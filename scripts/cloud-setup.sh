#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"

link_path() {
  local source_path="$1"
  local link_path="$2"
  local entry

  if [ -L "$link_path" ] || [ ! -e "$link_path" ]; then
    ln -sfn "$source_path" "$link_path"
    return
  fi

  if [ ! -d "$link_path" ] || [ ! -d "$source_path" ]; then
    echo "warning: kept $link_path, which exists and is not a symbolic link" >&2
    return
  fi

  for entry in "$source_path"/*; do
    if [ -e "$entry" ]; then
      link_path "$entry" "$link_path/${entry##*/}"
    fi
  done
}

mkdir -p "$HOME/.claude"
link_path "$REPO_DIR/.agents" "$HOME/.agents"
link_path "$REPO_DIR/.agents/rules" "$HOME/.claude/rules"
link_path "$REPO_DIR/.agents/skills" "$HOME/.claude/skills"
link_path "$REPO_DIR/.agents/agents" "$HOME/.claude/agents"
link_path "$REPO_DIR/.agents/AGENTS.md" "$HOME/.claude/CLAUDE.md"

echo "Cloud agent configuration linked from $REPO_DIR."
