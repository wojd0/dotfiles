
for brew_bin in /opt/homebrew/bin /home/linuxbrew/.linuxbrew/bin /usr/local/bin; do
  if [[ -x "$brew_bin/brew" ]]; then
    eval "$("$brew_bin/brew" shellenv)"
    break
  fi
done
unset brew_bin
