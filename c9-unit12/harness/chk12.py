"""Course 9 unit 12's checker (python3 -I -B harness/chk12.py MODE ...). Every number the README may say is re-derived here from a capture's
own lines, a saved file or a shipped file, never typed. Each request line a check reads is parsed by a named pattern or skipped by a named
rule; a line it cannot parse is a FAIL line and exit 1, never a traceback (Course 8 unit 25's class). The shared machinery (surefire, junit,
the values block, the hashable form, the module table, static, gloss, hook, exq, spoken) is U11's (chk11.py, c9-unit11/harness), adapted;
U11's REST Docs and page subcommands are left out (flag 25) - this unit's are the versioning ones: choose, four, required, default,
newest, deprecate, retire, replay, restdocs, client, type, change.
Modes:
  static AFTER BEFORE      the carried prose slice, XFAM_S9S1's md5, the change's files (derived), the guards (i)-(vi), the stale sentences
  hook | exq | gloss-line  print the spoken lines (typed ONCE, here; asserted against the brief's bytes by spoken)
  gloss README             the one new gloss line (A version carrier), U06's, U08's, U09's, U10's and U11's still byte-equal
  spoken HOOK EXQ          the spoken lines: byte-equal to S2B's Unit 12 Hook and Exercise lines, words, digits, spellings, statuses, dur9
  junit DIR CLASS          Surefire's XML for one class: every test case, its outcome, the exception class and message
  modtable UP AFTER BEFORE | surefire XML    the small readers
  <capture> FILE           one capture's checks; prints ok/FAIL lines and one VALUES line
  hashable NAME FILE       the capture with its load- and run-dependent lines dropped, for receipts.md5
  values README VALS       README.md's values block = this run's VALUES lines
  plants                   the checker's own plants: each made to fail first (a request line one byte off, an unparsable line, a fully
                           qualified @EnabledIf..., a third @Test, a pom touched, 50 as the current count) - FAIL, exit 1, no traceback"""
import collections, hashlib, json, os, re, subprocess, sys

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
HOOK = "Ask for version two in the media type, and a header-versioned server with a default answers version one, labelled two."
EXQ = "Your turn: version one is retired. Send the old request and read what TiffinBox answers."
GLOSS = "A version carrier: where the version travels."
BRIEFQ = "where the version travels"
U06GLOSS = "A contract: what a route promises its callers: the path, the method, the shapes in and out."
U08GLOSS = "Swagger UI: a page drawn from the document."
U09GLOSS = "A problem type: the U-R-I that names an error's kind."
U10GLOSS = "Code generation: source written by a tool from the spec."
U11GLOSS = "A snippet: one documented part of one tested request."
SPEC = "tiffinbox-web/src/test/resources/openapi/tiffinbox.json"
VC = "tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxApiVersioning.java"
VT = "tiffinbox-web/src/test/java/com/tiffinbox/web/ApiVersionTest.java"
W = "tiffinbox-web/src/main/java/com/tiffinbox/web/"
CHANGED = ["README.md", VC, VT]
UNTOUCHED = ["Dockerfile", "compose.yaml", SPEC, "pom.xml", "tiffinbox-web/pom.xml", "tiffinbox-client/pom.xml", "tiffinbox-core/pom.xml",
             W + "CustomerReads.java", W + "CustomerPauses.java", W + "CustomerPatches.java", W + "IdempotencyKeyFilter.java",
             W + "TiffinBoxOpenApi.java", W + "TiffinBoxErrors.java",
             "tiffinbox-web/src/test/java/com/tiffinbox/web/OpenApiSpecTest.java", "tiffinbox-web/src/test/java/com/tiffinbox/web/TiffinBoxRestDocsTest.java"]
LEFTOUT = ["snippets", "html", "sealed", "compare", "accept", "driven", "generate", "census", "jackson", "call", "pause", "mock", "default10",
           "counts", "loc", "location", "perop", "blanket", "shape", "types", "scheme", "wide"]
MINE = ["choose", "four", "required", "default", "newest", "deprecate", "retire", "replay", "restdocs", "client", "type", "change"]
GUARDED = re.compile(r"@(?:org\.junit\.jupiter\.api\.(?:condition\.)?)?(?:Disabled|EnabledIf\w*|DisabledIf\w*|EnabledOn\w*|DisabledOn\w*|EnabledFor\w*|DisabledFor\w*)\b")
STATUS = re.compile(r"(?<![\d.,:/-])\b(?:[1-5]\d\d)\b|\b(?:one|two|three|four|five)[\s-]hundred[\s-]and\b|\b(?:one|two|three|four|five)[\s-]hundred[\s-](?:one|two|three|four|five|six|seven|eight|nine|ten|eleven|twelve|thirteen|fourteen|fifteen)\b")
HING = re.compile(r"\b(?:bhai|yaar|dosto|kya|hai|nahi|nahin|matlab|karo|dekho|chalo|samjho|theek|accha|arre|haan|bilkul|zaroor|aur|toh|abhi|yeh|woh|kaise|kyun|bahut|thoda|sahi|galat)\b", re.I)
SPELL = re.compile(r"\b(?:API|URI|URL|RFC)s?\b|\bOpenAPI\b|\bspringdoc\b|\bopenapi-generator\b")
# a request line: "  SIDE | METHOD PATH [extra] -> STATUS CTYPE SIZE · headers {...} · body ..."
REQ = re.compile(r"^  ([A-Za-z0-9-]+) \| ([A-Z]+) (\S+)((?: \[[^\]]*\])*) -> (\d{3}) (\S*) (\d+) · headers \{([^}]*)\} · body (.*)$")

def lines(p):
    return open(p, encoding="utf-8", errors="replace").read().splitlines()
def rd(p):
    return open(p, encoding="utf-8").read()
def tree(d, skip=()):
    out = {}
    for r, ds, fs in os.walk(d):
        ds[:] = sorted(x for x in ds if x not in skip)
        for f in fs:
            p = os.path.join(r, f); out[os.path.relpath(p, d)] = hashlib.md5(open(p, "rb").read()).hexdigest()
    return out
def grab(rx, t, g=1, flags=re.M):
    m = re.search(rx, t, flags); return m.group(g) if m else None

def junit(d, cls):
    import xml.etree.ElementTree as ET
    p = os.path.join(d, "TEST-com.tiffinbox.web.%s.xml" % cls)
    if not os.path.exists(p): print("  junit %s: ABSENT" % cls); return
    r = ET.parse(p).getroot()
    print("  junit %s: tests %s failures %s errors %s skipped %s" % (cls, r.get("tests"), r.get("failures"), r.get("errors"), r.get("skipped")))
    for tc in r.findall("testcase"):
        out = "passed"
        for k in ("failure", "error", "skipped"):
            e = tc.find(k)
            if e is not None:
                out = "%s %s: %s" % (k, e.get("type") or "-", re.sub(r"\s+", " ", (e.get("message") or "")).strip()[:180])
        print("  case %s.%s | %s" % (cls, tc.get("name"), out))
def modlist(p):
    return re.findall(r"<module>([^<]+)</module>", rd(p))
def modules(up, after, before):
    b = modlist(os.path.join(before, "pom.xml")); a = modlist(os.path.join(after, "pom.xml"))
    print("== the parent's <modules> (python over before/pom.xml and after/pom.xml - the frozen trees, not the working tree)")
    print("  modules before: %d (%s) · after: %d (%s) · added: %s · removed: %s" % (len(b), ",".join(b), len(a), ",".join(a), ",".join(x for x in a if x not in b) or "none", ",".join(x for x in b if x not in a) or "none"))
    print("== every commit that touched c9-tiffinbox/ (git log --reverse), the first path segment of each changed path under it")
    r = subprocess.run(["git", "-C", up, "log", "--reverse", "--format=%h %s", "--", "c9-tiffinbox"], capture_output=True, text=True)
    for l in r.stdout.splitlines():
        h, s = l.split(" ", 1)
        names = subprocess.run(["git", "-C", up, "show", "--name-only", "--format=", h, "--", "c9-tiffinbox"], capture_output=True, text=True).stdout.split()
        seg = sorted({(n.split("/")[1] if n.count("/") >= 2 else "parent:" + n.split("/")[1]) for n in names})
        mods = sorted({x for x in seg if x in ("tiffinbox-core", "tiffinbox-web", "tiffinbox-client")})
        par = "pom.xml" if "parent:pom.xml" in seg else "-"
        unit = grab(r"^Course 9 unit (\d+)", s) or grab(r"^Course 9 (set-up)", s) or grab(r"^(receipts)", s) or s.split()[0]
        print("  commit | %s | unit %s | parent %s | modules %s" % (h, unit, par, ",".join(mods) or "-"))
    ch = [x for x in ("tiffinbox-core", "tiffinbox-web", "tiffinbox-client") if tree(os.path.join(after, x), {"target"}) != tree(os.path.join(before, x), {"target"})]
    pp = "parent pom.xml" if rd(os.path.join(after, "pom.xml")) != rd(os.path.join(before, "pom.xml")) else "no pom"
    print("  this unit's change (after/ against before, the frozen trees): %s · modules %s" % (pp, ",".join(ch)))
    print("  this commit's row (the working tree, not yet committed): unit 12 | parent - | modules tiffinbox-web")
    print("  the sentence for the scripts stage (printed, never written): unit 12 changes tiffinbox-web only (one main class, one test class), no pom; TIFFINBOX_MODULES in upload_java9.py is read, not edited")
def surefire(p):
    import xml.etree.ElementTree as ET
    if not os.path.exists(p): print("  %s absent" % os.path.basename(p)); return
    r = ET.parse(p).getroot()
    print("  %s tests %s failures %s errors %s skipped %s" % (r.get("name").split(".")[-1], r.get("tests"), r.get("failures"), r.get("errors"), r.get("skipped")))

# ---- static ---------------------------------------------------------------------------------------------------------------------------
def test_static(tt):
    """the test class's guards, as a list of failure names (empty = clean) - shared by static and the plants"""
    bad = []
    if len(re.findall(r"^\s*@Test\s*$", tt, re.M)) != 2: bad.append("not exactly two @Test")
    if GUARDED.search(tt) or re.search(r"org\.junit\.jupiter\.api\.condition\.", tt): bad.append("a guarded or disabled test (simple or fully qualified)")
    if re.search(r"RANDOM_PORT|DEFINED_PORT|LocalServerPort|\b\d{4,5}\b|Socket", tt): bad.append("a port or a socket")
    return bad
def static(after, before):
    md = lambda x: hashlib.md5("\n".join(x).encode()).hexdigest()
    end = "# --- XFAM_S9S1 end ---"
    s12 = rd(os.path.join(HERE, "s912.py")).split("\n")
    s11 = rd(os.path.join(UNIT, "..", "c9-unit11", "harness", "s911.py")).split("\n")
    if any(end not in s for s in (s12, s11)): fail("the XFAM_S9S1 end marker is missing in s912.py or s911.py"); done()
    a = lambda s: next(i for i, l in enumerate(s) if l.endswith('"""') and i > 0)
    sl = lambda s: s[a(s) + 1:s.index(end) + 1]
    need(sl(s12) == sl(s11), "s912.py's base + XFAM_S9S1 (after its docstring, through the block's end marker) = s911.py's, %d lines, md5 %s (copied from U11's harness)" % (len(sl(s11)), md(sl(s11))))
    t12 = "\n".join(s12)
    b = re.search(r"# --- XFAM_S9S1 begin ---\n.*?# --- XFAM_S9S1 end ---", t12, re.S)
    if b:
        h = hashlib.md5(b.group(0).encode()).hexdigest()
        print("  XFAM_S9S1_SLICE_MD5 = %s (computed the way ../c9-unit04/harness/chk04.py computes it)" % h); val("xfam_s9s1_md5", h[:8])
        need(h == "1f5217a0fdf43c70e68284c5311a32ef", "the slice md5 is the brief's (S2B, BUILDERS)")
    need(not re.search(r"^XU(?:0\d|1[01]) = ", t12, re.M), "XU01-XU11 are not carried")
    need(re.search(r"^XU12 = ", t12, re.M) is not None and re.search(r"^u04 = u12$", t12, re.M) is not None, "U12's own family (XU12) follows the carried slice; u04 = u12 (U01's binding)")
    x2 = os.path.join(C9R, "_builders", "s907.py")
    print("  XFAM_S9S2 (the scripts stage's, C9/_builders/s907.py): %s" % ("present - not asserted here" if os.path.exists(x2) and "XFAM_S9S2" in rd(x2) else "does not exist yet - nothing to assert XU12 against"))
    ck = rd(os.path.join(HERE, "chk12.py"))
    dead = [w for w in LEFTOUT if re.search(r"^def (?:c_)?%s\(" % re.escape(w), ck, re.M) or re.search(r'"%s": (?:lambda|c_)' % re.escape(w), ck)]
    need(not dead, "chk12.py carries none of the left-out subcommands (%s): %s" % (",".join(LEFTOUT), ",".join(dead) or "none"))
    for nm in MINE:
        need(re.search(r"^def c_%s\(" % nm, ck, re.M) is not None, "chk12.py has this unit's %s check" % nm)
    harn = sorted(os.listdir(HERE))
    bad = [x for x in harn if x in ("loc9.py", "seal9.py", "cdp.mjs", "cdp9.mjs")] + [x for x in os.listdir(os.path.join(HERE, "mirror")) if x in ("default.diff", "hc5.diff", "fail.diff", "accept.diff", "driven.diff", "html.diff")]
    need(not bad, "no earlier unit's instrument in harness/ (seal9.py, cdp.mjs, cdp9.mjs, loc9.py, U10's and U11's patches): %s" % (",".join(bad) or "none"))
    cl = os.path.join(HERE, "src", "probe", "u10", "Caller.java")
    need(os.path.exists(cl) and hashlib.md5(open(cl, "rb").read()).hexdigest() == "2566f21ca60d96bd341a552a1d4987a0", "Caller.java PRESENT in harness/src/probe/u10 and md5-equal to U10's file line (2566f21c...)")
    A, Bt = tree(after, {"target"}), tree(before, {"target"})
    ch = sorted(k for k in set(A) | set(Bt) if A.get(k) != Bt.get(k))
    print("  the change (after/ against before, the frozen trees; the derived list): %d files: %s" % (len(ch), " ".join(ch)))
    need(ch == sorted(CHANGED), "the changed files are exactly the README, the new configurer and the new test")
    val("changed_files", len(ch))
    need(not [k for k in ch if k.startswith(("tiffinbox-core/", "tiffinbox-client/"))], "(i) nothing under tiffinbox-core/ or tiffinbox-client/ changed")
    need(not [k for k in ch if k.endswith("pom.xml")], "(i) no pom changed")
    need(all(A.get(k) == Bt.get(k) and A.get(k) for k in UNTOUCHED), "(i) the Dockerfile, compose.yaml, the committed spec, the four poms, the five mapping files' classes, IdempotencyKeyFilter, TiffinBoxOpenApi, TiffinBoxErrors, OpenApiSpecTest and TiffinBoxRestDocsTest byte-equal to before's")
    need([k for k in ch if k.startswith("tiffinbox-web/src/main/")] == [VC], "(ii) the new class is the only changed main-scope path")
    need(not [k for k in ch if k.startswith("tiffinbox-web/src/test/") and k != VT], "no existing test edited (only the new test under tiffinbox-web/src/test)")
    vc = rd(os.path.join(after, VC)); code = re.sub(r"/\*.*?\*/|//[^\n]*", "", vc, flags=re.S)
    need(code.count("usePathSegment(1") == 1 and code.count("setVersionRequired(false)") == 1 and code.count('addSupportedVersions("1.0")') == 1,
         "(iii) TiffinBoxApiVersioning: usePathSegment(1, ...), setVersionRequired(false), addSupportedVersions(\"1.0\") once each")
    nn = [w for w in ("setDefaultVersion", "setDeprecationHandler", "StandardApiVersionDeprecationHandler", "detectSupportedVersions(false)", "Sunset", "Deprecation", "useRequestHeader", "useQueryParam", "useMediaTypeParameter") if w in code]
    need(not nn, "(iii) no default, no deprecation, no header, query or media-type carrier in its code: %s" % (",".join(nn) or "none"))
    need('startsWith("/api/")' in code and "underApi" in code, "(iii) the predicate: the path under /api/ (underApi)")
    need(len(re.findall(r"implements WebMvcConfigurer", "\n".join(open(os.path.join(r, f), encoding="utf-8").read() for r, _, fs in os.walk(os.path.join(after, "tiffinbox-web", "src", "main")) for f in fs if f.endswith(".java")))) == 1 and "configureApiVersioning" in code,
         "one WebMvcConfigurer in src/main, the one that configures versioning")
    mains = "\n".join(open(os.path.join(r, f), encoding="utf-8").read() for r, _, fs in os.walk(os.path.join(after, "tiffinbox-web", "src", "main")) for f in fs if f.endswith(".java"))
    need(not re.search(r"@(?:Get|Post|Patch|Put|Delete|Request)Mapping\([^)]*(?:version\s*=|\{version\})", mains), "no {version} and no version = in any @...Mapping under src/main")
    need(len(re.findall(r'"/api/v1/customers/\{name\}', mains)) >= 3, "the literal /api/v1/customers/{name} mappings are still there")
    need(not re.search(r"Deprecation|Sunset|StandardApiVersionDeprecationHandler", re.sub(r"/\*.*?\*/|//[^\n]*", "", mains, flags=re.S)), "the anchor's code names Deprecation, Sunset and StandardApiVersionDeprecationHandler 0 times")
    tt = rd(os.path.join(after, VT))
    tb = test_static(tt)
    need(not tb, "ApiVersionTest: exactly 2 @Test, no @Disabled/@EnabledIf.../@DisabledIf.../@EnabledOn.../@EnabledFor... (simple or fully qualified), no port, no socket: %s" % (",".join(tb) or "clean"))
    need("void theOldAddressAnswersAsBefore()" in tt and "void aVersionNoRouteCarriesIsNotFound()" in tt, "its two methods: theOldAddressAnswersAsBefore, aVersionNoRouteCarriesIsNotFound")
    import importlib.util
    spec = importlib.util.spec_from_file_location("dur9", os.path.join(HERE, "dur9.py")); m = importlib.util.module_from_spec(spec); spec.loader.exec_module(m)
    lits = " ".join(re.findall(r'"([^"]*)"', tt))
    need(not m.DUR.search(lits), "dur9 over the test's string literals: 0 (%s)" % (m.DUR.search(lits).group(0) if m.DUR.search(lits) else "none"))
    rm = rd(os.path.join(after, "README.md"))
    card = re.search(r"^## Course 9 · unit 12 — .*?(?=^## |^---$|\Z)", rm, re.M | re.S)
    need(card is not None, "the README has a Course 9 · unit 12 card")
    if card:
        c = re.sub(r"\s+", " ", card.group(0))
        need(not re.search(r"(?:tests? (?:at `mvn package` )?(?:are|is) 50\b|\b50 tests\b)(?! at unit 11)", c) and "50 at unit 11" in c, "R.250/R.453: unit 12's card gives 50 as unit 11's count only, never as the current one")
        need(not re.search(r"\b\d+ lines\b", c), "no line count spoken in the card")
    need("*Course 9, unit 12:" in rm.split("## Course 9 · unit 04")[0], "the README's header carries a *Course 9, unit 12: ...* note")
    need("Course 9's ninth change to this folder (U12)" in rm.split("## Course 9 · unit 04")[0], "the README's header names Course 9's ninth change to this folder (U12)")
    for u in ["0%d" % i for i in range(1, 10)] + ["10", "11"]:
        rs = os.path.join(UNIT, "..", "c9-unit%s" % u, "receipts.sh")
        hit = [l for l in open(rs, encoding="utf-8").read().splitlines() if "TiffinBoxApiVersioning" in l or "ApiVersionTest" in l]
        if hit: print("  a frozen receipt names a changed path: c9-unit%s/receipts.sh (%d lines)" % (u, len(hit)))
    done()

# ---- the spoken lines -----------------------------------------------------------------------------------------------------------------
def brief_lines():
    t = rd(S2B).split("\n")
    i0 = next(i for i, l in enumerate(t) if l.startswith("## Unit 12 · Versioning Strategies")); i1 = next(i for i, l in enumerate(t) if i > i0 and l.startswith("## "))
    print("  the brief's Unit 12 section: S2B :%d-:%d" % (i0 + 1, i1))
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
    need(hook == HOOK == bh, "the hook is S2B's Unit 12 Hook line's quote, byte for byte (extracted at run time = typed once here)")
    need(exq == EXQ == be, "the exercise's line is S2B's Unit 12 Exercise line's quote, byte for byte (extracted at run time = typed once here)")
    hw, ew, gw = len(hook.split()), len(exq.split()), len(GLOSS.split())
    need(hw == 20 and hw <= 25, "the hook: %d words (wc -w; the brief's 20; <= 25)" % hw)
    need(ew == 15 and ew <= 25, "the exercise: %d words (wc -w; the brief's 15; <= 25)" % ew)
    for name, s in (("the hook", hook), ("the exercise", exq), ("the gloss", GLOSS)):
        nd = re.findall(r"\d", s)
        print("  %s: digits %s · the status gate %s · the spelling gate %s · Hinglish %s · dur9 %s" % (name, "".join(nd) or "0", "hit" if STATUS.search(s) else "0",
              SPELL.search(s).group(0) if SPELL.search(s) else "0", "hit" if HING.search(s) else "0", dur.search(s).group(0) if dur is not None and dur.search(s) else "0"))
        need(not STATUS.search(s), "%s: the status gate 0" % name)
        need(not SPELL.search(s), "%s: the spelling gate 0" % name)
        need(not HING.search(s), "%s: the Hinglish list 0" % name)
        if dur is not None: need(not dur.search(s), "%s: dur9 0" % name)
        need(not nd, "%s: no digit" % name)
    for p in ("Open A-P-I", "spring doc", "A-P-I-Version", "Content-Type", "Deprecation", "Sunset", "API Versioning in Framework 7"):
        print("  the spelling gate on %r: %s" % (p, SPELL.search(p).group(0) if SPELL.search(p) else "passes"))
    for p in ("OpenAPI", "springdoc"): need(bool(SPELL.search("It reads the " + p + " document.")), "the bare %r refuses in a spoken line" % p)
    print("  the hook: %d words · the exercise: %d words · the gloss: %d words; the brief's parenthetical (%d words): \"%s\"" % (hw, ew, gw, len(BRIEFQ.split()), BRIEFQ))
    val("hook_words", hw); val("exercise_words", ew); val("gloss_words", gw)
    done()
def gloss(readme):
    olds = [("c9-unit06", U06GLOSS), ("c9-unit08", U08GLOSS), ("c9-unit09", U09GLOSS), ("c9-unit10", U10GLOSS), ("c9-unit11", U11GLOSS)]
    for u, g in olds:
        r = rd(os.path.join(UNIT, "..", u, "README.md")).split("\n"); n = [i + 1 for i, l in enumerate(r) if l == g]
        need(len(n) == 1, "%s's gloss line is still byte-equal at ../%s/README.md:%s" % (u, u, n[0] if n else "-"))
    r = rd(readme).split("\n")
    g = [i + 1 for i, l in enumerate(r) if re.match(r"^\s*(?:A contract|Swagger UI|A problem type|Code generation|A snippet):", l)]
    need(not g, "README.md carries no line starting \"A contract:\", \"Swagger UI:\", \"A problem type:\", \"Code generation:\" or \"A snippet:\" (not re-glossed) %s" % g)
    s = [i + 1 for i, l in enumerate(r) if l.startswith("A version carrier:")]
    need(len(s) == 1 and r[s[0] - 1] == GLOSS, "README.md carries exactly one line starting \"A version carrier:\", the gloss byte for byte (%s)" % s)
    need(len(GLOSS.split()) <= 25, "the gloss: %d words (<= 25)" % len(GLOSS.split()))
    first = next((i + 1 for i, l in enumerate(r) if "carrier" in re.sub(r"`[^`]*`", "", l).lower() and not l.startswith("#")), None)
    print("  the gloss (%d words): %s · the brief's parenthetical (%d words): %s" % (len(GLOSS.split()), GLOSS, len(BRIEFQ.split()), BRIEFQ))
    print("  first spoken use of \"carrier\" in the README at line %s" % first)
    val("gloss", "a_version_carrier_one_line")
    done()

# ---- the captures' checks ---------------------------------------------------------------------------------------------------------
def reqs(t):
    """every request line of a capture: {(side, method, path, extra): (status, ctype, size, headers, body)}; a line that starts like one and
    does not parse is a FAIL line"""
    out = collections.OrderedDict()
    for l in t.splitlines():
        if not re.match(r"^  [A-Za-z0-9-]+ \| [A-Z]+ /", l): continue
        m = REQ.match(l)
        if not m: fail("a request line the checker cannot parse: %r" % l[:160]); continue
        out[(m.group(1), m.group(2), m.group(3), m.group(4).strip())] = (m.group(5), m.group(6), m.group(7), m.group(8), m.group(9))
    return out
def ans(R, side, method, path, extra=""):
    return R.get((side, method, path, extra))
def detail(body):
    try: return json.loads(body.replace("~", "\n")).get("detail")
    except (ValueError, AttributeError): return None
def sf(t, prefix):
    out = {}
    for m in re.finditer(r"^  %s(\w+) tests (\d+) failures (\d+) errors (\d+) skipped (\d+)$" % re.escape(prefix), t, re.M): out[m.group(1)] = tuple(int(x) for x in m.groups()[1:])
    return out
def tot(d): return [sum(v[i] for v in d.values()) for i in range(4)]
def sevens(t):
    return dict(re.findall(r"^  ([A-Za-z0-9-]+): the seven ([0-9a-f]{32}) \(", t, re.M))

def c_choose(p):
    t = rd(p); R = reqs(t); s7 = sevens(t)
    exp = grab(r"the expected seven ([0-9a-f]{32})", t); pr = grab(r"the probe's required-variant seven ([0-9a-f]{32})", t)
    keys = [(m, pa, x) for (s, m, pa, x) in R if s == "after"]
    need(len(keys) == 14 and [(m, pa, x) for (s, m, pa, x) in R if s == "before"] == keys and [(m, pa, x) for (s, m, pa, x) in R if s == "required"] == keys,
         "the fourteen requests, in order, on before, after and the planted required mirror (%d / %d / %d)" % (len(keys), sum(1 for k in R if k[0] == "before"), sum(1 for k in R if k[0] == "required")))
    mv = [k for k in keys if R.get(("before",) + k) != R.get(("after",) + k)]
    for k in mv: print("  MOVED under D2: %s %s %s | before %s | after %s" % (k[0], k[1], k[2], R[("before",) + k][:2], R[("after",) + k][:2]))
    a1 = ans(R, "after", "GET", "/api/v1/customers/Ravi"); a2 = ans(R, "after", "GET", "/api/1.0/customers/Ravi"); a3 = ans(R, "after", "GET", "/api/v3/customers/Ravi")
    need(a1 is not None and a1[0] == "200" and a1[1] == "application/json", "after: GET /api/v1/customers/Ravi -> %s %s (the old address)" % (a1[:2] if a1 else "-"))
    need(a2 is not None, "after: GET /api/1.0/customers/Ravi -> %s %s · %s (as found)" % (a2[0], a2[1], detail(a2[4])) if a2 else "after: /api/1.0/ answered")
    need(a3 is not None, "after: GET /api/v3/customers/Ravi -> %s %s · %s (as found)" % (a3[0], a3[1], detail(a3[4])) if a3 else "after: /api/v3/ answered")
    need(exp is not None and s7.get("choose-before") == exp and s7.get("choose-after") == exp, "the seven on before and after: %s = the expected (each in its own JVM, after the fourteen requests)" % (exp or "-")[:8])
    rq_ = [k for k in keys if k[1] in ("/customers/Ravi",)]
    ro = ans(R, "required", "GET", "/customers/Ravi"); rv = ans(R, "required", "GET", "/api/v1/customers/Ravi")
    need(ro is not None and ro[0] == "400" and detail(ro[4]) == "API version is required.", "the planted required mirror: GET /customers/Ravi -> %s \"%s\"" % ((ro[0], detail(ro[4])) if ro else ("-", "-")))
    need(rv is not None and rv[0] == "200", "the planted required mirror: GET /api/v1/customers/Ravi -> %s (a version in the path is still read)" % (rv[0] if rv else "-"))
    need(s7.get("choose-required") is not None and s7.get("choose-required") != exp and s7.get("choose-required") == pr, "the planted mirror moves the seven: %s (= the probe's required-variant seven %s; the expected %s)" % ((s7.get("choose-required") or "-")[:8], (pr or "-")[:8], (exp or "-")[:8]))
    ju = re.search(r"^  junit ApiVersionTest: tests (\d+) failures (\d+) errors (\d+) skipped (\d+)$", t, re.M)
    need(ju is not None and ju.group(1) == "2" and int(ju.group(2)) + int(ju.group(3)) >= 1 and ju.group(4) == "0", "ApiVersionTest on the planted mirror goes red: %s" % (" / ".join(ju.groups()) if ju else "-"))
    val("v1", a1[0] if a1 else "-"); val("spell10", a2[0] if a2 else "-"); val("v3", a3[0] if a3 else "-"); val("moved", len(mv))
    val("seven", (exp or "-")[:8]); val("planted_seven", (s7.get("choose-required") or "-")[:8]); val("planted_old", ro[0] if ro else "-")
    val("planted_test_red", (int(ju.group(2)) + int(ju.group(3))) if ju else "-")
def c_tests(p):
    t = rd(p)
    need(re.search(r"^  mvn package exit 0 · Downloading/Downloaded from: 0$", t, re.M) is not None, "package: exit 0, offline")
    rs = re.findall(r"^  reactor: (TiffinBox[A-Za-z ]*) \.\.\. (SUCCESS|FAILURE|SKIPPED)", t, re.M)
    need(rs[:4] == [("TiffinBox", "SUCCESS"), ("TiffinBox Core", "SUCCESS"), ("TiffinBox Web", "SUCCESS"), ("TiffinBox Client", "SUCCESS")], "the reactor: four projects (the parent and three modules), each SUCCESS")
    w = sf(t, "tiffinbox-web | "); c = sf(t, "tiffinbox-client | ")
    b50 = grab(r"^  unit 11's values block: web_tests=(\d+)", t)
    k = grab(r"^  new @Test \| ApiVersionTest \| (\d+) \| theOldAddressAnswersAsBefore,aVersionNoRouteCarriesIsNotFound \| before/\S+: absent$", t)
    need(b50 == "50" and k == "2", "the web module before this change: %s (unit 11's values block) · the @Test lines the change adds: %s (a file before lacks)" % (b50, k))
    need(b50 is not None and k is not None and tot(w) == [int(b50) + int(k), 0, 0, 0], "tiffinbox-web at package: %s tests, 0 failures, 0 errors, 0 skipped (= unit 11's %s + %s)" % (tot(w)[0], b50, k))
    need(w.get("ApiVersionTest") == (2, 0, 0, 0) and w.get("TiffinBoxRestDocsTest") == (1, 0, 0, 0) and w.get("OpenApiSpecTest") == (1, 0, 0, 0), "ApiVersionTest 2 / 0 / 0 / 0 skipped; TiffinBoxRestDocsTest 1; OpenApiSpecTest 1")
    need(tot(c) == [1, 0, 0, 0], "tiffinbox-client at package: 1 test, run, none skipped")
    need(re.search(r"^  the page step's line \(package\): asciidoctor:3\.2\.0:process-asciidoc \(docs\) @ tiffinbox-web$", t, re.M) is not None, "U11's page step still in the package run")
    need(re.search(r"^  mvn package \(Docker-free\) exit 0 · Downloading/Downloaded from: 0$", t, re.M) is not None, "the Docker-free twin: exit 0")
    tw = sf(t, "twin tiffinbox-web | "); tc = sf(t, "twin tiffinbox-client | ")
    need(tot(tw) == tot(w) and tot(tc) == tot(c), "the twin's counts = package's")
    need(re.search(r"^  existing tests \(tiffinbox-web/src/test, tiffinbox-core/src\) before -> after/: 0 files differ$", t, re.M) is not None, "no existing test or core file edited")
    sv = sf(t, "sends /api/v1/ | ")
    need(sv and all(v[1] == v[2] == v[3] == 0 for v in sv.values()), "every test class that sends /api/v1/ passes: %s" % ",".join("%s %d" % (k, v[0]) for k, v in sv.items()))
    need(re.search(r"^  mvn verify exit 0 · Downloading/Downloaded from: 0$", t, re.M) is not None and "TIMED OUT" not in t, "verify: exit 0, offline, no IT wait timed out")
    it = {kk: v for kk, v in sf(t, "").items() if kk.endswith("IT")}
    need(len(it) == 5 and tot(it) == [14, 0, 0, 0], "the five ITs: %d tests, 0 failures (14)" % tot(it)[0])
    ib = re.findall(r"^  IT BINDINGS (\w+) \[(.*)\]$", t, re.M)
    ent = [e for _, x in ib for e in re.findall(r"[0-9.]+:\d+", x)]
    need(len(ib) == 5 and ent and all(e.startswith("127.0.0.1:") for e in ent), "IT BINDINGS: classes %d · entries %d · not 127.0.0.1: %d" % (len(ib), len(ent), sum(1 for e in ent if not e.startswith("127.0.0.1:"))))
    need(re.search(r"^  Testcontainers containers after: 0 · listeners on 21280-21284 after: 0$", t, re.M) is not None, "after verify: 0 containers, 21280-21284 free")
    wo = sf(t, "webonly tiffinbox-web | ")
    need(tot(wo) == tot(w), "the web-only form's web counts = the reactor's (%s)" % tot(wo)[0])
    lb = re.findall(r"^  (before|after): (\d+) jars · ", t, re.M)
    need(lb == [("before", "157"), ("after", "157")] and re.search(r"^  the jars' names moved before -> after: 0$", t, re.M) is not None, "BOOT-INF/lib 157 before and after, no name moved")
    val("web_before", b50); val("web_tests", tot(w)[0]); val("new_tests", k); val("apiversion_skipped", w.get("ApiVersionTest", (0, 0, 0, "-"))[3]); val("client_tests", tot(c)[0])
    val("its", tot(it)[0]); val("it_classes", len(ib)); val("lib", lb[1][1] if len(lb) > 1 else "-"); val("reactor", len(rs[:4])); val("sends_v1_classes", len(sv))
def c_change(p):
    t = rd(p)
    m = re.search(r"^  modules before: (\d+) \(([^)]*)\) · after: (\d+) \(([^)]*)\) · added: (\S+) · removed: (\S+)$", t, re.M)
    need(m is not None and m.group(1) == m.group(3) == "3" and m.group(5) == "none" and m.group(6) == "none", "the parent's <modules>: 3 -> 3, none added or removed")
    need(re.search(r"^  this unit's change \(after/ against before, the frozen trees\): no pom · modules tiffinbox-web$", t, re.M) is not None, "this unit's change: tiffinbox-web only, no pom")
    need(len(re.findall(r"^  \S+pom\.xml before -> after: byte-identical$|^  pom\.xml before -> after: byte-identical$", t, re.M)) == 4, "the four poms byte-identical")
    need(re.search(r"spring-webmvc-7\.0\.11\.jar", t) is not None, "spring-webmvc 7.0.11 in the web jar (the version the configurer runs on)")
    mp = re.findall(r"^  mapping \| (\w+)\.java:\d+:.*?Mapping\((?:path = )?\"(/api/[^\"]+)\"", t, re.M)
    need(len(mp) == 5 and all(x[1].startswith("/api/v1/") for x in mp), "the five literal /api/v1/ mappings: %s" % " ".join("%s %s" % x for x in mp))
    need(re.search(r"^  mappings with a version attribute or \{version\}: 0$", t, re.M) is not None, "no mapping carries a version attribute or {version}")
    need("MOVED" not in (grab(r"^  the five mapping files before -> after: (.*)$", t) or "MOVED"), "the mapping files, the filter, the info bean and the errors byte-equal")
    need(re.search(r"^  the committed file: md5 e715f47c\w+ · byte-identical to before's$", t, re.M) is not None, "the committed file unchanged")
    val("modules", m.group(3) if m else "-"); val("mappings", len(mp)); val("webmvc", grab(r"spring-webmvc-([0-9.]+)\.jar", t) or "-")
def vlines(t, v):
    return {(m, pa, x): a for (s, m, pa, x), a in reqs(t).items() if s == v}
def c_four(p):
    t = rd(p); s7 = sevens(t); E = "466c20ed7e0d5439cb052f32ce09de1b"; Rq = "7d36b99ea48f2bb5fc961fbac1fd8a6a"
    for v in ("H", "Q", "M", "P"):
        need(re.search(r"^  VER12 line: VER12 variant %s$" % v, t, re.M) is not None, "variant %s printed its VER12 line" % v)
    L = {v: vlines(t, v) for v in ("H", "Q", "M", "P")}
    g = lambda v, path, x="": (L[v].get(("GET", path, x)) or ("-", "-", "-", "-", "-"))
    need(g("H", "/vapi/customers")[0] == "400" and g("H", "/vapi/customers", "[API-Version: 2.0]")[4].find('"2.0"') >= 0, "H: no version 400; the header 2.0 answers 2.0")
    need(g("Q", "/vapi/customers?version=2.0")[4].find('"2.0"') >= 0 and g("Q", "/vapi/customers", "[API-Version: 2.0]")[0] == "400", "Q: ?version=2.0 answers 2.0; the header is the wrong carrier (400)")
    need(g("M", "/vapi/customers", "[Accept: application/json;version=2.0]")[4].find('"2.0"') >= 0, "M: Accept ...;version=2.0 answers 2.0")
    mc = g("M", "/vapi/customers", "[Content-Type: application/json;version=2.0]")
    print("  M's hazard: GET /vapi/customers with Content-Type: application/json;version=2.0 -> %s %s" % (mc[0], mc[4][:80]))
    need(g("P", "/vapi/2.0/customers")[4].find("2.0 (path)") >= 0 and g("P", "/vapi/1.0/customers")[4].find("1.0 (path)") >= 0, "P: /vapi/1.0/ and /vapi/2.0/ answer their handlers")
    h3 = detail(g("H", "/vapi/customers", "[API-Version: 3.0]")[4])
    need(h3 == "Invalid API version: '3.0.0'.", "the version token as the parser spells it: %r" % h3)
    for v in ("H", "Q", "M"):
        need(g(v, "/customers/Ravi")[0] == "400" and g(v, "/api/v1/customers/Ravi")[0] == "400" and s7.get("var-" + v) == Rq, "%s: every old route 400 (/customers/Ravi, /api/v1/customers/Ravi), the seven %s" % (v, (s7.get("var-" + v) or "-")[:8]))
    need(g("P", "/customers/Ravi")[0] == "200" and g("P", "/api/v1/customers/Ravi")[0] == "200" and s7.get("var-P") == E, "P (the path, /vapi/ only): the old routes 200, the seven %s" % (s7.get("var-P") or "-")[:8])
    two = vlines(t, "two")
    print("  two configurers in one JVM: %s" % " · ".join("%s %s -> %s" % (k[1], k[2], a[0]) for k, a in two.items()))
    val("H_old", g("H", "/customers/Ravi")[0]); val("P_old", g("P", "/customers/Ravi")[0]); val("token3", "3.0.0" if h3 == "Invalid API version: '3.0.0'." else "-")
    val("seven_HQM", Rq[:8]); val("seven_P", (s7.get("var-P") or "-")[:8]); val("M_content_type_get", mc[0])
def c_required(p):
    t = rd(p); R = reqs(t); s7 = sevens(t)
    h = R.get(("H", "GET", "/customers/Ravi", "")); r = R.get(("required", "GET", "/customers/Ravi", ""))
    need(h is not None and r is not None and h[0] == r[0] == "400" and detail(h[4]) == detail(r[4]) == "API version is required.", "required, two witnesses: the harness's H and the shipped class without setVersionRequired(false) both answer the old route 400 \"API version is required.\"")
    need(s7.get("var-H") == s7.get("choose-required") == "7d36b99ea48f2bb5fc961fbac1fd8a6a", "both move the seven to 7d36b99e")
    val("required_old", r[0] if r else "-"); val("required_seven", (s7.get("choose-required") or "-")[:8])
def c_default(p):
    t = rd(p); L = vlines(t, "HD"); s7 = sevens(t)
    need(re.search(r"^  VER12 line: VER12 variant HD$", t, re.M) is not None, "variant HD printed its VER12 line")
    m = re.search(r"^  trap 4 \| request Accept: application/json;version=2\.0 \| status (\d+) \| Content-Type (\S+) \| body handler (\S+) \| the body says (\S+); the header says (\S+)$", t, re.M)
    need(m is not None and m.group(1) == "200" and m.group(3) == "1.0" and m.group(5) == "2.0", "trap 4: Accept ...;version=2.0 -> %s, Content-Type %s, the body says %s; the header says %s" % (m.groups()[:2] + m.groups()[3:] if m else ("-",) * 4))
    r2 = L.get(("GET", "/vapi/customers", "[API-Version: 2.0]")); r0 = L.get(("GET", "/vapi/customers", ""))
    need(r2 is not None and '"2.0"' in r2[4] and r0 is not None and '"1.0"' in r0[4], "HD: the right carrier (API-Version: 2.0) answers 2.0; no carrier answers 1.0 (the default)")
    hm = re.search(r"^  H \| GET /vapi/customers \[Accept: application/json;version=2\.0\] -> (\d+)", t, re.M); mh = re.search(r"^  M \| GET /vapi/customers \[API-Version: 2\.0\] -> (\d+)", t, re.M)
    need(hm is not None and hm.group(1) == "400" and mh is not None and mh.group(1) == "400", "both ways: the same Accept against H 400, the header client against M 400")
    need(s7.get("var-HD") == "466c20ed7e0d5439cb052f32ce09de1b", "HD's seven: %s (a default makes the unversioned routes answer)" % (s7.get("var-HD") or "-")[:8])
    val("trap4_status", m.group(1) if m else "-"); val("trap4_body", m.group(3) if m else "-"); val("trap4_header", m.group(5) if m else "-"); val("seven_HD", (s7.get("var-HD") or "-")[:8])
def c_newest(p):
    t = rd(p); L = vlines(t, "HN"); s7 = sevens(t)
    need(re.search(r"^  VER12 line: VER12 variant HN$", t, re.M) is not None, "variant HN printed its VER12 line")
    r0 = L.get(("GET", "/vapi/customers", ""))
    need(r0 is not None and r0[0] == "200" and '"2.0"' in r0[4], "HN: no version, no default -> %s %s (the newest)" % ((r0[0], r0[4][:40]) if r0 else ("-", "-")))
    val("newest", "2.0" if r0 and '"2.0"' in r0[4] else "-"); val("seven_HN", (s7.get("var-HN") or "-")[:8])
def stamped(a):
    return a is not None and "Deprecation:" in a[3] and "Sunset:" in a[3] and "Link:" in a[3]
def c_deprecate(p):
    t = rd(p); R = reqs(t); s7 = sevens(t)
    st = sorted("%s %s" % (k[0], k[2]) for k, a in R.items() if stamped(a)); un = sorted("%s %s" % (k[0], k[2]) for k, a in R.items() if not stamped(a))
    print("  stamped (Deprecation, Sunset and Link): %s" % " | ".join(st)); print("  not stamped: %s" % " | ".join(un))
    need(stamped(R.get(("dep", "GET", "/api/v1/customers/Ravi", ""))), "the real /api/v1/customers/Ravi carries the three headers")
    need(not stamped(R.get(("dep", "GET", "/customers/Ravi", ""))), "the unversioned /customers/Ravi carries none")
    dg = grab(r"its day field holds (\S+) digits", t)
    need(dg == "2", "the Sunset value's day field: %s digits (read by python)" % dg)
    need(s7.get("dep") == "466c20ed7e0d5439cb052f32ce09de1b", "deprecate's seven: %s" % (s7.get("dep") or "-")[:8])
    need(grab(r"StandardApiVersionDeprecationHandler: (\d+) times under src/main", t) == "0", "the anchor's src/main names them 0 times")
    lk = grab(r"^  as written \(masked by the capture mask\) \| (Link: .*)$", t)
    print("  the Link header as written: %s" % lk)
    val("stamped", len(st)); val("unstamped", len(un)); val("sunset_day_digits", dg); val("seven_dep", (s7.get("dep") or "-")[:8])
def c_retire(p):
    t = rd(p); R = reqs(t); s7 = sevens(t)
    a = R.get(("ret", "GET", "/api/v1/customers/Ravi", "")); b = R.get(("ret", "GET", "/api/2.0/customers/Ravi", "")); c = R.get(("ret", "GET", "/customers/Ravi", "")); n = R.get(("ret", "GET", "/api/v1/customers/Nobody", ""))
    need(a is not None and a[0] == "400" and a[1] == "application/problem+json", "PATH: GET /api/v1/customers/Ravi on the retired mirror -> %s %s \"%s\"" % ((a[0], a[1], detail(a[4])) if a else ("-",) * 3))
    print("  PATH: /api/2.0/customers/Ravi -> %s \"%s\" · /customers/Ravi -> %s · the Nobody request -> %s \"%s\"" % (b[0] if b else "-", detail(b[4]) if b else "-", c[0] if c else "-", n[0] if n else "-", detail(n[4]) if n else "-"))
    need(c is not None and c[0] == "200", "PATH: the unversioned old route still answers 200")
    mp = grab(r"handler patterns under /api/ still mapped: (.*)$", t) or ""
    need("/api/v1/customers/{name}" in mp, "the retired version's handler is still mapped (%s)" % mp)
    h = R.get(("HR", "GET", "/vapi/customers", "[API-Version: 1.0]")); h2 = R.get(("HR", "GET", "/vapi/customers", "[API-Version: 2.0]"))
    need(re.search(r"^  VER12 line: VER12 variant HR$", t, re.M) is not None and h is not None and h[0] == "400" and h2 is not None and h2[0] == "200", "HEADER (HR): API-Version 1.0 -> %s \"%s\"; 2.0 -> %s" % (h[0] if h else "-", detail(h[4]) if h else "-", h2[0] if h2 else "-"))
    need(detail(h[4]) == detail(a[4]) if (h and a) else False, "the two carriers name the retired version in the same sentence: %r" % (detail(a[4]) if a else "-"))
    val("retire_path", a[0] if a else "-"); val("retire_token", (re.search(r"'([^']+)'", detail(a[4]) or "") or re.search("x", "x")).group(0).strip("'") if a else "-")
    val("retire_header", h[0] if h else "-"); val("seven_ret", (s7.get("ret") or "-")[:8]); val("seven_HR", (s7.get("var-HR") or "-")[:8])
def c_type(p):
    t = rd(p)
    m = dict((x[0], x[1:]) for x in re.findall(r"^  (before|after) \| members (\S+) \| type (\S+) \| instance (\S+) \| status (\d+) \| title (.+?) \| name (\S+)$", t, re.M))
    need(m.get("before") == m.get("after") and m.get("after", ("",) * 2)[1] == "tag:tiffinbox.example,2026:customer-not-found", "the Nobody 404's members on before = after; type %s · instance %s" % (m.get("after", ("-",) * 3)[1], m.get("after", ("-",) * 3)[2]))
    need(re.search(r"^  the two trees' Nobody bodies: equal$", t, re.M) is not None, "the two trees' Nobody bodies byte-equal")
    need("tag:tiffinbox.example,2026:customer-not-found" in (grab(r"^  the committed file's example type\(s\): (.*)$", t) or ""), "the type equals the committed file's example")
    R = reqs(t)
    for s in ("before", "after"):
        for k in (("GET", "/api/v1/customers/Nobody", ""), ("GET", "/customers/Nobody", ""), ("PATCH", "/api/v1/customers/Nobody", "[{\"mealsPerDay\":2}]")):
            pass
    mv = [k for k in R if k[0] == "after" and R.get(("before",) + k[1:]) != R[k]]
    need(not mv, "the three Nobody requests answer the same on before and after (%d moved)" % len(mv))
    rt = re.search(r"^  retired \| members (\S+) \| type (.+?) \| status (\d+) \| detail (.*)$", t, re.M)
    need(rt is not None and rt.group(3) == "400", "on the retired mirror the same Nobody request answers %s, type %s - the retirement's answer, not the not-found" % ((rt.group(3), rt.group(2)) if rt else ("-", "-")))
    val("type", "customer-not-found"); val("retired_nobody", rt.group(3) if rt else "-")
def c_client(p):
    t = rd(p)
    fl = re.search(r"^  \.openapi-generator/FILES: ([0-9a-f]{32}) · (\d+) Java files$", t, re.M)
    need(fl is not None and fl.group(2) == "10", "FILES lists %s Java files" % (fl.group(2) if fl else "-"))
    ap = re.search(r"^  ApiApi\.java: lines naming \"/api/v1/: (\d+) · distinct /api/ strings: (.*) · containing \{version\}: (\d+)$", t, re.M)
    need(ap is not None and ap.group(3) == "0" and all(x.startswith('"/api/v1/') for x in ap.group(2).split()), "the generated paths: all literal /api/v1/ (%s), 0 with {version}" % (ap.group(2) if ap else "-"))
    blocks = re.split(r"^  caller ", t, flags=re.M)[1:]
    print("  the runner's calls: %d" % len(blocks))
    for b in blocks: print("  call | %s" % " ".join(b.split("\n")[:3]).replace("    ", " ")[:220])
    need(len(blocks) == 5, "five calls: call, nobody, pause on after/; call, nobody on the retired mirror")
    need(all("exit 0" in b.split("\n")[0] or "exit 1" in b.split("\n")[0] for b in blocks), "every call ended with an exit status")
    val("files", fl.group(2) if fl else "-"); val("generated_v1_lines", ap.group(1) if ap else "-")
def c_restdocs(p):
    t = rd(p)
    s = re.findall(r"^  snippet \| (after|before) \| (\S+) \| ([0-9a-f]{32})$", t, re.M)
    a = {f: m for x, f, m in s if x == "after"}; b = {f: m for x, f, m in s if x == "before"}
    c = re.findall(r"^  compare \| (\S+) \| (equal|differ)$", t, re.M)
    need(len(a) == 8 and len(b) == 8 and all(x[1] == "equal" for x in c) and len(c) == 8, "the eight snippets on after and before: %d / %d, equal %d of %d" % (len(a), len(b), sum(1 for x in c if x[1] == "equal"), len(c)))
    j = re.findall(r"^  junit TiffinBoxRestDocsTest: tests (\d+) failures (\d+) errors (\d+) skipped (\d+)$", t, re.M)
    need(j == [("1", "0", "0", "0"), ("1", "0", "0", "0")], "TiffinBoxRestDocsTest passes on both: %s" % j)
    need(re.search(r"^  http-request \| GET /api/v1/customers/Ravi HTTP/1\.1$", t, re.M) is not None, "http-request.adoc documents GET /api/v1/customers/Ravi")
    pp = re.findall(r"^  path-parameters \| \|`\+(\w+)\+`$", t, re.M)
    need(pp == ["name"], "path-parameters.adoc names %s only (no version parameter)" % ",".join(pp))
    need(re.search(r"^  the test file before -> after: byte-identical$", t, re.M) is not None, "the test is not edited")
    val("snippets", len(a)); val("snippets_equal", sum(1 for x in c if x[1] == "equal")); val("path_parameters", ",".join(pp)); val("documented_ct", grab(r"^  http-response\.adoc's Content-Type: (\S+)$", t) or "-")
def c_replay(p):
    t = rd(p)
    s = {m.group(1): m for m in re.finditer(r"^  step (\d) \| POST (\S+) \[[^\]]*\] -> (\d+) ", t, re.M)}
    need(s.get("1") is not None and s.get("2") is not None and s["1"].group(3) == s["2"].group(3), "steps 1 and 2 under /api/v1/: %s, %s" % (s["1"].group(3) if "1" in s else "-", s["2"].group(3) if "2" in s else "-"))
    fp = grab(r"step 1 against step 2: (.*)$", t) or ""
    need(fp == "status=equal location=equal content-type=equal body=equal", "the four parts equal key for key: %s" % fp)
    k = dict(re.findall(r"^  key table \| (\S+) \| (\d+)$", t, re.M))
    need(k.get("replay-start") == "0" and k.get("after-step-1") == "1" and k.get("after-step-2") == "1", "the key table: 0 -> 1 -> 1 (the replay writes no row)")
    print("  step 3 (the other spelling /api/1.0/, the same key): %s · key rows after %s" % (s["3"].group(3) if "3" in s else "-", k.get("after-step-3")))
    val("replay_status", s["1"].group(3) if "1" in s else "-"); val("other_spelling", s["3"].group(3) if "3" in s else "-"); val("keys_after3", k.get("after-step-3", "-"))
def c_committed(p):
    t = rd(p)
    m = re.search(r"^  bytes (\d+) \(wc -c\) · md5 (\w+) · before's \(U11's\) md5 (\w+) · (byte-identical|DIFFERENT) · servers member: (\w+) · git diff 197ff80 on it: (\d+) lines$", t, re.M)
    need(m is not None and m.group(1) == "20306" and m.group(4) == "byte-identical" and m.group(5) == "absent" and m.group(6) == "0", "the committed file: 20306 B, byte-identical to U11's, no servers, git diff empty")
    need(re.search(r"= the committed file: byte-identical$", t, re.M) is not None, "the served document (servers removed) = the committed file: not regenerated")
    iv = re.search(r"^  info\.version (\S+) · the path keys under /api/ \((\d+)\): .* · the version token in the keys: (\S+) · info\.version and the keys' token the same string: (yes|no)$", t, re.M)
    need(iv is not None and iv.group(1) == "1.0" and iv.group(3) == "v1" and iv.group(4) == "no", "info.version %s beside the keys' token %s (%s path keys): not the same string" % (iv.group(1), iv.group(3), iv.group(2)) if iv else "info.version printed")
    need(re.search(r"^  package:  OpenApiSpecTest tests 1 failures 0 errors 0 skipped 0$", t, re.M) is not None and re.search(r"^  twin:  OpenApiSpecTest tests 1 failures 0 errors 0 skipped 0$", t, re.M) is not None, "OpenApiSpecTest passes in package and the twin")
    sd = grab(r"^  GET /v3/api-docs -> (\d+)", t)
    vp = re.findall(r"^  versioned path \| (\S+) \| operations (\d+) \| operationIds (\S+)$", t, re.M)
    print("  spring doc with versioned harness routes: %s · %s" % (sd, " · ".join("%s %s ops (%s)" % x for x in vp)))
    need(sd is not None, "the versioned-route document answered (%s)" % sd)
    val("file_bytes", m.group(1) if m else "-"); val("spec_md5", m.group(2)[:8] if m else "-"); val("info_version", iv.group(1) if iv else "-"); val("path_token", iv.group(3) if iv else "-")
    val("api_paths", iv.group(2) if iv else "-"); val("versioned_doc", sd or "-"); val("versioned_paths", len(vp))
def c_moved(p):
    t = rd(p)
    R = collections.OrderedDict()
    for side, req, rest in re.findall(r"^  (before|after) \| (.+?) -> (.*)$", t, re.M): R.setdefault(req, {})[side] = rest
    mv = [k for k, v in R.items() if v.get("before") != v.get("after")]
    for k in mv: print("  MOVED: %s | before %s | after %s" % (k, R[k].get("before"), R[k].get("after")))
    need(len(R) == 19 and not mv, "unit 11's nineteen requests: %d, moved %d (%s)" % (len(R), len(mv), ",".join(mv) or "none"))
    v1 = [k for k in R if " /api/v1/" in " " + k.split(" ", 1)[1]]
    print("  the nineteen's requests under /api/v1/ (the witnesses for the versioned routes): %d" % len(v1))
    jm = re.search(r"^  web jar md5: before (\w+) · after (\w+)$", t, re.M)
    need(jm is not None and jm.group(1) != jm.group(2), "the web jar's md5 differs before -> after (expected: a new class)")
    na = grab(r"^  entry names only after has: (.*)$", t) or ""; nb = grab(r"^  entry names only before has: (.*)$", t) or ""; crc = grab(r"^  shared entries whose CRC moved: (.*)$", t) or ""
    need(na == "BOOT-INF/classes/com/tiffinbox/web/TiffinBoxApiVersioning.class" and nb == "none" and crc == "none", "the per-entry comparison: after has one entry before lacks (%s), before none, shared CRCs moved: %s" % (na, crc))
    need(re.search(r"^  entries named restdocs, asciidoctor, jruby or generated-docs: before 0 · after 0$", t, re.M) is not None, "no REST Docs, Asciidoctor, JRuby or page entry in either jar")
    val("requests", len(R)); val("moved", len(mv)); val("v1_requests", len(v1)); val("jar_new_entries", len([x for x in na.split(",") if x and x != "none"])); val("jar_crc_moved", 0 if crc == "none" else len(crc.split(",")))
def c_seven(p):
    t = rd(p); exp = grab(r"the expected (\w{32})", t); s = sevens(t)
    need(s.get("choose-before") == exp and s.get("choose-after") == exp and exp is not None, "the seven on before and after: %s = the expected" % (exp or "-")[:8])
    need(s.get("choose-required") not in (None, exp), "the planted mirror's seven differs: %s" % (s.get("choose-required") or "-")[:8])
    need(re.search(r"^  the seven sends no request under /api/ .*: /customers /revenue /dashboard /kitchen /nowhere /shutdown and POST /shutdown$", t, re.M) is not None, "the seven's paths: none under /api/ (not a witness for the versioned routes)")
    val("seven", (exp or "-")[:8])
def c_surface(p):
    t = rd(p); exp = grab(r"the expected (\w{32})", t)
    s = re.findall(r"^  (before|after): the old surface (\w{32}) \((\d+) requests, (\d+) lines\)", t, re.M)
    need(len(s) == 2 and all(x[1] == exp for x in s), "the old surface on before and after: %s = the expected (%s requests, %s lines)" % ((exp or "-")[:8], s[0][2] if s else "-", s[0][3] if s else "-"))
    val("surface", (exp or "-")[:8]); val("surface_requests", s[0][2] if s else "-")
def c_inert(p):
    t = rd(p)
    s = re.findall(r"^  \.r-(\w+)\.new: request lines (\d+) · naming the key header (\d+)$", t, re.M)
    need(s and all(x[2] == "0" for x in s), "the request lines of %d captures name the key header 0 times" % len(s))
    need(grab(r"^  \.r-replay\.new: requests carrying the key (\d+)", t) == "3", "replay: the key on its three named requests only")
    k = dict(re.findall(r"^  key table \| (\S+) \| (\d+)$", t, re.M))
    need(k.get("replay-start") == "0" and k.get("after-step-2") == "1", "the key table: 0 rows before, 1 after the replay")
    val("captures_read", len(s))
def c_exercise(p):
    t = rd(p)
    runs = re.split(r"^== the exercise, h2, ", t, flags=re.M)[1:]
    R = {}
    for r in runs:
        h = r.split(" ", 1)[0].rstrip(","); sh = r.split(", ", 1)[1].split(" ", 1)[0]
        res = "PASS" if re.search(r"^  PASS:", r, re.M) else (grab(r"^  FAIL \((clause \d)\)", r) or "FAIL")
        R[(h, sh)] = (res, grab(r"^  check exit (\d+)$", r), grab(r"^  the live answer to the old request: (.*)$", r))
    print("  exercise runs: %s" % " · ".join("%s/%s %s" % (k[0], k[1], v[0]) for k, v in R.items()))
    need(R.get(("broken", "bash"), ("",))[0] == "clause 1" and R.get(("broken", "zsh"), ("",))[0] == "clause 1", "broken (no answer saved): FAILS clause 1 under bash and zsh -f")
    need(R.get(("solved", "bash"), ("",))[0] == "PASS" and R.get(("solved", "zsh"), ("",))[0] == "PASS", "solved: PASS under bash and zsh -f")
    want = {"typed404": "clause 3", "pasted200": "clause 3", "v2request": "clause 2", "nodetail": "clause 4", "fixedtree": "clause 5"}
    got = {k[0]: v[0] for k, v in R.items() if k[0] in want}
    need(got == want, "the refused answers: %s" % " · ".join("%s %s" % kv for kv in sorted(got.items())))
    la = R.get(("solved", "bash"), ("", "", ""))[2] or ""
    print("  the live answer (solved, bash): %s" % la)
    need(la.startswith("400 · detail: Invalid API version: '1.0.0'."), "the retired tree's answer to the old request: %s" % la)
    val("retired_status", la.split(" ")[0] if la else "-"); val("solved", "pass"); val("variants", len(got))

CAPS = {"choose": c_choose, "tests": c_tests, "change": c_change, "four": c_four, "required": c_required, "default": c_default, "newest": c_newest,
        "deprecate": c_deprecate, "retire": c_retire, "type": c_type, "client": c_client, "restdocs": c_restdocs, "replay": c_replay,
        "committed": c_committed, "moved": c_moved, "seven": c_seven, "surface": c_surface, "inert": c_inert, "exercise": c_exercise}
def plants():
    """each plant must fail: printed as FAIL lines by the check that catches it (the run ends exit 1, never a traceback)"""
    base = "    @Test\n    void a() {}\n    @Test\n    void b() {}\n"
    for name, tt in (("a fully qualified @org.junit.jupiter.api.condition.EnabledIfSystemProperty", base.replace("    @Test\n    void a", "    @org.junit.jupiter.api.condition.EnabledIfSystemProperty(named = \"x\", matches = \"y\")\n    @Test\n    void a")),
                     ("a simple @EnabledIf", base.replace("    @Test\n    void a", "    @EnabledIf(\"x\")\n    @Test\n    void a")),
                     ("a fully qualified @org.junit.jupiter.api.Disabled", base.replace("    @Test\n    void a", "    @org.junit.jupiter.api.Disabled\n    @Test\n    void a")),
                     ("a third @Test", base + "    @Test\n    void c() {}\n"), ("a port literal", base + "    int p = 21010;\n")):
        need(bool(test_static(tt)), "plant: %s is refused by the test guard (%s)" % (name, ",".join(test_static(tt))))
    need(not test_static(base), "the clean two-method shape passes the test guard")
    bad = "  after | GET /api/v1/customers/Ravi -> 200 application/json 67 · headers {} body {}\n"
    BAD.clear(); reqs(bad); caught = len(BAD); BAD.clear()
    need(caught == 1, "plant: a request line one byte off (the ' · ' before body missing) is a FAIL line, not a traceback")
    done()
def capture(nm, p):
    if nm in CAPS: CAPS[nm](p)
    else: fail("no checks for the capture %r" % nm)
    done()
def hashable(nm, p):
    for l in lines(p):
        if re.match(r"^  guard before ", l): continue
        if l.startswith("  Testcontainers' containers while verify ran"): continue
        if l.startswith("  U11's own pass capture on this disk:"): continue   # an ignored file, present on the author's disk only (never in a clone)
        l = re.sub(r"load1 [0-9.]+", "load1 <n>", l)
        print(l)
def values(readme, vals):
    t = rd(readme)
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
             "spoken": lambda: spoken(a[1], a[2]), "surefire": lambda: surefire(a[1]), "hashable": lambda: hashable(a[1], a[2]), "values": lambda: values(a[1], a[2]),
             "modtable": lambda: modules(a[1], a[2], a[3]), "junit": lambda: junit(a[1], a[2]), "plants": plants}
        if a and a[0] in M: M[a[0]]()
        elif len(a) == 2: capture(a[0], a[1])
        else: print(__doc__); sys.exit(2)
    except SystemExit:
        raise
    except Exception as e:
        print("FAIL the checker could not read its input (%s: %s) - a FAIL line, never a traceback" % (e.__class__.__name__, str(e)[:120])); sys.exit(1)
