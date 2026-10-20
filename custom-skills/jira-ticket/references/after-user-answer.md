# Handle the user's answer

Read this procedure only after the user answers the questionnaire for a proposal already shown in Step 4. Check the actual user message before any write. Creation requires an explicit instruction to create that ticket. If the answer is missing or unclear, keep the proposal pending and ask for the choice.

## Choice a: Create the ticket

Create the latest approved proposal with the procedure below. Keep its proposed assignee and status.

## Choice b: Create and assign the ticket to the current user

Confirm that the current user is assignable in the target project. Ask: **What status should the ticket have?**

Offer the three most relevant supported status names, plus **Other** for a typed status. Prefer the project's equivalents of To Do, In Progress, and Done when they fit. If fewer than three statuses exist, show only the available names. Use the question tool's built-in free-text option for Other when the tool provides it. Check a typed status against the selected type's workflow.

**Stop and end the turn after the status question.** Make no Jira writes until the user answers it. If the user already gave a valid status with choice b, use it without a repeated question. Then create the ticket with the procedure below, assign it to the confirmed current account ID, and set the selected status through the supported workflow.

## Choice c or edits

Apply the changes to the proposal. Preserve the user's latest wording. Repeat research or field checks only where the change affects them. Show the complete revised proposal and the three choices from Step 4, then stop again. Editing instructions alone do not authorize creation.

If the user explicitly requests edits and creation in the same answer, apply those edits and proceed within that instruction. A cancellation ends the task without creation.

## Create and verify: explicit creation answer required

Enter this procedure only after choice a or an equally clear creation instruction, or choice b with a confirmed status answer. Otherwise, stop without a write.

Create one ticket with the approved content, project, type, parent, and fields. Apply approved links and any fields that need a later edit to that ticket.

For a status change, read the new ticket's available transitions with their required fields. Match the destination status ID, not only the transition name. Perform valid transitions toward the selected status and refresh transitions after each move. Supply required transition values only from the approved proposal or user evidence. If no valid route exists, keep the created ticket, report its actual status, and ask how to proceed. Do not substitute a different final status.

A response that contains a new ticket key can be a partial success. Reuse that key if a link, assignment, sprint, field, or transition fails. After a timeout or unclear response, search for the ticket before retrying creation. Retry only after confirming that the ticket was not created.

After a temporary error in a later write, read the ticket and the affected metadata again. Skip the write if it already succeeded. Otherwise, retry that step once when it is safe. If it fails again or the workflow stops making progress, keep the ticket and report the actual result.

Fetch the ticket after the writes. Compare its summary, description, acceptance criteria, project, type, parent, links, assignee, status, and other approved metadata with the proposal. Fix an in-scope mismatch within the retry limit. Report any part that remains incomplete and ask how to proceed.

Return the ticket key and direct link, parent, assignee, and actual status. Creation is complete when one ticket exists with the approved details and the final read confirms them.
