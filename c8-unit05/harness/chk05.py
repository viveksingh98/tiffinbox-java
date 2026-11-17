"""Unit 05's checks (python3 -I -B harness/chk05.py MODE CAPTURE [ARGS]). One mode per capture - template, named, four, beans,
missing, seven, exercise - each reads the capture and asserts every number and string the video may say against another line of the
SAME run (the witness against JdbcTemplate's DEBUG log, the record against psql's row, the list's size against psql's count, the
rows affected against psql's row after, the bean count against the bean lines, one database against the other where the brief says
both), never against a typed figure; it prints VALUES - the values block's words - last. wib CAPTURE FILE prints what an exercise
file's block printed, read off the capture. A failed assertion prints FAIL and exits 1. Unit 04's chk04.py form."""
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
TYPES = ("JdbcTemplate", "NamedParameterJdbcTemplate", "JdbcClient", "DataSource")


def versions(t, where):
    v = VERS.findall(t)
    ok(len(v) > 0, "%s: every JVM printed its version line (%d)" % (where, len(v)))
    ok(len(set(v)) == 1, "%s: one version line across its JVMs" % where)
    ok(t.count("PROBE started: yes") == len(v), "%s: a version line in every JVM that started (%d of %d)" % (where, len(v), t.count("PROBE started: yes")))
    ok(t.count("log: HHH000001: Hibernate ORM core version ") == len(v), "%s: HHH000001 in every JVM's log" % where)
    ok(t.count("Found 1 JPA repository interface.") == len(v) and t.count("Found 1 JDBC repository interface.") == len(v), "%s: both modules' Found lines in every JVM (strict mode, S8.12)" % where)
    for ty in TYPES:
        b = re.findall(r"^PROBE beans of " + ty + r" \([^)]*\): (\d+) · (.+)$", t, re.M)
        ok(len(b) == len(v) and len(set(b)) == 1, "%s: every JVM printed its beans of %s line, the same in each (%s)" % (where, ty, sorted(set(b))))
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
    """One window: the witness's count and SELECTs, JdbcTemplate's DEBUG statement lines of the same window (equal), the SQL texts.
    A plain Statement (queryForObject with no argument) shows at the witness as (createStatement) and in the log as 'Executing SQL query'."""
    m = re.search(r"^PROBE " + re.escape(label) + r"[^\n]*" + re.escape(db) + r"\): the witness (\d+) · SELECT (\d+)$", b, re.M)
    ok(m is not None, "%s: the window %s printed its count" % (db, what))
    k = (int(m.group(1)), int(m.group(2))) if m else (-1, -1)
    lg = re.search(r"^  log " + re.escape(what) + r" \(" + re.escape(db.split()[0]) + r", JdbcTemplate DEBUG\): 'Executing prepared SQL statement' (\d+) · 'Executing SQL query' (\d+) · 'Executing SQL batch update' (\d+)$", b, re.M)
    ok(lg is not None, "%s: JdbcTemplate's DEBUG log of the window %s read" % (db, what))
    if lg:
        ok(int(lg.group(1)) + int(lg.group(2)) == k[0] and lg.group(3) == "0", "%s, %s: the witness %d = JdbcTemplate's DEBUG statements %s + %s, no batch (two witnesses, one window)" % (db, what, k[0], lg.group(1), lg.group(2)))
    sql = re.findall(r"^PROBE " + re.escape(label) + r"[^\n]*" + re.escape(db) + r"\) SQL x(\d+): (.*)$", b, re.M)
    ok(sum(int(n) for n, _ in sql) == k[0], "%s, %s: the witness's SQL texts add up to its count" % (db, what))
    logq = re.findall(r"^  log " + re.escape(what) + r" x(\d+): Executing prepared SQL statement \[(.*)\]$", b, re.M)
    ok(sorted((q, int(n)) for n, q in logq) == sorted((q, int(n)) for n, q in sql if q != "(createStatement)"), "%s, %s: JdbcTemplate's DEBUG text = the text the driver received (the witness)" % (db, what))
    plain = re.findall(r"^  log " + re.escape(what) + r" x(\d+): Executing SQL query \[(.*)\]$", b, re.M)
    ok(sum(int(n) for n, _ in plain) == sum(int(n) for n, q in sql if q == "(createStatement)"), "%s, %s: each (createStatement) at the witness is an 'Executing SQL query' line in the log" % (db, what))
    return k, [q for _, q in sql] + [q for _, q in plain]


def rec(row):
    """psql's or JdbcTemplate's 'name · meals · price · type' -> the record's toString, derived."""
    n, a, b, c = [x.strip() for x in row.split(" · ")]
    return "Customer[name=%s, mealsPerDay=%s, pricePerMeal=%s, mealType=%s]" % (n, a, b, c)


def meera(b):
    mr = re.findall(r"^  psql, Meera's row \(a second client, PostgreSQL\): (.*)$", b, re.M)
    ok(len(mr) == 1, "PostgreSQL: psql read Meera's row before the calls")
    return mr[0] if mr else "?"


def h2meera(b, mr):
    mh = re.findall(r"^PROBE Meera's row \(H2 2\.5\.250, JdbcTemplate\): (.*)$", b, re.M)
    ok(len(mh) >= 1 and set(mh) == {mr}, "H2: JdbcTemplate's Meera row = psql's (%s / %s)" % (mh, mr))


def got(b, what):
    return re.findall(r"^PROBE " + re.escape(what) + r": (.*)$", b, re.M)


def threw(b, what):
    return re.findall(r"^PROBE " + re.escape(what) + r" threw: (.*)$", b, re.M)


def cause(b, what):
    return re.findall(r"^PROBE " + re.escape(what) + r" its cause: (.*)$", b, re.M)


SQLN = "select name, meals_per_day, price_per_meal, meal_type from customer where name = ?"

# ---- template ------------------------------------------------------------------------------------------------------------------
if MODE == "template":
    t = read(sys.argv[2])
    vs = versions(t, "template")
    res = {}
    bp = blocks(t, "PostgreSQL 18.6 (the container)")
    d = data(bp, PG); psqldata(bp, d)
    mr = meera(bp); want = rec(mr)
    ab = re.findall(r"^  psql, Asha's row before the harness \(a second client, PostgreSQL\): (.*)$", bp, re.M)
    aa = re.findall(r"^  psql, Asha's row after the harness \(a second client, PostgreSQL\): (.*)$", bp, re.M)
    ad = re.findall(r"^  psql, Asha's rows after the delete \(a second client, PostgreSQL\): (\d+)$", bp, re.M)
    veg = re.findall(r"^  psql, the VEG customers \(a second client, PostgreSQL\): (\d+)$", bp, re.M)
    ok(len(ab) == 1 and len(aa) == 1 and ad == ["0"] and len(veg) == 1, "PostgreSQL: psql wrote Asha's row, read it before and after the harness, deleted it (0 left), counted the VEG customers")
    bh = blocks(t, "H2 in memory")
    dh = data(bh, H2)
    ok(dh == d, "the data line equal on both databases (%s / %s)" % (dh, d))
    h2meera(bh, mr)
    hab = re.findall(r"^PROBE asha: inserted by the harness's JdbcTemplate \(H2 2\.5\.250\), outside any window: 1 row · (.*)$", bh, re.M)
    ok(hab == ab, "H2: the harness's Asha row = psql's Asha row on PostgreSQL (%s / %s)" % (hab, ab))
    hdrop = re.findall(r"^PROBE ashadrop: deleted by the harness's JdbcTemplate \(H2 2\.5\.250\), outside any window: 1 row · Asha's row now: \(no row\)$", bh, re.M)
    ok(len(hdrop) == 1, "H2: Asha deleted again by the harness's JdbcTemplate (no row)")
    for db, b in ((PG, bp), (H2, bh)):
        bean = re.findall(r"^PROBE template: the context's JdbcTemplate bean \(" + re.escape(db) + r"\): (\S+) · (\S+)$", b, re.M)
        ok(len(bean) == 1 and bean[0][1] == "org.springframework.jdbc.core.JdbcTemplate", "%s: the calls go through the context's JdbcTemplate bean (%s)" % (db, bean))
        k1, s1 = window(b, "template queryForObject (JdbcTemplate, ?, a lambda RowMapper, \"Meera\"", db, "template queryForObject")
        ok(k1 == (1, 1) and s1 == [SQLN], "%s: queryForObject = 1 prepare, a SELECT, the driver received `... where name = ?` (%s %s)" % (db, k1, s1))
        r1 = got(b, "template queryForObject")
        ok(r1 == [want], "%s: queryForObject's record = psql's Meera row (%s)" % (db, r1))
        k2, s2 = window(b, "template query (JdbcTemplate, ?, a lambda RowMapper, \"VEG\"", db, "template query")
        ok(k2 == (1, 1) and len(s2) == 1 and s2[0].endswith("where meal_type = ? order by name"), "%s: query = 1 prepare, a SELECT, `... where meal_type = ? order by name` at the driver" % db)
        sz = re.findall(r"^PROBE template query: a list, size (\d+)$", b, re.M)
        cnt = veg if db == PG else re.findall(r"^PROBE template: VEG customers by count\(\*\) \(H2 2\.5\.250, the harness's JdbcTemplate, outside the windows\): (\d+)$", b, re.M)
        ok(len(sz) == 1 and sz == cnt, "%s: query's list size %s = the VEG customers counted by %s %s" % (db, sz, "psql" if db == PG else "the harness's JdbcTemplate", cnt))
        k3, s3 = window(b, "template update (JdbcTemplate, update customer set meals_per_day = ? where name = ?, 3, \"Asha\"", db, "template update")
        ok(k3 == (1, 0) and s3 == ["update customer set meals_per_day = ? where name = ?"], "%s: update = 1 prepare, no SELECT, `update customer set meals_per_day = ? where name = ?` at the driver (%s)" % (db, k3))
        n = got(b, "template update")
        bf = re.findall(r"^PROBE template: Asha's row before the update \(" + re.escape(db) + r", the harness's JdbcTemplate\): (.*)$", b, re.M)
        af = re.findall(r"^PROBE template: Asha's row after the update \(" + re.escape(db) + r", the harness's JdbcTemplate\): (.*)$", b, re.M)
        if db == PG:
            ok(bf == ab and af == aa, "PostgreSQL: the harness's read-backs of Asha = psql's, before and after (%s %s / %s %s)" % (bf, af, ab, aa))
        ok(len(bf) == 1 and len(af) == 1 and bf[0].split(" · ")[1] != af[0].split(" · ")[1] and bf[0].split(" · ")[0::2] == af[0].split(" · ")[0::2] and af[0].split(" · ")[1] == "3",
           "%s: Asha's meals_per_day moved to the update's value, the rest unchanged (%s -> %s)" % (db, bf, af))
        ok(n == ["1"] and len(af) == 1 and af[0].count(" | ") == 0, "%s: update's rows affected %s = the one Asha row the second client reads after" % (db, n))
        res[db] = (k1, k2, k3, r1, sz, n)
    ok(res[PG][:3] == res[H2][:3] and res[PG][3:] == res[H2][3:], "the counts, the record, the list size and the rows affected are the same on PostgreSQL and H2")
    p = res[PG]
    done("PostgreSQL 18.6: the context's JdbcTemplate - queryForObject(sql, rowMapper, \"Meera\") with ? -> %s (psql's row: %s), 1 prepare; query(sql, rowMapper, \"VEG\") -> a list, size %s (= psql's count of VEG customers), 1 prepare; "
         "update(\"update customer set meals_per_day = ? where name = ?\", 3, \"Asha\") on the harness's own row -> %s row affected (Asha by psql: %s -> %s; deleted after), 1 prepare; H2 2.5.250: the same; "
         "versions: Spring Boot %s · Spring Framework %s · Spring Data JDBC %s · Hibernate %s · datasource-proxy %s"
         % (p[3][0] if p[3] else "?", mr, p[4][0] if p[4] else "?", p[5][0] if p[5] else "?", ab[0] if ab else "?", aa[0] if aa else "?", vs[0], vs[1], vs[3], vs[6], vs[8]))

# ---- named ---------------------------------------------------------------------------------------------------------------------
if MODE == "named":
    t = read(sys.argv[2])
    versions(t, "named")
    bp = blocks(t, "PostgreSQL 18.6 (the container)")
    d = data(bp, PG); psqldata(bp, d)
    mr = meera(bp); want = rec(mr)
    bh = blocks(t, "H2 in memory")
    ok(data(bh, H2) == d, "the data line equal on both databases")
    h2meera(bh, mr)
    res = {}
    for db, b in ((PG, bp), (H2, bh)):
        bean = re.findall(r"^PROBE named: the context's NamedParameterJdbcTemplate bean \(" + re.escape(db) + r"\): (\S+) · (\S+)$", b, re.M)
        ok(len(bean) == 1 and bean[0][1] == "org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate", "%s: the calls go through the context's NamedParameterJdbcTemplate bean" % db)
        out = []
        for what, label in (("named Map", "named Map (NamedParameterJdbcTemplate, :name, Map.of(\"name\", \"Meera\"), new DataClassRowMapper<>(Customer.class)"),
                            ("named MapSqlParameterSource", "named MapSqlParameterSource (NamedParameterJdbcTemplate, :name, new MapSqlParameterSource(\"name\", \"Meera\"), new DataClassRowMapper<>(Customer.class)")):
            k, s = window(b, label, db, what)
            ok(k == (1, 1), "%s, %s: 1 prepare, a SELECT (%s)" % (db, what, k))
            ok(s == [SQLN], "%s, %s: the driver received `... where name = ?` - the :name rewritten before it (%s)" % (db, what, s))
            r = got(b, what)
            ok(r == [want], "%s, %s: the record = psql's Meera row (%s)" % (db, what, r))
            out.append((k, s, r))
        ok("PROBE named: the two records equal (equals): true" in b, "%s: the two records equal" % db)
        res[db] = out
    ok(res[PG] == res[H2], "the counts, the text at the driver and the records are the same on PostgreSQL and H2")
    done("PostgreSQL 18.6: the context's NamedParameterJdbcTemplate - queryForObject(\"... where name = :name\", Map.of(\"name\", \"Meera\"), new DataClassRowMapper<>(Customer.class)) -> %s, 1 prepare, "
         "the driver received `%s` (the witness: the :name rewritten to ?); the same with new MapSqlParameterSource(\"name\", \"Meera\"): 1 prepare, the same text, equal; H2 2.5.250: the same"
         % (want, SQLN))

# ---- four ----------------------------------------------------------------------------------------------------------------------
FOUR = [("four JdbcTemplate", "four JdbcTemplate (JdbcTemplate.queryForObject, ?, a lambda RowMapper", "?"),
        ("four NamedParameterJdbcTemplate", "four NamedParameterJdbcTemplate (NamedParameterJdbcTemplate.queryForObject, :name, Map.of, new DataClassRowMapper<>(Customer.class)", ":name"),
        ("four JdbcClient named", "four JdbcClient named (JdbcClient, :name, .param(\"name\", \"Meera\"), query(Customer.class).single()", ":name"),
        ("four JdbcClient positional", "four JdbcClient positional (JdbcClient, ?, .param(\"Meera\"), query(a lambda RowMapper).single()", "?")]
if MODE == "four":
    t = read(sys.argv[2])
    versions(t, "four")
    bp = blocks(t, "PostgreSQL 18.6 (the container)")
    d = data(bp, PG); psqldata(bp, d)
    mr = meera(bp); want = rec(mr)
    bh = blocks(t, "H2 in memory")
    ok(data(bh, H2) == d, "the data line equal on both databases")
    h2meera(bh, mr)
    res = {}
    for db, b in ((PG, bp), (H2, bh)):
        texts, ks = set(), []
        for what, label, par in FOUR:
            k, s = window(b, label, db, what)
            ok(k == (1, 1), "%s, %s (%s): 1 prepare, a SELECT (%s)" % (db, what, par, k))
            ok(len(s) == 1 and ":name" not in s[0], "%s, %s (%s): no :name at the driver (%s)" % (db, what, par, s))
            texts.update(s); ks.append(k)
            r = got(b, what)
            ok(r == [want], "%s, %s: the record = psql's Meera row (%s)" % (db, what, r))
        ok(texts == {SQLN}, "%s: one text at the driver across the four windows, the positional SQL string byte for byte (%s)" % (db, sorted(texts)))
        ok("PROBE four: all four equal: true · 4 records" in b, "%s: all four equal: true (equals on the records)" % db)
        dd = re.findall(r"^PROBE four: the texts the driver received, across the four windows: (\d+) · distinct (\d+)$", b, re.M)
        ok(dd == [("4", "1")], "%s: the harness's own tally - four texts, one distinct (%s)" % (db, dd))
        res[db] = (ks, sorted(texts))
    ok(res[PG] == res[H2], "H2: the same counts and the same text at the driver as PostgreSQL")
    done("PostgreSQL 18.6 (the hook): the same query four ways - JdbcTemplate (?), NamedParameterJdbcTemplate (:name), JdbcClient (:name), JdbcClient (?) - four calls, 1 prepare each, "
         "one text at the driver: `%s` (the witness, four windows); the records = psql's row %s; all four equal: true; H2 2.5.250: the same counts, the same text, all four equal: true" % (SQLN, want))

# ---- beans (RE-MEASURE 11, RED #11) -------------------------------------------------------------------------------------------
if MODE == "beans":
    t = read(sys.argv[2])
    versions(t, "beans")
    res = {}
    for db, lab in ((PG, "PostgreSQL 18.6 (the container)"), (H2, "H2 in memory")):
        b = blocks(t, lab)
        cnt = {}
        for ty in TYPES:
            c = re.findall(r"^PROBE beans of " + ty + r" \(" + re.escape(db) + r"\): (\d+) · (.+)$", b, re.M)
            lines = re.findall(r"^PROBE beans: " + ty + r" bean '([^']+)' \(" + re.escape(db) + r"\): (\S+) · the bean factory's dependency list: \[(.*)\]$", b, re.M)
            ok(len(c) == 1 and int(c[0][0]) == len(lines), "%s: beans of %s - the count %s = the bean lines the factory listed (%d)" % (db, ty, c[0][0] if c else "?", len(lines)))
            ok(len(c) == 1 and sorted(set(x[1] for x in lines)) == c[0][1].split(", "), "%s: beans of %s - the class in the count line = the beans' own classes" % (db, ty))
            cnt[ty] = (c[0] if c else ("?", "?"), lines)
        def nm(ty):
            return cnt[ty][1][0][0] if len(cnt[ty][1]) == 1 else "?"
        def deps(ty):
            return cnt[ty][1][0][2].split(", ") if len(cnt[ty][1]) == 1 else []
        f = re.findall(r"^PROBE beans: the JdbcClient's field namedParamOps \(reflection, " + re.escape(db) + r"\): (\S+) · the same object as the NamedParameterJdbcTemplate bean: (true|false)$", b, re.M)
        g = re.findall(r"^PROBE beans: the NamedParameterJdbcTemplate's getJdbcOperations\(\) \(" + re.escape(db) + r"\): (\S+) · the same object as the JdbcTemplate bean: (true|false)$", b, re.M)
        h = re.findall(r"^PROBE beans: the JdbcTemplate's getDataSource\(\) \(" + re.escape(db) + r"\): (\S+) · the same object as the DataSource bean: (true|false)$", b, re.M)
        w = re.findall(r"^PROBE beans: the DataSource bean wraps \(the witness's ProxyDataSource\.getDataSource\(\), " + re.escape(db) + r"\): (\S+)$", b, re.M)
        dep = re.findall(r"^PROBE beans: the beans that depend on '([^']+)' \(the bean factory's list, " + re.escape(db) + r"\): \[(.*)\]$", b, re.M)
        ok(len(f) == 1 and len(g) == 1 and len(h) == 1 and len(w) == 1 and len(dep) == 1, "%s: the wiring lines printed" % db)
        if f and g and h and dep:
            ok((f[0][1] == "true") == (nm("NamedParameterJdbcTemplate") in deps("JdbcClient")), "%s: reflection and the bean factory agree - JdbcClient's field is the named template bean iff its dependency list names it" % db)
            ok((g[0][1] == "true") == (nm("JdbcTemplate") in deps("NamedParameterJdbcTemplate")), "%s: reflection and the bean factory agree - the named template's JdbcOperations is the JdbcTemplate bean iff its dependency list names it" % db)
            ok((h[0][1] == "true") == (nm("DataSource") in deps("JdbcTemplate")), "%s: reflection and the bean factory agree - the JdbcTemplate's DataSource is the DataSource bean iff its dependency list names it" % db)
            ok(dep[0][0] == nm("NamedParameterJdbcTemplate") and (nm("JdbcClient") in dep[0][1].split(", ")) == (f[0][1] == "true"), "%s: the named template's dependents name the JdbcClient bean iff the field is that bean" % db)
            ok(f[0][0] == cnt["NamedParameterJdbcTemplate"][0][1] if f[0][1] == "true" else True, "%s: the field's class = the named template bean's class" % db)
        res[db] = [re.sub(r" \((?:reflection, |the witness's ProxyDataSource\.getDataSource\(\), |the bean factory's list, )?" + re.escape(db) + r"\)", " (DB)", x)
                   for x in re.findall(r"^PROBE beans.*$", b, re.M)]
        res[db + "f"] = (cnt, f, g, h, w, dep)
    ok(res[PG] == res[H2], "the bean lines - counts, classes, names, dependency lists, wiring - are the same on PostgreSQL and H2")
    cnt, f, g, h, w, dep = res[PG + "f"]
    built = "unread"
    if f and g and h:
        chainok = f[0][1] == "true" and g[0][1] == "true" and h[0][1] == "true"
        built = ("JdbcClient (%s) holds the context's NamedParameterJdbcTemplate bean (its field namedParamOps, by reflection: the same object; its dependency list names it), "
                 "which holds the context's JdbcTemplate bean (getJdbcOperations(): the same object), which holds the DataSource bean (getDataSource(): the same object; the witness's %s around %s)"
                 % (cnt["JdbcClient"][0][1], cnt["DataSource"][0][1], w[0] if w else "?")) if chainok else \
                ("JdbcClient's field: %s (the same object as the named template bean: %s); the named template's JdbcOperations the JdbcTemplate bean: %s; the JdbcTemplate's DataSource the bean: %s"
                 % (f[0][0], f[0][1], g[0][1], h[0][1]))
    done("RE-MEASURE 11, read off the running context, PostgreSQL 18.6 and H2 2.5.250 the same - " +
         " · ".join("beans of %s: %s · %s" % (ty, cnt[ty][0][0], cnt[ty][0][1]) for ty in TYPES) +
         "; what JdbcClient is built on: " + built + "; the beans that depend on the named template: [" + (dep[0][1] if dep else "?") + "]")

# ---- missing -------------------------------------------------------------------------------------------------------------------
if MODE == "missing":
    t = read(sys.argv[2])
    versions(t, "missing")
    res = {}
    bp = blocks(t, "PostgreSQL 18.6 (the container)")
    d = data(bp, PG); psqldata(bp, d)
    mr = meera(bp); want = rec(mr)
    bh = blocks(t, "H2 in memory")
    ok(data(bh, H2) == d, "the data line equal on both databases")
    h2meera(bh, mr)
    for db, b in ((PG, bp), (H2, bh)):
        three = []
        for what, label in (("missing JdbcTemplate", "missing JdbcTemplate (JdbcTemplate.queryForObject, ?, \"Nobody\""),
                            ("missing NamedParameterJdbcTemplate", "missing NamedParameterJdbcTemplate (NamedParameterJdbcTemplate.queryForObject, :name, \"Nobody\""),
                            ("missing JdbcClient", "missing JdbcClient (JdbcClient, :name, \"Nobody\", query(Customer.class).single()")):
            k, s = window(b, label, db, what)
            ok(k == (1, 1) and s == [SQLN], "%s, %s: 1 prepare, `... where name = ?` at the driver (%s)" % (db, what, k))
            th = threw(b, what)
            ok(len(th) == 1 and th[0].startswith("org.springframework.dao.EmptyResultDataAccessException: ") and th[0].endswith("actual 0"), "%s, %s: EmptyResultDataAccessException, actual 0 (%s)" % (db, what, th))
            three.append(th[0] if th else "?")
        ok(len(set(three)) == 1, "%s: the missing-row text identical for the three APIs (%d texts)" % (db, len(set(three))))
        km, sm = window(b, "missing many (JdbcTemplate.queryForObject, select name from customer, String.class", db, "missing many")
        ok(km == (1, 0) and sm == ["(createStatement)", "select name from customer"], "%s: too many rows - 1 statement, a plain Statement (no argument: createStatement), its text in the log (%s %s)" % (db, km, sm))
        many = threw(b, "missing many")
        wm = "org.springframework.dao.IncorrectResultSizeDataAccessException: Incorrect result size: expected 1, actual %s" % d[0]
        ok(many == [wm], "%s: queryForObject on every name -> actual = the data line's %s customers (%s)" % (db, d[0], many))
        ks, ss = window(b, "mixup swapped (JdbcTemplate.queryForObject, meal_type = ? and name = ?, \"Meera\", \"NON_VEG\"", db, "mixup swapped")
        ok(ks == (1, 1) and len(ss) == 1 and ss[0].endswith("where meal_type = ? and name = ?"), "%s: the swapped call - 1 prepare, `... where meal_type = ? and name = ?`" % db)
        sw = threw(b, "mixup swapped")
        ok(len(sw) == 1 and sw[0] == three[0], "%s: the swapped call (two strings) finds no row - the same text as a missing row (%s)" % (db, sw))
        kn, sn = window(b, "mixup named (NamedParameterJdbcTemplate.queryForObject, meal_type = :mealType and name = :name, Map.of(\"name\", \"Meera\", \"mealType\", \"NON_VEG\")", db, "mixup named")
        ok(kn == (1, 1) and sn == ss, "%s: the named form - 1 prepare, the same text at the driver as the swapped call (%s)" % (db, sn))
        ok(got(b, "mixup named") == [want], "%s: the named form -> Meera's row, = psql's" % db)
        kt, st = window(b, "mixup types swapped (JdbcTemplate.queryForObject, name = ? and meals_per_day = ?, 1, \"Meera\"", db, "mixup types swapped")
        ok(kt[0] == 1 and len(st) == 1 and st[0].endswith("where name = ? and meals_per_day = ?"), "%s: the swapped call (a number and a string) - 1 prepare (%s)" % (db, kt))
        tt, tc = threw(b, "mixup types swapped"), cause(b, "mixup types swapped")
        ok(len(tt) == 1 and len(tc) == 1 and tt[0].startswith("org.springframework.") and not tt[0].startswith("org.springframework.dao.EmptyResult"), "%s: the swapped number and string - the database refuses it, read off (%s)" % (db, tt))
        kr, sr = window(b, "mixup types named (NamedParameterJdbcTemplate.queryForObject, name = :name and meals_per_day = :mealsPerDay, Map.of(\"mealsPerDay\", 1, \"name\", \"Meera\")", db, "mixup types named")
        ok(kr == (1, 1) and sr == st and got(b, "mixup types named") == [want], "%s: its named form -> Meera's row, the same text at the driver" % db)
        res[db] = (three[0], many[0] if many else "?", sw[0] if sw else "?", tt[0] if tt else "?", tc[0] if tc else "?")
    ok(res[PG][:3] == res[H2][:3], "the missing-row text, the too-many text and the swapped strings' outcome are the same on PostgreSQL and H2")
    p, q = res[PG], res[H2]
    done("\"Nobody\" through JdbcTemplate.queryForObject, NamedParameterJdbcTemplate.queryForObject and JdbcClient...single() -> %s (the same text, three APIs, each in its own window; PostgreSQL 18.6 and H2 2.5.250 the same); "
         "queryForObject(\"select name from customer\", String.class) -> %s (one plain Statement, no argument); "
         "the positional mix-up, two strings swapped (meal_type = ? and name = ? given \"Meera\", \"NON_VEG\") -> %s (no row, both databases), the named form with the same two values -> %s; "
         "a number and a string swapped (name = ? and meals_per_day = ? given 1, \"Meera\") -> PostgreSQL 18.6: %s, its cause %s; H2 2.5.250: %s; its named form -> %s"
         % (p[0], p[1], p[2], want, p[3], p[4], q[3], want))

# ---- seven ---------------------------------------------------------------------------------------------------------------------
if MODE == "seven":
    t = read(sys.argv[2]); want = sys.argv[3]
    m = re.search(r"exit (\d+) · the seven responses: (\d+) lines · md5 ([0-9a-f]{32}) · listening on 20440 now: 0$", t, re.M)
    ok(m is not None and m.group(1) == "0" and m.group(2) == "7", "the seven: 7 responses, TiffinBox exit 0 after POST /shutdown")
    ok(m is not None and m.group(3) == want, "the seven's md5 = Course 7's, read off ../c7-unit31/receipts.sh (%s)" % (m.group(3) if m else None))
    ok("listens on: 127.0.0.1:20440" in t and "its log: the token 0 times" in t, "loopback only; the token never in the log")
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
    t = read(sys.argv[2]); words = int(sys.argv[3]); ms = read(sys.argv[4]); fo = read(sys.argv[5])
    ok(words == 21, "the spoken line: %d words (the brief's 21)" % words)
    out = {}
    for sh in ("bash", "zsh"):
        for w in ("README", "solution"):
            e, ls = shellblock(t, sh, w)
            ok(e == "0" and "javac: exit 0" in ls, "%s, %s: the block ran, javac exit 0" % (sh, w))
            out[(sh, w)] = ls
    ok(out[("bash", "README")] == out[("zsh", "README")] and out[("bash", "solution")] == out[("zsh", "solution")], "bash and zsh print the same")
    br, so = out[("bash", "README")], out[("bash", "solution")]
    ok("Ex05: exit 1" in br and "Ex05: exit 0" in so, "broken exits 1, solved exits 0")
    sw = re.findall(r"^PROBE mixup swapped threw: (.*)$", ms, re.M)
    bt = [x[len("EX lookup Meera threw: "):] for x in br if x.startswith("EX lookup Meera threw: ")]
    ok(len(sw) == 2 and len(set(sw)) == 1 and bt == sw[:1], "broken: the swapped call's text = capture missing's mixup swapped, on H2 and on PostgreSQL (%s)" % bt)
    hk = re.findall(r"^PROBE four JdbcTemplate: (Customer\[[^]]*\])$", fo, re.M)
    st = [x[len("EX lookup Meera: "):] for x in so if x.startswith("EX lookup Meera: ")]
    ok(len(hk) == 2 and len(set(hk)) == 1 and st == hk[:1], "solved: Meera's row = capture four's record (%s)" % st)
    ok(so[-1].startswith("EX done: yes") and br[-1].startswith("EX done: no"), "broken says no, solved says yes")
    ok(br != so, "R.196: broken and solved print differently")
    done("the exercise (%d words, H2 in memory, no Docker): broken - JdbcTemplate.queryForObject(\"... where meal_type = ? and name = ?\", rowMapper, \"Meera\", \"NON_VEG\") -> %s, exit 1; "
         "solved - NamedParameterJdbcTemplate.queryForObject(\"... where meal_type = :mealType and name = :name\", Map.of(\"name\", \"Meera\", \"mealType\", \"NON_VEG\"), rowMapper) -> %s, exit 0"
         % (words, bt[0] if bt else "?", st[0] if st else "?"))

print("FAIL no mode " + MODE)
sys.exit(1)
