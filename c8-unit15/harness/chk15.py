"""Unit 15's checks (python3 -I -B harness/chk15.py NAME ARGS...). Each capture's numbers are asserted against a second witness of the
same run - never a typed figure (R.398): the shipped KitchenOrders' answers (count(), findAll(), the finders, findById, existsById) against
redis-cli inside the Redis container (SCARD, SMEMBERS, EXISTS, TYPE, HGETALL, PTTL); the start's saves against the start's own orders
(TiffinBox's "orders cooked:" line, /kitchen, the customers and meal types the finders return); MONITOR's lines counted per operation
against the shape the shipped entity's own source gives (its @Indexed fields, its @TimeToLive); the exit code against the log's phrases
and curl; Surefire's XML against Maven's Results lines; the seven's md5 against Course 7's published one.
Prints ok/FAIL lines and one VALUES line; exits 1 on any FAIL.
  static AFTER BEFORE   the change itself, read off the files (C2), and receipts.sh's polls (R.412)
  r250 AFTER BEFORE     the anchor README's, YAML's, compose's and Javadoc's sentences C2 made false: each carries its note
  wib CAPTURE FILE      the lines the exercise's block printed for FILE (bash's), for receipts.sh to compare with "What it prints"
  exercise|anchor|keys|monitor|ttl|events|nolisten|stale|startstop|noconfig|default|seven CAPTURE [...]"""
import difflib, filecmp, os, re, sys

NAME = sys.argv[1]
fails, oks, VALUES = [], [], []


def ok(c, msg):
    (oks if c else fails).append(msg)


def raw(p):
    return open(p, encoding="utf-8").read().splitlines()


def lines(p):
    """the capture's lines, every indent of two spaces or more read as two (a pause's lines are printed one level deeper)"""
    return [re.sub(r"^ {2,}", "  ", l) for l in raw(p)]


def grab(L, rx, n=1):
    m = [x for x in (re.search(rx, l) for l in L) if x]
    ok(len(m) == n, "%d line(s) match %s (found %d)" % (n, rx[:90], len(m)))
    return m


def one(L, rx):
    m = grab(L, rx)
    return m[0] if m else None


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
ONW = "the shipped RedisDatastore, keyspace events ON_STARTUP"
OFFW = "the harness's configuration, keyspace events OFF"
RCM = "org.springframework.data.redis.cache.RedisCacheManager"
NETTY = "Netty's DNS line on macOS"
W = "tiffinbox-web/src/main/java/com/tiffinbox/web/"
KO = W + "KitchenOrder.java"; KOS = W + "KitchenOrders.java"; RD = W + "RedisDatastore.java"; TBS = W + "TiffinBoxServer.java"
TP = "tiffinbox-core/src/main/java/com/tiffinbox/TiffinBoxProperties.java"
AY = "tiffinbox-web/src/main/resources/application.yaml"; CY = "compose.yaml"; DY = "tiffinbox-web/src/main/resources/application-dev.yaml"
RS = "tiffinbox-web/src/test/java/slice/RedisSlice.java"; IT = "tiffinbox-web/src/test/java/com/tiffinbox/web/RedisDatastoreIT.java"


def rd(t, p): return open(os.path.join(t, p), encoding="utf-8").read()


def code(t): return [l for l in t.splitlines() if not l.strip().startswith(("*", "/**", "*/", "//"))]


def adds(B, A, p):
    return [l for l in difflib.unified_diff(rd(B, p).splitlines(), rd(A, p).splitlines(), lineterm="", n=0) if l[:1] in "+-" and not l.startswith(("+++", "---"))]


def jvmexit(body, code_, msg=""):
    m = [x for x in (re.match(r"^  exit %d · its log, every line but the harness's own PROBE lines: WARN (\d+) \(%s: (\d+)\) · ERROR (\d+) · lines naming an Exception or an Error class (\d+)$" % (code_, re.escape(NETTY)), l) for l in body) if x]
    ok(len(m) == 1, "%sthe JVM's exit is %d (%d line)" % (msg, code_, len(m)))
    return m[0] if m else None


def clean(body, msg=""):
    """no ERROR, no line naming an exception, WARN only Netty's DNS line"""
    m = jvmexit(body, 0, msg)
    if m: ok(m.group(1) == m.group(2) and m.group(3) == "0" and m.group(4) == "0", "%sno exception: ERROR 0, no line naming an Exception, WARN = Netty's DNS line only (%s)" % (msg, m.groups()))
    return m


def sset(s):
    return sorted(s.split()) if s.strip() else []


def indexed(after):
    c = code(rd(after, KO))
    return sum(1 for l in c if l.strip() == "@Indexed")


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
    want = ["README.md", CY, AY, TBS, TP, RS, IT, "new " + KO, "new " + KOS, "new " + RD]
    ok(sorted(changed) == sorted(want), "C2: the files new and changed are KitchenOrder, KitchenOrders, RedisDatastore, TiffinBoxServer, TiffinBoxProperties, application.yaml, compose.yaml, RedisSlice, RedisDatastoreIT and the README - nothing gone, application-dev.yaml and both pom.xml untouched: %s" % sorted(changed))
    ko = code(rd(A, KO))
    ok('@RedisHash("kitchen-order")' in ko and sum(1 for l in ko if l.strip() == "@Id") == 1 and indexed(A) == 2 and sum(1 for l in ko if l.strip() == "@TimeToLive") == 1, "KitchenOrder: @RedisHash(\"kitchen-order\"), one @Id, two @Indexed, one @TimeToLive")
    kj = "\n".join(ko)
    ok(re.search(r"@Indexed\s+private String customer;", kj) and re.search(r"@Indexed\s+private String mealType;", kj) and re.search(r"@TimeToLive\s+private Long ttl;", kj) and re.search(r"private int value;", kj), "KitchenOrder: @Indexed customer, @Indexed mealType, int value, @TimeToLive Long ttl")
    ok("Course 8, unit 15" in rd(A, KO) and "Course 8, unit 15" in rd(A, KOS) and "Course 8, unit 15" in rd(A, RD), "the three new classes: their Course 8, unit 15 Javadoc")
    ks = "\n".join(code(rd(A, KOS)))
    ok("interface KitchenOrders extends CrudRepository<KitchenOrder, String>" in ks and ks.count("List<KitchenOrder> findBy") == 3 and "findByMealType(String mealType)" in ks and "findByCustomer(String customer)" in ks and "findByCustomerAndMealType(String customer, String mealType)" in ks and "@Query" not in ks and "Pageable" not in ks, "KitchenOrders: a CrudRepository, the three derived finders, no @Query, no paging")
    rc = code(rd(A, RD))
    ok('@Profile("dev")' in rc and "@Configuration(proxyBeanMethods = false)" in rc and "@EnableRedisRepositories(basePackageClasses = KitchenOrders.class, enableKeyspaceEvents = EnableKeyspaceEvents.ON_STARTUP)" in rc, "RedisDatastore: @Configuration @Profile(\"dev\") @EnableRedisRepositories(basePackageClasses = KitchenOrders.class, enableKeyspaceEvents = ON_STARTUP) (⚑4, ⚑6)")
    rj = rd(A, RD)
    ok("while a TiffinBox under \"dev\" is running" in rj and "re-saves those ids" in rj.replace("\n *", "") or "until the next start re-saves those ids" in rj.replace("\n * ", " "), "RedisDatastore's Javadoc: ON_STARTUP's condition (a running TiffinBox; the next start re-saves those ids)")
    t = code(rd(A, TBS)); tj = "\n".join(t)
    ok("    private final ObjectProvider<KitchenOrders> rail;" in t and any("ObjectProvider<Leaderboard> board, ObjectProvider<KitchenOrders> rail) {" in l for l in t), "TiffinBoxServer: the constructor takes ObjectProvider<KitchenOrders> beside ObjectProvider<Leaderboard>")
    s0 = tj[tj.index("void start() throws Exception {"):]
    s0 = s0[:s0.index("kitchen.close();")]
    sv = re.findall(r"orders\.save\(new KitchenOrder\((.*)\)\);", s0)
    ok(len(sv) == 1 and sv[0] == 'c.name() + "-" + (day + 1), order.customer(), c.mealType(), order.value(), orderTtl', "start(): one save per placed order, the id the customer and the day (deterministic - no UUID, no clock), the order's own customer and value, the customer's meal type, the time to live from the setting: %s" % sv)
    ok(not re.search(r"UUID|currentTimeMillis|nanoTime|Instant\.now|Random", s0), "start(): nothing random or clock-based in the id")
    ix = [s0.find(x) for x in ("for (Customer c : repo.findAll())", "lb.record(order.customer(), order.value());", "orders.save(new KitchenOrder(")]
    ok(-1 not in ix and ix[0] < ix[1] < ix[2], "start(): the save in the same loop as the leaderboard's record, after it, from the same order: %s" % ix)
    ok("try" not in s0 and "catch" not in s0, "start(): the save is not guarded - no try/catch (⚑4: under dev Redis is required)")
    ok("settings.kitchenOrderTtl() == null || settings.kitchenOrderTtl().isZero() ? null : settings.kitchenOrderTtl().toSeconds()" in tj, "TiffinBoxServer: the time to live from tiffinbox.kitchen-order-ttl, null when the setting is absent or zero (an untimed save)")
    tp = rd(A, TP)
    ok("@NotBlank String shutdownToken, Duration kitchenOrderTtl) {" in tp and "kitchenOrderTtl=" in tp, "TiffinBoxProperties: kitchenOrderTtl, a Duration, no constraint (absent is allowed), in its toString")
    ay = rd(A, AY)
    ok(re.search(r"(?m)^  data:\n    redis:\n      repositories:\n        enabled: false$", ay) is not None, "application.yaml: spring.data.redis.repositories.enabled: false (⚑4)")
    ok(re.search(r"(?m)^  kitchen-order-ttl: \S+$", ay) is not None and "Course 8, unit 15" in ay, "application.yaml: tiffinbox.kitchen-order-ttl, with its Course 8, unit 15 comment")
    ad = adds(B, A, AY)
    ok(all(l.startswith("+") for l in ad), "application.yaml: lines added only, none removed or moved")
    cd = adds(B, A, CY)
    ok(all(l.startswith("+") and l[1:].lstrip().startswith("#") for l in cd) and sum("Course 8, unit 15" in l for l in cd) == 3, "compose.yaml: comment lines added only, three Course 8, unit 15 notes (the key sentence, the secrets note, ⚑15's note), no line removed")
    ca = rd(A, CY)
    ok("volumes:\n  data:" in ca and ca.count("- data:") == 1 and "Still no volume" in ca, "compose.yaml: still one volume, Postgres's - none added for Redis (⚑15)")
    it = rd(A, IT)
    ok("@Import({Leaderboard.class, RedisDatastore.class})" in it and '@ActiveProfiles("dev")' in it and "@DataRedisTest" in it and len(re.findall(r"(?m)^    @Test$", it)) == 2 and "@Autowired KitchenOrders orders;" in it, "RedisDatastoreIT: @Import({Leaderboard.class, RedisDatastore.class}) under \"dev\", a second test on the shipped KitchenOrders (⚑14)")
    ok(all(l.startswith("+ *") for l in adds(B, A, RS)), "RedisSlice: Javadoc lines added only (R.250)")
    ok(sorted(os.listdir(os.path.join(A, "tiffinbox-core/src/main/resources/db/migration"))) == ["V1__customer_and_pause.sql", "V2__seed.sql", "V3__customer_audit_columns.sql"], "Flyway's V1-V3, no V4")
    for f in (KO, KOS, RD, TBS, AY, CY):
        ok("Map.of" not in "\n".join(code(rd(A, f))), "no Map.of in " + f + " (R.411)")
    ex = rd("exercise", "Rail.java").splitlines()
    ok(ex.count("@EnableRedisRepositories(basePackageClasses = KitchenOrders.class)") == 1 and not any("ON_STARTUP" in l for l in ex) and not any("Map.of" in l for l in ex), "exercise/Rail.java: the one marked line, keyspace events off (the annotation's default); no Map.of")
    # R.412 in receipts.sh: between a poll that reads EXISTS to 0 and the next clean read, no sleep; every clean read is a pollq
    rs = open("receipts.sh", encoding="utf-8").read().splitlines()
    bad = []
    for i, l in enumerate(rs):
        if re.search(r"pollq .* 0 EXISTS ", l):
            j = i + 1
            while j < len(rs) and not re.search(r"^\s*(pollq |echo \"  then: |\*\) |;;|[a-z0-9]+\(\) \{)", rs[j]):
                if re.search(r"\bsleep\b", rs[j]): bad.append(j + 1)
                j += 1
    ok(not bad, "R.412: no sleep between a poll that reads EXISTS to 0 and the clean read after it (receipts.sh lines %s)" % bad)
    pq = [l for l in rs if l.lstrip().startswith("pollq ")]
    ok(len(pq) >= 8 and all(re.search(r'^\s*pollq "[^"]+" \d+ (EXISTS|SCARD) ', l) for l in pq), "R.412: every clean read waits on a count condition (pollq WHAT WANT EXISTS|SCARD …): %d polls" % len(pq))
    pf = [l for l in rs if l.startswith("pollq() {")]
    ok(len(pf) == 1, "R.412: one poll function, which prints its count")
    VALUES.append("C2 files 9 + README")
elif NAME == "r250":
    A, B = sys.argv[2], sys.argv[3]
    R = rd(A, "README.md").splitlines()
    FR = [(rd(A, CY).splitlines(), "hands TiffinBox its address: no spring.data.redis key anywhere.", "(Course 8, unit 15: one spring.data.redis key since", 1),
          (rd(A, CY).splitlines(), "and docker compose down keeps Postgres's data, in its volume, and loses Redis's.)", "(Course 8, unit 15: the kitchen orders too are Redis's own", 1),
          (rd(A, CY).splitlines(), "(Course 8, unit 14: nor does the leaderboard", "(Course 8, unit 15: nor do the kitchen orders", 1),
          (R, "No `spring.data.redis` key anywhere: Boot's Docker Compose support hands TiffinBox Redis's address", "*(Course 8, unit 15: one `spring.data.redis` key since", 1),
          (R, "Spring Data Redis, with no repository of its own", "*(Course 8, unit 15: under the profile \"dev\" it has one since", 0),
          (R, "`spring.data.redis` key anywhere (`spring.data.redis.repositories.enabled` is unit 15's)", "*(Course 8, unit 15: it is in `application.yaml`", 0),
          (rd(A, RS).splitlines(), "and Spring Data Redis's repositories, and leaves the web layer", "Course 8, unit 15: the slice starts none of Spring Data Redis's repositories since", 12)]
    for T, f, note, nxt in FR:
        h = [k for k, l in enumerate(T) if f in l]
        ok(len(h) == 1, "R.250: the sentence is in its file once: " + f[:60])
        if h:
            seg = "\n".join(T[h[0]:h[0] + nxt + 1])
            ok(note in seg and seg.index(note) > seg.index(f), "R.250: its unit 15 note follows it: " + f[:60])
    ok("(no\n  # spring.data.redis key here)" in rd(A, DY), "application-dev.yaml's \"no spring.data.redis key here\" stays true (the key is application.yaml's) - untouched")
    ok(sum(1 for l in R if l.startswith("## Course 8 · unit 15 — ")) == 1, "the README's Course 8 · unit 15 section")
    ok(rd(A, "README.md").count("needs no Redis") >= rd(B, "README.md").count("needs no Redis"), "the default run's \"needs no Redis\" sentences kept (still true)")
    u14 = open("../c8-unit14/README.md", encoding="utf-8").read()
    ok("U15 moves the anchor next" in u14 or "Unit 15 moves the anchor next" in u14 or "## Next" in u14, "unit 14's README stays as shipped (its hand-off, now done, is quoted in this unit's README, not edited there)")
    VALUES.append("R.250 sentences %d (compose.yaml 3, the anchor README 3, RedisSlice 1)" % len(FR))
elif NAME == "wib":
    L = raw(sys.argv[2]); f = sys.argv[3]
    key = "the README's lines" if f.endswith("README.md") else "then the solution's lines"
    out, on = [], False
    for l in L:
        if l.startswith("in zsh"): break
        if key in l: on = True; continue
        if on and (l.startswith("  then the solution's") or l.startswith("  the shell is now in")): break
        if on: out.append(l[4:])
    print("\n".join(out)); sys.exit(0)
elif NAME == "exercise":
    L = lines(sys.argv[2]); Wd = sys.argv[3]
    ok(Wd == "25", "the spoken line is 25 words (the brief's): %s" % Wd)
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
    cr, cs = g(r, r"^count\(\): (\d+)$"), g(s, r"^count\(\): (\d+)$")
    sr, ss = g(r, r"^redis-cli SCARD kitchen-order: (\d+)$"), g(s, r"^redis-cli SCARD kitchen-order: (\d+)$")
    fr, fs = g(r, r"^findAll\(\): \[(.*)\]$"), g(s, r"^findAll\(\): \[(.*)\]$")
    vr, vs = g(r, r"^redis-cli SMEMBERS kitchen-order:mealType:VEG: \((.*)\)$"), g(s, r"^redis-cli SMEMBERS kitchen-order:mealType:VEG: \((.*)\)$")
    sv = [g(b, r"^orders saved: (\d+) \(o1 and o2 with a time to live, o3 with none\) · count\(\) (\d+)$") for b in (r, s)]
    ok(sv[0] is not None and sv[0] == sv[1] and sv[0][0] == sv[0][1], "both states save the same orders, count() right after = the orders saved: %s" % sv)
    ok("the timed hashes gone (EXISTS kitchen-order:o1, kitchen-order:o2: 0), the JVM still up" in r and "the timed hashes gone (EXISTS kitchen-order:o1, kitchen-order:o2: 0), the JVM still up" in s, "both states: the two timed hashes gone, read with the JVM up")
    nr = fr[0].split(", ").count("null") if fr else -1
    ok(cr and sr and cr == sr and sv[0] and cr[0] == sv[0][0] and nr == 2 and fr and len(fr[0].split(", ")) == int(cr[0]), "R.196: broken - count() still the orders saved = redis-cli's SCARD, findAll() two nulls among them: %s %s %s" % (cr, sr, fr))
    ok(cs and ss and cs == ss and cs[0] == "1" and fs and "null" not in fs[0] and fs[0].count("KitchenOrder[") == 1 and vs == ("",), "R.196: solved - count() 1 = redis-cli's SCARD, findAll() the untimed order alone, the VEG index set gone: %s %s %s %s" % (cs, ss, fs, vs))
    ok(vr and len(vr[0].split()) == 2, "broken: the VEG index set still holds the two timed ids: %s" % (vr,))
    ok('keyspace events (CONFIG GET notify-keyspace-events): ""' in r and 'keyspace events (CONFIG GET notify-keyspace-events): "xE"' in s, "the server's setting, read by the program: \"\" broken, xE solved")
    ok(any(l.startswith("SCARD kitchen-order, read until it holds the untimed order alone (a cap of 50 reads): not reached,") for l in r) and "SCARD kitchen-order, read until it holds the untimed order alone (a cap of 50 reads): reached, 1" in s, "the poll: not reached broken, reached solved (a count condition, R.412)")
    for b in (r, s): ok("Rail: exit 0" in b and "Maven: exit 0" in b and "javac: exit 0" in b and "docker run: exit 0" in b and "docker rm -fv: exit 0" in b, "exits 0 in both states - the check is count() and SCARD, never the exit")
    ok("ON_STARTUP in Rail.java: 0" in r and "ON_STARTUP in Rail.java: 1" in s, "the broken copy lacks the ON_STARTUP line, the solved one holds it")
    ok(all(re.search(r"listening on 20542 afterwards: 0 · a container named c8u15-ex: 0$", l) for l in L if l.startswith("  the shell is now in")) and sum(1 for l in L if l.startswith("  the shell is now in")) == 2, "after each shell: 20542 free, the exercise's container gone")
    if cr and cs and sr and ss:
        VALUES.append("the line %s words · broken (keyspace events off): with the JVM up after both timed hashes are gone, count() %s = SCARD %s, findAll() two nulls · solved (ON_STARTUP, the same ids saved and the JVM up): count() %s = SCARD %s, the VEG index set gone · exit 0 both (a standalone harness JVM on the shipped KitchenOrders, Redis by the digest, no TiffinBox, no database)" % (Wd, cr[0], sr[0], cs[0], ss[0]))
elif NAME == "anchor":
    L = lines(sys.argv[2])
    pk = [x for x in (re.match(r"^  Surefire's Results line: Tests run: (\d+), Failures: 0, Errors: 0, Skipped: 0$", l) for l in L) if x]
    ok(len(pk) == 3, "three Results lines (package; verify's two executions): %d" % len(pk))
    n18 = int(pk[0].group(1)) if pk else 0; n18b = int(pk[1].group(1)) if len(pk) > 1 else 0; nit = int(pk[2].group(1)) if len(pk) > 2 else 0
    ok(n18 == n18b, "the package run's count = verify's first execution's: %d %d" % (n18, n18b))
    ok(any("absent - no container test ran" in l for l in L), "mvn package: no container test ran (Docker at nothing)")
    itl = [l for l in L if l.startswith("  REDIS IT ")]
    ok(len(itl) == 4, "the IT's four lines (the board's two, the orders' two): %d" % len(itl))
    oi = [l for l in itl if "KitchenOrders" in l or "kitchen-order" in l]
    m1 = re.search(r"count\(\) (\d+) · findByMealType\(VEG\) \[(.*)\]", oi[0]) if oi else None
    m2 = re.search(r"SMEMBERS kitchen-order:mealType:VEG \[(.*)\] · SCARD kitchen-order (\d+) · type kitchen-order:\S+ (\w+)$", oi[1]) if len(oi) > 1 else None
    ok(m1 and m2 and m1.group(2) == m2.group(1) and m1.group(1) == m2.group(2) and m2.group(3) == "hash", "the IT's two witnesses on the shipped KitchenOrders: findByMealType's ids = SMEMBERS of the index set, count() = SCARD, TYPE hash")
    libs = [(m.group(1), int(m.group(2))) for m in (re.match(r"^  (before|after)/: (\d+) libraries", l) for l in L) if m]
    ok(len(libs) == 2 and libs[0][1] == libs[1][1], "the jar's libraries unchanged (no new dependency): %s" % libs)
    ok("  gained: 0 · lost: 0" in L, "no jar gained or lost")
    ok("  the five classes in lib/spring-data-redis-4.1.2.jar (unzip -l): EnableRedisRepositories Indexed RedisHash RedisKeyValueAdapter TimeToLive" in L, "the five classes, in the jar the seed holds")
    starts = [s for s in sections(L) if s[0].startswith("-- start ")]
    ok(len(starts) == 3, "three starts")
    ids, scards = [], []
    for k, (h, body) in enumerate(starts, 1):
        ok(("PROBE started: yes · %s · a web server: yes" % DEVW) in body, "start %d: started under dev" % k)
        ok(("PROBE http (%s): GET /actuator/health -> 200 · status UP" % DEVW) in body and ("PROBE http (%s): GET /dashboard -> 200" % DEVW) in body and any(l.startswith("PROBE http (%s): GET /leaderboard -> 200 · {" % DEVW) for l in body), "start %d: health 200, /dashboard 200, /leaderboard 200" % k)
        oc = [int(m.group(1)) for m in (re.match(r"^  log: tiffinbox: orders cooked: +(\d+)$", l) for l in body) if m]
        kc = [int(m.group(1)) for m in (re.match(r"^PROBE http \(%s\): GET /kitchen -> 200 · ordersCooked (\d+) · ordersValue (\d+)$" % re.escape(DEVW), l) for l in body) if m]
        jr = one(body, r"^PROBE rail \(the start's saves, through the shipped KitchenOrders; %s\): count\(\) (\d+) · findAll\(\) (\d+) elements, (\d+) null · the ids, sorted: (\d+), first (\S+), last (\S+), md5 of the sorted lines ([0-9a-f]{32})$" % re.escape(DEVW))
        rr = one(body, r"^  SCARD kitchen-order: (\d+) · SMEMBERS kitchen-order, sorted: (\d+) ids, first (\S+), last (\S+), md5 of the sorted lines ([0-9a-f]{32})$")
        if jr and rr and oc and kc:
            ok(jr.group(1) == rr.group(1) == jr.group(4) == rr.group(2) and int(jr.group(1)) == oc[0] == kc[0] and jr.group(3) == "0", "start %d: count() = SCARD kitchen-order = the ids = the start's orders cooked = /kitchen's ordersCooked (one save per placed order): %s %s %s %s" % (k, jr.group(1), rr.group(1), oc, kc))
            ok((jr.group(5), jr.group(6), jr.group(7)) == (rr.group(3), rr.group(4), rr.group(5)), "start %d: the sorted ids, Java's and redis-cli's, the same first, last and md5" % k)
            ids.append(rr.group(5)); scards.append(rr.group(1))
        pc = one(body, r"^PROBE rail: findByCustomer, per customer: (.*) · findByMealType, per meal type: (.*)$")
        ix = one(body, r"^  the index sets, SCARD each: (.*)$")
        if pc and ix:
            jc = dict((a, int(b)) for a, b in re.findall(r"([A-Za-z]+) (\d+)", pc.group(1)))
            jm = dict((a, int(b)) for a, b in re.findall(r"([A-Z_]+) (\d+)", pc.group(2)))
            rcx = dict((a, int(b)) for a, b in re.findall(r"kitchen-order:customer:([A-Za-z]+) (\d+)", ix.group(1)))
            rmx = dict((a, int(b)) for a, b in re.findall(r"kitchen-order:mealType:([A-Z_]+) (\d+)", ix.group(1)))
            ok(jc == rcx and jm == rmx and jc and sum(jc.values()) == sum(jm.values()) == (int(jr.group(1)) if jr else -1), "start %d: per customer and per meal type, the finders' sizes = SCARD of each index set, each summing to count(): %s %s" % (k, jc, jm))
            ok(len(set(jc.values())) == 1, "start %d: each customer's index set the same size (days orders each): %s" % (k, jc))
        ok(any(re.match(r"^  TYPE kitchen-order:\S+: hash · HGETALL kitchen-order:\S+: _class com\.tiffinbox\.web\.KitchenOrder customer \S+ id \S+ mealType \S+ ttl <n> value \d+ · PTTL kitchen-order:\S+: yes \(> 0, the value masked\)$", l) for l in body), "start %d: TYPE hash, HGETALL (_class, customer, id, mealType, ttl masked, value), PTTL > 0" % k)
        ok(any(re.match(r"^  TYPE kitchen-order:\S+:idx: set · SMEMBERS, sorted: kitchen-order:customer:\S+ kitchen-order:mealType:\S+$", l) for l in body), "start %d: the id's :idx set names its two index sets" % k)
        ok(any(l == '  keys named *:phantom: 0 · CONFIG GET notify-keyspace-events: "xE"' for l in body), "start %d: no :phantom beside the start's saves (they come before the listener starts), CONFIG GET xE while it runs" % k)
        ok(sum(1 for l in body if l == "  log: Multiple Spring Data modules found, entering strict repository configuration mode") == 3 and "  log: Found 1 JPA repository interface" in body and "  log: Found 1 JDBC repository interface" in body and "  log: Found 1 Redis repository interface" in body, "start %d: strict mode, Found 1 JPA, Found 1 JDBC, Found 1 Redis repository interface (RE-MEASURE 6)" % k)
        ok("  log: RepositoryConfigurationExtensionSupport : Spring Data JPA - Could not safely identify store assignment for repository candidate interface com.tiffinbox.web.KitchenOrders" in body, "start %d: JPA's INFO line declining KitchenOrders, its logger named" % k)
        jvmexit(body, 130 if k == 3 else 0, "start %d: " % k)
    ok(len(ids) == 3 and ids[0] == ids[1] == ids[2] and scards[0] == scards[1] == scards[2], "three starts in a row against one Redis: SCARD unchanged and SMEMBERS sorted byte-equal (md5) each time - the ids are deterministic (RE-MEASURE 4)")
    b3 = starts[2][1] if len(starts) == 3 else []
    ok(any(l == "  the receipt at pause 2: kill -INT sent to the harness JVM (its pid, read off its own line)" for l in b3) and not any(l.startswith("PROBE <<< exit") for l in b3), "start 3: SIGINT at its pause -> exit 130, no exit line of its own")
    first = starts[0][1] if starts else []
    vl = one(first, r"^PROBE versions: Spring Boot (\S+) · Spring Framework (\S+) · Spring Data JPA (\S+) · Spring Data JDBC (\S+) · Spring Data Redis (\S+) · Lettuce (\S+?)(?:/\w+)? · Hibernate (\S+) · Flyway \(version\.txt\) (\S+)$")
    ver = vl.groups() if vl else ()
    ok(ver == ("4.1.2", "7.0.10", "4.1.2", "4.1.2", "4.1.2", "7.5.2.RELEASE", "7.4.13.Final", "12.4.0"), "the versions, off the run (R.246): %s" % (ver,))
    ok("  log: HHH000001: Hibernate ORM core version 7.4.13.Final" in first, "HHH000001's line")
    ok(("PROBE CacheManager beans 1 [cacheManager=%s] (%s)" % (RCM, DEVW)) in first, "cacheManager RedisCacheManager under dev (unchanged)")
    ok(("PROBE KitchenOrders beans 1 [kitchenOrders=a JDK proxy of com.tiffinbox.web.KitchenOrders] · RedisDatastore beans 1 (%s)" % DEVW) in first, "the KitchenOrders bean (Spring Data's proxy of the interface) and the RedisDatastore configuration")
    ok('PROBE CONFIG GET notify-keyspace-events, through the connection, after the start: "xE"' in first, "CONFIG GET xE, read while the JVM runs (through the connection)")
    ok(any(l.startswith('  redis-cli CONFIG SET notify-keyspace-events "" -> OK') and l.endswith('CONFIG GET notify-keyspace-events: ""') for l in L), "the receipt reset the server's setting before the first start: \"\"")
    ae = one(L, r'^  after the third JVM, redis-cli: CONFIG GET notify-keyspace-events "(\w*)" \(the server\'s setting, which the start\'s listener wrote, outlives the JVM\) · SCARD kitchen-order (\d+)$')
    ok(ae and ae.group(1) == "xE", "CONFIG GET xE by redis-cli after the JVM: the server's setting outlives it")
    rv = [l for l in L if l.startswith("  the Redis container's own client: ")]
    rvx = one(first, r"^PROBE Redis's INFO server, through the connection: redis_version:(\S+)$")
    ok(len(rv) == 1 and rv[0].endswith("INFO server: redis_version:8.10.3") and rvx and rvx.group(1) == "8.10.3", "redis_version 8.10.3 by redis-cli and through the connection")
    if ids and vl and pk:
        VALUES.append("15/after, profile dev, PostgreSQL + Redis, the start's saves: Found 1 Redis repository interface (and 1 JPA, 1 JDBC; JPA's INFO line declines KitchenOrders) · count() %s = SCARD kitchen-order %s = orders cooked, the index sets %s per customer, three starts SCARD unchanged and SMEMBERS byte-equal (md5 %s…), the third SIGINT -> exit 130 · no :phantom beside the start's saves · CONFIG GET \"\" before -> xE (during and after) · health 200 · /dashboard 200 · /leaderboard 200 · tests %d (mvn -o package, no Docker) and %d + %d (mvn -o verify) · libs %d -> %d (none gained) · Boot %s · Framework %s · Spring Data JPA/JDBC/Redis %s · Lettuce %s · HHH000001 %s · Flyway %s · redis_version:8.10.3" % (
            scards[0], scards[0], (list(jc.values())[0] if pc and ix and jc else "?"), ids[0][:8], n18, n18b, nit, libs[0][1], libs[1][1], ver[0], ver[1], ver[2], ver[5], ver[6], ver[7]))
elif NAME == "keys":
    L = lines(sys.argv[2])
    ty = dict((m.group(1), m.group(2)) for m in (re.match(r"^  (kitchen-order\S*): TYPE (\w+)$", l) for l in L) if m)
    want = {"kitchen-order": "set", "kitchen-order:o1": "hash", "kitchen-order:o2": "hash", "kitchen-order:o3": "hash",
            "kitchen-order:o1:idx": "set", "kitchen-order:o2:idx": "set", "kitchen-order:o3:idx": "set",
            "kitchen-order:o1:phantom": "hash", "kitchen-order:o2:phantom": "hash",
            "kitchen-order:customer:Meera": "set", "kitchen-order:customer:Ravi": "set", "kitchen-order:customer:Sunil": "set",
            "kitchen-order:mealType:NON_VEG": "set", "kitchen-order:mealType:VEG": "set"}
    ok(ty == want, "every key the three saves left, by redis-cli's --scan and TYPE: the ids' set, a hash per order, an :idx set per order, a set per indexed value, a :phantom hash per timed order only: %s" % sorted(ty.items()))
    ok(any(re.match(r"^  HGETALL kitchen-order:o1 \(timed\): _class com\.tiffinbox\.web\.KitchenOrder customer Ravi id o1 mealType VEG ttl <n> value \d+$", l) for l in L), "HGETALL of the timed hash: _class, customer, id, mealType, ttl (masked), value")
    ok(any(re.match(r"^  HGETALL kitchen-order:o3 \(untimed\): _class com\.tiffinbox\.web\.KitchenOrder customer Meera id o3 mealType NON_VEG value \d+$", l) for l in L), "HGETALL of the untimed hash: no ttl field")
    sc = one(L, r"^  SMEMBERS kitchen-order, sorted: (.*) · SCARD kitchen-order: (\d+)$")
    jc = one(L, r"^PROBE java \(the shipped KitchenOrders; %s\): count\(\) (\d+) · findAll\(\) \[(.*)\] \((\d+) elements, (\d+) null\)$" % re.escape(ONW))
    ok(sc and jc and sset(sc.group(1)) == ["o1", "o2", "o3"] and sc.group(2) == jc.group(1) and jc.group(4) == "0", "count() = SCARD kitchen-order, the three ids, no null")
    ok("  SMEMBERS kitchen-order:o1:idx, sorted: kitchen-order:customer:Ravi kitchen-order:mealType:VEG" in L, "SMEMBERS kitchen-order:o1:idx: the two index sets o1 is in")
    ok("  SMEMBERS kitchen-order:mealType:VEG, sorted: o1 o2 · SMEMBERS kitchen-order:customer:Ravi: o1" in L, "the VEG set holds o1 o2; Ravi's holds o1")
    fv = one(L, r"^PROBE java: findByMealType\(VEG\) \[(.*)\] · findByCustomer\(Ravi\) \[(.*)\] · findByCustomerAndMealType\(Ravi, VEG\) \[(.*)\]$")
    ok(fv and re.findall(r"KitchenOrder\[(\w+),", fv.group(1)) == ["o1", "o2"] and re.findall(r"KitchenOrder\[(\w+),", fv.group(3)) == ["o1"], "findByMealType(VEG) = the VEG set's ids; findByCustomerAndMealType(Ravi, VEG) = their intersection")
    ok("PROBE java: findById(o1) Optional[KitchenOrder[o1,Ravi,VEG,240]] · existsById(o1) true · findById(o3) Optional[KitchenOrder[o3,Meera,NON_VEG,150]]" in L, "findById by Java, the element printed (its ttl left out of toString - a configured number)")
    ok("  EXISTS kitchen-order:o1:phantom 1 · EXISTS kitchen-order:o2:phantom 1 · EXISTS kitchen-order:o3:phantom 0" in L, "the phantoms: one per timed order, none for the untimed")
    clean(L)
    if sc: VALUES.append("the harness's three orders through the shipped repository (15/after's classes, ON_STARTUP): keys kitchen-order (set), kitchen-order:<id> (hash) ×3, :idx (set) ×3, :phantom (hash) ×2 timed only, kitchen-order:customer:<name> and :mealType:<type> (sets) · the timed hash holds ttl (masked), the untimed none · count() %s = SCARD %s" % (sc.group(2), sc.group(2)))
elif NAME == "monitor":
    L = lines(sys.argv[2])
    ml = [l[2:] for l in L if l.startswith('  "')]
    ops, cur = {}, None
    for l in ml:
        m = re.match(r'^"ECHO" "h15:([\w-]+)"$', l)
        if m: cur = m.group(1); ops[cur] = []; continue
        if cur: ops[cur].append(l)
    cmd = lambda op: [re.match(r'^"(\w+)"', l).group(1) for l in ops.get(op, [])]
    n = indexed("after")
    tu, tt, t2 = cmd("save-untimed"), cmd("save-timed"), cmd("save-timed-2")
    want_u = ["DEL", "HMSET"] + ["SADD"] * (1 + 2 * n)
    ok(tu == want_u, "an untimed save: DEL, HMSET, then SADD to the ids' set and, per @Indexed field (%d, read off KitchenOrder.java), to its index set and the :idx set - %d commands: %s" % (n, len(want_u), tu))
    want_t = ["DEL", "HMSET", "SADD", "EXPIRE", "DEL", "HMSET", "EXPIRE"] + ["SADD"] * (2 * n)
    ok(tt == want_t and t2 == want_t, "a timed save under ON_STARTUP: DEL, HMSET (with ttl), SADD, EXPIRE, the phantom's DEL, HMSET, EXPIRE, then the index SADDs - %d commands (the untimed save's + EXPIRE + the phantom's three): %s" % (len(want_t), tt))
    ok(any('"HMSET" "kitchen-order:o1" ' in l and '"ttl" "<n>"' in l for l in ops.get("save-timed", [])) and not any('"ttl"' in l for l in ops.get("save-untimed", [])), "the timed HMSET carries the ttl field (masked), the untimed one none")
    ok(any(l == '"EXPIRE" "kitchen-order:o1" "<n>"' for l in ml) and any(l == '"EXPIRE" "kitchen-order:o1:phantom" "<n>"' for l in ml), "MONITOR's EXPIRE lines masked: the hash's and the phantom's")
    fm, fc, fa, ct = cmd("findByMealType"), cmd("findByCustomerAndMealType"), cmd("findAll"), cmd("count")
    jm = one(L, r"^PROBE mon \(the harness's saves through the shipped repository; %s\): a timed save \(o1\), an untimed save \(o3\), a timed save \(o2\), findByMealType\(VEG\) (\d+) elements, findByCustomerAndMealType\(Ravi, VEG\) (\d+), findAll\(\) (\d+), count\(\) (\d+) - an ECHO h15:<operation> before each$" % re.escape(ONW))
    if jm:
        a, b, c, d = (int(x) for x in jm.groups())
        ok(fm == ["SINTER"] + ["HGETALL"] * a and ops["findByMealType"][0] == '"SINTER" "kitchen-order:mealType:VEG"', "findByMealType: one SINTER of one index set, then one HGETALL per id it returned (%d): 1 + %d = %d commands" % (a, a, len(fm)))
        ok(fc == ["SINTER"] + ["HGETALL"] * b and ops["findByCustomerAndMealType"][0] == '"SINTER" "kitchen-order:customer:Ravi" "kitchen-order:mealType:VEG"', "findByCustomerAndMealType: one SINTER of two index sets, then one HGETALL per id (%d)" % b)
        ok(fa == ["SMEMBERS"] + ["HGETALL", "TTL"] * c, "findAll(): SMEMBERS, then HGETALL and TTL per id (%d): 1 + 2 × %d = %d commands" % (c, c, len(fa)))
        ok(ct == ["SCARD"] and d == c, "count(): one SCARD, its answer = findAll()'s size")
    ok("  MONITOR clients left (CLIENT LIST, flags O): 0" in L and any(l.strip() == "the receipt at pause 2: CLIENT KILL ID <the MONITOR client's id, read off CLIENT LIST, flags O> -> 1" for l in L), "the MONITOR client stopped by Redis (CLIENT KILL ID), none left")
    ok(not any(re.match(r"^\d{10}\.\d+ \[", l.strip()) for l in L), "MONITOR's unix-time prefix stripped from every line")
    clean(L)
    if jm: VALUES.append("MONITOR, the harness's saves through the shipped repository: untimed save %d commands · timed save under ON_STARTUP %d · findByMealType 1 SINTER + %d HGETALL · findByCustomerAndMealType 1 SINTER of two sets + %d HGETALL · findAll() SMEMBERS + HGETALL and TTL per id = %d · count() 1 SCARD" % (len(tu), len(tt), a, b, len(fa)))
elif NAME == "ttl":
    L = lines(sys.argv[2])
    ok("  PTTL kitchen-order:o1 (timed): yes (> 0, the value masked) · PTTL kitchen-order:o2 (timed): yes (> 0, the value masked) · PTTL kitchen-order:o3 (untimed): -1" in L, "PTTL: the timed hashes > 0 (yes, masked), the untimed -1")
    ok("  EXISTS kitchen-order:o1:phantom 1 · PTTL kitchen-order:o1:phantom: yes (> 0, the value masked) · EXISTS kitchen-order:o3:phantom 0" in L, "the timed order's :phantom exists, with its own time to live; the untimed has none")
    ok("  a field named ttl: in HGETALL kitchen-order:o1 1 · in HGETALL kitchen-order:o3 0" in L, "the timed hash holds a ttl field, the untimed none")
    tl = one(L, r"^PROBE java: the ttl each element carries \(a timed value printed as \"set\"\) - findAll\(\): (.*) · findByMealType\(VEG\): (.*) · findByMealType\(NON_VEG\): (.*) · findById\(o3\): (.*)$")
    ok(tl and tl.group(1) == "o1:set o2:set o3:-1" and tl.group(2) == "o1:set o2:set" and tl.group(3) == "o3:null" and tl.group(4) == "-1", "RE-MEASURE 5: findAll() and findById read TTL (the untimed element -1, the timed set); a derived finder reads the hash alone (the untimed element null, the timed the stored field): %s" % (tl.groups() if tl else None,))
    clean(L)
    VALUES.append("the harness's orders through the shipped repository: PTTL timed yes (> 0, masked), untimed -1 · :phantom 1 timed / 0 untimed · findAll()'s untimed element ttl -1, a finder's null (RE-MEASURE 5)")
elif NAME == "events":
    L = lines(sys.argv[2])
    ss = sections(L)
    a = ss[0][1] if ss else []; b = ss[1][1] if len(ss) > 1 else []
    ok(any(l.startswith('  redis-cli CONFIG SET notify-keyspace-events "" -> OK') and l.endswith('CONFIG GET notify-keyspace-events: ""') for l in a), "before the JVM: CONFIG GET notify-keyspace-events \"\" (the image's default, reset)")
    ok(('PROBE CONFIG GET notify-keyspace-events, through the connection (%s): "xE"' % ONW) in a, "after the start: xE, through the connection")
    ok(any(l.startswith('  CONFIG GET notify-keyspace-events: "xE" · SCARD kitchen-order: 3 · SMEMBERS kitchen-order:mealType:VEG, sorted: o1 o2') for l in a), "redis-cli at the pause: xE, SCARD 3, VEG o1 o2 - before the time to live ends")
    pl = [l for l in a if l.startswith("  poll: ")]
    ok([re.sub(r"polled <k> times.*$", "", l) for l in pl] == ["  poll: EXISTS kitchen-order:o1 kitchen-order:o2 (the two timed hashes gone: their time to live ended) -> 0, ", "  poll: SCARD kitchen-order (until the untimed order alone is in it) -> 1, ", "  poll: SCARD kitchen-order:mealType:VEG (until its set is gone) -> 0, "] and all("polled <k> times (a count condition" in l for l in pl), "R.412: EXISTS polled to 0, then SCARD polled to 1 and the VEG set to 0 - each a count condition, its poll count printed (masked)")
    ok("  then: SMEMBERS kitchen-order: o3 · EXISTS kitchen-order:o1:idx kitchen-order:o2:idx: 0 · --scan, sorted: kitchen-order kitchen-order:customer:Meera kitchen-order:mealType:NON_VEG kitchen-order:o3 kitchen-order:o3:idx" in a, "after the listener: the ids' set o3 alone, the timed :idx sets gone, every key left is the untimed order's")
    jc = one(a, r"^PROBE java \(the shipped KitchenOrders; %s\): count\(\) (\d+) · findAll\(\) \[(.*)\] \((\d+) elements, (\d+) null\)$" % re.escape(ONW))
    ok(jc and jc.group(1) == "1" and jc.group(2) == "KitchenOrder[o3,Meera,NON_VEG,150]" and jc.group(4) == "0", "count() 1, findAll() [o3] - Java beside redis-cli's SCARD 1")
    ok(any(l == '  after the JVM, redis-cli: CONFIG GET notify-keyspace-events "xE"' for l in L), "after the JVM: xE - the server's setting outlives it")
    clean(a)
    ok(any(l.startswith('  redis-cli CONFIG SET notify-keyspace-events "" -> OK') for l in b), "the start's shape: the setting reset before the JVM")
    s0 = one(b, r'^  SCARD kitchen-order: (\d+) · keys named \*:phantom: (\d+) · CONFIG GET notify-keyspace-events: "xE"$')
    jr = one(b, r"^PROBE rail \(the start's saves, through the shipped KitchenOrders; %s\): count\(\) (\d+) · " % re.escape(DEVW))
    oc = [int(m.group(1)) for m in (re.match(r"^  log: tiffinbox: orders cooked: +(\d+)$", l) for l in b) if m]
    ok(s0 and jr and oc and int(s0.group(1)) == int(jr.group(1)) == oc[0] and s0.group(2) == "0", "the start's saves: SCARD = count() = orders cooked, no phantom")
    pb = [re.sub(r"polled <k> times.*$", "", l) for l in b if l.startswith("  poll: ")]
    ok(len(pb) == 2 and pb[0].startswith("  poll: EXISTS on the ") and pb[0].endswith("hashes the set named (all gone: their time to live ended) -> 0, ") and pb[1] == "  poll: SCARD kitchen-order (until it is gone) -> 0, ", "R.412: the start's hashes polled to EXISTS 0, then SCARD polled to 0")
    ok("  then: keys named kitchen-order:customer:* 0 · kitchen-order:mealType:* 0 · kitchen-order:*:idx 0 · --scan, sorted: customers::SimpleKey [] tiffinbox:leaderboard" in b, "after the running TiffinBox's listener: no index set, no :idx set, no kitchen-order key left")
    rg = one(b, r"^PROBE railgone \(the start's saves, after their time to live; %s\): count\(\) (\d+) · findAll\(\) (\d+) elements, (\d+) null$" % re.escape(DEVW))
    ok(rg and rg.groups() == ("0", "0", "0"), "the start's own orders: count() 0, findAll() [] - while TiffinBox runs")
    jvmexit(b, 0, "the start's shape: ")
    if s0: VALUES.append("ON_STARTUP, the harness's three orders: CONFIG GET \"\" -> xE (the start), the two timed hashes gone while the JVM runs (EXISTS polled to 0) -> SCARD polled to 1, the VEG set to 0 -> count() 1, findAll() [o3] · the start's own %s orders (15/after, dev, the setting low on the command line): EXISTS polled to 0, SCARD polled to 0 -> count() 0, findAll() [] while TiffinBox runs, no :phantom needed" % s0.group(1))
elif NAME == "nolisten":
    L = lines(sys.argv[2])
    ss = sections(L)
    j1 = ss[0][1] if ss else []; nj = ss[1][1] if len(ss) > 1 else []; j2 = ss[2][1] if len(ss) > 2 else []; j3 = ss[3][1] if len(ss) > 3 else []
    ok(any(l.startswith("  the receipt at pause 1, redis-cli: EXISTS kitchen-order:o1 kitchen-order:o2 2 (both timed hashes still there) · SCARD kitchen-order 3 - then SIGINT") for l in j1) and any(l == "  the receipt at pause 1: kill -INT sent to the harness JVM (its pid, read off its own line)" for l in j1), "j1: both timed hashes there at SIGINT (before their time to live ended)")
    ok(not any(l.startswith("PROBE <<< exit") for l in j1) and any(re.match(r"^  exit 130 · ", l) for l in j1), "j1: exit 130 (SIGINT, its disposition reset)")
    ok(nj and nj[0].startswith("  poll: EXISTS kitchen-order:o1 kitchen-order:o2 (both timed hashes gone, no JVM listening) -> 0, polled <k> times") and "java processes of this script: 0" in ss[1][0], "no JVM up: the timed hashes polled to EXISTS 0")
    st = one(nj, r'^  then: SCARD kitchen-order (\d+) · SMEMBERS kitchen-order:mealType:VEG, sorted: (.*) · EXISTS kitchen-order:o1:phantom (\d) · CONFIG GET notify-keyspace-events "(\w*)"$')
    ok(st and st.group(1) == "3" and sset(st.group(2)) == ["o1", "o2"] and st.group(3) == "1" and st.group(4) == "xE", "nothing listened: SCARD 3, the VEG set the two stale ids, the phantom still there, xE on the server: %s" % (st.groups() if st else None,))
    t = one(j2, r"^  the receipt at pause 1, redis-cli, the fresh JVM up and listening \(it saves nothing\): SCARD kitchen-order, ten reads, a pause of the receipt's between each: (\d+) · SMEMBERS kitchen-order:mealType:VEG, sorted: (.*) · EXISTS kitchen-order:o1:phantom (\d)$")
    ok(t and len(t.group(1)) == 10 and set(t.group(1)) == {st.group(1) if st else "?"} and sset(t.group(2)) == ["o1", "o2"], "j2, a fresh ON_STARTUP JVM, idle: SCARD ten reads, all the stale count; the VEG set unchanged: %s" % (t.groups() if t else None,))
    ok(('PROBE CONFIG GET notify-keyspace-events, through the connection (%s): "xE"' % ONW) in j2, "j2 listens: xE")
    p3 = [re.sub(r"polled <k> times.*$", "", l) for l in j3 if l.startswith("  poll: ")]
    ok(p3 == ["  poll: EXISTS kitchen-order:o1 kitchen-order:o2 (the re-saved timed hashes gone: their time to live ended) -> 0, ", "  poll: SCARD kitchen-order (until 1) -> 1, ", "  poll: SCARD kitchen-order:mealType:VEG (until its set is gone) -> 0, "], "j3: the re-saved hashes polled to EXISTS 0, then SCARD polled to 1, the VEG set to 0 (R.412)")
    jc = one(j3, r"^PROBE java \(the shipped KitchenOrders; %s\): count\(\) (\d+) · findAll\(\) \[(.*)\] \((\d+) elements, (\d+) null\)$" % re.escape(ONW))
    ok(jc and jc.group(1) == "1" and jc.group(4) == "0" and "  then: SMEMBERS kitchen-order: o3 · --scan, sorted: kitchen-order kitchen-order:customer:Meera kitchen-order:mealType:NON_VEG kitchen-order:o3 kitchen-order:o3:idx" in j3, "j3: count() 1 = SCARD 1, the untimed order's keys alone left")
    ok(any(re.match(r"^PROBE save3 .*: saved again \(the same ids\) KitchenOrder\[o1,", l) for l in j3), "j3 saved the same three ids again")
    clean(j2, "j2: "); clean(j3, "j3: ")
    if st and t: VALUES.append("nolisten, the harness's orders through the shipped repository: the JVM stopped (SIGINT, exit 130) before their time to live ended, the hashes gone with no JVM up -> SCARD %s, VEG o1 o2, :phantom 1, xE · a fresh ON_STARTUP JVM, idle -> SCARD ten reads %s · a JVM that saves the same ids again and stays up -> SCARD polled to 1, the VEG set gone, count() 1" % (st.group(1), t.group(1)))
elif NAME == "stale":
    L = lines(sys.argv[2])
    ok(any(l.startswith('  redis-cli CONFIG SET notify-keyspace-events "" -> OK') and l.endswith('CONFIG GET notify-keyspace-events: ""') for l in L), "before: the server's setting reset, CONFIG GET \"\"")
    ok(('PROBE CONFIG GET notify-keyspace-events, through the connection (%s): ""' % OFFW) in L and any(l.startswith('  CONFIG GET notify-keyspace-events: "" · SCARD kitchen-order: 3') for l in L) and '  after the JVM, redis-cli: CONFIG GET notify-keyspace-events ""' in L, "keyspace events OFF: \"\" through the connection, at the pause and after the JVM - nothing wrote xE")
    ok(any(l.startswith("  poll: EXISTS kitchen-order:o1 kitchen-order:o2 (the two timed hashes gone: their time to live ended) -> 0, polled <k> times") for l in L), "the two timed hashes polled to EXISTS 0")
    th = one(L, r"^  then: SCARD kitchen-order (\d+) · SMEMBERS kitchen-order, sorted: (.*) · SMEMBERS kitchen-order:mealType:VEG, sorted: (.*) · SMEMBERS kitchen-order:customer:Ravi: (.*) · EXISTS kitchen-order:o1:phantom (\d)$")
    jc = one(L, r"^PROBE java \(the shipped KitchenOrders; %s\): count\(\) (\d+) · findAll\(\) \[(.*)\] \((\d+) elements, (\d+) null\)$" % re.escape(OFFW))
    if th and jc:
        el = jc.group(2).split(", ")
        ok(jc.group(1) == th.group(1) == "3" and sset(th.group(2)) == ["o1", "o2", "o3"], "count() 3 = SCARD 3 - both timed hashes gone, their ids still counted")
        ok(el.count("null") == 2 and int(jc.group(4)) == 2 and int(jc.group(3)) == int(jc.group(1)) and [e for e in el if e != "null"] == ["KitchenOrder[o3,Meera,NON_VEG,150]"], "findAll(): two null elements beside the untimed order, one element per id SCARD counts: %s" % el)
        ok(sset(th.group(3)) == ["o1", "o2"] and th.group(4) == "o1" and th.group(5) == "0", "the index sets still hold the gone ids (VEG o1 o2, Ravi's o1); no :phantom under OFF")
    fv = one(L, r"^PROBE java: findByMealType\(VEG\) \[(.*)\] · findByCustomer\(Ravi\) \[(.*)\] · findByCustomerAndMealType\(Ravi, VEG\) \[(.*)\]$")
    ok(fv and fv.groups() == ("", "", ""), "the derived finders return [] - they drop the missing ids, hiding the stale index (beside SMEMBERS VEG o1 o2)")
    ok("PROBE java: findById(o1) Optional.empty · existsById(o1) false · findById(o3) Optional[KitchenOrder[o3,Meera,NON_VEG,150]]" in L, "findById(o1) Optional.empty, existsById(o1) false")
    kl = one(L, r"^  the receipt at pause 2, redis-cli: the keys left, --scan sorted: (.*)$")
    ok(kl and kl.group(1).split() == ["kitchen-order", "kitchen-order:customer:Meera", "kitchen-order:customer:Ravi", "kitchen-order:customer:Sunil", "kitchen-order:mealType:NON_VEG", "kitchen-order:mealType:VEG", "kitchen-order:o1:idx", "kitchen-order:o2:idx", "kitchen-order:o3", "kitchen-order:o3:idx"], "the keys left: the gone orders' :idx sets and their index sets stay")
    clean(L)
    if jc: VALUES.append("stale, keyspace events OFF (the harness's configuration over the shipped repository): CONFIG GET \"\" before and after · the two timed hashes gone (EXISTS 0) -> count() %s = SCARD %s, findAll() two nulls beside o3, SMEMBERS VEG o1 o2, findByMealType(VEG) [] (it hides them), findById(o1) empty, existsById false · no exception (ERROR 0, no line naming an Exception)" % (jc.group(1), th.group(1) if th else "?"))
elif NAME == "startstop":
    L = lines(sys.argv[2])
    ss = sections(L)
    a = ss[0][1] if ss else []; b = ss[1][1] if len(ss) > 1 else []
    ok(ss and "--spring.data.redis.port=20549, where nothing listens (lsof: 0 listeners)" in ss[0][0], "Redis absent: 20549 asserted unbound")
    e = one(a, r"^  the JVM's exit: (\d+) · then curl /actuator/health on 20540: (\d+) · listening on 20540: (\d+)$")
    ok(e and e.groups() == ("1", "000", "0"), "15/after's jar: the start stops - exit 1, curl 000, nothing on 20540")
    c = one(a, r"^  its log: \"Error creating bean with name 'tiffinBoxServer'\" (\d+) lines · \"RedisConnectionFailureException: Unable to connect to Redis\" (\d+) · \"Failed to start bean 'redisKeyValueAdapter'\" (\d+) · \"Application run failed\" (\d+) · \"Started TiffinBoxApp\" (\d+) · \"orders cooked\" (\d+)$")
    ok(c and int(c.group(1)) >= 1 and int(c.group(2)) >= 1 and c.group(3) == "0" and int(c.group(4)) >= 1 and c.group(5) == "0" and c.group(6) == "0", "15/after prints unit 14's line - Error creating bean with name 'tiffinBoxServer' <- RedisConnectionFailureException - the fill fails before the repository's listener starts; the adapter's line 0; no Started, no orders cooked")
    ok(any(l.startswith("  the causes, in the order the log names them: org.springframework.data.redis.RedisConnectionFailureException<") for l in a), "the causes: RedisConnectionFailureException <- …")
    ok("PROBE started: no · org.springframework.context.ApplicationContextException: Failed to start bean 'redisKeyValueAdapter'" in b and "PROBE caused by: org.springframework.data.redis.RedisConnectionFailureException: Unable to connect to Redis" in b and "PROBE <<< exit 1" in b, "the shipped RedisDatastore alone, Redis absent: Failed to start bean 'redisKeyValueAdapter' <- RedisConnectionFailureException, exit 1")
    ok(any(re.match(r"^  its log: \"Failed to start bean 'redisKeyValueAdapter'\" [1-9]\d* lines$", l) for l in b), "the adapter's line in its log")
    if c: VALUES.append("startstop, 15/after's jar, profile dev, PostgreSQL up, Redis absent: the start stops - Error creating bean with name 'tiffinBoxServer' <- RedisConnectionFailureException (the start's fill, unit 14's), exit 1, curl 000; the adapter's line 0 there · the shipped RedisDatastore alone (the repository-only JVM): Failed to start bean 'redisKeyValueAdapter' <- RedisConnectionFailureException, exit 1 (control: anchor)")
elif NAME == "noconfig":
    L = lines(sys.argv[2])
    ok(any(re.match(r"^  c8u15-nocfg: published 6379/tcp -> 127\.0\.0\.1:20544 · redis-cli CONFIG GET notify-keyspace-events: ERR unknown command 'CONFIG'$", l) for l in L), "the second Redis refuses CONFIG: ERR unknown command 'CONFIG'")
    e = one(L, r"^  the JVM's exit: (\d+) · then curl /actuator/health on 20540: (\d+) · listening on 20540: (\d+)$")
    ok(e and e.groups() == ("1", "000", "0"), "the start stops: exit 1, curl 000, nothing on 20540")
    c = one(L, r"^  its log: \"Failed to start bean 'redisKeyValueAdapter'\" (\d+) lines · \"ERR unknown command 'CONFIG'\" (\d+) · \"Error creating bean with name 'tiffinBoxServer'\" (\d+) · \"orders cooked\" (\d+) · \"Started TiffinBoxApp\" (\d+) · \"Application run failed\" (\d+)$")
    ok(c and int(c.group(1)) >= 1 and int(c.group(2)) >= 1 and c.group(3) == "0" and c.group(4) == "1" and c.group(5) == "0", "Failed to start bean 'redisKeyValueAdapter' <- ERR unknown command 'CONFIG'; the start's fill and saves ran (orders cooked 1), no Started")
    sc = one(L, r"^  the second Redis after the stopped start: SCARD kitchen-order (\d+) \(the start's saves reached it before the listener's CONFIG SET was refused\) · ZCARD tiffinbox:leaderboard (\d+)$")
    ok(sc and int(sc.group(1)) > 0 and int(sc.group(2)) > 0, "the start's saves reached the refusing server before the listener's start failed")
    ok("  c8u15-nocfg removed with its volumes (rm -fv) · listening on 20544: 0" in L, "the second Redis removed with its volumes")
    if c and sc: VALUES.append("noconfig, the same digest with --rename-command CONFIG \"\" (20544): redis-cli CONFIG GET -> ERR unknown command 'CONFIG' · 15/after under dev -> Failed to start bean 'redisKeyValueAdapter' <- ERR unknown command 'CONFIG', exit 1, curl 000 (the start's %s saves had reached it) (control: events)" % sc.group(1))
elif NAME == "default":
    L = lines(sys.argv[2])
    ok(("PROBE started: yes · %s · a web server: yes" % DEFW) in L, "the default run started on H2")
    ok(("PROBE http (%s): GET /actuator/health -> 200 · status UP" % DEFW) in L and ("PROBE http (%s): GET /leaderboard -> 404" % DEFW) in L and ("PROBE http (%s): GET /dashboard -> 200" % DEFW) in L, "default run: health 200, /leaderboard 404, /dashboard 200")
    ok(("PROBE noorders (%s): getBeansOfType(KitchenOrders) 0 · a bean of class com.tiffinbox.web.RedisDatastore 0" % DEFW) in L and ("PROBE KitchenOrders beans 0 [] · RedisDatastore beans 0 (%s)" % DEFW) in L, "no KitchenOrders bean, no RedisDatastore")
    ok(not any(re.match(r"^  log: Found \d+ Redis", l) for l in L) and "  log: Found 1 JPA repository interface" in L and "  log: Found 1 JDBC repository interface" in L, "no Redis repository line at all (JPA 1, JDBC 1) - spring.data.redis.repositories.enabled: false")
    rl = one(L, r"^  its log: lines naming \"Redis repositor\" (\d+) · \"Could not safely identify store assignment for repository candidate interface com\.tiffinbox\.web\.KitchenOrders\" (\d+)$")
    ok(rl and rl.group(1) == "0", "grep 'Redis repositor' -> 0 lines on the default run")
    ok(not any(l.startswith("PROBE RedisConnectionFactory") for l in L), "no Redis connection made")
    pk = [x for x in (re.match(r"^  Surefire's Results line: Tests run: (\d+), Failures: 0, Errors: 0, Skipped: 0$", l) for l in L) if x]
    ok(len(pk) == 1, "the package run's Results line")
    jvmexit(L, 0)
    if pk and rl: VALUES.append("15/after, default run, H2, no Redis, no Docker: health 200 · /leaderboard 404 · /dashboard 200 · KitchenOrders beans 0 · no Redis repository line (grep 0; JPA's INFO line on KitchenOrders %s) · the %s under mvn -o package, Docker at nothing" % (rl.group(2), pk[0].group(1)))
elif NAME == "seven":
    L = lines(sys.argv[2]); S466 = sys.argv[3]
    h = [m.group(1) for m in (re.search(r"the seven responses: 7 lines · md5 ([0-9a-f]{32})", l) for l in L) if m]
    ok(len(h) == 2 and h[0] == h[1] == S466, "the seven on before/ and after/ = Course 7's published md5")
    ok(sum(1 for l in L if l == "  GET /dashboard: 200") == 2, "GET /dashboard 200 on both")
    ok("  exit 0 · cmp with xcheck.sql (= Course 7's capstone's): the same, byte for byte" in L, "Hibernate's schema script = xcheck.sql")
    ok("  the seven, after/ against before/: lines that differ: 0" in L, "0 lines differ")
    ok(sum(1 for l in L if l.startswith("  GET /actuator/health/readiness -> 200 · GET /actuator/health -> 200 · GET /leaderboard -> 404 ")) == 2, "the jar's default run: health 200, /leaderboard 404, before and after")
    rr = [l for l in L if l.startswith("  its log: lines naming \"Redis repositor\" ")]
    ok(len(rr) == 2 and rr[1].endswith(" 0"), "after/'s jar on the default run: no Redis repository line (before/'s, unit 14's, prints the strict-mode Found 0)")
    VALUES.append("the seven %s… on before/ and after/ (0 lines differ) · GET /dashboard 200 · health 200 · /leaderboard 404 on the default run · Hibernate's script = xcheck.sql" % S466[:8])
else:
    print("FAIL no check named " + NAME); sys.exit(1)
for o in oks: print("ok " + o)
for f in fails: print("FAIL " + f)
print("VALUES " + "; ".join(VALUES))
sys.exit(1 if fails else 0)
