# Implement a Plan Jira Ticket
This skills allows you to implement a plan for a Jira ticket following a given plan.

## Prerequisites

STOP keyword in this skills is a mark for the human entry, you need to stop, provide instructed information to the user and wait for their input.

Prerequisites checklist (check if those were already checked in previous phases):
- Check if you have access to the Atlassian MCP by running any simple tool provided by it
- Check if you have access to the GitHub origin the repository you're working on by fetching
- Verify that the current git branch is clean. If not - STOP and ask the user to clean the branch or give guidelines on how to proceed.

**SWITCH TO AGENT MODE** (you have to switch to agent mode, if declined or automatic switch fails - STOP and ask the user to switch to agent mode)

## STEP 1: Create a branch

Before naming or creating a branch, read this repository's branch naming conventions and follow them exactly. Search the repo for relevant docs or enforcement (e.g. `.github/instructions/`, `.cursor/rules/`, husky hooks, `CONTRIBUTING*`). Do not assume conventions from other repos.

Use the Jira ticket key and a short kebab-case description derived from the ticket summary.

Example tickets and branch names:

1.
  - ticket summary: DS-2204 Move default url to satori-preview
  - branch name: `feat/DS-2204-move-default-url-to-satori-preview`
2.
  - ticket summary: DS-2113 ⚙️ Fix nested scrollviews storybook example
  - branch name: `fix/DS-2113-fix-nested-scrollviews-storybook-example`

The prefix (`feat/`, `fix/`, etc.) must match the repo's valid types and pattern.

Discover the default base branch from the repo. First discover the remote name (it may be `origin`, `o`, etc.):

```bash
REMOTE=$(git remote | head -1)
BASE=$(git symbolic-ref "refs/remotes/$REMOTE/HEAD" 2>/dev/null | sed 's|.*/||' || echo main)
git fetch "$REMOTE" "$BASE"
git checkout -b <branch-name> "$REMOTE/$BASE"
git push -u "$REMOTE" HEAD
```

The `push -u` immediately sets the upstream to the matching remote branch, avoiding a mismatch where the branch tracks the base branch instead of the feature branch.

## STEP 2: Implement

Follow the implementation plan step by step.

## STEP 3: Run tests

After implementation, run the affected project's unit tests, lint checks and build.

Analyze GitHub workflow definitions, look for CI checks pipeline and determine what to run.

## STEP 4: Contribute

ONLY once all checks and verifications are done - read and follow the instructions in [contribution.md](contribution.md).