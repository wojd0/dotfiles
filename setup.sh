#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

export NONINTERACTIVE=1

for brew_bin in /opt/homebrew/bin /home/linuxbrew/.linuxbrew/bin /usr/local/bin; do
  if [ -x "$brew_bin/brew" ]; then
    export PATH="$brew_bin:$PATH"
    break
  fi
done

"$REPO_DIR/scripts/install.sh"
"$REPO_DIR/scripts/stow.sh"

echo "Setup complete. Start a new shell or run: exec zsh"
