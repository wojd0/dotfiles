---
name: ci-checks
description: Investigate and diagnose failing CI checks, GitHub Actions workflows, and automated pipeline runs.
---

# Investigate failing CI checks

## Collect run metadata

Extract the pull request number, branch name, or workflow run ID from the user request. If the user gives no repository, read it from the local git remote. The pull request can be for a branch other than the checked-out branch.

1. **Fetch CI status**: For a pull request, run `gh pr view <number> --repo <owner/repo>` and `gh pr checks <number> --repo <owner/repo>` to list the failing checks. For a branch or a workflow run, run `gh run list --branch <branch> --limit 5`.
2. **Read run logs**: For each failing check, find the latest attempt number with `gh run view <run-id> --json attemptNumber --jq '.attemptNumber'`. Then read the failed log of that attempt: `gh run view <run-id> --attempt <N> --log-failed`. If the log download fails, read the annotations and logs with `gh api`. Always inspect the latest attempt, and check whether earlier attempts failed in the same way.
3. **Read pull request changes**: For a pull request, run `gh pr diff <number> --repo <owner/repo>` and `gh pr view <number> --json files`. Skip this step for a run without a pull request.
4. **Pin a checkout**: When the analysis needs local test or source files, pin a checkout as in `~/.agents/references/temporary-codebases.md`:
   - For a pull request, read `headRefOid` and `baseRefName` from `gh pr view <number> --repo <owner/repo> --json headRefOid,baseRefName`. Use the commit `headRefOid`, the refs `<baseRefName>` and `pull/<number>/head`, and the name `ci/<owner>/<repo>/PR-<number>`. Run `git rev-list --count HEAD..<remote>/<baseRefName>` in the checkout to see how far the pull request is behind its base. More than 200 commits is an integration risk.
   - For a run without a pull request, read `headSha` and `headBranch` from `gh run view <run-id> --json headSha,headBranch`. Use the commit `headSha`, the ref `headBranch`, and the name `ci/<owner>/<repo>/run-<run-id>`.

Done when each failing check has its latest attempt log and the pull request diff or commit is known.

## Investigate the failure

Find the root cause of each failing check from its log and the changed files:

- Compare the failure with the pull request diff first.
- Aggregation jobs (such as Final Results) and external services (such as SonarCloud) often fail as a result of another failed job or a temporary service error.
- If the failure does not come from the changed files in the pull request, check the commits merged to the base branch and to the target branch since the last workflow run that passed on the first attempt. If that range is large, use sub-agents to inspect the diffs.
- If the log shows an authentication, permission, or environment error, check whether a token, secret, permission, or repository setting expired or changed on the remote host.

Done when each failing check has an identified root cause and an allowed reason.

## Fix failures

When the user asks to fix a failing check, apply the code changes only in a local checkout pinned as in step 4. Give the checkout path when it is a temporary codebase. Do not commit or push. Let the user decide when to commit.

## Report the summary

End your response with the summary format below. Pick one reason for each failure from the allowed reasons.

**Allowed reasons:**

- Due to PR changes
- Unrelated / Flaky
- Infrastructure / Environment
- Cascading failure
- External service
- Visual regression
- Missing translations

```markdown
## Failing Checks Summary

---
### ❌ <test ID or check name>
- **Reason:** <one of the allowed reasons>
- **Description:** <brief description of the failure, the root cause, and the fix>
- **File:** `<relative path to the test file>`
- **Run:** <full GitHub job URL>
---
(repeat for each failing check)

### Verdict
<one of the verdicts below>
```

**Verdict** must be one of:

- 🔁 Re-run – when all failures are unrelated, flaky, or cascading
- 🔧 Needs fixing – when at least one failure comes from code changes
- 🔍 Investigate infrastructure – when failures point to infrastructure, environment, or configuration problems
