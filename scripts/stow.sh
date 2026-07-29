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

require_command bun
require_command git
require_command stow

if [ ! -f "skills-lock.json" ]; then
  echo "error: $REPO_DIR/skills-lock.json is missing" >&2
  exit 1
fi

remove_custom_skill_links() {
  skill_dir="$1"
  skill_name="${skill_dir##*/}"
  link_path=".agents/skills/$skill_name"
  link_target="../../custom-skills/$skill_name"

  if [ -L "$link_path" ] && [ "$(readlink "$link_path")" = "$link_target" ]; then
    unlink "$link_path"
  fi
}

link_custom_skill() {
  skill_dir="$1"
  skill_name="${skill_dir##*/}"
  link_path=".agents/skills/$skill_name"
  link_target="../../custom-skills/$skill_name"

  if [ -e "$link_path" ] || [ -L "$link_path" ]; then
    echo "error: custom skill '$skill_name' conflicts with a lock-managed skill" >&2
    exit 1
  fi

  ln -s "$link_target" "$link_path"
}

mkdir -p ".agents/skills"

for skill_dir in custom-skills/*; do
  if [ -d "$skill_dir" ]; then
    remove_custom_skill_links "$skill_dir"
  fi
done

if ! bun x skills experimental_install; then
  for skill_dir in custom-skills/*; do
    if [ -d "$skill_dir" ]; then
      link_custom_skill "$skill_dir"
    fi
  done
  exit 1
fi

while IFS= read -r skill_name; do
  if [ ! -f ".agents/skills/$skill_name/SKILL.md" ]; then
    echo "error: lock-managed skill '$skill_name' was not restored" >&2
    exit 1
  fi
done < <(
  bun -e 'const lock = await Bun.file("skills-lock.json").json(); console.log(Object.keys(lock.skills).join("\n"));'
)

for skill_dir in custom-skills/*; do
  if [ -d "$skill_dir" ]; then
    link_custom_skill "$skill_dir"
  fi
done

stow --adopt -t "$HOME" shell
stow --adopt -t "$HOME" git
mkdir -p "$HOME/.agents"
stow --adopt -t "$HOME/.agents" .agents

link_agent_compatibility_directory() {
  directory_name="$1"
  source_path="$HOME/.agents/$directory_name"
  link_path="$HOME/.claude/$directory_name"

  if [ ! -d "$source_path" ]; then
    echo "error: canonical agent directory $source_path is missing" >&2
    exit 1
  fi

  mkdir -p "$HOME/.claude"

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

  ln -s "../.agents/$directory_name" "$link_path"
}

link_agent_compatibility_directory "rules"
link_agent_compatibility_directory "skills"

prepare_secrets_file() {
  template="$1"
  legacy_file="$2"
  target="$3"

  if [ -L "$target" ]; then
    if [ ! -e "$legacy_file" ] || [ ! "$target" -ef "$legacy_file" ]; then
      echo "error: $target points somewhere other than $legacy_file" >&2
      exit 1
    fi

    mv "$legacy_file" "$target"
    echo "migrated $target to a regular home-directory file"
  elif [ -e "$target" ] && [ -e "$legacy_file" ]; then
    echo "error: both $target and $legacy_file exist" >&2
    echo "merge them manually, remove $legacy_file, then rerun" >&2
    exit 1
  elif [ -e "$target" ]; then
    echo "skip $target"
  elif [ -e "$legacy_file" ]; then
    mv "$legacy_file" "$target"
    echo "migrated $legacy_file to $target"
  else
    cp "$template" "$target"
    echo "created $target (fill in your local values)"
  fi

  chmod 600 "$target"
}

prepare_secrets_file "local/.secrets.example" "local/.secrets" "$HOME/.secrets"

if [ ! -f "local/.gitconfig.local" ]; then
  cp "local/.gitconfig.local.example" "local/.gitconfig.local"
  echo "created local/.gitconfig.local (set your GPG signing key)"
fi

stow --adopt --ignore='\.example$' --ignore='^\.secrets$' -t "$HOME" local
git restore .
