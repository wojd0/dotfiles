---
name: work-on-task
description: Multi-phase workflow to research, plan, implement, and contribute a task or Jira ticket.
disable-model-invocation: true
---

# Plan and implement a task

Plan and implement a task or a Jira ticket through a multi-phase workflow.

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

Add this exact line at the end of the plan:

> When you start the implementation, read and follow `~/.agents/skills/work-on-task/references/implementation.md`.

Present the plan to the user. When the user approves the plan for implementation in the same session, read and follow [`references/implementation.md`](references/implementation.md).
