# Course 8, unit 26's exercise check: the START's own outcome, read off TiffinBox's log (started, or the failure text), AND the route's
# own answer - GET /revenue/by-customer's four totals and their sum beside /kitchen's ordersValue, read off what curl saved - never the
# exit of a run. Solved: TiffinBox started, the route answered Sunil 9000, Ravi 7200, Meera 4500, Priya 3600, and their sum equals
# /kitchen's ordersValue, 24300. A "solution" that deletes the fragment's method builds no jar, and fails here. Run with
# bash exercise/check.sh EX (the exercise's folder: its build.log, run.log and route.txt).
E=${1:?name the exercise folder}
python3 -I - "$E" <<'PY'
import json, os, re, sys
e = sys.argv[1]
def rd(n):
    p = os.path.join(e, n)
    return open(p, encoding="utf-8", errors="replace").read() if os.path.exists(p) else ""
b, r, t = rd("build.log"), rd("run.log"), rd("route.txt").splitlines()
jar = os.path.exists(os.path.join(e, "x", "tiffinbox-web-1.0.0.jar"))
if not jar:
    m = re.search(r"\[ERROR\] .*/([A-Za-z]+\.java):\[\d+,\d+\] (.*)", b)
    start = "no jar was built (" + (m.group(1) + ": " + m.group(2) if m else "the build failed") + ")"
elif re.search(r"Started TiffinBoxServer in ", r): start = "started"
else:
    m = re.search(r"No property '\w+' found for type '\w+'", r)
    start = "failed - " + (m.group(0) if m else "no Started line")
tot, kv = None, None
try: tot = [(x["customer"], x["total"]) for x in json.loads(t[0])]
except Exception: pass
try: kv = json.loads(t[1])["ordersValue"]
except Exception: pass
want = [("Sunil", 9000), ("Ravi", 7200), ("Meera", 4500), ("Priya", 3600)]
route = "none" if tot is None else ", ".join("%s %s" % x for x in tot) + " · their sum %d · /kitchen's ordersValue %s" % (sum(v for _, v in tot), kv)
ok = start == "started" and tot == want and sum(v for _, v in tot) == kv == 24300
print("check: the start: %s · the route: %s · solved: %s" % (start, route, "yes" if ok else "no"))
PY
