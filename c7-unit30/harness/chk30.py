"""The checks after each capture (python3 -I harness/chk30.py MODE CAPTURE [options]): every number the video says is read off the
capture here and compared with another witness of the same run - never with a typed figure. Each check prints its verdict and the
values it read (lines "VALUES ..."), and exits 1 when it fails. The statement counter is named on the command line (--counter): the
receipt passes Statistics.getPrepareStatementCount, the counter unit 39 asserts (S5.1); any other counter must fail here.

  count    the page's read at two N, the three witnesses per N, Statistics' other counters beside them, the derived line
           "statements = a + b x customers" from the TWO points (R.249), the count of queries the same at both N and not the statement
           count (the failure receipt, S5.1); the session-metrics block of the read-only read (--ro LABEL): its preparing/executing
           figures = the statement count, no flush; the labelled read-write control: its flush line, its entities and collections =
           Statistics' entity loads and collection fetches (RE-MEASURE 12)
  inverse  every pause, then its customer: 1 + one per pause, at both N, Statistics.getEntityFetchCount = the pauses
  nested   unit 19's nested projection: 1 + one per customer at both N (S3's CARRIED "1 + N")
  sql      the statement texts read off the SQL logger, each shown once, its repeats counted
  table    an HTML dashboard: the table, its "Paused days" column found by its header (prints one line; the page check reads it)
  page     TiffinBox: the import, the dashboard (HTML and JSON) per request and the read's own session, GET /customers, the second
           connection; A' the same as A
"""
import json
import re
import sys

COUNTER = "Statistics.getPrepareStatementCount"
args = sys.argv[1:]
if "--counter" in args:
    i = args.index("--counter"); COUNTER = args[i + 1]; del args[i:i + 2]
RO = None
if "--ro" in args:
    i = args.index("--ro"); RO = args[i + 1]; del args[i:i + 2]
mode, path = args[0], args[1]
text = open(path, encoding="utf-8").read() if mode != "table" else ""
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


VERS = ["  PROBE Hibernate ORM core version (org.hibernate.Version.getVersionString()): 7.4.13.Final",
        "  INFO  [main] org.hibernate.orm.core : HHH000001: Hibernate ORM core version 7.4.13.Final",
        "  PROBE Spring Data JPA version (JpaRepository.class.getPackage().getImplementationVersion()): 4.1.2",
        "  PROBE Spring Framework version (Transactional.class.getPackage().getImplementationVersion()): 7.0.10",
        "  PROBE database: H2 2.5.250 | url jdbc:h2:mem:u30;DB_CLOSE_DELAY=-1",
        "  exit 0 · 'GenerationTarget encountered exception': 0"]


def sections(t, heads):
    """The capture cut at each line that starts with one of heads; {head: [its lines]}, in order."""
    out, cur = [], None
    for line in t.splitlines():
        h = next((x for x in heads if line.startswith(x)), None)
        if h is not None:
            cur = (line, []); out.append(cur)
        elif cur:
            cur[1].append(line)
    return out


def jvm(lines, what):
    for v in VERS:
        need(lines.count(v) == 1, "%s: the line once: %s" % (what, v.strip()))


def steps(lines):
    """[(label, [lines between '  PROBE >>> label' and '  PROBE <<< label'])]"""
    out, cur = [], None
    for line in lines:
        if line.startswith("  PROBE >>> "):
            cur = (line[len("  PROBE >>> "):], []); out.append(cur)
        elif line.startswith("  PROBE <<< "):
            cur = None
        elif cur:
            cur[1].append(line)
    return out


def counts(block):
    c = [l for l in block if l.startswith("  PROBE counts: ")]
    if len(c) != 1:
        return {}
    return {k: int(v) for k, v in re.findall(r"((?:Statistics\.\w+)|org\.hibernate\.SQL lines|JDBC proxy \w+) (\d+)", c[0])}


def generated(lines):
    for l in lines:
        m = re.match(r"  PROBE generated \(-Dn=(\d+)\): customers 'Customer 0000001'\.\.\., one pause each · the second connection reads: "
                     r"customers (\d+) · pauses (\d+)$", l)
        if m:
            return int(m.group(1)), int(m.group(2)), int(m.group(3))
    return None


def three(c, what):
    """The three witnesses (S5.1): the counter named on the command line, the SQL logger's lines, the proxy's prepareStatement - equal."""
    s = c.get(COUNTER, -1); q = c.get("org.hibernate.SQL lines", -2); p = c.get("JDBC proxy prepareStatement", -3)
    need(s == q == p, "%s: %s %d · org.hibernate.SQL lines %d · JDBC proxy prepareStatement %d - the three witnesses differ" % (what, COUNTER, s, q, p))
    need(c.get("JDBC proxy executeQuery") == p, "%s: the proxy's executeQuery %s = its prepareStatement %d" % (what, c.get("JDBC proxy executeQuery"), p))
    return s


def derive(points, what):
    """Two (x, y) points with different x -> (b, a) of y = a + b x, integers; fewer points, or one x, fail (R.249)."""
    xs = sorted(set(x for x, _ in points))
    if not need(len(points) == 2 and len(xs) == 2, "%s: the line needs two points at two N - got %d point(s), %d N" % (what, len(points), len(xs))):
        return None
    (x1, y1), (x2, y2) = sorted(points)
    if not need((y2 - y1) % (x2 - x1) == 0, "%s: the slope (%d - %d) / (%d - %d) is not whole" % (what, y2, y1, x2, x1)):
        return None
    b = (y2 - y1) // (x2 - x1); a = y1 - b * x1
    return a, b


WORD = {1: "one"}

if mode == "count":
    secs = sections(text, ["the page at -Dn=", "the session metrics at -Dn="])
    pages = [s for s in secs if s[0].startswith("the page at -Dn=")]
    pts, rows, qe = [], [], []
    for head, lines in pages:
        jvm(lines, head)
        g = generated(lines); st = steps(lines)
        if not need(g is not None and len(st) == 1, "%s: the generator's line and one step" % head):
            continue
        n, cust, pauses = g; c = counts(st[0][1])
        s = three(c, head)
        need(c.get("Statistics.getQueryExecutionCount", s) != s, "%s: the count of queries %s must not be the statement count %d (S5.1)" % (head, c.get("Statistics.getQueryExecutionCount"), s))
        need(c.get("Statistics.getCollectionFetchCount") == cust, "%s: collection fetches %s = the customers the second connection read %d" % (head, c.get("Statistics.getCollectionFetchCount"), cust))
        need(c.get("Statistics.getEntityLoadCount") == cust + pauses, "%s: entity loads %s = customers + pauses read by the second connection (%d + %d)" % (head, c.get("Statistics.getEntityLoadCount"), cust, pauses))
        pts.append((cust, s)); qe.append(c.get("Statistics.getQueryExecutionCount"))
        rows.append("at %d customers (-Dn=%d, the second connection's count): %s %d · org.hibernate.SQL lines %d · JDBC proxy prepareStatement %d · "
                    "executeQuery %d · Statistics.getQueryExecutionCount %d · Statistics.getCollectionFetchCount %d · Statistics.getEntityLoadCount %d"
                    % (cust, n, COUNTER, s, c["org.hibernate.SQL lines"], c["JDBC proxy prepareStatement"], c["JDBC proxy executeQuery"],
                       c["Statistics.getQueryExecutionCount"], c["Statistics.getCollectionFetchCount"], c["Statistics.getEntityLoadCount"]))
    need(len(set(qe)) == 1, "the count of queries must be the same at every N (S5.1): %s" % qe)
    ab = derive(pts, "count")
    derived = ""
    if ab:
        a, b = ab
        need(a == 1 and b == 1, "the derived line: statements = %d + %d x customers - expected one plus one per customer" % (a, b))
        derived = "derived from the two points %s: statements = %d + %d x customers (one plus one per customer)" % (
            " and ".join("(%d customers, %d statements)" % p for p in sorted(pts)), a, b)
    met = [s for s in secs if s[0].startswith("the session metrics at -Dn=")]
    mline = ""
    if need(len(met) == 1, "one session-metrics JVM"):
        head, lines = met[0]; jvm(lines, head)
        st = steps(lines); g = generated(lines)
        ro = [b for l, b in st if l == RO]; ctl = [b for l, b in st if l.startswith("the control, labelled: ")]
        if need(len(ro) == 1 and len(ctl) == 1 and g is not None, "the metrics JVM: the step '%s' and the labelled control" % RO):
            n, cust, pauses = g
            for name, blk in (("the read", ro[0]), ("the control", ctl[0])):
                c = counts(blk); s = three(c, "metrics, " + name)
                h = [l for l in blk if l.endswith("org.hibernate.session.metrics : HHH000401: Logging session metrics:")]
                need(len(h) == 1, "metrics, %s: one session-metrics block inside the step - %d" % (name, len(h)))
                need(("      <ns> ns preparing %d JDBC statements" % s) in blk and ("      <ns> ns executing %d JDBC statements" % s) in blk,
                     "metrics, %s: preparing / executing %d JDBC statements in its block" % (name, s))
                fl = [l.strip() for l in blk if re.match(r"      <ns> ns executing \d+ flushes ", l)]
                if name == "the read":
                    need(fl == ["<ns> ns executing 0 flushes (flushing a total of 0 entities and 0 collections)"],
                         "metrics, the read: no flush at its commit (RE-MEASURE 12) - its flush line: %s" % fl)
                    rof = fl; sro = s
                else:
                    want = "<ns> ns executing 1 flushes (flushing a total of %d entities and %d collections)" % (c.get("Statistics.getEntityLoadCount", -1), c.get("Statistics.getCollectionFetchCount", -1))
                    need(fl == [want], "metrics, the control: one flush of every entity and collection it loaded - %s, expected %s" % (fl, want))
                    ctf = fl
            if not fails:
                mline = ("the read-only read's session (HHH000401, %d customers): <ns> ns preparing %d JDBC statements · <ns> ns executing %d JDBC statements · %s; "
                         "the control (labelled, read-write): %s" % (cust, sro, sro, rof[0], ctf[0]))
    for r in rows:
        print("  " + r)
    if derived:
        print("  " + derived)
    if mline:
        print("  " + mline)
    done("count", " · ".join(rows) + " · " + derived + " · the count of queries %s at both N, the statement count moves with N" % (qe[0] if qe else "?") + " · " + mline)

if mode in ("inverse", "nested"):
    secs = sections(text, ["the %s at -Dn=" % mode])
    pts, rows = [], []
    for head, lines in secs:
        jvm(lines, head)
        g = generated(lines); st = steps(lines)
        if not need(g is not None and len(st) == 1, "%s: the generator's line and one step" % head):
            continue
        n, cust, pauses = g; label, blk = st[0]; c = counts(blk); s = three(c, head)
        res = [l for l in blk if l.startswith("  PROBE result: ")]
        if mode == "inverse":
            m = re.match(r"  PROBE result: (\d+) pauses · (\d+) customers named$", res[0]) if res else None
            if not need(m is not None, "%s: the result line" % head):
                continue
            need(int(m.group(1)) == pauses, "%s: the pauses read %s = the second connection's %d" % (head, m.group(1), pauses))
            need(c.get("Statistics.getEntityFetchCount") == pauses, "%s: entity fetches %s = the pauses %d - one SELECT by id per pause's customer" % (head, c.get("Statistics.getEntityFetchCount"), pauses))
            pts.append((pauses, s))
            rows.append("at %d pauses (%d customers, -Dn=%d): %s %d · org.hibernate.SQL lines %d · JDBC proxy prepareStatement %d · Statistics.getEntityFetchCount %d · Statistics.getQueryExecutionCount %d"
                        % (pauses, cust, n, COUNTER, s, c["org.hibernate.SQL lines"], c["JDBC proxy prepareStatement"], c["Statistics.getEntityFetchCount"], c["Statistics.getQueryExecutionCount"]))
        else:
            need(label.startswith("the nested projection: findAllProjectedByOrderByNameAsc() - WithPauses"), "%s: the step is the nested projection, not '%s'" % (head, label))
            need(c.get("Statistics.getCollectionFetchCount") == cust, "%s: collection fetches %s = the customers %d" % (head, c.get("Statistics.getCollectionFetchCount"), cust))
            need(c.get("Statistics.getEntityLoadCount") == cust + pauses, "%s: entity loads %s = customers + pauses (%d + %d) - it loads entities" % (head, c.get("Statistics.getEntityLoadCount"), cust, pauses))
            pts.append((cust, s))
            rows.append("at %d customers (-Dn=%d): %s %d · org.hibernate.SQL lines %d · JDBC proxy prepareStatement %d · Statistics.getCollectionFetchCount %d · Statistics.getEntityLoadCount %d"
                        % (cust, n, COUNTER, s, c["org.hibernate.SQL lines"], c["JDBC proxy prepareStatement"], c.get("Statistics.getCollectionFetchCount", -1), c.get("Statistics.getEntityLoadCount", -1)))
    ab = derive(pts, mode); derived = ""
    if ab:
        a, b = ab
        need(a == 1 and b == 1, "%s: statements = %d + %d x %s - expected one plus one per %s" % (mode, a, b, "pauses" if mode == "inverse" else "customers", "pause" if mode == "inverse" else "customer"))
        derived = "derived from the two points %s: statements = %d + %d x %s" % (" and ".join("(%d, %d)" % p for p in sorted(pts)), a, b, "pauses" if mode == "inverse" else "customers")
    for r in rows:
        print("  " + r)
    if derived:
        print("  " + derived)
    done(mode, " · ".join(rows) + " · " + derived)

if mode == "sql":
    g = generated(text.splitlines())
    tx = [l for l in text.splitlines() if re.match(r"  \d+ x (select|insert|update|delete) ", l)]
    need(g is not None and len(tx) == 2, "sql: the generator's line and two statement texts - %d texts" % len(tx))
    if not fails:
        n, cust, pauses = g
        (c1, t1), (c2, t2) = [(int(l.split(" x ", 1)[0]), l.split(" x ", 1)[1]) for l in tx]
        need(c1 == 1 and t1.startswith("select ce1_0.id,") and t1.endswith(" from customer ce1_0 order by ce1_0.name"), "sql: the list's text once: %d x %s" % (c1, t1))
        need(c2 == cust and t2.startswith("select p1_0.customer_id,") and t2.endswith(" from pause p1_0 where p1_0.customer_id=?"), "sql: the pauses' text once per customer (%d): %d x %s" % (cust, c2, t2))
        print("  the list's statement, once: %s" % t1)
        print("  the pauses' statement, sent %d x (one per customer, %d customers): %s" % (c2, cust, t2))
        done("sql", "the list's statement (sent 1 x): %s · the pauses' statement (sent %d x, one per customer): %s" % (t1, c2, t2))
    done("sql", "")

if mode == "table":
    html = open(path, encoding="utf-8").read()
    rows = re.findall(r"<tr>(.*?)</tr>", html, re.S)
    if not rows or "<th>Paused days</th>" not in rows[0]:
        print("  the table: no Paused days header"); sys.exit(1)
    head = re.findall(r"<th>(.*?)</th>", rows[0]); col = head.index("Paused days")
    cells = [re.findall(r"<td>(.*?)</td>", r) for r in rows[1:]]
    seeded = [(c[0], c[col]) for c in cells if not c[0].startswith("Customer ")]
    imp = [c[col] for c in cells if c[0].startswith("Customer ")]
    print("  the table: the header 'Paused days' is column %d · rows %d · the seeded customers: %s · the imported ('Customer …'): %d, Paused days %s"
          % (col + 1, len(cells), " · ".join("%s %s" % p for p in seeded), len(imp), " ".join(sorted(set(imp))) or "none"))
    sys.exit(0)

if mode == "page":
    secs = sections(text, ["page - ", "A2 - "])
    keyed = {}
    for head, lines in secs:
        t = "\n".join(lines); k = head.split(" - ")[0]; keyed[k] = lines

        def segs(after):
            """The seg30 lines printed after the line 'after' (a request's echo), up to the next '$ ' line."""
            i = lines.index(after) if after in lines else -1
            out = []
            for l in lines[i + 1:] if i >= 0 else []:
                if l.startswith("$ ") or l.startswith("the "):
                    break
                out.append(l)
            return out
        reqs = [l for l in lines if l.startswith("$ curl ")]
        need(len(reqs) == 4, "%s: four requests - %d" % (k, len(reqs)))
        if len(reqs) != 4:
            continue
        imp, dh, dj, cu = [segs(r) for r in reqs]
        sec = [l for l in lines if re.match(r"^  \d+$", l)]
        need(len(sec) == 2, "%s: the second connection's two counts" % k)
        if len(sec) != 2:
            continue
        cust2, pause2 = int(sec[0]), int(sec[1])
        m = re.match(r'  -> 200 \{"file":"import\.csv","added":(\d+),"refused":\{\}\}$', imp[0]) if imp else None
        if not need(m is not None, "%s: the import's answer 200, added N, refused none" % k):
            continue
        added = int(m.group(1))
        gl = [l for l in lines if l.startswith("  the generated file: ")]
        need(gl == ["  the generated file: .harness/import.csv - a header and %d lines (wc -l: %d)" % (added, added + 1)], "%s: the generated file's lines = added %d: %s" % (k, added, gl))
        need("  between its markers: SQL lines %d (INSERTs into customer %d) · WARN lines 0 · ERROR lines 0" % (added, added) in imp, "%s: the import - one INSERT per line added (%d)" % (k, added))
        need(any(l.startswith("  session-metrics blocks (HHH000401) it closed: %d · " % added) for l in imp), "%s: the import - one session per line added" % k)
        dash = {}
        for name, blk in (("html", dh), ("json", dj)):
            need(blk[:1] == ["  -> 200"], "%s: the dashboard (%s) 200" % (k, name))
            sl = [re.match(r"  between its markers: SQL lines (\d+) \(INSERTs into customer 0\) · WARN lines 0 · ERROR lines 0$", l) for l in blk]
            sl = [x for x in sl if x]
            ms = [re.match(r"  session-metrics blocks \(HHH000401\) it closed: (\d+) · their 'preparing N JDBC statements', N by N: (.*)$", l) for l in blk]
            ms = [x for x in ms if x]
            rd = [re.match(r"  the read's session - .*: SQL lines (\d+) · 'Participating in existing transaction' (\d+) · the block", l) for l in blk]
            rd = [x for x in rd if x]
            if not need(len(sl) == 1 and len(ms) == 1 and len(rd) == 1, "%s: the dashboard (%s): its SQL lines, its sessions and the read's session bound" % (k, name)):
                continue
            req = int(sl[0].group(1)); nsess = int(ms[0].group(1))
            per = []
            for part in ms[0].group(2).split(" · "):
                v, c = part.split(" x"); per += [int(v)] * int(c)
            readsql = int(rd[0].group(1))
            prep = [re.match(r"    <ns> ns preparing (\d+) JDBC statements$", l) for l in blk]
            prep = [int(x.group(1)) for x in prep if x]
            exe = [re.match(r"    <ns> ns executing (\d+) JDBC statements$", l) for l in blk]
            exe = [int(x.group(1)) for x in exe if x]
            fl = [l.strip() for l in blk if re.match(r"    <ns> ns executing \d+ flushes ", l)]
            need(len(prep) == 1 and prep == exe and prep[0] == readsql, "%s (%s): the read's block - preparing %s = executing %s = its thread's SQL lines %d" % (k, name, prep, exe, readsql))
            need(prep and prep[0] == 1 + cust2, "%s (%s): the read's session %s = 1 + the customers the second connection counts (%d)" % (k, name, prep, cust2))
            need(sum(per) == req and nsess == len(per), "%s (%s): the request's SQL lines %d = the sum over its %d sessions %s (S5.2: four reads, four sessions)" % (k, name, req, nsess, per))
            need(int(rd[0].group(2)) == 1, "%s (%s): findAll joins the read's transaction" % (k, name))
            need(fl == ["<ns> ns executing 0 flushes (flushing a total of 0 entities and 0 collections)"], "%s (%s): the read-only read flushes nothing: %s" % (k, name, fl))
            dash[name] = (req, nsess, prep[0] if prep else -1, per)
        need(len(dash) == 2 and dash.get("html") == dash.get("json"), "%s: the dashboard as HTML and as JSON - the same counts: %s" % (k, dash))
        tb = [l for l in dh if l.startswith("  the table: ")]
        tm = re.match(r"  the table: the header 'Paused days' is column (\d+) · rows (\d+) · the seeded customers: (.*) · the imported \('Customer …'\): (\d+), Paused days (\S+)$", tb[0]) if tb else None
        if need(tm is not None, "%s: the table line" % k):
            need(int(tm.group(2)) == cust2 and int(tm.group(4)) == added and tm.group(5) == "0", "%s: the table - %s rows = the second connection's %d, %s imported = added %d, each 0" % (k, tm.group(2), cust2, tm.group(4), added))
            sums = [re.match(r"^  ([A-Z][a-z]+) *\| *(\d+)$", l) for l in lines]
            sums = ["%s %s" % x.groups() for x in sums if x]
            need(len(sums) > 0 and tm.group(3) == " · ".join(sums), "%s: the seeded column %s = the second connection's sums %s" % (k, tm.group(3), sums))
            seeded = tm.group(3)
        jl = [l for l in dj if l.startswith("  the JSON (python3 -I): ")]
        need(jl == ["  the JSON (python3 -I): customers %d · names %d" % (cust2, cust2)], "%s: the JSON dashboard's customers and names = %d: %s" % (k, cust2, jl))
        need(cu[:1] == ["  -> 200 · entries parsed (python3 -I): %d" % cust2], "%s: GET /customers - %d entries: %s" % (k, cust2, cu[:1]))
        need("  between its markers: SQL lines 1 (INSERTs into customer 0) · WARN lines 0 · ERROR lines 0" in cu, "%s: GET /customers - one SQL line" % k)
        need(any(l.startswith("  stopped by its pid (SIGTERM): exit 143 · listening on ") for l in lines), "%s: stopped" % k)
        keyed[k + ":v"] = (added, dash, cust2, seeded if tm else "")
    if need("page" in keyed and "A2" in keyed, "page: A and A'"):
        norm = lambda ls: [re.sub(r"2009[01]", "<port>", re.sub(r"u30p2?", "<db>", re.sub(r"\.harness/anchor2?", ".harness/<tree>", l))) for l in ls]
        need(norm(keyed["page"]) == norm(keyed["A2"]), "A' (the anchor copied and built again) must print what A printed (R.1)")
    if fails:
        done("page", "")
    added, dash, cust2, seeded = keyed["page:v"]
    req, nsess, rd, per = dash["html"]
    print("  page: the import added %d (one INSERT and one session per line); the dashboard, HTML and JSON alike: %d SQL lines in the request "
          "(its %d sessions: %s), the read's own session %d (= 1 + %d customers); GET /customers 1 SQL line, %d entries; Paused days %s, the imported 0; A' the same"
          % (added, req, nsess, " ".join(map(str, per)), rd, cust2, cust2, seeded))
    done("page", "TiffinBox on H2 over TCP - POST /customers/import of %d generated lines -> 200, added %d, %d SQL lines during it (one INSERT each, IDENTITY); "
         "GET /dashboard (HTML and JSON) -> 200, %d SQL lines in the whole request (its sessions: %d, preparing %s), the read's own session (pausedDaysByCustomer): "
         "preparing %d JDBC statements, executing %d, no flush; GET /customers -> 200, 1 SQL line, %d entries; Paused days %s, every imported customer 0"
         % (added, added, added, req, nsess, " ".join(map(str, per)), rd, rd, cust2, seeded))

print("chk30: no mode " + mode)
sys.exit(2)
