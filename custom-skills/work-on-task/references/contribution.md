## Commit strategy

First, create a proposal of commit strategy following these contribution principles:

### Commit message format

Analyze your work and changes and generate a commit message. 

### General commit pattern inside the repository
Commit message should follow pattern you can discover by analyzing last 30 lines of the git one-line log of current user's commits:

```bash
git log --all --author="$(git config user.email)" --oneline -30
```

If there are no commits made by the current user, follow the repository's guidelines for initial commit messages or create a commit message based on the changes introduced.

### Committing in smaller chunks
Split changes into commits based on their impact on the codebase, type of changes:
- modifications: commit with self-contained changes, that extend or modify existing code (ex. modification of existing inline values, addition of new entries to arrays and objects, changes to component structure, etc.)
- additions: commit of new files, new code, new stories, new component variants, new types
- refactors: commit with self-contained changes (ex. restructuring a function, splitting one function into multiple, splitting into smaller files, etc.)
- styles: commit with changes impacting component looks (ex. changes to colors, typography, spacing, css tokens, classes, mixins definition changes)
- tests: commit changing, adding or removing tests

Each chunk should be a self-contained change, that could be reviewed and merged separately.
Chunks should be made reasonably, tend to reduce amount of chunks to minimum, comitting all changes in one commit is welcome.

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

## Pushing to remote

Push the branch you committed the changes to to the remote repository using:

```bash
git push
```

## PR proposal

Finish the contribution with a PR proposal. Prepare its metadata as follows:

### Metadata pattern

Research the github workflows and other documentation inside the repository for PR metadata (title, description, branch) rules.

### Title

MUST follow pattern you can discover by analyzing last 20 merged PR titles in the repository. Keep in mind that automatic PRs may not follow general rules, so try and mimic the human-created ones as closely as possible.

```bash
gh pr list --repo OWNER/REPO --state merged --limit 20
```

### Description

Should contain ONLY a link to most related Jira ticket, ex. `https://atlassian.atlassian.net/browse/ABC-123`.

### Result
DO NOT create a PR! Instead - return the PR proposal to the user: a GitHub compare page URL from which they open the PR themselves.

Append following query params to the URL:
- `expand=1` - as is
- `body=<description>` - PR description
- `title=<title>` - PR title

Examples:

- comparing to default branch:
https://github.com/user/repo/compare/feat/my-feat-branch?expand=1&body=https://atlassian.atlassian.net/browse/ABC-123&title=ABC-123:%20Add%20new%20feature
- comparing to a specific branch:
https://github.com/user/repo/compare/my-other-branch...fix/my-fix-branch?expand=1&body=https://atlassian.atlassian.net/browse/ABC-456&title=ABC-456:%20Fix%20bug
