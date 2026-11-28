#!/bin/sh
# Course 9 unit 23's exercise solution: apply.sh DIR - writes DIR/answer.txt from DIR/scrape.txt by one python step: the 404 rows
# grouped by uri, then the one uri among them that is no route pattern of mappings.txt.
D=$1
[ -f "$D/scrape.txt" ] || { echo "usage: sh apply.sh DIR (after run.sh DIR)"; exit 2; }
HERE=$(cd "$(dirname "$0")" && pwd)
python3 -I - "$D/scrape.txt" "$HERE/mappings.txt" "$D/answer.txt" <<'PY'
import re, sys
routes = {l.split(" ", 1)[1] for l in open(sys.argv[2]).read().splitlines() if l.startswith("route ")}
key = {}
for l in open(sys.argv[1]).read().splitlines():
    if l.startswith("http_server_requests_seconds_count{") and 'status="404"' in l:
        u = re.search(r'uri="([^"]*)"', l).group(1); key[u] = key.get(u, 0) + int(float(l.rsplit(" ", 1)[1]))
out = ["%s %d" % (u, key[u]) for u in sorted(key)] + ["not a route: %s" % u for u in sorted(key) if u not in routes]
open(sys.argv[3], "w").write("".join(x + "\n" for x in out))
print("apply: wrote %d lines to answer.txt" % len(out))
PY
