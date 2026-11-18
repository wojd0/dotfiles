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
   2. Install each skill at the project scope, not at the global scope.
   3. Make sure that the installed skills are in the repository.
2. Limit the MCP servers of the project:
   1. Add to the project MCP config only the MCP servers that the work in the project needs.
   2. If the project needs no MCP server, keep an empty project MCP config: `{ "mcpServers": {} }`.
   3. If the agent must approve project servers, approve them in the project settings. A session that has no prompt cannot approve a server.
   4. Do not add the `t3-code` server. T3 Code adds it to its own sessions.
3. List the MCP servers of the project. The step is complete when the list shows each server from the project MCP config and no other server.
4. If a server needs authentication, tell the user to sign in to it.
