"""Unit 39's prose gate, per sentence (python3 -I -B harness/s39.py harness/dur7.py FILE...), with a self-test that must pass first.
Carried from unit 38's s38 (dur7's words, S4.7's duration meanings, R.301's cost family, R.190, R.224, R.302's typed md5s, jars and
counts, a password in a URL, R.313's history table, R.314's database, "Hibernate generates" never), with unit 39's own (Sections 6-7's
rules): R.335 inverted - "TiffinBox runs on PostgreSQL" is said FROM THIS UNIT, but only scoped (the config tree's URL, the dev profile,
its own driver - RED #1807), never "by default", and "+ the harness's driver" never (39's jar holds its own); a sentence that says
Kavya stays, survives or is kept names PostgreSQL and its scope, or says the default forgets her (RED #1807); R.334 "the tests need
Docker" unscoped (18 do not); R.321 a typed 21 or 19 as a test count (Surefire's reports say them, the values block quotes them);
R.320 getQueryExecutionCount() named as the shipped counter (only as the plant, the wrong counter, green, or the exercise's broken
test); R.319 a raw five-digit port in the 30000s (Testcontainers' port is OrbStack's, masked as <port>); R.325 tiffinbox.jdbc-url's
value said to be the database used (Hibernate's HHH10001005 URL says which database answered); "quick", "fast", "a few seconds".
Lines inside a fenced block and the values block are the runs' own text (receipts.sh checks them) and are not judged here; nor is a
`code span` (a quoted token: a plant's text, a log line) - the password, md5, port and driver checks read the raw sentence, code spans
included."""
import importlib.util, re, sys
spec = importlib.util.spec_from_file_location("dur7", sys.argv[1]); m = importlib.util.module_from_spec(spec); spec.loader.exec_module(m)
FAM = re.compile(r"\b(?:forever|for ever|at once|immediately|instantly|instant(?:ly)?|right away|in no time|a moment|momentar(?:y|ily)|"
                 r"(?:one|two|three|four|five|six|seven|eight|nine|ten|\d+)\s+(?:second|minute|hour)s?|half a second|eventually|"
                 r"a\s+(?:second|minute|hour)\b(?!-level|\s+`|\s+(?:connection|copy|run|JVM|database|read|request|time|start|look|migration|folder|file|statement|line|row|step|seed|table|class|set|key|harness|half|tree|plain|second)))\b", re.I)
NUM = r"(?:\d+|one|two|three|four|five|six|seven|eight|nine|ten|eleven|twelve|thirteen|fourteen|fifteen|twenty|thirty|fifty|a hundred|[NT])"
COST = re.compile(r"\b(?:costs?|costly|costing)\b", re.I)
TM = re.compile(r"\b(?:costs?|costly|costing|cheaper|cheap|expensive|saves? time|sav(?:es|ing) time|takes? longer|time-?consuming|round[- ]trips?)\b"
                rf"|\b{NUM}\s+times\b", re.I)
COUNT = re.compile(r"\b(?:statements?|SQL lines?|connections?|rows?|lines?|migrations?|JVMs?)\b", re.I)
SPEED = re.compile(r"\b(?:slow(?:er|ly)?|quick(?:er|ly)?|lag|faster|fast)\b", re.I)
T18 = re.compile(r"\b18(?:/18| tests)\b[^.;]*\b(?:prove|proves|show(?:s)? (?:that )?(?:the )?(?:fix|restart|migration|change|Kavya)|witness(?:es)?|caught|catch)\b", re.I)
GUARD = re.compile(r"guard|did not notice|not a witness|never a witness", re.I)
JARS = re.compile(r"\b(?:\d+|one|two|three|four|five|six|seven|eight|nine|ten|eleven|twelve|fourteen)\s+(?:added\s+)?(?:jars?|libraries)\b|\b\d{1,3}(?:,\d{3})+ (?:B|bytes)\b|\b\d+(?:\.\d+)? ?(?:MB|KB|kB|MiB|KiB)\b", re.I)
PWD = re.compile(r"password=(?!<pw>|\*)|\?user=sa&password=[^<*]", re.I)
HASH = re.compile(r"\b[0-9a-f]{32}\b|\b7f6942f0|\b466c20ed|\bf4f15b9c|\b(?:md5|hash) [0-9a-f]{6,}", re.I)
FLYRAN = re.compile(r"\bFlyway (?:ran|runs|applied|migrated|ran the migrations)\b|\bthe migrations? (?:ran|run once|applied)\b|\bmigrations? (?:were|was) applied\b", re.I)
HISTORY = re.compile(r"\bhistory\b|flyway_schema_history", re.I)
REPAIRW = re.compile(r"\brecords? (?:the |a )?fail\w*|\brun (?:a )?repair\b|\brepair\(\)|\brepair is needed\b|\bneeds? (?:a )?repair\b|\bhalf-applied\b|success=FALSE", re.I)
RECORDW = re.compile(r"\brecords? (?:the |a )?fail\w*|\brepair is needed\b|\bneeds? (?:a )?repair\b|\brun (?:a )?repair\b|\bhalf-applied\b|success=FALSE", re.I)
NEG = re.compile(r"\bno row\b|\bnothing to repair\b|\brecords no\b|\bnever\b|\bnot\b|\bno\b", re.I)
H2 = re.compile(r"\bH2\b")
PGS = re.compile(r"\bPostgreSQL\b")
RUNSPG = re.compile(r"\bTiffinBox runs on PostgreSQL\b", re.I)
TBPG = re.compile(r"\bTiffinBox\b[^.;]*\bon PostgreSQL\b[^.;]*\b(?:start|starts|started|restart|restarts|keeps|survives|runs|ran)\b|\b(?:start|restart)s? (?:of )?TiffinBox on PostgreSQL\b", re.I)
DRIVER = re.compile(r"the harness's driver")
PGSCOPE = re.compile(r"config tree|dev profile|its own driver|the same database|Compose|its URL in|a container")
PGDEF = re.compile(r"\bTiffinBox\b[^.;]*\bon PostgreSQL by default\b|\bPostgreSQL (?:is|becomes) (?:TiffinBox's )?(?:the )?default\b", re.I)
HDRV = re.compile(r"\+ the harness's driver")
KAVYA = re.compile(r"\bKavya\b[^.;]*\b(?:stays|survives|is kept|is still there|still there|comes back)\b|\bkeeps? (?:Kavya|her|a customer)\b", re.I)
FORGET = re.compile(r"\bforgets?\b|\bdefault\b[^.;]*\b(?:loses|404)\b", re.I)
NEEDD = re.compile(r"\b(?:the |TiffinBox's |its |all )?tests? (?:need|needs|require|requires) Docker\b", re.I)
DSCOPE = re.compile(r"\bcontainer\b|\bthree\b|\b3\b|\bverify\b|\*IT\b|\bIT\b")
T21 = re.compile(r"\b(?:21|19|twenty-one|nineteen)(?: tests?| passed| pass)\b|\b18 \+ [13] = (?:21|19)\b", re.I)
QEC = re.compile(r"getQueryExecutionCount")
QSCOPE = re.compile(r"plant|green|wrong|never|\bnot\b|exercise|passes|broken|README's test|leaves out|instead", re.I)
PORT = re.compile(r"(?<![0-9.])3[0-9]{4}(?![0-9])")
JURL = re.compile(r"tiffinbox\.jdbc-url")
USED = re.compile(r"\b(?:the database (?:used|that answered|TiffinBox uses)|which database answered|connected to|answers?)\b", re.I)
JSCOPE = re.compile(r"\bnot\b|\bnever\b|whatever|still (?:says|prints)|two URLs|HHH10001005", re.I)
GEN = re.compile(r"\bHibernate generates\b", re.I)
EVERY = re.compile(r"\b(?:every|each|all) (?:query|queries|select|read|statement)s?\b[^.;]*\b(?:hides?|filters?|skips?|excludes?|leaves? out)\b[^.;]*\b(?:deleted|removed)\b|\b(?:deleted|removed) rows? (?:are|is) (?:hidden|filtered|invisible) (?:from|in|to) (?:every|each|all)\b", re.I)
SCOPE = re.compile(r"Hibernate writes|\bnative\b|\bnot\b|\bnever\b", re.I)
WHERE = re.compile(r"@Where\b")
GONE = re.compile(r"\b(?:gone|absent|removed|no longer|not in|0 files|missing|deleted from)\b|`?Where\.class`? 0", re.I)
SAFE = re.compile(r"\b(?:audit(?:ed|ing)? (?:fields?|columns?|stamps?)|stamps?|created_at|createdAt|creation stamp)\b[^.;]*\b(?:cannot|can't|can never|never) be (?:lost|wiped|erased|overwritten|nulled)\b", re.I)
HSTAMP = re.compile(r"\bHibernate (?:stamps|fills (?:in )?the stamps|sets the stamps|writes the stamps)\b", re.I)
SEEDED = re.compile(r"\bseeded (?:rows?|customers?|four)\b[^.;]*\b(?:are stamped|have (?:their )?stamps|carry (?:their |both )?stamps|both stamps set|got stamps)\b", re.I)
NEGS = re.compile(r"\b(?:no|not|never|none|without)\b", re.I)
TYPED = re.compile(r"\b(?:\d+|one|two|three|four|five|six|seven|eight|nine|ten|eleven|twelve)\s+(?:statement kinds|kinds of statements?|history rows|rows in the history|SQL lines|words)\b", re.I)
TITLES = ["AOT Processing and Native Image", "Docker Compose for Development", "Testing the Web Layer", "N+1, Measured", "Testcontainers vs H2, Honestly", "The Persistence Layer",
          "REST APIs Done Right", "Pagination, Filtering and Sorting as an API Concern", "Testing Spring Apps", "Spring Data beyond JPA",
          "What's Next: Not Everything Is a Relation", "Ids and Generation Strategies", "Optimistic Locking with At-Version", "Optimistic Locking with @Version", "Reading the SQL Hibernate Writes",
          "Never Use ddl-auto in Production", "Liquibase, and Choosing", "Flyway: Versioned Migrations", "Dates, Times and Zones", "Spring Security — complete", "Aggregates, Not Entities", "Capstone: TiffinBox on Postgres", "Auditing and Soft Deletes", "Expand-contract",
          "Zero-Downtime Deploys", "SQL in 15 Minutes: TiffinBox Tables in H2", "Database Migrations in a Pipeline", "Ship It & Observe"]
CALLED = re.compile(r"\b(?:the )?lessons? called\b|\bCourse (?:2|5|6|8|9|10|11|18)\b", re.I)


def verdicts(s, raw=None):
    out = []
    raw = s if raw is None else raw
    for w in m.DUR.finditer(s): out.append("dur7: " + w.group(0))
    for w in FAM.finditer(s): out.append("S4.7's family: " + w.group(0))
    hits = [w.group(0) for w in TM.finditer(s)]
    if hits and not (all(COST.fullmatch(h) for h in hits) and COUNT.search(s)): out.append("R.301's family: " + ", ".join(hits))
    for w in SPEED.finditer(s):
        if not m.DUR.search(w.group(0)): out.append("a speed word: " + w.group(0))
    if T18.search(s) and not GUARD.search(s): out.append("R.190: the 18 tests as a witness")
    if JARS.search(s): out.append("R.302: a jar or byte count typed: " + JARS.search(s).group(0))
    if PWD.search(raw): out.append("a password in prose")
    if HASH.search(raw): out.append("R.302/R.252: a typed md5: " + HASH.search(raw).group(0))
    if FLYRAN.search(s) and not HISTORY.search(raw): out.append("R.313: a migration claim without the history table: " + FLYRAN.search(s).group(0))
    if REPAIRW.search(s) and not H2.search(s): out.append("R.314: a failed-migration claim without its database: " + REPAIRW.search(s).group(0))
    if PGS.search(s) and RECORDW.search(s) and not H2.search(s) and not NEG.search(s): out.append("R.314: H2's failure story on a PostgreSQL sentence")
    if PGS.search(s) and RECORDW.search(s) and not NEG.search(s) and re.search(r"PostgreSQL (?:records|keeps|needs)", s): out.append("R.314: PostgreSQL said to record the failure")
    if (RUNSPG.search(s) or TBPG.search(s)) and not PGSCOPE.search(raw): out.append("R.335/RED #1807: TiffinBox on PostgreSQL, unscoped (the config tree's URL or the dev profile)")
    if PGDEF.search(s): out.append("R.335/RED #1807: TiffinBox on PostgreSQL by default (the default URL is H2 in memory)")
    if HDRV.search(raw): out.append("R.335: + the harness's driver - this unit's jar holds its own")
    if KAVYA.search(s) and not (PGS.search(s) and PGSCOPE.search(raw)) and not FORGET.search(s): out.append("RED #1807: Kavya said to stay, unscoped")
    if NEEDD.search(s) and not DSCOPE.search(raw): out.append("R.334: the tests said to need Docker, unscoped (18 do not)")
    if T21.search(s): out.append("R.321: a typed test count: " + T21.search(s).group(0))
    if QEC.search(raw) and not QSCOPE.search(raw): out.append("R.320: getQueryExecutionCount() as the counter (the shipped test asserts getPrepareStatementCount())")
    if PORT.search(raw): out.append("R.319: a raw port: " + PORT.search(raw).group(0))
    if JURL.search(raw) and USED.search(s) and not JSCOPE.search(raw): out.append("R.325: tiffinbox.jdbc-url said to be the database used")
    if GEN.search(s): out.append("§Voice: \"Hibernate generates\"")
    if EVERY.search(s) and not SCOPE.search(raw): out.append("R.323: every query said to hide deleted rows, unscoped (the native query returns them)")
    if WHERE.search(raw) and not GONE.search(raw): out.append("R.323: @Where credited (Where.class: 0 files in 7.4.13's jar)")
    if SAFE.search(s): out.append("R.324: audited fields said to be safe (the merge writes NULL)")
    if HSTAMP.search(s): out.append("Hibernate said to stamp (Spring Data's listener fills the stamps)")
    if SEEDED.search(s) and not NEGS.search(s): out.append("the seeded rows said to be stamped (they are NULL)")
    if TYPED.search(s): out.append("R.302: a typed count: " + TYPED.search(s).group(0))
    if CALLED.search(s) and not any(t in raw for t in TITLES): out.append("R.224: a call-back without its title")
    return out


CASES = [("Flyway applies them instantly.", 1), ("It starts quick.", 1), ("at once", 1), ("a second connection reads the history table", 0),
         ("It took 26 milliseconds.", 1), ("Flyway's execution time is 26 ms.", 1),
         ("18/18 proves the migration works.", 1), ("18/18 on after/: a guard, never a witness.", 0),
         ("Flyway ran.", 1), ("Flyway ran: the history table holds two rows, success t.", 0),
         ("Flyway records the failed migration, so run repair.", 1), ("On PostgreSQL Flyway records the failed migration.", 1),
         ("On H2 Flyway records the failed migration (success=FALSE) and the column stays: the hand cleanup and repair() apply it.", 0),
         ("On PostgreSQL the failed migration is rolled back whole and the history table has no row for it - nothing to repair.", 0),
         ("TiffinBox runs on PostgreSQL now.", 1), ("TiffinBox starts on PostgreSQL and keeps Kavya.", 1),
         ("TiffinBox runs on PostgreSQL through the config tree's URL or the dev profile, with its own driver.", 0),
         ("TiffinBox on PostgreSQL + the harness's driver keeps Kavya across the restart.", 1), ("TiffinBox runs on PostgreSQL by default.", 1),
         ("Kavya stays.", 1), ("On PostgreSQL — the config tree's URL or the dev profile — Kavya stays.", 0), ("The default in-memory run forgets her, by design.", 0),
         ("The tests need Docker.", 1), ("The three container tests need Docker; mvn package does not.", 0),
         ("The build runs 21 tests.", 1), ("18 + 3 = 21 tests pass.", 1), ("Which tests run where: 18 on H2 in memory, 3 on PostgreSQL in a container.", 0),
         ("The test asserts `getQueryExecutionCount()` is one.", 1), ("With `getQueryExecutionCount()` the same N+1 plant stays green.", 0),
         ("Testcontainers mapped port 32768.", 1), ("The port is masked as `<port>`.", 0),
         ("`tiffinbox.jdbc-url` is the database that answered.", 1), ("Hibernate's `HHH10001005` URL says which database answered; `tiffinbox.jdbc-url` still says H2.", 0),
         ("Course 11 picks it up.", 1), ("Course 11's *Testcontainers vs H2, Honestly* picks it up.", 0),
         ("The test starts in a few seconds.", 1), ("The script is f4f15b9c71145930e75568c4e64ab595.", 1),
         ("Hibernate generates the schema.", 1), ("Hibernate's script is unchanged.", 0),
         ("The jar holds 94 libraries.", 1), ("The hash is 7f6942f0ed8bf296d661f629557f26c6.", 1),
         ("as the lesson called Ids said", 1), ("as the lesson called `Ids and Generation Strategies` showed", 0),
         ("Course 18 names it.", 1), ("Course 18's lesson called Expand-contract names it.", 0),
         ("The URL `jdbc:postgresql://127.0.0.1:20158/u36?user=sa&password=Xy12` is printed.", 1), ("Flyway masks it: `password=********`.", 0),
         ("And the index costs every insert one more write.", 1), ("A restart costs no row.", 0),
         ("Every query hides deleted rows.", 1), ("Every query filters deleted rows.", 1), ("Every query Hibernate writes hides the deleted rows; a native query does not.", 0),
         ("Use `@Where` for the filter.", 1), ("`@Where` is gone from Hibernate 7.4.13's jar (`Where.class` 0).", 0),
         ("Audited fields cannot be lost.", 1), ("The creation stamp can never be overwritten.", 1), ("A merge can write NULL over the creation stamp.", 0),
         ("Hibernate stamps both columns.", 1), ("Spring Data's listener stamps both columns.", 0),
         ("The seeded rows have stamps.", 1), ("The four seeded rows have no stamps.", 0),
         ("The clause is in 8 statement kinds.", 1), ("The history holds 3 history rows.", 1), ("The exercise line is 19 words.", 1), ("Each kind is a cell line.", 0),
         ("TiffinBox runs on PostgreSQL after the change.", 1)]
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
        mk = l.strip() in ("<!-- values: begin -->", "<!-- values: end -->", "<!-- cells: begin -->", "<!-- cells: end -->")
        brk = l.startswith("```") or mk or not l.strip() or l.startswith(("#", "- ", "| "))
        if brk or fence or vals:
            if para: judge(p, start, para); para = []
        if l.startswith("```"): fence = not fence; continue
        if l.strip() in ("<!-- values: begin -->", "<!-- cells: begin -->"): vals = True; continue
        if l.strip() in ("<!-- values: end -->", "<!-- cells: end -->"): vals = False; continue
        if fence or vals or not l.strip(): continue
        if not para: start = i
        para.append(l)
    if para: judge(p, start, para)
print("self-test: %d cases · refused: %d" % (len(CASES), n))
