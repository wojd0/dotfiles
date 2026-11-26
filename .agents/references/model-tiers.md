# Model tiers

A skill names a **tier** for each role, not a model. The agent definitions in `~/.agents/agents/` bind each tier to a model and an effort level for each runtime. This file is the single source of truth for the tiers and their bindings.

## Tiers

| Tier | Use it for | Effort |
|---|---|---|
| `light` | Mechanical work: collect files, summarize a log, count lines, run a fixed command. | `medium` |
| `standard` | Most work: research, implementation, review on one axis, orchestration of a loop. | `medium` |
| `deep` | Work that failed on `standard`, or adversarial checks that need judgement. | `high` |
| `top` | Escalation only: diagnose a dead end, or settle a conflict between two agents. | `high` |

Use the lowest tier that can do the job. Move one tier up only when a role fails on its tier, such as when a loop stalls. Do not use the lowest or the highest effort level of a runtime. The lowest level skips the checks that a role needs, and the highest level costs more time than it gives back.

## Models

| Tier | Claude | GPT | Gemini |
|---|---|---|---|
| `light` | `haiku` | `luna` | `gemini-4-hydrogen` |
| `standard` | `sonnet` | `sol` | `gemini-4-hydrogen` |
| `deep` | `opus` | `terra` | `gemini-4-neon` |
| `top` | `fable` | `astra` | `gemini-4-carbon` |

The Claude and GPT cells are model names without a version. Use the latest version of the model, so a new release needs no change here. The Gemini cells are model IDs. Update them when a new model family replaces them. For Gemini, the `light` and `standard` tiers use the same model.

## Bindings

| Tier | Claude Code `.md` frontmatter | Codex `.toml` keys |
|---|---|---|
| `light` | `model: haiku`, `effort: medium` | `model_reasoning_effort = "medium"` |
| `standard` | `model: sonnet`, `effort: medium` | `model_reasoning_effort = "medium"` |
| `deep` | `model: opus`, `effort: high` | `model_reasoning_effort = "high"` |
| `top` | `model: fable`, `effort: high` | `model_reasoning_effort = "high"` |

The Codex files set only the effort. The model comes from the parent session or from `default_subagent_model` in the Codex configuration. To bind a GPT model to a role, use the GPT model of its tier from the models table. To add a runtime, add one column here and the same keys to each agent definition.

## Rules for a skill

1. Write the tier of each role in the skill, such as "start the `loop-implementer` sub-agent (`standard` tier)".
2. If a role has no agent definition, and the runtime lets you select the model of a new sub-agent, select the model of the tier from the models table. Use the column of the model family that the runtime runs.
3. If the runtime cannot select a model or an effort level, start the sub-agent with the parent settings and continue.
4. To move a role one tier up for one run, select the model and effort of the higher tier when you start the sub-agent. Do not change the agent definition.
