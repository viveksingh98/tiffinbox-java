"""Unit 02's checks (python3 -I -B harness/chk02.py MODE ...). Modes: static TREE (C1's shape in the shipped tree, before anything
runs: the two POM lines with no version typed, TiffinBoxApp's three annotations, JdbcNames' post-processor, CustomerRow's mapping
against V1's columns, no V4), names TREE (R.354: every repository interface's simple name, its module read off its domain type's
annotation, none repeated - exit 1 when one is), r250 AFTER BEFORE (the gate before any build: every anchor README sentence C1 makes
false, each found in before/ and rewritten or noted in after/), one mode per capture (anchor, quote, dup, dirty, lazy, seven,
exercise: each reads the capture and asserts every number and string the video may say against another line of the same run,
printing VALUES - the values block's words - last), and wib CAPTURE FILE (what an exercise file's block printed, from the capture).
A failed assertion prints FAIL and exits 1."""
import os, re, sys

MODE = sys.argv[1]
BAD = []


def ok(cond, what):
    if cond:
        print("ok " + what)
    else:
        print("FAIL " + what)
        BAD.append(what)


def done(values=None):
    if values is not None:
        print("VALUES " + values)
    sys.exit(1 if BAD else 0)


def read(p):
    with open(p, encoding="utf-8") as f:
        return f.read()


# ---- static ------------------------------------------------------------------------------------------------------------------
if MODE == "static":
    t = sys.argv[2]
    core = read(os.path.join(t, "tiffinbox-core/pom.xml")); web = read(os.path.join(t, "tiffinbox-web/pom.xml"))
    dep = lambda pom, a: re.search(r"<dependency>\s*<groupId>[^<]+</groupId>\s*<artifactId>" + re.escape(a) + r"</artifactId>\s*</dependency>", pom)
    ok(dep(core, "spring-data-jdbc") is not None, "tiffinbox-core/pom.xml declares spring-data-jdbc, no version typed (Boot's parent manages it)")
    ok(dep(web, "spring-boot-starter-data-jdbc") is not None, "tiffinbox-web/pom.xml declares spring-boot-starter-data-jdbc, no version typed")
    ok(dep(web, "spring-boot-starter-data-jpa") is not None, "tiffinbox-web/pom.xml keeps spring-boot-starter-data-jpa (Spring Data JPA stays)")
    app = read(os.path.join(t, "tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxApp.java"))
    for a in ('@EnableJpaRepositories("com.tiffinbox")', '@EnableJdbcRepositories("com.tiffinbox.jdbc")', "@Import(JdbcNames.class)", "@EnableJpaAuditing"):
        ok(re.search(r"^" + re.escape(a) + r"$", app, re.M) is not None, "TiffinBoxApp carries " + a)
    jn = read(os.path.join(t, "tiffinbox-core/src/main/java/com/tiffinbox/jdbc/JdbcNames.java"))
    ok("postProcessBeforeInitialization" in jn and "setForceQuote(false)" in jn and "@Configuration" in jn and "static BeanPostProcessor" in jn,
       "JdbcNames: a @Configuration whose static BeanPostProcessor calls setForceQuote(false) before initialisation (Q)")
    cr = read(os.path.join(t, "tiffinbox-core/src/main/java/com/tiffinbox/jdbc/CustomerRow.java"))
    ok('@Table("customer")' in cr and '@MappedCollection(idColumn = "customer_id")' in cr and "@Version" in cr and "@Id" in cr,
       "CustomerRow: @Table(\"customer\"), @Id, @Version, @MappedCollection(idColumn = \"customer_id\")")
    v1 = read(os.path.join(t, "tiffinbox-core/src/main/resources/db/migration/V1__customer_and_pause.sql"))
    cols = re.findall(r"^\s+([a-z_]+)\s+[A-Z]", v1.split("CREATE TABLE pause")[0], re.M)
    fields = re.findall(r"^    private (?!Set<)[A-Za-z<>]+ ([a-zA-Z]+);", cr, re.M)
    snake = [re.sub(r"([A-Z])", lambda mm: "_" + mm.group(1).lower(), f) for f in fields]
    ok(sorted(snake) == sorted(cols), "CustomerRow's fields are V1's customer columns, by name: %s" % ", ".join(snake))
    pr = read(os.path.join(t, "tiffinbox-core/src/main/java/com/tiffinbox/jdbc/PauseRow.java"))
    pf = re.findall(r"^    private [A-Za-z]+ ([a-zA-Z]+);", pr, re.M)
    ok(pf == ["id", "days"] and '@Table("pause")' in pr, "PauseRow: @Table(\"pause\"), id and days - customer_id is the collection's")
    mig = sorted(os.listdir(os.path.join(t, "tiffinbox-core/src/main/resources/db/migration")))
    ok(mig == ["V1__customer_and_pause.sql", "V2__seed.sql", "V3__customer_audit_columns.sql"], "Flyway's migrations: V1-V3, no V4 (%d files)" % len(mig))
    done()

# ---- names (R.354) -------------------------------------------------------------------------------------------------------------
if MODE == "names":
    t = sys.argv[2]
    src = {}; files = []
    for r in ("tiffinbox-core/src/main/java", "tiffinbox-web/src/main/java"):
        for d, _, fs in os.walk(os.path.join(t, r)):
            for f in fs:
                if f.endswith(".java"):
                    txt = read(os.path.join(d, f)); files.append((os.path.join(d, f), txt)); src.setdefault(f[:-5], txt)
    repos = []
    for n, s in sorted(files):
        mm = re.search(r"public interface (\w+) extends [^{]*?(?:Repository)<(\w+), *\w+>", s)
        if mm:
            dom = src.get(mm.group(2), "")
            mod = "Spring Data JPA" if re.search(r"^@Entity$", dom, re.M) else "Spring Data JDBC" if re.search(r'^@Table\("', dom, re.M) and "jakarta.persistence" not in dom else "unclaimed"
            repos.append((mm.group(1), mod, mm.group(2)))
    for r in repos:
        print("repository interface %s - %s (its domain type %s)" % r)
    names = [r[0] for r in repos]
    lower = [x[0].lower() + x[1:] for x in names]
    rep = sorted({x for x in lower if lower.count(x) > 1})
    print("bean names (the simple name, first letter lower-case): %s · repeated: %d%s" % (", ".join(lower), len(rep), (" (" + ", ".join(rep) + ")") if rep else ""))
    sys.exit(1 if rep or not repos else 0)

# ---- r250 ------------------------------------------------------------------------------------------------------------------------
if MODE == "r250":
    a, b = sys.argv[2], sys.argv[3]
    ra = read(os.path.join(a, "README.md")); rb = read(os.path.join(b, "README.md"))
    flat = lambda x: re.sub(r"\s+", " ", x)
    fa, fb = flat(ra), flat(rb)
    # every sentence of the anchor README that C1 makes false, as before/ says it, and the note after/ adds right after it
    S = [("every file is byte-identical except this README, which gains only this header",
          "*(Course 8, unit 02: no longer — seven files besides this README differ since, C1; its section below)*"),
         ("(`CustomerEntityRepositoryIT`, started from `slice/DataSlice`, run by `mvn verify` only).",
          "*(Course 8, unit 02, **Course 8's first change to this folder (C1)**: the data layer has two Spring Data modules since"),
         ("each unit that changes this folder records it below as a `## Course 8 · unit NN` section, as Course 7's did.",
          "*(Course 8, unit 02: Spring Data JDBC is beside Spring Data JPA since"),
         ("and the unit sections keep their history.",
          "*(Course 8, unit 02: below the rule the Course 8 unit sections come first")]
    for s, note in S:
        ok(s in fb, "R.250: before/README.md says: " + s[:90])
        ok(flat(s + " " + note) in fa, "R.250: after/README.md notes it in place: " + note[:90])
    ok("\n## Course 8 · unit 02 — " in ra and "\n## Course 8 · unit 02 — " not in rb, "after/README.md has unit 02's section (C1), before/ none")
    for w in ("one data module", "the only repository", "Spring Data JPA owns the data layer", "a single Spring Data module", "the one repository"):
        ok(w.lower() not in fa.lower(), "R.250: after/README.md never says \"%s\"" % w)
    sec = ra.split("\n## Course 8 · unit 02 — ")[1].split("\n---\n")[0] if "\n## Course 8 · unit 02 — " in ra else ""
    for w in ("CustomerRow", "PauseRow", "CustomerAggregates", "JdbcNames", "@EnableJdbcRepositories(\"com.tiffinbox.jdbc\")", "@Import(JdbcNames.class)",
              "spring-data-jdbc", "spring-boot-starter-data-jdbc", "JpaRepositoryFactoryBean", "JdbcRepositoryFactoryBean", "JpaTransactionManager",
              "Multiple Spring Data modules found, entering strict repository configuration mode"):
        ok(w in sec, "unit 02's section names " + w)
    done()

# ---- wib -----------------------------------------------------------------------------------------------------------------------
if MODE == "wib":
    cap, f = read(sys.argv[2]), sys.argv[3]
    part = cap.split("in bash (/bin/bash --noprofile --norc) - the README's lines:")[1].split("\nin zsh (")[0]
    key = "  the block's exit" if f.endswith("README.md") else "  then the solution's lines"
    blk = part.split(key)[1].split("\n", 1)[1]
    out = []
    for l in blk.split("\n"):
        if not l.startswith("    "):
            break
        out.append(l[4:])
    print("\n".join(out))
    sys.exit(0)

# ---- the captures ------------------------------------------------------------------------------------------------------------------
cap = read(sys.argv[2]) if len(sys.argv) > 2 else ""


def grab(rx, what, text=None, g=1):
    mm = re.search(rx, cap if text is None else text, re.M)
    ok(mm is not None, what)
    return mm.group(g) if mm else "?"


def part(a, b=None, text=None):
    t = cap if text is None else text
    if a not in t:
        ok(False, "the capture holds: " + a[:80])
        return ""
    t = t.split(a, 1)[1]
    return t.split(b, 1)[0] if b and b in t else t



def cnt(rx, text=None):
    return len(re.findall(rx, cap if text is None else text, re.M))


def window(text, label):
    """the statement list of one labelled window, and its printed count"""
    n = grab(r"window " + re.escape(label) + r" \([^)]*\)\)?: statements (\d+)$", "window %s: its count line" % label, text)
    sql = re.findall(r"window " + re.escape(label) + r" \([^\n]*?\) SQL: (.*)$", text, re.M)
    return int(n) if n != "?" else -1, sql


if MODE == "anchor":
    ok("\n  changed: README.md\n  changed: tiffinbox-core/pom.xml\n  changed: tiffinbox-web/pom.xml\n  changed: tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxApp.java\n  new: tiffinbox-core/src/main/java/com/tiffinbox/jdbc\n" in cap and "  deleted:" not in cap,
       "C1: three files changed besides the README, one new package; nothing deleted")
    ok("the YAML, Flyway's migrations, the three JPA files and the tests, after/ against before/: the same, byte for byte" in cap, "C1 leaves the YAML, V1-V3, the entities, the JPA repository and the tests byte for byte")
    nb = int(grab(r"\.harness/before's jar, extracted - lib/ \(ls lib \| wc -l\): (\d+) libraries", "before/'s libraries"))
    na = int(grab(r"\.harness/after's jar, extracted - lib/ \(ls lib \| wc -l\): (\d+) libraries", "after/'s libraries"))
    add = grab(r"the libraries after/'s jar adds: (.*) · removes: none$", "the libraries added, none removed").split()
    ok(na - nb == len(add) and sorted(add) == ["spring-boot-data-jdbc-4.1.2.jar", "spring-data-jdbc-4.1.2.jar", "spring-data-relational-4.1.2.jar"],
       "the jar gains exactly spring-boot-data-jdbc, spring-data-jdbc and spring-data-relational, 4.1.2 (%d -> %d)" % (nb, na))
    ok(cnt(r"postgresql-\*\.jar: postgresql-42\.7\.14\.jar") == 2, "both jars hold PostgreSQL's driver (Course 7's capstone put it there): TiffinBox and the harness use it, nothing added")
    xm = grab(r"the script's md5: ([0-9a-f]{32}) · the filed xcheck.sql \(= Course 7's capstone's\): ([0-9a-f]{32}) · cmp: the same, byte for byte", "xcheck: Hibernate's script = the filed one, byte for byte")
    ok(cnt(r"its org\.flywaydb lines: 0 · the script's md5") == 1, "xcheck: no Flyway in its JVM")
    h2 = part("A - TiffinBox after/'s jar, the default:", "A - the same jar on PostgreSQL")
    pg = part("A - the same jar on PostgreSQL", "the harness on after/ - H2")
    for nm, t in (("H2 in memory", h2), ("PostgreSQL", pg)):
        ok(cnt(r"^  log: Multiple Spring Data modules found, entering strict repository configuration mode$", t) == 2, "TiffinBox on %s: strict mode, once per module" % nm)
        ok(cnt(r"^  log: Finished Spring Data repository scanning in <t> ms\. Found 1 JPA repository interface\.$", t) == 1 and cnt(r"Found 1 JDBC repository interface\.$", t) == 1, "TiffinBox on %s: Found 1 JPA and Found 1 JDBC repository interface" % nm)
        ok(cnt(r"Could not safely identify store assignment", t) == 1 and "Spring Data JPA - Could not safely identify store assignment for repository candidate interface com.tiffinbox.jdbc.CustomerAggregates" in t,
           "TiffinBox on %s: one 'Could not safely identify store assignment' line - Spring Data JPA's, for CustomerAggregates" % nm)
        ok(re.search(r"-> 200 · the request's org\.hibernate\.SQL lines, between its two markers: 4 · JdbcTemplate's SQL lines: 0 · ERROR lines: 0", t) is not None, "TiffinBox on %s: GET /dashboard 200, its SQL lines 4 (Hibernate's), Spring Data JDBC's 0" % nm)
        ok("HHH000001: Hibernate ORM core version 7.4.13.Final" in t, "TiffinBox on %s: HHH000001 7.4.13.Final" % nm)
    ok("'Database JDBC URL [jdbc:h2:mem:tiffinbox' 1" in h2 and "log: Database: jdbc:h2:mem:tiffinbox (H2 2.5)" in h2, "A on H2: Hibernate's and Flyway's URL lines say H2 in memory")
    ok("log: Database: jdbc:postgresql://127.0.0.1:20411/u02a?user=sa&password=******** (PostgreSQL 18.6)" in pg and "psql - the tables and the history: customer, flyway_schema_history, pause · 3 rows, success true" in pg,
       "A on PostgreSQL: Flyway's line says PostgreSQL 18.6; psql reads the migrated tables and three history rows")
    hh = part("the harness on after/ - H2 in memory", "the harness on after/ - PostgreSQL")
    hp = part("the harness on after/ - PostgreSQL", "tests - after/ copied")
    sqlv = {}
    for nm, t, db in (("H2", hh, "H2 2.5.250"), ("PostgreSQL", hp, "PostgreSQL 18.6")):
        ok("started: yes · the database that answered: %s" % db in t, "the harness on %s: the connection says %s" % (nm, db))
        ok("repository bean &customerEntityRepository · factory JpaRepositoryFactoryBean · interface com.tiffinbox.CustomerEntityRepository" in t and
           "repository bean &customerAggregates · factory JdbcRepositoryFactoryBean · interface com.tiffinbox.jdbc.CustomerAggregates" in t and cnt(r"^  repository bean ", t) == 2,
           "the harness on %s: two repository beans - JpaRepositoryFactoryBean's and JdbcRepositoryFactoryBean's" % nm)
        ok(cnt(r"^  transaction manager ", t) == 1 and "transaction manager transactionManager · org.springframework.orm.jpa.JpaTransactionManager" in t, "the harness on %s: one transaction manager, JpaTransactionManager" % nm)
        ok(cnt(r"^  data \(%s, JdbcTemplate\): customers 40 · pauses 38 · paused days 77$" % re.escape(db), t) == 2, "the harness on %s: the data line 40 · 38 · 77" % nm)
        mm = re.search(r"window findAll\(\) \(%s\): aggregates (\d+) · pauses in them (\d+) · statements (\d+)" % re.escape(db), t)
        ok(mm is not None, "the harness on %s: findAll()'s window" % nm)
        c1 = re.findall(r"window findAll\(\) \(%s\) SQL x(\d+): (.*)$" % re.escape(db), t, re.M)
        ok(mm is not None and len(c1) == 2 and int(c1[0][0]) + int(c1[1][0]) == int(mm.group(3)) == int(mm.group(1)) + 1, "the harness on %s: findAll() = one customer SELECT + one pause SELECT per aggregate (1 + N)" % nm)
        ok(all('"' not in q for _, q in c1), "the harness on %s: the SQL unquoted (JdbcNames)" % nm)
        sqlv[nm] = (mm.group(3) if mm else "?", [q for _, q in c1])
        ok("versions: Spring Boot 4.1.2 · Spring Framework 7.0.10 · Spring Data JDBC 4.1.2 · Spring Data Relational 4.1.2 · Spring Data JPA 4.1.2 · Flyway (version.txt) 12.4.0 · datasource-proxy (pom.properties) 1.11.1" in t
           and "HHH000001: Hibernate ORM core version 7.4.13.Final" in t, "the harness on %s: the version lines (R.246)" % nm)
    ok(sqlv["H2"][1][0].startswith("SELECT customer.ID AS ID") and sqlv["PostgreSQL"][1][0].startswith("SELECT customer.id AS id"), "the unquoted SQL per database: customer.ID AS ID on H2, customer.id AS id on PostgreSQL (R.365)")
    ok("psql - the data line, a second client: 40 customers · 38 pauses · 77 paused days" in hp, "PostgreSQL's data line read back by psql")
    tp = part("tests - after/ copied", "\n$ export DOCKER_HOST")
    tv = part("$ export TESTCONTAINERS_RYUK_DISABLED=true")
    ok("in all: 3 reports · tests 18 · failures 0 · errors 0 · skipped 0" in tp and "surefire-reports-it: absent - no container test ran" in tp and "offline: yes" in tp, "mvn package, Docker pointed at nothing: 18/18 from Surefire's reports (14 · 3 · 1), no container test")
    ok(cnt(r"in all: 3 reports · tests 18 · failures 0 · errors 0 · skipped 0", tv) == 1 and cnt(r"in all: 1 reports · tests 3 · failures 0 · errors 0 · skipped 0", tv) == 1 and "BUILD SUCCESS · offline: yes" in tv,
       "mvn verify: 18 + 3 from Surefire's two report folders")
    ok("1 container create of the digest, 0 others, 0 image pulls" in tv, "verify: one container, the digest, no pull (R.318)")
    done("the jar's libraries %d -> %d (+ %s); Hibernate's script f4f15b9c… = Course 7's capstone's; TiffinBox on H2 in memory and on PostgreSQL 18.6 (the config tree's URL, its own driver): strict mode, Found 1 JPA repository interface, Found 1 JDBC repository interface, one 'Could not safely identify' line (Spring Data JPA's, for CustomerAggregates), GET /dashboard 200 with 4 SQL lines; the harness: customerEntityRepository by JpaRepositoryFactoryBean, customerAggregates by JdbcRepositoryFactoryBean, one JpaTransactionManager; data 40 · 38 · 77; findAll() %s statements on H2 and %s on PostgreSQL (1 + 40); tests 18 (14 · 3 · 1, mvn package, no Docker) + 3 (mvn verify)" % (nb, na, ", ".join(sorted(add)), sqlv["H2"][0], sqlv["PostgreSQL"][0]))

if MODE == "quote":
    q0 = part("quote0 - a second COPY", "quote - H2 in memory")
    ok("read findAll() (H2 2.5.250): aggregates 4" in q0 and "SQL x1: SELECT customer.ID AS ID" in q0 and "  <<< exit 0" in q0 and "  < @Import(JdbcNames.class)" in q0,
       "quote0: only the @Import removed - H2 still reads 4 aggregates unquoted (the component scan finds JdbcNames)")
    qh = part("quote - H2 in memory", "quote - PostgreSQL")
    qp = part("quote - PostgreSQL", "Q - after/ (JdbcNames imported) on H2")
    ah = part("Q - after/ (JdbcNames imported) on H2", "Q - after/ on PostgreSQL")
    ap = part("Q - after/ on PostgreSQL")
    ok("  deleted: tiffinbox-core/src/main/java/com/tiffinbox/jdbc/JdbcNames.java\n  < import com.tiffinbox.jdbc.JdbcNames;\n  < import org.springframework.context.annotation.Import;\n  < @Import(JdbcNames.class)\n" in cap, "the quote copy: JdbcNames deleted, its import and @Import gone - nothing else")
    err = grab(r"read findAll\(\) \(H2 2\.5\.250\): org\.springframework\.jdbc\.BadSqlGrammarException <- org\.h2\.jdbc\.JdbcSQLSyntaxErrorException: (.*)$", "the copy on H2: BadSqlGrammarException", qh)
    ok(err == 'Table "customer" not found (candidates are: "CUSTOMER")', "the copy on H2: Table \"customer\" not found (candidates are: \"CUSTOMER\")")
    ok("  <<< exit 1" in qh and re.search(r'SQL x1: SELECT "customer"\."ID" AS "ID"', qh) is not None, "the copy on H2: exit 1; the quoted SQL it sent")
    ok("read findAll() (PostgreSQL 18.6): aggregates 4" in qp and "  <<< exit 0" in qp, "the copy on PostgreSQL: reads 4 aggregates, exit 0")
    qs = grab(r'read findAll\(\) \(PostgreSQL 18\.6\) SQL x1: (SELECT "customer"\."id" AS "id".*)$', "the copy on PostgreSQL: the quoted form", qp)
    for nm, t, db, head in (("H2", ah, "H2 2.5.250", "SELECT customer.ID AS ID"), ("PostgreSQL", ap, "PostgreSQL 18.6", "SELECT customer.id AS id")):
        ok("read findAll() (%s): aggregates 4" % db in t and "  <<< exit 0" in t and ("SQL x1: " + head) in t and '"' not in t.split("SQL x1: ")[1].split("\n")[0],
           "after/ (JdbcNames) on %s: 4 aggregates, exit 0, unquoted" % nm)
    done("the @Import alone removed: H2 still reads, unquoted (the component scan finds JdbcNames); the copy without JdbcNames: H2 refuses, exit 1, %s; PostgreSQL reads 4 aggregates with the quoted form (failure receipt only); after/ with JdbcNames: 4 aggregates on both, unquoted" % err)

if MODE == "dup":
    ok("  deleted: tiffinbox-core/src/main/java/com/tiffinbox/jdbc/CustomerAggregates.java\n  new: tiffinbox-core/src/main/java/com/tiffinbox/jdbc/CustomerEntityRepository.java\n" in cap, "the dup copy: the JDBC repository renamed CustomerEntityRepository, nothing else")
    a = part("  after/:", "  the dup copy:"); d = part("  the dup copy:", "dup - TiffinBox's jar")
    ok("· repeated: 0" in a and "  exit 0" in a, "R.354 on after/: no simple name repeated, exit 0")
    ok("· repeated: 1 (customerEntityRepository)" in d and "  exit 1" in d, "R.354 on the copy: customerEntityRepository twice, exit 1")
    ok("exit 1 · it listened on: nothing · 'APPLICATION FAILED TO START' 1" in cap, "the copy's TiffinBox: exit 1, nothing listened")
    ok("Found 1 JPA repository interface." in cap and "Found 1 JDBC" not in cap and "Found 0 JDBC" not in cap, "the copy: Spring Data JPA's Found line, none from Spring Data JDBC (it stops while registering)")
    ex = grab(r"the exception \(cut at its first ':' after the bean name\): (BeanDefinitionOverrideException: Invalid bean definition with name 'customerEntityRepository' .*)$", "BeanDefinitionOverrideException for 'customerEntityRepository'")
    ok("A bean with that name has already been defined in com.tiffinbox.CustomerEntityRepository defined in @EnableJpaRepositories declared on TiffinBoxApp and overriding is disabled." in cap, "Boot's failure analysis names both modules' interfaces")
    done("the copy: BeanDefinitionOverrideException: Invalid bean definition with name 'customerEntityRepository', exit 1, nothing listened; the simple-name check: after/ 0 repeated, the copy 1")

if MODE == "dirty":
    pgp = part("dirty - PostgreSQL", "dirty - H2 in memory")
    h2p = part("dirty - H2 in memory", "RE-MEASURE 3")
    au = part("RE-MEASURE 3")
    rows = re.findall(r"^  psql, (before any window|after B|after A|after A'): Ravi meals (\d+) version (\d+) updated_at (null|set)$", pgp, re.M)
    ok([r[0] for r in rows] == ["before any window", "after B", "after A", "after A'"], "PostgreSQL: psql read Ravi's row before the windows and after each")
    seqm = [int(r[1]) for r in rows]; seqv = [int(r[2]) for r in rows]; sequ = [r[3] for r in rows]
    ok(seqm[0] == seqm[1] and seqm[2] == seqm[1] + 1 and seqm[3] == seqm[2] + 1, "PostgreSQL by psql: B leaves meals, A writes +1, A' writes +1 (%s)" % " -> ".join(map(str, seqm)))
    ok(seqv == [0, 0, 1, 2], "PostgreSQL by psql: version 0 (B leaves it) -> 1 (A, Spring Data JPA) -> 2 (A', Spring Data JDBC): one column, both modules")
    ok(sequ == ["null", "null", "set", "set"] and "updated_at after A' against after A: the same value" in pgp, "PostgreSQL by psql: updated_at set by A (JPA's auditing), left as it was by A' (Spring Data JDBC)")
    wins = {}
    for nm, t in (("PostgreSQL", pgp), ("H2", h2p)):
        nb, sb = window(t, "B (Spring Data JDBC: findById, meals + 1, no save, commit)")
        na, sa = window(t, "A (Spring Data JPA: findByName, meals + 1, no save, commit)")
        n2, s2 = window(t, "A' (Spring Data JDBC: findById, meals + 1, save, commit)")
        ok(nb == len(sb) == 2 and all(q.upper().startswith("SELECT") for q in sb) and "FROM customer WHERE customer." in sb[0] and "FROM pause WHERE pause.customer_id = ?" in sb[1],
           "%s window B: 2 statements, the customer SELECT and her pauses' SELECT, no UPDATE" % nm)
        ok(na == len(sa) == 2 and sa[0].startswith("select ce1_0.") and sa[1] == "update customer set meal_type=?,meals_per_day=?,name=?,price_per_meal=?,updated_at=?,version=? where id=? and version=?",
           "%s window A: 2 statements, the SELECT and the UPDATE nobody called save() for" % nm)
        ok(re.search(r"window A: Hibernate getPrepareStatementCount\(\) 2 · the witness 2 · equal: yes · entityUpdateCount 1 · flushCount 1", t) is not None, "%s window A: Hibernate's getPrepareStatementCount() = the witness (R.357)" % nm)
        ok(n2 == len(s2) == 4 and s2[0].upper().startswith("SELECT") and s2[1].upper().startswith("SELECT") and s2[2].upper().startswith("UPDATE CUSTOMER SET") and s2[2].upper().endswith("WHERE CUSTOMER.ID = ? AND CUSTOMER.VERSION = ?") and s2[3].upper() == "DELETE FROM PAUSE WHERE PAUSE.CUSTOMER_ID = ?",
           "%s window A': 4 statements - 2 SELECTs, the UPDATE, the DELETE of her pauses (she has none to re-insert)" % nm)
        ok("updated_at" not in s2[2].lower(), "%s window A': its UPDATE names no updated_at" % nm)
        ok("B the Java object after the change: meals 3 (the object, not the row)" in t, "%s: B's object says 3 - the row is read by a second client, never the object (R.359)" % nm)
        wins[nm] = (nb, na, n2)
    hr = re.findall(r"read back by JdbcTemplate \(a second client, H2 2\.5\.250\): Ravi meals (\d+) version (\d+) updated_at ([a-z ,-]+?)$", h2p, re.M)
    ok([(int(a), int(b)) for a, b, _ in hr] == [(2, 0), (2, 0), (3, 1), (4, 2)] and hr[2][2].startswith("set, a new value") and hr[3][2].startswith("set, the same value"),
       "H2 by JdbcTemplate: meals 2 -> 2 -> 3 -> 4, version 0 -> 0 -> 1 -> 2, updated_at set by A and left by A'")
    for nm, db in (("H2", "H2 2.5.250"), ("PostgreSQL", "PostgreSQL 18.6")):
        t = part("audit copy - " + ("H2 in memory" if nm == "H2" else "PostgreSQL"), "audit copy - PostgreSQL" if nm == "H2" else None, au)
        r = re.findall(r"read back by JdbcTemplate \(a second client, %s\): Ravi meals (\d+) version (\d+) updated_at (.*)$" % re.escape(db), t, re.M)
        ok(len(r) == 2 and r[0][2] == "null" and r[1][2].startswith("set, a new value") and re.search(r"SQL: UPDATE customer SET .*(UPDATED_AT|updated_at) = \?", t) is not None,
           "RE-MEASURE 3 on %s: with @EnableJdbcAuditing and @LastModifiedDate (a copy) the JDBC UPDATE writes updated_at (null -> set)" % nm)
    ok("@EnableJdbcAuditing" in au and "@LastModifiedDate" in au, "the audit copy's two lines shown")
    done("window B (Spring Data JDBC, no save) %d statements, 0 UPDATE; window A (Spring Data JPA, no save) %d statements, the UPDATE included, = getPrepareStatementCount(); window A' (Spring Data JDBC, save) %d statements - 2 SELECTs, UPDATE, DELETE of pauses; psql on PostgreSQL and JdbcTemplate on H2: meals %s, version 0 -> 0 -> 1 -> 2, updated_at null -> set by A, left by A'; Spring Data JDBC's own auditing (a copy): writes updated_at on both databases" % (wins["PostgreSQL"][0], wins["PostgreSQL"][1], wins["PostgreSQL"][2], " -> ".join(map(str, seqm))))

if MODE == "lazy":
    vals = []
    for db in ("H2 2.5.250", "PostgreSQL 18.6"):
        j = grab(r"lazy \(%s\), after the call, no transaction: Spring Data JDBC getPauses\(\) -> (\d+) · java\.util\.LinkedHashSet$" % re.escape(db), "%s: the aggregate's pauses, a LinkedHashSet, after the call" % db)
        e = grab(r"lazy \(%s\): Spring Data JPA getPauses\(\)\.size\(\) -> org\.hibernate\.LazyInitializationException: (Cannot lazily initialize collection of role 'com\.tiffinbox\.CustomerEntity\.pauses' with key '(\d+)' \(no session\))$" % re.escape(db), "%s: the entity's pauses -> LazyInitializationException" % db)
        vals.append((j, e))
    ok(vals[0] == vals[1], "the same outcomes on both databases")
    ok("application.yaml's open-in-view, after/: open-in-view: false" in cap, "open-in-view: false (Course 7's)")
    done("after the call, no transaction, on H2 and PostgreSQL: Spring Data JDBC getPauses() -> %s (LinkedHashSet); Spring Data JPA -> LazyInitializationException: %s" % vals[0])

if MODE == "seven":
    want = sys.argv[3]
    ms = re.findall(r"exit 0 · the seven responses: 7 lines · md5 ([0-9a-f]{32})$", cap, re.M)
    ok(len(ms) == 3 and all(x == want for x in ms), "the seven: before/ on H2, after/ on H2, after/ on PostgreSQL - each the comparison set's md5 (read off ../c7-unit31/receipts.sh)")
    ok("the seven, after/ against before/ (H2): lines that differ: 0 · after/ on PostgreSQL against after/ on H2: 0" in cap, "the seven: no line differs")
    sq = re.findall(r"its log during the seven: org\.hibernate\.SQL lines (\d+) · JdbcTemplate's SQL lines (\d+)$", cap, re.M)
    ok(len(sq) == 3 and len(set(sq)) == 1 and sq[0][1] == "0", "the seven: the same SQL line count each time, none from Spring Data JDBC")
    done("the seven %s… on before/ and after/ (H2) and after/ on PostgreSQL, unchanged; %s Hibernate SQL lines during it each time, 0 from Spring Data JDBC" % (want[:8], sq[0][0] if sq else "?"))

if MODE == "exercise":
    w, line = sys.argv[3], sys.argv[4]
    ok(w == "19", "the spoken exercise line is 19 words (wc -w), as the brief has it")
    b = part("in bash (", "\nin zsh ("); z = part("in zsh (")
    norm = lambda t: t.replace("in bash (/bin/bash --noprofile --norc)", "").replace("in zsh (/bin/zsh -f)", "")
    ok(b.split(" - the README's lines:", 1)[1] == z.split(" - the README's lines:", 1)[1].rstrip("\n") or b.split(" - the README's lines:", 1)[1].rstrip("\n") == z.split(" - the README's lines:", 1)[1].rstrip("\n"), "bash and zsh printed the same")
    br = b.split("then the solution's lines")[0]; so = b.split("then the solution's lines")[1]
    ok("    Maven: exit 0\n    TiffinBox: exit 1\n    Found 1 JPA repository interface\n    BeanDefinitionOverrideException: Invalid bean definition with name 'customerEntityRepository'\n" in br, "broken: Maven 0, TiffinBox exit 1, JPA's Found line only, the override error")
    ok("    Maven: exit 0\n    TiffinBox: exit 0\n    Found 1 JPA repository interface\n    Found 1 JDBC repository interface\n    no override error\n" in so, "solved: TiffinBox exit 0, Found 1 JPA + Found 1 JDBC, no override error")
    ok(cnt(r"DOCKER_HOST in its environment: 0 · listening on 20417-20419: 0") == 2, "no Docker in the exercise's environment, no port bound")
    done("the exercise (19 words, H2 in memory, no Docker): broken - TiffinBox exit 1, BeanDefinitionOverrideException 'customerEntityRepository'; solved by the rename - exit 0, Found 1 JPA repository interface + Found 1 JDBC repository interface")
print("FAIL no mode " + MODE); sys.exit(2)
