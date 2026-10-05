Review the documentation of **{{prepare.repo}}** (commit `{{prepare.head}}`) against its code. The repository is cloned at `{{prepare.workdir}}`, your working directory: use paths relative to it or absolute paths under it.

## Documentation files to check

```
{{prepare.doc_files}}
```

## What changed in the code

{{prepare.changes}}

If this is the first review, check every listed doc. Otherwise start with the docs that talk about the changed code, then the rest if your budget allows. Any inaccuracy you can verify counts, not only ones caused by the latest changes.

## How to work

You have a small, hard budget: if you run out, the whole review is lost. So be frugal and finish early rather than late.

1. Read each doc once and note the concrete, checkable claims: commands, flags, options, config keys, default values, function and type names, signatures in examples, file paths, install steps, version requirements.
2. Check claims with **Grep first** (narrow patterns, e.g. the flag or function name) to find where they live in the code. Read only the lines you need (`offset`/`limit`); never read a whole large source file. Start with the places that define the public surface: CLI definitions, schemas, exported functions, package manifests.
3. When a claim is wrong and the code proves it, fix it in place with Edit: the smallest change that makes it true. Only edit the documentation files listed above.
4. Don't rewrite style, don't add sections, don't document new features, don't touch what you can't prove.
5. Every turn re-reads everything so far, so work in **few turns**: put several tool calls in the same turn (read all the docs at once; then send all the Greps for a batch of claims together). Aim for about 12 turns in total. Once you've checked the most important claims, stop and report: a partial review with real fixes is far better than running out of budget.

## What to return

- `changed_files`: the doc files you edited, as paths relative to the repo root (empty list if none).
- `report`: Markdown, in English, exactly in this shape:

```markdown
# docs-drift: <N> fixes proposed in {{prepare.repo}}

## <file path>: <short title of the fix>

- **Was:** what the doc said (quote it briefly).
- **Now:** what it says after your edit.
- **Evidence:** `path/in/code.ext` (line or symbol), and one sentence on what the code shows.

(one `##` section per fix)

## Worth a look

- Claims that look outdated but you couldn't prove, one line each with where to look. Omit this section if empty.
```

If nothing needed fixing, the first line is `# docs-drift: docs match the code in {{prepare.repo}}` followed by one or two sentences on what you checked (and the "Worth a look" section if any).
