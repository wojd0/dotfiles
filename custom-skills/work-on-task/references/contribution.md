## Commit strategy

### Commit message format

DO NOT commit yet, but create a proposal of commit strategy.

Analyze your work and changes and generate a commit message. Commit message should follow pattern you can discover by analyzing last 30 lines of the git one-line log.

### Committing in smaller chunks
If there are more that 100 lines of changes, STOP and ask the user if they want to commit the changes in smaller chunks.

Split changes into commits based on their impact on the codebase, type of changes:
- modifications: commit with self-contained changes, that extend or modify existing code (ex. modification of existing inline values, addition of new entries to arrays and objects, changes to component structure, etc.)
- additions: commit of new files, new code, new stories, new component variants, new types
- refactors: commit with self-contained changes (ex. restructuring a function, splitting one function into multiple, splitting into smaller files, etc.)
- styles: commit with changes impacting component looks (ex. changes to colors, typography, spacing, css tokens, classes, mixins definition changes)
- tests: commit changing, adding or removing tests

*Each chunk should be a self-contained change, that could be reviewed and merged separately.*

### Example commit message proposal

Commit message: `feat: ABC-123 Add new feature` <br>
Commit contents: Adding new feature to the codebase. New file `src/features/abc-123/abc-123.component.ts` with new component `Abc123Component`. Added new story `Abc123Component.stories.ts` for the component. Added new test `Abc123Component.spec.ts` for the component.

### Example multiple commit message proposal

Commit message: `feat: ABC-123 Add new feature` <br>
Commit contents: Adding new feature to the codebase. New file `src/features/abc-123/abc-123.component.ts` with new component `Abc123Component`. Added new story `Abc123Component.stories.ts` for the component. Added new test `Abc123Component.spec.ts` for the component.

Commit message: `feat: ABC-123 Add new feature` <br>
Commit contents: Adding new feature to the codebase. New file `src/features/abc-123/abc-123.component.ts` with new component `Abc123Component`. Added new story `Abc123Component.stories.ts` for the component. Added new test `Abc123Component.spec.ts` for the component.

Following this schema, propose the commit(s) message(s) to the user, STOP and ask if they want to commit.

## GitHub contribution

Once all changes are committed push the changes to the remote.

Read other skills and instruction for creating a PR, but DO NOT follow any other rules contradicting with the following guidelines.

## PR metadata preparation

### Mmetadata pattern

Research the github workflows and other documentation inside the repository for PR metadata (title, description, branch) rules.

### Branch checks

Check if the branch name is following the rules for a valid PR branch in this repo. If not, STOP and propose the correct branch name to the user and await their approval.

Push the branch to the remote repository and after that rebase it on the remote default branch to make sure it's up to date.

### Title

MUST follow pattern you can discover by analyzing last 15 PR titles in the repository. Keep in mind that automatic PRs may not follow general rules.

### Description

Should contain ONLY a link to most related Jira ticket, ex. `https://atlassian.atlassian.net/browse/ABC-123`.

### Result
DO NOT create a PR! Instead - return a GitHub compare page URL for the user.

Append following query params to the URL:
- `expand=1` - as is
- `body=<description>` - PR description
- `title=<title>` - PR title

Examples:

- comparing to default branch:
https://github.com/user/repo/compare/feat/my-feat-branch?expand=1&body=https://atlassian.atlassian.net/browse/ABC-123&title=ABC-123:&20Add%20new%20feature
- comparing to a specific branch:
https://github.com/user/repo/compare/fix/my-fix-branch...my-other-branch?expand=1&body=https://atlassian.atlassian.net/browse/ABC-456&title=ABC-456:%20Fix%20bug
