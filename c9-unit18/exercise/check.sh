#!/bin/sh
# Course 9 unit 18's exercise check: build TREE (a copy of ../after, offline from MAVEN_REPO when set), start its jar alone on PORT
# (default 21078; H2 in memory; the shipped lifetime, no flag), send the requests itself, and PASS only if every clause holds:
#   (1) the mint GET /api/v1/customers/Ravi/bill-link answers 200 with an href carrying expires and sig
#   (2) the minted link opens 200, text/csv, its body's md5 equal to the same run's GET /api/v1/customers/Ravi/bill body
#   (3) the bill route GET /api/v1/customers/Ravi/bill answers 200
#   (4) the same link with the name changed (Ravi -> Sunil) answers 403
#   (5) every src/main file but CustomerBills.java, the three poms and the spec md5-equal to ../after's (a fix elsewhere cannot pass)
#   (6) the signed handler's declared return type is not ResponseEntity<?>, not ResponseEntity<Object>, not a raw ResponseEntity
# Usage: sh check.sh TREE
T=${1:?usage: sh check.sh TREE}
HERE=$(cd "$(dirname "$0")" && pwd -P); AFTER=$(cd "$HERE/../after" && pwd -P)
[ "$(cd "$T" && pwd -P)" != "$AFTER" ] || { echo "check.sh: refused - that is ../after itself; copy it first"; exit 1; }
T=$(cd "$T" && pwd -P)
PORT=${PORT:-21078}; RUN="$HERE/check.run"; B="http://127.0.0.1:$PORT"
rm -f "$HERE/check.build.log" "$HERE/check.jvm.log" "$HERE/check.b" "$HERE/check.h" "$HERE/check.bill"; rm -rf "$RUN"
cd "$T" || exit 1
mvn -o -B -q ${MAVEN_REPO:+"-Dmaven.repo.local=$MAVEN_REPO"} -DskipTests clean package -pl tiffinbox-web -am > "$HERE/check.build.log" 2>&1 || { echo "check.sh: the tree did not build (check.build.log)"; exit 1; }
echo "built: mvn -o -DskipTests clean package -pl tiffinbox-web -am (exit 0)"
mkdir -p "$RUN/secrets/tiffinbox"; (umask 077 && openssl rand -hex 16 > "$RUN/secrets/tiffinbox/shutdown-token")
(cd "$RUN" && exec java -Duser.language=en -Duser.country=US -jar "$T/tiffinbox-web/target/tiffinbox-web-1.0.0.jar" --tiffinbox.port="$PORT" > "$HERE/check.jvm.log" 2>&1) &
JP=$!
i=0; while ! grep -q 'Started TiffinBox' "$HERE/check.jvm.log" 2> /dev/null; do kill -0 $JP 2> /dev/null || { echo "check.sh: the JVM exited before it started"; exit 1; }; i=$((i + 1)); [ $i -lt 600 ] || { kill $JP; echo "check.sh: no Started line"; exit 1; }; sleep 0.1; done
echo "started: the jar alone, H2, the shipped lifetime (no flag)"
W1=$(curl --noproxy '*' --http1.1 -s -o "$HERE/check.b" -w '%{http_code}' "$B/api/v1/customers/Ravi/bill-link")
HREF=$(python3 -I -c 'import json,sys
try: print(json.load(open(sys.argv[1]))["href"])
except Exception: print("")' "$HERE/check.b")
WB=$(curl --noproxy '*' --http1.1 -s -o "$HERE/check.bill" -w '%{http_code} %{content_type}' "$B/api/v1/customers/Ravi/bill")
WS=$(curl --noproxy '*' --http1.1 -s -o "$HERE/check.b" -w '%{http_code} %{content_type}' "$B$HREF")
TD=$(python3 -I -c 'import json,sys
try: d=json.load(open(sys.argv[1],encoding="utf-8")); print("title %s · detail %s" % (d.get("title"), d.get("detail")))
except Exception: print("not JSON")' "$HERE/check.b")
MS=$(md5 -q "$HERE/check.b" 2> /dev/null || md5sum "$HERE/check.b" | cut -d' ' -f1); MB=$(md5 -q "$HERE/check.bill" 2> /dev/null || md5sum "$HERE/check.bill" | cut -d' ' -f1)
OTHER=$(echo "$HREF" | sed 's#/customers/Ravi/#/customers/Sunil/#')
WN=$(curl --noproxy '*' --http1.1 -s -o /dev/null -w '%{http_code}' "$B$OTHER")
printf 'X-Shutdown-Token: %s\n' "$(cat "$RUN/secrets/tiffinbox/shutdown-token")" | curl --noproxy '*' -s -o /dev/null -H @- -X POST "$B/shutdown"
i=0; while kill -0 $JP 2> /dev/null; do i=$((i + 1)); [ $i -lt 100 ] || { kill $JP; break; }; sleep 0.1; done; wait $JP 2> /dev/null
echo "GET /api/v1/customers/Ravi/bill-link -> $W1 · href $(echo "$HREF" | sed -E 's/expires=[0-9]+/expires=<masked>/; s/sig=[A-Za-z0-9_-]+/sig=<masked>/')"
echo "measured: the signed download -> $WS$( [ "${WS%% *}" = 200 ] || echo " · $TD")"
echo "measured: the bill route -> $WB"
echo "the name changed in the link -> $WN"
rc=0
python3 -I - "$W1" "$HREF" "$WS" "$MS" "$WB" "$MB" "$WN" "$T" "$AFTER" <<'PY' || rc=1
import sys, os, hashlib, re
w1, href, ws, ms, wb, mb, wn, t, a = sys.argv[1:10]
bad = []
if not (w1 == "200" and re.search(r"\?expires=[0-9]+&sig=[A-Za-z0-9_-]+$", href)):
    bad.append("(1) the mint does not answer 200 with an href carrying expires and sig (got %s)" % w1)
if not (ws.split(" ")[0] == "200" and ws.split(" ")[-1].startswith("text/csv") and ms == mb):
    bad.append("(2) the minted link does not open 200 text/csv with the bill's own bytes (got %s)" % ws)
if wb.split(" ")[0] != "200":
    bad.append("(3) the bill route does not answer 200 (got %s)" % wb)
if wn != "403":
    bad.append("(4) the link with the name changed is not refused 403 (got %s)" % wn)
def md5(q): return hashlib.md5(open(q, "rb").read()).hexdigest()
for root in ("tiffinbox-web/src/main", "tiffinbox-core/src/main"):
    for d, _, fs in os.walk(os.path.join(a, root)):
        for f in fs:
            rel = os.path.relpath(os.path.join(d, f), a)
            if rel.endswith("CustomerBills.java"): continue
            q = os.path.join(t, rel)
            if not os.path.exists(q) or md5(q) != md5(os.path.join(a, rel)):
                bad.append("(5) %s differs from ../after's (the fix belongs in CustomerBills.java alone)" % rel)
for rel in ("pom.xml", "tiffinbox-web/pom.xml", "tiffinbox-core/pom.xml", "tiffinbox-web/src/test/resources/openapi/tiffinbox.json"):
    if md5(os.path.join(t, rel)) != md5(os.path.join(a, rel)): bad.append("(5) %s differs from ../after's" % rel)
s = open(os.path.join(t, "tiffinbox-web/src/main/java/com/tiffinbox/web/CustomerBills.java")).read()
m = re.search(r"\n\s*(ResponseEntity(?:<[^>]*>)?) signedBill\(", s)
dt = m.group(1) if m else "none"
print("the signed handler's declared type: %s" % dt)
if dt in ("ResponseEntity<?>", "ResponseEntity<Object>", "ResponseEntity", "none"):
    bad.append("(6) the signed handler is declared %s - a wildcard, Object or raw type" % dt)
for b in bad: print("FAIL " + b)
print("PASS - every clause holds" if not bad else "check.sh: %d clause(s) failed" % len(bad))
sys.exit(1 if bad else 0)
PY
rm -rf "$RUN"; rm -f "$HERE/check.b" "$HERE/check.h" "$HERE/check.bill"
exit $rc
