@~/.claude/RTK.md

# Writing

Write all prose in ASD-STE100 Simplified Technical English: docs, skills, Markdown files of any kind, reports, and any other in-file or in-chat prose.

# Glossary

- **Commit message**: a one-line subject matching the dominant pattern of the target repository's recent history (prefix, scope, ticket ID, capitalization, punctuation), or a concise imperative subject when the history shows no pattern. The `commit-message-format` skill holds the procedure.
- **PR proposal** (pull request proposal): a GitHub compare-page URL prefilled with the PR title and description, handed to the user so they open the pull request themselves; it stands in for creating the PR. The title follows the repository's recent human-written merged PR titles and the description is only the link to the related Jira ticket. `~/.agents/skills/work-on-task/references/contribution.md` holds the procedure. Examples:
  - Compared to the default branch: `https://github.com/user/repo/compare/feat/my-feat-branch?expand=1&body=https://atlassian.atlassian.net/browse/ABC-123&title=ABC-123:%20Add%20new%20feature`
  - Compared to a specific branch: `https://github.com/user/repo/compare/my-other-branch...fix/my-fix-branch?expand=1&body=https://atlassian.atlassian.net/browse/ABC-456&title=ABC-456:%20Fix%20bug`
