"""Course 9 unit 04's checker (python3 -I -B harness/chk04.py MODE ...). Every number the README may say is re-derived here from a capture's
own lines, never typed. Each listing line a check reads is parsed by a named pattern or skipped by a named rule; a line it cannot parse is
a FAIL line and exit 1, never a traceback. Modes:
  static AFTER BEFORE        the anchor's static facts: the five ITs' bindings, the version step, the new files, the stale sentences (R.250)
  <capture> FILE             one capture's checks; prints ok/FAIL lines and one VALUES line
  hashable NAME FILE         the capture with its load-dependent counts masked (the 409s counted while a retry polls), for receipts.md5
  values README VALS         README.md's values block = this run's VALUES lines
  prob / pauses / keyrow / ck / ttl / surefire / bom / mappings   the receipts' small readers"""
import hashlib, json, os, re, sys, xml.etree.ElementTree as ET

OK, BAD, VAL = [], [], []
def ok(m): OK.append(m); print("ok " + m)
def fail(m): BAD.append(m); print("FAIL " + m)
def need(cond, m): ok(m) if cond else fail(m)
def val(k, v): VAL.append("%s=%s" % (k, v))
def done():
    print("VALUES " + " ".join(VAL))
    sys.exit(1 if BAD else 0)

def lines(p):
    return open(p, encoding="utf-8", errors="replace").read().splitlines()

def grab(ls, rx, name, group=1, all_=False):
    """The value of a named pattern on the first (or every) matching line; a missing line is a FAIL, never a traceback."""
    out = [m.group(group) for l in ls for m in [re.search(rx, l)] if m]
    if not out:
        fail("%s: no line matches %r" % (name, rx)); return [] if all_ else None
    return out if all_ else out[0]

# ---- the small readers ------------------------------------------------------------------------------------------------------------------
def prob(p):
    raw = open(p, "rb").read()
    try:
        d = json.loads(raw)
    except Exception as e:
        print("NOT JSON (%s)" % e.__class__.__name__); return
    if not isinstance(d, dict):
        print("valid JSON, not an object"); return
    print("valid JSON · type %s · title %r · status %s · detail %r" % (d.get("type", "(absent = about:blank)"), d.get("title"), d.get("status"), str(d.get("detail"))[:110]))

def lower(d): return {k.lower(): v for k, v in d.items()}

IT = {"CustomerEntityRepositoryIT": ("tiffinbox-web/src/test/java/com/tiffinbox/CustomerEntityRepositoryIT.java", 21280, 5432),
      "CustomerAggregatesIT": ("tiffinbox-web/src/test/java/com/tiffinbox/jdbc/CustomerAggregatesIT.java", 21281, 5432),
      "RedisDatastoreIT": ("tiffinbox-web/src/test/java/com/tiffinbox/web/RedisDatastoreIT.java", 21282, 6379),
      "MongoDatastoreIT": ("tiffinbox-web/src/test/java/com/tiffinbox/web/MongoDatastoreIT.java", 21283, 27017),
      "ElasticsearchIT": ("tiffinbox-web/src/test/java/com/tiffinbox/web/ElasticsearchIT.java", 21284, 9200)}
NEW = ["tiffinbox-core/src/main/resources/db/migration/V5__idempotency_key.sql"] + ["tiffinbox-web/src/main/java/com/tiffinbox/web/%s.java" % c for c in
       ("IdempotencyKeyFilter", "IdempotencyKeys", "TransactionAwareCaching", "CustomerPauses", "Pauses")] + \
      ["tiffinbox-web/src/test/java/com/tiffinbox/web/IdempotencyKeyTest.java", "tiffinbox-web/src/test/java/com/tiffinbox/web/TransactionAwareCachingTest.java"]
STALE = re.compile(r"4\.1\.2|11\.0\.27|\b20578\b|\b20615\b|V1-V4|bindIp\(")

def code(text):
    """The Java/XML/YAML lines that are not comments (the binding is code; a dated history sentence is a comment)."""
    out = []
    for l in text.splitlines():
        t = l.strip()
        if t.startswith(("*", "//", "/*", "#", "<!--", "--")): continue
        out.append(l)
    return "\n".join(out)

def static(after, before):
    files = []
    for d, ds, fs in os.walk(after):
        ds.sort()
        for f in sorted(fs): files.append(os.path.relpath(os.path.join(d, f), after))
    bfiles = []
    for d, ds, fs in os.walk(before):
        for f in fs: bfiles.append(os.path.relpath(os.path.join(d, f), before))
    added = sorted(set(files) - set(bfiles)); removed = sorted(set(bfiles) - set(files))
    need(added == sorted(NEW), "the files after/ adds to before/: %d, the brief's list (V5, the five web classes, the two test classes)" % len(added))
    need(not removed, "the files after/ removes: %d" % len(removed))
    val("files_before", len(bfiles)); val("files_after", len(files)); val("files_added", len(added))
    changed = sorted(f for f in set(files) & set(bfiles) if open(os.path.join(after, f), "rb").read() != open(os.path.join(before, f), "rb").read())
    print("  changed files: " + " ".join(changed))
    val("files_changed", len(changed))
    pom = open(os.path.join(after, "pom.xml")).read()
    need(re.search(r"<artifactId>spring-boot-starter-parent</artifactId>\s*<!--(?:.|\n)*?-->\s*<version>4\.1\.3</version>|<artifactId>spring-boot-starter-parent</artifactId>[^<]*(?:<!--(?:.|\n)*?-->\s*)*<version>4\.1\.3</version>", pom) is not None, "the parent is 4.1.3")
    need(pom.count("<tomcat.version>11.0.29</tomcat.version>") == 1, "<tomcat.version>11.0.29</tomcat.version>, once")
    need("<h2.version>2.5.250</h2.version>" in pom, "h2.version 2.5.250 untouched")
    for c, (f, port, inner) in IT.items():
        t = open(os.path.join(after, f)).read(); k = code(t)
        b = re.findall(r'Ports\.Binding\.bindIpAndPort\("([0-9.]+)", (\d+)\), new ExposedPort\((\d+)\)', k)
        need(b == [("127.0.0.1", str(port), str(inner))], "%s binds %s -> 127.0.0.1:%d, once, by bindIpAndPort (found %s)" % (c, inner, port, b))
        need(not re.search(r"bindIp\(|\b20578\b|\b20615\b", k), "%s: no bindIp( form, no Course 8 port in its code" % c)
        need(('System.out.println("IT BINDINGS %s " + out);' % c) in k, "%s prints its own IT BINDINGS line" % c)
    for f in files:
        if f == "README.md" or not f.endswith((".java", ".xml", ".yaml", ".sql")): continue
        t = open(os.path.join(after, f)).read()
        if STALE.search(t) and "Course 9, unit 04" not in t:
            fail("R.250: %s still says %r with no Course 9, unit 04 note" % (f, STALE.search(t).group(0)))
    ok("R.250: every non-README file of after/ that names 4.1.2, 11.0.27, 20578, 20615, V1-V4 or bindIp( carries a Course 9, unit 04 note")
    main = "".join(open(os.path.join(after, f)).read() for f in files if "/src/main/" in f and f.endswith(".java"))
    need("probe." not in code(main) and "X-Probe" not in main, "src/main holds no harness class and no X-Probe header")
    need(re.search(r"static final int ORDER = -90;", open(os.path.join(after, NEW[2])).read()) is not None, "IdempotencyKeys.ORDER = -90")
    here = os.path.dirname(os.path.abspath(__file__))
    s9 = open(os.path.join(here, "s904.py"), encoding="utf-8").read().split("\n"); s8 = open(os.path.join(here, "..", "..", "c8-unit27", "harness", "s827.py"), encoding="utf-8").read().split("\n")
    md = lambda x: hashlib.md5("\n".join(x).encode()).hexdigest()
    need(s9[9:403] == s8[9:403], "s904.py's lines 10-403 = s827.py's lines 10-403 (the family base), md5 %s" % md(s8[9:403]))
    i = s9.index(s8[408]) if s8[408] in s9 else -1
    need(i > 403 and s9[i:i + 116] == s8[408:524], "s904.py's XFAM_S5 + TIMEPAT_S5 slice = s827.py's lines 409-524, md5 %s" % md(s8[408:524]))
    t9 = "\n".join(s9)
    need(not re.search(r"^(?:XEXEMPT_S5|XU25|XU26|XU27) = ", t9, re.M), "no XEXEMPT_S5, no XU25-XU27 defined")
    pin = re.search(r'^XFAM5B_SLICE_MD5 = "([0-9a-f]{32})"', open(os.path.join(here, "..", "..", "c8-unit25", "harness", "chk25.py")).read(), re.M)
    need(pin is not None and pin.group(1) == md(s8[408:524]), "the XFAM_S5 slice = the md5 ../c8-unit25/harness/chk25.py pins (XFAM5B_SLICE_MD5, read off it)")
    blk = re.search(r"# --- XFAM_S9S1 begin ---\n.*?# --- XFAM_S9S1 end ---", t9, re.S)
    need(blk is not None, "the XFAM_S9S1 block, delimited")
    if blk: print("  XFAM_S9S1_SLICE_MD5 = %s (units 01-03, 05, 06 carry this block byte for byte)" % hashlib.md5(blk.group(0).encode()).hexdigest()); val("xfam_s9s1_md5", hashlib.md5(blk.group(0).encode()).hexdigest()[:8])
    rd = open(os.path.join(after, "README.md")).read()
    need("## Course 9 · unit 04" in rd, "the anchor's README carries the unit 04 card")
    ik = open(os.path.join(after, NEW[2])).read().splitlines()
    for prop, n in re.findall(r"(tiffinbox\.idempotency\.[a-z0-9-]+) +default on line (\d+) of IdempotencyKeys\.java", rd):
        need(prop in ik[int(n) - 1] and "Duration.ofSeconds(" in ik[int(n) - 1], "the card: %s's default is on line %s of IdempotencyKeys.java" % (prop, n))
    done()

def surefire(p):
    r = ET.parse(p).getroot()
    print("  %s tests %s failures %s errors %s skipped %s" % (r.get("name").split(".")[-1], r.get("tests"), r.get("failures"), r.get("errors"), r.get("skipped")))

def bom(a, b):
    def props(p):
        t = ET.parse(p).getroot(); ns = {"m": "http://maven.apache.org/POM/4.0.0"}
        pr = t.find("m:properties", ns)
        return {e.tag.split("}")[1]: (e.text or "") for e in pr}
    x, y = props(a), props(b)
    vx = {k: v for k, v in x.items() if k.endswith(".version")}; vy = {k: v for k, v in y.items() if k.endswith(".version")}
    moved = sorted(k for k in vx if k in vy and vx[k] != vy[k])
    print("  version properties: 4.1.2 %d · 4.1.3 %d · added %d · removed %d · moved %d" % (len(vx), len(vy), len(set(vy) - set(vx)), len(set(vx) - set(vy)), len(moved)))
    for k in moved: print("    %s %s -> %s" % (k, vx[k], vy[k]))

def mappings(stdin):
    d = json.load(stdin); hm = []
    for ctx in d["contexts"].values():
        for ds in ctx["mappings"].get("dispatcherServlets", {}).values():
            for m in ds:
                h = (m.get("details") or {}).get("handlerMethod")
                if h: hm.append((h["className"], h["name"], m["predicate"]))
    tb = [x for x in hm if x[0].startswith("com.tiffinbox.")]
    u04 = [x for x in tb if x[0].endswith("CustomerPauses")]
    print("  handler methods: %d · TiffinBox's (com.tiffinbox.*) %d · unit 04's (CustomerPauses) %d · the set-up's (TiffinBox's minus unit 04's) %d · others %d" % (len(hm), len(tb), len(u04), len(tb) - len(u04), len(hm) - len(tb)))
    for x in sorted(u04): print("    %s#%s %s" % (x[0].split(".")[-1], x[1], x[2]))

# ---- the captures -----------------------------------------------------------------------------------------------------------------------
TESTS_RX = r"^  (\w+) tests (\d+) failures (\d+) errors (\d+) skipped (\d+)$"

def c_tests(ls):
    sec = None; per = {}
    for l in ls:
        m = re.match(r"^== (before|mid|after): mvn -o clean package", l)
        if m: sec = m.group(1); per[sec] = {}; continue
        if l.startswith("== mvn -o verify"): sec = "it"; per[sec] = {}; continue
        if l.startswith("== "): sec = None; continue
        m = re.match(TESTS_RX, l)
        if m and sec:
            per[sec][m.group(1)] = int(m.group(2)); need(m.group(3) == m.group(4) == "0", "%s %s: failures and errors 0" % (sec, m.group(1)))
    for s in ("before", "mid", "after", "it"):
        if s not in per: fail("no %s section" % s); continue
    if BAD: return
    for s in ("before", "mid", "after"): val("tests_" + s, sum(per[s].values()))
    need(sum(per["before"].values()) == sum(per["mid"].values()), "the version step alone keeps the test count (before = mid)")
    base = sum(per["before"].values()); k = sum(per["after"].values()) - base
    need(k > 0, "after/ adds tests: %d + %d" % (base, k)); val("tests_k", k); val("its", sum(per["it"].values()))
    need(len(per["it"]) == 5, "five IT classes ran at verify"); need(per["it"].get("MongoDatastoreIT") == 4, "MongoDatastoreIT 4")
    b = [re.match(r"^  IT BINDINGS (\w+) \[(.*)\]$", l) for l in ls if l.startswith("  IT BINDINGS ")]
    if any(x is None for x in b): fail("an IT BINDINGS line this checker cannot parse")
    b = [x for x in b if x]
    entries = [(x.group(1), e) for x in b for e in x.group(2).split(", ")]
    off = [e for c, e in entries if not re.search(r"-> 127\.0\.0\.1:\d+$", e)]
    need(len({c for c, e in entries}) == 5, "IT BINDINGS: classes 5 (found %d)" % len({c for c, e in entries}))
    need(not off, "IT BINDINGS: entries %d · not 127.0.0.1: %d" % (len(entries), len(off)))
    for c, (f, port, inner) in IT.items():
        need("%s/tcp -> 127.0.0.1:%d" % (inner, port) in [e for cc, e in entries if cc == c], "%s on 127.0.0.1:%d" % (c, port))
    val("it_entries", len(entries))
    need(grab(ls, r"mvn verify exit (\d+)", "verify exit") == "0", "mvn verify exit 0")
    need(grab(ls, r"^== mvn -o dependency:list.*\n?", "deps", 0) is not None and any(re.match(r"^  exit 0 · \d+ runtime entries", l) for l in ls), "mvn -o dependency:list: exit 0")
    need(not any("TIMED OUT" in l for l in ls), "no IT wait timed out")
    libs = grab(ls, r"^  BOOT-INF/lib: (\d+) jars", "lib", all_=True)
    if libs and len(libs) == 3: val("lib_before", libs[0]); val("lib_mid", libs[1]); val("lib_after", libs[2])
    mv = grab(ls, r"moved (\d+)$", "bom moved")
    tot = grab(ls, r"version properties: 4\.1\.2 (\d+)", "bom total")
    if mv: val("bom_moved", mv); val("bom_total", tot)
    need(grab(ls, r"added (\d+) · removed (\d+)", "bom added", 1) == "0", "the BOM adds no version property")
    after_lib = [l for l in ls if l.startswith("  BOOT-INF/lib:")][-1] if libs else ""
    for j in ("tomcat-embed-core-11.0.29.jar", "tomcat-embed-el-11.0.29.jar", "tomcat-embed-websocket-11.0.29.jar", "netty-common-4.2.20.Final.jar", "spring-core-7.0.11.jar", "spring-boot-4.1.3.jar"):
        need(j in after_lib, "after/'s BOOT-INF/lib holds " + j)
    h = re.search(r"TiffinBox's \(com\.tiffinbox\.\*\) (\d+) · unit 04's \(CustomerPauses\) (\d+) · the set-up's \(TiffinBox's minus unit 04's\) (\d+)", "\n".join(ls))
    if not h: fail("the handler-method line")
    else: val("handlers_total", h.group(1)); val("handlers_u04", h.group(2)); val("handlers_setup", h.group(3))
    need(any("Apache Tomcat/11.0.29" in l for l in ls), "the JVM's Tomcat line: 11.0.29")
    need(any(re.search(r'Successfully applied 5 migrations .*now at version v5', l) for l in ls), "Flyway: 5 migrations, v5")

def c_bill(ls):
    need(any("paid after 3 attempts" in l for l in ls), "the bill: paid after 3 attempts (read off ../c4-unit30)")
    need(any("charged 1020 for one order" in l for l in ls), "the bill: charged 1020 for one order")
    need(any("20100704612ca5c86f3b6ac20f3fd61b" in l for l in ls), "the README's md5 line of the bill")
    a = grab(ls, r"paid after (\d+) attempts", "attempts"); c = grab(ls, r"charged (\d+) for one order", "charged")
    val("bill_attempts", a); val("bill_charged", c)

def st(l):
    m = re.search(r" -> (\d{3}) ", l); return m.group(1) if m else None

def c_twice(ls, db):
    t1 = grab(ls, r"try 1: .* -> (\d{3}) .*· rows (\d+)", "try 1"); t2l = [l for l in ls if l.startswith("  try 2:")]
    need(t1 == "201", "try 1: 201")
    need(t2l and st(t2l[0]) == "409", "try 2: 409")
    need(t2l and "type (absent = about:blank)" in t2l[0], "the route's 409: no type (about:blank)")
    need(grab(ls, r"try 2: .*· rows (\d+)", "rows") == "1", "rows 1 after the second try")
    need(grab(ls, r"fresh name: .* -> (\d{3})", "negation") == "201", "R.312: a fresh name -> 201")
    val("twice_" + db, "201/409")

def c_pause(ls, db):
    pd = [grab(ls, r"pausedDays (\d+)", "start")] + [grab(ls, r"try %d: .*pausedDays (\d+)" % i, "try %d" % i) for i in (1, 2)]
    sts = [grab(ls, r"try %d: .* -> (\d{3})" % i, "status") for i in (1, 2)]
    need(sts == ["200", "200"], "the harness's route answers 200 twice, no exception")
    need(None not in pd and int(pd[1]) - int(pd[0]) == 2 and int(pd[2]) - int(pd[1]) == 2, "paused days +2, +2: the pause counted twice")
    val("pause_" + db, "->".join(str(x) for x in pd))

def c_key(ls, db):
    need(grab(ls, r"\(i\) no key: .* -> (\d{3})", "no key") == "400", "(i) no key: 400")
    need(any("idempotency-key-missing" in l for l in ls if "(i) no key" in l), "(i) type ...-missing")
    p0 = grab(ls, r"\(i\) no key: .*pausedDays (\d+)", "p0")
    need(grab(ls, r"try 1: .* -> (\d{3})", "t1") == "201", "(ii) try 1: 201")
    need(any(re.search(r"try 1: .*Location: http://127\.0\.0\.1:<port>/api/v1/customers/Sunil/pauses/\d+", l) for l in ls), "(ii) try 1 carries Location .../pauses/<id>")
    p1 = grab(ls, r"try 1: .*pausedDays (\d+)", "p1")
    need(grab(ls, r"try 2: .* -> (\d{3})", "t2") == "201", "(ii) try 2: 201")
    need(any("try 2:" in l and "cmp: byte-identical" in l for l in ls), "(ii) try 2 byte-identical (cmp)")
    w = grab(ls, r"the request witness: PROBE-REQ .* -> 201 \| handler (\S+) .*statements (\d+) \(writes (\d+)", "witness", 0)
    if w:
        m = re.search(r"handler (\S+) .*statements (\d+) \(writes (\d+)", w)
        need(m.group(1) == "none", "the replay: handler none (the route not run)"); val("replay_statements_" + db, m.group(2)); val("replay_writes_" + db, m.group(3))
    p2 = grab(ls, r"^    pausedDays (\d+)", "p2")
    if None not in (p0, p1, p2):
        need(int(p1) - int(p0) == 2 and p2 == p1, "paused days +2 once: %s -> %s -> %s" % (p0, p1, p2)); val("key_" + db, "%s->%s->%s" % (p0, p1, p2))
    need(any(re.search(r'GET its Location: .* -> 200 .*\{"id":\d+,"customer":"Sunil","days":2\}', l) for l in ls), "GET the Location: 200 {id, Sunil, 2}")
    need(any("key row a-1: status 201 claimed false" in l for l in ls), "the key row: status 201, claim token NULL")
    need(any("(iii) POST /customers JSON, key j-1" in l and "cmp: byte-identical" in l and "rows 1" in l for l in ls), "(iii) POST /customers with a key twice: 201, 201 byte-identical, rows 1")
    need(any("(iii) POST /customers JSON, no key (inert)" in l and " -> 201 " in l for l in ls), "(iii) no key: 201 (inert)")
    fm = [l for l in ls if "(iv) the form" in l]
    need(fm and " -> 302 " in fm[0] and "rows 1" in fm[0] and "key row f-1: no row" in fm[0], "(iv) the form with a key: 302, rows 1, no key row")
    jp = [l for l in ls if "(iv) application/json-patch+json" in l]
    need(jp and " -> 201 " in jp[0] and "key row jp-1: status 201" in jp[0], "(iv) json-patch+json with a key: 201, key row 201")
    four = grab(ls, r"a replay carries only these: (.*) \(and the body\)", "four")
    need(four == "HTTP/1.1 Location Content-Type Content-Length", "a replay carries: status, Location, Content-Type (+ its length) and the body")
    if db == "pg": need(any(l.startswith("      pg: ") for l in ls), "PostgreSQL's log_statement saw the replay's statements")

def c_mismatch(ls, db):
    need(any(" -> 422 " in l and "idempotency-key-reused" in l for l in ls), "another query under a stored key: 422 ...-reused")
    val("mismatch_" + db, grab(ls, r"pausedDays (\d+)", "pd"))

def c_error(ls, db):
    p = [l for l in ls if l.startswith("  planted:")]
    need(p and " -> 500 " in p[0] and "Location" not in p[0] and "rows 0" in p[0] and "key row pl-1: no row" in p[0], "the planted failure: 500, no Location, rows 0, no key row")
    rt = [l for l in ls if l.startswith("  its retry")]
    need(rt and " -> 201 " in rt[0] and "rows 1" in rt[0] and "status 201" in rt[0], "its retry: 201, rows 1, key row 201 (the freed key runs again)")

def c_race(ls, db):
    d = [l for l in ls if "the duplicate" in l and "while the first is held" in l]
    need(d and all(" -> 409 " in l and "idempotency-key-outstanding" in l for l in d), "every duplicate while the first is held: 409 ...-outstanding (%d)" % len(d))
    need(any(l.startswith("  the first, released: 201") for l in ls), "the first, released: 201")
    need(any("the retry after it" in l and "cmp: byte-identical" in l for l in ls), "the retry after it: byte-identical")
    if db == "pg": need(len(d) == 2, "PostgreSQL: the duplicate on both JVMs"); need(grab(ls, r"pg_locks not granted while held: (\d+)", "locks") == "0", "pg_locks not granted while held: 0 (the claim is committed alone)")
    val("race_" + db, "409x%d" % len(d))

def c_tx(ls, db):
    f = grab(ls, r"the first: (\d{3})", "first"); d = grab(ls, r"the duplicate: (\d{3})", "dup")
    need(f == "201", "the first: 201"); need(d in ("201", "409"), "the duplicate: %s" % d)
    if db == "pg": need(any("pg_locks not granted 1 or more" in l for l in ls), "PostgreSQL: the duplicate waited on the claim's row (pg_locks)")
    val("tx_" + db, "%s/%s" % (f, d))

def c_slow(ls, name, plant=None):
    b = re.search(r"B \(the retry, on \d+\): 409 answers (\d+) \[(.*?)\] then (\d{3})", "\n".join(ls))
    a = re.search(r"A \(the slow original, on \d+, released after B's answer\): (\d{3})(.*)", "\n".join(ls))
    pz = re.search(r"pauses \(the second client\): (\d+) pauses, \d+ days.* -> (\d+) pauses", "\n".join(ls))
    if not (b and a and pz): fail("the slow original's lines"); return
    n = int(pz.group(2)) - int(pz.group(1)); val(name + "_pauses", n); val(name + "_A", a.group(1)); val(name + "_B", b.group(3))
    need(int(b.group(1)) >= 1 and "idempotency-key-outstanding" in b.group(2), "B: one or more typed 409s before the age")
    if plant is None:
        need(b.group(3) == "201", "B: then 201 (reclaimed)"); need(a.group(1) == "503" and "Location" not in a.group(2) and "application/problem+json" in a.group(2), "A: 503 problem+json, no Location")
        need(n == 1, "ONE pause"); need(any("KEY RECLAIMED" in l for l in ls), "KEY RECLAIMED"); need(any("RELEASED after phase 2's time limit (TransactionTimedOutException): 0 key row deleted" in l for l in ls), "KEY RELEASED after phase 2's time limit: 0 key row deleted")
        need(any("C (one more retry): 201" in l and "cmp: byte-identical" in l for l in ls), "C: B's answer, byte-identical")
    elif plant == "nofence":
        need(a.group(1) == "201" and "Location" in a.group(2), "plant-nofence: A 201 with its own Location"); need(b.group(3) == "201", "plant-nofence: B 201"); need(n == 2, "plant-nofence: TWO pauses")
    else:
        need(a.group(1) == "409" and any("KEY ROLLBACK: the claim was reclaimed by another request (the fence)" in l for l in ls), "plant-nolimit: A 409, the fence's rollback"); need(n == 1, "plant-nolimit: one pause")

def c_kill(ls, db):
    need(any(re.search(r"kill -9 K1 \(its own pid\): the client's answer 000 .*Empty reply", l) for l in ls), "the client: curl's empty reply (000)")
    need(any("listeners on" in l and l.rstrip().endswith(": 0") for l in ls if "kill -9 K1" in l), "0 listeners after the kill")
    if db == "pg":
        need(any("key row status 0 claimed true" in l and "sessions idle in transaction 0" in l for l in ls if "PostgreSQL after the kill" in l), "PostgreSQL after the kill: the key row status 0 claimed, 0 sessions idle in transaction")
        kp = re.search(r"K2plant .*: 409 answers (\d+) then (\d{3})", "\n".join(ls)); need(kp and kp.group(2) == "409", "K2plant (no reclaim): still 409 past the age - the stuck key")
    k3 = re.search(r"K3 retries: 409 answers (\d+) then (\d{3})", "\n".join(ls)); need(k3 and k3.group(2) == "201", "K3: then 201")
    need(any("one more retry: 201" in l and "cmp: byte-identical" in l for l in ls), "one more retry: byte-identical")
    m = re.search(r"one more retry: .*· (\d+) pauses, \d+ days.*\(before the kill: (\d+) pauses", "\n".join(ls))
    need(m and int(m.group(1)) - int(m.group(2)) == 1, "pauses +1 once across the kill"); val("kill_" + db, "+1")
    if k3: val("kill_k3_409s_" + db, "masked")

def c_types(ls, db):
    for t in ("missing", "reused", "outstanding"):
        need(any(l.startswith("  %s: valid JSON · type tag:tiffinbox.example,2026:idempotency-key-%s" % (t, t)) for l in ls), "%s: valid JSON, its tag: type" % t)
    six = [l for l in ls if re.match(r"^  (escaped quote|two field lines|a parameter|a Token, not a String|an empty String|256 characters):", l)]
    need(len(six) == 6 and all(re.search(r": 400 · valid JSON · type tag:tiffinbox\.example,2026:idempotency-key-malformed .*echoed in the body: 0$", l) for l in six), "six malformed keys: 400 ...-malformed, valid JSON, the key never echoed")
    need(any(l.startswith("  255 characters (accepted): 201") for l in ls), "255 characters: 201")
    r = [l for l in ls if "the route's own" in l]
    need(r and " 409 " in r[0] and '"type"' not in r[0] and "key row n-1: no row" in r[0], "the route's 409: no type, its key not stored")
    f = [l for l in ls if "the filter's (a request outstanding)" in l]
    need(f and '"type":"tag:tiffinbox.example,2026:idempotency-key-outstanding"' in f[0], "the filter's 409: typed")

def c_order(ls, db, off=False):
    txt = "\n".join(ls)
    if not off:
        need(re.search(r"POST /customers key: 201.*\n(?:.*\n)*?.*Repository\.add \(key \"ord-\w+\"\) returned: transaction active true · customers cache \[SimpleKey \[\]\]", txt) is not None, "proxy on, the key: add returned inside the key's transaction - still warm (the evict deferred)")
        need(re.search(r"after the commit \(the feed's phase\): customers cache \[\]", txt) is not None, "after the commit: already []")
    else:
        need(re.search(r"returned: transaction active true · customers cache \[\]", txt) is not None, "proxy off, the key: add returned, transaction active - [] (evicted before the commit)")
    val("order_" + db + ("_off" if off else ""), "ok")

def c_window(ls, db):
    need(any(re.match(r"^  customers \[\] \(the harness's", l) for l in ls), "the cache empty right after the Started line")
    need(any("GET /actuator/health" in l and "customers [SimpleKey []]" in l for l in ls), "one health check fills customers [SimpleKey []]")
    g = grab(ls, r"GET /customers -> 200 .*statements (\d+)", "get")
    need(g == "0", "then GET /customers: 0 statements"); val("window_" + db, "health->warm")

def c_window_ii(ls, db, off=False):
    txt = "\n".join(ls)
    if off:
        need(re.search(r"after the commit: .*Winwarm\w* listed 0 · statements 0", txt) is not None, "proxy off, warm: after the commit the list still lacks the customer, 0 statements (the stale read)")
    else:
        need(re.search(r"warm: before.*\n.*inside the window.*listed 0 · .*statements 0", txt) is not None, "warm: inside the window the old list, 0 statements")
        need(re.search(r"after the commit: customers \[\] · .*Winwarm\w* listed 1 · statements 1", txt) is not None, "warm: after the commit [] and the next GET lists it")
        need(re.search(r"after the commit: customers \[\] · .*Wincold\w* listed 1", txt) is not None, "cold: the deferred clear, the next GET lists it")
    t = grab(ls, r"expireAfterWrite (PT\w+)", "ttl"); val("ttl" + ("_off" if off else "") + "_" + db, t)

def c_limits(ls, db):
    need(any(" -> 413 " in l and "key row big-1: no row" in l for l in ls), "70,000 bytes: 413, no key row")
    need(any(l.startswith("  http_server_requests_seconds_count") and 'status="201"' in l for l in ls), "prometheus: the pause route's 201s carry its pattern")
    t = grab(ls, r'idempotency_key\.body: (?:\{"DATA_TYPE":")?([A-Za-z ]+?)(?:"\})? \(', "coltype"); val("body_type_" + db, (t or "").replace(" ", "_"))
    need(t in ("CHARACTER VARYING", "text"), "V5's body column: %s (H2 CHARACTER VARYING, PostgreSQL text)" % t)

def c_map(ls):
    need(sum('REPLAY "m-1" from the JVM\'s map' in l for l in ls) == 2, "the map replays in each JVM (2)")
    p = [int(m.group(1)) for l in ls for m in [re.search(r"try \d: .*· (\d+) pauses", l)] if m]
    need(len(p) == 4 and p[1] == p[0] and p[2] == p[1] + 1 and p[3] == p[2], "after the restart the map forgot the key: a second pause landed (%s)" % p)
    val("map_pg", "->".join(map(str, p)))

def c_inert(ls):
    S466 = re.search(r"the expected seven ([0-9a-f]{32})", "\n".join(ls)); SURF = re.search(r"the old surface by count ([0-9a-f]{32})", "\n".join(ls))
    if not (S466 and SURF): fail("the expected hashes"); return
    for side in ("before", "mid", "after", "after-off"):
        m = re.search(r"^  %s: the seven ([0-9a-f]{32}) .*· the old surface ([0-9a-f]{32})" % re.escape(side), "\n".join(ls), re.M)
        need(m and m.group(1) == S466.group(1), "%s: the seven = %s" % (side, S466.group(1)[:8]))
        need(m and m.group(2) == SURF.group(1), "%s: the old surface = %s" % (side, SURF.group(1)[:8]))
    need(any("planted: the seven" in l and "unchanged: yes" in l and "moved: yes" in l for l in ls), "the ETag plant: the seven unchanged, the old surface moved")
    tr = [l for l in ls if "TRACE / on" in l]
    need(len(tr) == 2 and all("(Tomcat's own answer): 405 " in l for l in tr), "TRACE: 405 on before/ and after/ (Tomcat's)")
    val("seven", S466.group(1)[:8]); val("surface", SURF.group(1)[:8])

def c_exercise(ls):
    txt = "\n".join(ls)
    for sh in ("bash", "zsh"):
        need(re.search(r"broken, %s.*\n(?:.*\n)*?  check: FAIL" % sh, txt) is not None, "broken (%s): FAIL" % sh)
        need(re.search(r"solved, %s.*\n(?:.*\n)*?  PASS: one pause, counted once" % sh, txt) is not None, "solved (%s): PASS" % sh)
    need(re.search(r"wrong, bash.*\n(?:.*\n)*?  the tries answered: 201 422\n(?:.*\n)*?  check: FAIL", txt) is not None, "the wrong \"solution\" (another ?days= under one key): 422, FAIL")
    def blk(tag, sh):
        out = []; on = False
        for l in ls:
            if l.startswith("== the exercise, %s, %s" % (tag, sh)): on = True; continue
            if on and l.startswith("=="): break
            if on and not re.match(r"^  (guard before |ex-\w+-\w+ up on )", l): out.append(l[2:])
        return out
    rd = [l[len("  README: "):] for l in ls if l.startswith("  README: ")]; so = [l[len("  SOLUTION: "):] for l in ls if l.startswith("  SOLUTION: ")]
    need(blk("broken", "bash") == rd, "exercise/README.md's What it prints = the broken run's lines")
    need(blk("solved", "bash") == so, "SOLUTION.md's What it prints = the solved run's lines")
    need(blk("broken", "bash") == blk("broken", "zsh") and blk("solved", "bash") == blk("solved", "zsh"), "bash and zsh -f print the same")
    val("exercise", "broken-FAIL,solved-PASS,wrong-FAIL")

CAPS = {"tests": c_tests, "bill": c_bill, "inert": c_inert, "exercise": c_exercise, "map": c_map}
def capture(nm, p):
    ls = lines(p); db = "pg" if nm.endswith("pg") else "h2"; base = nm[:-2] if nm.endswith("pg") else nm
    if nm in CAPS: CAPS[nm](ls)
    elif base == "twice": c_twice(ls, db)
    elif base == "pause": c_pause(ls, db)
    elif base == "key": c_key(ls, db)
    elif base == "mismatch": c_mismatch(ls, db)
    elif base == "error": c_error(ls, db)
    elif base == "race": c_race(ls, db)
    elif base == "tx": c_tx(ls, db)
    elif base == "types": c_types(ls, db)
    elif base == "order": c_order(ls, db)
    elif base == "orderoff": c_order(ls, db, True)
    elif base == "window": c_window(ls, db)
    elif base == "windowii": c_window_ii(ls, db)
    elif base == "windowoff": c_window_ii(ls, db, True)
    elif base == "limits": c_limits(ls, db)
    elif base == "fence": c_slow(ls, "fence_" + db)
    elif nm == "plantnofence": c_slow(ls, "plant_nofence", "nofence")
    elif nm == "plantnolimit": c_slow(ls, "plant_nolimit", "nolimit")
    elif base == "killh2" or nm == "killh2": c_kill(ls, "h2")
    elif nm == "killpg": c_kill(ls, "pg")
    else: fail("no checks for the capture %r" % nm)
    done()

def hashable(nm, p):
    for l in lines(p):
        l = re.sub(r"409 answers \d+", "409 answers <n>", l)
        l = re.sub(r"\(KEY IN-FLIGHT lines: .*\)", "(KEY IN-FLIGHT lines: <n>)", l)
        if re.search(r"KEY (IN-FLIGHT|BUSY)", l): continue
        if re.search(r"receipts\.sh: line \d+: +\d+ Killed: 9 ", l): continue   # bash's own job notice for the killed JVM: printed or not, by the shell's timing
        if l.startswith("  Testcontainers' containers while verify ran"): continue
        if l.startswith("  (.r-bill.out, git-ignored, not hashed)"): continue   # a fresh clone has no .r-bill.out: printed where it exists, never hashed   # a poll of short-lived containers: printed, never hashed
        l = re.sub(r"(status=\"409\".*\} )[0-9.E]+", r"\1<n>", l)
        l = re.sub(r"guard before .*", "guard", l)
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
        elif a[0] == "prob": prob(a[1])
        elif a[0] == "pauses":
            d = lower(json.load(sys.stdin)); print("%s pauses, %s days" % (d["pauses"], d["days"]))
        elif a[0] == "keyrow":
            rows = [lower(x) for x in json.load(sys.stdin)]; hit = ["status %s claimed %s" % (x["status"], str(x["claimed"]).lower()) for x in rows if x["idem_key"] == a[1]]
            print(hit[0] if hit else "no row")
        elif a[0] == "ck": print(json.load(sys.stdin)["customers"]["keys"])
        elif a[0] == "ttl":
            d = json.load(sys.stdin)["customers"]; print("customers: maximumSize %s · expireAfterWrite %s · recordStats %s · %s" % (d.get("maximumSize"), d.get("expireAfterWrite"), d.get("recordStats"), d.get("decorator")))
        elif a[0] == "surefire": surefire(a[1])
        elif a[0] == "bom": bom(a[1], a[2])
        elif a[0] == "mappings": mappings(sys.stdin)
        elif a[0] == "hashable": hashable(a[1], a[2])
        elif a[0] == "values": values(a[1], a[2])
        else: capture(a[0], a[1])
    except SystemExit:
        raise
    except Exception as e:
        print("FAIL the checker could not read its input (%s: %s)" % (e.__class__.__name__, str(e)[:160])); sys.exit(1)
