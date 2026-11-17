"""Unit 38's prose gate, per sentence (python3 -I -B harness/s38.py harness/dur7.py FILE...), with a self-test that must pass first.
Carried from unit 36's s36 (below, its own words), and unit 38's own (R.323, R.324): "every query hides/filters deleted rows" unscoped
(the native query returns the deleted row - a sentence naming every query must say "Hibernate writes" or name the native query);
@Where credited as a 7.4 API (a sentence naming it must say it is gone: absent, removed, 0, not in the jar); "audited fields cannot be
lost" and its kin; "Hibernate stamps" (Spring Data's listener fills the stamps); a sentence saying the seeded rows carry stamps;
a typed count of statement kinds, rows, history rows or words (R.302: the values block says them).
Carried from unit 34's s34: dur7's words (R.172), S4.7's duration meanings (R.264) - with the brief's "quick", "instantly", "at once" -,
R.190 (the eighteen tests as a witness), R.224 (a call-back by its title), R.301 (BLUE's tm.py family: cost words only in a sentence
naming a printed count), R.302 (a typed md5, a jar or byte count), a password in a URL. Unit 36's own (Sections 6-7's rules):
R.313 - a migration claim ("Flyway ran", "the migrations ran", "Flyway applied") only in a sentence that names the history table;
R.314 - a failed-migration claim ("records the failed migration", "run repair", "repair()") names its database: H2 in the sentence, and a
sentence naming PostgreSQL never says Flyway records the failure or that a repair is needed (unless it says it does not);
R.335 - "TiffinBox runs on PostgreSQL" (and "TiffinBox on PostgreSQL" claims of a start or a restart) only with "+ the harness's driver"
or "the harness's driver" in the sentence, and the bare claim never; "Hibernate generates" never (contract §Voice). Lines inside a
fenced block and the values block are the runs' own text (receipts.sh checks them) and are not judged here; nor is a `code span`
(a quoted token: a plant's text, a log line) - the password, md5 and driver checks read the raw sentence, code spans included."""
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
HASH = re.compile(r"\b[0-9a-f]{32}\b|\b7f6942f0|\b466c20ed|\b(?:md5|hash) [0-9a-f]{6,}", re.I)
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
TITLES = ["Ids and Generation Strategies", "Optimistic Locking with At-Version", "Optimistic Locking with @Version", "Reading the SQL Hibernate Writes",
          "Never Use ddl-auto in Production", "Liquibase, and Choosing", "Flyway: Versioned Migrations", "Dates, Times and Zones", "Spring Security — complete", "Aggregates, Not Entities", "Capstone: TiffinBox on Postgres", "Auditing and Soft Deletes", "Expand-contract",
          "Zero-Downtime Deploys", "SQL in 15 Minutes: TiffinBox Tables in H2", "Database Migrations in a Pipeline", "Ship It & Observe"]
CALLED = re.compile(r"\b(?:the )?lessons? called\b|\bCourse (?:2|8|10|18)\b", re.I)


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
    if RUNSPG.search(s): out.append("R.335: \"TiffinBox runs on PostgreSQL\" before the capstone")
    if TBPG.search(s) and not DRIVER.search(raw): out.append("R.335: TiffinBox on PostgreSQL without the harness's driver")
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
         ("TiffinBox on PostgreSQL + the harness's driver keeps Kavya across the restart.", 0),
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
