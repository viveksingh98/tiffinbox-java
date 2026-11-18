"""Unit 10's checks (python3 -I -B harness/chk10.py NAME ARGS...). Each capture's numbers are asserted against a second witness of the
same run - never a typed figure: the invocation counter against Hibernate's statement counter per call (R.375), the rows a read
returned against a second client (JdbcTemplate in the JVM; psql on PostgreSQL) and V2's seed lines, the database the harness named
against Flyway's Database line, the CacheManager bean against the cache's own classes, Surefire's XML against Maven's Results lines,
the seven's md5 against Course 7's published one. Prints ok/FAIL lines and one VALUES line; exits 1 on any FAIL.
  static AFTER BEFORE   the change itself, read off the files (C2's two files and the README, nothing else; no Java change)
  r250 AFTER BEFORE     the anchor README's sentences C2 made false: each carries its unit 10 note (R.250)
  wib CAPTURE FILE      the lines the exercise's block printed for FILE (bash's), for receipts.sh to compare with "What it prints"
  anchor|stats|ceiling|nonames|tests|seven|exercise CAPTURE [...]"""
import re, sys

NAME = sys.argv[1]
fails = []
oks = []


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
    m = [re.search(rx, l) for l in L]
    m = [x for x in m if x]
    ok(len(m) == n, "%d line(s) match %s (found %d)" % (n, rx, len(m)))
    return m


LIST = r"\[([0-9, ]+)\]"
def lst(s): return [int(x) for x in s.split(",")]


def window(L, label):
    """A counted window's line: calls, statements, the two per-call lists, rows; asserted equal (R.375)."""
    m = grab(L, r"^PROBE " + re.escape(label) + r" \((H2 2\.5\.250|PostgreSQL 18\.6)\): repository calls (\d+) · prepareStatementCount (\d+) · per call " + LIST + " and " + LIST + r" · rows (\d+)$")
    if not m: return None
    db, c, s, a, b, r = m[0].groups()
    a, b = lst(a), lst(b)
    ok(a == b, "R.375: %s on %s - the counter's per-call list %s = the statement counter's %s" % (label, db, a, b))
    ok(sum(a) == int(c) and sum(b) == int(s), "%s on %s: each total is the sum of its per-call list" % (label, db))
    eq = grab(L, r"^PROBE " + re.escape(label) + r": the two witnesses' per-call lists (equal|DIFFER)")
    ok(bool(eq) and eq[0].group(1) == "equal", "%s on %s: the harness's own comparison says equal" % (label, db))
    return db, int(c), int(s), a, int(r)


def dbline(L, db):
    fl = [l for l in L if l.startswith("  log: Database: ")]
    want = "(H2 2.5)" if db.startswith("H2") else "(PostgreSQL 18.6)"
    ok(len(fl) == 1 and fl[0].endswith(want), "the harness's database %s = Flyway's Database line %s" % (db, fl))
    ok(any(l == "PROBE started: yes · the database that answered: " + db + " · a web server: yes" for l in L), "the harness started on %s, its web server on" % db)


def secs(p):
    return sections(lines(p))


def v2rows():
    return sum(1 for l in lines("after/tiffinbox-core/src/main/resources/db/migration/V2__seed.sql") if l.startswith("INSERT INTO customer "))



def dbof(body):
    d = [m.group(1) for m in (re.match(r"^PROBE started: yes · the database that answered: (.*?) · a web server: yes$", l) for l in body) if m]
    ok(len(d) == 1, "one database per JVM, its web server on")
    return d[0] if d else "?"


MGR = "org.springframework.cache.caffeine.CaffeineCacheManager"
NATIVE = "com.github.benmanes.caffeine.cache.BoundedLocalCache$BoundedLocalManualCache"
V2 = None
VALUES = []
if NAME == "static":
    A, B = sys.argv[2], sys.argv[3]
    import filecmp, os
    rd = lambda t, p: open(os.path.join(t, p), encoding="utf-8").read()
    POM, YML = "tiffinbox-web/pom.xml", "tiffinbox-web/src/main/resources/application.yaml"
    changed = []
    for d, ds, fs in os.walk(A):
        for f in fs:
            p = os.path.relpath(os.path.join(d, f), A)
            q = os.path.join(B, p)
            if not os.path.exists(q): changed.append("new " + p)
            elif not filecmp.cmp(os.path.join(A, p), q, shallow=False): changed.append(p)
    for d, ds, fs in os.walk(B):
        for f in fs:
            p = os.path.relpath(os.path.join(d, f), B)
            if not os.path.exists(os.path.join(A, p)): changed.append("gone " + p)
    ok(sorted(changed) == sorted(["README.md", POM, YML]), "C2: the files changed are README.md, the web POM and application.yaml - nothing new, nothing gone, no Java file: %s" % sorted(changed))
    import difflib
    pd = [l for l in difflib.unified_diff(rd(B, POM).splitlines(), rd(A, POM).splitlines(), lineterm="", n=0) if l[:1] in "+-" and not l.startswith(("+++", "---"))]
    ok(all(l.startswith("+") for l in pd), "the web POM: lines added only, none removed")
    added = "\n".join(l[1:] for l in pd)
    ok(re.search(r"<dependency>\s*<groupId>com\.github\.ben-manes\.caffeine</groupId>\s*<artifactId>caffeine</artifactId>\s*</dependency>", rd(A, POM)) is not None and "caffeine" not in rd(B, POM) and "<version>" not in added, "the web POM gains com.github.ben-manes.caffeine:caffeine, no version typed (Boot's parent manages it)")
    ok("Course 8, unit 10:" in added, "its comment names unit 10, as the POM's other dependencies' comments name theirs")
    yd = [l for l in difflib.unified_diff(rd(B, YML).splitlines(), rd(A, YML).splitlines(), lineterm="", n=0) if l[:1] in "+-" and not l.startswith(("+++", "---"))]
    ok(all(l.startswith("+") for l in yd), "application.yaml: lines added only")
    keys = [l[1:] for l in yd if not l[1:].strip().startswith("#")]
    ok(keys == ["  cache:", "    cache-names: customers", "    caffeine:", "      spec: maximumSize=100,recordStats"], "application.yaml gains spring.cache.cache-names: customers and spring.cache.caffeine.spec: maximumSize=100,recordStats, nothing else: %s" % keys)
    ya = rd(A, YML); top = ya.split("\n---\n")[0]
    ok("  cache:\n    cache-names: customers\n" in top and top.index("\nspring:\n") < top.index("  cache:\n    cache-names"), "the keys sit under the first document's spring:, above the ---")
    ok(any("Course 8, unit 10:" in l for l in yd), "a Course 8, unit 10: comment in the file's comment style")
    ok("ddl-auto: validate" in ya and "include: health,prometheus" in ya, "ddl-auto validate and the exposure health,prometheus untouched")
    ok(sorted(os.listdir(os.path.join(A, "tiffinbox-core/src/main/resources/db/migration"))) == ["V1__customer_and_pause.sql", "V2__seed.sql", "V3__customer_audit_columns.sql"], "Flyway's V1-V3, no V4")
    for j in ("tiffinbox-core/src/main/java/com/tiffinbox/CustomerRepository.java", "tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxApp.java"):
        ok(rd(A, j) == rd(B, j), "no Java change: " + j)
    cr = rd(A, "tiffinbox-core/src/main/java/com/tiffinbox/CustomerRepository.java")
    ok('return customers.findAll(Sort.by("name")).stream().map(CustomerRepository::toRecord).toList();' in cr, "findAll's body unchanged: .toList() stays (the ArrayList is unit 11's)")
    ok(sum(1 for l in cr.splitlines() if l.strip().startswith("@Cache")) == 2, "two cache annotations in CustomerRepository: findByName stays uncached (unit 13's)")
    c10 = open("harness/src/probe/u10/Counter.java", encoding="utf-8").read()
    c08 = open("../c8-unit08/harness/src/probe/u08/Counter.java", encoding="utf-8").read()
    ok(c10.replace("package probe.u10;", "package probe.u08;").replace(" Copied from unit 08's harness (probe.u08.Counter): only the package\n * line and this sentence differ.", "") == c08, "Counter.java = unit 08's, but for its package line and the sentence that says so")
    VALUES.append("C2 files 2 + README")
elif NAME == "r250":
    A = sys.argv[2]
    R = open(A + "/README.md", encoding="utf-8").read().splitlines()
    FR = [("Course 8's units are planned to put a", "(Course 8, unit 10, **Section 2's second change to this folder**"),
          ("With no cache library on the class path Boot builds a **`ConcurrentMapCacheManager`**: each cache a", "(Course 8, unit 10:")]
    for f, note in FR:
        h = [k for k, l in enumerate(R) if f in l]
        ok(len(h) == 1, "R.250: the sentence is in the README once: " + f[:60])
        if f.startswith("With no cache"):
            ok(bool(h) and note in R[h[0] + 1], "R.250: its unit 10 note closes the sentence (next line): " + f[:60])
        else:
            ok(bool(h) and note in R[h[0]], "R.250: its unit 10 note sits on its line: " + f[:60])
    ok(any(l.startswith("## Course 8 · unit 10 — ") for l in R), "the README's Course 8 · unit 10 section")
    ok(not any(re.search(r"ConcurrentMapCacheManager|ConcurrentHashMap", l) and "unit 10" not in l and "unit 08" not in l and "in place of" not in l and not any(f in l for f, _ in FR) for l in R), "no other present-tense ConcurrentMap sentence")
    VALUES.append("R.250 sentences %d" % len(FR))
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

elif NAME == "anchor":
    L = lines(sys.argv[2]); S = secs(sys.argv[2])
    lib = {t: int(m.group(2)) for t, m in ((x[0].group(1), x[0]) for x in [grab(L, r"^  (%s)/: (\d+) libraries" % t) for t in ("before", "after")])}
    gained = [l[len("  gained: "):] for l in L if l.startswith("  gained: ")]
    lost = [l for l in L if l.startswith("  lost: ")]
    ok(lib["after"] - lib["before"] == len(gained) and not lost, "the libs count: after %d = before %d + the %d jars gained, none lost" % (lib["after"], lib["before"], len(gained)))
    caf = [g for g in gained if g.startswith("caffeine-")]
    ok(caf == ["caffeine-3.2.4.jar"], "Caffeine's jar among the gained: %s" % gained)
    ok(any(re.match(r"^  after/: .* Caffeine in lib/: caffeine-3\.2\.4\.jar$", l) for l in L) and any(re.match(r"^  before/: .* Caffeine in lib/: none$", l) for l in L), "Caffeine in after/'s lib, not in before/'s")
    for t in ("before", "after"): ok(any(re.match(r"^  %s/: .* a PostgreSQL driver in lib/: postgresql-42\.7\.14\.jar " % t, l) for l in L), t + "/'s jar carries its own PostgreSQL driver")
    dbs = []; VER = ("?",) * 6
    for h, body in S[1:]:
        db = dbof(body); dbs.append(db); dbline(body, db)
        ok(sum(1 for l in body if l == "  log: Multiple Spring Data modules found, entering strict repository configuration mode") == 2, "strict mode, once per module (%s)" % db)
        ok(sum(1 for l in body if l == "  log: Found 1 JPA repository interface") == 1 and sum(1 for l in body if l == "  log: Found 1 JDBC repository interface") == 1, "Found 1 JPA and Found 1 JDBC (%s)" % db)
        v = grab(body, r"^PROBE versions: Spring Boot (\S+) · Spring Framework (\S+) · Spring Data JPA (\S+) · Spring Data JDBC (\S+) · Hibernate (\S+) · Flyway \(version\.txt\) (\S+)$")
        ok(bool(v) and v[0].groups() == ("4.1.2", "7.0.10", "4.1.2", "4.1.2", "7.4.13.Final", "12.4.0"), "the version lines (R.246) on " + db)
        ok(bool(v) and ("  log: HHH000001: Hibernate ORM core version " + v[0].group(5)) in body, "Hibernate's version = HHH000001's")
        if v: VER = v[0].groups()
        ok("PROBE the environment: spring.cache.type unset · spring.cache.cache-names customers · spring.cache.caffeine.spec maximumSize=100,recordStats · management.endpoints.web.exposure.include health,prometheus" in body, "the environment: type unset, names customers, the spec, the exposure unchanged (%s)" % db)
        ok("PROBE CacheManager beans 1 [cacheManager=%s] (%s)" % (MGR, db) in body, "CacheManager beans 1, CaffeineCacheManager (%s)" % db)
        ok("PROBE the cache names at the start, getCacheNames(): [customers]" in body, "getCacheNames() [customers] (%s)" % db)
        ok("PROBE cache customers: org.springframework.cache.caffeine.CaffeineCache · native " + NATIVE in body, "the cache CaffeineCache, its native BoundedLocalManualCache (%s)" % db)
        ok(any(l.startswith("PROBE CustomerEntityRepository's bean: a Spring AOP proxy (Advised) · the counter installed: yes") for l in body), "the counter installed (%s)" % db)
        st = grab(body, r"^PROBE the start's own read .*: repository calls (\d+) · prepareStatementCount (\d+) · Caffeine's stats\(\) CacheStats\{hitCount=0, missCount=0, .*\} · estimatedSize 0 · the list's entry \(SimpleKey \[\]\) present false$")
        ok(bool(st) and st[0].group(1) == st[0].group(2), "the start's read: the two counters agree, Caffeine's stats 0, the entry absent (%s)" % db)
        codes = {m.group(1): m.group(2) for m in (re.match(r"^PROBE http \(.*\): GET (\S+) -> (\d+)$", l) for l in body) if m}
        ok(codes == {"/dashboard": "200", "/actuator/caches": "404", "/actuator/metrics": "404", "/actuator/prometheus": "200"}, "GET /dashboard 200, /actuator/caches 404, /actuator/metrics 404, /actuator/prometheus 200 (%s): %s" % (db, codes))
        ok(any(l.startswith("  exit 0 · its log") for l in body), "exit 0 (%s)" % db)
    ok(dbs == ["H2 2.5.250", "PostgreSQL 18.6"], "H2 then PostgreSQL: %s" % dbs)
    VALUES.append("CacheManager %s, cache org.springframework.cache.caffeine.CaffeineCache, native %s, names [customers], on H2 2.5.250 and PostgreSQL 18.6; GET /dashboard 200 · /actuator/caches 404 · /actuator/metrics 404; libs %d -> %d (+%s); Boot %s · Framework %s · Spring Data JPA/JDBC %s/%s · HHH000001 %s · Flyway %s · Caffeine jar %s; Found 1 JPA + Found 1 JDBC" % ((MGR, NATIVE, lib["before"], lib["after"], ", ".join(gained)) + VER + (caf[0] if caf else "?",)))
elif NAME == "stats":
    S = secs(sys.argv[2]); L = lines(sys.argv[2]); V2 = v2rows()
    hooks = []; res = []
    for h, body in S:
        if not any(l.startswith("PROBE started:") for l in body): continue
        db = dbof(body); dbline(body, db)
        ok("PROBE CacheManager beans 1 [cacheManager=%s] (%s)" % (MGR, db) in body and "PROBE cache customers: org.springframework.cache.caffeine.CaffeineCache · native " + NATIVE in body, "Caffeine's manager and cache (%s)" % db)
        st = grab(body, r"^PROBE the start's own read .*: repository calls (\d+) · prepareStatementCount (\d+) · Caffeine's stats\(\) CacheStats\{hitCount=0, missCount=0, loadSuccessCount=0, loadFailureCount=0, totalLoadTime=<masked>, evictionCount=0, evictionWeight=0\} · estimatedSize 0 · the list's entry \(SimpleKey \[\]\) present false$")
        ok(bool(st) and st[0].group(1) == st[0].group(2), "the start window: both counters agree, stats 0, entry absent (%s)" % db)
        w = window(body, "reads: five calls of CustomerRepository.findAll()")
        ok(bool(w) and w[3] == [1, 0, 0, 0, 0] and w[4] == V2, "five calls: per call [1, 0, 0, 0, 0], rows = V2's (%s)" % db)
        cs = grab(body, r"^PROBE reads: after the five calls \(.*\): Caffeine's stats\(\) CacheStats\{hitCount=(\d+), missCount=(\d+), loadSuccessCount=0, loadFailureCount=0, totalLoadTime=<masked>, evictionCount=(\d+), evictionWeight=0\} · estimatedSize (\d+) \(after cleanUp\(\)\) · keys \[org\.springframework\.cache\.interceptor\.SimpleKey = SimpleKey \[\]\]$")
        sc = grab(body, r"^PROBE scrape \(.*\): GET /actuator/prometheus -> (\d+) · cache_ lines (\d+) · cache_ lines for customers (\d+)$")
        pr = {}
        for l in body:
            m = re.match(r'^PROBE scrape \(.*\): prometheus (cache_\w+)\{cache="customers",cache_manager="cacheManager",name="customers"(?:,result="(hit|miss)")?\} ([0-9.]+)$', l)
            if m: pr[m.group(1) + (":" + m.group(2) if m.group(2) else "")] = m.group(3)
        if w and cs:
            hit, miss, ev, size = (int(x) for x in cs[0].groups())
            calls = w[1]
            ok(miss == calls and hit == 5 - calls, "R.375: Caffeine's misses = the invocation counter's calls (%d), its hits = the five reads less them (%s)" % (calls, db))
            ok(pr.get("cache_gets_total:hit") == "%d.0" % hit and pr.get("cache_gets_total:miss") == "%d.0" % miss and pr.get("cache_size") == "%d.0" % size and pr.get("cache_evictions_total") == "%d.0" % ev, "prometheus's hit/miss/size/evictions = Caffeine's own (%s): %s" % (db, pr))
            ok(size == 1 and ev == 0, "one entry, no eviction: the list never reaches the ceiling (%s)" % db)
            ok(pr.get("cache_puts_total") == "0.0", "cache_puts_total printed, 0.0 after a stored read (not voiced) (%s)" % db)
        ok(bool(sc) and sc[0].group(1) == "200" and sc[0].group(3) == str(len(pr)) and len(pr) == 6, "the scrape: 200, six cache_ lines for customers, each printed (%s)" % db)
        b0 = grab(body, r"^PROBE add: before, rows by JdbcTemplate .* (\d+)$")
        ad = grab(body, r"^PROBE add: add\(Emma\) \(.*\): repository calls (\d+) · prepareStatementCount (\d+)$")
        aw = window(body, "add: the next call")
        b1 = grab(body, r"^PROBE add: rows by JdbcTemplate \(the second client\) (\d+)$")
        a2 = grab(body, r"^PROBE add: after add and the next call \(.*\): Caffeine's stats\(\) CacheStats\{hitCount=(\d+), missCount=(\d+), .*evictionCount=(\d+), .*\} · estimatedSize (\d+) ")
        ap = {}
        for l in body:
            m = re.match(r'^PROBE add: then \(.*\): prometheus (cache_\w+)\{cache="customers",cache_manager="cacheManager",name="customers"(?:,result="(hit|miss)")?\} ([0-9.]+)$', l)
            if m: ap[m.group(1) + (":" + m.group(2) if m.group(2) else "")] = m.group(3)
        if b0 and aw and b1 and a2 and cs and w:
            ok(int(b0[0].group(1)) == V2 and aw[4] == V2 + 1 == int(b1[0].group(1)), "rows %d -> %d, the read's = JdbcTemplate's (%s)" % (V2, aw[4], db))
            ok(aw[3] == [1], "after add, the next call reaches the repository (%s)" % db)
            ok(int(a2[0].group(2)) == miss + aw[1] and int(a2[0].group(1)) == hit, "Caffeine's misses after add = before + the next call's invocation (%s)" % db)
            ok(ap.get("cache_gets_total:miss") == a2[0].group(2) + ".0" and ap.get("cache_size") == a2[0].group(4) + ".0" and ap.get("cache_evictions_total") == a2[0].group(3) + ".0", "prometheus after add = Caffeine's own (%s)" % db)
            res.append((db, w, (hit, miss, ev, size), pr, aw, a2[0].groups(), int(b1[0].group(1)), ad[0].groups() if ad else None))
        ex = [l for l in body if l.startswith("  exit 0 · its log")]
        ok(len(ex) == 1, "exit 0 (%s)" % db)
        hk = [re.sub(r"\((H2 2\.5\.250|PostgreSQL 18\.6)\)", "(<db>)", l) for l in body if l.startswith(("PROBE reads", "PROBE scrape"))]
        import hashlib
        hooks.append(hashlib.md5("\n".join(hk).encode()).hexdigest())
    ok([r[0] for r in res] == ["H2 2.5.250"] + ["PostgreSQL 18.6"] * 3, "H2, then PostgreSQL in three JVMs: %s" % [r[0] for r in res])
    ok(len(hooks) == 4 and len(set(hooks)) == 1, "the hook's lines (five reads, stats, scrape) byte-identical on H2 and the three PostgreSQL JVMs but the db: %s" % hooks)
    pq = [m for m in (re.match(r"^  psql \(a second client, PostgreSQL\) after the JVM stopped: customers (\d+) · Emma$", l) for l in L) if m]
    ok(len(pq) == 3 and all(int(m.group(1)) == V2 + 1 for m in pq), "psql, three times: V2's rows + Emma")
    if len(res) == 4:
        db, w, (hit, miss, ev, size), pr, aw, a2, rows, ad = res[1]
        VALUES.append("calls %d statements %d per call %s · Caffeine hitCount=%d missCount=%d evictionCount=%d estimatedSize %d, key SimpleKey [] · prometheus hit %s miss %s size %s evictions %s (puts %s, not voiced) · the start: stats 0, the entry absent · add(Emma): the next call %s, rows %d -> %d (JdbcTemplate; psql), missCount=%s, prometheus miss %s · H2 and PostgreSQL x3 the same (hook md5 %s)"
                      % (w[1], w[2], w[3], hit, miss, ev, size, pr["cache_gets_total:hit"], pr["cache_gets_total:miss"], pr["cache_size"], pr["cache_evictions_total"], pr["cache_puts_total"], aw[3], V2, rows, a2[1], a2[1] + ".0", hooks[0][:8]))
elif NAME == "ceiling":
    L = lines(sys.argv[2])
    src = open("../c2-unit04/Bounded.java", encoding="utf-8").read()
    hd = grab(L, r"^CEILING Bounded\.java \(read at run time\): new LinkedHashMap<String, Integer>\((.*)\) · the ceiling: size\(\) > (\d+) · the sequence (\[.*\]) · (\d+) fresh pairs, one JVM - a harness on Caffeine's own API, not TiffinBox's cache$")
    seq = ["%s %s%s" % (m.group(1), m.group(2), " " + m.group(3) if m.group(3) else "") for m in re.finditer(r'cache\.(put|get)\("(\w+)"(?:, (\d+))?\);', src)]
    if hd:
        ok(hd[0].group(1) == "16, 0.75f, true" and "new LinkedHashMap<String, Integer>(16, 0.75f, true)" in src, "the map's constructor = Bounded.java's (access order)")
        ok(hd[0].group(3) == "[" + ", ".join(seq) + "]", "the sequence = Bounded.java's, read again here: %s" % seq)
        ok(("return size() > %s;" % hd[0].group(2)) in src, "the ceiling = Bounded.java's")
    n = int(hd[0].group(4)) if hd else 0
    lm = grab(L, r"^CEILING Course 2's LinkedHashMap \(access order, removeEldestEntry\): keySet\(\) in its own order -> \{(\[[A-Za-z, ]+\])=(\d+)\} · dropped \{(\[[A-Za-z, ]*\])=(\d+)\}$")
    cm = grab(L, r"^CEILING Caffeine maximumSize\((\d+)\), executor\(Runnable::run\), cleanUp\(\) before reading: asMap\(\)\.keySet\(\) sorted -> \{(\[[A-Za-z, ]+\])=(\d+)\} · dropped \{(\[[A-Za-z, ]*\])=(\d+)\} · estimatedSize \{(\d+)=(\d+)\} · stats\(\)\.evictionCount\(\) \{(\d+)=(\d+)\}$")
    ok("CEILING the same survivors: no" in L, "the two survivor sets differ")
    ok(any(re.match(r"^  exit 0 · lines that are not the program's own: 0$", l) for l in L), "exit 0, no other line")
    if lm and cm and hd:
        ok(lm[0].group(2) == lm[0].group(4) == str(n) and cm[0].group(3) == cm[0].group(5) == cm[0].group(7) == cm[0].group(9) == str(n), "every one of the %d pairs printed the same, both maps" % n)
        ok(lm[0].group(1) == "[Sam, Ravi, Nina]", "the LinkedHashMap's survivors are Course 2's terminal line: %s" % lm[0].group(1))
        ok("[Sam, Ravi, Nina]" in open("README.md", encoding="utf-8").read(), "README.md carries Course 2's terminal line")
        ok(cm[0].group(1) == hd[0].group(2) and cm[0].group(6) == hd[0].group(2) and cm[0].group(8) == "1", "Caffeine kept the ceiling's number, one eviction")
        ok(lm[0].group(3) != cm[0].group(4), "the victims differ: %s vs %s" % (lm[0].group(3), cm[0].group(4)))
        VALUES.append("a harness on Caffeine's own API, not TiffinBox's cache: Bounded.java's sequence, ceiling %s - LinkedHashMap %s (drops %s) vs Caffeine %s (drops %s, asMap().keySet() sorted), %s of %s pairs in one JVM, the same each"
                      % (hd[0].group(2), lm[0].group(1), lm[0].group(3), cm[0].group(2), cm[0].group(4), cm[0].group(3), n))
elif NAME == "nonames":
    S = secs(sys.argv[2]); L = lines(sys.argv[2]); out = []; named = None
    for h, body in S:
        if not any(l.startswith("PROBE started:") for l in body): continue
        db = dbof(body); dbline(body, db)
        if h.startswith("-- the nonames copy"):
            ok("PROBE the environment: spring.cache.type unset · spring.cache.cache-names unset · spring.cache.caffeine.spec maximumSize=100,recordStats · management.endpoints.web.exposure.include health,prometheus" in body, "nonames: the names unset, the spec kept (%s)" % db)
            ok("PROBE CacheManager beans 1 [cacheManager=%s] (%s)" % (MGR, db) in body, "nonames: still CaffeineCacheManager (%s)" % db)
            ok("PROBE the cache names at the start, getCacheNames(): []" in body, "nonames: getCacheNames() [] at the start (%s)" % db)
            w = window(body, "reads: five calls of CustomerRepository.findAll()")
            ok(bool(w) and w[3] == [1, 0, 0, 0, 0], "nonames: five calls [1, 0, 0, 0, 0] (%s)" % db)
            cs = grab(body, r"^PROBE reads: after the five calls \(.*\): Caffeine's stats\(\) CacheStats\{hitCount=(\d+), missCount=(\d+), .*\} · estimatedSize (\d+) ")
            if w and cs: ok(int(cs[0].group(2)) == w[1] and int(cs[0].group(1)) == 5 - w[1], "nonames: Caffeine still counts - misses = the counter's calls (%s)" % db)
            sc = grab(body, r"^PROBE scrape \(.*\): GET /actuator/prometheus -> (\d+) · cache_ lines (\d+) · cache_ lines for customers (\d+)$")
            ok(bool(sc) and sc[0].groups() == ("200", "0", "0"), "nonames: the prometheus endpoint 200, 0 cache_ lines (%s)" % db)
            ok(not any(l.startswith("PROBE scrape") and " prometheus cache_" in l for l in body), "nonames: no cache_ line printed (%s)" % db)
            ex = grab(body, r"^  exit (\d+) · its log, every line but the harness's own PROBE lines: lines naming a cache \(case-insensitive\) (\d+) · WARN (\d+) · ERROR (\d+) · exception class names (\d+)$")
            ok(bool(ex) and ex[0].group(1) == "0" and ex[0].group(2) == "0" and ex[0].group(4) == "0" and ex[0].group(5) == "0", "nonames: exit 0, no log line naming a cache, no ERROR, no exception (%s)" % db)
            warns = [l for l in body if l.startswith("  its WARN line: ")]
            ok(all("newer than the version Flyway has been verified with" in l for l in warns), "nonames: the only WARN lines are Flyway's H2 version line (%s): %d" % (db, len(warns)))
            if w and cs and sc and ex: out.append((db, w, cs[0].groups(), sc[0].groups(), ex[0].groups()))
        else:
            ok("PROBE the environment: spring.cache.type unset · spring.cache.cache-names customers,h10 · spring.cache.caffeine.spec maximumSize=100,recordStats · management.endpoints.web.exposure.include health,prometheus" in body, "R.384: the harness JVM on after/ names its own cache beside the anchor's (customers,h10)")
            nm = grab(body, r"^PROBE the cache names at the start, getCacheNames\(\): (\[.*\])$")
            ok(bool(nm) and sorted(nm[0].group(1).strip("[]").split(", ")) == ["customers", "h10"], "the names at the start: customers and h10")
            ok('PROBE names: getCache("stampede") -> null' in body, "getCache(\"stampede\") -> null: the manager is static")
            hn = grab(body, r'^PROBE names: two calls of @Cacheable\("h10"\) \(H2 2\.5\.250\): its method ran (\d+) · repository calls (\d+) · per call ' + LIST + " and " + LIST + r" · the two lists equal$")
            ok(bool(hn) and lst(hn[0].group(3)) == lst(hn[0].group(4)) == [1, 0], "the harness's named cache caches: [1, 0] on both witnesses")
            th = grab(body, r"^PROBE names: one call of @Cacheable\(\"unnamed\"\) \(H2 2\.5\.250\): threw (java\.lang\.IllegalArgumentException): (Cannot find cache named 'unnamed') for Builder\[…\]$")
            cnt = grab(L, r"^  the run's log, the throw's message: lines with \"Cannot find cache named 'unnamed'\" (\d+) · with \"Cannot find cache named 'h10'\" (\d+)$")
            ok(bool(cnt) and cnt[0].group(1) == "1" and cnt[0].group(2) == "0", "the message grep'd: 'unnamed' once, 'h10' never")
            ok(any(l.startswith("  exit 0 · its log") for l in body), "the named JVM exits 0")
            named = (th[0].groups() if th else None, cnt[0].groups() if cnt else None)
    ok([o[0] for o in out] == ["H2 2.5.250", "PostgreSQL 18.6"], "nonames on H2 then PostgreSQL")
    if len(out) == 2 and named and named[0]:
        o = out[1]
        VALUES.append("the copy without spring.cache.cache-names: getCacheNames() [] · calls %d per call %s · Caffeine hitCount=%s missCount=%s · GET /actuator/prometheus %s with cache_ lines %s · exit 0 · log lines naming a cache 0 · ERROR 0 (H2 and PostgreSQL) · names given (customers,h10): getCache(\"stampede\") null · @Cacheable(\"unnamed\") threw %s: %s (grep 1)"
                      % (o[1][1], o[1][3], o[2][0], o[2][1], o[3][0], o[3][1], named[0][0], named[0][1]))
elif NAME == "tests":
    L = lines(sys.argv[2])
    sf = [l for l in L if re.match(r"^  (total|  ?[A-Za-z]).*", l)]
    res = [re.search(r"Tests run: (\d+), Failures: (\d+), Errors: (\d+), Skipped: (\d+)$", l) for l in L if "Results line" in l]
    res = [tuple(int(x) for x in m.groups()) for m in res if m]
    tot = [int(m.group(1)) for m in (re.search(r"^  +(?:total|all)[^0-9]*(\d+) tests?", l) for l in L) if m]
    ok(len(res) == 3, "three Results lines (package's 18; verify's two executions): %s" % res)
    if len(res) == 3:
        ok(res[0][1:] == (0, 0, 0) and res[1][1:] == (0, 0, 0) and res[2][1:] == (0, 0, 0), "no failure, no error, nothing skipped")
        ok(res[0][0] == res[1][0], "the Docker-free package runs the same tests as verify's first execution: %d" % res[0][0])
    ok(sum(1 for l in L if l.startswith("  exit 0 · BUILD SUCCESS · offline: yes")) == 2, "both builds exit 0, offline")
    ok(any("$SRI" in l or "surefire-reports-it: absent - no container test ran" in l for l in L), "package: no container test ran")
    ok(any("'Found 1 JPA repository interface' " in l and "'Pulling' 0" in l for l in L), "verify: nothing pulled")
    if len(res) == 3:
        VALUES.append("%d (mvn -o package, Maven's DOCKER_HOST at nothing) · %d + %d (mvn -o verify: H2 in memory + PostgreSQL in containers)" % (res[0][0], res[1][0], res[2][0]))
elif NAME == "seven":
    L = lines(sys.argv[2]); S466 = sys.argv[3]
    h = [m.group(1) for m in (re.search(r"the seven responses: 7 lines · md5 ([0-9a-f]{32})", l) for l in L) if m]
    ok(len(h) == 2 and h[0] == h[1] == S466, "the seven on before/ and after/ = Course 7's published md5")
    ok(sum(1 for l in L if l == "  GET /dashboard: 200") == 2, "GET /dashboard 200 on both")
    ok("  exit 0 · cmp with xcheck.sql (= Course 7's capstone's): the same, byte for byte" in L, "Hibernate's schema script = xcheck.sql")
    ok("  the seven, after/ against before/: lines that differ: 0" in L, "0 lines differ")
    VALUES.append("the seven %s… on before/ and after/ (0 lines differ) · GET /dashboard 200 · Hibernate's script = xcheck.sql" % S466[:8])
elif NAME == "exercise":
    L = lines(sys.argv[2]); W, Q = sys.argv[3], sys.argv[4]
    ok(W == "21", "the spoken line is 21 words (the brief's): %s" % W)
    blocks = {}
    cur = None
    for l in L:
        if l.startswith("in bash") or l.startswith("in zsh"): sh = l.split()[1]
        if "the README's lines" in l: cur = (sh, "readme"); blocks[cur] = []; continue
        if "then the solution's lines" in l: cur = (sh, "sol"); blocks[cur] = []; continue
        if l.startswith("  the shell is now in"): cur = None; continue
        if cur: blocks[cur].append(l.strip())
    ok(blocks.get(("bash", "readme")) == blocks.get(("zsh", "readme")) and blocks.get(("bash", "sol")) == blocks.get(("zsh", "sol")), "bash and zsh print the same")
    r, s = blocks.get(("bash", "readme"), []), blocks.get(("bash", "sol"), [])
    def hc(b):
        m = [re.match(r"^hitCount=(\d+), missCount=(\d+)$", l) for l in b]; m = [x for x in m if x]
        return m[0].groups() if len(m) == 1 else None
    def sc(b):
        m = [re.match(r"^GET /actuator/prometheus -> (\d+) · cache_ lines (\d+) · cache_ lines for customers (\d+)$", l) for l in b]; m = [x for x in m if x]
        return m[0].groups() if len(m) == 1 else None
    hl = lambda b: [l for l in b if l.startswith("cache_gets_total{")]
    ok(hc(r) == hc(s) == ("4", "1"), "R.196: Caffeine counts the same in both states: %s %s" % (hc(r), hc(s)))
    ok(sc(r) is not None and sc(r)[0] == "200" and sc(r)[2] == "0" and hl(r) == [], "R.196: broken - the endpoint 200, 0 cache_ lines for customers, no hit line")
    ok(sc(s) is not None and sc(s)[0] == "200" and int(sc(s)[2]) > 0 and hl(s) == ['cache_gets_total{cache="customers",cache_manager="cacheManager",name="customers",result="hit"} 4.0'], "R.196: solved - the hit line 4.0")
    ok("TiffinBox: exit 0" in r and "TiffinBox: exit 0" in s, "both exit 0 - the check is the prometheus line and Caffeine's count, never the exit")
    ok("cache-names lines in application.yaml: 0" in r and "cache-names lines in application.yaml: 1" in s, "the broken tree lacks the line, the solved one has it")
    if sc(r) and sc(s) and hc(r):
        VALUES.append("the line %s words · broken: hitCount=%s, the endpoint %s, cache_ lines for customers %s · solved: the hit line %s · exit 0 both" % (W, hc(r)[0], sc(r)[0], sc(r)[2], hl(s)[0].split()[-1] if hl(s) else "?"))
else:
    print("FAIL no check named " + NAME); sys.exit(1)
for o in oks: print("ok " + o)
for f in fails: print("FAIL " + f)
print("VALUES " + "; ".join(VALUES))
sys.exit(1 if fails else 0)
