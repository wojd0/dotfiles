@~/.claude/RTK.md

# Writing

Write all prose in ASD-STE100 Simplified Technical English: docs, skills, Markdown files of any kind, reports, and any other in-file or in-chat prose.

# Skills

Write each skill so that all agents can use it. Write general instructions that do not name an agent, a tool, a setting, or a file of one agent. Put the shared skill files in `~/.agents/skills` and `.agents/skills`.

# Agent attribution rules

Branches, commits, tickets, filenames, GitHub comments, descriptions and any other artifacts and results of your should be named, authored or have any creator-related information pointing to the user as the creator. Do not use AI agent name, attribution, mention, tag, link or trademark anywhere.

# Codebase sync

Before you start work in a Git repository, run `git fetch --prune origin`. If the working tree is clean, run `git pull --ff-only`. A repository with no remote or upstream needs no sync. If the fetch or the pull fails, keep the local state and tell the user.

# Glossary

- **Commit message**: a one-line subject. The `commit-message-format` skill holds the format and the procedure.
- **PR proposal** (pull request proposal): a GitHub compare-page URL prefilled with the PR title and description (`expand=1`, `title`, and `body` with only the related Jira ticket link), handed to the user so they open the pull request themselves. `~/.agents/skills/work-on-task/references/contribution.md` holds the procedure and examples.
