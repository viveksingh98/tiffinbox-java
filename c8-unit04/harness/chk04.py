"""Unit 04's checks (python3 -I -B harness/chk04.py MODE CAPTURE [ARGS]). One mode per capture - client, custom, missing, unchecked,
seven, exercise - each reads the capture and asserts every number and string the video may say against another line of the SAME run
(the witness against JdbcTemplate's DEBUG log, the record against psql's row, the custom query's rows against psql's, the exception's
"actual" against the data line, one database against the other where the brief says both), never against a typed figure; it prints
VALUES - the values block's words - last. wib CAPTURE FILE prints what an exercise file's block printed, read off the capture. A
failed assertion prints FAIL and exits 1. Unit 03's chk03.py form."""
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
    jc = re.findall(r"^PROBE beans of JdbcClient \([^)]*\): (\d+) · (\S+)$", t, re.M)
    ok(len(jc) == len(v) and all(x == ("1", "org.springframework.jdbc.core.simple.DefaultJdbcClient") for x in jc), "%s: one JdbcClient bean in every JVM, DefaultJdbcClient" % where)
    return v[0] if v else ("?",) * 9


def blocks(t, label):
    """The lines of one block: from its '-- label' line to the next '-- ' line."""
    m = re.search(r"^-- " + re.escape(label) + r".*?$(.*?)(?=^-- |\Z)", t, re.M | re.S)
    return m.group(1) if m else ""


def data(b, db):
    j = re.findall(r"PROBE data \(" + re.escape(db) + r", JdbcTemplate\): customers (\d+) · pauses (\d+) · paused days (\d+)$", b, re.M)
    b0 = re.findall(r"PROBE before the seed \(" + re.escape(db) + r", JdbcTemplate\): customers (\d+) · pauses (\d+)$", b, re.M)
    ok(len(j) >= 1 and len(b0) == len(j), "%s: the data line built by the seed (before %s, after %s)" % (db, b0, j))
    ok(len(set(j)) <= 1, "%s: every seed in the block built the same data line" % db)
    if j and b0:
        ok(int(j[0][0]) == int(b0[0][0]) + 36 and int(j[0][1]) == int(b0[0][1]) + 36, "%s: the seed's 36 customers and 36 pauses on V2's rows" % db)
    return j[0] if j else ("?", "?", "?")


def psqldata(b, d):
    p = re.findall(r"psql \(a second client, PostgreSQL\): (\d+) customers · (\d+) pauses · (\d+) paused days$", b, re.M)
    ok(p == [d], "PostgreSQL: psql's data line = JdbcTemplate's: %s / %s" % (p, d))


def window(b, label, db, what):
    """One window: the witness's count and SELECTs, JdbcTemplate's DEBUG statement lines of the same window (equal), the SQL texts."""
    m = re.search(r"^PROBE " + re.escape(label) + r"[^\n]*" + re.escape(db) + r"\): the witness (\d+) · SELECT (\d+)$", b, re.M)
    ok(m is not None, "%s: the window %s printed its count" % (db, what))
    k = (int(m.group(1)), int(m.group(2))) if m else (-1, -1)
    lg = re.search(r"^  log " + re.escape(what) + r" \(" + re.escape(db.split()[0]) + r", JdbcTemplate DEBUG\): 'Executing prepared SQL statement' (\d+) · 'Executing SQL batch update' (\d+)$", b, re.M)
    ok(lg is not None, "%s: JdbcTemplate's DEBUG log of the window %s read" % (db, what))
    if lg:
        ok(int(lg.group(1)) == k[0] and lg.group(2) == "0", "%s, %s: the witness %d = JdbcTemplate's DEBUG statements %s, no batch (two witnesses, one window)" % (db, what, k[0], lg.group(1)))
    sql = re.findall(r"^PROBE " + re.escape(label) + r"[^\n]*" + re.escape(db) + r"\) SQL x(\d+): (.*)$", b, re.M)
    ok(sum(int(n) for n, _ in sql) == k[0], "%s, %s: the witness's SQL texts add up to its count" % (db, what))
    logq = re.findall(r"^  log " + re.escape(what) + r" x(\d+): Executing prepared SQL statement \[(.*)\]$", b, re.M)
    ok(sorted((q, int(n)) for n, q in logq) == sorted((q, int(n)) for n, q in sql), "%s, %s: JdbcTemplate's DEBUG text = the text the driver received (the witness)" % (db, what))
    return k, [q for _, q in sql]


def rec(row):
    """psql's or JdbcTemplate's 'name · meals · price · type' -> the record's toString, derived."""
    n, a, b, c = [x.strip() for x in row.split(" · ")]
    return "Customer[name=%s, mealsPerDay=%s, pricePerMeal=%s, mealType=%s]" % (n, a, b, c)


FORMS = [("client named", "client named (JdbcClient, :name, query(Customer.class).single()", ":name"),
         ("client positional", "client positional (JdbcClient, ?, query(Customer.class).single()", "?"),
         ("client lambda", "client lambda (JdbcClient, :name, a lambda RowMapper, single()", ":name"),
         ("client DataClassRowMapper", "client DataClassRowMapper (JdbcClient, :name, new DataClassRowMapper<>(Customer.class), single()", ":name"),
         ("template", "template (JdbcTemplate.queryForObject, ?, a lambda RowMapper - Course 2's shape, its own window", "?")]
SQLN = "select name, meals_per_day, price_per_meal, meal_type from customer where name = ?"


def clientdb(b, db, want):
    texts, out = set(), []
    for what, label, par in FORMS:
        k, sql = window(b, label, db, what)
        ok(k == (1, 1), "%s, %s (%s): 1 prepare, a SELECT (%s)" % (db, what, par, k))
        ok(len(sql) == 1 and ":name" not in sql[0] and sql[0].endswith("where name = ?"), "%s, %s (%s): the driver received `... where name = ?` - no :name at the driver (%s)" % (db, what, par, sql))
        texts.update(sql)
        r = re.findall(r"^PROBE " + re.escape(what) + r": (Customer\[[^]]*\])", b, re.M)
        ok(r == [want], "%s, %s: the record = the row read back by the second client (%s)" % (db, what, r))
        out.append(k)
    ok(len(texts) == 1, "%s: one text at the driver for the five calls (%d texts)" % (db, len(texts)))
    ok(texts == {SQLN} if texts else False, "%s: that text is the positional SQL string, byte for byte" % db)
    ok("PROBE client: the four records equal (equals): true · 4 records" in b, "%s: the four JdbcClient records equal" % db)
    ok(re.search(r"^PROBE template: Customer\[[^]]*\] · equal to the four: true$", b, re.M) is not None, "%s: JdbcTemplate's record equal to the four" % db)
    return out, (sorted(texts)[0] if texts else "?")


# ---- client --------------------------------------------------------------------------------------------------------------------
if MODE == "client":
    t = read(sys.argv[2])
    vs = versions(t, "client")
    bp = blocks(t, "PostgreSQL 18.6 (the container)")
    d = data(bp, PG); psqldata(bp, d)
    mr = re.findall(r"^  psql, Meera's row \(a second client, PostgreSQL\): (.*)$", bp, re.M)
    ok(len(mr) == 1, "PostgreSQL: psql read Meera's row before the hook")
    want = rec(mr[0]) if mr else "?"
    kp, tp = clientdb(bp, PG, want)
    bh = blocks(t, "H2 in memory")
    dh = data(bh, H2)
    ok(dh == d, "the data line equal on both databases (%s / %s)" % (dh, d))
    mh = re.findall(r"^PROBE Meera's row \(H2 2\.5\.250, JdbcTemplate\): (.*)$", bh, re.M)
    ok(mh == mr, "H2: JdbcTemplate's Meera row = psql's (%s / %s)" % (mh, mr))
    kh, th = clientdb(bh, H2, want)
    ok(kh == kp and th == tp, "H2: the same counts and the same text at the driver as PostgreSQL")
    done("PostgreSQL 18.6: JdbcClient.sql(\"... where name = :name\").param(\"name\", \"Meera\").query(Customer.class).single() -> %s (psql's row: %s); the driver received `%s` (the witness); "
         "the four JdbcClient forms (:name, ?, a lambda RowMapper, DataClassRowMapper) 1 prepare each, the records equal; JdbcTemplate.queryForObject (its own window) 1 prepare, equal; H2 2.5.250: the same counts, the same text; "
         "versions: Spring Boot %s · Spring Framework %s · Spring Data JDBC %s · Hibernate %s · datasource-proxy %s" % (want, mr[0] if mr else "?", tp, vs[0], vs[1], vs[3], vs[6], vs[8]))

# ---- custom --------------------------------------------------------------------------------------------------------------------
if MODE == "custom":
    t = read(sys.argv[2])
    versions(t, "custom")
    vals = []
    bp = blocks(t, "PostgreSQL 18.6, a fresh database u04q")
    d = data(bp, PG); psqldata(bp, d)
    ps = re.search(r"^  psql, the same SQL \(a second client, PostgreSQL\): rows (\d+) · the sum of paused_days (\d+)$", bp, re.M)
    ok(ps is not None, "PostgreSQL: psql ran the same SQL")
    for db, b in ((PG, bp), (H2, blocks(t, "H2 in memory"))):
        if db == H2:
            ok(data(b, H2) == d, "the data line equal on both databases")
        k, sql = window(b, "custom (JdbcClient, one SQL string, list()", db, "custom")
        ok(k == (1, 1), "%s: the custom query = 1 statement, a SELECT (%s)" % (db, k))
        ok(len(sql) == 1 and "left join pause p on p.customer_id = c.id group by c.name" in sql[0], "%s: the text the driver received is the one SQL string" % db)
        r = re.search(r"^PROBE custom: rows (\d+) · the sum of paused_days (\d+) · Meera (\S+) · Sunil (\S+)$", b, re.M)
        ok(r is not None, "%s: the rows and their sum printed" % db)
        if r and ps:
            ok(r.group(1) == d[0] and r.group(1) == ps.group(1), "%s: rows %s = the data line's customers %s = psql's rows %s (a customer with no pause is a row - the left join)" % (db, r.group(1), d[0], ps.group(1)))
            ok(r.group(2) == d[2] and r.group(2) == ps.group(2), "%s: the sum %s = the data line's paused days %s = psql's sum %s" % (db, r.group(2), d[2], ps.group(2)))
            vals.append("%s: 1 statement, %s rows, the sum of paused_days %s (= the data line's %s; %s)" % (db, r.group(1), r.group(2), d[2], "psql the second client" if db == PG else "JdbcTemplate's data line"))
    done("; ".join(vals) + "; the same question through the repositories is unit 06's count")

# ---- missing -------------------------------------------------------------------------------------------------------------------
EMPTY = "org.springframework.dao.EmptyResultDataAccessException: Incorrect result size: expected 1, actual 0"
if MODE == "missing":
    t = read(sys.argv[2])
    versions(t, "missing")
    res = {}
    for db, lab in ((PG, "PostgreSQL 18.6, a fresh database u04m"), (H2, "H2 in memory")):
        b = blocks(t, lab)
        d = data(b, db)
        if db == PG:
            psqldata(b, d)
        k, _ = window(b, "nobody (JdbcClient, \"Nobody\", single()", db, "nobody")
        ok(k == (1, 1), "%s: single() on Nobody = 1 prepare (%s)" % (db, k))
        th = re.findall(r"^PROBE a step threw \(" + re.escape(db) + r"\): (.*)$", b, re.M)
        ok(th == [EMPTY], "%s: single() on Nobody -> %s (%s)" % (db, EMPTY, th))
        ok(b.count("exit 1 · its log:") == 1 and "PROBE <<< exit 1" in b, "%s: that JVM exited 1" % db)
        ch = re.findall(r"^PROBE nobody: the class chain \(getSuperclass\(\)\): (.*)$", b, re.M)
        ok(len(ch) == 1 and " -> org.springframework.dao.DataAccessException -> " in ch[0] and " -> java.lang.RuntimeException -> " in ch[0], "%s: the class chain printed (DataAccessException, RuntimeException in it)" % db)
        for what, lab2, line, want in (("missing optional", "missing optional (JdbcClient, \"Nobody\", optional()", r"^PROBE missing optional: (.*)$", "Optional.empty"),
                                       ("missing list", "missing list (JdbcClient, \"Nobody\", list()", r"^PROBE missing list: (.*)$", "size 0")):
            kk, _ = window(b, lab2, db, what)
            got = re.findall(line, b, re.M)
            ok(kk == (1, 1) and got == [want], "%s: %s = 1 prepare, %s (%s)" % (db, what, want, got))
        km, _ = window(b, "missing many (JdbcClient, select name from customer, single()", db, "missing many")
        many = re.findall(r"^PROBE missing many: (org\.springframework\.dao\.\S+: .*)$", b, re.M)
        wm = "org.springframework.dao.IncorrectResultSizeDataAccessException: Incorrect result size: expected 1, actual %s" % d[0]
        ok(km == (1, 1) and many == [wm], "%s: single() on every name = 1 prepare, actual = the data line's %s customers (%s)" % (db, d[0], many))
        res[db] = (th, many, ch)
    ok(res[PG][0] == res[H2][0] and res[PG][1] == res[H2][1] and res[PG][2] == res[H2][2], "the texts and the class chain are the same on PostgreSQL and H2")
    p = res[PG]
    done("single() on Nobody -> %s (exit 1; PostgreSQL 18.6 and H2 2.5.250, the same text); optional() -> Optional.empty; list() -> size 0; single() on select name from customer -> %s; "
         "the class chain (getSuperclass(), printed): %s" % (p[0][0] if p[0] else "?", p[1][0] if p[1] else "?", p[2][0] if p[2] else "?"))

# ---- unchecked (RE-MEASURE 10) -------------------------------------------------------------------------------------------------
if MODE == "unchecked":
    t = read(sys.argv[2]); cl = read(sys.argv[3])
    versions(t, "unchecked")
    b = blocks(t, "PostgreSQL 18.6, a fresh database u04u")
    data(b, PG)
    cp = re.findall(r"^  psql, the copy row \(a second client, PostgreSQL\): (.*)$", b, re.M)
    m0 = re.findall(r"^  psql, Meera's row in public\.customer \(a second client, PostgreSQL\): (.*)$", b, re.M)
    m1 = re.findall(r"^  psql, Meera's row in public\.customer after \(a second client, PostgreSQL\): (.*)$", b, re.M)
    ok(len(cp) == 1 and len(m0) == 1 and m0 == m1, "psql: the copy row read; the anchor's Meera row the same before and after (%s / %s)" % (m0, m1))
    cmr = re.findall(r"^  psql, Meera's row \(a second client, PostgreSQL\): (.*)$", cl, re.M)
    ok(m0 == cmr, "the anchor's Meera row = capture client's psql row")
    if cp and m0:
        a, b0 = cp[0].split(" · "), m0[0].split(" · ")
        ok(a[0] == b0[0] and a[2:] == b0[2:] and a[1] != b0[1], "the copy row differs from Meera's in meals_per_day alone (%s / %s)" % (cp[0], m0[0]))
    k, sql = window(b, "unchecked (JdbcClient, u04x.customer, query(Customer.class).single()", PG, "unchecked")
    ok(k == (1, 1) and len(sql) == 1 and "from u04x.customer where name = ?" in sql[0], "the read = 1 prepare on u04x.customer (%s)" % (k,))
    jr = re.findall(r"^PROBE unchecked: the copy row read back by JdbcTemplate \(PostgreSQL 18\.6\): (\S+) · meals_per_day (\d+) · price_per_meal (\d+) · meal_type (\S+)$", b, re.M)
    want = rec(cp[0]) if cp else "?"
    r = re.findall(r"^PROBE unchecked: the record built: (Customer\[[^]]*\]) · mealsPerDay\(\) (-?\d+) · no exception$", b, re.M)
    ok(len(r) == 1 and r[0][0] == want, "the record built from the copy row = psql's copy row (%s)" % (r,))
    ok(len(r) == 1 and cp and r[0][1] == cp[0].split(" · ")[1] and jr and jr[0][1] == r[0][1], "mealsPerDay() = psql's and JdbcTemplate's meals_per_day (%s)" % (r[0][1] if r else None))
    ok("ConstraintViolation" not in b and "PROBE a step threw" not in b and "exit 0 · its log: ERROR lines 0" in b, "no ConstraintViolationException, no ERROR line, exit 0")
    vl = re.findall(r"^PROBE unchecked: the context's Validator \((\S+)\), asked afterwards by the harness: violations (\d+) · (.*)$", b, re.M)
    ok(len(vl) == 1 and vl[0][1] == "1" and vl[0][2].startswith("mealsPerDay: "), "the context's Validator, asked afterwards, names mealsPerDay (%s)" % (vl,))
    done("RE-MEASURE 10, PostgreSQL 18.6: a copy of Meera's row with meals_per_day %s (schema u04x, psql) -> query(Customer.class).single() builds %s, no exception, mealsPerDay() %s; "
         "the context's Validator (%s), asked afterwards by the harness: %s" % (cp[0].split(" · ")[1] if cp else "?", r[0][0] if r else "?", r[0][1] if r else "?", vl[0][0] if vl else "?", vl[0][2] if vl else "?"))

# ---- seven ---------------------------------------------------------------------------------------------------------------------
if MODE == "seven":
    t = read(sys.argv[2]); want = sys.argv[3]
    m = re.search(r"exit (\d+) · the seven responses: (\d+) lines · md5 ([0-9a-f]{32}) · listening on 20430 now: 0$", t, re.M)
    ok(m is not None and m.group(1) == "0" and m.group(2) == "7", "the seven: 7 responses, TiffinBox exit 0 after POST /shutdown")
    ok(m is not None and m.group(3) == want, "the seven's md5 = Course 7's, read off ../c7-unit31/receipts.sh (%s)" % (m.group(3) if m else None))
    ok("listens on: 127.0.0.1:20430" in t and "its log: the token 0 times" in t, "loopback only; the token never in the log")
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
    t = read(sys.argv[2]); words = int(sys.argv[3]); ms = read(sys.argv[4]); cl = read(sys.argv[5])
    ok(words == 20, "the spoken line: %d words (the brief's 20)" % words)
    out = {}
    for sh in ("bash", "zsh"):
        for w in ("README", "solution"):
            e, ls = shellblock(t, sh, w)
            ok(e == "0" and "javac: exit 0" in ls, "%s, %s: the block ran, javac exit 0" % (sh, w))
            out[(sh, w)] = ls
    ok(out[("bash", "README")] == out[("zsh", "README")] and out[("bash", "solution")] == out[("zsh", "solution")], "bash and zsh print the same")
    br, so = out[("bash", "README")], out[("bash", "solution")]
    ok("Ex04: exit 1" in br and "Ex04: exit 0" in so, "broken exits 1, solved exits 0")
    th = re.findall(r"^PROBE a step threw \((?:PostgreSQL 18\.6|H2 2\.5\.250)\): (.*)$", ms, re.M)
    bt = [x[len("EX lookup Nobody threw: "):] for x in br if x.startswith("EX lookup Nobody threw: ")]
    ok(len(th) == 2 and len(set(th)) == 1 and bt == th[:1], "broken: the exception's text = capture missing's, on H2 and on PostgreSQL (%s)" % bt)
    op = re.findall(r"^PROBE missing optional: (.*)$", ms, re.M)
    st = [x[len("EX lookup Nobody: "):] for x in so if x.startswith("EX lookup Nobody: ")]
    ok(len(op) == 2 and st == op[:1], "solved: the lookup prints capture missing's optional() line (%s)" % st)
    hk = re.findall(r"^PROBE client named: (Customer\[[^]]*\])$", cl, re.M)
    ml = [x for x in br + so if x.startswith("EX lookup Meera: ")]
    ok(len(ml) == 2 and all(x == "EX lookup Meera: " + hk[0] for x in ml) if hk else False, "Meera's lookup = capture client's record, in both blocks")
    ok(so[-1].startswith("EX done: yes") and br[-1].startswith("EX done: no"), "broken says no, solved says yes")
    ok(br != so, "R.196: broken and solved print differently")
    done("the exercise (%d words, H2 in memory, no Docker): broken - single() on Nobody -> %s, exit 1; solved - optional() -> %s, exit 0; Meera's lookup %s in both"
         % (words, bt[0] if bt else "?", st[0] if st else "?", hk[0] if hk else "?"))

print("FAIL no mode " + MODE)
sys.exit(1)
