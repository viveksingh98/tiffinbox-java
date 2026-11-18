"""Unit 11's prose gate, per sentence (python3 -I -B harness/s811.py harness/dur8.py FILE...), with a self-test that must pass first.
Carried from unit 10's s810.py (dur8's words, R.388's duration family, the speed and cost words, "the cache works", the abstraction
credited to Spring Data or Hibernate, a hit without its store, "Spring warns", "LRU" and the policy for Caffeine, a meter sentence
without spring.cache.cache-names, a cached page, "Hibernate generates", a raw port, a typed md5, a typed SQL string, a call-back
without its title, typed counts), with unit 11's refused readings (the brief's plant list and the prompt): "Redis is asynchronous" /
"Redis writes asynchronously" (flag 5 - the writer's calls are); a Redis sentence about evict, clear, a read after a write or the
stale list that does not name the writer (R.378); the JSON bytes said without both the bytes and the class read back (R.379 - a
"bytes" sentence names redis-cli or GET, and the class); the silence credited to Redis or to JSON (R.379/R.370 - the serializer's own
setting, FAIL_ON_UNKNOWN_PROPERTIES); a customer:: key or the customer cache (R.392 - only customers::SimpleKey [] at 11/after); a
TTL as a time ("after two seconds", "expires quickly") (R.380); a health sentence without the no-Redis default run (R.386); "Redis
as a datastore" (C8-15 - "as a cache"); rm -f without -v and Compose down without -v (R.387); -pl tiffinbox-web without -am (R.391);
pull_policy: never or a digest said as the viewer's compose.yaml line (flag 7); a spring.data.redis key said to be in the anchor's
YAML (flag 7 - Compose wires it); R.302 - a measured count typed in prose (1, 2, a per-call list, N of 10, TTL -1, 503, 200, 18 + 5,
the libs count, 8.10.3 beside its count). Lines inside a fenced block, the values block and the exercise's **Your turn:** line (the brief's words) are not judged here: the runs' own text (receipts.sh checks
them) and are not judged here; a `code span` is masked for every rule but the port, hash, SQL, meter, puts, rm, down, -am and key
rules."""
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
ASYNC = re.compile(r"\bRedis (?:is|writes|works) asynchronous(?:ly)?\b|\basynchronous Redis\b|\bRedis is async\b", re.I)
REDISOP = re.compile(r"\b(?:stale|@CacheEvict|evict(?:s|ed|ion)?|clear\(\)|read right after|read after a write|right after a write)\b", re.I)
WRITER = re.compile(r"\bwriter\b|immediateWrites|enableLocking", re.I)
REDISW = re.compile(r"\bRedis\b")
BYTES = re.compile(r"\bthe bytes\b|\bbytes Redis\b|\bthe JSON (?:bytes|text)\b", re.I)
BYTESOK = re.compile(r"redis-cli|\bGET\b", re.I)
CLASSOK = re.compile(r"\bclass(?:es)?\b|ArrayList|read back|@class", re.I)
SILENT = re.compile(r"\b(?:silent(?:ly)?|without a word|no exception)\b", re.I)
SILCREDIT = re.compile(r"\b(?:Redis|JSON|Jackson) (?:hides|swallows|ignores|drops|silences)\b|\bRedis(?:'s)? fault\b|\bJSON(?:'s)? fault\b", re.I)
SILOK = re.compile(r"FAIL_ON_UNKNOWN_PROPERTIES|unknown-property check|the serializer(?:'s)?|its own setting|strict", re.I)
CKEY = re.compile(r"\bcustomer::|`customer`(?: cache)?|\bthe customer cache\b|cache=\"customer\"", re.I)
TTLT = re.compile(r"\bexpires? (?:quickly|soon|after)\b|\bafter (?:two|\d+) seconds?\b|\bTTL of \d+ ?s\b", re.I)
HEALTH = re.compile(r"/actuator/health\b|\bhealth (?:answers|is|turns)\b|\b503\b", re.I)
HEALTHOK = re.compile(r"no Redis|without Redis|default run|indicator|Redis absent|Redis down|is down", re.I)
DSTORE = re.compile(r"\bRedis as a (?:datastore|data store|database)\b|\bas a datastore\b", re.I)
DSTOREOK = re.compile(r"C8-15|Section 3|not a datastore|as a cache, not", re.I)
DOWNNV = re.compile(r"\bdown(?! -v)\b(?=[`\s.,;)]|$)")
DOWNCTX = re.compile(r"compose[^.]*\bdown\b", re.I)
PULLV = re.compile(r"(?:viewer's|the anchor's) `?compose\.yaml`?[^.]*(?:pull_policy|redis@sha256)", re.I)
DRKEY = re.compile(r"spring\.data\.redis\.\w+`?[^.]*\b(?:in|from) `?(?:the anchor's|application(?:-dev)?\.yaml)", re.I)
DRKEYOK = re.compile(r"\bno\b|\bnot\b|\bnever\b|\b0\b", re.I)
PAGE = re.compile(r"\b(?:the dashboard|the page|GET /dashboard) is cached\b|\bcaches the (?:dashboard|page)\b", re.I)
GEN = re.compile(r"\bHibernate generates\b", re.I)
PORT = re.compile(r"localhost:\d{2,5}\b|127\.0\.0\.1:(?:[3-6]\d{4})\b")
TYPED = re.compile(r"(?<![\w.#:=/\[-])\d+\s+(?:tests?|customers?|rows?|calls?|statements?|invocations?|reads?|containers?|beans?|jars?|libraries|entries|keys?|words|lines?|hits?|misses|evictions?)\b"
                   r"|(?<![\w.#:=/-])(?:18|23|103|122|503|19)(?![\w:/\]-]|\.\d)"
                   r"|\bTTL -?\d|\bstale in \d|\b\d+ of 10\b"
                   r"|\b\d+ of \d+\b|\b(?:hit|miss|size|evictions?|hitCount|missCount)\s*=?\s*\d"
                   r"|\[\d+(?:, \d+)+\]", re.I)
HASH = re.compile(r"\b[0-9a-f]{32}\b|c130857a|0befc453|466c20ed|256c7752", re.I)
SQL = re.compile(r"SELECT customer\.|FROM customer\b|FROM \"customer\"|\"customer\"\.\"|select count\(", re.I)
TITLES = ["Docker Compose for Development", "N+1, Measured", "@Cacheable, @CacheEvict, @CachePut", "Caffeine",
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
    if ASYNC.search(raw): out.append("flag 5: \"Redis is asynchronous\" - the writer's calls are")
    if REDISW.search(raw) and REDISOP.search(raw) and not WRITER.search(raw): out.append("R.378: a Redis evict / clear / read-after-write sentence without the writer named")
    if BYTES.search(raw) and REDISW.search(raw) and not (BYTESOK.search(raw) and CLASSOK.search(raw)): out.append("R.379: the bytes without redis-cli's GET and the class read back")
    if SILCREDIT.search(raw) or (SILENT.search(raw) and re.search(r"\brenamed\b", raw, re.I) and not SILOK.search(raw)): out.append("R.379/R.370: the silence credited to Redis or JSON, not the serializer's own setting")
    if CKEY.search(raw): out.append("R.392: a customer:: key or the customer cache - the anchor at 11/after caches only customers::SimpleKey []")
    if TTLT.search(s): out.append("R.380: a TTL said as a time")
    if HEALTH.search(raw) and not HEALTHOK.search(raw): out.append("R.386: a health sentence without the default run that has no Redis")
    if DSTORE.search(raw) and not DSTOREOK.search(raw): out.append("C8-15: Redis as a datastore - this unit is Redis as a cache")
    if DOWNCTX.search(raw) and DOWNNV.search(raw): out.append("R.387: Compose down without -v")
    if PULLV.search(raw): out.append("flag 7: pull_policy or a digest as the viewer's compose.yaml line")
    if DRKEY.search(raw) and not DRKEYOK.search(raw): out.append("flag 7: a spring.data.redis key in the anchor's YAML")
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
         ("As Course 5's *Docker Compose for Development* showed.", 0), ("Spring Boot 4.1.2 and Caffeine 3.2.4.", 0),
         ("The numbers are in the values block.", 0), ("It took two seconds.", 1), ("`@Cacheable` on `findAll`.", 0),
         ("Redis is asynchronous.", 1), ("The writer Boot builds over Lettuce writes asynchronously; Redis does not.", 0),
         ("On Redis the read right after `@CacheEvict` is stale.", 1), ("On Redis, with the writer Boot builds over Lettuce, the read right after `@CacheEvict` is stale.", 0),
         ("The bytes Redis keeps are JSON.", 1), ("The bytes Redis keeps, by redis-cli's `GET`, beside the class Java read back.", 0),
         ("Redis hides the renamed field.", 1), ("The renamed field comes back empty, silently.", 1),
         ("The renamed field comes back empty, silently: the serializer's own setting turns `FAIL_ON_UNKNOWN_PROPERTIES` off.", 0),
         ("The key `customer::Ravi` holds her.", 1), ("The key `customers::SimpleKey []` holds the list.", 0),
         ("The entry expires after two seconds.", 1), ("The time to live the configuration sets, read back by redis-cli.", 0),
         ("`/actuator/health` answers 503.", 1), ("With no Redis, Redis's indicator on, `/actuator/health` answers DOWN.", 0),
         ("Redis as a datastore.", 1), ("Redis as a cache, not a datastore (C8-15, Section 3).", 0),
         ("Run `docker compose -p c8-unit11 down`.", 1), ("Run `docker compose -p c8-unit11 down -v`.", 0),
         ("The viewer's `compose.yaml` carries `pull_policy: never`.", 1), ("The receipts' copy carries `pull_policy: never`.", 0),
         ("`spring.data.redis.port` is set in `application-dev.yaml`.", 1), ("No `spring.data.redis.port` is set in `application-dev.yaml`.", 0),
         ("The key's TTL -1.", 1), ("Stale in 10 of 10 rounds.", 1), ("The libraries are 122.", 1), ("Redis 8.10.3, by the digest.", 0)]
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
        if l.startswith("**Your turn:**"): continue   # the brief's spoken line, byte for byte - receipts.sh checks it and its word count
        if not para: start = i
        para.append(l)
    if para: judge(p, start, para)
print("self-test: %d cases · refused: %d" % (len(CASES), n))
