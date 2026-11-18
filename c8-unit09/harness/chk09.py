"""Unit 09's checks (python3 -I -B harness/chk09.py NAME ARGS...). Each capture's numbers are asserted against a second witness of the
same run - never a typed figure alone: the invocation counter against Hibernate's statement counter per call (R.375); the
CacheManager bean (getBeansOfType) against the class of the cache it hands out and that cache's native store; the setting the
harness read back (spring.cache.type) against the one the section passed; Redis's version by the JVM's connection against
redis-cli's (a second client); the database the harness named against Flyway's Database line; the five key shapes and the collision
on H2 against PostgreSQL's; the log's counts against the WARN lines printed. Prints ok/FAIL lines and one VALUES line; exits 1 on
any FAIL.
  static ANCHOR          the anchor and the harness, read off the files (the Dashboard line, the harness's annotations)
  wib CAPTURE FILE       the lines the exercise's block printed for FILE (bash's), for receipts.sh to compare with "What it prints"
  managers|keys|proxy|finalclass|exercise CAPTURE [...]"""
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
    ok(len(m) == n, "%d line(s) match %s (found %d)" % (n, rx[:90], len(m)))
    return m


LIST = r"\[([0-9, ]+)\]"
DBS = r"(H2 2\.5\.250|PostgreSQL 18\.6)"
def lst(s): return [int(x) for x in s.split(",")]


def window(L, label):
    """A counted window's line: calls, statements, the two per-call lists, what each call returned; asserted equal (R.375)."""
    m = grab(L, r"^PROBE " + re.escape(label) + r" \(" + DBS + r"\): repository calls (\d+) · prepareStatementCount (\d+) · per call " + LIST + " and " + LIST + r" · returned \[(.*)\]$")
    if not m: return None
    db, c, s, a, b, r = m[0].groups()
    a, b = lst(a), lst(b)
    ok(a == b, "R.375: %s on %s - the counter's per-call list %s = the statement counter's %s" % (label, db, a, b))
    ok(sum(a) == int(c) and sum(b) == int(s), "%s on %s: each total is the sum of its per-call list" % (label, db))
    eq = grab(L, r"^PROBE " + re.escape(label) + r": the two witnesses' per-call lists (equal|DIFFER)$")
    ok(bool(eq) and eq[0].group(1) == "equal", "%s on %s: the harness's own comparison says equal" % (label, db))
    return db, int(c), int(s), a, r.split(", ")


def jvm(body):
    """One JVM's lines: its database (= Flyway's), its exit line's counts, its WARN lines."""
    db = [m.group(1) for m in (re.match(r"^PROBE started: yes · the database that answered: (.*)$", l) for l in body) if m]
    fl = [l for l in body if l.startswith("  log: Database: ")]
    ex = [re.match(r"^  exit (\d+) · its log, every line but the harness's own PROBE lines: lines naming a cache \(case-insensitive\) (\d+) · WARN (\d+) · ERROR (\d+) · 'Public final method' (\d+) · 'Could not generate CGLIB subclass' (\d+) · 'final class' (\d+)$", l) for l in body]
    ex = [m for m in ex if m]
    ok(len(ex) == 1, "one exit line per JVM")
    e = tuple(int(x) for x in ex[0].groups()) if ex else (-1,) * 7
    warns = [l[len("  its WARN line: "):] for l in body if l.startswith("  its WARN line: ")]
    errs = [l for l in body if l.startswith("  its ERROR line: ")]
    ok(len(warns) == e[2] and len(errs) == e[3], "the WARN and ERROR lines printed = the log's counts (%d, %d)" % (e[2], e[3]))
    if db:
        want = "(H2 2.5)" if db[0].startswith("H2") else "(PostgreSQL 18.6)"
        ok(len(fl) == 1 and fl[0].endswith(want), "the harness's database %s = Flyway's Database line %s" % (db[0], fl))
        ok(sum(1 for l in body if l == "  log: Multiple Spring Data modules found, entering strict repository configuration mode") >= 2, "strict mode (%s)" % db[0])
        ok("  log: Found 1 JPA repository interface" in body and "  log: Found 1 JDBC repository interface" in body, "Found 1 JPA and Found 1 JDBC (%s)" % db[0])
        ok("  log: HHH000001: Hibernate ORM core version 7.4.13.Final" in body, "HHH000001 7.4.13.Final (%s)" % db[0])
        vl = [l for l in body if l.startswith("PROBE versions: ")]
        ok(vl == ["PROBE versions: Spring Boot 4.1.2 · Spring Framework 7.0.10 · Hibernate 7.4.13.Final"], "the version line (R.246): Boot 4.1.2, Framework 7.0.10, Hibernate = HHH000001's (%s)" % db[0])
    return (db[0] if db else None), e, warns


FLYWAY_H2 = "org.flywaydb.core.internal.database.base.Database : Using H2 2.5.250 which is newer than the version Flyway has been verified with. The latest verified version of H2 is 2.3.232."
NETTY = "io.netty.resolver.dns.DnsServerAddressStreamProviders : Can not find io.netty.resolver.dns.macos.MacOSDnsServerAddressStreamProvider"
FINWARN = "org.springframework.aop.framework.CglibAopProxy : Public final method [public final java.lang.String probe.u09.H09Final$Fin.fin(java.lang.String)] cannot get proxied via CGLIB, consider removing the final marker or using interface-based JDK proxies."


def other_warns(warns):
    return [w for w in warns if w != FLYWAY_H2 and not w.startswith(NETTY) and w != FINWARN]


VALUES = []
if NAME == "static":
    import os
    A = sys.argv[2]
    rd = lambda p: open(p, encoding="utf-8").read()
    dl = [l for l in rd(os.path.join(A, "tiffinbox-core/src/main/java/com/tiffinbox/Dashboard.java")).splitlines() if l.startswith("public final class")]
    ok(dl == ["public final class Dashboard {"], "the anchor's Dashboard is a public final class: %s" % dl)
    srcm = []
    for d, ds, fs in os.walk(A):
        for f in fs:
            if f.endswith(".java") and "/src/main/" in os.path.join(d, f) and re.search(r"(?m)^ *@Cacheable\b", rd(os.path.join(d, f))): srcm.append(f)
    ok(srcm == ["CustomerRepository.java"], "an @Cacheable line in the anchor's src/main: CustomerRepository.java alone (unit 08's) - none on Dashboard: %s" % srcm)
    H = rd("harness/src/probe/u09/H09.java")
    ok(H.count('@Cacheable(cacheNames = "h09:keys", key = "#a")') == 1 and H.count("@Cacheable(") == 9, "H09: nine @Cacheable methods, kSpel's key \"#a\" once")
    ok(re.search(r'@Cacheable\("h09:pkg"\)\n        String pkg\(', H) is not None and re.search(r'@Cacheable\("h09:priv"\)\n        private String priv\(', H) is not None, "H09: pkg is package-private, priv is private")
    ok("public String allViaSelf() {\n            return this.all();" in H, "H09: allViaSelf calls this.all()")
    ok(H.count("entities.count()") == 9, "H09: every @Cacheable body reads the database through CustomerEntityRepository (count())")
    F = rd("harness/src/probe/u09/H09Final.java")
    ok("public final String fin(String k)" in F and "ENTITIES.count()" in F, "H09Final: a public final @Cacheable method whose body reads the database")
    ok("    public static class Reads {\n" in rd("harness/src/probe/u09/FinalOne.java"), "FinalOne as shipped: Reads is not final (the control)")
    print("ok " + "\nok ".join(oks) if not fails else "\n".join("FAIL " + f for f in fails)); sys.exit(1 if fails else 0)
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
elif NAME == "managers":
    L = lines(sys.argv[2]); S = sections(L)
    rv = grab(L, r"^  the Redis container, by redis-cli \(a second client\): redis_version (\S+)$")
    RV = rv[0].group(1) if rv else "?"
    for t, names in (("caffeine", ["caffeine-3.2.4.jar"]), ("redis", ["lettuce-core-7.5.2.RELEASE.jar", "spring-data-redis-4.1.2.jar", "spring-boot-data-redis-4.1.2.jar"]), ("both", ["caffeine-3.2.4.jar", "lettuce-core-7.5.2.RELEASE.jar", "spring-data-redis-4.1.2.jar"])):
        g = grab(L, r"^  the %s copy's jar: (\d+) libraries \(the anchor's (\d+)\); gained, by name: (.*); lost: (\d+)$" % t)
        if g:
            gained = g[0].group(3).split()
            ok(int(g[0].group(1)) == int(g[0].group(2)) + len(gained) and g[0].group(4) == "0", "the %s copy: its libraries = the anchor's + the jars gained, none lost" % t)
            ok(all(n in gained for n in names), "the %s copy gained %s" % (t, names))
            ok(("caffeine-3.2.4.jar" in gained) == (t != "redis") and (any(x.startswith("lettuce-core") for x in gained)) == (t != "caffeine"), "the %s copy: Caffeine and Lettuce exactly where named" % t)
    ok(sum(1 for l in L if re.match(r"^  the (caffeine|redis|both) copy \(\.harness/\1\), derived from the anchor's file by harness/variants\.py - diff -rq against the anchor: tiffinbox-web/pom\.xml alone:$", l)) == 3, "three copies, each differing from the anchor in tiffinbox-web/pom.xml alone")
    FAM = {"org.springframework.cache.concurrent.ConcurrentMapCacheManager": ("org.springframework.cache.concurrent.ConcurrentMapCache", "java.util.concurrent.ConcurrentHashMap"),
           "org.springframework.cache.caffeine.CaffeineCacheManager": ("org.springframework.cache.caffeine.CaffeineCache", "com.github.benmanes.caffeine.cache."),
           "org.springframework.data.redis.cache.RedisCacheManager": ("org.springframework.data.redis.cache.RedisCache", "org.springframework.data.redis.cache.DefaultRedisCacheWriter"),
           "org.springframework.cache.support.NoOpCacheManager": ("org.springframework.cache.support.NoOpCache", "org.springframework.cache.support.NoOpCache")}
    runs = []
    for h, body in S[1:]:
        m = re.match(r"^-- \((\d)\) the (anchor|caffeine copy|redis copy|both copy)\b.*?, spring\.cache\.type[ =](unset|\w+) - H2 in memory", h)
        ok(bool(m), "a section names its class path and its setting: " + h[:80])
        if not m: continue
        path, ty = m.group(2).replace(" copy", ""), m.group(3)
        db, e, warns = jvm(body)
        ok(db == "H2 2.5.250", "H2 in memory (%s, %s)" % (path, ty))
        ok(e[0] == 0 and e[1] == 0 and e[3] == 0, "exit 0, no log line naming a cache, no ERROR (%s, %s)" % (path, ty))
        ok(not other_warns(warns), "the only WARN lines are Flyway's H2 version line and (with Redis) Netty's DNS line (%s, %s): %s" % (path, ty, other_warns(warns)))
        st = grab(body, r"^PROBE spring\.cache\.type: (\S+)$")
        ok(bool(st) and st[0].group(1) == ty, "spring.cache.type read back = the section's: %s" % ty)
        cb = grab(body, r"^PROBE CacheManager beans (\d+) \[cacheManager=(\S+)\]$")
        mg = grab(body, r"^PROBE managers: the CacheManager bean (\S+) · getCache\(\"h09:all\"\) (\S+) · its native cache (\S+)$")
        if not (cb and mg): continue
        cls = cb[0].group(2)
        ok(cb[0].group(1) == "1" and mg[0].group(1) == cls, "one CacheManager bean, the same class both ways (%s, %s)" % (path, ty))
        fam = FAM.get(cls)
        ok(bool(fam) and mg[0].group(2) == fam[0] and mg[0].group(3).startswith(fam[1]), "the manager's cache and its native store belong to it: %s -> %s over %s" % (cls, mg[0].group(2), mg[0].group(3)))
        redis = path in ("redis", "both")
        ok(("  log: Found 0 Redis repository interfaces" in body) == redis, "Found 0 Redis repository interfaces exactly where Spring Data Redis is on the class path (%s)" % path)
        rl = [x for x in (re.match(r"^PROBE managers: Spring Data Redis on the class path: (yes|no)(.*)$", l) for l in body) if x]
        ok(len(rl) == 1 and (rl[0].group(1) == "yes") == redis, "Spring Data Redis on the class path: %s (%s)" % (redis, path))
        if redis and rl:
            ok(rl[0].group(2) == " · its connection factory org.springframework.data.redis.connection.lettuce.LettuceConnectionFactory · 127.0.0.1:20482 · PING -> PONG · INFO server: redis_version " + RV, "Redis by the digest answered the JVM: Lettuce's factory, 127.0.0.1:20482, PONG, redis_version = redis-cli's %s (%s, %s)" % (RV, path, ty))
        w = None
        if "Redis" in cls:
            ok(any(l.startswith("PROBE managers: no counted window on Redis's manager here") for l in body), "no window on Redis's manager, said (%s)" % path)
        else:
            w = window(body, "managers: all() three times through " + cls.rsplit(".", 1)[1])
            if w: ok(w[3] == ([1, 1, 1] if "NoOp" in cls else [1, 0, 0]), "the window: %s -> %s" % (cls, w[3]))
        runs.append((path, ty, cls, w))
    want = [("anchor", "unset"), ("caffeine", "unset"), ("redis", "unset"), ("both", "unset"), ("both", "caffeine"), ("both", "simple"), ("both", "none")]
    ok([(r[0], r[1]) for r in runs] == want, "seven runs, in order: %s" % [(r[0], r[1]) for r in runs])
    if len(runs) == 7:
        c = {(r[0], r[1]): r[2] for r in runs}
        ok(c[("anchor", "unset")] == "org.springframework.cache.concurrent.ConcurrentMapCacheManager", "the starter alone -> ConcurrentMapCacheManager")
        ok(c[("caffeine", "unset")] == "org.springframework.cache.caffeine.CaffeineCacheManager", "+ Caffeine -> CaffeineCacheManager")
        ok(c[("redis", "unset")] == "org.springframework.data.redis.cache.RedisCacheManager", "+ Redis -> RedisCacheManager")
        ok(c[("both", "unset")] == c[("redis", "unset")] != c[("caffeine", "unset")], "S8.36: both on the class path -> the Redis copy's manager, not the Caffeine copy's")
        ok(c[("both", "caffeine")] == c[("caffeine", "unset")] and c[("both", "simple")] == c[("anchor", "unset")], "spring.cache.type=caffeine / simple on the both copy -> the Caffeine copy's / the anchor's manager")
        ok(c[("both", "none")] == "org.springframework.cache.support.NoOpCacheManager", "spring.cache.type=none -> NoOpCacheManager")
        n = runs[6][3]
        VALUES.append("H2 in memory, Redis by the digest (redis_version %s) where on the class path: the starter alone (unset) %s · + caffeine (unset) %s · + spring-boot-starter-data-redis (unset) %s · both (unset) %s · both, spring.cache.type=caffeine %s · =simple %s · =none %s - its window, three calls of a harness copy's cache: calls %d statements %d per call %s; %d distinct classes over seven runs"
                      % (RV, c[want[0]].rsplit(".", 1)[1], c[want[1]].rsplit(".", 1)[1], c[want[2]].rsplit(".", 1)[1], c[want[3]].rsplit(".", 1)[1], c[want[4]].rsplit(".", 1)[1], c[want[5]].rsplit(".", 1)[1], c[want[6]].rsplit(".", 1)[1],
                         n[1], n[2], n[3], len(set(c.values()))) if n else "?")
elif NAME == "keys":
    S = sections(lines(sys.argv[2])); got = []
    for h, body in S:
        db, e, warns = jvm(body)
        if not db: continue
        ok(e[0] == 0 and e[3] == 0 and not other_warns(warns), "exit 0, no ERROR, no WARN but Flyway's (%s)" % db)
        kg = grab(body, r"^PROBE keys: the KeyGenerator bean h09Keys: (.*)$")
        w = window(body, "keys: k0(), k1(\"a\"), k2(\"a\", 1), kName(\"a\"), kGen(\"a\") once each, one cache h09:keys")
        ok(bool(w) and w[3] == [1, 1, 1, 1, 1], "five methods, five keys: each call runs its method (%s)" % db)
        hd = grab(body, r"^PROBE keys: the cache org\.springframework\.cache\.concurrent\.ConcurrentMapCache over java\.util\.concurrent\.ConcurrentHashMap holds (\d+) entries$")
        ks = [m.group(1) for m in (re.match(r"^PROBE keys: native key (.*?)   \(its value (\w+):\d+\)$", l) for l in body) if m]
        vs = [m.group(1) for m in (re.match(r"^PROBE keys: native key .*?   \(its value (\w+):\d+\)$", l) for l in body) if m]
        ok(bool(hd) and int(hd[0].group(1)) == len(ks) == 5, "five entries, five native keys printed (%s)" % db)
        ok(vs == ["k0", "k1", "k2", "kGen", "kName"], "each key's value names its own method (%s): %s" % (db, vs))
        sh = dict(zip(vs, ks))
        ok(sh.get("k0") == "org.springframework.cache.interceptor.SimpleKey = SimpleKey []" and sh.get("k1") == "java.lang.String = a" and sh.get("k2") == "org.springframework.cache.interceptor.SimpleKey = SimpleKey [a, 1]"
           and sh.get("kName") == "java.lang.String = kName" and sh.get("kGen") == "java.lang.String = gen:kGen:[a]", "the five key shapes (%s): %s" % (db, sh))
        ok(bool(kg) and kg[0].group(1).startswith("h09Keys (gen:<method>:<arguments>)") and sh.get("kGen", "").endswith("= gen:kGen:[a]"), "the generator's key is the shape its own string form names (%s)" % db)
        pw = window(body, "pair: k1(\"a\") then kSpel(\"a\", 9), one cache h09:keys")
        pe = grab(body, r"^PROBE pair: then cache h09:keys entries (\d+) \[java\.lang\.String = a -> (k1:\d+)\]$")
        if pw and pe:
            ok(pw[3] == [1, 0], "S8.29: the collision - k1 runs, kSpel does not (%s)" % db)
            ok(pw[4][0].startswith("k1:") and pw[4][1] == pw[4][0], "the collision: kSpel(\"a\", 9) returned k1's value %s (%s)" % (pw[4], db))
            ok(pe[0].group(1) == "1" and pe[0].group(2) == pw[4][0], "the collision: one entry, under the key a, holding k1's value (%s)" % db)
        ok(e[1] == 0, "S8.29: no log line naming a cache (%s)" % db)
        ok(not any(re.search(r"\w+Exception\b|threw", l) for l in body), "S8.29: no exception, no step threw (%s)" % db)
        got.append((db, sh, pw, e))
    ok([g[0] for g in got] == ["H2 2.5.250", "PostgreSQL 18.6"], "H2 then PostgreSQL")
    if len(got) == 2 and got[0][2] and got[1][2]:
        ok(got[0][1] == got[1][1] and got[0][2][3] == got[1][2][3], "H2's key shapes and collision = PostgreSQL's")
        sh, pw, e = got[1][1], got[1][2], got[1][3]
        VALUES.append("five key shapes (H2 and PostgreSQL alike, ConcurrentMapCache over ConcurrentHashMap): k0() %s · k1(\"a\") %s · k2(\"a\", 1) %s · kName %s · kGen %s · the collision k1(\"a\") then kSpel(\"a\", 9): returned %s, calls %d statements %d per call %s, exit %d, exception none, log lines naming a cache %d"
                      % (sh["k0"], sh["k1"], sh["k2"], sh["kName"], sh["kGen"], " and ".join(pw[4]), pw[1], pw[2], pw[3], e[0], e[1]))
elif NAME == "proxy":
    S = sections(lines(sys.argv[2])); res = {}
    for h, body in S:
        db, e, warns = jvm(body)
        if not db: continue
        fin = "with H09Final" in h
        contrast = "the contrast" in h
        ok(e[0] == 0 and e[3] == 0, "exit 0, no ERROR (%s)" % h[3:60])
        ok(e[1] == 0, "no log line naming a cache (%s)" % h[3:60])
        ok(not other_warns(warns), "no WARN line but Flyway's H2 line and the final method's (%s): %s" % (h[3:60], other_warns(warns)))
        ok(not any(re.search(r"\w+Exception\b|threw", l) for l in body), "no exception, no step threw (%s)" % h[3:60])
        if not fin:
            bl = grab(body, r"^PROBE bean: the harness bean H09\.Reads \(a harness bean, not the anchor's cache\): its class (\S+) · advisors \(printed, not interpreted\) (.*)$")
            ok(bool(bl) and bl[0].group(1) == "probe.u09.H09$Reads$$SpringCGLIB$$0", "the bean is a CGLIB subclass (%s)" % db)
            a = window(body, "self: all() three times, called from outside the bean")
            s = window(body, "self: allViaSelf() three times - it calls this.all()")
            se = grab(body, r"^PROBE self: then cache h09:all entries (\d+) ", 2)
            pk = window(body, "pkg: the package-private @Cacheable pkg(\"k\") three times")
            pv = window(body, "priv: the private @Cacheable priv(\"k\") three times, through the public privViaPublic(\"k\")")
            pn = grab(body, r"^PROBE priv: then cache h09:priv: not made yet \(0 entries\)$")
            if a and s and pk and pv:
                ok(a[3] == [1, 0, 0], "all() from outside: one call runs, two are hits (%s)" % db)
                ok(s[3] == [1, 1, 1], "S8.29: allViaSelf: every call runs - the counter keeps counting (%s)" % db)
                ok(len(se) == 2 and se[0].group(1) == "1" and se[1].group(1) == "0", "the cache holds all()'s entry, and none after allViaSelf - never asked (%s)" % db)
                ok(pk[3] == [1, 0, 0], "package-private: cached (%s)" % db)
                ok(pv[3] == [1, 1, 1] and bool(pn), "S8.29: private through a public caller: every call runs, the cache never made (%s)" % db)
                ok(e[4] == 0, "C4 U23's second half: the self-call's JVM logs no 'Public final method' line, nor any line naming a cache (%s)" % db)
                res[("self", db)] = (bl[0].group(1) if bl else "?", bl[0].group(2) if bl else "?", a, s, pk, pv, e)
        else:
            fl = grab(body, r"^PROBE final: the harness bean H09Final\.Fin \(a harness bean, not the anchor's cache\): its class (\S+) · ")
            f = window(body, "final: the public final @Cacheable fin(\"k\") three times")
            fe = grab(body, r"^PROBE final: then cache h09:fin: not made yet \(0 entries\)$")
            if f:
                ok(f[3] == [1, 1, 1] and all(x.startswith("fin:repo-null:") for x in f[4]), "the final method runs every call, on the proxy - its field null (%s): %s" % (db, f[4]))
                if contrast:
                    ok(e[4] == 0 and db == "H2 2.5.250", "the contrast: with the harness's root at WARN, no 'Public final method' line (H2)")
                    res[("contrast", db)] = (f, e)
                else:
                    ok(e[4] == 1 and warns.count(FINWARN) == 1, "the final method's JVM: exactly one 'Public final method' WARN line, captured whole (%s)" % db)
                    res[("final", db)] = (f, e)
    ok(sorted(res) == sorted([("self", "H2 2.5.250"), ("self", "PostgreSQL 18.6"), ("final", "H2 2.5.250"), ("final", "PostgreSQL 18.6"), ("contrast", "H2 2.5.250")]), "five JVMs: self and final on both databases, the contrast on H2: %s" % sorted(res))
    if len(res) == 5:
        h2, pg = res[("self", "H2 2.5.250")], res[("self", "PostgreSQL 18.6")]
        ok([x[3] for x in h2[2:6]] == [x[3] for x in pg[2:6]] and res[("final", "H2 2.5.250")][0][3] == res[("final", "PostgreSQL 18.6")][0][3], "H2's per-call lists = PostgreSQL's")
        f = res[("final", "PostgreSQL 18.6")][0]
        VALUES.append("the harness bean %s, advisors %s (H2 and PostgreSQL alike) · all() x3 calls %d statements %d %s · allViaSelf() x3 calls %d statements %d %s, the cache's entries after it 0 · package-private x3 %d %s · private x3 %d %s · public final x3 %d %s, returned %s · 'Public final method' WARN lines: the final method's JVM 1, the self-call's 0; with the harness's root at WARN 0 · exit 0, no exception, log lines naming a cache 0 in every JVM"
                      % (pg[0], pg[1], pg[2][1], pg[2][2], pg[2][3], pg[3][1], pg[3][2], pg[3][3], pg[4][1], pg[4][3], pg[5][1], pg[5][3], f[1], f[3], f[4][0]))
elif NAME == "finalclass":
    L = lines(sys.argv[2]); S = sections(L)
    dl = grab(L, r"^  Dashboard\.java:(\d+):public final class Dashboard \{$")
    ca = grab(L, r"^  an @Cacheable line \(an annotation, not a comment\) in the anchor's src/main: (.*)$")
    ok(bool(ca) and ca[0].group(1) == "tiffinbox-core/src/main/java/com/tiffinbox/CustomerRepository.java", "@Cacheable in the anchor: CustomerRepository alone - none on Dashboard")
    ctl = cp = None
    for h, body in S:
        if "the control" in h:
            db, e, warns = jvm(body)
            w = window(body, "fclass: its @Cacheable read(\"k\") three times")
            bl = grab(body, r"^PROBE fclass: the harness bean FinalOne\.Reads \(a harness bean, not the anchor's cache\): its class (\S+) · ")
            ok(db == "H2 2.5.250" and e[0] == 0 and bool(w) and w[3] == [1, 0, 0] and bool(bl) and bl[0].group(1) == "probe.u09.FinalOne$Reads$$SpringCGLIB$$0", "the control starts, its bean a CGLIB subclass, its read cached")
            ctl = (w, e)
        elif "the copy" in h:
            st = grab(body, r"^PROBE started: no · (\S+)$")
            ch = [l[len("PROBE   its cause chain: "):] for l in body if l.startswith("PROBE   its cause chain: ")]
            ex = [re.match(r"^  exit (\d+) · .* 'Public final method' (\d+) · 'Could not generate CGLIB subclass' (\d+) · 'final class' (\d+)$", l) for l in body]
            ex = [m for m in ex if m]
            ok(bool(st) and st[0].group(1) == "org.springframework.beans.factory.BeanCreationException", "the copy: the start stops, BeanCreationException")
            ok(bool(ex) and ex[0].group(1) == "1" and int(ex[0].group(3)) >= 1 and int(ex[0].group(4)) >= 1, "the copy: exit 1; the log names 'Could not generate CGLIB subclass' and 'final class'")
            ok(any("Could not generate CGLIB subclass of class probe.u09.FinalOne$Reads" in c for c in ch) and any(c.startswith("java.lang.IllegalArgumentException: Cannot subclass final class probe.u09.FinalOne$Reads") for c in ch), "the cause chain: Could not generate CGLIB subclass ... -> Cannot subclass final class")
            ok(not any(l.startswith("PROBE fclass:") for l in body), "no window ran on the copy")
            ok(any(l.startswith("  its ERROR line: org.springframework.boot.SpringApplication : Application run failed") for l in body), "Boot's own ERROR line: Application run failed")
            cp = (st[0].group(1) if st else "?", ch, ex[0].groups() if ex else None)
    if ctl and ctl[0] and cp and cp[2] and dl:
        VALUES.append("H2 in memory: FinalOne as shipped (Reads not final) starts, read x3 per call %s · the copy with Reads final: the start stops - %s, exit %s, the log's 'Could not generate CGLIB subclass' lines %s and 'final class' lines %s, the cause %s · the anchor's Dashboard.java:%s public final class, no @Cacheable on it"
                      % (ctl[0][3], cp[0], cp[2][0], cp[2][2], cp[2][3], cp[1][-1].split(":")[0], dl[0].group(1)))
elif NAME == "exercise":
    L = lines(sys.argv[2]); W, Q = sys.argv[3], sys.argv[4]
    ok(W == "21", "the spoken line is 21 words (the brief's): %s" % W)
    blocks = {}
    cur = None; sh = None
    for l in L:
        if l.startswith("in bash") or l.startswith("in zsh"): sh = l.split()[1]
        if "the README's lines" in l: cur = (sh, "readme"); blocks[cur] = []; continue
        if "then the solution's lines" in l: cur = (sh, "sol"); blocks[cur] = []; continue
        if l.startswith("  the shell is now in"): cur = None; continue
        if cur: blocks[cur].append(l.strip())
    ok(blocks.get(("bash", "readme")) == blocks.get(("zsh", "readme")) and blocks.get(("bash", "sol")) == blocks.get(("zsh", "sol")), "bash and zsh print the same")
    r, s = blocks.get(("bash", "readme"), []), blocks.get(("bash", "sol"), [])
    def wl(b):
        m = [re.search(r"repository calls (\d+) · prepareStatementCount (\d+) · per call " + LIST + " and " + LIST + r" · returned \[(.*)\]$", l) for l in b]
        m = [x for x in m if x]
        return m[0] if len(m) == 1 else None
    a, b = wl(r), wl(s)
    ok(bool(a) and lst(a.group(3)) == lst(a.group(4)) == [1, 0] and a.group(5).split(", ")[1] == a.group(5).split(", ")[0], "RE-MEASURE 4, broken: kSpel answers with k1's value, one call runs")
    ok(bool(b) and lst(b.group(3)) == lst(b.group(4)) == [1, 1] and b.group(5).split(", ")[0].startswith("k1:") and b.group(5).split(", ")[1].startswith("kSpel:"), "RE-MEASURE 4, solved: each method its own value, both calls run")
    ok("TiffinBox: exit 0" in r and "TiffinBox: exit 0" in s, "both exit 0 - the check is the values and the counter, never the exit (R.196)")
    ok('kSpel\'s @Cacheable: @Cacheable(cacheNames = "h09:keys", key = "#a")' in r and 'kSpel\'s @Cacheable: @Cacheable(cacheNames = "h09:keys", key = "#root.methodName + \':\' + #a")' in s, "the broken source names the key #a, the solved one the method's name and #a")
    if a and b:
        VALUES.append("the line %s words · broken (key \"#a\"): returned %s, calls %s statements %s per call %s · solved (key \"#root.methodName + ':' + #a\"): returned %s, calls %s statements %s per call %s · exit 0 both, H2 in memory"
                      % (W, a.group(5), a.group(1), a.group(2), lst(a.group(3)), b.group(5), b.group(1), b.group(2), lst(b.group(3))))
else:
    print("FAIL no check named " + NAME); sys.exit(1)
for o in oks: print("ok " + o)
for f in fails: print("FAIL " + f)
print("VALUES " + "; ".join(VALUES))
sys.exit(1 if fails else 0)
