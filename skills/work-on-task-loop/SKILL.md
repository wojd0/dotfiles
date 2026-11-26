---
name: work-on-task-loop
description: Multi-phase workflow to research, plan, implement, and contribute a task or Jira ticket. It repeats implementation and code triage in sub-agents until the triage finds no problem, with stall escalation to an advisor and the user.
disable-model-invocation: true
---

# Plan and implement a task in a triage loop

Plan and implement a task or a Jira ticket through a multi-phase workflow. Phases 7 and 8 form one loop. Each **round** has one implementer sub-agent and one triage sub-agent. The loop ends when a triage finds no confirmed problem and each check passes.

## Conventions

1. **STOP** means that you stop and wait for user input. Show the required information, ask the question with the question tool when available, and include a recommended answer.
2. When you start a phase, send the message: `<phase_name> phase started`.
3. If a rule, configuration, or missing permission blocks an action, **STOP**. Tell the user what is blocked, give the command or steps to fix it, and ask whether they resolved the problem.
4. Sub-agent definitions live in `~/.agents/agents/`. When a phase names a sub-agent, start it with that name as the agent type. If the agent type is not available, read its definition file and do its work yourself, and tell the user that the phase ran without the sub-agent.

## Prerequisites

1. Verify that the user gave a ticket key, a Jira link, or a clear task description. If not, **STOP** and ask for it.
2. When the task references Jira or Confluence, run one small read with the Atlassian MCP to confirm access.
3. Run `git fetch --prune origin` to confirm access to the GitHub remote.
4. Verify that the working tree is clean. If not, **STOP** and ask the user how to proceed.
5. If the repository sits on its default base branch (`main`, `develop`, or equivalent), run `git pull --ff-only`.

## Phase 1: Identify the ticket

Extract the ticket key and any extra context from the user message:

- A Jira URL: `https://example.atlassian.net/browse/<JIRA_KEY>-<NUMBER>`
- A ticket key with instructions: `implement ticket <JIRA_KEY>-<NUMBER>, <extra context>`
- A task or bug fix request with a Jira browse URL

If the user request is not clear enough to identify the task, **STOP** and ask for more detail.

## Phase 2: Collect spec and context

Start one `spec-researcher` sub-agent. Give it:

- the ticket key, link, or task request;
- the extra context and focus from the user message, in the user's words;
- what you know from Phase 1;
- the repository path and its remote URL.

The sub-agent explores every knowledge source connected to the session and returns a spec brief. Use the spec brief as the task spec in all later phases.

Done when you have the spec brief. If the brief lists blocked sources, **STOP**, show each blocked source with its fix, and ask the user whether to continue without it.

## Phase 3: Research the codebase

Run one or more research sub-agents to inspect the codebase and find the required changes:

- find the affected files and their callers;
- check usages in tests, stories, showcases, and demos;
- identify the build, lint, unit test, and CI verification targets for the affected projects;
- read related repository documentation and design specifications.

Done when all affected files, callers, and verification commands are identified.

## Phase 4: Confirm alignment with the user

Before you draft the implementation plan, show the user your understanding of the task without implementation details. Send a message with these four sections:

- **Context summary**: the number of pages, tickets, and other sources checked.
- **Current state**: how the affected functionality works now.
- **Problem or goal**: the missing feature, change, or bug that you will address.
- **Expected result**: how the behavior or technical outcome will change.

**STOP** and ask the user for approval or corrections. Continue to Phase 5 only after the user approves.

## Phase 5: Draft the implementation plan

Write a structured implementation plan covering the files to change, the steps to execute, and the verification commands to run.

Present the plan to the user. When the user approves the plan for implementation in the same session, continue from Phase 6.

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

## Phases 7 and 8: Implement and verify

Follow the loop phases below.

## Phase 9: Contribute

Read and follow [`references/contribution.md`](references/contribution.md) to propose the commits, push the branch, and return a PR proposal.

## Context budget

The main thread only routes the loop. All detail stays in the state folder, so 2 rounds and 2,000 rounds cost the main thread the same context.

- Give each sub-agent paths, not file contents.
- Read only the header and the last five rows of `ledger.md`, and the last line of each sub-agent.
- Do not read the round files yourself. The next sub-agent reads them.
- Start each round with new sub-agents. Do not continue a sub-agent of an earlier round.
- If the session lost the loop state, read the last rows of `ledger.md` again and continue from the last row.

## Model tiers

Start each sub-agent on its tier. `~/.agents/references/model-tiers.md` defines the tiers and their bindings.

| Role | Tier |
|---|---|
| Main thread that routes the loop | `standard` |
| `loop-implementer` | `standard`, or `deep` for the round after an advice |
| `loop-triage` and its axis sub-agents | `standard` |
| `triage-verifier` | `deep` |
| `loop-advisor` | `top` |

## Loop phase A: Prepare the state

1. Set the state folder to `<git-dir>/work-loop/<branch>`, with `/` in the branch name changed to `-`. Get `<git-dir>` with `git rev-parse --absolute-git-dir`. Git does not track this folder.
2. If the state folder has a `ledger.md`, **STOP**. Show its last row, and ask the user whether to resume the loop or to start again.
3. Write the approved plan to `plan.md` and the Phase 2 spec brief to `spec.md` in the state folder. If the session has no spec brief, run Phase 2 again to get it.
4. Set `<base>` with `git merge-base HEAD <remote>/<default-branch>`.
5. Set the round budget. Use the number that the user gives, or 10.
6. Write `ledger.md` with this header:

   ```markdown
   | Round | Tree | Open | New | Persisting | Fixed | Reopened | Age | Checks | Progress |
   |---|---|---|---|---|---|---|---|---|---|
   ```

Done when `plan.md`, `spec.md`, and `ledger.md` exist and `<base>` resolves.

## Loop phase B: Run one round

Start with round `<n>` = 1.

1. Start one `loop-implementer` sub-agent with the checkout path, the state folder, and `<n>`. If an advisor gave advice for this round, also give the path of the advice file.
2. If the implementer returns a `blocked` line, **STOP**, as in convention 3.
3. Take a snapshot of the working tree: `~/.agents/skills/work-on-task-loop/scripts/snapshot.sh <state-folder>`. The script prints the tree id `<tree>`. It does not change the index, the branch, or the stash.
4. Start one `loop-triage` sub-agent with the checkout path, the state folder, `<n>`, `<base>`, and `<tree>`.
5. If the triage returns a `blocked` line, **STOP**, as in convention 3.
6. Add one row to `ledger.md` from the triage line. Set **Progress** as in Loop phase C.

Done when the ledger has the row of round `<n>`.

## Loop phase C: Decide

Set **Progress** for the round:

- `yes`: **open** is less than the lowest **open** of the earlier rounds after the last advice row. The first round after the start or after an advice row always has `yes`.
- `no`: each other case. A round that closes one problem and opens another makes no progress.

Then do the first rule that applies:

1. **Done**: **open** is 0 and **checks** is `pass`. Go to Phase 9. If the triage line says `spec none`, tell the user that the triage had no spec.
2. **Stalled**: the last two rounds have `no`, or **age** is 3 or more. Go to Loop phase D.
3. **Budget**: the loop ran the round budget since the start or since the last answer of the user. **STOP**. Show the ledger, and ask the user whether to continue and with which budget.
4. **Next round**: add 1 to `<n>`, and go to Loop phase B.

## Loop phase D: Escalate a stall

1. Start one `loop-advisor` sub-agent with the checkout path, the state folder, `<base>`, and `<n>`.
2. **STOP**. Show the user the advisor line, the last three ledger rows, and the **Questions** section of `advice/<n>.md`. Ask how to continue, with these options:
   - **Apply the advice**: run the next round with the advice file, with the implementer one tier up. Recommend this option when the advisor says `continue`.
   - **Change the plan**: the user gives the change. Write it to `plan.md` and to a `## Plan change` section of `advice/<n>.md`, and run the next round with the advice file. Recommend this option when the advisor says `replan`.
   - **Answer the questions**: write the answers to an `## Answers` section of `advice/<n>.md`, and run the next round with the advice file. Recommend this option when the advisor says `ask-user`.
   - **Stop the loop**: keep the working tree as it is, and go to Phase 9.
3. Add the row `| advice <n> | <option> |` to `ledger.md`. The stall rules use only the rounds after the last advice row.

Done when the user selects an option and the next round starts, or the loop stops.
