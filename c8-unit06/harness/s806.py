"""Unit 06's prose gate, per sentence (python3 -I -B harness/s806.py harness/dur8.py FILE...), with a self-test that must pass first.
Carried from unit 05's s805.py (dur8's words, S4.7's duration family, a pair of counts from two windows (R.367), "N times" (R.309), a
SQL sentence without its database, a call-back without its title, "Hibernate generates" never, a typed md5), with unit 06's own
rules: no time is measured anywhere in this unit (contract 4.3: lines and query count, never a speed), so the speed and cost words
are refused in every sentence, a count beside them or not (R.355, R.261); getQueryExecutionCount() said as the JPA side's count
(C8-9, R.320: the prepare count only); "all three" sides using Sort.by (RED #5: the plain SQL writes order by); a hand-written table
row (R.338: every cell is a `cell` line the run printed, in a text block); a single-query-loading sentence without its method AND its
database, or "single-query loading changes nothing" (R.368, S8.26); the JPA side's SQL order compared (S8.16); R.302 the captures'
numbers typed in prose (43, 82, 80, 78, 240300, 77, 40, 38, 41, any count beside a counted noun, any line count). Lines inside a
fenced block and the values block are the runs' own text (receipts.sh checks them) and are not judged here; a `code span` is masked
for every rule but the counter, Sort.by, single-query and order rules, which read the raw sentence."""
import importlib.util, re, sys
spec = importlib.util.spec_from_file_location("dur8", sys.argv[1]); m = importlib.util.module_from_spec(spec); spec.loader.exec_module(m)
FAM = re.compile(r"\b(?:forever|at once|immediately|instantly|instant|right away|in no time|a moment|momentarily|eventually|"
                 r"(?:one|two|three|four|five|ten|\d+)\s+(?:second|minute|hour)s?|half a second)\b", re.I)
SPEED = re.compile(r"\b(?:slow(?:er|est|ly)?|quick(?:er|ly)?|fast(?:er|est)?)\b", re.I)
COST = re.compile(r"\b(?:lighter|heavier|simpler|cleaner|leaner|cheaper|costlier|expensive|overhead|efficient|inefficient|bloat\w*|better|worse|best|worst)\b", re.I)
NEG = re.compile(r"\bnever\b|\bnot\b|\brefused\b|\brefuses\b|\bno\b", re.I)
QEC = re.compile(r"getQueryExecutionCount", re.I)
SORT3 = re.compile(r"\ball three\b[^.;]*\bSort\.by\b|\bSort\.by\b[^.;]*\ball three\b|\bevery side\b[^.;]*\bSort\.by\b|\beach side\b[^.;]*\bSort\.by\b", re.I)
SQL1 = re.compile(r"\bsingle-query loading\b", re.I)
SQLM = re.compile(r"findAll\(\)|findAll\(Sort|findById|findAllById")
SQLDB = re.compile(r"\bPostgreSQL\b|\bH2\b")
NOTHING = re.compile(r"\bsingle-query loading\b[^.;]*\bchanges? nothing\b", re.I)
ORDER = re.compile(r"\b(?:SQL|statement|read|query) order\b|\border of (?:the |its )?(?:SQL|statements|reads|queries)\b|\b(?:runs?|comes?|is sent|arrives?) (?:first|second|last|before|after)\b", re.I)
ORDEROK = re.compile(r"\bvar(?:y|ies)\b|\bnot fixed\b|\bnever\b|\bnot\b|\bcounts?, never\b", re.I)
PAIR = re.compile(r"\b(?:against|versus|vs\.?)\b[^.;]*\b(?:statements?|prepares?)\b|\b(?:statements?|prepares?)\b[^.;]*\b(?:against|versus|vs\.?)\b", re.I)
PAIROK = re.compile(r"JPA vs JDBC vs Plain SQL|\bR\.367\b|\bone window\b|\bthe same window\b|\bthe page\b|\bone run\b", re.I)
TIMES = re.compile(r"\b(?:\d+|one|two|three|four|five|six|seven|eight|nine|ten|many|several|multiple)\s+times\b", re.I)
SQLW = re.compile(r"\b(?:the SQL|its SQL|SQL lines?|the SQL texts?|the ORDER BY)\b[^.;]*\b(?:reads?|quoted|unquoted|upper-?case|lower-?case|shows?|prints?)\b", re.I)
DB = re.compile(r"\bH2\b|\bPostgreSQL\b|both databases|each database|on both", re.I)
TYPED = re.compile(r"(?<![\w.#:=-])(?:43|82|80|78|240300|77|40|38|41|168|84|484|231)(?![\w:-]|\.\d)"
                   r"|(?<![\w.#:=-])\d+\s+(?:statements?|customers|pauses|SELECTs?|rows?|prepares?|records?|days|entities|collections|lines|code lines|files|cells)\b", re.I)
HASH = re.compile(r"\b[0-9a-f]{32}\b", re.I)
GEN = re.compile(r"\bHibernate generates\b", re.I)
TITLES = ["JDBC: Connect, Query, Map Rows to Records", "Aggregates, Not Entities", "Relationships Without an ORM", "JPA vs JDBC vs Plain SQL",
          "Why Another Data Module", "Testing the JDBC Layer", "JdbcClient and Custom Queries", "JdbcTemplate and NamedParameterJdbcTemplate",
          "Paging and Sorting"]
CALLED = re.compile(r"\b(?:the )?lessons? called\b|\bCourse (?:2|4|5|6|7)\b(?!'s (?:final anchor|capstone|builders|scripts|harness|units|worked|form|tree35|teaching))|\bas Course 7\b", re.I)
CALLOK = re.compile(r"Course 7's (?:harness|tree35|units|worked|form|precedent|builders|scripts|capstone|final|teaching)|c7-unit\d+|`c7-unit|`java7_series\.py`|no Course 2 code", re.I)


def verdicts(s, raw=None):
    out = []
    raw = s if raw is None else raw
    for w in m.DUR.finditer(s): out.append("dur8: " + w.group(0))
    for w in FAM.finditer(s): out.append("S4.7's family: " + w.group(0))
    for w in SPEED.finditer(s):
        if not m.DUR.search(w.group(0)): out.append("a speed word: " + w.group(0))
    for w in COST.finditer(s): out.append("R.355/R.261: a cost or quality word (no time and no adjective in unit 06): " + w.group(0))
    if QEC.search(raw) and not NEG.search(raw): out.append("C8-9/R.320: getQueryExecutionCount() as the JPA side's count - the prepare count only")
    if SORT3.search(raw) and not NEG.search(raw): out.append("RED #5: Sort.by said for all three sides - the plain SQL writes order by")
    if NOTHING.search(raw): out.append("R.368: \"single-query loading changes nothing\"")
    elif SQL1.search(raw) and not (SQLM.search(raw) and SQLDB.search(raw)): out.append("R.368/S8.26: a single-query-loading sentence without its method AND its database")
    if ORDER.search(raw) and not ORDEROK.search(raw): out.append("S8.16: the SQL order compared - counts, never order")
    if PAIR.search(s) and not PAIROK.search(raw): out.append("R.367: a pair of counts across windows")
    if TIMES.search(s): out.append("R.309: \"N times\": " + TIMES.search(s).group(0))
    if SQLW.search(s) and not DB.search(raw): out.append("R.353/R.365: a SQL sentence without its database")
    if TYPED.search(s): out.append("R.302: a capture's number typed in prose: " + TYPED.search(s).group(0))
    if HASH.search(raw): out.append("R.302: a typed md5")
    if GEN.search(s): out.append("§10: \"Hibernate generates\"")
    if CALLED.search(raw) and not any(t in raw for t in TITLES) and not CALLOK.search(raw): out.append("R.224: a call-back without its title")
    return out


CASES = [("J-D-B-C is faster.", 1), ("It starts at once.", 1), ("a second connection reads it", 0), ("Spring Data JDBC is slower here.", 1),
         ("JdbcClient is simpler.", 1), ("JdbcClient is simpler: the witness counts the statements.", 1), ("The JDBC side is lighter.", 1),
         ("The plain SQL is cleaner.", 1), ("JPA is heavier.", 1), ("The page is counted by the witness.", 0),
         ("On the JPA side the count is getQueryExecutionCount().", 1), ("The JPA side's count is `getQueryExecutionCount()`.", 1),
         ("The count is never `getQueryExecutionCount()`: it is the prepare count.", 0),
         ("All three sides use `Sort.by`.", 1), ("`Sort.by` reads the page on all three sides.", 1), ("The JDBC side reads with `findAll(Sort.by(\"name\"))`.", 0),
         ("Single-query loading changes nothing.", 1), ("With single-query loading the page is one statement.", 1),
         ("With single-query loading `findAll()` reads the customers in one statement on PostgreSQL.", 0),
         ("Single-query loading on H2 leaves it as it was.", 1),
         ("The JPA side's SQL order is Customer first.", 1), ("The JPA side's SQL order varies between rounds.", 0), ("The sum runs first.", 1),
         ("The custom query is one statement against the repositories' forty-one statements.", 1), ("The page is four statements against forty-three, one run.", 0),
         ("The driver received the same text four times.", 1), ("The SQL reads unquoted.", 1), ("The SQL reads unquoted on H2.", 0),
         ("The sum is 77.", 1), ("It returns 82 rows.", 1), ("The JDBC side is 43.", 1), ("The revenue is 240300.", 1), ("It holds 78.", 1),
         ("The file has 168 lines.", 1), ("CustomerRow is 53 code lines.", 1), ("Ports 20450-20459.", 0), ("The numbers are in the values block.", 0),
         ("The hash is 7ce49e3ec13c212a31ee6ba4618f53ab.", 1), ("Hibernate generates the SELECT.", 1),
         ("As Course 7 showed.", 1), ("As Course 7's Paging and Sorting showed.", 0), ("Course 7's teaching Javadoc is most of the anchor's lines.", 0),
         ("JPA is the better choice.", 1), ("Spring Data JDBC 4.1.2.", 0)]
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
        if not fence and not vals and l.startswith("| "):
            n += 1; print("  %s line %d: R.338: a hand-written table row - every cell is a `cell` line the run printed, in a text block" % (p, i))
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
