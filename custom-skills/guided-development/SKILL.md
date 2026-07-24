---
name: guided-development
description: Interactive guided development workflow that breaks work into iterative steps with user choices, presenting numbered next-step options after each action. Use when: the user says "guided", "step by step", "guide me", "what should I do next", "walk me through", "help me think through", "let's work through this together"; the user wants an interactive development loop where they stay in control of decisions; the user wants to work through a complex feature or refactor incrementally; or the user explicitly wants to be presented with choices at each step rather than having the agent decide everything autonomously.
---

# Guided Development

## Starting a Session

If the user hasn't stated a task yet, ask:

> What's the job to be done? Describe the feature, bug, refactor, or task you'd like to work on.

Wait for the user's response before proceeding.

## Core Loop

Every turn follows this cycle:

1. **Understand** — clarify the current goal and gather context (use MCPs, search, read files).
2. **Act** — perform the agreed-upon work (code changes, research, analysis).
3. **Present next steps** — offer a numbered list of logical follow-up actions for the user to choose from.

Repeat until the user says they're done.

## Gathering Context

Before writing code, use all available information sources — MCP servers, codebase search, file reads. Check which MCPs and skills are currently available in the system prompt and use whichever are relevant to the task.

## Presenting Next Steps

After every response, end with a **numbered list** of 3–6 concrete next actions. Always include at least one "wrap-up" option. Format:

```
**What would you like to do next?**

1. <action description>
2. <action description>
3. <action description>
4. Finish up — commit, create PR, or wrap the session
```

Tailor options to the current state. Examples of good next-step categories:

| Category | Examples |
|----------|---------|
| Implement | Add error handling, implement the next component, wire up the service |
| Test | Write unit tests, run existing tests, add edge-case coverage |
| Validate | Run linter, check for regressions, verify in browser |
| Explore | Investigate related code, check Jira for linked issues, review Figma specs |
| Refactor | Extract shared logic, rename for clarity, simplify conditionals |
| Document | Update README, add JSDoc, update Confluence |
| Ship | Commit changes, create PR, push branch |

## Skill Awareness

Check the system prompt for available skills. When a next step maps to an available skill, activate it by reading and following its SKILL.md. Also consider available skills when generating next-step options — if a skill is relevant, surface it as a choice.

## Permission Boundaries

**Do freely:** read files, search code, query MCPs for information, analyze, suggest.

**Ask permission first:**
- Git commits
- Git push
- Creating pull requests
- Commenting on Jira/Confluence
- Creating or modifying Jira tickets
- Any action that writes to an external system

When suggesting these actions as next steps, make it clear the user is choosing to trigger them.

## Session Style

- Keep responses focused — do the work, then present choices.
- Don't over-explain what you're about to do; just do it and summarize what you did.
- When multiple approaches exist, briefly list trade-offs and let the user pick.
- Track progress mentally; reference completed steps when presenting next actions.
- If the user picks a step that maps to an available skill, activate that skill.
