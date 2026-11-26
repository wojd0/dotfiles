#!/usr/bin/env bash
set -euo pipefail

TMP_CODEBASES_DIR="$HOME/d/.tmp-codebases"
MAX_AGE_MINUTES=$((3 * 24 * 60))

log() {
  printf '%s %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*"
}

# A codebase is the outermost directory holding a .git entry; its own mtime is its age.
find_expired_codebases() {
  find "$TMP_CODEBASES_DIR" -mindepth 1 -type d -exec test -e '{}/.git' ';' -prune \
    -mmin "+$MAX_AGE_MINUTES" -print0
}

# Linked worktrees go through git so their main repository drops the metadata that
# keeps their branch checked out.
remove_codebase() {
  local codebase="$1"
  local git_dir
  local common_dir

  if [ -f "$codebase/.git" ] \
    && git_dir="$(git -C "$codebase" rev-parse --path-format=absolute --git-dir 2>/dev/null)" \
    && common_dir="$(git -C "$codebase" rev-parse --path-format=absolute --git-common-dir 2>/dev/null)" \
    && [ "$git_dir" != "$common_dir" ]; then
    git --git-dir="$common_dir" worktree remove --force "$codebase"
  else
    rm -rf -- "$codebase"
  fi
}

remove_empty_parents() {
  local directory
  directory="$(dirname "$1")"

  while [ "$directory" != "$TMP_CODEBASES_DIR" ] && rmdir "$directory" 2>/dev/null; do
    directory="$(dirname "$directory")"
  done
}

if [ ! -d "$TMP_CODEBASES_DIR" ]; then
  exit 0
fi

codebases=()
while IFS= read -r -d '' codebase; do
  codebases+=("$codebase")
done < <(find_expired_codebases)

# Cron runs /bin/bash, and Bash 3.2 reports an empty array expansion as unbound under set -u.
if [ "${#codebases[@]}" -eq 0 ]; then
  exit 0
fi

failures=0
for codebase in "${codebases[@]}"; do
  if remove_codebase "$codebase"; then
    remove_empty_parents "$codebase"
    log "removed $codebase"
  else
    log "error: could not remove $codebase" >&2
    failures=$((failures + 1))
  fi
done

[ "$failures" -eq 0 ]
