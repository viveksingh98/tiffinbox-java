#!/bin/sh
# check.sh TREE - builds a TiffinBox tree (a copy of ../after made broken by break.sh, never ../after itself): the whole reactor, so the
# client is generated again from whatever the committed file says; starts the web jar alone on H2 on PORT; calls the GENERATED public
# read, ApiApi.one("Ravi"), through RestClient.builder() (a one-file Java program, check.run/Call.java, on the client jar's
# classpath); asks GET /v3/api-docs; stops the jar; and reads it all with python. It PASSES only when (1) the generated call answered
# two hundred with Ravi, and the generated PATH_ONE constant of the public read is the address the served document gives it; (2) the
# tree's committed file, tiffinbox-web/src/test/resources/openapi/tiffinbox.json, is the served document with servers removed; (3)
# the hand-written parts are untouched - tiffinbox-client (its pom and its test) and tiffinbox-web/src/main hash as ../after's.
# Anything else FAILS, naming the clause. MAVEN_REPO set: the build is offline from that repository (the receipt's seed copy).
rm -f check.build.log check.jvm.log check.spec.json check.call.txt check.cp
rm -rf check.run
[ -n "$1" ] && [ -d "$1" ] || { echo "FAIL: give a copy of ../after to check (cp -R ../after my-tiffinbox; sh break.sh my-tiffinbox; sh check.sh my-tiffinbox)"; exit 1; }
rpath=$(cd "$1" && pwd)
[ "$rpath" != "$(cd ../after && pwd)" ] || { echo "FAIL: ../after is unit 10's frozen tree - check a copy of it"; exit 1; }
port=${PORT:-20998}; ex=$(pwd)
jar="$rpath/tiffinbox-web/target/tiffinbox-web-1.0.0.jar"
cjar="$rpath/tiffinbox-client/target/tiffinbox-client-1.0.0.jar"
if [ -n "$MAVEN_REPO" ]; then set -- -o "-Dmaven.repo.local=$MAVEN_REPO"; else set --; fi
(cd "$rpath" && mvn -B "$@" -Duser.home="$HOME" -DskipTests clean package) > check.build.log 2>&1 || { echo "FAIL: the tree did not build (check.build.log)"; exit 1; }
[ -f "$jar" ] && [ -f "$cjar" ] || { echo "FAIL: no web jar or no client jar after the build"; exit 1; }
(cd "$rpath" && mvn -B "$@" -Duser.home="$HOME" -q dependency:build-classpath -DincludeScope=runtime -Dmdep.outputFile="$ex/check.cp" -pl tiffinbox-client -am) >> check.build.log 2>&1 || { echo "FAIL: the client's classpath could not be read (check.build.log)"; exit 1; }
mkdir -p check.run/secrets/tiffinbox
(umask 077 && openssl rand -hex 16 > check.run/secrets/tiffinbox/shutdown-token)
cat > check.run/Call.java <<'JAVA'
import com.tiffinbox.client.api.ApiApi;
import org.springframework.web.client.RestClient;
import org.springframework.web.client.RestClientResponseException;
import org.springframework.web.client.support.RestClientAdapter;
import org.springframework.web.service.invoker.HttpServiceProxyFactory;

public class Call {
    public static void main(String[] a) {
        RestClient rc = RestClient.builder().baseUrl(a[0]).build();
        ApiApi api = HttpServiceProxyFactory.builderFor(RestClientAdapter.create(rc)).build().createClient(ApiApi.class);
        System.out.println("PATH " + ApiApi.PATH_ONE);
        try {
            var r = api.one("Ravi");
            System.out.println("CALL " + r.getStatusCode().value() + " " + r.getBody().getName());
        } catch (RestClientResponseException e) {
            System.out.println("CALL " + e.getStatusCode().value() + " " + e.getClass().getName());
        }
    }
}
JAVA
(cd check.run && exec ${JAVA_HOME:+$JAVA_HOME/bin/}java -jar "$jar" --tiffinbox.port="$port" > ../check.jvm.log 2>&1) &
pid=$!
i=0; while ! grep -q 'Started TiffinBox' check.jvm.log 2> /dev/null; do
  kill -0 $pid 2> /dev/null || { echo "FAIL: the jar did not start (check.jvm.log)"; exit 1; }
  i=$((i + 1)); [ $i -lt 600 ] || { kill $pid; echo "FAIL: no Started line"; exit 1; }; sleep 0.1; done
${JAVA_HOME:+$JAVA_HOME/bin/}java -cp "$cjar:$(cat check.cp)" check.run/Call.java "http://127.0.0.1:$port" > check.call.txt 2>&1
curl --noproxy '*' -s -o check.spec.json "http://127.0.0.1:$port/v3/api-docs"
printf 'X-Shutdown-Token: %s\n' "$(cat check.run/secrets/tiffinbox/shutdown-token)" | curl --noproxy '*' -s -o /dev/null -H @- -X POST "http://127.0.0.1:$port/shutdown"
wait $pid 2> /dev/null
python3 -I - check.call.txt check.spec.json "$rpath" <<'PY'
import hashlib, io, json, os, posixpath as pp, sys
call, spec, tree = sys.argv[1:4]
c = dict(l.split(" ", 1) for l in open(call, encoding="utf-8").read().splitlines() if l.startswith(("PATH ", "CALL ")))
d = json.load(open(spec, encoding="utf-8"))
served = [p for p, v in d["paths"].items() for m, o in v.items() if m == "get" and o.get("operationId") == "one"]
print("the generated call: %s · its PATH_ONE constant %s · the served document's address for it %s" % (c.get("CALL", "none"), c.get("PATH", "none"), " ".join(served) or "none"))
if c.get("CALL") != "200 Ravi" or served != [c.get("PATH")]:
    print("FAIL (clause 1): the generated public read did not answer two hundred with Ravi at the address the served document gives it"); sys.exit(1)
d.pop("servers", None); b = io.StringIO(); json.dump(d, b, indent=2, ensure_ascii=False); b.write("\n")
if b.getvalue() != open(pp.join(tree, "tiffinbox-web/src/test/resources/openapi/tiffinbox.json"), encoding="utf-8").read():
    print("FAIL (clause 2): the committed file is not the served document with servers removed - write it again from the running tree"); sys.exit(1)
def th(r, skip):
    out = []
    for dd, ds, fs in os.walk(r):
        ds[:] = sorted(x for x in ds if x not in skip)
        for f in sorted(fs):
            q = pp.join(dd, f); out.append(pp.relpath(q, r) + "\0" + hashlib.md5(open(q, "rb").read()).hexdigest())
    return hashlib.md5("\n".join(sorted(out)).encode()).hexdigest()
if th(pp.join(tree, "tiffinbox-client"), {"target"}) != "23b993ca16b95ad804feb7443eb35260" or th(pp.join(tree, "tiffinbox-web/src/main"), set()) != "64165db013817804f5309eaec6c316df":
    print("FAIL (clause 3): a hand-written part moved (tiffinbox-client's pom or test, or tiffinbox-web/src/main) - the fix is in the spec"); sys.exit(1)
print("PASS: the generated public read answered 200 Ravi at the served address; the committed file is the served document; the hand-written parts as ../after's")
PY
