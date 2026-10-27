#!/bin/sh
# Default notification channel: a macOS notification on a Mac, ntfy anywhere else.
# The engine passes the run through PIPELINES_NOTIFY_*; both scripts read it.
set -eu
if [ "$(uname -s)" = "Darwin" ]; then
  exec sh scripts/notify-macos.sh
fi
# The engine only forwards the env vars a channel declares in `env:`, and
# declaring NTFY_TOPIC here would make a Mac require it too. So outside macOS
# this script reads NTFY_TOPIC (and NTFY_SERVER) from ./.env itself (the channel
# runs from the repo root). It extracts the values; it never sources the file.
# It accepts CRLF line endings, an optional leading `export `, quotes, and a
# trailing ` # comment` after an unquoted value.
env_value() {
  [ -f .env ] || return 0
  raw=$(tr -d '\r' < .env | sed -n "s/^\(export \)\{0,1\}$1=//p" | tail -n 1)
  case $raw in
    \"*) printf '%s\n' "$raw" | sed 's/^"\([^"]*\)".*$/\1/' ;;
    \'*) printf '%s\n' "$raw" | sed "s/^'\\([^']*\\)'.*\$/\\1/" ;;
    *) printf '%s\n' "$raw" | sed 's/[[:space:]][[:space:]]*#.*$//; s/[[:space:]]*$//' ;;
  esac
}
if [ -z "${NTFY_TOPIC:-}" ]; then
  NTFY_TOPIC=$(env_value NTFY_TOPIC)
fi
if [ -z "${NTFY_SERVER:-}" ]; then
  NTFY_SERVER=$(env_value NTFY_SERVER)
fi
if [ -z "$NTFY_TOPIC" ]; then
  echo "The default channel outside macOS sends through ntfy and needs NTFY_TOPIC in .env (see README)." >&2
  exit 1
fi
export NTFY_TOPIC
# An empty NTFY_SERVER would defeat notify-ntfy.sh's default (it uses :-).
[ -n "$NTFY_SERVER" ] && export NTFY_SERVER
exec sh scripts/notify-ntfy.sh
