#!/bin/sh
# Course 9 unit 16's exercise check: build TREE (a copy of ../after, offline from MAVEN_REPO when set), start its jar alone on PORT
# (default 21058; H2 in memory), send the requests itself, and PASS only if every clause holds:
#   (1) GET /api/v1/orders/1 -> 200, and its _links.self.href ends /api/v1/orders/1
#   (2) its _links.customer.href ends /api/v1/customers/Ravi
#   (3) following customer -> 200, the customer named Ravi
#   (4) CustomerReads.java still declares final class CustomerReads, md5-equal to ../after's
#   (5) every src/main file but OrderResources.java, the three poms and the spec md5-equal to ../after's (a fix elsewhere cannot pass)
#   (6) OrderResources.java holds no methodOn(CustomerReads and builds a link by linkTo( with a Method argument (CUSTOMER_ONE)
# Usage: sh check.sh TREE
T=${1:?usage: sh check.sh TREE}
HERE=$(cd "$(dirname "$0")" && pwd -P); AFTER=$(cd "$HERE/../after" && pwd -P)
[ "$(cd "$T" && pwd -P)" != "$AFTER" ] || { echo "check.sh: refused - that is ../after itself; copy it first"; exit 1; }
T=$(cd "$T" && pwd -P)
PORT=${PORT:-21058}; RUN="$HERE/check.run"; B="http://127.0.0.1:$PORT"
rm -f "$HERE/check.build.log" "$HERE/check.jvm.log" "$HERE/check.b" "$HERE/check.h"; rm -rf "$RUN"
cd "$T" || exit 1
mvn -o -B -q ${MAVEN_REPO:+"-Dmaven.repo.local=$MAVEN_REPO"} -DskipTests clean package -pl tiffinbox-web -am > "$HERE/check.build.log" 2>&1 || { echo "check.sh: the tree did not build (check.build.log)"; exit 1; }
echo "built: mvn -o -DskipTests clean package -pl tiffinbox-web -am (exit 0)"
mkdir -p "$RUN/secrets/tiffinbox"; (umask 077 && openssl rand -hex 16 > "$RUN/secrets/tiffinbox/shutdown-token")
(cd "$RUN" && exec java -Duser.language=en -Duser.country=US -jar "$T/tiffinbox-web/target/tiffinbox-web-1.0.0.jar" --tiffinbox.port="$PORT" > "$HERE/check.jvm.log" 2>&1) &
JP=$!
i=0; while ! grep -q 'Started TiffinBox' "$HERE/check.jvm.log" 2> /dev/null; do kill -0 $JP 2> /dev/null || { echo "check.sh: the JVM exited before it started"; exit 1; }; i=$((i + 1)); [ $i -lt 600 ] || { kill $JP; echo "check.sh: no Started line"; exit 1; }; sleep 0.1; done
W1=$(curl --noproxy '*' --http1.1 -s -o "$HERE/check.b" -w '%{http_code} %{content_type}' "$B/api/v1/orders/1"); B1=$(cat "$HERE/check.b")
CU=$(python3 -I -c 'import json,sys
try: print(json.loads(sys.argv[1])["_links"]["customer"]["href"])
except Exception: print("")' "$B1")
W3="none"; B3=""; if [ -n "$CU" ]; then W3=$(curl --noproxy '*' --http1.1 -s -o "$HERE/check.b" -w '%{http_code} %{content_type}' "$CU"); B3=$(cat "$HERE/check.b"); fi
LOGX=$(grep -m1 -oE '(AopConfigException|IllegalArgumentException): [^"]*' "$HERE/check.jvm.log" | cut -c1-160)
printf 'X-Shutdown-Token: %s\n' "$(cat "$RUN/secrets/tiffinbox/shutdown-token")" | curl --noproxy '*' -s -o /dev/null -H @- -X POST "$B/shutdown"
i=0; while kill -0 $JP 2> /dev/null; do i=$((i + 1)); [ $i -lt 100 ] || { kill $JP; break; }; sleep 0.1; done; wait $JP 2> /dev/null
mem() { python3 -I -c 'import json,sys
try:
    d=json.loads(sys.argv[1])
    if "_links" in d: print("links %s" % ["%s=%s" % (k, v["href"]) for k, v in d["_links"].items()])
    elif "name" in d: print("name %s" % d["name"])
    else: print("type %s · title %s · detail %s" % (d.get("type", "none"), d.get("title", d.get("error", "none")), d.get("detail", "none")))
except Exception: print("a body that is not JSON")' "$1"; }
echo "GET /api/v1/orders/1 -> $W1 · $(mem "$B1")"
echo "following customer -> $W3 · $(mem "$B3")"
echo "the JVM log's exception: ${LOGX:-none}"
rc=0
python3 -I - "$W1" "$B1" "$W3" "$B3" "$T" "$AFTER" <<'PY' || rc=1
import json, sys, os, hashlib, re
w1, b1, w3, b3, t, a = sys.argv[1:7]
bad = []
def js(x):
    try: return json.loads(x)
    except Exception: return None
d1 = js(b1) or {}
lk = d1.get("_links", {}) if isinstance(d1, dict) else {}
if not (w1.startswith("200 ") and lk.get("self", {}).get("href", "").endswith("/api/v1/orders/1")):
    bad.append("clause 1: GET /api/v1/orders/1 does not answer 200 with its self link (got %s)" % w1)
if not lk.get("customer", {}).get("href", "").endswith("/api/v1/customers/Ravi"):
    bad.append("clause 2: the order has no customer link to /api/v1/customers/Ravi")
d3 = js(b3) or {}
if not (w3.startswith("200 ") and isinstance(d3, dict) and d3.get("name") == "Ravi"):
    bad.append("clause 3: following customer does not answer Ravi (got %s)" % w3)
def md5(p): return hashlib.md5(open(p, "rb").read()).hexdigest()
cr = "tiffinbox-web/src/main/java/com/tiffinbox/web/CustomerReads.java"
if "final class CustomerReads" not in open(os.path.join(t, cr)).read() or md5(os.path.join(t, cr)) != md5(os.path.join(a, cr)):
    bad.append("clause 4: CustomerReads.java is no longer ../after's final class CustomerReads")
for root in ("tiffinbox-web/src/main", "tiffinbox-core/src/main"):
    for d, _, fs in os.walk(os.path.join(a, root)):
        for f in fs:
            rel = os.path.relpath(os.path.join(d, f), a)
            if rel.endswith("OrderResources.java") or rel == cr: continue
            q = os.path.join(t, rel)
            if not os.path.exists(q) or md5(q) != md5(os.path.join(a, rel)):
                bad.append("clause 5: %s differs from ../after's (the fix belongs in OrderResources.java alone)" % rel)
for rel in ("pom.xml", "tiffinbox-web/pom.xml", "tiffinbox-core/pom.xml", "tiffinbox-web/src/test/resources/openapi/tiffinbox.json"):
    if md5(os.path.join(t, rel)) != md5(os.path.join(a, rel)): bad.append("clause 5: %s differs from ../after's" % rel)
s = re.sub(r"(?s)/\*.*?\*/|//[^\n]*", "", open(os.path.join(t, "tiffinbox-web/src/main/java/com/tiffinbox/web/OrderResources.java")).read())   # the code, its comments left out
if "methodOn(CustomerReads" in s: bad.append("clause 6: OrderResources.java still proxies CustomerReads (methodOn(CustomerReads)")
if not re.search(r"linkTo\(CustomerReads\.class, *CUSTOMER_ONE,", s): bad.append("clause 6: no linkTo( call with CustomerReads' Method (the Method form)")
for b in bad: print("FAIL " + b)
print("PASS - every clause holds" if not bad else "check.sh: %d clause(s) failed" % len(bad))
sys.exit(1 if bad else 0)
PY
rm -rf "$RUN"; rm -f "$HERE/check.b" "$HERE/check.h"
exit $rc
