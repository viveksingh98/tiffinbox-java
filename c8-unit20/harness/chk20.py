"""Unit 20's checks (python3 -I -B harness/chk20.py NAME ARGS...). Each capture's numbers are asserted against a second witness of the
same run - never a typed figure (R.423): Java's answers (TiffinBox's routes under "dev", the harness's counts, ids and exceptions, the
mapper's IndexOperations, the driver's ClusterDescription, the IT's lines) against mongosh's view in a container with no network
(getIndexes, explain, system.profile's ops, hello, rs.status, the stored documents, countDocuments, listDatabases) and the driver's own
DEBUG line naming the database; Docker's own records (the IT container's Ports, the replica set's port, the volume count); Surefire's
XML against Maven's Results lines; the seven's md5 against Course 7's. The factors - the customers, tiffinbox.days, the first
customer's name - are read off after/'s files, never typed. Prints ok/FAIL lines and one VALUES line; exits 1 on any FAIL.
  static AFTER BEFORE   the change itself, read off the files (D3), and the harness's own rules (R.421-R.436 where a file shows them)
  r250 AFTER BEFORE     the sentences D3 made false or incomplete: rewritten or noted beside them, each listed
  wib CAPTURE FILE      the lines the exercise's block printed for FILE (bash's), for receipts.sh to compare with "What it prints"
  exercise|noindex|anchor|index|tx|notone|advertised|unique|shapes|default|seven CAPTURE [...]"""
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


def find(L, rx):
    for l in L:
        m = re.search(rx, l)
        if m: return m
    return None


def every(L, rx):
    return [m for m in (re.search(rx, l) for l in L) if m]


def slice_of(src, start, end_rx):
    i = src.index(start)
    m = re.compile(end_rx, re.M).search(src, i + len(start))
    return src[i:m.end()]


def groups(s):
    return [(a, int(b)) for a, b in re.findall(r"(\S+) (-?\d+)(?: ·|$)", s)]


def seed():
    s = rd("after", "tiffinbox-core/src/main/resources/db/migration/V2__seed.sql")
    return [(n, int(a), int(b), t) for n, a, b, t in re.findall(r"VALUES \('(\w+)', (\d+), (\d+), '(\w+)'\)", s)]


def days(tree="after"):
    return int(re.search(r"^  days: (\d+)$", rd(tree, "tiffinbox-web/src/main/resources/application.yaml"), re.M).group(1))


W = "tiffinbox-web/src/main/java/com/tiffinbox/web/"
MIMG = "mongo@sha256:05b334b0a7a78fe913caac0cd2e1ecccf4da515d9a3a44be911b6ea3734c17cd"
SD = seed(); N = days(); FC = SD[0][0]; NO = len(SD) * N
EX = re.compile(r"queryPlanner\.winningPlan ([A-Z >]+) · executionStats\.executionStages ([A-Z >]+) · nReturned (\d+) · totalKeysExamined (\d+) · totalDocsExamined (\d+)$")


def plan(m):
    return (m.group(1), m.group(2), int(m.group(3)), int(m.group(4)), int(m.group(5))) if m else None


if NAME == "static":
    A, B = sys.argv[2], sys.argv[3]
    s8, s0 = rd("..", "c8-unit18/harness/s818.py"), rd("harness", "s820.py")
    for nm, st, en in (("XFAM_S2", "XFAM_S2 = {\n", r"^}\n"), ("XFAM_S3 (s817's def s3)", "def s3(s, raw):\n", r"^    return out\n"),
                       ("XFAM_S4", "XFAM_S4 = {\n", r"^}\n"), ("TIMEPAT_S4 / XEXEMPT_S4 / def s4", "TIMEPAT_S4 = ", r"^    return out\n")):
        a, b = slice_of(s8, st, en), slice_of(s0, st, en)
        ok(a == b, "%s: s820.py's slice is s818.py's byte for byte (md5 %s)" % (nm, hashlib.md5(b.encode()).hexdigest()))
    s9 = rd("..", "c8-unit19/harness/s819.py")
    ok(slice_of(s9, "XU19 = {\n", r"^}\n") == slice_of(s0, "XU19 = {\n", r"^}\n"), "XU19: s820.py carries unit 19's block byte for byte")
    od = rd(A, W + "OrderDocument.java")
    ok("import org.springframework.data.mongodb.core.index.Indexed;" in od and "record OrderDocument(@Id String id, @Indexed String customer, String mealType, int day, int value)" in od, "OrderDocument: @Indexed on customer (org.springframework.data.mongodb.core.index.Indexed), the record otherwise unit 19's")
    ok("unique" not in od.split("@Document(")[1] and od.count("@Indexed") == 3, "OrderDocument: @Indexed not unique (four customers share the orders); the annotation once on the record, twice named in the Javadoc")
    ok("No index but the one on _id" not in od and "auto-index-creation" in od and "Course 8, unit 20:" in od, "OrderDocument's Javadoc: the false sentence gone, a unit 20 paragraph naming the key")
    dy, dyb = rd(A, "tiffinbox-web/src/main/resources/application-dev.yaml"), rd(B, "tiffinbox-web/src/main/resources/application-dev.yaml")
    ok("  data:\n    mongodb:\n      auto-index-creation: true\n" in dy and dy.count("auto-index-creation: true") == 1 and "# Course 8, unit 20:" in dy, "application-dev.yaml: spring.data.mongodb.auto-index-creation: true, under spring, with its comment")
    ok([l for l in dy.splitlines() if not l.startswith("  data:") and l not in ("    mongodb:", "      auto-index-creation: true") and not l.lstrip().startswith("#")] == [l for l in dyb.splitlines() if not l.lstrip().startswith("#")], "application-dev.yaml: no other key changed")
    it = rd(A, "tiffinbox-web/src/test/java/com/tiffinbox/web/MongoDatastoreIT.java")
    ok(len(re.findall(r"^    @Test$", it, re.M)) == 3 and "template.indexOps(OrderDocument.class).getIndexInfo()" in it and '"explain"' in it and 'contains("IXSCAN")' in it, "MongoDatastoreIT: three tests - the third names the index (IndexOperations) and reads explain's IXSCAN (the driver's runCommand)")
    ok(MIMG in it and 'bindIpAndPort("127.0.0.1", 20578)' in it and "withReplicaSet" not in it and "--replSet" not in it and '@ActiveProfiles("dev")' in it, "MongoDatastoreIT: the digest, 127.0.0.1:20578 (R.454), standalone - no replica set (S8.62, flag 10), under dev")
    for f in ("pom.xml", "tiffinbox-web/pom.xml", "tiffinbox-web/src/main/resources/application.yaml", W + "OrderDocuments.java", W + "Revenue.java", W + "TiffinBoxServer.java", W + "Menus.java", W + "MenuDay.java", "tiffinbox-web/src/test/java/slice/MongoSlice.java"):
        ok(rd(A, f) == rd(B, f), "D3 leaves " + f + " as unit 19 shipped it")
    cb, ca = rd(B, "compose.yaml"), rd(A, "compose.yaml")
    ok([l for l in ca.splitlines() if not l.lstrip().startswith("#")] == [l for l in cb.splitlines() if not l.lstrip().startswith("#")] and "(Course 8, unit 20: still a standalone" in ca, "compose.yaml: no service line changed, a Course 8, unit 20 note added")
    ra, rb = rd(A, "README.md"), rd(B, "README.md")
    ok("## Course 8 · unit 20 — Mongo Transactions, Indexes and Schema Design" in ra and "**Section 4 Part A ends here.**" in ra, "the anchor README: its unit 20 section, and Part A's closing paragraph")
    gone = [l for l in rb.splitlines() if l not in set(ra.splitlines())]
    ok(len(gone) == 2, "the anchor README: two of unit 19's lines grown by a note, nothing else changed or gone (%d)" % len(gone))
    ex = rd("exercise", "IndexedOrders.java")
    ok("import com.tiffinbox.web.OrderDocument;" in ex and "auto-index-creation" not in ex and "20599" in ex and "V2__seed.sql" in ex and "days: (\\\\d+)" in ex and "listIndexes" in ex and '"explain"' in ex,
       "exercise/IndexedOrders.java: the shipped OrderDocument, the key never in the file (the command line is the solution), MongoDB on 20599, the orders from after/'s seed and tiffinbox.days, getIndexes then explain")
    h = rd("harness", "src/probe/u20/H20.java")
    ok(h.count("replicaSet=rs0") == 1 and "withReplicaSet" not in h and "dropCollection" not in h, "H20: replicaSet=rs0 once (topo replicaset), no withReplicaSet, no dropCollection")
    ok('"tx_docs"' in h and "JpaTransactionManager(emf)" in h and "new MongoTransactionManager(f)" in h and 'IllegalStateException("PLANTED between the two writes")' in h, "H20: the planted pair in its own collection tx_docs; one manager per context - JpaTransactionManager or MongoTransactionManager")
    ok("@org.springframework.data.mongodb.core.mapping.DocumentReference Cust customer" in h and "@org.springframework.data.mongodb.core.mapping.DBRef Cust customer" in h and '@org.springframework.data.mongodb.core.mapping.Document("orders_emb")' in h, "H20: the three shapes in their own collections - embedded, @DocumentReference, @DBRef")
elif NAME == "r250":
    A, B = sys.argv[2], sys.argv[3]
    r, c = rd(A, "README.md"), rd(A, "compose.yaml")
    od = rd(A, W + "OrderDocument.java"); it = rd(A, "tiffinbox-web/src/test/java/com/tiffinbox/web/MongoDatastoreIT.java")
    items = [
        ("OrderDocument's Javadoc \"No index but the one on _id: unit 20 measures what a query on customer reads without one\" - rewritten (the index on customer since)", "No index but the one on _id" not in od and "its indexes are the one on _id and one on customer" in od),
        ("README.md's unit 19 section, \"No index but `_id`'s\" - noted (Course 8, unit 20: and one on `customer` since)", "No index but `_id`'s *(Course 8, unit 20: and one on" in r),
        ("README.md's unit 19 section, \"`mvn verify` runs 18 + 10\" - noted (Course 8, unit 20: 18 + 11)", "`mvn verify` runs 18 + 10 *(Course 8, unit 20: 18 + 11" in r),
        ("MongoDatastoreIT's \"18 + 10 under mvn verify\" - noted beside it (18 + 11)", "18 + 10 under mvn verify. (Course 8, unit 20: 18 + 11" in it),
        ("compose.yaml's \"A standalone server, not a replica set: TiffinBox ships no MongoDB transaction\" - kept (still true), a unit 20 note beside it", "A standalone server, not a replica set: TiffinBox ships no MongoDB" in c and "unit 20's\n  # transactions ran in its harness" in c),
        ("README.md's unit 18 section, \"18 + 9 since\" - unit 19's note kept; its 18 + 10 is now noted in unit 19's section", "18 + 9 since, the one more this test *(Course 8, unit 19: 18 + 10" in r),
        ("no anchor sentence states getIndexes [\"_id_\"] or COLLSCAN as the orders' present state", "COLLSCAN" not in r.split("## Course 8 · unit 20")[0] and '["_id_"]' not in r),
        ("Revenue's Javadoc \"the collection and its indexes stay\" (reset, a delete) and \"a drop would take the collection's indexes with it\" - kept: unit 20 measures both (index's second start; the brief's m8.js for the drop)", "the collection and its indexes stay" in rd(A, W + "Revenue.java") and "drop would take the collection's indexes with it" in rd(A, W + "Revenue.java")),
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
elif NAME == "exercise":
    L = raw(sys.argv[2]); T = "\n".join(L)
    ok(int(sys.argv[3]) == 23, "the spoken line: 23 words (wc -w)")
    for sh in ("bash", "zsh"):
        i = next((k for k, l in enumerate(L) if l.startswith("in " + sh + " ")), None)
        ok(i is not None, sh + ": its block ran")
        if i is None: continue
        j = next(k for k, l in enumerate(L) if k > i and l.startswith("  then the solution's lines"))
        e = next(k for k, l in enumerate(L) if k > j and l.startswith("  the shell is now in"))
        br, so = L[i + 1:j], L[j + 1:e]
        ok("    indexes: [_id_]" in br and any(re.match(r"    explain find \{customer: %s\}: COLLSCAN · totalDocsExamined %d · totalKeysExamined 0 · nReturned %d$" % (FC, NO, N), l) for l in br),
           "%s, broken: getIndexes [_id_] alone, THEN explain COLLSCAN, every document examined (%d = customers x days), %d returned" % (sh, NO, N))
        ok("    indexes: [_id_, customer]" in so and any(re.match(r"    explain find \{customer: %s\}: FETCH > IXSCAN · totalDocsExamined %d · totalKeysExamined %d · nReturned %d$" % (FC, N, N, N), l) for l in so),
           "%s, solved: getIndexes names customer, THEN explain IXSCAN, %d documents and %d keys examined" % (sh, N, N))
        ok(("    orders saved: %d" % NO) in br and ("    orders saved: %d" % NO) in so, sh + ": the orders saved, both halves")
        ok(" exit 0:" in L[i] and " exit 0:" in L[j], sh + ": both blocks exit 0 - the check is the readings, never the exit")
        ok(re.search(r"listening on 20599 afterwards: 0 · the container c8u20-mongo-ex afterwards: 0 · volumes (\d+) \(before the shell: \1\)", L[e]) is not None, sh + ": the container removed with its volumes, 20599 free")
        im = re.search(r"images afterwards: (\w+) \(at the start: (\w+)\)", L[e])
        ok(im is not None and im.group(1) == im.group(2), sh + ": the images unchanged after the exercise")
    VALUES.append("broken: getIndexes [_id_], explain COLLSCAN %d examined; solved: getIndexes [_id_, customer], IXSCAN %d examined" % (NO, N))
elif NAME == "noindex":
    L = raw(sys.argv[2]); T = "\n".join(L)
    ok(one(L, r"^    -      auto-index-creation: true$") is not None, "the copy's one change printed: the key's lines removed")
    ok(one(L, r"getIndexes\(\) before the copy's start -> NamespaceNotFound: ns does not exist: tiffinbox\.orders · db\.orders\.countDocuments\(\) -> 0$") is not None, "a fresh MongoDB: orders does not exist before the copy's start (no index, no document)")
    ok(one(L, r"createIndexes commands on orders -> 0 · listIndexes commands on orders -> 0$") is not None, "system.profile: 0 createIndexes on orders - the key unset, the mapper sent none")
    ops = one(L, r"system\.profile on tiffinbox\.orders since the reset - the ops in order: (.*)$")
    ok(ops is not None and ops.group(1) == "remove, the filter {} · insert, ninserted %d" % NO, "system.profile on orders: one remove (an empty filter), one insert of %d - and no command" % NO)
    gi = one(L, r"getIndexes\(\) after the copy's start -> (\S+) · db\.orders\.countDocuments\(\) -> (\d+)$")
    ok(gi is not None and gi.group(1) == '["_id_"]' and int(gi.group(2)) == NO, "getIndexes after the copy's start: [\"_id_\"] alone, %d documents" % NO)
    p = plan(find(L, r"find\(\{customer: \"%s\"\}\) -> (.*)$" % FC) and EX.search(find(L, r"find\(\{customer: \"%s\"\}\) -> (.*)$" % FC).group(1)))
    ok(p == ("COLLSCAN", "COLLSCAN", N, 0, NO), "explain of a find on %s: COLLSCAN, nReturned %d, totalKeysExamined 0, totalDocsExamined %d (%s)" % (FC, N, NO, p))
    ok(find(L, r"\(x\d+\) Command \"createIndexes\"") is None, "the driver's DEBUG lines: no createIndexes")
    ok(one(L, r"GET /revenue/by-customer -> 200 ") is not None, "the copy serves /revenue/by-customer (the four) without the index")
    VALUES.append("the copy without the key: getIndexes [\"_id_\"]; 0 createIndexes; explain COLLSCAN, totalDocsExamined %d, totalKeysExamined 0, nReturned %d" % (NO, N))
elif NAME == "anchor":
    L = raw(sys.argv[2]); T = "\n".join(L)
    res = every(L, r"Surefire's Results line: Tests run: (\d+), Failures: 0, Errors: 0, Skipped: 0$")
    ok(len(res) == 3 and int(res[0].group(1)) == 18 and int(res[1].group(1)) == 18 and int(res[2].group(1)) == 11, "the tests: package 18 (Docker at nothing), verify 18 + 11 (Surefire's Results lines)")
    ok(one(L, r"Ports 127\.0\.0\.1:20578->27017/tcp · its command") is not None, "the IT's container: 127.0.0.1:20578->27017/tcp, Docker's own record (R.454's shape)")
    ok(one(L, r"MONGO IT the container's port bindings \(Docker's own record\): \[127\.0\.0\.1:20578->27017/tcp\]$") is not None, "the IT's own reading of its binding: 127.0.0.1:20578 alone")
    ok(one(L, r"MONGO IT orders, the mapper's IndexOperations\.getIndexInfo\(\): \[_id_, customer\]$") is not None, "the IT's third test, the mapper's witness: [_id_, customer]")
    ok(one(L, r"MONGO IT explain of find \{customer: Ravi\}, through the driver's runCommand: winningPlan FETCH > IXSCAN · nReturned 2 · totalKeysExamined 2 · totalDocsExamined 2$") is not None, "the IT's third test, the store's witness: FETCH > IXSCAN over the two Ravi orders it saved")
    ok(one(L, r"the verify log's MongoDB repository line \(the slice's scan\): \(x1\) Found 1 MongoDB repository interface$") is not None, "the test log: Found 1 MongoDB repository interface (the slice's scan)")
    ok(one(L, r"before it: listening on 20578 \(the anchor IT's pinned binding\): 0$") is not None and one(L, r"listening on 20578 after it: 0$") is not None, "20578 unbound before verify and after it")
    ok(one(L, r"--replSet named in the IT container's command: 0$") is not None, "the IT's container: no --replSet (a standalone)")
    ok(one(L, r"the package log: lines naming 27017 0 · lines naming mongo \(any case\) 0$") is not None, "mvn package with Docker at nothing: 0 lines name 27017 or mongo")
    lb = every(L, r"^  (before|after)/: (\d+) libraries$")
    ok(len(lb) == 2 and lb[0].group(2) == lb[1].group(2), "the libraries: before/ and after/ the same count (D3 adds no dependency)")
    ok(one(L, r"gained: 0 · lost: 0$") is not None, "no jar gained or lost")
    for v in ("spring-boot-4.1.2.jar", "spring-data-mongodb-5.1.2.jar", "mongodb-driver-sync-5.8.1.jar"):
        ok(v in T, "the version line: " + v)
    for v in (r"HHH000001: Hibernate ORM core version 7\.4\.13\.Final", r"\(PostgreSQL 18\.6\)", r"redis_version:8\.10\.3", r"db\.version\(\) 8\.3\.17", r"db version v8\.3\.17", r"show server_version 18\.6"):
        ok(re.search(v, T) is not None, "the version line: " + v.replace("\\", ""))
    ok(one(L, r"spring-configuration-metadata\.json\): spring\.data\.mongodb\.auto-index-creation java\.lang\.Boolean \(DataMongoProperties\)$") is not None, "Boot's metadata names the key as D3 writes it: spring.data.mongodb.auto-index-creation, a Boolean")
    ok(one(L, r"\(x1\) Command \"createIndexes\" started on database \"tiffinbox\"$") is not None, "the driver's DEBUG line: createIndexes on the database tiffinbox, once")
    ops = one(L, r"system\.profile on tiffinbox\.orders after the start \(mongosh, no network\) - the ops in order: (.*)$")
    want_ops = 'command createIndexes [{"key":{"customer":1},"name":"customer"}] · remove, the filter {} · insert, ninserted %d' % NO
    ok(ops is not None and ops.group(1) == want_ops, "system.profile on orders: createIndexes {customer: 1} named customer, then the fill's remove and one insert of %d (%s)" % (NO, ops.group(1) if ops else None))
    ok(one(L, r"createIndexes commands on orders -> 1 · the first one, as the server received it: createIndexes: \"orders\", indexes: \[\{\"key\":\{\"customer\":1\},\"name\":\"customer\"\}\] · its place: before the menu's fill - the first insert on tiffinbox\.menu comes after it$") is not None, "the start's createIndexes: one, on orders, before the menu's fill - the key made it at the start, no hand")
    fac = re.search(r"customers in the database (\d+) · tiffinbox\.days in after/'s application\.yaml (\d+)$", T, re.M)
    ok(fac is not None and int(fac.group(1)) == len(SD) and int(fac.group(2)) == N, "the factors, read by the receipt: %d customers, days %d" % (len(SD), N))
    cnt = one(L, r"db\.orders\.countDocuments\(\) -> (\d+) · per customer -> (.*) · db\.menu\.countDocuments\(\) -> (\d+)$")
    ok(cnt is not None and int(cnt.group(1)) == NO and groups(cnt.group(2)) == [(c, N) for c in sorted(x[0] for x in SD)] and int(cnt.group(3)) == N, "orders %d = customers x days, each customer's days; menu %d" % (NO, N))
    ok(one(L, r"db\.orders\.getIndexes\(\) -> _id_ key \{\"_id\":1\} unique false · customer key \{\"customer\":1\} unique false$") is not None, "getIndexes: _id_ and customer (key {customer: 1}, not unique) - RE-MEASURE 7's name")
    ok(one(L, r"listDatabases -> admin,config,local,tiffinbox · that container's interfaces \(its /proc/net/dev, read by mongosh\): lo$") is not None, "listDatabases: tiffinbox, no test; mongosh's container: lo only")
    want = sorted(((c, a * b * N) for c, a, b, t in SD), key=lambda x: (-x[1], x[0]))
    rvs = every(L, r"^  GET /revenue/by-customer -> 200 (\[.*\])$")
    rj = json.loads(rvs[0].group(1)) if rvs else []
    ok([(x["customer"], x["total"]) for x in rj] == want, "GET /revenue/by-customer 200: the four, = the seed's meals x price x days %s" % want)
    kj = one(L, r"GET /kitchen -> 200 (\{.*\})$"); kd = json.loads(kj.group(1)) if kj else {}
    rs = sum(x["total"] for x in rj)
    ok(kd.get("ordersValue") == rs, "the sum of the four (%d) = /kitchen's ordersValue" % rs)
    ok(one(L, r"GET /menu/day-19 -> 200 ") is not None and one(L, r"GET /actuator/health -> 200 ") is not None and one(L, r"GET /dashboard -> 200$") is not None and one(L, r"GET /revenue -> 200 ") is not None, "GET /menu/day-19, /revenue, /actuator/health, /dashboard 200 under dev")
    ok(one(L, r"the project's containers: tiffinbox-dev-mongo-1 127\.0\.0\.1:18883->27017/tcp\|tiffinbox-dev-postgres-1 127\.0\.0\.1:18881->5432/tcp\|tiffinbox-dev-redis-1 127\.0\.0\.1:18882->6379/tcp$") is not None, "the Compose window: the three services on 18881-18883, 127.0.0.1")
    ok(len(rvs) == 2 and rvs[0].group(1) == rvs[1].group(1), "the Compose window's /revenue/by-customer = the dev start's (the four)")
    cl = one(L, r"the start's lines: (.*)$")
    ok(cl is not None and '1 Command "createIndexes" started on database "tiffinbox"' in cl.group(1) and '2 Command "insert" started on database "tiffinbox"' in cl.group(1), "the Compose window: the driver names the database tiffinbox for createIndexes and the two inserts")
    ok(one(L, r'listDatabases -> admin,config,local,tiffinbox · on tiffinbox: db\.orders\.countDocuments\(\) -> %d · db\.orders\.getIndexes\(\) -> \["_id_","customer"\] · db\.menu\.countDocuments\(\) -> %d · on test: orders -> 0$' % (NO, N)) is not None, "the Compose window, mongosh: tiffinbox (no test), orders %d, the index on customer, menu %d" % (NO, N))
    ok(one(L, r"then: volumes (\d+) · tiffinbox-dev volumes by name: 0 · the mongo service's two: present present$") is not None, "the Compose window: down -v leaves the mongo service's two anonymous volumes (unit 18's measure, again)")
    vv = one(L, r"volumes (\d+) = before the window")
    VALUES.append("tests 18 + 11 (package 18); Ports 127.0.0.1:20578->27017/tcp; the IT's third test: getIndexInfo [_id_, customer], FETCH > IXSCAN; the key spring.data.mongodb.auto-index-creation (Boot's metadata); the start's createIndexes on orders, {customer: 1} named customer, before the fill; getIndexes _id_ + customer; countDocuments %d = %d customers x %d days; revenue/by-customer %s = ordersValue; listDatabases tiffinbox, no test; Compose window: the index there too, volumes back to %s (the unit's three containers alive)"
                  % (NO, len(SD), N, " · ".join("%s %d" % x for x in want), vv.group(1) if vv else "?"))
elif NAME == "index":
    L = raw(sys.argv[2]); C = raw(sys.argv[3])
    gis = every(L, r"db\.orders\.getIndexes\(\) -> (_id_ key .*?)(?: · db\.orders\.countDocuments\(\) -> \d+)?$")
    want = '_id_ key {"_id":1} unique false · customer key {"customer":1} unique false'
    ok(len(gis) == 2 and gis[0].group(1) == want and gis[1].group(1) == want, "getIndexes: _id_ and customer, before and after the second start")
    eps = [plan(EX.search(m.group(1))) for m in every(L, r"find\(\{customer: \"%s\"\}\) -> (.*)$" % FC)]
    ok(len(eps) == 2 and all(p == ("FETCH > IXSCAN", "FETCH > IXSCAN", N, N, N) for p in eps), "explain of a find on %s, before and after the second start: FETCH > IXSCAN, nReturned %d, totalKeysExamined %d, totalDocsExamined %d (%s)" % (FC, N, N, N, eps))
    ok(one(L, r"db\.orders\.countDocuments\(\{customer: \"%s\"\}\) -> %d · db\.orders\.countDocuments\(\) -> %d$" % (FC, N, NO)) is not None, "the factors: %s's orders %d (= tiffinbox.days), all %d" % (FC, N, NO))
    ok(one(L, r"PROBE idx: the shipped OrderDocument's IndexOperations\.getIndexInfo\(\) on orders, 2: _id_ _id ASC unique false · customer customer ASC unique false$") is not None, "the Java witness: the mapper's getIndexInfo names _id_ and customer")
    ops = one(L, r"system\.profile on tiffinbox\.orders since the reset - the ops in order: (.*)$")
    ok(ops is not None and ops.group(1).endswith("remove, the filter {} · insert, ninserted %d" % NO), "the second start: the fill's remove (a delete, an empty filter) and one insert of %d" % NO)
    ok(one(L, r"drop commands on orders -> 0 · createIndexes commands on orders -> \d+ · the driver's DEBUG lines: Command \"createIndexes\" started 1 · Command \"delete\" started 2$") is not None, "the second start: no drop of orders (R.431); the driver sent createIndexes once (its DEBUG line) and the two deletes")
    ok(one(L, r"after the second start: db\.orders\.getIndexes\(\) -> .* · db\.orders\.countDocuments\(\) -> %d$" % NO) is not None, "after the second start: %d orders, the index kept" % NO)
    ctl = find(C, r"find\(\{customer: \"%s\"\}\) -> (.*)$" % FC)
    ok(ctl is not None and plan(EX.search(ctl.group(1))) == ("COLLSCAN", "COLLSCAN", N, 0, NO), "its control, noindex, the same run: COLLSCAN, %d examined" % NO)
    VALUES.append("getIndexes _id_ + customer (key {customer: 1}, not unique); explain FETCH > IXSCAN, nReturned %d, totalKeysExamined %d, totalDocsExamined %d; getIndexInfo the same two; a second start: the fill deletes, the index stays, IXSCAN %d" % (N, N, N, N))
elif NAME in ("tx", "notone"):
    L = raw(sys.argv[2]); T = "\n".join(L)
    blocks = {}
    cur = None
    for l in L:
        m = re.match(r"-- tx (jpa|mongo-standalone|mongo-rs) ", l)
        if m: cur = m.group(1); blocks[cur] = []; continue
        if cur: blocks[cur].append(l)
    want = ["jpa", "mongo-rs"] if NAME == "notone" else ["jpa", "mongo-standalone", "mongo-rs"]
    ok(sorted(blocks) == sorted(want), "%s: the runs %s" % (NAME, want))
    b = blocks.get("jpa", [])
    ok(find(b, r"PROBE the context's PlatformTransactionManager beans \(getBeansOfType\), 1: transactionManager = org\.springframework\.orm\.jpa\.JpaTransactionManager$") is not None, "tx jpa: the context's one manager, read off it: JpaTransactionManager")
    ok(find(b, r"PostgreSQL by the JDBC URL in the config file \(database u20txjpa\)") is not None and find(b, r"MongoDB at mongodb://127\.0\.0\.1:<the unit's standalone>/tiffinbox") is not None, "tx jpa: PostgreSQL's database u20txjpa; MongoDB the unit's standalone, host and port only")
    ok(find(b, r"a transaction active \(TransactionSynchronizationManager\.isActualTransactionActive\) true · resources bound to the thread: DriverManagerDataSource, the EntityManagerFactory$") is not None, "tx jpa: inside the method a transaction is active - the JPA one: the EntityManagerFactory and the DataSource bound, nothing of Mongo's")
    ok(find(b, r"PROBE the exception: java\.lang\.IllegalStateException: PLANTED between the two writes$") is not None, "tx jpa: the harness's planted exception")
    ok(find(b, r"PROBE tx_docs after the call \(the harness's count\): count 1 · ids \[a\]$") is not None and find(b, r'the stored _ids \["a"\] · countDocuments 1$') is not None, "tx jpa: count 1, ids [a] - the harness's count AND mongosh's stored _ids: the first document stayed")
    r = blocks.get("mongo-rs", [])
    ok(find(r, r"PROBE the context's PlatformTransactionManager beans \(getBeansOfType\), 1: transactionManager = org\.springframework\.data\.mongodb\.MongoTransactionManager$") is not None and find(r, r"<the unit's replica set>") is not None, "tx mongo-rs: MongoTransactionManager, the replica set")
    ok(find(r, r"PROBE inserted \{_id: \"a\"\} into tx_docs$") is not None and find(r, r"PROBE the exception: java\.lang\.IllegalStateException: PLANTED between the two writes$") is not None, "tx mongo-rs: the first insert ran, then the plant")
    ok(find(r, r"PROBE tx_docs after the call \(the harness's count\): count 0 · ids \[\]$") is not None and find(r, r"the stored _ids \[\] · countDocuments 0$") is not None, "tx mongo-rs: count 0, ids [] - both witnesses: both or neither")
    if NAME == "tx":
        s = blocks.get("mongo-standalone", [])
        ok(find(s, r"transactionManager = org\.springframework\.data\.mongodb\.MongoTransactionManager$") is not None, "tx mongo-standalone: MongoTransactionManager")
        ok(find(s, r"PROBE the exception: org\.springframework\.data\.mongodb\.UncategorizedMongoDbException: This MongoDB deployment does not support retryable writes\. Please add retryWrites=false to your connection string\.$") is not None, "tx mongo-standalone: the top line the viewer reads - the driver's retryable-writes line")
        ok(find(s, r"caused by: com\.mongodb\.MongoCommandException: Command execution failed on MongoDB server with error 20 \(IllegalOperation\): 'Transaction numbers are only allowed on a replica set member or mongos'") is not None, "tx mongo-standalone: its cause, the server's error 20 (IllegalOperation)")
        ok(find(s, r"PROBE inserted \{_id: \"a\"\}") is None and find(s, r"tx_docs after the call \(the harness's count\): count 0 · ids \[\]$") is not None and find(s, r"the stored _ids \[\] · countDocuments 0$") is not None, "tx mongo-standalone: the first insert itself refused - count 0, both witnesses")
        for j in ("spring-boot-mongodb", "spring-boot-data-mongodb"):
            ok(one(L, r"  %s-4\.1\.2\.jar: entries naming a transaction \(grep -ci transaction\) 0 · " % j) is not None, "Boot's %s-4.1.2.jar: 0 entries name a transaction" % j)
        bm = one(L, r"entries naming MongoTransactionManager: 0 in (\d+) jars$")
        ok(bm is not None and int(bm.group(1)) > 10, "every Boot 4.1.2 jar in the seed: 0 entries name MongoTransactionManager")
        ok(one(L, r"rs\.initiate\(\) -> ok 1 · me c8u20-mongo-rs:27017 · info2 no configuration specified\. Using a default configuration for the set") is not None, "the replica set: initiated by mongosh (no network), me c8u20-mongo-rs:27017")
        ok(one(L, r"isWritablePrimary, polled <k> times -> true$") is not None and one(L, r"rs\.status\(\) -> set rs0 · members 1 · members\[0\]\.name c8u20-mongo-rs:27017 · members\[0\]\.stateStr PRIMARY") is not None, "the replica set: polled to the writable primary; rs.status set rs0, one member, PRIMARY")
        ok(one(L, r"Docker's port list for c8u20-mongo-rs \(dk port\) -> 27017/tcp -> 127\.0\.0\.1:20595 ") is not None, "the replica set: published on 127.0.0.1:20595 alone")
        ok(len(every(L, r"interfaces \(its /proc/net/dev, read by mongosh\): lo$")) == 1, "the replica set's mongosh container: lo only")
        VALUES.append("JpaTransactionManager over PostgreSQL, MongoDB standalone -> count 1, ids [a] (the harness's plant); MongoTransactionManager, MongoDB standalone -> refused: \"This MongoDB deployment does not support retryable writes. Please add retryWrites=false to your connection string.\" caused by error 20 (IllegalOperation) 'Transaction numbers are only allowed on a replica set member or mongos', count 0; MongoTransactionManager, a single-node replica set -> count 0, ids [] (both or neither); Boot's MongoDB jars: 0 entries name a transaction")
    else:
        C = raw(sys.argv[3])
        cl = [l for l in L if "tx_docs after the call" in l]
        cc = [l for l in C if "tx_docs after the call" in l]
        ok(cl == [cc[0], cc[2]] if len(cc) == 3 else False, "notone's two count lines = tx's jpa and mongo-rs count lines, the same run")
        VALUES.append("JpaTransactionManager over PostgreSQL, MongoDB standalone: the first document stayed, count 1, ids [a]; its control MongoTransactionManager on a single-node replica set: count 0, ids []")
elif NAME == "advertised":
    L = raw(sys.argv[2])
    ok(one(L, r'db\.hello\(\) -> me c8u20-mongo-rs:27017 · hosts \["c8u20-mongo-rs:27017"\] · setName rs0 · isWritablePrimary true$') is not None, "hello: me c8u20-mongo-rs:27017 (the container's hostname), hosts, setName rs0, the writable primary")
    ok(one(L, r"PROBE topo one-seed: the driver's URI mongodb://127\.0\.0\.1:<the unit's replica set>/tiffinbox$") is not None, "one-seed: no replicaSet, no directConnection")
    ok(one(L, r"PROBE the driver's ClusterDescription: connection mode SINGLE · cluster type REPLICA_SET · servers \[127\.0\.0\.1:20595\] · the server's type REPLICA_SET_PRIMARY · its setName rs0$") is not None, "one-seed: SINGLE, REPLICA_SET, the one seed - the advertised name not followed")
    ok(one(L, r"PROBE insertOne \{_id: \"one-seed\"\} into topo_docs: done · count 1$") is not None and one(L, r'topo_docs\.find\(\)\.toArray\(\) -> the stored _ids \["one-seed"\]$') is not None, "one-seed: the write, both witnesses")
    ok(one(L, r"replicaSet=rs0&serverSelectionTimeoutMS=<n>$") is not None, "replicaset: the URI, its wait masked")
    ok(one(L, r"PROBE the exception: com\.mongodb\.MongoTimeoutException: Timed out while waiting for a server that matches WritableServerSelector\. Client view of cluster state is \{type=REPLICA_SET, servers=\[\{address=c8u20-mongo-rs:27017, type=UNKNOWN, state=CONNECTING, exception=\{com\.mongodb\.MongoSocketException: c8u20-mongo-rs\}, caused by \{java\.net\.UnknownHostException: c8u20-mongo-rs\}\}\]$") is not None, "replicaset: MongoTimeoutException, the advertised c8u20-mongo-rs:27017, UnknownHostException")
    VALUES.append("hello me c8u20-mongo-rs:27017, setName rs0; one seed: SINGLE / REPLICA_SET, the write done; replicaSet=rs0: the driver followed the advertised name and could not resolve it, UnknownHostException: c8u20-mongo-rs")
elif NAME == "unique":
    L = raw(sys.argv[2])
    ok(one(L, r"PROBE the exception: org\.springframework\.dao\.DuplicateKeyException: .*E11000 duplicate key error collection: tiffinbox\.uniq_docs index: code dup key: \{ code: \"LUNCH-1\" \}") is not None, "the second save: DuplicateKeyException, E11000 on tiffinbox.uniq_docs, index code")
    ok(one(L, r"PROBE the mapper's getIndexInfo on uniq_docs: _id_ unique false, code unique true · count 1$") is not None, "the Java witness: the index code, unique; count 1")
    ok(one(L, r'db\.uniq_docs\.getIndexes\(\) -> _id_ key \{"_id":1\} unique false · code key \{"code":1\} unique true · db\.uniq_docs\.find\(\)\.toArray\(\) -> \[\{"_id":"u1","code":"LUNCH-1"\}\]$') is not None, "mongosh: the index code unique true; one stored document, u1")
    VALUES.append("the harness's @Indexed(unique = true): the second save -> DuplicateKeyException, E11000 duplicate key error collection: tiffinbox.uniq_docs index: code; count 1")
elif NAME == "shapes":
    L = raw(sys.argv[2]); T = "\n".join(L)
    ok(one(L, r"PROBE shapes fill: the harness's customers %d \(after/'s seed: %s\) · tiffinbox\.days %d · orders_emb %d · orders_ref %d · orders_dbref %d$" % (len(SD), ", ".join(x[0] for x in SD), N, NO, NO, NO)) is not None, "the fill: %d customers x %d days in each shape" % (len(SD), N))
    ok(re.search(r"printjson\(db\.orders_ref\.findOne\(\{_id: \"%s-1\"\}\)\):\n +\{\n +_id: '%s-1',\n +customer: '%s',\n" % (FC, FC, FC), T) is not None, "orders_ref stores customer: '%s' - the id alone (@DocumentReference)" % FC)
    ok(re.search(r"customer: DBRef\('customers', '%s'\)" % FC, T) is not None, "orders_dbref stores DBRef('customers', '%s')" % FC)
    ok(re.search(r"printjson\(db\.orders_emb\.findOne\(\{_id: \"%s-1\"\}\)\):\n +\{\n +_id: '%s-1',\n +customer: \{\n +_id: '%s',\n +mealType: '\w+',\n +price: \d+\n +\}," % (FC, FC, FC), T) is not None, "orders_emb stores the customer inside, a sub-document")
    ok(one(L, r"the customer field's type, as stored: orders_emb Object · orders_ref string · orders_dbref DBRef · db\.customers\.countDocuments\(\) %d$" % len(SD)) is not None, "the stored types: a sub-document, a string, a DBRef")
    def counts(step):
        i = next(k for k, l in enumerate(L) if l.startswith("-- shapes %s," % step))
        m = next(re.search(r"the commands per namespace and op: (.*)$", l) for l in L[i:] if "the commands per namespace and op:" in l)
        return dict((a, int(b)) for a, b in re.findall(r"(tiffinbox\.\w+ \w+) (\d+)", m.group(1)))
    ce, cr, cd = counts("read-emb"), counts("read-ref"), counts("read-dbref")
    ok(ce.get("tiffinbox.orders_emb query") == 1 and ce.get("tiffinbox.orders_emb getmore", 0) >= 1 and not any(k.startswith("tiffinbox.customers") for k in ce), "embedded: one query op on orders_emb and its getmore (%s), 0 on customers" % ce)
    ok(cr.get("tiffinbox.orders_ref query") == 1 and cr.get("tiffinbox.customers query") == NO, "@DocumentReference: one query op on orders_ref, then %d on customers - one command per reference (%s)" % (NO, cr))
    ok(cd.get("tiffinbox.orders_dbref query") == 1 and cd.get("tiffinbox.customers query") == NO, "@DBRef: one query op on orders_dbref, then %d on customers (%s)" % (NO, cd))
    ok(one(L, r"PROBE shapes read-ref: findAll\(OrderRef\.class\) -> %d orders · customers resolved \(non-null\) %d$" % (NO, NO)) is not None and one(L, r"PROBE shapes read-dbref: findAll\(OrderDbRef\.class\) -> %d orders · customers resolved \(non-null\) %d$" % (NO, NO)) is not None, "the Java side: %d orders, every customer resolved, both reference shapes" % NO)
    we, wr = counts("write-emb"), counts("write-ref")
    ok(one(L, r"PROBE shapes write-emb: %s's price \d+ -> \d+ in every embedded copy, updateMulti\(OrderEmb\.class\) -> matched %d · modified %d$" % (FC, N, N)) is not None and one(L, r"update ops' nModified -> tiffinbox\.orders_emb %d$" % N) is not None and we == {"tiffinbox.orders_emb update": 1}, "the write, embedded: one update op, %d documents modified (both witnesses)" % N)
    ok(one(L, r"PROBE shapes write-ref: %s's price \d+ -> \d+ in the one customer document, updateFirst\(Cust\.class\) -> matched 1 · modified 1$" % FC) is not None and one(L, r"update ops' nModified -> tiffinbox\.customers 1$") is not None and wr == {"tiffinbox.customers update": 1}, "the write, referenced: one update op on customers, 1 modified, 0 ops on the orders")
    VALUES.append("the harness's three shapes, findAll of %d: embedded 1 query op (+ %d getmore), 0 on customers; @DocumentReference 1 + %d on customers; @DBRef 1 + %d - one command per reference; the price write: embedded %d documents modified vs referenced 1, 0 orders" % (NO, ce.get("tiffinbox.orders_emb getmore", 0), NO, NO, N))
elif NAME == "default":
    L = raw(sys.argv[2]); T = "\n".join(L)
    ok(one(L, r"GET /actuator/health -> 200 ") is not None, "health 200 with no MongoDB")
    ok(one(L, r"GET /revenue/by-customer -> 404 · GET /menu/day-19 -> 404 · GET /revenue -> 200 \{\"monthRevenue\":\d+\} · GET /kitchen -> 200 \{.*\"ordersValue\":\d+.*\} · GET /dashboard -> 200$") is not None, "/revenue/by-customer 404, /menu/day-19 404, /revenue 200, /kitchen 200, /dashboard 200")
    ok(one(L, r"a bean named revenue 0 · orderDocuments 0 · menus 0 · a MongoClient bean 0 · tiffinBoxServer 1$") is not None, "/actuator/beans: no Revenue, OrderDocuments, Menus or MongoClient bean")
    ok(one(L, r"its log: lines naming 27017 0 · lines naming mongo, any case 0 · lines naming createIndexes 0 · ") is not None, "the log: 0 lines naming 27017, mongo or createIndexes")
    ok(len(every(L, r"Surefire's Results line: Tests run: 18, Failures: 0, Errors: 0, Skipped: 0$")) == 1, "the 18 under mvn -o package, Docker at nothing")
    VALUES.append("health 200, /revenue/by-customer 404, /menu/day-19 404, /revenue 200, /kitchen 200, 0 lines naming 27017, mongo or createIndexes, no Revenue/OrderDocuments bean; the 18 without Docker")
elif NAME == "seven":
    L = raw(sys.argv[2]); want = sys.argv[3]
    hs = every(L, r"the seven responses: 7 lines · md5 ([0-9a-f]{32})")
    ok(len(hs) == 2 and hs[0].group(1) == hs[1].group(1) == want, "the seven on before/ and after/: md5 = Course 7's %s" % want)
    ok(one(L, r"cmp with xcheck\.sql \(= Course 7's capstone's\): the same, byte for byte$") is not None, "Hibernate's script = xcheck.sql")
    ok(one(L, r"lines that differ: 0$") is not None, "before/ against after/: 0 lines differ")
    VALUES.append("the seven: md5 %s on before/ and after/" % want)
else:
    print("FAIL no check named " + NAME); sys.exit(1)
for m in oks: print("ok " + m)
for m in fails: print("FAIL " + m)
if VALUES: print("VALUES " + "; ".join(VALUES))
sys.exit(1 if fails else 0)
