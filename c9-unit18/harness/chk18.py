#!/usr/bin/env python3
"""Course 9 unit 18's checker (python3 -I -B harness/chk18.py MODE ...), on chk17.py's shared machinery (ok / fail / need, the listing
parser that ends with a FAIL line and exit 1, never a traceback; hashable, static, gloss, hook, exq, interleaved, values, plants). Each
capture's check reads the capture's own lines and checks them against another witness of the same run (curl's size against the saved
file's bytes and the access log, the bill against Course 6's rows rebuilt from V2, the link's body against the bill route's, the counter's
totals ...). Prints "ok ..." / "FAIL ..." lines and one "VALUES k=v ..." line; exit 1 on any FAIL.

The self-contained rule (flag 31): static reads ONLY the unit's own frozen after/ and before trees, the committed receipts and git objects
pinned by a hash (git show 13b1967:PATH) - never the live anchor folder; a read of it, written whole or built from pieces, fails when the
folder is moved aside (the sealed clone's third static run).

Modes: CAPTURE FILE (see CAPS) · hashable CAPTURE FILE (the capture minus its run-variant lines, those starting "  ~") · static AFTER BEFORE
(run in the unit's folder) · gloss README · gloss-line · hook · exq · interleaved · values README VALS · plants CAPDIR. Left out of this
unit: see LEFT_OUT - a capture of that name in this checker or in receipts.sh is a static failure."""
import hashlib, json, os, re, subprocess, sys

FAILS = []
VALS = {}
HASH17 = "13b1967"
LEFT_OUT = ["acc" + "ept", "po" + "ll", "bi" + "lls", "rest" + "art", "dou" + "ble", "star" + "ter", "jack" + "son", "h" + "al", "fin" + "al",
            "ne" + "xt", "forw" + "arded", "hal" + "gz", "fie" + "lds", "vi" + "ew", "m" + "jv", "flo" + "or", "gro" + "wn", "und" + "er",
            "pa" + "ge", "cli" + "ents", "ya" + "ml", "wa" + "lk", "page" + "able", "tr" + "ap", "ta" + "ble", "fi" + "rst", "cur" + "sor",
            "lite" + "ral"]
CAPS = ["advisory", "before", "change", "census", "harness", "proxy", "declared", "signed", "presign", "defaults", "expect", "refuse",
        "specwire", "spec", "moved", "seven", "surface", "tests", "exercise", "inert", "section"]
GLOSS = "A presigned URL: an address that carries its own permission and expiry."
BRIEF = os.path.join(os.environ.get("C9R", ""), "_briefs/UNIT-BRIEFS-S3-PAYLOADS.md")
TYPE = "tag:tiffinbox.example,2026:"
KEYS = "X-Amz-Algorithm,X-Amz-Date,X-Amz-SignedHeaders,X-Amz-Credential,X-Amz-Expires,X-Amz-Signature"


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


def typ(rest):
    m = re.search(r"type=(\S+)", rest)
    return m.group(1) if m else "absent"


# ---- the captures -------------------------------------------------------------------------------------------------------------------------
def c_advisory(ls):
    need(g1(ls, r"^  fetched-at (\d{4}-\d{2}-\d{2})", "fetched-at") == g1(ls, r"run date (\d{4}-\d{2}-\d{2})", "run date"),
         "the read is this unit's day (fetched-at's date = the run's date)")
    m = grab(ls, r"MD5SUMS\.txt: (\d+) lines, (\d+) verified", "MD5SUMS")
    need(m is not None and m.group(1) == m.group(2) and int(m.group(1)) > 0, "MD5SUMS.txt: every line verified (%s)" % (str(m.groups()) if m else None))
    rows = g1(ls, r"spring index: CVE ids on its first page (\d+)", "spring ids")
    need(rows == "25", "Spring's index: 25 ids on its first page (%s)" % rows)
    need(g1(ls, r"tomcat page md5 ([0-9a-f]{32})", "tomcat") == "a1a756d985225fb5143eefd9aae3183c", "Tomcat's page md5 a1a756d9")
    shipped = grab_all(ls, r"^  shipped \| ([a-z0-9-]+) (\S+)$")
    need(len(shipped) >= 10 and all(s.group(2) for s in shipped), "the shipped tree's coordinates, each with its version (%d)" % len(shipped))
    need(g1(ls, r"awssdk jars in after/'s lib: (\d+)", "awssdk") == "0", "no SDK jar in the shipped tree")
    n = g1(ls, r"the presigner's class path: (\d+) jars", "class path")
    rowsh = grab_all(ls, r"^  harness \| (\S+) (\S+) · in the read: (yes|no)$")
    need(n and int(n) == len(rowsh), "every class-path coordinate printed (%s = %d)" % (n, len(rowsh)))
    nm = grab(ls, r"not in the read's (\d+) coordinates: (\d+) - (.*) \(not read, not said\)$", "not read")
    need(nm is not None and int(nm.group(2)) == sum(1 for r in rowsh if r.group(3) == "no"), "the coordinates not in the read named, 'not read, not said'")
    need(any(r.group(1) == "apache5-client" and r.group(3) == "yes" for r in rowsh), "apache5-client 2.59.10 is in this read (the gap of the 11-26 read, closed)")
    o = grab(ls, r"osv \(second witness only, S2\.8\): (\d+) results, (\d+) with vulns", "osv")
    need(o is not None and o.group(2) == "0", "OSV: no coordinate with a vuln")
    need(any(l.strip().startswith("verdict: no pin affected; evidence may proceed; this unit adds no jar") for l in ls), "the verdict line")
    VALS["adv_ids"] = rows
    VALS["cp_jars"] = n
    VALS["not_read"] = nm.group(2) if nm else "?"


def c_before(ls):
    for r in ("bill", "bill-link", "bill/signed"):
        m = grab(ls, r"before \| GET /api/v1/customers/Ravi/%s(?:\?\S*)? -> (\d+)" % re.escape(r), r)
        need(m is not None and m.group(1) in ("404", "405"), "before: %s is not there (%s)" % (r, m.group(1) if m else None))
    o = grab(ls, r"before \| GET /api/v1/orders/1 -> (\d+) \S+ (\d+) · file (\d+) B", "before order 1")
    need(o is not None and o.group(1) == "200" and o.group(2) == o.group(3), "before: GET /api/v1/orders/1 200, curl's size = the file's bytes")
    need(g1(ls, r"before \| GET /api/v1/customers/Ravi -> (\d+)", "Ravi") == "200", "before: GET /api/v1/customers/Ravi 200")
    b = grab(ls, r"before \| GET /api/v1/billing-runs/<uuid> -> (\d+) .* type=(\S+)", "billing run")
    need(b is not None and b.group(1) == "404" and b.group(2) == TYPE + "billing-run-unknown", "before: an unknown billing run answers 404 with U17's type (an old route now)")
    m = grab(ls, r"before \| mappings (\d+) · with bill in the path (\d+)", "mappings")
    need(m is not None and m.group(2) == "0", "before: no mapping with bill in its path")
    ops = grab(ls, r"before \| the committed spec: OPERATIONS (\d+) PATHS (\d+) · (\d+) B md5 ([0-9a-f]{32})", "before spec")
    need(ops is not None and ops.groups() == ("18", "16", "30801", "3cda0901be31567ce4c73f17652a5e29"),
         "before: the committed spec 18 operations / 16 paths, 30801 B 3cda0901 (checks, re-derived on this before)")
    lib = g1(ls, r"before \| BOOT-INF/lib names (\d+)", "lib")
    need(lib == "164", "before: BOOT-INF/lib 164 names (%s)" % lib)
    VALS["before_ops"] = "%s/%s" % (ops.group(1), ops.group(2)) if ops else "?"
    VALS["before_lib"] = lib
    VALS["before_mappings"] = m.group(1) if m else "?"


def c_change(ls):
    ch = g1(ls, r"changed \(derived[^)]*\): (.*)$", "changed")
    items = [x.strip() for x in ch.split("·") if x.strip()]
    allowed = {"A tiffinbox-web/src/main/java/com/tiffinbox/web/CustomerBills.java", "A tiffinbox-web/src/test/java/com/tiffinbox/web/CustomerBillsTest.java",
               "M tiffinbox-web/src/test/resources/openapi/tiffinbox.json", "M README.md", "M tiffinbox-web/src/main/resources/application.yaml"}
    need(items and set(items) <= allowed, "the derived changed list is within the allowed five (%s)" % items)
    need(g1(ls, r"poms before -> after/: (.*)$", "poms") == "equal", "no pom differs")
    for k in ("JsonView", "MappingJacksonValue", "Pageable", "offset(", "Probe", "/probe/", "ttlSeconds", "awssdk"):
        need(g1(ls, r"src/main grep %s: (\d+) code lines" % re.escape(k), "grep " + k) == "0", "src/main holds no %s" % k)
    for k in ("ResponseEntity<?>", "ResponseEntity<Object>"):
        m = grab(ls, r"CustomerBills grep %s: (\d+) lines · src/main before (\d+) · after (\d+)" % re.escape(k), k)
        need(m is not None and m.group(1) == "0" and m.group(2) == m.group(3), "CustomerBills holds no %s; src/main's count unmoved (the old routes' own)" % k)
    need(g1(ls, r"CustomerBills: (final class CustomerBills) \{", "final") == "final class CustomerBills", "CustomerBills is final (C6 (a))")
    need(g1(ls, r"the declared types of the shipped handlers: (.*)$", "declared") == "ResponseEntity<StreamingResponseBody> bill|BillLink billLink|ResponseEntity<StreamingResponseBody> signedBill",
         "the downloads declared ResponseEntity<StreamingResponseBody>, the mint BillLink")
    need(g1(ls, r"the checks' order in signedBill: (.*)$", "order") == "refuseParameters link-malformed MessageDigest.isEqual link-expired csv(customer",
         "signedBill's order: parameters, the link's form, the signature, the expiry, the customer (C4, C7)")
    for n in ("BillingRuns", "OrderResources", "OrderPages", "CustomerReads", "CustomerFields", "CustomerNotFound", "CustomerImport", "TiffinBoxErrors", "IdempotencyKeyFilter"):
        need(g1(ls, r"%s\.java byte-equal to before's: (\w+)" % n, n) == "yes", "%s.java byte-equal" % n)
    for k in ("compression", "forward-headers", "hateoas", "billing", "pause"):
        need(g1(ls, r"application.yaml %s keys: before (\d+) · after \d+" % k, k) == "0" and g1(ls, r"application.yaml %s keys: before \d+ · after (\d+)" % k, k) == "0", "application.yaml: no %s key" % k)
    need(g1(ls, r"application.yaml bill-link-lifetime keys: before (\d+) · after \d+", "lt") == "0" and g1(ls, r"application.yaml bill-link-lifetime keys: before \d+ · after (\d+)", "lt") == "1",
         "application.yaml: the lifetime key once, after only (C2 (a))")
    need(g1(ls, r"application.yaml bill-link-key keys: before \d+ · after (\d+)", "key") == "0", "application.yaml: no key setting (C3 (a): unset, random per start)")
    for h in ("bill", "billLink", "signedBill", "startBillingRun", "billingRun"):
        need(g1(ls, r"handler %s: (\d+) occurrence" % h, h) == "1", "the handler %s occurs once among the mapped handlers (R.535)" % h)
    r = grab(ls, r"the bill's rows: (\d+) row writers · DAYS = (\d+) · monthlyBill\(\): (.+?) · application.yaml's tiffinbox.days (\d+)", "rows")
    need(r is not None and r.group(2) == "30" and "mealsPerDay * pricePerMeal * 30" in r.group(3), "the bill's days = monthlyBill()'s thirty (C8)")
    v2 = grab_all(ls, r"^  V2 row: (\w+) meals (\d+) price (\d+) -> (\d+)$")
    need(len(v2) == 4 and all(int(x.group(4)) == int(x.group(2)) * int(x.group(3)) * 30 for x in v2), "V2's four rows through monthlyBill")
    cn = grab(ls, r"routes that throw CustomerNotFound \(R\.510\): before (\S+) · after (\S+)$", "cnf")
    need(cn is not None and set(cn.group(2).split(",")) == set(cn.group(1).split(",")) | {"CustomerBills.java"}, "R.510: CustomerBills joins the routes that throw CustomerNotFound, no other moved")
    VALS["changed"] = str(len(items))


def c_census(ls):
    def tot(side):
        m = grab(ls, r"census %s \| controllers (\d+) · final, default-run (\d+) · not final, default-run (\d+) · not final, dev-only (\d+)" % side, side)
        return tuple(int(x) for x in m.groups()) if m else (0, 0, 0, 0)
    b, a = tot("before"), tot("after")
    rb = len(grab_all(ls, r"^  census before \| \w+ +final")); ra = len(grab_all(ls, r"^  census after \| \w+ +final"))
    need(b[0] == rb and a[0] == ra, "the census totals = its rows (before %d = %d, after %d = %d)" % (b[0], rb, a[0], ra))
    need(a[0] == b[0] + 1 and a[1] == b[1] + 1 and a[2:] == b[2:], "after = before + one final default-run controller (CustomerBills)")
    need(any("census after | CustomerBills" in l and "final yes" in l and "dev-only no" in l for l in ls), "CustomerBills' row: final, default-run")
    need(sum(1 for l in ls if "excluded by the rule: TiffinBoxErrors" in l) == 2, "the excluded line printed on both sides")
    VALS["census_before"] = "%d/%d/%d/%d" % b
    VALS["census_after"] = "%d/%d/%d/%d" % a


def c_harness(ls):
    m = grab(ls, r"presign \| build: .* · exit (\d+) · Downloading from: (\d+)", "build")
    need(m is not None and m.groups() == ("0", "0"), "the harness's presigner built offline, exit 0, 0 downloads")
    p = grab(ls, r"the POM's parent: (\S+) (\S+) · awssdk.version (\S+) · its R.515 comment names the parent line: (\d+) · the measured surface: (\d+) · the word compatible: (\d+)", "pom")
    need(p is not None and p.groups()[:3] == ("spring-boot-starter-parent", "4.1.3", "2.59.10") and p.group(4) != "0" and p.group(5) != "0" and p.group(6) == "0",
         "R.515: parent 4.1.3, the SDK 2.59.10, the comment names the parent line and the measured surface, no 'compatible'")
    c = grab(ls, r"the class path: (\d+) jars · rewritten to /seed: (\d+) · the SDK: (.+?) · httpclient5 (\S+)$", "cp")
    need(c is not None and c.group(1) == c.group(2), "every class-path entry rewritten to /seed (%s)" % str(c.groups()[:2] if c else None))
    need(c is not None and "s3-2.59.10" in c.group(3) and "apache5-client-2.59.10" in c.group(3) and "netty-nio-client-2.59.10" in c.group(3), "the SDK's s3, apache5-client and netty-nio-client 2.59.10 on the class path")
    d = grab(ls, r"Presign\.java against the probe's .*: the named diff, md5 ([0-9a-f]{32}), (\d+) lines", "diff")
    need(d is not None and int(d.group(2)) > 0, "Presign.java's named diff printed")
    need(any("http://127.0.0.1:<port>" in l for l in ls if l.startswith("  presign | diff >")) and any("http://127.0.0.1:21399" in l for l in ls if l.startswith("  presign | diff <")), "the endpoint 21399 -> this unit's band (21079, masked as <port>) in the diff (N1)")
    need(any("package probe.u18" in l for l in ls if l.startswith("  presign | diff >")), "the package probe.api -> probe.u18")
    need(not any(re.search(r'AwsBasicCredentials\.create\("(?!<a fake test credential>)', l) for l in ls) and any('AwsBasicCredentials.create("<a fake test credential>"' in l for l in ls),
         "the fake test credential never printed in the diff (masked on both sides)")
    j = grab(ls, r"SDK classes in after/'s web jar: (\d+) · probe classes: (\d+) · the anchor's poms naming awssdk: (\d+)", "jar")
    need(j is not None and j.groups() == ("0", "0", "0"), "no SDK class, no probe class in the jar; no pom names the SDK")
    need(any("U18Blob.class U18Config.class" in l for l in ls), "the blob classes compiled outside the module")
    VALS["cp"] = c.group(1) if c else "?"


def c_proxy(ls):
    m = grab(ls, r"^  proxy \| GET /api/v1/customers/Ravi/bill -> (\d+) (\S+) (\d+) · status line (.+)$", "the bill")
    if not m:
        return
    need(m.group(1) == "200" and m.group(2) == "text/csv;charset=UTF-8", "the bill answers 200 text/csv;charset=UTF-8")
    need(m.group(4) == "HTTP/1.1 200 <none>", "Tomcat's status line has no reason phrase (%s)" % m.group(4))
    h = grab(ls, r"^  proxy \| Content-Length: (\w+) · Transfer-Encoding: (\S+)", "framing")
    need(h is not None and h.groups() == ("absent", "chunked"), "chunked, no Content-Length")
    cd = g1(ls, r"^  proxy \| header Content-Disposition: (.+)$", "Content-Disposition")
    need(cd == "attachment; filename=\"bill Ravi.csv\"; filename*=UTF-8''bill%20Ravi.csv", "Content-Disposition read off the wire")
    f = grab(ls, r"^  proxy \| the saved file: (\d+) B · (\d+) lines · md5 ([0-9a-f]{32})", "file")
    need(f is not None and f.group(1) == m.group(3), "curl's size %s = the saved file's %s B" % (m.group(3), f.group(1) if f else None))
    c6 = grab(ls, r"^  proxy \| Course 6's rows for Ravi .*: (\d+) B, (\d+) lines · diff against the wire's file: (\w+)", "c6")
    need(c6 is not None and c6.group(3) == "empty" and f is not None and c6.group(1) == f.group(1) and c6.group(2) == f.group(2), "the wire's file = Course 6's rows, byte for byte (C8 (b))")
    t = grab(ls, r"^  proxy \| the total row against monthlyBill\(\): (\d+) = (\d+) \* (\d+) \* 30 = (\d+)", "total")
    need(t is not None and t.group(1) == t.group(4), "the total row = monthlyBill()'s arithmetic")
    w = grab(ls, r"^  proxy \| the three byte witnesses: curl's size_download (\d+) · the saved file's wc -c (\d+) · the access log's %b (\d+)", "witnesses")
    if w:
        need(w.group(1) == w.group(2), "curl's size = the file's bytes")
        VALS["bill_b"] = "%s,log=%s" % (w.group(1), w.group(3))
    VALS["bill_lines"] = f.group(2) if f else "?"
    VALS["bill_md5"] = f.group(3)[:8] if f else "?"
    b = grab(ls, r"^  blob \| the harness's blob route GET /probe/u18/blob\?mib=8 -> (\d+) (\S+) (\d+) · Transfer-Encoding: (\S+) · Content-Length: (\w+) · the saved file's wc -c (\d+) · the access log's %b (\d+)", "blob")
    need(b is not None and b.group(1) == "200" and b.group(2) == "application/octet-stream" and b.group(4) == "chunked" and b.group(3) == b.group(6) == "8388608",
         "the harness's blob route: 200 octet-stream, chunked, 8388608 B by curl and the file")
    need(any(l.startswith("  blob | the JVM log") and "U18 harness: joined" in l for l in ls), "the harness-joined start printed its U18 harness line")
    if b:
        VALS["blob"] = "%s,log=%s" % (b.group(3), b.group(7))


def c_declared(ls):
    need(g1(ls, r"built the scratch copy .*: exit (\d+)", "build") == "0", "the broken copy built")
    need(g1(ls, r"the copy's declaration: (\S+) signedBill", "decl") == "ResponseEntity<?>", "the copy declares ResponseEntity<?>")
    s = grab(ls, r"^  declared \| the copy \| the signed download -> (\d+) (\S+) \d+ · (.*)$", "the copy's signed")
    need(s is not None and s.group(1) == "500" and s.group(2) == "application/problem+json", "the wildcard's answer: 500 application/problem+json")
    need(s is not None and "detail=Failed to write request" in s.group(3), "its detail: Failed to write request (read by python)")
    n = g1(ls, r"JVM log lines after the start \(a printed grep [^)]*\): (\d+)", "log")
    VALS["declared_log"] = n
    b = grab(ls, r"^  declared \| the copy \| the bill route on the same JVM -> (\d+) (\S+)", "bill")
    need(b is not None and b.group(1) == "200", "the bill route on the same broken JVM: 200")
    a = grab(ls, r"^  declared \| after/ \| .* -> (\d+) (\S+)", "after")
    need(a is not None and a.group(1) == "200" and a.group(2).startswith("text/csv"), "after/'s declared type: the signed download 200 text/csv")
    VALS["declared"] = "500,200" if s and a else "?"


def c_signed(ls):
    i = grab(ls, r"^  signed \| \(i\) mint Ravi -> (\d+) (\S+) \d+ · href (\S+) · body members (\[[^\]]*\]) · the href a path: (\w+)", "mint")
    need(i is not None and i.group(1) == "200" and i.group(2) == "application/json" and i.group(4) == "['href']" and i.group(5) == "yes", "the mint: 200 application/json {href}, a path")
    need(i is not None and re.fullmatch(r"/api/v1/customers/Ravi/bill/signed\?expires=<masked>&sig=<masked>", i.group(3)) is not None, "the href carries expires and sig, masked")
    o = grab(ls, r"^  signed \| \(i\) open it -> (\d+) (\S+) \d+ · body md5 ([0-9a-f]{32}) · the bill route's body md5 ([0-9a-f]{32}) · equal: (\w+) · Content-Disposition equal: (\w+)", "open")
    need(o is not None and o.group(1) == "200" and o.group(3) == o.group(4) and o.group(5) == "yes" and o.group(6) == "yes", "the link opens 200, the bill's own bytes and Content-Disposition")
    def ref(lab, code, t):
        m = grab(ls, r"^  signed \| %s -> (\d+) (\S+) \d+ · (.*)$" % re.escape(lab), lab)
        need(m is not None and m.group(1) == code and typ(m.group(3)) == TYPE + t, "%s -> %s %s" % (lab, code, t))
    ref("(ii) the name changed (Ravi -> Sunil, expires and sig kept)", "403", "link-signature-invalid")
    ref("(iii) expires raised by a day's seconds, the old sig kept", "403", "link-signature-invalid")
    ref("(iv) one character of sig changed", "403", "link-signature-invalid")
    v = grab(ls, r"^  signed \| \(v\) the lifetime read back: .* within \[[^]]*\]: (\w+) · the three equal: (\w+)", "lifetime")
    need(v is not None and v.groups() == ("yes", "yes"), "the lifetime read back: yaml = log = the mint's bracket")
    need(any(l.startswith("  signed | (v) the start's log lines:") and "<lifetime>" in l and "defaulted" in l for l in ls), "the start's log lines: the lifetime masked, the key 'defaulted' (never the key)")
    t = grab(ls, r"^  signed \| \(vi\) the planted client lifetime .* -> (\d+) (\S+) \d+ · (.*) · a minted href in the answer: (\w+)", "ttl")
    need(t is not None and t.group(1) == "400" and typ(t.group(3)) == TYPE + "parameter-unknown" and t.group(4) == "no", "the planted ttlSeconds: 400 parameter-unknown, no link minted (C5 (a))")
    need(not any("315360000" in l for l in ls if "expires=" in l and "<masked>" not in l), "the planted value in no minted expires")
    e = grab(ls, r"^  signed \| \(viii\) the mint is open: no credential minted Sunil's link -> (\d+) · opening it -> (\d+)", "open mint")
    need(e is not None and e.groups()[0] == "200" and e.group(2) == "200", "the open mint: any caller mints Sunil's link and it opens")
    s = grab(ls, r"^  signed \| \(vii\) minted -> (\d+) · opened at once after the mint -> (\d+) \(valid when minted\)", "valid first")
    need(s is not None and s.groups() == ("200", "200"), "the short-lifetime link: valid when minted (RED3 #28)")
    need(any("signed-short up on 21075" in l and "lifetime=short (the harness's)" in l and "--tiffinbox.bill-link-lifetime=<lifetime>" in l for l in ls), "the short lifetime labelled, its flag on the printed command line")
    x = grab(ls, r"^  signed \| \(vii\) polled by its condition .* -> the first refusal (\d+) (\S+) \d+ · (.*) · alarm ([\w-]+)", "expired")
    need(x is not None and x.group(1) == "403" and typ(x.group(3)) == TYPE + "link-expired" and x.group(4) == "not-hit", "the link waited out: 403 link-expired, the alarm not hit")
    a = grab(ls, r"^  signed \| \(vii\) the same link once more -> (\d+) \S+ \d+ · (\S+)", "again")
    need(a is not None and a.group(1) == "403" and a.group(2) == "type=" + TYPE + "link-expired", "the same link once more: 403 link-expired")
    te = grab(ls, r"^  signed \| \(iv\) tampered AND expired -> (\d+) \S+ \d+ · (\S+)", "tampered expired")
    need(te is not None and te.group(1) == "403" and te.group(2) == "type=" + TYPE + "link-signature-invalid", "tampered and expired: the signature answers (signature before expiry)")
    r = grab(ls, r"^  signed \| \(ix\) JVM-2 the same link -> (\d+) \S+ \d+ · (\S+)", "restart")
    need(r is not None and r.group(1) == "403" and r.group(2) == "type=" + TYPE + "link-signature-invalid", "a link from another start: 403 link-signature-invalid (this start's key)")
    k = grab(ls, r"the link key and the fake test credential in this run's captures so far: (\d+) lines .*the JVM logs' key lines (\d+), each 'defaulted'", "key")
    need(k is not None and k.group(1) == "0" and int(k.group(2)) > 0, "no key, no fake credential in a capture; every start's key line 'defaulted'")
    VALS["signed"] = "200,403,403,403"
    VALS["ttl"] = "400"


def sealed(ls, side, mode):
    d = grab(ls, r"^  %s \| docker run line: (.+ %s) \(no published port\)$" % (side, mode), "run line " + mode)
    if d:
        need("--network none" in d.group(1) and "--pull never" in d.group(1) and "eclipse-temurin:25-jre@sha256:fcd7fd7b387f94bb2ac461478a7436ad8e349924c374ea8313919624dceae636" in d.group(1)
             and d.group(1).count(":ro") == 3, "%s: network none, pull never, the image by digest, every mount :ro" % mode)
    ins = grab(ls, r"^  %s \| inspect: network mode, publish-all, ports: (\S+) (\S+) (\d+)" % side, "inspect")
    need(ins is not None and ins.group(1) == "none" and ins.group(3) == "0", "%s: inspect says network none, no port" % mode)
    b = [m for m in grab_all(ls, r"^  %s \| before any Java: interfaces (\[[^\]]*\]) · route rows (\d+) · the presigner's line after both: (\w+)" % side)]
    return d, b


def c_presign(ls):
    d, b = sealed(ls, "presign", "static")
    need(len(b) == 1 and b[0].groups() == ("['lo']", "0", "yes"), "the sealed run: lo only, no route row, printed before the presigner")
    i = [n for n, l in enumerate(ls) if "== /proc/net/dev" in l]; j = [n for n, l in enumerate(ls) if "PRESIGN static" in l]
    need(i and j and i[0] < j[0], "/proc/net/dev printed before the presign")
    p = grab(ls, r"PRESIGN static · OK · (\S+) · query keys \[([^\]]*)\] · X-Amz-Expires=(\S+) · X-Amz-Algorithm=(\S+) · isBrowserExecutable (\w+) · signed headers (\[[^\]]*\]) · expiration <masked> · signature <masked, (\d+) hex chars>", "presign")
    if p:
        need(p.group(1) == "http://127.0.0.1:<port>/tiffinbox-bills/bill-Ravi.csv", "the URL: the endpoint override's host, the port masked, path-style")
        need(p.group(2) == KEYS, "the six X-Amz-* keys in order")
        need(p.group(3) == "<masked>", "X-Amz-Expires masked")
        need(p.group(4) == "AWS4-HMAC-SHA256" and p.group(6) == "[host]" and p.group(7) == "64", "AWS4-HMAC-SHA256, signed headers [host], 64 hex chars")
        VALS["presign"] = "keys=6,sig=64"
    need(any(re.match(r"^  presign \| container exit 0 · removed: dk rm -fv c9u18-presign-static · left: 0$", l) for l in ls), "the container exit 0, removed -fv, none left")


def c_defaults(ls):
    for mode in ("regiononly", "default"):
        d, b = sealed(ls, "defaults", mode)
    b = grab_all(ls, r"^  defaults \| before any Java: interfaces (\[[^\]]*\]) · route rows (\d+) · the presigner's line after both: (\w+)")
    need(len(b) == 2 and all(x.groups() == ("['lo']", "0", "yes") for x in b), "both sealed runs: lo only, no route row, before the presigner")
    r = grab(ls, r"PRESIGN regiononly · FAILED · (\S+): Unable to load credentials from any of the providers in the chain AwsCredentialsProviderChain\(credentialsProviders=\[([^\]]*)\]\)", "regiononly")
    need(r is not None and r.group(2).split(", ")[-1] == "InstanceProfileCredentialsProvider()", "regiononly FAILED: the chain's last provider InstanceProfileCredentialsProvider()")
    need(any("PRESIGN regiononly · FAILED" in l and "InstanceProfileCredentialsProvider(): Failed to load credentials from IMDS." in l for l in ls), "its last message: Failed to load credentials from IMDS.")
    g = grab(ls, r"PRESIGN default · FAILED · .*Unable to load region from any of the providers", "default")
    need(g is not None and any("PRESIGN default · FAILED" in l and "InstanceProfileRegionProvider@<id>: Unable to contact EC2 metadata service." in l for l in ls), "default FAILED at the region: InstanceProfileRegionProvider, Unable to contact EC2 metadata service.")
    if r:
        VALS["chain"] = str(len(r.group(2).split(", ")))


def c_expect(ls):
    o = g1(ls, r"the order of the events in curl's trace \(--trace-ascii, no time\): (.+)$", "order")
    ev = o.split(" -> ")
    want = ["the request's Expect: 100-continue header", "curl's receipt of HTTP/1.1 100", "the first body bytes sent", "curl's receipt of HTTP/1.1 413"]
    need(ev == want, "the order: Expect, a 100, the first body bytes, then 413 (%s)" % ev)
    s = grab(ls, r"POST /customers/import -> (\d+) (\S+) · host", "post")
    need(s is not None and s.group(1) == "413" and s.group(2) == "application/problem+json", "the old route answers 413 application/problem+json")
    u = grab_all(ls, r"^  ~ expect \| curl's size_upload (\d+) · the trace's Send data bytes (\d+) · the CSV's (\d+) B · the whole body sent before the 413: (\w+)")
    need(len(u) == 1 and u[0].group(1) == u[0].group(2), "curl's size_upload = the trace's data bytes (run-variant, not said)")
    c = g1(ls, r"the harness's CSV: (\d+) B", "csv")
    t = u[0].group(1) if u else "?"
    b = grab(ls, r"the 413's body: (.*) · Content-Type (\S+)$", "body")
    need(b is not None, "the 413's body printed")
    n = grab(ls, r"the same with -H 'Expect:' \(no Expect header\) -> (\d+) · an HTTP/1.1 100 in its trace: (\d+)", "noexpect")
    need(n is not None and n.groups() == ("413", "0"), "with no Expect header: 413, no 100")
    VALS["expect"] = "100,body,413"
    VALS["csv"] = c


def c_refuse(ls):
    rows = grab_all(ls, r"^  refuse \| (.+?) \((\w+) (.+?)\) -> (\d+) (\S*) \| (.*)$")
    need(len(rows) >= 20, "refusals printed (%d)" % len(rows))
    by = {r.group(1): r for r in rows}
    def chk(lab, code, t):
        r = by.get(lab)
        if not need(r is not None, "refuse row %s" % lab):
            return
        need(r.group(4) == code, "%s -> %s (%s)" % (lab, code, r.group(4)))
        if t:
            need(typ(r.group(6)) == TYPE + t, "%s: the route's type %s" % (lab, t))
        else:
            need("type absent" in r.group(6), "%s: no type of TiffinBox's (Framework's/Boot's)" % lab)
    chk("an unknown customer on the bill", "404", "customer-not-found")
    chk("an unknown customer on the mint", "404", "customer-not-found")
    chk("an unknown customer on the signed download, its own link's sig", "403", "link-signature-invalid")
    chk("a query parameter on the bill", "400", "parameter-unknown")
    chk("a query parameter on the mint", "400", "parameter-unknown")
    chk("ttlSeconds on the mint", "400", "parameter-unknown")
    chk("a query parameter on the signed download", "400", "parameter-unknown")
    chk("the name changed in the link", "403", "link-signature-invalid")
    chk("expires raised", "403", "link-signature-invalid")
    chk("a missing sig", "400", "link-malformed")
    chk("a missing expires", "400", "link-malformed")
    chk("a non-numeric expires", "400", "link-malformed")
    chk("a sig of the wrong length", "403", "link-signature-invalid")
    for m in ("POST", "PUT", "DELETE"):
        for a in ("bill", "bill-link", "bill/signed"):
            r = by.get("%s on %s" % (m, a))
            need(r is not None and r.group(4) == "405" and "type absent" in r.group(6), "%s on %s: 405, Framework's (no type)" % (m, a))
    ah = grab(ls, r"Accept: application/json on the bill \(GET\) -> (\d+) (\S+)", "accept json")
    need(ah is not None, "Accept: application/json on the bill printed (%s)" % str(ah.groups() if ah else None))
    nt = sorted(r.group(1).replace(" ", "_") for r in rows if "type absent" in r.group(6))
    VALS["refusals"] = str(len(rows))
    VALS["notype"] = str(len(nt))


def c_specwire(ls):
    for lab, rs in (("bill", "['200', '400', '404']"), ("mint", "['200', '400', '404']"), ("signed", "['200', '400', '403', '404']")):
        m = grab(ls, r"^  spec \| %s \| GET (\S+) · operationId (\w+) · responses (\[[^\]]*\]) · 200 media (\[[^\]]*\])" % lab, lab)
        need(m is not None and m.group(3) == rs, "%s: documented responses %s" % (lab, rs))
        if m:
            need(m.group(4) == ("['application/json']" if lab == "mint" else "['text/csv']"), "%s: the 200 documented as %s (annotated, C9 (a))" % (lab, m.group(4)))
    for lab in ("bill", "signed"):
        w = grab(ls, r"^  wire \| %s \| Content-Type (\S+) · Transfer-Encoding (\S+) · Content-Disposition (\w+)" % lab, lab)
        need(w is not None and w.groups() == ("text/csv;charset=UTF-8", "chunked", "present"), "%s's wire: text/csv;charset=UTF-8, chunked, Content-Disposition" % lab)
    gaps = grab_all(ls, r"^  gap \| (?!named)(.+)$")
    n = g1(ls, r"^  gap \| named: (\d+)", "gaps")
    need(str(len(gaps)) == n and int(n) > 0, "every gap named (%s)" % n)
    VALS["gaps"] = n


def c_spec(ls):
    need(g1(ls, r"the committed file against the served document[^:]*: (\w+)", "equal") == "equal", "the committed file = the served document")
    m = grab(ls, r"committed md5 before ([0-9a-f]{32}) · after ([0-9a-f]{32}) · bytes before (\d+) · after (\d+)", "md5s")
    a = grab(ls, r"the diff against before's \(13b1967's\) file: (\d+) lines added, (\d+) removed", "diff")
    o = grab(ls, r"before: OPERATIONS (\d+) PATHS (\d+) · after: OPERATIONS (\d+) PATHS (\d+)", "ops")
    need(o is not None and int(o.group(3)) == int(o.group(1)) + 3 and int(o.group(4)) == int(o.group(2)) + 3, "three operations and three paths added")
    need(g1(ls, r"the old operations' ids before -> after: (\w+)", "old ids") == "equal", "the old operations' ids equal (R.535)")
    need(g1(ls, r"ops9s3.py on an empty spec: exit (\d+)", "empty") == "1", "the counter refuses an empty spec (exit 1)")
    need(g1(ls, r"operationIds unique: (\w+)", "unique") == "yes", "operationIds unique")
    need(a is not None and a.group(2) == "0", "the diff removes no line")
    pa = g1(ls, r"the paths added: (\[[^\]]*\])", "paths added")
    need(pa == "['/api/v1/customers/{name}/bill', '/api/v1/customers/{name}/bill-link', '/api/v1/customers/{name}/bill/signed']", "the three paths added")
    need(g1(ls, r"other paths moved (\[[^\]]*\])", "moved") == "[]", "no old path moved")
    c = grab(ls, r"the client: counts - equal (\d+) · date line only (\d+) · lines added only (\d+) · moved (\d+) · added (\d+)", "client counts")
    need(c is not None and c.group(4) == "0", "no client file moved beyond the date line and added lines")
    t = grab(ls, r"the client: its test in after/'s build: tests (\d+) failures (\d+) errors (\d+)", "client test")
    need(t is not None and t.groups() == ("1", "0", "0"), "the client's test passes on the client rebuilt from the regenerated spec")
    f = grab(ls, r"the client: FILES (\d+) -> (\d+)", "FILES")
    pc = grab(ls, r"PATH_\* constants \(ops9s3.py paths, a CHECK\): before PATH_CONSTANTS (\d+) FILES \d+ · after PATH_CONSTANTS (\d+) FILES \d+", "PATH")
    need(pc is not None and pc.group(1) == "18", "PATH_* before: 18 (a check)")
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
    new = {k for k in b if "the new routes" in k}
    yaml = {k for k in b if k.startswith("GET /v3/api-docs.yaml")}
    mv = sorted(k for k in b if k in a and b[k] != a[k] and k not in new | yaml)
    for k in mv:
        print("  moved: %s | before %s | after %s" % (k, b[k], a[k]))
    need(not mv, "no old request moved (%d)" % len(mv))
    need(all(b[k].startswith("404") and a[k].startswith("200") for k in new), "the new routes: 404 on before, 200 on after/ (the added routes, not a move)")
    j = grab(ls, r"jar \| the web jar's entries: added (\d+) (\[[^\]]*\]) · removed (\d+) · shared entries whose CRC moved (\d+) (\[[^\]]*\])", "jar")
    need(j is not None and j.group(3) == "0", "the jar removed no entry")
    VALS["moved"] = str(len(mv))
    VALS["named"] = str(len(sorted(k for k in new | yaml if b.get(k) != a.get(k))))
    if j:
        VALS["jar"] = "added=%s,crc_moved=%s" % (j.group(1), j.group(4))


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
    b = grab(ls, r"^  package \| class CustomerBillsTest \| tests (\d+) failures 0 errors 0 skipped 0", "CustomerBillsTest")
    k = int(b.group(1)) if b else 0
    br = grab(ls, r"^  package \| class BillingRunsTest \| tests (\d+)", "BillingRunsTest")
    need(br is not None and br.group(1) == "4", "BillingRunsTest still 4")
    wb = int(g1(ls, r"web tests before \(unit 17's values\): (\d+)", "web before", "0"))
    need(p[0] == wb + k, "web %d = unit 17's %d + CustomerBillsTest's %d" % (p[0], wb, k))
    o = grab(ls, r"web classes other than CustomerBillsTest .*: (\d+) classes, (\d+) tests", "others")
    need(o is not None and int(o.group(2)) == wb, "the other web classes' tests = unit 17's %d (no existing class moved)" % wb)
    v = grab(ls, r"verify exit (\d+) · ITs tests (\d+) failures (\d+) errors (\d+) · classes (\d+)", "verify")
    need(v is not None and v.groups() == ("0", "14", "0", "0", "5"), "verify: exit 0, 14 ITs, 0 failures, 5 classes")
    need(g1(ls, r"IT bindings: (\d+) lines", "bindings") == "5" and g1(ls, r"not 127\.0\.0\.1: (\d+)", "not local") == "0", "five IT BINDINGS lines, all 127.0.0.1")
    need(g1(ls, r"downloads across the builds: (\d+)", "downloads") == "0", "0 downloads")
    need(g1(ls, r"the slice's file byte-equal to before's: (\w+)", "slice") == "yes", "the slice unedited (measured)")
    lb = grab(ls, r"BOOT-INF/lib: before (\d+) · after (\d+) · name lists (\w+)", "lib")
    need(lb is not None and lb.groups() == ("164", "164", "equal"), "BOOT-INF/lib 164 -> 164, the name lists equal")
    VALS["web_tests"] = str(p[0]); VALS["web_before"] = str(wb); VALS["k"] = str(k); VALS["its"] = v.group(2) if v else "?"


def c_exercise(ls):
    for sh in ("bash", "zsh"):
        need(any(re.match(r"^  broken %s \| check exit 1$" % sh, l) for l in ls), "broken under %s: check exit 1" % sh)
        need(any(re.match(r"^  solved %s \| check exit 0$" % sh, l) for l in ls), "solved under %s: check exit 0" % sh)
        need(any(re.match(r"^  broken %s \| FAIL \(2\)" % sh, l) for l in ls), "broken under %s: clause 2 named" % sh)
    m = grab(ls, r"^  broken bash \| measured: the signed download -> (\d+) (\S+) · title (.+?) · detail (.+)$", "measured")
    need(m is not None and m.group(1) == "500" and m.group(2) == "application/problem+json" and m.group(4) == "Failed to write request", "measured first on the named route: 500, Failed to write request")
    b = grab(ls, r"^  broken bash \| measured: the bill route -> (\d+)", "bill")
    need(b is not None and b.group(1) == "200", "the bill route on the broken JVM: 200 (the bill streams fine elsewhere)")
    for v, cl in (("object", "6"), ("fixedelsewhere", "5"), ("hardcoded", "2"), ("nosignature", "4")):
        if any(l.startswith("  ~ %s bash |" % v) for l in ls):
            need(any(re.match(r"^  ~ %s bash \| FAIL \(%s\)" % (v, cl), l) for l in ls), "refused variant %s fails clause %s" % (v, cl))
    VALS["ex_broken"] = "500,bill=200" if m and b else "?"


def c_inert(ls):
    need(g1(ls, r"key header in this run's captures: (\d+)", "key") == "0", "no capture carries the key header")
    need(g1(ls, r"MockMvc runs carry the key header: (\d+)", "mockmvc") == "0", "MockMvc runs send no key")


def c_section(ls):
    c = grab_all(ls, r"^  section \| ([0-9a-f]{7}) Course 9 unit (\d+)")
    need([x.group(2) for x in c] == ["13", "14", "15", "16", "17"], "the five earlier Section 3 commits, in order (%s)" % [x.group(2) for x in c])
    s = grab_all(ls, r"^  section \| unit (\d+)'s after/: OPERATIONS (\d+) PATHS (\d+)")
    need(len(s) == 6, "the spec's counts at each after/ (%d)" % len(s))
    need(g1(ls, r"up next, by title only: (.+?) = ", "next") == "Rate Limiting" and g1(ls, r"TRACK-ROADMAP.md:393's: (\w+)", "rm") == "yes", "up next: Rate Limiting, the roadmap's row 19")
    VALS["section"] = ",".join("%s=%s" % (x.group(1), x.group(2)) for x in s)


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
    need(os.path.islink("before") and os.readlink("before") == "../c9-unit17/after", "before is a link whose text is ../c9-unit17/after")
    need(os.path.isdir("after") and not os.path.islink("after"), "after/ is a directory")
    A = lambda p: open(os.path.join(after, p), encoding="utf-8").read()
    Bf = lambda p: open(os.path.join(before, p), encoding="utf-8").read()
    H = lambda p: git("-C", u, "show", "%s:c9-unit17/after/%s" % (HASH17, p))
    W = "tiffinbox-web/src/main/java/com/tiffinbox/web/"
    need(H("pom.xml") == Bf("pom.xml") and H(W + "BillingRuns.java") == Bf(W + "BillingRuns.java"), "before's pom and BillingRuns = git show %s:c9-unit17/after/… (the pinned hash, not the live tree)" % HASH17)
    cb = A(W + "CustomerBills.java")
    code = re.sub(r"(?s)/\*.*?\*/|//[^\n]*", "", cb)
    need(re.search(r"^final class CustomerBills \{", cb, re.M) is not None, "CustomerBills is final (C6 (a))")
    for r in ('@GetMapping("/api/v1/customers/{name}/bill")', '@GetMapping("/api/v1/customers/{name}/bill-link")', '@GetMapping("/api/v1/customers/{name}/bill/signed")'):
        need(r in cb, "CustomerBills maps %s" % r)
    need(len(re.findall(r"@(?:Get|Post|Put|Patch|Delete|Request)Mapping", code)) == 3, "three mappings, no write route (C1 (a))")
    for k in ("Pageable", "JsonView", "MappingJacksonValue", "Probe", "/probe/", "ttlSeconds", "ResponseEntity<?>", "ResponseEntity<Object>", "awssdk", "PostMapping"):
        need(k not in code, "CustomerBills' code holds no %s" % k)
    need(code.count("MessageDigest.isEqual(") == 1, "one MessageDigest.isEqual comparison (C3)")
    need(code.count("ResponseEntity<StreamingResponseBody> bill(") == 1 and code.count("ResponseEntity<StreamingResponseBody> signedBill(") == 1, "both downloads declared ResponseEntity<StreamingResponseBody>")
    need(not re.search(r"Duration\.of|ofMinutes|ofSeconds|\b300\b|\b315360000\b", code), "no lifetime literal in the controller (C2)")
    need('@Value("${tiffinbox.bill-link-lifetime}")' in code and '@Value("${tiffinbox.bill-link-key:}")' in code, "the lifetime and the key read from settings (C2, C3)")
    need(not any(re.search(r"\bkey\b", re.sub(r'"[^"]*"', '""', l)) for l in code.splitlines() if "LOG.log" in l) and "new String(key" not in code, "the key is never logged")
    for n in ("BillingRuns", "OrderResources", "OrderPages", "CustomerReads", "CustomerFields", "CustomerNotFound", "CustomerImport", "TiffinBoxErrors", "TiffinBoxOpenApi",
              "TiffinBoxApiVersioning", "IdempotencyKeys", "IdempotencyKeyFilter"):
        need(A(W + n + ".java") == Bf(W + n + ".java"), "%s.java byte-equal to before's" % n)
    for n in ("OrderPages", "CustomerReads", "CustomerFields", "BillingRuns"):
        need(re.search(r"^final class %s" % n, A(W + n + ".java"), re.M) is not None, "%s still final" % n)
    for p in ("pom.xml", "tiffinbox-core/pom.xml", "tiffinbox-web/pom.xml", "tiffinbox-client/pom.xml",
              "Dockerfile", "compose.yaml", "tiffinbox-core/src/main/resources/db/migration/V6__tiffin_order.sql",
              "tiffinbox-web/src/test/java/com/tiffinbox/web/TiffinBoxWebTest.java", "tiffinbox-web/src/test/java/com/tiffinbox/web/OpenApiSpecTest.java",
              "tiffinbox-web/src/test/java/com/tiffinbox/web/OrderPagesTest.java", "tiffinbox-web/src/test/java/com/tiffinbox/web/CustomerFieldsTest.java",
              "tiffinbox-web/src/test/java/com/tiffinbox/web/OrderResourcesTest.java", "tiffinbox-web/src/test/java/com/tiffinbox/web/ApiVersionTest.java",
              "tiffinbox-web/src/test/java/com/tiffinbox/web/TiffinBoxRestDocsTest.java", "tiffinbox-web/src/test/java/com/tiffinbox/web/BillingRunsTest.java"):
        need(A(p) == Bf(p), "%s byte-equal to before's" % p)
    for d in ("tiffinbox-core", "tiffinbox-client"):
        fa = sorted(os.path.relpath(os.path.join(x, f), after) for x, _, fs in os.walk(os.path.join(after, d)) for f in fs)
        fb = sorted(os.path.relpath(os.path.join(x, f), before) for x, _, fs in os.walk(os.path.join(before, d)) for f in fs)
        need(fa == fb and all(A(p) == Bf(p) for p in fa), "%s unchanged (%d files)" % (d, len(fa)))
    ya, yb = A("tiffinbox-web/src/main/resources/application.yaml"), Bf("tiffinbox-web/src/main/resources/application.yaml")
    added = [l for l in ya.splitlines() if l not in yb.splitlines()]
    need(ya.replace("".join(l + "\n" for l in added), "", 1) == yb and len(added) >= 2 and added[-1] == "  bill-link-lifetime: 5m" and all(l.startswith("  #") for l in added[:-1]),
         "application.yaml = before's + the lifetime key and its comment lines, nothing else (C2 (a))")
    for k in ("compression", "forward-headers", "hateoas", "billing", "pause", "bill-link-key"):
        need(k not in ya, "application.yaml holds no %s key" % k)
    hs = [m.group(1) for d, _, fs in os.walk(os.path.join(after, "tiffinbox-web/src/main/java")) for f in fs
          for m in re.finditer(r"@(?:Get|Post|Put|Patch|Delete|Request)Mapping[^\n]*\n(?:\s*@[^\n]*\n)*\s*[\w<>.,? ]+? (\w+)\(", open(os.path.join(d, f), encoding="utf-8").read())]
    for h in ("bill", "billLink", "signedBill", "startBillingRun", "billingRun"):
        need(hs.count(h) == 1, "%s occurs once among the mapped handlers (%d)" % (h, hs.count(h)))
    sp = json.load(open(os.path.join(after, "tiffinbox-web/src/test/resources/openapi/tiffinbox.json")))
    sb = json.load(open(os.path.join(before, "tiffinbox-web/src/test/resources/openapi/tiffinbox.json")))
    ids = [o.get("operationId") for v in sp["paths"].values() for o in v.values()]
    idb = {(k, m): o.get("operationId") for k, v in sb["paths"].items() for m, o in v.items()}
    need(len(ids) == len(set(ids)) and "servers" not in sp, "the committed spec's operationIds unique, no servers")
    need(all(sp["paths"].get(k, {}).get(m, {}).get("operationId") == i for (k, m), i in idb.items()), "the %d old operationIds equal before's" % len(idb))
    t = A("tiffinbox-web/src/test/java/com/tiffinbox/web/CustomerBillsTest.java")
    need(not re.search(r"@(?:org\.junit\.jupiter\.api\.(?:condition\.)?)?(?:Disabled|EnabledIf\w*|DisabledIf\w*|EnabledOn\w*|DisabledOn\w*|EnabledFor\w*|DisabledFor\w*)\b", t),
         "CustomerBillsTest: no @Disabled / @EnabledIf... / @DisabledIf... in the simple or the fully-qualified form")
    need(not re.search(r"RANDOM_PORT|DEFINED_PORT|LocalServerPort|\bSocket\b|\b\d{4,5}\b(?!-)", re.sub(r'"[^"]*"', '""', t)), "CustomerBillsTest names no port and no socket")
    need(not re.search(r"Thread\.sleep\([^)]*\d", t), "CustomerBillsTest: no Thread.sleep with a typed number (R.525)")
    need("@TestPropertySource" in t and "tiffinbox.bill-link-lifetime" in t, "CustomerBillsTest: the short lifetime by @TestPropertySource (C13 (a))")
    me = open(__file__, encoding="utf-8").read(); rs = open("receipts.sh", encoding="utf-8").read()
    for n in LEFT_OUT:
        need(not re.search(r"^def c_%s\(" % n, me, re.M) and not re.search(r"^cap %s " % n, rs, re.M), "the left-out capture %s is in neither the checker nor receipts.sh" % n)
    for f in ("walk.py", "follow.py", "seal9.py", "cdp.mjs", "cdp9.mjs", "loc9.py", "Gzip14.java", "U16Hal.java", "U16Next.java", "src/probe/u16", "src/probe/u17"):
        need(not os.path.exists("harness/" + f), "harness/%s absent" % f)
    need(sorted(os.listdir("harness/presign")) == ["Presign.java", "pom.xml"], "harness/presign holds the POM and Presign.java only")
    pom = open("harness/presign/pom.xml", encoding="utf-8").read()
    need("spring-boot-starter-parent 4.1.3" in pom and "X-Amz-* query keys" in pom and "compatible" not in pom.lower(), "R.515: the harness POM's comment names the parent line and the measured surface, never 'compatible'")
    need(" -pl tiffinbox-core" not in rs, "no -pl tiffinbox-core form (R.391)")
    for p in ("pom.xml", "tiffinbox-core/pom.xml", "tiffinbox-web/pom.xml", "tiffinbox-client/pom.xml"):
        need("awssdk" not in A(p), "%s names no awssdk" % p)
    # flag 31: no static assertion of this unit reads the live anchor - written whole or built from pieces
    src = me.split("def static(", 1)[1].split("\ndef ", 1)[0]
    q = chr(34); piece = re.escape(q + "c9" + "-" + q) + r"\s*\+"
    need(("c9" + "-" + "tiffinbox") not in src and not re.search(piece, src), "static names no live anchor path, whole or in pieces (flag 31)")
    need(not os.path.exists(os.path.join(after, ".git")), "after/ is a plain frozen copy")
    r = open("README.md", encoding="utf-8").read()
    prose = re.sub(r"```.*?```", "", r, flags=re.S)
    prose = re.sub(r"<!-- values: begin -->.*?<!-- values: end -->", "", prose, flags=re.S)
    nocode = re.sub(r"`[^`]*`", "", prose)
    need(not re.search(r"(?<![\w.:<])\d{1,2}:\d{2}(?::\d{2})? ?(?:CET|UTC)?\b", nocode.split("## Runs of record")[0]), "README: no clock figure before the runs section")
    card = A("README.md").split("## Course 9 · unit 18", 1)
    need(len(card) == 2 and not re.search(r"web (?:tests )?`?71`?(?! at unit 17)", card[1].split("\n## ", 1)[0]), "the anchor's unit 18 card gives 71 as unit 17's count only")


def brief18():
    t = open(BRIEF, encoding="utf-8").read()
    return t.split("## Unit 18", 1)[1].split("\n## ", 1)[0]


def hook():
    m = re.search(r'\*\*Hook \(\[S3 §11\]\):\*\* "([^"]+)"', brief18())
    print(m.group(1) if m else "FAIL no hook line")


def exq():
    m = re.search(r'\*\*Exercise:\*\* "(Your turn: [^"]+)"', brief18())
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
    need(sum(1 for l in ls if l.startswith("A presigned URL:")) == 1, "exactly one README line starts with the presigned-URL gloss")
    need(GLOSS in ls, "the gloss line byte for byte")
    need(len(GLOSS.split()) <= 25, "the gloss %d words (<= 25)" % len(GLOSS.split()))
    for g in ("`HAL`:", "HAL:", "A status resource:", "A link relation:", "A sparse fieldset:", "A cursor:", "A version carrier:", "A snippet:", "A contract:", "Swagger UI:",
              "A problem type:", "Code generation:"):
        need(not any(l.startswith(g) for l in ls), "no second gloss of an earlier unit's kind (%s)" % g)
    base = os.path.dirname(os.path.dirname(os.path.abspath(readme)))
    for u, g in (("13", "A cursor:"), ("14", "A sparse fieldset:"), ("15", "A link relation:"), ("16", "`HAL`:"), ("17", "A status resource:")):
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
    ("proxy", "status line HTTP/1.1 200 <none>", "status line HTTP/1.1 200 OK", "a reason phrase typed"),
    ("proxy", "Content-Length: absent · Transfer-Encoding: chunked", "Content-Length: present · Transfer-Encoding: chunked", "Content-Length typed present"),
    ("proxy", "Content-Length: absent · Transfer-Encoding: chunked", "Content-Length: absent · Transfer-Encoding: none", "Transfer-Encoding typed absent"),
    ("proxy", "diff against the wire's file: empty", "diff against the wire's file: DIFFERS", "the bill typed the same as Course 6's with a non-empty diff"),
    ("proxy", "the saved file's wc -c 8388608", "the saved file's wc -c 8388607", "the blob's bytes one off"),
    ("declared", "the signed download -> 500", "the signed download -> 200", "the wildcard's answer typed 200"),
    ("declared", "detail=Failed to write request", "detail=Could not write", "the message typed other than the print"),
    ("declared", "the bill route on the same JVM -> 200", "the bill route on the same JVM -> 500", "the bill on the broken copy typed 500"),
    ("signed", "(ii) the name changed (Ravi -> Sunil, expires and sig kept) -> 403", "(ii) the name changed (Ravi -> Sunil, expires and sig kept) -> 200", "the changed name typed 200"),
    ("signed", "(iii) expires raised by a day's seconds, the old sig kept -> 403", "(iii) expires raised by a day's seconds, the old sig kept -> 200", "the raised expires typed 200"),
    ("signed", "the first refusal 403", "the first refusal 200", "the expired link typed 200"),
    ("signed", "opened at once after the mint -> 200 (valid when minted)", "opened at once after the mint -> 403 (valid when minted)", "a link minted already expired (RED3 #28)"),
    ("signed", "a minted href in the answer: no", "a minted href in the answer: yes", "the planted ttlSeconds minted a link"),
    ("signed", "(viii) the mint is open", "(viii) the mint is closed", "the open-mint print left out"),
    ("presign", "interfaces ['lo'] · route rows 0", "interfaces ['lo', 'eth0'] · route rows 0", "a non-lo interface (a copy of the capture, never an unsealed run)"),
    ("presign", "interfaces ['lo'] · route rows 0", "interfaces ['lo'] · route rows 1", "a route-table row"),
    ("presign", "--network none --pull never", "--pull never", "the run line without --network none"),
    ("presign", "X-Amz-Expires,X-Amz-Signature]", "X-Amz-Expires]", "the key list one key short"),
    ("presign", "X-Amz-Expires=<masked>", "X-Amz-Expires=300", "X-Amz-Expires unmasked"),
    ("defaults", "PRESIGN regiononly · FAILED", "PRESIGN regiononly · OK", "regiononly typed OK"),
    ("expect", "curl's receipt of HTTP/1.1 100 -> the first body bytes sent", "the first body bytes sent -> curl's receipt of HTTP/1.1 100", "the order typed body before the 100"),
    ("expect", "(no Expect header) -> 413 · an HTTP/1.1 100 in its trace: 0", "(no Expect header) -> 413 · an HTTP/1.1 100 in its trace: 1", "the -H 'Expect:' leg typed with a 100"),
    ("refuse", "type=tag:tiffinbox.example,2026:link-malformed", "type=none", "the route's 400 typed without its type"),
    ("census", "final, default-run 11", "final, default-run 12", "the census one off"),
    ("spec", "the old operations' ids before -> after: equal", "the old operations' ids before -> after: differ", "an operationId renumbered"),
    ("spec", "ops9s3.py on an empty spec: exit 1", "ops9s3.py on an empty spec: exit 0", "an empty spec accepted"),
    ("specwire", "| bill | GET /api/v1/customers/{name}/bill · operationId bill · responses ['200', '400', '404'] · 200 media ['text/csv']", "| bill | GET /api/v1/customers/{name}/bill · operationId bill · responses ['200', '400', '404'] · 200 media ['*/*']", "the bill typed documented */* where the census prints text/csv"),
    ("seven", "the seven 466c20ed", "the seven 466c20ee", "the seven one character off"),
    ("tests", "skipped 0", "skipped 1", "Skipped typed 1"),
    ("exercise", "measured: the signed download -> 500", "measured: the signed download -> 200", "the broken state's answer borrowed"),
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
    # a listing line it cannot parse: a FAIL line, never a traceback
    f0 = FAILS; FAILS = []
    buf = io.StringIO()
    with contextlib.redirect_stdout(buf):
        try:
            c_presign(["  presign | Inter-|   Receive", "\x00garbage", "Exception in thread main"])
        except Exception as e:
            fail("traceback (%s)" % e)
    caught = bool(FAILS) and not any("traceback" in x for x in FAILS); FAILS = f0
    if need(caught, "plant an unparsable listing: a FAIL line, no traceback"):
        n += 1
    here = os.path.dirname(os.path.abspath(__file__))
    tmp = tempfile.mkdtemp()
    try:
        for what, s in (("presigned URLs need no credentials", "Presigned URLs need no credentials."), ("the SDK makes no network calls", "The SDK makes no network calls."),
                        ("only Ravi", "Only Ravi can open Ravi's bill."), ("a lifetime typed", "The link lasts five minutes."), ("the store checks", "The store checks the signature."),
                        ("a ranking word", "Proxying is slow."), ("buffered", "The bill is buffered."), ("at once", "Tomcat answers at once."),
                        ("the same bytes", "It sends the same bytes."), ("the spec documents the bill correctly", "The spec documents the bill correctly."),
                        ("a status in digits", "It answers 403."), ("bare expires=", "The link carries expires= and a signature.")):
            q = os.path.join(tmp, "p.md")
            open(q, "w", encoding="utf-8").write(s + "\n")
            r = subprocess.run([sys.executable, "-I", "-B", os.path.join(here, "s918.py"), os.path.join(here, "dur9.py"), q], capture_output=True, text=True)
            last = (r.stdout.strip().splitlines() or [""])[-1]
            if need(r.returncode == 0 and not last.endswith("refused: 0"), "plant README / %s: refused by s918.py" % what):
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
