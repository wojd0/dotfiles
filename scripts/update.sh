#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_DIR"

INSTALL_PATTERN='^(scripts/install\.sh|scripts/oh-my-zsh\.sh|shell/\.oh-my-zsh-plugins|setup\.sh)$'
CRON_PATTERN='^(cron/|scripts/cron\.sh$)'
SHELL_PATTERN='^shell/'

ensure_clean_worktree() {
  if [ -n "$(git status --porcelain)" ]; then
    echo "error: the working tree has local changes; commit or stash them first" >&2
    git status --short >&2
    exit 1
  fi
}

pull_changes() {
  if ! git pull --rebase; then
    echo "error: git pull --rebase failed; resolve the rebase, then rerun ./scripts/update.sh" >&2
    exit 1
  fi
}

files_changed() {
  printf '%s\n' "$CHANGED_FILES" | grep -Eq "$1"
}

ensure_clean_worktree
OLD_HEAD="$(git rev-parse HEAD)"
pull_changes
CHANGED_FILES="$(git diff --name-only "$OLD_HEAD" HEAD)"

if files_changed "$INSTALL_PATTERN"; then
  ./setup.sh
else
  ./scripts/stow.sh
  if files_changed "$CRON_PATTERN"; then
    ./scripts/cron.sh
  fi
fi

./scripts/verify-agents.sh

if files_changed "$SHELL_PATTERN"; then
  echo "Shell configuration changed. Start a new shell or run: exec zsh"
fi

echo "Update complete."
