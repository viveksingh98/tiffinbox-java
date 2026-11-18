"""Unit 09's prose gate, per sentence (python3 -I -B harness/s809.py harness/dur8.py FILE...), with a self-test that must pass first.
Carried from unit 08's s808.py (dur8's words, R.388's duration family, the speed and cost words, "the cache works", the abstraction
credited to Spring Data or Hibernate, a hit without its store, a cached page, "Hibernate generates", a raw port, a typed md5, a typed
SQL string, a call-back without its title, typed counts), with unit 09's refused readings (the brief's plant list and the prompt):
R.377 - "Spring warns" / "warns you" / "a warning" in a sentence that is not about the final method (the one WARN captured is the
public final method's, at start), and "always warns" anywhere; flag 4 - "a final method fails" / "is not cached and fails" (it runs,
on the proxy, with one WARN); R.384 - "Caffeine wins" / "the first provider wins" (with both on the class path Redis's manager is
the one printed), and a sentence naming a manager class without its class path or setting; RED #18 - "the proxy's third time" /
"third appearance" (the self-invocation trap, a third time); R.392 - a harness cache (h09:...) called the anchor's; R.302 - a
measured count typed in prose ("3 vs 1", "one WARN", "three invocations"). Lines inside a fenced block and the values block are the
runs' own text (receipts.sh checks them) and are not judged here; a `code span` is masked for every rule but the port, hash, SQL,
manager and harness-cache rules."""
import importlib.util, re, sys
spec = importlib.util.spec_from_file_location("dur8", sys.argv[1]); m = importlib.util.module_from_spec(spec); spec.loader.exec_module(m)
FAM = re.compile(r"\b(?:forever|at once|immediately|instantly|instant|right away|in no time|a moment|momentarily|eventually|after a while|"
                 r"briefly|short(?:ly|er)?|(?:one|two|three|four|five|ten|\d+)\s+(?:second|minute|hour)s?|half a second)\b", re.I)
SPEED = re.compile(r"\b(?:slow(?:er|est|ly)?|quick(?:er|ly)?|fast(?:er|est)?)\b", re.I)
COST = re.compile(r"\b(?:lighter|heavier|cheaper|costlier|expensive|overhead|efficient|inefficient|bloat\w*)\b", re.I)
WORKS = re.compile(r"\b(?:the cache works|caching works|it just caches|just caches|it caches it)\b", re.I)
OWNER = re.compile(r"\bSpring Data(?:'s)? (?:cache|caches|caching)\b|\bHibernate's (?:cache|caching)\b|\bJPA's cache\b", re.I)
OWNNEG = re.compile(r"\bnot (?:a |the )?(?:Spring Data|Hibernate's)\b|\bnever (?:Spring Data|Hibernate's)\b|second-level cache", re.I)
HITW = re.compile(r"\b(?:cache hits?|a hit|the hits?|cached read|from the cache|served from)\b", re.I)
STORE = re.compile(r"ConcurrentMap|ConcurrentHashMap|Caffeine|Redis|NoOp|in the JVM|H2|PostgreSQL|the harness's|harness bean|SimpleKey|h09:", re.I)
WARNS = re.compile(r"\bSpring warns\b|\bwarns you\b|\ba warning\b|\bwarns\b", re.I)
ALWAYS = re.compile(r"\balways warns\b|\bwarns (?:about )?every\b", re.I)
FINFAIL = re.compile(r"\bfinal method (?:fails|throws|breaks|stops)\b|\bis not cached and fails\b|\bfinal method is refused\b", re.I)
WINS = re.compile(r"\bCaffeine wins\b|\bthe first provider wins\b|\bCaffeine is picked\b|\bCaffeine takes over\b", re.I)
THIRD = re.compile(r"\bthe proxy's third time\b|\bthird appearance\b|\bthe proxy, a third time\b", re.I)
MGR = re.compile(r"\b(?:ConcurrentMapCacheManager|CaffeineCacheManager|RedisCacheManager|NoOpCacheManager)\b")
MGRCTX = re.compile(r"class path|starter|copy|copies|spring\.cache\.type|setting|anchor|on the path|both", re.I)
H09ANCHOR = re.compile(r"h09:\S*.*\bthe anchor's (?:cache|own cache)\b|\bthe anchor's (?:cache|own cache)\b.*h09:", re.I)
H09NEG = re.compile(r"\bnot the anchor's\b", re.I)
PAGE = re.compile(r"\b(?:the dashboard|the page|GET /dashboard) is cached\b|\bcaches the (?:dashboard|page)\b", re.I)
GEN = re.compile(r"\bHibernate generates\b", re.I)
PORT = re.compile(r"localhost:\d{2,5}\b|127\.0\.0\.1:(?:[3-6]\d{4})\b")
TYPED = re.compile(r"(?<![\w.#:=/\[-])\d+\s+(?:tests?|customers?|rows?|calls?|statements?|invocations?|reads?|containers?|beans?|jars?|libraries|entries|keys?|words|WARN|warnings?|lines?)\b"
                   r"|\b\d+\s+vs\.?\s+\d+\b"
                   r"|\b(?:one|two|three|four|five|six|seven)\s+(?:WARN|warnings?|invocations?|statements?|entries|repository calls|manager classes|key shapes)\b", re.I)
HASH = re.compile(r"\b[0-9a-f]{32}\b|eedf32a3|466c20ed|7580ed21|7651ab12", re.I)
SQL = re.compile(r"SELECT customer\.|FROM customer\b|FROM \"customer\"|\"customer\"\.\"|select count\(", re.I)
TITLES = ["JDK Proxies vs CGLIB, and the Self-Invocation Trap", "@Transactional: What the Proxy Does", "Auto-Configuration, Mechanism First",
          "N+1, Measured", "@Cacheable, @CacheEvict, @CachePut", "Caffeine", "The Cache Abstraction's Machinery", "Redis as a Cache"]
CALLED = re.compile(r"\b(?:the )?lessons? called\b|\bCourse (?:2|4|5|6|7)\b(?!'s (?:final anchor|capstone|builders|scripts|harness|units|recipe|form|precedent|probe|IT|pinned|statistics|script))|\bas Course 7\b", re.I)
CALLOK = re.compile(r"Course 7's (?:harness|units|recipe|form|precedent|builders|scripts|capstone|final|probe|IT|pinned|statistics)|c7-unit\d+|`c7-unit|`java[457]_series\.py`|spring-core/", re.I)


def verdicts(s, raw=None):
    out = []
    raw = s if raw is None else raw
    for w in m.DUR.finditer(s): out.append("dur8: " + w.group(0))
    for w in FAM.finditer(s): out.append("R.388's family: " + w.group(0))
    for w in SPEED.finditer(s):
        if not m.DUR.search(w.group(0)): out.append("a speed word: " + w.group(0))
    for w in COST.finditer(s): out.append("R.355: a cost word: " + w.group(0))
    if WORKS.search(s): out.append("R.375: \"the cache works\" - a hit is two witnesses from one run, never a slogan")
    if OWNER.search(s) and not OWNNEG.search(s): out.append("R.348: the abstraction credited to Spring Data or Hibernate: " + OWNER.search(s).group(0))
    if HITW.search(s) and not STORE.search(raw): out.append("R.376: a hit or a cached read without its store, its manager or the database that answered")
    if ALWAYS.search(s): out.append("R.377 / flag 4: \"always warns\" - one WARN line is captured, the public final method's, at start")
    elif WARNS.search(s) and not re.search(r"\bfinal\b", s, re.I): out.append("R.377: Spring warns - the only WARN line captured is the public final method's")
    if FINFAIL.search(s): out.append("flag 4: \"a final method fails\" - it runs, on the proxy, with one WARN at start")
    if WINS.search(s): out.append("R.384: \"Caffeine wins\" - with both on the class path the manager printed is Redis's")
    if THIRD.search(s): out.append("RED #18: the proxy's third time - say \"the self-invocation trap, a third time\"")
    if MGR.search(raw) and not MGRCTX.search(raw): out.append("R.384: a manager named without its class path or spring.cache.type: " + MGR.search(raw).group(0))
    if H09ANCHOR.search(raw) and not H09NEG.search(raw): out.append("R.392: a harness cache (h09:...) voiced as the anchor's")
    if PAGE.search(s): out.append("R.389: a cached read set beside the page")
    if GEN.search(s): out.append("§10: \"Hibernate generates\"")
    if PORT.search(raw): out.append("R.319: a port printed raw: " + PORT.search(raw).group(0))
    if TYPED.search(s): out.append("R.302: a capture's number typed in prose: " + TYPED.search(s).group(0))
    if HASH.search(raw): out.append("R.302: a typed md5")
    if SQL.search(raw): out.append("R.225/R.365: a typed SQL string in the prose")
    if CALLED.search(raw) and not any(t in raw for t in TITLES) and not CALLOK.search(raw): out.append("R.224: a call-back without its title")
    return out


CASES = [("A cache hit is faster.", 1), ("It expires after a while.", 1), ("The cache works.", 1), ("Spring Data caches the list.", 1),
         ("Spring warns you about the self-call.", 1), ("Spring warns about it.", 1), ("Spring always warns.", 1),
         ("Spring warns once, at start, about the public final method.", 0),
         ("The final method fails.", 1), ("A final method is not cached and fails.", 1), ("The final method runs on the proxy.", 0),
         ("Caffeine wins when both are on the class path.", 1), ("The first provider wins.", 1),
         ("This is the proxy's third time.", 1), ("Its third appearance.", 1), ("The self-invocation trap, a third time.", 0),
         ("The manager is `RedisCacheManager`.", 1), ("With both on the class path, the manager is `RedisCacheManager`.", 0),
         ("The `h09:keys` cache is the anchor's cache.", 1), ("The `h09:keys` cache is a harness bean's, not the anchor's cache.", 0),
         ("allViaSelf costs 3 statements.", 1), ("It is 3 vs 1.", 1), ("Exactly one WARN line.", 1), ("Three invocations.", 1),
         ("The bean is called three times.", 0), ("A cache hit costs no statement.", 1), ("A cache hit in the JVM, a ConcurrentMap, costs nothing.", 0),
         ("Hibernate generates the SELECT.", 1), ("The URL was `jdbc:postgresql://localhost:32771/test`.", 1), ("Ports 20480-20489.", 0),
         ("The pin is eedf32a336609f92de214f7beba6d2ec.", 1), ("As Course 4 showed.", 1),
         ("As Course 4's *JDK Proxies vs CGLIB, and the Self-Invocation Trap* showed.", 0), ("Spring Boot 4.1.2.", 0),
         ("The numbers are in the values block.", 0), ("It took two seconds.", 1), ("`@Cacheable` on `findAll`.", 0)]
for t, want in CASES:
    got = verdicts(re.sub(r"`[^`]*`", "`…`", t), t)
    assert bool(got) == bool(want), (t, got)
n = 0
def judge(p, start, para):
    global n
    text = " ".join(x.strip() for x in para)
    for s in re.split(r"(?<=[.;!?])\s+", text):
        s2 = re.sub(r"`[^`]*`", "`…`", s)
        for v in verdicts(s2, s):
            n += 1; print("  %s line %d: %s" % (p, start, v))
for p in sys.argv[2:]:
    fence = False; vals = False; para = []; start = 0
    for i, l in enumerate(open(p, encoding="utf-8"), 1):
        mk = l.strip() in ("<!-- values: begin -->", "<!-- values: end -->")
        brk = l.startswith("```") or mk or not l.strip() or l.startswith(("#", "- ", "| "))
        if brk or fence or vals:
            if para: judge(p, start, para); para = []
        if l.startswith("```"): fence = not fence; continue
        if l.strip() == "<!-- values: begin -->": vals = True; continue
        if l.strip() == "<!-- values: end -->": vals = False; continue
        if fence or vals or not l.strip(): continue
        if not para: start = i
        para.append(l)
    if para: judge(p, start, para)
print("self-test: %d cases · refused: %d" % (len(CASES), n))
