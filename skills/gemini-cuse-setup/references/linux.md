# Setup on Linux

Run all commands in a Bash shell. Use this full path for CUA Driver: `c="$HOME/.local/bin/cua-driver"`. The installer links this path to the current release in `~/.cua-driver/packages/current`.

## 1. Antigravity CLI

1. Run `agy --version`.
2. If the command is not found, install the CLI. The installer puts `agy` in `~/.local/bin`. Then start a new shell.

   ```bash
   curl -fsSL https://antigravity.google/cli/install.sh | bash
   ```

3. Run `agy models`. The list must contain `gemini-3.8-flash-medium`.
4. If `agy models` reports a sign-in error, stop. Ask the user to sign in.

## 2. CUA Driver

1. Make sure that the shell runs in a graphical desktop session. Run `echo "${XDG_SESSION_TYPE:-} ${DISPLAY:-} ${WAYLAND_DISPLAY:-}"`. If `DISPLAY` and `WAYLAND_DISPLAY` are both empty, stop. Tell the user to run the agent from the desktop session, not over SSH or as a service.
2. Run `test -x "$c" && "$c" --version`.
3. If the file is missing, download the installer to a new temporary folder, and then run it with the `--no-connect` flag:

   ```bash
   d="$(mktemp -d)"
   curl -fsSL https://cua.ai/driver/install.sh -o "$d/install.sh"
   bash "$d/install.sh" --no-connect
   ```

   - `--no-connect` keeps the installer from adding CUA Driver to Claude Code, Codex, and Cursor.
   - The installer does not add a systemd user unit. The MCP server starts its own runtime when `agy` calls it.

4. Run `"$c" doctor`. All checks must pass. If a check fails, stop and give the user the failed line.

   Ignore the messages about Accessibility and Screen Recording. Those are macOS permissions, and `cua-driver permissions` applies to macOS only.

5. Take a test screenshot. Make sure that the file exists:

   ```bash
   o="${TMPDIR:-/tmp}/cua-setup-check.png"
   printf '{"screenshot_out_file":"%s"}' "$o" | "$c" call get_desktop_state
   test -s "$o" && echo ok
   ```

   If the desktop is KDE Plasma on Wayland and the screenshot fails, run `"$c" kwin-capture status`. If the status is off, run `"$c" kwin-capture on`, and then take the screenshot again.

## 3. MCP server in agy

1. Run `agy mcp list`.
2. If `cua-driver` is missing, add it:

   ```bash
   agy mcp add cua-driver "$c" mcp
   ```

3. If `cua-driver` shows `disabled`, run `agy mcp enable cua-driver`.
4. Make sure that `~/.gemini/antigravity-cli/skills/cua-driver` exists. This skill pack teaches the worker the CUA Driver tools. If it is missing, run `"$c" mcp-config --client antigravity`.

## 4. Smoke test

1. Find the calculator app. Run `command -v gnome-calculator kcalc galculator`, and use the first app that the command finds. If no app is found, stop. Ask the user to install a calculator app.
2. Run the `gemini-cuse` worker script. Put the name of the calculator app in `<app>`:

   ```bash
   bash "$HOME/.agents/skills/gemini-cuse/scripts/run-task.sh" --task "Open the <app> calculator app. Use it to calculate 2+2: enter 2, +, 2, and = in the app. Leave the calculator window open." --success "The calculator display shows the result of 2+2, and result gives the exact number on the display." --timeout-sec 600
   ```

3. Make sure that `structured_output.status` is `success` and `structured_output.result` is `4`.
4. Open `<run_dir>/final.png` with your image-read tool. The calculator display must show `4`.
5. Close the calculator with `pkill -x <app>`.
