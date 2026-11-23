"""Unit 21's checks (python3 -I -B harness/chk21.py NAME ARGS...). Each capture's numbers are asserted against a second witness of the
same run - never a typed figure (S8.78): Java's answers (TiffinBox's /dishes/search under "dev", the start's re-index line, the client's
own request lines by its trace logger, the IT's lines, the exercise's program) against the store's own REST API by curl (_analyze,
_search, _mapping, _settings, _cat/indices, _explain, _cluster/settings, GET /); Docker's own records (the IT containers' Ports, the
volume count, the image's Config); Surefire's XML against Maven's Results lines; the seven's md5 against Course 7's. Every hit COUNT is
re-derived from the ids list it prints beside, and every id's meal type is read off after/'s V4__dish.sql, never typed (S8.95). The
heap the six settings pin is read off compose.yaml's ES_JAVA_OPTS. Prints ok/FAIL lines and one VALUES line; exits 1 on any FAIL.
  static AFTER BEFORE   the change itself, read off the files, and the harness's own rules
  r250 AFTER BEFORE     the sentences the change made false or incomplete: rewritten or noted beside them, each listed
  wib CAPTURE FILE      the lines the exercise's block printed for FILE (bash's), for receipts.sh to compare with "What it prints"
  numbers CAPTURES... PROSE...   S8.95: every "a/the WAY finds N, M of them ..." sentence against the capture's ids and V4's meal types
  exercise|image|anchor|tokens|nohit|sayso|fuzzy|late|explain|default|absent|seven|sockets CAPTURE [...]"""
import hashlib, json, os, re, sys, zipfile

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
R = "tiffinbox-web/src/main/resources/"
TS = "tiffinbox-web/src/test/java/"
EIMG = "docker.elastic.co/elasticsearch/elasticsearch@sha256:fb7f2d0df199b3ea14a700e88a0b701d502cb44409ece3e1540b1dc1c5d5c403"
V4 = re.findall(r"VALUES \('([^']+)', '(\w+)', (\d+)\)", rd("after", "tiffinbox-core/src/main/resources/db/migration/V4__dish.sql"))
TYPE = {str(i): t for i, (n, t, p) in enumerate(V4, 1)}
DNAME = {str(i): n for i, (n, t, p) in enumerate(V4, 1)}
XMX = re.search(r'ES_JAVA_OPTS: "-Xms(\d+)m -Xmx(\d+)m"', rd("after", "compose.yaml"))
HEAP = int(XMX.group(2)) * 1024 * 1024
HIT = r"(\d+) \[([0-9, ]*)\]"


def ids(m):
    return [x.strip() for x in m.group(2).split(",") if x.strip()]


def hit(L, rx, msg):
    """a line holding 'N [ids]' after rx: the count re-derived from the ids list (S8.95)"""
    m = one(L, rx + HIT, msg)
    if not m: return None, []
    i = ids(m)
    ok(int(m.group(1)) == len(i), msg + ": the count %s = the ids listed (%d)" % (m.group(1), len(i)))
    return int(m.group(1)), i


def vegan(i):
    return [x for x in i if TYPE.get(x) == "VEGAN"]


if NAME == "static":
    A, B = sys.argv[2], sys.argv[3]
    s8, s1 = rd("..", "c8-unit18/harness/s818.py"), rd("harness", "s821.py")
    for nm, st, en in (("XFAM_S2", "XFAM_S2 = {\n", r"^}\n"), ("XFAM_S3 (s817's def s3)", "def s3(s, raw):\n", r"^    return out\n"),
                       ("XFAM_S4", "XFAM_S4 = {\n", r"^}\n"), ("TIMEPAT_S4 / XEXEMPT_S4 / def s4", "TIMEPAT_S4 = ", r"^    return out\n")):
        a, b = slice_of(s8, st, en), slice_of(s1, st, en)
        ok(a == b, "%s: s821.py's slice is s818.py's byte for byte (md5 %s)" % (nm, hashlib.md5(b.encode()).hexdigest()))
    ok(slice_of(rd("..", "c8-unit19/harness/s819.py"), "XU19 = {\n", r"^}\n") == slice_of(s1, "XU19 = {\n", r"^}\n"), "XU19: s821.py carries unit 19's block byte for byte")
    ok(slice_of(rd("..", "c8-unit20/harness/s820.py"), "XU20 = {\n", r"^}\n") == slice_of(s1, "XU20 = {\n", r"^}\n"), "XU20: s821.py carries unit 20's block byte for byte")
    xb = slice_of(s1, "XFAM_S4B = {\n", r"^}\n"); tb = slice_of(s1, "TIMEPAT_S4B = ", r"\)\n")
    ok(xb.count('": (r"') == 10 and "singular time words" in xb, "XFAM_S4B: one block, ten members (BLUE S4B's nine + the singular time words), md5 %s - the block 22-24 carry byte for byte" % hashlib.md5(xb.encode()).hexdigest())
    ok("XEXEMPT_S4B =" not in s1 and "XEXEMPT_S4B[" not in s1, "no XEXEMPT_S4B (§BUILDERS 3)")
    VALUES.append("XFAM_S4B md5 %s · TIMEPAT_S4B md5 %s" % (hashlib.md5(xb.encode()).hexdigest(), hashlib.md5(tb.encode()).hexdigest()))
    pom, pomb = rd(A, "tiffinbox-web/pom.xml"), rd(B, "tiffinbox-web/pom.xml")
    for a, sc in (("spring-boot-starter-data-elasticsearch", None), ("spring-boot-starter-data-elasticsearch-test", "test"), ("testcontainers-elasticsearch", "test")):
        m = re.search(r"<dependency>\s*<groupId>[^<]+</groupId>\s*<artifactId>" + re.escape(a) + r"</artifactId>\s*(<scope>(\w+)</scope>\s*)?</dependency>", pom)
        ok(m is not None and (m.group(2) if m else None) == sc, "tiffinbox-web/pom.xml: %s, scope %s, no version (the parent's BOM)" % (a, sc or "compile"))
    ok("(Course 8, unit 21: Jackson 2's\n         jackson-databind is back at run time, through the Elasticsearch client, beside Jackson 3 - Spring MVC still reads and\n         writes with Jackson 3" in pom, "tiffinbox-web/pom.xml: the Course 6 Jackson comment noted (R.250)")
    zips = {j: zipfile.ZipFile(os.path.join(".m2-demo/org/springframework/boot", j, "4.1.2", j + "-4.1.2.jar")) for j in ("spring-boot-elasticsearch", "spring-boot-data-elasticsearch")}
    imp = [l for j in zips.values() for l in j.read("META-INF/spring/org.springframework.boot.autoconfigure.AutoConfiguration.imports").decode().splitlines() if l.strip() and not l.startswith("#")]
    y = rd(A, R + "application.yaml")
    ex = re.search(r"\n  autoconfigure:\n    exclude:\n((?:      - \S+\n)+)", y).group(1).split()
    ex = [x for x in ex if x != "-"]
    ok(len(imp) == 7 and ex[3:] == imp and len(ex) == 10, "application.yaml: the exclude list = Part A's three + the seven names the two jars' AutoConfiguration.imports list (read off .m2-demo's jars), in their order - ten")
    ok(ex[:3] == re.search(r"\n  autoconfigure:\n    exclude:\n((?:      - \S+\n)+)", rd(B, R + "application.yaml")).group(1).split()[1::2], "application.yaml: Part A's three Mongo names kept, first")
    dy = rd(A, R + "application-dev.yaml")
    ok('  autoconfigure:\n    exclude: ""\n' in dy and "spring.elasticsearch" not in re.sub(r"#.*", "", dy), "application-dev.yaml: exclude \"\" (clears all ten), no spring.elasticsearch key set (Compose hands the address)")
    c = rd(A, "compose.yaml"); es = c.split("  elasticsearch:\n")[1].split("\nvolumes:")[0]
    esl = "\n".join(l for l in es.splitlines() if not l.lstrip().startswith("#"))
    for k, v in (("discovery.type", "single-node"), ("xpack.security.enabled", '"false"'), ("xpack.ml.enabled", '"false"'), ("ingest.geoip.downloader.enabled", '"false"'), ("xpack.inference.elastic.authorization.enabled", '"false"'), ("ES_JAVA_OPTS", '"-Xms512m -Xmx512m"')):
        ok(("      %s: %s" % (k, v)) in esl, "compose.yaml's elasticsearch: %s %s" % (k, v))
    ok("    image: docker.elastic.co/elasticsearch/elasticsearch:9.4.8" in esl and '      - "127.0.0.1:18884:9200"' in esl and "volumes" not in esl and "pull_policy" not in c and "sha256:fb7f2d0df199b3ea14a700e88a0b701d502cb44409ece3e1540b1dc1c5d5c403" in c,
       "compose.yaml's elasticsearch: the tag (R.387's split), 127.0.0.1:18884:9200, no volume, no pull_policy, the digest in its comment")
    ok(len(V4) == 10 and len({n for n, t, p in V4}) == 10 and {t for n, t, p in V4} == {"VEG", "NON_VEG", "VEGAN"}, "V4__dish.sql: ten rows, ten names, the three meal types")
    md = rd(A, W + "MenuDay.java"); price = {t: int(re.search(t + r"_PRICE = (\d+);", md).group(1)) for t in ("VEG", "NON_VEG", "VEGAN")}
    ok(all(int(p) == price[t] for n, t, p in V4), "V4__dish.sql: each row's price = MenuDay's price for its meal type (%s)" % ", ".join("%s %d" % kv for kv in sorted(price.items())))
    d = rd(A, W + "Dish.java")
    ok('@Document(indexName = "dishes")' in d and '@Setting(settingPath = "dish-settings.json")' in d and '@Field(type = FieldType.Text, analyzer = "dish") String name' in d and "@Field(type = FieldType.Keyword) String mealType" in d and "@Field(type = FieldType.Integer) int price" in d and "@Id String id" in d,
       "Dish: the index dishes, the @Setting file, name text by dish, mealType keyword, price integer, a String id")
    st = json.loads(rd(A, R + "dish-settings.json"))
    ok(st["index"]["number_of_replicas"] == "0" and st["analysis"]["analyzer"]["dish"] == {"type": "custom", "tokenizer": "standard", "filter": ["lowercase", "veg_syn"]} and st["analysis"]["filter"]["veg_syn"] == {"type": "synonym", "synonyms": ["veg, vegetarian"]},
       "dish-settings.json: number_of_replicas 0; dish = standard tokenizer, lowercase, the synonym veg, vegetarian - one analyzer (no second in the anchor)")
    ok("List<Dish> findByName(String name);" in rd(A, W + "Dishes.java") and '@Profile("dev")' in rd(A, W + "DishSearch.java") and '@GetMapping("/dishes/search")' in rd(A, W + "DishSearch.java"), "Dishes.findByName; DishSearch GET /dishes/search under dev only")
    sv = rd(A, W + "TiffinBoxServer.java")
    ok("dishes.deleteAll();" in sv and "dishes.saveAll(copiesOfRows);" in sv and sv.index("copies.fill(copied);") < sv.index("dishes.deleteAll();") and "Course 8, unit 21:" in sv, "TiffinBoxServer: the re-index after the MongoDB fills - delete, then save all; a unit 21 Javadoc paragraph")
    it = rd(A, TS + "com/tiffinbox/web/ElasticsearchIT.java")
    ok(EIMG in it and 'bindIpAndPort("127.0.0.1", 20606)' in it and ".withExposedPorts(9200)" in it and '@ActiveProfiles("dev")' in it and all('"%s", "false"' % k in it for k in ("xpack.security.enabled", "xpack.ml.enabled", "ingest.geoip.downloader.enabled", "xpack.inference.elastic.authorization.enabled")) and '"ES_JAVA_OPTS", "-Xms512m -Xmx512m"' in it,
       "ElasticsearchIT: the digest, 127.0.0.1:20606 with 9200 the only port exposed (S8.94), under dev, the four settings + ES_JAVA_OPTS (Testcontainers sets discovery.type itself)")
    ok('bindIpAndPort("127.0.0.1", 20578)' in rd(A, TS + "com/tiffinbox/web/MongoDatastoreIT.java"), "MongoDatastoreIT keeps 127.0.0.1:20578")
    ok('"4 true");' in rd(A, TS + "com/tiffinbox/jdbc/CustomerAggregatesIT.java") and '"4 dish true");' in rd(A, TS + "com/tiffinbox/CustomerEntityRepositoryIT.java"), "the two ITs' migration lists: V1-V4")
    ok("@EnableElasticsearchRepositories(basePackageClasses = com.tiffinbox.web.Dishes.class)" in rd(A, TS + "slice/ElasticsearchSlice.java"), "slice/ElasticsearchSlice names Dishes' package")
    for f in ("pom.xml", "tiffinbox-core/pom.xml", W + "OrderDocument.java", W + "Revenue.java", W + "Menus.java", W + "MenuDay.java", "tiffinbox-web/src/test/java/slice/MongoSlice.java", R + "application-audit.yaml"):
        ok(rd(A, f) == rd(B, f), "the change leaves " + f + " as unit 20 shipped it")
    dl = rd("exercise", "DishLab.java")
    ok("import com.tiffinbox.web.Dish;" in dl and "20608" in dl and "V4__dish.sql" in dl and "veg_syn" not in dl and "synonym" not in dl.split("*/")[1], "exercise/DishLab.java: the shipped Dish, Elasticsearch on 20608, the rows from after/'s V4, no synonym of its own (the settings file is the argument)")
    ck = rd("exercise", "check.sh")
    ok("20608" in ck and "_mapping" in ck and "search_analyzer" in ck and "_analyze" in ck and '"match":{"name":"veg"}' in ck, "exercise/check.sh: the ids by match, the search-side analyzer by _mapping, its tokens by _analyze (RED #14)")
elif NAME == "r250":
    A, B = sys.argv[2], sys.argv[3]
    r = rd(A, "README.md")
    items = [
        ("the anchor README's jar-count chain 58 -> 56 -> 61 and \"one Jackson from there on\" (Course 6 unit 04's section) - noted (Course 8, unit 21: two Jacksons again, BOOT-INF/lib's count since)", "*(Course 8, unit 21, 2026-11-23: two Jacksons in the jar again" in r),
        ("tiffinbox-web/pom.xml's Course 6 comment \"Jackson 2's jackson-databind ... is gone\" - noted beside it", "(Course 8, unit 21: Jackson 2's" in rd(A, "tiffinbox-web/pom.xml")),
        ("README.md's unit 20 section \"`mvn verify` runs 18 + 11\" - noted (18 + 12)", "`mvn verify` runs 18 + 11 *(Course 8, unit 21: 18 + 12" in r),
        ("README.md's unit 19 section \"18 + 10 (Course 8, unit 20: 18 + 11 ...)\" - noted (18 + 12)", "test)* *(Course 8, unit 21: 18 + 12)*" in r),
        ("MongoDatastoreIT's Javadoc \"18 + 11\" - noted (18 + 12, ElasticsearchIT beside it)", "Course 8, unit 21:\n * 18 + 12 - ElasticsearchIT beside it." in rd(A, TS + "com/tiffinbox/web/MongoDatastoreIT.java")),
        ("README.md's unit 18 section, the exclude list's three names - noted (ten since)", "*(Course 8, unit 21: ten names since" in r),
        ("README.md's Part A closing \"Part B ... changes this folder next\" - noted (it has)", "changes this folder next. *(Course 8, unit 21: it has" in r),
        ("application.yaml's exclude comment - grown: the seven and the count, ten", "Ten names now, three MongoDB's and seven Elasticsearch's" in rd(A, R + "application.yaml")),
        ("application-dev.yaml's exclude comment - grown: the same empty list clears the seven", "Course 8, unit 21: the same empty list clears the seven" in rd(A, R + "application-dev.yaml")),
        ("compose.yaml's header \"MongoDB, the third\" - grown: Elasticsearch, the fourth", "Course 8, unit 21: and Elasticsearch, the fourth" in rd(A, "compose.yaml")),
        ("TiffinBoxServer's Javadoc - a unit 21 paragraph (the fifth and sixth providers, the re-index), the fills' list grown", "Course 8, unit 21: under \"dev\" the start also copies the dish rows" in rd(A, W + "TiffinBoxServer.java")),
        ("CustomerEntityRepositoryIT's Javadoc \"lists V1-V3\" - rewritten (V1-V4)", "history table lists V1-V4" in rd(A, TS + "com/tiffinbox/CustomerEntityRepositoryIT.java")),
        ("README.md's head \"Flyway's three migrations (V1-V3)\" - kept: it says what Course 7 left (the Course 8 notes beside it say what moved), and unit 21's section names V4", "Flyway's three\nmigrations (V1-V3)" in r or "three\nmigrations (V1-V3)" in r or "migrations (V1-V3)" in r),
    ]
    for t, c_ in items:
        ok(c_, "R.250: " + t)
    ok("## Course 8 · unit 21 — Full-Text Search: The Analyzer Explained" in r and "unit 22 adds the write path next" in r and "**Section 4's anchor now holds**" in r, "the anchor README: its unit 21 section, the Part B opening sentence and unit 22's hand-off")
elif NAME == "wib":
    L = raw(sys.argv[2]); f = sys.argv[3]
    i = next(k for k, l in enumerate(L) if l.startswith("in bash "))
    j = next(k for k, l in enumerate(L) if k > i and l.startswith("  then the solution's lines"))
    e = next(k for k, l in enumerate(L) if k > j and l.startswith("  the shell is now in"))
    part = L[i + 1:j] if f.endswith("README.md") else L[j + 1:e]
    print("\n".join(l[4:] for l in part))
    sys.exit(0)
elif NAME == "numbers":
    caps = [a for a in sys.argv[2:] if a.startswith(".r-")]; prose = [a for a in sys.argv[2:] if not a.startswith(".r-")]
    L = [l for c in caps for l in raw(c)]
    WAY = {"prefix": r"(?:dishes \(standard\): )?prefix name veg -> ", "match": r"curl on 20605: match name veg -> ", "fuzziness": r"match name veg fuzziness 2 -> ", "synonym": r"dishes_syn.*\n?.*match name veg -> "}
    NUMW = {"zero": 0, "one": 1, "two": 2, "three": 3, "four": 4, "five": 5}
    meas = {}
    _, meas["prefix"] = hit(L, r"prefix name veg -> ", "the prefix's ids (nohit)")
    _, meas["fuzziness"] = hit(L, r"match name veg fuzziness 2 -> ", "fuzziness 2's ids (fuzzy)")
    _, meas["match"] = hit(L, r"curl on 20605: match name veg -> ", "veg on the standard copy (nohit)")

    def judge(sent):
        s = sent.lower()
        m = re.search(r"\b(?:a|the) (prefix|match|fuzziness)\b[^.;]*?\bfinds (zero|one|two|three|four|five)\b(?:[^.;]*?\b(zero|one|two|three|four|five|none) of them (?:the |is the |are )?vegan)?", s)
        if not m: return None
        i = meas.get(m.group(1), [])
        n = NUMW[m.group(2)]; v = None if not m.group(3) else NUMW.get(m.group(3), 0)
        good = n == len(i) and (v is None or v == len(vegan(i)))
        return (m.group(1), n, v, len(i), len(vegan(i)), good)
    # shown failing first (S8.95): the plant must fail, the brief's line pass
    pl = judge("Your turn: veg finds zero dishes, and a prefix finds four, two of them vegan.")
    ok(pl is not None and pl[5] is False, "S8.95's self-test: the plant \"a prefix finds four, two of them vegan\" FAILS against the capture (%s)" % (pl,))
    gd = judge("Your turn: veg finds zero dishes, and a prefix finds four, one of them the vegan box.")
    ok(gd is not None and gd[5] is True, "S8.95's self-test: the brief's \"a prefix finds four, one of them the vegan box\" passes (%s)" % (gd,))
    n = 0
    for p in prose:
        for k, l in enumerate(raw(p), 1):
            for s in re.split(r"(?<=[.;!?])\s+", l):
                j = judge(s)
                if j is None: continue
                n += 1
                ok(j[5], "S8.95: %s line %d - the %s finds %d%s; the capture: %d ids, %d vegan" % (p, k, j[0], j[1], "" if j[2] is None else ", %d of them vegan" % j[2], j[3], j[4]))
    VALUES.append("S8.95: %d sentences with a count, each = its capture's ids and V4's meal types" % n)
elif NAME == "exercise":
    L = raw(sys.argv[2]); T = "\n".join(L)
    for sh in ("bash", "zsh"):
        part = T.split("in " + sh + " (")[1].split("the shell is now in")[0]
        rp, sp = part.split("then the solution's lines")
        ok("built: 1 jar" in rp and "index dishes before: absent · settings dish-settings-standard.json" in rp and "index dishes before: absent · settings dish-settings.json" in sp, sh + ": each half on a fresh container - the index absent before each (S8.76's class)")
        a = re.search(r"dishes indexed: (\d+) of (\d+) rows", rp); b = re.search(r"dishes indexed: (\d+) of (\d+) rows", sp)
        ok(a and b and a.group(1) == a.group(2) == b.group(1) == str(len(V4)), sh + ": the ten rows indexed, both halves (V4's count)")
        m1 = re.search(r"match name veg: " + HIT, rp); c1 = re.search(r"check: match name veg -> " + HIT + r" · name's search-side analyzer: (\w+) · its tokens for vegetarian: \[([^]]*)\] · solved: (\w+)", rp)
        m2 = re.search(r"match name veg: " + HIT, sp); c2 = re.search(r"check: match name veg -> " + HIT + r" · name's search-side analyzer: (\w+) · its tokens for vegetarian: \[([^]]*)\] · solved: (\w+)", sp)
        ok(m1 and c1 and ids(m1) == [] and c1.group(2) == "" and "veg" not in c1.group(4).split(", ") and c1.group(5) == "no", sh + ": broken - veg 0 by the program and by curl, the analyzer's tokens hold no veg, solved: no")
        ok(m2 and c2 and ids(m2) == ["1"] and c2.group(2) == "1" and "veg" in c2.group(4).split(", ") and c2.group(5) == "yes" and DNAME["1"] == "Vegetarian Lunch Box", sh + ": solved - veg [1] (the vegetarian box) by the program and by curl, veg among the tokens, solved: yes")
        p1 = re.search(r"prefix name veg: " + HIT, rp)
        ok(p1 and int(p1.group(1)) == len(ids(p1)) and len(vegan(ids(p1))) == 1, sh + ": the prefix finds %s, one of them vegan (V4's meal types)" % (p1.group(1) if p1 else "?"))
    ok(T.count("the block's exit 0") == 4, "the four blocks exit 0 (the exit is not the judge - the check is)")
    ok(len(re.findall(r"listening on 20608 afterwards: 0 · the container c8u21-es-ex afterwards: 0", T)) == 2, "the exercise's container removed, 20608 free, after each shell")
    ok(len(re.findall(r"images afterwards: (\w+) \(at the start: \1\)", T)) == 2, "the images unchanged after each shell (the tag was present: nothing pulled)")
    ok(sys.argv[3] == "24" and sys.argv[4].startswith("Your turn: veg finds zero dishes"), "the spoken line: 24 words (wc -w)")
    VALUES.append("the exercise: broken (the standard analyzer's steps) veg 0, prefix 4 with one vegan; solved (the shipped dish-settings.json) veg [1] - by the program and by check.sh, bash and zsh")
elif NAME == "image":
    L = raw(sys.argv[2]); T = "\n".join(L)
    ok(one(L, r"RepoDigests \[\"" + re.escape(EIMG) + r"\"\]") is not None, "the image by its digest")
    ok(one(L, r"its declared volumes \(Config\.Volumes\): 0 \[\]$") is not None, "0 declared volumes")
    m = one(L, r"GET /_nodes/jvm \(curl, 127\.0\.0\.1\) -> version (\d+) · mem\.heap_max_in_bytes (\d+)")
    d = int(m.group(2)) if m else 0
    ok(d > HEAP, "the image's default heap (%d) is larger than the pinned one" % d)
    v = every(L, r"volumes with it alive: (\d+) \(before it: (\d+)\)")
    ok(len(v) == 1 and v[0].group(1) == v[0].group(2), "the default container adds no volume")
    m2 = one(L, r"^  GET /_nodes/jvm -> version (\d+) · vm_vendor [^·]+ · mem\.heap_max_in_bytes (\d+)")
    ok(m2 and int(m2.group(2)) == HEAP, "the unit's container: heap_max_in_bytes = compose.yaml's -Xmx (%d)" % HEAP)
    g = one(L, r"version\.number (\S+) · build_flavor (\S+) · lucene_version (\S+)")
    ok(g and g.group(1) == "9.4.8" and re.search(r"elasticsearch-java-9\.4\.8|9\.4\.8", rd("after", "compose.yaml")) is not None, "GET / version.number = the tag compose.yaml names (9.4.8)")
    vv = one(L, r"Mounts: none · volumes (\d+) \(before it: (\d+)\)")
    ok(vv and vv.group(1) == vv.group(2), "the unit's Elasticsearch: no Mounts, the volume count unchanged")
    cs = one(L, r"read back\): discovery\.type single-node · xpack\.security\.enabled false · xpack\.ml\.enabled false · ingest\.geoip\.downloader\.enabled false · xpack\.inference\.elastic\.authorization\.enabled false")
    ok(cs is not None, "the five settings read back by _cluster/settings")
    mm = one(L, r"/proc/sys/vm/max_map_count (\d+)")
    ok(one(L, r"'Security is disabled' [1-9]\d* · 'Starting authorization task executor' 0 · the ML controller \('controller \(64 bit\)'\) 0 · 'bound or publishing to a non-loopback address' 0") is not None, "the log: Security is disabled; no executor start; no controller; no bootstrap-check line")
    ok(one(L, r"curl -i GET /: status 200 · .* · a Warning header: 0$") is not None, "200 with no credentials, no Warning header")
    ok(one(L, r"/proc/net/dev's interfaces eth0,lo$") is not None, "the interfaces: eth0, lo")
    ok(one(L, r"Docker's port list for c8u21-es \(dk port\) -> 9200/tcp -> 127\.0\.0\.1:20604 · ") is not None, "published on 127.0.0.1:20604 alone, 9300 not published")
    VALUES.append("image: version.number %s, JDK %s, 0 declared volumes, max_map_count %s, the default heap %d (the image's default on this VM) and the pinned %d, the six settings read back, Security is disabled, no executor start, no controller" % (g.group(1) if g else "?", m2.group(1) if m2 else "?", mm.group(1) if mm else "?", d, int(m2.group(2)) if m2 else 0))
elif NAME == "anchor":
    L = raw(sys.argv[2]); T = "\n".join(L)
    ok(one(L, r"^  exit 0 · BUILD SUCCESS · offline: yes") is not None, "the builds: exit 0, offline")
    rl = every(L, r"Surefire's Results line: Tests run: (\d+), Failures: 0, Errors: 0, Skipped: 0$")
    ok(len(rl) >= 3 and rl[0].group(1) == "18", "mvn package: Tests run: 18 (Docker at nothing)")
    nit = sum(len(re.findall(r"^    @Test$", open(os.path.join(dp, f), encoding="utf-8").read(), re.M)) for dp, ds, fs in os.walk("after/tiffinbox-web/src/test/java") for f in fs if f.endswith("IT.java"))
    ok(len(rl) == 3 and rl[1].group(1) == "18" and int(rl[2].group(1)) == nit, "mvn verify: Tests run: 18, then the container tests' %s = the ITs' @Test methods in after/ (%d)" % (rl[2].group(1) if len(rl) > 2 else "?", nit))
    ok(one(L, r"Elasticsearch IT's container while verify ran, Docker's own list \(dk ps, polled on a count\): Ports (?:9300/tcp, )?127\.0\.0\.1:20606->9200/tcp · listening on 20606 after it: 0$") is not None, "the IT's container: 127.0.0.1:20606->9200/tcp (9300 exposed by the image, unpublished), never 0.0.0.0 (S8.94)")
    ok(one(L, r"Mongo IT's container while verify ran: Ports 127\.0\.0\.1:20578->27017/tcp · listening on 20578 after it: 0$") is not None, "the Mongo IT's container: 127.0.0.1:20578->27017/tcp")
    ok(one(L, r"ES IT heap_max_in_bytes \(the client's nodes info, jvm\): (\d+)$") and int(one(L, r"ES IT heap_max_in_bytes \(the client's nodes info, jvm\): (\d+)$").group(1)) == HEAP, "the IT's heap = compose.yaml's -Xmx")
    ok(one(L, r"ES IT Dishes\.findByName\(\"veg\"\) of three saved: \[Vegetarian Lunch Box\]$") is not None and one(L, r"ES IT _analyze on dishes, analyzer dish, \"Vegetarian Lunch Box\" \(the client's\): \[vegetarian, veg, lunch, box\]$") is not None, "the IT: veg finds the vegetarian dish alone; the client's _analyze holds veg")
    libs = every(L, r"^  (before|after)/: (\d+) libraries$")
    ok(len(libs) == 2, "the two jars' library counts")
    if len(libs) == 2:
        ok(("The jar's\n  `BOOT-INF/lib` holds %s since" % libs[1].group(2)) in rd("after", "README.md"), "the anchor README's jar-count note = after/'s jar (%s)" % libs[1].group(2))
    ok(one(L, r"the Jackson jars in after/'s lib: .*jackson-databind-2\.21\.7\.jar.*jackson-databind-3\.") is not None, "Jackson 2's jackson-databind 2.21.7 back, beside Jackson 3's")
    ok(one(L, r"Spring MVC's JSON converters, by their beans' types: .*JacksonJsonHttpMessageConverter") is not None and "MappingJackson2HttpMessageConverter" not in T, "Spring MVC's JSON converter is Jackson 3's (JacksonJsonHttpMessageConverter); no Jackson 2 converter bean")
    ok(one(L, r"\(x1\) Successfully applied 4 migrations$") is not None, "Flyway: 4 migrations")
    rx = every(L, r"dishes re-indexed: rows (\d+) · documents before (\d+) · documents after (\d+)")
    ok(len(rx) >= 3 and rx[0].group(1) == rx[0].group(3) == str(len(V4)) and rx[0].group(2) == "0" and rx[1].group(2) == rx[1].group(3) == str(len(V4)), "the re-index: rows 10 -> documents 10 (first start: before 0; second: before 10, after 10; Compose's too)")
    ok(one(L, r"select count\(\*\) from dish -> %d · " % len(V4)) is not None, "psql: the ten rows")
    ok(one(L, r"_cat/indices dishes -> dishes green open 1 0 %d$" % len(V4)) is not None, "_cat/indices: dishes green, 1 primary, 0 replicas, 10 documents")
    ok(one(L, r"_mapping -> .*_class \{\"doc_values\": false, \"index\": false, \"type\": \"keyword\"\} · id \{.*\"type\": \"text\"\} · mealType \{\"type\": \"keyword\"\} · name \{\"analyzer\": \"dish\", \"type\": \"text\"\} · price \{\"type\": \"integer\"\}$") is not None, "_mapping: _class, the dynamic id, mealType keyword, name text by dish, price integer")
    t = one(L, r"POST /dishes/_analyze \{analyzer dish, \"Vegetarian Lunch Box\"\} -> (\d+) \[([^]]*)\]$")
    ok(t and t.group(2) == "vegetarian, veg, lunch, box" and int(t.group(1)) == 4, "_analyze dish: 4 tokens [vegetarian, veg, lunch, box]")
    c1, i1 = hit(L, r"POST /dishes/_search match name veg -> ", "curl: match veg on the shipped index")
    m = one(L, r"GET /dishes/search\?q=veg \(TiffinBox\) -> 200 (\[.*?\]) · q=vegetarian -> 200 (\[.*?\])$")
    jv = [h["id"] for h in json.loads(m.group(1))] if m else None
    ok(m and jv == i1 == ["1"] and json.loads(m.group(1))[0]["name"] == DNAME["1"], "veg: [1] the vegetarian box by both witnesses (TiffinBox's route and curl's _search)")
    ok(m and [h["id"] for h in json.loads(m.group(2))] == ["1"], "vegetarian: [1] by TiffinBox")
    ok(len(every(L, r"curl -iX POST '<es>/dishes/_search\?search_type=query_then_fetch&typed_keys=true' -d '.*\"query_string\":\{\"default_operator\":\"and\",\"fields\":\[\"name\"\],\"query\":\"veg\"\}")) == 2, "the finder sent query_string on name, twice (the count, then the page)")
    ok(one(L, r"\(x1\) PUT <es>/dishes$") is not None and one(L, r"\(x1\) POST <es>/dishes/_delete_by_query$") is not None and one(L, r"\(x1\) POST <es>/_bulk$") is not None, "the client's requests: PUT /dishes (the index created at the start), the delete, one bulk")
    ok(one(L, r"the bulk request's action lines \(index, one per document\): %d · refresh=false on the bulk: 1 · then POST /dishes/_refresh: 1$" % len(V4)) is not None, "the bulk: ten index actions, refresh=false, then the repository's own _refresh")
    ok(one(L, r"the index creation, as the client sent it \(PUT /dishes, the body whole\): .*\"name\":\{\"type\":\"text\",\"analyzer\":\"dish\"\}.*veg_syn") is not None, "PUT /dishes carries the @Setting analyzer and the mapping")
    ok(one(L, r"GET /revenue/by-customer -> 200 ") is not None and one(L, r"GET /menu/day-19 -> 200 ") is not None and one(L, r"GET /kitchen -> 200 ") is not None, "Part A's routes unchanged: /revenue/by-customer, /menu/day-19, /kitchen 200")
    ok(one(L, r"the hosts the client's requests went to \(its trace logger\): 127\.0\.0\.1:18884 · the Compose service's own published port \(dk port\): 9200/tcp -> 127\.0\.0\.1:18884$") is not None, "Compose: every request to 127.0.0.1:18884 - Boot's factory handed that address")
    ok(one(L, r"curl on 18884 \(the elasticsearch service\): _cat/indices dishes -> dishes green open 1 0 %d · match name veg -> 1 \[1\]$" % len(V4)) is not None, "Compose: dishes green 10, veg [1] on 18884")
    ok(one(L, r"the elasticsearch service's container: its Mounts: none · ") is not None, "Compose: the elasticsearch service holds no volume")
    ok(one(L, r"the receipt removes the mongo service's two .* = before the window · listening on 18881-18884: 0$") is not None, "the Compose window's volumes back; 18881-18884 free")
    sc = one(L, r"of them \"Could not safely identify\": (\d+) · naming Dishes: (\d+) - by module: (.*)$")
    hv = one(L, r"HHH000001: Hibernate ORM core version (\S+)")
    VALUES.append("anchor: Flyway 4, the re-index rows %d -> documents %d (a second start: before %d, after %d), dishes green %d, _analyze dish 4 [vegetarian, veg, lunch, box], veg [1] by TiffinBox and curl, the finder's query_string, strict mode %s \"could not safely identify\" lines (%s naming Dishes: %s), Compose on 18884, 18 + %s, the IT 127.0.0.1:20606 and the Mongo IT 127.0.0.1:20578, the 18 without Docker, %s libraries (before %s), Jackson 2 back beside Jackson 3, HHH000001 %s"
                  % (len(V4), len(V4), len(V4), len(V4), len(V4), sc.group(1) if sc else "?", sc.group(2) if sc else "?", sc.group(3) if sc else "?", rl[2].group(1) if len(rl) > 2 else "?", libs[1].group(2) if len(libs) == 2 else "?", libs[0].group(2) if len(libs) == 2 else "?", hv.group(1) if hv else "?"))
elif NAME == "tokens":
    L = raw(sys.argv[2])
    a = one(L, r"\{analyzer standard, \"Vegetarian Lunch Box\"\} -> (\d+) \[([^]]*)\]$"); b = one(L, r"/dishes/_analyze \{analyzer dish, \"Vegetarian Lunch Box\"\} -> (\d+) \[([^]]*)\]$")
    ok(a and a.group(2) == "vegetarian, lunch, box" and int(a.group(1)) == 3, "standard: 3 tokens [vegetarian, lunch, box]")
    ok(b and b.group(2) == "vegetarian, veg, lunch, box", "dish: [vegetarian, veg, lunch, box]")
    t0, i0 = hit(L, r"term name \(text\) \"Vegetarian Lunch Box\" -> ", "term on the text field, the whole name")
    ok(t0 == 0, "term on name (text), the whole name: 0 - the index holds tokens, not the name")
    tv, iv = hit(L, r"term mealType \(keyword\) \"VEG\" -> ", "term on the keyword field, VEG")
    ok(iv == sorted(k for k, t in TYPE.items() if t == "VEG"), "term mealType VEG: the VEG rows of V4 (%s)" % iv)
    t2, _ = hit(L, r"term mealType \"veg\" -> ", "term on the keyword field, veg")
    ok(t2 == 0, "term mealType veg: 0 - a keyword is one token, as written")
    ok(one(L, r"the Java side, the same run: ES IT _analyze on dishes, analyzer dish, \"Vegetarian Lunch Box\" \(the client's\): \[vegetarian, veg, lunch, box\]$") is not None, "the Java side: the IT's _analyze, the same tokens")
    VALUES.append("tokens: standard 3 [vegetarian, lunch, box], dish 4 [vegetarian, veg, lunch, box]; term on the text field 0; term mealType VEG %d %s, veg 0" % (tv or 0, iv))
elif NAME == "nohit":
    L = raw(sys.argv[2])
    m = one(L, r"GET /dishes/search\?q=veg \(the copy's TiffinBox\) -> 200 \[\] · its JVM still running: yes · lines naming an Exception in its log: 0$")
    ok(m is not None, "the copy's route: veg -> 200 [], no exception, the JVM running (R.312's negation)")
    c0, i0 = hit(L, r"curl on 20605: match name veg -> ", "curl on the copy: veg")
    ok(c0 == 0 and one(L, r"curl's exit 0$") is not None, "curl on the copy: veg 0 [], curl's exit 0")
    c1 = one(L, r"GET /dishes/search\?q=vegetarian \(the control, the same JVM\) -> 200 (\[.*\])$")
    ok(c1 and [h["id"] for h in json.loads(c1.group(1))] == ["1"], "the control: vegetarian [1] by the copy's route")
    cv, iv = hit(L, r"curl on 20605: match name vegetarian -> ", "curl on the copy: vegetarian")
    ok(iv == ["1"], "curl on the copy: vegetarian [1]")
    cp, ip = hit(L, r"curl on 20605: prefix name veg -> ", "curl on the copy: prefix veg")
    ok(len(vegan(ip)) == 1 and "1" in ip, "the prefix: %d ids, one of them vegan (V4's meal types), the vegetarian box among them" % len(ip))
    cs, is_ = hit(L, r"the shipped analyzer, the same run - curl on 20604: match name veg -> ", "the shipped analyzer: veg")
    ok(is_ == ["1"], "the shipped analyzer, the same run: veg [1]")
    ok(one(L, r"_analyze \{analyzer dish, \"Vegetarian Lunch Box\"\} -> 3 \[vegetarian, lunch, box\] · beside _analyze \{analyzer standard\} -> 3 \[vegetarian, lunch, box\]$") is not None, "the copy's dish = the standard analyzer's tokens")
    ok(one(L, r"the hosts its client's requests went to: 127\.0\.0\.1:20605$") is not None, "the copy's client went to 20605 alone")
    VALUES.append("nohit (a copy with the standard analyzer): veg 0 [] by the copy's route and curl, no exception; vegetarian 1 [1]; prefix %d %s (%d vegan: %s); the shipped analyzer 1 [1]" % (cp or 0, ip, len(vegan(ip)), ", ".join(vegan(ip))))
elif NAME == "sayso":
    L = raw(sys.argv[2])
    cp, ip = hit(L, r"dishes \(standard\): prefix name veg -> ", "prefix")
    cq, iq = hit(L, r"match_phrase_prefix name veg -> ", "match_phrase_prefix")
    cw, iw = hit(L, r"wildcard name veg\* -> ", "wildcard veg*")
    ca, ia = hit(L, r"match name veg fuzziness AUTO -> ", "fuzziness AUTO")
    ok(ip == iq == iw and len(vegan(ip)) == 1, "prefix = match_phrase_prefix = wildcard: %s, one vegan" % ip)
    ok(ca == 0, "fuzziness AUTO: 0")
    en = one(L, r"\{analyzer english, \"vegetarian vegetable vegan veg\"\} -> (\d+) \[([^]]*)\] · match name veg -> " + HIT)
    ok(en and en.group(2).split(", ")[0] == "vegetarian" and en.group(2).split(", ")[3] == "veg" and en.group(4) == "", "english: vegetarian kept whole, veg 0")
    ng = one(L, r"\{analyzer autocomplete, \"Vegetarian\"\} -> (\d+) \[([^]]*)\] · match name veg -> " + HIT)
    ok(ng and int(ng.group(1)) == len(ng.group(2).split(", ")) and [x.strip() for x in ng.group(4).split(",")] == ip, "edge_ngram: its tokens counted; veg finds the prefix's ids")
    sy = one(L, r"dishes_syn.*|^    _analyze \{analyzer dish, \"Vegetarian Lunch Box\"\} -> (\d+) \[([^]]*)\] · match name veg -> " + HIT)
    sy = every(L, r"^    _analyze \{analyzer dish, \"Vegetarian Lunch Box\"\} -> (\d+) \[([^]]*)\] · match name veg -> " + HIT)
    ok(len(sy) == 1 and sy[0].group(2) == "vegetarian, veg, lunch, box" and sy[0].group(4) == "1", "the synonym (the shipped settings file): 4 tokens, veg [1]")
    ok(one(L, r"_cat/indices on 20605 .*dishes green open 1 0 10.*dishes_default yellow open 1 1 0.*dishes_en green open 1 0 10.*dishes_ngram green open 1 0 10.*dishes_syn green open 1 0 10") is not None, "yellow with the default replica on one node, green with number_of_replicas 0")
    ok(len(every(L, r"DELETE /dishes_[a-z]+ -> acknowledged true$")) == 4 and one(L, r"_cluster/health on 20605 after: status green") is not None, "every scratch index removed; green after")
    VALUES.append("sayso: prefix / match_phrase_prefix / wildcard %d %s (also the vegan box); fuzziness AUTO 0; english [%s], veg 0; edge_ngram %s tokens, veg %s; the synonym 4 tokens, veg 1 [1]; yellow with a replica, green with 0" % (cp or 0, ip, en.group(2) if en else "?", ng.group(1) if ng else "?", ng.group(3) if ng else "?"))
elif NAME == "fuzzy":
    L = raw(sys.argv[2]); S = raw(sys.argv[3])
    c2, i2 = hit(L, r"match name veg fuzziness 2 -> ", "fuzziness 2")
    ok("1" not in i2 and len(vegan(i2)) == 1 and any(TYPE[x] == "NON_VEG" for x in i2), "fuzziness 2: %s - never the vegetarian box; the vegan box and a non-veg dish" % i2)
    ca, _ = hit(L, r"match name veg fuzziness AUTO -> ", "fuzziness AUTO")
    sa = [m for m in every(S, r"match name veg fuzziness AUTO -> " + HIT)]
    ok(ca == 0 and len(sa) == 1 and sa[0].group(1) == "0", "fuzziness AUTO: 0 here and in sayso's capture (the same line)")
    cs, is_ = hit(L, r"the shipped analyzer \(20604, dishes\): match name veg -> ", "the shipped analyzer")
    ok(is_ == ["1"], "the shipped analyzer: [1]")
    VALUES.append("fuzzy: fuzziness 2 -> %d %s (%s), never the vegetarian box; AUTO 0; the shipped analyzer 1 [1]" % (c2 or 0, i2, " · ".join(DNAME[x] for x in i2)))
elif NAME == "late":
    L = raw(sys.argv[2])
    ok(one(L, r"match name veg -> 0 \[\]$") is not None, "before the synonym: veg 0")
    r = one(L, r"\{name: text, analyzer dish\} -> error illegal_argument_exception: (Mapper for \[name\] conflicts with existing mapper: Cannot update parameter \[analyzer\] from \[default\] to \[dish\]) · curl's exit 0 · its HTTP status 400$")
    ok(r is not None, "the refusal quoted whole, HTTP 400, curl's exit 0 (R.312)")
    ok(one(L, r"\{name: text, search_analyzer dish\} -> acknowledged true$") is not None and one(L, r"name -> \{\"analyzer\": \"default\", \"search_analyzer\": \"dish\", \"type\": \"text\"\}$") is not None, "the search_analyzer accepted; _mapping shows it")
    c, i = hit(L, r"match name veg, no document indexed again -> ", "veg after the search_analyzer")
    ok(i == ["1"], "veg [1] with no re-index")
    VALUES.append("late: \"%s\" (400); search_analyzer dish acknowledged, veg 1 [1] with no re-index" % (r.group(1) if r else "?"))
elif NAME == "explain":
    L = raw(sys.argv[2])
    ok(one(L, r"^  matched true$") is not None, "matched")
    top = one(L, r"^  ([0-9.]+) weight\((?:Synonym\()?[^)]*name:vegetarian[^)]*\)? in \d+\)")
    f = {k: one(L, r"^      ([0-9.]+) " + k) for k in ("boost", "idf,", "tf,")}
    ok(top and all(f.values()), "the score and its three factors read off _explain")
    if top and all(f.values()):
        p = float(f["boost"].group(1)) * float(f["idf,"].group(1)) * float(f["tf,"].group(1))
        ok(abs(p - float(top.group(1))) < 1e-4, "boost x idf x tf = the score (%.6f vs %s)" % (p, top.group(1)))
        VALUES.append("explain: the vegetarian box for vegetarian, score %s = boost %s x idf %s x tf %s" % (top.group(1), f["boost"].group(1), f["idf,"].group(1), f["tf,"].group(1)))
elif NAME == "default":
    L = raw(sys.argv[2])
    ok(one(L, r"^  GET /actuator/health -> 200 ") is not None, "health 200 with no Elasticsearch")
    ok(one(L, r"GET /dishes/search\?q=veg -> 404 · GET /revenue/by-customer -> 404 · GET /menu/day-19 -> 404 · GET /revenue -> 200 \{\"monthRevenue\":\d+\} · GET /kitchen -> 200 \{.*\"ordersValue\":\d+.*\} · GET /dashboard -> 200$") is not None, "/dishes/search 404, /revenue/by-customer 404, /menu/day-19 404, /revenue 200, /kitchen 200, /dashboard 200")
    ok(one(L, r"dishes 0 · dishSearch 0 · elasticsearchClient 0 · a bean whose type names Elasticsearch 0 · dishEntityRepository 1 · tiffinBoxServer 1$") is not None, "/actuator/beans: no Dishes, DishSearch or Elasticsearch bean; the rows' repository there")
    ok(one(L, r"its log: lines naming 9200 0 · naming elasticsearch, any case 0 · naming 27017 0 · naming mongo, any case 0 · Flyway: Successfully applied 4 migrations on Database: jdbc:h2:mem:<name> \(H2 ") is not None, "the log: 0 lines naming 9200, elasticsearch, 27017 or mongo; Flyway 4 on H2")
    hx = one(L, r"^  readiness never answered 200 · the JVM's exit 1 · listening on 20600: 0$")
    hl = one(L, r"^  its log: lines naming 9200 (\d+) · naming elasticsearch, any case (\d+) · its repository lines naming Elasticsearch: (.*)$")
    hc = one(L, r"DataAccessResourceFailureException: Connect to http://localhost:9200 .*Connection refused")
    ok(hx is not None and hc is not None and one(L, r"Error creating bean with name 'dishes'$") is not None, "the health key alone (the copy healthkey): the default run stops, exit 1 - Dishes' constructor reaches localhost:9200, Connection refused (the refused shape)")
    ok(hl and int(hl.group(1)) > 0 and int(hl.group(2)) > 0 and "Found 1 Elasticsearch repository interface" in hl.group(3), "the health key alone: its log names 9200 and Elasticsearch; the Elasticsearch repository scan found Dishes")
    ok(len(every(L, r"Surefire's Results line: Tests run: 18, Failures: 0, Errors: 0, Skipped: 0$")) == 1, "the 18 under mvn -o package, Docker at nothing")
    VALUES.append("default: health 200, /dishes/search 404, /revenue/by-customer 404, /menu/day-19 404, /revenue 200, /kitchen 200, 0 lines naming 9200 or elasticsearch, 0 naming 27017 or mongo, no Elasticsearch bean, Flyway 4 on H2; the health key alone (a labelled copy): exit 1, Dishes' constructor refused at localhost:9200; the 18 without Docker")
elif NAME == "absent":
    L = raw(sys.argv[2])
    ok(one(L, r"readiness never answered 200 · the JVM's exit 1 · listening on 20600: 0$") is not None, "exit 1, nothing listening")
    ok(one(L, r"DataAccessResourceFailureException: Connect to http://127\.0\.0\.1:20609 .*Connection refused") is not None, "the client's exception: Connect to http://127.0.0.1:20609 ... Connection refused")
    ok(one(L, r"Error creating bean with name 'dishes'") is not None, "the bean named: dishes")
    ok(one(L, r"the hosts its client tried \(Connect to \.\.\.\): Connect to http://127\.0\.0\.1:20609 · 'dishes re-indexed' 0 · ") is not None, "one URI tried, no re-index")
    VALUES.append("absent: exit 1, Error creating bean with name 'dishes', DataAccessResourceFailureException: Connect to <the URI> ... Connection refused")
elif NAME == "seven":
    L = raw(sys.argv[2]); want = sys.argv[3]
    hs = every(L, r"the seven responses: 7 lines · md5 ([0-9a-f]{32})")
    ok(len(hs) == 2 and hs[0].group(1) == hs[1].group(1) == want, "the seven on before/ and after/: md5 = Course 7's %s" % want)
    ok(one(L, r"lines that differ: 0$") is not None, "before/ against after/: 0 lines differ")
    VALUES.append("the seven: md5 %s on before/ and after/" % want)
elif NAME == "sockets":
    L = raw(sys.argv[2])
    ok(one(L, r"its interfaces \(/proc/net/dev\): eth0,lo$") is not None, "interfaces: eth0, lo")
    s = one(L, r"listening \(TCP\) on 9200, 9300 · connections from another local port \(outbound\): 0 · UDP sockets: 0$")
    ok(s is not None, "listening on 9200 and 9300 inside; 0 outbound; 0 UDP")
    VALUES.append("sockets: no outbound TCP or UDP socket in the samples (listening 9200, 9300; interfaces eth0, lo)")
else:
    print("FAIL no check named " + NAME); sys.exit(1)
for m in oks: print("ok " + m)
for m in fails: print("FAIL " + m)
if VALUES: print("VALUES " + "; ".join(VALUES))
sys.exit(1 if fails else 0)
