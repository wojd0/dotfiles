#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
OS_NAME="$(uname -s)"

case "$OS_NAME" in
  Darwin|Linux)
    ;;
  *)
    echo "error: unsupported operating system: $OS_NAME" >&2
    exit 1
    ;;
esac

if ! command -v brew >/dev/null 2>&1; then
  echo "Homebrew is required and will now be installed."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

for brew_bin in /opt/homebrew/bin /home/linuxbrew/.linuxbrew/bin /usr/local/bin; do
  if [ -x "$brew_bin/brew" ]; then
    eval "$("$brew_bin/brew" shellenv)"
    break
  fi
done

if ! command -v brew >/dev/null 2>&1; then
  echo "error: Homebrew was installed but is not available on PATH" >&2
  exit 1
fi

dependencies=(stow bun pre-commit gh fzf gnupg jq zsh)
if [ "$OS_NAME" = "Darwin" ]; then
  dependencies+=(pinentry-mac)
else
  dependencies+=(pinentry)
fi
brew install "${dependencies[@]}"

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
  zshrc_placeholder_created=false
  if [ ! -e "$HOME/.zshrc" ] && [ ! -L "$HOME/.zshrc" ]; then
    touch "$HOME/.zshrc"
    zshrc_placeholder_created=true
  fi

  if ! RUNZSH=no CHSH=no KEEP_ZSHRC=yes ZSH="$OH_MY_ZSH_DIR" \
    /bin/sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"; then
    if [ "$zshrc_placeholder_created" = true ] && [ ! -s "$HOME/.zshrc" ]; then
      rm "$HOME/.zshrc"
    fi
    return 1
  fi

  if [ "$zshrc_placeholder_created" = true ] && [ ! -s "$HOME/.zshrc" ]; then
    rm "$HOME/.zshrc"
  fi
}

install_oh_my_zsh
"$REPO_DIR/scripts/oh-my-zsh.sh"

echo "Dependencies and Zsh plugins installed."
echo "Run ./scripts/stow.sh to link and configure the dotfiles."
