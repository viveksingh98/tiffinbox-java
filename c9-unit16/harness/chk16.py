#!/usr/bin/env python3
"""Course 9 unit 16's checker (python3 -I -B harness/chk16.py MODE ...), on chk15.py's shared machinery (ok / fail / need, the listing
parser that ends with a FAIL line and exit 1, never a traceback). Each capture's check reads the capture's own lines and checks them
against another witness of the same run (curl's size against the saved file's bytes and Content-Length, the access log against curl's
lines, the counter's totals against its own listing, Surefire's XML against the reactor line, the census against its rows ...).
Prints "ok ..." / "FAIL ..." lines and one "VALUES k=v ..." line; exit 1 on any FAIL.

Modes: CAPTURE FILE (see CAPS) · hashable CAPTURE FILE (the capture minus its run-variant lines, those starting "  ~") · static AFTER BEFORE
(run in the unit's folder) · gloss README · gloss-line · hook · exq · interleaved · values README VALS · plants CAPDIR (each planted fault
made to FAIL first). Left out of this unit: see LEFT_OUT - a capture of that name in this checker or in receipts.sh is a static failure."""
import hashlib, json, os, re, subprocess, sys

FAILS = []
VALS = {}
LEFT_OUT = ["fu" + "ll", "fie" + "lds", "vi" + "ew", "m" + "jv", "flo" + "or", "gro" + "wn", "und" + "er", "pa" + "ge", "cli" + "ents",
            "ya" + "ml", "wa" + "lk", "page" + "able", "tr" + "ap", "rest" + "art", "ta" + "ble", "fi" + "rst", "cur" + "sor", "pi" + "n",
            "co" + "st", "lite" + "ral", "place" + "holder"]
CAPS = ["advisory", "before", "change", "starter", "jackson", "hal", "accept", "refuse", "final", "next", "forwarded", "halgz", "specwire",
        "spec", "moved", "seven", "surface", "tests", "exercise", "inert"]
GLOSS = "`HAL`: JSON with its links under `_links`."
BRIEF = os.path.join(os.environ.get("C9R", ""), "_briefs/UNIT-BRIEFS-S3-PAYLOADS.md")
SEVEN_JARS = ["accessors-smart-2.6.1.jar", "asm-9.11.1.jar", "json-path-2.10.0.jar", "json-smart-2.6.1.jar", "spring-boot-hateoas-4.1.3.jar",
              "spring-hateoas-3.1.4.jar", "spring-pl" + "ugin-core-4.1.0.jar"]
HOSTP = "http://127.0.0.1:<port>"


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


ONE = re.compile(r"^  ([\w -]+) \| GET (\S+?)(?: \[Accept: ([^\]]*)\])? -> (\d+) (\S*) (\d+) · file (\d+) B md5 ([0-9a-f]{32}) · Content-Length (\S+)"
                 r" · Content-Encoding (\S+) · Transfer-Encoding (\S+) · Vary (.+?)(?: · (?:members|a list).*)?$")


def gets(ls, lab=None):
    out = []
    for l in ls:
        m = ONE.match(l)
        if m and (lab is None or m.group(1) == lab):
            out.append(dict(lab=m.group(1), path=m.group(2), acc=m.group(3), code=int(m.group(4)), ctype=m.group(5), size=int(m.group(6)),
                            file=int(m.group(7)), md5=m.group(8), cl=m.group(9), ce=m.group(10), te=m.group(11), vary=m.group(12), line=l))
    return out


def same_size(g, what):
    return need(g["size"] == g["file"] and (g["cl"] == "none" or g["cl"] == str(g["file"])),
                "%s: curl's size %d = the saved file's %d B = Content-Length %s" % (what, g["size"], g["file"], g["cl"]))


def find(gs, path, acc=None):
    for g in gs:
        if g["path"] == path and (acc is None or g["acc"] == acc):
            return g
    fail("unparsable: no GET %s [%s]" % (path, acc))
    return dict(path=path, acc=acc, code=0, ctype="", size=-1, file=-2, md5="", cl="none", ce="", te="", vary="", line="")


# ---- the captures -------------------------------------------------------------------------------------------------------------------------
def c_advisory(ls):
    m = grab(ls, r"fetched-at (\S+) .* run date (\S+)", "the dates")
    if m:
        need(m.group(1) == m.group(2) == "2026-11-26", "the filed read is the batch day's and the run's date (%s, %s): it stands" % (m.group(1), m.group(2)))
    v = grab(ls, r"MD5SUMS\.txt: (\d+) lines, (\d+) verified", "the checksums")
    if v:
        need(v.group(1) == v.group(2) and int(v.group(1)) >= 8, "every checksum verified (%s of %s)" % (v.group(2), v.group(1)))
    r = grab(ls, r"spring rows (\d+) · naming Spring Framework (\d+) · naming HATEOAS (\d+)", "the rows")
    if r:
        need(r.group(2) == "0" and r.group(3) == "0", "Spring's index: no Spring Framework row, no HATEOAS row (of %s)" % r.group(1))
        VALS["adv_rows"] = r.group(1)
    need(any("tomcat page md5 a1a756d985225fb5143eefd9aae3183c" in l for l in ls), "Tomcat's page = the 2026-11-24 read (a1a756d9)")
    want = {"org.springframework.hateoas:spring-hateoas": "3.1.4", "org.springframework.boot:spring-boot-hateoas": "4.1.3", "net.minidev:json-smart": "2.6.1",
            "com.jayway.jsonpath:json-path": "2.10.0", "org.apache.tomcat.embed:tomcat-embed-core": "11.0.29", "tools.jackson.core:jackson-databind": "3.1.8"}
    got = {m.group(1): m.group(2) for m in grab_all(ls, r"^  t3 tree \| (\S+) (\S*)$")}
    for k, w in want.items():
        need(got.get(k) == w, "the read covers %s %s (got %s)" % (k, w, got.get(k)))
    need(ls and ls[-1] == "  verdict: no pin affected; evidence may proceed", "the verdict line")


def c_before(ls):
    gs = gets(ls, "before")
    o = find(gs, "/api/v1/orders/1")
    need(o["code"] in (404, 405), "GET /api/v1/orders/1 on before: %d (the print decides between 404 and 405)" % o["code"])
    VALS["before_order"] = o["code"]
    for g in gs:
        same_size(g, "before " + g["path"])
    r = find(gs, "/api/v1/customers/Ravi")
    need(r["code"] == 200 and "_links" not in r["line"], "the customer on before: 200, no _links (%d B)" % r["file"])
    VALS["before_ravi"] = r["file"]
    m = grab(ls, r"before \| mappings (\d+) · with orders in the path (\d+): (\[.*\])", "the mappings")
    if m:
        need("/api/v1/orders/{id}" not in m.group(3), "before maps no /api/v1/orders/{id} (%s)" % m.group(3))
        VALS["before_mappings"] = m.group(1)
    s = grab(ls, r"the committed spec: OPERATIONS (\d+) PATHS (\d+) · (\d+) B md5 ([0-9a-f]{32})", "the spec's counts")
    if s:
        need(s.group(3) == "24250" and s.group(4).startswith("b5ec509e"), "before's committed spec 24250 B b5ec509e")
        VALS["before_ops"] = "%s/%s" % (s.group(1), s.group(2))
    l = grab(ls, r"BOOT-INF/lib names (\d+) · naming hateoas (\d+)", "the lib")
    if l:
        need(l.group(2) == "0", "before's lib names no hateoas jar (%s names)" % l.group(1))
        VALS["before_lib"] = l.group(1)
    v = grab(ls, r"V6's orders: (\d+) rows · by customer (.*) · the first row (.*)$", "V6")
    if v:
        need("'Ravi'" in v.group(3) or "Ravi" in v.group(3), "V6's first row names Ravi (order 1's customer)")


def c_change(ls):
    m = grab(ls, r"modules: .* \((\d+)\) -> .* \((\d+)\)", "the modules")
    if m:
        need(m.group(1) == m.group(2) == "3", "three modules before and after")
    p = grab(ls, r"poms before -> after/: (.*)$", "the poms")
    if p:
        need(p.group(1) == "tiffinbox-web/pom.xml", "only tiffinbox-web/pom.xml differs among the poms")
    c = grab(ls, r"changed \(derived: .*\): (.*)$", "the changed list")
    if c:
        ch = c.group(1).split(" · ")
        need(sorted(ch) == sorted(["A tiffinbox-web/src/main/java/com/tiffinbox/web/OrderResources.java", "A tiffinbox-web/src/test/java/com/tiffinbox/web/OrderResourcesTest.java",
                                   "M README.md", "M tiffinbox-core/src/main/java/com/tiffinbox/OrderEntityRepository.java", "M tiffinbox-web/pom.xml",
                                   "M tiffinbox-web/src/test/resources/openapi/tiffinbox.json"]), "the changed set is flag 2's (%d paths)" % len(ch))
        VALS["changed"] = len(ch)
    for k in ("JsonView", "MappingJacksonValue", "Pageable", "offset(", "Probe", "/probe/", "methodOn(CustomerReads", "methodOn(OrderPages"):
        g = grab(ls, r"src/main grep %s: (\d+) code lines" % re.escape(k), k)
        if g:
            need(g.group(1) == "0", "src/main: %s 0 code lines" % k)
    f = grab(ls, r"OrderResources final: (\d+) · its declaration: (.*)$", "OrderResources' declaration")
    if f:
        need(f.group(1) == "0" and f.group(2) == "class OrderResources {", "OrderResources is not final (package-private: '%s')" % f.group(2))
    for n in ("OrderPages", "CustomerReads", "CustomerFields"):
        g = grab(ls, r"  %s: (.*) · byte-equal to before's: (\w+)" % n, n)
        if g:
            need(g.group(1).startswith("final class") and g.group(2) == "yes", "%s final and byte-equal to before's" % n)
    for k in ("compression", "forward-headers", "hateoas"):
        g = grab(ls, r"application\.yaml %s keys: before (\d+) · after (\d+)" % k, k)
        if g:
            need(g.group(1) == g.group(2) == "0", "application.yaml holds no %s key before or after" % k)
    h = grab(ls, r"handler orderResource: (\d+) occurrence", "the handler")
    if h:
        need(h.group(1) == "1", "the handler name orderResource occurs once among the mapped handlers")
    core = [l for l in ls if l.startswith("  core | ")]
    need(sum(1 for l in core if l.startswith("  core | >")) >= 1 and not any(l.startswith("  core | <") for l in core) and any("Optional<OrderEntity> findById(Long id);" in l for l in core),
         "the core diff: lines added only, findById among them")
    pd = grab(ls, r"ProblemDetail\.forStatus calls .*: before (\d+) · after (\d+)", "the instance view's grep")
    if pd:
        need(int(pd.group(2)) == int(pd.group(1)) + 1, "OrderResources adds one ProblemDetail.forStatus call (%s -> %s)" % (pd.group(1), pd.group(2)))


def c_starter(ls):
    e = grab(ls, r"edit \| the diff's md5 \w+ · lines added (\d+) removed (\d+) · a <version> on the starter: (\w+)", "the edit")
    if e:
        need(e.group(2) == "0" and e.group(3) == "absent", "the pom edit adds %s lines, removes 0, no version" % e.group(1))
        need(int(e.group(1)) == sum(1 for l in ls if l.startswith("  edit | >")), "the added-line count = the diff's > lines")
        VALS["pom_added"] = e.group(1)
    need(any("<spring-hateoas.version>3.1.4</spring-hateoas.version>" in l for l in ls), "the BOM manages spring-hateoas 3.1.4")
    n = grab(ls, r"lib \| before (\d+) names · after (\d+) names", "the lib counts")
    added = sorted(m.group(1) for m in grab_all(ls, r"^  lib \| added (\S+)$"))
    removed = [m.group(1) for m in grab_all(ls, r"^  lib \| removed (\S+)$")]
    if n:
        need(int(n.group(2)) - int(n.group(1)) == len(added) - len(removed), "the counts' difference = the listed names (%s -> %s)" % (n.group(1), n.group(2)))
        VALS["lib"] = "%s->%s" % (n.group(1), n.group(2))
    need(added == SEVEN_JARS and not removed, "the seven jars added, none removed (%s)" % ",".join(added))
    j = grab(ls, r"jar \| entries: before (\d+) · after (\d+) · only after: (\d+) \(in BOOT-INF/lib/ (\d+)\) · only before (\d+)", "the jar")
    o = grab(ls, r"jar \| only after, outside BOOT-INF/lib/: (.*)$", "the new entries")
    c = grab(ls, r"jar \| shared entries whose CRC differs: (.*)$", "the CRCs")
    if j and o and c:
        need(j.group(4) == "7" and j.group(5) == "0", "the web jar gained 7 lib entries and lost none")
        need(o.group(1) == "BOOT-INF/classes/com/tiffinbox/web/OrderResources.class", "outside lib/ the jar gained OrderResources.class alone (%s)" % o.group(1))
        cr = [x.strip() for x in c.group(1).split(",")]
        need(set(cr) <= {"BOOT-INF/lib/tiffinbox-core-1.0.0.jar", "BOOT-INF/classpath.idx", "META-INF/maven/com.tiffinbox/tiffinbox-web/pom.xml", "BOOT-INF/layers.idx"},
             "the shared entries that moved are the named ones only (%s)" % c.group(1))
        VALS["jar_moved"] = len(cr)
    k = grab(ls, r"core jar \| entries before (\d+) · after (\d+) · only after (.*) · only before (.*) · CRC differs: (.*)$", "the core jar")
    if k:
        need(k.group(3) == "none" and k.group(4) == "none" and k.group(5) == "com/tiffinbox/OrderEntityRepository.class", "the core jar: OrderEntityRepository.class alone differs")


def c_jackson(ls):
    m = grab(ls, r"MANIFEST Implementation-Version (\S+)", "the version")
    if m:
        need(m.group(1) == "3.1.4", "spring-hateoas Implementation-Version 3.1.4")
    h = grab(ls, r"HAL classes (\d+) · referencing tools/jackson/databind (\d+) · referencing com/fasterxml/jackson/databind (\d+)", "the counts")
    if h:
        need(int(h.group(2)) > 0 and h.group(3) == "0", "HAL's classes name Jackson 3 (%s of %s), Jackson 2 0 (by the printed rule)" % (h.group(2), h.group(1)))
        VALS["hal_jackson"] = "%s/%s/%s" % h.groups()
    need(any("rule: the .class entries directly in org/springframework/hateoas/mediatype/hal/" in l for l in ls), "the rule printed beside the counts")


def c_hal(ls):
    gs = gets(ls, "hal")
    o1 = find(gs, "/api/v1/orders/1", "application/hal+json"); o20 = find(gs, "/api/v1/orders/20", "application/hal+json")
    for g in (o1, o20):
        same_size(g, "hal " + g["path"])
        need(g["code"] == 200 and g["ctype"] == "application/hal+json", "%s: 200 application/hal+json" % g["path"])
    H = "http://127.0.0.1:21050"
    need("links ['self=%s/api/v1/orders/1', 'customer=%s/api/v1/customers/Ravi']" % (H, H) in o1["line"], "order 1's two links carry the request's host (127.0.0.1:21050) and end self /api/v1/orders/1, customer /api/v1/customers/Ravi")
    need("members ['_links', 'id', 'customer', 'mealType', 'amount', 'placedAt']" in o1["line"], "order 1's members: _links first, then the five")
    b = grab(ls, r"hal \| order 1's body: (.*)$", "the body")
    if b:
        need(b.group(1).startswith('{"_links":{"self":{"href":"http://127.0.0.1:21050/api/v1/orders/1"}'), "the printed body starts with _links.self")
    w = grab(ls, r"without _links .*: (\d+) B", "the control")
    if w:
        VALS["hal"] = "%d/%s" % (o1["file"], w.group(1))
    f = grab(ls, r"following customer: GET (\S+) -> (\d+) (\S+) (\d+) · (.*)$", "the follow")
    if f:
        need(f.group(2) == "200" and '"name":"Ravi"' in f.group(5), "following customer answers Ravi (200)")
    a = grab(ls, r"the access log: (.*)$", "the access log")
    if a:
        al = a.group(1).split("|")
        need(len(al) == 3 and all(" 200 " in x for x in al), "the access log holds this capture's three requests, each 200 (%d)" % len(al))
        need(any(x.startswith("GET /api/v1/orders/1 200 %d " % o1["file"]) for x in al), "the access log's %%b for order 1 = curl's %d" % o1["file"])


def c_accept(ls):
    gs = gets(ls, "accept")
    want = {"application/hal+json": (200, "application/hal+json"), "application/json": (200, "application/json"), "*/*": (200, "application/hal+json"),
            "none": (200, "application/hal+json"), "application/prs.hal-forms+json": (406, "application/problem+json"), "text/html": (406, "application/problem+json"),
            "application/xml": (406, "application/problem+json")}
    res = {}
    for a, (c, t) in want.items():
        g = find(gs, "/api/v1/orders/1", a)
        res[a] = g
        need(g["code"] == c and g["ctype"] == t, "Accept %s -> %d %s (the print: %d %s)" % (a, c, t, g["code"], g["ctype"]))
    need(len({res[a]["md5"] for a in ("application/hal+json", "application/json", "*/*", "none")}) == 1, "the four HAL answers are the same bytes")
    VALS["accept"] = "hal=%d,json=%d,406=%d" % (res["application/hal+json"]["file"], res["application/json"]["file"], sum(1 for a in want if res[a]["code"] == 406))
    old = {}
    for g in gets(ls):
        if g["lab"].startswith("old "):
            old[(g["lab"][4:], g["path"], g["acc"])] = (g["code"], g["ctype"], g["md5"])
    moved = [k for k in old if k[0] == "before" and old.get(("after",) + k[1:]) != old[k]]
    need(len(old) == 24, "the old routes: 4 x 3 Accept values on both trees (%d)" % len(old))
    need(not moved, "the starter moved no old answer under hal+json, json or */* (%s)" % moved)
    VALS["accept_old_moved"] = len(moved)


def c_refuse(ls):
    rs = {m.group(1): m for m in grab_all(ls, r"^  refuse \| (.+?) \((\S+)\) -> (\d+) (\S+) \| (.*)$")}
    want = {"an id no order has": ("404", "order-unknown"), "id zero": ("404", "order-unknown"), "a negative id": ("404", "order-unknown"),
            "not a number": ("400", None), "a query parameter": ("400", "parameter-unknown"), "a decimal id": ("400", None), "an id past Long": ("400", None)}
    for k, (c, t) in want.items():
        m = rs.get(k)
        if not need(m is not None, "refusal printed: %s" % k):
            continue
        need(m.group(3) == c and m.group(4) == "application/problem+json", "%s -> %s application/problem+json" % (k, c))
        if t:
            need("type=tag:tiffinbox.example,2026:%s" % t in m.group(5), "%s: the route's type %s" % (k, t))
        else:
            need("type absent" in m.group(5), "%s: Framework's four hundred, no type of TiffinBox's (named)" % k)
    ts = rs.get("a trailing slash")
    if need(ts is not None, "the trailing slash printed"):
        VALS["trailing_slash"] = ts.group(3)
    need(rs.get("an id no order has") is not None and "detail=no order with id 21" in rs["an id no order has"].group(5), "the 404's detail names the id")
    p = grab(ls, r"refuse \| POST /api/v1/orders/1 -> (\d+) (\S+) · Allow \{(.*)\}", "the POST")
    if p:
        need(p.group(1) == "405" and p.group(3) == "GET", "POST on the route: 405, Allow GET (no write route)")
    VALS["refusals"] = len(rs)
    VALS["notype"] = ",".join(sorted(k.replace(" ", "_") for k, m in rs.items() if "type absent" in m.group(5)))


def c_final(ls):
    for side, (n, fd, nf, nd) in (("before", (14, 9, 0, 5)), ("after", (15, 9, 1, 5))):
        m = grab(ls, r"census %s \| controllers (\d+) · final, default-run (\d+) · not final, default-run (\d+) · not final, dev-only (\d+) · other (\d+)" % side, side)
        rows = grab_all(ls, r"^  census %s \| (\w+) +final (yes|no) +dev-only (yes|no)" % side)
        if m:
            need(int(m.group(1)) == len(rows), "census %s: the total = its rows (%d)" % (side, len(rows)))
            need(sum(1 for r in rows if r.group(2) == "yes" and r.group(3) == "no") == int(m.group(2)), "census %s: the final default-run count = its rows" % side)
            VALS["census_" + side] = "%s/%s/%s/%s" % (m.group(1), m.group(2), m.group(3), m.group(4))
        need(any("census %s | excluded by the rule: TiffinBoxErrors" % side in l for l in ls), "census %s: the excluded line printed" % side)
    nf = [r.group(1) for r in grab_all(ls, r"^  census after \| (\w+) +final no +dev-only no")]
    need(nf == ["OrderResources"], "after: the one non-final default-run controller is OrderResources (%s)" % nf)
    m = grab(ls, r"final \| methodOnFinal: (.*)$", "methodOn on CustomerReads")
    if m:
        need(m.group(1) == "org.springframework.aop.framework.AopConfigException: Could not generate CGLIB subclass of class com.tiffinbox.web.CustomerReads: Common causes of this problem include using a final class or a non-visible class",
             "methodOn(CustomerReads) fails: the run's own AopConfigException")
    r = grab(ls, r"final \| methodOnFinalRoot: (.*)$", "the root")
    if r:
        need(r.group(1) == "java.lang.IllegalArgumentException: Cannot subclass final class com.tiffinbox.web.CustomerReads", "its root: Cannot subclass final class")
    f = grab(ls, r"final \| methodFormFinal: (.*)$", "the Method form")
    if f:
        need(f.group(1) == HOSTP + "/api/v1/customers/Ravi", "the Method form on CustomerReads builds %s/api/v1/customers/Ravi" % HOSTP)
    n = grab(ls, r"final \| methodOnNonFinal: (.*)$", "methodOn on OrderResources")
    if n:
        need(n.group(1) == HOSTP + "/api/v1/orders/1", "methodOn on the non-final OrderResources builds its link")
    j = grab(ls, r"final \| the JVM log \(the pattern '\^U16 harness: '\): (.*)$", "the JVM log")
    if j and m and r:
        need(j.group(1) == "U16 harness: methodOn(CustomerReads) -> " + m.group(1) + "|U16 harness: its root -> " + r.group(1), "the JVM log's lines = the route's answer")
    VALS["final"] = "AopConfigException"


def c_next(ls):
    p = grab(ls, r"next \| page one ids (\[.*\]) · the cursor (\d+) characters", "page one")
    h = grab(ls, r"next \| href (\S+) · templated (\w+) · percent signs in it (\d+)", "the href")
    e = grab(ls, r"next \| expanded (\S+)$", "the expanded href")
    f = grab(ls, r"next \| following the expanded href -> (\d+) (\S+) · ids (\[.*\])", "the follow")
    if p and h and e and f:
        need(p.group(1) == "[19, 20, 17, 18, 15]", "page one = unit 13's [19, 20, 17, 18, 15]")
        need(h.group(1).startswith(HOSTP + "/api/v1/orders?sort=newest&cursor=") and "<cursor>" in h.group(1), "the href: the list's route, the cursor masked")
        need(f.group(1) == "200" and f.group(3) == "[16, 13, 14, 11, 12]", "following the link opens page two [16, 13, 14, 11, 12]")
        VALS["next"] = "len=%s,templated=%s,pct=%s,page2=%s" % (p.group(2), h.group(2), h.group(3), f.group(1))
    r = grab(ls, r"following the raw href, its template unexpanded \(curl -g\) -> (\d+)", "the raw follow")
    if r:
        VALS["next_raw"] = r.group(1)


def c_forwarded(ls):
    res = {}
    for m in grab_all(ls, r"^  forwarded \| strategy=(\w+) · (with the headers|without them \(the control\)) -> self (\S+) · customer (\S+)"):
        res[(m.group(1), "with" if m.group(2) == "with the headers" else "control")] = (m.group(3), m.group(4))
    need(len(res) == 4, "four forwarded lines (%d)" % len(res))
    d = res.get(("default", "with")); fr = res.get(("framework", "with")); c = res.get(("framework", "with"[:4] if False else "with"))
    if d:
        need(d[0].startswith(HOSTP + "/") and d[1].startswith(HOSTP + "/"), "strategy=default: the headers ignored, the links carry the request's host")
    if fr:
        need(fr[0] == "https://api.tiffinbox.example/api/v1/orders/1" and fr[1] == "https://api.tiffinbox.example/api/v1/customers/Ravi",
             "strategy=framework: the header writes the links' host (https://api.tiffinbox.example, no port)")
        VALS["forwarded"] = fr[0].split("/api/")[0]
    for s in ("default", "framework"):
        cc = res.get((s, "with"[:4].replace("with", "with")))
    ctl = [v for k, v in res.items() if k[1] == "with"[:4] and False]
    for s in ("default", "framework"):
        k = (s, "with")
        k2 = [kk for kk in res if kk[0] == s and kk[1] != "with"]
        if k2:
            need(res[k2[0]][0].startswith(HOSTP + "/"), "strategy=%s, the control: the request's own host" % s)
    need(any("--server.forward-headers-strategy=framework" in l for l in ls if "strategy=framework ·" in l), "the run flag is on framework's command line")
    m = grab(ls, r"forward-headers in after/'s committed source and configuration files .*: (\d+) files", "the grep")
    if m:
        need(m.group(1) == "0", "forward-headers occurs in no committed file of after/")


def c_halgz(ls):
    k = grab(ls, r"halgz \| keys (\d+):", "the keys")
    mt = grab(ls, r"mime-types default: (\d+) entries: (.*)$", "the types")
    fl = grab(ls, r"server\.compression\.min-response-size default \"(\S+)\"", "the floor")
    e = grab(ls, r"server\.compression\.enabled default (\S+)", "enabled")
    inl = grab(ls, r"application/json in the list: (\w+) · application/hal\+json: (\w+) · application/problem\+json: (\w+)", "the three types")
    if k and mt and fl and e and inl:
        need(k.group(1) == "5" and e.group(1) == "false" and fl.group(1) == "2KB" and mt.group(1) == "8" and len(mt.group(2).split()) == 8,
             "Boot's metadata: 5 keys, enabled false, min-response-size 2KB, 8 types")
        need(inl.groups() == ("yes", "no", "no"), "application/json listed; hal+json and problem+json not")
        VALS["halgz_meta"] = "2KB/8"
    gs = gets(ls, "halgz")
    o = find(gs, "/api/v1/orders/1"); n = find(gs, "/api/v1/orders/21")
    need(o["code"] == 200 and o["ce"] == "none" and o["file"] < 2048, "the shipped order, gzip asked, flag on: %d B, under the floor, no Content-Encoding" % o["file"])
    need(n["code"] == 404 and n["ce"] == "none", "the 404, gzip asked, flag on: no Content-Encoding")
    need(any("--server.compression.enabled=true" in l for l in ls if l.startswith("  halgz | java ")), "the flag on the shipped JVM's command line")
    hs = gets(ls, "halgz-harness")
    need(len(hs) == 4, "the harness's collection asked four ways (%d)" % len(hs))
    hal = [g for g in hs if g["acc"] == "application/hal+json"]; js = [g for g in hs if g["acc"] == "application/json"]
    if len(hal) == 2 and len(js) == 2:
        need(hal[0]["file"] >= 2048 and hal[0]["ctype"] == "application/hal+json", "the harness's HAL collection is above the floor (%d B)" % hal[0]["file"])
        need(hal[1]["ce"] == "none" and hal[1]["md5"] == hal[0]["md5"], "hal+json, gzip asked, flag on: not compressed (the same bytes)")
        VALS["halgz"] = "%d,hal+json=%s,json=%s" % (hal[0]["file"], "gzip" if hal[1]["ce"] == "gzip" else "plain", "gzip" if js[1]["ce"] == "gzip" else "plain")
        if js[1]["ce"] == "gzip":
            g = grab(ls, r"\[Accept: application/json\] gunzip of the gzipped body: (\d+) B md5 (\w+) · the plain body md5 (\w+)", "the gunzip")
            if g:
                need(g.group(2) == g.group(3) and int(g.group(1)) == js[0]["file"], "application/json gzipped: gunzip = the plain body (%s B)" % g.group(1))
    need(any("--server.compression.enabled=true" in l and "probe.u16.U16Config" in l for l in ls if l.startswith("  halgz | java ")), "the flag on the harness JVM's command line")


def c_specwire(ls):
    m = grab(ls, r"spec \| operationId (\S+) · tags (.*) · parameters (.*)$", "the operation")
    if m:
        need(m.group(1) == "orderResource", "operationId orderResource")
        need("('id', 'path', 'integer', 'int64', True)" in m.group(3), "the id parameter: path, integer int64, required")
    r = {(x.group(1), x.group(2)): x.group(3) for x in grab_all(ls, r"^  spec \| (\d+) (\S+) schema (\S+)$")}
    need(r.get(("200", "application/hal+json")) == "EntityModelOrderView" and r.get(("200", "application/json")) == "EntityModelOrderView",
         "the 200 documented under application/hal+json and application/json, schema EntityModelOrderView")
    need(r.get(("400", "application/problem+json")) == "ProblemDetail" and r.get(("404", "application/problem+json")) == "ProblemDetail", "the 400 and 404 as ProblemDetail")
    w = {x.group(1): x.group(2) for x in grab_all(ls, r"^  wire \| 200 \[Accept: (\S+)\] (\S+) members")}
    need(w == {"application/hal+json": "application/hal+json", "application/json": "application/json"}, "the wire's 200 types = the documented two")
    e = grab(ls, r"wire \| 404 (\S+) · 400 \(\?x=1\) (\S+) · 400 \(abc, Framework's\) (\S+) · 406 \(hal-forms\) (\d+)", "the error types")
    if e:
        need(e.group(1) == e.group(2) == e.group(3) == "application/problem+json", "the errors on the wire: application/problem+json")
    g = grab(ls, r"gap \| named: (\d+)", "the gaps")
    gl = [l for l in ls if l.startswith("  gap | ") and not l.startswith("  gap | named")]
    if g:
        need(int(g.group(1)) == len(gl) and len(gl) >= 1, "every spec-vs-wire gap named (%d)" % len(gl))
        VALS["gaps"] = len(gl)


def c_spec(ls):
    need(any("against the served document (servers removed, json.dump indent 2, ensure_ascii False, a final newline): equal" in l for l in ls), "the committed file = the served document")
    m = grab(ls, r"committed md5 before (\w+) · after (\w+) · bytes before (\d+) · after (\d+)", "the bytes")
    d = grab(ls, r"the diff against before's .*: (\d+) lines added, (\d+) removed", "the diff")
    p = grab(ls, r"the paths added: (\[.*?\]) removed (\[.*?\]) other paths moved (\[.*?\]) schemas added (\[.*?\]) schemas moved (\[.*?\])", "the paths")
    if m and d and p:
        need(m.group(1).startswith("b5ec509e") and m.group(3) == "24250", "before's file 24250 B b5ec509e")
        need(d.group(2) == "0", "lines removed 0 (added %s)" % d.group(1))
        need(p.group(1) == "['/api/v1/orders/{id}']" and p.group(2) == "[]" and p.group(3) == "[]" and p.group(5) == "[]", "one new path, no path or schema moved")
        need(p.group(4) == "['EntityModelOrderView', 'Link', 'Links']", "the schemas added: EntityModelOrderView, Link, Links")
        VALS["spec"] = "%s->%s,+%s/-%s" % (m.group(3), m.group(4), d.group(1), d.group(2))
        VALS["spec_md5"] = m.group(2)[:8]
    o = grab(ls, r"before: OPERATIONS (\d+) PATHS (\d+) · after: OPERATIONS (\d+) PATHS (\d+)", "the counts")
    if o:
        need(int(o.group(3)) == int(o.group(1)) + 1 and int(o.group(4)) == int(o.group(2)) + 1, "operations and paths each up by one (%s/%s -> %s/%s)" % o.groups())
        VALS["ops"] = "%s->%s" % (o.group(1), o.group(3)); VALS["paths"] = "%s->%s" % (o.group(2), o.group(4))
    need(any(l.endswith("the old operations' ids before -> after: equal") for l in ls), "the old operations' ids equal (R.535)")
    need(not any(l.startswith("  ops moved | <") for l in ls), "no old operation line moved")
    need(any("ops9s3.py on an empty spec: exit 1 (refused)" in l for l in ls), "the counter refuses an empty spec")
    need(any("operationIds unique: yes" in l for l in ls), "operationIds unique")
    t = grab(ls, r"OpenApiSpecTest on the regenerated file: tests (\d+) failures (\d+) errors (\d+)", "OpenApiSpecTest")
    if t:
        need(t.groups() == ("1", "0", "0"), "OpenApiSpecTest passes on the regenerated file")
    c = grab(ls, r"the client: counts - equal (\d+) · date line only (\d+) · lines added only (\d+) · moved (\d+) · added (\d+)", "the client's classes")
    fs = grab(ls, r"the client: FILES (\d+) -> (\d+)", "the client's files")
    if c and fs:
        tot = sum(int(x) for x in c.groups())
        need(tot == int(fs.group(2)), "the client's classified files = its FILES count (%d)" % tot)
        need(c.group(4) == "0", "no client file moved beyond the date line and added lines")
        VALS["client"] = "%s->%s,date=%s,added_lines=%s,new=%s" % (fs.group(1), fs.group(2), c.group(2), c.group(3), c.group(5))
    need(any("ApiApi diff >" in l and 'PATH_ORDER_RESOURCE = "/api/v1/orders/{id}"' in l for l in ls), "ApiApi gains PATH_ORDER_RESOURCE, the new operation's path")
    k = grab(ls, r"the client: its test in after/'s build: tests (\d+) failures (\d+) errors (\d+) skipped (\d+) · git status --short tiffinbox-client: (\d+) lines", "the client's test")
    if k:
        need(k.groups() == ("1", "0", "0", "0", "0"), "the client builds on the regenerated spec, its test passes, nothing of it tracked moved")
    pc = grab(ls, r"PATH_\* constants .*: before (.*) · after (.*)$", "the PATH_* check")
    if pc:
        VALS["path_consts"] = "%s->%s" % (re.sub(r"\D+", " ", pc.group(1)).split()[0] if re.search(r"\d", pc.group(1)) else "?",
                                           re.sub(r"\D+", " ", pc.group(2)).split()[0] if re.search(r"\d", pc.group(2)) else "?")


def c_moved(ls):
    rows = {}
    for m in grab_all(ls, r"^  (before|after) \| (\S+ \S+(?: \[[^\]]*\])?) -> (.*)$"):
        rows.setdefault(m.group(2), {})[m.group(1)] = m.group(3)
    need(len(rows) == 37 and all(len(v) == 2 for v in rows.values()), "U14's list, the Accept class and the new route, printed on both trees (%d requests)" % len(rows))
    moved = [k for k, v in rows.items() if v.get("before") != v.get("after") and "[the new route]" not in k and not k.startswith("GET /v3/api-docs.yaml")]
    need(not moved, "no old line moved (%s)" % moved)
    new = rows.get("GET /api/v1/orders/1 [the new route]", {})
    need(new.get("after", "").startswith("200 application/hal+json"), "the added route on after/: 200 application/hal+json (the added route, not a move)")
    y = rows.get("GET /v3/api-docs.yaml", {})
    named = 1 if y.get("before") != y.get("after") else 0
    VALS["moved"] = len(moved); VALS["named"] = named
    pg = rows.get("GET /api/v1/orders", {})
    need(pg.get("before") == pg.get("after") and pg.get("before", "").startswith("200 "), "the shipped list's page one is byte-equal (the cursor masked): next stays a cursor")


def c_seven(ls):
    m = grab(ls, r"expected ([0-9a-f]{32})", "the expectation")
    got = {x.group(1): x.group(2) for x in grab_all(ls, r"^  (before|after): the seven ([0-9a-f]{32})")}
    if m and need(len(got) == 2, "the seven on both"):
        need(got["before"] == m.group(1) and got["after"] == m.group(1), "the seven on before and on after/ = %s" % m.group(1)[:8])
        VALS["seven"] = m.group(1)[:8]


def c_surface(ls):
    m = grab(ls, r"expected ([0-9a-f]{32})", "the expectation")
    got = {x.group(1): (x.group(2), x.group(3)) for x in grab_all(ls, r"^  (before|after): the old surface ([0-9a-f]{32}) \((\d+) requests")}
    if m and need(len(got) == 2, "the old surface on both"):
        need(got["before"][0] == m.group(1) and got["after"][0] == m.group(1), "the old surface on before and on after/ = %s (%s requests)" % (m.group(1)[:8], got["after"][1]))
        VALS["surface"] = m.group(1)[:8]
    need(any("~ plant (21054" in l and "moved, as planted" in l for l in ls), "the S9.14 plant moved the surface (the check can fail)")


def c_tests(ls):
    pk = {m.group(1): m.groups()[1:] for m in grab_all(ls, r"^  package \| tiffinbox-(\w+) \| tests (\d+) failures (\d+) errors (\d+) skipped (\d+)$")}
    tw = {m.group(1): m.groups()[1:] for m in grab_all(ls, r"^  twin \| tiffinbox-(\w+) \| tests (\d+) failures (\d+) errors (\d+) skipped (\d+)$")}
    need(any(l == "  mvn package exit 0" for l in ls), "mvn package exit 0")
    need(sum(1 for l in ls if l.startswith("  reactor: TiffinBox") and l.endswith("SUCCESS")) >= 8, "the reactor lines SUCCESS (package, verify)")
    if need("web" in pk and "client" in pk, "package's web and client counts"):
        need(pk["web"][1:] == ("0", "0", "0") and pk["client"] == ("1", "0", "0", "0"), "package: web %s, 0 failures 0 errors 0 skipped; client 1" % pk["web"][0])
        need(tw.get("web") == pk["web"] and tw.get("client") == pk["client"], "the Docker-free twin: the same counts")
        VALS["web_tests"] = pk["web"][0]
    c = {m.group(1): m.groups()[1:] for m in grab_all(ls, r"^  package \| class (\w+) \| tests (\d+) failures (\d+) errors (\d+) skipped (\d+)$")}
    need(c.get("OrderResourcesTest") == ("5", "0", "0", "0"), "OrderResourcesTest 5 / 0 / 0 / 0 skipped")
    for k, n in (("CustomerFieldsTest", "5"), ("OrderPagesTest", "5"), ("ApiVersionTest", "2"), ("TiffinBoxRestDocsTest", "1"), ("OpenApiSpecTest", "1")):
        need(c.get(k, ("",))[0] == n, "%s %s" % (k, n))
    b = grab(ls, r"web tests before \(unit 14's values\): (\d+) · new @Test lines (\d+)", "the before count")
    if b and "web" in pk:
        need(int(b.group(1)) + int(b.group(2)) == int(pk["web"][0]), "web %s + %s = %s" % (b.group(1), b.group(2), pk["web"][0]))
        VALS["web_before"] = b.group(1); VALS["k"] = b.group(2)
    s = grab(ls, r"slice TiffinBoxWebTest: before (\d+) · after (\d+) .* byte-equal to before's: (\w+)", "the slice")
    if s:
        need(s.group(1) == s.group(2) and s.group(3) == "yes", "the slice unedited, its count equal (%s): measured, not needed" % s.group(1))
    t = grab(ls, r"test files moved before -> after: (.*) · new: (.*)$", "the test files")
    if t:
        need(t.group(1) == "tiffinbox.json" and t.group(2) == "OrderResourcesTest.java", "the test tree: the spec regenerated, OrderResourcesTest new, nothing else")
    v = grab(ls, r"verify exit (\d+) · ITs tests (\d+) failures (\d+) errors (\d+) · classes (\d+)", "verify")
    if v:
        need(v.group(1) == "0" and v.group(3) == v.group(4) == "0" and v.group(5) == "5", "verify exit 0, five IT classes, 0 failures 0 errors (%s tests)" % v.group(2))
        VALS["its"] = v.group(2)
    bd = grab(ls, r"IT bindings: (\d+) lines · not 127\.0\.0\.1: (\d+)", "the bindings")
    if bd:
        need(bd.group(1) == "5" and bd.group(2) == "0", "five IT BINDINGS lines, none off 127.0.0.1")
    tc = grab(ls, r"Testcontainers containers after: (\d+) · images pulled: (\d+)", "the containers")
    if tc:
        need(tc.groups() == ("0", "0"), "no Testcontainers container left, no image pulled")
    w = grab(ls, r"webonly \| tiffinbox-web \| tests (\d+)", "the web-only form")
    if w and "web" in pk:
        need(w.group(1) == pk["web"][0], "the hand-built -pl tiffinbox-web -am form: the same web count")
    dl = grab(ls, r"downloads across the builds: (\d+)", "the downloads")
    if dl:
        need(dl.group(1) == "0", "Downloading/Downloaded from: 0")


def c_exercise(ls):
    for v in ("broken", "solved"):
        for sh in ("bash", "zsh"):
            blk = [l for l in ls if l.startswith("  %s %s | " % (v, sh))]
            want = "0" if v == "solved" else "1"
            need(any(l.endswith("check exit " + want) for l in blk), "%s under %s: check exit %s" % (v, sh, want))
            if v == "solved":
                need(any(l.endswith("PASS - every clause holds") for l in blk), "solved under %s: PASS" % sh)
            else:
                need(any("GET /api/v1/orders/1 -> 500 " in l for l in blk), "broken under %s: the route the exercise names answers 500 (measured)" % sh)
                need(any("the JVM log's exception: AopConfigException: Could not generate CGLIB subclass of class com.tiffinbox.web.CustomerReads" in l for l in blk), "broken under %s: the JVM log's CGLIB line" % sh)
    var = {m.group(1): m.group(2) for m in grab_all(ls, r"^  ~ (\w+) bash \| check exit (\d+)$")}
    if var:
        need(sorted(var) == ["dropped", "fixedelsewhere", "literal", "unfinal"], "the four refused variants ran (%s)" % ",".join(sorted(var)))
        for v, n in var.items():
            need(n == "1", "the refused variant %s fails (R.196)" % v)
    rd = [l[len("  README: "):] for l in ls if l.startswith("  README: ")]
    sd = [l[len("  SOLUTION: "):] for l in ls if l.startswith("  SOLUTION: ")]
    br = [l[len("  broken bash | "):] for l in ls if l.startswith("  broken bash | ") and not l.endswith("check exit 1")]
    so = [l[len("  solved bash | "):] for l in ls if l.startswith("  solved bash | ") and not l.endswith("check exit 0")]
    need(rd == br and len(rd) >= 4, "exercise/README.md's What it prints = the broken run under bash (%d lines)" % len(rd))
    need(sd == so and len(sd) >= 4, "exercise/SOLUTION.md's What it prints = the solved run under bash (%d lines)" % len(sd))
    VALS["ex_broken"] = "500"


def c_inert(ls):
    m = grab(ls, r"lines naming the key header across the captures: (\d+)", "the count")
    if m:
        need(m.group(1) == "0", "no request of this unit names the key header")


def hashable(name, f):
    for l in lines(f):
        if l.startswith("  ~"):
            continue
        print(l)


# ---- static ---------------------------------------------------------------------------------------------------------------------------
def git(*a):
    return subprocess.run(["git"] + list(a), capture_output=True, text=True).stdout


def static(after, before):
    u = os.getcwd()
    need(os.path.islink("before") and os.readlink("before") == "../c9-unit14/after", "before is a link whose text is ../c9-unit14/after")
    need(os.path.isdir("after") and not os.path.islink("after"), "after/ is a directory")
    os.chdir(os.path.dirname(u))
    units = ["c9-unit%02d" % i for i in range(1, 16)]
    need(git("diff", "--stat", "c7e5118", "--", *units) == "", "git diff --stat c7e5118 -- c9-unit01 .. c9-unit15: empty")
    ps = [l.split("|")[0].strip() for l in git("diff", "--stat", "c7e5118", "--", "*pom.xml").splitlines() if "|" in l]
    need(ps in ([], ["c9-tiffinbox/tiffinbox-web/pom.xml"]), "git diff --stat c7e5118 -- '*pom.xml': only c9-tiffinbox/tiffinbox-web/pom.xml (%s)" % ps)
    os.chdir(u)
    A = lambda p: open(os.path.join(after, p), encoding="utf-8").read()
    Bf = lambda p: open(os.path.join(before, p), encoding="utf-8").read()
    W = "tiffinbox-web/src/main/java/com/tiffinbox/web/"
    orr = A(W + "OrderResources.java")
    need(re.search(r"^class OrderResources \{", orr, re.M) is not None, "OrderResources is not final")
    need('@GetMapping(value = "/api/v1/orders/{id}"' in orr, "OrderResources maps the literal /api/v1/orders/{id}")
    for k in ("Pageable", "JsonView", "MappingJacksonValue", "Probe", "/probe/", "methodOn(CustomerReads", "methodOn(OrderPages", "forward", "compression"):
        need(k not in re.sub(r"(?s)/\*.*?\*/|//[^\n]*", "", orr), "OrderResources' code holds no %s" % k)
    for n in ("OrderPages", "CustomerReads", "CustomerFields", "CustomerNotFound", "TiffinBoxErrors", "TiffinBoxOpenApi", "TiffinBoxApiVersioning", "IdempotencyKeyFilter"):
        need(A(W + n + ".java") == Bf(W + n + ".java"), "%s.java byte-equal to before's" % n)
    for n in ("OrderPages", "CustomerReads", "CustomerFields"):
        need(re.search(r"^final class %s" % n, A(W + n + ".java"), re.M) is not None, "%s still final" % n)
    for p in ("pom.xml", "tiffinbox-core/pom.xml", "tiffinbox-client/pom.xml", "tiffinbox-web/src/main/resources/application.yaml", "Dockerfile", "compose.yaml",
              "tiffinbox-core/src/main/resources/db/migration/V6__tiffin_order.sql", "tiffinbox-core/src/main/java/com/tiffinbox/OrderEntity.java",
              "tiffinbox-web/src/test/java/com/tiffinbox/web/TiffinBoxWebTest.java", "tiffinbox-web/src/test/java/com/tiffinbox/web/OpenApiSpecTest.java",
              "tiffinbox-web/src/test/java/com/tiffinbox/web/OrderPagesTest.java", "tiffinbox-web/src/test/java/com/tiffinbox/web/CustomerFieldsTest.java",
              "tiffinbox-web/src/test/java/com/tiffinbox/web/ApiVersionTest.java", "tiffinbox-web/src/test/java/com/tiffinbox/web/TiffinBoxRestDocsTest.java"):
        need(A(p) == Bf(p), "%s byte-equal to before's" % p)
    pom = A("tiffinbox-web/pom.xml")
    m = re.search(r"<dependency>\s*<groupId>org.springframework.boot</groupId>\s*<artifactId>spring-boot-starter-hateoas</artifactId>(.*?)</dependency>", pom, re.S)
    need(m is not None and "<version>" not in m.group(1), "the starter in tiffinbox-web/pom.xml, no <version>")
    y = A("tiffinbox-web/src/main/resources/application.yaml")
    for k in ("compression", "forward-headers", "hateoas"):
        need(k not in y, "application.yaml holds no %s key" % k)
    hs = [m.group(1) for d, _, fs in os.walk(os.path.join(after, "tiffinbox-web/src/main/java")) for f in fs
          for m in re.finditer(r"@(?:Get|Post|Put|Patch|Delete|Request)Mapping[^\n]*\n(?:\s*@[^\n]*\n)*\s*[\w<>.,? ]+? (\w+)\(", open(os.path.join(d, f), encoding="utf-8").read())]
    need(hs.count("orderResource") == 1, "orderResource occurs once among the mapped handlers (%d)" % hs.count("orderResource"))
    sp = json.load(open(os.path.join(after, "tiffinbox-web/src/test/resources/openapi/tiffinbox.json")))
    ids = [o.get("operationId") for v in sp["paths"].values() for o in v.values()]
    need(len(ids) == len(set(ids)) and "servers" not in sp, "the committed spec's operationIds unique, no servers")
    t = A("tiffinbox-web/src/test/java/com/tiffinbox/web/OrderResourcesTest.java")
    need(not re.search(r"@(?:org\.junit\.jupiter\.api\.(?:condition\.)?)?(?:Disabled|EnabledIf\w*|DisabledIf\w*|EnabledOn\w*|DisabledOn\w*|EnabledFor\w*|DisabledFor\w*)\b", t),
         "OrderResourcesTest: no @Disabled / @EnabledIf... / @DisabledIf... in the simple or the fully-qualified form")
    need(not re.search(r"RANDOM_PORT|DEFINED_PORT|LocalServerPort|\bSocket\b|\b\d{4,5}\b(?!-)", re.sub(r'"[^"]*"', '""', t)), "OrderResourcesTest names no port and no socket")
    me = open(__file__, encoding="utf-8").read(); rs = open("receipts.sh", encoding="utf-8").read()
    for n in LEFT_OUT:
        need(not re.search(r"^def c_%s\(" % n, me, re.M) and not re.search(r"^cap %s " % n, rs, re.M), "the left-out capture %s is in neither the checker nor receipts.sh" % n)
    hsrc = "".join(open(os.path.join(d, f), encoding="utf-8", errors="replace").read() for d, _, fs in os.walk("harness/src") for f in fs)
    need("probe.u14" not in hsrc and "probe.u15" not in hsrc and "probe.u13" not in hsrc, "no earlier unit's probe class in harness/src")
    need(" -pl tiffinbox-core" not in rs, "no -pl tiffinbox-core form (R.391)")
    need("forward-headers" not in "".join(open(os.path.join(d, f), encoding="utf-8", errors="replace").read() for d, _, fs in os.walk(after) for f in fs if f.endswith((".yaml", ".yml", ".properties", ".java", ".xml"))),
         "forward-headers in no committed source or configuration file of after/")
    r = open("README.md", encoding="utf-8").read()
    prose = re.sub(r"```.*?```", "", r, flags=re.S)
    prose = re.sub(r"<!-- values: begin -->.*?<!-- values: end -->", "", prose, flags=re.S)
    nocode = re.sub(r"`[^`]*`", "", prose)
    need("most teams" not in nocode.lower(), "README: no 'most teams'")
    need(not re.search(r"\bmore than (?:double|twice)\b|\b(?:two|three) times\b|\d ?%|\bper (?:item|customer)\b", nocode), "README: no typed ratio, percentage or per-item figure")
    need("excluded by the rule: TiffinBoxErrors" in r, "README: the census's excluded line")
    need(not re.search(r"\bseven final\b|\b7 final\b|`7` (?:final|default)", r), "README: the brief's 7 is never this tree's census (C4)")
    card = A("README.md").split("## Course 9 · unit 16", 1)
    need(len(card) == 2 and not re.search(r"web (?:tests )?`?62`?(?! at unit 14)", card[1].split("\n## ", 1)[0]), "the anchor's unit 16 card gives 62 as unit 14's count only")
    need(not re.search(r"(?<![\w.:<])\d{1,2}:\d{2}(?::\d{2})? ?(?:CET|UTC)?\b", nocode.split("## Runs of record")[0]), "README: no clock figure before the runs section")


def brief16():
    t = open(BRIEF, encoding="utf-8").read()
    return t.split("## Unit 16", 1)[1].split("\n## ", 1)[0]


def hook():
    m = re.search(r'\*\*Hook \(\[S3 §9\]\):\*\* "([^"]+)"', brief16())
    print(m.group(1) if m else "FAIL no hook line")


def exq():
    m = re.search(r'\*\*Exercise:\*\* "(Your turn: [^"]+)"', brief16())
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
    need(sum(1 for l in ls if l.startswith("`HAL`:")) == 1, "exactly one README line starts with the HAL gloss")
    need(GLOSS in ls, "the gloss line byte for byte")
    need(len(GLOSS.split()) <= 25, "the gloss %d words (<= 25)" % len(GLOSS.split()))
    for g in ("A link relation:", "A sparse fieldset:", "A cursor:", "A version carrier:", "A snippet:", "A contract:", "Swagger UI:", "A problem type:", "Code generation:"):
        need(not any(l.startswith(g) for l in ls), "no second gloss of an earlier unit's kind (%s)" % g)
    base = os.path.dirname(os.path.dirname(os.path.abspath(readme)))
    for u, g in (("13", "A cursor:"), ("14", "A sparse fieldset:"), ("15", "A link relation:")):
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
def plants(capdir):
    def run(name, text):
        global FAILS
        f0 = FAILS
        FAILS = []
        import io, contextlib
        buf = io.StringIO()
        with contextlib.redirect_stdout(buf):
            try:
                FN[name](text.splitlines())
            except Exception as e:  # noqa
                fail("unparsable (%s)" % e.__class__.__name__)
        n = len(FAILS)
        FAILS = f0
        return n
    one_off = lambda m: m.group(1) + str(int(m.group(2)) + 1)
    P = [("advisory", "the filed read one day older than the run", lambda t: re.sub(r"(· run date )2026-11-26", r"\g<1>2026-11-27", t, count=1)),
         ("before", "the new route typed 200 on before", lambda t: re.sub(r"(before \| GET /api/v1/orders/1 -> )\d+", r"\g<1>200", t, count=1)),
         ("change", "final put on OrderResources", lambda t: t.replace("its declaration: class OrderResources {", "its declaration: final class OrderResources {", 1)),
         ("change", "JsonView in src/main", lambda t: t.replace("src/main grep JsonView: 0", "src/main grep JsonView: 1", 1)),
         ("change", "a compression key in application.yaml", lambda t: re.sub(r"(application\.yaml compression keys: before 0 · after )0", r"\g<1>1", t, count=1)),
         ("change", "OrderPages made non-final", lambda t: t.replace("  OrderPages: final class OrderPages {", "  OrderPages: class OrderPages {", 1)),
         ("starter", "the lib count typed 165", lambda t: re.sub(r"(lib \| before 157 names · after )\d+", r"\g<1>165", t, count=1)),
         ("starter", "a version put on the starter", lambda t: t.replace("a <version> on the starter: absent", "a <version> on the starter: PRESENT", 1)),
         ("starter", "the pom diff's added-line count one off", lambda t: re.sub(r"(lines added )(\d+)", one_off, t, count=1)),
         ("jackson", "HAL on Jackson 2 typed", lambda t: re.sub(r"referencing com/fasterxml/jackson/databind 0", "referencing com/fasterxml/jackson/databind 3", t, count=1)),
         ("hal", "a byte count one off", lambda t: re.sub(r"(hal \| GET /api/v1/orders/1 \[Accept: application/hal\+json\] -> 200 application/hal\+json )(\d+)", one_off, t, count=1)),
         ("hal", "a host typed localhost for the wire", lambda t: t.replace("self=http://127.0.0.1:21050/api/v1/orders/1", "self=http://localhost/api/v1/orders/1", 1)),
         ("hal", "a member order typed against the print", lambda t: t.replace("members ['_links', 'id',", "members ['id', '_links',", 1)),
         ("accept", "application/json typed as 406", lambda t: re.sub(r"(accept \| GET /api/v1/orders/1 \[Accept: application/json\] -> )200", r"\g<1>406", t, count=1)),
         ("refuse", "order-unknown typed 200", lambda t: re.sub(r"(an id no order has \(/api/v1/orders/21\) -> )404", r"\g<1>200", t, count=1)),
         ("refuse", "the Framework 400 typed as the route's", lambda t: re.sub(r"(not a number .*?)type absent \(no type of TiffinBox's\)", r"type=tag:tiffinbox.example,2026:id-invalid · \1", t, count=1)),
         ("refuse", "the unknown parameter typed ignored", lambda t: re.sub(r"(a query parameter \(/api/v1/orders/1\?x=1\) -> )400 application/problem\+json", r"\g<1>200 application/hal+json", t, count=1)),
         ("final", "methodOn typed as working on CustomerReads", lambda t: re.sub(r"(final \| methodOnFinal: ).*", r"\g<1>http://127.0.0.1:<port>/api/v1/customers/Ravi", t, count=1)),
         ("final", "the exception text from another file (the JVM log's line removed)", lambda t: re.sub(r"(final \| the JVM log [^:]*: ).*", r"\1", t, count=1)),
         ("final", "the census typed 10 final", lambda t: re.sub(r"(census after \| controllers 15 · final, default-run )9", r"\g<1>10", t, count=1)),
         ("next", "the followed page's ids typed against the print", lambda t: t.replace("ids [16, 13, 14, 11, 12]", "ids [16, 13, 14, 11, 10]", 1)),
         ("next", "the cursor typed whole (the mask gone)", lambda t: t.replace("<cursor>", "eyJzIjoibmV3ZXN0IiwiZiI6bnVsbCwiayI6W1siaWQiLCJMIiwiMTUiXV19.x", 1)),
         ("forwarded", "the default start's host typed as the header's", lambda t: re.sub(r"(strategy=default · with the headers -> self )\S+", r"\g<1>https://api.tiffinbox.example/api/v1/orders/1", t, count=1)),
         ("forwarded", "the flag put in application.yaml", lambda t: re.sub(r"(forward-headers in after/'s committed source and configuration files [^)]*\): )0", r"\g<1>1", t, count=1)),
         ("halgz", "the floor typed 4KB", lambda t: t.replace('min-response-size default "2KB"', 'min-response-size default "4KB"', 1)),
         ("halgz", "mime-types typed 9", lambda t: t.replace("mime-types default: 8 entries", "mime-types default: 9 entries", 1)),
         ("halgz", "the 404 typed as compressed", lambda t: re.sub(r"(halgz \| GET /api/v1/orders/21 \[Accept: application/hal\+json\] -> 404 .*?Content-Encoding )none", r"\1gzip", t, count=1)),
         ("specwire", "the wire's media type typed */*", lambda t: t.replace("wire | 200 [Accept: application/hal+json] application/hal+json", "wire | 200 [Accept: application/hal+json] */*", 1)),
         ("spec", "an old operationId renumbered", lambda t: t.replace("the old operations' ids before -> after: equal", "the old operations' ids before -> after: differ", 1)),
         ("spec", "servers added (the committed file differs from the served)", lambda t: t.replace("a final newline): equal", "a final newline): differ", 1)),
         ("spec", "a date-line-only client file called moved", lambda t: re.sub(r"(· moved )0", r"\g<1>1", t, count=1)),
         ("moved", "a moved old line (the seven's route)", lambda t: re.sub(r"(?m)^(  after \| GET /customers/Ravi -> \S+ \S+ · Allow \{\S*\} · Accept-Patch \{\S*\} · body )\w+", r"\g<1>000000000000", t, count=1)),
         ("seven", "the seven's md5 one character off", lambda t: re.sub(r"(after: the seven )(\w)", lambda m: m.group(1) + ("0" if m.group(2) != "0" else "1"), t, count=1)),
         ("surface", "the S9.14 plant not seen", lambda t: t.replace("moved, as planted", "EQUAL (the plant was not seen)", 1)),
         ("tests", "Skipped typed 1", lambda t: re.sub(r"(package \| class OrderResourcesTest \| tests 5 failures 0 errors 0 skipped )0", r"\g<1>1", t, count=1)),
         ("tests", "62 typed as the current web count", lambda t: re.sub(r"(package \| tiffinbox-web \| tests )\d+", r"\g<1>62", t, count=1)),
         ("exercise", "solution = broken", lambda t: re.sub(r"(?m)^(  solved bash \| .*)check exit 0$", r"\1check exit 1", t, count=1)),
         ("exercise", "the broken state's answer borrowed from another route", lambda t: t.replace("GET /api/v1/orders/1 -> 500 ", "GET /api/v1/customers/Ravi -> 200 ", 1)),
         ("hal", "an access-log line the checker cannot parse", lambda t: re.sub(r"the access log: GET ", "the access log: GOT ", t, count=1)),
         ("inert", "a key header typed", lambda t: re.sub(r"(across the captures: )0", r"\g<1>1", t, count=1))]
    n = 0
    for cap, what, mut in P:
        f = os.path.join(capdir, ".r-%s.new" % cap)
        if not os.path.exists(f):
            f = os.path.join(capdir, ".r-%s.out" % cap)
        if not os.path.exists(f):
            fail("plant %s / %s: no capture to plant on" % (cap, what))
            continue
        t = open(f, encoding="utf-8").read()
        t2 = mut(t)
        if t2 == t:
            fail("plant %s / %s: the mutation did not apply" % (cap, what))
            continue
        base = run(cap, t)
        got = run(cap, t2)
        if base == 0 and got > 0:
            ok("plant %s / %s: FAIL (%d), exit 1, no traceback" % (cap, what, got))
            n += 1
        else:
            fail("plant %s / %s: not caught (base %d, planted %d)" % (cap, what, base, got))
    here = os.path.dirname(os.path.abspath(__file__))
    import tempfile, shutil
    tmp = tempfile.mkdtemp(prefix="c9u16-plant-")
    try:
        rd = open(os.path.join(capdir, "README.md"), encoding="utf-8").read()
        for what, txt in (("HAL is compressed", "HAL is compressed."), ("compression shrinks every answer", "Compression shrinks every answer over 2 KB."),
                          ("the list has a next link", "The list has a next link."), ("the href is localhost", "The href is localhost."),
                          ("the framework strategy is safe", "The framework strategy is safe."), ("most teams", "Most teams skip HATEOAS."),
                          ("immune to change", "A client that follows links is immune to change."), ("a ratio typed", "The links make it more than double."),
                          ("a duration word", "It answers instantly."), ("a status in digits", "The route answers 404 back."),
                          ("a second gloss", "A link relation: the name of where a link goes."), ("a link as an access control", "A link is an access control."),
                          ("Spring HATEOAS bare", "Spring HATEOAS writes it.")):
            p = os.path.join(tmp, "README.md"); open(p, "w", encoding="utf-8").write(rd + "\n" + txt + "\n")
            r = subprocess.run([sys.executable, "-I", "-B", os.path.join(here, "s916.py"), os.path.join(here, "dur9.py"), p], capture_output=True, text=True)
            last = (r.stdout.strip().splitlines() or [""])[-1]
            if r.returncode == 0 and not last.endswith("refused: 0"):
                ok("plant README / %s: refused by s916.py (%s)" % (what, last.split("· ")[-1])); n += 1
            else:
                fail("plant README / %s: not refused (%s)" % (what, last))
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
