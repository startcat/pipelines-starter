# dev-machine-doctor

Once a week, a read-only health check of your Mac as a development machine: **free disk, the biggest dev caches (with the exact command to clean each one), listening TCP ports and node/bun/python processes left running for days**. It alerts you only when free disk is low, and it never deletes or stops anything.

Shell only: no agent, no tokens, no cost. No token or network access needed.

## Install

```bash
cd pipelines-starter
pipelines doctor dev-machine-doctor
pipelines install dev-machine-doctor
```

That's it: it runs every Monday at 10:00. To try it right now:

```bash
pipelines run dev-machine-doctor
```

## Configure

| Param | Default | What it does |
|---|---|---|
| `min_free_gb` | `20` | Alert when free space on `/` is below this many GB. **The only thing that makes the run fail and notify.** |
| `orphan_hours` | `24` | List node, bun and python processes running for longer than this. |
| `du_timeout_s` | `240` | Maximum seconds to wait for the cache sizes (measured in parallel). A cache still being measured then shows as `timed out`. |

Change a param later with `pipelines install dev-machine-doctor --set min_free_gb=50` (the others are kept). To change the schedule, edit `triggers.cron` in [`pipeline.yaml`](pipeline.yaml) and run `pipelines install dev-machine-doctor` again.

## What you get

A report at `reports/dev-machine-doctor/latest.md` (and one per run next to it). An excerpt from a test run:

```markdown
# 112 GB free on /, dev caches use 20.6 GB

## Disk

112.8 GB free of 465.6 GB on `/` (alert below 20 GB).

## Dev caches

| Cache | Size | To clean it, run by hand |
|---|---|---|
| `~/Library/Caches` (all apps, includes Yarn below) | 7.4 GB | Per app folder: quit the app, then `rm -rf ~/Library/Caches/<folder>` |
| `~/Library/Developer/Xcode/DerivedData` | 5.8 GB | `rm -rf ~/Library/Developer/Xcode/DerivedData` (quit Xcode first; it rebuilds it) |
| `~/.npm` | 2.2 GB | `npm cache clean --force` |
| `~/.bun/install/cache` | 343 MB | `bun pm cache rm` |
| `~/Library/Caches/Yarn` | 3.8 GB | `yarn cache clean` |
| `~/.gradle/caches` | 4.9 GB | `rm -rf ~/.gradle/caches` (stop Gradle daemons first with gradle --stop) |

## Docker

Docker is not installed (or not on the usual paths): skipped.

## Listening TCP ports (7)

| Port | Process | PID | Listens on |
|---|---|---|---|
| 5000 | ControlCenter | 784 | all interfaces |
| 7679 | Google Drive | 2685 | local only |
| 17500 | Dropbox | 11862 | all interfaces |

## node / bun / python running for more than 24 h

None.
```

What it looks at:

- **Disk:** the space available on `/`. On APFS this doesn't count purgeable space, so Finder may show a bit more.
- **Caches:** only the ones that exist, out of `~/Library/Caches` (plus its 8 biggest app folders), Xcode's `DerivedData`, `~/.npm`, `~/.bun/install/cache`, `~/Library/Caches/Yarn` and `~/.gradle/caches`, and `docker system df` if Docker is installed and running (Docker is optional: not installed or stopped just means "skipped").
- **Ports:** `lsof -iTCP -sTCP:LISTEN` for your user's processes, with whether each one listens on all interfaces or only locally.
- **Processes:** your node, bun and python processes older than `orphan_hours`, with the `kill <pid>` you could run. Some may be a dev server you keep open on purpose: check before killing.

When free disk is below `min_free_gb`, the run ends as `failed` on purpose and you get a notification. Everything else (big caches, open ports, old processes) only goes in the report: no notification. If the pipeline stops running for eight days, you get a notification too (`stale_after: 192h`).

## Notifications

By default, a macOS notification (`notify.channel: macos`). To get it on your phone instead, set `NTFY_TOPIC` in `.env` and change the channel to `ntfy` in [`pipeline.yaml`](pipeline.yaml). See the [main README](../../README.md#notifications).

## Safety

Read-only. It runs `df`, `du`, `lsof`, `ps` and, if present, `docker system df`; it makes no network requests and writes only the report under `reports/dev-machine-doctor/`. The cleaning commands in the report are text for you to run by hand: the pipeline never deletes files, prunes Docker or kills processes.
