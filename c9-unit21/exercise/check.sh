#!/bin/sh
# Course 9 unit 21's exercise, the check: sh check.sh TREE. PASS only if (1) the tree's client tests are green (mvn -o, the tree's own
# build), (2) the tree's PaymentCaller, called by the harness against Course 6's stub on $PORT (default 21108; a copy of ../harness/stub,
# byte for byte), sends ONE key on each of a payment's three attempts and a different key for a second payment (python reads the stub's
# dump), and (3) every other file of the tree is byte-equal to ../after's. No request goes to TiffinBox. MAVEN_REPO = the offline repository.
[ -n "$1" ] && [ -d "$1/tiffinbox-client" ] || { echo "usage: sh check.sh TREE"; exit 2; }
T=$(cd "$1" && pwd); X=$(cd "$(dirname "$0")" && pwd); A="$X/../after"; P=${PORT:-21108}; R=${MAVEN_REPO:-$HOME/.m2/repository}
W="$X/check.run"; rm -rf "$W"; mkdir -p "$W"; L="$X/check.build.log"; : > "$L"; fail=0
J="-Duser.language=en -Duser.country=US"
(cd "$T" && mvn -o -B -Dmaven.repo.local="$R" "-DargLine=$J" clean test -pl tiffinbox-client -am) >> "$L" 2>&1; mx=$?
red=$(grep -oE '^\[ERROR\]   PaymentRetryTest\.[A-Za-z0-9]+' "$L" | sed 's/.*\.//' | sort -u | tr '\n' ' ')
if [ $mx = 0 ]; then echo "(1) the tree's client tests: green ($(grep -oE 'Tests run: [0-9]+, Failures: 0, Errors: 0, Skipped: 0$' "$L" | tail -1))"
else echo "FAIL (1) the tree's client tests are red: ${red:-the build failed}"; fail=1; fi
(cd "$T" && mvn -o -B -Dmaven.repo.local="$R" dependency:build-classpath -pl tiffinbox-client -am -Dmdep.includeScope=test -Dmdep.outputFile="$W/cp.txt") >> "$L" 2>&1 || { echo "FAIL the class path could not be read"; exit 1; }
C="$T/tiffinbox-client/src/test/java/com/tiffinbox/client"
javac -nowarn -parameters -d "$W/hc" -cp "$(cat "$W/cp.txt")" "$C/Payments.java" "$C/PaymentCaller.java" "$X/../harness/src/probe21/Caller21.java" >> "$L" 2>&1 || { echo "FAIL the tree's caller does not compile"; exit 1; }
cp -R "$X/../harness/stub" "$W/stub"
(cd "$W/stub" && exec java $J Stub.java --port=$P --www=www > ../stub.out 2>&1) & sp=$!
i=0; until curl --noproxy '*' -s -o /dev/null --max-time 1 "http://127.0.0.1:$P/ready"; do i=$((i + 1)); [ $i -lt 150 ] || break; sleep 0.2; done
java $J -Dprobe21.stub=http://127.0.0.1:$P -Dprobe21.mode=retry -Dprobe21.wrap=lossy -Dprobe21.payments=2 -cp "$W/hc:$(cat "$W/cp.txt")" probe21.Caller21 --spring.http.clients.read-timeout=1s > "$W/caller.out" 2>&1
kill $sp 2> /dev/null; wait $sp 2> /dev/null
python3 -I - "$W/stub.out" <<'PY' || fail=1
import sys, re
t = open(sys.argv[1], encoding="utf-8").read().splitlines()
posts, keys, ids, cur = 0, [], [], None
for l in t:
    if l.startswith("STUB POST /payments "): posts += 1; keys.append(None)
    m = re.match(r"^STUB-H idempotency-key: (.*)$", l)
    if m and keys: keys[-1] = m.group(1)
ids = [l for l in t if l.startswith("STUB-ANSWER 201 ")]
a, b = keys[:3], keys[3:6]
print("(2) the stub (Course 6's, a stand-in that honours no key): POSTs %d · payment 1: %d attempts, %d distinct key(s) · payment 2: %d attempts, %d distinct key(s) · distinct across the two: %d · payments it made: %d" % (posts, len(a), len(set(a)), len(b), len(set(b)), len(set(keys)), len(ids)))
ok = posts == 6 and None not in keys and len(set(a)) == 1 and len(set(b)) == 1 and len(set(keys)) == 2
if not ok: print("FAIL (2) one payment's attempts must carry one key, and the two payments two keys"); sys.exit(1)
PY
python3 -I - "$T" "$A" <<'PY' || fail=1
import sys, os, hashlib
t, a = sys.argv[1], sys.argv[2]; edited = "tiffinbox-client/src/test/java/com/tiffinbox/client/PaymentCaller.java"; bad = []
def walk(r):
    out = {}
    for d, ds, fs in os.walk(r):
        ds[:] = [x for x in ds if x != "target"]
        for f in fs: p = os.path.join(d, f); out[os.path.relpath(p, r)] = hashlib.md5(open(p, "rb").read()).hexdigest()
    return out
T, A = walk(t), walk(a)
for k in sorted(set(T) | set(A)):
    if k != edited and T.get(k) != A.get(k): bad.append(k)
print("(3) the files other than PaymentCaller.java byte-equal to ../after's: %s" % ("yes" if not bad else "NO - " + ", ".join(bad[:3])))
sys.exit(1 if bad else 0)
PY
rm -rf "$W"
[ $fail = 0 ] && { echo "PASS"; exit 0; }
exit 1
