"""Unit 01's checks (python3 -I -B harness/chk01.py MODE CAPTURE [ARGS]). One mode per capture - data, context, statements, tree,
alone, exercise - each reads the capture and asserts every number and string the video may say against another line of the SAME
run (psql against JdbcTemplate, the witness against Hibernate's getPrepareStatementCount(), the persistence context against the data
line, one JVM against the other), never against a typed figure; it prints VALUES - the values block's words - last. wib CAPTURE FILE
prints what an exercise file's block printed, read off the capture. A failed assertion prints FAIL and exits 1."""
import re, sys

MODE = sys.argv[1]
BAD = []


def ok(cond, what):
    print(("ok " if cond else "FAIL ") + what)
    if not cond:
        BAD.append(what)


def done(values=None):
    if values is not None and not BAD:
        print("VALUES " + values)
    sys.exit(1 if BAD else 0)


def read(p):
    with open(p, encoding="utf-8") as f:
        return f.read()


def nums(pat, text):
    return [tuple(int(x) for x in m) if isinstance(m, tuple) else int(m) for m in re.findall(pat, text)]


VERS = re.compile(r"PROBE versions: Spring Boot (\S+) · Spring Framework (\S+) · Spring Data JPA (\S+) · Spring Data JDBC (\S+) · Spring Data Relational (\S+)"
                  r" · Spring Data Commons (\S+) · Hibernate (\S+) · Flyway \(version.txt\) (\S+) · datasource-proxy \(pom.properties\) (\S+)$", re.M)


def versions(t, where):
    v = VERS.findall(t)
    ok(len(v) > 0, "%s: every JVM printed its version line (%d)" % (where, len(v)))
    ok(len(set(v)) == 1, "%s: one version line across its JVMs" % where)
    ok(t.count("PROBE started: yes") == len(v), "%s: a version line in every JVM that started (%d of %d)" % (where, len(v), t.count("PROBE started: yes")))
    ok(t.count("log: HHH000001: Hibernate ORM core version ") == len(v), "%s: HHH000001 in every JVM's log" % where)
    return v[0] if v else ("?",) * 9


def blocks(t, label):
    """The lines of one JVM's block: from its '-- label' line to the next '-- ' line."""
    m = re.search(r"^-- " + re.escape(label) + r".*?$(.*?)(?=^-- |\Z)", t, re.M | re.S)
    return m.group(1) if m else ""


# ---- data ----------------------------------------------------------------------------------------------------------------------
if MODE == "data":
    t = read(sys.argv[2])
    j = re.findall(r"PROBE data \(PostgreSQL 18\.6, JdbcTemplate\): customers (\d+) · pauses (\d+) · paused days (\d+)$", t, re.M)
    p = re.findall(r"psql \(a second client, PostgreSQL\): (\d+) customers · (\d+) pauses · (\d+) paused days$", t, re.M)
    ok(len(j) == 1 and len(p) == 1, "the data line printed once by JdbcTemplate and once by psql")
    ok(j == p, "JdbcTemplate's data line = psql's: %s / %s" % (j, p))
    b0 = re.search(r"PROBE before the seed \(PostgreSQL 18\.6, JdbcTemplate\): customers (\d+) · pauses (\d+)$", t, re.M)
    ok(b0 is not None, "V2's own rows counted by JdbcTemplate after Flyway, before the seed")
    v2 = int(b0.group(1)) if b0 else -1
    ok(j and int(j[0][0]) == v2 + 36, "customers = V2's %d + the 36 the seed inserted" % v2)
    versions(t, "data")
    c, pa, d = j[0] if j else ("?", "?", "?")
    done("the data line (PostgreSQL 18.6; JdbcTemplate = psql): customers %s · pauses %s · paused days %s" % (c, pa, d))

# ---- context -------------------------------------------------------------------------------------------------------------------
if MODE == "context":
    t = read(sys.argv[2])
    vs = versions(t, "context")
    res = {}
    for jvm in ("PostgreSQL, JVM 1", "PostgreSQL, JVM 2", "H2, one JVM"):
        b = blocks(t, jvm)
        ok(b != "", "the block %s is in the capture" % jvm)
        d = re.search(r"PROBE data \(([^,]+), JdbcTemplate\): customers (\d+) · pauses (\d+) · paused days (\d+)$", b, re.M)
        ok(d is not None, "%s: the data line before any count" % jvm)
        cu, pa = (int(d.group(2)), int(d.group(3))) if d else (-1, -1)
        rounds = []
        for r in (1, 2, 3):
            R = "PROBE r%d " % r
            A = re.search(re.escape(R) + r"window A \(Spring Data JPA findAllByOrderByNameAsc\(\), [^)]+\): customers (\d+) · pauses in them (\d+) · the persistence context holds entities (\d+) · collections (\d+)$", b, re.M)
            Aw = re.search(re.escape(R) + r"window A: the witness (\d+) · Hibernate getPrepareStatementCount\(\) (\d+) · equal: yes$", b, re.M)
            B = re.search(re.escape(R) + r"window B \(Spring Data JDBC findAll\(Sort\.by\(\"name\"\)\), the same transaction, [^)]+\): aggregates (\d+) · pauses in them (\d+) · the witness (\d+) · the persistence context holds entities (\d+) · collections (\d+)$", b, re.M)
            Bp = re.search(re.escape(R) + r"window B: SELECTs from pause by customer_id (\d+) · other statements (\d+)$", b, re.M)
            A2 = re.search(re.escape(R) + r"window A' \(A again, [^)]+\): customers (\d+) · the same objects as A's: yes · the persistence context holds entities (\d+) · collections (\d+)$", b, re.M)
            A2w = re.search(re.escape(R) + r"window A': the witness (\d+) · Hibernate getPrepareStatementCount\(\) (\d+) · equal: yes$", b, re.M)
            C = re.search(re.escape(R) + r"the commit \(readOnly = false\): flushCount (\d+) · findDirty calls (\d+) · entityUpdateCount (\d+) · entityLoadCount over the transaction (\d+)$", b, re.M)
            RO = re.search(re.escape(R) + r"readOnly = true, window A \([^)]+\): customers (\d+) · the persistence context holds entities (\d+) · collections (\d+)$", b, re.M)
            ROc = re.search(re.escape(R) + r"the commit \(readOnly = true\): flushCount (\d+) · findDirty calls (\d+) · entityUpdateCount (\d+)$", b, re.M)
            allm = all(x is not None for x in (A, Aw, B, Bp, A2, A2w, C, RO, ROc))
            ok(allm, "%s round %d: every labelled line (A, B, A', the commit, readOnly) is in the capture" % (jvm, r))
            if not allm:
                continue
            e, col = int(A.group(3)), int(A.group(4))
            ok(int(A.group(1)) == cu and int(A.group(2)) == pa, "%s r%d: A read the data line's customers and pauses (%s / %s)" % (jvm, r, A.group(1), A.group(2)))
            ok(e == cu + pa, "%s r%d: the context holds %d = customers %d + pauses %d (derived from the data line)" % (jvm, r, e, cu, pa))
            ok(col == cu, "%s r%d: collections %d = one per customer" % (jvm, r, col))
            ok(Aw.group(1) == Aw.group(2), "%s r%d: A's witness = getPrepareStatementCount() (%s = %s, R.357)" % (jvm, r, Aw.group(1), Aw.group(2)))
            ok(int(B.group(1)) == cu and int(B.group(2)) == pa, "%s r%d: B read the same customers and pauses as aggregates" % (jvm, r))
            ok(int(B.group(4)) == e and int(B.group(5)) == col, "%s r%d: after B the context still holds %s · %s (B added none)" % (jvm, r, B.group(4), B.group(5)))
            ok(int(B.group(3)) == int(Bp.group(1)) + int(Bp.group(2)) and int(Bp.group(1)) == cu and int(Bp.group(2)) == 1,
               "%s r%d: B's witness %s = 1 customer SELECT + %s SELECTs from pause, one per aggregate" % (jvm, r, B.group(3), Bp.group(1)))
            ok(int(A2.group(2)) == e and A2w.group(1) == A2w.group(2), "%s r%d: A' holds %s, witness = Hibernate's counter" % (jvm, r, A2.group(2)))
            ok(int(C.group(2)) == e, "%s r%d: the commit's findDirty calls %s = the entities held %d" % (jvm, r, C.group(2), e))
            ok(int(C.group(3)) == 0, "%s r%d: the commit wrote nothing (entityUpdateCount 0 - nothing was changed)" % (jvm, r))
            ok(int(RO.group(2)) == e and int(ROc.group(1)) == 0 and int(ROc.group(2)) == 0, "%s r%d: readOnly = true holds %s, its commit flushCount 0 · findDirty 0" % (jvm, r, RO.group(2)))
            rounds.append((e, col, int(Aw.group(1)), int(B.group(3)), int(Bp.group(1)), int(C.group(1)), int(C.group(2)), int(ROc.group(1)), int(ROc.group(2)), cu, pa))
        ok(len(set(rounds)) == 1 and len(rounds) == 3, "%s: the three rounds print the same counts" % jvm)
        res[jvm] = rounds[0] if rounds else None
    pg1, pg2, h2 = res.get("PostgreSQL, JVM 1"), res.get("PostgreSQL, JVM 2"), res.get("H2, one JVM")
    ok(pg1 is not None and pg1 == pg2, "the two PostgreSQL JVMs agree on every count (6/6)")
    dl = re.search(r"^the two PostgreSQL JVMs' PROBE lines, diff: (\d+) lines differ$", t, re.M)
    ok(dl is not None and dl.group(1) == "0", "diff of the two PostgreSQL JVMs' PROBE lines: %s lines differ" % (dl.group(1) if dl else "?"))
    h2same = h2 is not None and h2 == pg1
    print("info H2 against PostgreSQL: " + ("the same counts" if h2same else "DIFFERENT: %s / %s" % (h2, pg1)))
    if pg1:
        e, col, wa, wb, ps, fc, fd, rf, rd, cu, pa = pg1
        done("the persistence context after window A (PostgreSQL 18.6, two JVMs x 3 rounds): entities %d · collections %d - customers %d + pauses %d; after window B "
             "(Spring Data JDBC, the same transaction): entities %d; the read: window B %d statements (1 + %d SELECTs from pause) against window A %d "
             "(= getPrepareStatementCount() %d); the commit: flushCount %d · findDirty calls %d; readOnly = true: flushCount %d · findDirty calls %d; H2 2.5.250: %s"
             % (e, col, cu, pa, e, wb, ps, wa, wa, fc, fd, rf, rd, "the same counts" if h2same else "differs"))
    done()

# ---- statements ----------------------------------------------------------------------------------------------------------------
if MODE == "statements":
    t = read(sys.argv[2])
    versions(t, "statements")
    out = {}
    for jvm in ("PostgreSQL", "H2"):
        b = blocks(t, jvm)
        ok(b != "", "the block %s is in the capture" % jvm)
        d = re.search(r"PROBE data \([^,]+, JdbcTemplate\): customers (\d+) · pauses (\d+) · paused days (\d+)$", b, re.M)
        cu, pdl = (int(d.group(1)), int(d.group(3))) if d else (-1, -1)
        rows = []
        for r in (1, 2, 3):
            R = "PROBE r%d " % r
            J = re.search(re.escape(R) + r"page JPA \(Dashboard\.load\(\), [^)]+\): customers (\d+) · revenue (\d+) · paused days (\d+) · days by name (\d+) · the witness (\d+) · entityLoadCount (\d+) · collectionLoadCount (\d+)$", b, re.M)
            Jw = re.search(re.escape(R) + r"page JPA: the witness (\d+) · Hibernate getPrepareStatementCount\(\) (\d+) · equal: yes$", b, re.M)
            D = re.search(re.escape(R) + r"page Spring Data JDBC \(findAll\(Sort\.by\(\"name\"\)\) \+ monthRevenue\(\) \+ pausedDays\(\), [^)]+\): customers (\d+) · revenue (\d+) · paused days (\d+) · days by name (\d+) · the witness (\d+) · of them SELECTs from pause by customer_id (\d+) · Hibernate getPrepareStatementCount\(\) (\d+)$", b, re.M)
            K = re.search(re.escape(R) + r"page JdbcClient \(four SQL strings, [^)]+\): customers (\d+) · revenue (\d+) · paused days (\d+) · days by name (\d+) · the witness (\d+) · Hibernate getPrepareStatementCount\(\) (\d+)$", b, re.M)
            E = re.search(re.escape(R) + r"page: revenue equal on all three: yes · paused days equal: yes$", b, re.M)
            allm = all(x is not None for x in (J, Jw, D, K, E))
            ok(allm, "%s round %d: the three sides' lines and the equality line" % (jvm, r))
            if not allm:
                continue
            ok(J.group(5) == Jw.group(1) == Jw.group(2), "%s r%d: JPA's witness %s = getPrepareStatementCount() %s (R.357)" % (jvm, r, J.group(5), Jw.group(2)))
            ok(int(J.group(1)) == int(D.group(1)) == int(K.group(1)) == cu, "%s r%d: each side read the data line's %d customers" % (jvm, r, cu))
            ok(J.group(2) == D.group(2) == K.group(2), "%s r%d: revenue %s on all three (derived, equal)" % (jvm, r, J.group(2)))
            ok(int(J.group(3)) == int(D.group(3)) == int(K.group(3)) == pdl == int(J.group(4)) == int(D.group(4)) == int(K.group(4)),
               "%s r%d: paused days %s on all three and by name, = the data line's" % (jvm, r, J.group(3)))
            ok(int(D.group(6)) == cu and int(D.group(5)) == int(D.group(6)) + 3, "%s r%d: Spring Data JDBC %s = 1 customer SELECT + %s from pause + 2 sums" % (jvm, r, D.group(5), D.group(6)))
            ok(D.group(7) == "0" and K.group(6) == "0", "%s r%d: Hibernate counted 0 on the JDBC and JdbcClient sides" % (jvm, r))
            ok(int(J.group(7)) == cu, "%s r%d: collectionLoadCount %s = one per customer" % (jvm, r, J.group(7)))
            rows.append((int(J.group(5)), int(J.group(6)), int(J.group(7)), int(D.group(5)), int(D.group(6)), int(K.group(5)), int(J.group(2)), int(J.group(3))))
        sq = re.findall(r"^PROBE r1 page Spring Data JDBC \([^)]+\) SQL x(\d+): (SELECT .* FROM pause WHERE pause\.customer_id = \?)$", b, re.M | re.I)
        ok(len(sq) == 1 and rows and int(sq[0][0]) == rows[0][4], "%s: the pause SELECT counted by a grep of the witness's SQL list: x%s, one text" % (jvm, sq[0][0] if sq else "?"))
        jc = re.findall(r"^PROBE r1 page JdbcClient \([^)]+\) SQL x1: ", b, re.M)
        ok(rows and len(jc) == rows[0][5], "%s: JdbcClient's four SQL strings, each once in the witness's list" % jvm)
        ok(len(set(rows)) == 1 and len(rows) == 3, "%s: three rounds, the same counts" % jvm)
        out[jvm] = rows[0] if rows else None
    pg, h2 = out.get("PostgreSQL"), out.get("H2")
    print("info H2 against PostgreSQL: " + ("the same counts" if pg == h2 else "DIFFERENT %s / %s" % (h2, pg)))
    if pg:
        j, el, cl, d, ps, k, rev, pdy = pg
        done("the page (PostgreSQL 18.6, one run, a witness window per side): Spring Data JPA Dashboard.load() %d (= getPrepareStatementCount() %d; entityLoadCount %d · "
             "collectionLoadCount %d) · Spring Data JDBC %d, of them %d SELECTs from pause by customer_id · JdbcClient %d; revenue %d · paused days %d on all three; H2 2.5.250: %s"
             % (j, j, el, cl, d, ps, k, rev, pdy, "the same counts" if pg == h2 else "differs"))
    done()

# ---- tree ----------------------------------------------------------------------------------------------------------------------
if MODE == "tree":
    t = read(sys.argv[2])
    a = blocks(t, "anchor/ (both modules)"); b = blocks(t, "jpa-only/ (Spring Data JPA alone)")
    ok("BUILD SUCCESS" in a and "BUILD SUCCESS" in b, "mvn dependency:tree: BUILD SUCCESS on both trees")
    got = {}
    for art in ("spring-data-jpa", "spring-data-jdbc", "spring-data-relational", "spring-data-commons", "spring-boot", "hibernate-core", "flyway-core"):
        g = re.findall(r"^  tree: [a-z.]+:" + re.escape(art) + r":jar:(\S+):compile$", a, re.M)
        ok(len(set(g)) == 1, "anchor/: %s at one version: %s" % (art, sorted(set(g))))
        got[art] = g[0] if g else "?"
    ok(len({got[k] for k in ("spring-data-jpa", "spring-data-jdbc", "spring-data-relational", "spring-data-commons")}) == 1, "the four Spring Data jars: one train, one version")
    ok(re.search(r"^  tree: [a-z.]+:spring-data-jdbc:jar:", b, re.M) is None and re.search(r"^  tree: [a-z.]+:spring-data-jpa:jar:", b, re.M) is not None,
       "jpa-only/: spring-data-jpa and no spring-data-jdbc")
    bom = re.search(r"^  spring-boot-dependencies-(\S+)\.pom: <spring-data-bom\.version>(\S+)</spring-data-bom\.version>$", t, re.M)
    ok(bom is not None and bom.group(1) == got["spring-boot"], "the Spring Data train from Boot's BOM, the same Boot version")
    sw = re.search(r"^  the sweep, spring-boot\.xml: <release>(\S+)</release> · swept-at\.txt: (\S+)$", t, re.M)
    ok(sw is not None and sw.group(1).startswith("4.2.0-RC") and sw.group(2).startswith("2026-11-17T"), "the sweep: Boot's newest release a 4.2.0 release candidate, swept 2026-11-17")
    done("the dependency tree (anchor/, mvn -o dependency:tree): spring-data-jpa %s · spring-data-jdbc %s · spring-data-relational %s · spring-data-commons %s · "
         "Spring Data train %s · spring-boot %s · hibernate-core %s · flyway-core %s; the sweep (%s): Boot's newest %s"
         % (got["spring-data-jpa"], got["spring-data-jdbc"], got["spring-data-relational"], got["spring-data-commons"], bom.group(2) if bom else "?", got["spring-boot"],
            got["hibernate-core"], got["flyway-core"], sw.group(2)[:10] if sw else "?", sw.group(1) if sw else "?"))

# ---- alone ---------------------------------------------------------------------------------------------------------------------
if MODE == "alone":
    t = read(sys.argv[2])
    ok(re.search(r"^  removed from tiffinbox-web/pom\.xml: <artifactId>spring-boot-starter-data-jpa</artifactId>$", t, re.M) is not None, "the copy: the JPA starter removed, nothing else")
    ok(re.search(r"^  the copy's diff against anchor/: 4 lines, all in tiffinbox-web/pom\.xml$", t, re.M) is not None, "the copy differs from anchor/ by the starter's four lines")
    pk = re.search(r"^  mvn package: exit (\d+) · (BUILD \w+) · Surefire's Results line: Tests run: (\d+), Failures: (\d+), Errors: (\d+), Skipped: (\d+)$", t, re.M)
    ok(pk is not None, "mvn package's exit, BUILD line and Results line")
    it = re.search(r"^  the IT compiled at test-compile: (yes|no)", t, re.M)
    lib = re.search(r"^  the copy's jar: lib/ (\d+) libraries \(anchor/'s (\d+)\) · hibernate-core-\*\.jar: (\w+) · spring-data-jpa-\*\.jar: (\w+) · spring-data-jdbc-\*\.jar: (\w+)$", t, re.M)
    ok(lib is not None, "the copy's jar: its libraries against anchor/'s")
    run = re.search(r"^  java -jar: exit (\d+) · listening on 20402: (\d+) · 'Application run failed' (\d+)$", t, re.M)
    asp = re.search(r"^  the cause: (Could not configure Spring Data JPA auditing-feature because spring-aspects\.jar is not on the classpath;)$", t, re.M)
    ok(run is not None and run.group(1) == "1" and run.group(2) == "0" and run.group(3) == "1", "the copy's jar does not start: exit 1, nothing bound")
    ok(asp is not None, "the cause, read off the log: the auditing feature needs spring-aspects.jar")
    if pk and lib and run and asp:
        done("alone (a copy of anchor/ without Spring Data JPA's starter, never the anchor): mvn package exit %s, %s, Tests run: %s, Failures: %s, Errors: %s; the IT compiled: %s; "
             "the jar: %s libraries (anchor/'s %s), hibernate-core %s; java -jar: exit %s - %s"
             % (pk.group(1), pk.group(2), pk.group(3), pk.group(4), pk.group(5), it.group(1) if it else "?", lib.group(1), lib.group(2), lib.group(3), run.group(1), asp.group(1)))
    done()

# ---- exercise ------------------------------------------------------------------------------------------------------------------
EXL = re.compile(r"^    EX the read: customers (\d+) · the persistence context holds entities (\d+)$\n^    EX changed in Java, no save\(\): Ravi meals (\d+)$\n"
                 r"^    EX the commit: flushCount (\d+) · entityUpdateCount (\d+)$\n^    EX after, read back by JdbcTemplate \(a second client\): Ravi meals (\d+) · version (\d+)$\n"
                 r"^    EX done: (yes|no)", re.M)


def section(t, head):
    m = re.search(r"^" + re.escape(head) + r".*?$(.*?)(?=^\S|\Z)", t, re.M | re.S)
    return m.group(1) if m else ""


if MODE == "exercise":
    t = read(sys.argv[2]); words = sys.argv[3]
    ok(words == "21", "the spoken exercise line: %s words (wc -w)" % words)
    res = {}
    for sh in ("bash", "zsh"):
        for part in ("the README's lines", "the solution's lines"):
            s = section(t, "in %s - %s" % (sh, part))
            m = EXL.search(s)
            ok(m is not None, "%s, %s: the read, the change, the commit, the read-back, the verdict" % (sh, part))
            ok(re.search(r"^    javac: exit 0$", s, re.M) is not None and re.search(r"^    Ex01: exit 0$", s, re.M) is not None, "%s, %s: javac and Ex01 exit 0" % (sh, part))
            res[(sh, part)] = m.groups() if m else None
    o = section(t, "the other solution, named in SOLUTION.md")
    mo = EXL.search(o)
    ok(mo is not None, "the other solution's lines (read through CustomerAggregates)")
    br, so = res.get(("bash", "the README's lines")), res.get(("bash", "the solution's lines"))
    ok(res.get(("zsh", "the README's lines")) == br and res.get(("zsh", "the solution's lines")) == so, "bash and zsh print the same")
    before = re.search(r"^    EX before: Ravi meals (\d+) · version (\d+)$", t, re.M)
    if br and so and mo and before:
        m0, v0 = before.groups()
        ok(br[4] == "1" and br[7] == "no" and (br[5], br[6]) != (m0, v0), "broken: entityUpdateCount 1, the row changed (read back by JdbcTemplate)")
        ok(so[4] == "0" and so[7] == "yes" and (so[5], so[6]) == (m0, v0), "solution (readOnly = true): entityUpdateCount 0, the row unchanged")
        ok(mo.group(5) == "0" and mo.group(8) == "yes" and (mo.group(6), mo.group(7)) == (m0, v0), "the other solution (CustomerAggregates): entityUpdateCount 0, the row unchanged")
        ok(br[1] == so[1], "the read holds the same entities, broken and readOnly (%s)" % br[1])
        done("the exercise (H2 in memory, no Docker; bash and zsh): broken - the persistence context holds %s, flushCount %s, entityUpdateCount %s, Ravi read back by JdbcTemplate "
             "meals %s · version %s; readOnly = true - flushCount %s, entityUpdateCount %s, Ravi meals %s · version %s; through CustomerAggregates - the context holds %s, "
             "entityUpdateCount %s, Ravi meals %s · version %s; the spoken line %s words"
             % (br[1], br[3], br[4], br[5], br[6], so[3], so[4], so[5], so[6], mo.group(2), mo.group(5), mo.group(6), mo.group(7), words))
    done()

if MODE == "wib":
    t = read(sys.argv[2]); f = sys.argv[3]
    part = "the README's lines" if f.endswith("README.md") else "the solution's lines"
    s = section(t, "in bash - " + part)
    for l in s.splitlines():
        if l.startswith("    ") and not l.startswith("    $ "):
            print(l[4:])
    sys.exit(0)

print("no mode " + MODE); sys.exit(2)
