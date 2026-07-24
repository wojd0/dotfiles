# Reference: Jira Ticket Implementation Patterns

## Atlassian MCP usage

### Fetching a ticket

```
Server: user-Atlassian
Tool: getJiraIssue
Arguments:
  cloudId: "hyland.atlassian.net"
  issueIdOrKey: "AAE-43172"
  responseContentFormat: "markdown"
```

The `cloudId` can be derived from the Jira URL hostname. If the call fails, use `getAccessibleAtlassianResources` (no arguments) to discover available cloud IDs.

### Searching for related tickets

```
Server: user-Atlassian
Tool: searchJiraIssuesUsingJql
Arguments:
  cloudId: "hyland.atlassian.net"
  jql: "key = AAE-43172"
```

## Nx workspace

### Discovering projects

Use the Nx MCP to find the right project:

```
Server: user-nrwl.angular-console-extension-nx-mcp
Tool: nx_workspace
```

### Getting project details (test targets, build config)

```
Server: user-nrwl.angular-console-extension-nx-mcp
Tool: nx_project_details
Arguments:
  projectName: "studio-hxp-project-hub-import-export-smart"
```

### Running tests

```bash
npx nx test <project-name>
# Example:
npx nx test studio-hxp-project-hub-import-export-smart
```

## Feature flag patterns

### Service usage

```typescript
private featureFlagService = inject(FeatureFlagService);

isFeatureEnabled = this.featureFlagService.isFeatureEnabled(FeatureFlags.STUDIO_PROJECT_SUBSET_IMPORT_EXPORT);
```

### Template usage

```html
@if (isFeatureEnabled()) {
  <new-behavior />
} @else {
  <old-behavior />
}
```

### Testing with feature flags

```typescript
import { provideMockFeatureFlags } from '@anthropic/testing'; // actual import path varies

function setupTest(config: { featureEnabled?: boolean } = {}) {
  const featureEnabled$ = new BehaviorSubject(config.featureEnabled ?? false);

  TestBed.configureTestingModule({
    providers: [
      provideMockFeatureFlags({
        [FeatureFlags.STUDIO_PROJECT_SUBSET_IMPORT_EXPORT]: featureEnabled$,
      }),
    ],
  });

  return { featureEnabled$ };
}

it('should show new label when feature is enabled', async () => {
  const { featureEnabled$ } = setupTest({ featureEnabled: true });

  const result = await firstValueFrom(component.label$);

  expect(result).toBe('Import');
});
```

## Localization

Only modify English locale files (`en.json`). Common locations:

- `libs/studio-hxp/project/hub/assets/i18n/en.json`
- `libs/studio-shared/sdk/i18n/en.json`
- `libs/studio-shared/project-editor/base/i18n/en.json`

Key format: `SECTION.SUBSECTION.KEY` (e.g. `PROJECT_HUB.IMPORT.ERROR.INVALID_OR_EMPTY_FILE`).

## Error handling pattern

Services throw errors; components catch and show UI feedback:

```typescript
// Service — throws on error
getTreeDataFromFile(file: File): Observable<TreeNode[]> {
  return this.http.post<Model[]>(url, formData).pipe(
    map(models => {
      if (!models?.length) {
        throw new Error('PROJECT_HUB.IMPORT.ERROR.INVALID_OR_EMPTY_FILE');
      }
      return this.mapToTreeData(models);
    }),
  );
}

// Component — catches and handles UI
loadData$ = this.service.getTreeDataFromFile(file).pipe(
  catchError(error => {
    this.notificationService.showError(error.message);
    this.dialogRef.close();
    return EMPTY;
  }),
);
```

## Branch naming

Must match regex: `^(revert-[0-9]+-)?(improvement|fix|feature|test|tmp|dependabot)/<JIRA_KEY>-<NUMBER>-<kebab-description>$`

Valid Jira keys: `HXCS`, `AAE`, `HXIDP`, `RPAHXP`, `CICGOV`, `CSX`

| Prefix | Use case | Example |
|--------|----------|---------|
| `feature/` | New functionality | `feature/AAE-43172-adjust-import-export-labels` |
| `fix/` | Bug fixes | `fix/AAE-42457-incorrect-project-file-empty-models-list` |
| `improvement/` | Refactoring, enhancements | `improvement/AAE-42386-fe-model-type-refresh-action` |
| `test/` | Test-only changes | `test/AAE-12345-add-missing-unit-tests` |
| `tmp/` | Temporary/experimental | `tmp/AAE-12345-spike-new-approach` |

## Commit message format

```
AAE-XXXXX <concise description>
```

Examples from past sessions:
- `AAE-42755 Add tsconfig validity check to precommit`
- `AAE-43172 Adjust import/export labels`

## PR creation

```bash
REMOTE=$(git remote | head -1)
git push -u "$REMOTE" HEAD

gh pr create --title "AAE-XXXXX: Short description" --body "$(cat <<'EOF'
## Summary
- <what changed and why>

## Test plan
- [ ] Unit tests pass
- [ ] Manual verification of <specific behavior>

## Jira
https://hyland.atlassian.net/browse/AAE-XXXXX
EOF
)"
```

## Common iteration patterns

From past sessions, users frequently ask for these refinements after initial implementation:

1. **Additional locations**: "Also update the project tree / project list / etc."
2. **Feature flag gating**: "Put this behind feature flag X"
3. **PR review comments**: "Apply this review comment" (often with screenshot)
4. **Error handling changes**: "Move notification from service to component"
5. **CI failures**: "Why is CI failing?" — often caused by label changes in e2e tests that use `getButtonByText()` instead of `data-automation-id`
