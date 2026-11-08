---
name: review-pr
description: Reviews a GitHub pull request with the code-review skill and adds the findings as brief line, file, and review-body comments to the user's pending (draft) review, leaving it unpublished.
disable-model-invocation: true
---

# Review a Pull Request

Review a pull request with the `code-review` skill, then turn its findings into comments in the user's pending review. The user edits and submits that review on GitHub, so each comment is written in their voice.

## Step 1: Pinning the pull request

The user gives a pull request link or branch. Read it with `gh pr view <link-or-branch> --json url,baseRefName,headRefOid`; the URL gives `<owner>/<repo>` and `<number>`. When a sandboxed `gh` call fails with `Forbidden` or an invalid token, rerun it outside the sandbox, where `gh` can read its keyring.

Pin a checkout following `~/.agents/references/temporary-codebases.md`, with the commit `<headRefOid>`, the refs `<baseRefName>` and `pull/<number>/head`, and the name `review/<owner>/<repo>/PR-<number>`.

Done when `<remote>/<baseRefName>` and `<headRefOid>` both resolve in the checkout.

## Step 2: Running the code-review skill

Follow the `code-review` at `~/.agents/skills/code-review/SKILL.md` skill through its final report, passing it the pull request link or branch the user gave. Run it, and its sub-agents, in the checkout from Step 1.

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

Write each comment in the user's voice. Model it on the user's comments in the pending review and in this pull request, when there are any.

The reader is the pull request author, a cold reader who did not see the code-review report. Make each comment specific enough for that reader to act on:

- Name the case that breaks: the exact input, state, or condition.
- Name the fix: the API, function, value, or file to use. A `suggestion` block can show it.
- Link the source when there is one: code that already does it right, the docs page, or the rule file.
- Write the code's identifiers in backticks, and replace the report's shorthand with the thing that it names.

Choose the form that fits the point. Most of the user's comments are statements or suggestions, and a few are questions:

- A statement of the problem and its effect, when the fix is clear.
- A suggestion with `could ...`, `you could ...`, `it would make sense to ...`, or `I think we better ...`.
- A request with `please ...` for a repository convention.
- A bare label for a small nit, for example `commented-out code`.
- A question when the author knows something that the user does not, or when the fix is a judgement call: `shouldn't it be ...?`, `maybe ...?`, `can we ...?`.
- A few words of reason and a `suggestion` block for a concrete edit of the anchored lines. The block holds the complete replacement lines with their indentation, and it is the request by itself.

Start each comment with its point, in one or two sentences. A design point can take a short paragraph. Use a lowercase start, no closing period, and `this` or `here` for the anchored code.

````text
`existsSync` reads the real disk, but the migration writes only to the virtual `Tree`, so this passes even when the file is never created
`tree.exists(path)` would check the right place

`chevron_right` isn't mirrored, so collapsed nodes point the wrong way in RTL

instead of the negative check you could use a ternary here, like in `toggleAllRows` above

`compileComponents` is only needed with `@defer` blocks https://angular.dev/guide/testing/components-basics#reduce-the-setup

please mark all continuous tasks with the `continuous` flag

commented-out code

shouldn't `eventemitter3` be a dependency of `js-api`?

this drops `--sat-breadcrumbs-gap`, so consumers that override it lose their custom gap
```suggestion
  gap: var(--sat-breadcrumbs-gap, 4px);
```
````

Done when every finding from both axes is a line or file comment with a verified anchor, a review-body comment, an offer, or a drop with its reason, and a cold reader can act on each comment without the report.

## Step 4: Posting into the pending review

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
