---
name: web-navigation
description: General guidelines for agentic navigation through complex web applications. Use when an agent interacts with, tests, or automates a web app through a browser, regardless of the browser-automation tooling in use.
---

# Web application navigation

Use these rules when you drive a web application through a browser tool.

## Browser selection

1. Use an integrated browser or preview tool for routine navigation and DOM inspection.
2. Use a connected Chrome debugging session when the task needs the user's signed-in session, extensions, or live tab state.
3. Use Playwright automation for repeatable test flows or when integrated tools lack reliable selectors and waits.

Keep one browser tool and session for the task unless that tool fails to complete the step.

## Selectors

Use stable, scoped selectors in this order:

1. Role and accessible name, or the associated form label.
2. Stable test attributes such as `data-testid`.
3. Visible text scoped to the container element.
4. Stable CSS attributes or structure.
5. XPath only when no other selector works.

Do not use generated class names, generated IDs, positional selectors, or unscoped text matches.

## Inspection and waiting

- Read the DOM or accessibility tree for text, structure, state, and element presence. Take a screenshot only to verify layout, visual rendering, or `<canvas>` content.
- Re-inspect the page after each navigation, asynchronous update, or action that changes the DOM. Do not chain actions from a stale snapshot.
- Wait for an explicit UI state (an element appears, a status changes, a dialog closes, or a control becomes enabled) and wait while a spinner, skeleton, or overlay covers the target. Do not rely on global network-idle or fixed sleeps.

## Guardrails and recovery

- **Authentication**: Never handle passwords, tokens, or MFA codes, and never sign in for the user. When a page needs authentication, stop and ask the user to sign in. When they reply, inspect the page again before you act.
- **Mutation safety**: Change data on a site only when the user asks you to change it. Ask for confirmation before any destructive or high-impact action that the user did not explicitly approve.
- **Recovery**: If an action gives an unexpected result, inspect the URL, DOM state, console errors, and failed network requests (without exposing secrets) to see whether the action already took effect. Retry only when the action is idempotent or did not take effect.
- **Stop condition**: Ask the user and wait idle when blocked by authentication, missing permission, an ambiguous choice, an unapproved high-impact action, or two failed attempts at the same step.

## Report

Finish when you verify the expected end state or hit a blocker. Report the flow that you ran, the verified final state, any errors or unverified outcomes, and any blocker.
