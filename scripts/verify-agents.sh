#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_DIR"

CANONICAL_SKILLS_DIR=".agents/skills"
AGENT_SKILL_DIRS=(
  ".claude/skills"
)

fail() {
  echo "$1"
  exit 1
}

is_tracked() {
  git ls-files --error-unmatch -- "$1" >/dev/null 2>&1
}

lock_skill_names() {
  jq -r '.skills | keys[]' skills-lock.json
}

if [ ! -d ".agents" ] || [ -L ".agents" ]; then
  fail ".agents must be a real directory at the repository root"
fi

if [ ! -d ".agents/rules" ]; then
  fail ".agents/rules must be a directory"
fi

if [ ! -f "skills-lock.json" ]; then
  fail "skills-lock.json is missing"
fi

lock_skills=()
while IFS= read -r skill_name; do
  lock_skills+=("$skill_name")
done < <(lock_skill_names)

is_lock_skill() {
  local name="$1"
  local skill_name

  for skill_name in "${lock_skills[@]}"; do
    if [ "$skill_name" = "$name" ]; then
      return 0
    fi
  done

  return 1
}

for skill_name in "${lock_skills[@]}"; do
  skill_path="$CANONICAL_SKILLS_DIR/$skill_name"

  if [ -L "$skill_path" ] || [ ! -d "$skill_path" ]; then
    fail "lock skill $skill_path must be a real directory"
  fi

  if ! is_tracked "$skill_path/SKILL.md"; then
    fail "lock skill $skill_path/SKILL.md must be tracked"
  fi

  if [ -d "skills/$skill_name" ]; then
    fail "skill '$skill_name' is in both skills-lock.json and skills/"
  fi

  for agent_dir in "${AGENT_SKILL_DIRS[@]}"; do
    link_path="$agent_dir/$skill_name"
    link_target="../../$CANONICAL_SKILLS_DIR/$skill_name"

    if [ ! -L "$link_path" ] || [ "$(readlink "$link_path")" != "$link_target" ]; then
      fail "$link_path must link to $link_target"
    fi

    if ! is_tracked "$link_path"; then
      fail "$link_path must be tracked"
    fi
  done
done

for skill_dir in skills/*; do
  if [ ! -d "$skill_dir" ]; then
    continue
  fi

  if [ ! -f "$skill_dir/SKILL.md" ]; then
    fail "missing $skill_dir/SKILL.md"
  fi

  skill_name="${skill_dir##*/}"
  link_path="$CANONICAL_SKILLS_DIR/$skill_name"
  link_target="../../skills/$skill_name"

  if [ ! -L "$link_path" ] || [ "$(readlink "$link_path")" != "$link_target" ]; then
    fail "$link_path must link to $link_target"
  fi

  if ! is_tracked "$link_path"; then
    fail "$link_path must be tracked"
  fi
done

while IFS= read -r tracked_name; do
  if is_lock_skill "$tracked_name" || [ -d "skills/$tracked_name" ]; then
    continue
  fi

  fail "$CANONICAL_SKILLS_DIR/$tracked_name is tracked but is not in skills-lock.json or skills/"
done < <(git ls-files -- "$CANONICAL_SKILLS_DIR" | cut -d/ -f3 | sort -u)

for agent_dir in "${AGENT_SKILL_DIRS[@]}"; do
  for link_path in "$agent_dir"/*; do
    if [ ! -e "$link_path" ] && [ ! -L "$link_path" ]; then
      continue
    fi

    if ! is_lock_skill "${link_path##*/}"; then
      fail "$link_path is not a skill in skills-lock.json"
    fi
  done
done

for agent_file in .agents/agents/*.md; do
  if [ ! -f "$agent_file" ]; then
    continue
  fi

  agent_name="$(basename "$agent_file" .md)"
  codex_file=".agents/agents/$agent_name.toml"

  if ! grep -qx "name: $agent_name" "$agent_file"; then
    echo "$agent_file must declare name: $agent_name"
    exit 1
  fi

  if [ ! -f "$codex_file" ] || ! grep -qx "name = \"$agent_name\"" "$codex_file"; then
    echo "$codex_file must declare name = \"$agent_name\""
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
    fail "provider-specific and wrapper agent directories are not allowed; found $path"
  fi
done

echo "agent configuration uses root .agents, skills, and skills-lock.json"
