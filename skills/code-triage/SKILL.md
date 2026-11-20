---
name: code-triage
description: "Three-axis code triage (Standards, Spec, Bugs) with adversarial verification against a base ref. Use when the user asks to triage or review a diff, branch, pull request, or work in progress."
---

# Code triage

Triage the diff between `HEAD` and a fixed point on three axes:

- **Standards**: does the code follow the documented standards of the repository and the smell baseline?
- **Spec**: does the code do what the sources that the change links to ask for?
- **Bugs**: does the code cause incorrect behavior, a crash, a regression, or a broken contract?

Each axis runs in its own sub-agent, so that one axis does not mask another. A verifier then tries to prove each finding wrong, and the report shows only the confirmed findings. All agents use the format in `~/.agents/references/triage-findings.md`.

## Sub-agents

The sub-agents are `triage-standards`, `triage-spec`, `triage-bugs`, and `triage-verifier`, defined in `~/.agents/agents/<name>.md`. Spawn each one with its agent type. If the agent type is not available, spawn a general-purpose sub-agent, and tell it to read `~/.agents/agents/<name>.md` and follow its body.

Give each sub-agent the **triage input**:

- the checkout path
- the diff command: `git diff <fixed-point>...HEAD`, three-dot, so the comparison is against the merge-base
- the commit list: `git log <fixed-point>..HEAD --oneline`
- the branch name, and the pull request link when there is one

## Steps

### 1. Pin the fixed point

The fixed point is what the user gives: a commit, a branch, a tag, `main`, `HEAD~5`, or a pull request link or number. If the user gives none, ask for it.

If the user gives a pull request link or number whose head commit is not the local `HEAD`, read `url`, `baseRefName`, and `headRefOid` with `gh pr view <pr> --json url,baseRefName,headRefOid`. Pin a checkout as in `~/.agents/references/temporary-codebases.md` with the commit `<headRefOid>`, the refs `<baseRefName>` and `pull/<number>/head`, and the name `triage/<owner>/<repo>/PR-<number>`. Set `<fixed-point>` to `<remote>/<baseRefName>` in that checkout.

Run `git rev-parse <fixed-point>` and `git diff --shortstat <fixed-point>...HEAD` in the checkout. Stop here if the ref does not resolve or the diff is empty.

Set the **consumer root**, the folder that holds the user's local repositories. It is the session's working directory when that folder is not inside the repository. Else it is the parent folder of the repository's main checkout, the first entry of `git worktree list`.

Done when the ref resolves, the diff is not empty, and the triage input and the consumer root are set.

### 2. Plan the scope

If the diff has 800 changed lines or fewer, each axis gets the whole diff.

If the diff has more than 800 changed lines, split the Standards and Bugs axes into **chunks**. A chunk is a set of changed paths of one or more projects, such as `packages/<name>/` or `apps/<name>/`. Put each project in one chunk, and join small projects, so that each chunk has about 800 changed lines or fewer. Make 4 chunks or fewer for each axis. The Spec axis always gets the whole diff, because it compares the change with its spec as a whole.

Done when each changed path is in one chunk of each split axis.

### 3. Start the checks

Start this step, then go to step 4 while it runs. Record each check result for the report.

1. If the change is a pull request, read its CI for the head commit with `gh pr checks <link> --json name,state,bucket,link`. For each failed check, read the failed log with `gh run view <run-id> --log-failed`.
2. Run locally the lint, type check, and unit test targets that the CI did not run or has not completed for the head commit. Run them only for the affected projects, as the repository's agent instructions say. Run them in the background.

A check failure is a finding when it points at a changed line, or when the same check passes on the base. Record a check that is still pending as pending.

Done when each check has a result: passed, failed with its finding, pending, or not run with the reason.

### 4. Run the axes

Spawn in parallel, in one message:

- one `triage-standards` sub-agent for each Standards chunk, with the triage input and the paths in scope
- one `triage-spec` sub-agent, with the triage input
- one `triage-bugs` sub-agent for each Bugs chunk, with the triage input, the paths in scope, and the consumer root

Done when each sub-agent has returned its findings, `No Standards findings`, `No Bugs findings`, or `No spec available`.

### 5. Verify the findings

Collect the findings of all axes. Give each finding to a `triage-verifier` sub-agent, with the triage input and, for a Spec finding, the spec text that it quotes. Spawn the verifiers in parallel. If there are more than 10 findings, give each verifier the findings of one file, so that there are 10 verifiers or fewer. Check failures from step 3 need no verifier, because the CI or the local run shows them.

Done when each finding has a `confirmed` or `refuted` verdict.

### 6. Report

Wait for the checks of step 3. Then report under the `## Standards`, `## Spec`, `## Bugs`, and `## Checks` headings. Under each axis, list the confirmed findings in the finding format, with the verifier's **Result** as the last line. Keep the axes apart, and keep the order in each axis. Under `## Spec`, put the spec sources table first.

End with one summary line for each axis: the number of confirmed findings, the number of refuted findings, and the worst confirmed finding of that axis. If the Spec axis reports `No spec available`, say so on its line.
