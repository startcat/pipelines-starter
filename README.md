# pipelines-starter

Seven ready-to-use pipelines for [agentic-pipelines](https://github.com/startcat/agentic-pipelines): small, useful jobs that run on their own on your Mac, every day or every week, and tell you when something needs your attention.

| Pipeline | What it does | Agent | Schedule |
|---|---|---|---|
| [site-checks](pipelines/site-checks/) | Checks your websites: HTTP errors, slow pages, TLS certificates about to expire. Alerts only when something is wrong. | — | daily |
| [stale-prs](pipelines/stale-prs/) | Pull requests in your GitHub repos that nobody has touched for days. | — | weekdays |
| [issues-already-fixed](pipelines/issues-already-fixed/) | Open issues that a merged commit already references, so they are probably done. | — | weekly |
| [dev-machine-doctor](pipelines/dev-machine-doctor/) | Disk space, the biggest developer caches, open ports and forgotten processes on your Mac. Read-only. | — | weekly |
| [weekly-briefing](pipelines/weekly-briefing/) | A plain-language summary of the week in your repos, for someone who doesn't read pull requests. | ✓ | Fridays |
| [docs-drift](pipelines/docs-drift/) | Compares a repo's docs with its code and prepares fixes on a local branch. Never pushes. | ✓ | weekly |
| [news-digest](pipelines/news-digest/) | Reads your RSS feeds and YouTube channels and writes a digest with content ideas. | ✓ | daily |

Every pipeline is **read-only by default**: nothing pushes, merges, closes or deletes.

**What it costs.** The four shell-only pipelines don't use AI and cost nothing. The three with an agent call the Anthropic API with your key and cap their spend per run (`max_cost_usd`). At API prices, with Sonnet, our test runs cost about $0.25 per weekly briefing, $0.15 per news digest and $0.20–0.35 per docs review. To make them cheaper, switch an agent to `model: haiku` in `agents/` (half the price per token).

## Quick start

**1. Install the engine** (needs macOS, [Bun](https://bun.sh), `git` and `jq`; the pipelines with an agent also need an [Anthropic API key](https://platform.claude.com/)):

```bash
git clone https://github.com/startcat/agentic-pipelines.git ~/agentic-pipelines
cd ~/agentic-pipelines && bun install
alias pipelines="bun run ~/agentic-pipelines/src/cli/index.ts"   # add this line to your ~/.zshrc
```

**2. Get the starter** — click **Use this template** on GitHub to get your own copy, or clone it:

```bash
git clone https://github.com/startcat/pipelines-starter.git ~/pipelines-starter
cd ~/pipelines-starter
cp .env.example .env      # API key for the agent pipelines, GitHub token, phone notifications
```

**3. Install the pipelines you want.** Each one is a single command; its README explains every option.

```bash
pipelines install site-checks --set urls="https://example.com"
pipelines install stale-prs --set repos="your-org/your-repo"
pipelines install issues-already-fixed --set repos="your-org/your-repo"
pipelines install dev-machine-doctor
pipelines install weekly-briefing --set repos="your-org/your-repo"
pipelines install docs-drift --set repo_url="https://github.com/your-org/your-repo.git"
pipelines install news-digest --set feeds="https://simonwillison.net/atom/everything/"
```

`install` checks that your Mac has everything the pipeline needs, saves your settings in `.params.local.json` (gitignored) and schedules it with `launchd`. To try a pipeline right now instead of waiting for its schedule, use `run` with the same `--set` options:

```bash
pipelines run site-checks --set urls="https://example.com"
```

## Where things end up

| What | Where |
|---|---|
| Reports | `reports/<pipeline>/latest.md`, plus one file per day next to it |
| Your settings | `.params.local.json` (written by `install --set`) |
| Secrets | `.env` (`ANTHROPIC_API_KEY`, `GITHUB_TOKEN` and, optionally, `NTFY_TOPIC`) |
| Run history | `.runs/` — or browse it with `pipelines web` |
| Clones and work files of the agent pipelines | `~/Library/Application Support/pipelines/workspaces/<pipeline>/` |

All of these are gitignored.

## Notifications

Each pipeline declares when it notifies (`notify.on`) and through which channel (`notify.channel`). Two channels are included in [`pipelines.yaml`](pipelines.yaml):

- **`macos`** (default): a macOS notification with the first line of the report. Works with no setup. The first time, macOS may ask you to allow notifications for Script Editor.
- **`ntfy`**: a push notification on your phone with the full report, through [ntfy.sh](https://ntfy.sh). Install the ntfy app, subscribe to a long, hard-to-guess topic name, put it in `.env` as `NTFY_TOPIC=...`, and change `channel: macos` to `channel: ntfy` in the pipelines you want on your phone.

Alert-style pipelines (site-checks, stale-prs, issues-already-fixed, dev-machine-doctor) only notify when there is something to look at. Digest-style ones (weekly-briefing, docs-drift, news-digest) notify every time they produce a report. All of them warn you if they stop running (`stale_after`).

## Day to day

The quickest way to see how everything is going is the engine's local dashboard: `pipelines web` opens it at http://127.0.0.1:7717. It shows which pipelines are scheduled, which failed their last run, what each run cost, what every step did and which actions the engine denied an agent. A pipeline that is installed but has stopped running shows up in red there too. See [the dashboard](https://github.com/startcat/agentic-pipelines#the-dashboard).

```bash
pipelines status                    # last runs of every pipeline
pipelines show <pipeline> <run-id>  # everything about one run
pipelines web                       # local dashboard at http://127.0.0.1:7717
pipelines uninstall <pipeline>      # stop scheduling it (keeps your settings and reports)
```

To change a setting, run `pipelines install <pipeline> --set key=value` again: the other settings are kept. To change a schedule, edit `triggers.cron` in the pipeline's `pipeline.yaml` and run `install` again.

## Make your own

Every pipeline here is a plain `pipeline.yaml` you can copy and adapt. The engine's [README](https://github.com/startcat/agentic-pipelines#your-first-pipeline-in-ten-minutes) walks you through writing one in ten minutes, and the [reference](https://github.com/startcat/agentic-pipelines/blob/main/docs/reference.md) documents every field. Check yours with `pipelines validate`.

## License

MIT — see [LICENSE](LICENSE). Built by [Start.cat](https://start.cat), a software studio in Barcelona.
