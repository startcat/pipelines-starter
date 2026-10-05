#!/bin/sh
# Saves a Markdown report read from stdin as reports/<pipeline>/<date>.md and
# reports/<pipeline>/latest.md (relative to the data repo root), and prints
# {"report": "<path>", "headline": "<first line>"} on stdout.
# Usage, from a step (whose cwd is pipelines/<name>/):
#   ... | sh ../../scripts/write-report.sh <pipeline-name>
set -eu
name="$1"
root=$(cd "$(dirname "$0")/.." && pwd)
dir="$root/reports/$name"
mkdir -p "$dir"
file="$dir/$(date +%Y-%m-%d).md"
cat > "$file"
cp "$file" "$dir/latest.md"
headline=$(grep -m1 -v '^[[:space:]]*$' "$file" | sed 's/^#* *//' || true)
jq -n --arg r "$file" --arg h "$headline" '{report: $r, headline: $h}'
