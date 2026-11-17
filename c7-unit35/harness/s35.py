"""Unit 35's prose gate, per sentence (python3 -I -B harness/s35.py harness/dur7.py FILE...), with a self-test that must pass first.
Carried from unit 36's s36: dur7's words (R.172), S4.7's duration meanings (R.264) - with the brief's "slow", "quick", "instantly" -,
R.301 (cost words only in a sentence naming a printed count), R.190 (tests as a witness: this unit runs none), R.224 (a call-back by its
title), a password in a URL, a typed md5, "Hibernate generates" never (contract §Voice). Unit 35's own (Sections 6-7's rules):
R.315 - update said as captured: "update only adds columns", "update never changes/narrows/retypes a column" refused, and a WARN run
said as a stop ("the start fails") beside update or a WARN, unless the sentence says the start goes on / ready: yes;
R.316 - validate checks presence and type, not length: "validate catches every mismatch", "validate checks the length", and the
length-40 run voiced as refused by validate are refused (unless negated: passes, no length, not);
R.178 - a ddl-auto run described on a kept, live or production database (unless negated);
R.302 - a jar or byte count typed; the numbers the video may say (4, 2, 0, 40, 60, 255, 6, 8) typed in a prose sentence - an exit status, a section, unit, step,
course or rule number aside - and a hand count of letters or characters ("N letters", "N characters", "letters"): only the run's
printed lines and the values block carry them; R.287 - the Hibernate 5/6 wordings. Lines inside a fenced block, the values block and
the changes table are the runs' own text (receipts.sh checks them) and are not judged here; a `code span` is judged raw by the number,
password, md5 and SQL checks and replaced by a token for the reading checks."""
import importlib.util, re, sys
spec = importlib.util.spec_from_file_location("dur7", sys.argv[1]); m = importlib.util.module_from_spec(spec); spec.loader.exec_module(m)
FAM = re.compile(r"\b(?:forever|for ever|at once|immediately|instantly|instant(?:ly)?|right away|in no time|a moment|momentar(?:y|ily)|straight away|in a flash|"
                 r"(?:one|two|three|four|five|six|seven|eight|nine|ten|\d+)[\s-]+(?:second|minute|hour)s?|half a second|eventually|"
                 r"a\s+(?:second|minute|hour)\b(?!-level|\s+`|\s+(?:connection|copy|run|JVM|database|read|request|time|start|look|migration|folder|file|statement|line|row|step|seed|table|class|set|key|harness|half|tree|plain|second|variant|value|name)))\b", re.I)
NUMW = r"(?:\d+|one|two|three|four|five|six|seven|eight|nine|ten|eleven|twelve|twenty|fifty|a hundred|[NT])"
COST = re.compile(r"\b(?:costs?|costly|costing)\b", re.I)
TM = re.compile(r"\b(?:costs?|costly|costing|cheaper|cheap|expensive|saves? time|sav(?:es|ing) time|takes? longer|time-?consuming|round[- ]trips?)\b"
                rf"|\b{NUMW}\s+times\b", re.I)
COUNT = re.compile(r"\b(?:statements?|SQL lines?|connections?|rows?|lines?|JVMs?)\b", re.I)
SPEED = re.compile(r"\b(?:slow(?:er|ly)?|quick(?:er|ly)?|lag|faster|fast)\b", re.I)
TESTW = re.compile(r"\b\d+ tests?\b|\btests? (?:prove|proves|show|shows|caught|catch|pass(?:ed)?)\b|\bthe 18\b", re.I)
JARS = re.compile(r"\b(?:\d+|one|two|three|four|five|six|seven|eight|nine|ten|eleven|twelve)\s+(?:added\s+)?(?:jars?|libraries)\b|\b\d{1,3}(?:,\d{3})+ (?:B|bytes)\b|\b\d+(?:\.\d+)? ?(?:MB|KB|kB|MiB|KiB)\b", re.I)
PWD = re.compile(r"password=(?!<pw>|\*)|\?user=sa&password=[^<*]", re.I)
HASH = re.compile(r"\b[0-9a-f]{32}\b|\b7f6942f0|\bff5f470f|\b(?:md5|hash) [0-9a-f]{6,}", re.I)
UPDONLY = re.compile(r"\bupdate\b[^.;]*\b(?:only adds?|just adds?|only ever adds?|adds only|never (?:changes|narrows|retypes|alters) (?:a |the |any )?column|cannot (?:narrow|retype|change a column)|does not (?:narrow|retype|change a column)|is (?:safe|harmless))\b", re.I)
STOPW = re.compile(r"\b(?:the start fails|the start stops|the start is refused|fails to start|refuses to start|start(?:-up)? fails|stops the start)\b", re.I)
GOESON = re.compile(r"\bgoes on\b|\bready: yes\b|\bwent on\b|\bvalidate\b", re.I)
WARNUP = re.compile(r"\bWARN\b|\bupdate\b|GenerationTarget", re.I)
VALALL = re.compile(r"\bvalidate\b[^.;]*\b(?:catches|checks|finds|refuses|rejects) (?:every|all|any) (?:mismatch|difference|change)\w*|\bvalidate\b[^.;]*\bchecks? (?:the |a |each |column )?lengths?\b", re.I)
VAL40 = re.compile(r"\bvalidate\b[^.;]*\b(?:refuses|refused|rejects|rejected|catches|caught|fails|failed|stops|stopped)\b[^.;]*\b(?:length|narrow\w*|shorter|forty)\b"
                   r"|\b(?:length|narrow\w*|shorter|forty)\b[^.;]*\b(?:refused|rejected|caught|stopped) by validate\b", re.I)
NEG = re.compile(r"\bnot\b|\bnever\b|\bno\b|\bpass(?:es|ed)?\b|\bwithout\b", re.I)
KEPT = re.compile(r"\b(?:ddl-auto|create|create-drop|update)\b[^.;]*\b(?:on|against|to|writes to) (?:a |the |TiffinBox's )?(?:kept|live|production|shared|real customers'?) database\b", re.I)
NUMS = re.compile(r"(?<![\w#/§ⓘ⚑(\[-])(?<!\w\.)(?:40|60|255|4|2|0|6|8)(?!\w|\.\d|%|-\w|/\w)")
NUMOK = re.compile(r"(?:exit|Section|section|unit|units|Course|course|batch|step|Step|row|rows #|item|R\.|S|C|RE-MEASURE|flag|code|status)\s*$")
LETTERS = re.compile(r"\b\d+[\s-]+(?:letters?|characters?)\b|\bletters\b", re.I)
H56 = re.compile(r"\bHibernate (?:5|6)\b|\bcore version [56]\.|\bHHH000412\b|\bHibernate Core \{", re.I)
GEN = re.compile(r"\bHibernate generates\b", re.I)
TITLES = ["Your First Entity and EntityManager", "Reading the SQL Hibernate Writes", "Flyway: Versioned Migrations", "Never Use ddl-auto in Production"]
CALLED = re.compile(r"\b(?:the )?lessons? called\b|\bthe next lesson\b|\bthe (?:first|index|SQL) lesson\b|\bas (?:the )?lesson\b", re.I)
SQLW = re.compile(r"alter table if exists|alter column [a-z_]+ set data type|add column [a-z_]+ integer|drop table if exists|create table (?:customer|pause|diner)|create index pause|insert into customer|drop database|select count", re.I)


def nums(raw):
    hits = []
    for w in NUMS.finditer(raw):
        if not NUMOK.search(raw[:w.start()]): hits.append(w.group(0))
    return hits


def verdicts(s, raw=None):
    out = []
    raw = s if raw is None else raw
    for w in m.DUR.finditer(s): out.append("dur7: " + w.group(0))
    for w in FAM.finditer(s): out.append("S4.7's family: " + w.group(0))
    hits = [w.group(0) for w in TM.finditer(s)]
    if hits and not (all(COST.fullmatch(h) for h in hits) and COUNT.search(s)): out.append("R.301's family: " + ", ".join(hits))
    for w in SPEED.finditer(s):
        if not m.DUR.search(w.group(0)): out.append("a speed word: " + w.group(0))
    if TESTW.search(s): out.append("R.190: tests as a witness or a typed test count: " + TESTW.search(s).group(0))
    if JARS.search(raw): out.append("R.302: a jar or byte count typed: " + JARS.search(raw).group(0))
    if PWD.search(raw): out.append("a password in prose")
    if HASH.search(raw): out.append("R.302/R.252: a typed md5: " + HASH.search(raw).group(0))
    if UPDONLY.search(s): out.append("R.315: update said as adding only / never changing a column: " + UPDONLY.search(s).group(0))
    if STOPW.search(s) and WARNUP.search(s) and not GOESON.search(s): out.append("R.315: a WARN run said as a stop: " + STOPW.search(s).group(0))
    if VALALL.search(s) and not NEG.search(VALALL.search(s).group(0)): out.append("R.316: validate said to catch every mismatch or check a length: " + VALALL.search(s).group(0))
    if VAL40.search(s) and not NEG.search(s): out.append("R.316: the length run voiced as refused by validate: " + VAL40.search(s).group(0))
    if KEPT.search(s) and not NEG.search(s): out.append("R.178: a ddl-auto run on a kept database: " + KEPT.search(s).group(0))
    n = nums(raw)
    if n: out.append("R.302: a typed number: " + ", ".join(n))
    if LETTERS.search(raw): out.append("R.302 (RED #1805): a hand count of letters or characters: " + LETTERS.search(raw).group(0))
    if H56.search(raw): out.append("R.287: a Hibernate 5/6 wording: " + H56.search(raw).group(0))
    if SQLW.search(raw): out.append("R.225: typed SQL: " + SQLW.search(raw).group(0))
    if GEN.search(s): out.append("§Voice: \"Hibernate generates\"")
    if CALLED.search(s) and not any(t in raw for t in TITLES): out.append("R.224: a call-back without its title")
    return out


CASES = [("update applies them instantly.", 1), ("The start is quick.", 1), ("at once", 1), ("a second connection reads the catalogue", 0),
         ("It took 26 milliseconds.", 1), ("update only adds columns.", 1), ("update never narrows a column.", 1),
         ("update adds, narrows and retypes columns, and never drops or renames one.", 0),
         ("With update the start fails on the refused column.", 1), ("The WARN is logged, ready: yes, and the start goes on.", 0),
         ("validate catches every mismatch.", 1), ("validate checks the length of a column.", 1), ("validate checks no length.", 0),
         ("validate refuses the length change.", 1), ("The narrowed length is refused by validate.", 1), ("validate passes the length change.", 0),
         ("create runs against a kept database here.", 1), ("ddl-auto never writes to a kept database.", 0),
         ("The table holds 4 rows.", 1), ("exit 0, the start went on", 0), ("Section 6's second unit", 0), ("H2 2.5.250 and Boot 4.1.2", 0),
         ("the column narrowed from 60 to 40", 1), ("The column narrowed to 40.", 1), ("Boot 4.1.2 and R.302", 0), ("a name of 45 characters", 1), ("a name the harness builds, its length printed", 0),
         ("the name has many letters", 1), ("Hibernate 6 said it differently.", 1), ("Hibernate generates the schema.", 1),
         ("Hibernate's schema step writes the DDL.", 0), ("The 18 tests prove it.", 1), ("this unit runs no tests", 0),
         ("The hash is 7f6942f0ed8bf296d661f629557f26c6.", 1), ("as the next lesson shows", 1),
         ("the next lesson, *Flyway: Versioned Migrations*, writes the schema", 0),
         ("The URL `jdbc:postgresql://127.0.0.1:20148/u35?user=sa&password=Xy12` is printed.", 1),
         ("It ran `alter table if exists customer add column x integer`.", 1), ("A restart costs no row.", 0), ("it saves time", 1), ("lib/ holds 91 libraries", 1), ("the libraries the receipt counts", 0)]
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
MARKS = ("<!-- values: begin -->", "<!-- values: end -->", "<!-- changes table: begin -->", "<!-- changes table: end -->", "<!-- runs: begin -->", "<!-- runs: end -->")
for p in sys.argv[2:]:
    fence = False; vals = False; para = []; start = 0
    for i, l in enumerate(open(p, encoding="utf-8"), 1):
        mk = l.strip() in MARKS
        brk = l.startswith("```") or mk or not l.strip() or l.startswith(("#", "- ", "| "))
        if brk or fence or vals:
            if para: judge(p, start, para); para = []
        if l.startswith("```"): fence = not fence; continue
        if l.strip() in ("<!-- values: begin -->", "<!-- changes table: begin -->"): vals = True; continue
        if l.strip() in ("<!-- values: end -->", "<!-- changes table: end -->"): vals = False; continue
        if fence or vals or not l.strip(): continue
        if not para: start = i
        para.append(l)
    if para: judge(p, start, para)
print("self-test: %d cases · refused: %d" % (len(CASES), n))
