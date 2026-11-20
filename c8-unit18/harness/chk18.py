"""Unit 18's checks (python3 -I -B harness/chk18.py NAME ARGS...). Each capture's numbers are asserted against a second witness of the
same run - never a typed figure (R.423): Java's answers (TiffinBox's routes under "dev", the harness's MongoTemplate - findById, the
rename's UpdateResult, the null id's String -, the IT's lines) against mongosh's view in a container with no network (printjson of the
stored document, its keys, _class and the _id's type; system.profile's ops; countDocuments; listDatabases) and the driver's own DEBUG
line naming the database; PostgreSQL's own statement log between two markers beside psql's rows (the harness's tables); Docker's own
records (exit codes, Mounts, the volume count, the IT container's Ports); Surefire's XML against Maven's Results lines; the seven's md5
against Course 7's. Prints ok/FAIL lines and one VALUES line; exits 1 on any FAIL.
  static AFTER BEFORE   the change itself, read off the files (D1), and the harness's own rules (R.421-R.436 where a file shows them)
  r250 AFTER BEFORE     the sentences D1 made incomplete: rewritten or noted beside them, each listed
  c815 README LEDGER    C8-15's sentence in README.md byte for byte, its md5 derived; the ledger's row holds it (when the ledger is there)
  wib CAPTURE FILE      the lines the exercise's block printed for FILE (bash's), for receipts.sh to compare with "What it prints"
  exercise|image|anchor|document|oneread|rename|absent|default|twice|seven CAPTURE [...]"""
import difflib, hashlib, json, os, re, sys

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


def num(m, g=1):
    return int(m.group(g)) if m else None


def days(tree="after"):
    m = re.search(r"^  days: (\d+)$", rd(tree, "tiffinbox-web/src/main/resources/application.yaml"), re.M)
    return int(m.group(1))


def slice_of(src, start, end_rx):
    i = src.index(start)
    m = re.compile(end_rx, re.M).search(src, i + len(start))
    return src[i:m.end()]


W = "tiffinbox-web/src/main/java/com/tiffinbox/web/"
C815 = ("Two of its sections are called Redis as a datastore, and Document and search, and the second of those opens with MongoDB, "
        "Documents, Not Rows. That's where not everything is a relation, named here and not measured.")
MIMG = "mongo@sha256:05b334b0a7a78fe913caac0cd2e1ecccf4da515d9a3a44be911b6ea3734c17cd"
EXCL = ["org.springframework.boot.mongodb.autoconfigure.MongoAutoConfiguration",
        "org.springframework.boot.data.mongodb.autoconfigure.DataMongoAutoConfiguration",
        "org.springframework.boot.data.mongodb.autoconfigure.DataMongoRepositoriesAutoConfiguration"]

if NAME == "static":
    A, B = sys.argv[2], sys.argv[3]
    s7, s8 = rd("..", "c8-unit17/harness/s817.py"), rd("harness", "s818.py")
    for nm, st, en in (("XFAM_S2", "XFAM_S2 = {\n", r"^}\n"), ("XFAM_S3 (s817's def s3)", "def s3(s, raw):\n", r"^    return out\n")):
        a, b = slice_of(s7, st, en), slice_of(s8, st, en)
        ok(a == b, "%s: s818.py's slice is s817.py's byte for byte (md5 %s)" % (nm, hashlib.md5(b.encode()).hexdigest()))
    y = rd(A, "tiffinbox-web/src/main/resources/application.yaml")
    ex = re.search(r"^  autoconfigure:\n    exclude:\n((?:      - \S+\n)+)", y, re.M)
    ok(ex is not None and [l.strip()[2:] for l in ex.group(1).splitlines()] == EXCL, "application.yaml: spring.autoconfigure.exclude lists the three classes, in Boot's jar's names")
    ok("management.health.mongo.enabled" not in y and "mongodb:\n      enabled" not in y, "application.yaml: no health key for MongoDB (the dead name is never written - R.425)")
    yd = rd(A, "tiffinbox-web/src/main/resources/application-dev.yaml")
    ok(re.search(r'^  autoconfigure:\n    exclude: ""$', yd, re.M) is not None, "application-dev.yaml: spring.autoconfigure.exclude: \"\" (the clear)")
    c = rd(A, "compose.yaml")
    mg = c[c.index("  # Course 8, unit 18: MongoDB, the menu's store"):c.index("\nvolumes:")]
    for want in ("    image: mongo:8\n", "      GLIBC_TUNABLES: glibc.pthread.rseq=1\n", "      MONGO_INITDB_DATABASE: tiffinbox\n",
                 '    command: ["--unixSocketPrefix", "/data/db"]\n', '      - "127.0.0.1:18883:27017"\n'):
        ok(want in mg, "compose.yaml's mongo service: " + want.strip())
    ok("05b334b0a7a78fe913caac0cd2e1ecccf4da515d9a3a44be911b6ea3734c17cd" in c and "pull_policy" not in c and "volumes:" not in mg, "compose.yaml: the digest in a comment, no pull_policy, no volume for mongo")
    ok("Course 8, unit 18" in mg, "compose.yaml's mongo service: a Course 8, unit 18 note")
    me = rd(A, W + "Menus.java")
    ok('@Profile("dev")' in me and "MongoTemplate" in me and "remove(new Query(), MenuDay.class)" in me and "insertAll" in me and "dropCollection" not in me, "Menus: @Profile(\"dev\"), MongoTemplate, reset() = remove(new Query()), fill = insertAll, no dropCollection (R.431)")
    md = rd(A, W + "MenuDay.java")
    ok('@Document("menu")' in md and "@Id String id" in md and "record MenuItem(" in md, "MenuDay: @Document(\"menu\"), @Id String, a nested record MenuItem")
    sv = rd(A, W + "TiffinBoxServer.java")
    ok("ObjectProvider<Menus> menu" in sv and re.search(r"menus\.reset\(\);\n\s+menus\.fill\(MenuDay\.forDays\(days\)\);", sv) is not None, "TiffinBoxServer: an ObjectProvider<Menus>; start() resets, then fills forDays(days) - no guard")
    it = rd(A, "tiffinbox-web/src/test/java/com/tiffinbox/web/MongoDatastoreIT.java")
    ok(MIMG in it and '"GLIBC_TUNABLES", "glibc.pthread.rseq=1"' in it and "withReplicaSet" not in it and 'bindIpAndPort("127.0.0.1", 20578)' in it, "MongoDatastoreIT: the digest, the variable, standalone (no withReplicaSet - R.422), published on 127.0.0.1:20578 (R.454's shape)")
    ok("@DataMongoTest" in it and "@ContextConfiguration(classes = MongoSlice.class)" in it and "@Import(Menus.class)" in it and '@ActiveProfiles("dev")' in it, "MongoDatastoreIT: @DataMongoTest + MongoSlice + @Import(Menus) + @ActiveProfiles(\"dev\")")
    pm = rd(A, "tiffinbox-web/pom.xml")
    for art in ("spring-boot-starter-data-mongodb", "spring-boot-starter-data-mongodb-test", "testcontainers-mongodb"):
        m = re.search(r"<artifactId>" + art + r"</artifactId>\n(\s*<scope>test</scope>\n)?\s*</dependency>", pm)
        ok(m is not None and (art == "spring-boot-starter-data-mongodb") == (m.group(1) is None), "tiffinbox-web/pom.xml: " + art + (" (compile)" if art == "spring-boot-starter-data-mongodb" else " (test)") + ", no version typed")
    hk = y.replace(ex.group(0), "") if ex else y
    hk = hk.replace("  health:\n    redis:\n      enabled: false\n", "  health:\n    redis:\n      enabled: false\n    mongodb:\n      enabled: false\n")
    ok(rd("exercise", "application.yaml") == hk, "exercise/application.yaml = after/'s application.yaml without the exclude, with management.health.mongodb.enabled: false (the broken state)")
    ra, rb = rd(A, "README.md").splitlines(), rd(B, "README.md").splitlines()
    sa = set(ra); sb = set(rb)
    gone = ["- " + l for l in rb if l not in sa]
    grown = ["+ " + l for l in ra if l not in sb]
    ok(len(gone) == 2 and all(any(re.sub(r" \*\(Course 8, unit 18[^)]*\)\*", "", g2[2:]) == g[2:] for g2 in grown) for g in gone), "the anchor README: two lines grown by a note (the header's, the Course 5 compose bullet's), nothing else changed or gone")
    ok("## Course 8 · unit 18 — MongoDB: Documents, Not Rows" in rd(A, "README.md"), "the anchor README: its unit 18 section")
elif NAME == "r250":
    A, B = sys.argv[2], sys.argv[3]
    c, r = rd(A, "compose.yaml"), rd(A, "README.md")
    pm = rd(A, "tiffinbox-web/pom.xml")
    items = [
        ("compose.yaml:1 \"one official Postgres image\" - noted (Course 8, unit 18: and MongoDB, the third)", "one official Postgres image" in c and "Course 8, unit 18: and MongoDB, the third" in c),
        ("compose.yaml's \"under \"dev\" Redis is required\" - kept (still true); the mongo service says Mongo is required too", 'under "dev" Redis is required' in c and 'Under "dev" Mongo is required' in c),
        ("tiffinbox-web/pom.xml's Testcontainers comment (\"Only CustomerEntityRepositoryIT uses them\") - noted (Course 8, unit 18: and MongoDatastoreIT)", "Course 8, unit 18: and MongoDatastoreIT" in pm),
        ("README.md's header (the data lives in PostgreSQL and Redis) - noted (Section 4's first change, this unit's note)", "(Course 8, unit 18, **Section 4's first change to this folder**" in r),
        ("README.md's compose bullet in c5-unit17's section (\"one official Postgres image\") - noted (Course 8, unit 18: and MongoDB)", "*(Course 8, unit 18: and MongoDB, the third, `mongo:8`" in r),
        ("README.md's `mvn package still runs the 18 and needs no Docker` (units 14-17) - kept, still true (RE-MEASURE 13); this unit's section says so", r.count("`mvn package` still runs the 18 and needs no Docker") >= 3),
        ("README.md's \"the default run still needs no Redis\" (units 14-17) - kept, still true; this unit's section adds no Docker and no MongoClient", "builds no MongoClient and still needs no Docker" in r),
    ]
    for t, c_ in items:
        ok(c_, "R.250: " + t)
elif NAME == "c815":
    rm = rd(".", sys.argv[2])
    ok(C815 in rm, "README.md quotes C8-15's sentence byte for byte (md5 %s)" % hashlib.md5(C815.encode()).hexdigest())
    if os.path.exists(sys.argv[3]):
        row = [l for l in raw(sys.argv[3]) if l.startswith("| C8-15 |")]
        ok(len(row) == 1 and ('"' + C815 + '"') in row[0], "the ledger's C8-15 row holds the same sentence, byte for byte (the ledger read on this machine)")
    else:
        oks.append("the ledger is not beside this clone (a sealed clone holds the repository only): the sentence's md5 is the check")
    VALUES.append("C8-15 md5 " + hashlib.md5(C815.encode()).hexdigest())
elif NAME == "wib":
    L = raw(sys.argv[2]); f = sys.argv[3]
    i = next(k for k, l in enumerate(L) if l.startswith("in bash "))
    j = next(k for k, l in enumerate(L) if k > i and l.startswith("  then the solution's lines"))
    e = next(k for k, l in enumerate(L) if k > j and l.startswith("  the shell is now in"))
    part = L[i + 1:j] if f.endswith("README.md") else L[j + 1:e]
    print("\n".join(l[4:] for l in part))
    sys.exit(0)
elif NAME == "exercise":
    L = raw(sys.argv[2]); words, line = int(sys.argv[3]), sys.argv[4]
    ok(words == 22 and len(line.split()) == 22, "the spoken exercise line: 22 words (wc -w)")
    bl = [k for k, l in enumerate(L) if l.startswith("in bash ") or l.startswith("in zsh ")]
    ok(len(bl) == 2, "two shells ran the blocks: bash, then zsh")
    got = []
    for k in bl:
        seg = L[k:]
        h = [l.strip() for l in seg if l.strip().startswith("health:")][:2]
        n = [int(re.search(r"(\d+)$", l).group(1)) for l in seg if "lines naming 27017 in the log:" in l][:2]
        got.append((h, n))
    for h, n in got:
        ok(h == ["health: 200", "health: 200"], "health 200 in the broken run and in the solution")
        ok(len(n) == 2 and n[0] > 0 and n[1] == 0, "R.196: the broken log names 27017 (%s lines), the solution's names it nowhere (%s)" % (n[0] if n else "?", n[1] if len(n) > 1 else "?"))
    ok(got[0] == got[1], "bash and zsh print the same")
    VALUES.append("broken: health 200, 27017 lines %d; solved: health 200, 27017 lines 0" % got[0][1][0])
elif NAME == "image":
    L = raw(sys.argv[2])
    m = one(L, r"Volumes (\{.*\}) · Cmd (\S+) · Entrypoint (\S+)$")
    ok(m and json.loads(m.group(1)) == {"/data/configdb": {}, "/data/db": {}} and m.group(2) == '["mongod"]' and m.group(3) == '["docker-entrypoint.sh"]', "the image declares two volumes, /data/configdb and /data/db; Cmd mongod; Entrypoint docker-entrypoint.sh")
    m = one(L, r"Id sha256:([0-9a-f]+) · Size (\d+)"); ok(m and MIMG.endswith(m.group(1)), "the image's Id is the digest")
    imgs = num(one(L, r"images on this machine: (\d+) · the digest among them: 1$"))
    vb = num(one(L, r"WITHOUT the variable.*volumes before it (\d+)$"))
    m = one(L, r"its state: exited, exit code (\d+) · volumes now (\d+) · its Mounts: volume /data/configdb · volume /data/db$")
    ok(m and m.group(1) == "1" and int(m.group(2)) == vb + 2, "the no-variable container: exited, exit code 1; volumes +2 while it exists; its two Mounts")
    f = one(L, r'^    \{"s": "F", "c": "CONTROL", "id": 12257600, "ctx": "main", "msg": "MongoDB cannot start: Linux kernel versions 6\.19\.0 through 7\.0\.13 have a known incompatibility with this version of MongoDB\. See https://jira\.mongodb\.org/browse/SERVER-121912 for more information\."\}$')
    vr = [int(x) for x in re.findall(r"· volumes (\d+)$", "\n".join(l for l in L if l.startswith("  dk rm -fv")), re.M)]
    ok(vr == [vb, vb], "after each rm -fv the volume count is back to %s (R.421)" % vb)
    m = one(L, r"^  its state: running · volumes now (\d+) · its Mounts: volume /data/configdb · volume /data/db$"); ok(m and int(m.group(1)) == vb + 2, "the unit's container: running, +2 volumes, its two Mounts")
    w = one(L, r'"id":8718500 "msg":"(Your system has glibc support for rseq built in, which is not yet supported by tcmalloc-google and has critical performance implications\. Please set the environment variable GLIBC_TUNABLES=glibc\.pthread\.rseq=0)"$')
    v = one(L, r"db\.version\(\) -> (\S+)$"); mv = one(L, r"mongod --version, .*: db version v(\S+)$")
    ok(v and mv and v.group(1) == mv.group(1) == "8.3.17", "mongosh's db.version() = mongod --version's = 8.3.17 (two witnesses of the version)")
    ok(one(L, r"that container's interfaces .*: lo$") is not None, "the mongosh container's interfaces: lo alone (R.422's witness)")
    VALUES.append("MongoDB %s · volumes %d -> %d -> %d · exit code 1 without the variable · images %d" % (v.group(1) if v else "?", vb, vb + 2, vb, imgs or 0))
elif NAME == "anchor":
    L = raw(sys.argv[2]); n = days()
    R = [l for l in L if "Surefire's Results line:" in l]
    ok(len(R) == 3 and "Tests run: 18, Failures: 0, Errors: 0, Skipped: 0" in R[0] and "Tests run: 18, Failures: 0, Errors: 0, Skipped: 0" in R[1] and "Tests run: 9, Failures: 0, Errors: 0, Skipped: 0" in R[2], "Maven's Results: package 18; verify 18 + 9, no failure")
    ok(one(L, r"lines naming 27017 0 · lines naming mongo \(any case\) 0$") is not None, "RE-MEASURE 13: mvn package with Docker at nothing - the 18 green, 0 lines naming 27017 or mongo")
    m = one(L, r"Docker's own list \(dk ps, polled on a count\): Ports (\S+) · its command (.*)$")
    ok(m and "mongod" in m.group(2) and "--replSet" not in m.group(2), "the IT's container: mongod, a standalone (no --replSet - R.422)")
    ok(m and m.group(1) == "127.0.0.1:20578->27017/tcp", "the IT's container while verify ran: 127.0.0.1:20578->27017/tcp alone (R.454's shape)")
    m = one(L, r"MONGO IT the container's port bindings \(Docker's own record\): \[(.*)\]$"); ok(m and m.group(1) == "127.0.0.1:20578->27017/tcp", "the IT's own reading of its binding: 127.0.0.1:20578")
    ok(one(L, r"MONGO IT the same document, through the driver's collection: _id String · _class com\.tiffinbox\.web\.MenuDay · items 3 · documents in menu 1$") is not None, "the IT's second witness: _id a String, _class the full class name, 3 items")
    ok(one(L, r"lines naming docker compose 0 · Testcontainers containers after it: 0$") is not None and one(L, r"mongosh named in the verify log: 0 · --replSet named in the IT container's command: 0$") is not None, "the IT: no Compose (RE-MEASURE 8), no mongosh (R.422), its container gone")
    lb, la = num(one(L, r"^  before/: (\d+) libraries$")), num(one(L, r"^  after/: (\d+) libraries$"))
    g = one(L, r"^  gained: (.*) · lost: 0$")
    gl = g.group(1).split() if g else []
    ok(la - lb == len(gl) and sorted(gl) == sorted(["bson-5.8.1.jar", "bson-record-codec-5.8.1.jar", "mongodb-driver-core-5.8.1.jar", "mongodb-driver-sync-5.8.1.jar", "spring-boot-data-mongodb-4.1.2.jar", "spring-boot-mongodb-4.1.2.jar", "spring-data-mongodb-5.1.2.jar"]), "the jar's libraries: %s -> %s, the gained ones the starter's (comm)" % (lb, la))
    ok(one(L, r"the version lines off the jar names: .*mongodb-driver-sync-5\.8\.1\.jar.*spring-boot-4\.1\.2\.jar.*spring-data-mongodb-5\.1\.2\.jar") is not None, "version lines: Boot 4.1.2, Spring Data MongoDB 5.1.2, the driver 5.8.1 (jar names)")
    ok(one(L, r"\(x1\) HHH000001: Hibernate ORM core version 7\.4\.13\.Final$") is not None and one(L, r"\(x1\) Found 0 MongoDB repository interfaces\.?$") is not None, "the start: HHH000001 7.4.13.Final; strict mode's MongoDB line: Found 0 MongoDB repository interfaces")
    ok(one(L, r'\(x1\) Command "delete" started on database "tiffinbox"$') is not None and one(L, r'\(x1\) Command "insert" started on database "tiffinbox"$') is not None, "the driver's DEBUG: one delete and one insert started on database \"tiffinbox\" (R.435)")
    ops = [l.strip() for l in L if l.startswith("    op ") and ("remove" in l or "insert" in l)]
    ok(ops[:2] == ["op remove, the filter {}", "op insert, ninserted %d" % n], "system.profile: one remove with the empty filter, then one insert of %d documents (days: %d - derived)" % (n, n))
    m = one(L, r"db\.menu\.countDocuments\(\) -> (\d+) · listDatabases -> (\S+)$")
    ok(m and int(m.group(1)) == n and "tiffinbox" in m.group(2).split(",") and "test" not in m.group(2).split(","), "mongosh: %d documents; listDatabases names tiffinbox, not test" % n)
    m = one(L, r"GET /menu/day-19 -> 200 (\{.*\})$")
    d = json.loads(m.group(1)) if m else {}
    ok(d.get("id") == "day-19" and len(d.get("items", [])) == 3, "GET /menu/day-19 -> 200, the document, its three items")
    ok(one(L, r"GET /menu/day-31 -> 404 $") is not None or one(L, r"GET /menu/day-31 -> 404$") is not None, "GET /menu/day-31 -> 404")
    ok(one(L, r'GET /actuator/health -> 200 \{"groups":\["liveness","readiness"\],"status":"UP"\}$') is not None and one(L, r"GET /dashboard -> 200$") is not None, "health 200, /dashboard 200")
    k = one(L, r'GET /kitchen -> 200 .*"ordersValue":(\d+)'); b = one(L, r"GET /leaderboard -> 200 (\{.*\})$")
    bd = json.loads(b.group(1)) if b else {}
    ok(k and bd and sum(bd.values()) == int(k.group(1)) and list(bd) == ["Sunil", "Ravi", "Meera", "Priya"], "the leaderboard still fills: its four scores sum to /kitchen's ordersValue (%s)" % (k.group(1) if k else "?"))
    ok(one(L, r"db\.version\(\) 8\.3\.17 · redis-cli INFO server redis_version:8\.10\.3 · psql show server_version 18\.6$") is not None, "the stores' versions: MongoDB 8.3.17, Redis 8.10.3, PostgreSQL 18.6")
    ok(one(L, r"POST /shutdown .* -> 200 · the JVM's exit 0") is not None, "the dev JVM stopped by POST /shutdown, exit 0")
    # the Compose window
    ok(one(L, r"the project's containers: tiffinbox-dev-mongo-1 127\.0\.0\.1:18883->27017/tcp\|tiffinbox-dev-postgres-1 127\.0\.0\.1:18881->5432/tcp\|tiffinbox-dev-redis-1 127\.0\.0\.1:18882->6379/tcp$") is not None, "Compose: three services, each on 127.0.0.1 alone (18881-18883)")
    ok(one(L, r'the mongo service\'s container: GLIBC_TUNABLES 1 · MONGO_INITDB_DATABASE=tiffinbox 1 · its command \["--unixSocketPrefix","/data/db"\]') is not None, "Compose's mongo container: the variable, MONGO_INITDB_DATABASE, the socket command")
    ok(one(L, r'the start\'s lines: 1 Command "delete" started on database "tiffinbox"\|1 Command "insert" started on database "tiffinbox"\|1 tiffinbox: orders cooked: +120$') is not None, "Compose: the driver's DEBUG names tiffinbox for the delete and the insert (RE-MEASURE 14)")
    m = one(L, r"\(no network, --volumes-from tiffinbox-dev-mongo-1\): listDatabases -> (\S+) · db\.menu\.countDocuments\(\) on tiffinbox -> (\d+) · on test -> (\d+)$")
    ok(m and m.group(1) == "admin,config,local,tiffinbox" and int(m.group(2)) == n and m.group(3) == "0", "Compose: listDatabases admin,config,local,tiffinbox - no test; %d menus on tiffinbox, 0 on test (R.435)" % n)
    ok(one(L, r"Compose window.*\n?") is not None and one(L, r"^  GET /menu/day-19 -> 200 ") is not None, "Compose: /menu/day-19 200 (RE-MEASURE 2)")
    v0 = num(one(L, r"^  before it: .* · volumes (\d+) · mongo:8 postgres:18-alpine redis:8-alpine present"))
    st = one(L, r"after TiffinBox stopped \(Boot's own compose stop\): the project's containers (.+?) · volumes (\d+) · tiffinbox-dev volumes by name: (\S*) · the mongo service's two \(by its Mounts\): (.*)$")
    dn = one(L, r"^  then: the project's containers 0 · its networks 0 · volumes (\d+) · tiffinbox-dev volumes by name: (\S*) · the mongo service's two: (.*)$")
    dv = one(L, r"^  then: volumes (\d+) · tiffinbox-dev volumes by name: (\d+) · the mongo service's two: (.*)$")
    fin = one(L, r"dk volume rm\): volumes (\d+) = before the window")
    ok(st and st.group(1) == "tiffinbox-dev-mongo-1 exited|tiffinbox-dev-postgres-1 exited|tiffinbox-dev-redis-1 exited" and int(st.group(2)) == v0 + 3 and st.group(3) == "tiffinbox-dev_data" and st.group(4) == "present present", "RE-MEASURE 3: after Boot's compose stop - three containers exited, volumes +3 (tiffinbox-dev_data and the mongo service's two)")
    ok(dn and int(dn.group(1)) == v0 + 3 and dn.group(2) == "tiffinbox-dev_data" and dn.group(3) == "present present", "RE-MEASURE 3: after down - containers and network gone; tiffinbox-dev_data and the two anonymous volumes stay")
    ok(dv and int(dv.group(1)) == v0 + 2 and dv.group(2) == "0" and dv.group(3) == "present present", "RE-MEASURE 3: after down -v - tiffinbox-dev_data gone; the two anonymous volumes still stay")
    ok(fin and int(fin.group(1)) == v0, "the two removed by name: the count back to the window's start")
    VALUES.append("dev: /menu/day-19 200 (3 items) · /menu/day-31 404 · health 200 · %d documents · tiffinbox, no test · 18 + 9 · libraries %d -> %d · Compose: stop +3, down +3, down -v +2 volumes" % (n, lb or 0, la or 0))
elif NAME == "document":
    L = raw(sys.argv[2])
    pj = "\n".join(l.strip() for l in L if l.startswith("    ") and not l.startswith("    printjson"))
    ok("_id: 'day-19'," in pj and pj.rstrip().endswith("_class: 'com.tiffinbox.web.MenuDay'\n}") or "_class: 'com.tiffinbox.web.MenuDay'\n}" in pj, "mongosh's printjson: _id 'day-19', _class the full class name, last")
    ok(pj.count("mealType:") == 3, "mongosh: three items embedded")
    ok(one(L, r"its keys _id,items,_class · typeof _id string · _class com\.tiffinbox\.web\.MenuDay$") is not None, "mongosh: the keys _id, items, _class; _id a string")
    m = one(L, r"findById\(\"day-19\", MenuDay\.class\), once -> one MenuDay, id day-19 · items (\d+)")
    names_j = [l.split(" ", 4)[-1] for l in L if l.startswith("  PROBE read:   ")]
    names_m = re.findall(r"name: '([^']+)'", pj)
    ok(m and int(m.group(1)) == 3 and len(names_j) == 3 and all(any(nm in j for j in names_j) for nm in names_m) and len(names_m) == 3, "Java (the harness's findById) and mongosh read the same three items")
    ok(one(L, r"a String of length 24, hex digits only true$") is not None, "the null id (the harness's): Java reads back a String of 24 hex characters")
    ok(one(L, r"typeof _id object · an ObjectId true · its keys _id,items,_class · _class com\.tiffinbox\.web\.MenuDay$") is not None and one(L, r"printjson\(_id\): ObjectId\(<objectid>\)$") is not None, "mongosh: that document's _id is an ObjectId (masked <objectid>)")
    m = one(L, r"deletedCount (\d+) · countDocuments\(\) (\d+)$"); ok(m and m.group(1) == "1" and int(m.group(2)) == days(), "the null-id document removed (1); the menu back to %d" % days())
    VALUES.append("keys _id,items,_class · _id a String · _class com.tiffinbox.web.MenuDay · null id: ObjectId, 24 characters in Java")
elif NAME == "oneread":
    L = raw(sys.argv[2])
    j = one(L, r"once -> one MenuDay, id day-19 · items (\d+) · allergens on its items (\d+) \(distinct (\d+)\)$")
    ops = num(one(L, r"^    ops (\d+)$"))
    q = one(L, r"^    op query · ns tiffinbox\.menu · command find · filter \{\"_id\":\"day-19\"\} · nreturned (\d+)$")
    ok(ops == 1 and q and q.group(1) == "1", "system.profile: ONE op, a query on tiffinbox.menu, find by _id, nreturned 1")
    r4 = [l for l in L if "rows (psql -At | wc -l):" in l]
    m4 = re.search(r"rows \(psql -At \| wc -l\): (\d+) · PostgreSQL's log between the markers: statements (\d+) · JOIN in it (\d+)$", r4[0]) if r4 else None
    m3 = re.search(r"rows \(psql -At \| wc -l\): (\d+) · PostgreSQL's log between the markers: statements (\d+) · JOIN in it (\d+)$", r4[1]) if len(r4) > 1 else None
    ok(m4 and m4.group(2) == "1" and m4.group(3) == "3" and j and int(m4.group(1)) == int(j.group(2)), "the four tables: one statement, three joins, a row per item and allergen - %s rows = the allergens Java read on day-19's items" % (m4.group(1) if m4 else "?"))
    ok(m3 and m3.group(2) == "1" and m3.group(3) == "2" and m4 and m3.group(1) == m4.group(1), "the three tables (labelled): one statement, two joins, the same rows")
    VALUES.append("Mongo: 1 query op, 1 document, %s items, %s allergens (%s distinct) · four tables: 1 statement, 3 joins, %s rows · three tables: 2 joins, %s rows" % (j.group(1) if j else "?", j.group(2) if j else "?", j.group(3) if j else "?", m4.group(1) if m4 else "?", m3.group(1) if m3 else "?"))
elif NAME == "rename":
    L = raw(sys.argv[2]); n = days()
    m = one(L, r"-> matched (\d+), modified (\d+)$"); ok(m and int(m.group(1)) == int(m.group(2)) == n, "the harness's updateMulti: matched %d, modified %d" % (n, n))
    ok(num(one(L, r"^    ops (\d+)$")) == 1 and one(L, r"^    op update · ns tiffinbox\.menu · nMatched %d · nModified %d$" % (n, n)) is not None, "system.profile: ONE update op, nMatched = nModified = %d" % n)
    c = one(L, r'"soya"\}\) -> (\d+) · countDocuments\(\{"items\.allergens": "soy"\}\) -> (\d+) · countDocuments\(\) -> (\d+)$')
    ok(c and int(c.group(1)) == n and c.group(2) == "0" and int(c.group(3)) == n, "mongosh after: soya in %d documents, soy in 0" % n)
    ok(one(L, r'countDocuments\(\{"items\.allergens": "soy"\}\) before -> %d$' % n) is not None, "mongosh before: soy in every menu (%d)" % n)
    u1 = one(L, r"the four tables: .* -> UPDATE (\d+)$"); u3 = one(L, r"the three tables, labelled .* -> UPDATE (\d+)$")
    ok(u1 and u1.group(1) == "1", "the four tables: UPDATE 1")
    ok(one(L, r"the menus that list soya now, through the joins \(count\(DISTINCT m\.id\)\): %d · that list soy: 0$" % n) is not None, "the four tables: %d menus list the new name, 0 the old" % n)
    ok(u3 and int(u3.group(1)) == n and one(L, r"the menus that list soya now \(count\(DISTINCT m\.id\)\): %d$" % n) is not None, "the three tables: UPDATE %d - a tie with MongoDB's %d documents (labelled)" % (n, n))
    ok(one(L, r"no exception anywhere: lines naming an Exception or ERROR in the harness JVM's log 0 · in PostgreSQL's psql answers 0$") is not None, "no exception anywhere (R.396's negation)")
    VALUES.append("Mongo: 1 update op, %d modified · four tables: UPDATE 1 · three tables: UPDATE %d (the tie)" % (n, int(u3.group(1)) if u3 else 0))
elif NAME == "absent":
    L = raw(sys.argv[2])
    ok(one(L, r"nothing listens: 0$") is not None, "20577 unbound before the start")
    ok(one(L, r"spring\.mongodb\.uri · spring\.data\.mongodb\.uri \(deprecated, replacement spring\.mongodb\.uri\)$") is not None, "the key: spring.mongodb.uri (Boot 4.1.2's metadata; spring.data.mongodb.uri deprecated with it as the replacement)")
    ok(one(L, r"the JVM's exit: 1 · GET /actuator/health on 20570 -> 000 · listening on 20570: 0$") is not None, "the start stops: exit 1, nothing answers on 20570 (000)")
    m = one(L, r"Error creating bean with name 'tiffinBoxServer' (\d+) · DataAccessResourceFailureException (\d+) · MongoTimeoutException (\d+) · Application run failed (\d+)$")
    ok(m and all(int(x) > 0 for x in m.groups()), "the log names the bean, DataAccessResourceFailureException, MongoTimeoutException and Application run failed")
    ok(one(L, r"the bean the log names first: Error creating bean with name 'tiffinBoxServer'") is not None, "RE-MEASURE 9: the bean named is tiffinBoxServer")
    VALUES.append("dev, Mongo absent: exit 1 · 000 · Error creating bean with name 'tiffinBoxServer' · DataAccessResourceFailureException · MongoTimeoutException")
elif NAME == "default":
    L = raw(sys.argv[2])
    H = [l for l in L if l.startswith("  GET /actuator/health -> ")]
    M = [l for l in L if l.startswith("  GET /menu/day-19 -> ")]
    G = [l for l in L if l.startswith("  its log: lines naming 27017 ")]
    ok(len(H) == 3 and len(M) == 3 and len(G) == 3, "three runs: after/, starteronly, healthkey")
    if len(H) == 3 and len(G) == 3:
        hs = [re.search(r"-> (\d+)", h).group(1) for h in H]
        cv = lambda x: 1000 if x == "more than 0" else int(x)
        ns = [cv(re.search(r"lines naming 27017 (\d+|more than 0)", g).group(1)) for g in G]
        mo = [cv(re.search(r"lines naming mongo, any case (\d+|more than 0)", g).group(1)) for g in G]
        ok(hs == ["200", "503", "200"], "health: after/ 200 · the starter alone 503 · the health key alone 200")
        ok(ns[0] == 0 and mo[0] == 0 and ns[1] > 0 and ns[2] > 0, "lines naming 27017: after/ 0 (and mongo 0) · the starter alone and the health key alone more than 0")
        ok(re.search(r"-> 404 · GET /dashboard -> 200 · /actuator/beans: a bean named menus 0 · a MongoClient bean 0$", M[0]) is not None, "after/'s default run: /menu/day-19 404, /dashboard 200, no menus bean, no MongoClient bean")
        VALUES.append("default run: health 200 · /menu/day-19 404 · 27017 lines 0 · the starter alone 503 and lines naming 27017 · the health key alone 200 and lines naming 27017")
    ok(one(L, r"Surefire's Results line: Tests run: 18, Failures: 0, Errors: 0, Skipped: 0$") is not None, "the 18 under mvn package with no Docker")
elif NAME == "twice":
    L = raw(sys.argv[2]); n = days()
    lg = [l for l in L if l.startswith("  its log: Command")]
    ms = [l for l in L if l.startswith("  mongosh (no network): countDocuments()")]
    ok(len(lg) == 4 and len(ms) == 4, "four starts: two of after/, two of the copy")
    if len(lg) == 4 and len(ms) == 4:
        cs = [re.search(r"countDocuments\(\) (\d+) · day-19 as stored, its md5 ([0-9a-f]{32})$", x) for x in ms]
        ok(all(cs) and int(cs[0].group(1)) == int(cs[1].group(1)) == n and cs[0].group(2) == cs[1].group(2), "after/'s two starts: %d documents both times, the same day-19 (md5)" % n)
        ok(all(re.search(r'delete" started 1 · Command "insert" started 1 · DuplicateKeyException 0', x) for x in lg[:2]), "after/: one delete, one insert, each start")
        ok(re.search(r'delete" started 0 · Command "insert" started 1 · DuplicateKeyException 0', lg[2]) is not None and int(cs[2].group(1)) == n, "the copy's first start (an emptied collection): one insert, %d documents" % n)
        ok(re.search(r'delete" started 0 · Command "insert" started 1 · DuplicateKeyException [1-9]\d* · E11000 [1-9]\d* · Application run failed [1-9]', lg[3]) is not None and int(cs[3].group(1)) == n, "the copy's second start: the insert refused - DuplicateKeyException, E11000 - and the start stops; still %d documents" % n)
        ok(one(L, r"the JVM stopped by itself: exit 1 · listening on 20570: 0$") is not None, "the copy's second start: exit 1, nothing listens")
        ok(one(L, r"deletedCount %d$" % n) is not None, "the copy's window starts from an emptied collection (deleteMany, %d)" % n)
    VALUES.append("two starts: %d and %d, the same day-19 · the copy without the reset: the second start stops, DuplicateKeyException (E11000)" % (n, n))
elif NAME == "seven":
    L = raw(sys.argv[2]); want = sys.argv[3]
    ok(one(L, r"cmp with xcheck\.sql \(= Course 7's capstone's\): the same, byte for byte$") is not None, "Hibernate's script = xcheck.sql (no JPA mapping moved)")
    md = re.findall(r"the seven responses: (\d+) lines · md5 ([0-9a-f]{32})", "\n".join(L))
    ok(len(md) == 2 and md[0] == md[1] and md[0][1] == want, "the seven on before/ and after/: the same md5, Course 7's %s" % want)
    ok(one(L, r"lines that differ: 0$") is not None, "the seven: before/ and after/ answer the same")
    ok(len([l for l in L if "GET /menu/day-19 -> 404" in l]) == 2, "the default run on both trees: /menu/day-19 404")
    VALUES.append("the seven: md5 %s on before/ and after/" % (md[0][1] if md else "?"))
else:
    print("FAIL unknown check " + NAME); sys.exit(1)

for m in oks: print("ok " + m)
for m in fails: print("FAIL " + m)
if VALUES: print("VALUES " + " · ".join(VALUES))
sys.exit(1 if fails else 0)
