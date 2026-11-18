"""Unit 11's checks (python3 -I -B harness/chk11.py NAME ARGS...). Each capture's numbers are asserted against a second witness of the
same run - never a typed figure: the invocation counter against Hibernate's statement counter per call (R.375), the bytes redis-cli
read against the class Java read back (R.379), the value a JVM read against psql's row (R.359), the database the harness named against
Flyway's Database line, the CacheManager bean against the cache's own class, the TTL redis-cli read against the setting the JVM held,
Surefire's XML against Maven's Results lines, the seven's md5 against Course 7's published one. Prints ok/FAIL lines and one VALUES
line; exits 1 on any FAIL.
  static AFTER BEFORE   the change itself, read off the files (C3's six files and the README, one new, nothing gone)
  r250 AFTER BEFORE     the anchor README's sentences C3 made false: each carries its unit 11 note (R.250)
  yamlkeys TREE         every key of TREE's application*.yaml files, flattened (spring.cache.type, ...), one per line
  wib CAPTURE FILE      the lines the exercise's block printed for FILE (bash's), for receipts.sh to compare with "What it prints"
  exercise|nodocker|anchor|compose|jdk|json|renamed|strict|writer|ttlbean|health|seven CAPTURE [...]"""
import difflib, filecmp, os, re, sys

NAME = sys.argv[1]
fails, oks, VALUES = [], [], []


def ok(c, msg):
    (oks if c else fails).append(msg)


def lines(p):
    return open(p, encoding="utf-8").read().splitlines()


def sections(L):
    out, cur = [], None
    for l in L:
        if l.startswith("-- "):
            cur = [l, []]; out.append(cur)
        elif cur is not None:
            cur[1].append(l)
    return out


def grab(L, rx, n=1):
    m = [x for x in (re.search(rx, l) for l in L) if x]
    ok(len(m) == n, "%d line(s) match %s (found %d)" % (n, rx, len(m)))
    return m


LIST = r"\[([0-9, ]+)\]"
def lst(s): return [int(x) for x in s.split(",")]
DBS = r"(H2 2\.5\.250|PostgreSQL 18\.6)"
STORE = r"(Redis|in the JVM, Caffeine)"
CAF = "org.springframework.cache.caffeine.CaffeineCacheManager"
RCM = "org.springframework.data.redis.cache.RedisCacheManager"


def window(L, label):
    """A counted window's line: calls, statements, the two per-call lists; asserted equal (R.375)."""
    m = grab(L, r"^PROBE " + re.escape(label) + r" \(" + DBS + ", " + STORE + r"\): repository calls (\d+) · prepareStatementCount (\d+) · per call " + LIST + " and " + LIST + r" · (.*)$")
    if not m: return None
    db, st, c, s, a, b, rest = m[0].groups()
    a, b = lst(a), lst(b)
    ok(a == b, "R.375: %s on %s - the counter's per-call list %s = the statement counter's %s" % (label, db, a, b))
    ok(sum(a) == int(c) and sum(b) == int(s), "%s on %s: each total is the sum of its per-call list" % (label, db))
    eq = grab(L, r"^PROBE " + re.escape(label) + r": the two witnesses' per-call lists (equal|DIFFER)")
    ok(bool(eq) and eq[0].group(1) == "equal", "%s on %s: the harness's own comparison says equal" % (label, db))
    return {"db": db, "store": st, "calls": int(c), "sql": int(s), "per": a, "rest": rest}


def jvm(body):
    """One harness JVM's section: its database, its store, its exit; Flyway's Database line agrees."""
    d = [m for m in (re.match(r"^PROBE started: yes · the database that answered: " + DBS + r" · the cache's store: " + STORE + r" · a web server: yes$", l) for l in body) if m]
    ok(len(d) == 1, "one JVM per section, started, its web server on")
    if not d: return ("?", "?")
    db, st = d[0].groups()
    fl = [l for l in body if l.startswith("  log: Database: ")]
    want = "(H2 2.5)" if db.startswith("H2") else "(PostgreSQL 18.6)"
    ok(len(fl) == 1 and fl[0].endswith(want), "the harness's database %s = Flyway's Database line %s" % (db, fl))
    ok(any(re.match(r"^  exit 0 · its log", l) for l in body) and "PROBE <<< exit 0" in body, "the JVM exits 0 (%s, %s)" % (db, st))
    return db, st


def mgr(body, cls):
    ok(any(l.startswith("PROBE CacheManager beans 1 [cacheManager=%s] (" % cls) for l in body), "CacheManager beans 1, %s" % cls)


def strict3(body, db):
    ok(sum(1 for l in body if l == "  log: Multiple Spring Data modules found, entering strict repository configuration mode") == 3, "strict mode, once per module - three modules (%s)" % db)
    ok([l for l in body if re.match(r"^  log: Found \d+ (JPA|JDBC|Redis) ", l)] == ["  log: Found 1 JPA repository interface", "  log: Found 1 JDBC repository interface", "  log: Found 0 Redis repository interfaces"], "Found 1 JPA, Found 1 JDBC, Found 0 Redis (%s)" % db)


def writerline(body):
    m = grab(body, r"^PROBE the cache writer: (\S+) · asynchronousWrites (true|false) · a lock wait set (yes|no) ")
    return m[0].groups() if m else None


def yaml_keys(path):
    out, stack = [], []
    for raw in open(path, encoding="utf-8").read().split("\n"):
        if raw.strip() == "---": stack = []; continue
        if not raw.strip() or raw.lstrip().startswith("#") or raw.lstrip().startswith("- "): continue
        m = re.match(r"^( *)([A-Za-z0-9_.\-\[\]]+):(.*)$", raw)
        if not m: continue
        ind = len(m.group(1)); stack = [(i, k) for i, k in stack if i < ind]; stack.append((ind, m.group(2)))
        out.append(".".join(k for _, k in stack))
    return out


def rd(t, p): return open(os.path.join(t, p), encoding="utf-8").read()


def adds(B, A, p):
    d = [l for l in difflib.unified_diff(rd(B, p).splitlines(), rd(A, p).splitlines(), lineterm="", n=0) if l[:1] in "+-" and not l.startswith(("+++", "---"))]
    return d


POM, YML, DEV, CMP = "tiffinbox-web/pom.xml", "tiffinbox-web/src/main/resources/application.yaml", "tiffinbox-web/src/main/resources/application-dev.yaml", "compose.yaml"
RCJ, CRJ = "tiffinbox-web/src/main/java/com/tiffinbox/web/RedisCaching.java", "tiffinbox-core/src/main/java/com/tiffinbox/CustomerRepository.java"
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
    ok(sorted(changed) == sorted(["README.md", POM, YML, DEV, CMP, CRJ, "new " + RCJ]), "C3: the files changed are README.md, the web POM, application.yaml, application-dev.yaml, compose.yaml, CustomerRepository.java and the new RedisCaching.java - nothing gone: %s" % sorted(changed))
    pd = adds(B, A, POM)
    ok(all(l.startswith("+") for l in pd), "the web POM: lines added only")
    added = "\n".join(l[1:] for l in pd)
    ok(re.search(r"<dependency>\s*<groupId>org\.springframework\.boot</groupId>\s*<artifactId>spring-boot-starter-data-redis</artifactId>\s*</dependency>", rd(A, POM)) is not None and "<version>" not in added and "Course 8, unit 11:" in added, "the web POM gains spring-boot-starter-data-redis, no version typed, a Course 8, unit 11: comment")
    rc = rd(A, RCJ)
    ok('@ConditionalOnProperty(name = "spring.cache.type", havingValue = "redis")' in rc, "RedisCaching: read only while spring.cache.type is redis")
    ok("RedisCacheWriter.create(connections, writer -> writer.immediateWrites().enableLocking())" in rc and "RedisCacheManagerBuilderCustomizer immediateLockingWriter(" in rc, "RedisCaching: the writer customizer - immediateWrites() and enableLocking()")
    ok("RedisCacheConfiguration redisCacheConfiguration(CacheProperties properties)" in rc and "SerializationPair.fromSerializer(RedisSerializer.json())" in rc and all(x in rc for x in ("getTimeToLive()", "getKeyPrefix()", "isCacheNullValues()", "isUseKeyPrefix()")), "RedisCaching: the JSON configuration built from CacheProperties (ttl, prefix, null values, use-key-prefix)")
    ok("Jackson2" not in rc and "Serializable" not in rd(A, "tiffinbox-core/src/main/java/com/tiffinbox/Customer.java"), "no Jackson 2 serializer named; Customer is not made Serializable")
    ok(rc.count("Course 8, unit 11:") >= 3 and "the writer Boot builds\n * over Lettuce" in rc and "turning the object into the bytes the store keeps" in rc, "RedisCaching's Javadoc: Course 8, unit 11: paragraphs, the writer Boot builds over Lettuce, the gloss")
    cd = adds(B, A, CRJ)
    cr = rd(A, CRJ)
    ok(".collect(Collectors.toCollection(ArrayList::new));" in cr and ").toList();" not in cr.split("public List<Customer> findAll()")[1].split("}")[0], "findAll collects into an ArrayList, Stream.toList() gone from it")
    ok(sum(1 for l in cr.splitlines() if l.strip().startswith("@Cache")) == 2, "two cache annotations in CustomerRepository: findByName stays uncached (unit 13's)")
    ok("none of them changes it" in cr and "TiffinBoxServer returns it or filters it into a new list" in cr and "KitchenHealthIndicator reads its size" in cr and "Dashboard maps it" in cr, "RED #9's sentence: the shared ArrayList, its four callers, none mutates")
    yd = adds(B, A, YML)
    ok(all(l.startswith("+") for l in yd), "application.yaml: lines added only")
    keys = [l[1:] for l in yd if not l[1:].strip().startswith("#")]
    ok(keys == ["    type: caffeine", "  health:", "    redis:", "      enabled: false"], "application.yaml gains spring.cache.type: caffeine and management.health.redis.enabled: false, nothing else: %s" % keys)
    ya = rd(A, YML); top = ya.split("\n---\n")[0]
    ok("  cache:\n    type: caffeine\n    cache-names: customers\n" in top and "  health:\n    redis:\n      enabled: false\n" in top, "both above the ---, the type under the existing spring.cache:")
    ok(sum(1 for l in yd if "Course 8, unit 11:" in l) == 2, "two Course 8, unit 11: comments in application.yaml")
    ok("ddl-auto: validate" in ya and "include: health,prometheus" in ya, "ddl-auto validate and the exposure health,prometheus untouched")
    dd = adds(B, A, DEV)
    ok(all(l.startswith("+") for l in dd) and [l[1:] for l in dd if not l[1:].strip().startswith("#")] == ["  cache:", "    type: redis", "management:", "  health:", "    redis:", "      enabled: true"], "application-dev.yaml gains spring.cache.type: redis and the indicator on")
    allkeys = yaml_keys(os.path.join(A, YML)) + yaml_keys(os.path.join(A, DEV))
    ok(not any(k.startswith("spring.data.redis") for k in allkeys), "no spring.data.redis key in the anchor's YAML (Compose wires it)")
    cy = rd(A, CMP)
    svc = cy.split("\n  redis:\n")[1].split("\nvolumes:")[0] if "\n  redis:\n" in cy else ""
    ok("    image: redis:8-alpine\n" in svc and "pull_policy" not in cy and '      - "127.0.0.1:18882:6379"\n' in svc and "volumes" not in svc.replace("declares none", ""), "compose.yaml's redis: the tag, no pull_policy, 127.0.0.1:18882, no volume")
    ok("sha256:7958cfbb9d152f87dadfbc89f1b0b15938f0b81ff8982feb327476f4911935c3" in cy and "Redis 8.10.3" in cy and all(l.strip().startswith("#") for l in cy.splitlines() if "sha256:" in l), "the digest and Redis 8.10.3 in a comment only")
    ok(sorted(os.listdir(os.path.join(A, "tiffinbox-core/src/main/resources/db/migration"))) == ["V1__customer_and_pause.sql", "V2__seed.sql", "V3__customer_audit_columns.sql"], "Flyway's V1-V3, no V4")
    c11 = open("harness/src/probe/u11/Counter.java", encoding="utf-8").read(); c08 = open("../c8-unit08/harness/src/probe/u08/Counter.java", encoding="utf-8").read()
    ok(c11.replace("package probe.u11;", "package probe.u08;").replace(" Copied from unit 08's harness (probe.u08.Counter): only the package\n * line and this sentence differ.", "") == c08, "Counter.java = unit 08's, but for its package line and the sentence that says so")
    VALUES.append("C3 files 6 (one new) + README")
elif NAME == "r250":
    A = sys.argv[2]
    R = open(A + "/README.md", encoding="utf-8").read().splitlines()
    FR = [("that cache is Caffeine's since — bounded and counted", "(Course 8, unit 11, **Section 2's third change to this folder**"),
          ("path Boot's cache module builds a **`CaffeineCacheManager`** in place of the `ConcurrentMapCacheManager`.", "(Course 8, unit 11:"),
          ("**What it changes:** the customer list is kept by Caffeine, in the JVM", "(Course 8, unit 11:"),
          ("- `compose.yaml` — new, beside this README: one official Postgres image", "(Course 8, unit 11:")]
    for f, note in FR:
        h = [k for k, l in enumerate(R) if f in l]
        ok(len(h) == 1, "R.250: the sentence is in the README once: " + f[:60])
        ok(bool(h) and note in R[h[0]] and R[h[0]].index(note) > R[h[0]].index(f), "R.250: its unit 11 note sits on its line, after it: " + f[:60])
    ok(sum(1 for l in R if l.startswith("## Course 8 · unit 11 — ")) == 1, "the README's Course 8 · unit 11 section")
    ok(sum(1 for l in R if "need no Docker" in l) == 1, "\"need no Docker\" (Course 7 unit 39's block) stays as written - kept true by the nodocker capture")
    ok(R.count("docker pull redis:8-alpine") == 1, "the one docker pull redis:8-alpine line, beside the dev story")
    VALUES.append("R.250 sentences %d (+ \"need no Docker\" kept true)" % len(FR))
elif NAME == "yamlkeys":
    T = sys.argv[2]
    for f in (YML, DEV, "tiffinbox-web/src/main/resources/application-audit.yaml"):
        for k in yaml_keys(os.path.join(T, f)): print(k)
    sys.exit(0)
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
    def calls(b):
        out = {}
        for l in b:
            m = re.match(r"^call ([12]) of CustomerRepository\.findAll\(\) \(H2 2\.5\.250, Redis\): repository calls (\d+)$", l)
            if m: out[m.group(1)] = int(m.group(2))
        return out
    def res(b): return [l for l in b if l.startswith(("returned ", "threw "))]
    ok(calls(r) == {"1": 1, "2": 0} and calls(s) == {"1": 1, "2": 0}, "R.196: both states - call 1 reaches the repository once, call 2 not (the counter): %s %s" % (calls(r), calls(s)))
    ok(len(res(r)) == 2 and res(r)[0].startswith("returned java.util.ImmutableCollections") and res(r)[1].startswith("threw org.springframework.data.redis.serializer.SerializationException: Could not read JSON: Unexpected token"), "R.196: broken - call 1 returns Stream.toList()'s list, call 2 (the hit) throws: %s" % res(r))
    ok(res(s) == ["returned java.util.ArrayList", "returned java.util.ArrayList"], "R.196: solved - both calls return an ArrayList, the second a hit: %s" % res(s))
    for b in (r, s): ok("TiffinBox: exit 0" in b and "Maven: exit 0" in b and "Redis: exit 0" in b and "Redis removed: exit 0" in b, "exits 0 - the check is the second call's outcome and the counter, never the exit")
    ok("toList() in CustomerRepository.java: 1" in r and "toList() in CustomerRepository.java: 0" in s, "the broken tree holds the toList() statement, the solved one not")
    VALUES.append("the line %s words · broken: call 2 (the hit) threw SerializationException: Could not read JSON: Unexpected token, repository calls %s · solved: call 2 returned java.util.ArrayList, repository calls %s · exit 0 both" % (W, calls(r).get("2"), calls(s).get("2")))
elif NAME == "nodocker":
    L = lines(sys.argv[2])
    res = [tuple(int(x) for x in m.groups()) for m in (re.search(r"Tests run: (\d+), Failures: (\d+), Errors: (\d+), Skipped: (\d+)$", l) for l in L if "Results line" in l) if m]
    ok(len(res) == 3, "three Results lines (package's; verify's two executions): %s" % res)
    if len(res) == 3:
        ok(all(r[1:] == (0, 0, 0) for r in res), "no failure, no error, nothing skipped")
        ok(res[0][0] == res[1][0], "the Docker-free package runs the same tests as verify's first execution: %d" % res[0][0])
    ok(sum(1 for l in L if l.startswith("  exit 0 · BUILD SUCCESS · offline: yes")) == 2, "both builds exit 0, offline")
    ok(any("surefire-reports-it: absent - no container test ran" in l for l in L), "package with DOCKER_HOST at nothing: no container test ran")
    v = grab(L, r"^  the verify log: 'Found 1 JPA repository interface' (\d+) · 'Found 0 Redis repository interfaces' (\d+) · 'Creating container for image' (\d+) · 'Pulling' (\d+) · 'RedisConnectionFailure' (\d+)$")
    ok(bool(v) and int(v[0].group(2)) > 0 and v[0].group(4) == "0" and v[0].group(5) == "0", "verify: the third module's line, nothing pulled, no Redis connection failure (the tests run on Caffeine)")
    if len(res) == 3:
        VALUES.append("%d (mvn -o package, Maven's DOCKER_HOST at nothing - no Docker) · %d + %d (mvn -o verify: H2 in memory + PostgreSQL in containers, on Caffeine, no Redis)" % (res[0][0], res[1][0], res[2][0]))
elif NAME == "anchor":
    L = lines(sys.argv[2]); S = sections(L)
    lib = {t: int(m[0].group(1)) for t, m in ((t, grab(L, r"^  %s/: (\d+) libraries" % t)) for t in ("before", "after")) if m}
    gained = [l[len("  gained: "):] for l in L if l.startswith("  gained: ")]
    ok(lib.get("after", 0) - lib.get("before", 0) == len(gained) and not any(l.startswith("  lost: ") for l in L), "the libs count: after = before + the jars gained, none lost")
    for j in ("lettuce-core-7.5.2.RELEASE.jar", "spring-data-redis-4.1.2.jar", "spring-data-keyvalue-4.1.2.jar", "spring-boot-data-redis-4.1.2.jar", "reactor-core-3.8.8.jar"):
        ok(j in gained, "gained: " + j)
    jx = grab(L, r"^  Jackson's databind in after/'s lib/: (jackson-databind-[0-9.]+\.jar) \(tools\.jackson's, Jackson 3\) · jedis in lib/: (\d+)$")
    out = {}
    for h, body in S[1:]:
        db, st = jvm(body)
        strict3(body, db)
        v = grab(body, r"^PROBE versions: Spring Boot (\S+) · Spring Framework (\S+) · Spring Data JPA (\S+) · Spring Data JDBC (\S+) · Spring Data Redis (\S+) · Hibernate (\S+) · Flyway \(version\.txt\) (\S+)$")
        ok(bool(v) and v[0].groups() == ("4.1.2", "7.0.10", "4.1.2", "4.1.2", "4.1.2", "7.4.13.Final", "12.4.0"), "the version lines (R.246) on " + db)
        ok(bool(v) and ("  log: HHH000001: Hibernate ORM core version " + v[0].group(6)) in body, "Hibernate's version = HHH000001's")
        w = window(body, "reads: five calls of CustomerRepository.findAll()")
        ok(bool(w) and w["per"] == [1, 0, 0, 0, 0], "five calls [1, 0, 0, 0, 0] (%s, %s)" % (db, st))
        cls = grab(body, r"^PROBE reads: the classes read back - call 1 \(the miss\): (\S+) of (\S+) · call 5 \(a hit\): (\S+) of \[(\S+)\]$")
        ok(bool(cls) and cls[0].groups() == ("java.util.ArrayList", "com.tiffinbox.Customer", "java.util.ArrayList", "com.tiffinbox.Customer"), "the classes read back: ArrayList of Customer, miss and hit")
        hc = {m.group(1): (m.group(2), m.group(3), m.group(4)) for m in (re.match(r"^PROBE http \(.*\): GET (\S+) -> (\d+)(?: · status (\S+) · components (.*))?$", l) for l in body) if m}
        if h.startswith("-- after/ on H2 in memory, NO Redis"):
            ok(st == "in the JVM, Caffeine" and db.startswith("H2"), "the default run: H2, Caffeine")
            mgr(body, CAF)
            ok("PROBE the environment: spring.cache.type caffeine · spring.cache.cache-names customers · management.health.redis.enabled false · spring.cache.redis.time-to-live unset · spring.cache.redis.key-prefix unset · spring.profiles.active unset" in body, "the default run's settings: type caffeine, the indicator off")
            ok("PROBE RedisCaching (com.tiffinbox.web): its configuration bean absent · RedisCacheManagerBuilderCustomizer beans [] · RedisCacheConfiguration beans []" in body, "the default run builds neither RedisCaching bean")
            ok(hc.get("/dashboard", ("",))[0] == "200" and hc.get("/actuator/health", ("",))[0] == "200" and hc.get("/actuator/health/readiness", ("",))[0] == "200", "R.386: the default run with no Redis - /dashboard 200, health 200, readiness 200: %s" % hc)
            ok("redis" not in (hc.get("/actuator/health", ("", "", ""))[2] or ""), "R.386: health has no redis component on the default run")
            out["default"] = (hc, w)
        else:
            ok(st == "Redis" and db.startswith("PostgreSQL"), "the dev-shaped run: PostgreSQL, Redis")
            mgr(body, RCM)
            ok(any(l == "PROBE cache customers: org.springframework.data.redis.cache.RedisCache · native org.springframework.data.redis.cache.DefaultRedisCacheWriter" for l in body), "the cache: RedisCache")
            ok("PROBE RedisConnectionFactory: org.springframework.data.redis.connection.lettuce.LettuceConnectionFactory" in body and "PROBE the connection: 127.0.0.1:20502" in body, "LettuceConnectionFactory, the connection 127.0.0.1:20502")
            rv = grab(body, r"^PROBE Redis's INFO server, through the connection: redis_version:(\S+)$")
            wl = writerline(body)
            ok(wl == ("org.springframework.data.redis.cache.DefaultRedisCacheWriter", "false", "yes"), "the cache writer TiffinBox gives Redis: asynchronousWrites false, a lock wait set: %s" % (wl,))
            ok(any(l.startswith("PROBE the customers cache's configuration: value serializer org.springframework.data.redis.serializer.GenericJacksonJsonRedisSerializer · key prefix for customers \"customers::\"") for l in body), "the JSON serializer, the prefix customers::")
            ok(hc.get("/actuator/health", ("",))[0] == "200" and "redis UP" in (hc.get("/actuator/health", ("", "", ""))[2] or ""), "the dev-shaped run: health 200 with redis UP")
            sc = [l for l in body if l.startswith("  redis-cli --scan: ")]
            ok(sc == ["  redis-cli --scan: customers::SimpleKey []"], "R.392: the one key Redis holds - customers::SimpleKey []: %s" % sc)
            out["dev"] = (hc, w, rv[0].group(1) if rv else "?", wl)
    ok(set(out) == {"default", "dev"}, "both runs: the default and the dev-shaped")
    if set(out) == {"default", "dev"} and jx:
        VALUES.append("default run (H2, no Redis): %s, health %s, readiness %s, /dashboard %s, no redis component, RedisCaching's beans absent · dev-shaped (PostgreSQL + Redis by the digest): %s, LettuceConnectionFactory 127.0.0.1:20502, redis_version:%s, the writer asynchronousWrites false with a lock, health 200 redis UP, key customers::SimpleKey [] · [1, 0, 0, 0, 0] on both · classes ArrayList of Customer · libs %d -> %d (+%d: %s) · Boot 4.1.2 · Framework 7.0.10 · Spring Data JPA/JDBC/Redis 4.1.2 · HHH000001 7.4.13.Final · Flyway 12.4.0 · Lettuce lettuce-core-7.5.2.RELEASE.jar · Jackson %s · Found 1 JPA + 1 JDBC + 0 Redis"
                      % (CAF, out["default"][0]["/actuator/health"][0], out["default"][0]["/actuator/health/readiness"][0], out["default"][0]["/dashboard"][0], RCM, out["dev"][2], lib["before"], lib["after"], len(gained), ", ".join(gained), jx[0].group(1)))
elif NAME == "compose":
    L = lines(sys.argv[2])
    cfg = [l.strip() for l in L if l.startswith("    image:") or l.startswith("    published:")] + [l.strip() for l in L if l.strip().startswith(("image:", "published:"))]
    ok("image: redis:8-alpine" in cfg and "image: postgres:18-alpine" in cfg and 'published: "18882"' in cfg and 'published: "18881"' in cfg, "docker compose config of the anchor's file: the tags, 18881 and 18882")
    ok("  keys spring.data.redis.* in after/'s YAML files: 0" in L, "no spring.data.redis.* key in the anchor's YAML")
    ok(any(l.startswith("  Using Docker Compose file …/compose-run/compose.yaml") for l in L), "Boot: Using Docker Compose file - the copy's")
    ev = {m.group(1): m.group(2) for m in (re.match(r"^  (Network c8-unit11_default|Volume c8-unit11_data|Container c8-unit11-postgres-1|Container c8-unit11-redis-1): (.*)$", l) for l in L) if m}
    ok(ev.get("Network c8-unit11_default") == "Creating Created" and ev.get("Volume c8-unit11_data") == "Creating Created", "the network and the volume created: %s" % ev)
    for c in ("postgres", "redis"): ok(ev.get("Container c8-unit11-%s-1" % c) == "Creating Created Starting Started Waiting Healthy", "the %s container: Created / Started / Waiting / Healthy: %s" % (c, ev.get("Container c8-unit11-%s-1" % c)))
    body = L
    db, st = jvm(body)
    strict3(body, db)
    mgr(body, RCM)
    cdb = grab(body, r"^PROBE the beans named \.\.\.ConnectionDetails\.\.\.: \[(.*)\]$")
    names = cdb[0].group(1).split(", ") if cdb else []
    ok("dataRedisConnectionDetailsForC8Unit11Redis1" in names and any(n.startswith("jdbcConnectionDetailsForC8Unit11Postgres1") for n in names), "the connection-details beans Boot's Compose support made: %s" % names)
    ok("PROBE the connection: 127.0.0.1:20503" in body and any(l.startswith("PROBE the environment: spring.cache.type redis · spring.cache.cache-names customers · management.health.redis.enabled true") and l.endswith("spring.profiles.active dev") for l in body), "the profile dev: type redis, the indicator on, the copy's Redis on 20503")
    w = window(body, "reads: five calls of CustomerRepository.findAll()")
    ok(bool(w) and w["per"] == [1, 0, 0, 0, 0] and w["db"] == "PostgreSQL 18.6" and w["store"] == "Redis", "five reads [1, 0, 0, 0, 0] on the Compose PostgreSQL and Redis")
    ok(any(l == "  redis-cli in the copy's Redis container (c8-unit11-redis-1), after the five reads, TiffinBox paused: --scan customers::SimpleKey [] · TYPE string" for l in L), "redis-cli --scan in the Compose Redis: customers::SimpleKey [], TYPE string")
    hc = [l for l in body if re.match(r"^PROBE http \(.*\): GET /actuator/health -> 200 · status UP · components \[.*redis UP.*\]$", l)]
    ok(len(hc) == 1, "health 200 with redis UP")
    ex = grab(L, r"^  after TiffinBox stopped \(Boot's own stop\): the project's containers (.*) · its network (\S*) · its volume (\S*)$")
    ok(bool(ex) and ex[0].group(1) == "c8-unit11-postgres-1 Exited (0)|c8-unit11-redis-1 Exited (0)" and ex[0].group(2) == "c8-unit11_default" and ex[0].group(3) == "c8-unit11_data", "Boot's stop leaves both containers Exited, the network and the volume")
    rm = [l.strip() for l in L if re.match(r"^  (Container|Network|Volume) .* Removed$", l)]
    ok(sorted(rm) == sorted(["Container c8-unit11-postgres-1 Removed", "Container c8-unit11-redis-1 Removed", "Network c8-unit11_default Removed", "Volume c8-unit11_data Removed"]), "down -v: both containers, the network and the volume Removed: %s" % rm)
    then = grab(L, r"^  then: the project's containers (\d+) · its network (\d+) · volumes (\d+) \((\d+) \+ this script's PostgreSQL container's (\d+)\)$")
    ok(bool(then) and then[0].group(1) == "0" and then[0].group(2) == "0" and int(then[0].group(3)) == int(then[0].group(4)) + int(then[0].group(5)), "then: no container, no network, the volumes back")
    if ev and ex and then:
        VALUES.append("Using Docker Compose file · Network c8-unit11_default Created · c8-unit11-redis-1 and -postgres-1 Created / Started / Waiting / Healthy · beans %s · no spring.data.redis key · %s on 127.0.0.1:20503 · [1, 0, 0, 0, 0] · --scan customers::SimpleKey [] · health 200 redis UP · after Boot's stop: %s, the network and the volume left · down -v: %d Removed lines, volumes back to %s"
                      % (", ".join(names), RCM, ex[0].group(1).replace("|", " and "), len(rm), then[0].group(4)))
elif NAME == "jdk":
    L = lines(sys.argv[2])
    db, st = jvm(L); mgr(L, RCM)
    ok(any(l.startswith("PROBE the customers cache's configuration: value serializer org.springframework.data.redis.serializer.JdkSerializationRedisSerializer") for l in L), "the jdk copy: Java's serialization, Boot's default")
    ok("PROBE RedisCaching (com.tiffinbox.web): its configuration bean present · RedisCacheManagerBuilderCustomizer beans [immediateLockingWriter] · RedisCacheConfiguration beans []" in L, "the copy keeps the writer, lacks the configuration bean")
    ws = [window(L, "two: call %d of CustomerRepository.findAll()" % i) for i in (1, 2)]
    for i, w in enumerate(ws, 1):
        ok(bool(w) and w["per"] == [1] and w["rest"].startswith("threw org.springframework.data.redis.serializer.SerializationException: Cannot serialize") and "java.io.NotSerializableException: com.tiffinbox.Customer" in w["rest"], "call %d: invokes (1) and throws at put - NotSerializableException: com.tiffinbox.Customer" % i)
    ok("  redis-cli --scan: " in L, "redis-cli --scan: no key")
    ok("  Customer.java (tiffinbox-core, unchanged): 3:public record Customer(String name, int mealsPerDay, int pricePerMeal, String mealType) {" in L or any(l.startswith("  Customer.java (tiffinbox-core, unchanged): ") and l.endswith("'Serializable' in it: 0") for l in L), "the record is not Serializable")
    if all(ws):
        VALUES.append("the copy without RedisCaching's configuration (Java's serialization): call 1 and call 2 each invoke (invocations 1, then 2) and throw SerializationException: Cannot serialize <- NotSerializableException: com.tiffinbox.Customer at put · redis-cli --scan: no key · the record not Serializable")
elif NAME == "json":
    L = lines(sys.argv[2]); S = sections(L)
    a = S[0][1]; t = S[1][1]
    jvm(a); mgr(a, RCM)
    w = window(a, "reads: five calls of CustomerRepository.findAll()")
    ok(bool(w) and w["per"] == [1, 0, 0, 0, 0] and w["store"] == "Redis", "five reads [1, 0, 0, 0, 0] on Redis")
    cls = grab(a, r"^PROBE reads: the classes read back - call 1 \(the miss\): (\S+) of (\S+) · call 5 \(a hit\): (\S+) of \[(\S+)\]$")
    i = a.index("  redis-cli GET \"customers::SimpleKey []\" (raw bytes):") if "  redis-cli GET \"customers::SimpleKey []\" (raw bytes):" in a else -1
    by = a[i + 1].strip() if i >= 0 else ""
    ok(by.startswith('["java.util.ArrayList",[{"@class":"com.tiffinbox.Customer","name":'), "R.379: the bytes by redis-cli GET: [\"java.util.ArrayList\",[{\"@class\":\"com.tiffinbox.Customer\",...")
    ok(bool(cls) and cls[0].group(3) == "java.util.ArrayList" and cls[0].group(4) == "com.tiffinbox.Customer" and "java.util.ArrayList" in by and "com.tiffinbox.Customer" in by, "R.379: the class Java read back (ArrayList of Customer) = the classes the bytes name")
    names = re.findall(r'"name":"(\w+)"', by)
    ok(len(names) == int(re.search(r"rows (\d+)", w["rest"]).group(1)) if w else False, "the bytes hold one element per row the read returned")
    ty = grab(a, r'^  redis-cli TYPE "customers::SimpleKey \[\]": (\S+) · TTL: (-?\d+)$')
    ok(bool(ty) and ty[0].groups() == ("string", "-1"), "TYPE string, TTL -1 (no time to live set)")
    nv = grab(a, r'^PROBE nullv: two calls of @Cacheable\("h11"\) none\(\) \(PostgreSQL 18\.6, Redis\): returned null · per call \[1, 0\] and \[1, 0\]$')
    nb = grab(a, r'^  redis-cli --no-raw GET "h11::SimpleKey \[\]" \(the harness\'s null, its bytes escaped\): ("\\xac\\xed\\x00\\x05sr\\x00\+org\.springframework\.cache\.support\.NullValue.*)$')
    ok(any(l.startswith("PROBE nullv: a harness bean, not the anchor's cache - HarnessNull.Lookups; the cache names at the start [customers, h11]") for l in a), "R.384: the harness JVM names its own cache (customers,h11)")
    sc = [l for l in a if l.startswith("  redis-cli --scan: ")]
    ok(sc == ["  redis-cli --scan: customers::SimpleKey []|h11::SimpleKey []"], "the keys: the anchor's list and the harness's null: %s" % sc)
    jvm(t); mgr(t, RCM)
    w1 = window(t, "two: call 1 of CustomerRepository.findAll()"); w2 = window(t, "two: call 2 of CustomerRepository.findAll()")
    ok(bool(w1) and w1["per"] == [1] and w1["rest"].startswith("returned java.util.ImmutableCollections$ListN of [com.tiffinbox.Customer]"), "toList(): call 1 (the miss) returns")
    ok(bool(w2) and w2["per"] == [0] and w2["rest"].startswith("threw org.springframework.data.redis.serializer.SerializationException: Could not read JSON: Unexpected token") and "type id" in w2["rest"], "toList(): call 2 (the hit) throws - Unexpected token ... type id, invocations 0 on the call")
    j = t.index("  redis-cli GET \"customers::SimpleKey []\" (raw bytes):") if "  redis-cli GET \"customers::SimpleKey []\" (raw bytes):" in t else -1
    tb = t[j + 1].strip() if j >= 0 else ""
    ok(tb.startswith('[{"@class":"com.tiffinbox.Customer"'), "toList()'s bytes: a bare array, the list's class absent")
    if w and w2 and nb:
        VALUES.append("bytes by redis-cli GET %s… · the class read back java.util.ArrayList of com.tiffinbox.Customer · [1, 0, 0, 0, 0] · TYPE string, TTL -1 · toList() copy: call 1 returned, call 2 (the hit) threw SerializationException: Could not read JSON: Unexpected token … type id (bytes %s…) · the harness's null (h11, labelled): per call [1, 0], bytes %s…"
                      % (by[:60], tb[:36], nb[0].group(1)[:60]))
elif NAME == "renamed":
    L = lines(sys.argv[2]); S = sections(L)
    sec = {h: b for h, b in S}
    first = S[0][1]; jvm(first)
    w0 = window(first, "one: one call of CustomerRepository.findAll()")
    ok(bool(w0) and w0["per"] == [1], "the first JVM writes the list (1 / 1)")
    pl = [l for l in L if l.startswith("  the planted bytes (an earlier build's: Priya's mealType written as type) - the edit's diff: ")]
    ok(pl == ['  the planted bytes (an earlier build\'s: Priya\'s mealType written as type) - the edit\'s diff: < "mealType":"VEGAN"} > "type":"VEGAN"}'], "the plant: one element's mealType written as type: %s" % pl)
    ok(sum(1 for l in L if re.match(r"^  redis-cli SET .*: OK$", l)) == 3, "three redis-cli SET ... OK (the second client wrote the bytes)")
    s2 = S[1][1]; jvm(s2)
    w = window(s2, "one: one call of CustomerRepository.findAll()")
    ok(bool(w) and w["per"] == [0] and w["rest"] == "returned", "S8.29's prints: invocations 0, statements 0, no exception")
    pr = [l for l in s2 if "name=Priya" in l]
    ok(pr == ["PROBE one: element com.tiffinbox.Customer = Customer[name=Priya, mealsPerDay=1, pricePerMeal=120, mealType=null]"], "the element read back: Priya's mealType=null: %s" % pr)
    ex = grab(s2, r"^  exit 0 · its log, every line but the harness's own PROBE lines: WARN (\d+) · ERROR (\d+) · exception class names (\d+)$")
    ok(bool(ex) and ex[0].group(2) == "0" and ex[0].group(3) == "0", "no ERROR line, no exception in the log")
    wl = [l for l in s2 if l.startswith("  its WARN line: ")]
    ok(all("MacOSDnsServerAddressStreamProvider" in l for l in wl), "its only WARN is Netty's DNS line at start: %s" % wl)
    pq = [l for l in L if l.startswith("  psql (a second client, PostgreSQL): ")]
    ok(pq == ["  psql (a second client, PostgreSQL): Priya VEGAN"], "psql's row: Priya VEGAN")
    w3 = window(S[2][1], "one: one call of CustomerRepository.findAll()")
    ok(bool(w3) and w3["per"] == [0] and "Cannot map `null` into type `int`" in w3["rest"], "the renamed int field: LOUD - Cannot map null into type int, at the hit")
    w4 = window(S[3][1], "one: one call of CustomerRepository.findAll()")
    ok(bool(w4) and w4["per"] == [0] and "com.tiffinbox.CustomerV0" in w4["rest"] and "threw org.springframework.data.redis.serializer.SerializationException" in w4["rest"], "the renamed class: LOUD - its message names com.tiffinbox.CustomerV0")
    jd = [l.strip() for l in L if l.startswith("    ") and ("FAIL_ON_UNKNOWN_PROPERTIES" in l or "iconst_0" in l or "invokespecial" in l or "invokevirtual" in l or "bipush" in l)]
    ok(len(jd) >= 6 and any("String FAIL_ON_UNKNOWN_PROPERTIES" in l for l in jd) and sum(1 for l in jd if l.endswith("iconst_0")) == 2, "javap: Jackson's default iconst_0 and the serializer's configure(FAIL_ON_UNKNOWN_PROPERTIES, iconst_0): %s" % jd)
    if w and w3 and w4:
        cls_msg = re.search(r"Could not read JSON: ([^<]*)", w4["rest"]).group(1).strip()
        VALUES.append("the anchor's key customers::SimpleKey [] · the planted bytes (Priya's mealType as type, by redis-cli SET) -> Customer[name=Priya, mealsPerDay=1, pricePerMeal=120, mealType=null], invocations 0, statements 0, exit 0, no exception, no ERROR · psql: Priya VEGAN · credited to the serializer's own setting: Jackson 3's FAIL_ON_UNKNOWN_PROPERTIES default iconst_0 and GenericJacksonJsonRedisSerializer's builder configure(FAIL_ON_UNKNOWN_PROPERTIES, iconst_0) (javap) · renamed int field: Cannot map `null` into type `int` · renamed class: %s" % cls_msg)
elif NAME == "strict":
    L = lines(sys.argv[2]); S = sections(L)
    a = S[0][1]; jvm(a)
    w1 = window(a, "two: call 1 of CustomerRepository.findAll()"); w2 = window(a, "two: call 2 of CustomerRepository.findAll()")
    ok(bool(w1) and bool(w2) and w1["per"] == [1] and w2["per"] == [0] and w2["rest"].startswith("returned java.util.ArrayList"), "the strict copy reads today's bytes: [1] then [0], a hit")
    w = window(S[1][1], "one: one call of CustomerRepository.findAll()")
    ok(bool(w) and w["per"] == [0] and 'Could not read JSON: Unrecognized property "type" (class com.tiffinbox.Customer)' in w["rest"] and w["rest"].startswith("threw org.springframework.data.redis.serializer.SerializationException"), "strict: the renamed String field's hit throws SerializationException ... Unrecognized property \"type\" - the caller gets the exception, not a miss (invocations 0)")
    wa = window(S[2][1], "one: one call of CustomerRepository.findAll()")
    ok(bool(wa) and wa["per"] == [0] and 'Unrecognized property "phone"' in wa["rest"], "the trade-off: an added field (phone) throws too")
    p = S[3][1]; jvm(p)
    ok(any(l.startswith("PROBE the environment: spring.cache.type redis") and "spring.cache.redis.key-prefix v2:" in l for l in p) and any('key prefix for customers "v2:customers::"' in l for l in p), "the prefix from CacheProperties applied: v2:customers::")
    wp = window(p, "one: one call of CustomerRepository.findAll()")
    ok(bool(wp) and wp["per"] == [1] and wp["rest"] == "returned", "with the versioned prefix the old bytes are a miss: invocations 1")
    ok("PROBE one: element com.tiffinbox.Customer = Customer[name=Priya, mealsPerDay=1, pricePerMeal=120, mealType=VEGAN]" in p, "and the read is the database's: Priya VEGAN")
    sc = [l for l in p if l.startswith("  redis-cli --scan: ")]
    ok(sc == ["  redis-cli --scan: customers::SimpleKey []|v2:customers::SimpleKey []"], "--scan shows both keys: %s" % sc)
    if w and wa and wp:
        VALUES.append("the strict copy (FAIL_ON_UNKNOWN_PROPERTIES enabled): the same planted bytes -> the hit throws SerializationException: Could not read JSON: Unrecognized property \"type\", invocations 0 (the caller gets the exception) · the trade-off: an added field (phone) throws too · a versioned key prefix (v2:, from CacheProperties) on the anchor: invocations 1, Priya VEGAN, --scan both keys")
elif NAME == "writer":
    L = lines(sys.argv[2]); S = sections(L)
    res = {}
    for h, b in S[:2]:
        db, st = jvm(b)
        wl = writerline(b)
        e = grab(b, r"^PROBE evict \(PostgreSQL 18\.6, Redis\): ten rounds of a read, add\(a new name\) and an immediate read: the new name missing \(stale\) in (\d+) of 10 rounds$")
        r = grab(b, r"^PROBE evict: then fifty rounds .*: a read right after the put reached the repository in at least one of the fifty: (yes|no)$")
        rows = grab(b, r"^PROBE evict: rows by JdbcTemplate \(a second client\) (\d+)$")
        pq = grab(b, r"^  psql \(a second client\): customers (\d+)$")
        ok(bool(rows) and bool(pq) and rows[0].group(1) == pq[0].group(1) == "14", "the ten names stored: 4 + 10 rows, JdbcTemplate = psql")
        per = grab(b, r"^PROBE evict: per round, the immediate read's repository calls: \[(.*)\]$")
        if e and per:
            items = per[0].group(1).split(", ")
            ok(sum(1 for x in items if " stale " in x) == int(e[0].group(1)), "the stale count = the rounds listed stale")
            ok(all(x.endswith(" stale 0") or x.endswith(" fresh 1") for x in items), "a stale read reached no repository, a fresh one did (the counter per round)")
        res["default" if h.startswith("-- the writer copy") else "anchor"] = (wl, e[0].groups() if e else None, r[0].group(1) if r else None)
    d, a = res.get("default"), res.get("anchor")
    ok(bool(d) and d[0] == ("org.springframework.data.redis.cache.DefaultRedisCacheWriter", "true", "no"), "the writer Boot builds over Lettuce: asynchronousWrites true, no lock")
    ok(bool(a) and a[0] == ("org.springframework.data.redis.cache.DefaultRedisCacheWriter", "false", "yes"), "the cache writer TiffinBox gives Redis: asynchronousWrites false, a lock")
    ok(bool(d) and d[1] is not None and int(d[1][0]) > 0, "the default writer: stale in N of 10, N > 0")
    ok(bool(a) and a[1] == ("0",) and a[2] == "no", "the anchor's writer: stale 0 of 10, the read after a put never misses")
    ok(bool(d) and d[2] == "yes", "the default writer: a read right after a put reached the repository in some round")
    ok(any(l == "  DefaultRedisCacheWriter: private final boolean asynchronousWrites;" for l in L) and any(l.startswith("  RedisCacheWriter.RedisCacheWriterConfigurer: public default org.springframework.data.redis.cache.RedisCacheWriter$RedisCacheWriterConfigurer immediateWrites();") for l in L), "javap: asynchronousWrites and immediateWrites()")
    ok("  Redis clients in after/'s lib/: lettuce-core-7.5.2.RELEASE.jar - Lettuce only" in L, "Lettuce only, from the jar names")
    if d and a and d[1]:
        VALUES.append("the writer Boot builds over Lettuce (the copy, asynchronousWrites true, no lock): @CacheEvict(allEntries = true) then an immediate read - stale in %s of 10; a read right after a put reached the repository in some of fifty rounds (the count not voiced) · the cache writer TiffinBox gives Redis (immediateWrites + enableLocking): stale %s of 10, none after a put · javap: asynchronousWrites, immediateWrites() · Lettuce only" % (d[1][0], a[1][0]))
elif NAME == "ttlbean":
    L = lines(sys.argv[2]); S = sections(L)
    b = S[0][1]; jvm(b)
    ok(any("spring.cache.redis.time-to-live set" in l for l in b) and "PROBE RedisCaching (com.tiffinbox.web): its configuration bean present · RedisCacheManagerBuilderCustomizer beans [immediateLockingWriter] · RedisCacheConfiguration beans [redisCacheConfiguration]" in b, "the ttlbean copy: the setting in the environment, the bean present")
    t1 = grab(b, r'^  redis-cli TTL "customers::SimpleKey \[\]": (-?\d+)$')
    ok(bool(t1) and t1[0].group(1) == "-1", "the copy's bean ignores CacheProperties: TTL -1 (no expiry), silent")
    a = S[1][1]; jvm(a)
    t2 = grab(a, r'^  redis-cli TTL "customers::SimpleKey \[\]": TTL <n> · a positive count, at most the configured value: (yes|no)$')
    ok(bool(t2) and t2[0].group(1) == "yes", "the anchor's bean applies the setting: a positive TTL, at most the configured value (read back, R.380)")
    c = S[2][1]; jvm(c)
    t3 = grab(c, r'^  redis-cli TTL "customers::SimpleKey \[\]": (-?\d+)$')
    ok(bool(t3) and t3[0].group(1) == "-1", "the anchor with no time to live: TTL -1")
    for body in (b, a, c):
        w = window(body, "one: one call of CustomerRepository.findAll()")
        ok(bool(w) and w["per"] == [1], "each JVM's one call writes the entry (1 / 1)")
    if t1 and t2 and t3:
        VALUES.append("the copy whose bean ignores CacheProperties, time-to-live set: redis-cli TTL -1 · the anchor's bean, the same setting: TTL a positive count, at most the configured value (masked, never voiced as a time) · the anchor with none: TTL -1")
elif NAME == "health":
    L = lines(sys.argv[2]); S = sections(L)
    a = S[0][1]; jvm(a)
    ok(any("management.health.redis.enabled true" in l and "spring.cache.type caffeine" in l for l in a), "the copy's settings: the cache Caffeine's, the indicator on (the harness's flag)")
    hc = {m.group(1): (m.group(2), m.group(3), m.group(4)) for m in (re.match(r"^PROBE http \(.*\): GET (\S+) -> (\d+)(?: · status (\S+) · components (.*))?$", l) for l in a) if m}
    ok(hc.get("/actuator/health", ("",))[0] == "503" and hc["/actuator/health"][1] == "DOWN" and "redis DOWN" in hc["/actuator/health"][2], "no Redis, the indicator on: /actuator/health 503, redis DOWN")
    ok(hc.get("/actuator/health/readiness", ("",))[0] == "200" and hc.get("/dashboard", ("",))[0] == "200", "readiness 200, /dashboard 200")
    ok(sum(1 for l in L if l == "  listening on 20506: 0") == 2, "nothing listened on 20506, before and after")
    b = S[1][1]; jvm(b)
    ws = [window(b, "two: call %d of CustomerRepository.findAll()" % i) for i in (1, 2)]
    ok(all(w and w["per"] == [0] and w["rest"].startswith("threw org.springframework.data.redis.RedisConnectionFailureException: Unable to connect to Redis") for w in ws), "the cache type redis with no Redis: the context starts, every cached call throws RedisConnectionFailureException")
    if hc and all(ws):
        VALUES.append("no Redis, Redis's indicator on: /actuator/health %s (redis DOWN), readiness %s, /dashboard %s · the cache type redis with no Redis: started, each call threw RedisConnectionFailureException · the anchor's default: health 200, no redis component (anchor)" % (hc["/actuator/health"][0], hc["/actuator/health/readiness"][0], hc["/dashboard"][0]))
elif NAME == "seven":
    L = lines(sys.argv[2]); S466 = sys.argv[3]
    h = [m.group(1) for m in (re.search(r"the seven responses: 7 lines · md5 ([0-9a-f]{32})", l) for l in L) if m]
    ok(len(h) == 2 and h[0] == h[1] == S466, "the seven on before/ and after/ = Course 7's published md5")
    ok(sum(1 for l in L if l == "  GET /dashboard: 200") == 2, "GET /dashboard 200 on both")
    ok("  exit 0 · cmp with xcheck.sql (= Course 7's capstone's): the same, byte for byte" in L, "Hibernate's schema script = xcheck.sql")
    ok("  the seven, after/ against before/: lines that differ: 0" in L, "0 lines differ")
    ok(sum(1 for l in L if l.startswith("  GET /actuator/health/readiness -> 200 · GET /actuator/health -> 200 ")) == 2, "the jar's default run: health 200, before and after")
    ok(sum(1 for l in L if l == "  log: Found 0 Redis repository interfaces.") == 1, "after/'s jar: the third module, Found 0 Redis")
    VALUES.append("the seven %s… on before/ and after/ (0 lines differ) · GET /dashboard 200 · health 200 · Hibernate's script = xcheck.sql" % S466[:8])
else:
    print("FAIL no check named " + NAME); sys.exit(1)
for o in oks: print("ok " + o)
for f in fails: print("FAIL " + f)
print("VALUES " + "; ".join(VALUES))
sys.exit(1 if fails else 0)
