#!/bin/sh
# Default notification channel: a macOS notification on a Mac, ntfy anywhere else.
# The engine passes the run through PIPELINES_NOTIFY_*; both scripts read it.
set -eu
if [ "$(uname -s)" = "Darwin" ]; then
  exec sh scripts/notify-macos.sh
fi
if [ -z "${NTFY_TOPIC:-}" ]; then
  echo "The default channel outside macOS sends through ntfy and needs NTFY_TOPIC in .env (see README)." >&2
  exit 1
fi
exec sh scripts/notify-ntfy.sh
