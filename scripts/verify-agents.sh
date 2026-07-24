#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_DIR"

if [ ! -d ".agents" ] || [ -L ".agents" ]; then
  echo ".agents must be a real directory at the repository root"
  exit 1
fi

if [ ! -d ".agents/rules" ]; then
  echo ".agents/rules must be a directory"
  exit 1
fi

for skill_dir in custom-skills/*; do
  if [ ! -d "$skill_dir" ]; then
    continue
  fi

  if [ ! -f "$skill_dir/SKILL.md" ]; then
    echo "missing $skill_dir/SKILL.md"
    exit 1
  fi

  skill_name="${skill_dir##*/}"
  link_path=".agents/skills/$skill_name"
  link_target="../../custom-skills/$skill_name"

  if [ ! -L "$link_path" ] || [ "$(readlink "$link_path")" != "$link_target" ]; then
    echo "$link_path must link to $link_target"
    exit 1
  fi
done

provider_directories=(
  "agents"
  "claude"
  "codex"
  "cursor"
  "userskills"
)

for path in "${provider_directories[@]}"; do
  if [ -e "$path" ]; then
    echo "provider-specific and wrapper agent directories are not allowed; found $path"
    exit 1
  fi
done

echo "agent configuration uses root .agents and custom-skills"
