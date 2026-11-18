"""Unit 10's prose gate, per sentence (python3 -I -B harness/s810.py harness/dur8.py FILE...), with a self-test that must pass first.
Carried from unit 09's s809.py (dur8's words, R.388's duration family, the speed and cost words, "the cache works", the abstraction
credited to Spring Data or Hibernate, a hit without its store, "Spring warns", a cached page, "Hibernate generates", a raw port, a
typed md5, a typed SQL string, a call-back without its title, typed counts), with unit 10's refused readings (the brief's plant list
and the prompt): R.385 - "LRU" / "least recently used" / "the same eviction" / "the same customer leaves" / "drops the same" for
Caffeine, and Caffeine's policy named ("TinyLFU", "Window TinyLFU", "frequency") - the receipt prints no policy; R.384 - a meter
sentence (prometheus's cache_ lines, a meter, cache_gets_total) that does not name spring.cache.cache-names or the names made at the
start; R.392 - a count from the customer cache (the probe's, singular: the anchor ships only customers), and the ceiling's harness
numbers or the nonames copy's set beside "TiffinBox's" without their label; R.375 - cache_puts_total voiced (allowed only beside
"not voiced" / "never voiced"); R.377 - "Spring warns" (no WARN line is captured for the cache in this unit); R.387 - rm -f without
-v; R.391 - -pl tiffinbox-web without -am; R.302 - a measured count typed in prose (hit 4, miss 1, 50 of 50, a per-call list).
Lines inside a fenced block and the values block are the runs' own text (receipts.sh checks them) and are not judged here; a
`code span` is masked for every rule but the port, hash, SQL, meter, puts, rm and -am rules."""
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
STORE = re.compile(r"ConcurrentMap|ConcurrentHashMap|Caffeine|Redis|in the JVM|H2|PostgreSQL|the harness's|harness bean|SimpleKey", re.I)
WARNS = re.compile(r"\bSpring warns\b|\bwarns you\b|\ba warning\b|\bwarns\b", re.I)
LRU = re.compile(r"\bLRU\b|\bleast[- ]recently[- ]used\b|\bthe same eviction\b|\bthe same customer (?:leaves|goes|is dropped)\b|\bdrops the same\b|\bevicts the same\b", re.I)
POLICY = re.compile(r"TinyLFU|\bW-?TinyLFU\b|\bfrequency sketch\b|\bleast[- ]frequently[- ]used\b|\bLFU\b", re.I)
METER = re.compile(r"\bmeters?\b|cache_gets_total|cache_size|cache_evictions_total|\bcache_ lines?\b|\bprometheus line|\bhit line\b", re.I)
NAMED = re.compile(r"cache-names|named at the start|names? (?:given|set|listed)|caches named|the names", re.I)
SINGLE = re.compile(r"cache=\"customer\"|\bthe customer cache\b|`customer` cache|\bcache `customer`", re.I)
PUTS = re.compile(r"cache_puts_total", re.I)
PUTSOK = re.compile(r"\b(?:not|never) voiced\b|\bnever said\b|\bnot said\b", re.I)
HARNUM = re.compile(r"\[Meera, Nina, Ravi\]|maximumSize\(3\)|\bnonames\b|the copy's", re.I)
HARLAB = re.compile(r"harness|Caffeine's own API|not TiffinBox's|the copy|a copy|nonames|Course 2", re.I)
RMF = re.compile(r"\brm -f(?![a-z]*v)\b")
PLNOAM = re.compile(r"-pl tiffinbox-web(?! -am)")
PAGE = re.compile(r"\b(?:the dashboard|the page|GET /dashboard) is cached\b|\bcaches the (?:dashboard|page)\b", re.I)
GEN = re.compile(r"\bHibernate generates\b", re.I)
PORT = re.compile(r"localhost:\d{2,5}\b|127\.0\.0\.1:(?:[3-6]\d{4})\b")
TYPED = re.compile(r"(?<![\w.#:=/\[-])\d+\s+(?:tests?|customers?|rows?|calls?|statements?|invocations?|reads?|containers?|beans?|jars?|libraries|entries|keys?|words|lines?|hits?|misses|evictions?)\b"
                   r"|(?<![\w.#:=/-])(?:18|23|101|103)(?![\w:/\]-]|\.\d)"
                   r"|\b\d+ of \d+\b|\b(?:hit|miss|size|evictions?|hitCount|missCount)\s*=?\s*\d"
                   r"|\[\d+(?:, \d+)+\]", re.I)
HASH = re.compile(r"\b[0-9a-f]{32}\b|eedf32a3|c130857a|466c20ed|4e008fc9", re.I)
SQL = re.compile(r"SELECT customer\.|FROM customer\b|FROM \"customer\"|\"customer\"\.\"|select count\(", re.I)
TITLES = ["Reference Types: Strong, Soft, Weak and WeakHashMap", "N+1, Measured", "@Cacheable, @CacheEvict, @CachePut", "Caffeine",
          "The Cache Abstraction's Machinery", "Redis as a Cache", "The Second-Level Cache"]
CALLED = re.compile(r"\b(?:the )?lessons? called\b|\bCourse (?:2|4|5|6|7)\b(?!'s (?:final anchor|capstone|builders|scripts|harness|units|recipe|form|precedent|probe|IT|pinned|statistics|script|LinkedHashMap|own))|\bas Course 7\b", re.I)
CALLOK = re.compile(r"Course 7's (?:harness|units|recipe|form|precedent|builders|scripts|capstone|final|probe|IT|pinned|statistics)|c7-unit\d+|`c7-unit|`java[2578]_series\.py`|c2-unit04|core-java-2/", re.I)


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
    if WARNS.search(s): out.append("R.377: Spring warns - no WARN line is captured for the cache in this unit")
    if LRU.search(s): out.append("R.385: \"LRU\" / \"the same eviction\" for Caffeine - the two maps drop different customers")
    if POLICY.search(s): out.append("R.385: Caffeine's policy named - the receipt prints none")
    if METER.search(raw) and not NAMED.search(raw): out.append("R.384: a meter sentence without spring.cache.cache-names")
    if SINGLE.search(raw): out.append("R.392: the customer cache (the probe's) - the anchor ships only customers")
    if PUTS.search(raw) and not PUTSOK.search(raw): out.append("R.375: cache_puts_total voiced")
    if HARNUM.search(raw) and not HARLAB.search(raw): out.append("R.392: a harness or copy number without its label")
    if RMF.search(raw): out.append("R.387: rm -f without -v")
    if PLNOAM.search(raw): out.append("R.391: -pl tiffinbox-web without -am")
    if PAGE.search(s): out.append("R.389: a cached read set beside the page")
    if GEN.search(s): out.append("§10: \"Hibernate generates\"")
    if PORT.search(raw): out.append("R.319: a port printed raw: " + PORT.search(raw).group(0))
    if TYPED.search(s): out.append("R.302: a capture's number typed in prose: " + TYPED.search(s).group(0))
    if HASH.search(raw): out.append("R.302: a typed md5")
    if SQL.search(raw): out.append("R.225/R.365: a typed SQL string in the prose")
    if CALLED.search(raw) and not any(t in raw for t in TITLES) and not CALLOK.search(raw): out.append("R.224: a call-back without its title")
    return out


CASES = [("A cache hit is faster.", 1), ("It expires after a while.", 1), ("The cache works.", 1), ("Spring Data caches the list.", 1),
         ("Hibernate's cache keeps it.", 1), ("Not Hibernate's second-level cache, and not Spring Data.", 0),
         ("Spring warns you about it.", 1), ("Caffeine is LRU.", 1), ("Caffeine evicts the least recently used entry.", 1),
         ("The same eviction, industrialised.", 1), ("The same customer leaves.", 1), ("Caffeine runs Window TinyLFU.", 1),
         ("Same idea, a ceiling: Caffeine drops another customer.", 0),
         ("The prometheus line shows the hits.", 1), ("The meters appear for the caches named at the start, `spring.cache.cache-names`.", 0),
         ("The customer cache counts five hits.", 1), ("The `cache=\"customer\"` line reads 5.0.", 1), ("The customers cache, in the JVM, Caffeine's.", 0),
         ("`cache_puts_total` reads the loads.", 1), ("`cache_puts_total` is printed and not voiced.", 0),
         ("TiffinBox keeps `[Meera, Nina, Ravi]`.", 1), ("The harness on Caffeine's own API keeps `[Meera, Nina, Ravi]`.", 0),
         ("Run `docker rm -f c8u10-pg`.", 1), ("Run `docker rm -fv c8u10-pg`.", 0),
         ("Build with `mvn -o package -pl tiffinbox-web`.", 1), ("Build with `mvn -o package -pl tiffinbox-web -am`.", 0),
         ("The hit count is hit 4.", 1), ("Caffeine counts 4 hits.", 1), ("50 of 50 pairs.", 1), ("The lists read [1, 0, 0, 0, 0].", 1),
         ("The verify runs 23 tests.", 1), ("18 on H2.", 1), ("A cache hit costs no statement.", 1), ("A cache hit in the JVM, Caffeine's, costs nothing.", 0),
         ("Hibernate generates the SELECT.", 1), ("The URL was `jdbc:postgresql://localhost:32771/test`.", 1), ("Ports 20490-20499.", 0),
         ("The pin is eedf32a336609f92de214f7beba6d2ec.", 1), ("As Course 2 showed.", 1),
         ("As Course 2's *Reference Types: Strong, Soft, Weak and WeakHashMap* showed.", 0), ("Spring Boot 4.1.2 and Caffeine 3.2.4.", 0),
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
