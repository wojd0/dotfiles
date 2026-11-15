# Setup on macOS

Run all commands in a Bash or Zsh shell. Use this full path for CUA Driver: `c="$HOME/.local/bin/cua-driver"`. The installer puts the app in `/Applications/CuaDriver.app` and links the binary to that path.

## 1. Antigravity CLI

1. Run `agy --version`.
2. If the command is not found, install the CLI. The installer puts `agy` in `~/.local/bin`. Then start a new shell.

   ```bash
   curl -fsSL https://antigravity.google/cli/install.sh | bash
   ```

3. Run `agy models`. The list must contain `gemini-3.8-flash-medium`.
4. If `agy models` reports a sign-in error, stop. Ask the user to sign in.

## 2. CUA Driver

1. Run `test -x "$c" && "$c" --version`.
2. If the file is missing, download the installer to a new temporary folder, and then run it with the `--no-connect` flag:

   ```bash
   d="$(mktemp -d)"
   curl -fsSL https://cua.ai/driver/install.sh -o "$d/install.sh"
   /bin/bash "$d/install.sh" --no-connect
   ```

   - `--no-connect` keeps the installer from adding CUA Driver to Claude Code, Codex, and Cursor. It also skips the permission guide, so do step 3.
   - The installer does not add a login item. The MCP server starts its own runtime when `agy` calls it.

3. Give CUA Driver the Accessibility and Screen Recording permissions. These permissions need a person:
   1. Run `"$c" permissions grant`. This command opens a guide window and waits.
   2. Ask the user to turn on the two switches for `CuaDriver` in the guide window.
   3. Wait until the command exits without an error.
4. Run `"$c" doctor`. All checks must pass. If a check fails, stop and give the user the failed line. If the agent runs over SSH, tell the user to run the agent from the desktop session.
5. Take a test screenshot. Make sure that the file exists:

   ```bash
   o="${TMPDIR:-/tmp}/cua-setup-check.png"
   printf '{"screenshot_out_file":"%s"}' "$o" | "$c" call get_desktop_state
   test -s "$o" && echo ok
   ```

   If the screenshot is missing or black, the Screen Recording permission is off. Do step 3 again.

## 3. MCP server in agy

1. Run `agy mcp list`.
2. If `cua-driver` is missing, add it:

   ```bash
   agy mcp add cua-driver "$c" mcp
   ```

3. If `cua-driver` shows `disabled`, run `agy mcp enable cua-driver`.
4. Make sure that `~/.gemini/antigravity-cli/skills/cua-driver` exists. This skill pack teaches the worker the CUA Driver tools. If it is missing, run `"$c" mcp-config --client antigravity`.

## 4. Smoke test

1. Run the `gemini-cuse` worker script:

   ```bash
   bash "$HOME/.agents/skills/gemini-cuse/scripts/run-task.sh" --task "Open the macOS Calculator app. Use it to calculate 2+2: enter 2, +, 2, and = in the app. Leave the Calculator window open." --success "The Calculator display shows the result of 2+2, and result gives the exact number on the display." --timeout-sec 600
   ```

2. Make sure that `structured_output.status` is `success` and `structured_output.result` is `4`.
3. Open `<run_dir>/final.png` with your image-read tool. The Calculator display must show `4`.
4. Close Calculator with `osascript -e 'quit app "Calculator"'`.
