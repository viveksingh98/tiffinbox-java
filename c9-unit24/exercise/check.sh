#!/bin/sh
# Course 9 unit 24's exercise, the check: sh check.sh TREE. Builds the tree's web jar offline (mvn -o -DskipTests clean package -pl
# tiffinbox-web -am), starts it on $PORT (default 21138; H2 in memory, its own folder and token) and asks: (1) GET /customers/Ravi must
# answer 410, application/problem+json, type tag:tiffinbox.example,2026:route-retired; (2) GET /api/v1/customers/Ravi must answer 200
# with the successor's 67 bytes as ../after answers them (md5 5394e0eb...); (3) the Link must name the successor for Ravi; (4) every
# file of the tree but TiffinBoxServer.java must be byte-equal to ../after's. MAVEN_REPO = the offline repository. It checks the handler,
# not the committed spec (OpenApiSpecTest is not run: -DskipTests).
[ -n "$1" ] && [ -d "$1/tiffinbox-web" ] || { echo "usage: sh check.sh TREE"; exit 2; }
T=$(cd "$1" && pwd); X=$(cd "$(dirname "$0")" && pwd); A="$X/../after"; P=${PORT:-21138}; R=${MAVEN_REPO:-$HOME/.m2/repository}
W="$X/check.run"; rm -rf "$W"; mkdir -p "$W/secrets/tiffinbox"; L="$X/check.build.log"; : > "$L"; fail=0
J="-Duser.language=en -Duser.country=US"
(cd "$T" && mvn -o -B -Dmaven.repo.local="$R" -DskipTests clean package -pl tiffinbox-web -am) >> "$L" 2>&1 || { echo "FAIL the tree does not build"; rm -rf "$W" "$L"; exit 1; }
(umask 077 && openssl rand -hex 16 > "$W/secrets/tiffinbox/shutdown-token")
(cd "$W" && exec java $J -jar "$T/tiffinbox-web/target/tiffinbox-web-1.0.0.jar" --tiffinbox.port=$P > jvm.log 2>&1) & jp=$!
i=0; until grep -q 'Started TiffinBox' "$W/jvm.log" 2> /dev/null; do kill -0 $jp 2> /dev/null || break; i=$((i + 1)); [ $i -lt 600 ] || break; sleep 0.1; done
python3 -I - "$P" <<'PY' || fail=1
import sys, json, hashlib, http.client
port = int(sys.argv[1]); bad = 0
def call(p):
    c = http.client.HTTPConnection("127.0.0.1", port, timeout=20); c.request("GET", p); r = c.getresponse(); b = r.read()
    h = {k.lower(): v for k, v in r.getheaders()}; c.close(); return r.status, h, b
st, h, b = call("/customers/Ravi")
try: j = json.loads(b)
except ValueError: j = {}
if not isinstance(j, dict): j = {}
ty = j.get("type", "none")
dates = " · Deprecation: <masked> Sunset: <masked>" if "deprecation" in h and "sunset" in h else ""
print("(1) GET /customers/Ravi -> %d · %s · type %s%s" % (st, h.get("content-type", "none"), ty.rsplit(":", 1)[-1] if ty != "none" else "none", dates))
if st == 200: print("FAIL (1) the retired route still answers 200"); bad = 1
elif st != 410: print("FAIL (1) the retired route answers %d, not 410 - an old client cannot tell gone from a typo" % st); bad = 1
elif h.get("content-type") != "application/problem+json" or ty != "tag:tiffinbox.example,2026:route-retired": print("FAIL (1) the 410 is not the problem type route-retired"); bad = 1
s2, h2, b2 = call("/api/v1/customers/Ravi")
same = hashlib.md5(b2).hexdigest() == "5394e0ebc1b6958ada589aa5314f5316"
print("(2) GET /api/v1/customers/Ravi -> %d · %d B · md5 equal to after's: %s" % (s2, len(b2), "yes" if same else "no"))
if s2 != 200 or not same: print("FAIL (2) the successor must answer as before"); bad = 1
lk = h.get("link", "none")
print("(3) Link: %s" % lk)
if lk != '</api/v1/customers/Ravi>; rel="successor-version"': print("FAIL (3) the Link must name the successor"); bad = 1
sys.exit(bad)
PY
if kill -0 $jp 2> /dev/null; then printf 'X-Shutdown-Token: %s\n' "$(head -1 "$W/secrets/tiffinbox/shutdown-token")" | curl --noproxy '*' -s -o /dev/null --max-time 5 -H @- -X POST "http://127.0.0.1:$P/shutdown"; fi
i=0; while kill -0 $jp 2> /dev/null; do i=$((i + 1)); [ $i = 100 ] && kill $jp 2> /dev/null; [ $i -lt 300 ] || break; sleep 0.05; done; wait $jp 2> /dev/null
python3 -I - "$T" "$A" <<'PY' || fail=1
import sys, os, hashlib
t, a = sys.argv[1], sys.argv[2]; edited = "tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java"; bad = []
def walk(r):
    out = {}
    for d, ds, fs in os.walk(r):
        ds[:] = [x for x in ds if x != "target"]
        for f in fs: p = os.path.join(d, f); out[os.path.relpath(p, r)] = hashlib.md5(open(p, "rb").read()).hexdigest()
    return out
T, A = walk(t), walk(a)
for k in sorted(set(T) | set(A)):
    if k != edited and T.get(k) != A.get(k): bad.append(k)
print("(4) the files other than TiffinBoxServer.java byte-equal to ../after's: %s" % ("yes" if not bad else "NO - " + ", ".join(bad[:3])))
sys.exit(1 if bad else 0)
PY
rm -rf "$W" "$L"
[ $fail = 0 ] && { echo "PASS"; exit 0; }
exit 1
