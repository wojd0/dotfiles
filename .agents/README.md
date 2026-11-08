# .agents in dotfiles

This root directory is the canonical runtime source for portable agent configuration.

- `AGENTS.md` contains global instructions and the glossary.
- `rules/` contains shared instructions.
- `skills/` contains the tracked third-party skills from `skills-lock.json` plus links to the root `skills/` directory.
- `agents/` contains sub-agent definitions. `<name>.md` holds the instructions in the Claude Code format, and `<name>.toml` is the Codex role file that points to it.
- `references/` contains procedures that several skills read by their `~/.agents/references/` path.
- `mcp.json` contains shared MCP configuration.

The Stow script creates Claude compatibility links at `~/.claude/rules`,
`~/.claude/skills`, `~/.claude/agents`, and `~/.claude/CLAUDE.md` (to `AGENTS.md`), and a Codex compatibility link at `~/.codex/agents`. No provider-specific configuration is maintained separately.
