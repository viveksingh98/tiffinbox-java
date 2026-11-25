#!/bin/sh
# check.sh TREE - builds a TiffinBox tree (a copy of ../before, never ../before itself), starts its jar alone on H2 on PORT, asks
# GET /v3/api-docs and GET /api/v1/customers/Nobody, stops it, and reads both with python. It PASSES only when (1) exactly one operation
# of the served document documents a four-oh-four and it is the public read, GET /api/v1/customers/{name}; (2) that response's content is
# application/problem+json with the schema #/components/schemas/ProblemDetail; (3) the public read still documents its two-hundred; (4)
# the wire still answers Nobody with a four-oh-four problem; (5) the tree's committed file, tiffinbox-web/src/test/resources/openapi/
# tiffinbox.json, is the served document with servers removed (written in the same change). Anything else FAILS, naming the clause.
# MAVEN_REPO set: the build is offline from that repository (the receipt's seed copy); unset: your own Maven.
rm -f check.build.log check.jvm.log check.spec.json check.nobody.json check.status
rm -rf check.run
[ -n "$1" ] && [ -d "$1" ] || { echo "FAIL: give a copy of ../before to check (cp -R ../before my-tiffinbox; sh check.sh my-tiffinbox)"; exit 1; }
rpath=$(cd "$1" && pwd)
[ "$rpath" != "$(cd ../before && pwd)" ] || { echo "FAIL: ../before is unit 08's frozen tree - check a copy of it"; exit 1; }
port=${PORT:-20988}
jar="$rpath/tiffinbox-web/target/tiffinbox-web-1.0.0.jar"
if [ -n "$MAVEN_REPO" ]; then set -- -o "-Dmaven.repo.local=$MAVEN_REPO"; else set --; fi
(cd "$rpath" && mvn -B "$@" -Duser.home="$HOME" -DskipTests clean package -pl tiffinbox-web -am) > check.build.log 2>&1 || { echo "FAIL: the tree did not build (check.build.log)"; exit 1; }
[ -f "$jar" ] || { echo "FAIL: no jar after the build"; exit 1; }
mkdir -p check.run/secrets/tiffinbox
(umask 077 && openssl rand -hex 16 > check.run/secrets/tiffinbox/shutdown-token)
(cd check.run && exec ${JAVA_HOME:+$JAVA_HOME/bin/}java -jar "$jar" --tiffinbox.port="$port" > ../check.jvm.log 2>&1) &
pid=$!
i=0; while ! grep -q 'Started TiffinBox' check.jvm.log 2> /dev/null; do
  kill -0 $pid 2> /dev/null || { echo "FAIL: the jar did not start (check.jvm.log)"; exit 1; }
  i=$((i + 1)); [ $i -lt 600 ] || { kill $pid; echo "FAIL: no Started line"; exit 1; }; sleep 0.1; done
curl --noproxy '*' -s -o check.spec.json "http://127.0.0.1:$port/v3/api-docs"
curl --noproxy '*' -s -o check.nobody.json -w '%{http_code} %{content_type}' "http://127.0.0.1:$port/api/v1/customers/Nobody" > check.status
printf 'X-Shutdown-Token: %s\n' "$(cat check.run/secrets/tiffinbox/shutdown-token)" | curl --noproxy '*' -s -o /dev/null -H @- -X POST "http://127.0.0.1:$port/shutdown"
wait $pid 2> /dev/null
python3 -I - check.spec.json check.status "$rpath/tiffinbox-web/src/test/resources/openapi/tiffinbox.json" <<'PY'
import io, json, sys
spec, status, filed = sys.argv[1:4]
d = json.load(open(spec, encoding="utf-8"))
ops = [(m.upper(), p, o) for p, v in d["paths"].items() for m, o in v.items()]
with404 = [(m, p) for m, p, o in ops if "404" in o.get("responses", {})]
want = ("GET", "/api/v1/customers/{name}")
if with404 != [want]: print("FAIL (clause 1): %d operations document a four-oh-four, not the public read alone: %s" % (len(with404), " · ".join("%s %s" % x for x in with404) or "none")); sys.exit(1)
r = d["paths"][want[1]]["get"]["responses"]
c = r["404"].get("content", {}).get("application/problem+json", {})
if c.get("schema", {}).get("$ref") != "#/components/schemas/ProblemDetail" or "ProblemDetail" not in d.get("components", {}).get("schemas", {}):
    print("FAIL (clause 2): the public read's four-oh-four is not application/problem+json with the ProblemDetail schema: %s" % json.dumps(r["404"])[:120]); sys.exit(1)
if "200" not in r: print("FAIL (clause 3): the public read no longer documents its two-hundred (responses %s)" % sorted(r)); sys.exit(1)
st = open(status).read().split()
if st[:2] != ["404", "application/problem+json"]: print("FAIL (clause 4): the wire answers Nobody %s, not a four-oh-four problem" % " ".join(st)); sys.exit(1)
d.pop("servers", None); b = io.StringIO(); json.dump(d, b, indent=2, ensure_ascii=False); b.write("\n")
if b.getvalue() != open(filed, encoding="utf-8").read(): print("FAIL (clause 5): the committed file is not the served document with servers removed - write it again in the same change"); sys.exit(1)
print("PASS: one operation documents a four-oh-four, GET /api/v1/customers/{name}, application/problem+json, ProblemDetail; its two-hundred kept; the wire answers Nobody 404; the committed file is the served document")
PY
