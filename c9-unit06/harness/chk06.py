"""Course 9 unit 06's checker (python3 -I -B harness/chk06.py MODE ...). Every number the README may say is re-derived here from a capture's
own lines (or a shipped file), never typed. Each listing line a check reads is parsed by a named pattern or skipped by a named rule; a line
it cannot parse is a FAIL line and exit 1, never a traceback. The request-block reader is U05's (chk05.py: parse, hdr, hset, reqs, errs -
copied from U05's harness, which copied U03's; two sub-lines added: "sent:" and "validators:"); the author rule is U03's author(),
copied byte for byte from ../c9-unit03/harness/chk03.py (static prints both slices' md5); the classes are U03's CLASSES.
Modes:
  static AFTER BEFORE      the carried prose slice, XFAM_S9S1's md5, the change's files, the stale sentences (R.250), the author rule's copy
  hook | exq | gloss       print the spoken lines (typed ONCE, here)
  spoken HOOK EXQ GLOSS    the spoken lines: byte-equal to their sources, words, digits, spellings, statuses, Hinglish, dur9
  <capture> FILE           one capture's checks; prints ok/FAIL lines and one VALUES line
  hashable NAME FILE       the capture with its load-dependent lines dropped, for receipts.md5
  values README VALS       README.md's values block = this run's VALUES lines
  surefire / mapjson       the receipts' small readers

THE AUTHOR RULE (U03's, S9.31): the author of a response is the part of the server that wrote its status line and body, read off the
request's own witnesses, in this order: (1) an ERROR-dispatch witness line -> Boot's /error; (2) no REQUEST-dispatch witness line -> Tomcat;
(3) the resolver's line names an advice -> TiffinBox's advice (TiffinBoxErrors) or Boot's problem-details handler (ProblemDetailsExceptionHandler);
(4) ResourceHttpRequestHandler -> the static handler; (5) post-handle yes and a 3xx with Location -> Spring MVC's redirect; (6) HttpOptionsHandler ->
Spring MVC's OPTIONS handler; (7) post-handle yes -> the route; anything else -> unattributed (a FAIL line).

THE MAPPINGS READER RULE (the boundary's census.sh, md5 printed by static): every dispatcherServlets entry with a handlerMethod is one handler
method - its class, its name, its methods (ANY when none), its patterns, produces, consumes; TiffinBox's are com.tiffinbox's."""
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
EV06 = os.path.join(C9R, "_briefs", "prompts-s1", "ev06-prompt.md")
CENSUS = os.path.join(C9R, "_research", "boundary-2026-11-24", "instruments", "census.sh")
J9 = os.path.join(os.path.expanduser("~"), "Desktop", "PromptVidya-Automation", "java9_series.py")
CU9 = os.path.join(os.path.expanduser("~"), "Desktop", "PromptVidya-Automation", "check_unit9.py")
HOOK = "You can change Priya on TiffinBox's public address, but you cannot read her back: a GET there is refused. So we review every route, one by one."
EXQ = "Your turn: this read asks for Priya on the public address and gets four oh four. Fix one word so it answers two hundred."
GLOSSQ = "what a route promises its callers: the path, the method, the shapes in and out"
GLOSS = "A contract: " + GLOSSQ + "."
ROUTE, ADVICE, BOOTPD, STATIC, REDIRECT, BOOTERR, TOMCAT = ("the route", "TiffinBox's advice", "Boot's problem-details handler", "the static handler",
                                                         "Spring MVC's redirect", "Boot's /error", "Tomcat")
OPTS = "Spring MVC's OPTIONS handler"
CLASSES = [ROUTE, ADVICE, BOOTPD, STATIC, REDIRECT, BOOTERR, TOMCAT, OPTS]
FEEDLABS = {"r10-feed"}   # the feed read by count: its own block (no witness lines - the answer stays open), never asked of the author rule

def lines(p):
    return open(p, encoding="utf-8", errors="replace").read().splitlines()

# ---- static ---------------------------------------------------------------------------------------------------------------------------
WEB = "tiffinbox-web/src/main/java/com/tiffinbox/web/"
NEW = [WEB + "CustomerReads.java", "tiffinbox-web/src/test/java/com/tiffinbox/web/CustomerReadsTest.java"]
CHANGED = ["README.md"]
STALE = [r"answers no read", r"cannot be read back from (?:it|the public)", r"no GET (?:on|at) the (?:new|public) address", r"a GET on the new address"]

def tree(d):
    out = {}
    for r, ds, fs in os.walk(d):
        ds.sort()
        for f in fs:
            p = os.path.join(r, f); out[os.path.relpath(p, d)] = hashlib.md5(open(p, "rb").read()).hexdigest()
    return out

def aslice(path):
    s = open(path, encoding="utf-8").read().split("\n"); out = []; on = False
    for l in s:
        if l.startswith("def author(r):"): on = True
        if on: out.append(l)
        if on and l.startswith('    return None, "handler %s, post-handle no, no resolver line"'): break
    return "\n".join(out)

def static(after, before):
    md = lambda x: hashlib.md5("\n".join(x).encode()).hexdigest()
    end = "# --- XFAM_S9S1 end ---"
    s9 = open(os.path.join(HERE, "s906.py"), encoding="utf-8").read().split("\n")
    s5 = open(os.path.join(UNIT, "..", "c9-unit05", "harness", "s905.py"), encoding="utf-8").read().split("\n")
    s4 = open(os.path.join(UNIT, "..", "c9-unit04", "harness", "s904.py"), encoding="utf-8").read().split("\n")
    if any(end not in s for s in (s9, s5, s4)): fail("the XFAM_S9S1 end marker is missing in s906.py, s905.py or s904.py"); done()
    a = lambda s: next(i for i, l in enumerate(s) if l.endswith('"""') and i > 0)
    sl = lambda s: s[a(s) + 1:s.index(end) + 1]
    need(sl(s9) == sl(s4), "s906.py's base + XFAM_S9S1 (after its docstring, through the block's end marker) = s904.py's, %d lines, md5 %s" % (len(sl(s4)), md(sl(s4))))
    need(sl(s9) == sl(s5), "= U05's s905.py's slice (copied from U05's harness)")
    t9 = "\n".join(s9); t4 = "\n".join(s4)
    rx = r"# --- XFAM_S9S1 begin ---\n.*?# --- XFAM_S9S1 end ---"
    b4 = re.search(rx, t4, re.S); b9 = re.search(rx, t9, re.S)
    need(b4 is not None and b9 is not None and b4.group(0) == b9.group(0), "the XFAM_S9S1 block, delimited, byte-equal to U04's")
    if b9:
        h = hashlib.md5(b9.group(0).encode()).hexdigest()
        print("  XFAM_S9S1_SLICE_MD5 = %s (computed the way ../c9-unit04/harness/chk04.py computes it)" % h); val("xfam_s9s1_md5", h[:8])
    need(not re.search(r"^XU0[12345] = ", t9, re.M), "XU01-XU05 are not carried")
    need(re.search(r"^XU06 = ", t9, re.M) is not None and re.search(r"^u04 = u06$", t9, re.M) is not None, "U06's own family (XU06) follows the carried slice; u04 = u06 (U01's binding)")
    # the author rule, copied byte for byte from U03's harness
    a3 = aslice(os.path.join(UNIT, "..", "c9-unit03", "harness", "chk03.py")); a6 = aslice(os.path.abspath(__file__))
    need(bool(a3) and a3 == a6, "author() = U03's chk03.py's, byte for byte (md5 %s, %d lines)" % (hashlib.md5(a3.encode()).hexdigest(), a3.count("\n") + 1))
    if os.path.exists(CENSUS): print("  the mappings reader rule: the boundary's census.sh (md5 %s), its python reader copied as mappings()" % hashlib.md5(open(CENSUS, "rb").read()).hexdigest())
    # the change: two new files, one changed, nothing else
    ta, tb_ = tree(after), tree(before)
    for f in NEW: need(f in ta and f not in tb_, "new in after/, absent from before: " + f)
    for f in CHANGED: need(f in ta and f in tb_ and ta[f] != tb_[f], "changed by this unit: " + f)
    other = sorted(f for f in set(ta) | set(tb_) if f not in NEW + CHANGED and ta.get(f) != tb_.get(f))
    rs = open(os.path.join(UNIT, "receipts.sh"), encoding="utf-8").read()
    need(re.search(r'^AD=\$\(diff -rq -x \.m2-demo -x target -x secrets -x \.harness after \.\./c9-tiffinbox 2>&1 \|\| true\)$', rs, re.M) is not None
         and not re.search(r'\[ -z "\$AD" \] \|\| die', rs) and re.search(r'\[ "\$AD1" = "\$AD" \] \|\| die "the anchor moved during the run"', rs) is not None,
         "receipts.sh: the anchor check at the start is a NOTE (no die on it); the end's check is the anchor moving DURING the run (the orchestrator's notes)")
    need(not other, "no other file differs between before and after/ (before %d files, after/ %d) %s" % (len(tb_), len(ta), other[:3]))
    val("files_new", len(NEW)); val("files_changed", len(CHANGED))
    cr = open(os.path.join(after, NEW[0]), encoding="utf-8").read()
    need(re.search(r'^@RestController\nfinal class CustomerReads \{', cr, re.M) is not None, "CustomerReads: @RestController, final, package-private")
    gm = re.findall(r"@GetMapping\(([^)]*)\)", cr)
    need(gm == ['"/api/v1/customers/{name}"'], "CustomerReads: one literal mapping, no version attribute (%s)" % gm)
    need(len(re.findall(r"^\s*@(Get|Post|Patch|Put|Delete)Mapping", cr, re.M)) == 1 and "repo.findByName(name).orElseThrow(() -> new CustomerNotFound(name))" in cr,
         "CustomerReads#one: one handler method, CustomerRepository.findByName, CustomerNotFound")
    need("Course 9, unit 06:" in cr, "CustomerReads: its Javadoc names Course 9, unit 06")
    ct = open(os.path.join(after, NEW[1]), encoding="utf-8").read()
    need(len(re.findall(r"^    @Test$", ct, re.M)) == 4, "CustomerReadsTest: 4 tests")
    need(not re.search(r'firstValue\("(?:ETag|Last-Modified|Cache-Control)"\)', ct), "CustomerReadsTest pins no missing validator (RED-C9-U06 #3: the absence is a fixes capture line, U20's)")
    rd = open(os.path.join(after, "README.md"), encoding="utf-8").read()
    need(re.search(r"^## Course 9 · unit 06 — API Design Review", rd, re.M) is not None, "README: the unit 06 card")
    need("*Course 9, unit 06: since unit 06 the public address also answers a read" in rd, "README: the header's unit 06 note")
    need("The old addresses keep their four-oh-five for a PATCH." in rd and "`PATCH` is not keyed" in rd, "README: unit 05's card stays true as written (the PATCH rows, not keyed)")
    for f in [ "README.md", NEW[0], WEB + "CustomerPatches.java"]:
        t = open(os.path.join(after, f), encoding="utf-8").read()
        hit = [x for x in STALE if re.search(x, t, re.I)]
        need(not hit, "the stale hunt (R.250): %s says nothing the read makes false (%s)" % (f, hit))
    if os.path.exists(J9):
        t = open(J9, encoding="utf-8").read(); m = re.search(r'"06": "([^"]+)"', t)
        need(m is not None and m.group(1) == "API Design Review", "java9_series.TITLES['06'] = %r" % (m.group(1) if m else None))
    done()

# ---- the spoken lines -----------------------------------------------------------------------------------------------------------------
STATUS = re.compile(r"(?<![\d.,:/-])\b(?:[1-5]\d\d)\b|\b(?:one|two|three|four|five)[\s-]hundred[\s-]and\b|\b(?:one|two|three|four|five)[\s-]hundred[\s-](?:one|two|three|four|five|six|seven|eight|nine|ten|eleven|twelve|thirteen|fourteen|fifteen)\b")
HING = re.compile(r"\b(?:bhai|yaar|dosto|kya|hai|nahi|nahin|matlab|karo|dekho|chalo|samjho|theek|accha|arre|haan|bilkul|zaroor|aur|toh|abhi|yeh|woh|kaise|kyun|bahut|thoda|sahi|galat)\b", re.I)
SPELL = re.compile(r"\b(?:API|URI|URL|RFC)s?\b")
def flat(p): return re.sub(r"\s+", " ", open(p, encoding="utf-8").read()) if os.path.exists(p) else ""
def spoken(hook, exq, gloss):
    import importlib.util
    spec = importlib.util.spec_from_file_location("dur9", os.path.join(HERE, "dur9.py")); m = importlib.util.module_from_spec(spec); spec.loader.exec_module(m)
    dur = getattr(m, "DUR", None)
    need(dur is not None, "dur9.py exposes its pattern (DUR)")
    sf = None
    if os.path.exists(CU9):
        try:
            sys.path.insert(0, os.path.dirname(CU9))
            sp = importlib.util.spec_from_file_location("cu9", CU9); cu = importlib.util.module_from_spec(sp); sp.loader.exec_module(cu); sf = cu.status_forms
            sys.path.pop(0)
        except Exception as e: print("  check_unit9.py's status_forms could not be loaded (%s): this checker's own status pattern only" % e.__class__.__name__)
    b = flat(S1B); e6 = flat(EV06)
    need(hook == HOOK and hook in b, "the hook candidate is BLUE C9-U06's (S1B AMENDMENT Q-c), byte for byte (whitespace of the brief's line breaks collapsed)")
    need(exq == EXQ and exq in e6, "the exercise's line is RED-C9-U06's correction (c), byte for byte (ev06-prompt.md's note)")
    need(gloss == GLOSS and '"' + GLOSSQ + '"' in b, "the gloss's quoted words are S1B :388's: %r" % gloss)
    hw, ew, gw = len(hook.split()), len(exq.split()), len(gloss.split())
    need(hw == 27 and hw <= 30, "the hook candidate: %d words (wc -w; BLUE's 27; <= 30)" % hw)
    need(ew == 24 and ew <= 25, "the exercise: %d words (wc -w; RED's 24; <= 25)" % ew)
    need(gw == 17, "the gloss: %d words (BLUE's 17)" % gw)
    for name, s in (("the hook", hook), ("the exercise", exq), ("the gloss", gloss)):
        nd = re.findall(r"\d", s); cf = sf(s) if sf else None
        print("  %s: digits %s · the status gate %s · check_unit9.status_forms %s · the spelling gate %s · Hinglish %s · dur9 %s" % (name, "".join(nd) or "0", "hit" if STATUS.search(s) else "0",
              cf if cf is not None else "-", SPELL.search(s).group(0) if SPELL.search(s) else "0", "hit" if HING.search(s) else "0", dur.search(s).group(0) if dur is not None and dur.search(s) else "0"))
        need(not STATUS.search(s) and not cf, "%s: the status gate 0" % name)
        need(not SPELL.search(s), "%s: the spelling gate 0 (API, URI, URL, RFC bare)" % name)
        need(not HING.search(s), "%s: the Hinglish list 0" % name)
        if dur is not None: need(not dur.search(s), "%s: dur9 0" % name)
        need(not nd, "%s: no digit" % name)
    need(" the contract" not in (hook + exq).lower(), "no spoken line says \"the contract\" (OpenAPI: The Contract's)")
    need(not re.search(r"\.sh\b", exq), "the exercise's line voices no file name (RED-C9-U06 #11)")
    print("  the hook candidate: %d words · the exercise: %d words · the gloss: %d words · GET written as the brief writes it (the spelling gate names neither GET nor JSON)" % (hw, ew, gw))
    val("hook_words", hw); val("exercise_words", ew); val("gloss_words", gw)
    done()

# ---- the request blocks (U05's reader, copied; two sub-lines added) ----------------------------------------------------------------------
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
                   "sl": [], "hd": [], "acc": [], "srv": [], "rby": [], "res": [], "cache": None, "log": [], "body": None, "key": None, "val": None}
            asks.append(cur); continue
        if l.startswith("     ") and cur is not None:
            t = l[5:]
            if t.startswith("status lines: "): cur["sl"] = [x.strip() for x in t[14:].split(" > ") if x.strip()]; continue
            if t.startswith("header: "): cur["hd"].append(t[8:]); continue
            if t.startswith("sent: key header "): cur["key"] = t[17:]; continue
            if t.startswith("validators: {") and t.endswith("}"): cur["val"] = t[13:-1]; continue
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
KEYF = "the key filter (IdempotencyKeyFilter)"
KEYROUTES = re.compile(r"^(?:POST /customers|POST /api/v1/customers/[^/]+/pauses)$")
def author6(r):
    """U03's author() first. Where it returns no class, ONE more rule (this unit's, named - U03's run never met U04's filter): a witness
    line with handler none, post-handle no, no resolver line, on a route in the key filter's table -> the key filter (IdempotencyKeyFilter),
    a servlet filter that answered before the DispatcherServlet chose a handler."""
    a, ev = author(r)
    if a is not None: return a, ev
    q = reqs(r)
    if q and q[0]["h"] == "none" and not q[0]["ph"] and not r["rby"] and KEYROUTES.match("%s %s" % (r["m"], r["p"].split("?")[0])):
        return KEYF, "handler none, post-handle no, no resolver line, %s %s is in the key filter's table" % (r["m"], r["p"].split("?")[0])
    return a, ev
def problem(r):
    try: return json.loads(r["body"]) if r["body"] and r["body"].startswith("{") else None
    except Exception: return None
def stm(r):
    q = reqs(r); return q[0]["stm"] if q else None
def head(heads, rx):
    for h in heads:
        m = re.search(rx, h)
        if m: return m
    return None
def load(p):
    ls = lines(p); asks, heads = parse(ls); return ls, {a["lab"]: a for a in asks}, heads, asks
def st(R, lab): return R[lab]["st"] if lab in R else None
def expect(R, lab, code, who=None, title=None):
    r = R.get(lab)
    if r is None: fail("%s: no request block" % lab); return None
    need(r["st"] == code, "%s: %s %s -> %s (want %s)" % (lab, r["m"], r["p"], r["st"], code))
    if who:
        a, ev = author6(r); need(a == who, "%s: the author is %s (%s)" % (lab, a, ev))
    if title is not None:
        pd = problem(r); need(pd is not None and pd.get("title") == title, "%s: title %r (%r)" % (lab, title, pd.get("title") if pd else None))
    return r
def nokey(asks, want):
    sent = sorted(a["lab"] for a in asks if a["key"] == "yes")
    need(all(a["key"] in ("yes", "no") for a in asks), "every request says whether it sent the key header")
    need(sent == sorted(want), "the key header sent by exactly %s (found %s)" % (sorted(want), sent))
    need(all(a["lab"].startswith("k-") for a in asks if a["key"] == "yes"), "every keyed request is labelled k-")
def classes(R):
    out = collections.Counter()
    for r in R.values():
        if r["lab"] in FEEDLABS: continue
        a, _ = author6(r); out[a or "unattributed"] += 1
    need(out.get("unattributed", 0) == 0, "every request has an author (U03's rule): unattributed %d" % out.get("unattributed", 0))
    return out
def sibling(p, frm, to):
    q = p.replace(frm, to); return q if os.path.exists(q) else None
def crossdb(p, h2name, pgname):
    q = sibling(p, ".r-%s." % h2name, ".r-%s." % pgname)
    if not q: fail("the PostgreSQL capture %s is not beside this one" % pgname); return
    _, Rp, _, _ = load(q); _, Rh, _, _ = load(p)
    need(set(Rp) == set(Rh), "the same requests on both databases (%d / %d)" % (len(Rp), len(Rh)))
    moved = [k for k in Rh if k in Rp and ((Rh[k]["st"], Rh[k]["ct"], Rh[k]["sz"], hset(Rh[k], "Allow"), hset(Rh[k], "Accept-Patch"), author6(Rh[k])[0])
                                         != (Rp[k]["st"], Rp[k]["ct"], Rp[k]["sz"], hset(Rp[k], "Allow"), hset(Rp[k], "Accept-Patch"), author6(Rp[k])[0]))]
    need(not moved, "PostgreSQL and H2 equal on status, type, size, Allow, Accept-Patch and author (moved: %s)" % moved)
    sm = [k for k in Rh if k in Rp and stm(Rh[k]) != stm(Rp[k])]
    print("  statement counts PostgreSQL vs H2: %s" % ("equal on every request" if not sm else "differ on " + ",".join(sm)))
    val("crossdb_moved", len(moved))

# ---- rows: the review's rows on before ----------------------------------------------------------------------------------------------
ROWS = {"R1": "NAMED", "R2": "HANDED", "R3": "HANDED", "R4": "HANDED", "R5": "FIXED-U04/HANDED", "R6": "NAMED", "R7": "FIXED-U04", "R8": "NAMED",
        "R9": "NAMED", "R10": "NAMED", "R11": "NAMED", "R12": "NAMED", "R13": "FIXED-U06"}
def c_rows(p, db):
    ls, R, H, asks = load(p)
    t = "\n".join(ls)
    nokey(asks, ["k-r1-pause", "k-r7-pause-key", "k-r7-pause-replay"])
    dbl = re.search(r"which database answered \(Flyway's line\): Database: <url> \((PostgreSQL|H2) ([0-9.]+)\)", t)
    sc2 = re.findall(r"\(([^()]*), the second client\)", t)
    want = "PostgreSQL" if db == "pg" else "H2"
    need(dbl is not None and dbl.group(1) == want and len(sc2) > 0 and all(x.endswith("psql in c9u06-pg") if db == "pg" else re.search(r"the harness's JdbcTemplate route /probe/\S+$", x) is not None for x in sc2),
         "which database answered: %s (Flyway's line %s), every second-client line names %s (%d lines)" % (want, dbl.group(1) + " " + dbl.group(2) if dbl else None, "psql in c9u06-pg" if db == "pg" else "the harness's JdbcTemplate route", len(sc2)))
    val("database", (dbl.group(1) + "_" + dbl.group(2)) if dbl else "-")
    # R13
    r = expect(R, "r13-get", "405", BOOTPD); need(r is not None and hset(r, "Allow") == "PATCH", "R13: GET on the public address 405, Allow {PATCH}")
    expect(R, "r13-head", "405")
    r = expect(R, "r13-put", "405", BOOTPD); need(r is not None and hset(r, "Allow") == "PATCH", "R13: PUT 405, Allow {PATCH}")
    r = expect(R, "r13-options", "200", OPTS); need(r is not None and hset(r, "Allow") == "OPTIONS,PATCH", "R13: OPTIONS Allow {OPTIONS,PATCH}")
    expect(R, "r13-nobody", "405", BOOTPD)
    expect(R, "r13-priya-patch", "200", ROUTE); expect(R, "r13-priya-get", "405", BOOTPD)
    pb = head(H, r"Priya before: (\S+ \S+ \S+ \S+ v\d+)"); pa = head(H, r"Priya after the PATCH: (\S+ \S+ \S+ \S+ v\d+)")
    need(pb is not None and pa is not None and pa.group(1).split()[1] == "2", "R13: Priya changed by the PATCH (%s -> %s), not readable back on the public address" % (pb.group(1) if pb else None, pa.group(1) if pa else None))
    # R1
    expect(R, "k-r1-pause", "201", ROUTE)
    expect(R, "r1-rename", "200", ROUTE); expect(R, "r1-old", "404", ADVICE); expect(R, "r1-new", "200", ROUTE)
    expect(R, "r1-loc-old", "404"); expect(R, "r1-loc-new", "200", ROUTE)
    m = re.search(r"the pause's Location path: /api/v1/customers/Sunil/pauses/(\d+) · id (\d+)", t)
    pa2 = re.search(r"pauses after the rename: Sunil (.*?) \(.*· Sunny (\S+(?: \S+)*?) \(id:customer_id", t)
    pb2 = re.search(r"Sunil's pauses now: (\S+(?: \S+)*?) \(id:customer_id", t)
    need(m is not None and pb2 is not None and pa2 is not None and pb2.group(1) == pa2.group(2) and m.group(1) in [x.split(":")[0] for x in pa2.group(2).split()],
         "R1: the pause row survives the rename (the pause table points at customer_id): Sunil's %s = Sunny's %s; its Location dies with the old name" % (pb2.group(1) if pb2 else None, pa2.group(2) if pa2 else None))
    # R2
    expect(R, "r2-404", "404", ADVICE); expect(R, "r2-422", "422", ROUTE); expect(R, "r2-400", "400", ROUTE)
    errb = [l for l in ("r2-404", "r2-422", "r2-400", "k-r7-pause-nokey") if l in R]
    typed = [l for l in errb if problem(R[l]) and "type" in problem(R[l])]
    need(typed == ["k-r7-pause-nokey"] and str(problem(R["k-r7-pause-nokey"]).get("type", "")).startswith("tag:"), "R2: of %d error bodies, only the key filter's carries a type (tag:) - %s" % (len(errb), typed))
    for l in ("r2-404", "r2-422", "r2-400"):
        pd = problem(R.get(l, {"body": None})); print("  R2 %s: type %s · title %r · instance %s" % (l, pd.get("type", "absent (about:blank)") if pd else "-", pd.get("title") if pd else None, "= the path" if pd and pd.get("instance") == R[l]["p"] else (pd.get("instance") if pd else "-")))
    need("When \"about:blank\" is used, the title SHOULD be the same as the" in t, "R2: RFC 9457 section 4.2.1's SHOULD, read off the filed copy")
    val("typed_bodies", "%d/%d" % (len(typed), len(errb)))
    # R3
    a, b = expect(R, "r3-list", "200", ROUTE), expect(R, "r3-page", "200", ROUTE)
    need(a is not None and b is not None and a["body"] == b["body"] and "byte-identical" in t, "R3: the paging query changes nothing (the same bytes)")
    n = len(json.loads(a["body"])) if a and a["body"] and a["body"].startswith("[") else -1
    c = re.search(r"rows by the second client: (\d+) ", t)
    need(c is not None and n == int(c.group(1)), "R3: the body's %d customers = the second client's %s rows" % (n, c.group(1) if c else None))
    need(a is not None and hset(a, "Link") == "" and a["val"] == "", "R3: no Link, no total header")
    val("list_rows", n)
    # R4
    for l in ("r3-list", "r4-ravi", "r5-old", "r13-priya-patch"): need(R.get(l) and R[l]["val"] == "", "R4: %s carries no ETag, no Last-Modified, no Cache-Control (validators {%s})" % (l, R[l]["val"] if l in R else None))
    expect(R, "r4-inm-star", "200"); expect(R, "r4-inm-made", "200")
    r = expect(R, "r4-css", "200", STATIC); need(r is not None and "Last-Modified" in (r["val"] or "") and "Cache-Control" in (r["val"] or ""), "R4: the stylesheet beside carries a validator and a lifetime {%s}" % (r["val"] if r else None))
    # R5
    expect(R, "r5-old", "200", ROUTE)
    # R6
    for l in ("r6-search", "r6-dishes", "r6-leaderboard", "r6-menu", "r6-bycustomer"): expect(R, l, "404")
    # R10
    f = R.get("r10-feed"); need(f is not None and f["st"] == "200" and (f["body"] or "").startswith(":listening"), "R10: the feed answers 200 and its first line by count")
    lb = re.search(r"listeners before: (\d+)", t); la = re.search(r"listeners after the client left: (\d+) · again: (\d+)", t); ln = re.search(r"listeners after the next stored customer \(R10's second half\): (\d+)", t); l2 = re.search(r"listeners after a second stored customer: (\d+)", t)
    need(lb is not None and la is not None and ln is not None and l2 is not None and lb.group(1) == "0" and la.group(1) == la.group(2) == "1" and ln.group(1) == "1" and l2.group(1) == "0",
         "R10: the feed's listeners 0 before, 1 after the client left (and again), 1 after the next stored customer, 0 after a second (%s)" % ([x.groups() for x in (lb, la, ln, l2) if x],))
    sc = re.search(r"a second stored customer \(POST /customers Lata.*\): (\d{3}) · the feed's access-log line, waited for by count: GET (/customers/feed\S*) 500 ", t)
    need(sc is not None and sc.group(1) == "201", "R10: the second stored customer 201, and then the abandoned feed read's 500 in the access log (the census's fifteenth code)")
    val("listeners", "%s->%s->%s->%s" % (lb.group(1) if lb else "-", la.group(1) if la else "-", ln.group(1) if ln else "-", l2.group(1) if l2 else "-"))
    # R7
    expect(R, "r7-create", "201", ROUTE); expect(R, "r7-create-again", "409")
    r = expect(R, "k-r7-pause-nokey", "400", KEYF); expect(R, "k-r7-pause-key", "201", ROUTE); expect(R, "k-r7-pause-replay", "201", KEYF)
    need("the replay's body: byte-identical" in t, "R7: the replay's body byte-identical")
    k0 = re.search(r"key table rows before: (\d+)", t); k1 = re.search(r"key table rows after the keyless ones: (\d+)", t); k2 = re.search(r"Ravi's pauses: .*? key table rows: (\d+)", t)
    need(k0 is not None and k1 is not None and k0.group(1) == k1.group(1), "R7: the keyless requests stored no key row (%s -> %s)" % (k0.group(1) if k0 else None, k1.group(1) if k1 else None))
    val("keyrows", "%s->%s->%s" % (k0.group(1) if k0 else "-", k1.group(1) if k1 else "-", k2.group(1) if k2 else "-"))
    # R8, R9, R11, R12
    expect(R, "r8-trace", "405", BOOTERR)
    r = expect(R, "r9-csv", "406", BOOTPD); need(r is not None and reqs(r) and not reqs(r)[0]["ph"] and reqs(r)[0]["h"] != "-", "R9: the 406 after the handler ran (handler %s, post-handle no, statements %s)" % (reqs(r)[0]["h"] if r and reqs(r) else None, stm(r) if r else None))
    expect(R, "r9-json", "200", ROUTE)
    r1, r2 = expect(R, "r11-put", "405", BOOTPD), expect(R, "r11-options", "200", OPTS)
    need(r1 is not None and r2 is not None and hset(r1, "Allow") == "GET,POST" and hset(r2, "Allow") == "GET,HEAD,OPTIONS,POST", "R11: the 405's Allow {%s} narrower than OPTIONS' {%s}" % (hset(r1, "Allow") if r1 else None, hset(r2, "Allow") if r2 else None))
    expect(R, "r12-kitchen", "200", ROUTE); r = expect(R, "r12-shutdown", "405"); need(r is not None and hset(r, "Allow") == "POST", "R12: GET /shutdown 405 Allow {POST}")
    a5 = re.search(r"status 500: (\d+)", t); print("  the access log's 500s in this JVM: %s" % (a5.group(0) if a5 else "-"))
    cl = classes(R)
    codes = sorted({a["st"] for a in asks}); val("codes", ",".join(codes))
    val("authors", ",".join("%s:%d" % (k.replace(" ", "_").replace("'", ""), v) for k, v in sorted(cl.items())))
    cc = collections.Counter(ROWS.values())
    fx = sum(1 for v in ROWS.values() if v.startswith("FIXED")); hd = sum(1 for v in ROWS.values() if "HANDED" in v); nm = cc["NAMED"]
    print("  the rows: %d · FIXED %d (R5's address and R7 at U04, R13 by U06) · HANDED %d (R2, R3, R4, R5's strategy) · NAMED %d - R5 counted in both halves" % (len(ROWS), fx, hd, nm))
    val("rows", len(ROWS)); val("fixed", fx); val("handed", hd); val("named", nm)
    val("requests", len(asks))
    if db == "h2": crossdb(p, "rows", "rowspg")

# ---- fixes: the same requests on after/ ------------------------------------------------------------------------------------------------
def c_fixes(p, db):
    ls, R, H, asks = load(p); t = "\n".join(ls)
    nokey(asks, [])
    r = expect(R, "f-get", "200", ROUTE)
    need(r is not None and reqs(r) and reqs(r)[0]["h"] == "CustomerReads#one", "the public read is CustomerReads#one (handler %s)" % (reqs(r)[0]["h"] if r and reqs(r) else None))
    need(r is not None and stm(r) == 1 and stm(R.get("f-get2", r)) == 0, "the public read: cold 1 statement, warm 0 (%s / %s)" % (stm(r) if r else None, stm(R["f-get2"]) if "f-get2" in R else None))
    need(r is not None and r["val"] == "", "the public read carries no ETag, no Last-Modified, no Cache-Control (R4: HANDED to ETags and Conditional GET)")
    o = expect(R, "f-old", "200", ROUTE); need("the public read's body and the old address's: byte-identical" in t, "the public read answers the old address's bytes")
    need(o is not None and stm(o) == 0, "the old address after the public read: 0 statements (one shared customer entry - the order-dependent count)")
    h = expect(R, "f-head", "200"); need(h is not None and hdr(h, "Content-Length") == str(r["sz"] if r else -1), "HEAD: 200, Content-Length %s = the GET's body" % (hdr(h, "Content-Length") if h else None))
    x = expect(R, "f-put", "405", BOOTPD); need(x is not None and hset(x, "Allow") == "GET,PATCH", "PUT on the address: 405, Allow {GET,PATCH} (R11's gap, now here too: NAMED)")
    x = expect(R, "f-options", "200", OPTS); need(x is not None and hset(x, "Allow") == "GET,HEAD,OPTIONS,PATCH" and hset(x, "Accept-Patch") == "application/json-patch+json,application/merge-patch+json", "OPTIONS: Allow {GET,HEAD,OPTIONS,PATCH}, Accept-Patch both")
    expect(R, "f-nobody", "404", ADVICE, "Customer not found")
    expect(R, "f-inm", "200")
    expect(R, "f-priya-patch", "200", ROUTE); g = expect(R, "f-priya-get", "200", ROUTE)
    need(g is not None and '"mealsPerDay":2' in (g["body"] or ""), "Priya, changed by the PATCH, is read back on the public address")
    w = expect(R, "f-warm", "200"); need(w is not None and w["cache"] is not None and "Sunil" in w["cache"][3], "the rename: Sunil's customer entry warm first")
    rn = expect(R, "f-rename", "200", ROUTE); need(rn is not None and rn["cache"] is not None and "Sunil" not in rn["cache"][3], "the rename evicts Sunil's entry (%s)" % (rn["cache"][3] if rn and rn["cache"] else None))
    expect(R, "f-pub-old", "404", ADVICE); expect(R, "f-pub-new", "200", ROUTE); expect(R, "f-old-old", "404", ADVICE); expect(R, "f-old-new", "200", ROUTE)
    need(head(H, r"key table rows: 0 ") is not None, "the key table: 0 rows (no request of this capture sent a key)")
    # the planted no-evict copy (the detector, R.276 + R.374)
    expect(R, "n-rename", "200", ROUTE); n = expect(R, "n-pub-old", "200")
    need(n is not None and stm(n) == 0, "the planted no-evict copy: the old public address 200 from Caffeine (statements %s)" % (stm(n) if n else None))
    pubold404 = lambda RR: st(RR, "f-pub-old" if "f-pub-old" in RR else "n-pub-old") == "404"
    need(not pubold404({"n-pub-old": R["n-pub-old"]}) if "n-pub-old" in R else False, "the cannot-fail detector: the check 'the old public address answered 404 after the rename' FAILS on the planted no-evict copy")
    rp = sibling(p, ".r-fixes", ".r-rows")
    if rp:
        _, Rr, _, _ = load(rp)
        need(st(Rr, "r13-get") == "405" and st(Rr, "r13-get") != "200", "the cannot-fail detector: the check 'the public GET answered 200' FAILS on before's capture (%s: %s)" % (os.path.basename(rp), st(Rr, "r13-get")))
        pairs = [("r13-get", "f-get"), ("r13-head", "f-head"), ("r13-put", "f-put"), ("r13-options", "f-options"), ("r13-nobody", "f-nobody"), ("r13-priya-get", "f-priya-get"), ("r5-old", "f-old")]
        for b_, a_ in pairs:
            if b_ in Rr and a_ in R: print("  PAIR %s -> %s: %s %s {%s} -> %s %s {%s}" % (Rr[b_]["m"] + " " + Rr[b_]["p"], a_, Rr[b_]["st"], author6(Rr[b_])[0], hset(Rr[b_], "Allow"), R[a_]["st"], author6(R[a_])[0], hset(R[a_], "Allow")))
        need(Rr.get("r5-old") is not None and R.get("f-old") is not None and Rr["r5-old"]["body"] == R["f-old"]["body"] and Rr["r5-old"]["st"] == R["f-old"]["st"], "the old GET /customers/Ravi: the same status and body on before and after/ (S9.2)")
    else: fail("before's rows capture is not beside this one")
    val("public", "%s->%s" % (st(Rr, "r13-get") if rp else "-", st(R, "f-get"))); val("allow", hset(R["f-options"], "Allow").replace(",", "+") if "f-options" in R else "-")
    val("rename", "/".join(st(R, l) or "-" for l in ("f-rename", "f-pub-old", "f-pub-new", "f-old-old", "f-old-new"))); val("noevict_old", st(R, "n-pub-old"))
    if db == "h2": crossdb(p, "fixes", "fixespg")

# ---- mappings ------------------------------------------------------------------------------------------------------------------------
MAPL = re.compile(r"^  ([A-Za-z]+)#(\w+) \| (\S+) \| (\S+) \| (\S+) \| (\S+)$")
def c_mappings(p):
    ls = lines(p); t = "\n".join(ls)
    h = re.search(r"^  handler methods: (\d+) in all, (\d+) TiffinBox's \(com\.tiffinbox\), (\d+) others$", t, re.M)
    rows = []
    for l in ls:
        if l.startswith("  ") and " | " in l and "#" in l.split(" | ")[0]:
            m = MAPL.match(l)
            if not m: fail("a mapping line this checker cannot parse: %r" % l[:120]); continue
            rows.append(m.groups())
    if not h: fail("the handler-method total line"); done()
    total, tb, oth = int(h.group(1)), int(h.group(2)), int(h.group(3))
    need(len(rows) == tb, "one mapping line per TiffinBox handler method (%d lines, %d counted)" % (len(rows), tb))
    need(("CustomerReads", "one", "GET", "/api/v1/customers/{name}", "-", "-") in rows, "CustomerReads#one GET /api/v1/customers/{name} is mapped (unit 06's)")
    C = {}
    for l in ls:
        m = re.match(r"^  commit (\w+) \(.*\): mapping annotations (\d+) · dev classes (\d+) · dev mappings (\d+) · default run (\d+)$", l)
        if m: C[m.group(1)] = tuple(int(x) for x in m.groups()[1:])
    a = re.search(r"^  after/ \(this unit's tree\): mapping annotations (\d+) · dev classes (\d+) · dev mappings (\d+) · default run (\d+)$", t, re.M)
    need(set(C) == {"80f7839", "a0a0151", "df4ff12"} and a is not None, "the partition: three commits and after/ read")
    if a and len(C) == 3:
        s0, s4, s5, s6 = C["80f7839"][3], C["a0a0151"][3], C["df4ff12"][3], int(a.group(4))
        need(s6 == tb, "after/'s default-run mappings by source (%d) = the flag start's TiffinBox rows (%d)" % (s6, tb))
        need(s0 + (s4 - s0) + (s5 - s4) + (s6 - s5) == tb and s6 - s5 == 1, "the partition: the set-up's %d + U04's %d + U05's %d + U06's %d = %d" % (s0, s4 - s0, s5 - s4, s6 - s5, tb))
        need(int(a.group(2)) == 9 and int(a.group(3)) == 5 and all(C[c][1:3] == (9, 5) for c in C), "the dev profile: nine classes, five mappings, at every commit")
        val("handlers", tb); val("handlers_setup", s0); val("handlers_u04", s4 - s0); val("handlers_u05", s5 - s4); val("handlers_u06", s6 - s5); val("handlers_all", total); val("others", oth)
        val("dev", "%d/%d" % (int(a.group(2)), int(a.group(3))))
    by = collections.Counter(r[0] for r in rows)
    print("  TiffinBox's by class: %s" % " · ".join("%s %d" % kv for kv in sorted(by.items(), key=lambda x: (-x[1], x[0]))))
    wr = [r for r in rows if r[2] not in ("GET", "HEAD", "OPTIONS")]
    keyed = {"/customers", "/api/v1/customers/{name}/pauses"}
    print("  the write routes (method not GET/HEAD/OPTIONS), as data for unit 26 (C9-13), by the mappings and the key filter's table alone (who may call them is Course 10's):")
    def keyword(r):
        if r[2] != "POST" or r[3] not in keyed: return "not keyed"
        if r[3] == "/api/v1/customers/{name}/pauses": return "the key REQUIRED (the filter's table)"
        if r[5] == "application/x-www-form-urlencoded": return "the form: the filter lets it by (its source)"
        return "the key taken when sent (the filter's table)"
    for r in sorted(wr, key=lambda x: (x[3], x[0])):
        print("    %s %s · %s#%s · consumes %s · %s · %s" % (r[2], r[3], r[0], r[1], r[5], "public" if r[3].startswith("/api/v1/") else "old", keyword(r)))
    need(len(wr) == 7 and not any(r[0] == "CustomerReads" for r in wr), "the write routes: %d, the fix adds none" % len(wr))
    pub = [r for r in rows if r[3].startswith("/api/v1/")]
    val("writes", len(wr)); val("public", len(pub))
    ua = re.search(r"the unanchored count beside \(the finding\): after/ (\d+)", t)
    need(ua is not None and a is not None and int(ua.group(1)) == int(a.group(1)) + 1, "the unanchored pattern counts one line more (a Javadoc's {@code @GetMapping}): %s vs %s" % (ua.group(1) if ua else None, a.group(1) if a else None))
    need(re.search(r"^  IdempotencyKey", t, re.M) is not None, "the key filter's table, read off the source")

# ---- moved ---------------------------------------------------------------------------------------------------------------------------
MVL = re.compile(r"^  (before|after) \| ([A-Z]+ \S+(?: \[[\w-]+\])?) -> (\d{3}) (\S*) (\d+) · Allow \{([^}]*)\} · Accept-Patch \{([^}]*)\} · body (\S+)$")
NEWADDR = ["GET /api/v1/customers/Ravi", "HEAD /api/v1/customers/Ravi", "PUT /api/v1/customers/Ravi", "DELETE /api/v1/customers/Ravi", "OPTIONS /api/v1/customers/Ravi", "GET /api/v1/customers/Nobody"]
def c_moved(p):
    ls = lines(p); M = {}
    for l in ls:
        m = MVL.match(l)
        if m: M[(m.group(1), m.group(2))] = m.groups()[2:]
        elif l.startswith("  before |") or l.startswith("  after |"): fail("a moved line this checker cannot parse: %r" % l[:120])
    qs = sorted({k[1] for k in M})
    need(len(qs) == 36 + 6 + 8 and all(("before", q) in M and ("after", q) in M for q in qs), "every request asked on both trees (%d)" % len(qs))
    moved = [q for q in qs if M.get(("before", q)) != M.get(("after", q))]
    need(sorted(moved) == sorted(NEWADDR), "moved: exactly the new address's own lines (S9.37, the one compatible move): %s" % moved)
    for q in moved: print("  MOVED (compatible, named in this unit) %s: before %s -> after %s" % (q, " ".join(M[("before", q)]), " ".join(M[("after", q)])))
    a = M.get(("after", "PATCH /customers")); need(a is not None and a[0] == "405" and a[3] == "GET,POST", "C9-10a: a PATCH to /customers answers 405, Allow the set {GET, POST}, on after/")
    pt = [q for q in qs if q.startswith("PATCH /api/")]
    need(len(pt) == 8 and not any(q in moved for q in pt), "U05's PATCH answers on the public address: %d, all unmoved (%s)" % (len(pt), "/".join(M[("after", q)][0] for q in pt)))
    g = M.get(("after", "GET /api/v1/customers/Ravi")); b = M.get(("before", "GET /api/v1/customers/Ravi"))
    need(b is not None and g is not None and b[0] == "405" and g[0] == "200" and g[3] == "", "the move: GET /api/v1/customers/Ravi 405 -> 200, no Allow on the 200")
    o = M.get(("after", "OPTIONS /api/v1/customers/Ravi")); need(o is not None and o[3] == "GET,HEAD,OPTIONS,PATCH", "the move: OPTIONS on the address names GET and HEAD beside PATCH")
    val("asked", len(qs)); val("moved", len(moved)); val("unmoved", len(qs) - len(moved)); val("patch_customers", "405:" + (a[3].replace(",", "+") if a else "-"))

def c_inert(p):
    ls = lines(p); t = "\n".join(ls)
    S = re.search(r"the expected seven ([0-9a-f]{32}), the old surface ([0-9a-f]{32})", t)
    if not S: fail("the expected hashes"); return
    for side in ("before", "after"):
        m = re.search(r"^  %s: the seven ([0-9a-f]{32}) .*· the old surface ([0-9a-f]{32})" % side, t, re.M)
        need(m is not None and m.group(1) == S.group(1), "%s: the seven = %s" % (side, S.group(1)[:8]))
        need(m is not None and m.group(2) == S.group(2), "%s: the old surface = %s (U05's)" % (side, S.group(2)[:8]))
    need(any("planted: the seven" in l and "unchanged: yes" in l and "moved: yes" in l for l in ls), "the ETag plant: the seven unchanged, the old surface moved")
    need(any("planted:" in l and " 0 (reader exit 3)" in l for l in ls), "the ETag plant: the feed answers nothing (the reader's exit 3 at its alarm, 0 bytes)")
    val("seven", S.group(1)[:8]); val("surface", S.group(2)[:8])

TESTS_RX = r"^  (\w+) tests (\d+) failures (\d+) errors (\d+) skipped (\d+)$"
IT = {"CustomerEntityRepositoryIT": (21280, 5432), "CustomerAggregatesIT": (21281, 5432), "RedisDatastoreIT": (21282, 6379), "MongoDatastoreIT": (21283, 27017), "ElasticsearchIT": (21284, 9200)}
def u05_tests():
    t = open(os.path.join(UNIT, "..", "c9-unit05", "README.md"), encoding="utf-8").read()
    m = re.search(r"^tests: tests=(\d+) .*its=(\d+) ", t, re.M); return (int(m.group(1)), int(m.group(2))) if m else (None, None)
def c_tests(p):
    ls = lines(p); sec = None; per = {"unit": {}, "it": {}}
    for l in ls:
        if l.startswith("== Surefire's XML"): sec = "unit"; continue
        if l.startswith("== Failsafe's XML"): sec = "it"; continue
        if l.startswith("== "): sec = None; continue
        m = re.match(TESTS_RX, l)
        if m and sec:
            per[sec][m.group(1)] = int(m.group(2)); need(m.group(3) == m.group(4) == "0", "%s %s: failures and errors 0" % (sec, m.group(1)))
    u5, i5 = u05_tests()
    tot = sum(per["unit"].values()); k = per["unit"].get("CustomerReadsTest", 0)
    need(u5 is not None and tot == u5 + k and k > 0, "the test phase: %d = U05's %s (its README values block) + %d (CustomerReadsTest)" % (tot, u5, k))
    need(sum(per["it"].values()) == i5 == 14 and len(per["it"]) == 5, "the ITs: %d in 5 classes (U05's %s)" % (sum(per["it"].values()), i5))
    val("tests", tot); val("tests_u05", u5); val("tests_k", k); val("its", sum(per["it"].values()))
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
    need(any(l == "  the jars whose names moved: 0" for l in ls), "no jar's name moved (no dependency moves)")
    al = [l for l in ls if l.startswith("  after: ")]
    for j in ("tomcat-embed-core-11.0.29.jar", "spring-core-7.0.11.jar", "spring-boot-4.1.3.jar", "postgresql-42.7.14.jar", "parsson-1.1.9.jar"):
        need(al and j in al[0], "after/'s BOOT-INF/lib holds " + j)

def c_exercise(p):
    ls = lines(p)
    def blk(db, tag, sh):
        out = []; on = False
        for l in ls:
            if l.startswith("== the exercise, %s, %s, %s " % (db, tag, sh)): on = True; continue
            if on and l.startswith("=="): break
            if on: out.append(l[2:])
        return out
    want = {"broken": ("FAIL", "404"), "solved": ("PASS", "200"), "oldaddr": ("FAIL", "200"), "method": ("FAIL", None), "media": ("FAIL", "406"), "other": ("FAIL", "200"), "segment": ("FAIL", None)}
    for db in ("pg", "h2"):
        for v, (verdict, code) in want.items():
            for sh in ("bash", "zsh"):
                b = blk(db, v, sh)
                need(any(x.startswith(verdict + ": status " + (code or "")) for x in b), "%s %s (%s): %s%s" % (db, v, sh, verdict, " with status " + code if code else ""))
                need(("check exit 0" if verdict == "PASS" else "check exit 1") in b, "%s %s (%s): check.sh's exit" % (db, v, sh))
            need(blk(db, v, "bash") == blk(db, v, "zsh"), "%s %s: bash and zsh -f print the same" % (db, v))
            need(blk("pg", v, "bash") == blk("h2", v, "bash") if db == "h2" else True, "%s: PostgreSQL and H2 print the same" % v)
    ch = re.findall(r"^== the exercise, h2, (\w+), bash .*read\.sh vs shipped: (\d+) changed lines", "\n".join(ls), re.M)
    need(dict(ch).get("broken") == "0" and all(dict(ch).get(v) == "2" for v in want if v != "broken"), "the tries: read.sh as shipped, then SOLUTION's line (or a refused change of it) in place of its one curl line (%s)" % ch)
    rd = [l[len("  README: "):] for l in ls if l.startswith("  README: ")]; so = [l[len("  SOLUTION: "):] for l in ls if l.startswith("  SOLUTION: ")]
    need([x for x in blk("h2", "broken", "bash") if not x.startswith("check exit")] == rd, "exercise/README.md's What it prints = the broken run's lines")
    need([x for x in blk("h2", "solved", "bash") if not x.startswith("check exit")] == so, "SOLUTION.md's What it prints = the solved run's lines")
    for v in ("method", "segment"):
        x = [l for l in blk("h2", v, "bash") if l.startswith("FAIL: status ")]; print("  %s: %s" % (v, x[0] if x else "-"))
    val("exercise", "broken-404-FAIL,solved-200-PASS,refused-5-FAIL,pg+h2")

CAPS = {"tests": c_tests, "mappings": c_mappings, "moved": c_moved, "inert": c_inert, "exercise": c_exercise}
PER = {"rows": c_rows, "fixes": c_fixes}
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
        # Spring MVC writes Accept-Patch (and Allow) in no fixed order from one JVM start to the next (U05's finding): the raw header is
        # hashed as its sorted set, which the line also carries
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
    m = json.load(stdin); rows = []
    for ctx in m["contexts"].values():
        for ds in ctx["mappings"].get("dispatcherServlets", {}).values():
            for e in ds:
                d = e.get("details") or {}
                hm = d.get("handlerMethod")
                if not hm: continue
                c = d.get("requestMappingConditions", {})
                rows.append((hm["className"], hm["name"], ",".join(c.get("methods", [])) or "ANY", ",".join(c.get("patterns", [])),
                             ",".join(x["mediaType"] for x in c.get("produces", [])) or "-", ",".join(x["mediaType"] for x in c.get("consumes", [])) or "-"))
    tb = [r for r in rows if r[0].startswith("com.tiffinbox")]
    print("  handler methods: %d in all, %d TiffinBox's (com.tiffinbox), %d others" % (len(rows), len(tb), len(rows) - len(tb)))
    for r in sorted(tb): print("  " + " | ".join([r[0].rsplit('.', 1)[1] + "#" + r[1]] + list(r[2:])))
    print("  the others: %s" % " · ".join(sorted("%s %s" % (r[2], r[3]) for r in rows if not r[0].startswith("com.tiffinbox"))))

if __name__ == "__main__":
    a = sys.argv[1:]
    try:
        if a[0] == "static": static(a[1], a[2])
        elif a[0] == "hook": print(HOOK)
        elif a[0] == "exq": print(EXQ)
        elif a[0] == "gloss": print(GLOSS)
        elif a[0] == "spoken": spoken(a[1], a[2], a[3])
        elif a[0] == "surefire": surefire(a[1])
        elif a[0] == "mapjson": mappings(sys.stdin)
        elif a[0] == "hashable": hashable(a[1], a[2])
        elif a[0] == "values": values(a[1], a[2])
        else: capture(a[0], a[1])
    except SystemExit:
        raise
    except Exception as e:
        print("FAIL the checker could not read its input (%s: %s)" % (e.__class__.__name__, str(e)[:160])); sys.exit(1)
