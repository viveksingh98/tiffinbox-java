"""Unit 01's prose gate, per sentence (python3 -I -B harness/s801.py harness/dur8.py FILE...), with a self-test that must pass first.
Carried from unit 02's s802.py (dur8's words, S4.7's duration family, R.355's cost words without a count, a SQL sentence without its
database, a call-back without its title, "Hibernate generates" never, a typed md5), with unit 01's own rules: R.355 "no persistence
context" said without a count beside it; R.361 a heap or bytes figure; R.367 a pair across operations ("43 against 1", "41 against 4"
- the pairs are the read with the read and the page with the page); R.368 single-query loading claimed (U03's and U06's); R.302 the
capture's numbers typed in prose (78, 41, 43, 118, 38, 77, 240300, and 40 / 4 beside a counted noun) - they live in the runs' printed
blocks and the values block only; 4.2.0 said more than once, or undated. Lines inside a fenced block and the values block are the
runs' own text (receipts.sh checks them) and are not judged here; nor is a `code span`."""
import importlib.util, re, sys
spec = importlib.util.spec_from_file_location("dur8", sys.argv[1]); m = importlib.util.module_from_spec(spec); spec.loader.exec_module(m)
FAM = re.compile(r"\b(?:forever|at once|immediately|instantly|instant|right away|in no time|a moment|momentarily|eventually|"
                 r"(?:one|two|three|four|five|ten|\d+)\s+(?:second|minute|hour)s?|half a second)\b", re.I)
SPEED = re.compile(r"\b(?:slow(?:er|ly)?|quick(?:er|ly)?|faster|fast)\b", re.I)
COST = re.compile(r"\b(?:lighter|heavier|simpler|leaner|cheaper|costlier|expensive|overhead|efficient|bloat\w*)\b", re.I)
NOPC = re.compile(r"\bno persistence context\b|\bkeeps none\b|\bwithout a persistence context\b", re.I)
COUNTED = re.compile(r"\bstatements?\b|\bSELECTs?\b|\bwindow\b|values block|the capture", re.I)
HEAP = re.compile(r"\b\d[\d,]*\s?(?:B|KiB|MiB|KB|MB|bytes)\b|\bheap (?:bytes|size) (?:is|of|are)\b", re.I)
HEAPOK = re.compile(r"\brefused\b|\bnot a slide fact\b|\bnever\b|\bnot reproduced\b|R\.361", re.I)
CROSS = re.compile(r"\b43\b[^.;]*\b(?:against|versus|vs\.?|beside)\b[^.;]*\b1\b|\b41\b[^.;]*\b(?:against|versus|vs\.?|beside)\b[^.;]*\b4\b", re.I)
SQL1 = re.compile(r"single[- ]query loading", re.I)
SQL1OK = re.compile(r"Relationships Without an ORM|JPA vs JDBC vs Plain SQL|\bnot\b|\bnever\b|\bno\b|named|unmeasured|U03|U06|later|its default", re.I)
SQLW = re.compile(r"\b(?:the SQL|its SQL|SQL lines?|the SQL texts?)\b[^.;]*\b(?:reads?|quoted|unquoted|upper-?case|lower-?case|shows?|prints?)\b", re.I)
DB = re.compile(r"\bH2\b|\bPostgreSQL\b|both databases|each database|on both", re.I)
TYPED = re.compile(r"(?<![\w.#-])(?:78|41|43|118|38|77|240300|240,300)(?![\w-]|\.\d)|(?<![\w.#-])(?:40|4)\s+(?:statements?|customers|collections|SELECTs?|aggregates|entities|pauses)\b", re.I)
HASH = re.compile(r"\b[0-9a-f]{32}\b", re.I)
GEN = re.compile(r"\bHibernate generates\b", re.I)
V42 = re.compile(r"\b4\.2\.0\b")
V42OK = re.compile(r"4\.2\.0 was a release candidate on 17 November 2026")
TITLES = ["The Persistence Context", "Batching and the Write Path", "What's Next: Not Everything Is a Relation", "Aggregates, Not Entities",
          "Relationships Without an ORM", "JPA vs JDBC vs Plain SQL", "Why Another Data Module", "Testing the JDBC Layer"]
CALLED = re.compile(r"\b(?:the )?lessons? called\b|\bCourse (?:2|4|5|6|7)\b(?!'s (?:final anchor|capstone|builders|scripts|harness|units|worked|form|tree35))|\bas Course 7\b", re.I)
CALLOK = re.compile(r"Course 7's (?:harness|tree35|units|worked|form|precedent|builders|scripts|capstone|final)|c7-unit\d+|`c7-unit", re.I)


def verdicts(s, raw=None):
    out = []
    raw = s if raw is None else raw
    for w in m.DUR.finditer(s): out.append("dur8: " + w.group(0))
    for w in FAM.finditer(s): out.append("S4.7's family: " + w.group(0))
    for w in SPEED.finditer(s):
        if not m.DUR.search(w.group(0)): out.append("a speed word: " + w.group(0))
    if COST.search(s) and not COUNTED.search(raw): out.append("R.355: a cost word without its count: " + COST.search(s).group(0))
    if NOPC.search(s) and not COUNTED.search(raw): out.append("R.355: \"no persistence context\" without its statement count")
    if HEAP.search(raw) and not HEAPOK.search(raw): out.append("R.361: a heap or bytes figure: " + HEAP.search(raw).group(0))
    if CROSS.search(raw): out.append("R.367: a pair across two operations: " + CROSS.search(raw).group(0))
    if SQL1.search(s) and not SQL1OK.search(raw): out.append("R.368: single-query loading claimed in this unit")
    if SQLW.search(s) and not DB.search(raw): out.append("R.353/R.365: a SQL sentence without its database")
    if TYPED.search(s): out.append("R.302: a capture's number typed in prose: " + TYPED.search(s).group(0))
    if HASH.search(raw): out.append("R.302: a typed md5")
    if GEN.search(s): out.append("§10: \"Hibernate generates\"")
    if V42.search(s) and not V42OK.search(raw): out.append("⚑1: 4.2.0 undated")
    if CALLED.search(raw) and not any(t in raw for t in TITLES) and not CALLOK.search(raw): out.append("R.224: a call-back without its title")
    return out


CASES = [("J-D-B-C is faster.", 1), ("Spring Data JDBC is quicker.", 1), ("It starts at once.", 1), ("a second connection reads it", 0),
         ("The module is lighter.", 1), ("The module is lighter: window B's statements are counted.", 0),
         ("Spring Data JDBC has no persistence context.", 1), ("Spring Data JDBC has no persistence context, and window B prints its statements.", 0),
         ("The context costs 4,368 B.", 1), ("The heap bytes are refused (R.361).", 0), ("The persistence context takes 2880 bytes.", 1),
         ("The page is 43 against 1.", 1), ("The read is 41 against 4.", 1), ("The read with the read, the page with the page.", 0),
         ("Single-query loading makes it one statement.", 1), ("Single-query loading is not this unit's: JPA vs JDBC vs Plain SQL owns it.", 0),
         ("The SQL reads unquoted.", 1), ("The SQL reads unquoted on PostgreSQL.", 0),
         ("The context holds 78 entities.", 1), ("Window B prints 41.", 1), ("The dashboard loads 118.", 1), ("It reads 40 customers.", 1),
         ("The numbers are in the values block.", 0), ("Unit 40's sentence.", 0), ("Ports 20400-20409.", 0),
         ("The hash is 7ce49e3ec13c212a31ee6ba4618f53ab.", 1), ("Hibernate generates the UPDATE.", 1),
         ("4.2.0 is out.", 1), ("4.2.0 was a release candidate on 17 November 2026, and the course stays on 4.1.", 0),
         ("As Course 7 said.", 1), ("As Course 7's *The Persistence Context* said.", 0), ("The lesson called the persistence context.", 1)]
for t, want in CASES:
    got = verdicts(re.sub(r"`[^`]*`", "`…`", t), t)
    assert bool(got) == bool(want), (t, got)
n = 0
v42 = 0
def judge(p, start, para):
    global n, v42
    text = " ".join(x.strip() for x in para)
    for s in re.split(r"(?<=[.;!?])\s+", text):
        s2 = re.sub(r"`[^`]*`", "`…`", s)
        v42 += len(V42.findall(s2))
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
if v42 > 1:
    n += 1; print("  ⚑1: 4.2.0 said %d times in the prose (once, dated)" % v42)
print("self-test: %d cases · refused: %d" % (len(CASES), n))
