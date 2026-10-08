#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"

run_skills_cli() {
  if command -v bun >/dev/null 2>&1; then
    bun x skills "$@"
  else
    npx -y skills "$@"
  fi
}

restore_lock_managed_skills() {
  if ! (cd "$REPO_DIR" && GIT_TERMINAL_PROMPT=0 run_skills_cli experimental_install </dev/null); then
    echo "warning: lock-managed skills were not restored" >&2
  fi

  git -C "$REPO_DIR" checkout -- .agents/skills
}

link_path() {
  local source_path="$1"
  local link_path="$2"

  if [ -e "$link_path" ] && [ ! -L "$link_path" ]; then
    echo "error: $link_path exists and is not a symbolic link" >&2
    exit 1
  fi

  ln -sfn "$source_path" "$link_path"
}

restore_lock_managed_skills

mkdir -p "$HOME/.claude"
link_path "$REPO_DIR/.agents" "$HOME/.agents"
link_path "../.agents/rules" "$HOME/.claude/rules"
link_path "../.agents/skills" "$HOME/.claude/skills"
link_path "../.agents/AGENTS.md" "$HOME/.claude/CLAUDE.md"

echo "Cloud agent configuration linked from $REPO_DIR."
