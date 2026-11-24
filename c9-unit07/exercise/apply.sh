#!/bin/sh
# apply.sh TREE - the measured solution, as one script: in a copy of ../after, @NotNull on Customer's two int components (mealsPerDay,
# pricePerMeal; the import is already there), then the committed document written again from the running application - the tree built
# with its tests skipped, its jar started alone on PORT (H2), GET /v3/api-docs, servers removed, json.dump(indent=2, ensure_ascii=False)
# with a final newline, the jar stopped. apply.sh --regenerate TREE writes the document again and edits nothing.
# MAVEN_REPO set: the build is offline from that repository; unset: your own Maven.
edit=yes
[ "$1" = --regenerate ] && { edit=no; shift; }
[ -n "$1" ] && [ -d "$1" ] || { echo "apply.sh: give a copy of ../after"; exit 1; }
rpath=$(cd "$1" && pwd)
[ "$rpath" != "$(cd ../after && pwd)" ] || { echo "apply.sh: ../after is the unit's frozen tree - edit a copy of it"; exit 1; }
port=${PORT:-18425}
cu="$rpath/tiffinbox-core/src/main/java/com/tiffinbox/Customer.java"
if [ $edit = yes ]; then
  sed -i.orig -e 's/@Min(1) @Max(3) int mealsPerDay/@NotNull @Min(1) @Max(3) int mealsPerDay/' -e 's/@Min(1) int pricePerMeal/@NotNull @Min(1) int pricePerMeal/' "$cu"
  n=$(diff "$cu.orig" "$cu" | grep -c '^>'); rm -f "$cu.orig"
  [ "$n" = 2 ] || { echo "apply.sh: the two components were not found as shipped ($n lines changed)"; exit 1; }
fi
if [ -n "$MAVEN_REPO" ]; then set -- -o "-Dmaven.repo.local=$MAVEN_REPO"; else set --; fi
(cd "$rpath" && mvn -B -q "$@" -Duser.home="$HOME" -DskipTests clean package -pl tiffinbox-web -am) > apply.build.log 2>&1 || { echo "apply.sh: the tree did not build (apply.build.log)"; exit 1; }
rm -rf apply.run; mkdir -p apply.run/secrets/tiffinbox
(umask 077 && openssl rand -hex 16 > apply.run/secrets/tiffinbox/shutdown-token)
(cd apply.run && exec ${JAVA_HOME:+$JAVA_HOME/bin/}java -jar "$rpath/tiffinbox-web/target/tiffinbox-web-1.0.0.jar" --tiffinbox.port="$port" > ../apply.jvm.log 2>&1) &
pid=$!
i=0; while ! grep -q 'Started TiffinBox' apply.jvm.log 2> /dev/null; do
  kill -0 $pid 2> /dev/null || { echo "apply.sh: the jar did not start (apply.jvm.log)"; exit 1; }
  i=$((i + 1)); [ $i -lt 600 ] || { kill $pid; echo "apply.sh: no Started line"; exit 1; }; sleep 0.1; done
curl --noproxy '*' -s -o apply.spec.json "http://127.0.0.1:$port/v3/api-docs"
printf 'X-Shutdown-Token: %s\n' "$(cat apply.run/secrets/tiffinbox/shutdown-token)" | curl --noproxy '*' -s -o /dev/null -H @- -X POST "http://127.0.0.1:$port/shutdown"
wait $pid 2> /dev/null
python3 -I - apply.spec.json "$rpath/tiffinbox-web/src/test/resources/openapi/tiffinbox.json" <<'PY'
import json, sys
d = json.load(open(sys.argv[1], encoding="utf-8")); d.pop("servers", None)
with open(sys.argv[2], "w", encoding="utf-8") as f:
    json.dump(d, f, indent=2, ensure_ascii=False); f.write("\n")
print("apply.sh: the committed document written again - required %s" % "/".join(sorted(d["components"]["schemas"]["Customer"].get("required", []))))
PY
rm -rf apply.run apply.build.log apply.jvm.log apply.spec.json
