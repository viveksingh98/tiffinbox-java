#!/bin/sh
# Course 9 unit 19's exercise check: build TREE (a copy of ../after, offline from MAVEN_REPO when set), start its jar alone on PORT
# (default 21088; H2 in memory; the run flag --tiffinbox.rate-limit.capacity=5), send the requests itself, and PASS only if every
# clause holds:
#   (1) five GET /api/v1/customers/Ravi answer 200, the sixth 429
#   (2) after that 429, the same GET with a forged X-Api-Key (forged-1, then forged-2) answers 429, with Retry-After
#   (3) after that, the same GET with a forged X-Forwarded-For answers 429
#   (4) every src/main file but RateLimitFilter.java, the three poms, application.yaml and the spec md5-equal to ../after's
#   (5) RateLimitFilter.java reads no request header (no getHeader( and no getHeaders( in it)
# Usage: sh check.sh TREE
T=${1:?usage: sh check.sh TREE}
HERE=$(cd "$(dirname "$0")" && pwd -P); AFTER=$(cd "$HERE/../after" && pwd -P)
[ "$(cd "$T" && pwd -P)" != "$AFTER" ] || { echo "check.sh: refused - that is ../after itself; copy it first"; exit 1; }
T=$(cd "$T" && pwd -P)
PORT=${PORT:-21088}; RUN="$HERE/check.run"; B="http://127.0.0.1:$PORT"
rm -f "$HERE/check.build.log" "$HERE/check.jvm.log"; rm -rf "$RUN"
cd "$T" || exit 1
mvn -o -B -q ${MAVEN_REPO:+"-Dmaven.repo.local=$MAVEN_REPO"} -DskipTests clean package -pl tiffinbox-web -am > "$HERE/check.build.log" 2>&1 || { echo "check.sh: the tree did not build (check.build.log)"; exit 1; }
echo "built: mvn -o -DskipTests clean package -pl tiffinbox-web -am (exit 0)"
mkdir -p "$RUN/secrets/tiffinbox"; (umask 077 && openssl rand -hex 16 > "$RUN/secrets/tiffinbox/shutdown-token")
(cd "$RUN" && exec java -Duser.language=en -Duser.country=US -jar "$T/tiffinbox-web/target/tiffinbox-web-1.0.0.jar" --tiffinbox.port="$PORT" --tiffinbox.rate-limit.capacity=5 > "$HERE/check.jvm.log" 2>&1) &
JP=$!
i=0; while ! grep -q 'Started TiffinBox' "$HERE/check.jvm.log" 2> /dev/null; do kill -0 $JP 2> /dev/null || { echo "check.sh: the JVM exited before it started"; exit 1; }; i=$((i + 1)); [ $i -lt 600 ] || { kill $JP; echo "check.sh: no Started line"; exit 1; }; sleep 0.1; done
echo "started: the jar alone, H2, --tiffinbox.rate-limit.capacity=5 (a run flag)"
u="$B/api/v1/customers/Ravi"; S6=""
for n in 1 2 3 4 5 6; do S6="$S6 $(curl --noproxy '*' --http1.1 -s -o /dev/null -w '%{http_code}' "$u")"; done
K1=$(curl --noproxy '*' --http1.1 -s -o /dev/null -D "$HERE/check.h" -w '%{http_code}' -H 'X-Api-Key: forged-1' "$u")
RA=$(tr -d '\r' < "$HERE/check.h" | grep -ci '^Retry-After: [0-9]')
K2=$(curl --noproxy '*' --http1.1 -s -o /dev/null -w '%{http_code}' -H 'X-Api-Key: forged-2' "$u")
XF=$(curl --noproxy '*' --http1.1 -s -o /dev/null -w '%{http_code}' -H 'X-Forwarded-For: 10.0.0.1' "$u")
printf 'X-Shutdown-Token: %s\n' "$(cat "$RUN/secrets/tiffinbox/shutdown-token")" | curl --noproxy '*' -s -o /dev/null -H @- -X POST "$B/shutdown"
i=0; while kill -0 $JP 2> /dev/null; do i=$((i + 1)); [ $i -lt 100 ] || { kill $JP; break; }; sleep 0.1; done; wait $JP 2> /dev/null
rm -f "$HERE/check.h"
echo "GET /api/v1/customers/Ravi x6 ->$S6"
echo "measured: X-Api-Key forged-1 -> $K1 (Retry-After lines $RA) · forged-2 -> $K2 · X-Forwarded-For 10.0.0.1 -> $XF"
rc=0
python3 -I - "$S6" "$K1" "$RA" "$K2" "$XF" "$T" "$AFTER" <<'PY' || rc=1
import sys, os, hashlib
s6, k1, ra, k2, xf, t, a = sys.argv[1:8]
bad = []
if s6.split() != ["200"] * 5 + ["429"]: bad.append("(1) five 200 then a 429 - got%s" % s6)
if not (k1 == "429" and k2 == "429" and ra == "1"): bad.append("(2) a forged X-Api-Key after the 429 answered %s, %s (Retry-After lines %s): the key is a header the caller picks" % (k1, k2, ra))
if xf != "429": bad.append("(3) a forged X-Forwarded-For after the 429 answered %s" % xf)
def md(p): return hashlib.md5(open(p, "rb").read()).hexdigest()
keep = ["pom.xml", "tiffinbox-web/pom.xml", "tiffinbox-core/pom.xml", "tiffinbox-web/src/main/resources/application.yaml", "tiffinbox-web/src/test/resources/openapi/tiffinbox.json"]
for root in ("tiffinbox-web/src/main", "tiffinbox-core/src/main"):
    for d, ds, fs in os.walk(os.path.join(a, root)):
        for f in fs:
            r = os.path.relpath(os.path.join(d, f), a)
            if not r.endswith("RateLimitFilter.java"): keep.append(r)
moved = [r for r in sorted(set(keep)) if not os.path.exists(os.path.join(t, r)) or md(os.path.join(t, r)) != md(os.path.join(a, r))]
if moved: bad.append("(4) files other than RateLimitFilter.java differ from ../after's: " + ", ".join(moved[:3]))
src = open(os.path.join(t, "tiffinbox-web/src/main/java/com/tiffinbox/web/RateLimitFilter.java"), encoding="utf-8").read()
if "getHeader(" in src or "getHeaders(" in src: bad.append("(5) RateLimitFilter.java reads a request header")
for b in bad: print("FAIL " + b)
print("PASS" if not bad else "check.sh: %d clause(s) failed" % len(bad))
sys.exit(1 if bad else 0)
PY
rm -rf "$RUN"
exit $rc
