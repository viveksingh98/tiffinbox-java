"""Course 9 unit 05's checker (python3 -I -B harness/chk05.py MODE ...). Every number the README may say is re-derived here from a capture's
own lines (or a shipped file), never typed. Each listing line a check reads is parsed by a named pattern or skipped by a named rule; a line
it cannot parse is a FAIL line and exit 1, never a traceback. The request-block reader and the author rule are U03's (copied from U03's
harness, chk03.py: parse, hdr, reqs, errs, author - the cache sub-line widened to both caches; the classes are U03's CLASSES).
Modes:
  static AFTER BEFORE      the carried prose slice, XFAM_S9S1's md5, the change's files, the pin, the stale sentences (R.250), the lines rule
  hook | exq               print the brief's spoken lines (typed ONCE, here)
  spoken HOOK EXQ GLOSS    the spoken lines: byte-equal to the brief, words, digits, spellings, statuses, Hinglish, dur9
  view matrix FILES...     every PATCH answer of the named captures, one ROW line each (PostgreSQL's files first)
  <capture> FILE           one capture's checks; prints ok/FAIL lines and one VALUES line
  hashable NAME FILE       the capture with its load-dependent lines dropped, for receipts.md5
  values README VALS       README.md's values block = this run's VALUES lines
  surefire / mappings / features   the receipts' small readers

THE AUTHOR RULE (U03's, S9.31): the author of a response is the part of the server that wrote its status line and body, read off the
request's own witnesses, in this order: (1) an ERROR-dispatch witness line -> Boot's /error; (2) no REQUEST-dispatch witness line -> Tomcat;
(3) the resolver's line names an advice -> TiffinBox's advice (TiffinBoxErrors) or Boot's problem-details handler (ProblemDetailsExceptionHandler);
(4) ResourceHttpRequestHandler -> the static handler; (5) post-handle yes and a 3xx with Location -> Spring MVC's redirect; (6) HttpOptionsHandler ->
Spring MVC's OPTIONS handler; (7) post-handle yes -> the route; anything else -> unattributed (a FAIL line)."""
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
S1B = os.path.join(C9R, "_briefs", "UNIT-BRIEFS-S1-DESIGN.md")
J9 = os.path.join(os.path.expanduser("~"), "Desktop", "PromptVidya-Automation", "java9_series.py")
HOOK = "Send Priya a PATCH with only her meals, and Jackson 3 refuses it: four hundred. Leave out her meal type instead, and it reads as null."
EXQ = "Your turn: this PATCH sends Meera's meals as plain JSON and the server refuses it. Send it so only her meals change."
GLOSSQ = "a change that names only the fields it changes"
ROUTE, ADVICE, BOOTPD, STATIC, REDIRECT, BOOTERR, TOMCAT = ("the route", "TiffinBox's advice", "Boot's problem-details handler", "the static handler",
                                                         "Spring MVC's redirect", "Boot's /error", "Tomcat")
OPTS = "Spring MVC's OPTIONS handler"
CLASSES = [ROUTE, ADVICE, BOOTPD, STATIC, REDIRECT, BOOTERR, TOMCAT, OPTS]
LEAK = ("jakarta.", "tools.jackson", "Exception", "parsson", "Parsson")

def lines(p):
    return open(p, encoding="utf-8", errors="replace").read().splitlines()

# ---- static ---------------------------------------------------------------------------------------------------------------------------
WEB = "tiffinbox-web/src/main/java/com/tiffinbox/web/"
CORE = "tiffinbox-core/src/main/java/com/tiffinbox/"
NEW = [WEB + "CustomerPatches.java", "tiffinbox-web/src/test/java/com/tiffinbox/web/CustomerPatchesTest.java"]
CHANGED = ["pom.xml", "tiffinbox-web/pom.xml", CORE + "CustomerEntity.java", CORE + "CustomerRepository.java", "README.md"]
BRIEF_LINES = {"naive": 6, "merge-jsonnode": 36, "merge-jsonp": 14, "jsonpatch-jsonp": 21}

def method_lines(path, sig):
    """THE LINES RULE: the non-blank, non-comment lines of a method, from the line holding its signature to its closing brace (braces
    counted from the signature line on); a comment line starts with //, /*, * or */ once stripped. Returns None when the signature is
    not found exactly once."""
    src = open(path, encoding="utf-8").read().split("\n")
    hit = [i for i, l in enumerate(src) if sig in l]
    if len(hit) != 1: return None
    depth = 0; n = 0; started = False
    for l in src[hit[0]:]:
        t = l.strip()
        if t and not t.startswith(("//", "/*", "*", "*/")): n += 1
        depth += l.count("{") - l.count("}")
        if "{" in l: started = True
        if started and depth == 0: return n
    return None

def static(after, before):
    md = lambda x: hashlib.md5("\n".join(x).encode()).hexdigest()
    end = "# --- XFAM_S9S1 end ---"
    s9 = open(os.path.join(HERE, "s905.py"), encoding="utf-8").read().split("\n")
    s4 = open(os.path.join(UNIT, "..", "c9-unit04", "harness", "s904.py"), encoding="utf-8").read().split("\n")
    s3 = open(os.path.join(UNIT, "..", "c9-unit03", "harness", "s903.py"), encoding="utf-8").read().split("\n")
    if any(end not in s for s in (s9, s4, s3)): fail("the XFAM_S9S1 end marker is missing in s905.py, s904.py or s903.py"); done()
    a = lambda s: next(i for i, l in enumerate(s) if l.endswith('"""') and i > 0)
    sl = lambda s: s[a(s) + 1:s.index(end) + 1]
    need(sl(s9) == sl(s4), "s905.py's base + XFAM_S9S1 (after its docstring, through the block's end marker) = s904.py's, %d lines, md5 %s" % (len(sl(s4)), md(sl(s4))))
    need(sl(s9) == sl(s3), "= U03's s903.py's slice (copied from U03's harness)")
    t9 = "\n".join(s9); t4 = "\n".join(s4)
    rx = r"# --- XFAM_S9S1 begin ---\n.*?# --- XFAM_S9S1 end ---"
    b4 = re.search(rx, t4, re.S); b9 = re.search(rx, t9, re.S)
    need(b4 is not None and b9 is not None and b4.group(0) == b9.group(0), "the XFAM_S9S1 block, delimited, byte-equal to U04's")
    if b9:
        h = hashlib.md5(b9.group(0).encode()).hexdigest()
        print("  XFAM_S9S1_SLICE_MD5 = %s (computed the way ../c9-unit04/harness/chk04.py computes it)" % h); val("xfam_s9s1_md5", h[:8])
    need(not re.search(r"^XU0[1234] = ", t9, re.M), "XU01-XU04 are not carried")
    need(re.search(r"^XU05 = ", t9, re.M) is not None and re.search(r"^u04 = u05$", t9, re.M) is not None, "U05's own family (XU05) follows the carried slice; u04 = u05 (U01's binding)")
    for f in NEW: need(os.path.isfile(os.path.join(after, f)) and not os.path.exists(os.path.join(before, f)), "new in after/, absent from before: " + f)
    for f in CHANGED:
        need(open(os.path.join(after, f), "rb").read() != open(os.path.join(before, f), "rb").read(), "changed by this unit: " + f)
    pp = open(os.path.join(after, "pom.xml")).read(); wp = open(os.path.join(after, "tiffinbox-web/pom.xml")).read()
    pv = re.findall(r"<parsson\.version>([0-9.]+)</parsson\.version>", pp)
    need(len(pv) == 1, "the parent declares parsson.version once (S9.7): %s" % pv); val("parsson_pin", pv[0] if pv else "none")
    need("parsson" not in open(os.path.join(before, "pom.xml")).read(), "before's parent names no Parsson")
    need(re.search(r"<groupId>jakarta\.json</groupId>\s*<artifactId>jakarta\.json-api</artifactId>\s*</dependency>", wp) is not None, "tiffinbox-web declares jakarta.json-api with no version (Boot's)")
    need(re.search(r"<groupId>org\.eclipse\.parsson</groupId>\s*<artifactId>parsson</artifactId>\s*<version>\$\{parsson\.version\}</version>", wp) is not None, "tiffinbox-web declares parsson at ${parsson.version}")
    need("<artifactId>spring-boot-starter-data-elasticsearch</artifactId>" in wp, "the Elasticsearch starter stays")
    pv0 = re.search(r"<parent>.*?<version>([0-9.]+)</version>", pp, re.S)
    need(pv0 is not None and pv0.group(1) == "4.1.3", "the Boot parent stays 4.1.3")
    need("<tomcat.version>11.0.29</tomcat.version>" in pp and "<h2.version>2.5.250</h2.version>" in pp, "tomcat.version and h2.version untouched")
    # the stale hunt (R.250 / R.453): every sentence the change makes false carries its unit 05 note
    rd = open(os.path.join(after, "README.md"), encoding="utf-8").read()
    need("no PUT, PATCH or DELETE route" in rd and "*Course 9, unit 05: the set-up's \"no PUT, PATCH or DELETE route\" is no longer true" in rd, "README: the set-up's \"no PUT, PATCH or DELETE route\" kept as written, with its unit 05 note")
    need("## Course 9 · unit 05" in rd, "README: the unit 05 card")
    need("`/customers/import` and `PATCH` are not keyed" in rd, "README: unit 04's \"PATCH are not keyed\" stays (still true)")
    cr = open(os.path.join(after, CORE + "CustomerRepository.java"), encoding="utf-8").read()
    need("and add empties that cache" in cr and "Course 9, unit 05: add is no longer the only write that empties a cache" in cr, "CustomerRepository's Javadoc: \"add empties that cache\" (Course 8 unit 08's) gains its unit 05 note")
    need(cr.count("@Caching(evict") == 1 and "@CacheEvict(cacheNames = \"customer\", key = \"#name\")" in cr, "CustomerRepository.update evicts customers and both names in customer")
    # the lines rule
    pj = os.path.join(HERE, "src", "probe", "Patch.java"); cpj = os.path.join(after, WEB + "CustomerPatches.java")
    got = {"naive": method_lines(pj, "Customer naive("), "merge-jsonnode": method_lines(pj, "ResponseEntity<Object> merge("),
           "merge-jsonp": method_lines(cpj, "ResponseEntity<?> merge("), "jsonpatch-jsonp": method_lines(cpj, "ResponseEntity<?> jsonPatch(")}
    for k, v in got.items():
        need(v is not None, "the lines rule found %s's method once" % k)
        print("  lines %s: %s (the brief's %d; re-measure%s)" % (k, v, BRIEF_LINES[k], "" if v == BRIEF_LINES[k] else " - differs"))
    print("  the lines rule: non-blank, non-comment lines from the signature's line to the closing brace; the shipped methods' helpers (parse, shapeError, apply, patched, readBack) are counted apart: %d"
          % sum(method_lines(cpj, s) or 0 for s in ("private static JsonValue parse(", "private static String shapeError(", "private ResponseEntity<?> apply(", "private JsonValue patched(", "private Customer readBack(")))
    val("lines", "/".join(str(got[k]) for k in ("naive", "merge-jsonnode", "merge-jsonp", "jsonpatch-jsonp")))
    if os.path.exists(J9):
        t = open(J9, encoding="utf-8").read(); m = re.search(r'"05": "([^"]+)"', t)
        need(m is not None and m.group(1) == "PATCH Properly: JSON Patch and Merge Patch", "java9_series.TITLES['05'] = %r" % (m.group(1) if m else None))
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
    gl = [i + 1 for i, l in enumerate(b) if '"' + GLOSSQ + '"' in l]
    need(hook == HOOK and bool(hl), "the hook is S1B's, byte for byte - S1B line %s" % hl)
    need(exq == EXQ and bool(el), "the exercise's line is RED-C9-S1 #37's, byte for byte - S1B line %s" % el)
    need(gloss == "A partial update: " + GLOSSQ + "." and bool(gl), "the gloss's quoted words are S1B's (line %s): %r" % (gl, gloss))
    hw = len(hook.split()); ew = len(exq.split())
    need(hw == 26, "the hook: %d words (wc -w)" % hw)
    need(ew == 22, "the exercise: %d words (wc -w) - #37's 22; :342's older line is 21" % ew)
    for name, s in (("the hook", hook), ("the exercise", exq), ("the gloss", gloss)):
        nd = re.findall(r"\d", s)
        print("  %s: digits %s · the status gate %s · the spelling gate %s · Hinglish %s · dur9 %s" % (name, "".join(nd) or "0", "hit" if STATUS.search(s) else "0",
              SPELL.search(s).group(0) if SPELL.search(s) else "0", "hit" if HING.search(s) else "0", dur.search(s).group(0) if dur is not None and dur.search(s) else "0"))
        need(not STATUS.search(s), "%s: the status gate 0" % name)
        need(not SPELL.search(s), "%s: the spelling gate 0 (API, URI, URL, RFC bare)" % name)
        need(not HING.search(s), "%s: the Hinglish list 0" % name)
        if dur is not None: need(not dur.search(s), "%s: dur9 0" % name)
    need(re.findall(r"\d", hook) == ["3"], "the hook's one digit is Jackson's major (3), a name - not a status (the status gate does not match it)")
    need(not re.search(r"\d", exq), "the exercise's line holds no digit")
    print("  the hook: %d words (wc -w) · the exercise: %d words · JSON and PATCH written as the brief writes them (the spelling gate names neither)" % (hw, ew))
    val("hook_words", hw); val("exercise_words", ew)
    done()

# ---- the request blocks (U03's reader, copied; the cache sub-line widened to both caches) ------------------------------------------------
ASK = re.compile(r"^-- ([\w-]+) \| ([A-Z]+) (\S+) -> (\d{3}) (\S*) (\d+) \(curl exit (\d+)\)$")
SRV = re.compile(r"^([A-Z]+) (\S+)( \[dispatch (\w+), for (\S+)\])? -> (\d{3}) \| handler (\S+) \| post-handle (no|yes \(count (\d+)\))(?: \| ex (\S+))?(?: \| thrown (\S+))?(?: \| async started)? \| statements (\d+) \(writes (\d+), prepares (\d+)\)$")
ACC = re.compile(r"^([A-Z]+) (\S+?) (\d{3}) (\S+)$")
CACHE = re.compile(r"^cache: before customers (\[.*?\]) customer (\[.*?\]) · after customers (\[.*?\]) customer (\[.*?\])$")
def parse(ls):
    asks = []; heads = []; cur = None
    for l in ls:
        if l.startswith("-- "):
            a = ASK.match(l)
            if not a: fail("a request line the reader cannot parse: %r" % l[:120]); cur = None; continue
            cur = {"lab": a.group(1), "m": a.group(2), "p": a.group(3), "st": a.group(4), "ct": a.group(5), "sz": int(a.group(6)), "rc": a.group(7),
                   "sl": [], "hd": [], "acc": [], "srv": [], "rby": [], "res": [], "cache": None, "log": [], "body": None}
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
            if t.startswith("cache: "):
                m = CACHE.match(t)
                if not m: fail("a cache sub-line the reader cannot parse: %r" % t[:120]); continue
                cur["cache"] = m.groups(); continue
            if t.startswith("log: "): cur["log"].append(t[5:]); continue
            if t.startswith("body: "): cur["body"] = t[6:]; continue
            fail("a sub-line the reader cannot parse: %r" % t[:100]); continue
        if l.startswith("     "): fail("an indented line outside a request block: %r" % l[:100]); continue
        cur = None
        heads.append(l)
    return asks, heads

def hdr(r, name):
    for h in r["hd"]:
        if h.lower().startswith(name.lower() + ":"): return h.split(":", 1)[1].split(" · set {")[0].strip()
    return None
def hset(r, name):
    for h in r["hd"]:
        if h.lower().startswith(name.lower() + ":"):
            m = re.search(r" · set \{(.*)\}$", h); return m.group(1) if m else None
    return ""
def reqs(r): return [s for s in r["srv"] if s["disp"] is None]
def errs(r): return [s for s in r["srv"] if s["disp"] == "ERROR"]
def author(r):
    """THE AUTHOR RULE (the docstring's steps, in order). Returns (class, evidence) or (None, why). Copied from U03's chk03.py."""
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
def writes(r):
    q = reqs(r); return q[0]["w"] if q else None
def head(heads, rx):
    for h in heads:
        m = re.search(rx, h)
        if m: return m
    return None
ROWRX = r"%s: (\S+ \S+ \S+ \S+ v\d+|no row) \("

def load(p):
    ls = lines(p); asks, heads = parse(ls); return ls, {a["lab"]: a for a in asks}, heads
def st(R, lab): return R[lab]["st"] if lab in R else None
def expect(R, lab, code, who=None, detail=None):
    r = R.get(lab)
    if r is None: fail("%s: no request block" % lab); return None
    need(r["st"] == code, "%s: %s %s -> %s (want %s)" % (lab, r["m"], r["p"], r["st"], code))
    if who:
        a, ev = author(r); need(a == who, "%s: the author is %s (%s)" % (lab, a, ev))
    if detail is not None:
        pd = problem(r); need(pd is not None and detail in str(pd.get("detail")), "%s: detail holds %r (%r)" % (lab, detail, pd.get("detail") if pd else None))
    return r
def noleak(R, labs):
    for lab in labs:
        r = R.get(lab)
        if r and r["body"]: need(not any(x in r["body"] for x in LEAK), "%s: the body names no class, no Jackson or JSON-P text" % lab)
def rowv(heads, label):
    m = head(heads, ROWRX % re.escape(label)); return m.group(1) if m else None

def c_bodies(p, db):
    ls, R, H = load(p)
    for lab in ("b-int-absent", "b-int-null"): expect(R, lab, "400", BOOTPD, "Failed to read request")
    for lab in ("b-text-absent", "b-text-null"):
        r = expect(R, lab, "400", ROUTE, "the customer breaks 1 rule")
        pd = problem(r) if r else None; need(pd is not None and pd.get("errors") == {"mealType": "must not be null"}, "%s: errors {mealType: must not be null}" % lab)
    for lab in ("b-int-absent", "b-int-null", "b-text-absent", "b-text-null"): need(writes(R.get(lab, {"srv": []})) == 0, "%s: write statements 0" % lab)
    need(head(H, r"rows Asha after the four: 0 ") is not None, "nothing stored: rows Asha 0")
    f = head(H, r"DeserializationFeature: (.*)$"); fs = f.group(1) if f else ""
    for k, v in (("FAIL_ON_NULL_FOR_PRIMITIVES", "enabled"), ("ACCEPT_FLOAT_AS_INT", "disabled"), ("FAIL_ON_UNKNOWN_PROPERTIES", "disabled")): need("%s %s" % (k, v) in fs, "Jackson 3: %s %s" % (k, v))
    need(head(H, r"JSON Boot's mapper bean: tools\.jackson\.databind\.json\.JsonMapper \(3\.") is not None, "the mapper bean is Jackson 3's JsonMapper")
    need(head(H, r"JsonProbe: JSON read \[mealType absent\] -> Customer\[.*mealType=null\]") is not None, "an absent text field reads as null (JsonProbe)")
    need(head(H, r"JsonProbe: JSON read \[mealsPerDay absent\] !! tools\.jackson\.databind\.exc\.MismatchedInputException: Cannot map `null` into type `int`") is not None, "an absent int is refused at the read (JsonProbe)")
    need(head(H, r"JsonProbe: JSON read \[an unknown field\] -> Customer\[") is not None, "an unknown member is ignored (JsonProbe)")
    val("codes", "/".join(st(R, l) or "-" for l in ("b-int-absent", "b-int-null", "b-text-absent", "b-text-null")))

def c_trap(p, db):
    ls, R, H = load(p)
    fe = re.findall(r"^== %s trap-(a|b|a2): .* - FAIL_ON_NULL_FOR_PRIMITIVES (\w+)$" % db, "\n".join(ls), re.M)
    need(dict(fe) == {"a": "enabled", "b": "disabled", "a2": "enabled"}, "the feature per JVM: trap-a enabled, trap-b disabled, trap-a2 enabled (%s)" % fe)
    pb = rowv(H, "Priya before"); pa = rowv(H, "Priya after trap-a"); pv = rowv(H, "Priya after the @Valid copy"); pbb = rowv(H, "Priya after trap-b"); pa2 = rowv(H, "Priya after trap-a2")
    expect(R, "trap-a", "400", BOOTPD, "Failed to read request")
    need(pb is not None and pb == pa, "trap-a: Priya's row unchanged (%s)" % pa)
    expect(R, "trap-text", "500", BOOTERR)
    rb = rowv(H, "Ravi before"); ra = rowv(H, "Ravi after the String-absent body")
    need(rb is not None and rb == ra, "the String-absent body: Ravi's row unchanged (%s)" % ra)
    tw = writes(R.get("trap-text", {"srv": []})); need(tw is not None and tw >= 1, "the String-absent body: %s write statement(s) sent (the table refused it)" % tw)
    expect(R, "trap-b-valid", "400", ROUTE, "the body breaks")
    need(pv is not None and pv == pa, "the @Valid copy: Priya's row unchanged")
    r = expect(R, "trap-b", "200", ROUTE)
    need(r is not None and r["body"] and '"pricePerMeal":0' in r["body"], "trap-b: the answer says pricePerMeal 0")
    need(pbb is not None and pbb.split()[2] == "0" and pbb.split()[1] == "2", "trap-b: the second client reads Priya with 2 meals and a price of 0 (%s)" % pbb)
    expect(R, "trap-a2", "400", BOOTPD, "Failed to read request")
    need(pa2 is not None and pa2 == pbb, "trap-a2: the row as trap-b left it (%s) - the 0 is the earlier write" % pa2)
    revs = re.findall(r"/revenue (\d+)$", "\n".join(ls), re.M)
    if len(revs) == 7:   # trap-a before/after · trap-b before / after the @Valid copy / after trap-b · trap-a2 before/after
        need(revs[0] == revs[1], "trap-a: /revenue unchanged %s" % revs[0]); need(revs[2] == revs[3], "the @Valid copy: /revenue unchanged %s" % revs[3])
        need(revs[3] != revs[4], "trap-b: /revenue %s -> %s" % (revs[3], revs[4]))
        need(revs[4] == revs[5] == revs[6], "trap-a2: /revenue as trap-b left it %s" % revs[6])
        val("revenue", "%s->%s" % (revs[3], revs[4]))
    else: fail("seven /revenue readings (found %d)" % len(revs))
    val("priya", "%s->%s" % ("_".join(pb.split()[1:4]) if pb else "-", "_".join(pbb.split()[1:4]) if pbb else "-"))
    val("codes", "/".join(st(R, l) or "-" for l in ("trap-a", "trap-text", "trap-b-valid", "trap-b", "trap-a2")))

SHIPPED_SET = "application/json-patch+json,application/merge-patch+json"
def c_merge(p, db):
    ls, R, H = load(p)
    b0 = rowv(H, "Meera before"); b1 = rowv(H, "Meera after m-meals"); b2 = rowv(H, "Meera after the refused ones")
    r = expect(R, "m-meals", "200", ROUTE)
    if b0 and b1:
        x, y = b0.split(), b1.split()
        need(y[1] == "2" and y[2] == x[2] and y[3] == x[3], "m-meals: meals 2, price and meal type KEPT (%s -> %s)" % (b0, b1))
        need(int(y[4][1:]) == int(x[4][1:]) + 1, "m-meals: the version one higher (%s -> %s)" % (x[4], y[4]))
    if r and r["cache"]: need(r["cache"][3] == "[]" or "Meera" not in r["cache"][3], "m-meals: no Meera entry in customer after it")
    expect(R, "m-type-null", "422", ROUTE, "breaks 1 rule"); expect(R, "m-price-null", "422", ROUTE, "cannot be read at pricePerMeal")
    expect(R, "m-price-text", "422", ROUTE, "cannot be read at pricePerMeal"); expect(R, "m-rule", "422", ROUTE, "breaks 1 rule")
    expect(R, "m-notjson", "400", ROUTE, "not JSON")
    expect(R, "m-unknown", "200", ROUTE)
    r = expect(R, "m-json", "415", BOOTPD)
    need(r is not None and hset(r, "Accept-Patch") == SHIPPED_SET, "m-json: Accept-Patch names both media types (%s)" % (hdr(r, "Accept-Patch") if r else None))
    expect(R, "m-nobody", "404", ADVICE, "no customer named Nobody")
    need(b1 is not None and b1 == b2, "the refused ones, the unknown member and the 415 leave Meera as m-meals left her (%s)" % b2)
    for lab in ("m-type-null", "m-price-null", "m-price-text", "m-rule", "m-notjson", "m-json", "m-nobody", "m-unknown"):
        need(writes(R.get(lab, {"srv": []})) == 0, "%s: write statements 0" % lab)
    noleak(R, [l for l in R if l.startswith("m-")])
    need(not any(a["st"] == "500" and a["p"].startswith("/api/") for a in R.values()), "the shipped route answered no five hundred")
    expect(R, "h-mergep-null", "500", BOOTERR); expect(R, "h-mergep-notjson", "500", BOOTERR)
    pd = problem(R["m-type-null"]) if "m-type-null" in R else None
    need(pd is not None and "type" not in pd and pd.get("instance") == "/api/v1/customers/Meera", "the route's bodies: no type (about:blank), instance = the path")
    val("codes", "/".join(st(R, l) or "-" for l in ("m-meals", "m-type-null", "m-price-null", "m-price-text", "m-rule", "m-notjson", "m-unknown", "m-json", "m-nobody")))

def c_jsonpatch(p, db):
    ls, R, H = load(p)
    b0 = rowv(H, "Meera before"); b1 = rowv(H, "Meera after j-replace"); b2 = rowv(H, "Meera after j-test"); b3 = rowv(H, "Meera after the refused ones")
    expect(R, "j-replace", "200", ROUTE)
    need(b1 is not None and b1.split()[1] == "1", "j-replace: meals 1 (%s)" % b1)
    r = expect(R, "j-test", "409", ROUTE, "a test operation in the patch does not hold")
    need(r is not None and any("JSON-P's words: The JSON Patch operation 'test' failed for path '/mealsPerDay'" in x for x in r["log"]), "j-test: JSON-P's words in the JVM's log line, not in the body")
    need(b1 is not None and b1 == b2 == b3, "the failed test and every refused patch leave Meera as j-replace left her (%s)" % b3)
    for lab in ("j-remove", "j-null", "j-text"): expect(R, lab, "422", ROUTE)
    for lab, d in (("j-op", "has no op this route knows"), ("j-novalue", "has no value"), ("j-nomember", "has a path to no member"), ("j-object", "is an array of operations"), ("j-notjson", "is not JSON")):
        expect(R, lab, "400", ROUTE, d); need(writes(R.get(lab, {"srv": []})) == 0, "%s: no statement written" % lab)
    r = expect(R, "j-json", "415", BOOTPD); need(r is not None and hset(r, "Accept-Patch") == SHIPPED_SET, "j-json: Accept-Patch names both")
    noleak(R, [l for l in R if l.startswith("j-")])
    need(not any(a["st"] == "500" and a["p"].startswith("/api/") for a in R.values()), "the shipped route answered no five hundred")
    hj = {l: R[l] for l in R if l.startswith("h-jp-")}
    for l, r in sorted(hj.items()): print("  the harness's route %s -> %s · %s" % (l, r["st"], (r["body"] or "")[:150]))
    msgs = [problem(r).get("detail") for r in hj.values() if r["st"] == "409" and problem(r)]
    need(len(hj) == 5, "the harness's JSON Patch route: five answers printed (JSON-P's JsonException, one class, its messages)")
    val("codes", "/".join(st(R, l) or "-" for l in ("j-replace", "j-test", "j-remove", "j-null", "j-text", "j-op", "j-novalue", "j-nomember", "j-object", "j-notjson", "j-json")))
    val("harness", "/".join(st(R, l) or "-" for l in ("h-jp-op", "h-jp-novalue", "h-jp-nomember", "h-jp-test", "h-jp-object")))

def c_retry(p, db):
    ls, R, H = load(p)
    rb = rowv(H, "Ravi before"); r1 = rowv(H, "Ravi after r-merge-1"); r2 = rowv(H, "Ravi after r-merge-2"); t1 = rowv(H, "Ravi after r-tr-1"); t2 = rowv(H, "Ravi after r-tr-2")
    expect(R, "r-merge-1", "200", ROUTE); expect(R, "r-merge-2", "200", ROUTE)
    need(r1 is not None and r1 == r2, "the merge patch twice: the row equal after both (%s; the version moved %s -> %s -> %s)" % (r2, rb.split()[4] if rb else "-", r1.split()[4] if r1 else "-", r2.split()[4] if r2 else "-"))
    w2 = writes(R.get("r-merge-2", {"srv": []})); print("  r-merge-2: write statements %s (Hibernate's dirty check: nothing moved)" % w2)
    expect(R, "r-tr-1", "200", ROUTE); expect(R, "r-tr-2", "409", ROUTE, "a test operation in the patch does not hold")
    need(t1 is not None and t1 == t2, "test-then-replace twice: 200, then 409, the row as after the first (%s)" % t2)
    need(head(H, r"key table rows: 0 ") is not None, "the key table: 0 rows (a PATCH is not keyed)")
    val("merge_twice", "%s,%s" % (st(R, "r-merge-1"), st(R, "r-merge-2"))); val("testreplace_twice", "%s,%s" % (st(R, "r-tr-1"), st(R, "r-tr-2")))
    val("versions", "->".join(x.split()[4] for x in (rb, r1, r2) if x)); val("second_writes", w2)

def old200(R): return st(R, "old") == "200"
def c_rename(p, db):
    ls, R, H = load(p)
    r = expect(R, "w-old", "200"); expect(R, "w-list", "200")
    r = expect(R, "rename", "200", ROUTE)
    if r and r["cache"]:
        need("Meera" in r["cache"][1], "rename: Meera's customer entry warm before (%s)" % r["cache"][1])
        need(r["cache"][2] == "[]" and "Meera" not in r["cache"][3], "rename: customers empty and no Meera entry in customer after it (%s · %s)" % (r["cache"][2], r["cache"][3]))
    need(not old200(R), "the old address does not answer two hundred on the shipped route")
    expect(R, "old", "404", ADVICE, "no customer named Meera"); expect(R, "new", "200", ROUTE)
    r = R.get("list"); need(r is not None and r["body"] and '"Mira"' in r["body"] and '"Meera"' not in r["body"], "the list is renamed")
    if r: need(reqs(r) and reqs(r)[0]["stm"] >= 1, "the list after the rename read the table (statements %s)" % (reqs(r)[0]["stm"] if reqs(r) else None))
    expect(R, "taken", "409", ROUTE, "a customer with that name already exists")
    need(head(H, r"rows Ravi 1 .*rows Mira 1 ") is not None, "the taken name: Ravi 1 row, Mira 1 row - nothing stored for the rename")
    val("codes", "/".join(st(R, l) or "-" for l in ("rename", "old", "new", "list", "taken")))

def c_stale(p, db):
    ls, R, H = load(p)
    expect(R, "rename", "200", ROUTE)
    r = expect(R, "old", "200", ROUTE)
    need(r is not None and reqs(r) and reqs(r)[0]["stm"] == 0, "the old address: 200 from Caffeine (statements 0)")
    if r and r["cache"]: need("Meera" in r["cache"][1], "the old name's entry is still in customer (%s)" % r["cache"][1])
    r = expect(R, "new", "200", ROUTE); need(r is not None and reqs(r) and reqs(r)[0]["stm"] >= 1, "the new address: read from the table")
    r = R.get("list"); need(r is not None and r["body"] and '"Meera"' in r["body"] and '"Mira"' not in r["body"], "the list still holds the old name")
    m = head(H, r"spec: maximumSize=100,recordStats,expireAfterWrite=10m .*customers\.expireAfterWrite PT10M customer\.expireAfterWrite PT10M")
    need(m is not None, "the configured time to live, read back: the spec's expireAfterWrite=10m and the running cache's PT10M")
    sib = p.replace(".r-stale", ".r-rename")
    if os.path.exists(sib):
        _, R2, _ = load(sib)
        need(not old200(R2), "the cannot-fail detector (R.276 + R.374): the check 'the old address answered 200' run on the shipped rename's capture FAILS there")
    else: fail("the shipped rename's capture %s is not beside this one" % os.path.basename(sib))
    val("old", st(R, "old")); val("ttl", "PT10M")

def c_reader(p):
    ls, R, H = load(p)
    want = {"rd-meals": "200", "rd-type-null": "400", "rd-price-null-unmapped": "500", "rd-price-null": "422", "rd-unknown": "200", "rd-rename": "422",
            "sr-meals": "200", "sr-type-null": "422", "sr-price-null": "422", "sr-unknown": "200", "sr-rename": "200"}
    for k, v in want.items(): expect(R, k, v)
    r = R.get("rd-meals"); need(r is not None and r["body"] and '"before":{' in r["body"] and '"pricePerMeal":100' in r["body"], "readerForUpdating: absent members kept")
    need(head(H, r"JSON readerForUpdating\(record\) -> Customer\[") is not None, "readerForUpdating on a record: a record came back (JsonProbe)")
    val("reader", "/".join(st(R, k) for k in ("rd-meals", "rd-type-null", "rd-price-null-unmapped", "rd-price-null", "rd-unknown", "rd-rename")))
    val("shipped", "/".join(st(R, k) for k in ("sr-meals", "sr-type-null", "sr-price-null", "sr-unknown", "sr-rename")))

ROWL = re.compile(r"^ROW (pg|h2) \| (\w+) \| ([\w-]+) \| ([A-Z]+) (\S+) \| sent (\S+) \| (\d{3}) (\S*) (\d+) \| Accept-Patch \{([^}]*)\} \| (.+?) \| (.+) \| instance (yes|no|-) \| statements (\d+|-) \(writes (\d+|-)\)$")
def view_matrix(files):
    for f in files:
        db = "pg" if "pg.new" in f or "pg.out" in f else "h2"; capn = re.sub(r"^\.r-|(pg)?\.(new|out)$", "", os.path.basename(f))
        if not os.path.exists(f): print("MISSING %s" % f); continue
        ls = lines(f); asks, heads = parse(ls)
        sent = {}
        for a in asks:
            if not (a["p"].startswith("/api/") or a["p"].startswith("/probe/")) or a["m"] != "PATCH": continue
            au, ev = author(a); pd = problem(a)
            inst = "-" if not pd else ("yes" if pd.get("instance") == a["p"].split("?")[0] else "no")
            q = reqs(a)
            print("ROW %s | %s | %s | %s %s | sent %s | %s %s %d | Accept-Patch {%s} | %s | %s | instance %s | statements %s (writes %s)" % (
                db, capn, a["lab"], a["m"], a["p"], "-", a["st"], a["ct"] or "-", a["sz"], hset(a, "Accept-Patch") or "", au, ev, inst,
                q[0]["stm"] if q else "-", q[0]["w"] if q else "-"))
    done_quiet()
def done_quiet(): sys.exit(0)
def c_matrix(p):
    rows = []
    for l in lines(p):
        if not l.startswith("ROW "): continue
        m = ROWL.match(l)
        if not m: fail("a matrix row this checker cannot parse: %r" % l[:120]); continue
        rows.append(m.groups())
    need(not any(l.startswith("MISSING ") for l in lines(p)), "every sibling capture was there")
    need(len(rows) > 0, "the matrix holds %d rows" % len(rows))
    need(all(r[10] in CLASSES for r in rows), "every row has an author (U03's rule): unattributed %d" % sum(1 for r in rows if r[10] not in CLASSES))
    sh = [r for r in rows if r[4].startswith("/api/")]
    need(not any(r[6] == "500" for r in sh), "the shipped route: no five hundred in any row")
    for db in ("pg", "h2"):
        c = collections.Counter((r[6], r[10]) for r in sh if r[0] == db)
        print("  %s: the shipped route's codes and authors: %s" % (db, " · ".join("%s %s x%d" % (k[0], k[1], v) for k, v in sorted(c.items()))))
    key = lambda r: (r[1], r[2])
    pg = {key(r): r for r in rows if r[0] == "pg"}; h2 = {key(r): r for r in rows if r[0] == "h2"}
    need(set(pg) == set(h2), "the same requests on both databases (%d / %d)" % (len(pg), len(h2)))
    moved = [k for k in pg if k in h2 and (pg[k][6:11] != h2[k][6:11] or pg[k][12] != h2[k][12])]
    need(not moved, "PostgreSQL and H2 equal on every HTTP column and the author (moved: %s)" % moved)
    codes = sorted({r[6] for r in sh}); val("codes", ",".join(codes)); val("rows", len(rows))
    au = collections.Counter(r[10] for r in sh if r[0] == "h2")
    val("authors", ",".join("%s:%d" % (k.replace(" ", "_").replace("'", ""), v) for k, v in sorted(au.items())))
    for c in codes:
        who = sorted({r[10] for r in sh if r[6] == c})
        print("  %s: %s" % (c, " / ".join(who)))
    need(any(r[6] == "404" and r[10] == ADVICE for r in sh) and any(r[6] == "409" and r[2] == "j-test" for r in sh) and any(r[6] == "409" and r[2] == "taken" for r in sh),
         "the pairs: 404 by TiffinBox's advice; 409 twice by the route, two causes (a failed test, a taken name)")
    need(all(r[12] == "yes" for r in sh if r[6] != "200"), "instance is the request path on every error body of the shipped route (read off each body)")

def c_moved(p):
    ls = lines(p); M = {}
    for l in ls:
        m = re.match(r"^  (before|after) \| ([A-Z]+ \S+) -> (\d{3}) (\S*) · Allow \{([^}]*)\} · Accept-Patch \{([^}]*)\}$", l)
        if m: M[(m.group(1), m.group(2))] = m.groups()[2:]
        elif l.startswith("  before |") or l.startswith("  after |"): fail("a moved line this checker cannot parse: %r" % l[:120])
    old = ["PATCH /customers", "PATCH /customers/Ravi", "PATCH /revenue", "PATCH /shutdown", "OPTIONS /customers/Ravi"]
    for q in old:
        need(("before", q) in M and M.get(("before", q)) == M.get(("after", q)), "%s: before = after (%s)" % (q, M.get(("after", q))))
    need(M.get(("after", "PATCH /customers"), ("",))[0] == "405" and M[("after", "PATCH /customers")][2] == "GET,POST", "C9-10a: a PATCH to /customers answers 405, Allow the set {GET, POST}")
    a = M.get(("after", "OPTIONS /api/v1/customers/Ravi")); need(a is not None and a[0] == "200" and a[3] == SHIPPED_SET and a[2] == "OPTIONS,PATCH", "after: OPTIONS on the new address: 200, Allow {OPTIONS,PATCH}, Accept-Patch both (%s)" % (a,))
    g = M.get(("after", "GET /api/v1/customers/Ravi")); need(g is not None and g[0] == "405" and g[2] == "PATCH", "after: GET on the new address: 405, Allow {PATCH} (no GET route there: not in this change)")
    b = M.get(("before", "OPTIONS /api/v1/customers/Ravi")); print("  before: OPTIONS /api/v1/customers/Ravi -> %s · GET -> %s (no route there yet)" % (b, M.get(("before", "GET /api/v1/customers/Ravi"))))
    val("moved", sum(1 for q in old if M.get(("before", q)) != M.get(("after", q)))); val("patch_customers", "405:" + M.get(("after", "PATCH /customers"), ("", "", ""))[2])

def c_inert(p):
    ls = lines(p); t = "\n".join(ls)
    S = re.search(r"the expected seven ([0-9a-f]{32}), the old surface ([0-9a-f]{32})", t)
    if not S: fail("the expected hashes"); return
    for side in ("before", "after"):
        m = re.search(r"^  %s: the seven ([0-9a-f]{32}) .*· the old surface ([0-9a-f]{32})" % side, t, re.M)
        need(m is not None and m.group(1) == S.group(1), "%s: the seven = %s" % (side, S.group(1)[:8]))
        need(m is not None and m.group(2) == S.group(2), "%s: the old surface = %s (U04's)" % (side, S.group(2)[:8]))
    need(any("planted: the seven" in l and "unchanged: yes" in l and "moved: yes" in l for l in ls), "the ETag plant: the seven unchanged, the old surface moved")
    need(any("planted:" in l and "(reader exit 3)" in l and " 0 (reader exit 3)" in l for l in ls), "the ETag plant: the feed answers nothing (the reader's exit 3 at its alarm, 0 bytes)")
    val("seven", S.group(1)[:8]); val("surface", S.group(2)[:8])

def c_jsonp(p):
    ls = lines(p); sec = None; T = {"before": [], "after": []}
    for l in ls:
        m = re.match(r"^== (before|after): mvn -o dependency:tree", l)
        if m: sec = m.group(1); continue
        if l.startswith("== "): sec = None; continue
        if sec and l.startswith("  ") and re.match(r"^  [-+\\| ]", l): T[sec].append(l[2:])
    need(any(re.match(r"^  exit 0$", l) for l in ls) and sum(1 for l in ls if l == "  exit 0") == 2, "dependency:tree: exit 0 on both trees")
    def depth(tree, art):
        for l in tree:
            m = re.search(r"^([-+\\| ]*)" + re.escape(art), l)
            if m: return len(m.group(1)) // 3
        return None
    for art in ("jakarta.json:jakarta.json-api:jar:2.1.3", "org.eclipse.parsson:parsson:jar:1.1.9"):
        db, da = depth(T["before"], art), depth(T["after"], art)
        need(db is not None and db > 1 and any("elasticsearch" in l for l in T["before"]), "before: %s only through the Elasticsearch starter (depth %s)" % (art, db))
        need(da == 1, "after: %s direct (depth %s)" % (art, da))
    need(any("<parsson.version>1.1.9</parsson.version>" in l for l in ls), "the pin: parsson.version 1.1.9")
    m = re.search(r"BOOT-INF/lib's: before (\S+) · after (\S+)", "\n".join(ls)); need(m is not None and m.group(1) == m.group(2) == "parsson-1.1.9.jar", "BOOT-INF/lib's Parsson: before = after = parsson-1.1.9.jar")
    pr = [l for l in ls if '"provider"' in l]
    try: d = json.loads(pr[0].strip()) if pr else {}
    except Exception: d = {}
    need(d.get("provider") == "org.eclipse.parsson.JsonProviderImpl" and d.get("providerJar") == "parsson-1.1.9.jar" and d.get("apiJar") == "jakarta.json-api-2.1.3.jar", "the running JVM's provider: org.eclipse.parsson.JsonProviderImpl from parsson-1.1.9.jar")
    need(d.get("mergePatch") == "org.eclipse.parsson.JsonMergePatchImpl" and d.get("jsonPatch") == "org.eclipse.parsson.JsonPatchImpl", "createMergePatch -> JsonMergePatchImpl, createPatch -> JsonPatchImpl")
    val("provider", d.get("provider", "-")); val("pin", "1.1.9")

TESTS_RX = r"^  (\w+) tests (\d+) failures (\d+) errors (\d+) skipped (\d+)$"
IT = {"CustomerEntityRepositoryIT": (21280, 5432), "CustomerAggregatesIT": (21281, 5432), "RedisDatastoreIT": (21282, 6379), "MongoDatastoreIT": (21283, 27017), "ElasticsearchIT": (21284, 9200)}
def u04_tests():
    t = open(os.path.join(UNIT, "..", "c9-unit04", "README.md"), encoding="utf-8").read()
    m = re.search(r"^tests: .*tests_after=(\d+) .*its=(\d+) ", t, re.M); return (int(m.group(1)), int(m.group(2))) if m else (None, None)
def c_tests(p):
    ls = lines(p); sec = None; per = {"unit": {}, "it": {}}
    for l in ls:
        if l.startswith("== Surefire's XML"): sec = "unit"; continue
        if l.startswith("== Failsafe's XML"): sec = "it"; continue
        if l.startswith("== "): sec = None; continue
        m = re.match(TESTS_RX, l)
        if m and sec:
            per[sec][m.group(1)] = int(m.group(2)); need(m.group(3) == m.group(4) == "0", "%s %s: failures and errors 0" % (sec, m.group(1)))
    u4, i4 = u04_tests()
    tot = sum(per["unit"].values()); k = per["unit"].get("CustomerPatchesTest", 0)
    need(u4 is not None and tot == u4 + k and k > 0, "the test phase: %d = U04's %s (its README values block) + %d (CustomerPatchesTest)" % (tot, u4, k))
    need(sum(per["it"].values()) == i4 == 14 and len(per["it"]) == 5, "the ITs: %d in 5 classes (U04's %s)" % (sum(per["it"].values()), i4))
    val("tests", tot); val("tests_u04", u4); val("tests_k", k); val("its", sum(per["it"].values()))
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
    need(re.search(r"mvn verify exit 0 ", "\n".join(ls)) is not None, "mvn verify exit 0")
    need(not any("TIMED OUT" in l for l in ls), "no IT wait timed out (S9.32)")
    need(any(l.startswith("  Testcontainers containers after: 0 ") for l in ls), "Testcontainers containers after: 0")
    libs = re.findall(r"^  (before|after): (\d+) jars", "\n".join(ls), re.M)
    need(len(libs) == 2 and libs[0][1] == libs[1][1], "BOOT-INF/lib before = after (%s)" % libs); val("lib", "/".join(x[1] for x in libs))
    need(any(l == "  the jars whose names moved: 0" for l in ls), "no jar's name moved")
    al = [l for l in ls if l.startswith("  after: ")]
    for j in ("tomcat-embed-core-11.0.29.jar", "netty-common-4.2.20.Final.jar", "spring-core-7.0.11.jar", "spring-boot-4.1.3.jar", "postgresql-42.7.14.jar", "jakarta.json-api-2.1.3.jar", "parsson-1.1.9.jar"):
        need(al and j in al[0], "after/'s BOOT-INF/lib holds " + j)
    h = re.search(r"handler methods: (\d+) · TiffinBox's \(com\.tiffinbox\.\*\) (\d+) · the set-up's (\d+) · unit 04's \(CustomerPauses\) (\d+) · unit 05's \(CustomerPatches\) (\d+) · others (\d+)", "\n".join(ls))
    if not h: fail("the handler-method line")
    else:
        need(int(h.group(2)) == int(h.group(3)) + int(h.group(4)) + int(h.group(5)) and h.group(3) == "12" and h.group(4) == "2", "TiffinBox's handler methods: %s = the set-up's %s + U04's %s + U05's %s" % h.group(2, 3, 4, 5))
        val("handlers", h.group(2)); val("handlers_setup", h.group(3)); val("handlers_u04", h.group(4)); val("handlers_u05", h.group(5))
    need(any("Apache Tomcat/11.0.29" in l for l in ls), "the JVM's Tomcat line: 11.0.29")

def c_exercise(p):
    ls = lines(p)
    def blk(tag, sh):
        out = []; on = False
        for l in ls:
            if l.startswith("== the exercise, %s, %s " % (tag, sh)): on = True; continue
            if on and l.startswith("=="): break
            if on: out.append(l[2:])
        return out
    want = {"broken": ("FAIL", "415"), "solved": ("PASS", "200"), "jsonpatch": ("FAIL", "400"), "typenull": ("FAIL", "422"), "mealstext": ("FAIL", "422"), "other": ("FAIL", "200")}
    for v, (verdict, code) in want.items():
        for sh in ("bash", "zsh"):
            b = blk(v, sh)
            need(any(x.startswith(verdict + ": status " + code) for x in b), "%s (%s): %s with status %s" % (v, sh, verdict, code))
            need(("check exit 0" if verdict == "PASS" else "check exit 1") in b, "%s (%s): check.sh's exit" % (v, sh))
    for v in want: need(blk(v, "bash") == blk(v, "zsh"), "%s: bash and zsh -f print the same" % v)
    ch = re.findall(r"^== the exercise, (\w+), bash .*patch\.sh vs shipped: (\d+) changed lines", "\n".join(ls), re.M)
    need(dict(ch).get("broken") == "0" and dict(ch).get("solved") == "2" and all(dict(ch).get(v) in ("2", "4") for v in ("jsonpatch", "typenull", "mealstext", "other")), "the tries: patch.sh as shipped, SOLUTION's line in place, the refused ones one more line each (%s)" % ch)
    rd = [l[len("  README: "):] for l in ls if l.startswith("  README: ")]; so = [l[len("  SOLUTION: "):] for l in ls if l.startswith("  SOLUTION: ")]
    need([x for x in blk("broken", "bash") if not x.startswith("check exit")] == rd, "exercise/README.md's What it prints = the broken run's lines")
    need([x for x in blk("solved", "bash") if not x.startswith("check exit")] == so, "SOLUTION.md's What it prints = the solved run's lines")
    val("exercise", "broken-415-FAIL,solved-200-PASS,refused-4-FAIL")

CAPS = {"tests": c_tests, "jsonp": c_jsonp, "reader": c_reader, "matrix": c_matrix, "moved": c_moved, "inert": c_inert, "exercise": c_exercise}
PER = {"bodies": c_bodies, "trap": c_trap, "merge": c_merge, "jsonpatch": c_jsonpatch, "retry": c_retry, "rename": c_rename, "stale": c_stale}
def capture(nm, p):
    if nm in CAPS: CAPS[nm](p)
    elif nm in PER: PER[nm](p, "h2")
    elif nm.endswith("pg") and nm[:-2] in PER: PER[nm[:-2]](p, "pg")
    else: fail("no checks for the capture %r" % nm)
    done()

def hashable(nm, p):
    for l in lines(p):
        if re.match(r"^  guard before ", l): continue
        if l.startswith("  Testcontainers' containers while verify ran"): continue
        l = re.sub(r"load1 [0-9.]+", "load1 <n>", l)
        # Spring MVC writes Accept-Patch (and Allow) in no fixed order from one JVM start to the next (measured: both orders in one run):
        # the raw header is hashed as its sorted set, which the line also carries
        l = re.sub(r"^(     header: (?:Accept-Patch|Allow): ).*( · set \{(.*)\})$", lambda m: m.group(1) + m.group(3) + m.group(2), l)
        print(l)

def values(readme, vals):
    t = open(readme, encoding="utf-8").read()
    m = re.search(r"<!-- values: begin -->\n```\n(.*?)\n```\n<!-- values: end -->", t, re.S)
    if not m:
        print("FAIL README.md has no values block"); [print("VALS| " + l) for l in vals.splitlines()]; sys.exit(1)
    if m.group(1).strip() != vals.strip():
        print("FAIL the values block differs from this run's:"); [print("VALS| " + l) for l in vals.splitlines()]; sys.exit(1)
    print("ok the values block = this run's")

def surefire(p):
    import xml.etree.ElementTree as ET
    r = ET.parse(p).getroot()
    print("  %s tests %s failures %s errors %s skipped %s" % (r.get("name").split(".")[-1], r.get("tests"), r.get("failures"), r.get("errors"), r.get("skipped")))

def mappings(stdin):
    d = json.load(stdin); hm = []
    for ctx in d["contexts"].values():
        for ds in ctx["mappings"].get("dispatcherServlets", {}).values():
            for m in ds:
                h = (m.get("details") or {}).get("handlerMethod")
                if h: hm.append((h["className"], h["name"], m["predicate"]))
    tb = [x for x in hm if x[0].startswith("com.tiffinbox.")]
    u04 = [x for x in tb if x[0].endswith("CustomerPauses")]; u05 = [x for x in tb if x[0].endswith("CustomerPatches")]
    print("  handler methods: %d · TiffinBox's (com.tiffinbox.*) %d · the set-up's %d · unit 04's (CustomerPauses) %d · unit 05's (CustomerPatches) %d · others %d" % (
        len(hm), len(tb), len(tb) - len(u04) - len(u05), len(u04), len(u05), len(hm) - len(tb)))
    for x in sorted(u05): print("    %s#%s %s" % (x[0].split(".")[-1], x[1], x[2]))

def features(stdin):
    on = off = None
    for l in stdin.read().splitlines():
        m = re.match(r"^JSON DeserializationFeature (enabled|disabled): \[(.*)\]$", l)
        if m:
            if m.group(1) == "enabled": on = [x.strip() for x in m.group(2).split(",")]
            else: off = [x.strip() for x in m.group(2).split(",")]
    if on is None or off is None: print("FAIL no JsonProbe feature lines"); sys.exit(1)
    print(" · ".join("%s %s" % (f, "enabled" if f in on else "disabled" if f in off else "absent") for f in ("FAIL_ON_NULL_FOR_PRIMITIVES", "ACCEPT_FLOAT_AS_INT", "FAIL_ON_UNKNOWN_PROPERTIES")))

if __name__ == "__main__":
    a = sys.argv[1:]
    try:
        if a[0] == "static": static(a[1], a[2])
        elif a[0] == "hook": print(HOOK)
        elif a[0] == "exq": print(EXQ)
        elif a[0] == "spoken": spoken(a[1], a[2], a[3])
        elif a[0] == "view" and a[1] == "matrix": view_matrix(a[2:])
        elif a[0] == "surefire": surefire(a[1])
        elif a[0] == "mappings": mappings(sys.stdin)
        elif a[0] == "features": features(sys.stdin)
        elif a[0] == "hashable": hashable(a[1], a[2])
        elif a[0] == "values": values(a[1], a[2])
        else: capture(a[0], a[1])
    except SystemExit:
        raise
    except Exception as e:
        print("FAIL the checker could not read its input (%s: %s)" % (e.__class__.__name__, str(e)[:160])); sys.exit(1)
