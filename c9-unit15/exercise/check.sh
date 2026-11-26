#!/bin/sh
# Course 9 unit 15's exercise check. Needs the servers sh build.sh built (../.harness/servers/). Starts server A (the member route at
# /probe/people) on PORT (default 21048; H2 in memory, the harness's copy, the harness's access log), runs CLIENT_FILE, stops A by its
# recorded pid; then server B (the route moved to /probe/members) on the same port, the same CLIENT_FILE again. PASS only if:
#   (1) against A the client prints Ravi, exit 0
#   (2) against B the SAME file prints Ravi, exit 0
#   (3) each server's access log shows the client's GET /probe/entry BEFORE its member request
#   (4) the client's source holds neither /probe/people nor /probe/members (the path is read, not written)
#   (5) in each server, the client's member request path equals the href the entry point answers
#   (6) the client writes no file (no open(...) for writing): it cannot carry A's link over to B
# Usage: sh check.sh CLIENT_FILE   (a COPY of client.py; client.py itself is refused unless --allow-broken)
AB=""; [ "$1" = "--allow-broken" ] && { AB=1; shift; }
F=${1:?usage: sh check.sh [--allow-broken] CLIENT_FILE}
HERE=$(cd "$(dirname "$0")" && pwd -P); S="$HERE/../.harness/servers"
[ -f "$F" ] || { echo "check.sh: no such file: $F"; exit 1; }
FD=$(cd "$(dirname "$F")" && pwd -P); FA="$FD/$(basename "$F")"
[ "$FA" != "$HERE/client.py" ] || [ -n "$AB" ] || { echo "check.sh: refused - that is client.py itself; copy it first (or --allow-broken to see the shipped answer)"; exit 1; }
[ -d "$S/A" ] && [ -d "$S/B" ] && [ -f "$S/copy/tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar" ] || { echo "check.sh: run build.sh first"; exit 3; }
PORT=${PORT:-21048}; RUN="$S/check.run"; BB="http://127.0.0.1:$PORT"; X="$S/copy/tiffinbox-web/target/extracted"
rm -rf "$RUN"; mkdir -p "$RUN/cwd"
serve() { side=$1; r="$RUN/$side"; mkdir -p "$r/secrets/tiffinbox"; (umask 077 && openssl rand -hex 16 > "$r/secrets/tiffinbox/shutdown-token")
  (cd "$r" && exec java -Duser.language=en -Duser.country=US -cp "$X/tiffinbox-web-1.0.0.jar:$X/lib/*:$S/$side" com.tiffinbox.web.TiffinBoxServer \
     --tiffinbox.port="$PORT" --spring.main.sources=probe.u15.U15Config --server.tomcat.accesslog.enabled=true "--server.tomcat.accesslog.directory=$r" \
     --server.tomcat.accesslog.prefix=access --server.tomcat.accesslog.suffix=.log --server.tomcat.accesslog.rotate=false \
     --server.tomcat.accesslog.buffered=false '--server.tomcat.accesslog.pattern=%m %U %s' > jvm.log 2>&1) &
  echo $! > "$r/pid"; i=0
  while ! grep -q 'Started TiffinBox' "$r/jvm.log" 2> /dev/null; do kill -0 "$(cat "$r/pid")" 2> /dev/null || { echo "check.sh: server $side exited before it started"; exit 1; }; i=$((i + 1)); [ $i -lt 600 ] || { echo "check.sh: server $side: no Started line"; exit 1; }; sleep 0.1; done; }
halt() { r="$RUN/$1"; p=$(cat "$r/pid")
  printf 'X-Shutdown-Token: %s\n' "$(cat "$r/secrets/tiffinbox/shutdown-token")" | curl --noproxy '*' -s -o /dev/null -H @- -X POST "$BB/shutdown"
  i=0; while kill -0 "$p" 2> /dev/null; do i=$((i + 1)); [ $i -lt 100 ] || { kill "$p"; break; }; sleep 0.1; done; wait "$p" 2> /dev/null; true; }
for side in A B; do
  serve $side || exit 1
  (cd "$RUN/cwd" && python3 -I "$FA" "$PORT" > "$RUN/$side.out" 2>&1); echo $? > "$RUN/$side.rc"
  cp "$RUN/$side/access.log" "$RUN/$side.client.log" 2> /dev/null || : > "$RUN/$side.client.log"
  curl --noproxy '*' --http1.1 -s -H 'Accept: application/hal+json' "$BB/probe/entry" > "$RUN/$side.entry"
  halt $side
  echo "server $side ($( [ $side = A ] && echo 'the member route at /probe/people' || echo 'moved to /probe/members')): the client printed: $(tr '\n' '|' < "$RUN/$side.out" | sed 's/|$//') (exit $(cat "$RUN/$side.rc"))"
  RQ=$(awk '{ print $1, $2, $3 }' "$RUN/$side.client.log" | tr '\n' ';' | sed 's/;$//')
  LK=$(python3 -I - "$RUN/$side.entry" <<'PY'
import json, re, sys
print(re.sub(r":[0-9]{4,5}", ":<port>", json.load(open(sys.argv[1]))["_links"]["ravi"]["href"]))
PY
)
  echo "server $side: the client's requests: ${RQ:-none} · the entry point's link: $LK"
done
python3 -I - "$RUN" "$FA" <<'PY'
import json, os, re, sys
run, f = sys.argv[1:3]
bad = []
src = open(f, encoding="utf-8").read()
for side, n in (("A", 1), ("B", 2)):
    out = open(os.path.join(run, side + ".out")).read().split()
    rc = open(os.path.join(run, side + ".rc")).read().strip()
    if not (rc == "0" and out and out[-1] == "Ravi"):
        bad.append("clause %d: against server %s the client does not print Ravi with exit 0 (exit %s)" % (n, side, rc))
    log = [l.split() for l in open(os.path.join(run, side + ".client.log")) if l.strip()]
    paths = [l[1] for l in log if len(l) > 1]
    href = re.sub(r"^https?://[^/]+", "", json.load(open(os.path.join(run, side + ".entry")))["_links"]["ravi"]["href"])
    member = [p for p in paths if p != "/probe/entry"]
    if not ("/probe/entry" in paths and member and paths.index("/probe/entry") < paths.index(member[0])):
        bad.append("clause 3: server %s's access log does not show GET /probe/entry before the member request (%d lines)" % (side, len(paths)))
    if not (member and member[-1] == href):
        bad.append("clause 5: on server %s the client's member request (%s) is not the href the entry point answers (%s)" % (side, member[-1] if member else "none", href))
if re.search(r"/probe/(?:people|members)", src):
    bad.append("clause 4: the client's source writes the member's path in")
if re.search(r"open\([^)]*['\"][wax]", src) or "write_text" in src or ".write(" in src:
    bad.append("clause 6: the client writes a file (a link carried between servers)")
for b in bad:
    print("FAIL " + b)
print("PASS - every clause holds" if not bad else "check.sh: %d clause(s) failed" % len(bad))
sys.exit(1 if bad else 0)
PY
rc=$?; rm -rf "$RUN"; exit $rc
