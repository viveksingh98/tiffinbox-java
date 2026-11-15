"""Unit 31's prose gate, per sentence (python3 -I -B harness/s31.py harness/dur7.py FILE...), with a self-test that must pass first.
Carried from unit 30's s30: dur7's words (R.172), S4.7's duration meanings (R.264), R.301's time-meaning family (BLUE's tm.py: a
cost word only in a sentence that names a printed count), the words for pace, R.287 (Hibernate 5/6's wordings), R.190 (the eighteen
tests as a witness), S5.1 (R.284), S5.2 (R.285), R.249 and R.224 (DataLoader without its title). Unit 31's own refused readings:
S5.6 (R.289) - paging said "in memory", or HHH90003004 named as printed, where the capture prints neither; S2.12 - the batch IN list
said without its database (PostgreSQL's "= any (?)" without "PostgreSQL" on the line, H2's "in (?,...)" without "H2"); the inner
join's lost customers - inner join fetch's one statement said without the two customers it drops, Meera and Ravi, beside it; R.224 -
the first "N+1" in a file without unit 30's title, N+1, Measured. The typed table cells and counts (S5.5, R.302) are receipts.sh's."""
import importlib.util, re, sys
spec = importlib.util.spec_from_file_location("dur7", sys.argv[1]); m = importlib.util.module_from_spec(spec); spec.loader.exec_module(m)
FAM = re.compile(r"\b(?:forever|for ever|at once|immediately|instantly|instant(?:ly)?|right away|in no time|a moment|momentar(?:y|ily)|"
                 r"(?:one|two|three|four|five|six|seven|eight|nine|ten|\d+)\s+(?:second|minute|hour)s?|half a second|eventually|"
                 r"a\s+(?:second|minute|hour)\b(?!\s+(?:connection|copy|run|JVM|database|read|request|time|dispatch|point|seed|collection)))\b", re.I)
NUM = r"(?:\d+|one|two|three|four|five|six|seven|eight|nine|ten|eleven|twelve|thirteen|fourteen|fifteen|twenty|thirty|fifty|a hundred|[NT])"
COST = re.compile(r"\b(?:costs?|costly|costing)\b", re.I)
TM = re.compile(r"\b(?:costs?|costly|costing|cheaper|cheap|expensive|saves? time|sav(?:es|ing) time|takes? longer|time-?consuming|round[- ]trips?)\b"
                rf"|\b{NUM}\s+times\b", re.I)
COUNT = re.compile(r"\b(?:statements?|SQL lines?|connections?|sessions?|rows?|batch(?:es)?|executeBatch|prepareStatement)\b", re.I)
SPEED = re.compile(r"\b(?:slow(?:er|ly)?|quick(?:er|ly)?|lag|faster|fast)\b", re.I)
OLD = re.compile(r"failed to lazily initialize|could not initialize proxy - no Session")
T18 = re.compile(r"\b18(?:/18| tests)\b[^.;]*\b(?:prove|proves|show(?:s)? (?:that )?the (?:fix|page)|witness(?:es)?|caught|catch)\b", re.I)
GUARD = re.compile(r"guard|did not notice|not a witness|never a witness", re.I)
QEBAD = re.compile(r"(?:getQueryExecutionCount\(?\)?|queryExecutionCount|the count of queries|the query count)[^.;]*?\b(?:counts?|is|gives|prints|says|reads)\b[^.;]*?\b(?:every|each|the|all)?\s*(?:statements?|N ?\+ ?1|SQL)\b"
                   r"|(?:getQueryExecutionCount\(?\)?|queryExecutionCount)\s*(?:=|:)?\s*\d+\s+(?:statements|queries)", re.I)
QEOK = re.compile(r"\b(?:never|not|leaves out|misses|does not|cannot|1 at every|1 at both|the same at)\b", re.I)
PAGE = re.compile(r"\b(?:the dashboard|the page|a page|this page)\b[^.;]*?\b(?:runs?|sends?|makes?|prints?|is|costs?)\s+(?:\d+|forty[- ]\w+|four|one)\s+(?:queries|statements|SQL lines|selects)\b", re.I)
SCOPE = re.compile(r"\b(?:session|sessions|request|the read's|between (?:its|the) markers|whole request|fourth read)\b", re.I)
TREND = re.compile(r"\b(?:1 ?\+ ?N|one plus one (?:per|for each)|one more (?:statement |query |select )?(?:per|for each) (?:customer|row|pause)|grows? with)\b", re.I)
NCUST = re.compile(r"\b(?:\d+|ten|forty) (?:customers|diners|pauses)\b", re.I)
DL = re.compile(r"\bDataLoader\b")
TITLE = "The N+1 Problem and DataLoader"
# S5.6: paging in memory, or the warning named as printed
MEM = re.compile(r"(?:\bpag(?:e|es|ed|ing)\b|setMaxResults|PageRequest)[^.;]*\bin memory\b|\bin memory\b[^.;]*(?:\bpag(?:e|es|ed|ing)\b|setMaxResults)", re.I)
MEMOK = re.compile(r"\b(?:not|never|no)\b[^.;]*\bin memory\b|\bin memory\b[^.;]*\b(?:not|never)\b", re.I)
HHH = re.compile(r"HHH90003004")
HHHOK = re.compile(r"HHH90003004[^.;]*(?:\b0\b|\bnone\b|\bnever\b|\bno\b|\bnot\b)|(?:\b0\b|\bno\b|\bnot\b|\bnever\b)[^.;]*HHH90003004")
# S2.12: the batch IN list beside its database
ANY = re.compile(r"= any \(\?\)|= any\b")
INL = re.compile(r"\bin \(\?")
# the inner join's lost customers
INNER = re.compile(r"\binner\b[^.;]*\bjoin fetch\b|\binner join\b", re.I)
ONEST = re.compile(r"\b(?:one statement|1 statement|prints? 1|prints? one)\b", re.I)


def verdicts(s, state):
    out = []
    for w in m.DUR.finditer(s): out.append("dur7: " + w.group(0))
    for w in FAM.finditer(s): out.append("S4.7's family: " + w.group(0))
    hits = [w.group(0) for w in TM.finditer(s)]
    if hits and not (all(COST.fullmatch(h) for h in hits) and COUNT.search(s)): out.append("R.301's family: " + ", ".join(hits))
    for w in SPEED.finditer(s): out.append("a speed word: " + w.group(0))
    for w in OLD.finditer(s): out.append("R.287: Hibernate 5/6's wording: " + w.group(0))
    if T18.search(s) and not GUARD.search(s): out.append("R.190: the 18 tests as a witness")
    if QEBAD.search(s) and not QEOK.search(s): out.append("S5.1: the count of queries said as a statement count: " + QEBAD.search(s).group(0))
    if PAGE.search(s) and not SCOPE.search(s): out.append("S5.2: a page's count with no scope (session or request): " + PAGE.search(s).group(0))
    if TREND.search(s) and len(NCUST.findall(s)) == 1: out.append("R.249: a trend beside one N: " + TREND.search(s).group(0))
    if DL.search(s) and TITLE not in s: out.append("R.224: DataLoader without its title")
    if MEM.search(s) and not MEMOK.search(s): out.append("S5.6: paging said in memory: " + MEM.search(s).group(0))
    if HHH.search(s) and not HHHOK.search(s): out.append("S5.6: HHH90003004 named as printed")
    if ANY.search(s) and "PostgreSQL" not in s: out.append("S2.12: = any (?) without its database, PostgreSQL")
    if ANY.search(s) and "H2" in s and "PostgreSQL" not in s: out.append("S2.12: = any (?) said for H2")
    if INL.search(s) and "H2" not in s: out.append("S2.12: an in (?,...) list without its database, H2")
    if INNER.search(s) and ONEST.search(s) and not ("Meera" in s and "Ravi" in s): out.append("the inner join's one statement without the two customers it drops")
    if "N+1" in s and not state.get("n1"):
        state["n1"] = True
        if "N+1, Measured" not in s and TITLE not in s: out.append("R.224: the first N+1 without unit 30's title, N+1, Measured")
    return out


CASES = [("getQueryExecutionCount() counts every statement.", 1), ("getQueryExecutionCount() says 1 at both N, the statement count moves.", 0),
         ("the dashboard runs 44 queries.", 1), ("the dashboard runs 44 SQL lines in the whole request.", 0),
         ("one plus one per customer at 40 customers.", 1), ("one plus one per customer: 11 at 10 customers and 41 at 40 customers.", 0),
         ("Course 17 has a DataLoader lesson.", 1), ("Course 17's The N+1 Problem and DataLoader names it.", 0),
         ("ten times slower", 1), ("the page is faster now", 1), ("one more statement per customer costs a session nothing", 0),
         ("that costs a lot", 1), ("forever", 1), ("for the whole request", 0), ("at once", 1), ("the second connection", 0),
         ("failed to lazily initialize a collection", 1), ("18/18 proves the fix.", 1), ("18/18 on the anchor: a guard.", 0),
         ("Hibernate applies the page in memory.", 1), ("the page is cut in the database, not in memory", 0),
         ("Hibernate warns HHH90003004 and pages the rows.", 1), ("HHH90003004 lines (grep -c): 0 on both databases.", 0),
         ("H2 asks = any (?) with an array.", 1), ("PostgreSQL asks = any (?), one array parameter.", 0),
         ("the batch asks in (?,?,?) for sixteen ids.", 1), ("on H2 the batch asks in (?,?,?) for sixteen ids.", 0),
         ("the inner join fetch prints one statement too.", 1), ("the inner join fetch prints one statement too, and Meera and Ravi are gone.", 0),
         ("the N+1 is gone.", 1), ("N+1, Measured counted the N+1.", 0),
         ("H2 in this JVM's memory holds the tables.", 0), ("the page of ten, the derived table in the database.", 0),
         ("the same statement, in a second seed.", 0)]
for t, want in CASES:
    got = verdicts(t, {})
    assert bool(got) == bool(want), (t, got)
n = 0
for p in sys.argv[2:]:
    st = {}
    for i, l in enumerate(open(p, encoding="utf-8"), 1):
        for s in re.split(r"(?<=[.;!?])\s+", l):
            for v in verdicts(s, st):
                n += 1; print("  %s line %d: %s" % (p, i, v))
print("self-test: %d cases · refused: %d" % (len(CASES), n))
