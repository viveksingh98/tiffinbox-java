"""Unit 22's checks (python3 -I -B harness/chk22.py NAME ARGS...). Each capture's numbers are asserted against a second witness of the
same run - never a typed figure (S8.78): Java's answers (TiffinBox's routes under "dev", the start's re-index line, the client's own
request lines by its trace logger, the IT's lines, the harness's PROBE lines, the exercise's program) against the store's own answers
(Elasticsearch's REST API by curl: _search, _count, _mapping, _settings, _cat/indices, _doc; PostgreSQL's count(*) by psql); Docker's
own records (the IT containers' Ports, the volume count); Surefire's XML against Maven's Results lines; the seven's md5 against
Course 7's. Every hit COUNT is re-derived from the ids list beside it, every id's meal type is read off after/'s V4__dish.sql, and every
"rows N / documents M" pair is read off psql's and _count's answers of the same run (S8.95). Prints ok/FAIL lines and one VALUES line;
exits 1 on any FAIL.
  static AFTER BEFORE   the change itself, read off the files, and the harness's own rules (the family slices' md5s)
  r250 AFTER BEFORE     the sentences the change made false or incomplete: rewritten or noted beside them, each listed
  javadoc AFTER BEFORE  the Javadoc and comment lines the change added, through s822's families (the double family test)
  wib CAPTURE FILE      the lines the exercise's block printed for FILE (bash's), for receipts.sh to compare with "What it prints"
  same NRT STALE        stale's lines are nrt's: the template's save 0 and the repository's save 1, with the same request lines
  numbers README CAPTURES...   S8.95: the README's values block against the captures' ids, pairs and counts
  exercise|anchor|mapping|requests|highlight|nrt|stale|sync|drift|default|absent|seven|sockets CAPTURE [...]"""
import hashlib, json, os, re, sys

NAME = sys.argv[1]
fails, oks, VALUES = [], [], []


def ok(c, msg):
    (oks if c else fails).append(msg)


def raw(p):
    return open(p, encoding="utf-8").read().splitlines()


def rd(t, p):
    return open(os.path.join(t, p), encoding="utf-8").read()


def one(L, rx, msg=None):
    m = [re.search(rx, l) for l in L]
    m = [x for x in m if x]
    ok(len(m) >= 1, msg or ("a line matches " + rx))
    return m[0] if m else None


def every(L, rx):
    return [m for m in (re.search(rx, l) for l in L) if m]


def slice_of(src, start, end_rx):
    i = src.index(start)
    m = re.compile(end_rx, re.M).search(src, i + len(start))
    return src[i:m.end()]


W = "tiffinbox-web/src/main/java/com/tiffinbox/web/"
C = "tiffinbox-core/src/main/java/com/tiffinbox/"
R = "tiffinbox-web/src/main/resources/"
TS = "tiffinbox-web/src/test/java/"
V4 = re.findall(r"VALUES \('([^']+)', '(\w+)', (\d+)\)", rd("after", "tiffinbox-core/src/main/resources/db/migration/V4__dish.sql"))
TYPE = {str(i): t for i, (n, t, p) in enumerate(V4, 1)}
DNAME = {str(i): n for i, (n, t, p) in enumerate(V4, 1)}
RX = open("receipts.sh", encoding="utf-8").read()
NEWD = re.search(r"^NEWD='([^']+)'; NEWD2='([^']+)'$", RX, re.M)
NEW1, NEW2 = NEWD.group(1), NEWD.group(2)
HIT = r"(\d+) \[([0-9, ]*)\]"
FRAG = "<em>Vegetarian</em> Lunch Box"


def ids(m, g=2):
    return [x.strip() for x in m.group(g).split(",") if x.strip()]


def hit(L, rx, msg):
    """a line holding 'N [ids]' after rx: the count re-derived from the ids list (S8.95)"""
    m = one(L, rx + HIT, msg)
    if not m: return None, []
    i = ids(m, m.lastindex)
    ok(int(m.group(m.lastindex - 1)) == len(i), msg + ": the count %s = the ids listed (%d)" % (m.group(m.lastindex - 1), len(i)))
    return int(m.group(m.lastindex - 1)), i


if NAME == "static":
    A, B = sys.argv[2], sys.argv[3]
    s8, s1, s2 = rd("..", "c8-unit18/harness/s818.py"), rd("..", "c8-unit21/harness/s821.py"), rd("harness", "s822.py")
    for nm, st, en in (("XFAM_S2", "XFAM_S2 = {\n", r"^}\n"), ("XFAM_S3 (s817's def s3)", "def s3(s, raw):\n", r"^    return out\n"),
                       ("XFAM_S4", "XFAM_S4 = {\n", r"^}\n"), ("TIMEPAT_S4 / XEXEMPT_S4 / def s4", "TIMEPAT_S4 = ", r"^    return out\n")):
        a, b = slice_of(s8, st, en), slice_of(s2, st, en)
        ok(a == b, "%s: s822.py's slice is s818.py's byte for byte (md5 %s)" % (nm, hashlib.md5(b.encode()).hexdigest()))
    for nm, st, en in (("XU19", "XU19 = {\n", r"^}\n"), ("XU20", "XU20 = {\n", r"^}\n"), ("XU21", "XU21 = {\n", r"^}\n")):
        ok(slice_of(s1, st, en) == slice_of(s2, st, en), "%s: s822.py carries s821.py's block byte for byte" % nm)
    xb1, xb2 = slice_of(s1, "XFAM_S4B = {\n", r"^}\n"), slice_of(s2, "XFAM_S4B = {\n", r"^}\n")
    tb1, tb2 = slice_of(s1, "TIMEPAT_S4B = ", r"\)\n"), slice_of(s2, "TIMEPAT_S4B = ", r"\)\n")
    ok(xb1 == xb2 and "(?!-)" in xb2, "XFAM_S4B: s822.py's block is s821.py's byte for byte, the (?!-) member with it (md5 %s, R.434)" % hashlib.md5(xb2.encode()).hexdigest())
    ok(tb1 == tb2, "TIMEPAT_S4B: s822.py's is s821.py's byte for byte (md5 %s)" % hashlib.md5(tb2.encode()).hexdigest())
    ok("XEXEMPT_S4B =" not in s2 and "XEXEMPT_S4B[" not in s2, "no XEXEMPT_S4B (§BUILDERS 3)")
    VALUES.append("XFAM_S4B md5 %s · TIMEPAT_S4B md5 %s" % (hashlib.md5(xb2.encode()).hexdigest(), hashlib.md5(tb2.encode()).hexdigest()))
    d = rd(A, W + "Dishes.java")
    ok("@Highlight(fields = @HighlightField(name = \"name\"))\n    SearchHits<Dish> searchByName(String name);" in d and "List<Dish> findByName(String name);" in d, "Dishes: findByName kept, searchByName with @Highlight on name returning SearchHits<Dish>")
    s = rd(A, W + "DishSearch.java")
    ok('@Profile("dev")' in s and "public record Hit(String id, String name, List<String> fragment)" in s and "dishes.searchByName(q)" in s and 'getHighlightField("name")' in s, "DishSearch: under dev, the hit carries the fragment (Hit(id, name, fragment)), read off searchByName")
    sv = rd(A, W + "DishService.java")
    ok("@Service\n@Profile(\"dev\")" in sv and "    @Transactional\n    public DishSaved add(" in sv and "rows.save(new DishEntity(name, mealType, price))" in sv and "events.publishEvent(saved);" in sv and "ElasticsearchOperations" not in sv and "Dishes" not in sv.split("*/")[-1], "DishService: @Service, dev only, @Transactional on JPA's manager (the one TiffinBox has), the row saved, DishSaved published - no index write inside it")
    sy = rd(A, W + "DishIndexSync.java")
    ok("@Component\n@Profile(\"dev\")" in sy and "@TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)" in sy and "dishes.save(new Dish(" in sy and "BEFORE_COMMIT" not in sy, "DishIndexSync: @Component, dev only, AFTER_COMMIT, the repository's save")
    wr = rd(A, W + "DishWrite.java")
    ok('@Profile("dev")' in wr and '@PostMapping("/dishes")' in wr and "@ResponseStatus(HttpStatus.CREATED)" in wr, "DishWrite: POST /dishes, 201, under dev only")
    ok("public record DishSaved(long id, String name, String mealType, int price)" in rd(A, W + "DishSaved.java"), "DishSaved(id, name, mealType, price)")
    e = rd(A, C + "DishEntity.java")
    ok("public DishEntity(String name, MealType mealType, int price)" in e and "protected DishEntity()" in e, "DishEntity: a constructor for a new row added beside Hibernate's")
    it = rd(A, TS + "com/tiffinbox/web/ElasticsearchIT.java")
    ok('bindIpAndPort("127.0.0.1", 20615)' in it and 'containsExactly("127.0.0.1:20615->9200/tcp")' in it and "bindIpAndPort(\"127.0.0.1\", 20606)" not in it and it.count("    @Test\n") == 2 and 'dishes.searchByName("veg")' in it and 'containsExactly("<em>Vegetarian</em> Lunch Box")' in it, "ElasticsearchIT: 127.0.0.1:20615 (unit 21's 20606 moved), two tests, the second searchByName's fragment")
    ok('bindIpAndPort("127.0.0.1", 20578)' in rd(A, TS + "com/tiffinbox/web/MongoDatastoreIT.java"), "MongoDatastoreIT keeps 127.0.0.1:20578")
    srv, srvb = rd(A, W + "TiffinBoxServer.java"), rd(B, W + "TiffinBoxServer.java")
    ok(re.sub(r"/\*\*.*?\*/", "", srv, flags=re.S) == re.sub(r"/\*\*.*?\*/", "", srvb, flags=re.S) and "Course 8, unit 22:" in srv, "TiffinBoxServer: the code as unit 21 shipped it (the start's delete-then-save stays); a unit 22 Javadoc paragraph")
    for f in ("pom.xml", "tiffinbox-core/pom.xml", "tiffinbox-web/pom.xml", "compose.yaml", R + "application.yaml", R + "application-dev.yaml", R + "dish-settings.json", W + "Dish.java", "tiffinbox-core/src/main/resources/db/migration/V4__dish.sql", TS + "slice/ElasticsearchSlice.java"):
        ok(rd(A, f) == rd(B, f), "the change leaves " + f + " as unit 21 shipped it")
    sl = rd("exercise", "SaveLab.java")
    ok("import com.tiffinbox.web.Dish;" in sl and "20618" in sl and sl.count("ops.save(dish);") == 1 and "RefreshPolicy.IMMEDIATE" not in sl and "low_level.Request=TRACE" in sl, "exercise/SaveLab.java: the shipped Dish, Elasticsearch on 20618, ONE template save, no refresh policy of its own, the trace logger on")
    ck = rd("exercise", "check.sh")
    ok("20618" in ck and "_count" in ck and "_refresh" in ck and "refresh=(true|wait_for)" in ck and "1 1 yes" in ck, "exercise/check.sh: the store's _count, the document writes counted, a refresh behind the write (R.196)")
    h = rd("harness", "src/probe/u22/H22.java")
    ok(h.count("new IllegalStateException(\"PLANTED") == 3 and "the harness plants a failure" in h and "JpaTransactionManager transactionManager(" in h and "dishes_drift" in h, "H22: three planted failures, each labelled; JPA's manager named transactionManager; the harness's own index dishes_drift")
elif NAME == "r250":
    A, B = sys.argv[2], sys.argv[3]
    r = rd(A, "README.md")
    items = [
        ("README.md's unit 21 section \"`mvn verify` runs 18 + 12\" - noted (18 + 13)", "`mvn verify` runs 18 + 12 *(Course 8, unit 22: 18 + 13" in r),
        ("README.md's unit 20 section \"18 + 11 (Course 8, unit 21: 18 + 12 ...)\" - noted (18 + 13)", "*(Course 8, unit 21: 18 + 12 — `ElasticsearchIT`)* *(Course 8, unit 22: 18 + 13)*" in r),
        ("README.md's unit 19 section \"(Course 8, unit 21: 18 + 12)\" - noted (18 + 13)", "*(Course 8, unit 21: 18 + 12)* *(Course 8, unit 22: 18 + 13)*" in r),
        ("README.md's unit 21 Part B opening \"unit 22 adds the write path next\" - noted (it has)", "unit 22 adds the write path next" in r and "*(Course 8, unit 22: it has" in r),
        ("README.md's unit 21 section \"a copy ... which the \"dev\" start rebuilds\" - noted (and the listener adds each committed row)", "*(Course 8, unit 22: the start rebuilds it, and the listener `DishIndexSync` adds" in r),
        ("ElasticsearchIT's Javadoc \"18 + 12 under mvn verify\" - noted (18 + 13 since) and \"20606\" - noted (20615)", "18 + 12 under mvn verify (Course 8, unit 22: 18 + 13 since)" in rd(A, TS + "com/tiffinbox/web/ElasticsearchIT.java") and "20606 was unit 21's slot" in rd(A, TS + "com/tiffinbox/web/ElasticsearchIT.java")),
        ("MongoDatastoreIT's Javadoc \"18 + 12 - ElasticsearchIT beside it\" - noted (18 + 13)", "Course 8, unit 22: 18 + 13 - ElasticsearchIT's second test." in rd(A, TS + "com/tiffinbox/web/MongoDatastoreIT.java")),
        ("DishEntityRepository's Javadoc \"nothing writes a dish row but V4__dish.sql\" - noted (DishService writes one for each POST /dishes)", "(Course 8, unit 22: DishService writes one too since" in rd(A, C + "DishEntityRepository.java")),
        ("DishEntity's Javadoc \"a copy of them the start rebuilds\" - noted (and the listener adds)", "(Course 8, unit 22: the start rebuilds the copy, and the listener DishIndexSync adds" in rd(A, C + "DishEntity.java")),
        ("Dishes' Javadoc - a unit 22 paragraph (searchByName, the listener's save)", "Course 8, unit 22: searchByName sends the same query_string" in rd(A, W + "Dishes.java")),
        ("DishSearch's Javadoc \"the copy the \"dev\" start rebuilt\" - a unit 22 paragraph (the fragment, the listener)", "Course 8, unit 22: the route reads Dishes.searchByName since" in rd(A, W + "DishSearch.java")),
        ("TiffinBoxServer's Javadoc \"the index is a copy the start rebuilds\" - a unit 22 paragraph after it (the start's re-index stays; the listener adds)", "Course 8, unit 22: the start's re-index stays as it is" in rd(A, W + "TiffinBoxServer.java")),
        ("V4__dish.sql's comment \"a copy the \"dev\" start rebuilds\" - kept: a migration's bytes are Flyway's checksum (a comment edit is a new checksum on every database that ran V4); this README's unit 22 section says the listener adds", "a copy the \"dev\" start rebuilds from them" in rd(A, "tiffinbox-core/src/main/resources/db/migration/V4__dish.sql")),
        ("compose.yaml's \"the start rebuilds the index from the rows\" (no volume) - kept: still true, the listener's copies are rebuilt by the next start too", "the start rebuilds the index from the rows" in rd(A, "compose.yaml")),
    ]
    for t, c_ in items:
        ok(c_, "R.250: " + t)
    ok("## Course 8 · unit 22 — Spring Data Elasticsearch" in r, "the anchor README: its unit 22 section")
    left = [l for l in r.splitlines() if "18 + 12" in l and "unit 22" not in l and "18 + 13" not in l]
    ok(not left, "no \"18 + 12\" left without its unit 22 note (%d)" % len(left))
elif NAME == "javadoc":
    A, B = sys.argv[2], sys.argv[3]
    import importlib.util
    sp = importlib.util.spec_from_file_location("s822lib", "harness/s822.py")
    added = []
    for d, ds, fs in os.walk(A):
        for f in fs:
            if not f.endswith((".java", ".yaml", ".sql")): continue
            p = os.path.join(d, f); q = os.path.join(B, os.path.relpath(p, A))
            new = open(p, encoding="utf-8").read().splitlines()
            old = set(open(q, encoding="utf-8").read().splitlines()) if os.path.exists(q) else set()
            for l in new:
                t = l.strip()
                if l not in old and (t.startswith(("*", "/**", "//", "#", "--"))):
                    added.append(re.sub(r"^(/\*\*|\*/|\*|//|#|--)\s?", "", t))
    text = " ".join(x for x in added if x)
    import subprocess, tempfile
    with tempfile.NamedTemporaryFile("w", suffix=".md", delete=False, dir=".harness" if os.path.isdir(".harness") else None) as tf:
        tf.write(text + "\n"); fn = tf.name
    o = subprocess.run([sys.executable, "-I", "-B", "harness/s822.py", "harness/dur8.py", fn], capture_output=True, text=True)
    os.unlink(fn)
    last = o.stdout.strip().splitlines()[-1] if o.stdout.strip() else ""
    # a Javadoc names its numbers (18 + 13, the ports) as code does - R.302's typed-number rule is the README's; every family binds
    bad = [l.split(": ", 1)[1] for l in o.stdout.splitlines() if " line " in l and "R.302" not in l]
    ok(o.returncode == 0 and re.match(r"^self-test: \d+ cases", last) and not bad, "the Javadoc and comment lines the change added (%d lines): s822's families (R.302's typed numbers aside) refuse 0%s" % (len(added), (" - " + "; ".join(bad))[:400] if bad else ""))
elif NAME == "wib":
    L = raw(sys.argv[2]); f = sys.argv[3]
    i = next(k for k, l in enumerate(L) if l.startswith("in bash "))
    j = next(k for k, l in enumerate(L) if k > i and l.startswith("  then the solution's lines"))
    e = next(k for k, l in enumerate(L) if k > j and l.startswith("  the shell is now in"))
    part = L[i + 1:j] if f.endswith("README.md") else L[j + 1:e]
    print("\n".join(re.sub(r"^    ", "", l) for l in part))
    sys.exit(0)
elif NAME == "same":
    a, b = raw(sys.argv[2]), raw(sys.argv[3])
    t = lambda L, k: [l for l in L if re.search(k, l)]
    ok(t(a, r"refresh policy") == t(b, r"refresh policy"), "stale and nrt: the template's refresh policy line the same")
    ok(any(l.endswith("b: the count that follows it -> 0") for l in a) and any(l.endswith("the template's save, the count that follows it -> 0") for l in b), "the template's save: 0 in both")
    ok(any(l.endswith("a: the count that follows it -> 1") for l in a) and any(l.endswith("the repository's save, the count that follows it -> 1") for l in b), "the repository's save: 1 in both")
    rq = lambda L: [l for l in L if re.search(r"request: PUT '<es>/dishes_nrt_j/_doc/1\?refresh=false'|request: POST '<es>/dishes_nrt_j/_refresh'", l)]
    ok(len(rq(a)) == 3 and len(rq(b)) == 3, "the request lines: refresh=false twice and one _refresh in each (nrt's a and b, stale's two saves)")
    print("stale = nrt's slices (chk22 same): %s" % ("ok" if not fails else "FAIL " + "; ".join(fails)))
    sys.exit(1 if fails else 0)
elif NAME == "exercise":
    L = raw(sys.argv[2]); w, q = sys.argv[3], sys.argv[4]
    ok(int(w) == len(q.split()) == 24, "the spoken line: %s words (wc -w) - the brief's 24" % w)
    for sh in ("bash", "zsh"):
        i = next((k for k, l in enumerate(L) if l.startswith("in %s " % sh)), None)
        ok(i is not None, sh + ": its section")
        if i is None: continue
        blk = L[i:i + 40]
        ok(any(l.strip() == "saved: dish 1 · the count that follows: 0" for l in blk), sh + ": broken - the count that follows the template's save: 0")
        ok(any(l.strip() == "check: _count -> 0 · document writes the program sent: 1 · a refresh behind the write: no · solved: no" for l in blk), sh + ": broken - check: _count 0, one write, no refresh, solved: no")
        ok(any(l.strip() == "saved: dish 1 · the count that follows: 1" for l in blk), sh + ": solved - the count: 1")
        ok(any(l.strip() == "check: _count -> 1 · document writes the program sent: 1 · a refresh behind the write: yes · solved: yes" for l in blk), sh + ": solved - check: _count 1, one write, refresh yes, solved: yes")
        ok(any("PUT '/dishes/_doc/1?refresh=false'" in l for l in blk) and any("PUT '/dishes/_doc/1?refresh=true'" in l for l in blk), sh + ": the trace - refresh=false broken, refresh=true solved")
    ok(len(every(L, r"listening on 20618 afterwards: 0 · the container c8u22-es-ex afterwards: 0 ")) == 2, "both shells: 20618 free, the container gone after")
    ok(len(every(L, r"images afterwards: the same list yes")) == 2, "both shells: the images list unchanged (nothing pulled)")
    ok(len(every(L, r"the block's exit 0")) == 4, "the four blocks exit 0")
    VALUES.append("the exercise: the template's save 0, solved 1, one write, refresh=true")
elif NAME == "anchor":
    L = raw(sys.argv[2])
    rl = every(L, r"Surefire's Results line: Tests run: (\d+), Failures: 0, Errors: 0, Skipped: 0$")
    ok([int(m.group(1)) for m in rl] == [18, 18, 13], "the tests: 18 (package, Docker at nothing), then 18 + 13 under verify - Maven's Results lines")
    ok(one(L, r"the Elasticsearch IT's container while verify ran, Docker's own list \(dk ps, polled on a count\): Ports 9300/tcp, 127\.0\.0\.1:20615->9200/tcp · listening on 20615 after it: 0$") is not None, "the IT's container: 127.0.0.1:20615->9200/tcp, gone after (S8.94)")
    ok(one(L, r"the Mongo IT's container while verify ran: Ports 127\.0\.0\.1:20578->27017/tcp · listening on 20578 after it: 0$") is not None, "the Mongo IT: 127.0.0.1:20578, gone after")
    ok(one(L, r"ES IT Dishes\.searchByName\(\"veg\"\) of three saved: ids \[1\] · the fragment of the first \[<em>Vegetarian</em> Lunch Box\]$") is not None, "the IT's second test: searchByName veg -> [1], the fragment")
    ok(one(L, r"ES IT heap_max_in_bytes \(the client's nodes info, jvm\): 536870912$") is not None, "the IT's heap 536870912")
    libs = every(L, r"^  (before|after)/: (\d+) libraries$")
    ok(len(libs) == 2 and libs[0].group(2) == libs[1].group(2), "the libraries: after/'s count = before/'s (the change adds no dependency)")
    ok(one(L, r"gained: 0 · lost: 0$") is not None, "the jars: none gained, none lost")
    sc = one(L, r"of them \"Could not safely identify\": (\d+) · naming Dishes: (\d+) - by module: (.*) · \"Multiple Spring Data modules found\": (\d+)$")
    ok(one(L, r"\(x1\) Successfully applied 4 migrations$") is not None, "Flyway: 4 migrations on the fresh database")
    ok(one(L, r"tiffinbox: dishes re-indexed: rows %d · documents before 0 · documents after %d$" % (len(V4), len(V4))) is not None, "the first start: rows 10, documents before 0, after 10 (V4's count)")
    ok(one(L, r"the wait lines \(\"Waiting\"/\"retry\" naming Elasticsearch\): 0$") is not None, "0 wait lines")
    ok(one(L, r"S8\.84: the key spring\.elasticsearch\.uris on that command line: 1 - the one URI http://127\.0\.0\.1:20614$") is not None, "S8.84: one URI on the command line")
    rows0 = one(L, r"the rows \(psql, the unit's PostgreSQL\): select count\(\*\) from dish -> (\d+) · the index \(curl on 20614\): _cat/indices dishes -> dishes green open 1 0 (\d+)$")
    ok(rows0 and rows0.group(1) == rows0.group(2) == str(len(V4)), "rows 10 = documents 10, green (psql beside _cat/indices)")
    m = one(L, r"GET /dishes/search\?q=veg \(TiffinBox\) -> 200 (\[.*\])$")
    j = json.loads(m.group(1)) if m else []
    ok(j == [{"id": "1", "name": DNAME["1"], "fragment": [FRAG]}], "the route: veg -> [1] with its fragment")
    m = one(L, r"curl: POST /dishes/_search match name veg, highlight name -> 1 \[1\] · 1 VEG highlight\.name \[\"<em>Vegetarian</em> Lunch Box\"\]$")
    p = one(L, r"POST /dishes \{\"name\":\"%s\",\"mealType\":\"VEG\",\"price\":110\} \(TiffinBox\) -> 201 (\{.*\})$" % re.escape(NEW1))
    pid = json.loads(p.group(1))["id"] if p else None
    ok(pid == len(V4) + 1, "POST /dishes: 201, the id PostgreSQL assigned = V4's count + 1 (%s)" % pid)
    ok(one(L, r"the listener's requests, by the client's trace logger \(after the POST, before any other request\): PUT '<es>/dishes/_doc/%s\?refresh=false' · POST '<es>/dishes/_refresh'$" % pid) is not None, "the listener: PUT _doc/<id>?refresh=false, then POST _refresh (the repository's save)")
    after = one(L, r"then the rows \(psql\): select count\(\*\) from dish -> (\d+) · select id from dish where name = the new dish -> (\d+) · the index \(curl\): _count -> (\d+) · _doc/11's _source -> (.*)$")
    ok(after and after.group(1) == after.group(3) == str(len(V4) + 1) and after.group(2) == str(pid), "rows 11 = documents 11 (psql beside _count), the row's id = the POST's")
    ok(after and json.loads(after.group(4)).get("name") == NEW1, "_doc/11's _source: the new dish")
    ok(one(L, r"GET /dishes/search\?q=mushroom \(TiffinBox\) -> 200 \[\{\"id\":\"%s\",\"name\":\"%s\",\"fragment\":\[\"<em>Mushroom</em> Noodle Bowl\"\]\}\] · curl: match name mushroom -> 1 \[%s\]$" % (pid, re.escape(NEW1), pid)) is not None, "the new dish found by both witnesses: [11]")
    for r_ in ("/revenue/by-customer", "/kitchen", "/menu/day-19", "/actuator/health"):
        ok(one(L, r"GET %s -> 200 " % re.escape(r_)) is not None, "GET %s 200 under dev" % r_)
    ok(one(L, r"dishes 1 · dishSearch 1 · dishWrite 1 · dishService 1 · dishIndexSync 1 · elasticsearchClient 1 · the PlatformTransactionManager beans: \['transactionManager JpaTransactionManager'\]$") is not None, "the beans: the five, one transaction manager - transactionManager JpaTransactionManager")
    ok(one(L, r"curl: _count dishes before it -> %d$" % (len(V4) + 1)) is not None, "before the second start: 11 documents")
    ok(one(L, r"the start's re-index line: dishes re-indexed: rows %d · documents before %d · documents after %d$" % ((len(V4) + 1,) * 3)) is not None, "the second start on the same database: rows 11 · before 11 · after 11")
    ok(one(L, r"the rows \(psql\): %d · the index \(curl\): _count -> %d · match name mushroom -> 1 \[%s\]$" % (len(V4) + 1, len(V4) + 1, pid)) is not None, "after it: 11 = 11, mushroom [11]")
    ok(one(L, r"the hosts the client's requests went to \(its trace logger\): 127\.0\.0\.1:18884 · the Compose service's own published port \(dk port\): 9200/tcp -> 127\.0\.0\.1:18884$") is not None, "Compose: every request to 127.0.0.1:18884")
    ok(one(L, r"curl on 18884 \(the elasticsearch service\): _cat/indices dishes -> dishes green open 1 0 %d · match name veg -> 1 \[1\]$" % len(V4)) is not None, "Compose: dishes green 10, veg [1]")
    cp = one(L, r"the rows \(psql, Compose's PostgreSQL, the postgres service's own client\): select count\(\*\) from dish -> (\d+) · the index \(curl on 18884\): _count -> (\d+) · the listener's requests: PUT '<es>/dishes/_doc/11\?refresh=false' · POST '<es>/dishes/_refresh'$")
    ok(cp and cp.group(1) == cp.group(2) == str(len(V4) + 1), "Compose: POST /dishes -> rows 11 = documents 11 on Compose's stores")
    ok(one(L, r"the receipt removes the mongo service's two .* = before the window · listening on 18881-18884: 0$") is not None, "the Compose window's volumes back; 18881-18884 free")
    ok(one(L, r"the version lines off the jar names: elasticsearch-java-9\.4\.8\.jar elasticsearch-rest5-client-9\.4\.8\.jar spring-boot-4\.1\.2\.jar spring-data-elasticsearch-6\.1\.2\.jar spring-tx-") is not None, "the version lines: 9.4.8, 4.1.2, 6.1.2")
    hv = one(L, r"HHH000001: Hibernate ORM core version (\S+)")
    VALUES.append("anchor: Flyway 4, the re-index rows %d -> documents %d, dishes green %d, veg [1] with the fragment %s by TiffinBox and curl, strict mode %s \"could not safely identify\" lines (%s naming Dishes: %s) and %s \"Multiple Spring Data modules found\", POST /dishes 201 id %s, rows %d = documents %d, the listener PUT _doc/%s?refresh=false then _refresh, the second start on the same database rows %d -> documents %d, Compose on 18884 with rows %s = documents %s, 18 + 13, the IT 127.0.0.1:20615 and the Mongo IT 127.0.0.1:20578, the 18 without Docker, %s libraries (before %s), HHH000001 %s"
                  % (len(V4), len(V4), len(V4), FRAG, sc.group(1) if sc else "?", sc.group(2) if sc else "?", sc.group(3) if sc else "?", sc.group(4) if sc else "?", pid, len(V4) + 1, len(V4) + 1, pid, len(V4) + 1, len(V4) + 1,
                     cp.group(1) if cp else "?", cp.group(2) if cp else "?", libs[1].group(2) if len(libs) == 2 else "?", libs[0].group(2) if len(libs) == 2 else "?", hv.group(1) if hv else "?"))
elif NAME == "mapping":
    L = raw(sys.argv[2])
    m = one(L, r"curl: GET /dishes/_mapping -> (.*)$")
    parts = dict((p.split(" ", 1)[0], json.loads(p.split(" ", 1)[1])) for p in m.group(1).split(" · ")) if m else {}
    ok(parts.get("name") == {"type": "text", "analyzer": "dish"} and parts.get("mealType") == {"type": "keyword"} and parts.get("price") == {"type": "integer"}, "the mapping the annotations asked for: name text by dish, mealType keyword, price integer")
    ok(parts.get("_class") == {"type": "keyword", "index": False, "doc_values": False}, "the mapper's _class: keyword, index false, doc_values false")
    ok(parts.get("id", {}).get("type") == "text" and parts.get("id", {}).get("fields", {}).get("keyword", {}).get("type") == "keyword", "the dynamic id: text with a keyword sub-field")
    s = one(L, r"curl: GET /dishes/_settings .* -> (.*)$")
    ok(s and 'index.number_of_replicas "0"' in s.group(1) and 'index.analysis.analyzer.dish.tokenizer "standard"' in s.group(1), "the settings: number_of_replicas 0, the analyzer dish")
    d = one(L, r"curl: GET /dishes/_doc/1 -> _source (.*)$")
    src = json.loads(d.group(1)) if d else {}
    ok(src.get("_class") == "com.tiffinbox.web.Dish" and src.get("id") == "1" and src.get("name") == DNAME["1"], "_doc/1's _source: _class com.tiffinbox.web.Dish, the id in the body, the vegetarian box")
    ok(len(every(L, r"^    line \d+: +(@|public record Dish\(@Id)")) == 6, "Dish.java's annotation lines quoted by line number")
    VALUES.append("mapping: _class keyword (index false), the dynamic id text + keyword, name text by dish, _doc/1 _class com.tiffinbox.web.Dish")
elif NAME == "requests":
    L = raw(sys.argv[2])
    rq = every(L, r"request: POST '<es>/dishes/_search' -d '(.*)'$")
    bodies = [json.loads(m.group(1)) for m in rq]
    ok(len(bodies) == 5, "five search requests: the derived finder's two, CriteriaQuery's, NativeQuery's match, NativeQuery's prefix (%d)" % len(bodies))
    qs = {"query_string": {"default_operator": "and", "fields": ["name"], "query": "veg"}}
    if len(bodies) == 5:
        ok(bodies[0]["size"] == 0 and "track_total_hits" in bodies[0] and bodies[0]["query"]["bool"]["must"] == [qs], "derived 1: size 0, track_total_hits, query_string default_operator and")
        ok(bodies[1]["size"] == 1 and bodies[1]["query"]["bool"]["must"] == [qs], "derived 2: size 1, the same query_string")
        ok(bodies[2]["size"] == 10000 and bodies[2]["query"]["bool"]["must"] == [qs], "CriteriaQuery: size 10000, the same query_string")
        ok(bodies[3]["size"] == 10 and bodies[3]["query"] == {"match": {"name": {"query": "veg"}}}, "NativeQuery match: size 10 (its default page)")
        ok(bodies[4]["size"] == 10 and bodies[4]["query"] == {"prefix": {"name": {"value": "veg"}}}, "NativeQuery prefix: size 10")
    ok(one(L, r"PROBE 1 derived: Dishes\.findByName\(\"veg\"\) -> \[1 Vegetarian Lunch Box\]$") is not None, "derived: [1]")
    for k in ("2 CriteriaQuery Criteria\\.where\\(\"name\"\\)\\.is\\(\"veg\"\\) -> ", "3 NativeQuery match name veg -> "):
        c_, i_ = hit(L, "PROBE " + k, k); ok(i_ == ["1"], k + "[1]")
    pc, pi = hit(L, r"PROBE 4 NativeQuery prefix name veg -> ", "prefix")
    pt = one(L, r"PROBE 4 NativeQuery prefix name veg -> .*\] \[(.*)\]$")
    ok(pt and all(TYPE[x.split(" ")[0]] == x.split(" ")[1] for x in pt.group(1).split(", ")), "prefix: each id's meal type = V4's")
    ok("8" in pi and TYPE.get("8") == "VEGAN", "prefix: the vegan box among them (S8.80)")
    cs = every(L, r"curl: POST /dishes/_search (\{.*\}) -> " + HIT + "$")
    ok(len(cs) == 4 and [ids(m, 3) for m in cs[:3]] == [["1"], ["1"], ["1"]] and ids(cs[3], 3) == pi, "curl re-sends each body: [1] x3 and the prefix's same ids")
    VALUES.append("requests: the derived finder size 0 then size 1, CriteriaQuery size 10000, NativeQuery size 10, each [1]; prefix %d [%s] (%s)" % (pc or 0, ", ".join(pi), ", ".join(x + " " + TYPE[x] for x in pi)))
elif NAME == "highlight":
    L = raw(sys.argv[2])
    hb = every(L, r"request: POST '<es>/dishes/_search' -d '(.*)'$")
    ok(sum(1 for m in hb if '"highlight":{"fields":{"name":{}}}' in m.group(1) or '"highlight":{"fields":[{"name":{}}]}' in m.group(1)) == 6, "the highlighted requests carry a highlight block on name (six: the count and the page for each word)")
    ok(one(L, r"PROBE Dishes\.searchByName\(\"veg\"\) -> 1 \[1\] · 1 VEG \{name=\[<em>Vegetarian</em> Lunch Box\]\}$") is not None, "veg -> [1], {name=[<em>Vegetarian</em> Lunch Box]}")
    ok(one(L, r"PROBE Dishes\.searchByName\(\"vegetarian\"\) -> 1 \[1\] · 1 VEG \{name=\[<em>Vegetarian</em> Lunch Box\]\}$") is not None, "vegetarian -> [1], the same fragment")
    lu = one(L, r"PROBE Dishes\.searchByName\(\"lunch\"\) -> 2 \[1, 8\] · 1 VEG \{name=\[Vegetarian <em>Lunch</em> Box\]\} · 8 VEGAN \{name=\[Vegan <em>Lunch</em> Box\]\}$")
    ok(lu is not None and TYPE["1"] == "VEG" and TYPE["8"] == "VEGAN", "lunch -> [1, 8], Vegetarian <em>Lunch</em> Box and the vegan box's")
    ok(one(L, r"curl: match name veg, highlight name -> 1 \[1\] · 1 VEG highlight\.name \[\"<em>Vegetarian</em> Lunch Box\"\]$") is not None, "curl: veg's fragment under hits.hits[0].highlight.name")
    ok(one(L, r"curl: match name lunch, highlight name -> 2 \[1, 8\] · 1 VEG highlight\.name \[\"Vegetarian <em>Lunch</em> Box\"\] · 8 VEGAN highlight\.name \[\"Vegan <em>Lunch</em> Box\"\]$") is not None, "curl: lunch's two fragments")
    VALUES.append("highlight: veg %s [1], vegetarian the same, lunch [1, 8] Vegetarian <em>Lunch</em> Box and Vegan <em>Lunch</em> Box" % FRAG)
elif NAME == "nrt":
    L = raw(sys.argv[2])
    rc = every(L, r"PUT (/dishes_nrt/_doc/1(?:\?refresh=(\w+))?) -> result created · forced_refresh (\w+) · then _count -> (\d+) · _search match_all -> " + HIT + "$")
    ok([(m.group(2), m.group(4)) for m in rc] == [(None, "0"), ("wait_for", "1"), ("true", "1")] and all(m.group(4) == m.group(5) for m in rc), "REST: at once 0, wait_for 1, true 1 - _count beside _search's total")
    ok(one(L, r"PROBE the template's refresh policy \(getRefreshPolicy\) -> null$") is not None, "the template's refresh policy: null")
    for k, n, rq in (("a", "1", [r"PUT '<es>/dishes_nrt_j/_doc/1\?refresh=false'", r"POST '<es>/dishes_nrt_j/_refresh'"]), ("b", "0", [r"PUT '<es>/dishes_nrt_j/_doc/1\?refresh=false'"]), ("c", "1", [r"PUT '<es>/dishes_nrt_j/_doc/1\?refresh=true'"])):
        i = next((x for x, l in enumerate(L) if l.startswith("PROBE -- %s:" % k)), None)
        j = next((x for x, l in enumerate(L) if l == "PROBE %s: the count that follows it -> %s" % (k, n)), None)
        ok(i is not None and j is not None and i < j, "Spring %s: the count %s" % (k, n))
        if i is not None and j is not None:
            got = [l for l in L[i:j] if "request: PUT" in l and "_doc" in l or "_refresh" in l]
            ok(len(got) == len(rq) and all(re.search(r_, g) for r_, g in zip(rq, got)), "Spring %s: its write requests %s" % (k, rq))
    VALUES.append("nrt: REST at once 0, wait_for 1, true 1; Spring the repository's save 1 (refresh=false then _refresh), ElasticsearchOperations.save 0 (refresh=false, policy null), withRefreshPolicy(IMMEDIATE) 1 (refresh=true)")
elif NAME == "stale":
    L = raw(sys.argv[2])
    ok(one(L, r"PROBE the template's save, the count that follows it -> 0$") is not None, "the failure: the template's save, then 0")
    ok(one(L, r"PROBE the repository's save, the count that follows it -> 1$") is not None, "the control: the repository's save, then 1")
    ok(len(every(L, r"PROBE dishes_nrt_j deleted$")) == 2, "the two scratch indices deleted, each printed")
    VALUES.append("stale: the template's save then a count 0, beside the repository's save 1")
elif NAME == "sync":
    L = raw(sys.argv[2])
    s0 = one(L, r"after the start: dishes re-indexed: rows (\d+) · documents before (\d+) · documents after (\d+) · rows (\d+) · documents (\d+)$")
    ok(s0 and s0.group(1) == s0.group(3) == s0.group(4) == s0.group(5) == str(len(V4)), "after the start: rows 10 = documents 10")
    p1 = one(L, r"POST /dishes %s -> 201 (\{.*\}) · the listener's requests: PUT '<es>/dishes/_doc/(\d+)\?refresh=false' · POST '<es>/dishes/_refresh' · rows (\d+) · documents (\d+)$" % re.escape(NEW1))
    ok(p1 and json.loads(p1.group(1))["id"] == int(p1.group(2)) == len(V4) + 1 and p1.group(3) == p1.group(4) == str(len(V4) + 1), "POST 1: id 11, the listener's two requests, rows 11 = documents 11")
    p2 = one(L, r"POST /dishes %s -> 201 (\{.*\}) · the listener's requests: PUT '<es>/dishes/_doc/(\d+)\?refresh=false' · POST '<es>/dishes/_refresh' · rows (\d+) · documents (\d+)$" % re.escape(NEW2))
    ok(p2 and json.loads(p2.group(1))["id"] == int(p2.group(2)) == len(V4) + 2 and p2.group(3) == p2.group(4) == str(len(V4) + 2), "POST 2: id 12, rows 12 = documents 12")
    du = one(L, r"POST /dishes %s again \(the name is the table's unique key\) -> (\d+) · rows (\d+) · documents (\d+)$" % re.escape(NEW1))
    ok(du and du.group(1) != "201" and du.group(2) == du.group(3) == str(len(V4) + 2), "the same name again: refused (%s), rows 12 = documents 12 - the row rolled back, the listener never ran" % (du.group(1) if du else "?"))
    s2 = one(L, r"the second start on u22sync: dishes re-indexed: rows (\d+) · documents before (\d+) · documents after (\d+) · rows (\d+) · documents (\d+) · ids \(psql\) ([0-9,]+) · ids \(curl, match_all\) " + HIT + "$")
    ok(s2 is not None and s2.group(1) == s2.group(2) == s2.group(3) == s2.group(4) == s2.group(5) == str(len(V4) + 2) and sorted(s2.group(6).split(",")) == ids(s2, 8), "the second start: rows 12 · before 12 · after 12, the ids the same in both stores")
    VALUES.append("sync: rows 10 = documents 10, POST -> 11 = 11, another POST -> 12 = 12, the same name again %s and 12 = 12, the second start 12 -> 12" % (du.group(1) if du else "?"))
elif NAME == "drift":
    L = raw(sys.argv[2])
    secs = {}
    cur = None
    for l in L:
        m = re.match(r"^-- mode (\w+) ", l)
        if m: cur = m.group(1); secs[cur] = []
        elif cur: secs[cur].append(l)
    want = {"intx": ("0", "1"), "listener": ("1", "0"), "control": ("1", "1")}
    for k, (r_, i_) in want.items():
        S = secs.get(k, [])
        ok(any(l == "PROBE the context's transaction managers, by name -> class: [transactionManager] -> [JpaTransactionManager]" for l in S), k + ": one manager, transactionManager -> JpaTransactionManager")
        m = one(S, r"rows, PostgreSQL's own answer \(psql on c8u22-pg-h, h22\w+\): the new dish \(Garden Pea Soup\) (\d+) · all rows (\d+) · the index, curl's _count on dishes_drift -> (\d+)$", k + ": the pair line")
        ok(m and (m.group(1), m.group(3)) == (r_, i_) and int(m.group(2)) == len(V4) + int(r_), "%s: rows %s, index %s (psql beside curl's _count)" % (k, r_, i_))
        ok(any(l == "  DELETE /dishes_drift -> acknowledged true" for l in S), k + ": dishes_drift deleted, printed")
    ok(any(l == "PROBE the caller: the exception java.lang.IllegalStateException: PLANTED after both writes (the harness plants a failure)" for l in secs.get("intx", [])), "intx: the caller saw the planted exception")
    li = secs.get("listener", [])
    ok(any(l.startswith("PROBE the listener (AFTER_COMMIT) throws: java.lang.IllegalStateException: PLANTED in the AFTER_COMMIT listener") for l in li), "listener: the planted exception, quoted whole")
    ok(any(l == "  ERROR org.springframework.transaction.support.TransactionSynchronizationUtils: TransactionSynchronization.afterCompletion threw exception" for l in li), "listener: Spring's afterCompletion threw exception line")
    ok(any(l == "PROBE the caller: the call returned, no exception" for l in li), "listener: the caller saw no exception")
    ok(any(l == "PROBE the caller: the call returned, no exception" for l in secs.get("control", [])), "control: no exception")
    ok(len(every(L, r"the harness JVM's exit 0$")) == 3, "the three harness JVMs exit 0")
    VALUES.append("drift (the harness plants a failure): intx rows 0 / index 1, listener rows 1 / index 0 and the caller saw no exception, control rows 1 / index 1")
elif NAME == "default":
    L = raw(sys.argv[2])
    ok(one(L, r"GET /actuator/health -> 200 ") is not None, "health 200")
    ok(one(L, r"GET /dishes/search\?q=veg -> 404 · GET /revenue/by-customer -> 404 · GET /menu/day-19 -> 404 · GET /revenue -> 200 .* · GET /kitchen -> 200 ") is not None, "404 x3, /revenue 200, /kitchen 200")
    ok(one(L, r"POST /dishes \{.*\} -> 404$") is not None, "POST /dishes 404 on the default run (DishWrite is dev's)")
    ok(one(L, r"the beans by name \(1 present, 0 absent\): dishes 0 · dishSearch 0 · dishWrite 0 · dishService 0 · dishIndexSync 0 · elasticsearchClient 0 · a bean whose type names Elasticsearch 0$") is not None, "no Dishes, DishSearch, DishWrite, DishService, DishIndexSync, client bean")
    ok(one(L, r"its log: lines naming 9200 0 · naming elasticsearch, any case 0 · naming 27017 0 · naming mongo, any case 0 · ") is not None, "0 lines naming 9200/elasticsearch/27017/mongo")
    ok(one(L, r"Surefire's Results line: Tests run: 18, Failures: 0, Errors: 0, Skipped: 0$") is not None, "the 18 without Docker")
    VALUES.append("default: health 200, /dishes/search 404, /revenue/by-customer 404, /menu/day-19 404, /revenue 200, /kitchen 200, POST /dishes 404, 0 lines naming 9200 or elasticsearch, 0 naming 27017 or mongo, the 18 under mvn package")
elif NAME == "absent":
    L = raw(sys.argv[2])
    ok(one(L, r"S8\.84: the key spring\.elasticsearch\.uris on that command line: 1 - the one URI http://127\.0\.0\.1:20619$") is not None, "S8.84: one URI, 20619")
    ok(one(L, r"readiness never answered 200 · the JVM's exit 1 · listening on 20610: 0$") is not None, "exit 1")
    ok(one(L, r"Error creating bean with name 'dishes'") is not None, "the bean named: dishes")
    ok(one(L, r"DataAccessResourceFailureException: Connect to http://127\.0\.0\.1:20619 .*Connection refused") is not None, "the client's exception: Connect to ...:20619 ... Connection refused")
    ok(one(L, r"'dishes re-indexed' 0$") is not None, "no re-index")
    VALUES.append("absent: exit 1, Error creating bean with name 'dishes', DataAccessResourceFailureException: Connect to ... Connection refused, the one URI")
elif NAME == "seven":
    L = raw(sys.argv[2]); s466 = sys.argv[3]
    ms = every(L, r"exit 0 · the seven responses: (\d+) lines · md5 ([0-9a-f]{32}) · listening on \d+ now: 0$")
    ok(len(ms) == 2 and ms[0].group(2) == ms[1].group(2) == s466, "the seven: before/ and after/ = Course 7's md5 (%s)" % (ms[0].group(2) if ms else "?"))
    ok(one(L, r"the seven, after/ against before/: lines that differ: 0$") is not None, "0 lines differ")
    VALUES.append("the seven: md5 %s on before/ and after/" % (ms[0].group(2) if ms else "?"))
elif NAME == "sockets":
    L = raw(sys.argv[2])
    m = one(L, r"the sockets: listening \(TCP\) on ([0-9, ]+) · connections from another local port \(outbound\): (\d+) · UDP sockets: (\d+)$")
    ok(m and m.group(2) == "0" and m.group(3) == "0", "no outbound TCP or UDP socket in the samples")
    VALUES.append("sockets: listening on %s, outbound 0, UDP 0" % (m.group(1) if m else "?"))
elif NAME == "numbers":
    r = open(sys.argv[2], encoding="utf-8").read()
    caps = "\n".join(open(p, encoding="utf-8").read() for p in sys.argv[3:])
    blk = r.split("<!-- values: begin -->")[1].split("<!-- values: end -->")[0] if "<!-- values: begin -->" in r else ""
    ok(bool(blk), "README.md holds the values block")
    pairs = re.findall(r"`(intx|listener|control)`: rows (\d+) / index (\d+)", blk)
    want = {"intx": ("0", "1"), "listener": ("1", "0"), "control": ("1", "1")}
    ok(len(pairs) == 3 and all(want[k] == (a, b) for k, a, b in pairs), "the values block's drift pairs = the capture's (intx 0/1, listener 1/0, control 1/1)")
    for k, (a, b) in want.items():
        ok(re.search(r"-- mode %s .*?the new dish \(Garden Pea Soup\) %s · all rows \d+ · the index, curl's _count on dishes_drift -> %s" % (k, a, b), caps, re.S) is not None, "drift %s: the capture prints rows %s / index %s" % (k, a, b))
    ok("b: the count that follows it -> 0" in caps and "the template's save, the count that follows it -> 0" in caps, "stale's 0 in the captures")
    ok('"size":10000' in caps, "requests: 10000 in the capture")
    ok(FRAG in caps, "highlight: the <em> fragment in the captures")
    print("S8.95: the values block's rows/index pairs, stale's 0, requests' 10000 and the fragment - each re-derived from the captures: %s" % ("ok" if not fails else "FAIL"))
for m in oks: print("ok " + m)
for m in fails: print("FAIL " + m)
if VALUES: print("VALUES " + "; ".join(VALUES))
sys.exit(1 if fails else 0)
