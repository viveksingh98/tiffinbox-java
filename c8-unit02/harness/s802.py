"""Unit 02's prose gate, per sentence (python3 -I -B harness/s802.py harness/dur8.py FILE...), with a self-test that must pass first.
Carried from Course 7's s39 (dur8's words, S4.7's duration meanings, R.301's cost family, a password in a URL, R.302's typed md5s and
jar counts, R.224 a call-back without its title, "Hibernate generates" never), with Section 1's own rules (R.343-R.368):
R.355 "faster", "lighter", "simpler", "leaner", "cheaper" without a count in the sentence; R.359 the row said to change (or not),
read off the Java object - a sentence about the row names its second client (psql, JdbcTemplate, read back); R.364 a version or
updated_at sentence without the read-back; R.353/R.365 a SQL sentence (quoted, unquoted, the SQL reads) without its database; R.367
"2 / 2 / 2", and a statement pair without its windows; R.368 single-query loading claimed in this unit (it is U03's); R.335 TiffinBox
on PostgreSQL unscoped, "+ the harness's driver" (this jar holds its own driver); R.215 is the receipt's dish check.
Lines inside a fenced block and the values block are the runs' own text (receipts.sh checks them) and are not judged here; nor is a
`code span` (a quoted token) - the password and md5 checks read the raw sentence, code spans included."""
import importlib.util, re, sys
spec = importlib.util.spec_from_file_location("dur8", sys.argv[1]); m = importlib.util.module_from_spec(spec); spec.loader.exec_module(m)
FAM = re.compile(r"\b(?:forever|at once|immediately|instantly|instant|right away|in no time|a moment|momentarily|eventually|"
                 r"(?:one|two|three|four|five|ten|\d+)\s+(?:second|minute|hour)s?|half a second)\b", re.I)
COST = re.compile(r"\b(?:lighter|heavier|simpler|leaner|cheaper|costlier|expensive|overhead|efficient|bloat\w*)\b", re.I)
HASNUM = re.compile(r"\d")
SPEED = re.compile(r"\b(?:slow(?:er|ly)?|quick(?:er|ly)?|faster|fast)\b", re.I)
ROW = re.compile(r"\b(?:the row|the database|the table|the customer table)\b[^.;]*\b(?:changed|changes|is updated|was updated|was written|is written|was not written|stays|still says|unchanged)\b", re.I)
SECOND = re.compile(r"psql|JdbcTemplate|read back|read-back|second client", re.I)
VERS = re.compile(r"\b(?:version column|the version|its version|updated_at)\b", re.I)
VERB = re.compile(r"\b(?:rais\w*|goes|went|incremented|bumps?|moves?|unchanged|untouched|alone|leaves?|stamp\w*|writes?|written)\b|0 → 1|1 → 2|\+1", re.I)
SQLW = re.compile(r"\b(?:the SQL|its SQL|SQL lines?|the quoted form|quoted names?|unquoted|the names it writes)\b[^.;]*\b(?:reads?|quoted|unquoted|upper-?case|lower-?case|shows?|prints?)\b", re.I)
DB = re.compile(r"\bH2\b|\bPostgreSQL\b|both databases|each database|either database|on both|neither", re.I)
TRIPLE = re.compile(r"\b\d+ / \d+ / \d+\b")
PAIR = re.compile(r"\bstatements?\b[^.;]*\b(?:against|versus|vs\.?|beside|compared)\b", re.I)
WIN = re.compile(r"window", re.I)
SQL1 = re.compile(r"single[- ]query loading", re.I)
SQL1OK = re.compile(r"Relationships Without an ORM|JPA vs JDBC vs Plain SQL|\bnot\b|\bnever\b|\bno\b|named|unmeasured|hand(?:ed|s)? (?:over|it|to)|U03|U06|later", re.I)
TBPG = re.compile(r"\bTiffinBox runs on PostgreSQL\b|\bTiffinBox\b[^.;]*\bon PostgreSQL by default\b", re.I)
PGSCOPE = re.compile(r"config tree|dev profile|its own driver|a fresh database|a container")
HDRV = re.compile(r"\+ the harness's driver|the harness's driver", re.I)
PWD = re.compile(r"password=(?!<pw>|\*)", re.I)
HASH = re.compile(r"\b[0-9a-f]{32}\b|\b466c20ed|\b(?:md5|hash) [0-9a-f]{6,}", re.I)
JARS = re.compile(r"\b(?:\d+|one|two|three|four|five|six|seven|eight|nine|ten)\s+(?:added\s+)?(?:jars?|libraries)\b", re.I)
GEN = re.compile(r"\bHibernate generates\b", re.I)
TITLES = ["The Persistence Context", "Lazy Loading and LazyInitializationException", "Optimistic Locking with @Version", "The Bean Lifecycle, Step by Step",
          "Relationships Without an ORM", "JPA vs JDBC vs Plain SQL", "Testing the JDBC Layer", "Why Another Data Module", "Aggregates, Not Entities",
          "Capstone: TiffinBox on Postgres", "Auditing and Soft Deletes", "Flyway: Versioned Migrations", "The Repository You Do Not Write"]
CALLED = re.compile(r"\b(?:the )?lessons? called\b|\bCourse (?:2|4|5|6|7)\b(?!'s (?:final anchor|capstone's|last|anchor|xcheck|seven|builders|scripts))|\bas Course 7\b", re.I)
CALLOK = re.compile(r"Course 7 left|Course 7's (?:schema-script|link form|builders)|Course 7's (?:final anchor|capstone|anchor-change|units|builders|scripts|evidence|worked|form|pattern|precedent|R\.)|Course 7 unit \d+'s|`c7-unit|c7-unit\d+|Course 7's [`*]", re.I)


def verdicts(s, raw=None):
    out = []
    raw = s if raw is None else raw
    for w in m.DUR.finditer(s): out.append("dur8: " + w.group(0))
    for w in FAM.finditer(s): out.append("S4.7's family: " + w.group(0))
    for w in SPEED.finditer(s):
        if not m.DUR.search(w.group(0)): out.append("a speed word: " + w.group(0))
    if COST.search(s) and not HASNUM.search(raw): out.append("R.355: a cost or size word without its count: " + COST.search(s).group(0))
    if ROW.search(s) and not SECOND.search(raw): out.append("R.359: the row read off the Java object (no second client named)")
    if VERS.search(s) and VERB.search(s) and not SECOND.search(raw): out.append("R.364: a version or updated_at sentence without the read-back")
    if SQLW.search(s) and not DB.search(raw): out.append("R.353/R.365: a SQL sentence without its database")
    if TRIPLE.search(raw): out.append("R.367: \"2 / 2 / 2\" - a count from each window, unlabelled: " + TRIPLE.search(raw).group(0))
    if PAIR.search(s) and not WIN.search(raw): out.append("R.367: a statement pair without its windows")
    if SQL1.search(s) and not SQL1OK.search(raw): out.append("R.368: single-query loading claimed in this unit")
    if TBPG.search(s) and not PGSCOPE.search(raw): out.append("R.335: TiffinBox on PostgreSQL, unscoped")
    if HDRV.search(raw): out.append("R.335: the harness's driver - this unit's jar holds its own")
    if PWD.search(raw): out.append("a password in prose")
    if HASH.search(raw): out.append("R.302: a typed md5: " + HASH.search(raw).group(0))
    if JARS.search(s): out.append("R.302: a jar count typed: " + JARS.search(s).group(0))
    if GEN.search(s): out.append("§10: \"Hibernate generates\"")
    if CALLED.search(raw) and not any(t in raw for t in TITLES) and not CALLOK.search(raw): out.append("R.224: a call-back without its title")
    return out


CASES = [("Spring Data JDBC is faster.", 1), ("The read is quicker on JDBC.", 1), ("It starts at once.", 1), ("a second connection reads it", 0),
         ("It took 26 milliseconds.", 1), ("The module is lighter.", 1), ("The module is simpler: no persistence context.", 1),
         ("The JDBC read is lighter: 41 statements against the entity graph's 1, each from its window.", 0),
         ("The row changed: the object says 3 meals.", 1), ("The row is unchanged, psql says 2 meals.", 0), ("The row still says 2 meals, read back by JdbcTemplate on H2.", 0),
         ("The version goes 0 → 1 → 2.", 1), ("The version goes 0 → 1 → 2, read back by psql after each window.", 0), ("The JDBC save leaves updated_at alone.", 1),
         ("JDBC's save leaves updated_at as it was - psql read it back after both windows.", 0),
         ("The SQL reads unquoted.", 1), ("The SQL reads unquoted on PostgreSQL and upper-case on H2.", 0), ("The quoted form shows on PostgreSQL only.", 0),
         ("JPA, JDBC and the save: 2 / 2 / 2.", 1), ("Its statements against JPA's are 2 and 2.", 1), ("Window B's statements against window A's: 2 and 2.", 0),
         ("Single-query loading makes it one statement.", 1), ("Single-query loading is not this unit's: Relationships Without an ORM names it.", 0),
         ("TiffinBox runs on PostgreSQL.", 1), ("TiffinBox runs on PostgreSQL through the config tree's URL, with its own driver.", 0),
         ("TiffinBox on PostgreSQL + the harness's driver.", 1), ("The URL `jdbc:postgresql://x?user=sa&password=Xy12` is printed.", 1),
         ("The hash is 466c20ed7e0d5439cb052f32ce09de1b.", 1), ("The jar holds 99 libraries.", 1), ("Hibernate generates the UPDATE.", 1), ("Hibernate writes the UPDATE.", 0),
         ("As the lesson called the persistence context said.", 1), ("As Course 7's *The Persistence Context* said.", 0), ("Course 4 showed the callback.", 1),
         ("Course 4's *The Bean Lifecycle, Step by Step* showed the callback.", 0), ("The data layer as Course 7 left it.", 0),
         ("A pause has no repository of its own.", 0), ("Both modules raise one version column.", 1)]
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
        mk = l.strip() in ("<!-- values: begin -->", "<!-- values: end -->", "<!-- runs: begin -->", "<!-- runs: end -->")
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
