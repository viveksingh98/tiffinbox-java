"""Course 9 unit 07's checker (python3 -I -B harness/chk07.py MODE ...). Every number the README may say is re-derived here from a capture's
own lines (or a shipped file), never typed. Each listing line a check reads is parsed by a named pattern or skipped by a named rule; a line
it cannot parse is a FAIL line and exit 1, never a traceback. The request-block reader is U06's (chk06.py: parse, hdr - copied from U06's
harness, which copied U05's and U03's; the cache sub-line dropped, as unit 07 reads no cache). The spec-vs-wire rows are specwire9.py's
(BLUE's instrument); this checker re-derives each row's two sides from the same filed pairs and the same document, independently.
Modes:
  static AFTER BEFORE      the carried prose slice, XFAM_S9S1's md5, the change's files, the pin's comment (S9.7, R.515), the test (no knob),
                           the committed file (no servers), the stale sentences (R.250/R.453), the anchor-note form
  hook | exq               print the spoken lines (typed ONCE, here; asserted against the brief's bytes by spoken)
  gloss README             U06's gloss called back, none re-glossed (flag 4)
  spoken HOOK EXQ          the spoken lines: byte-equal to S2B :158 / :166-:167, words, digits, spellings, statuses, Hinglish, dur9
  specmask                 stdin: a document; prints its servers with the port masked
  mapjson SIDE | ops MAP SPEC | docfacts RAW OUT FILE | pairs DIR | rowsvs MINE BLUE | jars LIBDIR | surefire XML   the receipts' small readers
  <capture> FILE           one capture's checks; prints ok/FAIL lines and one VALUES line
  hashable NAME FILE       the capture with its load-dependent lines dropped and the run's own name tag masked, for receipts.md5
  values README VALS       README.md's values block = this run's VALUES lines"""
import collections, hashlib, json, os, re, sys, zipfile

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
HOOK = "TiffinBox's own spec says a new customer's meals are optional. Leave them out, and TiffinBox answers four hundred."
EXQ = "Your turn: the spec says meals are optional. Make the spec require them, then check it against the wire."
U06GLOSS = "A contract: what a route promises its callers: the path, the method, the shapes in and out."
BRIEFQ = "what a client may rely on"
FOUR = ["mealType", "mealsPerDay", "name", "pricePerMeal"]

def lines(p):
    return open(p, encoding="utf-8", errors="replace").read().splitlines()

# ---- static ---------------------------------------------------------------------------------------------------------------------------
WEB = "tiffinbox-web/"
NEW = ["tiffinbox-web/src/test/java/com/tiffinbox/web/OpenApiSpecTest.java", "tiffinbox-web/src/test/resources/openapi/tiffinbox.json"]
CHANGED = ["pom.xml", "tiffinbox-web/pom.xml", "README.md"]
STALE = [r"/v3/api-docs[^.\n]{0,40}(?:answers|is) (?:a )?(?:404|four-oh-four)", r"publishes no contract", r"no OpenAPI", r"`BOOT-INF/lib` (?:holds |is )?146(?! →)",
         r"\b44 tests\b"]

def tree(d):
    out = {}
    for r, ds, fs in os.walk(d):
        ds.sort()
        for f in fs:
            p = os.path.join(r, f); out[os.path.relpath(p, d)] = hashlib.md5(open(p, "rb").read()).hexdigest()
    return out

def card(t):
    m = re.search(r"^## Course 9 · unit 07 — .*?(?=^## |\Z)", t, re.M | re.S); return m.group(0) if m else ""

def static(after, before):
    md = lambda x: hashlib.md5("\n".join(x).encode()).hexdigest()
    end = "# --- XFAM_S9S1 end ---"
    s9 = open(os.path.join(HERE, "s907.py"), encoding="utf-8").read().split("\n")
    s6 = open(os.path.join(UNIT, "..", "c9-unit06", "harness", "s906.py"), encoding="utf-8").read().split("\n")
    s4 = open(os.path.join(UNIT, "..", "c9-unit04", "harness", "s904.py"), encoding="utf-8").read().split("\n")
    if any(end not in s for s in (s9, s6, s4)): fail("the XFAM_S9S1 end marker is missing in s907.py, s906.py or s904.py"); done()
    a = lambda s: next(i for i, l in enumerate(s) if l.endswith('"""') and i > 0)
    sl = lambda s: s[a(s) + 1:s.index(end) + 1]
    need(sl(s9) == sl(s4), "s907.py's base + XFAM_S9S1 (after its docstring, through the block's end marker) = s904.py's, %d lines, md5 %s" % (len(sl(s4)), md(sl(s4))))
    need(sl(s9) == sl(s6), "= U06's s906.py's slice (copied from U06's harness)")
    t9 = "\n".join(s9); t4 = "\n".join(s4)
    rx = r"# --- XFAM_S9S1 begin ---\n.*?# --- XFAM_S9S1 end ---"
    b4 = re.search(rx, t4, re.S); b9 = re.search(rx, t9, re.S)
    need(b4 is not None and b9 is not None and b4.group(0) == b9.group(0), "the XFAM_S9S1 block, delimited, byte-equal to U04's")
    if b9:
        h = hashlib.md5(b9.group(0).encode()).hexdigest()
        print("  XFAM_S9S1_SLICE_MD5 = %s (computed the way ../c9-unit04/harness/chk04.py computes it)" % h); val("xfam_s9s1_md5", h[:8])
    need(not re.search(r"^XU0[123456] = ", t9, re.M), "XU01-XU06 are not carried")
    need(re.search(r"^XU07 = ", t9, re.M) is not None and re.search(r"^u04 = u07$", t9, re.M) is not None, "U07's own family (XU07) follows the carried slice; u04 = u07 (U01's binding)")
    ta, tb_ = tree(after), tree(before)
    for f in NEW: need(f in ta and f not in tb_, "new in after/, absent from before: " + f)
    for f in CHANGED: need(f in ta and f in tb_ and ta[f] != tb_[f], "changed by this unit: " + f)
    other = sorted(f for f in set(ta) | set(tb_) if f not in NEW + CHANGED and ta.get(f) != tb_.get(f))
    need(not other, "no other file differs between before and after/ (before %d files, after/ %d) %s" % (len(tb_), len(ta), other[:3]))
    need(not any(f.startswith(("tiffinbox-web/src/main/", "tiffinbox-core/src/main/")) for f in NEW + CHANGED + other), "nothing under src/main/ is new or changed (no application code, property, migration)")
    val("files_new", len(NEW)); val("files_changed", len(CHANGED))
    rs = open(os.path.join(UNIT, "receipts.sh"), encoding="utf-8").read()
    need(re.search(r'^AD=\$\(diff -rq -x \.m2-demo -x target -x secrets -x \.harness after \.\./c9-tiffinbox 2>&1 \|\| true\)$', rs, re.M) is not None
         and not re.search(r'\[ -z "\$AD" \] \|\| die', rs) and re.search(r'\[ "\$AD1" = "\$AD" \] \|\| die "the anchor moved during the run"', rs) is not None,
         "receipts.sh: the anchor check at the start is a NOTE (no die on it); the end's check is the anchor moving DURING the run (the orchestrator's notes)")
    # the pin (S9.7, R.515)
    pp = open(os.path.join(after, "pom.xml"), encoding="utf-8").read(); wp = open(os.path.join(after, "tiffinbox-web", "pom.xml"), encoding="utf-8").read()
    need(pp.count("<springdoc.version>") == 1 and "<springdoc.version>3.2.1</springdoc.version>" in pp, "the parent POM: springdoc.version declared once, 3.2.1")
    need("<springdoc.version>" not in wp and "<version>" not in re.search(r"<artifactId>springdoc-openapi-starter-webmvc-ui</artifactId>\s*</dependency>|<artifactId>springdoc-openapi-starter-webmvc-ui</artifactId>.{0,80}", wp, re.S).group(0),
         "tiffinbox-web/pom.xml: the starter with no version and no second springdoc.version")
    m = re.search(r"<!--((?:(?!-->).)*?)-->\s*<springdoc\.version>", pp, re.S)
    c = re.sub(r"\s+", " ", m.group(1)) if m else ""
    print("  the pin's comment (%d words): %s" % (len(c.split()), c.strip()[:400]))
    need(bool(c) and "Course 9, unit 07" in c, "the pin's comment names Course 9, unit 07")
    need("4.2.0" in c and "springdoc-openapi-3.2.1.pom:13" in c, "R.515 (1): the comment names the parent POM line (Boot 4.2.0, springdoc-openapi-3.2.1.pom:13)")
    need("3.1.0" in c and "3.1.1" in c and "not weighed" in c, "R.515 (2): the comment names the alternatives not weighed (3.1.0, 3.1.1)")
    need("/v3/api-docs" in c and "../c9-unit07" in c, "R.515 (3): the comment names the measured surface and the capture that measured it")
    need(not re.search(r"\bcompatible\b", c, re.I), "R.515: the bare word \"compatible\" is not in the comment")
    need("Versioning Strategies" in c, "what would change the pin is named by its lesson's title (Versioning Strategies)")
    md_ = re.search(r"<dependency>\s*<groupId>org\.springdoc</groupId>\s*<artifactId>springdoc-openapi-starter-webmvc-ui</artifactId>\s*<version>\$\{springdoc\.version\}</version>\s*</dependency>", pp)
    need(md_ is not None and pp.count("org.springdoc") == 1, "the parent's dependencyManagement: one managed springdoc entry, its version the property")
    # the test: no knob, no Docker, Javadoc's two sentences
    tt = open(os.path.join(after, NEW[0]), encoding="utf-8").read()
    need("System.getProperty" not in tt and "getenv" not in tt, "OpenApiSpecTest: no system-property or environment knob")
    need("Docker" not in re.sub(r"/\*\*.*?\*/", "", tt, flags=re.S) and "Testcontainers" not in tt, "OpenApiSpecTest: no Docker use")
    need(len(re.findall(r"^    @Test$", tt, re.M)) == 1 and "getResourceAsStream(\"/openapi/tiffinbox.json\")" in tt and 'remove("servers")' in tt, "OpenApiSpecTest: one test, the file off the test class path, servers removed")
    need("the code drifting from the committed file" in tt and "does NOT catch: the document drifting from the wire" in tt and "Course 9, unit 07:" in tt,
         "OpenApiSpecTest's Javadoc: what it catches and what it does not, in its own sentences")
    need(re.search(r"^@SpringBootTest\(classes = TiffinBoxApp\.class, properties = \"tiffinbox\.shutdown-token=not-the-real-token\"\)\nclass OpenApiSpecTest \{", tt, re.M) is not None, "OpenApiSpecTest: package-private, MOCK (no web environment), the dummy token")
    # the committed file
    sf = os.path.join(after, NEW[1]); sd = json.load(open(sf, encoding="utf-8"))
    need("servers" not in sd, "the committed file carries no servers")
    import io
    b = io.StringIO(); json.dump(sd, b, indent=2, ensure_ascii=False); b.write("\n")
    need(b.getvalue() == open(sf, encoding="utf-8").read(), "the committed file is written by the fixed rule (json.dump indent 2, ensure_ascii False, a final newline)")
    val("spec_bytes", os.path.getsize(sf))
    # the stale hunt (R.250/R.453)
    rd = open(os.path.join(after, "README.md"), encoding="utf-8").read(); cd = card(rd)
    need(bool(cd) and "*Course 9, unit 07: since unit 07 the application also serves its own OpenAPI document at `/v3/api-docs`" in rd, "README: the unit 07 card and the header's unit 07 note")
    hits = [x for x in STALE if re.search(x, cd)]
    need(not hits, "the stale hunt: unit 07's card says nothing as current that the change makes false (%s)" % hits)
    for f in ["tiffinbox-web/pom.xml", "pom.xml"] + [os.path.join(dp, x)[len(after) + 1:] for dp, _, fs in os.walk(os.path.join(after, "tiffinbox-web", "src", "main")) for x in fs if x.endswith((".java", ".yaml", ".html"))]:
        t = open(os.path.join(after, f), encoding="utf-8", errors="replace").read()
        h = [x for x in STALE[:3] if re.search(x, t)]
        if h: fail("the stale hunt: %s says %s" % (f, h))
    hh = [(i + 1, l) for i, l in enumerate(rd.split("\n")) if re.search(r"api-docs|swagger|openapi|springdoc|publishes no|BOOT-INF/lib` (?:holds )?146|\b146 jars", l, re.I)]
    print("  the stale hunt over after/README.md (api-docs, swagger, openapi, springdoc, publishes no, 146): %d lines - %s" % (len(hh), ", ".join(str(i) for i, _ in hh)))
    for i, l in hh:
        if i > 200: continue
        print("    README.md:%d %s" % (i, l.strip()[:150]))
    if os.path.exists(J9):
        t = open(J9, encoding="utf-8").read(); m = re.search(r'"07": "([^"]+)"', t)
        need(m is not None and m.group(1) == "OpenAPI: The Contract", "java9_series.TITLES['07'] = %r" % (m.group(1) if m else None))
    mods = re.findall(r"<module>([^<]+)</module>", pp); bp = open(os.path.join(before, "pom.xml"), encoding="utf-8").read()
    need(mods == re.findall(r"<module>([^<]+)</module>", bp) == ["tiffinbox-core", "tiffinbox-web"], "the parent's modules unchanged (%s): no TIFFINBOX_MODULES row (carried to U10)" % mods)
    done()

# ---- the spoken lines -----------------------------------------------------------------------------------------------------------------
STATUS = re.compile(r"(?<![\d.,:/-])\b(?:[1-5]\d\d)\b|\b(?:one|two|three|four|five)[\s-]hundred[\s-]and\b|\b(?:one|two|three|four|five)[\s-]hundred[\s-](?:one|two|three|four|five|six|seven|eight|nine|ten|eleven|twelve|thirteen|fourteen|fifteen)\b")
HING = re.compile(r"\b(?:bhai|yaar|dosto|kya|hai|nahi|nahin|matlab|karo|dekho|chalo|samjho|theek|accha|arre|haan|bilkul|zaroor|aur|toh|abhi|yeh|woh|kaise|kyun|bahut|thoda|sahi|galat)\b", re.I)
SPELL = re.compile(r"\b(?:API|URI|URL|RFC)s?\b|\bOpenAPI\b|\bspringdoc\b|\bSwagger\b", re.I)
def brief_lines():
    t = open(S2B, encoding="utf-8").read().split("\n")
    i0 = next(i for i, l in enumerate(t) if l.startswith("## Unit 07 · OpenAPI: The Contract")); i1 = next(i for i, l in enumerate(t) if i > i0 and l.startswith("## "))
    print("  the brief's Unit 07 section: S2B :%d-:%d" % (i0 + 1, i1))
    t = t[i0:i1]
    h = [l for l in t if l.startswith("**Hook")]
    e = [i for i, l in enumerate(t) if l.startswith('**Exercise:** "Your turn:')]
    hook = re.search(r'"([^"]+)"', h[0]).group(1) if len(h) == 1 else None
    ex = (t[e[0]] + " " + t[e[0] + 1]) if len(e) == 1 else ""
    m = re.search(r'\*\*Exercise:\*\* "([^"]+)"', ex)
    exq = re.sub(r"\s+", " ", m.group(1)) if m else None
    return hook, exq, [l for l in h] + ([t[e[0]], t[e[0] + 1]] if e else [])
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
    need(hook == HOOK == bh, "the hook is S2B :158's, byte for byte (extracted at run time = typed once here)")
    need(exq == EXQ == be, "the exercise's line is S2B :166's, byte for byte (extracted at run time = typed once here)")
    hw, ew = len(hook.split()), len(exq.split())
    need(hw == 18, "the hook: %d words (wc -w; the brief's 18)" % hw)
    need(ew == 19 and ew <= 25, "the exercise: %d words (wc -w; the brief's 19; <= 25)" % ew)
    for name, s in (("the hook", hook), ("the exercise", exq)):
        nd = re.findall(r"\d", s); cf = sf(s) if sf else None
        print("  %s: digits %s · the status gate %s · check_unit9.status_forms %s · the spelling gate %s · Hinglish %s · dur9 %s" % (name, "".join(nd) or "0", "hit" if STATUS.search(s) else "0",
              cf if cf is not None else "-", SPELL.search(s).group(0) if SPELL.search(s) else "0", "hit" if HING.search(s) else "0", dur.search(s).group(0) if dur is not None and dur.search(s) else "0"))
        need(not STATUS.search(s) and not cf, "%s: the status gate 0" % name)
        need(not SPELL.search(s), "%s: the spelling gate 0 (API, URI, URL, RFC, bare OpenAPI / springdoc / Swagger)" % name)
        need(not HING.search(s), "%s: the Hinglish list 0" % name)
        if dur is not None: need(not dur.search(s), "%s: dur9 0" % name)
        need(not nd, "%s: no digit" % name)
    for p in ("Open A-P-I", "spring doc"): need(not SPELL.search(p), "the spelled form %r passes the spelling gate (RED #25 / BLUE)" % p)
    for p in ("OpenAPI", "springdoc"): need(bool(SPELL.search("It reads the " + p + " document.")), "the bare %r refuses in a spoken line" % p)
    need(" the contract" not in (hook + exq).lower(), "no spoken line says \"the contract\"")
    print("  the hook: %d words · the exercise: %d words · \"meals are optional\": true of two properties - the diff capture's required row prints which" % (hw, ew))
    val("hook_words", hw); val("exercise_words", ew)
    done()

def gloss(readme):
    u6 = open(os.path.join(UNIT, "..", "c9-unit06", "README.md"), encoding="utf-8").read().split("\n")
    need(u6.count(U06GLOSS) == 1, "U06's gloss stands in ../c9-unit06/README.md once, a line of its own, byte for byte")
    c6 = open(os.path.join(UNIT, "..", "c9-unit06", "harness", "chk06.py"), encoding="utf-8").read()
    need('GLOSSQ = "what a route promises its callers: the path, the method, the shapes in and out"' in c6, "U06's chk06.py types it once (GLOSSQ)")
    rd = open(readme, encoding="utf-8").read().split("\n")
    g = [i + 1 for i, l in enumerate(rd) if re.match(r"^\s*A contract:", l)]
    need(not g, "README.md carries no line starting \"A contract:\" (no second gloss) %s" % g)
    first = next((i + 1 for i, l in enumerate(rd) if re.search(r"\bcontract\b", re.sub(r"`[^`]*`", "", l), re.I) and not l.startswith("#")), None)
    print("  U06's gloss (%d words): %s" % (len(U06GLOSS.split()), U06GLOSS))
    print("  the brief's U07 parenthetical (%d words): \"a contract\" (%s) - a paraphrase of U06's, not a second gloss" % (len(BRIEFQ.split()), BRIEFQ))
    print("  first spoken use of \"contract\" in the README at line %s (called back, the word is U06's)" % first)
    need(first is not None, "the README uses the word (called back)")
    val("gloss", "U06s_called_back")
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

# ---- the captures ---------------------------------------------------------------------------------------------------------------------
TESTS_RX = r"^  (\w+) tests (\d+) failures (\d+) errors (\d+) skipped (\d+)$"
IT = {"CustomerEntityRepositoryIT": (21280, 5432), "CustomerAggregatesIT": (21281, 5432), "RedisDatastoreIT": (21282, 6379), "MongoDatastoreIT": (21283, 27017), "ElasticsearchIT": (21284, 9200)}
NEWJARS = ["commons-lang3-3.20.0.jar", "jackson-dataformat-yaml-3.1.8.jar", "snakeyaml-engine-3.0.1.jar", "springdoc-openapi-starter-common-3.2.1.jar",
           "springdoc-openapi-starter-webmvc-api-3.2.1.jar", "springdoc-openapi-starter-webmvc-ui-3.2.1.jar", "swagger-annotations-3.0.0.jar",
           "swagger-core-3.0.0.jar", "swagger-models-3.0.0.jar", "swagger-ui-5.35.1.jar", "webjars-locator-lite-1.1.5.jar"]
def u06_tests():
    t = open(os.path.join(UNIT, "..", "c9-unit06", "README.md"), encoding="utf-8").read()
    m = re.search(r"^tests: tests=(\d+) .*its=(\d+) .*lib=(\d+)/(\d+)$", t, re.M); return (int(m.group(1)), int(m.group(2)), int(m.group(4))) if m else (None, None, None)
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
        elif sec and l.startswith("  ") and not l.startswith("  IT BINDINGS") and not l.startswith("  the ") and not l.startswith("  Testcontainers") and not l.startswith("  mvn "):
            fail("a per-class line this checker cannot parse: %r" % l[:100])
    u6, i6, lib6 = u06_tests()
    for s in ("pkg", "twin"):
        tot = sum(per[s].values()); k = per[s].get("OpenApiSpecTest", 0)
        need(u6 is not None and tot == u6 + k and k == 1, "%s: %d = U06's %s (its README values block; re-measured) + %d (OpenApiSpecTest)" % (s, tot, u6, k))
    need(per["pkg"] == per["twin"], "the Docker-free twin runs the same classes and counts as package")
    t = "\n".join(ls)
    need(re.search(r"^  mvn package exit 0 ", t, re.M) is not None and re.search(r"^  mvn package \(Docker-free\) exit 0 ", t, re.M) is not None, "mvn package exit 0, and its Docker-free twin exit 0")
    need(re.search(r"^  the twin's OpenApiSpecTest line: OpenApiSpecTest: servers served \[\{\"url\":\"http://localhost\"", t, re.M) is not None, "the twin: MockMvc's servers is http://localhost")
    need(sum(per["it"].values()) == i6 == 14 and len(per["it"]) == 5, "the ITs: %d in 5 classes (U06's %s)" % (sum(per["it"].values()), i6))
    val("tests", sum(per["pkg"].values())); val("tests_u06", u6); val("tests_k", per["pkg"].get("OpenApiSpecTest", 0)); val("its", sum(per["it"].values()))
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
    moved = [l[6:] for l in ls if l.startswith("  lib ")]
    add = sorted(x[2:] for x in moved if x.startswith("> ")); rem = [x for x in moved if x.startswith("< ")]
    need(len(libs) == 2 and lib6 is not None and int(libs[0][1]) == lib6 and int(libs[1][1]) == lib6 + len(add), "BOOT-INF/lib %s -> %s (U06's %s + %d new)" % (libs[0][1] if libs else "-", libs[1][1] if len(libs) > 1 else "-", lib6, len(add)))
    need(add == NEWJARS and not rem, "the jars whose names moved: %d added (%s), %d removed - no other version moves" % (len(add), " ".join(add), len(rem)))
    al = [l for l in ls if l.startswith("  after: ")]
    for j in ("tomcat-embed-core-11.0.29.jar", "spring-core-7.0.11.jar", "spring-boot-4.1.3.jar", "postgresql-42.7.14.jar", "jackson-databind-3.1.8.jar", "jackson-databind-2.21.8.jar"):
        need(al and j in al[0], "after/'s BOOT-INF/lib holds " + j)
    val("lib", "%s->%s" % (libs[0][1], libs[1][1]) if len(libs) == 2 else "-"); val("new_jars", len(add))

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
    need(H["before"][2] == 0 and H["after"][2] == len(SD["after"]), "springdoc's rows: before %d, after/ %d" % (H["before"][2], H["after"][2]))
    need(H["after"][3] == H["before"][3], "the others (actuator, /error) equal on both: %d" % H["after"][3])
    need(H["after"][0] - H["before"][0] == H["after"][2], "the difference of all rows (%d) = springdoc's rows (%d)" % (H["after"][0] - H["before"][0], H["after"][2]))
    for r in SD["after"]: print("  springdoc's row: %s %s %s" % r)
    tb = H["after"][1]
    C = {}
    for l in ls:
        m = re.match(r"^  commit (\w+) \(.*\): mapping annotations (\d+) · dev mappings (\d+) · default run (\d+)$", l)
        if m: C[m.group(1)] = tuple(int(x) for x in m.groups()[1:])
    a = re.search(r"^  after/ \(this unit's tree\): mapping annotations (\d+) · dev mappings (\d+) · default run (\d+)$", t, re.M)
    need(set(C) == {"80f7839", "a0a0151", "df4ff12", "a805e6c"} and a is not None, "the partition: four commits and after/ read")
    if a and len(C) == 4:
        s0, s4, s5, s6, s7 = C["80f7839"][2], C["a0a0151"][2], C["df4ff12"][2], C["a805e6c"][2], int(a.group(3))
        need(s7 == tb, "after/'s default-run mappings by source (%d) = the flag start's TiffinBox rows (%d)" % (s7, tb))
        u6 = open(os.path.join(UNIT, "..", "c9-unit06", "README.md"), encoding="utf-8").read()
        m6 = re.search(r"handlers_setup=(\d+) handlers_u04=(\d+) handlers_u05=(\d+) handlers_u06=(\d+)", u6)
        need(m6 is not None and (s0, s4 - s0, s5 - s4, s6 - s5) == tuple(int(x) for x in m6.groups()), "the partition by commit = U06's values block (%s)" % (",".join(m6.groups()) if m6 else None))
        need(s0 + (s4 - s0) + (s5 - s4) + (s6 - s5) == s6 == tb and s7 - s6 == 0, "the partition: the set-up's %d + U04's %d + U05's %d + U06's %d = %d; U07 adds %d" % (s0, s4 - s0, s5 - s4, s6 - s5, s6, s7 - s6))
        val("handlers", tb); val("handlers_setup", s0); val("handlers_u04", s4 - s0); val("handlers_u05", s5 - s4); val("handlers_u06", s6 - s5); val("handlers_u07", s7 - s6)
    ua = re.search(r"the unanchored count beside: after/ (\d+)", t)
    need(ua is not None and a is not None and int(ua.group(1)) == int(a.group(1)) + 1, "the unanchored pattern counts one line more (a Javadoc's {@code @GetMapping})")
    opsl = re.search(r"^  op document: paths (\d+) · operations (\d+) · operations no handler maps: (\d+)$", t, re.M)
    need(opsl is not None and len(O) == tb, "one handler-to-operation line per TiffinBox handler (%d)" % len(O))
    if opsl:
        absent = [o for o in O if o[4] == "absent"]; present = [o for o in O if o[4] != "absent"]
        merged = len(present) - len({o[4] for o in present})
        nops = int(opsl.group(2))
        need(all(o[0] == "DashboardPage" for o in absent) and len(absent) == 3, "absent: DashboardPage's three (%s)" % ", ".join("%s %s" % (o[2], o[3]) for o in absent))
        pm = [o for o in present if o[0] == "CustomerPatches"]
        need(len(pm) == 2 and len({o[4] for o in pm}) == 1 and merged == 1, "CustomerPatches' two PATCH handlers are one operation (%s); merged %d" % (pm[0][4] if pm else "-", merged))
        need(tb - len(absent) - merged == nops and int(opsl.group(3)) == 0, "handlers - absent - merged = the document's operations: %d - %d - %d = %d (every operation maps a handler)" % (tb, len(absent), merged, nops))
        val("operations", nops); val("paths", int(opsl.group(1))); val("absent", len(absent)); val("merged", merged); val("springdoc_rows", H["after"][2])

def c_after(p):
    ls, R, heads, asks = load(p); t = "\n".join(ls)
    F = {}
    for db in ("pg", "h2"):
        blk = t.split("== %s: the three addresses" % db)[1].split("\n== ")[0] if ("== %s: the three addresses" % db) in t else ""
        f = {}
        for k, rx in (("doc1", r"document: openapi (\S+) · info (\{.*?\}) · servers (.*)$"), ("doc2", r"document: paths (\d+) · operations (\d+) · tags (\S+) · schemas (\S+)$"),
                      ("doc3", r"document: components\.securitySchemes (\w+) · a security member (\w+)"), ("doc4", r"document: Customer required (\[.*?\]) of (\d+) properties$"),
                      ("doc5", r"document: the socket's answer (\d+) B .* md5 masked ([0-9a-f]{32}) · servers removed \(the fixed rule\) ([0-9a-f]{32}) · = the committed file: (\S+)$"),
                      ("dbl", r"which database answered \(Flyway's line\): Database: \S+ \(([A-Za-z0-9]+) ([0-9.]+)\)")):
            m = re.search(rx, blk, re.M); f[k] = m.groups() if m else None
            need(m is not None, "%s: the %s line" % (db, k))
        F[db] = f
    if any(v is None for f in F.values() for v in f.values()): return
    need(F["pg"]["dbl"] == ("PostgreSQL", "18.6") and F["h2"]["dbl"][0] == "H2", "the database label: PostgreSQL 18.6 on the pg block, H2 on the h2 block (each block's own Flyway line: %s, %s)" % (F["pg"]["dbl"], F["h2"]["dbl"]))
    for db in ("pg", "h2"):
        f = F[db]
        need(f["doc1"][0] == "3.1.0", "%s: openapi 3.1.0" % db)
        need("<port>" in f["doc1"][2] and not re.search(r":\d{4,5}", f["doc1"][2]), "%s: servers[0].url masked (%s)" % (db, f["doc1"][2]))
        need(f["doc3"] == ("absent", "absent"), "%s: no securitySchemes, no security member (data for U09 / U26, claimed nowhere)" % db)
        need(json.loads(f["doc4"][0]) == ["mealType", "name"] and f["doc4"][1] == "4", "%s: Customer required %s of %s" % (db, f["doc4"][0], f["doc4"][1]))
        need(f["doc5"][3] == "byte-identical", "%s: the served document with servers removed = the committed file" % db)
    need({k: v for k, v in F["pg"].items() if k != "dbl"} == {k: v for k, v in F["h2"].items() if k != "dbl"}, "the document equal on PostgreSQL and H2 after the mask (every fact line)")
    need("  the document on PostgreSQL and on H2, servers removed: byte-identical" in ls, "the two servers-removed documents byte-identical")
    blocks = [a for a in asks]
    need(len(blocks) == 10, "five addresses asked on each database (%d blocks)" % len(blocks))
    want = {"/v3/api-docs": ("200", "application/json"), "/swagger-ui.html": ("302", None), "/swagger-ui/index.html": ("200", "text/html"),
            "/v3/api-docs.yaml": ("200", None), "/v3/api-docs/swagger-config": ("200", "application/json")}
    for b in blocks:
        w = want.get(b["p"])
        need(w is not None and b["st"] == w[0] and (w[1] is None or b["ct"].startswith(w[1])), "after: GET %s -> %s %s" % (b["p"], b["st"], b["ct"]))
        need(b["key"] == "no", "after: GET %s sent no key header" % b["p"])
    loc = [hdr(b, "Location") for b in blocks if b["p"] == "/swagger-ui.html"]
    need(all(x and x.endswith("/swagger-ui/index.html") for x in loc), "the page's address redirects to /swagger-ui/index.html (status line only; U08's page)")
    yt = sorted({b["ct"] for b in blocks if b["p"] == "/v3/api-docs.yaml"})
    print("  /v3/api-docs.yaml's media type as printed: %s" % ",".join(yt))
    h = F["h2"]
    val("openapi", h["doc1"][0]); val("info", json.loads(h["doc1"][1])["title"].replace(" ", "_") + "/" + json.loads(h["doc1"][1])["version"]); val("paths", h["doc2"][0]); val("operations", h["doc2"][1])
    val("tags", len(h["doc2"][2].split(","))); val("schemas", h["doc2"][3]); val("required", "%d/%s" % (len(json.loads(h["doc4"][0])), h["doc4"][1])); val("socket_bytes_not_voiced", h["doc5"][0])
    val("spec_md5", h["doc5"][2][:8]); val("pg_equal", "yes")

def detector_200(R):
    """the check "/v3/api-docs answered 200": run on before's capture it must FAIL (plant 4, R.276 + R.374)"""
    r = [x for x in R.values() if x["p"] == "/v3/api-docs"]
    return bool(r) and all(x["st"] == "200" for x in r)
def c_before(p):
    ls, R, heads, asks = load(p)
    need(len(asks) == 3, "three addresses asked on before (%d)" % len(asks))
    for a in asks:
        need(a["st"] == "404", "before: GET %s -> %s (want 404)" % (a["p"], a["st"]))
        q = [s for s in a["srv"] if s["disp"] is None]
        need(bool(q) and q[0]["h"] == "ResourceHttpRequestHandler", "before: GET %s - the request witness's handler ResourceHttpRequestHandler (the static handler)" % a["p"])
        need(a["body"] is not None and "No static resource" in a["body"], "before: GET %s - Boot's problem detail for a missing static resource" % a["p"])
        need(a["key"] == "no", "before: GET %s sent no key header" % a["p"])
    need(not detector_200(R), "the detector \"/v3/api-docs answered 200\" FAILS on before's capture (it can fail: R.276 + R.374)")
    t = "\n".join(ls)
    need("  ledger: The API docs route and the Swagger page answer four-oh-four: TiffinBox publishes no contract today." in ls, "Course 8's line, read off the ledger (C9-10d)")
    m = re.search(r"^  the script's line (\d+) holds it: (\d+)$", t, re.M)
    need(m is not None and int(m.group(2)) >= 1, "the line stands in What's Next: The API Other People Will Use (first at line %s, %s lines hold it)" % (m.group(1) if m else None, m.group(2) if m else None))
    need("  key table rows: 0 (the harness's JdbcTemplate route /probe/u07/keys, the second client)" in ls, "before: the key table 0 rows")
    val("before", "404/404/404"); val("detector_on_before", "FAIL")

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
def c_diffpg(p):
    ls = lines(p); t = "\n".join(ls)
    need(re.search(r"Database: <url> \(PostgreSQL 18\.6\)", t) is not None or "PostgreSQL 18.6" in t, "the database: PostgreSQL 18.6")
    K, Dn, rows, st = wirecheck(p, "pg", ls, t)
    q = sibling(p, "diff")
    if q:
        lh = lines(q); th = "\n".join(lh)
        Ph = {m.group(1): (m.group(6), m.group(7)) for m in (PAIR.match(l) for l in lh) if m}
        Pp = {m.group(1): (m.group(6), m.group(7)) for m in (PAIR.match(l) for l in ls) if m}
        need(Ph == Pp, "every request's status and content type equal on PostgreSQL and H2 (%d)" % len(Pp))
        rh = [r[0] for r in (ROWL.match(l) for l in lh) if r and r.group(1) == "a"]; rp = [r[0] for r in (ROWL.match(l) for l in ls) if r and r.group(1) == "a"]
        need([ROWL.match(l).groups()[2:] for l in lh if ROWL.match(l) and l.startswith("  (a)")] == [ROWL.match(l).groups()[2:] for l in ls if ROWL.match(l) and l.startswith("  (a)")], "(a)'s rows equal on PostgreSQL and H2")
    else: print("  (the H2 diff capture runs later in the run; the equality is asserted by the diff capture's check)")
    val("kinds_a", K.get("a", ["-"])[0] if K.get("a") else "-"); val("rows_a", Dn.get("a", "-"))

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
    hd = {k: ([s["h"] for s in v["srv"] if s["disp"] is None] or ["none"])[0] for k, v in W.items()}
    print("  the request witness on after/: %s" % " · ".join("%s -> %s %s" % (k, W[k]["st"], hd[k]) for k in W))
    need(hd.get("/nowhere") == "ResourceHttpRequestHandler" and W.get("/nowhere", {}).get("st") == "404", "after/: /nowhere still the static handler's 404 - the old request that reaches the resource handlers")
    need(hd.get("/swagger-ui/index.html") == "ResourceHttpRequestHandler", "after/: the page's resources are served by a resource handler (Swagger UI's webjar)")
    need(W.get("/v3/api-docs", {}).get("st") == "200" and hd.get("/v3/api-docs", "").startswith("OpenApiWebMvcResource"), "after/: /v3/api-docs -> 200 by springdoc's handler (%s)" % hd.get("/v3/api-docs"))
    m = re.search(r"the document on this harness-joined start: paths (\d+), of them /probe/ (\d+)", t)
    need(m is not None and int(m.group(2)) > 0, "the harness-joined start documents the harness's routes too (%s /probe/ paths): no claim reads that document" % (m.group(2) if m else "-"))
    mp = re.search(r"the wire's mapper \(the harness's /probe/u07/mapper\): (\{.*\})$", t, re.M)
    if mp:
        d = json.loads(mp.group(1)); print("  the wire's mapper: Jackson 3 %s · Jackson 2 class %s · Jackson 2 beans %s" % (d["jackson3"], d["jackson2_class"], d["jackson2_beans"]))
        need(d["jackson3"] == ["tools.jackson.databind.json.JsonMapper"] and d["jackson2_beans"] == [], "the wire's mapper: Jackson 3's JsonMapper, no Jackson 2 ObjectMapper bean")
    else: fail("the wire's mapper line")
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

def c_jackson(p):
    ls = lines(p); t = "\n".join(ls)
    m = re.search(r"swagger-core-3\.0\.0\.jar \S+ObjectMapperFactory\.class: constant-pool UTF-8 entries naming tools/jackson/databind (\d+) · tools/jackson/core (\d+) · com/fasterxml/jackson/databind (\d+) · com/fasterxml/jackson/annotation (\d+)$", t, re.M)
    need(m is not None and int(m.group(1)) > 0 and int(m.group(3)) == 0, "swagger-core 3.0.0's ObjectMapperFactory names Jackson 3's databind (%s entries) and not Jackson 2's (%s)" % (m.group(1) if m else "-", m.group(3) if m else "-"))
    c = re.search(r"springdoc-openapi-starter-common-3\.2\.1\.jar: classes (\d+) · naming tools/jackson/databind (\d+) · naming com/fasterxml/jackson/databind (\d+)$", t, re.M)
    need(c is not None and int(c.group(2)) > 0 and int(c.group(3)) == 0, "springdoc-openapi-starter-common 3.2.1: %s classes name Jackson 3's databind, %s Jackson 2's" % (c.group(2) if c else "-", c.group(3) if c else "-"))
    j = re.search(r"^  jackson jars: (.*)$", t, re.M)
    need(j is not None and "jackson-databind-3.1.8.jar" in j.group(1) and "jackson-databind-2.21.8.jar" in j.group(1), "the jars: jackson-databind 3.1.8 (the wire's) and the 2.21.8 jar present")
    q = sibling(p, "diff")
    if q:
        mp = re.search(r"the wire's mapper \(the harness's /probe/u07/mapper\): (\{.*\})$", open(q, encoding="utf-8").read(), re.M)
        need(mp is not None and json.loads(mp.group(1))["jackson3"] == ["tools.jackson.databind.json.JsonMapper"], "the wire's mapper (the diff capture's harness read): Jackson 3's JsonMapper")
    print("  the setup's expectation it overrules (S2B :23-:25): \"swagger-core is expected to bring or need Jackson 2\"")
    if m and c: val("sc_j3", m.group(1)); val("sc_j2", m.group(3)); val("common_j3", c.group(2)); val("common_j2", c.group(3))

def c_committed(p):
    ls = lines(p); t = "\n".join(ls)
    m = re.search(r"^  bytes (\d+) \(wc -c\) · md5 ([0-9a-f]{32}) · servers member: (\w+)$", t, re.M)
    need(m is not None and m.group(3) == "absent", "(i) the file: %s bytes, no servers" % (m.group(1) if m else "-"))
    need("byte-identical" in (re.search(r"the fixed rule .* re-applied to the file: (\S+)", t) or [None, ""])[1] if re.search(r"the fixed rule .* re-applied to the file: (\S+)", t) else False, "(i) the fixed rule re-applied reproduces the file")
    need(re.search(r"^  the file against the served document, servers removed \(the after capture's python, live\): pg byte-identical · h2 byte-identical$", t, re.M) is not None, "(i) the file = the served document with servers removed, on PostgreSQL and H2")
    need(re.search(r"^  package:  OpenApiSpecTest tests 1 failures 0 errors 0 skipped 0$", t, re.M) is not None and re.search(r"^  twin:  OpenApiSpecTest tests 1 failures 0 errors 0 skipped 0$", t, re.M) is not None, "(ii) OpenApiSpecTest PASSES in package and in the Docker-free twin")
    need(re.search(r'^  MockMvc\'s servers, as the test printed it: \[\{"url":"http://localhost"', t, re.M) is not None and re.search(r'^  the socket\'s servers, .*127\.0\.0\.1:<port>', t, re.M) is not None, "(ii) MockMvc's servers http://localhost beside the socket's (masked)")
    for k, n in (("iii", "file"), ("iv", "code")):
        sec = t.split("== (%s)" % k)[1].split("\n== ")[0] if "== (%s)" % k in t else ""
        need(re.search(r"mvn test -Dtest=OpenApiSpecTest exit 1 · Tests run: 1, Failures: 1, Errors: 0", sec) is not None, "(%s) the drifted %s: the test FAILS (exit 1, Failures 1)" % (k, n))
        need("its FAIL line: theServedDocumentIsTheCommittedOne" in sec and re.search(r"the assertion: expected", sec) is not None, "(%s) its FAIL line and the expected ... but was ... assertion kept" % k)
        need(len(re.findall(r"^  diff: [<>]", sec, re.M)) >= 2, "(%s) the drift's diff printed" % k)
    v = re.search(r"the diff capture's \(a\) line: \(a\) DISAGREEMENTS (\d+) · the test: equal: true with every disagreement present", t)
    need(v is not None and int(v.group(1)) > 0, "(v) the test PASSES in the run in which diff prints %s rows: code against the committed file, never the document against the wire" % (v.group(1) if v else "-"))
    if m: val("spec_bytes", m.group(1)); val("spec_md5", m.group(2)[:8])
    val("test", "PASS"); val("drift_file", "FAIL"); val("drift_code", "FAIL")

MVL = re.compile(r"^  (before|after) \| ([A-Z]+ \S+(?: \[[\w-]+\])?) -> (\d{3}) (\S*) (\d+) · Allow \{([^}]*)\} · Accept-Patch \{([^}]*)\} · Location \{([^}]*)\} · body (\S+)$")
THREE = ["GET /v3/api-docs", "GET /swagger-ui.html", "GET /swagger-ui/index.html"]
def c_moved(p):
    ls = lines(p); M = {}
    for l in ls:
        m = MVL.match(l)
        if m: M[(m.group(1), m.group(2))] = m.groups()[2:]
        elif l.startswith("  before |") or l.startswith("  after |"): fail("a moved line this checker cannot parse: %r" % l[:120])
    qs = sorted({k[1] for k in M})
    need(len(qs) == 12 and all(("before", q) in M and ("after", q) in M for q in qs), "every request asked on both trees (%d)" % len(qs))
    moved = [q for q in qs if M.get(("before", q)) != M.get(("after", q))]
    need(sorted(moved) == sorted(THREE), "moved: exactly the three addresses (S9.37, the one named compatible move - an addition): %s" % moved)
    for q in moved: print("  MOVED (compatible, an addition, named in this unit) %s: before %s -> after %s" % (q, " ".join(M[("before", q)][:2]), " ".join(M[("after", q)][:2])))
    a = M.get(("after", "PATCH /customers")); b = M.get(("before", "PATCH /customers"))
    need(a is not None and b is not None and a[0] == b[0] == "405" and a[3] == b[3] == "GET,POST", "C9-10a: a PATCH to /customers answers 405, Allow the set {GET, POST}, on before and after/")
    need(M.get(("after", "GET /nowhere"), ("",))[0] == "404", "GET /nowhere: the static handler's 404 on both (a witness for this change)")
    un = [q for q in qs if q not in moved]
    print("  unmoved (%d): %s" % (len(un), " · ".join(un)))
    val("asked", len(qs)); val("moved", len(moved)); val("unmoved", len(un)); val("patch_customers", "405:" + (a[3].replace(",", "+") if a else "-"))

WITNESS = ["GET /nowhere"]
def c_seven(p):
    ls = lines(p); t = "\n".join(ls)
    S = re.search(r"the expected ([0-9a-f]{32})", t)
    if not S: fail("the expected hash"); return
    for side in ("before", "after"):
        m = re.search(r"^  %s: the seven ([0-9a-f]{32}) " % side, t, re.M)
        need(m is not None and m.group(1) == S.group(1), "%s: the seven = %s" % (side, S.group(1)[:8]))
    need("  before -> after/: equal" in ls, "the seven: before = after/")
    val("seven", S.group(1)[:8])
def c_surface(p):
    ls = lines(p); t = "\n".join(ls)
    S = re.search(r"the expected ([0-9a-f]{32})", t)
    if not S: fail("the expected hash"); return
    for side in ("before", "after"):
        m = re.search(r"^  %s: the old surface ([0-9a-f]{32}) \((\d+) requests, (\d+) lines\)$" % side, t, re.M)
        need(m is not None and m.group(1) == S.group(1), "%s: the old surface = %s (U06's) - %s requests, %s lines" % (side, S.group(1)[:8], m.group(2) if m else "-", m.group(3) if m else "-"))
    need("  before -> after/: equal" in ls and not any(l.startswith("    moved: ") for l in ls), "the old surface: before = after/, no line moved")
    need(any("planted: the seven" in l and "unchanged: yes" in l and "moved: yes" in l for l in ls), "the ETag plant (the harness's): the seven unchanged, the old surface moved")
    need(any("planted:" in l and " 0 (reader exit 3)" in l for l in ls), "the ETag plant: the feed answers nothing (the reader's exit 3 at its alarm, 0 bytes)")
    # R.511: which requests of the seven and the surface reach the change (the resource handlers) - by the diff capture's witness
    print("  R.511 witness for this change: GET /nowhere (the static handler's 404, the resource handlers springdoc's page sits beside); not a witness for this change: the other requests of the seven and the surface - they stay equal because they do not reach it")
    val("surface", S.group(1)[:8])
def c_inert(p):
    ls = lines(p); t = "\n".join(ls)
    for f in (".r-before.new", ".r-after.new"):
        m = re.search(r"^  %s: sent the key: (\d+) · did not: (\d+)$" % re.escape(f), t, re.M)
        need(m is not None and m.group(1) == "0", "%s: no request sent the key header (%s sent none)" % (f, m.group(2) if m else "-"))
    for f in (".r-diff.new", ".r-diffpg.new"):
        m = re.search(r"^  %s: sent the key: (\d+) · did not: (\d+)$" % re.escape(f), t, re.M)
        need(m is not None and m.group(1) == "0", "%s: no curl request sent the key header" % f)
    for w in ("wire-h2", "wire-pg"):
        m = re.search(r"^  %s: requests (\d+) · with the key: (\S+)$" % w, t, re.M)
        need(m is not None and m.group(1) == "12" and m.group(2) == "pause-key", "%s: 12 filed requests, the key header on pause-key alone" % w)
    kb = re.findall(r"^  \.r-before\.new:   key table rows: (\d+)", t, re.M)
    need(kb == ["0"], "before's JVM: the key table 0 rows")
    for f in (".r-diff.new", ".r-diffpg.new"):
        b = re.search(r"^  %s:   the second client before: .* · keys (\d+) " % re.escape(f), t, re.M); a = re.search(r"^  %s:   the second client after: .* · keys (\d+) " % re.escape(f), t, re.M)
        need(b is not None and a is not None and b.group(1) == "0" and a.group(1) == "1", "%s: the key table 0 before the census, 1 after it (pause-key's own)" % f)
    val("keyed", "pause-key"); val("key_rows", "0/1")

def c_exercise(p):
    ls = lines(p)
    def blk(db, tag, sh):
        out = []; on = False
        for l in ls:
            if l.startswith("== the exercise, %s, %s, %s " % (db, tag, sh)): on = True; continue
            if on and l.startswith("=="): break
            if on and not l.startswith("  guard before "): out.append(l[2:])
        return out
    want = {"broken": ("FAIL", "1"), "solved": ("PASS", None), "fileonly": ("FAIL", "1,2"), "noregen": ("FAIL", "2"), "wrongprops": ("FAIL", "1"), "unvalidated": ("FAIL", "3")}
    for v, (verdict, cl) in want.items():
        for sh in ("bash", "zsh"):
            b = blk("h2", v, sh)
            pre = "PASS: " if verdict == "PASS" else "FAIL (clause %s): " % cl
            need(any(x.startswith(pre) for x in b), "h2 %s (%s): %s" % (v, sh, pre.strip()))
            need(("check exit 0" if verdict == "PASS" else "check exit 1") in b, "h2 %s (%s): check.sh's exit" % (v, sh))
        need(blk("h2", v, "bash") == blk("h2", v, "zsh"), "h2 %s: bash and zsh -f print the same" % v)
    for v in ("solved", "broken"):
        for sh in ("bash", "zsh"):
            need(blk("pg", v, sh) == blk("h2", v, "bash"), "pg %s (%s): PostgreSQL prints what H2 prints" % (v, sh))
    need(blk("h2", "broken", "bash") != blk("h2", "solved", "bash"), "broken != solved")
    rd = [l[len("  README: "):] for l in ls if l.startswith("  README: ")]; so = [l[len("  SOLUTION: "):] for l in ls if l.startswith("  SOLUTION: ")]
    need([x for x in blk("h2", "broken", "bash") if not x.startswith("check exit")] == rd, "exercise/README.md's What it prints = the broken run's lines")
    need([x for x in blk("h2", "solved", "bash") if not x.startswith("check exit")] == so, "SOLUTION.md's What it prints = the solved run's lines")
    t = "\n".join(ls)
    need(re.search(r"^== the exercise's tree, solved: changed against after/: .*Customer\.java.*tiffinbox\.json", t, re.M) is not None, "the solution changes Customer.java and the committed file, nothing else")
    need(re.search(r"^     Customer\.java: @NotNull @Min\(1\) @Max\(3\) int mealsPerDay,$", t, re.M) is not None, "the solution: @NotNull on the two ints (no dependency moves)")
    val("exercise", "broken-FAIL1,solved-PASS,refused-4-FAIL,bash+zsh,pg+h2")

CAPS = {"tests": c_tests, "census": c_census, "after": c_after, "diffpg": c_diffpg, "exercise": c_exercise, "before": c_before, "diff": c_diff,
        "jackson": c_jackson, "committed": c_committed, "moved": c_moved, "seven": c_seven, "surface": c_surface, "inert": c_inert}
def capture(nm, p):
    if nm in CAPS: CAPS[nm](p)
    else: fail("no checks for the capture %r" % nm)
    done()

def hashable(nm, p):
    for l in lines(p):
        if re.match(r"^  guard before ", l): continue
        if l.startswith("  Testcontainers' containers while verify ran"): continue
        l = re.sub(r"load1 [0-9.]+", "load1 <n>", l)
        l = re.sub(r"\bBLUE_RUN=\d+", "BLUE_RUN=<N>", l)
        l = re.sub(r"\b(Blue\d)r\d+\b", r"\1r<N>", l)
        l = re.sub(r"blue-specwire-\d+", "blue-specwire-<N>", l)
        l = re.sub(r"(\"(?:id|version|ts)\":)\d+", r"\1<n>", l) if nm in ("diff", "diffpg") and l.startswith("  pair ") else l
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
        if a[0] == "static": static(a[1], a[2])
        elif a[0] == "hook": print(HOOK)
        elif a[0] == "exq": print(EXQ)
        elif a[0] == "gloss": gloss(a[1])
        elif a[0] == "spoken": spoken(a[1], a[2])
        elif a[0] == "specmask": specmask(sys.stdin)
        elif a[0] == "surefire": surefire(a[1])
        elif a[0] == "mapjson": mapjson(a[1], sys.stdin)
        elif a[0] == "ops": ops(a[1], a[2])
        elif a[0] == "docfacts": docfacts(a[1], a[2], a[3])
        elif a[0] == "pairs": pairs(a[1])
        elif a[0] == "rowsvs": rowsvs(a[1], a[2])
        elif a[0] == "jars": jars(a[1])
        elif a[0] == "hashable": hashable(a[1], a[2])
        elif a[0] == "values": values(a[1], a[2])
        else: capture(a[0], a[1])
    except SystemExit:
        raise
    except Exception as e:
        print("FAIL the checker could not read its input (%s: %s)" % (e.__class__.__name__, str(e)[:160])); sys.exit(1)
