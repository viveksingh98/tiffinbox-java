"""Unit 26's checks (python3 -I -B harness/chk26.py NAME ARG...), each re-deriving its numbers from a capture or from the shipped files,
never from the README's prose; every check prints "ok ..." or "FAIL ...", and one "VALUES ..." line (what the video may say), and exits 1
on a FAIL. A capture line it cannot parse is a FAIL of its own, never a traceback: every listing line it reads is parsed by a named
pattern or skipped by a named rule, and any error while reading ends in a FAIL line and exit 1 (unit 25's chk25 printed its verdict and
then tracebacked on a line it could not parse - the defect class this file closes). Names:
  static AFTER BEFORE  s826.py's lines 10-403 = s825.py's (md5), its lines 409-524 = XFAM_S5's slice (the md5 chk25.py pins, read off
                  it); tree26.py's code = tree25.py's; every line H26.java and the variants print says "the harness's"; the patch;
                  the change's files; the stale sentences (R.250/R.453); the variants against the shipped files they copy
  inject AFTER    who names each repository in AFTER's src/main and src/test, comments stripped (unit 25's reading)
  anchor F        the change's files, 84 files, the libs, the postfix "Impl", the readers, the start's lines, the JSON byte-equal,
                  the four totals and their sum = /kitchen's ordersValue on both trees
  composition F   two fragments, isCustomMethod / isQueryMethod, the six and five, 1 aggregate + 1 find in their windows, the stack's
                  Commons classes in order, mongosh's four totals
  misnamed F      exit 1, no start, the exception chain whole: revenue <- orderDocuments <- QueryCreationException <- PropertyReference
  silent F        7 (3 fragments, isCustomMethod true, sort day -1 limit 7) vs 30 (2 fragments, isQueryMethod true, no sort), exit 0 both
  lookup F M      (a) one bean orderTotalsImpl, the composition unchanged; (b) exit 1, the same chain as M (misnamed's)
  why F C         the @Aggregation strings sent as written, the same four totals as C (composition's)
  jpatx F         three runs alike: active false, the exception whole, rows 0 (JdbcTemplate and psql); the control: true, rows 1
  seven F MD5     both trees: 7 lines, md5 = MD5 (read off ../c7-unit31/receipts.sh)
  verify F        18 + 14 (MongoDatastoreIT 4), five IT BINDINGS lines on 127.0.0.1, the new test's own line, nothing pulled or left
  exercise F W Q  bash and zsh: broken (the start fails with the text), solved (started, the four totals, 24300); the deleted method x3
  wib F FILE      what FILE's "What it prints" block must be: the bash run's lines of that file's block, from the capture F
  readme R V      README.md's values block = V; every line of its text blocks is a line a capture printed (R.302)"""
import hashlib, os, re, sys

HERE = os.path.dirname(os.path.abspath(__file__)); U = os.path.dirname(HERE); REPO = os.path.dirname(U)
FAILS = []; VALUES = []
TOT = [("Sunil", 9000), ("Ravi", 7200), ("Meera", 4500), ("Priya", 3600)]
WEB = "tiffinbox-web/src/main/java/com/tiffinbox/web/"


def ok(c, msg):
    print(("ok " if c else "FAIL ") + msg)
    if not c: FAILS.append(msg)


def rd(p): return open(p, encoding="utf-8").read()


def md5(s): return hashlib.md5(s.encode()).hexdigest()


def lines(p): return rd(p).splitlines()


def static(after, before):
    s6 = rd(os.path.join(HERE, "s826.py")).split("\n"); s5 = rd(os.path.join(REPO, "c8-unit25", "harness", "s825.py")).split("\n")
    ok(s6[9].startswith("import hashlib") and md5("\n".join(s6[9:403])) == md5("\n".join(s5[9:403])), "s826.py's lines 10-403 = s825.py's lines 10-403 (the family base), byte for byte (md5 %s)" % md5("\n".join(s6[9:403])))
    pin = re.search(r'^XFAM5B_SLICE_MD5 = "([0-9a-f]{32})"', rd(os.path.join(REPO, "c8-unit25", "harness", "chk25.py")), re.M)
    b6 = "\n".join(s6[408:524])
    ok(pin is not None and s6[408].startswith("MOD = ") and md5(b6) == pin.group(1), "s826.py's lines 409-524 (XFAM_S5 + TIMEPAT_S5) = the slice ../c8-unit25/harness/chk25.py pins (md5 %s, read off it)" % md5(b6))
    ok(re.search(r"^XEXEMPT_S5\s*=", "\n".join(s6), re.M) is None, "no XEXEMPT_S5 in s826.py")
    t6 = rd(os.path.join(HERE, "tree26.py")).split('"""', 2)[2]; t5 = rd(os.path.join(REPO, "c8-unit25", "harness", "tree25.py")).split('"""', 2)[2]
    ok(t6 == t5, "tree26.py's code = tree25.py's, byte for byte (only the docstring differs)")
    j = re.sub(r"(?s)/\*.*?\*/", "", rd(os.path.join(HERE, "src", "probe", "u26", "H26.java")))
    ok(re.findall(r'System\.out\.println\("([^"]*)', j) == ["the harness's "], "H26.java prints through p() alone, and p() starts every line with \"the harness's \"")
    ok("@Enable" not in re.sub(r"//[^\n]*", "", j), "H26.java: no @Enable...Repositories (S8.101)")
    vs = []
    for d, ds, fs in os.walk(os.path.join(HERE, "variants")):
        for f in fs: vs.append(os.path.join(d, f))
    pr = [l for v in vs for l in re.findall(r'System\.out\.println\("([^"]*)', rd(v))]
    ok(len(vs) == 11 and len(pr) == 4 and all(l.startswith("the harness's variant ") for l in pr), "the variants: 11 files, their %d print lines each \"the harness's variant ...\"" % len(pr))
    ok(all(re.search(r"^/\*\* The harness's variant \(unit 26, ", rd(v), re.M) or "// the harness's variant (unit 26, jpatx)" in rd(v) for v in vs), "every variant file names itself the harness's variant (unit 26, ...)")
    ce = rd(os.path.join(HERE, "variants/jpa/com/tiffinbox/CustomerEntityRepository.java")).split("\n"); ca = rd(os.path.join(after, "tiffinbox-core/src/main/java/com/tiffinbox/CustomerEntityRepository.java")).split("\n")
    dl = [i for i in range(max(len(ce), len(ca))) if (ce[i] if i < len(ce) else None) != (ca[i] if i < len(ca) else None)]
    ok(len(ce) == len(ca) and len(dl) == 1 and ce[dl[0]].startswith("public interface CustomerEntityRepository extends JpaRepository<CustomerEntity, Long>, CustomerWrites {"), "the jpa variant's CustomerEntityRepository = after/'s with its one extends line changed")
    cv = rd(os.path.join(HERE, "variants/comp/com/tiffinbox/web/OrderTotalsImpl.java")); cs = rd(os.path.join(after, WEB + "OrderTotalsImpl.java"))
    strip = lambda t: re.sub(r"(?s)/\*\*.*?\*/\n", "", t, count=1)
    ok(strip(cv).replace("import org.springframework.stereotype.Component;\n", "").replace("@Component\n", "") == strip(cs), "the comp variant = after/'s OrderTotalsImpl with @Component and its import, nothing else in the code")
    pt = rd(os.path.join(HERE, "it-bindings.patch")); files = re.findall(r"^\+\+\+ b/(\S+)", pt, re.M)
    ok(len(files) == 5 and all("/src/test/java/" in f for f in files), "it-bindings.patch: five files, every one under src/test/java (%s)" % ", ".join(f.split("/")[-1] for f in files))
    ok(pt.count("bindIp(\"127.0.0.1\")") == 3 and pt.count("System.out.println(\"IT BINDINGS ") == 5, "it-bindings.patch: bindIp(\"127.0.0.1\") on three ITs, five IT BINDINGS lines")
    p25 = rd(os.path.join(REPO, "c8-unit25", "harness", "it-bindings.patch"))
    ch = lambda t: [l for l in t.split("\n") if re.match(r"^[-+][^-+]", l)]
    ok(ch(pt) == ch(p25), "it-bindings.patch's changed lines = unit 25's, line for line (only MongoDatastoreIT's hunk header moved: its Javadoc grew)")
    ia = rd(os.path.join(after, WEB + "OrderTotalsImpl.java")); rv = rd(os.path.join(after, WEB + "Revenue.java")); od = rd(os.path.join(after, WEB + "OrderDocuments.java"))
    code = lambda t: re.sub(r"//[^\n]*", "", re.sub(r"(?s)/\*.*?\*/", "", t))
    ok("@Component" not in code(ia) and "@Repository" not in code(ia), "OrderTotalsImpl: no @Component, no @Repository (Commons finds it by its name)")
    ok("record Total" not in rv and "orders.totalsByCustomer()" in code(rv), "Revenue: no record Total; the route reads orders.totalsByCustomer()")
    ok("extends MongoRepository<OrderDocument, String>, OrderTotals {" in od and "one derived finder" not in od, "OrderDocuments extends OrderTotals; its Javadoc says no \"one derived finder\"")
    rm = rd(os.path.join(after, "README.md")).split("\n"); bad = []
    c0 = next((k for k, l in enumerate(rm) if l.startswith("## Course 8 · unit 26 ")), len(rm)); c1 = next((k for k in range(c0, len(rm)) if rm[k] == "---"), len(rm))
    for i, l in enumerate(rm):
        if c0 <= i < c1: continue   # rule: unit 26's own card names what it replaces
        if "Revenue.Total" in l and not any("unit 26" in rm[k] for k in range(max(0, i - 1), min(len(rm), i + 3))): bad.append("Revenue.Total:%d" % (i + 1))
        if "18 + 13" in l and not any("unit 26: 18 + 14" in rm[k] for k in range(i, min(len(rm), i + 3))): bad.append("18 + 13:%d" % (i + 1))
        if "one derived finder" in l and not any("unit 26" in rm[k] for k in range(i, min(len(rm), i + 4))): bad.append("one derived finder:%d" % (i + 1))
    ok(not bad, "R.250/R.453: every README line with Revenue.Total, \"18 + 13\" or \"one derived finder\" carries its unit 26 note (stale: %s)" % (bad or "none"))
    srcs = []
    for root in ("tiffinbox-core", "tiffinbox-web"):
        for d, ds, fs in os.walk(os.path.join(after, root, "src")):
            for f in fs:
                if f.endswith(".java"): srcs.append(os.path.join(d, f))
    st = [os.path.basename(s) for s in srcs if re.search(r"\bRevenue\.Total\b", code(rd(s)))]
    ok(not st, "no Java code in after/ names Revenue.Total (%s)" % (st or "none"))
    VALUES.append("the family base and XFAM_S5 carried md5-equal; the stale sentences each noted")


def inject(after):
    src = {}
    for part in ("main", "test"):
        for root in ("tiffinbox-core", "tiffinbox-web"):
            base = os.path.join(after, root, "src", part, "java")
            for d, ds, fs in os.walk(base):
                for f in fs:
                    if f.endswith(".java"):
                        t = re.sub(r"(?s)/\*.*?\*/", "", rd(os.path.join(d, f))); t = re.sub(r"//[^\n]*", "", t)
                        src.setdefault(part, {})[f[:-5]] = t
    for r in SIX:
        row = []
        for part in ("main", "test"):
            w = sorted(k for k, t in src.get(part, {}).items() if k != r and re.search(r"\b%s\b" % r, t))
            row.append(", ".join(w) or "none")
        print("    %-25s main: %s · test: %s" % (r, row[0], row[1]))


SIX = ["CustomerEntityRepository", "DishEntityRepository", "CustomerAggregates", "KitchenOrders", "OrderDocuments", "Dishes"]


def grab(L, rx, name):
    """The one line matching rx, parsed; a missing or doubled line is a FAIL by name, never an exception."""
    m = [re.match(rx, l) for l in L]; m = [x for x in m if x]
    ok(len(m) == 1, "%s: one line (%d found)" % (name, len(m)))
    return m[0] if len(m) == 1 else None


def totals_of(s):
    try:
        import json
        return [(x["customer"], x["total"]) for x in json.loads(s)]
    except Exception:
        return None


def startcounts(L, i0):
    """The (xN) lines under one start's header, from line i0 on, until the next line that is not one (rule: a (xN) line or stop)."""
    c = {"mult": 0, "csi": 0, "found": {}, "flyway": None}; mod = {}
    for l in L[i0:]:
        m = re.match(r"^    \(x(\d+)\) (.*)$", l)
        if not m: break
        k, s = int(m.group(1)), m.group(2)
        if s == "Multiple Spring Data modules found, entering strict repository configuration mode": c["mult"] += k
        mm = re.match(r"^Spring Data ([A-Za-z ]+?) - Could not safely identify store assignment for repository candidate interface ", s)
        if mm: c["csi"] += k; mod[mm.group(1)] = mod.get(mm.group(1), 0) + k
        mf = re.search(r"Found (\d+) (JPA|JDBC|Redis|MongoDB|Elasticsearch|Reactive Elasticsearch) repository interfaces?\.", s)
        if mf: c["found"][mf.group(2)] = int(mf.group(1))
        fw = re.match(r"^Successfully applied (\d+) migrations", s)
        if fw: c["flyway"] = int(fw.group(1))
    c["mod"] = mod
    return c


def anchor(p):
    L = lines(p); t = "\n".join(L)
    ch = sorted(re.sub(r"^  changed: ", "", l) for l in L if l.startswith("  changed: ")); nw = sorted(re.sub(r"^  new: ", "", l) for l in L if l.startswith("  new: "))
    ok(ch == ["README.md", WEB + "OrderDocuments.java", WEB + "Revenue.java", "tiffinbox-web/src/test/java/com/tiffinbox/web/MongoDatastoreIT.java"] or sorted(ch) == sorted(["README.md", WEB + "OrderDocuments.java", WEB + "Revenue.java", "tiffinbox-web/src/test/java/com/tiffinbox/web/MongoDatastoreIT.java"]), "the change: README.md, OrderDocuments.java, Revenue.java, MongoDatastoreIT.java changed (%d)" % len(ch))
    ok(nw == [WEB + "CustomerTotal.java", WEB + "OrderTotals.java", WEB + "OrderTotalsImpl.java"], "the change: CustomerTotal.java, OrderTotals.java, OrderTotalsImpl.java new (%d); nothing gone (%d)" % (len(nw), sum(1 for l in L if l.startswith("  gone: "))))
    ok(not any(l.startswith("  gone: ") for l in L), "nothing gone")
    m = grab(L, r"^  the trees \(python3 -I harness/tree26\.py, links followed\): before/ (\d+) ([0-9a-f]{32}) · after/ (\d+) ([0-9a-f]{32})$", "the trees")
    pin = rd(os.path.join(REPO, "c8-unit25", "receipts.md5")); pin = re.search(r"^after-tree (\d+) ([0-9a-f]{32})$", pin, re.M)
    if m: ok(pin is not None and (m.group(1), m.group(2)) == pin.groups() and int(m.group(3)) == int(m.group(1)) + 3, "before/ = ../c8-unit25/receipts.md5's after-tree line (%s files); after/ %s files = before/'s + the three new" % (m.group(1), m.group(3)))
    b = grab(L, r"^  the builds: after/ 'Downloaded from' (\d+) · before/ (\d+) · BOOT-INF/lib: after/ (\d+) jars, before/ (\d+) jars, the same names: (yes|no)$", "the builds")
    if b: ok(b.group(1) == b.group(2) == "0" and b.group(3) == b.group(4) and b.group(5) == "yes", "both builds offline; BOOT-INF/lib %s jars on both trees, the same names (the change adds no dependency)" % b.group(3))
    pf = grab(L, r"^  @EnableMongoRepositories' repositoryImplementationPostfix, its default \(javap -v, [^)]+\): (.*)$", "the postfix")
    if pf: ok(pf.group(1) == '"Impl"', "repositoryImplementationPostfix's default, read by javap -v: %s" % pf.group(1))
    rdr = {}
    for l in L:
        mm = re.match(r"^    (\w+) +main: (.*) · test: (.*)$", l)
        if mm: rdr[mm.group(1)] = (mm.group(2), mm.group(3))
    inj = sorted(k for k, v in rdr.items() if v[0] != "none")
    ok(len(rdr) == 6 and rdr.get("OrderDocuments", ("",))[0] == "Revenue", "OrderDocuments' src/main reader: %s" % rdr.get("OrderDocuments", ("?",))[0])
    starts = [i for i, l in enumerate(L) if re.match(r"^-- (after|before)/'s jar under dev on (20650|20655)", l)]
    ok(len(starts) == 2, "two dev starts, after/ on 20650 and before/ on 20655")
    cs = []
    for i in starts:
        ok(re.search(r": exit 0 · listening on: 127\.0\.0\.1:(20650|20655)$", L[i]) is not None, "the start exits 0 after POST /shutdown, listening on 127.0.0.1 alone: " + L[i][3:40])
        j = next((k for k in range(i, len(L)) if L[k].startswith("  its start's repository and Flyway lines")), None)
        cs.append(startcounts(L, j + 1) if j is not None else None)
    for nm, c in zip(("after/", "before/"), cs):
        if c is None: ok(False, nm + ": its start lines"); continue
        ok(c["mult"] == 6 and c["csi"] == 12 and c["flyway"] == 4 and c["found"].get("MongoDB") == 1, "%s: strict mode x%d, Could not safely identify %d (%s), Flyway %s, Found 1 MongoDB" % (nm, c["mult"], c["csi"], ", ".join("%s %d" % kv for kv in sorted(c["mod"].items())), c["flyway"]))
    ra = grab(L, r"^  GET /revenue/by-customer on 20650 \(after/\): (.*)$", "after/'s route"); rb = grab(L, r"^  GET /revenue/by-customer on 20655 \(before/\): (.*)$", "before/'s route")
    ta, tb = (totals_of(ra.group(1)) if ra else None), (totals_of(rb.group(1)) if rb else None)
    ok(ta == TOT and tb == TOT, "the four totals on both trees: %s" % ("; ".join("%s %s" % x for x in (ta or []))))
    h = grab(L, r"^  the two bodies: md5 after/ ([0-9a-f]{32}) · before/ ([0-9a-f]{32}) · cmp: (byte-equal|DIFFER)$", "the bodies")
    ok(h is not None and h.group(1) == h.group(2) and h.group(3) == "byte-equal" and ra and rb and ra.group(1) == rb.group(1) and md5(ra.group(1)) == h.group(1), "RE-MEASURE 12: the route's JSON byte-equal before/after (cmp, and the md5 of the printed body re-derived: %s)" % (h.group(1) if h else "?"))
    k = grab(L, r'^  GET /kitchen on 20650 \(after/\): \{"ordersCooked":(\d+),"ordersValue":(\d+)\} · on 20655 \(before/\): \{"ordersCooked":(\d+),"ordersValue":(\d+)\}$', "the kitchen")
    s = sum(v for _, v in (ta or []))
    ok(k is not None and int(k.group(2)) == s == int(k.group(4)) == 24300, "the totals' sum %d (added here) = /kitchen's ordersValue on both trees (%s, %s)" % (s, k.group(2) if k else "?", k.group(4) if k else "?"))
    ok(re.search(r'^  POST /shutdown \(the token\): after/ \{"stopping":true\} · before/ \{"stopping":true\}$', t, re.M) is not None, "both stopped by POST /shutdown with the token")
    VALUES.append("changed 4 (README.md, OrderDocuments, Revenue, MongoDatastoreIT) · new 3 (CustomerTotal, OrderTotals, OrderTotalsImpl) · files %s -> %s · libs %s · postfix %s · repositories with a src/main reader %d of 6 (%s) · strict x%s, Could not safely identify %s, Flyway %s · the JSON byte-equal md5 %s · %s · sum %d = ordersValue" % (
        m.group(1) if m else "?", m.group(3) if m else "?", b.group(3) if b else "?", pf.group(1) if pf else "?", len(inj), ", ".join(inj), cs[0]["mult"] if cs and cs[0] else "?", cs[0]["csi"] if cs and cs[0] else "?", cs[0]["flyway"] if cs and cs[0] else "?", h.group(1) if h else "?", " · ".join("%s %d" % x for x in (ta or [])), s))


COMPRX = r"^the harness's   composition \(RepositoryInformation\.getRepositoryComposition\(\)\.getFragments\(\)\) (\d+) \[(.*)\]$"


def comp_of(L, name):
    """The composition line, parsed fragment by fragment; a fragment of another shape is a FAIL, never an exception."""
    c = [l for l in L if l.startswith("the harness's   composition ")]
    ok(len(c) == 1, "%s: one composition line (%d)" % (name, len(c)))
    if len(c) != 1: return None
    m = re.match(COMPRX, c[0])
    if not m: ok(False, "%s: the composition line does not parse: %s" % (name, c[0][:120])); return None
    fr = [x.strip() for x in m.group(2).split(",")] if m.group(2) else []
    good = all(re.match(r"^(ImplementedRepositoryFragment \w+:\w+|StructuralRepositoryFragment \w+)$", x) for x in fr)
    ok(good and int(m.group(1)) == len(fr), "%s: the composition parses, %d fragments, each of a known shape" % (name, len(fr)))
    return fr if good else None


def methods_of(L):
    d = {}
    for l in L:
        m = re.match(r"^the harness's   (\w+)\.(\w+) isCustomMethod (true|false) · isQueryMethod (true|false)$", l)
        if m: d[m.group(2)] = (m.group(1), m.group(3) == "true", m.group(4) == "true")
    return d


def prof(L, lab):
    e = [l for l in L if l.startswith("the harness's   the profiler [%s] op=" % lab)]
    n = grab(L, r"^the harness's   the profiler \[%s\] entries (\d+)$" % re.escape(lab), "the profiler window " + lab)
    return e, (int(n.group(1)) if n else -1)


def composition(p):
    L = lines(p)
    ok(re.search(r"the JVM's exit 0$", next((l for l in L if l.startswith("-- composition: ")), "")) is not None, "the harness's JVM exits 0")
    r6 = grab(L, r"^the harness's repositories \(Commons' Repositories over the context\) (\d+) \[(.*)\]$", "the repositories")
    ok(r6 is not None and r6.group(1) == "6" and r6.group(2).split(", ") == sorted(SIX), "six repositories by name (%s)" % (r6.group(2) if r6 else "?"))
    f5 = grab(L, r"^the harness's factory beans (\d+) \[(.*)\]$", "the factory beans")
    ok(f5 is not None and f5.group(1) == "5", "five factory beans (%s)" % (f5.group(2) if f5 else "?"))
    fr = comp_of(L, "composition")
    ok(fr == ["ImplementedRepositoryFragment OrderTotals:OrderTotalsImpl", "StructuralRepositoryFragment SimpleMongoRepository"], "S8.102: two fragments - OrderTotals:OrderTotalsImpl, then SimpleMongoRepository")
    md = methods_of(L)
    ok(md.get("totalsByCustomer") == ("OrderTotals", True, False) and md.get("findByMealType") == ("OrderDocuments", False, True), "isCustomMethod(totalsByCustomer) true · isQueryMethod(findByMealType) true")
    bi = grab(L, r"^the harness's beans whose class is TiffinBox's and ends in Impl or Implementation: (\d+) \[(.*)\]$", "the Impl beans")
    ok(bi is not None and bi.group(1) == "1" and bi.group(2) == "orderTotalsImpl=com.tiffinbox.web.OrderTotalsImpl", "one bean of the class, orderTotalsImpl (%s)" % (bi.group(2) if bi else "?"))
    e, n = prof(L, "totalsByCustomer")
    ok(n == 1 and len(e) == 1 and ' op=command ' in e[0] and '"aggregate": "orders", "pipeline": [{"$group": {"_id": "$customer", "total": {"$sum": "$value"}}}, {"$sort": {"total": -1}}]' in e[0], "1 aggregate in totalsByCustomer()'s window (the profiler), the pipeline $group then $sort")
    e2, n2 = prof(L, "findByMealType")
    ok(n2 == 1 and len(e2) == 1 and " op=query " in e2[0] and ' nreturned=60 ' in e2[0] and '"find": "orders", "filter": {"mealType": "VEG"}' in e2[0], "1 find in findByMealType(\"VEG\")'s window, filter mealType VEG, 60 returned")
    tl = [re.match(r"^the harness's   CustomerTotal\[customer=(\w+), total=(\d+)\]$", l) for l in L]; tl = [(x.group(1), int(x.group(2))) for x in tl if x]
    ok(tl == TOT and "the harness's CALL totalsByCustomer() -> 4 results" in L, "the call's four totals: " + "; ".join("%s %d" % x for x in tl))
    fs = [re.match(r"^the harness's   STACK (\d\d) (\S+)$", l) for l in L]; fs = [x.group(2) for x in fs if x]
    want = ["com.tiffinbox.web.OrderTotalsImpl.totalsByCustomer", "org.springframework.data.repository.core.support.RepositoryMethodInvoker$RepositoryFragmentMethodInvoker.lambda$new$0",
            "org.springframework.data.repository.core.support.RepositoryComposition$RepositoryFragments.invoke", "org.springframework.data.repository.core.support.RepositoryComposition.invoke",
            "org.springframework.data.repository.core.support.RepositoryFactorySupport$ImplementationMethodExecutionInterceptor.invoke",
            "org.springframework.data.repository.core.support.QueryExecutorMethodInterceptor.invoke", "jdk.proxy<n>.$Proxy<n>.totalsByCustomer"]
    idx = [fs.index(w) if w in fs else -1 for w in want]
    ok(all(i >= 0 for i in idx) and idx == sorted(idx) and "the harness's STACK totalsByCustomer: the aggregates the window sent 1, each one's stack from MongoTemplate up to the harness's call:" in L, "the stack, from the class up: OrderTotalsImpl <- RepositoryFragmentMethodInvoker <- RepositoryFragments.invoke <- RepositoryComposition.invoke <- ImplementationMethodExecutionInterceptor <- QueryExecutorMethodInterceptor <- the proxy (%d frames)" % len(fs))
    mg = grab(L, r"^    mongosh: db\.orders\.aggregate\(.*\) -> (.*)$", "mongosh's aggregate")
    ok(mg is not None and mg.group(1) == ", ".join("%s %d" % x for x in TOT), "mongosh's own $group: the same four totals (%s)" % (mg.group(1) if mg else "?"))
    mc = grab(L, r"^    mongosh: db\.orders\.countDocuments\(\) -> (\d+) · countDocuments\(\{mealType: 'VEG'\}\) -> (\d+)$", "mongosh's counts")
    ok(mc is not None and mc.groups() == ("120", "60"), "mongosh: 120 orders, 60 VEG")
    sk = grab(L, r"^    the sockets: listening \(TCP\) on (.*) · connections from another local port \(outbound\): (\d+) · UDP sockets: (\d+)$", "the Elasticsearch sockets")
    VALUES.append("fragments 2 (OrderTotals:OrderTotalsImpl, SimpleMongoRepository) · isCustomMethod(totalsByCustomer) true · isQueryMethod(findByMealType) true · repositories 6, factory beans 5 · aggregate 1, find 1 (60) · the stack through RepositoryComposition (%d frames) · mongosh the same four totals" % len(fs))


def chain(L):
    i = next((k for k, l in enumerate(L) if l.startswith("  the exception, whole")), None)
    o = []
    if i is None: return o
    for l in L[i + 1:]:
        if not l.startswith("    "): break
        o.append(l.strip())
    return o


def failcheck(L, name):
    m = grab(L, r"^  its exit (\d+) · 'Started TiffinBoxServer' (\d+) · 'APPLICATION FAILED TO START' (\d+) · 'Application run failed' (\d+) · its MongoDB Found line: (.*)$", name + "'s exit line")
    ok(m is not None and m.group(1) == "1" and m.group(2) == "0" and m.group(4) == "1" and m.group(5) == "Found 1 MongoDB repository interface.", "%s: exit 1, no Started line, 'Application run failed' once, Found 1 MongoDB repository interface ('APPLICATION FAILED TO START' %s)" % (name, m.group(3) if m else "?"))
    c = chain(L)
    ok(len(c) == 4 and c[0].startswith("org.springframework.beans.factory.UnsatisfiedDependencyException: Error creating bean with name 'revenue' defined in URL [") and "Error creating bean with name 'orderDocuments'" in c[0] and c[0].endswith("No property 'totalsByCustomer' found for type 'OrderDocument'")
       and c[1] == "Caused by: org.springframework.beans.factory.BeanCreationException: Error creating bean with name 'orderDocuments' defined in com.tiffinbox.web.OrderDocuments defined in @EnableMongoRepositories declared on DataMongoRepositoriesRegistrar.EnableMongoRepositoriesConfiguration: No property 'totalsByCustomer' found for type 'OrderDocument'"
       and c[2] == "Caused by: org.springframework.data.repository.query.QueryCreationException: Cannot create query for method [OrderTotals.totalsByCustomer()]; No property 'totalsByCustomer' found for type 'OrderDocument'"
       and c[3] == "Caused by: org.springframework.data.core.PropertyReferenceException: No property 'totalsByCustomer' found for type 'OrderDocument'",
       "%s: the chain whole - UnsatisfiedDependencyException on 'revenue' <- BeanCreationException on 'orderDocuments' <- QueryCreationException [OrderTotals.totalsByCustomer()] <- PropertyReferenceException (%d lines)" % (name, len(c)))
    return c


def misnamed(p):
    L = lines(p)
    ok("  the copy against after/ (diff -rq, target and secrets left out): gone OrderTotalsImpl.java new OrderTotalsImplementation.java" in L, "the copy differs from after/ by the one file renamed")
    failcheck(L, "misnamed")
    VALUES.append("exit 1 · UnsatisfiedDependencyException 'revenue' <- BeanCreationException 'orderDocuments' <- QueryCreationException: Cannot create query for method [OrderTotals.totalsByCustomer()] <- PropertyReferenceException: No property 'totalsByCustomer' found for type 'OrderDocument' · 'APPLICATION FAILED TO START' 0, 'Application run failed' 1")


def silent(p):
    L = lines(p)
    i = next((k for k, l in enumerate(L) if l.startswith("-- silent: ")), None); j = next((k for k, l in enumerate(L) if l.startswith("-- silent, misnamed: ")), None)
    ok(i is not None and j is not None and i < j, "both halves in the capture")
    if i is None or j is None: return
    A, B = L[i:j], L[j:]
    ok(re.search(r"the JVM's exit 0 · ERROR lines 0$", A[0]) is not None, "named OrderLookupImpl: exit 0, ERROR lines 0")
    fa = comp_of(A, "silent"); ok(fa == ["ImplementedRepositoryFragment OrderTotals:OrderTotalsImpl", "ImplementedRepositoryFragment OrderLookup:OrderLookupImpl", "StructuralRepositoryFragment SimpleMongoRepository"], "named OrderLookupImpl: three fragments")
    ok(methods_of(A).get("findByCustomer") == ("OrderLookup", True, False), "named OrderLookupImpl: isCustomMethod(findByCustomer) true")
    e, n = prof(A, "findByCustomer")
    ok(n == 1 and len(e) == 1 and ' nreturned=7 ' in e[0] and '"filter": {"customer": "Ravi"}, "sort": {"day": -1}, "limit": 7' in e[0], "named OrderLookupImpl: 1 find, filter customer Ravi, sort day -1, limit 7, 7 returned (the profiler)")
    ok("the harness's CALL findByCustomer(\"Ravi\") -> 7 results" in A and "the harness's variant OrderLookupImpl.findByCustomer ran" in A, "named OrderLookupImpl: the class ran, 7 results")
    ids7 = "Ravi-30 Ravi-29 Ravi-28 Ravi-27 Ravi-26 Ravi-25 Ravi-24"
    ok("  the harness's variant's results, each one's id in the order returned: " + ids7 in A and any(l.startswith("  mongosh after: db.orders.find({customer: 'Ravi'}).sort({day: -1}).limit(7) -> " + ids7 + " · countDocuments({customer: 'Ravi'}) -> 30") for l in A), "named OrderLookupImpl: the seven ids, and mongosh's own find with that sort and limit, the same seven")
    ok(re.search(r"the JVM's exit 0 · ERROR lines 0 · exception lines 0$", B[0]) is not None, "named OrderLookupImplementation: exit 0, ERROR lines 0, no exception")
    fb = comp_of(B, "silent, misnamed"); ok(fb == ["ImplementedRepositoryFragment OrderTotals:OrderTotalsImpl", "StructuralRepositoryFragment SimpleMongoRepository"], "named OrderLookupImplementation: two fragments, OrderLookup's class not among them")
    ok(methods_of(B).get("findByCustomer") == ("OrderLookup", False, True), "named OrderLookupImplementation: isCustomMethod false, isQueryMethod true")
    e, n = prof(B, "findByCustomer")
    ok(n == 1 and len(e) == 1 and ' nreturned=30 ' in e[0] and e[0].endswith('command={"find": "orders", "filter": {"customer": "Ravi"}}'), "named OrderLookupImplementation: 1 find, filter customer Ravi, no sort, no limit, 30 returned (the profiler)")
    ok("the harness's CALL findByCustomer(\"Ravi\") -> 30 results" in B and not any("findByCustomer ran" in l for l in B), "named OrderLookupImplementation: the class never ran, 30 results")
    ok(any(l.startswith("  mongosh after: countDocuments({customer: 'Ravi'}) -> 30 · ") for l in B), "mongosh: 30 orders of Ravi")
    VALUES.append("the harness's variant: OrderLookupImpl -> 7 (3 fragments, isCustomMethod true, find sort day -1 limit 7) · OrderLookupImplementation -> 30 (2 fragments, isCustomMethod false, isQueryMethod true, find with no sort), exit 0, ERROR 0 · mongosh 7 and 30")


def lookup(p, mis):
    L = lines(p); M = lines(mis)
    i = next((k for k, l in enumerate(L) if l.startswith("-- lookup (b): ")), len(L)); A, B = L[:i], L[i:]
    ok(re.search(r"the JVM's exit 0$", A[0]) is not None, "(a) @Component: exit 0")
    ok(comp_of(A, "lookup (a)") == ["ImplementedRepositoryFragment OrderTotals:OrderTotalsImpl", "StructuralRepositoryFragment SimpleMongoRepository"], "(a) the same two fragments")
    bi = grab(A, r"^the harness's beans whose class is TiffinBox's and ends in Impl or Implementation: (\d+) \[(.*)\]$", "(a) the Impl beans")
    ok(bi is not None and bi.groups() == ("1", "orderTotalsImpl=com.tiffinbox.web.OrderTotalsImpl"), "(a) one bean, orderTotalsImpl - no second instance")
    ok("the harness's CALL totalsByCustomer() -> 4 results" in A, "(a) the call answers 4 totals")
    ok(any(l == "  the copy against after/ (diff -rq, target and secrets left out): gone tiffinbox-web/src/main/java/com/tiffinbox/web/OrderTotalsImpl.java new tiffinbox-web/src/main/java/com/tiffinbox/OrderTotalsImpl.java" for l in B), "(b) the copy: OrderTotalsImpl moved to com.tiffinbox, nothing else")
    cb = failcheck(B, "lookup (b)"); cm = chain(M)
    nrm = lambda c: [re.sub(r"defined in URL \[[^\]]*\]", "defined in URL [<jar>]", x) for x in c]
    ok(cb and nrm(cb) == nrm(cm), "(b) the same chain as misnamed's, line for line (the jar's URL aside)")
    VALUES.append("(a) @Component: one bean orderTotalsImpl, the composition unchanged · (b) the class in com.tiffinbox: exit 1, misnamed's chain")


def why(p, comp):
    L = lines(p); C = lines(comp)
    ok(re.search(r"the JVM's exit 0$", L[0]) is not None, "exit 0")
    e, n = prof(L, "totals")
    ok(n == 1 and len(e) == 1 and e[0].endswith('command={"aggregate": "orders", "pipeline": [{"$group": {"_id": "$customer", "total": {"$sum": "$value"}}}, {"$sort": {"total": -1}}], "cursor": {}}'), "the @Aggregation strings sent as written: 1 aggregate, $group then $sort")
    tw = [l for l in L if l.startswith("the harness's   CustomerTotal[")]; tc = [l for l in C if l.startswith("the harness's   CustomerTotal[")]
    ok(len(tw) == 4 and tw == tc, "the same four totals as the fragment's (composition's capture)")
    ce = [l for l in C if l.startswith("the harness's   the profiler [totalsByCustomer] op=")]
    ok(len(ce) == 1 and e and ce[0].split(" command=")[1] == e[0].split(" command=")[1], "the fragment's typed pipeline and the strings send the same command")
    VALUES.append("@Aggregation strings: 1 aggregate, the same command, the same four totals")


def jpatx(p):
    L = lines(p)
    hs = [k for k, l in enumerate(L) if l.startswith("-- jpatx")]
    ok(len(hs) == 4, "three runs and the control (%d)" % len(hs))
    if len(hs) != 4: return
    blk = [L[hs[k]:(hs[k + 1] if k + 1 < len(hs) else len(L))] for k in range(4)]
    body = [b[1:] for b in blk]
    ok(body[0] == body[1] == body[2], "the three runs without @Transactional print the same lines")
    b = blk[0]
    ok(re.search(r"the JVM's exit 0$", b[0]) is not None and "the harness's variant CustomerWritesImpl.addProbe: a transaction active on this thread: false" in b, "no @Transactional: a transaction active false")
    ok("the harness's CALL addProbe(\"the-harness-26\") threw org.springframework.dao.InvalidDataAccessApiUsageException: No EntityManager with actual transaction available for current thread - cannot reliably process 'persist' call" in b
       and "the harness's   cause jakarta.persistence.TransactionRequiredException: No EntityManager with actual transaction available for current thread - cannot reliably process 'persist' call" in b, "no @Transactional: InvalidDataAccessApiUsageException, its cause TransactionRequiredException, whole")
    ok("the harness's ROWS customer where name = 'the-harness-26' (JdbcTemplate): 0" in b and "  psql after: select count(*) from customer where name = 'the-harness-26' -> 0" in b, "no @Transactional: rows 0 (JdbcTemplate, psql)")
    c = blk[3]
    ok(re.search(r"the JVM's exit 0$", c[0]) is not None and "the harness's variant CustomerWritesImpl.addProbe: a transaction active on this thread: true" in c and "the harness's CALL addProbe(\"the-harness-26\") returned" in c, "@Transactional: a transaction active true, the call returned")
    ok("the harness's ROWS customer where name = 'the-harness-26' (JdbcTemplate): 1" in c and "  psql after: select count(*) from customer where name = 'the-harness-26' -> 1" in c, "@Transactional: rows 1 (JdbcTemplate, psql)")
    VALUES.append("the harness's variant: no @Transactional -> active false, InvalidDataAccessApiUsageException (TransactionRequiredException), rows 0, 3/3 · @Transactional -> active true, rows 1")


def seven(p, want):
    L = lines(p)
    for port in ("20650", "20655"):
        m = [l for l in L if re.match(r"^  exit 0 · the seven responses: 7 lines · md5 [0-9a-f]{32} · listening on %s now: 0$" % port, l)]
        ok(len(m) == 1 and want in m[0], "the seven on port %s: 7 lines, md5 = %s (read off ../c7-unit31/receipts.sh)" % (port, want))
    VALUES.append("the seven on after/ and before/: 7 lines each, md5 = the course's")


def verify(p):
    L = lines(p); t = "\n".join(L)
    ok(any(l.startswith("  the copy against after/ (diff -rq, target and secrets left out): ") and l.endswith("tiffinbox-web/src/test/java/com/tiffinbox/CustomerEntityRepositoryIT.java tiffinbox-web/src/test/java/com/tiffinbox/jdbc/CustomerAggregatesIT.java tiffinbox-web/src/test/java/com/tiffinbox/web/ElasticsearchIT.java tiffinbox-web/src/test/java/com/tiffinbox/web/MongoDatastoreIT.java tiffinbox-web/src/test/java/com/tiffinbox/web/RedisDatastoreIT.java") for l in L), "the tests' copy differs from after/ in the five IT files alone")
    ok(re.search(r"· under src/main: 0$", t, re.M) is not None, "the copy: nothing under src/main")
    ok("  the modifier, per IT file (grep -c withCreateContainerCmdModifier): CustomerEntityRepositoryIT 1 · CustomerAggregatesIT 1 · RedisDatastoreIT 1 · MongoDatastoreIT 1 · ElasticsearchIT 1" in L, "the static check: the modifier in all five IT files")
    ok(re.search(r"^  exit 0 · BUILD SUCCESS · offline: yes$", t, re.M) is not None, "mvn verify: exit 0, BUILD SUCCESS, offline")
    res = re.findall(r"^  the Results line: Tests run: (\d+), Failures: (\d+), Errors: (\d+), Skipped: (\d+)$", t, re.M)
    ok(len(res) == 2 and res[0] == ("18", "0", "0", "0") and res[1] == ("14", "0", "0", "0"), "the tests: %s" % " + ".join("%s run, %s failures, %s errors" % r[:3] for r in res))
    ok(re.search(r"^  MongoDatastoreIT: Tests run: 4, Failures: 0, Errors: 0, Skipped: 0 -- in com\.tiffinbox\.web\.MongoDatastoreIT$", t, re.M) is not None, "MongoDatastoreIT: 4 tests")
    ok("  the new test's own line: MONGO IT the fragment's totalsByCustomer(), through OrderDocuments: [CustomerTotal[customer=Ravi, total=480], CustomerTotal[customer=Sunil, total=300]]" in L, "the new test's own line: Ravi 480, Sunil 300, as CustomerTotal")
    b = [l.strip() for l in L if l.startswith("    IT BINDINGS ")]
    cls = sorted(set(x.split()[2] for x in b if len(x.split()) > 2)); hosts = re.findall(r"-> ([^:\]]+):", "\n".join(b))
    ok(len(cls) == 5 and len(b) == 5, "five IT BINDINGS lines, five distinct classes (%s)" % ", ".join(cls))
    ok(len(hosts) >= 5 and all(h == "127.0.0.1" for h in hosts), "every entry's host IP 127.0.0.1 (%d entries, not 127.0.0.1: %d)" % (len(hosts), sum(1 for h in hosts if h != "127.0.0.1")))
    ok(re.search(r"each distinct host address: 127\.0\.0\.1 · ", t) is not None, "the Testcontainers containers' ports while verify ran: 127.0.0.1 alone (dk ps)")
    ok(re.search(r"· 18881-18884 bound during it: no$", t, re.M) is not None, "18881-18884 free during verify (Compose stays off in tests)")
    m = re.search(r"ElasticsearchIT: 'Timed out waiting' lines (\d+) · its container started: (\d+) · 'Creating container for image' (\d+) · 'Pulling' (\d+) · Testcontainers containers after it: (\d+) · listening on 20578 and 20615 after it: (\d+)", t)
    ok(m is not None and m.group(1) == "0" and m.group(4) == "0" and m.group(5) == "0" and m.group(6) == "0", "ElasticsearchIT did not time out on its wait; nothing pulled; no Testcontainers container left; 20578 and 20615 free after")
    VALUES.append("tests 18 + 14, 0 failures (MongoDatastoreIT 4) · the new test Ravi 480, Sunil 300 · IT BINDINGS 5 classes, every host IP 127.0.0.1 · containers created %s · pulled 0" % (m.group(3) if m else "?"))


BROKEN = "check: the start: failed - No property 'totalsByCustomer' found for type 'OrderDocument' · the route: none · solved: no"
SOLVED = "check: the start: started · the route: Sunil 9000, Ravi 7200, Meera 4500, Priya 3600 · their sum 24300 · /kitchen's ordersValue 24300 · solved: yes"


def exercise(p, w, q):
    L = lines(p)
    ok(w == "24" and len(q.split()) == 24, "the spoken exercise line: 24 words (wc -w %s)" % w)
    for sh in ("bash", "zsh"):
        i = next((k for k, l in enumerate(L) if l.startswith("in " + sh + " (")), None)
        ok(i is not None, "the %s run is in the capture" % sh)
        if i is None: continue
        j = next((k for k in range(i, len(L)) if L[k].startswith("  then the solution's lines")), len(L))
        e = next((k for k in range(j, len(L)) if L[k].startswith("  the shell is now in:")), len(L))
        br, so = [x.strip() for x in L[i + 1:j]], [x.strip() for x in L[j + 1:e]]
        ok(br == ["built: 1 jar", BROKEN] and L[i].endswith("the block's exit 0:"), sh + ": broken - built, the start fails with No property 'totalsByCustomer' found for type 'OrderDocument', the route none, solved: no")
        ok(so == ["built: 1 jar", SOLVED], sh + ": solved - started, the four totals, their sum 24300 = /kitchen's ordersValue, solved: yes")
        ok(e < len(L) and re.search(r"listening on 20651-20656 afterwards: 0 · the exercise's containers afterwards: 0 · volumes (\d+) \(before the shell: \1\) · java processes of the exercise: 0 · images afterwards: the same list yes", L[e]) is not None, sh + ": nothing left - no listener, no container, the volumes back, no JVM, the images the same")
    runs = [k for k, l in enumerate(L) if re.match(r"^  run [123] - the block's exit \d+:$", l)]
    ok(len(runs) == 3, "the deleted-method \"solution\": three runs")
    dl = []
    for k in runs:
        blk = []
        for l in L[k + 1:]:
            if not l.startswith("    "): break
            blk.append(l.strip())
        dl.append(blk)
        nx = L[k + 1 + len(blk)] if k + 1 + len(blk) < len(L) else ""
        ok(re.search(r"listening on 20651-20656 afterwards: 0 · the exercise's containers afterwards: 0 · volumes (\d+) \(before the shell: \1\) · java processes of the exercise: 0", nx) is not None, "the deleted-method run leaves nothing")
    ref = [b for b in dl if len(b) == 2 and b[0] == "built: 0 jar" and re.match(r"^check: the start: no jar was built \(OrderTotalsImplementation\.java: .+\) · the route: none · solved: no$", b[1])]
    ok(len(ref) == 3 and dl[0] == dl[1] == dl[2], "the deleted-method \"solution\": refused 3/3 - no jar (a compile error), solved: no (%s)" % (dl[0][1][:140] if dl and len(dl[0]) > 1 else "?"))
    VALUES.append("broken: the start fails, No property 'totalsByCustomer' found for type 'OrderDocument' · solved: started, the four totals, 24300 · the deleted method refused 3/3 (no jar) · the spoken line 24 words")


def wib(p, f):
    L = lines(p)
    i = next(k for k, l in enumerate(L) if l.startswith("in bash ("))
    j = next(k for k in range(i, len(L)) if L[k].startswith("  then the solution's lines"))
    e = next(k for k in range(j, len(L)) if L[k].startswith("  the shell is now in:"))
    seg = L[i + 1:j] if f.endswith("README.md") else L[j + 1:e]
    print("\n".join(x[4:] if x.startswith("    ") else x for x in seg))


def readme(r, v):
    R = rd(r); V = rd(v).rstrip("\n")
    m = re.search(r"<!-- values: begin -->\n```text\n(.*?)\n```\n<!-- values: end -->", R, re.S)
    ok(m is not None and m.group(1) == V, "the values block = the captures' VALUES lines, byte for byte")
    caps = set()
    for f in os.listdir(U):
        if f.startswith(".r-") and f.endswith(".out"): caps.update(x.rstrip() for x in rd(os.path.join(U, f)).splitlines())
    caps.update(V.split("\n"))
    blocks = re.findall(r"```text\n(.*?)\n```", R, re.S); n = 0; bad = []
    for b in blocks:
        for l in b.split("\n"):
            n += 1
            if l.rstrip() not in caps and l.strip() != "…": bad.append(l[:100])
    ok(not bad, "every line of README.md's %d text blocks is a line a capture printed (%d lines; not found: %s)" % (len(blocks), n, bad[:3]))


def main():
    a = sys.argv[1:]; nm = a[0] if a else "?"
    try:
        if nm == "inject": inject(a[1]); return
        if nm == "wib": wib(a[1], a[2]); return
        {"static": lambda: static(a[1], a[2]), "anchor": lambda: anchor(a[1]), "composition": lambda: composition(a[1]), "misnamed": lambda: misnamed(a[1]),
         "silent": lambda: silent(a[1]), "lookup": lambda: lookup(a[1], a[2]), "why": lambda: why(a[1], a[2]), "jpatx": lambda: jpatx(a[1]),
         "seven": lambda: seven(a[1], a[2]), "verify": lambda: verify(a[1]), "exercise": lambda: exercise(a[1], a[2], a[3]), "readme": lambda: readme(a[1], a[2])}[nm]()
    except Exception as x:   # a capture this file cannot read is a FAIL with its reason, never a traceback (unit 25's defect class)
        ok(False, "%s: the checker could not read its input: %s: %s" % (nm, type(x).__name__, str(x)[:160]))
    print("VALUES " + " · ".join(VALUES))
    sys.exit(1 if FAILS else 0)


main()
