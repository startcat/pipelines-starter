# stale-prs

Every weekday morning, lists the open pull requests in your GitHub repos that **nobody has touched in N days** (author, days idle, draft, review state) and alerts you only when there are some.

Shell only: no agent, no tokens, no cost. A few GitHub API calls per repo.

## Before you start

It needs a GitHub token in `.env` at the root of the starter:

```bash
GITHUB_TOKEN=github_pat_...
```

A [fine-grained token](https://github.com/settings/personal-access-tokens/new) with read-only **Pull requests** access to the repos you list is enough (public repos work with "Public repositories (read-only)"). A classic token needs `repo` for private repos, nothing for public ones.

## Install

```bash
cd pipelines-starter
pipelines doctor stale-prs
pipelines install stale-prs --set repos="my-org/api my-org/web"
```

That's it: from tomorrow it runs Monday to Friday at 09:00. To try it right now:

```bash
pipelines run stale-prs --set repos="my-org/api"
```

## Configure

| Param | Default | What it does |
|---|---|---|
| `repos` | (required) | Space-separated list of repos as `owner/name`. |
| `stale_days` | `5` | A pull request is stale after this many days without any update (commits, comments, reviews, labels). |
| `include_drafts` | `true` | Set to `false` to ignore draft pull requests. |
| `max_rows` | `30` | Pull requests listed per repo, stalest first; the rest are counted. |

Change a param later with `pipelines install stale-prs --set stale_days=7` (the others are kept). To change the schedule, edit `triggers.cron` in [`pipeline.yaml`](pipeline.yaml) and run `pipelines install stale-prs` again.

## What you get

A report at `reports/stale-prs/latest.md` (and one per day next to it). This one is from a test run against two public repos:

```markdown
# 64 pull requests idle for 5+ days

## startcat/agentic-pipelines

No stale pull requests.

## withastro/astro: 64 stale

| Pull request | Author | Days idle | Draft | Review |
|---|---|---|---|---|
| #14955 feat(config): Add React compiler as an Astro config option | @erbierc | 250 | draft | commented |
| #17020 fix(transitions): skip ClientRouter transition when `from` and `to` are the same URL | @Arecsu | 109 |  | no reviewer |
| #17121 Added config option for setting a hostname to be prepended to Server Island URLs | @ryechus | 97 |  | changes requested |

…and 61 more.
```

Each pull request links to GitHub. **Review** is the latest decision (`approved`, `changes requested`), `commented` if there are only comments, `waiting for @someone` if a review was requested but not given, or `no reviewer`.

When there is at least one stale pull request (or a repo can't be read), the run ends as `failed` on purpose and you get a notification. When there are none, it stays quiet. If the pipeline stops running for four days, you get a notification too (`stale_after: 98h`, long enough to cover a weekend).

## Notifications

By default, a macOS notification (`notify.channel: macos`). To get it on your phone instead, set `NTFY_TOPIC` in `.env` and change the channel to `ntfy` in [`pipeline.yaml`](pipeline.yaml). See the [main README](../../README.md#notifications).

## Safety

Read-only: it only makes `GET` requests to `api.github.com` (the open pull requests of each repo, and the reviews of the ones it lists) and writes the report under `reports/stale-prs/`. It never comments, labels, closes or merges anything.
