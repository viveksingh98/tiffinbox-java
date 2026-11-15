"""Unit 32's checks (python3 -I -B harness/chk32.py MODE CAPTURE [CAPTURE...]): every number and string the video says, read off its
capture and asserted against another witness of the same run - never against a typed figure. Each mode prints one line per check and
a VALUES line (the values the video may say, composed from what it read). Exit 1 on the first failed check.
  setup  the two sets (the ls -l sizes summed again and counted, against the receipt's line and dependency:list's "added" lines); per
         JVM the version lines; the keys read off the run; the regions; HHH90001006 by grep -c = the regions counted, and 0 with
         missing_cache_strategy=create; the start without the module refused with its cause; the control's regions [] and a SELECT per
         read; Ehcache's stderr counted (WARNING: and objectFieldOffset, each > 0 and = its lines shown), Caffeine's stderr 0
  ratio  (ratio + setup) per K: M read back, reads = K x M, the region's miss = put = M and hit = (K - 1) x M, the three witnesses =
         M, getConnection = getConnectCount = K x M; the ratio derived two ways, hits / (hits + misses) and (K - 1) / K, equal; the
         collection region; Ehcache's K = 5 counts = Caffeine's
  trap   per database: the three readings (the cached read, the database's own value, the uncached entity) with their statement
         deltas and region counts; the database-truth line; Hibernate's native and JPQL bulk updates (both cached customers miss
         after); the edit through Hibernate (put 1, its UPDATE read off the log, the next read a hit with the new value); H2 = PG
  query  per database: three runs (miss put, hit, hit), an INSERT into customer (miss put), an INSERT into pause (hit)"""
import re, sys

mode, files = sys.argv[1], sys.argv[2:]
T = [open(f, encoding="utf-8").read() for f in files]
VALS = []


def need(ok, what):
    print(("  ok    " if ok else "  FAIL  ") + what)
    if not ok:
        sys.exit(1)


VERS = ["  PROBE Hibernate ORM core version (org.hibernate.Version.getVersionString()): 7.4.13.Final",
        "  INFO  [main] org.hibernate.orm.core : HHH000001: Hibernate ORM core version 7.4.13.Final",
        "  PROBE Spring Data JPA version (JpaRepository.class.getPackage().getImplementationVersion()): 4.1.2",
        "  PROBE Spring Framework version (Transactional.class.getPackage().getImplementationVersion()): 7.0.10"]


def jvms(t):
    """The capture cut at each JVM's command line: [(the lines before it, back to the last JVM - its CP/V lines), its own lines]."""
    out, cur = [], None
    for line in t.splitlines():
        if line.startswith("$ cd .harness/run && "):
            cur = [line]; out.append(cur)
        elif cur is not None:
            cur.append(line)
    return out


def vers(b, what):
    for v in VERS:
        need(b.count(v) == 1, "%s: the version line once: %s" % (what, v.strip()))


def exitof(b):
    for l in b:
        m = re.match(r"  exit (\d+) · 'GenerationTarget encountered exception': (\d+)$", l)
        if m:
            return int(m.group(1)), int(m.group(2))
    return None


def delta(l):
    m = re.search(r"statements: Statistics\.getPrepareStatementCount (\d+) · org\.hibernate\.SQL lines (\d+) · JDBC proxy prepareStatement (\d+) "
                  r"\| connections: JDBC proxy getConnection (\d+) · Statistics\.getConnectCount (\d+)", l)
    if not m:
        return None
    d = {"st": int(m.group(1)), "sql": int(m.group(2)), "prep": int(m.group(3)), "conn": int(m.group(4)), "cc": int(m.group(5))}
    for r, h, mi, p in re.findall(r"region (\S+): hit (\d+) · miss (\d+) · put (\d+)", l):
        d[r] = (int(h), int(mi), int(p))
    q = re.search(r"query cache \(Statistics\.getQueryCacheHitCount · Miss · Put\): hit (\d+) · miss (\d+) · put (\d+)", l)
    if q:
        d["qc"] = tuple(int(x) for x in q.groups())
    return d


def three(d, what):
    need(d is not None, what + ": its counters printed")
    need(d["st"] == d["sql"] == d["prep"], "%s: the three witnesses agree - Statistics.getPrepareStatementCount %d · org.hibernate.SQL lines %d · JDBC proxy prepareStatement %d" % (what, d["st"], d["sql"], d["prep"]))
    return d["st"]


def one(b, rx, what):
    hits = [re.match(rx, l) for l in b]
    hits = [h for h in hits if h]
    need(len(hits) == 1, "%s: the line once (%s)" % (what, rx[:70]))
    return hits[0]


def regions(b):
    m = one(b, r"  PROBE regions \(Statistics\.getSecondLevelCacheRegionNames\(\), sorted\): \[(.*)\]$", "the regions")
    return [x for x in m.group(1).split(", ") if x]


def line(b, prefix):
    l = [x for x in b if x.startswith(prefix)]
    return l


KC = "probe.k.ent.KCustomer"
KCP = "probe.k.ent.KCustomer.pauses"
KP = "probe.k.ent.KPause"
QR = "default-query-results-region"

if mode == "setup":
    t = T[0]
    sets = {}
    for s in ("caffeine", "ehcache"):
        sec = t.split("the %s set - harness/%s/pom.xml" % (s, s), 1)
        need(len(sec) == 2, "%s: its set is listed" % s)
        body = sec[1].split("\n(ii)", 1)[0].split("\nthe ehcache set", 1)[0]
        dl = re.findall(r"^  ([^ ]+) - (added|in the anchor's lib/) \(([^)]+)\)$", body, re.M)
        lsl = re.findall(r"^  (\d+) (\S+\.jar)$", body, re.M)
        m = re.search(r"^  the %s set, added: (\d+) jars, (\d+) bytes \(ls \| wc -l; ls -l's sizes summed by awk\) · dependency:list's 'added' lines: (\d+)$" % s, body, re.M)
        need(m is not None, "%s: the receipt's added line" % s)
        n, b, nd = int(m.group(1)), int(m.group(2)), int(m.group(3))
        added = sorted(j for _, k, j in dl if k == "added")
        need(len(lsl) == n and sum(int(x) for x, _ in lsl) == b, "%s: ls -l's lines counted again (%d) and summed again (%d) = the receipt's %d jars, %d bytes" % (s, len(lsl), sum(int(x) for x, _ in lsl), n, b))
        need(nd == n == len(added) and sorted(j for _, j in lsl) == added, "%s: dependency:list's added jars (%d) = the jars ls -l shows, name for name" % (s, len(added)))
        inlib = sorted(j for _, k, j in dl if k != "added")
        sets[s] = (n, b, added, inlib)
    jx = [j for j in sets["ehcache"][3] if "jaxb" in j]
    need(len(jx) > 0, "ehcache: its JAXB jars are in the anchor's lib/ already (not added): " + " ".join(jx))
    lib = re.search(r"^setup - switching it on, on H2; the anchor's lib/ holds (\d+) jars", t, re.M)
    need(lib is not None, "the anchor's lib/ count printed")
    B = jvms(t)
    need(len(B) == 5, "five JVMs: the default strategy, create, the refusal, the control, Ehcache (%d)" % len(B))
    for i, b in enumerate(B):
        vers(b, "JVM %d" % (i + 1))
    # (ii)-(iv) the default strategy
    b = B[0]
    keys = dict(re.findall(r"^  PROBE key \(EntityManagerFactory\.getProperties\(\)\): (\S+) = (.*)$", "\n".join(b), re.M))
    prov = one(b, r"  PROBE JCache providers on the class path \(javax\.cache\.Caching\.getCachingProviders\(\)\): \[(\S+)\]$", "default: the providers").group(1)
    need(keys.get("hibernate.cache.use_second_level_cache") == "true" and keys.get("hibernate.cache.region.factory_class") == "jcache"
         and keys.get("hibernate.javax.cache.provider") == prov and keys.get("jakarta.persistence.sharedCache.mode") == "ENABLE_SELECTIVE",
         "default: the four keys read off the EntityManagerFactory, the provider = the one JCache provider on the class path (%s)" % prov)
    need(keys.get("hibernate.javax.cache.missing_cache_strategy") == "null", "default: missing_cache_strategy not set")
    one(b, r"  PROBE region factory in use .*: org\.hibernate\.cache\.jcache\.internal\.JCacheRegionFactory$", "default: the JCache region factory")
    R = regions(b)
    need(R == sorted([KC, KCP, KP]), "default: the regions - the two entities and the collection: " + ", ".join(R))
    w = one(b, r"  its WARN lines \(grep -c '\^WARN '\): (\d+) · HHH90001006 lines \(grep -c 'HHH90001006'\): (\d+)$", "default: the WARN counts")
    shown = [l for l in b if "HHH90001006: Missing cache region [" in l]
    named = sorted(re.search(r"Missing cache region \[([^\]]+)\]", l).group(1) for l in shown)
    need(int(w.group(2)) == len(R) == len(shown) and named == R and int(w.group(1)) == int(w.group(2)),
         "default: HHH90001006 by grep -c %s = the regions counted %d = the lines shown, one per region by name; every WARN line is one" % (w.group(2), len(R)))
    text = re.search(r"(HHH90001006: Missing cache region \[)[^\]]+(\] was created with provider-specific default policies\.)", shown[0])
    htext = text.group(1) + "…" + text.group(2)
    need(exitof(b) == (0, 0), "default: exit 0")
    # create
    b = B[1]
    keys2 = dict(re.findall(r"^  PROBE key \(EntityManagerFactory\.getProperties\(\)\): (\S+) = (.*)$", "\n".join(b), re.M))
    need(keys2.get("hibernate.javax.cache.missing_cache_strategy") == "create", "create: the fifth key read off the run")
    w2 = one(b, r"  its WARN lines \(grep -c '\^WARN '\): (\d+) · HHH90001006 lines \(grep -c 'HHH90001006'\): (\d+)$", "create: the WARN counts")
    need(w2.group(1) == "0" and w2.group(2) == "0" and regions(b) == R, "create: HHH90001006 by grep -c 0, WARN 0, the same regions")
    # stderr of Caffeine's JVMs
    for i in (0, 1):
        e = one(B[i], r"  its stderr \(\.harness/h\.err\): (\d+) lines · grep -c '\^WARNING:' (\d+) · grep -c 'objectFieldOffset' (\d+)$", "Caffeine JVM %d: stderr" % (i + 1))
        need(e.groups() == ("0", "0", "0"), "Caffeine JVM %d: stderr 0 lines, WARNING: 0" % (i + 1))
    # (v) the refusal and the control
    b = B[2]
    need(exitof(b) == (1, 0), "no module, the keys on: exit 1 (ready: no)")
    cause = [l for l in b if l.startswith("  PROBE caused by: ")]
    need(len(cause) > 0 and cause[-1] == "  PROBE caused by: java.lang.ClassNotFoundException: Could not load requested class: jcache", "no module, the keys on: the cause, read off the chain: " + (cause[-1].strip() if cause else "none"))
    need(not line(b, "  PROBE regions"), "no module, the keys on: no context, no regions")
    b = B[3]
    one(b, r"  PROBE region factory in use .*: org\.hibernate\.cache\.internal\.NoCachingRegionFactory$", "control: NoCachingRegionFactory")
    need(regions(b) == [], "control: regions []")
    rd = one(b, r"  PROBE reads (\d+) \| (.*)$", "control: the reads")
    dc = delta(rd.group(0))
    need(three(dc, "control") == int(rd.group(1)) and KC not in dc, "control: a SELECT per read - %s statements for %s reads, no region (@Cache ignored)" % (dc["st"], rd.group(1)))
    wc = one(b, r"  its WARN lines \(grep -c '\^WARN '\): (\d+) · HHH90001006 lines \(grep -c 'HHH90001006'\): (\d+)$", "control: the WARN counts")
    need(wc.groups() == ("0", "0"), "control: WARN 0, HHH90001006 0")
    # (vi) Ehcache
    b = B[4]
    pe = one(b, r"  PROBE JCache providers on the class path \(javax\.cache\.Caching\.getCachingProviders\(\)\): \[(\S+)\]$", "Ehcache: the providers").group(1)
    ke = dict(re.findall(r"^  PROBE key \(EntityManagerFactory\.getProperties\(\)\): (\S+) = (.*)$", "\n".join(b), re.M))
    need(ke.get("hibernate.javax.cache.provider") == pe and "ehcache" in pe, "Ehcache: its provider read off the run = the key: " + pe)
    e = one(b, r"  its stderr \(\.harness/h\.err\): (\d+) lines · grep -c '\^WARNING:' (\d+) · grep -c 'objectFieldOffset' (\d+)$", "Ehcache: stderr")
    sl = [l[len("  stderr: "):] for l in b if l.startswith("  stderr: ")]
    nw, no = int(e.group(2)), int(e.group(3))
    need(nw > 0 and nw == sum(1 for l in sl if l.startswith("WARNING:")) and int(e.group(1)) == len(sl), "Ehcache: stderr WARNING: by grep -c %d = the WARNING: lines shown, > 0 (the loser's warning captured)" % nw)
    need(no > 0 and no == sum(1 for l in sl if "objectFieldOffset" in l), "Ehcache: objectFieldOffset by grep -c %d = the lines naming it, > 0" % no)
    need(exitof(b) == (0, 0), "Ehcache: exit 0")
    VALS.append("Caffeine's set (hibernate-jcache + Caffeine's jcache): %d jars added, %d bytes (%s)" % (sets["caffeine"][0], sets["caffeine"][1], " ".join(sets["caffeine"][2])))
    VALS.append("Ehcache's set (hibernate-jcache + ehcache jakarta): %d jars added, %d bytes (%s); its JAXB already in the anchor's lib/: %s" % (sets["ehcache"][0], sets["ehcache"][1], " ".join(sets["ehcache"][2]), " ".join(jx)))
    VALS.append("the anchor's lib/: %s jars" % lib.group(1))
    VALS.append("the keys: hibernate.cache.use_second_level_cache=true, hibernate.cache.region.factory_class=jcache, hibernate.javax.cache.provider=%s, jakarta.persistence.sharedCache.mode=ENABLE_SELECTIVE" % prov)
    VALS.append("regions: " + ", ".join(R))
    VALS.append("HHH90001006 (%s) by grep -c: %s, one per region; with missing_cache_strategy=create: 0" % (htext, w.group(2)))
    VALS.append("without the module, the keys on: exit 1, %s; the keys off: regions [], %d statements for %s reads, WARN 0" % (cause[-1].strip()[len("PROBE caused by: "):], dc["st"], rd.group(1)))
    VALS.append("Ehcache (the loser, labelled): stderr WARNING: %d, objectFieldOffset %d, first: %s; Caffeine's stderr WARNING: 0" % (nw, no, sl[0]))

if mode == "ratio":
    t, ts = T[0], T[1]
    B = jvms(t)
    need(len(B) == 2, "two JVMs, K = 5 and K = 10")
    rows = {}
    for b in B:
        vers(b, "ratio JVM")
        lab = one(b, r"  PROBE >>> K = (\d+) rounds x M = (\d+) customers, each em\.find\(KCustomer\.class, id\) in its own transaction$", "the design")
        K, M = int(lab.group(1)), int(lab.group(2))
        Ms = int(one(b, r"  PROBE the seeded customers - .*\| M = (\d+)$", "M read back on the second connection").group(1))
        need(M == Ms, "K = %d: M = %d, read back on the second connection" % (K, Ms))
        rd = one(b, r"  PROBE reads (\d+) \| (.*)$", "K = %d: the reads" % K)
        d = delta(rd.group(0)); n = int(rd.group(1))
        h, mi, p = d[KC]
        st = three(d, "K = %d" % K)
        need(n == K * M, "K = %d: reads %d = K x M = %d x %d" % (K, n, K, M))
        need(mi == M and p == M and h == (K - 1) * M, "K = %d: region %s hit %d · miss %d · put %d = (K - 1) x M · M · M" % (K, KC, h, mi, p))
        need(st == M, "K = %d: statements %d = M (one SELECT per customer, the first round)" % (K, st))
        need(d["conn"] == d["cc"] == K * M, "K = %d: JDBC proxy getConnection %d = Statistics.getConnectCount %d = K x M (each read its own transaction, a hit included)" % (K, d["conn"], d["cc"]))
        r1 = "%.3f" % (h / (h + mi)); r2 = "%.3f" % ((K - 1) / K)
        need(r1 == r2, "K = %d: derived - hits / (hits + misses) = %d / %d = %s = (K - 1) / K = %d / %d = %s" % (K, h, h + mi, r1, K - 1, K, r2))
        rows[K] = (n, h, mi, p, st, d["conn"], d["cc"], r1, M)
        # the collection region
        tr = [re.match(r"  PROBE transaction (\d): Sunil's pauses (\d+) \| (.*)$", l) for l in b]
        tr = [x for x in tr if x]
        need(len(tr) == 3, "K = %d: the collection read in three transactions" % K)
        ds = [delta(x.group(0)) for x in tr]
        need(ds[0][KCP][1:] == (1, 1) and three(ds[0], "collection 1") == 1, "the collection's first transaction: %s miss 1 · put 1, one SELECT" % KCP)
        need(all(x[KCP][0] == 1 and three(x, "collection") == 0 for x in ds[1:]), "the collection's next two: %s hit 1 each, 0 statements" % KCP)
        tot = [sum(x[r][i] for x in ds for r in (KC, KCP, KP)) for i in range(3)]
        coll = "the collection (Sunil's pauses, three transactions): statements %s; over the three regions hit %d · miss %d · put %d; %s per transaction: %s" % (
            " · ".join(str(x["st"]) for x in ds), tot[0], tot[1], tot[2], KCP, " · ".join("hit %d miss %d put %d" % x[KCP] for x in ds))
    need(sorted(rows) == [5, 10], "the two K: 5 and 10 (read off the step labels)")
    # Ehcache's K = 5 (setup's labelled loser) = Caffeine's
    eb = jvms(ts)[-1]
    ed = delta(one(eb, r"  PROBE reads (\d+) \| (.*)$", "Ehcache: the reads").group(0))
    need(ed[KC] == rows[5][1:4] and ed["st"] == rows[5][4], "Ehcache's K = 5 (setup, labelled): hit · miss · put %s = Caffeine's %s, the same statements" % (ed[KC], rows[5][1:4]))
    for K in (5, 10):
        n, h, mi, p, st, c, cc, r, M = rows[K]
        VALS.append("K = %d, M = %d: reads %d, region %s hit %d · miss %d · put %d, statements %d (three witnesses), JDBC proxy getConnection %d = Statistics.getConnectCount %d; derived: hits / (hits + misses) = %d / %d = %s = (K - 1) / K = %d / %d" % (
            K, M, n, KC, h, mi, p, st, c, cc, h, h + mi, r, K - 1, K))
    VALS.append(coll)
    VALS.append("Ehcache's K = 5 = Caffeine's")

if mode == "trap":
    t = T[0]
    secs = re.split(r"^(H2 \(in the harness JVM's memory.*|PostgreSQL \(the container.*)$", t, flags=re.M)
    need(len(secs) == 5, "two databases, H2 then PostgreSQL")
    summ = {}
    for name, body in (("H2", secs[2]), ("PostgreSQL", secs[4])):
        b = body.splitlines()
        vers(b, name)
        need(exitof(b) == (0, 0), name + ": exit 0")
        r1 = one(b, r"  PROBE read 1 \(phase 1\): Ravi meals_per_day (\d+) \| (.*)$", name + ": read 1")
        old = int(r1.group(1)); d1 = delta(r1.group(0))
        need(three(d1, name + " read 1") == 1 and d1[KC] == (0, 1, 1), name + ": read 1 - one SELECT, a miss and a put")
        if name == "H2":
            w = one(b, r"  PROBE the outside write - plain JDBC, a second java\.sql\.Connection \(DriverManager\) on the same URL, outside Hibernate: update customer set meals_per_day = (\d+) where name = 'Ravi' - rows (\d+)$", name + ": the outside write")
            need(int(w.group(1)) == old + 1 and w.group(2) == "1", name + ": the outside write (plain JDBC) sets read 1's value + 1, one row")
            tr = [re.match(r"  PROBE database truth - the second connection reads \(select name, meals_per_day from customer where name = 'Ravi'\): Ravi (\d+)$", l) for l in b]
            writer = "plain JDBC in the JVM (a second java.sql.Connection)"
        else:
            need(b.count("  PROBE ready: phase 1 done, Ravi read %d - the JVM now blocks on System.in.read() until the receipt's outside write is done" % old) == 1, name + ": the ready line, the JVM blocked")
            tr = [re.match(r"  database truth \(psql, another process\): Ravi\|(\d+)$", l) for l in b]
            need(len([x for x in tr if x]) == 1, name + ": the database-truth line, once")
            pw = [l for l in b if l.startswith("  psql: ")]
            need(pw == ["  psql: UPDATE 1"], name + ": psql's write - UPDATE 1")
            nv = re.search(r"the JVM's read, (\d+), plus 1 = (\d+):", body)
            need(nv is not None and int(nv.group(1)) == old and int(nv.group(2)) == old + 1, name + ": the value the receipt chose = read 1's + 1")
            need(b.count("  PROBE phase 2: System.in.read() returned one byte") == 1, name + ": the JVM went on after one byte")
            writer = "psql in the container (another process)"
        tr = [x for x in tr if x]
        need(len(tr) == 1, name + ": the database-truth line, once")
        new = int(tr[0].group(1))
        need(new == old + 1, name + ": the database's value %d = the outside write's" % new)
        r2 = one(b, r"  PROBE read 2 \(the cached KCustomer\): Ravi meals_per_day (\d+) \| (.*)$", name + ": read 2")
        d2 = delta(r2.group(0))
        need(int(r2.group(1)) == old and d2[KC] == (1, 0, 0) and three(d2, name + " read 2") == 0, name + ": read 2 - the old value %d, a hit, 0 statements (the database says %d)" % (old, new))
        r3 = one(b, r"  PROBE read 3 \(the anchor's CustomerEntity, not cached, findByName\): Ravi meals_per_day (\d+) \| (.*)$", name + ": read 3")
        d3 = delta(r3.group(0))
        need(int(r3.group(1)) == new and three(d3, name + " read 3") == 1, name + ": read 3 (uncached) - the new value %d, one SELECT" % new)
        out = ["database: %s - read 1 Ravi %d (miss 1 · put 1, statements 1); %s sets %d; the database: Ravi %d; read 2 (cached) Ravi %d (hit 1, statements 0); read 3 (the anchor's CustomerEntity, uncached) Ravi %d (statements 1)" % (name, old, writer, new, new, old, new)]
        for tag, how in (("(b1)", "nativeBump"), ("(b2)", "jpqlBump")):
            seg = body.split("PROBE >>> " + tag, 1)[1].split("PROBE <<< " + tag, 1)[0].splitlines()
            bp = one(seg, r"  PROBE %s\(\"Meera\"\) - rows (\d+) \| (.*)$" % how, name + " " + tag)
            txt = one(seg, r"  PROBE its SQL texts \(org\.hibernate\.SQL\): 1 x (.*)$", name + " " + tag + " text").group(1)
            truth = one(seg, r"  PROBE database truth - the second connection reads: Meera (\d+) · Priya (\d+)$", name + " " + tag + " truth")
            af = [re.match(r"  PROBE after: (Meera|Priya) meals_per_day (\d+) \| (.*)$", l) for l in seg]
            af = [x for x in af if x]
            need(len(af) == 2 and all(delta(x.group(0))[KC][1:] == (1, 1) for x in af), name + " " + tag + ": the next reads of Meera AND Priya both miss (and put) - the region emptied")
            need(int(af[0].group(2)) == int(truth.group(1)) and int(af[1].group(2)) == int(truth.group(2)), name + " " + tag + ": the reads after = the database's values")
            bf = [re.match(r"  PROBE before: (Meera|Priya) meals_per_day (\d+) \| (.*)$", l) for l in seg]
            bf = [x for x in bf if x]
            out.append("%s %s(\"Meera\"): rows %s, %s; the next reads Meera %s and Priya %s both miss (before it: %s)" % (
                tag, how, bp.group(1), txt, af[0].group(2), af[1].group(2), " · ".join("%s %s" % ("hit" if delta(x.group(0))[KC][0] else "miss", x.group(1)) for x in bf)))
        seg = body.split("PROBE >>> (b3)", 1)[1].split("PROBE <<< (b3)", 1)[0].splitlines()
        ed = one(seg, r"  PROBE the edit: Priya meals_per_day set to (\d+) \| (.*)$", name + " (b3)")
        de = delta(ed.group(0))
        need(de[KC][2] == 1 and three(de, name + " (b3)") == 1, name + " (b3): the edit through Hibernate - put 1, one statement")
        txt = one(seg, r"  PROBE its SQL texts \(org\.hibernate\.SQL\): 1 x (.*)$", name + " (b3) text").group(1)
        need(txt.startswith("update customer set ") and txt.endswith(" where id=? and version=?") and "version=?" in txt, name + " (b3): its UPDATE read off the log carries the version: " + txt)
        aft = one(seg, r"  PROBE after: Priya meals_per_day (\d+) \| (.*)$", name + " (b3) after")
        da = delta(aft.group(0))
        need(int(aft.group(1)) == int(ed.group(1)) and da[KC] == (1, 0, 0) and three(da, name + " (b3) after") == 0, name + " (b3): the next read a hit with the new value, 0 statements")
        out.append("(b3) the edit through Hibernate: put 1, %s; the next read Priya %s, a hit, statements 0" % (txt, aft.group(1)))
        summ[name] = out
    VALS.append(" ; ".join(summ["H2"]))
    same = [a.split(" - ", 1)[1].replace("plain JDBC in the JVM (a second java.sql.Connection)", "W") == b.split(" - ", 1)[1].replace("psql in the container (another process)", "W")
            for a, b in zip(summ["H2"][:1], summ["PostgreSQL"][:1])] + [a == b for a, b in zip(summ["H2"][1:], summ["PostgreSQL"][1:])]
    need(all(same), "H2 = PostgreSQL for every reading (the writer aside)")
    VALS.append(summ["PostgreSQL"][0] + " ; H2 = PostgreSQL for every line above but the writer")

if mode == "query":
    t = T[0]
    secs = re.split(r"^(H2 \(in the harness JVM's memory\):|PostgreSQL \(the container, a fresh database\):)$", t, flags=re.M)
    need(len(secs) == 5, "two databases, H2 then PostgreSQL")
    res = {}
    for name, body in (("H2", secs[2]), ("PostgreSQL", secs[4])):
        b = body.splitlines()
        vers(b, name)
        need(exitof(b) == (0, 0), name + ": exit 0")
        need(QR in regions(b), name + ": the regions include " + QR)
        runs = {}
        for l in b:
            m = re.match(r"  PROBE run (\d): the query returned \[(.*?)\] \| (.*)$", l)
            if m:
                runs[int(m.group(1))] = (m.group(2), delta(m.group(0)))
        need(sorted(runs) == [1, 2, 3, 4, 5], name + ": five runs of the query")
        q = {k: v[1][QR] for k, v in runs.items()}
        st = {k: three(v[1], "%s run %d" % (name, k)) for k, v in runs.items()}
        need(all(runs[k][1]["qc"] == q[k] for k in runs), name + ": Statistics.getQueryCache*Count = the region's, every run")
        tot = tuple(sum(q[k][i] for k in (1, 2, 3)) for i in range(3))
        need(q[1] == (0, 1, 1) and q[2] == (1, 0, 0) and q[3] == (1, 0, 0) and st[1] == 1 and st[2] == st[3] == 0, name + ": three runs - miss put (one SELECT), hit, hit (0 statements); hit %d · miss %d · put %d" % tot)
        ins = [l for l in b if l.startswith("  PROBE its SQL texts (org.hibernate.SQL): ")]
        need(len(ins) == 2 and "insert into customer " in ins[0] and "insert into pause " in ins[1], name + ": the two INSERTs read off the log - customer, then pause")
        need(q[4] == (0, 1, 1) and st[4] == 1 and runs[4][0] != runs[3][0], name + ": after the INSERT into customer the query misses and puts, one SELECT, and returns the new row")
        need(q[5] == (1, 0, 0) and st[5] == 0 and runs[5][0] == runs[4][0], name + ": after the INSERT into pause it hits, 0 statements (the query reads no pause)")
        res[name] = "runs 1-3 hit %d · miss %d · put %d on %s (statements %s); an INSERT into customer: miss %d · put %d (statements %d); an INSERT into pause: hit %d (statements %d)" % (
            tot[0], tot[1], tot[2], QR, " · ".join(str(st[k]) for k in (1, 2, 3)), q[4][1], q[4][2], st[4], q[5][0], st[5])
    need(res["H2"] == res["PostgreSQL"], "H2 = PostgreSQL")
    VALS.append("both databases: " + res["H2"])

print("VALUES " + " ; ".join(VALS))
