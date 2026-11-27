"""Course 9 unit 20's checks (python3 -I -B harness/chk20.py SUBCOMMAND ...), run from c9-unit20/.

Each capture's check reads the masked capture file the receipt wrote (.r-NAME.new) and prints "ok ..." or "FAIL ..." lines and one
"VALUES ..." line; any FAIL exits 1 (a line it cannot parse is a FAIL line, exit 1, never a traceback). `static` reads only this unit's
frozen after/, before (the link to ../c9-unit19/after) and git objects of unit 19's commit (0609870:c9-unit19/after/...) - never the live
anchor: an audit hook refuses any open() whose real path lies in the live anchor's folder, so a static read of it exits 1 (flag 31).
Subcommands: static AFTER BEFORE · static-plant live|pieces · gloss README · gloss-line · hook · exq · interleaved · hashable NAME FILE ·
values README VALS · plants DIR · and one per capture: advisory before change census shallow paths weak deep ifmatch cache chrome metrics
spec moved api seven surface moving inert tests harness exercise.
"""
import hashlib, os, re, subprocess, sys

ANCHOR_DIR = "/c9-" + "tiffinbox"   # LIVE_ANCHOR_PLANT: the live anchor's folder name, assembled so a grep for it finds only this line


def _guard(event, args):
    if event == "open" and args and isinstance(args[0], (str, bytes, os.PathLike)):
        p = os.path.realpath(os.fsdecode(args[0]))
        if (ANCHOR_DIR + "/") in p or p.endswith(ANCHOR_DIR):
            raise SystemExit("FAIL flag 31: a static check read the live anchor (%s)" % p)


GLOSS = "A precondition: a condition the server checks before it writes."
H19 = "0609870"
LEFT_OUT = ["limit", "forge", "xff", "refill", "scope", "twojvm", "lua", "defaults", "restart", "proxy", "declared", "signed", "presign",
            "sealed", "expect", "specwire", "blob", "bills", "poll", "accept", "callpg", "html", "walk", "pageable", "trap", "table", "first", "next"]
OUT = []
BUDGET = 250


def ok(c, msg):
    OUT.append(("ok " if c else "FAIL ") + msg)
    return c


def finish(values=""):
    for l in OUT: print(l)
    if values is not None: print("VALUES " + values)
    sys.exit(1 if any(l.startswith("FAIL") for l in OUT) else 0)


def grab(text, rx, flags=re.M):
    m = re.search(rx, text, flags)
    return m.group(1) if m else None


def md5(b): return hashlib.md5(b).hexdigest()


WEB = "tiffinbox-web/src/main/java/com/tiffinbox/web/"
EXPECTED_CHANGED = ["A " + WEB + "ConditionalGets.java", "A tiffinbox-web/src/test/java/com/tiffinbox/web/ConditionalGetTest.java",
                    "M README.md", "M tiffinbox-core/src/main/java/com/tiffinbox/CustomerRepository.java",
                    "M " + WEB + "CustomerPatches.java", "M " + WEB + "CustomerReads.java"]
BYTE_EQUAL = [WEB + n + ".java" for n in ("CustomerBills", "CustomerFeed", "RateLimitFilter", "RateLimiting", "IdempotencyKeys", "IdempotencyKeyFilter",
                                          "TiffinBoxErrors", "TiffinBoxOpenApi", "TiffinBoxApiVersioning", "OrderResources")] + \
             ["Dockerfile", "compose.yaml", "pom.xml", "tiffinbox-web/pom.xml", "tiffinbox-core/pom.xml", "tiffinbox-client/pom.xml",
              "tiffinbox-web/src/main/resources/application.yaml", "tiffinbox-web/src/main/resources/application-dev.yaml",
              "tiffinbox-web/src/test/resources/openapi/tiffinbox.json"]


def walk(r):
    out = {}
    for d, ds, fs in os.walk(r):
        for f in fs:
            p = os.path.join(d, f); out[os.path.relpath(p, r)] = md5(open(p, "rb").read())
    return out


def gitobj(rel):
    top = subprocess.run(["git", "rev-parse", "--show-toplevel"], capture_output=True, text=True).stdout.strip()
    r = subprocess.run(["git", "-C", top, "show", "%s:c9-unit19/after/%s" % (H19, rel)], capture_output=True)
    return r.stdout if r.returncode == 0 else None


def static(a, b):
    sys.addaudithook(_guard)
    A, Bt = walk(a), walk(b)
    ch = sorted(["A " + k for k in A if k not in Bt] + ["D " + k for k in Bt if k not in A] + ["M " + k for k in A if k in Bt and A[k] != Bt[k]])
    ok(ch == sorted(EXPECTED_CHANGED), "the changed set (after/ against before, derived) is flag 2's: %s" % " · ".join(ch))
    for rel in BYTE_EQUAL:
        g = gitobj(rel)
        ok(g is not None and md5(g) == A.get(rel), "%s byte-equal to git show %s:c9-unit19/after/%s" % (rel, H19, rel))
    for k in sorted(Bt):
        if k.startswith("tiffinbox-web/src/test/") and k in A and A[k] != Bt[k]: ok(False, "an existing test file was edited: " + k)
    ok(True, "every existing test file byte-equal to before's (%d files)" % sum(1 for k in Bt if k.startswith("tiffinbox-web/src/test/")))
    ok(not any(k.startswith("tiffinbox-client/") for k in ch), "nothing under tiffinbox-client/ moved")
    c = open(os.path.join(a, WEB + "ConditionalGets.java"), encoding="utf-8").read()
    ok(re.search(r"^    static final class ApiEtags extends ShallowEtagHeaderFilter \{", c, re.M) is not None, "ConditionalGets: a nested final ShallowEtagHeaderFilter subclass")
    pats = re.findall(r'addUrlPatterns\(([^)]*)\)', c)
    ok(pats == ['"/api/v1/*"'], "ConditionalGets registers exactly /api/v1/* (%s)" % pats)
    ok('"/*"' not in c, "no \"/*\" literal in ConditionalGets")
    ok("ORDER = -80" in c, "the filter's order -80 (after the limiter's -95 and the key filter's -90)")
    ok(re.findall(r'Pattern\.compile\("([^"]*)"\)', c) == ["/api/v1/customers/[^/]+/bill(/signed)?"], "the exclusion names the two bill shapes only")
    ok("getHeader" not in c and "@Component" not in c, "ConditionalGets reads no header and is no @Component")
    src = ""
    for root in ("tiffinbox-web/src/main", "tiffinbox-core/src/main"):
        for d, ds, fs in os.walk(os.path.join(a, root)):
            for x in fs:
                if x.endswith(".java"): src += open(os.path.join(d, x), encoding="utf-8").read()
    ok(re.search(r"\bProbe|probe\.s4|/probe/|THE PROBE", src) is None, "no probe name in src/main")
    ok('getHeader("If-' not in src, "no hand-rolled If- header parser in src/main (getHeader(\"If-: 0)")
    rd = open(os.path.join(a, WEB + "CustomerReads.java"), encoding="utf-8").read()
    ok("No validator header is sent here" not in rd, "CustomerReads' stale sentence rewritten")
    ok('ResponseEntity.ok().eTag(tag(found.version()))' in rd and "Customer> one(@PathVariable String name)" in rd, "CustomerReads.one: the deep tag, the parameter list (String) kept")
    pt = open(os.path.join(a, WEB + "CustomerPatches.java"), encoding="utf-8").read()
    ok(pt.count("request.checkNotModified(CustomerReads.tag(row.version()))") == 1, "CustomerPatches: one If-Match check, in apply")
    core_b = open(os.path.join(b, "tiffinbox-core/src/main/java/com/tiffinbox/CustomerRepository.java"), encoding="utf-8").read()
    core_a = open(os.path.join(a, "tiffinbox-core/src/main/java/com/tiffinbox/CustomerRepository.java"), encoding="utf-8").read()
    added = len(re.findall(r"^    public \S.*\(", core_a, re.M)) - len(re.findall(r"^    public \S.*\(", core_b, re.M))
    ok(added == 2 and "public Optional<Versioned> findVersioned(String name)" in core_a, "core: one read method and its record (public signatures added: %d)" % added)
    t = open(os.path.join(a, "tiffinbox-web/src/test/java/com/tiffinbox/web/ConditionalGetTest.java"), encoding="utf-8").read()
    ok(re.search(r"@(org\.junit\.jupiter\.api\.(condition\.)?)?(Disabled|EnabledIf|DisabledIf|EnabledOn|DisabledOn|EnabledFor|DisabledFor)\w*", t) is None, "ConditionalGetTest: no disabling or conditional annotation, simple or fully qualified")
    tc = re.sub(r'"[^"\n]*"', '""', t)
    ok(re.search(r"RANDOM_PORT|DEFINED_PORT|LocalServerPort|\bSocket\b|(?<![\d.])\d{4,5}(?![\d.])", tc) is None, "ConditionalGetTest: no port, no socket, no 4-5 digit literal outside a string")
    readme = open(os.path.join(a, "README.md"), encoding="utf-8").read()
    card = readme.split("## Course 9 · unit 20", 1)
    ok(len(card) == 2, "the anchor README has a unit 20 card")
    if len(card) == 2:
        body = card[1].split("\n## ", 1)[0]
        bad = [l for l in body.splitlines() if re.search(r"(?<![\d.,])(81)(?![\d.,])", l) and "unit 19" not in l]
        ok(not bad, "the card gives 81 as unit 19's count only (%d lines otherwise)" % len(bad))
    ok("Course 9's sixteenth change to this folder (U20)" in readme, "the header note names the sixteenth change")
    me = open(__file__, encoding="utf-8").read()
    subs = set(re.findall(r'^    elif cmd == "([a-z0-9-]+)"', me, re.M)) | set(re.findall(r'^    if cmd == "([a-z0-9-]+)"', me, re.M)) | set(CHECKS)
    ok(not (subs & set(LEFT_OUT)), "no left-out subcommand in chk20.py (%s)" % sorted(subs & set(LEFT_OUT)))
    finish(None)


def brief():
    c9 = os.environ.get("C9R") or ""
    return open(os.path.join(c9, "_briefs/UNIT-BRIEFS-S4-OPERATING.md"), encoding="utf-8").read()


def unit20(): return brief().split("\n## Unit 20", 1)[1].split("\n## Unit 21", 1)[0]


def hook(): return re.search(r'^\*\*Hook \(\[S4 §\d+\]\):\*\* "([^"]+)"', unit20(), re.M).group(1)


def exq(): return re.search(r'^\*\*Exercise:\*\* "(Your turn: [^"]+)"', unit20(), re.M).group(1)


# ---- capture checks ----------------------------------------------------------------------------------------------------------------
def ans(t, lab):
    """the rq line whose label is exactly lab: (status, etag, content-type, framing, body bytes)"""
    m = re.search(r"^  %s -> (\d{3}) · ETag (.*?) · Content-Type (\S+) · (chunked|Content-Length: \d+|no framing header) · body (\d+) B" % re.escape(lab), t, re.M)
    if not m: raise ValueError("no answer line for %r" % lab)
    return int(m.group(1)), m.group(2), m.group(3), m.group(4), int(m.group(5))


def wit(t, side=""):
    """the witness's PROBE-REQ lines: (method uri, status, handler, post-handle count, statements, writes)"""
    pre = "witness %s |" % side if side else "witness |"
    rx = re.compile(r"^  %s PROBE-REQ \d+ (\S+ \S+) -> (\d{3}) \| handler (\S+) \| post-handle (?:yes \(count (\d+)\)|no) \| statements (\d+) \(writes (\d+)," % re.escape(pre), re.M)
    return [(m.group(1), int(m.group(2)), m.group(3), int(m.group(4) or 0), int(m.group(5)), int(m.group(6))) for m in rx.finditer(t)]


def budget(t):
    for m in re.finditer(r"^  budget \| (\S+): requests under /api/v1/ \(its access log\): (\d+) · refusal lines: (\d+)", t, re.M):
        if m.group(1) != "lim":
            ok(int(m.group(2)) <= BUDGET and m.group(3) == "0", "N13: %s sent %s /api/v1/ requests (<= %d), refusals %s" % (m.group(1), m.group(2), BUDGET, m.group(3)))
    return max([int(x) for x in re.findall(r"requests under /api/v1/ \(its access log\): (\d+)", t)] or [0])


def c_advisory(t):
    fa = grab(t, r"fetched-at (\S+) \(the hour masked\) · run date (\S+)")
    rd = grab(t, r"run date (\S+) ·")
    ok(fa is not None and fa == rd, "the read is the batch day's (fetched-at %s = run date %s)" % (fa, rd))
    for m in re.finditer(r"(\S+)/MD5SUMS.txt: (\d+) lines, (\d+) verified", t): ok(m.group(2) == m.group(3) and int(m.group(2)) > 0, "%s: %s of %s verified" % (m.group(1), m.group(3), m.group(2)))
    ok("tomcat page md5 a1a756d985225fb5143eefd9aae3183c " in t, "Tomcat's page = the earlier reads")
    o = re.search(r"(\d+) coordinates queried, (\d+) results, (\d+) with vulns", t)
    ok(o is not None and o.group(3) == "0", "OSV: %s" % (o.group(0) if o else "absent"))
    lib = re.search(r"lib names before (\d+) · after (\d+) · by name: (\w+)", t)
    ok(lib is not None and lib.group(1) == lib.group(2) == "167" and lib.group(3) == "equal", "BOOT-INF/lib 167 = 167 by name")
    ok("shipped | spring-webmvc 7.0.11" in t and "shipped | spring-boot 4.1.3" in t and "shipped | tomcat-embed-core 11.0.29" in t, "the pins: Boot 4.1.3, Framework 7.0.11, Tomcat 11.0.29")
    ok("verdict: no pin affected; evidence may proceed" in t, "the verdict")
    finish("fetched=%s lib=%s->%s" % (fa, lib.group(1) if lib else "", lib.group(2) if lib else ""))


def c_before(t):
    a = ans(t, "before GET /api/v1/customers/Ravi")
    ok(a[0] == 200 and a[1] == "none", "before: the public read 200 with no ETag")
    ok(ans(t, 'before GET /api/v1/customers/Ravi If-None-Match "v0"')[0] == 200, "before: If-None-Match answered by nothing (200)")
    ok(ans(t, "before GET /api/v1/customers")[1] == "none" and ans(t, "before GET /api/v1/orders/1")[1] == "none", "before: the list and the order untagged")
    bl = ans(t, "before GET /api/v1/customers/Ravi/bill")
    ok(bl[3] == "chunked" and bl[4] == 595, "before: the bill chunked, 595 B")
    w = wit(t)
    ok(len(w) == 2 and w[0][4] >= 1 and w[1][4] == 0 and w[1][3] == 2, "before, harness-joined: the cached read cold %s, warm %s statements (the handler ran: count %s)" % (w[0][4] if w else "?", w[1][4] if len(w) > 1 else "?", w[1][3] if len(w) > 1 else "?"))
    ok("apiEtagFilter" not in t, "before: no apiEtagFilter among the servlet filters")
    budget(t)
    finish("before=noetag warm_statements=%s cold_statements=%s lib=%s %s" % (w[1][4] if len(w) > 1 else "", w[0][4] if w else "", grab(t, r"BOOT-INF/lib names (\d+)"), grab(t, r"the committed spec: (.*?) ·")))


def c_change(t):
    ch = grab(t, r"changed \(derived: .*?\): (.*)$")
    got = sorted((ch or "").split(" · "))
    ok(got == sorted(EXPECTED_CHANGED), "the derived changed list is flag 2's (%d paths)" % len(got))
    ok("the \"/*\" literal: 0" in t and "getHeader): 0 · @Component: 0" in t, "ConditionalGets: no /* literal, no header read, no @Component")
    ok(re.search(r"src/main: getHeader\(\"If- 0 · checkNotModified \d+ · Probe/probe.s4//probe/ 0", t) is not None, "src/main: no hand parser, no probe")
    ok("public methods added 1 · records added 1" in t, "the core change: one read and its record")
    ok(not re.search(r"byte-equal to before's: no", t), "the listed files byte-equal to before's")
    ok(grab(t, r"handler names added: (\d+)") == "0", "no handler added")
    f = grab(t, r"after \| servlet filters: (.*)$") or ""
    ok("apiEtagFilter /api/v1/*" in f and "rateLimitFilter /api/v1/*" in f, "the running context: apiEtagFilter on /api/v1/* beside the limiter")
    ok("RateLimiting ORDER = -95 · IdempotencyKeys ORDER = -90 · ConditionalGets ORDER = -80" in t, "the orders -95, -90, -80")
    finish("changed=%d filters=%s" % (len(got), "apiEtagFilter:/api/v1/*"))


def c_census(t):
    b = grab(t, r"census before \| controllers (.*)$"); a = grab(t, r"census after \| controllers (.*)$")
    ok(b is not None and a == b, "the census before = after: %s" % b)
    ok(t.count("not a controller by the rule: ConditionalGets") == 1, "ConditionalGets named as no controller (after/ only)")
    sb = grab(t, r"the spec's counts .*?before (.*?) · after"); sa = grab(t, r"the spec's counts .*? · after (.*)$")
    ok(sb == sa, "the spec's counts equal: %s" % sb)
    nums = re.findall(r"\d+", b or "")
    finish("census=%s spec=%s files=%s" % ("/".join(nums[:4]), sb, grab(t, r"generated client's files \(after/'s build\): (\d+)")))


def _shr(t, lab, side=""):
    cold = ans(t, "%s GET /api/v1/customers (cold)" % lab); warm = ans(t, "%s GET /api/v1/customers (warm)" % lab)
    n304 = ans(t, "%s GET /api/v1/customers If-None-Match <its tag>" % lab); oth = ans(t, "%s GET /api/v1/customers If-None-Match another tag" % lab)
    hd = ans(t, "%s HEAD /api/v1/customers" % lab)
    o1 = ans(t, "%s GET /api/v1/orders/1 #1" % lab); o3 = ans(t, "%s GET /api/v1/orders/1 If-None-Match <its tag>" % lab)
    ok(cold[0] == 200 and cold[1] == '"<shallow tag>"' and cold[3].startswith("Content-Length"), "%s: the list 200, a strong shallow tag, Content-Length" % lab)
    ok(n304[0] == 304 and n304[4] == 0 and n304[1] == '"<shallow tag>"', "%s: the list's tag answered 304, no body, the tag repeated" % lab)
    ok(oth[0] == 200, "%s: another tag 200" % lab)
    ok(o1[0] == 200 and o1[1] == '"<shallow tag>"' and o3[0] == 304 and o3[4] == 0, "%s: the order 200 + tag, then 304" % lab)
    return hd


def c_shallow(t):
    hd = _shr(t, "free"); _shr(t, "wit"); _shr(t, "pg")
    ok("N3 | the two starts' answers (status, ETag, Content-Type, framing, body md5) equal: yes" in t, "N3: the witness adds no byte")
    ok("H2 and PostgreSQL: the answers equal: yes · the witness's handler and statement columns equal: yes" in t, "H2 = PostgreSQL 18.6 on answers and counts")
    for side, lab in (("", "H2"), ("pg ", "PostgreSQL")):
        w = wit(t, side.strip())
        lst = [x for x in w if x[0] == "GET /api/v1/customers"]; ords = [x for x in w if x[0] == "GET /api/v1/orders/1"]
        ok(len(lst) >= 4 and lst[0][4] >= 1 and all(x[4] == 0 for x in lst[1:]) and all(x[2] == "CustomerFields#customerFields" for x in lst), "%s: the cached list cold %d, then 0 on every warm answer, the 304 included; handler CustomerFields#customerFields each" % (lab, lst[0][4] if lst else -1))
        ok(all(x[3] >= 1 for x in w if x[1] == 304), "%s: the handler ran on every 304 (post-handle counted)" % lab)
        ok(len(ords) == 4 and all(x[4] >= 1 for x in ords) and [x[1] for x in ords] == [200, 200, 304, 304], "%s: the uncached order: statements >= 1 on every answer, both 304s included" % lab)
    star = wit(t, "star")
    rv = [x for x in star if x[0] == "GET /revenue"]; cr = [x for x in star if x[0] == "GET /customers/Ravi"]
    ok([x[1] for x in rv] == [200, 200, 304] and all(x[4] >= 1 for x in rv), "the /* copy: /revenue 200, 200, 304 - statements >= 1 each (uncached)")
    ok([x[1] for x in cr] == [200, 200, 304] and cr[1][4] == 0 and cr[2][4] == 0, "the /* copy: the old /customers/Ravi warm 0 statements, its 304 0")
    w = wit(t)
    lst = [x for x in w if x[0] == "GET /api/v1/customers"]; ords = [x for x in w if x[0] == "GET /api/v1/orders/1"]
    finish("cached=/api/v1/customers cold=%d warm=0 handler304=%d uncached=/api/v1/orders/1 statements304=%d pg=equal star_revenue304=%d" % (lst[0][4], lst[2][3], ords[2][4], rv[2][4] if len(rv) > 2 else -1))


def c_paths(t):
    f = grab(t, r"after \| servlet filters: (.*)$") or ""
    ok("apiEtagFilter /api/v1/*" in f, "the registration: apiEtagFilter on /api/v1/*")
    for s in ("before", "after"):
        fd = re.search(r"^  %s GET /customers/feed .*?reader exit (\d) · status (\d+) · (\S+) · ETag (\d) · chunked (\d) · body (\d+) B" % s, t, re.M)
        ok(fd is not None and fd.group(1) == "0" and fd.group(2) == "200" and fd.group(4) == "0", "%s: the feed's first event read (exit 0), no ETag" % s)
        for p in ("/revenue", "/actuator/health", "/v3/api-docs", "/customers/Ravi"):
            ok(ans(t, "%s GET %s" % (s, p))[1] == "none", "%s: %s untagged" % (s, p))
    bb = ans(t, "before GET /api/v1/customers/Ravi/bill"); ba = ans(t, "after GET /api/v1/customers/Ravi/bill")
    ok(ba[3] == "chunked" and ba[1] == "none" and ba[4] == 595, "after: the bill chunked, no ETag, 595 B")
    mb = grab(t, r"^  before GET /api/v1/customers/Ravi/bill -> .*? md5 (\w+)$"); ma = grab(t, r"^  after GET /api/v1/customers/Ravi/bill -> .*? md5 (\w+)$")
    ok(mb is not None and mb == ma, "the bill's md5 equal on both trees")
    sa = ans(t, "after GET <the signed link, opened inside its lifetime>")
    ok(sa[0] == 200 and sa[3] == "chunked" and sa[1] == "none", "after: the signed link 200, chunked, untagged")
    ok(ans(t, "after GET /api/v1/customers/Ravi/bill-link")[1] == '"<shallow tag>"', "after: the bill link (plain JSON) tagged")
    fs = re.search(r"^  star GET /customers/feed .*?reader exit (\d) · status (\S*) · .*? · body (\d+) B", t, re.M)
    ok(fs is not None and fs.group(1) == "3" and fs.group(3) == "0", "the /* copy: the feed starved (the reader's alarm, exit 3, 0 bytes)")
    dsh = ans(t, "star GET /dashboard (Accept: text/html)"); pc = ans(t, "star POST /customers (JSON, a fresh name)")
    ok(dsh[1] == '"<shallow tag>"' and dsh[3].startswith("Content-Length"), "the /* copy: the dashboard tagged, Content-Length (%s)" % dsh[3])
    m = re.search(r"star \| the old surface: before (\w+) · the /\* copy (\w+) · differ: (\w+) · diff lines (\d+) · answers that gained an ETag (\d+) · lost chunked (\d+)", t)
    ok(m is not None and m.group(3) == "yes" and int(m.group(5)) > 0, "S9.14: the /* copy's old surface differs from before's (the detector works)")
    nb = ans(t, "nobill GET /api/v1/customers/Ravi/bill")
    ok(nb[3] == "Content-Length: 595" and nb[4] == 595, "the unfiltered-bill copy: the bill buffered, Content-Length: 595")
    lim = [ans(t, "lim GET /api/v1/customers #%d" % i) for i in range(1, 7)]
    ok([x[0] for x in lim] == [200] * 5 + [429] and all(x[1] == '"<shallow tag>"' for x in lim[:5]) and lim[5][1] == "none" and lim[5][3].startswith("Content-Length"), "limiter (cap=5): five 200 with a tag, the sixth 429 with no tag")
    budget(t)
    finish("filter=/api/v1/* feed_after=first_event bill_after=chunked,595B,noetag star_feed=starved star_tagged=%s star_unchunked=%s nobill=%s dashboard=%s post=%s lim429_etag=none" % (m.group(5) if m else "", m.group(6) if m else "", nb[3], dsh[3], pc[3]))


def c_weak(t):
    rows = {"the tag": 304, "W/ + the tag": 304, "another": 200, "*": 200, "a list (another, the tag)": 304}
    got = {k: ans(t, "weak /api/v1/customers INM %s" % k)[0] for k in rows}
    ok(got == rows, "the list: %s" % got)
    d = {'"v0"': 304, 'W/"v0"': 304, '"v7"': 200, "*": 200, 'a list ("v7", "v0")': 304}
    gd = {k: ans(t, "weak /api/v1/customers/Ravi INM %s" % k)[0] for k in d}
    ok(gd == d, "the deep route: %s" % gd)
    tags = re.findall(r" -> \d{3} · ETag (.*?) · Content-Type", t)
    ok(tags and all(x.startswith('"') for x in tags if x != "none"), "every tag the server wrote starts with a quote, none with W/ (%d)" % sum(1 for x in tags if x != "none"))
    budget(t)
    finish("list=304,W304,other200,star200,list304 deep=304,W304,v7_200,star200,list304 weak_written=0")


def _deep(t, lab):
    a1 = ans(t, "%s GET /api/v1/customers/Ravi #1" % lab); n = ans(t, '%s GET /api/v1/customers/Ravi If-None-Match "v0"' % lab)
    ok(a1[0] == 200 and a1[1] == '"v0"' and a1[4] == 67, "%s: 200, ETag \"v0\", 67 B" % lab)
    ok(n[0] == 304 and n[4] == 0 and n[1] == '"v0"', "%s: If-None-Match \"v0\" -> 304, no body" % lab)
    ok(ans(t, '%s GET /api/v1/customers/Ravi If-None-Match "v7"' % lab)[0] == 200, "%s: \"v7\" -> 200" % lab)
    ok(ans(t, "%s HEAD /api/v1/customers/Ravi" % lab)[1] == '"v0"', "%s: HEAD carries the tag" % lab)
    ok(ans(t, "%s PATCH /api/v1/customers/Ravi (merge, no If-Match)" % lab)[0] == 200 and ans(t, "%s PATCH /api/v1/customers/Ravi (merge, no If-Match)" % lab)[1] == "none", "%s: a PATCH 200, no tag on its answer" % lab)
    ok(ans(t, "%s GET /api/v1/customers/Ravi after the PATCH" % lab)[1] == '"v1"', "%s: the tag moved to \"v1\"" % lab)
    ok(ans(t, '%s GET /api/v1/customers/Ravi If-None-Match "v0" (the old tag)' % lab)[0] == 200, "%s: the old tag now 200" % lab)
    ok(ans(t, "%s GET /customers/Ravi #1 (the old address)" % lab)[1] == "none", "%s: the old address untagged" % lab)


def c_deep(t):
    for lab in ("free", "wit", "pg"): _deep(t, lab)
    bm = grab(t, r"^  before GET /api/v1/customers/Ravi -> .*? md5 (\w+)$"); am = grab(t, r"^  free GET /api/v1/customers/Ravi #1 -> .*? md5 (\w+)$")
    ok(bm is not None and bm == am, "the 200's body byte-equal to before's (md5 %s)" % bm)
    ok(re.search(r'deep \| the tag a bare shallow filter would write on that body .*?: "<shallow tag>" - not the handler\'s tag', t) is not None, "a body hash is not the handler's tag")
    ok("N3 | the two starts' answers equal: yes" in t and "H2 and PostgreSQL: the answers equal: yes · the witness's handler and statement columns equal: yes" in t, "N3; H2 = PostgreSQL 18.6")
    for side, lab in (("", "H2"), ("pg", "PostgreSQL")):
        w = [x for x in wit(t, side) if x[0] == "GET /api/v1/customers/Ravi"]
        ok(len(w) == 6 and all(x[4] == 1 and x[2] == "CustomerReads#one" for x in w), "%s: every 200 and 304 of the public read 1 statement, handler CustomerReads#one (%s)" % (lab, [(x[1], x[4]) for x in w]))
        o = [x for x in wit(t, side) if x[0] == "GET /customers/Ravi"]
        ok(len(o) == 2 and o[1][4] == 0, "%s: the old address warm 0 (cached)" % lab)
    ok(re.search(r"witness \| PROBE-SQL \d+ select .* from customer ce1_0 where ce1_0\.name=\?", t) is not None, "the one statement: select ... from customer where name=?")
    i1 = ans(t, "ident GET /api/v1/customers/Zed (the first row)"); i2 = ans(t, "ident GET /api/v1/customers/Zed (the new row)")
    i3 = ans(t, 'ident GET /api/v1/customers/Zed If-None-Match "v0" (the first row\'s tag)')
    ok(i1[1] == '"v0"' and i2[1] == '"v0"' and ans(t, "ident GET /api/v1/customers/Zed-old (the first row, renamed)")[1] == '"v1"', "identity: the first row \"v0\" -> renamed \"v1\"; the re-created name \"v0\" again")
    ok(i3[0] in (200, 304), "identity: the first row's tag on the re-created name answered %d (read, not typed)" % i3[0])
    budget(t)
    finish('tag="v0" statements200=1 statements304=1 before_warm=0 pg=equal moved="v1" identity=%d' % i3[0])


IFM_EXPECT = {"(1) If-Match \"v0\" (current)": 200, "(2) If-Match \"v0\" again (stale)": 412, "(3) If-Match W/\"v1\" (weak, current)": 412, "(4) no If-Match": 200}


def c_ifmatch(t):
    res = {}
    for db in ("h2", "pg"):
        for r in ("merge", "json"):
            for k, v in IFM_EXPECT.items():
                a = ans(t, "%s %s %s" % (db, r, k)); res[(db, r, k)] = a[0]
                ok(a[0] == v, "%s %s %s -> %d" % (db, r, k, a[0]))
            g1 = ans(t, "%s %s GET after (1)" % (db, r)); g2 = ans(t, "%s %s GET after (2)" % (db, r)); g3 = ans(t, "%s %s GET after (3)" % (db, r))
            ok(g1[1] == '"v1"' and g2[1] == '"v1"' and g3[1] == '"v1"', "%s %s: the tag moved to \"v1\" and stayed after the stale and the weak tag" % (db, r))
            m1 = grab(t, r"^  %s %s GET after \(1\) -> .*? md5 (\w+)$" % (db, r)); m2 = grab(t, r"^  %s %s GET after \(2\) -> .*? md5 (\w+)$" % (db, r))
            ok(m1 is not None and m1 == m2, "%s %s: the customer read back unchanged after the stale tag" % (db, r))
            ok(ans(t, "%s %s GET after (4)" % (db, r))[1] == '"v2"', "%s %s: no If-Match wrote (\"v2\")" % (db, r))
        p = re.search(r"^  %s merge \(2\) If-Match \"v0\" again \(stale\) -> 412 · ETag none · Content-Type application/problem\+json · Content-Length: \d+ · body \d+ B md5 \w+ · members (\S+) · title Precondition failed · status 412 · type none" % db, t, re.M)
        ok(p is not None and p.group(1) == "detail,instance,status,title", "%s: the 412 a problem (detail, instance, status, title; no type)" % db)
        ok(ans(t, "%s merge (6) an unknown customer, If-Match stale" % db)[0] == 404, "%s: an unknown customer is the 404, not a 412" % db)
    ok("H2 and PostgreSQL: the answers equal: yes · the witness's handler and statement columns equal: yes" in t, "H2 = PostgreSQL 18.6 on every answer and count")
    for side, lab in (("", "H2"), ("pg", "PostgreSQL")):
        w = [x for x in wit(t, side) if x[0].startswith("PATCH /api/v1/customers/Ifm-")]
        st = [x for x in w if x[1] == 412]; good = [x for x in w if x[1] == 200]
        ok(st and all(x[5] == 0 and x[4] == 1 for x in st), "%s: every 412: 0 writes, 1 statement (the version read)" % lab)
        ok(good and all(x[5] == 1 for x in good), "%s: every 200 one write" % lab)
    ok(len(re.findall(r"witness (?:pg )?\| PROBE-SQL \d+ update customer set .*version=\? where id=\? and version=\?", t)) >= 4, "the UPDATE: ... version=? where id=? and version=? (H2 and PostgreSQL)")
    ok(re.search(r"postgres \| the version column: version bigint NO default 0", t) is not None, "PostgreSQL's column: version bigint not null default 0")
    star = ans(t, "h2 merge (5) If-Match *")[0]; lst = ans(t, 'h2 merge (5) If-Match a list "v0", "v3"')[0]
    mal = ans(t, "h2 merge (6) If-Match stale, a body that is not JSON")[0]; mt = ans(t, "h2 merge (6) If-Match stale, text/plain")[0]
    budget(t)
    finish("both_routes current=200 stale=412 weak=412 none=200 star=%d list=%d unknown=404 malformed_stale=%d mediatype=%d writes412=0 pg=equal" % (star, lst, mal, mt))


def c_cache(t):
    css = grab(t, r"the page's stylesheet link: (\S+)")
    ok(css is not None and "<md5>" in css, "the page links the versioned stylesheet (%s)" % css)
    p = ans(t, "cache GET /css/tiffinbox.css")
    ok(p[0] == 200 and p[1] == "none", "the plain stylesheet 200, no ETag")
    v = ans(t, "cache GET %s (the versioned name)" % css)
    ok(v[0] == 200 and v[1] == 'W/"<css md5>"', "the versioned name: 200 and a weak tag")
    a = ans(t, "cache %s If-None-Match its own tag alone" % css); b = ans(t, "cache %s If-Modified-Since its own date alone" % css)
    c = ans(t, "cache %s both headers" % css)
    ok(a[0] == 200 and a[4] > 0, "its own weak tag alone: 200, the whole stylesheet (still matches nothing)")
    ok(b[0] == 304 and b[4] == 0, "its own date alone: 304, no body")
    ok(re.search(r"ServletWebRequest\.checkNotModified:\(Ljava/lang/String;J\)Z", t) is not None, "javap: the static handler hands checkNotModified its tag and its date (String, long)")
    ok(c[0] == 200, "both headers: 200 (the tag that matches nothing decides)")
    finish("tag_alone=%d date_alone=%d both=%d javap=checkNotModified(String,long)" % (a[0], b[0], c[0]))


def c_chrome(t):
    def ev(leg, what):
        return re.findall(r"^  chrome20 %s %s \| (\S+) (\S+) \| responseReceived (\S+) \| responseReceivedExtraInfo (\S+) \| If-None-Match (.*?) \| ETag (.*?) \|" % (leg, what), t, re.M)
    a = ev("a", "reload"); ao = ev("a", "open")
    ok(ao and ao[0][2] == "200" and ao[0][3] == "200", "leg A open: the page 200 in both events")
    ok(len(a) >= 1 and a[0][0] == "Document" and a[0][2] == "200" and a[0][3] == "304" and a[0][4] == '"v0"', "leg A reload: the page - responseReceived 200, responseReceivedExtraInfo 304, If-None-Match \"v0\"")
    acc = [l for l in re.findall(r"^  access a \| (GET /api/v1/customers/Ravi .*)$", t, re.M)]
    ok(len(acc) == 2 and acc[0].startswith('GET /api/v1/customers/Ravi 200 67 "-" ') and acc[1].startswith('GET /api/v1/customers/Ravi 304 - "\\"v0\\"" "\\"v0\\"" ') and "Chrome/<version>" in acc[1], "leg A: TiffinBox's access log - 200 67, then 304 with If-None-Match \"v0\" from Chrome (%s)" % acc)
    b = ev("b", "reload")
    doc = [x for x in b if x[1] == "/dashboard"]; css = [x for x in b if x[1].startswith("/css/")]
    ok(doc and doc[0][2] == "200" and doc[0][3] == "304", "leg B reload: the page 200 / 304")
    ok(css and css[0][2] == "304" and css[0][3] == "304", "leg B reload: the stylesheet 304 in both events (a subresource)")
    accb = re.findall(r"^  access b \| (GET \S+ \d{3})", t, re.M)
    ok("GET /dashboard 304" in accb and "GET /css/tiffinbox.css 304" in accb, "leg B: the access log 304 for the page and the stylesheet")
    for leg in ("a", "b"):
        sv = grab(t, r"seal9\.py netlog \(%s\) exit (\d)" % leg)
        u = re.search(r"udp %s \| TCP connects not to 127\.0\.0\.1: (\d+) · UDP connects not to loopback: (\d+), each failed: (\w+) \(net_error (\S+)\) · UDP bytes sent: (\d+)" % leg, t)
        ok(u is not None and u.group(1) == "0" and u.group(3) == "yes" and u.group(5) == "0" and (sv == "0" or int(u.group(2)) > 0), "NetLog (%s): every TCP connect to 127.0.0.1; seal9.py netlog exit %s - its UDP refusal is Chrome's failed connect, 0 bytes sent" % (leg, sv))
        ok(re.search(r"seal9\.py cdp \(%s reload\) exit 0" % leg, t) is not None, "seal9.py cdp (%s reload): 127.0.0.1 only" % leg)
        ok(re.search(r"Chrome %s stopped by Browser.close .*?its pid gone, its profile folder removed" % leg, t) is not None, "Chrome %s stopped, its profile removed" % leg)
    ok("chrome20.py on an empty event file: exit 2" in t, "an empty capture refused (exit 2)")
    finish("A_page=responseReceived200,extraInfo304 A_access=200,304 B_css=304,304 B_page=200,304 netlog=tcp_127.0.0.1_only,udp_probe_failed_0B")


def c_metrics(t):
    m = re.search(r"met \| GET \S+ -> (\d+) · If-None-Match \"v0\" -> (\d+) · PATCH merge If-Match \"v9\" -> (\d+)", t)
    ok(m is not None and m.groups() == ("200", "304", "412"), "the sequence 200, 304, 412")
    rows = dict(((x[0], x[1]), (x[2], int(x[3]))) for x in re.findall(r"^  met \| (\w+) (\d+) (\w+): count (\d+)$", t, re.M))
    ok(rows.get(("GET", "304")) == ("REDIRECTION", 1) and rows.get(("PATCH", "412")) == ("CLIENT_ERROR", 1), "the scrape: 304 REDIRECTION 1, 412 CLIENT_ERROR 1 (%s)" % rows)
    finish("304=REDIRECTION 412=CLIENT_ERROR")


def c_spec(t):
    ok("(servers removed, json.dump indent 2, ensure_ascii False, a final newline): equal" in t, "the served spec = the committed file")
    ok("byte-equal: yes" in t, "the committed file unchanged by this unit")
    ok("the operations' ids before -> after: equal" in t, "the operations' ids equal")
    ok("ops9s3.py on an empty spec: exit 1" in t, "ops9s3.py refuses an empty spec")
    ok(re.search(r"304 responses 0 · 412 responses 0 · ETag named 0 · If-Match named 0", t) is not None, "no operation documents the tag, If-Match, 304 or 412")
    ok(re.search(r"OpenApiSpecTest on the committed file: tests 1 failures 0 errors 0", t) is not None, "OpenApiSpecTest passes")
    ok("tiffinbox-client byte-equal before -> after/: yes" in t, "the client untouched")
    finish("spec=%s ops=%s" % (grab(t, r"bytes before (\d+)"), grab(t, r"before: (.*?) · after:")))


def c_moved(t):
    b = [x for x in re.findall(r"^  before \| (.*)$", t, re.M) if not x.startswith("requests sent")]
    a = [x for x in re.findall(r"^  after \| (.*)$", t, re.M) if not x.startswith("requests sent")]
    ok(len(b) == len(a) and len(b) > 30, "U18's list on both trees (%d requests each)" % len(b))
    mv = []; other = []
    for x, y in zip(b, a):
        if x == y: continue
        mv.append(y)
        hx = re.search(r"headers \{([^}]*)\}", x).group(1).split(","); hy = re.search(r"headers \{([^}]*)\}", y).group(1).split(",")
        if sorted(set(hy) - set(hx)) != ["etag"] or set(hx) - set(hy) or re.sub(r"headers \{[^}]*\}", "", x) != re.sub(r"headers \{[^}]*\}", "", y):
            other.append(y)
    for y in mv: OUT.append("note moved: " + y)
    ok(not other, "every moved line moved by the etag header alone (%d moved, %d other)" % (len(mv), len(other)))
    ok(all("/api/v1/" in y for y in mv), "every moved line is an /api/v1/ GET")
    j = re.search(r"jar \| the web jar's entries: added (\d+) (\[.*?\]) · removed (\d+) · shared entries whose CRC moved (\d+) (\[.*?\])", t)
    ok(j is not None and j.group(3) == "0", "the jar: added %s, removed %s, moved %s" % (j.group(1), j.group(3), j.group(4)) if j else "the jar line")
    ok(j is not None and "BOOT-INF/lib/tiffinbox-core-1.0.0.jar" in j.group(5), "the core jar inside BOOT-INF/lib moved (named)")
    lib = re.search(r"BOOT-INF/lib names: before (\d+) · after (\d+) · added: (.*?) · removed: (\d+)", t)
    finish("moved=%d moved_by=etag jar_added=%s jar_moved=%s lib=%s->%s" % (len(mv), j.group(1) if j else "", j.group(5) if j else "", lib.group(1) if lib else "", lib.group(2) if lib else ""))


def c_api(t):
    m = re.search(r"api \| additive: (\w+) · lines moved (\d+) · tagged after (\d+) \(deep (\d+)\) · untagged after (\d+) · moved other than the tag and the framing: (\d+)", t)
    ok(m is not None and m.group(1) == "yes" and m.group(6) == "0", "the /api/v1/ census additive (the tag and the framing only)")
    for x in re.findall(r"^  api after \| GET (\S+) -> (\d+) .*? · etag (\S+(?: \S+)?) · framing (\S+)", t, re.M):
        if "/bill" in x[0] and "bill-link" not in x[0]: ok(x[2] == "none", "%s untagged" % x[0])
        if x[1] != "200": ok(x[2] == "none", "%s (%s) untagged" % (x[0], x[1]))
    ok(re.search(r'^  api after \| GET /api/v1/customers/Ravi -> 200 .*? · etag "v0" · ', t, re.M) is not None, "the public read: the deep tag \"v0\" raw")
    ok(re.search(r"^  api after \| GET /api/v1/customers/Ravi/bill -> 200 .*? · framing chunked", t, re.M) is not None, "the bill chunked on after/")
    routes = re.findall(r"^  api \| moved (\S+): headers \+etag", t, re.M)
    fr = re.findall(r"^  api \| moved (\S+): .*? framing (\S+) -> (\S+)", t, re.M)
    framing = [r for r, x, y in fr if x != y]
    finish("api=%s tagged=%s routes=%s framing_moved=%s" % (len(re.findall(r"^  api after \|", t, re.M)), m.group(3) if m else "", ",".join(routes), ",".join(framing) or "none"))


def c_seven(t):
    e = grab(t, r"expected ([0-9a-f]{32})"); b = grab(t, r"before: the seven ([0-9a-f]{32})"); a = grab(t, r"after: the seven ([0-9a-f]{32})")
    ok(e is not None and b == e and a == e, "the seven = %s on both" % e)
    finish("seven=%s" % (e or "")[:8])


def c_surface(t):
    e = grab(t, r"expected ([0-9a-f]{32})"); b = grab(t, r"before: the old surface ([0-9a-f]{32})"); a = grab(t, r"after: the old surface ([0-9a-f]{32})")
    ok(e is not None and b == e and a == e, "the old surface = %s on both" % e)
    finish("surface=%s" % (e or "")[:8])


def c_moving(t):
    d = dict(re.findall(r"^  moving \| (\S+): distinct tags over three starts (\d+)", t, re.M))
    ok(len(d) == 5, "five routes")
    ok(d.get("/api/v1/orders") == "3" and d.get("/api/v1/customers/Ravi/bill-link") == "3", "per-start: the list's and the bill link's tags move per start (3)")
    ok(d.get("/api/v1/customers/Ravi") == "1" and d.get("/api/v1/customers") == "1" and d.get("/api/v1/orders/1") == "1", "stable: the deep tag, the list and the order (1)")
    finish("orders=%s bill_link=%s deep=%s list=%s order=%s" % tuple(d.get(k, "") for k in ("/api/v1/orders", "/api/v1/customers/Ravi/bill-link", "/api/v1/customers/Ravi", "/api/v1/customers", "/api/v1/orders/1")))


def c_inert(t):
    ok(grab(t, r"keyed requests in this run's captures: (\d+)") == "0", "no request of this unit carries the key header")
    finish("keyed=0")


def c_tests(t):
    ok("mvn package exit 0" in t, "package exit 0")
    w = re.search(r"package \| tiffinbox-web \| tests (\d+) failures 0 errors 0 skipped 0", t)
    ok(w is not None, "package: the web module green, 0 skipped")
    ok(re.search(r"package \| tiffinbox-client \| tests 1 failures 0 errors 0 skipped 0", t) is not None, "the client: 1 test")
    cg = re.search(r"class ConditionalGetTest \| tests (\d+) failures 0 errors 0 skipped 0", t)
    ok(cg is not None, "ConditionalGetTest green")
    ok(re.search(r"class RateLimitFilterTest \| tests 3 failures 0 errors 0 skipped 0", t) is not None, "RateLimitFilterTest 3, unmoved")
    wb = grab(t, r"web tests before \(unit 19's values block\): (\d+)")
    ok(w is not None and cg is not None and wb is not None and int(w.group(1)) == int(wb) + int(cg.group(1)), "web %s = unit 19's %s + ConditionalGetTest's %s" % (w.group(1) if w else "", wb, cg.group(1) if cg else ""))
    ok("disabling or conditional annotations 0 · ports or sockets (string literals removed) 0" in t, "the test class: no disabling annotation, no port")
    ok(re.search(r"test files moved before -> after:  · new: ConditionalGetTest.java", t) is not None, "no existing test file moved; one new")
    ok(grab(t, r"outside RateLimitFilterTest (\d+)") == "0", "R.555: 0 refusals at the default outside RateLimitFilterTest")
    tw = re.search(r"twin \| tiffinbox-web \| tests (\d+) failures 0 errors 0 skipped 0", t)
    ok(tw is not None and w is not None and tw.group(1) == w.group(1), "the Docker-free twin: the same counts")
    v = re.search(r"verify exit 0 · ITs tests (\d+) failures 0 errors 0 · classes (\d+)", t)
    ok(v is not None and v.group(1) == "14" and v.group(2) == "5", "verify: %s" % (v.group(0) if v else "absent"))
    ok(re.search(r"IT bindings: \d+ lines · not 127\.0\.0\.1: 0", t) is not None, "IT bindings: all 127.0.0.1")
    ok("Testcontainers containers after: 0 · images pulled: 0" in t, "no container left, nothing pulled")
    wo = re.search(r"webonly \| tiffinbox-web \| tests (\d+) failures 0 errors 0 skipped 0", t)
    ok(wo is not None and w is not None and wo.group(1) == w.group(1), "the web-only form: the same counts")
    ok("downloads across the builds: 0" in t, "0 downloads")
    lib = re.search(r"BOOT-INF/lib: before (\d+) · after (\d+) · added (\d+) · removed (\d+) · the core jar's md5 before -> after: (\w+)", t)
    ok(lib is not None and lib.group(3) == "0" and lib.group(4) == "0" and lib.group(5) == "moved", "BOOT-INF/lib: 0 added, 0 removed; the core jar moved")
    ok("TiffinBoxWebTest green unedited: yes" in t, "the slice green, unedited")
    finish("web=%s client=1 conditionalget=%s its=%s lib=%s->%s" % (w.group(1) if w else "", cg.group(1) if cg else "", v.group(1) if v else "", lib.group(1) if lib else "", lib.group(2) if lib else ""))


def c_harness(t):
    ok("harness/: cdp.mjs cdp9.mjs chk20.py chrome20.py dur9.py ops9s3.py s920.py seal9.py src tree20.py · harness/src: probe/Etag.java probe/Http.java probe/Witness.java" in t, "the folder's files exactly")
    ok("Routes.java - 0 present" in t, "no instrument this unit does not carry")
    ok(re.search(r"a byte appended to after/compose\.yaml .*?: exit 1 · a FAIL names it: [1-9]", t) is not None, "static on a scratch copy moved by one byte: exit 1")
    ok("reading the live anchor (its folder name assembled) -> exit 1 · the same path from two pieces -> exit 1" in t, "flag 31's two plants exit 1")
    finish("static=%s" % grab(t, r"as written: output md5 ([0-9a-f]{32})"))


def c_exercise(t):
    for sh in ("bash", "zsh"):
        bl = "\n".join(re.findall(r"^  broken %s \| (.*)$" % sh, t, re.M)); sl = "\n".join(re.findall(r"^  solved %s \| (.*)$" % sh, t, re.M))
        ok("check exit 1" in bl and "FAIL (2) the old tag on the merge PATCH answered 200 and Ravi reads CHANGED: a stale tag wrote" in bl, "broken, %s: FAIL on clause 2 (a stale tag wrote, 200)" % sh)
        ok("check exit 0" in sl and "\nPASS" in "\n" + sl, "solved, %s: PASS" % sh)
    for v in ("mergeonly", "required", "fixedelsewhere"):
        l = "\n".join(re.findall(r"^  ~ %s bash \| (.*)$" % v, t, re.M))
        if l: ok("check exit 1" in l, "refused variant %s: exit 1" % v)
    finish("broken=FAIL(stale_200_written) solved=PASS")


CHECKS = {"advisory": c_advisory, "before": c_before, "change": c_change, "census": c_census, "shallow": c_shallow, "paths": c_paths,
          "weak": c_weak, "deep": c_deep, "ifmatch": c_ifmatch, "cache": c_cache, "chrome": c_chrome, "metrics": c_metrics, "spec": c_spec,
          "moved": c_moved, "api": c_api, "seven": c_seven, "surface": c_surface, "moving": c_moving, "inert": c_inert, "tests": c_tests,
          "harness": c_harness, "exercise": c_exercise}

PLANTS = [("shallow", r"(  free GET /api/v1/customers If-None-Match <its tag> -> )304", r"\g<1>200", "a 304 typed 200"),
          ("shallow", r"(PROBE-REQ \d+ GET /api/v1/orders/1 -> 304 \| handler \S+ \| post-handle yes \(count \d+\) \| statements )\d+", r"\g<1>0", "statements typed 0 on the uncached 304"),
          ("shallow", r"(PROBE-REQ \d+ GET /api/v1/customers -> 304 \| handler \S+ \| post-handle )yes \(count \d+\)", r"\1no", "the handler typed not run"),
          ("paths", r"(  after GET /api/v1/customers/Ravi/bill -> 200 · ETag )none", r'\1"<shallow tag>"', "the bill typed with an ETag on after/"),
          ("paths", r"(  star GET /customers/feed .*?reader exit )3", r"\g<1>0", "the feed typed alive on the /* copy"),
          ("paths", r"(  lim GET /api/v1/customers #6 -> 429 · ETag )none", r'\1"<shallow tag>"', "the 429 typed with an ETag"),
          ("weak", r"(  weak /api/v1/customers INM \* -> )200", r"\g<1>304", "* typed 304"),
          ("weak", r'(  weak GET /api/v1/customers -> 200 · ETag )"', r'\1W/"', "W/ typed on a tag the server wrote"),
          ("deep", r'(  free GET /api/v1/customers/Ravi #1 -> 200 · ETag )"v0"', r'\1"v1"', 'the tag typed "v1" at start'),
          ("deep", r"(witness \| PROBE-REQ \d+ GET /api/v1/customers/Ravi -> 304 \| handler \S+ \| post-handle yes \(count \d+\) \| statements )1", r"\g<1>0", "the 304's statements typed 0"),
          ("deep", r"(  free GET /customers/Ravi #1 \(the old address\) -> 200 · ETag )none", r'\1"v0"', "the old route typed tagged"),
          ("ifmatch", r'(  h2 merge \(2\) If-Match "v0" again \(stale\) -> )412', r"\g<1>200", "a stale tag typed 200"),
          ("ifmatch", r'(  pg json \(3\) If-Match W/"v1" \(weak, current\) -> )412', r"\g<1>200", "the weak form typed 200 (PostgreSQL, JSON Patch)"),
          ("ifmatch", r"(  h2 json \(4\) no If-Match -> )200", r"\g<1>412", "no header typed 412"),
          ("ifmatch", r"(witness \| PROBE-REQ \d+ PATCH /api/v1/customers/Ifm-merge -> 412 \| handler \S+ \| post-handle yes \(count \d+\) \| statements 1 \(writes )0", r"\g<1>1", "the UPDATE counted 1 on a stale 412"),
          ("ifmatch", r"version bigint NO default 0", "version integer YES default none", "PostgreSQL's column typed otherwise"),
          ("cache", r"(If-None-Match its own tag alone -> )200", r"\g<1>304", "the stylesheet's own tag alone typed 304"),
          ("cache", r"(If-Modified-Since its own date alone -> )304", r"\g<1>200", "the date alone typed 200"),
          ("chrome", r"(  chrome20 a reload \| Document /api/v1/customers/Ravi \| responseReceived )200", r"\g<1>304", "responseReceived typed 304 for the page"),
          ("chrome", r"(udp a \| TCP connects not to 127\.0\.0\.1: )0", r"\g<1>1", "a NetLog TCP host that is not 127.0.0.1"),
          ("chrome", r"chrome20\.py on an empty event file: exit 2", "chrome20.py on an empty event file: exit 0", "an empty events file accepted"),
          ("api", r"api \| additive: yes", "api | additive: NO", "a non-ETag move in the census"),
          ("moving", r"(  moving \| /api/v1/orders: distinct tags over three starts )3", r"\g<1>1", "a per-start route typed with one tag"),
          ("spec", r"a final newline\): equal", "a final newline): differ", "the committed file touched"),
          ("seven", r"after: the seven ([0-9a-f]{31})[0-9a-f]", r"after: the seven \g<1>0", "the seven's md5 one character off"),
          ("tests", r"(package \| tiffinbox-web \| tests \d+ failures 0 errors 0) skipped 0", r"\1 skipped 1", "Skipped typed 1"),
          ("tests", r"outside RateLimitFilterTest 0", "outside RateLimitFilterTest 1", "a refusal at the default"),
          ("exercise", r"(  solved bash \| )check exit 0", r"\1check exit 1", "solution = broken"),
          ("advisory", r"run date (\S+)", "run date 2026-11-28", "the read one day older than the run"),
          ("before", r"(  before GET /api/v1/customers/Ravi -> 200 · ETag )none", r'\1"v0"', "before typed with a tag"),
          ("paths", r"(  budget \| paths-after: requests under /api/v1/ \(its access log\): )\d+", r"\g<1>251", "a per-JVM request count above the cap"),
          ("paths", r"(  budget \| paths-after: requests under /api/v1/ \(its access log\): \d+ · refusal lines: )0", r"\g<1>1", "a refusal line in a default-capacity JVM")]


def plants(d):
    n = 0
    for nm, rx, rep, what in PLANTS:
        p = os.path.join(d, ".r-%s.new" % nm)
        if not os.path.exists(p): ok(False, "plant %s: no capture %s" % (what, p)); continue
        t = open(p, encoding="utf-8").read(); t2 = re.sub(rx, rep, t, count=1)
        if t2 == t: ok(False, "plant %s: the pattern did not apply" % what); continue
        r = subprocess.run([sys.executable, "-I", "-B", __file__, nm, "-"], input=t2, capture_output=True, text=True)
        f = [l for l in r.stdout.splitlines() if l.startswith("FAIL")]
        ok(r.returncode == 1 and f and "Traceback" not in r.stderr, "plant (%s) %s: caught - %s" % (nm, what, f[0][5:90] if f else "NOT CAUGHT"))
        n += 1
    for nm, line in (("shallow", "  witness | PROBE-REQ x garbage\n"), ("chrome", "  chrome20 a reload | garbage\n"), ("tests", "  package | garbage\n")):
        r = subprocess.run([sys.executable, "-I", "-B", __file__, nm, "-"], input=line, capture_output=True, text=True)
        ok(r.returncode == 1 and "Traceback" not in r.stderr, "plant an unparseable %s listing: a FAIL line, exit 1, no traceback" % nm); n += 1
    for l in OUT: print(l)
    print("VALUES plants=%d" % n)
    sys.exit(1 if any(l.startswith("FAIL") for l in OUT) else 0)


def main():
    a = sys.argv[1:]
    cmd = a[0] if a else ""
    if cmd == "static":
        static(a[1], a[2])
    elif cmd == "static-plant":
        sys.addaudithook(_guard)
        if a[1] == "live": open("../c9-" + "tiffinbox/pom.xml").read()   # LIVE_ANCHOR_PLANT
        else: open(os.path.join("..", "c9-" + "tiff" + "inbox", "pom.xml")).read()   # LIVE_ANCHOR_PLANT (two pieces)
        sys.exit(0)
    elif cmd == "gloss":
        r = open(a[1], encoding="utf-8").read().splitlines()
        ok(sum(1 for l in r if l.startswith("A precondition:")) == 1, "exactly one line starts A precondition:")
        ok(sum(1 for l in r if l == GLOSS) == 1, "the gloss line byte for byte")
        for g in ("An ETag:", "A validator:", "A token bucket:", "A cursor:", "A sparse fieldset:", "A link relation:", "`HAL`:", "A status resource:", "A presigned URL:", "A version carrier:", "A snippet:", "A contract:", "Swagger UI:", "A problem type:", "Code generation:"):
            ok(not any(l.startswith(g) for l in r), "no second gloss line (%s)" % g)
        u19 = open("../c9-unit19/README.md", encoding="utf-8").read().splitlines()
        ok("A token bucket: a count of requests that refills." in u19, "U19's gloss line byte-equal in its own README")
        finish(None)
    elif cmd == "gloss-line":
        print(GLOSS)
    elif cmd == "hook":
        print(hook())
    elif cmd == "exq":
        print(exq())
    elif cmd == "interleaved":
        b = brief(); hs = re.findall(r'^\*\*Hook \(\[S4 §\d+\]\):\*\* "([^"]+)"', b, re.M); es = re.findall(r'^\*\*Exercise:\*\* "(Your turn: [^"]+)"', b, re.M)
        if len(hs) != 6 or len(es) != 6: print("the extractor found %d hooks and %d exercises, not 6 + 6" % (len(hs), len(es))); sys.exit(1)
        il = "\n".join(x for p in zip(hs, es) for x in p) + "\n"
        print("the brief's hooks and exercises: %d + %d (R.534), the interleaved list's md5 %s" % (len(hs), len(es), md5(il.encode())))
    elif cmd == "hashable":
        t = open(a[2], encoding="utf-8").read().splitlines()
        sys.stdout.write("".join(l + "\n" for l in t if not l.startswith("  ~")))
    elif cmd == "values":
        r = open(a[1], encoding="utf-8").read()
        m = re.search(r"<!-- values: begin -->\n(.*?)<!-- values: end -->", r, re.S)
        got = "\n".join(l for l in (m.group(1) if m else "").splitlines() if l.strip() and l.strip() != "```")
        want = a[2].strip()
        if got != want:
            print("the README's values block differs from this run's:")
            for x, y in zip(got.splitlines() + [""] * 40, want.splitlines()):
                if x != y: print("  README: " + x); print("  run:    " + y)
            sys.exit(1)
        print("the README's values block = this run's (%d lines)" % len(want.splitlines()))
    elif cmd == "plants":
        plants(a[1])
    elif cmd in CHECKS:
        t = sys.stdin.read() if a[1] == "-" else open(a[1], encoding="utf-8").read()
        try:
            CHECKS[cmd](t)
        except SystemExit:
            raise
        except Exception as e:
            print("FAIL %s: the capture could not be parsed (%s: %s)" % (cmd, type(e).__name__, e)); sys.exit(1)
    else:
        print("FAIL unknown subcommand %r" % cmd); sys.exit(1)


main()
