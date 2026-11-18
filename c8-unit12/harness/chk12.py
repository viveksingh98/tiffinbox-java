"""Unit 12's checks (python3 -I -B harness/chk12.py NAME ARGS...). Each capture's numbers are asserted against a second witness of the
same run - never a typed figure: the invocation counter against Hibernate's statement counter per call (R.375), the value a JVM read
against psql's row (R.359), the key a JVM saw against redis-cli's --scan and EXISTS, the TTL redis-cli read against the value in the
anchor's YAML (R.380), the database the harness named against Flyway's Database line, the CacheManager bean against the cache's own
class, Surefire's XML against Maven's Results lines, the seven's md5 against Course 7's published one, Course 7's sentence against its
md5. Prints ok/FAIL lines and one VALUES line; exits 1 on any FAIL.
  static AFTER BEFORE   the change itself, read off the files (C4: application.yaml and the README, nothing new, nothing gone)
  r250 AFTER BEFORE     the anchor README's and YAML's sentences C4 made dated: each carries its unit 12 note (R.250)
  ttlvalue TREE         TREE's spring.cache.redis.time-to-live, as the count redis-cli's TTL reads (for the receipt's comparison only)
  wib CAPTURE FILE      the lines the exercise's block printed for FILE (bash's), for receipts.sh to compare with "What it prints"
  rawsum RAW            the stampede's U12-RAW lines above 8 threads, per JVM: the least and the most per count (the run log only)
  exercise|anchor|stale|evict|put|ttl|stampede|pinned|seven CAPTURE [...]"""
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
CMM = "org.springframework.cache.concurrent.ConcurrentMapCacheManager"
KEY = "customers::SimpleKey []"


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


YML = "tiffinbox-web/src/main/resources/application.yaml"
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
    ok(sorted(changed) == sorted(["README.md", YML]), "C4: the files changed are README.md and application.yaml - nothing new, nothing gone, no pom.xml, no Java file: %s" % sorted(changed))
    yd = adds(B, A, YML)
    keysA = dict(yaml_keys(os.path.join(A, YML))); keysB = dict(yaml_keys(os.path.join(B, YML)))
    spec = keysA.get("spring.cache.caffeine.spec", ""); ttl = keysA.get("spring.cache.redis.time-to-live", "")
    m = re.fullmatch(r"maximumSize=100,recordStats,expireAfterWrite=(\d+[smhd])", spec)
    ok(keysB.get("spring.cache.caffeine.spec") == "maximumSize=100,recordStats" and bool(m), "Caffeine's spec: unit 10's maximumSize=100,recordStats, then expireAfterWrite=<n> appended")
    ok(bool(m) and ttl == m.group(1), "spring.cache.redis.time-to-live = the spec's expireAfterWrite value - one backstop, the same for both stores")
    ok(bool(m) and m.group(1).endswith("m"), "the backstop is a count of the YAML's m unit, not s (the brief: not seconds)")
    newkeys = sorted(set(keysA) - set(keysB))
    ok(newkeys == ["spring.cache.redis", "spring.cache.redis.time-to-live"], "the new keys: spring.cache.redis.time-to-live alone (and its parent): %s" % newkeys)
    ok({k: v for k, v in keysA.items() if k != "spring.cache.caffeine.spec" and k not in newkeys} == {k: v for k, v in keysB.items() if k != "spring.cache.caffeine.spec"}, "every other key of application.yaml unchanged")
    ya = rd(A, YML); top = ya.split("\n---\n")[0]
    ok("    caffeine:\n      spec: maximumSize=100,recordStats,expireAfterWrite=" in top and "    redis:\n      time-to-live: " in top, "both above the ---, under the existing spring.cache:")
    ok(sum(1 for l in yd if l.startswith("+") and "Course 8, unit 12:" in l) == 2 and sum(1 for l in yd if l.startswith("-")) == 2, "two Course 8, unit 12: lines added in application.yaml's comments (the note and the new paragraph); two lines replaced (the spec, the comment line its note sits on)")
    cm = "\n".join(l for l in ya.split("\n") if l.strip().startswith("#"))
    ok("JdbcTemplate" in cm and "psql" in cm and "another process" in cm and "add still evicts" in cm and "the spec is fixed when the jar is built" in cm, "the comment: the writes the cache never sees (a JdbcTemplate, psql, another process), add still evicts, the AOT phrasing")
    ok("ddl-auto: validate" in ya and "include: health,prometheus" in ya and "type: caffeine" in top and "      enabled: false" in top, "ddl-auto validate, the exposure, the cache type and Redis's health indicator untouched")
    ok(sorted(os.listdir(os.path.join(A, "tiffinbox-core/src/main/resources/db/migration"))) == ["V1__customer_and_pause.sql", "V2__seed.sql", "V3__customer_audit_columns.sql"], "Flyway's V1-V3, no V4")
    c12 = open("harness/src/probe/u12/Counter.java", encoding="utf-8").read(); c11 = open("../c8-unit11/harness/src/probe/u11/Counter.java", encoding="utf-8").read()
    ok(c12.replace("package probe.u12;", "package probe.u11;") == c11, "Counter.java = unit 11's (unit 08's), but for its package line")
    VALUES.append("C4 files 1 + README")
elif NAME == "r250":
    A = sys.argv[2]
    R = open(A + "/README.md", encoding="utf-8").read().splitlines()
    Y = open(os.path.join(A, YML), encoding="utf-8").read().splitlines()
    FR = [(R, "a call it does not hold (a miss) runs the method and keeps the", "answer *(Course 8, unit 12:", 1),
          (R, "**`spring.cache.caffeine.spec: maximumSize=100,recordStats`**", "*(Course 8, unit 12:", 0),
          (R, "the default run keeps Caffeine, in the JVM, and needs no Redis; its section below.)*", "*(Course 8, unit 12, **Section 2's fourth change to this folder**", 0),
          (Y, "recordStats, which turns on Caffeine's counts (hits, misses, evictions).", "(Course 8, unit 12: and", 0)]
    for T, f, note, nxt in FR:
        h = [k for k, l in enumerate(T) if f in l]
        ok(len(h) == 1, "R.250: the sentence is in its file once: " + f[:60])
        if h:
            line = T[h[0] + nxt]
            ok(note in line and (nxt == 1 or line.index(note) > line.index(f)), "R.250: its unit 12 note follows it: " + f[:60])
    ok(sum(1 for l in R if l.startswith("## Course 8 · unit 12 — ")) == 1, "the README's Course 8 · unit 12 section")
    u11 = open("../c8-unit11/README.md", encoding="utf-8").read()
    ok("Unit 12 moves the anchor next (the time-to-live backstop)" in u11 and "(unit 12 sets the backstop)" in u11, "unit 11's README stays as shipped (its two forward lines - now done - are noted in this unit's README, not edited there)")
    VALUES.append("R.250 sentences %d (anchor README 3, application.yaml 1) + unit 11's README's 2 forward lines noted here" % len(FR))
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
elif NAME == "rawsum":
    for l in lines(sys.argv[2]):
        m = re.match(r"^U12-RAW stampede (\d+) threads \((.*)\): repository calls per round " + LIST + " . statements per round " + LIST + "$", l)
        if m and int(m.group(1)) > 4:
            a = lst(m.group(3))
            print("%s threads (%s): least %d, most %d, rounds with all %s: %d of %d" % (m.group(1), m.group(2), min(a), max(a), m.group(1), sum(1 for x in a if x == int(m.group(1))), len(a)))
    sys.exit(0)
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
    def reads(b):
        out = {}
        for l in b:
            m = re.match(r"^read ([12]): Ravi's meals (\d+) · repository calls (\d+)$", l)
            if m: out[m.group(1)] = (int(m.group(2)), int(m.group(3)))
        return out
    def table(b):
        m = [re.match(r"^update: (\d+) row · the table now says (\d+)$", l) for l in b]
        m = [x for x in m if x]
        return (int(m[0].group(1)), int(m[0].group(2))) if len(m) == 1 else None
    rr, ss = reads(r), reads(s)
    tr, ts = table(r), table(s)
    ok(bool(tr) and bool(ts) and tr == ts and tr[0] == 1, "both states: the update changes 1 row, and the table then says the same number: %s %s" % (tr, ts))
    ok(set(rr) == {"1", "2"} and set(ss) == {"1", "2"} and rr["1"] == ss["1"] and rr["1"][1] == 1, "both states: read 1 reaches the repository once: %s %s" % (rr, ss))
    if tr and rr.get("2") and ss.get("2"):
        ok(rr["2"][0] == rr["1"][0] and rr["2"][0] != tr[1] and rr["2"][1] == rr["1"][1], "R.196: broken - read 2 shows the old number (read 1's), not the table's, and the repository calls stay at read 1's: %s" % (rr,))
        ok(ss["2"][0] == tr[1] and ss["2"][1] == ss["1"][1] + 1, "R.196: solved - read 2 shows the table's number, and the repository calls went up by one: %s" % (ss,))
    for b in (r, s): ok("TiffinBox: exit 0" in b and "Maven: exit 0" in b and "javac: exit 0" in b and "cache: CaffeineCacheManager" in b, "exits 0, Caffeine's manager - the check is the second read's value and the counter, never the exit")
    ok("clear() on the write path in Meals.java: 0" in r and "clear() on the write path in Meals.java: 1" in s, "the broken program lacks the clear() line, the solved one holds it")
    if tr and rr.get("2") and ss.get("2"):
        VALUES.append("the line %s words · broken: read 2 says %d (the table %d), repository calls %d -> %d · solved: read 2 says %d, repository calls %d -> %d · exit 0 both (H2, Caffeine, no Docker)" % (W, rr["2"][0], tr[1], rr["1"][1], rr["2"][1], ss["2"][0], ss["1"][1], ss["2"][1]))
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
        w = window(body, "reads: five calls of CustomerRepository.findAll()")
        ok(bool(w) and w["per"] == [1, 0, 0, 0, 0], "five calls [1, 0, 0, 0, 0] (%s, %s)" % (db, st))
        hc = {m.group(1): m.group(2) for m in (re.match(r"^PROBE http \(.*\): GET (\S+) -> (\d+)", l) for l in body) if m}
        if h.startswith("-- before/"):
            ok(st == "in the JVM, Caffeine" and db.startswith("H2"), "before/: H2, Caffeine")
            mgr(body, CAF)
            ok("PROBE Caffeine's policy, read back through Cache.getNativeCache().policy(): expireAfterWrite() Optional.empty (absent) · eviction().getMaximum() 100 · isRecordingStats() true" in body, "before/ (unit 11's tree): expireAfterWrite absent, the ceiling 100, recordStats on")
            ok(any(l.startswith("PROBE the environment:") and "spring.cache.caffeine.spec maximumSize=100,recordStats ·" in l and l.endswith("time-to-live unset") for l in body), "before/'s settings: unit 10's spec, no time to live")
            out["before"] = 1
        elif h.startswith("-- after/ on H2"):
            ok(st == "in the JVM, Caffeine" and db.startswith("H2"), "the default run: H2, Caffeine")
            mgr(body, CAF)
            ok("PROBE Caffeine's policy, read back through Cache.getNativeCache().policy(): expireAfterWrite() Optional[…] (present) · its value = the spec's expireAfterWrite=<n>: yes · eviction().getMaximum() 100 · isRecordingStats() true" in body, "after/: expireAfterWrite present, its value = the spec's, the ceiling 100, recordStats on")
            ok(any(l.startswith("PROBE the environment: spring.cache.type caffeine · spring.cache.cache-names customers · spring.cache.caffeine.spec maximumSize=100,recordStats,expireAfterWrite=<n> · spring.cache.redis.time-to-live set") for l in body), "after/'s settings: the spec with expireAfterWrite (masked), the time to live set")
            cc = grab(body, r"^PROBE reads: Caffeine's counts \(a third witness\): hitCount (\d+) · missCount (\d+) · estimatedSize (\d+)$")
            ok(bool(cc) and bool(w) and int(cc[0].group(2)) == sum(w["per"]) and int(cc[0].group(1)) == len(w["per"]) - sum(w["per"]) and cc[0].group(3) == "1", "Caffeine's counts = the two witnesses' (misses = the calls that reached the repository, hits = the rest, one entry)")
            ok(hc == {"/dashboard": "200", "/actuator/health": "200", "/actuator/health/readiness": "200"}, "R.386: the default run, no Redis: /dashboard, health and readiness 200: %s" % hc)
            out["default"] = (cc[0].groups() if cc else None, hc)
        else:
            ok(st == "Redis" and db.startswith("PostgreSQL"), "the dev-shaped run: PostgreSQL, Redis")
            mgr(body, RCM)
            ok("PROBE RedisConnectionFactory: org.springframework.data.redis.connection.lettuce.LettuceConnectionFactory · the connection: 127.0.0.1:20512" in body, "LettuceConnectionFactory, 127.0.0.1:20512")
            rv = grab(body, r"^PROBE Redis's INFO server, through the connection: redis_version:(\S+)$")
            wl = writerline(body)
            ok(wl == ("org.springframework.data.redis.cache.DefaultRedisCacheWriter", "false", "yes"), "the cache writer TiffinBox gives Redis: asynchronousWrites false, a lock wait set")
            ok(hc.get("/actuator/health") == "200", "the dev-shaped run: health 200")
            ok([l for l in body if l.startswith("  redis-cli --scan: ")] == ["  redis-cli --scan: customers::SimpleKey [] (1 keys)"], "R.392: the one key Redis holds - customers::SimpleKey []")
            t = grab(body, r'^  redis-cli TTL "customers::SimpleKey \[\]": TTL <n> · a positive count, at most the configured value \(the anchor.s spring\.cache\.redis\.time-to-live, read off after/.s YAML\): (yes|no)$')
            ok(bool(t) and t[0].group(1) == "yes", "R.380: the anchor's time to live reaches Redis: TTL a positive count, at most the YAML's value (%d, masked)" % TTLA)
            out["dev"] = (rv[0].group(1) if rv else "?",)
    ok(set(out) == {"before", "default", "dev"}, "the three runs: before/, the default, the dev-shaped")
    if set(out) == {"before", "default", "dev"} and len(res) == 3 and out["default"][0]:
        VALUES.append("before/ (unit 11): expireAfterWrite Optional.empty · after/ default run (H2, no Redis): %s, expireAfterWrite Optional[…] = the spec's, maximum 100, recordStats true, [1, 0, 0, 0, 0] by both witnesses, Caffeine hitCount %s missCount %s estimatedSize %s, /dashboard %s, health %s, readiness %s · dev-shaped (PostgreSQL + Redis by the digest): %s, redis_version:%s, the writer asynchronousWrites false with a lock, key customers::SimpleKey [], redis-cli TTL a positive count at most the anchor's (masked) · tests %d (mvn -o package, no Docker) and %d + %d (mvn -o verify) · libs %d -> %d (none gained) · Boot 4.1.2 · Framework 7.0.10 · Spring Data JPA/Redis 4.1.2 · HHH000001 7.4.13.Final · Flyway 12.4.0"
                      % (CAF, out["default"][0][0], out["default"][0][1], out["default"][0][2], out["default"][1]["/dashboard"], out["default"][1]["/actuator/health"], out["default"][1]["/actuator/health/readiness"], RCM, out["dev"][0], res[0][0], res[1][0], res[2][0], lib["before"], lib["after"]))
elif NAME == "stale":
    L = lines(sys.argv[2]); S = sections(L)
    got = []
    for h, body in S:
        db, st = jvm(body, "PostgreSQL")
        r1 = grab(body, r"^PROBE stale: read 1 - Ravi's meals (\d+)$")
        up = grab(body, r"^PROBE stale: JdbcTemplate\.update\(\"update customer set meals_per_day = (\d+) where name = 'Ravi'\"\) -> (\d+) row$")
        ps = grab(body, r"^  the receipt at pause 1, psql \(a second client, PostgreSQL\): Ravi's row says (\d+)$")
        r2 = grab(body, r"^PROBE stale: read 2 \(the cached read\) - Ravi's meals (\d+) · repository calls (\d+) · prepareStatementCount (\d+) · (returned|threw .*)$")
        w = window(body, "stale: the read, the write around the cache, the read again")
        c = window(body, "stale control: the cache emptied, a read, add(Oscar) through the cache, a read")
        if not (r1 and up and ps and r2 and w and c): continue
        new, rows, row = int(up[0].group(1)), int(up[0].group(2)), int(ps[0].group(1))
        ok(rows == 1 and row == new, "the update changed 1 row, and psql (a second client) reads the row the update wrote: %d" % row)
        ok(int(r2[0].group(1)) == int(r1[0].group(1)) != row, "the cached read says read 1's number, not the row's: %s vs psql %d (%s)" % (r2[0].group(1), row, st))
        ok(r2[0].group(2) == "0" and r2[0].group(3) == "0" and r2[0].group(4) == "returned" and w["per"] == [1, 0], "S8.29: the cached read reached nothing - repository calls 0, statements 0, returned (no exception)")
        ok(any(re.match(r"^  exit 0 · its log, every line but the harness's own PROBE lines: WARN \d+ · ERROR 0 · exception class names 0$", l) for l in body), "S8.29: no exception, no ERROR line, exit 0")
        ok(w["rest"] == " · the cached read says %s, the row now %d (JdbcTemplate)" % (r1[0].group(1), row), "the window's line: the cached read's number beside the row JdbcTemplate reads")
        cm = re.match(r"^ · rows (\d+) -> (\d+) · Oscar in the second read: (true|false) · Ravi's meals (\d+)$", c["rest"])
        ok(bool(cm) and c["per"] == [1, 1] and int(cm.group(2)) == int(cm.group(1)) + 1 and cm.group(3) == "true" and int(cm.group(4)) == row, "the control: the write through add - the next read reaches the repository (invocations 2), the new row in it, Ravi's row read fresh")
        if st == "Redis":
            wl = writerline(body); ok(wl == ("org.springframework.data.redis.cache.DefaultRedisCacheWriter", "false", "yes"), "Redis through the anchor's writer")
        else: mgr(body, CAF)
        got.append((st, int(r1[0].group(1)), row, c["calls"], int(cm.group(1)) if cm else 0, int(cm.group(2)) if cm else 0))
    ok([g[0] for g in got] == ["in the JVM, Caffeine", "Redis"], "both stores: Caffeine, then Redis: %s" % [g[0] for g in got])
    if len(got) == 2:
        VALUES.append(" · ".join("%s (PostgreSQL): row now %d (psql) · cached read says %d, repository calls 1 then 0, statements 0, no exception, exit 0 · control via add(Oscar): invocations %d, rows %d -> %d" % (g[0], g[2], g[1], g[3], g[4], g[5]) for g in got))
elif NAME == "evict":
    L = lines(sys.argv[2]); S = sections(L); got = []
    for h, body in S:
        db, st = jvm(body, "PostgreSQL")
        w = window(body, "evict: a read, add(Hannah) - @CacheEvict(allEntries = true) - a read")
        ps = grab(body, r"^  psql \(a second client\): customers (\d+)$")
        if not (w and ps): continue
        m = re.match(r"^ · rows (\d+) -> (\d+) · Hannah in the second read: (true|false)$", w["rest"])
        ok(bool(m) and w["per"] == [1, 1] and int(m.group(2)) == int(m.group(1)) + 1 and m.group(3) == "true" and int(ps[0].group(1)) == int(m.group(2)), "evict (%s): the read after add reaches the repository (per call [1, 1]), its rows = psql's count, the new name in it" % st)
        if st == "Redis":
            wl = writerline(body) if any(l.startswith("PROBE the cache writer") for l in body) else None
        got.append((st, w["calls"], int(m.group(1)) if m else 0, int(m.group(2)) if m else 0))
    ok([g[0] for g in got] == ["in the JVM, Caffeine", "Redis"], "both stores")
    if len(got) == 2:
        VALUES.append(" · ".join("%s (PostgreSQL): rows %d -> %d, invocations %d (both reads)" % (g[0], g[2], g[3], g[1]) for g in got) + " · Redis through the anchor's writer")
elif NAME == "put":
    L = lines(sys.argv[2]); S = sections(L); got = []
    for h, body in S:
        db, st = jvm(body, "PostgreSQL")
        ok(any(l == "PROBE put: a harness bean, not the anchor's cache - HarnessPut.Meals, its cache h12put; the cache names at the start [customers, h12put]" for l in body), "R.384: the harness's cache named at the start beside the anchor's, labelled the harness's")
        m = grab(body, r"^PROBE put \(" + DBS + ", " + STORE + r"\): @CachePut write\(\"Ravi\", 2\), write\(\"Ravi\", 3\), then @Cacheable read\(\"Ravi\"\): per call " + LIST + " and " + LIST + r" · the writes returned \[(.*)\] · the read returned \"(.*)\"$")
        e = grab(body, r"^PROBE put: the two witnesses' per-call lists (equal|DIFFER)$")
        if not m: continue
        a, b = lst(m[0].group(3)), lst(m[0].group(4)); wr = m[0].group(5).split(", ")
        ok(a == b and e and e[0].group(1) == "equal", "R.375: the two witnesses agree")
        ok(a == [1, 1, 0] and m[0].group(6) == wr[-1], "@CachePut: every write invokes (1, 1), the read is served from the cache (0) and returns the second write's value: %s, %s" % (a, m[0].group(6)))
        if st == "Redis":
            g = grab(body, r'^  redis-cli GET "h12put::Ravi" \(the harness.s key\): (.*)$')
            ok(bool(g) and wr[-1] in g[0].group(1), "redis-cli reads the second write's value under the harness's key")
        got.append((st, a, m[0].group(6)))
    ok([g[0] for g in got] == ["in the JVM, Caffeine", "Redis"], "both stores")
    if got:
        VALUES.append("the harness's h12put (not the anchor's): " + " · ".join("%s (PostgreSQL): per call %s, the read returned \"%s\"" % g for g in got))
elif NAME == "ttl":
    L = lines(sys.argv[2]); S = sections(L); got = []
    for h, body in S:
        ok("LABELLED SHORT OVERRIDE" in h and "=<n>" in h, "the override labelled, its value masked")
        db, st = jvm(body, "PostgreSQL")
        k1 = grab(body, r"^PROBE ttl: after read 1 - keys (\d+) \(")
        kp = grab(body, r"^PROBE ttl: the harness polled the condition \(keys 0\), bounded, under the JVM's alarm - keys (\d+)$")
        w = window(body, "ttl: a read, the key gone, a read")
        if not (k1 and kp and w): continue
        mm = re.match(r"^ · invocations (\d+) -> (\d+) · keys after read 2: (\d+)$", w["rest"])
        ok(k1[0].group(1) == "1" and kp[0].group(1) == "0" and w["per"] == [1, 1] and bool(mm) and mm.groups() == ("1", "2", "1"), "keys 1 -> 0 (polled on the condition), then the read reaches the repository: invocations 1 -> 2 (%s)" % st)
        if st == "Redis":
            s1 = grab(body, r"^  the receipt at pause 1, redis-cli: --scan (.*) \((\d+) keys\)$")
            t1 = grab(body, r"^  redis-cli TTL \"customers::SimpleKey \[\]\": TTL <n> · a positive count, at most the configured value \(the override's\): (yes|no)$")
            s2 = grab(body, r"^  the receipt at pause 2, redis-cli: --scan \((\d+) keys\) · EXISTS \"customers::SimpleKey \[\]\" (\d+)$")
            ok(bool(s1) and s1[0].groups() == (KEY, "1") and bool(t1) and t1[0].group(1) == "yes", "redis-cli (a second client) at pause 1: the one key, its TTL a positive count at most the override's")
            ok(bool(s2) and s2[0].groups() == ("0", "0"), "redis-cli at pause 2: 0 keys, EXISTS 0 - the harness's keys 0 seen by a second client")
        else:
            cl = grab(body, r"^PROBE ttl: keys 0 · estimatedSize after cleanUp\(\) (\d+)$")
            ok(bool(cl) and cl[0].group(1) == "0", "Caffeine: getIfPresent null, and estimatedSize 0 after cleanUp() (before it, Caffeine's lazy expiry: standard error only)")
            ok(any("expireAfterWrite() Optional[…] (present) · its value = the spec's expireAfterWrite=<n>: yes" in l for l in body), "Caffeine's policy holds the override's value")
        got.append(st)
    ok(got == ["in the JVM, Caffeine", "Redis"], "both stores: %s" % got)
    if len(got) == 2:
        VALUES.append("a labelled short override (masked), PostgreSQL, Caffeine and Redis alike: keys 1 -> 0 by a bounded poll on the condition, then invocations 1 -> 2; Redis: redis-cli --scan 1 key then 0, TTL a positive count at most the override's; Caffeine: getIfPresent null, estimatedSize 0 after cleanUp()")
elif NAME == "stampede":
    L = lines(sys.argv[2]); S = sections(L)
    ok(L[0] == "-- the stampede's class, harness/src/probe/u12/Stampede.java: lines naming sleep 0 · the read each thread makes: the anchor's own CustomerRepository.findAll() (the context's bean)", "READ FIRST 14: no sleep in the stampede's class")
    got = {}
    for h, body in S[1:]:
        db, st = jvm(body, "PostgreSQL")
        label = st
        res = {}
        for n in (2, 4, 8, 16, 32):
            rx = r"^PROBE stampede %d threads \(PostgreSQL 18\.6, %s\), 20 rounds, the key cold in each: every round's repository calls = its statements: (yes|NO)%s · more than one in every round: (yes|no) · calls that threw (\d+)$" % (n, re.escape(st), r" · %d in every round: (yes|no)" % n if n <= 4 else "()")
            m = grab(body, rx)
            if not m: continue
            eq, alln, many, threw = m[0].groups()
            ok(eq == "yes" and threw == "0", "R.375: %d threads (%s): per round, repository calls = statements; no call threw" % (n, label))
            ok(many == "yes", "R.381: %d threads (%s): more than one read in every round" % (n, label))
            if n <= 4:
                pr = [l for l in body if l.startswith("PROBE stampede %d threads: per round " % n)]
                ok((alln == "yes") == (len(pr) == 1) and (alln != "yes" or pr[0].endswith(str([n] * 20))), "%d threads (%s): the per-round list printed exactly when every round printed %d" % (n, label, n))
            res[n] = (alln, many)
        if st == "Redis":
            wl = writerline(body); ok(wl == ("org.springframework.data.redis.cache.DefaultRedisCacheWriter", "false", "yes"), "the anchor's writer")
        got[label] = res
    ok(sorted(got) == sorted(["in the JVM, Caffeine", "Redis"]), "two JVMs: Caffeine, Redis with the anchor's writer")
    if "in the JVM, Caffeine" in got:
        ok(all(got["in the JVM, Caffeine"].get(n, ("", ""))[0] == "yes" for n in (2, 4)), "R.381: Caffeine on PostgreSQL - 2 and 4 threads -> N in every round (the three runs of this capture equal: 60 of 60 per count)")
    def say(r):
        return ", ".join(("%d -> %d in every round" % (n, n)) if n <= 4 and r[n][0] == "yes" else ("%d -> more than one in every round, up to all of them" % n) for n in sorted(r))
    if len(got) == 2:
        VALUES.append("PostgreSQL, 20 rounds per count per JVM, 3 JVMs per run (the capture 3/3): Caffeine %s · Redis (the anchor's writer) %s · H2 never run · Boot's own writer not captured" % (say(got["in the JVM, Caffeine"]), say(got["Redis"])))
elif NAME == "pinned":
    L = lines(sys.argv[2]); S = sections(L); got = []
    for h, body in S:
        if not h.startswith("-- after/"): continue
        db, st = jvm(body, "PostgreSQL")
        w = window(body, "pinned: the read, the write around the cache, the read again")
        if not w: continue
        m = re.match(r"^ · Ravi's meals: read (\d+) · JdbcTemplate update (\d+) row · row now (\d+) · cached read says (\d+)$", w["rest"])
        ok(bool(m) and w["per"] == [1, 0] and m.group(2) == "1" and m.group(1) == m.group(4) != m.group(3), "%s: one cached read, a write around the cache, the cached read still old: %s" % (st, w["rest"]))
        mgr(body, {"in the JVM, a ConcurrentMap": CMM, "in the JVM, Caffeine": CAF, "Redis": RCM}.get(st, "?"))
        got.append((st, w["rest"].lstrip(" ·")))
    ok([g[0] for g in got] == ["in the JVM, a ConcurrentMap", "in the JVM, Caffeine", "Redis"], "three stores: ConcurrentMap, Caffeine, Redis")
    c7 = grab(L, r"^-- Course 7's sentence \(C8-3\), read off \.\./c7-unit32/pinned\.txt - md5 ([0-9a-f]{32}), 1 line:$")
    ok(bool(c7) and c7[0].group(1) == "dbd5b67c2521ccde67a5d0f8b6039a62", "C8-3: Course 7's sentence by its md5 (dbd5b67c…)")
    i = L.index(c7[0].group(0)) if c7 else -1
    ok(i >= 0 and L[i + 1] == "  " + open("../c7-unit32/pinned.txt", encoding="utf-8").read().rstrip("\n"), "C8-3's sentence printed byte for byte from its file")
    p = grab(L, r"^  md5 ([0-9a-f]{32}) · 1 line · cmp with pinned\.txt: the same, byte for byte$")
    import hashlib
    ok(bool(p) and p[0].group(1) == hashlib.md5(open("pinned.txt", "rb").read()).hexdigest(), "C8-22: the heredoc's file = this folder's pinned.txt, byte for byte, its md5")
    if len(got) == 3 and p:
        VALUES.append("C8-3 md5 dbd5b67c… · C8-22 pinned.txt md5 %s… · PostgreSQL: %s" % (p[0].group(1)[:8], " · ".join("%s: %s" % g for g in got)))
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
