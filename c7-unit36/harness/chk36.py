"""Unit 36's checks (python3 -I -B harness/chk36.py MODE ...). Each capture's mode reads its capture (.r-NAME.out) and asserts every
number and string the video may say against another witness of the same run - the history table read by a second connection beside
Flyway's own lines (R.313), the database named on every failure (R.314), the harness's driver said (R.335) - never against a typed
figure; it prints "ok ..." lines and one "VALUES ..." line, and exits 1 on the first failed assertion. Three helper modes: r250 (the
gate before any build: every sentence of after/ that names Database says it was retired; R.330's ddl-auto), r80 (V1 against
Hibernate's script, the named differences) and wib (an exercise file's "What it prints" block as the bash run printed it)."""
import os, re, sys

MODE = sys.argv[1]
OK = []


def ok(cond, what):
    if not cond:
        print("FAIL " + what); sys.exit(1)
    OK.append(what); print("ok    " + what)


def lines(p):
    return open(p, encoding="utf-8").read().splitlines()


def one(L, rx, what, start=0, end=None):
    hits = [i for i in range(start, len(L) if end is None else end) if re.search(rx, L[i])]
    ok(len(hits) >= 1, what + " (" + rx[:70] + ")")
    return hits[0]


def section(L, head, nxt=None):
    a = one(L, "^" + re.escape(head), "the step: " + head)
    b = len(L)
    if nxt:
        hs = [i for i in range(a + 1, len(L)) if L[i].startswith(nxt)]
        b = hs[0] if hs else len(L)
    return L[a:b]


def has(S, line, what):
    ok(line in S, what + ": " + line.strip()[:110])


def cnt(S, line):
    return sum(1 for s in S if s == line)


# ---- r250 -------------------------------------------------------------------------------------------------------------------
if MODE == "r250":
    A = sys.argv[2]
    ALLOWED = re.compile(r"retired|Unsupported Database|theSliceLeavesTheDatabaseOut")
    bad = []; n = 0
    for d, ds, fs in os.walk(A):
        ds.sort()
        for f in sorted(fs):
            p = os.path.join(d, f); rel = os.path.relpath(p, A)
            if rel == "README.md":
                continue
            t = open(p, encoding="utf-8", errors="replace").read()
            # a sentence: comment markers and line breaks dropped, split on . ; or a blank line
            flat = re.sub(r"\n\s*(?:\*|//|#|--)?\s*", " ", t)
            for s in re.split(r"(?<=[.;])\s+|\n\s*\n", flat):
                if re.search(r"\bDatabase\b", s):
                    n += 1
                    if not ALLOWED.search(s): bad.append(rel + ": " + s.strip()[:120])
    for b in bad: print("R.250: a sentence that names Database and does not say it was retired: " + b)
    ok(not bad, "R.250: after/'s sources, YAML, POM, migrations and tests - %d sentences name Database, each says it was retired (or is Flyway's own `Unsupported Database`, or the test's name)" % n)
    R = open(A + "/README.md", encoding="utf-8").read()
    head = R.split("\n## ", 1)[0]
    ok("*(Course 7, unit 36, **Section 6's first change to this folder**" in head, "R.250: the anchor README's header carries unit 36's note")
    ok(re.search(r"\(Course 7, unit 36: retired", head) is not None, "R.250: the header's first sentence about Database carries the retirement note")
    sec = R.split("\n## Course 7 · unit 36 — ", 1)
    ok(len(sec) == 2 and "Database.java" in sec[1].split("\n## ", 1)[0] and "deleted" in sec[1].split("\n## ", 1)[0], "R.250: the README's unit 36 section names Database.java deleted")
    Y = open(A + "/tiffinbox-web/src/main/resources/application.yaml", encoding="utf-8").read()
    dd = re.findall(r"^\s*ddl-auto:\s*(\S+)", Y, re.M)
    ok(dd == ["validate"], "R.330: the anchor's YAML - ddl-auto: %s (validate only; create, update or none refused)" % ",".join(dd))
    ok("# validate: Hibernate checks the migrated schema and writes nothing" in Y, "R.330: the YAML's comment, by its text")
    sys.exit(0)

# ---- r80 ----------------------------------------------------------------------------------------------------------------------
if MODE == "r80":
    v1 = open(sys.argv[2], encoding="utf-8").read(); hs = open(sys.argv[3], encoding="utf-8").read()
    def cols(sql, table):
        m = re.search(r"create table " + table + r" \((.*?)\)\s*;", sql, re.I | re.S)
        out = []
        for c in re.split(r",\s*(?![^()]*\))", m.group(1)):
            w = c.strip().split()
            if w and w[0].lower() not in ("primary",): out.append(w[0].lower())
        return out
    def col(sql, table, name):
        m = re.search(r"create table " + table + r" \((.*?)\)\s*;", sql, re.I | re.S)
        for c in re.split(r",\s*(?![^()]*\))", m.group(1)):
            if c.strip().lower().startswith(name + " "): return re.sub(r"\s+", " ", c.strip())
        return "(none)"
    print("meal_type: V1 `%s` · Hibernate's script `%s`" % (col(v1, "customer", "meal_type"), col(hs, "customer", "meal_type")))
    print("version: V1 `%s` · Hibernate's script `%s`" % (col(v1, "customer", "version"), col(hs, "customer", "version")))
    fk = re.search(r"add constraint (\S+) foreign key", hs)
    print("the foreign key: V1 `%s` (no name: the database names it) · Hibernate's script names it `%s`" % (col(v1, "pause", "customer_id"), re.sub(r"FK[0-9a-z]{20,}", "FK<name>", fk.group(1)) if fk else "(none)"))
    print("the index: V1 `%s` · Hibernate's script `%s`" % (re.search(r"CREATE INDEX .*;", v1).group(0), re.search(r"create index .*;", hs).group(0)))
    print("the identity columns: V1 `%s` · Hibernate's script `%s`" % (col(v1, "customer", "id"), col(hs, "customer", "id")))
    print("customer's column order: V1 %s · Hibernate's script %s" % (", ".join(cols(v1, "customer")), ", ".join(cols(hs, "customer"))))
    print("pause's column order: V1 %s · Hibernate's script %s" % (", ".join(cols(v1, "pause")), ", ".join(cols(hs, "pause"))))
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

L = lines(sys.argv[2]); S = set(L)
FLYV = "  PROBE version: Flyway 12.4.0"
VER = ["  PROBE version: Hibernate 7.4.13.Final", "  PROBE version: Spring Data JPA 4.1.2", "  PROBE version: Spring Framework 7.0.10", "  PROBE version: Spring Boot 4.1.2", FLYV]


def jvms(L):
    """each harness JVM's block: from its '$ cd .harness/run' line to its 'exit N · its WARN lines' line"""
    out = []; a = None
    for i, l in enumerate(L):
        if l.startswith("$ cd .harness/run && perl -e 'alarm 240; exec @ARGV' java") and "org.h2.tools.Shell" not in l: a = i
        elif a is not None and re.match(r"^  exit \d+ · its WARN lines: \d+ · its org\.flywaydb lines: \d+$", l): out.append(L[a:i + 1]); a = None
    return out


def versions(L, flyway=True):
    for b in jvms(L):
        fl = any("org.flywaydb" in x for x in b)
        if fl or flyway:
            ok(all(v in b for v in VER), "R.246/R.329: every version line in the JVM block at '%s' (Flyway 12.4.0 among them)" % b[1][:50])


def hist_rows(L, i):
    """the psql rows printed under a history read that starts at line i"""
    rows = []
    for l in L[i + 2:]:
        if not l.startswith("    "): break
        rows.append(l.strip())
    return rows


if MODE == "guard":
    for b, sha in (("s703", "b2e0641"), ("s706", "f4c3653"), ("s707", "d84bf1b"), ("s709", "9853dae")):
        has(L, "  %s.py: the guard - present: " % b + next(l for l in L if l.startswith("  %s.py: the guard - present: " % b))[len("  %s.py: the guard - present: " % b):], b + ": the guard is in the shipped file")
        ok(any(l.startswith("    %s - the shipped comparison step, on the live anchor: exit 0 · its note: lines " % b) for l in L), b + ": the comparison step as shipped - exit 0 on the live anchor")
        has(L, "      note: c7-tiffinbox's tiffinbox-core/src/main/java/com/tiffinbox/Database.java is gone from the live anchor (unit 36 retired it); after/ is checked against %s" % sha, b + ": its note for the retired file")
        ok(any(l.startswith("    %s - the plant - the guard taken out, on the live anchor: FileNotFoundError: No such file or directory: c7-tiffinbox/tiffinbox-core/src/main/java/com/tiffinbox/Database.java" % b) for l in L), b + ": the plant (R.331) - FileNotFoundError")
    has(L, "  exit of guard.py: 0", "guard.py exit 0")
    print("VALUES the four shipped builders (s703, s706, s707, s709) compare after/ with the live anchor behind an existence check: on the moved anchor each runs to exit 0 with the note \"c7-tiffinbox's …/Database.java is gone from the live anchor (unit 36 retired it)\"; with the guard taken out, FileNotFoundError, four of four")
    sys.exit(0)

if MODE == "jars":
    NL = sys.argv[3]; versions(L)
    i1 = one(L, r"^\(i\) ", "(i)"); i2 = one(L, r"^\(ii\) ", "(ii)"); i3 = one(L, r"^\(iii\) ", "(iii)"); i4 = one(L, r"^\(iv\) ", "(iv)")
    A, B, C, D = L[i1:i2], L[i2:i3], L[i3:i4], L[i4:]
    ok(L[0].startswith("jars - Boot 4.1 runs Flyway through its own module; the harness over after/'s libraries, %s of them (ls | wc -l)" % NL), "the libraries counted by ls, %s" % NL)
    has(A, "  exit 0 · its WARN lines: 2 · its org.flywaydb lines: 0", "(i) exit 0, no Flyway line")
    has(A, FLYV, "(i) Flyway's version still printed from the class path")
    has(A, "    (none)", "(i) the second connection: no table in public")
    has(A, '  the history check (R.313): 1 refusal - no flyway_schema_history: "Flyway ran" is refused for this run', "(i) the history check refuses it (R.313)")
    has(B, "  PROBE cause: org.flywaydb.core.api.FlywayException: Unsupported Database: PostgreSQL 18.6", "(ii) the refusal")
    has(B, "  the refusal's step - exit 1 · its lines (grep -o, this step's log): FlywayException: Unsupported Database: PostgreSQL 18.6 ← Error creating bean with name 'flywayInitializer' ← Failed to initialize dependency 'flywayInitializer' of LoadTimeWeaverAware bean 'entityManagerFactory'", "(ii) the filed step (R.303)")
    has(B, "    (none)", "(ii) no table")
    eight = [l for l in C if " org.flywaydb." in l]
    ok(len(eight) == 8, "(iii) eight Flyway lines: %d" % len(eight))
    ok(eight[0].startswith("  INFO  [main] org.flywaydb.core.FlywayExecutor : Database: jdbc:postgresql://127.0.0.1:20158/u36j3?user=sa&password=******** (PostgreSQL 18.6)"), "(iii) Flyway masks the password itself")
    for t in ['Schema history table "public"."flyway_schema_history" does not exist yet', "Successfully validated 2 migrations (execution time <t>)", 'Creating Schema History table "public"."flyway_schema_history" ...',
              'Current version of schema "public": << Empty Schema >>', 'Migrating schema "public" to version "1 - customer and pause"', 'Migrating schema "public" to version "2 - seed"',
              'Successfully applied 2 migrations to schema "public", now at version v2 (execution time <t>)']:
        ok(any(l.endswith(" : " + t) for l in eight), "(iii) " + t)
    o = [l for l in C if l.startswith("  the order (line numbers in its log): ")][0]
    a, z, h = [int(x) for x in re.match(r"^  the order \(line numbers in its log\): the first org\.flywaydb line (\d+) · the last (\d+) · HHH000001 (\d+)$", o).groups()]
    ok(a < z < h, "(iii) R.197: every Flyway line before HHH000001 (lines %d-%d, then %d)" % (a, z, h))
    has(C, "  PROBE emf hibernate.hbm2ddl.auto = validate", "(iii) ddl-auto validate read off the EMF")
    has(C, "  exit 0 · its WARN lines: 0 · its org.flywaydb lines: 8", "(iii) exit 0, no WARN on PostgreSQL")
    hi = one(C, r"^  the second connection - the history table:$", "(iii) history read")
    rows = hist_rows(C, hi)
    ok(len(rows) == 2 and all(r.endswith("|sa|t") for r in rows) and rows[0].startswith("1|1|customer and pause|SQL|V1__customer_and_pause.sql|") and rows[1].startswith("2|2|seed|SQL|V2__seed.sql|"), "(iii) R.313: the history table by psql - %d rows, success t" % len(rows))
    has(C, "    customer, flyway_schema_history, pause", "(iii) the tables")
    has(C, "    pause_customer_id_fkey", "(iii) PostgreSQL's name for V1's foreign key")
    w = [l for l in D if "newer than the version Flyway has been verified with" in l]
    ok(len(w) == 1 and w[0] == "  WARN  [main] org.flywaydb.core.internal.database.base.Database : Using H2 2.5.250 which is newer than the version Flyway has been verified with. The latest verified version of H2 is 2.3.232.", "(iv) H2: one WARN per start")
    has(D, "  PROBE emf hibernate.hbm2ddl.auto = validate", "(iv) validate on H2"); has(D, "  exit 0 · its WARN lines: 1 · its org.flywaydb lines: 9", "(iv) exit 0, the one WARN")
    print("VALUES the libraries %s, Flyway's three: flyway-core-12.4.0, flyway-database-postgresql-12.4.0, spring-boot-flyway-4.1.2; (i) without spring-boot-flyway: 0 Flyway lines, exit 0, tables (none), no history table - \"Flyway ran\" refused, Flyway 12.4.0 still on the class path; (ii) without flyway-database-postgresql: exit 1, FlywayException: Unsupported Database: PostgreSQL 18.6 ← flywayInitializer ← entityManagerFactory; (iii) all three: 8 Flyway lines, every one before HHH000001, the URL's password masked by Flyway (********), Successfully applied 2 migrations … now at version v2, ddl-auto validate passing, the history table by psql 2 rows success t, PostgreSQL names V1's foreign key pause_customer_id_fkey; (iv) on H2: one WARN per start, Using H2 2.5.250 which is newer than the version Flyway has been verified with. The latest verified version of H2 is 2.3.232." % NL)
    sys.exit(0)

if MODE == "anchor":
    ix = {k: one(L, "^" + re.escape(k), k) for k in ("B, JVM 1 of 2", "B, JVM 2 of 2", "A, JVM 1 of 2", "A, JVM 2 of 2", "A2, JVM 1 of 2", "A2, JVM 2 of 2", "the refusal")}
    B1, B2, A1, A2, P1, P2, RF = (L[ix["B, JVM 1 of 2"]:ix["B, JVM 2 of 2"]], L[ix["B, JVM 2 of 2"]:ix["A, JVM 1 of 2"]], L[ix["A, JVM 1 of 2"]:ix["A, JVM 2 of 2"]],
                                  L[ix["A, JVM 2 of 2"]:ix["A2, JVM 1 of 2"]], L[ix["A2, JVM 1 of 2"]:ix["A2, JVM 2 of 2"]], L[ix["A2, JVM 2 of 2"]:ix["the refusal"]], L[ix["the refusal"]:])
    for nm in ("B - ", "A - ", "A2 - "):
        ok(any(l.startswith(nm + "TiffinBox on PostgreSQL + the harness's driver (.m2-demo/org/postgresql/postgresql/42.7.14/postgresql-42.7.14.jar on its class path; its lib/ holds none)") for l in L), "R.335: %s's line says + the harness's driver" % nm.strip(" -"))
    has(L, "  deleted: tiffinbox-core/src/main/java/com/tiffinbox/Database.java", "C1: Database.java deleted"); has(L, "  the YAML's ddl-auto line, after/: ddl-auto: validate", "R.330")
    K = '  -> 201 {"name":"Kavya","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}'
    for nm, X in (("B", B1), ("A", A1), ("A'", P1)):
        has(X, K, nm + ": POST Kavya 201"); has(X, "  the second connection - customers: 5 rows · the history table:", nm + ": psql 5 rows after the POST")
    ok("  -> 404" in B2 and "  the second connection - customers: 4 rows · the history table:" in B2 and "  -> 200 · customers listed: 4 (Meera Priya Ravi Sunil)" in B2, "B (the failure receipt): the restart - GET /customers/Kavya 404, 4 listed, psql 4 rows (C7-1 cause 2: the drop-and-seed)")
    ok(not any(" org.flywaydb." in l or l.startswith("  Flyway: ") for l in B1 + B2) and cnt(B1 + B2, "  its log, read off: org.flywaydb lines 0 · HHH000001 lines 1 · ERROR lines 0") == 2 and "    ERROR:  relation \"flyway_schema_history\" does not exist" in B1, "B: no Flyway, no history table")
    MIG = ['  Flyway: INFO Migrating schema "public" to version "1 - customer and pause"', '  Flyway: INFO Migrating schema "public" to version "2 - seed"', '  Flyway: INFO Successfully applied 2 migrations to schema "public", now at version v2 (execution time <t>)']
    UTD = ['  Flyway: INFO Current version of schema "public": 2', '  Flyway: INFO Schema "public" is up to date. No migration necessary.']
    for nm, X, Y in (("A", A1, A2), ("A'", P1, P2)):
        ok(all(m in X for m in MIG), nm + ": JVM 1 migrates (V1, V2)"); ok(all(u in Y for u in UTD) and not any("Migrating schema" in l for l in Y), nm + ": JVM 2 - up to date, nothing migrated")
        ok("  -> 200" in Y and "  -> 200 · customers listed: 5 (Kavya Meera Priya Ravi Sunil)" in Y and "  the second connection - customers: 5 rows · the history table:" in Y, nm + ": the restart keeps Kavya - 200, 5 listed, psql 5 rows")
        for Z in (X, Y):
            hi = [i for i, l in enumerate(Z) if l.endswith("· the history table:")][0]
            rows = hist_rows(Z, hi)
            ok(len(rows) == 2 and all(r.endswith("|sa|t") for r in rows), nm + ": R.313 - the history table by psql, %d rows, success t" % len(rows))
    sq = [l for l in A2 if l.startswith("  -> 200 · the request's org.hibernate.SQL lines, between its two markers: ")]
    ok(len(sq) == 2 and all(l.endswith(": 4 · WARN lines: 0 · ERROR lines: 0") for l in sq), "A: GET /dashboard (HTML and JSON) - 4 SQL lines each")
    js = [l for l in A2 if l.startswith("  its JSON: ")][0]
    ok(sorted(re.findall(r'"(\w+)":', js)) == ["customers", "monthRevenue", "names", "pausedDays"], "A: the JSON dashboard keeps its four keys")
    has(RF, "  it never listened; exit 1 · its line (grep -o): Schema validation: missing table [customer] · org.flywaydb lines: 0", "the refusal (R.303): validate is loud")
    has(L, "Flyway's version in TiffinBox's JVMs (R.329): Boot prints none; the jar on their class path, the file VersionPrinter.getVersion() reads (unzip -p flyway-core-12.4.0.jar org/flywaydb/core/internal/version.txt): 12.4.0", "R.329 for TiffinBox's JVMs")
    print("VALUES TiffinBox on PostgreSQL + the harness's driver (after/'s lib/ holds none): B (before/): POST Kavya 201, psql 5 rows; the restart - GET /customers/Kavya 404, 4 customers listed, psql 4 rows (the drop-and-seed: C7-1 cause 2); A (after/): JVM 1 Migrating … \"1 - customer and pause\", \"2 - seed\", POST Kavya 201, psql 5 rows, history 2 rows success t; JVM 2 Current version of schema \"public\": 2 · Schema \"public\" is up to date. No migration necessary. - GET /customers/Kavya 200, 5 listed, psql 5 rows, history still 2; GET /dashboard 200 with 4 SQL lines (HTML and JSON), the JSON's four keys; A' = A; with --spring.flyway.enabled=false: exit 1, Schema validation: missing table [customer]")
    sys.exit(0)

if MODE == "fail":
    versions(L)
    ip = one(L, r"^on PostgreSQL - run 1:", "pg 1"); ip2 = one(L, r"^on PostgreSQL - run 2", "pg 2"); ipf = one(L, r"^on PostgreSQL - the file fixed", "pg fixed")
    ih = one(L, r"^on H2 over TCP", "h2 1"); ih2 = one(L, r"^on H2 - run 2", "h2 2"); ihf = one(L, r"^on H2 - the file fixed alone", "h2 fixed")
    ihr = one(L, r"^on H2 - the file fixed \+ repair", "h2 repair"); ihc = one(L, r"^on H2 - the half-applied column dropped", "h2 cleanup")
    P1, P2, PF, H1, H2_, HF, HR, HC = L[ip:ip2], L[ip2:ipf], L[ipf:ih], L[ih:ih2], L[ih2:ihf], L[ihf:ihr], L[ihr:ihc], L[ihc:]
    PGF = '  ERROR [main] org.flywaydb.core.internal.command.DbMigrate : Migration of schema "public" to version "3 - add phone" failed! Changes successfully rolled back.'
    for nm, X in (("PostgreSQL run 1", P1), ("PostgreSQL run 2", P2)):
        has(X, PGF, nm); has(X, "  SQL State  : 42601", nm); has(X, '  Message    : ERROR: syntax error at or near "VARCHAR"', nm); has(X, "  PROBE closed, exit 1", nm + ": exit 1")
        rows = hist_rows(X, [i for i, l in enumerate(X) if l == "  the second connection - the history table:"][0])
        ok(len(rows) == 2 and not any("|3|" in r for r in rows), nm + ": R.314 - PostgreSQL's history table holds no row for V3 (%d rows)" % len(rows))
    has(P1, "    id, name, meals_per_day, price_per_meal, meal_type, version", "PostgreSQL: phone absent - the first statement rolled back too")
    has(PF, '  INFO  [main] org.flywaydb.core.internal.command.DbMigrate : Successfully applied 1 migration to schema "public", now at version v3 (execution time <t>)', "PostgreSQL: the file fixed applies, no repair")
    ok(not any("repair" in l.lower() for l in P1 + P2 + PF if "org.flywaydb" in l), "PostgreSQL: no repair line anywhere")
    has(PF, "    id, name, meals_per_day, price_per_meal, meal_type, version, phone, email", "PostgreSQL: both columns")
    H2F = '  ERROR [main] org.flywaydb.core.internal.command.DbMigrate : Migration of schema "PUBLIC" to version "3 - add phone" failed! Please restore backups and roll back database and code!'
    has(H1, H2F, "H2 run 1"); has(H1, '  Message    : Unknown data type: "EMAIL"; SQL statement:', "H2 run 1")
    T = "    installed_rank | version | description                               | type  | script                     | installed_by | success"
    MR = "    -1             | null    | << Flyway Schema History table created >> | TABLE |                            | SA           | TRUE"
    F3 = "    3              | 3       | add phone                                 | SQL   | V3__add_phone.sql          | SA           | FALSE"
    T3 = "    3              | 3       | add phone                                 | SQL   | V3__add_phone.sql          | SA           | TRUE"
    ok(T in H1 and MR in H1 and F3 in H1 and "    PHONE" in H1, "H2 run 1: R.314 - success=FALSE for V3, the -1 TABLE row, PHONE present (half-applied)")
    for nm, X in (("H2 run 2", H2_), ("H2, the file fixed alone", HF)):
        has(X, "  Detected failed migration to version 3 (add phone).", nm); has(X, "  Please remove any half-completed changes then run repair to fix the schema history.", nm)
        has(X, "  PROBE cause: org.flywaydb.core.api.exception.FlywayValidateException: Validate failed: Migrations have failed validation", nm); has(X, "  PROBE closed, exit 1", nm + ": exit 1")
    has(HR, '  INFO  [main] org.flywaydb.core.internal.command.DbRepair : Successfully repaired schema history table "PUBLIC"."flyway_schema_history" (execution time <t>).', "H2 repair()")
    has(HR, "  INFO  [main] org.flywaydb.core.internal.command.DbRepair : Manual cleanup of the remaining effects of the failed migration may still be required.", "H2 repair()'s warning")
    has(HR, '  Message    : Duplicate column name "PHONE"; SQL statement:', "H2: repair() alone re-runs into the duplicate column"); ok(F3 in HR, "H2: success=FALSE again")
    has(HC, '  INFO  [main] org.flywaydb.core.internal.command.DbMigrate : Successfully applied 1 migration to schema "PUBLIC", now at version v3 (execution time <t>)', "H2: the drop + repair() + migrate() - now at version v3")
    ok(T3 in HC and "    EMAIL" in HC and "  PROBE closed, exit 0" in HC, "H2: success=TRUE, PHONE and EMAIL, exit 0")
    ok(not any(re.search(r"execution time \d", l) for l in L), "R.264: every Flyway execution time masked")
    print("VALUES a V3 whose second statement is misspelt - on PostgreSQL: Migration of schema \"public\" to version \"3 - add phone\" failed! Changes successfully rolled back. · SQL State 42601 · ERROR: syntax error at or near \"VARCHAR\", exit 1; the history table holds rows 1-2 only, phone absent; run 2 the same; the file fixed: Successfully applied 1 migration … now at version v3, no repair; on H2: … failed! Please restore backups and roll back database and code! · Unknown data type: \"EMAIL\"; the history table: the -1 << Flyway Schema History table created >> TABLE row and 3 add phone success FALSE, PHONE present; run 2 and the file fixed alone: Validate failed: Migrations have failed validation · Detected failed migration to version 3 (add phone). · Please remove any half-completed changes then run repair to fix the schema history., exit 1; repair() (a FlywayMigrationStrategy bean): Successfully repaired schema history table · Manual cleanup of the remaining effects of the failed migration may still be required. - then Duplicate column name \"PHONE\", success FALSE again; the column dropped by a second connection + repair(): now at version v3, success TRUE, PHONE and EMAIL")
    sys.exit(0)

if MODE == "traps":
    versions(L)
    i1 = one(L, r"^\(i\) ", "(i)"); i2 = one(L, r"^\(ii\) ", "(ii)"); i3 = one(L, r"^\(iii\) ", "(iii)"); i4 = one(L, r"^\(iv\) ", "(iv)"); i5 = one(L, r"^\(v\) ", "(v)"); i6 = one(L, r"^\(vi\) ", "(vi)")
    C, N, BL, B2, O, CL = L[i1:i2], L[i2:i3], L[i3:i4], L[i4:i5], L[i5:i6], L[i6:]
    has(C, "  Migration checksum mismatch for migration version 1", "(i) the checksum mismatch")
    ap = [l for l in C if l.startswith("  -> Applied to database : ")][0].split(": ")[1]; rl = [l for l in C if l.startswith("  -> Resolved locally    : ")][0].split(": ")[1]
    ok(ap != rl and ("  the second connection - V1's checksum in the history table: " + ap) in C, "(i) Applied to database %s = the history table's checksum (psql) ≠ Resolved locally %s" % (ap, rl))
    has(N, '  PROBE cause: org.flywaydb.core.api.FlywayException: Found non-empty schema(s) "public" but no schema history table. Use baseline() or set baselineOnMigrate to true to initialize the schema history table.', "(ii)")
    has(N, "  PROBE closed, exit 1", "(ii) exit 1")
    has(BL, "  INFO  [main] org.flywaydb.core.internal.command.DbBaseline : Successfully baselined schema with version: 1", "(iii) baselined at 1")
    has(BL, "  SQL State  : 23505", "(iii) 23505"); has(BL, '  Message    : ERROR: duplicate key value violates unique constraint "customer_name_key"', "(iii) the seed collides")
    has(BL, "    1|1|<< Flyway Baseline >>|BASELINE|<< Flyway Baseline >>||sa|t", "(iii) the history table: the baseline row alone")
    has(B2, "  INFO  [main] org.flywaydb.core.internal.command.DbBaseline : Successfully baselined schema with version: 2", "(iv) baselined at 2")
    has(B2, '  INFO  [main] org.flywaydb.core.internal.command.DbMigrate : Schema "public" is up to date. No migration necessary.', "(iv) up to date"); has(B2, "  PROBE closed, exit 0", "(iv) exit 0")
    has(O, "  Detected resolved migration not applied to database: 1.5.", "(v) refused"); has(O, '  INFO  [main] org.flywaydb.core.internal.command.DbMigrate : Migrating schema "public" to version "1.5 - note" [out of order]', "(v) out-of-order=true")
    has(O, "    3|1.5|note|SQL|V1_5__note.sql|" + [l for l in O if l.startswith("    3|1.5|note|")][0].split("|", 5)[5], "(v) the history table: 1.5 as rank 3")
    has(CL, "  PROBE clean refused: org.flywaydb.core.api.FlywayException: Unable to execute clean as it has been disabled with the 'flyway.cleanDisabled' property.", "(vi) clean refused")
    has(CL, "  PROBE info: 1 customer and pause SUCCESS", "(vi) info"); has(CL, "  PROBE info: 2 seed SUCCESS", "(vi) info"); has(CL, "    customer, flyway_schema_history, pause", "(vi) the tables kept")
    print("VALUES on PostgreSQL: a comment edited in an applied V1 - Migration checksum mismatch for migration version 1, -> Applied to database : %s (the history table's, by psql) -> Resolved locally : %s, exit 1; a schema seeded without Flyway - Found non-empty schema(s) \"public\" but no schema history table, exit 1; baseline-on-migrate - Successfully baselined schema with version: 1, then V2 fails SQL State 23505 duplicate key value violates unique constraint \"customer_name_key\", rolled back, the history table: the << Flyway Baseline >> BASELINE row alone; baseline-version 2 - up to date, exit 0; V1_5 added after v2 - Detected resolved migration not applied to database: 1.5., exit 1, with out-of-order=true [out of order], exit 0; clean() - Unable to execute clean as it has been disabled with the 'flyway.cleanDisabled' property. (info: 1 SUCCESS, 2 SUCCESS)" % (ap, rl))
    sys.exit(0)

if MODE == "seven":
    S466 = sys.argv[3]
    ok(cnt(L, "  exit 0 · the seven responses: 7 lines · md5 " + S466) == 2 and "  the seven, after/ against before/: lines that differ: 0" in L, "the seven %s on before/ and after/ (a guard)" % S466)
    q = [l for l in L if l.startswith("  its log's org.hibernate.SQL lines during the seven: ")]
    ok(len(q) == 2 and q[0] == q[1], "the SQL lines during the seven, the same on both: " + q[0].split(": ")[1])
    has(L, "  its log before the seven: Migrating lines 0 · 'Successfully applied 2 migrations' 0 · Flyway's H2 WARN 0", "before/: no Flyway")
    has(L, "  its log before the seven: Migrating lines 2 · 'Successfully applied 2 migrations' 1 · Flyway's H2 WARN 1", "after/: two Migrating lines, one applied line, the H2 WARN")
    print("VALUES %s on before/ and after/ (H2 over TCP), SQL lines during it %s on both; after/'s start: 2 Migrating lines, Successfully applied 2 migrations 1, Flyway's H2 WARN 1" % (S466, q[0].split(": ")[1]))
    sys.exit(0)

if MODE == "tests":
    for l in ("    TEST-com.tiffinbox.web.TiffinBoxWebTest.xml: tests 14 · failures 0 · errors 0 · skipped 0", "    TEST-com.tiffinbox.web.FullStackTest.xml: tests 3 · failures 0 · errors 0 · skipped 0",
              "    TEST-com.tiffinbox.web.FeedTest.xml: tests 1 · failures 0 · errors 0 · skipped 0", "  exit 0 · BUILD SUCCESS · offline: yes", "    in all: 3 reports · tests 18 · failures 0 · errors 0 · skipped 0",
              "  Surefire's console summary (its Results line): tests 18 · failures 0 · errors 0 · skipped 0 · the reports' sum the same: yes", "      passed  theSliceLeavesTheDatabaseOut"):
        has(L, l, "tests")
    has(L, "  its log's Flyway lines - 'Successfully applied 2 migrations': 1 · 'is up to date. No migration necessary': 1 · Flyway's H2 WARN ('newer than the version Flyway has been verified with'): 2", "tests: one context migrates, the other finds it migrated; the H2 WARN twice (RE-MEASURE 14)")
    print("VALUES 18 (14/3/1) on after/ from Surefire's reports, offline - a guard, C7-4 re-run; its log: Successfully applied 2 migrations 1, is up to date. No migration necessary 1 (the two contexts share one in-memory database), Flyway's H2 WARN 2")
    sys.exit(0)

if MODE == "xcheck":
    X34, XF = sys.argv[3], sys.argv[4]
    has(L, "  after/'s md5: %s · the filed xcheck.sql: %s · cmp: the same, byte for byte · the index lesson's xcheck.sql: %s · diff: 0 lines" % (X34, XF, X34), "xcheck: Hibernate's script unchanged by C1 (R.252)")
    ok(X34 == XF, "xcheck.sql = the index lesson's")
    has(L, "  INFO  [main] org.hibernate.orm.core : HHH000001: Hibernate ORM core version 7.4.13.Final", "HHH000001")
    has(L, "  exit 0 · its WARN lines: 0 · its org.flywaydb lines: 0", "no Flyway in the xcheck JVM")
    for l in ("    meal_type: V1 `meal_type VARCHAR(10) NOT NULL` · Hibernate's script `meal_type enum ('NON_VEG','VEG','VEGAN') not null`", "    version: V1 `version BIGINT NOT NULL DEFAULT 0` · Hibernate's script `version bigint not null`",
              "    the index: V1 `CREATE INDEX pause_customer_id_idx ON pause (customer_id);` · Hibernate's script `create index pause_customer_id_idx on pause (customer_id);`"):
        has(L, l, "R.80")
    fk = [l for l in L if l.startswith("    the foreign key: ")][0]; ok("FK<name>" in fk, "R.80: Hibernate names the foreign key, V1 does not")
    print("VALUES Hibernate's script over after/'s libraries %s = the index lesson's, byte for byte (no mapping moved); R.80, V1 against it: meal_type VARCHAR(10) vs enum ('NON_VEG','VEG','VEGAN'), version DEFAULT 0 vs none, the foreign key unnamed in V1 (PostgreSQL: pause_customer_id_fkey) vs Hibernate's FK<name>, the column order differs; the index and the identity columns agree" % X34)
    sys.exit(0)

if MODE == "exercise":
    EXW = sys.argv[3]
    b = L.index("in bash (/bin/bash --noprofile --norc) - the README's lines:"); z = L.index("in zsh (/bin/zsh -f) - the README's lines:")
    ok(L[b + 1:z] == L[z + 1:z + 1 + (z - b - 1)], "exercise: bash and zsh print the same")
    B = L[b:z]; s = [i for i, l in enumerate(B) if l.startswith("  then the solution's lines")][0]
    R, So = B[:s], B[s:]
    has(R, "    PROBE   history: -1 - << Flyway Schema History table created >> success=true | 1 v1 customer and pause success=true | 2 v2 seed success=true | 3 v3 add phone success=false", "the README: success=false")
    has(R, "    PROBE   customer's columns: id, name, meals_per_day, price_per_meal, meal_type, version, phone", "the README: the half-applied column (RE-MEASURE 1: one JVM)")
    has(R, "    PROBE   Detected failed migration to version 3 (add phone).", "the README: the second migrate refused")
    ok(not any("now at version v3" in l for l in R), "the README never reaches v3 (R.196)")
    has(So, "    PROBE migrate: applied 1 · now at version v3", "the solution: v3")
    has(So, "    PROBE   history: -1 - << Flyway Schema History table created >> success=true | 1 v1 customer and pause success=true | 2 v2 seed success=true | 3 v3 add phone success=true", "the solution: success=true")
    ok(cnt(B, "  the shell is now in: this unit's folder") == 1 and any(l.startswith("  the shell is now in: this unit's folder · ") for l in B), "the shell back in this folder")
    ok(EXW == "18", "the spoken line: %s words (wc -w)" % EXW)
    print("VALUES one JVM, H2 in memory, Flyway's API: migrate - success=false for 3, the phone column left; migrate again - Detected failed migration to version 3 (add phone).; the solution: the corrected file, the column dropped, repair() (removed failed 1), migrate() - now at version v3, success=true (%s words)" % EXW)
    sys.exit(0)
sys.exit("unknown mode " + MODE)
