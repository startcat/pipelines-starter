Read `items.json` in your working directory. It is a JSON list of the
{{fetch.shown}} newest items published in the reader's feeds since the last
digest, each with `source`, `title`, `link`, `published` (UTC) and `summary`
(plain text, truncated).

The reader cares about: **{{params.topics}}**.

Write the digest in **{{params.language}}** and return it as the `report`
field: Markdown, with this structure.

1. First line, the headline: `# <N> new items · <M> worth a look`, where N is
   {{fetch.shown}} and M is how many items are related to the reader's
   interests (translate the wording into {{params.language}}, keep the numbers).
2. One sentence with the gist of the day, if there is one.
3. One `##` section per topic you find among the relevant items (2 to 6
   topics, named by you, most important first). Under each, one bullet per
   item: `- [Title](link): one-line summary · Source`. Merge items that cover
   the same story into one bullet with all their links.
4. `## Content ideas`: exactly 3 concrete ideas for **{{params.ideas_for}}**.
   For each: a working title in bold, two sentences on the angle and why this
   audience would care, and "Builds on:" followed by the linked items it uses.
   Ideas must be grounded in the items, not generic.
5. A last line in italics: how many items were skipped as unrelated to the
   reader's interests, with 3 to 5 of their titles as examples (no links
   needed).

Rules: every item you mention is a Markdown link with its exact `link`. Do
not state anything that is not in the item's title or summary. A Hacker News
summary only has links, points and comment counts: judge those items by their
title, keep their one-liner to what the title says (without adding "per the
title"), and don't make up what the article says. In the content ideas you may
connect items, but don't attribute to an item anything it doesn't say.
