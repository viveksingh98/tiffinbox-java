"""Unit 07's checks (python3 -I -B harness/chk07.py MODE ...). Modes: static AFTER BEFORE (the change's shape before anything runs: the
files that differ, nothing in src/main, the test-scope dependency with no version typed, JdbcSlice's three annotations, the IT's
annotations and its *IT name - S6.22), r250 AFTER BEFORE (the gate before any build: every anchor README sentence the change makes false,
found in before/ and noted in place in after/, and every test-count phrase in after/README.md noted or in unit 07's section), one mode
per capture (tests, slice, sql, wrongslice, nocontainer, nodocker, seven, exercise: each reads the capture and asserts every number and
string the video may say against a second witness of the same run, printing VALUES - the values block's words - last), and
wib CAPTURE FILE (what an exercise file's block printed, from the capture). A failed assertion prints FAIL and exits 1."""
import difflib, os, re, sys

MODE = sys.argv[1]
BAD = []


def ok(cond, what):
    print(("ok " if cond else "FAIL ") + what)
    if not cond:
        BAD.append(what)


def done(values=None):
    if values is not None:
        print("VALUES " + values)
    sys.exit(1 if BAD else 0)


def read(p):
    with open(p, encoding="utf-8") as f:
        return f.read()


def one(pat, text, what, group=1):
    mm = re.search(pat, text, re.M)
    ok(mm is not None, what)
    return mm.group(group) if mm else None


def ints(pat, text):
    return [int(x) for x in re.findall(pat, text, re.M)]


def folders(c):
    """Surefire's 'in all' lines, in the order the capture printed its report folders."""
    return [tuple(int(x) for x in mm) for mm in re.findall(r"^ +in all: (\d+) reports · tests (\d+) · failures (\d+) · errors (\d+) · skipped (\d+)$", c, re.M)]


def results(c):
    return [tuple(int(x) for x in mm) for mm in re.findall(r"^ +Surefire's Results line: Tests run: (\d+), Failures: (\d+), Errors: (\d+), Skipped: (\d+)$", c, re.M)]


def report(c, cls):
    mm = re.search(r"^ +TEST-com\.tiffinbox\.(?:jdbc\.)?" + cls + r"\.xml: tests (\d+) · failures (\d+) · errors (\d+) · skipped (\d+)$", c, re.M)
    return tuple(int(x) for x in mm.groups()) if mm else None


def runline(c, k=0):
    """The k-th Maven run's exit line and its events line."""
    ex = re.findall(r"^ +exit (\d+) · BUILD (SUCCESS|FAILURE) · offline: (\S+)", c, re.M)
    ev = re.findall(r"^ +the engine's events over its window \(the pinned CLI\): image pull (\d+) · container create (\d+) \(([^)]*)\) · Testcontainers' log: 'Creating container for image' (\d+) · 'Pulling' (\d+) · 'Ryuk has been disabled' (\d+)$", c, re.M)
    return (ex[k] if k < len(ex) else None), (tuple(ev[k]) if k < len(ev) else None)


IMG = "postgres@sha256:77f585114c32fbca283dc835b0596f4e52b51b4c6662d7810b2f4084f60a1873"


def events_ok(ev, creates, what):
    ok(ev is not None, what + ": the events line printed")
    if ev is None:
        return
    pull, cre, ims, logc, pulling, ryuk = ev
    ok(int(cre) == creates and int(logc) == creates, "%s: %d container create(s) by the engine's events = %d by Testcontainers' log (want %d)" % (what, int(cre), int(logc), creates))
    ok(creates == 0 or ims == IMG, what + ": every create is the pinned digest")
    ok(int(pull) == 0 and int(pulling) == 0, what + ": 0 image pulls (events) = 0 'Pulling' lines (log)")
    ok(creates == 0 or int(ryuk) >= 1, what + ": 'Ryuk has been disabled' in the log (R.318)")


# ---- static ------------------------------------------------------------------------------------------------------------------
if MODE == "static":
    a, b = sys.argv[2], sys.argv[3]
    files = {}
    for root in (a, b):
        s = set()
        for d, ds, fs in os.walk(root):
            for f in fs:
                s.add(os.path.relpath(os.path.join(d, f), root))
        files[root] = s
    new = sorted(files[a] - files[b]); gone = sorted(files[b] - files[a])
    changed = sorted(f for f in files[a] & files[b] if open(os.path.join(a, f), "rb").read() != open(os.path.join(b, f), "rb").read())
    W = "tiffinbox-web/src/test/java/"
    ok(new == [W + "com/tiffinbox/jdbc/CustomerAggregatesIT.java", W + "slice/JdbcSlice.java"], "new: %s" % ", ".join(new))
    ok(gone == [], "deleted: none")
    ok(changed == ["README.md", "tiffinbox-web/pom.xml", W + "com/tiffinbox/CustomerEntityRepositoryIT.java"], "changed: %s" % ", ".join(changed))
    ok(not [f for f in new + changed if "/src/main/" in f], "nothing in src/main differs (test scope only)")
    strip = lambda t: re.sub(r"\s+", " ", re.sub(r"<!--.*?-->", "", t, flags=re.S)).strip()
    pa, pb = read(os.path.join(a, "tiffinbox-web/pom.xml")), read(os.path.join(b, "tiffinbox-web/pom.xml"))
    dep = re.search(r"<dependency>\s*<groupId>org\.springframework\.boot</groupId>\s*<artifactId>spring-boot-starter-data-jdbc-test</artifactId>\s*<scope>test</scope>\s*</dependency>", pa)
    ok(dep is not None, "tiffinbox-web/pom.xml: spring-boot-starter-data-jdbc-test, test scope, no version typed (Boot's parent manages it)")
    ok(dep is not None and strip(pa.replace(dep.group(0), "")) == strip(pb), "tiffinbox-web/pom.xml: that dependency is its only change outside comments")
    js = read(os.path.join(a, W + "slice/JdbcSlice.java"))
    for ann in ("@SpringBootConfiguration", '@EnableJdbcRepositories("com.tiffinbox.jdbc")', "@Import(JdbcNames.class)"):
        ok(("\n" + ann + "\n") in js, "slice/JdbcSlice.java carries " + ann)
    it = read(os.path.join(a, W + "com/tiffinbox/jdbc/CustomerAggregatesIT.java"))
    # @ServiceConnection is not checked here: S8.20 - the check is the database that answered, read off the run (the tests capture)
    for ann in ("@DataJdbcTest", "@ContextConfiguration(classes = JdbcSlice.class)", "@Testcontainers", "    @Container", "@Sql(statements = "):
        ok(("\n" + ann) in it, "CustomerAggregatesIT.java carries " + ann.strip())
    ok('DockerImageName.parse("' + IMG + '")' in it, "CustomerAggregatesIT.java names the image by the capstone's digest")
    ok(re.search(r"\nclass CustomerAggregatesIT \{", it) is not None, "S6.22: the class is named *IT (Surefire's container-tests execution runs it, mvn package does not)")
    ok(it.count("@Test\n") == 2, "CustomerAggregatesIT.java holds two tests")
    ri = difflib.unified_diff(read(os.path.join(b, W + "com/tiffinbox/CustomerEntityRepositoryIT.java")).splitlines(), read(os.path.join(a, W + "com/tiffinbox/CustomerEntityRepositoryIT.java")).splitlines(), lineterm="", n=0)
    rl = [l for l in ri if l[:1] in "+-" and not l.startswith(("+++", "---"))]
    ok(all(l.lstrip("+- ").startswith("*") for l in rl) and "Course 8, unit 07" in " ".join(rl), "CustomerEntityRepositoryIT.java: its Javadoc alone changed, the count noted in place")
    done()

# ---- R.250 ---------------------------------------------------------------------------------------------------------------------
if MODE == "r250":
    a, b = sys.argv[2], sys.argv[3]
    ra, rb = read(os.path.join(a, "README.md")), read(os.path.join(b, "README.md"))
    nw = lambda t: re.sub(r"\s+", " ", t)
    A, B = nw(ra), nw(rb)
    S = ["(`CustomerEntityRepositoryIT`, started from `slice/DataSlice`, run by `mvn verify` only)",
         "unit 07 changes this folder next, in test scope only.)*",
         "The 18 tests on H2 in memory and the 3 on PostgreSQL in a container are the same tests, unchanged",
         "**Which tests run where: 18 on H2 in memory, 3 on PostgreSQL in a container.**",
         "`mvn verify` runs the 18, then the three container tests",
         "`verify` runs the three container tests since"]
    for s in S:
        ok(s in B, "R.250: before/README.md says: " + s[:90])
        i = A.find(s)
        ok(i >= 0 and "*(Course 8, unit 07" in A[i + len(s): i + len(s) + 40], "R.250: after/README.md notes it in place, right after it: *(Course 8, unit 07 … - " + s[:70])
    sec = re.search(r"\n## Course 8 · unit 07 .*?\n---\n", ra, re.S)
    ok(sec is not None, "after/README.md holds a ## Course 8 · unit 07 section, closed by its rule")
    body = ra.replace(sec.group(0), "") if sec else ra
    for mm in re.finditer(r"21 tests|3 on PostgreSQL in a container|three container tests|CustomerEntityRepositoryIT's three tests", nw(body)):
        tail = nw(body)[mm.end(): mm.end() + 420]
        ok("Course 8, unit 07" in tail, "R.250: every test-count phrase outside unit 07's section is noted - '%s'" % mm.group(0))
    pom = read(os.path.join(a, "tiffinbox-web/pom.xml"))
    ok("CustomerEntityRepositoryIT's three tests on PostgreSQL in a container.\n           (Course 8, unit 07:" in pom, "R.250: the pom's container-tests comment noted in place")
    ok("Only CustomerEntityRepositoryIT uses them" in pom and "(Course 8, unit 07: CustomerAggregatesIT uses them too" in pom, "R.250: the pom's Testcontainers comment noted in place")
    ok(not re.search(r"\b(?:one|a single) (?:container|IT) (?:test )?class\b", ra), "after/README.md says nowhere that one container test class runs")
    done()

C = read(sys.argv[2]) if len(sys.argv) > 2 and MODE != "wib" else ""

# ---- tests ---------------------------------------------------------------------------------------------------------------------
if MODE == "tests":
    ex, ev = runline(C)
    ok(ex is not None and ex[0] == "0" and ex[1] == "SUCCESS" and ex[2] == "yes", "mvn verify: exit 0 · BUILD SUCCESS · offline: yes")
    events_ok(ev, 2, "mvn verify")
    rows = re.findall(r"^ +JDBC IT test ([12]) customers (\d+) · Kavya (\d+) · test transaction active (true|false)$", C, re.M)
    ok([r[0] for r in rows] == ["1", "2"], "the two slice tests each print their line")
    rep = re.findall(r"^ +JDBC IT test ([12]) through the repository: findByName\(\"Kavya\"\) (\w+) · findAll\(\) (\d+)$", C, re.M)
    for r, q in zip(rows, rep):
        ok(r[2] == "1" and r[3] == "true", "test %s: Kavya 1 · test transaction active true" % r[0])
        ok(q[1] == "Kavya" and int(q[2]) == int(r[1]), "test %s: customers %s by JdbcTemplate = findAll() %s through the repository (the second witness)" % (r[0], r[1], q[2]))
    ok(len(rows) == 2 and rows[0][1] == rows[1][1], "the same customer count in both tests (the rollback removed the first Kavya)")
    db = re.findall(r"^ +JDBC IT test ([12]) the database: (\S+) · (PostgreSQL [0-9.]+)$", C, re.M)
    ok(len(db) == 2 and all(d[1] == "jdbc:postgresql://localhost:<port>/test?loggerLevel=OFF" and d[2] == "PostgreSQL 18.6" for d in db), "both tests: the database that answered is jdbc:postgresql://localhost:<port>/test · PostgreSQL 18.6 (port masked, R.319)")
    fl = one(r"the database Flyway saw in the slice \(its Database line\): (.*)$", C, "Flyway's Database line printed", 1) or ""
    ok("(PostgreSQL 18.6)" in fl, "Flyway's Database line says PostgreSQL 18.6 (the second witness of the product line)")
    f = folders(C); rs = results(C)
    ok(len(f) == 2 and len(rs) == 2, "two report folders and two Results lines")
    if len(f) == 2 and len(rs) == 2:
        ok(f[0][1] == rs[0][0] and f[1][1] == rs[1][0] and all(x[2] == 0 and x[3] == 0 for x in f), "surefire-reports %d = Results %d · surefire-reports-it %d = Results %d · failures 0 · errors 0" % (f[0][1], rs[0][0], f[1][1], rs[1][0]))
    ja, je = report(C, "CustomerAggregatesIT"), report(C, "CustomerEntityRepositoryIT")
    ok(ja is not None and ja[0] == 2 and ja[1:3] == (0, 0), "TEST-com.tiffinbox.jdbc.CustomerAggregatesIT.xml: 2 tests, 0 failures, 0 errors")
    ok(je is not None and je[0] == 3 and f and len(f) == 2 and f[1][1] == ja[0] + je[0], "the container folder = CustomerEntityRepositoryIT's + CustomerAggregatesIT's")
    jp = re.search(r"'Found 1 JPA repository interface' (\d+) · 'Found 1 JDBC repository interface' (\d+)", C)
    ok(jp is not None and int(jp.group(1)) >= 1 and int(jp.group(2)) >= 1, "both modules' Found 1 … repository interface lines in the verify log (S8.21)")
    tot = (f[0][1] + f[1][1]) if len(f) == 2 else -1
    done("mvn verify, offline, PostgreSQL 18.6 from the digest: the two slice tests each print customers %s · Kavya 1 · test transaction active true, the database jdbc:postgresql://localhost:<port>/test · PostgreSQL 18.6; Surefire per report folder: surefire-reports %s, surefire-reports-it %s (CustomerEntityRepositoryIT %s · CustomerAggregatesIT %s), %s in all, failures 0, errors 0; Testcontainers: %s container creates (one per IT class), 0 pulls, Ryuk disabled"
         % (rows[0][1] if rows else "?", f[0][1] if f else "?", f[1][1] if len(f) > 1 else "?", je[0] if je else "?", ja[0] if ja else "?", tot, ev[1] if ev else "?"))

# ---- slice ---------------------------------------------------------------------------------------------------------------------
if MODE == "slice":
    ok(re.search(r"^ +JDBC IT the configuration: jdbcSlice · slice\.JdbcSlice$", C, re.M) is not None, "the configuration: jdbcSlice · slice.JdbcSlice")
    want = {"EntityManagerFactory": "0", "Flyway": "1", "PlatformTransactionManager": "1 · org.springframework.jdbc.support.JdbcTransactionManager",
            "CustomerAggregates": "1", "Dashboard": "0", "CustomerEntityRepository": "0", "JdbcClient": "1"}
    got = dict(re.findall(r"^ +JDBC IT beans (\w+): (.*)$", C, re.M))
    for k, v in want.items():
        ok(got.get(k) == v, "beans %s: %s (read off the slice's context)" % (k, got.get(k)))
    seg = one(r"^ +its log, from 'Running com\.tiffinbox\.jdbc\.CustomerAggregatesIT' to its Tests run line: (.*)$", C, "the slice's own log segment counted", 1) or ""
    def g(key):
        mm = re.search(re.escape(key) + r"'?(?: \([^)]*\))? (\d+)", seg)
        return int(mm.group(1)) if mm else None
    ok(g("Found 1 JDBC repository interface") == 1 and got.get("CustomerAggregates") == "1", "CustomerAggregates 1 = the segment's 'Found 1 JDBC repository interface' 1 (the second witness)")
    ok(g("Found 1 JPA repository interface") == 0 and g("HHH000001") == 0 and got.get("EntityManagerFactory") == "0", "EntityManagerFactory 0 = the segment's Spring Data JPA Found lines 0 and Hibernate's HHH000001 0")
    ok(g("Successfully applied 3 migrations") == 1 and got.get("Flyway") == "1", "Flyway 1 = the segment's 'Successfully applied 3 migrations' 1")
    ok(g("Tomcat started") == 0 and re.search(r"listening on 20460 while nothing runs: 0", C) is not None, "the slice started no web server, and 20460 is free")
    mode = one(r"^ +JDBC IT spring\.sql\.init\.mode, read off the Environment: (.*)$", C, "spring.sql.init.mode printed", 1)
    sc = one(r"^ +JDBC IT spring\.sql\.init's scripts on the class path: schema\.sql (true|false) · data\.sql (true|false)$", C, "the scripts' presence printed", 0)
    ok(mode == "(not set)" and sc is not None and sc.endswith("schema.sql false · data.sql false"), "RE-MEASURE 15: spring.sql.init.mode not set, no schema.sql or data.sql on the class path: the seed is Flyway's V2 + @Sql")
    h = one(r"^ +JDBC IT flyway_schema_history: rows (\d+) · the migrations' \(a version\) \[(.*)\]$", C, "Flyway's history printed", 0)
    hl = re.search(r"rows (\d+) · the migrations' \(a version\) \[(.*)\]", h or "")
    ok(hl is not None and hl.group(2) == "1 true, 2 true, 3 true" and hl.group(1) == "3", "history [1 true, 2 true, 3 true], rows 3 = 'Successfully applied 3 migrations' (PostgreSQL)")
    done("@DataJdbcTest from slice.JdbcSlice, read off its context inside the first test, PostgreSQL 18.6): EntityManagerFactory 0 · Flyway 1 · PlatformTransactionManager org.springframework.jdbc.support.JdbcTransactionManager · CustomerAggregates 1 · Dashboard 0 · CustomerEntityRepository 0 · JdbcClient 1; spring.sql.init.mode not set, no schema.sql or data.sql (the seed is Flyway's V2 + @Sql); flyway_schema_history [1 true, 2 true, 3 true]; no web server")

# ---- sql -----------------------------------------------------------------------------------------------------------------------
if MODE == "sql":
    ex, ev = runline(C)
    ok(ex is not None and ex[0] == "0", "AfterTheClassIT: exit 0")
    events_ok(ev, 1, "AfterTheClassIT")
    seed = ints(r"INSERT INTO customer lines (\d+)$", C)
    t = re.findall(r"^ +JDBC IT test ([12]) customers (\d+) · Kavya (\d+) · test transaction active (true)$", C, re.M)
    af = re.findall(r"^ +JDBC IT after the class, a JdbcTemplate of its own on the container: customers (\d+) · Kavya (\d+)$", C, re.M)
    ok(len(seed) == 1 and len(t) == 2 and all(int(x[1]) == seed[0] + 1 and x[2] == "1" for x in t), "test 1 and test 2: V2's customers + the fixture's one (Kavya 1), inside the test's transaction")
    ok(len(af) == 1 and len(seed) == 1 and int(af[0][0]) == seed[0] and af[0][1] == "0", "after the class: V2's customers alone, Kavya 0 - the rollback removed her (a JdbcTemplate of its own, a second client)")
    ok(len(re.findall(r"^ +JDBC IT test [12] the database: jdbc:postgresql://localhost:<port>/test\?loggerLevel=OFF · PostgreSQL 18\.6$", C, re.M)) == 2, "both tests on PostgreSQL 18.6")
    done("the @Sql sequence on PostgreSQL 18.6: test 1 customers %s · Kavya 1, test 2 customers %s · Kavya 1 (not one more), after the class (a JdbcTemplate of its own on the container) customers %s · Kavya 0"
         % (t[0][1] if t else "?", t[1][1] if len(t) > 1 else "?", af[0][0] if af else "?"))

# ---- wrongslice ------------------------------------------------------------------------------------------------------------------
if MODE == "wrongslice":
    ex, ev = runline(C)
    ok(ex is not None and ex[0] == "1" and ex[1] == "FAILURE", "WrongSliceIT: exit 1 · BUILD FAILURE")
    r = report(C, "WrongSliceIT")
    ok(r is not None and r[0] == 2 and r[2] == 2, "TEST-…WrongSliceIT.xml: 2 tests, 2 errors")
    ok("Caused by: java.lang.IllegalStateException: Unable to retrieve @EnableAutoConfiguration base packages" in C, "the report's Caused by: Unable to retrieve @EnableAutoConfiguration base packages")
    ok("the log's first IllegalStateException line: java.lang.IllegalStateException: Unable to retrieve @EnableAutoConfiguration base packages" in C, "the same text in Maven's log (the second witness)")
    ok(not re.search(r"^ +JDBC IT test", C, re.M), "no test line printed - the context never started")
    done("Spring Data JPA's DataSlice under @DataJdbcTest - Unable to retrieve @EnableAutoConfiguration base packages, both tests in error, exit 1")

# ---- nocontainer -----------------------------------------------------------------------------------------------------------------
if MODE == "nocontainer":
    exa, eva = runline(C, 0); exb, evb = runline(C, 1)
    ok(exa is not None and exa[0] == "0" and exa[1] == "SUCCESS", "NoServiceConnectionIT: exit 0 · BUILD SUCCESS - green")
    events_ok(eva, 1, "NoServiceConnectionIT")
    ra = report(C, "NoServiceConnectionIT")
    ok(ra is not None and ra == (2, 0, 0, 0), "TEST-…NoServiceConnectionIT.xml: 2 tests passed")
    h2 = re.findall(r"^ +JDBC IT test ([12]) the database: jdbc:h2:mem:<uuid> · (H2 2\.5\.250)(?: \([0-9-]+\))?$", C, re.M)
    ok(len(h2) >= 2, "NoServiceConnectionIT: both tests answered by jdbc:h2:mem:<uuid> · H2 2.5.250 (the container created and unused)")
    c = re.findall(r"^ +JDBC IT test ([12]) customers (\d+) · Kavya (\d+) · test transaction active true$", C, re.M)
    ok(len(c) >= 2 and c[0][1] == c[1][1], "NoServiceConnectionIT: the same count in both tests")
    rep = ints(r"^ +JDBC IT test [12] through the repository: findByName\(\"Kavya\"\) Kavya · findAll\(\) (\d+)$", C)
    ok(len(rep) == 2 and c and rep[0] == int(c[0][1]), "findAll() through the repository = JdbcTemplate's count, on H2 (Q imported)")
    sq = re.findall(r"^ +the SQL Spring Data JDBC sent for findAll\(\), its JdbcTemplate log: (.*)$", C, re.M)
    ok(any(s.startswith("SELECT customer.ID AS ID") for s in sq), "on H2 with Q: the SQL unquoted (H2's dialect upper-cases the names)")
    ok(exb is not None and exb[0] == "1", "the without-Q run: exit 1 (one class in error)")
    events_ok(evb, 2, "NoServiceConnectionNoQIT + NoQIT")
    rb, rq = report(C, "NoServiceConnectionNoQIT"), report(C, "NoQIT")
    ok(rb is not None and rb[1] + rb[2] >= 1, "NoServiceConnectionNoQIT: not green on H2")
    ok('Table "customer" not found (candidates are: "CUSTOMER")' in C, "on H2 without Q: Table \"customer\" not found (candidates are: \"CUSTOMER\")")
    ok(rq is not None and rq == (2, 0, 0, 0), "NoQIT (PostgreSQL without Q): 2 tests passed")
    ok(any(s.startswith('SELECT "customer"."id" AS "id"') for s in sq), "on PostgreSQL without Q: the quoted SQL (labelled, failure receipt only)")
    done("@ServiceConnection removed, @Container kept - green, the database that answered jdbc:h2:mem:<uuid> · H2 2.5.250, findAll() %s, the container created and unused (1 create, 0 pulls); without Q on H2: Table \"customer\" not found (candidates are: \"CUSTOMER\"); without Q on PostgreSQL 18.6: green, the SQL quoted" % (rep[0] if rep else "?"))

# ---- nodocker --------------------------------------------------------------------------------------------------------------------
if MODE == "nodocker":
    exv, evv = runline(C, 0); exp, evp = runline(C, 1)
    ok(exv is not None and exv[0] == "1" and exv[1] == "FAILURE" and exv[2] == "yes", "mvn verify, Maven's DOCKER_HOST tcp://127.0.0.1:1: exit 1 · BUILD FAILURE · offline")
    n = ints(r"'Could not find a valid Docker environment': (\d+) lines$", C)
    ok(n and n[0] >= 1, "R.179: Could not find a valid Docker environment")
    events_ok(evv, 0, "the no-Docker verify"); events_ok(evp, 0, "the no-Docker package")
    f = folders(C); rs = results(C)
    ok(len(f) >= 2 and f[0][1:4] == (f[0][1], 0, 0) and rs and f[0][1] == rs[0][0], "the verify's first folder: surefire-reports, every test passed, = its Results line - before the container tests")
    ok(exp is not None and exp[0] == "0" and exp[1] == "SUCCESS", "mvn package, the same way: exit 0 · BUILD SUCCESS")
    ok(len(f) >= 3 and f[2][1] == f[0][1] and f[2][2:4] == (0, 0) and len(rs) >= 2 and rs[-1][0] == f[2][1], "mvn package: surefire-reports = the verify's first folder, every test passed, = its Results line")
    ok("surefire-reports-it: absent - no container test ran" in C, "mvn package ran no container test")
    done("mvn verify with Maven's DOCKER_HOST pointed at nothing - Could not find a valid Docker environment, exit 1, after the %s tests on H2 passed; mvn package the same way - exit 0, %s tests on H2, no container test" % (f[0][1] if f else "?", f[2][1] if len(f) > 2 else "?"))

# ---- seven -----------------------------------------------------------------------------------------------------------------------
if MODE == "seven":
    s466 = sys.argv[3]
    x = re.search(r"the script's md5: ([0-9a-f]{32}) · xcheck\.sql \(= Course 7's capstone's\): ([0-9a-f]{32}) · cmp: the same, byte for byte", C)
    ok(x is not None and x.group(1) == x.group(2), "Hibernate's schema script over after/'s libraries = xcheck.sql (Course 7's capstone's)")
    h = re.findall(r"^ +exit 0 · the seven responses: 7 lines · md5 ([0-9a-f]{32}) · listening on 20462 now: 0$", C, re.M)
    ok(len(h) == 2 and h[0] == h[1] == s466, "the seven on before/ and after/: 7 lines each, md5 = c7-unit31's S466")
    ok("the seven, after/ against before/: lines that differ: 0" in C, "after/ against before/: 0 lines differ")
    fj = re.findall(r"^ +log: Found 1 (JPA|JDBC) repository interface\.$", C, re.M)
    ok(fj == ["JPA", "JDBC", "JPA", "JDBC"], "both TiffinBox starts: Found 1 JPA + Found 1 JDBC repository interface (S8.21)")
    done("the comparison set on before/'s and after/'s jars (H2, port 20462) - 7 responses each, the same md5 as Course 7's (%s…), 0 lines differ; both modules' Found 1 repository interface lines at each start; Hibernate's schema script = Course 7's capstone's" % s466[:8])

# ---- exercise --------------------------------------------------------------------------------------------------------------------
def blocks(c):
    out = {}
    for sh in ("bash", "zsh"):
        mm = re.search(r"^in " + sh + r" \([^)]*\) - the README's lines, the block's exit (\d+):\n(.*?)^  then the solution's lines, in the same shell - the block's exit (\d+):\n(.*?)^  the shell is now in", c, re.M | re.S)
        if mm:
            out[sh] = (mm.group(1), [l[4:] for l in mm.group(2).splitlines()], mm.group(3), [l[4:] for l in mm.group(4).splitlines()])
    return out


if MODE == "exercise":
    w, q = int(sys.argv[3]), sys.argv[4]
    ok(w == len(q.split()) == 23, "the spoken line: %d words by wc -w = %d by a split - the brief's 23" % (w, len(q.split())))
    b = blocks(C)
    ok(set(b) == {"bash", "zsh"}, "the exercise ran in bash and in zsh")
    ok(b.get("bash") and b.get("zsh") and b["bash"] == b["zsh"], "zsh printed what bash printed, line for line")
    if b.get("bash"):
        e1, r, e2, s = b["bash"]
        ok("the image: sha256:77f585114c32" in r and "the image: sha256:77f585114c32" in s, "both blocks print the pinned image's id first")
        ok("mvn: exit 0" in r and "mvn: exit 0" in s, "both runs exit 0 - the exit proves nothing (R.196)")
        ok("EX the database that answered: H2 2.5.250" in r, "broken: the database that answered is H2 2.5.250")
        ok("EX the database that answered: PostgreSQL 18.6" in s, "solved: the database that answered is PostgreSQL 18.6")
        ok(any(l.startswith("the first SELECT: SELECT customer.ID AS ID") for l in r) and any(l.startswith("the first SELECT: SELECT customer.id AS id") for l in s), "the first SELECT: unquoted on both (Q), H2's upper-case names, PostgreSQL's lower-case")
        fr = [l for l in r if l.startswith("EX findAll(): ")]; fs = [l for l in s if l.startswith("EX findAll(): ")]
        ok(fr and fs and fr == fs, "findAll() reads the same count on both: %s" % (fr[0] if fr else "?"))
    ok(C.count("  after it: images ") == 2, "after each shell: images, volumes and Testcontainers' containers as before")
    done("%d words; Docker and the pinned image needed, the image's id printed first): broken - @Container without @ServiceConnection, mvn exit 0, the database that answered H2 2.5.250, the SELECT upper-case and unquoted; solved by @ServiceConnection - mvn exit 0, PostgreSQL 18.6, the SELECT lower-case and unquoted; bash and zsh the same" % w)

if MODE == "wib":
    b = blocks(read(sys.argv[2]))
    if "bash" not in b:
        sys.exit(1)
    e1, r, e2, s = b["bash"]
    print("\n".join(r if sys.argv[3].endswith("README.md") else s))
    sys.exit(0)

print("unknown mode " + MODE); sys.exit(2)
