#!/bin/sh
# Course 9 unit 23's exercise check: check.sh DIR/answer.txt - derives the key from DIR/scrape.txt (the 404 rows by uri) and
# mappings.txt (the tree's route patterns, frozen from /actuator/mappings), then compares your answer with it, clause by clause.
# It sends no request: it reads the two files only.
A=$1
[ -f "$A" ] || { echo "usage: sh check.sh DIR/answer.txt (run.sh DIR writes DIR/scrape.txt and an empty DIR/answer.txt)"; exit 2; }
HERE=$(cd "$(dirname "$0")" && pwd)
python3 -I - "$A" "$(dirname "$A")/scrape.txt" "$HERE/mappings.txt" <<'PY'
import re, sys
ans, sc, mp = sys.argv[1], sys.argv[2], sys.argv[3]
routes = {l.split(" ", 1)[1] for l in open(mp).read().splitlines() if l.startswith("route ")}
key = {}
for l in open(sc).read().splitlines():
    if l.startswith("http_server_requests_seconds_count{") and 'status="404"' in l:
        u = re.search(r'uri="([^"]*)"', l).group(1); key[u] = key.get(u, 0) + int(float(l.rsplit(" ", 1)[1]))
notroute = sorted(u for u in key if u not in routes)
if len(notroute) != 1:
    print("the scrape's 404 rows hold %d uri values that are not a route pattern (%s) - the exercise needs exactly one" % (len(notroute), notroute)); sys.exit(2)
rows, nr, other = {}, [], []
for l in open(ans).read().splitlines():
    if not l.strip(): continue
    m = re.match(r"^not a route: (\S+)$", l)
    if m: nr.append(m.group(1)); continue
    m = re.match(r"^(\S+) (\d+)$", l)
    if m and m.group(1) not in rows: rows[m.group(1)] = int(m.group(2))
    else: other.append(l)
fails = []
bad = [u for u in key if rows.get(u) != key[u]]
if bad: fails.append("(1) a 404 row's count is missing or differs from the scrape: %s" % ", ".join(sorted(bad)))
extra = [u for u in rows if u not in key]
if extra: fails.append("(2) a row of another status is counted: %s" % ", ".join(sorted(extra)))
if nr != notroute: fails.append("(3) the not-a-route line must name the one 404 uri that is no route pattern of the tree (you wrote: %s)" % (", ".join(nr) or "nothing"))
if other: fails.append("(4) a line that is neither '<uri> <count>' nor 'not a route: <uri>': %s" % other[0])
for f in fails: print("FAIL " + f)
if fails: sys.exit(1)
print("PASS: %d 404 rows counted by uri, and the not-a-route line names the catch-all pattern" % len(key))
PY
