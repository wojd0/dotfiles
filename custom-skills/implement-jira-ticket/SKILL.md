---
name: plan-jira-ticket
description: Plans the implementation of a Jira ticket.
---

# Plan a Jira Ticket 
This skills allows you to plan the implementation of a Jira ticket following a multi-phase workflow.

## Prerequisites

STOP keyword in this skills is a mark for the human entry, you need to stop, provide instructed information to the user and wait for their input.

Prerequisites checklist:
- Check if user provided ticket ID, Jira link or a specific request. If not - STOP and ask the user to provide that.
- Check if you have access to the Atlassian MCP by running any simple tool provided by it
- Check if you have access to the GitHub origin the repository you're working on by fetching
- Verify that the current git branch is clean. If not - STOP and ask the user to clean the branch or give guidelines on how to proceed.
- If on repository's main merging branch (develop, main, etc.) - update with fetch and git pull --rebase

When reaching next phase send a message to the user with the following content:
<phase_name> phase started

Example:
Phase 1: Identifying the ticket phase started

Do not edit any files or code, do not create any new git entities. Your work should leave no trace if you were to be restarted.

## Phase 1: Identifying the ticket

**SWITCH TO AGENT/EDIT MODE** (you have to switch to agent/edit mode - STOP and ask the user to switch to agent/edit mode if declined or automatic switch fails)

Extract the ticket ID and any extra context from the user message. The user may provide:

- A Jira URL: `https://example.atlassian.net/browse/<JIRA_KEY>-<NUMBER>`
- A ticket ID with instructions: `implement ticket <JIRA_KEY>-<NUMBER>, <extra context>`
- A bug fix request containing a Jira browse URL

If the provided context is not enough, STOP and ask the user for additional information.

## Phase 2: Fetching ticket details

Phase 2 is best executed in ONE sub-agent using a lighter model. If available, use pre-configured agent type designed for this purpose.

### Fetch ticket and related sources details

Fetch tickets summary, description, comments and other ticket metadata.

### Fetch related ticket details

Collect additional information from:
- user-provided ticket
- parent ticket
- child tickets
Fetch information from all sources indicated in a given's ticket description or linked sources list. Fetch full content of those sources and summarize them.

## Phase 3: Researching the codebase

Phase 3 is best executed in ONE OR MORE sub-agent(s) using a lighter model. If available, use pre-configured agent type designed for this purpose.

Research the codebase to understand the current state and the changes needed.
- identify affected files
- check related and impacted files
- verify usages of the files in tests, showcases, demos etc.

## Phase 4: Confirming alignement with user's request

Purpose of this phase is for the user to be able to "read your mind" and check if you're understanding their request correctly BEFORE you start drafting implementation plan, so do not provide any implementation details. Provide a structured message with four following sections:
- summary of context you've gathered (number of pages, tickets and other sources checked)
- current state - how does the affected functionality work now?
- the problem, missing feature or bug you're going to work on
- result - how the behavior or technical solution will change

On user's feedback, adjust the plan accordingly.

## Phase 5: Drafting the implementation plan

**SWITCH TO PLAN MODE** (you have to switch to plan mode - STOP and ask the user to switch to plan mode if declined or automatic switch fails)

Create a structured plan with the implementation plan. You should follow general best practices for implementation plans you have already setup. Try to omit information already provided in previous phases.

Add this paragraph at the end of the plan (do not read this file yourself, implementing agent has to do it):
Once starting the implementation, agent MUST follow the guidelines provided in the `./references/implementation.md` file.

