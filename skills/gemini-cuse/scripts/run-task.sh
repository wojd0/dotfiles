#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: run-task.sh --task <text> --success <text> [--timeout-sec <n>] [--model <id>] [--conversation <id>] [--run-root <dir>]" >&2
  exit 2
}

TASK=""
SUCCESS=""
TIMEOUT_SEC=900
MODEL="gemini-3.8-flash-medium"
CONVERSATION=""
RUN_ROOT="${XDG_STATE_HOME:-$HOME/.local/state}/gemini-cuse/runs"

while [ "$#" -gt 0 ]; do
  case "$1" in
    --task) TASK="${2:-}"; shift 2 ;;
    --success) SUCCESS="${2:-}"; shift 2 ;;
    --timeout-sec) TIMEOUT_SEC="${2:-}"; shift 2 ;;
    --model) MODEL="${2:-}"; shift 2 ;;
    --conversation) CONVERSATION="${2:-}"; shift 2 ;;
    --run-root) RUN_ROOT="${2:-}"; shift 2 ;;
    *) usage ;;
  esac
done

if [ -z "$TASK" ] || [ -z "$SUCCESS" ]; then
  usage
fi

case "$(uname -s)" in
  Darwin) OS_NAME="macOS" ;;
  Linux) OS_NAME="Linux" ;;
  *) echo "Unsupported operating system: $(uname -s)" >&2; exit 1 ;;
esac

SKILL_DIR="$(cd "$(dirname "$0")/.." && pwd)"
RUN_DIR="$RUN_ROOT/$(date +%Y%m%d-%H%M%S)-$$"
mkdir -p "$RUN_DIR"
SCREENSHOT="$RUN_DIR/final.png"

replace_all() {
  local text="$1" placeholder="$2" value="$3" result=""
  while [[ "$text" == *"$placeholder"* ]]; do
    result="$result${text%%"$placeholder"*}$value"
    text="${text#*"$placeholder"}"
  done
  printf '%s' "$result$text"
}

brief="$(cat "$SKILL_DIR/references/worker-brief.md")"
brief="$(replace_all "$brief" '{{TASK}}' "$TASK")"
brief="$(replace_all "$brief" '{{SUCCESS}}' "$SUCCESS")"
brief="$(replace_all "$brief" '{{OS}}' "$OS_NAME")"
brief="$(replace_all "$brief" '{{SCREENSHOT}}' "$SCREENSHOT")"
printf '%s\n' "$brief" > "$RUN_DIR/TASK.md"

cp "$SKILL_DIR/references/result-schema.json" "$RUN_DIR/result-schema.json"
cat > "$RUN_DIR/session-settings.json" <<'JSON'
{ "permissions": { "allow": ["mcp(cua-driver/*)"] } }
JSON

agy_args=(
  -p "Read the file TASK.md in the current directory. Do the task that it describes. Nobody else can see or control this computer, so you own the task from start to end."
  --model "$MODEL"
  --output-format json
  --json-schema "$RUN_DIR/result-schema.json"
  --settings "$RUN_DIR/session-settings.json"
  --print-timeout "${TIMEOUT_SEC}s"
)
if [ -n "$CONVERSATION" ]; then
  agy_args+=(--conversation "$CONVERSATION")
fi

code=0
(cd "$RUN_DIR" && agy "${agy_args[@]}" > "$RUN_DIR/output.json" 2> "$RUN_DIR/agy-stderr.log") || code=$?

has_screenshot=false
if [ -f "$SCREENSHOT" ]; then
  has_screenshot=true
fi

cat <<EOF
{
  "run_dir": "$RUN_DIR",
  "exit_code": $code,
  "output_file": "$RUN_DIR/output.json",
  "screenshot": "$SCREENSHOT",
  "has_screenshot": $has_screenshot
}
----- agy output -----
EOF
cat "$RUN_DIR/output.json"
