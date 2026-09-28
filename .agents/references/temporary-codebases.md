# Temporary codebases

A temporary codebase is a clone or worktree under `~/d/.tmp-codebases`, checked out detached at one commit. A cron job deletes each one whose top directory has gone 3 days unmodified, and `touch` restarts that clock. Detached checkouts leave no local branch behind when it does.

## Pinning a checkout

The calling skill supplies the repository `<owner>/<repo>`, the commit `<sha>`, the `<refs>` to fetch, and a `<name>`; the temporary codebase lives at `<path>`, which is `~/d/.tmp-codebases/<name>`. Use the first checkout that applies:

1. The workspace, or one of its `git worktree list` entries, when a remote points at `<owner>/<repo>` and it sits at `<sha>` with a clean working tree: fetch `<refs>` there.
2. An existing `<path>`: `touch` it, fetch `<refs>` there, and run `git checkout --detach <sha>`.
3. A new worktree, when the workspace is a clone of `<owner>/<repo>`: `git fetch <remote> <refs>`, then `git worktree add --detach <path> <sha>`.
4. A new clone: `gh repo clone <owner>/<repo> <path> -- --filter=blob:none`, then `git -C <path> fetch origin <refs>` and `git -C <path> checkout --detach <sha>`.

When a sandboxed write under `~/d/.tmp-codebases` is denied, rerun it outside the sandbox.

Done when `git rev-parse HEAD` in the checkout prints `<sha>`.
