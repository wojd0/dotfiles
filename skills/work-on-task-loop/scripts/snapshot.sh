#!/usr/bin/env bash
set -euo pipefail

STATE_DIR="${1:?usage: snapshot.sh <state-dir>}"
INDEX_FILE="$STATE_DIR/snapshot.index"
REAL_INDEX="$(git rev-parse --path-format=absolute --git-path index)"

mkdir -p "$STATE_DIR"
rm -f "$INDEX_FILE"
if [ -f "$REAL_INDEX" ]; then
  cp "$REAL_INDEX" "$INDEX_FILE"
else
  GIT_INDEX_FILE="$INDEX_FILE" git read-tree HEAD
fi
GIT_INDEX_FILE="$INDEX_FILE" git add -A
GIT_INDEX_FILE="$INDEX_FILE" git write-tree
rm -f "$INDEX_FILE"
