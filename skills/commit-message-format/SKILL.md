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

If no pattern exists, follow the conventional commit rules:
Each commit message consists of a header, a body and a footer. The header has a special format that includes a type, a scope and a subject:
build: Changes that affect the build system or external dependencies (example scopes: gulp, broccoli, npm)
ci: Changes to our CI configuration files and scripts (example scopes: Travis, Circle, BrowserStack, SauceLabs)
docs: Documentation only changes
feat: A new feature
fix: A bug fix
perf: A code change that improves performance
refactor: A code change that neither fixes a bug nor adds a feature
style: Changes that do not affect the meaning of the code (white-space, formatting, missing semi-colons, etc)
test: Adding missing tests or correcting existing tests

Use a concise one-line imperative subject. Write a one-line subject only. Do not add a body.
