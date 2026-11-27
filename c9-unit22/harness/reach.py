#!/usr/bin/env python3
# reach: one extra-member request per body-reading route (and its clean twin), on one TiffinBox JVM; prints
# request · status · Content-Type · masked body md5 · detail. argv: port
import sys, json, re, hashlib, http.client, uuid
port = int(sys.argv[1])
KEYH = "Idempotency-Key"
def mask(s):
    s = re.sub(r'"timestamp":"[^"]*"', '"timestamp":"<t>"', s)
    s = re.sub(r'"(createdAt|updatedAt)":"[^"]*"', r'"\1":"<t>"', s)
    s = re.sub(r"(127\.0\.0\.1|localhost):\d{4,5}", r"\1:<port>", s)
    s = re.sub(r"[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}", "<uuid>", s)
    s = re.sub(r"/pauses/\d+", "/pauses/<id>", s); s = re.sub(r'"id":\d+', '"id":<n>', s)
    return s
def req(label, method, path, body=None, ctype=None, headers=None):
    h = dict(headers or {})
    if ctype: h["Content-Type"] = ctype
    data = None if body is None else (body if isinstance(body, (bytes, str)) else json.dumps(body))
    c = http.client.HTTPConnection("127.0.0.1", port, timeout=10); c.request(method, path, body=data, headers=h)
    r = c.getresponse(); b = r.read().decode("utf-8", "replace"); hd = {k.lower(): v for k, v in r.getheaders()}; c.close()
    det = ""
    try:
        j = json.loads(b)
        if isinstance(j, dict):
            det = j.get("detail") or ""
            if not det and r.status >= 400: det = json.dumps({k: v for k, v in j.items() if k != "timestamp"}, sort_keys=True)
    except Exception:
        pass
    m = mask(b)
    print("  reach | %-58s -> %s %s · body %s · detail %s" % (label, r.status, hd.get("content-type"), hashlib.md5(m.encode()).hexdigest()[:12], det if det else "-"))
    return r.status, b, hd
CJ = "application/json"; MP = "application/merge-patch+json"; JP = "application/json-patch+json"
rec = lambda n: {"name": n, "mealsPerDay": 1, "pricePerMeal": 110, "mealType": "VEG"}
req("POST /customers clean (Asha)", "POST", "/customers", rec("Asha"), CJ)
req("POST /customers +loyaltyPoints:5 (Lata; Course 6's)", "POST", "/customers", dict(rec("Lata"), loyaltyPoints=5), CJ)
req("POST /customers +version:99,admin,createdAt (Mohan; hook)", "POST", "/customers", dict(rec("Mohan"), version=99, admin=True, createdAt="2001-01-01T00:00:00Z"), CJ)
b = rec("Neha"); del b["mealType"]; b["mealTyp"] = "VEG"
req("POST /customers misspelt mealTyp (Neha; Course 6's typo)", "POST", "/customers", b, CJ)
req("POST /customers +id:1 (Om)", "POST", "/customers", dict(rec("Om"), id=1), CJ)
for n in ("Asha", "Lata", "Mohan", "Neha", "Om"):
    req("GET /customers/%s (read back)" % n, "GET", "/customers/" + n)
req("PATCH merge Ravi {pricePerMeal:121} clean", "PATCH", "/api/v1/customers/Ravi", {"pricePerMeal": 121}, MP)
req("PATCH merge Priya {version:99}", "PATCH", "/api/v1/customers/Priya", {"version": 99}, MP)
req("PATCH merge Meera {admin:true}", "PATCH", "/api/v1/customers/Meera", {"admin": True}, MP)
req("PATCH merge Sunil {loyaltyPoints:5}", "PATCH", "/api/v1/customers/Sunil", {"loyaltyPoints": 5}, MP)
req("PATCH json-patch Ravi add /version 99", "PATCH", "/api/v1/customers/Ravi", [{"op": "add", "path": "/version", "value": 99}], JP)
req("PATCH json-patch Ravi replace /pricePerMeal 122 clean", "PATCH", "/api/v1/customers/Ravi", [{"op": "replace", "path": "/pricePerMeal", "value": 122}], JP)
for n in ("Ravi", "Priya", "Meera", "Sunil"):
    req("GET /api/v1/customers/%s (read back)" % n, "GET", "/api/v1/customers/" + n)
req("POST /customers form +admin=true (Bina)", "POST", "/customers", "name=Bina&mealsPerDay=2&pricePerMeal=100&mealType=VEGAN&admin=true", "application/x-www-form-urlencoded", {"Accept": "text/html"})
k = str(uuid.UUID(int=22))
s1, b1, h1 = req("POST /api/v1/customers/Ravi/pauses?days=2 keyed (1st)", "POST", "/api/v1/customers/Ravi/pauses?days=2", None, None, {KEYH: '"%s"' % k})
s2, b2, h2 = req("POST /api/v1/customers/Ravi/pauses?days=2 keyed (2nd, same key)", "POST", "/api/v1/customers/Ravi/pauses?days=2", None, None, {KEYH: '"%s"' % k})
print("  reach | keyed replay: second answer %s the first (status %s/%s, body %s, Location %s)" % ("EQUALS" if (s1, b1) == (s2, b2) else "DIFFERS FROM", s1, s2, "same" if b1 == b2 else "differs", "same" if h1.get("location") == h2.get("location") else "differs"))
req("POST /api/v1/billing-runs with a JSON body {x:1} (reads none)", "POST", "/api/v1/billing-runs", {"x": 1}, CJ)
