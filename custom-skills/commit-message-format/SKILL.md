---
name: commit-message-format
description: Enables the agent to follow the active repository's commit-message format. Use every time the agent creates or rewrites a commit message, including commit, amend, merge, revert, cherry-pick, squash, and rebase.
---

# Commit Message Format

Before you create a commit message, run this in the target repository:

```bash
git log -30 --format=%s
```

Match the new subject to the dominant pattern in that output, including
prefixes, scopes, ticket IDs, capitalization, and punctuation. Prefer recent
entries when patterns conflict. Use only formats that the repository history
supports.

If no pattern exists, use a concise one-line imperative subject.

Write a one-line subject only. Do not add a body.
