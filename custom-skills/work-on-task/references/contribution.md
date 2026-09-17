Once all changes are committed push the changes to the remote.

Read other skills and instruction for creating a PR, but DO NOT follow any other rules contradicting with the following guidelines.

## PR metadata preparation

### PR metadata pattern

Research the github workflows and other documentation inside the repository for PR metadata (title, description, branch) rules.

### Branch checks

Check if the branch name is following the rules for a valid PR branch in this repo. If not, STOP and propose the correct branch name to the user and await their approval.

Push the branch to the remote repository and after that rebase it on the remote default branch to make sure it's up to date.

### PR title

MUST follow pattern you can discover by analyzing last 15 PR titles in the repository. Keep in mind that automatic PRs may not follow general rules.

### PR description

Should contain ONLY a link to most related Jira ticket, ex. `https://atlassian.atlassian.net/browse/ABC-123`.

### Result
DO NOT create a PR! Instead - return a GitHub compare page URL for the user.

Append following query params to the URL:
- `expand=1` - as is
- `body=<description>` - PR description (as instructed)
- `title=<title>` - PR title (as instructed)

Examples:

- comparing to default branch:
https://github.com/user/repo/compare/feat/my-feat-branch?expand=1&body=https://atlassian.atlassian.net/browse/ABC-123&title=ABC-123:&20Add%20new%20feature
- comparing to a specific branch:
https://github.com/user/repo/compare/fix/my-fix-branch...my-other-branch?expand=1&body=https://atlassian.atlassian.net/browse/ABC-456&title=ABC-456:%20Fix%20bug