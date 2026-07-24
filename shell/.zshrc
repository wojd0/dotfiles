export RBENV_ROOT=$HOME/.rbenv
export PATH=$RBENV_ROOT/shims:/versions:$PATH
# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"
autoload -Uz compinit && compinit


# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

plugins=()
while read -r plugin_name _; do
  [[ -z "$plugin_name" || "$plugin_name" == \#* ]] && continue
  plugins+=("$plugin_name")
done < "$HOME/.oh-my-zsh-plugins"

if [[ -r "$ZSH/oh-my-zsh.sh" ]]; then
  source "$ZSH/oh-my-zsh.sh"
fi

# Git alias completion with substring branch matching (e.g. gco cleanup<Tab>)
compdef _git gco=git-checkout gcb='git checkout -b' gcor='git checkout --recurse-submodules'

_git_patch_substring_branch_completion() {
  [[ -n $functions[__git_refs_orig] || -z $functions[__git_refs] ]] && return

  functions[__git_refs_orig]=$functions[__git_refs]
  functions[__git_heads_orig]=$functions[__git_heads]

  __git_heads() {
    emulate -L ksh
    local pfx="${1-}" cur_="${2-}" sfx="${3-}"

    if [[ -n $cur_ ]]; then
      local b
      while IFS= read -r b; do
        [[ $b == *${cur_}* ]] && print -r -- "${pfx}${b}${sfx}"
      done < <(command git for-each-ref --format='%(refname:strip=2)' refs/heads/ 2>/dev/null)
      return
    fi

    __git_heads_orig "$@"
  }

  __git_refs() {
    emulate -L ksh
    local remote="${1-}" track="${2-}" pfx="${3-}" cur_="${4-$cur}" sfx="${5-}"
    local match="${4-}"

    if [[ -z $remote && -n $match && $cur_ != *'refs'* ]]; then
      __git_find_repo_path 2>/dev/null
      if [[ -n $__git_repo_path ]]; then
        local b
        while IFS= read -r b; do
          [[ $b == *${match}* ]] && print -r -- "${pfx}${b}${sfx}"
        done < <(command git for-each-ref --format='%(refname:strip=2)' refs/heads/ refs/tags/ 2>/dev/null)
        [[ -n $track ]] && __git_dwim_remote_heads "$pfx" "$match" "$sfx"
        return
      fi
    fi

    __git_refs_orig "$@"
  }
}

autoload -Uz _git
_git 2>/dev/null
_git_patch_substring_branch_completion

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

alias bn=pnpm

# often aliases
alias bs='bun start'
alias bss='bun start studio-hxp'
alias bsa='bun start admin-hxp'
alias bsw='bun start workspace-hxp'
alias cldx='claude --allow-dangerously-skip-permissions'
alias cldh='claude --allow-dangerously-skip-permissions --effort high'
alias cldmax='claude --allow-dangerously-skip-permissions --effort max'

# use nvm if there is a .nvmrc file here
if [[ -f ".nvmrc" ]] && command -v nvm >/dev/null 2>&1; then
  nvm use > /dev/null
fi

# packs n' tokens
if command -v python3 >/dev/null 2>&1; then
  export PATH="$PATH:$(python3 -m site --user-base)/bin"
fi

if command -v npm >/dev/null 2>&1; then
  export PATH="$PATH:$(npm config get prefix)/bin"
fi



export BUN_INSTALL="$HOME/.bun" 
export PATH="$BUN_INSTALL/bin:$PATH" 

alias bb=bun
alias bx="bun x"
alias bxx="bun x nx"
alias pnpmi="pnpm install --no-lockfile"
alias buni="START=\$(date +%s.%N) && bun install; sleep 1; rm -f bun.lock && END=\$(date +%s.%N) && echo \"Installation complete in \$(echo \"\$END - \$START\" | bc -l | xargs printf \"%.3f\")s 🏎️\""

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

ZSH_THEME_GIT_PROMPT_PREFIX="@ %F{magenta}"
ZSH_THEME_GIT_PROMPT_SUFFIX=" "
ZSH_THEME_GIT_PROMPT_DIRTY=" %F{reset_color}✗"
ZSH_THEME_GIT_PROMPT_CLEAN=" %F{reset_color}✔"
 
# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# gpg signing
export GPG_TTY=$(tty)

export PATH=$PATH:$HOME/.spicetify
export PATH="$HOME/.local/bin:$PATH"


### MANAGED BY RANCHER DESKTOP START (DO NOT EDIT)
export PATH="$HOME/.rd/bin:$PATH"
### MANAGED BY RANCHER DESKTOP END (DO NOT EDIT)

# mtr
alias mtr='sudo mtr'

bindkey "\e\e[C" forward-word
bindkey "\e\e[D" backward-word
# OR sometimes these are needed instead:
bindkey "^[[1;3C" forward-word
bindkey "^[[1;3D" backward-word

# opencode
export PATH=$HOME/.opencode/bin:$PATH

if [ -f "$HOME/.secrets" ]; then
  source "$HOME/.secrets"
fi

export GHCR_USERNAME="$GITHUB_USERNAME"
export GIT_CONFIG_COUNT=2
export GIT_CONFIG_KEY_0="user.name"
export GIT_CONFIG_VALUE_0="$GITHUB_USERNAME"
export GIT_CONFIG_KEY_1="user.email"
export GIT_CONFIG_VALUE_1="$GITHUB_EMAIL"

if [ -f "$HOME/.zshrc.local" ]; then
  source "$HOME/.zshrc.local"
fi
