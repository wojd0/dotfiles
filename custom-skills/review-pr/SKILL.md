---
name: review-pr
description: Reviews a GitHub pull request with the code-review skill and adds the findings as brief line, file, and review-body comments to the user's pending (draft) review, leaving it unpublished.
disable-model-invocation: true
---

# Review a Pull Request

Review a pull request with the `code-review` skill, then turn its findings into comments in the user's pending review. The user edits and submits that review on GitHub, so each comment is written in their voice.

## Step 1: Pinning the pull request

The user gives a pull request link or branch. Read it with `gh pr view <link-or-branch> --json url,baseRefName,headRefOid`; the URL gives `<owner>/<repo>` and `<number>`. When a sandboxed `gh` call fails with `Forbidden` or an invalid token, rerun it outside the sandbox, where `gh` can read its keyring.

When possible, work in a local clone of that repository: the workspace, when one of its remotes points there. 
If you can't find a clone or worktree checked out to PR's branch (synced to the remote version), create a worktree named `review/<org>/<repo>/PR-number` (if already taken, use it) for the pull request's branch. 

Done when `<remote>/<baseRefName>` and `<headRefOid>` both resolve locally.

## Step 2: Running the code-review skill

Follow the `code-review` at `~/.agents/skills/code-review/SKILL.md` skill through its final report, passing it the pull request link or branch the user gave.

Done when both axes have reported, or the Spec axis reports that no spec is available.

## Step 3: Drafting the comments

Read what the pull request already holds:

- The user's pending review, from `gh api repos/<owner>/<repo>/pulls/<number>/reviews --paginate --jq '.[] | select(.state == "PENDING")'`, and its comments at `repos/<owner>/<repo>/pulls/<number>/reviews/<id>/comments`. GitHub keeps one pending review per user and pull request, so new comments join this one.
- The published review comments at `repos/<owner>/<repo>/pulls/<number>/comments`.

Check each finding against the head's code, then sort it:

- **Comment**: a defect or a worthwhile improvement in the diff.
- **Offer**: findings such as missing requirements or patterns in unchanged files, and minor preferences. The user decides on these once the comments are in.
- **Drop**: findings the code does not bear out, and findings the pending review or a published comment already raises.

The comment should sit on the line that has the problem. When the same problem sits on several lines, each gets the same comment. When the problem regards the entire file, it becomes a file comment on that file. When it is best described in the scope of the entire pull request, it becomes a review-body comment.

A line comment's anchor is its `path` and `line`, and GitHub accepts it only inside a diff hunk. This prints each file's head-side hunks as `path start-end`:

```bash
gh api "repos/<owner>/<repo>/pulls/<number>/files" --paginate --jq '.[] | .filename as $f | .patch // "" | scan("@@ -[0-9,]+ \\+([0-9]+)(?:,([0-9]+))? @@") | "\($f) \(.[0])-\((.[0] | tonumber) + ((.[1] // "1") | tonumber) - 1)"'
```

Anchor with `side: "RIGHT"` and the head's line number. A comment on a removed line takes `side: "LEFT"` and the base's line number. A range adds `start_line` and `start_side` inside the same hunk.

A file comment's anchor is its `path` alone, and GitHub accepts it for any file that `repos/<owner>/<repo>/pulls/<number>/files` lists. A review-body comment has no anchor. It joins the review body as its own paragraph, after anything the user already wrote there.

Write each comment in the user's voice, modelled on their own comments in the pending review when there are any:

- One short clause, or the problem and a question on the next line.
- Lowercase start, a question mark as the only closing punctuation, and `this` or `here` for the anchored code.
- Requests as questions: ex.`can we ...?`, `maybe ...?`, `shouldn't it be ...?`.
- For a concrete edit of the anchored lines, a few words and a `suggestion` block holding the complete replacement lines with their indentation.
- Each comment starts with its point and reads on its own.

````text
this check passes even when the file is written, because the fixture never exists on disk

this isn't covered in `parser.spec.ts`

the first file that fails to parse leaves every remaining file unformatted
can we catch the error per file?

shouldn't it be `@scope/ui/button`?

for consistency
```suggestion
export const DEFAULT_TIMEOUT_MS = 5000;
```
````

Done when every finding from both axes is a line or file comment with a verified anchor, a review-body comment, an offer, or a drop with its reason.

## Step 4: Posting into the pending review

Every write lands in the user's pending review and keeps it `PENDING`. Line and file comments go in as threads, and review-body comments go in the review body. Send the JSON through `--input -` from a quoted heredoc, so backticks and quotes reach GitHub intact.

With no pending review, create one holding the line comments and the review body in a single request; leaving out `event` keeps it pending, and `body` is left out when there are no review-body comments:

```bash
gh api --method POST "repos/<owner>/<repo>/pulls/<number>/reviews" --jq '{id, node_id, state, html_url}' --input - <<'EOF'
{"commit_id": "<headRefOid>", "body": "can we split the migration into its own pull request?", "comments": [
  {"path": "src/parser.ts", "line": 42, "side": "RIGHT", "body": "can we catch the error per file?"}
]}
EOF
```

GitHub rejects the whole request with `422` when any anchor falls outside the diff, so fix that anchor and resend it all.

Add each file comment as a thread through the review's `node_id`, and with an existing pending review each line comment too:

```bash
gh api graphql --jq '.data.addPullRequestReviewThread.thread' --input - <<'EOF'
{"query": "mutation($input: AddPullRequestReviewThreadInput!) { addPullRequestReviewThread(input: $input) { thread { id } } }",
 "variables": {"input": {"pullRequestReviewId": "<node_id>", "path": "src/parser.ts", "line": 42, "side": "RIGHT", "body": "can we catch the error per file?"}}}
EOF
```

A file thread takes `"subjectType": "FILE"` in place of `line` and `side`. Range threads take `startLine` and `startSide`. A `null` thread means GitHub rejected that anchor. List the review's comments before any retry, so each comment lands once.

With an existing pending review, add the review-body comments by replacing its body with the user's text followed by them:

```bash
gh api --method PUT "repos/<owner>/<repo>/pulls/<number>/reviews/<id>" --jq '{state, body}' --input - <<'EOF'
{"body": "<the user's body>\n\ncan we split the migration into its own pull request?"}
EOF
```

Done when `gh api repos/<owner>/<repo>/pulls/<number>/reviews/<id> --jq .state` prints `PENDING`, the review's comments include every line and file comment from Step 3, and its body holds the user's text and every review-body comment.

## Step 5: Reporting

```markdown
Added <N> comments to your [pending review](html_url) on [<owner>/<repo>#<number>](url). It stays unpublished until you submit it.

Some comments weren't posted, tell me which to add:

1. <finding>: <file, area, or spec line>
2. <finding>: <file, area, or spec line>
n. <finding>: <file, area, or spec line>

...

Dropped:

n+1. <finding>: <reason>
n+2. <finding>: <reason>
n+x. <finding>: <reason>
```

When the user picks offers, add them to the same pending review.
