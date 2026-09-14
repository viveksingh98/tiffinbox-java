#!/bin/bash
# watch.sh — the whole unit in one script: record, load, ask, stop, prove the port is free.
# Usage:  ./watch.sh [port]          (default 18543)
# Needs:  ../c2-capstone already built with `mvn -B clean package`
set -u
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # line 1, always: a bare shell here gives Maven JDK 26
export PATH="$JAVA_HOME/bin:$PATH"

HERE=$(cd "$(dirname "$0")" && pwd)
CAP="$HERE/../c2-capstone"
PORT=${1:-18543}
JFR="$HERE/tiffinbox.jfr"

[ -f "$CAP/target/c2-capstone-1.0.0.jar" ] || { echo "build the capstone first: (cd $CAP && mvn -B clean package)"; exit 1; }
lsof -nP -iTCP:$PORT -sTCP:LISTEN && { echo "port $PORT is already in use — pick another"; exit 1; }
echo "port $PORT free"

# ---- 1. start the server with a flight recording running from the first instruction
cd "$CAP" || exit 1
java --enable-preview \
  "-XX:StartFlightRecording=name=tiffinbox,filename=$JFR,settings=profile,+jdk.VirtualThreadStart#enabled=true" \
  -Djava.util.logging.config.file=logging.properties \
  -jar target/c2-capstone-1.0.0.jar "$PORT" > "$HERE/server.log" 2>&1 &
PID=$!
for _ in $(seq 1 60); do grep -q "listening on" "$HERE/server.log" && break; sleep 0.25; done
cat "$HERE/server.log"

# ---- 2. real load: 20,000 requests, 200 in flight, one virtual thread each
( cd "$HERE" && java Load.java "$PORT" 20000 200 ) &
LOAD=$!

# ---- 3. ask the live pid three questions, while it is busy
for _ in $(seq 1 120); do
  ST=$(jcmd $PID Thread.vthread_scheduler 2>/dev/null | grep -o 'steals = [0-9]*' | grep -o '[0-9]*')
  [ -n "${ST:-}" ] && [ "$ST" -gt 25000 ] && break
  sleep 0.25
done
echo "--- jcmd $PID Thread.print  (platform threads only)"
jcmd $PID Thread.print | grep '^"ForkJoinPool-1-worker'
echo "--- jcmd $PID Thread.dump_to_file -format=json  (this one has the virtual threads)"
# jcmd splits diagnostic-command arguments on spaces and has no quoting, so the
# destination must be a path with no spaces in it. Measured: a path containing a
# space fails with  java.lang.IllegalArgumentException: Unknown argument '...'
TMPJSON=${TMPDIR:-/tmp}threads-tiffinbox.json
# a thread dump is an instant, and a request here lasts well under a millisecond, so
# take several and keep the most interesting one — the "carrier" field only appears on a
# virtual thread that happened to be mounted at that instant
BEST=0 BESTC=0
for _ in 1 2 3 4; do
  jcmd $PID Thread.dump_to_file -overwrite -format=json "$TMPJSON" > /dev/null
  n=$(grep -c '"virtual": true' "$TMPJSON")
  c=$(grep -c '"carrier"' "$TMPJSON")
  if [ "$c" -gt "$BESTC" ] || { [ "$c" -eq "$BESTC" ] && [ "$n" -gt "$BEST" ]; }; then
    BEST=$n; BESTC=$c; cp "$TMPJSON" "$HERE/threads.json"
  fi
done
echo "kept the dump with $BEST virtual threads, $BESTC of them mounted on a carrier"
grep -m1 'ThreadPerTaskExecutor' "$HERE/threads.json"
grep -m1 '"threadCount"' "$HERE/threads.json"
grep -m1 -B5 '"carrier"' "$HERE/threads.json" | grep -v '"stack"\|java\.\|sun\.\|com\.\|jdk\.\|"\.\.\.'
echo "--- jcmd $PID Thread.vthread_scheduler"
jcmd $PID Thread.vthread_scheduler
wait $LOAD

# ---- 4. stop the recording, stop the server
jcmd $PID JFR.stop name=tiffinbox
curl -s -X POST "http://127.0.0.1:$PORT/shutdown"; echo
sleep 2

# ---- 5. prove nothing is left behind
lsof -nP -iTCP:$PORT -sTCP:LISTEN || echo "port $PORT free"
pgrep -f "c2-capstone-1.0.0.jar $PORT" || echo "no server process"
kill -0 $PID 2>/dev/null && kill -9 $PID

# ---- 6. read the recording
echo "--- jfr summary $JFR | grep ThreadStart"
jfr summary "$JFR" | grep ThreadStart
echo "--- jfr view allocation-by-class $JFR"
jfr view --width 62 allocation-by-class "$JFR" | sed -n '1,8p'
echo "--- jfr view hot-methods $JFR"
jfr view --width 110 hot-methods "$JFR" | sed -n '1,12p'
