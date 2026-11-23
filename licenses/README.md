# Third-party licenses

This directory holds the license of each third-party source that the repository contains now or contained in its commit history. Each license file is a copy of the upstream license text.

## Current content

| Repository path | Upstream | License | Copyright | License file |
|---|---|---|---|---|
| `skills/coding-principles/` | [unclebob/ub-mode](https://github.com/unclebob/ub-mode) `SKILL.md` at `3da62bf` | MIT | Copyright (c) 2026 Robert C. Martin | [unclebob-ub-mode.txt](unclebob-ub-mode.txt) |
| `.agents/skills/grill-me/`, `.agents/skills/improve-codebase-architecture/`, `.agents/skills/resolving-merge-conflicts/`, `.agents/skills/to-spec/`, `.agents/skills/wait-what/`, `.agents/skills/writing-for-agents/` | [mattpocock/skills](https://github.com/mattpocock/skills) `skills/` | MIT | Copyright (c) 2026 Matt Pocock | [mattpocock-skills.txt](mattpocock-skills.txt) |
| `.agents/skills/find-skills/` | [vercel-labs/skills](https://github.com/vercel-labs/skills) `skills/find-skills/` | MIT | Copyright (c) 2026 Vercel, Inc. | [vercel-labs-skills.txt](vercel-labs-skills.txt) |
| `.agents/skills/refactoring/` | [ciembor/agent-rules-books](https://github.com/ciembor/agent-rules-books) `refactoring/` | MIT | Copyright (c) 2026 Maciej Ciemborowicz | [ciembor-agent-rules-books.txt](ciembor-agent-rules-books.txt) |
| `shell/.zshrc` (parts) | [ohmyzsh/ohmyzsh](https://github.com/ohmyzsh/ohmyzsh) `templates/zshrc.zsh-template` | MIT | Copyright (c) 2009-2026 Robby Russell and contributors | [ohmyzsh-ohmyzsh.txt](ohmyzsh-ohmyzsh.txt) |

`skills/coding-principles/` is a changed copy of the upstream skill. The `name`, the description, and the top heading are different. The other text is the same as the upstream text.

`skills-lock.json` records the upstream path of each skill in `.agents/skills/`.

## Content in the commit history only

| Former repository path | Upstream | License | License file |
|---|---|---|---|
| `.agents/skills/` skills `teach`, `tdd`, `grilling`, `implement`, `diagnosing-bugs`, `wayfinder`, `wizard` | [mattpocock/skills](https://github.com/mattpocock/skills) | MIT | [mattpocock-skills.txt](mattpocock-skills.txt) |
| `custom-skills/pdf/` | [openai/skills](https://github.com/openai/skills) `skills/.curated/pdf/` | Apache-2.0 | [openai-skills-pdf.txt](openai-skills-pdf.txt) |
| `custom-skills/create-rule/`, `custom-skills/create-skill/`, `custom-skills/update-cursor-settings/` | Cursor built-in skills | No public license | None |

The Cursor skills have no public license. The current files do not contain them.

## Content that needs no notice

- Git does not track the skills in `.gitignore`, for example `angular-developer`, `monitor-ci`, and `synced`.
- Setup downloads the Oh My Zsh plugins and the Oh My Zsh installation. The repository holds no copy of them.
