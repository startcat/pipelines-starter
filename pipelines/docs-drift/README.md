# docs-drift

Once a week, **if the code changed**, an agent reads a repository's docs next to its code and fixes what is no longer true (wrong flags, renamed functions, outdated install steps, examples that don't match the signatures). You get a report with the evidence for each fix and a local branch to review. **Nothing is ever pushed.**

Uses an agent (Sonnet) only on weeks with new commits, capped at $1.00 per run (a typical review costs $0.20–0.35); weeks without changes cost nothing.

## Install

```bash
cd pipelines-starter
pipelines doctor docs-drift
pipelines install docs-drift --set repo_url="https://github.com/owner/repo.git"
```

That's it: it runs every Monday at 07:00. To try it right now:

```bash
pipelines run docs-drift --set repo_url="https://github.com/owner/repo.git"
```

The first run always reviews; after that, the agent only runs when the branch has new commits since the last successful review.

## Configure

| Param | Default | What it does |
|---|---|---|
| `repo_url` | (required) | Git URL to clone, https or ssh (`git@github.com:owner/repo.git`). For a private repo, use a URL your `git` can already clone. |
| `branch` | remote default branch | Branch to review. |
| `docs` | `README.md docs` | Space-separated doc files, directories or simple globs (`docs/*.md`), relative to the repo root. Directories are searched for `.md`, `.mdx`, `.rst`, `.adoc` and `.txt` files. |
| `workdir` | `~/Library/Application Support/pipelines/workspaces/docs-drift` | Where the pipeline keeps its own clone (`<owner>-<repo>/`) and the last reviewed commit (`<owner>-<repo>.last-reviewed`). |

Change a param later with `pipelines install docs-drift --set docs="README.md docs CONTRIBUTING.md"` (the others are kept). To change the schedule, edit `triggers.cron` in [`pipeline.yaml`](pipeline.yaml) and run `pipelines install docs-drift` again. To force a new review without new commits, delete the `.last-reviewed` file.

## What you get

A report at `reports/docs-drift/latest.md` (and one per date next to it). An excerpt from a real run against the engine's own repo, where the README had a wrong port:

```markdown
# docs-drift: 1 fix proposed in owner/repo

## README.md: wrong default port for `pipelines web`

- **Was:** `pipelines web   # local read-only dashboard at http://127.0.0.1:8080`
- **Now:** `pipelines web   # local read-only dashboard at http://127.0.0.1:7717`
- **Evidence:** `src/cli/commands/web.ts:8` defines `.option('-p, --port <n>', ..., '7717')`: the default port is 7717, not 8080.

## Worth a look

- "tested with 1.3.9" for Bun is a testing claim that can't be verified against the repo; left untouched.
```

When everything matches, the headline is `docs-drift: docs match the code in owner/repo` with a short list of what was checked.

The fixes are committed on a local branch `docs-drift/<date>` of the pipeline's clone, and the report ends with the commands to look at them and, if you agree, push them yourself:

```sh
cd "~/Library/Application Support/pipelines/workspaces/docs-drift/owner-repo" && git diff <sha>..docs-drift/2026-10-05
cd "~/Library/Application Support/pipelines/workspaces/docs-drift/owner-repo" && git push origin docs-drift/2026-10-05
```

On a week without new commits the report just says `docs-drift: no code changes in owner/repo since the last review` and the agent doesn't run.

## Notifications

A macOS notification after every run with the report's first line, e.g. "docs-drift: 3 fixes proposed in owner/repo", and on failure. If it hasn't completed a run for 8 days, you get a notification too (`stale_after: 200h`). To get it on your phone instead, set `NTFY_TOPIC` in `.env` and change the channel to `ntfy` in [`pipeline.yaml`](pipeline.yaml). See the [main README](../../README.md#notifications).

## Safety

- **Your checkouts are never touched.** The pipeline clones the repo into its own `workdir` and only ever resets that clone (it refuses to touch a directory it didn't create, or a clone of another URL).
- **The agent** can only Read, Glob, Grep, Edit and Write inside that clone: no shell, no git, no network. It is told to edit docs only, and any edit outside the `docs` list is undone before committing.
- **git** clones and fetches from `repo_url`, then commits locally as `docs-drift <docs-drift@localhost>`. It never pushes: pushing is a command in the report that you run yourself.
- Writes only the clone, its `.last-reviewed` file and `reports/docs-drift/`.
