---
name: commit-message-format
description: Detects and follows the active repository's commit-message format. Use every time the agent is asked to commit, amend, write or edit a commit message, or perform another action that creates or rewrites commits, including merge, revert, cherry-pick, squash, and rebase.
---

# Commit Message Format

Before any covered action, run this in the target repository:

```bash
git log -30 --format=%s
```

Match the new subject to the dominant pattern in that output, including
prefixes, scopes, ticket IDs, capitalization, and punctuation. Prefer recent
entries when patterns conflict; introduce only formats supported by the
repository history.

If no pattern exists, use a concise one-line imperative subject.
