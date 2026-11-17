"""Unit 07's prose gate, per sentence (python3 -I -B harness/s807.py harness/dur8.py FILE...), with a self-test that must pass first.
Carried from unit 06's s806.py (dur8's words, S4.7's duration family, the speed and cost words - no time is measured in unit 07 either -,
a typed md5, "Hibernate generates" never, a call-back without its title, a typed SQL string), with unit 07's own rules: Amendment A
(RED #3) - "the database TiffinBox runs on" / "a database TiffinBox never uses" (TiffinBox starts on H2 in memory by default; the test
runs on PostgreSQL by the capstone's digest); S8.20 - a sentence that says green / passes / passed without the database that answered
beside it (PostgreSQL 18.6, H2 2.5.250, "the database that answered", "the product line"); R.319 - a container's port printed raw;
C8-17 - an H2-against-PostgreSQL ranking; ⚑7 - "Failsafe" said as what runs the tests (Surefire's container-tests execution does);
R.302 - the captures' numbers typed in prose (18, 21, 23 anywhere; any count beside a counted noun). Lines inside a fenced block and the
values block are the runs' own text (receipts.sh checks them) and are not judged here; a `code span` is masked for every rule but the
port, Failsafe and SQL rules, which read the raw sentence."""
import importlib.util, re, sys
spec = importlib.util.spec_from_file_location("dur8", sys.argv[1]); m = importlib.util.module_from_spec(spec); spec.loader.exec_module(m)
FAM = re.compile(r"\b(?:forever|at once|immediately|instantly|instant|right away|in no time|a moment|momentarily|eventually|"
                 r"(?:one|two|three|four|five|ten|\d+)\s+(?:second|minute|hour)s?|half a second)\b", re.I)
SPEED = re.compile(r"\b(?:slow(?:er|est|ly)?|quick(?:er|ly)?|fast(?:er|est)?)\b", re.I)
COST = re.compile(r"\b(?:lighter|heavier|simpler|cleaner|leaner|cheaper|costlier|expensive|overhead|efficient|inefficient|bloat\w*)\b", re.I)
AMEND = re.compile(r"\bthe database TiffinBox runs on\b|\bdatabase TiffinBox never uses\b|\bTiffinBox's (?:real|production) database\b", re.I)
GREEN = re.compile(r"\b(?:green|passes|passed|pass)\b", re.I)
PRODUCT = re.compile(r"PostgreSQL 18\.6|H2 2\.5\.250|the database that answered|the product line|database line|jdbc:h2:mem|jdbc:postgresql", re.I)
PORT = re.compile(r"localhost:\d{2,5}\b|127\.0\.0\.1:(?:[3-6]\d{4})\b")
RANK = re.compile(r"\b(?:H2|PostgreSQL)\b[^.;]*\b(?:better|worse|more realistic|realistic|the real (?:one|database)|trustworth\w*|reliable|unreliable|good enough|toy|lies)\b|"
                  r"\b(?:better|worse|more realistic|good enough|toy)\b[^.;]*\b(?:H2|PostgreSQL)\b", re.I)
FAILSAFE = re.compile(r"\bFailsafe\b", re.I)
NEG = re.compile(r"\bno\b|\bnot\b|\bnever\b|\bwithout\b|\bnone\b|\brefused\b", re.I)
TYPED = re.compile(r"(?<![\w.#:=/-])(?:18|21|23)(?![\w:/-]|\.\d)"
                   r"|(?<![\w.#:=/-])\d+\s+(?:tests?|customers?|rows?|containers?|creates?|pulls?|beans?|reports?|words|statements?|lines|files|migrations)\b", re.I)
HASH = re.compile(r"\b[0-9a-f]{32}\b|466c20ed|7ce49e3e", re.I)
GEN = re.compile(r"\bHibernate generates\b", re.I)
SQL = re.compile(r"SELECT customer\.|FROM customer\b|FROM \"customer\"|\"customer\"\.\"", re.I)
TITLES = ["Capstone: TiffinBox on Postgres", "Aggregates, Not Entities", "Testing the JDBC Layer", "JPA vs JDBC vs Plain SQL", "Why Another Data Module"]
CALLED = re.compile(r"\b(?:the )?lessons? called\b|\bCourse (?:2|4|5|6|7)\b(?!'s (?:final anchor|capstone|builders|scripts|harness|units|recipe|form|precedent|probe|IT))|\bas Course 7\b", re.I)
CALLOK = re.compile(r"Course 7's (?:harness|units|recipe|form|precedent|builders|scripts|capstone|final|probe|IT)|c7-unit\d+|`c7-unit|`java7_series\.py`", re.I)


def verdicts(s, raw=None):
    out = []
    raw = s if raw is None else raw
    for w in m.DUR.finditer(s): out.append("dur8: " + w.group(0))
    for w in FAM.finditer(s): out.append("S4.7's family: " + w.group(0))
    for w in SPEED.finditer(s):
        if not m.DUR.search(w.group(0)): out.append("a speed word: " + w.group(0))
    for w in COST.finditer(s): out.append("R.355: a cost word (no time and no adjective in unit 07): " + w.group(0))
    if AMEND.search(raw): out.append("Amendment A (RED #3): the database TiffinBox runs on - it starts on H2 in memory by default; the test runs on PostgreSQL by the digest")
    if GREEN.search(s) and not PRODUCT.search(raw): out.append("S8.20: green or passes without the database that answered beside it")
    if PORT.search(raw): out.append("R.319: a port printed raw: " + PORT.search(raw).group(0))
    if RANK.search(s): out.append("C8-17: an H2-against-PostgreSQL ranking")
    if FAILSAFE.search(raw) and not NEG.search(raw): out.append("⚑7: Failsafe - the tests run in Surefire's container-tests execution")
    if TYPED.search(s): out.append("R.302: a capture's number typed in prose: " + TYPED.search(s).group(0))
    if HASH.search(raw): out.append("R.302: a typed md5")
    if GEN.search(s): out.append("§10: \"Hibernate generates\"")
    if SQL.search(raw): out.append("R.225/R.365: a typed SQL string in the prose")
    if CALLED.search(raw) and not any(t in raw for t in TITLES) and not CALLOK.search(raw): out.append("R.224: a call-back without its title")
    return out


CASES = [("J-D-B-C is faster.", 1), ("It starts at once.", 1), ("a second connection reads it", 0), ("The slice is lighter.", 1),
         ("The test runs on the database TiffinBox runs on.", 1), ("The exercise passes on a database TiffinBox never uses.", 1),
         ("The test runs on PostgreSQL by the capstone's digest.", 0),
         ("The run is green.", 1), ("The run is green, and the database that answered is H2 2.5.250.", 0), ("Both tests pass.", 1),
         ("Both tests pass on PostgreSQL 18.6.", 0), ("It passed with `jdbc:h2:mem:<uuid>` printed.", 0),
         ("The URL was `jdbc:postgresql://localhost:32771/test`.", 1), ("The URL is `jdbc:postgresql://localhost:<port>/test`.", 0),
         ("H2 is good enough for these tests.", 1), ("PostgreSQL is the real database.", 1), ("H2 answered; PostgreSQL answered the solution.", 0),
         ("Failsafe runs the container tests.", 1), ("No Failsafe: Surefire's second execution runs them.", 0),
         ("The verify runs 23 tests.", 1), ("18 on H2.", 1), ("The fixture adds 1 customer.", 1), ("It creates 3 containers.", 1),
         ("PostgreSQL 18.6 answered.", 0), ("Ports 20460-20469.", 0), ("Spring Boot 4.1.2.", 0), ("The numbers are in the values block.", 0),
         ("The seven's md5 is 466c20ed.", 1), ("Hibernate generates the SELECT.", 1), ("The SQL reads SELECT customer.id AS id.", 1),
         ("As Course 7 showed.", 1), ("As Course 7's Capstone: TiffinBox on Postgres showed.", 0), ("Course 7's recipe, unchanged.", 0),
         ("It took two seconds.", 1), ("Spring Data JDBC is slower here.", 1)]
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
