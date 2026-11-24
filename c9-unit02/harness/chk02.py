"""Course 9 unit 02's checker (python3 -I -B harness/chk02.py MODE ...). Every number the README may say is re-derived here from a capture's
own lines (or a shipped file), never typed. Each listing line a check reads is parsed by a named pattern or skipped by a named rule; a line
it cannot parse is a FAIL line and exit 1, never a traceback. The shape is U01's chk01.py (copied from U01's harness, cut to this unit).
Modes:
  static LEDGER               the prose gate's carried slices (s902.py against U04's s904.py and U01's s901.py), the XFAM_S9S1 block's md5
  spoken HOOK PIN EXQ LEDGER  the three spoken lines: words, digits, spellings, statuses, Hinglish, dur9; the pinned sentence's two md5s
  view KIND PG H2             head / who / trace / safe / cross, read off both table captures (PostgreSQL first)
  <capture> FILE              one capture's checks; prints ok/FAIL lines and one VALUES line
  hashable NAME FILE          the capture with its load-dependent lines dropped and every Allow list read as a set, for receipts.md5
  values README VALS          README.md's values block = this run's VALUES lines"""
import collections, hashlib, json, os, re, sys

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
BR8 = os.path.join(C9R, "_research", "boundary-2026-11-24", "B8", "census-mid", "census.txt")
HOOK = "Send TRACE to TiffinBox and no TiffinBox route runs: Tomcat refuses it four oh five, and Spring Boot's error page writes the answer. Send it through MockMvc, and it comes back two hundred."
EXQ = "Your turn: curl -X HEAD waits on the customer list. Ask it so curl stops after the headers, and print the methods shutdown allows."
ADDRS = ["/customers", "/customers/Ravi", "/revenue", "/shutdown"]
METHODS = ["GET", "HEAD", "POST", "PUT", "DELETE", "CONNECT", "OPTIONS", "TRACE", "PATCH"]
GETS = ["/customers", "/customers/Ravi", "/revenue"]

def lines(p):
    return open(p, encoding="utf-8", errors="replace").read().splitlines()
def aset(s):
    return ",".join(sorted(x.strip() for x in s.split(",") if x.strip() and x.strip() != "-"))

# ---- static ---------------------------------------------------------------------------------------------------------------------------
def static(ledger):
    s9 = open(os.path.join(HERE, "s902.py"), encoding="utf-8").read().split("\n")
    s4 = open(os.path.join(UNIT, "..", "c9-unit04", "harness", "s904.py"), encoding="utf-8").read().split("\n")
    s1 = open(os.path.join(UNIT, "..", "c9-unit01", "harness", "s901.py"), encoding="utf-8").read().split("\n")
    md = lambda x: hashlib.md5("\n".join(x).encode()).hexdigest()
    end = "# --- XFAM_S9S1 end ---"
    if end not in s9 or end not in s4 or end not in s1: fail("the XFAM_S9S1 end marker is missing in s902.py, s904.py or s901.py"); done()
    a = lambda s: next(i for i, l in enumerate(s) if l.endswith('"""') and i > 0)
    sl = lambda s: s[a(s) + 1:s.index(end) + 1]
    need(sl(s9) == sl(s4), "s902.py's base + XFAM_S9S1 (after its docstring, through the block's end marker) = s904.py's, %d lines, md5 %s" % (len(sl(s4)), md(sl(s4))))
    need(sl(s9) == sl(s1), "= U01's s901.py's slice (copied from U01's harness)")
    t9 = "\n".join(s9); t4 = "\n".join(s4)
    rx = r"# --- XFAM_S9S1 begin ---\n.*?# --- XFAM_S9S1 end ---"
    b4 = re.search(rx, t4, re.S); b9 = re.search(rx, t9, re.S)
    need(b4 is not None and b9 is not None and b4.group(0) == b9.group(0), "the XFAM_S9S1 block, delimited, byte-equal to U04's")
    if b9:
        h = hashlib.md5(b9.group(0).encode()).hexdigest()
        print("  XFAM_S9S1_SLICE_MD5 = %s (computed the way ../c9-unit04/harness/chk04.py computes it)" % h)
        val("xfam_s9s1_md5", h[:8])
    need(not re.search(r"^XU04 = ", t9, re.M) and not re.search(r"^XU01 = ", t9, re.M), "U04's own family (XU04) and U01's (XU01) are not carried")
    need(re.search(r"^XU02 = ", t9, re.M) is not None, "U02's own family (XU02) follows the carried slice")
    done()

# ---- the spoken lines -----------------------------------------------------------------------------------------------------------------
STATUS = re.compile(r"(?<![\d.,:/-])\b(?:[2-5]\d\d)\b|\b(?:two|three|four|five)[\s-]hundred[\s-]and\b|\b(?:two|three|four|five)[\s-]hundred[\s-](?:one|two|three|four|five|six|seven|eight|nine|ten)\b")
HING = re.compile(r"\b(?:bhai|yaar|dosto|kya|hai|nahi|nahin|matlab|karo|dekho|chalo|samjho|theek|accha|arre|haan|bilkul|zaroor|aur|toh|abhi|yeh|woh|kaise|kyun|bahut|thoda|sahi|galat)\b", re.I)
SPELL = re.compile(r"\b(?:API|URI|URL|RFC)s?\b")
def ledger_md5(ledger):
    t = open(ledger, encoding="utf-8").read()
    m = re.search(r"^\| C9-10a \|.*?\(89 bytes, md5 `([0-9a-f]{32})`\)", t, re.M)
    return m.group(1) if m else None
def file_md5_named():
    t = open(os.path.join(UNIT, "..", "c8-unit28", "README.md"), encoding="utf-8").read()
    m = re.search(r"^api: the pinned sentence, pinned\.txt md5 ([0-9a-f]{32})\b", t, re.M)
    return m.group(1) if m else None
def spoken(hook, pin, exq, ledger):
    import importlib.util
    spec = importlib.util.spec_from_file_location("dur9", os.path.join(HERE, "dur9.py")); m = importlib.util.module_from_spec(spec); spec.loader.exec_module(m)
    dur = getattr(m, "DUR", None)
    need(dur is not None, "dur9.py exposes its pattern (DUR)")
    need(hook == HOOK, "the hook is RED-C9-S1 #4's (S1B :574), byte for byte")
    need(len(hook.split()) == 33, "the hook: %d words (wc -w), #4's 33" % len(hook.split()))
    need(exq == EXQ, "the exercise's line is S1B :258-260's, byte for byte")
    need(len(exq.split()) == 24, "the exercise: %d words (wc -w), the brief's 24" % len(exq.split()))
    raw = open(os.path.join(UNIT, "..", "c8-unit28", "pinned.txt"), "rb").read()
    fm = hashlib.md5(raw).hexdigest(); named = file_md5_named()
    need(named is not None and fm == named, "c8-unit28/pinned.txt measures md5 %s = the md5 c8-unit28/README.md's api line names (%s) - the FILE's, %d B with its newline" % (fm, named, len(raw)))
    need(raw.endswith(b"\n") and raw[:-1].decode() == pin, "the pinned sentence = pinned.txt with ONE trailing newline stripped")
    sm = hashlib.md5(pin.encode()).hexdigest(); lm = ledger_md5(ledger) if os.path.exists(ledger) else None
    need(lm is not None and sm == lm, "the SENTENCE's md5 %s (%d B) = the ledger's C9-10a md5 (%s) - the one s902-era builders assert" % (sm, len(pin.encode()), lm))
    for name, s in (("the hook", hook), ("the pinned sentence", pin), ("the exercise", exq)):
        need(not re.search(r"\d", s), "%s holds no digit" % name)
        need(not STATUS.search(s), "%s: the status gate 0" % name)
        need(not SPELL.search(s), "%s: the spelling gate 0 (API, URI, URL, RFC bare)" % name)
        need(not HING.search(s), "%s: the Hinglish list 0" % name)
        if dur is not None: need(not dur.search(s), "%s: dur9 0 (%s)" % (name, dur.search(s).group(0) if dur.search(s) else "no hit"))
    print("  the hook: %d words · the pinned sentence: %d B, md5 %s (file %s) · the exercise: %d words" % (len(hook.split()), len(pin.encode()), sm, fm, len(exq.split())))
    val("hook_words", len(hook.split())); val("exercise_words", len(exq.split())); val("pin_md5", sm[:8]); val("pinfile_md5", fm[:8])
    done()

# ---- the table captures ---------------------------------------------------------------------------------------------------------------
ROW = re.compile(r"^-- ([A-Z]+) (/\S*) -> (\d{3}) (\S*) (\d+) \(curl exit (\d+)\)$")
ASK = re.compile(r"^-- ([\w-]+) \| ([A-Z]+) (\S+) -> (\d{3}) (\S*) (\d+)(?: bytes)? \(.*\)$")
SRV = re.compile(r"^([A-Z]+) (\S+)( \[dispatch (\w+), for (\S+)\])? -> (\d{3}) \| handler (\S+) \| post-handle (no|yes \(count (\d+)\))(?: \| ex \S+)?(?: \| thrown \S+)?(?: \| async started)? \| statements (\d+) \(writes (\d+), prepares (\d+)\)$")
ACC = re.compile(r"^([A-Z]+) (\S+?) (\d{3}) (\S+)$")
def parse(ls):
    """Blocks: '-- ' a table row or an ask; '     ' sub-lines (allow, content-length, access, server, body, body file). Other lines are
    kept as heads by these named rules: '== ' section heads and '  ' + one-line facts (cache, window, key rows, twice, listeners)."""
    rows = []; asks = []; heads = []; cur = None; win = None
    for l in ls:
        if l.startswith("-- "):
            m = ROW.match(l); a = ASK.match(l)
            if m:
                cur = {"m": m.group(1), "p": m.group(2), "st": m.group(3), "ct": m.group(4), "sz": int(m.group(5)), "rc": m.group(6), "allow": None, "set": None,
                       "cl": None, "acc": [], "srv": [], "body": None}
                (rows if win == "open" else asks).append(cur); continue
            if a:
                cur = {"lab": a.group(1), "m": a.group(2), "p": a.group(3), "st": a.group(4), "ct": a.group(5), "sz": int(a.group(6)), "acc": [], "srv": [], "body": None}
                asks.append(cur); continue
            fail("a request line the table reader cannot parse: %r" % l[:120]); cur = None; continue
        if l.startswith("     ") and cur is not None:
            t = l[5:]
            m = re.match(r"^allow: (.*) · set \{(.*)\}$", t)
            if m: cur["allow"] = m.group(1); cur["set"] = m.group(2); continue
            m = re.match(r"^content-length: ?(\d*)$", t)
            if m: cur["cl"] = m.group(1); continue
            if t.startswith("access: "):
                a = ACC.match(t[8:])
                if not a: fail("an access-log line the reader cannot parse: %r" % t[:100]); continue
                cur["acc"].append(a.groups()); continue
            if t.startswith("server: "):
                s = SRV.match(t[8:])
                if not s: fail("a witness line the reader cannot parse: %r" % t[:140]); continue
                cur["srv"].append(s.groups()); continue
            if t.startswith("body file: "): cur["body"] = None; continue
            if t.startswith("body: "): cur["body"] = t[6:]; continue
            fail("a sub-line the table reader cannot parse: %r" % t[:100]); continue
        if l.startswith("     "): fail("an indented line outside a request block: %r" % l[:100]); continue
        cur = None; heads.append(l)
        if l.startswith("  window opens"): win = "open"
        if l.startswith("  window closes"): win = "closed"
    return rows, asks, heads

def who(r):
    req = [s for s in r["srv"] if s[2] is None]; err = [s for s in r["srv"] if s[2] is not None]
    if req: return "spring"
    if err: return "tomcat+error"
    return "tomcat"
def req_line(r):
    x = [s for s in r["srv"] if s[2] is None]
    return x[0] if x else None
def head_of(heads, rx):
    for h in heads:
        m = re.search(rx, h)
        if m: return m
    return None
def rowmap(rows): return {(r["m"], r["p"]): r for r in rows}

def table(ls, db):
    rows, asks, heads = parse(ls)
    first = ls[0] if ls else ""
    want = {"pg": "PostgreSQL 18.6", "h2": "H2 2.5"}[db]
    need(first.startswith("== %s:" % db) and ("(%s)" % want) in first, "which database answered: the capture's head says %s and Flyway's line says %s" % (db, want))
    c0 = head_of(heads, r"^  cache before any request: customers (\[.*\])"); c1 = head_of(heads, r"^  cache after one health check: customers (\[.*\])")
    need(c0 is not None and c0.group(1) == "[]", "the customers cache right after the Started line: empty (%s)" % (c0.group(1) if c0 else "no line"))
    need(c1 is not None and c1.group(1) == "[SimpleKey []]", "after one GET /actuator/health: warm, [SimpleKey []] (U04's resolution: the kitchen's health reads the cached list)")
    h0 = [a for a in asks if a.get("lab") == "health0"]
    st0 = h0[0]["srv"][0][9] if h0 and h0[0]["srv"] else None
    need(st0 == "1", "the health check's own statements: %s (the one read that fills the cache)" % st0)
    # the window: 36 rows, in the receipt's order, each with one access line and its own witness
    need([(r["m"], r["p"]) for r in rows] == [(m, p) for p in ADDRS for m in METHODS], "the window holds the 36 requests, 4 addresses x 9 methods, in order (%d rows)" % len(rows))
    wo = head_of(heads, r"^  window opens after access-log line (\d+)$"); wc = head_of(heads, r"^  window closes at access-log line (\d+): (\d+) lines$")
    need(wo is not None and wc is not None and int(wc.group(1)) - int(wo.group(1)) == int(wc.group(2)) == len(rows) == 36, "the access log's window: %s lines = the requests sent (36); the over-long request line is not sent (U03's)" % (wc.group(2) if wc else "?"))
    for r in rows:
        tag = "%s %s" % (r["m"], r["p"])
        a = r["acc"]
        if len(a) != 1 or a[0][0] != r["m"] or a[0][1].rstrip("-") != r["p"] or a[0][2] != r["st"]: fail("%s: its one access-log line (%s)" % (tag, a)); continue
        q = req_line(r)
        if q and (q[0] != r["m"] or q[1] != r["p"] or q[5] != r["st"]): fail("%s: the request witness's line names %s %s -> %s" % (tag, q[0], q[1], q[5]))
        if r["allow"] is None or r["cl"] is None: fail("%s: no allow or content-length line" % tag)
        if r["set"] is not None and aset(r["allow"]) != r["set"]: fail("%s: Allow as sent (%s) read as a set is not the printed set {%s}" % (tag, r["allow"], r["set"]))
        for s in r["srv"]:
            if s[10] != "0": fail("%s: a witness line with writes %s" % (tag, s[10]))
    ok("every row: one access-log line (method, path, status = curl's), the witness's REQUEST line (when present) names the same request, writes 0 on every line")
    rm = rowmap(rows)
    # (a) the pinned sentence's facts
    pr = rm.get(("PATCH", "/customers"))
    c8 = None
    for l in lines(os.path.join(UNIT, "..", "c8-unit28", "README.md")):
        m = re.match(r"^PATCH /customers -> (\d{3}) · Allow \(as a set, sorted\): ([A-Z, ]+) · Content-Type: (\S+) · body (\{.*\})$", l)
        if m: c8 = m.groups(); break
    need(c8 is not None, "Course 8 U28's own comparison line read off c8-unit28/README.md (PATCH /customers -> …)")
    if pr and c8:
        need(pr["st"] == "405" and pr["set"] == "GET,POST" and pr["ct"] == "application/problem+json", "(a) the pinned sentence's facts on this tree: PATCH /customers -> %s · Allow as a set {%s} · %s" % (pr["st"], pr["set"], pr["ct"]))
        need((pr["st"], aset(c8[1]), pr["ct"]) == (c8[0], aset(c8[2 - 1]), c8[2]), "= Course 8 U28's line: %s · {%s} · %s" % (c8[0], aset(c8[1]), c8[2]))
        try:
            same = json.dumps(json.loads(pr["body"]), sort_keys=True) == json.dumps(json.loads(c8[3]), sort_keys=True)
        except Exception as e:
            same = False; fail("(a) the PATCH body could not be read as JSON (%s)" % e.__class__.__name__)
        need(same, "(a) the PATCH /customers body = Course 8 U28's, key for key (%s)" % pr["body"])
        print("  (a) Allow as sent on this JVM: %s (a hash-order list: the set is the fact)" % pr["allow"])
    # (b) the two Allow lines
    pu = rm.get(("PUT", "/customers")); op = rm.get(("OPTIONS", "/customers"))
    if pu and op:
        gap = sorted(set(op["set"].split(",")) - set(pu["set"].split(",")))
        print("  (b) PUT /customers -> %s · Allow: %s  |  OPTIONS /customers -> %s · Allow: %s  |  served but absent from the 405's Allow: %s" % (pu["st"], pu["allow"], op["st"], op["allow"], ", ".join(gap)))
        need(pu["st"] == "405" and op["st"] == "200" and gap == ["HEAD", "OPTIONS"], "(b) the 405's Allow lists fewer methods than OPTIONS: it leaves HEAD and OPTIONS out")
    # (c) inert against the boundary's pre-key table
    if os.path.exists(BR8):
        b = {}; on = False
        for l in lines(BR8):
            if l.startswith("### the method table over the socket"): on = True; continue
            if on and l.startswith("###"): break
            if on:
                m = re.match(r"^  ([A-Z]+) (/\S*) -> (\d{3}) (\S*) (\d+) \(curl (\d+)\) · Allow: (.*?) · Content-Length: (\d*) · body \d+ B$", l)
                if not m: fail("(c) a boundary row the reader cannot parse: %r" % l[:100]); continue
                b[(m.group(1), m.group(2))] = (m.group(3), m.group(4), int(m.group(5)), aset(m.group(7)), m.group(8))
        moved = []
        for k, r in rm.items():
            o = b.get(k)
            if o is None: moved.append("%s %s: not in the boundary's table" % k); continue
            mine = (r["st"], r["ct"], r["sz"], r["set"], r["cl"])
            if mine != o: moved.append("%s %s: %s (boundary %s)" % (k[0], k[1], mine, o))
        for x in moved: print("  (c) moved: " + x)
        need(len(b) == 36 and not moved, "(c) inert: the 36 rows (status, content type, size_download, Allow as a set, Content-Length) = the boundary's B8 census-mid table (4.1.3 + Tomcat 11.0.29, before the key), %d moved" % len(moved))
        pc = rm.get(("POST", "/customers"))
        if pc: print("  (c) POST /customers (the address the key filter registers): %s %s %d - as before the key; its witness: handler %s" % (pc["st"], pc["ct"], pc["sz"], req_line(pc)[6] if req_line(pc) else "none"))
        val("inert_moved", len(moved))
    else:
        print("  (c) the boundary's table is not on this machine (%s): inert not compared" % BR8); val("inert_moved", "not-compared")
    k1 = head_of(heads, r"^  key table rows after the table: (\d+) "); k2 = head_of(heads, r"^  key table rows at the end: (\d+) ")
    need(k1 is not None and k2 is not None and k1.group(1) == "0" and k2.group(1) == "0", "S9.21: the key table's rows, read by a second client: 0 after the table, 0 at the end")
    # (d) the 15th code
    a5 = head_of(heads, r"^  access log in all: (\d+) lines · status 500: (\d+)(.*)$")
    need(a5 is not None and a5.group(2) == "0", "(d) a 500 in this JVM's access log: %s%s" % (a5.group(2) if a5 else "?", a5.group(3) if a5 else ""))
    # (e) derived numbers
    dist = collections.Counter(r["st"] for r in rows)
    print("  (e) status distribution: " + " · ".join("%s x%d" % (k, dist[k]) for k in sorted(dist)))
    sets = sorted(set(r["set"] for r in rows if r["set"]))
    print("  (e) distinct Allow sets: %d (%s)" % (len(sets), " | ".join("{%s}" % s for s in sets)))
    for p in GETS:
        g = rm[("GET", p)]; h = rm[("HEAD", p)]
        need(g["cl"] == str(g["sz"]) and h["cl"] == g["cl"] and h["sz"] == 0, "(e) GET %s Content-Length %s = its %d bytes; HEAD's Content-Length %s, size_download %d" % (p, g["cl"], g["sz"], h["cl"], h["sz"]))
    cls = collections.Counter(who(r) for r in rows)
    val("requests", len(rows)); val("tomcat_refused", cls["tomcat"] + cls["tomcat+error"]); val("spring", cls["spring"])
    for k in sorted(dist): val("s%s" % k, dist[k])
    val("allow_sets", len(sets)); val("cl", "/".join(rm[("GET", p)]["cl"] for p in GETS)); val("pin", "%s:%s:%s" % (pr["st"], pr["set"], pr["ct"]) if pr else "none")
    # safe: each GET twice
    tw = {}
    for h in heads:
        m = re.match(r"^  twice (\w+): (byte-identical|DIFFERENT)$", h)
        if m: tw[m.group(1)] = m.group(2)
    labs = ["customers", "ravi", "revenue", "veg", "dashjson", "dashhtml", "form", "kitchen"]
    need(sorted(tw) == sorted(labs) and all(v == "byte-identical" for v in tw.values()), "safe: each of %d GETs asked twice, the second answer byte-identical to the first (cmp)" % len(tw))
    am = {a["lab"]: a for a in asks if "lab" in a}
    stl = []
    for lab in labs:
        x = [am.get(lab + "-1"), am.get(lab + "-2")]
        if None in x or not all(y["srv"] for y in x): fail("safe: %s has no witness line" % lab); continue
        w = [y["srv"][0][10] for y in x]; s = [y["srv"][0][9] for y in x]
        if w != ["0", "0"]: fail("safe: %s writes %s" % (lab, w))
        stl.append("%s %s/%s" % (lab, s[0], s[1]))
    print("  safe: statements, first/second ask: " + " · ".join(stl))
    val("safe_twice", len(tw)); val("st_ravi_table", rm[("GET", "/customers/Ravi")]["srv"][0][9]); val("st_revenue", rm[("GET", "/revenue")]["srv"][0][9])
    val("st_dashboard", am["dashjson-1"]["srv"][0][9] if am.get("dashjson-1") and am["dashjson-1"]["srv"] else "?")
    # the feed
    l0 = head_of(heads, r"^  listeners before: (\d+)$"); l1 = head_of(heads, r"^  listeners after the client left: (\d+)$"); l2 = head_of(heads, r"^  listeners again: (\d+)$")
    fd = [a for a in asks if a.get("lab") == "feed"]
    need(fd and fd[0]["st"] == "200" and fd[0]["ct"] == "text/event-stream" and "reader exit 0" in " ".join(ls[ls.index(next(l for l in ls if l.startswith("-- feed |")))].split()), "the feed: 200 text/event-stream, read to its first event by a count condition, closed by the reader (exit 0)")
    lv = tuple(x.group(1) if x else "?" for x in (l0, l1, l2))
    need(lv == ("0", "1", "1"), "the feed's listeners: %s before -> %s after the client left -> %s again (a GET that keeps state for a client that has gone; never voiced here)" % lv)
    val("listeners", "->".join(lv))
    done()

# ---- the views (head, who, trace, safe, cross) ------------------------------------------------------------------------------------------
def load(p):
    rows, asks, heads = parse(lines(p))
    return rowmap(rows), rows, asks, heads

def view(kind, pg, h2):
    sides = (("pg", "PostgreSQL") + load(pg), ("h2", "H2") + load(h2))
    if BAD: print("RESULT the table captures could not be read"); sys.exit(1)
    if kind == "head":
        for db, name, rm, rows, asks, heads in sides:
            for p in ADDRS:
                g = rm[("GET", p)]; h = rm[("HEAD", p)]; gq = req_line(g); hq = req_line(h)
                print("RESULT %s %s | GET -> %s cl %s %dB | handler %s post-handle %s statements %s | HEAD -> %s cl %s %dB | handler %s post-handle %s statements %s"
                      % (name, p, g["st"], g["cl"] or "-", g["sz"], gq[6] if gq else "-", gq[7] if gq else "-", gq[9] if gq else "-",
                         h["st"], h["cl"] or "-", h["sz"], hq[6] if hq else "-", hq[7] if hq else "-", hq[9] if hq else "-"))
        sys.exit(1 if BAD else 0)
    if kind == "who":
        for db, name, rm, rows, asks, heads in sides:
            for r in rows:
                q = req_line(r); e = [s for s in r["srv"] if s[2]]
                print("RESULT %s %s %s -> %s | %s | %s" % (name, r["m"], r["p"], r["st"], who(r),
                      ("handler " + q[6]) if q else (("ERROR dispatch %s %s, handler %s" % (e[0][0], e[0][1], e[0][6])) if e else "no witness line; access log: %s" % " ".join(r["acc"][0]))))
        sys.exit(1 if BAD else 0)
    if kind == "trace":
        for db, name, rm, rows, asks, heads in sides:
            for p in ADDRS:
                t = rm[("TRACE", p)]; e = [s for s in t["srv"] if s[2]]
                print("RESULT %s TRACE %s -> %s %s %dB · Allow set {%s} · witness: %s · body %s" % (name, p, t["st"], t["ct"], t["sz"], t["set"],
                      "; ".join("%s %s [dispatch %s, for %s] handler %s post-handle %s statements %s" % (s[0], s[1], s[3], s[4], s[6], s[7], s[9]) for s in t["srv"]) or "none", t["body"]))
        sys.exit(1 if BAD else 0)
    if kind == "safe":
        for db, name, rm, rows, asks, heads in sides:
            for a in asks:
                if "lab" in a and a["srv"]:
                    s = a["srv"][0]; print("RESULT %s %s %s -> %s | handler %s | statements %s writes %s" % (name, a["lab"], a["p"], a["st"], s[6], s[9], s[10]))
            for p in ADDRS:
                r = rm[("POST", p)]; q = req_line(r)
                print("RESULT %s write-route POST %s -> %s | handler %s" % (name, p, r["st"], q[6] if q else "none"))
            for h in heads:
                if re.match(r"^  (listeners|key table rows|twice|cache)", h): print("RESULT %s %s" % (name, h.strip()))
        u1 = [l for l in lines(os.path.join(UNIT, "..", "c9-unit01", "README.md")) if l.startswith("TiffinBoxServer 7 (")]
        print("RESULT U01's mappings row (c9-unit01/README.md, its mappings capture): %s" % (u1[0] if u1 else "absent"))
        sys.exit(1 if BAD else 0)
    if kind == "cross":
        for k in sides[0][2]:
            a = sides[0][2][k]; b = sides[1][2][k]
            ha = (a["st"], a["ct"], a["sz"], a["set"], a["cl"], tuple(a["acc"][0]) if a["acc"] else None, who(a), a["body"])
            hb = (b["st"], b["ct"], b["sz"], b["set"], b["cl"], tuple(b["acc"][0]) if b["acc"] else None, who(b), b["body"])
            sa = "/".join(s[9] for s in a["srv"]) or "-"; sb = "/".join(s[9] for s in b["srv"]) or "-"
            print("RESULT %s %s | HTTP %s | statements PostgreSQL %s · H2 %s%s" % (k[0], k[1], "equal" if ha == hb else "DIFFERENT %s vs %s" % (ha, hb), sa, sb, "" if sa == sb else " (differs)"))
        sys.exit(1 if BAD else 0)
    fail("unknown view %r" % kind); sys.exit(1)

def results(ls):
    out = []
    for l in ls:
        if l.startswith("RESULT "): out.append(l[7:])
        elif l.strip() and not l.startswith("FAIL") and not l.startswith("ok "): fail("a view line the reader cannot parse: %r" % l[:100])
    return out

def c_head(ls):
    rs = results(ls); n = 0
    for r in rs:
        m = re.match(r"^(PostgreSQL|H2) (\S+) \| GET -> (\d+) cl (\S+) (\d+)B \| handler (\S+) post-handle (\S+(?: \(count \d+\))?) statements (\S+) \| HEAD -> (\d+) cl (\S+) (\d+)B \| handler (\S+) post-handle (\S+(?: \(count \d+\))?) statements (\S+)$", r)
        if not m: fail("a head line the reader cannot parse: %r" % r[:100]); continue
        db, p, gs, gcl, gsz, gh, gph, gst, hs, hcl, hsz, hh, hph, hst = m.groups(); n += 1
        if p in GETS:
            gc = re.search(r"count (\d+)", gph); hc = re.search(r"count (\d+)", hph)
            need(gh == hh != "-" and gc and hc and int(hc.group(1)) == int(gc.group(1)) + 1, "%s HEAD %s runs the GET handler %s: post-handle count %s -> %s" % (db, p, hh, gc.group(1) if gc else "?", hc.group(1) if hc else "?"))
            need(hcl == gcl and hsz == "0", "%s HEAD %s: Content-Length %s = GET's, 0 bytes sent (size_download)" % (db, p, hcl))
            if p == "/revenue": need(hst == gst == "1", "%s HEAD /revenue runs its statement: %s, as the GET's %s (uncached)" % (db, hst, gst)); val("revenue_head_%s" % {"PostgreSQL": "pg", "H2": "h2"}[db], hst)
            if p == "/customers": need(hst == "0", "%s HEAD /customers: statements %s (warm - R.312's negation: a route whose read is cached)" % (db, hst))
        else:
            need(hs == "405" and hh in ("-", "none"), "%s HEAD /shutdown: %s, no handler selected (its GET is %s too)" % (db, hs, gs))
    need(n == 8, "head: 4 addresses x 2 databases (%d)" % n)
    val("head_ph", "+1"); done()

def c_who(ls):
    rs = results(ls); per = collections.defaultdict(collections.Counter); meth = collections.defaultdict(set); n = 0
    for r in rs:
        m = re.match(r"^(PostgreSQL|H2) ([A-Z]+) (\S+) -> (\d+) \| (spring|tomcat|tomcat\+error) \| (.*)$", r)
        if not m: fail("a who line the reader cannot parse: %r" % r[:100]); continue
        db, mt, p, st, c, w = m.groups(); n += 1; per[db][c] += 1; meth[(db, c)].add(mt)
        if c == "tomcat+error" and "handler BasicErrorController#error" not in w: fail("%s %s %s: an ERROR dispatch not written by BasicErrorController" % (db, mt, p))
    for db in ("PostgreSQL", "H2"):
        c = per[db]
        need(c["tomcat"] + c["tomcat+error"] + c["spring"] == 36, "%s: 36 rows classed" % db)
        need(meth[(db, "tomcat")] == {"CONNECT"} and c["tomcat"] == 4, "%s: Tomcat alone (no witness line, an access-log line): CONNECT x%d" % (db, c["tomcat"]))
        need(meth[(db, "tomcat+error")] == {"TRACE"} and c["tomcat+error"] == 4, "%s: Tomcat, then Spring's /error (an ERROR-dispatch line only): TRACE x%d" % (db, c["tomcat+error"]))
        need("CONNECT" not in meth[(db, "spring")] and "TRACE" not in meth[(db, "spring")], "%s: Spring MVC answered the other %d (a REQUEST-dispatch line each)" % (db, c["spring"]))
    need(n == 72, "who: 36 rows x 2 databases (%d)" % n)
    val("tomcat_refused", per["H2"]["tomcat"] + per["H2"]["tomcat+error"]); val("tomcat_alone", per["H2"]["tomcat"]); val("tomcat_error", per["H2"]["tomcat+error"]); val("spring", per["H2"]["spring"])
    done()

def c_trace(ls):
    rs = results(ls); n = 0; sizes = []
    for r in rs:
        m = re.match(r"^(PostgreSQL|H2) TRACE (\S+) -> (\d+) (\S+) (\d+)B · Allow set \{(.*)\} · witness: (.*) · body (.*)$", r)
        if not m: fail("a trace line the reader cannot parse: %r" % r[:100]); continue
        db, p, st, ct, sz, al, wit, body = m.groups(); n += 1
        ws = wit.split("; ")
        need(st == "405" and ct == "application/json", "%s TRACE %s -> %s %s" % (db, p, st, ct))
        need(len(ws) == 1 and "[dispatch ERROR, for %s]" % p in ws[0] and "handler BasicErrorController#error" in ws[0] and ws[0].endswith("statements 0"), "%s TRACE %s: ONE witness line, the ERROR dispatch, BasicErrorController#error, statements 0 - no request-dispatch line, no TiffinBox handler" % (db, p))
        try:
            d = json.loads(body)
        except Exception as e:
            fail("%s TRACE %s: the body is not JSON (%s)" % (db, p, e.__class__.__name__)); continue
        need(sorted(d) == ["error", "path", "status", "timestamp"] and d["timestamp"] == "<time>" and d["status"] == 405 and d["path"] == p, "%s TRACE %s: Boot's /error body, exactly four keys (timestamp masked), path %s" % (db, p, p))
        if db == "H2": sizes.append(sz)
        if db == "H2" and p == "/customers": val("trace_bytes", sz); val("trace_allow", al.replace(",", "/"))
        if db == "H2" and p == "/customers": val("error_dispatch_method", ws[0].split()[0])
    need(n == 8, "trace: 4 addresses x 2 databases (%d)" % n)
    done()

def c_safe(ls):
    rs = results(ls); st = {}; n = 0
    for r in rs:
        m = re.match(r"^(PostgreSQL|H2) ([\w-]+) (\S+) -> (\d+) \| handler (\S+) \| statements (\d+) writes (\d+)$", r)
        if m:
            n += 1
            if m.group(7) != "0": fail("%s %s: writes %s" % (m.group(1), m.group(2), m.group(7)))
            st[(m.group(1), m.group(2))] = m.group(6); continue
        if re.match(r"^(PostgreSQL|H2) (write-route|listeners|key table rows|twice|cache)", r) or r.startswith("U01's mappings row"): continue   # named rule: printed facts, checked by table
        fail("a safe line the reader cannot parse: %r" % r[:100])
    need(n > 0, "safe: %d asks outside the table, writes 0 on every one" % n)
    for db in ("PostgreSQL", "H2"):
        print("  %s statements: " % db + " · ".join("%s %s" % (k[1], v) for k, v in sorted(st.items()) if k[0] == db))
    need(all(st.get((d, "health0")) == "1" for d in ("PostgreSQL", "H2")), "the first health check reads once on both databases")
    wr = [r for r in rs if " write-route " in r]
    need(len(wr) == 8, "the write routes the table touched, named with their answers (POST on the four addresses, both databases)")
    val("st_dashboard_pg", st.get(("PostgreSQL", "dashjson-1"))); val("st_dashboard_h2", st.get(("H2", "dashjson-1")))
    done()

def c_cross(ls):
    rs = results(ls); n = 0; d = 0; sd = []
    for r in rs:
        m = re.match(r"^([A-Z]+) (\S+) \| HTTP (equal|DIFFERENT.*) \| statements PostgreSQL (\S+) · H2 (\S+)( \(differs\))?$", r)
        if not m: fail("a cross line the reader cannot parse: %r" % r[:100]); continue
        n += 1
        if m.group(3) != "equal": d += 1; print("  moved: %s %s %s" % (m.group(1), m.group(2), m.group(3)[:200]))
        if m.group(6): sd.append("%s %s (%s vs %s)" % (m.group(1), m.group(2), m.group(4), m.group(5)))
    need(n == 36, "cross: 36 rows")
    need(d == 0, "(f) PostgreSQL and H2: every HTTP column equal (status, content type, size_download, Allow as a set, Content-Length, access line, who answered, body) - %d differ" % d)
    print("  the statement column: %s" % ("equal on every row" if not sd else "differs on " + "; ".join(sd)))
    val("cross_http_diff", d); val("cross_stmt_diff", len(sd)); done()

# ---- xhead, mockmvc -----------------------------------------------------------------------------------------------------------------------
def c_xhead(ls):
    t = "\n".join(ls)
    g = re.search(r"^  GET /customers -> 200 (\d+) \(curl exit 0\)$", t, re.M)
    i = re.search(r"^  curl -I /customers -> (\d+) (\d+) \(curl exit (\d+)\) · Content-Length: (\d+)$", t, re.M)
    x = re.search(r"^  curl -X HEAD /customers -> (\d+) (\d+) \(curl exit (\d+)\) · headers received: HTTP/1.1 (\d+) *· Content-Length: (\d+)$", t, re.M)
    s = re.search(r"^  curl said: curl: \(28\) Operation timed out after <masked> with (\d+) out of (\d+) bytes received$", t, re.M)
    if not (g and i and x and s): fail("xhead: a line the reader cannot parse or a line missing (GET %s, -I %s, -X HEAD %s, said %s)" % tuple(bool(y) for y in (g, i, x, s))); done()
    n = g.group(1)
    need(i.group(1) == "200" and i.group(2) == "0" and i.group(3) == "0" and i.group(4) == n, "the control: curl -I -> 200, exit 0, Content-Length %s, 0 bytes" % i.group(4))
    need(x.group(3) == "28" and x.group(4) == "200" and x.group(5) == n, "curl -X HEAD: the server answered 200 with Content-Length %s; curl exit %s" % (x.group(5), x.group(3)))
    need(s.group(1) == "0" and s.group(2) == n, "curl waited for the %s bytes the Content-Length announced and got %s (the length derived from the same JVM's GET)" % (s.group(2), s.group(1)))
    need("the harness's alarm - never a result" in t, "the cap is printed as the harness's alarm, never as a result")
    val("xhead_exit", x.group(3)); val("xhead_wanted", s.group(2)); val("i_exit", i.group(3)); done()

MM = re.compile(r"^MOCKMVC ([A-Z]+) (\S+) -> (\d{3}) · Allow (.*?) · Content-Length (\S+) · body (\d+) B · Content-Type (\S+)$")
def c_mockmvc(ls):
    mm = {}; rest = []
    for l in ls:
        if l.startswith("MOCKMVC "):
            m = MM.match(l)
            if not m: fail("a MOCKMVC line the reader cannot parse (an exception MockMvc let through counts here too): %r" % l[:120]); continue
            mm[(m.group(1), m.group(2))] = m.groups()
        else: rest.append(l)
    t = "\n".join(rest)
    b = re.search(r"exit (\d+) · Downloading/Downloaded from: 0 · listeners on 20910-20919 during the build \(sampled\): at most (\d+)$", t, re.M)
    r = re.search(r"^Tests run: (\d+), Failures: (\d+), Errors: (\d+), Skipped: (\d+) -- in com\.tiffinbox\.web\.ProbeMethodTableTest$", t, re.M)
    cp = re.search(r"the test's class path \(its Surefire report\): (.*)$", t, re.M)
    need(b is not None and b.group(1) == "0", "the harness's test copy built offline and its one test class ran: exit %s" % (b.group(1) if b else "?"))
    need(b is not None and b.group(2) == "0", "socketless: no listener on 20910-20919 during the build (sampled)")
    need(r is not None and r.groups() == ("1", "0", "0", "0"), "Tests run: 1, Failures: 0 - the harness's own line, never the anchor's count")
    need(cp is not None and "spring-test-7.0.11.jar" in cp.group(1) and "spring-boot-webmvc-test-4.1.3.jar" in cp.group(1), "S9.19: the MockMvc facts' class path: %s" % (cp.group(1) if cp else "?"))
    need(list(mm) == [(m, p) for p in ADDRS for m in METHODS], "36 MOCKMVC lines, 4 paths x 9 methods (%d)" % len(mm))
    sp = os.path.join(os.path.dirname(os.path.abspath(sys.argv[2])), ".r-table.new")
    if not os.path.exists(sp): sp = sp[:-4] + ".out"
    rows, asks, heads = parse(lines(sp)); rm = rowmap(rows)
    kinds = collections.Counter(); raw = []; unexplained = []
    for k, (m, p, st, al, cl, bb, ct) in mm.items():
        s = rm.get(k)
        if s is None: unexplained.append("%s %s: no socket row" % k); continue
        diffs = []
        if st != s["st"]: diffs.append("status %s vs %s" % (st, s["st"]))
        if aset(al) != (s["set"] or ""): diffs.append("Allow {%s} vs {%s}" % (aset(al), s["set"]))
        mcl = "" if cl == "-" else cl
        if mcl != (s["cl"] or ""): diffs.append("Content-Length %s vs %s" % (cl, s["cl"] or "-"))
        if m == "HEAD" and int(bb) != s["sz"]: diffs.append("body bytes %s vs %d" % (bb, s["sz"]))
        elif m != "HEAD" and st == s["st"] and not st.startswith("2") and int(bb) != s["sz"]: diffs.append("body bytes %s vs %d" % (bb, s["sz"]))   # named rule: a 2xx GET's body is the stand-ins' data, not compared
        for d in diffs:
            raw.append("%s %s: %s" % (m, p, d))
            if m == "TRACE": kinds["TRACE's status (and its echo)"] += 1
            elif m == "CONNECT": kinds["CONNECT's status"] += 1
            elif m == "HEAD" and d.startswith("body bytes"): kinds["HEAD's body bytes"] += 1
            elif d.startswith("Content-Length"): kinds["Content-Length absent"] += 1
            else: unexplained.append("%s %s: %s" % (m, p, d))
    for x in raw: print("  raw difference: " + x)
    print("  difference kinds (the named grouping rule: a TRACE row's differences are one kind, a CONNECT row's one, a HEAD row's body bytes one, any other missing Content-Length one): " + " · ".join("%s x%d lines" % (k, v) for k, v in sorted(kinds.items())))
    need(not unexplained, "every difference belongs to one of the four kinds (%d unexplained: %s)" % (len(unexplained), "; ".join(unexplained[:3])))
    need(len(kinds) == 4, "MockMvc differs from the socket on four kinds (%d); %d raw difference lines" % (len(kinds), len(raw)))
    tr = mm[("TRACE", "/customers")]
    need(tr[2] == "200" and tr[6] == "message/http", "the voiced difference: TRACE through MockMvc -> %s %s (the socket: %s)" % (tr[2], tr[6], rm[("TRACE", "/customers")]["st"]))
    eqm = [m for m in ("GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS") if all(mm[(m, p)][2] == rm[(m, p)]["st"] and aset(mm[(m, p)][3]) == (rm[(m, p)]["set"] or "") for p in ADDRS)]
    need(eqm == ["GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS"], "status and Allow equal for GET / POST / PUT / DELETE / PATCH / OPTIONS on all four addresses")
    val("mockmvc_lines", len(mm)); val("mockmvc_kinds", len(kinds)); val("mockmvc_raw", len(raw)); val("mockmvc_trace", tr[2]); val("tests_run", r.group(1) if r else "?")
    done()

# ---- seven, surface, exercise -----------------------------------------------------------------------------------------------------------
def c_seven(ls):
    m = [x for l in ls for x in [re.search(r"^  the seven: ([0-9a-f]{32}) \((\d+) lines\) · expected ([0-9a-f]{32})$", l)] if x]
    if not m: fail("no 'the seven:' line"); done()
    g = m[0]
    need(g.group(1) == g.group(3), "the seven on after/ = the expected %s (= U04's inert: seven=)" % g.group(3))
    val("seven", g.group(1)); done()

def c_surface(ls):
    m = [x for l in ls for x in [re.search(r"^  the old surface: ([0-9a-f]{32}) \((\d+) requests, (\d+) lines\) · expected ([0-9a-f]{32})$", l)] if x]
    if not m: fail("no 'the old surface:' line"); done()
    g = m[0]
    need(g.group(1) == g.group(4), "the old surface on after/ = the expected %s (%s requests, %s lines; = U04's inert: surface=)" % (g.group(4), g.group(2), g.group(3)))
    p = [x for l in ls for x in [re.search(r"planted: the seven ([0-9a-f]{32}) \(unchanged: (\w+)\) · the old surface ([0-9a-f]{32}) \(moved: (\w+)\) · the feed's line: .*-> +(\S*) *(\S*) *(\d+) \(reader exit (\d+)\)", l)] if x]
    need(bool(p) and p[0].group(2) == "yes" and p[0].group(4) == "yes" and p[0].group(7) == "0" and p[0].group(8) == "3", "the S9.14 plant: the seven unchanged, the surface moved, the feed answers nothing (0 bytes, reader exit 3)")
    val("surface", g.group(1)); val("surface_requests", g.group(2)); val("surface_lines", g.group(3)); val("surface_plant", p[0].group(3) if p else "none")
    done()

def normallow(l):
    m = re.match(r"^(\s*Allow: )(.*)$", l, re.I)
    return (m.group(1) + aset(m.group(2))) if m else l

def c_exercise(ls):
    secs = {}; cur = None
    for l in ls:
        m = re.match(r"^== the exercise, (\w+), (\w+) ", l)
        if m: cur = (m.group(1), m.group(2)); secs[cur] = []; continue
        if l.startswith("== "): cur = None; continue
        if cur and l.startswith("  ") and (not secs[cur] or not re.match(r"^(PASS|FAIL):", secs[cur][-1])): secs[cur].append(l[2:])   # named rule: a try's lines end at its verdict
    want = {"broken": ("28", "none", "FAIL"), "solved": ("0", "OPTIONS,POST", "PASS"), "ionly": ("0", "none", "FAIL"), "custopts": ("0", "GET,HEAD,OPTIONS,POST", "FAIL"), "headkept": ("28", "none", "FAIL")}
    for (v, sh), out in sorted(secs.items()):
        t = "\n".join(out)
        m = re.search(r"^curl exit (\d+)\n(PASS|FAIL): curl exit (\S+) · (?:the methods shutdown allows: |Allow )(\S+)$", t, re.M)
        got = (m.group(1), m.group(4), m.group(2)) if m and m.group(1) == m.group(3) else None
        need(got == want.get(v), "%s under %s: curl exit %s · Allow %s · %s" % (v, sh, *(want.get(v, ("?", "?", "?")))))
    need(len(secs) == 10, "five tries x two shells: %d" % len(secs))
    rd = [l.split("README: ", 1)[1] for l in ls if l.startswith("  README: ")]; so = [l.split("SOLUTION: ", 1)[1] for l in ls if l.startswith("  SOLUTION: ")]
    for name, w, k in (("README.md", rd, ("broken", "bash")), ("SOLUTION.md", so, ("solved", "bash"))):
        got = secs.get(k, [])
        need([normallow(x) for x in w] == [normallow(x) for x in got], "%s's What it prints = the %s run's output (Allow read as a set)" % (name, k[0]))
    val("exercise", "broken-FAIL,solved-PASS,ionly-FAIL,custopts-FAIL,headkept-FAIL")
    done()

# ---- hashable, values -------------------------------------------------------------------------------------------------------------------
def hashable(nm, p):
    """The capture as published, minus the guard's load lines; every Allow list read as a sorted set (the order Spring MVC sends is a
    hash order that moved between JVM starts in this unit's own runs - the set is the fact; the order as sent stays on the capture)."""
    for l in lines(p):
        if re.match(r"^  guard before ", l): continue
        l = re.sub(r"load1 [0-9.]+", "load1 <n>", l)
        l = re.sub(r"^(     allow: ).*? · (set \{.*\})$", r"\1\2", l)
        l = re.sub(r"( · Allow )([A-Z][A-Z, ]*?)( · Content-Length )", lambda m: m.group(1) + aset(m.group(2)) + m.group(3), l)
        l = re.sub(r"(Allow: )([A-Z][A-Z, ]*)$", lambda m: m.group(1) + aset(m.group(2)), l)
        l = re.sub(r"(Allow as sent on this JVM: )(.*?)( \(a hash-order)", r"\1<order>\3", l)
        l = re.sub(r"(\| OPTIONS /customers -> \d+ · Allow: )([^|]*?)(  \|)", lambda m: m.group(1) + aset(m.group(2)) + m.group(3), l)
        l = re.sub(r"(PUT /customers -> \d+ · Allow: )([^|]*?)(  \|)", lambda m: m.group(1) + aset(m.group(2)) + m.group(3), l)
        sys.stdout.write(l + "\n")

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

CAPS = {"tablepg": lambda ls: table(ls, "pg"), "table": lambda ls: table(ls, "h2"), "xhead": c_xhead, "head": c_head, "who": c_who, "trace": c_trace,
        "safe": c_safe, "cross": c_cross, "mockmvc": c_mockmvc, "seven": c_seven, "surface": c_surface, "exercise": c_exercise}

if __name__ == "__main__":
    a = sys.argv[1:]
    try:
        if not a: fail("no mode"); done()
        if a[0] == "static": static(a[1])
        elif a[0] == "spoken": spoken(a[1], a[2], a[3], a[4])
        elif a[0] == "view": view(a[1], a[2], a[3])
        elif a[0] == "hashable": hashable(a[1], a[2])
        elif a[0] == "values": values(a[1], a[2])
        elif a[0] in CAPS: CAPS[a[0]](lines(a[1]))
        else: fail("unknown mode %r" % a[0]); done()
    except SystemExit:
        raise
    except Exception as e:
        print("FAIL the checker could not read its input (%s: %s)" % (e.__class__.__name__, str(e)[:160])); sys.exit(1)
