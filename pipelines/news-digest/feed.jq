# Turns the tab-separated lines printed by feed.xsl (one feed) into one JSON
# object: {url, source, total, undated, newest, items: [...]}, where items are
# only the ones published after $since (epoch seconds), newest first.
# Usage: jq -R -s --arg url URL --argjson since EPOCH -f feed.jq feed.tsv

# Seconds east of UTC for a time zone suffix: Z, +02:00, -0700, GMT, PDT...
def tzoff:
  if . == null or . == "" or . == "Z" or . == "GMT" or . == "UTC" or . == "UT" then 0
  elif test("^[+-][0-9]{2}:?[0-9]{2}$") then
    gsub(":"; "") as $z
    | (($z[1:3] | tonumber) * 3600 + ($z[3:5] | tonumber) * 60) * (if $z[0:1] == "-" then -1 else 1 end)
  else ({"EST": -5, "EDT": -4, "CST": -6, "CDT": -5, "MST": -7, "MDT": -6, "PST": -8, "PDT": -7}[.] // 0) * 3600
  end;

# ISO 8601 (Atom) or RFC 822 (RSS) date to epoch seconds; null if unparseable.
# Month names are mapped by hand: strptime's %b depends on the platform/locale.
def to_epoch:
  (. // "") as $d
  | if ($d | test("^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}")) then
      $d | capture("^(?<b>[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2})(?<s>:[0-9]{2})?([.][0-9]+)?(?<z>Z|[+-][0-9]{2}:?[0-9]{2})?")
      | ((.b + (.s // ":00") + "Z") | strptime("%Y-%m-%dT%H:%M:%SZ") | mktime) - (.z | tzoff)
    elif ($d | test("[0-9]{1,2} [A-Za-z]{3} [0-9]{4} [0-9]{1,2}:[0-9]{2}")) then
      $d | capture("(?<d>[0-9]{1,2}) (?<m>[A-Za-z]{3}) (?<y>[0-9]{4}) (?<h>[0-9]{1,2}):(?<mi>[0-9]{2})(:(?<s>[0-9]{2}))?( (?<z>[^ ]+))?")
      | ({"jan": "01", "feb": "02", "mar": "03", "apr": "04", "may": "05", "jun": "06",
          "jul": "07", "aug": "08", "sep": "09", "oct": "10", "nov": "11", "dec": "12"}[.m | ascii_downcase]) as $mon
      | if $mon == null then null
        else ("\(.y)-\($mon)-\(.d) \(.h):\(.mi):\(.s // "00")" | strptime("%Y-%m-%d %H:%M:%S") | mktime) - (.z | tzoff)
        end
    else null end;

# HTML to plain text: drop tags, decode the usual entities, collapse spaces.
def plain:
  gsub("<[^>]*>"; " ")
  | gsub("&#(?<n>[0-9]{1,6});"; [.n | tonumber] | implode)
  | gsub("&quot;"; "\"") | gsub("&apos;|&#x27;"; "'") | gsub("&lt;"; "<") | gsub("&gt;"; ">")
  | gsub("&nbsp;"; " ") | gsub("&amp;"; "&")
  | gsub("[[:space:]]+"; " ") | ltrimstr(" ") | rtrimstr(" ");

def clip($n): if length > $n then .[0:$n] + "…" else . end;

[ split("\n")[] | select(length > 0) | split("\t")
  | { source: (.[0] // "" | plain), title: (.[1] // "" | plain), link: (.[2] // ""),
      epoch: (.[3] | to_epoch), summary: (.[4] // "" | plain | clip(280)) } ] as $all
| ($all | map(select(.epoch != null))) as $dated
| {
    url: $url,
    source: (($all[0].source // "") | if . == "" then $url else . end),
    total: ($all | length),
    undated: (($all | length) - ($dated | length)),
    newest: ([$since] + ($dated | map(.epoch)) | max),
    items: ($dated | map(select(.epoch > $since)) | sort_by(-.epoch)
            | map({source, title, link, published: (.epoch | todate), epoch, summary}))
  }
