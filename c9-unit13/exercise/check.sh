#!/bin/sh
# Course 9 unit 13's exercise check: build TREE (a copy of ../after, offline from MAVEN_REPO when set), start its jar alone on PORT
# (default 21028; H2 in memory), send the requests itself, and PASS only if every clause holds:
#   (1) ?sort=nosuch -> 400 application/problem+json, type ...:sort-unknown, the detail naming the four sorts
#   (2) a cursor written for sort=newest, reused with sort=oldest -> 400 ...:cursor-mismatch, the detail naming sort
#   (3) ?sort=newest -> 200, page one's ids as ../after answers them: 19, 20, 17, 18, 15
#   (4) every src/main file but OrderPages.java, both poms and the spec md5-equal to ../after's (a fix elsewhere cannot pass)
#   (5) the four sort names in OrderPages.java, and no Sort.by(...) built from the request's own value
# Usage: sh check.sh TREE
T=${1:?usage: sh check.sh TREE}
HERE=$(cd "$(dirname "$0")" && pwd -P); AFTER=$(cd "$HERE/../after" && pwd -P)
[ "$(cd "$T" && pwd -P)" != "$AFTER" ] || { echo "check.sh: refused - that is ../after itself; copy it first"; exit 1; }
T=$(cd "$T" && pwd -P)
PORT=${PORT:-21028}; RUN="$HERE/check.run"; B="http://127.0.0.1:$PORT"
rm -f check.build.log check.jvm.log check.b check.h; rm -rf "$RUN"
cd "$T" || exit 1
mvn -o -B -q ${MAVEN_REPO:+"-Dmaven.repo.local=$MAVEN_REPO"} -DskipTests clean package -pl tiffinbox-web -am > "$HERE/check.build.log" 2>&1 || { echo "check.sh: the tree did not build (check.build.log)"; exit 1; }
echo "built: mvn -o -DskipTests clean package -pl tiffinbox-web -am (exit 0)"
mkdir -p "$RUN/secrets/tiffinbox"; (umask 077 && openssl rand -hex 16 > "$RUN/secrets/tiffinbox/shutdown-token")
(cd "$RUN" && exec java -Duser.language=en -Duser.country=US -jar "$T/tiffinbox-web/target/tiffinbox-web-1.0.0.jar" --tiffinbox.port="$PORT" > "$HERE/check.jvm.log" 2>&1) &
JP=$!
i=0; while ! grep -q 'Started TiffinBox' "$HERE/check.jvm.log" 2> /dev/null; do kill -0 $JP 2> /dev/null || { echo "check.sh: the JVM exited before it started"; exit 1; }; i=$((i + 1)); [ $i -lt 600 ] || { kill $JP; echo "check.sh: no Started line"; exit 1; }; sleep 0.1; done
ask() { curl --noproxy '*' --http1.1 -s -o "$HERE/check.b" -w '%{http_code} %{content_type}' "$B/api/v1/orders$1"; }
W1=$(ask "?sort=nosuch"); B1=$(cat "$HERE/check.b")
ask "?sort=newest&size=5" > /dev/null; N=$(python3 -I -c 'import json,sys; print(json.load(open(sys.argv[1])).get("next") or "")' "$HERE/check.b" 2> /dev/null)
W2=$(ask "?sort=oldest&size=5&cursor=$N"); B2=$(cat "$HERE/check.b")
W3=$(ask "?sort=newest&size=5"); B3=$(cat "$HERE/check.b")
EX=$(grep -cE 'Exception' "$HERE/check.jvm.log")
printf 'X-Shutdown-Token: %s\n' "$(cat "$RUN/secrets/tiffinbox/shutdown-token")" | curl --noproxy '*' -s -o /dev/null -H @- -X POST "$B/shutdown"
i=0; while kill -0 $JP 2> /dev/null; do i=$((i + 1)); [ $i -lt 100 ] || { kill $JP; break; }; sleep 0.1; done; wait $JP 2> /dev/null
echo "sort=nosuch -> $W1 · $(python3 -I -c 'import json,sys
try:
    d=json.loads(sys.argv[1]); print("type %s · detail %s" % (d.get("type", "none"), d.get("detail", d.get("error", "none"))))
except Exception: print("a body that is not JSON")' "$B1")"
echo "a newest cursor reused with sort=oldest -> $W2 · $(python3 -I -c 'import json,sys
try:
    d=json.loads(sys.argv[1]); print("type %s · detail %s" % (d.get("type", "none"), d.get("detail", "none")) if "type" in d or "detail" in d else "ids %s" % [i["id"] for i in d.get("items", [])])
except Exception: print("a body that is not JSON")' "$B2")"
echo "sort=newest -> $W3 · ids $(python3 -I -c 'import json,sys
try: print([i["id"] for i in json.loads(sys.argv[1])["items"]])
except Exception: print("none")' "$B3")"
echo "the JVM's log: lines naming an Exception $EX"
rc=0
python3 -I - "$W1" "$B1" "$W2" "$B2" "$W3" "$B3" "$T" "$AFTER" <<'PY' || rc=1
import json, sys, os, hashlib, re
w1, b1, w2, b2, w3, b3, t, a = sys.argv[1:9]
bad = []
def js(x):
    try: return json.loads(x)
    except Exception: return {}
d1 = js(b1)
if not (w1 == "400 application/problem+json" and d1.get("type") == "tag:tiffinbox.example,2026:sort-unknown" and "[newest, oldest, amount, customer]" in d1.get("detail", "")):
    bad.append("clause 1: an unknown sort is not refused 400 sort-unknown naming the four sorts (got %s)" % w1)
d2 = js(b2)
if not (w2 == "400 application/problem+json" and d2.get("type") == "tag:tiffinbox.example,2026:cursor-mismatch" and "sort" in d2.get("detail", "")):
    bad.append("clause 2: a cursor reused with another sort is not refused cursor-mismatch naming sort (got %s)" % w2)
d3 = js(b3)
if not (w3 == "200 application/json" and [i["id"] for i in d3.get("items", [])] == [19, 20, 17, 18, 15]):
    bad.append("clause 3: sort=newest does not answer page one as ../after does")
def md5(p): return hashlib.md5(open(p, "rb").read()).hexdigest()
for root in ("tiffinbox-web/src/main", "tiffinbox-core/src/main"):
    for d, _, fs in os.walk(os.path.join(a, root)):
        for f in fs:
            rel = os.path.relpath(os.path.join(d, f), a)
            if rel.endswith("OrderPages.java"): continue
            q = os.path.join(t, rel)
            if not os.path.exists(q) or md5(q) != md5(os.path.join(a, rel)):
                bad.append("clause 4: %s differs from ../after's (the fix belongs in OrderPages.java alone)" % rel)
for rel in ("pom.xml", "tiffinbox-web/pom.xml", "tiffinbox-core/pom.xml", "tiffinbox-web/src/test/resources/openapi/tiffinbox.json"):
    if md5(os.path.join(t, rel)) != md5(os.path.join(a, rel)): bad.append("clause 4: %s differs from ../after's" % rel)
s = open(os.path.join(t, "tiffinbox-web/src/main/java/com/tiffinbox/web/OrderPages.java")).read()
if not all('SORTS.put("%s"' % n in s for n in ("newest", "oldest", "amount", "customer")): bad.append("clause 5: the four sort names are not all in OrderPages.java")
if re.search(r"Sort\.by\([^)]*\bsort\b\)", s): bad.append("clause 5: a Sort.by(...) built from the request's own value")
for b in bad: print("FAIL " + b)
print("PASS - every clause holds" if not bad else "check.sh: %d clause(s) failed" % len(bad))
sys.exit(1 if bad else 0)
PY
rm -rf "$RUN"; rm -f "$HERE/check.b" "$HERE/check.h"
exit $rc
