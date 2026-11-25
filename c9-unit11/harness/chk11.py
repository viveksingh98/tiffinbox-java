"""Course 9 unit 11's checker (python3 -I -B harness/chk11.py MODE ...). Every number the README may say is re-derived here from a capture's
own lines, a saved file or a shipped file, never typed. Each listing line a check reads is parsed by a named pattern or skipped by a named
rule; a line it cannot parse is a FAIL line and exit 1, never a traceback (Course 8 unit 25's class). The shared machinery (surefire, the
values block, the hashable form, the module table, static, gloss, hook, exq, spoken) is U10's (chk10.py, c9-unit10/harness), adapted;
U10's generator subcommands are left out (flag 20) - this unit's are REST Docs' and the page's: snippets, html, sealed, compare, accept,
driven, change.
Modes:
  static AFTER BEFORE      the carried prose slice, XFAM_S9S1's md5, the change's files (derived), the guards (i)-(vi), the stale sentences
  hook | exq | gloss-line  print the spoken lines (typed ONCE, here; asserted against the brief's bytes by spoken)
  gloss README             the one new gloss line (A snippet), U06's, U08's, U09's and U10's still byte-equal, none re-glossed
  spoken HOOK EXQ          the spoken lines: byte-equal to S2B's Unit 11 Hook and Exercise lines, words, digits, spellings, statuses, dur9
  listing DIR [ID...]      the snippet listing: per identifier, ABSENT, "0 files", or each file with its bytes and md5
  junit DIR CLASS          Surefire's XML for one class: every test case, its outcome, the exception class and message
  hosts FILE               the byte census of one page: every https?:// host, counted, and the total
  maskhtml FILE            the page with its "Last updated" line and absolute paths masked (for an md5 compared across runs)
  resp FILE                http-response.adoc read by python: status line, Content-Type, Content-Length, the body's md5 and members
  eqbody SNIPPET BODY      the snippet's body against a wire body, key for key and value
  example SPEC BODY        a wire body against the committed file's examples for GET /api/v1/customers/{name}'s 404
  springdoc SPEC           the document's operations, the error responses by operation, the schemas, the '*/*' successes
  modtable UP AFTER BEFORE | surefire XML    the small readers
  <capture> FILE           one capture's checks; prints ok/FAIL lines and one VALUES line
  hashable NAME FILE       the capture with its load- and run-dependent lines dropped, for receipts.md5
  values README VALS       README.md's values block = this run's VALUES lines"""
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
HOOK = "Document a field TiffinBox never sends, and the test fails. The answer's other snippets are still written."
EXQ = "Your turn: this test documents a nickname TiffinBox never sends. Make it pass without the nickname."
GLOSS = "A snippet: one documented part of one tested request."
BRIEFQ = "one documented part of one tested request"
U06GLOSS = "A contract: what a route promises its callers: the path, the method, the shapes in and out."
U08GLOSS = "Swagger UI: a page drawn from the document."
U09GLOSS = "A problem type: the U-R-I that names an error's kind."
U10GLOSS = "Code generation: source written by a tool from the spec."
SPEC = "tiffinbox-web/src/test/resources/openapi/tiffinbox.json"
TEST = "tiffinbox-web/src/test/java/com/tiffinbox/web/TiffinBoxRestDocsTest.java"
CHANGED = ["README.md", "pom.xml", "tiffinbox-web/pom.xml", TEST, "tiffinbox-web/src/docs/asciidoc/index.adoc", "tiffinbox-web/src/docs/asciidoc/tiffinbox-docs.css"]
UNTOUCHED = ["Dockerfile", "compose.yaml", SPEC, "tiffinbox-client/pom.xml", "tiffinbox-core/pom.xml",
             "tiffinbox-web/src/test/java/com/tiffinbox/web/OpenApiSpecTest.java", "tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxOpenApi.java",
             "tiffinbox-web/src/main/java/com/tiffinbox/web/IdempotencyKeyFilter.java"]
LEFTOUT = ["generate", "census", "jackson", "call", "pause", "mock", "default", "counts", "loc", "location", "perop", "blanket", "shape", "types", "scheme", "wide"]
DEFAULTS = ["curl-request.adoc", "http-request.adoc", "http-response.adoc", "httpie-request.adoc", "request-body.adoc", "response-body.adoc"]
EIGHT = sorted(DEFAULTS + ["path-parameters.adoc", "response-fields.adoc"])
STATUS = re.compile(r"(?<![\d.,:/-])\b(?:[1-5]\d\d)\b|\b(?:one|two|three|four|five)[\s-]hundred[\s-]and\b|\b(?:one|two|three|four|five)[\s-]hundred[\s-](?:one|two|three|four|five|six|seven|eight|nine|ten|eleven|twelve|thirteen|fourteen|fifteen)\b")
HING = re.compile(r"\b(?:bhai|yaar|dosto|kya|hai|nahi|nahin|matlab|karo|dekho|chalo|samjho|theek|accha|arre|haan|bilkul|zaroor|aur|toh|abhi|yeh|woh|kaise|kyun|bahut|thoda|sahi|galat)\b", re.I)
SPELL = re.compile(r"\b(?:API|URI|URL|RFC)s?\b|\bOpenAPI\b|\bspringdoc\b|\bopenapi-generator\b")
HOSTRX = re.compile(rb"https?://[A-Za-z0-9.-]+")

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

# ---- the small readers ----------------------------------------------------------------------------------------------------------------
def listing(d, ids):
    """per identifier: ABSENT (no directory), 0 files (an empty directory), or each file with its bytes and md5"""
    ids = ids or (sorted(os.listdir(d)) if os.path.isdir(d) else [])
    print("  listing of %s: %s" % (os.path.basename(os.path.dirname(d.rstrip("/"))) + "/" + os.path.basename(d.rstrip("/")), "the directory itself ABSENT" if not os.path.isdir(d) else "%d identifier directories" % len([x for x in os.listdir(d) if os.path.isdir(os.path.join(d, x))])))
    for i in ids:
        p = os.path.join(d, i)
        if not os.path.isdir(p): print("  snip %s: ABSENT" % i); continue
        fs = sorted(os.listdir(p))
        print("  snip %s: %d files" % (i, len(fs)))
        for f in fs: print("  snip %s | %s | %d B | %s" % (i, f, os.path.getsize(os.path.join(p, f)), hashlib.md5(open(os.path.join(p, f), "rb").read()).hexdigest()))
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
def hosts(p):
    b = open(p, "rb").read(); c = collections.Counter(m.decode() for m in HOSTRX.findall(b))
    for h, n in sorted(c.items()): print("  host %s | %s x%d" % (os.path.basename(p), h, n))
    print("  hosts %s: %d B · references %d · distinct hosts %d" % (os.path.basename(p), len(b), sum(c.values()), len(c)))
def maskhtml(p):
    for l in lines(p):
        l = re.sub(r"Last updated \d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2} [+-]\d{4}", "Last updated <masked>", l)
        print(l)
def resp(p):
    t = rd(p); ls = t.split("\n")
    st = next((l for l in ls if l.startswith("HTTP/1.1 ")), "-")
    ct = next((l.split(": ", 1)[1] for l in ls if l.startswith("Content-Type: ")), "-")
    cl = next((l.split(": ", 1)[1] for l in ls if l.startswith("Content-Length: ")), "-")
    body = t.split("\n\n", 1)[1].rsplit("\n----", 1)[0].strip() if "\n\n" in t else ""
    try: mem = ",".join(json.loads(body)) if body else "-"
    except ValueError: mem = "not JSON"
    print("  resp %s | status %s | Content-Type %s | Content-Length %s | body %d B md5 %s | members %s" % (os.path.basename(os.path.dirname(p)), st[9:], ct, cl, len(body.encode()), hashlib.md5(body.encode()).hexdigest()[:12], mem))
def snipbody(p):
    t = rd(p); return t.split("\n\n", 1)[1].rsplit("\n----", 1)[0].strip() if "\n\n" in t else t
def eqbody(snip, body):
    a = json.loads(snipbody(snip)); b = json.load(open(body, encoding="utf-8"))
    print("  %s (%s)" % ("EQUAL key for key and value" if a == b else "DIFFERENT", ",".join(sorted(set(a) | set(b)))))
def example(spec, body):
    d = json.load(open(spec, encoding="utf-8")); w = json.load(open(body, encoding="utf-8"))
    ex = d["paths"]["/api/v1/customers/{name}"]["get"]["responses"]["404"]["content"]["application/problem+json"].get("examples", {})
    hit = [k for k, v in ex.items() if v.get("value") == w]
    only = {k: sorted(set(w) ^ set(v.get("value", {}))) for k, v in ex.items()}
    print("  example: %s (the examples: %s; members only one side has: %s) · type %s" % ("EQUAL to %s" % ",".join(hit) if hit else "DIFFERENT", ",".join(ex), json.dumps(only), w.get("type")))
def springdoc(spec):
    d = json.load(open(spec, encoding="utf-8")); d.pop("servers", None)
    ops = [(m.upper(), p, o) for p, v in d["paths"].items() for m, o in v.items()]
    err = [(m, p) for m, p, o in ops if any(not k.startswith("2") for k in o.get("responses", {}))]
    star = [(m, p) for m, p, o in ops if any(k.startswith("2") and "*/*" in r.get("content", {}) for k, r in o.get("responses", {}).items())]
    print("  springdoc: operations %d · paths %d · operations with an error response %d · schemas %d (%s) · operations whose success lists */* %d" % (
          len(ops), len(d["paths"]), len(err), len(d.get("components", {}).get("schemas", {})), ",".join(sorted(d.get("components", {}).get("schemas", {}))), len(star)))

# ---- modules (git) ----------------------------------------------------------------------------------------------------------------
def modlist(p):
    return re.findall(r"<module>([^<]+)</module>", rd(p))
def modules(up, after, before):
    b = modlist(os.path.join(before, "pom.xml")); a = modlist(os.path.join(after, "pom.xml"))
    print("== the parent's <modules> (python over before/pom.xml and after/pom.xml - the frozen trees, not the working tree)")
    print("  modules before: %d (%s) · after: %d (%s) · added: %s · removed: %s" % (len(b), ",".join(b), len(a), ",".join(a), ",".join(x for x in a if x not in b) or "none", ",".join(x for x in b if x not in a) or "none"))
    print("== every commit that touched c9-tiffinbox/ (git log --reverse), the first path segment of each changed path under it")
    r = subprocess.run(["git", "-C", up, "log", "--reverse", "--format=%h %s", "--", "c9-tiffinbox"], capture_output=True, text=True)
    rows = []
    for l in r.stdout.splitlines():
        h, s = l.split(" ", 1)
        names = subprocess.run(["git", "-C", up, "show", "--name-only", "--format=", h, "--", "c9-tiffinbox"], capture_output=True, text=True).stdout.split()
        seg = sorted({(n.split("/")[1] if n.count("/") >= 2 else "parent:" + n.split("/")[1]) for n in names})
        mods = sorted({x for x in seg if x in ("tiffinbox-core", "tiffinbox-web", "tiffinbox-client")})
        par = "pom.xml" if "parent:pom.xml" in seg else "-"
        unit = grab(r"^Course 9 unit (\d+)", s) or grab(r"^Course 9 (set-up)", s) or grab(r"^(receipts)", s) or s.split()[0]
        rows.append((h, unit, par, mods))
        print("  commit | %s | unit %s | parent %s | modules %s" % (h, unit, par, ",".join(mods) or "-"))
    ch = [x for x in ("tiffinbox-core", "tiffinbox-web", "tiffinbox-client") if tree(os.path.join(after, x), {"target"}) != tree(os.path.join(before, x), {"target"})]
    print("  this unit's change (after/ against before, the frozen trees): parent pom.xml · modules %s" % ",".join(ch))
    print("  the sentence for the scripts stage (printed, never written): unit 11 changes the parent pom and tiffinbox-web (test scope, a build step, src/docs); TIFFINBOX_MODULES in upload_java9.py is read, not edited")
def surefire(p):
    import xml.etree.ElementTree as ET
    if not os.path.exists(p): print("  %s absent" % os.path.basename(p)); return
    r = ET.parse(p).getroot()
    print("  %s tests %s failures %s errors %s skipped %s" % (r.get("name").split(".")[-1], r.get("tests"), r.get("failures"), r.get("errors"), r.get("skipped")))

# ---- static ---------------------------------------------------------------------------------------------------------------------------
def pomdiff(a, b):
    dd = [l for l in subprocess.run(["diff", a, b], capture_output=True, text=True).stdout.splitlines() if l[:1] in "<>"]
    return [l[2:] for l in dd if l.startswith(">")], [l[2:] for l in dd if l.startswith("<")]
def static(after, before):
    md = lambda x: hashlib.md5("\n".join(x).encode()).hexdigest()
    end = "# --- XFAM_S9S1 end ---"
    s11 = rd(os.path.join(HERE, "s911.py")).split("\n")
    s10 = rd(os.path.join(UNIT, "..", "c9-unit10", "harness", "s910.py")).split("\n")
    if any(end not in s for s in (s11, s10)): fail("the XFAM_S9S1 end marker is missing in s911.py or s910.py"); done()
    a = lambda s: next(i for i, l in enumerate(s) if l.endswith('"""') and i > 0)
    sl = lambda s: s[a(s) + 1:s.index(end) + 1]
    need(sl(s11) == sl(s10), "s911.py's base + XFAM_S9S1 (after its docstring, through the block's end marker) = s910.py's, %d lines, md5 %s (copied from U10's harness)" % (len(sl(s10)), md(sl(s10))))
    t11 = "\n".join(s11)
    b = re.search(r"# --- XFAM_S9S1 begin ---\n.*?# --- XFAM_S9S1 end ---", t11, re.S)
    if b:
        h = hashlib.md5(b.group(0).encode()).hexdigest()
        print("  XFAM_S9S1_SLICE_MD5 = %s (computed the way ../c9-unit04/harness/chk04.py computes it)" % h); val("xfam_s9s1_md5", h[:8])
        need(h == "1f5217a0fdf43c70e68284c5311a32ef", "the slice md5 is the brief's (S2B, BUILDERS)")
    need(not re.search(r"^XU(?:0\d|10) = ", t11, re.M), "XU01-XU10 are not carried")
    need(re.search(r"^XU11 = ", t11, re.M) is not None and re.search(r"^u04 = u11$", t11, re.M) is not None, "U11's own family (XU11) follows the carried slice; u04 = u11 (U01's binding)")
    x2 = os.path.join(C9R, "_builders", "s907.py")
    print("  XFAM_S9S2 (the scripts stage's, C9/_builders/s907.py): %s" % ("present - not asserted here" if os.path.exists(x2) and "XFAM_S9S2" in rd(x2) else "does not exist yet - nothing to assert XU11 against"))
    ck = rd(os.path.join(HERE, "chk11.py"))
    dead = [w for w in LEFTOUT if re.search(r"^def (?:c_)?%s\(" % re.escape(w), ck, re.M) or re.search(r'"%s": (?:lambda|c_)' % re.escape(w), ck)]
    need(not dead, "chk11.py carries none of the left-out subcommands (%s): %s" % (",".join(LEFTOUT), ",".join(dead) or "none"))
    for nm in ("snippets", "html", "sealed", "compare", "accept", "driven", "change"):
        need(re.search(r"^def c_%s\(" % nm, ck, re.M) is not None, "chk11.py has this unit's %s check" % nm)
    harn = sorted(os.listdir(HERE))
    bad = [x for x in harn if x in ("loc9.py", "Caller.java")] + [x for x in os.listdir(os.path.join(HERE, "mirror")) if x in ("default.diff", "hc5.diff")]
    bad += [x for x in ("src/probe/u10/Caller.java", "src/probe/u09/SchemeCopy.java") if os.path.exists(os.path.join(HERE, x))]
    need(not bad, "no U09/U10 instrument in harness/ (loc9.py, Caller.java, default.diff, hc5.diff, SchemeCopy.java): %s" % (",".join(bad) or "none"))
    need(all(os.path.exists(os.path.join(HERE, x)) for x in ("cdp.mjs", "cdp9.mjs", "seal9.py")), "the seal's instruments are in harness/ (cdp.mjs, cdp9.mjs, seal9.py)")
    A, Bt = tree(after, {"target"}), tree(before, {"target"})
    ch = sorted(k for k in set(A) | set(Bt) if A.get(k) != Bt.get(k))
    print("  the change (after/ against before, the frozen trees; the derived list): %d files: %s" % (len(ch), " ".join(ch)))
    need(ch == sorted(CHANGED), "the changed files are exactly the parent pom, the web pom, the README, the one test and the two page sources")
    val("changed_files", len(ch))
    need(not [k for k in ch if k.startswith(("tiffinbox-core/", "tiffinbox-client/", "tiffinbox-web/src/main/"))], "(i) nothing under tiffinbox-core/, tiffinbox-client/ or tiffinbox-web/src/main changed")
    need(all(A.get(k) == Bt.get(k) and A.get(k) for k in UNTOUCHED), "(i) the Dockerfile, compose.yaml, the committed spec, the client's and core's poms, OpenApiSpecTest, TiffinBoxOpenApi and IdempotencyKeyFilter byte-equal to before's")
    need(not [k for k in ch if k.startswith("tiffinbox-web/src/test/") and k != TEST], "no existing test edited (only the new test under tiffinbox-web/src/test)")
    plus, minus = pomdiff(os.path.join(before, "pom.xml"), os.path.join(after, "pom.xml"))
    prop = [l for l in plus if "<asciidoctor-maven-plugin.version>" in l]
    need(not minus and prop == ["    <asciidoctor-maven-plugin.version>3.2.0</asciidoctor-maven-plugin.version>"] and all(l.strip().startswith(("<!--", "<asciidoctor-maven-plugin.version>")) or not l.strip().startswith("<") for l in plus),
         "(ii) the parent pom's diff: %d lines added, 0 removed - one property and its comment" % len(plus))
    com = " ".join(l.strip() for l in plus if not l.strip().startswith("<asciidoctor"))
    need(all(w in com for w in ("Course 9, unit 11:", "newest", "not", "weighed", "measured", "Version-bound")) and com.strip() not in ("<!-- compatible -->",),
         "R.515: the property's comment names the sweep's newest, the versions not weighed, the measured surface and \"Version-bound\" (\"compatible\" alone fails)")
    need(not re.search(r"<module>", "\n".join(plus)), "the parent's <modules> unchanged (no <module> line added)")
    wplus, wminus = pomdiff(os.path.join(before, "tiffinbox-web", "pom.xml"), os.path.join(after, "tiffinbox-web", "pom.xml"))
    need(not wminus, "(ii) the web pom's diff: %d lines added, 0 removed" % len(wplus))
    added = "\n".join(wplus)
    deps = re.findall(r"<dependency>(.*?)</dependency>", added, re.S)
    plugin_deps = re.findall(r"<plugin>.*?<dependencies>(.*?)</dependencies>", added, re.S)
    pdeps = re.findall(r"<dependency>(.*?)</dependency>", "".join(plugin_deps), re.S)
    mdeps = [d for d in deps if d not in pdeps]
    need(len(mdeps) == 2 and all("<scope>test</scope>" in d and "<version>" not in d for d in mdeps), "(iii) the module's two added dependencies carry <scope>test</scope> and no version (Boot's parent manages them)")
    need(sorted(re.search(r"<artifactId>([^<]+)", d).group(1) for d in mdeps) == ["spring-boot-starter-restdocs", "spring-restdocs-mockmvc"], "(iii) they are spring-restdocs-mockmvc and spring-boot-starter-restdocs")
    need("<version>${asciidoctor-maven-plugin.version}</version>" in added and not re.search(r"<version>3\.2\.0</version>", added), "(iii) the build step's version is the parent's property, never a literal")
    need(all(x in added for x in ("<id>docs</id>", "<phase>prepare-package</phase>", "<goal>process-asciidoc</goal>", "<sourceDirectory>${project.basedir}/src/docs/asciidoc</sourceDirectory>",
                                  "<outputDirectory>${project.build.directory}/generated-docs</outputDirectory>", "<backend>html5</backend>", "<version>${spring-restdocs.version}</version>")),
         "the build step: execution docs at prepare-package, process-asciidoc, src/docs/asciidoc -> target/generated-docs, html5, spring-restdocs-asciidoctor at Boot's version")
    need(not re.search(r"jackson-|httpclient5|restclient|generatorName", added), "(iii) no jackson-*, httpclient5, restclient or generatorName in what was added")
    tt = rd(os.path.join(after, TEST))
    need(len(re.findall(r"^\s*@Test\s*$", tt, re.M)) == 1 and "void thePublicReadIsDocumented()" in tt, "the new test class holds exactly one @Test, thePublicReadIsDocumented")
    need(not re.search(r"@EnabledIf|@Disabled|@DisabledIf", tt), "(vi) the test names no @EnabledIf..., @Disabled or @DisabledIf (nothing skipped)")
    need(not re.search(r"RANDOM_PORT|DEFINED_PORT|LocalServerPort|\b\d{4,5}\b|Socket", tt), "(vi) the test names no port and no socket (MockMvc, the MOCK environment)")
    need(tt.index("andExpect(status().isOk())") < tt.index("andDo(document("), "the 200 is expected before document()")
    need(not re.search(r'"nickname"', tt), "the shipped test documents no nickname")
    css = os.path.join(after, "tiffinbox-web", "src", "docs", "asciidoc", "tiffinbox-docs.css")
    need(hashlib.md5(open(css, "rb").read()).hexdigest() == "e2156842ec34e4ffa12d3c2743a0c71f", "tiffinbox-docs.css is the probe's file byte-equal (md5 e2156842..., 191 B)")
    ad = rd(os.path.join(after, "tiffinbox-web", "src", "docs", "asciidoc", "index.adoc"))
    need(":webfonts!:" in ad and ":stylesheet: tiffinbox-docs.css" in ad and len(re.findall(r"^include::\{snippets\}/customer-read/", ad, re.M)) == 4, "index.adoc: :webfonts!:, the local stylesheet, four includes of customer-read's snippets")
    rm = rd(os.path.join(after, "README.md"))
    card = re.search(r"^## Course 9 · unit 11 — .*?(?=^## |^---$|\Z)", rm, re.M | re.S)
    need(card is not None, "the README has a Course 9 · unit 11 card")
    if card:
        c = re.sub(r"\s+", " ", card.group(0))
        need(not re.search(r"(?:tests? (?:at `mvn package` )?(?:are|is) 49\b|\b49 tests\b)(?! at unit 10)", c) and "49 at unit 10" in c, "R.250/R.453: unit 11's card gives 49 as unit 10's count only, never as the current one")
        need(not re.search(r"\b\d+ lines\b", c), "no line count spoken in the card")
    need("*Course 9, unit 11:" in rm.split("## Course 9 · unit 04")[0], "the README's header carries a *Course 9, unit 11: ...* note")
    done()

# ---- the spoken lines -----------------------------------------------------------------------------------------------------------------
def brief_lines():
    t = rd(S2B).split("\n")
    i0 = next(i for i, l in enumerate(t) if l.startswith("## Unit 11 · Spring REST Docs")); i1 = next(i for i, l in enumerate(t) if i > i0 and l.startswith("## "))
    print("  the brief's Unit 11 section: S2B :%d-:%d" % (i0 + 1, i1))
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
    need(hook == HOOK == bh, "the hook is S2B's Unit 11 Hook line's quote, byte for byte (extracted at run time = typed once here)")
    need(exq == EXQ == be, "the exercise's line is S2B's Unit 11 Exercise line's quote, byte for byte (extracted at run time = typed once here)")
    hw, ew, gw = len(hook.split()), len(exq.split()), len(GLOSS.split())
    need(hw == 17 and hw <= 25, "the hook: %d words (wc -w; the brief's 17; <= 25)" % hw)
    need(ew == 16 and ew <= 25, "the exercise: %d words (wc -w; the brief's 16; <= 25)" % ew)
    for name, s in (("the hook", hook), ("the exercise", exq), ("the gloss", GLOSS)):
        nd = re.findall(r"\d", s)
        print("  %s: digits %s · the status gate %s · the spelling gate %s · Hinglish %s · dur9 %s" % (name, "".join(nd) or "0", "hit" if STATUS.search(s) else "0",
              SPELL.search(s).group(0) if SPELL.search(s) else "0", "hit" if HING.search(s) else "0", dur.search(s).group(0) if dur is not None and dur.search(s) else "0"))
        need(not STATUS.search(s), "%s: the status gate 0" % name)
        need(not SPELL.search(s), "%s: the spelling gate 0" % name)
        need(not HING.search(s), "%s: the Hinglish list 0" % name)
        if dur is not None: need(not dur.search(s), "%s: dur9 0" % name)
        need(not nd, "%s: no digit" % name)
    for p in ("Open A-P-I", "spring doc", "R-E-S-T Docs", "Asciidoctor"): need(not SPELL.search(p), "the spelled form %r passes the spelling gate" % p)
    for p in ("OpenAPI", "springdoc"): need(bool(SPELL.search("It reads the " + p + " document.")), "the bare %r refuses in a spoken line" % p)
    print("  the hook: %d words · the exercise: %d words · the gloss: %d words; the brief's parenthetical (%d words): \"%s\"" % (hw, ew, gw, len(BRIEFQ.split()), BRIEFQ))
    val("hook_words", hw); val("exercise_words", ew); val("gloss_words", gw)
    done()
def gloss(readme):
    u6 = rd(os.path.join(UNIT, "..", "c9-unit06", "README.md")).split("\n")
    u8 = rd(os.path.join(UNIT, "..", "c9-unit08", "README.md")).split("\n")
    u9 = rd(os.path.join(UNIT, "..", "c9-unit09", "README.md")).split("\n")
    u10 = rd(os.path.join(UNIT, "..", "c9-unit10", "README.md")).split("\n")
    need(len(u6) > 18 and u6[18] == U06GLOSS, "U06's gloss line is still byte-equal at ../c9-unit06/README.md:19")
    need(len(u8) > 15 and u8[15] == U08GLOSS, "U08's gloss line is still byte-equal at ../c9-unit08/README.md:16")
    n9 = [i + 1 for i, l in enumerate(u9) if l == U09GLOSS]; n10 = [i + 1 for i, l in enumerate(u10) if l == U10GLOSS]
    need(len(n9) == 1, "U09's gloss line is still byte-equal at ../c9-unit09/README.md:%s" % (n9[0] if n9 else "-"))
    need(len(n10) == 1, "U10's gloss line is still byte-equal at ../c9-unit10/README.md:%s" % (n10[0] if n10 else "-"))
    r = rd(readme).split("\n")
    g = [i + 1 for i, l in enumerate(r) if re.match(r"^\s*(?:A contract|Swagger UI|A problem type|Code generation):", l)]
    need(not g, "README.md carries no line starting \"A contract:\", \"Swagger UI:\", \"A problem type:\" or \"Code generation:\" (not re-glossed) %s" % g)
    s = [i + 1 for i, l in enumerate(r) if l.startswith("A snippet:")]
    need(len(s) == 1 and r[s[0] - 1] == GLOSS, "README.md carries exactly one line starting \"A snippet:\", the gloss byte for byte (%s)" % s)
    need(len(GLOSS.split()) <= 25, "the gloss: %d words (<= 25)" % len(GLOSS.split()))
    first = next((i + 1 for i, l in enumerate(r) if "snippet" in re.sub(r"`[^`]*`", "", l).lower() and not l.startswith("#")), None)
    print("  the gloss (%d words): %s · the brief's parenthetical (%d words): %s" % (len(GLOSS.split()), GLOSS, len(BRIEFQ.split()), BRIEFQ))
    print("  first spoken use of \"snippet\" in the README at line %s" % first)
    val("gloss", "a_snippet_one_line")
    done()

# ---- the captures' checks ---------------------------------------------------------------------------------------------------------
def sf(t, prefix):
    out = {}
    for m in re.finditer(r"^  %s(\w+) tests (\d+) failures (\d+) errors (\d+) skipped (\d+)$" % re.escape(prefix), t, re.M): out[m.group(1)] = tuple(int(x) for x in m.groups()[1:])
    return out
def tot(d): return [sum(v[i] for v in d.values()) for i in range(4)]
def snips(t, ident):
    """the listing's lines for one identifier: None (ABSENT), or {file: (bytes, md5)}; a line under 'snip' it cannot parse is a FAIL"""
    if re.search(r"^  snip %s: ABSENT$" % re.escape(ident), t, re.M): return None
    n = grab(r"^  snip %s: (\d+) files$" % re.escape(ident), t)
    if n is None: return "missing"
    fs = {}
    for l in re.findall(r"^  snip %s \| .*$" % re.escape(ident), t, re.M):
        m = re.match(r"^  snip %s \| (\S+) \| (\d+) B \| ([0-9a-f]{32})$" % re.escape(ident), l)
        if not m: fail("a listing line the checker cannot parse: %r" % l); continue
        fs[m.group(1)] = (int(m.group(2)), m.group(3))
    if len(fs) != int(n): fail("the listing of %s says %s files and lists %d" % (ident, n, len(fs)))
    return fs
def unparsed(t):
    bad = [l for l in t.splitlines() if l.startswith("  snip ") and not re.match(r"^  snip [\w-]+(?:: ABSENT|: \d+ files| \| \S+ \| \d+ B \| [0-9a-f]{32})$", l)]
    for l in bad: fail("a listing line the checker cannot parse: %r" % l)
def c_tests(p):
    t = rd(p)
    need(re.search(r"^  mvn package exit 0 · Downloading/Downloaded from: 0$", t, re.M) is not None, "package: exit 0, offline")
    rs = re.findall(r"^  reactor: (TiffinBox[A-Za-z ]*) \.\.\. (SUCCESS|FAILURE|SKIPPED)", t, re.M)
    need(rs[:4] == [("TiffinBox", "SUCCESS"), ("TiffinBox Core", "SUCCESS"), ("TiffinBox Web", "SUCCESS"), ("TiffinBox Client", "SUCCESS")], "the reactor: four projects (the parent and three modules), each SUCCESS")
    w = sf(t, "tiffinbox-web | "); c = sf(t, "tiffinbox-client | ")
    b49 = grab(r"^  unit 10's values block: web_tests=(\d+)", t)
    k = grab(r"^  new @Test \| TiffinBoxRestDocsTest \| (\d+) \| thePublicReadIsDocumented \| before/\S+: absent$", t)
    need(b49 == "49" and k == "1", "the web module before this change: %s (unit 10's values block) · the @Test lines the change adds: %s (thePublicReadIsDocumented, a file before lacks)" % (b49, k))
    need(b49 is not None and k is not None and tot(w) == [int(b49) + int(k), 0, 0, 0], "tiffinbox-web at package: %s tests, 0 failures, 0 errors, 0 skipped (= unit 10's %s + %s)" % (tot(w)[0], b49, k))
    need(w.get("TiffinBoxRestDocsTest") == (1, 0, 0, 0) and w.get("OpenApiSpecTest") == (1, 0, 0, 0), "TiffinBoxRestDocsTest 1 / 0 failures / 0 errors / 0 skipped; OpenApiSpecTest 1 / 0")
    need(tot(c) == [1, 0, 0, 0], "tiffinbox-client at package: 1 test, run, none skipped")
    need(re.search(r"^  the build step's line \(package\): asciidoctor:3\.2\.0:process-asciidoc \(docs\) @ tiffinbox-web$", t, re.M) is not None and re.search(r"^  its phase \(the web pom\): prepare-package$", t, re.M) is not None,
         "the page step: asciidoctor 3.2.0 process-asciidoc (docs) in tiffinbox-web, bound to prepare-package")
    need(re.search(r"^  package: target/generated-docs/index\.html present · target/generated-snippets/customer-read 8 files$", t, re.M) is not None, "package wrote the page and the eight snippets")
    need(re.search(r"^  mvn package \(Docker-free\) exit 0 · Downloading/Downloaded from: 0$", t, re.M) is not None, "the Docker-free twin: exit 0")
    tw = sf(t, "twin tiffinbox-web | "); tc = sf(t, "twin tiffinbox-client | ")
    need(tot(tw) == tot(w) and tot(tc) == tot(c), "the twin's counts = package's")
    need(re.search(r"^  existing tests \(tiffinbox-web/src/test, tiffinbox-core/src\) before -> after/: 0 files differ$", t, re.M) is not None, "no existing test or core file edited")
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
    sk = re.search(r"^  -DskipTests on a scratch copy: exit (\d+) · include-not-found lines in the log (\d+) · target/generated-docs/index\.html (present|absent) · unresolved-include markers in it (\d+)$", t, re.M)
    need(sk is not None, "the -DskipTests form printed: exit %s · include-not-found %s · page %s · unresolved %s" % (sk.groups() if sk else ("-",) * 4))
    val("web_before", b49); val("web_tests", tot(w)[0]); val("client_tests", tot(c)[0]); val("restdocs_skipped", w.get("TiffinBoxRestDocsTest", (0, 0, 0, "-"))[3]); val("its", tot(it)[0]); val("it_classes", len(ib))
    val("lib", lb[1][1] if len(lb) > 1 else "-"); val("reactor", len(rs[:4]))
    if sk: val("skiptests_exit", sk.group(1)); val("skiptests_unresolved", sk.group(4))
def c_change(p):
    t = rd(p)
    m = re.search(r"^  modules before: (\d+) \(([^)]*)\) · after: (\d+) \(([^)]*)\) · added: (\S+) · removed: (\S+)$", t, re.M)
    need(m is not None and m.group(1) == m.group(3) == "3" and m.group(5) == "none" and m.group(6) == "none", "the parent's <modules>: 3 -> 3, none added or removed")
    need(re.search(r"^  this unit's change \(after/ against before, the frozen trees\): parent pom\.xml · modules tiffinbox-web$", t, re.M) is not None, "this unit's change: the parent pom and tiffinbox-web only")
    pa = re.search(r"^  the parent pom before -> after: (\d+) lines added, (\d+) removed$", t, re.M); wa = re.search(r"^  the web pom before -> after: (\d+) lines added, (\d+) removed$", t, re.M)
    need(pa is not None and pa.group(2) == "0" and wa is not None and wa.group(2) == "0", "both pom diffs are additions only (parent %s, web %s added)" % (pa.group(1) if pa else "-", wa.group(1) if wa else "-"))
    ev = dict(re.findall(r"^  resolved \| (\S+) \| (\S+)$", t, re.M))
    need(ev.get("org.springframework.restdocs:spring-restdocs-mockmvc") == "4.0.3:test" and ev.get("org.springframework.boot:spring-boot-starter-restdocs") == "4.1.3:test", "the test scope resolved: spring-restdocs-mockmvc 4.0.3 (test), spring-boot-starter-restdocs 4.1.3 (test)")
    need(not [k for k, v in ev.items() if ("restdocs" in k or "asciidoctor" in k or "jruby" in k) and not v.endswith(":test")], "no REST Docs, Asciidoctor or JRuby artifact in a scope other than test")
    need(re.search(r"^  the build step's effective version \(help:effective-pom\): 3\.2\.0$", t, re.M) is not None, "the build step's effective version: 3.2.0 (the parent's property)")
    need(re.search(r"^  the committed file: md5 e715f47c\w+ · byte-identical to before's$", t, re.M) is not None, "the committed file unchanged")
    val("restdocs", (ev.get("org.springframework.restdocs:spring-restdocs-mockmvc") or "-").split(":")[0]); val("plugin", "3.2.0"); val("modules", m.group(3) if m else "-")
def c_pass(p):
    t = rd(p); unparsed(t)
    fs = snips(t, "customer-read")
    need(isinstance(fs, dict) and sorted(fs) == EIGHT, "the passing test's customer-read/: %s files, the eight names %s" % (len(fs) if isinstance(fs, dict) else fs, ",".join(sorted(fs)) if isinstance(fs, dict) else "-"))
    bl = dict(re.findall(r"^  BLUE \| (\S+) \| ([0-9a-f]{32})$", t, re.M))
    eq = [f for f in DEFAULTS if isinstance(fs, dict) and f in fs and bl.get(f) == fs[f][1]]
    need(len(bl) == 8 and len(eq) == 6, "the six defaults' md5s equal BLUE's filed run (%d of 6); path-parameters and response-fields hold this test's descriptions: %s" % (len(eq), ",".join("%s %s" % (f, "equal" if isinstance(fs, dict) and fs.get(f, (0, ""))[1] == bl.get(f) else "differ") for f in ("path-parameters.adoc", "response-fields.adoc"))))
    r = re.search(r"^  resp customer-read \| status (.+?) \| Content-Type (\S+) \| Content-Length (\d+) \| body (\d+) B md5 (\w+) \| members (\S+)$", t, re.M)
    need(r is not None and r.group(1) == "200 OK" and r.group(2) == "application/json" and r.group(6) == "name,mealsPerDay,pricePerMeal,mealType", "http-response.adoc: 200 OK, application/json, the four members")
    sk = re.findall(r"^-- socket \| GET /api/v1/customers/Ravi \((no Accept|Accept: application/json)\) -> (\d+) (\S+) (\d+)", t, re.M)
    need(len(sk) == 2 and all(x[1] == "200" and x[2] == "application/json" for x in sk), "the socket twin (21000, H2, harness-free): 200 application/json, with no Accept and with Accept: application/json")
    eb = re.findall(r"^  the snippet's body against the socket's \((no Accept|Accept: application/json)\): (EQUAL key for key and value|DIFFERENT)", t, re.M)
    need(len(eb) == 2 and all(x[1].startswith("EQUAL") for x in eb), "the snippet's body = the socket's body, key for key and value (both)")
    ac = re.findall(r"^     access: GET /api/v1/customers/Ravi-? 200 \d+$", t, re.M)
    need(len(ac) == 2, "the access log holds the socket's two lines (%d)" % len(ac))
    need(re.search(r"^  listeners 20400-21299 during the MockMvc run: 0 · after: 0$", t, re.M) is not None, "MockMvc: no socket (0 listeners during and after the test run)")
    val("snippets", len(fs) if isinstance(fs, dict) else "-"); val("defaults_equal_blue", len(eq)); val("snippet_ct", r.group(2) if r else "-"); val("socket_ct", sk[0][2] if sk else "-")
def kinds(t):
    unparsed(t)
    J = {}
    for l in re.findall(r"^  case FailureKindsProbeTest\.(\w+) \| (.*)$", t, re.M): J[l[0]] = l[1]
    return J
def c_status(p):
    t = rd(p); J = kinds(t)
    need(re.search(r"^  the failing run: exit 1 · Tests run: 7, Failures: 2, Errors: 4, Skipped: 0$", t, re.M) is not None or re.search(r"^  the failing run: exit 1 · Tests run: 7,", t, re.M) is not None, "the failing run on the fail mirror: exit 1, 7 tests (six failing, the shipped test passing) - %s" % grab(r"^  the failing run: (.*)$", t))
    need(re.search(r"^  case TiffinBoxRestDocsTest\.thePublicReadIsDocumented \| passed$", t, re.M) is not None, "the shipped test passed in the same run")
    a = snips(t, "status-a"); b = snips(t, "status-b")
    need(a is None, "status A (the 201 expected before document()): directory ABSENT")
    need(isinstance(b, dict) and set(DEFAULTS) <= set(b), "status B (document() first): %s files - the six defaults%s" % (len(b) if isinstance(b, dict) else b, " and " + ",".join(sorted(set(b) - set(DEFAULTS))) if isinstance(b, dict) and set(b) - set(DEFAULTS) else ""))
    need(J.get("statusA", "").startswith("failure java.lang.AssertionError: Status expected:<201> but was:<200>") and J.get("statusB", "").startswith("failure java.lang.AssertionError: Status expected:<201> but was:<200>"), "both status tests fail with AssertionError: Status expected:<201> but was:<200>")
    ref = grab(r"^  the passing test's http-response\.adoc md5 ([0-9a-f]{32})$", t)
    need(isinstance(b, dict) and b.get("http-response.adoc", (0, ""))[1] == ref, "status B's http-response.adoc = the passing test's (the 200 documented)")
    need(re.search(r"^  package on the failing mirror: exit 1 · target/generated-docs ABSENT · the last phase line: .*surefire.*$", t, re.M) is not None, "the package build on the failing mirror stops at test: generated-docs ABSENT, the page step never reached")
    val("status_a", "absent"); val("status_b_files", len(b) if isinstance(b, dict) else "-")
def c_field(p):
    t = rd(p); J = kinds(t)
    res = {}
    for i in ("never-sent-a", "never-sent-b", "undocumented-a", "undocumented-b"):
        s = snips(t, i); res[i] = s
        need(isinstance(s, dict) and sorted(s) == sorted(DEFAULTS), "%s: the six defaults (%s files), no response-fields.adoc, no path-parameters.adoc" % (i, len(s) if isinstance(s, dict) else s))
    ref = dict(re.findall(r"^  passing \| (\S+) \| ([0-9a-f]{32})$", t, re.M))
    need(all(isinstance(s, dict) and all(s[f][1] == ref.get(f) for f in DEFAULTS) for s in res.values()), "every field case's six defaults = the passing test's md5s")
    need(J.get("neverSentA", "").startswith("error org.springframework.restdocs.snippet.SnippetException: Fields with the following paths were not found in the payload: [nickname]")
         and J.get("neverSentB", "").startswith("error org.springframework.restdocs.snippet.SnippetException: Fields with the following paths were not found in the payload: [nickname]"), "never sent (nickname), A and B: SnippetException, not found in the payload: [nickname]")
    need(J.get("undocumentedA", "").startswith("error org.springframework.restdocs.snippet.SnippetException: The following parts of the payload were not documented:") and "mealType" in J.get("undocumentedA", "")
         and J.get("undocumentedB", "").startswith("error org.springframework.restdocs.snippet.SnippetException: The following parts of the payload were not documented:"), "left undocumented (mealType), A and B: SnippetException, not documented")
    same = res["never-sent-a"] == res["never-sent-b"] and res["undocumented-a"] == res["undocumented-b"] and J.get("neverSentA") == J.get("neverSentB") and J.get("undocumentedA") == J.get("undocumentedB")
    print("  the order's effect on a field failure (A against B, read from the pairs): %s" % ("none - the same six files and the same exception in both orders" if same else "the orders DIFFER"))
    val("field_files", 6 if all(isinstance(s, dict) and len(s) == 6 for s in res.values()) else "-"); val("field_order_effect", "none" if same else "differs")
def c_accept(p):
    t = rd(p); unparsed(t)
    g = grab(r"^  the generated client's Accept \(read off \S+:\d+\): (.+)$", t)
    need(g == "*/*, application/problem+json", "the generated client's Accept, read off its source: %s" % g)
    rows = re.findall(r"^  accept \| (none|generated|json) \| MockMvc: (\d+) (\S+) \| socket: (\d+) (\S+)$", t, re.M)
    need(len(rows) == 3, "three Accepts, each with MockMvc's and the socket's Content-Type side by side")
    R = {r[0]: r[1:] for r in rows}
    for k in R: print("  accept %s: MockMvc %s %s · socket %s %s · %s" % (k, R[k][0], R[k][1], R[k][2], R[k][3], "agree" if R[k][1] == R[k][3] else "DISAGREE"))
    need(all(R[k][0] == "200" for k in R), "every Accept documents a 200")
    need(re.search(r"^  listeners 20400-21299 during the MockMvc run: 0 · after: 0$", t, re.M) is not None, "MockMvc: no socket during the accept run")
    for k in ("none", "generated", "json"): val("accept_%s" % k, "%s/%s" % (R[k][1], R[k][3]) if k in R else "-")
def c_driven(p):
    t = rd(p); unparsed(t)
    w = snips(t, "nobody-with-name"); wo = snips(t, "nobody-without-name")
    J = dict(re.findall(r"^  case DrivenErrorProbeTest\.(\w+) \| (.*)$", t, re.M))
    need(J.get("nobodyWithName") == "passed" and isinstance(w, dict) and "response-fields.adoc" in w, "with name documented: passed, %s files, response-fields.adoc written" % (len(w) if isinstance(w, dict) else w))
    need(J.get("nobodyWithoutName", "").startswith("error org.springframework.restdocs.snippet.SnippetException: The following parts of the payload were not documented:") and isinstance(wo, dict) and sorted(wo) == sorted(DEFAULTS),
         "with name left out: SnippetException (not documented: name), the six defaults, no response-fields.adoc")
    r = re.search(r"^  resp nobody-with-name \| status (.+?) \| Content-Type (\S+) \| ", t, re.M)
    need(r is not None and r.group(1) == "404 Not Found" and r.group(2) == "application/problem+json", "the snippet documents 404 Not Found, application/problem+json")
    e = grab(r"^  example: (EQUAL to \S+|DIFFERENT)", t)
    need(e is not None and e.startswith("EQUAL"), "the wire's body = the committed file's example for the Nobody 404, key for key and value (%s)" % e)
    eb = grab(r"^  the snippet's body against the wire's: (EQUAL key for key and value|DIFFERENT)", t)
    need(eb is not None and eb.startswith("EQUAL"), "the snippet's body = the wire's (21005, a harness copy's JVM)")
    val("driven_with_name", "passed"); val("driven_without_name", "SnippetException"); val("driven_type", grab(r" · type (\S+)$", t) or "-")
def c_html(p):
    t = rd(p)
    H = {}
    for m in re.finditer(r"^  hosts (\S+): (\d+) B · references (\d+) · distinct hosts (\d+)$", t, re.M): H[m.group(1)] = (int(m.group(2)), int(m.group(3)))
    hh = collections.defaultdict(dict)
    for m in re.finditer(r"^  host (\S+) \| (\S+) x(\d+)$", t, re.M): hh[m.group(1)][m.group(2)] = int(m.group(3))
    need("shipped.html" in H and H["shipped.html"][1] == 0, "the shipped page names %s hosts in its bytes (the gate: total 0)" % (H.get("shipped.html", ("-", "-"))[1]))
    need("nofonts.html" in H and "https://fonts.googleapis.com" in hh["nofonts.html"], "the nofonts page (:webfonts!: only): %s references, fonts.googleapis.com still in its bytes" % (H.get("nofonts.html", ("-", "-"))[1]))
    need("default.html" in H and "https://fonts.googleapis.com" in hh["default.html"] and H["default.html"][1] > H["nofonts.html"][1], "the default page: %s references (more than nofonts')" % (H.get("default.html", ("-", "-"))[1]))
    need(re.search(r'^  generator: <meta name="generator" content="Asciidoctor 2\.0\.23">$', t, re.M) is not None, "the generator line: Asciidoctor 2.0.23")
    need(re.search(r"^  footer \(masked\): Last updated <masked>$", t, re.M) is not None and not re.search(r"Last updated \d", t), "the footer's clock masked (self-tested)")
    need(re.search(r"^  the jar's entries named generated-docs or index\.html: 0$", t, re.M) is not None, "the web jar holds no page")
    need(re.search(r"^  git check-ignore: \.gitignore:\d+:target/\s+\S*generated-docs/index\.html$", t, re.M) is not None, "the page is ignored by git (target/)")
    need(re.search(r"^  the mask's self-test: ok$", t, re.M) is not None, "the HTML mask's self-test")
    for k in ("shipped.html", "nofonts.html", "default.html"):
        if k in H: val("hosts_%s" % k.split(".")[0], H[k][1]); val("bytes_%s" % k.split(".")[0], H[k][0])
    val("generator", "2.0.23")
def c_sealed(p):
    t = rd(p)
    v = {k: x for k, x in re.findall(r"^  seal9\.py cdp \((\w+)\) exit (\d+)$", t, re.M)}
    need(v.get("shipped") == "0", "the shipped page: seal9.py cdp exit 0 (the page asked nothing but this computer)")
    need(v.get("default") == "1" and re.search(r"^  default: +CDP OUTBOUND: https://fonts\.googleapis\.com/css$", t, re.M) is not None, "the default page: exit 1, CDP OUTBOUND https://fonts.googleapis.com/css (the judge red, this run)")
    need(v.get("nofonts") == "0", "the nofonts page: exit 0 - its bytes name the host, Chrome asked it nothing")
    need(v.get("probe") == "1" and v.get("empty") == "2", "the probe's filed events: exit 1; an empty events file: exit 2 (refused)")
    need(re.search(r"^  shipped: +CDP requests: (\d+) \(0 to a socket", t, re.M) is not None, "the shipped page's requests: none to a socket")
    need(re.search(r"^  Chrome version: Browser\.getVersion: product Chrome/\S+", t, re.M) is not None, "Chrome's version line printed (yours will differ)")
    need(re.search(r"^  cdp9\.mjs rendered on a file:// page: exit 2 \(tabs found: 0\)$", t, re.M) is not None, "cdp9.mjs's tab filter finds no file:// tab (exit 2, shown once, never used)")
    need(re.search(r"^  the dead proxy: nothing listens on 127\.0\.0\.1:9 · curl exit 7 \(refused\)$", t, re.M) is not None, "the dead proxy refused before Chrome started")
    tcp = re.findall(r"^  netlog (\w+): +NetLog TCP connect (\S+) +x\d+$", t, re.M)
    need(tcp and all(a.startswith("127.0.0.1:") for _, a in tcp), "every TCP connect in the three NetLogs went to 127.0.0.1 (%s)" % ",".join(sorted({a for _, a in tcp})))
    udp = sorted({a for _, a in re.findall(r"^  netlog (\w+): +NetLog UDP connect (\S+) +x\d+$", t, re.M)})
    urls = sorted({a for _, a in re.findall(r"^  netlog (\w+): +NetLog URL asked +(\S+) +x\d+$", t, re.M)})
    print("  as found (printed, neither asserted nor said): UDP %s · URL %s" % (",".join(udp) or "none", ",".join(urls) or "none"))
    need(re.search(r"^  netlog\.py \(Course 6\) on the default page's NetLog: exit 0", t, re.M) is not None, "Course 6's netlog.py on the plant's NetLog: exit 0 (the check that cannot fail here, shown)")
    need(re.search(r"^  a non-loopback TCP connect planted in a NetLog copy: .*every TCP connect to loopback: no", t, re.M) is not None, "a planted non-loopback TCP connect: the TCP verdict says no")
    need(re.search(r"^  a port named that the page never asked: exit 1$", t, re.M) is not None, "a port the page never asked: exit 1")
    need(re.search(r"^  Chrome profiles left: 0$", t, re.M) is not None, "every Chrome profile folder removed")
    val("chrome", grab(r"product Chrome/(\S+)", t) or "-"); val("sealed_shipped", v.get("shipped", "-")); val("sealed_default", v.get("default", "-")); val("sealed_nofonts", v.get("nofonts", "-"))
def c_compare(p):
    t = rd(p)
    d = grab(r"^  REST Docs: identifier directories under target/generated-snippets: (\d+)", t); s = grab(r"^  REST Docs: snippets in them: (\d+)$", t)
    need(d is not None and s is not None, "REST Docs (the real build): %s directory, %s snippets" % (d, s))
    sd = re.search(r"^  springdoc: operations (\d+) · paths (\d+) · operations with an error response (\d+) · schemas (\d+) \(([^)]*)\) · operations whose success lists \*/\* (\d+)$", t, re.M)
    need(sd is not None, "spring doc (/v3/api-docs on 21000, harness-free): %s operations, %s with an error response, %s schemas, %s successes listing */*" % (sd.group(1), sd.group(3), sd.group(4), sd.group(6)) if sd else "the springdoc line")
    kk = {}
    for side in ("a", "b"):
        m = re.search(r"^  \(%s\) KINDS (\d+)" % side, t, re.M); r = re.search(r"^  \(%s\) DISAGREEMENTS (\d+)" % side, t, re.M)
        kk[side] = (m.group(1) if m else "-", r.group(1) if r else "-")
    u10 = grab(r"^  unit 10's values block \(before's rows\): (.*)$", t)
    need(u10 == "kinds_a=6 rows_a=9 kinds_b=7 rows_b=10", "BEFORE (unit 10's, re-measured): %s" % u10)
    need(kk["a"] == ("6", "9") and kk["b"] == ("7", "10"), "AFTER: (a) %s / %s · (b) %s / %s - DELTA none (the change adds a test, not a route)" % (kk["a"] + kk["b"]))
    st = re.findall(r"^  \(a\) +\d+ (\S+) media +spec: \['\*/\*'\] \| wire: (\S+)$", t, re.M)
    print("  specwire9's response-media-type rows (diff (a)): %d - %s" % (len(st), "; ".join("%s */* | wire %s" % x for x in st)))
    need(len(st) >= 1, "the */* kind's rows are printed by specwire9 (%d)" % len(st))
    rp = re.findall(r"^  RANDOM_PORT \| (\w+)\.java:\d+:", t, re.M)
    need({"CustomerPatchesTest", "CustomerReadsTest"} <= set(rp), "the hand-off's two socket tests among the RANDOM_PORT classes, by grep: %s (%d in all)" % (",".join(sorted(set(rp))), len(set(rp))))
    mm = re.findall(r"^  MockMvc \| (\w+)\.java:\d+:", t, re.M)
    need("TiffinBoxRestDocsTest" in mm and "OpenApiSpecTest" in mm, "the MockMvc tests, by grep: OpenApiSpecTest and TiffinBoxRestDocsTest among them")
    val("socket_tests", len(set(rp)));
    val("restdocs_operations", d); val("restdocs_snippets", s); val("springdoc_operations", sd.group(1) if sd else "-"); val("springdoc_errors", sd.group(3) if sd else "-")
    val("springdoc_star", sd.group(6) if sd else "-"); val("star_rows", len(st)); val("kinds_a", kk["a"][0]); val("rows_a", kk["a"][1]); val("kinds_b", kk["b"][0]); val("rows_b", kk["b"][1])
def c_committed(p):
    t = rd(p)
    m = re.search(r"^  bytes (\d+) \(wc -c\) · md5 (\w+) · before's \(U10's\) md5 (\w+) · (byte-identical|DIFFERENT) · servers member: (\w+) · git diff 221465c on it: (\d+) lines$", t, re.M)
    need(m is not None and m.group(1) == "20306" and m.group(4) == "byte-identical" and m.group(5) == "absent" and m.group(6) == "0", "the committed file: 20306 B, byte-identical to U10's, no servers, git diff empty")
    need(re.search(r"= the committed file: byte-identical$", t, re.M) is not None, "the served document (servers removed) = the committed file")
    need(re.search(r"^  package:  OpenApiSpecTest tests 1 failures 0 errors 0 skipped 0$", t, re.M) is not None and re.search(r"^  twin:  OpenApiSpecTest tests 1 failures 0 errors 0 skipped 0$", t, re.M) is not None, "OpenApiSpecTest passes in package and the twin")
    val("file_bytes", m.group(1) if m else "-"); val("spec_md5", m.group(2)[:8] if m else "-")
def c_moved(p):
    t = rd(p)
    R = collections.OrderedDict()
    for side, req, rest in re.findall(r"^  (before|after) \| (.+?) -> (.*)$", t, re.M): R.setdefault(req, {})[side] = rest
    mv = [k for k, v in R.items() if v.get("before") != v.get("after")]
    for k in mv: print("  MOVED: %s | before %s | after %s" % (k, R[k].get("before"), R[k].get("after")))
    need(len(R) == 19 and not mv, "unit 10's nineteen requests: %d, moved %d (%s)" % (len(R), len(mv), ",".join(mv) or "none"))
    jm = re.search(r"^  web jar md5: before (\w+) · after (\w+)$", t, re.M)
    need(jm is not None and jm.group(1) != jm.group(2), "the web jar's md5 differs before -> after (expected: the web pom is embedded)")
    names = grab(r"^  entry names before -> after: (\S+)$", t); crc = re.findall(r"^  entry CRC moved: (\S+)$", t, re.M)
    need(names == "equal" and crc == ["META-INF/maven/com.tiffinbox/tiffinbox-web/pom.xml"], "the per-entry comparison: the names equal; the CRC moved in exactly one entry, the web module's own pom (%s)" % ",".join(crc))
    need(re.search(r"^  entries named restdocs, asciidoctor, jruby or generated-docs: before 0 · after 0$", t, re.M) is not None, "no REST Docs, Asciidoctor, JRuby or page entry in either jar")
    val("requests", len(R)); val("moved", len(mv)); val("jar_entries_moved", len(crc))
def c_seven(p):
    t = rd(p); exp = grab(r"the expected (\w{32})", t)
    s = re.findall(r"^  (before|after): the seven (\w{32})", t, re.M)
    need(len(s) == 2 and all(x[1] == exp for x in s), "the seven on before and after: %s = the expected" % (exp or "-")[:8])
    val("seven", (exp or "-")[:8])
def c_surface(p):
    t = rd(p); exp = grab(r"the expected (\w{32})", t)
    s = re.findall(r"^  (before|after): the old surface (\w{32}) \((\d+) requests, (\d+) lines\)", t, re.M)
    need(len(s) == 2 and all(x[1] == exp for x in s), "the old surface on before and after: %s = the expected (%s requests, %s lines)" % ((exp or "-")[:8], s[0][2] if s else "-", s[0][3] if s else "-"))
    pl = re.search(r"\(unchanged: (yes|NO)\) · the old surface \w+ \(moved: (yes|NO)\)", t)
    need(pl is not None and pl.groups() == ("yes", "yes"), "the S9.14 plant: the seven unchanged, the surface moves")
    val("surface", (exp or "-")[:8])
def c_inert(p):
    t = rd(p)
    m = re.search(r"wire: requests (\d+) · with the key: (\S+)$", t, re.M)
    need(m is not None and m.group(2) == "pause-key", "specwire9's wire: the key header on pause-key alone")
    s = re.findall(r"^  \.r-(\w+)\.new: sent the key: (\d+) · did not: (\d+)$", t, re.M)
    need(s and all(x[1] == "0" for x in s), "curl sent the key header 0 times in %s" % ",".join(x[0] for x in s))
    k = re.findall(r"^  key table \| (\S+) \| (\d+)$", t, re.M)
    need(k and all(x[1] == "0" for x in k if x[0] != "diff-after") and dict(k).get("diff-after") == "1", "the key table: 0 rows on every harness-joined read except diff's after send (1: pause-key)")
    need(re.search(r"^  MockMvc runs: key header sent 0 · key table read 0 \(no POST is driven by REST Docs here\)$", t, re.M) is not None, "the MockMvc runs send no key")
def c_exercise(p):
    t = rd(p)
    runs = re.split(r"^== the exercise, h2, ", t, flags=re.M)[1:]
    R = {}
    for r in runs:
        h = r.split(" ", 1)[0].rstrip(","); sh = r.split(", ", 1)[1].split(" ", 1)[0]
        res = "PASS" if re.search(r"^  PASS:", r, re.M) else (grab(r"^  FAIL \((clause \d)\)", r) or "FAIL")
        R[(h, sh)] = (res, grab(r"^  check exit (\d+)$", r), grab(r"^  the test: (.*)$", r))
    print("  exercise runs: %s" % " · ".join("%s/%s %s" % (k[0], k[1], v[0]) for k, v in R.items()))
    need(R.get(("broken", "bash"), ("",))[0] == "clause 1" and R.get(("broken", "zsh"), ("",))[0] == "clause 1", "broken: FAILS clause 1 under bash and zsh -f")
    br = R.get(("broken", "bash"), ("", "", ""))[2] or ""
    need("SnippetException" in br and "[nickname]" in br, "broken: the test's SnippetException, not found in the payload: [nickname] (measured)")
    need(R.get(("solved", "bash"), ("",))[0] == "PASS" and R.get(("solved", "zsh"), ("",))[0] == "PASS", "solved: PASS under bash and zsh -f")
    want = {"none": "clause 1", "delall": "clause 2", "optional": "clause 1", "disabled": "clause 1", "handsnippet": "clause 1"}
    got = {k[0]: v[0] for k, v in R.items() if k[0] in want}
    need(got == want, "the refused variants: %s" % " · ".join("%s %s" % kv for kv in sorted(got.items())))
    op = R.get(("optional", "bash"), ("", "", ""))[2] or ""
    print("  the optional variant: the test %s" % op)
    need(re.search(r"^  the solved test against \.\./after's: (equal|differ)", t, re.M) is not None, "the solved test's md5 against ../after's printed")
    val("broken", "SnippetException"); val("solved", "pass"); val("variants", len(got))

CAPS = {"tests": c_tests, "change": c_change, "pass": c_pass, "status": c_status, "field": c_field, "accept": c_accept, "driven": c_driven,
        "html": c_html, "sealed": c_sealed, "compare": c_compare, "committed": c_committed, "moved": c_moved, "seven": c_seven,
        "surface": c_surface, "inert": c_inert, "exercise": c_exercise}
def c_snippets(p):
    """the listing parser's own self-test (flag 2's plants): a line one byte off, an empty directory printed ABSENT"""
    t = rd(p); unparsed(t)
    need(snips("  snip x: 0 files\n", "x") == {}, "an empty directory reads as 0 files, never ABSENT")
    need(snips("  snip x: ABSENT\n", "x") is None, "an absent directory reads ABSENT")
def capture(nm, p):
    if nm in CAPS: CAPS[nm](p)
    elif nm == "snippets": c_snippets(p)
    else: fail("no checks for the capture %r" % nm)
    done()
def hashable(nm, p):
    for l in lines(p):
        if re.match(r"^  guard before ", l): continue
        if l.startswith("  Testcontainers' containers while verify ran"): continue
        if l.startswith("  Chrome version: ") or l.startswith("  Chrome ") and " up: " in l: continue
        l = re.sub(r"load1 [0-9.]+", "load1 <n>", l)
        l = re.sub(r"\bBLUE_RUN=\d+", "BLUE_RUN=<N>", l)
        l = re.sub(r"\b(Blue\d)r\d+\b", r"\1r<N>", l)
        l = re.sub(r"blue-specwire-\d+", "blue-specwire-<N>", l)
        l = re.sub(r"(\"(?:id|version|ts)\":)\d+", r"\1<n>", l) if nm == "compare" and l.startswith("  pair ") else l
        if nm == "sealed":
            if re.search(r"NetLog (?:UDP connect|URL asked|verdict)|seal9\.py netlog \(\w+\) exit|a non-loopback TCP connect planted", l): continue   # printed as found, never hashed (R.504)
            l = re.sub(r"(NetLog TCP connect +\S+ +)x\d+", r"\1x<n>", l)
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
             "modtable": lambda: modules(a[1], a[2], a[3]), "listing": lambda: listing(a[1], a[2:]), "junit": lambda: junit(a[1], a[2]), "hosts": lambda: hosts(a[1]),
             "maskhtml": lambda: maskhtml(a[1]), "resp": lambda: resp(a[1]), "eqbody": lambda: eqbody(a[1], a[2]), "example": lambda: example(a[1], a[2]),
             "springdoc": lambda: springdoc(a[1])}
        if a and a[0] in M: M[a[0]]()
        elif a: capture(a[0], a[1])
        else: print(__doc__); sys.exit(2)
    except SystemExit:
        raise
    except Exception as e:
        print("FAIL the checker could not read its input (%s: %s) - a FAIL line, never a traceback" % (e.__class__.__name__, str(e)[:120])); sys.exit(1)
