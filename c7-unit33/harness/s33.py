"""Unit 33's prose gate, per sentence (python3 -I -B harness/s33.py harness/dur7.py FILE...), with a self-test that must pass first.
Carried from unit 32's s32: dur7's words (R.172), S4.7's duration meanings (R.264), the words for pace, R.287 (Hibernate 5/6's
wordings), R.190 (the eighteen tests as a witness), R.224 (a call-back by its title). Unit 33's own: the brief's dur7 line - "faster"
(and "slower") only in a sentence that carries PostgreSQL's threshold line (ratio >= T: true), "on this Mac" and "on PostgreSQL";
R.301 (S5.18) BLUE's tm.py family (cost/costs/costly, cheaper, expensive, saves time, takes longer, round trip, "N times" with digits
or number-words) only beside the threshold line or, the cost words alone, in a sentence naming a printed count; S5.9 (R.292) - a
duration word in a sentence about H2, and a verdict on a ratio ("no difference", "about the same", "within noise", "no gain") anywhere;
S5.10 (R.293) - batch_versioned_data credited as a live setting; R.206 - IDENTITY said to batch, "executeBatch > 0" for it, the SQL
log's lines or HHH100501 as a batch witness, "a batch" said of the log's lines; R.207 - a spoken median; R.302 - a ratio typed (a
number with two decimals), a jar count; the flush order said in call order (insert, update, delete words out of that order in one
sentence). Lines inside a fenced block, the values block and the time table are the runs' own text (receipts.sh checks them) and are
not judged here; nor is a `code span` (a quoted token: a plant's text, a log line, a key) - the receipt's greps still read them; the
threshold line counts as present when the raw sentence carries it, in a code span or not."""
import importlib.util, os, re, sys
spec = importlib.util.spec_from_file_location("dur7", sys.argv[1]); m = importlib.util.module_from_spec(spec); spec.loader.exec_module(m)
FAM = re.compile(r"\b(?:forever|for ever|at once|immediately|instantly|instant(?:ly)?|right away|in no time|a moment|momentar(?:y|ily)|"
                 r"(?:one|two|three|four|five|six|seven|eight|nine|ten|\d+)\s+(?:second|minute|hour)s?|half a second|eventually|"
                 r"a\s+(?:second|minute|hour)\b(?!-level|\s+`|\s+(?:connection|copy|run|JVM|database|read|request|time|dispatch|point|seed|collection|transaction|process|reading|class|set|key|phase|harness|look)))\b", re.I)
# BLUE's tm.py (#1506), its regexes as BLUE tested them on 24 cases
NUM = r"(?:\d+|one|two|three|four|five|six|seven|eight|nine|ten|eleven|twelve|thirteen|fourteen|fifteen|twenty|thirty|fifty|a hundred|[NT])"
COST = re.compile(r"\b(?:costs?|costly|costing)\b", re.I)
TM = re.compile(r"\b(?:costs?|costly|costing|cheaper|cheap|expensive|saves? time|sav(?:es|ing) time|takes? longer|time-?consuming|round[- ]trips?)\b"
                rf"|\b{NUM}\s+times\b", re.I)
COUNT = re.compile(r"\b(?:statements?|SQL lines?|connections?|sessions?|rows?|batch(?:es)?|executeBatch|prepareStatement)\b", re.I)
GATE = re.compile(r"ratio >= (?:T|\d+): true")
MAC = re.compile(r"\bon this Mac\b", re.I)
PGS = re.compile(r"\bon PostgreSQL\b", re.I)
GATED = re.compile(r"\b(?:faster|slower)\b", re.I)
SPEED = re.compile(r"\b(?:slow(?:er|ly)?|quick(?:er|ly)?|lag|faster|fast)\b", re.I)
OLD = re.compile(r"failed to lazily initialize|could not initialize proxy - no Session")
T18 = re.compile(r"\b18(?:/18| tests)\b[^.;]*\b(?:prove|proves|show(?:s)? (?:that )?the (?:fix|page|batch|copy)|witness(?:es)?|caught|catch)\b", re.I)
GUARD = re.compile(r"guard|did not notice|not a witness|never a witness", re.I)
# S5.9: H2 is never characterised; a verdict on a ratio is a duration meaning
H2 = re.compile(r"\bH2\b")
VERDICT = re.compile(r"\bno (?:real )?(?:difference|gain|benefit|speed-?up)\b|\babout the same\b|\bwithin (?:the )?noise\b|\bthe same speed\b|\bmakes? no difference\b|\bas fast as\b|\bbarely\b|\bflat line\b", re.I)
DURW = re.compile(r"\b(?:faster|slower|quick\w*|slow\w*|speed\w*|time[sd]?|timing|duration|cost\w*|cheaper|expensive|takes? longer|ratio is|wins?|gains?)\b", re.I)
# S5.10: the knob the jar does not hold
BVD = re.compile(r"batch_versioned_data", re.I)
BVDOK = re.compile(r"\babsent\b|\bgone\b|does not exist|doesn't exist|\bnot in\b|\b0 files\b|\bno file\b|older Hibernate|\bremoved\b|changes nothing|\bnamed as\b|\bno longer\b|grep -a", re.I)
# R.206: IDENTITY never batches; the SQL log and HHH100501 are never batch witnesses
IDENT = re.compile(r"\bIDENTITY\b|\bidentity columns?\b", re.I)
BATCHES = re.compile(r"\bbatch(?:es|ed)\b|\bjoins? a batch\b|\bin (?:a|one) batch\b|\bexecuteBatch (?:>|is above|above) 0\b", re.I)
NEG = re.compile(r"\bnever\b|\bnot\b|\bno\b|\bcannot\b|can't|n't\b|\bnone\b|\b0\b|\bzero\b|\bwithout\b|\bof one\b|\bof its own\b|\bsingle\b|\bbut\b|\bonly when\b|\bif it knows\b|\bknows? the ids?\b", re.I)
GT0 = re.compile(r"executeBatch\s*>\s*0")
LOGW = re.compile(r"\bSQL log(?:'s)?(?: lines)?\b|\blog(?:'s)? lines\b|\bHHH100501\b", re.I)
LOGB = re.compile(r"\bbatch(?:es|ed)?\b", re.I)
LOGOK = re.compile(r"not a (?:batch )?witness|never a (?:batch(?:ing)? )?witness|\bnever\b|\bnot\b|\bbeside\b|still prints|still reads", re.I)
# R.207: a spoken median
MEDIAN = re.compile(r"\bmedians?\b[^.;]*\b(?:\d+|one|two|three|four|five|six|seven|eight|nine|ten|eleven|twelve|thirteen|fourteen|fifteen|twenty|thirty|forty|fifty|hundred)\b(?! (?:JVMs?|rounds?|runs?|persists?|timed|warm-up))", re.I)
# R.302: a ratio typed, a jar count
RATIO = re.compile(r"(?<![\w.])\d+\.\d\d\b|\bratio (?:of|is|was|=) \d", re.I)
JARS = re.compile(r"\b(?:\d+|one|two|three|four|five|six|seven|eight|nine|ten|eleven|twelve|fourteen)\s+(?:added\s+)?(?:jars?|libraries)\b|\b\d{1,3}(?:,\d{3})+ (?:B|bytes)\b|\b\d+(?:\.\d+)? ?(?:MB|KB|kB|MiB|KiB)\b", re.I)
# the flush order: in one sentence, the SQL verbs in the order Hibernate flushes them - insert, update, delete
VERB = re.compile(r"\b(insert|update|delete)(?:s|d)?\b", re.I)
RANK = {"insert": 0, "update": 1, "delete": 2}
# R.224: a call-back by its title
TITLES = ["Transactions and Batches: All or Nothing", "Chunk-Oriented Processing", "Writers and the Flush", "Ids and Generation Strategies",
          "Propagation, All Seven", "Rollback Rules", "Optimistic Locking with At-Version", "Optimistic Locking with @Version", "Paging and Sorting",
          "@Transactional: What the Proxy Does", "Lazy Loading and LazyInitializationException", "N+1, Measured", "JOIN FETCH vs @EntityGraph vs @BatchSize",
          "The Second-Level Cache", "Batching and the Write Path", "Your First Entity and EntityManager", "The Persistence Context"]
PINNED = open(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "pinned.txt"), encoding="utf-8").read().strip()
CALLED = re.compile(r"\b(?:the )?lessons? called\b|\bCourse (?:2|14)\b", re.I)


def verdicts(s, raw=None):
    out = []
    raw = s if raw is None else raw
    gate = bool(GATE.search(raw)) and bool(MAC.search(raw)) and bool(PGS.search(raw))
    for w in m.DUR.finditer(s):
        if not (gate and GATED.fullmatch(w.group(0))): out.append("dur7: " + w.group(0))
    for w in FAM.finditer(s): out.append("S4.7's family: " + w.group(0))
    hits = [w.group(0) for w in TM.finditer(s)]
    if hits and not GATE.search(raw) and not (all(COST.fullmatch(h) for h in hits) and COUNT.search(s)): out.append("R.301's family: " + ", ".join(hits))
    for w in SPEED.finditer(s):
        if not (gate and GATED.fullmatch(w.group(0))) and not m.DUR.search(w.group(0)): out.append("a speed word: " + w.group(0))
    for w in OLD.finditer(s): out.append("R.287: Hibernate 5/6's wording: " + w.group(0))
    if T18.search(s) and not GUARD.search(s): out.append("R.190: the 18 tests as a witness")
    if H2.search(s) and DURW.search(s) and not re.search(r"no threshold|never characteri[sz]ed|numbers? on (?:the|a) chip|as numbers", s, re.I): out.append("S5.9: a duration word in a sentence about H2: " + DURW.search(s).group(0))
    if VERDICT.search(s): out.append("S5.9: a verdict on a ratio: " + VERDICT.search(s).group(0))
    if BVD.search(s) and not BVDOK.search(s): out.append("S5.10: batch_versioned_data credited as a live setting")
    if GT0.search(s): out.append("R.206: executeBatch > 0")
    if IDENT.search(s) and BATCHES.search(s) and not NEG.search(s): out.append("R.206: IDENTITY said to batch: " + BATCHES.search(s).group(0))
    if LOGW.search(raw) and LOGB.search(s) and not LOGOK.search(s): out.append("R.206: the SQL log or HHH100501 as a batch witness")
    if MEDIAN.search(s): out.append("R.207: a spoken median: " + MEDIAN.search(s).group(0))
    if RATIO.search(s): out.append("R.302: a ratio typed: " + RATIO.search(s).group(0))
    if JARS.search(s): out.append("R.302: a jar or byte count typed: " + JARS.search(s).group(0))
    vs = [RANK[v.group(1).lower()] for v in VERB.finditer(s)]
    if len(set(vs)) > 1 and vs != sorted(vs): out.append("the flush order: SQL verbs out of Hibernate's order (insert, update, delete)")
    if CALLED.search(s) and not any(t in raw for t in TITLES): out.append("R.224: a call-back without its title")
    return out


CASES = [("ten times", 1), ("the batch is ten times quicker on PostgreSQL", 1), ("And on Postgres the trip is what costs.", 1), ("Batching saves time on PostgreSQL only", 1),
         ("at least five times", 1), ("13 times", 1), ("it is three times cheaper on H2", 1), ("round trip", 1),
         ("On this Mac, on PostgreSQL, batch 50 is faster than batch 1 in every JVM: ratio >= T: true.", 0),
         ("On PostgreSQL batch 50 is faster than batch 1.", 1), ("On this Mac batch 50 is faster: ratio >= T: true.", 1),
         ("And on Postgres each statement is a trip to the server - the batch makes fewer trips.", 0),
         ("Hibernate can send many INSERTs in one trip to the database.", 0), ("IDENTITY costs every insert its own statement: 200 statements.", 0),
         ("forever", 1), ("at once", 1), ("a second connection reads the table", 0), ("failed to lazily initialize a collection", 1),
         ("18/18 proves the copy works.", 1), ("18/18 on the copy: a guard.", 0),
         ("On H2 the batch makes no difference.", 1), ("H2's ratio is about the same.", 1), ("On H2 the batch is slower.", 1),
         ("H2's ratios are printed as numbers on the chip, never characterised.", 0), ("The ratio straddles noise; no difference.", 1),
         ("Set hibernate.jdbc.batch_versioned_data=true to batch versioned updates.", 1), ("hibernate.jdbc.batch_versioned_data turns on versioned batching.", 1),
         ("batch_versioned_data is absent from 7.4.13: 0 files of the jar hold it.", 0),
         ("executeBatch > 0 for IDENTITY.", 1), ("IDENTITY inserts are batched with the key.", 1), ("An identity column never joins a batch.", 0),
         ("TiffinBox's identity columns keep every insert in a batch of its own.", 0),
         ("The SQL log shows the batch.", 1), ("The SQL log's lines still read 205 beside the 6 statements - never a batch witness.", 0),
         ("HHH100501 proves the inserts batched.", 1),
         ("The median was about fourteen milliseconds.", 1), ("The median on PostgreSQL is fourteen.", 1), ("The medians of 9 timed rounds per JVM are masked.", 0),
         ("The PostgreSQL ratio is 10.68.", 1), ("Each JVM prints its two ratios; the receipt masks them.", 0),
         ("Caffeine adds 11 jars.", 1),
         ("At the commit Hibernate sends the deletes first, then the update, then the inserts.", 1),
         ("Called remove, remove, edit, persist, persist, Hibernate flushed the inserts, then the update, then the deletes.", 0),
         ("as the lesson called Locking said", 1), ("the same hash as in the lesson called Optimistic Locking with At-Version.", 0),
         ("Course 2 called it executeBatch.", 1), ("Course 2's lesson called Transactions and Batches: All or Nothing called executeBatch itself.", 0),
         ("Course 14 comes back to it.", 1), ("Course 14's lesson called Chunk-Oriented Processing comes back to it.", 0), (PINNED, 0)]
for t, want in CASES:
    got = verdicts(re.sub(r"`[^`]*`", "`…`", t), t)
    assert bool(got) == bool(want), (t, got)
n = 0
def judge(p, start, para):
    global n
    text = " ".join(x.strip() for x in para)
    for s in re.split(r"(?<=[.;!?])\s+", text):
        for v in verdicts(re.sub(r"`[^`]*`", "`…`", s), s):
            n += 1; print("  %s line %d: %s" % (p, start, v))
for p in sys.argv[2:]:
    fence = False; vals = False; para = []; start = 0
    for i, l in enumerate(open(p, encoding="utf-8"), 1):
        brk = l.startswith("```") or l.strip() in ("<!-- values: begin -->", "<!-- time-table: begin -->", "<!-- values: end -->", "<!-- time-table: end -->") or not l.strip() or l.startswith(("#", "- ", "| "))
        if brk or fence or vals:
            if para: judge(p, start, para); para = []
        if l.startswith("```"): fence = not fence; continue
        if l.strip() in ("<!-- values: begin -->", "<!-- time-table: begin -->"): vals = True; continue
        if l.strip() in ("<!-- values: end -->", "<!-- time-table: end -->"): vals = False; continue
        if fence or vals or not l.strip(): continue
        if not para: start = i
        para.append(l)
    if para: judge(p, start, para)
print("self-test: %d cases · refused: %d" % (len(CASES), n))
