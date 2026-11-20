# Implement a task plan

Execute an approved implementation plan through Phases 6–9. If the prerequisites in [`SKILL.md`](../SKILL.md) were not checked in this session, check them first.

## Phase 6: Prepare the branch

1. Read the repository's branch naming rules (`.github/instructions/`, `.cursor/rules/`, Husky hooks, `CONTRIBUTING*`).
2. Name the branch with the repository's valid prefix (`feat/`, `fix/`, etc.), the Jira ticket key, and a short kebab-case description from the ticket summary:
   - `DS-2204 Move default url to satori-preview` → `feat/DS-2204-move-default-url-to-satori-preview`
   - `DS-2113 ⚙️ Fix nested scrollviews storybook example` → `fix/DS-2113-fix-nested-scrollviews-storybook-example`
3. If the current branch does not match the target branch for this ticket, create the branch from the default base branch and push its upstream:

   ```bash
   REMOTE=$(git remote | head -1)
   BASE=$(git symbolic-ref "refs/remotes/$REMOTE/HEAD" 2>/dev/null | sed 's|.*/||' || echo main)
   git fetch "$REMOTE" "$BASE"
   git checkout -b <branch-name> "$REMOTE/$BASE"
   git push -u "$REMOTE" HEAD
   ```

Done when the checkout is on the feature branch and tracks its matching remote branch.

## Phase 7: Implement

Pass the full implementation plan to a sub-agent (or execute it step by step when sub-agents are unavailable) and apply each planned change.

Done when all planned changes are applied.

## Phase 8: Verify

Read the repository's scripts and GitHub Actions workflow files to find the required checks. Run the unit tests, lint checks, type checks, and build for the affected projects. Fix all failures until every check passes.

Done when all affected tests, lint checks, and builds pass.

## Phase 9: Contribute

Read and follow [`contribution.md`](contribution.md) to propose the commits, push the branch, and return a PR proposal.