#!/usr/bin/env python3
# BLUE C9-U22: the record cure against Mallory's body. argv: port [psqlcmd...]
import sys, json, http.client, subprocess
port = int(sys.argv[1]); psql = sys.argv[2:]
def call(m, p, body=None):
    c = http.client.HTTPConnection("127.0.0.1", port, timeout=20)
    c.request(m, p, body=None if body is None else json.dumps(body), headers={"Content-Type": "application/json"} if body is not None else {})
    r = c.getresponse(); b = r.read().decode(); c.close(); return r.status, b
def rows():
    s, b = call("GET", "/probe/v1/recrows"); return json.loads(b)
def fmt(rs): return " ".join("%s|%s|%s|%s|%s|v%s" % (r["id"], r["name"], r["meals"], r["price"], r["mealType"], r["version"]) for r in rs)
def pg():
    if not psql: return None
    o = subprocess.run(psql + ["select id, name, meals_per_day, price_per_meal, meal_type, version from customer order by id"], capture_output=True, text=True).stdout
    return " ".join("%s|%s|%s|%s|%s|v%s" % tuple(l.split("|")) for l in o.split() if l)
def show(lab):
    f = fmt(rows()); print("  rows | %s | companion read: %s" % (lab, f)); p = pg()
    if p is not None: print("  rows | %s | psql: %s | %s" % (lab, p, "EQUAL to the companion read" if p == f else "DIFFER"))
r0 = rows(); I = {r["name"]: r for r in r0}; ravi = I["Ravi"]
show("start")
def case(lab, route, body, who="Sunil"):
    st, b = call("PUT", "/probe/v1/customers/%s/%s" % (who, route), body)
    try: j = json.loads(b); j.pop("timestamp", None); bb = json.dumps(j, sort_keys=True)
    except Exception: bb = b[:120]
    print("  case | %s | PUT /probe/v1/customers/%s/%s <- %s -> %s %s" % (lab, who, route, json.dumps(body, sort_keys=True), st, bb))
    show(lab)
    print("  read | %s | GET /api/v1/customers/Ravi -> %s · GET /api/v1/customers/Mallory -> %s" % (lab, call("GET", "/api/v1/customers/Ravi")[0], call("GET", "/api/v1/customers/Mallory")[0]))
case("R1 record route, Mallory's body", "record", {"id": ravi["id"], "name": "Mallory"})
case("R2 record route, Mallory's body made whole", "record", {"id": ravi["id"], "version": ravi["version"], "name": "Mallory", "mealsPerDay": 2, "pricePerMeal": 100, "mealType": "VEG"})
case("R3 record route, Meera <- Priya's id at an equal version", "record", {"id": I["Priya"]["id"], "version": I["Priya"]["version"], "name": "Eve", "mealsPerDay": 3, "pricePerMeal": 100, "mealType": "VEG"}, "Meera")
case("C1 control: the held entity route, Priya <- Ravi's id, both at v0 (the attack on this JVM)", "bind", {"id": ravi["id"], "name": "Mallory"}, "Priya")
