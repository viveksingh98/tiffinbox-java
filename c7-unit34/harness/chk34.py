"""Unit 34's checks (python3 -I -B harness/chk34.py MODE FILE [ARG...]): every number and string the video says, read off its capture
and asserted against another witness of the same run - never against a typed figure. Each mode prints one line per check and a VALUES
line (the values the video may say, composed from what it read). Exit 1 on the first failed check.
  ways        six JVMs on H2, the one read each: the version lines (the OFF run: HHH000001 absent, every org.hibernate logger off); the
              three witnesses equal (Statistics, the proxy - and the SQL logger where it is on); (i) show-sql: the read's two
              "Hibernate:" lines between its markers, the SQL logger at WARN; (ii) the OFF run: the two lines still printed, beside the
              control that the level took - org.hibernate.SQL's effective level OFF, isDebugEnabled() false, org.hibernate OFF, 0
              org.hibernate logger lines where (iii) has more than 0 (S5.13); (iii) the bind lines, the VARCHAR one Sunil, the BIGINT one
              her id as the second connection read it; (iv) format_sql: the first statement's lines; (v) highlight_sql: ESC[34m in the
              log file; (vi) use_sql_comments: a comment on the first statement, none on the collection's
  collection  prints the lazy collection's statement, read off (iii)'s SQL logger (the second statement of the read)
  spy         p6spy's jar from dependency:list and ls -l; on H2 the failing start (exit 1, Boot's pool without a user name, the
              28000-250 line) beside the fixed run (user sa, the read's two statements with their binds inlined, 0 WARN, 0 JVM
              warnings); on PostgreSQL every spy.log line held the password before the mask, 0 copies after, the file deleted
  dsproxy     datasource-proxy's line per statement (two in the read), the query and its parameters, Connection and Time masked, no
              URL ('jdbc:' 0); the BOM names neither tool
  slow        per JVM: the versions, the design, the configured log_slow_query read off the EMF, the seed run twice, the generator
              counted back (seed + N, seed + N K), every round's order (even rounds without -> with, odd reversed: R.300), every
              lookup's rows checked, the index lists (PostgreSQL: the new index and the primary key, then the key alone; H2: its own
              constraint index on both sides), the plan pair (PostgreSQL: a sequential scan removing every other customer's rows
              without, the new index with; H2: one plan, both sides, its constraint index), the SQL_SLOW chip (PostgreSQL: lines
              without, none with; H2 none), PostgreSQL's threshold line; then the run's table: at least ten JVMs per database (R.236),
              every PostgreSQL ratio >= T, the margin and the SQL_SLOW margin printed
  table       a slow table (README.md's, between its markers): the same reading
  anchor      TiffinBox on PostgreSQL, B / A / A': ready, HHH000001 once, ERROR 0; the generator counted back; the indexes (B the
              primary key alone, A and A' the new index too); the lazy collection's statement as the ways capture read it; B's plan
              a sequential scan, A's the new index, A' = A; GET /dashboard 200 on each with the same SQL line count"""
import re
import sys

mode, files = sys.argv[1], sys.argv[2:]
VALS = []


def need(ok, what):
    print(("  ok    " if ok else "  FAIL  ") + what)
    if not ok:
        sys.exit(1)


def read(f):
    return open(f, encoding="utf-8").read()


VERS = ["  PROBE Hibernate ORM core version (org.hibernate.Version.getVersionString()): 7.4.13.Final",
        "  PROBE Spring Data JPA version (JpaRepository.class.getPackage().getImplementationVersion()): 4.1.2",
        "  PROBE Spring Framework version (Transactional.class.getPackage().getImplementationVersion()): 7.0.10"]
HHH = "  INFO  [main] org.hibernate.orm.core : HHH000001: Hibernate ORM core version 7.4.13.Final"
CNT = re.compile(r"^  PROBE counts: statements: Statistics\.getPrepareStatementCount (\d+) · org\.hibernate\.SQL lines (\d+) · JDBC proxy prepareStatement (\d+)$")


def jvms(t, main="probe.q.Main"):
    """The capture cut at each JVM's command line: a list of (the JVM's lines)."""
    out, cur = [], None
    for line in t.splitlines():
        if line.startswith("$ cd .harness/run && ") and main in line:
            cur = [line]; out.append(cur)
        elif line.startswith("$ cd ") or line.startswith("$ DB="):
            cur = None
        elif cur is not None:
            cur.append(line)
    return out


def vers(b, core=True):
    for v in VERS:
        need(b.count(v) == 1, "the version line once in the JVM: %s" % v.strip())
    need(b.count(HHH) == (1 if core else 0), "HHH000001 %s" % ("once in the JVM" if core else "absent - every org.hibernate logger off"))


def one(b, rx, what):
    m = [re.match(rx, l) for l in b]
    m = [x for x in m if x]
    need(len(m) == 1, what)
    return m[0]


def inside(b):
    out, f = [], False
    for l in b:
        if l.startswith("  PROBE >>> "): f = True; continue
        if l.startswith("  PROBE <<< "): f = False
        if f: out.append(l)
    return out


def counts(b, sql):
    m = one(b, CNT, "the read's counts printed once")
    a, s, p = (int(x) for x in m.groups())
    need(a == p and a > 0 and s == sql(a), "the witnesses: Statistics.getPrepareStatementCount %d = the proxy's prepareStatement %d; the SQL logger's events %d" % (a, p, s))
    return a


def offlog(b, k):
    m = one(b, r"^  read off its log - org\.hibernate logger lines in the whole log \(grep -cE '\^LEVEL \[thread\] org\.hibernate\.\.\.'\): (\d+) · org\.hibernate\.SQL lines inside the read's markers: (\d+) · bind lines \(org\.hibernate\.orm\.jdbc\.bind\) inside them: (\d+)$", "%s: the logger counts read off its log" % k)
    h = one(b, r"^  read off its log - 'Hibernate:' lines \(show-sql, stdout\) inside the read's markers: (\d+) · outside them: (\d+) \(of them create global temporary table HTE_: (\d+)\)$", "%s: show-sql's lines read off its log" % k)
    return [int(x) for x in m.groups()], [int(x) for x in h.groups()]


def key(b, k):
    m = one(b, r"^  PROBE key \(EntityManagerFactory\.getProperties\(\)\): %s = (\S+)$" % re.escape(k), "the key %s read off the EntityManagerFactory" % k)
    return m.group(1)


def exit0(b, what, want=0):
    m = one(b, r"^  its WARN lines \(grep -c '\^WARN '\): (\d+) · exit (\d+) · 'GenerationTarget encountered exception': (\d+)$", "%s: its exit line" % what)
    need(int(m.group(2)) == want and m.group(3) == "0", "%s: exit %s, no schema failure" % (what, m.group(2)))
    return int(m.group(1))


def level(b):
    return one(b, r"^  PROBE the level control: org\.hibernate\.SQL's effective level \(logback\) (\S+) · LoggerFactory\.getLogger\(\"org\.hibernate\.SQL\"\)\.isDebugEnabled\(\) (\S+) · org\.hibernate's effective level (\S+)$", "the level control printed").groups()


SQLL = re.compile(r"^  DEBUG \[main\] org\.hibernate\.SQL : ?(.*)$")

if mode in ("ways", "collection"):
    bl = jvms(read(files[0]))
    need(len(bl) == 6, "six JVMs in the ways capture")
    sh, of, lg, fm, hl, cm = bl
    if mode == "collection":
        sq = [SQLL.match(l).group(1) for l in inside(lg) if SQLL.match(l)]
        if len(sq) != 2:
            sys.exit(1)
        print(sq[1])
        sys.exit(0)
    sid = one(lg, r"^  PROBE Sunil's id, read off the second connection: (\d+) · her pauses there: (\[[\d, ]*\])$", "Sunil's id read off the second connection").groups()
    res = []
    for b, nm in ((sh, "(i)"), (of, "(ii)"), (lg, "(iii)"), (fm, "(iv)"), (hl, "(v)"), (cm, "(vi)")):
        vers(b, core=(b is not of))
        exit0(b, nm)
        r = one(b, r"^  PROBE result: (Sunil \[[\d, ]*\])$", "%s: the read's result" % nm).group(1)
        need(r == "Sunil " + sid[1], "%s: the read returns Sunil and her pauses, as the second connection reads them: %s" % (nm, r))
        res.append(r)
    # (i) show-sql
    n = counts(sh, lambda a: 0)
    (hlines, hsql, hbind), (hin, hout, hte) = offlog(sh, "(i)")
    need(hin == n and hsql == 0, "(i) show-sql: %d 'Hibernate:' lines between the read's markers = the statements %d; the SQL logger at WARN: 0 lines" % (hin, n))
    need(key(sh, "hibernate.show_sql") == "true", "(i) hibernate.show_sql = true, read off the EMF")
    need(hout == hte, "(i) the 'Hibernate:' lines outside the read are the HTE_ table lines at start (%d), named, not counted" % hte)
    shown = [l for l in inside(sh) if l.startswith("  Hibernate: ")]
    # (ii) the OFF run
    lv = level(of)
    n2 = counts(of, lambda a: 0)
    (olines, osql, obind), (oin, oout, ohte) = offlog(of, "(ii)")
    (llines, lsql, lbind), (lin, lout, lhte) = offlog(lg, "(iii)")
    need(lv == ("OFF", "false", "OFF"), "(ii) the control: org.hibernate.SQL's effective level OFF, isDebugEnabled() false, org.hibernate's level OFF - %s" % (lv,))
    need(olines == 0 and llines > 0, "(ii) the control: org.hibernate logger lines 0 in the OFF run, %d in (iii)" % llines)
    need(oin == n2 == n and [l for l in inside(of) if l.startswith("  Hibernate: ")] == shown, "(ii) show-sql still prints the read's %d lines between its markers, the same lines as (i)" % oin)
    need(key(of, "hibernate.show_sql") == "true", "(ii) hibernate.show_sql = true, read off the EMF")
    # (iii) the logger and the binds
    need(level(lg)[:2] == ("DEBUG", "true"), "(iii) org.hibernate.SQL at DEBUG")
    n3 = counts(lg, lambda a: a)
    sq = [SQLL.match(l).group(1) for l in inside(lg) if SQLL.match(l)]
    binds = [l.split(" : ", 1)[1] for l in inside(lg) if l.startswith("  TRACE [main] org.hibernate.orm.jdbc.bind : ")]
    need(lsql == n3 == len(sq) and lbind == len(binds) == n3 and lin == 0, "(iii) the SQL logger's %d statements, one bind line each, no show-sql line" % n3)
    need(binds == ["binding parameter (1:VARCHAR) <- [Sunil]", "binding parameter (1:BIGINT) <- [%s]" % sid[0]], "(iii) the binds: Sunil, then her id %s (the second connection's): %s" % (sid[0], binds))
    need(sq == [s[len("Hibernate: "):].strip() for s in [x.strip() for x in shown]], "(iii) the logger's texts = show-sql's texts")
    # (iv) format_sql
    need(key(fm, "hibernate.format_sql") == "true", "(iv) hibernate.format_sql = true, read off the EMF")
    counts(fm, lambda a: a)
    ins = inside(fm)
    i0 = next(i for i, l in enumerate(ins) if l.startswith("  DEBUG [main] org.hibernate.SQL :"))
    j = i0 + 1
    while j < len(ins) and not re.match(r"^  (PROBE|DEBUG|TRACE|INFO|WARN|ERROR) ", ins[j]): j += 1
    fl = j - i0
    need(fl > 2, "(iv) the first statement spans %d log lines (its logger line and the formatted SQL)" % fl)
    # (v) highlight_sql
    need(key(hl, "hibernate.highlight_sql") == "true", "(v) hibernate.highlight_sql = true, read off the EMF")
    counts(hl, lambda a: a)
    m = one(hl, r"^  its log FILE, \.harness/h\.log, read with grep: lines holding ESC\[34m \(grep -c\): (\d+) · ESC\[34m occurrences \(grep -o \| wc -l\): (\d+) · its first statement line through cat -v:$", "(v) the escapes counted in the log file")
    el, eo = int(m.group(1)), int(m.group(2))
    cv = hl[hl.index(m.group(0)) + 1]
    need(el > 0 and eo >= el and "^[[34m" in cv, "(v) ESC[34m: %d lines, %d occurrences in the log file; cat -v shows ^[[34m" % (el, eo))
    # (vi) use_sql_comments
    need(key(cm, "hibernate.use_sql_comments") == "true", "(vi) hibernate.use_sql_comments = true, read off the EMF")
    counts(cm, lambda a: a)
    cq = [SQLL.match(l).group(1) for l in inside(cm) if SQLL.match(l)]
    cmt = re.match(r"^(/\* .* \*/) ", cq[0]) if cq else None
    need(len(cq) == 2 and cmt is not None and "/*" not in cq[1], "(vi) a comment on the first statement, none on the collection's: %s" % (cmt.group(1) if cmt else cq))
    VALS.append("the one read (Sunil %s, her id %s) is %d statements - Statistics.getPrepareStatementCount = the proxy's prepareStatement, every way; (i) show-sql: %d 'Hibernate:' lines on stdout between the read's markers, no logger, no level, no binds (%d HTE_ lines at start, not counted); (ii) the OFF run (org.hibernate.SQL and org.hibernate OFF, no core level pinned): the same %d lines, beside its control - effective level OFF, isDebugEnabled() false, 0 org.hibernate logger lines where the ON run has %d; (iii) %s · %s; (iv) format_sql: the first statement over %d log lines; (v) highlight_sql: ESC[34m on %d lines of the log file, %d times; (vi) use_sql_comments: %s on the first statement, none on the collection's" % (
        sid[1], sid[0], n, hin, hte, oin, llines, binds[0], binds[1], fl, el, eo, cmt.group(1)))

elif mode == "spy":
    t = read(files[0]); L = t.splitlines()
    jars = re.findall(r"^  (\d+) (p6spy-3\.9\.1\.jar|datasource-proxy-1\.11\.1\.jar)$", t, re.M)
    need("  p6spy:p6spy:jar:3.9.1:compile" in L and "  net.ttddyy:datasource-proxy:jar:1.11.1:compile" in L and len(jars) == 2, "dependency:list names p6spy 3.9.1 and datasource-proxy 1.11.1; ls -l prints both jars")
    bl = jvms(t)
    need(len(bl) == 3, "three JVMs: H2 without the user name, H2 with it, PostgreSQL")
    f, x, p = bl
    vers(f); vers(x); vers(p)
    need(any(l == "  PROBE Boot's pool (HikariDataSource): driver class com.p6spy.engine.spy.P6SpyDriver · user name (getUsername()) null" for l in f), "the failing start: Boot's pool on p6spy's driver, its user name null (the URL does not look embedded)")
    m = one(f, r"^  its WARN lines \(grep -c '\^WARN '\): (\d+) · exit (\d+) · 'GenerationTarget encountered exception': (\d+)$", "the failing start's exit line")
    q = "Wrong user name or password [28000-250]"
    need(m.group(2) == "1" and ("  the failing start's step - exit 1 · its line (grep -o): " + q) in f and any(q in l and l.startswith("  PROBE ") for l in f), "the failing start: exit 1, '%s' grepped from its own log and in its chain" % q)
    need(any(l == "  PROBE Boot's pool (HikariDataSource): driver class com.p6spy.engine.spy.P6SpyDriver · user name (getUsername()) sa" for l in x), "the fixed run: --spring.datasource.username=sa reaches the pool")
    need(exit0(x, "the fixed run") == 0 and "  JVM warnings on its stderr (grep -c '^WARNING'): 0" in x, "the fixed run: 0 WARN lines, 0 JVM warnings")
    def spyread(b, what):
        h = max(i for i, l in enumerate(b) if l.startswith("  spy.log - lines: "))
        r = [l.strip() for l in b[h + 1:h + 3] if re.match(r"^    <time>\|<ms>\|statement\|connection <n>\|url jdbc:p6spy:", l)]
        need(len(r) == 2 and r[0].endswith("where ce1_0.name='Sunil'") and re.search(r"where p1_0\.customer_id=\d+$", r[1]), "%s: spy.log's two statements, the binds inlined: name='Sunil', customer_id=<her id>" % what)
        return r
    rx = spyread(x, "H2")
    sid = one(x, r"^  PROBE Sunil's id, read off the second connection: (\d+) ", "Sunil's id").group(1)
    need(rx[1].endswith("customer_id=" + sid), "H2: the inlined id is Sunil's, as the second connection reads it (%s)" % sid)
    m = one(p, r"^  spy\.log, raw, before the mask: lines holding the generated password (\d+) of (\d+)$", "PostgreSQL: the raw count")
    pw, tot = int(m.group(1)), int(m.group(2))
    need(pw == tot > 0, "PostgreSQL: every spy.log line held the password, raw: %d of %d" % (pw, tot))
    need("  masked into .harness/spy-pg.masked.log; raw copies after the mask: 0 · the raw file deleted: spy.log under .harness now 0 · git check-ignore spy.log: ignored" in p, "PostgreSQL: 0 raw copies after the mask, the file deleted, spy.log ignored by git")
    fl = p[p.index("  one masked line in full (the first):") + 1]
    need("?user=sa&password=<pw>|" in fl and fl.startswith("    <time>|<ms>|"), "PostgreSQL: a masked line carries the URL with password=<pw>")
    rp = spyread(p, "PostgreSQL")
    need(exit0(p, "PostgreSQL") == 0, "PostgreSQL: 0 WARN lines")
    VALS.append("p6spy 3.9.1 (%s bytes, printed by ls -l); on H2 the URL jdbc:p6spy:h2:… without a user name: exit 1, '%s', Boot's pool user name null - with --spring.datasource.username=sa it runs (0 WARN, 0 JVM warnings) and spy.log writes each statement with its binds inlined: …%s · …%s; on PostgreSQL every spy.log line carries the URL with the password: %d of %d raw, 0 after the mask, the file deleted" % (
        [b for b, n in jars if n.startswith("p6spy")][0], q, rx[0][rx[0].rindex("where "):], rx[1][rx[1].rindex("where "):], pw, tot))

elif mode == "dsproxy":
    t = read(files[0]); L = t.splitlines()
    bl = jvms(t)
    need(len(bl) == 1, "one JVM")
    b = bl[0]; vers(b); exit0(b, "dsproxy")
    n = counts(b, lambda a: a)
    ins = [l for l in inside(b) if "SLF4JQueryLoggingListener : Name:tiffinbox" in l]
    need(len(ins) == n, "datasource-proxy's lines inside the read: %d = the statements" % len(ins))
    need(all(", Connection:<n>, Time:<ms>, Success:True, Type:Prepared, Batch:False, QuerySize:1, BatchSize:0, Query:[" in l for l in ins), "each line: Connection and Time masked, Success, Prepared, one query")
    need(ins[0].endswith("where ce1_0.name=?\"], Params:[(Sunil)]"), "the first line: the query with its ? and Params:[(Sunil)]")
    m = one(b, r"^  read off its log - datasource-proxy's lines inside the read's markers: (\d+) · 'jdbc:' in all its lines: (\d+)$", "the counts read off its log")
    need(int(m.group(1)) == n and m.group(2) == "0", "no URL in its lines: 'jdbc:' 0")
    m2 = one(b, r"^  Spring Boot 4\.1\.2's BOM .*: (\d+)$", "the BOM's grep")
    need(m2.group(1) == "0", "the BOM names neither tool: 0 lines")
    jb = re.search(r"\.harness/tools: (\d+) datasource-proxy-1\.11\.1\.jar\)", t)
    need(jb is not None, "its jar named and sized (ls -l)")
    VALS.append("datasource-proxy 1.11.1 (%s bytes): %d lines in the read, e.g. …%s - 'jdbc:' 0 in its lines; Boot 4.1.2's BOM names neither tool (0 lines)" % (
        jb.group(1), n, ins[0][ins[0].index("Query:["):]))

elif mode in ("slow", "table"):
    def table(rows, T, cfg, what):
        db = {}
        for r in rows:
            db.setdefault(r[0], []).append(r)
        need(sorted(db) == ["H2", "PostgreSQL"], "%s: rows for H2 and PostgreSQL" % what)
        for k, v in db.items():
            need(len(v) >= 10, "%s: %d JVMs on %s - at least ten per database (R.236)" % (what, len(v), k))
        pgs = [r[1] for r in db["PostgreSQL"]]
        bad = [x for x in pgs if not x >= T]
        need(not bad, "%s: every PostgreSQL ratio without / with the index >= T = %g (below it: %s)" % (what, T, bad))
        k0 = [r[2] for r in db["PostgreSQL"]]; k1 = [r[3] for r in db["PostgreSQL"]]
        need(all(r[2] > 0 and r[2] > r[3] for r in db["PostgreSQL"]), "%s: PostgreSQL's SQL_SLOW lines: more than 0 without the index, and more without than with, in every JVM" % what)
        mins = [r[4] for r in db["PostgreSQL"]]
        need(all(m > cfg for m in mins), "%s: every PostgreSQL SQL_SLOW line's time above the configured %d" % (what, cfg))
        lo = min(pgs)
        print("  %s: JVMs per database H2 %d · PostgreSQL %d; PostgreSQL ratio without / with the index %.2f-%.2f, T = %g, the margin (the smallest - T) %.2f; H2 %.2f-%.2f (numbers on the chip, no threshold); SQL_SLOW at a configured %d ms on PostgreSQL: %d-%d lines without, %d-%d with, the smallest logged time %d; on H2 %d-%d without, %d-%d with" % (
            what, len(db["H2"]), len(db["PostgreSQL"]), lo, max(pgs), T, lo - T, min(r[1] for r in db["H2"]), max(r[1] for r in db["H2"]), cfg, min(k0), max(k0), min(k1), max(k1), min(mins),
            min(r[2] for r in db["H2"]), max(r[2] for r in db["H2"]), min(r[3] for r in db["H2"]), max(r[3] for r in db["H2"])))
        return db, lo, min(mins), min(k0), max(k0)

    if mode == "table":
        T = float(files[1]); cfg = int(files[2])
        rows = []
        for l in read(files[0]).splitlines():
            m = re.match(r"^\| (H2|PostgreSQL) \| (\d) \| (\d+) \| (\d+\.\d\d) \| ([\d.]+) · ([\d.]+) \| (\d+) · (\d+) \| (\d+|none) \|$", l)
            if m: rows.append((m.group(1), float(m.group(4)), int(m.group(7)), int(m.group(8)), int(m.group(9)) if m.group(9) != "none" else 10 ** 9))
        db, lo, mn, a, b = table(rows, T, cfg, "the table")
        tx = read(files[0])
        mg = re.search(r"^margin: the smallest PostgreSQL ratio without / with the index (\d+\.\d\d) - T (\d+) = (\d+\.\d\d)$", tx, re.M)
        need(mg is not None and float(mg.group(1)) == lo and float(mg.group(2)) == T and abs(float(mg.group(3)) - (lo - T)) < 0.005, "the table's margin line = the smallest PostgreSQL ratio - T")
        ms = re.search(r"^SQL_SLOW margin: the smallest time a SQL_SLOW line reported on PostgreSQL, without the index, (\d+) - the configured (\d+) = (\d+)$", tx, re.M)
        need(ms is not None and int(ms.group(1)) == mn and int(ms.group(2)) == cfg and int(ms.group(3)) == mn - cfg, "the table's SQL_SLOW margin line = the smallest logged time - the configured value")
    else:
        t = read(files[0]); T = float(files[2]); TJ = int(files[3]); cfg = int(files[4])
        bl = jvms(t)
        need(len(bl) == 2 * TJ, "%d JVMs in the capture run: %d per database" % (len(bl), TJ))
        plans = {}; dbs = []; facts = {}
        for b in bl:
            vers(b)
            d = one(b, r"^  PROBE database: (H2 [\d.]+|PostgreSQL [\d.]+) \|", "the database line").group(1)
            k = d.split()[0]; dbs.append(k)
            need(key(b, "hibernate.log_slow_query") == str(cfg), "%s: hibernate.log_slow_query = %d, read off the EntityManagerFactory (R.201)" % (k, cfg))
            made = one(b, r"^  PROBE indexes on pause as the shipped Database \(34/after\) made them: (\[.*\])$", "%s: the indexes as made" % k).group(1)
            rs = one(b, r"^  PROBE the shipped Database's createAndSeed\(\) run once more on this database \(its DROP TABLE first, the index there\): returned · customers (\d+) · pauses (\d+) · indexes on pause: (\[.*\])$", "%s: the seed run twice" % k)
            need(rs.group(3) == made, "%s: the seed run a second time on the same database returns, the same indexes - DROP TABLE drops the index with its table" % k)
            g = one(b, r"^  PROBE generated \(the second connection, one transaction\): (\d+) customers 'Customer 0000001'\.\.\., (\d+) pauses each · counted back: customers (\d+) · pauses (\d+)$", "%s: the generator" % k)
            n, kk, c, p = (int(x) for x in g.groups())
            need(c == int(rs.group(1)) + n and p == int(rs.group(2)) + n * kk, "%s: counted back %d customers = %s + %d, %d pauses = %s + %d x %d" % (k, c, rs.group(1), n, p, rs.group(2), n, kk))
            st = one(b, r"^  PROBE the lookup's statement \(org\.hibernate\.SQL, read off the logger once, then back to WARN\): (select .* where pe1_0\.customer_id=\?) · statements in that lookup: 1$", "%s: the statement read off the logger" % k).group(1)
            des = one(b, r"^  PROBE design: customers (\d+) · pauses (\d+) · M (\d+) lookups per half · W (\d+) warm-up rounds · R (\d+) timed · each round without and with the index, the order reversed every other round · hibernate\.log_slow_query (\d+) \(read off the EntityManagerFactory\) · the counting proxy and Statistics on in both halves$", "%s: the design line" % k)
            M, W, R = int(des.group(3)), int(des.group(4)), int(des.group(5))
            need(int(des.group(1)) == c and int(des.group(2)) == p, "%s: the design names the counted-back rows" % k)
            ords = [re.match(r"^  PROBE round (\d+) \((warm-up|timed)\) order: (without, with|with, without)$", l) for l in b if l.startswith("  PROBE round ")]
            need(len(ords) == W + R and all(o and int(o.group(1)) == i and o.group(2) == ("warm-up" if i < W else "timed") for i, o in enumerate(ords)), "%s: %d rounds printed, W warm-up then R timed" % (k, W + R))
            need(all(o.group(3) == ("without, with" if i % 2 == 0 else "with, without") for i, o in enumerate(ords)), "%s: R.300 - even rounds without -> with, odd rounds with -> without" % k)
            ck = one(b, r"^  PROBE every lookup's rows checked \(count = the second connection's for that customer, every row's customer the id\): (\d+) lookups, (\d+) rows$", "%s: every lookup checked" % k)
            need(int(ck.group(1)) == (W + R) * 2 * M, "%s: %s lookups checked = (W + R) x 2 x M" % (k, ck.group(1)))
            wo = one(b, r"^  PROBE indexes on pause without the index: (\[.*\])$", "%s: indexes without" % k).group(1)
            wi = one(b, r"^  PROBE indexes on pause with the index: (\[.*\])$", "%s: indexes with" % k).group(1)
            end = one(b, r"^  PROBE indexes on pause at the end: (\[.*\])$", "%s: indexes at the end" % k).group(1)
            pid = one(b, r"^  PROBE the plans' id: select id from customer where name = 'Customer 0001000' -> (\d+)$", "%s: the plans' id" % k).group(1)
            pw = [l[len("  PROBE plan without the index: "):] for l in b if l.startswith("  PROBE plan without the index: ")]
            pi = [l[len("  PROBE plan with the index: "):] for l in b if l.startswith("  PROBE plan with the index: ")]
            wl = wo.strip("[]").split(", "); il = wi.strip("[]").split(", ")
            if k == "PostgreSQL":
                need(wl == ["pause_pkey"] and il == ["pause_customer_id_idx", "pause_pkey"] and made == wi, "PostgreSQL: pg_indexes on pause - without %s, with %s (as the shipped Database made them)" % (wo, wi))
                rm = [re.search(r"Rows Removed by Filter: (\d+)", l) for l in pw]
                rm = [int(x.group(1)) for x in rm if x]
                need(pw and pw[0].startswith("Seq Scan on pause pe1_0") and any(l.strip() == "Filter: (customer_id = %s)" % pid for l in pw) and rm == [p - kk], "PostgreSQL without: Seq Scan on pause, Filter on the id %s, Rows Removed by Filter = the pauses %d - her %d" % (pid, p, kk))
                need(any("Index Scan on pause_customer_id_idx" in l or "Index Scan using pause_customer_id_idx" in l for l in pi) and not any("Seq Scan" in l for l in pi), "PostgreSQL with: the new index scanned, no sequential scan: %s" % " | ".join(x.strip() for x in pi))
                need(not any("cost=" in l for l in pw + pi), "R.245: no cost in either plan")
                need(any(re.match(r"^  exit 0 · on PostgreSQL, JVM \d+: ratio >= %d: true$" % T, l) for l in b), "PostgreSQL: the threshold line, ratio >= %d: true" % T)
                need("  PROBE org.hibernate.SQL_SLOW lines over the timed rounds, without the index and with it: counted, to the table" in b, "PostgreSQL: the SQL_SLOW lines counted per half, to the table")
            else:
                new = [x for x in il if x not in wl]
                need(new == ["PAUSE_CUSTOMER_ID_IDX"] and len(wl) == 2 and any(x.startswith("CONSTRAINT_INDEX") for x in wl) and made == wi, "H2: INFORMATION_SCHEMA.INDEXES on PAUSE - without %s (its own constraint index), with %s" % (wo, wi))
                ci = [x for x in wl if x.startswith("CONSTRAINT_INDEX")][0]
                need(pw == pi and len(pw) == 1 and ("PUBLIC." + ci + ":") in pw[0], "H2: one plan both sides, its constraint index %s - the new index unused" % ci)
                need(any(re.match(r"^  exit 0 · on H2, JVM \d+: its ratio goes to the table as a number - no threshold on H2 \(S5\.11\)$", l) for l in b), "H2: no threshold, its ratio to the table")
                need("  PROBE org.hibernate.SQL_SLOW lines over the timed rounds, without the index and with it: counted, to the table" in b, "H2: the SQL_SLOW lines counted per half, to the table")
            last = ords[-1].group(3).split(", ")[1]
            need(end == (wi if last == "with" else wo), "%s: the indexes at the end are the last half's (%s the index)" % (k, last))
            need(sum(1 for l in b if re.match(r"^  PROBE timed (without|with) the index \(ms\): \[<masked>\]$", l)) == 2 and "  PROBE median (ms): without <ms> · with <ms>" in b and "  PROBE ratio without / with the index: <ratio>" in b, "%s: the timed values, the medians and the ratio printed and masked" % k)
            plans.setdefault(k, set()).add(("\n".join(pw), "\n".join(pi)))
            facts[k] = (wo, wi, pw, pi, st, n, kk, c, p, M, W, R, pid)
        need(dbs == ["H2", "PostgreSQL"] * TJ, "H2 and PostgreSQL in turn, JVM by JVM")
        need(all(len(v) == 1 for v in plans.values()), "every JVM of a database prints the same plan pair (%s)" % ", ".join("%s %d" % (k, len(v)) for k, v in plans.items()))
        rows = []
        md = ["| database | capture run | JVM | ratio without / with | medians (ms): without · with | SQL_SLOW lines: without · with | smallest logged time (ms) |", "|---|---|---|---|---|---|---|"]
        for l in read(files[1]).splitlines():
            m = re.match(r"^(H2|PostgreSQL) · capture run (\d) · JVM (\d+) · ratio without / with the index: (\d+\.\d\d) · median \(ms\): without ([\d.]+) · with ([\d.]+) · SQL_SLOW lines \(timed rounds\): without (\d+) · with (\d+) · smallest logged time \(ms\): without (\d+|none) · with (\d+|none)$", l)
            if m:
                rows.append((m.group(1), float(m.group(4)), int(m.group(7)), int(m.group(8)), int(m.group(9)) if m.group(9) != "none" else 10 ** 9))
                md.append("| %s | %s | %s | %s | %s · %s | %s · %s | %s |" % m.groups()[:9])
        db, lo, mn, k0a, k0b = table(rows, T, cfg, "this run's table (.r-slow.table)")
        md.append("")
        md.append("margin: the smallest PostgreSQL ratio without / with the index %.2f - T %d = %.2f" % (lo, T, lo - T))
        md.append("SQL_SLOW margin: the smallest time a SQL_SLOW line reported on PostgreSQL, without the index, %d - the configured %d = %d" % (mn, cfg, mn - cfg))
        for l in read(files[1]).splitlines():
            if l.startswith("capture run "): md.append("load average, " + l)
        open(files[1] + ".md", "w", encoding="utf-8").write("\n".join(md) + "\n")
        P, Hh = facts["PostgreSQL"], facts["H2"]
        VALS.append("the fixed design: the seed and %d generated customers with %d pauses each (%d customers, %d pauses, counted back), M %d lookups per half, W %d warm-up rounds, R %d timed, each round without and with the index, the order reversed every other round; %d JVMs per database per capture run, %d per database in the three runs; the lookup's statement %s; on PostgreSQL pg_indexes %s -> %s, the plan without: %s, with: %s; on PostgreSQL ratio >= %d: true in every JVM, on this Mac; on H2 %s -> %s, one plan both sides (%s) - H2's ratios numbers on the chip, no threshold; SQL_SLOW at a configured %d ms (hibernate.log_slow_query, read off the EMF): lines in every PostgreSQL JVM without the index, more than with it in each (the counts tabled) - a chip, never a verdict" % (
            P[5], P[6], P[7], P[8], P[9], P[10], P[11], TJ, 3 * TJ, P[4], P[0], P[1], " · ".join(x.strip() for x in P[2] if "Seq Scan" in x or "Rows Removed" in x), " | ".join(x.strip().lstrip("-> ") for x in P[3] if "Index Scan" in x), T, Hh[0], Hh[1], re.search(r"/\* PUBLIC\.[^*]*\*/", Hh[2][0]).group(0), cfg))

elif mode == "anchor":
    t = read(files[0]); qc = files[1]; L = t.splitlines()
    need(qc.startswith("select ") and qc.endswith("customer_id=?"), "the lazy collection's statement, read off the ways capture: %s" % qc)
    parts = re.split(r"^(B|A|A2) - TiffinBox on PostgreSQL from ", t, flags=re.M)
    segs = {parts[i]: parts[i + 1].splitlines() for i in range(1, len(parts), 2)}
    need(sorted(segs) == ["A", "A2", "B"], "B, A and A' each ran")
    res = {}
    for nm in ("B", "A", "A2"):
        s = segs[nm]
        need("  GET /actuator/health/readiness -> 200" in s, "%s: ready on PostgreSQL" % nm)
        need("  its log, read off: HHH000001 lines 1 · ERROR lines 0" in s, "%s: HHH000001 once, ERROR 0" % nm)
        need(any(l.startswith("  PROBE database: PostgreSQL 18.6 |") for l in s), "%s: the second connection on PostgreSQL 18.6" % nm)
        b0 = one(s, r"^  PROBE before the generator \(TiffinBox's seed\): customers (\d+) · pauses (\d+)$", "%s: TiffinBox's seed" % nm)
        g = one(s, r"^  PROBE generated \(the second connection, one transaction\): (\d+) customers 'Customer 0000001'\.\.\., (\d+) pauses each · counted back: customers (\d+) · pauses (\d+)$", "%s: the generator" % nm)
        n, kk, c, p = (int(x) for x in g.groups())
        need(c == int(b0.group(1)) + n and p == int(b0.group(2)) + n * kk, "%s: counted back %d customers, %d pauses = the seed + the generator" % (nm, c, p))
        ix = one(s, r"^  PROBE indexes on pause \(pg_indexes\): (\[.*\])$", "%s: the indexes" % nm).group(1)
        need(("  PROBE the lazy collection's statement (read off the ways capture): " + qc) in s, "%s: the statement explained is the ways capture's" % nm)
        pid = one(s, r"^  PROBE the id: select id from customer where name = 'Customer 0001000' -> (\d+)$", "%s: the id" % nm).group(1)
        pl = [l[len("  PROBE plan: "):] for l in s if l.startswith("  PROBE plan: ")]
        dash = one(s, r"^  -> (\d+) · the page's rows \(<tr> lines\): (\d+) · the whole request's org\.hibernate\.SQL lines, between its two markers: (\d+) · WARN lines: (\d+) · ERROR lines: (\d+)$", "%s: GET /dashboard" % nm)
        need(dash.group(1) == "200" and dash.group(4) == "0" and dash.group(5) == "0", "%s: GET /dashboard -> 200, 0 WARN, 0 ERROR" % nm)
        need("  its log: the token 0 times, the password 0 times (raw, before the mask)" in s, "%s: its log holds neither the token nor the password" % nm)
        res[nm] = (ix, pl, dash.group(3), dash.group(2), c, p, kk, pid)
    ib, pb = res["B"][0], res["B"][1]
    rm = [int(m.group(1)) for m in (re.search(r"Rows Removed by Filter: (\d+)", l) for l in pb) if m]
    need(ib == "[pause_pkey]", "B: pg_indexes on pause - %s, the primary key alone" % ib)
    need(pb and pb[0].startswith("Seq Scan on pause ") and rm == [res["B"][5] - res["B"][6]], "B (the failure receipt): %s · Rows Removed by Filter %s = the pauses - hers" % (pb[0].strip() if pb else "-", rm))
    for nm in ("A", "A2"):
        need(res[nm][0] == "[pause_customer_id_idx, pause_pkey]", "%s: pg_indexes on pause - %s, the shipped Database made the index" % (nm, res[nm][0]))
        need(any("Index Scan on pause_customer_id_idx" in l or "Index Scan using pause_customer_id_idx" in l for l in res[nm][1]) and not any("Seq Scan" in l for l in res[nm][1]), "%s: the plan reads pause_customer_id_idx" % nm)
    need(res["A"][1] == res["A2"][1] and res["A"][0] == res["A2"][0], "A' = A: the same index list and plan")
    need(not any("cost=" in l for l in pb + res["A"][1]), "R.245: no cost in the plans")
    need(res["B"][2] == res["A"][2] == res["A2"][2] and res["B"][3] == res["A"][3], "GET /dashboard: the same SQL lines on B, A and A' (%s) and the same rows" % res["B"][2])
    VALS.append("TiffinBox on PostgreSQL with %d customers and %d pauses (its seed + the generator, counted back): B (before/) pg_indexes %s, the lazy collection's statement explained: %s · Rows Removed by Filter: %d; A (after/) %s, %s; A' = A; GET /dashboard 200 on each, %s SQL lines in the whole request (the fourth read is one statement since the fetch plan moved into the anchor)" % (
        res["B"][4], res["B"][5], ib, pb[0].strip(), rm[0], res["A"][0], " | ".join(x.strip() for x in res["A"][1] if "Index Scan" in x), res["B"][2]))

else:
    need(False, "no such mode: %s" % mode)

if VALS:
    print("VALUES " + " · ".join(VALS))
