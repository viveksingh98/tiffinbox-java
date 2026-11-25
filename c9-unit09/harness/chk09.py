"""Course 9 unit 09's checker (python3 -I -B harness/chk09.py MODE ...). Every number the README may say is re-derived here from a capture's
own lines, a saved document or a shipped file, never typed. Each listing line a check reads is parsed by a named pattern or skipped by a
named rule; a line it cannot parse is a FAIL line and exit 1, never a traceback. The request-block reader and the small readers are U08's
(chk08.py - copied from U08's harness, c9-unit08/harness); the document checks (none, blanket, perop, shape, types, scheme) are this unit's.
chk08.py's browser subcommands (cdpev, netread, plantev, plantnet, detector, dom, assets, opid, media, statusword, bare, names, scfg) and
its page captures (redirect, tryitpg, sealed, ops, tryit, versions, info) are left out: no browser in this unit.
Modes:
  static AFTER BEFORE      the carried prose slice, XFAM_S9S1's md5, the change's files (the derived list), the guards (i')-(v), the
                           committed file's additions-only proof, the @ResponseStatus grep file by file, the stale sentences (R.250/R.453)
  hook | exq | gloss-line  print the spoken lines (typed ONCE, here; asserted against the brief's bytes by spoken)
  gloss README             the one new gloss line (A problem type), U06's and U08's still byte-equal, none re-glossed
  spoken HOOK EXQ          the spoken lines: byte-equal to S2B's Unit 09 Hook and Exercise lines, words, digits, spellings, statuses, dur9
  docsum FILE              one served document: its facts and every operation's response codes
  nameset FILE | keyset F  flag 3's part (1) (the {name} operations) and part (2) (the filter's GUARDED table)
  strip BEFORE AFTER       flag 9: the two documents with info, servers, the added responses and ProblemDetail removed, hashed and compared
  examples FILE BODIES     flag 6: every documented example against the filed wire bodies (BODIES = a folder of NAME.json)
  schema FILE BODIES       flag 5: the ProblemDetail schema's members beside each filed wire body's keys, the disagreements by kind
  count404 FILE            the blanket plant: the operations documenting a four-oh-four
  <capture> FILE           one capture's checks; prints ok/FAIL lines and one VALUES line
  hashable NAME FILE       the capture with its load- and run-dependent lines dropped, for receipts.md5
  values README VALS       README.md's values block = this run's VALUES lines"""
import collections, hashlib, io, json, os, re, sys, zipfile

OK, BAD, VAL = [], [], []
def ok(m): OK.append(m); print("ok " + m)
def fail(m): BAD.append(m); print("FAIL " + m)
def need(cond, m): ok(m) if cond else fail(m)
def val(k, v): VAL.append("%s=%s" % (k, v))
def done():
    print("VALUES " + " ".join(VAL))
    sys.exit(1 if BAD else 0)

HERE = os.path.dirname(os.path.abspath(__file__))
UNIT = os.path.dirname(HERE)
C9R = os.environ.get("C9R", os.path.join(UNIT, "..", "..", "..", "rest-apis-done-right"))
S2B = os.path.join(C9R, "_briefs", "UNIT-BRIEFS-S2-CONTRACTS.md")
J9 = os.path.join(os.path.expanduser("~"), "Desktop", "PromptVidya-Automation", "java9_series.py")
CU9 = os.path.join(os.path.expanduser("~"), "Desktop", "PromptVidya-Automation", "check_unit9.py")
HOOK = "One line on TiffinBox's error advice, and spring doc promises a four oh four on every documented route, the revenue included."
EXQ = "Your turn: document the four oh four on the public read only, and nowhere else."
GLOSS = "A problem type: the U-R-I that names an error's kind."
BRIEFQ = "the URI that names an error's kind"
U06GLOSS = "A contract: what a route promises its callers: the path, the method, the shapes in and out."
U08GLOSS = "Swagger UI: a page drawn from the document."
TYPE = "tag:tiffinbox.example,2026:customer-not-found"
KEYT = {"missing": "tag:tiffinbox.example,2026:idempotency-key-missing", "malformed": "tag:tiffinbox.example,2026:idempotency-key-malformed",
        "outstanding": "tag:tiffinbox.example,2026:idempotency-key-outstanding", "reused": "tag:tiffinbox.example,2026:idempotency-key-reused"}
INFO = {"title": "TiffinBox", "version": "1.0"}
PD = "#/components/schemas/ProblemDetail"
PJ = "application/problem+json"
# the change, as a derived list is expected to print it (asserted against git status / the trees, never used to make it)
WEB = "tiffinbox-web/src/main/java/com/tiffinbox/web/"
TWEB = "tiffinbox-web/src/test/java/com/tiffinbox/web/"
SPEC = "tiffinbox-web/src/test/resources/openapi/tiffinbox.json"
TEST = TWEB + "OpenApiSpecTest.java"
MAINCH = [WEB + f for f in ("CustomerPatches.java", "CustomerPauses.java", "CustomerReads.java", "TiffinBoxErrors.java", "TiffinBoxServer.java")]
TESTCH = [TWEB + f for f in ("CustomerPatchesTest.java", "CustomerReadsTest.java", "IdempotencyKeyTest.java", "TiffinBoxWebTest.java")]
CHANGED = MAINCH + TESTCH + [SPEC, "README.md"]
UNTOUCHED = ["pom.xml", "tiffinbox-web/pom.xml", "tiffinbox-core/pom.xml", TEST, WEB + "TiffinBoxOpenApi.java", WEB + "IdempotencyKeyFilter.java"]
STALE = [r"\b0 error responses\b(?! (?:at|on|before|in) )", r"no problem type moves", r"no test is added", r"\bnot-found answer is `about:blank`"]

def card(t):
    m = re.search(r"^## Course 9 · unit 09 — .*?(?=^## |^---$|\Z)", t, re.M | re.S); return m.group(0) if m else ""

def lines(p):
    return open(p, encoding="utf-8", errors="replace").read().splitlines()
def fixed(d):
    b = io.StringIO(); json.dump(d, b, indent=2, ensure_ascii=False); b.write("\n"); return b.getvalue()

# ---- the documents ---------------------------------------------------------------------------------------------------------------------
def jload(p):
    return json.load(open(p, encoding="utf-8"))
def opsof(d):
    return [(m.upper(), p, o) for p, v in d["paths"].items() for m, o in v.items()]
def codes(d):
    return {"%s %s" % (m, p): list(o.get("responses", {})) for m, p, o in opsof(d)}
def errcount(d):
    return sum(1 for m, p, o in opsof(d) for c in o.get("responses", {}) if not c.startswith("2"))
def keynamed(d):
    return sum(1 for m, p, o in opsof(d) for x in o.get("parameters", []) if x.get("in") == "header" and x.get("name", "").lower() == "idempotency-key")
def secmembers(d):
    return ("securitySchemes" in d.get("components", {}), "security" in d or any("security" in o for m, p, o in opsof(d)))
def docsum(f):
    d = jload(f)
    tags = sorted({t for m, p, o in opsof(d) for t in o.get("tags", [])})
    ss, sm = secmembers(d)
    print("  doc: openapi %s · info %s/%s · paths %d · operations %d · tags %d · schemas %s · securitySchemes %s · security %s · error responses %d · the key header named %d" % (
          d.get("openapi"), d.get("info", {}).get("title"), d.get("info", {}).get("version"), len(d["paths"]), len(opsof(d)), len(tags),
          ",".join(sorted(d.get("components", {}).get("schemas", {}))), "present" if ss else "absent", "present" if sm else "absent", errcount(d), keynamed(d)))
    for k, v in codes(d).items(): print("  resp | %s | %s" % (k, ",".join(v)))
DOCL = re.compile(r"^  doc: openapi (\S+) · info (\S+)/(\S+) · paths (\d+) · operations (\d+) · tags (\d+) · schemas (\S+) · securitySchemes (\w+) · security (\w+) · error responses (\d+) · the key header named (\d+)$")
RESPL = re.compile(r"^  resp \| ([A-Z]+ \S+) \| (\S+)$")
def readdoc(ls, prefix=""):
    D = []; R = []
    for l in ls:
        if not l.startswith(prefix): continue
        l2 = "  " + l[len(prefix):].lstrip() if prefix else l
        m = DOCL.match(l2)
        if m: D.append(m.groups()); R.append({}); continue
        r = RESPL.match(l2)
        if r and R: R[-1][r.group(1)] = r.group(2).split(","); continue
        if l2.startswith("  doc: ") or l2.startswith("  resp | "): fail("a document line this checker cannot parse: %r" % l[:120])
    return D, R

def nameset(f):
    d = jload(f); out = [(m, p) for m, p, o in opsof(d) if "{name}" in p]
    for m, p in out: print("  part1 | %s %s" % (m, p))
    print("  part (1): the {name} operations of the served document: %d of %d" % (len(out), len(opsof(d))))
def keyset(f):
    t = open(f, encoding="utf-8").read()
    rows = re.findall(r'new Guarded\("([A-Z]+)", PathPatternParser\.defaultInstance\.parse\("([^"]+)"\), (true|false), (true|false)\)', t)
    for m, p, req, form in rows: print("  part2 | %s %s | key %s | the form passes %s" % (m, p, "required" if req == "true" else "optional", form))
    print("  part (2): the keyed operations of the filter's GUARDED table: %d" % len(rows))
    print("  the filter's four types: %s" % " · ".join(re.findall(r'URI\.create\("(tag:[^"]+)"\)', t)))

def strip_added(b, a):
    """a with every response code b lacks removed and the ProblemDetail schema removed; both with info and servers removed"""
    b = json.loads(json.dumps(b)); a = json.loads(json.dumps(a)); added = []
    for d in (a, b): d.pop("servers", None); d.pop("info", None)
    for m, p, o in opsof(a):
        bo = b["paths"].get(p, {}).get(m.lower())
        if bo is None: continue
        for c in list(o.get("responses", {})):
            if c not in bo.get("responses", {}): added.append("%s %s %s" % (m, p, c)); del o["responses"][c]
    sch = a.get("components", {}).get("schemas", {})
    extra = [k for k in sch if k not in b.get("components", {}).get("schemas", {})]
    if "ProblemDetail" in extra: del sch["ProblemDetail"]          # the one schema this change adds; any other new schema stays and MOVES
    return b, a, added, extra
def strip(bf, af):
    if not os.path.exists(bf) or not os.path.exists(af) or os.path.getsize(bf) == 0 or os.path.getsize(af) == 0:
        print("  refused: an empty input"); sys.exit(2)
    b0, a0 = jload(bf), jload(af)
    b, a, added, extra = strip_added(b0, a0)
    hb = hashlib.md5(fixed(b).encode()).hexdigest(); ha = hashlib.md5(fixed(a).encode()).hexdigest()
    print("  strip: before (info, servers removed) md5 %s · after (info, servers, the added responses and the new schemas removed) md5 %s · %s" % (hb, ha, "EQUAL" if hb == ha else "MOVED"))
    for x in added: print("  added | %s" % x)
    print("  added responses %d · new schemas %s · info before %s · info after %s" % (len(added), ",".join(extra) or "none", json.dumps(b0.get("info")), json.dumps(a0.get("info"))))
    if hb != ha:
        for k in sorted(set(a) | set(b)):
            if a.get(k) != b.get(k): print("  MOVED member %s" % k)
        sys.exit(1)

def examples(f, bodies):
    d = jload(f); W = {os.path.splitext(x)[0]: jload(os.path.join(bodies, x)) for x in sorted(os.listdir(bodies)) if x.endswith(".json")}
    n = bad = 0
    for m, p, o in opsof(d):
        for c, r in o.get("responses", {}).items():
            for mt, cv in r.get("content", {}).items():
                for en, ex in cv.get("examples", {}).items():
                    n += 1; v = ex.get("value"); hit = [k for k, w in W.items() if w == v]
                    print("  example | %s %s %s %s | %s | %s" % (m, p, c, mt, en, ",".join(hit) or "NO FILED BODY"))
                    if not hit: bad += 1
                if "example" in cv: n += 1; bad += 1; print("  example | %s %s %s | a bare example member (not planned)" % (m, p, c))
    print("  examples %d · equal to a filed wire body %d · not %d" % (n, n - bad, bad))
    if bad: sys.exit(1)

def schema(f, bodies):
    d = jload(f); sch = d.get("components", {}).get("schemas", {}).get("ProblemDetail")
    W = {os.path.splitext(x)[0]: jload(os.path.join(bodies, x)) for x in sorted(os.listdir(bodies)) if x.endswith(".json")} if os.path.isdir(bodies) else {}
    if sch is None or not W: print("  refused: no ProblemDetail schema or no filed body"); sys.exit(2)
    mem = sorted(sch.get("properties", {}))
    print("  schema ProblemDetail members: %s" % ",".join(mem))
    k1 = set(); k2 = set(mem)
    for k, w in W.items():
        ks = sorted(w); print("  body %s keys: %s" % (k, ",".join(ks)))
        k1 |= set(ks) - set(mem); k2 -= set(ks)
    print("  the wire sends, the schema does not list at its top level: %s (%d) · the schema lists, the wire never sends: %s (%d)" % (",".join(sorted(k1)) or "none", len(k1), ",".join(sorted(k2)) or "none", len(k2)))

def count404(f):
    d = jload(f); w = [(m, p) for m, p, o in opsof(d) if "404" in o.get("responses", {})]
    print("  blanket: operations documenting a four-oh-four: %d of %d" % (len(w), len(opsof(d))))
    for m, p in (("GET", "/revenue"), ("GET", "/kitchen"), ("POST", "/shutdown")):
        o = d["paths"].get(p, {}).get(m.lower(), {})
        print("  blanket | %s %s | responses %s | 404 %s" % (m, p, ",".join(o.get("responses", {})), json.dumps(o.get("responses", {}).get("404"))[:160]))

# ---- the request blocks and the small readers: U08's (chk08.py), copied --------------------------------------------------------
def tree(d):
    out = {}
    for r, ds, fs in os.walk(d):
        ds.sort()
        for f in fs:
            p = os.path.join(r, f); out[os.path.relpath(p, d)] = hashlib.md5(open(p, "rb").read()).hexdigest()
    return out


# ---- the request blocks (U06's reader, copied; the cache sub-line dropped) --------------------------------------------------------------
ASK = re.compile(r"^-- ([\w-]+) \| ([A-Z]+) (\S+) -> (\d{3}) (\S*) (\d+) \(curl exit (\d+)\)$")
SRV = re.compile(r"^([A-Z]+) (\S+)( \[dispatch (\w+), for (\S+)\])? -> (\d{3}) \| handler (\S+) \| post-handle (no|yes \(count (\d+)\))(?: \| ex (\S+))?(?: \| thrown (\S+))?(?: \| async started)? \| statements (\d+) \(writes (\d+), prepares (\d+)\)$")
ACC = re.compile(r"^([A-Z]+) (\S+?) (\d{3}) (\S+)$")
def parse(ls):
    asks = []; heads = []; cur = None
    for l in ls:
        if l.startswith("-- "):
            a = ASK.match(l)
            if not a: fail("a request line the reader cannot parse: %r" % l[:120]); cur = None; continue
            cur = {"lab": a.group(1), "m": a.group(2), "p": a.group(3), "st": a.group(4), "ct": a.group(5), "sz": int(a.group(6)), "rc": a.group(7),
                   "sl": [], "hd": [], "acc": [], "srv": [], "body": None, "key": None}
            asks.append(cur); continue
        if l.startswith("     ") and cur is not None:
            t = l[5:]
            if t.startswith("status lines: "): cur["sl"] = [x.strip() for x in t[14:].split(" > ") if x.strip()]; continue
            if t.startswith("header: "): cur["hd"].append(t[8:]); continue
            if t.startswith("sent: key header "): cur["key"] = t[17:]; continue
            if t.startswith("access: "):
                a = ACC.match(t[8:])
                if not a: fail("an access-log line the reader cannot parse: %r" % t[:100]); continue
                cur["acc"].append(a.groups()); continue
            if t.startswith("server: "):
                s = SRV.match(t[8:])
                if not s: fail("a witness line the reader cannot parse: %r" % t[:140]); continue
                g = s.groups()
                cur["srv"].append({"m": g[0], "p": g[1], "disp": g[3], "st": g[5], "h": g[6], "ph": g[7] != "no", "stm": int(g[11]), "w": int(g[12])}); continue
            if t.startswith("body: "): cur["body"] = t[6:]; continue
            fail("a sub-line the reader cannot parse: %r" % t[:100]); continue
        if l.startswith("     "): fail("an indented line outside a request block: %r" % l[:100]); continue
        cur = None
        heads.append(l)
    return asks, heads
def hdr(r, name):
    for h in r["hd"]:
        if h.lower().startswith(name.lower() + ":"): return h.split(":", 1)[1].strip()
    return None
def load(p):
    ls = lines(p); asks, heads = parse(ls); return ls, {a["lab"]: a for a in asks}, heads, asks
def sibling(p, nm):
    q = os.path.join(os.path.dirname(os.path.abspath(p)), ".r-%s.new" % nm)
    if os.path.exists(q): return q
    q = os.path.join(os.path.dirname(os.path.abspath(p)), ".r-%s.out" % nm)
    return q if os.path.exists(q) else None

# ---- small readers --------------------------------------------------------------------------------------------------------------------
def specmask(stdin):
    d = json.load(stdin); s = d.get("servers")
    print(re.sub(r"(127\.0\.0\.1|localhost):\d{4,5}", r"\1:<port>", json.dumps(s)))
def surefire(p):
    import xml.etree.ElementTree as ET
    if not os.path.exists(p): print("  %s absent" % os.path.basename(p)); return
    r = ET.parse(p).getroot()
    print("  %s tests %s failures %s errors %s skipped %s" % (r.get("name").split(".")[-1], r.get("tests"), r.get("failures"), r.get("errors"), r.get("skipped")))
def maprows(m):
    rows = []
    for ctx in m["contexts"].values():
        for ds in ctx["mappings"].get("dispatcherServlets", {}).values():
            for e in ds:
                d = e.get("details") or {}
                hm = d.get("handlerMethod")
                if not hm: continue
                c = d.get("requestMappingConditions", {})
                rows.append((hm["className"], hm["name"], ",".join(c.get("methods", [])) or "ANY", ",".join(c.get("patterns", [])),
                             ",".join(x["mediaType"] for x in c.get("produces", [])) or "-", ",".join(x["mediaType"] for x in c.get("consumes", [])) or "-"))
    return rows
def mapjson(side, stdin):
    rows = maprows(json.load(stdin))
    tb = [r for r in rows if r[0].startswith("com.tiffinbox")]; sd = [r for r in rows if r[0].startswith("org.springdoc")]
    oth = [r for r in rows if not r[0].startswith(("com.tiffinbox", "org.springdoc"))]
    print("  %s: handler methods: %d in all, %d TiffinBox's (com.tiffinbox), %d springdoc's (org.springdoc), %d others (actuator, /error)" % (side, len(rows), len(tb), len(sd), len(oth)))
    for r in sorted(tb): print("  %s | %s" % (side, " | ".join([r[0].rsplit('.', 1)[1] + "#" + r[1]] + list(r[2:]))))
    for r in sorted(sd): print("  %s springdoc | %s#%s %s %s" % (side, r[0].rsplit('.', 1)[1], r[1], r[2], r[3]))
    print("  %s the others: %s" % (side, " · ".join(sorted("%s %s" % (r[2], r[3]) for r in oth))))
def ops(mp, sp):
    rows = [r for r in maprows(json.load(open(mp))) if r[0].startswith("com.tiffinbox")]
    d = json.load(open(sp)); d.pop("servers", None)
    O = {(m.upper(), p): set(o.get("tags", [])) for p, v in d["paths"].items() for m, o in v.items()}
    kebab = lambda n: re.sub(r"(?<!^)(?=[A-Z])", "-", n).lower()
    seen = collections.Counter()
    for r in sorted(rows):
        k = (r[2], r[3]); cl = r[0].rsplit(".", 1)[1]
        # an operation documents a handler when its method and path are the handler's AND its tag is the handler's class (springdoc's tag
        # rule): DashboardPage's GET /dashboard and POST /customers share a method and path with TiffinBoxServer's, not a tag
        st = "operation %s %s" % k if k in O and kebab(cl) in O[k] else "absent"
        if st != "absent": seen[k] += 1
        print("  op | %s#%s | %s %s | %s" % (r[0].rsplit('.', 1)[1], r[1], r[2], r[3], st))
    print("  op document: paths %d · operations %d · operations no handler maps: %d" % (len(d["paths"]), len(O), len([k for k in O if k not in seen])))
def docfacts(raw, out, filed):
    d = json.load(open(raw, encoding="utf-8")); s = d.get("servers")
    print("  document: openapi %s · info %s · servers %s" % (d.get("openapi"), json.dumps(d.get("info")), re.sub(r"(127\.0\.0\.1|localhost):\d{4,5}", r"\1:<port>", json.dumps(s))))
    print("  document: paths %d · operations %d · tags %s · schemas %s" % (len(d["paths"]), sum(len(v) for v in d["paths"].values()),
          ",".join(sorted({t for v in d["paths"].values() for o in v.values() for t in o.get("tags", [])})), ",".join(sorted(d.get("components", {}).get("schemas", {})))))
    print("  document: components.securitySchemes %s · a security member %s (data for the later lessons, claimed nowhere)" % ("present" if "securitySchemes" in d.get("components", {}) else "absent",
          "present" if "security" in d or any("security" in o for v in d["paths"].values() for o in v.values()) else "absent"))
    print("  document: Customer required %s of %s properties" % (json.dumps(sorted(d["components"]["schemas"]["Customer"].get("required", []))), len(d["components"]["schemas"]["Customer"]["properties"])))
    rawm = re.sub(rb"(127\.0\.0\.1|localhost):\d{4,5}", rb"\1:<port>", open(raw, "rb").read())
    d.pop("servers", None)
    import io
    b = io.StringIO(); json.dump(d, b, indent=2, ensure_ascii=False); b.write("\n")
    open(out, "w", encoding="utf-8").write(b.getvalue())
    print("  document: the socket's answer %d B (never voiced: it carries the port) · md5 masked %s · servers removed (the fixed rule) %s · = the committed file: %s" % (
          os.path.getsize(raw), hashlib.md5(rawm).hexdigest(), hashlib.md5(b.getvalue().encode()).hexdigest(), "byte-identical" if b.getvalue() == open(filed, encoding="utf-8").read() else "DIFFERENT"))
def pairs(dr):
    for f in sorted(os.listdir(dr)):
        w = json.load(open(os.path.join(dr, f)))
        rq, rs = w["request"], w["response"]
        key = "yes" if any(k.lower() == "idempotency-key" for k in rq["headers"]) else "no"
        print("  pair %s | %s %s | body %s | key header %s -> %s %s | %s" % (w["name"], rq["method"], rq["path"], json.dumps(rq["body"], separators=(",", ":")), key,
              rs["status"], rs["content_type"], re.sub(r"\s+", " ", rs["body"])[:150].replace('"timestamp"', '"ts"')))
def rowsvs(mine, blue):
    rx = re.compile(r"^\s*\d+ (\S.*?)\s+spec: ")
    a = [rx.match(l).group(1) for l in lines(mine) if rx.match(l)]
    b = [rx.match(l).group(1) for l in lines(blue) if rx.match(l)] if os.path.exists(blue) else []
    print("rows %d vs BLUE's %d, the row keys %s" % (len(a), len(b), "equal" if a == b else "DIFFER"))

TESTS_RX = r"^  (\w+) tests (\d+) failures (\d+) errors (\d+) skipped (\d+)$"
IT = {"CustomerEntityRepositoryIT": (21280, 5432), "CustomerAggregatesIT": (21281, 5432), "RedisDatastoreIT": (21282, 6379), "MongoDatastoreIT": (21283, 27017), "ElasticsearchIT": (21284, 9200)}

KINDS = re.compile(r"^  \((a|b)\) KINDS (\d+): (.*)$")
DIS = re.compile(r"^  \((a|b)\) DISAGREEMENTS (\d+)$")
ROWL = re.compile(r"^  \((a|b)\) +(\d+) (\S.*?)\s+spec: (.*?) \| wire: (.*)$")
PAIR = re.compile(r"^  pair (\S+) \| ([A-Z]+) (\S+) \| body (.*) \| key header (yes|no) -> (\d{3}) (\S+) \| (.*)$")

def kind(k):
    for suf, name in ((" status", "success/error status"), (" media", "response media type"), (" header", "required header")):
        if k.endswith(suf): return name
    return k


# ---- static ---------------------------------------------------------------------------------------------------------------------------
import difflib
def udiff(a, b):
    return [l for l in difflib.unified_diff(a.splitlines(), b.splitlines(), lineterm="", n=0) if not l.startswith(("---", "+++", "@@"))]
ANNOT = re.compile(r"^\+(?:\s*$|\s*//.*|\s*/?\*.*|\s*@ApiResponse\(.*|\s+schema = @Schema\(implementation = ProblemDetail\.class\), examples = .*|import (?:io\.swagger\.v3\.oas\.annotations\.\S+|org\.springframework\.http\.ProblemDetail|java\.net\.URI);|\s*static final URI CUSTOMER_NOT_FOUND = URI\.create\(\"tag:tiffinbox\.example,2026:customer-not-found\"\);|\s*problem\.setType\(CUSTOMER_NOT_FOUND\);\s+// Course 9, unit 09: .*)$")
def static(after, before):
    md = lambda x: hashlib.md5("\n".join(x).encode()).hexdigest()
    end = "# --- XFAM_S9S1 end ---"
    s9 = open(os.path.join(HERE, "s909.py"), encoding="utf-8").read().split("\n")
    s8 = open(os.path.join(UNIT, "..", "c9-unit08", "harness", "s908.py"), encoding="utf-8").read().split("\n")
    s4 = open(os.path.join(UNIT, "..", "c9-unit04", "harness", "s904.py"), encoding="utf-8").read().split("\n")
    if any(end not in s for s in (s9, s8, s4)): fail("the XFAM_S9S1 end marker is missing in s909.py, s908.py or s904.py"); done()
    a = lambda s: next(i for i, l in enumerate(s) if l.endswith('"""') and i > 0)
    sl = lambda s: s[a(s) + 1:s.index(end) + 1]
    need(sl(s9) == sl(s4), "s909.py's base + XFAM_S9S1 (after its docstring, through the block's end marker) = s904.py's, %d lines, md5 %s" % (len(sl(s4)), md(sl(s4))))
    need(sl(s9) == sl(s8), "= U08's s908.py's slice (copied from U08's harness)")
    t9 = "\n".join(s9); t4 = "\n".join(s4)
    rx = r"# --- XFAM_S9S1 begin ---\n.*?# --- XFAM_S9S1 end ---"
    b4 = re.search(rx, t4, re.S); b9 = re.search(rx, t9, re.S)
    need(b4 is not None and b9 is not None and b4.group(0) == b9.group(0), "the XFAM_S9S1 block, delimited, byte-equal to U04's")
    if b9:
        h = hashlib.md5(b9.group(0).encode()).hexdigest()
        print("  XFAM_S9S1_SLICE_MD5 = %s (computed the way ../c9-unit04/harness/chk04.py computes it)" % h); val("xfam_s9s1_md5", h[:8])
    need(not re.search(r"^XU0[1-8] = ", t9, re.M), "XU01-XU08 are not carried")
    need(re.search(r"^XU09 = ", t9, re.M) is not None and re.search(r"^u04 = u09$", t9, re.M) is not None, "U09's own family (XU09) follows the carried slice; u04 = u09 (U01's binding)")
    x2 = os.path.join(C9R, "_builders", "s907.py")
    print("  XFAM_S9S2 (the scripts stage's, C9/_builders/s907.py): %s" % ("present - not asserted here" if os.path.exists(x2) and "XFAM_S9S2" in open(x2, encoding="utf-8").read() else "does not exist yet - nothing to assert XU09 against"))
    ck = open(os.path.join(HERE, "chk09.py"), encoding="utf-8").read()
    dead = [w for w in ("cdpev(", "netread(", "plantev(", "plantnet(", "detector(", "dom(", "assets(", "opid(", "media(", "c_sealed(", "c_tryit(", "c_redirect(", "c_ops(", "c_info(")
            if re.search(r"^def " + re.escape(w), ck, re.M)]
    need(not dead, "chk09.py carries none of chk08.py's browser subcommands or page captures (left out by name: cdpev netread plantev plantnet detector dom assets opid media sealed tryit redirect ops info) %s" % dead)
    hs = sorted(os.listdir(HERE))
    need(not any(x in hs for x in ("cdp.mjs", "cdp9.mjs", "seal9.py")), "harness/ holds no cdp.mjs, cdp9.mjs or seal9.py (no browser here)")
    ta, tb_ = tree(after), tree(before)
    ch = sorted(f for f in set(ta) | set(tb_) if ta.get(f) != tb_.get(f))
    print("  the changed files, derived (the two trees' file lists and md5s): %d · %s" % (len(ch), " ".join(ch)))
    need(ch == sorted(CHANGED) and all(f in tb_ for f in ch), "the derived list = the change's files (5 under src/main, 4 tests, the committed file, the README), none new")
    nm = [f for f in ch if f.startswith(("tiffinbox-web/src/main/", "tiffinbox-core/src/main/"))]
    val("files_changed", len(ch)); val("files_main", len(nm)); val("files_new", 0)
    for f in UNTOUCHED: need(f in ta and ta[f] == tb_.get(f), "(iii)/(iv) byte-equal to before (U08's): " + f)
    need(not any(f.endswith((".yaml", ".yml", ".sql", ".properties", "pom.xml")) for f in ch), "(iii) no pom, no property, no migration")
    bad = []
    for f in nm:
        for l in udiff(open(os.path.join(before, f), encoding="utf-8").read(), open(os.path.join(after, f), encoding="utf-8").read()):
            if l.startswith("-") or not ANNOT.match(l): bad.append("%s: %s" % (f.rsplit("/", 1)[1], l[:90]))
    need(not bad, "(i') src/main's diff: only annotation lines, comments, imports, the constant and the one setType line - no handler's logic (%d other lines) %s" % (len(bad), bad[:3]))
    et = open(os.path.join(after, WEB + "TiffinBoxErrors.java"), encoding="utf-8").read()
    need(et.count("problem.setType(CUSTOMER_NOT_FOUND);") == 1 and 'URI.create("%s")' % TYPE in et and "@ResponseStatus" not in et, "TiffinBoxErrors: one setType, the constant %s, no @ResponseStatus" % TYPE)
    rs = []
    for f in sorted(ta):
        if f.startswith(("tiffinbox-web/src/main/", "tiffinbox-core/src/main/")) and f.endswith(".java"):
            for i, l in enumerate(open(os.path.join(after, f), encoding="utf-8").read().split("\n"), 1):
                if "@ResponseStatus" in l and not l.strip().startswith(("*", "//")): rs.append("%s:%d" % (f.rsplit("/", 1)[1], i))
    print("  @ResponseStatus in after/'s main sources, file by file: %s" % (" ".join(rs) or "none"))
    dw = open(os.path.join(after, WEB + "DishWrite.java"), encoding="utf-8").read()
    need(rs == ["DishWrite.java:32"] and '@Profile("dev")' in dw, "flag 8: exactly DishWrite.java:32 (a @Profile(\"dev\") route) and nothing in TiffinBoxErrors.java")
    tbad = []
    for f in [x for x in ch if x.startswith(TWEB)]:
        for l in udiff(open(os.path.join(before, f), encoding="utf-8").read(), open(os.path.join(after, f), encoding="utf-8").read()):
            if l.startswith("-"): tbad.append(f)
    k = sum(len([l for l in udiff(open(os.path.join(before, f), encoding="utf-8").read(), open(os.path.join(after, f), encoding="utf-8").read()) if l.strip() == "+    @Test"]) for f in ch if f.startswith(TWEB))
    need(not tbad, "the tests' diff: additions only (no existing test edited) %s" % tbad[:2])
    print("  new @Test lines in the tests' diff (k): %d" % k); val("k", k)
    sf = os.path.join(after, SPEC); sd = jload(sf); bd = jload(os.path.join(before, SPEC))
    need("servers" not in sd and fixed(sd) == open(sf, encoding="utf-8").read(), "the committed file: no servers, written by the fixed rule")
    b2, a2, added, extra = strip_added(bd, sd)
    sb = open(os.path.join(before, SPEC), encoding="utf-8").read()
    a2["info"] = sd.get("info"); a3 = json.loads(json.dumps(sd))
    for m, p, o in opsof(a3):
        o["responses"] = {c: r for c, r in o["responses"].items() if c in bd["paths"][p][m.lower()]["responses"]}
    a3.get("components", {}).get("schemas", {}).pop("ProblemDetail", None)
    need(fixed(a3) == sb, "the committed file with the added responses and ProblemDetail removed = U08's file byte for byte (md5 %s = %s)" % (hashlib.md5(fixed(a3).encode()).hexdigest()[:8], hashlib.md5(sb.encode()).hexdigest()[:8]))
    dl = udiff(sb, open(sf, encoding="utf-8").read())
    need(dl and all(l.startswith("+") for l in dl), "the file's diff against U08's: additions only (%d lines, %d removed)" % (len(dl), sum(1 for l in dl if l.startswith("-"))))
    need(extra == ["ProblemDetail"] and not any(secmembers(sd)) and keynamed(sd) == 0, "the file gains ProblemDetail and no other schema; no securitySchemes, no security member, no header parameter")
    val("spec_bytes", os.path.getsize(sf)); val("spec_bytes_u08", os.path.getsize(os.path.join(before, SPEC))); val("added_responses", len(added))
    rsh = open(os.path.join(UNIT, "receipts.sh"), encoding="utf-8").read()
    need(re.search(r'^AD=\$\(diff -rq -x \.m2-demo -x target -x secrets -x \.harness after \.\./c9-tiffinbox 2>&1 \|\| true\)$', rsh, re.M) is not None
         and not re.search(r'\[ -z "\$AD" \] \|\| die', rsh) and re.search(r'\[ "\$AD1" = "\$AD" \] \|\| die "the anchor moved during the run"', rsh) is not None,
         "receipts.sh: the anchor check at the start is a NOTE (no die on it); the end's check is the anchor moving DURING the run")
    rd = open(os.path.join(after, "README.md"), encoding="utf-8").read(); cd = card(rd)
    need(bool(cd) and "*Course 9, unit 09:" in rd and "Course 9's sixth change to this folder" in rd, "README: the unit 09 card, the header's unit 09 note, the sixth change named")
    hits = [x for x in STALE if re.search(x, cd)]
    need(not hits, "the stale hunt: unit 09's card says nothing as current that the change makes false (%s)" % hits)
    hh = [(i + 1, l) for i, l in enumerate(rd.split("\n")) if re.search(r"error response|problem type|about:blank|tag:|ProblemDetail|security|scheme|Not fixed here|no test is added|\b45\b|\b157\b|\b9843\b|Idempotency-Key", l, re.I)]
    print("  the stale hunt over after/README.md: %d lines (each read; history cards stay as written)" % len(hh))
    tj = open(os.path.join(after, TEST), encoding="utf-8").read()
    need("A change that changes the document on purpose (an info bean, documented errors) makes this" in tj, "OpenApiSpecTest's Javadoc (unchanged): \"documented errors ... fail until the file is written again\" - true, now paid")
    if os.path.exists(J9):
        t = open(J9, encoding="utf-8").read(); m = re.search(r'"09": "([^"]+)"', t)
        need(m is not None and m.group(1) == "Documenting Errors, Examples and Security", "java9_series.TITLES['09'] = %r" % (m.group(1) if m else None))
    done()

# ---- the spoken lines -----------------------------------------------------------------------------------------------------------------
STATUS = re.compile(r"(?<![\d.,:/-])\b(?:[1-5]\d\d)\b|\b(?:one|two|three|four|five)[\s-]hundred[\s-]and\b|\b(?:one|two|three|four|five)[\s-]hundred[\s-](?:one|two|three|four|five|six|seven|eight|nine|ten|eleven|twelve|thirteen|fourteen|fifteen)\b")
HING = re.compile(r"\b(?:bhai|yaar|dosto|kya|hai|nahi|nahin|matlab|karo|dekho|chalo|samjho|theek|accha|arre|haan|bilkul|zaroor|aur|toh|abhi|yeh|woh|kaise|kyun|bahut|thoda|sahi|galat)\b", re.I)
SPELL = re.compile(r"\b(?:API|URI|URL|RFC)s?\b|\bOpenAPI\b|\bspringdoc\b")
def brief_lines():
    t = open(S2B, encoding="utf-8").read().split("\n")
    i0 = next(i for i, l in enumerate(t) if l.startswith("## Unit 09 · Documenting Errors, Examples and Security")); i1 = next(i for i, l in enumerate(t) if i > i0 and l.startswith("## "))
    print("  the brief's Unit 09 section: S2B :%d-:%d" % (i0 + 1, i1))
    t = t[i0:i1]
    h = [l for l in t if l.startswith("**Hook")]
    e = [l for l in t if l.startswith('**Exercise:** "Your turn:')]
    hook = re.search(r'"([^"]+)"', h[0]).group(1) if len(h) == 1 else None
    m = re.search(r'\*\*Exercise:\*\* "([^"]+)"', e[0]) if len(e) == 1 else None
    return hook, (m.group(1) if m else None), h + e
def spoken(hook, exq):
    import importlib.util
    spec = importlib.util.spec_from_file_location("dur9", os.path.join(HERE, "dur9.py")); m = importlib.util.module_from_spec(spec); spec.loader.exec_module(m)
    dur = getattr(m, "DUR", None)
    need(dur is not None, "dur9.py exposes its pattern (DUR)")
    bh, be, bl = brief_lines()
    print("  extracted from the brief's bytes (S2B, the Hook line and the Exercise line): %d lines, md5 %s" % (len(bl), hashlib.md5("\n".join(bl).encode()).hexdigest()))
    need(hook == HOOK == bh, "the hook is S2B's Unit 09 Hook line's quote, byte for byte (extracted at run time = typed once here)")
    need(exq == EXQ == be, "the exercise's line is S2B's Unit 09 Exercise line's quote, byte for byte (extracted at run time = typed once here)")
    hw, ew, gw = len(hook.split()), len(exq.split()), len(GLOSS.split())
    need(hw == 21 and hw <= 25, "the hook: %d words (wc -w; the brief's 21; <= 25)" % hw)
    need(ew == 15 and ew <= 25, "the exercise: %d words (wc -w; the brief's 15; <= 25)" % ew)
    for name, s in (("the hook", hook), ("the exercise", exq), ("the gloss", GLOSS)):
        nd = re.findall(r"\d", s)
        print("  %s: digits %s · the status gate %s · the spelling gate %s · Hinglish %s · dur9 %s" % (name, "".join(nd) or "0", "hit" if STATUS.search(s) else "0",
              SPELL.search(s).group(0) if SPELL.search(s) else "0", "hit" if HING.search(s) else "0", dur.search(s).group(0) if dur is not None and dur.search(s) else "0"))
        need(not STATUS.search(s), "%s: the status gate 0 (\"four oh four\" is the status form)" % name)
        need(not SPELL.search(s), "%s: the spelling gate 0 (API, URI, URL, RFC, bare OpenAPI / springdoc)" % name)
        need(not HING.search(s), "%s: the Hinglish list 0" % name)
        if dur is not None: need(not dur.search(s), "%s: dur9 0" % name)
        need(not nd, "%s: no digit" % name)
    for p in ("Open A-P-I", "spring doc", "U-R-I"): need(not SPELL.search(p), "the spelled form %r passes the spelling gate (RED #25 / BLUE)" % p)
    for p in ("OpenAPI", "springdoc", "URI"): need(bool(SPELL.search("It reads the " + p + " document.")), "the bare %r refuses in a spoken line" % p)
    print("  the hook: %d words · the exercise: %d words · the gloss: %d words; the brief's parenthetical (%d words): \"%s\" (its bare URI refuses: the gloss spells it U-R-I)" % (hw, ew, gw, len(BRIEFQ.split()), BRIEFQ))
    need(bool(SPELL.search(BRIEFQ)), "the brief's parenthetical as written (bare URI) would refuse - the passing form is the spelled one")
    print("  the hook's citation in the brief: \"BLUE §B7\" - the gate re-run on the brief's new lines is NOTES's B4 (B7 is the Sunset header re-read): a mis-cite, filed for the scripts stage, the brief not edited")
    val("hook_words", hw); val("exercise_words", ew); val("gloss_words", gw)
    done()

def gloss(readme):
    u6 = open(os.path.join(UNIT, "..", "c9-unit06", "README.md"), encoding="utf-8").read().split("\n")
    u8 = open(os.path.join(UNIT, "..", "c9-unit08", "README.md"), encoding="utf-8").read().split("\n")
    need(len(u6) > 18 and u6[18] == U06GLOSS, "U06's gloss line is still byte-equal at ../c9-unit06/README.md:19")
    need(len(u8) > 15 and u8[15] == U08GLOSS, "U08's gloss line is still byte-equal at ../c9-unit08/README.md:16")
    rd = open(readme, encoding="utf-8").read().split("\n")
    g = [i + 1 for i, l in enumerate(rd) if re.match(r"^\s*(?:A contract|Swagger UI):", l)]
    need(not g, "README.md carries no line starting \"A contract:\" or \"Swagger UI:\" (U06's and U08's, not re-glossed) %s" % g)
    s = [i + 1 for i, l in enumerate(rd) if l.startswith("A problem type:")]
    need(len(s) == 1 and rd[s[0] - 1] == GLOSS, "README.md carries exactly one line starting \"A problem type:\", the gloss byte for byte (%s)" % s)
    need(len(GLOSS.split()) <= 25, "the gloss: %d words (<= 25)" % len(GLOSS.split()))
    first = next((i + 1 for i, l in enumerate(rd) if "problem type" in re.sub(r"`[^`]*`", "", l) and not l.startswith("#")), None)
    print("  the gloss (%d words): %s · the brief's parenthetical (%d words): %s" % (len(GLOSS.split()), GLOSS, len(BRIEFQ.split()), BRIEFQ))
    print("  first spoken use of \"problem type\" in the README at line %s" % first)
    val("gloss", "problem_type_one_line")
    done()

# ---- this unit's small readers -----------------------------------------------------------------------------------------------------------
def codetable(bf, af):
    b, a = jload(bf), jload(af); cb, ca = codes(b), codes(a)
    for k in ca: print("  codes | %s | before %s | after %s | %s" % (k, ",".join(cb.get(k, [])), ",".join(ca[k]), "+" + ",".join(c for c in ca[k] if c not in cb.get(k, [])) if ca[k] != cb.get(k) else "equal"))
def plantdoc(k, src, out):
    d = jload(src)
    if k == "description": d["paths"]["/revenue"]["get"]["description"] = "the harness's plant"
    elif k == "schema": d["components"]["schemas"]["Plant"] = {"type": "object"}
    elif k == "securitySchemes": d["components"]["securitySchemes"] = {"bearer": {"type": "http", "scheme": "bearer"}}
    json.dump(d, open(out, "w"))
def union(sp, filt):
    d = jload(sp); t = open(filt, encoding="utf-8").read()
    p1 = {(m, p) for m, p, o in opsof(d) if "{name}" in p}
    p2 = {(m, p) for m, p, req, form in re.findall(r'new Guarded\("([A-Z]+)", PathPatternParser\.defaultInstance\.parse\("([^"]+)"\), (true|false), (true|false)\)', t)}
    u = sorted(p1 | p2)
    for m, p in u:
        o = d["paths"][p][m.lower()]
        print("  union | %s %s | part %s | documents %s" % (m, p, "+".join(x for x, s in (("1", p1), ("2", p2)) if (m, p) in s), ",".join(c for c in o.get("responses", {}) if not c.startswith("2")) or "none"))
    print("  part (1) %d · part (2) %d · both %d · the union %d of %d operations" % (len(p1), len(p2), len(p1 & p2), len(u), len(opsof(d))))
def bodydiff(bd, s1, s2):
    for k in ("nf-customers", "nf-public", "nf-patch", "pauseget-404"):
        f1, f2 = os.path.join(bd, "%s-%s.json" % (s1, k)), os.path.join(bd, "%s-%s.json" % (s2, k))
        if not (os.path.exists(f1) and os.path.exists(f2)): print("  body | %s | MISSING" % k); continue
        a, b = jload(f1), jload(f2)
        add = sorted(set(b) - set(a)); rem = sorted(set(a) - set(b)); same = all(a[x] == b[x] for x in a if x in b)
        print("  body | %s | before %s" % (k, open(f1, encoding="utf-8").read().strip()))
        print("  body | %s | after  %s" % (k, open(f2, encoding="utf-8").read().strip()))
        print("  body | %s | %s" % (k, ("moved, additive: +" + ",".join('"%s":"%s"' % (x, b[x]) for x in add) + (", every other member byte-equal" if same and not rem else ", OTHER MEMBERS MOVED")) if add or rem or not same else "equal"))
def should(bd):
    import http
    rows = []
    for f in sorted(os.listdir(bd)):
        if not f.startswith("after-") and not f.startswith("key-"): continue
        b = jload(os.path.join(bd, f)); st = b.get("status"); ty = b.get("type", "about:blank"); ti = b.get("title")
        ph = http.HTTPStatus(st).phrase if st else "-"
        rows.append((f[:-5], st, ty, ti, ph, ti == ph))
    for r in rows: print("  should | %s | %s | %s | %s | the phrase %s | %s" % (r[0], r[1], r[2], r[3], r[4], ("equal" if r[5] else "NOT the phrase") + (" (about:blank: the SHOULD applies)" if r[2] == "about:blank" else " (typed: the SHOULD does not apply)")))
    ab = [r for r in rows if r[2] == "about:blank"]
    print("  should: bodies %d · about:blank %d (title = the phrase %d, not %d) · typed %d" % (len(rows), len(ab), sum(1 for r in ab if r[5]), sum(1 for r in ab if not r[5]), len(rows) - len(ab)))
def typeconst(f):
    t = open(f, encoding="utf-8").read(); m = re.search(r'static final URI CUSTOMER_NOT_FOUND = URI\.create\("([^"]+)"\);', t)
    print("%s (static final URI CUSTOMER_NOT_FOUND, TiffinBoxErrors; no '//': %s)" % (m.group(1) if m else "-", "yes" if m and "//" not in m.group(1) else "NO"))
def unadd(bf, af):
    b, a = jload(bf), jload(af); a = json.loads(json.dumps(a))
    for m, p, o in opsof(a): o["responses"] = {c: r for c, r in o["responses"].items() if c in b["paths"][p][m.lower()]["responses"]}
    a.get("components", {}).get("schemas", {}).pop("ProblemDetail", None)
    print(hashlib.md5(fixed(a).encode()).hexdigest())
def abdiff(af, bf):
    a, b = jload(af), jload(bf)
    for d in (a, b): d.pop("servers", None)
    ha, hb = hashlib.md5(fixed(a).encode()).hexdigest(), hashlib.md5(fixed(b).encode()).hexdigest()
    print("  abdiff: A (after/, the annotations) md5 %s · B (the loser mirror, the customizer) md5 %s · the bytes %s · as JSON %s" % (ha, hb, "equal" if ha == hb else "DIFFER", "equal" if a == b else "DIFFER"))
    def walk(x, y, path):
        if isinstance(x, dict) and isinstance(y, dict):
            for k in list(x) + [k for k in y if k not in x]:
                if k not in x or k not in y: print("  abdiff | %s/%s | %s" % (path, k, "A only" if k in x else "B only"))
                else: walk(x[k], y[k], path + "/" + k)
            if list(x) != list(y) and set(x) == set(y): print("  abdiff | %s | the member order differs" % path)
        elif x != y: print("  abdiff | %s | A %s | B %s" % (path, json.dumps(x)[:80], json.dumps(y)[:80]))
    walk(a, b, "")
def rnames(p):
    t = open(p, encoding="utf-8", errors="replace").read() if os.path.exists(p) else ""
    print("responses %s · mealsPerDay %s · maxLength %s · 410 %s" % ("responses" in t, "mealsPerDay" in t, "maxLength" in t, "410" in t))

# ---- the captures ---------------------------------------------------------------------------------------------------------------------
def u08v():
    t = open(os.path.join(UNIT, "..", "c9-unit08", "README.md"), encoding="utf-8").read()
    m = re.search(r"<!-- values: begin -->\n```\n(.*?)\n```", t, re.S); V = {}
    for l in (m.group(1).splitlines() if m else []):
        for k, v in re.findall(r"(\w+)=(\S+)", l): V.setdefault(l.split(":")[0] + "." + k, v)
    return V
def kfrom(t):
    return sum(int(x) for x in re.findall(r"^  new @Test \| \w+ \| (\d+) \| ", t, re.M))
def c_tests(p):
    ls = lines(p); sec = None; per = {"pkg": {}, "twin": {}, "it": {}}
    for l in ls:
        if l.startswith("== Surefire's XML, per class (package)"): sec = "pkg"; continue
        if l.startswith("== Surefire's XML, per class (the twin)"): sec = "twin"; continue
        if l.startswith("== Failsafe's XML"): sec = "it"; continue
        if l.startswith("== "): sec = None; continue
        m = re.match(TESTS_RX, l)
        if m and sec:
            per[sec][m.group(1)] = int(m.group(2)); need(m.group(3) == m.group(4) == "0", "%s %s: failures and errors 0" % (sec, m.group(1)))
        elif sec and l.startswith("  ") and not l.startswith(("  IT BINDINGS", "  the ", "  Testcontainers", "  mvn ")):
            fail("a per-class line this checker cannot parse: %r" % l[:100])
    V = u08v(); u8 = int(V.get("tests.tests", 0)); i8 = int(V.get("tests.its", 0)); t = "\n".join(ls); k = kfrom(t)
    nt = re.findall(r"^  new @Test \| (\w+) \| (\d+) \| (\S+)$", t, re.M)
    print("  the new tests: %s" % " · ".join("%s#%s" % (c, n) for c, x, n in nt))
    need(k == 4 and sorted(c for c, x, n in nt) == ["CustomerPatchesTest", "CustomerReadsTest", "IdempotencyKeyTest", "TiffinBoxWebTest"], "k = %d new @Test lines, one per CustomerNotFound route's class (derived off the trees)" % k)
    for s in ("pkg", "twin"):
        tot = sum(per[s].values())
        need(tot == u8 + k and per[s].get("OpenApiSpecTest") == 1, "%s: %d = U08's %d (its README values block; re-measured) + k %d; OpenApiSpecTest 1" % (s, tot, u8, k))
    need(per["pkg"] == per["twin"], "the Docker-free twin runs the same classes and counts as package")
    need(re.search(r"^  mvn package exit 0 ", t, re.M) is not None and re.search(r"^  mvn package \(Docker-free\) exit 0 ", t, re.M) is not None, "mvn package exit 0, and its Docker-free twin exit 0")
    need(sum(per["it"].values()) == i8 == 14 and len(per["it"]) == 5, "the ITs: %d in 5 classes (U08's %s)" % (sum(per["it"].values()), i8))
    for c in ("TiffinBoxWebTest", "CustomerReadsTest", "CustomerPatchesTest", "IdempotencyKeyTest"): print("  %s: %s tests (the XML)" % (c, per["pkg"].get(c)))
    val("tests", sum(per["pkg"].values())); val("tests_u08", u8); val("tests_k", k); val("its", sum(per["it"].values()))
    b = [re.match(r"^  IT BINDINGS (\w+) \[(.*)\]$", l) for l in ls if l.startswith("  IT BINDINGS ")]
    if any(x is None for x in b): fail("an IT BINDINGS line this checker cannot parse")
    b = [x for x in b if x]
    entries = [(x.group(1), e) for x in b for e in x.group(2).split(", ")]
    off = [e for c, e in entries if not re.search(r"-> 127\.0\.0\.1:\d+$", e)]
    need(len({c for c, e in entries}) == 5, "IT BINDINGS: classes 5 (found %d)" % len({c for c, e in entries}))
    need(not off, "IT BINDINGS: entries %d · not 127.0.0.1: %d" % (len(entries), len(off)))
    for c, (port, inner) in IT.items():
        need("%s/tcp -> 127.0.0.1:%d" % (inner, port) in [e for cc, e in entries if cc == c], "%s on 127.0.0.1:%d" % (c, port))
    val("it_entries", len(entries))
    need(re.search(r"^  mvn verify exit 0 ", t, re.M) is not None, "mvn verify exit 0")
    need(not any("TIMED OUT" in l for l in ls) and "  the Elasticsearch IT's wait: 0 timed out (S9.32)" in ls, "no IT wait timed out (S9.32)")
    need(any(l.startswith("  Testcontainers containers after: 0 ") for l in ls), "Testcontainers containers after: 0")
    libs = re.findall(r"^  (before|after): (\d+) jars", t, re.M)
    moved = [l for l in ls if l.startswith("  lib ")]
    l8 = V.get("tests.lib", "-").split("->")[-1]
    need(len(libs) == 2 and libs[0][1] == libs[1][1] == l8 and not moved and "  the jars' names moved before -> after: 0" in ls, "BOOT-INF/lib %s -> %s (U08's %s), no jar's name moved" % (libs[0][1] if libs else "-", libs[1][1] if len(libs) > 1 else "-", l8))
    al = [l for l in ls if l.startswith("  after: ")]
    for j in ("tomcat-embed-core-11.0.29.jar", "spring-core-7.0.11.jar", "spring-boot-4.1.3.jar", "springdoc-openapi-starter-webmvc-ui-3.2.1.jar", "swagger-annotations-3.0.0.jar"):
        need(al and j in al[0], "after/'s BOOT-INF/lib holds " + j)
    val("lib", "%s->%s" % (libs[0][1], libs[1][1]) if len(libs) == 2 else "-")

MAPL = re.compile(r"^  (before|after) \| ([A-Za-z]+)#(\w+) \| (\S+) \| (\S+) \| (\S+) \| (\S+)$")
OPL = re.compile(r"^  op \| ([A-Za-z]+)#(\w+) \| ([A-Z,]+) (\S+) \| (operation [A-Z]+ \S+|absent)$")
def c_census(p):
    ls = lines(p); t = "\n".join(ls); R = {"before": [], "after": []}; SD = {"before": [], "after": []}; O = []
    H = {m.group(1): tuple(int(x) for x in m.groups()[1:]) for m in re.finditer(r"^  (before|after): handler methods: (\d+) in all, (\d+) TiffinBox's \(com\.tiffinbox\), (\d+) springdoc's \(org\.springdoc\), (\d+) others", t, re.M)}
    for l in ls:
        m = MAPL.match(l)
        if m: R[m.group(1)].append(m.groups()[1:]); continue
        m2 = re.match(r"^  (before|after) springdoc \| (\S+) (\S+) (\S+)$", l)
        if m2: SD[m2.group(1)].append(m2.groups()[1:]); continue
        o = OPL.match(l)
        if o: O.append(o.groups()); continue
        if re.match(r"^  (before|after) \| ", l) or l.startswith("  op | "): fail("a census line this checker cannot parse: %r" % l[:120])
    need(set(H) == {"before", "after"}, "both flag starts read")
    if set(H) != {"before", "after"}: return
    need(R["after"] == R["before"], "TiffinBox's rows byte-equal on before and after/ (%d)" % len(R["after"]))
    need(SD["after"] == SD["before"] and H["after"][2] == len(SD["after"]) == 4, "springdoc's rows equal on both trees: %d" % len(SD["after"]))
    need(H["after"] == H["before"], "all rows equal on both trees (%d): the change adds no mapping row" % H["after"][0])
    V = u08v(); tb = H["after"][1]
    a = re.search(r"^  after/ \(this unit's tree\): mapping annotations (\d+) · dev mappings (\d+) · default run (\d+) · U08's commit 4725421: mapping annotations (\d+) · dev mappings (\d+) · default run (\d+)$", t, re.M)
    need(a is not None and a.groups()[:3] == a.groups()[3:] and (int(a.group(1)), int(a.group(2)), int(a.group(3))) == (int(V.get("census.annotations", -1)), int(V.get("census.dev_mappings", -1)), tb),
         "the partition %s · %s · %s = U08's commit's and U08's values block (annotations %s, dev %s), default run = the flag start's TiffinBox rows (%d)" % (tuple(a.groups()[:3] if a else ("-",) * 3) + (V.get("census.annotations"), V.get("census.dev_mappings"), tb)))
    if a: val("annotations", a.group(1)); val("dev_mappings", a.group(2)); val("handlers", tb)
    opsl = re.search(r"^  op document: paths (\d+) · operations (\d+) · operations no handler maps: (\d+)$", t, re.M)
    need(opsl is not None and len(O) == tb, "one handler-to-operation line per TiffinBox handler (%d)" % len(O))
    if opsl:
        absent = [o for o in O if o[4] == "absent"]; present = [o for o in O if o[4] != "absent"]
        merged = len(present) - len({o[4] for o in present}); nops = int(opsl.group(2))
        need(all(o[0] == "DashboardPage" for o in absent) and len(absent) == 3 and merged == 1, "absent: DashboardPage's three; the two PATCH handlers one operation")
        need(tb - len(absent) - merged == nops == int(V.get("census.operations", -1)), "%d - %d - %d = %d operations (U08's %s)" % (tb, len(absent), merged, nops, V.get("census.operations")))
        val("operations", nops); val("paths", int(opsl.group(1)))
    p1 = re.findall(r"^  part1 \| ([A-Z]+ \S+)$", t, re.M); p2 = re.findall(r"^  part2 \| ([A-Z]+ \S+) \| key (required|optional) \| the form passes (true|false)$", t, re.M)
    U = re.findall(r"^  union \| ([A-Z]+ \S+) \| part ([12+]+) \| documents (\S+)$", t, re.M)
    us = re.search(r"^  part \(1\) (\d+) · part \(2\) (\d+) · both (\d+) · the union (\d+) of (\d+) operations$", t, re.M)
    need(us is not None and len(p1) == int(us.group(1)) and len(p2) == int(us.group(2)) and len(U) == int(us.group(4)), "flag 3: part (1) %s · part (2) %s · both %s · the union %s, each listed" % (us.groups()[:4] if us else ("-",) * 4))
    need(sorted(p1) == sorted(["GET /customers/{name}", "GET /api/v1/customers/{name}", "PATCH /api/v1/customers/{name}", "POST /api/v1/customers/{name}/pauses", "GET /api/v1/customers/{name}/pauses/{id}"]), "part (1): the five {name} operations RED #16 named (the expectation; the print is the number)")
    need(sorted(x[0] for x in p2) == ["POST /api/v1/customers/{name}/pauses", "POST /customers"] and dict((x[0], x[1]) for x in p2) == {"POST /customers": "optional", "POST /api/v1/customers/{name}/pauses": "required"}, "part (2): POST /customers (the key optional) and the pause POST (required)")
    D = {u[0]: u[2] for u in U}
    need(all(D.get(k, "none").split(",")[0] != "none" for k, _, _ in U) and D.get("GET /api/v1/customers/{name}/pauses/{id}") == "404" and D.get("POST /customers") == "400,409,422" and D.get("POST /api/v1/customers/{name}/pauses") == "400,404,409,422",
         "every operation of the union documents its problems: the four not-found routes 404, the pause GET its own 404, POST /customers the key's 400 409 422, the pause POST 400 404 409 422 (%s)" % D)
    if us: val("part1", us.group(1)); val("part2", us.group(2)); val("union", us.group(4))
    P = re.findall(r"^  problem \| (\w+\.java):(\d+) \| (\w+|-) \| (\S+)$", t, re.M)
    need(len(P) > 0 and not any(l.startswith("  problem | ") and not re.match(r"^  problem \| \w+\.java:\d+ \| (?:\w+|-) \| \S+$", l) for l in ls), "flag 2: the problems TiffinBox constructs, listed (%d sites)" % len(P))
    typed = [x for x in P if x[3] != "about:blank"]
    need(sorted({x[3] for x in typed}) == ["CUSTOMER_NOT_FOUND", "MALFORMED", "MISSING", "OUTSTANDING", "REUSED"], "typed: the not-found and the filter's four; every other site about:blank (%d of %d)" % (len(P) - len(typed), len(P)))
    val("problem_sites", len(P)); val("problem_sites_blank", len(P) - len(typed))
    w = re.search(r"^  write handler methods \(default run\): (\d+) · the document's write operations: (\d+)$", t, re.M)
    need(w is not None, "flag 15: the write handler count and the document's write operations read")
    if w:
        print("  flag 15: write handler methods %s (Q-d's 7: %s) · the document's write operations %s" % (w.group(1), "equal" if w.group(1) == "7" else "DIFFERENT", w.group(2)))
        val("write_handlers", w.group(1)); val("write_ops", w.group(2))
    j = {m.group(1): int(m.group(2)) for m in re.finditer(r"^  (before|after)'s jar: (\d+) entries named probe/", t, re.M)}
    need(j == {"before": 0, "after": 0}, "the jars: 0 entries named probe/ on both")
    pl = re.search(r"^  plant \(one probe/ class added to a scratch copy of the jar\): (\d+) entries", t, re.M)
    need(pl is not None and int(pl.group(1)) > 0, "the plant jar holds a probe/ entry - the 0 check would FAIL on it")

def asks_of(p):
    ls, R, heads, asks = load(p); return ls, R, "\n".join(ls)
def bodyof(r):
    try: return json.loads(r["body"].rstrip("~"))
    except Exception: return None
def docread(ls, n):
    D, Rs = readdoc(ls)
    need(len(D) == n, "%d document summary line(s) read" % n)
    return D, Rs
def c_after(p):
    ls, R, t = asks_of(p); D, Rs = docread(ls, 2)
    for d in D:
        need(d[0] == "3.1.0" and (d[1], d[2]) == ("TiffinBox", "1.0") and (d[3], d[4], d[5]) == ("11", "13", "6") and d[6] == "Customer,ProblemDetail,SseEmitter", "the document: 3.1.0 · TiffinBox/1.0 · 11 paths · 13 operations · 6 tags · schemas Customer, ProblemDetail, SseEmitter")
        need(d[7] == d[8] == "absent" and d[10] == "0", "the document: no securitySchemes, no security member, the key header named 0 times")
    need(len(D) == 2 and D[0] == D[1] and Rs[0] == Rs[1], "PostgreSQL's and H2's documents say the same")
    need("byte-identical · = the committed file: pg byte-identical · h2 byte-identical" in t, "servers removed: PostgreSQL = H2 = the committed file, byte for byte")
    for k, r in R.items():
        if k.startswith("a-"): need(r["st"] == "200", "%s %s -> 200" % (r["m"], r["p"]))
    if D: val("openapi", D[0][0]); val("info", "%s/%s" % D[0][1:3]); val("paths", D[0][3]); val("operations", D[0][4]); val("tags", D[0][5]); val("error_responses", D[0][9]); val("pg_equal", "yes")
def nobodycheck(R, side):
    out = {}
    for k in ("old", "public", "patch", "pause", "pauseget"):
        r = R.get("nb-%s-%s" % (side, k))
        if not r: fail("%s: nb-%s missing" % (side, k)); continue
        out[k] = (r["st"], r["ct"], bodyof(r))
    return out
def c_none(p):
    ls, R, t = asks_of(p); D, Rs = docread(ls, 1)
    if D:
        d = D[0]
        need((d[1], d[2]) == ("TiffinBox", "1.0") and (d[3], d[4], d[5]) == ("11", "13", "6") and d[6] == "Customer,SseEmitter" and d[9] == "0" and d[10] == "0" and d[7] == d[8] == "absent",
             "before's document: TiffinBox/1.0 · 11 / 13 / 6 · schemas Customer, SseEmitter · error responses 0 · the key named 0 · no securitySchemes, no security")
        need(all(v == ["200"] for v in Rs[0].values()) and len(Rs[0]) == 13, "every one of the 13 operations documents 200 alone")
        V = u08v(); need(V.get("diff.errors_documented") == "0" and V.get("diff.key_named") == "0", "= U08's values block: errors_documented=0 key_named=0")
    N = nobodycheck(R, "before")
    for k in ("old", "public", "patch"):
        if k in N: need(N[k][0] == "404" and N[k][1] == PJ and N[k][2] and "type" not in N[k][2] and N[k][2].get("title") == "Customer not found" and N[k][2].get("name") == "Nobody", "before %s: 404 problem, Customer not found, name Nobody, no type member (about:blank)" % k)
    if "pause" in N: need(N["pause"][0] == "400" and N["pause"][2] and N["pause"][2].get("type") == KEYT["missing"], "before pause POST without a key: the filter's 400, typed missing")
    if "pauseget" in N: need(N["pauseget"][0] == "404" and N["pauseget"][2] and "type" not in N["pauseget"][2] and "name" not in N["pauseget"][2], "before pause GET: its own 404, about:blank, no name")
    val("before_errors", D[0][9] if D else "-")
def c_blanket(p):
    ls, R, t = asks_of(p)
    need(re.search(r"^  diff: > +@org\.springframework\.web\.bind\.annotation\.ResponseStatus\(HttpStatus\.NOT_FOUND\)", t, re.M) is not None and len(re.findall(r"^  diff: ", t, re.M)) == 1, "the plant's diff: one line added, the @ResponseStatus on the advice's handler")
    m = re.search(r"^  blanket: operations documenting a four-oh-four: (\d+) of (\d+)$", t, re.M)
    need(m is not None and m.group(1) == m.group(2) == "13", "the document with the plant: %s of %s operations document a four-oh-four" % (m.groups() if m else ("-", "-")))
    B = re.findall(r"^  blanket \| ([A-Z]+ \S+) \| responses (\S+) \| 404 (.*)$", t, re.M)
    need(len(B) == 3 and all("404" in x[1].split(",") for x in B), "the hook's three (GET /revenue, GET /kitchen, POST /shutdown) each document a four-oh-four")
    W = {k: R.get(k, {}).get("st") for k in ("bl-revenue", "bl-kitchen", "bl-nobody")}
    need(W == {"bl-revenue": "200", "bl-kitchen": "200", "bl-nobody": "404"}, "the same mirror's wire: /revenue 200, /kitchen 200, Nobody 404 - documented a four-oh-four, answered two hundred")
    if m: val("blanket", "%s/%s" % m.groups())
    val("revenue_wire", W.get("bl-revenue"))
def c_perop(p):
    ls = lines(p); t = "\n".join(ls)
    C = re.findall(r"^  codes \| ([A-Z]+ \S+) \| before (\S+) \| after (\S+) \| (\S+)$", t, re.M)
    need(len(C) == 13, "the code table: 13 operations")
    moved = sorted(k for k, b, a, d in C if d != "equal")
    need(moved == sorted(["GET /customers/{name}", "GET /api/v1/customers/{name}", "PATCH /api/v1/customers/{name}", "POST /api/v1/customers/{name}/pauses", "GET /api/v1/customers/{name}/pauses/{id}", "POST /customers"]), "the operations that gained responses = flag 3's union (6), every other one equal: %s" % moved)
    need(all(b == "200" and a.startswith("200") for k, b, a, d in C), "every operation keeps its 200 first, as before")
    m = re.search(r"^  strip: before \(info, servers removed\) md5 ([0-9a-f]{32}) · after \(.*\) md5 ([0-9a-f]{32}) · (EQUAL|MOVED)$", t, re.M)
    need(m is not None and m.group(3) == "EQUAL" and re.search(r"^  strip exit 0$", t, re.M) is not None, "flag 9 (a): the documents with info, servers, the added responses and ProblemDetail removed hash the same (%s)" % (m.group(1)[:8] if m else "-"))
    W = os.path.join(os.path.dirname(os.path.abspath(p)), ".harness", "work")
    if m and os.path.exists(os.path.join(W, "spec-before.raw")):
        b, a, added, extra = strip_added(jload(os.path.join(W, "spec-before.raw")), jload(os.path.join(W, "spec-h2.raw")))
        need(hashlib.md5(fixed(b).encode()).hexdigest() == m.group(1) and hashlib.md5(fixed(a).encode()).hexdigest() == m.group(2), "the hashes READ BACK: this checker hashed the two saved documents again itself and got the printed md5s")
        need(extra == ["ProblemDetail"], "components gains ProblemDetail and nothing else")
    ad = re.findall(r"^  added \| ([A-Z]+ \S+) (\d{3})$", t, re.M)
    na = re.search(r"^  added responses (\d+) · new schemas (\S+) · info before (.*) · info after (.*)$", t, re.M)
    need(na is not None and int(na.group(1)) == len(ad) and na.group(2) == "ProblemDetail" and json.loads(na.group(3)) == json.loads(na.group(4)) == INFO, "flag 9 (b)/(c): %s added responses listed, ProblemDetail the one new schema, info TiffinBox/1.0 on both" % (na.group(1) if na else "-"))
    need(re.search(r"^  swagger-config: before ([0-9a-f]{32}) · after \1 ", t, re.M) is not None, "swagger-config equal after the port mask")
    y = re.search(r"^  the YAML: before (\d+) lines · after (\d+) lines · removed lines (\d+)$", t, re.M)
    need(y is not None and y.group(3) == "0" and int(y.group(2)) > int(y.group(1)), "the YAML: lines added only (%s -> %s, removed %s)" % (y.groups() if y else ("-",) * 3))
    for k, w in (("description", "paths"), ("schema", "components"), ("securitySchemes", "components")):
        need(re.search(r"^  plant %s: strip exit 1 · MOVED member %s" % (k, w), t, re.M) is not None, "plant %s: strip exit 1, naming the member (%s)" % (k, w))
    need(re.search(r"^  plant empty input: strip exit 2 · refused: an empty input$", t, re.M) is not None, "plant empty input: exit 2")
    ab = re.search(r"^  abdiff: A \(after/, the annotations\) md5 ([0-9a-f]{32}) · B \(the loser mirror, the customizer\) md5 ([0-9a-f]{32}) · the bytes (\w+) · as JSON (\w+)$", t, re.M)
    need(ab is not None, "the loser (B) measured: its document beside A's, both md5s printed")
    if ab:
        dl = re.findall(r"^  abdiff \| (.*)$", t, re.M)
        print("  flag 4's pre-stated test: A's document equals the census's expectation (above) and B's differs from A's by %s -> %s" % ("nothing" if ab.group(3) == "equal" else "%d line(s) (as JSON: %s)" % (len(dl), ab.group(4)), "ship A" if ab.group(4) == "equal" else "ship A (B differs; A expresses every member the receipt needs) - the difference filed"))
        val("loser_bytes", ab.group(3)); val("loser_json", ab.group(4))
    if na: val("added_responses", na.group(1))
    if m: val("rest_md5", m.group(1)[:8])
    val("ops_moved", len(moved)); val("ops_equal", 13 - len(moved))
def c_shape(p):
    ls = lines(p); t = "\n".join(ls)
    E = re.findall(r"^  example \| ([A-Z]+ \S+ \d{3} \S+) \| (\S+) \| (.*)$", t, re.M)
    s = re.search(r"^  examples (\d+) · equal to a filed wire body (\d+) · not (\d+)$", t, re.M)
    need(s is not None and s.group(3) == "0" and int(s.group(1)) == len(E) and re.search(r"^  examples exit 0$", t, re.M) is not None, "flag 6: every example (%s) equal to a body the wire sent and this run filed" % (s.group(1) if s else "-"))
    need(all("NO FILED BODY" not in x[2] for x in E), "no example without a filed body")
    sc = re.search(r"^  the wire sends, the schema does not list at its top level: (\S+) \((\d+)\) · the schema lists, the wire never sends: (\S+) \((\d+)\)$", t, re.M)
    need(sc is not None and sc.group(1) == "errors,name" or (sc is not None and "name" in sc.group(1).split(",")), "flag 5: the wire sends name at the top level, the schema does not list it (%s)" % (sc.group(1) if sc else "-"))
    need(sc is not None and sc.group(3) == "properties", "flag 5: the schema lists properties, the wire never sends it")
    pr = re.search(r"^  plant rename \(detail -> details in the schema\): the wire sends, the schema does not list at its top level: (\S+) \((\d+)\) · the schema lists, the wire never sends: (\S+) \((\d+)\)$", t, re.M)
    need(pr is not None and sc is not None and int(pr.group(2)) == int(sc.group(2)) + 1 and int(pr.group(4)) == int(sc.group(4)) + 1, "the plant (one member renamed) moves each count by exactly one")
    need(re.search(r"^  plant status one off: examples exit 1 · example \| GET /api/v1/customers/\{name\} 404 ", t, re.M) is not None, "an example's status one off: FAIL naming it")
    need(re.search(r"^  plant empty input: schema exit 2 ", t, re.M) is not None, "an empty input: exit 2")
    if s: val("examples", s.group(1))
    if sc: val("wire_not_schema", sc.group(1)); val("schema_not_wire", sc.group(3))
def c_types(p):
    ls, R, t = asks_of(p)
    N = nobodycheck(R, "after")
    for k in ("old", "public", "patch"):
        if k in N: need(N[k][0] == "404" and N[k][2] and N[k][2].get("type") == TYPE and N[k][2].get("name") == "Nobody", "after %s: 404, type %s, name Nobody" % (k, TYPE))
    if "pauseget" in N: need(N["pauseget"][0] == "404" and N["pauseget"][2] and "type" not in N["pauseget"][2], "after pause GET: its own 404, still about:blank")
    BD = re.findall(r"^  body \| (\S+) \| (moved, additive: .*|equal)$", t, re.M)
    D = dict(BD)
    for k in ("nf-customers", "nf-public", "nf-patch"):
        need(D.get(k, "").startswith('moved, additive: +"type":"%s", every other member byte-equal' % TYPE), "S9.37: %s moved, additive (+type), every other member byte-equal" % k)
    need(D.get("pauseget-404") == "equal", "the pause GET's own 404: equal before and after")
    kn = R.get("key-nobody"); km = R.get("key-missing"); kf = R.get("key-malformed"); r1 = R.get("key-reused-1"); r2 = R.get("key-reused-2")
    need(kn and kn["st"] == "404" and bodyof(kn) and bodyof(kn).get("type") == TYPE, "the keyed pause POST to Nobody: 404, the not-found type (the fourth CustomerNotFound route)")
    need(km and km["st"] == "400" and bodyof(km) and bodyof(km).get("type") == KEYT["missing"], "no key: 400, missing")
    need(kf and kf["st"] == "400" and bodyof(kf) and bodyof(kf).get("type") == KEYT["malformed"], "an unquoted key: 400, malformed")
    need(r1 and r2 and r1["st"] == "201" and r2["st"] == "422" and bodyof(r2) and bodyof(r2).get("type") == KEYT["reused"], "the reused pair: 201, then 422 reused")
    k0 = re.search(r"the second client after the keyed Nobody POST: keys (\d+)", t); k1 = re.search(r"the second client after the reused pair: count (\d+) .* · keys (\d+)", t)
    need(k0 is not None and k0.group(1) == "0" and k1 is not None and k1.group(2) == "1", "the key table: 0 after the keyed Nobody POST (the claim deleted), 1 after the reused pair")
    ko = R.get("key-outstanding"); k2 = re.search(r"the second client after the outstanding request: count (\d+) .* · keys (\d+)", t)
    need(re.search(r'the harness\'s route\): \{"rows":1\}$', t, re.M) is not None, "the harness's plant row written (1 row)")
    need(ko and ko["st"] == "409" and bodyof(ko) and bodyof(ko).get("type") == KEYT["outstanding"], "an in-flight claim under the same fingerprint: 409, outstanding")
    need(k2 is not None and k2.group(2) == "2" and k1 is not None and k2.group(1) == k1.group(1), "the key table 2 after it (the stored row and the plant row), no customer row moved")
    S = re.findall(r"^  should \| (\S+) \| (\d+) \| (\S+) \| (.*?) \| the phrase (.*?) \| (.*)$", t, re.M)
    s = re.search(r"^  should: bodies (\d+) · about:blank (\d+) \(title = the phrase (\d+), not (\d+)\) · typed (\d+)$", t, re.M)
    need(s is not None and len(S) == int(s.group(1)), "flag 14: the SHOULD table, one row per body (%s)" % (s.group(1) if s else "-"))
    need(re.search(r"^  RFC :497\+\d+:.*SHOULD", t, re.M) is not None, "the SHOULD quoted from the filed copy's lines 498-515 only")
    if s: val("should_rows", s.group(1)); val("should_blank", s.group(2)); val("should_blank_not_phrase", s.group(4)); val("should_typed", s.group(5))
    ty = re.search(r"^  type (tag:\S+) \(static final URI CUSTOMER_NOT_FOUND, TiffinBoxErrors; no '//': yes\)", t, re.M)
    need(ty is not None and ty.group(1) == TYPE, "flag 11: the constant read off the source, no '//' in it")
    rv = re.search(r"^  mvn test exit (\d+) · Tests run: (\d+), Failures: (\d+), Errors: (\d+)", t, re.M)
    F = re.findall(r"^  failed: (\w+)\.(\w+)$", t, re.M)
    need(rv is not None and rv.group(1) == "1" and int(rv.group(3)) + int(rv.group(4)) == 4 and sorted(F) == sorted([(c, "aNameNobodyHasIsTyped") for c in ("CustomerPatchesTest", "CustomerReadsTest", "IdempotencyKeyTest", "TiffinBoxWebTest")]),
         "the plant (setType reverted): exactly the k = 4 new tests fail (%s)" % ",".join("%s.%s" % f for f in F))
    val("type", "customer-not-found"); val("routes_typed", 4); val("revert_fail", len(F))
def c_committed(p):
    ls = lines(p); t = "\n".join(ls)
    m = re.search(r"^  bytes (\d+) \(wc -c\) · md5 ([0-9a-f]{32}) · servers member: (\w+) · U08's file (\d+) B$", t, re.M)
    need(m is not None and m.group(3) == "absent", "(i) the file: %s bytes (wc -c), no servers" % (m.group(1) if m else "-"))
    need(re.search(r"re-applied to the file: byte-identical$", t, re.M) is not None, "(i) the fixed rule re-applied reproduces the file")
    need(re.search(r"^  the file against the served document, servers removed \(the after capture's python, live\): pg byte-identical · h2 byte-identical$", t, re.M) is not None, "(i) the file = the served document with servers removed, on PostgreSQL and H2")
    d = re.search(r"^  its diff against U08's \(= 4725421's\) file: (\d+) lines added · (\d+) removed$", t, re.M)
    need(d is not None and d.group(2) == "0" and int(d.group(1)) > 0, "(i) the diff against U08's file: additions only (%s added)" % (d.group(1) if d else "-"))
    u = re.search(r"^  the file with the added responses and ProblemDetail removed: md5 ([0-9a-f]{32}) · U08's file md5 ([0-9a-f]{32})$", t, re.M)
    need(u is not None and u.group(1) == u.group(2), "(i) the file minus its additions = U08's file byte for byte (md5 %s)" % (u.group(1)[:8] if u else "-"))
    need("  the file: securitySchemes absent · security absent" in ls, "(i) the file: no securitySchemes, no security member")
    need(re.search(r"^  package:  OpenApiSpecTest tests 1 failures 0 errors 0 skipped 0$", t, re.M) is not None and re.search(r"^  twin:  OpenApiSpecTest tests 1 failures 0 errors 0 skipped 0$", t, re.M) is not None, "(ii) OpenApiSpecTest PASSES on the regenerated file, package and twin")
    for k, n, w in (("iii", "the stale file", "responses True"), ("iv", "the drifted file", "mealsPerDay True"), ("v", "the drifted code", "maxLength True"), ("vi", "the moved four-oh-four", "410 True")):
        sec = t.split("== (%s)" % k)[1].split("\n== ")[0] if "== (%s)" % k in t else ""
        need(re.search(r"mvn test -Dtest=OpenApiSpecTest exit 1 · Tests run: 1, Failures: 1, Errors: 0", sec) is not None, "(%s) %s: the test FAILS (exit 1, Failures 1)" % (k, n))
        need("its FAIL line: theServedDocumentIsTheCommittedOne" in sec, "(%s) its FAIL line kept" % k)
        need(w in sec, "(%s) the report names what moved (%s)" % (k, w))
    if m: val("spec_bytes", m.group(1)); val("spec_md5", m.group(2)[:8]); val("spec_bytes_u08", m.group(4))
    if d: val("lines_added", d.group(1))
    val("test", "PASS"); val("stale", "FAIL"); val("drift_file", "FAIL"); val("drift_code", "FAIL"); val("drift_moved404", "FAIL")
def c_diff(p):
    ls, R, heads, asks = load(p); t = "\n".join(ls)
    P = [PAIR.match(l) for l in ls if l.startswith("  pair ")]
    need(len(P) == 12 and all(P), "the twelve filed pairs read")
    P = [x for x in P if x]
    need([x.group(1) for x in P if x.group(5) == "yes"] == ["pause-key"], "the key header sent by pause-key alone")
    K = {m.group(1): (int(m.group(2)), m.group(3)) for m in (KINDS.match(l) for l in ls) if m}
    Dn = {m.group(1): int(m.group(2)) for m in (DIS.match(l) for l in ls) if m}
    rows = collections.defaultdict(list)
    for l in ls:
        m = ROWL.match(l)
        if m: rows[m.group(1)].append((m.group(3), m.group(4), m.group(5)))
    need("a" in K and "b" in K and len(rows["a"]) == Dn.get("a") and len(rows["b"]) == Dn.get("b"), "(a) and (b): KINDS and DISAGREEMENTS read, one row line per disagreement")
    V = u08v()
    ka, ra, kb, rb = int(V.get("diff.kinds_a", -1)), int(V.get("diff.rows_a", -1)), int(V.get("diff.kinds_b", -1)), int(V.get("diff.rows_b", -1))
    if "a" in K and "b" in K:
        print("  specwire9 (a): before %d kinds / %d rows (U08's values block; re-measured on this anchor's before by U08) -> after %d / %d · delta %+d kinds / %+d rows" % (ka, ra, K["a"][0], Dn["a"], K["a"][0] - ka, Dn["a"] - ra))
        print("  specwire9 (b): before %d / %d -> after %d / %d · delta %+d / %+d" % (kb, rb, K["b"][0], Dn["b"], K["b"][0] - kb, Dn["b"] - rb))
        print("  (a)'s kinds after: %s" % K["a"][1])
        need("error responses" not in K["a"][1] and not any(r[0] == "error responses" for r in rows["a"]), "the error-responses kind: gone from (a) after (the document now documents the wire's four-hundreds)")
        need(any(r[0].endswith(" header") for r in rows["a"]), "the required-header row stays (the key still not named as a header)")
        need(any(r[0] == "required" for r in rows["a"]), "required 2 of 4 stays a row")
        val("kinds_a", K["a"][0]); val("rows_a", Dn["a"]); val("kinds_b", K["b"][0]); val("rows_b", Dn["b"]); val("delta_a", "%+d/%+d" % (K["a"][0] - ka, Dn["a"] - ra)); val("delta_b", "%+d/%+d" % (K["b"][0] - kb, Dn["b"] - rb))
    pa = re.search(r"^  plant \(a\) KINDS (\d+):", t, re.M); pda = re.search(r"^  plant \(a\) DISAGREEMENTS (\d+)$", t, re.M)
    pb = re.search(r"^  plant \(b\) KINDS (\d+):", t, re.M); pdb = re.search(r"^  plant \(b\) DISAGREEMENTS (\d+)$", t, re.M)
    need(pa and pda and pb and pdb and int(pa.group(1)) == K["a"][0] + 1 and int(pda.group(1)) == Dn["a"] + 1 and int(pb.group(1)) == K["b"][0] + 1 and int(pdb.group(1)) == Dn["b"] + 1, "the plant (mealType -> meal_type) moves the kinds and the rows by exactly one in (a) and (b) (R.508)")
    need(re.search(r"^  empty: exit 2$", t, re.M) is not None, "an empty wire directory: exit 2")
    b_ = re.search(r"^  the second client before: count (\d+) .* · keys (\d+) ", t, re.M); a_ = re.search(r"^  the second client after: count (\d+) .* · keys (\d+) ", t, re.M)
    need(b_ and a_ and b_.group(2) == "0" and a_.group(2) == "1" and int(a_.group(1)) == int(b_.group(1)) + 1, "the second client: one customer more (the valid POST), the key table 0 -> 1 (pause-key)")
    W = {a["lab"]: a for a in asks}
    need(W.get("w-v3-api-docs", {}).get("st") == "200" and W.get("w-nobody", {}).get("st") == "404", "the witness asked the document (200) and Nobody (404)")
    hd = {k: ([s["h"] for s in v["srv"] if s["disp"] is None] or ["none"])[0] for k, v in W.items()}
    print("  the request witness: %s" % " · ".join("%s -> %s %s" % (W[k]["p"], W[k]["st"], hd[k]) for k in W))
    val("key_named", 0)
def c_scheme(p):
    ls, R, t = asks_of(p)
    D, Rs = readdoc(ls)
    need(len(D) == 1 and D[0][7] == "present" and D[0][8] == "present", "the copy's document: securitySchemes present, a security member present")
    need('"bearer": {"type": "http", "scheme": "bearer", "bearerFormat": "JWT"}' in t, "the copy's scheme: bearer, http, JWT")
    a, b = R.get("sc-anon"), R.get("sc-bearer")
    need(a and b and a["st"] == b["st"] == "200", "GET Ravi with no credential: 200; with Bearer not-a-token: 200")
    m = re.search(r"^  the bodies: anonymous ([0-9a-f]{32}) · bearer ([0-9a-f]{32}) · after/'s own \(.*\) ([0-9a-f]{32}) · the probe's anon\.b \(the figure to compare\) (\S*)$", t, re.M)
    need(m is not None and m.group(1) == m.group(2) == m.group(3), "both bodies = after/'s own (md5 %s); the probe's figure %s (compared, not asserted)" % ((m.group(1)[:8], m.group(4)[:8]) if m else ("-", "-")))
    g = re.search(r"^  every request of the copy's JVM a GET \(the access log\): (.*)$", t, re.M)
    need(g is not None and re.fullmatch(r"GET \d+", g.group(1).strip()) is not None, "GET only: no write sent from the copy (%s)" % (g.group(1) if g else "-"))
    need("  the shipped document beside it (the after capture's H2 document): securitySchemes absent · security absent" in ls, "the shipped document: none yet")
    ds = re.search(r"^  the start: (.*)$", t, re.M)
    need(ds is not None, "the probe's own DeclaredScheme start: its outcome printed (%s)" % (ds.group(1) if ds else "-"))
    if ds: val("declared_scheme_start", "started" if ds.group(1).startswith("Started") else "refused")
    if m: val("anon", "200"); val("bearer", "200"); val("body_md5", m.group(1)[:8])
    val("shipped", "none")
MVL = re.compile(r"^  (before|after) \| ([A-Z]+ \S+(?: \[[\w-]+\])?) -> (\d{3}) (\S*) (\d+) · Allow \{([^}]*)\} · Accept-Patch \{([^}]*)\} · Location \{([^}]*)\} · body (\S+)$")
MOVES = ["GET /v3/api-docs", "GET /v3/api-docs.yaml", "GET /customers/Nobody", "GET /api/v1/customers/Nobody", "PATCH /api/v1/customers/Nobody [merge]"]
def c_moved(p):
    ls = lines(p); M = {}
    for l in ls:
        m = MVL.match(l)
        if m: M[(m.group(1), m.group(2))] = m.groups()[2:]
        elif l.startswith("  before |") or l.startswith("  after |"): fail("a moved line this checker cannot parse: %r" % l[:120])
    qs = sorted({k[1] for k in M})
    need(len(qs) == 19 and all(("before", q) in M and ("after", q) in M for q in qs), "every request asked on both trees (%d: U08's fourteen + five Nobody requests)" % len(qs))
    moved = [q for q in qs if M.get(("before", q)) != M.get(("after", q))]
    need(sorted(moved) == sorted(MOVES), "moved: exactly the document, its YAML and the three CustomerNotFound bodies a harness-free start reaches (S9.37): %s" % moved)
    for q in moved:
        print("  MOVED (named in this unit) %s: before %s -> after %s" % (q, " ".join(M[("before", q)][:3]) + " body " + M[("before", q)][-1], " ".join(M[("after", q)][:3]) + " body " + M[("after", q)][-1]))
        need(M[("before", q)][:2] == M[("after", q)][:2], "%s: status and type equal, the body moved" % q)
    for q in ("GET /v3/api-docs/swagger-config", "GET /api/v1/customers/Nobody/pauses/1", "POST /api/v1/customers/Nobody/pauses?days=1"): need(q in qs and q not in moved, "%s: equal on both trees" % q)
    a = M.get(("after", "PATCH /customers")); b = M.get(("before", "PATCH /customers"))
    need(a is not None and b is not None and a[0] == b[0] == "405" and a[3] == b[3] == "GET,POST", "the pinned sentence: a PATCH to /customers answers 405, Allow {GET, POST}, on before and after/")
    val("asked", len(qs)); val("moved", len(moved)); val("unmoved", len(qs) - len(moved))
def c_seven(p):
    ls = lines(p); t = "\n".join(ls)
    S = re.search(r"the expected ([0-9a-f]{32})", t)
    if not S: fail("the expected hash"); return
    for side in ("before", "after"):
        m = re.search(r"^  %s: the seven ([0-9a-f]{32}) " % side, t, re.M)
        need(m is not None and m.group(1) == S.group(1), "%s: the seven = %s" % (side, S.group(1)[:8]))
        q = re.search(r"^  %s: the seven's requests \(the access log, a harness-free start\): (.*)$" % side, t, re.M)
        need(q is not None and "Nobody" not in q.group(1) and "/v3/" not in q.group(1), "%s: the seven send no Nobody request and reach no springdoc address" % side)
    need("  before -> after/: equal" in ls, "the seven: before = after/")
    need(u08v().get("seven.seven") == S.group(1)[:8], "= U08's values block (seven=%s)" % u08v().get("seven.seven"))
    print("  R.511: not a witness for this change - the seven send no Nobody request and reach no springdoc handler, so they stay equal")
    val("seven", S.group(1)[:8])
def c_surface(p):
    ls = lines(p); t = "\n".join(ls)
    S = re.search(r"the expected ([0-9a-f]{32})", t)
    if not S: fail("the expected hash"); return
    for side in ("before", "after"):
        m = re.search(r"^  %s: the old surface ([0-9a-f]{32}) \((\d+) requests, (\d+) lines\)$" % side, t, re.M)
        need(m is not None and m.group(1) == S.group(1), "%s: the old surface = %s" % (side, S.group(1)[:8]))
    need("  before -> after/: equal" in ls and not any(l.startswith("    moved: ") for l in ls), "the old surface: before = after/, no line moved")
    need(u08v().get("surface.surface") == S.group(1)[:8], "= U08's values block (surface=%s)" % u08v().get("surface.surface"))
    need(any("planted: the seven" in l and "unchanged: yes" in l and "moved: yes" in l for l in ls), "the ETag plant (the harness's): the seven unchanged, the old surface moved")
    w = re.search(r"^  wide: the seven ([0-9a-f]{32}) \(moved against the expected: (\w+)\) · the moved lines: (\d+)$", t, re.M)
    need(w is not None and w.group(2) == "NO", "the wide plant (a type on /shutdown's 403): the seven's md5 does NOT move - the seven send no token-less POST /shutdown (their two /shutdown requests are a GET, 405, and a POST with the token, 200): the prompt's premise, measured false")
    ws = re.search(r"^  wide: the old surface ([0-9a-f]{32}) \(moved against the expected: (\w+)\) · the moved lines: (\d+)$", t, re.M)
    need(ws is not None and ws.group(2) == "yes" and int(ws.group(3)) > 0, "the wide plant: the old surface moves (%s line(s)) - its last request, POST /shutdown with no token, answers the 403: the surface is the witness a wider change would reach" % (ws.group(3) if ws else "-"))
    val("wide_seven", "equal"); val("wide_surface", "moved")
    print("  R.511: witness for this change: the document's requests and the Nobody requests (perop, types, moved); not a witness: the old surface's thirteen and the seven - they do not reach it")
    val("surface", S.group(1)[:8])
def c_inert(p):
    ls = lines(p); t = "\n".join(ls)
    K = {}
    for m in re.finditer(r"^  \.r-(\w+)\.new: sent the key: (\d+) \((\S*)\) · did not: (\d+)$", t, re.M): K[m.group(1)] = (int(m.group(2)), m.group(3))
    need(set(K) == {"after", "none", "blanket", "types", "diff", "scheme"}, "every curl capture read (%s)" % ",".join(sorted(K)))
    need(all(v[0] == 0 for k, v in K.items() if k != "types") and K.get("types", (0, ""))[1].split(",") == ["key-malformed", "key-nobody", "key-reused-1", "key-reused-2", "key-outstanding"], "the key header: only the keyed companion's five named requests (%s) and specwire9's pause-key" % K.get("types", ("", "-"))[1])
    m = re.search(r"^  wire-h2: requests (\d+) · with the key: (\S+)$", t, re.M)
    need(m is not None and m.group(2) == "pause-key", "wire-h2: the key header on pause-key alone")
    val("keyed", "pause-key+companion5")
def c_exercise(p):
    ls = lines(p)
    def blk(v, sh):
        out = []; on = False
        for l in ls:
            if l.startswith("== the exercise, h2, %s, %s " % (v, sh)): on = True; continue
            if on and l.startswith("=="): break
            if on and not l.startswith("  guard before "): out.append(l[2:])
        return out
    want = {"broken": ("FAIL (clause 1)", "1"), "solved": ("PASS", "0")}
    for v, (pre, ex) in want.items():
        for sh in ("bash", "zsh"):
            b = blk(v, sh)
            need(any(x.startswith(pre) for x in b) and "check exit %s" % ex in b, "%s (%s): %s, exit %s" % (v, sh, pre, ex))
    for v in ("broken", "solved"): need(blk(v, "bash") == blk(v, "zsh"), "%s: bash and zsh -f print the same" % v)
    need(blk("broken", "bash") != blk("solved", "bash"), "broken != solved")
    ref = {"blanket": "FAIL (clause 1)", "oldroute": "FAIL (clause 1)", "both": "FAIL (clause 1)", "pauseget": "FAIL (clause 1)", "noschema": "FAIL (clause 2)", "nofile": "FAIL (clause 5)", "handedit": "FAIL (clause 1)"}
    ran = [v for v in ref if blk(v, "bash")]
    for v in ran: need(any(x.startswith(ref[v]) for x in blk(v, "bash")) and "check exit 1" in blk(v, "bash"), "refused %s: %s" % (v, ref[v]))
    need(len(ran) == len(ref) or any(l.startswith("== the refused variants: run 1/1") for l in ls), "the refused variants: %d run here (else run 1's)" % len(ran))
    rd = [l[len("  README: "):] for l in ls if l.startswith("  README: ")]; so = [l[len("  SOLUTION: "):] for l in ls if l.startswith("  SOLUTION: ")]
    need([x for x in blk("broken", "bash") if not x.startswith("check exit")] == rd, "exercise/README.md's What it prints = the broken run's lines")
    need([x for x in blk("solved", "bash") if not x.startswith("check exit")] == so, "SOLUTION.md's What it prints = the solved run's lines")
    val("exercise", "broken-FAIL1,solved-PASS,refused-7,bash+zsh,h2")

CAPS = {"tests": c_tests, "census": c_census, "after": c_after, "none": c_none, "blanket": c_blanket, "perop": c_perop, "shape": c_shape, "types": c_types,
        "committed": c_committed, "diff": c_diff, "scheme": c_scheme, "moved": c_moved, "seven": c_seven, "surface": c_surface, "inert": c_inert, "exercise": c_exercise}
def capture(nm, p):
    if nm in CAPS: CAPS[nm](p)
    else: fail("no checks for the capture %r" % nm)
    done()

def hashable(nm, p):
    for l in lines(p):
        if re.match(r"^  guard before ", l): continue
        if l.startswith("  Testcontainers' containers while verify ran"): continue
        if nm == "exercise" and l.startswith("== the refused variants: run 1/1"): continue
        if nm == "exercise" and re.match(r"^== the exercise, h2, (blanket|oldroute|both|pauseget|noschema|nofile|handedit), ", l): HSKIP[0] = True; continue
        if nm == "exercise" and HSKIP[0]:
            if l.startswith("=="): HSKIP[0] = False
            else: continue
        l = re.sub(r"load1 [0-9.]+", "load1 <n>", l)
        l = re.sub(r"\bBLUE_RUN=\d+", "BLUE_RUN=<N>", l)
        l = re.sub(r"\b(Blue\d)r\d+\b", r"\1r<N>", l)
        l = re.sub(r"blue-specwire-\d+", "blue-specwire-<N>", l)
        l = re.sub(r"(\"(?:id|version|ts)\":)\d+", r"\1<n>", l) if nm == "diff" and l.startswith("  pair ") else l
        print(l)
HSKIP = [False]

def values(readme, vals):
    t = open(readme, encoding="utf-8").read()
    m = re.search(r"<!-- values: begin -->\n```\n(.*?)\n```\n<!-- values: end -->", t, re.S)
    if not m:
        print("FAIL README.md has no values block"); [print("VALS| " + l) for l in vals.splitlines()]; sys.exit(1)
    if m.group(1).strip() != vals.strip():
        print("FAIL the values block differs from this run's:"); [print("VALS| " + l) for l in vals.splitlines()]; sys.exit(1)
    print("ok the values block = this run's")

if __name__ == "__main__":
    a = sys.argv[1:]
    try:
        M = {"static": lambda: static(a[1], a[2]), "hook": lambda: print(HOOK), "exq": lambda: print(EXQ), "gloss-line": lambda: print(GLOSS), "gloss": lambda: gloss(a[1]),
             "spoken": lambda: spoken(a[1], a[2]), "specmask": lambda: specmask(sys.stdin), "surefire": lambda: surefire(a[1]), "mapjson": lambda: mapjson(a[1], sys.stdin),
             "opsmap": lambda: ops(a[1], a[2]), "pairs": lambda: pairs(a[1]), "hashable": lambda: hashable(a[1], a[2]), "values": lambda: values(a[1], a[2]),
             "docsum": lambda: docsum(a[1]), "nameset": lambda: nameset(a[1]), "keyset": lambda: keyset(a[1]), "union": lambda: union(a[1], a[2]), "strip": lambda: strip(a[1], a[2]),
             "examples": lambda: examples(a[1], a[2]), "schema": lambda: schema(a[1], a[2]), "count404": lambda: count404(a[1]), "codetable": lambda: codetable(a[1], a[2]),
             "plantdoc": lambda: plantdoc(a[1], a[2], a[3]), "bodydiff": lambda: bodydiff(a[1], a[2], a[3]), "should": lambda: should(a[1]), "typeconst": lambda: typeconst(a[1]),
             "unadd": lambda: unadd(a[1], a[2]), "rnames": lambda: rnames(a[1]), "abdiff": lambda: abdiff(a[1], a[2])}
        if a and a[0] in M: M[a[0]]()
        elif a: capture(a[0], a[1])
        else: print(__doc__); sys.exit(2)
    except SystemExit:
        raise
    except Exception as e:
        print("FAIL the checker could not read its input (%s: %s) - a FAIL line, never a traceback" % (e.__class__.__name__, str(e)[:120])); sys.exit(1)
