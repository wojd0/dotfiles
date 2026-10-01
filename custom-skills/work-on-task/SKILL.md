---
name: work-on-task
description: Plans and executes implementation of a task.
---

# Plan a Jira Ticket 
This skills allows you to plan the implementation of a task following a multi-phase workflow.

## Conventions

Here are important conventions and instructions for using this skill, agent MUST follow these closely:

1. STOP keyword in this skill is a moment for human's input. You need to stop, provide instructed information and questions to the user. Use the ask question tool, outline recommended answer.

2. When reaching next phase send a message to the user with the following content:
<phase_name> phase started

3. If anything (rules, agent configuration or permissions) is preventing you from performing an action, STOP, inform the user what is the problem, providing guidance on how to resolve it (ex. command to execute) and ask him yes/no if they resolved the issue.

## Prerequisites checklist:

- Check if user provided ticket ID, Jira link or a specific request. If not - STOP and ask the user to provide that.
- Check if you have access to the Atlassian MCP by running any simple tool provided by it
- Check if you have access to the GitHub origin the repository you're working on by fetching
- Verify that the current git branch is clean. If not - STOP and ask the user to clean the branch or give guidelines on how to proceed.
- If on repository's main merging branch (develop, main, etc.) - update with fetch and git pull --rebase

## Phase 1: Identifying the ticket

Extract the ticket ID and any extra context from the user message. The user may provide:

- A Jira URL: `https://example.atlassian.net/browse/<JIRA_KEY>-<NUMBER>`
- A ticket ID with instructions: `implement ticket <JIRA_KEY>-<NUMBER>, <extra context>`
- A bug fix request containing a Jira browse URL

If the provided context is not enough, STOP and ask the user for additional information.

## Phase 2: Collecting spec and context 

Phase 2 is best executed using ONE sub-agent. If available, use pre-configured agent type designed for this purpose.

Collect additional information from:
- user-provided ticket
- parent ticket
- child tickets
Fetch information from all sources indicated in a given's ticket description or linked sources list.
Inspect ALL linked confluence pages, ALL linked PRs and ANY other accessible references mentioned in description or otherwise linked to those tickets.
Fetch full content of those sources and summarize them.

## Phase 3: Researching the codebase

Phase 3 is best executed in ONE OR MORE sub-agent(s). If available, use pre-configured agent type designed for this purpose. Adjust subagent(s)' model and effort according to the complexity of the codebase and the changes required.

Research the codebase to understand the current state and the changes needed. Explore all the following areas:
- identify affected files
- check related and impacted files
- verify usages of the files in tests, showcases, demos etc.
- check verification steps and test coverage - builds, lints, tests and CI checks
- review related documentation and design specifications

## Phase 4: Confirming alignement with user's request

Purpose of this phase is for the user to be able to "read your mind" and check if you're understanding their request correctly BEFORE you start drafting implementation plan, so do not provide any implementation details. Provide a structured message with four following sections:
- summary of context you've gathered (number of pages, tickets and other sources checked)
- current state - how does the affected functionality work now?
- the problem, missing feature or bug you're going to work on
- result - how the behavior or technical solution will change

STOP and ask user for feedback, once you get it adjust the plan accordingly. Advance to the next phase only after user's approval.

## Phase 5: Drafting the implementation plan

Create a structured implementation plan. You should follow general best practices for implementation plans you already know or have skills for.

This paragraph MUST be added as-is at the end of the plan (do not read this file yourself, implementing agent has to do it):
Once starting the implementation, agent MUST follow the guidelines provided in the `./references/implementation.md` file.

When the plan is ready, present it to the user.