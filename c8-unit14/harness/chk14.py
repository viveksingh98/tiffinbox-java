"""Unit 14's checks (python3 -I -B harness/chk14.py NAME ARGS...). Each capture's numbers are asserted against a second witness of the
same run - never a typed figure (R.398): Java's answer (the shipped Leaderboard's route, the context's StringRedisTemplate, the
harness's template beans) against redis-cli inside the Redis container; the four scores' sum against /kitchen's ordersValue and the
start's own "kitchen value:" log line (three numbers from one run); the start's "orders cooked:" against /kitchen's ordersCooked; the
harness's flip count against CONFIG GET; the doubled board against the single one; the exit code against the log's phrases and
curl; Surefire's XML against Maven's Results lines; the seven's md5 against Course 7's published one.
Prints ok/FAIL lines and one VALUES line; exits 1 on any FAIL.
  static AFTER BEFORE   the change itself, read off the files (C1)
  r250 AFTER BEFORE     the anchor README's, YAML's, compose's and Javadoc's sentences C1 made false or dated: each carries its note
  wib CAPTURE FILE      the lines the exercise's block printed for FILE (bash's), for receipts.sh to compare with "What it prints"
  exercise|anchor|zset|flip|structs|twice|trap|absent|default|notes|seven CAPTURE [...]"""
import difflib, filecmp, os, re, sys

NAME = sys.argv[1]
fails, oks, VALUES = [], [], []


def ok(c, msg):
    (oks if c else fails).append(msg)


def lines(p):
    return open(p, encoding="utf-8").read().splitlines()


def grab(L, rx, n=1):
    m = [x for x in (re.search(rx, l) for l in L) if x]
    ok(len(m) == n, "%d line(s) match %s (found %d)" % (n, rx, len(m)))
    return m


def sections(L):
    out, cur = [], None
    for l in L:
        if l.startswith("-- "):
            cur = [l, []]; out.append(cur)
        elif cur is not None:
            cur[1].append(l)
    return out


DEVW = "profile dev, PostgreSQL 18.6"
DEFW = "default run, H2 2.5.250"
JDK = "org.springframework.data.redis.serializer.JdkSerializationRedisSerializer"
STR = "org.springframework.data.redis.serializer.StringRedisSerializer"
RCM = "org.springframework.data.redis.cache.RedisCacheManager"
CAF = "org.springframework.cache.caffeine.CaffeineCacheManager"
LBC = "com.tiffinbox.web.Leaderboard"
LB = "tiffinbox:leaderboard"
NETTY = "Netty's DNS line on macOS"


def pairs(s):
    """'Sunil 9000 · Ravi 7200' or 'Sunil 9000 Ravi 7200' -> [('Sunil', 9000), ...]"""
    t = s.replace("·", " ").split()
    return [(t[i], int(float(t[i + 1]))) for i in range(0, len(t) - 1, 2)]


def jvmexit(body, code, warn_ok=True):
    m = [l for l in body if re.match(r"^  exit %d · its log, every line but the harness's own PROBE lines: WARN (\d+) \(%s: (\d+)\) · ERROR (\d+) · " % (code, re.escape(NETTY)), l)]
    ok(len(m) == 1, "the JVM's exit is %d (%d line)" % (code, len(m)))
    return m


def started(body, who):
    ok(("PROBE started: yes · %s · a web server: yes" % who) in body, "the JVM started: %s" % who)


def startlog(body):
    oc = [int(m.group(1)) for m in (re.match(r"^  log: tiffinbox: orders cooked: +(\d+)$", l) for l in body) if m]
    kv = [int(m.group(1)) for m in (re.match(r"^  log: tiffinbox: kitchen value: +(\d+)$", l) for l in body) if m]
    ok(len(oc) == 1 and len(kv) == 1, "the start's own two log lines, orders cooked and kitchen value: %s %s" % (oc, kv))
    return (oc[0] if oc else None, kv[0] if kv else None)


def kitchen(body, who):
    m = grab(body, r"^PROBE http \(%s\): GET /kitchen -> 200 · ordersCooked (\d+) · ordersValue (\d+)$" % re.escape(who))
    return (int(m[0].group(1)), int(m[0].group(2))) if m else (None, None)


def lbroute(body, who):
    m = grab(body, r"^PROBE http \(%s\): GET /leaderboard -> 200 · \{(.*)\}$" % re.escape(who))
    if not m: return []
    return [(k, int(float(v))) for k, v in re.findall(r'"([A-Za-z]+)":([0-9.]+)', m[0].group(1))]


def health(body, who, code="200", st="UP"):
    ok(("PROBE http (%s): GET /actuator/health -> %s · status %s" % (who, code, st)) in body, "health %s %s (%s)" % (code, st, who))


def rd(t, p): return open(os.path.join(t, p), encoding="utf-8").read()


def adds(B, A, p):
    return [l for l in difflib.unified_diff(rd(B, p).splitlines(), rd(A, p).splitlines(), lineterm="", n=0) if l[:1] in "+-" and not l.startswith(("+++", "---"))]


W = "tiffinbox-web/src/main/java/com/tiffinbox/web/"
LBF = W + "Leaderboard.java"; TBS = W + "TiffinBoxServer.java"; KHI = W + "KitchenHealthIndicator.java"
CY = "compose.yaml"; DY = "tiffinbox-web/src/main/resources/application-dev.yaml"; WP = "tiffinbox-web/pom.xml"
RS = "tiffinbox-web/src/test/java/slice/RedisSlice.java"; IT = "tiffinbox-web/src/test/java/com/tiffinbox/web/RedisDatastoreIT.java"
if NAME == "static":
    A, B = sys.argv[2], sys.argv[3]
    changed = []
    for d, ds, fs in os.walk(A):
        for f in fs:
            p = os.path.relpath(os.path.join(d, f), A); q = os.path.join(B, p)
            if not os.path.exists(q): changed.append("new " + p)
            elif not filecmp.cmp(os.path.join(A, p), q, shallow=False): changed.append(p)
    for d, ds, fs in os.walk(B):
        for f in fs:
            p = os.path.relpath(os.path.join(d, f), B)
            if not os.path.exists(os.path.join(A, p)): changed.append("gone " + p)
    want = ["README.md", CY, WP, KHI, TBS, DY, "new " + LBF, "new " + RS, "new " + IT]
    ok(sorted(changed) == sorted(want), "C1: the files new and changed are Leaderboard, TiffinBoxServer, KitchenHealthIndicator, compose.yaml, application-dev.yaml, tiffinbox-web/pom.xml, RedisSlice, RedisDatastoreIT and the README - nothing gone, application.yaml untouched: %s" % sorted(changed))
    lb = rd(A, LBF)
    code = lambda t: [l for l in t.splitlines() if not l.strip().startswith(("*", "/**", "*/", "//"))]
    lc = code(lb)
    ok("@RestController" in lc and '@Profile("dev")' in lc, "Leaderboard: @RestController @Profile(\"dev\") (⚑4)")
    ok(any("StringRedisTemplate redis;" in l for l in lc) and not any(re.search(r"RedisTemplate<", l) for l in lc), "Leaderboard: built on StringRedisTemplate, no RedisTemplate<…> (R.399)")
    ok(any('KEY = "tiffinbox:leaderboard"' in l for l in lc) and any('@GetMapping("/leaderboard")' in l for l in lc), "Leaderboard: the key tiffinbox:leaderboard, GET /leaderboard")
    ok(any("redis.delete(KEY)" in l for l in lc) and any("incrementScore(KEY, customer, value)" in l for l in lc) and any("reverseRangeWithScores(KEY, 0, -1)" in l for l in lc), "Leaderboard: reset = DEL, record = ZINCRBY, the route = ZREVRANGE … WITHSCORES")
    ok(not any("Map.of" in l for l in lc) and any("LinkedHashMap" in l for l in lc), "Leaderboard: the route's map a LinkedHashMap, no Map.of (R.411)")
    ok("Course 8, unit 14" in lb, "Leaderboard: its Course 8, unit 14 Javadoc")
    t = code(rd(A, TBS)); tj = "\n".join(t)
    ok("    private final ObjectProvider<Leaderboard> board;" in t and any("ConfigurableApplicationContext context, ObjectProvider<Leaderboard> board) {" in l for l in t), "TiffinBoxServer: the constructor takes ObjectProvider<Leaderboard>")
    s0 = tj[tj.index("void start() throws Exception {"):]
    s0 = s0[:s0.index("kitchen.close();")]
    ix = [s0.find(x) for x in ("lb.reset();", "for (Customer c : repo.findAll())", "lb.record(order.customer(), order.value());")]
    ok(-1 not in ix and ix[0] < ix[1] < ix[2] and s0.count("lb.reset();") == 1, "start(): reset() once before the orders loop, record() per placed order, with the order's own value: %s" % ix)
    ok("try" not in s0 and "catch" not in s0, "start(): the fill is not guarded - no try/catch around it (READ FIRST 14)")
    dc = [l for l in difflib.unified_diff(code(rd(B, TBS)), t, lineterm="", n=0) if l[:1] in "+-" and not l.startswith(("+++", "---"))]
    ok(sum(1 for l in dc if l.startswith("-")) == 2, "TiffinBoxServer: two code lines replaced (the constructor's line, the place line), none else: %s" % [l for l in dc if l.startswith("-")])
    kd = adds(B, A, KHI)
    ok(all(l.startswith("+ *") or l.startswith("- *") for l in kd) and any("Course 8, unit 14" in l for l in kd) and "UP while the database answers" in rd(A, KHI), "KitchenHealthIndicator: Javadoc lines only, a Course 8, unit 14 note, the sentence kept (#119)")
    cd = adds(B, A, CY)
    ok(all(l.startswith("+") and l[1:].lstrip().startswith("#") for l in cd) and sum("Course 8, unit 14" in l for l in cd) == 3, "compose.yaml: comment lines added only, three Course 8, unit 14 notes (⚑15), no line removed")
    ca = rd(A, CY)
    ok("Redis, the cache's store under the profile \"dev\"" in ca and "a cache is rebuilt from the database." in ca and "volumes:\n  data:" in ca and ca.count("- data:") == 1, "compose.yaml: both sentences kept; still one volume, Postgres's - none added for Redis")
    dd = adds(B, A, DY)
    ok(all(l[1:].lstrip().startswith("#") for l in dd) and any("Course 8, unit 14" in l for l in dd), "application-dev.yaml: one comment note, no key moved")
    pd = adds(B, A, WP)
    ok("+      <artifactId>spring-boot-starter-data-redis-test</artifactId>" in pd and not any("<version>" in l for l in pd), "pom.xml: spring-boot-starter-data-redis-test added, no version typed")
    pa = rd(A, WP)
    i = pa.index("<artifactId>spring-boot-starter-data-redis-test</artifactId>")
    ok(pa[i:i + 120].split("</dependency>")[0].strip().endswith("<scope>test</scope>"), "pom.xml: the Redis test starter is test scope")
    it = rd(A, IT); sl = rd(A, RS)
    ok("@DataRedisTest" in it and "@Import(Leaderboard.class)" in it and '@ActiveProfiles("dev")' in it and '@ServiceConnection(name = "redis")' in it and "redis@sha256:7958cfbb9d152f87dadfbc89f1b0b15938f0b81ff8982feb327476f4911935c3" in it and len(re.findall(r"(?m)^    @Test$", it)) == 1, "RedisDatastoreIT: @DataRedisTest + @Import(Leaderboard.class) + @ActiveProfiles(\"dev\"), the pinned digest, @ServiceConnection(name = \"redis\"), one test (⚑14)")
    ok("@SpringBootConfiguration" in sl and "@AutoConfigurationPackage" in sl, "slice/RedisSlice: the slices' form")
    ok(sorted(os.listdir(os.path.join(A, "tiffinbox-core/src/main/resources/db/migration"))) == ["V1__customer_and_pause.sql", "V2__seed.sql", "V3__customer_audit_columns.sql"], "Flyway's V1-V3, no V4")
    ok(not re.search(r"\bdata:\s*\n\s*redis:", rd(A, "tiffinbox-web/src/main/resources/application.yaml")) and "repositories:" not in rd(A, "tiffinbox-web/src/main/resources/application.yaml").split("redis:")[-1][:200], "application.yaml: no spring.data.redis key (spring.data.redis.repositories.enabled is unit 15's)")
    ex = rd("exercise", "Board.java").splitlines()
    ok(ex.count("        var board = new RedisTemplate<Object, Object>();") == 1 and not any("Map.of" in l for l in ex), "exercise/Board.java: the one template line, RedisTemplate<Object, Object>; no Map.of")
    VALUES.append("C1 files 8 + README")
elif NAME == "r250":
    A, B = sys.argv[2], sys.argv[3]
    R = rd(A, "README.md").splitlines()
    FR = [(rd(A, CY).splitlines(), "Course 8, unit 11: Redis, the cache's store under the profile \"dev\"", "(Course 8, unit 14: Redis is also a store since", 4),
          (rd(A, CY).splitlines(), "a cache is rebuilt from the database.", "(Course 8, unit 14: so is the leaderboard", 1),
          (rd(A, CY).splitlines(), "and the cache holds nothing secret.", "(Course 8, unit 14: nor does the leaderboard", 1),
          (rd(A, KHI).splitlines(), "UP while the database answers", "(Course 8, unit 14: not while the customer list is", 1),
          (rd(A, DY).splitlines(), "with Redis down, /actuator/health", "(Course 8, unit 14: with Redis down when TiffinBox starts", 1),
          (R, "`../c8-unit12/after`. **Section 3 starts here**, on this tree", "*(Course 8, unit 14: it has", 0),
          (R, "*(Course 8, unit 13, **Section 2's fifth and last change to this folder**", "*(Course 8, unit 14, **Section 3's first change to this folder**", 0)]
    for T, f, note, nxt in FR:
        h = [k for k, l in enumerate(T) if f in l]
        ok(len(h) == 1, "R.250: the sentence is in its file once: " + f[:60])
        if h:
            seg = "\n".join(T[h[0]:h[0] + nxt + 1])
            ok(note in seg and seg.index(note) > seg.index(f), "R.250: its unit 14 note follows it: " + f[:60])
    ok(sum(1 for l in R if l.startswith("## Course 8 · unit 14 — ")) == 1 and any("**Section 3 starts here: Redis as a datastore, under the profile dev.**" in l for l in R), "the README's Course 8 · unit 14 section, and Section 3 starts here")
    ok(rd(A, "README.md").count("needs no Redis") >= rd(B, "README.md").count("needs no Redis"), "the default run's \"needs no Redis\" sentences kept (still true)")
    u13 = open("../c8-unit13/README.md", encoding="utf-8").read()
    ok("Section 3 starts on" in u13 or "Section 3 starts here" in u13, "unit 13's README stays as shipped (its hand-off, now done, is noted in this unit's README, not edited there)")
    VALUES.append("R.250 sentences %d (compose.yaml 3, KitchenHealthIndicator 1, application-dev.yaml 1, the anchor README 2)" % len(FR))
elif NAME == "wib":
    L = lines(sys.argv[2]); f = sys.argv[3]
    key = "the README's lines" if f.endswith("README.md") else "then the solution's lines"
    out, on = [], False
    for l in L:
        if l.startswith("in zsh"): break
        if key in l: on = True; continue
        if on and (l.startswith("  then the solution's") or l.startswith("  the shell is now in")): break
        if on: out.append(l[4:])
    print("\n".join(out)); sys.exit(0)
elif NAME == "exercise":
    L = lines(sys.argv[2]); W = sys.argv[3]
    ok(W == "22", "the spoken line is 22 words (the brief's): %s" % W)
    blocks, cur, sh = {}, None, None
    for l in L:
        if l.startswith("in bash") or l.startswith("in zsh"): sh = l.split()[1]
        if "the README's lines" in l: cur = (sh, "readme"); blocks[cur] = []; continue
        if "then the solution's lines" in l: cur = (sh, "sol"); blocks[cur] = []; continue
        if l.startswith("  the shell is now in"): cur = None; continue
        if cur: blocks[cur].append(l.strip())
    ok(blocks.get(("bash", "readme")) == blocks.get(("zsh", "readme")) and blocks.get(("bash", "sol")) == blocks.get(("zsh", "sol")), "bash and zsh print the same")
    r, s = blocks.get(("bash", "readme"), []), blocks.get(("bash", "sol"), [])
    def g(b, rx):
        m = [x for x in (re.match(rx, l) for l in b) if x]
        return m[0].groups() if len(m) == 1 else None
    zr, zs = g(r, r"^redis-cli ZSCORE tiffinbox:leaderboard Ravi: \(([0-9.]*)\)$"), g(s, r"^redis-cli ZSCORE tiffinbox:leaderboard Ravi: \(([0-9.]*)\)$")
    er, es = g(r, r"^redis-cli EXISTS tiffinbox:leaderboard: (\d)$"), g(s, r"^redis-cli EXISTS tiffinbox:leaderboard: (\d)$")
    orr, os_ = g(r, r"^orders written: (\d+) · no exception$"), g(s, r"^orders written: (\d+) · no exception$")
    ok(orr is not None and orr == os_, "both states write the same orders, no exception: %s %s" % (orr, os_))
    ok(zr == ("",) and er == ("0",), "R.196: broken - redis-cli's ZSCORE for Ravi is empty and EXISTS 0: %s %s" % (zr, er))
    ok(zs is not None and zs[0] != "" and es == ("1",), "R.196: solved - redis-cli reads Ravi's score and EXISTS 1: %s %s" % (zs, es))
    ok("template: RedisTemplate · key serializer JdkSerializationRedisSerializer" in r and "template: StringRedisTemplate · key serializer StringRedisSerializer" in s, "the template and its serializer, read off the bean in each state")
    for b in (r, s): ok("Board: exit 0" in b and "Maven: exit 0" in b and "javac: exit 0" in b and "docker run: exit 0" in b and "docker rm -fv: exit 0" in b, "exits 0 in both states - the check is redis-cli's answer, never the exit")
    ok("StringRedisTemplate in Board.java: 0" in r and "StringRedisTemplate in Board.java: 1" in s, "the broken copy lacks StringRedisTemplate's line, the solved one holds it")
    ok(all(re.search(r"listening on 20532 afterwards: 0 · a container named c8u14-ex: 0$", l) for l in L if l.startswith("  the shell is now in")) and sum(1 for l in L if l.startswith("  the shell is now in")) == 2, "after each shell: 20532 free, the exercise's container gone")
    if zs and orr:
        VALUES.append("the line %s words · broken (RedisTemplate<Object, Object>, JdkSerializationRedisSerializer): redis-cli ZSCORE Ravi empty, EXISTS %s · solved (StringRedisTemplate): ZSCORE Ravi %s, EXISTS %s · %s orders, exit 0 both (a standalone harness JVM, Redis by the digest, no TiffinBox, no database)" % (W, er[0], zs[0], es[0], orr[0]))
elif NAME == "anchor":
    L = lines(sys.argv[2])
    pk = [x for x in (re.match(r"^  Surefire's Results line: Tests run: (\d+), Failures: 0, Errors: 0, Skipped: 0$", l) for l in L) if x]
    ok(len(pk) == 3, "three Results lines (package; verify's two executions): %d" % len(pk))
    rep = [x for x in (re.match(r"^  (\d+) tests? .* \(\d+ files?\)|^  tests (\d+)", l) for l in L) if x]
    n18 = int(pk[0].group(1)) if pk else 0; n18b = int(pk[1].group(1)) if len(pk) > 1 else 0; nit = int(pk[2].group(1)) if len(pk) > 2 else 0
    ok(n18 == n18b and nit == n18b - n18 + nit, "the package run's count = verify's first execution's")
    ok(any("absent - no container test ran" in l for l in L), "mvn package: no container test ran (Docker at nothing)")
    itl = [l for l in L if l.startswith("    REDIS IT ")]
    ok(len(itl) == 2 and "{Sunil=9000.0, Ravi=7200.0, Meera=4500.0, Priya=3600.0}" in itl[0] and "type zset · score(Ravi) 7200.0 · reverseRank(Sunil) 0 · order [Sunil, Ravi, Meera, Priya]" in itl[1], "the IT's two witnesses: the shipped bean's board and the slice's StringRedisTemplate, the same order")
    libs = [(m.group(1), int(m.group(2))) for m in (re.match(r"^  (before|after)/: (\d+) libraries", l) for l in L) if m]
    ok(len(libs) == 2 and libs[0][1] == libs[1][1], "the jar's libraries unchanged (the test starter is test scope): %s" % libs)
    ok("  gained: 0 · lost: 0" in L, "no jar gained or lost")
    starts = [s for s in sections(L) if s[0].startswith("-- start ")]
    ok(len(starts) == 3, "three starts")
    boards, logs = [], []
    for k, (h, body) in enumerate(starts, 1):
        started(body, DEVW)
        health(body, DEVW)
        rt = lbroute(body, DEVW)
        bl = [l for l in body if l.startswith("  redis-cli ZREVRANGE tiffinbox:leaderboard 0 -1 WITHSCORES: ")]
        rcb = pairs(bl[0].split(": ", 1)[1]) if len(bl) == 1 else []
        ok(rt == rcb and len(rt) == 4, "start %d: GET /leaderboard (Java, the shipped bean) = redis-cli's ZREVRANGE … WITHSCORES: %s / %s" % (k, rt, rcb))
        oc, kv = startlog(body); kc, kval = kitchen(body, DEVW)
        ok(rt and sum(v for _, v in rt) == kv == kval, "start %d: the four scores' sum = the start's kitchen value log line = /kitchen's ordersValue: %s %s %s" % (k, sum(v for _, v in rt) if rt else None, kv, kval))
        ok(oc == kc, "start %d: the start's orders cooked = /kitchen's ordersCooked: %s %s" % (k, oc, kc))
        ok(("PROBE http (%s): GET /dashboard -> 200" % DEVW) in body, "start %d: /dashboard 200" % k)
        ok(sum(1 for l in body if l == "  log: Multiple Spring Data modules found, entering strict repository configuration mode") == 3 and "  log: Found 1 JPA repository interface" in body and "  log: Found 1 JDBC repository interface" in body and "  log: Found 0 Redis repository interfaces" in body and not any(re.match(r"^  log: Found [1-9]\d* Redis", l) for l in body), "start %d: strict mode, Found 1 JPA, Found 1 JDBC, Found 0 Redis - no Redis repository yet (unit 15's)" % k)
        boards.append(rt); logs.append((oc, kv))
        jvmexit(body, 130 if k == 3 else 0)
    ok(len(boards) == 3 and boards[0] == boards[1] == boards[2], "three starts in a row against one Redis: the same board each time - the reset holds")
    b3 = starts[2][1] if len(starts) == 3 else []
    ok(any(l == "  the receipt at pause 1: kill -INT sent to the harness JVM (its pid, read off its own line)" for l in b3) and not any(l.startswith("PROBE <<< exit") or l == "PROBE hold: no SIGINT came" for l in b3) and b3.index("PROBE pause 1: the receipt reads now") == max(i for i, l in enumerate(b3) if l.startswith("PROBE ")), "start 3: SIGINT at its pause -> exit 130, no exit line of its own")
    first = starts[0][1] if starts else []
    vl = grab(first, r"^PROBE versions: Spring Boot (\S+) · Spring Framework (\S+) · Spring Data JPA (\S+) · Spring Data JDBC (\S+) · Spring Data Redis (\S+) · Lettuce (\S+?)(?:/\w+)? · Hibernate (\S+) · Flyway \(version\.txt\) (\S+)$")
    ver = vl[0].groups() if vl else ()
    ok(ver == ("4.1.2", "7.0.10", "4.1.2", "4.1.2", "4.1.2", "7.5.2.RELEASE", "7.4.13.Final", "12.4.0"), "the versions, off the run (R.246): %s" % (ver,))
    ok("  log: HHH000001: Hibernate ORM core version 7.4.13.Final" in first, "HHH000001's line")
    ok(("PROBE CacheManager beans 1 [cacheManager=%s] (%s)" % (RCM, DEVW)) in first, "cacheManager RedisCacheManager under dev (unchanged from unit 13)")
    ok(("PROBE Leaderboard beans 1 [leaderboard=%s] (%s)" % (LBC, DEVW)) in first, "the Leaderboard bean, its class")
    rv = [l for l in L if l.startswith("  the Redis container's own client: ")]
    rvx = grab(first, r"^PROBE Redis's INFO server, through the connection: redis_version:(\S+)$")
    ok(len(rv) == 1 and rv[0].endswith("INFO server: redis_version:8.10.3") and rvx and rvx[0].group(1) == "8.10.3", "redis_version 8.10.3 by redis-cli and through the connection")
    if boards and boards[0] and logs:
        VALUES.append("14/after, profile dev, PostgreSQL + Redis: /leaderboard 200 %s = redis-cli's ZREVRANGE, the sum %d = kitchen value %d = /kitchen's ordersValue, orders cooked %d, three starts in a row the same board (the reset holds), the third SIGINT -> exit 130 · health 200 · /dashboard 200 · cacheManager RedisCacheManager · the Leaderboard bean · strict mode, Found 1 JPA, 1 JDBC, 0 Redis · tests %d (mvn -o package, no Docker) and %d + %d (mvn -o verify) · libs %d -> %d (none gained) · Boot %s · Framework %s · Spring Data JPA/JDBC/Redis %s · Lettuce %s · HHH000001 %s · Flyway %s · redis_version:8.10.3" % (
            " · ".join("%s %d" % p for p in boards[0]), sum(v for _, v in boards[0]), logs[0][1], logs[0][0], n18, n18b, nit, libs[0][1], libs[1][1], ver[0], ver[1], ver[2], ver[5], ver[6], ver[7]))
elif NAME == "zset":
    L = lines(sys.argv[2])
    started(L, DEVW); health(L, DEVW)
    jz = grab(L, r"^PROBE zset \(profile dev, PostgreSQL 18\.6, the context's StringRedisTemplate\): reverseRangeWithScores\(tiffinbox:leaderboard, 0, -1\) -> (.*)$")
    jv = pairs(jz[0].group(1)) if jz else []
    rt = lbroute(L, DEVW)
    rz = grab(L, r"^    ZREVRANGE tiffinbox:leaderboard 0 -1 WITHSCORES: (.*)$")
    rv = pairs(rz[0].group(1)) if rz else []
    ok(jv == rv == rt and len(jv) == 4, "the board: StringRedisTemplate's reverseRangeWithScores = the shipped route = redis-cli's ZREVRANGE … WITHSCORES: %s / %s / %s" % (jv, rt, rv))
    j2 = grab(L, r"^PROBE zset: score\(Ravi\) ([0-9.]+) · reverseRank\(Sunil\) (\d+) · zCard (\d+) · type (\w+) · encoding (\w+)$")
    r2 = grab(L, r"^    ZSCORE tiffinbox:leaderboard Ravi: (\S+) · ZREVRANK tiffinbox:leaderboard Sunil: (\d+) · ZCARD tiffinbox:leaderboard: (\d+) · TYPE tiffinbox:leaderboard: (\w+) · OBJECT ENCODING tiffinbox:leaderboard: (\w+)$")
    if j2 and r2:
        a, b = j2[0].groups(), r2[0].groups()
        ok(float(a[0]) == float(b[0]) and a[1:] == b[1:], "score, rank, card, type, encoding: Java %s = redis-cli %s" % (a, b))
        ok(dict(jv).get("Ravi") == int(float(a[0])) and jv and jv[0][0] == "Sunil" and int(a[1]) == 0 and int(a[2]) == len(jv), "ZSCORE Ravi is Ravi's score in the board; Sunil first, rank 0; ZCARD the board's size")
    oc, kv = startlog(L); kc, kval = kitchen(L, DEVW)
    sm = grab(L, r"^PROBE zset: the four scores' sum (\d+) · /kitchen's ordersValue (\d+)$")
    s_ = sum(v for _, v in rv)
    ok(sm and int(sm[0].group(1)) == s_ == int(sm[0].group(2)) == kv == kval, "RE-MEASURE 1: the sum of redis-cli's four scores = Java's sum = /kitchen's ordersValue = the start's kitchen value log line: %s %s %s" % (s_, kv, kval))
    ok(oc == kc, "orders cooked (log) = /kitchen's ordersCooked: %s %s" % (oc, kc))
    jvmexit(L, 0)
    if j2 and rv:
        VALUES.append("14/after, profile dev, PostgreSQL + Redis, Java and redis-cli: ZREVRANGE … WITHSCORES %s · ZSCORE Ravi %s · ZREVRANK Sunil %s · ZCARD %s · TYPE %s · OBJECT ENCODING %s · the sum %d = /kitchen's ordersValue = the start's kitchen value · orders cooked %s" % (
            " · ".join("%s %d" % p for p in rv), int(float(j2[0].group(1))), j2[0].group(2), j2[0].group(3), j2[0].group(4), j2[0].group(5), s_, oc))
elif NAME == "flip":
    L = lines(sys.argv[2])
    started(L, DEVW)
    jn = grab(L, r"^PROBE flip \(a harness's keys, not the anchor's board; profile dev, PostgreSQL 18\.6\): CONFIG GET zset-max-listpack-entries, through the connection -> (\d+)$")
    rn = grab(L, r"^  the receipt at pause 1, redis-cli: CONFIG GET zset-max-listpack-entries: zset-max-listpack-entries (\d+)$")
    n = int(jn[0].group(1)) if jn else -1
    ok(rn and int(rn[0].group(1)) == n, "the threshold: CONFIG GET through the connection = redis-cli's")
    got = {}
    for size in (n, n + 1):
        j = grab(L, r"^PROBE flip: h14:z%d · zCard (\d+) · type (\w+) · encoding (\w+)$" % size)
        r = grab(L, r"^    h14:z%d: ZCARD (\d+) · TYPE (\w+) · OBJECT ENCODING (\w+)$" % size)
        if j and r:
            ok(j[0].groups() == r[0].groups() and int(j[0].group(1)) == size, "h14:z%d: Java %s = redis-cli %s, its card the size the threshold gave" % (size, j[0].groups(), r[0].groups()))
            got[size] = r[0].group(3)
    ok(got.get(n) == "listpack" and got.get(n + 1) == "skiplist", "the flip: n members listpack, n + 1 skiplist: %s" % got)
    ok("PROBE flip: deleted 2 harness keys" in L and "  after the JVM, redis-cli --scan --pattern 'h14:*': 0 keys" in L, "the harness's keys deleted")
    jvmexit(L, 0)
    VALUES.append("the harness's keys (labelled), 14/after, profile dev: CONFIG GET zset-max-listpack-entries %d · h14:z%d %s · h14:z%d %s (Java and redis-cli)" % (n, n, got.get(n), n + 1, got.get(n + 1)))
elif NAME == "structs":
    L = lines(sys.argv[2])
    started(L, DEVW)
    jh = grab(L, r"^PROBE structs \(a harness's keys, not the anchor's; profile dev, PostgreSQL 18\.6\): a hash from the seed's row, HSET h14:customer:Ravi \(a LinkedHashMap\) -> entries \{(.*)\} · type (\w+) · encoding (\w+)$")
    rh = grab(L, r"^    h14:customer:Ravi: TYPE (\w+) · HGETALL (.*) · OBJECT ENCODING (\w+)$")
    if jh and rh:
        je = [tuple(x.split("=")) for x in jh[0].group(1).split(", ")]
        t = rh[0].group(2).split(); re_ = [(t[i], t[i + 1]) for i in range(0, len(t), 2)]
        ok(je == re_ and jh[0].group(2) == rh[0].group(1) == "hash" and jh[0].group(3) == rh[0].group(3), "the hash: Java's entries %s = redis-cli's HGETALL %s, the field order the LinkedHashMap's; TYPE and encoding the same" % (je, re_))
    js = grab(L, r"^PROBE structs: the meal types' set \(tiffinbox\.meal-types\), SADD h14:meal-types -> members, sorted \[(.*)\] · type (\w+) · encoding (\w+)$")
    rs = grab(L, r"^    h14:meal-types: TYPE (\w+) · SMEMBERS, sorted (.*) · OBJECT ENCODING (\w+)$")
    if js and rs: ok(js[0].group(1).split(", ") == rs[0].group(2).split() and js[0].group(2) == rs[0].group(1) == "set" and js[0].group(3) == rs[0].group(3), "the set: Java's members = redis-cli's SMEMBERS, sorted; TYPE set, the encoding the same")
    jc = grab(L, r"^PROBE structs: a counter, INCR h14:orders-placed -> (\d+) · type (\w+) · encoding (\w+)$")
    rcn = grab(L, r"^    h14:orders-placed: TYPE (\w+) · GET (\d+) · OBJECT ENCODING (\w+)$")
    if jc and rcn: ok(jc[0].group(1) == rcn[0].group(2) and jc[0].group(2) == rcn[0].group(1) == "string" and jc[0].group(3) == rcn[0].group(3), "the counter: INCR's answer = redis-cli's GET; TYPE string, the encoding the same")
    ok("PROBE structs: deleted 3 harness keys" in L and "  after the JVM, redis-cli --scan --pattern 'h14:*': 0 keys" in L, "the harness's keys deleted")
    jvmexit(L, 0)
    if jh and js and jc:
        VALUES.append("the harness's keys (labelled), 14/after, profile dev: h14:customer:Ravi hash %s {%s} · h14:meal-types set %s [%s] · h14:orders-placed INCR %s string %s (Java and redis-cli)" % (jh[0].group(3), jh[0].group(1), js[0].group(3), js[0].group(1), jc[0].group(1), jc[0].group(3)))
elif NAME == "twice":
    L = lines(sys.argv[2])
    started(L, DEVW)
    b0 = grab(L, r"^PROBE twice \(the harness calls the shipped Leaderboard\.record, not the start; profile dev, PostgreSQL 18\.6\): the board the start left -> (.*)$")
    b2 = grab(L, r"^PROBE twice: two fills, (\d+) and (\d+) record calls, no reset between -> (.*)$")
    r2 = grab(L, r"^  the receipt at pause 1, redis-cli: ZREVRANGE tiffinbox:leaderboard 0 -1 WITHSCORES: (.*)$")
    b1 = grab(L, r"^PROBE twice: then reset\(\) and one fill \((\d+) record calls\), the start's own shape -> (.*)$")
    ra = grab(L, r"^  redis-cli ZREVRANGE tiffinbox:leaderboard 0 -1 WITHSCORES: (.*)$")
    if b0 and b2 and r2 and b1 and ra:
        single, double, rdouble, again, rafter = pairs(b0[0].group(1)), pairs(b2[0].group(3)), pairs(r2[0].group(1)), pairs(b1[0].group(2)), pairs(ra[0].group(1))
        ok(double == rdouble, "the doubled board: Java = redis-cli: %s / %s" % (double, rdouble))
        ok(len(single) == 4 and double == [(n, 2 * v) for n, v in single], "each doubled score is twice the single fill's: %s -> %s" % (single, double))
        ok(again == rafter == single, "reset() and one fill: the start's board again, by Java and redis-cli")
        ok("PROBE twice: reset() first, so the harness's two fills start from an empty key -> zCard 0" in L, "the harness empties the key first")
        VALUES.append("the harness over the shipped Leaderboard.record (labelled), 14/after, profile dev: two fills, no reset -> %s (Java and redis-cli; each twice the start's %s) · the start's own shape resets first: anchor's three starts" % (" · ".join("%s %d" % p for p in double), " · ".join("%s %d" % p for p in single)))
    jvmexit(L, 0)
elif NAME == "trap":
    L = lines(sys.argv[2])
    started(L, DEVW)
    tb = grab(L, r"^PROBE the template bean redisTemplate: org\.springframework\.data\.redis\.core\.RedisTemplate · key serializer (\S+) · value serializer (\S+)$")
    ok(tb and tb[0].groups() == (JDK, JDK), "Boot's redisTemplate bean: RedisTemplate, JdkSerializationRedisSerializer for key and value, read off the bean")
    sb = grab(L, r"^PROBE the template bean stringRedisTemplate: org\.springframework\.data\.redis\.core\.StringRedisTemplate · key serializer (\S+) · value serializer (\S+)$")
    ok(sb and sb[0].groups() == (STR, STR), "stringRedisTemplate: StringRedisSerializer")
    tt = grab(L, r"^PROBE trap \(a harness's fill through Boot's redisTemplate bean, not the anchor's Leaderboard; profile dev, PostgreSQL 18\.6\): org\.springframework\.data\.redis\.core\.RedisTemplate · key serializer (\S+) · value serializer (\S+)$")
    ok(tt and tt[0].groups() == (JDK, JDK), "the trap's template is that bean")
    ok("PROBE trap: the start's board deleted first through StringRedisTemplate, so the plain key is clean: delete -> true" in L, "the plain key cleaned first")
    nn = grab(L, r"^PROBE trap: (\d+) incrementScore calls through redisTemplate, each returned without an exception$")
    sn = grab(L, r"^PROBE trap: StringRedisTemplate on the plain key: hasKey (\w+) · score\(Ravi\) (\w+)$")
    ok(sn and sn[0].groups() == ("false", "null"), "StringRedisTemplate on the plain key: no key, Ravi's score null")
    on = grab(L, r"^PROBE trap: redisTemplate on its own key: hasKey (\w+) · score\(Ravi\) ([0-9.]+) · zCard (\d+)$")
    sc = grab(L, r'^    --no-raw --scan --pattern \'\*leaderboard\*\': (.*)$')
    ok(sc and sc[0].group(1) == '"\\xac\\xed\\x00\\x05t\\x00\\x15tiffinbox:leaderboard"', "redis-cli --no-raw --scan: the key's bytes: %s" % (sc[0].group(1) if sc else None))
    ev = grab(L, r"^    --no-raw EVAL \(KEYS finds the key, which holds bytes a shell cannot pass; ZRANGE … WITHSCORES on it\): (.*)$")
    mem = re.findall(r'"(\\xac\\xed\\x00\\x05t\\x00\\x0[0-9a-f])([A-Za-z]+)" "(\d+)"', ev[0].group(1)) if ev else []
    ok(len(mem) == 4 and ('\\xac\\xed\\x00\\x05t\\x00\\x04', 'Ravi') in [(a, b) for a, b, _ in mem], "the members' bytes, Ravi's \\xac\\xed\\x00\\x05t\\x00\\x04Ravi: %s" % mem)
    ok(all(int(a[-2:], 16) == len(b) for a, b, _ in mem), "each member's length byte is its name's length (Java serialization's string header)")
    ravi = [int(s) for a, b, s in mem if b == "Ravi"]
    ok(on and ravi and float(on[0].group(2)) == ravi[0] and on[0].group(1) == "true" and int(on[0].group(3)) == len(mem), "the object template reads its own key back: Ravi's score = redis-cli's for the byte member, card the same")
    zs = grab(L, r"^    ZSCORE tiffinbox:leaderboard Ravi: \(([^)]*)\) · EXISTS tiffinbox:leaderboard: (\d)$")
    ok(zs and zs[0].groups() == ("", "0"), "redis-cli ZSCORE tiffinbox:leaderboard Ravi empty, EXISTS 0 (R.396's negation; control: zset)")
    ok("PROBE trap: redisTemplate.delete -> true" in L and "  after the JVM, redis-cli --no-raw --scan --pattern '*leaderboard*': 0 keys" in L, "the trap's key deleted; --scan empty after")
    ex = jvmexit(L, 0)
    ok(any(re.search(r"WARN (\d+) \(%s: \1\) · ERROR 0 · lines naming an Exception or an Error class 0$" % re.escape(NETTY), l) for l in L), "no exception: ERROR 0, no line naming an Exception, no WARN but Netty's DNS line")
    if sc and mem and on:
        VALUES.append("the harness's fill through Boot's redisTemplate (labelled), 14/after, profile dev: JdkSerializationRedisSerializer (key and value, read off the bean) · redis-cli --no-raw --scan %s · the member %s · ZSCORE tiffinbox:leaderboard Ravi empty · EXISTS 0 · StringRedisTemplate score(Ravi) null · the object template reads its own key back %s · no exception (ERROR 0, exception lines 0)" % (
            sc[0].group(1), [a + b for a, b, _ in mem if b == "Ravi"][0], on[0].group(2)))
elif NAME == "absent":
    L = lines(sys.argv[2])
    ok(any(re.search(r"--spring\.data\.redis\.port=20539, where nothing listens \(lsof: 0 listeners\)", l) for l in L), "Redis absent: 20539 asserted unbound")
    e = grab(L, r"^  the JVM's exit: (\d+) · then curl /actuator/health on 20530: (\d+) · listening on 20530: (\d+)$")
    ok(e and e[0].groups() == ("1", "000", "0"), "the start stops: exit 1, curl 000, nothing on 20530")
    c = grab(L, r"^  its log: \"Error creating bean with name 'tiffinBoxServer'\" (\d+) lines · \"RedisConnectionFailureException: Unable to connect to Redis\" (\d+) · \"Application run failed\" (\d+) · \"Started TiffinBoxApp\" (\d+) · \"orders cooked\" (\d+)$")
    ok(c and int(c[0].group(1)) >= 1 and int(c[0].group(2)) >= 1 and int(c[0].group(3)) >= 1 and c[0].group(4) == "0" and c[0].group(5) == "0", "the three phrases each present, no Started line, no orders cooked line")
    ok("  its cause: Caused by: org.springframework.data.redis.RedisConnectionFailureException: Unable to connect to Redis" in L, "the cause line")
    VALUES.append("14/after, profile dev, PostgreSQL up, Redis absent: the start stops - Error creating bean with name 'tiffinBoxServer' <- RedisConnectionFailureException: Unable to connect to Redis, Application run failed, exit 1, curl 000, nothing on 20530 (control: anchor)")
elif NAME == "default":
    L = lines(sys.argv[2])
    started(L, DEFW)
    health(L, DEFW)
    ok(("PROBE http (%s): GET /leaderboard -> 404" % DEFW) in L and ("PROBE http (%s): GET /dashboard -> 200" % DEFW) in L, "default run: /leaderboard 404, /dashboard 200")
    ok(("PROBE noboard (%s): getBeansOfType(Leaderboard) 0 · GET /leaderboard -> 404" % DEFW) in L and ("PROBE Leaderboard beans 0 [] (%s)" % DEFW) in L, "no Leaderboard bean")
    ok(("PROBE CacheManager beans 1 [cacheManager=%s] (%s)" % (CAF, DEFW)) in L, "the default run's cache: Caffeine, in the JVM")
    ok(not any(l.startswith("PROBE RedisConnectionFactory") for l in L), "no Redis connection made")
    pk = [x for x in (re.match(r"^  Surefire's Results line: Tests run: (\d+), Failures: 0, Errors: 0, Skipped: 0$", l) for l in L) if x]
    ok(len(pk) == 1, "the package run's Results line")
    jvmexit(L, 0)
    if pk: VALUES.append("14/after, default run, H2, no Redis, no Docker: health 200 · /leaderboard 404 · /dashboard 200 · Leaderboard beans 0 · CaffeineCacheManager · the %s under mvn -o package, Docker at nothing" % pk[0].group(1))
elif NAME == "notes":
    L = lines(sys.argv[2])
    md = [m.groups() for m in (re.match(r"^  \.\./(\S+): md5 ([0-9a-f]{32}) · at 3478b30 ([0-9a-f]{32})$", l) for l in L) if m]
    ok(len(md) == 4 and all(a == b for _, a, b in md), "the four files never edited: md5 now = md5 at 3478b30 (%s)" % [f for f, _, _ in md])
    ok(any(re.match(r"^  quoted in README\.md byte for byte: c8-unit09/exercise/README\.md:3 1 · SOLUTION\.md:3 1 · c8-unit11/README\.md:515 1 and :516 1 · c8-unit12/pinned\.txt \(C8-22\) 1$", l) for l in L), "the quoted lines, byte for byte (R.370)")
    kh = grab(L, r"^  tiffinbox-web/src/main/java/com/tiffinbox/web/KitchenHealthIndicator\.java: before/ md5 ([0-9a-f]{32}) · after/ md5 ([0-9a-f]{32}) · lines naming Course 8, unit 14: (\d+)$")
    ok(kh and kh[0].group(1) != kh[0].group(2) and int(kh[0].group(3)) >= 1, "KitchenHealthIndicator's md5 moves with #119's note")
    ss = sections(L)
    ren = [b for h, b in ss if h.startswith("-- #119")]
    cold = [b for h, b in ss if h.startswith("-- then a TiffinBox started with the table renamed")]
    rb = ren[0] if ren else []
    r0 = grab(rb, r"^PROBE rename \(profile dev, PostgreSQL 18\.6\), before the receipt's first pause, a request that reads the list \(the cache then holds it\): GET /actuator/health -> (\d+)$")
    rr = [grab(rb, r"^PROBE rename \(profile dev, PostgreSQL 18\.6\), after the receipt's pause %d: (.*)$" % k) for k in (1, 2, 3)]
    ok(any(l.startswith("  the receipt at pause 1, psql (a second client, PostgreSQL): alter table customer rename to customer_renamed -> tables named customer 0 · redis-cli EXISTS 'customers::SimpleKey []': 1") for l in rb), "psql renamed the table (tables named customer 0) while the cached list was in Redis (EXISTS 1)")
    ok(any(l.startswith("  the receipt at pause 2, redis-cli: FLUSHALL -> OK · EXISTS 'customers::SimpleKey []': 0") for l in rb), "redis-cli emptied the cache (EXISTS 0)")
    W1 = "GET /actuator/health -> 200 UP · GET /actuator/health/readiness -> 200 UP · GET /dashboard -> 500 · GET /customers -> 200"
    W2 = "GET /actuator/health -> 503 DOWN · GET /actuator/health/readiness -> 503 DOWN · GET /dashboard -> 500 · GET /customers -> 500"
    W3 = "GET /actuator/health -> 200 UP · GET /actuator/health/readiness -> 200 UP · GET /dashboard -> 200 · GET /customers -> 200"
    got = [x[0].group(1) if x else None for x in rr]
    ok(r0 and r0[0].group(1) == "200", "a first request reads the list: health 200")
    ok(got[0] == W1, "#119, the table renamed, the list in the cache: health UP, readiness UP, /customers 200, /dashboard 500: %s" % got[0])
    ok(got[1] == W2, "#119, the table renamed, the cache emptied: health DOWN, readiness DOWN, /customers 500, /dashboard 500: %s" % got[1])
    ok(got[2] == W3, "renamed back: every route 200: %s" % got[2])
    r1 = rr[0]
    cb = cold[0] if cold else []
    ok("PROBE started: no · org.springframework.beans.factory.BeanCreationException" in cb and "  log: Schema validation: missing table [customer]" in cb, "a cold JVM with the table renamed does not start: Schema validation: missing table [customer]")
    jvmexit(cb, 1)
    if r1 and kh: VALUES.append("⚑11: c8-unit09/exercise/README.md, SOLUTION.md, c8-unit11/README.md and c8-unit12/pinned.txt unchanged (md5 = 3478b30's) · KitchenHealthIndicator.java %s… -> %s… · #119 (14/after, profile dev, PostgreSQL + Redis): the customer table renamed under a running TiffinBox, the list in Redis's cache -> health 200 UP, readiness UP, /customers 200, /dashboard 500; the cache emptied too -> health 503 DOWN, /customers 500; a cold start with it renamed -> Schema validation: missing table [customer], exit 1" % (kh[0].group(1)[:8], kh[0].group(2)[:8]))
elif NAME == "seven":
    L = lines(sys.argv[2]); S466 = sys.argv[3]
    h = [m.group(1) for m in (re.search(r"the seven responses: 7 lines · md5 ([0-9a-f]{32})", l) for l in L) if m]
    ok(len(h) == 2 and h[0] == h[1] == S466, "the seven on before/ and after/ = Course 7's published md5")
    ok(sum(1 for l in L if l == "  GET /dashboard: 200") == 2, "GET /dashboard 200 on both")
    ok("  exit 0 · cmp with xcheck.sql (= Course 7's capstone's): the same, byte for byte" in L, "Hibernate's schema script = xcheck.sql")
    ok("  the seven, after/ against before/: lines that differ: 0" in L, "0 lines differ")
    ok(sum(1 for l in L if l.startswith("  GET /actuator/health/readiness -> 200 · GET /actuator/health -> 200 · GET /leaderboard -> 404 ")) == 2, "the jar's default run: health 200, /leaderboard 404, before and after")
    VALUES.append("the seven %s… on before/ and after/ (0 lines differ) · GET /dashboard 200 · health 200 · /leaderboard 404 on the default run · Hibernate's script = xcheck.sql" % S466[:8])
else:
    print("FAIL no check named " + NAME); sys.exit(1)
for o in oks: print("ok " + o)
for f in fails: print("FAIL " + f)
print("VALUES " + "; ".join(VALUES))
sys.exit(1 if fails else 0)
