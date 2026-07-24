#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
LOCAL_GIT_CONFIG="$HOME/.gitconfig.local"
TEMP_DIR=""

cleanup() {
  if [ -n "$TEMP_DIR" ] && [ -d "$TEMP_DIR" ]; then
    rm -rf "$TEMP_DIR"
  fi
}

trap cleanup EXIT

say() {
  printf '\n%s\n' "$1"
}

fail() {
  echo "error: $1" >&2
  exit 1
}

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    fail "$1 is required; run $REPO_DIR/scripts/install.sh first"
  fi
}

confirm() {
  prompt="$1"
  default_answer="${2:-y}"

  if [ "$default_answer" = "y" ]; then
    suffix="[Y/n]"
  else
    suffix="[y/N]"
  fi

  while true; do
    printf '%s %s ' "$prompt" "$suffix"
    IFS= read -r answer
    answer="${answer:-$default_answer}"

    case "$answer" in
      y|Y|yes|YES|Yes)
        return 0
        ;;
      n|N|no|NO|No)
        return 1
        ;;
      *)
        echo "Please answer yes or no."
        ;;
    esac
  done
}

prompt_with_default() {
  prompt="$1"
  default_value="$2"

  if [ -n "$default_value" ]; then
    printf '%s [%s]: ' "$prompt" "$default_value" >&2
  else
    printf '%s: ' "$prompt" >&2
  fi

  IFS= read -r value
  printf '%s\n' "${value:-$default_value}"
}

ensure_interactive_terminal() {
  if [ ! -t 0 ] || [ ! -t 1 ]; then
    fail "this setup is interactive and must be run from a terminal"
  fi
}

ensure_git_config_include() {
  include_found=false

  while IFS= read -r include_path; do
    case "$include_path" in
      "~/.gitconfig.local"|"$HOME/.gitconfig.local")
        include_found=true
        ;;
    esac
  done < <(git config --global --get-all include.path 2>/dev/null || true)

  if [ "$include_found" = false ]; then
    git config --global --add include.path "~/.gitconfig.local"
  fi
}

list_secret_key_fingerprints() {
  email="$1"

  gpg --batch --with-colons --list-secret-keys "$email" 2>/dev/null |
    awk -F: '
      function print_signing_key() {
        if (primary_fingerprint != "" && signing_capability) {
          print primary_fingerprint
        }
      }
      $1 == "sec" {
        print_signing_key()
        primary_fingerprint = ""
        fingerprint_expected = 1
        signing_capability = ($12 ~ /[sS]/)
        next
      }
      $1 == "ssb" && $12 ~ /[sS]/ {
        signing_capability = 1
        next
      }
      fingerprint_expected && $1 == "fpr" {
        primary_fingerprint = $10
        fingerprint_expected = 0
      }
      END { print_signing_key() }
    '
}

choose_existing_key() {
  email="$1"
  fingerprints=()

  while IFS= read -r fingerprint; do
    if [ -n "$fingerprint" ]; then
      fingerprints+=("$fingerprint")
    fi
  done < <(list_secret_key_fingerprints "$email")

  if [ "${#fingerprints[@]}" -eq 0 ]; then
    return 1
  fi

  say "Existing secret GPG signing keys for $email:"
  for index in "${!fingerprints[@]}"; do
    printf '  %s) %s\n' "$((index + 1))" "${fingerprints[$index]}"
  done

  if ! confirm "Reuse an existing key?" "y"; then
    return 1
  fi

  if [ "${#fingerprints[@]}" -eq 1 ]; then
    SELECTED_FINGERPRINT="${fingerprints[0]}"
    return 0
  fi

  while true; do
    printf 'Choose a key [1-%s]: ' "${#fingerprints[@]}"
    IFS= read -r selection

    case "$selection" in
      ''|*[!0-9]*)
        echo "Enter one of the listed numbers."
        ;;
      *)
        if [ "$selection" -ge 1 ] && [ "$selection" -le "${#fingerprints[@]}" ]; then
          SELECTED_FINGERPRINT="${fingerprints[$((selection - 1))]}"
          return 0
        fi
        echo "Enter one of the listed numbers."
        ;;
    esac
  done
}

prompt_for_expiration() {
  while true; do
    expiration="$(prompt_with_default "Key expiration (for example 1y, 2y, or 0 for no expiration)" "2y")"

    if [ "$expiration" = "0" ] ||
      [[ "$expiration" =~ ^[1-9][0-9]*[dwmy]$ ]]; then
      printf '%s\n' "$expiration"
      return 0
    fi

    echo "Use 0 or a number followed by d, w, m, or y." >&2
  done
}

generate_key() {
  name="$1"
  email="$2"
  expiration="$3"
  user_id="$name <$email>"

  say "GPG will now ask you to protect the new key with a passphrase."
  echo "Use a strong, memorable passphrase. GPG may open a separate pinentry window."

  generation_status="$(
    gpg --status-fd 1 --quick-generate-key "$user_id" ed25519 cert "$expiration"
  )"
  fingerprint="$(
    printf '%s\n' "$generation_status" |
      awk '$2 == "KEY_CREATED" { print $4; exit }'
  )"

  if [ -z "$fingerprint" ]; then
    fail "GPG created a key but its fingerprint could not be determined"
  fi

  gpg --quick-add-key "$fingerprint" ed25519 sign "$expiration"
  SELECTED_FINGERPRINT="$fingerprint"
}

github_key_exists() {
  fingerprint="$1"
  key_id="${fingerprint: -16}"

  gh api --paginate user/gpg_keys --jq '.[].key_id' 2>/dev/null |
    tr '[:lower:]' '[:upper:]' |
    awk -v expected="$key_id" '$0 == expected { found = 1 } END { exit !found }'
}

check_github_email() {
  email="$1"
  verified_email="$(
    gh api user/emails \
      --jq '.[] | select(.verified == true) | .email' \
      2>/dev/null |
      awk -v expected="$email" '$0 == expected { print; exit }' || true
  )"

  if [ "$verified_email" != "$email" ]; then
    echo
    echo "warning: GitHub did not report $email as a verified account email." >&2
    echo "Signatures only show as Verified when the commit email belongs to your GitHub account." >&2
    echo "Check https://github.com/settings/emails after this script finishes." >&2
  fi
}

verify_signed_commit() {
  fingerprint="$1"
  name="$2"
  email="$3"
  verification_repo="$TEMP_DIR/verification"

  mkdir -p "$verification_repo"
  git -C "$verification_repo" init --quiet
  git -C "$verification_repo" \
    -c "user.name=$name" \
    -c "user.email=$email" \
    -c "user.signingkey=$fingerprint" \
    -c commit.gpgsign=true \
    commit --quiet --allow-empty -m "Verify GPG signing setup"
  git -C "$verification_repo" verify-commit HEAD
}

ensure_interactive_terminal
require_command git
require_command gpg
require_command gh

export GPG_TTY
GPG_TTY="$(tty)"

say "GPG commit signing setup"
echo "This will create or reuse a signing key, configure Git, add the public key"
echo "to your GitHub account, and make a local signed test commit."

default_name="${GITHUB_USERNAME:-$(git config --global --get user.name 2>/dev/null || true)}"
default_email="${GITHUB_EMAIL:-$(git config --global --get user.email 2>/dev/null || true)}"

name="$(prompt_with_default "Name for commits" "$default_name")"
email="$(prompt_with_default "Email for commits" "$default_email")"

if [ -z "$name" ]; then
  fail "a commit name is required"
fi

if [ -z "$email" ] || [[ "$email" != *@*.* ]]; then
  fail "a valid commit email is required"
fi

SELECTED_FINGERPRINT=""
if ! choose_existing_key "$email"; then
  expiration="$(prompt_for_expiration)"
  generate_key "$name" "$email" "$expiration"
fi

say "Configuring Git to sign commits and tags."
mkdir -p "$(dirname "$LOCAL_GIT_CONFIG")"
git config --file "$LOCAL_GIT_CONFIG" user.name "$name"
git config --file "$LOCAL_GIT_CONFIG" user.email "$email"
git config --file "$LOCAL_GIT_CONFIG" user.signingkey "$SELECTED_FINGERPRINT"
git config --file "$LOCAL_GIT_CONFIG" commit.gpgsign true
git config --file "$LOCAL_GIT_CONFIG" tag.gpgSign true
git config --file "$LOCAL_GIT_CONFIG" gpg.program "$(command -v gpg)"
ensure_git_config_include

say "Connecting to GitHub."
if ! gh auth status --hostname github.com >/dev/null 2>&1; then
  echo "GitHub CLI authentication is required. Follow the prompts in your browser."
  gh auth login --hostname github.com --web
fi

check_github_email "$email"

TEMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/gpg-signing-setup.XXXXXX")"
public_key_file="$TEMP_DIR/public-key.asc"
gpg --armor --export "$SELECTED_FINGERPRINT" >"$public_key_file"

if github_key_exists "$SELECTED_FINGERPRINT"; then
  echo "The GPG key is already registered with GitHub."
else
  key_title="$(hostname -s 2>/dev/null || hostname) Git signing key"
  gh gpg-key add "$public_key_file" --title "$key_title"
  echo "Added the public GPG key to GitHub."
fi

say "Creating a signed test commit."
verify_signed_commit "$SELECTED_FINGERPRINT" "$name" "$email"

say "GPG signing is ready."
echo "Fingerprint: $SELECTED_FINGERPRINT"
echo "Git config:  $LOCAL_GIT_CONFIG"
echo "GitHub keys: https://github.com/settings/keys"
echo
echo "New commits and annotated tags will now be signed automatically."
