"""Course 9 unit 08's checker (python3 -I -B harness/chk08.py MODE ...). Every number the README may say is re-derived here from a capture's
own lines (or a shipped file), never typed. Each listing line a check reads is parsed by a named pattern or skipped by a named rule; a line
it cannot parse is a FAIL line and exit 1, never a traceback. The request-block reader, the small readers and the spec-vs-wire re-derivation
are U07's (chk07.py - copied from U07's harness, c9-unit07/harness); the page's checks (info, redirect, sealed, ops, tryit, versions) are
this unit's.
Modes:
  static AFTER BEFORE      the carried prose slice, XFAM_S9S1's md5, the change's files (one new in main, the committed file, the README),
                           the bean's shape, the pom and the test untouched, the file's two-line diff, the stale sentences (R.250/R.453)
  hook | exq               print the spoken lines (typed ONCE, here; asserted against the brief's bytes by spoken)
  gloss README             the one new gloss line (Swagger UI), U06's called back, none re-glossed (flag 16)
  spoken HOOK EXQ          the spoken lines: byte-equal to S2B :179 / :187, words, digits, spellings, statuses, Hinglish, dur9
  infodiff BEFORE AFTER    the two documents with info and servers removed: md5s, member order, what differs (exit 1 if more than info moved)
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
HOOK = "Swagger UI loads in a browser that can reach nothing but TiffinBox, and the page asks for nothing else."
EXQ = "Your turn: open Swagger UI in the sealed browser and find the one request that answers Ravi."
GLOSS = "Swagger UI: a page drawn from the document."
BRIEFQ = "a page drawn from the document"
U06GLOSS = "A contract: what a route promises its callers: the path, the method, the shapes in and out."
FOUR = ["mealType", "mealsPerDay", "name", "pricePerMeal"]
INFO_A = {"title": "TiffinBox", "version": "1.0"}
INFO_B = {"title": "OpenAPI definition", "version": "v0"}

def lines(p):
    return open(p, encoding="utf-8", errors="replace").read().splitlines()
def fixed(d):
    b = io.StringIO(); json.dump(d, b, indent=2, ensure_ascii=False); b.write("\n"); return b.getvalue()

# ---- static ---------------------------------------------------------------------------------------------------------------------------
BEAN = "tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxOpenApi.java"
SPEC = "tiffinbox-web/src/test/resources/openapi/tiffinbox.json"
TEST = "tiffinbox-web/src/test/java/com/tiffinbox/web/OpenApiSpecTest.java"
NEW = [BEAN]
CHANGED = [SPEC, "README.md"]
STALE = [r"\"OpenAPI definition\"[^.\n]{0,40}(?:is|as) (?:its|the) title", r"no `OpenAPI` info bean", r"title is \"OpenAPI definition\"", r"version is \"v0\"",
         r"`BOOT-INF/lib` (?:holds |is )?146(?! →)"]

def tree(d):
    out = {}
    for r, ds, fs in os.walk(d):
        ds.sort()
        for f in fs:
            p = os.path.join(r, f); out[os.path.relpath(p, d)] = hashlib.md5(open(p, "rb").read()).hexdigest()
    return out

def card(t):
    m = re.search(r"^## Course 9 · unit 08 — .*?(?=^## |^---$|\Z)", t, re.M | re.S); return m.group(0) if m else ""

def static(after, before):
    md = lambda x: hashlib.md5("\n".join(x).encode()).hexdigest()
    end = "# --- XFAM_S9S1 end ---"
    s9 = open(os.path.join(HERE, "s908.py"), encoding="utf-8").read().split("\n")
    s7 = open(os.path.join(UNIT, "..", "c9-unit07", "harness", "s907.py"), encoding="utf-8").read().split("\n")
    s4 = open(os.path.join(UNIT, "..", "c9-unit04", "harness", "s904.py"), encoding="utf-8").read().split("\n")
    if any(end not in s for s in (s9, s7, s4)): fail("the XFAM_S9S1 end marker is missing in s908.py, s907.py or s904.py"); done()
    a = lambda s: next(i for i, l in enumerate(s) if l.endswith('"""') and i > 0)
    sl = lambda s: s[a(s) + 1:s.index(end) + 1]
    need(sl(s9) == sl(s4), "s908.py's base + XFAM_S9S1 (after its docstring, through the block's end marker) = s904.py's, %d lines, md5 %s" % (len(sl(s4)), md(sl(s4))))
    need(sl(s9) == sl(s7), "= U07's s907.py's slice (copied from U07's harness)")
    t9 = "\n".join(s9); t4 = "\n".join(s4)
    rx = r"# --- XFAM_S9S1 begin ---\n.*?# --- XFAM_S9S1 end ---"
    b4 = re.search(rx, t4, re.S); b9 = re.search(rx, t9, re.S)
    need(b4 is not None and b9 is not None and b4.group(0) == b9.group(0), "the XFAM_S9S1 block, delimited, byte-equal to U04's")
    if b9:
        h = hashlib.md5(b9.group(0).encode()).hexdigest()
        print("  XFAM_S9S1_SLICE_MD5 = %s (computed the way ../c9-unit04/harness/chk04.py computes it)" % h); val("xfam_s9s1_md5", h[:8])
    need(not re.search(r"^XU0[1234567] = ", t9, re.M), "XU01-XU07 are not carried")
    need(re.search(r"^XU08 = ", t9, re.M) is not None and re.search(r"^u04 = u08$", t9, re.M) is not None, "U08's own family (XU08) follows the carried slice; u04 = u08 (U01's binding)")
    x2 = os.path.join(C9R, "_builders", "s907.py")
    print("  XFAM_S9S2 (the scripts stage's, C9/_builders/s907.py): %s" % ("present - not asserted here (written after this unit's start? read it)" if os.path.exists(x2) and "XFAM_S9S2" in open(x2, encoding="utf-8").read() else "does not exist yet - nothing to assert XU08 against"))
    ta, tb_ = tree(after), tree(before)
    for f in NEW: need(f in ta and f not in tb_, "new in after/, absent from before: " + f)
    for f in CHANGED: need(f in ta and f in tb_ and ta[f] != tb_[f], "changed by this unit: " + f)
    other = sorted(f for f in set(ta) | set(tb_) if f not in NEW + CHANGED and ta.get(f) != tb_.get(f))
    need(not other, "no other file differs between before and after/ (before %d files, after/ %d) %s" % (len(tb_), len(ta), other[:3]))
    nm = [f for f in ta if f.startswith(("tiffinbox-web/src/main/", "tiffinbox-core/src/main/")) and ta.get(f) != tb_.get(f)]
    need(nm == [BEAN], "(i') exactly ONE new file under src/main, no changed one: %s" % nm)
    for f in ("pom.xml", "tiffinbox-web/pom.xml", "tiffinbox-core/pom.xml", TEST):
        need(f in ta and ta[f] == tb_.get(f), "(iii)-(v) byte-equal to before (U07's): " + f)
    need(not any(f.endswith((".yaml", ".yml", ".sql", ".properties")) for f in NEW + CHANGED), "(iii) no property, no migration")
    val("files_new", len(NEW)); val("files_changed", len(CHANGED))
    # the bean (flag 1)
    bt = open(os.path.join(after, BEAN), encoding="utf-8").read()
    need(re.search(r"^@Configuration\(proxyBeanMethods = false\)\nfinal class TiffinBoxOpenApi \{$", bt, re.M) is not None, "the bean's class: package-private, final, @Configuration(proxyBeanMethods = false)")
    need(len(re.findall(r"^    @Bean$", bt, re.M)) == 1 and 'return new OpenAPI().info(new Info().title("TiffinBox").version("1.0"));' in bt, "ONE @Bean OpenAPI, info = title \"TiffinBox\" and version \"1.0\", nothing else")
    code = re.sub(r"/\*\*.*?\*/", "", bt, flags=re.S)
    for w in ("servers", "Server", "Tag", "externalDocs", "ExternalDocumentation", "Components", "SecurityScheme", "Contact", "License", "description", "@Value", "ConfigurationProperties"):
        need(w not in code, "the bean's code names no %s" % w)
    need("Course 9, unit 08:" in bt and "OpenApiSpecTest" in bt and "the DOCUMENT's version, not the version of any route" in bt and "Versioning Strategies" in bt, "the bean's Javadoc: what it does, what it does not, the test it fails, info.version is the document's")
    # the committed file (flag 4)
    sf = os.path.join(after, SPEC); sd = json.load(open(sf, encoding="utf-8")); bd = json.load(open(os.path.join(before, SPEC), encoding="utf-8"))
    need("servers" not in sd and fixed(sd) == open(sf, encoding="utf-8").read(), "the committed file: no servers, written by the fixed rule")
    need(sd.get("info") == INFO_A and bd.get("info") == INFO_B, "the committed file's info: %s (before: %s)" % (json.dumps(sd.get("info")), json.dumps(bd.get("info"))))
    sa = dict(sd); sb = dict(bd); sa.pop("info"); sb.pop("info")
    need(fixed(sa) == fixed(sb) and list(sd) == list(bd), "the committed file with info removed: byte-equal to unit 07's, the member order equal")
    import difflib
    dl = [l for l in difflib.unified_diff(open(os.path.join(before, SPEC), encoding="utf-8").read().splitlines(), open(sf, encoding="utf-8").read().splitlines(), lineterm="", n=0) if not l.startswith(("---", "+++", "@@"))]
    need(dl == ['-    "title": "OpenAPI definition",', '-    "version": "v0"', '+    "title": "TiffinBox",', '+    "version": "1.0"'], "the file's diff against unit 07's: exactly the two info lines out, two in (%d lines)" % len(dl))
    for l in dl: print("    diff: %s" % l)
    sz = os.path.getsize(sf); sz7 = os.path.getsize(os.path.join(before, SPEC))
    pred = sz7 + (len("TiffinBox") - len("OpenAPI definition")) + (len("1.0") - len("v0"))
    print("  the file's bytes: unit 07's %d, the arithmetic (title %+d, version %+d) predicts %d, wc -c says %d" % (sz7, len("TiffinBox") - len("OpenAPI definition"), len("1.0") - len("v0"), pred, sz))
    need(pred == sz, "the file's size = the arithmetic's prediction")
    val("spec_bytes", sz); val("spec_bytes_u07", sz7)
    # the anchor note form
    rs = open(os.path.join(UNIT, "receipts.sh"), encoding="utf-8").read()
    need(re.search(r'^AD=\$\(diff -rq -x \.m2-demo -x target -x secrets -x \.harness after \.\./c9-tiffinbox 2>&1 \|\| true\)$', rs, re.M) is not None
         and not re.search(r'\[ -z "\$AD" \] \|\| die', rs) and re.search(r'\[ "\$AD1" = "\$AD" \] \|\| die "the anchor moved during the run"', rs) is not None,
         "receipts.sh: the anchor check at the start is a NOTE (no die on it); the end's check is the anchor moving DURING the run (the orchestrator's notes)")
    # the stale hunt (R.250/R.453, flag 24)
    rd = open(os.path.join(after, "README.md"), encoding="utf-8").read(); cd = card(rd)
    need(bool(cd) and "*Course 9, unit 08: since unit 08 the served document carries its own title and version" in rd, "README: the unit 08 card and the header's unit 08 note")
    hits = [x for x in STALE if re.search(x, cd)]
    need(not hits, "the stale hunt: unit 08's card says nothing as current that the change makes false (%s)" % hits)
    hh = [(i + 1, l) for i, l in enumerate(rd.split("\n")) if re.search(r"\binfo\b|OpenAPI definition|\bv0\b|swagger|api-docs|springdoc|Not in this change|BOOT-INF/lib|\b157\b|\b45\b", l, re.I)]
    print("  the stale hunt over after/README.md (info, OpenAPI definition, v0, swagger, api-docs, springdoc, BOOT-INF/lib, 157, 45): %d lines" % len(hh))
    for i, l in hh:
        if i > 200: continue
        print("    README.md:%d %s" % (i, l.strip()[:140]))
    tj = open(os.path.join(after, TEST), encoding="utf-8").read()
    need("A change that changes the document on purpose (an info bean, documented errors) makes this" in tj, "OpenApiSpecTest's Javadoc (unchanged): \"an info bean ... makes this test fail until the file is written again\" - true, now paid")
    if os.path.exists(J9):
        t = open(J9, encoding="utf-8").read(); m = re.search(r'"08": "([^"]+)"', t)
        need(m is not None and m.group(1) == "springdoc-openapi and Swagger UI", "java9_series.TITLES['08'] = %r" % (m.group(1) if m else None))
    done()

# ---- the spoken lines -----------------------------------------------------------------------------------------------------------------
STATUS = re.compile(r"(?<![\d.,:/-])\b(?:[1-5]\d\d)\b|\b(?:one|two|three|four|five)[\s-]hundred[\s-]and\b|\b(?:one|two|three|four|five)[\s-]hundred[\s-](?:one|two|three|four|five|six|seven|eight|nine|ten|eleven|twelve|thirteen|fourteen|fifteen)\b")
HING = re.compile(r"\b(?:bhai|yaar|dosto|kya|hai|nahi|nahin|matlab|karo|dekho|chalo|samjho|theek|accha|arre|haan|bilkul|zaroor|aur|toh|abhi|yeh|woh|kaise|kyun|bahut|thoda|sahi|galat)\b", re.I)
SPELL = re.compile(r"\b(?:API|URI|URL|RFC)s?\b|\bOpenAPI\b|\bspringdoc\b")
def brief_lines():
    t = open(S2B, encoding="utf-8").read().split("\n")
    i0 = next(i for i, l in enumerate(t) if l.startswith("## Unit 08 · springdoc-openapi and Swagger UI")); i1 = next(i for i, l in enumerate(t) if i > i0 and l.startswith("## "))
    print("  the brief's Unit 08 section: S2B :%d-:%d" % (i0 + 1, i1))
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
    sf = None
    if os.path.exists(CU9):
        try:
            sys.path.insert(0, os.path.dirname(CU9))
            sp = importlib.util.spec_from_file_location("cu9", CU9); cu = importlib.util.module_from_spec(sp); sp.loader.exec_module(cu); sf = cu.status_forms
            sys.path.pop(0)
        except Exception as e: print("  check_unit9.py's status_forms could not be loaded (%s): this checker's own status pattern only" % e.__class__.__name__)
    bh, be, bl = brief_lines()
    print("  extracted from the brief's bytes (S2B, the Hook line and the Exercise line): %d lines, md5 %s" % (len(bl), hashlib.md5("\n".join(bl).encode()).hexdigest()))
    need(hook == HOOK == bh, "the hook is S2B :179's, byte for byte (extracted at run time = typed once here)")
    need(exq == EXQ == be, "the exercise's line is S2B :187's, byte for byte (extracted at run time = typed once here)")
    hw, ew, gw = len(hook.split()), len(exq.split()), len(GLOSS.split())
    need(hw == 19 and hw <= 25, "the hook: %d words (wc -w; the brief's 19; <= 25)" % hw)
    need(ew == 17 and ew <= 25, "the exercise: %d words (wc -w; the brief's 17; <= 25)" % ew)
    for name, s in (("the hook", hook), ("the exercise", exq), ("the gloss", GLOSS)):
        nd = re.findall(r"\d", s); cf = sf(s) if sf else None
        print("  %s: digits %s · the status gate %s · check_unit9.status_forms %s · the spelling gate %s · Hinglish %s · dur9 %s" % (name, "".join(nd) or "0", "hit" if STATUS.search(s) else "0",
              cf if cf is not None else "-", SPELL.search(s).group(0) if SPELL.search(s) else "0", "hit" if HING.search(s) else "0", dur.search(s).group(0) if dur is not None and dur.search(s) else "0"))
        need(not STATUS.search(s) and not cf, "%s: the status gate 0" % name)
        need(not SPELL.search(s), "%s: the spelling gate 0 (API, URI, URL, RFC, bare OpenAPI / springdoc; Swagger and UI are bare, BLUE's gate printed 0)" % name)
        need(not HING.search(s), "%s: the Hinglish list 0" % name)
        if dur is not None: need(not dur.search(s), "%s: dur9 0" % name)
        need(not nd, "%s: no digit" % name)
    for p in ("Open A-P-I", "spring doc"): need(not SPELL.search(p), "the spelled form %r passes the spelling gate (RED #25 / BLUE)" % p)
    for p in ("OpenAPI", "springdoc"): need(bool(SPELL.search("It reads the " + p + " document.")), "the bare %r refuses in a spoken line" % p)
    print("  the hook: %d words · the exercise: %d words · the gloss: %d words; the brief's parenthetical (%d words): \"%s\"" % (hw, ew, gw, len(BRIEFQ.split()), BRIEFQ))
    val("hook_words", hw); val("exercise_words", ew); val("gloss_words", gw)
    done()

def gloss(readme):
    u6 = open(os.path.join(UNIT, "..", "c9-unit06", "README.md"), encoding="utf-8").read().split("\n")
    need(len(u6) > 18 and u6[18] == U06GLOSS, "U06's gloss line is still byte-equal at ../c9-unit06/README.md:19")
    rd = open(readme, encoding="utf-8").read().split("\n")
    g = [i + 1 for i, l in enumerate(rd) if re.match(r"^\s*A contract:", l)]
    need(not g, "README.md carries no line starting \"A contract:\" (U06's, not re-glossed) %s" % g)
    s = [i + 1 for i, l in enumerate(rd) if l.startswith("Swagger UI:")]
    need(len(s) == 1 and rd[s[0] - 1] == GLOSS, "README.md carries exactly one line starting \"Swagger UI:\", the gloss byte for byte (%s)" % s)
    need(len(GLOSS.split()) <= 25, "the gloss: %d words (<= 25)" % len(GLOSS.split()))
    first = next((i + 1 for i, l in enumerate(rd) if "Swagger UI" in re.sub(r"`[^`]*`", "", l) and not l.startswith("#")), None)
    print("  the gloss (%d words): %s · the brief's parenthetical (%d words): %s" % (len(GLOSS.split()), GLOSS, len(BRIEFQ.split()), BRIEFQ))
    print("  first spoken use of \"Swagger UI\" in the README at line %s" % first)
    val("gloss", "Swagger_UI_one_line")
    done()

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
def cpool(data):
    """the class file's constant pool, its UTF-8 entries (JVMS 4.4)"""
    if data[:4] != b"\xca\xfe\xba\xbe": return []
    n = int.from_bytes(data[8:10], "big"); i = 10; k = 1; out = []
    size = {7: 2, 8: 2, 3: 4, 4: 4, 9: 4, 10: 4, 11: 4, 12: 4, 15: 3, 16: 2, 17: 4, 18: 4, 19: 2, 20: 2}
    while k < n:
        t = data[i]
        if t == 1:
            L = int.from_bytes(data[i + 1:i + 3], "big"); out.append(data[i + 3:i + 3 + L].decode("utf-8", "replace")); i += 3 + L
        elif t in (5, 6): i += 9; k += 1
        else: i += 1 + size[t]
        k += 1
    return out
def jars(lib):
    names = sorted(os.listdir(lib))
    print("  jackson jars: %s" % " ".join(x for x in names if x.startswith(("jackson-databind-", "jackson-core-", "jackson-dataformat-yaml-"))))
    sc = [x for x in names if x.startswith("swagger-core-")]; cm = [x for x in names if x.startswith("springdoc-openapi-starter-common-")]
    if sc:
        z = zipfile.ZipFile(os.path.join(lib, sc[0])); c = [n for n in z.namelist() if n.endswith("/ObjectMapperFactory.class")]
        u = cpool(z.read(c[0])) if c else []
        print("  %s %s: constant-pool UTF-8 entries naming tools/jackson/databind %d · tools/jackson/core %d · com/fasterxml/jackson/databind %d · com/fasterxml/jackson/annotation %d" % (
              sc[0], c[0] if c else "no ObjectMapperFactory", sum("tools/jackson/databind" in x for x in u), sum("tools/jackson/core" in x for x in u),
              sum("com/fasterxml/jackson/databind" in x for x in u), sum("com/fasterxml/jackson/annotation" in x for x in u)))
    if cm:
        z = zipfile.ZipFile(os.path.join(lib, cm[0])); cls = [n for n in z.namelist() if n.endswith(".class")]
        j3 = j2 = 0
        for n in cls:
            u = cpool(z.read(n)); j3 += any("tools/jackson/databind" in x for x in u); j2 += any("com/fasterxml/jackson/databind" in x for x in u)
        print("  %s: classes %d · naming tools/jackson/databind %d · naming com/fasterxml/jackson/databind %d" % (cm[0], len(cls), j3, j2))


# ---- unit 08's small readers ------------------------------------------------------------------------------------------------------------
PM = lambda s: re.sub(r"(127\.0\.0\.1|localhost):\d{4,5}", r"\1:<port>", s)
def scfg(p):
    try: d = json.load(open(p, encoding="utf-8"))
    except Exception: print("unreadable"); return
    print("validatorUrl %s · oauth2RedirectUrl %s · url %s · configUrl %s" % (json.dumps(d.get("validatorUrl")), PM(json.dumps(d.get("oauth2RedirectUrl"))), json.dumps(d.get("url")), json.dumps(d.get("configUrl"))))
def assets(p):
    t = open(p, encoding="utf-8", errors="replace").read()
    out = []
    for m in re.finditer(r'(?:href|src)="([^"#?]+)"', t):
        u = m.group(1)
        if u.startswith(("http:", "https:", "data:", "//")): continue
        if not u.startswith("/"): u = "/swagger-ui/" + u.lstrip("./")
        if u not in out: out.append(u)
    print(" ".join(out))
def opid(p):
    d = json.load(open(p, encoding="utf-8"))
    ids = [o.get("operationId") for path, v in d["paths"].items() for m, o in v.items() if m == "get" and path.startswith("/api/v1/") and path.endswith("/{name}")]
    if len(ids) != 1: print("AMBIGUOUS %s" % ids); return
    tag = d["paths"]["/api/v1/customers/{name}"]["get"]["tags"][0]
    print("%s-%s" % (tag, ids[0]))
def media(p, op):
    d = json.load(open(p, encoding="utf-8"))
    for path, v in d["paths"].items():
        for m, o in v.items():
            if "%s-%s" % (o.get("tags", [""])[0], o.get("operationId")) == op:
                print(" · ".join("%s %s" % (c, ",".join(r.get("content", {}).keys()) or "-") for c, r in o["responses"].items())); return
    print("no operation %s" % op)
def evload(p):
    try: return json.load(open(p))
    except Exception: return None
def cdpev(mode, *a):
    if mode == "summary":
        ev = evload(a[0]) or []
        rw = [e for e in ev if e.get("method") == "Network.requestWillBeSent"]
        lf = [e for e in ev if e.get("method") == "Network.loadingFailed"]
        print("  CDP: requestWillBeSent %d · loadingFailed %d · schemes %s" % (len(rw), len(lf), ",".join(sorted(collections.Counter(e["params"]["request"]["url"].split(":", 1)[0] for e in rw)))))
        for e in rw:
            u = e["params"]["request"]["url"]
            if u.startswith(("data:", "file:", "blob:")): print("  CDP request %s: (inline, %s - no socket, not a request to any host)" % (e["params"].get("type", "-"), u.split(":", 1)[0] + ":"))
            else:
                r = next((x for x in ev if x.get("method") == "Network.responseReceived" and x["params"]["requestId"] == e["params"]["requestId"]), None)
                print("  CDP request %s %s -> %s %s" % (e["params"]["request"]["method"], PM(u), r["params"]["response"]["status"] if r else "-", r["params"]["response"]["mimeType"] if r else "-"))
    elif mode == "host":
        ev = evload(a[0]) or []
        print(sum(1 for e in ev if e.get("method", "").startswith("Network.") and a[1] in json.dumps(e.get("params", {}).get("request", {}).get("url", ""))))
    elif mode == "same":
        f = lambda p: [re.sub(r"^https?://([^/:]+)(?::\d+)?", r"\1", e["params"]["request"]["url"]) for e in (evload(p) or []) if e.get("method") == "Network.requestWillBeSent" and not e["params"]["request"]["url"].startswith("data:")]
        x, y = f(a[0]), f(a[1])
        print("%s (before %d, after %d host-and-path entries)" % ("equal" if sorted(x) == sorted(y) else "DIFFERENT", len(x), len(y)))
def strip2(d):
    d = dict(d); d.pop("info", None); d.pop("servers", None); return d
def infodiff(bp, ap, title=None, version=None):
    want = {"title": title or INFO_A["title"], "version": version or INFO_A["version"]}
    try:
        b = json.load(open(bp, encoding="utf-8")); a = json.load(open(ap, encoding="utf-8"))
    except Exception as e:
        print("  refused: an input is empty or not a document (%s)" % e.__class__.__name__); sys.exit(2)
    print("  (a) before's info %s · after's info %s" % (json.dumps(b.get("info")), json.dumps(a.get("info"))))
    hb, ha = hashlib.md5(fixed(strip2(b)).encode()).hexdigest(), hashlib.md5(fixed(strip2(a)).encode()).hexdigest()
    print("  (b) with info and servers removed, re-dumped by the fixed rule: before md5 %s · after md5 %s · %s" % (hb, ha, "equal" if hb == ha else "DIFFERENT"))
    print("  (b) the top-level member order: before %s · after %s · %s" % (",".join(b), ",".join(a), "equal" if list(b) == list(a) else "DIFFERENT"))
    top = sorted(k for k in set(a) | set(b) if a.get(k) != b.get(k) and k != "servers")
    inf = sorted(k for k in set(a.get("info", {})) | set(b.get("info", {})) if a.get("info", {}).get(k) != b.get("info", {}).get(k))
    print("  (b) top-level members that differ (servers aside): %s · info's members that differ: %s" % (",".join(top) or "none", ",".join(inf) or "none"))
    sv = lambda d: PM(json.dumps(d.get("servers")))
    print("  (b) servers, the port masked: before %s · after %s · %s" % (sv(b), sv(a), "equal" if sv(b) == sv(a) else "DIFFERENT"))
    P = lambda d: (len(d.get("paths", {})), sum(len(v) for v in d.get("paths", {}).values()), len({t for v in d.get("paths", {}).values() for o in v.values() for t in o.get("tags", [])}))
    print("  (e) paths / operations / tags: before %d / %d / %d · after %d / %d / %d" % (P(b) + P(a)))
    bad = []
    for k in top:
        if k != "info": bad.append(k); print("  MOVED beyond info: %s" % k)
    if sv(b) != sv(a): bad.append("servers"); print("  MOVED beyond info: servers")
    if hb != ha or list(b) != list(a): bad.append("the rest of the document")
    if inf != ["title", "version"]: bad.append("info's members %s" % inf)
    if a.get("info") != want: print("  refused: after's info %s is not the exact strings %s" % (json.dumps(a.get("info")), json.dumps(want))); bad.append("info's strings")
    if P(a) != P(b): bad.append("the counts")
    print("  verdict: %s" % ("the bean moved info (title, version) and nothing else" if not bad else "MOVED: " + "; ".join(bad)))
    sys.exit(1 if bad else 0)
def yamldiff(bp, ap):
    import difflib
    b = PM(open(bp, encoding="utf-8").read()).splitlines(); a = PM(open(ap, encoding="utf-8").read()).splitlines()
    d = [l for l in difflib.unified_diff(b, a, lineterm="", n=0) if not l.startswith(("---", "+++", "@@"))]
    for l in d: print("  yaml %s" % l)
    print("  yaml: %d lines out, %d in" % (sum(l.startswith("-") for l in d), sum(l.startswith("+") for l in d)))
def plantdoc(k, src, out):
    d = json.load(open(src, encoding="utf-8"))
    if k == "servers": d["servers"] = [{"url": "https://api.tiffinbox.example"}]
    elif k == "externalDocs": d["externalDocs"] = {"url": "https://docs.tiffinbox.example"}
    elif k == "tags": d["tags"] = [{"name": "customers"}]
    json.dump(d, open(out, "w", encoding="utf-8"))
def netread(p):
    d = json.load(open(p))
    types = {v: k for k, v in d["constants"]["logEventTypes"].items()}
    udp = collections.Counter(); err = collections.Counter(); sent = 0; tcp = set()
    for e in d["events"]:
        t, q = types.get(e["type"], ""), e.get("params", {}) or {}
        if t == "UDP_CONNECT" and "address" in q: udp[q["address"]] += 1
        if t == "UDP_CONNECT" and "net_error" in q: err[q["net_error"]] += 1
        if t == "UDP_BYTES_SENT": sent += q.get("byte_count", 0) or 1
        if t == "TCP_CONNECT_ATTEMPT" and "address" in q: tcp.add(q["address"])
        if t == "TCP_CONNECT" and "remote_address" in q: tcp.add(q["remote_address"])
    lo = lambda x: x.rsplit(":", 1)[0].strip("[]") in ("127.0.0.1", "::1")
    print("  chk08's read: UDP connects %d (%s) · their net_error values %s · UDP_BYTES_SENT %d - printed as found, not asserted, never voiced" % (sum(udp.values()), ",".join(sorted(udp)) or "none", dict(err) or "none", sent))
    print("  chk08's read: TCP connect addresses %s · every TCP connect to loopback: %s" % (",".join(sorted(tcp)), "yes" if tcp and all(lo(x) for x in tcp) else "NO - STOP: the dead proxy failed"))
def plantev(src, out):
    ev = json.load(open(src)); ev.append({"method": "Network.requestWillBeSent", "params": {"requestId": "plant", "request": {"url": "https://validator.swagger.io/validator?url=x", "method": "GET", "headers": {}}}})
    json.dump(ev, open(out, "w"))
def plantnet(src, out):
    d = json.load(open(src)); t = {k: v for k, v in d["constants"]["logEventTypes"].items()}
    d["events"].append({"type": t["TCP_CONNECT"], "params": {"remote_address": "8.8.8.8:443"}})
    json.dump(d, open(out, "w"))
def detector(n):
    print("PASS" if n.strip() == "13" else "FAIL (it can fail: R.276 + R.374)")
def statusword(s):
    print("PASS" if re.fullmatch(r'"?[1-5]\d\d"?', s.strip()) else "FAIL (the shown status is not a status: %s)" % s.strip())
def bare(s):
    print("refused (a scheme)" if re.match(r"^[a-z]+://", s) else "bare")
def names(p):
    t = open(p, encoding="utf-8", errors="replace").read() if os.path.exists(p) else ""
    print("the report names: TiffinBox %s · OpenAPI definition %s · mealsPerDay %s · maxLength %s" % ("TiffinBox" in t, "OpenAPI definition" in t, "mealsPerDay" in t, "maxLength" in t))

# ---- the captures ---------------------------------------------------------------------------------------------------------------------
TESTS_RX = r"^  (\w+) tests (\d+) failures (\d+) errors (\d+) skipped (\d+)$"
IT = {"CustomerEntityRepositoryIT": (21280, 5432), "CustomerAggregatesIT": (21281, 5432), "RedisDatastoreIT": (21282, 6379), "MongoDatastoreIT": (21283, 27017), "ElasticsearchIT": (21284, 9200)}
def u07v():
    t = open(os.path.join(UNIT, "..", "c9-unit07", "README.md"), encoding="utf-8").read()
    m = re.search(r"<!-- values: begin -->\n```\n(.*?)\n```", t, re.S); V = {}
    for l in (m.group(1).splitlines() if m else []):
        for k, v in re.findall(r"(\w+)=(\S+)", l): V.setdefault(l.split(":")[0] + "." + k, v)
    return V
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
    V = u07v(); u7 = int(V.get("tests.tests", 0)); i7 = int(V.get("tests.its", 0))
    for s in ("pkg", "twin"):
        tot = sum(per[s].values())
        need(tot == u7 + 0 and per[s].get("OpenApiSpecTest") == 1, "%s: %d = U07's %d (its README values block; re-measured) + 0 (no new class); OpenApiSpecTest 1" % (s, tot, u7))
    need(per["pkg"] == per["twin"], "the Docker-free twin runs the same classes and counts as package")
    t = "\n".join(ls)
    need(re.search(r"^  mvn package exit 0 ", t, re.M) is not None and re.search(r"^  mvn package \(Docker-free\) exit 0 ", t, re.M) is not None, "mvn package exit 0, and its Docker-free twin exit 0")
    need(re.search(r"^  the twin's OpenApiSpecTest line: OpenApiSpecTest: servers served \[\{\"url\":\"http://localhost\"", t, re.M) is not None, "the twin: MockMvc's servers is http://localhost")
    need(sum(per["it"].values()) == i7 == 14 and len(per["it"]) == 5, "the ITs: %d in 5 classes (U07's %s)" % (sum(per["it"].values()), i7))
    val("tests", sum(per["pkg"].values())); val("tests_u07", u7); val("tests_k", 0); val("its", sum(per["it"].values()))
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
    l7 = V.get("tests.lib", "-").split("->")[-1]
    need(len(libs) == 2 and libs[0][1] == libs[1][1] == l7 and not moved and "  the jars' names moved before -> after: 0" in ls, "BOOT-INF/lib %s -> %s (U07's %s), no jar's name moved" % (libs[0][1] if libs else "-", libs[1][1] if len(libs) > 1 else "-", l7))
    al = [l for l in ls if l.startswith("  after: ")]
    for j in ("tomcat-embed-core-11.0.29.jar", "spring-core-7.0.11.jar", "spring-boot-4.1.3.jar", "springdoc-openapi-starter-webmvc-ui-3.2.1.jar", "swagger-ui-5.35.1.jar"):
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
    need(len(R["after"]) == H["after"][1] and len(R["before"]) == H["before"][1], "one mapping line per TiffinBox handler method (after %d, before %d)" % (len(R["after"]), len(R["before"])))
    need(R["after"] == R["before"], "TiffinBox's rows byte-equal on before and after/ (%d)" % len(R["after"]))
    need(SD["after"] == SD["before"] and H["after"][2] == len(SD["after"]) == 4, "springdoc's rows equal on both trees: %d (%s)" % (len(SD["after"]), ", ".join(r[2] for r in SD["after"])))
    need(H["after"] == H["before"], "all rows equal on both trees (%d): the bean adds no mapping row" % H["after"][0])
    V = u07v(); tb = H["after"][1]
    C = {}
    for l in ls:
        m = re.match(r"^  commit (\w+) \(.*\): mapping annotations (\d+) · dev mappings (\d+) · default run (\d+)$", l)
        if m: C[m.group(1)] = tuple(int(x) for x in m.groups()[1:])
    a = re.search(r"^  after/ \(this unit's tree\): mapping annotations (\d+) · dev mappings (\d+) · default run (\d+)$", t, re.M)
    need(set(C) == {"80f7839", "a0a0151", "df4ff12", "a805e6c", "bf9b296"} and a is not None, "the partition: five commits and after/ read")
    if a and len(C) == 5:
        s0, s4, s5, s6, s7, s8 = C["80f7839"][2], C["a0a0151"][2], C["df4ff12"][2], C["a805e6c"][2], C["bf9b296"][2], int(a.group(3))
        need(C["bf9b296"] == (int(a.group(1)), int(a.group(2)), s8), "after/: annotations %s · dev %s · default run %s = bf9b296's (U07's commit)" % a.groups())
        need(s8 == tb, "after/'s default-run mappings by source (%d) = the flag start's TiffinBox rows (%d)" % (s8, tb))
        need((s0, s4 - s0, s5 - s4, s6 - s5, s7 - s6) == tuple(int(V.get("census." + k, -1)) for k in ("handlers_setup", "handlers_u04", "handlers_u05", "handlers_u06", "handlers_u07")), "the partition by commit = U07's values block")
        need(s0 + (s4 - s0) + (s5 - s4) + (s6 - s5) + (s7 - s6) == s7 == tb and s8 - s7 == 0, "the partition: %d + %d + %d + %d + %d = %d; U08 adds %d" % (s0, s4 - s0, s5 - s4, s6 - s5, s7 - s6, s7, s8 - s7))
        val("annotations", a.group(1)); val("dev_mappings", a.group(2)); val("handlers", tb); val("handlers_u08", s8 - s7)
    dc = re.search(r"^  the dev classes \(@Profile\(\"dev\"\)\): (.*) - not started on the default run", t, re.M)
    need(dc is not None and a is not None and int(a.group(1)) - int(a.group(2)) == tb, "the dev mappings (%s) are not among the default run's rows: annotations %s - dev %s = %d" % (dc.group(1) if dc else "-", a.group(1) if a else "-", a.group(2) if a else "-", tb))
    ua = re.search(r"the unanchored count beside: after/ (\d+)", t)
    need(ua is not None and a is not None and int(ua.group(1)) == int(a.group(1)) + 1, "the unanchored pattern counts one line more (a Javadoc's {@code @GetMapping}) - the anchored grep is the count")
    opsl = re.search(r"^  op document: paths (\d+) · operations (\d+) · operations no handler maps: (\d+)$", t, re.M)
    need(opsl is not None and len(O) == tb, "one handler-to-operation line per TiffinBox handler (%d)" % len(O))
    if opsl:
        absent = [o for o in O if o[4] == "absent"]; present = [o for o in O if o[4] != "absent"]
        merged = len(present) - len({o[4] for o in present}); nops = int(opsl.group(2))
        need(all(o[0] == "DashboardPage" for o in absent) and len(absent) == 3, "absent: DashboardPage's three")
        need(merged == 1, "the two PATCH handlers are one operation (merged %d)" % merged)
        need(tb - len(absent) - merged == nops == int(V.get("census.operations", -1)) and int(opsl.group(3)) == 0, "%d - %d - %d = %d operations (U07's %s)" % (tb, len(absent), merged, nops, V.get("census.operations")))
        val("operations", nops); val("paths", int(opsl.group(1))); val("absent", len(absent)); val("merged", merged); val("springdoc_rows", H["after"][2])
    j = {m.group(1): int(m.group(2)) for m in re.finditer(r"^  (before|after)'s jar: (\d+) entries named probe/", t, re.M)}
    need(j == {"before": 0, "after": 0}, "the jars: 0 entries named probe/ on both (the harness's routes never in the jar)")
    pl = re.search(r"^  plant \(one probe/ class added to a scratch copy of the jar\): (\d+) entries", t, re.M)
    need(pl is not None and int(pl.group(1)) > 0, "the plant jar holds a probe/ entry - the 0 check would FAIL on it")
    need(re.search(r"^  after's jar: 0 entries named probe/ · TiffinBoxOpenApi\.class 1$", t, re.M) is not None, "after/'s jar holds the bean's class")
    val("probe_in_jar", 0)

def c_after(p):
    ls, R, heads, asks = load(p); t = "\n".join(ls); F = {}
    for db in ("pg", "h2"):
        blk = t.split("== %s: the five addresses" % db)[1].split("\n== ")[0] if ("== %s: the five addresses" % db) in t else ""
        f = {}
        for k, rx in (("doc1", r"document: openapi (\S+) · info (\{.*?\}) · servers (.*)$"), ("doc2", r"document: paths (\d+) · operations (\d+) · tags (\S+) · schemas (\S+)$"),
                      ("doc3", r"document: components\.securitySchemes (\w+) · a security member (\w+)"),
                      ("doc5", r"document: the socket's answer (\d+) B .* md5 masked ([0-9a-f]{32}) · servers removed \(the fixed rule\) ([0-9a-f]{32}) · = the committed file: (\S+)$"),
                      ("scfg", r"swagger-config \(python, the served member\): validatorUrl (\S+) · oauth2RedirectUrl (\S+)"),
                      ("dbl", r"which database answered \(Flyway's line\): Database: \S+ \(([A-Za-z0-9]+) ([0-9.]+)\)")):
            m = re.search(rx, blk, re.M); f[k] = m.groups() if m else None
            need(m is not None, "%s: the %s line" % (db, k))
        F[db] = f
    if any(v is None for f in F.values() for v in f.values()): return
    need(F["pg"]["dbl"] == ("PostgreSQL", "18.6") and F["h2"]["dbl"][0] == "H2", "the database label: PostgreSQL 18.6 on the pg block, H2 on the h2 block (%s, %s)" % (F["pg"]["dbl"], F["h2"]["dbl"]))
    for db in ("pg", "h2"):
        f = F[db]
        need(f["doc1"][0] == "3.1.0" and json.loads(f["doc1"][1]) == INFO_A, "%s: openapi 3.1.0, info %s" % (db, f["doc1"][1]))
        need("<port>" in f["doc1"][2] and not re.search(r":\d{4,5}", f["doc1"][2]), "%s: servers[0].url masked" % db)
        need(f["doc3"] == ("absent", "absent"), "%s: no securitySchemes, no security member" % db)
        need(f["doc5"][3] == "byte-identical", "%s: the served document with servers removed = the committed file" % db)
        need(f["scfg"][0] == '""' and "<port>" in f["scfg"][1], "%s: swagger-config validatorUrl \"\" (the served member), oauth2RedirectUrl's port masked" % db)
    need({k: v for k, v in F["pg"].items() if k != "dbl"} == {k: v for k, v in F["h2"].items() if k != "dbl"}, "the document equal on PostgreSQL and H2 after the mask (every fact line)")
    need("  the document on PostgreSQL and on H2, servers removed: byte-identical" in ls, "the two servers-removed documents byte-identical")
    need(len(asks) == 10, "five addresses asked on each database (%d blocks)" % len(asks))
    want = {"/v3/api-docs": ("200", "application/json"), "/swagger-ui.html": ("302", None), "/swagger-ui/index.html": ("200", "text/html"),
            "/v3/api-docs.yaml": ("200", None), "/v3/api-docs/swagger-config": ("200", "application/json")}
    for b in asks:
        w = want.get(b["p"])
        need(w is not None and b["st"] == w[0] and (w[1] is None or b["ct"].startswith(w[1])), "after: GET %s -> %s %s" % (b["p"], b["st"], b["ct"]))
        need(b["key"] == "no", "after: GET %s sent no key header" % b["p"])
    h = F["h2"]; d2 = h["doc2"]
    need((d2[0], d2[1], len(d2[2].split(","))) == ("11", "13", 6), "paths 11 / operations 13 / tags 6 (%s)" % d2[2])
    val("openapi", h["doc1"][0]); val("info", "TiffinBox/1.0"); val("paths", d2[0]); val("operations", d2[1]); val("tags", len(d2[2].split(","))); val("schemas", d2[3])
    val("socket_bytes_not_voiced", h["doc5"][0]); val("spec_md5", h["doc5"][2][:8]); val("validatorUrl", "empty"); val("pg_equal", "yes")

def c_redirect(p):
    ls, R, heads, asks = load(p); t = "\n".join(ls)
    S = collections.defaultdict(list); cur = None
    for l in ls:
        m = re.match(r"^== (pg|h2|before): the page's address", l)
        if m: cur = m.group(1); continue
    blocks = {}
    for side in ("pg", "h2", "before"):
        blk = t.split("== %s: the page's address" % side)[1].split("\n== ")[0] if "== %s: the page's address" % side in t else ""
        _, A = parse(blk.splitlines())[0], parse(blk.splitlines())[0]
        blocks[side] = [(a["p"], a["st"], a["ct"], a["sz"], hdr(a, "Location")) for a in parse(blk.splitlines())[0]]
    for side, bl in blocks.items():
        r = [x for x in bl if x[0] == "/swagger-ui.html"]; i = [x for x in bl if x[0] == "/swagger-ui/index.html"]
        need(len(r) == 1 and r[0][1] == "302" and (r[0][4] or "").endswith("/swagger-ui/index.html"), "%s: GET /swagger-ui.html -> 302, Location .../swagger-ui/index.html" % side)
        need(len(i) == 1 and i[0][1] == "200" and i[0][2].startswith("text/html"), "%s: GET /swagger-ui/index.html -> 200 text/html" % side)
        st = [x for x in bl if x[0] not in ("/swagger-ui.html", "/swagger-ui/index.html")]
        need(len(st) >= 4 and all(x[1] == "200" for x in st), "%s: the page's static files, each 200: %s" % (side, " · ".join("%s %s %s" % (x[0], x[1], x[2]) for x in st)))
    need(blocks["pg"] == blocks["h2"] == blocks["before"], "the same lines on PostgreSQL, H2 and before (status, type, size, Location)")
    val("redirect", "302->index.html"); val("static_files", len(blocks["h2"]) - 2)

def c_before(p):
    ls, R, heads, asks = load(p); t = "\n".join(ls)
    need(len(asks) == 5, "five addresses asked on before (%d)" % len(asks))
    st = {a["p"]: a["st"] for a in asks}
    need(st == {"/v3/api-docs": "200", "/v3/api-docs.yaml": "200", "/v3/api-docs/swagger-config": "200", "/swagger-ui.html": "302", "/swagger-ui/index.html": "200"}, "before: the five addresses answer (U07 paid the first half): %s" % st)
    m = re.search(r"document: openapi (\S+) · info (\{.*?\}) · servers", t)
    need(m is not None and json.loads(m.group(2)) == INFO_B, "before's info: %s (springdoc's default, as NOTES :88 read it)" % (m.group(2) if m else "-"))
    m2 = re.search(r"document: paths (\d+) · operations (\d+) · tags (\S+)", t)
    need(m2 is not None and (m2.group(1), m2.group(2), len(m2.group(3).split(","))) == ("11", "13", 6), "before: paths 11 / operations 13 / tags 6")
    need("  ledger: The API docs route and the Swagger page answer four-oh-four: TiffinBox publishes no contract today." in ls, "Course 8's line, read off the ledger (C9-10d)")
    need(re.search(r"^  the script's line (\d+) holds it: [1-9]", t, re.M) is not None, "the line stands in What's Next: The API Other People Will Use")
    need(all(a["key"] == "no" for a in asks), "before: no request sent the key header")
    val("before_info", "OpenAPI_definition/v0")

def c_info(p):
    ls = lines(p); t = "\n".join(ls)
    m = re.search(r"^  \(b\) with info and servers removed, re-dumped by the fixed rule: before md5 ([0-9a-f]{32}) · after md5 ([0-9a-f]{32}) · (\w+)$", t, re.M)
    need(m is not None and m.group(1) == m.group(2) and m.group(3) == "equal", "(b) the two hashes printed and equal")
    W = os.path.join(UNIT, ".harness", "work")
    if m:
        hb = hashlib.md5(fixed(strip2(json.load(open(os.path.join(W, "spec-before.raw"), encoding="utf-8")))).encode()).hexdigest()
        ha = hashlib.md5(fixed(strip2(json.load(open(os.path.join(W, "spec-h2.raw"), encoding="utf-8")))).encode()).hexdigest()
        need(hb == m.group(1) and ha == m.group(2), "(b) READ BACK: the hashes in the capture = this checker's own hashes of the two saved documents (%s)" % m.group(1)[:8])
        val("info_rest_md5", m.group(1)[:8])
    need(re.search(r"^  \(a\) before's info \{\"title\": \"OpenAPI definition\", \"version\": \"v0\"\} · after's info \{\"title\": \"TiffinBox\", \"version\": \"1\.0\"\}$", t, re.M) is not None, "(a) info before / after as printed")
    need(re.search(r"^  \(b\) the top-level member order: .* · equal$", t, re.M) is not None, "(b) the top-level member order equal")
    need(re.search(r"^  \(b\) top-level members that differ \(servers aside\): info · info's members that differ: title,version$", t, re.M) is not None, "(b) exactly 1 top-level member differs (info) and 2 of info's (title, version)")
    need(re.search(r"^  \(b\) servers, the port masked: .* · equal$", t, re.M) is not None, "(b) servers equal after the port mask (springdoc's own generated server on both)")
    need(re.search(r"^  \(e\) paths / operations / tags: before 11 / 13 / 6 · after 11 / 13 / 6$", t, re.M) is not None, "(e) paths 11 / operations 13 / tags 6 on both")
    need("  infodiff exit 0" in ls, "infodiff exit 0: the bean moved info (title, version) and nothing else")
    y = [l for l in ls if l.startswith("  yaml -") or l.startswith("  yaml +")]
    need(y == ['  yaml -  title: OpenAPI definition', '  yaml -  version: v0', '  yaml +  title: TiffinBox', '  yaml +  version: "1.0"'] or (len(y) == 4 and sum("title:" in l for l in y) == 2 and sum("version:" in l for l in y) == 2),
         "(c) the YAML: exactly the title: and version: lines, 2 out, 2 in (%s)" % " | ".join(x.strip() for x in y))
    d = re.search(r"^== \(d\) swagger-config, the port masked: before (.*) · after (.*)$", t, re.M)
    need(d is not None and d.group(1) == d.group(2), "(d) swagger-config equal after the port mask")
    for k in ("servers", "externalDocs", "tags"):
        m = re.search(r"^  plant %s: infodiff exit (\d) · (.*)$" % k, t, re.M)
        need(m is not None and m.group(1) == "1" and (k in m.group(2) or (k == "servers" and "servers" in m.group(2))), "the plant: the bean also adds %s -> infodiff FAILS naming it (%s)" % (k, m.group(2)[:60] if m else "-"))
    need(re.search(r"^  plant empty input: infodiff exit 2 ", t, re.M) is not None, "an empty input: exit 2 (refused)")
    need(re.search(r"^  plant typed \"Tiffinbox\": infodiff exit 1 · refused", t, re.M) is not None and re.search(r"^  plant typed \"1\": infodiff exit 1 · refused", t, re.M) is not None, "typed \"Tiffinbox\" or \"1\": the exact-string check FAILS")
    print("  witness for this change: the requests answered by springdoc's four handlers (OpenApiWebMvcResource, SwaggerConfigResource, SwaggerWelcomeWebMvc) and the resource handlers (the page's files); not a witness for this change: the rest - the seven, the old surface, the old routes - they stay equal because they do not reach it")
    print("  moved, compatible (a metadata edit), named in this unit: the document's info (title, version) and the page's heading that follows it")
    val("info_moved", "title+version"); val("rest_equal", "yes")

def c_sealed(p):
    ls = lines(p); t = "\n".join(ls)
    H = re.findall(r"^  CDP request host (\S+)\s+x(\d+)$", t, re.M)
    cr = re.findall(r"^  CDP requests: (\d+) \((\d+) to a socket, (\d+) data:/file: with no socket\)$", t, re.M)
    vd = re.findall(r"^  CDP verdict: (.*)$", t, re.M)
    ex = re.findall(r"^  seal9\.py cdp exit (\d)$", t, re.M)
    need(ex[:1] == ["0"] and vd[:1] == ["the page asked nothing but 127.0.0.1"], "seal9.py cdp on after/'s page: exit 0, \"the page asked nothing but 127.0.0.1\"")
    need(H[:1] == [("127.0.0.1:20970", cr[0][1] if cr else "-")], "the host table: 127.0.0.1:20970 only (x%s)" % (H[0][1] if H else "-"))
    if cr:
        n, s, i = (int(x) for x in cr[0])
        need(i == 2 and s + i == n, "CDP requests: %d (%d to a socket, %d data: with no socket) - the probe's 11 / 9 / 2" % (n, s, i))
        val("cdp_socket", s); val("cdp_inline", i)
    sm = re.search(r"^  CDP: requestWillBeSent (\d+) · loadingFailed (\d+)", t, re.M)
    need(sm is not None and sm.group(2) == "0", "0 loadingFailed")
    need(re.search(r"^  swagger-config: validatorUrl \"\" ", t, re.M) is not None, "the served swagger-config: validatorUrl \"\"")
    need("  the DOM's validator badge elements: 0" in ls and "  CDP events naming validator.swagger.io: 0" in ls, "0 validator badge elements in the DOM, 0 CDP events to validator.swagger.io")
    need(re.search(r"^  seal9\.py cdp \(the plant\) exit 1$", t, re.M) is not None and re.search(r"^  CDP OUTBOUND: https://fonts\.googleapis\.com/css$", t, re.M) is not None, "the plant (the harness's page): seal9.py cdp exit 1, CDP OUTBOUND: https://fonts.googleapis.com/css")
    need(re.search(r"^  probe: CDP OUTBOUND: https://fonts\.googleapis\.com/css", t, re.M) is not None and "  seal9.py cdp (the probe's) exit 1" in ls and re.search(r"= the probe's MD5SUMS line [0-9a-f]{32}: yes$", t, re.M) is not None, "the probe's filed font run (md5 = its MD5SUMS line): exit 1 - read, not produced here")
    need("  an empty events file: seal9.py cdp exit 2" in ls, "an empty events file: exit 2")
    need("  seal9.py cdp (port one off) exit 1" in ls, "the TiffinBox port typed one off: exit 1")
    need(re.search(r"^  a validator event planted in a copy of the events: [1-9]\d* events - the check FAILS on it$", t, re.M) is not None, "a planted validator event: the 0-events check FAILS on it")
    need(re.search(r"a non-loopback TCP connect planted in a NetLog copy: .*every TCP connect to loopback: no", t) is not None, "a planted non-loopback TCP connect: the TCP verdict says no (a STOP line)")
    nv = re.search(r"^  NetLog verdict: every TCP connect to loopback: (\w+) · every UDP connect to loopback: (\w+)$", t, re.M)
    need(nv is not None and nv.group(1) == "yes", "the NetLog: every TCP connect to loopback (the dead proxy 127.0.0.1:9 and TiffinBox's port)")
    tcp = re.findall(r"^  NetLog TCP connect (\S+)\s+x\d+$", t, re.M)
    need("127.0.0.1:9" in tcp and "127.0.0.1:20970" in tcp and all(x.startswith("127.0.0.1:") for x in tcp), "the NetLog's TCP lines: %s" % ", ".join(tcp))
    need(re.search(r"^  chk08's read: TCP connect addresses .* · every TCP connect to loopback: yes$", t, re.M) is not None, "chk08's own read: every TCP connect to loopback")
    need(re.search(r"^  chk08's read: UDP connects \d+ ", t, re.M) is not None, "chk08's read of the UDP connects printed (as found, not asserted)")
    need(re.search(r"netlog\.py exit 0 \(cannot fail: shown once\)", t) is not None and "127.0.0.1 only: yes" in t, "Course 6's netlog.py on the plant's NetLog: \"127.0.0.1 only: yes\", exit 0 - it cannot fail")
    bh = re.findall(r"^  bundle host (\S+) x(\d+)$", t, re.M)
    bc = re.search(r"^  bundle hosts: (\d+) distinct bare names \((\d+) with the scheme apart, BLUE's form\) · validator\.swagger\.io x(\d+) · .* md5 ([0-9a-f]{32}) = BLUE's filed list's count-and-host lines, sorted, ([0-9a-f]{32}): (\w+)$", t, re.M)
    need(bc is not None and bc.group(6) == "equal", "the bundle census in BLUE's form = BLUE's filed list, line for line (md5 %s)" % (bc.group(4)[:8] if bc else "-"))
    need(bc is not None and int(bc.group(1)) == len(bh) and all(not re.match(r"^[a-z]+://", h) for h, _ in bh), "the bundle's hosts: %s distinct, printed bare (no scheme)" % (bc.group(1) if bc else "-"))
    need(bc is not None and bc.group(3) == "3" and bc.group(2) == "21", "validator.swagger.io x%s in the bundle (BLUE's 3), %s lines in BLUE's form (BLUE's 21)" % (bc.group(3) if bc else "-", bc.group(2) if bc else "-"))
    need("  a host printed with its scheme (the harness's plant): refused (a scheme)" in ls, "a host printed with its scheme: refused")
    need(re.search(r"^  seal9\.py cdp \(before\) exit 0$", t, re.M) is not None, "before's page: seal9.py cdp exit 0")
    need(re.search(r"^  the page's requests, host and path, before and after: equal ", t, re.M) is not None, "(f) the page's request lists before and after equal, host and path")
    need(re.search(r"^  every request of the page's session a GET \(the access log, no time field\): GET \d+ $", t, re.M) is not None, "every request of the page's session a GET")
    need(len(re.findall(r"^  Chrome \w+ stopped by Browser\.close", t, re.M)) == 3, "three Chromes, each stopped by Browser.close, pid gone, profile removed")
    need(len(re.findall(r"^  the dead proxy: .* exit 7 \(refused\)", t, re.M)) == 3, "the dead proxy refused before every Chrome start")
    print("  the green line and the red line in the same receipt: %s" % ("yes" if ex[:1] == ["0"] and "  seal9.py cdp (the plant) exit 1" in ls else "NO"))
    if bc: val("bundle_hosts_bare", bc.group(1)); val("bundle_lines_blue_form", bc.group(2)); val("bundle_validator", bc.group(3))
    val("judge", "green"); val("plant", "red"); val("second_red", "red"); val("validator_events", 0); val("validator_badges", 0)

def c_ops(p):
    ls = lines(p); t = "\n".join(ls)
    for side, title in (("after", "TiffinBox 1.0 OAS 3.1"), ("before", "OpenAPI definition v0 OAS 3.1")):
        m = re.search(r"^  dom %s: title \"(.*)\" · operations (\d+) · tags (\d+) \((.*)\) · tags = the document's: (\w+) · dashboard operations (\d+) · probe operations (\d+)" % side, t, re.M)
        need(m is not None and m.group(1) == title and m.group(2) == "13" and m.group(3) == "6" and m.group(5) == "yes" and m.group(6) == "0" and m.group(7) == "0",
             "%s's page: title \"%s\", 13 operations in 6 tags = the document's, none of DashboardPage's, none of the harness's" % (side, m.group(1) if m else "-"))
    s = re.search(r"^  dom after: the Servers control: (.*)$", t, re.M)
    need(s is not None and "<port>" in s.group(1) and not re.search(r":\d{4,5}", s.group(1)), "the Servers control's text masked (%s)" % (s.group(1) if s else "-"))
    need(re.search(r"the detector \"the page shows 13 operations\" on the plant page's DOM: operations 0 -> FAIL", t) is not None, "the detector run on the plant page's DOM FAILS (it can fail: R.276 + R.374)")
    val("page_title", "TiffinBox/1.0"); val("page_ops", 13); val("page_tags", 6); val("before_title", "OpenAPI_definition/v0")

def dom(side, dp, sp):
    d = json.load(open(dp)) if os.path.exists(dp) else {}
    s = json.load(open(sp, encoding="utf-8"))
    dt = sorted({t for v in s["paths"].values() for o in v.values() for t in o.get("tags", [])})
    ops = d.get("ops") or []; tags = d.get("tags") or []
    print("  dom %s: title \"%s\" · operations %d · tags %d (%s) · tags = the document's: %s · dashboard operations %d · probe operations %d" % (side, d.get("title"), len(ops), len(tags), ",".join(tags),
          "yes" if sorted(tags) == dt else "NO", sum("dashboard-page" in x for x in ops), sum("probe" in x or "u08" in x for x in ops)))
    if d.get("servers") is not None: print("  dom %s: the Servers control: %s" % (side, PM(" | ".join(d["servers"]))))
    for x in ops: print("  dom %s: operation %s" % (side, x))

TRY = {"request": re.compile(r"^  request: (GET|POST|PUT|PATCH|DELETE) (\S+) · accept (\S+) · Referer (\S+) · user agent (.+)$"),
       "response": re.compile(r"^  response: (\d{3}) · Content-Type (\S+) · body (\d+) B md5 ([0-9a-f]{32})$"),
       "shows": re.compile(r"^  the page shows: status \"(.*?)\" · request URL \"(.*?)\" · curl \"(.*)\"$"),
       "access": re.compile(r"^  access: (\S+) (\S+?)-? (\d{3}) (\S+)(?: (\S+))?$"),
       "curl": re.compile(r"^  curl GET \S+ on the same JVM: body (\d+) B md5 ([0-9a-f]{32})$"),
       "media": re.compile(r"^  the document's response media types for (\S+): (.*)$")}
def tryparse(ls):
    R = collections.defaultdict(list)
    for l in ls:
        for k, rx in TRY.items():
            m = rx.match(l)
            if m: R[k].append(m.groups())
        if (l.startswith("  request:") or l.startswith("  response:") or l.startswith("  access:")) and not any(rx.match(l) for rx in TRY.values()): fail("a tryit line this checker cannot parse: %r" % l[:120])
    return R
def trycheck(ls, db):
    t = "\n".join(ls); R = tryparse(ls)
    need(re.search(r"^  state before: \{\"open\":false,", t, re.M) is not None, "%s: the operation opened from a CLOSED state (state before printed)" % db)
    c1 = re.search(r"^  click 1 outcome: (.*)$", t, re.M); c2 = re.search(r"^  click 2 (?:outcome: (opened)|\(\.opblock-control-arrow\): (not clicked .*))$", t, re.M)
    need(c1 is not None and c2 is not None, "%s: the expand control measured both ways: click 1 %s · click 2 %s" % (db, c1.group(1) if c1 else "-", (c2.group(1) or c2.group(2)) if c2 else "-"))
    need(re.search(r"^  click 1 \(\.opblock-summary-control\), state after: \{\"open\":(true|false)", t, re.M) is not None, "%s: the state after click 1 filed" % db)
    need(re.search(r"^  requests after the click: 1$", t, re.M) is not None and len(R["request"]) == 1, "%s: exactly ONE request after the click" % db)
    if R["request"]:
        m, u, acc, ref, ua = R["request"][0]
        need(m == "GET" and u.endswith("/api/v1/customers/Ravi"), "%s: the request: GET .../api/v1/customers/Ravi" % db)
        need(acc == "*/*" and ref.endswith("/swagger-ui/index.html") and "HeadlessChrome/" in ua, "%s: accept */* · Referer the page · user agent HeadlessChrome" % db)
    if R["response"] and R["curl"]:
        st, ct, n, md = R["response"][0]
        need(st == "200" and ct == "application/json", "%s: the answer 200 application/json" % db)
        need((n, md) == R["curl"][0], "%s: Network.getResponseBody's md5 = a curl GET of the same address on the same JVM (%s)" % (db, md[:8]))
    else: fail("%s: the response / curl lines" % db)
    if R["shows"]:
        need(R["shows"][0][0] == "200" and R["shows"][0][1].endswith("/api/v1/customers/Ravi") and "-H 'accept: */*'" in R["shows"][0][2] and "<port>" in R["shows"][0][2], "%s: the page shows 200 (the response row's cell), the request URL, its curl line (port masked)" % db)
    else: fail("%s: the page's shown lines" % db)
    a0 = re.search(r"^  the access log before the click: (\d+) lines$", t, re.M); a1 = re.search(r"^  the access log after the click: (\d+) lines \(\+(\d+)\)$", t, re.M)
    need(a0 is not None and a1 is not None and a1.group(2) == "1" and len(R["access"]) == 1, "%s: the access log +1 line" % db)
    if R["access"]: need(R["access"][0][:3] == ("GET", "/api/v1/customers/Ravi", "200"), "%s: the access log's line: %s" % (db, " ".join(R["access"][0][:4])))
    md = R["media"][0][1] if R["media"] else ""
    need("200 */*" in md, "%s: the failure receipt: the document says */* for the 200 (%s), the request asks */*, TiffinBox answers application/json" % (db, md))
    return R
def c_tryit(p):
    ls = lines(p); t = "\n".join(ls)
    main = [l for l in ls if not l.startswith("  old: ")]
    R = trycheck(main, "h2")
    need(re.search(r"^  cdp9\.mjs tryit exit 0$", t, re.M) is not None, "cdp9.mjs tryit exit 0")
    old = [l[7:] for l in ls if l.startswith("  old: ")]
    need(any(re.match(r"^request: GET \S+/customers/Ravi · accept \*/\*", l) for l in old) and any(re.match(r"^access: GET /customers/Ravi-? 200 ", l) for l in old), "the near miss (1/1): the old route's GET-by-name, one request, 200, its access line")
    need(re.search(r"^  the status reader pointed at the table's header", open(sibling(p, "sealed") or p, encoding="utf-8").read(), re.M) is not None, "the status-reader plant ran (its line in the sealed capture)")
    st = open(sibling(p, "sealed"), encoding="utf-8").read() if sibling(p, "sealed") else ""
    need(re.search(r"the status reader pointed at the table's header \(RED #13's defect\): \"Code\" -> FAIL", st) is not None, "the status reader pointed at the header reads \"Code\" -> FAIL (RED #13's defect caught)")
    need(re.search(r"the operation already open: cdp9\.mjs tryit exit 3 · already open - the step was skipped", st) is not None, "the operation already open: exit 3")
    need(re.search(r"a wait condition never met .*: cdp9\.mjs rendered exit 4 · rendered: DEADLINE", st) is not None, "a wait condition never met: exit 4, the state printed")
    q = sibling(p, "tryitpg")
    if q and R["response"]:
        P = tryparse(lines(q))
        need(P["response"] and P["response"][0] == R["response"][0] and P["request"] and P["request"][0][:4] == R["request"][0][:4], "PostgreSQL's tryit: the request, status and body md5 equal to H2's")
        val("pg_equal", "yes")
    c1 = re.search(r"^  click 1 outcome: (\S+)", t, re.M)
    if R["response"]: val("status", R["response"][0][0]); val("type", R["response"][0][1]); val("body_md5", R["response"][0][3][:8])
    val("click1", c1.group(1) if c1 else "-"); val("requests", len(R["request"])); val("accept", "any")
def c_tryitpg(p):
    ls = lines(p); t = "\n".join(ls)
    need(re.search(r"Database: <url> \(PostgreSQL 18\.6\)", t) is not None, "the database: PostgreSQL 18.6 (Flyway's line)")
    trycheck(ls, "pg")
    need(re.search(r"^  Ravi's row by psql \(the second client\): Ravi 2 \d+ \w+ v\d+ \(psql in c9u08-pg", t, re.M) is not None, "Ravi's row read by psql, named on its line")
    need(re.search(r"^  every request of the page's session a GET: GET \d+ $", t, re.M) is not None, "every request of the page's session a GET")
    val("pg", "measured")
def c_versions(p):
    ls = lines(p); t = "\n".join(ls)
    for j in ("springdoc-openapi-starter-webmvc-ui-3.2.1.jar", "swagger-core-3.0.0.jar", "swagger-ui-5.35.1.jar", "spring-boot-4.1.3.jar"):
        need(j in t, "BOOT-INF/lib: %s" % j)
    need(re.search(r"Boot's banner: :: Spring Boot :: \(v4\.1\.3\)", t) is not None, "Boot's banner: v4.1.3")
    need("the webjar's pom.properties: version=5.35.1" in t, "the webjar's pom.properties: version=5.35.1")
    c = re.search(r"Browser\.getVersion: product Chrome/(\S+) · .* - yours will differ$", t, re.M)
    need(c is not None, "Chrome's version printed with \"yours will differ\" (%s)" % (c.group(1) if c else "-"))
    pv = re.search(r"the page's own version string \(window\.versions, by eval\): (.*)$", t, re.M)
    print("  the page's own version string: %s" % (pv.group(1) if pv else "-"))
    val("springdoc", "3.2.1"); val("swagger_core", "3.0.0"); val("swagger_ui", "5.35.1"); val("boot", "4.1.3"); val("chrome", c.group(1) if c else "-")

def c_committed(p):
    ls = lines(p); t = "\n".join(ls)
    m = re.search(r"^  bytes (\d+) \(wc -c\) · md5 ([0-9a-f]{32}) · servers member: (\w+) · U07's file (\d+) B$", t, re.M)
    need(m is not None and m.group(3) == "absent", "(i) the file: %s bytes, no servers" % (m.group(1) if m else "-"))
    if m:
        pred = int(m.group(4)) - 9 + 1
        need(int(m.group(1)) == pred, "(i) the size: U07's %s B, the arithmetic (title -9, version +1) predicts %d, wc -c says %s" % (m.group(4), pred, m.group(1)))
    need(re.search(r"re-applied to the file: byte-identical$", t, re.M) is not None, "(i) the fixed rule re-applied reproduces the file")
    need(re.search(r"^  the file against the served document, servers removed \(the after capture's python, live\): pg byte-identical · h2 byte-identical$", t, re.M) is not None, "(i) the file = the served document with servers removed, on PostgreSQL and H2")
    dl = [l.strip() for l in ls if l.startswith("    -") or l.startswith("    +")]
    need(dl == ['-    "title": "OpenAPI definition",', '-    "version": "v0"', '+    "title": "TiffinBox",', '+    "version": "1.0"'], "(i) the file's diff against U07's: exactly the two info lines (%d lines)" % len(dl))
    need(re.search(r"^  package:  OpenApiSpecTest tests 1 failures 0 errors 0 skipped 0$", t, re.M) is not None and re.search(r"^  twin:  OpenApiSpecTest tests 1 failures 0 errors 0 skipped 0$", t, re.M) is not None, "(ii) OpenApiSpecTest PASSES on the regenerated file, in package and in the Docker-free twin")
    need(re.search(r'^  MockMvc\'s servers, as the test printed it: \[\{"url":"http://localhost"', t, re.M) is not None and re.search(r'^  the socket\'s servers, .*127\.0\.0\.1:<port>', t, re.M) is not None, "(ii) MockMvc's servers http://localhost beside the socket's (masked)")
    for k, n, w in (("iii", "the stale file", "TiffinBox True · OpenAPI definition True"), ("iv", "the drifted file", "mealsPerDay True"), ("v", "the drifted code", "maxLength True")):
        sec = t.split("== (%s)" % k)[1].split("\n== ")[0] if "== (%s)" % k in t else ""
        need(re.search(r"mvn test -Dtest=OpenApiSpecTest exit 1 · Tests run: 1, Failures: 1, Errors: 0", sec) is not None, "(%s) %s: the test FAILS (exit 1, Failures 1)" % (k, n))
        need("its FAIL line: theServedDocumentIsTheCommittedOne" in sec and re.search(r"the assertion: expected", sec) is not None, "(%s) its FAIL line and the expected ... but was ... assertion kept" % k)
        need(w in sec, "(%s) the report names what moved (%s)" % (k, w))
    need(re.search(r"^  cp: .*before/tiffinbox-web/src/test/resources/openapi/tiffinbox\.json -> ", t, re.M) is not None, "(iii) the stale file's cp printed")
    if m: val("spec_bytes", m.group(1)); val("spec_md5", m.group(2)[:8])
    val("test", "PASS"); val("stale", "FAIL"); val("drift_file", "FAIL"); val("drift_code", "FAIL")
KINDS = re.compile(r"^  \((a|b)\) KINDS (\d+): (.*)$")
DIS = re.compile(r"^  \((a|b)\) DISAGREEMENTS (\d+)$")
ROWL = re.compile(r"^  \((a|b)\) +(\d+) (\S.*?)\s+spec: (.*?) \| wire: (.*)$")
PAIR = re.compile(r"^  pair (\S+) \| ([A-Z]+) (\S+) \| body (.*) \| key header (yes|no) -> (\d{3}) (\S+) \| (.*)$")
def wiredir(p, db):
    return os.path.join(os.path.dirname(os.path.abspath(p)), ".harness", "work", "wire-%s" % db)
def rederive(spec, W):
    """this checker's own reading of the same filed pairs: each row's two sides, independently of specwire9.py"""
    cust = spec["components"]["schemas"]["Customer"]; out = {}
    omit = {"mealsPerDay": "post-nomeals", "pricePerMeal": "post-noprice", "mealType": "post-notype", "name": "post-noname"}
    out["required"] = (sorted(cust.get("required", [])), sorted(k for k, n in omit.items() if 400 <= W[n]["response"]["status"] < 500))
    out["names"] = (sorted(cust["properties"]), sorted(json.loads(W["one"]["response"]["body"]).keys()))
    out["minLength"] = (cust["properties"]["name"].get("minLength"), W["post-blank"]["response"]["status"])
    allops = [(p, m, o) for p, v in spec["paths"].items() for m, o in v.items()]
    out["star"] = (sum(1 for _, _, o in allops if any("*/*" in r.get("content", {}) for c, r in o["responses"].items() if c.startswith("2"))), len(allops))
    out["errors"] = (sum(1 for _, _, o in allops for c in o["responses"] if not c.startswith("2")), sorted({w["response"]["status"] for w in W.values() if w["response"]["status"] >= 400}))
    pz = spec["paths"]["/api/v1/customers/{name}/pauses"]["post"]
    out["key"] = (sum(1 for x in pz.get("parameters", []) if x["in"] == "header" and x["name"].lower() == "idempotency-key"), W["pause-nokey"]["response"]["status"], W["pause-nokey"]["response"]["body"])
    out["post"] = (sorted(spec["paths"]["/customers"]["post"]["responses"]), W["post-ok"]["response"]["status"])
    fs = list(spec["paths"]["/customers/feed"]["get"]["responses"]["200"]["content"].items())
    out["feed"] = (fs[0][0], fs[0][1]["schema"].get("$ref"), sorted(spec["components"]["schemas"].get("SseEmitter", {}).get("properties", {})), W["feed"]["response"]["body"].splitlines()[:1])
    return out
def wirecheck(p, db, ls, t):
    P = [PAIR.match(l) for l in ls if l.startswith("  pair ")]
    if any(x is None for x in P): fail("a pair line this checker cannot parse")
    P = [x for x in P if x]
    names = [x.group(1) for x in P]
    need(names == ["one", "list", "post-ok", "post-nomeals", "post-noprice", "post-notype", "post-noname", "post-blank", "pause-nokey", "pause-key", "patch-json-patch", "feed"],
         "%s: the twelve filed pairs, in BLUE's order, each request body printed (%d)" % (db, len(P)))
    need([x.group(1) for x in P if x.group(5) == "yes"] == ["pause-key"], "%s: the key header sent by pause-key alone" % db)
    st = {x.group(1): x.group(6) for x in P}
    need([st.get(n) for n in ("post-ok", "post-nomeals", "post-noprice", "post-notype", "post-noname", "post-blank")] == ["201", "400", "400", "400", "400", "400"], "%s: post-ok 201, the five refused 400 (the failure receipt's negation: all four -> 201)" % db)
    need(st.get("pause-key") == "201" and st.get("patch-json-patch") == "200" and st.get("feed") == "200" and st.get("one") == "200", "%s: pause-key 201, the JSON Patch 200, the feed 200, the public read 200" % db)
    K = {m.group(1): (int(m.group(2)), m.group(3)) for m in (KINDS.match(l) for l in ls) if m}
    Dn = {m.group(1): int(m.group(2)) for m in (DIS.match(l) for l in ls) if m}
    rows = collections.defaultdict(list)
    for l in ls:
        m = ROWL.match(l)
        if m: rows[m.group(1)].append((m.group(3), m.group(4), m.group(5)))
    need("a" in K and "a" in Dn and len(rows["a"]) == Dn["a"], "%s: (a) KINDS and DISAGREEMENTS read, one row line per disagreement (%d)" % (db, len(rows["a"])))
    need(re.search(r"^  \(a\) exit 1$", t, re.M) is not None, "%s: (a) exit 1 (rows present)" % db)
    wd = wiredir(p, db); sp = os.path.join(os.path.dirname(os.path.abspath(p)), ".harness", "work", "spec-%s.json" % db)
    if not (os.path.isdir(wd) and os.path.exists(sp)): fail("%s: the filed pairs or the document are not beside the capture" % db); return K, Dn, rows, None
    W = {}
    for f in sorted(os.listdir(wd)):
        w = json.load(open(os.path.join(wd, f))); W[w["name"]] = w
    spec = json.load(open(sp))
    X = rederive(spec, W)
    need(W["pause-nokey"]["response"]["status"] == 400 and "idempotency-key-missing" in W["pause-nokey"]["response"]["body"], "%s: the keyless pause 400, its type idempotency-key-missing (the filed body)" % db)
    print("  %s re-derived (this checker, the same filed pairs): required spec %s | wire %s · names %s | %s · name minLength %s | blank -> %s · */* on %d of %d operations · error responses %d | wire %s · the pause route's key header named %d times | keyless -> %s · POST /customers documented %s | wire %s · the feed %s %s %s | first line %s" % (
          db, X["required"][0], X["required"][1], len(X["names"][0]), len(X["names"][1]), X["minLength"][0], X["minLength"][1], X["star"][0], X["star"][1], X["errors"][0], X["errors"][1],
          X["key"][0], X["key"][1], X["post"][0], X["post"][1], X["feed"][0], X["feed"][1], X["feed"][2], X["feed"][3]))
    ra = {r[0]: r for r in rows["a"]}
    need("required" in ra and json.dumps(X["required"][0]).replace('"', "'") == ra["required"][1].strip() and json.dumps(X["required"][1]).replace('"', "'") == ra["required"][2].strip(),
         "%s: the required row = the re-derived sides (spec %s, wire %s) - the failure receipt" % (db, X["required"][0], X["required"][1]))
    need(X["required"][0] == ["mealType", "name"] and X["required"][1] == FOUR, "%s: required 2 of 4 in the spec; the wire refuses each of the four omitted" % db)
    need(X["names"][0] == X["names"][1] == FOUR and "property names" not in ra, "%s: property names agree 4 of 4 (no row)" % db)
    need("name minLength" in ra and X["minLength"] == (0, 400), "%s: name minLength 0 against the blank name's 400" % db)
    need(X["star"] == (12, 13), "%s: */* on 12 of 13 operations (python over the saved document; the feed's text/event-stream agrees)" % db)
    need(X["errors"][0] == 0 and "error responses" in ra, "%s: 0 error responses documented against %s answered" % (db, X["errors"][1]))
    need(X["key"][0] == 0 and X["key"][1] == 400 and any(k.endswith(" header") for k in ra), "%s: the Idempotency-Key named 0 times against the keyless 400" % db)
    need(X["post"] == (["200"], 201) and "post-ok status" in ra, "%s: POST /customers documented 200, the wire 201" % db)
    need(X["feed"][1] == "#/components/schemas/SseEmitter" and X["feed"][3] == [":listening"] and "feed schema" in ra, "%s: the feed's SseEmitter against :listening" % db)
    kinds = K["a"][1].split("; ")
    need(K["a"][0] == len(kinds) == len({kind(r[0]) for r in rows["a"]}), "%s: (a) KINDS %d = the distinct kinds of its rows" % (db, K["a"][0]))
    print("  %s (a): %d kinds · %d rows · kinds: %s" % (db, K["a"][0], Dn["a"], K["a"][1]))
    after_ = re.search(r"^  the second client after: count (\d+) .* · keys (\d+) .* · Ravi (.*)$", t, re.M); before_ = re.search(r"^  the second client before: count (\d+) .* · keys (\d+) .* · Ravi (.*)$", t, re.M)
    need(before_ is not None and after_ is not None and int(after_.group(1)) == int(before_.group(1)) + 1, "%s: the second client: customers %s -> %s (the valid POST's one row)" % (db, before_.group(1) if before_ else "-", after_.group(1) if after_ else "-"))
    need(before_ is not None and after_ is not None and before_.group(2) == "0" and after_.group(2) == "1", "%s: the key table 0 -> 1 (pause-key's own)" % db)
    pj = json.loads(W["patch-json-patch"]["response"]["body"])
    need(after_ is not None and before_ is not None and after_.group(3) == before_.group(3) and after_.group(3).split(" ")[:2] == ["Ravi", str(pj["mealsPerDay"])],
         "%s: the JSON Patch (mealsPerDay -> 2) is a no-op on Ravi, whose seed row already says 2: the second client reads the row unchanged, version and all (%s), and the patch's own answer says %s" % (db, after_.group(3)[:22] if after_ else "-", pj["mealsPerDay"]))
    rr = {m.group(1): m.group(2) for m in re.finditer(r"^  row (Blue\dr\S+): (.*)$", t, re.M)}
    ok1 = [k for k, v in rr.items() if k.startswith("Blue1") and not v.startswith("no row")]
    nos = [k for k, v in rr.items() if not k.startswith("Blue1") and v.startswith("no row")]
    need(len(ok1) == 1 and len(nos) == 3, "%s: the valid POST's customer is there (1 row), the refused names are not (%d of 3; the nameless two have no name to ask)" % (db, len(nos)))
    return K, Dn, rows, st
def kind(k):
    for suf, name in ((" status", "success/error status"), (" media", "response media type"), (" header", "required header")):
        if k.endswith(suf): return name
    return k
def c_diff(p):
    ls, R, heads, asks = load(p); t = "\n".join(ls)
    K, Dn, rows, st = wirecheck(p, "h2", ls, t)
    need("b" in K and "b" in Dn and len(rows["b"]) == Dn["b"], "(b) KINDS and DISAGREEMENTS read, one row line per disagreement (%d)" % len(rows["b"]))
    if "a" in K and "b" in K:
        extra = sorted({kind(r[0]) for r in rows["b"]} - {kind(r[0]) for r in rows["a"]})
        need(K["b"][0] == K["a"][0] + len(extra) and all(e.startswith("generated client") for e in extra), "(b): %d kinds = (a)'s %d + the generated client's (%s) - the probe's filed source, U10's tool's output" % (K["b"][0], K["a"][0], extra))
        need(rows["b"][:len(rows["a"])] == [r for r in rows["a"]], "(b)'s first rows are (a)'s")
        val("kinds_b", K["b"][0]); val("rows_b", Dn["b"])
    pa = re.search(r"^  plant \(a\) KINDS (\d+):", t, re.M); pb = re.search(r"^  plant \(b\) KINDS (\d+):", t, re.M)
    pda = re.search(r"^  plant \(a\) DISAGREEMENTS (\d+)$", t, re.M); pdb = re.search(r"^  plant \(b\) DISAGREEMENTS (\d+)$", t, re.M)
    need(pa and pb and pda and pdb and int(pa.group(1)) == K["a"][0] + 1 and int(pb.group(1)) == K["b"][0] + 1 and int(pda.group(1)) == Dn["a"] + 1 and int(pdb.group(1)) == Dn["b"] + 1,
         "the plant (mealType -> meal_type) moves the kinds and the rows by exactly one in (a) and (b) (R.508)")
    need(re.search(r"^  empty: refused: empty spec or empty wire dir$", t, re.M) is not None and re.search(r"^  empty: exit 2$", t, re.M) is not None, "an empty wire directory: refused, exit 2")
    bv = re.search(r"^  this run's \(b\) output md5 ([0-9a-f]{32}) · its rows against BLUE's: rows (\d+) vs BLUE's (\d+), the row keys (\w+)$", t, re.M)
    bf = re.search(r"^  BLUE's filed \(b\) output, for the comparison: .* md5 ([0-9a-f]{32})$", t, re.M)
    need(bv is not None and bv.group(4) == "equal" and bf is not None and bv.group(1) == bf.group(1), "(b) byte-equal to BLUE's filed run (output md5 %s = the filed diff-run1.txt's; rows %s = %s)" % (bv.group(1)[:8] if bv else "-", bv.group(2) if bv else "-", bv.group(3) if bv else "-"))
    # the witness: which handler answers the addresses springdoc added, and the static handler's own
    W = {a["p"]: a for a in asks if a["lab"].startswith("w-")}
    for k in ("/v3/api-docs", "/v3/api-docs.yaml", "/v3/api-docs/swagger-config", "/swagger-ui.html", "/swagger-ui/index.html", "/nowhere"):
        need(k in W, "the request witness asked %s" % k)
    hd = {k: ([s["h"] for s in v["srv"] if s["disp"] is None] or ["none"])[0] for k, v in W.items()}
    print("  the request witness on after/: %s" % " · ".join("%s -> %s %s" % (k, W[k]["st"], hd[k]) for k in W))
    need(hd.get("/nowhere") == "ResourceHttpRequestHandler" and W.get("/nowhere", {}).get("st") == "404", "after/: /nowhere still the static handler's 404 - the old request that reaches the resource handlers")
    need(hd.get("/swagger-ui/index.html") == "ResourceHttpRequestHandler", "after/: the page's resources are served by a resource handler (Swagger UI's webjar)")
    need(W.get("/v3/api-docs", {}).get("st") == "200" and hd.get("/v3/api-docs", "").startswith("OpenApiWebMvcResource") and W.get("/v3/api-docs/swagger-config", {}).get("st") == "200", "after/: /v3/api-docs -> 200 by springdoc's handler (%s)" % hd.get("/v3/api-docs"))
    m = re.search(r"the document on this harness-joined start: paths (\d+), of them /probe/ (\d+)", t)
    need(m is not None and int(m.group(2)) > 0, "the harness-joined start documents the harness's routes too (%s /probe/ paths): no claim reads that document" % (m.group(2) if m else "-"))
    V = u07v()
    need(K.get("a", [None])[0] == int(V.get("diff.kinds_a", -1)) and Dn.get("a") == int(V.get("diff.rows_a", -1)) and K.get("b", [None])[0] == int(V.get("diff.kinds_b", -1)) and Dn.get("b") == int(V.get("diff.rows_b", -1)),
         "(a) %s kinds / %s rows and (b) %s / %s = U07's values block (read at run time): the bean moved no row" % (K.get("a", ["-"])[0], Dn.get("a"), K.get("b", ["-"])[0], Dn.get("b")))
    q = sibling(p, "diffpg")
    if q:
        lp = lines(q)
        Ph = {m.group(1): (m.group(6), m.group(7)) for m in (PAIR.match(l) for l in ls) if m}
        Pp = {m.group(1): (m.group(6), m.group(7)) for m in (PAIR.match(l) for l in lp) if m}
        need(Ph == Pp, "every request's status and content type equal on H2 and PostgreSQL (the diffpg capture, %d)" % len(Pp))
        need([ROWL.match(l).groups()[2:] for l in ls if ROWL.match(l) and l.startswith("  (a)")] == [ROWL.match(l).groups()[2:] for l in lp if ROWL.match(l) and l.startswith("  (a)")], "(a)'s rows equal on H2 and PostgreSQL")
        val("pg_equal", "yes")
    val("kinds_a", K.get("a", ["-"])[0] if K.get("a") else "-"); val("rows_a", Dn.get("a", "-")); val("required", "2/4"); val("star", "12/13"); val("errors_documented", 0); val("key_named", 0)
    val("witness", "/nowhere")


MVL = re.compile(r"^  (before|after) \| ([A-Z]+ \S+(?: \[[\w-]+\])?) -> (\d{3}) (\S*) (\d+) · Allow \{([^}]*)\} · Accept-Patch \{([^}]*)\} · Location \{([^}]*)\} · body (\S+)$")
MOVES = ["GET /v3/api-docs", "GET /v3/api-docs.yaml"]
def c_moved(p):
    ls = lines(p); M = {}
    for l in ls:
        m = MVL.match(l)
        if m: M[(m.group(1), m.group(2))] = m.groups()[2:]
        elif l.startswith("  before |") or l.startswith("  after |"): fail("a moved line this checker cannot parse: %r" % l[:120])
    qs = sorted({k[1] for k in M})
    need(len(qs) == 14 and all(("before", q) in M and ("after", q) in M for q in qs), "every request asked on both trees (%d: U07's twelve + the YAML + swagger-config)" % len(qs))
    moved = [q for q in qs if M.get(("before", q)) != M.get(("after", q))]
    need(sorted(moved) == sorted(MOVES), "moved: exactly the document and its YAML (S9.37, the one named compatible move - the document's info): %s" % moved)
    for q in moved: print("  MOVED (compatible, the document's info, named in this unit) %s: before %s -> after %s" % (q, " ".join(M[("before", q)][:3]) + " body " + M[("before", q)][-1], " ".join(M[("after", q)][:3]) + " body " + M[("after", q)][-1]))
    for q in moved: need(M[("before", q)][:2] == M[("after", q)][:2], "%s: status and type equal, the body (size and md5) moved" % q)
    for q in ("GET /v3/api-docs/swagger-config", "GET /swagger-ui.html", "GET /swagger-ui/index.html"): need(q in qs and q not in moved, "%s: equal on both trees" % q)
    a = M.get(("after", "PATCH /customers")); b = M.get(("before", "PATCH /customers"))
    need(a is not None and b is not None and a[0] == b[0] == "405" and a[3] == b[3] == "GET,POST", "the pinned sentence: a PATCH to /customers answers 405, Allow the set {GET, POST}, on before and after/")
    un = [q for q in qs if q not in moved]
    print("  unmoved (%d): %s" % (len(un), " · ".join(un)))
    val("asked", len(qs)); val("moved", len(moved)); val("unmoved", len(un)); val("patch_customers", "405:" + (a[3].replace(",", "+") if a else "-"))

def c_seven(p):
    ls = lines(p); t = "\n".join(ls)
    S = re.search(r"the expected ([0-9a-f]{32})", t)
    if not S: fail("the expected hash"); return
    for side in ("before", "after"):
        m = re.search(r"^  %s: the seven ([0-9a-f]{32}) " % side, t, re.M)
        need(m is not None and m.group(1) == S.group(1), "%s: the seven = %s" % (side, S.group(1)[:8]))
    need("  before -> after/: equal" in ls, "the seven: before = after/")
    need(u07v().get("seven.seven") == S.group(1)[:8], "= U07's values block (seven=%s)" % u07v().get("seven.seven"))
    print("  R.511: not a witness for this change - the seven do not reach springdoc's handlers or the page's files, so they stay equal")
    val("seven", S.group(1)[:8])
def c_surface(p):
    ls = lines(p); t = "\n".join(ls)
    S = re.search(r"the expected ([0-9a-f]{32})", t)
    if not S: fail("the expected hash"); return
    for side in ("before", "after"):
        m = re.search(r"^  %s: the old surface ([0-9a-f]{32}) \((\d+) requests, (\d+) lines\)$" % side, t, re.M)
        need(m is not None and m.group(1) == S.group(1), "%s: the old surface = %s - %s requests, %s lines" % (side, S.group(1)[:8], m.group(2) if m else "-", m.group(3) if m else "-"))
    need("  before -> after/: equal" in ls and not any(l.startswith("    moved: ") for l in ls), "the old surface: before = after/, no line moved")
    need(u07v().get("surface.surface") == S.group(1)[:8], "= U07's values block (surface=%s)" % u07v().get("surface.surface"))
    need(any("planted: the seven" in l and "unchanged: yes" in l and "moved: yes" in l for l in ls), "the ETag plant (the harness's): the seven unchanged, the old surface moved")
    need(any("planted:" in l and " 0 (reader exit 3)" in l for l in ls), "the ETag plant: the feed answers nothing (the reader's exit 3 at its alarm, 0 bytes)")
    print("  R.511: witness for this change: the requests springdoc's four handlers and the resource handlers answer (the document, its YAML, swagger-config, the page and its files - the info, redirect, sealed and moved captures); not a witness for this change: the old surface's thirteen and the seven - they stay equal because they do not reach it")
    val("surface", S.group(1)[:8])
def c_inert(p):
    ls = lines(p); t = "\n".join(ls)
    for f in (".r-after.new", ".r-redirect.new", ".r-before.new", ".r-diff.new"):
        m = re.search(r"^  %s: sent the key: (\d+) · did not: (\d+)$" % re.escape(f), t, re.M)
        need(m is not None and m.group(1) == "0" and int(m.group(2)) > 0, "%s: no curl request sent the key header (%s sent none)" % (f, m.group(2) if m else "-"))
    m = re.search(r"^  wire-h2: requests (\d+) · with the key: (\S+)$", t, re.M)
    need(m is not None and m.group(1) == "12" and m.group(2) == "pause-key", "wire-h2: 12 filed requests, the key header on pause-key alone")
    b = re.search(r"the second client before: .* · keys (\d+) ", t); a = re.search(r"the second client after: .* · keys (\d+) ", t)
    need(b is not None and a is not None and b.group(1) == "0" and a.group(1) == "1", "the diff JVM: the key table 0 before the census, 1 after it (pause-key's own)")
    k = re.findall(r"\.r-sealed\.new \(the plant JVM\):.*key table rows(?: after)?:? (\d+)", t)
    need(k and all(x == "0" for x in k), "the plant JVM (harness-joined): the key table 0 rows (%s)" % ",".join(k))
    g = re.findall(r"every request of the page.s session a GET[^:]*: (.*)$", t, re.M)
    need(len(g) == 2 and all(re.fullmatch(r"GET \d+ ", x) for x in g), "the page's sessions (sealed, tryitpg): every request a GET, by the access log (%s)" % " | ".join(g))
    val("keyed", "pause-key"); val("key_rows", "0/1"); val("page_requests", "GET_only")

def c_exercise(p):
    ls = lines(p)
    def blk(v, sh):
        out = []; on = False
        for l in ls:
            if l.startswith("== the exercise, h2, %s, %s " % (v, sh)): on = True; continue
            if on and l.startswith("=="): break
            if on and not l.startswith("  guard before "): out.append(l[2:])
        return out
    want = {"broken": ("FAIL (clause 1)", "1", ("bash", "zsh")), "solved": ("PASS", "0", ("bash", "zsh")), "curl": ("FAIL (clause 1)", "1", ("bash",)),
            "meera": ("FAIL (clause 3)", "1", ("bash",)), "two": ("FAIL (clause 2)", "1", ("bash",)), "noexec": ("FAIL (clause 1)", "1", ("bash",)), "oldroute": ("PASS", "0", ("bash",))}
    for v, (pre, ex, shs) in want.items():
        for sh in shs:
            b = blk(v, sh)
            need(any(x.startswith(pre) for x in b), "%s (%s): %s" % (v, sh, pre))
            need("check exit %s" % ex in b, "%s (%s): check.sh's exit %s" % (v, sh, ex))
    for v in ("broken", "solved"): need(blk(v, "bash") == blk(v, "zsh"), "%s: bash and zsh -f print the same" % v)
    need(blk("broken", "bash") != blk("solved", "bash"), "broken != solved")
    rd = [l[len("  README: "):] for l in ls if l.startswith("  README: ")]; so = [l[len("  SOLUTION: "):] for l in ls if l.startswith("  SOLUTION: ")]
    need([x for x in blk("broken", "bash") if not x.startswith("check exit")] == rd, "exercise/README.md's What it prints = the broken run's lines")
    need([x for x in blk("solved", "bash") if not x.startswith("check exit")] == so, "SOLUTION.md's What it prints = the solved run's lines")
    o = [x for x in blk("oldroute", "bash") if x.startswith("PASS")]
    print("  the near miss that passes (the old route): %s" % (o[0] if o else "-"))
    val("exercise", "broken-FAIL1,solved-PASS,refused-4-FAIL,oldroute-PASS,bash+zsh,h2")

CAPS = {"tests": c_tests, "census": c_census, "after": c_after, "redirect": c_redirect, "tryitpg": c_tryitpg, "before": c_before, "info": c_info,
        "sealed": c_sealed, "ops": c_ops, "tryit": c_tryit, "versions": c_versions, "committed": c_committed, "diff": c_diff, "moved": c_moved,
        "seven": c_seven, "surface": c_surface, "inert": c_inert, "exercise": c_exercise}
def capture(nm, p):
    if nm in CAPS: CAPS[nm](p)
    else: fail("no checks for the capture %r" % nm)
    done()

def hashable(nm, p):
    for l in lines(p):
        if re.match(r"^  guard before ", l): continue
        if l.startswith("  Testcontainers' containers while verify ran"): continue
        if re.match(r"^  NetLog (UDP connect|URL asked)", l) or l.startswith("  NetLog verdict") or l.startswith("  chk08's read: UDP") or l.startswith("  seal9.py netlog exit"): continue   # Chrome's own background: printed as found, never asserted
        if l.startswith("  the browser: ") or l.startswith("  Chrome ") and " up: " in l: continue
        l = re.sub(r"^(  NetLog TCP connect \S+\s+)x\d+$", r"\1x<n>", l)
        l = re.sub(r"load1 [0-9.]+", "load1 <n>", l)
        l = re.sub(r"\bBLUE_RUN=\d+", "BLUE_RUN=<N>", l)
        l = re.sub(r"\b(Blue\d)r\d+\b", r"\1r<N>", l)
        l = re.sub(r"blue-specwire-\d+", "blue-specwire-<N>", l)
        l = re.sub(r"(\"(?:id|version|ts)\":)\d+", r"\1<n>", l) if nm == "diff" and l.startswith("  pair ") else l
        print(l)

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
        M = {"static": lambda: static(a[1], a[2]), "hook": lambda: print(HOOK), "exq": lambda: print(EXQ), "gloss": lambda: gloss(a[1]), "spoken": lambda: spoken(a[1], a[2]),
             "specmask": lambda: specmask(sys.stdin), "surefire": lambda: surefire(a[1]), "mapjson": lambda: mapjson(a[1], sys.stdin), "opsmap": lambda: ops(a[1], a[2]),
             "docfacts": lambda: docfacts(a[1], a[2], a[3]), "pairs": lambda: pairs(a[1]), "rowsvs": lambda: rowsvs(a[1], a[2]), "hashable": lambda: hashable(a[1], a[2]),
             "values": lambda: values(a[1], a[2]), "scfg": lambda: scfg(a[1]), "assets": lambda: assets(a[1]), "opid": lambda: opid(a[1]), "media": lambda: media(a[1], a[2]),
             "cdpev": lambda: cdpev(*a[1:]), "infodiff": lambda: infodiff(*a[1:]), "yamldiff": lambda: yamldiff(a[1], a[2]), "plantdoc": lambda: plantdoc(a[1], a[2], a[3]),
             "netread": lambda: netread(a[1]), "plantev": lambda: plantev(a[1], a[2]), "plantnet": lambda: plantnet(a[1], a[2]), "detector": lambda: detector(a[1]),
             "statusword": lambda: statusword(a[1]), "bare": lambda: bare(a[1]), "names": lambda: names(a[1]), "dom": lambda: dom(a[1], a[2], a[3])}
        if a and a[0] in M: M[a[0]]()
        elif a: capture(a[0], a[1])
        else: print(__doc__); sys.exit(2)
    except SystemExit:
        raise
    except Exception as e:
        print("FAIL the checker could not read its input (%s: %s) - a FAIL line, never a traceback" % (e.__class__.__name__, str(e)[:120])); sys.exit(1)
