"""The checks after each capture (python3 -I harness/chk31.py MODE CAPTURE): every number the video says is read off the capture here
and compared with another witness of the same run - never with a typed figure. Each check prints its verdict and the values it read
(lines "VALUES ..."), and exits 1 when it fails.

  fix      the page's read through each fetch plan, per database: the three witnesses per step (Statistics.getPrepareStatementCount,
           the SQL logger's lines, the JDBC proxy's prepareStatement - and its executeQuery), the rows read, the customers shown; each
           row's label is the step's own, read off the run (the annotation by reflection, the run option off the EMF); each row checked
           against the second connection's counts (customers, pauses, the customers with no pause); the batch rows' statements derived
           as 1 + ceil(N / size) from the shown N and the read-off size, their id lists per statement; the two databases' rows the same.
           Prints the table (the slide), the derived lines and the two "database:" lines of the batch id lists (S2.12)
  sql      the statements' texts, per database: the join, the graph's (= the left join fetch's without distinct), the batch
           statement (H2 an "in (?,...)" list of the read-off size, PostgreSQL "= any (?)"), SUBSELECT's, the same elsewhere
  paging   a page of ten with a collection fetch, per database: one statement over a derived table, rows read = the pauses of the
           customers shown (one each; three each after the second seed), WARN and HHH90003004 lines 0; the entity graph's page and
           its count query; no fetch: 1 + the count + one per customer shown
  bags     two Lists: MultipleBagFetchException, 0 statements, raised after createQuery returned; two Sets: one statement, rows read
           = the cartesian product of each customer's pauses and orders (the second connection's counts), with and without distinct
  page     TiffinBox, B (before/), A (after/), A' (after/ again): the import, the dashboard per request (HTML and JSON) and the read's
           own session, the "Paused days" column parsed by its header = the second connection's sum, row by row; GET /customers
  table    an HTML dashboard: the "Paused days" column found by its header, printed row by row (one line; the page check reads it)
"""
import math
import re
import sys

mode, path = sys.argv[1], sys.argv[2]
fails = []


def need(ok, what):
    if not ok:
        fails.append(what)
    return ok


def done(name, values):
    for f in fails:
        print("  %s: FAIL - %s" % (name, f))
    if fails:
        sys.exit(1)
    print("  %s: PASS" % name)
    print("VALUES " + values)
    sys.exit(0)


if mode == "table":
    html = open(path, encoding="utf-8").read()
    rows = re.findall(r"<tr>(.*?)</tr>", html, re.S)
    if not rows or "<th>Paused days</th>" not in rows[0]:
        print("  the table: no Paused days header"); sys.exit(1)
    head = re.findall(r"<th>(.*?)</th>", rows[0]); col = head.index("Paused days")
    cells = [re.findall(r"<td>(.*?)</td>", r) for r in rows[1:]]
    print("  the table: the header 'Paused days' is column %d · rows %d · the column, row by row: %s"
          % (col + 1, len(cells), " · ".join("%s %s" % (c[0], c[col]) for c in cells)))
    sys.exit(0)

text = open(path, encoding="utf-8").read()
L = text.splitlines()
VERS = ["  PROBE Hibernate ORM core version (org.hibernate.Version.getVersionString()): 7.4.13.Final",
        "  INFO  [main] org.hibernate.orm.core : HHH000001: Hibernate ORM core version 7.4.13.Final",
        "  PROBE Spring Data JPA version (JpaRepository.class.getPackage().getImplementationVersion()): 4.1.2",
        "  PROBE Spring Framework version (Transactional.class.getPackage().getImplementationVersion()): 7.0.10"]
DBL = {"H2": re.compile(r"^  PROBE database: H2 2\.5\.250 \| url jdbc:h2:mem:u31;DB_CLOSE_DELAY=-1 \| JDBC driver H2 JDBC Driver 2\.5\.250 \(\d{4}-\d\d-\d\d\)$"),
       "PostgreSQL": re.compile(r"^  PROBE database: PostgreSQL 18\.6 \| url jdbc:postgresql://127\.0\.0\.1:20108/u31[a-z]+ \| JDBC driver PostgreSQL JDBC Driver 42\.7\.14$")}


def databases(lines):
    """{'H2': [JVM blocks], 'PostgreSQL': [JVM blocks]} - a database's part starts at its header line, a JVM block at '$ V=('."""
    out, db = {}, None
    for l in lines:
        if l.startswith("H2 (") or l.startswith("PostgreSQL ("):
            db = l.split(" ")[0]; out[db] = []
        elif db and l.startswith("$ V=("):
            out[db].append([l])
        elif db and out[db]:
            out[db][-1].append(l)
    return out


def jvm(block, db, what):
    for v in VERS:
        need(block.count(v) == 1, "%s (%s): the line once: %s" % (what, db, v.strip()))
    need(sum(1 for l in block if DBL[db].match(l)) == 1, "%s (%s): the database line (version, URL cut before ?, driver)" % (what, db))
    need("  exit 0 · 'GenerationTarget encountered exception': 0" in block, "%s (%s): the JVM ended, exit 0" % (what, db))
    if db == "PostgreSQL":
        need("  raw password copies in its log: 0 (before the mask; the URL is printed cut before its ?)" in block, "%s (%s): the password, raw, 0" % (what, db))


def steps(block):
    out, cur = [], None
    for l in block:
        if l.startswith("  PROBE >>> "):
            cur = (l[len("  PROBE >>> "):], []); out.append(cur)
        elif l.startswith("  PROBE <<< "):
            cur = None
        elif cur:
            cur[1].append(l)
    return out


def counts(b):
    c = [l for l in b if l.startswith("  PROBE counts: ")]
    if len(c) != 1:
        return {}
    return {k: int(v) for k, v in re.findall(r"((?:Statistics\.\w+)|org\.hibernate\.SQL lines|JDBC proxy [\w ]+?) (\d+)", c[0])}


def result(b):
    r = [l for l in b if l.startswith("  PROBE result: ")]
    return r[0][len("  PROBE result: "):] if len(r) == 1 else ""


def lists(b):
    r = [l for l in b if l.startswith("  PROBE id lists its statements asked for (JDBC proxy): ")]
    return r[0].split(": ", 1)[1] if len(r) == 1 else "?"


def three(c, what):
    s = c.get("Statistics.getPrepareStatementCount", -1); q = c.get("org.hibernate.SQL lines", -2); p = c.get("JDBC proxy prepareStatement", -3)
    need(s == q == p, "%s: Statistics.getPrepareStatementCount %d · org.hibernate.SQL lines %d · JDBC proxy prepareStatement %d - the three witnesses differ" % (what, s, q, p))
    need(c.get("JDBC proxy executeQuery") == p, "%s: the proxy's executeQuery %s = its prepareStatement %d" % (what, c.get("JDBC proxy executeQuery"), p))
    return s


def generated(block):
    for l in block:
        m = re.match(r"  PROBE generated \(-Dn=(\d+)\): customers 'Customer 0000001'\.\.\., one pause each · the second connection reads: customers (\d+) · pauses (\d+)$", l)
        if m:
            return int(m.group(1)), int(m.group(2)), int(m.group(3))
    return None


def texts(block):
    out = []
    for l in block:
        m = re.match(r"  SQL text, sent (\d+) x: (.*)$", l)
        if m:
            out.append((int(m.group(1)), m.group(2)))
    return out


if mode == "fix":
    dbs = databases(L)
    need(sorted(dbs) == ["H2", "PostgreSQL"], "fix: both databases - %s" % sorted(dbs))
    tables, inlines, derived, lost = {}, {}, {}, {}
    for db, blocks in dbs.items():
        need(len(blocks) == 2, "fix (%s): two JVMs, the plans and the run option" % db)
        rows = []
        for block in blocks:
            jvm(block, db, "fix")
            g = generated(block)
            if not need(g is not None, "fix (%s): the generator's line" % db):
                continue
            n, cust, pauses = g
            npl = [l for l in block if l.startswith("  PROBE the second connection - customers with no pause: ")]
            nop = re.findall(r"[A-Z][a-z]+", npl[0].split(": ", 1)[1]) if npl else None
            for label, b in steps(block):
                short = label.split(" - ")[0]
                c = counts(b); s = three(c, "%s %s" % (db, short)); res = result(b)
                m = re.match(r"customers shown (\d+) · seeded \{(.*?)\} · generated (\d+), days each \[(.*?)\]$", res)
                if not need(m is not None and c, "fix (%s) %s: the result and counts lines - %s" % (db, short, res)):
                    continue
                shown = int(m.group(1)); seeded = dict((k, int(v)) for k, v in re.findall(r"(\w+)=(\d+)", m.group(2)))
                rr = c.get("JDBC proxy rows read", -1); cf = c.get("Statistics.getCollectionFetchCount", -1); el = c.get("Statistics.getEntityLoadCount", -1)
                lst = lists(b); what = "fix (%s) %s" % (db, short)
                need(int(m.group(3)) + len(seeded) == shown, "%s: the shown customers' parts add up" % what)
                if short == "none":
                    need(s == 1 + cust and cf == cust and rr == cust + pauses and shown == cust,
                         "%s: one statement for the list and one per customer (%d), a collection fetch each, rows read = customers + pauses (%d + %d) - %d · %d · %d" % (what, cust, cust, pauses, s, cf, rr))
                elif short in ("left join fetch",) or short.startswith("@EntityGraph(") or short.startswith("@NamedEntityGraph("):
                    need(nop is not None and s == 1 and cf == 0 and rr == pauses + len(nop) and shown == cust and el == cust + pauses,
                         "%s: one statement, no collection fetch, rows read = pauses + the customers with no pause (%d + %s), every customer shown (%d) - %d · %d · %d · %d" % (what, pauses, nop, cust, s, cf, rr, shown))
                elif short == "inner join fetch":
                    gone = sorted(set(["Meera", "Priya", "Ravi", "Sunil"]) - set(seeded)) if nop is not None else None
                    need(nop is not None and s == 1 and rr == pauses and shown == cust - len(nop) and gone == nop,
                         "%s: one statement, rows read = pauses (%d), the customers with no pause gone (%s; the second connection: %s) - %d · %d · %d" % (what, pauses, gone, nop, s, rr, shown))
                    lost[db] = (shown, cust, gone)
                elif short.startswith("@BatchSize(size = ") or short.startswith("default_batch_fetch_size="):
                    k = int(re.search(r"(\d+)\)?$", short).group(1))
                    pb = re.search(r"the collection persister's batch size (\d+)", label)
                    need(pb is not None and int(pb.group(1)) == k, "%s: the collection persister's batch size = the read-off %d" % (what, k))
                    batches = math.ceil(shown / k)
                    need(s == 1 + batches and cf == batches and rr == cust + pauses and shown == cust,
                         "%s: statements = 1 + ceil(%d / %d) = %d, collection fetches ceil = %d, rows read %d - got %d · %d · %d" % (what, shown, k, 1 + batches, batches, cust + pauses, s, cf, rr))
                    ph = [int(x) for x in re.findall(r"in \(\?,\.\.\.\) placeholders (\d+)", lst)]
                    ar = [int(x) for x in re.findall(r"= any \(\?\) bound array length (\d+)", lst)]
                    if db == "H2":
                        need(len(ph) == batches and not ar and all(x == k for x in ph) and sum(ph) >= shown,
                             "%s: %d in (?,...) lists, each of the size %d - %s" % (what, batches, k, lst))
                        inl = "in (?,...) placeholders %s - each list the read-off size %d, the last batch padded to it (%d ids asked for in %d placeholders)" % (" · ".join(map(str, ph)), k, shown, sum(ph))
                    else:
                        need(len(ar) == batches and not ph and all(x <= k for x in ar) and sum(ar) == shown,
                             "%s: %d = any (?) arrays, none over %d, %d ids in all - %s" % (what, batches, k, shown, lst))
                        inl = "= any (?) bound array lengths %s - one array parameter per statement, none over the read-off size %d, %d ids in all" % (" · ".join(map(str, ar)), k, sum(ar))
                    inlines.setdefault(db, {})[short] = inl
                    derived.setdefault(db, []).append("derived: %s - 1 + ceil(%d / %d) = %d = its statements; ceil(%d / %d) = %d = Statistics.getCollectionFetchCount"
                                                      % (short, shown, k, 1 + batches, shown, k, batches))
                elif short.startswith("@Fetch(FetchMode.SUBSELECT)"):
                    need(s == 2 and cf == 1 and rr == cust + pauses and shown == cust, "%s: the list and one statement for every collection, one collection fetch - %d · %d · %d" % (what, s, cf, rr))
                elif short == "the DTO group-by projection":
                    need(s == 1 and el == 0 and rr == cust and shown == cust, "%s: one statement, no entity loaded, a row per customer - %d · %d · %d" % (what, s, el, rr))
                else:
                    need(False, "%s: a step this check does not know" % what)
                if short != "inner join fetch":
                    need(seeded == {"Meera": 0, "Priya": 2, "Ravi": 0, "Sunil": 3}, "%s: the seeded customers' days %s" % (what, seeded))
                rows.append("row: %s · statements %d · rows read %d · customers shown %d · Statistics.getCollectionFetchCount %d · Statistics.getEntityLoadCount %d"
                            % (short, s, rr, shown, cf, el))
        tables[db] = rows
    need(len(tables.get("H2", [])) == 9, "fix: nine rows on H2 - %d" % len(tables.get("H2", [])))
    need(tables.get("H2") == tables.get("PostgreSQL"), "fix: the two databases' rows must be the same, row by row")
    need(derived.get("H2") == derived.get("PostgreSQL") and len(derived.get("H2", [])) == 2, "fix: the derived batch lines, the same on both")
    if fails:
        done("fix", "")
    for r in tables["H2"]:
        print("  " + r)
    for d in derived["H2"]:
        print("  " + d)
    sh, cu, gone = lost["H2"]
    print("  the inner join fetch: customers shown %d of %d - %s gone, the customers with no pause (the second connection)" % (sh, cu, " and ".join(gone)))
    print("  the two databases' rows: the same, row by row (%d rows)" % len(tables["H2"]))
    for db in ("H2", "PostgreSQL"):
        for short, inl in inlines[db].items():
            print("  database: %s - %s, each batch statement's id list (JDBC proxy): %s" % (db, short, inl))
    done("fix", " ; ".join(r[len("row: "):] for r in tables["H2"]) + " ; " + " ; ".join(derived["H2"])
         + " ; the inner join fetch drops %s" % " and ".join(gone)
         + " ; " + " ; ".join("database: %s - %s" % (db, inlines[db][s]) for db in ("H2", "PostgreSQL") for s in inlines[db]))

if mode == "sql":
    dbs = databases(L)
    need(sorted(dbs) == ["H2", "PostgreSQL"], "sql: both databases")
    per = {}
    for db, blocks in dbs.items():
        if not need(len(blocks) == 1, "sql (%s): one JVM" % db):
            continue
        block = blocks[0]; jvm(block, db, "sql")
        g = generated(block); tx = texts(block)
        if not need(g is not None and tx, "sql (%s): the generator's line and the texts" % db):
            continue
        n, cust, pauses = g
        st = dict((label.split(" - ")[0], b) for label, b in steps(block))
        bs = [k for k in st if k.startswith("@BatchSize(size = ")]
        k = int(re.search(r"(\d+)\)$", bs[0]).group(1)) if bs else -1
        J = " from customer ce1_0 left join pause p1_0 on ce1_0.id=p1_0.customer_id order by ce1_0.name"
        ljf = [t for c, t in tx if t.startswith("select distinct ce1_0.") and t.endswith(J)]
        gr = [t for c, t in tx if t.startswith("select ce1_0.") and t.endswith(J)]
        inn = [t for c, t in tx if t.startswith("select distinct ce1_0.") and t.endswith(" from customer ce1_0 join pause p1_0 on ce1_0.id=p1_0.customer_id order by ce1_0.name")]
        sub = [t for c, t in tx if t.endswith(" from pause p1_0 where p1_0.customer_id in (select t1_0.id from customer t1_0)")]
        one = [(c, t) for c, t in tx if t.endswith(" from pause p1_0 where p1_0.customer_id=?")]
        bat = [(c, t) for c, t in tx if re.search(r"where p1_0\.customer_id (in \([?,]+\)|= any \(\?\))$", t)]
        need(len(ljf) == 1 and len(gr) == 1 and gr[0] == ljf[0].replace("select distinct ", "select ", 1),
             "sql (%s): the graph's statement = the left join fetch's without its distinct" % db)
        need(len(inn) == 1 and len(sub) == 1, "sql (%s): the inner join's text and SUBSELECT's" % db)
        need(len(one) == 1 and one[0][0] == cust, "sql (%s): the pauses' one-customer statement, sent once per customer (%d) - %s" % (db, cust, one))
        need(len(bat) == 1 and bat[0][0] == math.ceil(cust / k), "sql (%s): one batch text, sent ceil(%d / %d) times - %s" % (db, cust, k, bat))
        if db == "H2" and bat:
            m = re.search(r"in \(([?,]+)\)$", bat[0][1])
            need(m is not None and len(m.group(1).split(",")) == k, "sql (H2): the in list holds the read-off size %d of placeholders" % k)
        if db == "PostgreSQL" and bat:
            need(bat[0][1].endswith("where p1_0.customer_id = any (?)"), "sql (PostgreSQL): the batch statement asks = any (?)")
        per[db] = (tx, ljf, gr, inn, sub, bat, k, cust)
    if not fails:
        a = [t for c, t in per["H2"][0] if t != per["H2"][5][0][1]]; b = [t for c, t in per["PostgreSQL"][0] if t != per["PostgreSQL"][5][0][1]]
        need(a == b, "sql: every text but the batch statement's is the same on both databases")
    if fails:
        done("sql", "")
    tx, ljf, gr, inn, sub, bat, k, cust = per["H2"]
    print("  the left join fetch's statement (both databases): %s" % ljf[0])
    print("  the entity graph's statement (both databases) = the left join fetch's without its distinct: - 'select distinct ' + 'select '")
    print("  the inner join fetch's statement (both databases): %s" % inn[0])
    print("  SUBSELECT's second statement (both databases): %s" % sub[0])
    for db in ("H2", "PostgreSQL"):
        c, t = per[db][5][0]
        print("  database: %s - the batch statement, sent %d x for %d customers at @BatchSize(size = %d): %s" % (db, c, per[db][7], per[db][6], t))
    print("  every other text: the same on both databases")
    done("sql", "the join: %s ; the graph's = the left join fetch's without distinct ; SUBSELECT: %s ; " % (gr[0], sub[0])
         + " ; ".join("database: %s - %s" % (db, per[db][5][0][1]) for db in ("H2", "PostgreSQL")))

if mode == "paging":
    dbs = databases(L)
    need(sorted(dbs) == ["H2", "PostgreSQL"], "paging: both databases")
    out = {}
    for db, blocks in dbs.items():
        if not need(len(blocks) == 1, "paging (%s): one JVM" % db):
            continue
        block = blocks[0]; jvm(block, db, "paging")
        g = generated(block); st = steps(block); tx = texts(block)
        w = [l for l in block if l.startswith("  its WARN lines (grep -c '^WARN '): ")]
        if not need(g is not None and len(st) == 4 and len(w) == 1, "paging (%s): the generator's line, four steps, the WARN line" % db):
            continue
        n, cust, pauses = g
        wm = re.match(r"  its WARN lines \(grep -c '\^WARN '\): (\d+) · HHH90003004 lines \(grep -c\): (\d+)$", w[0])
        need(wm is not None and wm.group(1) == "0" and wm.group(2) == "0", "paging (%s): WARN lines 0 and HHH90003004 lines 0 - %s" % (db, w[0]))
        dt = [(c, t) for c, t in tx if " from (select " in t and " offset ? rows fetch first ? rows only) ce1_0(" in t and t.endswith(" left join pause p1_0 on ce1_0.id=p1_0.customer_id order by ce1_0.name")]
        need(len(dt) == 1 and dt[0][0] == 3, "paging (%s): the derived table's statement, sent by the three fetching steps - %s" % (db, dt))
        cnt = [(c, t) for c, t in tx if t == "select count(*) from customer ce1_0"]
        need(len(cnt) == 1 and cnt[0][0] == 1, "paging (%s): the entity graph page's count statement once" % db)
        sec = [l for l in block if l.startswith("  PROBE the second seed: ")]
        each = [int(x) for x in re.findall(r"\d+", sec[0].split("pauses each: ", 1)[1])] if sec else []
        vals = []
        for i, (label, b) in enumerate(st):
            c = counts(b); s = three(c, "paging %s %d" % (db, i + 1)); res = result(b)
            m = re.match(r"customers shown (\d+) · first (.*?) · last (.*?) · their pauses (\d+)(?: · of total (\d+))?$", res)
            if not need(m is not None, "paging (%s) step %d: the result" % (db, i + 1)):
                continue
            sh, tp = int(m.group(1)), int(m.group(4)); rr = c.get("JDBC proxy rows read", -1)
            if i in (0, 3):
                need(s == 1 and rr == tp and c.get("Statistics.getCollectionFetchCount") == 0, "paging (%s) %s: one statement, rows read = the shown customers' pauses (%d) - %d · %d" % (db, label, tp, s, rr))
                if i == 0:
                    need(tp == sh, "paging (%s): one pause each before the second seed" % db)
                else:
                    need(len(each) == sh and tp == sum(each), "paging (%s): after the second seed, the pauses read = the second connection's for the first %d (%s)" % (db, sh, each))
                vals.append((s, rr, sh))
            elif i == 1:
                need(s == 2 and m.group(5) is not None and int(m.group(5)) == cust and rr == tp + 1, "paging (%s) the graph's page: the derived table and a count, total = customers (%d) - %d · %s" % (db, cust, s, m.group(5)))
                vals.append((s, int(m.group(5)), sh))
            else:
                need(s == 1 + 1 + sh and c.get("Statistics.getCollectionFetchCount") == sh, "paging (%s) no fetch: 1 + the count + one per customer shown (%d) - %d" % (db, sh, s))
                vals.append((s, rr, sh))
        out[db] = (vals, dt[0][1] if dt else "", wm.groups() if wm else ("?", "?"))
    need(out.get("H2", [None])[0] == out.get("PostgreSQL", [None])[0], "paging: the two databases' counts the same")
    need(out.get("H2", ["", ""])[1] == out.get("PostgreSQL", ["", ""])[1], "paging: the derived table's text the same on both")
    if fails:
        done("paging", "")
    (s1, r1, n1), (s2, tot, n2), (s3, r3, n3), (s4, r4, n4) = out["H2"][0]
    line = ("left join fetch + setMaxResults(10): %d statement over a derived table, rows read %d for %d customers shown (one pause each), rows read %d after the second seed "
            "(three pauses each); @EntityGraph + PageRequest.of(0, 10, Sort.by(\"name\")): %d statements (the derived table, then select count(*) from customer ce1_0), total %d; "
            "no fetch + a page: %d statements (1 + the count + %d); WARN lines %s · HHH90003004 lines %s" % (s1, r1, n1, r4, s2, tot, s3, n3, out["H2"][2][0], out["H2"][2][1]))
    print("  both databases: " + line)
    print("  the derived table's statement (both databases): %s" % out["H2"][1])
    done("paging", "both databases: " + line)

if mode == "bags":
    dbs = databases(L)
    need(sorted(dbs) == ["H2", "PostgreSQL"], "bags: both databases")
    out = {}
    MBF = "  PROBE threw: java.lang.IllegalArgumentException: org.hibernate.loader.MultipleBagFetchException: cannot simultaneously fetch multiple bags: [probe.w.ent.BCustomer.orders, probe.w.ent.BCustomer.pauses]"
    for db, blocks in dbs.items():
        if not need(len(blocks) == 1, "bags (%s): one JVM" % db):
            continue
        block = blocks[0]; jvm(block, db, "bags")
        st = steps(block)
        sc = [l for l in block if l.startswith("  PROBE the second connection - each customer's pauses and orders")]
        if not need(len(st) == 3 and len(sc) == 1, "bags (%s): three steps and the second connection's counts" % db):
            continue
        per = [(a, int(b), int(c)) for a, b, c in re.findall(r"(\w+) (\d+) (\d+)", sc[0].split(": ", 1)[1])]
        prod = sum(max(1, p) * max(1, o) for _, p, o in per)
        (l1, b1), (l2, b2), (l3, b3) = st
        c1 = counts(b1); s1 = three(c1, "bags %s two Lists" % db)
        need(MBF in b1 and "  PROBE createQuery returned" in b1 and s1 == 0, "bags (%s) two Lists: MultipleBagFetchException after createQuery returned, 0 statements" % db)
        sets = []
        for lab, b in ((l2, b2), (l3, b3)):
            c = counts(b); s = three(c, "bags %s %s" % (db, lab)); res = result(b)
            m = re.match(r"customers shown (\d+) · \[(.*)\]$", res)
            got = [(a, int(p), int(o)) for a, p, o in re.findall(r"(\w+) pauses (\d+) orders (\d+)", m.group(2))] if m else []
            need(s == 1 and c.get("JDBC proxy rows read") == prod and m is not None and int(m.group(1)) == len(per) and got == per,
                 "bags (%s) %s: one statement, rows read = the product %d, every customer once with the second connection's counts - %d · %s · %s" % (db, lab.split(" - ")[0], prod, s, c.get("JDBC proxy rows read"), res))
            sets.append((s, c.get("JDBC proxy rows read"), int(m.group(1)) if m else -1))
        out[db] = (s1, sets, per, prod)
    need(out.get("H2") == out.get("PostgreSQL"), "bags: the two databases the same")
    if fails:
        done("bags", "")
    s1, sets, per, prod = out["H2"]
    der = " + ".join("%s %d x %d" % (a, max(1, p), max(1, o)) for a, p, o in per)
    print("  both databases: two Lists fetched - %s, %d statements, raised by getResultList after createQuery returned" % (MBF[len("  PROBE threw: "):], s1))
    print("  both databases: two Sets fetched - %d statement, rows read %d = %s (each customer's pauses x orders, a customer with none counted once - the second connection's counts), customers shown %d with distinct and %d without"
          % (sets[0][0], sets[0][1], der, sets[0][2], sets[1][2]))
    done("bags", "two Lists: %s (%d statements, after createQuery returned) ; two Sets: %d statement, rows read %d = %s, customers shown %d with distinct and %d without"
         % (MBF[len("  PROBE threw: "):], s1, sets[0][0], sets[0][1], der, sets[0][2], sets[1][2]))

if mode == "page":
    secs, cur = [], None
    for l in L:
        if l.startswith("B - ") or l.startswith("A - ") or l.startswith("A2 - "):
            cur = (l.split(" - ")[0], []); secs.append(cur)
        elif cur:
            cur[1].append(l)
    keyed = {}
    chg = [l for l in L[:L.index(next(x for x in L if x.startswith("B - ")))] if l.startswith("  ") and not l.startswith("    ") and not l.startswith("  its diff")] if any(x.startswith("B - ") for x in L) else []
    need(chg == ["  README.md", "  tiffinbox-core/src/main/java/com/tiffinbox/CustomerEntityRepository.java", "  tiffinbox-core/src/main/java/com/tiffinbox/CustomerRepository.java"],
         "anchor: the change - the README and two files: %s" % chg)
    need("    +    @EntityGraph(attributePaths = \"pauses\")" in L and "    +    List<CustomerEntity> findAllByOrderByNameAsc();" in L
         and "    -        for (CustomerEntity e : customers.findAll(Sort.by(\"name\"))) {" in L and "    +        for (CustomerEntity e : customers.findAllByOrderByNameAsc()) {" in L,
         "anchor: the change's code lines - the graph, the method, the read's call")
    for k, lines in secs:
        def segs(after):
            i = lines.index(after) if after in lines else -1
            out = []
            for l in lines[i + 1:] if i >= 0 else []:
                if l.startswith("$ ") or l.startswith("the "):
                    break
                out.append(l)
            return out
        reqs = [l for l in lines if l.startswith("$ curl ")]
        if not need(len(reqs) == 4, "%s: four requests - %d" % (k, len(reqs))):
            continue
        imp, dh, dj, cu = [segs(r) for r in reqs]
        cnts = [l for l in lines if re.match(r"^  \d+$", l)]
        if not need(len(cnts) == 2, "%s: the second connection's two counts" % k):
            continue
        cust2, pause2 = int(cnts[0]), int(cnts[1])
        i0 = next((i for i, l in enumerate(lines) if l.startswith("  NAME") and "COALESCE(SUM(P.DAYS), 0)" in l), None)
        grp = []
        if i0 is not None:
            for l in lines[i0 + 1:]:
                m = re.match(r"^  (.+?) *\| *(\d+)$", l)
                if not m:
                    break
                grp.append("%s %s" % (m.group(1), m.group(2)))
        need(len(grp) == cust2, "%s: the second connection's sum, a row per customer (%d) - %d" % (k, cust2, len(grp)))
        m = re.match(r'  -> 200 \{"file":"import\.csv","added":(\d+),"refused":\{\}\}$', imp[0]) if imp else None
        if not need(m is not None, "%s: the import's answer 200, added N, refused none" % k):
            continue
        added = int(m.group(1))
        need("  between its markers: SQL lines %d (INSERTs into customer %d) · WARN lines 0 · ERROR lines 0" % (added, added) in imp, "%s: the import - one INSERT per line added (%d)" % (k, added))
        dash = {}
        for name, blk in (("html", dh), ("json", dj)):
            need(blk[:1] == ["  -> 200"], "%s: the dashboard (%s) 200" % (k, name))
            sl = [x for x in (re.match(r"  between its markers: SQL lines (\d+) \(INSERTs into customer 0\) · WARN lines 0 · ERROR lines 0$", l) for l in blk) if x]
            ms = [x for x in (re.match(r"  session-metrics blocks \(HHH000401\) it closed: (\d+) · their 'preparing N JDBC statements', N by N: (.*)$", l) for l in blk) if x]
            rd = [x for x in (re.match(r"  the read's session - its thread's lines from 'Creating new transaction with name \[com\.tiffinbox\.CustomerRepository\.pausedDaysByCustomer\]' .*: SQL lines (\d+) · 'Participating in existing transaction' (\d+) · the block", l) for l in blk) if x]
            if not need(len(sl) == 1 and len(ms) == 1 and len(rd) == 1, "%s: the dashboard (%s): its SQL lines, its sessions and the read's session bound (the manager line naming pausedDaysByCustomer)" % (k, name)):
                continue
            req = int(sl[0].group(1)); nsess = int(ms[0].group(1)); per = []
            for part in ms[0].group(2).split(" · "):
                v, c = part.split(" x"); per += [int(v)] * int(c)
            prep = [int(x.group(1)) for x in (re.match(r"    <ns> ns preparing (\d+) JDBC statements$", l) for l in blk) if x]
            fl = [l.strip() for l in blk if re.match(r"    <ns> ns executing \d+ flushes ", l)]
            need(sum(per) == req and nsess == len(per), "%s (%s): the request's SQL lines %d = the sum over its %d sessions %s (S5.2: four reads, four sessions)" % (k, name, req, nsess, per))
            need(len(prep) == 1 and prep[0] == int(rd[0].group(1)), "%s (%s): the read's block - preparing %s = its thread's SQL lines" % (k, name, prep))
            need(int(rd[0].group(2)) == (1 if k == "B" else 0), "%s (%s): B's findAll(Sort) - SimpleJpaRepository's own @Transactional - joins the read's transaction (Participating 1); A's derived findAllByOrderByNameAsc() carries none of its own and runs inside it (Participating 0): %s" % (k, name, rd[0].group(2)))
            need(fl == ["<ns> ns executing 0 flushes (flushing a total of 0 entities and 0 collections)"], "%s (%s): the read-only read flushes nothing: %s" % (k, name, fl))
            if k == "B":
                need(prep and prep[0] == 1 + cust2, "B (%s): the read's session prepares 1 + the customers the second connection counts (%d): %s" % (name, cust2, prep))
            else:
                need(prep == [1] and per == [1] * nsess, "%s (%s): the read's session prepares one statement, and every session one: %s, %s" % (k, name, prep, per))
            dash[name] = (req, nsess, prep[0] if prep else -1, per)
        need(len(dash) == 2 and dash.get("html") == dash.get("json"), "%s: the dashboard as HTML and as JSON - the same counts: %s" % (k, dash))
        tb = [l for l in dh if l.startswith("  the table: ")]
        tm = re.match(r"  the table: the header 'Paused days' is column (\d+) · rows (\d+) · the column, row by row: (.*)$", tb[0]) if tb else None
        if need(tm is not None, "%s: the table line" % k):
            col = tm.group(3).split(" · ")
            need(int(tm.group(1)) == 6 and int(tm.group(2)) == cust2 and col == grp,
                 "%s: the Paused days column (column %s, %s rows) = the second connection's sum, row by row (%d rows)" % (k, tm.group(1), tm.group(2), len(grp)))
        jl = [l for l in dj if l.startswith("  the JSON (python3 -I): ")]
        need(jl == ["  the JSON (python3 -I): customers %d · names %d · keys customers monthRevenue names pausedDays" % (cust2, cust2)], "%s: the JSON dashboard's four keys, customers and names = %d: %s" % (k, cust2, jl))
        need(cu[:1] == ["  -> 200 · entries parsed (python3 -I): %d" % cust2], "%s: GET /customers - %d entries: %s" % (k, cust2, cu[:1]))
        need("  between its markers: SQL lines 1 (INSERTs into customer 0) · WARN lines 0 · ERROR lines 0" in cu, "%s: GET /customers - one SQL line" % k)
        need(any(l.startswith("  stopped by its pid (SIGTERM): exit 143 · listening on ") for l in lines), "%s: stopped" % k)
        keyed[k] = (lines, added, dash, cust2, [g for g in grp if not g.startswith("Customer ")], sorted(set(g.split(" ")[-1] for g in grp if g.startswith("Customer "))))
    if need("B" in keyed and "A" in keyed and "A2" in keyed, "anchor: B, A and A'"):
        norm = lambda ls: [re.sub(r"2010[12]", "<port>", re.sub(r"u31a2?\b", "<db>", re.sub(r"\.harness/after2?\b", ".harness/<tree>", l))) for l in ls[1:]]
        need(norm(keyed["A"][0]) == norm(keyed["A2"][0]), "A' (after/ copied and built again) must print what A printed (R.1)")
    if fails:
        done("anchor", "")
    _, added, bd, cust2, seeded, imported = keyed["B"]
    _, _, ad, _, _, _ = keyed["A"]
    print("  B (before/ = ../c7-unit29/after): the import added %d; GET /dashboard, HTML and JSON alike: %d SQL lines in the whole request (its %d sessions: %s), the read's own session (pausedDaysByCustomer) preparing %d = 1 + %d customers"
          % (added, bd["html"][0], bd["html"][1], " ".join(map(str, bd["html"][3])), bd["html"][2], cust2))
    print("  A (after/): the import added %d; GET /dashboard, HTML and JSON alike: %d SQL lines in the whole request (its %d sessions: %s), the read's own session (pausedDaysByCustomer, its transaction kept: Creating new transaction; the derived method no transaction of its own, Participating 0) preparing %d"
          % (added, ad["html"][0], ad["html"][1], " ".join(map(str, ad["html"][3])), ad["html"][2]))
    print("  B and A: the Paused days column (by its header, column 6) = the second connection's sum, row by row, %d rows - %s, every imported customer %s; GET /customers 1 SQL line, %d entries; A' = A"
          % (cust2, " · ".join(seeded), "/".join(imported), cust2))
    done("anchor", "B (before/): GET /dashboard (HTML and JSON) %d SQL lines in the whole request (sessions %s), the read's session preparing %d ; A (after/): %d SQL lines in the whole request (sessions %s), the read's session preparing %d, Creating new transaction with name [com.tiffinbox.CustomerRepository.pausedDaysByCustomer] ; the Paused days column = the second connection row by row: %s, every imported customer %s ; GET /customers 1 SQL line, %d entries ; A' = A"
         % (bd["html"][0], " ".join(map(str, bd["html"][3])), bd["html"][2], ad["html"][0], " ".join(map(str, ad["html"][3])), ad["html"][2], " · ".join(seeded), "/".join(imported), cust2))

print("chk31: no mode " + mode)
sys.exit(2)
