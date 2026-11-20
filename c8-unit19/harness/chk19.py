"""Unit 19's checks (python3 -I -B harness/chk19.py NAME ARGS...). Each capture's numbers are asserted against a second witness of the
same run - never a typed figure (R.423): Java's answers (TiffinBox's routes under "dev", the harness's repository, criteria find and
pipelines, the IT's lines) against mongosh's view in a container with no network (system.profile's ops, filters and pipelines; the same
pipeline run by mongosh; explain; printjson of a stored document, its keys, _class and the types; countDocuments; listDatabases) and
the driver's own DEBUG line naming the database; Docker's own records (the IT container's Ports, the volume count); Surefire's XML
against Maven's Results lines; the seven's md5 against Course 7's. Prints ok/FAIL lines and one VALUES line; exits 1 on any FAIL.
  static AFTER BEFORE   the change itself, read off the files (D2), and the harness's own rules (R.421-R.436 where a file shows them)
  r250 AFTER BEFORE     the sentences D2 made incomplete: rewritten or noted beside them, each listed
  wib CAPTURE FILE      the lines the exercise's block printed for FILE (bash's), for receipts.sh to compare with "What it prints"
  order FILE            the server's own order of each list of groups, per run (printed apart - S8.69: said, never asserted)
  exercise|anchor|finder|pipeline|explain|field|silent|twice|default|seven CAPTURE [...]"""
import hashlib, json, os, re, sys

NAME = sys.argv[1]
fails, oks, VALUES = [], [], []


def ok(c, msg):
    (oks if c else fails).append(msg)


def raw(p):
    return open(p, encoding="utf-8").read().splitlines()


def rd(t, p):
    return open(os.path.join(t, p), encoding="utf-8").read()


def one(L, rx, msg=None):
    m = [re.search(rx, l) for l in L]
    m = [x for x in m if x]
    ok(len(m) >= 1, msg or ("a line matches " + rx))
    return m[0] if m else None


def every(L, rx):
    return [m for m in (re.search(rx, l) for l in L) if m]


def slice_of(src, start, end_rx):
    i = src.index(start)
    m = re.compile(end_rx, re.M).search(src, i + len(start))
    return src[i:m.end()]


def groups(s):
    """'Sunil 9000 · Ravi 7200 · ...' -> [(name, total)]"""
    return [(a, int(b)) for a, b in re.findall(r"(\S+) (-?\d+)(?: ·|$)", s)]


def seed():
    """The four customers of after/'s V2__seed.sql: name -> (meals, price, meal type) - the factors, read off the file."""
    s = rd("after", "tiffinbox-core/src/main/resources/db/migration/V2__seed.sql")
    return {n: (int(a), int(b), t) for n, a, b, t in re.findall(r"VALUES \('(\w+)', (\d+), (\d+), '(\w+)'\)", s)}


def days(tree="after"):
    return int(re.search(r"^  days: (\d+)$", rd(tree, "tiffinbox-web/src/main/resources/application.yaml"), re.M).group(1))


W = "tiffinbox-web/src/main/java/com/tiffinbox/web/"
MIMG = "mongo@sha256:05b334b0a7a78fe913caac0cd2e1ecccf4da515d9a3a44be911b6ea3734c17cd"

if NAME == "static":
    A, B = sys.argv[2], sys.argv[3]
    s8, s9 = rd("..", "c8-unit18/harness/s818.py"), rd("harness", "s819.py")
    for nm, st, en in (("XFAM_S2", "XFAM_S2 = {\n", r"^}\n"), ("XFAM_S3 (s817's def s3)", "def s3(s, raw):\n", r"^    return out\n"),
                       ("XFAM_S4", "XFAM_S4 = {\n", r"^}\n"), ("TIMEPAT_S4 / XEXEMPT_S4 / def s4", "TIMEPAT_S4 = ", r"^    return out\n")):
        a, b = slice_of(s8, st, en), slice_of(s9, st, en)
        ok(a == b, "%s: s819.py's slice is s818.py's byte for byte (md5 %s)" % (nm, hashlib.md5(b.encode()).hexdigest()))
    od = rd(A, W + "OrderDocument.java")
    ok('@Document("orders")' in od and "record OrderDocument(@Id String id, String customer, String mealType, int day, int value)" in od, "OrderDocument: @Document(\"orders\"), a record - @Id String id, customer, mealType (a String), day, value")
    ok("@Indexed" not in od and "KitchenOrder" not in od.split("@Document")[1], "OrderDocument: no @Indexed (unit 20's); not named KitchenOrder (Redis's entity)")
    os_ = rd(A, W + "OrderDocuments.java")
    ok("interface OrderDocuments extends MongoRepository<OrderDocument, String>" in os_ and "List<OrderDocument> findByMealType(String mealType);" in os_, "OrderDocuments: a MongoRepository<OrderDocument, String> with findByMealType(String)")
    rv = rd(A, W + "Revenue.java")
    ok('@RestController\n@Profile("dev")\npublic class Revenue' in rv and 'remove(new Query(), OrderDocument.class)' in rv and "insertAll" in rv and "dropCollection" not in rv, "Revenue: @RestController @Profile(\"dev\"), reset() = remove(new Query(), OrderDocument.class), fill = insertAll, no dropCollection (R.431)")
    ok('newAggregation(OrderDocument.class, group("customer").sum("value").as("total"), sort(Sort.Direction.DESC, "total"))' in rv and 'mongo.aggregate(pipeline(), Total.class)' in rv, "Revenue: the typed pipeline - group(\"customer\").sum(\"value\").as(\"total\"), sort(DESC, \"total\") - through MongoTemplate.aggregate into Total")
    ok('@GetMapping("/revenue/by-customer")' in rv and "record Total(@Id String customer, int total)" in rv, "Revenue: GET /revenue/by-customer; Total(@Id String customer, int total)")
    sv = rd(A, W + "TiffinBoxServer.java")
    ok("ObjectProvider<Revenue> revenue" in sv and '@GetMapping("/revenue")' in sv, "TiffinBoxServer: a fourth provider, ObjectProvider<Revenue>; its own GET /revenue unchanged")
    loop = sv[sv.index("void start() throws Exception {"):sv.index("kitchen.close();")]
    ok(loop.index("copies.reset();") < loop.index("for (Customer c : repo.findAll())") < loop.index("copied.add(new OrderDocument(") < loop.index("copies.fill(copied);"), "TiffinBoxServer.start(): the reset before the loop, one OrderDocument per placed order inside it, one fill after it")
    ok('new OrderDocument(c.name() + "-" + (day + 1), order.customer(), c.mealType(), day + 1, order.value())' in loop and 'new KitchenOrder(c.name() + "-" + (day + 1),' in loop, "TiffinBoxServer.start(): the id is the kitchen order's (the same expression as KitchenOrder's), the value the placed order's")
    ok("menus.reset();" in loop and loop.index("menus.fill(") < loop.index("copies.reset();"), "TiffinBoxServer.start(): the menu's fill comes first (unit 18's), unchanged")
    sl = rd(A, "tiffinbox-web/src/test/java/slice/MongoSlice.java")
    ok("@EnableMongoRepositories(basePackageClasses = com.tiffinbox.web.OrderDocuments.class)" in sl, "MongoSlice: @EnableMongoRepositories(basePackageClasses = OrderDocuments.class) - the slice's scan names the repository's package")
    it = rd(A, "tiffinbox-web/src/test/java/com/tiffinbox/web/MongoDatastoreIT.java")
    ok(len(re.findall(r"^    @Test$", it, re.M)) == 2 and "@Autowired OrderDocuments orderDocuments;" in it and 'findByMealType("VEG")' in it and '"com.tiffinbox.web.OrderDocument"' in it, "MongoDatastoreIT: two tests - the second saves through OrderDocuments, finds by meal type, reads _class raw")
    ok(MIMG in it and 'bindIpAndPort("127.0.0.1", 20578)' in it and "withReplicaSet" not in it, "MongoDatastoreIT: the digest, 127.0.0.1:20578 (unit 18's binding), standalone")
    for f in ("pom.xml", "tiffinbox-web/pom.xml", "tiffinbox-web/src/main/resources/application.yaml", "tiffinbox-web/src/main/resources/application-dev.yaml", W + "Menus.java", W + "MenuDay.java"):
        ok(rd(A, f) == rd(B, f), "D2 leaves " + f + " as unit 18 shipped it")
    dy = rd(A, "tiffinbox-web/src/main/resources/application-dev.yaml")
    ok("auto-index-creation" not in dy, "application-dev.yaml: no auto-index-creation (unit 20's)")
    cb, ca = rd(B, "compose.yaml"), rd(A, "compose.yaml")
    ok([l for l in ca.splitlines() if not l.lstrip().startswith("#")] == [l for l in cb.splitlines() if not l.lstrip().startswith("#")] and "(Course 8, unit 19:" in ca, "compose.yaml: no service line changed, a Course 8, unit 19 note added")
    ra, rb = rd(A, "README.md"), rd(B, "README.md")
    ok("## Course 8 · unit 19 — Repositories, MongoTemplate and Aggregation" in ra, "the anchor README: its unit 19 section")
    la, lb = ra.splitlines(), set(rb.splitlines())
    gone = [l for l in rb.splitlines() if l not in set(la)]
    ok(len(gone) == 2, "the anchor README: two of unit 18's lines grown by a note, nothing else changed or gone (%d)" % len(gone))
    ex = rd("exercise", "RenamedRevenue.java")
    ok(ex.count('newAggregation(group("customer").sum("value").as("total"), sort(Sort.Direction.DESC, "total"))') == 1 and "OrderRenamed.class," not in ex and '@Field("cust") String customer' in ex and '"orders_r", Total.class' in ex,
       "exercise/RenamedRevenue.java: the broken state - @Field(\"cust\") on customer, the UNTYPED newAggregation(group(\"customer\")...) on orders_r, once")
    ok("20589" in ex and "V2__seed.sql" in ex and "days: (\\\\d+)" in ex, "exercise/RenamedRevenue.java: MongoDB on 20589; the orders from after/'s seed and tiffinbox.days, read, never typed")
elif NAME == "r250":
    A, B = sys.argv[2], sys.argv[3]
    r, c = rd(A, "README.md"), rd(A, "compose.yaml")
    sv = rd(A, W + "TiffinBoxServer.java"); sl = rd(A, "tiffinbox-web/src/test/java/slice/MongoSlice.java")
    it = rd(A, "tiffinbox-web/src/test/java/com/tiffinbox/web/MongoDatastoreIT.java")
    items = [
        ("README.md's unit 18 section, \"18 + 9 since\" - noted (Course 8, unit 19: 18 + 10)", "18 + 9 since, the one more this test *(Course 8, unit 19: 18 + 10" in r),
        ("README.md's unit 18 section, \"MongoDB's alone, so nothing is written twice\" - noted (the orders are, a copy)", "so nothing is written twice *(Course 8, unit 19: the\norders are" in r),
        ("README.md's unit 18 \"What it does not\" (/menu/day-19 404, health 200, no MongoClient) - kept, still true; unit 19's section adds /revenue/by-customer 404 and /revenue 200", "`/revenue/by-customer` and `/menu/day-19` with 404, `/revenue` and `/actuator/health` with 200" in r),
        ("compose.yaml's mongo note \"the start fills the menu and without Mongo it stops\" - kept (still true: the menu's fill comes first), a Course 8, unit 19 note beside it", "the start fills the menu and without Mongo it stops" in c and "(Course 8, unit 19: the start fills a second" in c),
        ("compose.yaml's \"MongoDB, the menu's store\" - the note names the second collection, orders", "collection too, orders - a copy of the orders it places" in c),
        ("TiffinBoxServer's unit 18 paragraphs (the menu, \"nothing here touches MongoDB\" on the default run) - kept, true; a unit 19 paragraph after each", sv.count("Course 8, unit 19:") == 2),
        ("MongoSlice's \"it holds no repository and no document\" - kept (the package still holds none), the unit 19 paragraph names the scan", "it holds no repository and no document" in sl and "Course 8, unit 19: and one more" in sl),
        ("MongoDatastoreIT's \"Two witnesses in one test\" - kept for its first test, a unit 19 paragraph for the second (18 + 10)", "Two witnesses in one test" in it and "18 + 10 under mvn verify" in it),
        ("no quote of \"Found 0 MongoDB repository interfaces\" left in the anchor as a present fact", "Found 0 MongoDB repository" not in r.replace("(`Found 0 MongoDB repository interfaces`, measured in", "")),
    ]
    for t, c_ in items:
        ok(c_, "R.250: " + t)
elif NAME == "wib":
    L = raw(sys.argv[2]); f = sys.argv[3]
    i = next(k for k, l in enumerate(L) if l.startswith("in bash "))
    j = next(k for k, l in enumerate(L) if k > i and l.startswith("  then the solution's lines"))
    e = next(k for k, l in enumerate(L) if k > j and l.startswith("  the shell is now in"))
    part = L[i + 1:j] if f.endswith("README.md") else L[j + 1:e]
    print("\n".join(l[4:] for l in part))
    sys.exit(0)
elif NAME == "order":
    L = raw(sys.argv[2])
    by = {}
    for l in L:
        m = re.match(r"(\w+) run (\d): (\w+): the order the server returned: (.*)$", l)
        if m: by.setdefault((m.group(1), m.group(3)), []).append(m.group(4))
    for (cap_, step), v in sorted(by.items()):
        print("%s's %s: the server's order %s across %d runs" % (cap_, step, "the same" if len(set(v)) == 1 else "MOVED", len(v)))
    sys.exit(0)
elif NAME == "exercise":
    L = raw(sys.argv[2]); words, line = int(sys.argv[3]), sys.argv[4]
    ok(words == 21 and len(line.split()) == 21, "the spoken exercise line: 21 words (wc -w)")
    bl = [k for k, l in enumerate(L) if l.startswith("in bash ") or l.startswith("in zsh ")]
    ok(len(bl) == 2, "two shells ran the blocks: bash, then zsh")
    sd = seed(); n = days()
    want = sorted(((c, a * b * n) for c, (a, b, t) in sd.items()), key=lambda x: (-x[1], x[0]))
    got = []
    for k in bl:
        seg = L[k:k + 40]
        j = next(i for i, l in enumerate(seg) if l.startswith("  then the solution's lines"))
        e = next(i for i, l in enumerate(seg) if l.startswith("  the shell is now in"))
        br = [re.match(r"    group (\S+) (\d+)$", l) for l in seg[1:j]]; br = [(m.group(1), int(m.group(2))) for m in br if m]
        so = [re.match(r"    group (\S+) (\d+)$", l) for l in seg[j + 1:e]]; so = [(m.group(1), int(m.group(2))) for m in so if m]
        ok(len(br) == 1 and br[0][0] == "null", "R.196: the broken state prints exactly one group, its _id null (%s)" % br)
        ok(so == want, "R.196: the solved state prints the four named groups, sorted by total then name, = the seed's meals x price x days %s" % want)
        ok(len(br) == 1 and sum(t for _, t in so) == br[0][1], "the solved groups' sum = the broken state's one total (%s)" % (br[0][1] if br else "?"))
        ok(seg[0].endswith("the block's exit 0:") and "the block's exit 0:" in seg[j], "both blocks ran to their end (exit 0 - never the check)")
        ok(re.search(r"listening on 20589 afterwards: 0 · the container c8u19-mongo-ex afterwards: 0 · volumes (\d+) \(before the shell: \1\)", seg[e]) is not None, "the exercise's container is gone, removed with its volumes; nothing listens on 20589")
        got.append((br, so))
    ok(len(got) == 2 and got[0] == got[1], "bash and zsh print the same")
    if got and got[0][0]:
        VALUES.append("broken: one group, %s %d; solved: %s" % (got[0][0][0][0], got[0][0][0][1], " · ".join("%s %d" % x for x in got[0][1])))
elif NAME == "anchor":
    L = raw(sys.argv[2]); T = "\n".join(L)
    sd = seed(); n = days()
    m = one(L, r"Surefire's Results line: Tests run: (\d+), Failures: 0, Errors: 0, Skipped: 0$")
    res = every(L, r"Surefire's Results line: Tests run: (\d+), Failures: 0, Errors: 0, Skipped: 0$")
    ok(len(res) == 3 and int(res[0].group(1)) == 18 and int(res[1].group(1)) == 18 and int(res[2].group(1)) == 10, "the tests: package 18 (Docker at nothing), verify 18 + 10 (Surefire's Results lines)")
    sf = every(L, r"^  (\d+) tests? in (\d+) files?")
    ok(one(L, r"Ports 127\.0\.0\.1:20578->27017/tcp · its command") is not None, "the IT's container: 127.0.0.1:20578->27017/tcp, Docker's own record (R.454's shape)")
    ok(one(L, r"MONGO IT the container's port bindings \(Docker's own record\): \[127\.0\.0\.1:20578->27017/tcp\]$") is not None, "the IT's own reading of its binding: 127.0.0.1:20578 alone")
    ok(one(L, r"MONGO IT orders, through OrderDocuments: count 3 · findByMealType\(\"VEG\"\) \[Ravi-1, Sunil-1\]$") is not None and
       one(L, r"MONGO IT Ravi-1, through the driver's collection: _id String · _class com\.tiffinbox\.web\.OrderDocument · mealType VEG · value 240$") is not None, "the IT's second test: two witnesses - the derived finder and the raw document")
    ok(one(L, r"the verify log's MongoDB repository line \(the slice's scan\): \(x1\) Found 1 MongoDB repository interface$") is not None, "the test log: Found 1 MongoDB repository interface (the slice's scan)")
    ok(one(L, r"before it: listening on 20578 \(the anchor IT's pinned binding\): 0$") is not None and one(L, r"listening on 20578 after it: 0$") is not None, "20578 unbound before verify and after it")
    ok(one(L, r"the package log: lines naming 27017 0 · lines naming mongo \(any case\) 0$") is not None, "mvn package with Docker at nothing: 0 lines name 27017 or mongo")
    lb = every(L, r"^  (before|after)/: (\d+) libraries$")
    ok(len(lb) == 2 and lb[0].group(2) == lb[1].group(2), "the libraries: before/ and after/ the same count (D2 adds no dependency)")
    ok(one(L, r"gained: 0 · lost: 0$") is not None, "no jar gained or lost")
    for v in ("spring-boot-4.1.2.jar", "spring-data-mongodb-5.1.2.jar", "mongodb-driver-sync-5.8.1.jar"):
        ok(v in T, "the version line: " + v)
    for v in (r"HHH000001: Hibernate ORM core version 7\.4\.13\.Final", r"\(PostgreSQL 18\.6\)", r"redis_version:8\.10\.3", r"db\.version\(\) 8\.3\.17", r"db version v8\.3\.17", r"show server_version 18\.6"):
        ok(re.search(v, T) is not None, "the version line: " + v.replace("\\", ""))
    strict = every(L, r"^    \(x(\d+)\) (.*)$")
    st = {s.group(2): int(s.group(1)) for s in strict}
    ok(st.get("Multiple Spring Data modules found, entering strict repository configuration mode") == 4, "strict mode: four modules each print 'Multiple Spring Data modules found' (x4)")
    for mod, kind in (("Redis", "Redis"), ("JPA", "JPA"), ("JDBC", "JDBC"), ("MongoDB", "MongoDB")):
        ok(st.get("Finished Spring Data repository scanning in <t>. Found 1 %s repository interface." % kind) == 1, "strict mode: Found 1 %s repository interface" % kind)
    cn = [k for k in st if "Could not safely identify store assignment for repository candidate interface com.tiffinbox.web.OrderDocuments" in k]
    ok(sorted(re.match(r"Spring Data (\w+) ", k).group(1) for k in cn) == ["JPA", "Redis"], "strict mode: JPA and Redis each print 'could not safely identify' about OrderDocuments (JDBC scans com.tiffinbox.jdbc only): %s" % sorted(re.match(r"Spring Data (\w+) ", k).group(1) for k in cn))
    ok(one(L, r"\(x1\) tiffinbox: kitchen value: +(\d+)$") is not None and one(L, r"\(x1\) tiffinbox: orders cooked: +(\d+)$") is not None, "the start's kitchen value and orders cooked lines")
    kv = int(one(L, r"tiffinbox: kitchen value: +(\d+)$").group(1)); oc = int(one(L, r"tiffinbox: orders cooked: +(\d+)$").group(1))
    ok(one(L, r"\(x2\) Command \"insert\" started on database \"tiffinbox\"$") is not None and one(L, r"\(x2\) Command \"delete\" started on database \"tiffinbox\"$") is not None, "the driver's DEBUG lines: two deletes and two inserts on the database tiffinbox (the menu's, the orders')")
    ops = every(L, r"^    op (\w+)(.*)$")
    ok([o.group(1) for o in ops] == ["remove", "insert"], "system.profile on tiffinbox.orders after the start: one remove, then one insert (%s)" % [o.group(1) for o in ops])
    nins = re.search(r"ninserted (\d+)", ops[1].group(2)).group(1) if len(ops) > 1 and "ninserted" in ops[1].group(2) else None
    fac = re.search(r"customers in the database (\d+) · tiffinbox\.days in after/'s application\.yaml (\d+)$", T, re.M)
    ok(fac is not None and int(fac.group(1)) == len(sd) and int(fac.group(2)) == n, "the factors, read by the receipt: %d customers, days %d" % (len(sd), n))
    cnt = one(L, r"db\.orders\.countDocuments\(\) -> (\d+) · per customer -> (.*) · db\.menu\.countDocuments\(\) -> (\d+)$")
    want_n = len(sd) * n
    ok(cnt is not None and int(cnt.group(1)) == want_n and nins == str(want_n) and oc == want_n, "120 derived: customers x days = %d = countDocuments = the insert op's ninserted = orders cooked" % want_n)
    ok(cnt is not None and groups(cnt.group(2)) == [(c, n) for c in sorted(sd)], "per customer: each customer's days in orders")
    ok(cnt is not None and int(cnt.group(3)) == n, "db.menu.countDocuments() = days (unit 18's menu, unchanged)")
    want = sorted(((c, a * b * n) for c, (a, b, t) in sd.items()), key=lambda x: (-x[1], x[0]))
    agg = one(L, r"db\.orders\.aggregate\(.*\) -> groups 4 · sorted by total, then _id: (.*) · their sum (\d+)$")
    ok(agg is not None and groups(agg.group(1)) == want, "mongosh's pipeline: the four, = the seed's meals x price x days %s" % want)
    rv = one(L, r"GET /revenue/by-customer -> 200 (\[.*\])$")
    rj = json.loads(rv.group(1)) if rv else []
    ok([(x["customer"], x["total"]) for x in rj] == want, "GET /revenue/by-customer 200: the four, in the route's order (distinct totals)")
    kj = one(L, r"GET /kitchen -> 200 (\{.*\})$"); kd = json.loads(kj.group(1)) if kj else {}
    rs = sum(x["total"] for x in rj)
    ok(kd.get("ordersValue") == rs == kv == int(agg.group(2) if agg else -1), "the sum of the four (%d) = /kitchen's ordersValue = the start's kitchen value = mongosh's sum" % rs)
    mr = one(L, r"GET /revenue -> 200 \{\"monthRevenue\":(\d+)\}$")
    ok(one(L, r"GET /menu/day-19 -> 200 ") is not None and one(L, r"GET /actuator/health -> 200 ") is not None and one(L, r"GET /dashboard -> 200$") is not None, "GET /menu/day-19, /actuator/health, /dashboard 200 under dev")
    ok(one(L, r"its keys _id,customer,mealType,day,value,_class · typeof _id string · typeof mealType string · _class com\.tiffinbox\.web\.OrderDocument$") is not None, "the stored Ravi-19: keys _id, customer, mealType, day, value, _class; _id and mealType Strings; _class the full class name")
    ok(one(L, r"listDatabases -> admin,config,local,tiffinbox · that container's interfaces \(its /proc/net/dev, read by mongosh\): lo$") is not None, "listDatabases: tiffinbox, no test; mongosh's container: lo only")
    cw = one(L, r"the start's lines: (.*)$")
    ok(one(L, r"the project's containers: tiffinbox-dev-mongo-1 127\.0\.0\.1:18883->27017/tcp\|tiffinbox-dev-postgres-1 127\.0\.0\.1:18881->5432/tcp\|tiffinbox-dev-redis-1 127\.0\.0\.1:18882->6379/tcp$") is not None, "the Compose window: the three services on 18881-18883, 127.0.0.1")
    cr = one(L, r"^  GET /revenue/by-customer -> 200 (\[.*\])$")
    crs = [m for m in every(L, r"^  GET /revenue/by-customer -> 200 (\[.*\])$")]
    ok(len(crs) == 2 and crs[0].group(1) == crs[1].group(1), "the Compose window's /revenue/by-customer = the dev start's (the four)")
    ok(one(L, r"Command \"insert\" started on database \"tiffinbox\"") is not None and re.search(r'2 Command "insert" started on database "tiffinbox"', T) is not None, "the Compose window: the driver names the database tiffinbox")
    ok(one(L, r"listDatabases -> admin,config,local,tiffinbox · on tiffinbox: db\.orders\.countDocuments\(\) -> %d · db\.menu\.countDocuments\(\) -> %d · on test: orders -> 0$" % (want_n, n)) is not None, "the Compose window, mongosh: tiffinbox (no test), orders 120, menu 30")
    ok(one(L, r"then: volumes (\d+) · tiffinbox-dev volumes by name: 0 · the mongo service's two: present present$") is not None, "the Compose window: down -v leaves the mongo service's two anonymous volumes (unit 18's measure, again)")
    vv = one(L, r"volumes (\d+) = before the window")
    VALUES.append("tests 18 + 10 (package 18); Ports 127.0.0.1:20578->27017/tcp; Found 1 MongoDB repository interface (dev and the slice); could not safely identify OrderDocuments: JPA, Redis; countDocuments %d = %d customers x %d days; revenue/by-customer %s, sum %d = ordersValue = kitchen value; menu %d; listDatabases tiffinbox, no test; Compose window the same four, volumes back to %s"
                  % (want_n, len(sd), n, " · ".join("%s %d" % x for x in want), rs, n, vv.group(1) if vv else "?"))
elif NAME == "finder":
    L = raw(sys.argv[2]); sd = seed(); n = days()
    veg = sorted(c for c, (a, b, t) in sd.items() if t == "VEG"); want = len(veg) * n
    f = one(L, r"findByMealType\(\"VEG\"\), once -> (\d+) documents · per customer \{(.*)\}$")
    ok(f is not None and int(f.group(1)) == want, "the derived finder: %d = the VEG customers (%s) x days" % (want, veg))
    ok(f is not None and f.group(2) == ", ".join("%s=%d" % (c, n) for c in veg), "per customer: the VEG customers, days each")
    c = one(L, r"Criteria\.where\(\"mealType\"\)\.is\(\"VEG\"\)\), OrderDocument\.class\), once -> (\d+) documents$")
    ok(c is not None and int(c.group(1)) == want, "the criteria find: the same count")
    i1 = next(i for i, l in enumerate(L) if l.startswith("  system.profile, mongosh"))
    i2 = next(i for i, l in enumerate(L) if l.startswith("  system.profile again"))
    a = [l for l in L[i1:i2] if l.startswith("    op ")]; b = [l for l in L[i2:] if l.startswith("    op ")]
    exp = '    op query · ns tiffinbox.orders · command find "orders" · filter {"mealType":"VEG"} · nreturned %d' % want
    ok(a == [exp], "system.profile after the finder: ONE query op, find orders, filter {mealType: VEG}, nreturned %d" % want)
    ok(b == [exp, exp], "system.profile after the criteria find too: TWO query ops, the same filter - the same find")
    ok(one(L, r"^    ops 2 · getmore ops 0$") is not None, "no getmore op: %d documents fit the first batch" % want)
    m = one(L, r"the customers whose orders are VEG, with their counts -> (.*) · countDocuments\(\{mealType: \"VEG\"\}\) -> (\d+)$")
    ok(m is not None and groups(m.group(1)) == [(x, n) for x in veg] and int(m.group(2)) == want, "mongosh: the VEG customers and countDocuments - the second witness")
    ok(len(every(L, r"its exit 0 · .* lines naming an Exception 0$")) == 2, "the harness JVMs: exit 0, no Exception")
    VALUES.append("findByMealType(VEG) %d (%s x %d days), 1 query op filter {mealType: VEG}; criteria find %d, 2 query ops the same filter; getmore 0" % (want, " + ".join(veg), n, want))
elif NAME == "pipeline":
    L = raw(sys.argv[2]); A = raw(sys.argv[3]); sd = seed(); n = days()
    want = sorted(((c, a * b * n) for c, (a, b, t) in sd.items()), key=lambda x: (-x[1], x[0]))
    st = one(L, r"PROBE pipeline: the stages the template sends \(toPipeline\): (.*)$")
    ok(st is not None and st.group(1) == '{"$group": {"_id": "$customer", "total": {"$sum": "$value"}}}, {"$sort": {"total": -1}}', "the stages as the template builds them: $group by $customer, $sum of $value; $sort total -1")
    g = one(L, r"PROBE pipeline: groups 4 · sorted by total, then _id: (.*) · their sum (\d+)$")
    ok(g is not None and groups(g.group(1)) == want, "the harness's pipeline: the four, = the seed's meals x price x days")
    ops = [l for l in L if l.startswith("    op ")]
    ok(ops == ['    op command · ns tiffinbox.orders · command aggregate · pipeline [{"$group":{"_id":"$customer","total":{"$sum":"$value"}}},{"$sort":{"total":-1}}] · nreturned 4'], "system.profile: ONE op on tiffinbox.orders, op command (the server's name for an aggregate), the pipeline as received")
    ms = one(L, r"mongosh, the same stages: .* -> groups 4 · sorted by total, then _id: (.*) · their sum (\d+)$")
    ok(ms is not None and groups(ms.group(1)) == want and g is not None and ms.group(2) == g.group(2), "mongosh's same pipeline: the same four, the same sum - the second witness")
    kj = [re.search(r"GET /kitchen -> 200 (\{.*\})$", l) for l in A]; kj = [k for k in kj if k]
    ov = json.loads(kj[0].group(1))["ordersValue"] if kj else None
    ok(g is not None and int(g.group(2)) == ov, "the sum (%s) = /kitchen's ordersValue in this run's anchor (%s)" % (g.group(2) if g else "?", ov))
    ok(len(set(t for _, t in want)) == 4, "the four totals are distinct: no tie to order")
    VALUES.append("%s, sum %s = ordersValue; 1 command op (aggregate) with $group/$sort as sent; mongosh the same four" % (" · ".join("%s %d" % x for x in want), g.group(2) if g else "?"))
elif NAME == "explain":
    L = raw(sys.argv[2]); sd = seed(); n = days(); N = len(sd) * n
    e = every(L, r"read at (.*) · queryPlanner\.winningPlan stages (.*) · executionStats: nReturned (\d+) · totalDocsExamined (\d+) · totalKeysExamined (\d+) · stages of the pipeline (.*)$")
    ok(len(e) == 2, "two explains printed")
    for x, nm in zip(e, ("the plain group", "with $match VEG")):
        ok("COLLSCAN" in x.group(2) and "IXSCAN" not in x.group(2), "%s: the plan's stages hold COLLSCAN, no IXSCAN (%s)" % (nm, x.group(2)))
        ok(int(x.group(4)) == N and int(x.group(5)) == 0, "%s: totalDocsExamined %d, totalKeysExamined 0" % (nm, N))
    ok(one(L, r'db\.orders\.getIndexes\(\) -> \["_id_"\] · db\.orders\.countDocuments\(\) -> %d$' % N) is not None, "getIndexes: [\"_id_\"] only; the collection holds %d" % N)
    VALUES.append("COLLSCAN, totalDocsExamined %d, totalKeysExamined 0 (both); getIndexes [\"_id_\"]" % N)
elif NAME == "field":
    L = raw(sys.argv[2]); sd = seed(); n = days(); N = len(sd) * n
    want = sorted(((c, a * b * n) for c, (a, b, t) in sd.items()), key=lambda x: (-x[1], x[0]))
    ok(one(L, r"PROBE copy: the harness's copy - orders read \(findAll, OrderDocument\) %d · saved into orders_r as OrderRenamed \(@Field\(\"cust\"\) on customer\) -> count %d$" % (N, N)) is not None, "the harness's copy: %d read, %d saved into orders_r" % (N, N))
    ok(one(L, r"its keys _id,cust,mealType,day,value,_class · the shipped orders' Ravi-19, its keys _id,customer,mealType,day,value,_class · db\.orders_r\.countDocuments\(\) -> %d · db\.orders\.countDocuments\(\) -> %d$" % (N, N)) is not None, "mongosh: the copy stores cust, the shipped orders customer; both collections %d" % N)
    ok(one(L, r"^    +cust: 'Ravi',$") is not None and one(L, r"^    +_class: 'probe\.u19\.OrderRenamed'$") is not None, "printjson of the copy's Ravi-19: cust, _class probe.u19.OrderRenamed")
    g = one(L, r"PROBE typedr: groups 4 · sorted by total, then _id: (.*) · their sum (\d+)$")
    ok(g is not None and groups(g.group(1)) == want, "the typed pipeline on the copy: the four")
    ok(one(L, r'^    op command · ns tiffinbox\.orders_r · pipeline \[\{"\$group":\{"_id":"\$cust","total":\{"\$sum":"\$value"\}\}\},\{"\$sort":\{"total":-1\}\}\] · nreturned 4$') is not None, "system.profile: the typed pipeline as the server received it groups on $cust - the mapper's rename")
    VALUES.append("the harness's copy stores cust; the typed pipeline sends $cust and answers the four")
elif NAME == "silent":
    L = raw(sys.argv[2]); sd = seed(); n = days()
    want = sorted(((c, a * b * n) for c, (a, b, t) in sd.items()), key=lambda x: (-x[1], x[0])); S = sum(t for _, t in want)
    z = one(L, r"PROBE summeal: groups 4 · sorted by total, then _id: (.*) · their sum (\d+)$")
    ok(z is not None and groups(z.group(1)) == [(c, 0) for c in sorted(sd)], "(a) $sum over a String: every total 0 (sorted by total, then _id)")
    ok(one(L, r'PROBE summeal: the stages the template sends \(toPipeline\): \{"\$group": \{"_id": "\$customer", "total": \{"\$sum": "\$mealType"\}\}\}') is not None, "(a) the stage as sent: $sum of $mealType")
    c = one(L, r"PROBE pipeline: groups 4 · sorted by total, then _id: (.*) · their sum (\d+)$")
    ok(c is not None and groups(c.group(1)) == want, "(a)'s control, sum(value), the same run: the four")
    mz = one(L, r"\$sum: \"\$mealType\".* -> groups 4 · sorted by total, then _id: (.*) · their sum 0 · typeof mealType string$")
    ok(mz is not None and groups(mz.group(1)) == [(x, 0) for x in sorted(sd)], "(a) mongosh's same stage: every total 0; mealType a string - the second witness")
    u = one(L, r"PROBE untypedr: groups (\d+) · sorted by total, then _id: (.*) · their sum (\d+)$")
    ok(u is not None and u.group(1) == "1" and groups(u.group(2)) == [("null", S)], "(b) the untyped pipeline on the renamed copy: ONE group, null, %d" % S)
    t = one(L, r"PROBE typedr: groups 4 · sorted by total, then _id: (.*) · their sum (\d+)$")
    ok(t is not None and groups(t.group(1)) == want and int(t.group(2)) == S, "(b)'s control, the typed pipeline, the same run: the four, sum %d" % S)
    ok(one(L, r'db\.orders_r\.aggregate\(.*\) -> \[\{"_id":null,"total":%d\}\] · documents in orders_r with a field customer 0 · with cust %d$' % (S, len(sd) * n)) is not None, "(b) mongosh's same stage on the copy: [{_id: null, total: %d}] - no document has customer, every one has cust" % S)
    ex = every(L, r"its exit (\d+) · its log, every line but its PROBE lines: \d+ · lines naming an Exception (\d+)$")
    ok(len(ex) == 2 and all(x.group(1) == "0" and x.group(2) == "0" for x in ex), "no exception: the harness JVMs exit 0, 0 lines naming an Exception (R.396's negation)")
    VALUES.append("sum(mealType): every total 0 beside sum(value)'s four; untyped on the renamed copy: one group null %d beside the typed four; exit 0, 0 Exception lines" % S)
elif NAME == "twice":
    L = raw(sys.argv[2]); sd = seed(); n = days(); N = len(sd) * n
    cnts = every(L, r"mongosh \(no network\): orders countDocuments\(\) (\d+) · menu countDocuments\(\) (\d+) · Ravi-19 as stored, its md5 ([0-9a-f]{32})$")
    ok(len(cnts) == 4, "four starts read by mongosh")
    rv = every(L, r"GET /revenue/by-customer -> 200 · its body's md5 ([0-9a-f]{32}) · GET /kitchen -> 200 (\{.*\})$")
    if len(cnts) == 4:
        ok(int(cnts[0].group(1)) == N and int(cnts[1].group(1)) == N, "after/'s two starts: orders %d both times" % N)
        ok(cnts[0].group(3) == cnts[1].group(3), "after/'s two starts: the same Ravi-19 stored")
        ok(int(cnts[2].group(1)) == N, "the copy's first start (on an emptied collection): %d" % N)
        ok(int(cnts[3].group(1)) == N, "the copy's second start: the count unchanged, %d (the insert refused)" % N)
    ok(len(rv) == 3 and rv[0].group(1) == rv[1].group(1) and rv[0].group(2) == rv[1].group(2), "after/'s two starts: the same /revenue/by-customer (md5) and /kitchen")
    ok(one(L, r"the JVM stopped by itself: exit 1 · listening on 20580: 0$") is not None, "the copy's second start stops: exit 1, nothing listens")
    d = one(L, r"DuplicateKeyException ([1-9]\d*) · E11000 ([1-9]\d*) · the duplicate id named: E11000 duplicate key error collection: tiffinbox\.orders index: _id_ dup key: \{ _id: \"(\w+-\d+)\" \} · Application run failed ([1-9]\d*)$")
    ok(d is not None, "the copy's second start: DuplicateKeyException, E11000 on tiffinbox.orders' _id_, the id named, Application run failed")
    ok(one(L, r"deletedCount %d$" % N) is not None, "the copy's window starts from an emptied collection: deleteMany -> %d (never a drop)" % N)
    VALUES.append("%d / %d, the same /revenue/by-customer; the copy without the reset: the second start stops, E11000 on %s, exit 1, count %d" % (N, N, d.group(3) if d else "?", N))
elif NAME == "default":
    L = raw(sys.argv[2])
    ok(one(L, r"GET /actuator/health -> 200 ") is not None, "the default run: health 200")
    m = one(L, r"GET /revenue/by-customer -> 404 · GET /menu/day-19 -> 404 · GET /revenue -> 200 \{\"monthRevenue\":(\d+)\} · GET /kitchen -> 200 \{\"ordersCooked\":(\d+),\"ordersValue\":(\d+)\} · GET /dashboard -> 200$")
    ok(m is not None, "the default run: /revenue/by-customer 404, /menu/day-19 404, /revenue 200, /kitchen 200, /dashboard 200")
    ok(one(L, r"a bean named revenue 0 · orderDocuments 0 · menus 0 · a MongoClient bean 0 · tiffinBoxServer [1-9]") is not None, "/actuator/beans: no Revenue, OrderDocuments, Menus or MongoClient bean")
    ok(one(L, r"its log: lines naming 27017 0 · lines naming mongo, any case 0 · ") is not None, "the default run's log: 0 lines name 27017 or mongo - it builds no MongoClient")
    ok(one(L, r"Surefire's Results line: Tests run: 18, Failures: 0, Errors: 0, Skipped: 0$") is not None, "the 18 under mvn package, Docker at nothing")
    sd = seed(); n = days()
    ov = sum(a * b * n for a, b, t in sd.values())
    ok(m is not None and int(m.group(3)) == ov, "the default run's /kitchen ordersValue on H2 = the seed's meals x price x days (%d)" % ov)
    VALUES.append("health 200, /revenue/by-customer 404, /menu/day-19 404, /revenue 200 monthRevenue %s, ordersValue %s, 0 lines naming 27017 or mongo, no Revenue/OrderDocuments bean" % (m.group(1) if m else "?", m.group(3) if m else "?"))
elif NAME == "seven":
    L = raw(sys.argv[2]); want = sys.argv[3]
    ok(one(L, r"cmp with xcheck\.sql \(= Course 7's capstone's\): the same, byte for byte$") is not None, "Hibernate's script = xcheck.sql (no JPA mapping moved)")
    md = re.findall(r"the seven responses: (\d+) lines · md5 ([0-9a-f]{32})", "\n".join(L))
    ok(len(md) == 2 and md[0] == md[1] and md[0][1] == want, "the seven on before/ and after/: the same md5, Course 7's %s" % want)
    ok(one(L, r"lines that differ: 0$") is not None, "the seven: before/ and after/ answer the same")
    ok(len([l for l in L if "GET /revenue/by-customer -> 404" in l]) == 2, "the default run on both trees: /revenue/by-customer 404")
    VALUES.append("the seven: md5 %s on before/ and after/" % (md[0][1] if md else "?"))
else:
    print("FAIL unknown check " + NAME); sys.exit(1)

for m in oks: print("ok " + m)
for m in fails: print("FAIL " + m)
if VALUES: print("VALUES " + " · ".join(VALUES))
sys.exit(1 if fails else 0)
