---
name: jira-ticket
description: Propose a new Jira ticket, then create it or change the proposal as the user directs. Use when the user asks to draft or create a Jira ticket.
---

# Jira ticket

Prepare one complete ticket proposal. Let the user choose whether to create it, create and assign it to themselves, or change it.

Steps 1–4 are read-only. End the turn after the Step 4 questionnaire. Even an initial request to “create a ticket” requires this proposal and a later user answer before creation.

Use the connected Jira tools. Discover operations and their inputs before use.

## 1. Find the bucket

Resolve the Jira site, project, and current user's account ID and display name. Reuse values already confirmed in this session. Use the current Jira account, not the Git author or a stored name.

A **bucket** is an existing parent ticket that groups this work. It can be an Epic or another parent type that the project supports. A project, board, sprint, or label alone is not a parent ticket.

Read the user's evidence and any specified parent. Otherwise, search Jira for the feature, component, and purpose. Find the best existing bucket from its scope and child tickets. Check that the work fits the parent and its hierarchy. Check project creation access.

If several buckets fit equally well, ask the user to choose. If no parent fits, propose no parent and explain why. Create a new bucket only when the user requests it. Continue independent research while a bucket question is pending.

This step is complete when the project and parent are known, or a specific parent question is pending.

## 2. Read the ticket context with subagents

Run these three research tasks with separate subagents. Give each agent the site, current account ID, request, evidence, and confirmed bucket. Agents have read access for this task; the main agent handles all writes.

| Agent | Tickets to read | Required result |
| --- | --- | --- |
| Bucket | The parent and every ticket inside it, including nested children | Shared scope, conventions, metadata, dependencies, and work already covered |
| Related work | Tickets named by the user, direct issue links, and tickets found by searches for the requested work | Related work, duplicate candidates, useful evidence, and proposed link types and direction |
| User history | The latest 20 tickets created by the current user, across projects | Current writing style, with more weight on tickets in the target project and of a similar type |

Use `creator = currentUser() ORDER BY created DESC` for user history. Use creator, not reporter or assignee. Stop at 20 distinct tickets, or report that fewer are available.

For bucket research, use the site's supported parent or Epic relationship. Read all result pages. Follow child relationships until all descendants are covered. For related work, search with the feature name, component, symptom, and exact identifiers. Read every result of the relevant searches and every direct issue link from the parent or matched tickets. Follow further links when they affect this request. Record the search scope so that “all related tickets” has a clear limit.

### Read contract

- Read each ticket's complete available fields, including standard fields, custom fields, and metadata. Request `fields: ["*all"]` with `view: "full"`, or the connector's equivalent. A summary or compact search result is not a complete read.
- Inspect the description, acceptance criteria, parent, children, issue links, type, status, resolution, priority, labels, components, categories, versions, sprint, people, dates, and other returned fields. Keep field names and schemas with their values. Fetch field metadata if the response has only field IDs.
- Read all comment pages when the ticket has comments. Read attachment metadata; open an attachment when it contains evidence needed for the request. Read additional history or properties when a field's meaning depends on them.
- Page all ticket sets and field metadata. Fetch an individual ticket when a search result omits or truncates fields. Mark content that the source still truncates or access rules hide.
- Share complete reads between agents to avoid repeated requests. Each agent must inspect its full assigned set.
- Each agent returns the queries, ticket keys, unique ticket count, pages read, findings, and any missing fields or access limits. Return the evidence needed for decisions; keep raw ticket records out of tracked files.

If subagents are unavailable, state this limit and do the same reads in sequence. Do not report this as a subagent review.

Merge the results before writing the proposal. Resolve conflicting conventions with the target bucket and project. Distinguish user text from empty templates, imported text, and automation. Report a duplicate before proposing a second ticket. If the same work already exists, ask whether the user wants a separate ticket.

This step is complete when all three sets are read and their coverage is known. State any remaining access limit beside the affected proposal detail.

## 3. Select the type, fields, and status

List the issue types that the user can create in the target project. Choose the type from the work's purpose, the parent hierarchy, and similar tickets. Check the type's description and subtask flag. Use the project's actual types; a bug can be a child ticket if the hierarchy and local practice require it.

Read create-field metadata for the selected project and type, including optional fields. With the Atlassian connector, discover and use:

- `listJiraProjectIssueTypesMetadata`, with all pages;
- `getJiraIssueTypeMetaWithFields`, with `requiredFieldsOnly: false` and all pages;
- `listJiraStatuses`, with `mode: "project"` and the selected `issueType`.

Record field names, IDs, required flags, schemas, allowed values, and defaults. Read edit metadata when a proposed field can only be set after creation. Check available issue link types and their inward and outward meanings. Check that each proposed value is valid for this project and type. Resolve a required value from evidence or ask one focused question.

Always write a list of acceptance criteria. Each item must describe a result that can be checked. If a separate Acceptance Criteria field is supported and writable during creation or an edit, put the list there. Otherwise, put it under **Acceptance criteria** in the description. Show its exact destination in the proposal. An empty Readiness template or a Definition of Done field does not replace the list.

Propose metadata from the request and relevant bucket conventions. Include all required fields and any optional field to be set. Identify defaults and fields left empty. Include the project, parent, assignee, labels, components, categories, priority, status, versions, sprint, and other applicable custom fields. Mark a named field as **Not supported** when the project does not provide it. Treat server-managed fields as read-only. Do not copy completed statuses, resolutions, release labels, or people from old tickets.

Project statuses show what the type supports. Issue transitions show where one issue can move now. Use workflow metadata to confirm the initial status when available. Otherwise, mark the proposed initial status as unconfirmed. Do not infer the initial status or a transition from old tickets alone.

This step is complete when the type, acceptance criteria destination, writable fields, required values, and supported statuses are known.

## 4. Present the proposal and ask how to proceed

Before writing the proposal, read the [ticket style guide](references/ticket-style.md). Apply it with the findings from the latest 20-ticket review in Step 2.

Use these six bullets in this order. Expand the description and metadata as needed so that the user can review all text and values before creation.

```text
- bucket (parent ticket) name: [Name, key, and link; or None with a reason]
- ticket type: [Supported type; brief reason if useful]
- summary: [Exact proposed summary]
- description: [Exact proposed description]
- linked tickets: [Key, summary, link type, and direction; or None]
- all other metadata (labels, categories, status): [Project, acceptance criteria field and list if separate, and every other proposed value or default]
```

Then ask: **How do you want to proceed?**

a) Create the ticket.
b) Create the ticket and assign it to [current user's display name].
c) Change something.

Use a question tool when available. Include the proposal in the question or the same response. Keep these three choices.

**STOP HERE. End the turn with the proposal and questionnaire.** The proposal stage is complete when the user has received both. Make no Jira writes while the answer is pending. A preselected choice, silence, elapsed time, or earlier general permission is not an answer.

Only after an actual user answer to this questionnaire arrives, read [Handle the user's answer](references/after-user-answer.md). Keep that procedure unloaded during the proposal stage. Creation requires choice a, choice b, or an equally clear user instruction to create the proposed ticket.
