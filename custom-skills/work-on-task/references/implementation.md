# Implement a Plan Jira Ticket
This skills allows you to implement a plan for a Jira ticket following a given plan.

## Prerequisites

STOP keyword in this skills is a mark for the human entry, you need to stop, provide instructed information to the user and wait for their input.

Prerequisites checklist (check if those were already checked in previous phases):
- Check if you have access to the Atlassian MCP by running any simple tool provided by it
- Check if you have access to the GitHub origin the repository you're working on by fetching
- Verify that the current git branch is clean. If not - STOP and ask the user to clean the branch or give guidelines on how to proceed.

## STEP 1: Create a branch

**SWITCH TO AGENT MODE** (you have to switch to agent mode, if declined or automatic switch fails - STOP and ask the user to switch to agent mode)

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

Follow the plan step by step. Key conventions for this codebase:


## STEP 3: Run tests

After implementation, run the affected project's unit tests, lint checks and build.

Analyze GitHub workflow definitions, look for CI checks pipeline and determine what to run.

## STEP 4: Commit

### Commit message format

Do not commit yet, but create a proposal of commit strategy. 

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

## STEP 5: Contribution

Once all changes are committed follow the instructions in [contribution.md](contribution.md).