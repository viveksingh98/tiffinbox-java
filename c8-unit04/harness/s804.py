"""Unit 04's prose gate, per sentence (python3 -I -B harness/s804.py harness/dur8.py FILE...), with a self-test that must pass first.
Carried from unit 03's s803.py (dur8's words, S4.7's duration family, R.355's cost words without a count, a SQL sentence without its
database, a call-back without its title, "Hibernate generates" never, a typed md5), with unit 04's own rules: `:name` shown AT the
driver (the witness's text refutes it - the driver receives `?`); "validated" / "checked" said of the record query(Customer.class)
builds without RE-MEASURE 10's capture named (it is built unchecked); a pair of counts from two windows (R.367); "N times" (R.309);
R.302 the captures' numbers typed in prose (77, 150, 40, and 1 / 0 / 40 beside a counted noun) - they live in the runs' printed
blocks and the values block only. Lines inside a fenced block and the values block are the runs' own text (receipts.sh checks
them) and are not judged here; a `code span` is masked for every rule but the driver rule, which reads the raw sentence."""
import importlib.util, re, sys
spec = importlib.util.spec_from_file_location("dur8", sys.argv[1]); m = importlib.util.module_from_spec(spec); spec.loader.exec_module(m)
FAM = re.compile(r"\b(?:forever|at once|immediately|instantly|instant|right away|in no time|a moment|momentarily|eventually|"
                 r"(?:one|two|three|four|five|ten|\d+)\s+(?:second|minute|hour)s?|half a second)\b", re.I)
SPEED = re.compile(r"\b(?:slow(?:er|ly)?|quick(?:er|ly)?|faster|fast)\b", re.I)
COST = re.compile(r"\b(?:lighter|heavier|simpler|leaner|cheaper|costlier|expensive|overhead|efficient|bloat\w*)\b", re.I)
COUNTED = re.compile(r"\bstatements?\b|\bprepares?\b|\bwindow\b|values block|the capture|the witness", re.I)
NAMEDRV = re.compile(r"\bdriver\b[^.;]*?\b(?:receives?|received|sees|saw|gets|got|is sent|sends?|says|reads|shows|holds|keeps)\b[^.;]*?:name\b|:name\b[^.;]*?\bat the driver\b", re.I)
NAMEOK = re.compile(r"\brewritten\b|\bnever\b|\bnot\b|\bno `?:name|\brefused\b|\binstead of\b", re.I)
VALID = re.compile(r"\b(?:is|are|gets?|got|was|were|been|being)\s+(?:validated|checked)\b|\bvalidates\b|\bchecks the record\b", re.I)
RECORD = re.compile(r"query\(Customer\.class\)|DataClassRowMapper|the record (?:built|it builds|JdbcClient builds)|\bRowMapper\b", re.I)
VALIDOK = re.compile(r"\bnever\b|\bnot\b|\bunchecked\b|RE-MEASURE 10|\bno one\b|\bnothing\b", re.I)
PAIR = re.compile(r"\b(?:against|versus|vs\.?)\b[^.;]*\b(?:statements?|prepares?)\b|\b(?:statements?|prepares?)\b[^.;]*\b(?:against|versus|vs\.?)\b", re.I)
PAIROK = re.compile(r"JPA vs JDBC vs Plain SQL|\bR\.367\b|\bone window\b|\bthe same window\b|\bunit 06\b", re.I)
TIMES = re.compile(r"\b(?:\d+|one|two|three|four|five|six|seven|eight|nine|ten|many|several|multiple)\s+times\b", re.I)
SQLW = re.compile(r"\b(?:the SQL|its SQL|SQL lines?|the SQL texts?|the text)\b[^.;]*\b(?:reads?|quoted|unquoted|upper-?case|lower-?case|shows?|prints?)\b", re.I)
DB = re.compile(r"\bH2\b|\bPostgreSQL\b|both databases|each database|on both", re.I)
TYPED = re.compile(r"(?<![\w.#:=-])(?:77|150|40)(?![\w:-]|\.\d)|(?<![\w.#:=-])(?:40|1|0)\s+(?:statements?|customers|pauses|SELECTs?|rows?|prepares?|records?|days)\b", re.I)
HASH = re.compile(r"\b[0-9a-f]{32}\b", re.I)
GEN = re.compile(r"\bHibernate generates\b", re.I)
TITLES = ["JDBC: Connect, Query, Map Rows to Records", "TiffinBox on a Real Database: The JDBC Repository", "Aggregates, Not Entities",
          "Relationships Without an ORM", "JPA vs JDBC vs Plain SQL", "Why Another Data Module", "Testing the JDBC Layer",
          "JdbcTemplate, NamedParameterJdbcTemplate, JdbcClient"]
CALLED = re.compile(r"\b(?:the )?lessons? called\b|\bCourse (?:2|4|5|6|7)\b(?!'s (?:final anchor|capstone|builders|scripts|harness|units|worked|form|tree35))|\bas Course 7\b", re.I)
CALLOK = re.compile(r"Course 7's (?:harness|tree35|units|worked|form|precedent|builders|scripts|capstone|final)|c7-unit\d+|`c7-unit|c2-unit35|no Course 6 unit|Course 6\x27s title|`java6_series\.py`|Course 2\x27s (?:block|shape|raw JDBC|JDBC under)|no Course 2 code", re.I)


def verdicts(s, raw=None):
    out = []
    raw = s if raw is None else raw
    for w in m.DUR.finditer(s): out.append("dur8: " + w.group(0))
    for w in FAM.finditer(s): out.append("S4.7's family: " + w.group(0))
    for w in SPEED.finditer(s):
        if not m.DUR.search(w.group(0)): out.append("a speed word: " + w.group(0))
    if COST.search(s) and not COUNTED.search(raw): out.append("R.355: a cost word without its count: " + COST.search(s).group(0))
    if NAMEDRV.search(raw) and not NAMEOK.search(raw): out.append("the hazard: `:name` shown at the driver - the witness's text is `?`")
    if VALID.search(raw) and RECORD.search(raw) and not VALIDOK.search(raw): out.append("RE-MEASURE 10: the record query(Customer.class) builds is never checked")
    if PAIR.search(s) and not PAIROK.search(raw): out.append("R.367: a pair of counts across windows")
    if TIMES.search(s): out.append("R.309: \"N times\": " + TIMES.search(s).group(0))
    if SQLW.search(s) and not DB.search(raw): out.append("R.353/R.365: a SQL sentence without its database")
    if TYPED.search(s): out.append("R.302: a capture's number typed in prose: " + TYPED.search(s).group(0))
    if HASH.search(raw): out.append("R.302: a typed md5")
    if GEN.search(s): out.append("§10: \"Hibernate generates\"")
    if CALLED.search(raw) and not any(t in raw for t in TITLES) and not CALLOK.search(raw): out.append("R.224: a call-back without its title")
    return out


CASES = [("J-D-B-C is faster.", 1), ("It starts at once.", 1), ("a second connection reads it", 0),
         ("JdbcClient is simpler.", 1), ("JdbcClient is simpler: the witness counts one statement.", 0),
         ("The driver receives `:name`.", 1), ("At the driver the text still says `:name`.", 1), ("The text keeps `:name` at the driver.", 1),
         ("The driver receives `?`: the `:name` is rewritten before it.", 0), ("The driver never sees `:name`.", 0),
         ("The record query(Customer.class) builds is validated.", 1), ("DataClassRowMapper checks the record.", 1),
         ("The record query(Customer.class) builds is not validated (RE-MEASURE 10).", 0), ("The request body is validated.", 0),
         ("The custom query is one statement against the repositories' forty-one statements.", 1),
         ("JdbcClient's call is one statement against JdbcTemplate's, each in its own window, R.367.", 0),
         ("The driver received the same text four times.", 1), ("Four calls, one text at the driver.", 0),
         ("The SQL reads unquoted.", 1), ("The SQL reads unquoted on H2.", 0),
         ("The sum is 77.", 1), ("Meera pays 150 a meal.", 1), ("It returns 40 rows.", 1), ("Each form is 1 prepare.", 1), ("Ports 20430-20439.", 0),
         ("`pricePerMeal=150` is in the record.", 0), ("The numbers are in the values block.", 0),
         ("The hash is 7ce49e3ec13c212a31ee6ba4618f53ab.", 1), ("Hibernate generates the SELECT.", 1),
         ("As Course 2 showed.", 1), ("As Course 2's JDBC: Connect, Query, Map Rows to Records showed.", 0),
         ("Course 6's rule: no Course 6 unit says it.", 0), ("JdbcTemplate is Course 2's shape.", 0), ("Course 2 wrote it by hand.", 1)]
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
