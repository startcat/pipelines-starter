#!/bin/sh
# ntfy.sh channel: pushes the run status to your phone. On success, the body is
# the pipeline's latest report (Markdown), if it wrote one.
# Needs NTFY_TOPIC in .env. NTFY_SERVER overrides https://ntfy.sh.
set -eu
name="${PIPELINES_NOTIFY_NAME:-pipeline}"
status="${PIPELINES_NOTIFY_STATUS:-}"
server="${NTFY_SERVER:-https://ntfy.sh}"
latest="reports/$name/latest.md"
if [ "${PIPELINES_NOTIFY_STALE:-}" = "1" ]; then
  body="No successful run since ${PIPELINES_NOTIFY_LAST_SUCCESS:-ever}."
elif [ "$status" = "success" ] && [ -f "$latest" ]; then
  body=$(head -c 3500 "$latest")
else
  body="${PIPELINES_NOTIFY_REASON:-$status}"
fi
priority=default
[ "$status" = "failed" ] && priority=high
printf '%s' "$body" | curl -fsS --max-time 15 \
  -H "Title: $name: $status" -H "Priority: $priority" -H "Markdown: yes" \
  --data-binary @- "$server/$NTFY_TOPIC" >/dev/null
