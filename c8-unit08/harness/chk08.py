"""Unit 08's checks (python3 -I -B harness/chk08.py NAME ARGS...). Each capture's numbers are asserted against a second witness of the
same run - never a typed figure: the invocation counter against Hibernate's statement counter per call (R.375), the rows a read
returned against a second client (JdbcTemplate in the JVM; psql on PostgreSQL) and V2's seed lines, the database the harness named
against Flyway's Database line, the CacheManager bean against the cache's own classes, Surefire's XML against Maven's Results lines,
the seven's md5 against Course 7's published one. Prints ok/FAIL lines and one VALUES line; exits 1 on any FAIL.
  static AFTER BEFORE   the change itself, read off the files (C1's four files, nothing else in src/main, no YAML key, no V4)
  r250 AFTER BEFORE     the anchor README's sentences C1 made false: each carries its unit 08 note (R.250)
  wib CAPTURE FILE      the lines the exercise's block printed for FILE (bash's), for receipts.sh to compare with "What it prints"
  anchor|hits|evict|put|off|tests|seven|exercise CAPTURE [...]"""
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
    ok(any(l == "PROBE started: yes · the database that answered: " + db for l in L), "the harness started on %s" % db)


def secs(p):
    return sections(lines(p))


def v2rows():
    return sum(1 for l in lines("after/tiffinbox-core/src/main/resources/db/migration/V2__seed.sql") if l.startswith("INSERT INTO customer "))


VALUES = []
if NAME == "static":
    A, B = sys.argv[2], sys.argv[3]
    import filecmp, os
    rd = lambda t, p: open(os.path.join(t, p), encoding="utf-8").read()
    POM, APP, CR = "tiffinbox-web/pom.xml", "tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxApp.java", "tiffinbox-core/src/main/java/com/tiffinbox/CustomerRepository.java"
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
    ok(sorted(changed) == sorted(["README.md", POM, APP, CR]), "C1: the files changed are README.md and the three source files, nothing new, nothing gone: %s" % sorted(changed))
    pa, pb = rd(A, POM), rd(B, POM)
    dep = re.search(r"<dependency>\s*<groupId>org\.springframework\.boot</groupId>\s*<artifactId>spring-boot-starter-cache</artifactId>\s*</dependency>", pa)
    ok(bool(dep) and "spring-boot-starter-cache" not in pb, "the web POM gains spring-boot-starter-cache, no version typed (Boot's parent manages it)")
    ok(rd(A, "tiffinbox-core/pom.xml") == rd(B, "tiffinbox-core/pom.xml"), "tiffinbox-core/pom.xml unchanged (spring-context, which holds the annotations, was already there)")
    ok("<artifactId>spring-context</artifactId>" in rd(A, "tiffinbox-core/pom.xml"), "tiffinbox-core depends on spring-context")
    aa = rd(A, APP).splitlines()
    ok(aa.count("@EnableCaching") == 1 and aa.count("import org.springframework.cache.annotation.EnableCaching;") == 1 and "@EnableCaching" not in rd(B, APP), "TiffinBoxApp gains @EnableCaching and its import")
    ca = rd(A, CR).splitlines()
    i = [k for k, l in enumerate(ca) if l.strip().startswith("public List<Customer> findAll()")]
    ok(len(i) == 1 and ca[i[0] - 1].strip() == '@Cacheable("customers")', "findAll() carries @Cacheable(\"customers\") on the line above it")
    j = [k for k, l in enumerate(ca) if l.strip().startswith("public void add(Customer customer)")]
    ok(len(j) == 1 and ca[j[0] - 1].strip() == "@Transactional(rollbackFor = SQLException.class)" and ca[j[0] - 2].strip() == '@CacheEvict(cacheNames = "customers", allEntries = true)', "add carries @CacheEvict(cacheNames = \"customers\", allEntries = true) beside its @Transactional(rollbackFor = SQLException.class)")
    ok(sum(1 for l in ca if l.strip().startswith("@Cache")) == 2, "two cache annotations in CustomerRepository: findByName and pausedDaysByCustomer stay uncached")
    ok('return customers.findAll(Sort.by("name")).stream().map(CustomerRepository::toRecord).toList();' in rd(A, CR), "findAll's body unchanged: .toList() stays (the ArrayList is unit 11's)")
    for y in ("application.yaml", "application-dev.yaml", "application-audit.yaml"):
        ok("cache" not in rd(A, "tiffinbox-web/src/main/resources/" + y).replace("cache:\n        period", "") .replace("spring.thymeleaf.cache", "").replace("provider.cache", "") or rd(A, "tiffinbox-web/src/main/resources/" + y) == rd(B, "tiffinbox-web/src/main/resources/" + y), "no YAML change: " + y)
    ok(sorted(os.listdir(os.path.join(A, "tiffinbox-core/src/main/resources/db/migration"))) == ["V1__customer_and_pause.sql", "V2__seed.sql", "V3__customer_audit_columns.sql"], "Flyway's V1-V3, no V4")
    ok("ddl-auto: validate" in rd(A, "tiffinbox-web/src/main/resources/application.yaml"), "ddl-auto validate untouched")
    VALUES.append("C1 files 4 + README")
elif NAME == "r250":
    A = sys.argv[2]
    R = open(A + "/README.md", encoding="utf-8").read().splitlines()
    # each sentence C1 makes false (or leaves without the cache): a fragment of it, and the note that must sit on the same line
    FR = [("Course 8's units are planned to put a", "(Course 8, unit 08, **Section 2's first change to this folder**"),
          ("**Unchanged:** the 18 tests, the seven (the record and the JSON carry no stamp), the dashboard's four SQL statements.", "(Course 8, unit 08:"),
          ("dashboard's four SQL statements. *(Course 8, unit 08: the customer read among them is cached since — on a hit it sends none;", "(Course 8, unit 08:"),
          ("the database answers — with the customers it holds and the orders the kitchen cooked — and DOWN, with the error's class name,", "(Course 8, unit 08:"),
          ("liveness 200, **readiness 503**; `/customers` 500; `/kitchen` 200, from memory.", "(Course 8, unit 08:")]
    for f, note in FR:
        h = [k for k, l in enumerate(R) if f in l]
        ok(len(h) == 1, "R.250: the sentence is in the README once: " + f[:60])
        ok(bool(h) and note in R[h[0]], "R.250: its unit 08 note sits on its line: " + f[:60])
    ok(any(l.startswith("## Course 8 · unit 08 — ") for l in R), "the README's Course 8 · unit 08 section")
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
    ok(sorted(gained) == ["spring-boot-cache-4.1.2.jar", "spring-context-support-7.0.10.jar"], "the jars gained: %s" % gained)
    for t in ("before", "after"): ok(any(re.match(r"^  %s/: .* a PostgreSQL driver in lib/: postgresql-42\.7\.14\.jar$" % t, l) for l in L), t + "/'s jar carries its own PostgreSQL driver")
    dbs = []; VER = ("?",) * 6
    for h, body in S[1:]:
        db = [m.group(1) for m in (re.match(r"^PROBE started: yes · the database that answered: (.*)$", l) for l in body) if m]
        ok(len(db) == 1, "one database per JVM"); db = db[0] if db else "?"; dbs.append(db)
        dbline(body, db)
        ok(sum(1 for l in body if l == "  log: Multiple Spring Data modules found, entering strict repository configuration mode") == 2, "strict mode, once per module (%s)" % db)
        ok(sum(1 for l in body if l == "  log: Found 1 JPA repository interface") == 1 and sum(1 for l in body if l == "  log: Found 1 JDBC repository interface") == 1, "Found 1 JPA and Found 1 JDBC (%s)" % db)
        ok("  log: HHH000001: Hibernate ORM core version 7.4.13.Final" in body, "HHH000001 7.4.13.Final (%s)" % db)
        v = grab(body, r"^PROBE versions: Spring Boot (\S+) · Spring Framework (\S+) · Spring Data JPA (\S+) · Spring Data JDBC (\S+) · Hibernate (\S+) · Flyway \(version\.txt\) (\S+)$")
        ok(bool(v) and v[0].groups() == ("4.1.2", "7.0.10", "4.1.2", "4.1.2", "7.4.13.Final", "12.4.0"), "the version lines (R.246) on " + db)
        ok(bool(v) and ("  log: HHH000001: Hibernate ORM core version " + v[0].group(5)) in body, "Hibernate's version = HHH000001's")
        if v: VER = v[0].groups()
        ok("PROBE CacheManager beans 1 [cacheManager=org.springframework.cache.concurrent.ConcurrentMapCacheManager] (%s)" % db in body, "CacheManager beans 1, ConcurrentMapCacheManager (%s)" % db)
        ok(any(l.startswith("PROBE CustomerRepository's bean class: com.tiffinbox.CustomerRepository$$SpringCGLIB$$0 · advisors 2 [BeanFactoryCacheOperationSourceAdvisor(org.springframework.cache.interceptor.CacheInterceptor), BeanFactoryTransactionAttributeSourceAdvisor(org.springframework.transaction.interceptor.TransactionInterceptor)]") for l in body), "CustomerRepository: a CGLIB subclass, the cache and the transaction advisors (%s)" % db)
        ok(any(l.startswith("PROBE CustomerEntityRepository's bean: a Spring AOP proxy (Advised) · the counter installed: yes") for l in body), "the counter installed on Spring Data JPA's proxy (%s)" % db)
        st = grab(body, r"^PROBE the start's own read .*\((H2 2\.5\.250|PostgreSQL 18\.6)\): repository calls (\d+) · prepareStatementCount (\d+) · cache names \[\] \(no customers cache yet\)$")
        ok(bool(st) and st[0].group(2) == st[0].group(3), "the start's read: the two counters agree (%s)" % db)
        ok(any(l.startswith("  exit 0 · its log") for l in body), "exit 0 (%s)" % db)
    ok(dbs == ["H2 2.5.250", "PostgreSQL 18.6"], "H2 then PostgreSQL: %s" % dbs)
    VALUES.append("CacheManager org.springframework.cache.concurrent.ConcurrentMapCacheManager on H2 2.5.250 and PostgreSQL 18.6; libs %d -> %d (+%s); Boot %s · Framework %s · Spring Data JPA/JDBC %s/%s · HHH000001 %s · Flyway %s; Found 1 JPA + Found 1 JDBC" % ((lib["before"], lib["after"], ", ".join(gained)) + VER))
elif NAME == "hits":
    S = secs(sys.argv[2]); L = lines(sys.argv[2]); V2 = v2rows()
    got = {}
    for h, body in S:
        db = [m.group(1) for m in (re.match(r"^PROBE started: yes · the database that answered: (.*)$", l) for l in body) if m]
        if not db: continue
        db = db[0]; dbline(body, db); tr = "before" if h.startswith("-- A: before/") else "after"
        st = grab(body, r"^PROBE the start's own read .*: repository calls (\d+) · prepareStatementCount (\d+) · (.*)$")
        w = window(body, "hits: five calls of CustomerRepository.findAll()")
        if not w or not st: continue
        ok(w[4] == V2, "rows %d = V2's INSERT INTO customer lines %d (%s, %s)" % (w[4], V2, tr, db))
        if tr == "before":
            ok(w[3] == [1, 1, 1, 1, 1] and "PROBE CacheManager beans 0 [] (%s)" % db in body, "A (before/, %s): no CacheManager, every call reaches the repository" % db)
            ok(st[0].group(3) == "no CacheManager bean", "before/: no CacheManager bean")
            hl = grab(body, r"^PROBE health \(.*\): JdbcTemplate: alter table customer rename to customer_gone - then the kitchen, no CacheManager bean: (DOWN \{error=\w+\})$")
            got[(tr, db)] = (w, st[0].groups(), hl[0].group(1) if hl else "?")
        else:
            ok(w[3] == [1, 0, 0, 0, 0], "B (after/, %s): per call [1, 0, 0, 0, 0]" % db)
            ok(st[0].group(3) == "cache names [] (no customers cache yet)", "the start's read left the cache empty (%s)" % db)
            ok("PROBE hits: five calls of CustomerRepository.findAll(): the two witnesses' per-call lists equal · customers cache entries 1 [org.springframework.cache.interceptor.SimpleKey = SimpleKey []]" in body, "the cache's one key SimpleKey [] (%s)" % db)
            ok("PROBE clear: cacheManager.getCache(\"customers\").clear() · then customers cache entries 0 []" in body, "clear(): 0 entries (%s)" % db)
            c = window(body, "clear: the next two calls")
            ok(bool(c) and c[3] == [1, 0], "A' (%s): after clear() the next call reaches the repository again, then none" % db)
            hb = grab(body, r"^PROBE health \(.*\): the kitchen before, customers cache entries 1 .*: (UP \{customers=(\d+), ordersCooked=\d+\})$")
            hr = grab(body, r"^PROBE health \(.*\): JdbcTemplate: alter table customer rename to customer_gone - then the kitchen, customers cache entries 1 .*: (UP \{customers=(\d+), ordersCooked=\d+\})$")
            hc = grab(body, r"^PROBE health \(.*\): the customers cache cleared - then the kitchen, customers cache entries 0 \[\]: (DOWN \{error=\w+\})$")
            ok(bool(hr) and int(hr[0].group(2)) == V2, "the kitchen UP with the table gone, its count the cached list's (%s)" % db)
            got[(tr, db)] = (w, st[0].groups(), c, hr[0].group(1) if hr else "?", hc[0].group(1) if hc else "?")
    ok(sorted(got) == sorted([("before", "H2 2.5.250"), ("before", "PostgreSQL 18.6"), ("after", "H2 2.5.250"), ("after", "PostgreSQL 18.6")]), "four JVMs: before/ and after/ on both databases")
    pq = grab(L, r"^  psql \(a second client, PostgreSQL\), after the JVM stopped: tables (.*) · customers (\d+)$")
    ok(bool(pq) and int(pq[0].group(2)) == V2, "psql's count = V2's")
    if len(got) == 4:
        for tr in ("before", "after"):
            ok(got[(tr, "H2 2.5.250")][0][1:4] == got[(tr, "PostgreSQL 18.6")][0][1:4], "%s/: H2's window = PostgreSQL's (calls, statements, per call)" % tr)
        ok(got[("after", "H2 2.5.250")][2][3] == got[("after", "PostgreSQL 18.6")][2][3], "A': H2's = PostgreSQL's")
        a, b = got[("before", "PostgreSQL 18.6")], got[("after", "PostgreSQL 18.6")]
        VALUES.append("A before/ calls %d statements %d per call %s (H2 and PostgreSQL alike) · B after/ calls %d statements %d per call %s · A' clear() then %s · the start's read %s calls / %s statements, the cache empty · rows %d · the kitchen with the table renamed: before/ %s; after/ %s, cleared %s"
                      % (a[0][1], a[0][2], a[0][3], b[0][1], b[0][2], b[0][3], b[2][3], b[1][0], b[1][1], b[0][4], a[2], b[3], b[4]))
elif NAME == "evict":
    S = secs(sys.argv[2]); L = lines(sys.argv[2]); V2 = v2rows(); out = []
    for h, body in S:
        db = [m.group(1) for m in (re.match(r"^PROBE started: yes · the database that answered: (.*)$", l) for l in body) if m]
        if not db: continue
        db = db[0]; dbline(body, db)
        f0 = window(body, "evict: the read that fills the cache")
        ok(bool(f0) and f0[3] == [1] and f0[4] == V2, "evict: the read before add fills the cache (%s)" % db)
        b0 = grab(body, r"^PROBE evict: before add, customers cache entries 1 \[org\.springframework\.cache\.interceptor\.SimpleKey = SimpleKey \[\]\] · rows by JdbcTemplate .* (\d+)$")
        ad = grab(body, r"^PROBE evict: add\(Emma\) \(.*\): repository calls (\d+) · prepareStatementCount (\d+) · then customers cache entries 0 \[\]$")
        w = window(body, "evict: the next two calls")
        b1 = grab(body, r"^PROBE evict: rows by JdbcTemplate \(the second client\) (\d+)$")
        if not (b0 and ad and w and b1): continue
        ok(int(b0[0].group(1)) == V2 and w[4] == V2 + 1 == int(b1[0].group(1)), "rows %d -> %d, the read's = JdbcTemplate's (%s)" % (V2, w[4], db))
        ok(w[3] == [1, 0], "after the evict: the next call reaches the repository, the one after does not (%s)" % db)
        o1 = grab(body, r"^PROBE order \(.*\): inside add's transaction \(a listener on CustomerAdded\): transaction active true · customers cache entries 1 ")
        o2 = grab(body, r"^PROBE order \(.*\): after the commit, add not yet returned \(afterCommit\): customers cache entries 1 .* rows by JdbcTemplate (\d+) · a second thread's findAll\(\) there: rows (\d+) · repository calls 0 · prepareStatementCount 0$")
        o3 = grab(body, r"^PROBE order \(.*\): after add returned: customers cache entries 0 \[\]$")
        ow = window(body, "order: the next call")
        ok(bool(o2) and int(o2[0].group(1)) == V2 + 2 and int(o2[0].group(2)) == V2 + 1, "RE-MEASURE 2: after the commit the table holds one row more than the second thread's cached read (%s)" % db)
        out.append((db, int(ad[0].group(1)), int(ad[0].group(2)), w, o2[0].groups() if o2 else None))
    pq = grab(L, r"^  psql \(a second client, PostgreSQL\) after the JVM stopped: customers (\d+) · Emma, Oliver$")
    ok(bool(pq) and int(pq[0].group(1)) == V2 + 2, "psql: V2's rows + Emma + Oliver")
    ok([o[0] for o in out] == ["H2 2.5.250", "PostgreSQL 18.6"], "H2 then PostgreSQL")
    if len(out) == 2:
        VALUES.append("rows %d -> %d (JdbcTemplate; psql on PostgreSQL) · add: calls %d statements %d · the next two calls %s and %s · RE-MEASURE 2: after the commit, before add returned, the cache still held the list - a second thread read %s rows while the table held %s, on both databases" % (V2, V2 + 1, out[1][1], out[1][2], out[1][3][3], out[1][3][3], out[1][4][1], out[1][4][0]))
elif NAME == "put":
    L = lines(sys.argv[2])
    ok("PROBE started: yes · the database that answered: H2 2.5.250" in L, "H2")
    p = grab(L, r"^PROBE put: three @CachePut calls \(H2 2\.5\.250\): its method ran (\d+) · repository calls (\d+) · prepareStatementCount (\d+) · the customer cache \(org\.springframework\.cache\.concurrent\.ConcurrentMapCache, native java\.util\.concurrent\.ConcurrentHashMap\) holds \{Ravi=Customer\[name=Ravi, mealsPerDay=(\d), .*\]\}$")
    r = grab(L, r"^PROBE put: then @Cacheable byName\(\"Ravi\"\) on the same cache and key \(H2 2\.5\.250\): its method ran (\d+) · repository calls (\d+) · prepareStatementCount (\d+) · returned Customer\[name=Ravi, mealsPerDay=(\d),")
    d = grab(L, r"^PROBE put: the anchor's database row for Ravi by JdbcTemplate: meals_per_day (\d+)$")
    ok(any(l.startswith("PROBE put: a harness bean, not the anchor's cache") for l in L), "labelled a harness bean (R.392)")
    if p and r and d:
        ok(p[0].groups()[:3] == ("3", "0", "0") and p[0].group(4) == "3", "three puts ran three times, the cache holds the last (meals 3)")
        ok(r[0].groups() == ("0", "0", "0", "3"), "the read on the same key: 0 runs, 0 repository calls, 0 statements, the put's value")
        ok(d[0].group(1) != r[0].group(4), "the database row (second client) is not what the cache answered: %s vs %s" % (d[0].group(1), r[0].group(4)))
        VALUES.append("a harness bean, not the anchor's cache: @CachePut ran %s of 3 · the @Cacheable read on the same key ran %s, repository calls %s, statements %s, answered meals %s (the row by JdbcTemplate: %s) - H2" % (p[0].group(1), r[0].group(1), r[0].group(2), r[0].group(3), r[0].group(4), d[0].group(1)))
elif NAME == "off":
    S = secs(sys.argv[2]); out = []
    for h, body in S:
        db = [m.group(1) for m in (re.match(r"^PROBE started: yes · the database that answered: (.*)$", l) for l in body) if m]
        if not db: continue
        db = db[0]; dbline(body, db)
        ok("PROBE CacheManager beans 0 [] (%s)" % db in body, "off: CacheManager beans 0 (%s)" % db)
        ok(any(l == "PROBE CustomerRepository's bean class: com.tiffinbox.CustomerRepository$$SpringCGLIB$$0 · advisors 1 [BeanFactoryTransactionAttributeSourceAdvisor(org.springframework.transaction.interceptor.TransactionInterceptor)]" for l in body), "off: still a CGLIB subclass, for @Transactional - the cache advisor absent (%s)" % db)
        w = window(body, "hits: five calls of CustomerRepository.findAll()")
        ok(bool(w) and w[3] == [1, 1, 1, 1, 1], "off: five calls, every one reaches the repository (%s)" % db)
        ex = grab(body, r"^  exit (\d+) · its log, every line but the harness's own PROBE lines: lines naming a cache \(case-insensitive\) (\d+) · WARN (\d+) · ERROR (\d+)$")
        ok(bool(ex) and ex[0].group(1) == "0" and ex[0].group(2) == "0" and ex[0].group(4) == "0", "off: exit 0, no log line naming a cache, no ERROR (%s)" % db)
        warns = [l for l in body if l.startswith("  its WARN line: ")]
        ok(all("Flyway has been verified with" in l or "newer than" in l for l in warns), "off: the only WARN lines are Flyway's H2 version line, which after/ prints too (%s): %d" % (db, len(warns)))
        ok(not any(re.search(r"\w+Exception\b|threw", l) for l in body if not l.startswith("PROBE CustomerEntityRepository's advisors")), "off: no exception, no step threw (%s)" % db)
        out.append((db, w, ex[0].groups() if ex else None, len(warns)))
    ok([o[0] for o in out] == ["H2 2.5.250", "PostgreSQL 18.6"], "H2 then PostgreSQL")
    if len(out) == 2:
        VALUES.append("CacheManager beans 0 · CustomerRepository still CGLIB (TransactionInterceptor alone) · calls %d statements %d per call %s · exit 0 · log lines naming a cache 0 · ERROR 0 (H2 and PostgreSQL)" % (out[1][1][1], out[1][1][2], out[1][1][3]))
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
    ok(W == "20", "the spoken line is 20 words (the brief's): %s" % W)
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
    def wl(b):
        m = [re.search(r"repository calls (\d+) · prepareStatementCount (\d+) · per call " + LIST + " and " + LIST, l) for l in b]
        m = [x for x in m if x]
        return m[0] if len(m) == 1 else None
    a, b = wl(r), wl(s)
    ok(bool(a) and lst(a.group(3)) == lst(a.group(4)) == [1, 1, 1, 1, 1], "R.196: broken - the two counters per call [1, 1, 1, 1, 1]")
    ok(bool(b) and lst(b.group(3)) == lst(b.group(4)) == [1, 0, 0, 0, 0], "R.196: solved - the two counters per call [1, 0, 0, 0, 0]")
    ok("TiffinBox: exit 0" in r and "TiffinBox: exit 0" in s, "both exit 0 - the check is the counters, never the exit")
    ok("@EnableCaching lines in TiffinBoxApp.java: 0" in r and "@EnableCaching lines in TiffinBoxApp.java: 1" in s, "the broken tree lacks @EnableCaching, the solved one has it")
    if a and b:
        VALUES.append("the line %s words · broken %s/%s per call %s · solved %s/%s per call %s · exit 0 both" % (W, a.group(1), a.group(2), lst(a.group(3)), b.group(1), b.group(2), lst(b.group(3))))
else:
    print("FAIL no check named " + NAME); sys.exit(1)
for o in oks: print("ok " + o)
for f in fails: print("FAIL " + f)
print("VALUES " + "; ".join(VALUES))
sys.exit(1 if fails else 0)
