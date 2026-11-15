"""Unit 34's prose gate, per sentence (python3 -I -B harness/s34.py harness/dur7.py FILE...), with a self-test that must pass first.
Carried from unit 33's s33: dur7's words (R.172), S4.7's duration meanings (R.264), R.287 (Hibernate 5/6's wordings), R.190 (the
eighteen tests as a witness), R.224 (a call-back by its title), R.301 (S5.18) BLUE's tm.py family (cost/costs/costly, cheaper,
expensive, saves time, takes longer, round trip, "N times" with digits or number-words) only beside the threshold line or, the cost
words alone, in a sentence naming a printed count, S5.9 (R.292) - a verdict on a ratio ("no difference", "about the same", "within
noise"), a duration word in a sentence about H2 - and R.207 (a spoken median), R.302 (a ratio typed, a jar count). Unit 34's own:
the brief's dur7 line - "slow" (and "slower") only in a sentence that carries PostgreSQL's threshold line (ratio >= T: true), "on this
Mac" and "on PostgreSQL" - never on H2 (S5.11), so never beside the SQL_SLOW chip alone; "milliseconds" never (dur7: inside a capture's
masked line only, and those are fenced); S5.12 (R.295) a URL with a password, or a raw p6spy line, in prose; S5.13 (R.296) "no log
level silences show-sql" (and its kin) only in a paragraph that names the OFF run's control (isDebugEnabled, the effective level);
S5.17 (R.300) a grouped timing described as the design; R.245 a plan's cost or a rows= figure in prose; R.302/R.252 a typed md5 (the
old script's, the new one's, the seven's) in prose; the developer boundary ("database administration") with the course title in the
same sentence, and once in all the files. Lines inside a fenced block, the values block and the slow table are the runs' own text
(receipts.sh checks them) and are not judged here; nor is a `code span` (a quoted token: a plant's text, a log line, a logger's name
such as `org.hibernate.SQL_SLOW`) - the receipt's greps still read them; the threshold line counts as present when the raw sentence
carries it, in a code span or not; the password, cost, md5 and grouped checks read the raw sentence, code spans included."""
import importlib.util, re, sys
spec = importlib.util.spec_from_file_location("dur7", sys.argv[1]); m = importlib.util.module_from_spec(spec); spec.loader.exec_module(m)
FAM = re.compile(r"\b(?:forever|for ever|at once|immediately|instantly|instant(?:ly)?|right away|in no time|a moment|momentar(?:y|ily)|"
                 r"(?:one|two|three|four|five|six|seven|eight|nine|ten|\d+)\s+(?:second|minute|hour)s?|half a second|eventually|"
                 r"a\s+(?:second|minute|hour)\b(?!-level|\s+`|\s+(?:connection|copy|run|JVM|database|read|request|time|dispatch|point|seed|collection|transaction|process|reading|class|set|key|phase|harness|look|index|half)))\b", re.I)
# BLUE's tm.py (#1506), its regexes as BLUE tested them on 24 cases
NUM = r"(?:\d+|one|two|three|four|five|six|seven|eight|nine|ten|eleven|twelve|thirteen|fourteen|fifteen|twenty|thirty|fifty|a hundred|[NT])"
COST = re.compile(r"\b(?:costs?|costly|costing)\b", re.I)
TM = re.compile(r"\b(?:costs?|costly|costing|cheaper|cheap|expensive|saves? time|sav(?:es|ing) time|takes? longer|time-?consuming|round[- ]trips?)\b"
                rf"|\b{NUM}\s+times\b", re.I)
COUNT = re.compile(r"\b(?:statements?|SQL lines?|connections?|sessions?|rows?|batch(?:es)?|executeBatch|prepareStatement|lines?)\b", re.I)
GATE = re.compile(r"ratio >= (?:T|\d+): true")
MAC = re.compile(r"\bon this Mac\b", re.I)
PGS = re.compile(r"\bon PostgreSQL\b", re.I)
GATED = re.compile(r"\b(?:slow|slower)\b", re.I)
SPEED = re.compile(r"\b(?:slow(?:er|ly)?|quick(?:er|ly)?|lag|faster|fast)\b", re.I)
OLD = re.compile(r"failed to lazily initialize|could not initialize proxy - no Session")
T18 = re.compile(r"\b18(?:/18| tests)\b[^.;]*\b(?:prove|proves|show(?:s)? (?:that )?the (?:fix|page|index|change)|witness(?:es)?|caught|catch)\b", re.I)
GUARD = re.compile(r"guard|did not notice|not a witness|never a witness", re.I)
H2 = re.compile(r"\bH2\b")
VERDICT = re.compile(r"\bno (?:real )?(?:difference|gain|benefit|speed-?up)\b|\babout the same\b|\bwithin (?:the )?noise\b|\bthe same speed\b|\bmakes? no difference\b|\bas fast as\b|\bbarely\b|\bflat line\b|\bnegligible\b", re.I)
DURW = re.compile(r"\b(?:faster|slower|quick\w*|slow\w*|speed\w*|time[sd]?|timing|duration|cost\w*|cheaper|expensive|takes? longer|ratio is|wins?|gains?)\b", re.I)
H2OK = re.compile(r"no threshold|never characteri[sz]ed|numbers? on (?:the|a) chip|as numbers|changes no plan|unused|unchanged", re.I)
MEDIAN = re.compile(r"\bmedians?\b[^.;]*\b(?:\d+|one|two|three|four|five|six|seven|eight|nine|ten|eleven|twelve|thirteen|fourteen|fifteen|twenty|thirty|forty|fifty|hundred)\b(?! (?:JVMs?|rounds?|runs?|lookups?|timed|warm-up))", re.I)
RATIO = re.compile(r"(?<![\w.])\d+\.\d\d\b|\bratio (?:of|is|was|=) \d", re.I)
JARS = re.compile(r"\b(?:\d+|one|two|three|four|five|six|seven|eight|nine|ten|eleven|twelve|fourteen)\s+(?:added\s+)?(?:jars?|libraries)\b|\b\d{1,3}(?:,\d{3})+ (?:B|bytes)\b|\b\d+(?:\.\d+)? ?(?:MB|KB|kB|MiB|KiB)\b", re.I)
# S5.12: a password in prose; a raw p6spy line
PWD = re.compile(r"password=(?!<pw>)|\?user=sa&password=[^<]|^\d{10,}\|\d+\|statement\|", re.I)
# R.245: a plan's numbers
COSTN = re.compile(r"\bcost=|\brows=\d|\bloops=\d|Rows Removed by Filter: \d|Heap Blocks: exact=\d")
# R.302 / R.252: a typed md5
HASH = re.compile(r"\b[0-9a-f]{32}\b|\b7f6942f0|\b9cf92b8c|\b466c20ed|\b(?:md5|hash) [0-9a-f]{6,}", re.I)
# S5.17: a grouped timing as the design
GROUPED = re.compile(r"\bgrouped\b|\ball (?:the )?(?:rounds )?without(?:,)? then all (?:the rounds )?with\b|\bwithout first, then with\b", re.I)
GROUPOK = re.compile(r"\brefused\b|\bnever\b|\bnot\b|\binstead of\b|\bthe probe's\b|\bBLUE's\b|\border effect\b|\bwas\b|\bwere\b", re.I)
# S5.13: show-sql's claim, judged per paragraph
SILENCE = re.compile(r"no (?:log )?level silences|does not silence|cannot silence|not silenced|still prints?|still printed", re.I)
CONTROL = re.compile(r"isDebugEnabled|effective level", re.I)
# the developer boundary
BOUND = re.compile(r"database administration", re.I)
COURSE20 = "Databases for Java Developers"
# R.224: a call-back by its title
TITLES = ["Optimistic Locking with At-Version", "Optimistic Locking with @Version", "Paging and Sorting", "Your First Entity and EntityManager",
          "Lazy Loading and LazyInitializationException", "N+1, Measured", "JOIN FETCH vs @EntityGraph vs @BatchSize", "The Second-Level Cache",
          "Batching and the Write Path", "SQL in 15 Minutes: TiffinBox Tables in H2", "Flyway: Versioned Migrations", "Capstone: TiffinBox on Postgres",
          "Ids and Generation Strategies", "The Persistence Context", COURSE20]
CALLED = re.compile(r"\b(?:the )?lessons? called\b|\bCourse (?:2|20)\b", re.I)


def verdicts(s, raw=None):
    out = []
    raw = s if raw is None else raw
    gate = bool(GATE.search(raw)) and bool(MAC.search(raw)) and bool(PGS.search(raw))
    h2 = bool(H2.search(s))
    for w in m.DUR.finditer(s):
        if not (gate and not h2 and GATED.fullmatch(w.group(0))): out.append("dur7: " + w.group(0))
    for w in FAM.finditer(s): out.append("S4.7's family: " + w.group(0))
    hits = [w.group(0) for w in TM.finditer(s)]
    if hits and not GATE.search(raw) and not (all(COST.fullmatch(h) for h in hits) and COUNT.search(s)): out.append("R.301's family: " + ", ".join(hits))
    for w in SPEED.finditer(s):
        if not (gate and not h2 and GATED.fullmatch(w.group(0))) and not m.DUR.search(w.group(0)): out.append("a speed word: " + w.group(0))
    for w in OLD.finditer(s): out.append("R.287: Hibernate 5/6's wording: " + w.group(0))
    if T18.search(s) and not GUARD.search(s): out.append("R.190: the 18 tests as a witness")
    if h2 and DURW.search(s) and not H2OK.search(s): out.append("S5.9/S5.11: a duration word in a sentence about H2: " + DURW.search(s).group(0))
    if VERDICT.search(s): out.append("S5.9: a verdict on a ratio: " + VERDICT.search(s).group(0))
    if MEDIAN.search(s): out.append("R.207: a spoken median: " + MEDIAN.search(s).group(0))
    if RATIO.search(s): out.append("R.302: a ratio typed: " + RATIO.search(s).group(0))
    if JARS.search(s): out.append("R.302: a jar or byte count typed: " + JARS.search(s).group(0))
    if PWD.search(raw): out.append("S5.12: a password or a raw p6spy line in prose")
    if COSTN.search(raw): out.append("R.245: a plan's cost or rows in prose: " + COSTN.search(raw).group(0))
    if HASH.search(raw): out.append("R.302/R.252: a typed md5: " + HASH.search(raw).group(0))
    if GROUPED.search(raw) and not GROUPOK.search(raw): out.append("S5.17: a grouped timing as the design")
    if BOUND.search(raw) and COURSE20 not in raw: out.append("the developer boundary without the course title")
    if CALLED.search(s) and not any(t in raw for t in TITLES): out.append("R.224: a call-back without its title")
    return out


def para_verdicts(text):
    out = []
    if SILENCE.search(text) and re.search(r"show-sql|show_sql", text) and not CONTROL.search(text): out.append("S5.13: show-sql's claim without the OFF run's control in the paragraph")
    return out


CASES = [("ten times", 1), ("the index is ten times quicker on PostgreSQL", 1), ("Batching saves time on PostgreSQL only", 1), ("13 times", 1), ("round trip", 1),
         ("On this Mac, on PostgreSQL, the lookup is slow without the index in every JVM: ratio >= T: true.", 0),
         ("On PostgreSQL the lookup is slow without the index.", 1), ("On this Mac the lookup is slow: ratio >= T: true.", 1),
         ("On this Mac, on PostgreSQL and on H2, the lookup is slow: ratio >= T: true.", 1),
         ("On H2 the lookup is slow without the index.", 1), ("The query is slow: `org.hibernate.SQL_SLOW` printed lines.", 1),
         ("At a configured `5` the `org.hibernate.SQL_SLOW` logger printed lines without the index and none with it - a chip, never a verdict.", 0),
         ("It took 6 milliseconds.", 1), ("forever", 1), ("at once", 1), ("a second connection reads the table", 0), ("failed to lazily initialize a collection", 1),
         ("18/18 proves the index works.", 1), ("18/18 on after/: a guard.", 0),
         ("On H2 the index makes no difference.", 1), ("H2's ratio is about the same.", 1), ("On H2 the lookup is faster with the index.", 1),
         ("H2's ratios are printed as numbers on the chip, never characterised.", 0), ("On H2 the new index changes no plan.", 0),
         ("The median was about thirty milliseconds.", 1), ("The medians of 9 timed rounds per JVM are masked.", 0),
         ("The PostgreSQL ratio is 13.71.", 1), ("p6spy adds 2 jars.", 1),
         ("The URL `jdbc:p6spy:postgresql://127.0.0.1:20138/u34spy?user=sa&password=Xy12` is in every line.", 1),
         ("Every line carries `?user=sa&password=<pw>` after the mask.", 0),
         ("The plan says `Seq Scan on pause pe1_0 (cost=0.00..3582.03 rows=100 width=20)`.", 1), ("The plan without the index is a sequential scan of the whole table.", 0),
         ("Hibernate's script moved from 9cf92b8cae3abfd0f1c0706bfe7a4373 to the new one.", 1), ("Hibernate's script moved: unit 34 adds one line to it.", 0),
         ("The timing runs all rounds without, then all with the index.", 1), ("The rounds are grouped by side.", 1),
         ("The probe's grouped design was refused: an order effect falls on one side.", 0),
         ("Past this is database administration.", 1), ("Past this is database administration - a future course 20, Databases for Java Developers.", 0),
         ("as the lesson called Locking said", 1), ("the same hash as in the lesson called Optimistic Locking with At-Version.", 0),
         ("Course 2 showed the tables.", 1), ("Course 2's lesson called `SQL in 15 Minutes: TiffinBox Tables in H2` showed the tables.", 0),
         ("And the index costs every insert one more write.", 1), ("EAGER costs every list four more statements.", 0)]
PCASES = [("No log level silences show-sql: it prints to standard output.", 1),
          ("No log level silences show-sql: in the OFF run org.hibernate.SQL's effective level is OFF and isDebugEnabled() is false, and the two lines still print.", 0)]
for t, want in CASES:
    got = verdicts(re.sub(r"`[^`]*`", "`…`", t), t)
    assert bool(got) == bool(want), (t, got)
for t, want in PCASES:
    assert bool(para_verdicts(t)) == bool(want), t
n = 0
bounds = 0
def judge(p, start, para):
    global n, bounds
    text = " ".join(x.strip() for x in para)
    for v in para_verdicts(text):
        n += 1; print("  %s line %d: %s" % (p, start, v))
    for s in re.split(r"(?<=[.;!?])\s+", text):
        if BOUND.search(s): bounds += 1
        for v in verdicts(re.sub(r"`[^`]*`", "`…`", s), s):
            n += 1; print("  %s line %d: %s" % (p, start, v))
for p in sys.argv[2:]:
    fence = False; vals = False; para = []; start = 0
    for i, l in enumerate(open(p, encoding="utf-8"), 1):
        mk = l.strip() in ("<!-- values: begin -->", "<!-- slow-table: begin -->", "<!-- values: end -->", "<!-- slow-table: end -->")
        brk = l.startswith("```") or mk or not l.strip() or l.startswith(("#", "- ", "| "))
        if brk or fence or vals:
            if para: judge(p, start, para); para = []
        if l.startswith("```"): fence = not fence; continue
        if l.strip() in ("<!-- values: begin -->", "<!-- slow-table: begin -->"): vals = True; continue
        if l.strip() in ("<!-- values: end -->", "<!-- slow-table: end -->"): vals = False; continue
        if fence or vals or not l.strip(): continue
        if not para: start = i
        para.append(l)
    if para: judge(p, start, para)
if bounds != 1:
    n += 1; print("  the developer boundary: %d sentences name database administration - named once (the brief)" % bounds)
print("self-test: %d cases · refused: %d" % (len(CASES) + len(PCASES), n))
