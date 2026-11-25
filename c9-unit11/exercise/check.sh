#!/bin/sh
# check.sh TREE - builds a TiffinBox tree (a copy of ../after made broken by break.sh, never ../after itself): the web module and what it
# needs, its one REST Docs test run, so the snippets are written and the page step is reached; starts the web jar alone on H2 on PORT;
# asks GET /api/v1/customers/Ravi; stops the jar; and reads it all with python. It PASSES only when (1) the build exited 0 and Surefire's
# XML for TiffinBoxRestDocsTest says one test, no failure, no error, none skipped; (2) target/generated-snippets/customer-read holds the
# eight snippets, response-fields.adoc lists exactly the members the wire's body carries, and nickname appears nowhere - not in the test,
# not in a snippet, not in the page; (3) the snippet's response-body.adoc is the wire's body, key for key and value; (4) the hand-written
# parts are untouched - both poms, src/docs, src/main and the committed file hash as ../after's; (5) the test still names status().isOk()
# and document(. Anything else FAILS, naming the clause. MAVEN_REPO set: the build is offline from that repository (the receipt's seed copy).
rm -f check.build.log check.jvm.log check.body.json
rm -rf check.run
[ -n "$1" ] && [ -d "$1" ] || { echo "FAIL: give a copy of ../after to check (cp -R ../after my-tiffinbox; sh break.sh my-tiffinbox; sh check.sh my-tiffinbox)"; exit 1; }
rpath=$(cd "$1" && pwd)
[ "$rpath" != "$(cd ../after && pwd)" ] || { echo "FAIL: ../after is unit 11's frozen tree - check a copy of it"; exit 1; }
port=${PORT:-21008}; ex=$(pwd); after=$(cd ../after && pwd)
jar="$rpath/tiffinbox-web/target/tiffinbox-web-1.0.0.jar"
if [ -n "$MAVEN_REPO" ]; then set -- -o "-Dmaven.repo.local=$MAVEN_REPO"; else set --; fi
(cd "$rpath" && mvn -B "$@" -Duser.home="$HOME" -pl tiffinbox-web -am -Dtest=TiffinBoxRestDocsTest -Dsurefire.failIfNoSpecifiedTests=false clean package) > check.build.log 2>&1
built=$?
if [ "$built" = 0 ] && [ -f "$jar" ]; then
  mkdir -p check.run/secrets/tiffinbox
  (umask 077 && openssl rand -hex 16 > check.run/secrets/tiffinbox/shutdown-token)
  (cd check.run && exec ${JAVA_HOME:+$JAVA_HOME/bin/}java -jar "$jar" --tiffinbox.port="$port" > ../check.jvm.log 2>&1) &
  pid=$!
  i=0; while ! grep -q 'Started TiffinBox' check.jvm.log 2> /dev/null; do
    kill -0 $pid 2> /dev/null || { echo "FAIL: the jar did not start (check.jvm.log)"; exit 1; }
    i=$((i + 1)); [ $i -lt 600 ] || { kill $pid; echo "FAIL: no Started line"; exit 1; }; sleep 0.1; done
  curl --noproxy '*' -s -o check.body.json "http://127.0.0.1:$port/api/v1/customers/Ravi"
  printf 'X-Shutdown-Token: %s\n' "$(cat check.run/secrets/tiffinbox/shutdown-token)" | curl --noproxy '*' -s -o /dev/null -H @- -X POST "http://127.0.0.1:$port/shutdown"
  wait $pid 2> /dev/null
fi
python3 -I - "$built" "$rpath" "$after" check.body.json <<'PY'
import hashlib, json, os, posixpath as pp, re, sys
import xml.etree.ElementTree as ET
built, tree, after, body = sys.argv[1:5]
web = pp.join(tree, "tiffinbox-web"); sn = pp.join(web, "target/generated-snippets/customer-read")
x = pp.join(web, "target/surefire-reports/TEST-com.tiffinbox.web.TiffinBoxRestDocsTest.xml")
r = ET.parse(x).getroot() if pp.exists(x) else None
out = "no Surefire XML"
if r is not None:
    out = "tests %s failures %s errors %s skipped %s" % (r.get("tests"), r.get("failures"), r.get("errors"), r.get("skipped"))
    for tc in r.findall("testcase"):
        for k in ("failure", "error", "skipped"):
            e = tc.find(k)
            if e is not None: out += " · %s %s: %s" % (k, e.get("type") or "-", re.sub(r"\s+", " ", e.get("message") or "").strip()[:140])
have = sorted(os.listdir(sn)) if pp.isdir(sn) else []
print("the test: %s" % out)
print("the snippets: %d (%s) · the build exit %s" % (len(have), ",".join(have) or "none", built))
if built != "0" or r is None or (r.get("tests"), r.get("failures"), r.get("errors"), r.get("skipped")) != ("1", "0", "0", "0"):
    print("FAIL (clause 1): the build did not pass with TiffinBoxRestDocsTest run, passing and not skipped"); sys.exit(1)
src = open(pp.join(web, "src/test/java/com/tiffinbox/web/TiffinBoxRestDocsTest.java"), encoding="utf-8").read()
w = json.load(open(body, encoding="utf-8")) if pp.exists(body) and pp.getsize(body) else {}
eight = ["curl-request.adoc", "http-request.adoc", "http-response.adoc", "httpie-request.adoc", "path-parameters.adoc", "request-body.adoc", "response-body.adoc", "response-fields.adoc"]
rf = open(pp.join(sn, "response-fields.adoc"), encoding="utf-8").read() if "response-fields.adoc" in have else ""
listed = re.findall(r"^\|`\+([^+`]+)\+`\n\|`\+\w+\+`$", rf, re.M)
page = pp.join(web, "target/generated-docs/index.html"); pg = open(page, encoding="utf-8").read() if pp.exists(page) else ""
nick = src.count("nickname") + sum(open(pp.join(sn, f), encoding="utf-8").read().count("nickname") for f in have) + pg.count("nickname")
print("response-fields.adoc lists %s · the wire's body carries %s · nickname appears %d times (test, snippets, page)" % (",".join(listed) or "nothing", ",".join(w) or "nothing", nick))
if have != eight or sorted(listed) != sorted(w) or nick != 0 or not pg:
    print("FAIL (clause 2): not the eight snippets, or response-fields.adoc does not list exactly the wire's members, or nickname is still named"); sys.exit(1)
rb = open(pp.join(sn, "response-body.adoc"), encoding="utf-8").read().split("\n----\n", 1)[1].rsplit("\n----", 1)[0]
if json.loads(rb) != w:
    print("FAIL (clause 3): the snippet's body is not the wire's"); sys.exit(1)
def th(r, skip=()):
    o = []
    for dd, ds, fs in os.walk(r):
        ds[:] = sorted(z for z in ds if z not in skip)
        for f in sorted(fs):
            q = pp.join(dd, f); o.append(pp.relpath(q, r) + "\0" + hashlib.md5(open(q, "rb").read()).hexdigest())
    return hashlib.md5("\n".join(sorted(o)).encode()).hexdigest()
parts = ["pom.xml", "tiffinbox-web/pom.xml", "tiffinbox-web/src/docs", "tiffinbox-web/src/main", "tiffinbox-web/src/test/resources/openapi/tiffinbox.json"]
moved = [p for p in parts if (th(pp.join(tree, p)) if pp.isdir(pp.join(tree, p)) else hashlib.md5(open(pp.join(tree, p), "rb").read()).hexdigest()) != (th(pp.join(after, p)) if pp.isdir(pp.join(after, p)) else hashlib.md5(open(pp.join(after, p), "rb").read()).hexdigest())]
if moved:
    print("FAIL (clause 4): a hand-written part moved (%s) - the fix is in the test" % ",".join(moved)); sys.exit(1)
if "status().isOk()" not in src or "document(" not in src:
    print("FAIL (clause 5): the test no longer checks the status and documents the read"); sys.exit(1)
print("PASS: TiffinBoxRestDocsTest ran and passed; the eight snippets; response-fields.adoc = the wire's members; the body = the wire's; the hand-written parts as ../after's")
PY
