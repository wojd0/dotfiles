#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
OH_MY_ZSH_DIR="$HOME/.oh-my-zsh"
PLUGIN_FILE="$REPO_DIR/shell/.oh-my-zsh-plugins"

if [ ! -f "$OH_MY_ZSH_DIR/oh-my-zsh.sh" ]; then
  echo "error: Oh My Zsh is not installed at $OH_MY_ZSH_DIR" >&2
  echo "run ./scripts/install.sh first" >&2
  exit 1
fi

if [ ! -f "$PLUGIN_FILE" ]; then
  echo "error: $PLUGIN_FILE is missing" >&2
  exit 1
fi

while read -r plugin_name plugin_repository extra; do
  if [ -z "$plugin_name" ] || [[ "$plugin_name" == \#* ]]; then
    continue
  fi

  if [ -n "${extra:-}" ] || [[ ! "$plugin_name" =~ ^[A-Za-z0-9][A-Za-z0-9._-]*$ ]]; then
    echo "error: invalid plugin entry in $PLUGIN_FILE: $plugin_name ${plugin_repository:-} ${extra:-}" >&2
    exit 1
  fi

  if [ -z "${plugin_repository:-}" ]; then
    if [ ! -d "$OH_MY_ZSH_DIR/plugins/$plugin_name" ]; then
      echo "error: Oh My Zsh does not include the '$plugin_name' plugin" >&2
      exit 1
    fi
    continue
  fi

  plugin_dir="$OH_MY_ZSH_DIR/custom/plugins/$plugin_name"
  if [ -d "$plugin_dir/.git" ]; then
    echo "$plugin_name is already installed."
    continue
  fi

  if [ -e "$plugin_dir" ]; then
    echo "error: $plugin_dir exists but is not a Git checkout" >&2
    echo "move or remove it, then rerun $0" >&2
    exit 1
  fi

  echo "Installing the $plugin_name Oh My Zsh plugin."
  git clone --depth 1 "$plugin_repository" "$plugin_dir"
done < "$PLUGIN_FILE"
