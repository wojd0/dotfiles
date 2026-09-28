#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
CRONTAB_FILE="$REPO_DIR/cron/crontab"
LOG_DIR="$HOME/.local/state/dotfiles"
BLOCK_START="# BEGIN dotfiles cron"
BLOCK_END="# END dotfiles cron"

if ! command -v crontab >/dev/null 2>&1; then
  echo "error: crontab is required to install the dotfiles cron jobs" >&2
  exit 1
fi

# An unreadable crontab must stop the install; otherwise the rewrite would drop its entries.
read_current_crontab() {
  local error_output

  if crontab -l 2>/dev/null; then
    return
  fi

  error_output="$(crontab -l 2>&1 >/dev/null || true)"
  case "$error_output" in
    *"no crontab for"*)
      ;;
    *)
      echo "error: could not read the current crontab: $error_output" >&2
      return 1
      ;;
  esac
}

remove_managed_block() {
  awk -v start="$BLOCK_START" -v end="$BLOCK_END" '
    $0 == start { managed = 1; next }
    $0 == end { managed = 0; next }
    !managed { print }
  '
}

render_managed_block() {
  printf '%s\n' "$BLOCK_START"
  printf 'DOTFILES_DIR="%s"\n' "$REPO_DIR"
  printf 'DOTFILES_LOG_DIR="%s"\n' "$LOG_DIR"
  cat "$CRONTAB_FILE"
  printf '%s\n' "$BLOCK_END"
}

current_crontab="$(read_current_crontab)"
new_crontab="$(
  if [ -n "$current_crontab" ]; then
    printf '%s\n' "$current_crontab" | remove_managed_block
  fi
  render_managed_block
)"

mkdir -p "$LOG_DIR"
printf '%s\n' "$new_crontab" | crontab -
echo "installed cron jobs from $CRONTAB_FILE"
