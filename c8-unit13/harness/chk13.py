"""Unit 13's checks (python3 -I -B harness/chk13.py NAME ARGS...). Each capture's numbers are asserted against a second witness of the
same run - never a typed figure: the invocation counter against Hibernate's statement counter per call (R.375), the row psql wrote
against the lookup that found it or not (R.359), the key a JVM stored against redis-cli's --scan and GET, the TTL redis-cli read
against the value in the anchor's YAML (R.380), the database the harness named against Flyway's Database line, the CacheManager bean
against the cache names it made, Surefire's XML against Maven's Results lines, the seven's md5 against Course 7's published one.
Prints ok/FAIL lines and one VALUES line; exits 1 on any FAIL.
  static AFTER BEFORE   the change itself, read off the files (C5: CustomerRepository.java, application.yaml and the README)
  r250 AFTER            the anchor README's, YAML's and Javadoc's sentences C5 made false or dated: each carries its unit 13 note
  ttlvalue TREE         TREE's spring.cache.redis.time-to-live, as the count redis-cli's TTL reads (the receipt's comparison only)
  wib CAPTURE FILE      the lines the exercise's block printed for FILE (bash's), for receipts.sh to compare with "What it prints"
  exercise|anchor|sync|nulls|unless|cond|nonull|syncunless|seven CAPTURE [...]"""
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
STORE = r"(Redis|in the JVM, Caffeine|in the JVM, a ConcurrentMap)"
CAF = "org.springframework.cache.caffeine.CaffeineCacheManager"
RCM = "org.springframework.data.redis.cache.RedisCacheManager"
KEY = "customers::SimpleKey []"
WRITER = ("org.springframework.data.redis.cache.DefaultRedisCacheWriter", "false", "yes")
EMPTY = "Optional.empty"
NOBODY = "Optional[Customer[name=Nobody, mealsPerDay=1, pricePerMeal=100, mealType=VEG]]"


def window(L, label):
    """A counted window's line: calls, statements, the two per-call lists; asserted equal (R.375)."""
    m = grab(L, r"^PROBE " + re.escape(label) + r" \(" + DBS + ", " + STORE + r"\): repository calls (\d+) · prepareStatementCount (\d+) · per call " + LIST + " and " + LIST + r"(.*)$")
    if not m: return None
    db, st, c, s, a, b, rest = m[0].groups()
    a, b = lst(a), lst(b)
    ok(a == b, "R.375: %s on %s - the counter's per-call list %s = the statement counter's %s" % (label, db, a, b))
    ok(sum(a) == int(c) and sum(b) == int(s), "%s on %s: each total is the sum of its per-call list" % (label, db))
    eq = grab(L, r"^PROBE " + re.escape(label) + r": the two witnesses' per-call lists (equal|DIFFER)")
    ok(bool(eq) and eq[0].group(1) == "equal", "%s on %s: the harness's own comparison says equal" % (label, db))
    return {"db": db, "store": st, "calls": int(c), "sql": int(s), "per": a, "rest": rest}


def jvm(body, want_db=None, want_store=None):
    """One harness JVM's section: its database, its store, its exit; Flyway's Database line agrees."""
    d = [m for m in (re.match(r"^PROBE started: yes · the database that answered: " + DBS + r" · the cache's store: " + STORE + r" · a web server: yes$", l) for l in body) if m]
    ok(len(d) == 1, "one JVM per section, started, its web server on")
    if not d: return ("?", "?")
    db, st = d[0].groups()
    fl = [l for l in body if l.startswith("  log: Database: ")]
    want = "(H2 2.5)" if db.startswith("H2") else "(PostgreSQL 18.6)"
    ok(len(fl) == 1 and fl[0].endswith(want), "the harness's database %s = Flyway's Database line %s" % (db, fl))
    ok(any(re.match(r"^  exit 0 · its log", l) for l in body) and "PROBE <<< exit 0" in body, "the JVM exits 0 (%s, %s)" % (db, st))
    ok(any(re.match(r"^  exit 0 · its log, every line but the harness's own PROBE lines: WARN \d+ · ERROR 0 · ", l) for l in body), "no ERROR line in the JVM's log (%s, %s)" % (db, st))
    if want_db: ok(db.startswith(want_db), "the section's database is %s: %s" % (want_db, db))
    if want_store: ok(st == want_store, "the section's store is %s: %s" % (want_store, st))
    return db, st


def mgr(body, cls):
    ok(any(l.startswith("PROBE CacheManager beans 1 [cacheManager=%s] (" % cls) for l in body), "CacheManager beans 1, %s" % cls)


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
        out.append((".".join(k for _, k in stack), m.group(3).strip()))
    return out


def rd(t, p): return open(os.path.join(t, p), encoding="utf-8").read()


def adds(B, A, p):
    return [l for l in difflib.unified_diff(rd(B, p).splitlines(), rd(A, p).splitlines(), lineterm="", n=0) if l[:1] in "+-" and not l.startswith(("+++", "---"))]


def count_of(v):
    m = re.fullmatch(r"(\d+)([smhd])", v)
    return int(m.group(1)) * {"s": 1, "m": 60, "h": 3600, "d": 86400}[m.group(2)] if m else None


def pausepsql(body, k):
    m = grab(body, r"^  the receipt at pause %d, psql \(a second client, PostgreSQL\): insert Nobody -> rows named Nobody (\d+)$" % k)
    return int(m[0].group(1)) if m else None


YML = "tiffinbox-web/src/main/resources/application.yaml"
CR = "tiffinbox-core/src/main/java/com/tiffinbox/CustomerRepository.java"
SYNCA = '    @Cacheable(cacheNames = "customers", sync = true)'
UNLA = '    @Cacheable(cacheNames = "customer", unless = "#result == null")'
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
    ok(sorted(changed) == sorted(["README.md", YML, CR]), "C5: the files changed are README.md, application.yaml and CustomerRepository.java - nothing new, nothing gone, no pom.xml, no compose.yaml, RedisCaching untouched: %s" % sorted(changed))
    yd = adds(B, A, YML)
    keysA = dict(yaml_keys(os.path.join(A, YML))); keysB = dict(yaml_keys(os.path.join(B, YML)))
    ok(keysB.get("spring.cache.cache-names") == "customers" and keysA.get("spring.cache.cache-names") == "customers,customer", "spring.cache.cache-names: customers -> customers,customer (RED #3)")
    ok({k: v for k, v in keysA.items() if k != "spring.cache.cache-names"} == {k: v for k, v in keysB.items() if k != "spring.cache.cache-names"}, "every other key of application.yaml unchanged (the spec's expireAfterWrite and the time-to-live untouched)")
    ok([l for l in yd if not l[1:].lstrip().startswith("#")] == ["-    cache-names: customers", "+    cache-names: customers,customer"], "the YAML's diff: the names line, and comment lines only")
    ok(sum(1 for l in yd if l.startswith("+") and "Course 8, unit 13:" in l) == 1, "the YAML's comment carries one Course 8, unit 13: note")
    ja, jb = rd(A, CR), rd(B, CR)
    la = ja.splitlines()
    ok(not re.search(r"sync = true[^)\n]*unless|unless[^)\n]*sync = true", ja), "the failure receipt: sync and unless never on one method in the anchor (syncunless: the first call throws)")
    ok(la.count(SYNCA) == 1 and la.count(UNLA) == 1, "CustomerRepository: sync = true on findAll, unless on findByName - one each")
    ok(SYNCA in la and UNLA in la and la[la.index(SYNCA) + 1].strip().startswith("public List<Customer> findAll()") and la[la.index(UNLA) + 1].strip().startswith("public Optional<Customer> findByName(String name)"), "each annotation on its method")
    code = lambda t: [l for l in t.splitlines() if not l.strip().startswith(("*", "/**", "*/", "//"))]
    ev = [l.strip() for l in code(ja) if "@CacheEvict(" in l]
    ok(ev == ['@CacheEvict(cacheNames = "customers", allEntries = true)'], "add's evict unchanged: no evict by name (RED #8): %s" % ev)
    dc = [l for l in difflib.unified_diff(code(jb), code(ja), lineterm="", n=0) if l[:1] in "+-" and not l.startswith(("+++", "---"))]
    ok(sorted(dc) == sorted(['-    @Cacheable("customers")', "+" + SYNCA, "+" + UNLA]), "the Java diff outside the Javadoc: the two annotations and nothing else: %s" % dc)
    ok(sorted(os.listdir(os.path.join(A, "tiffinbox-core/src/main/resources/db/migration"))) == ["V1__customer_and_pause.sql", "V2__seed.sql", "V3__customer_audit_columns.sql"], "Flyway's V1-V3, no V4")
    c13 = open("harness/src/probe/u13/Counter.java", encoding="utf-8").read(); c12 = open("../c8-unit12/harness/src/probe/u12/Counter.java", encoding="utf-8").read()
    ok(c13.replace("package probe.u13;", "package probe.u12;") == c12, "Counter.java = unit 12's (unit 08's), but for its package line")
    ex = open("exercise/CustomerRepository.java", encoding="utf-8").read().splitlines()
    dx = [l for l in difflib.unified_diff(la, ex, lineterm="", n=0) if l[:1] in "+-" and not l.startswith(("+++", "---"))]
    ok(dx == ["-" + UNLA, '+    @Cacheable(cacheNames = "customer")'], "exercise/CustomerRepository.java = after/'s but for findByName's annotation (unless removed): %s" % dx)
    VALUES.append("C5 files 2 + README")
elif NAME == "r250":
    A = sys.argv[2]
    R = open(A + "/README.md", encoding="utf-8").read().splitlines()
    Y = open(os.path.join(A, YML), encoding="utf-8").read().splitlines()
    J = open(os.path.join(A, CR), encoding="utf-8").read().splitlines()
    FR = [(R, "the backstop for the writes the cache never sees; its section below.)*", "*(Course 8, unit 13, **Section 2's fifth and last change to this folder**", 0),
          (R, "`pausedDaysByCustomer` stay uncached", "*(Course 8, unit 13:", 0),
          (R, "and `add` still empties the cache; `findByName` stays uncached", "*(Course 8, unit 13:", 0),
          (R, "comparison requests, the same answers; `findByName` stays uncached", "*(Course 8, unit 13:", 0),
          (R, "unit 13's `sync` takes that on", "*(Course 8, unit 13: it has", 0),
          (R, "`findByName` stays uncached *(Course 8, unit 13: cached since, in `customer`, unless it finds no one; its section below.)*. The numbers are in `../c8-unit12`", "*(Course 8, unit 13:", 0),
          (Y, "here the one TiffinBox has, customers (CustomerRepository.findAll()'s)", "(Course 8, unit 13: two", 0),
          (J, "proxy that ran add's transaction runs the cache's advice too. findByName and pausedDaysByCustomer stay uncached", "(Course 8, unit 13: findByName is cached since", 1)]
    for T, f, note, nxt in FR:
        h = [k for k, l in enumerate(T) if f in l]
        ok(len(h) == 1, "R.250: the sentence is in its file once: " + f[:60])
        if h:
            line = T[h[0] + nxt]
            ok(note in line and (nxt == 1 or line.index(note) > line.index(f)), "R.250: its unit 13 note follows it: " + f[:60])
    plain = [l for l in R if re.search(r"`findByName` (?:stays|stay) uncached", l) and "Course 8, unit 13" not in l and "until" not in l]
    ok(not plain, "R.250: no anchor README line says findByName stays uncached without its unit 13 note: %s" % [l[:60] for l in plain])
    ok(sum(1 for l in R if l.startswith("## Course 8 · unit 13 — ")) == 1 and any("**Section 3 starts here**" in l for l in R), "the README's Course 8 · unit 13 section, and Section 3 starts here")
    u12 = open("../c8-unit12/README.md", encoding="utf-8").read()
    ok("Unit 13 moves the anchor next (`sync = true` on the cold key, `unless` on `findByName`, which stays uncached until then)." in u12, "unit 12's README stays as shipped (its Next, now done, is noted in this unit's README, not edited there)")
    VALUES.append("R.250 sentences %d (anchor README 6, application.yaml 1, CustomerRepository's Javadoc 1) + unit 12's README's Next noted here" % len(FR))
elif NAME == "ttlvalue":
    v = dict(yaml_keys(os.path.join(sys.argv[2], YML))).get("spring.cache.redis.time-to-live", "")
    n = count_of(v)
    print(n if n else ""); sys.exit(0 if n else 1)
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
    ok(W == "23", "the spoken line is 23 words (the brief's): %s" % W)
    blocks, cur, sh = {}, None, None
    for l in L:
        if l.startswith("in bash") or l.startswith("in zsh"): sh = l.split()[1]
        if "the README's lines" in l: cur = (sh, "readme"); blocks[cur] = []; continue
        if "then the solution's lines" in l: cur = (sh, "sol"); blocks[cur] = []; continue
        if l.startswith("  the shell is now in"): cur = None; continue
        if cur: blocks[cur].append(l.strip())
    ok(blocks.get(("bash", "readme")) == blocks.get(("zsh", "readme")) and blocks.get(("bash", "sol")) == blocks.get(("zsh", "sol")), "bash and zsh print the same")
    r, s = blocks.get(("bash", "readme"), []), blocks.get(("bash", "sol"), [])
    def looks(b):
        out = {}
        for l in b:
            m = re.match(r"^lookup ([12]): Nobody (found|not found) · repository calls (\d+)$", l)
            if m: out[m.group(1)] = (m.group(2), int(m.group(3)))
        return out
    def ins(b):
        m = [x for x in (re.match(r"^insert: (\d+) row · the table now holds Nobody: (\d+)$", l) for l in b) if x]
        return (int(m[0].group(1)), int(m[0].group(2))) if len(m) == 1 else None
    rr, ss = looks(r), looks(s)
    tr, ts = ins(r), ins(s)
    ok(tr == ts == (1, 1), "both states: the insert writes 1 row, and the table then holds her: %s %s" % (tr, ts))
    ok(set(rr) == {"1", "2"} and set(ss) == {"1", "2"} and rr["1"] == ss["1"] == ("not found", 1), "both states: lookup 1 finds no one and reaches the repository once: %s %s" % (rr, ss))
    if rr.get("2") and ss.get("2"):
        ok(rr["2"] == ("not found", 1), "R.196: broken - lookup 2 still finds no one, and the repository calls stay at lookup 1's (the kept empty answer): %s" % (rr,))
        ok(ss["2"] == ("found", 2), "R.196: solved - lookup 2 finds her, and the repository calls went up by one: %s" % (ss,))
    for b in (r, s): ok("TiffinBox: exit 0" in b and "Maven: exit 0" in b and "javac: exit 0" in b and "cache: CaffeineCacheManager" in b, "exits 0, Caffeine's manager - the check is the second lookup's value and the counter, never the exit")
    ok("unless on findByName: 0" in r and "unless on findByName: 1" in s, "the broken tree lacks unless on findByName, the solved one holds it")
    if rr.get("2") and ss.get("2"):
        VALUES.append("the line %s words · broken: lookup 2 %s, repository calls %d -> %d · solved: lookup 2 %s, repository calls %d -> %d · exit 0 both (H2, Caffeine, no Docker)" % (W, rr["2"][0], rr["1"][1], rr["2"][1], ss["2"][0], ss["1"][1], ss["2"][1]))
elif NAME == "anchor":
    L = lines(sys.argv[2]); TTLA = int(sys.argv[3]); S = sections(L)
    res = [tuple(int(x) for x in m.groups()) for m in (re.search(r"Tests run: (\d+), Failures: (\d+), Errors: (\d+), Skipped: (\d+)$", l) for l in L if "Results line" in l) if m]
    ok(len(res) == 3 and all(r[1:] == (0, 0, 0) for r in res) and res[0][0] == res[1][0], "the tests: package (no Docker) = verify's first execution, then verify's container tests; nothing failed or skipped: %s" % res)
    ok(sum(1 for l in L if l.startswith("  exit 0 · BUILD SUCCESS · offline: yes")) == 2, "both builds exit 0, offline")
    ok(any("surefire-reports-it: absent - no container test ran" in l for l in L), "package with DOCKER_HOST at nothing: no container test ran")
    v = grab(L, r"^  the verify log: 'Creating container for image' (\d+) · 'Pulling' (\d+) · 'RedisConnectionFailure' (\d+)$")
    ok(bool(v) and v[0].group(2) == "0" and v[0].group(3) == "0", "verify: nothing pulled, no Redis connection failure")
    lib = {t: int(m[0].group(1)) for t, m in ((t, grab(L, r"^  %s/: (\d+) libraries" % t)) for t in ("before", "after")) if m}
    gl = grab(L, r"^  gained: (\d+) · lost: (\d+)$")
    ok(bool(gl) and gl[0].groups() == ("0", "0") and lib.get("before") == lib.get("after"), "the libs count unchanged: no jar gained, none lost")
    out = {}
    for h, body in S:
        if not h.startswith(("-- before/", "-- after/")): continue
        db, st = jvm(body)
        vv = grab(body, r"^PROBE versions: Spring Boot (\S+) · Spring Framework (\S+) · Spring Data JPA (\S+) · Spring Data Redis (\S+) · Hibernate (\S+) · Flyway \(version\.txt\) (\S+)$")
        ok(bool(vv) and vv[0].groups() == ("4.1.2", "7.0.10", "4.1.2", "4.1.2", "7.4.13.Final", "12.4.0"), "the version lines (R.246) on " + db)
        ok(bool(vv) and ("  log: HHH000001: Hibernate ORM core version " + vv[0].group(5)) in body, "Hibernate's version = HHH000001's")
        names = grab(body, r"^PROBE the cache names at the start, getCacheNames\(\): \[(.*)\]$")
        gc = grab(body, r"^PROBE getCache\(\"customer\"\): (\S+)$")
        if h.startswith("-- before/"):
            ok(st == "in the JVM, Caffeine" and db.startswith("H2"), "before/: H2, Caffeine")
            mgr(body, CAF)
            ok(bool(names) and names[0].group(1) == "customers" and bool(gc) and gc[0].group(1) == "null", "before/ (unit 12's tree): one cache at the start, getCache(\"customer\") null - the RED #3 hazard, the other way round")
            out["before"] = 1
            continue
        w = window(body, "reads: five calls of CustomerRepository.findAll()")
        ok(bool(w) and w["per"] == [1, 0, 0, 0, 0], "five calls [1, 0, 0, 0, 0] (%s, %s)" % (db, st))
        hc = {m.group(1): m.group(2) for m in (re.match(r"^PROBE http \(.*\): GET (\S+) -> (\d+)", l) for l in body) if m}
        ok(bool(names) and names[0].group(1) == "customer, customers", "two caches at the start: customer, customers (%s)" % st)
        if h.startswith("-- after/ on H2"):
            ok(st == "in the JVM, Caffeine" and db.startswith("H2"), "the default run: H2, Caffeine")
            mgr(body, CAF)
            ok(bool(gc) and gc[0].group(1) == "org.springframework.cache.caffeine.CaffeineCache", "getCache(\"customer\") a CaffeineCache")
            ok(hc == {"/dashboard": "200", "/actuator/health": "200", "/actuator/health/readiness": "200"}, "R.386: the default run, no Redis: /dashboard, health and readiness 200: %s" % hc)
            pm = grab(body, r"^PROBE prometheus \(H2 2\.5\.250, in the JVM, Caffeine\): GET /actuator/prometheus -> 200 · cache_gets_total lines per cache \{customer=(\d+), customers=(\d+)\} · every cache_ line per cache \{customer=(\d+), customers=(\d+)\}$")
            ok(bool(pm) and pm[0].group(1) == pm[0].group(2) and int(pm[0].group(1)) > 0, "R.384: /actuator/prometheus holds cache_gets_total lines for both names, as many for each")
            out["default"] = (hc, pm[0].groups() if pm else None)
        else:
            ok(st == "Redis" and db.startswith("PostgreSQL"), "the dev-shaped run: PostgreSQL, Redis")
            mgr(body, RCM)
            ok(bool(gc) and gc[0].group(1) == "org.springframework.data.redis.cache.RedisCache", "getCache(\"customer\") a RedisCache")
            ok("PROBE RedisConnectionFactory: org.springframework.data.redis.connection.lettuce.LettuceConnectionFactory · the connection: 127.0.0.1:20522" in body, "LettuceConnectionFactory, 127.0.0.1:20522")
            rv = grab(body, r"^PROBE Redis's INFO server, through the connection: redis_version:(\S+)$")
            ok(writerline(body) == WRITER, "the cache writer TiffinBox gives Redis: asynchronousWrites false, a lock wait set")
            b1 = grab(body, r"^PROBE byname: findByName\(\"Ravi\"\) \(PostgreSQL 18\.6, Redis\): repository calls 1 · prepareStatementCount 1 · per call \[1\] and \[1\] · returned Optional\[Customer\[name=Ravi, ")
            ok(hc.get("/actuator/health") == "200", "the dev-shaped run: health 200")
            sc = [l for l in body if l.startswith("  redis-cli --scan: ")]
            ok(sc == ["  redis-cli --scan: customer::Ravi|customers::SimpleKey [] (2 keys)"], "redis-cli --scan: the two keys, customers::SimpleKey [] and customer::<name> (the name the key): %s" % sc)
            ty = grab(body, r"^  redis-cli TYPE: customer::Ravi (\S+) · customers::SimpleKey \[\] (\S+)$")
            ok(bool(ty) and ty[0].groups() == ("string", "string"), "TYPE string, both keys")
            for k in ("customers::SimpleKey \\[\\]", "customer::Ravi"):
                t = grab(body, r'^  redis-cli TTL "%s": TTL <n> · a positive count, at most the configured value \(the anchor.s spring\.cache\.redis\.time-to-live, read off after/.s YAML\): (yes|no)$' % k)
                ok(bool(t) and t[0].group(1) == "yes", "R.380: unit 12's time to live bounds %s too: TTL a positive count, at most the YAML's value (%d, masked)" % (k, TTLA))
            out["dev"] = (rv[0].group(1) if rv else "?",)
    hz = [b for h, b in S if h.startswith("-- the RED #3 hazard")]
    if hz:
        jvm(hz[0], "H2", "in the JVM, Caffeine")
        ok(any(l == "PROBE the cache names at the start, getCacheNames(): [customers]" for l in hz[0]), "the hazard: one cache made at the start")
        hf = grab(hz[0], r"^PROBE first: (java\.lang\.IllegalArgumentException: Cannot find cache named 'customer') for ")
        hw = window(hz[0], "first: findByName(\"Ravi\"), the first cached call")
        ok(bool(hf) and bool(hw) and hw["per"] == [0], "RED #3: a cache the start did not make - the first findByName throws, invocations 0")
        out["hazard"] = hf[0].group(1) if hf else "?"
    ok(set(out) == {"before", "default", "dev", "hazard"}, "the four runs: before/, the default, the hazard, the dev-shaped")
    if set(out) == {"before", "default", "dev", "hazard"} and len(res) == 3 and out["default"][1]:
        hc, pm = out["default"]
        VALUES.append("before/ (unit 12): caches at the start [customers], getCache(\"customer\") null · after/ default run (H2, no Redis): %s, caches at the start [customer, customers], findAll [1, 0, 0, 0, 0] by both witnesses (unchanged), /actuator/prometheus cache_gets_total lines customer %s · customers %s, /dashboard %s, health %s, readiness %s · --spring.cache.cache-names=customers on after/: the first findByName throws %s, invocations 0 · dev-shaped (PostgreSQL + Redis by the digest): %s, redis_version:%s, the writer asynchronousWrites false with a lock, keys customer::Ravi and customers::SimpleKey [] (TYPE string, TTL a positive count at most the anchor's, masked) · tests %d (mvn -o package, no Docker) and %d + %d (mvn -o verify) · libs %d -> %d (none gained) · Boot 4.1.2 · Framework 7.0.10 · Spring Data JPA/Redis 4.1.2 · HHH000001 7.4.13.Final · Flyway 12.4.0"
                      % (CAF, pm[0], pm[1], hc["/dashboard"], hc["/actuator/health"], hc["/actuator/health/readiness"], out["hazard"], RCM, out["dev"][0], res[0][0], res[1][0], res[2][0], lib["before"], lib["after"]))
elif NAME == "sync":
    L = lines(sys.argv[2]); S = sections(L)
    ok(L[0] == "-- the stampede's class, harness/src/probe/u13/Stampede.java: lines naming sleep 0 · the read each thread makes: the anchor's own CustomerRepository.findAll() (the context's bean)", "READ FIRST 14: no sleep in the stampede's class")
    got = {}
    for h, body in S[1:]:
        db, st = jvm(body, "PostgreSQL")
        sync = "sync = true" in h
        mode, counts = ("sync", (2, 4, 8, 16, 32)) if sync else ("plain", (2, 4))
        res = {}
        for n in counts:
            want = 1 if sync else n
            rx = r"^PROBE %s %d threads \(PostgreSQL 18\.6, %s\), 20 rounds, the key cold in each: every round's repository calls = its statements: (yes|NO) · %d in every round: (yes|no)%s · every thread received the list, its size\(\) per round as a set: (.*) · calls that threw (\d+)$" % (mode, n, re.escape(st), want, "" if sync else r" · more than one in every round: (?:yes|no)")
            m = grab(body, rx)
            if not m: continue
            eq, alln, sz, threw = m[0].groups()
            ok(eq == "yes" and threw == "0", "R.375: %s %d threads (%s): per round, repository calls = statements; no call threw" % (mode, n, st))
            ok(sz == "{4} in every round", "every thread of every round received the list, its size 4 (the seed's rows): %s" % sz)
            pr = [l for l in body if l.startswith("PROBE %s %d threads: per round " % (mode, n))]
            ok((alln == "yes") == (len(pr) == 1) and (alln != "yes" or pr[0].endswith(str([want] * 20))), "%s %d threads (%s): the per-round list printed exactly when every round printed %d" % (mode, n, st, want))
            ok(alln == "yes", "%s %d threads (%s): %d in every round of this JVM (R.381: the voiced claim needs every round)" % (mode, n, st, want))
            res[n] = alln
        if st == "Redis": ok(writerline(body) == WRITER, "the anchor's writer")
        got[(mode, st)] = res
    ok(sorted(got) == sorted([("sync", "in the JVM, Caffeine"), ("sync", "Redis"), ("plain", "in the JVM, Caffeine")]), "three JVMs: after/ on Caffeine, after/ on Redis (the anchor's writer), before/ on Caffeine: %s" % sorted(got))
    if len(got) == 3 and all(all(v == "yes" for v in r.values()) for r in got.values()):
        VALUES.append("PostgreSQL, 20 rounds per count per JVM, the capture 3/3: after/ (sync = true) in the JVM, Caffeine: 1 in every round at 2, 4, 8, 16 and 32 threads, every thread its 4 rows · after/ Redis (the anchor's writer): 1 in every round at 2, 4, 8, 16 and 32 threads, every thread its 4 rows · before/ (unit 12, no sync) in the JVM, Caffeine: 2 -> 2 and 4 -> 4 in every round · in one JVM · H2 never run")
elif NAME == "nulls":
    L = lines(sys.argv[2]); S = sections(L); got = []
    ok(L[1:3] == ["  --- after/tiffinbox-core/src/main/java/com/tiffinbox/CustomerRepository.java", "  +++ nounless/tiffinbox-core/src/main/java/com/tiffinbox/CustomerRepository.java"] and L[3:5] == ["  -" + UNLA, '  +    @Cacheable(cacheNames = "customer")'], "the labelled copy's one change printed: unless removed from findByName")
    for h, body in S[1:]:
        db, st = jvm(body, "PostgreSQL")
        ok("nounless/" in h, "the section runs the labelled copy (nounless)")
        f3 = grab(body, r"^PROBE nulls: the first three lookups returned \[(.*)\] · per call " + LIST + "$")
        sf = grab(body, r"^PROBE nulls: the stored form, in the cache customer: (.*)$")
        r1 = grab(body, r"^PROBE nulls: TiffinBoxServer's route, before the insert: GET /customers/Nobody -> (\d+) · repository calls (\d+) · prepareStatementCount (\d+)$")
        ps = pausepsql(body, 1)
        a4 = grab(body, r"^PROBE nulls: after psql's insert, the lookup returned (.*) · repository calls (\d+) · prepareStatementCount (\d+)$")
        r2 = grab(body, r"^PROBE nulls: TiffinBoxServer's route, after the insert: GET /customers/Nobody -> (\d+) · repository calls (\d+) · prepareStatementCount (\d+)$")
        a5 = grab(body, r"^PROBE nulls: after evict\(\"Nobody\"\), the lookup returned (.*) · repository calls (\d+) · prepareStatementCount (\d+)$")
        w = window(body, "nulls: findByName(\"Nobody\") x3, psql inserts her, the lookup, evict(\"Nobody\"), the lookup")
        if not (f3 and sf and r1 and a4 and r2 and a5 and w and ps is not None): continue
        ok(f3[0].group(1) == ", ".join([EMPTY] * 3) and lst(f3[0].group(2)) == [1, 0, 0], "three lookups of a name nobody has: Optional.empty each, invocations 1 (%s)" % st)
        ok(ps == 1, "psql (a second client) inserts Nobody: the table then holds her: %s" % ps)
        ok(a4[0].groups() == (EMPTY, "0", "0"), "the invisible row: after the insert the lookup still returns Optional.empty, repository calls 0, statements 0 (%s)" % st)
        ok(r1[0].groups() == ("404", "0", "0") and r2[0].groups() == ("404", "0", "0"), "GET /customers/Nobody: 404 before the insert and still 404 after it, from the cache (%s)" % st)
        ok(a5[0].groups() == (NOBODY, "1", "1"), "evict(\"Nobody\") - the next lookup reaches the table and finds her (%s)" % st)
        ok(w["per"] == [1, 0, 0, 0, 1] and w["rest"] == " · invocations 1 -> 1 (the insert) -> 2 (the evict)", "invocations 1 -> 1 (the insert) -> 2 (the evict): %s" % w["rest"])
        if st == "Redis":
            ok(writerline(body) == WRITER, "Redis through the anchor's writer")
            gk = grab(body, r'^  the receipt at pause 1, redis-cli: --scan (.*) \((\d+) keys\) · TYPE "customer::Nobody" (\S+) · GET "customer::Nobody" (.*)$')
            ok(bool(gk) and gk[0].group(1) == "customer::Nobody" and gk[0].group(3) == "string" and "org.springframework.cache.support.NullValue" in gk[0].group(4), "redis-cli (a second client): the key customer::Nobody, its bytes NullValue's")
            stored = gk[0].group(4) if gk else "?"
        else:
            mgr(body, CAF)
            ok(sf[0].group(1) == 'getNativeCache().getIfPresent("Nobody") org.springframework.cache.support.NullValue', "Caffeine's native entry: Spring's NullValue holder")
            stored = "getIfPresent(\"Nobody\") org.springframework.cache.support.NullValue"
        got.append((st, stored))
    ok([g[0] for g in got] == ["in the JVM, Caffeine", "Redis"], "both stores: Caffeine, then Redis: %s" % [g[0] for g in got])
    if len(got) == 2:
        VALUES.append("the labelled copy nounless (unless removed), PostgreSQL: " + " · ".join("%s: findByName(\"Nobody\") x3 -> Optional.empty, invocations 1, stored %s · psql inserts her -> still Optional.empty, invocations 1, GET /customers/Nobody 404 then 404 · evict(\"Nobody\") -> found, invocations 2" % g for g in got))
elif NAME == "unless":
    L = lines(sys.argv[2]); S = sections(L); got = []
    for h, body in S:
        db, st = jvm(body, "PostgreSQL")
        a = window(body, "unless: findByName(\"Nobody\") x3")
        b = window(body, "unless: findByName(\"Ravi\") x3")
        c = window(body, "unless: on a cold cache, findByName(\"Nobody\"), psql inserts her, findByName(\"Nobody\")")
        sa = grab(body, r"^PROBE unless: after Nobody x3, in the cache customer: (.*)$")
        sb = grab(body, r"^PROBE unless: after Ravi x3, in the cache customer: (.*)$")
        l1 = grab(body, r"^PROBE unless: the lookup before the insert returned (.*)$")
        l2 = grab(body, r"^PROBE unless: the lookup after psql's insert returned (.*)$")
        ps = pausepsql(body, 2)
        if not (a and b and c and sa and sb and l1 and l2 and ps is not None): continue
        ok(a["per"] == [1, 1, 1] and a["rest"] == " · returned [Optional.empty]", "Nobody x3: invocations 3, Optional.empty each - nothing kept (%s)" % st)
        ok(b["per"] == [1, 0, 0] and b["rest"].startswith(" · returned [Optional[Customer[name=Ravi, "), "Ravi x3: invocations 1, found - kept (%s)" % st)
        ok(ps == 1 and l1[0].group(1) == EMPTY and l2[0].group(1) == NOBODY and c["per"] == [1, 1] and c["rest"] == " · invocations 1 -> 2", "RE-MEASURE 11: on a cold cache, empty; psql inserts her; the next lookup finds her, invocations 1 -> 2 (%s)" % st)
        if st == "Redis":
            ok(writerline(body) == WRITER, "Redis through the anchor's writer")
            s1 = grab(body, r"^  the receipt at pause 1, redis-cli: --scan (.*) \((\d+) keys\)$")
            ok(bool(s1) and s1[0].groups() == ("customer::Ravi", "1"), "redis-cli at pause 1: customer::Ravi alone - no customer::Nobody")
            s2 = grab(body, r"^  redis-cli --scan: (.*) \((\d+) keys\)$")
            ok(bool(s2) and s2[0].groups() == ("customer::Nobody", "1"), "redis-cli after the JVM: customer::Nobody - kept once she was found")
        else:
            mgr(body, CAF)
            ok(sa[0].group(1) == 'getNativeCache().getIfPresent("Nobody") null' and sb[0].group(1) == 'getNativeCache().getIfPresent("Ravi") com.tiffinbox.Customer', "Caffeine: nothing kept for Nobody, a Customer kept for Ravi")
        got.append((st, a["calls"], b["calls"], c["calls"]))
    ok([g[0] for g in got] == ["in the JVM, Caffeine", "Redis"], "both stores: %s" % [g[0] for g in got])
    if len(got) == 2:
        VALUES.append("the anchor's unless, PostgreSQL: " + " · ".join("%s: Nobody x3 -> invocations %d, nothing stored · Ravi x3 -> invocations %d, stored · insert-then-find -> found, invocations %d" % g for g in got) + " · #result the unwrapped value (the Optional never stored, the empty one never kept)")
elif NAME == "cond":
    L = lines(sys.argv[2]); S = sections(L); got = []
    for h, body in S:
        db, st = jvm(body, "PostgreSQL")
        ok(any(l == "PROBE cond: a harness bean, not the anchor's cache - HarnessCond.Lookups, its cache h13cond (condition = \"#name.length() > 3\"); the cache names at the start [customer, customers, h13cond]" for l in body), "R.384: the harness's cache named at the start beside the anchor's two, labelled the harness's")
        sm = grab(body, r"^PROBE cond: Sam in the seed: (true|false)")
        w = window(body, "cond: HarnessCond byName(\"Sam\") x3, then byName(\"Ravi\") x3")
        if not w: continue
        ok(w["per"] == [1, 1, 1, 1, 0, 0] and w["calls"] == 4, "condition: Sam (3 letters) uncached x3, Ravi cached after 1 - invocations 4 (%s): %s" % (st, w["per"]))
        ok(w["rest"] == " · returned [Optional[Sam 1 meals], Optional[Sam 1 meals], Optional[Sam 1 meals], Optional[Ravi 2 meals], Optional[Ravi 2 meals], Optional[Ravi 2 meals]]", "every call found its customer")
        if st == "Redis":
            sc = grab(body, r"^  redis-cli --scan: (.*) \((\d+) keys\)$")
            ok(bool(sc) and sc[0].groups() == ("h13cond::Ravi", "1"), "redis-cli: h13cond::Ravi alone (no h13cond::Sam)")
        got.append((st, w["per"], w["calls"], sm[0].group(1) if sm else "?"))
    ok([g[0] for g in got] == ["in the JVM, Caffeine", "Redis"], "both stores")
    if len(got) == 2:
        VALUES.append("the harness's h13cond (not the anchor's), condition = \"#name.length() > 3\", PostgreSQL, Sam not in the seed (added through add): " + " · ".join("%s: per call %s, invocations %d" % g[:3] for g in got))
elif NAME == "nonull":
    L = lines(sys.argv[2]); S = sections(L); got = []
    for h, body in S:
        db, st = jvm(body, "PostgreSQL", "Redis")
        ok("nounless/" in h and "cache-null-values=false" in h, "the labelled copy nounless + --spring.cache.redis.cache-null-values=false")
        ok(any(l.startswith("PROBE the environment:") and l.endswith("spring.cache.redis.cache-null-values false") for l in body), "the flag reached the environment")
        msgs = [m.group(1) for m in (re.match(r"^PROBE nonull: call [123]: (.*)$", l) for l in body) if m]
        ok(len(msgs) == 3 and len(set(msgs)) == 1 and msgs[0].startswith("java.lang.IllegalArgumentException: Cache 'customer' does not allow 'null' values"), "R.383: IllegalArgumentException on every call, the same message: %s" % msgs[:1])
        w = window(body, "nonull: findByName(\"Nobody\") x3, spring.cache.redis.cache-null-values=false")
        ok(bool(w) and w["per"] == [1, 1, 1], "invocations 3 - each call ran the method, then threw at the store")
        sc = grab(body, r"^  redis-cli --scan: (.*)\((\d+) keys\)$")
        ok(bool(sc) and sc[0].group(2) == "0", "nothing stored: redis-cli --scan 0 keys")
        ok(writerline(body) == WRITER, "Redis through the anchor's writer")
        got.append(msgs[0] if msgs else "?")
    ok(len(got) == 1, "one JVM")
    if got:
        VALUES.append("the labelled copy nounless + cache-null-values=false, PostgreSQL + Redis: findByName(\"Nobody\") x3 -> %s, three times, invocations 3, nothing stored - the context started" % got[0].split(";")[0])
elif NAME == "syncunless":
    L = lines(sys.argv[2]); S = sections(L)
    ok(L[1:3] == ["  --- after/tiffinbox-core/src/main/java/com/tiffinbox/CustomerRepository.java", "  +++ syncunless/tiffinbox-core/src/main/java/com/tiffinbox/CustomerRepository.java"] and L[3:5] == ["  -" + UNLA, '  +    @Cacheable(cacheNames = "customer", sync = true, unless = "#result == null")'], "the labelled copy's one change printed: sync = true beside unless")
    body = S[1][1] if len(S) > 1 else []
    db, st = jvm(body, "H2", "in the JVM, Caffeine")
    hc = {m.group(1): m.group(2) for m in (re.match(r"^PROBE http \(.*\): GET (\S+) -> (\d+)", l) for l in body) if m}
    ok(hc.get("/actuator/health") == "200" and hc.get("/actuator/health/readiness") == "200", "the context starts green: health 200, readiness 200")
    f = grab(body, r"^PROBE first: (java\.lang\.IllegalStateException: A sync=true operation does not support the unless attribute) on ")
    w = window(body, "first: findByName(\"Ravi\"), the first cached call")
    ok(bool(w) and w["per"] == [0], "the first call throws before the method runs: invocations 0")
    if f and w: VALUES.append("the labelled copy syncunless (sync = true and unless on findByName), H2, no Docker: the start green (health 200), the first call %s, invocations 0" % f[0].group(1))
elif NAME == "seven":
    L = lines(sys.argv[2]); S466 = sys.argv[3]
    h = [m.group(1) for m in (re.search(r"the seven responses: 7 lines · md5 ([0-9a-f]{32})", l) for l in L) if m]
    ok(len(h) == 2 and h[0] == h[1] == S466, "the seven on before/ and after/ = Course 7's published md5")
    ok(sum(1 for l in L if l == "  GET /dashboard: 200") == 2, "GET /dashboard 200 on both")
    ok("  exit 0 · cmp with xcheck.sql (= Course 7's capstone's): the same, byte for byte" in L, "Hibernate's schema script = xcheck.sql")
    ok("  the seven, after/ against before/: lines that differ: 0" in L, "0 lines differ")
    ok(sum(1 for l in L if l.startswith("  GET /actuator/health/readiness -> 200 · GET /actuator/health -> 200 ")) == 2, "the jar's default run: health 200, before and after")
    VALUES.append("the seven %s… on before/ and after/ (0 lines differ) · GET /dashboard 200 · health 200 · Hibernate's script = xcheck.sql" % S466[:8])
else:
    print("FAIL no check named " + NAME); sys.exit(1)
for o in oks: print("ok " + o)
for f in fails: print("FAIL " + f)
print("VALUES " + "; ".join(VALUES))
sys.exit(1 if fails else 0)
