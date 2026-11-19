"""Unit 16's checks (python3 -I -B harness/chk16.py NAME ARGS...). Each capture's numbers are asserted against a second witness of the
same run - never a typed figure (R.398): Java's answers (the harness's publisher's receivers, the subscriber's list, the consumers'
read / acknowledged / claimed counts, the listener container's received and acknowledged, opsForStream().size and pending(...); the
context's StringRedisTemplate over KitchenEvents' stream) against redis-cli inside the Redis container (PUBLISH, PUBSUB NUMSUB, XLEN,
XRANGE, XPENDING, XINFO, --scan, CONFIG GET, INFO persistence, DBSIZE, MONITOR) and psql; the API's statuses against the table's rows;
the container's log lines against the restart; Surefire's XML against Maven's Results lines; the seven's md5 against Course 7's.
Prints ok/FAIL lines and one VALUES line; exits 1 on any FAIL.
  static AFTER BEFORE   the change itself, read off the files (C3), and receipts.sh's and the harness's own rules (R.410-R.412)
  r250 AFTER BEFORE     the anchor README's, compose's and Javadoc's sentences C3 made false or incomplete: noted, or kept true
  wib CAPTURE FILE      the lines the exercise's block printed for FILE (bash's), for receipts.sh to compare with "What it prints"
  exercise|anchor|pubsub|dropped|group|pending|trim|persist|default|seven CAPTURE [...]"""
import difflib, filecmp, hashlib, os, re, sys

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
NETTY = "Netty's DNS line on macOS"
W = "tiffinbox-web/src/main/java/com/tiffinbox/web/"
KE = W + "KitchenEvents.java"
CY = "compose.yaml"; IT = "tiffinbox-web/src/test/java/com/tiffinbox/web/RedisDatastoreIT.java"
K = "tiffinbox:kitchen-events"
FIELDS = "type customer-added name Asha mealType VEGAN"


def rd(t, p): return open(os.path.join(t, p), encoding="utf-8").read()


def code(t): return [l for l in t.splitlines() if not l.strip().startswith(("*", "/**", "*/", "//"))]


def adds(B, A, p):
    return [l for l in difflib.unified_diff(rd(B, p).splitlines(), rd(A, p).splitlines(), lineterm="", n=0) if l[:1] in "+-" and not l.startswith(("+++", "---"))]


def exitline(body, code_, msg="", clean=True):
    rx = r"^  exit %d · its log, every line but the harness's own PROBE lines: WARN (\d+) \(%s: (\d+)\) · ERROR (\d+) · lines naming an Exception or an Error class (\d+) · RedisConnectionFailureException (\d+)$" % (code_, re.escape(NETTY))
    m = [x for x in (re.match(rx, l) for l in body) if x]
    ok(len(m) >= 1, "%sthe JVM's exit is %d (%d line(s))" % (msg, code_, len(m)))
    if clean:
        for x in m:
            ok(x.group(1) == x.group(2) and x.group(3) == "0" and x.group(4) == "0" and x.group(5) == "0", "%sno exception: ERROR 0, no line naming an Exception, no RedisConnectionFailureException, WARN = Netty's DNS line only (%s)" % (msg, x.groups()))
    return m


def xfam(p):
    s = open(p, encoding="utf-8").read(); a = s.index("XFAM_S2 = {"); b = s.index("\n}\n", a) + 3
    return hashlib.md5(s[a:b].encode()).hexdigest()


def fail_unknown():
    print("FAIL no check named " + NAME); sys.exit(1)


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
    want = ["README.md", CY, IT, "new " + KE]
    ok(sorted(changed) == sorted(want), "C3: the files new and changed are KitchenEvents, compose.yaml, RedisDatastoreIT and the README - nothing gone; application.yaml, application-dev.yaml, TiffinBoxServer, CustomerRepository, CustomerAdded and the poms untouched: %s" % sorted(changed))
    ke = code(rd(A, KE)); kj = "\n".join(ke)
    ok("@Component" in ke and '@Profile("dev")' in ke and "class KitchenEvents {" in ke and "public class" not in kj, "KitchenEvents: @Component @Profile(\"dev\"), package-private (⚑4, ⚑7)")
    ok(re.search(r"@TransactionalEventListener\n    void stored\(CustomerAdded e\) \{\n        write\(e\);\n    \}", kj) is not None and "@EventListener" not in kj and "phase" not in kj, "KitchenEvents: a @TransactionalEventListener on CustomerAdded, the default phase (after the commit), calling write (⚑7)")
    wm = re.search(r"RecordId write\(CustomerAdded e\) \{\n(.*?)\n    \}", kj, re.S)
    wb = wm.group(1) if wm else ""
    ix = [wb.find(x) for x in ('var fields = new LinkedHashMap<String, String>();', 'fields.put("type", "customer-added");', 'fields.put("name", e.customer().name());', 'fields.put("mealType", e.customer().mealType());', "redis.opsForStream().add(StreamRecords.mapBacked(fields).withStreamKey(KEY));")]
    ok(-1 not in ix and ix == sorted(ix), "KitchenEvents.write: a LinkedHashMap, put in the order type, name, mealType, then one XADD on KEY (R.411): %s" % ix)
    ok("Map.of" not in kj and "HashMap<" not in kj.replace("LinkedHashMap<", ""), "KitchenEvents: no Map.of, no HashMap (R.411)")
    ok('static final String KEY = "tiffinbox:kitchen-events";' in kj and "private final StringRedisTemplate redis;" in kj, "KitchenEvents: the key tiffinbox:kitchen-events, a StringRedisTemplate")
    kd = rd(A, KE)
    ok("Course 8, unit 16" in kd and "dual write" in kd and "not measured" in kd and "after the commit" in kd and 'profile "dev"' in kd, "KitchenEvents' Javadoc: Course 8, unit 16 - after the commit, the dual write named and not measured, why dev-only")
    ok(not re.search(r"\b(?:guarantee\w*|durable|never lost|at-(?:least|most)-once|exactly-once|expir\w*|later|immediately)\b", kd, re.I), "KitchenEvents: no delivery-guarantee word, no XFAM_S2 time word (R.404, ⚑13)")
    cd = adds(B, A, CY)
    ok(all(l.startswith("+") and l[1:].lstrip().startswith("#") for l in cd) and sum("Course 8, unit 16" in l for l in cd) == 2, "compose.yaml: comment lines added only, two Course 8, unit 16 notes (the secrets note, ⚑15's sentence), no line removed")
    ca = rd(A, CY)
    ok("volumes:\n  data:" in ca and ca.count("- data:") == 1 and "still\n    # no volume" in ca, "compose.yaml: still one volume, Postgres's - none added for Redis (⚑15)")
    ok("a new container loses it, XLEN 0" in ca.replace("\n    # ", " ") and "a docker restart keeps it" in ca.replace("\n    # ", " "), "compose.yaml: the unit 16 sentence - a docker restart keeps the stream, a new container loses it (XLEN 0)")
    it = rd(A, IT)
    ok("@Import({Leaderboard.class, RedisDatastore.class, KitchenEvents.class})" in it and '@ActiveProfiles("dev")' in it and len(re.findall(r"(?m)^    @Test$", it)) == 3 and "@Autowired KitchenEvents events;" in it and "events.write(new CustomerAdded(" in it, "RedisDatastoreIT: @Import adds KitchenEvents, a third test calling write as a method (⚑14)")
    ok([l for l in adds(B, A, IT) if l.startswith("-")] == ["-@Import({Leaderboard.class, RedisDatastore.class})"], "RedisDatastoreIT: lines added only, but the @Import line, which gains KitchenEvents.class")
    ok(sorted(os.listdir(os.path.join(A, "tiffinbox-core/src/main/resources/db/migration"))) == ["V1__customer_and_pause.sql", "V2__seed.sql", "V3__customer_audit_columns.sql"], "Flyway's V1-V3, no V4")
    ok("INSERT INTO customer" in rd(A, "tiffinbox-core/src/main/resources/db/migration/V2__seed.sql") and "repo.add(" not in rd(A, W + "TiffinBoxServer.java").split("void start()")[1].split("kitchen.close();")[0], "the seed's customers are Flyway's INSERTs, and start() calls no add: a start writes nothing to the stream (RE-MEASURE 7, derived)")
    # the harness's own rules: the container drained before the factory closes (R.410), LinkedHashMap writers (R.411)
    h = open("harness/src/probe/u16/H16.java", encoding="utf-8").read()
    c3 = h[h.index("static void c3()"):h.index("static void trim()")]
    ix3 = [c3.find(x) for x in ("c.stop();", "while (sub.isActive()", 'echo("h16:c3-end");')]
    ok(-1 not in ix3 and ix3 == sorted(ix3) and "destroy" not in c3 and "close()" not in c3, "H16.c3: the container stopped, its subscription polled to inactive, then the end marker - the factory closes only after, in main (R.410): %s" % ix3)
    sb = h[h.index("static void sub(int want)"):h.index("static LinkedHashMap<String, String> fields")]
    ix4 = [sb.find(x) for x in ("c.stop();", "while ((c.isRunning() || c.isListening())", "c.destroy();")]
    ok(-1 not in ix4 and ix4 == sorted(ix4), "H16.sub: the Pub/Sub container stopped, polled to not listening, destroyed - before the factory closes (R.410): %s" % ix4)
    for f in ("harness/src/probe/u16/H16.java", "harness/src/probe/u16/U16.java", "exercise/Pending.java", os.path.join(A, KE)):
        ok("Map.of" not in "\n".join(code(open(f, encoding="utf-8").read())), "no Map.of in " + os.path.basename(f) + " (R.411)")
    # receipts.sh: every JVM it starts resets SIGINT first (R.410); every poll a count (R.412); no sleep behind the NUMSUB poll
    rs = open("receipts.sh", encoding="utf-8").read().splitlines()
    jl = [i + 1 for i, l in enumerate(rs) if not l.lstrip().startswith("#") and re.search(r"exec @ARGV' (java|javac|mvn) |alarm \d+; exec @ARGV' (java|javac|mvn) ", l) and "$SIG{INT}" not in l and "SIG{INT}" not in l]
    ok(not jl, "R.410: every java, javac and mvn receipts.sh starts runs after the perl reset ($SIG{INT}=\"DEFAULT\"): lines without it %s" % jl)
    ki = [i + 1 for i, l in enumerate(rs) if re.search(r"kill -INT", l)]
    ok(len(ki) == 1 and any("phsig()" in rs[k] for k in range(max(0, ki[0] - 4), ki[0])), "R.410: one kill -INT, in phsig, to a JVM started under the reset: lines %s" % ki)
    bad = []
    for i, l in enumerate(rs):
        if re.search(r"pollq .*PUBSUB NUMSUB", l):
            j = i + 1
            while j < len(rs) and not re.search(r"^\S|^  [a-z]+\(\) \{|; \}$", rs[j]):
                if re.search(r"\bsleep\b", rs[j]): bad.append(j + 1)
                j += 1
            if j < len(rs) and re.search(r"\bsleep\b", rs[j]): bad.append(j + 1)
    ok(not bad, "R.412: no sleep behind a PUBSUB NUMSUB poll (receipts.sh lines %s)" % bad)
    pq = [l for l in rs if l.lstrip().startswith("pollq ")]
    ok(len(pq) >= 3 and all(re.search(r'^\s*pollq "[^"]+" ("[^"]+"|\w+) (PUBSUB NUMSUB|PING)\b', l) for l in pq), "R.412: every wait on Redis is a count condition (pollq WHAT WANT PUBSUB NUMSUB|PING …): %d polls" % len(pq))
    ok(xfam("harness/s816.py") == xfam("../c8-unit15/harness/s815.py") == xfam("../c8-unit14/harness/s814.py"), "R.409: s816.py's XFAM_S2 block = s815.py's = s814.py's, byte for byte (md5 %s)" % xfam("harness/s816.py"))
    ok("Pending 20552 read" in rd("exercise", "README.md") and "Pending 20552 claim" in rd("exercise", "SOLUTION.md"), "the exercise: the README's c2 reads, the solution's claims")
    VALUES.append("C3 files 1 new + 2 changed + README")
elif NAME == "r250":
    A, B = sys.argv[2], sys.argv[3]
    R = rd(A, "README.md").splitlines()
    cy = rd(A, CY).splitlines()
    FR = [(cy, "and docker compose down keeps Postgres's data, in its volume, and loses Redis's.)", "(Course 8, unit 16: the kitchen stream too is Redis's own", 5),
          (cy, "so a new container loses nothing the next start does not save again", "(Course 8, unit 16: the kitchen stream too is Redis's own", 3),
          (cy, "(Course 8, unit 15: nor do the kitchen orders", "(Course 8, unit 16: nor does the kitchen stream", 1)]
    for T, f, note, nxt in FR:
        h = [k for k, l in enumerate(T) if f in l]
        ok(len(h) == 1, "R.250: the sentence is in its file once: " + f[:60])
        if h:
            seg = "\n".join(T[h[0]:h[0] + nxt + 1])
            ok(note in seg and seg.index(note) > seg.index(f), "R.250: its unit 16 note follows it: " + f[:60])
    # true, kept: each names CustomerFeed as a listener - under "dev" one of two since; none says it is the only one
    KEEP = [("tiffinbox-core/src/main/java/com/tiffinbox/CustomerAdded.java", "CustomerFeed's, after the commit - hears it only once the row is in the database."),
            ("tiffinbox-core/src/main/java/com/tiffinbox/CustomerRepository.java", "stored row publishes CustomerAdded, which CustomerFeed hears after the commit."),
            ("tiffinbox-web/src/main/java/com/tiffinbox/web/CustomerFeed.java", "that repository, so none of them tells the feed itself"),
            ("tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java", "A stored customer reaches CustomerFeed's listeners through the repository's"),
            ("tiffinbox-web/src/main/resources/application-dev.yaml", "under \"dev\" the\n# start fills the leaderboard in Redis, and without Redis it stops")]
    for f, sent in KEEP:
        a = rd(A, f)
        ok(sent in a and a == rd(B, f), "R.250: kept, still true, untouched - %s: %s" % (os.path.basename(f), sent[:50].replace("\n", " ")))
        ok(not re.search(r"\b(?:only|the one|sole) (?:listener|one that hears)\b", a), "R.250: %s names no listener as the only one" % os.path.basename(f))
    ok(sum(1 for l in R if l.startswith("## Course 8 · unit 16 — ")) == 1, "the README's Course 8 · unit 16 section")
    ok(sum(1 for l in R if "*(Course 8, unit 16, **Section 3's third change to this folder**" in l) == 1, "the README's header note for unit 16")
    ok(rd(A, "README.md").count("needs no Redis") >= rd(B, "README.md").count("needs no Redis"), "the default run's \"needs no Redis\" sentences kept (still true)")
    u15 = open("../c8-unit15/README.md", encoding="utf-8").read()
    ok("U16 moves the anchor next" in u15 or "## Next" in u15 or "unit 16" in u15.lower(), "unit 15's README stays as shipped (its hand-off, now done, is quoted in this unit's README, not edited there)")
    VALUES.append("R.250 sentences %d noted (compose.yaml 3) and %d kept true" % (len(FR), len(KEEP)))
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
    ok(Wd == "23", "the spoken line is 23 words (the brief's): %s" % Wd)
    blocks, cur, sh = {}, None, None
    for l in L:
        if l.startswith("in bash") or l.startswith("in zsh"): sh = l.split()[1]
        if "the README's lines" in l: cur = (sh, "readme"); blocks[cur] = []; continue
        if "then the solution's lines" in l: cur = (sh, "sol"); blocks[cur] = []; continue
        if l.startswith("  the shell is now in"): cur = None; continue
        if cur: blocks[cur].append(l.strip())
    ok(blocks.get(("bash", "readme")) == blocks.get(("zsh", "readme")) and blocks.get(("bash", "sol")) == blocks.get(("zsh", "sol")) and blocks.get(("bash", "readme")), "bash and zsh print the same")
    r, s = blocks.get(("bash", "readme"), []), blocks.get(("bash", "sol"), [])
    def g(b, rx):
        m = [x for x in (re.match(rx, l) for l in b) if x]
        return [x.groups() for x in m]
    for b, nm in ((r, "broken"), (s, "solved")):
        d = g(b, r"^events added: (\d+) · c1 read (\d+) · acknowledged (\d+) · then c1 stops$")
        p1 = g(b, r"^redis-cli XPENDING tiffinbox:kitchen-events kitchen \(its count\): (\d+)$")
        jp = g(b, r"^the pending list, by Java: (\d+) · per consumer \{(.*)\}$")
        ok(len(d) == 1 and d[0][0] == d[0][1] and p1 and jp and int(d[0][1]) - int(d[0][2]) == int(p1[0][0]) == int(jp[0][0]) and jp[0][1] == "c1=%s" % p1[0][0], "%s: the died consumer - added = read, read - acknowledged = XPENDING's count by redis-cli = Java's, all c1's: %s %s %s" % (nm, d, p1, jp))
        for x in ("Maven: exit 0", "javac: exit 0", "docker run: exit 0", "Pending died: exit 0", "Pending c2: exit 0", "docker rm -fv: exit 0"):
            ok(x in b, "%s: %s - the check is XPENDING, never the exit (R.196)" % (nm, x))
    fr = g(r, r"^redis-cli XPENDING tiffinbox:kitchen-events kitchen \(its count\): (\d+) · XLEN tiffinbox:kitchen-events: (\d+)$")
    fs = g(s, r"^redis-cli XPENDING tiffinbox:kitchen-events kitchen \(its count\): (\d+) · XLEN tiffinbox:kitchen-events: (\d+)$")
    rd2 = g(r, r'^c2 read (\d+) new entries \(">"\) · acknowledged (\d+)$'); sc = g(s, r"^c2 claimed (\d+) of c1's pending entries · acknowledged (\d+)$")
    jr = g(r, r"^the pending list, by Java: (\d+) · per consumer \{(.*)\}$"); js = g(s, r"^the pending list, by Java: (\d+) · per consumer \{(.*)\}$")
    p0 = g(r, r"^redis-cli XPENDING tiffinbox:kitchen-events kitchen \(its count\): (\d+)$")
    dd = g(r, r"^events added: (\d+) ")
    ok(fr and rd2 and rd2[0] == ("0", "0") and len(jr) == 2 and fr[0][0] == jr[1][0] == p0[0][0] and fr[0][1] == dd[0][0], "R.196: broken - c2 reads 0 with \">\", XPENDING by redis-cli = Java's = the count before, XLEN = the events added: %s %s %s" % (fr, rd2, jr))
    ok(fs and sc and sc[0][0] == sc[0][1] == p0[0][0] and len(js) == 2 and js[1] == ("0", "") and fs[0][0] == "0" and fs[0][1] == fr[0][1], "R.196: solved - c2 claims c1's pending entries and acknowledges them, XPENDING 0 by redis-cli and Java, XLEN unchanged: %s %s %s" % (fs, sc, js))
    ok(all(re.search(r"listening on 20552 afterwards: 0 · a container named c8u16-ex: 0$", l) for l in L if l.startswith("  the shell is now in")) and sum(1 for l in L if l.startswith("  the shell is now in")) == 2, "after each shell: 20552 free, the exercise's container gone")
    if fr and fs and sc:
        VALUES.append("the line %s words · broken (c2 reads with \">\"): c2 read %s, XPENDING %s by redis-cli and Java, XLEN %s · solved (c2 claims, min-idle-time Duration.ZERO, and acknowledges): claimed %s, acknowledged %s, XPENDING %s, XLEN %s · exit 0 both (a standalone program on the anchor's libraries, Redis by the digest, no TiffinBox, no database)" % (Wd, rd2[0][0], fr[0][0], fr[0][1], sc[0][0], sc[0][1], fs[0][0], fs[0][1]))
elif NAME == "anchor":
    L = lines(sys.argv[2])
    pk = [x for x in (re.match(r"^  Surefire's Results line: Tests run: (\d+), Failures: 0, Errors: 0, Skipped: 0$", l) for l in L) if x]
    ok(len(pk) == 3, "three Results lines (package; verify's two executions): %d" % len(pk))
    n18 = int(pk[0].group(1)) if pk else 0; n18b = int(pk[1].group(1)) if len(pk) > 1 else 0; nit = int(pk[2].group(1)) if len(pk) > 2 else 0
    ok(n18 == n18b, "the package run's count = verify's first execution's: %d %d" % (n18, n18b))
    ok(any("absent - no container test ran" in l for l in L), "mvn package: no container test ran (Docker at nothing)")
    rep = [x for x in (re.match(r"^  in all: 3 reports · tests (\d+) · failures 0 · errors 0 · skipped 0$", l) for l in L) if x]
    ok(len(rep) == 3 and [int(x.group(1)) for x in rep] == [n18, n18b, nit], "Surefire's XML (surefire.py) = Maven's Results lines, all three: %s" % [x.group(1) for x in rep])
    ok(sum(1 for l in L if l.startswith("  passed  ")) == n18 + n18b + nit and "  passed  aStoredCustomerIsOneStreamEntryRedisReadsInTheOrderWritten" in L, "every test passed, the third RedisDatastoreIT test among them")
    itl = [l for l in L if l.startswith("  REDIS IT ")]
    ok(len(itl) == 6, "the IT's six lines (the board's two, the orders' two, the stream's two): %d" % len(itl))
    m1 = [l for l in itl if "through KitchenEvents' write" in l]; m2 = [re.search(r"type (\w+) · XLEN (\d+) · XRANGE's entries (\d+) · the id the write returned = XRANGE's · fields \[(.*)\]$", l) for l in itl if "XRANGE's entries" in l]
    ok(len(m1) == 1 and m1[0].endswith("an id given by Redis") and len(m2) == 1 and m2[0] and m2[0].group(1) == "stream" and m2[0].group(2) == m2[0].group(3) == "1" and m2[0].group(4) == "type=customer-added, name=Asha, mealType=VEGAN", "the IT's two witnesses on the shipped KitchenEvents: the write's id = XRANGE's, TYPE stream, XLEN = XRANGE's entries, the fields in the written order")
    libs = [(m.group(1), int(m.group(2))) for m in (re.match(r"^  (before|after)/: (\d+) libraries", l) for l in L) if m]
    ok(len(libs) == 2 and libs[0][1] == libs[1][1], "the jar's libraries unchanged (no new dependency): %s" % libs)
    ok("  gained: 0 · lost: 0" in L, "no jar gained or lost")
    ok("  the five classes in lib/spring-data-redis-4.1.2.jar (unzip -l): ChannelTopic RedisMessageListenerContainer StreamMessageListenerContainer StreamOffset StreamOperations" in L, "the five classes, in the jar the seed holds")
    starts = [s for s in sections(L) if s[0].startswith("-- start ")]
    ok(len(starts) == 3, "three starts")
    xl, orders = [], []
    for k, (h, body) in enumerate(starts, 1):
        ok(("PROBE started: yes · %s · a web server: yes" % DEVW) in body, "start %d: started under dev" % k)
        ok(("PROBE http (%s): GET /actuator/health -> 200 · status UP" % DEVW) in body and ("PROBE http (%s): GET /dashboard -> 200" % DEVW) in body and ("PROBE http (%s): GET /leaderboard -> 200" % DEVW) in body, "start %d: health 200, /dashboard 200, /leaderboard 200" % k)
        oc = [m.group(1) for m in (re.match(r"^  log: tiffinbox: orders cooked: +(\d+)$", l) for l in body) if m]
        kc = [m.group(1) for m in (re.match(r"^PROBE http \(%s\): GET /kitchen -> 200 · ordersCooked (\d+)$" % re.escape(DEVW), l) for l in body) if m]
        sc = [m.group(1) for m in (re.match(r"^  SCARD kitchen-order (\d+) · ZCARD tiffinbox:leaderboard (\d+) \(unit 14's and 15's, unchanged by unit 16\)$", l) for l in body) if m]
        ok(len(oc) == 1 and oc == kc == sc, "start %d: orders cooked = /kitchen's ordersCooked = SCARD kitchen-order (unit 15's, unchanged): %s %s %s" % (k, oc, kc, sc))
        ok(sum(1 for l in body if l == "  log: Multiple Spring Data modules found, entering strict repository configuration mode") == 3 and all(("  log: Found 1 %s repository interface" % x) in body for x in ("JPA", "JDBC", "Redis")), "start %d: strict mode, Found 1 JPA, 1 JDBC, 1 Redis repository interface (unchanged: KitchenEvents is a component)" % k)
        js = [m.groups() for m in (re.match(r"^PROBE stream \(%s, the context's StringRedisTemplate - KitchenEvents' writes\): XLEN (\d+) · TYPE (\w+) · entries \[(.*)\]$" % re.escape(DEVW), l) for l in body) if m]
        rs = [m.groups() for m in (re.match(r"^  XLEN tiffinbox:kitchen-events: (\d+) · TYPE tiffinbox:kitchen-events: (\w+) · XRANGE tiffinbox:kitchen-events - \+: (.*)$", l) for l in body) if m]
        pq = [m.groups() for m in (re.match(r"^  psql: customer rows (\d+) · rows named Asha (\d+)$", l) for l in body) if m]
        ad = [m.group(1) for m in (re.match(r"^PROBE add \(%s\): POST /customers \{\"name\":\"Asha\",\"mealsPerDay\":2,\"pricePerMeal\":110,\"mealType\":\"VEGAN\"\} -> (\d+)$" % re.escape(DEVW), l) for l in body) if m]
        ok(len(js) == 3 and len(rs) == 3 and len(pq) == 3 and ad == ["201", "409"], "start %d: three reads (after the start, after the add, after the refused add) by Java, redis-cli and psql; the API's 201 then 409: %s" % (k, ad))
        if len(js) == 3 and len(rs) == 3 and len(pq) == 3:
            jx = [int(x[0]) for x in js]; rx = [int(x[0]) for x in rs]
            ok(jx == rx, "start %d: XLEN by Java = by redis-cli at each read: %s %s" % (k, jx, rx))
            ok(all((x[1] == "none") == (int(x[0]) == 0) and x[1] in ("none", "stream") for x in js) and [x[1] for x in js] == [x[1] for x in rs], "start %d: TYPE stream (none while empty), Java's = redis-cli's" % k)
            je = [x[2].split(", ") if x[2] else [] for x in js]; re_ = [x[2].split(" | ") if x[2] else [] for x in rs]
            ok(je == re_ and all(len(e) == n for e, n in zip(je, jx)), "start %d: the entries, Java's = redis-cli's XRANGE, one per XLEN" % k)
            ok(all(e == "<id> " + FIELDS for x in je for e in x), "start %d: every entry's fields in the written order - type, name, mealType (R.411): %s" % (k, set(e for x in je for e in x)))
            ok(jx[1] == jx[0] + 1 and jx[2] == jx[1], "start %d: the add -> XLEN + 1 (one entry per stored customer), the refused add -> XLEN unchanged: %s" % (k, jx))
            ok(pq[0] == ("4", "0") and pq[1] == ("5", "1") and pq[2] == ("5", "1") and int(pq[1][0]) - int(pq[0][0]) == jx[1] - jx[0] and pq[2][0] == pq[1][0], "start %d: psql's rows beside it - the seed's (Flyway), one more row for the 201, none for the 409 = the stream's moves: %s" % (k, pq))
            xl.append(jx); orders.extend(e for x in je for e in x)
        exitline(body, 130 if k == 3 else 0, "start %d: " % k, clean=False)
        ex = [m.groups() for m in (re.match(r"^  exit (?:0|130) · its log, every line but the harness's own PROBE lines: WARN (\d+) \(%s: (\d+)\) · ERROR (\d+) · lines naming an Exception or an Error class (\d+) · RedisConnectionFailureException (\d+)$" % re.escape(NETTY), l) for l in body) if m]
        ow = [l for l in body if l.startswith("  its other WARN line: ")]
        ok(ex and ex[0][2:] == ("0", "0", "0") and int(ex[0][0]) == int(ex[0][1]) + len(ow) and sorted(ow) == sorted(["  its other WARN line: [tomcat-handler-5] org.hibernate.orm.jdbc.error : ERROR: duplicate key value violates unique constraint \"customer_name_key\"", "  its other WARN line: [tomcat-handler-5] org.hibernate.orm.jdbc.error : HHH000247: ErrorCode: 0, SQLState: 23505"]) or (ex and ex[0][2:] == ("0", "0", "0") and int(ex[0][0]) == int(ex[0][1]) + len(ow) and len(ow) == 2 and all("customer_name_key" in w or "SQLState: 23505" in w for w in ow)), "start %d: ERROR 0, no line naming an Exception, RedisConnectionFailureException 0; WARN = Netty's DNS line + PostgreSQL's two lines for the refused name (23505): %s" % (k, ex))
    ok(len(xl) == 3 and [x[0] for x in xl] == [0, 1, 2] and [x[2] for x in xl] == [1, 2, 3], "three starts against one Redis: XLEN after each start = the last start's (no start writes to the stream, no start rebuilds it): %s" % xl)
    ok(len(set(orders)) == 1, "the field order byte-equal across the three starts' entries (R.411): %s" % set(orders))
    b3 = starts[2][1] if len(starts) == 3 else []
    ok(any(l == "  the receipt at pause 4: kill -INT sent to the harness JVM (its pid, read off its own line)" for l in b3) and not any(l.startswith("PROBE <<< exit") for l in b3), "start 3: SIGINT at its pause -> exit 130, no exit line of its own")
    first = starts[0][1] if starts else []
    vl = one(first, r"^PROBE versions: Spring Boot (\S+) · Spring Framework (\S+) · Spring Data JPA (\S+) · Spring Data JDBC (\S+) · Spring Data Redis (\S+) · Lettuce (\S+?)(?:/\w+)? · Hibernate (\S+) · Flyway \(version\.txt\) (\S+)$")
    ver = vl.groups() if vl else ()
    ok(ver == ("4.1.2", "7.0.10", "4.1.2", "4.1.2", "4.1.2", "7.5.2.RELEASE", "7.4.13.Final", "12.4.0"), "the versions, off the run (R.246): %s" % (ver,))
    ok("  log: HHH000001: Hibernate ORM core version 7.4.13.Final" in first, "HHH000001's line")
    ok(("PROBE KitchenEvents beans 1 [kitchenEvents=com.tiffinbox.web.KitchenEvents @Profile[dev]] (%s)" % DEVW) in first, "the KitchenEvents bean, its class and its profile")
    ok(("PROBE StringRedisTemplate beans [stringRedisTemplate] (%s)" % DEVW) in first, "one StringRedisTemplate bean, Boot's stringRedisTemplate - the one KitchenEvents (and Leaderboard) take")
    rv = [l for l in L if l.startswith("  the Redis container's own client: ")]
    rvx = one(first, r"^PROBE Redis's INFO server, through the connection: redis_version:(\S+)$")
    ok(len(rv) == 1 and rv[0].endswith("INFO server: redis_version:8.10.3") and rvx and rvx.group(1) == "8.10.3", "redis_version 8.10.3 by redis-cli and through the connection")
    ae = one(L, r"^  after the third JVM, redis-cli: XLEN tiffinbox:kitchen-events (\d+) \(TiffinBox stopped; the stream stays in Redis\)$")
    ok(ae and xl and int(ae.group(1)) == xl[-1][2], "after the third JVM: the stream's length by redis-cli = the last read")
    if xl and vl and pk:
        VALUES.append("16/after, profile dev, PostgreSQL + Redis, KitchenEvents' writes, three starts against one Redis (a fresh database each): XLEN after the start %s · after one POST /customers (201) %s · after the refused one (409) %s · psql 4 -> 5 -> 5 each start · TYPE stream · every entry type customer-added name Asha mealType VEGAN, the order byte-equal across the starts · Found 1 JPA / 1 JDBC / 1 Redis repository interface · orders cooked = SCARD kitchen-order %s · health 200 · /dashboard 200 · /leaderboard 200 · the third SIGINT -> exit 130 · tests %d (mvn -o package, no Docker) and %d + %d (mvn -o verify) · libs %d -> %d (none gained) · Boot %s · Framework %s · Spring Data JPA/JDBC/Redis %s · Lettuce %s · HHH000001 %s · Flyway %s · redis_version:8.10.3" % (
            "/".join(str(x[0]) for x in xl), "/".join(str(x[1]) for x in xl), "/".join(str(x[2]) for x in xl), oc[0] if oc else "?", n18, n18b, nit, libs[0][1], libs[1][1], ver[0], ver[1], ver[2], ver[5], ver[6], ver[7]))
elif NAME == "pubsub":
    L = lines(sys.argv[2])
    e1 = one(L, r"^  redis-cli PUBSUB NUMSUB tiffinbox:kitchen: tiffinbox:kitchen (\d+) · redis-cli PUBLISH tiffinbox:kitchen early-cli -> (\d+)$")
    pj = [m.groups() for m in (re.match(r"^  PROBE publisher \(the harness's, convertAndSend on tiffinbox:kitchen\): (\S+) -> receivers (\d+)$", l) for l in L) if m]
    sb = one(L, r"^PROBE subscriber \(the harness's, a RedisMessageListenerContainer on ChannelTopic tiffinbox:kitchen\): listening true · heard so far (\d+)$")
    nm = one(L, r"^  poll: PUBSUB NUMSUB tiffinbox:kitchen \(until the subscriber is counted\) -> tiffinbox:kitchen (\d+), polled <k> times")
    lc = one(L, r"^  redis-cli PUBLISH tiffinbox:kitchen late-cli -> (\d+)$")
    hd = one(L, r"^PROBE subscriber: heard (\d+) \[(.*)\]$")
    sc = one(L, r"^  then redis-cli: --scan (\d+) keys · PUBSUB NUMSUB tiffinbox:kitchen: tiffinbox:kitchen (\d+)$")
    st = "PROBE subscriber: the container stopped - isRunning false · isListening false (polled to false before the factory closes)" in L
    if e1 and len(pj) == 2 and sb and nm and lc and hd and sc:
        ok(e1.group(1) == "0" and e1.group(2) == "0" and pj[0] == ("early-java", "0"), "no subscriber (NUMSUB 0): redis-cli's PUBLISH -> 0 and the publisher's convertAndSend -> receivers 0")
        ok(nm.group(1) == "1" and lc.group(1) == nm.group(1) and pj[1] == ("late-java", nm.group(1)), "the subscriber counted (NUMSUB 1, a poll): redis-cli's PUBLISH -> 1 and convertAndSend -> receivers 1 - each = NUMSUB")
        heard = hd.group(2).split(", ") if hd.group(2) else []
        late = ["late-cli"] + [x[0] for x in pj if x[1] != "0"]
        ok(int(hd.group(1)) == len(heard) == sum(1 for x in [lc.group(1)] + [x[1] for x in pj] if x != "0") and heard == late, "heard N = the publishes whose reply was not 0, in order - %s" % heard)
        ok(not any(x.startswith("early") for x in heard), "neither early message is in the list (receivers 0, not in the list)")
        ok(sc.group(1) == "0" and sc.group(2) == "0" and st, "nothing kept: --scan 0 keys; NUMSUB 0 after the subscriber stopped (its container stopped, then the factory closed)")
        VALUES.append("the harness's, Pub/Sub on tiffinbox:kitchen: no subscriber -> redis-cli PUBLISH %s and convertAndSend receivers %s · the subscriber counted (NUMSUB %s) -> %s and %s · heard %s [%s] · --scan %s keys" % (e1.group(2), pj[0][1], nm.group(1), lc.group(1), pj[1][1], hd.group(1), hd.group(2), sc.group(1)))
    else:
        ok(False, "pubsub: a line is missing")
    exitline(L, 0, "the subscriber: ")
    ok(sum(1 for l in L if l.startswith("  the publisher's exit 0 · its log: ERROR 0 · lines naming an Exception 0")) == 2, "the two publisher JVMs: exit 0, ERROR 0, no exception")
elif NAME == "dropped":
    L = lines(sys.argv[2])
    e = one(L, r"^  redis-cli PUBLISH tiffinbox:kitchen early-cli -> (\d+) · redis-cli XADD tiffinbox:kitchen-events \* type harness-entry name early-cli mealType VEG -> <id>$")
    s0 = one(L, r"^  --scan, sorted: (.*) \(no key named tiffinbox:kitchen\)$")
    hd = one(L, r"^PROBE subscriber: heard (\d+) \[(.*)\]$")
    nm = one(L, r"^  poll: PUBSUB NUMSUB tiffinbox:kitchen \(until the subscriber is counted\) -> tiffinbox:kitchen (\d+), polled <k> times")
    xr = one(L, r"^  XLEN tiffinbox:kitchen-events: (\d+) · XRANGE tiffinbox:kitchen-events - \+: (.*) · --scan, sorted: (.*)$")
    tn = one(L, r"^  then redis-cli: XLEN tiffinbox:kitchen-events (\d+) · --scan, sorted: (.*)$")
    if e and s0 and hd and nm and xr and tn:
        ok(e.group(1) == "0", "the early event on the channel, no subscriber: PUBLISH -> 0")
        ok(nm.group(1) == "1" and hd.group(1) == "0" and hd.group(2) == "", "the subscriber, counted (NUMSUB 1), heard 0 - the early event is not in its list")
        ok(s0.group(1) == xr.group(3) == tn.group(2) == "tiffinbox:kitchen-events" and "tiffinbox:kitchen" not in s0.group(1).split(), "nothing of the channel's in Redis: --scan names the stream's key alone, before and after")
        ok(xr.group(1) == tn.group(1) == "1" and xr.group(2) == "<id> type harness-entry name early-cli mealType VEG", "the same event on the stream, written before any reader: XLEN 1, its entry read back - what Pub/Sub does not keep, the stream does")
        VALUES.append("the harness's, one window: the early event's PUBLISH %s, the subscriber's list %s, --scan nothing of the channel's · the same event on the stream: XLEN %s" % (e.group(1), hd.group(1), xr.group(1)))
    else:
        ok(False, "dropped: a line is missing")
    exitline(L, 0, "the subscriber: ")
elif NAME in ("group", "pending"):
    L = lines(sys.argv[2])
    cg = one(L, r"^  redis-cli XGROUP CREATE tiffinbox:kitchen-events kitchen \$ MKSTREAM -> OK · XLEN tiffinbox:kitchen-events: 0 · XINFO GROUPS: name kitchen · consumers 0 · pending 0 · entries-read (\S+)$")
    a10 = one(L, r"^PROBE add10 \(the harness's entries, ten XADDs, a LinkedHashMap each\): ids \[(.*)\] · XLEN by Java (\d+)$")
    x10 = one(L, r"^  redis-cli XLEN tiffinbox:kitchen-events: (\d+) · XRANGE's first entry: <id> type harness-entry name entry-1 mealType VEG$")
    c1 = one(L, r"^PROBE c1 \(the harness's consumer, group kitchen\): read (\d+) \[(.*)\] · acknowledged (\d+) \[(.*)\]$")
    hp = one(L, r"^  XPENDING tiffinbox:kitchen-events kitchen: (\d+) <id> <id> c1 (\d+) · XLEN tiffinbox:kitchen-events: (\d+)$")
    ok("PROBE hold (the harness holds c1, mid-batch, planted): pid <n>" in L and "  the receipt at pause 1: kill -INT sent to the harness JVM (its pid, read off its own line)" in L and "  java processes of this script after it: 0" in L, "c1: the harness holds it (planted, labelled), SIGINT at the hold, no JVM left")
    exitline([l for l in L if l.startswith("  exit 130")], 130, "c1: ")
    xp1 = grab(L, r"^  redis-cli XPENDING tiffinbox:kitchen-events kitchen: (\d+) <id> <id> c1 (\d+)$", 1)
    xpx = one(L, r"^  redis-cli XPENDING tiffinbox:kitchen-events kitchen - \+ 10: (.*)$")
    xic = one(L, r"^  redis-cli XINFO CONSUMERS tiffinbox:kitchen-events kitchen: name c1 pending (\d+) idle <n> inactive <n> · XLEN tiffinbox:kitchen-events: (\d+)$")
    if a10 and x10 and c1 and hp and xp1 and xpx and xic and cg:
        n10 = len(a10.group(1).split(", "))
        ok(n10 == int(a10.group(2)) == int(x10.group(1)), "ten XADDs: the ids Java got = XLEN by Java = by redis-cli (%d)" % n10)
        rd_, ak = int(c1.group(1)), int(c1.group(3))
        ok(len(c1.group(2).split(", ")) == rd_ and len(c1.group(4).split(", ")) == ak and ak < rd_, "c1: read %d, acknowledged %d - the ids listed" % (rd_, ak))
        pend = rd_ - ak
        ok(int(hp.group(1)) == int(hp.group(2)) == pend and int(xp1[0].group(1)) == int(xp1[0].group(2)) == pend, "XPENDING (redis-cli) = read - acknowledged, all c1's, while the harness holds it and after the SIGINT: %d" % pend)
        ex = xpx.group(1).split(" ")
        ok(len(ex) == 4 * pend and all(ex[i:i + 4] == ["<id>", "c1", "<idle>", "1"] for i in range(0, len(ex), 4)), "XPENDING's extended form: %d entries, each c1's, delivered once (the idle column masked)" % pend)
        ok(int(xic.group(1)) == pend and int(xic.group(2)) == n10 and int(hp.group(3)) == n10, "XINFO CONSUMERS: c1 pending %d (idle masked); XLEN %d" % (pend, n10))
        V = [n10, rd_, ak, pend]
    else:
        ok(False, NAME + ": a group line is missing"); V = []
    if NAME == "group":
        c2a = one(L, r"^PROBE c2 \(the harness's consumer\): the pending list by Java before the claim: total (\d+) · per consumer \{c1=(\d+)\}$")
        c2b = one(L, r"^PROBE c2: c1's pending ids (\d+) · claimed (\d+) \[(.*)\] \(min-idle-time Duration\.ZERO\) · acknowledged (\d+)$")
        c2c = one(L, r"^PROBE c2: the pending list by Java after: total (\d+) · per consumer \{\} · XLEN by Java (\d+)$")
        x0 = one(L, r"^  redis-cli XPENDING tiffinbox:kitchen-events kitchen: (\d+) · XLEN tiffinbox:kitchen-events: (\d+)$")
        c3 = one(L, r"^PROBE c3 \(the harness's StreamMessageListenerContainer, consumer c3, no auto-ack, the listener acknowledges each\): received (\d+) \[(.*)\] · acknowledged (\d+)$")
        c3d = "PROBE c3: the container stopped, its subscription polled to inactive (isActive false, running false) - then the factory closes" in L
        c3e = one(L, r"^PROBE c3: the pending list by Java after: total (\d+) · per consumer \{\} · XLEN by Java (\d+)$")
        mon = one(L, r'^  MONITOR\'s lines between the two markers, each line\'s unix-time prefix and \[0 <client>\] stripped: XREADGROUP lines, their distinct forms: (.*) · XACK lines (\d+), their form: (.*)$')
        fin = one(L, r"^  redis-cli XPENDING tiffinbox:kitchen-events kitchen: (\d+) · XINFO GROUPS: name kitchen · consumers (\d+) · pending (\d+) · entries-read (\d+) · XLEN tiffinbox:kitchen-events: (\d+)$")
        ok("  MONITOR answered OK" in L and "  MONITOR clients left (CLIENT LIST, flags O): 0" in L and "  CLIENT KILL ID <the MONITOR client's id, read off CLIENT LIST, flags O> -> 1" in L, "MONITOR: a second client, its OK read, stopped by CLIENT KILL ID, none left")
        if V and c2a and c2b and c2c and x0 and c3 and c3e and mon and fin:
            n10, rd_, ak, pend = V
            ok(int(c2a.group(1)) == int(c2a.group(2)) == pend, "c2: the pending list by Java before the claim = redis-cli's XPENDING, all c1's (%d)" % pend)
            ok(int(c2b.group(1)) == int(c2b.group(2)) == int(c2b.group(4)) == pend and len(c2b.group(3).split(", ")) == pend, "c2: claimed = acknowledged = c1's pending (%d)" % pend)
            ok(c2c.group(1) == "0" and x0.group(1) == "0" and int(c2c.group(2)) == int(x0.group(2)) == n10, "after the claim: XPENDING 0 by Java and redis-cli; XLEN still %d - acknowledged entries stay in the stream" % n10)
            got = c3.group(2).split(", ")
            ok(int(c3.group(1)) == int(c3.group(3)) == len(got) == n10 - rd_ and got == ["entry-%d" % i for i in range(rd_ + 1, n10 + 1)], "c3, the listener container: received = acknowledged = the entries nobody was given (%d), in order: %s" % (n10 - rd_, got))
            ok(int(mon.group(2)) == int(c3.group(3)) and mon.group(3) == '"XACK" "tiffinbox:kitchen-events" "kitchen" "<id>"' and mon.group(1) == '"XREADGROUP" "GROUP" "kitchen" "c3" "BLOCK" "<n>" "STREAMS" "tiffinbox:kitchen-events" ">"', "MONITOR: the container's XREADGROUP GROUP kitchen c3 BLOCK <n> (masked) STREAMS … >, and one XACK per entry it acknowledged (%s, counted off the lines)" % mon.group(2))
            ok(c3d and c3e.group(1) == "0" and int(c3e.group(2)) == n10, "c3: the container stopped and its subscription inactive before the factory closes (R.410); XPENDING 0, XLEN %d" % n10)
            ok(fin.group(1) == fin.group(3) == "0" and fin.group(2) == "3" and int(fin.group(4)) == n10 == int(fin.group(5)), "the end, redis-cli: XPENDING 0, the group's three consumers, entries-read = XLEN = %d - every entry read and acknowledged, every entry still in the stream" % n10)
            VALUES.append("the harness's, on tiffinbox:kitchen-events: XLEN %d · c1 read %d, acknowledged %d, the harness holds (planted), SIGINT -> exit 130 · XPENDING %d, all c1's · c2 claimed %d, acknowledged %d -> XPENDING 0 · c3 (a StreamMessageListenerContainer) received and acknowledged %d, MONITOR XREADGROUP … BLOCK <n> and %s XACK · XLEN %d throughout" % (n10, rd_, ak, pend, int(c2b.group(2)), int(c2b.group(4)), int(c3.group(3)), mon.group(2), int(fin.group(5))))
        else:
            ok(False, "group: a c2/c3 line is missing")
        exitline([l for l in L if l.startswith("  exit 0")], 0, "group's JVMs: ")
    else:
        tr = one(L, r"^  the harness holds, no consumer running: XPENDING's count, ten reads with a pause of the receipt's between each: (\d+)$")
        if V and tr:
            ok(tr.group(1) == str(V[3]) * 10, "the harness holds, no consumer running: XPENDING read ten times, the same each time - nothing moves on its own: %s" % tr.group(1))
            ok(not any(l.startswith("PROBE c2") or "claimed" in l for l in L), "no claim in this window (group's c2 is the control)")
            VALUES.append("the harness's, the SIGINT'd c1 (planted hold): XPENDING %d held across ten reads (%s), XINFO CONSUMERS c1 pending %d, XLEN %d" % (V[3], tr.group(1), V[3], V[0]))
        else:
            ok(False, "pending: the ten reads are missing")
        exitline([l for l in L if l.startswith("  exit 0")], 0, "add10: ")
elif NAME == "trim":
    L = lines(sys.argv[2])
    cf = one(L, r"^  redis-cli CONFIG GET stream-node-max-entries: stream-node-max-entries (\d+) · CONFIG GET stream-node-max-bytes: stream-node-max-bytes (\d+)$")
    jt = one(L, r"^PROBE trim \(the harness's entries, a thousand XADDs, XAddOptions\.maxlen\((\d+)\)\.approximateTrimming\(true\): MAXLEN ~ (\d+)\): XLEN by Java (\d+)$")
    rt = one(L, r"^  redis-cli XLEN tiffinbox:kitchen-events: (\d+) · TYPE tiffinbox:kitchen-events: stream$")
    if cf and jt and rt:
        ok(jt.group(1) == jt.group(2) and jt.group(3) == rt.group(1), "the trim: MAXLEN ~ %s, XLEN by Java = by redis-cli (%s)" % (jt.group(2), rt.group(1)))
        ok(int(rt.group(1)) >= int(jt.group(1)) and int(rt.group(1)) < 1000, "approximate trimming keeps at least MAXLEN and fewer than the thousand added: %s" % rt.group(1))
        VALUES.append("the harness's thousand XADDs, MAXLEN ~ %s: XLEN %s by Java and redis-cli, on stream-node-max-entries %s (stream-node-max-bytes %s)" % (jt.group(2), rt.group(1), cf.group(1), cf.group(2)))
    else:
        ok(False, "trim: a line is missing")
    exitline(L, 0, "trim: ")
elif NAME == "persist":
    L = lines(sys.argv[2])
    a10 = one(L, r"^PROBE add10 \(the harness's entries, ten XADDs, a LinkedHashMap each\): ids \[(.*)\] · XLEN by Java (\d+)$")
    b = one(L, r"^  redis-cli CONFIG GET save: (.*) · CONFIG GET appendonly: (\w+) · INFO persistence: rdb_changes_since_last_save:(\d+) · XLEN tiffinbox:kitchen-events: (\d+) · DBSIZE: (\d+)$")
    pg = one(L, r"^  poll: PING \(until Redis answers\) -> PONG, polled <k> times")
    a = one(L, r"^  redis-cli XLEN tiffinbox:kitchen-events: (\d+) · DBSIZE: (\d+) · XPENDING tiffinbox:kitchen-events kitchen: (\d+) · INFO persistence: rdb_changes_since_last_save:(\d+)$")
    lg = one(L, r"^  the container's log since the restart: 'Received SIGTERM' (\d+) · 'Saving the final RDB snapshot before exiting\.' (\d+) · 'DB saved on disk' (\d+) · 'DB loaded from disk' (\d+) · 'Ready to accept connections' (\d+)$")
    ll = one(L, r"^  its line: DB loaded from disk: <t>$")
    nc = one(L, r"^  c8u16-redis: a new container, published 6379/tcp -> 127\.0\.0\.1:20552 · redis-cli XLEN tiffinbox:kitchen-events: (\d+) · DBSIZE: (\d+) · EXISTS tiffinbox:kitchen-events: (\d+) · its log: 'DB loaded from disk' (\d+)$")
    rm = "  c8u16-redis removed with its volumes (rm -fv) · listening on 20552: 0" in L
    if a10 and b and pg and a and lg and nc:
        ok(b.group(1) == "3600 1 300 100 60 10000" and b.group(2) == "no", "the image's own settings, read off the run: save 3600 1 300 100 60 10000, appendonly no")
        ok(int(b.group(4)) == int(a10.group(2)) == len(a10.group(1).split(", ")) and b.group(5) == "1" and int(b.group(3)) > 0, "before the restart: XLEN by redis-cli = Java's ten, DBSIZE 1, changes since the last save > 0 (%s)" % b.group(3))
        ok(a.group(1) == b.group(4) and a.group(2) == b.group(5) and a.group(3) == "0" and a.group(4) == "0", "after the restart: XLEN %s and DBSIZE %s as before (the group with it, XPENDING 0), changes since the last save 0 - the stream came back from dump.rdb" % (a.group(1), a.group(2)))
        ok(lg.groups() == ("1", "1", "1", "1", "1") and ll is not None, "the container's log since the restart: SIGTERM, 'Saving the final RDB snapshot before exiting.', 'DB saved on disk', 'DB loaded from disk' (its time masked), 'Ready to accept connections' - each once")
        ok(rm and nc.groups() == ("0", "0", "0", "0"), "a new container from the same digest on the same port: XLEN 0, DBSIZE 0, no key, nothing loaded - the stream is gone with the old container")
        VALUES.append("the harness's ten entries, the image's defaults (save 3600 1 300 100 60 10000, appendonly no): XLEN %s -> a restart of the container -> %s (Saving the final RDB snapshot, DB saved on disk, DB loaded from disk, once each) -> a new container -> %s" % (b.group(4), a.group(1), nc.group(1)))
    else:
        ok(False, "persist: a line is missing")
    exitline(L, 0, "add10: ")
elif NAME == "default":
    L = lines(sys.argv[2])
    ok(("PROBE started: yes · %s · a web server: yes" % DEFW) in L, "the default run started on H2")
    ok(("PROBE http (%s): GET /actuator/health -> 200 · status UP" % DEFW) in L and ("PROBE http (%s): GET /leaderboard -> 404" % DEFW) in L and ("PROBE http (%s): GET /dashboard -> 200" % DEFW) in L, "default run: health 200, /leaderboard 404, /dashboard 200")
    ok(("PROBE noevents (%s): getBeansOfType(KitchenEvents) 0" % DEFW) in L and sum(1 for l in L if l == "PROBE KitchenEvents beans 0 [] (%s)" % DEFW) == 2, "no KitchenEvents bean on the default run")
    ok(('PROBE add (%s): POST /customers {"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEGAN"} -> 201' % DEFW) in L, "one add on the default run -> 201, with no Redis anywhere (the listener is dev-only)")
    ok("  log: Found 1 JPA repository interface" in L and "  log: Found 1 JDBC repository interface" in L and not any(re.match(r"^  log: Found \d+ Redis", l) for l in L), "JPA 1, JDBC 1, no Redis repository line (unit 15's, unchanged)")
    ok(not any(l.startswith("PROBE Redis's INFO server") for l in L), "no Redis connection made")
    ex = [m.groups() for m in (re.match(r"^  exit 0 · its log, every line but the harness's own PROBE lines: WARN (\d+) \(%s: (\d+)\) · ERROR (\d+) · lines naming an Exception or an Error class (\d+) · RedisConnectionFailureException (\d+)$" % re.escape(NETTY), l) for l in L) if m]
    ow = [l for l in L if l.startswith("  its other WARN line: ")]
    ok(len(ex) == 1 and ex[0][2:] == ("0", "0", "0") and int(ex[0][0]) == int(ex[0][1]) + len(ow) and all("Flyway has been verified with" in w for w in ow), "exit 0, ERROR 0, no exception, no RedisConnectionFailureException; WARN = Netty's DNS line + Flyway's H2-version line: %s" % ex)
    pk = [x for x in (re.match(r"^  Surefire's Results line: Tests run: (\d+), Failures: 0, Errors: 0, Skipped: 0$", l) for l in L) if x]
    ok(len(pk) == 1, "the package run's Results line")
    if pk: VALUES.append("16/after, default run, H2, no Redis, no Docker: health 200 · /leaderboard 404 · /dashboard 200 · KitchenEvents beans 0 · POST /customers 201 with no Redis · no Redis repository line · the %s under mvn -o package, Docker at nothing" % pk[0].group(1))
elif NAME == "seven":
    L = lines(sys.argv[2]); S466 = sys.argv[3]
    h = [m.group(1) for m in (re.search(r"the seven responses: 7 lines · md5 ([0-9a-f]{32})", l) for l in L) if m]
    ok(len(h) == 2 and h[0] == h[1] == S466, "the seven on before/ and after/ = Course 7's published md5")
    ok(sum(1 for l in L if l == "  GET /dashboard: 200") == 2, "GET /dashboard 200 on both")
    ok("  exit 0 · cmp with xcheck.sql (= Course 7's capstone's): the same, byte for byte" in L, "Hibernate's schema script = xcheck.sql")
    ok("  the seven, after/ against before/: lines that differ: 0" in L, "0 lines differ")
    ok(sum(1 for l in L if l.startswith("  GET /actuator/health/readiness -> 200 · GET /actuator/health -> 200 · GET /leaderboard -> 404 ")) == 2, "the jar's default run: health 200, /leaderboard 404, before and after")
    VALUES.append("the seven %s… on before/ and after/ (0 lines differ) · GET /dashboard 200 · health 200 · /leaderboard 404 on the default run · Hibernate's script = xcheck.sql" % S466[:8])
else:
    fail_unknown()
for o in oks: print("ok " + o)
for f in fails: print("FAIL " + f)
print("VALUES " + "; ".join(VALUES))
sys.exit(1 if fails else 0)
