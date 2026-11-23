"""Unit 24's checks (python3 -I -B harness/chk24.py NAME ARG...), each re-deriving its numbers from a capture or from the shipped files,
never from the README's prose; every check prints "ok ..." or "FAIL ...", and one "VALUES ..." line (what the video may say), and exits 1
on a FAIL. Names:
  static          the family base: s824.py's XFAM_S4B, TIMEPAT_S4B, XU19-XU23 blocks equal to s823.py's (md5), no XEXEMPT_S4B;
                  tree24.py's code = tree23.py's; every line H24.java prints says "the harness's" (S8.87, R.396)
  exercise F W Q  the exercise in bash and zsh: broken (one manager, the exception, rows 0 / documents 0, solved: no), solved (two
                  managers, rows 1 / documents 1, solved: yes), the rename three times (one manager named transactionManager, no
                  exception, rows 0 / documents 1, solved: no); the spoken line W words
  wib F FILE      prints what FILE's "What it prints" block must be: the bash run's lines of that file's block, from the capture F
  jars F          the two annotations on JpaBaseConfiguration.transactionManager; ChainedTransactionManager's size and Deprecated
  handoff F MD5   the sentence's md5 = MD5; after/README.md holds it once; the roadmap's lines and the ledger row as read
  mtm F           [mongoTransactionManager] -> [MongoTransactionManager]; the exception whole; rows 0 / documents 0 by both witnesses
  mtmnamed F      [transactionManager] -> [MongoTransactionManager]; no plant: no exception, rows 0 / documents 1; planted 0 / 0;
                  the WARN and ERROR lines counted, none naming the row
  both F          the two managers, their classes, @Primary on JPA's, each method's @Transactional value
  dual F          the matrix: every method planted and its control, rows / documents by the harness's Java = psql's = mongosh's
  scoped F        planted: no exception at the caller, rows 1 / documents 0, the afterCompletion line; control 1 / 1; both witnesses
  sockets F       the replica set's container: listening on 27017 alone, 0 outbound, 0 UDP; its interfaces
  footprint F     the Compose window: four containers, mongo a standalone, Flyway 4, the re-index, veg 1 hit, the reading masked
  default F       200, 404 x3, 200, 200; 0 Elasticsearch and 0 MongoDB lines; the two jars equal
  seven F MD5     the seven on before/ and after/: 7 lines each, md5 = MD5 (read off ../c7-unit31/receipts.sh), 0 lines differ
  readme R V      README.md's values block = V's line; every line of its text blocks is a line a capture printed (R.302)"""
import hashlib, os, re, sys

HERE = os.path.dirname(os.path.abspath(__file__)); U = os.path.dirname(HERE); REPO = os.path.dirname(U)
FAILS = []; VALUES = []


def ok(c, msg):
    print(("ok " if c else "FAIL ") + msg)
    if not c: FAILS.append(msg)


def rd(p): return open(p, encoding="utf-8").read()


def md5(s): return hashlib.md5(s.encode()).hexdigest() if s is not None else None


def block(src, start):
    i = src.find("\n" + start)
    if i < 0: return None
    i += 1
    if src[i:].split("\n", 1)[0].rstrip().endswith("{"):
        j = src.find("\n}\n", i); return src[i:j + 2]
    return src[i:].split("\n", 1)[0]


def static():
    s4, s3 = rd(os.path.join(HERE, "s824.py")), rd(os.path.join(REPO, "c8-unit23", "harness", "s823.py"))
    for b in ("XFAM_S4B = {", "TIMEPAT_S4B = re.compile(", "XU19 = {", "XU20 = {", "XU21 = {", "XU22 = {", "XU23 = {"):
        x, y = block(s4, b), block(s3, b)
        ok(x is not None and md5(x) == md5(y), "%s s824.py = s823.py's slice (md5 %s)" % (b.split(" ")[0], md5(x)))
    ok(re.search(r"^XEXEMPT_S4B\s*=", s4, re.M) is None, "no XEXEMPT_S4B in s824.py (BUILDERS 3)")
    t4 = rd(os.path.join(HERE, "tree24.py")).split('"""', 2)[2]; t3 = rd(os.path.join(REPO, "c8-unit23", "harness", "tree23.py")).split('"""', 2)[2]
    ok(t4 == t3, "tree24.py's code = tree23.py's, byte for byte (only the docstring differs)")
    j = rd(os.path.join(HERE, "src", "probe", "u24", "H24.java"))
    lits = re.findall(r'System\.out\.println\("([^"]*)', j)
    ok(len(lits) > 0 and all(l.startswith("the harness's ") for l in lits), "every line H24.java prints starts with \"the harness's\" (%d println calls)" % len(lits))
    ok("replicaSet=" not in j, "H24.java: no replicaSet= (R.428)")
    VALUES.append("the families carried from s823.py, md5-equal")


def cap(p): return rd(p).splitlines()


def exercise(p, w, q):
    L = cap(p); t = "\n".join(L)
    ok(w == "21" and len(q.split()) == 21, "the spoken exercise line: 21 words (wc -w %s)" % w)
    for sh in ("bash", "zsh"):
        i = next((k for k, l in enumerate(L) if l.startswith("in " + sh + " (")), None)
        ok(i is not None, "the %s run is in the capture" % sh)
        if i is None: continue
        j = next((k for k in range(i, len(L)) if L[k].startswith("  then the solution's lines")), None)
        e = next((k for k in range(j or i, len(L)) if L[k].startswith("  the shell is now in:")), None)
        br, so = L[i:j], L[j:e]
        ok(any("the lab's transaction managers: [mongoTransactionManager] -> [MongoTransactionManager]" in l for l in br), sh + ": broken - one manager, Mongo's")
        ok(any("caller caught NoSuchBeanDefinitionException: No bean named 'transactionManager' available" in l for l in br), sh + ": broken - the call refused, no bean named transactionManager")
        ok(any("the lab's plain: rows 0 · documents 0" in l for l in br), sh + ": broken - rows 0, documents 0 (the lab's Java)")
        ok(any(l.strip().startswith("check: ") and l.strip().endswith("rows (psql) 0 · documents (mongosh, no network) 0 · solved: no") for l in br), sh + ": broken - check.sh: psql 0, mongosh 0, solved: no")
        ok(any("the lab's transaction managers: [transactionManager, mongoTransactionManager] -> [JpaTransactionManager, MongoTransactionManager]" in l for l in so), sh + ": solved - two managers, JPA's and Mongo's")
        ok(any("the lab's plain call: caller saw no exception" in l for l in so) and any("the lab's plain: rows 1 · documents 1" in l for l in so), sh + ": solved - no exception, rows 1, documents 1")
        ok(any(l.strip().endswith("rows (psql) 1 · documents (mongosh, no network) 1 · solved: yes") for l in so), sh + ": solved - check.sh: psql 1, mongosh 1, solved: yes")
        ok("exit 0:" in br[0] and "exit 0:" in so[0], sh + ": both blocks exit 0 (the exit is not the check)")
        ok(e is not None and "listening on 20635 and 20636 afterwards: 0" in L[e] and "afterwards: 0 · volumes" in L[e] and "the same list yes" in L[e], sh + ": nothing left - ports, containers, volumes, images")
    rn = [k for k, l in enumerate(L) if l.startswith("  rename run ")]
    ok(len(rn) == 3, "the rename: three runs")
    nr = 0
    for k in rn:
        seg = L[k:k + 5]
        good = (any("[transactionManager] -> [MongoTransactionManager]" in l for l in seg) and any("caller saw no exception" in l for l in seg)
                and any("rows 0 · documents 1" in l for l in seg) and any(l.strip().endswith("rows (psql) 0 · documents (mongosh, no network) 1 · solved: no") for l in seg))
        nr += good
    ok(nr == 3, "the rename refused 3/3: one manager named transactionManager, no exception, rows 0 / documents 1, check.sh solved: no")
    VALUES.append("broken [mongoTransactionManager] rows 0 documents 0 solved no; solved [transactionManager, mongoTransactionManager] rows 1 documents 1 solved yes; rename [transactionManager] -> [MongoTransactionManager] rows 0 documents 1 solved no 3/3")


def wib(p, f):
    L = cap(p)
    i = next(k for k, l in enumerate(L) if l.startswith("in bash ("))
    j = next(k for k in range(i, len(L)) if L[k].startswith("  then the solution's lines"))
    e = next(k for k in range(j, len(L)) if L[k].startswith("  the shell is now in:"))
    seg = L[i + 1:j] if f.endswith("README.md") else L[j + 1:e]
    for l in seg: print(l[4:] if l.startswith("    ") else l)
    sys.exit(0)


def jars(p):
    t = rd(p)
    ok("org.springframework.context.annotation.Bean" in t, "JpaBaseConfiguration.transactionManager: @Bean (javap -v, RuntimeVisibleAnnotations)")
    ok("org.springframework.boot.autoconfigure.condition.ConditionalOnMissingBean(" in t and "value=[class Lorg/springframework/transaction/TransactionManager;]" in t, "and @ConditionalOnMissingBean(value = [TransactionManager.class])")
    ok(re.search(r"public org\.springframework\.transaction\.PlatformTransactionManager transactionManager\(", t) is not None, "the method: public PlatformTransactionManager transactionManager(...)")
    m = re.search(r"org/springframework/data/transaction/ChainedTransactionManager\.class (\d+) B", t)
    ok(m is not None, "ChainedTransactionManager.class is in spring-data-commons-4.1.2.jar")
    ok("Deprecated: true" in t and "java.lang.Deprecated" in t, "ChainedTransactionManager: Deprecated: true, @java.lang.Deprecated")
    mm = re.search(r"entries naming MongoTransactionManager \(unzip -l\): spring-boot-mongodb (\d+) · spring-boot-data-mongodb (\d+)", t)
    ok(mm is not None and mm.groups() == ("0", "0"), "Boot's two MongoDB jars: 0 entries naming MongoTransactionManager")
    ok("spring-boot-jpa-4.1.2.jar · spring-data-commons-4.1.2.jar" in t, "the jar names read off BOOT-INF/lib: spring-boot-jpa-4.1.2.jar, spring-data-commons-4.1.2.jar")
    VALUES.append("@Bean + @ConditionalOnMissingBean(value = [TransactionManager.class]) on JpaBaseConfiguration.transactionManager; ChainedTransactionManager %s B, Deprecated: true" % (m.group(1) if m else "?"))


def handoff(p, h):
    t = rd(p)
    ok("md5 -> " + h in t, "printf '%s' sentence | md5 = " + h)
    ok(re.search(r"after/README\.md: lines equal to it \(grep -cxF\) 1 · that line's md5 \(no newline\) " + h, t) is not None, "after/README.md holds the sentence once, byte for byte")
    ok(re.search(r"\.\./c8-tiffinbox/README\.md: lines equal to it \(grep -cxF\) [01] ", t) is not None, "../c8-tiffinbox/README.md: the sentence 0 times (before the copy) or 1")
    for r, w in ((":64 ", "Messaging & Integration"), (":552 ", "COURSE 13 — Messaging & Integration"), (":580 ", "S4 · Patterns that matter"), (":581 ", "The Outbox Pattern"), (":922 ", "named by section, not number")):
        ok(any(l.strip().startswith(r) and w in l for l in t.splitlines()), "the roadmap %s holds %s" % (r.strip(), w))
    ok("| C8-20 |" in t, "the ledger's row C8-20, read")
    VALUES.append("the hand-off sentence md5 " + h + ", roadmap :64 :552 :580-581 :922, ledger C8-20")


ROW = re.compile(r"^  the harness's (.+): rows (\d+) · documents (\d+)$")
OUT = re.compile(r"^  the harness's (.+) \(Dual\.(\w+), plant (yes|no)\): (.*)$")


def java(t):
    return {m.group(1): (int(m.group(2)), int(m.group(3))) for m in (ROW.match(l) for l in t.splitlines()) if m}


def outcomes(t):
    return {m.group(1): m.group(4) for m in (OUT.match(l) for l in t.splitlines()) if m}


def wit(t):
    pr = {}; md = {}
    for l in t.splitlines():
        m = re.match(r"^    psql rows: (.+) (\d+)$", l)
        if m: pr[m.group(1)] = int(m.group(2))
        m = re.match(r"^    mongosh documents: (.+) (\d+)$", l)
        if m: md[m.group(1)] = int(m.group(2))
    return pr, md


def witnesses(t, names):
    j = java(t); pr, md = wit(t)
    for n in names:
        ok(n in j and (pr.get(n, 0), md.get(n, 0)) == j[n], "%s: the harness's Java rows / documents %s = psql %d / mongosh %d" % (n, "%d / %d" % j[n] if n in j else "?", pr.get(n, 0), md.get(n, 0)))
    ok(set(pr) <= set(names) and set(md) <= set(names), "the stores hold no row or document but these names")
    return j


def migrations(t): ok("  the start: Successfully applied 4 migrations" in t, "the harness JVM's Boot start: Successfully applied 4 migrations (Flyway, V1-V4)")


NSBDE = "caller caught org.springframework.beans.factory.NoSuchBeanDefinitionException: No bean named 'transactionManager' available: No matching TransactionManager bean found for qualifier 'transactionManager' - neither qualifier match nor bean name match!"


def mtm(p):
    t = rd(p); migrations(t)
    ok("  the harness's transaction managers: [mongoTransactionManager] -> [MongoTransactionManager]" in t, "the bean list: [mongoTransactionManager] -> [MongoTransactionManager] - Boot made no JPA manager")
    ok(outcomes(t).get("mtm plain") == NSBDE, "the plain call: NoSuchBeanDefinitionException, quoted whole")
    j = witnesses(t, ["mtm plain"])
    ok(j.get("mtm plain") == (0, 0), "rows 0 / documents 0")
    VALUES.append("[mongoTransactionManager] -> [MongoTransactionManager]; NoSuchBeanDefinitionException: No bean named 'transactionManager' available; rows 0 / documents 0")


def mtmnamed(p):
    t = rd(p); migrations(t)
    ok("  the harness's transaction managers: [transactionManager] -> [MongoTransactionManager]" in t, "the bean list: [transactionManager] -> [MongoTransactionManager]")
    o = outcomes(t)
    ok(o.get("mtmnamed plain") == "caller saw no exception", "no plant: the caller saw no exception")
    ok(o.get("mtmnamed planted") == "caller caught java.lang.IllegalStateException: PLANTED after both writes", "planted: IllegalStateException")
    j = witnesses(t, ["mtmnamed plain", "mtmnamed planted"])
    ok(j.get("mtmnamed plain") == (0, 1) and j.get("mtmnamed planted") == (0, 0), "no plant rows 0 / documents 1; planted 0 / 0")
    m = re.search(r"^  its WARN and ERROR lines: (\d+)$", t, re.M)
    warns = [l for l in t.splitlines() if re.match(r"^    (WARN|ERROR) ", l)]
    ok(m is not None and int(m.group(1)) == len(warns), "the WARN and ERROR lines counted (%s) and each printed" % (m.group(1) if m else "?"))
    ok(not any(re.search(r"dish|mtmnamed|transaction|rollback|insert", l, re.I) for l in warns), "none of them names the row, the dish table, a transaction or an insert")
    ok(not re.search(r"^    ERROR ", t, re.M), "no ERROR line")
    VALUES.append("[transactionManager] -> [MongoTransactionManager]; no plant: caller saw no exception, rows 0 / documents 1; planted: IllegalStateException, 0 / 0; WARN lines %s, none naming the row" % (m.group(1) if m else "?"))


def both(p):
    t = rd(p); migrations(t)
    ok("  the harness's transaction managers: [transactionManager, mongoTransactionManager] -> [JpaTransactionManager, MongoTransactionManager]" in t, "the bean list: [transactionManager, mongoTransactionManager]")
    ok("  the harness's bean transactionManager: org.springframework.orm.jpa.JpaTransactionManager (@Primary)" in t and "  the harness's bean mongoTransactionManager: org.springframework.data.mongodb.MongoTransactionManager" in t, "each manager's class; JPA's @Primary")
    want = {"jpaDocRow": "transactionManager", "jpaDocRowAfter": "transactionManager", "jpaRowDoc": "transactionManager", "mongoDocRow": "mongoTransactionManager",
            "mongoDocRowAfter": "mongoTransactionManager", "mongoRowDoc": "mongoTransactionManager", "nested": "transactionManager", "plain": "", "scoped": "transactionManager"}
    got = dict(re.findall(r"^  the harness's Dual\.(\w+): @Transactional\(\"(\w*)\"\)$", t, re.M))
    ok(got == want, "each method's @Transactional value (plain names none)")
    ok("  the harness's Inner.doc: @Transactional(\"mongoTransactionManager\")" in t, "Inner.doc: @Transactional(\"mongoTransactionManager\")")
    VALUES.append("[transactionManager, mongoTransactionManager] -> [JpaTransactionManager, MongoTransactionManager], JPA's @Primary")


MATRIX = {"plain": ((0, 1), "after both writes"), "jpaRowDoc": ((0, 1), "after both writes"), "jpaDocRowAfter": ((0, 1), "after both writes"),
          "jpaDocRow": ((0, 1), "between the writes"), "mongoRowDoc": ((1, 0), "after both writes"), "mongoDocRowAfter": ((1, 0), "after both writes"),
          "mongoDocRow": ((0, 0), "between the writes"), "nested": ((0, 1), "in the outer, after the inner returned")}


def dual(p):
    t = rd(p); migrations(t)
    ok("  the harness's transaction managers: [transactionManager, mongoTransactionManager] -> [JpaTransactionManager, MongoTransactionManager]" in t, "the bean list: both managers")
    names = [m + " planted" for m in MATRIX] + [m + " control" for m in MATRIX]
    j = witnesses(t, names); o = outcomes(t); cells = []
    for m, (rd_, where) in MATRIX.items():
        ok(j.get(m + " planted") == rd_, "%s, planted %s: rows %d / documents %d" % (m, where, rd_[0], rd_[1]))
        ok(o.get(m + " planted") == "caller caught java.lang.IllegalStateException: PLANTED " + where, "%s, planted: the exception printed, IllegalStateException" % m)
        ok(j.get(m + " control") == (1, 1) and o.get(m + " control") == "caller saw no exception", "%s, the control: 1 / 1, no exception" % m)
        cells.append("%s %d/%d" % (m, rd_[0], rd_[1]))
    ok("  the harness JVM's exit 0" in t, "the harness's exit 0 (it catches)")
    pr, md = wit(t)
    ok(sum(pr.values()) == sum(v[0] for v in j.values()) and sum(md.values()) == sum(v[1] for v in j.values()), "the totals: psql %d rows = the harness's %d · mongosh %d documents = the harness's %d" % (sum(pr.values()), sum(v[0] for v in j.values()), sum(md.values()), sum(v[1] for v in j.values())))
    VALUES.append("planted: " + ", ".join(cells) + "; every control 1/1")


def scoped(p):
    t = rd(p); migrations(t)
    o = outcomes(t); j = witnesses(t, ["scoped planted", "scoped control"])
    ok(o.get("scoped planted") == "caller saw no exception" and j.get("scoped planted") == (1, 0), "planted in the listener: the caller saw no exception, rows 1 / documents 0")
    ok("the start's log: TransactionSynchronization.afterCompletion threw exception lines 1" in t, "Spring's afterCompletion threw exception line: 1")
    ok(o.get("scoped control") == "caller saw no exception" and j.get("scoped control") == (1, 1), "the control: 1 / 1")
    VALUES.append("planted in the AFTER_COMMIT listener: rows 1 / documents 0, the caller saw no exception; control 1 / 1")


def sockets(p):
    t = rd(p)
    m = re.search(r"the sockets: listening \(TCP\) on ([0-9, ]+) · connections from another local port \(outbound\): (\d+) · UDP sockets: (\d+)", t)
    ok(m is not None and m.group(1).strip() == "27017" and m.group(2) == "0" and m.group(3) == "0", "the replica set's container: listening on 27017, outbound 0, UDP 0")
    i = re.search(r"its interfaces \(/proc/net/dev\): (\S+)", t)
    VALUES.append("listening 27017, outbound 0, UDP 0; interfaces " + (i.group(1) if i else "?"))


def footprint(p):
    t = rd(p)
    for s in ("postgres-1", "redis-1", "mongo-1", "elasticsearch-1"): ok("tiffinbox-dev-" + s in t, "the project's container tiffinbox-dev-" + s)
    ok(re.search(r"the mongo service \(a standalone, Part A's flag 6\): its command (\S+) · no --replSet", t) is not None and "--replSet\"" not in t, "the mongo service: a standalone (no --replSet)")
    ok("Successfully applied 4 migrations" in t and "dishes re-indexed" in t, "the dev start: Flyway 4, the re-index")
    ok(re.search(r"GET /dishes/search\?q=veg \(TiffinBox, 20630\) -> 200 1 hit\(s\), ids \[1\]", t) is not None, "one search: veg 1 hit [1]")
    ok("the containers docker stats listed: 4 of the project's" in t, "docker stats: the project's four containers")
    ok("<mem>" in t and not re.search(r"\d+(\.\d+)?(MiB|GiB) ", t), "the reading masked in the capture (a one-shot reading)")
    ok("listening on 18881-18884: 0" in t and "the mongo service's two anonymous volumes: " in t, "the window down -v, the two volumes by name, the ports free")
    VALUES.append("four containers, Mongo a standalone; the reading in the run's log")


def default(p):
    t = rd(p)
    ok("GET /actuator/health -> 200" in t, "health 200")
    ok("GET /dishes/search?q=veg -> 404 · GET /revenue/by-customer -> 404 · GET /menu/day-19 -> 404 · GET /revenue -> 200 · GET /kitchen -> 200" in t, "404 x3, 200, 200")
    ok("lines naming 9200 0 · naming elasticsearch, any case 0 · naming 27017 0 · naming mongo, any case 0" in t, "0 Elasticsearch lines, 0 MongoDB lines")
    ok("md5 (flag 11 - the README is not in the jar): equal" in t, "after/'s jar = before/'s, md5")
    m = re.search(r"BOOT-INF/lib (\d+) and (\d+)", t)
    ok(m is not None and m.group(1) == m.group(2), "BOOT-INF/lib: the same count on both")
    VALUES.append("health 200, 404 x3, 0 Elasticsearch / 0 MongoDB lines, the two jars md5-equal, BOOT-INF/lib %s" % (m.group(1) if m else "?"))


def seven(p, h):
    t = rd(p)
    ms = re.findall(r"the seven responses: (\d+) lines · md5 ([0-9a-f]{32})", t)
    ok(len(ms) == 2 and all(x == ("7", h) for x in ms), "before/ and after/: 7 lines, md5 %s each" % h)
    ok("lines that differ: 0" in t, "after/ against before/: 0 lines differ")
    VALUES.append("7 lines, md5 " + h + " on before/ and after/")


def readme(r, v):
    t = rd(r); vals = rd(v).strip()
    m = re.search(r"<!-- values: begin -->\n(.*?)\n<!-- values: end -->", t, re.S)
    ok(m is not None and m.group(1).strip() == vals, "README.md's values block = the captures' values line")
    caps = set()
    for f in os.listdir(U):
        if f.startswith(".r-") and f.endswith(".out"): caps |= {l.rstrip() for l in rd(os.path.join(U, f)).splitlines()}
    bl = re.findall(r"^```text\n(.*?)^```$", t, re.S | re.M); n = bad = 0
    for b in bl:
        for l in b.splitlines():
            n += 1
            if l.rstrip() not in caps: bad += 1; print("  not printed by a run: " + l[:140])
    ok(bad == 0, "R.302: %d lines in %d text blocks, each a line a capture printed" % (n, len(bl)))


if __name__ == "__main__":
    n = sys.argv[1]; a = sys.argv[2:]
    {"static": lambda: static(), "exercise": lambda: exercise(*a), "wib": lambda: wib(*a), "jars": lambda: jars(*a), "handoff": lambda: handoff(*a),
     "mtm": lambda: mtm(*a), "mtmnamed": lambda: mtmnamed(*a), "both": lambda: both(*a), "dual": lambda: dual(*a), "scoped": lambda: scoped(*a),
     "sockets": lambda: sockets(*a), "footprint": lambda: footprint(*a), "default": lambda: default(*a), "seven": lambda: seven(*a),
     "readme": lambda: readme(*a)}[n]()
    if VALUES: print("VALUES " + "; ".join(VALUES))
    sys.exit(1 if FAILS else 0)
