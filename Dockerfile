FROM oven/bun:1-debian

RUN apt-get update \
  && apt-get install --yes --no-install-recommends \
    build-essential \
    ca-certificates \
    curl \
    fzf \
    gh \
    git \
    jq \
    npm \
    python3 \
    rbenv \
    ruby-build \
    stow \
    zsh \
  && rm -rf /var/lib/apt/lists/*

RUN useradd --create-home --shell /usr/bin/zsh dotfiles

WORKDIR /workspace/dotfiles
COPY --chown=dotfiles:dotfiles . .

ENV HOME=/home/dotfiles
USER dotfiles

RUN git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh" \
  && ./scripts/oh-my-zsh.sh

CMD ["zsh", "-lc", "./scripts/stow.sh && ./scripts/verify-agents.sh && test -L \"$HOME/.zshrc\" && test -L \"$HOME/.gitconfig\" && test \"$HOME/.claude/rules\" -ef \"$HOME/.agents/rules\" && test \"$HOME/.claude/skills\" -ef \"$HOME/.agents/skills\" && zsh -ic 'for tool in zsh rbenv python3 npm bun fzf gh jq; do command -v \"$tool\" >/dev/null || exit 1; done' && echo 'dotfiles setup passed'" ]
