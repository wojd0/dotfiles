---
name: implement-jira-ticket
description: Implements or fixes a Jira ticket end-to-end in the hxp-frontend-apps Nx monorepo. Use when the message contains a Jira ticket ID with or without a verb; the user provides a Jira browse URL; the user says "implement", "fix", "work on", "pick up", "take on", "start on", "do", or "handle" a ticket; the user pastes a ticket ID alone; or the user asks to implement a feature or fix a bug and there is a ticket reference anywhere in the message.
---

# Implement Jira Ticket

## Workflow

### 1. Parse the request

Extract the ticket ID and any extra context from the user message. The user may provide:
- A Jira URL: `https://example.atlassian.net/browse/<JIRA_KEY>-<NUMBER>`
- A ticket ID with instructions: `implement ticket <JIRA_KEY>-<NUMBER>, <extra context>`
- A bug fix request containing a Jira browse URL

### 2. Fetch ticket details

Use the Atlassian MCP to get ticket details:

```
Tool: getJiraIssue
Server: user-Atlassian
Arguments:
  cloudId: "<connected-cloud-id>"
  issueIdOrKey: "<JIRA_KEY>-<NUMBER>"
  responseContentFormat: "markdown"
```

If MCP is unavailable, ask the user to paste the ticket description.

### 3. Summarize and confirm scope

Present a concise summary of:
- What needs to be done
- Acceptance criteria
- Any feature flag requirements (user may specify one, or the ticket may mention one)

Ask the user to confirm or adjust before proceeding.

### 4. Create a plan

Switch to Plan mode and create a structured plan with:
- Specific files to modify/create
- Implementation steps as a checklist
- Test strategy

### 5. Create a branch (if not already on one)

Always branch from the latest `develop`. First discover the remote name (it may be `origin`, `o`, etc.):

```bash
REMOTE=$(git remote | head -1)
git fetch "$REMOTE" develop
git checkout -b <branch-name> "$REMOTE/develop"
git push -u "$REMOTE" HEAD
```

The `push -u` immediately sets the upstream to the matching remote branch, avoiding the mismatch where the branch tracks `develop` instead of the feature branch.

Branch name must match: `^(revert-[0-9]+-)?(improvement|fix|feature|test|tmp|dependabot)/<JIRA_KEY>-<NUMBER>-<kebab-description>$`

Use the Jira project key from the linked ticket.

Common prefixes:
- `feature/` — new functionality
- `fix/` — bug fixes
- `improvement/` — refactoring, enhancements to existing features
- `test/` — test-only changes

### 6. Implement

Follow the plan step by step. Key conventions for this codebase:

- **Localization**: Only modify `en.json` files. Never touch other language files.
- **Angular components**: Remove `standalone: true` if present (it's now the default).
- **Feature flags**: When required, gate changes behind the specified flag. Use `FeatureFlagService` and the feature flag enum. Test both flag-on and flag-off states.
- **RxJS**: Prefer `catchError` over subscribe error handlers. Use `firstValueFrom`/`lastValueFrom` with async/await in tests.
- **Error handling**: Services throw errors; components handle UI feedback (dialogs, snackbars, notifications).

Use the Nx MCP to discover project structure and targets when needed:
- `nx_workspace` — overview of all projects
- `nx_project_details` — specific project config and available targets

### 7. Run tests

After implementation, run the affected project's unit tests:

```bash
npx nx test <project-name>
```

Use the Nx MCP `nx_project_details` tool to find the correct project name and test target if unsure.

Test conventions:
- No `should create` boilerplate tests
- Separate arrange/act/assert with empty lines
- Use `firstValueFrom`/`lastValueFrom` with async/await (not subscribe, not done callback)
- No `TestBed.resetTestingModule()`
- Minimize `fakeAsync`, `fixture.detectChanges`, `fixture.whenStable`
- Single shared `setupTest()` function with config object and defaults
- Use component harnesses from `libs/shared/testing/src/util/component-harnesses` for Angular Material
- For feature flags: use `provideMockFeatureFlags` with `BehaviorSubject` to toggle flag states

### 8. Commit

Commit message format: `<JIRA_KEY>-<NUMBER> <concise description of the change>`

Only commit when asked. Follow the standard git safety protocol.

### 9. Create PR

When asked, create a PR using `gh pr create`. Include:
- Summary of changes (1-3 bullets)
- Test plan / checklist
- Link to the Jira ticket

## Iterative refinement
`
The user will likely request adjustments after the initial implementation. Common follow-ups:
- Additional files/locations that need the same change
- Feature flag gating that wasn't initially requested
- PR review comments to apply
- CI failure analysis and fixes

For each round of feedback, update the plan, implement, and re-run tests.

## Detailed reference

For detailed codebase patterns and examples, see [reference.md](reference.md).
