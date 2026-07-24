#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"

if [[ "$(uname)" != "Darwin" ]]; then
  echo "error: scripts/install.sh currently supports macOS only" >&2
  exit 1
fi

if ! command -v brew >/dev/null 2>&1; then
  echo "Homebrew is required and will now be installed."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

brew install stow bun pre-commit gh fzf

OH_MY_ZSH_DIR="$HOME/.oh-my-zsh"

install_oh_my_zsh() {
  if [ -f "$OH_MY_ZSH_DIR/oh-my-zsh.sh" ]; then
    echo "Oh My Zsh is already installed."
    return
  fi

  if [ -e "$OH_MY_ZSH_DIR" ]; then
    echo "error: $OH_MY_ZSH_DIR exists but is not a complete Oh My Zsh installation" >&2
    echo "move or remove it, then rerun ./scripts/install.sh" >&2
    exit 1
  fi

  echo "Installing Oh My Zsh."
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes ZSH="$OH_MY_ZSH_DIR" \
    /bin/sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}

install_oh_my_zsh
"$REPO_DIR/scripts/oh-my-zsh.sh"

echo "Dependencies and Zsh plugins installed."
echo "Run ./scripts/stow.sh to link and configure the dotfiles."
