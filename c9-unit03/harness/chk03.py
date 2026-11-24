"""Course 9 unit 03's checker (python3 -I -B harness/chk03.py MODE ...). Every number the README may say is re-derived here from a capture's
own lines (or a shipped file), never typed. Each listing line a check reads is parsed by a named pattern or skipped by a named rule; a line
it cannot parse is a FAIL line and exit 1, never a traceback. The shape is U02's chk02.py (copied from U02's harness, cut to this unit).
Modes:
  static LEDGER            the prose gate's carried slices (s903.py against U04's s904.py, U01's s901.py and U02's s902.py), XFAM_S9S1's md5
  hook | exq               print the brief's spoken lines (typed ONCE, here; asserted byte-equal to S1B :273 and :290 by `spoken`)
  spoken HOOK EXQ GLOSS    the spoken lines: byte-equal to the brief, words, digits, spellings, statuses, Hinglish, dur9
  view KIND PG H2          census / authors / six / conditional / limits / cannot / five / inert / instance / cross, read off both matrices
  <capture> FILE           one capture's checks; prints ok/FAIL lines and one VALUES line (a view is recomputed from its sibling matrices)
  hashable NAME FILE       the capture with its load-dependent lines dropped and every Allow list read as a set, for receipts.md5
  values README VALS       README.md's values block = this run's VALUES lines

THE AUTHOR RULE (S9.31, RED-C9-S1 #22) - function author(); its classes are the names in CLASSES (the brief's seven + one the run found). The author of a response is the
part of the server that wrote its status line and body, read off the request's own witnesses, in this order:
  (1) an ERROR-dispatch witness line exists                      -> Boot's /error (BasicErrorController wrote the body on the ERROR dispatch)
  (2) no REQUEST-dispatch witness line exists                    -> Tomcat (no filter ran; the access log holds the request's only line)
  (3) the resolver's line names an advice                         -> TiffinBox's advice (TiffinBoxErrors) or Boot's problem-details handler
                                                                     (ProblemDetailsExceptionHandler) - ExceptionHandlerExceptionResolver's own
                                                                     DEBUG line "Using @ExceptionHandler <class>#<method>"
  (4) the selected handler is ResourceHttpRequestHandler          -> the static handler
  (5) the handler ran (post-handle yes) and answered 3xx + Location (not 304) -> Spring MVC's redirect (a "redirect:" view name)
  (6) the selected handler is HttpOptionsHandler                  -> Spring MVC's OPTIONS handler (the eighth class: Spring MVC's own
                                                                     handler for an OPTIONS no TiffinBox method maps - a finding of the run)
  (7) the handler ran (post-handle yes)                           -> the route (a TiffinBox handler method whose return value is the answer)
  anything else                                                  -> unattributed: a FAIL line"""
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
S1B = os.path.join(C9R, "_briefs", "UNIT-BRIEFS-S1-DESIGN.md")
DOCS = os.path.join(C9R, "_research", "docs-2026-11-23")
J9 = os.path.join(os.path.expanduser("~"), "Desktop", "PromptVidya-Automation", "java9_series.py")
HOOK = "Ask TiffinBox for a customer list in CSV. It answers four oh six — after it has already read the customers."
EXQ = "Your turn: the stylesheet answers two hundred to its own ETag. Ask it so it answers three oh four."
ROUTE, ADVICE, BOOTPD, STATIC, REDIRECT, BOOTERR, TOMCAT = ("the route", "TiffinBox's advice", "Boot's problem-details handler", "the static handler",
                                                         "Spring MVC's redirect", "Boot's /error", "Tomcat")
OPTS = "Spring MVC's OPTIONS handler"   # the eighth class, a finding of this unit's run (only the cannot ask OPTIONS /customers meets it)
CLASSES = [ROUTE, ADVICE, BOOTPD, STATIC, REDIRECT, BOOTERR, TOMCAT, OPTS]
BRIEF14 = ["200", "201", "302", "304", "400", "403", "404", "405", "406", "409", "412", "413", "415", "501"]
CANNOT = ["202", "204", "401", "410", "422", "429"]
NUMW = {12: "twelve", 13: "thirteen", 14: "fourteen", 15: "fifteen", 16: "sixteen"}

def lines(p):
    return open(p, encoding="utf-8", errors="replace").read().splitlines()
def aset(s):
    return ",".join(sorted(x.strip() for x in s.split(",") if x.strip() and x.strip() != "-"))

# ---- static ---------------------------------------------------------------------------------------------------------------------------
def static(ledger):
    s9 = open(os.path.join(HERE, "s903.py"), encoding="utf-8").read().split("\n")
    s4 = open(os.path.join(UNIT, "..", "c9-unit04", "harness", "s904.py"), encoding="utf-8").read().split("\n")
    s1 = open(os.path.join(UNIT, "..", "c9-unit01", "harness", "s901.py"), encoding="utf-8").read().split("\n")
    s2 = open(os.path.join(UNIT, "..", "c9-unit02", "harness", "s902.py"), encoding="utf-8").read().split("\n")
    md = lambda x: hashlib.md5("\n".join(x).encode()).hexdigest()
    end = "# --- XFAM_S9S1 end ---"
    if any(end not in s for s in (s9, s4, s1, s2)): fail("the XFAM_S9S1 end marker is missing in s903.py, s904.py, s901.py or s902.py"); done()
    a = lambda s: next(i for i, l in enumerate(s) if l.endswith('"""') and i > 0)
    sl = lambda s: s[a(s) + 1:s.index(end) + 1]
    need(sl(s9) == sl(s4), "s903.py's base + XFAM_S9S1 (after its docstring, through the block's end marker) = s904.py's, %d lines, md5 %s" % (len(sl(s4)), md(sl(s4))))
    need(sl(s9) == sl(s1), "= U01's s901.py's slice")
    need(sl(s9) == sl(s2), "= U02's s902.py's slice (copied from U02's harness)")
    t9 = "\n".join(s9); t4 = "\n".join(s4)
    rx = r"# --- XFAM_S9S1 begin ---\n.*?# --- XFAM_S9S1 end ---"
    b4 = re.search(rx, t4, re.S); b9 = re.search(rx, t9, re.S)
    need(b4 is not None and b9 is not None and b4.group(0) == b9.group(0), "the XFAM_S9S1 block, delimited, byte-equal to U04's")
    if b9:
        h = hashlib.md5(b9.group(0).encode()).hexdigest()
        print("  XFAM_S9S1_SLICE_MD5 = %s (computed the way ../c9-unit04/harness/chk04.py computes it)" % h)
        val("xfam_s9s1_md5", h[:8])
    need(not re.search(r"^XU0[124] = ", t9, re.M), "U04's own family (XU04), U01's (XU01) and U02's (XU02) are not carried")
    need(re.search(r"^XU03 = ", t9, re.M) is not None and re.search(r"^u04 = u03$", t9, re.M) is not None, "U03's own family (XU03) follows the carried slice; u04 = u03 (U01's binding)")
    if os.path.exists(J9):
        t = open(J9, encoding="utf-8").read()
        m = re.search(r'"03": "([^"]+)"', t)
        need(m is not None and m.group(1) == "Status Codes That Mean Something", "java9_series.TITLES['03'] = %r (C9-10b / C9-10f name it)" % (m.group(1) if m else None))
    done()

# ---- the spoken lines -----------------------------------------------------------------------------------------------------------------
STATUS = re.compile(r"(?<![\d.,:/-])\b(?:[1-5]\d\d)\b|\b(?:one|two|three|four|five)[\s-]hundred[\s-]and\b|\b(?:one|two|three|four|five)[\s-]hundred[\s-](?:one|two|three|four|five|six|seven|eight|nine|ten|eleven|twelve|thirteen|fourteen|fifteen)\b")
HING = re.compile(r"\b(?:bhai|yaar|dosto|kya|hai|nahi|nahin|matlab|karo|dekho|chalo|samjho|theek|accha|arre|haan|bilkul|zaroor|aur|toh|abhi|yeh|woh|kaise|kyun|bahut|thoda|sahi|galat)\b", re.I)
SPELL = re.compile(r"\b(?:API|URI|URL|RFC)s?\b")
def spoken(hook, exq, gloss):
    import importlib.util
    spec = importlib.util.spec_from_file_location("dur9", os.path.join(HERE, "dur9.py")); m = importlib.util.module_from_spec(spec); spec.loader.exec_module(m)
    dur = getattr(m, "DUR", None)
    need(dur is not None, "dur9.py exposes its pattern (DUR)")
    b = open(S1B, encoding="utf-8").read().split("\n") if os.path.exists(S1B) else []
    hl = [i + 1 for i, l in enumerate(b) if hook in l]; el = [i + 1 for i, l in enumerate(b) if exq in l]
    gl = [i + 1 for i, l in enumerate(b) if "which part of the server wrote these bytes" in l]
    need(hook == HOOK and bool(hl), "the hook is S1B's, byte for byte (the em dash U+2014 as the brief has it) - S1B line %s" % hl)
    need(exq == EXQ and bool(el), "the exercise's line is S1B's, byte for byte - S1B line %s" % el)
    need(gloss.startswith("An author: ") and gloss[len("An author: "):-1] == "which part of the server wrote these bytes" and bool(gl), "the gloss's quoted words are S1B's (line %s): %r" % (gl, gloss))
    hw = len(hook.split()); hwd = len([w for w in hook.split() if w != "—"]); ew = len(exq.split())
    need(hw == 21 and hwd == 20, "the hook: %d words by wc -w (the lone em dash counts as a word); %d without it" % (hw, hwd))
    need(ew == 19, "the exercise: %d words (wc -w) - RED #37's 19; the brief's '(18 words)' is stale" % ew)
    for name, s in (("the hook", hook), ("the exercise", exq), ("the gloss", gloss)):
        need(not re.search(r"\d", s), "%s holds no digit" % name)
        need(not STATUS.search(s), "%s: the status gate 0" % name)
        need(not SPELL.search(s), "%s: the spelling gate 0 (API, URI, URL, RFC bare)" % name)
        need(not HING.search(s), "%s: the Hinglish list 0" % name)
        if dur is not None: need(not dur.search(s), "%s: dur9 0 (%s)" % (name, dur.search(s).group(0) if dur.search(s) else "no hit"))
    print("  the hook: %d words (wc -w), %d without the em dash · the exercise: %d words · CSV and ETag written as the brief writes them (no spelling gate names them)" % (hw, hwd, ew))
    val("hook_words", hw); val("hook_words_nodash", hwd); val("exercise_words", ew)
    done()

# ---- the matrix captures --------------------------------------------------------------------------------------------------------------
ASK = re.compile(r"^-- ([\w-]+) \| ([A-Z]+) (/customers/<9000 x>|\S+) -> (\d{3}) (\S*) (\d+) \(curl exit (\d+)\)$")
SRV = re.compile(r"^([A-Z]+) (\S+)( \[dispatch (\w+), for (\S+)\])? -> (\d{3}) \| handler (\S+) \| post-handle (no|yes \(count (\d+)\))(?: \| ex (\S+))?(?: \| thrown (\S+))?(?: \| async started)? \| statements (\d+) \(writes (\d+), prepares (\d+)\)$")
ACC = re.compile(r"^([A-Z]+) (\S+?) (\d{3}) (\S+)$")
def parse(ls):
    """Blocks: '-- ' an ask; '     ' its sub-lines (status lines, header, access, server, resolved by, resolved, cache, sql, body). Other
    lines are kept as heads by these named rules: '== ' section heads, '  acc: ' the window's access-log lines, and '  ' + one-line facts."""
    asks = []; heads = []; acc = []; cur = None; win = None
    for l in ls:
        if l.startswith("-- "):
            a = ASK.match(l)
            if not a: fail("a request line the matrix reader cannot parse: %r" % l[:120]); cur = None; continue
            cur = {"lab": a.group(1), "m": a.group(2), "p": a.group(3), "st": a.group(4), "ct": a.group(5), "sz": int(a.group(6)), "rc": a.group(7),
                   "sl": [], "hd": [], "acc": [], "srv": [], "rby": [], "res": [], "cache": None, "sql": [], "body": None, "win": win == "open"}
            asks.append(cur); continue
        if l.startswith("     ") and cur is not None:
            t = l[5:]
            if t.startswith("status lines: "): cur["sl"] = [x.strip() for x in t[14:].split(" > ") if x.strip()]; continue
            if t.startswith("header: "): cur["hd"].append(t[8:]); continue
            if t.startswith("access: "):
                a = ACC.match(t[8:])
                if not a: fail("an access-log line the reader cannot parse: %r" % t[:100]); continue
                cur["acc"].append(a.groups()); continue
            if t.startswith("server: "):
                s = SRV.match(t[8:])
                if not s: fail("a witness line the reader cannot parse: %r" % t[:140]); continue
                g = s.groups()
                cur["srv"].append({"m": g[0], "p": g[1], "disp": g[3], "for": g[4], "st": g[5], "h": g[6], "ph": g[7] != "no", "ex": g[9], "thrown": g[10],
                                   "stm": int(g[11]), "w": int(g[12])}); continue
            if t.startswith("resolved by: "): cur["rby"].append(t[13:]); continue
            if t.startswith("resolved: "): cur["res"].append(t[10:]); continue
            m = re.match(r"^cache: before customers (\[.*\]) · after customers (\[.*\])$", t)
            if m: cur["cache"] = (m.group(1), m.group(2)); continue
            if t.startswith("sql: "): cur["sql"].append(t[5:]); continue
            if t.startswith("body: "): cur["body"] = t[6:]; continue
            fail("a sub-line the matrix reader cannot parse: %r" % t[:100]); continue
        if l.startswith("     "): fail("an indented line outside a request block: %r" % l[:100]); continue
        cur = None
        if l.startswith("  acc: "):
            a = ACC.match(l[7:])
            if not a: fail("a window access-log line the reader cannot parse: %r" % l[:100]); continue
            acc.append(a.groups()); continue
        heads.append(l)
        if l.startswith("  window opens"): win = "open"
        if l.startswith("  window closes"): win = "closed"
    return asks, heads, acc

def hdr(r, name):
    for h in r["hd"]:
        if h.lower().startswith(name.lower() + ":"): return h.split(":", 1)[1].split(" · set {")[0].strip()
    return None
def reqs(r): return [s for s in r["srv"] if s["disp"] is None]
def errs(r): return [s for s in r["srv"] if s["disp"] == "ERROR"]
def author(r):
    """THE AUTHOR RULE (the docstring's six steps, in order). Returns (class, evidence) or (None, why)."""
    e = errs(r); q = reqs(r)
    if e: return BOOTERR, "an ERROR-dispatch witness line (%s %s, handler %s, post-handle %s)" % (e[0]["m"], e[0]["p"], e[0]["h"], "yes" if e[0]["ph"] else "no")
    if not q: return TOMCAT, "no witness line; the access log's line %s" % (" ".join(r["acc"][0][:3]) if r["acc"] else "none")
    if r["rby"]:
        c = r["rby"][0].split("#")[0]
        if c == "TiffinBoxErrors": return ADVICE, "the resolver's line: %s (%s)" % (r["rby"][0], ",".join(r["res"]))
        if c == "ProblemDetailsExceptionHandler": return BOOTPD, "the resolver's line: %s (%s)" % (r["rby"][0], ",".join(r["res"]))
        return None, "a resolver line naming %s" % c
    s = q[0]
    if s["h"] == "ResourceHttpRequestHandler": return STATIC, "handler ResourceHttpRequestHandler, post-handle %s, no exception resolved" % ("yes" if s["ph"] else "no")
    if s["ph"] and r["st"].startswith("3") and r["st"] != "304" and hdr(r, "Location"): return REDIRECT, "handler %s, post-handle yes, Location %s" % (s["h"], hdr(r, "Location"))
    if s["h"].startswith("HttpOptionsHandler"): return OPTS, "handler %s (Spring MVC's own), post-handle %s" % (s["h"], "yes" if s["ph"] else "no")
    if s["ph"]: return ROUTE, "handler %s, post-handle yes" % s["h"]
    return None, "handler %s, post-handle no, no resolver line" % s["h"]
def problem(r):
    try: return json.loads(r["body"]) if r["body"] and r["body"].startswith("{") else None
    except Exception: return None
def stm(r):
    q = reqs(r)
    return q[0]["stm"] if q else None
def head_of(heads, rx):
    for h in heads:
        m = re.search(rx, h)
        if m: return m
    return None
PROBE_READ = re.compile(r"^/probe/u03/(cache|keys|row/\w+)$")   # the named rule: the harness's own reads, set apart from the window's requests

def matrix(ls, db):
    asks, heads, acc = parse(ls)
    first = ls[0] if ls else ""
    want = {"pg": "PostgreSQL 18.6", "h2": "H2 2.5"}[db]
    need(first.startswith("== %s:" % db) and ("(%s)" % want) in first, "which database answered: the capture's head says %s and Flyway's line says %s" % (db, want))
    c0 = head_of(heads, r"^  cache before any request: customers (\[.*\])")
    need(c0 is not None and c0.group(1) == "[]", "the customers cache right after the Started line: empty (%s)" % (c0.group(1) if c0 else "no line"))
    h = [a for a in asks if a["lab"] == "health"]
    need(bool(h) and h[0]["st"] == "200" and stm(h[0]) == 1 and h[0]["cache"] == ("[]", "[SimpleKey []]"), "one GET /actuator/health (counted, before the window): 200, 1 statement, cache [] -> [SimpleKey []] (warm)")
    win = [a for a in asks if a["win"]]
    need(len(win) == len(asks) - 1, "every request but the health check is inside the window (%d)" % len(win))
    wo = head_of(heads, r"^  window opens after access-log line (\d+)$"); wc = head_of(heads, r"^  window closes at access-log line (\d+): (\d+) lines$")
    nprobe = len([x for x in acc if PROBE_READ.match(x[1].rstrip("-"))])
    need(wo is not None and wc is not None and int(wc.group(1)) - int(wo.group(1)) == int(wc.group(2)) == len(acc), "the window: %s access-log lines, each printed" % (wc.group(2) if wc else "?"))
    need(len(acc) - nprobe == len(win), "the window's lines = the requests sent (%d) + the harness's reads of /probe/u03/{cache,keys,row} (%d, set apart by the named rule)" % (len(win), nprobe))
    # each request: one access line, the same method/status; the REQUEST witness (when present) names it; no key header, no U04 route
    for r in win:
        a = r["acc"]
        if len(a) != 1 or a[0][0] != r["m"] or a[0][2] != r["st"]: fail("%s: its one access-log line (%s)" % (r["lab"], a)); continue
        if r["lab"] != "long" and a[0][1].rstrip("-").split("?")[0] != r["p"].split("?")[0]: fail("%s: the access line's path %s" % (r["lab"], a[0][1]))
        q = reqs(r)
        if q and (q[0]["m"] != r["m"] or q[0]["st"] != r["st"]): fail("%s: the request witness's line names %s -> %s" % (r["lab"], q[0]["m"], q[0]["st"]))
        if r["p"].startswith("/api/") or r["p"].startswith("/probe/pauses"): fail("%s: a request to one of U04's routes (S9.3)" % r["lab"])
    ok("every request: one access-log line (method and status = curl's), its REQUEST witness (when present) names the same request; no request to /api/** or /probe/pauses/**")
    attributed = 0
    for r in win:
        c, ev = author(r)
        if c is None: fail("%s: unattributed by the author rule (%s)" % (r["lab"], ev))
        else: attributed += 1
    need(attributed == len(win), "the author rule attributes every request of the window (%d/%d)" % (attributed, len(win)))
    kr = head_of(heads, r"^  key table rows after the matrix: (\d+) \((.*)\)$")
    need(kr is not None and kr.group(1) == "0", "S9.21: the key table's rows after the matrix: %s (%s)" % (kr.group(1) if kr else "?", kr.group(2) if kr else "no line"))
    rk = head_of(heads, r"^  the name's rows after the 409: Kavya (\d+) \((.*)\)$")
    need(rk is not None and rk.group(1) == "1", "the 409 stored nothing: Kavya's rows %s (%s)" % (rk.group(1) if rk else "?", rk.group(2) if rk else "no line"))
    codes = sorted(set(r["st"] for r in win if r["lab"] != "boom"))
    need(codes == BRIEF14, "the final codes the asked routes answered: %d (%s) - the brief's fourteen" % (len(codes), " ".join(codes)))
    val("requests", len(win)); val("codes", len(codes)); val("probe_reads", nprobe); val("window", len(acc))
    done()

def load(p):
    asks, heads, acc = parse(lines(p))
    return {a["lab"]: a for a in asks}, asks, heads, acc

# ---- the views ------------------------------------------------------------------------------------------------------------------------
def rfc(fn, heading, phrase):
    """A section of a filed RFC: the body's heading line (the last line that starts with it, after the table of contents) and the first
    line inside the section holding the phrase - both line numbers printed, the phrase (one clause at most) quoted."""
    p = os.path.join(DOCS, fn)
    if not os.path.exists(p): return None
    L = open(p, encoding="utf-8", errors="replace").read().split("\n")
    hs = [i for i, l in enumerate(L) if l.startswith(heading)]
    if not hs: return None
    h = hs[-1]
    for j in range(h + 1, min(h + 120, len(L))):
        if phrase in " ".join(L[j].split()) or phrase in " ".join((L[j] + " " + (L[j + 1] if j + 1 < len(L) else "")).split()):
            return "%s:%d \"%s\" · :%d \"%s\"" % (fn, h + 1, L[h].strip(), j + 1, phrase)
    return None

def V(lines_, checks, vals):
    return lines_, checks, vals

def row(r, db):
    c, ev = author(r)
    pd = problem(r)
    inst = "-" if not pd else ("instance=path" if pd.get("instance") == r["p"].split("?")[0] else ("instance=%s" % pd.get("instance") if "instance" in pd else "no instance"))
    return "%-13s %-7s %-22s %s %-26s %6d · %-30s · stm %s · %s · %s" % (r["lab"], r["m"], (r["p"] if len(r["p"]) < 23 else r["p"][:19] + "…"), r["st"], r["ct"] or "-", r["sz"], c, stm(r), inst, ev)

def v_census(pg, h2):
    out, ck, vs = [], [], []
    for db, (m, _, _, _) in (("pg", pg), ("h2", h2)):
        out.append("== %s: the 2xx and 3xx rows (PostgreSQL first)" % db)
        for lab in ("s200", "s201", "s302", "s200form", "s200css", "s304"):
            r = m.get(lab)
            if not r: ck.append((False, "%s: no %s row" % (db, lab))); continue
            out.append("  " + row(r, db))
            if r["cache"]: out.append("    cache: before %s · after %s" % r["cache"])
            if hdr(r, "Location"): out.append("    Location: %s" % hdr(r, "Location"))
        g = lambda lab: m.get(lab, {"st": None})
        ck.append((g("s200")["st"] == "200" and author(m["s200"])[0] == ROUTE and stm(m["s200"]) == 0, "%s: s200 GET /customers -> 200, the route, 0 statements (warm)" % db))
        ck.append((g("s201")["st"] == "201" and author(m["s201"])[0] == ROUTE and (hdr(m["s201"], "Location") or "").endswith("/customers/Kavya") and reqs(m["s201"])[0]["w"] == 1 and m["s201"]["cache"][1] == "[]",
                   "%s: s201 -> 201 + Location …/customers/Kavya, the route, 1 write; the cache evicted (after: [])" % db))
        ck.append((g("s302")["st"] == "302" and author(m["s302"])[0] == REDIRECT and hdr(m["s302"], "Content-Length") == "0" and (hdr(m["s302"], "Location") or "").endswith("/dashboard"),
                   "%s: s302 the form POST -> 302, Spring MVC's redirect (handler DashboardPage#add), Content-Length 0, Location …/dashboard" % db))
        ck.append((g("s200form")["st"] == "200" and author(m["s200form"])[0] == ROUTE and reqs(m["s200form"])[0]["h"] == "DashboardPage#add" and reqs(m["s200list"] if "s200list" in m else m["s200"])[0]["h"] == "TiffinBoxServer#customers",
                   "%s: s200form -> 200, the route - handler DashboardPage#add, a different class from the list's TiffinBoxServer#customers" % db))
        ck.append((g("s304")["st"] == "304" and author(m["s304"])[0] == STATIC and stm(m["s304"]) == 0 and m["s304"]["sz"] == 0, "%s: s304 (If-Modified-Since = its Last-Modified) -> 304, the static handler, 0 statements, 0 body bytes" % db))
    return V(out, ck, vs)

def counts(win):
    per_req = collections.Counter(); per_code = collections.defaultdict(set)
    for r in win:
        if r["lab"] == "boom": continue
        c = author(r)[0]; per_req[c] += 1; per_code[c].add(r["st"])
    return per_req, per_code

def v_authors(pg, h2):
    out, ck, vs = [], [], []
    out.append("== the author rule (harness/chk03.py author(), its classes CLASSES): (1) an ERROR-dispatch witness line -> Boot's /error · (2) no REQUEST witness line -> Tomcat · (3) a resolver line -> TiffinBox's advice / Boot's problem-details handler · (4) ResourceHttpRequestHandler -> the static handler · (5) post-handle yes + 3xx + Location -> Spring MVC's redirect · (6) HttpOptionsHandler -> Spring MVC's OPTIONS handler · (7) post-handle yes -> the route")
    res = {}
    for db, (m, asks, heads, acc) in (("pg", pg), ("h2", h2)):
        win = [a for a in asks if a["win"]]
        out.append("== %s: the matrix - %d requests, one row each (label · method · path · code · content type · bytes · author · statements · instance · evidence)" % (db, len(win)))
        for r in win: out.append("  " + row(r, db))
        pr, pc = counts(win)
        out.append("  %s per request: %s" % (db, " · ".join("%s %d" % (c, pr[c]) for c in CLASSES)))
        out.append("  %s per code:    %s" % (db, " · ".join("%s %d (%s)" % (c, len(pc[c]), " ".join(sorted(pc[c]))) for c in CLASSES)))
        refused = [r for r in win if not reqs(r) and r["lab"] != "boom"]
        wrote = [r for r in win if author(r)[0] == TOMCAT]
        out.append("  %s Tomcat refused before any TiffinBox route: %d (%s) · Tomcat wrote the body: %d (%s)" % (db, len(refused), " ".join("%s %s" % (r["m"], r["st"]) for r in refused), len(wrote), " ".join("%s %s" % (r["m"], r["st"]) for r in wrote)))
        codes = sorted(set(r["st"] for r in win if r["lab"] != "boom"))
        interim = sorted(set(s.split()[1] for r in win for s in r["sl"][:-1]))
        out.append("  %s distinct final codes: %d (%s) · interim: %s · the harness's: %s" % (db, len(codes), " ".join(codes), " ".join(interim) or "none", " ".join(sorted(set(r["st"] for r in win if r["lab"] == "boom")))))
        res[db] = (pr, pc, len(refused), len(wrote), codes, interim, win)
        a404 = m.get("s404a"); b404 = m.get("s404b"); a405 = m.get("s405"); t405 = m.get("trace"); r409 = m.get("s409")
        ck.append((a404 and b404 and author(a404)[0] == ADVICE and author(b404)[0] == BOOTPD and "name" in (problem(a404) or {}) and "name" not in (problem(b404) or {}),
                   "%s: the SAME code, two authors - 404 Nobody by TiffinBox's advice (a name member) and 404 /nowhere by Boot's problem-details handler" % db))
        ck.append((a405 and t405 and author(a405)[0] == BOOTPD and author(t405)[0] == BOOTERR, "%s: 405 GET /shutdown by Boot's problem-details handler, 405 TRACE by Boot's /error" % db))
        ck.append((r409 and author(r409)[0] == ROUTE and a404 and author(a404)[0] == ADVICE, "%s: R.312's negation - the route's 409 beside the advice's 404: both TiffinBox's, two authors" % db))
        lg = m.get("long"); cn = m.get("connect")
        ck.append((lg and cn and author(lg)[0] == TOMCAT and author(cn)[0] == TOMCAT and "HTTP Status 400" in (lg["body"] or "") and "HTTP Status 501" in (cn["body"] or ""),
                   "%s: the long line's 400 and CONNECT's 501 - Tomcat's own HTML pages (\"HTTP Status 400\", \"HTTP Status 501\"), no witness line" % db))
        ck.append((len(refused) == 3 and len(wrote) == 2, "%s: Tomcat refused 3 before any route (TRACE, CONNECT, the long line); Tomcat wrote 2 bodies - the brief's 'Tomcat 3' is the first count" % db))
        ck.append((interim == ["100"] and codes == BRIEF14, "%s: the interim code: 100 only; the distinct final codes: %d" % (db, len(codes))))
    if "pg" in res and "h2" in res:
        ck.append((res["pg"][0] == res["h2"][0] and res["pg"][1] == res["h2"][1], "the counts per class, per request and per code, equal on PostgreSQL and H2"))
        pr, pc = res["h2"][0], res["h2"][1]
        out.append("  the brief's (S1B :287, 'the brief's; re-measure'): route 5 · advice 1 · Boot 7 · static 2 · Tomcat 3 - measured per code: route %d · advice %d · Boot's problem-details handler %d · static %d · Tomcat %d (+ Spring MVC's redirect %d, Boot's /error %d); per request: %s"
                   % (len(pc[ROUTE]), len(pc[ADVICE]), len(pc[BOOTPD]), len(pc[STATIC]), len(pc[TOMCAT]), len(pc[REDIRECT]), len(pc[BOOTERR]), " · ".join("%d" % pr[c] for c in CLASSES)))
        for c, k in zip(CLASSES, ("route", "advice", "bootpd", "static", "redirect", "booterr", "tomcat", "options")):
            vs.append(("req_" + k, pr[c])); vs.append(("code_" + k, len(pc[c])))
        vs += [("refused", res["h2"][2]), ("wrote", res["h2"][3]), ("codes", len(res["h2"][4])), ("requests", len(res["h2"][6]))]
    return V(out, ck, vs)

def v_six(pg, h2):
    out, ck, vs = [], [], []
    for db, (m, _, _, _) in (("pg", pg), ("h2", h2)):
        out.append("== %s: six - a customer list in CSV, after the read" % db)
        for lab, state in (("six-cold", "COLD (the 201's eviction just ran)"), ("six-control", "the control, straight after"), ("six-warm", "WARM"), ("six-evict", "an eviction"), ("six-base", "the baseline: cold, JSON")):
            r = m.get(lab)
            if not r: ck.append((False, "%s: no %s row" % (db, lab))); continue
            q = reqs(r)
            out.append("  %-11s %s: %s %s -> %s %s · cache %s -> %s · handler %s · post-handle %s · statements %s (writes %s)%s" % (lab, state, r["m"], r["p"], r["st"], r["ct"], r["cache"][0] if r["cache"] else "?", r["cache"][1] if r["cache"] else "?",
                       q[0]["h"] if q else "-", ("yes" if q and q[0]["ph"] else "no"), q[0]["stm"] if q else "-", q[0]["w"] if q else "-", (" · resolved %s by %s" % (",".join(r["res"]), ",".join(r["rby"]))) if r["rby"] else ""))
            for s in r["sql"]: out.append("      sql: %s" % s)
            if r["st"] == "406": out.append("      body: %s" % r["body"])
        c, w, b, ctl = m.get("six-cold"), m.get("six-warm"), m.get("six-base"), m.get("six-control")
        if c and w and b and ctl:
            ck.append((c["st"] == "406" and c["ct"] == "application/problem+json" and stm(c) == 1 and c["cache"] == ("[]", "[SimpleKey []]") and not reqs(c)[0]["ph"] and reqs(c)[0]["h"] == "TiffinBoxServer#customers",
                       "%s: COLD - 406 problem+json, 1 statement inside the request, keys [] -> [SimpleKey []], handler TiffinBoxServer#customers, post-handle no" % db))
            ck.append((c["res"] == ["HttpMediaTypeNotAcceptableException"] and c["rby"] == ["ProblemDetailsExceptionHandler#handleException"], "%s: the resolver's line: HttpMediaTypeNotAcceptableException by ProblemDetailsExceptionHandler#handleException" % db))
            ck.append((ctl["st"] == "200" and stm(ctl) == 0, "%s: the control - the same GET as JSON straight after: 200, 0 statements (the 406's read warmed it)" % db))
            ck.append((w["st"] == "406" and stm(w) == 0 and w["cache"][0] == w["cache"][1] == "[SimpleKey []]", "%s: WARM - 406, 0 statements, keys unchanged" % db))
            ck.append((b["st"] == "200" and stm(b) == 1 and b["cache"] == ("[]", "[SimpleKey []]") and c["sql"] and c["sql"] == b["sql"], "%s: the baseline - a cold JSON GET: 200, 1 statement, the same SQL text as the cold 406's" % db))
            ck.append(("Acceptable representations" in (c["body"] or ""), "%s: the 406's body says 'Acceptable representations: …'" % db))
    rf = rfc("rfc9110.txt", "15.5.7.  406 Not Acceptable", "does not have a current representation")
    out.append("  RFC 9110 §15.5.7: %s" % rf); ck.append((rf is not None, "RFC 9110 §15.5.7 read off the filed copy"))
    vs += [("cold_stm", stm(h2[0]["six-cold"]) if "six-cold" in h2[0] else "?"), ("warm_stm", stm(h2[0]["six-warm"]) if "six-warm" in h2[0] else "?")]
    return V(out, ck, vs)

def v_conditional(pg, h2):
    out, ck, vs = [], [], []
    want = [("s304", "If-Modified-Since = its Last-Modified", "304"), ("c-inm", "If-None-Match = its own ETag", "200"), ("c-inmdate", "If-None-Match = its ETag + If-Modified-Since = its date", "200"),
            ("c-star", "If-None-Match: *", "200"), ("c-ifmatch", "If-Match: \"x\"", "200"), ("c-iusbefore", "If-Unmodified-Since a day before its Last-Modified", "412"), ("c-iuseq", "If-Unmodified-Since = its Last-Modified", "200")]
    for db, (m, _, _, _) in (("pg", pg), ("h2", h2)):
        out.append("== %s: conditional - the static handler on the stylesheet (%s)" % (db, m["s200css"]["p"] if "s200css" in m else "?"))
        for lab, what, st in want:
            r = m.get(lab)
            if not r: ck.append((False, "%s: no %s row" % (db, lab))); continue
            q = reqs(r)
            out.append("  %-11s %-56s -> %s · %d B · handler %s · post-handle %s · statements %s" % (lab, what, r["st"], r["sz"], q[0]["h"] if q else "-", "yes" if q and q[0]["ph"] else "no", q[0]["stm"] if q else "-"))
            ck.append((r["st"] == st and author(r)[0] == STATIC and stm(r) == 0, "%s: %s -> %s, the static handler, 0 statements" % (db, what, st)))
    rows_ = [("13.1.1.  If-Match", "failed by responding with a 412 (Precondition Failed) status code."), ("13.1.2.  If-None-Match", "304 (Not Modified)"), ("13.1.3.  If-Modified-Since", "304 (Not Modified)"),
             ("13.1.4.  If-Unmodified-Since", "412 (Precondition Failed)"), ("13.2.2.  Precedence of Preconditions", "evaluate the If-Match precondition")]
    for hd, ph in rows_:
        rf = rfc("rfc9110.txt", hd, ph)
        out.append("  RFC 9110 §%s: %s" % (hd.split(".  ")[0], rf)); ck.append((rf is not None, "RFC 9110 §%s read off the filed copy" % hd.split(".  ")[0]))
    out.append("  the capture: If-Match \"x\" -> 200 here (what Spring's static handler did); §13.1.1's clause wants a 412 for a false If-Match. The 304 and the 412 come from the same handler on the same file, by two different headers.")
    return V(out, ck, vs)

def v_limits(pg, h2):
    out, ck, vs = [], [], []
    lf = os.environ.get("LIMF", "?"); lh = os.environ.get("LIMH", "?")
    b5 = [l for l in lines(BR8)] if os.path.exists(BR8) else []
    bl = None
    for i, l in enumerate(b5[167:354]):
        if re.match(r"^-- GET http://127\.0\.0\.1:\d+/customers/x{100,} ", l) or (l.startswith("-- GET") and "/customers/xxxx" in l):
            for k in b5[167 + i + 1:167 + i + 8]:
                m = re.match(r"^\s+Content-Length: (\d+)$", k)
                if m: bl = int(m.group(1)); break
            break
    for db, (m, _, _, _) in (("pg", pg), ("h2", h2)):
        out.append("== %s: limits" % db)
        for lab in ("l413", "l413noexpect", "lsmall", "long", "ravi"):
            r = m.get(lab)
            if not r: ck.append((False, "%s: no %s row" % (db, lab))); continue
            q = reqs(r)
            out.append("  %-12s %s %s -> %s %s %d B · status lines %s · witness %s · access %s · Connection %s%s" % (lab, r["m"], r["p"], r["st"], r["ct"] or "-", r["sz"], " > ".join(r["sl"]), ("handler %s, post-handle %s, statements %d" % (q[0]["h"], "yes" if q[0]["ph"] else "no", q[0]["stm"])) if q else "none",
                       " ".join(r["acc"][0]) if r["acc"] else "none", hdr(r, "Connection") or "-", (" · resolved %s by %s" % (",".join(r["res"]), ",".join(r["rby"]))) if r["rby"] else ""))
        a, n, s, lg, rv = (m.get(x) for x in ("l413", "l413noexpect", "lsmall", "long", "ravi"))
        if a and n and s and lg and rv:
            ck.append((a["sl"] == ["HTTP/1.1 100", "HTTP/1.1 413"] and a["ct"] == "application/problem+json" and "Maximum upload size exceeded" in (a["body"] or "") and "Content Too Large" in (a["body"] or ""),
                       "%s: the big import - curl's header file holds HTTP/1.1 100 THEN HTTP/1.1 413; problem+json 'Content Too Large', 'Maximum upload size exceeded'" % db))
            q = reqs(a)
            ck.append((q and q[0]["h"] == "none" and not q[0]["ph"] and q[0]["stm"] == 0 and a["res"] == ["MaxUploadSizeExceededException"] and a["rby"] == ["ProblemDetailsExceptionHandler#handleException"],
                       "%s: the 413's witness: handler none, post-handle no, 0 statements; resolved MaxUploadSizeExceededException by Boot's handler before any handler" % db))
            ck.append((n["sl"] == ["HTTP/1.1 413"], "%s: the control with -H 'Expect:' - the same 413 with NO 100 block (the 100 answered curl's Expect: 100-continue)" % db))
            ck.append((s["st"] == "200" and author(s)[0] == ROUTE, "%s: the control - a small valid CSV: 200, the route ran" % db))
            ck.append((lg["st"] == "400" and not lg["srv"] and lg["acc"] and lg["acc"][0][1] == "--" and "HTTP Status 400" in (lg["body"] or "") and lg["ct"].startswith("text/html"),
                       "%s: the long line - 400, Tomcat's own HTML page, NO witness line, the access line 'GET -- 400' (%%U and %%q both '-': no URI parsed)" % db))
            ck.append((bl is None or lg["sz"] == bl, "%s: the long line's page %d B = the boundary's pre-key census's %s B (B8 census-mid)" % (db, lg["sz"], bl)))
            ck.append((rv["st"] == "200" and bool(reqs(rv)), "%s: R.312's negation - GET /customers/Ravi reaches Spring (a REQUEST witness line); the long one never does" % db))
    for hd, ph in (("15.2.1.  100 Continue", "initial part of a"), ("15.5.14.  413 Content Too Large", "request content is larger"), ("15.5.15.  414 URI Too Long", "target URI is longer than")):
        rf = rfc("rfc9110.txt", hd, ph)
        out.append("  RFC 9110 §%s: %s" % (hd.split(".  ")[0], rf)); ck.append((rf is not None, "RFC 9110 §%s read off the filed copy" % hd.split(".  ")[0]))
    out.append("  the jars' own metadata: spring.servlet.multipart.max-file-size %s · server.max-http-request-header-size %s" % (lf, lh))
    out.append("  the capture: Tomcat answered 400 here; §15.5.15 names 414 for a target URI too long - no advisory filed, nothing else read")
    bb = head_of(h2[2], r"^  the big file: (\d+) bytes ")
    ck.append((bb is not None, "the big file's size, read off the matrix's own line (wc -c): %s bytes" % (bb.group(1) if bb else "?")))
    vs += [("big_bytes", bb.group(1) if bb else "?"), ("long_page", h2[0]["long"]["sz"] if "long" in h2[0] else "?")]
    return V(out, ck, vs)

def titles():
    if not os.path.exists(J9): return {}
    t = open(J9, encoding="utf-8").read()
    b = re.search(r"^TITLES = \{(.*?)^\}", t, re.S | re.M)
    return dict(re.findall(r'"(\d\d)": "([^"]+)"', b.group(1))) if b else {}

def v_cannot(pg, h2):
    out, ck, vs = [], [], []
    T = titles()
    pick = lambda w: next((k for k, v in T.items() if v.startswith(w)), None)
    named = [("202", pick("Bulk Operations and 202")), ("422", pick("Idempotency, Safety and Retries")), ("429", pick("Rate Limiting")), ("410", pick("Retiring an Endpoint"))]
    for db, (m, asks, _, _) in (("pg", pg), ("h2", h2)):
        out.append("== %s: cannot - asked first, then named" % db)
        ks = [a for a in asks if a["lab"].startswith("k")]
        for r in ks: out.append("  %-11s %s %s%s -> %s · %s" % (r["lab"], r["m"], r["p"], " (Authorization: Bearer x)" if r["lab"] == "k401bearer" else (" (a wrong token)" if r["lab"] == "k401token" else ""), r["st"], author(r)[0]))
        s4 = m.get("s400a")
        out.append("  422's ask is the matrix's s400a (a body that parses and breaks a rule): -> %s" % (s4["st"] if s4 else "?"))
        got = set(r["st"] for r in ks) | ({s4["st"]} if s4 else set())
        ck.append((not (got & set(CANNOT)), "%s: none of the asked requests answered %s (they answered %s)" % (db, " ".join(CANNOT), " ".join(sorted(got)))))
        burst = [r for r in ks if r["lab"].startswith("k429-")]
        ck.append((len(burst) >= 1 and set(r["st"] for r in burst) == {"200"}, "%s: the burst: %d GET /customers, distinct codes {200}" % (db, len(burst))))
        ck.append((m.get("k401token", {}).get("st") == "403" and author(m["k401token"])[0] == ROUTE, "%s: a wrong shutdown token -> 403, the route's own answer - the route's, not a login's" % db))
        vs.append(("burst_" + db, len(burst)))
    for c, k in named:
        out.append("  %s -> %s (java9_series.TITLES)" % (c, T.get(k, "?")))
        ck.append((k is not None, "%s is named by its lesson's title, read off java9_series.TITLES" % c))
    out.append("  401 -> Spring Security — complete (by course name) · 204: no Course 9 title builds it - unsaid")
    return V(out, ck, vs)

def v_five(pg, h2):
    out, ck, vs = [], [], []
    for db, (m, asks, heads, acc) in (("pg", pg), ("h2", h2)):
        out.append("== %s: five" % db)
        b = m.get("boom"); t = m.get("trace")
        if not b or not t: ck.append((False, "%s: no boom or trace row" % db)); continue
        pb, pt = problem(b) or {}, problem(t) or {}
        out.append("  boom  GET /probe/u03/boom -> %s %s · witnesses: %s · body keys %s" % (b["st"], b["ct"], " | ".join("%s %s%s handler %s" % (s["m"], s["p"], " [ERROR]" if s["disp"] else "", s["h"]) for s in b["srv"]), sorted(pb)))
        out.append("  trace TRACE /customers -> %s %s · body keys %s (the same four-key shape, the same class)" % (t["st"], t["ct"], sorted(pt)))
        ck.append((b["st"] == "500" and sorted(pb) == ["error", "path", "status", "timestamp"] and any(s["disp"] == "ERROR" and s["h"] == "BasicErrorController#error" for s in b["srv"]) and any(s["disp"] is None and s["h"] == "U03Probe#boom" for s in b["srv"]),
                   "%s: boom -> 500, Boot's /error four keys (timestamp masked, status, error, path), a REQUEST line handler U03Probe#boom and an ERROR-dispatch line BasicErrorController#error - a harness route, never TiffinBox's" % db))
        ck.append((sorted(pt) == ["error", "path", "status", "timestamp"] and author(t)[0] == BOOTERR, "%s: TRACE's 405 - the same four keys, authored by the same class" % db))
        tb500 = [r for r in asks if r["win"] and r["st"] == "500" and r["lab"] != "boom"]
        ck.append((not tb500, "%s: no TiffinBox request of the matrix answered 500" % db))
        dc = sorted(set(x[2] for x in acc if not PROBE_READ.match(x[1].rstrip("-"))))
        out.append("  %s the access log's distinct codes in the window (the harness's reads set apart by the named rule): %d (%s)" % (db, len(dc), " ".join(dc)))
        ck.append((dc == sorted(BRIEF14 + ["500"]), "%s: the access log's distinct codes = the fourteen final codes + the harness's 500, nothing else" % db))
        a5 = head_of(heads, r"^  access log in all: (\d+) lines · status 500: (\d+)(.*)$")
        out.append("  %s access log in all: %s lines · status 500: %s%s" % (db, a5.group(1) if a5 else "?", a5.group(2) if a5 else "?", a5.group(3) if a5 else ""))
        ck.append((a5 is not None and a5.group(2) == "1" and "/probe/u03/boom" in a5.group(3), "%s: the access log's only 500 is GET /probe/u03/boom (this unit sends no feed request)" % db))
        vs.append(("acc_codes_" + db, len(dc)))
    out.append("  U01's feed 500 (c9-unit01/README.md): GET /customers/feed, logged by Tomcat when the next add's event cannot reach the closed answer - cited, not re-sent here (feed500: dropped first, not captured, not said)")
    return V(out, ck, vs)

def v_inert(pg, h2):
    out, ck, vs = [], [], []
    if not os.path.exists(BR8): return V(["  the boundary's census is not on this machine"], [(False, "B8 census-mid present")], vs)
    b = lines(BR8)
    blocks = []
    for i in range(167, min(354, len(b))):
        m = re.match(r"^-- ([A-Z]+) http://127\.0\.0\.1:\d+(\S+) -> (\d{3}) (\S*) ?(\d+) \(curl exit \d+\)$", b[i])
        if m: blocks.append((m.group(1), re.sub(r"x{100,}", "<9000 x>", m.group(2)), m.group(3), m.group(4), int(m.group(5))))
    out.append("== inert - the matrix (PostgreSQL first) against the boundary's pre-key census (BR/B8/census-mid/census.txt:168-354, 4.1.3 + Tomcat 11.0.29 BEFORE the key): %d request blocks" % len(blocks))
    MAP = ["s200", "s201", "s409", "s400a", "s400b", "s400c", "s403", "s404a", "s404b", "s405", "six-cold", "s415a", "s302", "s200form", "s304", "c-inm", "c-ifmatch", "c-iusbefore", "l413", "s415b",
           "k204del", None, "long", None, None]
    moved = 0
    for db, (m, _, _, _) in (("pg", pg), ("h2", h2)):
        for k, blk in enumerate(blocks):
            lab = MAP[k] if k < len(MAP) else None
            if lab is None:
                out.append("  %s %-11s %s %s -> %s · not a request of this unit (the boundary's own)" % (db, "-", blk[0], blk[1][:40], blk[2])); continue
            r = m.get(lab)
            mine = (r["m"], r["p"] if lab != "long" else "/customers/<9000 x>", r["st"], r["ct"], r["sz"]) if r else None
            blk2 = (blk[0], blk[1] if lab != "s304" else blk[1], blk[2], blk[3], blk[4])
            if lab in ("s304", "c-inm", "c-ifmatch", "c-iusbefore"): blk2 = (blk[0], "<css>", blk[2], blk[3], blk[4]); mine = (mine[0], "<css>") + mine[2:] if mine else None
            eq = mine == blk2
            if not eq: moved += 1
            out.append("  %s %-11s %s · %s" % (db, lab, "equal" if eq else "MOVED: mine %s, the boundary's %s" % (mine, blk2), "%s %s -> %s %s %d" % blk2))
    ck.append((moved == 0, "inert: every matched row equals the boundary's pre-key census (method, path, status, content type, bytes) on both databases - %d moved" % moved))
    for db, (m, _, heads, _) in (("pg", pg), ("h2", h2)):
        kr = head_of(heads, r"^  key table rows after the matrix: (\d+) \((.*)\)$")
        out.append("  %s key table rows after the whole matrix: %s (%s)" % (db, kr.group(1) if kr else "?", kr.group(2) if kr else "no line"))
        ck.append((kr is not None and kr.group(1) == "0", "%s: the key table's rows = 0 by the second client" % db))
        posts = [r for r in m.values() if r["m"] == "POST" and r["p"] == "/customers" and r["win"]]
        out.append("  %s the POST /customers rows the filter could have moved (registered on /customers; no key header: passed on): %s" % (db, " · ".join("%s %s" % (r["lab"], r["st"]) for r in posts)))
    vs.append(("moved", moved)); vs.append(("blocks", len(blocks)))
    return V(out, ck, vs)

def v_instance(pg, h2):
    out, ck, vs = [], [], []
    src = os.path.join(UNIT, "..", "c9-tiffinbox")
    si = []; fs = []
    for root, _, files in os.walk(src):
        if "/target" in root or "/src/test" in root: continue
        for f in files:
            if f.endswith(".java"):
                for i, l in enumerate(open(os.path.join(root, f), encoding="utf-8", errors="replace"), 1):
                    if "setInstance" in l: si.append("%s:%d" % (f, i))
                    if "ProblemDetail.forStatus" in l: fs.append("%s:%d" % (f, i))
    out.append("== instance - who fills it, which bodies carry it")
    out.append("  TiffinBox's sources (c9-tiffinbox, main): setInstance: %s · ProblemDetail.forStatus…: %s" % (" ".join(si) or "no match", " ".join(fs)))
    for db, (m, asks, _, _) in (("pg", pg), ("h2", h2)):
        pbs = [r for r in asks if r["win"] and r["ct"] == "application/problem+json"]
        errb = [r for r in asks if r["win"] and author(r)[0] == BOOTERR]
        eq = [r for r in pbs if (problem(r) or {}).get("instance") == r["p"].split("?")[0]]
        out.append("  %s problem+json answers: %d · carrying instance = the request path: %d (%s)" % (db, len(pbs), len(eq), " ".join(sorted(set("%s:%s" % (author(r)[0].split("'")[0].split()[-1] if False else author(r)[0], r["st"]) for r in eq)))))
        out.append("  %s Boot's /error bodies: %d · carrying instance: %d · their keys: %s" % (db, len(errb), len([r for r in errb if "instance" in (problem(r) or {})]), " / ".join(sorted(set(",".join(sorted(problem(r) or {})) for r in errb)))))
        ck.append((len(eq) == len(pbs) and pbs, "%s: every problem+json answer of the matrix carries instance = its request path (%d/%d) - the route's, the advice's and Boot's handler's alike" % (db, len(eq), len(pbs))))
        ck.append((errb and all("instance" not in (problem(r) or {}) for r in errb), "%s: Boot's /error bodies carry no instance (the four-key shape)" % db))
        vs.append(("problem_" + db, len(pbs)))
    ck.append((not si, "no TiffinBox source calls setInstance: the route's and the advice's ProblemDetail leave it null, and the instance on the wire is filled by Framework (the bodies carry the request path)"))
    rf = rfc("rfc9457.txt", '3.1.5.  "instance"', "identifies the specific occurrence of the problem")
    out.append("  RFC 9457 §3.1.5: %s" % rf); ck.append((rf is not None, "RFC 9457 §3.1.5 read off the filed copy"))
    return V(out, ck, vs)

def v_cross(pg, h2):
    out, ck, vs = [], [], []
    mp, ap = pg[0], pg[1]; mh, ah = h2[0], h2[1]
    lp = [a["lab"] for a in ap]; lh = [a["lab"] for a in ah]
    ck.append((lp == lh, "the two JVMs sent the same requests in the same order (%d)" % len(lp)))
    diff = 0
    for lab in lh:
        a, b = mp.get(lab), mh.get(lab)
        if not a or not b: diff += 1; out.append("  %s: missing on one side" % lab); continue
        ka = (a["m"], a["p"], a["st"], a["ct"], a["sz"], a["sl"], sorted(x.split(" · set")[0] if not x.lower().startswith("allow") else "Allow {%s}" % x.split("{")[-1] for x in a["hd"]), [x[:3] for x in a["acc"]], author(a)[0], a["body"])
        kb = (b["m"], b["p"], b["st"], b["ct"], b["sz"], b["sl"], sorted(x.split(" · set")[0] if not x.lower().startswith("allow") else "Allow {%s}" % x.split("{")[-1] for x in b["hd"]), [x[:3] for x in b["acc"]], author(b)[0], b["body"])
        if ka != kb:
            diff += 1; out.append("  %-11s DIFFERS: %s" % (lab, " · ".join("%s pg %r h2 %r" % (n, x, y) for n, x, y in zip(("method", "path", "status", "type", "bytes", "status lines", "headers", "access", "author", "body"), ka, kb) if x != y)))
        else:
            out.append("  %-11s equal · %s %s -> %s · statements pg %s / h2 %s" % (lab, a["m"], a["p"][:40], a["st"], stm(a), stm(b)))
    ck.append((diff == 0, "every HTTP column (status, content type, bytes, status lines, headers - Allow as a set -, access line, author, body) equal on PostgreSQL and H2 - %d differ" % diff))
    sd = [lab for lab in lh if lab in mp and stm(mp[lab]) != stm(mh[lab])]
    out.append("  the statement column differs on: %s" % (" ".join(sd) or "none"))
    ck.append((not sd, "the statement column is equal too (%d rows differ)" % len(sd)))
    vs.append(("differ", diff))
    return V(out, ck, vs)

VIEWS = {"census": v_census, "authors": v_authors, "six": v_six, "conditional": v_conditional, "limits": v_limits, "cannot": v_cannot, "five": v_five,
         "inert": v_inert, "instance": v_instance, "cross": v_cross}
def view(kind, pgp, h2p):
    pg = load(pgp); h2 = load(h2p)
    if BAD: done()
    out, _, _ = VIEWS[kind](pg, h2)
    for l in out: print(l)
def check_view(kind, fp):
    d = os.path.dirname(os.path.abspath(fp))
    pgp, h2p = os.path.join(d, ".r-matrixpg.new"), os.path.join(d, ".r-matrix.new")
    if not os.path.exists(pgp): pgp, h2p = os.path.join(d, ".r-matrixpg.out"), os.path.join(d, ".r-matrix.out")
    pg = load(pgp); h2 = load(h2p)
    out, ck, vs = VIEWS[kind](pg, h2)
    need(out == lines(fp), "the %s capture = its view recomputed from the two matrix captures" % kind)
    for c, m in ck: need(bool(c), m)
    for k, v in vs: val(k, v)
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

def c_exercise(ls):
    secs = {}; cur = None
    for l in ls:
        m = re.match(r"^== the exercise, (\w+), (\w+) ", l)
        if m: cur = (m.group(1), m.group(2)); secs[cur] = []; continue
        if l.startswith("== "): cur = None; continue
        if cur and l.startswith("  "): secs[cur].append(l[2:])   # named rule: a try's lines are the indented lines under its head
    want = {"broken": ("200", "200", "FAIL", "1"), "solved": ("304", "0", "PASS", "0"), "ifmatch": ("200", "200", "FAIL", "1"), "both": ("200", "200", "FAIL", "1"),
            "daybefore": ("200", "200", "FAIL", "1"), "star": ("200", "200", "FAIL", "1")}
    for (v, sh), out in sorted(secs.items()):
        t = "\n".join(out)
        m = re.search(r"^status (\d+) · body bytes (\d+)\n(PASS|FAIL): status (\S+) · body bytes (\S+)\ncheck exit (\d+)$", t, re.M)
        got = (m.group(1), m.group(2), m.group(3), m.group(6)) if m and m.group(1) == m.group(4) and m.group(2) == m.group(5) else None
        w = want.get(v, ("?",) * 4)
        need(got is not None and got[0] == w[0] and got[2] == w[2] and got[3] == w[3] and (got[1] == w[1] if v == "solved" else got[1] != "0"),
             "%s under %s: status %s · body bytes %s · %s · check exit %s" % (v, sh, *(got or ("?",) * 4)))
    need(len(secs) == 12, "six tries x two shells: %d" % len(secs))
    rd = [l.split("README: ", 1)[1] for l in ls if l.startswith("  README: ")]; so = [l.split("SOLUTION: ", 1)[1] for l in ls if l.startswith("  SOLUTION: ")]
    for name, w, k in (("README.md", rd, ("broken", "bash")), ("SOLUTION.md", so, ("solved", "bash"))):
        need(w == [x for x in secs.get(k, []) if not x.startswith("check exit ")], "%s's What it prints = the %s run's output (the harness's own 'check exit' line set apart)" % (name, k[0]))
    sz = None
    for l in secs.get(("broken", "bash"), []):
        m = re.match(r"^status 200 · body bytes (\d+)$", l)
        if m: sz = m.group(1)
    val("exercise", "broken-FAIL,solved-PASS,ifmatch-FAIL,both-FAIL,daybefore-FAIL,star-FAIL"); val("css_bytes", sz)
    done()

# ---- hashable, values -------------------------------------------------------------------------------------------------------------------
def hashable(nm, p):
    """The capture as published, minus the guard's load lines; every Allow list read as a sorted set (the order Spring MVC sends is a
    hash order that moves between JVM starts - U02's finding; the set is the fact, the order as sent stays on the capture)."""
    for l in lines(p):
        if re.match(r"^  guard before ", l): continue
        l = re.sub(r"load1 [0-9.]+", "load1 <n>", l)
        l = re.sub(r"^(     header: [Aa]llow: ).*? · (set \{.*\})$", r"\1\2", l)
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

CAPS = {"matrixpg": lambda ls: matrix(ls, "pg"), "matrix": lambda ls: matrix(ls, "h2"), "seven": c_seven, "surface": c_surface, "exercise": c_exercise}

if __name__ == "__main__":
    a = sys.argv[1:]
    try:
        if not a: fail("no mode"); done()
        if a[0] == "static": static(a[1])
        elif a[0] == "hook": print(HOOK)
        elif a[0] == "exq": print(EXQ)
        elif a[0] == "spoken": spoken(a[1], a[2], a[3])
        elif a[0] == "view": view(a[1], a[2], a[3])
        elif a[0] == "hashable": hashable(a[1], a[2])
        elif a[0] == "values": values(a[1], a[2])
        elif a[0] in CAPS: CAPS[a[0]](lines(a[1]))
        elif a[0] in VIEWS: check_view(a[0], a[1])
        else: fail("unknown mode %r" % a[0]); done()
    except SystemExit:
        raise
    except Exception as e:
        print("FAIL the checker could not read its input (%s: %s)" % (e.__class__.__name__, str(e)[:160])); sys.exit(1)
