# dotfiles

Public-safe dotfiles managed with GNU Stow.

## Structure

- shell: zsh and shell startup files
- git: git configuration
- `.agents`: canonical rules, MCP configuration, and generated lock-managed skills
- `custom-skills`: tracked custom skill sources linked into `.agents/skills`
- local: tracked machine configuration plus a template for gitignored secrets
- scripts: helper scripts

## Bootstrap

1. Clone this repo into your home directory as dotfiles.
2. Run `./scripts/install.sh` to install Homebrew (when needed), GNU Stow, Bun, pre-commit, the GitHub CLI, GnuPG, `fzf`, Oh My Zsh, and the configured Oh My Zsh plugins.
3. Run `./scripts/stow.sh`.
   - Skills from `skills-lock.json` are restored with Bun.
   - Custom skills from `custom-skills/` are linked into `.agents/skills`.
   - Claude compatibility links point `~/.claude/rules` and `~/.claude/skills` to the canonical `.agents` directories.
   - This creates `~/.secrets` from the tracked example when it is missing.
   - Existing secrets remain in the home directory and are never managed by Stow.
   - The `local` Stow package links only public-safe machine configuration into your home directory.
4. Fill in the secret values.

## GPG commit signing

Run `./scripts/setup-gpg-signing.sh` from a terminal after installing the
dependencies. The interactive setup creates or reuses a GPG signing key,
configures your personal Git identity in `~/.gitconfig.local`, authenticates
the GitHub CLI when needed, uploads the public key, and verifies the result with
a temporary signed commit. It is safe to rerun when the key is already present.

`install.sh` installs the required tools and Zsh plugins. It preserves an existing
Oh My Zsh installation and can be rerun safely. `stow.sh` performs all dotfile
and skill setup.

Oh My Zsh plugins are declared in `shell/.oh-my-zsh-plugins`. Each line contains
a plugin name and, for plugins not bundled with Oh My Zsh, its Git repository
URL. `scripts/oh-my-zsh.sh` validates the list and clones external entries,
while `.zshrc` generates its `plugins` array from the same ordered list. The
plugin installer can also be run independently after changing the manifest.

## Docker test environment

With Docker running, execute `./scripts/docker-test.sh` to build a clean Linux
fresh-machine image and run the complete Stow setup plus its validation checks.
The image provisions Zsh, Oh My Zsh (including `fzf-tab`), Bun, Node/npm,
Python, rbenv, fzf, and the GitHub CLI. Use
`./scripts/docker-test.sh shell` to run the setup and then open an interactive
Zsh shell in that container. Populated local configuration files are excluded
from the image build context.

## Secrets

- Running `./scripts/stow.sh` creates `~/.secrets` from `local/.secrets.example` only when it is missing.
- Older installations where `~/.secrets` links to `local/.secrets` are migrated to a regular home-directory file.
- The file is prefilled with the required secret variable names and empty values for you to fill in.
- `~/.secrets` is sourced automatically by `.zshrc`, exposing the values as environment variables in every shell.
- `GITHUB_USERNAME` supplies both the GitHub Packages username and Git `user.name`; `GITHUB_EMAIL` supplies Git `user.email`.
- The real `~/.secrets` file stays outside the repository; only `local/.secrets.example` is tracked.
- The tracked `local/.npmrc` reads registry tokens from those environment variables.

## Agent configuration

- `.agents` is the canonical runtime location for agent rules, skills, and MCP configuration.
- Tracked custom skill sources live at repository-root `custom-skills/` and are linked into `.agents/skills`.
- Provider-specific runtime directories contain compatibility links only; they are not separate Stow packages.
- Claude's `rules` and `skills` paths are linked automatically because Claude does not read `.agents` directly.
