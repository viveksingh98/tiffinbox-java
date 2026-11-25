#!/bin/sh
# apply.sh TREE - the receipt's solution, made on a copy of ../before: one response annotation on CustomerReads.one (the public read)
# - its two-hundred kept, a four-oh-four with application/problem+json and the ProblemDetail schema - then the tree is built, its jar
# started alone on H2 on PORT, and the committed file written again from GET /v3/api-docs by the fixed rule (servers removed,
# json.dump(indent=2, ensure_ascii=False), a final newline). HOW changes it for the receipt's refused variants: blanket (one
# @ResponseStatus line on the advice instead), oldroute (the old route's handler instead), both (the public read and the old route),
# pauseget (the pause GET instead), noschema (no schema), nofile (the annotation, the file not written again), handedit (the file edited
# by hand, no code change).
[ -n "$1" ] && [ -d "$1" ] || { echo "apply.sh TREE"; exit 1; }
rpath=$(cd "$1" && pwd); how=${HOW:-}; port=${PORT:-20988}
web="$rpath/tiffinbox-web/src/main/java/com/tiffinbox/web"
filed="$rpath/tiffinbox-web/src/test/resources/openapi/tiffinbox.json"
rm -f apply.build.log apply.jvm.log apply.spec.json; rm -rf apply.run
python3 -I - "$web" "${how:-public}" "$filed" <<'PY'
import json, os, sys
web, how, filed = sys.argv[1:4]
A = ('    @io.swagger.v3.oas.annotations.responses.ApiResponse(responseCode = "200", description = "OK")\n'
     '    @io.swagger.v3.oas.annotations.responses.ApiResponse(responseCode = "404", description = "Customer not found", content = @io.swagger.v3.oas.annotations.media.Content(\n'
     '            mediaType = "application/problem+json"%s))\n')
SCH = ', schema = @io.swagger.v3.oas.annotations.media.Schema(implementation = org.springframework.http.ProblemDetail.class)'
def put(f, anchor, text):
    p = os.sep.join((web, f)); s = open(p, encoding="utf-8").read(); assert s.count(anchor) == 1, (f, anchor)
    open(p, "w", encoding="utf-8").write(s.replace(anchor, text + anchor))
pub = ("CustomerReads.java", '    @GetMapping("/api/v1/customers/{name}")\n')
old = ("TiffinBoxServer.java", '    @GetMapping("/customers/{name}")\n')
pg = ("CustomerPauses.java", '    @GetMapping("/api/v1/customers/{name}/pauses/{id}")\n')
if how in ("public", "nofile"): put(*pub, A % SCH)
elif how == "noschema": put(*pub, A % "")
elif how == "oldroute": put(*old, A % SCH)
elif how == "both": put(*pub, A % SCH); put(*old, A % SCH)
elif how == "pauseget": put(*pg, A % SCH)
elif how == "blanket": put("TiffinBoxErrors.java", "    ProblemDetail notFound(CustomerNotFound e) {\n", "    @org.springframework.web.bind.annotation.ResponseStatus(HttpStatus.NOT_FOUND)\n")
elif how == "handedit":
    d = json.load(open(filed, encoding="utf-8"))
    d["paths"]["/api/v1/customers/{name}"]["get"]["responses"]["404"] = {"description": "Customer not found", "content": {"application/problem+json": {"schema": {"$ref": "#/components/schemas/ProblemDetail"}}}}
    with open(filed, "w", encoding="utf-8") as f: json.dump(d, f, indent=2, ensure_ascii=False); f.write("\n")
print("apply.sh: %s" % how)
PY
case "$how" in nofile|handedit) exit 0 ;; esac
if [ -n "$MAVEN_REPO" ]; then set -- -o "-Dmaven.repo.local=$MAVEN_REPO"; else set --; fi
(cd "$rpath" && mvn -B "$@" -Duser.home="$HOME" -DskipTests clean package -pl tiffinbox-web -am) > apply.build.log 2>&1 || { echo "apply.sh: the tree did not build (apply.build.log)"; exit 1; }
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
python3 -I -c 'import json,sys; d = json.load(open(sys.argv[1], encoding="utf-8")); d.pop("servers", None); f = open(sys.argv[2], "w", encoding="utf-8"); json.dump(d, f, indent=2, ensure_ascii=False); f.write("\n")' apply.spec.json "$filed"
rm -rf apply.run; rm -f apply.spec.json
echo "apply.sh: the committed file written again from the running tree"
