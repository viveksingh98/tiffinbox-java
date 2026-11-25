#!/bin/sh
# apply.sh TREE - the receipt's solution, made on the broken copy: the tree is built (the whole reactor, tests skipped), its web jar started
# alone on H2 on PORT, and the committed file written again from GET /v3/api-docs by unit 08's fixed rule (servers removed,
# json.dump(indent=2, ensure_ascii=False), a final newline); check.sh's build then generates the client again from it. HOW changes it for
# the receipt's refused variants: none (nothing changed), genedit (the generated PATH_ONE constant edited by hand under target/, the spec
# left broken), movedserver (the public read's @GetMapping moved to the broken address, the spec left broken).
[ -n "$1" ] && [ -d "$1" ] || { echo "apply.sh TREE"; exit 1; }
rpath=$(cd "$1" && pwd); how=${HOW:-solution}; port=${PORT:-20998}
filed="$rpath/tiffinbox-web/src/test/resources/openapi/tiffinbox.json"
rm -f apply.build.log apply.jvm.log apply.spec.json; rm -rf apply.run
if [ -n "$MAVEN_REPO" ]; then set -- -o "-Dmaven.repo.local=$MAVEN_REPO"; else set --; fi
case $how in
  none) echo "apply.sh: nothing changed (HOW=none)"; exit 0 ;;
  genedit)
    (cd "$rpath" && mvn -B "$@" -Duser.home="$HOME" -DskipTests clean package) > apply.build.log 2>&1 || { echo "apply.sh: the tree did not build"; exit 1; }
    python3 -I - "$rpath/tiffinbox-client/target/generated-sources/openapi/src/main/java/com/tiffinbox/client/api/ApiApi.java" <<'PY'
import sys
f = sys.argv[1]; s = open(f, encoding="utf-8").read(); a = 'String PATH_ONE = "/api/v1/customer/{name}";'
assert s.count(a) == 1, s.count(a); open(f, "w", encoding="utf-8").write(s.replace(a, 'String PATH_ONE = "/api/v1/customers/{name}";'))
print("apply.sh (genedit): the generated PATH_ONE edited by hand under target/")
PY
    exit 0 ;;
  movedserver)
    python3 -I - "$rpath/tiffinbox-web/src/main/java/com/tiffinbox/web/CustomerReads.java" <<'PY'
import sys
f = sys.argv[1]; s = open(f, encoding="utf-8").read(); a = '@GetMapping("/api/v1/customers/{name}")'
assert s.count(a) == 1, s.count(a); open(f, "w", encoding="utf-8").write(s.replace(a, '@GetMapping("/api/v1/customer/{name}")'))
print("apply.sh (movedserver): the public read's @GetMapping moved to /api/v1/customer/{name}")
PY
    exit 0 ;;
esac
(cd "$rpath" && mvn -B "$@" -Duser.home="$HOME" -DskipTests clean package) > apply.build.log 2>&1 || { echo "apply.sh: the tree did not build (apply.build.log)"; exit 1; }
mkdir -p apply.run/secrets/tiffinbox
(umask 077 && openssl rand -hex 16 > apply.run/secrets/tiffinbox/shutdown-token)
(cd apply.run && exec ${JAVA_HOME:+$JAVA_HOME/bin/}java -jar "$rpath/tiffinbox-web/target/tiffinbox-web-1.0.0.jar" --tiffinbox.port="$port" > ../apply.jvm.log 2>&1) &
pid=$!
i=0; while ! grep -q 'Started TiffinBox' apply.jvm.log 2> /dev/null; do
  kill -0 $pid 2> /dev/null || { echo "apply.sh: the jar did not start"; exit 1; }
  i=$((i + 1)); [ $i -lt 600 ] || { kill $pid; echo "apply.sh: no Started line"; exit 1; }; sleep 0.1; done
curl --noproxy '*' -s -o apply.spec.json "http://127.0.0.1:$port/v3/api-docs"
printf 'X-Shutdown-Token: %s\n' "$(cat apply.run/secrets/tiffinbox/shutdown-token)" | curl --noproxy '*' -s -o /dev/null -H @- -X POST "http://127.0.0.1:$port/shutdown"
wait $pid 2> /dev/null
python3 -I - apply.spec.json "$filed" <<'PY'
import io, json, sys
d = json.load(open(sys.argv[1], encoding="utf-8")); d.pop("servers", None)
b = io.StringIO(); json.dump(d, b, indent=2, ensure_ascii=False); b.write("\n")
open(sys.argv[2], "w", encoding="utf-8").write(b.getvalue())
print("apply.sh: the committed file written again from the running tree (servers removed, the fixed rule)")
PY
