# Triage findings

The `code-triage` skill and its sub-agents (`triage-standards`, `triage-spec`, `triage-bugs`, and `triage-verifier`) share this format. A **finding** is one problem in the change, with the evidence that a cold reader needs to check it.

## Bar

Report a finding only when you can show it from the code, a rule, or a source. The reader is the author of the change, who has not seen your work. A finding that needs your reasoning to make sense is not ready.

- Point at the exact place: the head-side `path:line`, a `path`, or the whole change.
- Quote the evidence: the hunk, the rule with its file, or the spec text with its link.
- Keep one problem in each finding. If the same problem sits on several lines, list each line in one finding.
- Report findings in the change. A problem that was on the base already is a finding only when the change makes it worse.

## Finding format

```markdown
### <axis letter><n>. <title in eight words or fewer>
- **Where**: `<path>:<line>` (head side), `<path>`, or the change
- **Kind**: <kind>
- **Claim**: <one sentence: what is wrong and what it causes>
- **Evidence**: <quote or link>
- **Scenario**: <input or state> → <wrong result>
- **Fix**: <the API, function, value, or file to use>
```

The axis letter is `S` for Standards, `P` for Spec, and `B` for Bugs. Write **Scenario** for each `defect` and `wrong-implementation` finding. Write **Fix** when the fix is not clear from the claim.

## Kinds

| Kind | Axis | Meaning |
|---|---|---|
| `standard` | Standards | The change breaks a rule that the repository documents. |
| `smell` | Standards | A baseline code smell. Always a judgement call. |
| `missing` | Spec | A requirement that the change does not do, or does only in part. |
| `scope-creep` | Spec | Behavior that no source asks for. |
| `wrong-implementation` | Spec | The change does a requirement, but incorrectly. |
| `defect` | Bugs | The change causes incorrect behavior, a crash, a regression, or a broken contract. |

## Verdict format

The `triage-verifier` sub-agent returns one verdict for each finding that it gets:

```markdown
### <finding id>: <confirmed | refuted>
- **Check**: <what you read or ran>
- **Result**: <the observed result, with the quote or the command output>
- **Reason**: <one sentence>
```
