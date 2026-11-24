"""Unit 27's checks (python3 -I -B harness/chk27.py NAME ARG...), each re-deriving its numbers from a capture or from the shipped files,
never from the README's prose; every check prints "ok ..." or "FAIL ...", and one "VALUES ..." line (what the video may say), and exits 1
on a FAIL. A capture line it cannot parse is a FAIL of its own, never a traceback: every listing line it reads is parsed by a named
pattern or skipped by a named rule, and any error while reading ends in a FAIL line and exit 1 (unit 25's defect class, closed in 26
and kept). "show" lists a JVM's raw files as the capture prints them (the receipt masks them); the other names check a capture. Names:
  static AFTER BEFORE  s827.py's two slices md5-equal (the family base, XFAM_S5 + TIMEPAT_S5 as chk25.py pins it), no XEXEMPT_S5;
                  tree27.py's code = tree26.py's; the harness prints "the harness's" alone; no configuration class named as its
                  @Bean method; the five IT files' change; the stale sentences each noted (R.250/R.453)
  show runs|tour|copies|default|absent|twocaches DIR...   the listing of a JVM's raw files
  runs F · tour F · copies F · default F · absent F · twocaches F · seven F MD5 · bound F IP · exercise F W Q · wib F FILE · readme R V"""
import hashlib, json, os, re, sys, calendar, time

HERE = os.path.dirname(os.path.abspath(__file__)); U = os.path.dirname(HERE); REPO = os.path.dirname(U)
FAILS = []; VALUES = []
TD = "tiffinbox-web/src/test/java/com/tiffinbox/"
ITS = [("CustomerEntityRepositoryIT", "", "bindIp"), ("CustomerAggregatesIT", "jdbc/", "bindIp"), ("RedisDatastoreIT", "web/", "bindIp"),
       ("MongoDatastoreIT", "web/", "bindIpAndPort"), ("ElasticsearchIT", "web/", "bindIpAndPort")]
TOUR = ["c1", "c2", "lb", "menu", "rev", "search", "kitchen", "patch", "delete"]
COPY = ["addc", "c3", "addd", "search2"]
ALLOW = ["?"]


def ok(c, msg):
    print(("ok " if c else "FAIL ") + msg)
    if not c: FAILS.append(msg)


def rd(p): return open(p, encoding="utf-8", errors="replace").read()


def md5(s): return hashlib.md5(s.encode()).hexdigest()


def lines(p): return rd(p).splitlines()


def code(t): return re.sub(r"//[^\n]*", "", re.sub(r"(?s)/\*.*?\*/", "", t))


# ---- static --------------------------------------------------------------------------------------------------------------------
def static(after, before):
    s7 = rd(os.path.join(HERE, "s827.py")).split("\n"); s5 = rd(os.path.join(REPO, "c8-unit25", "harness", "s825.py")).split("\n")
    ok(s7[9].startswith("import hashlib") and md5("\n".join(s7[9:403])) == md5("\n".join(s5[9:403])), "s827.py's lines 10-403 = s825.py's lines 10-403 (the family base), byte for byte (md5 %s)" % md5("\n".join(s7[9:403])))
    pin = re.search(r'^XFAM5B_SLICE_MD5 = "([0-9a-f]{32})"', rd(os.path.join(REPO, "c8-unit25", "harness", "chk25.py")), re.M)
    b7 = "\n".join(s7[408:524])
    ok(pin is not None and s7[408].startswith("MOD = ") and md5(b7) == pin.group(1), "s827.py's lines 409-524 (XFAM_S5 + TIMEPAT_S5) = the slice ../c8-unit25/harness/chk25.py pins (md5 %s, read off it)" % md5(b7))
    ok(re.search(r"^XEXEMPT_S5\s*=", "\n".join(s7), re.M) is None, "no XEXEMPT_S5 in s827.py")
    t7 = rd(os.path.join(HERE, "tree27.py")).split('"""', 2)[2]; t6 = rd(os.path.join(REPO, "c8-unit26", "harness", "tree26.py")).split('"""', 2)[2]
    ok(t7 == t6, "tree27.py's code = tree26.py's, byte for byte (only the docstring differs)")
    for f in ("CacheBeans", "TwoCaches"):
        j = code(rd(os.path.join(HERE, "src", "probe", "u27", f + ".java")))
        pr = re.findall(r'System\.out\.println\("([^"]*)', j)
        ok(len(pr) >= 1 and all(p.startswith("the harness's ") for p in pr), "%s.java: every line it prints begins \"the harness's\" (%d print call(s))" % (f, len(pr)))
        bm = re.findall(r"@Bean\s+(?:[\w<>?, ]+\s)?(\w+)\(", j); cb = f[0].lower() + f[1:]
        ok(bm and cb not in bm, "%s.java: the configuration's bean name (%s) is none of its @Bean methods' (%s) - unit 25's lesson" % (f, cb, ", ".join(bm)))
    ex = code(rd(os.path.join(U, "exercise", "LocalCacheConfig.java")))
    eb = re.findall(r"@Bean\s+(?:[\w<>?, ]+\s)?(\w+)\(", ex); ec = re.search(r"public class (\w+)", ex)
    ok(ec is not None and eb == ["localCaches"] and (ec.group(1)[0].lower() + ec.group(1)[1:]) not in eb, "the exercise's %s: its bean name is not its @Bean method's (localCaches)" % (ec.group(1) if ec else "?"))
    for cls, sub, form in ITS:
        a = rd(os.path.join(after, TD + sub + cls + ".java")); b = rd(os.path.join(before, TD + sub + cls + ".java"))
        n = a.count('bindIp("127.0.0.1")') if form == "bindIp" else a.count('bindIpAndPort("127.0.0.1"')
        ok(n == 1 and a.count('System.out.println("IT BINDINGS ' + cls + ' "') == 1 and "@BeforeAll" in a and "import org.junit.jupiter.api.BeforeAll;" in a,
           "%s: %s(\"127.0.0.1\"...) once, one IT BINDINGS %s line from an @BeforeAll" % (cls, form, cls))
        if form == "bindIp":
            ok(b.count("withCreateContainerCmdModifier") == 0 and all(("import com.github.dockerjava.api.model.%s;" % x) in a for x in ("ExposedPort", "PortBinding", "Ports")) and "Course 8, unit 27: the container's port is published on 127.0.0.1 alone" in a,
               "%s: before/ had no modifier; after/ imports ExposedPort, PortBinding, Ports and its Javadoc gains the unit 27 paragraph" % cls)
        rest = lambda t: re.sub(r"(?s)\n \*\n \* <p>Course 8, unit 27:.*?(?=\n \*/)", "", t)
        ok(len(rest(a).split("\n")) > len(rest(b).split("\n")) and not [l for l in b.split("\n") if l.strip() and l not in a.split("\n") and "asCompatibleSubstituteFor" not in l and "withExposedPorts(6379)" not in l],
           "%s: every line of before/'s file is still in after/'s (but the container's closing line)" % cls)
    rm = rd(os.path.join(after, "README.md")).split("\n"); bad = []
    c0 = next((k for k, l in enumerate(rm) if l.startswith("## Course 8 · unit 27 ")), len(rm)); c1 = next((k for k in range(c0 + 1, len(rm)) if rm[k].startswith("## ") or rm[k] == "---"), len(rm))
    for i, l in enumerate(rm):
        if c0 <= i < c1: continue   # rule: unit 27's own card names what it changes
        if "every interface unless the test names the address" in l and not any("unit 27" in rm[k] for k in range(i, min(len(rm), i + 2))): bad.append("every interface:%d" % (i + 1))
    n27 = sum(l.count("unit 27 binds it to") for l in rm) + sum(1 for k in range(len(rm) - 1) if rm[k].endswith("unit 27 binds it to") )
    ok(not bad, "R.250/R.453: every README line saying Testcontainers publishes on every interface carries its unit 27 note (stale: %s)" % (bad or "none"))
    ok(sum(1 for l in rm if re.search(r"unit 27 binds it to(?:\s*$| 127\.0\.0\.1)", l)) == 3, "the three rebound ITs' cards each carry \"(Course 8, unit 27 binds it to 127.0.0.1)\" (%d)" % sum(1 for l in rm if re.search(r"unit 27 binds it to(?:\s*$| 127\.0\.0\.1)", l)))
    ok(c0 < len(rm), "README.md holds unit 27's card")
    VALUES.append("the family base and XFAM_S5 carried md5-equal; the five ITs' change and the stale sentences each noted")


# ---- the raw readers (show) ----------------------------------------------------------------------------------------------------
def ts_pg(l):
    m = re.match(r"^(\d{4})-(\d\d)-(\d\d) (\d\d):(\d\d):(\d\d)\.(\d+) UTC", l)
    return calendar.timegm(tuple(int(x) for x in m.groups()[:6]) + (0, 0, 0)) + float("0." + m.group(7)) if m else None


def ts_jvm(l):
    m = re.match(r"^(\d{4})-(\d\d)-(\d\d)T(\d\d):(\d\d):(\d\d)\.(\d+)([+-])(\d\d):(\d\d)", l)
    if not m: return None
    t = calendar.timegm(tuple(int(x) for x in m.groups()[:6]) + (0, 0, 0)) + float("0." + m.group(7))
    off = (int(m.group(9)) * 60 + int(m.group(10))) * 60
    return t - off if m.group(8) == "+" else t + off


def window(L, lab, keep):
    out, on = [], False
    for l in L:
        if ("S27MARK-%s-begin" % lab) in l: on = True; continue
        if ("S27MARK-%s-end" % lab) in l: break
        if on and keep(l): out.append(l)
    return out


PGST = re.compile(r"LOG:\s+(?:statement|execute [^:]*):\s?(.*)$")


def pg_of(D, lab):
    raw = window(lines(os.path.join(D, "pg.log")), lab, lambda l: PGST.search(l) is not None)
    full = [(ts_pg(l), PGST.search(l).group(1).strip()) for l in raw]
    return [x for x in full if x[1]], len(raw)


RD = re.compile(r'^(\d+\.\d+) \[\d+ [^\]]+\] (.*)$')


def redis_of(D, lab):
    out = []
    for l in window(lines(os.path.join(D, "monitor.txt")), lab, lambda l: RD.match(l) is not None):
        m = RD.match(l); out.append((float(m.group(1)), m.group(2)))
    return out


ESR = re.compile(r"curl -iX (\w+) '[a-z]+://[^/']+(/[^']*)'")


def es_of(D, lab):
    p = os.path.join(D, lab + ".es"); out = []
    if os.path.exists(p):
        for l in lines(p):
            m = ESR.search(l)
            if m: out.append((ts_jvm(l), m.group(1) + " " + m.group(2)))
    return out


def prof_of(D, lab):
    p = os.path.join(D, lab + ".prof")
    t = rd(p).strip() if os.path.exists(p) else "[]"
    return json.loads(t) if t.startswith("[") else []


def reqs(D):
    out = {}
    for l in lines(os.path.join(D, "reqs.txt")):
        p = l.split(" ")
        if len(p) >= 4: out[p[0]] = p[1:]
    return out


def hdr(D, lab, name):
    p = os.path.join(D, lab + ".hdr")
    if not os.path.exists(p): return ""
    m = re.findall(r"^%s:\s*(.*?)\r?$" % name, rd(p), re.M | re.I)
    if m and name == "Allow": return ", ".join(sorted(x.strip() for x in m[-1].split(",")))   # rule: the header's order is the JVM's set order - it differs between JVMs, so it is printed sorted
    return m[-1] if m else ""


def body(D, lab, n=600):
    p = os.path.join(D, lab + ".body")
    return re.sub(r"\s+", " ", rd(p))[:n] if os.path.exists(p) else ""


def harness_lines(D): return [l for l in lines(os.path.join(D, "jvm.log")) if l.startswith("the harness's ")]


def caffeine(D):
    p = os.path.join(D, "classload.txt"); names = []
    for l in (lines(p) if os.path.exists(p) else []):
        m = re.search(r"\] (com\.github\.benmanes\.caffeine\.\S+) source:", l)
        if m: names.append(re.sub(r"/0x[0-9a-f]+$", "/<address>", m.group(1)))   # rule: a lambda's hidden class carries the JVM's address - masked
    return sorted(names)


def show_runs(D, F):
    for nm, d, port in (("under dev", D, "20660"), ("the default run", F, "20665")):
        print("== %s (%s): exit %s · listening on: %s" % (nm, port, rd(os.path.join(d, "exit")).strip(), rd(os.path.join(d, "listen")).strip()))
        for l in harness_lines(d):
            if l.startswith("the harness's CacheManager beans") or l.startswith("the harness's cache customers in"): print("  " + l)
        c = caffeine(d)
        print("  Caffeine classes loaded (the JVM's own -Xlog:class+load file, its com.github.benmanes.caffeine lines): %d - %s" % (len(c), ", ".join(x.replace("com.github.benmanes.caffeine.", "") for x in c)))


def row(D, lab, R):
    m, p, c = (R.get(lab, ["?", "?", "?"]) + ["?", "?", "?"])[:3]
    pg, praw = pg_of(D, lab); rs = redis_of(D, lab); es = es_of(D, lab); pf = prof_of(D, lab)
    print("== %s %s %s -> %s · PostgreSQL %d (non-empty statements; raw %d) · Redis %d · MongoDB %d · Elasticsearch %d" % (lab, m, p, c, len(pg), praw, len(rs), len(pf), len(es)))
    for t, s in pg: print("   pg     " + s[:150])
    for t, s in rs: print("   redis  " + s[:120])
    for d in pf: print("   mongo  %s %s on %s · nreturned %s · docsExamined %s" % (d.get("op"), d.get("cmd"), d.get("ns"), d.get("nreturned"), d.get("docsExamined")))
    for t, s in es: print("   es     " + s[:120])
    a = hdr(D, lab, "Allow"); ct = hdr(D, lab, "Content-Type")
    print("   answer %s%s · %s" % ("Allow (sorted): %s · " % a if a else "", "Content-Type: " + ct if ct else "no body", body(D, lab)))
    return pg, rs, es, pf


def show_tour(D):
    R = reqs(D)
    print("-- tour: the dev JVM on 20660, one request at a time; each between its own markers in PostgreSQL's log and in Redis's MONITOR, MongoDB's profiler on for that call alone, the client's trace by the JVM log's line numbers:")
    print("  before the first: redis-cli DEL 'customers::SimpleKey []' -> %s (the start and the readiness check had cached the list - RED #3)" % rd(os.path.join(D, "del.txt")).strip())
    for lab in TOUR: row(D, lab, R)


def short(store, s):
    if store == "PostgreSQL":
        w = s.split(); return " ".join(w[:3]) if w[:2] == ["insert", "into"] else " ".join(w[:3]) if w[:1] == ["BEGIN"] else w[0] if w else s
    if store == "Redis":
        q = re.findall(r'"((?:[^"\\]|\\.)*)"', s); return " ".join(q[:2]) if q else s
    return s.split("?")[0] + ("?" + s.split("?")[1] if "?refresh" in s else "")


def show_copies(D):
    R = reqs(D)
    print("-- copies: the same dev JVM after the tour's reads; each write between its own markers, then the read after it:")
    for lab in COPY:
        pg, rs, es, pf = row(D, lab, R)
        if lab in ("addc", "addd"):
            ev = [(t, "PostgreSQL", short("PostgreSQL", s)) for t, s in pg] + [(t, "Redis", short("Redis", s)) for t, s in rs] + [(t, "Elasticsearch", short("Elasticsearch", s)) for t, s in es]
            ev = [e for e in ev if e[0] is not None]; ev.sort(key=lambda e: e[0])
            print("   the witnesses' order (each event placed by its own log's clock; the times not printed): " + " · ".join("%s %s" % (e[1], e[2]) for e in ev))
    print("  the writers, read off the running context (the harness's CacheBeans):")
    for l in harness_lines(D):
        if l.startswith("the harness's cache customers in") or l.startswith("the harness's listeners") or l.startswith("the harness's   bean "): print("    " + l)


def show_default(F):
    R = reqs(F)
    print("-- default: the default run's JVM on 20665 (H2 in memory, Caffeine), one request at a time; Hibernate's SQL logger's lines (the harness's logback) by the JVM log's line numbers:")
    for l in harness_lines(F):
        if l.startswith("the harness's CacheManager beans"): print("  " + l)
    for lab in ["addc", "c1", "c2", "lb", "menu", "rev", "search", "addd", "patch", "delete", "cust", "apidocs", "swagger"]:
        v = R.get(lab, ["?", "?", "?", "?"])
        a = hdr(F, lab, "Allow"); ct = hdr(F, lab, "Content-Type")
        print("== %s %s %s -> %s · Hibernate SQL lines %s · %s%s · %s" % (lab, v[0], v[1], v[2], v[3] if len(v) > 3 else "?", "Allow (sorted): %s · " % a if a else "", "Content-Type: " + ct if ct else "no body", body(F, lab, 150)))
        if lab == "addc":
            print("  /actuator/prometheus, cache_gets_total for customers, before the two reads: " + " · ".join(x.split("{", 1)[1].replace('"', "") for x in lines(os.path.join(F, "prom-before.txt"))))
        if lab == "c2":
            print("  /actuator/prometheus, cache_gets_total for customers, after them: " + " · ".join(x.split("{", 1)[1].replace('"', "") for x in lines(os.path.join(F, "prom-after.txt"))))


def chain_of(L):
    w = next((l for l in L if "Error creating bean with name" in l), "")
    names = []
    for a, b in re.findall(r"Error creating bean with name '([^']+)'|dependency '([^']+)'", w):
        n = a or b
        if n not in names: names.append(n)
    return w, names


def show_absent(O):
    L = lines(os.path.join(O, "jvm.log")); w, names = chain_of(L)
    print("  exit %s · 'Started TiffinBoxServer' %d · 'Application run failed' %d · 'APPLICATION FAILED TO START' %d · Flyway's lines (applied / up to date) %d" % (
        rd(os.path.join(O, "exit")).strip(), sum("Started TiffinBoxServer" in l for l in L), sum("Application run failed" in l for l in L), sum("APPLICATION FAILED TO START" in l for l in L),
        sum(bool(re.search(r"Successfully applied \d+ migration|is up to date", l)) for l in L)))
    print("  the chain's first two beans: %s" % " <- ".join(names[:2]))
    print("  the first 'Error creating bean with name' line, from its exception's name: " + (w[w.find("org.springframework.beans.factory."):] if "org.springframework.beans.factory." in w else w))
    for l in [l for l in L if l.startswith("Caused by: ")][-2:]: print("  " + l)


def show_twocaches(O):
    L = lines(os.path.join(O, "jvm.log")); w, names = chain_of(L)
    d = next((L[k + 2] for k, l in enumerate(L) if l.strip() == "Description:" and k + 2 < len(L)), "")
    print("  exit %s · 'Started TiffinBoxServer' %d · 'APPLICATION FAILED TO START' %d · 'Application run failed' %d" % (
        rd(os.path.join(O, "exit")).strip(), sum("Started TiffinBoxServer" in l for l in L), sum("APPLICATION FAILED TO START" in l for l in L), sum("Application run failed" in l for l in L)))
    print("  the harness's TwoCaches lines in the log: %d (the bean's definition is in the context; its method never ran - the start stopped first)" % sum(l.startswith("the harness's TwoCaches") for l in L))
    print("  the first exception's class and bean: %s · %s" % ((re.search(r"org\.springframework\.beans\.factory\.\w+", w) or re.search("x^", "")) and re.search(r"org\.springframework\.beans\.factory\.\w+", w).group(0), " <- ".join(names[:2])))
    print("  Description: " + d)


# ---- the checks ----------------------------------------------------------------------------------------------------------------
def grab(L, rx, name):
    m = [re.match(rx, l) for l in L]; m = [x for x in m if x]
    ok(len(m) == 1, "%s: one line (%d found)" % (name, len(m)))
    return m[0] if len(m) == 1 else None


def runs(p):
    L = lines(p)
    d = grab(L, r"^== under dev \(20660\): exit (\d+) · listening on: (.*)$", "the dev JVM's line")
    f = grab(L, r"^== the default run \(20665\): exit (\d+) · listening on: (.*)$", "the default JVM's line")
    ok(d is not None and d.group(1) == "0" and d.group(2) == "127.0.0.1:20660", "dev: exit 0 after POST /shutdown, listening on 127.0.0.1:20660 alone")
    ok(f is not None and f.group(1) == "0" and f.group(2) == "127.0.0.1:20665", "the default run: exit 0, listening on 127.0.0.1:20665 alone")
    cm = [re.match(r"^  the harness's CacheManager beans (\d+): \[(\w+) = ([\w.]+) caches \[(.*)\]\]$", l) for l in L if l.startswith("  the harness's CacheManager beans")]
    ok(len(cm) == 2 and all(cm), "two CacheManager lines, one per run, each parsed")
    if len(cm) == 2 and all(cm):
        ok(cm[0].group(1) == "1" and cm[0].group(3) == "org.springframework.data.redis.cache.RedisCacheManager", "dev: ONE CacheManager bean, %s (%s)" % (cm[0].group(3).split(".")[-1], cm[0].group(2)))
        ok(cm[1].group(1) == "1" and cm[1].group(3) == "org.springframework.cache.caffeine.CaffeineCacheManager", "the default run: ONE CacheManager bean, %s" % cm[1].group(3).split(".")[-1])
        ok(cm[0].group(4) == "customer, customers" and cm[1].group(4) == "customer, customers", "both runs' cache names [customer, customers] (read)")
    cf = []
    for l in L:
        m = re.match(r"^  Caffeine classes loaded \(the JVM's own -Xlog:class\+load file, its com\.github\.benmanes\.caffeine lines\): (\d+) - (.*)$", l)
        if l.startswith("  Caffeine classes loaded"): ok(m is not None, "a Caffeine class-load line parsed")
        if m: cf.append((int(m.group(1)), [x for x in m.group(2).split(", ") if x]))
    ok(len(cf) == 2, "two class-load counts, one per run")
    if len(cf) == 2:
        ok(cf[0][0] == len(cf[0][1]) == 2 and sorted(cf[0][1]) == ["cache.Cache", "cache.Caffeine"], "dev: Caffeine classes loaded 2 - %s (the count = the names listed)" % ", ".join(cf[0][1]))
        ok(cf[1][0] == len(cf[1][1]) == 93, "the default run: Caffeine classes loaded 93 (the count = the names listed: %d)" % len(cf[1][1]))
    nc = [l for l in L if l.startswith("  the harness's cache customers in")]
    ok(len(nc) == 2 and "RedisCache · writes through org.springframework.data.redis.cache.DefaultRedisCacheWriter" in nc[0] and "CaffeineCache" in nc[1], "the customers cache: a RedisCache writing through DefaultRedisCacheWriter under dev, a CaffeineCache in the default run")
    VALUES.append("one jar, two runs - dev: 1 CacheManager, RedisCacheManager, Caffeine classes 2 · default: 1 CacheManager, CaffeineCacheManager, Caffeine classes 93 · cache names [customer, customers]")


def rows(L):
    R = {}; cur = None
    for l in L:
        m = re.match(r"^== (\w+) (\w+) (\S+) -> (\d+) · PostgreSQL (\d+) \(non-empty statements; raw (\d+)\) · Redis (\d+) · MongoDB (\d+) · Elasticsearch (\d+)$", l)
        if m: cur = m.group(1); R[cur] = {"m": m.group(2), "p": m.group(3), "c": m.group(4), "pg": int(m.group(5)), "raw": int(m.group(6)), "rd": int(m.group(7)), "mo": int(m.group(8)), "es": int(m.group(9)), "L": []}; continue
        if l.startswith("== "): ok(False, "a row header that does not parse: " + l[:80]); cur = None; continue
        if cur and l.startswith("   "): R[cur]["L"].append(l.strip())
        elif l.startswith("  ") or l.startswith("-- "): cur = None   # rule: a two-space line ends the row (a note of the capture's)
    for k, v in R.items():
        n = lambda pre: sum(1 for x in v["L"] if x.startswith(pre + " "))
        ok(n("pg") == v["pg"] and n("redis") == v["rd"] and n("mongo") == v["mo"] and n("es") == v["es"], "%s: each count = the witness lines listed under it" % k)
    return R


def ans(r): return next((x for x in r["L"] if x.startswith("answer ")), "")


def tour(p):
    L = lines(p); R = rows(L)
    ok(set(R) == set(TOUR), "the tour's nine rows (%s)" % " ".join(R))
    if set(R) != set(TOUR): VALUES.append("the tour incomplete"); return
    dl = grab(L, r"^  before the first: redis-cli DEL 'customers::SimpleKey \[\]' -> (\d+) ", "the DEL line")
    ok(dl is not None and dl.group(1) == "1", "RED #3: DEL customers::SimpleKey [] -> 1 before the first read (the key WAS there)")
    c1, c2 = R["c1"], R["c2"]
    ok(c1["c"] == "200" and c1["pg"] == 3 and [x.split()[1] for x in c1["L"] if x.startswith("pg ")][::2] == ["BEGIN", "COMMIT"] and c1["rd"] == 7 and c1["mo"] == 0 and c1["es"] == 0, "GET /customers: 200 · PostgreSQL 3 (BEGIN READ ONLY, the select, COMMIT) · Redis 7 · MongoDB 0 · Elasticsearch 0")
    ok(any(x.startswith('redis  "SET" "customers::SimpleKey []"') for x in c1["L"]) and any(x == 'redis  "SET" "customers~lock" "" "NX"' for x in c1["L"]), "the first read: the cache writer's lock and the SET of the list")
    ok(c2["c"] == "200" and c2["pg"] == 0 and c2["rd"] == 2 and [x for x in c2["L"] if x.startswith("redis")] == ['redis  "EXISTS" "customers~lock"', 'redis  "GET" "customers::SimpleKey []"'], "GET /customers again: PostgreSQL 0 · Redis 2 (EXISTS customers~lock, GET customers::SimpleKey [])")
    lb = R["lb"]; ok(lb["c"] == "200" and lb["rd"] == 1 and 'redis  "ZREVRANGE" "tiffinbox:leaderboard" "0" "-1" "WITHSCORES"' in lb["L"] and '{"Sunil":9000.0' in ans(lb) and lb["pg"] == 0, "GET /leaderboard: ZREVRANGE tiffinbox:leaderboard 0 -1 WITHSCORES, Sunil first, PostgreSQL 0")
    mn = R["menu"]; ok(mn["c"] == "200" and mn["mo"] == 1 and "mongo  query find on tiffinbox.menu · nreturned 1 · docsExamined 1" in mn["L"] and ans(mn).count('"mealType"') >= 3 and mn["pg"] == 0 and mn["rd"] == 0, "GET /menu/day-19: 1 find on menu (nreturned 1), 3 items, PostgreSQL 0, Redis 0")
    rv = R["rev"]; m = [re.match(r"^mongo  command aggregate on tiffinbox\.orders · nreturned (\d+) · docsExamined (\d+)$", x) for x in rv["L"] if x.startswith("mongo")]
    ok(rv["c"] == "200" and rv["mo"] == 1 and len(m) == 1 and m[0] and m[0].group(2) == "120" and m[0].group(1) == "4", "GET /revenue/by-customer: 1 aggregate on orders, 120 examined, 4 returned")
    se = R["search"]; ok(se["c"] == "200" and se["es"] == 2 and all(x.startswith("es     POST /dishes/_search") for x in se["L"] if x.startswith("es")) and "<em>Vegetarian</em>" in ans(se) and se["pg"] == se["rd"] == se["mo"] == 0, "GET /dishes/search?q=veg: 2 _search requests, <em>Vegetarian</em>, no other store")
    ki = R["kitchen"]; ok(ki["c"] == "200" and '{"ordersCooked":120,"ordersValue":24300}' in ans(ki) and ki["pg"] == ki["rd"] == ki["mo"] == ki["es"] == 0, "GET /kitchen: {\"ordersCooked\":120,\"ordersValue\":24300}")
    pa, de = R["patch"], R["delete"]
    al = re.search(r"Allow \(sorted\): ([A-Z, ]+) · Content-Type: application/problem\+json", ans(pa)); ALLOW[0] = al.group(1) if al else "?"
    ok(pa["c"] == "405" and al is not None and sorted(al.group(1).split(", ")) == ["GET", "POST"], "PATCH /customers: 405, Allow: %s (sorted: its order differs between JVMs), problem details" % ALLOW[0])
    ok(de["c"] == "405" and "Allow (sorted): GET · Content-Type: application/problem+json" in ans(de), "DELETE /customers/Ravi: 405, Allow: GET, problem details")
    raws = sum(r["raw"] - r["pg"] for r in R.values())
    VALUES.append("DEL -> 1 · GET /customers: PostgreSQL 3, Redis 7, then 0 and 2 · /leaderboard ZREVRANGE, Sunil first · /menu/day-19 1 find, 3 items · /revenue/by-customer 1 aggregate, 120 examined, 4 returned · /dishes/search?q=veg 2 _search · /kitchen 120 / 24300 · PATCH 405 Allow: %s · DELETE 405 Allow: GET (empty statements filtered: %d)" % (ALLOW[0], raws))


def order(L, lab):
    l = next((x for x in L if x.startswith("== %s " % lab)), None); i = L.index(l) if l else -1
    o = next((x for x in L[i + 1:] if x.startswith("   the witnesses' order")), "") if i >= 0 else ""
    return [e.strip() for e in o.split(": ", 1)[1].split(" · ")] if ": " in o else []


def copies(p):
    L = lines(p); R = rows(L)
    ok(set(R) == set(COPY), "the copies' four rows")
    if set(R) != set(COPY): VALUES.append("the copies incomplete"); return
    a, c3, d, s2 = R["addc"], R["c3"], R["addd"], R["search2"]
    oc = order(L, "addc"); od = order(L, "addd")
    want_c = ["PostgreSQL BEGIN", "PostgreSQL insert into customer", "PostgreSQL COMMIT", "Redis XADD tiffinbox:kitchen-events", "Redis EXISTS customers~lock", "Redis SET customers~lock", "Redis KEYS customers::*", "Redis DEL customers::SimpleKey []", "Redis DEL customers~lock"]
    want_d = ["PostgreSQL BEGIN", "PostgreSQL insert into dish", "PostgreSQL COMMIT", "Elasticsearch PUT /dishes/_doc/11?refresh=false", "Elasticsearch POST /dishes/_refresh"]
    ok(a["c"] == "201" and oc == want_c, "POST /customers: 201 · the witnesses' order: COMMIT, then XADD tiffinbox:kitchen-events, then the cache writer's EXISTS / SET NX / KEYS / DEL / DEL (got: %s)" % " · ".join(oc))
    ok(any(x.startswith('redis  "XADD" "tiffinbox:kitchen-events" "*" "type" "customer-added" "name" "Probe') for x in a["L"]), "the stream event: XADD tiffinbox:kitchen-events * type customer-added name Probe<run>")
    ok(c3["pg"] == 3 and c3["rd"] == 7, "the next GET /customers misses: PostgreSQL 3, Redis 7")
    ok(d["c"] == "201" and od == want_d, "POST /dishes: 201 · the witnesses' order: COMMIT, then PUT /dishes/_doc/11?refresh=false, then POST /dishes/_refresh (got: %s)" % " · ".join(od))
    ok(s2["c"] == "200" and "<em>Probe</em> Dish" in ans(s2), "GET /dishes/search?q=probe finds the new dish")
    ok(a["mo"] == 0 and d["mo"] == 0, "MongoDB's profiler in both write windows: 0 - written by neither (RED #4)")
    ok(a["es"] == 0 and d["rd"] == 0, "one copying store per write: the customer's window holds no Elasticsearch request, the dish's no Redis command")
    cp = sum(1 for x in a["L"] if x.startswith('redis  "XADD"')) + sum(1 for x in a["L"] if x == 'redis  "DEL" "customers::SimpleKey []"') + sum(1 for x in d["L"] if x.startswith("es     PUT /dishes/_doc/"))
    st = len({"Redis" for x in a["L"] if x.startswith("redis")} | {"Elasticsearch" for x in d["L"] if x.startswith("es     PUT")})
    ok(cp == 3 and st == 2, "%d copies in %d stores (the stream event and the evict in Redis, the index document in Elasticsearch)" % (cp, st))
    w = [l.strip() for l in L if l.startswith("    the harness's")]
    ok("the harness's cache customers in cacheManager: org.springframework.data.redis.cache.RedisCache · writes through org.springframework.data.redis.cache.DefaultRedisCacheWriter" in w, "the evict's writer: DefaultRedisCacheWriter, the customers cache's own (read off the context)")
    ok(any(re.match(r"^the harness's   bean kitchenEvents \(com\.tiffinbox\.web\.KitchenEvents\) stored\[CustomerAdded\] phase AFTER_COMMIT$", x) for x in w) and any(re.match(r"^the harness's   bean dishIndexSync \(com\.tiffinbox\.web\.DishIndexSync\) copy\[DishSaved\] phase AFTER_COMMIT$", x) for x in w),
       "the stream event's writer: KitchenEvents.stored, the index document's: DishIndexSync.copy, each after the commit (read off the context)")
    VALUES.append("POST /customers: COMMIT, then XADD tiffinbox:kitchen-events (KitchenEvents, after the commit), then the evict (DefaultRedisCacheWriter): EXISTS, SET NX, KEYS customers::*, DEL customers::SimpleKey [], DEL customers~lock; the next read PostgreSQL 3 · POST /dishes: COMMIT, then PUT /dishes/_doc/11?refresh=false and POST /dishes/_refresh (DishIndexSync, after the commit); search finds it · MongoDB 0 in both · 3 copies in 2 stores")


def default(p):
    L = lines(p); R = {}
    for l in L:
        m = re.match(r"^== (\w+) (\w+) (\S+) -> (\d+) · Hibernate SQL lines (\d+) · (.*)$", l)
        if l.startswith("== ") and not m: ok(False, "a default row that does not parse: " + l[:80])
        if m: R[m.group(1)] = (m.group(2), m.group(3), m.group(4), int(m.group(5)), m.group(6))
    ok(len(R) == 13, "the default run's thirteen rows")
    if len(R) != 13: VALUES.append("the default run incomplete"); return
    cm = grab(L, r"^  the harness's CacheManager beans 1: \[cacheManager = org\.springframework\.cache\.caffeine\.CaffeineCacheManager caches \[customer, customers\]\]$", "the default run's CacheManager")
    ok(R["addc"][2] == "201", "POST /customers (Probe<run>): 201 - it evicts the list Caffeine held since the start")
    ok(R["c1"][2] == "200" and R["c1"][3] == 1 and R["c2"][2] == "200" and R["c2"][3] == 0, "GET /customers: Hibernate's SQL lines 1, then 0")
    pb = grab(L, r"^  /actuator/prometheus, cache_gets_total for customers, before the two reads: (.*)$", "prometheus before"); pa = grab(L, r"^  /actuator/prometheus, cache_gets_total for customers, after them: (.*)$", "prometheus after")
    def mh(m):
        d = {}
        for x in (m.group(1).split(" · ") if m else []):
            r = re.search(r"result=(\w+)\} ([\d.]+)$", x)
            if r: d[r.group(1)] = r.group(2)
        return d
    b, a = mh(pb), mh(pa)
    ok(b.get("miss") == "1.0" and a.get("miss") == "2.0" and b.get("hit") == "0.0" and a.get("hit") == "1.0", "cache_gets_total{cache=customers}: miss 1.0 -> 2.0, hit 0.0 -> 1.0 (%s -> %s)" % (b, a))
    for k in ("lb", "menu", "rev", "search", "addd"):
        ok(R[k][2] == "404" and "No static resource" in R[k][4], "the default run: %s %s -> 404 (No static resource)" % (R[k][0], R[k][1]))
    al = re.search(r"Allow \(sorted\): ([A-Z, ]+) · ", R["patch"][4]); ALLOW[0] = al.group(1) if al else "?"
    ok(R["patch"][2] == "405" and al is not None and sorted(al.group(1).split(", ")) == ["GET", "POST"], "PATCH /customers -> 405, Allow: %s (sorted: its order differs between JVMs)" % ALLOW[0])
    ok(R["delete"][2] == "405" and "Allow (sorted): GET ·" in R["delete"][4], "DELETE /customers/Ravi -> 405, Allow: GET")
    ok(R["cust"][2] == "200" and R["cust"][3] == 1, "GET /customers/Ravi -> 200, Hibernate's SQL lines 1")
    ok(R["apidocs"][2] == "404" and R["swagger"][2] == "404", "GET /v3/api-docs -> 404, GET /swagger-ui.html -> 404 (unit 28's witness)")
    VALUES.append("the default run: CaffeineCacheManager · GET /customers Hibernate SQL 1 then 0 · cache_gets_total miss 1.0 -> 2.0, hit 0.0 -> 1.0 · the five dev-only routes 404 (POST /dishes too) · PATCH 405 Allow: %s · DELETE 405 Allow: GET · GET /customers/Ravi 200 · /v3/api-docs 404 · /swagger-ui.html 404" % ALLOW[0])


ABS = {"pg": ("entityManagerFactory", "flywayInitializer", "PSQLException: Connection to 127.0.0.1:20669 refused"), "redis": ("tiffinBoxServer", None, "AnnotatedConnectException"),
       "es": ("dishIndexSync", "dishes", "Connection refused"), "mongo": ("menus", "mongoTemplate", "MongoTimeoutException")}


def absent(p):
    L = lines(p); seen = []
    for i, l in enumerate(L):
        m = re.match(r"^== absent (\w+): ", l)
        if not m: continue
        s = m.group(1); seen.append(s); blk = []
        for x in L[i + 1:]:
            if x.startswith("== ") or x.startswith("-- "): break
            blk.append(x)
        e = next((re.match(r"^  exit (\d+) · 'Started TiffinBoxServer' (\d+) · 'Application run failed' (\d+) · 'APPLICATION FAILED TO START' (\d+) · Flyway's lines \(applied / up to date\) (\d+)$", x) for x in blk if x.startswith("  exit ")), None)
        ch = next((x[len("  the chain's first two beans: "):] for x in blk if x.startswith("  the chain's first two beans: ")), "")
        want = ABS.get(s)
        ok(want is not None and e is not None and e.group(1) == "1" and e.group(2) == "0" and e.group(3) == "1", "absent %s: exit 1, no Started line, 'Application run failed' once" % s)
        if want:
            ok(ch == " <- ".join(x for x in want[:2] if x), "absent %s: the chain's first two beans %s (got: %s)" % (s, " <- ".join(x for x in want[:2] if x), ch))
            ok(any(want[2] in x for x in blk if x.startswith("  Caused by: ")), "absent %s: a last Caused by line names %s" % (s, want[2]))
        if s == "pg": ok(e is not None and e.group(5) == "0", "absent pg: Flyway's lines 0 - the start stops before any migration")
    ok(sorted(seen) == ["es", "mongo", "pg", "redis"], "absent: four starts, one per store (%s)" % " ".join(seen))
    VALUES.append("absent: PostgreSQL entityManagerFactory <- flywayInitializer · Redis tiffinBoxServer · Elasticsearch dishIndexSync <- dishes · MongoDB menus <- mongoTemplate · each exit 1")


TWO = "Parameter 0 of method redisCacheConfiguration in com.tiffinbox.web.RedisCaching required a bean of type 'org.springframework.boot.cache.autoconfigure.CacheProperties' that could not be found."


def twocaches(p):
    L = lines(p); n = 0
    for i, l in enumerate(L):
        m = re.match(r"^== twocaches, (\w+) names", l)
        if not m: continue
        n += 1; blk = []
        for x in L[i + 1:]:
            if x.startswith("== ") or x.startswith("  Boot's CacheAutoConfiguration"): break
            blk.append(x)
        e = next((re.match(r"^  exit (\d+) · 'Started TiffinBoxServer' (\d+) · 'APPLICATION FAILED TO START' (\d+) · 'Application run failed' (\d+)$", x) for x in blk if x.startswith("  exit ")), None)
        ok(e is not None and e.group(1) == "1" and e.group(2) == "0" and e.group(3) == "1", "twocaches %s: exit 1, no Started line, APPLICATION FAILED TO START once" % m.group(1))
        ok(("  Description: " + TWO) in blk, "twocaches %s: the Description quoted whole: %s" % (m.group(1), TWO[:60]))
        ok(any(x.startswith("  the first exception's class and bean: org.springframework.beans.factory.UnsatisfiedDependencyException · redisCacheConfiguration") for x in blk), "twocaches %s: the owner org.springframework.beans.factory's UnsatisfiedDependencyException, bean redisCacheConfiguration" % m.group(1))
        tw = next((re.match(r"^  the harness's TwoCaches lines in the log: (\d+) ", x) for x in blk if x.startswith("  the harness's TwoCaches lines")), None)
        ok(tw is not None and tw.group(1) == "0", "twocaches %s: the harness's localCaches method never ran (its line 0): the condition read the bean's definition" % m.group(1))
    ok(n == 2, "twocaches: two variants (%d)" % n)
    t = "\n".join(L)
    ok(re.search(r'condition\.ConditionalOnMissingBean\(\n\s+value=\[class Lorg/springframework/cache/CacheManager;\]\n\s+name=\["cacheResolver"\]', t) is not None, "javap: CacheAutoConfiguration @ConditionalOnMissingBean(value = CacheManager.class, name = \"cacheResolver\")")
    ok(re.search(r"EnableConfigurationProperties\(\n\s+value=\[class Lorg/springframework/boot/cache/autoconfigure/CacheProperties;\]", t) is not None, "javap: CacheAutoConfiguration @EnableConfigurationProperties(CacheProperties.class) - backed off, no CacheProperties")
    VALUES.append("twocaches: a second CacheManager bean (localCaches) -> exit 1 · %s · CacheAutoConfiguration @ConditionalOnMissingBean(value = CacheManager.class, name = \"cacheResolver\")" % TWO)


def seven(p, want):
    L = lines(p)
    m = [l for l in L if re.match(r"^  exit 0 · the seven responses: 7 lines · md5 [0-9a-f]{32} · listening on 20665 now: 0$", l)]
    ok(len(m) == 1 and want in m[0], "the seven on after/'s jar (20665): 7 lines, md5 = %s (read off ../c7-unit31/receipts.sh)" % want)
    VALUES.append("the seven on after/: 7 lines, md5 = the course's")


def bound(p, ip):
    L = lines(p); t = "\n".join(L)
    ch = sorted(x.split("changed: ", 1)[1] for x in L if x.startswith("  changed: "))
    want = sorted(["README.md"] + [TD + s + c + ".java" for c, s, f in ITS])
    ok(ch == want and not [x for x in L if x.startswith("  new: ") or x.startswith("  gone: ")], "the change: the five IT files and README.md, nothing new, nothing gone")
    tr = grab(L, r"^  the trees \(python3 -I harness/tree27\.py, links followed\): before/ (\d+) [0-9a-f]{32} · after/ (\d+) [0-9a-f]{32}$", "the trees line")
    ok(tr is not None and tr.group(1) == tr.group(2) == "84", "84 files before, 84 after - 0 new")
    ok("  under tiffinbox-core/ and tiffinbox-web/src/main/: 0 + 0 files differ - the jar's sources byte-equal" in L, "tiffinbox-core/ and src/main byte-equal")
    ok(re.search(r"^  before/'s three older ITs, their modifier \(grep -c withCreateContainerCmdModifier\): CustomerEntityRepositoryIT 0 · CustomerAggregatesIT 0 · RedisDatastoreIT 0 - ", t, re.M) is not None, "before/: the three older ITs had no modifier (every interface, Testcontainers' default - read, not re-run)")
    sc = grab(L, r"^  the static check .*->((?: \d+)+)$", "the static check")
    ok(sc is not None and sc.group(1).split() == ["1"] * 5, "the static check: 1 1 1 1 1")
    ok(re.search(r"^  exit 0 · BUILD SUCCESS · offline: yes$", t, re.M) is not None, "mvn verify: exit 0, BUILD SUCCESS, offline")
    res = re.findall(r"^  the Results line: Tests run: (\d+), Failures: (\d+), Errors: (\d+), Skipped: (\d+)$", t, re.M)
    ok(len(res) == 2 and res[0] == ("18", "0", "0", "0") and res[1] == ("14", "0", "0", "0"), "the tests: %s" % " + ".join("%s run, %s failures, %s errors" % r[:3] for r in res))
    ok(re.search(r"^  MongoDatastoreIT: Tests run: 4, Failures: 0, Errors: 0, Skipped: 0 -- in com\.tiffinbox\.web\.MongoDatastoreIT$", t, re.M) is not None, "MongoDatastoreIT: 4 tests")
    cls, ent, off = set(), 0, 0
    for l in L:
        if not l.startswith("    IT BINDINGS "): continue
        m = re.match(r"^    IT BINDINGS (\w+) \[(.*)\]$", l)
        ok(m is not None, "an IT BINDINGS line parsed (%s)" % l.strip()[:70])
        if not m: continue
        cls.add(m.group(1))
        for e in [x for x in m.group(2).split(", ") if x]:
            em = re.match(r"^(\d+)/tcp -> ([^:]+):(<port>|\d+)$", e)
            ok(em is not None, "an IT BINDINGS entry parsed (%s)" % e[:50])
            if em: ent += 1; off += em.group(2) != ip
    ok(len(cls) == 5 and ent >= 5 and off == 0, "IT BINDINGS: classes %d · entries %d · not %s: %d" % (len(cls), ent, ip, off))
    ok(re.search(r"each distinct host address: 127\.0\.0\.1 · ", t) is not None, "the Testcontainers containers' ports while verify ran: 127.0.0.1 alone (dk ps)")
    ok(re.search(r"· 18881-18884 bound during it: no$", t, re.M) is not None, "18881-18884 free during verify (Compose stays off in tests)")
    m = re.search(r"ElasticsearchIT: 'Timed out waiting' lines (\d+) · its container started: (\d+) · 'Creating container for image' (\d+) · 'Pulling' (\d+) · Testcontainers containers after it: (\d+) · listening on 20578 and 20615 after it: (\d+)", t)
    ok(m is not None and m.group(1) == "0" and m.group(4) == "0" and m.group(5) == "0" and m.group(6) == "0", "S8.112: ElasticsearchIT did not time out on its log wait; nothing pulled; no Testcontainers container left; 20578 and 20615 free after")
    VALUES.append("the change: five IT files + README, 84 files, src/main byte-equal · static 1 1 1 1 1 · tests 18 + 14, 0 failures (MongoDatastoreIT 4) · IT BINDINGS classes %d, entries %d, not 127.0.0.1: %d · ElasticsearchIT's wait held · containers created %s · pulled 0" % (len(cls), ent, off, m.group(3) if m else "?"))


BROKEN = "check: the start: failed - " + TWO + " · the reads: none · solved: no"
SOLVED = "check: the start: started · DEL customers::SimpleKey [] -> 1 · GET /customers twice: PostgreSQL 3 then 0 statements · Redis EXISTS customers::SimpleKey [] -> 1 · solved: yes"


def exercise(p, w, q):
    L = lines(p)
    ok(w == "21" and len(q.split()) == 21, "the spoken exercise line: 21 words (wc -w %s)" % w)
    for sh in ("bash", "zsh"):
        i = next((k for k, l in enumerate(L) if l.startswith("in " + sh + " (")), None)
        ok(i is not None, "the %s run is in the capture" % sh)
        if i is None: continue
        j = next((k for k in range(i, len(L)) if L[k].startswith("  then the solution's lines")), len(L))
        e = next((k for k in range(j, len(L)) if L[k].startswith("  the shell is now in:")), len(L))
        br, so = [x.strip() for x in L[i + 1:j]], [x.strip() for x in L[j + 1:e]]
        ok(br == ["built: 1 jar", BROKEN], sh + ": broken - built, the start fails: no bean of type CacheProperties, the reads none, solved: no")
        ok(so == ["built: 1 jar", SOLVED], sh + ": solved - started, DEL 1, PostgreSQL 3 then 0, Redis EXISTS 1, solved: yes")
        ok(e < len(L) and re.search(r"listening on 20661-20666 afterwards: 0 · the exercise's containers afterwards: 0 · volumes (\d+) \(before the shell: \1\) · java processes of the exercise: 0 · images afterwards: the same list yes", L[e]) is not None, sh + ": nothing left")
    runs_ = [k for k, l in enumerate(L) if re.match(r"^  run [123] - the block's exit \d+:$", l)]
    ok(len(runs_) == 3, "the cache-type \"solution\": three runs")
    dl = []
    for k in runs_:
        blk = []
        for l in L[k + 1:]:
            if not l.startswith("    "): break
            blk.append(l.strip())
        dl.append(blk)
    ref = [b for b in dl if len(b) == 2 and b[0] == "built: 1 jar" and re.match(r"^check: the start: started · DEL customers::SimpleKey \[\] -> 0 · GET /customers twice: PostgreSQL \d+ then \d+ statements · Redis EXISTS customers::SimpleKey \[\] -> 0 · solved: no$", b[1])]
    ok(len(ref) == 3 and dl[0] == dl[1] == dl[2], "the cache-type \"solution\": refused 3/3 - it starts, and Redis holds no list (%s)" % (dl[0][1][:150] if dl and len(dl[0]) > 1 else "?"))
    VALUES.append("broken: the start fails, no bean of type CacheProperties · solved: started, DEL 1, PostgreSQL 3 then 0, EXISTS 1 · the cache-type switch refused 3/3 (EXISTS 0) · the spoken line 21 words")


def wib(p, f):
    L = lines(p)
    i = next(k for k, l in enumerate(L) if l.startswith("in bash ("))
    j = next(k for k in range(i, len(L)) if L[k].startswith("  then the solution's lines"))
    e = next(k for k in range(j, len(L)) if L[k].startswith("  the shell is now in:"))
    seg = L[i + 1:j] if f.endswith("README.md") else L[j + 1:e]
    print("\n".join(x[4:] if x.startswith("    ") else x for x in seg))


def readme(r, v):
    R = rd(r); V = rd(v).rstrip("\n")
    m = re.search(r"<!-- values: begin -->\n```text\n(.*?)\n```\n<!-- values: end -->", R, re.S)
    ok(m is not None and m.group(1) == V, "the values block = the captures' VALUES lines, byte for byte")
    caps = set()
    for f in os.listdir(U):
        if f.startswith(".r-") and f.endswith(".out"): caps.update(x.rstrip() for x in rd(os.path.join(U, f)).splitlines())
    caps.update(V.split("\n"))
    blocks = re.findall(r"```text\n(.*?)\n```", R, re.S); n = 0; bad = []
    for b in blocks:
        for l in b.split("\n"):
            n += 1
            if l.rstrip() not in caps and l.strip() != "…": bad.append(l[:100])
    ok(not bad, "every line of README.md's %d text blocks is a line a capture printed (%d lines; not found: %s)" % (len(blocks), n, bad[:3]))


def main():
    a = sys.argv[1:]; nm = a[0] if a else "?"
    try:
        if nm == "show":
            {"runs": lambda: show_runs(a[2], a[3]), "tour": lambda: show_tour(a[2]), "copies": lambda: show_copies(a[2]), "default": lambda: show_default(a[2]),
             "absent": lambda: show_absent(a[2]), "twocaches": lambda: show_twocaches(a[2])}[a[1]](); return
        if nm == "wib": wib(a[1], a[2]); return
        {"static": lambda: static(a[1], a[2]), "runs": lambda: runs(a[1]), "tour": lambda: tour(a[1]), "copies": lambda: copies(a[1]), "default": lambda: default(a[1]),
         "absent": lambda: absent(a[1]), "twocaches": lambda: twocaches(a[1]), "seven": lambda: seven(a[1], a[2]), "bound": lambda: bound(a[1], a[2]),
         "exercise": lambda: exercise(a[1], a[2], a[3]), "readme": lambda: readme(a[1], a[2])}[nm]()
    except Exception as x:   # a capture this file cannot read is a FAIL with its reason, never a traceback (unit 25's defect class)
        ok(False, "%s: the checker could not read its input: %s: %s" % (nm, type(x).__name__, str(x)[:160]))
    print("VALUES " + " · ".join(VALUES))
    sys.exit(1 if FAILS else 0)


main()
