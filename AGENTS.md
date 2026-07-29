# Repository Guidelines

## Project Structure & Module Organization

This repository manages public-safe dotfiles with GNU Stow. Each top-level package mirrors paths under `$HOME`:

- `shell/`: Zsh startup files (`.zshrc`, `.zshenv`).
- `git/`: global Git configuration, ignore rules, and commit template.
- `.agents/`: canonical portable rules, generated skills, and MCP configuration.
- `custom-skills/`: tracked custom skill sources linked into `.agents/skills`.
- `local/`: tracked, public-safe machine configuration plus gitignored secrets; only secrets use a tracked `.example` template.
- `scripts/`: bootstrap, Stow, and agent-verification utilities.
- `docs/`: verification, dependency, and release checklists.

Keep new configuration in the appropriate Stow package and preserve its intended home-directory path.

## Build, Test, and Development Commands

There is no compilation step. Validate changes from the repository root:

- `./scripts/stow.sh`: prepare the home-directory secrets file, link the `shell`, `git`, and `local` packages, and Stow `.agents` contents into `$HOME/.agents`.
- `stow -n -t "$HOME" shell git && stow -n -t "$HOME/.agents" .agents && stow -n --ignore='\.example$' --ignore='^\.secrets$' -t "$HOME" local`: preview links and detect conflicts without changing files.
- `./scripts/verify-agents.sh`: confirm the canonical agent layout and custom-skill links are valid.

## Coding Style & Naming Conventions

Shell scripts use Bash, two-space indentation, quoted variable expansions, and `set -euo pipefail`. Prefer small functions with descriptive `snake_case` names and uppercase names for constants. Keep dotfile syntax native to its tool. Name documentation with lowercase kebab-case, and reserve `.example` for secret templates.

## Testing Guidelines

Every change should pass agent verification. For shell changes, also run `zsh -i -c 'echo ok'`. For link-layout changes, run the Stow dry run and inspect its output for conflicts. New rules can be added directly under `.agents/rules` without registering their filenames in the verification script.

## Commit & Pull Request Guidelines

The repository has no commit history yet. Use short, imperative commit subjects, optionally scoped, such as `shell: simplify PATH setup`. Keep commits focused. Pull requests should explain the affected package, list validation commands run, and call out new external dependencies or manual setup. Include screenshots only for changes with visible UI impact.

## Security & Configuration

Never commit real credentials or populated `.secrets` files. Tracked configuration such as `.npmrc` must reference environment variables rather than contain tokens. Update `.secrets.example` with empty placeholders and follow `docs/public-release-checklist.md` before configuring a remote or publishing.
