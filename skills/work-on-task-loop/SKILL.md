---
name: work-on-task-loop
description: Variant of work-on-task that repeats implementation and code triage in sub-agents until the triage finds no problem, with stall escalation to an advisor and the user.
disable-model-invocation: true
---

# Plan and implement a task in a triage loop

This skill extends the `work-on-task` skill. Read `~/.agents/skills/work-on-task/SKILL.md` completely, and follow it as the base procedure. If this file and the base procedure disagree, this file applies.

The base Phases 7 and 8 become one loop. Each **round** has one implementer sub-agent and one triage sub-agent. The loop ends when a triage finds no confirmed problem and each check passes.

## Changes to the base procedure

- **Phase 5**: put this exact line at the end of the plan, in place of the base line:

  > When you start the implementation, read `~/.agents/skills/work-on-task-loop/SKILL.md` and continue from Phase 6.

- **Phase 6**: follow `~/.agents/skills/work-on-task/references/implementation.md`, Phase 6.
- **Phases 7 and 8**: follow the Loop phases below.
- **Phase 9**: follow `~/.agents/skills/work-on-task/references/contribution.md`.

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
3. Write the approved plan to `plan.md` and the Phase 2 spec brief to `spec.md` in the state folder. If the session has no spec brief, run base Phase 2 again to get it.
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
2. If the implementer returns a `blocked` line, **STOP**, as in base convention 3.
3. Take a snapshot of the working tree: `~/.agents/skills/work-on-task-loop/scripts/snapshot.sh <state-folder>`. The script prints the tree id `<tree>`. It does not change the index, the branch, or the stash.
4. Start one `loop-triage` sub-agent with the checkout path, the state folder, `<n>`, `<base>`, and `<tree>`.
5. If the triage returns a `blocked` line, **STOP**, as in base convention 3.
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
