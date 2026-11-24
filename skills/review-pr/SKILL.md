---
name: review-pr
description: Reviews a GitHub pull request with the code-triage skill, selects the worthwhile findings, and adds them as brief line, file, and review-body comments to the user's pending (draft) review, leaving it unpublished.
disable-model-invocation: true
---

# Review a Pull Request

Review a pull request with the `code-triage` skill, then turn its findings into comments in the user's pending review. The user edits and submits that review on GitHub, so each comment is written in their voice.

## Step 1: Pin the pull request

The user gives a pull request link or branch. Read it with `gh pr view <link-or-branch> --json url,baseRefName,headRefOid`; the URL gives `<owner>/<repo>` and `<number>`. When a sandboxed `gh` call fails with `Forbidden` or an invalid token, rerun it outside the sandbox, where `gh` can read its keyring.

Pin a checkout following `~/.agents/references/temporary-codebases.md`, with the commit `<headRefOid>`, the refs `<baseRefName>` and `pull/<number>/head`, and the name `review/<owner>/<repo>/PR-<number>`.

Done when `<remote>/<baseRefName>` and `<headRefOid>` both resolve in the checkout.

## Step 2: Run the code-triage skill

Follow the `code-triage` skill at `~/.agents/skills/code-triage/SKILL.md` through its final report. Give it the pull request link, and `<remote>/<baseRefName>` as the fixed point. Run it, and its sub-agents, in the checkout from Step 1.

Done when the Standards, Spec, and Bugs axes and the checks have reported, and each finding has a verdict.

## Step 3: Draft the comments

Read what the pull request already holds:

- The user's pending review, from `gh api repos/<owner>/<repo>/pulls/<number>/reviews --paginate --jq '.[] | select(.state == "PENDING")'`, and its comments at `repos/<owner>/<repo>/pulls/<number>/reviews/<id>/comments`. GitHub keeps one pending review per user and pull request, so new comments join this one.
- The published review comments at `repos/<owner>/<repo>/pulls/<number>/comments`.

Write a comment only for a finding that meets all of these conditions:

- The `code-triage` report shows it as confirmed.
- It is a defect or a worthwhile improvement in the diff.
- No comment in the pending review and no published comment already raises it.
- You are fully confident that it is correct and worth the author's time.

The comment should sit on the line that has the problem. When the same problem sits on several lines, each gets the same comment. When the problem regards the entire file, it becomes a file comment on that file. When it is best described in the scope of the entire pull request, it becomes a review-body comment.

A line comment's anchor is its `path` and `line`, and GitHub accepts it only inside a diff hunk. This prints each file's head-side hunks as `path start-end`:

```bash
gh api "repos/<owner>/<repo>/pulls/<number>/files" --paginate --jq '.[] | .filename as $f | .patch // "" | scan("@@ -[0-9,]+ \\+([0-9]+)(?:,([0-9]+))? @@") | "\($f) \(.[0])-\((.[0] | tonumber) + ((.[1] // "1") | tonumber) - 1)"'
```

Anchor with `side: "RIGHT"` and the head's line number. A comment on a removed line takes `side: "LEFT"` and the base's line number. A range adds `start_line` and `start_side` inside the same hunk.

A file comment's anchor is its `path` alone, and GitHub accepts it for any file that `repos/<owner>/<repo>/pulls/<number>/files` lists. A review-body comment has no anchor. It joins the review body as its own paragraph, after anything the user already wrote there.

Write each comment in the user's voice. Before you write the first comment, read [the comment voice](references/comment-voice.md). It gives the length, form, and words for each type of finding. If the user has comments in the pending review or in this pull request, match them too.

The reader is the pull request author, a cold reader who did not see the `code-triage` report. Make each comment specific enough for that reader to act on, in the length that the comment voice gives:

- Name the case that breaks: the exact input, state, or condition.
- If the fix is not clear from the problem, name the API, function, value, or file to use.
- Link the source when there is one: code that already does it right, the docs page, or the rule file.
- Write the code's identifiers in backticks, and replace the report's shorthand with the thing that it names.

Done when each comment is a line or file comment with a verified anchor, or a review-body comment. Each comment must follow the comment voice, and a cold reader must be able to act on it without the report.

## Step 4: Select the comments

If Step 3 has no comments, skip this step.

Spawn one `review-curator` sub-agent, defined in `~/.agents/agents/review-curator.md`, for the full set of drafted comments. If the agent type is not available, spawn a general-purpose sub-agent, and tell it to read `~/.agents/agents/review-curator.md` and follow its body. Give it:

- the pull request link
- the checkout path and the diff command `git diff <remote>/<baseRefName>...HEAD`
- each drafted comment, with an id, its anchor, its full text, and the `code-triage` finding that it comes from
- the comments in the pending review and the published comments from Step 3

The sub-agent decides which comments to keep: all, some, or none. Its verdict is final. The **kept comments** are the comments with a `keep` verdict, with the text from Step 3.

Done when each drafted comment has a `keep` or `drop` verdict.

## Step 5: Post into the pending review

If Step 4 has no kept comments, skip this step and create no review.

Every write lands in the user's pending review and keeps it `PENDING`. Line and file comments go in as threads, and review-body comments go in the review body. Send the JSON through `--input -` from a quoted heredoc, so backticks and quotes reach GitHub intact.

With no pending review, create one holding the line comments and the review body in a single request; leaving out `event` keeps it pending, and `body` is left out when there are no review-body comments:

```bash
gh api --method POST "repos/<owner>/<repo>/pulls/<number>/reviews" --jq '{id, node_id, state, html_url}' --input - <<'EOF'
{"commit_id": "<headRefOid>", "body": "can we split the migration into its own pull request?", "comments": [
  {"path": "src/parser.ts", "line": 42, "side": "RIGHT", "body": "the error could be caught per file, so one file that fails to parse leaves the rest formatted"}
]}
EOF
```

GitHub rejects the whole request with `422` when any anchor falls outside the diff, so fix that anchor and resend it all.

Add each file comment as a thread through the review's `node_id`, and with an existing pending review each line comment too:

```bash
gh api graphql --jq '.data.addPullRequestReviewThread.thread' --input - <<'EOF'
{"query": "mutation($input: AddPullRequestReviewThreadInput!) { addPullRequestReviewThread(input: $input) { thread { id } } }",
 "variables": {"input": {"pullRequestReviewId": "<node_id>", "path": "src/parser.ts", "line": 42, "side": "RIGHT", "body": "the error could be caught per file, so one file that fails to parse leaves the rest formatted"}}}
EOF
```

A file thread takes `"subjectType": "FILE"` in place of `line` and `side`. Range threads take `startLine` and `startSide`. A `null` thread means GitHub rejected that anchor. List the review's comments before any retry, so each comment lands once.

With an existing pending review, add the review-body comments by replacing its body with the user's text followed by them:

```bash
gh api --method PUT "repos/<owner>/<repo>/pulls/<number>/reviews/<id>" --jq '{state, body}' --input - <<'EOF'
{"body": "<the user's body>\n\ncan we split the migration into its own pull request?"}
EOF
```

Done when `gh api repos/<owner>/<repo>/pulls/<number>/reviews/<id> --jq .state` prints `PENDING`, the review's comments include every kept line and file comment, and its body holds the user's text and every kept review-body comment.

## Step 6: Report

If an inline HTML widget tool (`show_widget`) is in your tool list, report with [the widget report](references/widget-report.md) in place of the Markdown report below.

```markdown
Added <N> comments to your [pending review](html_url) on [<owner>/<repo>#<number>](url). It stays unpublished until you submit it.

1. <file>:<line>, <file>, or review body: <comment>
2. <file>:<line>, <file>, or review body: <comment>
n. <file>:<line>, <file>, or review body: <comment>
```

The report shows the posted comments and nothing more. If Step 3 or Step 4 leaves no comments, tell the user that the pull request needs no comments.
