#!/bin/sh
# check.sh TREE - builds a TiffinBox tree (a copy of ../after, never ../after itself), runs its OpenApiSpecTest, starts its jar alone on H2
# (or on JDBC_URL when set) on PORT, reads /v3/api-docs and sends five new customers. It PASSES only when (1) the served document's
# Customer requires all four properties, (2) the committed file equals the served document with servers removed AND the test passed,
# (3) the four POSTs that leave one property out still answer four hundred and the full one two-oh-one. Anything else FAILS, naming
# each clause it broke. MAVEN_REPO set: the build is offline from that repository (the receipt's seed copy); unset: your own Maven.
rm -f check.build.log check.spec.json check.status check.jvm.log
rm -rf check.run
[ -n "$1" ] && [ -d "$1" ] || { echo "FAIL: give a copy of ../after to check (cp -R ../after my-tiffinbox; sh check.sh my-tiffinbox)"; exit 1; }
rpath=$(cd "$1" && pwd)
[ "$rpath" != "$(cd ../after && pwd)" ] || { echo "FAIL: ../after is the unit's frozen tree - check a copy of it"; exit 1; }
port=${PORT:-18425}
jar="$rpath/tiffinbox-web/target/tiffinbox-web-1.0.0.jar"
xml="$rpath/tiffinbox-web/target/surefire-reports/TEST-com.tiffinbox.web.OpenApiSpecTest.xml"
if [ -n "$MAVEN_REPO" ]; then set -- -o "-Dmaven.repo.local=$MAVEN_REPO"; else set --; fi
(cd "$rpath" && mvn -B "$@" -Duser.home="$HOME" clean package -Dtest=OpenApiSpecTest -Dsurefire.failIfNoSpecifiedTests=false \
   -Dmaven.test.failure.ignore=true -pl tiffinbox-web -am) > check.build.log 2>&1 || { echo "FAIL: the tree did not build (check.build.log)"; exit 1; }
[ -f "$jar" ] || { echo "FAIL: no jar after the build"; exit 1; }
tests=$(sed -n 's/.*<testsuite [^>]*tests="\([0-9]*\)".*/\1/p' "$xml" 2> /dev/null | head -1)
bad=$(sed -n 's/.*<testsuite [^>]*failures="\([0-9]*\)".*/\1/p' "$xml" 2> /dev/null | head -1)
err=$(sed -n 's/.*<testsuite [^>]*errors="\([0-9]*\)".*/\1/p' "$xml" 2> /dev/null | head -1)
if [ "${tests:-0}" -ge 1 ] && [ "$bad" = 0 ] && [ "$err" = 0 ]; then test=passed; else test="failed (tests ${tests:-none}, failures ${bad:-?}, errors ${err:-?})"; fi
mkdir -p check.run/secrets/tiffinbox
(umask 077 && openssl rand -hex 16 > check.run/secrets/tiffinbox/shutdown-token)
if [ -n "$JDBC_URL" ]; then jx="-Dtiffinbox.jdbc-url=$JDBC_URL"; else jx=""; fi
(cd check.run && exec ${JAVA_HOME:+$JAVA_HOME/bin/}java $jx -jar "$jar" --tiffinbox.port="$port" > ../check.jvm.log 2>&1) &
pid=$!
i=0; while ! grep -q 'Started TiffinBox' check.jvm.log 2> /dev/null; do
  kill -0 $pid 2> /dev/null || { echo "FAIL: the jar did not start (check.jvm.log)"; exit 1; }
  i=$((i + 1)); [ $i -lt 600 ] || { kill $pid; echo "FAIL: no Started line"; exit 1; }; sleep 0.1; done
curl --noproxy '*' -s -o check.spec.json "http://127.0.0.1:$port/v3/api-docs"
for b in '{"name":"Ex1","pricePerMeal":100,"mealType":"VEG"}' '{"name":"Ex2","mealsPerDay":2,"mealType":"VEG"}' \
         '{"name":"Ex3","mealsPerDay":2,"pricePerMeal":100}' '{"mealsPerDay":2,"pricePerMeal":100,"mealType":"VEG"}' \
         '{"name":"Ex5","mealsPerDay":2,"pricePerMeal":100,"mealType":"VEG"}'; do
  curl --noproxy '*' -s -o /dev/null -w '%{http_code}\n' -H 'Content-Type: application/json' --data-binary "$b" "http://127.0.0.1:$port/customers" >> check.status
done
printf 'X-Shutdown-Token: %s\n' "$(cat check.run/secrets/tiffinbox/shutdown-token)" | curl --noproxy '*' -s -o /dev/null -H @- -X POST "http://127.0.0.1:$port/shutdown"
wait $pid 2> /dev/null
python3 -I - check.spec.json "$rpath/tiffinbox-web/src/test/resources/openapi/tiffinbox.json" check.status "$test" <<'PY'
import json, sys
spec, filed, st, test = sys.argv[1:5]
s = json.load(open(spec, encoding="utf-8")); f = json.load(open(filed, encoding="utf-8"))
req = sorted(s["components"]["schemas"]["Customer"].get("required", []))
s.pop("servers", None); f.pop("servers", None)
codes = open(st).read().split()
c1 = req == ["mealType", "mealsPerDay", "name", "pricePerMeal"]
c2 = s == f and test == "passed"
c3 = codes == ["400", "400", "400", "400", "201"]
line = "required %s · the committed file %s the served document, the test %s · the five POSTs %s" % (
    "/".join(req), "=" if s == f else "!=", test, " ".join(codes))
bad = [str(n) for n, c in ((1, c1), (2, c2), (3, c3)) if not c]
print(("PASS: " if not bad else "FAIL (clause %s): " % ",".join(bad)) + line)
sys.exit(1 if bad else 0)
PY
