# weekly-briefing

Every Friday afternoon, writes a **short, plain-language briefing of what happened in your GitHub repos this week**, for someone who doesn't read code: a manager, a client, a sales team. What shipped, what got fixed, what's in progress and, only when it's warranted, what needs a decision.

One agent step (Sonnet), capped at $0.50. In testing, a busy repo (68 merged pull requests, 124 new issues) cost about **$0.25 per run**. A week with no activity costs nothing: the agent is skipped.

To make it cheaper, change `model: sonnet` to `model: haiku` in [`agents/briefing-writer.md`](../../agents/briefing-writer.md): Haiku costs half as much per token. In our test of news-digest, a run went from about $0.15 to $0.11; check that the result is good enough for you.

## Before you start

You need two things in `.env`: an Anthropic API key as `ANTHROPIC_API_KEY` (create one in the [Claude Console](https://platform.claude.com/); the agent's runs are billed to it at API prices), and a GitHub token as `GITHUB_TOKEN`. Create a [fine-grained token](https://github.com/settings/personal-access-tokens/new) with access to the repositories you want to cover and these **read-only** permissions: **Contents**, **Issues**, **Pull requests**. For public repos only, a token with no extra permissions is enough.

```bash
cp .env.example .env   # then paste the key and the token
```

## Install

```bash
cd pipelines-starter
pipelines doctor weekly-briefing
pipelines install weekly-briefing --set repos="acme/api acme/web"
```

That's it: it runs every Friday at 16:00. To try it right now:

```bash
pipelines run weekly-briefing --set repos="acme/api"
```

## Configure

| Param | Default | What it does |
|---|---|---|
| `repos` | (required) | Space-separated repositories as `owner/name`. One briefing covers all of them. |
| `days` | `7` | How many days back to look. |
| `audience` | `a non-technical manager` | Who reads it. The agent adapts tone and detail, e.g. `"the sales team"` or `"our client at Acme"`. |
| `language` | `English` | Language of the briefing, e.g. `Spanish`. |
| `include_releases` | `true` | Also read the notes of releases published in the period. |
| `workdir` | (empty) | Where the collected data is written for the agent. Empty means `~/Library/Application Support/pipelines/workspaces/weekly-briefing`. |

Change a param later with `pipelines install weekly-briefing --set audience="the sales team"` (the others are kept). To change the schedule, edit `triggers.cron` in [`pipeline.yaml`](pipeline.yaml) and run `pipelines install weekly-briefing` again. The wording of the briefing lives in [`steps/write.md`](steps/write.md): edit it to change the sections or the length.

## What you get

A report at `reports/weekly-briefing/latest.md` (and one per week next to it). A real one, from a test run against `oven-sh/bun` (shortened):

```markdown
# Week 41: 68 changes shipped in oven-sh/bun

_Mon 28 Sep 2026 to Mon 05 Oct 2026_

- **More reliable secure connections and web requests** — Several fixes improve how Bun
  handles secure (TLS) connections and DNS lookups, including a fix for users behind VPNs
  or Apple's iCloud Private Relay who were getting incorrect "not found" errors.
  ([#44519](…), [#44290](…), [#43962](…))
- **Lighter memory use** — Updates to underlying system components reduce memory held by
  idle worker threads and speed up allocation, which should help long-running processes
  stay leaner. ([#44575](…), [#44564](…), [#44560](…))
- **New security option** — Added a setting that lets security-conscious teams block code
  from being generated out of plain text strings, closing off a common attack path. ([#44171](…))

## Needs a decision

- No release was published this week despite the large number of fixes merged. Teams
  waiting on any of the above will need to know when the next release is expected.
```

When nothing happened in any of the repos, the agent doesn't run and the report is a single line: `# Week 41: no activity in acme/api`.

## Notifications

Digest-style: you get a notification after every run, with the headline as the message, and also when a run fails (for example, an expired token). If it hasn't run successfully for eight days, you get a notification too (`stale_after: 192h`). By default it's a macOS notification (`notify.channel: macos`); to get it on your phone, set `NTFY_TOPIC` in `.env` and change the channel to `ntfy` in [`pipeline.yaml`](pipeline.yaml). See the [main README](../../README.md#notifications).

## Safety

Read-only. A shell step calls the GitHub REST API with your token (search for merged pull requests and issues, list releases) and writes the results as Markdown files into the workspace. The agent can only read those files (`Read`, `Glob`, `Grep`); it has no network, no shell and no access to your token. The report is saved under `reports/weekly-briefing/`. Nothing is posted, commented, closed or changed on GitHub.
