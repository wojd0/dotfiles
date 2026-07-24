#!/usr/bin/env bash
set -euo pipefail

if [[ "$(uname)" != "Darwin" ]]; then
  echo "error: scripts/install.sh currently supports macOS only" >&2
  exit 1
fi

if ! command -v brew >/dev/null 2>&1; then
  echo "Homebrew is required and will now be installed."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

brew install stow bun pre-commit gh

echo "Dependencies installed. Run ./scripts/stow.sh to link and configure the dotfiles."
