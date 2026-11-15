---
name: gemini-cuse-setup
description: Install and verify the stack for the `gemini-cuse` skill on Windows, macOS, or Linux (Antigravity CLI `agy`, CUA Driver, and the `cua-driver` MCP server in `agy`), then run a Calculator 2+2 smoke test.
disable-model-invocation: true
---

# Gemini computer use setup

Do the steps in sequence. Each step starts with a check. If the check passes, go to the next step. The setup is complete when all checks in the final report pass.

## 1. Find the operating system

Find the operating system of the computer. Then read the reference file for that system and do its steps:

| Operating system | Reference file |
|---|---|
| Windows | [`references/windows.md`](references/windows.md) |
| macOS | [`references/macos.md`](references/macos.md) |
| Linux | [`references/linux.md`](references/linux.md) |

If `uname -s` gives `Darwin`, the system is macOS. If it gives `Linux`, the system is Linux. If PowerShell runs and `$env:OS` is `Windows_NT`, the system is Windows.

Each reference file has the same four steps: Antigravity CLI, CUA Driver, MCP server in `agy`, and smoke test.

## 2. General rules

- Never type credentials for the user. If `agy` reports a sign-in error, stop. Ask the user to run `agy` in a terminal and sign in with Google.
- Use the full path for CUA Driver in all commands. A shell that started before the install does not have it on PATH.
- Install CUA Driver without its connect step. Only `agy` needs CUA Driver, so do not add it to Claude Code, Codex, or Cursor.
- Link the CUA Driver skill pack into `agy` only, with `cua-driver mcp-config --client antigravity`. Do not use `cua-driver skills install`, because it links the pack into all agents that it finds.
- If the smoke test fails, read `<run_dir>/agy-stderr.log` and `<run_dir>/output.json`. Fix the cause, then run the test again.

## 3. Report

Give the user a table with one row for each check, and its result:

- Operating system
- `agy` version and sign-in
- `gemini-3.8-flash-medium` in the model list
- CUA Driver version and `doctor` result
- Operating-system permissions or display session, from the reference file
- Test screenshot
- `cua-driver` MCP server enabled in `agy`
- Calculator smoke test: worker result, screenshot result, duration, and `run_dir`
