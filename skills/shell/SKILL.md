---
name: shell
description: Runs the text after /shell as a literal shell command.
disable-model-invocation: true
---
# Run shell commands

## Behavior

1. Run the exact user text after `/shell` as a terminal command immediately, without prior repository checks or edits to the command.
2. If no text follows `/shell`, ask the user which command to run.

## Response

- Report the exit status and any important stdout or stderr.
