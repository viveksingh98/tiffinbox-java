"""Unit 17's checks (python3 -I -B harness/chk17.py NAME ARGS...). Each capture's numbers are asserted against a second witness of the
same run - never a typed figure (R.398): Java's answers (the harness's setIfAbsent, GET, delete and Lua replies, Redlock's per-instance
list, the counter's counts; each TiffinBox JVM's invocation counter and its list's size) against redis-cli inside the Redis container
(GET, EXISTS, PTTL / TTL masked, --scan, INCR, EXPIRE ... NX, SET ... EX ... NX) and PostgreSQL's own statement log (the customer
SELECTs between two psql markers); the API's statuses; Surefire's XML against Maven's Results lines; the seven's md5 against Course
7's. Prints ok/FAIL lines and one VALUES line; exits 1 on any FAIL.
  static AFTER BEFORE   the change itself, read off the files (C4), and receipts.sh's and the harness's own rules (R.387, R.410-R.412)
  readme AFTER BEFORE   the anchor README's change: its unit 17 section added, one header line grown by its note, nothing else
  r250 AFTER BEFORE     the sentences C4 made incomplete: noted beside them, the unit 13 sentence kept word for word
  wib CAPTURE FILE      the lines the exercise's block printed for FILE (bash's), for receipts.sh to compare with "What it prints"
  exercise|sync|lock|otherholder|lua|rate|race|anchor|default|seven|redlock CAPTURE [...]"""
import filecmp, hashlib, os, re, sys

NAME = sys.argv[1]
fails, oks, VALUES = [], [], []


def ok(c, msg):
    (oks if c else fails).append(msg)


def raw(p):
    return open(p, encoding="utf-8").read().splitlines()


def lines(p):
    """the capture's lines, every indent of two spaces or more read as two (a pause's lines are printed one level deeper)"""
    return [re.sub(r"^ {2,}", "  ", l) for l in raw(p)]


def all_(L, rx):
    return [x for x in (re.search(rx, l) for l in L) if x]


def one(L, rx):
    m = all_(L, rx)
    ok(len(m) == 1, "1 line matches %s (found %d)" % (rx[:100], len(m)))
    return m[0] if m else None


def windows(L, head):
    """the capture split at its "-- " lines that start with head"""
    out, cur = [], None
    for l in L:
        if l.startswith("-- "):
            cur = [] if l.startswith(head) else None
            if cur is not None: out.append(cur)
        if cur is not None: cur.append(l)
    return out


def rd(t, p): return open(os.path.join(t, p), encoding="utf-8").read()


def xfam(p):
    s = open(p, encoding="utf-8").read(); a = s.index("XFAM_S2 = {"); b = s.index("\n}\n", a) + 3
    return hashlib.md5(s[a:b].encode()).hexdigest()


NETTY = "Netty's DNS line on macOS"
CRP = "tiffinbox-core/src/main/java/com/tiffinbox/CustomerRepository.java"
U13S = "profile \"dev\" the waiting is done by the cache writer TiffinBox gives Redis (RedisCaching), in this JVM; a second server\n     * runs its own read."
U17P = "<p>Course 8, unit 17: across two JVMs, one Redis, under \"dev\": one read of the table with the writer TiffinBox gives Redis"
LK = "tiffinbox:lock:kitchen-slot"
EXITRX = r"^  exit (\d+) · its log, every line but the harness's own PROBE lines: WARN (\d+) \(%s: (\d+)\) · ERROR (\d+) · lines naming an Exception or an Error class (\d+) · RedisConnectionFailureException (\d+)$" % re.escape(NETTY)


def clean_exits(L, code, msg, allow_rcfe=False):
    m = all_(L, EXITRX)
    ok(len(m) >= 1 and all(x.group(1) == str(code) for x in m), "%s: every harness JVM exits %d (%d line(s))" % (msg, code, len(m)))
    for x in m:
        ok(x.group(2) == x.group(3) and x.group(4) == "0" and (allow_rcfe or (x.group(5) == "0" and x.group(6) == "0")), "%s: ERROR 0, WARN = Netty's DNS line only, no exception line, no RedisConnectionFailureException: %s" % (msg, x.groups()))
    return m


def side_exits(L, msg):
    m = all_(L, r"^  its exit (\d+) · its log: ERROR (\d+) · lines naming an Exception (\d+)$")
    ok(all(x.groups() == ("0", "0", "0") for x in m), "%s: every second harness JVM exits 0, ERROR 0, no exception: %s" % (msg, [x.groups() for x in m]))
    return m


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
    ok(sorted(changed) == ["README.md", CRP], "C4 changes two files, the Javadoc's and the README's: %s" % sorted(changed))
    a, b = rd(A, CRP), rd(B, CRP)
    ok(U13S in a and U13S in b, "R.250: the unit 13 sentence kept word for word")
    ok(a.count(U17P) == 1 and a.index(U17P) > a.index(U13S), "the unit 17 paragraph once, after the unit 13 sentence")
    ok([l for l in a.splitlines() if not l.strip().startswith(("*", "/**", "*/", "//"))] == [l for l in b.splitlines() if not l.strip().startswith(("*", "/**", "*/", "//"))], "C4 moves no code line of CustomerRepository.java - Javadoc only")
    for f in ("compose.yaml", "tiffinbox-web/pom.xml", "tiffinbox-core/pom.xml", "pom.xml", "tiffinbox-web/src/main/java/com/tiffinbox/web/RedisCaching.java", "tiffinbox-web/src/main/resources/application-dev.yaml", "tiffinbox-web/src/main/resources/application.yaml"):
        ok(rd(A, f) == rd(B, f), "untouched: " + f)
    ok(not any("Lock" in f or "Rate" in f or "Counter" in f for f in changed), "no lock, no counter class in the anchor (⚑8)")
    ok(xfam("harness/s817.py") == xfam("../c8-unit16/harness/s816.py") == xfam("../c8-unit14/harness/s814.py"), "XFAM_S2's block, byte for byte, = s814.py's and s816.py's (md5)")
    R = open("receipts.sh", encoding="utf-8").read().splitlines()
    code = [l for l in R if not l.lstrip().startswith("#")]
    jl = [l for l in code if re.search(r"' java |\bjava \$JL|\bjava -(?:cp|D|jar)\b", l) and not l.strip().startswith('echo "-- ')]
    ok(jl and all('$SIG{INT}=\\"DEFAULT\\"' in l or "$SIG{INT}=\"DEFAULT\"" in l for l in jl), "R.410: every java launch in receipts.sh resets SIGINT by perl (%d lines)" % len(jl))
    ki = [l for l in code if "kill -INT" in l]
    ok(len(ki) == 1 and 'kill -INT "$p"' in ki[0], "R.410: one kill -INT, in phsig, to the pid the JVM printed (%d)" % len(ki))
    sl = [float(x) for l in code for x in re.findall(r"\bsleep ([0-9.]+)", l)]
    ok(sl and max(sl) <= 0.5, "R.412: every sleep in receipts.sh is a poll's read gap (max %s), never a wait of the lock's length" % (max(sl) if sl else None))
    ok(not any(re.search(r"\brm -f(?!v)\b", l) and re.search(r"\bdk\b|docker", l) for l in code), "R.387: no container removed with rm -f alone")
    ok(any(re.search(r'dk rm -fv "\$R2" "\$R3"', l) for l in code), "R.387: Redlock's second and third Redis removed rm -fv")
    v = open("harness/variants.py", encoding="utf-8").read()
    ok('"nolocking": [NOLOCK], "hold": [HOLD, HOLDM], "nolockhold": [NOLOCK, HOLD, HOLDM]' in v, "variants.py: nolocking, hold, nolockhold - labelled copies only")
    h = open("harness/src/probe/u17/H17.java", encoding="utf-8").read()
    ok("if redis.call('GET', KEYS[1]) == ARGV[1] then return redis.call('DEL', KEYS[1]) else return 0 end" in h and "local c = redis.call('INCR', KEYS[1]); if c == 1 then redis.call('EXPIRE', KEYS[1], ARGV[1]) end; return c" in h, "H17: the two Lua scripts as the brief writes them")
    ok(not re.search(r'\+ *(?:LOCK_TTL|RATE_TTL)\b|(?:LOCK_TTL|RATE_TTL) *\+', h), "H17 prints neither time to live (R.402): no string built with it")
    VALUES.append("C4 = %s" % " + ".join(sorted(changed)))
elif NAME == "readme":
    A, B = sys.argv[2], sys.argv[3]
    a, b = rd(A, "README.md").splitlines(), rd(B, "README.md").splitlines()
    nt = " *(Course 8, unit 17, **Section 3's fourth change to this folder**"
    hl = [l for l in a if nt in l]
    ok(len(hl) == 1 and hl[0][:hl[0].index(nt)] + hl[0][hl[0].index(")*", hl[0].index(nt)) + 2:] in b, "the header line is unit 16's with the unit 17 note added, nothing else")
    import difflib
    dl = [l for l in difflib.unified_diff(b, a, lineterm="", n=0) if l[:1] in "+-" and not l.startswith(("+++", "---"))]
    ok(sum(1 for l in dl if l.startswith("-")) == 1 and all(l.startswith("+") for l in dl if not l.startswith("-")), "README.md: one line grown, the rest added")
    VALUES.append("README: the unit 17 section and its header note")
elif NAME == "r250":
    A, B = sys.argv[2], sys.argv[3]
    a = rd(A, CRP)
    ok("thread). Under the\n     * profile \"dev\" the waiting is done" in a and U13S in a, "R.250: findAll's unit 13 sentence kept, word for word")
    ok("that asked for the same key meanwhile wait for its answer, in one JVM (../c8-unit13, sync)" in a, "R.250: the class Javadoc's unit 13 sentence (in one JVM) kept: a statement of what unit 13 measured, still true")
    ok("its last clause - a second server runs its own read - is what the copy without enableLocking() printed" in a, "R.250: the unit 17 paragraph says which clause the capture contradicts")
    R = rd(A, "README.md")
    ok(R.count("## Course 8 · unit 17 — ") == 1, "the anchor README's unit 17 section")
    ok(R.count("*(Course 8, unit 17, **Section 3's fourth change to this folder**") == 1, "the anchor README's header note for unit 17")
    ok("in one JVM — Caffeine's cache or the cache writer TiffinBox gives Redis (`../c8-unit13`, `sync`" in R and "Unit 13's last\n  clause" in R, "R.250: the anchor README's unit 13 \"in one JVM\" sentence kept; the unit 17 section beside it")
    me = open("README.md", encoding="utf-8").read()
    ok("in one JVM" in open("../c8-unit13/README.md", encoding="utf-8").read(), "c8-unit13's README keeps its \"in one JVM\" sentence (frozen; its receipt reads it live)")
    ok("A dated note on `../c8-unit13/README.md`" in me, "this README carries the dated note on unit 13's sentence, not in place")
    VALUES.append("R.250: the unit 13 sentence kept in findAll's Javadoc and the anchor README, the unit 17 paragraph beside it; c8-unit13's README noted here")
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
    ok(Wd == "25", "the spoken line is 25 words (the brief's): %s" % Wd)
    blocks, cur, sh = {}, None, None
    for l in L:
        if l.startswith("in bash") or l.startswith("in zsh"): sh = l.split()[1]
        if "the README's lines" in l: cur = (sh, "readme"); blocks[cur] = []; continue
        if "then the solution's lines" in l: cur = (sh, "sol"); blocks[cur] = []; continue
        if l.startswith("  the shell is now in"): cur = None; continue
        if cur: blocks[cur].append(l.strip())
    r, s = blocks.get(("bash", "readme"), []), blocks.get(("bash", "sol"), [])
    ok(r and s and blocks.get(("zsh", "readme")) == r and blocks.get(("zsh", "sol")) == s, "bash and zsh print the same")
    for b, nm in ((r, "broken"), (s, "solved")):
        for x in ("Maven: exit 0", "javac: exit 0", "docker run: exit 0", "Release: exit 0", "docker rm -fv: exit 0", "holder A: acquired true", "holder B: acquired true",
                  "the program holds A past its lock's time to live (EXISTS read until 0): EXISTS 0", "holder A sees, before its release: B"):
            ok(x in b, "%s: %s" % (nm, x))
    ok("holder A releases by DEL: deleted true" in r and "redis-cli GET tiffinbox:lock:kitchen-slot: []" in r, "R.196: broken - A's DEL deletes B's lock: redis-cli GET empty")
    ok("holder A releases by the Lua compare-and-delete: returned 0" in s and "redis-cli GET tiffinbox:lock:kitchen-slot: [B]" in s, "R.196: solved - the Lua release returns 0: redis-cli GET B")
    ok(sum(1 for l in L if re.search(r"listening on 20562 afterwards: 0 · a container named c8u17-ex: 0$", l)) == 2, "after each shell: 20562 free, the exercise's container gone")
    VALUES.append("the line %s words · broken (DEL): deleted true, redis-cli GET empty · solved (the Lua compare-and-delete): returned 0, redis-cli GET B · the program holds A past its lock's time to live on purpose · exit 0 both (a standalone program on the anchor's libraries, Redis by the digest)" % Wd)
elif NAME == "sync":
    L = lines(sys.argv[2])
    W = windows(L, "-- sync row (")
    ok(len(W) == 4, "four rows (a, b, c, d): %d" % len(W))
    rows = {}
    for w in W:
        h = re.match(r"^-- sync row \(([abcd])\): (.*) · (no hold|the harness holds the caller inside findAll \(planted, labelled\))$", w[0])
        ok(h is not None, "a row's header names its tree and its hold: " + w[0][:90])
        if not h: continue
        r = h.group(1); held = h.group(3) != "no hold"
        ds = all_(w, r"^  the counters' deltas, sorted: (\d+) (\d+) · their sum (\d+)$")
        fa = all_(w, r"^  PROBE JVM <k> \(profile dev, PostgreSQL [0-9.]+\): findAll\(\) returned (\d+) customers · the counter's delta \(calls that reached Spring Data JPA's repository\): (\d+)$")
        pg = all_(w, r"^  PostgreSQL's log between the two psql markers .* · its lines: (\d+)$")
        cold = all_(w, r"^  redis-cli EXISTS 'customers::SimpleKey \[\]' -> 0 ")
        aft = all_(w, r"^  after both answers, redis-cli --scan, sorted: (.*) · TYPE 'customers::SimpleKey \[\]' string$")
        dur = all_(w, r"^  during the hold \(both callers parked, each by its own JVM's line\), redis-cli --scan, sorted: (.*)$")
        cal = all_(w, r"^  PROBE JVM <k>'s caller: (.*) · read <k> times$")
        ok(len(ds) == 1 and len(fa) == 2 and len(pg) == 1 and len(cold) == 1 and len(aft) == 1, "row %s: its lines (deltas, both JVMs' answers, PostgreSQL's count, the cold key, the scan after)" % r)
        if not (ds and len(fa) == 2 and pg and aft): continue
        d1, d2, sm = int(ds[0].group(1)), int(ds[0].group(2)), int(ds[0].group(3))
        ok(sorted([int(fa[0].group(2)), int(fa[1].group(2))]) == [d1, d2] and d1 + d2 == sm, "row %s: the summed deltas = the two JVMs' own lines" % r)
        ok(sm == int(pg[0].group(1)), "row %s: witness 2 - PostgreSQL's customer SELECTs between the markers = the counters' sum (%s, %s)" % (r, sm, pg[0].group(1)))
        ok(fa[0].group(1) == fa[1].group(1) and int(fa[0].group(1)) > 0, "row %s: both JVMs got the same non-empty list (%s)" % (r, fa[0].group(1)))
        ok("customers::SimpleKey []" in aft[0].group(1).split(" tiffinbox")[0] + " " and "customers~lock" not in aft[0].group(1), "row %s: after both answers the list is in Redis and no lock key is left: %s" % (r, aft[0].group(1)))
        exits = all_(w, r"^  \(x2\) +JVM <k>'s log: its log, every line but the harness's own PROBE lines: WARN (\d+) \(%s: (\d+)\) · ERROR (\d+) · lines naming an Exception or an Error class (\d+) · RedisConnectionFailureException (\d+)$" % re.escape(NETTY))
        ok(len(exits) == 1 and exits[0].group(1) == exits[0].group(2) and exits[0].groups()[2:] == ("0", "0", "0"), "row %s: both JVMs' logs - ERROR 0, no exception, RedisConnectionFailureException 0" % r)
        lockseen = None
        if held:
            ok(len(dur) == 1 and len(cal) == 2, "row %s: the hold - both callers' states and the scan during it" % r)
            if dur and len(cal) == 2:
                lockseen = "customers~lock" in dur[0].group(1).split()
                states = sorted(c.group(1) for c in cal)
                if lockseen:
                    ok(states == ["inside the copy's hold in CustomerRepository.findAll (the harness holds - planted)", "waiting inside Spring Data Redis's cache writer, before the method"], "row %s: one caller in the hold, the other waiting in the cache writer (the lock): %s" % (r, states))
                else:
                    ok(states == ["inside the copy's hold in CustomerRepository.findAll (the harness holds - planted)"] * 2, "row %s: both callers in the hold, no lock to wait on: %s" % (r, states))
        else:
            ok(not dur and not cal, "row %s: no hold, no hold lines" % r)
        rows[r] = (sm, lockseen, d1, d2)
    a_, b_, c_, d_ = (rows.get(k, (None,)) for k in "abcd")
    ok(c_[0] == 1 and c_[1] is True, "row c (shipped writer, held): one read, customers~lock seen by redis-cli: %s" % (c_,))
    ok(d_[0] == 2 and d_[1] is False, "row d (no enableLocking(), held): two reads, no lock key: %s" % (d_,))
    ok(a_[0] == 1, "row a (shipped writer, no hold): one read: %s" % (a_,))
    ok(b_[0] in (1, 2), "row b (no enableLocking(), no hold): one or two reads, as printed: %s" % (b_,))
    jd = open(os.path.join("after", CRP), encoding="utf-8").read()
    ok((U17P in jd) == (a_[0] == 1 and c_[0] == 1 and d_[0] == 2 and c_[1] is True and d_[1] is False), "C4: the Javadoc paragraph is in after/ exactly when sync printed 1 / 2 (rows a, c, d) - ⚑10")
    sc = all_(L, r"^  after both starts against one Redis .*: ZCARD tiffinbox:leaderboard (\d+) · SCARD kitchen-order (\d+) · XLEN tiffinbox:kitchen-events (\d+) · ")
    oc = all_(L, r"^  JVM [12]   log: tiffinbox: orders cooked: +(\d+)$")
    ok(len(sc) == 1 and len(oc) == 8 and len(set(x.group(1) for x in oc)) == 1, "both starts filled, every row (orders cooked twice per row, the same count): %d" % len(oc))
    if sc and oc: ok(int(sc[0].group(2)) == int(oc[0].group(1)), "the kitchen orders after two starts against one Redis = one start's count (the same deterministic ids): SCARD %s, orders cooked %s" % (sc[0].group(2), oc[0].group(1)))
    VALUES.append("RE-MEASURE 9, two TiffinBox JVMs, one Redis, one PostgreSQL, findAll() through each context's bean, released by one Redis key: (a) after/'s shipped writer, no hold - %s read · (b) a copy without enableLocking(), labelled, no hold - %s · (c) the shipped writer, the harness holds (planted) - %s, customers~lock seen by redis-cli · (d) the copy without enableLocking(), the harness holds - %s, no lock key · each sum = PostgreSQL's customer SELECTs between the markers" % (a_[0], b_[0], c_[0], d_[0]))
    if sc and oc: VALUES.append("two starts against one Redis: ZCARD tiffinbox:leaderboard %s, SCARD kitchen-order %s (= one start's orders cooked %s)" % (sc[0].group(1), sc[0].group(2), oc[0].group(1)))
elif NAME == "lock":
    L = lines(sys.argv[2])
    W = windows(L, "-- holder A releases by ")
    ok(len(W) == 2, "two windows (DEL, the Lua release): %d" % len(W))
    got = {}
    for w in W:
        rel = "del" if "by DEL," in w[0] else "lua"
        a = all_(w, r"^PROBE holder A \(the harness's lock\): setIfAbsent\(%s, A, <the lock's time to live>\) -> acquired (\w+)$" % LK)
        g1 = all_(w, r"^  the receipt at pause 1, redis-cli: GET %s -> (\S*) · PTTL %s -> (.*)$" % (LK, LK))
        rr = all_(w, r"^PROBE holder A releases by DEL \(the harness's lock\): deleted (\w+)$") if rel == "del" else all_(w, r"^PROBE holder A releases by the Lua compare-and-delete \(the harness's lock\): returned (\d+)$")
        g2 = all_(w, r"^  the receipt at pause 2, redis-cli: GET %s -> \[(.*)\] · EXISTS %s -> (\d+)$" % (LK, LK))
        b = all_(w, r"^  PROBE holder B \(the harness's lock\): setIfAbsent\(%s, B, <the lock's time to live>\) -> acquired (\w+)$" % LK)
        g3 = all_(w, r"^  redis-cli GET %s -> (\S+)$" % LK)
        ok(len(a) == 1 and a[0].group(1) == "true" and g1 and g1[0].group(1) == "A" and g1[0].group(2) == "<n> (positive)", "%s: A acquires (true), redis-cli GET A, PTTL positive (masked)" % rel)
        want = "true" if rel == "del" else "1"
        ok(len(rr) == 1 and rr[0].group(1) == want and g2 and g2[0].groups() == ("", "0"), "%s: A releases inside its lock -> %s; redis-cli GET empty, EXISTS 0" % (rel, want))
        ok(len(b) == 1 and b[0].group(1) == "true" and g3 and g3[0].group(1) == "B", "%s: then B (a second harness JVM) acquires -> true; redis-cli GET B" % rel)
        got[rel] = (a[0].group(1) if a else None, rr[0].group(1) if rr else None, b[0].group(1) if b else None)
    ok(not any(l.startswith("PROBE the harness holds") for l in L), "no hold in the control")
    clean_exits(L, 0, "lock"); side_exits(L, "lock")
    VALUES.append("the harness's lock, no hold (RE-MEASURE 14): A acquired %s, redis-cli GET A, PTTL positive; A releases inside its lock - DEL deleted %s / the Lua release returned %s; redis-cli GET empty; then B acquired %s, GET B" % (got.get("del", ("?",))[0], got.get("del", (0, "?"))[1], got.get("lua", (0, "?"))[1], got.get("del", (0, 0, "?"))[2]))
elif NAME in ("otherholder", "lua"):
    L = lines(sys.argv[2]); lua = NAME == "lua"
    a = one(L, r"^PROBE holder A \(the harness's lock\): setIfAbsent\(%s, A, <the lock's time to live>\) -> acquired (\w+)$" % LK)
    g1 = one(L, r"^  the receipt at pause 1, redis-cli: GET %s -> (\S+) · PTTL %s -> (.*)$" % (LK, LK))
    hd = one(L, r"^PROBE the harness holds this holder past its lock's time to live \(planted, labelled\)$")
    pe = one(L, r"^  poll: EXISTS %s \(until A's key is gone, A still running\) -> 0, polled <k> times" % LK)
    b = one(L, r"^  PROBE holder B \(the harness's lock\): setIfAbsent\(%s, B, <the lock's time to live>\) -> acquired (\w+)$" % LK)
    gb = all_(L, r"^  redis-cli GET %s -> (\S+)$" % LK)
    se = one(L, r"^PROBE holder A sees the lock's value before release: (\S+)$")
    ov = one(L, r"^PROBE holder A and holder B held at once: A's work ran past its lock while B held it \(the planted hold\)$")
    rr = one(L, r"^PROBE holder A releases by the Lua compare-and-delete \(the harness's lock\): returned (\d+)$") if lua else one(L, r"^PROBE holder A releases by DEL \(the harness's lock\): deleted (\w+)$")
    g3 = one(L, r"^  the receipt at pause 3, after A's release, redis-cli: GET %s -> \[(.*)\] · EXISTS %s -> (\d+)$" % (LK, LK))
    c = one(L, r"^  PROBE holder C \(the harness's lock\): setIfAbsent\(%s, C, <the lock's time to live>\) -> acquired (\w+)$" % LK)
    if a and g1 and b and se and rr and g3 and c and len(gb) == 2:
        ok(a.group(1) == "true" and g1.group(1) == "A" and g1.group(2) == "<n> (positive)", "A acquires; redis-cli GET A, PTTL positive (masked)")
        ok(b.group(1) == "true" and gb[0].group(1) == "B", "while the harness holds A, its key gone (EXISTS 0 by the poll), B acquires; redis-cli GET B")
        ok(se.group(1) == "B" and ov is not None, "A sees B before its release - A and B held at once (both witnesses: Java's GET, redis-cli's GET B)")
        if lua:
            ok(rr.group(1) == "0" and g3.groups() == ("B", "1") and c.group(1) == "false" and gb[1].group(1) == "B", "the Lua release returned 0; redis-cli GET B, EXISTS 1; C refused (false), GET B")
            VALUES.append("the harness holds A past its lock's time to live (planted): B acquired %s, A sees %s (held at once); the Lua compare-and-delete returned %s; redis-cli GET %s; C acquired %s" % (b.group(1), se.group(1), rr.group(1), g3.group(1), c.group(1)))
        else:
            ok(rr.group(1) == "true" and g3.groups() == ("", "0") and c.group(1) == "true" and gb[1].group(1) == "C", "A's DEL deleted true; redis-cli GET empty, EXISTS 0 - A deleted B's lock; C acquires (true), GET C")
            VALUES.append("the harness holds A past its lock's time to live (planted): B acquired %s, A sees %s (held at once); A's DEL deleted %s; redis-cli GET empty - A deleted B's lock; C acquired %s" % (b.group(1), se.group(1), rr.group(1), c.group(1)))
    clean_exits(L, 0, NAME); side_exits(L, NAME)
elif NAME == "rate":
    L = lines(sys.argv[2])
    rq = all_(L, r"^PROBE request (\d) \(the harness's counter, the Lua INCR \+ EXPIRE on the first\): count (\d+) -> (allowed|refused) \(limit 5\)$")
    ok([(int(x.group(1)), int(x.group(2)), x.group(3)) for x in rq] == [(i, i, "allowed" if i <= 5 else "refused") for i in range(1, 7)], "six requests: counts 1-5 allowed, the 6th refused")
    g = one(L, r"^  redis-cli GET tiffinbox:rate:kitchen-slot -> (\d+) · TTL tiffinbox:rate:kitchen-slot -> (.*)$")
    if g and rq: ok(int(g.group(1)) == len(rq) == int(rq[-1].group(2)) and g.group(2) == "<n> (positive)", "witness 2: redis-cli GET = the last count, TTL positive (masked)")
    v = one(L, r"^-- two one-command forms on this Redis, by redis-cli \(INFO server: redis_version:([0-9.]+)\):$")
    s0 = one(L, r"^  SET tiffinbox:rate:nx 1 -> OK · TTL -> (-1)$")
    e = one(L, r"^  EXPIRE tiffinbox:rate:nx <n> NX -> (\d) · again -> (\d) · TTL -> (.*)$")
    x = one(L, r"^  SET tiffinbox:rate:ex 1 EX <n> NX -> (OK) · INCR tiffinbox:rate:ex -> (\d+) · TTL -> (.*)$")
    if e and x and v:
        ok(e.groups() == ("1", "0", "<n> (positive)"), "EXPIRE ... NX: 1, then 0 (a time to live already there), TTL positive")
        ok(x.groups() == ("OK", "2", "<n> (positive)"), "SET ... EX ... NX: OK; INCR 2 keeps the time to live (TTL positive)")
        VALUES.append("the harness's counter: requests 1-5 allowed, the 6th refused; redis-cli GET %s, TTL positive · on %s: EXPIRE … NX %s then %s; SET … EX … NX %s, INCR %s, TTL positive" % (g.group(1) if g else "?", v.group(1), e.group(1), e.group(2), x.group(1), x.group(2)))
    clean_exits(L, 0, "rate")
elif NAME == "race":
    L = lines(sys.argv[2])
    i = one(L, r"^PROBE the harness's counter, INCR tiffinbox:rate:race -> (\d+)$")
    hd = one(L, r"^PROBE the harness holds before its EXPIRE \(planted, labelled\): pid <n>$")
    sg = one(L, r"^  the receipt at pause 1: kill -INT sent to the harness JVM \(its pid, read off its own line\)$")
    g = one(L, r"^  redis-cli GET tiffinbox:rate:race -> (\d+) · TTL tiffinbox:rate:race -> (\S+) · EXISTS tiffinbox:rate:race -> (\d)$")
    ok(not any("race: no SIGINT came" in l for l in L), "the SIGINT came before the EXPIRE")
    m = clean_exits(L, 130, "race")
    ok("  java processes of this script after it: 0" in L, "no JVM left")
    if i and g:
        ok(i.group(1) == g.group(1) == "1" and g.group(2) == "-1" and g.group(3) == "1", "INCR 1 by Java; redis-cli GET 1, TTL -1, EXISTS 1 - a counter that never ends")
        VALUES.append("INCR %s, the harness holds before EXPIRE (planted), SIGINT -> exit 130; redis-cli GET %s, TTL %s" % (i.group(1), g.group(1), g.group(2)))
elif NAME == "anchor":
    L = lines(sys.argv[2])
    pk = [x for x in (re.match(r"^  Surefire's Results line: Tests run: (\d+), Failures: 0, Errors: 0, Skipped: 0$", l) for l in L) if x]
    ok(len(pk) == 3, "three Results lines (package; verify's two executions): %d" % len(pk))
    n18 = int(pk[0].group(1)) if pk else 0; n18b = int(pk[1].group(1)) if len(pk) > 1 else 0; nit = int(pk[2].group(1)) if len(pk) > 2 else 0
    ok(n18 == n18b, "the package run's count = verify's first execution's: %d %d" % (n18, n18b))
    ok(any("absent - no container test ran" in l for l in L), "mvn package: no container test ran (Docker at nothing)")
    rep = [x for x in (re.match(r"^  in all: 3 reports · tests (\d+) · failures 0 · errors 0 · skipped 0$", l) for l in L) if x]
    ok(len(rep) == 3 and [int(x.group(1)) for x in rep] == [n18, n18b, nit], "Surefire's XML (surefire.py) = Maven's Results lines, all three: %s" % [x.group(1) for x in rep])
    ok(any("Testcontainers containers after it: 0" in l for l in L), "Testcontainers' containers gone after verify")
    lb = all_(L, r"^  (before|after)/: (\d+) libraries · ")
    ok(len(lb) == 2 and lb[0].group(2) == lb[1].group(2), "the libraries, before/ = after/: %s" % [x.group(2) for x in lb])
    ok("  gained: 0 · lost: 0" in L, "no library gained or lost")
    ok(sum(1 for l in L if re.match(r"^  after/(compose\.yaml|tiffinbox-web/pom\.xml|tiffinbox-web/src/main/resources/application-dev\.yaml|tiffinbox-web/src/main/java/com/tiffinbox/web/RedisCaching\.java): md5 [0-9a-f]{32} = before/'s: yes$", l)) == 4, "compose.yaml, the web pom, application-dev.yaml and RedisCaching untouched")
    jd = [l[4:] for l in L if l.startswith("  > ")]
    ok(any(U17P.replace("<p>", "") in l or "Course 8, unit 17: across two JVMs" in l for l in jd), "the Javadoc paragraph, read off after/ by diff")
    for rx, msg in ((r"^  log: Multiple Spring Data modules found, entering strict repository configuration mode$", "strict mode"),
                    (r"^  log: Found 1 JPA repository interface\.?$", "Found 1 JPA"), (r"^  log: Found 1 JDBC repository interface\.?$", "Found 1 JDBC"), (r"^  log: Found 1 Redis repository interface\.?$", "Found 1 Redis"),
                    (r"^  log: HHH000001: Hibernate ORM core version 7\.4\.13\.Final$", "HHH000001 7.4.13.Final"),
                    (r"^PROBE versions: Spring Boot 4\.1\.2 · Spring Framework 7\.0\.10 · Spring Data JPA 4\.1\.2 · Spring Data JDBC 4\.1\.2 · Spring Data Redis 4\.1\.2 · Lettuce 7\.5\.2\.RELEASE(?:/\w+)? · Hibernate 7\.4\.13\.Final · Flyway \(version\.txt\) 12\.4\.0$", "the version line"),
                    (r"^PROBE Redis's INFO server, through the connection: redis_version:8\.10\.3$", "redis_version 8.10.3 by Java"),
                    (r"^  the Redis container's own client: redis-cli 8\.10\.3 · INFO server: redis_version:8\.10\.3$", "redis_version 8.10.3 by redis-cli"),
                    (r"^PROBE bean kitchenEvents: present ", "KitchenEvents present"), (r"^PROBE bean leaderboard: present ", "Leaderboard present"), (r"^PROBE bean redisDatastore: present ", "RedisDatastore present"),
                    (r"^PROBE http \(profile dev, PostgreSQL 18\.6\): GET /actuator/health -> 200 · status UP$", "health 200"), (r"^PROBE http \(profile dev, PostgreSQL 18\.6\): GET /leaderboard -> 200$", "/leaderboard 200"),
                    (r"^PROBE http \(profile dev, PostgreSQL 18\.6\): GET /dashboard -> 200$", "/dashboard 200")):
        ok(any(re.search(rx, l) for l in L), "anchor: " + msg)
    oc = one(L, r"^  log: tiffinbox: orders cooked: +(\d+)$"); kv = one(L, r"^  log: tiffinbox: kitchen value: +(\d+)$")
    sc = one(L, r"^  SCARD kitchen-order (\d+) · ZCARD tiffinbox:leaderboard (\d+) · XLEN tiffinbox:kitchen-events (\d+) ")
    if oc and sc: ok(oc.group(1) == sc.group(1) and sc.group(3) == "0", "witness 2: SCARD kitchen-order = the start's orders cooked; XLEN 0 on a fresh Redis (no add)")
    ok("  --scan, keys with lock or rate in their name: 0" in L, "TiffinBox writes no lock and no counter key (⚑8)")
    clean_exits(L, 130, "anchor")
    if pk and oc and kv and lb:
        VALUES.append("17/after, profile dev, PostgreSQL + Redis: Found 1 JPA / 1 JDBC / 1 Redis repository interface · orders cooked %s · kitchen value %s · SCARD kitchen-order %s · health 200 · /leaderboard 200 · /dashboard 200 · Boot 4.1.2, Framework 7.0.10, Spring Data JPA/JDBC/Redis 4.1.2, Lettuce 7.5.2.RELEASE, HHH000001 7.4.13.Final, Flyway 12.4.0, redis_version 8.10.3 · SIGINT -> exit 130 · libraries %s, none gained · tests %d + %d (no move at 17: no anchor test of harness code)" % (oc.group(1), kv.group(1), sc.group(1) if sc else "?", lb[1].group(2), n18, nit))
elif NAME == "default":
    L = lines(sys.argv[2]); DEFW = "default run, H2 2.5.250"
    ok(("PROBE started: yes · %s · the cache's store: in the JVM, CaffeineCacheManager · a web server: yes" % DEFW) in L, "the default run started on H2, the cache in the JVM")
    ok(("PROBE http (%s): GET /actuator/health -> 200 · status UP" % DEFW) in L and ("PROBE http (%s): GET /leaderboard -> 404" % DEFW) in L and ("PROBE http (%s): GET /dashboard -> 200" % DEFW) in L, "default run: health 200, /leaderboard 404, /dashboard 200")
    ok(not any(l.startswith("PROBE Redis's INFO server") for l in L), "no Redis connection made")
    ex = [m.groups() for m in (re.match(r"^  exit 0 · its log, every line but the harness's own PROBE lines: WARN (\d+) \(%s: (\d+)\) · ERROR (\d+) · lines naming an Exception or an Error class (\d+) · RedisConnectionFailureException (\d+)$" % re.escape(NETTY), l) for l in L) if m]
    ow = [l for l in L if l.startswith("  its other WARN line: ")]
    ok(len(ex) == 1 and ex[0][2:] == ("0", "0", "0") and int(ex[0][0]) == int(ex[0][1]) + len(ow) and all("Flyway has been verified with" in w for w in ow), "exit 0, ERROR 0, no exception, no RedisConnectionFailureException; WARN = Netty's DNS line + Flyway's H2-version line: %s" % ex)
    pk = [x for x in (re.match(r"^  Surefire's Results line: Tests run: (\d+), Failures: 0, Errors: 0, Skipped: 0$", l) for l in L) if x]
    ok(len(pk) == 1, "the package run's Results line")
    if pk: VALUES.append("17/after, default run, H2, no Redis, no Docker: health 200 · /leaderboard 404 · /dashboard 200 · the %s under mvn -o package, Docker at nothing" % pk[0].group(1))
elif NAME == "seven":
    L = lines(sys.argv[2]); S466 = sys.argv[3]
    h = [m.group(1) for m in (re.search(r"the seven responses: 7 lines · md5 ([0-9a-f]{32})", l) for l in L) if m]
    ok(len(h) == 2 and h[0] == h[1] == S466, "the seven on before/ and after/ = Course 7's published md5")
    ok(sum(1 for l in L if l == "  GET /dashboard: 200") == 2, "GET /dashboard 200 on both")
    ok("  exit 0 · cmp with xcheck.sql (= Course 7's capstone's): the same, byte for byte" in L, "Hibernate's schema script = xcheck.sql")
    ok("  the seven, after/ against before/: lines that differ: 0" in L, "0 lines differ")
    ok(sum(1 for l in L if l.startswith("  GET /actuator/health/readiness -> 200 · GET /actuator/health -> 200 · GET /leaderboard -> 404 ")) == 2, "the jar's default run: health 200, /leaderboard 404, before and after")
    VALUES.append("the seven %s… on before/ and after/ (0 lines differ) · GET /dashboard 200 · health 200 · /leaderboard 404 on the default run · Hibernate's script = xcheck.sql" % S466[:8])
elif NAME == "redlock":
    L = lines(sys.argv[2])
    W = [w for w in windows(L, "-- ") if w[0] in ("-- all three up:", "-- dk stop c8u17-redis3 (20564):", "-- dk stop c8u17-redis2 (20563) too:")]
    ok(len(W) == 3, "three states: %d" % len(W))
    res = []
    for w, want in zip(W, ((3, "HELD", ["true", "true", "true"]), (2, "HELD", ["true", "true", "RedisConnectionFailureException"]), (1, "NOT HELD", ["true", "RedisConnectionFailureException", "RedisConnectionFailureException"]))):
        li = one(w, r"^PROBE redlock \(the harness's majority acquire, holder A\): 20562 -> (\w+) · 20563 -> (\w+) · 20564 -> (\w+)$")
        nn = one(w, r"^PROBE redlock: (\d) of 3 -> (HELD|NOT HELD) \(majority 2\)$")
        gg = one(w, r"^  redis-cli GET %s on each: 20562 (.*) · 20563 (.*) · 20564 (.*)$" % LK)
        if not (li and nn and gg): continue
        ok(list(li.groups()) == want[2] and int(nn.group(1)) == want[0] == sum(1 for x in li.groups() if x == "true") and nn.group(2) == want[1], "%s: the per-instance list %s -> %s of 3 %s" % (w[0], li.groups(), nn.group(1), nn.group(2)))
        cli = [gg.group(1), gg.group(2), gg.group(3)]
        for got, port, j in zip(li.groups(), ("20562", "20563", "20564"), cli):
            if got == "true" and want[1] == "HELD": ok(j == "[A]", "witness 2: %s holds A by redis-cli (%s)" % (port, j))
            if got == "RedisConnectionFailureException": ok(j.startswith("stopped"), "witness 2: %s stopped - no redis-cli answer (%s)" % (port, j))
        if want[1] == "NOT HELD":
            mr = one(w, r"^PROBE redlock: the minority release on 20562 \(the Lua compare-and-delete\) -> returned (\d)$")
            ok(mr is not None and mr.group(1) == "1" and cli[0] == "[]", "RE-MEASURE 10: after NOT HELD the harness released the key it got on 20562 (returned 1); redis-cli GET on 20562 empty")
        res.append(nn.group(1) + " of 3 " + nn.group(2))
    clean_exits(L, 0, "redlock", allow_rcfe=True)
    ok(any(re.search(r"removed with their volumes \(rm -fv\) · listening on 20563: 0 · on 20564: 0$", l) for l in L), "the two extra containers removed rm -fv, 20563 and 20564 free")
    VALUES.append("the harness's Redlock sketch, three Redis of the one digest: %s · stopped instances answer RedisConnectionFailureException (named) · the minority release: 20562's key gone (redis-cli GET empty) · no drift term, no retry" % " / ".join(res))
else:
    fail_unknown()
for o in oks: print("ok " + o)
for f in fails: print("FAIL " + f)
print("VALUES " + "; ".join(VALUES))
sys.exit(1 if fails else 0)
