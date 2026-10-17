#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
OS_NAME="$(uname -s)"

load_brew() {
  local brew_bin

  for brew_bin in /opt/homebrew/bin /home/linuxbrew/.linuxbrew/bin /usr/local/bin; do
    if [ -x "$brew_bin/brew" ]; then
      eval "$("$brew_bin/brew" shellenv)"
      return
    fi
  done
}

is_windows() {
  case "$OS_NAME" in
    MINGW*|MSYS*|CYGWIN*)
      return 0
      ;;
  esac
  return 1
}

winget_command() {
  if command -v winget >/dev/null 2>&1; then
    echo winget
  elif command -v winget.exe >/dev/null 2>&1; then
    echo winget.exe
  fi
}

detect_package_manager() {
  if command -v brew >/dev/null 2>&1; then
    echo brew
  elif command -v apt-get >/dev/null 2>&1; then
    echo apt
  elif is_windows && [ -n "$(winget_command)" ]; then
    echo winget
  fi
}

install_brew() {
  case "$OS_NAME" in
    Darwin|Linux)
      ;;
    *)
      echo "error: no supported package manager found and Homebrew cannot be installed on $OS_NAME" >&2
      exit 1
      ;;
  esac

  echo "No supported package manager found. Homebrew will now be installed."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  load_brew

  if ! command -v brew >/dev/null 2>&1; then
    echo "error: Homebrew was installed but is not available on PATH" >&2
    exit 1
  fi
}

install_with_brew() {
  local dependencies=(stow bun pre-commit gh fzf gnupg jq zsh)

  if [ "$OS_NAME" = "Darwin" ]; then
    dependencies+=(pinentry-mac)
  else
    dependencies+=(pinentry)
  fi
  brew install "${dependencies[@]}"
}

install_bun_script() {
  if command -v bun >/dev/null 2>&1; then
    return
  fi

  echo "Installing Bun."
  curl -fsSL https://bun.sh/install | bash
  export PATH="$HOME/.bun/bin:$PATH"
}

install_with_apt() {
  local root_command=(env DEBIAN_FRONTEND=noninteractive)
  local dependencies=(ca-certificates curl git unzip stow pre-commit gh fzf gnupg jq zsh pinentry-curses)

  if [ "$(id -u)" -ne 0 ]; then
    root_command=(sudo "${root_command[@]}")
  fi

  "${root_command[@]}" apt-get update
  "${root_command[@]}" apt-get install --yes "${dependencies[@]}"
  install_bun_script
}

install_with_winget() {
  local winget
  local package_id
  local dependencies=(Git.Git GitHub.cli junegunn.fzf jqlang.jq GnuPG.GnuPG Oven-sh.Bun)

  winget="$(winget_command)"
  for package_id in "${dependencies[@]}"; do
    "$winget" install --exact --id "$package_id" --silent --accept-package-agreements --accept-source-agreements \
      || echo "warning: winget did not install $package_id" >&2
  done

  echo "warning: winget does not provide GNU Stow, Zsh, or pre-commit; install them manually" >&2
}

load_brew
PACKAGE_MANAGER="$(detect_package_manager)"
if [ -z "$PACKAGE_MANAGER" ]; then
  install_brew
  PACKAGE_MANAGER=brew
fi

echo "Installing dependencies with $PACKAGE_MANAGER."
case "$PACKAGE_MANAGER" in
  brew)
    install_with_brew
    ;;
  apt)
    install_with_apt
    ;;
  winget)
    install_with_winget
    ;;
esac

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

if command -v zsh >/dev/null 2>&1; then
  install_oh_my_zsh
  "$REPO_DIR/scripts/oh-my-zsh.sh"
else
  echo "warning: Zsh is not available; Oh My Zsh was not installed" >&2
fi

echo "Dependencies and Zsh plugins installed."
echo "Run ./scripts/stow.sh to link and configure the dotfiles."
