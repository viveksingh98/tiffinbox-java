#!/bin/sh
# Course 9 unit 22's exercise, the check: sh check.sh TREE. Builds the tree's web jar offline (mvn -o -DskipTests package -pl
# tiffinbox-web -am), starts it on $PORT (default 21168; H2 in memory, its own folder and token) and sends PUT /exercise/customers/{name}:
# (1) Sunil's row <- Ravi's id and version, (2) Meera's row <- Priya's id and version - each time the other customer's row is read
# back (GET /api/v1/customers/<name>, never read before, so no cache answers) and must be unchanged, and no "Mallory" or "Eve" exists;
# (3) a whole body with no id to Sunil must still be written (Sunil reads back 2 meals). (4) every other file of the tree is byte-equal
# to ../after's. MAVEN_REPO = the offline repository.
[ -n "$1" ] && [ -d "$1/tiffinbox-web" ] || { echo "usage: sh check.sh TREE"; exit 2; }
T=$(cd "$1" && pwd); X=$(cd "$(dirname "$0")" && pwd); A="$X/../after"; P=${PORT:-21168}; R=${MAVEN_REPO:-$HOME/.m2/repository}
W="$X/check.run"; rm -rf "$W"; mkdir -p "$W/secrets/tiffinbox"; L="$X/check.build.log"; : > "$L"; fail=0
J="-Duser.language=en -Duser.country=US"
(cd "$T" && mvn -o -B -Dmaven.repo.local="$R" -DskipTests clean package -pl tiffinbox-web -am) >> "$L" 2>&1 || { echo "FAIL the tree does not build"; rm -rf "$W"; exit 1; }
(umask 077 && openssl rand -hex 16 > "$W/secrets/tiffinbox/shutdown-token")
(cd "$W" && exec java $J -jar "$T/tiffinbox-web/target/tiffinbox-web-1.0.0.jar" --tiffinbox.port=$P > jvm.log 2>&1) & jp=$!
i=0; until grep -q 'Started TiffinBox' "$W/jvm.log" 2> /dev/null; do kill -0 $jp 2> /dev/null || break; i=$((i + 1)); [ $i -lt 600 ] || break; sleep 0.1; done
python3 -I - "$P" <<'PY' || fail=1
import sys, json, http.client
port = int(sys.argv[1]); bad = 0
def call(m, p, body=None):
    c = http.client.HTTPConnection("127.0.0.1", port, timeout=20)
    c.request(m, p, body=None if body is None else json.dumps(body), headers={"Content-Type": "application/json"} if body is not None else {})
    r = c.getresponse(); b = r.read().decode("utf-8", "replace"); c.close(); return r.status, b
def row(n):
    s, b = call("GET", "/api/v1/customers/" + n)
    if s != 200: return "%s %s" % (n, s)
    j = json.loads(b); return "%s %s %s %s" % (j["name"], j["mealsPerDay"], j["pricePerMeal"], j["mealType"])
for k, (target, victim, vid, fake, whole, want) in enumerate([
        ("Sunil", "Ravi", 1, "Mallory", (3, 100, "VEG"), "Ravi 2 120 VEG"),
        ("Meera", "Priya", 4, "Eve", (1, 150, "NON_VEG"), "Priya 1 120 VEGAN")], 1):
    body = {"id": vid, "version": 0, "name": fake, "mealsPerDay": whole[0], "pricePerMeal": whole[1], "mealType": whole[2]}
    st, _ = call("PUT", "/exercise/customers/" + target, body)
    got, other = row(victim), row(fake)
    print("(%d) PUT /exercise/customers/%s <- %s's id %d at version 0 -> %s · %s reads back: %s · %s: %s" % (k, target, victim, vid, st, victim, got, fake, other))
    if got != want or other != "%s 404" % fake:
        print("FAIL (%d) another customer's id reached %s's row" % (k, victim)); bad = 1
st, _ = call("PUT", "/exercise/customers/Sunil", {"name": "Sunil", "mealsPerDay": 2, "pricePerMeal": 100, "mealType": "VEG"})
got = row("Sunil")
print("(3) PUT /exercise/customers/Sunil <- a whole body, no id -> %s · Sunil reads back: %s" % (st, got))
if st != 200 or got != "Sunil 2 100 VEG": print("FAIL (3) the route must still write the row its URL names"); bad = 1
sys.exit(bad)
PY
if kill -0 $jp 2> /dev/null; then printf 'X-Shutdown-Token: %s\n' "$(head -1 "$W/secrets/tiffinbox/shutdown-token")" | curl --noproxy '*' -s -o /dev/null --max-time 5 -H @- -X POST "http://127.0.0.1:$P/shutdown"; fi
i=0; while kill -0 $jp 2> /dev/null; do i=$((i + 1)); [ $i = 100 ] && kill $jp 2> /dev/null; [ $i -lt 300 ] || break; sleep 0.05; done; wait $jp 2> /dev/null
python3 -I - "$T" "$A" <<'PY' || fail=1
import sys, os, hashlib
t, a = sys.argv[1], sys.argv[2]; edited = "tiffinbox-web/src/main/java/com/tiffinbox/web/CustomerOverwrite.java"; bad = []
def walk(r):
    out = {}
    for d, ds, fs in os.walk(r):
        ds[:] = [x for x in ds if x != "target"]
        for f in fs: p = os.path.join(d, f); out[os.path.relpath(p, r)] = hashlib.md5(open(p, "rb").read()).hexdigest()
    return out
T, A = walk(t), walk(a)
for k in sorted(set(T) | set(A)):
    if k != edited and T.get(k) != A.get(k): bad.append(k)
print("(4) the files other than CustomerOverwrite.java byte-equal to ../after's: %s" % ("yes" if not bad else "NO - " + ", ".join(bad[:3])))
sys.exit(1 if bad else 0)
PY
rm -rf "$W"
[ $fail = 0 ] && { echo "PASS"; exit 0; }
exit 1
