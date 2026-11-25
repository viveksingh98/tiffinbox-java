#!/bin/sh
# check.sh TREE - reads the learner's saved answer, TREE/answer.http, against a live start of the tree (a copy of ../after made retired by
# break.sh, never ../after itself). It builds the tree (-DskipTests: the existing tests are red on a retired tree), starts its jar alone
# on H2 on PORT, sends the OLD request GET /api/v1/customers/Ravi itself, stops the jar, and PASSES only when python reads: (1) answer.http
# exists and holds an HTTP answer; (2) its request line, if present, is the old request; (3) its status is the live status; (4) its
# detail is the live body's detail, character for character; (5) the tree is the retired tree - TiffinBoxApiVersioning.java as break.sh
# writes it, every other src/main path, both poms and the committed spec as ../after's; (6) it carries no Deprecation or Sunset header the
# live answer lacks. Anything else FAILS, naming the clause. MAVEN_REPO set: the build is offline from that repository.
rm -f check.build.log check.jvm.log check.body.json check.h
rm -rf check.run
[ -n "$1" ] && [ -d "$1" ] || { echo "FAIL: give a copy of ../after to check (cp -R ../after my-tiffinbox; sh break.sh my-tiffinbox; sh check.sh my-tiffinbox)"; exit 1; }
rpath=$(cd "$1" && pwd)
[ "$rpath" != "$(cd ../after && pwd)" ] || { echo "FAIL: ../after is unit 12's frozen tree - check a copy of it"; exit 1; }
port=${PORT:-21018}; after=$(cd ../after && pwd)
jar="$rpath/tiffinbox-web/target/tiffinbox-web-1.0.0.jar"
if [ -n "$MAVEN_REPO" ]; then set -- -o "-Dmaven.repo.local=$MAVEN_REPO"; else set --; fi
(cd "$rpath" && mvn -B "$@" -Duser.home="$HOME" -DskipTests -pl tiffinbox-web -am clean package) > check.build.log 2>&1
built=$?
if [ "$built" = 0 ] && [ -f "$jar" ]; then
  mkdir -p check.run/secrets/tiffinbox
  (umask 077 && openssl rand -hex 16 > check.run/secrets/tiffinbox/shutdown-token)
  (cd check.run && exec ${JAVA_HOME:+$JAVA_HOME/bin/}java -jar "$jar" --tiffinbox.port="$port" > ../check.jvm.log 2>&1) &
  pid=$!
  i=0; while ! grep -q 'Started TiffinBox' check.jvm.log 2> /dev/null; do
    kill -0 $pid 2> /dev/null || { echo "FAIL: the jar did not start (check.jvm.log)"; exit 1; }
    i=$((i + 1)); [ $i -lt 600 ] || { kill $pid; echo "FAIL: no Started line"; exit 1; }; sleep 0.1; done
  curl --noproxy '*' --http1.1 -s -D check.h -o check.body.json "http://127.0.0.1:$port/api/v1/customers/Ravi"
  printf 'X-Shutdown-Token: %s\n' "$(cat check.run/secrets/tiffinbox/shutdown-token)" | curl --noproxy '*' -s -o /dev/null -H @- -X POST "http://127.0.0.1:$port/shutdown"
  wait $pid 2> /dev/null
fi
python3 -I - "$built" "$rpath" "$after" check.h check.body.json <<'PY'
import hashlib, json, os, posixpath as pp, re, sys
built, tree, after, lh, lb = sys.argv[1:6]
if built != "0" or not pp.exists(lb):
    print("FAIL (clause 5): the tree did not build or start (check.build.log)"); sys.exit(1)
lhs = open(lh, encoding="utf-8").read().replace("\r", "").split("\n")
lst = lhs[0].split(" ")[1] if lhs and lhs[0].startswith("HTTP/") else "-"
lbody = json.load(open(lb, encoding="utf-8"))
print("the live answer to the old request: %s · detail: %s" % (lst, lbody.get("detail")))
ans = pp.join(tree, "answer.http")
if not pp.exists(ans) or not open(ans, encoding="utf-8").read().strip():
    print("FAIL (clause 1): no answer saved - send the old request with curl -i and save what TiffinBox answers in TREE/answer.http"); sys.exit(1)
t = open(ans, encoding="utf-8").read().replace("\r", "")
ls = t.split("\n")
st = next((l for l in ls if l.startswith("HTTP/")), None)
if st is None:
    print("FAIL (clause 1): answer.http holds no HTTP status line"); sys.exit(1)
req = next((l for l in ls[:ls.index(st)] if re.match(r"^(GET|POST|PUT|PATCH|DELETE|HEAD|OPTIONS) ", l)), None)
if req is not None and req.split(" ")[1] != "/api/v1/customers/Ravi":
    print("FAIL (clause 2): the saved request is %s - send the OLD request, GET /api/v1/customers/Ravi" % req.split(" ")[1]); sys.exit(1)
if st.split(" ")[1] != lst:
    print("FAIL (clause 3): the saved status %s is not what TiffinBox answers (%s)" % (st.split(" ")[1], lst)); sys.exit(1)
body = t.split("\n\n", 1)[1].strip() if "\n\n" in t else ""
try: sb = json.loads(body)
except ValueError: sb = {}
if sb.get("detail") != lbody.get("detail"):
    print("FAIL (clause 4): the saved detail %r is not the live one, character for character" % sb.get("detail")); sys.exit(1)
f = "tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxApiVersioning.java"
a = open(pp.join(after, f), encoding="utf-8").read().replace('setVersionRequired(false).addSupportedVersions("1.0");', 'setVersionRequired(false).addSupportedVersions("2.0");')
md = lambda p: hashlib.md5(open(p, "rb").read()).hexdigest()
def th(r):
    o = []
    for dd, ds, fs in os.walk(r):
        ds.sort()
        for x in sorted(fs):
            q = pp.join(dd, x); o.append(pp.relpath(q, r) + "\0" + md(q))
    return hashlib.md5("\n".join(sorted(o)).encode()).hexdigest()
others = [p for p in ("pom.xml", "tiffinbox-web/pom.xml", "tiffinbox-web/src/test/resources/openapi/tiffinbox.json") if md(pp.join(tree, p)) != md(pp.join(after, p))]
mt = {pp.relpath(pp.join(d, x), pp.join(tree, "tiffinbox-web/src/main")) for d, _, fs in os.walk(pp.join(tree, "tiffinbox-web/src/main")) for x in fs}
ma = {pp.relpath(pp.join(d, x), pp.join(after, "tiffinbox-web/src/main")) for d, _, fs in os.walk(pp.join(after, "tiffinbox-web/src/main")) for x in fs}
skip = "java/com/tiffinbox/web/TiffinBoxApiVersioning.java"
others += ["src/main/" + x for x in sorted(mt ^ ma)] + ["src/main/" + x for x in sorted(mt & ma) if x != skip and md(pp.join(tree, "tiffinbox-web/src/main", x)) != md(pp.join(after, "tiffinbox-web/src/main", x))]
if open(pp.join(tree, f), encoding="utf-8").read() != a or others:
    print("FAIL (clause 5): not the retired tree - TiffinBoxApiVersioning.java is not break.sh's, or another part moved (%s)" % ",".join(others)); sys.exit(1)
live = {l.split(":", 1)[0].lower() for l in lhs[1:] if ":" in l}
extra = [h for h in ("deprecation", "sunset") if any(l.lower().startswith(h + ":") for l in ls) and h not in live]
if extra:
    print("FAIL (clause 6): the saved answer carries %s, the live answer does not" % ",".join(extra)); sys.exit(1)
print("PASS: the saved answer is the old request's, its status %s and its detail the live answer's; the tree is the retired tree" % lst)
PY
