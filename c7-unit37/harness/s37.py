"""Unit 37's prose gate, per sentence (python3 -I -B harness/s37.py harness/dur7.py FILE...), with a self-test that must pass first.
Carried from unit 35's s35: dur7's words (R.172), S4.7's duration meanings (R.264), R.301 (cost words only in a sentence naming a
printed count), R.190 (tests as a witness: this unit runs none), R.224 (a call-back by its title), a password in a URL, a typed md5,
typed SQL (R.225), R.287 (the Hibernate 5/6 wordings), "Hibernate generates" never (contract §Voice). Unit 37's own (Sections 6-7):
R.310 - the lock wait is a configured wait, never a duration: "waits", "forever", "hangs", "until someone releases it", "waited out"
refused ("the next start is refused until the lock is released" is a state and passes); R.317 - Liquibase said to be offline by default
or to call nothing, unless the sentence names the key; R.328 - a rollback read off its "done" (done + rolled back, unless the sentence
says nothing changed), and a file: changelog outside the labelled path-identity step; R.314 - a failure said on the wrong database (H2's
half-applied column or Duplicate column on a PostgreSQL sentence; "records the failed changeset/migration" unscoped); R.312 - "the
refusal is the control"; an adjective in the comparison (better, simpler, heavier, lighter, safer, easier, cleaner, worse); R.302 - a
jar or byte count typed, the numbers the video may say (29, 38, 30, 22, 15, 26, 7, 6, 5, 4, 3, 2, 1, 0, 137) typed in a prose sentence
(an exit status, a unit, section, step, course, changeset, version or rule number aside): only the runs' printed lines and the values
line carry them. Lines inside a fenced block, the values line and the compare table are the runs' own text (receipts.sh checks them)
and are not judged here; a `code span` is judged raw by the number, password, md5 and SQL checks and replaced by a token for the reading
checks."""
import importlib.util, re, sys
spec = importlib.util.spec_from_file_location("dur7", sys.argv[1]); m = importlib.util.module_from_spec(spec); spec.loader.exec_module(m)
FAM = re.compile(r"\b(?:for ever|at once|immediately|instantly|instant(?:ly)?|right away|in no time|a moment|momentar(?:y|ily)|straight away|in a flash|"
                 r"(?:one|two|three|four|five|six|seven|eight|nine|ten|\d+)[\s-]+(?:second|minute|hour)s?|half a second|eventually|"
                 r"a\s+(?:second|minute|hour)\b(?!-level|\s+`|\s+(?:connection|copy|run|JVM|database|read|request|time|start|look|migration|folder|file|statement|line|row|step|seed|table|class|set|key|harness|half|tree|plain|second|variant|value|name|changeset|changelog)))\b", re.I)
WAIT = re.compile(r"\b(?:waits|waiting|waited(?: out)?|forever|hangs?|hung|blocks? for|until someone releases it|wait(?:s|ed)? it out|sits there)\b", re.I)
NUMW = r"(?:\d+|one|two|three|four|five|six|seven|eight|nine|ten|eleven|twelve|twenty|fifty|a hundred|[NT])"
COST = re.compile(r"\b(?:costs?|costly|costing)\b", re.I)
TM = re.compile(r"\b(?:costs?|costly|costing|cheaper|cheap|expensive|saves? time|sav(?:es|ing) time|takes? longer|time-?consuming|round[- ]trips?)\b"
                rf"|\b{NUMW}\s+times\b", re.I)
COUNT = re.compile(r"\b(?:statements?|SQL lines?|connections?|rows?|lines?|JVMs?)\b", re.I)
SPEED = re.compile(r"\b(?:slow(?:er|ly)?|quick(?:er|ly)?|lag|faster|fast)\b", re.I)
TESTW = re.compile(r"\b\d+ tests?\b|\btests? (?:prove|proves|show|shows|caught|catch|pass(?:ed)?)\b|\bthe 18\b", re.I)
JARS = re.compile(r"\b(?:\d+|one|two|three|four|five|six|seven|eight|nine|ten|eleven|twelve)\s+(?:added\s+|extra\s+|more\s+)?(?:jars?|libraries)\b|\b\d{1,3}(?:,\d{3})+ (?:B|bytes)\b|\b\d+(?:\.\d+)? ?(?:MB|KB|kB|MiB|KiB)\b", re.I)
PWD = re.compile(r"password=(?!<pw>|\*)|\?user=sa&password=[^<*]", re.I)
HASH = re.compile(r"\b[0-9a-f]{32}\b|\b7f6942f0|\bae7b6ac3|\b(?:md5|hash) [0-9a-f]{6,}|\b9:[0-9a-f]{6,}", re.I)
OFFLINE = re.compile(r"\bLiquibase\b[^.;]*\b(?:is offline|offline by default|never calls (?:the network|out|home)|calls nothing|makes no (?:network )?calls?|does not call (?:the network|out|home))\b", re.I)
KEYW = re.compile(r"analytics-enabled|analytics\.enabled|\bkey\b|\bunless\b|\btrap\b", re.I)
DONE = re.compile(r"\b(?:done|reports? success|succeeded)\b[^.;]*\b(?:rolled back|rolls back|undid|reverted)\b|\b(?:rolled back|reverted)\b[^.;]*\bbecause it (?:said|printed) done\b", re.I)
NOTHING = re.compile(r"\bnothing\b|\bnot\b|\bno\b|\bnever\b|\bdoes nothing\b|\bdid nothing\b", re.I)
FILEP = re.compile(r"\bfile:", re.I)
FILEOK = re.compile(r"\blabelled\b|\bidentity\b|\bpath as\b|\bthe one\b", re.I)
H2HALF = re.compile(r"\bhalf-applied\b|\bPHONE\b|\bDuplicate column\b|\bsuccess=FALSE\b", re.I)
PGW = re.compile(r"\bPostgreSQL\b")
H2W = re.compile(r"\bH2\b")
ROLLEDB = re.compile(r"\brolled back\b|\brolls? back whole\b", re.I)
REC = re.compile(r"\b(?:records?|recorded|keeps?) (?:the |a )?failed (?:changeset|migration|script)\b", re.I)
CTRL = re.compile(r"\bthe refusal is the control\b|\brefusal (?:is|as) (?:the|a) control\b", re.I)
ADJ = re.compile(r"\b(?:better|simpler|heavier|lighter|safer|easier|cleaner|worse|superior|nicer)\b", re.I)
NUMS = re.compile(r"(?<![\w#/§ⓘ⚑(\[:.=-])(?:137|29|38|30|22|15|26|7|6|5|4|3|2|1|0)(?![\w%]|\.\d|-\w|/\w|:\d)")
NUMOK = re.compile(r"(?:exit|Section|section|unit|units|Unit|Course|course|batch|step|Step|row|rows #|item|R\.|S|C|RE-MEASURE|flag|code|status|changeset|changesets|tiffinbox:|diner:|version|V|Boot|Hibernate|Framework|Flyway|Liquibase|Data JPA|PostgreSQL|H2|JDK|bash|port|ports|number|#)\s*$")
LETTERS = re.compile(r"\b\d+[\s-]+(?:letters?|characters?)\b|\bletters\b", re.I)
H56 = re.compile(r"\bHibernate (?:5|6)\b|\bcore version [56]\.|\bHHH000412\b|\bHibernate Core \{", re.I)
GEN = re.compile(r"\bHibernate generates\b", re.I)
TITLES = ["Reading the SQL Hibernate Writes", "Flyway: Versioned Migrations", "Never Use ddl-auto in Production", "Liquibase, and Choosing"]
CALLED = re.compile(r"\b(?:the )?lessons? called\b|\bthe (?:next|previous) lesson\b|\bthe (?:first|index|SQL|Flyway|ddl-auto) lesson\b|\bas (?:the )?lesson\b", re.I)
SQLW = re.compile(r"create table (?:customer|pause|diner|databasechangelog)|insert into (?:customer|pause|databasechangeloglock)|alter table customer add|select pg_sleep|pg_terminate_backend\(|drop database|select count|update databasechangeloglock", re.I)


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
    for w in WAIT.finditer(s): out.append("R.310: a duration meaning for the lock wait: " + w.group(0))
    hits = [w.group(0) for w in TM.finditer(s)]
    if hits and not (all(COST.fullmatch(h) for h in hits) and COUNT.search(s)): out.append("R.301's family: " + ", ".join(hits))
    for w in SPEED.finditer(s):
        if not m.DUR.search(w.group(0)): out.append("a speed word: " + w.group(0))
    if TESTW.search(s): out.append("R.190: tests as a witness or a typed test count: " + TESTW.search(s).group(0))
    if JARS.search(raw): out.append("R.302: a jar or byte count typed: " + JARS.search(raw).group(0))
    if PWD.search(raw): out.append("a password in prose")
    if HASH.search(raw): out.append("R.302/R.252: a typed md5 or checksum: " + HASH.search(raw).group(0))
    if OFFLINE.search(s) and not KEYW.search(raw): out.append("R.317: Liquibase said to call nothing, without its key: " + OFFLINE.search(s).group(0))
    if DONE.search(s) and not NOTHING.search(s): out.append("R.328: a rollback read off its done: " + DONE.search(s).group(0))
    if FILEP.search(raw) and not FILEOK.search(s): out.append("R.328: a changelog named by a file: path outside the labelled step")
    if H2HALF.search(s) and PGW.search(s) and not H2W.search(s): out.append("R.314: H2's half-applied change said of PostgreSQL: " + H2HALF.search(s).group(0))
    if ROLLEDB.search(s) and H2W.search(s) and not PGW.search(s) and not NOTHING.search(s): out.append("R.314: PostgreSQL's rollback said of H2")
    if REC.search(s) and not (H2W.search(s) or PGW.search(s) or NOTHING.search(s)): out.append("R.314: a failure record unscoped: " + REC.search(s).group(0))
    if CTRL.search(s) and not NOTHING.search(s): out.append("R.312: the refusal as the control")
    if ADJ.search(s): out.append("an adjective in the comparison: " + ADJ.search(s).group(0))
    n = nums(raw)
    if n: out.append("R.302: a typed number: " + ", ".join(n))
    if LETTERS.search(raw): out.append("R.302: a hand count of letters or characters: " + LETTERS.search(raw).group(0))
    if H56.search(raw): out.append("R.287: a Hibernate 5/6 wording: " + H56.search(raw).group(0))
    if SQLW.search(raw): out.append("R.225: typed SQL: " + SQLW.search(raw).group(0))
    if GEN.search(s): out.append("§Voice: \"Hibernate generates\"")
    if CALLED.search(s) and not any(t in raw for t in TITLES): out.append("R.224: a call-back without its title")
    return out


CASES = [("The next start waits forever.", 1), ("It hangs until someone releases it.", 1), ("the next start is refused until the lock is released", 0),
         ("a configured wait, read off the run", 0), ("It took 26 milliseconds.", 1), ("The start is quick.", 1), ("at once", 1),
         ("a second connection reads the table", 0), ("Liquibase is offline by default.", 1), ("Liquibase calls nothing with the key set.", 0),
         ("The rollback printed done, so it rolled back.", 1), ("The command printed done and rolled back nothing.", 0),
         ("The changelog is named `file:../files/changelog.sql` here.", 1), ("The one labelled `file:` run shows the path as identity.", 0),
         ("On PostgreSQL the column is half-applied.", 1), ("On H2 the column is half-applied; PostgreSQL rolls it back whole.", 0),
         ("On H2 the changeset is rolled back.", 1), ("Liquibase records the failed changeset.", 1), ("Liquibase never records a failed changeset.", 0),
         ("The refusal is the control here.", 1), ("Flyway is simpler.", 1), ("Liquibase is heavier.", 1), ("the cells that decide it", 0),
         ("The changelog has 29 lines.", 1), ("exit 1, the start refused", 0), ("changeset 3 failed", 0), ("Section 6's third unit", 0),
         ("Boot 4.1.2 and H2 2.5.250", 0), ("The trap caught 1 line.", 1), ("The wait defaults to 5.", 1), ("Boot has 26 keys.", 1),
         ("Liquibase brings seven jars.", 1), ("the jars the receipt lists", 0), ("Hibernate 6 said it differently.", 1), ("Hibernate generates the schema.", 1),
         ("The 18 tests prove it.", 1), ("this unit runs no tests", 0), ("The hash is 7f6942f0ed8bf296d661f629557f26c6.", 1),
         ("the checksum `9:0d69134f1b2c` moved", 1), ("as the previous lesson shows", 1), ("the previous lesson, *Flyway: Versioned Migrations*, owns the schema", 0),
         ("The URL `jdbc:postgresql://127.0.0.1:20168/u37?user=sa&password=Xy12` is printed.", 1), ("It ran `select pg_sleep(30)`.", 1),
         ("A restart costs no row.", 0), ("it saves time", 1), ("`Run: 1` and `Previously run: 2`", 1), ("Liquibase's `Run:` line", 0)]
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
SKIP_ON = ("<!-- values: begin -->", "<!-- compare table: begin -->", "<!-- runs: begin -->")
SKIP_OFF = ("<!-- values: end -->", "<!-- compare table: end -->", "<!-- runs: end -->")
for p in sys.argv[2:]:
    fence = False; vals = False; para = []; start = 0
    for i, l in enumerate(open(p, encoding="utf-8"), 1):
        mk = l.strip() in SKIP_ON + SKIP_OFF
        brk = l.startswith("```") or mk or not l.strip() or l.startswith(("#", "- ", "| "))
        if brk or fence or vals:
            if para: judge(p, start, para); para = []
        if l.startswith("```"): fence = not fence; continue
        if l.strip() in SKIP_ON: vals = True; continue
        if l.strip() in SKIP_OFF: vals = False; continue
        if fence or vals or not l.strip(): continue
        if not para: start = i
        para.append(l)
    if para: judge(p, start, para)
print("self-test: %d cases · refused: %d" % (len(CASES), n))
