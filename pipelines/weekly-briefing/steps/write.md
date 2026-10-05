Write this week's briefing about {{params.repos}}.

- Reader: {{params.audience}}.
- Language: write the whole briefing in {{params.language}}.
- Period: {{collect.period}} (ISO week {{collect.week}}).
- Counts: {{collect.summary}}.

## The data

Your working directory holds the week's activity, collected from GitHub:

- `overview.md`: the period and the counts per repository. Read it first.
- One `<owner>_<name>.md` per repository with the merged pull requests (title, author,
  labels and the start of the description), the issues opened and closed, and the notes of
  any release published in the period. Lists hold at most 100 items; the heading of each
  section gives the real total.

Read all of them. They can be long: read them in chunks if needed. Merged pull requests and
release notes are what shipped; issues opened show what people are asking for or running
into; issues closed show what got resolved.

## What to return

Return a `report` field with the briefing as Markdown, in exactly this shape:

1. First line, a headline that says what happened, with the week number and real numbers:
   `# Week {{collect.week}}: 6 changes shipped in acme/api` (translated into
   {{params.language}}; with several repositories, name them or say "across N projects").
   This line is shown on its own in a notification, so it must make sense alone.
2. A blank line, then one italic line with the period, e.g. `_{{collect.period}}_`.
3. 3 to 6 bullet points in plain language, grouped by theme under short bold labels such as
   **What users will notice**, **Fixes**, **In progress** (only the themes the data
   supports, translated). Each bullet explains the change and why it matters to
   {{params.audience}}. Put the evidence at the end of a bullet as small links, e.g.
   `([#123](url), [#124](url))`, never as numbers inside the sentence.
4. Only if something in the data needs a decision or attention from the reader (a
   recurring complaint, a pile of reports about the same problem, a breaking change, a
   release that needs announcing), a `## Needs a decision` section (translated) with 1 or 2
   short bullets. Otherwise leave that section out completely.

If a repository had no activity, say so in one short bullet instead of leaving it out.
No jargon (words like "segfault", "TLS" or "refactor" don't belong here), no intro or closing sentences, no table, nothing after the last section.
