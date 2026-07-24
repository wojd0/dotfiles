# .agents in dotfiles

This root directory is the canonical runtime source for portable agent configuration.

- `rules/` contains shared instructions.
- `skills/` contains restored third-party skills plus links to root `custom-skills/`.
- `mcp.json` contains shared MCP configuration.

The Stow script creates Claude compatibility links at `~/.claude/rules` and
`~/.claude/skills`. No provider-specific configuration is maintained separately.
