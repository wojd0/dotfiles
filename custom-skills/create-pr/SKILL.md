---
name: create-pr
description: Creates a GitHub pull request with the standard team template using gh CLI. When pre-commit, pre-push, or other hooks block commits or pushes, follows an explicit user-approved unblock loop before continuing. Use when: the user says "create pr", "open pr", "make pr", "push and create pr", "submit for review", "ready for review", "ship it", "ship the changes", "push changes"; the user says "I'm done" after implementing something; the user asks to push and open a PR; the user mentions wanting to submit their work or get it reviewed; or the implementation is complete and the user wants to proceed to code review.
---

# Create Pull Request

## Unblock loop (pre-commit, pre-push, and similar)

Whenever a **gate blocks** continuing the workflow (for example pre-commit, `lint-staged`, commit-msg, pre-push, formatters, linters, typecheck scripts invoked by hooks, or a failed `git commit` / `git push` because of hook exit codes), the agent **must not** apply repo changes silently to get past the hook.

1. **Tell the user clearly** that **changes are required** before the create-PR flow can continue, and name the blocker in plain language (which hook or command failed and the high-level reason if known from the log).

2. **Give a rundown of changes the agent intends to make** to unblock — be specific enough to review: affected paths or scopes, category of fix (for example format with Prettier, ESLint autofix, import order, test expectation alignment), and whether that implies new commits or amended files. If the next step is only re-running a command with no file edits, say that explicitly.

3. **Wait for explicit user agreement** before editing files or re-running destructive git operations. If the user declines or wants a different approach, follow their direction instead of assuming.

4. **After agreement**, apply the agreed changes and retry the blocked step (commit, push, etc.).

5. **If the gate still fails**, stop and treat it as a new blocker: summarize the new error, give an **updated** rundown (do not reuse the old one as if nothing changed), ask for agreement again. **Repeat** this inform → rundown → agree → retry cycle until the workflow is unblocked or the user stops the process.

6. **Escalation**: if the same failure repeats with no new actionable information, say so and ask the user how they want to proceed (for example skip a hook locally only when they explicitly request it and team policy allows — never bypass hooks by default).

This unblock loop applies anywhere in the workflow below where hooks or validation would run, including before push and after local commits.

## Workflow

1. **Gather context** — run in parallel:
   - `git status` — check for uncommitted changes
   - `git remote | head -1` — discover remote name
   - `git rev-parse --abbrev-ref HEAD` — get current branch name (for ticket ID and base branch detection)

   Then ALWAYS refresh the base branch before diffing (prevents stale `<remote>/develop` from polluting the diff with files the branch never touched):
   - `git fetch <remote> develop`
   - Compute the true merge base: `MERGE_BASE=$(git merge-base <remote>/develop HEAD)`
   - `git log $MERGE_BASE..HEAD --oneline` — all commits in the PR
   - `git diff $MERGE_BASE..HEAD --stat` — changed files summary

   Use `$MERGE_BASE..HEAD` (not `<remote>/develop..HEAD`) for every subsequent diff/log in this workflow. If the commit list or diff contains files that don't look related to the ticket, double-check by running `git log $MERGE_BASE..HEAD -- <path>` to confirm the branch actually touches them; if it returns no commits, those files are not part of the PR.

2. **Ensure correct branch name**:
   - Branch names must match the regex from `.husky/pre-push`: `^(revert-[0-9]+-)?(improvement|fix|feature|test|tmp|dependabot)/<TICKET_KEY>-[0-9]+[_-][A-Za-z0-9._-]+$`
   - Valid JIRA keys: `HXCS`, `AAE`, `HXIDP`, `RPAHXP`, `CICGOV`, `CSX`
   - Choose prefix based on change type: `fix/` for bugfixes, `feature/` for new features, `improvement/` for refactors/enhancements, `test/` for test-only changes
   - Example: `fix/AAE-43710-dropdown-widget-alignment`
   - If on `develop` or wrong branch name, create/rename to a valid branch before pushing

3. **Rebase onto the freshest base branch** (MANDATORY before pushing):
   - Abort if the working tree is dirty (`git status` from step 1 must be clean). If there are uncommitted changes, stop and ask the user to commit or stash first — never stash or discard on the user's behalf. If the user asks the agent to create the commit and **hooks fail on commit**, follow **Unblock loop** before retrying.
   - Decide the base branch first (see step 4 rules: `develop` by default, or the parent feature branch for stacked PRs).
   - Ensure it's up to date: `git fetch <remote> <base_branch>`.
   - Rebase: `git rebase <remote>/<base_branch>`.
   - If the rebase has conflicts, stop immediately, run `git rebase --abort`, and ask the user to resolve — do NOT attempt to resolve conflicts automatically.
   - After a successful rebase, recompute `MERGE_BASE=$(git merge-base <remote>/<base_branch> HEAD)` and redo the log/diff/stat from step 1 so the PR metadata reflects the rebased state.

4. **Determine base branch**:
   - Default: `develop`
   - If the branch was created from another feature branch (visible in git log or branch tracking), use that as the base instead (stacked PRs). This is the same `<base_branch>` used in step 3.

5. **Push branch**:
   ```bash
   REMOTE=$(git remote | head -1)
   git push -u "$REMOTE" HEAD
   ```
   - If the branch already existed on the remote, the rebase will have rewritten history and a normal push will be rejected. In that case run `git push -u --force-with-lease "$REMOTE" HEAD` (never `--force`). If `--force-with-lease` is rejected, stop and ask the user — do not escalate to `--force`.
   - If push fails because of **pre-push or other hooks**, follow **Unblock loop** above before retrying; do not disable hooks unless the user explicitly asks and policy allows.

6. **Check if tests were actually added or modified**:
   - Run `git diff $MERGE_BASE..HEAD` (the merge base from step 1, NOT `<remote>/develop..HEAD`) and inspect the full diff content across all changed files.
   - Look for additions or modifications of test-related code: `it(`, `describe(`, `expect(`, `beforeEach(`, `afterEach(`, `test(`, `cy.`, etc.
   - Sanity-check suspicious test file changes with `git log $MERGE_BASE..HEAD -- <test-file>` — if no commits are returned, the change isn't part of this PR and must not be claimed in the Testing section.
   - Distinguish unit tests (`*.spec.ts`) from e2es (`*.e2e.ts`, `cy.*`) and mention only the kinds actually touched (e.g. `unit tests updated/added`, `e2es updated/added`, or `unit tests/e2es updated/added`).
   - Only use the appropriate phrase in the Testing section if the diff contains such changes. Do not run tests, do not claim they pass.

7. **Determine PR metadata** from the commits and changes:
   - **Title**: `AAE-XXXXX Description` — space separator, NO colon. Extract ticket ID(s) from branch name. Sentence case, start with an action verb (Fix, Add, Refactor, Update, Move, Remove, Replace, Migrate, Introduce, Handle, etc.). For multiple tickets: `AAE-XXXXX AAE-YYYYY Description`.
   - **Change type**: one of Bugfix, New feature, UI/UX, Tests only, Documentation, Build, Refactoring
   - **Additional context**: leave empty unless there is a truly important related ticket or prerequisite to reference (e.g. `AAE-42899.`)
   - **Testing section**: always fill — see filling rules below
   - **Feature flags**: check if any feature flag usage was added or modified
   - **Visual changes**: check if `.html`, `.scss`, or template files were modified

8. **Build PR body from repo template**:
   - Read the PR template from `.github/PULL_REQUEST_TEMPLATE.md` in the repo root.
   - Fill in the template sections according to the filling rules below, replacing HTML comment placeholders with actual content.

9. **Create PR**:
   ```bash
   gh pr create --base <base_branch> --title "<title>" --body "$(cat <<'EOF'
   <filled template>
   EOF
   )"
   ```

10. **Transition linked Jira ticket to Review**:
   - Extract the ticket key(s) from the branch name (e.g. `AAE-12345`).
   - For each ticket, use the Atlassian MCP tools with `cloudId: "hyland.atlassian.net"`:
     1. Call `getJiraIssue` with `issueIdOrKey` and `fields: ["status"]` to get the current status.
     2. If the status name is **"In Progress"** (case-insensitive match):
        - Call `getTransitionsForJiraIssue` to list available transitions.
        - Find the transition whose `name` matches **"Review"** (case-insensitive).
        - Call `transitionJiraIssue` with that transition `id` to move the ticket to Review.
        - Confirm the transition in the final output message.
     3. If the status is not "In Progress", skip the transition and mention the current status so the user is aware.

11. Return the PR URL (and mention the Jira transition result).

## Filling rules

| Section | Rule |
|---------|------|
| Title format | `AAE-XXXXX Description` — space separator, **no colon**. Sentence case. Start with action verb. Multiple tickets: `AAE-XXXXX AAE-YYYYY Description`. |
| JIRA link | Extract from branch name. Format: `https://hyland.atlassian.net/browse/AAE-XXXXX`. Multiple tickets on separate lines. Replace the HTML comment placeholder with the actual link(s). |
| Additional context | **Leave empty** in most cases. Only fill to reference a closely related/prerequisite ticket (e.g. `AAE-42899.`). Remove the HTML comment placeholder if leaving empty. |
| Change type | Check exactly one based on the nature of the commits. |
| Testing — tests added/updated | Compute against the true merge base (`$MERGE_BASE..HEAD`) after `git fetch <remote> develop`, not against a possibly-stale `<remote>/develop`. If the diff contains additions/modifications of test-related code (`it(`, `describe(`, `expect(`, `beforeEach(`, `test(`, `cy.`, etc.), replace the HTML comment placeholder with the kinds actually touched: `unit tests updated/added` (only `*.spec.ts`), `e2es updated/added` (only `*.e2e.ts`/Cypress), or `unit tests/e2es updated/added` (both). Verify each test file with `git log $MERGE_BASE..HEAD -- <file>` before claiming it. |
| Testing — no tests added | Replace the HTML comment placeholder with a brief explanation. Examples: `style changes only`, `styling changes`, `package and style changes only`, `ci change only`, `refactor`, `repo config related change` |
| Feature flags | Check "Yes" only if code imports/uses `FeatureFlagService`, feature flag enums, or `toSignal` with feature flags. |
| Visual changes | Check "Yes" only if `.html`, `.scss`, or template files were modified. |
| Checkboxes | Use `[x]` for the selected option, `[ ]` for the other. |
| Base branch | Default `develop`. Use parent feature branch for stacked PRs. |
