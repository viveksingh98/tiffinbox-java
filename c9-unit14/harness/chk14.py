#!/usr/bin/env python3
"""Course 9 unit 14's checker (python3 -I -B harness/chk14.py MODE ...). Each capture's check reads the capture's own lines and checks
them against another witness of the same run (curl's size against the saved file's bytes, the access log against curl's line, the
gunzip output against the plain answer, Boot's metadata against the answers, the Surefire XML against the reactor line, ...). Prints
"ok ..." / "FAIL ..." lines and one "VALUES k=v ..." line; exit 1 on any FAIL. A line it cannot parse is a FAIL line, never a traceback.

Modes: CAPTURE FILE (advisory before change full fields refuse view mjv floor page grown under clients yaml spec moved seven surface
inert tests exercise) · hashable CAPTURE FILE (the capture minus its run-variant lines, those starting "  ~") · static AFTER BEFORE ·
gloss README · hook · exq · gloss-line · interleaved · values README VALS · plants (each planted fault made to FAIL first).
Left out of this unit (a name of U13's captures here is a static failure): see LEFT_OUT."""
import hashlib, json, os, re, subprocess, sys

FAILS = []
VALS = {}
LEFT_OUT = ["wa" + "lk", "page" + "able", "tr" + "ap", "rest" + "art", "ta" + "ble", "fi" + "rst", "ne" + "xt", "cur" + "sor",
            "cho" + "ose", "fo" + "ur", "requ" + "ired", "defa" + "ult", "new" + "est", "depre" + "cate", "ret" + "ire", "rep" + "lay",
            "rest" + "docs", "call" + "pg", "snip" + "pets", "sea" + "led", "comp" + "are", "acc" + "ept", "dri" + "ven",
            "cen" + "sus", "jack" + "son", "pau" + "se", "mo" + "ck"]
CAPS = ["advisory", "before", "change", "full", "fields", "refuse", "view", "mjv", "floor", "page", "grown", "under", "clients", "yaml",
        "spec", "moved", "seven", "surface", "inert", "tests", "exercise"]
TAG = "tag:tiffinbox.example,2026:"
FULL_MD5 = "09cb28cd6fa1ad8b8fe4870ec8bbf0d0"   # the full list at the seed's four (282 B), measured by this unit's full capture
C6_MD5 = "bc5535748533a4c827adf3935546b84b"     # Course 6's grown list, read off ../c6-unit30/README.md (compared by the print)
WL = ["name", "mealsPerDay", "pricePerMeal", "mealType"]


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
    out = [re.search(rx, l) for l in ls]
    out = [m for m in out if m]
    if not out:
        fail("unparsable: no line for " + what)
    return out


ONE = re.compile(r"^  (\w+) \| GET (\S+) -> (\d+) (\S+) (\d+) · file (\d+) B md5 ([0-9a-f]{32}) · Content-Length (\S+) · Content-Encoding (\S+)"
                 r" · Transfer-Encoding (\S+) · Vary (\S+)(?: · members (\[.*?\]) · elements (\d+))?$")


def gets(ls, lab):
    """every `one` line of label lab, as dicts, in order"""
    out = []
    for l in ls:
        m = ONE.search(l)
        if m and m.group(1) == lab:
            k = ["lab", "path", "status", "ctype", "size", "file", "md5", "clen", "cenc", "te", "vary", "members", "n"]
            out.append(dict(zip(k, m.groups())))
    return out


def same_size(g, what):
    need(g["size"] == g["file"], "%s: curl's size_download %s = the saved file's bytes %s" % (what, g["size"], g["file"]))


# ---- the captures ------------------------------------------------------------------------------------------------------------------
def c_advisory(ls):
    m = grab(ls, r"^  fetched-at (\S+) \(the hour masked\) · run date (\S+)", "fetched-at")
    if m:
        need(m[0].group(1)[:10] == "2026-11-26", "the filed read is the batch day's (2026-11-26)")
        need(m[0].group(2) == m[0].group(1)[:10], "the run's date is the read's date (else STOP: the orchestrator's dated network act)")
    m = grab(ls, r"^  MD5SUMS\.txt: (\d+) lines, (\d+) verified", "MD5SUMS")
    if m:
        need(m[0].group(1) == m[0].group(2) and int(m[0].group(1)) > 0, "every MD5SUMS line verified (%s/%s)" % (m[0].group(2), m[0].group(1)))
    m = grab(ls, r"^  spring rows (\d+) · naming Spring Framework (\d+)", "spring rows")
    if m:
        need(m[0].group(2) == "0", "Spring's index rows name Spring Framework 0 times")
        VALS["adv_rows"] = m[0].group(1)
    m = grab(ls, r"^  tomcat page md5 ([0-9a-f]{32})", "tomcat md5")
    if m:
        need(m[0].group(1) == "a1a756d985225fb5143eefd9aae3183c", "Tomcat's page md5 = the 2026-11-24 read's")
    want = {"spring-data-jpa": "4.1.3", "spring-data-commons": "4.1.3", "hibernate-core": "7.4.15.Final", "tomcat-embed-core": "11.0.29",
            "jackson-databind": "3.1.8", "jackson-core": "3.1.8", "postgresql": "42.7.14", "h2": "2.5.250", "httpclient5": "5.6.5",
            "spring-web": "7.0.11"}
    for a, v in want.items():
        m = [re.search(r"^  t3 tree \| %s (\S+)$" % re.escape(a), l) for l in ls]
        m = [x for x in m if x]
        need(bool(m) and m[0].group(1) == v, "the t3 tree's %s = %s" % (a, v))
    need(any(l.startswith("  osv (second witness only") for l in ls), "the OSV result printed as a second witness only")
    need(any(l == "  verdict: no pin affected; evidence may proceed" for l in ls), "the verdict line")


def c_before(ls):
    for p, want in (("/api/v1/customers", "404"), ("/api/v1/customers?fields=name", "404"), ("/api/v1/orders", "200"), ("/customers", "200")):
        m = [l for l in ls if re.search(r"^  before \| GET %s -> " % re.escape(p), l)]
        need(bool(m) and (" -> %s " % want) in m[0], "before: GET %s answers %s" % (p, want))
    m = [l for l in ls if l.startswith("  before | GET /customers -> ")]
    if m:
        need(" application/json 282 · " in m[0], "before: the old /customers answers 282 B at the seed's four")
    m = grab(ls, r"^  before \| mappings (\d+) · with customers in the path (\d+) · GET /api/v1/customers mapped (\S+)", "mappings")
    if m:
        need(m[0].group(3) == "no", "before: no request mapping is /api/v1/customers")
        VALS["before_mappings"] = m[0].group(1)
    m = grab(ls, r"^  before \| the committed spec: OPERATIONS (\d+) PATHS (\d+) · (\d+) B md5 ([0-9a-f]{32})", "before spec")
    if m:
        need(m[0].groups() == ("14", "12", "22908", "fd608a6e4ffa42c0f5a4b79e9fdab7b9") or (m[0].group(1), m[0].group(2), m[0].group(3)) == ("14", "12", "22908") and m[0].group(4).startswith("fd608a6e"),
             "before: the committed spec 14 operations, 12 paths, 22908 B, md5 fd608a6e")


def c_change(ls):
    m = grab(ls, r"^  changed \(derived: [^)]*\): (.*)$", "changed list")
    if m:
        got = m[0].group(1).split(" · ")
        want = ["M README.md", "M tiffinbox-web/src/test/resources/openapi/tiffinbox.json",
                "A tiffinbox-web/src/main/java/com/tiffinbox/web/CustomerFields.java",
                "A tiffinbox-web/src/test/java/com/tiffinbox/web/CustomerFieldsTest.java"]
        need(sorted(got) == sorted(want), "the changed anchor paths are the flag-2 set: %s" % " · ".join(got))
        VALS["changed"] = str(len(got))
    m = grab(ls, r"^  the record's components: (\S+)$", "components")
    w = grab(ls, r"^  the whitelist \(CustomerFields\.FIELDS, in order\): (\S+)$", "whitelist")
    if m and w:
        need(m[0].group(1) == w[0].group(1) == ",".join(WL), "the whitelist = the Customer record's components, in the record's order (%s)" % w[0].group(1))
    for k in ("JsonView", "MappingJacksonValue", "Pageable", "offset(", "Probe", "/probe/"):
        m = grab(ls, r"^  src/main grep %s: (\d+) code lines" % re.escape(k), k)
        if m:
            need(m[0].group(1) == "0", "src/main holds no %s" % k)
    m = grab(ls, r"^  application\.yaml compression keys: before (\d+) · after (\d+)", "yaml keys")
    if m:
        need(m[0].groups() == ("0", "0"), "application.yaml holds no compression key, before or after")
    m = grab(ls, r"^  handler customerFields: (\d+) occurrence", "handler")
    if m:
        need(m[0].group(1) == "1", "the new handler's name is unique among the mapped handlers")
    m = grab(ls, r"^  modules: (.*)$", "modules")
    if m:
        need(m[0].group(1) == "tiffinbox-core tiffinbox-web tiffinbox-client (3) -> tiffinbox-core tiffinbox-web tiffinbox-client (3)", "the parent's modules 3 -> 3")
    m = grab(ls, r"^  poms before -> after/: (.*)$", "poms")
    if m:
        need(m[0].group(1) == "equal", "the four poms byte-equal before -> after/")
    m = grab(ls, r"^  ProblemDetail\.forStatus calls in src/main [^:]*: before (\d+) · after (\d+)", "forStatus")
    if m:
        need(int(m[0].group(2)) == int(m[0].group(1)) + 1, "unit 03's instance view: CustomerFields adds one ProblemDetail.forStatus call (a print, not a stop)")
    m = grab(ls, r"^  the web jar's Jackson databind jars: (.*) · the @JsonView annotation's jar: (\S+)", "jackson")
    if m:
        need("jackson-databind-3.1.8.jar" in m[0].group(1), "the web jar carries Jackson 3's databind 3.1.8")
        VALS["jsonview_jar"] = m[0].group(2)
    m = grab(ls, r"^  the web jar's HttpClient 5: (\S+)", "httpclient5")
    if m:
        need(m[0].group(1) == "httpclient5-5.6.5.jar", "HttpClient 5.6.5 on the class path")


def c_full(ls):
    g = gets(ls, "full")
    if not need(len(g) == 2, "full: two GETs"):
        return
    a, o = g
    need(a["path"] == "/api/v1/customers" and a["status"] == "200" and a["ctype"] == "application/json", "full: the new route 200 application/json")
    same_size(a, "full, the new route")
    need(a["clen"] == a["size"], "full: Content-Length %s = the bytes" % a["clen"])
    need(a["md5"] == FULL_MD5, "full: the body md5 = the full list's (09cb28cd)")
    need(a["members"] == str(WL), "full: one element's members are the record's four, in its order")
    need(a["cenc"] == "none" and a["vary"] == "none" and a["te"] == "none", "full: no Content-Encoding, no Vary, no Transfer-Encoding (flag=off)")
    need(o["path"] == "/customers" and o["status"] == "200", "full: the old /customers 200")
    same_size(o, "full, the old route")
    need(o["size"] == a["size"], "full: the old /customers answers the same bytes count (%s)" % o["size"])
    m = grab(ls, r"^  full \| the two bodies byte-equal: (\S+)", "byte-equal")
    if m:
        need(m[0].group(1) == "yes", "full: the new route's full list and the old /customers byte-equal")
    m = grab(ls, r"^  full \| the access log \(the harness's pattern, these GETs\): (.*)$", "access")
    if m:
        need(re.search(r'GET /api/v1/customers 200 %s "-" "-" "curl/' % a["size"], m[0].group(1)) is not None, "full: Tomcat's access log saw the GET, 200, %b = curl's bytes, no Accept-Encoding, no Content-Encoding")
    VALS["full"] = a["size"]


def c_fields(ls):
    g = gets(ls, "fields")
    if not need(len(g) == 4, "fields: four GETs"):
        return
    want = [("/api/v1/customers?fields=name,mealType", "['name', 'mealType']"), ("/api/v1/customers?fields=name", "['name']"),
            ("/api/v1/customers?fields=mealType,name", "['name', 'mealType']"), ("/api/v1/customers?fields=pricePerMeal", "['pricePerMeal']")]
    for x, (p, mem) in zip(g, want):
        need(x["path"] == p and x["status"] == "200" and x["ctype"] == "application/json", "fields: %s 200 application/json" % p)
        same_size(x, "fields " + p)
        need(x["members"] == mem, "fields: %s members %s" % (p, mem))
        need(x["clen"] == x["size"] and x["cenc"] == "none", "fields: %s Content-Length = bytes, no encoding" % p)
    need(g[0]["md5"] == g[2]["md5"], "fields: the member order is the record's, not the request's (name,mealType = mealType,name, byte for byte)")
    VALS["fields"] = "%s/%s" % (g[0]["size"], g[1]["size"])
    m = grab(ls, r"^  fields \| the access log: (\d+) lines with fields=, each status 200: (\d+) not", "access")
    if m:
        need(m[0].group(1) == "4" and m[0].group(2) == "0", "fields: the access log saw the four, each 200")


REF = re.compile(r"^  refuse \| (.*?) \((\S*)\) -> (\d+) (\S+) \| (.*)$")


def c_refuse(ls):
    rows = [REF.search(l) for l in ls]
    rows = [r for r in rows if r]
    need(len(rows) == 12, "refuse: twelve requests (%d)" % len(rows))
    want = {"?fields=nickname": "field-unknown", "?fields=name,nickname": "field-unknown", "?colour=red": "parameter-unknown",
            "?size=5": "parameter-unknown", "?fields=": "fields-invalid", "?fields=name,": "fields-invalid", "?fields=name,name": "fields-invalid",
            "?fields=Name": "field-unknown", "?fields=name&fields=mealType": "fields-invalid", "?fields%5B%5D=name": "parameter-unknown",
            "?fields=%20name": "field-unknown"}
    types = set()
    for r in rows:
        q, st, ct, body = r.group(2), r.group(3), r.group(4), r.group(5)
        if q in want:
            t = TAG + want[q]
            need(st == "400" and ct == "application/problem+json" and ("type=" + t) in body and "instance=/api/v1/customers" in body,
                 "refuse: %s -> 400 problem+json %s, instance the path" % (q, want[q]))
            types.add(want[q])
        elif q == "?fields=%zz":
            need(st == "400" and "type=" not in body, "refuse: %s -> 400 with no type: not the route's (named)" % q)
            VALS["notype"] = "fields=%zz"
    for q in ("?fields=nickname", "?fields=Name"):
        b = [r.group(5) for r in rows if r.group(2) == q]
        need(bool(b) and "[name, mealsPerDay, pricePerMeal, mealType]" in b[0], "refuse: %s's detail names the accepted fields" % q)
    m = grab(ls, r"^  refuse \| the JVM's log: lines naming an Exception (\d+)", "log")
    if m:
        VALS["log_exceptions"] = m[0].group(1)
    VALS["refusals"] = str(sum(1 for r in rows if r.group(2) in want))
    VALS["types"] = ",".join(sorted(types))


def c_view(ls):
    g = gets(ls, "view")
    if not need(len(g) == 2, "view: two GETs"):
        return
    v, n = g
    need(v["path"] == "/probe/u14/fields/view" and v["status"] == "200" and v["members"] == "['name', 'mealType']", "view: the harness's @JsonView route 200, members name and mealType")
    need(n["path"] == "/probe/u14/fields/noview" and n["status"] == "200" and n["members"] == "['name', 'mealType', 'mealsPerDay', 'pricePerMeal']", "view: the same route without the view, four members")
    same_size(v, "view")
    m = grab(ls, r"^  view \| the view's bytes against the shipped route's \?fields=name,mealType bytes \(the fields capture\): ([0-9a-f]{32}) vs ([0-9a-f]{32})", "vs")
    if m:
        need(m[0].group(1) == m[0].group(2), "view: the harness's view bytes = the shipped route's ?fields=name,mealType bytes")
    VALS["view"] = v["size"]
    VALS["noview"] = n["size"]


def c_mjv(ls):
    m = grab(ls, r"^  mjv \| GET /probe/u14/fields/mjv -> (\d+) (\S+) \| (\{.*\})$", "mjv")
    if m:
        need(m[0].group(1) == "500", "mjv: the harness's MappingJacksonValue route answers 500")
        try:
            d = json.loads(m[0].group(3))
            need(d.get("status") == 500 and d.get("timestamp") == "<masked>" and d.get("path") == "/probe/u14/fields/mjv", "mjv: Boot's /error body (timestamp masked)")
        except Exception as e:  # noqa
            fail("unparsable: the mjv body (%s)" % e.__class__.__name__)
    m = grab(ls, r"^  mjv \| the JVM's log: (.*)$", "log")
    if m:
        need(m[0].group(1) == "java.lang.UnsupportedOperationException: MappingJacksonValue is not supported, use hints instead", "mjv: the run's own log names the exception")
    m = grab(ls, r"^  mjv \| the frame that threw: (\S+)", "frame")
    if m:
        need(m[0].group(1).startswith("org.springframework.http.converter."), "mjv: the frame that threw is a Spring converter (%s)" % m[0].group(1))
        VALS["thrower"] = m[0].group(1).rsplit(".", 2)[-2]
    m = grab(ls, r"^  mjv \| MappingJacksonValue's jar: (\S+) · the Jackson 3 databind on the class path: (\S+)", "jars")
    if m:
        need(m[0].group(1) == "spring-web-7.0.11.jar" and m[0].group(2) == "jackson-databind-3.1.8.jar", "mjv: the wrapper in spring-web 7.0.11, Jackson 3.1.8 on the class path")


def c_floor(ls):
    m = grab(ls, r"^  floor \| the jar: (\S+)$", "jar")
    if m:
        need(m[0].group(1) == "spring-boot-web-server-4.1.3.jar", "floor: the metadata is spring-boot-web-server-4.1.3.jar's")
    m = grab(ls, r"^  floor \| keys (\d+): (.*)$", "keys")
    if m:
        need(m[0].group(1) == "5", "floor: five server.compression keys")
    m = grab(ls, r"^  floor \| server\.compression\.enabled default (\S+)$", "enabled")
    if m:
        need(m[0].group(1) == "false", "floor: enabled defaults to false")
    m = grab(ls, r"^  floor \| server\.compression\.min-response-size default (\S+)$", "min")
    if m:
        need(m[0].group(1) == '"2KB"', "floor: min-response-size defaults to 2KB")
        VALS["floor"] = "2KB"
    m = grab(ls, r"^  floor \| mime-types default: (\d+) entries", "mime count")
    mt = [l.split("mime-type ", 1)[1] for l in ls if l.startswith("  floor | mime-type ")]
    if m:
        need(m[0].group(1) == "8" and len(mt) == 8, "floor: mime-types 8, counted one by one (%d)" % len(mt))
        VALS["mime_types"] = str(len(mt))
    m = grab(ls, r"^  floor \| application/json in the list: (\S+) · application/hal\+json: (\S+) · application/problem\+json: (\S+)", "in list")
    if m:
        need(m[0].groups() == ("yes", "no", "no"), "floor: application/json in, hal+json and problem+json not in the list")
    g = gets(ls, "floor")
    if need(len(g) == 2, "floor: two GETs, gzip asked"):
        for x in g:
            same_size(x, "floor " + x["path"])
            need(x["status"] == "200" and x["cenc"] == "none" and x["vary"] == "none" and x["clen"] == x["size"], "floor: %s at 4 customers, gzip asked, flag=on -> %s B, no Content-Encoding, no Vary, Content-Length set" % (x["path"], x["size"]))
    m = grab(ls, r"^  floor \| the access log: (.*)$", "access")
    if m:
        need(m[0].group(1).count('"gzip" "-"') == 2, "floor: Tomcat saw gzip asked and sent no Content-Encoding, twice")


def c_page(ls):
    g = gets(ls, "page")
    if not need(len(g) == 2, "page: two GETs"):
        return
    p, z = g
    need(p["status"] == "200" and p["ctype"].startswith("text/html") and p["cenc"] == "none", "page: /dashboard HTML 200, plain")
    need(z["status"] == "200" and z["cenc"] == "gzip", "page: gzip asked -> Content-Encoding gzip")
    same_size(p, "page plain")
    same_size(z, "page gzip")
    m = grab(ls, r"^  page \| gunzip -c, the saved bytes: (\d+) B md5 ([0-9a-f]{32}) · equal to the plain answer: (\S+)", "gunzip")
    if m:
        need(m[0].group(1) == p["size"] and m[0].group(2) == p["md5"] and m[0].group(3) == "yes", "page: gunzip gives back the plain page byte for byte")
    VALS["page"] = "%s->%s" % (p["size"], z["size"])
    VALS["page_framing"] = "%s/%s" % ("Content-Length" if p["clen"] != "none" else "chunked" if p["te"] == "chunked" else "?",
                                       "Content-Length" if z["clen"] != "none" else "chunked" if z["te"] == "chunked" else "?")
    VALS["page_md5"] = p["md5"][:8]


def c_grown(ls):
    m = grab(ls, r"^  grow \| 30 POST /customers [^>]*-> statuses (.*)$", "grow")
    if m:
        need(m[0].group(1) == "201 x30", "grown: 30 POSTs, 201 x30")
    g = gets(ls, "grown")
    if not need(len(g) == 4, "grown: four GETs"):
        return
    gz = {}
    for i, p in enumerate(("/customers", "/api/v1/customers")):
        pl, z = g[2 * i], g[2 * i + 1]
        need(pl["path"] == p and z["path"] == p, "grown: %s plain then gzip asked" % p)
        same_size(pl, "grown plain " + p)
        same_size(z, "grown gzip " + p)
        need(pl["cenc"] == "none" and pl["vary"] == "accept-encoding", "grown: %s plain, flag=on -> no encoding, Vary accept-encoding" % p)
        need(z["cenc"] == "gzip" and z["vary"] == "accept-encoding", "grown: %s gzip asked -> Content-Encoding gzip" % p)
        m = grab(ls, r"^  grown \| %s gunzip -c: (\d+) B md5 ([0-9a-f]{32}) · equal to the plain answer: (\S+)" % re.escape(p), "gunzip " + p)
        if m:
            need(m[0].group(1) == pl["size"] and m[0].group(2) == pl["md5"] and m[0].group(3) == "yes", "grown: %s gunzip = the plain answer, byte for byte" % p)
        gz[p] = (pl, z)
    if len(gz) == 2:
        a, b = gz["/customers"], gz["/api/v1/customers"]
        need(a[0]["md5"] == b[0]["md5"], "grown: the two routes' plain bodies byte-equal")
        need(a[0]["md5"] == C6_MD5, "grown: the plain md5 = Course 6's bc553574 (reproduced)")
        VALS["grown"] = "%s->%s" % (a[0]["size"], a[1]["size"])
        VALS["c6_md5"] = "equal" if a[0]["md5"] == C6_MD5 else "differ"
        m = grab(ls, r"^  grown \| the access log's %b for the gzip-asked GETs: (\S+) (\S+) ·", "%b")
        if m:
            bb = [x.split(":")[1] for x in m[0].groups()]
            need(all(x.isdigit() for x in bb), "grown: Tomcat's %b printed beside curl's (the gap not explained)")
            VALS["pct_b"] = bb[0]


def c_under(ls):
    g = gets(ls, "under")
    if not need(len(g) == 4, "under: four GETs"):
        return
    sizes = []
    for i, q in enumerate(("?fields=name", "?fields=name,mealType")):
        pl, z = g[2 * i], g[2 * i + 1]
        same_size(pl, "under plain " + q)
        same_size(z, "under gzip " + q)
        need(pl["status"] == z["status"] == "200" and pl["n"] == "34", "under: %s 200, 34 elements" % q)
        need(z["cenc"] == "none" and z["vary"] == "none" and z["clen"] == z["size"] and z["size"] == pl["size"], "under: %s gzip asked -> %s B, no Content-Encoding, no Vary, Content-Length set" % (q, z["size"]))
        need(int(pl["size"]) < 2048, "under: %s below the floor read back (2KB = 2048 B)" % q)
        sizes.append(pl["size"])
    m = grab(ls, r"^  under \| the floor read back \(the floor capture\): (\S+)", "floor")
    if m:
        need(m[0].group(1) == "2KB", "under: the floor printed beside them (2KB)")
    VALS["under"] = "/".join(sizes)


def c_clients(ls):
    cl = [re.search(r"^  clients \| CLIENT (.*?) · factory (\S+) · status (\d+) · Content-Encoding (\S+) · Content-Length (\S+) · Vary (\S+) · bytes handed back (\d+) · md5 ([0-9a-f]{32})$", l) for l in ls]
    cl = [c for c in cl if c]
    if not need(len(cl) == 3, "clients: three client lines"):
        return
    want = ["org.springframework.http.client.HttpComponentsClientHttpRequestFactory", "org.springframework.http.client.HttpComponentsClientHttpRequestFactory",
            "org.springframework.http.client.JdkClientHttpRequestFactory"]
    for c, f in zip(cl, want):
        need(c.group(2) == f, "clients: %s's factory %s" % (c.group(1), f.rsplit(".", 1)[1]))
        need(c.group(3) == "200" and c.group(4) == "null" and c.group(5) == "null", "clients: %s exposes no Content-Encoding and no Content-Length" % c.group(1))
        need(c.group(7) == "2403" and c.group(8) == C6_MD5, "clients: %s hands back the plain 2403 bytes (md5 = the plain list's)" % c.group(1))
    m = grab(ls, r"^  clients \| Tomcat saw \(the access log, the three GETs\): (.*)$", "access")
    if m:
        al = m[0].group(1).split("|")
        need(len(al) == 3, "clients: Tomcat's access log holds three GETs (%d)" % len(al))
        if len(al) == 3:
            ae = [re.search(r'^GET /customers 200 (\d+) "([^"]*)" "([^"]*)" "([^"]*)"$', x) for x in al]
            if need(all(ae), "clients: each access-log line parses"):
                for x in ae:
                    need(x.group(2) != "-" and "gzip" in x.group(2) and x.group(3) == "gzip", "clients: Tomcat saw Accept-Encoding %s and sent gzip" % x.group(2))
                need(ae[0].group(4).startswith("Apache-HttpClient/5.6.5") and ae[1].group(4).startswith("Apache-HttpClient/5.6.5") and ae[2].group(4).startswith("Java-http-client/"),
                     "clients: each client's own User-Agent (HttpClient 5.6.5 twice, the JDK's client)")
                VALS["ae"] = ";".join(x.group(2).replace(" ", "") for x in ae)
    m = grab(ls, r"^  clients \| Course 6's access-log line for that factory \(\.\./c6-unit30/README\.md:(\d+)\): (.*)$", "c6 line")
    if m:
        need("accept-encoding:gzip,deflate content-encoding:gzip" in m[0].group(2), "clients: Course 6's line for its JDK factory (README.md:%s): gzip,deflate asked, gzip sent - no contrast" % m[0].group(1))
    m = grab(ls, r"^  clients \| Course 6's factory line \(\.\./c6-unit30/README\.md:(\d+)\): (.*)$", "c6 factory")
    if m:
        need("JdkClientHttpRequestFactory" in m[0].group(2), "clients: Course 6's RestClient.create() picked the JDK factory (its README.md:%s)" % m[0].group(1))
    m = grab(ls, r"^  clients \| Course 6's class path \([^)]*\): (.*)$", "c6 cp")
    if m:
        need(m[0].group(1).endswith(": 0"), "clients: Course 6's class path held no httpclient5 (its own print)")
    m = grab(ls, r"^  clients \| Gzip14 exit (\d+)", "exit")
    if m:
        need(m[0].group(1) == "0", "clients: the harness's client exit 0")


def c_yaml(ls):
    m = grab(ls, r"^  yaml \| the copy's compression keys: (\d+) · after/'s: (\d+)", "keys")
    if m:
        need(m[0].group(1) == "1" and m[0].group(2) == "0", "yaml: the scratch copy holds the key; after/ none")
    m = grab(ls, r"^  yaml \| the old surface, gzip asked: after/ flag=off (\S+) \((\d+) requests\) · the yaml copy (\S+) \((\d+) requests\)", "surface")
    if m:
        need(m[0].group(2) == m[0].group(4) == "13", "yaml: 13 requests on each side")
    m = grab(ls, r"^  yaml \| answers that differ: (\d+) - (.*)$", "differ")
    if m:
        n = int(m[0].group(1))
        need(n > 0, "yaml: the key in application.yaml moves old answers (%d)" % n)
        VALS["yaml_moved"] = str(n)
        VALS["yaml_answers"] = m[0].group(2).replace(" ", "_")
    adds = [l for l in ls if re.match(r"^  yaml \| .*: added \[", l)]
    need(all("vary: accept-encoding" in l for l in adds), "yaml: every moved answer gained vary: accept-encoding")
    VALS["yaml_gzip"] = str(sum(1 for l in adds if "Content-Encoding: gzip" in l))
    m = grab(ls, r"^  yaml \| the seven under the key \(its own client, no gzip asked\): (\S+) · expected (\S+)", "seven")
    if m:
        VALS["yaml_seven"] = "equal" if m[0].group(1) == m[0].group(2) else "moved"


def c_spec(ls):
    m = grab(ls, r"^  the committed file against the served document \(servers removed\): (\S+)", "served")
    if m:
        need(m[0].group(1) == "equal", "the committed spec = the served document with servers removed")
    m = grab(ls, r"^  before: OPERATIONS (\d+) PATHS (\d+) · after: OPERATIONS (\d+) PATHS (\d+)", "ops")
    if m:
        a, b, c, d = map(int, m[0].groups())
        need((a, b) == (14, 12) and c == a + 1 and d == b + 1, "operations and paths each grew by one (%d/%d -> %d/%d)" % (a, b, c, d))
        VALS["ops"] = "%d->%d" % (a, c)
        VALS["paths"] = "%d->%d" % (b, d)
    m = grab(ls, r"^  the old operations' ids before -> after: (\S+)", "old ids")
    if m:
        need(m[0].group(1) == "equal", "the old operations' operationIds equal before and after (no renumbering)")
    m = grab(ls, r"^  the diff against before's \(fd06e77's\) file: (\d+) lines added, (\d+) removed", "diff")
    if m:
        need(m[0].group(2) == "0", "the committed spec's diff removes no line")
        VALS["spec_added"] = m[0].group(1)
    m = grab(ls, r"^  the paths added: (.*)$", "paths added")
    if m:
        need(m[0].group(1) == "['/api/v1/customers'] removed [] other paths moved [] components moved False", "one path added, no other path or component moved")
    m = grab(ls, r"^  spec vs wire \| 200 (\S+) (\S+) (\S+) · wire 200 (\S+) (\S+) members (\[.*?\]) · schema properties (\[.*?\]) required (\[.*?\])", "spec vs wire 200")
    if m:
        need(m[0].group(1) == m[0].group(4) == "application/json", "the new route's 200: the spec's media type = the wire's (application/json)")
        need(m[0].group(2) == "array" and m[0].group(5) == "array" and m[0].group(3) == "Customer", "the 200's schema an array of Customer; the wire an array")
        need(m[0].group(6) == m[0].group(7), "the full answer's members = the schema's properties")
        VALS["required"] = m[0].group(8).replace(" ", "")
    m = grab(ls, r"^  spec vs wire \| the gap, named: \?fields=mealsPerDay answers members (\[.*?\])", "gap")
    if m:
        need(m[0].group(1) == "['mealsPerDay']", "the gap named: a fieldset answer lacks the schema's required members")
    m = grab(ls, r"^  spec vs wire \| 400 (\S+) (\S+) · wire 400 (\S+)", "spec vs wire 400")
    if m:
        need(m[0].group(1) == m[0].group(3) == "application/problem+json", "the new route's 400: spec = wire (application/problem+json)")
    m = grab(ls, r"^  operationIds unique: (\S+)", "unique ids")
    if m:
        need(m[0].group(1) == "yes", "the spec's operationIds are unique")
    m = grab(ls, r"^  the client: FILES (\d+) -> (\d+) · build exit (\d+)", "client")
    if m:
        need(m[0].group(3) == "0", "the client builds on the regenerated spec")
        VALS["client_files"] = "%s->%s" % (m[0].group(1), m[0].group(2))
    m = grab(ls, r"^  the client: counts - equal (\d+) · date line only (\d+) · lines added only (\d+) · moved (\d+) · added (\d+)", "client counts")
    if m:
        need(m[0].group(4) == "0", "the client: no generated file moved beyond its date line and the new operation's added lines")
        need(any(l == "  the client: src/main/java/com/tiffinbox/client/api/ApiApi.java lines added only (the new operation), the date line aside" for l in ls), "the client: ApiApi gained lines only")
        VALS["client_kinds"] = "dateonly=%s,linesadded=%s,new=%s" % (m[0].group(2), m[0].group(3), m[0].group(5))
    need(any(re.search(r"^  the client: ApiApi\.java customerFields: [1-9]", l) for l in ls), "the generated ApiApi holds customerFields")
    m = grab(ls, r"^  OpenApiSpecTest on the regenerated file: tests (\d+) failures (\d+) errors (\d+)", "OpenApiSpecTest")
    if m:
        need(m[0].groups() == ("1", "0", "0"), "OpenApiSpecTest passes on the regenerated file")
    m = grab(ls, r"^  committed md5 before (\S+) · after (\S+) · bytes before (\d+) · after (\d+)", "md5s")
    if m:
        need(m[0].group(1).startswith("fd608a6e") and m[0].group(3) == "22908", "the BEFORE file is fd608a6e, 22908 B")
        VALS["spec_md5"] = m[0].group(2)[:8]
        VALS["spec_bytes"] = m[0].group(4)


def c_moved(ls):
    rows = {}
    for l in ls:
        m = re.search(r"^  (before|after) \| (.*?) -> (.*)$", l)
        if m:
            rows.setdefault(m.group(2), {})[m.group(1)] = m.group(3)
    need(len(rows) >= 22, "the moved list: %d requests on both trees" % len(rows))
    mv = [k for k, v in rows.items() if v.get("before") != v.get("after") and not k.endswith(" /api/v1/customers")]
    named = {"GET /v3/api-docs.yaml"}
    need(set(mv) <= named, "moved lines outside the added route and the document's YAML: %s" % (", ".join(sorted(set(mv) - named)) or "0"))
    need("GET /v3/api-docs.yaml" in mv, "the document's YAML moved by the added path (named, S9.37)")
    nr = rows.get("GET /api/v1/customers", {})
    need(nr.get("before", "").startswith("404") and nr.get("after", "").startswith("200"), "the added route: 404 -> 200 (named, not a move)")
    VALS["moved"] = str(len(set(mv) - named))
    VALS["named"] = str(len(mv))
    m = grab(ls, r"^  web jar: entries only after has: (.*)$", "web jar")
    if m:
        need(m[0].group(1) == "BOOT-INF/classes/com/tiffinbox/web/CustomerFields.class", "the web jar gained CustomerFields.class, and only it")
    m = grab(ls, r"^  core jar: entries only after has: (.*)$", "core jar")
    if m:
        need(m[0].group(1) == "none", "the core jar gained nothing")
    for j in ("web", "core"):
        m = grab(ls, r"^  %s jar: shared entries whose CRC moved: (.*)$" % j, j + " crc")
        if m:
            need(m[0].group(1) == "none", "%s jar: no shared entry's CRC moved" % j)
        m = grab(ls, r"^  %s jar: entries only before has: (.*)$" % j, j + " gone")
        if m:
            need(m[0].group(1) == "none", "%s jar: no entry lost" % j)
    m = grab(ls, r"^  the web jar's md5: before \S+ · after \S+ \((\S+)\)", "jar md5")
    if m:
        need(m[0].group(1) == "differ", "the web jar's md5 differs (it gained an entry)")
    m = grab(ls, r"^  BOOT-INF/lib names: before (\d+) · after (\d+) · moved (\d+)", "lib")
    if m:
        need(m[0].groups() == ("157", "157", "0"), "BOOT-INF/lib 157 = 157, names unmoved")


def c_seven(ls):
    m = grab(ls, r"^  expected (\S+)$", "expected")
    exp = m[0].group(1) if m else "?"
    for s in ("before", "after"):
        m = grab(ls, r"^  %s: the seven (\S+) " % s, s)
        if m:
            need(m[0].group(1) == exp, "%s: the seven = %s" % (s, exp[:8]))
    need(any("not a witness for the new route" in l for l in ls), "said: not a witness for the new route (R.511)")
    VALS["seven"] = exp[:8]


def c_surface(ls):
    m = grab(ls, r"^  expected (\S+)$", "expected")
    exp = m[0].group(1) if m else "?"
    for s in ("before", "after"):
        m = grab(ls, r"^  %s: the old surface (\S+) \((\d+) requests" % s, s)
        if m:
            need(m[0].group(1) == exp and m[0].group(2) == "13", "%s: the old surface = %s (13 requests)" % (s, exp[:8]))
    m = grab(ls, r"^  ~ plant \(21034, the S9\.14 slot\): the old surface (\S+)", "plant")
    if m:
        need(m[0].group(1) != exp, "the S9.14 plant moves the old surface (the check can fail)")
    VALS["surface"] = exp[:8]


def c_inert(ls):
    m = grab(ls, r"^  request lines naming the key header across the captures: (\d+)", "inert")
    if m:
        need(m[0].group(1) == "0", "no request carries an Idempotency-Key")


def c_tests(ls):
    def mod(lab):
        m = [re.search(r"^  %s \| tiffinbox-(web|client) \| tests (\d+) failures (\d+) errors (\d+) skipped (\d+)" % re.escape(lab), l) for l in ls]
        return {x.group(1): tuple(map(int, x.groups()[1:])) for x in m if x}
    for lab in ("package", "twin", "webonly", "verify"):
        d = mod(lab)
        need("web" in d and d["web"][1:] == (0, 0, 0), "%s: tiffinbox-web green, 0 skipped (%s)" % (lab, d.get("web", "?")))
        if lab in ("package", "twin"):
            need(d.get("client") == (1, 0, 0, 0), "%s: tiffinbox-client 1" % lab)
        if lab == "package" and "web" in d:
            VALS["web_tests"] = str(d["web"][0])
    if "web_tests" in VALS:
        need(all(mod(l).get("web", (0,))[0] == int(VALS["web_tests"]) for l in ("twin", "webonly", "verify")), "the twin, the web-only form and verify print the same web count")
    for cls, n in (("CustomerFieldsTest", 5), ("OrderPagesTest", 5), ("ApiVersionTest", 2), ("TiffinBoxRestDocsTest", 1), ("OpenApiSpecTest", 1), ("TiffinBoxWebTest", 15)):
        m = grab(ls, r"^  package \| class %s \| tests (\d+) failures (\d+) errors (\d+) skipped (\d+)" % cls, cls)
        if m:
            need(tuple(map(int, m[0].groups())) == (n, 0, 0, 0), "%s: %d run, 0 failed, 0 skipped" % (cls, n))
    m = grab(ls, r"^  slice TiffinBoxWebTest: before (\d+) · after (\d+) .*byte-equal to before's: (\S+)", "slice")
    if m:
        need(m[0].group(1) == m[0].group(2) and m[0].group(3) == "yes", "the slice unedited and its count equal (no slice edit needed: measured)")
    m = grab(ls, r"^  web tests before \(unit 13's values\): (\d+) · new @Test lines (\d+)", "before count")
    if m and "web_tests" in VALS:
        need(int(m[0].group(1)) + int(m[0].group(2)) == int(VALS["web_tests"]), "web %s + %s = %s" % (m[0].group(1), m[0].group(2), VALS["web_tests"]))
        VALS["web_before"] = m[0].group(1)
        VALS["k"] = m[0].group(2)
    m = grab(ls, r"^  verify exit (\d+) · ITs tests (\d+) failures (\d+) errors (\d+) · classes (\d+)", "verify")
    if m:
        need(m[0].groups() == ("0", "14", "0", "0", "5"), "verify: exit 0, 14 ITs green in 5 classes")
        VALS["its"] = m[0].group(2)
    m = grab(ls, r"^  IT bindings: (\d+) lines · not 127\.0\.0\.1: (\d+)", "bindings")
    if m:
        need(m[0].group(1) == "5" and m[0].group(2) == "0", "five IT BINDINGS lines, every one on 127.0.0.1")
    m = grab(ls, r"^  Testcontainers containers after: (\d+) · images pulled: (\d+)", "tc")
    if m:
        need(m[0].groups() == ("0", "0"), "Testcontainers containers after 0, nothing pulled")
    m = grab(ls, r"^  downloads across the builds: (\d+)", "downloads")
    if m:
        need(m[0].group(1) == "0", "Downloading from: 0 in every log")
    m = grab(ls, r"^  test files moved before -> after: (.*?) · new: (.*)$", "moved tests")
    if m:
        need(m[0].group(1) == "tiffinbox.json" and m[0].group(2) == "CustomerFieldsTest.java", "the test files moved: the spec only; new: CustomerFieldsTest")
    m = grab(ls, r"^  BOOT-INF/lib: before (\d+) · after (\d+)", "lib")
    if m:
        need(m[0].groups() == ("157", "157"), "BOOT-INF/lib 157 before and after")


def c_exercise(ls):
    for sh in ("bash", "zsh"):
        b = [l for l in ls if l.startswith("  broken %s | check exit " % sh)]
        need(bool(b) and not b[0].endswith("check exit 0"), "broken (%s): check.sh fails" % sh)
        s = [l for l in ls if l.startswith("  solved %s | check exit " % sh)]
        need(bool(s) and s[0].endswith("check exit 0"), "solved (%s): check.sh passes" % sh)
    for v, doc in (("broken", "README"), ("solved", "SOLUTION")):
        for sh in ("bash", "zsh"):
            got = [l.split(" | ", 1)[1] for l in ls if l.startswith("  %s %s | " % (v, sh)) and not l.startswith("  %s %s | check exit" % (v, sh))]
            want = [l[len("  %s: " % doc):] for l in ls if l.startswith("  %s: " % doc)]
            need(got == want and got, "%s (%s): the run printed exactly exercise/%s.md's What it prints block (%d lines)" % (v, sh, doc, len(want)))
    m = grab(ls, r"^  broken bash \| fields=name -> (\d+) (\S+) (\d+) · members (.*)$", "broken answer")
    if m:
        need(m[0].group(1) == "200" and m[0].group(3) == "282", "broken: ?fields=name answers 200 with the full list's 282 B")
        VALS["ex_broken"] = "%s/%s" % (m[0].group(1), m[0].group(3))
    m = grab(ls, r"^  broken bash \| fields=nickname -> (\d+) ", "broken nickname")
    if m:
        VALS["ex_broken_unknown"] = m[0].group(1)
    m = grab(ls, r"^  solved bash \| fields=nickname -> (\d+) (\S+)", "solved answer")
    if m:
        need(m[0].group(1) == "400" and m[0].group(2) == "application/problem+json", "solved: fields=nickname -> 400 problem+json")


# ---- the hashable form --------------------------------------------------------------------------------------------------------------
def hashable(name, f):
    for l in lines(f):
        if l.startswith("  ~"):
            continue
        if name == "tests" and re.search(r"Tests run:|Time elapsed", l):
            continue
        print(l)


# ---- static ---------------------------------------------------------------------------------------------------------------------------
COND = re.compile(r"@(?:org\.junit\.jupiter\.api\.(?:condition\.)?)?(?:Disabled|EnabledIf\w*|DisabledIf\w*|EnabledOn\w*|DisabledOn\w*|EnabledFor\w*|DisabledFor\w*)\b")


def static(after, before):
    src = os.path.join(after, "tiffinbox-web/src/main/java/com/tiffinbox/web/CustomerFields.java")
    tst = os.path.join(after, "tiffinbox-web/src/test/java/com/tiffinbox/web/CustomerFieldsTest.java")
    s = open(src).read()
    need(re.search(r"^final class CustomerFields\b", s, re.M) is not None, "CustomerFields is final")
    need('@GetMapping("/api/v1/customers")' in s, "CustomerFields maps the literal /api/v1/customers")
    code = re.sub(r"/\*.*?\*/|//[^\n]*", "", s, flags=re.S)
    for k in ("JsonView", "MappingJacksonValue", "Pageable", "offset(", "Probe", "/probe/", "PostMapping", "compression"):
        need(k not in code, "CustomerFields' code holds no %s" % k)
    wl = re.findall(r'FIELDS\.put\("(\w+)"', s)
    rec = open(os.path.join(after, "tiffinbox-core/src/main/java/com/tiffinbox/Customer.java")).read()
    comps = re.findall(r"(?:String|int)\s+(\w+)\s*(?:,|$)", re.search(r"record Customer\((.*?)\)\s*\{", rec, re.S).group(1))
    need(wl == comps == WL, "the whitelist = the Customer record's components, in order (%s)" % ",".join(wl))
    need(re.search(r"\bm\.put\(f\b", code) is None, "no member put under a name taken from the request")
    t = open(tst).read()
    need(COND.search(t) is None, "CustomerFieldsTest: no @Disabled / @EnabledIf... / @DisabledIf... in the simple or the fully-qualified form")
    t2 = re.sub(r"\b\d+L\b", "", t.replace("tag:tiffinbox.example,2026:", "tag:"))
    need(re.search(r"RANDOM_PORT|DEFINED_PORT|LocalServerPort|\bSocket\b|\b\d{4,5}\b", t2) is None, "CustomerFieldsTest names no port, no socket (the problem-type tag's year aside)")
    need(len(re.findall(r"^\s+@Test$", t, re.M)) == 5, "CustomerFieldsTest: five @Test methods")
    hs = []
    for d, _, fs in os.walk(os.path.join(after, "tiffinbox-web/src/main/java")):
        for f in fs:
            if f.endswith(".java"):
                hs += re.findall(r"@(?:Get|Post|Put|Patch|Delete|Request)Mapping[^\n]*\n\s*(?:@[^\n]*\n\s*)*[\w<>?, ]+\s+(\w+)\(", open(os.path.join(d, f)).read())
    need(hs.count("customerFields") == 1, "the new handler's name customerFields occurs once among %d mapped handlers" % len(hs))
    for rel in ("pom.xml", "tiffinbox-web/pom.xml", "tiffinbox-core/pom.xml", "tiffinbox-client/pom.xml",
                "tiffinbox-web/src/main/java/com/tiffinbox/web/OrderPages.java", "tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxApiVersioning.java",
                "tiffinbox-web/src/main/java/com/tiffinbox/web/IdempotencyKeyFilter.java", "tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxErrors.java",
                "tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxOpenApi.java", "tiffinbox-web/src/main/java/com/tiffinbox/web/CustomerReads.java",
                "tiffinbox-web/src/test/java/com/tiffinbox/web/ApiVersionTest.java", "tiffinbox-web/src/test/java/com/tiffinbox/web/TiffinBoxRestDocsTest.java",
                "tiffinbox-web/src/test/java/com/tiffinbox/web/OpenApiSpecTest.java", "tiffinbox-web/src/test/java/com/tiffinbox/web/OrderPagesTest.java",
                "tiffinbox-web/src/test/java/com/tiffinbox/web/TiffinBoxWebTest.java", "tiffinbox-web/src/test/java/com/tiffinbox/CustomerEntityRepositoryIT.java",
                "tiffinbox-web/src/test/java/com/tiffinbox/jdbc/CustomerAggregatesIT.java", "Dockerfile", "compose.yaml",
                "tiffinbox-web/src/main/resources/application.yaml", "tiffinbox-core/src/main/resources/db/migration/V6__tiffin_order.sql",
                "tiffinbox-core/src/main/java/com/tiffinbox/TiffinBoxProperties.java"):
        need(open(os.path.join(before, rel), "rb").read() == open(os.path.join(after, rel), "rb").read(), "%s byte-equal to before's" % rel)
    for y in (before, after):
        need("compression" not in open(os.path.join(y, "tiffinbox-web/src/main/resources/application.yaml")).read(), "%s's application.yaml holds no compression key" % os.path.basename(os.path.normpath(y)))
    readme = open(os.path.join(after, "README.md")).read()
    card = readme.split("## Course 9 · unit 14", 1)
    need(len(card) == 2, "c9-tiffinbox/README.md holds a Course 9 · unit 14 card")
    if len(card) == 2:
        c = " ".join(card[1].split("\n## ", 1)[0].split())
        need(re.search(r"\b57\b", c.replace("57 at unit 13", "")) is None, "the card gives 57 as unit 13's count only")
    need("Course 9's eleventh change to this folder (U14)" in readme, "the header note: Course 9's eleventh change to this folder (U14)")
    here = os.path.dirname(os.path.abspath(__file__))
    me = open(os.path.join(here, "chk14.py")).read().split("LEFT_OUT = [", 1)[1].split("]", 1)[1]
    need(not any(re.search(r"\bdef c_%s\(" % n, me) for n in LEFT_OUT), "chk14.py defines none of the left-out captures (%d names)" % len(LEFT_OUT))
    for f in ("walk.py", "seal9.py", "cdp.mjs", "cdp9.mjs", "loc9.py", "specwire9.py", "mirror", "src/probe/u12", "src/probe/u13", "src/probe/u10/Caller.java"):
        need(not os.path.exists(os.path.join(here, f)), "harness/%s absent" % f)
    rs = open(os.path.join(here, "..", "receipts.sh")).read()
    need(re.search(r"-pl tiffinbox-core(?! -am)", rs) is None, "R.391: no -pl tiffinbox-core form in receipts.sh")
    print("VALUES static=pass")


# ---- prose helpers ----------------------------------------------------------------------------------------------------------------------
BRIEF = os.path.join(os.environ.get("C9R", ""), "_briefs/UNIT-BRIEFS-S3-PAYLOADS.md")
GLOSS = "A sparse fieldset: only the fields asked for."


def unit14():
    t = open(BRIEF, encoding="utf-8").read()
    return t.split("## Unit 14", 1)[1].split("\n## ", 1)[0]


def hook():
    m = re.search(r'\*\*Hook \(\[S3 §8\]\):\*\* "([^"]+)"', unit14())
    print(m.group(1) if m else "FAIL no hook line")


def exq():
    m = re.search(r'"(Your turn: [^"]+)"', unit14())
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
    print("the brief's hooks and exercises: %d + %d (the gates paragraph excluded), interleaved md5 %s = S3B's" % (len(hs), len(es), h))


def gloss(readme):
    ls = lines(readme)
    need(sum(1 for l in ls if l.startswith("A sparse fieldset:")) == 1, "exactly one README line starts 'A sparse fieldset:'")
    need(GLOSS in ls, "the gloss line byte for byte")
    need(len(GLOSS.split()) <= 25, "the gloss %d words (<= 25)" % len(GLOSS.split()))
    for g in ("A cursor:", "A version carrier:", "A snippet:", "A contract:", "Swagger UI:", "A problem type:", "Code generation:"):
        need(not any(l.startswith(g) for l in ls), "no second gloss of an earlier unit's kind (%s)" % g)
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
    P = [("full", "a byte count one off", lambda t: re.sub(r"(full \| GET /api/v1/customers -> 200 application/json )(\d+)", lambda m: m.group(1) + str(int(m.group(2)) + 1), t, count=1)),
         ("full", "a Vary typed on the flag-off answer", lambda t: re.sub(r"(full \| GET /api/v1/customers -> .*Vary )none", r"\1accept-encoding", t, count=1)),
         ("fields", "a member order typed against the print", lambda t: re.sub(r"(fields=mealType,name -> .*members )\['name', 'mealType'\]", r"\1['mealType', 'name']", t, count=1)),
         ("refuse", "field-unknown typed 200", lambda t: t.replace("(?fields=nickname) -> 400", "(?fields=nickname) -> 200", 1)),
         ("refuse", "a Framework 400 with no type typed as the route's", lambda t: re.sub(r"(\(\?fields=%zz\) -> 400 \S+ \| )", r"\1type=tag:tiffinbox.example,2026:field-unknown · ", t, count=1)),
         ("refuse", "an unknown field answered (ignored) with a list", lambda t: re.sub(r"(\(\?fields=Name\) -> )400 application/problem\+json \| .*", r"\g<1>200 application/json | a list of 4 · members ['name']", t, count=1)),
         ("mjv", "the 500 typed 200", lambda t: t.replace("/mjv -> 500", "/mjv -> 200", 1)),
         ("mjv", "the exception text not the run's", lambda t: t.replace("use hints instead", "use views instead", 1)),
         ("floor", "the floor typed 4KB", lambda t: t.replace('min-response-size default "2KB"', 'min-response-size default "4KB"', 1)),
         ("floor", "mime-types 9", lambda t: t.replace("mime-types default: 8 entries", "mime-types default: 9 entries", 1)),
         ("floor", "HAL in the list", lambda t: t.replace("application/hal+json: no", "application/hal+json: yes", 1)),
         ("grown", "229 typed as %b's", lambda t: re.sub(r"(grown \| GET /customers -> 200 application/json )(\d+)( · file )(\d+)( B md5 \S+ · Content-Length \S+ · Content-Encoding gzip)", lambda m: m.group(1) + str(int(m.group(2)) + 16) + m.group(3) + m.group(4) + m.group(5), t, count=1)),
         ("grown", "Course 6's md5 one character off", lambda t: re.sub(r"(grown \| GET /customers -> 200 application/json \d+ · file \d+ B md5 )bc55", r"\1bc56", t, count=1)),
         ("under", "629 typed as compressed", lambda t: re.sub(r"(under \| GET /api/v1/customers\?fields=name -> .*Content-Encoding )none(.*)$", r"\1gzip\2", t, flags=re.M)),
         ("clients", "one factory's Accept-Encoding typed -", lambda t: re.sub(r'(Tomcat saw \(the access log, the three GETs\): GET /customers 200 \d+ )"[^"]*"', r'\1"-"', t, count=1)),
         ("clients", "a probe User-Agent (the probe's Gzip.java unmodified)", lambda t: re.sub(r'"Apache-HttpClient/5\.6\.5 [^"]*"', '"probe-HttpComponen"', t, count=1)),
         ("clients", "the compressed bytes handed back", lambda t: re.sub(r"bytes handed back 2403", "bytes handed back 229", t, count=1)),
         ("yaml", "the count typed 0", lambda t: re.sub(r"answers that differ: \d+ - .*", "answers that differ: 0 - none", t, count=1)),
         ("spec", "an operationId renumbered (customers -> customers_1)", lambda t: t.replace("old operations' ids before -> after: equal", "old operations' ids before -> after: differ", 1)),
         ("spec", "the spec touched without regeneration", lambda t: t.replace("(servers removed): equal", "(servers removed): differ", 1)),
         ("spec", "a date-line-only client file called moved", lambda t: re.sub(r"(lines added only \d+ · moved )0", r"\g<1>1", t, count=1)),
         ("moved", "a moved line", lambda t: re.sub(r"(after \| GET /customers/Ravi -> \S+)", r"\g<1>X", t, count=1)),
         ("moved", "no new entry typed", lambda t: t.replace("web jar: entries only after has: BOOT-INF/classes/com/tiffinbox/web/CustomerFields.class", "web jar: entries only after has: none", 1)),
         ("seven", "the seven's md5 one character off", lambda t: re.sub(r"(after: the seven )(\w)", lambda m: m.group(1) + ("0" if m.group(2) != "0" else "1"), t, count=1)),
         ("tests", "Skipped typed 1", lambda t: t.replace("class CustomerFieldsTest | tests 5 failures 0 errors 0 skipped 0", "class CustomerFieldsTest | tests 5 failures 0 errors 0 skipped 1", 1)),
         ("tests", "57 typed as current", lambda t: re.sub(r"(package \| tiffinbox-web \| tests )\d+", r"\g<1>57", t, count=1)),
         ("advisory", "the filed read one day older than the run", lambda t: re.sub(r"(· run date )2026-11-26", r"\g<1>2026-11-27", t, count=1)),
         ("change", "a whitelist one name short", lambda t: t.replace("FIELDS, in order): name,mealsPerDay,pricePerMeal,mealType", "FIELDS, in order): name,mealsPerDay,pricePerMeal", 1)),
         ("change", "JsonView in src/main", lambda t: t.replace("src/main grep JsonView: 0", "src/main grep JsonView: 1", 1)),
         ("change", "a compression key in application.yaml", lambda t: t.replace("compression keys: before 0 · after 0", "compression keys: before 0 · after 1", 1)),
         ("floor", "an access-log line the checker cannot parse", lambda t: re.sub(r"(  floor \| GET /customers) -> ", r"\1 =>", t, count=1))]
    n = 0
    for cap, what, mut in P:
        f = os.path.join(capdir, ".r-%s.new" % cap)
        if not os.path.exists(f):
            f = os.path.join(capdir, ".r-%s.out" % cap)
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
    except Exception as e:  # noqa - a FAIL line, exit 1, never a traceback
        fail("unparsable: %s: %s" % (e.__class__.__name__, str(e)[:160]))
    sys.exit(1 if FAILS else 0)
