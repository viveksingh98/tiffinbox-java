"""Unit 08's prose gate, per sentence (python3 -I -B harness/s808.py harness/dur8.py FILE...), with a self-test that must pass first.
Carried from unit 07's s807.py (dur8's words, S4.7's duration family, the speed and cost words, a typed md5, "Hibernate generates" never,
a call-back without its title, a typed SQL string, a raw port, typed counts), with Section 2's rules for unit 08: R.375 - "the cache
works" / "it just caches" (a hit is two witnesses, never a slogan); R.348 / C8-16 - "Spring Data caches", "Spring Data's cache",
"Hibernate's cache" for the abstraction (spring-context's annotations, Boot's spring-boot-cache module; a negated naming - "not
Hibernate's second-level cache" - passes); R.376 - a sentence about a hit or a cached read that names neither the store nor the
manager nor the database that answered; R.377 - "Spring warns" / "a warning" (no WARN line is captured for the cache; unit 08 names
none); R.388's family - "after a while", "short", "briefly", "in a moment", "faster", "instantly"; R.389 - a cached read set beside the
page ("the dashboard is cached", "the page is cached"). Lines inside a fenced block and the values block are the runs' own text
(receipts.sh checks them) and are not judged here; a `code span` is masked for every rule but the port, hash and SQL rules."""
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
STORE = re.compile(r"ConcurrentMap|ConcurrentHashMap|in the JVM|H2|PostgreSQL|the harness's|harness bean|SimpleKey", re.I)
WARNS = re.compile(r"\bSpring warns\b|\bwarns you\b|\ba warning\b", re.I)
PAGE = re.compile(r"\b(?:the dashboard|the page|GET /dashboard) is cached\b|\bcaches the (?:dashboard|page)\b", re.I)
GEN = re.compile(r"\bHibernate generates\b", re.I)
PORT = re.compile(r"localhost:\d{2,5}\b|127\.0\.0\.1:(?:[3-6]\d{4})\b")
TYPED = re.compile(r"(?<![\w.#:=/\[-])(?:18|23)(?![\w:/\]-]|\.\d)"
                   r"|(?<![\w.#:=/-])\d+\s+(?:tests?|customers?|rows?|calls?|statements?|invocations?|reads?|containers?|beans?|jars?|libraries|entries|keys?|puts?|words)\b", re.I)
HASH = re.compile(r"\b[0-9a-f]{32}\b|466c20ed|f16230d4|48e9f0d8|bbc1ce32|69ea1c83|32a886c9", re.I)
SQL = re.compile(r"SELECT customer\.|FROM customer\b|FROM \"customer\"|\"customer\"\.\"", re.I)
TITLES = ["The Second-Level Cache", "N+1, Measured", "Testing the JDBC Layer", "Aggregates, Not Entities", "The Cache Abstraction's Machinery", "Caffeine",
          "JDK Proxies vs CGLIB, and the Self-Invocation Trap", "@Transactional: What the Proxy Does"]
CALLED = re.compile(r"\b(?:the )?lessons? called\b|\bCourse (?:2|4|5|6|7)\b(?!'s (?:final anchor|capstone|builders|scripts|harness|units|recipe|form|precedent|probe|IT|pinned|statistics))|\bas Course 7\b", re.I)
CALLOK = re.compile(r"Course 7's (?:harness|units|recipe|form|precedent|builders|scripts|capstone|final|probe|IT|pinned|statistics)|c7-unit\d+|`c7-unit|`java7_series\.py`", re.I)


def verdicts(s, raw=None):
    out = []
    raw = s if raw is None else raw
    for w in m.DUR.finditer(s): out.append("dur8: " + w.group(0))
    for w in FAM.finditer(s): out.append("R.388 / S4.7's family: " + w.group(0))
    for w in SPEED.finditer(s):
        if not m.DUR.search(w.group(0)): out.append("a speed word: " + w.group(0))
    for w in COST.finditer(s): out.append("R.355: a cost word: " + w.group(0))
    if WORKS.search(s): out.append("R.375: \"the cache works\" - a hit is two witnesses from one run, never a slogan")
    if OWNER.search(s) and not OWNNEG.search(s): out.append("R.348 / C8-16: the abstraction credited to Spring Data or Hibernate: " + OWNER.search(s).group(0))
    if HITW.search(s) and not STORE.search(raw): out.append("R.376: a hit or a cached read without its store, its manager or the database that answered")
    if WARNS.search(s): out.append("R.377: Spring warns - no WARN line is captured for the cache in this unit")
    if PAGE.search(s): out.append("R.389: a cached read set beside the page - the dashboard's four reads are four windows")
    if GEN.search(s): out.append("§10: \"Hibernate generates\"")
    if PORT.search(raw): out.append("R.319: a port printed raw: " + PORT.search(raw).group(0))
    if TYPED.search(s): out.append("R.302: a capture's number typed in prose: " + TYPED.search(s).group(0))
    if HASH.search(raw): out.append("R.302: a typed md5")
    if SQL.search(raw): out.append("R.225/R.365: a typed SQL string in the prose")
    if CALLED.search(raw) and not any(t in raw for t in TITLES) and not CALLOK.search(raw): out.append("R.224: a call-back without its title")
    return out


CASES = [("A cache hit is faster.", 1), ("The read returns instantly.", 1), ("It expires after a while.", 1), ("A short window.", 1), ("It ran briefly.", 1),
         ("The cache works.", 1), ("It just caches the list.", 1), ("Spring Data caches the list.", 1), ("Hibernate's cache keeps it.", 1),
         ("Not Hibernate's second-level cache, and not Spring Data: Spring Framework's annotations.", 0),
         ("A cache hit costs no statement.", 1), ("A cache hit on H2 costs no statement.", 0), ("The hit, in the JVM, a ConcurrentMap.", 0),
         ("Spring warns you about it.", 1), ("The dashboard is cached.", 1), ("Hibernate generates the SELECT.", 1),
         ("The URL was `jdbc:postgresql://localhost:32771/test`.", 1), ("The verify runs 23 tests.", 1), ("18 on H2.", 1), ("It makes 5 calls.", 1),
         ("The read costs 1 statement.", 1), ("The seven's md5 is 466c20ed.", 1), ("The SQL reads SELECT customer.id AS id.", 1),
         ("As Course 7 showed.", 1), ("As Course 7's *The Second-Level Cache* showed.", 0), ("Ports 20470-20479.", 0), ("Spring Boot 4.1.2.", 0),
         ("The numbers are in the values block.", 0), ("It took two seconds.", 1), ("A second client reads the rows.", 0), ("Five calls, one statement.", 0),
         ("`@EnableCaching` on `TiffinBoxApp`.", 0), ("Course 7's pinned counter, unchanged.", 0)]
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
