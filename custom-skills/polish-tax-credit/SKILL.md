---
name: polish-tax-credit
description: Check the current month's Polish tax-credit submission deadline and prepare the monthly IP Box form content from Outlook, GitHub, Jira, and Confluence only when two or fewer Polish working days remain.
---

# Polish Tax Credit

Use Europe/Warsaw for the current month, current date, and run timestamp. This is a read-only evidence-gathering workflow: do not send email, submit a form, or modify source systems.

## Gate the run on the deadline

1. Search Outlook for emails about the current month's Poland tax-credit request submission deadline. Resolve the month from the email's subject and body, not merely its received date.
2. Among emails that unambiguously concern the current month, use the most recently received relevant email as authoritative. Extract the stated deadline date and time, preserving any stated timezone; interpret an unstated timezone as Europe/Warsaw only when the surrounding company context makes that interpretation reliable.
3. Count Polish working dates strictly after today's Warsaw date and through the deadline's Warsaw date. A working date is Monday through Friday excluding Polish public holidays. Use scripts/polish_working_days.py for the calculation. If the deadline has passed, treat the remaining count as zero.
4. If more than two working days remain, end the run without a user-visible notification or report. Do not query GitHub or Atlassian after this gate.
5. If the deadline or its applicable month cannot be determined reliably, return one concise blocker and stop.

## Establish the reporting period

Search Outlook, including Sent Items, for the most recent message or submission receipt that reliably proves when the user submitted a tax report. Use its exact sent/submission timestamp as the exclusive start and the current run timestamp as the inclusive end: (previous_submission, run_time].

Prefer explicit submission evidence over discussion, reminders, drafts, or an email that merely contains a report. If the exact submission timestamp is unavailable or ambiguous, return one concise blocker and stop. Record the resolved start and end in one consistent timezone before querying contributions.

## Gather complete contribution evidence

### GitHub pull requests

1. Identify the authenticated GitHub user and require the login to be exactly wojd0. A mismatch is a blocker because it risks reporting another person's work.
2. Search across all repositories visible to the authenticated account for pull requests authored by wojd0 and merged during the reporting period. Exhaust pagination or result cursors.
3. Search broadly enough to cover both boundary dates, then verify each PR's precise mergedAt timestamp against (previous_submission, run_time]. Deduplicate by PR URL.
4. Preserve every qualifying PR title exactly and retain its direct PR URL, repository name, repository URL, and available association evidence such as branch name, body, linked issues, and development links.

Do not substitute closed-but-unmerged PRs or PRs whose merge time falls outside the interval.

### Confluence contributions

Use Atlassian Rovo to identify the current Atlassian user, search candidate Confluence pages, and inspect page version/history evidence for the reporting period.

Include a page when either condition is proved:

- The page was created by the user during the reporting period.
- The page was created by someone else, and version/history evidence attributes a substantial content update during the period to the user.

A substantial update changes meaning: for example, adding or rewriting guidance, decisions, requirements, procedures, or a meaningful section. Exclude whitespace-only, formatting-only, metadata-only, accidental, trivial, and ambiguous changes. contributor = currentUser() is candidate discovery, not proof of a current-period contribution. When attribution, timestamp, or materiality cannot be confirmed from reliable history or diff evidence, exclude the page.

Preserve qualifying page titles exactly and retain direct page URLs, space/project context, timestamps, authorship evidence, and a short evidence-based note about the recorded work.

### Jira issues

For every Jira key reliably associated with a qualifying PR, retrieve the issue from Jira. Use the issue and PR evidence together to write an accurate one- or two-sentence Polish description of the implemented work.

Accept association evidence from explicit Jira development links, the PR title or body, the branch name, or linked issue metadata. Do not invent a key or association. If a qualifying PR has no reliably associated Jira key, or a required issue cannot be read, return one concise blocker instead of producing an incomplete report. When a PR has multiple reliably associated keys, account for each key without duplicating the PR in the creative-work field.

## Compose the form content

Write prose in Polish. Preserve names, PR titles, Confluence page titles, component names, repository names, Jira keys, and product names exactly as found.

Return exactly four separate copy-ready plain-text blocks in the order below. Put each exact label immediately before its block, outside the copy-ready content. Put no preface, conclusion, deadline note, or evidence commentary around the four labeled blocks. Use raw URLs, never Markdown link syntax. Use no bullets, bold text, or tables inside the blocks. Put one blank line between entries within a field.

### Wytworzony utwór / Creative work outcome:

List every qualifying PR as its exact title followed by its direct PR URL. Then list every qualifying Confluence page as its exact title followed by its direct page URL.

### Realizowany projekt, w ramach którego został wytworzony utwór / Project under which the work was created:

List each relevant project or repository once with its direct project or repository URL. Preserve first-seen order. For Satori, use these exact entries:

    Satori Design System
    https://hyland.atlassian.net/browse/DS

    HylandSoftware/satori
    https://github.com/HylandSoftware/satori

For work outside Satori, use only project/repository mappings supported by the retrieved evidence; do not infer ownership from a page title alone.

### Ewidencja i archiwizacja utworu / Recording and archiving of the work:

For each PR, give its associated Jira key, the concise Polish implementation description, and the direct Jira URL. For each Confluence contribution, preserve the exact page title, concisely explain in Polish what work the page records, and include the direct Confluence URL.

Every entry must state positive, evidence-based work. Do not add a placeholder or sentence saying that no Jira issue exists.

### People:

The copy-ready body of this block contains exactly this URL and nothing else:

    https://github.com/orgs/HylandSoftware/people

If exhaustive retrieval finds no qualifying PRs or Confluence contributions, still return all four labeled blocks and leave inapplicable block bodies empty. An empty result is valid only after the searches and boundary checks complete successfully.

## Blocker behavior

When a required Outlook, GitHub, Jira, or Confluence connection cannot be read, or a required deadline, submission timestamp, identity, PR-to-Jira association, or issue cannot be determined reliably, return one concise blocker instead of the four blocks. Name the missing source or fact and the minimum action needed to continue. Never fill gaps with old report content, examples, or guesses.
