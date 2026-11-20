---
name: project-setup
description: >-
  Sets up a repository for agents: project skills and a project MCP
  config. Use when the user asks to set up, onboard, or prepare a project
  for agents, or when a repository has no project MCP config.
---
# Project setup

The global agent configuration has no MCP servers. Each project gets its MCP servers only from its own config.

## Steps

1. Install the recommended skills in the project:
   1. Find the skills that match the stack of the project. Use the `find-skills` skill.
   2. Install each skill at the project scope under `.agents/skills/` (and any agent-compatibility link that the repository tracks), not at the global scope.
   3. Verify that `.agents/skills/` in the repository contains each installed skill.
2. Limit the MCP servers of the project:
   1. Add to the project MCP config (`.mcp.json` or `.agents/mcp.json`) only the domain MCP servers that the work in the project needs. Omit built-in harness servers that the runtime injects automatically.
   2. If the project needs no MCP server, keep an empty project MCP config: `{ "mcpServers": {} }`.
   3. If the agent must approve project servers, approve them in the project settings. A session that has no prompt cannot approve a server.
3. Read the project MCP config and list the active MCP servers of the project. The step is complete when the list shows each server from the project MCP config and no other domain server.
4. If a server needs authentication, tell the user to sign in to it.
