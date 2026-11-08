# dotfiles

Public-safe dotfiles managed with GNU Stow.

## Structure

- shell: zsh and shell startup files
- git: git configuration
- `.agents`: canonical rules, sub-agent definitions, shared skill references, MCP configuration, and the tracked skills from `skills-lock.json`
- `skills`: tracked custom skill sources linked into `.agents/skills`
- local: tracked machine configuration plus a template for gitignored secrets
- cron: crontab entries and the jobs they run
- scripts: helper scripts

## Bootstrap

1. Clone this repo into your home directory as dotfiles.
2. Run `./setup.sh` to install GNU Stow, Bun, pre-commit, the GitHub CLI, GnuPG, `fzf`, `jq`, Oh My Zsh, and the configured Oh My Zsh plugins, then link and configure the dotfiles.
   - The install script uses the first package manager that it finds, in this order:
     1. Homebrew.
     2. APT. Bun is installed with its official install script.
     3. winget, on Windows only. Winget does not provide GNU Stow, Zsh, or pre-commit, so install them manually.
   - If the script finds no package manager, it installs Homebrew.
   - The verification script checks the skill layout before Stow links it.
   - Claude compatibility links point `~/.claude/rules`, `~/.claude/skills`, and `~/.claude/agents` to the canonical `.agents` directories.
   - A Codex compatibility link points `~/.codex/agents` to `.agents/agents`.
   - This creates `~/.secrets` from the tracked example when it is missing.
   - Existing secrets remain in the home directory and are never managed by Stow.
   - The `local` Stow package links only public-safe machine configuration into your home directory.
   - `~/d/.tmp-codebases` is created for temporary clones and worktrees.
   - The cron jobs from `cron/crontab` are installed into your user crontab.
3. Fill in the secret values.

## Update

Run `./scripts/update.sh` to get the latest changes and apply them. The script does these steps:

1. It stops if the working tree has local changes.
2. It runs `git pull --rebase`.
3. If the install files changed, it runs `./setup.sh`. Otherwise, it runs `./scripts/stow.sh`, and it runs `./scripts/cron.sh` when `cron/` changed.
4. It runs `./scripts/verify-agents.sh`.
5. If `shell/` changed, it tells you to start a new shell.

## Windows agent sync

On Windows, run `.\scripts\sync-agents.ps1` to install only the agent configuration. The script does not install packages and does not touch the `shell`, `git`, `local`, or `cron` packages. It does these steps:

1. It runs `git pull --ff-only` when the working tree is clean. Use `-NoPull` to skip this step.
2. It checks that each skill from `skills-lock.json` is tracked in `.agents/skills`.
3. It links `.agents` into `~/.agents`, and links each lock-managed and custom skill into `~/.agents/skills`.
4. It links `rules`, `agents`, `skills`, and `CLAUDE.md` into `~/.claude`, and `agents` into `~/.codex`.

Directories become junctions and files become hard links, so the script needs no administrator rights. A git pull breaks the hard links, so run the script again after each pull. The script moves a changed file that it does not manage to `<name>.bak-<timestamp>`. It skips a skill directory that another installer owns.

## GPG commit signing

Run `./scripts/setup-gpg-signing.sh` from a terminal after installing the
dependencies. The interactive menu can create or register a signing key, remove
one, or configure existing keys for dev-container use. Creating or registering
a key reuses local key material when possible, configures your personal Git
identity in `~/.gitconfig.local`, authenticates the GitHub CLI when needed,
uploads the public key, and verifies the result with a temporary signed commit.
Removing a key shows its user ID, fingerprint, creation date, and expiration
date before selection, deletes it from GitHub and the local GPG keyring, and
clears Git signing settings when that key is currently configured. Registration
is safe to rerun when the key is already present. Enter `q` at any script prompt
to quit without continuing the current action.

The configure-only menu option applies the Satori hardening to existing keys
without creating, uploading, or deleting key material. It prompts for the
default key when multiple signing keys are available, enables signed commits
and tags, and performs two signing operations to confirm that each one requires
a separate pinentry approval.

Run the setup on the host, not inside a dev container. On macOS it configures
`pinentry-mac`, disables GPG agent and Keychain passphrase caching, and offers
to remove existing saved GPG passphrases. On Linux it selects an installed GUI
or terminal pinentry program. Both platforms disable GPG agent passphrase
caching. Git intentionally does not set an absolute `gpg.program`, so each
environment resolves its own `gpg` executable.

`install.sh` installs the required tools and Zsh plugins. It preserves an existing
Oh My Zsh installation and can be rerun safely. 

`stow.sh` performs all dotfile
and skill setup.

Oh My Zsh plugins are declared in `shell/.oh-my-zsh-plugins`. Each line contains
a plugin name and, for plugins not bundled with Oh My Zsh, its Git repository
URL. `scripts/oh-my-zsh.sh` validates the list and clones external entries,
while `.zshrc` generates its `plugins` array from the same ordered list. The
plugin installer can also be run independently after changing the manifest.

## Cron jobs

`scripts/cron.sh` writes the entries from `cron/crontab` into your user crontab
between `# BEGIN dotfiles cron` and `# END dotfiles cron`. Each run replaces
that block and keeps every other entry, so rerun it after editing
`cron/crontab`. The block sets `DOTFILES_DIR` to this repository and
`DOTFILES_LOG_DIR` to `~/.local/state/dotfiles`, where jobs append their output
to `cron.log`. On macOS, the first install can ask to let your terminal
administer the computer.

`cron/clean-tmp-codebases.sh` runs at 10:00 and 16:00. It removes each clone
or worktree in `~/d/.tmp-codebases` whose top directory was last modified over
3 days ago, then the parent directories that removal leaves empty. Worktrees
go through `git worktree remove --force`, which also unregisters them from
their main repository; a locked worktree stays until it is unlocked. Run
`touch <path>` to keep a codebase for another 3 days.

## Docker test environment

With Docker running, execute `./scripts/docker-test.sh` to build a clean Linux
fresh-machine image and run the complete Stow setup plus its validation checks.
The image provisions Zsh, Oh My Zsh with the configured plugins, Bun, Node/npm,
Python, rbenv, fzf, jq, and the GitHub CLI. Use
`./scripts/docker-test.sh shell` to run the setup and then open an interactive
Zsh shell in that container. Populated local configuration files are excluded
from the image build context.

## Claude Code cloud environment

A cloud session does not read the local `~/.claude` directory. Put these lines
in the setup script field of the cloud environment:

```bash
#!/bin/bash
set -euo pipefail
git clone --depth 1 https://github.com/wojd0/dotfiles.git "$HOME/dotfiles"
"$HOME/dotfiles/scripts/cloud-setup.sh"
```

`scripts/cloud-setup.sh` links
`~/.agents` to the `.agents` directory of the clone, and creates the Claude
compatibility links in `~/.claude`. It does not install Homebrew, Stow the
`shell`, `git`, or `local` packages, or install the cron jobs. The environment
keeps the result of the setup script, so a later push to this repository
arrives only when the environment runs the script again.

## Secrets

- Running `./scripts/stow.sh` creates `~/.secrets` from `local/.secrets.example` only when it is missing.
- Any existing `~/.secrets`, including a symlink from an older installation, is left unchanged.
- The file is prefilled with the required secret variable names and empty values for you to fill in.
- `~/.secrets` is sourced automatically by `.zshrc`, exposing the values as environment variables in every shell.
- `GITHUB_USERNAME` supplies both the GitHub Packages username and Git
  `user.name`; `GITHUB_EMAIL` supplies Git `user.email`. Starting Zsh writes
  non-empty values to `~/.gitconfig.local`.
- New secrets files stay outside the repository; only `local/.secrets.example` is tracked.
- The tracked `local/.npmrc` reads registry tokens from those environment variables.

## Agent configuration

- `.agents` is the canonical runtime location for agent rules, skills, and MCP configuration.
- Tracked custom skill sources live at repository-root `skills/` and are linked into `.agents/skills`.
- The skills in `skills-lock.json` are tracked as real directories in `.agents/skills`. Setup does not download them.
- Each skill in `skills-lock.json` has a tracked link in `.claude/skills` to its `.agents/skills` directory.
- To add or update a third-party skill, run `bun x skills add <source> -a codex -a claude-code` or `bun x skills update` at the repository root. Then commit `.agents/skills`, `.claude/skills`, and `skills-lock.json`.
- `./scripts/verify-agents.sh` fails if a tracked skill is not in `skills-lock.json` or `skills/`, or if a link is missing.
- Provider-specific runtime directories contain compatibility links only; they are not separate Stow packages.
- Claude's `rules`, `skills`, and `agents` paths are linked automatically because Claude does not read `.agents` directly.
- Sub-agent definitions live in `.agents/agents`. Each sub-agent has a canonical `<name>.md` file in the Claude Code sub-agent format. A `<name>.toml` Codex role file beside it points Codex to the same Markdown file. `~/.codex/agents` links to this directory.
