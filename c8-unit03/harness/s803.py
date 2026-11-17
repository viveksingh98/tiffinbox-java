"""Unit 03's prose gate, per sentence (python3 -I -B harness/s803.py harness/dur8.py FILE...), with a self-test that must pass first.
Carried from unit 01's s801.py and unit 02's s802.py (dur8's words, S4.7's duration family, R.355's cost words without a count, a SQL
sentence without its database, a call-back without its title, "Hibernate generates" never, a typed md5), with unit 03's own rules:
S8.14 "new ids" / "fresh ids" / "re-numbered" (the ids survive - psql's and JdbcTemplate's read-backs); S8.16 the INSERTs' order
compared or voiced (count, never order); S8.26 = R.368 "single-query loading changes nothing", or any single-query sentence without
its method AND its database; R.364 a version sentence that moves the number without the read-back client named; R.224 mappedBy or
"inverse side" outside Course 7's @OneToMany/@ManyToOne and the Owning Side called back by title; R.68 the aggregate glossed again
(unit 02, Aggregates, Not Entities, paid it - called back by title only); R.302 the captures' numbers typed in prose (41, 38, 39, 77,
and 40 / 4 / 3 / 2 / 1 beside a counted noun) - they live in the runs' printed blocks and the values block only. Lines inside a fenced
block and the values block are the runs' own text (receipts.sh checks them) and are not judged here; nor is a `code span`."""
import importlib.util, re, sys
spec = importlib.util.spec_from_file_location("dur8", sys.argv[1]); m = importlib.util.module_from_spec(spec); spec.loader.exec_module(m)
FAM = re.compile(r"\b(?:forever|at once|immediately|instantly|instant|right away|in no time|a moment|momentarily|eventually|"
                 r"(?:one|two|three|four|five|ten|\d+)\s+(?:second|minute|hour)s?|half a second)\b", re.I)
SPEED = re.compile(r"\b(?:slow(?:er|ly)?|quick(?:er|ly)?|faster|fast)\b", re.I)
COST = re.compile(r"\b(?:lighter|heavier|simpler|leaner|cheaper|costlier|expensive|overhead|efficient|bloat\w*)\b", re.I)
COUNTED = re.compile(r"\bstatements?\b|\bSELECTs?\b|\bwindow\b|values block|the capture|the witness", re.I)
NEWIDS = re.compile(r"\b(?:new|fresh|different) ids\b|\bre-?numbered\b|\bnew ids?\b for (?:every|each|all|the old)|\brecreated with new\b", re.I)
ORDER = re.compile(r"\bthe (?:first|second|last|later|earlier) INSERT\b|\bINSERTs? (?:in (?:this|that|the same) order|come first|comes first)\b|"
                   r"\border of the INSERTs\b|\bINSERT order\b|\bINSERT (?:before|after) the (?:other )?INSERT\b", re.I)
ORDEROK = re.compile(r"\bnot fixed\b|\bnever (?:the )?order\b|\bcount, never order\b|\bS8\.16\b|\bR\.358\b", re.I)
SQ = re.compile(r"single[- ]query loading", re.I)
SQNOTHING = re.compile(r"single[- ]query loading (?:changes|does|makes) (?:nothing|no difference)", re.I)
SQMETHOD = re.compile(r"findAll\(\)|findById|findAllById|findAll\(Sort", re.I)
SQDB = re.compile(r"\bH2\b|\bPostgreSQL\b", re.I)
VER = re.compile(r"\bversion\b(?! lines?\b)(?!\.txt)[^.;]*?(?:\+ ?1\b|\braise[sd]?\b|\brises\b|\bgoes up\b|→|->|\bby one\b|\bmoved\b|\bunchanged\b)", re.I)
VEROK = re.compile(r"\bpsql\b|\bJdbcTemplate\b|second client", re.I)
INV = re.compile(r"\bmappedBy\b|\binverse side\b|\bowning side\b", re.I)
INVOK = re.compile(r"@OneToMany/@ManyToOne and the Owning Side")
GLOSS = re.compile(r"\ban aggregate is\b|\baggregate means\b|\ba group of objects (?:saved|loaded)\b", re.I)
GLOSSOK = re.compile(r"Aggregates, Not Entities")
SQLW = re.compile(r"\b(?:the SQL|its SQL|SQL lines?|the SQL texts?)\b[^.;]*\b(?:reads?|quoted|unquoted|upper-?case|lower-?case|shows?|prints?)\b", re.I)
DB = re.compile(r"\bH2\b|\bPostgreSQL\b|both databases|each database|on both", re.I)
TYPED = re.compile(r"(?<![\w.#:-])(?:41|38|39|77)(?![\w:-]|\.\d)|(?<![\w.#:-])(?:40|4|3|2|1)\s+(?:statements?|customers|pauses|SELECTs?|aggregates|INSERTs?|prepares?|rows)\b", re.I)
HASH = re.compile(r"\b[0-9a-f]{32}\b", re.I)
GEN = re.compile(r"\bHibernate generates\b", re.I)
TITLES = ["@OneToMany/@ManyToOne and the Owning Side", "Aggregates, Not Entities", "Relationships Without an ORM", "JPA vs JDBC vs Plain SQL",
          "Why Another Data Module", "Testing the JDBC Layer", "Cascades and Orphan Removal", "The Persistence Context"]
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
    if NEWIDS.search(s): out.append("S8.14: the ids survive - \"" + NEWIDS.search(s).group(0) + "\"")
    if ORDER.search(s) and not ORDEROK.search(raw): out.append("S8.16: the INSERTs' order voiced: " + ORDER.search(s).group(0))
    if SQNOTHING.search(s): out.append("S8.26/R.368: \"single-query loading changes nothing\"")
    elif SQ.search(s) and not (SQMETHOD.search(raw) and SQDB.search(raw)): out.append("S8.26/R.368: single-query loading without its method AND database")
    if VER.search(raw) and not VEROK.search(raw): out.append("R.364: a version sentence without its read-back client")
    if INV.search(s) and not INVOK.search(raw): out.append("R.224: mappedBy / the inverse side outside Course 7's call-back by title")
    if GLOSS.search(raw) and not GLOSSOK.search(raw): out.append("R.68: the aggregate glossed again (call unit 02 back by title)")
    if SQLW.search(s) and not DB.search(raw): out.append("R.353/R.365: a SQL sentence without its database")
    if TYPED.search(s): out.append("R.302: a capture's number typed in prose: " + TYPED.search(s).group(0))
    if HASH.search(raw): out.append("R.302: a typed md5")
    if GEN.search(s): out.append("§10: \"Hibernate generates\"")
    if CALLED.search(raw) and not any(t in raw for t in TITLES) and not CALLOK.search(raw): out.append("R.224: a call-back without its title")
    return out


CASES = [("J-D-B-C is faster.", 1), ("It starts at once.", 1), ("a second connection reads it", 0),
         ("The module is simpler.", 1), ("The module is simpler: the witness counts its statements.", 0),
         ("The save gives the pauses new ids.", 1), ("The rows are re-numbered.", 1), ("The new pause gets an id from the identity.", 0),
         ("The first INSERT carries the old id.", 1), ("The INSERTs are counted, never order: a Set's iteration is not fixed.", 0),
         ("Single-query loading changes nothing.", 1), ("Single-query loading makes it one statement.", 1),
         ("With single-query loading on, findAll() reads in one statement on PostgreSQL.", 0),
         ("Single-query loading on PostgreSQL helps.", 1),
         ("The version goes up by one.", 1), ("The version goes up by one, read back by psql.", 0), ("The version lines name Boot.", 0),
         ("There is no mappedBy here.", 1), ("No mappedBy, as in Course 7's @OneToMany/@ManyToOne and the Owning Side.", 0),
         ("An aggregate is a group of objects saved as one.", 1), ("The aggregate, as Aggregates, Not Entities named it.", 0),
         ("The SQL reads unquoted.", 1), ("The SQL reads unquoted on H2.", 0),
         ("Window A prints 41.", 1), ("The save sends 4 statements.", 1), ("The unchanged save is 3 statements.", 1), ("It reads 40 customers.", 1),
         ("Sunil's pause 1:3 survives.", 0), ("`new ids` is refused.", 0), ("`single-query loading changes nothing` is refused.", 0), ("The numbers are in the values block.", 0), ("Ports 20420-20429.", 0),
         ("The hash is 7ce49e3ec13c212a31ee6ba4618f53ab.", 1), ("Hibernate generates the DELETE.", 1),
         ("As Course 7 said.", 1), ("As Course 7's Cascades and Orphan Removal said.", 0)]
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
