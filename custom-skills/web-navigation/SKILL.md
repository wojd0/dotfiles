---
name: web-navigation
description: General guidelines for agentic navigation through Hyland web applications. Use when an agent interacts with, tests, or automates any Hyland web app (HxP shell, Content Cloud, Nuxeo, Alfresco, etc.) through a browser, regardless of the browser-automation tooling in use.
---

# Hyland Web Navigation

Guidelines for driving Hyland web applications through any browser-automation harness. These rules describe *what* to do; map each capability to whatever tools your harness exposes.

## Choose the Browser Capability

Use the best available capability for the task:

- Use an agent-native browser or preview for routine navigation and structural inspection when it supports the required interactions.
- Use a running Chrome session through a debugging client when the task depends on the user's authenticated session, extensions, or exact live state.
- Use Playwright-compatible automation for deterministic, repeatable flows or when the integrated options lack reliable selectors and waits.

Confirm the chosen capability is available before relying on it. Preserve an existing authenticated session and avoid switching tools unless the current one cannot complete the task reliably.

## Interaction Loop

For every interaction:

1. Inspect the current URL, page identity, target element, relevant state, dialogs, and blocking overlays.
2. Define the visible result expected from the next action.
3. Perform one click, fill, submission, or navigation.
4. Wait for the expected result and for its controls to become interactive.
5. Verify the resulting state before continuing.

Never chain actions from a stale page snapshot. Re-inspect after navigation, asynchronous updates, or any action that can replace or reorder content.

## Waiting for Hyland Applications

Hyland applications may use polling, streaming requests, or WebSockets, so global network-idle is not a reliable readiness signal.

- Prefer an explicit UI condition, such as an element appearing, a status changing, a dialog closing, or a control becoming enabled.
- If a relevant request is identifiable, combine its completion with the expected UI condition.
- Wait while a spinner, skeleton, or blocking overlay covers the target.
- Avoid fixed sleeps. If a condition times out, inspect the current state before deciding whether to retry.



## Selectors

Use stable, scoped selectors in this order:

1. Role plus accessible name, or an associated form label.
2. Stable test hooks such as `data-testid`.
3. Visible text scoped to the relevant region.
4. Stable CSS attributes or structure.
5. XPath only when no resilient alternative exists.

Avoid generated classes or IDs, positional selectors, and unscoped text matches.

## Structural and Visual Inspection

Use the DOM or accessibility tree for text, structure, state, and element presence. Use screenshots only when layout, rendering, canvas content, or another genuinely visual result must be verified.

After using a screenshot, record a concise note containing the page location, relevant visible state, and conclusion. At natural checkpoints, retain only the completed steps, current state, known issue, and next expected condition. Reduce trial-and-error history to the result that matters for the remaining work.

## User Involvement

Continue autonomously when the current state can be discovered safely. Ask the user only when blocked by:

- Authentication.
- A materially ambiguous choice.
- Missing permission.
- An irreversible or high-impact action that was not clearly authorized.
- Two similar failed attempts after applying the recovery process.

After asking, wait idle. Do not poll, set a timeout, or guess while waiting for the user's response.

## Authentication

Never handle credentials, authentication tokens, or MFA codes, and never attempt to log in on the user's behalf. When authentication is required, stop and ask the user to complete the flow in the browser. Resume only after they explicitly prompt you, then inspect the page again before acting.

## Mutation Safety

Do not ever modify any information on the site unless explictly instructed to do so. Confirm destructive or high-impact actions immediately before execution when they were not already explicitly authorized.

## Error Recovery

When an action produces an unexpected result:

1. Inspect the URL, page identity, DOM state, visible errors, dialogs, and target state. Determine whether the action already took effect.
2. When supported, inspect console errors and relevant failed network requests without exposing credentials, tokens, or sensitive payloads.
3. Classify the problem as transient loading, validation, authentication or permission, application failure, or stale targeting.
4. Retry only after re-inspection proves the operation is safe and either idempotent or did not take effect.
5. After two similar failures, stop and ask the user for help with a concise summary of the observed state and evidence.



## Completion

Finish only when the expected end state is verified or a blocker is established. Report:

- The flow exercised.
- The verified final state.
- Any errors or incomplete steps.
- Any assumptions or outcomes that could not be verified.
