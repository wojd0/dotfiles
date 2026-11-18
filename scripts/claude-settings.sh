#!/usr/bin/env bash
set -euo pipefail

SETTINGS_FILE="$HOME/.claude/settings.json"

CLAUDE_ENV='{
  "CLAUDE_CODE_EXPERIMENTAL_CODE_MODE": "1"
}'

CLAUDE_SETTINGS='{
  "disableClaudeAiConnectors": true,
  "enabledPlugins": {
    "browser-use@synced": false,
    "browser-use@inline": false
  }
}'

if ! command -v jq >/dev/null 2>&1; then
  echo "error: jq is required; run ./scripts/install.sh first" >&2
  exit 1
fi

mkdir -p "$(dirname "$SETTINGS_FILE")"

if [ ! -s "$SETTINGS_FILE" ]; then
  echo '{}' > "$SETTINGS_FILE"
fi

tmp_file="$(mktemp)"
trap 'rm -f "$tmp_file"' EXIT

jq --argjson env "$CLAUDE_ENV" --argjson settings "$CLAUDE_SETTINGS" '(. * $settings) | .env = ((.env // {}) + $env)' "$SETTINGS_FILE" > "$tmp_file"
cat "$tmp_file" > "$SETTINGS_FILE"
echo "updated env and MCP settings in $SETTINGS_FILE"
