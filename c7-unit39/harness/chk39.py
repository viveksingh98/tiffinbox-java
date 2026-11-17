"""Unit 39's checks (python3 -I -B harness/chk39.py MODE ...). Each capture's mode reads its capture (.r-NAME.out) and asserts every
number and string the video may say against another witness of the same run - psql in the run's container, Surefire's two report
folders, the test's own JdbcTemplate, Testcontainers' own log lines and the docker events of the run's window - never against a typed
figure; it prints "ok ..." lines and one "VALUES ..." line, and exits 1 on the first failed assertion. Three helper modes: static (the
shipped test and its pom, before anything runs: R.320, R.333, R.252, R.334), r250 (the gate before any build: C3's file list, every
sentence of after/ C3 makes false rewritten) and wib (an exercise file's "What it prints" block as the bash run printed it)."""
import os, re, sys

MODE = sys.argv[1]
DIGEST = "postgres@sha256:77f585114c32fbca283dc835b0596f4e52b51b4c6662d7810b2f4084f60a1873"
IT = "tiffinbox-web/src/test/java/com/tiffinbox/CustomerEntityRepositoryIT.java"
POM = "tiffinbox-web/pom.xml"
REPO = "tiffinbox-core/src/main/java/com/tiffinbox/CustomerEntityRepository.java"
SLICE = "tiffinbox-web/src/test/java/slice/DataSlice.java"


def ok(cond, what):
    if not cond:
        print("FAIL " + what); sys.exit(1)
    print("ok    " + what)


def lines(p):
    return open(p, encoding="utf-8").read().splitlines()


def flat(t):
    return re.sub(r"\s+", " ", re.sub(r"\n\s*(?:\*|//|#|--|>)?\s*", " ", t))


# ---- static: the shipped test, its pom and the pinned sentences, before anything runs -------------------------------------------
if MODE == "static":
    A, P30, PIN, U06, U36 = sys.argv[2:7]
    it = open(os.path.join(A, IT), encoding="utf-8").read(); pom = open(os.path.join(A, POM), encoding="utf-8").read()
    ok(re.search(r"\bclass CustomerEntityRepositoryIT\b", it) is not None and not re.search(r"class \w+Test\b", it), "R.334: the container test class is named *IT (Surefire's default includes leave it out of package)")
    ok("assertThat(stats.getPrepareStatementCount()).isEqualTo(1L);" in it and "getQueryExecutionCount" not in it, "R.320: the shipped count is getPrepareStatementCount(); getQueryExecutionCount() 0 times in the shipped IT")
    a = it.find("isNotEqualTo(1 + all.size())"); b = it.find("assertThat(stats.getPrepareStatementCount()).isEqualTo(1L);")
    ok(0 < a < b and "new PauseEntity(c, 2)" in it, "R.333: days != 1 + N asserted before the witness binds; the fixture's pauses are 2 days each")
    s30 = open(P30, encoding="utf-8").read().splitlines()[0]
    ok(("        // " + s30) in it.splitlines(), "R.252: U30's counter sentence, byte-equal, in the IT's comment: " + s30)
    pin = open(PIN, encoding="utf-8").read().splitlines()
    S11 = "H2 accepted TiffinBox's old AUTO_INCREMENT line and kept a half-applied migration; PostgreSQL refused the first and rolled back the second."
    ok(pin[0] == S11, "R.252: pinned.txt's first line is Course 11 U11's sentence, byte for byte")
    u06 = open(U06, encoding="utf-8").read(); u36 = open(U36, encoding="utf-8").read()
    ok('ERROR: syntax error at or near\n  "AUTO_INCREMENT"' in u06 or 'syntax error at or near "AUTO_INCREMENT"' in u06, "R.252: unit 06's capture says PostgreSQL refused AUTO_INCREMENT")
    ok("Changes successfully rolled back." in u36 and 'Duplicate column name "PHONE"' in u36 and "half-applied" in u36, "R.252: unit 36's capture says PostgreSQL rolled back and H2 kept a half-applied migration")
    ok(DIGEST in it and "asCompatibleSubstituteFor(\"postgres\")" in it and "@ServiceConnection" in it and "@Testcontainers" in it and not re.search(r"^@AutoConfigureTestDatabase", it, re.M), "the IT: the image by its digest, @ServiceConnection, @Testcontainers, no @AutoConfigureTestDatabase")
    ex = re.findall(r"<execution>\s*<id>([^<]+)</id>\s*<phase>([^<]+)</phase>\s*<goals>\s*<goal>([^<]+)</goal>\s*</goals>\s*<configuration>\s*<includes>\s*<include>([^<]+)</include>\s*</includes>\s*<reportsDirectory>([^<]+)</reportsDirectory>", pom)
    ok(ex == [("container-tests", "integration-test", "test", "**/*IT.java", "${project.build.directory}/surefire-reports-it")], "R.334: the pom's second Surefire execution - container-tests, integration-test, test, **/*IT.java, surefire-reports-it")
    ok(pom.count("<includes>") == 1 and pom.count("<execution>") == 1 and "maven-failsafe-plugin" not in pom, "R.334: no other includes and no other execution - Surefire's default-test keeps its default includes, which leave *IT out; no Failsafe")
    deps = re.findall(r"<artifactId>([^<]+)</artifactId>\s*(?:<scope>([^<]+)</scope>)?", pom.split("<dependencies>", 1)[1].split("</dependencies>", 1)[0])
    want = {"postgresql": "runtime", "spring-boot-starter-data-jpa-test": "test", "spring-boot-testcontainers": "test", "testcontainers-postgresql": "test", "testcontainers-junit-jupiter": "test"}
    got = {a: s for a, s in deps if a in want}
    ok(got == want and not re.search(r"<artifactId>(?:postgresql|testcontainers[a-z-]*)</artifactId>\s*<version>", pom), "C3's dependencies and scopes, no version typed: " + ", ".join("%s %s" % kv for kv in sorted(got.items())))
    sl = open(os.path.join(A, SLICE), encoding="utf-8").read()
    ok(all(x in sl for x in ("@SpringBootConfiguration", "@EntityScan(\"com.tiffinbox\")", "@EnableJpaRepositories(\"com.tiffinbox\")", "@EnableJpaAuditing")), "DataSlice: @SpringBootConfiguration, the scan, the repositories, @EnableJpaAuditing")
    rp = open(os.path.join(A, REPO), encoding="utf-8").read()
    ok("Window<CustomerEntity> findFirst10ByOrderByNameAsc(ScrollPosition position);" in rp and "tie-breaker" in rp and "Course 9's" in rp, "the keyset method, its Javadoc (the id tie-breaker, Course 9's route)")
    sys.exit(0)

# ---- r250 -------------------------------------------------------------------------------------------------------------------
if MODE == "r250":
    A, B = sys.argv[2], sys.argv[3]
    def files(r):
        out = set()
        for d, ds, fs in os.walk(r):
            for f in fs: out.add(os.path.relpath(os.path.join(d, f), r))
        return out
    fa, fb = files(A), files(B)
    changed = sorted(f for f in fa & fb if open(os.path.join(A, f), "rb").read() != open(os.path.join(B, f), "rb").read())
    ok(sorted(fa - fb) == [IT, SLICE] and not (fb - fa) and changed == ["README.md", REPO, POM],
       "C3's file list: new %s; changed %s; deleted or renamed: %s" % (", ".join(sorted(fa - fb)), ", ".join(changed), ", ".join(sorted(fb - fa)) or "none"))
    for f in ("tiffinbox-web/src/main/resources/application.yaml", "compose.yaml", "Dockerfile"):
        ok(open(os.path.join(A, f), "rb").read() == open(os.path.join(B, f), "rb").read(), "unchanged: " + f)
    probe = []; red = []; nodrv = []
    def hits(r, f):
        p = os.path.join(r, f)
        if not os.path.exists(p): return 0
        t = open(p, encoding="utf-8", errors="replace").read()
        return len(re.findall(r"\bPROBE\b|\bRED\b", t))
    for f in sorted(fa):
        if re.search(r"\bPROBE\b", open(os.path.join(A, f), encoding="utf-8", errors="replace").read()): probe.append(f)
        if hits(A, f) > hits(B, f): red.append(f)
    ok(not probe and not red, "after/ holds no PROBE wording, and C3 adds no RED or PROBE word to any file (the README's older RED row numbers are Course 5's and 6's history): %s" % (", ".join(probe + red) or "0 files"))
    R = open(os.path.join(A, "README.md"), encoding="utf-8").read(); FR = flat(R)
    # every sentence that says TiffinBox has no driver, or that Postgres is not under it, carries the unit 39 note
    for pat, note in (("TiffinBox declares no Postgres driver", "Course 7, unit 39: it does since"),
                      ("this tree holds no PostgreSQL driver", "Course 7, unit 39: the tree holds its own driver since"),
                      ("Postgres runs beside TiffinBox, not under it.", "Course 7, unit 39: under it since"),
                      ("the Postgres driver on the class path (not in this project", "Course 7, unit 39: both are, since"),
                      ("the capstone moves TiffinBox's own database.", "Course 7, unit 39: the capstone keeps that default"),
                      ("`mvn -o -B verify` → `BUILD SUCCESS`, exit 0, three runs.", "Course 7, unit 39: `verify` runs the three container tests since"),
                      ("`package` and `install` run the tests now.", "Course 7, unit 39: still the eighteen, on H2 in memory, with no Docker")):
        for mm in re.finditer(re.escape(flat(pat)), FR):
            here = FR[mm.end():mm.end() + 700]
            ok(note in here, "R.250: \"%s\" carries its unit 39 note (%s)" % (pat[:60], note))
        ok(re.search(re.escape(flat(pat)), FR) is not None, "R.250: the sentence is there: " + pat[:60])
    for mm in re.finditer(r"no (?:PostgreSQL|Postgres) driver", FR):
        here = FR[max(0, mm.start() - 400):mm.end() + 400]
        ok("unit 39" in here, "R.250: every \"no PostgreSQL driver\" sentence is within reach of a unit 39 note: …" + FR[max(0, mm.start() - 50):mm.end() + 20])
    head = R.split("\n## ", 1)[0]
    ok("*(Course 7, unit 39, **Section 7's capstone: Course 7's final anchor (C3)**" in head and "unit 40 changes the repository's root README only" in flat(head), "the anchor README's header: unit 39's note - Course 7's final anchor, 40 changes the root README only")
    s39 = R.split("\n## Course 7 · unit 39 — ", 1)
    ok(len(s39) == 2, "the anchor README's unit 39 section")
    s = s39[1].split("\n## ", 1)[0]
    for w in ("**Which tests run where: 18 on H2 in memory, 3 on PostgreSQL in a container.**", "export DOCKER_HOST=unix://$HOME/.orbstack/run/docker.sock", "export TESTCONTAINERS_RYUK_DISABLED=true",
              "mvn -B verify", "Dockerfile's `mvn -B package`", "not measured here", "*Docker Compose for Development*", "*Testing the Web Layer*", "*REST APIs Done Right*", "*Spring Security — complete*",
              "Nothing is deleted or renamed", "the default in-memory run" if "the default in-memory run" in s else "still forgets a customer at a restart, by design"):
        ok(w in s, "the unit 39 section says: " + w[:70])
    ok("TiffinBox runs on PostgreSQL" in flat(s) and "the config tree's URL or the dev profile" in flat(s), "RED #1807: the section's PostgreSQL sentence carries its scope (the config tree's URL or the dev profile)")
    sys.exit(0)

# ---- wib: the block an exercise file must show ------------------------------------------------------------------------------
if MODE == "wib":
    L = lines(sys.argv[2]); f = sys.argv[3]
    b = L.index("in bash (/bin/bash --noprofile --norc) - the README's lines:")
    z = L.index("in zsh (/bin/zsh -f) - the README's lines:")
    B = L[b:z]
    s = [i for i, l in enumerate(B) if l.startswith("  then the solution's lines")][0]
    part = B[1:s] if f.endswith("README.md") else B[s:]
    out = []
    for l in part[1:]:
        if l.startswith("  the shell is now in: "): break
        out.append(l[4:])
    print("\n".join(out)); sys.exit(0)

L = lines(sys.argv[2])


def block(L, head, nxt):
    a = [i for i, l in enumerate(L) if l.startswith(head)]
    ok(len(a) == 1, "the block: " + head[:70])
    a = a[0]; b = [i for i in range(a + 1, len(L)) if any(L[i].startswith(n) for n in nxt)]
    return L[a:b[0] if b else len(L)]


def has(X, line, what):
    ok(line in X, what + ": " + line.strip()[:140])


def after(X, head):
    i = [j for j, l in enumerate(X) if l == head]
    ok(len(i) >= 1, "the read: " + head.strip()[:70])
    out = []
    for l in X[i[0] + 1:]:
        if not l.startswith("    "): break
        out.append(l.strip())
    return out


K = '  -> 201 {"name":"Kavya","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}'

if MODE == "anchor":
    for l in ("  changed: README.md", "  changed: tiffinbox-core/src/main/java/com/tiffinbox/CustomerEntityRepository.java", "  changed: tiffinbox-web/pom.xml",
              "  new: tiffinbox-web/src/test/java/com/tiffinbox/CustomerEntityRepositoryIT.java", "  new: tiffinbox-web/src/test/java/slice/DataSlice.java"):
        has(L, l, "C3")
    ok(not any(l.startswith("  deleted: ") for l in L), "C3: no file deleted")
    lb = [l for l in L if l.startswith("  .harness/before's jar, extracted - lib/: ")][0]; la = [l for l in L if l.startswith("  .harness/after's jar, extracted - lib/: ")][0]
    mb = re.search(r"lib/: (\d+) libraries · postgresql-\*\.jar: (\d+) \(([^)]*)\) · checker-qual-\*\.jar: (\d+) · testcontainers-\*\.jar: (\d+)$", lb)
    ma = re.search(r"lib/: (\d+) libraries · postgresql-\*\.jar: (\d+) \(([^)]*)\) · checker-qual-\*\.jar: (\d+) · testcontainers-\*\.jar: (\d+)$", la)
    ok(mb and ma and mb.group(2) == "0" and ma.group(2) == "1" and ma.group(3) == "postgresql-42.7.14.jar" and ma.group(4) == "1" and ma.group(5) == "0" and mb.group(5) == "0",
       "R.335: before/'s lib/ holds no PostgreSQL driver, after/'s its own (postgresql-42.7.14.jar) and checker-qual; no Testcontainers jar in either")
    ad = [l for l in L if l.startswith("  the libraries after/'s jar adds: ")][0]
    m = re.match(r"^  the libraries after/'s jar adds: (\S+) (\S+) · removes: none$", ad)
    ok(m is not None and sorted(x.split("-")[0] for x in m.groups()) == ["checker", "postgresql"] and int(ma.group(1)) == int(mb.group(1)) + 2, "the jar gains two libraries, the driver and checker-qual: %s -> %s" % (mb.group(1), ma.group(1)))
    Bk = block(L, "B - before/'s jar", ["A - after/'s jar"]); A1 = block(L, "A - after/'s jar", ["A - between the two JVMs"])
    Mid = block(L, "A - between the two JVMs", ["A - JVM 2"]); A2 = block(L, "A - JVM 2", ["A - the anchor's own ddl-auto"]); Em = block(L, "A - the anchor's own ddl-auto", ["A' - the default"])
    P1 = block(L, "A' - the default", ["A' - JVM 2"]); P2 = block(L, "A' - JVM 2", ["C7-3, cited"])
    ok(any(re.fullmatch(r"  exit 1 · it listened on: nothing · ready: no · 'Failed to load driver class org\.postgresql\.Driver' lines in its log: [1-9]\d* · 'Application run failed': 1", l) for l in Bk),
       "B (the failure receipt, R.335): before/'s jar on the config tree's URL refused - exit 1, nothing listened, Failed to load driver class org.postgresql.Driver")
    cz = [l.strip() for l in Bk if l.startswith("  Caused by: ")]
    ok(cz and cz[-1] == "Caused by: java.lang.ClassNotFoundException: org.postgresql.Driver" and any("Failed to load driver class org.postgresql.Driver" in c for c in cz), "B: the chain ends in ClassNotFoundException: org.postgresql.Driver")
    ok("  psql - the database it was given: tables 0" in Bk, "B: psql - the database it was given holds no table (nothing migrated)")
    ok('  Flyway: INFO Migrating schema "public" to version "1 - customer and pause"' in A1 and '  Flyway: INFO Migrating schema "public" to version "3 - customer audit columns"' in A1
       and any(l.startswith('  Flyway: INFO Successfully applied 3 migrations to schema "public", now at version v3') for l in A1), "A JVM 1: Flyway migrates V1-V3 on the fresh database")
    h = after(A1, "  psql - the history table:")
    ok(len(h) == 3 and all(r.endswith("|sa|t") for r in h) and [r.split("|")[1] for r in h] == ["1", "2", "3"], "A (R.313): psql - the history table, %d rows, success t, versions 1-3" % len(h))
    ok(after(A1, "  psql - the id columns (information_schema):") == ["id YES BY DEFAULT", "id YES BY DEFAULT"], "C7-3: psql - customer.id and pause.id are identity columns, BY DEFAULT (V1's GENERATED BY DEFAULT AS IDENTITY)")
    has(A1, K, "A JVM 1: POST Kavya 201")
    sq = [l for l in A1 if l.startswith("  -> 200 · the request's org.hibernate.SQL lines, between its two markers: ")]
    ok(len(sq) == 2 and all(l.endswith(": 4 · WARN lines: 0 · ERROR lines: 0") for l in sq), "A JVM 1: GET /dashboard (HTML and JSON) on PostgreSQL - 4 SQL lines each")
    js = [l for l in A1 if l.startswith("  its JSON: ")][0]
    ok(sorted(re.findall(r'"(\w+)":', js)) == ["customers", "monthRevenue", "names", "pausedDays"], "A: the JSON dashboard's four keys")
    ok(any(l.startswith("  stopped by its pid (SIGTERM): exit ") for l in A1), "A JVM 1: stopped by its pid")
    mid = after(Mid, "A - between the two JVMs, nothing running on u39a: psql - the customers:")
    ok(len(mid) == 5 and mid[4] == "5 Kavya" and [x.split()[1] for x in mid[:4]] == ["Ravi", "Meera", "Sunil", "Priya"], "the hook's first witness - psql between the JVMs: %d rows, Kavya id 5 among them" % len(mid))
    ok("  Flyway: INFO Current version of schema \"public\": 3" in A2 and '  Flyway: INFO Schema "public" is up to date. No migration necessary.' in A2, "A JVM 2: Flyway - version 3, up to date, no migration")
    ok(any(l.startswith("  -> 200 {") and '"name":"Kavya"' in l for l in A2) and "  -> 200 · customers listed: 5 (Kavya Meera Priya Ravi Sunil)" in A2, "the hook's second witness - JVM 2: GET /customers/Kavya 200, 5 listed")
    has(Em, "  PROBE emf hibernate.hbm2ddl.auto = validate", "R.330: the anchor's EMF on PostgreSQL says validate")
    ok("  PROBE ready: yes" in Em and "  PROBE version: Flyway 12.4.0" in Em and "  PROBE version: Hibernate 7.4.13.Final" in Em and "  PROBE version: Spring Boot 4.1.2" in Em and "  PROBE version: Spring Framework 7.0.10" in Em and "  PROBE version: Spring Data JPA 4.1.2" in Em, "the Emf JVM: started (validate passing), its version lines (R.329)")
    hh = after(Em, "  psql - the history table at the end:"); ok(len(hh) == 3, "the history table at the end: still 3 rows")
    has(P1, K, "A' JVM 1: POST Kavya 201 on the default (H2 in memory)")
    ok(any(l.startswith("  -> 404 ") and "Kavya" in l for l in P2) and "  -> 200 · customers listed: 4 (Meera Priya Ravi Sunil)" in P2, "A' JVM 2 (C7-1's remaining scope): the default run forgets her - GET /customers/Kavya 404, 4 listed")
    has(L, "C7-3, cited - the identity line in after/'s V1 (tiffinbox-core/src/main/resources/db/migration/V1__customer_and_pause.sql, grep -c): GENERATED BY DEFAULT AS IDENTITY 2 · AUTO_INCREMENT 0", "C7-3: V1's two identity columns, no AUTO_INCREMENT")
    has(L, '  the line PostgreSQL refused before it, quoted from the README of *Ids and Generation Strategies* (its pgstart capture): Caused by: org.postgresql.util.PSQLException: ERROR: syntax error at or near "AUTO_INCREMENT"', "C7-3: unit 06's refusal, quoted")
    has(L, '  Flyway\'s failed V3, quoted from the README of *Flyway: Versioned Migrations* (its fail capture): PostgreSQL - failed! Changes successfully rolled back. · H2 - Duplicate column name "PHONE", the half-applied column', "R.252: unit 36's two halves, quoted")
    has(L, "Flyway's version in TiffinBox's JVMs (R.329): Boot prints none; the jar on their class path, the file VersionPrinter.getVersion() reads (unzip -p flyway-core-12.4.0.jar org/flywaydb/core/internal/version.txt): 12.4.0", "R.329 for TiffinBox's JVMs")
    print("VALUES the jar's libraries %s -> %s (+ postgresql-42.7.14.jar, + checker-qual); B (before/'s jar on the config tree's URL, no driver): exit 1, nothing listened, Failed to load driver class org.postgresql.Driver <- ClassNotFoundException: org.postgresql.Driver; A (after/'s jar, its own driver, the config tree's URL): Flyway migrates V1-V3, history 3 rows success t, POST Kavya 201, GET /dashboard 200 with 4 SQL lines (HTML and JSON), the JSON's four keys, stopped by its pid; psql between the JVMs: 5 rows, 5 Kavya; JVM 2: Schema \"public\" is up to date. No migration necessary., GET /customers/Kavya 200, 5 listed; the anchor's EMF hibernate.hbm2ddl.auto = validate; A' (the default java -jar, H2 in memory): POST Kavya 201, the restart -> GET /customers/Kavya 404, 4 listed; C7-3: V1's GENERATED BY DEFAULT AS IDENTITY twice, id YES BY DEFAULT by psql, unit 06's syntax error at or near \"AUTO_INCREMENT\" quoted"
          % (mb.group(1), ma.group(1)))
    sys.exit(0)

if MODE == "dev":
    ok([re.sub(r"\s+", " ", l.strip()) for l in L if l.startswith("  < ") or l.startswith("  > ")] == ["< name: tiffinbox-dev", "> name: c7u39-dev", '< - "127.0.0.1:18881:5432"', '> - "127.0.0.1:20187:5432"'], "the compose COPY: the project name and the port alone differ (c7u39-dev, 127.0.0.1:20187)")
    has(L, "  the YAML's tiffinbox.jdbc-url, after/ (no flag here changes it): jdbc-url: jdbc:h2:mem:tiffinbox;DB_CLOSE_DELAY=-1", "R.325: tiffinbox.jdbc-url still says H2")
    J1 = block(L, "dev - JVM 1", ["dev - JVM 2"]); J2 = block(L, "dev - JVM 2", ["$ docker -H"])
    for nm, X in (("JVM 1", J1), ("JVM 2", J2)):
        ok(any(l.startswith("  compose: Using Docker Compose file ") and l.endswith("/.harness/dev/compose.yaml") for l in X), nm + ": Using Docker Compose file …/.harness/dev/compose.yaml")
        ok(any(re.fullmatch(r"  compose: +Container c7u39-dev-postgres-1 +Started", l) for l in X) and any(re.fullmatch(r"  compose: +Container c7u39-dev-postgres-1 +Healthy", l) for l in X), nm + ": Container c7u39-dev-postgres-1 Started, Healthy")
        has(X, "  HHH10001005 - the database Hibernate connected to: Database JDBC URL [jdbc:postgresql://127.0.0.1:20187/tiffinbox]", nm + " (R.325): which database answered - Hibernate's HHH10001005 URL, the compose copy's")
        ok(any(l.startswith("  the copy's container after the stop: c7u39-dev-postgres-1 Exited (0) · its named volume: c7u39-dev_data") for l in X), nm + ": Boot stopped the container (Exited (0)), the named volume c7u39-dev_data kept")
    ok(any(l.startswith('  Flyway: INFO Successfully applied 3 migrations to schema "public", now at version v3') for l in J1), "JVM 1: Flyway migrates V1-V3 on the copy's database")
    has(J1, K, "JVM 1: POST Kavya 201")
    ok('  Flyway: INFO Schema "public" is up to date. No migration necessary.' in J2, "JVM 2: up to date")
    ok(any(l.startswith("  -> 200 {") and '"name":"Kavya"' in l for l in J2) and "  -> 200 · customers listed: 5 (Kavya Meera Priya Ravi Sunil)" in J2, "JVM 2: GET /customers/Kavya 200 through the named volume, 5 listed")
    has(L, "  left of project c7u39-dev: containers 0 · volumes 0 · networks 0 (the volume count is asserted at the end of the run, R.322)", "compose down -v on the copy: 0 containers, 0 volumes, 0 networks of the project")
    print("VALUES a COPY of compose.yaml (project c7u39-dev, 127.0.0.1:20187): the dev profile from Maven's class path - Using Docker Compose file, Container c7u39-dev-postgres-1 Started and Healthy, Flyway migrates V1-V3, HHH10001005 Database JDBC URL [jdbc:postgresql://127.0.0.1:20187/tiffinbox] while tiffinbox.jdbc-url still says jdbc:h2:mem:tiffinbox;DB_CLOSE_DELAY=-1 (two URLs, one used), POST Kavya 201, the stop leaves the container Exited (0) and the volume c7u39-dev_data; JVM 2: up to date, GET /customers/Kavya 200 through the named volume; down -v: 0 containers, 0 volumes, 0 networks left")
    sys.exit(0)


def rep(X, folder):
    i = [j for j, l in enumerate(X) if l == "  Surefire's reports, %s (read by harness/surefire.py):" % folder]
    ok(len(i) == 1, "the reports of " + folder)
    out = []
    for l in X[i[0] + 1:]:
        if not l.startswith("    "): break
        out.append(l[2:])
    return out


def total(R):
    t = [l for l in R if l.startswith("  in all: ")]
    ok(len(t) == 1, "a report total")
    return tuple(int(x) for x in re.match(r"^  in all: (\d+) reports · tests (\d+) · failures (\d+) · errors (\d+) · skipped (\d+)$", t[0]).groups())


def tcrun(X, what, creates="1"):
    ok(any(l == "  the engine's events over its window (the pinned CLI): image pull 0 · container create %s (%s) · Testcontainers containers left: 0" % (creates, DIGEST) for l in X), what + ": the events - %s container create of the digest, 0 image pulls, 0 containers left" % creates)
    ok(any(l == "  Ryuk's three checks (R.318): pre-flight PASS · the log: 'Ryuk has been disabled' 1 · the events: %s container create of the digest, 0 others, 0 image pulls" % creates for l in X), what + ": Ryuk's three checks")
    ok(any(l == "  Testcontainers in its log: 'Testcontainers version: 2.0.5' 1 · 'Found Docker environment with Environment variables' 1 · Resolved dockerHost=unix://~/.orbstack/run/docker.sock · 'Ryuk has been disabled' 1 · Creating container for image: " + DIGEST for l in X), what + " (R.329, R.318): Testcontainers version: 2.0.5, Found Docker environment with Environment variables, the socket, Ryuk disabled, the digest")
    ok("  the mapped port: read off the run (Testcontainers' JDBC URL line and the test's own URL agree), masked: localhost:<port>" in X, what + " (R.319): the mapped port read off the run, masked")


if MODE == "tests":
    V = block(L, "tests - TiffinBox's tests", ["tests - mvn package"]); Pk = block(L, "tests - mvn package", ["tests - R.179"])
    N = block(L, "tests - R.179", ["tests - the two counter plants"]); Pl = block(L, "tests - the two counter plants", ["@@none"])
    ok(any(l.startswith("  pre-flight (R.318): /_ping OK on unix://~/.orbstack/run/docker.sock · TESTCONTAINERS_RYUK_DISABLED=true · the receipt home's .testcontainers.properties: checks.disable tinyimage.container.image, ryuk.* keys 0") for l in V), "the pre-flight (R.318)")
    ok("  exit 0 · BUILD SUCCESS · offline: yes · its alarm's cap: 600 (R.247)" in V, "mvn verify under the recipe: exit 0, offline")
    tcrun(V, "verify")
    r1 = rep(V, "tiffinbox-web/target/surefire-reports"); r2 = rep(V, "tiffinbox-web/target/surefire-reports-it")
    for l in ("  TEST-com.tiffinbox.web.TiffinBoxWebTest.xml: tests 14 · failures 0 · errors 0 · skipped 0", "  TEST-com.tiffinbox.web.FullStackTest.xml: tests 3 · failures 0 · errors 0 · skipped 0", "  TEST-com.tiffinbox.web.FeedTest.xml: tests 1 · failures 0 · errors 0 · skipped 0"):
        has(r1, l, "surefire-reports")
    has(r2, "  TEST-com.tiffinbox.CustomerEntityRepositoryIT.xml: tests 3 · failures 0 · errors 0 · skipped 0", "surefire-reports-it")
    for t in ("theMigrationsAreTheSchema", "theDashboardReadIsOneStatementHoweverManyCustomers", "theCustomersComeTenAtATimeByKeyset"): has(r2, "    passed  " + t, "the IT")
    t1 = total(r1); t2 = total(r2)
    ok(t1[2:] == (0, 0, 0) and t2[2:] == (0, 0, 0) and t1[0] == 3 and t2[0] == 1, "R.321: both report folders - failures 0, errors 0, skipped 0 (%d + %d reports)" % (t1[0], t2[0]))
    n21 = t1[1] + t2[1]
    ok(t1[1] == 18 and t2[1] == 3, "R.321: Surefire's reports - %d on H2 in memory + %d on PostgreSQL in a container = %d, read, never typed" % (t1[1], t2[1], n21))
    res = [l for l in V if l.startswith("  Surefire's Results line: ")]
    ok(res == ["  Surefire's Results line: Tests run: %d, Failures: 0, Errors: 0, Skipped: 0" % t1[1], "  Surefire's Results line: Tests run: %d, Failures: 0, Errors: 0, Skipped: 0" % t2[1]], "the console's two Results lines agree with the reports")
    itl = after(V, "  the test's own lines (IT, its stdout):")
    ok(itl[0] == "IT the database: jdbc:postgresql://localhost:<port>/test?loggerLevel=OFF · PostgreSQL 18.6", "the IT's database - PostgreSQL 18.6, the port masked: " + itl[0])
    ok("IT flyway_schema_history: 3 rows [1 customer and pause true, 2 seed true, 3 customer audit columns true]" in itl and "IT hibernate.hbm2ddl.auto = validate" in itl, "(i) the migrations are the schema - flyway_schema_history 3 rows by JdbcTemplate, validate")
    ok("IT a saved customer's stamps: createdAt set · updatedAt set" in itl, "the slice's @EnableJpaAuditing - a saved customer's stamps set")
    cl = [l for l in itl if l.startswith("IT customers ")]
    m = re.fullmatch(r"IT customers (\d+) · paused days (\d+) · prepareStatementCount (\d+)", cl[0]) if len(cl) == 1 else None
    ok(m is not None and m.group(3) == "1", "(ii) the count line: " + (cl[0] if cl else "none"))
    nn, days = int(m.group(1)), int(m.group(2))
    ok(days != 1 + nn, "R.333: the witness never equals another number on its line - paused days %d != 1 + N = %d" % (days, 1 + nn))
    w = [l for l in itl if l.startswith("IT window ")]
    ws = [re.match(r"IT window (\d+): (\d+) customers, from (.+) to (.+) · hasNext (true|false)$", l).groups() for l in w]
    ok([x[1] for x in ws] == ["10", "10", "10", "10"] and [x[4] for x in ws] == ["true", "true", "true", "false"] and sum(int(x[1]) for x in ws) == nn, "(iii) the keyset windows - %s, hasNext false on the fourth, %d customers in all" % (" · ".join(x[1] for x in ws), nn))
    KS = "select ce1_0.id,ce1_0.created_at,ce1_0.meal_type,ce1_0.meals_per_day,ce1_0.name,ce1_0.price_per_meal,ce1_0.updated_at,ce1_0.version from customer ce1_0 where ce1_0.name>? or ce1_0.name=? and ce1_0.id>? order by ce1_0.name,ce1_0.id fetch first ? rows only"
    ks = [l for l in V if l.startswith("  the keyset read's SQL")][0]
    ok(("the first of its lines: " + KS + " · such lines: 3 · the first window's read (no WHERE): 1") in ks, "R.235: the keyset SQL - the id tie-breaker Spring Data adds, in the WHERE and the ORDER BY; 3 such reads after the first window's")
    has(V, "  HHH10001005 in the container tests' JVM - the database Hibernate connected to: Database JDBC URL [jdbc:postgresql://localhost:<port>/test?loggerLevel=OFF]", "R.325: the container tests' HHH10001005 URL (masked)")
    vl = [l for l in V if l.startswith("  version lines in its log (R.329): ")]
    mv = re.fullmatch(r"  version lines in its log \(R\.329\): HHH000001 7\.4\.13\.Final (\d+) · Boot's banner \(v4\.1\.2\) (\d+) · Testcontainers 2\.0\.5 (\d+) · Flyway: the jar on the tests' class path, its version\.txt: 12\.4\.0", vl[0]) if vl else None
    ok(mv is not None and mv.group(1) == "2" and int(mv.group(2)) >= 2 and mv.group(3) == "1", "R.329: HHH000001 in both Surefire forks (the 18's and the IT's), Boot 4.1.2's banner in every context, Testcontainers 2.0.5 in the IT's fork, Flyway 12.4.0's jar")
    # (b) package without Docker
    ok("  exit 0 · BUILD SUCCESS · offline: yes · its alarm's cap: 600 (R.247)" in Pk and "  the engine's events over its window (the pinned CLI): image pull 0 · container create 0 (none) · Testcontainers containers left: 0" in Pk, "R.334: mvn package with Maven's DOCKER_HOST at nothing - exit 0, 0 container creates")
    ok(any(re.fullmatch(r"  the pinned CLI meanwhile: info exit 0 · images [1-9]\d* \(non-empty\)", l) for l in Pk), "R.332: the pinned CLI answers during the plant, a non-empty baseline")
    ok(("    in all: 3 reports · tests %d · failures 0 · errors 0 · skipped 0" % t1[1]) in Pk and "  tiffinbox-web/target/surefire-reports-it: absent - no container test ran" in Pk, "R.334: package runs the %d alone - no container test" % t1[1])
    # (c) verify without Docker: R.179
    ok("  exit 1 · BUILD FAILURE · offline: yes · its alarm's cap: 600 (R.247)" in N and any(re.fullmatch(r"  'Could not find a valid Docker environment' lines in its log: [1-9]\d*", l) for l in N), "R.179: mvn verify without Docker - exit 1, BUILD FAILURE, Could not find a valid Docker environment")
    n1 = total(rep(N, "tiffinbox-web/target/surefire-reports")); rn = rep(N, "tiffinbox-web/target/surefire-reports-it"); n2 = total(rn)
    has(rn, "  TEST-com.tiffinbox.CustomerEntityRepositoryIT.xml: tests 1 · failures 0 · errors 1 · skipped 0", "R.321: the IT's report - tests 1, errors 1 (the class failed before its tests)")
    ok(n1[1:] == (t1[1], 0, 0, 0) and n2[1:] == (1, 0, 1, 0), "R.321: %d pass on H2, then the container class counts 1 error in place of its %d tests: %d + %d = %d - never \"passed\"" % (n1[1], t2[1], n1[1], n2[1], n1[1] + n2[1]))
    ok("  the engine's events over its window (the pinned CLI): image pull 0 · container create 0 (none) · Testcontainers containers left: 0" in N, "R.179's run: 0 container creates")
    # (d) the plants
    P1 = block(Pl, "  NPlusOneIT - ", ["  WrongCounterIT - "]); P2 = block(Pl, "  WrongCounterIT - ", ["  the shipped IT's counter"])
    for X in (P1, P2):
        ok("    > var all = customers.findAll(Sort.by(\"name\"));" in X and "    < var all = customers.findAllByOrderByNameAsc();" in X, "the plant: the N+1 read, findAll(Sort.by(\"name\"))")
    ok("    > assertThat(stats.getQueryExecutionCount()).isEqualTo(1L);" in P2 and not any("getQueryExecutionCount" in l for l in P1), "the second plant alone counts with getQueryExecutionCount()")
    ok("  exit 1 · BUILD FAILURE · offline: yes · its alarm's cap: 600 (R.247)" in P1, "R.320: the N+1 read under the shipped counter - red, exit 1")
    tcrun(P1, "the N+1 plant"); tcrun(P2, "the wrong-counter plant")
    f1 = [l for l in P1 if l.startswith("      FAILED  theDashboardReadIsOneStatementHoweverManyCustomers - ")]
    ok(len(f1) == 1 and "        expected: 1L" in P1 and "        but was: 41L" in P1, "R.320: the N+1 plant fails expected: 1L but was: 41L")
    c1 = [l for l in P1 if l.startswith("  its count line: ")][0]
    m1 = re.fullmatch(r"  its count line: IT customers (\d+) · paused days (\d+) · prepareStatementCount (\d+)", c1)
    ok(m1 is not None and m1.group(3) == "41" and int(m1.group(3)) == 1 + int(m1.group(1)) and int(m1.group(2)) != int(m1.group(3)), "R.333: on the plant's own line the days (%s) differ from the counted statements (%s = 1 + %s)" % (m1.group(2), m1.group(3), m1.group(1)))
    ok("  exit 0 · BUILD SUCCESS · offline: yes · its alarm's cap: 600 (R.247)" in P2 and "      passed  theDashboardReadIsOneStatementHoweverManyCustomers" in P2, "R.320 (R.284 inside a test): the same N+1 asserted by getQueryExecutionCount() - green, exit 0")
    c2 = [l for l in P2 if l.startswith("  its count line: ")][0]
    ok(c2 == c1, "the wrong counter's plant prints the same line - prepareStatementCount 41 - and passes")
    has(Pl, "  the shipped IT's counter (grep): getPrepareStatementCount() asserted 1 · getQueryExecutionCount() 0", "R.320: the shipped test's counter")
    print("VALUES which tests run where: %d on H2 in memory, %d on PostgreSQL in a container; mvn verify under the recipe (DOCKER_HOST=unix://$HOME/.orbstack/run/docker.sock, TESTCONTAINERS_RYUK_DISABLED=true, a receipt home): exit 0, surefire-reports %d (TiffinBoxWebTest 14, FullStackTest 3, FeedTest 1) + surefire-reports-it CustomerEntityRepositoryIT %d = %d, failures 0, errors 0; Testcontainers version: 2.0.5, Found Docker environment with Environment variables, Ryuk has been disabled 1, 1 container create of the digest, 0 image pulls, 0 containers left; the mapped port read off the run, masked <port>; IT: PostgreSQL 18.6, flyway_schema_history 3 rows, hbm2ddl.auto validate, a saved customer's stamps set (the slice's @EnableJpaAuditing); %s (days %d != 1 + N = %d); windows %s, hasNext false on the fourth; the keyset SQL %s; mvn package with Maven's DOCKER_HOST at nothing: exit 0, %d, 0 container creates; mvn verify the same: exit 1, %d + %d = %d (the IT class errors 1), Could not find a valid Docker environment, BUILD FAILURE; the N+1 plant: expected: 1L but was: 41L (%s), exit 1; the same N+1 with getQueryExecutionCount(): green, exit 0 - shown, never shipped"
          % (t1[1], t2[1], t1[1], t2[1], n21, cl[0][3:], days, 1 + nn, " · ".join(x[1] for x in ws), KS, t1[1], n1[1], n2[1], n1[1] + n2[1], c1.split(": ", 1)[1][3:]))
    sys.exit(0)

if MODE == "seven":
    S466 = sys.argv[3]
    ok(sum(1 for l in L if l == "  exit 0 · the seven responses: 7 lines · md5 " + S466) == 3, "the seven %s on before/ and after/ (H2 over TCP) and on after/ on PostgreSQL" % S466)
    has(L, "  the seven, after/ against before/ (H2): lines that differ: 0 · after/ on PostgreSQL against after/ on H2: 0", "the same bytes")
    q = [l for l in L if l.startswith("  its log's org.hibernate.SQL lines during the seven: ")]
    ok(len(q) == 3 and len(set(q)) == 1, "the SQL lines during the seven, the same on all three: " + q[0].split(": ")[1])
    ok(sum(1 for l in L if l.startswith("  its log before the seven: 'Successfully applied 3 migrations' 1")) == 3, "V1-V3 migrated before each seven")
    print("VALUES %s on before/ and after/ (H2 over TCP) and on after/ on PostgreSQL (its own driver, the config tree's URL) - the same bytes; SQL lines during it %s on all three" % (S466, q[0].split(": ")[1]))
    sys.exit(0)

if MODE == "xcheck":
    X38, XF = sys.argv[3], sys.argv[4]
    md = [l for l in L if l.startswith("  after/'s md5: ")][0]
    m = re.match(r"^  after/'s md5: ([0-9a-f]{32}) · the filed xcheck\.sql: ([0-9a-f]{32}) · cmp: the same, byte for byte · the auditing lesson's xcheck\.sql: ([0-9a-f]{32}) · diff: 0 lines$", md)
    ok(m is not None and m.group(1) == XF == X38 == m.group(3), "xcheck: Hibernate's script = the filed xcheck.sql = the auditing lesson's, diff 0 - C3 moves no mapping: " + (m.group(1) if m else md))
    has(L, "  INFO  [main] org.hibernate.orm.core : HHH000001: Hibernate ORM core version 7.4.13.Final", "HHH000001")
    has(L, "  exit 0 · its WARN lines: 0 · its org.flywaydb lines: 0 · Flyway's jar on its class path: 0", "no Flyway in the xcheck JVM")
    print("VALUES Hibernate's script over after/'s libraries %s = the auditing lesson's, byte for byte (the keyset method and the tests move no mapping)" % m.group(1))
    sys.exit(0)

if MODE == "exercise":
    EXW, EXQ = sys.argv[3], sys.argv[4]
    b = L.index("in bash (/bin/bash --noprofile --norc) - the README's lines:"); z = L.index("in zsh (/bin/zsh -f) - the README's lines:")
    ok(L[b + 1:z] == L[z + 1:z + 1 + (z - b - 1)], "exercise: bash and zsh print the same")
    B = L[b:z]; s = [i for i, l in enumerate(B) if l.startswith("  then the solution's lines")][0]
    R, So = B[:s], B[s:]
    for X in (R, So):
        has(X, "    embedded H2 (the slice's own database): 1", "R.196: the exercise runs on embedded H2 - no Docker")
        ok(any(re.fullmatch(r"    EX customers 40, paused days 77, counted \d+", l) for l in X), "the exercise's count line")
    has(R, "    Maven: exit 0", "the README: the test passes (green)"); has(R, "    EX customers 40, paused days 77, counted 1", "the README: getQueryExecutionCount() counts 1 on the N+1 read")
    has(R, "    the assertion: passed", "the README: no assertion failed")
    has(So, "    Maven: exit 1", "the solution: the test fails (red) - it catches the extra statements")
    has(So, "    EX customers 40, paused days 77, counted 41", "the solution: getPrepareStatementCount() counts 41")
    ok("    expected: 1L" in So and "     but was: 41L" in So, "the solution: expected: 1L but was: 41L")
    ok(sum(1 for l in B if l.startswith("  the shell is now in: this unit's folder")) == 2, "the shell back in this folder")
    ok(any(l.endswith("DOCKER_HOST in its environment: 0") for l in B), "the exercise's shell holds no DOCKER_HOST")
    ok(EXW == str(len(EXQ.split())), "the spoken line: %s words (wc -w, and split here)" % EXW)
    print("VALUES the data slice on embedded H2 (no Docker), 40 customers, paused days 77, the N+1 read: getQueryExecutionCount() counts 1 and the test passes (Maven exit 0); the solution getPrepareStatementCount() counts 41 -> expected: 1L but was: 41L, Maven exit 1 (%s words)" % EXW)
    sys.exit(0)
sys.exit("unknown mode " + MODE)
