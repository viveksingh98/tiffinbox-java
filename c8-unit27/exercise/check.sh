# Course 8, unit 27's exercise check: the START's own outcome, read off TiffinBox's log (started, or the failure text); then, on a
# started TiffinBox, the list's key deleted in Redis (the start's own findAll() cached it), GET /customers twice with PostgreSQL's
# statements counted between markers in its own log, and the key read back in Redis - never the exit of a run. Solved: started,
# PostgreSQL 3 statements then 0, and Redis holds customers::SimpleKey [] (EXISTS 1). A "solution" that switches the dev cache to
# Caffeine starts, but Redis holds no list: it fails here. Run with bash exercise/check.sh EX DH (the exercise's folder, the socket).
E=${1:?name the exercise folder}; DH=${2:?name the docker socket}
r=$(cat "$E/run.log" 2> /dev/null)
if [ ! -f "$E/x/tiffinbox-web-1.0.0.jar" ]; then echo "check: the start: no jar was built · the reads: none · solved: no"; exit 0; fi
if ! printf '%s\n' "$r" | grep -q 'Started TiffinBoxServer in '; then
  m=$(printf '%s\n' "$r" | grep -m1 -oE "Parameter [0-9]+ of method [A-Za-z]+ in [A-Za-z.]+ required a bean of type '[A-Za-z.]+' that could not be found\.")
  echo "check: the start: failed - ${m:-no Started line} · the reads: none · solved: no"; exit 0; fi
d=$(docker -H "$DH" exec c8u27-ex-redis redis-cli DEL 'customers::SimpleKey []' | tr -d '\r')
n0=$(docker -H "$DH" logs c8u27-ex-pg 2>&1 | wc -l | tr -d ' ')
for i in 1 2; do
  docker -H "$DH" exec c8u27-ex-pg psql -U tiffinbox -d tiffinbox -qAt -c "select 'EXMARK-$i-begin'" > /dev/null
  curl -s --noproxy '*' -o /dev/null http://127.0.0.1:20666/customers
  docker -H "$DH" exec c8u27-ex-pg psql -U tiffinbox -d tiffinbox -qAt -c "select 'EXMARK-$i-end'" > /dev/null
done
k=$(docker -H "$DH" exec c8u27-ex-redis redis-cli EXISTS 'customers::SimpleKey []' | tr -d '\r')
docker -H "$DH" logs c8u27-ex-pg 2>&1 | sed -n "$((n0 + 1)),\$p" | python3 -I -c '
import re, sys
L = sys.stdin.read().splitlines(); d, k = sys.argv[1], sys.argv[2]; c = []
for i in (1, 2):
    on, n = False, 0
    for l in L:
        if "EXMARK-%d-begin" % i in l: on = True; continue
        if "EXMARK-%d-end" % i in l: break
        if on and re.search(r"LOG:\s+(statement|execute [^:]*):\s*\S", l): n += 1
    c.append(n)
ok = c == [3, 0] and k == "1"
print("check: the start: started · DEL customers::SimpleKey [] -> %s · GET /customers twice: PostgreSQL %d then %d statements · Redis EXISTS customers::SimpleKey [] -> %s · solved: %s" % (d, c[0], c[1], k, "yes" if ok else "no"))' "$d" "$k"
