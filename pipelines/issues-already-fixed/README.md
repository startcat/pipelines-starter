# issues-already-fixed

Once a week, finds **open issues that a recent commit on the default branch already references** (`fixes #12`, `closes #12`, or just `#12`), so you can check them and close the ones that are really done. It never closes anything itself.

Shell only: no agent, no tokens, no cost. A handful of GitHub API calls per repo.

## Before you start

It needs a GitHub token in `.env` at the root of the starter:

```bash
GITHUB_TOKEN=github_pat_...
```

A [fine-grained token](https://github.com/settings/personal-access-tokens/new) with read-only **Contents** and **Issues** access to the repos you list is enough (public repos work with "Public repositories (read-only)"). A classic token needs `repo` for private repos, nothing for public ones.

## Install

```bash
cd pipelines-starter
pipelines doctor issues-already-fixed
pipelines install issues-already-fixed --set repos="my-org/api my-org/web"
```

That's it: it runs every Monday at 09:00. To try it right now:

```bash
pipelines run issues-already-fixed --set repos="my-org/api"
```

## Configure

| Param | Default | What it does |
|---|---|---|
| `repos` | (required) | Space-separated list of repos as `owner/name`. |
| `since_days` | `30` | How far back to read commits on the default branch. |
| `max_commits` | `500` | Cap on commits read per repo (newest first), so a busy repo stays cheap. |

Change a param later with `pipelines install issues-already-fixed --set since_days=14` (the others are kept). To change the schedule, edit `triggers.cron` in [`pipeline.yaml`](pipeline.yaml) and run `pipelines install issues-already-fixed` again.

## What you get

A report at `reports/issues-already-fixed/latest.md` (and one per run next to it). This one is from a test run against a busy public repo:

```markdown
# 8 open issues referenced by recent commits

## oven-sh/bun: 8 open issue(s) referenced, 0 with a closing keyword

Read 300 commit(s) on `main` since 2026-09-05.

| Issue | Reference | Commit(s) |
|---|---|---|
| #27418 bun install shouldn't contact NPM registry for bundled dependencies | mention | `8eaad80` install: do not download tarballs that the installers never place (#43122) |
| #26369 Bun.SQL SNI details not sent unless (a) a connection URL is used or (b) serverName is explicitly specified in connection options | mention | `ceb5ac0` sql: strip IPv6 brackets from the TLS server name, send no SNI for an IP host (#42766) |
| #8872 Bun server.reload certFile & keyFile | mention | `754ea34` node:tls: make Server.setSecureContext() replace the listening socket's TLS context (#430… |
```

Issues and commits link to GitHub. **closing keyword** means a commit says `fix`/`fixes`/`fixed`, `close`/`closes`/`closed` or `resolve`/`resolves`/`resolved` followed by `#N`: those are the strongest candidates and are listed first. **mention** means a commit only mentions `#N`: worth a look, not proof.

How it decides:

- Only bare `#N` references count (not `other-org/other-repo#N`), and only issues, never pull requests.
- GitHub's own pull request references are ignored: the trailing `(#N)` of a squash merge and `Merge pull request #N`, which always point at the PR that carried the commit.
- A commit older than the issue can't be about it, so it's ignored.
- In a repo with more than 1,000 open issues it looks up each referenced number instead of listing every issue, up to 150 per run (closing keywords first); the report says so when it hits that cap.

When there is at least one candidate (or a repo can't be read), the run ends as `failed` on purpose and you get a notification. When there are none, it stays quiet. If the pipeline stops running for eight days, you get a notification too (`stale_after: 192h`).

## Notifications

By default, a macOS notification (`notify.channel: macos`). To get it on your phone instead, set `NTFY_TOPIC` in `.env` and change the channel to `ntfy` in [`pipeline.yaml`](pipeline.yaml). See the [main README](../../README.md#notifications).

## Safety

Read-only: it only makes `GET` requests to `api.github.com` (the repo, its recent commits on the default branch, and its open issues) and writes the report under `reports/issues-already-fixed/`. It never closes, comments on or labels an issue.
