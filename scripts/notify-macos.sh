#!/bin/sh
# macOS notification channel. The engine passes the run through PIPELINES_NOTIFY_*.
# If the pipeline wrote a report, the notification shows its first line.
set -eu
name="${PIPELINES_NOTIFY_NAME:-pipeline}"
status="${PIPELINES_NOTIFY_STATUS:-}"
latest="reports/$name/latest.md"
if [ "${PIPELINES_NOTIFY_STALE:-}" = "1" ]; then
  msg="No successful run since ${PIPELINES_NOTIFY_LAST_SUCCESS:-ever}."
elif [ "$status" = "success" ] && [ -f "$latest" ]; then
  msg=$(grep -m1 -v '^[[:space:]]*$' "$latest" | sed 's/^#* *//' || true)
else
  msg="${PIPELINES_NOTIFY_REASON:-$status}"
fi
# Keep it short and strip characters that would break the AppleScript string.
msg=$(printf '%s' "$msg" | tr '\n"\\' '   ' | cut -c1-200)
osascript -e "display notification \"$msg\" with title \"$name: $status\""
