---
name: cloudsmith-backfill
description: Backfill Cloudsmith with the npm package versions that a HylandSoftware repository already published to GitHub Packages. Use when the user wants previous or old releases available on Cloudsmith, or wants to copy or migrate published versions from GitHub Packages to Cloudsmith.
---

# Cloudsmith backfill

The backfill copies each published tarball from GitHub Packages to Cloudsmith with a one-off GitHub Actions workflow. The workflow does not build anything, so each version keeps its sha512 integrity. The template is [`assets/cloudsmith-backfill.yml`](assets/cloudsmith-backfill.yml). Its comments explain each step.

## Reference implementation

The first backfill was for `@hylandsoftware/satori-icons` (46 versions, ticket DS-2770). Its branch is the reference. Keep that branch, and compare with it when a step gives an unexpected result.

- Branch: [`build/DS-2770-cloudsmith-backfill`](https://github.com/HylandSoftware/satori-icons/tree/build/DS-2770-cloudsmith-backfill) in `HylandSoftware/satori-icons`.
- Workflow: [`.github/workflows/cloudsmith-backfill.yml`](https://github.com/HylandSoftware/satori-icons/blob/build/DS-2770-cloudsmith-backfill/.github/workflows/cloudsmith-backfill.yml). It uses the local `.github/actions/cloudsmith-auth` action of that repository. The template has the same Cloudsmith auth inline.
- Commits: [branch history](https://github.com/HylandSoftware/satori-icons/commits/build/DS-2770-cloudsmith-backfill). The last two commits show step 4: add the temporary `push` trigger, then remove it.
- Runs: the [registration run](https://github.com/HylandSoftware/satori-icons/actions/runs/39422703879) (skipped), the [dry run](https://github.com/HylandSoftware/satori-icons/actions/runs/39422830666), and the [real run](https://github.com/HylandSoftware/satori-icons/actions/runs/39423326495). Use their logs to see the expected log lines of steps 5 and 6. GitHub deletes run logs after the retention period of the repository.

To read the reference workflow, run:

```bash
gh api "repos/HylandSoftware/satori-icons/contents/.github/workflows/cloudsmith-backfill.yml?ref=build/DS-2770-cloudsmith-backfill" --jq .content | base64 -d
```

## Rules

- Publish only from GitHub Actions through OIDC. A personal Cloudsmith API key cannot publish to `cic-unified-shared-libs`. Only the `cloudsmith-cic-unified-shared-libs-service-write` team has write access, and it holds only OIDC service accounts.
- Get an explicit "yes" from the user before each of these actions: commit, push, start a workflow run, and delete a branch.
- Start each real run only after a dry run of the same package passed.

## Steps

### 1. Collect the facts

Find these four values in the target repository. Step 1 is complete when you know all four.

- **Package**: the `name` in `package.json`. In a monorepo, list each package published to GitHub Packages and ask the user which ones to copy.
- **Cloudsmith registry URL**: the Cloudsmith npm URL in `.npmrc` or in the publish workflow, for example `https://npm.artifacts.hyland.dev/cic-unified-shared-libs/`. It must end with `/`.
- **Cloudsmith OIDC setup**: a workflow that uses `cloudsmith-io/cloudsmith-cli-action` with `vars.CLOUDSMITH_NAMESPACE`. If the repository has none, stop. Tell the user to add the repository to the Cloudsmith write allowlist first ("Self-Service: Add Your Repository to Cloudsmith Access" in Confluence).
- **Base branch**: the default branch. If the Cloudsmith OIDC setup exists only on an unmerged branch, the template still works from the default branch, because it does not use repository files.

### 2. Count the versions and confirm the backfill

Do this step before you make a branch or a file.

1. Run this, with `<package>` replaced. If npm returns 401 or 403, run `gh auth refresh -h github.com -s read:packages` and try again.

   ```bash
   D=$(mktemp -d) && printf '//npm.pkg.github.com/:_authToken=%s\n' "$(gh auth token)" > "$D/npmrc" && (cd "$D" && npm --userconfig "$D/npmrc" view <package> versions dist-tags --json --registry=https://npm.pkg.github.com/); rm -rf "$D"
   ```

2. Send the user one confirmation message with these facts:
   - The package and the Cloudsmith registry URL.
   - The number of versions on GitHub Packages, and the list of all the versions.
   - The `latest` and `next` dist-tags, and the prereleases. The workflow gives `latest` and `next` to the same versions on Cloudsmith.
   - The branch name for step 3.
3. Wait for a "yes".

The step is complete when the user approved the backfill of that number of versions.

### 3. Make the branch and the workflow

1. Make a branch from the base branch. Follow the branch names in `git log` of the repository, for example `build/<TICKET>-cloudsmith-backfill`.
2. Copy the template to `.github/workflows/cloudsmith-backfill.yml`.
3. Replace `__PACKAGE__`, `__CLOUDSMITH_REGISTRY__`, and `__BRANCH__`.
4. If the repository pins `actions/setup-node` to a different SHA, or uses a different Node.js major version in `.nvmrc`, use the values of the repository.
5. Show the file to the user and wait for approval.

### 4. Register the workflow

GitHub starts a `workflow_dispatch` workflow from a branch only after the workflow ran once. The temporary `push` trigger gives that run, and the job `if` skips the job in it.

1. Commit with the `commit-message-format` skill and push.
2. Run `gh run list --branch <branch> --workflow cloudsmith-backfill.yml --limit 1 --json event,conclusion`. The step is complete when the result shows `"event":"push"` and `"conclusion":"skipped"`.
3. Remove the `push` block and its comment from `on:`. Keep the job `if`.
4. Commit and push.

### 5. Do the dry run

1. Start it: `gh workflow run cloudsmith-backfill.yml --ref <branch> -f dry-run=true -f package=<package>`.
2. Wait for it: `gh run watch <run-id> --exit-status`.
3. Save the log with `gh run view <run-id> --log > <scratchpad>/dry-run.log`, then count these lines:
   - `Z copy    ` (the planned copies)
   - `Z skip    ` (the versions that Cloudsmith already has)
   - `Z Integrity OK: sha512` (the integrity checks)
   - `npm notice Publishing to <Cloudsmith registry URL>` (the dry-run publishes)
   - `##[error]` and `npm error`

The dry run passed when the copies plus the skips equal the version count from step 2, each copy has one integrity check and one publish, and there are no errors. Report these numbers and the dist-tag of each version that gets `latest` or `next`. Tell the user that a dry run does not prove write access.

### 6. Do the real run

1. Get a "yes" from the user.
2. Start it: `gh workflow run cloudsmith-backfill.yml --ref <branch> -f dry-run=false -f package=<package>`.
3. Wait for it and save its log the same way as in step 5.
4. Count the lines `Z + <package>@`. The real run passed when that count equals the planned copies and the step "Remove the temporary backfill dist-tag" shows `-backfill:`.

If the first publish fails with 401 or 403, the repository is not on the Cloudsmith write allowlist. Stop and tell the user (see step 1).

For each other package in a monorepo, do steps 5 and 6 again with a different `package` input.

### 7. Clean up

Offer the user these actions, then do only the ones that they approve:

1. Do one more dry run after a few minutes. It shows each version as `skip` if Cloudsmith has all of them.
2. Delete the branch. The workflow is not on the default branch, so this removes the workflow completely. Keep the reference branch in `HylandSoftware/satori-icons`.
