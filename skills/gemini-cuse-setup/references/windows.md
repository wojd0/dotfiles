# Setup on Windows

Run all commands in PowerShell. Use this full path for CUA Driver: `$c = "$env:LOCALAPPDATA\Programs\Cua\cua-driver\bin\cua-driver.exe"`.

## 1. Antigravity CLI

1. Run `agy --version`.
2. If the command is not found, install the CLI. Then start a new shell.

   ```powershell
   irm https://antigravity.google/cli/install.ps1 | iex
   ```

3. Run `agy models`. The list must contain `gemini-3.8-flash-medium`.
4. If `agy models` reports a sign-in error, stop. Ask the user to sign in.

## 2. CUA Driver

1. Run `Test-Path $c`.
2. If the file is missing, download the installer to a new temporary folder, and then run it with two switches:

   ```powershell
   $d = Join-Path $env:TEMP "cua-install-$(Get-Random)"; New-Item -ItemType Directory $d | Out-Null
   Invoke-WebRequest https://cua.ai/driver/install.ps1 -OutFile "$d\install.ps1" -UseBasicParsing
   powershell -NoProfile -ExecutionPolicy Bypass -File "$d\install.ps1" -NoConnect -NoAutoStart
   ```

   - `-NoConnect` keeps the installer from adding CUA Driver to Claude Code, Codex, and Cursor.
   - `-NoAutoStart` skips the logon task, which needs a UAC prompt. The MCP server starts its own runtime when `agy` calls it.

3. Run `& $c doctor`. The line `interactive session` must show `[ok  ]`. If it fails, stop. Tell the user to run the agent from the desktop session, not over SSH or as a service.

   Ignore the installer and `cua-driver test` messages about Accessibility and Screen Recording. Those are macOS permissions, and `cua-driver permissions` applies to macOS only.

4. Take a test screenshot. Make sure that the file exists:

   ```powershell
   $o = "$env:TEMP\cua-setup-check.png"
   '{"screenshot_out_file":"' + ($o -replace '\\','\\') + '"}' | & $c call get_desktop_state
   Test-Path $o
   ```

## 3. MCP server in agy

1. Run `agy mcp list`.
2. If `cua-driver` is missing, add it:

   ```powershell
   agy mcp add cua-driver "$($c -replace '\\','/')" mcp
   ```

3. If `cua-driver` shows `disabled`, run `agy mcp enable cua-driver`.
4. Make sure that `%USERPROFILE%\.gemini\antigravity-cli\skills\cua-driver` exists. This skill pack teaches the worker the CUA Driver tools. If it is missing, run `& $c mcp-config --client antigravity`.

## 4. Smoke test

1. Run the `gemini-cuse` worker script:

   ```powershell
   powershell -NoProfile -ExecutionPolicy Bypass -File "$env:USERPROFILE\.agents\skills\gemini-cuse\scripts\run-task.ps1" -Task "Open the Windows Calculator app. Use it to calculate 2+2: enter 2, +, 2, and = in the app. Leave the Calculator window open." -Success "The Calculator display shows the result of 2+2, and result gives the exact number on the display." -TimeoutSec 600
   ```

2. Make sure that `structured_output.status` is `success` and `structured_output.result` is `4`.
3. Open `<run_dir>\final.png` with your image-read tool. The Calculator display must show `4`.
4. Close Calculator with `Stop-Process -Name CalculatorApp`.
