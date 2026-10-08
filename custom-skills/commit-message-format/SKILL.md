---
name: commit-message-format
description: Enables the agent to follow the active repository's commit-message format. Use every time the agent is creating or modifying commit messages.
---

# Commit Message Format

Before creating a commit message, run this in the target repository:

```bash
git log -30 --format=%s
```

Match the new subject to the dominant pattern in that output, including
prefixes, scopes, ticket IDs, capitalization, and punctuation. Prefer recent
entries when patterns conflict; introduce only formats supported by the
repository history.

If no pattern exists, use a concise one-line imperative subject.
