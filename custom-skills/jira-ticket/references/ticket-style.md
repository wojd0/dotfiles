# Ticket style

Use these rules with the latest 20-ticket review and the target bucket. The user's current instructions take precedence.

## Evidence

This guide is based on the latest 100 tickets created by the current user, read on 20 October 2026. The query was `creator = currentUser() ORDER BY created DESC`. The sample covers 6 November 2025 through 19 October 2026.

Three subagents read groups of 34, 34, and 32 tickets. The sample contains 41 Tasks, 37 Sub-tasks, 11 Bugs, 7 Stories, and 4 tickets of other types. Fifteen descriptions are empty. Only two tickets have a populated Acceptance Criteria field. The same empty Readiness template appears in 98 tickets.

These are current ticket values. Creator identity does not prove who wrote each field or what it contained at creation. Some release and security text comes from templates or imports. One imported security description is truncated in the source. Exclude these sources from personal writing rules. No private ticket records or account values are stored in this guide.

## Summary

- Use a short, specific line. Name the action and target for implementation work. Name the component and visible fault for a bug.
- Start task summaries with a direct verb, such as Add, Remove, Update, Migrate, Create, or Investigate.
- Use sentence case. Keep product names, API names, versions, and code identifiers exact. Correct accidental spelling errors rather than copying them.
- Use a prefix such as `[FE]`, `[BE]`, `[ADF]`, or an emoji only when the target bucket uses that convention. Prefixes vary between projects.

## Description

- Start with the problem or required change. Add the reason or expected result when it helps define the work.
- Keep small tasks and child tickets brief. One short paragraph is often enough before the acceptance criteria.
- For larger work, add only useful sections, such as Background, Goal, Scope, Out of scope, and Dependencies.
- Use a list for several changes, investigation questions, or criteria. Use numbered steps for reproduction or a required sequence.
- For a bug, state the visible fault and its effect. Add Steps to reproduce, Expected, and Actual when the evidence supports them. Keep cause separate from observation unless the cause is known.
- For an investigation, state the question, what to inspect, and the expected result of the investigation.
- Keep code identifiers exact. Use inline code for APIs, package names, paths, commands, and values. Use code blocks for exact commands or examples.
- Add direct links to useful code, designs, documentation, related tickets, or failed runs. Use screenshots or other supplied media when they show the fault.
- Keep imported advisory text and standard checklists out of a small task unless that content is needed to perform it.

## Acceptance criteria

Always include the list required by the user, even when similar old tickets omit it. Write observable results with one result per item. The two populated criteria fields in the sample use bullet lists. Empty Given/When/Then prompts are template text, not a style rule.

For example, use a short task statement followed by criteria such as:

```markdown
Add a theme switch to the settings page.

**Acceptance criteria**

- The user can select light or dark mode.
- The selected mode remains active after a page reload.
```

The example shows the writing style only. Derive actual criteria from the user's request and evidence. Put the list in the supported separate field when possible; otherwise, keep it in the description.

## Metadata

Use the current bucket to select applicable labels, components, categories, and parent relationships. Historical values can reflect later delivery work or automation. Completed status, resolution, release labels, assignees, and estimates are not creation defaults.
