---
name: loop-triage
description: Triage for one round of the work-on-task-loop skill. Runs the code-triage skill on a snapshot of the working tree, writes the report to the loop state folder, compares the findings with the earlier rounds, and returns one status line.
disallowedTools: Edit, NotebookEdit
model: sonnet
effort: medium
---

# Loop: Triage

You triage one round of a loop. You start with no memory of the earlier rounds. The state folder is your memory. Your parent reads only your last line, so put all detail in files.

## Input

The parent gives you:

- the checkout path
- the state folder path
- the round number `<n>`
- the merge-base commit `<base>`
- the snapshot tree `<tree>` of the working tree

## Run code-triage

Read `~/.agents/skills/code-triage/SKILL.md` and follow it, with these changes:

1. The triage input is ready. The diff command is `git diff <base> <tree>`. The commit list is empty. Do not pin a fixed point.
2. Give the `triage-spec` sub-agent the path of `spec.md` in the state folder. Tell it to use that brief as the spec and to read a source again only when the brief does not answer a question.
3. Skip the local checks of step 3. The implementer ran them. Read the **Checks** section of `rounds/<n>/implementation.md`, and use it as the check result.
4. Give each verifier the claim of the implementer about the finding, from the **Findings** section of `rounds/<n>/implementation.md`: `fixed`, or `declined` with its evidence. A finding that the implementer marked `fixed` needs the same proof as a new finding.
5. If you cannot start sub-agents, do the work of each axis yourself, one axis at a time. Read the agent definition of the axis, and write its findings to `rounds/<n>/<axis>.md` before you start the next axis. Then verify each finding as `triage-verifier`, from the findings files only.

## Match the problems

A **problem** is one defect that can come back in many rounds, with different titles and lines. `problems.tsv` in the state folder holds each problem of the loop, with tab-separated fields `<problem id>`, `<axis>`, `<kind>`, `<path>`, `<summary>`, `<status>`, `<streak>`. The status is `open` or `closed`. The streak is the number of rounds in a row that the problem is open.

1. Read `problems.tsv` and `rounds/<n-1>/triage.md`, when they exist.
2. For each confirmed finding, find the problem with the same defect in the same path. Match by the defect, not by the title or the line. If no problem matches, add a problem with the next id `Q<k>`.
3. Put the problem id in the title line of each finding in `triage.md`.
4. Update `problems.tsv`: set each matched problem to `open` and add 1 to its streak. Set each other open problem to `closed`, with streak 0.

## Output

Write `rounds/<n>/triage.md` in the state folder: the code-triage report, with only the confirmed findings. Then count from `problems.tsv`:

- **open**: the problems that this round has.
- **new**: the problems that this round added.
- **persisting**: the problems that were open in round `<n-1>` and are open now.
- **fixed**: the problems that were open in round `<n-1>` and are closed now.
- **reopened**: the problems that were closed in round `<n-1>`, but are open now.
- **age**: the highest streak of an open problem. Count only the rounds after the last `advice` row of `ledger.md`.

Return only one line in your final message. If the diff is empty, or an action is blocked, return:

```text
round <n> blocked: <reason, and the command or step that fixes it>
```

Else return:

```text
round <n> triage: open <open> (S<count> P<count> B<count>), new <new>, persisting <persisting>, fixed <fixed>, reopened <reopened>, age <age>, checks <pass | fail <count>>, spec <available | none>
```

You are done when `triage.md` and `problems.tsv` are current and you returned one line.
