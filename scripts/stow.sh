#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_DIR"

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "error: $1 is required; run ./scripts/install.sh first" >&2
    exit 1
  fi
}

require_command git
require_command stow
require_command jq

ensure_stow_sources_safe() {
  local untracked_files

  if ! git diff --quiet -- shell git .agents local; then
    echo "error: stow source packages have unstaged changes; stage, stash, or commit them first" >&2
    exit 1
  fi

  untracked_files="$(git ls-files --others --exclude-standard -- shell git .agents local)"
  if [ -n "$untracked_files" ]; then
    echo "error: stow source packages have untracked files; add, stash, or remove them first" >&2
    printf '%s\n' "$untracked_files" >&2
    exit 1
  fi
}

ensure_stow_sources_safe

"$REPO_DIR/scripts/verify-agents.sh"

stow --adopt -t "$HOME" shell
stow --adopt -t "$HOME" git
mkdir -p "$HOME/.agents"
stow --adopt -t "$HOME/.agents" .agents

link_agent_compatibility_path() {
  provider_dir="$1"
  source_name="$2"
  link_name="$3"
  source_path="$HOME/.agents/$source_name"
  link_path="$HOME/$provider_dir/$link_name"

  if [ ! -e "$source_path" ]; then
    echo "error: canonical agent path $source_path is missing" >&2
    exit 1
  fi

  mkdir -p "$HOME/$provider_dir"

  if [ -L "$link_path" ]; then
    if [ "$link_path" -ef "$source_path" ]; then
      return
    fi

    echo "error: $link_path points somewhere other than $source_path" >&2
    exit 1
  fi

  if [ -e "$link_path" ]; then
    echo "error: $link_path exists and is not a symbolic link" >&2
    exit 1
  fi

  ln -s "../.agents/$source_name" "$link_path"
}

link_agent_compatibility_path ".claude" "rules" "rules"
link_agent_compatibility_path ".claude" "skills" "skills"
link_agent_compatibility_path ".claude" "agents" "agents"
link_agent_compatibility_path ".claude" "AGENTS.md" "CLAUDE.md"
link_agent_compatibility_path ".codex" "agents" "agents"

prepare_secrets_file() {
  local template="local/.secrets.example"
  local legacy_file="local/.secrets"
  local target="$HOME/.secrets"

  # Secrets are user-owned; this preservation check must not apply to other dotfiles.
  if [ -e "$target" ] || [ -L "$target" ]; then
    echo "skip $target"
    return
  fi

  if [ -e "$legacy_file" ]; then
    mv "$legacy_file" "$target"
    echo "migrated $legacy_file to $target"
  else
    cp "$template" "$target"
    echo "created $target (fill in your local values)"
  fi

  chmod 600 "$target"
}

prepare_secrets_file

if [ ! -f "local/.gitconfig.local" ]; then
  cp "local/.gitconfig.local.example" "local/.gitconfig.local"
  echo "created local/.gitconfig.local (set your GPG signing key)"
fi

stow --adopt --ignore='\.example$' --ignore='^\.secrets$' -t "$HOME" local
git restore --worktree -- shell git .agents local
