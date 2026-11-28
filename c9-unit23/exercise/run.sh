#!/bin/sh
# Course 9 unit 23's exercise: run.sh DIR - builds ../before (offline from $MAVEN_REPO when it is set, -DskipTests) under
# exercise/.servers/ once, starts its jar on $PORT (21128 by default; H2 in memory, the default capacity, the default exposure),
# sends the requests of requests.txt, saves the scrape (/actuator/prometheus, every value but the _count lines masked <v>) to
# DIR/scrape.txt, stops the JVM by its recorded pid, and leaves DIR/answer.txt empty - the broken state you fill.
D=$1
[ -n "$D" ] || { echo "usage: sh run.sh DIR"; exit 2; }
mkdir -p "$D"
HERE=$(cd "$(dirname "$0")" && pwd)
PORT=${PORT:-21128}
JAVA=java; [ -n "$JAVA_HOME" ] && JAVA="$JAVA_HOME/bin/java"
S="$HERE/.servers"; mkdir -p "$S"
JAR="$S/tree/tiffinbox-web/target/tiffinbox-web-1.0.0.jar"
if [ ! -f "$JAR" ]; then
  rsync -a --exclude target --exclude secrets --exclude .m2-demo "$HERE/../before/" "$S/tree/" || { echo "copy failed"; exit 1; }
  (cd "$S/tree" && mvn -o -B ${MAVEN_REPO:+"-Dmaven.repo.local=$MAVEN_REPO"} -DskipTests clean package -pl tiffinbox-web -am > "$S/build.log" 2>&1) || { echo "the build failed: $S/build.log"; tail -5 "$S/build.log"; exit 1; }
  echo "built ../before offline (mvn -o -DskipTests clean package -pl tiffinbox-web -am, exit 0)"
else
  echo "built ../before earlier in this folder (the same jar, reused)"
fi
R="$S/run"; rm -rf "$R"; mkdir -p "$R/secrets/tiffinbox"
(umask 077 && openssl rand -hex 16 > "$R/secrets/tiffinbox/shutdown-token")
(cd "$R" && exec "$JAVA" -jar "$JAR" --tiffinbox.port="$PORT" > jvm.log 2>&1) &
echo $! > "$R/pid"
i=0
while ! grep -q 'Started TiffinBox' "$R/jvm.log" 2> /dev/null; do
  kill -0 "$(cat "$R/pid")" 2> /dev/null || { echo "the JVM exited before its Started line"; tail -5 "$R/jvm.log"; exit 1; }
  i=$((i + 1)); [ $i -lt 1200 ] || { echo "no Started line"; kill "$(cat "$R/pid")"; exit 1; }; sleep 0.1
done
echo "up on $PORT (H2, the default capacity, the default exposure)"
python3 -I - "$PORT" "$HERE/requests.txt" "$D/scrape.txt" <<'PY'
import http.client, re, sys, time
port, reqs, out = int(sys.argv[1]), sys.argv[2], sys.argv[3]
n = 0
for l in open(reqs).read().splitlines():
    if not l.strip(): continue
    m, u = l.split()[:2]
    c = http.client.HTTPConnection("127.0.0.1", port, timeout=10); c.request(m, u); r = c.getresponse(); r.read(); c.close(); n += 1
    print("sent %s %s -> %d" % (m, u, r.status))
def read():
    c = http.client.HTTPConnection("127.0.0.1", port, timeout=10); c.request("GET", "/actuator/prometheus"); r = c.getresponse(); b = r.read().decode(); c.close(); return b
def rows(t):
    return sorted(l for l in t.splitlines() if l.startswith("http_server_requests_seconds_count{") and 'uri="/actuator/' not in l)
a = read()
for _ in range(20):
    time.sleep(0.5); b = read()
    if rows(a) == rows(b): break
    a = b
res = []
for l in a.splitlines():
    if l.startswith("#"):
        if l.startswith("# HELP") or l.startswith("# TYPE"): res.append(l)
    elif l.startswith("http_server_requests_seconds_count{"): res.append(l)
    elif " " in l: res.append(l.rsplit(" ", 1)[0] + " <v>")
open(out, "w").write("\n".join(res) + "\n")
k = {}
for l in rows(a):
    if 'status="404"' in l:
        uri = re.search(r'uri="([^"]*)"', l).group(1); k[uri] = int(float(l.rsplit(" ", 1)[1]))
print("404 rows in the scrape: " + " · ".join("%s %d" % (u, k[u]) for u in sorted(k)))
PY
st=$?
printf 'X-Shutdown-Token: %s\n' "$(head -1 "$R/secrets/tiffinbox/shutdown-token")" | curl --noproxy '*' -s -o /dev/null --max-time 5 -H @- -X POST "http://127.0.0.1:$PORT/shutdown"
p=$(cat "$R/pid"); i=0
while kill -0 "$p" 2> /dev/null; do i=$((i + 1)); [ $i = 100 ] && kill "$p"; sleep 0.05; done
echo "stopped (its recorded pid)"
: > "$D/answer.txt"
exit $st
