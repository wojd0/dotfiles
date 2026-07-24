#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
IMAGE_NAME="${DOTFILES_DOCKER_IMAGE:-dotfiles-test}"

usage() {
  cat <<'EOF'
Usage: ./scripts/docker-test.sh [test|shell]

Builds a clean Linux image for this repository.
  test   Run the dotfiles setup and validation checks (default).
  shell  Run setup, then open an interactive zsh shell in the test container.

Set DOTFILES_DOCKER_IMAGE to use a different image name.
EOF
}

case "${1:-test}" in
  test)
    container_command=()
    ;;
  shell)
    container_command=(zsh -lc './scripts/stow.sh && exec zsh -i')
    ;;
  -h|--help)
    usage
    exit 0
    ;;
  *)
    usage >&2
    exit 1
    ;;
esac

docker build --tag "$IMAGE_NAME" --file "$REPO_DIR/Dockerfile" "$REPO_DIR"

if [ "${#container_command[@]}" -eq 0 ]; then
  docker run --rm "$IMAGE_NAME"
else
  docker run --rm --interactive --tty "$IMAGE_NAME" "${container_command[@]}"
fi
