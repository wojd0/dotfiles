Once all changes are committed STOP and ask the user if they want to create a PR. Give them 3 options:
- "Push and create a PR"
- "Push and create a draft PR"
- "Push only"

Read other skills and instruction for creating a PR, but DO NOT follow any other rules contradicting with the following guidelines.

Steps to create a PR:

## PR preparation

### PR metadata pattern

Research the github workflows and other documentation inside the repository for PR metadata (title, description, branch) rules.

### Branch checks

Check if the branch name is following the rules for a valid PR branch in this repo. If not, STOP and propose the correct branch name to the user and await their approval.

Push the branch to the remote repository and after that rebase it on the remote default branch to make sure it's up to date.

### PR title

MUST follow pattern you can discover by analyzing last 15 PR titles in the repository. Keep in mind that automatic PRs may not follow general rules.

### PR description

Should contain ONLY a link to most related Jira ticket, ex. `https://atlassian.atlassian.net/browse/ABC-123`.

Create the PR.