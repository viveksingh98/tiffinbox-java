#!/bin/sh
# Course 9 unit 17's exercise check: build TREE (a copy of ../after, offline from MAVEN_REPO when set), start its jar alone on PORT
# (default 21068; H2 in memory; the harness's pause between customers on the command line, so a run is seen RUNNING), send the requests
# itself, poll the status resource by its condition under a guard, and PASS only if every clause holds:
#   (1) POST /api/v1/billing-runs -> 202, its Location ending /api/v1/billing-runs/<id>
#   (2) at least one poll in the RUNNING state carries Retry-After with a non-negative integer value
#   (3) every poll in a terminal state carries no Retry-After
#   (4) the terminal body holds the four customers' bills (Meera, Priya, Ravi, Sunil)
#   (5) every src/main file but BillingRuns.java, the three poms and the spec md5-equal to ../after's (a fix elsewhere cannot pass)
#   (6) in BillingRuns.java's status handler, Retry-After is set inside a condition on the run's state
# Usage: sh check.sh TREE
T=${1:?usage: sh check.sh TREE}
HERE=$(cd "$(dirname "$0")" && pwd -P); AFTER=$(cd "$HERE/../after" && pwd -P)
[ "$(cd "$T" && pwd -P)" != "$AFTER" ] || { echo "check.sh: refused - that is ../after itself; copy it first"; exit 1; }
T=$(cd "$T" && pwd -P)
PORT=${PORT:-21068}; RUN="$HERE/check.run"; B="http://127.0.0.1:$PORT"
PAUSE=${PAUSE:-400}   # the harness's pause between two customers (tiffinbox.billing-runs.harness-pause-ms), a label, off in TiffinBox by default
rm -f "$HERE/check.build.log" "$HERE/check.jvm.log" "$HERE/check.b" "$HERE/check.h" "$HERE/check.polls"; rm -rf "$RUN"
cd "$T" || exit 1
mvn -o -B -q ${MAVEN_REPO:+"-Dmaven.repo.local=$MAVEN_REPO"} -DskipTests clean package -pl tiffinbox-web -am > "$HERE/check.build.log" 2>&1 || { echo "check.sh: the tree did not build (check.build.log)"; exit 1; }
echo "built: mvn -o -DskipTests clean package -pl tiffinbox-web -am (exit 0)"
mkdir -p "$RUN/secrets/tiffinbox"; (umask 077 && openssl rand -hex 16 > "$RUN/secrets/tiffinbox/shutdown-token")
(cd "$RUN" && exec java -Duser.language=en -Duser.country=US -jar "$T/tiffinbox-web/target/tiffinbox-web-1.0.0.jar" --tiffinbox.port="$PORT" --tiffinbox.billing-runs.harness-pause-ms="$PAUSE" > "$HERE/check.jvm.log" 2>&1) &
JP=$!
i=0; while ! grep -q 'Started TiffinBox' "$HERE/check.jvm.log" 2> /dev/null; do kill -0 $JP 2> /dev/null || { echo "check.sh: the JVM exited before it started"; exit 1; }; i=$((i + 1)); [ $i -lt 600 ] || { kill $JP; echo "check.sh: no Started line"; exit 1; }; sleep 0.1; done
echo "started: the jar alone, H2, delay=on (the harness's pause on the command line)"
hv() { tr -d '\r' < "$HERE/check.h" | grep -i "^$1:" | head -1 | sed -E 's/^[^:]*: *//'; }
W1=$(curl --noproxy '*' --http1.1 -s -D "$HERE/check.h" -o "$HERE/check.b" -w '%{http_code}' -X POST "$B/api/v1/billing-runs"); LOC=$(hv Location)
echo "POST /api/v1/billing-runs -> $W1 · Location $(echo "$LOC" | sed -E 's#127\.0\.0\.1:[0-9]+#127.0.0.1:<port>#; s#[0-9a-f-]{36}$#<id>#')"
: > "$HERE/check.polls"; END=$(( $(date +%s) + 20 )); ST=""
if [ -n "$LOC" ]; then
  while :; do
    W=$(curl --noproxy '*' --http1.1 -s -D "$HERE/check.h" -o "$HERE/check.b" -w '%{http_code} %{content_type}' "$LOC"); RA=$(hv Retry-After)
    ST=$(python3 -I -c 'import json,sys
try: print(json.load(open(sys.argv[1]))["state"])
except Exception: print("none")' "$HERE/check.b")
    printf '%s\t%s\t%s\t%s\n' "$ST" "${RA:-absent}" "$W" "$(tr -d '\n' < "$HERE/check.b")" >> "$HERE/check.polls"
    [ "$ST" = RUNNING ] || break
    [ "$(date +%s)" -lt "$END" ] || { echo "the guard: still RUNNING at the guard (a guard, not a measurement)"; break; }
    case "$RA" in ''|*[!0-9]*) sleep 0.2 ;; *) sleep "$RA" ;; esac   # Retry-After's own value when sent; else the client's own short pause
  done
fi
printf 'X-Shutdown-Token: %s\n' "$(cat "$RUN/secrets/tiffinbox/shutdown-token")" | curl --noproxy '*' -s -o /dev/null -H @- -X POST "$B/shutdown"
i=0; while kill -0 $JP 2> /dev/null; do i=$((i + 1)); [ $i -lt 100 ] || { kill $JP; break; }; sleep 0.1; done; wait $JP 2> /dev/null
rc=0
python3 -I - "$W1" "$LOC" "$HERE/check.polls" "$T" "$AFTER" <<'PY' || rc=1
import json, sys, os, hashlib, re
w1, loc, polls, t, a = sys.argv[1:6]
ps = [l.rstrip("\n").split("\t") for l in open(polls) if l.strip()]
run = [p for p in ps if p[0] == "RUNNING"]; term = [p for p in ps if p[0] in ("SUCCEEDED", "FAILED")]
def show(p): return "%s %s · Retry-After %s" % (p[2], "", "present" if p[1] != "absent" else "absent")
if run: print("measured: RUNNING -> %s · Retry-After %s" % (run[0][2], "present" if run[0][1] != "absent" else "absent"))
if term: print("measured: %s -> %s · Retry-After %s · bills %s" % (term[0][0], term[0][2], "present" if term[0][1] != "absent" else "absent",
                                                                   " ".join("%s=%s" % kv for kv in sorted((json.loads(term[0][3]).get("bills") or {}).items()))))
print("states observed in order: %s" % " ".join(dict.fromkeys(p[0] for p in ps)))
bad = []
if not (w1 == "202" and re.search(r"/api/v1/billing-runs/[0-9a-f-]{36}$", loc or "")):
    bad.append("(1) the POST does not answer 202 with Location /api/v1/billing-runs/<id> (got %s)" % w1)
if not any(re.fullmatch(r"\d+", p[1]) for p in run):
    bad.append("(2) no RUNNING poll carries Retry-After with a non-negative integer value (the status resource never says when to come back)")
if any(p[1] != "absent" for p in term):
    bad.append("(3) a finished run's answer still carries Retry-After")
names = set()
for p in term:
    try: names |= set((json.loads(p[3]).get("bills") or {}).keys())
    except Exception: pass
if not term or not {"Meera", "Priya", "Ravi", "Sunil"} <= names:
    bad.append("(4) no terminal answer holds the four customers' bills")
def md5(q): return hashlib.md5(open(q, "rb").read()).hexdigest()
for root in ("tiffinbox-web/src/main", "tiffinbox-core/src/main"):
    for d, _, fs in os.walk(os.path.join(a, root)):
        for f in fs:
            rel = os.path.relpath(os.path.join(d, f), a)
            if rel.endswith("BillingRuns.java"): continue
            q = os.path.join(t, rel)
            if not os.path.exists(q) or md5(q) != md5(os.path.join(a, rel)):
                bad.append("(5) %s differs from ../after's (the fix belongs in BillingRuns.java alone)" % rel)
for rel in ("pom.xml", "tiffinbox-web/pom.xml", "tiffinbox-core/pom.xml", "tiffinbox-web/src/test/resources/openapi/tiffinbox.json"):
    if md5(os.path.join(t, rel)) != md5(os.path.join(a, rel)): bad.append("(5) %s differs from ../after's" % rel)
s = re.sub(r"(?s)/\*.*?\*/|//[^\n]*", "", open(os.path.join(t, "tiffinbox-web/src/main/java/com/tiffinbox/web/BillingRuns.java")).read())
h = s.split("billingRun(@PathVariable", 1)[-1].split("private void bill(", 1)[0]
if not re.search(r"if \([^\n]*\bState\.\w+[^\n]*\) \{\s*answer\.header\(HttpHeaders\.RETRY_AFTER", h):
    bad.append("(6) the status handler does not set Retry-After inside a condition on the run's state")
for b in bad: print("FAIL " + b)
print("PASS - every clause holds" if not bad else "check.sh: %d clause(s) failed" % len(bad))
sys.exit(1 if bad else 0)
PY
rm -rf "$RUN"; rm -f "$HERE/check.b" "$HERE/check.h" "$HERE/check.polls"
exit $rc
