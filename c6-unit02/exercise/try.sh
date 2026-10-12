#!/bin/bash
# exercise/try.sh CONFIG PATH... - the exercise's run. The raw servlet (harness/web/harness/RawServlet.java) and CONFIG - a
# RawServletConfig: the shipped one, yours, or the solution's - compiled into .harness/mine/hc against the copy's own jars; the
# copy in .harness/mine (exercise/README.md's setup builds it) started exploded with the registration joined - TiffinBox's own
# server on 19318, Tomcat on 19319, both on 127.0.0.1; readiness waited for, 60 s at most; each PATH asked of Tomcat
# (harness/paths.sh: the status, the content type and the answer, which names the pattern that matched); then the JVM stopped
# by its pid - on every exit, Ctrl-C included.
set -e
cd "$(dirname "$0")/.."
M=.harness/mine
[ -f "$M/tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar" ] || { echo "run exercise/README.md's setup first: $M holds no extracted jar"; exit 1; }
[ -f "${1:-}" ] || { echo "usage: exercise/try.sh CONFIG PATH... (CONFIG: a RawServletConfig.java)"; exit 2; }
C=$1; shift
rm -rf "$M/hc" && mkdir -p "$M/hc"
javac -d "$M/hc" -cp "$M/tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:$M/tiffinbox-web/target/extracted/lib/*" harness/web/harness/RawServlet.java "$C"
p=""
trap 'if [ -n "$p" ]; then kill "$p" 2> /dev/null || true; wait "$p" 2> /dev/null || true; fi' EXIT
trap 'exit 130' INT TERM
(cd "$M" && exec java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19318 --spring.main.sources=harness.RawServletConfig --server.address=127.0.0.1 --server.port=19319 > run.log 2>&1 < /dev/null) & p=$!
i=0
while [ $i -lt 240 ]; do
  [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19318/actuator/health/readiness || true)" = 200 ] && break
  kill -0 "$p" 2> /dev/null || { echo "it stopped before readiness answered 200 - read $M/run.log"; exit 1; }
  sleep 0.25; i=$((i + 1))
done
[ $i -lt 240 ] || { echo "readiness never answered 200 within 60 s - read $M/run.log"; exit 1; }
harness/paths.sh 19319 "$@"
