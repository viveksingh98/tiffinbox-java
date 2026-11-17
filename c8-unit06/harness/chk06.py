"""Unit 06's checks (python3 -I -B harness/chk06.py MODE CAPTURE [ARGS]). One mode per capture - witness, three, lines, compare,
plant, seven, exercise - each reads the capture and asserts every number and string the video may say against another line of the
SAME run (the witness against Hibernate's getPrepareStatementCount(), the witness's SQL list against its count, the rows against the
data line, the three sides' answers against each other, the counter's lines against wc -l, one database against the other), never
against a typed figure; it prints VALUES - the values block's words - last. `cells` builds the decision table's cell lines (inside
the compare capture) from this run's three, lines and compare logs and from earlier units' captures by hash (each hash read off
that unit's receipts.md5, each line read off that unit's README). wib CAPTURE FILE prints what an exercise file's block printed.
A failed assertion prints FAIL and exits 1. Unit 05's chk05.py form."""
import re, sys

MODE = sys.argv[1]
BAD = []


def ok(cond, what):
    if MODE != "cells" or not cond:
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


VERS = re.compile(r"PROBE versions: Spring Boot (\S+) · Spring Framework (\S+) · Spring Data JPA (\S+) · Spring Data JDBC (\S+) · Spring Data Relational (\S+)"
                  r" · Spring Data Commons (\S+) · Hibernate (\S+) · Flyway \(version.txt\) (\S+) · datasource-proxy \(pom.properties\) (\S+)$", re.M)
PG, H2 = "PostgreSQL 18.6", "H2 2.5.250"
ADJ = re.compile(r"\b(?:fast\w*|slow\w*|quick\w*|light\w*|heav\w*|simpl\w*|clean\w*|lean\w*|cheap\w*|costl\w*|expensive|overhead|efficient|better|worse|best|worst|easy|easier|hard|harder|nice|elegant|verbose|concise|bloat\w*|magic\w*|safe\w*|risky)\b", re.I)


def versions(t, where):
    v = VERS.findall(t)
    ok(len(v) > 0, "%s: every JVM printed its version line (%d)" % (where, len(v)))
    ok(len(set(v)) == 1, "%s: one version line across its JVMs" % where)
    ok(t.count("PROBE started: yes") == len(v), "%s: a version line in every JVM that started (%d of %d)" % (where, len(v), t.count("PROBE started: yes")))
    ok(t.count("log: HHH000001: Hibernate ORM core version ") == len(v), "%s: HHH000001 in every JVM's log" % where)
    ok(t.count("Found 1 JPA repository interface.") == len(v) and t.count("Found 1 JDBC repository interface.") == len(v), "%s: both modules' Found lines in every JVM (strict mode, S8.12)" % where)
    ok(len(re.findall(r"^  log: Database: jdbc:", t, re.M)) >= len(v), "%s: Flyway's Database line in the JVMs' logs (the schema's owner; the compare step's Flyway.info() logs it once more)" % where)
    return v[0] if v else ("?",) * 9


def blocks(t, label):
    m = re.search(r"^-- " + re.escape(label) + r".*?$(.*?)(?=^-- (?:PostgreSQL|H2)|\Z)", t, re.M | re.S)
    return m.group(1) if m else ""


def data(b, db):
    j = re.findall(r"PROBE data \(" + re.escape(db) + r", JdbcTemplate\): customers (\d+) · pauses (\d+) · paused days (\d+)$", b, re.M)
    b0 = re.findall(r"PROBE before the seed \(" + re.escape(db) + r", JdbcTemplate\): customers (\d+) · pauses (\d+)$", b, re.M)
    ok(len(j) >= 1 and len(b0) == len(j), "%s: the data line built by the seed (before %s, after %s)" % (db, b0, j))
    ok(len(set(j)) <= 1, "%s: every seed in the block built the same data line" % db)
    if j and b0:
        ok(int(j[0][0]) == int(b0[0][0]) + 36 and int(j[0][1]) == int(b0[0][1]) + 36, "%s: the seed's 36 customers and 36 pauses on V2's rows" % db)
    if db == PG:
        p = re.findall(r"psql \(a second client, PostgreSQL\): (\d+) customers · (\d+) pauses · (\d+) paused days$", b, re.M)
        ok(len(p) >= 1 and set(p) == {j[0]} if j else False, "PostgreSQL: psql's data line = JdbcTemplate's: %s / %s" % (p, j[:1]))
    return tuple(int(x) for x in j[0]) if j else (-1, -1, -1)


def one(b, pat, what):
    m = re.findall(pat, b, re.M)
    ok(len(m) >= 1, what + " (%d)" % len(m))
    return m[0] if m else None


# ---- witness -------------------------------------------------------------------------------------------------------------------
if MODE == "witness":
    t = read(sys.argv[2])
    vs = versions(t, "witness")
    ok(vs[8] == "1.11.1", "the witness: datasource-proxy 1.11.1 (its pom.properties; %s)" % vs[8])
    res = {}
    for db, lab in ((PG, "PostgreSQL 18.6 (the container)"), (H2, "H2 in memory")):
        b = blocks(t, lab)
        d = data(b, db)
        dsl = one(b, r"^PROBE the DataSource bean \(" + re.escape(db) + r"\): (net\.ttddyy\.dsproxy\.support\.ProxyDataSource) named '(witness)' around (com\.zaxxer\.hikari\.HikariDataSource) · DataSource beans (\d+) · the JdbcClient bean (\S+)$",
                  "%s: the DataSource bean is the witness's ProxyDataSource named 'witness' around HikariDataSource" % db)
        ok(dsl is not None and dsl[3] == "1", "%s: one DataSource bean - every side reaches the database through it" % db)
        mf = one(b, r"^PROBE datasource-proxy's jar manifest: Implementation-Version (\S+) ", "%s: the jar's manifest read" % db)
        sm = one(b, r"^PROBE witness window \(Spring Data JPA Dashboard\.load\(\), " + re.escape(db) + r"\): revenue (\d+) · paused days (\d+) · days by name (\d+) · customers (\d+)$", "%s: the JPA page's answers" % db)
        ok(sm is not None and int(sm[1]) == d[2] and int(sm[2]) == d[2] and int(sm[3]) == d[0], "%s: paused days and the by-name total = the data line's, customers = its count" % db)
        w = one(b, r"^PROBE witness window \(" + re.escape(db) + r"\): the witness (\d+) · Hibernate getPrepareStatementCount\(\) (\d+) · equal: (yes|NO)$", "%s: the witness's count beside Hibernate's" % db)
        ok(w is not None and w[0] == w[1] and w[2] == "yes", "%s: the witness = getPrepareStatementCount() on the JPA side (C8-9, S8.15): %s" % (db, w))
        ok(re.search(r"^  exit 0 ", b, re.M) is not None and "  exit 1 " not in b, "%s: the JVMs exited 0" % db)
        res[db] = (w[0] if w else "?", sm[0] if sm else "?", sm[1] if sm else "?", mf, dsl[4] if dsl else "?")
    ok(res[PG][:3] == res[H2][:3], "the JPA page's count and sums the same on both databases")
    done("the witness: datasource-proxy %s (its version from its pom.properties; the jar's manifest Implementation-Version %s), named 'witness', the DataSource bean wrapped by a BeanPostProcessor - net.ttddyy.dsproxy.support.ProxyDataSource around com.zaxxer.hikari.HikariDataSource, one DataSource bean, the JdbcClient bean %s; "
         "the JPA page Dashboard.load(): the witness %s = Hibernate getPrepareStatementCount() %s (PostgreSQL 18.6; H2 2.5.250 the same), revenue %s, paused days %s"
         % (vs[8], res[PG][3], res[PG][4], res[PG][0], res[PG][0], res[PG][1], res[PG][2]))


# ---- three ---------------------------------------------------------------------------------------------------------------------
def sqls(b, label, db):
    return [(int(n), q) for n, q in re.findall(r"^PROBE r1 " + re.escape(label) + r" \(" + re.escape(db) + r"\) SQL x(\d+): (.*)$", b, re.M)]


def orderby(q):
    m = re.search(r"\b(order by .*)$", q, re.I)
    return m.group(1) if m else None


def three_of(t):
    out = {}
    for db, lab in ((PG, "PostgreSQL 18.6 (the container)"), (H2, "H2 in memory")):
        b = blocks(t, lab)
        d = data(b, db)
        rounds = []
        for r in (1, 2, 3):
            R = "r%d " % r
            ans = re.findall(r"^PROBE " + R + r"answers, before any count \(" + re.escape(db) + r"\): JPA (.*) \| JDBC (.*) \| JdbcClient (.*) · the three Views' customers, sums and by-name maps equal: (yes|NO)$", b, re.M)
            ok(len(ans) == 1 and ans[0][0] == ans[0][1] == ans[0][2] and ans[0][3] == "yes", "%s %s: the three answers equal, asserted before any count" % (db, R.strip()))
            sm = re.match(r"revenue (\d+) · paused days (\d+) · days by name (\d+) · customers (\d+)$", ans[0][0]) if ans else None
            ok(sm is not None and int(sm.group(2)) == d[2] and int(sm.group(3)) == d[2] and int(sm.group(4)) == d[0], "%s %s: paused days and by-name total = the data line's %d, customers = %d" % (db, R.strip(), d[2], d[0]))
            no = re.findall(r"^PROBE " + R + r"name order \(" + re.escape(db) + r"\): JPA's list = JDBC's = JdbcClient's: (yes|NO) · first (.*) · last (.*)$", b, re.M)
            ok(len(no) == 1 and no[0][0] == "yes", "%s %s: the three name orders equal" % (db, R.strip()))
            j = re.findall(r"^PROBE " + R + r"JPA \(Dashboard\.load\(\), " + re.escape(db) + r"\): the witness (\d+) · rows (\d+) · Hibernate getPrepareStatementCount\(\) (\d+) · equal: (yes|NO)$", b, re.M)
            ok(len(j) == 1 and j[0][0] == j[0][2] and j[0][3] == "yes", "%s %s: JPA - the witness = getPrepareStatementCount() (%s)" % (db, R.strip(), j))
            k = re.findall(r"^PROBE " + R + r"Spring Data JDBC \(JdbcDashboard\.load\(\), " + re.escape(db) + r"\): the witness (\d+) · rows (\d+) · of them SELECT from customer (\d+) · SELECT from pause by customer_id (\d+) · other (\d+) · Hibernate getPrepareStatementCount\(\) (\d+)$", b, re.M)
            kk = [int(x) for x in k[0]] if k else [-1] * 6
            ok(len(k) == 1 and kk[0] == kk[2] + kk[3] + kk[4] and kk[2] == 1 and kk[3] == d[0] and kk[4] == 2 and kk[5] == 0,
               "%s %s: JDBC - the witness %d = 1 customer SELECT + one pause SELECT per customer (%d = the data line's customers) + the two sums; Hibernate 0" % (db, R.strip(), kk[0], kk[3]))
            ok(kk[1] == d[0] + d[1] + 2, "%s %s: JDBC rows %d = the data line's customers + pauses + the two sums' rows (derived)" % (db, R.strip(), kk[1]))
            c = re.findall(r"^PROBE " + R + r"JdbcClient \(PlainSql\.load\(\), " + re.escape(db) + r"\): the witness (\d+) · rows (\d+) · Hibernate getPrepareStatementCount\(\) (\d+)$", b, re.M)
            cc = [int(x) for x in c[0]] if c else [-1] * 3
            ok(len(c) == 1 and cc[2] == 0 and cc[1] == 2 * d[0] + 2, "%s %s: JdbcClient - rows %d = the customers + the by-name rows (one per customer) + the two sums' rows (derived); Hibernate 0" % (db, R.strip(), cc[1]))
            rounds.append((j[0][:2] if j else None, (k[0][0], k[0][1]) if k else None, (c[0][0], c[0][1]) if c else None, sm.groups() if sm else None, no[0][1:] if no else None))
        ok(len(set(map(str, rounds))) == 1, "%s: the three rounds print the same counts (S8.16: counts, never order)" % db)
        j1, k1, c1 = sqls(b, "JPA", db), sqls(b, "Spring Data JDBC (the 40 by customer_id: one text)", db), sqls(b, "JdbcClient", db)
        ok(sum(n for n, _ in j1) == int(rounds[0][0][0]), "%s: the JPA SQL list adds up to its count" % db)
        ok(sum(n for n, _ in k1) == int(rounds[0][1][0]) and sum(n for n, _ in c1) == int(rounds[0][2][0]), "%s: the JDBC and JdbcClient SQL lists add up to their counts" % db)
        jo = sorted(orderby(q) for n, q in j1 if orderby(q))
        ko = [orderby(q) for n, q in k1 if orderby(q) and q.upper().startswith("SELECT CUSTOMER.") is False and " FROM customer " in q]
        ko = [orderby(q) for n, q in k1 if " FROM customer ORDER BY " in q]
        co = [orderby(q) for n, q in c1 if q.startswith("select name, meals_per_day")]
        ok(len(ko) == 1 and ko[0].lower() == "order by customer.name asc", "%s: findAll(Sort.by(\"name\")) on the JDBC side - its ORDER BY at the driver (%s)" % (db, ko))
        ok(len(jo) == 2 and set(jo) == {"order by ce1_0.name"}, "%s: the JPA side's two customer reads both order by ce1_0.name (%s)" % (db, jo))
        ok(co == ["order by name"], "%s: the plain SQL's own order by name (%s)" % (db, co))
        jt = [q for n, q in j1 if " left join pause " in q]
        ok(len(jt) == 1, "%s: the JPA side's entity-graph read - one statement with the pauses joined in" % db)
        out[db] = dict(d=d, r=rounds[0], ko=ko[0] if ko else "?", jo=jo[0] if jo else "?", co=co[0] if co else "?", k1=k1)
    return out


if MODE == "three":
    t = read(sys.argv[2])
    vs = versions(t, "three")
    o = three_of(t)
    p, h = o[PG], o[H2]
    ok(p["d"] == h["d"], "the data line equal on both databases")
    ok(p["r"] == h["r"], "the counts, rows, sums and name order the same on PostgreSQL and H2 (%s / %s)" % (p["r"], h["r"]))
    r = p["r"]
    done("the hook, the page three ways (PostgreSQL 18.6, three rounds, one witness; repeated on H2 2.5.250, the same counts): Spring Data JPA Dashboard.load() %s statements (= Hibernate getPrepareStatementCount() %s) · rows %s; "
         "Spring Data JDBC (findAll(Sort.by(\"name\")) + monthRevenue() + pausedDays()) %s statements (1 customer SELECT + %d pause SELECTs by customer_id + 2 sums) · rows %s; JdbcClient (four SQL strings) %s statements · rows %s; "
         "the answers asserted equal first - revenue %s, paused days %s, days by name %s, customers %s on all three; the name order equal on all three (first %s, last %s); "
         "the ORDER BY at the driver - Spring Data JDBC findAll(Sort.by(\"name\")): PostgreSQL `%s`, H2 `%s`; the JPA side's two customer reads (JpaRepository findAll(Sort.by(\"name\")) through CustomerRepository.findAll(), and the derived findAllByOrderByNameAsc()): `%s`; the plain SQL: `%s`"
         % (r[0][0], r[0][0], r[0][1], r[1][0], p["d"][0], r[1][1], r[2][0], r[2][1], r[3][0], r[3][1], r[3][2], r[3][3], r[4][0], r[4][1], p["ko"], h["ko"], p["jo"], p["co"]))


# ---- lines ---------------------------------------------------------------------------------------------------------------------
def lines_of(t):
    files = re.findall(r"^lines (\S+): (\S+) · lines (\d+) · code (\d+)$", t, re.M)
    tots = {l: (int(f), int(n), int(c)) for l, f, n, c in re.findall(r"^lines (\S+) total: (\d+) files · lines (\d+) · code (\d+)$", t, re.M)}
    return files, tots


if MODE == "lines":
    t = read(sys.argv[2])
    ok("loc self-test: the fixture (13 lines: a Javadoc block, a block comment, a line comment, a trailing comment, a block that ends before code, 2 blank) -> lines 13 · code 5 · ok" in t, "the counter's self-test passed first")
    files, tots = lines_of(t)
    wc = dict(re.findall(r"^  wc -l (\S+): (\d+)$", t, re.M))
    ok(len(files) == 12 and len(wc) == 12, "twelve files counted, twelve wc -l lines (%d, %d)" % (len(files), len(wc)))
    for l, f, n, c in files:
        ok(wc.get(f) == n, "%s: the counter's lines %s = wc -l %s" % (f, n, wc.get(f)))
        ok(int(c) <= int(n), "%s: code lines %s <= lines %s" % (f, c, n))
    for l in ("JPA", "JDBC", "quoting", "SQL", "shared"):
        fs = [(int(n), int(c)) for ll, f, n, c in files if ll == l]
        ok(l in tots and tots[l] == (len(fs), sum(a for a, _ in fs), sum(b for _, b in fs)), "%s: the total = the sum of its files (%s)" % (l, tots.get(l)))
    jp = [f for l, f, n, c in files if l == "JPA"]
    ok(all(f.startswith("anchor/") for f in jp) and len(jp) == 5, "the JPA side: the anchor's own five files (no second entity set, RED #10)")
    ok(sum(1 for l, f, n, c in files if l == "JDBC" and f.startswith("anchor/")) == 3, "the JDBC side: unit 02's three files from the anchor, plus the harness's JdbcDashboard")
    per = "; ".join("%s %s lines · %s code" % (f.split("/")[-1], n, c) for l, f, n, c in files)
    tt = "; ".join("%s %d files · %d lines · %d code" % (l, *tots[l]) for l in ("JPA", "JDBC", "quoting", "SQL", "shared") if l in tots)
    done("one counter (harness/loc.py, its self-test first; lines = wc -l, code = not blank, not wholly comment): %s - totals: %s (the anchor's JPA files carry Course 7's teaching Javadoc: the code column is the like-for-like one)" % (per, tt))


# ---- cells (inside the compare capture) ------------------------------------------------------------------------------------------
def md5of(p, nm):
    for l in read(p).splitlines():
        f = l.split()
        if f and f[0] == nm:
            return f[1]
    return None


def readme_line(p, pat):
    for l in read(p).splitlines():
        s = l.strip()
        m = re.match(pat, s)
        if m:
            return s, m
    return None, None


if MODE == "cells":
    th, ln, cp, m2, r2, m3, r3 = sys.argv[2:9]
    o = three_of(read(th))
    files, tots = lines_of(read(ln))
    lg = "\n".join(l for l in read(cp).splitlines() if l.startswith("PROBE "))
    rows = []

    def cell(row, side, value, source):
        rows.append((row, side))
        print("cell %s · %s · %s · %s" % (row, side, value, source))

    def drop(row, side, why):
        print("dropped %s · %s · %s" % (row, side, why))

    r = o[PG]["r"]
    for side, i in (("Spring Data JPA", 0), ("Spring Data JDBC", 1), ("JdbcClient", 2)):
        cell("statements for the page", side, r[i][0], "three (PostgreSQL 18.6, r1-r3; H2 the same)")
    for side, i in (("Spring Data JPA", 0), ("Spring Data JDBC", 1), ("JdbcClient", 2)):
        cell("rows the driver handed over", side, r[i][1], "three (PostgreSQL 18.6, the witness's ResultSet.next() count)")
    hj = re.search(r"^PROBE held after Spring Data JPA findAllByOrderByNameAsc\(\) \(PostgreSQL 18\.6, one transaction\): customers \d+ · the witness \d+ · the persistence context holds entities (\d+) · collections (\d+)$", lg, re.M)
    hd = re.search(r"^PROBE held after Spring Data JDBC findAll\(Sort\.by\(\"name\"\)\) \(PostgreSQL 18\.6, the same transaction\): aggregates \d+ · the witness \d+ · the persistence context holds entities (\d+) · collections (\d+)$", lg, re.M)
    hc = re.search(r"^PROBE held after JdbcClient PlainSql\.load\(\) \(PostgreSQL 18\.6, the same transaction\): customers \d+ · the witness \d+ · the persistence context holds entities (\d+) · collections (\d+)$", lg, re.M)
    if hj and hd and hc:
        cell("entities the persistence context holds after the read", "Spring Data JPA", "%s entities · %s collections" % hj.groups(), "compare (PostgreSQL 18.6, one transaction)")
        cell("entities the persistence context holds after the read", "Spring Data JDBC", "none added (%s -> %s)" % (hj.group(1), hd.group(1)), "compare (PostgreSQL 18.6, the same transaction)")
        cell("entities the persistence context holds after the read", "JdbcClient", "none added (%s -> %s)" % (hd.group(1), hc.group(1)), "compare (PostgreSQL 18.6, the same transaction)")
    h2 = md5of(m2, "dirty")
    s, m = readme_line(r2, r"^window A \(Spring Data JPA: findByName, meals \+ 1, no save, commit\) \(PostgreSQL 18\.6\) SQL: (update customer set .*)$")
    if h2 and s:
        cell("load, change, no save, commit", "Spring Data JPA", "the flush writes `%s`" % m.group(1), "c8-unit02 dirty %s (its README: window A's SQL line)" % h2[:8])
    s, m = readme_line(r2, r"^window B \(Spring Data JDBC: findById, meals \+ 1, no save, commit\) \(PostgreSQL 18\.6\): statements (\d+)$")
    s2, m2b = readme_line(r2, r"^psql, after B: Ravi meals (\d+) version (\d+) updated_at null$")
    if h2 and s and s2:
        cell("load, change, no save, commit", "Spring Data JDBC", "%s statements, no UPDATE; psql after it: meals %s · version %s" % (m.group(1), m2b.group(1), m2b.group(2)), "c8-unit02 dirty %s (its README: window B's lines)" % h2[:8])
    drop("load, change, no save, commit", "JdbcClient", "not measured (no unit's run changes a JdbcClient record)")
    hl = md5of(m2, "lazy")
    s, m = readme_line(r2, r"^lazy \(PostgreSQL 18\.6\): Spring Data JPA getPauses\(\)\.size\(\) -> (org\.hibernate\.LazyInitializationException: .*)$")
    if hl and s:
        cell("the pauses read after the call, no transaction", "Spring Data JPA", m.group(1), "c8-unit02 lazy %s (its README)" % hl[:8])
    s, m = readme_line(r2, r"^lazy \(PostgreSQL 18\.6\), after the call, no transaction: Spring Data JDBC getPauses\(\) -> (\d+ · java\.util\.LinkedHashSet)$")
    if hl and s:
        cell("the pauses read after the call, no transaction", "Spring Data JDBC", "getPauses() -> " + m.group(1), "c8-unit02 lazy %s (its README)" % hl[:8])
    drop("the pauses read after the call, no transaction", "JdbcClient", "not measured")
    for side, l in (("Spring Data JPA", "JPA"), ("Spring Data JDBC", "JDBC"), ("JdbcClient", "SQL")):
        if l in tots:
            extra = " (+ JdbcNames, the quoting fix: %d lines · %d code)" % (tots["quoting"][1], tots["quoting"][2]) if l == "JDBC" and "quoting" in tots else ""
            cell("code lines for the page (lines)", side, "%d (%d)%s" % (tots[l][2], tots[l][1], extra), "lines (harness/loc.py, %d files)" % tots[l][0])
    fw = re.search(r"^PROBE the schema's owner \(PostgreSQL 18\.6, the context's Flyway bean\): (applied V1 Success, V2 Success, V3 Success · current V3) · spring\.jpa\.hibernate\.ddl-auto (\S+)$", lg, re.M)
    if fw:
        for side in ("Spring Data JPA", "Spring Data JDBC", "JdbcClient"):
            cell("the schema's owner", side, "Flyway: %s (ddl-auto %s)" % fw.groups(), "compare (PostgreSQL 18.6, one JVM serves the three sides)")
    s, m = readme_line(r2, r"^psql, after A: Ravi meals (\d+) version (\d+) updated_at set$")
    s2, mb = readme_line(r2, r"^psql, after A': Ravi meals (\d+) version (\d+) updated_at set$")
    s0, m0 = readme_line(r2, r"^psql, after B: Ravi meals (\d+) version (\d+) updated_at null$")
    if h2 and s and s2 and s0:
        cell("the version column, one row", "Spring Data JPA", "version %s -> %s (the flush, no save)" % (m0.group(2), m.group(2)), "c8-unit02 dirty %s (its README: psql after A)" % h2[:8])
        cell("the version column, one row", "Spring Data JDBC", "version %s -> %s (save)" % (m.group(2), mb.group(2)), "c8-unit02 dirty %s (its README: psql after A')" % h2[:8])
    drop("the version column, one row", "JdbcClient", "not measured")
    a = re.search(r"^PROBE missing row, Spring Data JPA findById\(-1L\) \(PostgreSQL 18\.6\): (.*)$", lg, re.M)
    b = re.search(r"^PROBE missing row, Spring Data JPA getReferenceById\(-1L\)\.getName\(\) \(PostgreSQL 18\.6\): (.*)$", lg, re.M)
    c = re.search(r"^PROBE missing row, Spring Data JDBC findById\(-1L\) \(PostgreSQL 18\.6\): (.*)$", lg, re.M)
    d = re.search(r"^PROBE missing row, JdbcClient single\(\) on Nobody \(PostgreSQL 18\.6\): (.*)$", lg, re.M)
    if a and b:
        cell("a missing row", "Spring Data JPA", "findById -> %s; getReferenceById(...).getName() -> %s" % (a.group(1), b.group(1)), "compare (PostgreSQL 18.6)")
    if c:
        cell("a missing row", "Spring Data JDBC", "findById -> %s" % c.group(1), "compare (PostgreSQL 18.6)")
    if d:
        cell("a missing row", "JdbcClient", "single() -> %s" % d.group(1), "compare (PostgreSQL 18.6)")
    cs = re.search(r"^PROBE collection save, Spring Data JPA \(PostgreSQL 18\.6\): Sunil's pauses loaded \d+ · one PauseEntity persisted and added · flush: the witness (\d+)$", lg, re.M)
    cq = re.findall(r"^PROBE collection save, Spring Data JPA \(PostgreSQL 18\.6\) SQL x\d+: (.*)$", lg, re.M)
    if cs and len(cq) == 1:
        cell("one pause added to a customer's collection, saved", "Spring Data JPA", "the flush: %s statement, `%s` (rolled back)" % (cs.group(1), cq[0]), "compare (PostgreSQL 18.6)")
    h3 = md5of(m3, "reinsert")
    s, m = readme_line(r3, r"^PROBE reinsert \(Spring Data JDBC save\(\), Sunil \+ one 1-day pause, PostgreSQL 18\.6\): the witness (\d+) · SELECT 0 · (UPDATE 1 · DELETE 1 · INSERT with id 1 · INSERT without id 1)$")
    if h3 and s:
        cell("one pause added to a customer's collection, saved", "Spring Data JDBC", "save(): %s statements - %s" % (m.group(1), m.group(2)), "c8-unit03 reinsert %s (its README)" % h3[:8])
    drop("one pause added to a customer's collection, saved", "JdbcClient", "not measured")
    cell("the name order (PostgreSQL 18.6)", "Spring Data JPA", "`%s` (JpaRepository findAll(Sort.by(\"name\")) through CustomerRepository.findAll(), and the derived findAllByOrderByNameAsc())" % o[PG]["jo"], "three (r1's SQL list)")
    cell("the name order (PostgreSQL 18.6)", "Spring Data JDBC", "`%s` (findAll(Sort.by(\"name\")))" % o[PG]["ko"], "three (r1's SQL list)")
    cell("the name order (PostgreSQL 18.6)", "JdbcClient", "`%s` (written in the SQL string)" % o[PG]["co"], "three (r1's SQL list)")
    drop("a test slice per side", "all three", "not measured here (unit 07 measures the Spring Data JDBC slice)")
    drop("auditing per side", "all three", "not measured here (unit 02's RE-MEASURE 3 ran on a copy - not a cell)")
    nr = len(dict.fromkeys(rr for rr, _ in rows))
    print("the table: %d rows · %d cells kept · 4 cells dropped (one per row named above) · 2 rows dropped (a test slice, auditing)" % (nr, len(rows)))
    sys.exit(0 if len(rows) == 3 * nr - 4 and not BAD else 1)


# ---- compare -------------------------------------------------------------------------------------------------------------------
if MODE == "compare":
    t = read(sys.argv[2]); th = read(sys.argv[3]); ln = read(sys.argv[4])
    vs = versions(t, "compare")
    o = three_of(th)
    res = {}
    for db, lab in ((PG, "PostgreSQL 18.6 (the container)"), (H2, "H2 in memory")):
        b = blocks(t, lab)
        d = data(b, db)
        hj = one(b, r"^PROBE held after Spring Data JPA findAllByOrderByNameAsc\(\) \(" + re.escape(db) + r", one transaction\): customers (\d+) · the witness (\d+) · the persistence context holds entities (\d+) · collections (\d+)$", "%s: held after the JPA read" % db)
        hd = one(b, r"^PROBE held after Spring Data JDBC findAll\(Sort\.by\(\"name\"\)\) \(" + re.escape(db) + r", the same transaction\): aggregates (\d+) · the witness (\d+) · the persistence context holds entities (\d+) · collections (\d+)$", "%s: held after the JDBC read" % db)
        hc = one(b, r"^PROBE held after JdbcClient PlainSql\.load\(\) \(" + re.escape(db) + r", the same transaction\): customers (\d+) · the witness (\d+) · the persistence context holds entities (\d+) · collections (\d+)$", "%s: held after the JdbcClient read" % db)
        ok(hj is not None and int(hj[2]) == d[0] + d[1] and int(hj[3]) == d[0] and hj[1] == "1", "%s: JPA's read - 1 statement, the context holds the data line's customers + pauses as entities and one collection per customer (derived)" % db)
        ok(hd is not None and hd[2:] == hj[2:] and int(hd[1]) == d[0] + 1, "%s: the JDBC read in the same transaction adds none (%s -> %s); its witness 1 + one per customer" % (db, hj[2] if hj else "?", hd[2] if hd else "?"))
        ok(hc is not None and hc[2:] == hj[2:] and hc[1] == o[db]["r"][2][0], "%s: the JdbcClient page in the same transaction adds none; its witness = three's" % db)
        cs = one(b, r"^PROBE collection save, Spring Data JPA \(" + re.escape(db) + r"\): Sunil's pauses loaded (\d+) · one PauseEntity persisted and added · flush: the witness (\d+)$", "%s: JPA's collection save" % db)
        cq = re.findall(r"^PROBE collection save, Spring Data JPA \(" + re.escape(db) + r"\) SQL x(\d+): (.*)$", b, re.M)
        ok(cs is not None and cs[1] == "1" and len(cq) == 1 and cq[0][0] == "1" and cq[0][1].startswith("insert into pause ("), "%s: the flush of one added pause - 1 statement, an insert into pause, no delete (%s)" % (db, cq))
        rb = one(b, r"^PROBE collection save, Spring Data JPA: Sunil's pause rows by JdbcTemplate \(a second client\) before (\d+) · after the rollback (\d+)$", "%s: Sunil's rows read back" % db)
        ok(rb is not None and rb[0] == rb[1] and cs is not None and rb[0] == cs[0], "%s: rolled back - Sunil's pause rows unchanged by a second client, = the pauses loaded" % db)
        ms = [one(b, r"^PROBE missing row, Spring Data JPA findById\(-1L\) \(" + re.escape(db) + r"\): (.*)$", "%s: JPA findById" % db),
              one(b, r"^PROBE missing row, Spring Data JPA getReferenceById\(-1L\)\.getName\(\) \(" + re.escape(db) + r"\): (.*)$", "%s: JPA getReferenceById" % db),
              one(b, r"^PROBE missing row, Spring Data JDBC findById\(-1L\) \(" + re.escape(db) + r"\): (.*)$", "%s: JDBC findById" % db),
              one(b, r"^PROBE missing row, JdbcClient single\(\) on Nobody \(" + re.escape(db) + r"\): (.*)$", "%s: JdbcClient single()" % db)]
        ok(ms[0] == "Optional.empty" and ms[2] == "Optional.empty", "%s: findById -> Optional.empty on both repositories" % db)
        ok(ms[1] is not None and ms[1].startswith("jakarta.persistence.EntityNotFoundException: "), "%s: getReferenceById on a missing id -> EntityNotFoundException when read (%s)" % (db, ms[1]))
        ok(ms[3] == "org.springframework.dao.EmptyResultDataAccessException: Incorrect result size: expected 1, actual 0", "%s: JdbcClient single() -> EmptyResultDataAccessException, = units 04/05's text" % db)
        fw = one(b, r"^PROBE the schema's owner \(" + re.escape(db) + r", the context's Flyway bean\): applied V1 Success, V2 Success, V3 Success · current V3 · spring\.jpa\.hibernate\.ddl-auto validate$", "%s: Flyway applied V1-V3, ddl-auto validate" % db)
        res[db] = (hj, hd, hc, cs, ms)
    ok(res[PG][0][2:] == res[H2][0][2:] and res[PG][4][::2] == res[H2][4][::2], "the held counts and the missing-row outcomes the same on both databases")
    cl = re.findall(r"^cell (.*?) · (.*?) · (.*) · (.*)$", t, re.M)
    rows = list(dict.fromkeys(r for r, _, _, _ in cl))
    ok(0 < len(rows) <= 12, "the table: %d rows, at most 12 (R.261)" % len(rows))
    ok(all(not ADJ.search(re.sub(r"`[^`]*`", "", v)) for _, _, v, _ in cl), "no adjective in any cell (R.261): %s" % [v for _, _, v, _ in cl if ADJ.search(re.sub(r"`[^`]*`", "", v))])
    ok(all(s for _, _, _, s in cl), "every cell names its source (R.338)")
    for _, _, v, s in cl:
        m = re.match(r"c8-unit(0[23]) (\w+) ([0-9a-f]{8}) ", s)
        if m:
            full = [l.split()[1] for l in read("../c8-unit%s/receipts.md5" % m.group(1)).splitlines() if l.split() and l.split()[0] == m.group(2)]
            ok(len(full) == 1 and full[0].startswith(m.group(3)), "the cell's earlier capture %s %s by hash = c8-unit%s/receipts.md5's" % (m.group(2), m.group(3), m.group(1)))
    files, tots = lines_of(ln)
    lc = {sd: v for r, sd, v, _ in cl if r == "code lines for the page (lines)"}
    for sd, l in (("Spring Data JPA", "JPA"), ("Spring Data JDBC", "JDBC"), ("JdbcClient", "SQL")):
        ok(l in tots and lc.get(sd, "").startswith("%d (%d)" % (tots[l][2], tots[l][1])), "S8.18: the %s code-lines cell is the counter's code column first, its lines column beside it (%s)" % (sd, lc.get(sd)))
    st = {sd: v for r, sd, v, _ in cl if r == "statements for the page"}
    ok(st.get("Spring Data JPA") == o[PG]["r"][0][0] and st.get("Spring Data JDBC") == o[PG]["r"][1][0] and st.get("JdbcClient") == o[PG]["r"][2][0], "the statements row = three's counts")
    sm = re.search(r"^the table: (\d+) rows · (\d+) cells kept · 4 cells dropped .* · 2 rows dropped \(a test slice, auditing\)$", t, re.M)
    ok(sm is not None and int(sm.group(1)) == len(rows) and int(sm.group(2)) == len(cl), "the row count said = the cell lines' rows (%s)" % (str(sm.groups()) if sm else None))
    dr = re.findall(r"^dropped (.*?) · (.*?) · (.*)$", t, re.M)
    ok(len(dr) == 6, "the dropped cells and rows named (%d)" % len(dr))
    hj, hd, hc, cs, ms = res[PG]
    done("the decision table: %d rows, %d cells, each a cell line with its source (this run's three, lines, compare; unit 02's dirty and lazy and unit 03's reinsert by hash); dropped: %s; "
         "measured here (PostgreSQL 18.6; H2 2.5.250 the same): after the JPA read in one transaction the persistence context holds %s entities · %s collections, the JDBC read and the JdbcClient page in the same transaction add none (%s -> %s -> %s); "
         "JPA's flush of one added pause %s statement (an insert into pause, rolled back); a missing row - JPA findById %s, getReferenceById(...).getName() %s; Spring Data JDBC findById %s; JdbcClient single() %s; the schema Flyway's (V1-V3, ddl-auto validate) on all three"
         % (len(rows), len(cl), "; ".join("%s (%s)" % (a, b) for a, b, _ in dr), hj[2], hj[3], hj[2], hd[2], hc[2], cs[1], ms[0], ms[1], ms[2], ms[3]))


# ---- plant ---------------------------------------------------------------------------------------------------------------------
if MODE == "plant":
    t = read(sys.argv[2]); o = three_of(read(sys.argv[3]))
    vs = versions(t, "plant")
    b = blocks(t, "PostgreSQL 18.6 (the container)")
    d = data(b, PG)
    p1 = re.search(r"^-- plant 1: .*?$(.*?)(?=^-- plant 2|\Z)", t, re.M | re.S)
    p2 = re.search(r"^-- plant 2: .*?$(.*?)\Z", t, re.M | re.S)
    a = p1.group(1) if p1 else ""; c = p2.group(1) if p2 else ""
    w1 = re.findall(r"^PROBE plant43 \(Spring Data JDBC JdbcDashboard\.load\(\), PostgreSQL 18\.6\): the witness (\d+) · asserted == 4$", a, re.M)
    th = re.findall(r"^PROBE a step threw: java\.lang\.AssertionError: (expected: 4 but was: (\d+))$", a, re.M)
    ok(len(w1) == 1 and len(th) == 1 and th[0][1] == w1[0] == o[PG]["r"][1][0], "plant 1: the assertion fails with the JDBC page's count, = three's (%s)" % th)
    ok("  exit 1 " in a and "PROBE <<< exit 1" in a, "plant 1: the JVM exits 1")
    w2 = re.findall(r"^PROBE witness window \(PostgreSQL 18\.6\): the witness (\d+) · Hibernate getPrepareStatementCount\(\) (\d+) · equal: (yes|NO)$", c, re.M)
    ok(len(w2) == 1 and w2[0][0] == "0" and w2[0][1] == o[PG]["r"][0][0] and w2[0][2] == "NO", "plant 2: the unwired witness 0 against Hibernate's %s, equal: NO (%s)" % (o[PG]["r"][0][0], w2))
    ok("PROBE S8.15: the witness and getPrepareStatementCount() disagree on the JPA window" in c and "  exit 1 " in c, "plant 2: S8.15's guard stops the JVM, exit 1")
    ok("JX=-Du06.unwired=true" in c, "plant 2: the switch named on its command line")
    done("the failure receipt (PostgreSQL 18.6): the JDBC page's count asserted == 4 -> java.lang.AssertionError: %s, exit 1; the witness unwired (-Du06.unwired=true, it skips prepareStatement) -> the witness %s · Hibernate getPrepareStatementCount() %s · equal: NO, exit 1 (S8.15)"
         % (th[0][0] if th else "?", w2[0][0] if w2 else "?", w2[0][1] if w2 else "?"))


# ---- seven ---------------------------------------------------------------------------------------------------------------------
if MODE == "seven":
    t = read(sys.argv[2]); want = sys.argv[3]
    m = re.search(r"exit (\d+) · the seven responses: (\d+) lines · md5 ([0-9a-f]{32}) · listening on 20450 now: 0$", t, re.M)
    ok(m is not None and m.group(1) == "0" and m.group(2) == "7", "the seven: 7 responses, TiffinBox exit 0 after POST /shutdown")
    ok(m is not None and m.group(3) == want, "the seven's md5 = Course 7's, read off ../c7-unit31/receipts.sh (%s)" % (m.group(3) if m else None))
    ok("listens on: 127.0.0.1:20450" in t and "its log: the token 0 times" in t, "loopback only; the token never in the log")
    done("the seven on anchor/ (H2): %s…, unchanged" % (m.group(3)[:8] if m else "?"))


# ---- exercise ------------------------------------------------------------------------------------------------------------------
def shellblock(t, sh, which):
    m = re.search(r"^in " + sh + r" - the " + which + r"'s lines \(the block's exit (\d+)\):\n((?:    .*\n?)*)", t, re.M)
    return (m.group(1), [l[4:] for l in m.group(2).rstrip("\n").split("\n")]) if m else ("?", [])


if MODE == "wib":
    t = read(sys.argv[2])
    print("\n".join(shellblock(t, "bash", "README" if sys.argv[3].endswith("README.md") else "solution")[1]))
    sys.exit(0)

if MODE == "exercise":
    t = read(sys.argv[2]); words = int(sys.argv[3]); o = three_of(read(sys.argv[4]))
    ok(words == 20, "the spoken line: %d words (the brief's 20)" % words)
    out = {}
    for sh in ("bash", "zsh"):
        for w in ("README", "solution"):
            e, ls = shellblock(t, sh, w)
            ok(e == "0" and "javac: exit 0" in ls and "docker run: exit 0" in ls and "docker rm -fv: exit 0" in ls, "%s, %s: the block ran - javac 0, its container started and removed with its volume" % (sh, w))
            ok("Ex06 on PostgreSQL: exit 0" in ls and "Ex06 on H2: exit 0" in ls, "%s, %s: both JVMs exit 0 (the check is the count, never the exit - R.196)" % (sh, w))
            out[(sh, w)] = ls
    ok(out[("bash", "README")] == out[("zsh", "README")] and out[("bash", "solution")] == out[("zsh", "solution")], "bash and zsh print the same")
    br, so = out[("bash", "README")], out[("bash", "solution")]
    pat = r"^EX (PostgreSQL 18\.6|H2 2\.5\.250): statements (\d+) · revenue (\d+) · paused days (\d+) · days by name (\d+) · name order = the JPA side's list: (yes|no)$"
    B = {m.group(1): m.groups()[1:] for m in (re.match(pat, x) for x in br) if m}
    S = {m.group(1): m.groups()[1:] for m in (re.match(pat, x) for x in so) if m}
    sq = [x for x in br + so if x.endswith("single-query loading true")]
    ok(len(sq) == 4, "single-query loading on in the copy - printed by each JVM off the mapping context (%d)" % len(sq))
    rv = o[PG]["r"][3]
    for nm, X in (("broken", B), ("solved", S)):
        ok(set(X) == {PG, H2}, "%s: a PostgreSQL line and an H2 line" % nm)
        for db in X:
            ok(X[db][1] == rv[0] and X[db][2] == rv[1] and X[db][3] == rv[2] and X[db][4] == "yes", "%s, %s: revenue, paused days and by-name = three's, the name order = the JPA side's" % (nm, db))
    jd = o[PG]["r"][1][0]
    ok(B.get(PG, ("?",))[0] == jd and B.get(H2, ("?",))[0] == o[H2]["r"][1][0], "broken: flag on, findAll(Sort.by(\"name\")) -> still the JDBC page's count on both databases (= three's %s)" % jd)
    ok(S.get(PG, ("?",))[0] == "3", "solved: flag on + findAll() sorted in Java -> 3 on PostgreSQL 18.6 (%s)" % str(S.get(PG)))
    ok(S.get(H2, ("?",))[0] == o[H2]["r"][1][0], "solved on H2: still the JDBC page's count - measured, said (%s)" % str(S.get(H2)))
    ok(any(x.startswith("EX PostgreSQL 18.6: done yes") for x in so) and any(x.startswith("EX PostgreSQL 18.6: done no") for x in br), "broken says no on PostgreSQL, solved says yes")
    ok(br != so, "R.196: broken and solved print differently")
    done("the exercise (%d words; a copy whose JdbcNames switches single-query loading on, never the anchor; its own container on 127.0.0.1:20452, then H2): broken - findAll(Sort.by(\"name\")) + the two sums -> PostgreSQL 18.6 %s statements, H2 2.5.250 %s; "
         "solved - findAll() sorted in Java + the two sums -> PostgreSQL 18.6 %s statements, H2 2.5.250 %s; revenue %s and paused days %s unchanged, the name order = the JPA side's list, on every run"
         % (words, B.get(PG, "?")[0], B.get(H2, "?")[0], S.get(PG, "?")[0], S.get(H2, "?")[0], rv[0], rv[1]))

print("FAIL no mode " + MODE)
sys.exit(1)
