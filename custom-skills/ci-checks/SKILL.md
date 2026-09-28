---
name: ci-checks
description: Investigate and diagnose failing CI checks, GitHub Actions workflows, and automated pipeline runs. Use when explicitely invoked.
---

# Investigate failing CI checks

## Workflow

The user may provide a PR number, a GitHub PR link (e.g. `https://github.com/owner/repo/pull/16022`), a branch name, or a workflow run URL. Extract the relevant identifiers and infer the repo from the current git remote when not provided.

Rename the agent session to `[pr-number or branch] [repository] failing CI` — for example `#2056 owner/repository failing CI`.

**Important:** The PR may not be for the branch you are currently on.

1. **Fetch CI status** – Use `gh pr view <number> --repo <owner/repo>` and `gh pr checks <number> --repo <owner/repo>` to list failing checks. For branch/run investigations use `gh run list --branch <branch> --limit 5`.
2. **Get run details** – For each failing check, always fetch the latest attempt number first with `gh run view <run-id> --json attemptNumber --jq '.attemptNumber'`, then pass it explicitly: `gh run view <run-id> --attempt <N> --log-failed`. Fall back to `gh api` to fetch annotations/logs when log download fails. Never inspect attempt 1 if a newer attempt exists.
3. **Get PR changes** – Run `gh pr diff <number> --repo <owner/repo>` and `gh pr view <number> --json files` to see which files were modified. Skip this step for non-PR runs.
4. **Pin a checkout** – When the analysis needs local test or source files, pin a checkout following `~/.agents/references/temporary-codebases.md`:
   - For a PR, use the commit `headRefOid` and the refs `<baseRefName>` and `pull/<number>/head` from `gh pr view <number> --repo <owner/repo> --json headRefOid,baseRefName`, and the name `ci/<owner>/<repo>/PR-<number>`. Then `git rev-list --count HEAD..<remote>/<baseRefName>` in the checkout shows how far the PR is behind its base; over 200 commits is a potential integration risk.
   - For a run without a PR, use the commit `headSha` and the ref `headBranch` from `gh run view <run-id> --json headSha,headBranch`, and the name `ci/<owner>/<repo>/run-<run-id>`.
5. **Analyze each failure** – For each failing check:
   - Identify the failing test/job and error message
   - Check if the failure is related to PR changes (modified files) or unrelated (flaky, external service, cascading)
   - For e2e failures: locate the test file, understand the assertion/behavior, and correlate with PR changes
   - For label/other checks: explain the cause and required action
   - Read test and source files from the checkout pinned in step 4
6. **Summarize** – Always end with the structured summary below.

## Fixing failures

When the user asks to fix a failing check, only apply the code changes locally, in a checkout pinned as in step 4, and give its path when it is a temporary codebase. Do **not** commit or push — let the user decide when to commit.

## Notes

- Always use the latest run attempt. Fetch it with `gh run view <run-id> --json attemptNumber --jq '.attemptNumber'` and pass `--attempt <N>` to all subsequent `gh run view` calls.
- `gh run view --log-failed` may fail with stream errors; fall back to `gh api repos/<owner>/<repo>/actions/jobs/<job-id>/logs` or annotations.
- Aggregation jobs (e.g. Final Results) and external services (e.g. SonarCloud) often fail as cascading or transient issues.
- When the PR changes i18n keys or UI labels, check for missing translations and e2e assertions that expect old text.

## Summary template

Use the card-style format below for each failing test/check. Pick one reason per failure from the allowed list.

**Allowed reasons:**

- Due to PR changes
- Unrelated / Flaky
- Infrastructure / Environment
- Cascading failure
- External service
- Visual regression
- Missing translations

```
## Failing Checks Summary

---
### ❌ <test ID or check name>
- **Reason:** <one of the allowed reasons>
- **Description:** <brief description of the failure, what is the root cause and how to fix it>
- **File:** `<relative path to the test file>`
- **Run:** <full GitHub job URL>
---
(repeat for each failing check)

### Verdict
<one of the following>
```

**Verdict** must be exactly one of:

- 🔁 Re-run – when all failures are unrelated/flaky/cascading
- 🔧 Needs fixing – when at least one failure is caused by PR changes
- 🔍 Investigate infra – when failures point to infrastructure/environment problems
