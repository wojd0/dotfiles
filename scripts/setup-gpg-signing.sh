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
    suffix="[Y/n/q]"
  else
    suffix="[y/N/q]"
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
      q|Q|quit|QUIT|Quit)
        echo "Exiting."
        exit 0
        ;;
      *)
        echo "Please answer yes, no, or q to quit."
        ;;
    esac
  done
}

prompt_with_default() {
  prompt="$1"
  default_value="$2"

  if [ -n "$default_value" ]; then
    printf '%s [%s] (q to quit): ' "$prompt" "$default_value" >&2
  else
    printf '%s (q to quit): ' "$prompt" >&2
  fi

  IFS= read -r value
  case "$value" in
    q|Q|quit|QUIT|Quit)
      echo "Exiting." >&2
      return 130
      ;;
  esac
  printf '%s\n' "${value:-$default_value}"
}

ensure_interactive_terminal() {
  if [ ! -t 0 ] || [ ! -t 1 ]; then
    fail "this setup is interactive and must be run from a terminal"
  fi
}

ensure_macos_host() {
  if [ "$(uname)" != "Darwin" ]; then
    fail "run this setup on the macOS host, not inside a dev container"
  fi
}

rewrite_gpg_config() {
  config_file="$1"
  config_kind="$2"
  pinentry_program="${3:-}"
  temp_file="$(mktemp "${TMPDIR:-/tmp}/gpg-config.XXXXXX")"

  awk -v config_kind="$config_kind" '
    $0 == "# dotfiles: signed-commit hardening start" {
      managed_block = 1
      next
    }
    $0 == "# dotfiles: signed-commit hardening end" {
      managed_block = 0
      next
    }
    managed_block {
      next
    }
    {
      normalized = $0
      sub(/^[[:space:]]*/, "", normalized)
      split(normalized, fields, /[[:space:]]+/)

      if (config_kind == "agent" &&
          (fields[1] == "pinentry-program" ||
           fields[1] == "default-cache-ttl" ||
           fields[1] == "max-cache-ttl")) {
        next
      }

      if (config_kind == "gpg" &&
          fields[1] == "pinentry-mode" &&
          fields[2] == "loopback") {
        next
      }

      if (config_kind == "gpg" && fields[1] == "use-agent") {
        next
      }

      if ($0 == "") {
        trailing_blank_lines++
        next
      }

      while (trailing_blank_lines > 0) {
        print ""
        trailing_blank_lines--
      }
      print
    }
  ' "$config_file" >"$temp_file"

  if [ -s "$temp_file" ]; then
    echo >>"$temp_file"
  fi

  if [ "$config_kind" = "agent" ]; then
    {
      echo "# dotfiles: signed-commit hardening start"
      printf 'pinentry-program %s\n' "$pinentry_program"
      echo "default-cache-ttl 0"
      echo "max-cache-ttl 0"
      echo "# dotfiles: signed-commit hardening end"
    } >>"$temp_file"
  else
    {
      echo "# dotfiles: signed-commit hardening start"
      echo "use-agent"
      echo "# Never enable pinentry-mode loopback on the host."
      echo "# dotfiles: signed-commit hardening end"
    } >>"$temp_file"
  fi

  mv "$temp_file" "$config_file"
  chmod 600 "$config_file"
}

delete_keychain_passphrases() {
  if ! security find-generic-password -s "GnuPG" >/dev/null 2>&1; then
    return 0
  fi

  say "Stored GPG passphrases were found in macOS Keychain."
  echo "They can bypass the per-signature passphrase prompt even when agent caching is disabled."
  if ! confirm "Delete all Keychain password items with service GnuPG?" "n"; then
    echo "warning: remove the saved GnuPG entries before relying on per-commit prompts." >&2
    return 0
  fi

  deleted_count=0
  while security delete-generic-password -s "GnuPG" >/dev/null 2>&1; do
    deleted_count=$((deleted_count + 1))
  done
  echo "Deleted $deleted_count stored GPG passphrase item(s) from macOS Keychain."
}

harden_host_gpg() {
  pinentry_program="$(command -v pinentry-mac)"
  gnupg_dir="$HOME/.gnupg"
  agent_config="$gnupg_dir/gpg-agent.conf"
  gpg_config="$gnupg_dir/gpg.conf"

  say "Hardening host GPG for dev-container signing."
  mkdir -p "$gnupg_dir"
  chmod 700 "$gnupg_dir"
  touch "$agent_config" "$gpg_config"

  rewrite_gpg_config "$agent_config" "agent" "$pinentry_program"
  rewrite_gpg_config "$gpg_config" "gpg"

  defaults write org.gpgtools.pinentry-mac UseKeychain -bool NO
  defaults write org.gpgtools.pinentry-mac DisableKeychain -bool YES
  delete_keychain_passphrases

  gpg-agent --gpgconf-test
  gpgconf --kill gpg-agent
  echo "Configured GUI pinentry with no agent or Keychain passphrase caching."
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
  email="${1:-}"

  if [ -n "$email" ]; then
    key_listing="$(
      gpg --batch --with-colons --list-secret-keys "$email" 2>/dev/null || true
    )"
  else
    key_listing="$(gpg --batch --with-colons --list-secret-keys 2>/dev/null || true)"
  fi

  printf '%s\n' "$key_listing" |
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

get_secret_key_details() {
  fingerprint="$1"

  gpg --batch --with-colons --list-secret-keys "$fingerprint" 2>/dev/null |
    awk -F: '
      $1 == "sec" && !primary_seen {
        created = ($6 != "" ? $6 : "-")
        expires = ($7 != "" ? $7 : "-")
        primary_seen = 1
        next
      }
      primary_seen && $1 == "uid" {
        uid = ($10 != "" ? $10 : "(no user ID)")
        print created "\t" expires "\t" uid
        details_printed = 1
        exit
      }
      END {
        if (!details_printed) {
          if (created == "") {
            created = "-"
          }
          if (expires == "") {
            expires = "-"
          }
          print created "\t" expires "\t(no user ID)"
        }
      }
    '
}

format_key_date() {
  timestamp="$1"

  if [ "$timestamp" = "-" ]; then
    printf '%s\n' "unknown"
    return 0
  fi

  if formatted_date="$(date -r "$timestamp" '+%Y-%m-%d' 2>/dev/null)"; then
    printf '%s\n' "$formatted_date"
  elif formatted_date="$(date -d "@$timestamp" '+%Y-%m-%d' 2>/dev/null)"; then
    printf '%s\n' "$formatted_date"
  else
    printf '%s\n' "$timestamp"
  fi
}

choose_action() {
  say "What would you like to do?"
  echo "  1) Add or configure a signing key"
  echo "  2) Remove an existing signing key"

  while true; do
    printf 'Choose an action [1-2, q to quit]: '
    IFS= read -r selection

    case "$selection" in
      1)
        SELECTED_ACTION="add"
        return 0
        ;;
      2)
        SELECTED_ACTION="remove"
        return 0
        ;;
      q|Q|quit|QUIT|Quit)
        echo "Exiting."
        exit 0
        ;;
      *)
        echo "Enter 1, 2, or q to quit."
        ;;
    esac
  done
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
    printf 'Choose a key [1-%s, q to quit]: ' "${#fingerprints[@]}"
    IFS= read -r selection

    case "$selection" in
      q|Q|quit|QUIT|Quit)
        echo "Exiting."
        exit 0
        ;;
      ''|*[!0-9]*)
        echo "Enter one of the listed numbers, or q to quit."
        ;;
      *)
        if [ "$selection" -ge 1 ] && [ "$selection" -le "${#fingerprints[@]}" ]; then
          SELECTED_FINGERPRINT="${fingerprints[$((selection - 1))]}"
          return 0
        fi
        echo "Enter one of the listed numbers, or q to quit."
        ;;
    esac
  done
}

choose_key_to_remove() {
  fingerprints=()

  while IFS= read -r fingerprint; do
    if [ -n "$fingerprint" ]; then
      fingerprints+=("$fingerprint")
    fi
  done < <(list_secret_key_fingerprints)

  if [ "${#fingerprints[@]}" -eq 0 ]; then
    fail "no secret GPG signing keys were found"
  fi

  say "Local secret GPG signing keys:"
  for index in "${!fingerprints[@]}"; do
    fingerprint="${fingerprints[$index]}"
    key_details="$(get_secret_key_details "$fingerprint")"
    IFS=$'\t' read -r created_timestamp expires_timestamp key_uid <<<"$key_details"
    created_date="$(format_key_date "$created_timestamp")"

    if [ "$expires_timestamp" = "-" ]; then
      expires_date="never"
    else
      expires_date="$(format_key_date "$expires_timestamp")"
    fi

    printf '  %s) %s\n' "$((index + 1))" "$key_uid"
    printf '     Fingerprint: %s\n' "$fingerprint"
    printf '     Created: %s; Expires: %s\n' "$created_date" "$expires_date"
  done

  while true; do
    printf 'Choose a key to remove [1-%s, q to quit]: ' "${#fingerprints[@]}"
    IFS= read -r selection

    case "$selection" in
      q|Q|quit|QUIT|Quit)
        echo "Exiting."
        exit 0
        ;;
      ''|*[!0-9]*)
        echo "Enter one of the listed numbers, or q to quit."
        ;;
      *)
        if [ "$selection" -ge 1 ] && [ "$selection" -le "${#fingerprints[@]}" ]; then
          SELECTED_FINGERPRINT="${fingerprints[$((selection - 1))]}"
          return 0
        fi
        echo "Enter one of the listed numbers, or q to quit."
        ;;
    esac
  done
}

prompt_for_expiration() {
  while true; do
    if ! expiration="$(
      prompt_with_default \
        "Key expiration (for example 1y, 2y, or 0 for no expiration)" \
        "2y"
    )"; then
      return 130
    fi

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

  [ -n "$(github_key_database_id "$fingerprint")" ]
}

github_key_database_id() {
  fingerprint="$1"
  key_id="${fingerprint: -16}"

  gh api --paginate user/gpg_keys \
    --jq '.[] | [.id, .key_id] | @tsv' 2>/dev/null |
    awk -v expected="$key_id" '
      toupper($2) == toupper(expected) {
        print $1
        exit
      }
    '
}

ensure_github_auth() {
  say "Connecting to GitHub."
  if ! gh auth status --hostname github.com >/dev/null 2>&1; then
    echo "GitHub CLI authentication is required. Follow the prompts in your browser."
    gh auth login --hostname github.com --web
  fi
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

add_signing_key() {
  say "Add or configure a GPG signing key"
  echo "This will create or reuse a signing key, configure Git, add the public key"
  echo "to your GitHub account, and make a local signed test commit."

  harden_host_gpg

  default_name="${GITHUB_USERNAME:-$(git config --global --get user.name 2>/dev/null || true)}"
  default_email="${GITHUB_EMAIL:-$(git config --global --get user.email 2>/dev/null || true)}"

  if ! name="$(prompt_with_default "Name for commits" "$default_name")"; then
    return 0
  fi
  if ! email="$(prompt_with_default "Email for commits" "$default_email")"; then
    return 0
  fi

  if [ -z "$name" ]; then
    fail "a commit name is required"
  fi

  if [ -z "$email" ] || [[ "$email" != *@*.* ]]; then
    fail "a valid commit email is required"
  fi

  SELECTED_FINGERPRINT=""
  if ! choose_existing_key "$email"; then
    if ! expiration="$(prompt_for_expiration)"; then
      return 0
    fi
    generate_key "$name" "$email" "$expiration"
  fi

  say "Configuring Git to sign commits and tags."
  mkdir -p "$(dirname "$LOCAL_GIT_CONFIG")"
  git config --file "$LOCAL_GIT_CONFIG" user.name "$name"
  git config --file "$LOCAL_GIT_CONFIG" user.email "$email"
  git config --file "$LOCAL_GIT_CONFIG" user.signingkey "$SELECTED_FINGERPRINT"
  git config --file "$LOCAL_GIT_CONFIG" commit.gpgsign true
  git config --file "$LOCAL_GIT_CONFIG" tag.gpgSign true
  git config --file "$LOCAL_GIT_CONFIG" --unset-all gpg.program 2>/dev/null || true
  ensure_git_config_include

  ensure_github_auth
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
}

remove_signing_key() {
  say "Remove a GPG signing key"
  choose_key_to_remove

  echo
  echo "This will remove the key from GitHub and permanently delete its local"
  echo "secret and public key material."
  if ! confirm "Remove $SELECTED_FINGERPRINT?" "n"; then
    echo "No key was removed."
    return 0
  fi

  ensure_github_auth
  github_key_id="$(github_key_database_id "$SELECTED_FINGERPRINT")"
  if [ -n "$github_key_id" ]; then
    gh gpg-key delete "$github_key_id" --yes
    echo "Removed the GPG key from GitHub."
  else
    echo "The GPG key was not registered with GitHub."
  fi

  configured_fingerprint="$(
    git config --file "$LOCAL_GIT_CONFIG" --get user.signingkey 2>/dev/null || true
  )"
  if [ "$(printf '%s' "$configured_fingerprint" | tr '[:lower:]' '[:upper:]')" = \
    "$(printf '%s' "$SELECTED_FINGERPRINT" | tr '[:lower:]' '[:upper:]')" ]; then
    git config --file "$LOCAL_GIT_CONFIG" --unset-all user.signingkey || true
    git config --file "$LOCAL_GIT_CONFIG" --unset-all commit.gpgsign || true
    git config --file "$LOCAL_GIT_CONFIG" --unset-all tag.gpgSign || true
    echo "Cleared Git signing settings for the removed key."
  fi

  gpg --batch --yes --delete-secret-and-public-key "$SELECTED_FINGERPRINT"

  say "GPG signing key removed."
  echo "Fingerprint: $SELECTED_FINGERPRINT"
}

ensure_interactive_terminal
ensure_macos_host
require_command git
require_command gpg
require_command gpg-agent
require_command gpgconf
require_command gh
require_command pinentry-mac
require_command defaults
require_command security

export GPG_TTY
GPG_TTY="$(tty)"

say "GPG commit signing"
SELECTED_ACTION=""
choose_action

case "$SELECTED_ACTION" in
  add)
    add_signing_key
    ;;
  remove)
    remove_signing_key
    ;;
esac
