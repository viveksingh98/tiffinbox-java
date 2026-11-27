#!/usr/bin/env python3
# bind: the harness's entity-bound route (Course 9 unit 22; the held ev22 run's bind.py with R.567's two prints added), BLUE B2's cases + one body per getter-visible member + an unknown member
# + the createdAt control on a POST-created customer (C3). Each outcome classified into R.551's four words from the companion
# read (rows before / after), or printed as it answered. argv: port members(comma list, derived from javap) [psqlcmd...]
import sys, json, http.client, subprocess
port = int(sys.argv[1]); members = sys.argv[2].split(","); psql = sys.argv[3:]
def call(method, path, body=None, ctype="application/json"):
    c = http.client.HTTPConnection("127.0.0.1", port, timeout=20)
    c.request(method, path, body=None if body is None else (body if isinstance(body, str) else json.dumps(body)), headers={"Content-Type": ctype} if body is not None else {})
    r = c.getresponse(); b = r.read().decode(); c.close(); return r.status, b
def rows():
    s, b = call("GET", "/probe/v1/rows"); return {r["id"]: r for r in json.loads(b)}
def fmt(rs): return " ".join("%s|%s|%s|%s|%s|v%s" % (r["id"], r["name"], r["meals"], r["price"], r["mealType"], r["version"]) for r in rs.values())
def pg():
    if not psql: return None
    o = subprocess.run(psql + ["select id, name, meals_per_day, price_per_meal, meal_type, version from customer order by id"], capture_output=True, text=True).stdout
    return " ".join("%s|%s|%s|%s|%s|v%s" % tuple(l.split("|")) for l in o.split() if l)
def ids(rs): return {r["name"]: r["id"] for r in rs.values()}
def classify(sent, target, b4, af, st):
    out = []
    tid = ids(b4)[target]
    changed = [i for i in af if i in b4 and af[i] != b4[i]]
    other = [i for i in changed if i != tid]
    for k, v in sent.items():
        if st != 200: w = "refused (%s)" % st
        elif other: w = "another row overwritten (row %s)" % ",".join(map(str, other))
        else:
            col = {"name": "name", "mealsPerDay": "meals", "pricePerMeal": "price", "mealType": "mealType", "version": "version", "createdAt": "createdAt"}.get(k)
            if col is None: w = "not written (no column read back)" if k != "id" else "not written"
            elif k == "version" and str(v) == str(b4[tid]["version"]): w = "equal to the row's version: accepted (the save then incremented it to v%s)" % af[tid]["version"]
            elif str(af[tid][col]) == str(v): w = "written"
            elif af[tid][col] != b4[tid][col]: w = "not one of R.551's four: %s %s -> %s" % (col, b4[tid][col], af[tid][col])
            else: w = "not written"
        out.append("%s=%s" % (k, w))
    return "; ".join(out)
def case(label, target, body):
    b4 = rows(); vb = b4[ids(b4)[target]]["version"]
    st, resp = call("PUT", "/probe/v1/customers/%s/bind" % target, body)
    af = rows()
    sa, _ = call("GET", "/api/v1/customers/" + target)
    sid = body.get("id"); sv = ("the sent id's row (row %s, %s) at v%s" % (sid, b4[sid]["name"], b4[sid]["version"])) if sid in b4 else "no id sent"
    lab409 = " (the harness's route answers 409 for any exception)" if st == 409 else ""
    print("  case | %s | %s <- %s | the URL's row (row %s) at v%s · %s | -> %s%s %s" % (label, target, json.dumps(body, sort_keys=True), ids(b4)[target], vb, sv, st, lab409, json.dumps(json.loads(resp), sort_keys=True) if st != 200 and resp else ""))
    print("  case | %s | outcome: %s | GET /api/v1/customers/%s -> %s" % (label, classify(body, target, b4, af, st), target, sa))
    print("  rows | %s | companion read: %s" % (label, fmt(af)))
    p = pg()
    if p is not None: print("  rows | %s | psql: %s | %s" % (label, p, "EQUAL to the companion read" if p == fmt(af) else "DIFFER"))
r0 = rows(); I = ids(r0); print("  rows | start | %s" % fmt(r0))
print("  members | the entity's getters (javap): %s" % ",".join(members))
# B2's failure receipt first: Sunil's body with Ravi's (existing) id
case("1 existing id", "Sunil", {"id": I["Ravi"], "name": "Mallory"})
print("  read | GET /api/v1/customers/Ravi -> %s · GET /api/v1/customers/Mallory -> %s" % (call("GET", "/api/v1/customers/Ravi")[0], call("GET", "/api/v1/customers/Mallory")[0]))
st, _ = call("PATCH", "/api/v1/customers/Priya", {"mealsPerDay": 2}, "application/merge-patch+json"); print("  read | merge patch Priya {mealsPerDay:2} -> %s (bumps Priya's version)" % st)
case("2 existing id, row at a later version", "Meera", {"id": I["Priya"], "name": "Eve"})
case("2b existing id + that row's version", "Meera", {"id": I["Priya"], "version": 1, "name": "Eve"})
print("  read | GET /api/v1/customers/Priya -> %s (the customer cache) · GET /api/v1/customers/Eve -> %s" % (call("GET", "/api/v1/customers/Priya")[0], call("GET", "/api/v1/customers/Eve")[0]))
case("3 version equal", "Sunil", {"version": 0, "pricePerMeal": 1})
case("3b version differing", "Sunil", {"version": 7})
# one body per getter-visible member (D6), on Meera (her own row)
val = {"name": "Zed", "mealsPerDay": 3, "pricePerMeal": 155, "mealType": "VEGAN", "pauses": [], "updatedAt": "2001-01-01T00:00:00Z"}
for m in members:
    if m in val: case("member " + m, "Meera" if m != "name" else "Meera", {m: val[m]}) if m != "name" else None
case("member name", "Meera", {"name": "Zed"})
case("unknown member admin", "Zed", {"admin": True})
# C3: the createdAt control on a POST-created customer
st, _ = call("POST", "/customers", {"name": "Chitra", "mealsPerDay": 1, "pricePerMeal": 130, "mealType": "VEGAN"}); r1 = rows(); cid = ids(r1)["Chitra"]
print("  c3 | POST /customers Chitra -> %s · createdAt read back %s" % (st, "non-null" if r1[cid]["createdAt"] != "None" else "null"))
c_before = r1[cid]["createdAt"]
case("C3 createdAt (POST-created row)", "Chitra", {"createdAt": "2001-01-01T00:00:00Z"})
r2 = rows(); print("  c3 | createdAt after: %s (sent 2001-01-01T00:00:00Z)" % ("UNCHANGED" if r2[cid]["createdAt"] == c_before else "CHANGED"))
print("  c3 | seeded rows' createdAt: %s" % ",".join(sorted({r["createdAt"] for i, r in r2.items() if i != cid})))
