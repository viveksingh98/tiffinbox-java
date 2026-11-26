#!/usr/bin/env python3
"""Course 9 unit 17's checker (python3 -I -B harness/chk17.py MODE ...), on chk16.py's shared machinery (ok / fail / need, the listing
parser that ends with a FAIL line and exit 1, never a traceback; hashable, static, gloss, hook, exq, interleaved, values, plants). Each
capture's check reads the capture's own lines and checks them against another witness of the same run (curl's size against the saved
file's bytes, the access log against curl's lines, the bills against monthlyBill's arithmetic over V2's rows, the counter's totals ...).
Prints "ok ..." / "FAIL ..." lines and one "VALUES k=v ..." line; exit 1 on any FAIL.

The self-contained rule (flag 31): static reads ONLY the unit's own frozen after/ and before trees, the committed receipts and git objects
pinned by a hash (git show c3bc1b2:PATH) - never the live ../c9-tiffinbox.

Modes: CAPTURE FILE (see CAPS) · hashable CAPTURE FILE (the capture minus its run-variant lines, those starting "  ~") · static AFTER BEFORE
(run in the unit's folder) · gloss README · gloss-line · hook · exq · interleaved · values README VALS · plants CAPDIR. Left out of this
unit: see LEFT_OUT - a capture of that name in this checker or in receipts.sh is a static failure."""
import hashlib, json, os, re, subprocess, sys

FAILS = []
VALS = {}
HASH16 = "c3bc1b2"
LEFT_OUT = ["star" + "ter", "jack" + "son", "h" + "al", "fin" + "al", "ne" + "xt", "forw" + "arded", "hal" + "gz", "fie" + "lds", "vi" + "ew",
            "m" + "jv", "flo" + "or", "gro" + "wn", "und" + "er", "pa" + "ge", "cli" + "ents", "ya" + "ml", "wa" + "lk", "page" + "able",
            "tr" + "ap", "ta" + "ble", "fi" + "rst", "cur" + "sor", "lite" + "ral"]
CAPS = ["advisory", "before", "change", "census", "accept", "poll", "bills", "restart", "double", "refuse", "specwire", "spec", "moved",
        "seven", "surface", "tests", "exercise", "inert"]
GLOSS = "A status resource: the address that tells you how the job is going."
BRIEF = os.path.join(os.environ.get("C9R", ""), "_briefs/UNIT-BRIEFS-S3-PAYLOADS.md")
BILLS = "Meera=4500 Priya=3600 Ravi=7200 Sunil=9000"
TYPE = "tag:tiffinbox.example,2026:"


def ok(m):
    print("ok " + m)


def fail(m):
    FAILS.append(m)
    print("FAIL " + m)


def need(cond, m):
    (ok if cond else fail)(m)
    return cond


def lines(f):
    return open(f, encoding="utf-8", errors="replace").read().splitlines()


def grab(ls, rx, what):
    """the first match of rx over the lines, or a FAIL line (never a traceback)"""
    for l in ls:
        m = re.search(rx, l)
        if m:
            return m
    fail("unparsable: no line for " + what)
    return None


def grab_all(ls, rx):
    return [m for m in (re.search(rx, l) for l in ls) if m]


def g1(ls, rx, what, default=""):
    m = grab(ls, rx, what)
    return m.group(1) if m else default


# ---- the captures -------------------------------------------------------------------------------------------------------------------------
def c_advisory(ls):
    need(g1(ls, r"^  fetched-at (\d{4}-\d{2}-\d{2})", "fetched-at") == g1(ls, r"run date (\d{4}-\d{2}-\d{2})", "run date"),
         "the read is the batch day's (fetched-at's date = the run's date)")
    m = grab(ls, r"MD5SUMS\.txt: (\d+) lines, (\d+) verified", "MD5SUMS")
    need(m is not None and m.group(1) == m.group(2) and int(m.group(1)) > 0, "MD5SUMS.txt: every line verified (%s)" % (str(m.groups()) if m else None))
    rows = g1(ls, r"spring rows (\d+)", "spring rows")
    need(rows == "25", "Spring's index: 25 rows (%s)" % rows)
    need(g1(ls, r"tomcat page md5 ([0-9a-f]{32})", "tomcat") == "a1a756d985225fb5143eefd9aae3183c", "Tomcat's page md5 a1a756d9")
    shipped = grab_all(ls, r"^  shipped \| (\S+) (\S+)$")
    need(len(shipped) >= 10 and all(s.group(2) for s in shipped), "the shipped tree's coordinates, each with its version (%d)" % len(shipped))
    need(any(l.strip() == "verdict: no pin affected; evidence may proceed; this unit adds no jar" for l in ls), "the verdict line")
    VALS["adv_rows"] = rows


def c_before(ls):
    p = g1(ls, r"before \| POST /api/v1/billing-runs -> (\d+)", "before POST")
    g = g1(ls, r"before \| GET /api/v1/billing-runs/<uuid> -> (\d+)", "before GET")
    need(p in ("404", "405") and g in ("404", "405"), "before: the new routes are not there (POST %s, GET %s)" % (p, g))
    o = grab(ls, r"before \| GET /api/v1/orders/1 -> (\d+) \S+ (\d+) · file (\d+) B", "before order 1")
    need(o is not None and o.group(1) == "200" and o.group(2) == o.group(3), "before: GET /api/v1/orders/1 200, curl's size = the file's bytes")
    need(g1(ls, r"before \| GET /api/v1/customers/Ravi -> (\d+)", "Ravi") == "200", "before: GET /api/v1/customers/Ravi 200")
    m = grab(ls, r"before \| mappings (\d+) · with billing in the path (\d+)", "mappings")
    need(m is not None and m.group(2) == "0", "before: no mapping with billing in its path")
    ops = grab(ls, r"before \| the committed spec: OPERATIONS (\d+) PATHS (\d+) · (\d+) B md5 ([0-9a-f]{32})", "before spec")
    need(ops is not None and (ops.group(1), ops.group(2), ops.group(3), ops.group(4)) == ("16", "14", "27247", "ab65420bdbf35b9b639ca94b22029ae9"),
         "before: the committed spec 16 operations / 14 paths, 27247 B ab65420b (checks, re-derived on this before)")
    lib = g1(ls, r"before \| BOOT-INF/lib names (\d+)", "lib")
    need(lib == "164", "before: BOOT-INF/lib 164 names (%s)" % lib)
    VALS["before_billing"] = "%s/%s" % (p, g)
    VALS["before_ops"] = "%s/%s" % (ops.group(1), ops.group(2)) if ops else "?"
    VALS["before_lib"] = lib
    VALS["before_mappings"] = m.group(1) if m else "?"


def c_change(ls):
    ch = g1(ls, r"changed \(derived[^)]*\): (.*)$", "changed")
    items = [x.strip() for x in ch.split("·") if x.strip()]
    allowed = {"A tiffinbox-web/src/main/java/com/tiffinbox/web/BillingRuns.java", "A tiffinbox-web/src/test/java/com/tiffinbox/web/BillingRunsTest.java",
               "M tiffinbox-web/src/test/resources/openapi/tiffinbox.json", "M README.md"}
    need(items and set(items) <= allowed, "the derived changed list is within the allowed four (%s)" % items)
    need(g1(ls, r"poms before -> after/: (.*)$", "poms") == "equal", "no pom differs")
    for k in ("JsonView", "MappingJacksonValue", "Pageable", "offset(", "Probe", "/probe/", "msPerCustomer"):
        need(g1(ls, r"src/main grep %s: (\d+) code lines" % re.escape(k), "grep " + k) == "0", "src/main holds no %s" % k)
    for h in ("startBillingRun", "billingRun"):
        need(g1(ls, r"handler %s: (\d+) occurrence" % h, h) == "1", "the handler %s occurs once among the mapped handlers" % h)
    for k in ("compression", "forward-headers", "hateoas", "billing", "pause"):
        need(g1(ls, r"application.yaml %s keys: before (\d+) · after (\d+)" % k, k) == "0", "application.yaml: no %s key before" % k)
        need(g1(ls, r"application.yaml %s keys: before \d+ · after (\d+)" % k, k) == "0", "application.yaml: no %s key after" % k)
    need(g1(ls, r"BillingRuns: (final class BillingRuns) \{", "final") == "final class BillingRuns", "BillingRuns is final (C7)")
    need(g1(ls, r"IdempotencyKeyFilter byte-equal to before's: (\w+)", "filter") == "yes", "IdempotencyKeyFilter byte-equal (C4 (a))")
    VALS["changed"] = str(len(items))


def c_census(ls):
    def tot(side):
        m = grab(ls, r"census %s \| controllers (\d+) · final, default-run (\d+) · not final, default-run (\d+) · not final, dev-only (\d+)" % side, side)
        return tuple(int(x) for x in m.groups()) if m else (0, 0, 0, 0)
    b, a = tot("before"), tot("after")
    rb = len(grab_all(ls, r"^  census before \| \w+ +final")); ra = len(grab_all(ls, r"^  census after \| \w+ +final"))
    need(b[0] == rb and a[0] == ra, "the census totals = its rows (before %d = %d, after %d = %d)" % (b[0], rb, a[0], ra))
    need(a[0] == b[0] + 1 and a[1] == b[1] + 1 and a[2:] == b[2:], "after = before + one final default-run controller (BillingRuns)")
    need(any("census after | BillingRuns" in l and "final yes" in l and "dev-only no" in l for l in ls), "BillingRuns' row: final, default-run")
    need(sum(1 for l in ls if "excluded by the rule: TiffinBoxErrors" in l) == 2, "the excluded line printed on both sides")
    VALS["census_before"] = "%d/%d/%d/%d" % b
    VALS["census_after"] = "%d/%d/%d/%d" % a


def c_accept(ls):
    m = grab(ls, r"^  accept \| delay=on \| POST /api/v1/billing-runs -> (\d+) (\S+) (\d+) · file (\d+) B · status line (.+?) · Location (\S+) · Retry-After (\S+) · state (\w+)", "the 202")
    if not m:
        return
    need(m.group(1) == "202", "the POST answers 202")
    need(m.group(5) == "HTTP/1.1 202 <none>", "Tomcat's status line has no reason phrase (%s)" % m.group(5))
    need(m.group(3) == m.group(4), "curl's size %s = the saved file's %s B" % (m.group(3), m.group(4)))
    need(re.fullmatch(r"http://127\.0\.0\.1:<port>/api/v1/billing-runs/<uuid>", m.group(6)) is not None, "Location absolute, the request's host, the run's address")
    need(m.group(7) == "<masked>", "Retry-After present, its value masked")
    need(m.group(2) == "application/json", "the 202's type application/json")
    acc = grab(ls, r"^  accept \| access log: POST /api/v1/billing-runs 202 (\d+|-)", "the access log line")
    need(acc is not None, "the access log holds the POST's 202")
    f = grab(ls, r"^  accept \| delay=on \| following Location -> (\d+)", "follow")
    need(f is not None and f.group(1) == "200", "following Location answers 200")
    VALS["accept"] = "202,%s" % m.group(8)
    o = grab(ls, r"^  ~ accept \| delay=off \| POST /api/v1/billing-runs -> (\d+) .* state (\w+) · Retry-After (\S+)", "delay off")
    if o:
        need(o.group(1) == "202", "delay=off: the POST answers 202 (its body's state is whatever the race gave: %s)" % o.group(2))


def c_poll(ls):
    m = grab(ls, r"^  poll \| delay=on \| states observed in order: (.+?) · every RUNNING poll carried Retry-After: (\w+) · the first terminal poll carried Retry-After: (\w+) · alarm ([\w-]+)", "poll")
    if not m:
        return
    st = m.group(1).split()
    need(st == ["RUNNING", "SUCCEEDED"], "the states observed in order: RUNNING then SUCCEEDED (%s)" % st)
    need("PENDING" not in st, "PENDING never observed (S3.8; this route ships none)")
    need(m.group(2) == "yes", "every RUNNING poll carried Retry-After")
    need(m.group(3) == "no", "the first terminal poll carried no Retry-After")
    need(m.group(4) == "not-hit", "the alarm (a guard) was not hit")
    polls = grab_all(ls, r"^  ~ poll \| delay=on \| (\w+) · Retry-After (present|absent)")
    need(polls and all((p.group(1) == "RUNNING") == (p.group(2) == "present") for p in polls), "each poll: Retry-After present iff RUNNING (%d polls, not voiced)" % len(polls))
    VALS["poll"] = ",".join(st)


def c_bills(ls):
    b = g1(ls, r"^  bills \| delay=on \| the final body's bills: (.+)$", "bills")
    need(b == BILLS, "the four bills = the expectation (%s)" % b)
    ar = g1(ls, r"^  bills \| monthlyBill\(\): (.+)$", "monthlyBill")
    need("mealsPerDay * pricePerMeal * 30" in ar, "monthlyBill's arithmetic printed")
    v2 = grab_all(ls, r"^  bills \| V2 row: (\w+) meals (\d+) price (\d+) -> (\d+)$")
    calc = " ".join("%s=%d" % (r.group(1), int(r.group(2)) * int(r.group(3)) * 30) for r in sorted(v2, key=lambda r: r.group(1)))
    need(len(v2) == 4 and calc == b, "the bills = V2's four rows through monthlyBill (%s)" % calc)
    need(all(int(r.group(4)) == int(r.group(2)) * int(r.group(3)) * 30 for r in v2), "each V2 row's printed product")
    VALS["bills"] = b.replace(" ", ",")


def c_restart(ls):
    r1 = g1(ls, r"^  restart \| JVM-1 \| id-1 state at the stop: (\w+)", "id-1")
    need(r1 == "RUNNING", "id-1 was RUNNING when JVM-1 stopped")
    need(g1(ls, r"^  restart \| JVM-1 \| id-2 state: (\w+)", "id-2") == "SUCCEEDED", "id-2 was SUCCEEDED on JVM-1")
    need(g1(ls, r"^  restart \| JVM-1 stopped by (.+)$", "stop") in ("POST /shutdown", "its recorded pid (SIGTERM)"), "JVM-1 stopped by /shutdown or its recorded pid")
    for i in ("id-1", "id-2"):
        m = grab(ls, r"^  restart \| JVM-2 \| GET %s -> (\d+) (\S+) · type (\S+) · detail (.+)$" % i, i)
        need(m is not None and m.group(1) == "404" and m.group(2) == "application/problem+json" and m.group(3) == TYPE + "billing-run-unknown"
             and m.group(4) == "no billing run with id <uuid>", "JVM-2: the old %s answers 404, billing-run-unknown, the detail naming the id" % i)
    c = grab(ls, r"^  restart \| JVM-2 \| the control: POST -> (\d+) · polled to (\w+) · bills (.+)$", "control")
    need(c is not None and c.group(1) == "202" and c.group(2) == "SUCCEEDED" and c.group(3) == BILLS, "the control: a new run on JVM-2 answers 202 and ends SUCCEEDED with the four bills")
    need(g1(ls, r"^  restart \| JVM-2 port (\d+)", "port") == "21065", "JVM-2 on 21065")
    VALS["restart"] = "404,control=202"


def c_double(ls):
    m = grab(ls, r"^  double \| two key-less POSTs -> (\d+) (\d+) · distinct ids (\w+) · each followed -> (\d+) (\d+)", "keyless")
    need(m is not None and m.groups() == ("202", "202", "yes", "200", "200"), "two key-less POSTs: two 202s, two distinct runs, each 200")
    k = grab(ls, r"^  double \| one keyed POST -> (\d+) · the same key again -> (\d+) · distinct ids (\w+)", "keyed")
    need(k is not None and k.groups() == ("202", "202", "yes"), "a key on the unlisted route is inert: the same key twice started two runs")
    need(g1(ls, r"^  double \| the filter's table: (\d+) rows", "table") == "2", "IdempotencyKeyFilter's GUARDED: 2 rows, the route not among them")
    VALS["double"] = "two_runs,key_inert"


def c_refuse(ls):
    rows = grab_all(ls, r"^  refuse \| (.+?) \((.+?)\) -> (\d+) (\S*) \| (.*)$")
    need(len(rows) >= 7, "refusals printed (%d)" % len(rows))
    by = {r.group(1): r for r in rows}
    def chk(lab, code, typ):
        r = by.get(lab)
        if not need(r is not None, "refuse row %s" % lab):
            return
        need(r.group(3) == code, "%s -> %s (%s)" % (lab, code, r.group(3)))
        if typ:
            need(("type=" + TYPE + typ) in r.group(5), "%s: type %s" % (lab, typ))
        else:
            need("type absent" in r.group(5), "%s: no type of TiffinBox's (Framework's/Boot's)" % lab)
    chk("an unknown id", "404", "billing-run-unknown")
    chk("a non-UUID id", "404", "billing-run-unknown")
    chk("a query parameter on the POST", "400", "parameter-unknown")
    chk("a query parameter on the status resource", "400", "parameter-unknown")
    nt = sorted(r.group(1).replace(" ", "_") for r in rows if "type absent" in r.group(5))
    VALS["refusals"] = str(len(rows))
    VALS["notype"] = ",".join(nt)


def c_specwire(ls):
    need(g1(ls, r"^  spec \| POST /api/v1/billing-runs responses (\[[^\]]*\])", "post responses") == "['202', '400']", "the POST's documented responses 202, 400 (annotated, C5)")
    need(g1(ls, r"^  spec \| GET /api/v1/billing-runs/\{id\} responses (\[[^\]]*\])", "get responses") == "['200', '400', '404']", "the GET's documented responses 200, 400, 404")
    need(g1(ls, r"^  spec \| 202 headers (\[[^\]]*\])", "202 headers") == "['Location', 'Retry-After']", "the 202 documents Location and Retry-After")
    w = grab(ls, r"^  wire \| POST -> (\d+) (\S+) members (.+)$", "wire post")
    need(w is not None and w.group(1) == "202", "the wire's POST 202")
    gaps = grab_all(ls, r"^  gap \| (?!named)(.+)$")
    n = g1(ls, r"^  gap \| named: (\d+)", "gaps")
    need(str(len(gaps)) == n, "every gap named (%s)" % n)
    VALS["gaps"] = n


def c_spec(ls):
    need(g1(ls, r"the committed file against the served document[^:]*: (\w+)", "equal") == "equal", "the committed file = the served document")
    m = grab(ls, r"committed md5 before ([0-9a-f]{32}) · after ([0-9a-f]{32}) · bytes before (\d+) · after (\d+)", "md5s")
    a = grab(ls, r"the diff against before's \(c3bc1b2's\) file: (\d+) lines added, (\d+) removed", "diff")
    o = grab(ls, r"before: OPERATIONS (\d+) PATHS (\d+) · after: OPERATIONS (\d+) PATHS (\d+)", "ops")
    need(o is not None and int(o.group(3)) == int(o.group(1)) + 2 and int(o.group(4)) == int(o.group(2)) + 2, "two operations and two paths added")
    need(g1(ls, r"the old operations' ids before -> after: (\w+)", "old ids") == "equal", "the old operations' ids equal (R.535)")
    need(g1(ls, r"ops9s3.py on an empty spec: exit (\d+)", "empty") == "1", "the counter refuses an empty spec (exit 1)")
    need(g1(ls, r"operationIds unique: (\w+)", "unique") == "yes", "operationIds unique")
    need(a is not None and a.group(2) == "0", "the diff removes no line")
    c = grab(ls, r"the client: counts - equal (\d+) · date line only (\d+) · lines added only (\d+) · moved (\d+) · added (\d+)", "client counts")
    need(c is not None and c.group(4) == "0", "no client file moved beyond the date line and added lines")
    t = grab(ls, r"the client: its test in after/'s build: tests (\d+) failures (\d+) errors (\d+)", "client test")
    need(t is not None and t.groups() == ("1", "0", "0"), "the client's test passes on the client rebuilt from the regenerated spec")
    f = grab(ls, r"the client: FILES (\d+) -> (\d+)", "FILES")
    pc = grab(ls, r"PATH_\* constants \(ops9s3.py paths, a CHECK\): before PATH_CONSTANTS (\d+) FILES \d+ · after PATH_CONSTANTS (\d+) FILES \d+", "PATH")
    if m and a and o and c and f:
        VALS["spec"] = "%s->%s,+%s/-%s" % (m.group(3), m.group(4), a.group(1), a.group(2))
        VALS["spec_md5"] = m.group(2)[:8]
        VALS["ops"] = "%s->%s" % (o.group(1), o.group(3))
        VALS["paths"] = "%s->%s" % (o.group(2), o.group(4))
        VALS["client"] = "%s->%s,date=%s,added_lines=%s,new=%s" % (f.group(1), f.group(2), c.group(2), c.group(3), c.group(5))
    if pc:
        VALS["path_consts"] = "%s->%s" % pc.groups()


def c_moved(ls):
    rows = grab_all(ls, r"^  (before|after) \| (\S+ \S+(?: \[[^\]]*\])?) -> (.*)$")
    b = {r.group(2): r.group(3) for r in rows if r.group(1) == "before"}
    a = {r.group(2): r.group(3) for r in rows if r.group(1) == "after"}
    need(b and set(b) == set(a), "the same requests on both sides (%d)" % len(b))
    new = {k for k in b if "billing-runs" in k}
    yaml = {k for k in b if k.startswith("GET /v3/api-docs.yaml")}
    mv = sorted(k for k in b if k in a and b[k] != a[k] and k not in new | yaml)
    for k in mv:
        print("  moved: %s | before %s | after %s" % (k, b[k], a[k]))
    need(not mv, "no old request moved (%d)" % len(mv))
    named = sorted(k for k in new | yaml if b.get(k) != a.get(k))
    VALS["moved"] = str(len(mv))
    VALS["named"] = str(len(named))


def c_seven(ls):
    exp = g1(ls, r"expected ([0-9a-f]{32})", "expected")
    for s in ("before", "after"):
        need(g1(ls, r"^  %s: the seven ([0-9a-f]{32})" % s, s) == exp, "the seven on %s = %s" % (s, exp[:8]))
    VALS["seven"] = exp[:8]


def c_surface(ls):
    exp = g1(ls, r"expected ([0-9a-f]{32})", "expected")
    for s in ("before", "after"):
        need(g1(ls, r"^  %s: the old surface ([0-9a-f]{32})" % s, s) == exp, "the old surface on %s = %s" % (s, exp[:8]))
        need(g1(ls, r"^  %s: the old surface [0-9a-f]{32} \((\d+) requests" % s, s) == "13", "13 requests on %s" % s)
    VALS["surface"] = exp[:8]


def c_tests(ls):
    def su(lab):
        m = grab(ls, r"^  %s \| tests (\d+) failures (\d+) errors (\d+) skipped (\d+)" % re.escape(lab), lab)
        return tuple(int(x) for x in m.groups()) if m else (0, -1, -1, -1)
    p = su("package | tiffinbox-web"); c = su("package | tiffinbox-client"); t = su("twin | tiffinbox-web"); w = su("webonly | tiffinbox-web")
    need(p[1:] == (0, 0, 0) and c == (1, 0, 0, 0), "package: web %d, 0 failures, 0 skipped; client 1" % p[0])
    need(t == p and w == p, "the twin and the web-only form print the same web counts")
    b = grab(ls, r"^  package \| class BillingRunsTest \| tests (\d+) failures 0 errors 0 skipped 0", "BillingRunsTest")
    k = int(b.group(1)) if b else 0
    wb = int(g1(ls, r"web tests before \(unit 16's values\): (\d+)", "web before", "0"))
    need(p[0] == wb + k, "web %d = unit 16's %d + BillingRunsTest's %d" % (p[0], wb, k))
    v = grab(ls, r"verify exit (\d+) · ITs tests (\d+) failures (\d+) errors (\d+) · classes (\d+)", "verify")
    need(v is not None and v.groups() == ("0", "14", "0", "0", "5"), "verify: exit 0, 14 ITs, 0 failures, 5 classes")
    need(g1(ls, r"IT bindings: (\d+) lines", "bindings") == "5" and g1(ls, r"not 127\.0\.0\.1: (\d+)", "not local") == "0", "five IT BINDINGS lines, all 127.0.0.1")
    need(g1(ls, r"downloads across the builds: (\d+)", "downloads") == "0", "0 downloads")
    need(g1(ls, r"the slice's file byte-equal to before's: (\w+)", "slice") == "yes", "the slice unedited (measured)")
    VALS["web_tests"] = str(p[0]); VALS["web_before"] = str(wb); VALS["k"] = str(k); VALS["its"] = v.group(2) if v else "?"


def c_exercise(ls):
    for sh in ("bash", "zsh"):
        need(any(re.match(r"^  broken %s \| check exit 1$" % sh, l) for l in ls), "broken under %s: check exit 1" % sh)
        need(any(re.match(r"^  solved %s \| check exit 0$" % sh, l) for l in ls), "solved under %s: check exit 0" % sh)
        need(any(re.match(r"^  broken %s \| FAIL \(2\)" % sh, l) for l in ls), "broken under %s: clause 2 named (no Retry-After while RUNNING)" % sh)
    m = grab(ls, r"^  broken bash \| measured: RUNNING -> (\d+) (\S+) · Retry-After (\w+)", "measured")
    need(m is not None and m.group(1) == "200" and m.group(3) == "absent", "measured first on the named route: RUNNING 200, no Retry-After")
    for v, cl in (("always", "3"), ("never", "2"), ("fixedelsewhere", "5"), ("statehardcoded", "4")):
        if any(l.startswith("  ~ %s bash |" % v) for l in ls):
            need(any(re.match(r"^  ~ %s bash \| FAIL \(%s\)" % (v, cl), l) for l in ls), "refused variant %s fails clause %s" % (v, cl))
    VALS["ex_broken"] = "200,no_retry_after" if m else "?"


def c_inert(ls):
    need(g1(ls, r"key header outside the double capture: (\d+)", "key") == "0", "no request outside double carries the key header")
    need(g1(ls, r"MockMvc runs carry the key header: (\d+)", "mockmvc") == "0", "MockMvc runs send no key")


# ---- hashable, static ---------------------------------------------------------------------------------------------------------------------
def hashable(name, f):
    for l in lines(f):
        if l.startswith("  ~"):
            continue
        print(l)


def git(*a):
    return subprocess.run(["git"] + list(a), capture_output=True, text=True).stdout


def static(after, before):
    u = os.getcwd()
    need(os.path.islink("before") and os.readlink("before") == "../c9-unit16/after", "before is a link whose text is ../c9-unit16/after")
    need(os.path.isdir("after") and not os.path.islink("after"), "after/ is a directory")
    A = lambda p: open(os.path.join(after, p), encoding="utf-8").read()
    Bf = lambda p: open(os.path.join(before, p), encoding="utf-8").read()
    H = lambda p: git("-C", u, "show", "%s:c9-tiffinbox/%s" % (HASH16, p))
    W = "tiffinbox-web/src/main/java/com/tiffinbox/web/"
    need(H("pom.xml") == Bf("pom.xml"), "before's pom = git show %s:<the anchor>/pom.xml (the pinned hash, not the live tree)" % HASH16)
    br = A(W + "BillingRuns.java")
    code = re.sub(r"(?s)/\*.*?\*/|//[^\n]*", "", br)
    need(re.search(r"^final class BillingRuns \{", br, re.M) is not None, "BillingRuns is final (C7)")
    need('@PostMapping("/api/v1/billing-runs")' in br and '@GetMapping("/api/v1/billing-runs/{id}")' in br, "BillingRuns maps the two literal routes")
    for k in ("Pageable", "JsonView", "MappingJacksonValue", "Probe", "/probe/", "msPerCustomer", "@RequestParam", "PENDING"):
        need(k not in code, "BillingRuns' code holds no %s" % k)
    need("ConcurrentHashMap" in code and "Thread.ofVirtual()" in code, "the store a ConcurrentHashMap, the run on a virtual thread (C8)")
    need(code.count("HttpHeaders.RETRY_AFTER") == 2 and code.count("if (view.state() == State.RUNNING)") == 2, "Retry-After sent only on RUNNING, in each handler")
    for n in ("OrderResources", "OrderPages", "CustomerReads", "CustomerFields", "CustomerNotFound", "TiffinBoxErrors", "TiffinBoxOpenApi",
              "TiffinBoxApiVersioning", "IdempotencyKeys", "IdempotencyKeyFilter"):
        need(A(W + n + ".java") == Bf(W + n + ".java"), "%s.java byte-equal to before's" % n)
    for n in ("OrderPages", "CustomerReads", "CustomerFields"):
        need(re.search(r"^final class %s" % n, A(W + n + ".java"), re.M) is not None, "%s still final" % n)
    for p in ("pom.xml", "tiffinbox-core/pom.xml", "tiffinbox-web/pom.xml", "tiffinbox-client/pom.xml", "tiffinbox-web/src/main/resources/application.yaml",
              "Dockerfile", "compose.yaml", "tiffinbox-core/src/main/resources/db/migration/V6__tiffin_order.sql",
              "tiffinbox-web/src/test/java/com/tiffinbox/web/TiffinBoxWebTest.java", "tiffinbox-web/src/test/java/com/tiffinbox/web/OpenApiSpecTest.java",
              "tiffinbox-web/src/test/java/com/tiffinbox/web/OrderPagesTest.java", "tiffinbox-web/src/test/java/com/tiffinbox/web/CustomerFieldsTest.java",
              "tiffinbox-web/src/test/java/com/tiffinbox/web/OrderResourcesTest.java", "tiffinbox-web/src/test/java/com/tiffinbox/web/ApiVersionTest.java",
              "tiffinbox-web/src/test/java/com/tiffinbox/web/TiffinBoxRestDocsTest.java"):
        need(A(p) == Bf(p), "%s byte-equal to before's" % p)
    for d in ("tiffinbox-core", "tiffinbox-client"):
        fa = sorted(os.path.relpath(os.path.join(x, f), after) for x, _, fs in os.walk(os.path.join(after, d)) for f in fs)
        fb = sorted(os.path.relpath(os.path.join(x, f), before) for x, _, fs in os.walk(os.path.join(before, d)) for f in fs)
        need(fa == fb and all(A(p) == Bf(p) for p in fa), "%s unchanged (%d files)" % (d, len(fa)))
    y = A("tiffinbox-web/src/main/resources/application.yaml")
    for k in ("compression", "forward-headers", "hateoas", "billing", "pause", "ms-per-customer"):
        need(k not in y, "application.yaml holds no %s key" % k)
    hs = [m.group(1) for d, _, fs in os.walk(os.path.join(after, "tiffinbox-web/src/main/java")) for f in fs
          for m in re.finditer(r"@(?:Get|Post|Put|Patch|Delete|Request)Mapping[^\n]*\n(?:\s*@[^\n]*\n)*\s*[\w<>.,? ]+? (\w+)\(", open(os.path.join(d, f), encoding="utf-8").read())]
    for h in ("startBillingRun", "billingRun"):
        need(hs.count(h) == 1, "%s occurs once among the mapped handlers (%d)" % (h, hs.count(h)))
    sp = json.load(open(os.path.join(after, "tiffinbox-web/src/test/resources/openapi/tiffinbox.json")))
    sb = json.load(open(os.path.join(before, "tiffinbox-web/src/test/resources/openapi/tiffinbox.json")))
    ids = [o.get("operationId") for v in sp["paths"].values() for o in v.values()]
    idb = {(k, m): o.get("operationId") for k, v in sb["paths"].items() for m, o in v.items()}
    need(len(ids) == len(set(ids)) and "servers" not in sp, "the committed spec's operationIds unique, no servers")
    need(all(sp["paths"].get(k, {}).get(m, {}).get("operationId") == i for (k, m), i in idb.items()), "the %d old operationIds equal before's" % len(idb))
    t = A("tiffinbox-web/src/test/java/com/tiffinbox/web/BillingRunsTest.java")
    need(not re.search(r"@(?:org\.junit\.jupiter\.api\.(?:condition\.)?)?(?:Disabled|EnabledIf\w*|DisabledIf\w*|EnabledOn\w*|DisabledOn\w*|EnabledFor\w*|DisabledFor\w*)\b", t),
         "BillingRunsTest: no @Disabled / @EnabledIf... / @DisabledIf... in the simple or the fully-qualified form")
    need(not re.search(r"RANDOM_PORT|DEFINED_PORT|LocalServerPort|\bSocket\b|\b\d{4,5}\b(?!-)", re.sub(r'"[^"]*"', '""', re.sub(r"Map\.entry\([^)]*\)|containsEntry\([^)]*\)", "", t))),
         "BillingRunsTest names no port and no socket")
    need(not re.search(r"Thread\.sleep\([^)]*\d", t), "BillingRunsTest: no Thread.sleep with a typed number (R.525)")
    me = open(__file__, encoding="utf-8").read(); rs = open("receipts.sh", encoding="utf-8").read()
    for n in LEFT_OUT:
        need(not re.search(r"^def c_%s\(" % n, me, re.M) and not re.search(r"^cap %s " % n, rs, re.M), "the left-out capture %s is in neither the checker nor receipts.sh" % n)
    need(not os.path.exists("harness/src"), "harness/ holds no Java (C1 (a): the delay is a run flag)")
    for f in ("walk.py", "follow.py", "seal9.py", "cdp.mjs", "cdp9.mjs", "loc9.py", "Gzip14.java", "U16Hal.java", "U16Next.java"):
        need(not os.path.exists("harness/" + f), "harness/%s absent" % f)
    need(" -pl tiffinbox-core" not in rs, "no -pl tiffinbox-core form (R.391)")
    # flag 31: no static assertion of this unit reads the live anchor
    src = me.split("def static(", 1)[1].split("\ndef ", 1)[0]
    live = ".." + "/c9-" + "tiffinbox"
    need(src.count("c9-" + "tiffinbox") == 1 and live not in src, "static reads no live anchor: its one naming is the pinned git show HASH16 form (flag 31)")
    r = open("README.md", encoding="utf-8").read()
    prose = re.sub(r"```.*?```", "", r, flags=re.S)
    prose = re.sub(r"<!-- values: begin -->.*?<!-- values: end -->", "", prose, flags=re.S)
    nocode = re.sub(r"`[^`]*`", "", prose)
    need(not re.search(r"(?<![\w.:<])\d{1,2}:\d{2}(?::\d{2})? ?(?:CET|UTC)?\b", nocode.split("## Runs of record")[0]), "README: no clock figure before the runs section")
    card = A("README.md").split("## Course 9 · unit 17", 1)
    need(len(card) == 2 and not re.search(r"web (?:tests )?`?67`?(?! at unit 16)", card[1].split("\n## ", 1)[0]), "the anchor's unit 17 card gives 67 as unit 16's count only")


def brief17():
    t = open(BRIEF, encoding="utf-8").read()
    return t.split("## Unit 17", 1)[1].split("\n## ", 1)[0]


def hook():
    m = re.search(r'\*\*Hook \(\[S3 §10\]\):\*\* "([^"]+)"', brief17())
    print(m.group(1) if m else "FAIL no hook line")


def exq():
    m = re.search(r'\*\*Exercise:\*\* "(Your turn: [^"]+)"', brief17())
    print(m.group(1) if m else "FAIL no exercise line")


def interleaved():
    t = open(BRIEF, encoding="utf-8").read().split("\n")
    gate = [l for l in t if l.startswith("**Gates on this brief's own lines")]
    body = [l for l in t if not l.startswith("**Gates on this brief's own lines")]
    hs = [m.group(1) for m in (re.search(r'\*\*Hook \(\[S3 §\d+\]\):\*\* "([^"]+)"', l) for l in body) if m]
    es = [m.group(1) for m in (re.search(r'\*\*Exercise:\*\* "([^"]+)"', l) for l in body) if m]
    h = hashlib.md5("\n".join(x for p in zip(hs, es) for x in p).encode()).hexdigest()
    if len(gate) != 1 or len(hs) != 6 or len(es) != 6 or h != "1f1f7d32df49d49e39df4ba58a94f9b2":
        fail("the interleaved list: %d + %d (gates paragraph lines %d), md5 %s" % (len(hs), len(es), len(gate), h))
        return
    print("the brief's hooks and exercises: %d + %d (the gates paragraph's own pattern line excluded: %d), interleaved md5 %s = S3B's" % (len(hs), len(es), len(gate), h))


def gloss(readme):
    ls = lines(readme)
    need(sum(1 for l in ls if l.startswith("A status resource:")) == 1, "exactly one README line starts with the status-resource gloss")
    need(GLOSS in ls, "the gloss line byte for byte")
    need(len(GLOSS.split()) <= 25, "the gloss %d words (<= 25)" % len(GLOSS.split()))
    for g in ("`HAL`:", "HAL:", "A link relation:", "A sparse fieldset:", "A cursor:", "A version carrier:", "A snippet:", "A contract:", "Swagger UI:",
              "A problem type:", "Code generation:"):
        need(not any(l.startswith(g) for l in ls), "no second gloss of an earlier unit's kind (%s)" % g)
    base = os.path.dirname(os.path.dirname(os.path.abspath(readme)))
    for u, g in (("13", "A cursor:"), ("14", "A sparse fieldset:"), ("15", "A link relation:"), ("16", "`HAL`:")):
        p = os.path.join(base, "c9-unit%s/README.md" % u)
        if os.path.exists(p):
            need(sum(1 for l in lines(p) if l.startswith(g)) == 1, "unit %s's README keeps its own gloss line (%s)" % (u, g))
    print("VALUES gloss_words=%d" % len(GLOSS.split()))


def values(readme, vals):
    t = open(readme, encoding="utf-8").read()
    m = re.search(r"<!-- values: begin -->\n```\n(.*?)\n```\n<!-- values: end -->", t, re.S)
    if not m:
        fail("README.md has no values block")
        return
    want = [l.rstrip() for l in vals.strip().splitlines()]
    got = [l.rstrip() for l in m.group(1).strip().splitlines()]
    need(got == want, "the README's values block = this run's values (%d lines)" % len(want))
    if got != want:
        for a in want:
            if a not in got:
                print("  this run: " + a)
        for a in got:
            if a not in want:
                print("  README:   " + a)


# ---- plants: each made to FAIL first ------------------------------------------------------------------------------------------------------
PLANTS = [
    ("accept", "status line HTTP/1.1 202 <none>", "status line HTTP/1.1 202 Accepted", "a reason phrase typed"),
    ("accept", "Location http://127.0.0.1:<port>/", "Location http://localhost:<port>/", "Location typed localhost"),
    ("poll", "states observed in order: RUNNING SUCCEEDED", "states observed in order: PENDING RUNNING SUCCEEDED", "PENDING typed as observed"),
    ("poll", "states observed in order: RUNNING SUCCEEDED", "states observed in order: SUCCEEDED RUNNING", "the states in the wrong order"),
    ("poll", "the first terminal poll carried Retry-After: no", "the first terminal poll carried Retry-After: yes", "Retry-After typed on the terminal poll"),
    ("bills", "Meera=4500 Priya=3600", "Meera=4501 Priya=3600", "a total one off"),
    ("bills", "Meera=4500 Priya=3600 Ravi=7200 Sunil=9000", "Ravi=7200 Meera=4500 Priya=3600 Sunil=9000", "the names in another order"),
    ("restart", "GET id-1 -> 404", "GET id-1 -> 200", "the old id typed 200"),
    ("restart", "the control: POST -> 202", "the control: POST -> left out", "the control left out"),
    ("restart", "JVM-2 port 21065", "JVM-2 port 21060", "the second JVM on the first's port"),
    ("double", "distinct ids yes · each", "distinct ids no · each", "one run typed for two POSTs"),
    ("refuse", "type=tag:tiffinbox.example,2026:billing-run-unknown", "type=none", "the route's 404 typed without its type"),
    ("census", "final, default-run 10", "final, default-run 11", "the census one off"),
    ("spec", "the old operations' ids before -> after: equal", "the old operations' ids before -> after: differ", "an operationId renumbered"),
    ("spec", "ops9s3.py on an empty spec: exit 1", "ops9s3.py on an empty spec: exit 0", "an empty spec accepted"),
    ("specwire", "spec | 202 headers ['Location', 'Retry-After']", "spec | 202 headers []", "the 202 headers typed absent"),
    ("seven", "the seven 466c20ed", "the seven 466c20ee", "the seven one character off"),
    ("tests", "skipped 0", "skipped 1", "Skipped typed 1"),
]


def plants(capdir):
    import io, contextlib, shutil, tempfile
    global FAILS
    n = 0
    for cap, a, b, what in PLANTS:
        p = os.path.join(capdir, ".r-%s.new" % cap)
        if not os.path.exists(p):
            fail("plant %s: no capture %s" % (what, p)); continue
        t = open(p, encoding="utf-8").read()
        if a not in t:
            fail("plant %s: the text to plant on is not in the capture (%s)" % (what, a)); continue
        f0 = FAILS; FAILS = []
        buf = io.StringIO()
        with contextlib.redirect_stdout(buf):
            try:
                FN[cap](t.replace(a, b, 1).splitlines())
            except Exception as e:
                fail("unparsable (%s)" % e)
        caught = bool(FAILS); FAILS = f0
        if need(caught, "plant %s / %s: caught (%s)" % (cap, what, "FAIL line, no traceback" if caught else "missed")):
            n += 1
    here = os.path.dirname(os.path.abspath(__file__))
    tmp = tempfile.mkdtemp()
    try:
        for what, s in (("the job survives a restart", "The job survives a restart."), ("billing is slow", "Billing is slow."),
                        ("a done count", "Two of four done."), ("try again in a second", "Try again in a second."),
                        ("idempotent", "The route is idempotent."), ("the 202 means done", "Accepted means done."),
                        ("a ranking word", "Polling is cheap."), ("a status in digits", "It answers 404."), ("bare Retry-After", "Send Retry-After.")):
            q = os.path.join(tmp, "p.md")
            open(q, "w", encoding="utf-8").write(s + "\n")
            r = subprocess.run([sys.executable, "-I", "-B", os.path.join(here, "s917.py"), os.path.join(here, "dur9.py"), q], capture_output=True, text=True)
            last = (r.stdout.strip().splitlines() or [""])[-1]
            if need(r.returncode == 0 and not last.endswith("refused: 0"), "plant README / %s: refused by s917.py" % what):
                n += 1
    finally:
        shutil.rmtree(tmp)
    print("VALUES plants=%d" % n)


FN = {n: globals()["c_" + n] for n in CAPS}

if __name__ == "__main__":
    a = sys.argv[1:]
    try:
        if a[0] in FN:
            FN[a[0]](lines(a[1]))
            print("VALUES " + " ".join("%s=%s" % kv for kv in VALS.items()))
        elif a[0] == "hashable":
            hashable(a[1], a[2])
        elif a[0] == "static":
            static(a[1], a[2])
        elif a[0] == "gloss":
            gloss(a[1])
        elif a[0] == "gloss-line":
            print(GLOSS)
        elif a[0] == "hook":
            hook()
        elif a[0] == "exq":
            exq()
        elif a[0] == "interleaved":
            interleaved()
        elif a[0] == "values":
            values(a[1], a[2])
        elif a[0] == "plants":
            plants(a[1])
        else:
            fail("unknown mode " + a[0])
    except Exception as e:  # a listing it cannot parse is a FAIL line, never a traceback
        fail("unparsable (%s: %s)" % (e.__class__.__name__, str(e)[:120]))
    sys.exit(1 if FAILS else 0)
