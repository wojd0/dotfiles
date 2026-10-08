# .agents in dotfiles

This root directory is the canonical runtime source for portable agent configuration.

- `AGENTS.md` contains global instructions and the glossary.
- `rules/` contains shared instructions.
- `skills/` contains restored third-party skills plus links to root `custom-skills/`.
- `references/` contains procedures that several skills read by their `~/.agents/references/` path.
- `mcp.json` contains shared MCP configuration.

The Stow script creates Claude compatibility links at `~/.claude/rules`,
`~/.claude/skills`, and `~/.claude/CLAUDE.md` (to `AGENTS.md`). No provider-specific configuration is maintained separately.
