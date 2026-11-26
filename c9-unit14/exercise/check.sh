#!/bin/sh
# Course 9 unit 14's exercise check: build TREE (a copy of ../after, offline from MAVEN_REPO when set), start its jar alone on PORT
# (default 21038; H2 in memory), send the requests itself, and PASS only if every clause holds:
#   (1) ?fields=name -> 200, every element holds exactly name, the seed's four first
#   (2) ?fields=mealType,name -> 200, every element holds exactly name and mealType, in the record's order
#   (3) ?fields=nickname -> 400 application/problem+json, type ...:field-unknown, the detail naming the four fields
#   (4) no fields -> the full list, its bytes ../after's (282 bytes at the seed's four, md5 09cb28cd...)
#   (5) every src/main file but CustomerFields.java, the poms and the spec md5-equal to ../after's (a fix elsewhere cannot pass)
#   (6) the four field names in CustomerFields.java's whitelist, and no member put under a name taken from the request
# Usage: sh check.sh TREE
T=${1:?usage: sh check.sh TREE}
HERE=$(cd "$(dirname "$0")" && pwd -P); AFTER=$(cd "$HERE/../after" && pwd -P)
[ "$(cd "$T" && pwd -P)" != "$AFTER" ] || { echo "check.sh: refused - that is ../after itself; copy it first"; exit 1; }
T=$(cd "$T" && pwd -P)
PORT=${PORT:-21038}; RUN="$HERE/check.run"; B="http://127.0.0.1:$PORT"
rm -f check.build.log check.jvm.log check.b check.h; rm -rf "$RUN"
cd "$T" || exit 1
mvn -o -B -q ${MAVEN_REPO:+"-Dmaven.repo.local=$MAVEN_REPO"} -DskipTests clean package -pl tiffinbox-web -am > "$HERE/check.build.log" 2>&1 || { echo "check.sh: the tree did not build (check.build.log)"; exit 1; }
echo "built: mvn -o -DskipTests clean package -pl tiffinbox-web -am (exit 0)"
mkdir -p "$RUN/secrets/tiffinbox"; (umask 077 && openssl rand -hex 16 > "$RUN/secrets/tiffinbox/shutdown-token")
(cd "$RUN" && exec java -Duser.language=en -Duser.country=US -jar "$T/tiffinbox-web/target/tiffinbox-web-1.0.0.jar" --tiffinbox.port="$PORT" > "$HERE/check.jvm.log" 2>&1) &
JP=$!
i=0; while ! grep -q 'Started TiffinBox' "$HERE/check.jvm.log" 2> /dev/null; do kill -0 $JP 2> /dev/null || { echo "check.sh: the JVM exited before it started"; exit 1; }; i=$((i + 1)); [ $i -lt 600 ] || { kill $JP; echo "check.sh: no Started line"; exit 1; }; sleep 0.1; done
ask() { curl --noproxy '*' --http1.1 -s -o "$HERE/check.b" -w '%{http_code} %{content_type} %{size_download}' "$B/api/v1/customers$1"; }
W1=$(ask "?fields=name"); B1=$(cat "$HERE/check.b")
W2=$(ask "?fields=mealType,name"); B2=$(cat "$HERE/check.b")
W3=$(ask "?fields=nickname"); B3=$(cat "$HERE/check.b")
W4=$(ask ""); M4=$(python3 -I -c 'import hashlib,sys; print(hashlib.md5(open(sys.argv[1],"rb").read()).hexdigest())' "$HERE/check.b")
printf 'X-Shutdown-Token: %s\n' "$(cat "$RUN/secrets/tiffinbox/shutdown-token")" | curl --noproxy '*' -s -o /dev/null -H @- -X POST "$B/shutdown"
i=0; while kill -0 $JP 2> /dev/null; do i=$((i + 1)); [ $i -lt 100 ] || { kill $JP; break; }; sleep 0.1; done; wait $JP 2> /dev/null
mem() { python3 -I -c 'import json,sys
try:
    d=json.loads(sys.argv[1])
    if isinstance(d, list): print("members %s" % sorted(set(tuple(o) for o in d)))
    else: print("type %s · detail %s" % (d.get("type", "none"), d.get("detail", d.get("error", "none"))))
except Exception: print("a body that is not JSON")' "$1"; }
echo "fields=name -> $W1 · $(mem "$B1")"
echo "fields=mealType,name -> $W2 · $(mem "$B2")"
echo "fields=nickname -> $W3 · $(mem "$B3")"
echo "no fields -> $W4 · md5 $M4"
rc=0
python3 -I - "$W1" "$B1" "$W2" "$B2" "$W3" "$B3" "$W4" "$M4" "$T" "$AFTER" <<'PY' || rc=1
import json, sys, os, hashlib, re
w1, b1, w2, b2, w3, b3, w4, m4, t, a = sys.argv[1:11]
bad = []
def js(x):
    try: return json.loads(x)
    except Exception: return None
seed = ["Meera", "Priya", "Ravi", "Sunil"]
d1 = js(b1)
if not (w1.startswith("200 application/json ") and isinstance(d1, list) and all(list(o) == ["name"] for o in d1) and [o["name"] for o in d1[:4]] == seed):
    bad.append("clause 1: ?fields=name does not answer each customer's name alone (got %s)" % w1)
d2 = js(b2)
if not (w2.startswith("200 application/json ") and isinstance(d2, list) and all(list(o) == ["name", "mealType"] for o in d2)):
    bad.append("clause 2: ?fields=mealType,name does not answer name and mealType alone, in the record's order")
d3 = js(b3)
if not (w3.startswith("400 application/problem+json ") and isinstance(d3, dict) and d3.get("type") == "tag:tiffinbox.example,2026:field-unknown"
        and "[name, mealsPerDay, pricePerMeal, mealType]" in d3.get("detail", "")):
    bad.append("clause 3: an unknown field is not refused 400 field-unknown naming the four fields (got %s)" % w3)
if not (w4 == "200 application/json 282" and m4 == "09cb28cd6fa1ad8b8fe4870ec8bbf0d0"):
    bad.append("clause 4: the full list is not ../after's (got %s, md5 %s)" % (w4, m4))
def md5(p): return hashlib.md5(open(p, "rb").read()).hexdigest()
for root in ("tiffinbox-web/src/main", "tiffinbox-core/src/main"):
    for d, _, fs in os.walk(os.path.join(a, root)):
        for f in fs:
            rel = os.path.relpath(os.path.join(d, f), a)
            if rel.endswith("CustomerFields.java"): continue
            q = os.path.join(t, rel)
            if not os.path.exists(q) or md5(q) != md5(os.path.join(a, rel)):
                bad.append("clause 5: %s differs from ../after's (the fix belongs in CustomerFields.java alone)" % rel)
for rel in ("pom.xml", "tiffinbox-web/pom.xml", "tiffinbox-core/pom.xml", "tiffinbox-web/src/test/resources/openapi/tiffinbox.json"):
    if md5(os.path.join(t, rel)) != md5(os.path.join(a, rel)): bad.append("clause 5: %s differs from ../after's" % rel)
s = open(os.path.join(t, "tiffinbox-web/src/main/java/com/tiffinbox/web/CustomerFields.java")).read()
if not all('FIELDS.put("%s"' % n in s for n in ("name", "mealsPerDay", "pricePerMeal", "mealType")): bad.append("clause 6: the four field names are not all in the whitelist")
if re.search(r"\bm\.put\(f\b", s): bad.append("clause 6: a member put under a name taken from the request")
for b in bad: print("FAIL " + b)
print("PASS - every clause holds" if not bad else "check.sh: %d clause(s) failed" % len(bad))
sys.exit(1 if bad else 0)
PY
rm -rf "$RUN"; rm -f "$HERE/check.b" "$HERE/check.h"
exit $rc
