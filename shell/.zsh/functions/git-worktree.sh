gcbw() {
  if (( $# != 1 )); then
    print -u2 "usage: gcbw <branch-name>"
    return 2
  fi

  local branch_name="$1"
  local default_ref=""
  local remote
  local repo_root
  local repo_name
  local worktree_root
  local worktree_path
  local worktree_listing
  local -a remotes

  worktree_listing=$(command git worktree list --porcelain 2>/dev/null) || {
    print -u2 "gcbw: not inside a Git repository"
    return 1
  }
  repo_root="${worktree_listing%%$'\n'*}"
  repo_root="${repo_root#worktree }"

  command git check-ref-format --branch "$branch_name" >/dev/null || return 1

  remotes=(origin ${(f)"$(command git remote 2>/dev/null)"})
  for remote in "${remotes[@]}"; do
    default_ref=$(command git symbolic-ref --quiet --short "refs/remotes/$remote/HEAD" 2>/dev/null)
    [[ -n "$default_ref" ]] && break
  done

  if [[ -z "$default_ref" ]]; then
    for default_ref in main master; do
      command git show-ref --verify --quiet "refs/heads/$default_ref" && break
      default_ref=""
    done
  fi

  if [[ -z "$default_ref" ]]; then
    print -u2 "gcbw: could not determine the repository default branch"
    return 1
  fi

  repo_name="${repo_root:t}"
  worktree_root="${repo_root:h}/.${repo_name}-worktrees"
  worktree_path="$worktree_root/${branch_name:t}"

  if [[ -e "$worktree_path" ]]; then
    print -u2 "gcbw: worktree path already exists: $worktree_path"
    return 1
  fi

  command mkdir -p "$worktree_root" || return 1
  command git worktree add -b "$branch_name" "$worktree_path" "$default_ref"
}
