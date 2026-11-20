---
name: commit-message-format
description: Repository commit-message format. Use when you create or rewrite a commit message.
---

# Commit message format

Before you create or rewrite a commit message, run this command in the target repository:

```bash
git log -30 --format=%s
```

Match the new subject to the dominant pattern in that output: prefixes, scopes, ticket IDs, capitalization, and punctuation. Prefer recent commits when patterns conflict. Use only formats that the repository history supports.

If no pattern exists in the history, use the one-line Conventional Commits format `<type>(<optional scope>): <imperative subject>` with one of these types:

- `build`: build system or external dependency changes
- `ci`: CI configuration and script changes
- `docs`: documentation-only changes
- `feat`: a new feature
- `fix`: a bug fix
- `perf`: a performance improvement
- `refactor`: a code change that neither fixes a bug nor adds a feature
- `style`: formatting or whitespace changes that do not change meaning
- `test`: new or updated tests

Write a concise one-line imperative subject only. Do not add a commit body or footer.
