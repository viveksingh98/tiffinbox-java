#!/bin/sh
# Course 9 unit 20's exercise check: build TREE (a copy of ../after, offline from MAVEN_REPO when set), start its jar alone on PORT
# (default 21098; H2 in memory, a fresh database; the default settings), send the requests itself, and PASS only if every clause holds:
#   (1) GET /api/v1/customers/Ravi answers an ETag; a merge PATCH with it as If-Match answers 200 and the tag moves
#   (2) the OLD tag again on the merge PATCH answers 412, and Ravi reads back as the first PATCH left him
#   (3) the OLD tag on the JSON Patch route answers 412, and Ravi still reads back unchanged
#   (4) a weak W/ form of the current tag answers 412
#   (5) a PATCH with no If-Match answers 200 (an unconditional write, as before)
#   (6) every src/main file but CustomerPatches.java md5-equal to ../after's
# Usage: sh check.sh TREE
T=${1:?usage: sh check.sh TREE}
HERE=$(cd "$(dirname "$0")" && pwd -P); AFTER=$(cd "$HERE/../after" && pwd -P)
[ "$(cd "$T" && pwd -P)" != "$AFTER" ] || { echo "check.sh: refused - that is ../after itself; copy it first"; exit 1; }
T=$(cd "$T" && pwd -P)
PORT=${PORT:-21098}; RUN="$HERE/check.run"; B="http://127.0.0.1:$PORT"
rm -f "$HERE/check.build.log" "$HERE/check.jvm.log"; rm -rf "$RUN"
cd "$T" || exit 1
mvn -o -B -q ${MAVEN_REPO:+"-Dmaven.repo.local=$MAVEN_REPO"} -DskipTests clean package -pl tiffinbox-web -am > "$HERE/check.build.log" 2>&1 || { echo "check.sh: the tree did not build (check.build.log)"; exit 1; }
echo "built: mvn -o -DskipTests clean package -pl tiffinbox-web -am (exit 0)"
mkdir -p "$RUN/secrets/tiffinbox"; (umask 077 && openssl rand -hex 16 > "$RUN/secrets/tiffinbox/shutdown-token")
(cd "$RUN" && exec java -Duser.language=en -Duser.country=US -jar "$T/tiffinbox-web/target/tiffinbox-web-1.0.0.jar" --tiffinbox.port="$PORT" > "$HERE/check.jvm.log" 2>&1) &
JP=$!
i=0; while ! grep -q 'Started TiffinBox' "$HERE/check.jvm.log" 2> /dev/null; do kill -0 $JP 2> /dev/null || { echo "check.sh: the JVM exited before it started"; exit 1; }; i=$((i + 1)); [ $i -lt 600 ] || { kill $JP; echo "check.sh: no Started line"; exit 1; }; sleep 0.1; done
echo "started: the jar alone, H2, the default settings"
u="$B/api/v1/customers/Ravi"; MP='Content-Type: application/merge-patch+json'; JP2='Content-Type: application/json-patch+json'
tagof() { curl --noproxy '*' --http1.1 -s -o /dev/null -D - "$u" | tr -d '\r' | sed -n 's/^[Ee][Tt][Aa][Gg]: //p'; }
T0=$(tagof)
P1=$(curl --noproxy '*' --http1.1 -s -o /dev/null -w '%{http_code}' -X PATCH -H "$MP" -H "If-Match: $T0" --data-binary '{"mealsPerDay":3}' "$u")
T1=$(tagof); R1=$(curl --noproxy '*' --http1.1 -s "$u")
P2=$(curl --noproxy '*' --http1.1 -s -o /dev/null -w '%{http_code}' -X PATCH -H "$MP" -H "If-Match: $T0" --data-binary '{"mealsPerDay":1}' "$u")
R2=$(curl --noproxy '*' --http1.1 -s "$u")
P3=$(curl --noproxy '*' --http1.1 -s -o /dev/null -w '%{http_code}' -X PATCH -H "$JP2" -H "If-Match: $T0" --data-binary '[{"op":"replace","path":"/mealsPerDay","value":1}]' "$u")
R3=$(curl --noproxy '*' --http1.1 -s "$u"); T3=$(tagof)
P4=$(curl --noproxy '*' --http1.1 -s -o /dev/null -w '%{http_code}' -X PATCH -H "$MP" -H "If-Match: W/$T3" --data-binary '{"mealsPerDay":2}' "$u")
P5=$(curl --noproxy '*' --http1.1 -s -o /dev/null -w '%{http_code}' -X PATCH -H "$MP" --data-binary '{"mealsPerDay":2}' "$u")
printf 'X-Shutdown-Token: %s\n' "$(cat "$RUN/secrets/tiffinbox/shutdown-token")" | curl --noproxy '*' -s -o /dev/null -H @- -X POST "$B/shutdown"
i=0; while kill -0 $JP 2> /dev/null; do i=$((i + 1)); [ $i -lt 100 ] || { kill $JP; break; }; sleep 0.1; done; wait $JP 2> /dev/null
echo "measured: tag $T0 · PATCH with it -> $P1, the tag now $T1 · the old tag again (merge) -> $P2 · (JSON Patch) -> $P3 · W/ of the current -> $P4 · no If-Match -> $P5"
echo "read back: after the first PATCH $R1 · after the old tag (merge) $R2 · after the old tag (JSON Patch) $R3"
rc=0
python3 -I - "$T0" "$P1" "$T1" "$P2" "$R1" "$R2" "$P3" "$R3" "$P4" "$P5" "$T" "$AFTER" <<'PY' || rc=1
import sys, os, hashlib
t0, p1, t1, p2, r1, r2, p3, r3, p4, p5, t, a = sys.argv[1:13]
bad = []
if not (t0 and p1 == "200" and t1 and t1 != t0): bad.append("(1) the tag %s, the PATCH with it %s, the tag after %s" % (t0 or "none", p1, t1 or "none"))
if not (p2 == "412" and r2 == r1): bad.append("(2) the old tag on the merge PATCH answered %s and Ravi reads %s: a stale tag wrote" % (p2, "unchanged" if r2 == r1 else "CHANGED"))
if not (p3 == "412" and r3 == r1): bad.append("(3) the old tag on the JSON Patch answered %s and Ravi reads %s" % (p3, "unchanged" if r3 == r1 else "CHANGED"))
if p4 != "412": bad.append("(4) a weak form of the current tag answered %s" % p4)
if p5 != "200": bad.append("(5) a PATCH with no If-Match answered %s (it wrote unconditionally before)" % p5)
def md(p): return hashlib.md5(open(p, "rb").read()).hexdigest()
keep = []
for root in ("tiffinbox-web/src/main", "tiffinbox-core/src/main"):
    for d, ds, fs in os.walk(os.path.join(a, root)):
        for f in fs:
            r = os.path.relpath(os.path.join(d, f), a)
            if not r.endswith("CustomerPatches.java"): keep.append(r)
moved = [r for r in sorted(keep) if not os.path.exists(os.path.join(t, r)) or md(os.path.join(t, r)) != md(os.path.join(a, r))]
if moved: bad.append("(6) files other than CustomerPatches.java differ from ../after's: " + ", ".join(moved[:3]))
for b in bad: print("FAIL " + b)
print("PASS" if not bad else "check.sh: %d clause(s) failed" % len(bad))
sys.exit(1 if bad else 0)
PY
rm -rf "$RUN"
exit $rc
