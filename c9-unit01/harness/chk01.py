"""Course 9 unit 01's checker (python3 -I -B harness/chk01.py MODE ...). Every number the README may say is re-derived here from a capture's
own lines (or a shipped file), never typed. Each listing line a check reads is parsed by a named pattern or skipped by a named rule; a line
it cannot parse is a FAIL line and exit 1, never a traceback. Modes:
  static SETC                 the prose gate's carried slices (s901.py against U04's s904.py), the set-up filter's classes, the dev routes
  spoken HOOK EXQ             the two spoken lines: words, the hook's number word, digits, spellings, statuses, Hinglish, dur9
  linkcount FILE CT           links and forms in one answer's body (HTML by html.parser; JSON by its keys)
  mapread JSON SETC           the flag run's /actuator/mappings: every handler method, the totals, the hook's count by two derivations
  view KIND PG H2 MAPPINGS    the stateless / cache / links tables, read off both census captures (and the flag run's rows)
  <capture> FILE              one capture's checks; prints ok/FAIL lines and one VALUES line
  hashable NAME FILE          the capture with its load-dependent lines dropped, for receipts.md5
  values README VALS          README.md's values block = this run's VALUES lines"""
import hashlib, json, os, re, sys
from html.parser import HTMLParser

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
WORDS = {12: "twelve", 13: "thirteen", 14: "fourteen", 11: "eleven", 7: "seven", 5: "five", 8: "eight", 4: "four", 1: "one", 3: "three"}
HOOK = "TiffinBox came into this course with twelve routes. Exactly one answer says how long it may be kept, and it's the stylesheet."
U04_ADDED = "CustomerPauses"   # U04's README: the pause POST and its GET, CustomerPauses (2 methods) - its flag run printed it

def lines(p):
    return open(p, encoding="utf-8", errors="replace").read().splitlines()

# ---- static ---------------------------------------------------------------------------------------------------------------------------
def setc_parse(s):
    out = {}
    for tok in s.split():
        m = re.fullmatch(r"(\w+):(\d+):(\d+)", tok)
        if not m: fail("the set-up filter's token %r is not class:methods:dev" % tok); continue
        out[m.group(1)] = (int(m.group(2)), int(m.group(3)))
    return out

def static(setc):
    s9 = open(os.path.join(HERE, "s901.py"), encoding="utf-8").read().split("\n")
    s4 = open(os.path.join(UNIT, "..", "c9-unit04", "harness", "s904.py"), encoding="utf-8").read().split("\n")
    md = lambda x: hashlib.md5("\n".join(x).encode()).hexdigest()
    end = "# --- XFAM_S9S1 end ---"
    if end not in s9 or end not in s4: fail("the XFAM_S9S1 end marker is missing in s901.py or s904.py"); done()
    a9 = s9.index('"""', 1) if False else next(i for i, l in enumerate(s9) if l.endswith('"""') and i > 0)
    a4 = next(i for i, l in enumerate(s4) if l.endswith('"""') and i > 0)
    b9 = s9.index(end); b4 = s4.index(end)
    need(s9[a9 + 1:b9 + 1] == s4[a4 + 1:b4 + 1], "s901.py's base + XFAM_S9S1 (after its docstring, through the block's end marker) = s904.py's, %d lines, md5 %s" % (b4 - a4, md(s4[a4 + 1:b4 + 1])))
    t4 = "\n".join(s4); t9 = "\n".join(s9)
    blk4 = re.search(r"# --- XFAM_S9S1 begin ---\n.*?# --- XFAM_S9S1 end ---", t4, re.S); blk9 = re.search(r"# --- XFAM_S9S1 begin ---\n.*?# --- XFAM_S9S1 end ---", t9, re.S)
    need(blk4 is not None and blk9 is not None and blk4.group(0) == blk9.group(0), "the XFAM_S9S1 block, delimited, byte-equal to U04's")
    if blk9:
        h = hashlib.md5(blk9.group(0).encode()).hexdigest()
        r4 = open(os.path.join(UNIT, "..", "c9-unit04", "README.md"), encoding="utf-8").read()
        u4 = re.search(r"XFAM_S9S1[^\n]*?\b([0-9a-f]{8})(?:…|\.\.\.)", r4)
        print("  XFAM_S9S1_SLICE_MD5 = %s (computed the way ../c9-unit04/harness/chk04.py computes it)%s" % (h, (" · U04's README names %s…" % u4.group(1)) if u4 else ""))
        if u4: need(h.startswith(u4.group(1)), "the block's md5 = the prefix U04's README names")
        val("xfam_s9s1_md5", h[:8])
    need(not re.search(r"^XU04 = ", t9, re.M), "U04's own family (XU04) is not carried")
    sc = setc_parse(setc)
    need(len(sc) > 0, "the set-up commit's classes were read (%d)" % len(sc))
    print("  the set-up filter's classes (git grep at the set-up commit): " + " · ".join("%s %d" % (c, n) for c, (n, d) in sorted(sc.items()) if not d))
    print("  the dev classes at the set-up commit (@Profile(\"dev\")): " + " · ".join("%s %d" % (c, n) for c, (n, d) in sorted(sc.items()) if d))
    set_n = sum(n for n, d in sc.values() if not d); dev_n = sum(n for n, d in sc.values() if d)
    val("setup_classes", sum(1 for n, d in sc.values() if not d)); val("setup_methods", set_n); val("dev_methods", dev_n)
    need(U04_ADDED not in sc, "%s holds no handler method at the set-up commit (it is U04's)" % U04_ADDED)
    done()

# ---- the spoken lines -----------------------------------------------------------------------------------------------------------------
STATUS = re.compile(r"(?<![\d.,:/-])\b(?:[2-5]\d\d)\b|\b(?:two|three|four|five)[\s-]hundred\b")
HING = re.compile(r"\b(?:bhai|yaar|dosto|kya|hai|nahi|nahin|matlab|karo|dekho|chalo|samjho|theek|accha|arre|haan|bilkul|zaroor|aur|toh|abhi|yeh|woh|kaise|kyun|bahut|thoda|sahi|galat)\b", re.I)
SPELL = re.compile(r"\b(?:API|URI|URL|RFC|HTTP|JSON|SSE)\b")
def spoken(hook, exq):
    import importlib.util
    spec = importlib.util.spec_from_file_location("dur9", os.path.join(HERE, "dur9.py")); m = importlib.util.module_from_spec(spec); spec.loader.exec_module(m)
    dur = getattr(m, "DUR", None)
    need(dur is not None, "dur9.py exposes its pattern (DUR)")
    need(hook == HOOK, "the hook is the dated note's (S1B), byte for byte")
    for name, s in (("the hook", hook), ("the exercise", exq)):
        need(not re.search(r"\d", s), "%s holds no digit" % name)
        need(not STATUS.search(s), "%s: the status gate 0" % name)
        need(not SPELL.search(s), "%s: the spelling gate 0 (API, URI, URL, RFC, HTTP, JSON, SSE bare)" % name)
        need(not HING.search(s), "%s: the Hinglish list 0" % name)
        if dur is not None: need(not dur.search(s), "%s: dur9 0 (%s)" % (name, dur.search(s).group(0) if dur.search(s) else "no hit"))
    print("  the hook: %d words · the exercise: %d words" % (len(hook.split()), len(exq.split())))
    val("hook_words", len(hook.split())); val("exercise_words", len(exq.split()))
    done()

# ---- links in one body -----------------------------------------------------------------------------------------------------------------
class Links(HTMLParser):
    def __init__(self):
        super().__init__(); self.a = 0; self.link = 0; self.form = 0; self.css = 0
    def handle_starttag(self, tag, attrs):
        d = dict(attrs)
        if tag == "a" and "href" in d: self.a += 1
        if tag == "link" and "href" in d:
            self.link += 1
            if (d.get("rel") or "").lower() == "stylesheet": self.css += 1
        if tag == "form" and "action" in d: self.form += 1

def walk(o, keys):
    if isinstance(o, dict):
        for k, v in o.items():
            keys.append(k); walk(v, keys)
    elif isinstance(o, list):
        for v in o: walk(v, keys)

def linkcount(p, ct):
    raw = open(p, "rb").read()
    if "html" in ct:
        h = Links(); h.feed(raw.decode("utf-8", "replace"))
        print("links (html.parser): <a href> %d · <link href> %d (rel=stylesheet %d) · <form action> %d · links in all %d" % (h.a, h.link, h.css, h.form, h.a + h.link))
    elif "json" in ct:
        try:
            d = json.loads(raw)
        except Exception as e:
            print("links (JSON): NOT JSON (%s)" % e.__class__.__name__); return
        keys = []; walk(d, keys)
        hk = sum(1 for k in keys if k in ("_links", "links", "href"))
        pid = [k for k in ("type", "instance") if isinstance(d, dict) and k in d]
        print("links (JSON keys _links/links/href): %d%s" % (hk, (" · problem identifiers present: %s (identifiers, not hypermedia controls: counted 0)" % ",".join(pid)) if pid else ""))
    else:
        print("links: none counted (%s: neither HTML nor JSON)" % (ct or "no body type"))

# ---- the flag run's mappings -----------------------------------------------------------------------------------------------------------
def devcount():
    src = os.path.join(UNIT, "after", "tiffinbox-web", "src", "main", "java", "com", "tiffinbox", "web"); n = 0; cls = []
    for f in sorted(os.listdir(src)):
        t = open(os.path.join(src, f), encoding="utf-8").read()
        if '@Profile("dev")' in t:
            k = len(re.findall(r"^ +@(?:Get|Post|Put|Delete|Patch|Request)Mapping\b", t, re.M))
            if k: n += k; cls.append("%s %d" % (f[:-5], k))
    return n, cls

def mapread(p, setc):
    try:
        d = json.load(open(p))
        ctxs = d["contexts"]
    except Exception as e:
        fail("the mappings answer is not Actuator's mappings document (%s) - is the endpoint exposed? (the flag run's flag)" % e.__class__.__name__); done()
    rows = []
    for ctx in ctxs.values():
        for ds in ctx["mappings"].get("dispatcherServlets", {}).values():
            for e in ds:
                dd = e.get("details") or {}
                hm = dd.get("handlerMethod")
                if not hm: continue
                c = dd.get("requestMappingConditions", {})
                rows.append((hm["className"].rsplit(".", 1)[1], hm["name"], ",".join(c.get("methods", [])) or "ANY", ",".join(c.get("patterns", [])),
                             ",".join(x["mediaType"] for x in c.get("produces", [])) or "-", ",".join(x["mediaType"] for x in c.get("consumes", [])) or "-",
                             hm["className"].startswith("com.tiffinbox")))
    for r in sorted(rows, key=lambda r: (not r[6], r[0], r[1], r[3])):
        print("  row | %s#%s | %s | %s | %s | %s | %s" % (r[0], r[1], r[2], r[3], r[4], r[5], "TiffinBox" if r[6] else "other"))
    sc = setc_parse(setc)
    tb = [r for r in rows if r[6]]
    setf = [r for r in tb if r[0] in sc and not sc[r[0]][1]]
    added = [r for r in tb if r[0] == U04_ADDED]
    n, cls = devcount()
    print("  (a) TiffinBox's handler methods on after/: %d" % len(tb))
    print("  (b) the set-up filter (the classes holding a handler method at the set-up commit: %s): %d" % (", ".join(sorted(c for c in sc if not sc[c][1])), len(setf)))
    print("  (c) the mappings minus what U04 adds (%s, %d): %d - %d = %d" % (U04_ADDED, len(added), len(tb), len(added), len(tb) - len(added)))
    print("  (d) the set-up filter's split: GET %d · POST %d" % (sum(1 for r in setf if r[2] == "GET"), sum(1 for r in setf if r[2] == "POST")))
    print("  (e) the others (Actuator + BasicErrorController): %d" % (len(rows) - len(tb)))
    print("  (f) the \"dev\" routes by the sources only (@Profile(\"dev\") classes of after/, not started): %d (%s)" % (n, ", ".join(cls)))
    print("  the set-up filter's classes, per class on after/: " + " · ".join("%s %d" % (c, sum(1 for r in setf if r[0] == c)) for c in sorted(set(r[0] for r in setf))))
    w = WORDS.get(len(setf), str(len(setf)))
    print("  (g) the hook: \"%s\" (%d words) · its number word \"%s\" = (b) spelled out" % (HOOK, len(HOOK.split()), w))

def mappings(ls):
    rows = []; vals = {}
    for l in ls:
        m = re.match(r"^  row \| (\w+)#(\w+) \| ([A-Z,]+) \| (\S+) \| (\S+) \| (\S+) \| (TiffinBox|other)$", l)
        if m: rows.append(m.groups()); continue
        m = re.match(r"^  \(([a-f])\) .*?: (?:\d+ - \d+ = )?(\d+)(?: \(| ·|$)", l)
        if m: vals[m.group(1)] = int(m.group(2)); continue
        if l.startswith("  row |"): fail("a row line the reader cannot parse: %r" % l[:120])
    need(any(re.match(r"^  GET /actuator/mappings -> 200 ", l) for l in ls), "the flag run answered GET /actuator/mappings with 200")
    tb = [r for r in rows if r[6] == "TiffinBox"]; ot = [r for r in rows if r[6] == "other"]
    need(len(tb) == vals.get("a"), "(a) = the TiffinBox rows printed: %d" % len(tb))
    need(len(ot) == vals.get("e"), "(e) = the other rows printed: %d" % len(ot))
    need("b" in vals and "c" in vals and vals["b"] == vals["c"], "the two derivations agree: the set-up filter (b) = the mappings minus U04's (c) = %s" % vals.get("b"))
    need(any(l.startswith("  (g) the hook: \"%s\"" % HOOK) for l in ls), "the hook, byte-equal to S1B's dated note")
    hw = re.search(r"its number word \"(\w+)\"", "\n".join(ls))
    need(hw is not None and hw.group(1) == "twelve" and WORDS.get(vals.get("b")) == "twelve", "the hook says \"twelve\" and (b) spelled out is \"%s\"" % WORDS.get(vals.get("b")))
    need(not re.search(r"\bthirteen\b", HOOK), "the hook does not say thirteen")
    m = re.search(r"GET (\d+) · POST (\d+)", "\n".join(ls))
    if m: val("get", m.group(1)); val("post", m.group(2))
    else: fail("no GET/POST split line")
    for k, n in (("a", "tb_methods"), ("b", "setup_filter"), ("c", "minus_u04"), ("e", "others"), ("f", "dev")):
        if k in vals: val(n, vals[k])
    val("u04_added", vals.get("a", 0) - vals.get("c", 0))
    val("hook_word", hw.group(1) if hw else "none")
    done()

# ---- the census -------------------------------------------------------------------------------------------------------------------------
REQ = re.compile(r"^-- (\w+) \| ([A-Z]+) (\S+) -> (\d{3}) (\S*) ?(\S*) \((?:curl|read by count|reader).*$")
def census_parse(ls):
    """Per request: label, method, path, status, ct, bytes, headers{}, server line, links line, body. Lines between requests that are
    not part of a block are skipped by these named rules: '== ' section heads, '  ' + cache/key/access/total lines, the guard."""
    reqs = []; cur = None; extra = []
    for l in ls:
        if l.startswith("-- "):
            m = re.match(r"^-- (\w+) \| ([A-Z]+) (\S+) -> (\d{3})? ?(\S*) ?(\S*) ", l + " ")
            if not m: fail("a request line the census reader cannot parse: %r" % l[:120]); cur = None; continue
            cur = {"label": m.group(1), "method": m.group(2), "path": m.group(3), "status": m.group(4) or "", "ct": m.group(5), "bytes": m.group(6),
                   "h": {}, "server": [], "links": "", "body": "", "notes": []}
            reqs.append(cur); continue
        if cur is not None and l.startswith("     "):
            t = l[5:]
            if t.startswith("server: "): cur["server"].append(t[8:]); continue
            if t.startswith("links"): cur["links"] = t; continue
            if t.startswith("body: "): cur["body"] = t[6:]; continue
            m = re.match(r"^([A-Za-z-]+): ?(.*)$", t)
            if m: cur["h"].setdefault(m.group(1).lower(), []).append(m.group(2)); continue
            if t.startswith("HTTP/"): cur["h"]["status-line"] = [t]; continue
            cur["notes"].append(t); continue
        if l.startswith("     access: "): cur = None; continue   # named rule: the access log's lines, read by census() itself
        if l.startswith("     "): fail("an indented line outside a request block: %r" % l[:100]); continue
        cur = None; extra.append(l)
    return reqs, extra

def handler(r):
    for s in r["server"]:
        if "[dispatch" in s: continue
        m = re.search(r"\| handler (\S+)", s)
        if m: return m.group(1)
    return "none"

def stmts(r):
    for s in r["server"]:
        if "[dispatch" in s: continue
        m = re.search(r"statements (\d+) \(writes (\d+)", s)
        if m: return int(m.group(1)), int(m.group(2))
    return None

def route(r):
    h = handler(r)
    if h == "ResourceHttpRequestHandler": return "static " + ("/css/**" if r["path"].startswith("/css/") else r["path"])
    if h in ("none",): return "none " + r["path"]
    return h

def lifetime(r):
    cc = " ".join(r["h"].get("cache-control", []))
    return bool(re.search(r"\b(?:max-age|s-maxage)=", cc)) or "expires" in r["h"]

EXPECT = {"health0": "200", "customers": "200", "veg": "200", "ravi": "200", "ravi2": "200", "nobody": "404", "revenue": "200", "dashjson": "200",
          "dashhtml": "200", "form": "200", "kitchen": "200", "feed": "200", "nowhere": "404", "css": "200", "css304": "304", "add": "201",
          "formjar": "302", "dashjar": "200", "formnojar": "302", "dashnojar": "200", "formjar2": "302", "dashjar2": "200", "shutdown": "403",
          "health": "200", "mappings": "404", "pausenokey": "400", "pausekey": "201", "pauseget": "200"}

def mapping_rows():
    p = os.path.join(UNIT, ".r-mappings.new")
    if not os.path.exists(p): p = os.path.join(UNIT, ".r-mappings.out")
    out = []
    for l in lines(p):
        m = re.match(r"^  row \| (\w+#\w+) \| ([A-Z,]+) \| (\S+) \| \S+ \| \S+ \| (TiffinBox|other)$", l)
        if m: out.append(m.groups())
    return out

def census(ls, db):
    reqs, extra = census_parse(ls)
    if BAD: done()
    by = {r["label"]: r for r in reqs}
    dbl = [m.group(1) for l in ls for m in [re.match(r"^  which database answered \(Flyway's line\): Database: \S+ \((\w+)", l)] if m]
    need(dbl == [{"pg": "PostgreSQL", "h2": "H2"}[db]], "which database answered: %s (Flyway's own line; the capture's label says %s)" % (dbl, db))
    need(len(by) == len(reqs), "every request label once (%d requests)" % len(reqs))
    for k, s in EXPECT.items():
        if k.startswith("pause") and k not in by: continue
        need(k in by and by[k]["status"] == s, "%s %s %s -> %s (the capture: %s)" % (db, by[k]["method"] if k in by else "?", by[k]["path"] if k in by else k, s, by[k]["status"] if k in by else "absent"))
    t = "\n".join(extra)
    need(re.search(r"customers \[\] \(the harness's /probe/u01/cache, before any request", t) is not None, "the cache is cold right after the Started line: customers []")
    need(re.search(r"customers \[SimpleKey \[\]\] \(after one health check", t) is not None, "after one health check the cache is warm: customers [SimpleKey []]")
    st = {k: stmts(r) for k, r in by.items()}
    for k, n in (("health0", 1), ("customers", 0), ("ravi", 1), ("ravi2", 0), ("revenue", 1)):
        need(st.get(k) is not None and st[k][0] == n, "%s statements on %s: %d (the capture: %s)" % (db, k, n, st.get(k)))
    need(st.get("dashjson") is not None and st.get("dashhtml") is not None and st["dashjson"] == st["dashhtml"], "the dashboard's JSON and HTML send the same statements: %s" % (st.get("dashjson"),))
    # Set-Cookie per route
    sc_routes = sorted(set(route(r) for r in reqs if "set-cookie" in r["h"]))
    need(sc_routes == ["DashboardPage#add"], "Set-Cookie on exactly one route, the form POST (DashboardPage#add): %s" % sc_routes)
    jsonsc = [r["label"] for r in reqs if "set-cookie" in r["h"] and "json" in r["ct"]]
    need(not jsonsc, "no JSON answer carries Set-Cookie: %s" % jsonsc)
    need(all("HttpOnly" in v and "Path=/" in v and "JSESSIONID=<masked>" in v for r in reqs for v in r["h"].get("set-cookie", [])), "the cookie: JSESSIONID=<masked>; Path=/; HttpOnly")
    # notes: jar 1, no jar 0, jar again 1
    notes = {m.group(1): int(m.group(2)) for l in ls for m in [re.search(r'the note "(\w+) added" on the page: (\d+)', l)] if m}
    need(notes.get("Chitra") == 1 and notes.get("Bina") == 0 and notes.get("Divya") == 1, "the failure receipt: note with the jar 1, without 0, with a jar again 1 (%s)" % notes)
    need(re.search(r"the jar \(the cookie's name.*: JSESSIONID=<masked> · the raw line starts with: #HttpOnly_", t + "\n" + "\n".join(n for r in reqs for n in r["notes"])) is not None, "the jar's line starts #HttpOnly_ and the stripped reader finds JSESSIONID")
    # lifetimes and validators
    lt = sorted(set(route(r) for r in reqs if lifetime(r)))
    need(lt == ["static /css/**"], "a lifetime (Cache-Control max-age / s-maxage or Expires) on exactly one route, the stylesheet's: %s" % lt)
    vroutes = sorted(set(route(r) for r in reqs if "etag" in r["h"] or "last-modified" in r["h"]))
    need(vroutes == ["static /css/**"], "validators (ETag / Last-Modified) on the stylesheet's route only: %s" % vroutes)
    css = by.get("css", {"h": {}})
    need(re.match(r'^W/"[0-9a-f]+"$', (css["h"].get("etag") or [""])[0]) is not None, "the stylesheet's ETag is weak: %s" % (css["h"].get("etag"),))
    # links
    def lk(k):
        m = re.search(r"<a href> (\d+) · <link href> (\d+) \(rel=stylesheet (\d+)\) · <form action> (\d+)", by.get(k, {}).get("links", ""))
        return tuple(int(x) for x in m.groups()) if m else None
    need(lk("dashhtml") == (2, 1, 1, 0), "the dashboard page: <a href> 2 + <link rel=stylesheet> 1, no form: %s" % (lk("dashhtml"),))
    need(lk("form") == (2, 1, 1, 1), "the form page: <a href> 2 + <link rel=stylesheet> 1 + <form action> 1: %s" % (lk("form"),))
    jl = [r["label"] for r in reqs if "json" in r["ct"] and not re.search(r"\(JSON keys _links/links/href\): 0\b", r["links"])]
    need(not jl, "every JSON answer: 0 link keys (%s)" % jl)
    lh = [r["label"] for r in reqs if "link" in r["h"]]
    need(not lh, "no answer carries a Link header: %s" % lh)
    need(bool(by.get("add", {"h": {}})["h"].get("location")), "the 201 carries Location (the one link a JSON answer carries)")
    # the feed
    fd = by.get("feed")
    need(fd is not None and "text/event-stream" in fd["ct"] and re.search(r"reader exit 0", " ".join([l for l in ls if l.startswith("-- feed")])) is not None, "the feed read by count to its first event, reader exit 0")
    # coverage against the flag run's rows
    mr = mapping_rows()
    tbm = sorted(set(r[0] for r in mr if r[3] == "TiffinBox"))
    asked = set(handler(r) for r in reqs)
    miss = [x for x in tbm if x not in asked]
    need(tbm and not miss, "coverage: every TiffinBox mapping row of the flag run is asked at least once (%d rows; missed %s)" % (len(tbm), miss))
    ACT = ("OperationHandler", "WebMvcLinksHandler")
    # named rule: U04's key filter answers the unkeyed pause POST itself (handler none, 400): who answered is the filter, not a mapping
    unexpl = [r["label"] for r in reqs if r["label"] not in ("nowhere", "nobody") and not (r["label"] == "pausenokey" and handler(r) == "none" and r["status"] == "400") and not route(r).startswith("static ") and not r["path"].startswith("/actuator")
              and handler(r) not in tbm]
    need(not unexpl, "coverage: every other request maps to a mapping row (%s)" % unexpl)
    keys = [int(m.group(1)) for l in ls for m in [re.search(r"key table rows after the census: (\d+)", l)] if m]
    keyed = sum(1 for l in ls if re.match(r"^-- pausekey ", l))
    need(keys == [keyed], "the key table's rows after the census: %s = the requests that carried a key (%d) - every other route left it as it was" % (keys, keyed))
    # access log
    acc = [l.split("access: ", 1)[1] for l in ls if l.startswith("     access: ")]
    e500 = [a for a in acc if re.search(r" 500 ", a + " ")]
    print("  access log: %d lines · a 500 in it: %s" % (len(acc), ("; ".join(e500) + " (the feed request this census abandoned: named, not a finding about TiffinBox)") if e500 else "none"))
    need(all("/customers/feed" in a for a in e500), "a 500 in the access log, if any, is the abandoned feed read's")
    nroutes = sorted(set(route(r) for r in reqs if not r["path"].startswith("/actuator") and r["label"] not in ("pausenokey", "pausekey", "pauseget")))
    val("requests", len(reqs)); val("routes", len(nroutes)); val("setcookie_routes", len(sc_routes)); val("lifetime_routes", len(lt))
    val("dash_links", sum(lk("dashhtml")[:2]) if lk("dashhtml") else 0); val("form_links", sum(lk("form")[:2]) if lk("form") else 0); val("forms", lk("form")[3] if lk("form") else 0)
    val("cssinm", by.get("cssinm", {}).get("status", "absent")); val("keyrows", keys[0] if keys else "none")
    val("notes", "%s/%s/%s" % (notes.get("Chitra"), notes.get("Bina"), notes.get("Divya")))
    val("st_dashboard", st["dashjson"][0] if st.get("dashjson") else "none"); val("st_import", by.get("import", {}).get("status", "absent"))
    val("prometheus", by.get("prometheus", {}).get("status", "absent"))
    done()

# ---- the views --------------------------------------------------------------------------------------------------------------------------
def view(kind, pg, h2, mp):
    rp, _ = census_parse(lines(pg)); rh, _ = census_parse(lines(h2))
    bp = {r["label"]: r for r in rp}; bh = {r["label"]: r for r in rh}
    cols = ("status", "ct", "set-cookie", "cache-control", "expires", "pragma", "etag", "last-modified", "vary", "link", "location")
    def row(r):
        return tuple([r["status"], r["ct"]] + ["|".join(r["h"].get(c, [])) for c in cols[2:]] + [r["links"]])
    diff = [k for k in bp if k in bh and row(bp[k]) != row(bh[k]) and k != "prometheus"]
    print("RESULT http_columns_equal=%s labels=%d differ=%s" % ("yes" if not diff and set(bp) == set(bh) else "no", len(bp), ",".join(diff) or "none"))
    sd = [k for k in bp if k in bh and stmts(bp[k]) != stmts(bh[k])]
    print("RESULT statements_equal=%s differ=%s" % ("yes" if not sd else "no", ";".join("%s pg %s h2 %s" % (k, stmts(bp[k]), stmts(bh[k])) for k in sd) or "none"))
    EXTRAS = ("pausenokey", "pausekey", "pauseget")   # named rule: U04's routes, labelled, not in the hook's population
    rs = sorted(set(route(r) for r in rh if not r["path"].startswith("/actuator") and r["label"] not in EXTRAS))
    print("RESULT the_routes=%d (the census's routes: TiffinBox's handler methods of the set-up filter, the stylesheet's, the static handler's 404; Actuator and U04's extras left out)" % len(rs))
    for x in rs: print("  route: " + x)
    if kind == "stateless":
        print("== stateless (Fielding 5.1.3): Set-Cookie per route, PostgreSQL first, then H2")
        for k in bp:
            r = bp[k]; s = bh.get(k, r)
            print("  %-10s %-4s %-44s pg %s · h2 %s · Set-Cookie: %s · handler %s" % (k, r["method"], r["path"][:44], r["status"], s["status"], ("JSESSIONID (" + r["h"]["set-cookie"][0].split("; ", 1)[1] + ")") if "set-cookie" in r["h"] else "none", route(r)))
        scr = sorted(set(route(r) for r in rh if "set-cookie" in r["h"] and r["label"] not in EXTRAS)); scp = sorted(set(route(r) for r in rp if "set-cookie" in r["h"]))
        print("RESULT setcookie_routes=%d of=%d route=%s same_on_pg=%s" % (len(scr), len(rs), ",".join(scr), "yes" if scr == scp else "no"))
    elif kind == "cache":
        print("== cacheable (Fielding 5.1.4): lifetimes and validators per answer, PostgreSQL first, then H2 (an answer = a route: method + pattern)")
        for k in bp:
            r = bp[k]; h = r["h"]
            print("  %-10s %-4s %-44s %s · Cache-Control %s · Expires %s · Pragma %s · ETag %s · Last-Modified %s · statements pg %s h2 %s" % (k, r["method"], r["path"][:44], r["status"],
                  "|".join(h.get("cache-control", [])) or "-", "|".join(h.get("expires", [])) or "-", "|".join(h.get("pragma", [])) or "-", "|".join(h.get("etag", [])) or "-",
                  "|".join(h.get("last-modified", [])) or "-", stmts(r), stmts(bh[k]) if k in bh else "-"))
        lt = sorted(set(route(r) for r in rh if lifetime(r) and r["label"] not in EXTRAS)); va = sorted(set(route(r) for r in rh if "etag" in r["h"] or "last-modified" in r["h"]))
        nc = sorted(set(route(r) for r in rh if re.search(r"no-store|no-cache", " ".join(r["h"].get("cache-control", [])))))
        print("RESULT lifetime_routes=%d of=%d route=%s validator_routes=%d no_store_or_no_cache_routes=%s" % (len(lt), len(rs), ",".join(lt), len(va), ",".join(nc) or "none"))
        css = bh["css"]
        print("RESULT css_cc=%s css_etag=%s css_lm=%s" % ("|".join(css["h"].get("cache-control", [])), "|".join(css["h"].get("etag", [])), "present" if css["h"].get("last-modified") else "absent"))
        print("RESULT css304=%s css304_statements=%s cssinm=%s (If-None-Match with the stylesheet's own ETag) cssinm_pg=%s" % (bh["css304"]["status"], stmts(bh["css304"]), bh["cssinm"]["status"], bp["cssinm"]["status"]))
        m = re.search(r"/css/tiffinbox-([0-9a-f]+)\.css", css["path"]); e = re.search(r'W/"([0-9a-f]+)"', "|".join(css["h"].get("etag", [])))
        f = re.search(r"the file's own md5 \(md5 -q of the built static/css/tiffinbox.css\): ([0-9a-f]{32})", open(h2, encoding="utf-8").read())
        print("RESULT css_name_md5=%s css_etag_value=%s css_file_md5=%s" % (m.group(1) if m else "none", e.group(1) if e else "none", f.group(1) if f else "none"))
    elif kind == "links":
        print("== uniform interface (Fielding 5.1.5): links and forms per representation, PostgreSQL first, then H2")
        for k in bp:
            r = bp[k]
            print("  %-10s %-4s %-44s %s %-26s %s%s%s" % (k, r["method"], r["path"][:44], r["status"], r["ct"][:26], r["links"], (" · Location " + r["h"]["location"][0]) if "location" in r["h"] else "",
                  (" · Link " + r["h"]["link"][0]) if "link" in r["h"] else ""))
        js = [r for r in rh if "json" in r["ct"]]
        jl = [r["label"] for r in js if not re.search(r"\(JSON keys _links/links/href\): 0\b", r["links"])]
        pidl = [r["label"] for r in js if "problem identifiers present" in r["links"]]
        print("RESULT json_answers=%d json_with_links=%d link_headers=%d problem_bodies_with_identifiers=%d (%s)" % (len(js), len(jl), sum(1 for r in rh if "link" in r["h"]), len(pidl), ",".join(pidl)))
        def lk(k):
            m = re.search(r"<a href> (\d+) · <link href> (\d+) \(rel=stylesheet (\d+)\) · <form action> (\d+)", bh[k]["links"]); return m.groups() if m else ("?",) * 4
        a, l, c, f = lk("dashhtml"); a2, l2, c2, f2 = lk("form")
        print("RESULT dashboard_nav=%s dashboard_stylesheet=%s dashboard_forms=%s form_nav=%s form_stylesheet=%s form_forms=%s" % (a, c, f, a2, c2, f2))
        print("RESULT locations=%s" % ",".join("%s:%s" % (r["label"], r["status"]) for r in rh if "location" in r["h"]))

def v_check(ls, kind):
    res = {}
    for l in ls:
        if l.startswith("RESULT "):
            for m in re.finditer(r"(\w+)=(\S+)", l[7:]): res[m.group(1)] = m.group(2)
    need(res.get("http_columns_equal") == "yes", "PostgreSQL and H2: every HTTP column equal, request by request (differ: %s)" % res.get("differ"))
    print("  statements PostgreSQL vs H2: %s (differ: %s)" % ("equal" if res.get("statements_equal") == "yes" else "NOT equal - named", res.get("differ")))
    if kind == "stateless":
        need(res.get("setcookie_routes") == "1" and res.get("route") == "DashboardPage#add" and res.get("same_on_pg") == "yes", "Set-Cookie on 1 route of %s: the form POST, on both databases" % res.get("of"))
        val("setcookie_routes", res.get("setcookie_routes")); val("routes", res.get("of"))
    elif kind == "cache":
        need(res.get("lifetime_routes") == "1" and res.get("route") == "static", "a lifetime on 1 route of %s: the stylesheet's (static /css/**)" % res.get("of"))
        need(res.get("validator_routes") == "1", "validators on 1 route")
        need(res.get("css304") == "304" and res.get("css304_statements", "").startswith("(0,"), "If-Modified-Since -> 304, 0 statements")
        need(res.get("css_name_md5") == res.get("css_file_md5"), "the fingerprinted name = the file's own md5 (%s)" % res.get("css_file_md5"))
        need(res.get("cssinm") == res.get("cssinm_pg"), "If-None-Match: the same answer on both databases (%s)" % res.get("cssinm"))
        val("cssinm", res.get("cssinm")); val("css_etag_eq_name", "yes" if res.get("css_etag_value") == res.get("css_name_md5") else "no")
        val("css_md5", res.get("css_file_md5")); val("lifetime_routes", res.get("lifetime_routes")); val("routes", res.get("of"))
        val("max_age", (re.search(r"max-age=(\d+)", res.get("css_cc", "")) or re.search("()", "")).group(1) or "none")
        val("css_etag", res.get("css_etag", "none"))
    elif kind == "links":
        need(res.get("json_with_links") == "0" and res.get("link_headers") == "0", "every JSON answer 0 links, no Link header (%s JSON answers)" % res.get("json_answers"))
        need(res.get("dashboard_nav") == "2" and res.get("dashboard_stylesheet") == "1" and res.get("form_forms") == "1", "the pages: navigation 2 + stylesheet 1; the form page + 1 form")
        val("json_answers", res.get("json_answers")); val("nav", res.get("dashboard_nav")); val("stylesheet_links", res.get("dashboard_stylesheet")); val("form_forms", res.get("form_forms"))
    done()

# ---- seven, surface, exercise -----------------------------------------------------------------------------------------------------------
def c_seven(ls):
    m = [re.search(r"^  the seven: ([0-9a-f]{32}) \((\d+) lines\) · expected ([0-9a-f]{32})(?: · U04's after/ ([0-9a-f]{32}))?$", l) for l in ls]
    m = [x for x in m if x]
    if not m: fail("no 'the seven:' line"); done()
    g = m[0]
    need(g.group(1) == g.group(3), "the seven on after/ = the expected %s" % g.group(3))
    if g.group(4): need(g.group(1) == g.group(4), "= U04's after/ capture")
    val("seven", g.group(1)); done()

def c_surface(ls):
    m = [x for l in ls for x in [re.search(r"^  the old surface: ([0-9a-f]{32}) \((\d+) requests, (\d+) lines\) · expected ([0-9a-f]{32})(?: · U04's after/ ([0-9a-f]{32}))?$", l)] if x]
    if not m: fail("no 'the old surface:' line"); done()
    g = m[0]
    need(g.group(1) == g.group(4), "the old surface on after/ = the expected %s (%s requests, %s lines)" % (g.group(4), g.group(2), g.group(3)))
    if g.group(5): need(g.group(1) == g.group(5), "= U04's after/ capture")
    p = [x for l in ls for x in [re.search(r"planted: the seven ([0-9a-f]{32}) \(unchanged: (\w+)\) · the old surface ([0-9a-f]{32}) \(moved: (\w+)\) · the feed's line: .*-> +(\S*) *(\S*) *(\d+) \(reader exit (\d+)\)", l)] if x]
    need(bool(p) and p[0].group(2) == "yes" and p[0].group(4) == "yes" and p[0].group(8) == "3", "the S9.14 plant: the seven unchanged, the surface moved, the feed answers nothing (reader exit 3)")
    val("surface", g.group(1)); val("surface_requests", g.group(2)); val("surface_lines", g.group(3)); val("surface_plant", p[0].group(3) if p else "none")
    done()

def c_exercise(ls):
    secs = {}; cur = None
    for l in ls:
        m = re.match(r"^== the exercise, (\w+), (\w+) ", l)
        if m: cur = (m.group(1), m.group(2)); secs[cur] = []; continue
        if l.startswith("== "): cur = None; continue
        if cur and l.startswith("  ") and (not secs[cur] or secs[cur][-1] not in ("PASS", "FAIL")): secs[cur].append(l[2:])   # named rule: a try's lines end at its verdict
    want = {"broken": ("absent", "absent", "FAIL"), "solved": ("present", "present", "PASS"), "jaronly": ("absent", "present", "FAIL"), "emptyjar": ("absent", "absent", "FAIL")}
    for (v, sh), out in sorted(secs.items()):
        t = "\n".join(out)
        m = re.search(r"the note for this try's name: (\w+) · the session cookie JSESSIONID in jar.txt: (\w+)\n(PASS|FAIL)", t)
        need(m is not None and m.groups() == want[v], "%s under %s: note %s · cookie %s · %s" % (v, sh, *(want[v])))
        need("POST /customers (the form) -> 302" in t, "%s under %s: the form POST answered 302" % (v, sh))
    need(len(secs) == 8, "four tries x two shells: %d" % len(secs))
    rd = [l.split("README: ", 1)[1] for l in ls if l.startswith("  README: ")]; so = [l.split("SOLUTION: ", 1)[1] for l in ls if l.startswith("  SOLUTION: ")]
    for name, w, k in (("README.md", rd, ("broken", "bash")), ("SOLUTION.md", so, ("solved", "bash"))):
        got = [x for x in secs.get(k, []) if not x.startswith("(")]
        need(w == got, "%s's What it prints = the %s run's output" % (name, k[0]))
    val("exercise", "broken FAIL, solved PASS, jar-only FAIL, empty-jar FAIL, bash + zsh")
    done()

# ---- hashable, values -------------------------------------------------------------------------------------------------------------------
def hashable(nm, p):
    """The capture as published, minus the guard's load lines; the access log's lines sorted (the abandoned feed's 500 is logged by
    another thread when the next add's event fails to reach it: its place among the lines is timing, its presence is not)."""
    acc = []
    for l in lines(p):
        if re.match(r"^  guard before ", l): continue
        if l.startswith("     access: "): acc.append(l); continue
        if acc: sys.stdout.write("\n".join(sorted(acc)) + "\n"); acc = []
        sys.stdout.write(re.sub(r"load1 [0-9.]+", "load1 <n>", l) + "\n")
    if acc: sys.stdout.write("\n".join(sorted(acc)) + "\n")

def values(readme, vals):
    run = {}
    for l in vals.splitlines():
        m = re.match(r"^(\w+): (.*)$", l)
        if not m: continue
        for kv in m.group(2).split():
            if "=" in kv: k, v = kv.split("=", 1); run["%s.%s" % (m.group(1), k)] = v
    t = open(readme, encoding="utf-8").read()
    b = re.search(r"<!-- values: begin -->\n(.*?)<!-- values: end -->", t, re.S)
    if not b: fail("README.md has no values block"); done()
    n = 0
    for l in b.group(1).splitlines():
        if not l.strip() or l.startswith("```"): continue
        m = re.match(r"^- (\w+\.\w+) = (\S+) · (.+)$", l)
        if not m: fail("a values line the reader cannot parse: %r" % l[:100]); continue
        n += 1
        need(run.get(m.group(1)) == m.group(2), "values: %s = %s (this run: %s)" % (m.group(1), m.group(2), run.get(m.group(1))))
    print("values block: %d lines, each = this run's" % n if not BAD else "values block: %d lines, NOT all this run's" % n)
    done()

CAPS = {"mappings": mappings, "censuspg": lambda ls: census(ls, "pg"), "census": lambda ls: census(ls, "h2"), "stateless": lambda ls: v_check(ls, "stateless"),
        "cache": lambda ls: v_check(ls, "cache"), "links": lambda ls: v_check(ls, "links"), "seven": c_seven, "surface": c_surface, "exercise": c_exercise}

if __name__ == "__main__":
    a = sys.argv[1:]
    try:
        if not a: fail("no mode"); done()
        if a[0] == "static": static(a[1])
        elif a[0] == "spoken": spoken(a[1], a[2])
        elif a[0] == "linkcount": linkcount(a[1], a[2])
        elif a[0] == "mapread": mapread(a[1], a[2]); sys.exit(1 if BAD else 0)
        elif a[0] == "view": view(a[1], a[2], a[3], a[4])
        elif a[0] == "hashable": hashable(a[1], a[2])
        elif a[0] == "values": values(a[1], a[2])
        elif a[0] in CAPS: CAPS[a[0]](lines(a[1]))
        else: fail("unknown mode %r" % a[0]); done()
    except SystemExit:
        raise
    except Exception as e:
        print("FAIL the checker could not read its input (%s: %s)" % (e.__class__.__name__, str(e)[:160])); sys.exit(1)
