#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

export NONINTERACTIVE=1

if [ "$(uname -m)" = "arm64" ]; then
  export PATH="/opt/homebrew/bin:$PATH"
else
  export PATH="/usr/local/bin:$PATH"
fi

"$REPO_DIR/scripts/install.sh"
"$REPO_DIR/scripts/stow.sh"
