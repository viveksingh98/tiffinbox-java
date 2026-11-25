"""Course 9 unit 10's checker (python3 -I -B harness/chk10.py MODE ...). Every number the README may say is re-derived here from a capture's
own lines, a saved document or a shipped file, never typed. Each listing line a check reads is parsed by a named pattern or skipped by a
named rule; a line it cannot parse is a FAIL line and exit 1, never a traceback. The small readers (surefire, the mappings reader, the
values block, the hashable form) are U09's (chk09.py - copied from U09's harness, c9-unit09/harness); U09's document subcommands (perop,
blanket, shape, types, scheme, wide, the document-minus-additions hashing, the example-vs-wire equality, the ProblemDetail schema reader)
are left out (flag 20) - this unit's are the generator's: loc, census, modules, generate, jackson, call, pause, mock, default, counts.
Modes:
  static AFTER BEFORE      the carried prose slice, XFAM_S9S1's md5, the change's files (derived), the guards (i)-(v), the stale sentences
  hook | exq | gloss-line  print the spoken lines (typed ONCE, here; asserted against the brief's bytes by spoken)
  gloss README             the one new gloss line (Code generation), U06's, U08's and U09's still byte-equal, none re-glossed
  spoken HOOK EXQ          the spoken lines: byte-equal to S2B's Unit 10 Hook and Exercise lines, words, digits, spellings, statuses, dur9
  genmask FILE | genmd5 ROOT | panel FILE METHOD | gendiff A B STRING | genops GENROOT SPEC | members OUT BODY | example OUT SPEC |
  specop SPEC METHOD PATH | modtable UP AFTER BEFORE | mapjson SIDE | opsmap MAP SPEC | surefire XML    the small readers
  <capture> FILE           one capture's checks; prints ok/FAIL lines and one VALUES line
  hashable NAME FILE       the capture with its load- and run-dependent lines dropped, for receipts.md5
  values README VALS       README.md's values block = this run's VALUES lines"""
import collections, hashlib, io, json, os, re, subprocess, sys

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
HOOK = "The client generated from TiffinBox's own spec reads Ravi, and binds to Spring's mock server unchanged."
EXQ = "Your turn: this generated call reads Ravi from the wrong path. Fix the spec, then generate again."
GLOSS = "Code generation: source written by a tool from the spec."
BRIEFQ = "source written by a tool from the spec"
U06GLOSS = "A contract: what a route promises its callers: the path, the method, the shapes in and out."
U08GLOSS = "Swagger UI: a page drawn from the document."
U09GLOSS = "A problem type: the U-R-I that names an error's kind."
SPEC = "tiffinbox-web/src/test/resources/openapi/tiffinbox.json"
CHANGED = ["README.md", "pom.xml", "tiffinbox-client/pom.xml", "tiffinbox-client/src/test/java/com/tiffinbox/client/TiffinBoxClientTest.java"]
UNTOUCHED = ["Dockerfile", "compose.yaml", SPEC, "tiffinbox-web/pom.xml", "tiffinbox-core/pom.xml",
             "tiffinbox-web/src/test/java/com/tiffinbox/web/OpenApiSpecTest.java", "tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxOpenApi.java",
             "tiffinbox-web/src/main/java/com/tiffinbox/web/IdempotencyKeyFilter.java"]
LEFTOUT = ["perop", "blanket", "shape", "types", "scheme", "wide", "cdpev", "netread", "plantev", "plantnet", "c_sealed", "c_tryit"]
STALE = [r"\btwo modules\b(?! \(|, tiffinbox-core and tiffinbox-web, before)", r"\bno client module\b"]
STATUS = re.compile(r"(?<![\d.,:/-])\b(?:[1-5]\d\d)\b|\b(?:one|two|three|four|five)[\s-]hundred[\s-]and\b|\b(?:one|two|three|four|five)[\s-]hundred[\s-](?:one|two|three|four|five|six|seven|eight|nine|ten|eleven|twelve|thirteen|fourteen|fifteen)\b")
HING = re.compile(r"\b(?:bhai|yaar|dosto|kya|hai|nahi|nahin|matlab|karo|dekho|chalo|samjho|theek|accha|arre|haan|bilkul|zaroor|aur|toh|abhi|yeh|woh|kaise|kyun|bahut|thoda|sahi|galat)\b", re.I)
SPELL = re.compile(r"\b(?:API|URI|URL|RFC)s?\b|\bOpenAPI\b|\bspringdoc\b|\bopenapi-generator\b")
GENDATE = re.compile(r'date = "[^"]*"')

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

# ---- the generated sources ----------------------------------------------------------------------------------------------------------
def genmask(p):
    for l in lines(p): print(GENDATE.sub('date = "<generated-date>"', l))
def gentree(root):
    out = {}
    for r, ds, fs in os.walk(root):
        ds.sort()
        for f in sorted(fs):
            if not f.endswith(".java"): continue
            p = os.path.join(r, f); out[os.path.relpath(p, root)] = hashlib.md5(GENDATE.sub('date = "<generated-date>"', rd(p)).encode()).hexdigest()
    return out
def genmd5(root):
    t = gentree(root)
    if not t: print("  refused: no .java file under the root"); sys.exit(2)
    for k, v in sorted(t.items()): print("  gen | %s | %s" % (k, v))
    print("  generated .java files %d · the set's md5 (date masked) %s" % (len(t), hashlib.md5("\n".join("%s %s" % kv for kv in sorted(t.items())).encode()).hexdigest()))
def panel(p, meth):
    t = GENDATE.sub('date = "<generated-date>"', rd(p)).split("\n")
    head = [l for l in t if l.startswith(("package ", "@Generated", "public interface"))]
    i = next((k for k, l in enumerate(t) if re.search(r"\b%s\(" % re.escape(meth), l)), None)
    if i is None: print("  panel: no method %s" % meth); return
    j = next(k for k in range(i, -1, -1) if t[k].strip().startswith("String PATH_"))
    e = next(k for k in range(i, len(t)) if t[k].strip() == ");")
    for l in head + [""] + t[j:e + 1]: print("  panel | " + l)
def gendiff(a, b, s):
    A, Bt = gentree(a), gentree(b)
    moved = sorted(k for k in set(A) | set(Bt) if A.get(k) != Bt.get(k))
    naming = sorted(k for k in Bt if s in rd(os.path.join(b, k)))
    for k in moved: print("  moved | %s" % k)
    print("  files moved %d (%s) · files naming the edited text %d (%s) · %s" % (len(moved), ",".join(os.path.basename(x) for x in moved), len(naming), ",".join(os.path.basename(x) for x in naming), "EQUAL SETS" if moved == naming else "DIFFERENT SETS"))
def genops(gr, spec):
    d = json.load(open(spec, encoding="utf-8"))
    ops = [(m.upper(), p) for p, v in d["paths"].items() for m in v]
    api = os.path.join(gr, "src", "main", "java", "com", "tiffinbox", "client", "api")
    n = 0
    for f in sorted(os.listdir(api)):
        c = len(re.findall(r"^\s*@HttpExchange\(", rd(os.path.join(api, f)), re.M)); n += c
        print("  genops | %s | @HttpExchange %d | methods %s" % (f[:-5], c, ",".join(re.findall(r"^\s*ResponseEntity<.*?>\s+(\w+)\(", rd(os.path.join(api, f)), re.M))))
    gen = set()
    for f in sorted(os.listdir(api)):
        t = rd(os.path.join(api, f))
        for m, p in re.findall(r'method = "([A-Z]+)",\s*value = \w+\.(PATH_\w+)', t):
            pv = grab(r'String %s = "([^"]+)";' % p, t); gen.add((m, pv))
    print("  generated methods %d · the committed file's operations %d · the operations without a generated method: %s · generated methods without an operation: %s" % (
          n, len(ops), ",".join("%s %s" % x for x in sorted(set(ops) - gen)) or "none", ",".join("%s %s" % x for x in sorted(gen - set(ops))) or "none"))

# ---- the runner's lines, the spec -----------------------------------------------------------------------------------------------------
def members(out, body):
    t = rd(out); b = json.load(open(body, encoding="utf-8"))
    m = re.search(r"^CLIENT members (.*)$", t, re.M)
    if not m: print("NO MEMBERS LINE"); return
    got = dict(x.split("=", 1) for x in m.group(1).split())
    wire = {k: str(v) for k, v in b.items()}
    print("EQUAL (%s)" % ",".join(sorted(wire)) if got == wire else "DIFFERENT (runner %s, wire %s)" % (json.dumps(got, sort_keys=True), json.dumps(wire, sort_keys=True)))
def example(out, spec):
    t = rd(out); d = json.load(open(spec, encoding="utf-8"))
    m = re.search(r"^CLIENT body (.*)$", t, re.M)
    if not m: print("NO BODY LINE"); return
    w = json.loads(m.group(1))
    ex = d["paths"]["/api/v1/customers/{name}/pauses"]["post"]["responses"]["400"]["content"]["application/problem+json"]["examples"]
    hit = [k for k, v in ex.items() if v.get("value") == w]
    near = {k: sorted(set(w) ^ set(v.get("value", {}))) for k, v in ex.items()}
    print("%s (the examples: %s; members only one side has: %s)" % ("EQUAL to %s" % ",".join(hit) if hit else "DIFFERENT", ",".join(ex), json.dumps(near)))
def specop(spec, m, p):
    d = json.load(open(spec, encoding="utf-8")); o = d["paths"][p][m]
    print("parameters %s · header parameters %d · responses %s" % (",".join("%s(%s)" % (x["name"], x["in"]) for x in o.get("parameters", [])),
          sum(1 for x in o.get("parameters", []) if x.get("in") == "header"), ",".join(o.get("responses", {}))))

# ---- modules (git) ----------------------------------------------------------------------------------------------------------------
def modlist(p):
    return re.findall(r"<module>([^<]+)</module>", rd(p))
def modules(up, after, before):
    b = modlist(os.path.join(before, "pom.xml")); a = modlist(os.path.join(after, "pom.xml"))
    print("== the parent's <modules> (python over before/pom.xml and after/pom.xml - the frozen trees, not the working tree)")
    print("  modules before: %d (%s) · after: %d (%s) · added: %s · removed: %s" % (len(b), ",".join(b), len(a), ",".join(a), ",".join(x for x in a if x not in b) or "none", ",".join(x for x in b if x not in a) or "none"))
    dd = [l for l in subprocess.run(["diff", os.path.join(before, "pom.xml"), os.path.join(after, "pom.xml")], capture_output=True, text=True).stdout.splitlines() if l[:1] in "<>"]
    print("  the parent pom before -> after: %d lines added, %d removed (diff)" % (sum(1 for l in dd if l.startswith(">")), sum(1 for l in dd if l.startswith("<"))))
    for l in dd:
        if "<module>" in l or "<openapi-generator.version>" in l: print("  pom | %s" % l.strip())
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
        print("  commit | %s | unit %s | parent %s | modules %s | other %s" % (h, unit, par, ",".join(mods) or "-", ",".join(x[7:] for x in seg if x.startswith("parent:") and x != "parent:pom.xml") or "-"))
    print("  this unit's change (after/ against before, the frozen trees): parent pom.xml · modules %s" % ",".join(
          x for x in ("tiffinbox-core", "tiffinbox-web", "tiffinbox-client") if tree(os.path.join(after, x), {"target"}) != (tree(os.path.join(before, x), {"target"}) if os.path.isdir(os.path.join(before, x)) else None)))
    us = [x for x in rows if x[2] != "-" or x[3]]
    print("  the sentence for the scripts stage (printed, never written): units whose commit changed the parent pom or a module: %s; the first to add a module: 10" % ", ".join(sorted({x[1] for x in us if x[1].isdigit()})))

# ---- U09's small readers, copied ----------------------------------------------------------------------------------------------------
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
def ops(mp, sp):
    rows = [r for r in maprows(json.load(open(mp))) if r[0].startswith("com.tiffinbox")]
    d = json.load(open(sp)); d.pop("servers", None)
    O = {(m.upper(), p): set(o.get("tags", [])) for p, v in d["paths"].items() for m, o in v.items()}
    kebab = lambda n: re.sub(r"(?<!^)(?=[A-Z])", "-", n).lower()
    seen = collections.Counter()
    for r in sorted(rows):
        k = (r[2], r[3]); cl = r[0].rsplit(".", 1)[1]
        st = "operation %s %s" % k if k in O and kebab(cl) in O[k] else "absent"
        if st != "absent": seen[k] += 1
        print("  op | %s#%s | %s %s | %s" % (r[0].rsplit('.', 1)[1], r[1], r[2], r[3], st))
    print("  op document: paths %d · operations %d · operations no handler maps: %d" % (len(d["paths"]), len(O), len([k for k in O if k not in seen])))

# ---- static ---------------------------------------------------------------------------------------------------------------------------
def static(after, before):
    md = lambda x: hashlib.md5("\n".join(x).encode()).hexdigest()
    end = "# --- XFAM_S9S1 end ---"
    s10 = rd(os.path.join(HERE, "s910.py")).split("\n")
    s9 = rd(os.path.join(UNIT, "..", "c9-unit09", "harness", "s909.py")).split("\n")
    if any(end not in s for s in (s10, s9)): fail("the XFAM_S9S1 end marker is missing in s910.py or s909.py"); done()
    a = lambda s: next(i for i, l in enumerate(s) if l.endswith('"""') and i > 0)
    sl = lambda s: s[a(s) + 1:s.index(end) + 1]
    need(sl(s10) == sl(s9), "s910.py's base + XFAM_S9S1 (after its docstring, through the block's end marker) = s909.py's, %d lines, md5 %s (copied from U09's harness)" % (len(sl(s9)), md(sl(s9))))
    t10 = "\n".join(s10)
    b = re.search(r"# --- XFAM_S9S1 begin ---\n.*?# --- XFAM_S9S1 end ---", t10, re.S)
    if b:
        h = hashlib.md5(b.group(0).encode()).hexdigest()
        print("  XFAM_S9S1_SLICE_MD5 = %s (computed the way ../c9-unit04/harness/chk04.py computes it)" % h); val("xfam_s9s1_md5", h[:8])
    need(not re.search(r"^XU0\d = ", t10, re.M), "XU01-XU09 are not carried")
    need(re.search(r"^XU10 = ", t10, re.M) is not None and re.search(r"^u04 = u10$", t10, re.M) is not None, "U10's own family (XU10) follows the carried slice; u04 = u10 (U01's binding)")
    x2 = os.path.join(C9R, "_builders", "s907.py")
    print("  XFAM_S9S2 (the scripts stage's, C9/_builders/s907.py): %s" % ("present - not asserted here" if os.path.exists(x2) and "XFAM_S9S2" in rd(x2) else "does not exist yet - nothing to assert XU10 against"))
    ck = rd(os.path.join(HERE, "chk10.py"))
    dead = [w for w in LEFTOUT if re.search(r"^def (?:c_)?%s\(" % re.escape(w), ck, re.M) or re.search(r'"%s": lambda' % re.escape(w), ck)]
    need(not dead, "chk10.py carries none of U09's left-out subcommands (%s): %s" % (",".join(LEFTOUT), ",".join(dead) or "none"))
    A, Bt = tree(after, {"target"}), tree(before, {"target"})
    ch = sorted(k for k in set(A) | set(Bt) if A.get(k) != Bt.get(k))
    print("  the change (after/ against before, the frozen trees; the derived list): %d files: %s" % (len(ch), " ".join(ch)))
    need(ch == sorted(CHANGED), "the changed files are exactly the parent pom, the README, the client's pom and its one test")
    val("changed_files", len(ch))
    need(not [k for k in ch if k.startswith(("tiffinbox-web/", "tiffinbox-core/"))], "(i) nothing under tiffinbox-web/ or tiffinbox-core/ changed")
    need(all(A.get(k) == Bt.get(k) and A.get(k) for k in UNTOUCHED), "(i) the Dockerfile, compose.yaml, the committed spec, both module poms, OpenApiSpecTest, TiffinBoxOpenApi and IdempotencyKeyFilter byte-equal to before's")
    dd = [l for l in subprocess.run(["diff", os.path.join(before, "pom.xml"), os.path.join(after, "pom.xml")], capture_output=True, text=True).stdout.splitlines() if l[:1] in "<>"]
    plus = [l[2:] for l in dd if l.startswith(">")]
    need(not [l for l in dd if l.startswith("<")] and sum("<module>tiffinbox-client</module>" in l for l in plus) == 1 and sum("<openapi-generator.version>7.27.0</openapi-generator.version>" in l for l in plus) == 1
         and all(re.match(r"^\s*(<!--|<module>tiffinbox-client</module>|<openapi-generator\.version>|\S.*-->$|[a-z(])", l) or l.strip().startswith(("pin ", "the ", "measured", "receipts")) for l in plus),
         "(ii) the parent pom's diff: %d lines added, 0 removed - one <module>, one property and its comment" % len(plus))
    cp = rd(os.path.join(after, "tiffinbox-client", "pom.xml"))
    deps = re.findall(r"<artifactId>([^<]+)</artifactId>", cp.split("<dependencies>")[1].split("</dependencies>")[0])
    print("  the client's declared dependencies: %s" % ",".join(deps))
    bad = [x for x in ("tiffinbox-web", "tiffinbox-core", "jackson-databind", "jackson-databind-nullable", "httpclient5") if x in deps]
    need(not bad, "(iii) the client names no dependency on tiffinbox-web / tiffinbox-core, no jackson-databind, jackson-databind-nullable or httpclient5 (%s)" % (",".join(bad) or "none"))
    pomall = "".join(rd(os.path.join(after, p)) for p in ("pom.xml", "tiffinbox-client/pom.xml", "tiffinbox-web/pom.xml", "tiffinbox-core/pom.xml"))
    need(not re.search(r"restclient</library>|<generatorName>java<|jackson-databind-nullable", pomall), "(iii) no restclient library, generatorName java or jackson-databind-nullable in the anchor's poms")
    need("<generatorName>spring</generatorName>" in cp and "<library>spring-http-interface</library>" in cp and "<inputSpec>${project.baseUri}../" + SPEC + "</inputSpec>" in cp,
         "the generator's one execution: spring, spring-http-interface, the committed file read in place")
    need(not os.path.exists(os.path.join(after, "tiffinbox-client", "src", "main")), "the client has no src/main of its own")
    need(not os.path.exists(os.path.join(after, "tiffinbox-client", "src", "main", "openapi")) and SPEC.split("/")[-1] not in " ".join(k for k in A if k.startswith("tiffinbox-client/")), "no copy of the spec inside tiffinbox-client")
    rm = rd(os.path.join(after, "README.md"))
    card = re.search(r"^## Course 9 · unit 10 — .*?(?=^## |^---$|\Z)", rm, re.M | re.S)
    need(card is not None, "the README has a Course 9 · unit 10 card")
    if card:
        st = [(rx, grab("(" + rx + ")", card.group(0))) for rx in STALE if re.search(rx, card.group(0))]
        need(not st, "R.250/R.453: no stale sentence in unit 10's card (\"two modules\" as current, \"no client module\"): %s" % (st or "none"))
    need("*Course 9, unit 10:" in rm.split("## Course 9 · unit 04")[0], "the README's header carries a *Course 9, unit 10: ...* note")
    harn = sorted(os.listdir(HERE))
    need(not [x for x in harn if x in ("cdp.mjs", "cdp9.mjs", "seal9.py")], "no browser instrument in harness/")
    done()

# ---- the spoken lines -----------------------------------------------------------------------------------------------------------------
def brief_lines():
    t = rd(S2B).split("\n")
    i0 = next(i for i, l in enumerate(t) if l.startswith("## Unit 10 · Code Generation From the Contract")); i1 = next(i for i, l in enumerate(t) if i > i0 and l.startswith("## "))
    print("  the brief's Unit 10 section: S2B :%d-:%d" % (i0 + 1, i1))
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
    need(hook == HOOK == bh, "the hook is S2B's Unit 10 Hook line's quote, byte for byte (extracted at run time = typed once here)")
    need(exq == EXQ == be, "the exercise's line is S2B's Unit 10 Exercise line's quote, byte for byte (extracted at run time = typed once here)")
    hw, ew, gw = len(hook.split()), len(exq.split()), len(GLOSS.split())
    need(hw == 16 and hw <= 25, "the hook: %d words (wc -w; the brief's 16; <= 25)" % hw)
    need(ew == 17 and ew <= 25, "the exercise: %d words (wc -w; the brief's 17; <= 25)" % ew)
    for name, s in (("the hook", hook), ("the exercise", exq), ("the gloss", GLOSS)):
        nd = re.findall(r"\d", s)
        print("  %s: digits %s · the status gate %s · the spelling gate %s · Hinglish %s · dur9 %s" % (name, "".join(nd) or "0", "hit" if STATUS.search(s) else "0",
              SPELL.search(s).group(0) if SPELL.search(s) else "0", "hit" if HING.search(s) else "0", dur.search(s).group(0) if dur is not None and dur.search(s) else "0"))
        need(not STATUS.search(s), "%s: the status gate 0" % name)
        need(not SPELL.search(s), "%s: the spelling gate 0 (API, URI, URL, RFC, bare OpenAPI / springdoc / openapi-generator)" % name)
        need(not HING.search(s), "%s: the Hinglish list 0" % name)
        if dur is not None: need(not dur.search(s), "%s: dur9 0" % name)
        need(not nd, "%s: no digit" % name)
    for p in ("Open A-P-I", "spring doc", "Open A-P-I Generator"): need(not SPELL.search(p), "the spelled form %r passes the spelling gate" % p)
    for p in ("OpenAPI", "springdoc", "openapi-generator"): need(bool(SPELL.search("It reads the " + p + " document.")), "the bare %r refuses in a spoken line" % p)
    print("  the hook: %d words · the exercise: %d words · the gloss: %d words; the brief's parenthetical (%d words): \"%s\"" % (hw, ew, gw, len(BRIEFQ.split()), BRIEFQ))
    val("hook_words", hw); val("exercise_words", ew); val("gloss_words", gw)
    done()
def gloss(readme):
    u6 = rd(os.path.join(UNIT, "..", "c9-unit06", "README.md")).split("\n")
    u8 = rd(os.path.join(UNIT, "..", "c9-unit08", "README.md")).split("\n")
    u9 = rd(os.path.join(UNIT, "..", "c9-unit09", "README.md")).split("\n")
    need(len(u6) > 18 and u6[18] == U06GLOSS, "U06's gloss line is still byte-equal at ../c9-unit06/README.md:19")
    need(len(u8) > 15 and u8[15] == U08GLOSS, "U08's gloss line is still byte-equal at ../c9-unit08/README.md:16")
    n9 = [i + 1 for i, l in enumerate(u9) if l == U09GLOSS]
    need(len(n9) == 1, "U09's gloss line is still byte-equal at ../c9-unit09/README.md:%s" % (n9[0] if n9 else "-"))
    r = rd(readme).split("\n")
    g = [i + 1 for i, l in enumerate(r) if re.match(r"^\s*(?:A contract|Swagger UI|A problem type):", l)]
    need(not g, "README.md carries no line starting \"A contract:\", \"Swagger UI:\" or \"A problem type:\" (not re-glossed) %s" % g)
    s = [i + 1 for i, l in enumerate(r) if l.startswith("Code generation:")]
    need(len(s) == 1 and r[s[0] - 1] == GLOSS, "README.md carries exactly one line starting \"Code generation:\", the gloss byte for byte (%s)" % s)
    need(len(GLOSS.split()) <= 25, "the gloss: %d words (<= 25)" % len(GLOSS.split()))
    first = next((i + 1 for i, l in enumerate(r) if "code generation" in re.sub(r"`[^`]*`", "", l).lower() and not l.startswith("#")), None)
    print("  the gloss (%d words): %s · the brief's parenthetical (%d words): %s" % (len(GLOSS.split()), GLOSS, len(BRIEFQ.split()), BRIEFQ))
    print("  first spoken use of \"code generation\" in the README at line %s" % first)
    val("gloss", "code_generation_one_line")
    done()

# ---- the captures' checks ---------------------------------------------------------------------------------------------------------
def sf(t, prefix):
    """surefire lines under a prefix: {class: (tests, failures, errors, skipped)}"""
    out = {}
    for m in re.finditer(r"^  %s(\w+) tests (\d+) failures (\d+) errors (\d+) skipped (\d+)$" % re.escape(prefix), t, re.M): out[m.group(1)] = tuple(int(x) for x in m.groups()[1:])
    return out
def tot(d): return [sum(v[i] for v in d.values()) for i in range(4)]
def c_tests(p):
    t = rd(p)
    need(re.search(r"^  mvn package exit 0 · Downloading/Downloaded from: 0$", t, re.M) is not None, "package: exit 0, offline")
    rs = re.findall(r"^  reactor: (TiffinBox[A-Za-z ]*) \.\.\. (SUCCESS|FAILURE|SKIPPED)", t, re.M)
    need(rs[:4] == [("TiffinBox", "SUCCESS"), ("TiffinBox Core", "SUCCESS"), ("TiffinBox Web", "SUCCESS"), ("TiffinBox Client", "SUCCESS")], "the reactor: four projects (the parent and three modules), each SUCCESS")
    w = sf(t, "tiffinbox-web | "); c = sf(t, "tiffinbox-client | ")
    need(tot(w) == [49, 0, 0, 0], "tiffinbox-web at package: %s tests, 0 failures, 0 errors, 0 skipped (U09's 49, re-measured)" % tot(w)[0])
    need(tot(c) == [1, 0, 0, 0] and list(c) == ["TiffinBoxClientTest"], "tiffinbox-client at package: %s test, run, none skipped (TiffinBoxClientTest)" % tot(c)[0])
    need(re.search(r"^  mvn package \(Docker-free\) exit 0 · Downloading/Downloaded from: 0$", t, re.M) is not None, "the Docker-free twin: exit 0")
    tw = sf(t, "twin tiffinbox-web | "); tc = sf(t, "twin tiffinbox-client | ")
    need(tot(tw) == tot(w) and tot(tc) == tot(c), "the twin's counts = package's")
    nt = re.findall(r"^  new @Test \| (\w+) \| (\d+) \| ([\w,]+) \| before/\S+: absent$", t, re.M)
    need(nt == [("TiffinBoxClientTest", "1", "readsRaviThroughTheMockServer")], "the new @Test lines: 1, readsRaviThroughTheMockServer, a file before lacks")
    need(re.search(r"^  existing tests \(tiffinbox-web/src/test, tiffinbox-core/src\) before -> after/: 0 files differ$", t, re.M) is not None, "no existing test or core file edited")
    need(re.search(r"^  mvn verify exit 0 · Downloading/Downloaded from: 0$", t, re.M) is not None and "TIMED OUT" not in t, "verify: exit 0, offline, no IT wait timed out")
    it = {k: v for k, v in sf(t, "").items() if k.endswith("IT")}
    need(len(it) == 5 and tot(it) == [14, 0, 0, 0], "the five ITs: %d tests, 0 failures (14)" % tot(it)[0])
    ib = re.findall(r"^  IT BINDINGS (\w+) \[(.*)\]$", t, re.M)
    ent = [e for _, x in ib for e in re.findall(r"[0-9.]+:\d+", x)]
    need(len(ib) == 5 and ent and all(e.startswith("127.0.0.1:") for e in ent), "IT BINDINGS: classes %d · entries %d · not 127.0.0.1: %d" % (len(ib), len(ent), sum(1 for e in ent if not e.startswith("127.0.0.1:"))))
    need(re.search(r"^  the client's ITs: 0 \(the module has no IT\)$", t, re.M) is not None, "the client has no IT")
    need(re.search(r"^  Testcontainers containers after: 0 · listeners on 21280-21284 after: 0$", t, re.M) is not None, "after verify: 0 containers, 21280-21284 free")
    need(re.search(r"^  exit 0 · Downloading/Downloaded from: 0 · tiffinbox-client/target after it: absent$", t, re.M) is not None, "the web-only form builds no client")
    wo = sf(t, "webonly tiffinbox-web | ")
    need(tot(wo) == tot(w), "the web-only form's web counts = the reactor's (%s)" % tot(wo)[0])
    lb = re.findall(r"^  (before|after): (\d+) jars · ", t, re.M)
    need(lb == [("before", "157"), ("after", "157")] and re.search(r"^  the jars' names moved before -> after: 0$", t, re.M) is not None, "BOOT-INF/lib 157 before and after, no name moved")
    val("web_tests", tot(w)[0]); val("client_tests", tot(c)[0]); val("client_skipped", tot(c)[3]); val("its", tot(it)[0]); val("it_classes", len(ib)); val("lib", lb[1][1] if len(lb) > 1 else "-")
    val("reactor", len(rs[:4]))
def c_census(p):
    t = rd(p)
    m = re.search(r"^  after: handler methods: (\d+) in all, (\d+) TiffinBox's", t, re.M)
    o = re.search(r"^  op document: paths (\d+) · operations (\d+) · operations no handler maps: (\d+)$", t, re.M)
    ab = len(re.findall(r"^  op \| .* \| absent$", t, re.M)); opn = len(re.findall(r"^  op \| .* \| operation ", t, re.M))
    need(m is not None and m.group(2) == "17", "after/'s TiffinBox handler methods: %s (U09's 17)" % (m.group(2) if m else "-"))
    need(o is not None and (o.group(1), o.group(2), o.group(3)) == ("11", "13", "0"), "the document: 11 paths, 13 operations, every operation a handler's")
    need(opn == 15 and ab == 2 or (opn + ab == 17), "the 17 handlers: %d documented, %d absent" % (opn, ab))
    g = re.search(r"^  generated methods (\d+) · the committed file's operations (\d+) · the operations without a generated method: (\S+) · generated methods without an operation: (\S+)$", t, re.M)
    need(g is not None and g.group(2) == "13", "the generated methods beside the 13 operations: %s generated, without a method: %s, without an operation: %s" % (g.groups()[0], g.group(3), g.group(4)) if g else "the genops line")
    pn = re.findall(r"^  generated PATH_ constants naming (\S+): (\d+)$", t, re.M)
    need(dict(pn) == {'"/customers/new"': "0", '"/dashboard"': "1"}, "the form page /customers/new has no generated constant; /dashboard has one, the JSON operation's (DashboardPage's own handlers share its method and path, no operation of their own): %s" % pn)
    j = re.findall(r"^  (before|after)'s web jar: (\d+) entries named com/tiffinbox/client · (\d+) named probe/$", t, re.M)
    need(j == [("before", "0", "0"), ("after", "0", "0")], "the web jars: 0 entries named com/tiffinbox/client, 0 named probe/")
    pl = grab(r"^  plant \(one client class added to a scratch copy of the web jar\): (\d+) entries", t)
    need(pl == "1", "the plant's scratch jar: 1 entry named com/tiffinbox/client - the check refuses it (the harness's plant)")
    val("handlers", m.group(2) if m else "-"); val("operations", o.group(2) if o else "-"); val("generated_methods", g.group(1) if g else "-")
def c_modules(p):
    t = rd(p)
    m = re.search(r"^  modules before: (\d+) \(([^)]*)\) · after: (\d+) \(([^)]*)\) · added: (\S+) · removed: (\S+)$", t, re.M)
    need(m is not None and m.groups() == ("2", "tiffinbox-core,tiffinbox-web", "3", "tiffinbox-core,tiffinbox-web,tiffinbox-client", "tiffinbox-client", "none"), "the parent's <modules>: 2 -> 3, tiffinbox-client added after tiffinbox-web")
    d = re.search(r"^  the parent pom before -> after: (\d+) lines added, (\d+) removed", t, re.M)
    need(d is not None and d.group(2) == "0", "the parent pom: additions only (%s added)" % (d.group(1) if d else "-"))
    rows = re.findall(r"^  commit \| (\w+) \| unit (\S+) \| parent (\S+) \| modules (\S+) \| other (\S+)$", t, re.M)
    need(len(rows) >= 7 and not [r for r in rows if "tiffinbox-client" in r[3]], "%d commits touched c9-tiffinbox/ before this one; none touched a tiffinbox-client module" % len(rows))
    need(re.search(r"^  this unit's change \(after/ against before, the frozen trees\): parent pom\.xml · modules tiffinbox-client$", t, re.M) is not None, "this unit's change: the parent pom and tiffinbox-client only")
    val("modules_before", m.group(1) if m else "-"); val("modules_after", m.group(3) if m else "-"); val("commits", len(rows))
def c_generate(p):
    t = rd(p)
    need(re.search(r"^  listeners 20400-21299 before: 0$", t, re.M) is not None and re.search(r"^  exit 0 · Downloading/Downloaded from: 0 · listeners 20400-21299 after: 0 · tiffinbox-web/target: absent", t, re.M) is not None,
         "the generator's run: exit 0, offline, nothing listening 20400-21299 before or after, no web module built")
    need(re.search(r"^  the build step's line: openapi-generator(-maven-plugin)?:7\.27\.0:generate \(tiffinbox\) @ tiffinbox-client$", t, re.M) is not None, "the build step 7.27.0, execution tiffinbox")
    sha = grab(r"^  the committed file: \d+ B · md5 \w+ · sha256 (\w+)$", t); rec = grab(r"^  the generator's own record \([^)]*\): (\w+)$", t)
    need(sha is not None and rec is not None, "the input: shasum -a 256 of the committed file %s; the generator's own record %s (%s - the record is not the file's sha256)" % ((sha or "-")[:8], (rec or "-")[:8], "equal" if sha == rec else "different"))
    val("gen_record", (rec or "-")[:8])
    need(grab(r"^  inputSpec \(the pom\): \S+ · resolved: (\S+)$", t) == SPEC, "the input resolves to the committed file in place (%s)" % SPEC)
    need(re.search(r"^  \.openapi-generator/VERSION: 7\.27\.0 · the parent's property: 7\.27\.0$", t, re.M) is not None, "VERSION 7.27.0 = the parent's property")
    fl = re.findall(r"^  FILES \| (\S+)$", t, re.M); jv = [x for x in fl if x.endswith(".java")]
    need(len(jv) >= 1, "FILES: %d entries, %d *.java" % (len(fl), len(jv)))
    s1 = grab(r"^  generated \.java files (\d+) · the set's md5 \(date masked\) (\w+)$", t, 2); n1 = grab(r"^  generated \.java files (\d+) · ", t)
    s2 = grab(r"^  the same set from after/'s own build \(\.harness/after\):   generated \.java files \d+ · the set's md5 \(date masked\) (\w+)$", t)
    need(s1 is not None and s1 == s2 and n1 == str(len(jv)), "the generated set (date masked): %s files, md5 %s, = after/'s own build's" % (n1, s1))
    need(re.search(r"^  panel \| @Generated\(value = \"[^\"]+\", date = \"<generated-date>\"", t, re.M) is not None and not re.search(r'date = "\d', t), "every @Generated date masked")
    gd = re.search(r"^  files moved (\d+) \(([^)]*)\) · files naming the edited text (\d+) \(([^)]*)\) · (EQUAL SETS|DIFFERENT SETS)$", t, re.M)
    need(gd is not None and gd.group(5) == "EQUAL SETS" and gd.group(1) != "0", "the one-byte mirror: the files that moved are exactly the files naming the edit (%s)" % (gd.group(2) if gd else "-"))
    cs = re.search(r"^  exit \d+ · OpenApiSpecTest tests 1 failures (\d+) errors \d+ skipped \d+$", t, re.M)
    st = grab(r"^  the client generated from the stale copy:   generated \.java files \d+ · the set's md5 \(date masked\) (\w+) ", t)
    need(cs is not None and cs.group(1) == "1" and st == s1, "the second-copy mirror: OpenApiSpecTest red, the client generated from the stale copy unchanged (measured, not shipped)")
    val("gen_java_files", n1); val("gen_md5", (s1 or "-")[:8]); val("version", "7.27.0"); val("onebyte_moved", gd.group(1) if gd else "-")
def c_jackson(p):
    t = rd(p)
    c = re.search(r"^  com\.fasterxml\.jackson\.core:jackson-databind \(Jackson 2\): (\d+) · org\.openapitools:jackson-databind-nullable: (\d+) · httpclient5: (\d+) · tools\.jackson\.core:jackson-databind \(Jackson 3\): (\d+) · com\.fasterxml\.jackson\.core:jackson-annotations \(shared, kept by Jackson 3\): (\d+)$", t, re.M)
    need(c is not None and c.groups() == ("0", "0", "0", "1", "1"), "the client's resolved list: Jackson 2's databind 0, jackson-databind-nullable 0, httpclient5 0, Jackson 3's databind 1, jackson-annotations 1")
    im = dict(re.findall(r"^  imports '([^']+)': (\d+)$", t, re.M))
    need(im.get("import com.fasterxml.jackson.databind") == "0" and im.get("import tools.jackson") == "0" and im.get("import org.openapitools.jackson.nullable") == "0" and int(im.get("import com.fasterxml.jackson.annotation", "0")) > 0,
         "the generated imports: databind (2) 0, tools.jackson 0, the nullable module 0, the annotation package %s" % im.get("import com.fasterxml.jackson.annotation"))
    jp = re.findall(r"^  javap \| (\S+) \| com/fasterxml/jackson/databind (\d+) \| tools/jackson (\d+) \| com/fasterxml/jackson/annotation (\d+)$", t, re.M)
    need(jp and all(x[1] == "0" for x in jp), "the compiled classes' constant pools: %d classes, com/fasterxml/jackson/databind 0 in each" % len(jp))
    lb = re.findall(r"^  (before|after): (\d+) jars · ", t, re.M)
    need(lb == [("before", "157"), ("after", "157")], "the web jar's BOOT-INF/lib 157 before and after")
    val("databind2", c.group(1) if c else "-"); val("nullable", c.group(2) if c else "-"); val("hc5", c.group(3) if c else "-"); val("annotation_imports", im.get("import com.fasterxml.jackson.annotation", "-")); val("classes", len(jp))
def c_committed(p):
    t = rd(p)
    m = re.search(r"^  bytes (\d+) \(wc -c\) · md5 (\w+) · before's \(U09's\) md5 (\w+) · (byte-identical|DIFFERENT) · servers member: (\w+)$", t, re.M)
    need(m is not None and m.group(1) == "20306" and m.group(4) == "byte-identical" and m.group(5) == "absent", "the committed file: 20306 B, byte-identical to U09's, no servers")
    need(re.search(r"= the committed file: byte-identical$", t, re.M) is not None, "the served document (servers removed) = the committed file")
    need(re.search(r"^  package:  OpenApiSpecTest tests 1 failures 0 errors 0 skipped 0$", t, re.M) is not None and re.search(r"^  twin:  OpenApiSpecTest tests 1 failures 0 errors 0 skipped 0$", t, re.M) is not None, "OpenApiSpecTest passes in package and the twin")
    val("file_bytes", m.group(1) if m else "-"); val("spec_md5", m.group(2)[:8] if m else "-")
def blocks(t):
    """the runner's blocks: each starts at a CLIENT builder line"""
    out = []; cur = None
    for l in t.splitlines():
        if l.startswith("  CLIENT builder "): cur = [l]; out.append(cur); continue
        if cur is not None and (l.startswith("  CLIENT ") or l.startswith("  runner") or l.startswith("  the runner's exit")): cur.append(l)
        if l.startswith("  the runner's exit"): cur = None
    return out
def c_call(p):
    t = rd(p); B = blocks(t)
    need(len(B) == 5, "five runs of the runner: call, Nobody, call with HttpClient 5, nothing listening, the stub (%d)" % len(B))
    if len(B) < 5: done()
    b = "\n".join(B[0])
    need(re.search(r"factory org\.springframework\.http\.client\.JdkClientHttpRequestFactory$", B[0][0]) is not None, "call: the factory of RestClient.builder() on the client's class path (no HttpClient 5): JdkClientHttpRequestFactory")
    need("org.springframework.http.converter.json.JacksonJsonHttpMessageConverter" in b and "MappingJackson2" not in b, "call: the converters hold Jackson 3's JacksonJsonHttpMessageConverter, no Jackson 2 converter")
    r = re.search(r"^  CLIENT one\(Ravi\) -> (\d+) (\S+) (\S+)$", b, re.M)
    need(r is not None and r.group(1) == "200" and r.group(3) == "com.tiffinbox.client.model.Customer", "call: one(Ravi) -> 200, the generated model com.tiffinbox.client.model.Customer")
    need(grab(r"^  the runner's members against curl's body \(python, key for key\): (\w+)", t) == "EQUAL", "call: the members equal curl's body, key for key")
    acc = grab(r"^  the access log's line for it: (GET /api/v1/customers/Ravi\S* .*)$", t)
    need(acc is not None and " 200 " in acc, "call: the access log's line (%s)" % acc)
    ua = grab(r"ua=(\S+)", acc or "")
    cts = re.findall(r"^-- (curl-[\w-]+) \| GET \S+ -> (\d+) (\S+) \d+", t, re.M)
    need(len(cts) == 3 and all(x[1] == "200" for x in cts), "curl beside: three Accept headers, each 200 (%s)" % " · ".join("%s %s" % (x[0], x[2]) for x in cts))
    n = "\n".join(B[1])
    need(re.search(r"^  CLIENT thrown org\.springframework\.web\.client\.HttpClientErrorException\$NotFound status 404 application/problem\+json$", n, re.M) is not None, "Nobody: HttpClientErrorException.NotFound, 404, application/problem+json")
    pd = grab(r"^  CLIENT as com\.tiffinbox\.client\.model\.ProblemDetail (.*)$", n)
    need(pd is not None and "properties={}" in pd and '"name":"Nobody"' in n, "Nobody: the generated ProblemDetail reads type, title, status, detail, instance; the wire's name member lands nowhere (properties {})")
    h = "\n".join(B[2])
    need(re.search(r"factory org\.springframework\.http\.client\.HttpComponentsClientHttpRequestFactory$", B[2][0]) is not None and re.search(r"^  CLIENT one\(Ravi\) -> 200 ", h, re.M) is not None,
         "HttpClient 5 on the runner's class path: HttpComponentsClientHttpRequestFactory, 200 (measured, not shipped)")
    acc2 = re.findall(r"^  the access log's line for it: (GET /api/v1/customers/Ravi\S* .*)$", t, re.M)
    need(len(acc2) == 2, "the access log names both requests' User-Agent")
    need(re.search(r"ResourceAccessException|ConnectException", "\n".join(B[3])) is not None and re.search(r"^  the runner's exit: [1-9]", "\n".join(B[3]), re.M) is not None, "plant: nothing listening -> the call fails (ResourceAccessException), exit non-zero")
    need(grab(r"^  the stub's members against the wire's \(curl's body on after/\): (\w+)", t) == "DIFFERENT", "plant: the stub's wrong body -> the members check says DIFFERENT (it FAILS)")
    val("call_status", r.group(1) if r else "-"); val("factory", "JdkClientHttpRequestFactory"); val("factory_hc5", "HttpComponentsClientHttpRequestFactory")
    val("ua", (ua or "-").replace(" ", "_")); val("ua_hc5", (grab(r"ua=(\S+)", acc2[1]) if len(acc2) > 1 else "-")); val("call_ct", r.group(2) if r else "-")
def c_pause(p):
    t = rd(p)
    sg = grab(r"^  CLIENT signature (.*)$", t)
    need(sg is not None and sg.endswith("ApiApi.add1(java.lang.String,java.lang.Integer)"), "the generated pause method: add1(String name, Integer days) - no key parameter")
    i = re.search(r"^  the whole generated root: lines naming idempotency \(grep -c -i\): (\d+) · of them in comment lines \(\^ \*\\\*\): (\d+) · @RequestHeader: (\d+) \(([^)]*)\) · naming the key header: (\d+)$", t, re.M)
    need(i is not None and i.group(1) == i.group(2) and i.group(5) == "0", "the generated root: every line naming idempotency is a comment line (%s of %s); @RequestHeader %s (%s), naming the key header 0" % (i.group(2), i.group(1), i.group(3), i.group(4)) if i else "the idempotency line")
    sp = grab(r"^  the spec's pause POST: parameters (\S+) · header parameters (\d+)", t, 2)
    need(sp == "0", "the spec's pause POST: header parameters 0")
    blk = blocks(t)
    need(len(blk) == 3, "three runs of the runner: the call, the companion's call, the keyed alternative")
    if len(blk) < 3: done()
    a = "\n".join(blk[0])
    need(re.search(r"^  CLIENT thrown org\.springframework\.web\.client\.HttpClientErrorException\$BadRequest status 400 application/problem\+json$", a, re.M) is not None, "the call: HttpClientErrorException.BadRequest, 400, application/problem+json")
    ex = grab(r"^  the wire's body against the spec's key-missing example \(python, key for key and value\): (EQUAL to \S+|DIFFERENT)", t)
    need(ex is not None and ex.startswith("EQUAL to "), "the wire's body = the spec's %s example, key for key and value" % (ex or "-")[9:])
    need(re.search(r"^  CLIENT user-agent ", a, re.M) is not None, "the runner prints the User-Agent its interceptor saw")
    k0 = re.search(r"^  before: keys (\d+) .* customers (\d+) ", t, re.M); k1 = re.search(r"^  after the refused call: keys (\d+) .* customers (\d+) ", t, re.M)
    need(k0 is not None and k1 is not None and k0.group(1) == k1.group(1) == "0" and k0.group(2) == k1.group(2), "the key table: 0 before and after the refused call; the customers unchanged")
    kd = "\n".join(blk[2]); k2 = re.search(r"^  after the keyed call: keys (\d+) ", t, re.M)
    need(re.search(r"^  CLIENT add1\(Ravi, 2\) -> 201 Location ", kd, re.M) is not None and k2 is not None and k2.group(1) == "1", "the printed alternative: a default header on the builder -> 201, the key table 1 (not shipped, not a test)")
    val("pause_status", "400"); val("idem_comment_lines", i.group(2) if i else "-"); val("request_header", i.group(3) if i else "-"); val("key_header_params", i.group(5) if i else "-"); val("example", (ex or "-").replace("EQUAL to ", "")); val("keyed", "201")
def c_mock(p):
    t = rd(p)
    need(re.search(r"^  TiffinBoxClientTest tests 1 failures 0 errors 0 skipped 0$", t, re.M) is not None, "the package run: TiffinBoxClientTest 1 test, 0 failures, 0 skipped")
    mm = grab(r"^  package: CLIENT mock interface com\.tiffinbox\.client\.api\.ApiApi classfile-md5 (\w+)$", t); cm = grab(r"^  the call capture's interface line: CLIENT interface com\.tiffinbox\.client\.api\.ApiApi classfile-md5 (\w+)$", t)
    jm = grab(r"^  the jar's ApiApi\.class: md5 (\w+)$", t)
    need(mm is not None and mm == cm == jm, "the same generated interface, byte for byte: the mock test's, the real call's and the jar's ApiApi.class md5 equal (%s)" % (mm or "-")[:8])
    need(re.search(r"^  package: CLIENT mock factory org\.springframework\.test\.web\.client\.MockRestServiceServer\$MockClientHttpRequestFactory$", t, re.M) is not None, "the mock's factory: MockRestServiceServer$MockClientHttpRequestFactory")
    need(re.search(r"^  package: CLIENT mock verify\(\) passed · one\(Ravi\) -> 200 ", t, re.M) is not None, "verify() passed, one(Ravi) -> 200")
    pl = re.findall(r"^  mvn test exit (\d+) · TiffinBoxClientTest tests 1 failures (\d+) errors (\d+) skipped \d+$", t, re.M)
    need(len(pl) == 3 and pl[0][0] != "0" and pl[1][0] != "0" and pl[2] == ("0", "0", "0"), "the plants: the wrong path FAILS, the unmet expectation with verify() FAILS, the same with verify() removed PASSES (%s)" % pl)
    val("mock_md5", (mm or "-")[:8]); val("verify", "passed"); val("noverify_plant", "passes")
def c_default(p):
    t = rd(p)
    need(re.search(r"^  mvn -o clean package -pl tiffinbox-client -am exit 0 · Downloading/Downloaded from: 0$", t, re.M) is not None, "the loser builds offline on its scratch mirror")
    w = grab(r"^  the compile's removal warnings \(grep -c 'marked for removal'\): (\d+)$", t)
    need(w is not None and int(w) > 0 and len(re.findall(r"^  removal \| ", t, re.M)) == int(w), "the loser's removal warnings: %s, each printed" % w)
    im = dict(re.findall(r"^  the loser's imports '([^']+)': (\d+)$", t, re.M))
    need(int(im.get("import com.fasterxml.jackson.databind", "0")) > 0, "the loser imports Jackson 2's databind (%s lines)" % im.get("import com.fasterxml.jackson.databind"))
    need(re.search(r"^  \d+ lines name the restclient library, jackson-databind-nullable or generatorName java$", t, re.M) is not None and re.search(r"^  0 lines name", t, re.M) is not None, "the anchor's poms: 0")
    val("warnings", w); val("loser_databind_imports", im.get("import com.fasterxml.jackson.databind", "-"))
def c_counts(p):
    t = rd(p)
    R = re.findall(r"^  (\S+): (\d+) files, (\d+) lines \(non-blank, comment-only dropped, imports kept\)$", t, re.M)
    need(len(R) == 3, "loc9.py printed three counted roots")
    need(re.search(r"^  work/emptyroot: 0 \.java files - refused$", t, re.M) is not None and re.search(r"^ +loc9\.py exit 2$", t, re.M) is not None, "the empty root refused, exit 2")
    per = {}; cur = None
    for l in t.splitlines():
        m = re.match(r"^  (\S+): \d+ files, \d+ lines ", l)
        if m: cur = m.group(1); per[cur] = []; continue
        m = re.match(r"^ {6,}(\d+)  \S+$", l)
        if m and cur: per[cur].append(int(m.group(1))); continue
        if not l.startswith("   "): cur = None
    for r, f, l in R:
        need(len(per.get(r, [])) == int(f) and sum(per.get(r, [])) == int(l), "%s: %s files, %s lines = its per-file lines" % (r, f, l))
    pl = grab(r"^  plant: \S+: (\d+) files, (\d+) lines", t, 2)
    need(pl is not None and R and pl != R[0][2], "plant: one level too deep -> the lines move (%s != %s)" % (pl, R[0][2] if R else "-"))
    if len(R) == 3:
        val("gen_files", R[0][1]); val("gen_lines", R[0][2]); val("loser_files", R[1][1]); val("loser_lines", R[1][2]); val("web_files", R[2][1]); val("web_lines", R[2][2])
def c_location(p):
    t = rd(p)
    rt = re.search(r"^  create: ResponseEntity<(.*?)> add\(.* · pause: ResponseEntity<(.*?)> add1\(", t, re.M)
    need(rt is not None, "the return types: create %s, pause %s" % (rt.groups() if rt else ("-", "-")))
    c = grab(r"^  CLIENT add\(Gen10\) -> (\d+) Location (\S+)$", t, 0)
    cr = re.search(r"^  CLIENT add\(Gen10\) -> (\d+) Location (\S+)$", t, re.M)
    cu = re.search(r"^-- loc-curl \| POST /customers -> (\d+) ", t, re.M)
    need(cr is not None and cu is not None and cr.group(1) == cu.group(1), "the generated create and curl's: the same status (%s / %s)" % (cr.group(1) if cr else "-", cu.group(1) if cu else "-"))
    cb = re.search(r"^  customers before: (\d+) ", t, re.M); ca = re.search(r"^  customers after: (\d+) ", t, re.M)
    need(cb is not None and ca is not None and int(ca.group(1)) == int(cb.group(1)) + 2, "the second client: two customers more (Gen10, Curl10)")
    val("create_status", cr.group(1) if cr else "-"); val("create_location", "present" if cr and cr.group(2) != "null" else "null")
def c_diff(p):
    t = rd(p)
    ka = re.search(r"^  \(a\) KINDS (\d+) .*?ROWS (\d+)", t, re.M) or re.search(r"^  \(a\) KINDS:? (\d+).*$", t, re.M)
    print("  (diff's KINDS lines:) %s" % " | ".join(re.findall(r"^  \((?:a|b)\) KINDS.*$", t, re.M)))
    a = re.search(r"^  \(a\) exit (\d+)$", t, re.M); b = re.search(r"^  \(b\) exit (\d+)$", t, re.M)
    need(a is not None and b is not None, "diff (a) and (b) ran")
    e = re.search(r"^  empty wire: exit (\d+)$", t, re.M)
    need(e is not None and e.group(1) == "2", "the empty wire folder refused (exit 2)")
    kk = {}
    for side in ("a", "b"):
        m = re.search(r"^  \(%s\) KINDS (\d+)" % side, t, re.M); r = re.search(r"^  \(%s\) DISAGREEMENTS (\d+)" % side, t, re.M)
        kk[side] = (m.group(1) if m else "-", r.group(1) if r else "-")
    need(kk["a"][0] != "-" and kk["b"][0] != "-", "kinds / rows: (a) %s / %s · (b) %s / %s" % (kk["a"] + kk["b"]))
    val("kinds_a", kk["a"][0]); val("rows_a", kk["a"][1]); val("kinds_b", kk["b"][0]); val("rows_b", kk["b"][1])
def c_moved(p):
    t = rd(p)
    R = {}
    for m in re.finditer(r"^  (before|after) \| (.*?) -> (.*)$", t, re.M): R.setdefault(m.group(2), {})[m.group(1)] = m.group(3)
    mv = [k for k, v in R.items() if v.get("before") != v.get("after")]
    need(len(R) == 19 and not mv, "U09's nineteen requests: %d, moved %d (%s)" % (len(R), len(mv), ",".join(mv) or "none"))
    jm = re.search(r"^  web jar md5: before (\w+) · after (\w+)$", t, re.M); en = grab(r"^  entries whose CRC moved before -> after: (\d+)$", t)
    need(jm is not None and en is not None, "the web jar's md5 before and after printed (%s), entries moved %s" % ("equal" if jm and jm.group(1) == jm.group(2) else "different", en))
    val("requests", len(R)); val("moved", len(mv)); val("jar", "equal" if jm and jm.group(1) == jm.group(2) else "entries_%s" % en)
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
    m = re.search(r"wire-h2: requests (\d+) · with the key: (\S+)$", t, re.M)
    need(m is not None and m.group(2) == "pause-key", "wire-h2: the key header on pause-key alone")
    s = re.findall(r"^  \.r-(\w+)\.new: sent the key: (\d+) · did not: (\d+)$", t, re.M)
    need(s and all(x[1] == "0" for x in s), "curl sent the key header 0 times in %s" % ",".join(x[0] for x in s))
    k = grab(r"^  the runner's requests with the key \(its keyed mode, the printed alternative\): (\d+) in pause", t)
    need(k == "1", "the runner sent the key once (the keyed alternative)")
def c_exercise(p):
    t = rd(p)
    runs = re.split(r"^== the exercise, h2, ", t, flags=re.M)[1:]
    R = {}
    for r in runs:
        h = r.split(" ", 1)[0].rstrip(","); sh = r.split(", ", 1)[1].split(" ", 1)[0]
        res = "PASS" if re.search(r"^  PASS:", r, re.M) else (grab(r"^  FAIL \((clause \d)\)", r) or "FAIL")
        R[(h, sh)] = (res, grab(r"^  check exit (\d+)$", r), grab(r"^  the generated call: (\d+) ", r))
    print("  exercise runs: %s" % " · ".join("%s/%s %s (call %s)" % (k[0], k[1], v[0], v[2]) for k, v in R.items()))
    need(R.get(("broken", "bash"), ("",))[0] == "clause 1" and R.get(("broken", "zsh"), ("",))[0] == "clause 1", "broken: FAILS clause 1 under bash and zsh -f")
    need(R.get(("broken", "bash"), ("", "", ""))[2] == "404", "broken: the generated call answers 404 (measured)")
    need(R.get(("solved", "bash"), ("",))[0] == "PASS" and R.get(("solved", "zsh"), ("",))[0] == "PASS" and R.get(("solved", "bash"), ("", "", ""))[2] == "200", "solved: PASS under bash and zsh -f, the generated call 200")
    need(R.get(("none", "bash"), ("",))[0] == "clause 1" and R.get(("genedit", "bash"), ("",))[0] == "clause 1" and R.get(("movedserver", "bash"), ("",))[0] == "clause 1" and R.get(("movedserver", "bash"), ("", "", ""))[2] == "200",
         "the refused variants: none (clause 1), genedit (clause 1: clean generates it again), movedserver (clause 1: the call answers two hundred at the moved mapping, but the served document's operation one is now another route)")
    val("broken", "404"); val("solved", "200"); val("variants", len([k for k in R if k[0] not in ("broken", "solved")]))

CAPS = {"tests": c_tests, "census": c_census, "modules": c_modules, "generate": c_generate, "jackson": c_jackson, "committed": c_committed, "call": c_call,
        "pause": c_pause, "mock": c_mock, "default": c_default, "counts": c_counts, "location": c_location, "diff": c_diff, "moved": c_moved,
        "seven": c_seven, "surface": c_surface, "inert": c_inert, "exercise": c_exercise}
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
        l = re.sub(r"(\"(?:id|version|ts)\":)\d+", r"\1<n>", l) if nm == "diff" and l.startswith("  pair ") else l
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
             "spoken": lambda: spoken(a[1], a[2]), "surefire": lambda: surefire(a[1]), "mapjson": lambda: mapjson(a[1], sys.stdin), "opsmap": lambda: ops(a[1], a[2]),
             "hashable": lambda: hashable(a[1], a[2]), "values": lambda: values(a[1], a[2]), "genmask": lambda: genmask(a[1]), "genmd5": lambda: genmd5(a[1]),
             "panel": lambda: panel(a[1], a[2]), "gendiff": lambda: gendiff(a[1], a[2], a[3]), "genops": lambda: genops(a[1], a[2]), "members": lambda: members(a[1], a[2]),
             "example": lambda: example(a[1], a[2]), "specop": lambda: specop(a[1], a[2], a[3]), "modtable": lambda: modules(a[1], a[2], a[3])}
        if a and a[0] in M: M[a[0]]()
        elif a: capture(a[0], a[1])
        else: print(__doc__); sys.exit(2)
    except SystemExit:
        raise
    except Exception as e:
        print("FAIL the checker could not read its input (%s: %s) - a FAIL line, never a traceback" % (e.__class__.__name__, str(e)[:120])); sys.exit(1)
