"""Unit 30's prose gate, per sentence (python3 -I -B harness/s30.py harness/dur7.py FILE...), with a self-test that must pass first.
Carried from unit 29's s29: dur7's words (R.172), S4.7's duration meanings (R.264), R.301's time-meaning family (BLUE's tm.py: a
cost word only in a sentence that names a printed count), the words for pace, R.287 (Hibernate 5/6's wordings), R.190 (the eighteen
tests as a witness). Unit 30's own refused readings: S5.1 (R.284) - the count of queries said as a statement count; S5.2 (R.285) - a
page's count with no scope (the read's session, or the whole request); R.249 - one plus one per customer beside one N only; R.224 -
DataLoader without its title. The typed 41 and 44 (R.302) are receipts.sh's grep, not this file's."""
import importlib.util, re, sys
spec = importlib.util.spec_from_file_location("dur7", sys.argv[1]); m = importlib.util.module_from_spec(spec); spec.loader.exec_module(m)
FAM = re.compile(r"\b(?:forever|for ever|at once|immediately|instantly|instant(?:ly)?|right away|in no time|a moment|momentar(?:y|ily)|"
                 r"(?:one|two|three|four|five|six|seven|eight|nine|ten|\d+)\s+(?:second|minute|hour)s?|half a second|eventually|"
                 r"a\s+(?:second|minute|hour)\b(?!\s+(?:connection|copy|run|JVM|database|read|request|time|dispatch|point)))\b", re.I)
NUM = r"(?:\d+|one|two|three|four|five|six|seven|eight|nine|ten|eleven|twelve|thirteen|fourteen|fifteen|twenty|thirty|fifty|a hundred|[NT])"
COST = re.compile(r"\b(?:costs?|costly|costing)\b", re.I)
TM = re.compile(r"\b(?:costs?|costly|costing|cheaper|cheap|expensive|saves? time|sav(?:es|ing) time|takes? longer|time-?consuming|round[- ]trips?)\b"
                rf"|\b{NUM}\s+times\b", re.I)
COUNT = re.compile(r"\b(?:statements?|SQL lines?|connections?|sessions?|rows?|batch(?:es)?|executeBatch|prepareStatement)\b", re.I)
SPEED = re.compile(r"\b(?:slow(?:er|ly)?|quick(?:er|ly)?|lag)\b", re.I)
OLD = re.compile(r"failed to lazily initialize|could not initialize proxy - no Session")
T18 = re.compile(r"\b18(?:/18| tests)\b[^.;]*\b(?:prove|proves|show(?:s)? (?:that )?the (?:fix|page)|witness(?:es)?|caught|catch)\b", re.I)
GUARD = re.compile(r"guard|did not notice|not a witness|never a witness", re.I)
# S5.1: getQueryExecutionCount (or "the count of queries") said to count the statements, or its figure said as statements
QE = re.compile(r"(?:getQueryExecutionCount\(?\)?|queryExecutionCount|the count of queries|the query count)", re.I)
QEBAD = re.compile(r"(?:getQueryExecutionCount\(?\)?|queryExecutionCount|the count of queries|the query count)[^.;]*?\b(?:counts?|is|gives|prints|says|reads)\b[^.;]*?\b(?:every|each|the|all)?\s*(?:statements?|N ?\+ ?1|SQL)\b"
                   r"|(?:getQueryExecutionCount\(?\)?|queryExecutionCount)\s*(?:=|:)?\s*\d+\s+(?:statements|queries)", re.I)
QEOK = re.compile(r"\b(?:never|not|leaves out|misses|does not|cannot|1 at every|1 at both|the same at)\b", re.I)
# S5.2: a page's count with a number and no scope word
PAGE = re.compile(r"\b(?:the dashboard|the page|a page|this page)\b[^.;]*?\b(?:runs?|sends?|makes?|prints?|is|costs?)\s+(?:\d+|forty[- ]\w+)\s+(?:queries|statements|SQL lines|selects)\b", re.I)
SCOPE = re.compile(r"\b(?:session|sessions|request|the read's|between (?:its|the) markers|whole request)\b", re.I)
# R.249: "one plus one per customer" with exactly one count of customers beside it
TREND = re.compile(r"\b(?:1 ?\+ ?N|one plus one (?:per|for each)|one more (?:statement |query |select )?(?:per|for each) (?:customer|row|pause)|grows? with)\b", re.I)
NCUST = re.compile(r"\b(?:\d+|ten|forty) (?:customers|diners|pauses)\b", re.I)
DL = re.compile(r"\bDataLoader\b")
TITLE = "The N+1 Problem and DataLoader"


def verdicts(s):
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
    return out


CASES = [("getQueryExecutionCount() counts every statement.", 1), ("queryExecutionCount 1 statements", 1),
         ("the count of queries is the statement count", 1), ("getQueryExecutionCount() says 1 at both N, the statement count moves.", 0),
         ("Hibernate's statistics count every statement it prepares; the count of queries leaves out the collection loads.", 0),
         ("the dashboard runs 41 queries.", 1), ("the page sends 44 statements", 1),
         ("the dashboard runs 44 SQL lines in the whole request.", 0), ("the page's read prints 41 statements in its session.", 0),
         ("one plus one per customer at 40 customers.", 1), ("one plus one per customer: 11 at 10 customers and 41 at 40 customers.", 0),
         ("One query for the list and one more for each row is the N plus one, whatever sends the extra queries.", 0),
         ("Course 17 has a DataLoader lesson.", 1), ("Course 17's The N+1 Problem and DataLoader names it.", 0),
         ("ten times slower", 1), ("the page is slow", 1), ("one more statement per customer costs a session nothing", 0),
         ("that costs a lot", 1), ("N times the work", 1), ("forever", 1), ("for the whole request", 0), ("at once", 1),
         ("the second connection", 0), ("wait a second", 1), ("failed to lazily initialize a collection", 1),
         ("18/18 proves the fix.", 1), ("18/18 on the anchor: a guard.", 0)]
for t, want in CASES:
    assert bool(verdicts(t)) == bool(want), (t, verdicts(t))
n = 0
for p in sys.argv[2:]:
    for i, l in enumerate(open(p, encoding="utf-8"), 1):
        for s in re.split(r"(?<=[.;!?])\s+", l):
            for v in verdicts(s):
                n += 1; print("  %s line %d: %s" % (p, i, v))
print("self-test: %d cases · refused: %d" % (len(CASES), n))
