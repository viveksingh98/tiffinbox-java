#!/bin/sh
# check.sh TREE - builds a TiffinBox tree (a copy of ../after, never ../after itself), starts its jar alone on H2 on PORT with Tomcat's
# access log on (the pattern %m %U%q %s %b %{Referer}i: method, address, status, bytes, the page that asked - a flag on this command line
# only, never shipped), and lets you work: with VISIT set, it runs "$VISIT URL" (the receipt's apply.sh); without, it prints the page's
# address for sealed.sh and waits for Enter. Then it stops TiffinBox and reads the log. It PASSES only when (1) the page sent a request
# to one of TiffinBox's routes (a line whose Referer is the page, beyond the page's own files), (2) exactly one, and (3) that one is a GET
# of a customer named Ravi, answered two hundred. Anything else FAILS, naming the clause. MAVEN_REPO set: the build is offline from that
# repository (the receipt's seed copy); unset: your own Maven.
rm -f check.build.log check.jvm.log
rm -rf check.run
[ -n "$1" ] && [ -d "$1" ] || { echo "FAIL: give a copy of ../after to check (cp -R ../after my-tiffinbox; sh check.sh my-tiffinbox)"; exit 1; }
rpath=$(cd "$1" && pwd)
[ "$rpath" != "$(cd ../after && pwd)" ] || { echo "FAIL: ../after is the unit's frozen tree - check a copy of it"; exit 1; }
port=${PORT:-20978}
jar="$rpath/tiffinbox-web/target/tiffinbox-web-1.0.0.jar"
if [ -n "$MAVEN_REPO" ]; then set -- -o "-Dmaven.repo.local=$MAVEN_REPO"; else set --; fi
(cd "$rpath" && mvn -B "$@" -Duser.home="$HOME" -DskipTests clean package -pl tiffinbox-web -am) > check.build.log 2>&1 || { echo "FAIL: the tree did not build (check.build.log)"; exit 1; }
[ -f "$jar" ] || { echo "FAIL: no jar after the build"; exit 1; }
mkdir -p check.run/secrets/tiffinbox check.run/access
(umask 077 && openssl rand -hex 16 > check.run/secrets/tiffinbox/shutdown-token)
(cd check.run && exec ${JAVA_HOME:+$JAVA_HOME/bin/}java -jar "$jar" --tiffinbox.port="$port" --server.tomcat.accesslog.enabled=true \
   --server.tomcat.accesslog.directory="$PWD/access" --server.tomcat.accesslog.prefix=access --server.tomcat.accesslog.suffix=.log \
   --server.tomcat.accesslog.file-date-format= --server.tomcat.accesslog.rotate=false "--server.tomcat.accesslog.pattern=%m %U%q %s %b %{Referer}i" \
   --server.tomcat.accesslog.buffered=false > ../check.jvm.log 2>&1) &
pid=$!
i=0; while ! grep -q 'Started TiffinBox' check.jvm.log 2> /dev/null; do
  kill -0 $pid 2> /dev/null || { echo "FAIL: the jar did not start (check.jvm.log)"; exit 1; }
  i=$((i + 1)); [ $i -lt 600 ] || { kill $pid; echo "FAIL: no Started line"; exit 1; }; sleep 0.1; done
url="http://127.0.0.1:$port/swagger-ui/index.html"
if [ -n "$VISIT" ]; then $VISIT "$url" > /dev/null 2>&1; else echo "open it: sh sealed.sh $url - find the request, then press Enter here"; read answer; fi
printf 'X-Shutdown-Token: %s\n' "$(cat check.run/secrets/tiffinbox/shutdown-token)" | curl --noproxy '*' -s -o /dev/null -H @- -X POST "http://127.0.0.1:$port/shutdown"
wait $pid 2> /dev/null
python3 -I - check.run/access/access.log "$url" <<'PY'
import sys
log, page = sys.argv[1:3]
own = ("/swagger-ui/", "/v3/api-docs", "/swagger-ui.html")
rows = [l.split(" ") for l in open(log).read().splitlines() if l.strip()]
for r in rows:                      # Tomcat prints an empty query string as "-" right after the address: the address is what is before it
    if len(r) > 1 and r[1].endswith("-"): r[1] = r[1][:-1]
ui = [r for r in rows if len(r) >= 5 and r[4] == page and not r[1].startswith(own)]
def show(r): return "%s %s %s" % (r[0], r[1], r[2])
if not ui: print("FAIL (clause 1): no request from the page to TiffinBox's routes (access-log lines: %d, none with the page as Referer beyond its own files)" % len(rows)); sys.exit(1)
if len(ui) != 1: print("FAIL (clause 2): %d requests from the page, not one: %s" % (len(ui), " · ".join(show(r) for r in ui))); sys.exit(1)
r = ui[0]
if not (r[0] == "GET" and r[1].endswith("/customers/Ravi") and r[2] == "200"): print("FAIL (clause 3): the page's one request is %s, not a GET of Ravi answered 200" % show(r)); sys.exit(1)
print("PASS: one request from the page, %s (the access log, Referer the page)" % show(r))
PY
