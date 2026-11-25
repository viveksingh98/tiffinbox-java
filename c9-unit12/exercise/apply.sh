#!/bin/sh
# apply.sh TREE - the receipt's solution, on the broken (retired) copy: build it, start its jar alone on PORT (H2), send the OLD request
# GET /api/v1/customers/Ravi, and WRITE TREE/answer.http from what TiffinBox answered (the status line, the headers with Date masked, a
# blank line, the body). HOW changes it for the receipt's refused variants: typed404 (a four oh four typed from memory), pasted200 (the
# unretired tree's answer pasted in), v2request (the answer to /api/2.0/customers/Ravi saved instead), nodetail (the right status, the
# sentence reworded), fixedtree ("1.0" put back in the tree and that tree's answer saved). MAVEN_REPO set: the build is offline from that repository.
[ -n "$1" ] && [ -d "$1" ] || { echo "apply.sh TREE"; exit 1; }
rpath=$(cd "$1" && pwd); how=${HOW:-solution}; port=${PORT:-21018}
jar="$rpath/tiffinbox-web/target/tiffinbox-web-1.0.0.jar"; rq=/api/v1/customers/Ravi
[ "$how" = v2request ] && rq=/api/2.0/customers/Ravi
if [ "$how" = typed404 ] || [ "$how" = pasted200 ]; then
  python3 -I - "$rpath/answer.http" "$how" <<'PY'
import sys
p, how = sys.argv[1:3]
if how == "typed404":
    open(p, "w").write('GET /api/v1/customers/Ravi\nHTTP/1.1 404 \nContent-Type: application/problem+json\n\n{"detail":"No static resource api/v1/customers/Ravi.","instance":"/api/v1/customers/Ravi","status":404,"title":"Not Found"}\n')
else:
    open(p, "w").write('GET /api/v1/customers/Ravi\nHTTP/1.1 200 \nContent-Type: application/json\n\n{"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"}\n')
print("apply.sh (%s): done" % how)
PY
  exit 0
fi
if [ "$how" = fixedtree ]; then sed -i.bak 's/addSupportedVersions("2.0")/addSupportedVersions("1.0")/' "$rpath/tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxApiVersioning.java" && rm -f "$rpath/tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxApiVersioning.java.bak"; fi
if [ -n "$MAVEN_REPO" ]; then set -- -o "-Dmaven.repo.local=$MAVEN_REPO"; else set --; fi
(cd "$rpath" && mvn -B "$@" -Duser.home="$HOME" -DskipTests -pl tiffinbox-web -am clean package) > "$rpath/apply.build.log" 2>&1 || { echo "apply.sh: the build failed"; exit 1; }
run="$rpath/apply.run"; rm -rf "$run"; mkdir -p "$run/secrets/tiffinbox"
(umask 077 && openssl rand -hex 16 > "$run/secrets/tiffinbox/shutdown-token")
(cd "$run" && exec ${JAVA_HOME:+$JAVA_HOME/bin/}java -jar "$jar" --tiffinbox.port="$port" > jvm.log 2>&1) &
pid=$!
i=0; while ! grep -q 'Started TiffinBox' "$run/jvm.log" 2> /dev/null; do
  kill -0 $pid 2> /dev/null || { echo "apply.sh: the jar did not start"; exit 1; }
  i=$((i + 1)); [ $i -lt 600 ] || { kill $pid; echo "apply.sh: no Started line"; exit 1; }; sleep 0.1; done
curl --noproxy '*' --http1.1 -sS -D "$run/h" -o "$run/b" "http://127.0.0.1:$port$rq"
printf 'X-Shutdown-Token: %s\n' "$(cat "$run/secrets/tiffinbox/shutdown-token")" | curl --noproxy '*' -s -o /dev/null -H @- -X POST "http://127.0.0.1:$port/shutdown"
wait $pid 2> /dev/null
python3 -I - "$run/h" "$run/b" "$rpath/answer.http" "$rq" "$how" <<'PY'
import json, re, sys
h, b, out, rq, how = sys.argv[1:6]
hs = [l for l in open(h, encoding="utf-8").read().replace("\r", "").split("\n") if l]
hs = [re.sub(r"^(Date): .*", r"\1: <masked>", l) for l in hs]
body = open(b, encoding="utf-8").read()
if how == "nodetail":
    d = json.loads(body); d["detail"] = "Version one is not supported any more."; body = json.dumps(d, separators=(",", ":"))
open(out, "w", encoding="utf-8").write("GET %s\n%s\n\n%s\n" % (rq, "\n".join(hs), body))
print("apply.sh (%s): answer.http written - %s" % (how, hs[0]))
PY
rm -rf "$run"
