# Comment voice

Write each comment so that the user can post it as their own text. These rules come from the comments that the user wrote before this skill drafted for them. Drafted comments were longer and more polished than the user's own, so match the examples in this file, not earlier drafts.

## Shape

- Start with a lowercase letter, and end with no period. Use capitals only for `I`, proper names, and `LGTM`.
- Write one point in each comment. Most comments have 5 to 20 words, and the median is 10.
- Write one sentence. Add a second line only for the fix or for a question. Write three sentences only for a design point.
- Put each clause on its own line, in place of a long sentence.
- Join clauses with `so`, `as`, a comma, or ` - ` (a hyphen with spaces).
- Name the anchored code with `this` or `here`. Use `we` and `can we` for the team, `I` for the user's opinion, and `you` only a little.
- Put identifiers, files, and flags in backticks.
- Paste URLs bare, inline or on their own line. Use Markdown link text only for a file name.
- Write plain text, like a quick note to a colleague.

## Forms

### Defect

State the consequence in one sentence. If the fix is not clear from the problem, add a second line that asks for it with `can we ...?`.

```text
`chevron_right` isn't mirrored, so collapsed nodes point the wrong way in RTL

this sample has no trigger, so neither tooltip can open
can we add the trigger/reference?

shouldn't eventemitter3 be a dependency of js-api?
```

### Suggestion or design point

Hedge with `maybe`, `could`, `I think`, `it would make sense to`, or `shouldn't ...?`. If the user cannot be sure, make the point a question.

```text
maybe if we're just switching this subject true or false and don't subscribe to it to handle some side effects it doesn't need to be an observable?

this looks like a remedy for an overflowing layout of components, can we do it more safely with flex or grid layout?

I think we better align label content to the left, so it stays aligned when there are multiple radio buttons one under another

this part of code is duplicated in [app-header-service.ts](https://github.com/<owner>/<repo>/pull/<number>/changes#diff-<hash>R76-R82), could be extracted to a service method
```

### Nit

Write a bare label or 3 to 6 words.

```text
commented-out code

can be shortened to a call to `clearSelection`

seems like nothing has changed here
```

### Question

Start with `shouldn't`, `is ... intentional?`, or `do you expect`. Ask one question in each comment.

```text
shouldn't it be `@hylandsoftware/satori-ui/navigation-tabs` ?

shouldn't this be `@internal` too? it lands in `public.api.md` typed with `SatDragDropItemRef`, which isn't exported
```

### Repository convention

Use `please` only for a convention or a process request.

```text
please make sure to mark all continuous jobs with "continuous" flag

please use bun as a package manager and js runtime as this is what's used in gh actions
```

### Suggestion block

Use a `suggestion` block only for a typo, for code to delete, or for an edit that is shorter than its description. Put a few words of reason before the block. The block holds the complete replacement lines with their indentation.

````text
this looks a bit excessive, from what I checked no `whenStable` call is needed
```suggestion
  async function createFixture<T>(component: new () => T): ComponentFixture<T> {
    const fixture = TestBed.createComponent(component);
    fixture.detectChanges();
    return fixture;
  }
```

for consistency
```suggestion
  (`### Do Not Use Upload Area Alone`) and explain the consequence.
```
````

### Link to related code

Point to the related code with a few words and the bare URL.

```text
possibly this line should also be removed, a similar customization
https://github.com/<owner>/<repo>/blob/<sha>/<path>#L57

it would make sense to parametrize the `createFixture` function like in https://github.com/<owner>/<repo>/pull/<number>/changes#diff-<hash>R37-R43
```

### Review body

A review-body comment has the same form as a line comment. Add no summary of the line comments, because the user writes any summary when they submit.

```text
holding it until https://github.com/HylandSoftware/satori/pull/2114 is merged

can we split the migration into its own pull request?
```

## Variety

- If the same problem sits on several lines, repeat the same comment word for word. Below the first one in the same file, `same here` is sufficient.
- For different findings in one review, change the first word: `this ...`, `maybe ...`, `shouldn't ...`, `can we ...`, or the backticked identifier.

## Word choice

Use the user's words in the right column:

| In place of | Write |
|---|---|
| `Consider ...`, `You might want to ...`, `It might be worth ...`, `Feel free to ...` | `could ...`, `maybe ...`, `can we ...?` |
| a `nit:`, `blocking:`, `Suggestion:`, or `Issue:` prefix, a bold label | the point itself |
| `Hi`, `Thanks for the PR`, `Great work`, `Let me know`, `Hope this helps` | nothing |
| `I noticed that ...`, or a description of what the code does | the problem, as the first words |
| an em dash, a semicolon, `however`, `additionally`, `therefore` | ` - `, a comma, or a new line |
| `ensure`, `robust`, `leverage` | `make sure`, or a plain word |
| a bullet list or a heading in a comment | short lines |
| `[#123](url)` link text for a pull request or a ticket | the bare URL |
| praise in a critical comment | the critique alone |
