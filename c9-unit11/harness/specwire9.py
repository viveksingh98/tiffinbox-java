# BLUE C9-S2 instrument (draft for U07's harness): the spec against the wire, by script.
#   python3 -I specwire9.py send PORT OUTDIR      -> sends the filed request set to 127.0.0.1:PORT; files each request AND answer as OUTDIR/NN-name.json
#   python3 -I specwire9.py diff SPEC.json WIREDIR [GENDIR]
#        -> prints, row by row, where the spec and the wire part (and, with GENDIR, what the generated client can send); the last line is
#           "DISAGREEMENTS n"; exit 0 when n == 0, 1 otherwise, 2 on an empty/absent input. A planted difference must move n.
import http.client, json, os, re, sys

REQS = [  # name, method, path, spec path key, headers, body (None = no body)
    ("one", "GET", "/api/v1/customers/Ravi", "/api/v1/customers/{name}", {}, None),
    ("list", "GET", "/customers", "/customers", {}, None),
    ("post-ok", "POST", "/customers", "/customers", {"Content-Type": "application/json"},
     {"name": "Blue1", "mealsPerDay": 2, "pricePerMeal": 100, "mealType": "VEG"}),
    ("post-nomeals", "POST", "/customers", "/customers", {"Content-Type": "application/json"},
     {"name": "Blue2", "pricePerMeal": 100, "mealType": "VEG"}),
    ("post-noprice", "POST", "/customers", "/customers", {"Content-Type": "application/json"},
     {"name": "Blue3", "mealsPerDay": 2, "mealType": "VEG"}),
    ("post-notype", "POST", "/customers", "/customers", {"Content-Type": "application/json"},
     {"name": "Blue4", "mealsPerDay": 2, "pricePerMeal": 100}),
    ("post-noname", "POST", "/customers", "/customers", {"Content-Type": "application/json"},
     {"mealsPerDay": 2, "pricePerMeal": 100, "mealType": "VEG"}),
    ("post-blank", "POST", "/customers", "/customers", {"Content-Type": "application/json"},
     {"name": "", "mealsPerDay": 2, "pricePerMeal": 100, "mealType": "VEG"}),
    ("pause-nokey", "POST", "/api/v1/customers/Ravi/pauses?days=2", "/api/v1/customers/{name}/pauses", {}, None),
    ("pause-key", "POST", "/api/v1/customers/Ravi/pauses?days=2", "/api/v1/customers/{name}/pauses", {"Idempotency-Key": '"blue-specwire-1"'}, None),
    ("patch-json-patch", "PATCH", "/api/v1/customers/Ravi", "/api/v1/customers/{name}", {"Content-Type": "application/json-patch+json"},
     [{"op": "replace", "path": "/mealsPerDay", "value": 2}]),
    ("feed", "GET", "/customers/feed", "/customers/feed", {"Accept": "text/event-stream"}, None),
]

def send(port, out):
    os.makedirs(out, exist_ok=True)
    for i, (name, m, path, key, h, body) in enumerate(REQS, 1):
        c = http.client.HTTPConnection("127.0.0.1", int(port), timeout=3)
        tag = os.environ.get("BLUE_RUN", "1")
        if isinstance(body, dict) and body.get("name", "").startswith("Blue"): body = dict(body, name=body["name"] + "r" + tag)
        h = {k: (v.replace("-1\"", "-%s\"" % tag) if k == "Idempotency-Key" else v) for k, v in h.items()}
        raw = None if body is None else json.dumps(body).encode()
        c.request(m, path, body=raw, headers=h)
        r = c.getresponse()
        try: data = r.read1(4096) if name == "feed" else r.read()
        except Exception as ex: data = ("(read: %s)" % type(ex).__name__).encode()
        rec = {"name": name, "request": {"method": m, "path": path, "spec_path": key, "headers": h, "body": body},
               "response": {"status": r.status, "content_type": r.getheader("Content-Type"), "body": data.decode("utf-8", "replace")[:2000]}}
        c.close()
        json.dump(rec, open(os.path.join(out, "%02d-%s.json" % (i, name)), "w"), indent=1, sort_keys=True)
        print("%-18s %s %s -> %s %s" % (name, m, path, r.status, r.getheader("Content-Type")))

def diff(spec_p, wire_d, gen_d=None):
    if not os.path.isfile(spec_p) or not os.path.isdir(wire_d): print("refused: no spec or no wire dir"); sys.exit(2)
    spec = json.load(open(spec_p))
    wire = [json.load(open(os.path.join(wire_d, f))) for f in sorted(os.listdir(wire_d)) if f.endswith(".json")]
    if not spec.get("paths") or not wire: print("refused: empty spec or empty wire dir"); sys.exit(2)
    W = {w["name"]: w for w in wire}
    rows = []
    def row(k, spec_says, wire_says): rows.append((k, spec_says, wire_says))
    cust = spec["components"]["schemas"]["Customer"]
    props, req = sorted(cust.get("properties", {})), sorted(cust.get("required", []))
    # 1 names: the spec's property list against the wire's keys on the public read
    wk = sorted(json.loads(W["one"]["response"]["body"]).keys())
    print("names   spec %s | wire %s" % (props, wk))
    if props != wk: row("property names", props, wk)
    # 2 required: a property is wire-required when the POST that omits it answers 4xx
    omit = {"mealsPerDay": "post-nomeals", "pricePerMeal": "post-noprice", "mealType": "post-notype", "name": "post-noname"}
    wreq = sorted(p for p, n in omit.items() if n in W and 400 <= W[n]["response"]["status"] < 500)
    print("required spec %s | wire %s (omitted -> %s)" % (req, wreq, {p: W[n]["response"]["status"] for p, n in omit.items() if n in W}))
    if req != wreq: row("required", req, wreq)
    # 3 name minLength vs the wire's answer to ""
    ml = cust["properties"]["name"].get("minLength")
    bl = W["post-blank"]["response"]["status"]
    print("name ''  spec minLength %s | wire %s" % (ml, bl))
    if (ml in (None, 0)) and bl >= 400: row("name minLength", ml, bl)
    # 4 per request: the documented success codes/media types against the wire's status and Content-Type
    nerr_spec = 0
    for p, ops in spec["paths"].items():
        for m, o in ops.items():
            nerr_spec += sum(1 for c in o["responses"] if not c.startswith("2"))
    for w in wire:
        rq, rs = w["request"], w["response"]
        o = spec["paths"].get(rq["spec_path"], {}).get(rq["method"].lower())
        if o is None: row("operation", "absent", "%s %s" % (rq["method"], rq["spec_path"])); continue
        codes = o["responses"]; st = str(rs["status"])
        ct = (rs["content_type"] or "").split(";")[0]
        doc = codes.get(st)
        media = sorted(doc.get("content", {}).keys()) if doc else None
        print("%-16s %s %-36s spec %s | wire %s %s" % (w["name"], rq["method"], rq["spec_path"], {k: sorted(v.get("content", {})) for k, v in codes.items()}, st, ct))
        if doc is None: row("%s status" % w["name"], sorted(codes), st)
        elif media and ct not in media and "*/*" not in media: row("%s media" % w["name"], media, ct)
        elif media == ["*/*"] and ct: row("%s media" % w["name"], media, ct)
        # header parameters the wire demanded (a 400 whose type names a missing header) and the spec does not name
        if rs["status"] == 400 and "missing" in rs["body"]:
            hdrs = [x["name"] for x in o.get("parameters", []) if x["in"] == "header"]
            m2 = re.search(r'requires an? ([A-Za-z-]+) header', rs["body"])
            if m2 and m2.group(1) not in hdrs: row("%s header" % w["name"], "header params %s" % hdrs, "requires %s" % m2.group(1))
    # 5 errors documented vs answered
    werr = sorted({w["response"]["status"] for w in wire if w["response"]["status"] >= 400})
    print("errors  spec non-2xx responses %d | wire 4xx statuses seen %s" % (nerr_spec, werr))
    if nerr_spec == 0 and werr: row("error responses", 0, werr)
    # 6 the feed's schema vs the wire's first event
    fo = spec["paths"]["/customers/feed"]["get"]["responses"]["200"]["content"]
    fs = list(fo.values())[0]["schema"].get("$ref", "")
    fb = W["feed"]["response"]["body"].splitlines()[:3]
    print("feed    spec schema %s %s | wire %s" % (fs, json.dumps(spec["components"]["schemas"].get(fs.split("/")[-1], {})), fb))
    if fs.endswith("/SseEmitter"): row("feed schema", fs, "events: " + (fb[0] if fb else "(none in the read)"))
    # 7 the generated client: which request media types it can send
    if gen_d:
        src = "".join(open(os.path.join(d, f)).read() for d, _, fs_ in os.walk(gen_d) for f in fs_ if f.endswith(".java"))
        smt = sorted({mt for ops in spec["paths"].values() for o in ops.values() for mt in o.get("requestBody", {}).get("content", {})})
        for mt in smt:
            n = src.count(mt)
            print("gen     request media type %-32s in generated source x%d" % (mt, n))
            if n == 0: row("generated client cannot send", mt, "not sendable (0 in the source)")
        hk = src.count("Idempotency-Key")
        print("gen     Idempotency-Key in generated source x%d" % hk)
    print("-- where they part --")
    for i, (k, a, b) in enumerate(rows, 1): print("%2d %-24s spec: %s | wire: %s" % (i, k, a, b))
    def kind(k):
        for suf, name in ((" status", "success/error status"), (" media", "response media type"), (" header", "required header")):
            if k.endswith(suf): return name
        return k
    kinds = sorted({kind(k) for k, _, _ in rows})
    print("KINDS %d: %s" % (len(kinds), "; ".join(kinds)))
    print("DISAGREEMENTS %d" % len(rows))
    sys.exit(0 if not rows else 1)

if __name__ == "__main__":
    if len(sys.argv) < 4: print("usage: specwire9.py send PORT OUTDIR | diff SPEC WIREDIR [GENDIR]"); sys.exit(2)
    if sys.argv[1] == "send": send(sys.argv[2], sys.argv[3])
    else: diff(sys.argv[2], sys.argv[3], sys.argv[4] if len(sys.argv) > 4 else None)
