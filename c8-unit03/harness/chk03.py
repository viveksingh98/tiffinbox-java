"""Unit 03's checks (python3 -I -B harness/chk03.py MODE CAPTURE [ARGS]). One mode per capture - reinsert, same, load, noid, ref,
seven, exercise - each reads the capture and asserts every number and string the video may say against another line of the SAME run
(the witness against JdbcTemplate's DEBUG log, psql against JdbcTemplate, the ids after against the ids before, the identity
sequence against the new id, the read against the data line, one database against the other where the brief says both), never
against a typed figure; it prints VALUES - the values block's words - last. wib CAPTURE FILE prints what an exercise file's block
printed, read off the capture. A failed assertion prints FAIL and exits 1."""
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


VERS = re.compile(r"PROBE versions: Spring Boot (\S+) · Spring Framework (\S+) · Spring Data JPA (\S+) · Spring Data JDBC (\S+) · Spring Data Relational (\S+)"
                  r" · Spring Data Commons (\S+) · Hibernate (\S+) · Flyway \(version.txt\) (\S+) · datasource-proxy \(pom.properties\) (\S+)$", re.M)
PG, H2 = "PostgreSQL 18.6", "H2 2.5.250"


def versions(t, where):
    v = VERS.findall(t)
    ok(len(v) > 0, "%s: every JVM printed its version line (%d)" % (where, len(v)))
    ok(len(set(v)) == 1, "%s: one version line across its JVMs" % where)
    ok(t.count("PROBE started: yes") == len(v), "%s: a version line in every JVM that started (%d of %d)" % (where, len(v), t.count("PROBE started: yes")))
    ok(t.count("log: HHH000001: Hibernate ORM core version ") == len(v), "%s: HHH000001 in every JVM's log" % where)
    ok(t.count("Found 1 JPA repository interface.") == len(v) and t.count("Found 1 JDBC repository interface.") == len(v), "%s: both modules' Found lines in every JVM (strict mode, S8.12)" % where)
    return v[0] if v else ("?",) * 9


def blocks(t, label):
    """The lines of one block: from its '-- label' line to the next '-- ' line."""
    m = re.search(r"^-- " + re.escape(label) + r".*?$(.*?)(?=^-- |\Z)", t, re.M | re.S)
    return m.group(1) if m else ""


def data(b, db):
    j = re.findall(r"PROBE data \(" + re.escape(db) + r", JdbcTemplate\): customers (\d+) · pauses (\d+) · paused days (\d+)$", b, re.M)
    b0 = re.findall(r"PROBE before the seed \(" + re.escape(db) + r", JdbcTemplate\): customers (\d+) · pauses (\d+)$", b, re.M)
    ok(len(j) == 1 and len(b0) == 1, "%s: the data line built by the seed, once (before %s, after %s)" % (db, b0, j))
    if j and b0:
        ok(int(j[0][0]) == int(b0[0][0]) + 36 and int(j[0][1]) == int(b0[0][1]) + 36, "%s: the seed's 36 customers and 36 pauses on V2's rows" % db)
    return j[0] if j else ("?", "?", "?")


def psqldata(b, d):
    p = re.findall(r"psql \(a second client, PostgreSQL\): (\d+) customers · (\d+) pauses · (\d+) paused days$", b, re.M)
    ok(p == [d], "PostgreSQL: psql's data line = JdbcTemplate's: %s / %s" % (p, d))


KINDS = r"the witness (\d+) · SELECT (\d+) · UPDATE (\d+) · DELETE (\d+) · INSERT with id (\d+) · INSERT without id (\d+)$"


def window(b, label, db, what):
    """One window's counts by the witness, and JdbcTemplate's DEBUG log of the same window: the statements equal."""
    m = re.search(r"^PROBE " + re.escape(label) + r"[^\n]*" + re.escape(db) + r"[^\n]*?\): " + KINDS, b, re.M)
    ok(m is not None, "%s: the window %s printed its counts" % (db, label))
    k = tuple(int(x) for x in m.groups()) if m else (-1,) * 6
    lg = re.search(r"^  log " + re.escape(what) + r" \(" + re.escape(db.split()[0]) + r", JdbcTemplate DEBUG\): 'Executing prepared SQL statement' (\d+) · 'Executing SQL batch update' (\d+)$", b, re.M)
    ok(lg is not None, "%s: JdbcTemplate's DEBUG log of the window %s read" % (db, what))
    if lg:
        ok(int(lg.group(1)) == k[0], "%s, %s: the witness %d = JdbcTemplate's DEBUG statements %s (two witnesses, one window)" % (db, what, k[0], lg.group(1)))
    ok(k[0] == sum(k[1:]), "%s, %s: every statement is a SELECT, UPDATE, DELETE or INSERT (%d = %d)" % (db, what, k[0], sum(k[1:])))
    sql = re.findall(r"^PROBE " + re.escape(label) + r"[^\n]*" + re.escape(db) + r"[^\n]*?\) SQL x(\d+): (.*)$", b, re.M)
    ok(sum(int(n) for n, _ in sql) == k[0], "%s, %s: the witness's SQL texts add up to its count" % (db, what))
    return k, dict((q, int(n)) for n, q in sql), (int(lg.group(2)) if lg else -1)


def ids(s):
    return [tuple(int(y) for y in x.split(":")) for x in s.split()] if s != "(none)" else []


# ---- reinsert ------------------------------------------------------------------------------------------------------------------
if MODE == "reinsert":
    t = read(sys.argv[2])
    versions(t, "reinsert")
    vals = []
    bp = blocks(t, "PostgreSQL 18.6 (the container)")
    d = data(bp, PG); psqldata(bp, d)
    k, sql, nb = window(bp, "reinsert (Spring Data JDBC save(), Sunil + one 1-day pause", PG, "reinsert")
    ok(k[1:] == (0, 1, 1, 1, 1), "PostgreSQL: the save = UPDATE 1 · DELETE 1 · INSERT with id 1 · INSERT without id 1, no SELECT (%s)" % (k,))
    ok("DELETE FROM pause WHERE pause.customer_id = ?" in sql, "PostgreSQL: the DELETE of every pause of the customer is in the witness's SQL")
    ok(nb == 1, "PostgreSQL: JdbcTemplate logs the INSERT with ids as a batch update (%d)" % nb)
    be = re.search(r"psql before \(a second client, PostgreSQL\): Sunil pauses ([0-9: ]+) · version (\d+) · pause identity \(pg_sequences, pause_id_seq\) last_value (\d+)$", bp, re.M)
    af = re.search(r"psql after \(a second client, PostgreSQL\): Sunil pauses ([0-9: ]+) · version (\d+) · pause identity \(pg_sequences, pause_id_seq\) last_value (\d+)$", bp, re.M)
    ok(be is not None and af is not None, "PostgreSQL: psql read Sunil's pauses, version and the identity before and after")
    if be and af:
        i0, i1 = ids(be.group(1)), ids(af.group(1))
        new = [x for x in i1 if x not in i0]
        ok(all(x in i1 for x in i0), "PostgreSQL: every pause id before is there after, with its days - the ids survive (%s -> %s)" % (be.group(1), af.group(1)))
        ok(len(new) == 1 and new[0][1] == 1 and len(i1) == len(i0) + 1, "PostgreSQL: one new row, a 1-day pause (%s)" % new)
        ok(int(af.group(3)) == int(be.group(3)) + 1, "PostgreSQL: the identity advanced by one (%s -> %s)" % (be.group(3), af.group(3)))
        ok(new and new[0][0] == int(af.group(3)), "PostgreSQL: the new pause's id = the identity's last_value after (%s)" % af.group(3))
        ok(int(af.group(2)) == int(be.group(2)) + 1, "PostgreSQL: version +1 by psql (%s -> %s)" % (be.group(2), af.group(2)))
        vals.append("PostgreSQL 18.6: save() of Sunil + one 1-day pause = %d statements (UPDATE, DELETE FROM pause WHERE pause.customer_id = ?, INSERT with id, INSERT without id; the with-id INSERT logged by JdbcTemplate as a batch update); "
                    "psql: pauses %s -> %s, version %s -> %s, pause identity last_value %s -> %s" % (k[0], be.group(1), af.group(1), be.group(2), af.group(2), be.group(3), af.group(3)))
    bh = blocks(t, "H2 in memory")
    dh = data(bh, H2)
    ok(dh == d, "the data line equal on both databases (%s / %s)" % (dh, d))
    kh, sqlh, nbh = window(bh, "reinsert (Spring Data JDBC save(), Sunil + one 1-day pause", H2, "reinsert")
    ok(kh == k, "H2: the same counts as PostgreSQL (%s / %s)" % (kh, k))
    rb = re.findall(r"PROBE read back by JdbcTemplate \(H2 2\.5\.250\): Sunil pauses ([0-9: ]+) · version (\d+)$", bh, re.M)
    ok(len(rb) == 2, "H2: JdbcTemplate read Sunil's pauses and version before and after")
    if len(rb) == 2:
        i0, i1 = ids(rb[0][0]), ids(rb[1][0])
        new = [x for x in i1 if x not in i0]
        ok(all(x in i1 for x in i0) and len(new) == 1 and new[0][1] == 1, "H2: the ids survive, one new 1-day pause (%s -> %s)" % (rb[0][0], rb[1][0]))
        ok(int(rb[1][1]) == int(rb[0][1]) + 1, "H2: version +1 by JdbcTemplate")
        if be and af:
            ok((rb[0][0], rb[1][0]) == (be.group(1), af.group(1)), "the same ids before and after on both databases")
        vals.append("H2 2.5.250: the same %d statements; JdbcTemplate: pauses %s -> %s, version %s -> %s" % (kh[0], rb[0][0], rb[1][0], rb[0][1], rb[1][1]))
    done("; ".join(vals))

# ---- same ----------------------------------------------------------------------------------------------------------------------
if MODE == "same":
    t = read(sys.argv[2])
    versions(t, "same")
    bp = blocks(t, "PostgreSQL 18.6, a fresh database u03m")
    d = data(bp, PG); psqldata(bp, d)
    ks, sqls, _ = window(bp, "same Sunil (Spring Data JDBC save(), Sunil unchanged", PG, "same Sunil")
    kr, sqlr, _ = window(bp, "same Ravi (Spring Data JDBC save(), Ravi unchanged - no pauses", PG, "same Ravi")
    ok(ks[1:] == (0, 1, 1, 1, 0), "PostgreSQL: Sunil unchanged = UPDATE 1 · DELETE 1 · INSERT with id 1 (%s)" % (ks,))
    ok(kr[1:] == (0, 1, 1, 0, 0), "PostgreSQL: Ravi unchanged, no pauses = UPDATE 1 · DELETE 1 (%s)" % (kr,))
    ok("DELETE FROM pause WHERE pause.customer_id = ?" in sqls and "DELETE FROM pause WHERE pause.customer_id = ?" in sqlr, "PostgreSQL: the DELETE is in the unchanged saves' SQL (no diff, ever)")
    R = r"Sunil pauses ([0-9: ]+) · version (\d+) · Ravi pauses ([^·]+) · version (\d+) · pause identity \(pg_sequences, pause_id_seq\) last_value (\d+)$"
    be = re.search(r"psql before \(a second client, PostgreSQL\): " + R, bp, re.M)
    af = re.search(r"psql after \(a second client, PostgreSQL\): " + R, bp, re.M)
    ok(be is not None and af is not None, "PostgreSQL: psql read both rows before and after")
    vals = []
    if be and af:
        ok(be.group(1) == af.group(1), "PostgreSQL: Sunil's pause ids unchanged (%s)" % af.group(1))
        ok(be.group(3).strip() == af.group(3).strip() == "(none)", "PostgreSQL: Ravi has no pauses before and after")
        ok(int(af.group(2)) == int(be.group(2)) + 1 and int(af.group(4)) == int(be.group(4)) + 1, "PostgreSQL: both versions +1 by psql")
        ok(be.group(5) == af.group(5), "PostgreSQL: the identity did not move (%s)" % af.group(5))
        vals.append("PostgreSQL 18.6: Sunil saved unchanged = %d statements (UPDATE, DELETE, INSERT with id); Ravi (no pauses) = %d (UPDATE, DELETE); psql: Sunil's pauses %s -> %s, "
                    "version %s -> %s; Ravi's version %s -> %s; the identity unchanged" % (ks[0], kr[0], be.group(1), af.group(1), be.group(2), af.group(2), be.group(4), af.group(4)))
    bh = blocks(t, "H2 in memory")
    ok(data(bh, H2) == d, "the data line equal on both databases")
    ksh, _, _ = window(bh, "same Sunil (Spring Data JDBC save(), Sunil unchanged", H2, "same Sunil")
    krh, _, _ = window(bh, "same Ravi (Spring Data JDBC save(), Ravi unchanged - no pauses", H2, "same Ravi")
    ok(ksh == ks and krh == kr, "H2: the same counts as PostgreSQL")
    rb = re.findall(r"PROBE read back by JdbcTemplate \(H2 2\.5\.250\): (Sunil|Ravi) pauses ([^·]+) · version (\d+)$", bh, re.M)
    ok(len(rb) == 4, "H2: JdbcTemplate read both rows before and after")
    if len(rb) == 4:
        ok(rb[0][1] == rb[2][1] and rb[1][1] == rb[3][1], "H2: the pause ids unchanged")
        ok(int(rb[2][2]) == int(rb[0][2]) + 1 and int(rb[3][2]) == int(rb[1][2]) + 1, "H2: both versions +1 by JdbcTemplate")
        vals.append("H2 2.5.250: the same %d and %d; JdbcTemplate: Sunil's pauses %s -> %s, version %s -> %s" % (ksh[0], krh[0], rb[0][1].strip(), rb[2][1].strip(), rb[0][2], rb[2][2]))
    done("; ".join(vals))

# ---- load ----------------------------------------------------------------------------------------------------------------------
if MODE == "load":
    t = read(sys.argv[2])
    versions(t, "load")
    W = [("load findById(Sunil)", "load findById", "findById"), ("load findAll()", "load findAll()", "findAll()"),
         ("load findAll(Sort.by(\"name\"))", "load findAll(Sort)", "findAll(Sort.by(\"name\"))"), ("load findAllById(", "load findAllById", "findAllById")]
    res = {}
    d0 = None
    for lab, db, sq in (("PostgreSQL 18.6, a fresh database u03l", PG, "false"), ("PostgreSQL, the same database, a second JVM", PG, "true"),
                        ("H2 in memory, single-query loading off", H2, "false"), ("H2 in memory, a second JVM", H2, "true")):
        b = blocks(t, lab)
        ok(("PROBE single-query loading (%s, the mapping context's isSingleQueryLoadingEnabled()): %s" % (db, sq)) in b, "%s: the flag printed by the mapping context: %s" % (lab, sq))
        if "data (" in b:
            dd = data(b, db)
            d0 = d0 or dd
            ok(dd == d0, "%s: the data line = the first block's" % lab)
        if db == PG and sq == "false":
            psqldata(b, d0)
        agg = re.search(r"PROBE load findAll\(\): aggregates (\d+) · pauses in them (\d+)$", b, re.M)
        ok(agg is not None and d0 is not None and agg.groups() == d0[:2], "%s: findAll() read the data line's customers and pauses (%s)" % (lab, agg.groups() if agg else None))
        for label, what, name in W:
            k, sql, _ = window(b, label, db, what)
            ok(k[0] == k[1], "%s, %s: every statement a SELECT" % (lab, name))
            res[(db, sq, name)] = k[0]
            if name != "findById" and agg:
                per = sum(n for q, n in sql.items() if re.match(r"(?i)SELECT .* FROM pause WHERE pause\.customer_id = \?$", q))
                ok(k[0] in (1, 1 + per) and (k[0] == 1 or per == int(agg.group(1))), "%s, %s: %d = 1, or 1 + one pause SELECT per aggregate (%d)" % (lab, name, k[0], per))
    for db in (PG, H2):
        ok(res[(db, "false", "findAll()")] == int(d0[0]) + 1, "%s, the default: findAll() = 1 + N, N = the data line's customers (%d)" % (db, res[(db, "false", "findAll()")]))
        ok(res[(db, "false", "findById")] == 2, "%s, the default: findById = the customer's SELECT + its pauses' SELECT" % db)
    ok(res[(PG, "true", "findAll(Sort.by(\"name\"))")] == res[(PG, "false", "findAll(Sort.by(\"name\"))")], "PostgreSQL: findAll(Sort) unchanged by the flag")
    ok(all(res[(H2, "true", n)] == res[(H2, "false", n)] for _, _, n in W), "H2: every read unchanged by the flag")
    f = lambda db, sq: " · ".join("%s %d" % (n, res[(db, sq, n)]) for _, _, n in W)
    done("single-query loading off (the anchor's): PostgreSQL 18.6 %s; H2 2.5.250 %s - single-query loading on (the harness's SingleQuery, never the anchor): PostgreSQL 18.6 %s; H2 2.5.250 %s"
         % (f(PG, "false"), f(H2, "false"), f(PG, "true"), f(H2, "true")))

# ---- noid ----------------------------------------------------------------------------------------------------------------------
if MODE == "noid":
    t = read(sys.argv[2])
    versions(t, "noid")
    e = re.findall(r"^  ([<>]) (.*)$", blocks(t, "noid: a COPY"), re.M)
    ok(e == [("<", '    @MappedCollection(idColumn = "customer_id")'), (">", "    @MappedCollection")], "the copy differs from anchor/ by its one edited line (%s)" % e)
    vals = []
    for db, cl, cpy, anc in ((H2, "H2", "H2 in memory, the noid copy", "H2 in memory, anchor/"), (PG, "PostgreSQL", "PostgreSQL 18.6, a fresh database u03n, the noid copy", "PostgreSQL, the same database, anchor/")):
        b = blocks(t, cpy)
        data(b, db)
        m = re.search(r"^PROBE read findAll\(\) \(" + re.escape(db) + r"\): org\.springframework\.jdbc\.BadSqlGrammarException <- (\S+): (.*)$", b, re.M)
        ok(m is not None, "%s, the copy: findAll() refused - BadSqlGrammarException and its cause" % cl)
        ok("PROBE <<< exit 1" in b and "  exit 1 · " in b, "%s, the copy: the JVM exit 1" % cl)
        k, sql, _ = window(b, "read findAll()", db, "read findAll()")
        bad = [q for q in sql if re.search(r"(?i)FROM pause WHERE pause\.customer = \?$", q)]
        ok(len(bad) == 1, "%s, the copy: the pause SELECT names the column customer (the parent's table) - %s" % (cl, bad))
        a = blocks(t, anc)
        ma = re.search(r"^PROBE read findAll\(\) \(" + re.escape(db) + r"\): aggregates (\d+)$", a, re.M)
        ok(ma is not None and "PROBE <<< exit 0" in a, "%s, anchor/ (idColumn = \"customer_id\"): findAll() reads, exit 0" % cl)
        ok(ma is not None and re.search(r"SQL x" + ma.group(1) + r": SELECT pause\.\S+ AS \S+, pause\.\S+ AS \S+ FROM pause WHERE pause\.customer_id = \?$", a, re.M) is not None,
           "%s, anchor/: one pause SELECT per aggregate, by customer_id" % cl)
        if m:
            vals.append("%s: the copy without idColumn - findAll() -> %s: %s (SQL ... WHERE pause.%s = ?), exit 1; anchor/ with idColumn = \"customer_id\" reads %s aggregates"
                        % (db, m.group(1), m.group(2), "CUSTOMER" if db == H2 else "customer", ma.group(1) if ma else "?"))
    hm = re.search(r'Column "PAUSE\.CUSTOMER" not found', t)
    ok(hm is not None, "H2: the error text is the probe's - Column \"PAUSE.CUSTOMER\" not found (re-read, never typed into the capture)")
    done("; ".join(vals))

# ---- ref -----------------------------------------------------------------------------------------------------------------------
if MODE == "ref":
    t = read(sys.argv[2])
    versions(t, "ref")
    vals = []
    for db, lab in ((H2, "H2 in memory, one JVM - PauseRef"), (PG, "PostgreSQL 18.6, a fresh database u03f")):
        b = blocks(t, lab)
        data(b, db)
        m = re.search(r"^PROBE ref findById \(JdbcAggregateTemplate, PauseRef, " + re.escape(db) + r"\): " + KINDS, b, re.M)
        ok(m is not None and int(m.group(1)) == 1 and int(m.group(2)) == 1, "%s: the PauseRef read is one SELECT - no customer read with it" % db)
        sq = re.findall(r"^PROBE ref findById \([^)]*\) SQL x1: (.*)$", b, re.M)
        ok(len(sq) == 1 and "customer_id" in sq[0].lower() and "FROM pause WHERE" in sq[0] and "customer." not in sq[0].lower(), "%s: its SQL reads pause's customer_id, never the customer table" % db)
        r = re.search(r"^PROBE ref: PauseRef (\d+) · days (\d+) · customerId (\S+) getId\(\) (\d+) · Sunil's id \(JdbcTemplate\) (\d+) · equal: yes · the PauseRef holds a CustomerRow: no$", b, re.M)
        ok(r is not None, "%s: the reference holds Sunil's id (= JdbcTemplate's), no CustomerRow" % db)
        ins = re.search(r"^PROBE ref insert \(JdbcAggregateTemplate, a new PauseRef for Ravi, " + re.escape(db) + r"\): " + KINDS, b, re.M)
        ok(ins is not None and int(ins.group(1)) == 1 and int(ins.group(6)) == 1, "%s: the insert is one INSERT" % db)
        ok(re.search(r"^PROBE ref: the new pause read back by JdbcTemplate \(" + re.escape(db) + r"\): customer_id = Ravi's id: yes · days 2$", b, re.M) is not None, "%s: the new row read back by JdbcTemplate: Ravi's id" % db)
        if db == PG:
            ok("psql (a second client, PostgreSQL): the newest pause row: Ravi · days 2 · customer_id = Ravi's id: yes" in b, "PostgreSQL: the new row read back by psql: Ravi's")
        if r:
            vals.append("%s: AggregateReference<CustomerRow, Long> on a sketch class (PauseRef, never the anchor) - a read = 1 SELECT of pause alone, getId() = Sunil's id by JdbcTemplate, no CustomerRow held; "
                        "an insert = 1 INSERT, its customer_id = Ravi's id by %s" % (db, "JdbcTemplate and psql" if db == PG else "JdbcTemplate"))
    done("; ".join(vals))

# ---- seven ---------------------------------------------------------------------------------------------------------------------
if MODE == "seven":
    t = read(sys.argv[2]); want = sys.argv[3]
    m = re.search(r"exit (\d+) · the seven responses: (\d+) lines · md5 ([0-9a-f]{32}) · listening on 20420 now: 0$", t, re.M)
    ok(m is not None and m.group(1) == "0" and m.group(2) == "7", "the seven: 7 responses, TiffinBox exit 0 after POST /shutdown")
    ok(m is not None and m.group(3) == want, "the seven's md5 = Course 7's, read off ../c7-unit31/receipts.sh (%s)" % (m.group(3) if m else None))
    ok("listens on: 127.0.0.1:20420" in t and "its log: the token 0 times" in t, "loopback only; the token never in the log")
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
    t = read(sys.argv[2]); words = int(sys.argv[3]); same = read(sys.argv[4])
    ok(words == 23, "the spoken line: %d words (the brief's 23)" % words)
    out = {}
    for sh in ("bash", "zsh"):
        for w in ("README", "solution"):
            e, ls = shellblock(t, sh, w)
            ok(e == "0" and "javac: exit 0" in ls and "Ex03: exit 0" in ls, "%s, %s: the block ran, javac and Ex03 exit 0" % (sh, w))
            out[(sh, w)] = ls
    ok(out[("bash", "README")] == out[("zsh", "README")] and out[("bash", "solution")] == out[("zsh", "solution")], "bash and zsh print the same")
    def cnt(ls):
        c = [int(x.split(": ")[1]) for x in ls if x.startswith("EX statement count: ")]
        return c[0] if c else -1
    st = [x for x in out[("bash", "solution")] if x.startswith("EX statement: ")]
    b, s = cnt(out[("bash", "README")]), cnt(out[("bash", "solution")])
    ok(b == sum(1 for x in st if x.startswith("EX statement: SELECT")), "broken: the count is the SELECTs among the statements (%d)" % b)
    ok(s == len(st), "solved: the count = the statements listed (%d)" % s)
    ok(b != s, "R.196: broken and solved print different counts (%d / %d)" % (b, s))
    ok(out[("bash", "solution")][-1].startswith("EX done: yes") and out[("bash", "README")][-1].startswith("EX done: no"), "broken says no, solved says yes")
    hs = re.search(r"^PROBE same Sunil \(Spring Data JDBC save\(\), Sunil unchanged, H2 2\.5\.250\): the witness (\d+) ", same, re.M)
    ok(hs is not None and int(hs.group(1)) == s, "the solved count = capture same's H2 window for the same save (%s)" % (hs.group(1) if hs else None))
    hsq = sorted(re.findall(r"^PROBE same Sunil \(Spring Data JDBC save\(\), Sunil unchanged, H2 2\.5\.250\) SQL x1: (.*)$", same, re.M))
    ok(hsq == [x[len("EX statement: "):] for x in st], "the solved statements = capture same's H2 SQL texts, sorted")
    ids = [x for x in out[("bash", "solution")] if "Sunil pauses" in x]
    ok(len(ids) == 2 and ids[0].split(" · ")[0].split(": ")[1] == ids[1].split(" · ")[0].split(": ")[1], "the pause ids by JdbcTemplate unchanged across the save")
    done("the exercise (%d words, H2 in memory, no Docker): broken - counts SELECTs only, prints %d; solved - every statement the witness kept, %d (UPDATE, DELETE, INSERT with id), = capture same's H2 window; "
         "Sunil's pause ids unchanged by JdbcTemplate" % (words, b, s))

print("FAIL no mode " + MODE)
sys.exit(1)
