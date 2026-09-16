---
name: create-bug-report-ticket
description: Creates concise bug-report work items from user-provided conversations, logs, screenshots, documents, or other evidence.
disable-model-invocation: true
---

# Create Bug Report Ticket

Turn the supplied evidence into one evidence-bound bug report. Draft or create the work item according to the user's request.

## Intent gate

- A request to **draft, write, or suggest** a report authorizes read-only research and a draft. Return the draft without creating a work item.
- A request to **create, file, open, or log** a report authorizes creating one work item in the requested tracker and destination.
- If the tracker, project, work-item type, or parent container cannot be inferred safely and the choice would materially change the result, ask one concise question.

## Workflow

1. **Read the evidence.** Open the user-provided conversations, links, logs, screenshots, documents, or existing work items with the appropriate connected tools. Extract only supported facts:
   - affected component or feature;
   - triggering action or state;
   - observable behavior and impact;
   - expected behavior;
   - reproducible steps;
   - exact error identifiers or messages;
   - relevant source links.

   Treat explanations of cause as inference unless the evidence establishes them. Keep inference out of the report unless the user asks for it.

2. **Resolve conventions and destination.** When the user provides an example work item, read it and mirror its useful structure, brevity, and terminology without copying unrelated content. Resolve the exact project, work-item type, and requested parent container, such as an epic, milestone, initiative, release, project, sprint, or cycle. Prefer the tracker's bug or defect type when available.

3. **Check for duplicates before creation.** When creation is requested, search the destination tracker using the strongest evidence: error identifiers, component names, symptoms, and concise phrase variants. For a draft-only request, search only when the user asks. Distinguish an exact duplicate from a merely related report. If an exact duplicate exists, return it instead of creating another unless the user explicitly asks to proceed anyway.

4. **Draft an evidence-bound report.** Use the smallest set of sections supported by the evidence:

   ```markdown
   [One-line summary: component + observable problem]

   Bug in [component or feature]. When [trigger], [observable behavior and impact].

   **Steps to reproduce**

   1. [Step]
   2. [Step]

   **Expected**

   [Observable expected behavior]

   **Actual**

   [Observable actual behavior, including an exact error identifier when useful]

   **Related links**

   - [Relevant evidence or documentation]
   ```

   Keep it concise. Describe the problem rather than proposing a fix. Add severity, priority, ownership, acceptance criteria, environment details, or attachments only when supplied by the user, required by the tracker, or necessary to reproduce the bug. If the user asks to omit evidence such as a video, omit it without leaving a placeholder.

5. **Preserve user edits.** If the user revises the draft, their latest text supersedes earlier versions. Use it unchanged except for formatting conversions required by the destination tracker.

6. **Create only when authorized.** Use the available native connector or API for the requested tracker. Create one work item with the resolved title, description, type, project, and parent container. If required fields are missing, inspect the tracker's metadata and supply only values that can be inferred safely.

7. **Verify the created work item.** Fetch it after creation and confirm its title, description, type, project, parent container, and URL. Correct an in-scope mismatch when possible. Before retrying a failed creation, confirm that the first attempt did not create a work item.

8. **Hand off the result.** Return the work-item identifier and direct link, plus the parent container when one was requested. Mention related reports only when they affect duplicate status or follow-up work.

## Completion criteria

- The report contains no unsupported claims or speculative solution.
- The latest user-edited wording is preserved.
- Duplicate status is known before any creation.
- A created work item exists exactly once in the requested destination and has been verified.
