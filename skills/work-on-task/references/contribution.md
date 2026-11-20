# Contribution procedure

## 1. Propose the commit strategy

Follow the `commit-message-format` skill to format each commit subject.

Prefer a single commit when the change is small and self-contained. When the change spans distinct concerns, split it into small, self-contained commits by change kind:

- **modifications**: self-contained updates to existing logic or component structure
- **additions**: new files, components, stories, or types
- **refactors**: structural changes that preserve behavior
- **styles**: visual changes to colors, typography, spacing, tokens, or CSS classes
- **tests**: new or updated unit and integration tests

Present the proposed commits to the user in this format:

```markdown
Commit message: `feat: ABC-123 Add new feature`
Commit contents: Add `Abc123Component` in `src/features/abc-123/abc-123.component.ts` with its story `Abc123Component.stories.ts`.

Commit message: `test: ABC-123 Add unit tests for Abc123Component`
Commit contents: Add unit tests in `src/features/abc-123/abc-123.component.spec.ts`.
```

**STOP** and ask the user for approval before you commit.

## 2. Commit and push

After the user approves, create the commit(s) and push the branch to the remote repository:

```bash
git push
```

## 3. Return a PR proposal

Do not create a pull request on GitHub. Instead, return a **PR proposal**: a GitHub compare-page URL prefilled with the pull request title and description so the user can open the pull request themselves.

1. **Title**: Check the repository's pull request rules and the last 20 merged human-authored pull requests:

   ```bash
   gh pr list --repo <owner>/<repo> --state merged --limit 20
   ```

   Match the dominant human-written title pattern.
2. **Description**: Include only the direct URL to the related Jira ticket (for example, `https://atlassian.atlassian.net/browse/ABC-123`). If there is no Jira ticket link, leave `body` empty.
3. **Compare URL**: Append the URL-encoded query parameters `expand=1`, `body=<description>`, and `title=<title>`:
   - Compared to the default branch:
     `https://github.com/user/repo/compare/feat/my-feat-branch?expand=1&body=https://atlassian.atlassian.net/browse/ABC-123&title=ABC-123:%20Add%20new%20feature`
   - Compared to a specific base branch:
     `https://github.com/user/repo/compare/my-other-branch...fix/my-fix-branch?expand=1&body=https://atlassian.atlassian.net/browse/ABC-456&title=ABC-456:%20Fix%20bug`
