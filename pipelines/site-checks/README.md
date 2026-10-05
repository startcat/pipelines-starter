# site-checks

Checks a list of websites every morning and **alerts you only when something is wrong**: a page that doesn't answer, an HTTP error, a slow response or a TLS certificate about to expire.

Shell only: no agent, no tokens, no cost.

## Install

```bash
cd pipelines-starter
pipelines doctor site-checks
pipelines install site-checks --set urls="https://example.com https://example.com/sitemap.xml"
```

That's it: from tomorrow it runs every day at 08:00. To try it right now:

```bash
pipelines run site-checks --set urls="https://example.com"
```

## Configure

| Param | Default | What it does |
|---|---|---|
| `urls` | (required) | Space-separated list of URLs. Add your sitemap or any page that must stay up. |
| `cert_warn_days` | `14` | Warn when a certificate expires in fewer days than this. |
| `slow_ms` | `3000` | Warn when a page takes longer than this to answer, in milliseconds. |

Change a param later with `pipelines install site-checks --set slow_ms=5000` (the others are kept). To change the schedule, edit `triggers.cron` in [`pipeline.yaml`](pipeline.yaml) and run `pipelines install site-checks` again.

## What you get

A report at `reports/site-checks/latest.md` (and one per day next to it):

```markdown
# 1 site(s) need attention

| URL | HTTP | Time | Cert (days) | Status |
|---|---|---|---|---|
| https://example.com | 200 | 208 ms | 61 | ok |
| https://shop.example.com | 500 | 481 ms | 89 | HTTP 500 |
```

When any site has a problem, the run ends as `failed` on purpose and you get a notification. When everything is fine, it stays quiet. If the pipeline stops running for two days, you get a notification too (`stale_after: 50h`).

## Notifications

By default, a macOS notification (`notify.channel: macos`). To get it on your phone instead, set `NTFY_TOPIC` in `.env` and change the channel to `ntfy` in [`pipeline.yaml`](pipeline.yaml). See the [main README](../../README.md#notifications).

## Safety

Read-only: it only makes HTTP requests and TLS handshakes to the URLs you list.
