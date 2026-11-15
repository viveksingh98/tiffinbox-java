"""Unit 32's prose gate, per sentence (python3 -I -B harness/s32.py harness/dur7.py FILE...), with a self-test that must pass first.
Carried from unit 31's s31: dur7's words (R.172), S4.7's duration meanings (R.264), R.301's time-meaning family (BLUE's tm.py: a
cost word only in a sentence that names a printed count), the words for pace, R.287 (Hibernate 5/6's wordings), R.190 (the eighteen
tests as a witness). Unit 32's own refused readings: S5.7 (R.290) - a hit ratio, a percentage or a hit/miss/put triple typed in a
sentence, and a stale-value claim without its three readings (the cached read, the database's value, the hit); S5.8 (R.291) -
"stale" without its writer named (psql, plain JDBC, a write Hibernate never saw), and Hibernate's own bulk paths said to leave the
cache stale or not to invalidate it (measured: both invalidate); R.302 - a jar count, a byte count or a warning count typed; R.303 -
a quoted JVM or Hibernate warning without its filed step; RED #1516 - a connection count or "no connection" for a hit, unscoped;
the loser - Spring's cache abstraction (spring-boot-starter-cache, @EnableCaching, Spring's @Cacheable) said without Course 8 or
without "not Hibernate's"; R.224 - "the lesson called" or "Course 8" without a title from the roadmap or the series. Lines inside a
fenced block and the values block are the runs' own text (receipts.sh checks each is printed) and are not judged here; nor is a
`code span` (a quoted token: a plant's text, a log line, a key) - the receipt's R.302, R.225 and R.303 greps still read them."""
import importlib.util, os, re, sys
spec = importlib.util.spec_from_file_location("dur7", sys.argv[1]); m = importlib.util.module_from_spec(spec); spec.loader.exec_module(m)
FAM = re.compile(r"\b(?:forever|for ever|at once|immediately|instantly|instant(?:ly)?|right away|in no time|a moment|momentar(?:y|ily)|"
                 r"(?:one|two|three|four|five|six|seven|eight|nine|ten|\d+)\s+(?:second|minute|hour)s?|half a second|eventually|"
                 r"a\s+(?:second|minute|hour)\b(?!-level|\s+`|\s+(?:connection|copy|run|JVM|database|read|request|time|dispatch|point|seed|collection|transaction|process|reading|class|set|key|phase)))\b", re.I)
NUM = r"(?:\d+|one|two|three|four|five|six|seven|eight|nine|ten|eleven|twelve|thirteen|fourteen|fifteen|twenty|thirty|fifty|a hundred|[NT])"
COST = re.compile(r"\b(?:costs?|costly|costing)\b", re.I)
TM = re.compile(r"\b(?:costs?|costly|costing|cheaper|cheap|expensive|saves? time|sav(?:es|ing) time|takes? longer|time-?consuming|round[- ]trips?)\b"
                rf"|\b{NUM}\s+times\b", re.I)
COUNT = re.compile(r"\b(?:statements?|SQL lines?|connections?|sessions?|rows?|batch(?:es)?|executeBatch|prepareStatement|jars?|regions?)\b", re.I)
SPEED = re.compile(r"\b(?:slow(?:er|ly)?|quick(?:er|ly)?|lag|faster|fast)\b", re.I)
OLD = re.compile(r"failed to lazily initialize|could not initialize proxy - no Session")
T18 = re.compile(r"\b18(?:/18| tests)\b[^.;]*\b(?:prove|proves|show(?:s)? (?:that )?the (?:fix|page|cache)|witness(?:es)?|caught|catch)\b", re.I)
GUARD = re.compile(r"guard|did not notice|not a witness|never a witness", re.I)
# S5.7: a typed ratio, percentage or counter triple; a stale-value claim beside its three readings
RATIO = re.compile(r"(?<![\d.])0\.\d{2,3}\b|\b\d{1,3}(?:\.\d+)? ?(?:%|per ?cent)|\bhit ratio (?:of|is|=|was) \d", re.I)
TRIPLE = re.compile(r"\bhits? \d+\b|\b\d+ (?:hits?|misses|puts)\b|\bmiss(?:es)? \d+\b|\bputs? \d+\b|\b\d+ · \d+ · \d+\b|\b\d+/\d+/\d+\b", re.I)
CLAIM = re.compile(r"\b(?:serves?|serving|returns?|answers?|reads?|says?|prints?)\b[^.;]*\b(?:the old value|old meals|the stale value)\b|\bstale (?:value|hit|read)\b", re.I)
R1 = re.compile(r"\b(?:cached|the cache|a hit|the hit|region)\b", re.I)
R2 = re.compile(r"\b(?:database|psql|second connection|the table)\b", re.I)
R3 = re.compile(r"\b(?:Statistics|hit|miss|put|getHitCount)\b", re.I)
# S5.8: stale with its writer; Hibernate's bulk paths never "stale"
STALE = re.compile(r"\bstale\b", re.I)
WRITER = re.compile(r"\bpsql\b|plain JDBC|\bnever (?:passes|passed) through Hibernate\b|Hibernate never (?:saw|sees|hears)|outside Hibernate|another process|second java\.sql\.Connection", re.I)
NATIVE = re.compile(r"(?:native|@Modifying|bulk|JPQL)[^.;]*(?:does(?: not|n't)|do(?: not|n't)|never|fails? to|won't|will not)\s+(?:invalidate|evict|clear|empty|touch)|"
                    r"(?:native|@Modifying|bulk|JPQL)[^.;]*(?:leaves?|leaving|keeps?)[^.;]*\b(?:stale|old value|cached entr)|"
                    r"(?:native|@Modifying)[^.;]*\bbypass(?:es)?\b[^.;]*\bcache\b", re.I)
# R.302 / R.303
JARS = re.compile(r"\b(?:\d+|one|two|three|four|five|six|seven|eight|nine|ten|eleven|twelve|thirteen|fourteen)\s+(?:added\s+)?(?:jars?|libraries)\b|\b\d{1,3}(?:,\d{3})+ (?:B|bytes)\b|\b\d{4,} (?:B|bytes)\b|\b\d+(?:\.\d+)? ?(?:MB|KB|kB|MiB|KiB)\b", re.I)
WARNS = re.compile(r"\b(?:\d+|one|two|three|four|five|six)\s+(?:JVM\s+|stderr\s+|WARN\s+|HHH90001006\s+)?(?:warning|WARNING:?|warnings|WARN) (?:lines?|messages?)\b|\b(?:\d+|one|two|three|four|five|six) HHH90001006\b", re.I)
QUOTE = re.compile(r"WARNING: A terminally|sun\.misc\.Unsafe::objectFieldOffset|HHH90001006: Missing|Could not load requested class")
FILED = re.compile(r"\bsetup\b|\bfiled\b|\blabelled\b|its step|the step", re.I)
# RED #1516: the connection sentence scoped
CONN = re.compile(r"\b(?:\d+|one|four|five|ten|twenty|forty) connections?\b|\bno connection\b|\bwithout (?:a|any) connection\b|\bskips? the connection\b", re.I)
CSCOPE = re.compile(r"own transaction|K × M|K x M|each transaction takes a connection|per transaction", re.I)
# the loser: Spring's cache abstraction is Course 8's
SPRINGC = re.compile(r"spring-boot-starter-cache|@EnableCaching|Spring's cache abstraction|Spring's @Cacheable|CacheManager", re.I)
SPRINGOK = re.compile(r"Course 8|not Hibernate|loser", re.I)
# R.224: a call-back by its title
TITLES = ["Cache Invalidation", "`@Cacheable`, `@CacheEvict`, `@CachePut`", "@Cacheable, @CacheEvict, @CachePut", "Spring Data beyond JPA",
          "Optimistic Locking with At-Version", "Optimistic Locking with @Version", "Lazy Loading and LazyInitializationException", "N+1, Measured",
          "JOIN FETCH vs @EntityGraph vs @BatchSize", "Your First Entity and EntityManager", "The Persistence Context", "The Second-Level Cache"]
PINNED = open(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "pinned.txt"), encoding="utf-8").read().strip()
CALLED = re.compile(r"\b(?:the )?lessons? called\b|\bCourse 8\b", re.I)


def verdicts(s, state, raw=None):
    out = []
    raw = s if raw is None else raw
    for w in m.DUR.finditer(s): out.append("dur7: " + w.group(0))
    for w in FAM.finditer(s): out.append("S4.7's family: " + w.group(0))
    hits = [w.group(0) for w in TM.finditer(s)]
    if hits and not (all(COST.fullmatch(h) for h in hits) and COUNT.search(s)): out.append("R.301's family: " + ", ".join(hits))
    for w in SPEED.finditer(s): out.append("a speed word: " + w.group(0))
    for w in OLD.finditer(s): out.append("R.287: Hibernate 5/6's wording: " + w.group(0))
    if T18.search(s) and not GUARD.search(s): out.append("R.190: the 18 tests as a witness")
    if RATIO.search(s): out.append("S5.7: a ratio typed: " + RATIO.search(s).group(0))
    if TRIPLE.search(s): out.append("S5.7: a hit/miss/put count typed: " + TRIPLE.search(s).group(0))
    if CLAIM.search(s) and s.strip() not in PINNED and not s.lstrip('"*').startswith("Your turn:") and not (R1.search(s) and R2.search(s) and R3.search(s)): out.append("S5.7: a stale-value claim without its three readings: " + CLAIM.search(s).group(0))
    if STALE.search(s) and not WRITER.search(s): out.append("S5.8: stale without the writer Hibernate never saw")
    if NATIVE.search(s): out.append("S5.8: Hibernate's bulk path said not to invalidate (measured: it does): " + NATIVE.search(s).group(0))
    if JARS.search(s): out.append("R.302: a jar or byte count typed: " + JARS.search(s).group(0))
    if WARNS.search(s): out.append("R.302: a warning count typed: " + WARNS.search(s).group(0))
    if QUOTE.search(s) and not FILED.search(s): out.append("R.303: a quoted warning without its filed step")
    if CONN.search(s) and not CSCOPE.search(s): out.append("#1516: a connection count without its scope: " + CONN.search(s).group(0))
    if SPRINGC.search(s) and not SPRINGOK.search(s): out.append("the loser: Spring's cache abstraction said for Hibernate's: " + SPRINGC.search(s).group(0))
    if CALLED.search(s) and not any(t in raw for t in TITLES): out.append("R.224: a call-back without its title")
    return out


CASES = [("ten times slower", 1), ("the cached read is faster", 1), ("that costs a lot", 1), ("forever", 1), ("at once", 1),
         ("a second connection reads the table", 0), ("a second transaction reads it", 0), ("failed to lazily initialize a collection", 1),
         ("18/18 proves the cache works.", 1), ("18/18 on the anchor: a guard.", 0),
         ("The hit ratio is 0.800 at K = 5.", 1), ("The hit ratio is 80% here.", 1), ("Spring Framework 7.0.10 and Hibernate 7.4.13.Final", 0), ("The ratio is derived by chk32 from the printed counts.", 0),
         ("The region says hit 16 and miss 4.", 1), ("16 hits and 4 misses.", 1), ("hit · miss · put, read per region.", 0),
         ("The cache serves the old value.", 1), ("Your turn: the cache keeps serving the old meals after psql changed them.", 0),
         ("a second `java.sql.Connection` on the same URL", 0),
         ("The cached read serves the old value, a hit in Statistics, while psql reads the new one from the database.", 0),
         ("The value is stale.", 1), ("After psql's update the cached value is stale.", 0),
         ("A native query leaves the cache stale.", 1), ("A native @Modifying query does not invalidate the cache.", 1),
         ("The native @Modifying update bypasses the cache.", 1), ("A JPQL bulk update leaves the old value in the cache.", 1),
         ("Both bulk paths empty the region: the next reads miss.", 0), ("The native update invalidates the cached customers.", 0),
         ("Caffeine adds 11 jars.", 1), ("Caffeine adds eleven jars.", 1), ("The set weighs 1,681,123 bytes.", 1), ("about 1.7 MB", 1),
         ("The added set is printed by ls -l and summed by the receipt.", 0),
         ("Ehcache prints four warning lines.", 1), ("Hibernate warns with 3 HHH90001006 lines.", 1),
         ("The JVM says WARNING: A terminally deprecated method in sun.misc.Unsafe has been called.", 1),
         ("Ehcache's labelled step in setup prints WARNING: A terminally deprecated method in sun.misc.Unsafe has been called.", 0),
         ("The 20 reads take 20 connections.", 1), ("A hit takes no connection.", 1),
         ("Each read here runs in its own transaction, and each transaction takes a connection - a hit included.", 0),
         ("spring-boot-starter-cache would do it.", 1), ("spring-boot-starter-cache is Spring's cache abstraction, not Hibernate's.", 0),
         ("as the lesson called Locking said", 1), ("the same hash as in the lesson called Optimistic Locking with At-Version.", 0),
         ("Course 8 comes back to it.", 1), (PINNED, 0),
         (re.sub(r"`[^`]*`", "`…`", "the plant `A native query leaves the cache stale.` is refused"), 0)]
for t, want in CASES:
    got = verdicts(t, {})
    assert bool(got) == bool(want), (t, got)
n = 0
for p in sys.argv[2:]:
    st = {}; fence = False; vals = False
    for i, l in enumerate(open(p, encoding="utf-8"), 1):
        if l.startswith("```"): fence = not fence; continue
        if l.strip() == "<!-- values: begin -->": vals = True; continue
        if l.strip() == "<!-- values: end -->": vals = False; continue
        if fence or vals: continue
        for s in re.split(r"(?<=[.;!?])\s+", re.sub(r"`[^`]*`", "`…`", l)):
            for v in verdicts(s, st, l):
                n += 1; print("  %s line %d: %s" % (p, i, v))
print("self-test: %d cases · refused: %d" % (len(CASES), n))
