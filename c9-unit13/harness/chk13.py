#!/usr/bin/env python3
"""Course 9 unit 13's checker (python3 -I -B harness/chk13.py MODE ...). Each capture's check reads the capture's own lines and checks
them against another witness of the same run (the SQL log against the ids, the decoded cursor against the request, the Surefire XML
against the reactor line, ...). Prints "ok ..." / "FAIL ..." lines and one "VALUES k=v ..." line; exit 1 on any FAIL. A line it cannot
parse is a FAIL line, never a traceback.

Modes: CAPTURE FILE (advisory before change table first next refuse pageable walk trap restart spec moved seven surface inert tests
exercise) · hashable CAPTURE FILE (the capture minus its run-variant lines, those starting "  ~") · static AFTER BEFORE · gloss README ·
hook · exq · gloss-line · values README VALS · plants (each planted fault made to FAIL first).
Left out of this unit (a name of U12's captures here is a static failure): see LEFT_OUT."""
import json, os, re, subprocess, sys

FAILS = []
VALS = {}
LEFT_OUT = ["cho" + "ose", "fo" + "ur", "requ" + "ired", "defa" + "ult", "new" + "est", "depre" + "cate", "ret" + "ire", "rep" + "lay",
            "rest" + "docs", "cli" + "ent", "ty" + "pe", "call" + "pg", "snip" + "pets", "ht" + "ml", "sea" + "led", "comp" + "are",
            "acc" + "ept", "dri" + "ven", "gene" + "rate", "cen" + "sus", "jack" + "son", "ca" + "ll", "pau" + "se", "mo" + "ck",
            "default" + "10", "cou" + "nts", "l" + "oc", "loca" + "tion", "per" + "op", "blan" + "ket", "sha" + "pe", "typ" + "es",
            "sch" + "eme", "wi" + "de"]
CAPS = ["advisory", "before", "change", "table", "first", "next", "refuse", "pageable", "walk", "trap", "restart", "spec", "moved",
        "seven", "surface", "inert", "tests", "exercise"]
TAG = "tag:tiffinbox.example,2026:"
P1 = [19, 20, 17, 18, 15]          # page one newest first, ids (measured by this unit's first capture before OrderPagesTest was written)
P2 = [16, 13, 14, 11, 12]          # page two through the cursor


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


def ids_of(s):
    return [int(x) for x in re.findall(r"-?\d+", s)]


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
            "jackson-databind": "3.1.8", "postgresql": "42.7.14", "h2": "2.5.250"}
    for a, v in want.items():
        m = [re.search(r"^  t3 tree \| %s (\S+)$" % re.escape(a), l) for l in ls]
        m = [x for x in m if x]
        need(bool(m) and m[0].group(1) == v, "the t3 tree's %s = %s" % (a, v))
    need(any(l.startswith("  osv (second witness only") for l in ls), "the OSV result printed as a second witness only")
    need(any(l == "  verdict: no pin affected; evidence may proceed" for l in ls), "the verdict line")


def c_before(ls):
    for p in ("/api/v1/orders", "/orders"):
        m = [l for l in ls if re.search(r"^  before \| GET %s -> (\d+) " % re.escape(p), l)]
        need(bool(m) and " -> 404 " in m[0], "before: GET %s answers 404" % p)
    m = grab(ls, r"^  before \| flyway (\[.*\])$", "before flyway")
    if m:
        need(m[0].group(1) == "['1', '2', '3', '4', '5']", "before: the Flyway history V1-V5 (/actuator/flyway, the harness's exposure flag)")
    m = grab(ls, r"^  before \| mappings (\d+) · with order in the path (\d+)", "mappings")
    if m:
        need(m[0].group(2) == "0", "before: 0 request mappings name an order list")
        VALS["before_mappings"] = m[0].group(1)
    m = grab(ls, r"^  before \| GET /kitchen -> 200 .*members \[(.*)\]", "kitchen")
    if m:
        need("ordersCooked" in m[0].group(1), "before: /kitchen's counters printed (the in-JVM counters, not the list)")


def c_change(ls):
    m = grab(ls, r"^  changed \(derived: [^)]*\): (.*)$", "changed list")
    if m:
        got = m[0].group(1).split(" · ")
        want = ["M tiffinbox-web/src/test/java/com/tiffinbox/CustomerEntityRepositoryIT.java",
                "M tiffinbox-web/src/test/java/com/tiffinbox/jdbc/CustomerAggregatesIT.java",
                "M tiffinbox-web/src/test/java/com/tiffinbox/web/TiffinBoxWebTest.java",
                "M tiffinbox-web/src/test/resources/openapi/tiffinbox.json",
                "A tiffinbox-core/src/main/java/com/tiffinbox/OrderEntity.java",
                "A tiffinbox-core/src/main/java/com/tiffinbox/OrderEntityRepository.java",
                "A tiffinbox-core/src/main/resources/db/migration/V6__tiffin_order.sql",
                "A tiffinbox-web/src/main/java/com/tiffinbox/web/OrderPages.java",
                "A tiffinbox-web/src/test/java/com/tiffinbox/web/OrderPagesTest.java"]
        rm = [x for x in got if x.startswith("M README")]
        need(sorted(x for x in got if not x.startswith("M README")) == sorted(want), "the changed anchor paths are the flag-2 set (+ README.md: %d)" % len(rm))
        VALS["changed"] = str(len(got))
    for k in ("offset(", "Pageable", "PageRequest"):
        m = grab(ls, r"^  src/main grep %s: (\d+) code lines" % re.escape(k), k)
        if m:
            need(m[0].group(1) == "0", "src/main holds no %s" % k)
    m = grab(ls, r"^  the web jar's spring-data-jpa: (\S+)", "spring-data-jpa")
    if m:
        need(m[0].group(1) == "spring-data-jpa-4.1.3.jar", "the effective Spring Data JPA is 4.1.3")
    m = grab(ls, r"^  handler orderPage: (\d+) occurrence", "handler")
    if m:
        need(m[0].group(1) == "1", "the new handler's name is unique among the mapped handlers")
    need(any(l.startswith("  TiffinBoxApp | @EntityScan(\"com.tiffinbox\")") for l in ls), "TiffinBoxApp's @EntityScan printed")
    need(any(l.startswith("  TiffinBoxApp | @EnableJpaRepositories(\"com.tiffinbox\")") for l in ls), "TiffinBoxApp's @EnableJpaRepositories printed")
    m = grab(ls, r"^  modules: (.*)$", "modules")
    if m:
        need(m[0].group(1) == "tiffinbox-core tiffinbox-web tiffinbox-client (3) -> tiffinbox-core tiffinbox-web tiffinbox-client (3)", "the parent's modules 3 -> 3")
    m = grab(ls, r"^  poms against 0248b1c: (.*)$", "poms")
    if m:
        need(m[0].group(1) == "empty", "git diff --stat 0248b1c -- '*pom.xml' empty")


def c_table(ls):
    for db in ("h2", "pg"):
        m = grab(ls, r"^  %s \| flyway (\[.*\])$" % db, db + " flyway")
        if m:
            need(m[0].group(1) == "['1', '2', '3', '4', '5', '6']", "%s: the Flyway history V1-V6" % db)
        m = grab(ls, r"^  %s \| rows (\d+) · placed_at minutes (\d+) · rows per minute (\[.*\])" % db, db + " rows")
        if m:
            need(m[0].group(1) == "20" and m[0].group(2) == "10" and m[0].group(3) == str([2] * 10), "%s: 20 rows, two per placed_at minute" % db)
    m = grab(ls, r"^  value \| the scratch copy's start: (\S+)", "value reserved")
    if m:
        need(m[0].group(1) == "org.h2.jdbc.JdbcSQLSyntaxErrorException", "a column named value stops V6 on H2 (JdbcSQLSyntaxErrorException)")
    m = grab(ls, r"^  the two histories: (\S+)", "histories")
    if m:
        need(m[0].group(1) == "equal", "the H2 and PostgreSQL histories are the same list")


def _page(ls, db, lab):
    m = [re.search(r"^  %s \| %s -> (\d+) (\S+) · keys (\[.*?\]) · ids (\[.*?\]) · next (\S+)" % (db, re.escape(lab)), l) for l in ls]
    m = [x for x in m if x]
    if not m:
        fail("unparsable: no %s line for %s" % (db, lab))
        return None
    return m[0]


def _sql(ls, db, lab):
    m = [re.search(r"^  %s \| %s SQL \| (.*)$" % (db, re.escape(lab)), l) for l in ls]
    m = [x.group(1) for x in m if x]
    if not m:
        fail("unparsable: no SQL line for %s %s" % (db, lab))
        return None
    return m[0]


def c_first(ls):
    for db in ("h2", "pg"):
        p = _page(ls, db, "page one newest")
        if not p:
            continue
        need(p.group(1) == "200" and p.group(2) == "application/json", "%s: page one 200 application/json" % db)
        need(p.group(3) == "['items', 'next']", "%s: the body's members items, next" % db)
        need(ids_of(p.group(4)) == P1, "%s: page one's ids %s" % (db, P1))
        need(p.group(5) == "present", "%s: next present" % db)
        s = _sql(ls, db, "page one newest")
        if s:
            mm = re.search(r"order by (\w+)\.placed_at desc,\1\.id(?! desc)\b", s)
            need(bool(mm), "%s: the id in the ORDER BY, ascending under placed_at desc" % db)
            need(" where " not in s, "%s: page one has no keyset WHERE" % db)
    VALS["p1"] = ",".join(map(str, P1))


def c_next(ls):
    for db in ("h2", "pg"):
        m = grab(ls, r"^  %s \| decoded once \| (\{.*\}) \. <signature masked> · length (\d+)" % db, db + " decoded")
        if m:
            try:
                d = json.loads(m[0].group(1))
                need(list(d) == ["s", "f", "k"] and d["s"] == "newest" and d["f"] is None, "%s: the payload {s, f, k}, s newest, f JSON null" % db)
                ks = {k[0]: k[1] for k in d["k"]}
                need(ks == {"id": "L", "placedAt": "I"}, "%s: the keyset keys id (L) and placedAt (I)" % db)
                need([k for k in d["k"] if k[0] == "id"][0][2] == "15", "%s: the cursor's id is page one's last (15)" % db)
            except Exception as e:  # noqa
                fail("unparsable: the decoded payload (%s)" % e.__class__.__name__)
            VALS["cursor_len_" + db] = m[0].group(2)
        p = _page(ls, db, "page two")
        if p:
            need(p.group(1) == "200" and ids_of(p.group(4)) == P2, "%s: page two's ids %s" % (db, P2))
        s = _sql(ls, db, "page two")
        if s:
            mm = re.search(r"where (\w+)\.placed_at<\? or \1\.placed_at=\? and \1\.id>\? order by \1\.placed_at desc,\1\.id(?! desc)\b", s)
            need(bool(mm), "%s: the keyset WHERE holds the id (id>?) and the ORDER BY the id ascending" % db)
    if "cursor_len_h2" in VALS and "cursor_len_pg" in VALS:
        need(VALS["cursor_len_h2"] == VALS["cursor_len_pg"], "the cursor's length equal on both databases")
    VALS["p2"] = ",".join(map(str, P2))


REFUSALS = [("tampered", "cursor-invalid", None), ("notacursor", "cursor-invalid", None), ("truncated", "cursor-invalid", None),
            ("reused sort=oldest", "cursor-mismatch", "sort"), ("reused mealType=VEG", "cursor-mismatch", "mealType"),
            ("reused mealType=null (the string)", "cursor-mismatch", "mealType"), ("sort=nosuch", "sort-unknown", "[newest, oldest, amount, customer]"),
            ("colour=red", "parameter-unknown", "[colour]"), ("customer=Ravi", "parameter-unknown", "[customer]"),
            ("mealType=PIZZA", "filter-unknown", "[VEG, NON_VEG, VEGAN]"), ("mealType=null (no cursor)", "filter-unknown", "[VEG, NON_VEG, VEGAN]"),
            ("size=0", "size-invalid", "1 to 50"), ("size=-1", "size-invalid", "1 to 50"), ("size=51", "size-invalid", "1 to 50")]


def c_refuse(ls):
    per = {}
    for db in ("h2", "pg"):
        for lab, typ, names in REFUSALS:
            m = [re.search(r"^  %s \| %s -> (\d+) (\S+) \| (\{.*\})$" % (db, re.escape(lab)), l) for l in ls]
            m = [x for x in m if x]
            if not m:
                fail("unparsable: no %s line for %s" % (db, lab))
                continue
            try:
                b = json.loads(m[0].group(3))
            except Exception:
                fail("unparsable: %s %s's body" % (db, lab))
                continue
            good = m[0].group(1) == "400" and m[0].group(2) == "application/problem+json" and b.get("type") == TAG + typ and b.get("status") == 400 \
                and b.get("instance") == "/api/v1/orders" and (names is None or names in b.get("detail", ""))
            need(good, "%s: %s -> 400 problem+json %s%s" % (db, lab, typ, "" if names is None else ", the detail names " + names))
            per[(db, lab)] = b
        m = [re.search(r"^  %s \| size=abc -> (\d+) (\S+) \| (\{.*\})$" % db, l) for l in ls]
        m = [x for x in m if x]
        if need(bool(m), "%s: size=abc printed" % db):
            b = json.loads(m[0].group(3))
            need(m[0].group(1) == "400" and "type" not in b, "%s: size=abc -> 400, Framework's own conversion problem (no type member)" % db)
        m = [re.search(r"^  %s \| size=50 -> (\d+) .* items (\d+)" % db, l) for l in ls]
        m = [x for x in m if x]
        need(bool(m) and m[0].group(1) == "200" and m[0].group(2) == "20", "%s: size=50 -> 200, all 20 rows" % db)
    for db in ("h2", "pg"):
        a, b = per.get((db, "reused sort=oldest")), per.get((db, "reused mealType=VEG"))
        if a and b:
            need(a["detail"] != b["detail"], "%s: the two reuse refusals' details differ (each names its parameter)" % db)
    for lab, _, _ in REFUSALS:
        a, b = per.get(("h2", lab)), per.get(("pg", lab))
        if a and b:
            need(a == b, "H2 and PostgreSQL answer %s with the same body" % lab)
    VALS["refusals"] = str(len(REFUSALS))
    VALS["types"] = "cursor-invalid,cursor-mismatch,sort-unknown,parameter-unknown,filter-unknown,size-invalid"


def c_pageable(ls):
    for db in ("h2", "pg"):
        runs = [re.search(r"^  ~ %s \| run (\d) \| ties (\[.*?\])$" % db, l) for l in ls]
        runs = [x for x in runs if x]
        need(len(runs) >= 3, "%s: at least 3 fresh %s (%d)" % (db, "JVMs" if db == "h2" else "databases", len(runs)))
        orders = {x.group(2) for x in runs}
        for x in runs:
            need(sorted(ids_of(x.group(2))) == [3, 7, 11, 15, 19], "%s run %s: the five tied rows (amount 300) are 3, 7, 11, 15, 19" % (db, x.group(1)))
        m = grab(ls, r"^  ~ %s \| distinct orders (\d+) over (\d+)" % db, db + " distinct")
        if m:
            need(int(m[0].group(1)) == len(orders) and int(m[0].group(2)) == len(runs), "%s: the distinct-orders count is the id lists' (%d over %d)" % (db, len(orders), len(runs)))
            VALS["fresh_" + db] = str(len(runs))   # the distinct-orders count varies per run: said with its run, never in the values block
        s = [re.search(r"^  %s \| SQL \| (.*)$" % db, l) for l in ls]
        s = [x.group(1) for x in s if x]
        if need(bool(s), "%s: the Pageable SQL printed" % db):
            need(re.search(r"order by (\w+)\.amount desc", s[0]) is not None and ".id" not in s[0].split("order by")[1], "%s: no id in the Pageable route's ORDER BY" % db)
        m = grab(ls, r"^  %s \| sort=nosuch -> (\d+) \S+ \| (.*)$" % db, db + " nosuch")
        if m:
            need(m[0].group(1) == "500", "%s: the harness's Pageable route answers an unknown sort 500" % db)
        m = grab(ls, r"^  %s \| the JVM's log: (.*)$" % db, db + " exception")
        if m:
            need("PropertyReferenceException" in m[0].group(1) and "nosuch" in m[0].group(1), "%s: the log names PropertyReferenceException for nosuch" % db)


def c_walk(ls):
    want = {("newest", "offset"): (2, 0, 0), ("newest", "cursor"): (0, 0, 0), ("oldest", "offset"): (0, 0, 2), ("oldest", "cursor"): (0, 0, 2)}
    tab = {}
    for db in ("H2", "PG"):
        for (s, mo), w in want.items():
            m = [re.search(r"^  %s sort=%s +mode=%s +rows-before=(\d+) pages=\d+ read=\d+ duplicates=(\d+) .* skips=(\d+) .* new-rows-seen=(\d+)" % (db, s, mo), l) for l in ls]
            m = [x for x in m if x]
            if not m:
                fail("unparsable: no %s walk line for %s %s" % (db, s, mo))
                continue
            got = (int(m[0].group(2)), int(m[0].group(3)), int(m[0].group(4)))
            need(m[0].group(1) == "20" and got == w, "%s %s %s: rows at the start 20, duplicates/skips/new seen %s" % (db, s, mo, "/".join(map(str, w))))
            tab[(db, s, mo)] = got
    if len(tab) == 8:
        need(all(tab[("H2",) + k] == tab[("PG",) + k] for k in want), "the four walks identical on both databases")
        VALS["walk"] = " ".join("%s-%s=%s" % (s, mo, "/".join(map(str, tab[("H2", s, mo)]))) for s, mo in want)
    m = [l for l in ls if re.search(r"^  H2 \| offset newest page two begins with page one's last two: yes", l)]
    need(bool(m), "the failure receipt: the offset walk's page two begins with page one's last two ids")


def c_trap(ls):
    for db in ("h2", "pg"):
        def sq(step):
            m = [re.search(r"^  %s \| %s \| (.*)$" % (db, re.escape(step)), l) for l in ls]
            m = [x.group(1) for x in m if x]
            if not m:
                fail("unparsable: no %s trap line for %s" % (db, step))
                return ""
            return m[0]
        b0, b1 = sq("B offset"), sq("B keyset")
        a0, a1 = sq("A keyset"), sq("A keyset again")
        c0, c1, c2 = sq("C keyset"), sq("C offset"), sq("C keyset again")
        ap = sq("Aprime keyset")
        keyset = lambda s: re.search(r"order by \w+\.amount,\w+\.id\b", s) is not None
        need(re.search(r"order by \w+\.amount\b(?!,)", b0) is not None and not keyset(b0), "%s: B's offset() step: order by amount, no id (offset() from the start writes no OFFSET clause)" % db)
        need(not keyset(b1) and re.search(r"order by \w+\.amount\b(?!,)", b1) is not None, "%s: B's keyset() after offset() runs order by amount, no id (the trap)" % db)
        need(keyset(a0) and keyset(a1), "%s: the control A, keyset() twice: order by amount,id both times" % db)
        need(keyset(c0) and not keyset(c2), "%s: C keyset() first has the id; after offset(), keyset() again has none" % db)
        need(keyset(ap), "%s: A-prime, B's method keyset() only in its own JVM: order by amount,id" % db)
    VALS["trap"] = "reproduced_both"


def c_restart(ls):
    for db in ("h2", "pg"):
        m = grab(ls, r"^  %s \| random-key JVM 2 \| the cursor of random-key JVM 1 -> (\d+) (\S+) \| type (\S+)" % db, db + " restart random")
        if m:
            need(m[0].group(1) == "400" and m[0].group(3) == TAG + "cursor-invalid", "%s: a cursor from before a restart (random key) -> 400 cursor-invalid" % db)
        m = grab(ls, r"^  %s \| same-key JVM 2 \| the cursor of same-key JVM 1 -> (\d+) \S+ \| ids (\[.*?\])" % db, db + " restart key")
        if m:
            need(m[0].group(1) == "200" and ids_of(m[0].group(2)) == P2, "%s: the same cursor under the same explicit key -> 200, page two's ids" % db)
        need(any(re.search(r"^  %s \| cursor key: defaulted .* · set .*" % db, l) for l in ls), "%s: the JVMs say defaulted / set (the key never printed)" % db)


def c_spec(ls):
    m = grab(ls, r"^  the committed file against the served document \(servers removed\): (\S+)", "served")
    if m:
        need(m[0].group(1) == "equal", "the committed spec = the served document with servers removed")
    m = grab(ls, r"^  before: OPERATIONS (\d+) PATHS (\d+) · after: OPERATIONS (\d+) PATHS (\d+)", "ops")
    if m:
        a, b, c, d = map(int, m[0].groups())
        need(c == a + 1 and d == b + 1, "operations and paths each grew by one (%d/%d -> %d/%d)" % (a, b, c, d))
        VALS["ops"] = "%d->%d" % (a, c)
        VALS["paths"] = "%d->%d" % (b, d)
    m = grab(ls, r"^  the old operations' ids before -> after: (\S+)", "old ids")
    if m:
        need(m[0].group(1) == "equal", "the old operations' operationIds equal before and after (no renumbering)")
    m = grab(ls, r"^  the diff against 0248b1c: (\d+) lines added, (\d+) removed", "diff")
    if m:
        need(m[0].group(2) == "0", "the committed spec's diff removes no line")
        VALS["spec_added"] = m[0].group(1)
    m = grab(ls, r"^  spec vs wire \| 200 (\S+) (\S+) · wire 200 (\S+) members (\[.*?\])", "spec vs wire 200")
    if m:
        need(m[0].group(1) == m[0].group(3) == "application/json", "the new route's 200: the spec's media type = the wire's (application/json)")
        need(m[0].group(4) == "['items', 'next']", "the wire's members = the schema's properties (items, next)")
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
    need(any(re.search(r"^  the client: ApiApi\.java orderPage: [1-9]", l) for l in ls), "the generated ApiApi holds orderPage")
    m = grab(ls, r"^  OpenApiSpecTest on the regenerated file: tests (\d+) failures (\d+) errors (\d+)", "OpenApiSpecTest")
    if m:
        need(m[0].groups() == ("1", "0", "0"), "OpenApiSpecTest passes on the regenerated file")
    m = grab(ls, r"^  committed md5 before (\S+) · after (\S+)", "md5s")
    if m:
        need(m[0].group(1) == "e715f47c04a2268324d6313d28f26e9a", "the BEFORE md5 is e715f47c")
        VALS["spec_md5"] = m[0].group(2)[:8]


def c_moved(ls):
    rows = {}
    for l in ls:
        m = re.search(r"^  (before|after) \| (.*?) -> (.*)$", l)
        if m:
            rows.setdefault(m.group(2), {})[m.group(1)] = m.group(3)
    need(len(rows) >= 19, "the moved list: %d requests on both trees" % len(rows))
    mv = [k for k, v in rows.items() if v.get("before") != v.get("after") and not k.startswith("GET /api/v1/orders")]
    named = {"GET /v3/api-docs.yaml"}   # the document's YAML: it lists the added path (named under S9.37, the spec capture's diff)
    need(set(mv) <= named, "moved lines outside the added route and the document's YAML: %s" % (", ".join(sorted(set(mv) - named)) or "0"))
    need("GET /v3/api-docs.yaml" in mv, "the document's YAML moved by the added path (named, S9.37)")
    nr = rows.get("GET /api/v1/orders", {})
    need(nr.get("before", "").startswith("404") and nr.get("after", "").startswith("200"), "the added route: 404 -> 200 (named, not a move)")
    VALS["moved"] = str(len(set(mv) - named))
    VALS["named"] = str(len(mv))
    m = grab(ls, r"^  web jar: entries only after has: (.*)$", "web jar")
    if m:
        need(m[0].group(1) == "BOOT-INF/classes/com/tiffinbox/web/OrderPages$OrderPage.class,BOOT-INF/classes/com/tiffinbox/web/OrderPages$OrderView.class,BOOT-INF/classes/com/tiffinbox/web/OrderPages.class", "the web jar gained OrderPages and its two records")
    m = grab(ls, r"^  core jar: entries only after has: (.*)$", "core jar")
    if m:
        need(m[0].group(1) == "com/tiffinbox/OrderEntity.class,com/tiffinbox/OrderEntityRepository.class,db/migration/V6__tiffin_order.sql", "the core jar gained OrderEntity, OrderEntityRepository, V6")
    for j in ("web", "core"):
        m = grab(ls, r"^  %s jar: shared entries whose CRC moved: (.*)$" % j, j + " crc")
        if m:
            allowed = {"web": "BOOT-INF/lib/tiffinbox-core-1.0.0.jar", "core": "none"}[j]
            need(m[0].group(1) == allowed, "%s jar: shared entries whose CRC moved = %s" % (j, allowed))
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
    m = grab(ls, r"^  ~ plant \(21024, the S9\.14 slot\): the old surface (\S+)", "plant")
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
    for lab in ("package", "twin", "webonly"):
        d = mod(lab)
        need("web" in d and d["web"][1:] == (0, 0, 0), "%s: tiffinbox-web green, 0 skipped (%s)" % (lab, d.get("web", "?")))
        if lab != "webonly":
            need(d.get("client") == (1, 0, 0, 0), "%s: tiffinbox-client 1" % lab)
        if lab == "package" and "web" in d:
            VALS["web_tests"] = str(d["web"][0])
    if "web_tests" in VALS:
        need(all(mod(l).get("web", (0,))[0] == int(VALS["web_tests"]) for l in ("twin", "webonly")), "the twin and the web-only form print the same web count")
    for cls, n in (("OrderPagesTest", 5), ("ApiVersionTest", 2), ("TiffinBoxRestDocsTest", 1), ("OpenApiSpecTest", 1)):
        m = grab(ls, r"^  package \| class %s \| tests (\d+) failures (\d+) errors (\d+) skipped (\d+)" % cls, cls)
        if m:
            need(tuple(map(int, m[0].groups())) == (n, 0, 0, 0), "%s: %d run, 0 failed, 0 skipped" % (cls, n))
    m = grab(ls, r"^  slice TiffinBoxWebTest: before (\d+) · after (\d+)", "slice")
    if m:
        need(m[0].group(1) == m[0].group(2), "TiffinBoxWebTest's count equal before and after (the mock in place)")
    m = grab(ls, r"^  web tests before \(unit 12's values\): (\d+) · new @Test lines (\d+)", "before count")
    if m and "web_tests" in VALS:
        need(int(m[0].group(1)) + int(m[0].group(2)) == int(VALS["web_tests"]), "web %s + %s = %s" % (m[0].group(1), m[0].group(2), VALS["web_tests"]))
        VALS["web_before"] = m[0].group(1)
        VALS["k"] = m[0].group(2)
    m = grab(ls, r"^  verify exit (\d+) · ITs tests (\d+) failures (\d+) errors (\d+) · classes (\d+)", "verify")
    if m:
        need(m[0].groups() == ("0", "14", "0", "0", "5"), "verify: exit 0, 14 ITs green in 5 classes (both Flyway ITs on V1-V6)")
        VALS["its"] = m[0].group(2)
    m = grab(ls, r"^  IT bindings: (\d+) lines · not 127\.0\.0\.1: (\d+)", "bindings")
    if m:
        need(m[0].group(1) == "5" and m[0].group(2) == "0", "five IT BINDINGS lines, every one on 127.0.0.1")
    m = grab(ls, r"^  need \| without the two IT edits[^:]*: exit (\d+) · (.*)$", "need its")
    if m:
        need(m[0].group(1) != "0" and "CustomerEntityRepositoryIT" in m[0].group(2) and "CustomerAggregatesIT" in m[0].group(2), "the measured need: both Flyway ITs red without their V6 line")
    m = grab(ls, r"^  need \| without the slice mock: exit (\d+) · TiffinBoxWebTest tests (\d+) errors (\d+)", "need mock")
    if m:
        need(m[0].group(1) != "0" and int(m[0].group(3)) > 0, "the measured need: the slice red without the OrderEntityRepository mock (%s errors)" % m[0].group(3))
        VALS["slice_errors"] = m[0].group(3)
    m = grab(ls, r"^  downloads across the builds: (\d+)", "downloads")
    if m:
        need(m[0].group(1) == "0", "Downloading from: 0 in every log")
    m = grab(ls, r"^  test files moved before -> after: (.*?) · new: ", "moved tests")
    if m:
        need(m[0].group(1) == "CustomerEntityRepositoryIT.java,CustomerAggregatesIT.java,TiffinBoxWebTest.java,tiffinbox.json", "the existing test files moved: exactly the two ITs, the slice and the spec")


def c_exercise(ls):
    for sh in ("bash", "zsh"):
        m = grab(ls, r"^  == broken, %s$" % sh, "broken " + sh)
        b = [l for l in ls if l.startswith("  broken %s | check exit " % sh)]
        need(bool(b) and not b[0].endswith("check exit 0"), "broken (%s): check.sh fails" % sh)
        s = [l for l in ls if l.startswith("  solved %s | check exit " % sh)]
        need(bool(s) and s[0].endswith("check exit 0"), "solved (%s): check.sh passes" % sh)
    for v, doc in (("broken", "README"), ("solved", "SOLUTION")):
        for sh in ("bash", "zsh"):
            got = [l.split(" | ", 1)[1] for l in ls if l.startswith("  %s %s | " % (v, sh)) and not l.startswith("  %s %s | check exit" % (v, sh))]
            want = [l[len("  %s: " % doc):] for l in ls if l.startswith("  %s: " % doc)]
            need(got == want and got, "%s (%s): the run printed exactly exercise/%s.md's What it prints block (%d lines)" % (v, sh, doc, len(want)))
    m = grab(ls, r"^  broken bash \| sort=nosuch -> (\d+) (\S+)", "broken answer")
    if m:
        VALS["ex_broken"] = m[0].group(1)
    m = grab(ls, r"^  solved bash \| sort=nosuch -> (\d+) (\S+)", "solved answer")
    if m:
        need(m[0].group(1) == "400" and m[0].group(2) == "application/problem+json", "solved: sort=nosuch -> 400 problem+json")


# ---- the hashable form --------------------------------------------------------------------------------------------------------------
def hashable(name, f):
    for l in lines(f):
        if l.startswith("  ~"):
            continue
        if name == "tests" and re.search(r"Tests run:|Time elapsed", l):
            continue
        print(l)


# ---- static ---------------------------------------------------------------------------------------------------------------------------
def static(after, before):
    src = os.path.join(after, "tiffinbox-web/src/main/java/com/tiffinbox/web/OrderPages.java")
    rep = os.path.join(after, "tiffinbox-core/src/main/java/com/tiffinbox/OrderEntityRepository.java")
    mig = os.path.join(after, "tiffinbox-core/src/main/resources/db/migration/V6__tiffin_order.sql")
    tst = os.path.join(after, "tiffinbox-web/src/test/java/com/tiffinbox/web/OrderPagesTest.java")
    s = open(src).read()
    need(re.search(r"^final class OrderPages\b", s, re.M) is not None, "OrderPages is final")
    need('@GetMapping("/api/v1/orders")' in s, "OrderPages maps the literal /api/v1/orders")
    code = re.sub(r"/\*.*?\*/|//[^\n]*", "", s, flags=re.S)
    for k in ("offset(", "Pageable", "PageRequest", "Probe", "PostMapping", "\"value\""):
        need(k not in code, "OrderPages' code holds no %s" % k)
    r = open(rep).read()
    rc = re.sub(r"/\*.*?\*/|//[^\n]*", "", r, flags=re.S)
    need("ScrollPosition" in rc and "Pageable" not in rc and "JpaRepository" not in rc, "OrderEntityRepository: ScrollPosition, no Pageable, no JpaRepository")
    m = open(mig).read()
    need(re.search(r"^\s+amount\s", m, re.M) is not None and re.search(r"\bvalue\b\s+INT", m, re.I) is None, "V6 has amount, no value column")
    need("PROBE" not in m.upper().replace("PROBE'S", "") or "THE PROBE'S COPY" not in m, "V6 is not the probe's copy")
    t = open(tst).read()
    cond = re.compile(r"@(?:org\.junit\.jupiter\.api\.(?:condition\.)?)?(?:Disabled|EnabledIf\w*|DisabledIf\w*|EnabledOn\w*|DisabledOn\w*|EnabledFor\w*|DisabledFor\w*)\b")
    need(cond.search(t) is None, "OrderPagesTest: no @Disabled / @EnabledIf... / @DisabledIf... in the simple or the fully-qualified form")
    t2 = re.sub(r"\b\d+L\b", "", t.replace("tag:tiffinbox.example,2026:", "tag:"))
    need(re.search(r"RANDOM_PORT|DEFINED_PORT|LocalServerPort|\bSocket\b|\b\d{4,5}\b", t2) is None, "OrderPagesTest names no port, no socket (the problem-type tag's year aside)")
    need(len(re.findall(r"^\s+@Test$", t, re.M)) == 5, "OrderPagesTest: five @Test methods")
    # the handler's name, once among the mapped handlers under src/main
    hs = []
    for d, _, fs in os.walk(os.path.join(after, "tiffinbox-web/src/main/java")):
        for f in fs:
            if f.endswith(".java"):
                hs += re.findall(r"@(?:Get|Post|Put|Patch|Delete|Request)Mapping[^\n]*\n\s*(?:@[^\n]*\n\s*)*[\w<>?, ]+\s+(\w+)\(", open(os.path.join(d, f)).read())
    need(hs.count("orderPage") == 1, "the new handler's name orderPage occurs once among %d mapped handlers" % len(hs))
    # the four edits, each exactly its lines
    def dd(rel):
        out = subprocess.run(["diff", os.path.join(before, rel), os.path.join(after, rel)], capture_output=True, text=True).stdout
        return [l for l in out.splitlines() if l[:1] in "<>"]
    w = dd("tiffinbox-web/src/test/java/com/tiffinbox/web/TiffinBoxWebTest.java")
    need(len(w) == 2 and all(l.startswith(">") for l in w) and sum("@MockitoBean com.tiffinbox.OrderEntityRepository" in l for l in w) == 1, "the slice test: one @MockitoBean line and its comment, additions only")
    for rel, el in (("tiffinbox-web/src/test/java/com/tiffinbox/CustomerEntityRepositoryIT.java", '"6 tiffin order true"'),
                    ("tiffinbox-web/src/test/java/com/tiffinbox/jdbc/CustomerAggregatesIT.java", '"6 true"')):
        w = dd(rel)
        need(len(w) == 3 and sum(l.startswith("<") for l in w) == 1 and el in w[-1] and "Course 9, unit 13" in w[1], "%s: one comment line and one appended list element" % rel.split("/")[-1])
    for rel in ("pom.xml", "tiffinbox-web/pom.xml", "tiffinbox-core/pom.xml", "tiffinbox-client/pom.xml",
                "tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxApiVersioning.java", "tiffinbox-web/src/main/java/com/tiffinbox/web/IdempotencyKeyFilter.java",
                "tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxErrors.java", "tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxOpenApi.java",
                "tiffinbox-web/src/test/java/com/tiffinbox/web/ApiVersionTest.java", "tiffinbox-web/src/test/java/com/tiffinbox/web/TiffinBoxRestDocsTest.java",
                "tiffinbox-web/src/test/java/com/tiffinbox/web/OpenApiSpecTest.java", "Dockerfile", "compose.yaml",
                "tiffinbox-web/src/main/resources/application.yaml", "tiffinbox-core/src/main/java/com/tiffinbox/TiffinBoxProperties.java"):
        need(open(os.path.join(before, rel), "rb").read() == open(os.path.join(after, rel), "rb").read(), "%s byte-equal to before's" % rel)
    readme = open(os.path.join(after, "README.md")).read()
    card = readme.split("## Course 9 · unit 13", 1)
    need(len(card) == 2, "c9-tiffinbox/README.md holds a Course 9 · unit 13 card")
    if len(card) == 2:
        c = " ".join(card[1].split("\n## ", 1)[0].split())
        need(re.search(r"\b52\b(?! at unit 12)", c.replace("52 at unit 12", "")) is None, "the card gives 52 as unit 12's count only")
    need("Course 9's tenth change to this folder (U13)" in readme, "the header note: Course 9's tenth change to this folder (U13)")
    here = os.path.dirname(os.path.abspath(__file__))
    me = open(os.path.join(here, "chk13.py")).read().split("LEFT_OUT = [", 1)[1].split("]", 1)[1]
    for n in LEFT_OUT:
        need(re.search(r"\bdef c_%s\b" % n, me) is None, "no subcommand %s" % n) if False else None
    need(not any(re.search(r"\bdef c_%s\(" % n, me) for n in LEFT_OUT), "chk13.py defines none of U12's left-out captures (%d names)" % len(LEFT_OUT))
    for f in ("seal9.py", "cdp.mjs", "cdp9.mjs", "loc9.py", "specwire9.py", "mirror", "src/probe/u12", "src/probe/u10/Caller.java"):
        need(not os.path.exists(os.path.join(here, f)), "harness/%s absent" % f)
    print("VALUES static=pass")


# ---- prose helpers ----------------------------------------------------------------------------------------------------------------------
BRIEF = os.path.join(os.environ.get("C9R", ""), "_briefs/UNIT-BRIEFS-S3-PAYLOADS.md")
GLOSS = "A cursor: where the next page starts, signed."


def unit13():
    t = open(BRIEF, encoding="utf-8").read()
    return t.split("## Unit 13", 1)[1].split("\n## ", 1)[0]


def hook():
    m = re.search(r'\*\*Hook \(\[S3 §7\]\):\*\* "([^"]+)"', unit13())
    print(m.group(1) if m else "FAIL no hook line")


def exq():
    m = re.search(r'"(Your turn: [^"]+)"', unit13())
    print(m.group(1) if m else "FAIL no exercise line")


def gloss(readme):
    ls = lines(readme)
    need(sum(1 for l in ls if l.startswith("A cursor:")) == 1, "exactly one README line starts 'A cursor:'")
    need(GLOSS in ls, "the gloss line byte for byte")
    need(len(GLOSS.split()) <= 25, "the gloss %d words (<= 25)" % len(GLOSS.split()))
    for g in ("A version carrier:", "A snippet:", "A contract:", "Swagger UI:", "A problem type:", "Code generation:"):
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
    P = [("first", "an id list one off", lambda t: t.replace("ids [19, 20, 17, 18, 15]", "ids [19, 20, 17, 18, 16]", 1)),
         ("first", "the id typed descending in the ORDER BY", lambda t: re.sub(r"(placed_at desc,\w+\.id)", r"\1 desc", t, count=1)),
         ("next", "the keyset WHERE without the id", lambda t: re.sub(r" and (\w+)\.id>\?", "", t, count=1)),
         ("next", "the filter as the string null", lambda t: t.replace('"f":null', '"f":"null"', 1)),
         ("refuse", "parameter-unknown typed 200", lambda t: t.replace("colour=red -> 400", "colour=red -> 200", 1)),
         ("refuse", "the two reuse bodies byte-identical", lambda t: re.sub(r"(mealType=VEG -> 400 \S+ \| ).*", lambda m: m.group(1) + [l for l in t.splitlines() if "reused sort=oldest ->" in l][0].split(" | ", 2)[2], t, count=1)),
         ("refuse", "mealType=null typed accepted", lambda t: t.replace("(the string) -> 400", "(the string) -> 200", 1)),
         ("refuse", "a tampered signature accepted", lambda t: t.replace("tampered -> 400", "tampered -> 200", 1)),
         ("pageable", "one order typed for H2 (the distinct count 1)", lambda t: re.sub(r"(~ h2 \| distinct orders )\d+", r"\g<1>1", t, count=1)),
         ("pageable", "an id in the Pageable ORDER BY", lambda t: re.sub(r"(h2 \| SQL \| .*?amount desc)", r"\1,oe1_0.id", t, count=1)),
         ("walk", "a duplicate count one off", lambda t: t.replace("mode=offset rows-before=20 pages=5 read=22 duplicates=2", "mode=offset rows-before=20 pages=5 read=22 duplicates=1", 1)),
         ("walk", "the new rows claimed seen on the newest-first cursor", lambda t: re.sub(r"(H2 sort=newest mode=cursor .*new-rows-seen=)0", r"\g<1>2", t, count=1)),
         ("trap", "keyset-again typed as keyset SQL", lambda t: re.sub(r"(h2 \| B keyset \| .*order by (\w+)\.amount)", r"\1,\2.id", t, count=1)),
         ("restart", "a different explicit key typed accepted", lambda t: t.replace("random-key JVM 1 -> 400", "random-key JVM 1 -> 200", 1)),
         ("spec", "an operationId renumbered", lambda t: t.replace("old operations' ids before -> after: equal", "old operations' ids before -> after: differ", 1)),
         ("spec", "the spec touched without regeneration", lambda t: t.replace("(servers removed): equal", "(servers removed): differ", 1)),
         ("moved", "a moved line", lambda t: re.sub(r"(after \| GET /customers/Ravi -> \S+)", r"\g<1>X", t, count=1)),
         ("seven", "the seven's md5 one character off", lambda t: re.sub(r"(after: the seven )(\w)", lambda m: m.group(1) + ("0" if m.group(2) != "0" else "1"), t, count=1)),
         ("tests", "Skipped typed 1", lambda t: t.replace("class OrderPagesTest | tests 5 failures 0 errors 0 skipped 0", "class OrderPagesTest | tests 5 failures 0 errors 0 skipped 1", 1)),
         ("tests", "a Flyway IT left on V1-V5 (verify red)", lambda t: re.sub(r"verify exit 0 · ITs tests 14 failures 0", "verify exit 1 · ITs tests 14 failures 1", t, count=1)),
         ("advisory", "the filed read one day older than the run", lambda t: re.sub(r"(· run date )2026-11-26", r"\g<1>2026-11-27", t, count=1)),
         ("table", "a value column on H2 accepted", lambda t: re.sub(r"(value \| the scratch copy's start: )\S+", r"\1Started", t, count=1)),
         ("change", "a pom touched", lambda t: t.replace("poms against 0248b1c: empty", "poms against 0248b1c: 1 file changed", 1)),
         ("change", "offset( in src/main", lambda t: t.replace("src/main grep offset(: 0", "src/main grep offset(: 1", 1)),
         ("first", "an SQL line the checker cannot parse", lambda t: re.sub(r"(h2 \| page one newest) SQL \|", r"\1 SQL-x |", t, count=1))]
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
        elif a[0] == "values":
            values(a[1], a[2])
        elif a[0] == "plants":
            plants(a[1])
        else:
            fail("unknown mode " + a[0])
    except Exception as e:  # noqa - a FAIL line, exit 1, never a traceback
        fail("unparsable: %s: %s" % (e.__class__.__name__, str(e)[:160]))
    sys.exit(1 if FAILS else 0)
