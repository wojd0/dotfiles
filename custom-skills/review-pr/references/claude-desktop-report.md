# Desktop app report

Use this report in place of the Markdown report of Step 5. The report is one inline widget. It shows the comments that Step 4 posted and nothing more, each with its full text, a direct link, and a **Mention** button.

1. Before the first widget of the session, call `mcp__visualize__read_me` with `modules: ["interactive"]`.
2. Fill the template below. Add one card for each posted comment, in the order of Step 4.
3. Call `mcp__visualize__show_widget` with the filled template.
4. Write no text after the widget. The widget is the full report.

Fill the placeholders with these rules:

- `{{TITLE}}`: the pull request title, HTML-escaped, with its Jira key as a link to the ticket. If the title has no key, use the plain title.
- `{{APPROVERS}}`: the logins of the users that approved the pull request, comma-separated. If there are no approvers, remove the whole `<span class="bdg">` element.
- `{{KIND}}`: `Line comment`, `File comment` or `Review body`.
- `{{LABEL}}` and `{{LINK}}`:

| Comment | `{{LABEL}}` | `{{LINK}}` |
|---|---|---|
| Line comment | `<file name>:<line>` | `https://github.com/<owner>/<repo>/pull/<number>/files#diff-<hash>R<line>` |
| Range comment | `<file name>:<start_line>–<line>` | `…#diff-<hash>R<start_line>-R<line>` |
| File comment | `<file name>` | `…#diff-<hash>` |
| Review body | `#<number>` | the `html_url` of the pending review |

`<hash>` is the SHA-256 of the full `path`: `printf %s '<path>' | shasum -a 256 | cut -d' ' -f1`. A comment on a removed line (`side: "LEFT"`) uses `L` in place of `R`.

- `{{MENTION}}`: `[comment <label> on <owner>/<repo>#<number>](<link>) `, with the space at the end.
- `{{BODY}}`: the full body of the comment, as posted. Show all of it, with these changes:
  - Escape `&`, `<` and `>`.
  - Put each line in a `<p>` element.
  - Put each backtick span in a `<code>` element, and each URL in an `<a>` element.
  - Put each `suggestion` block in `<pre><code>`. After the last `<p>` of the card, add the edit suggestion line below.

The edit suggestion line says in one sentence what the suggested edit changes:

```html
<div class="sug"><i class="ti ti-info-circle" aria-hidden="true"></i><span>Edit suggestion: {{ONE SENTENCE}}</span></div>
```

The template:

```html
<style>
.card{background:var(--surface-2);border:0.5px solid var(--border);border-radius:12px;padding:1rem 1.25rem;margin-bottom:12px}
.bdg{font-size:12px;padding:3px 8px;border-radius:var(--radius);white-space:nowrap;background:var(--bg-success);color:var(--text-success)}
.sec{display:flex;align-items:center;gap:8px;margin:1.5rem 0 10px;font-size:14px;font-weight:500}
.sec .n{font-size:12px;font-weight:400;color:var(--text-muted)}
.hd{display:flex;flex-wrap:wrap;align-items:center;gap:8px;margin-bottom:6px}
.loc{font-family:var(--font-mono);font-size:12px;color:var(--text-accent)}
.kind{font-size:12px;color:var(--text-muted)}
.body{font-size:14px;line-height:1.6;color:var(--text-primary)}
.body p{margin:0}
.mention{margin-left:auto;font-size:12px;padding:4px 10px}
.sug{display:flex;gap:6px;align-items:flex-start;margin-top:10px;padding-top:10px;border-top:0.5px solid var(--border);font-size:13px;line-height:1.5;color:var(--text-accent)}
</style>
<h2 class="sr-only">Review summary for pull request {{NUMBER}}: {{N}} comments posted to the pending review.</h2>
<div style="padding:0.5rem 0 0">
<a href="{{PR_URL}}" style="font-size:18px;font-weight:500">{{OWNER}}/{{REPO}}#{{NUMBER}}</a>
<div style="font-size:14px;color:var(--text-secondary);margin:4px 0 8px">{{TITLE}}</div>
<span class="bdg"><i class="ti ti-check" aria-hidden="true"></i> Approved by: {{APPROVERS}}</span>
</div>
<div class="sec"><i class="ti ti-message-check" aria-hidden="true"></i>In your pending review <span class="n">{{N}} comments</span><a href="{{REVIEW_URL}}" style="margin-left:auto;font-size:13px;font-weight:400">Open review <i class="ti ti-external-link" aria-hidden="true"></i></a></div>
<div class="card">
<div class="hd"><a class="loc" href="{{LINK}}">{{LABEL}}</a><span class="kind">{{KIND}}</span><button class="mention" data-ref="{{MENTION}}"><i class="ti ti-at" aria-hidden="true"></i> Mention</button></div>
<div class="body">{{BODY}}</div>
</div>
<script>
document.querySelectorAll('.mention').forEach(b=>b.addEventListener('click',()=>sendPrompt(b.dataset.ref)));
</script>
```

Done when the widget shows one card for each posted comment, every link opens its line or file, and every card has a **Mention** button.
