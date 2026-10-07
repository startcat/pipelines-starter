# news-digest

Reads your RSS/Atom feeds every morning (blogs, YouTube channels, Hacker News...) and has an agent write **a short digest of what's new**, grouped by topic and linked, plus three content ideas for your own audience.

Uses one agent step (Sonnet): about $0.15 per run with ~25 new items, capped at $0.50. Days with nothing new cost nothing (the agent is skipped).

To make it cheaper, change `model: sonnet` to `model: haiku` in [`agents/news-editor.md`](../../agents/news-editor.md): Haiku costs half as much per token. In our test of news-digest, a run went from about $0.15 to $0.11; check that the result is good enough for you.

## Before you start

You need an Anthropic API key in `.env` as `ANTHROPIC_API_KEY`. Create one in the [Claude Console](https://platform.claude.com/); the agent's runs are billed to it at API prices.

## Install

```bash
cd pipelines-starter
pipelines doctor news-digest
pipelines install news-digest --set feeds="https://simonwillison.net/atom/everything/ https://hnrss.org/frontpage"
```

That's it: from tomorrow it runs every day at 10:00 (not earlier, because of YouTube; see below). To try it right now:

```bash
pipelines run news-digest --set feeds="https://simonwillison.net/atom/everything/ https://hnrss.org/frontpage"
```

The first run covers the last 48 hours; after that, each run only shows what was published since the previous digest.

**YouTube channels** have a feed too: `https://www.youtube.com/feeds/videos.xml?channel_id=<ID>`. The ID starts with `UC`; to find it, open the channel page, view the page source and search for `"externalId"`, or run:

```bash
curl -sL https://www.youtube.com/@anthropic-ai | grep -oE '"externalId":"UC[^"]+"'
```

On most days, YouTube's feeds answer 404 for every channel for a few hours until midnight Pacific time, which is the early morning in Europe. A 404 then doesn't mean the channel ID is wrong, and retrying a few seconds later doesn't help. That's why the schedule is 10:00; if you change it, or you're in a time zone where 10:00 falls in that window, pick an hour after midnight Pacific. A feed that fails one day is caught up by the next run that reads it.

## Configure

| Param | Default | What it does |
|---|---|---|
| `feeds` | (required) | Space-separated list of RSS or Atom feed URLs. |
| `topics` | `software development and AI` | What you care about, in plain words. Unrelated items are left out of the digest (but counted). |
| `ideas_for` | `a small software studio's blog` | Who the three content ideas are for: your blog, newsletter, channel... |
| `language` | `English` | Language the digest is written in. |
| `max_items` | `40` | Most new items handed to the agent per run (the newest win). |
| `workdir` | (empty) | Where the fetched items and the state file live. Empty means `~/Library/Application Support/pipelines/workspaces/news-digest`. |

Change a param later with `pipelines install news-digest --set topics="Rust, databases and developer tooling"` (the others are kept). To add a feed, set `feeds` again with the full list; a new feed starts with its last 48 hours. To change the schedule, edit `triggers.cron` in [`pipeline.yaml`](pipeline.yaml) and run `pipelines install news-digest` again.

## What you get

A report at `reports/news-digest/latest.md` (and one per day next to it). Excerpt of a real run over two YouTube channels, Simon Willison's blog, the Hacker News front page and one broken URL:

```markdown
# 24 new items · 16 worth a look

No single story dominates today; it's a spread of AI-model performance news, cost-control debates, and a batch of developer-tool releases and retro-software pieces on HN.

## AI models, performance and cost

- [How Anthropic made Claude 3x faster](https://www.youtube.com/watch?v=FsDUOUV9Vs8): Video walkthrough of Anthropic's blog post on how they made Claude faster after the Opus 5.5 release. · Theo - t3․gg
- [We're going to need default hard budget caps on pretty much everything](https://simonwillison.net/2026/Oct/3/default-hard-budget-caps/): Argues pay-by-usage APIs and services need a standard feature to cut off access once a spending limit is hit. · Simon Willison's Weblog

## Content ideas

**Designing Hard Budget Caps for AI Features in Client Projects**
Walk through how a studio would implement Simon Willison's proposed "default hard budget cap" in a client-facing AI feature, so a runaway prompt loop can't blow a client's monthly bill. Builds on: [We're going to need default hard budget caps on pretty much everything](https://simonwillison.net/2026/Oct/3/default-hard-budget-caps/).

*8 items were skipped as unrelated to software development and AI, including "Germany's RobCo hits $1B valuation," ...*

---

Sources: 4 feed(s) read, 80 items, 24 new since the last digest. Failed: https://example.invalid/feed.xml (Could not resolve host: example.invalid).
```

Each feed is tried up to three times, five seconds apart, because YouTube feeds sometimes answer 404 for a moment. A feed that still fails (down, moved, not a feed) is listed at the bottom and the rest still runs; the run only fails if every feed fails. When nothing is new, the report is one line (`# No new items since the last digest`) and no agent runs. If the pipeline stops running for two days, you get a notification too (`stale_after: 50h`).

## Notifications

By default, a macOS notification (`notify.channel: macos`) every morning with the headline (`24 new items · 16 worth a look`), and one if the run fails. To get it on your phone instead, set `NTFY_TOPIC` in `.env` and change the channel to `ntfy` in [`pipeline.yaml`](pipeline.yaml). See the [main README](../../README.md#notifications).

## Safety

Read-only on the outside: it only downloads the feeds you list (plain HTTP GETs with `curl`). Parsing uses `xsltproc`/`xmllint` with network access off. It writes only to its workspace (`items.json`, `state.json`) and to `reports/news-digest/`. The agent can only read files in the workspace (`Read`, `Glob`), has no network or shell access, and is told to state only what the items say and link every item it mentions.
