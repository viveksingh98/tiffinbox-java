#!/bin/bash
XPATH=$PATH                                           # the PATH you started this with: the exercise's own shells get it
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25.0.4.1 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# Course 7 · Lazy Loading and LazyInitializationException - this unit's receipts. Section 5's first unit and its first change to the
# anchor (brief flag 1, C1), the course's tenth: before/ is the link to ../c7-unit27/after; after/ is this unit's tree and
# ../c7-tiffinbox equals it (unit 30 measures it through a link; unit 31 moves the anchor next). CustomerRepository gains
# pausedDaysByCustomer() with @Transactional(readOnly = true); Dashboard.load() runs it as a fourth read; the HTML dashboard gains a
# "Paused days" column. Seven captures, each run three times and hashed; a hash that differs from receipts.md5 stops the run; every
# number and string the video says is asserted right after its capture by a check that can fail. One database: H2 - in the harness
# JVM's memory, and for TiffinBox an H2 TCP server on 127.0.0.1:20088 (only local connections), so a second connection (H2's own
# Shell) reads the same database the running TiffinBox reads.
#   lazy      the placeholder (harness, after/'s libraries): findAll(Sort.by("name")) outside a transaction - one statement, the
#             pauses a PersistentBag not yet read, the read refused; getReferenceById(3) - a proxy, getId() with no statement,
#             getName() refused; a pause's customer the same
#   anchor    the change (after/ against before/), the sentences it rewrote (R.250); TiffinBox B/A/A' (S5.15): B = after/ without
#             the read's transaction (labelled) - the dashboard 500 with its cause bound per request, the seven's dashboard line,
#             its tests 18/18 (a guard); the H2 user trap (labelled: no username - the start fails); A = after/ - 200, the
#             "Paused days" column parsed by its header and compared row by row with the second connection; A' built again
#   wrong     the four wrong fixes, each with its cost (S5.3, S5.14, S5.16, S5.20): (a) open-in-view on B + a request-thread route,
#             and the control without the flag; the held connection (harness); (b) EAGER (labelled) + harness; (c)
#             enable_lazy_load_no_trans on B + harness; (d) the controller's transaction - the final class's refusal (its own
#             step), then un-finaled; (e) the read's own transaction and Hibernate.initialize (harness)
#   seven     before/'s jar and after/'s, the seven each (a guard, R.190)
#   tests     TiffinBox's tests on after/ (the README's line, offline), from Surefire's reports (C7-4); B's reports beside them
#   xcheck    the harness's DDL script over after/'s libraries = ../c7-unit27/xcheck.sql, filed here too (no mapping moved)
#   exercise  exercise/README.md's commands, then exercise/SOLUTION.md's, read from the files and run as written, in ONE env -i
#             shell - /bin/bash, then again in /bin/zsh -f; each file's "What it prints" block = what it printed
# Every tree is COPIED under .harness/ and built there, never in place, with the README's package line, offline. The labelled copies
# are after/ with harness/derive.py's named edits; each copy's diff from after/ is printed whole. The harness (harness/src, packages
# probe.u and probe.x, outside com.tiffinbox) is compiled once with javac -parameters against after/'s extracted libraries.
# Counts (S5.1, the brief's flag 3): Hibernate's Statistics, the SQL logger's events and a JDBC proxy, side by side, per step; on
# TiffinBox, the SQL logger's lines between two markers this script appends to the JVM's log around each request (never a whole
# log's). Every JVM runs under an alarm (perl -e 'alarm N; exec ...'); an alarm that fires is a failed receipt (R.247). Ports (§P,
# 20080-20089): 20080 B (and the seven's before/) · 20081 the H2 user trap (binds none) and A (and the seven's after/) · 20082 A' ·
# 20083 (a) with the flag, its route in the same JVM · 20084 (a)'s control · 20085 (b) · 20086 (c) · 20087 (d) (the refusal binds
# none; the un-finaled copy listens there) · 20088 the H2 TCP server · 20089 never bound. Nothing leaves the machine.
shopt -u patsub_replacement 2> /dev/null || true
export LC_ALL=C
cd "$(dirname "$0")"
mkdir .r-lock 2> /dev/null || { echo "  *** another receipts.sh is running in this folder (.r-lock exists) - if none is, rmdir .r-lock ***"; exit 1; }
U="$PWD"; UP="$(cd .. && pwd)"; ME="$(id -un)"; G=/usr/bin/grep
# On every exit - the end, a failed check, or Ctrl-C - stop what this script started in the background, if it still runs: $pid (a
# JVM), $lpid (the feed's listener, a curl), $mpid (a Maven or a javac, with every process under it), $xpid (an exercise shell, with
# every process under it); then sweep(): anything of this run still alive in its process group is stopped. After an interrupt a
# capture's unfinished runs (.r-NAME.1-3) go too; after a failed check they stay. The clean-up ignores a second Ctrl-C; the script
# exits 130 after an interrupt. No wait in this script is bare.
pid=""; lpid=""; mpid=""; xpid=""; spid=""
sweep() { local g i l
  g=$(ps -o pgid= -p $$ 2> /dev/null | tr -d ' ') || g=""
  [ -n "$g" ] || return 0
  i=0; while [ $i -lt 20 ]; do
    l=$(ps -axo pid=,pgid=,command= 2> /dev/null | awk -v g="$g" -v me=$$ '
      $2 == g && $1 != me && $3 != "awk" && $3 != "ps" && (index($0, "probe.u.") || index($0, "probe.x.") || index($0, "org.h2.tools.") || index($0, "tiffinbox-web-1.0.0.jar") || index($0, "/customers/feed") || index($0, "surefirebooter") || $3 ~ /(^|\/)javac$/ || index($0, "jdk.compiler/com.sun.tools.javac") || index($0, "org.codehaus.plexus.classworlds.launcher.Launcher")) { print $1 }' | paste -sd' ' -) || l=""
    [ -n "$l" ] || return 0
    if [ $i -lt 10 ]; then kill $l 2> /dev/null || true; else kill -9 $l 2> /dev/null || true; fi
    sleep 0.5; i=$((i + 1)); done; }
desc() { ps -axo pid=,ppid= 2> /dev/null | awk -v r="$1" '{ p[$1] = $2 } END { n = 1; q[1] = r; for (i = 1; i <= n; i++) for (c in p) if (p[c] == q[i]) { q[++n] = c; print c } }'; }
killtree() { local d; d=$(desc "$1"); kill "$1" $d 2> /dev/null || true; }
trap 'trap "" INT TERM; for p in "$mpid" "$xpid"; do [ -z "$p" ] || killtree "$p"; done; for p in "$pid" "$lpid" "$mpid" "$xpid" "$spid"; do if [ -n "$p" ] && kill "$p" 2> /dev/null; then wait "$p" 2> /dev/null || true; fi; done; sweep || true; [ -z "$INTR" ] || rm -f .r-*.[123]; rmdir .r-lock 2> /dev/null || true' EXIT
INTR=""; trap 'INTR=1; exit 130' INT TERM
exec 3>&1                                            # die() speaks to the terminal even inside a redirected capture
die() { echo "  *** $* ***" >&3; exit 1; }
java -version 2>&1 | $G -q 'version "25' || die "JDK 25 needed; JAVA_HOME gives: $(java -version 2>&1 | head -1)"
javac -version 2>&1 | $G -q '^javac 25' || die "javac 25 needed (the harness is compiled with it)"
for t in python3 perl rsync lsof mvn md5 cmp find curl openssl javap /bin/zsh; do command -v $t > /dev/null || die "$t is needed"; done
# A variable of yours must not become a property source, a JVM flag or a build setting (a canary planted under every name first)
for v in TIFFINBOX_CANARY SPRING_CANARY MANAGEMENT_CANARY SERVER_CANARY LOGGING_CANARY PROBE_CANARY DEBUG JAVA_TOOL_OPTIONS JDK_JAVA_OPTIONS _JAVA_OPTIONS MAVEN_ARGS; do export "$v=planted-canary"; done
for v in $(env | sed -n -E 's/^(TIFFINBOX_[A-Za-z0-9_]*|SPRING_[A-Za-z0-9_]*|MANAGEMENT_[A-Za-z0-9_]*|SERVER_[A-Za-z0-9_]*|LOGGING_[A-Za-z0-9_]*|PROBE_[A-Za-z0-9_]*|DEBUG|JAVA_TOOL_OPTIONS|JDK_JAVA_OPTIONS|_JAVA_OPTIONS|MAVEN_ARGS)=.*/\1/p'); do unset "$v"; done
[ -z "$(env | $G -- '=planted-canary$')" ] || die "a variable survived the clean-up above: $(env | $G -- '=planted-canary$' | sed 's/=.*//' | paste -sd' ' -)"
export no_proxy="127.0.0.1,localhost${no_proxy:+,$no_proxy}" NO_PROXY="127.0.0.1,localhost${NO_PROXY:+,$NO_PROXY}"
[ -e secrets ] && die "this folder holds a secrets/ - the token lives under .harness/ only"
[ -L before ] && [ "$(readlink before)" = ../c7-unit27/after ] || die "before must be the link to ../c7-unit27/after - the anchor before this change"
[ -d after ] && [ ! -L after ] || die "after/ must be this unit's own tree, not a link"
for t in before after; do
  [ -f "$t/pom.xml" ] && [ -f "$t/README.md" ] || die "the tree $t (its pom.xml or README.md) is missing"
  [ -e "$t/secrets" ] || [ -e "$t/target" ] || [ -e "$t/tiffinbox-web/target" ] || [ -e "$t/tiffinbox-core/target" ] || [ -e "$t/tiffinbox-local.yaml" ] || [ -e "$t/hibernate-ddl.sql" ] && die "$t holds a secrets/, a target/, a tiffinbox-local.yaml or a hibernate-ddl.sql - it is a frozen copy, never built in place"
  true; done
# after/ is this unit's tree and Section 4's frozen anchor; ../c7-tiffinbox equals it - should a later course change the anchor, a
# note, never a stop (R.211)
[ -d ../c7-tiffinbox ] || die "../c7-tiffinbox is missing"
anchornote() { local d; d=$(diff -rq -x .m2-demo -x target -x secrets -x .harness after ../c7-tiffinbox 2>&1 || true)
  if [ -z "$d" ]; then echo "  the anchor ($1): diff -rq -x .m2-demo -x target -x secrets -x .harness after ../c7-tiffinbox: empty - after/ = ../c7-tiffinbox"
  else echo "  (after/ and ../c7-tiffinbox differ - the anchor has moved past the tree this unit froze: $(printf '%s\n' "$d" | head -3 | paste -sd';' -))" >&3
    echo "  the anchor ($1): after/ is this unit's tree (C1) - a later anchor change has moved ../c7-tiffinbox on"; fi; }
anchornote start
M2="$PWD/.m2-demo"
CJ=tiffinbox-core/src/main/java/com/tiffinbox        # the core module's sources, in a tree
WJ=tiffinbox-web/src/main/java/com/tiffinbox/web     # the web module's
SR=tiffinbox-web/target/surefire-reports
XD=tiffinbox-web/target/extracted                    # the jar, extracted (the anchor's own line), in a tree
TF=secrets/tiffinbox/shutdown-token
CURLSET=../c5-unit11/curlset.sh
[ -x "$CURLSET" ] || die "$CURLSET is missing - the comparison set the seven runs"
HS=harness/src/probe/u
HFILES='derive.py dur7.py logback.xml src surefire.py'
SFILES='probe/u/H.java probe/u/Main.java probe/u/Run.java probe/u/Seed.java probe/u/SqlCounter.java probe/u/Svc.java probe/u/ent/ECustomer.java probe/u/ent/EPause.java probe/u/ex/ExApp.java probe/x/XMain.java'
for f in exercise/README.md exercise/SOLUTION.md README.md receipts.md5 xcheck.sql; do [ -f "$f" ] || die "$f is missing"; done
[ "$(ls harness | paste -sd' ' -)" = "$HFILES" ] && [ "$(cd harness/src && find . -type f | sed 's#^\./##' | sort | paste -sd' ' -)" = "$SFILES" ] || die "harness/ holds another file, or misses one"
[ "$(ls exercise | paste -sd' ' -)" = 'README.md SOLUTION.md' ] || die "exercise/ holds another file"
[ "$(md5 -q harness/dur7.py)" = 41667fed9ffcefe171389eed7e654e66 ] || die "harness/dur7.py is not the builders' dur7.py (md5 41667fed…)"
if [ -f ../../../data-jpa-hibernate/_builders/dur7.py ]; then cmp -s harness/dur7.py ../../../data-jpa-hibernate/_builders/dur7.py || die "harness/dur7.py differs from the builders' _builders/dur7.py"
  echo "  (terminal only) harness/dur7.py = the builders' _builders/dur7.py, byte for byte" >&3
else echo "  (terminal only) the builders' _builders/dur7.py is not beside this clone: its md5 above is the check" >&3; fi
cmp -s harness/surefire.py ../c6-unit28/harness/surefire.py || die "harness/surefire.py is not the testing lesson's (../c6-unit28/harness/surefire.py), byte for byte"
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
PORTS="18425 8080 35729 20080 20081 20082 20083 20084 20085 20086 20087 20088 20089"
for p in $PORTS; do
  [ "$(listeners $p)" = 0 ] || die "something already listens on $p - this unit's ports must be free; if it is a process an interrupted run left behind, stop it: kill $(lsof -nP -iTCP:$p -sTCP:LISTEN -t 2> /dev/null | paste -sd' ' -)"; done
rm -rf .harness; mkdir -p .harness/run .harness/hc

# ---- the prose gates ----------------------------------------------------------------------------------------------------------
SECT=$(awk '/^## Course 7 · unit 29 /{f=1} f && ((/^## / && !/unit 29 /) || /^---$/){f=0} f' after/README.md)
[ -n "$SECT" ] || die "after/README.md has no Course 7 · unit 29 section"
printf '%s\n' "$SECT" > .harness/section.md
PROSE='README.md exercise/README.md exercise/SOLUTION.md .harness/section.md'
# R.172 + S4.7 (R.264): dur7.DUR and the duration-meaning family; R.301 (S5.18): the time-meaning family, BLUE's tm.py - its cost
# words allowed only in a sentence that names a printed count; and this unit's refused readings, per sentence (s29)
cat > .harness/s29.py <<'PY'
import importlib.util, re, sys
spec = importlib.util.spec_from_file_location("dur7", sys.argv[1]); m = importlib.util.module_from_spec(spec); spec.loader.exec_module(m)
FAM = re.compile(r"\b(?:forever|for ever|at once|immediately|instantly|instant(?:ly)?|right away|in no time|a moment|momentar(?:y|ily)|"
                 r"(?:one|two|three|four|five|six|seven|eight|nine|ten|\d+)\s+(?:second|minute|hour)s?|half a second|eventually|"
                 r"a\s+(?:second|minute|hour)\b(?!\s+(?:connection|copy|run|JVM|database|read|request|time|dispatch)))\b", re.I)
NUM = r"(?:\d+|one|two|three|four|five|six|seven|eight|nine|ten|eleven|twelve|thirteen|fourteen|fifteen|twenty|thirty|fifty|a hundred|[NT])"
COST = re.compile(r"\b(?:costs?|costly|costing)\b", re.I)
TM = re.compile(r"\b(?:costs?|costly|costing|cheaper|cheap|expensive|saves? time|sav(?:es|ing) time|takes? longer|time-?consuming|round[- ]trips?)\b"
                rf"|\b{NUM}\s+times\b", re.I)
COUNT = re.compile(r"\b(?:statements?|SQL lines?|connections?|sessions?|rows?|batch(?:es)?|executeBatch|prepareStatement)\b", re.I)
SPEED = re.compile(r"\b(?:slow(?:er|ly)?|quick(?:er|ly)?|lag)\b", re.I)
# R.286 (S5.3): open-in-view's or the controller's verdict, unscoped - a sentence that says one of them fixes or works, and names
# neither the request thread, a route nor the dashboard's 500
FIXER = re.compile(r"\b(?:open-in-view|OpenEntityManagerInView\w*|a transaction on the controller|the controller's transaction|"
                   r"@Transactional on (?:the controller|DashboardPage))\b[^.;]*\b(?:fix(?:es|ed)?|solves?|works|cures?)\b", re.I)
SCOPE = re.compile(r"request(?:'s)? thread|request-thread|/customers/paused|\broute\b|\b500\b|virtual|never|refused|not\b", re.I)
# R.287 (S5.4): Hibernate 5/6's wordings - 7.4.13 prints others
OLD = re.compile(r"failed to lazily initialize|could not initialize proxy - no Session")
# R.190: the 18 tests voiced as a witness
T18 = re.compile(r"\b18(?:/18| tests)\b[^.;]*\b(?:prove|proves|show(?:s)? (?:that )?the (?:fix|page)|witness(?:es)?|caught|catch)\b", re.I)
GUARD = re.compile(r"guard|did not notice|not a witness|never a witness", re.I)
def verdicts(s):
    out = []
    for w in m.DUR.finditer(s): out.append("dur7: " + w.group(0))
    for w in FAM.finditer(s): out.append("S4.7's family: " + w.group(0))
    hits = [w.group(0) for w in TM.finditer(s)]
    if hits and not (all(COST.fullmatch(h) for h in hits) and COUNT.search(s)): out.append("R.301's family: " + ", ".join(hits))
    for w in SPEED.finditer(s): out.append("a speed word: " + w.group(0))
    if FIXER.search(s) and not SCOPE.search(s): out.append("R.286: an unscoped verdict: " + FIXER.search(s).group(0))
    for w in OLD.finditer(s): out.append("R.287: Hibernate 5/6's wording: " + w.group(0))
    if T18.search(s) and not GUARD.search(s): out.append("R.190: the 18 tests as a witness")
    return out
CASES = [("open-in-view fixes it.", 1), ("A transaction on the controller fixes it.", 1),
         ("open-in-view keeps the persistence context on the request thread; on the route it works.", 0),
         ("failed to lazily initialize a collection of role", 1), ("could not initialize proxy - no Session", 1),
         ("Could not initialize proxy [com.tiffinbox.CustomerEntity#3] - no session", 0),
         ("18/18 proves the fix.", 1), ("18/18 on B: the tests did not notice - a guard.", 0),
         ("EAGER costs every list four more statements", 0), ("it is ten times quicker", 1), ("the page is slow", 1),
         ("that costs a lot", 1), ("forever", 1), ("for the whole request", 0), ("at once", 1), ("one second", 1), ("the second connection", 0), ("a second connection reads it", 0), ("wait a second", 1)]
for t, want in CASES:
    assert bool(verdicts(t)) == bool(want), t
n = 0
for p in sys.argv[2:]:
    for i, l in enumerate(open(p, encoding="utf-8"), 1):
        for s in re.split(r"(?<=[.;!?])\s+", l):
            for v in verdicts(s):
                n += 1; print("  %s line %d: %s" % (p, i, v))
print("self-test: %d cases · refused: %d" % (len(CASES), n))
PY
DW=$(python3 -I -B .harness/s29.py harness/dur7.py $PROSE) || die "the prose gate did not run (or its self-test failed)"
printf '%s\n' "$DW" | tail -1 | $G -qxF 'self-test: 19 cases · refused: 0' || die "a refused word or reading in this unit's prose (R.172, S4.7, R.301, R.286, R.287, R.190): $(printf '%s\n' "$DW" | $G ' line ' | head -4 | paste -sd';' -)"
echo "  prose, per sentence (s29, 19-case self-test): dur7 words 0 · S4.7's family 0 · R.301's family 0 (a cost word only beside a printed count) · speed words 0 · R.286 unscoped verdicts 0 · R.287 old wordings 0 · R.190 the tests as a witness 0 - over README.md, exercise/, after/README.md's unit 29 section"
DISH='thali|khichdi|dal|daal|paneer|biryani|roti|chapati|chapatti|naan|sabzi|sabji|idli|dosa|sambar|rasam|rajma|chole|chana|poha|upma|paratha|pulao|pulav|raita|korma|tikka|masala|samosa|pakora|pakoda|halwa|kheer|jalebi|ladoo|laddu|vada|bhaji|aloo|gobi|jain'
dishes() { $G -rniwE -- "$DISH" "$@" 2> /dev/null | cut -c1-160 | head -3 | paste -sd';' - || true; }
DN=$(dishes README.md exercise harness/src .harness/section.md)
[ -z "$DN" ] || die "an Indian dish name (R.215: English names only): $DN"
echo "  dish names: 0 ($(printf '%s\n' "$DISH" | tr '|' '\n' | wc -l | tr -d ' ') refused, whole words, any case, over README.md, exercise/, harness/src and the anchor's unit 29 section)"
PH=$($G -rnE 'EXERCISE-[A-Z-]*OUTPUT|[A-Z]+-OUTPUT\b|[A-Z]+-PARAGRAPH\b|TODO|TBD|PLACEHOLDER' README.md exercise .harness/section.md 2> /dev/null | cut -c1-160 | head -3 | paste -sd';' - || true)
[ -z "$PH" ] || die "a placeholder line in this unit's prose: $PH"
wib() { awk '/^What it prints/ { w = 1; next } w == 1 && /^```$/ { w = 2; next } w == 2 && /^```$/ { exit } w == 2 { print }' "$1"; }
for f in exercise/README.md exercise/SOLUTION.md; do [ "$($G -c '^What it prints' "$f")" = 1 ] && [ -n "$(wib "$f" | $G -v '^ *$' || true)" ] || die "$f must hold one \"What it prints\" line and, under it, a block that is not empty"; done
echo "  placeholders: 0 · each exercise file's \"What it prints\" block not empty"
# R.225: a SQL string this unit shows is the logger's - outside the values block, none in README.md
SQLRE='select ce1_0|from customer ce1_0|from pause p1_0|insert into customer|update customer|select c\.name, coalesce'
TS=$(awk '/^<!-- values: begin -->$/ { v = 1; next } /^<!-- values: end -->$/ { v = 0; next } !v { print NR ": " $0 }' README.md | $G -E "$SQLRE" | cut -c1-160 | head -3 | paste -sd';' - || true)
[ -z "$TS" ] || die "a typed SQL string in README.md (R.225): $TS"
echo "  typed SQL strings: 0 in README.md outside its values block"
# R.250: C1 makes "three reads" false - every sentence that said it, in before/ and in after/ (sources and the anchor's README)
R250='Three database reads|submits all three|all three are finished|all three, or none|three are finished|Dashboard reads three'
OB=$($G -rnE "$R250|^ \* three are finished" before/$CJ/Dashboard.java | wc -l | tr -d ' ')
[ "$OB" = 4 ] || die "R.250: before/'s Dashboard.java must hold the three-reads sentences (4 lines): $OB"
OA=$($G -rnE "$R250|^ \* three are finished" after/$CJ after/$WJ after/tiffinbox-web/src/main/resources after/README.md 2> /dev/null | cut -c1-160 | head -3 | paste -sd';' - || true)
[ -z "$OA" ] || die "R.250: after/ still says three reads: $OA"
$G -q 'Unit 29/31: rows in' before/$CJ/CustomerRepository.java && ! $G -q 'Unit 29/31' after/$CJ/CustomerRepository.java || die "R.250 (RED #1515): CustomerRepository's first Javadoc line must no longer read as Course 7's unit 29"
$G -q "TiffinBox's first {@code @Transactional}, on add (Course 7, unit 29: the second is pausedDaysByCustomer's," after/$CJ/CustomerRepository.java || die "R.250 (RED #1515): \"TiffinBox's first @Transactional\" kept true by naming the second"
[ "$($G -c '^    @Transactional(readOnly = true)$' after/$CJ/CustomerRepository.java)" = 1 ] && [ "$($G -c 'pausedDaysByCustomer' before/$CJ/CustomerRepository.java || true)" = 0 ] || die "C1: after/'s CustomerRepository carries pausedDaysByCustomer's @Transactional(readOnly = true), before/'s no such method"
$G -qF 'List.of(repo::findAll, repo::monthRevenue, repo::pausedDays, repo::pausedDaysByCustomer);' after/$CJ/Dashboard.java && $G -qF 'public View(List<Customer> customers, int monthRevenue, int pausedDays) {' after/$CJ/Dashboard.java || die "C1: after/'s Dashboard runs the fourth read and keeps the three-value constructor"
$G -qF '<th>Paused days</th>' after/tiffinbox-web/src/main/resources/templates/dashboard.html && $G -qF '${view.pausedDaysByName[c.name] ?: 0}' after/tiffinbox-web/src/main/resources/templates/dashboard.html || die "C1: after/'s dashboard.html carries the Paused days column"
echo "  R.250: the three-reads sentences - 4 lines in before/'s Dashboard.java, 0 anywhere in after/ (sources, templates, README); CustomerRepository's first line no longer \"Unit 29/31\", its \"first @Transactional\" names the second; C1's method, read and column in after/"

# ---- the commands: read from after/README.md, the anchor's own, and asserted - each line must be there, whole -------------
readme() { $G -m1 -xF -- "$1" after/README.md > /dev/null || die "after/README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
R_PLAIN=$(readme 'mvn -B package')
R_TEST=$(readme 'mvn -B clean test')
R_EXTRACT=$(readme 'java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted')
R_RUN=$(readme 'java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431')
R_TOKEN=$(readme 'mkdir -p secrets/tiffinbox && (umask 077 && printf '"'"'%s\n'"'"' "$(openssl rand -hex 16)" > secrets/tiffinbox/shutdown-token)')
mine() { $G -m1 -xF -- "$1" README.md > /dev/null || die "README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
JL='-Duser.language=en -Duser.country=US'
AL="perl -e 'alarm 240; exec @ARGV'"
HSRC="$HS/H.java $HS/Main.java $HS/Run.java $HS/Seed.java $HS/SqlCounter.java $HS/Svc.java $HS/ent/ECustomer.java $HS/ent/EPause.java harness/src/probe/x/XMain.java"
L_JAVAC=$(mine "javac -parameters -d .harness/hc -cp \".harness/after/$XD/lib/*\" $HSRC")
L_H=$(mine "$AL java $JL -Dstdout.encoding=UTF-8 \"\${V[@]}\" -cp \"../hc:../after/$XD/lib/*\" probe.u.Main \"\${A[@]}\"")
L_X=$(mine "$AL java $JL -Dstdout.encoding=UTF-8 -cp \"../hc:../after/$XD/lib/*\" probe.x.XMain \"\${A[@]}\"")
L_H2S=$(mine "cd .harness/run && exec perl -e 'alarm 3000; exec @ARGV' java $JL -Dh2.bindAddress=127.0.0.1 -cp \"../after/$XD/lib/h2-2.5.250.jar\" org.h2.tools.Server -tcp -tcpPort 20088 -ifNotExists")
L_SHELL=$(mine "cd .harness/run && $AL java $JL -cp \"../after/$XD/lib/h2-2.5.250.jar\" org.h2.tools.Shell -url \"jdbc:h2:tcp://127.0.0.1:20088/mem:\$DB\" -user sa -password '' -sql \"\$Q\"")
Q_SUM='select c.name, coalesce(sum(p.days),0) from customer c left join pause p on p.customer_id = c.id group by c.name order by c.name'
Q_IDS='select id, name from customer order by name'
TBL=(--spring.datasource.username=sa --logging.level.org.hibernate.SQL=debug --logging.level.org.springframework.orm.jpa.JpaTransactionManager=debug)
off() { local c=${2/mvn -B /mvn -o -B -Dmaven.repo.local=\"\$M2\" }
  [ -n "${3:-}" ] && c=${c/ $3/ clean $3}
  printf 'cd %s && %s\n' "$1" "$c"; }
exe() { printf '%s\n' "$1" | sed -E 's/&& (([A-Z_]+=[^ ]* )*)/\&\& \1exec /'; }
at() { local l=${3/--tiffinbox.port=18431/--tiffinbox.port=$2}; case $l in 'java '*) l="$AL java $JL ${l#java }" ;; esac; printf 'cd %s && %s\n' "$1" "$l"; }
# tb TREE PORT DB [more args]: the README's run line on TREE, its port, TiffinBox's database on the H2 server (mem:DB), sa, the
# SQL logger and the transaction manager's DEBUG lines - every argument quoted
tb() { local t=$1 p=$2 d=$3 a; shift 3; a="'--tiffinbox.jdbc-url=jdbc:h2:tcp://127.0.0.1:20088/mem:$d;DB_CLOSE_DELAY=-1'"
  for x in "${TBL[@]}" "$@"; do a="$a $x"; done; printf '%s %s\n' "$(at .harness/$t $p "$R_RUN")" "$a"; }
[ "$(off .harness/after "$R_PLAIN" package)" = 'cd .harness/after && mvn -o -B -Dmaven.repo.local="$M2" clean package' ] || die "off(): the build line is not the README's package line, offline"
[ "$(exe "$(at .harness/after 20081 "$R_RUN")")" = "cd .harness/after && exec $AL java $JL -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=20081" ] || die "at(): the run line is not the README's"
echo "  the commands: after/README.md gives the $($G -c '^R_[A-Z]*=$(readme ' receipts.sh) lines this script runs; README.md the $($G -c '^L_[A-Z0-9]*=$(mine ' receipts.sh) this unit adds"
JV=$(java -version 2>&1 | sed -n 's/.*version "\([^"]*\)".*/\1/p' | head -1)
echo "  (terminal only) the JDK is $JV - the captures say Java <version>" >&3

# ---- build: before the captures -------------------------------------------------------------------------------------------
# ---- build: before the captures -------------------------------------------------------------------------------------------
NOPLUG='No plugin'' found for prefix'
mbuild() { local how=yes ec=0 c=$1 miss got web
  (eval "$c") > "$2" 2>&1 < /dev/null & mpid=$!; wait "$mpid" || ec=$?; mpid=""
  if [ $ec != 0 ] && $G -qE "offline mode|Could not resolve|could not be resolved|Cannot access|$NOPLUG" "$2"; then
    cp "$2" "${2%.log}-offline.log"
    miss=$($G -oE 'the artifact [^ ]+ has not been downloaded' "$2" | head -1 | sed -E 's/^the artifact ([^ ]+) has not been downloaded$/\1/')
    [ -n "$miss" ] || miss=$($G -oE "Could not find artifact [^ ]+|$NOPLUG [^ ]+|Non-resolvable parent POM for [^ ]+" "$2" | head -1)
    ec=0; (eval "${c/mvn -o -B /mvn -B }") > "$2" 2>&1 < /dev/null & mpid=$!; wait "$mpid" || ec=$?; mpid=""
    got=$(sed -n -E 's/^\[INFO\] Downloaded from ([^ :]+): ([a-z]+):.*/\1 (\2)/p' "$2" | sort | uniq -c | awk '{ printf "%s%s %s %d", (NR > 1 ? ", " : ""), $2, $3, $1 }')
    web=$($G -cE '^\[INFO\] Downloaded from [^ ]+: https?://' "$2" || true)
    how="no - the offline build could not resolve ${miss:-an artifact (none named in its log)} from .m2-demo, so it ran once more without -o; that run downloaded from: ${got:-nothing}; of them over http(s): $web"; fi
  [ $ec = 0 ] || { tail -30 "$2" >&3; die "build failed: $3"; }
  echo "  built $3 · offline: $how · exit $ec · 'Downloaded from' lines in its log: $($G -c '^\[INFO\] Downloaded from ' "$2" || true)"; }
summ4() { $G -E '^\[(INFO|WARNING|ERROR)\] Tests run: [0-9]+, Failures: [0-9]+, Errors: [0-9]+, Skipped: [0-9]+$' "$1" | sed -E 's/.*Tests run: ([0-9]+), Failures: ([0-9]+), Errors: ([0-9]+), Skipped: ([0-9]+)$/\1 \2 \3 \4/' | awk '{ a += $1; b += $2; c += $3; d += $4 } END { print a + 0, b + 0, c + 0, d + 0 }'; }
JE=""
jc() { local ec=0; (eval "$1") > "$2" 2>&1 < /dev/null & mpid=$!; wait "$mpid" || ec=$?; mpid=""; JE=$ec; }
copy() { rsync -a --exclude target --exclude secrets --exclude .m2-demo "$1/" "$2/"; }
copy before .harness/before; copy after .harness/after
# the labelled copies: after/ with derive.py's named edits (harness/derive.py; each copy's diff from after/ printed in its capture)
L_DERIVE=$(mine 'python3 -I harness/derive.py .harness/anb notx')
derive() { local t=$1; shift; copy after .harness/$t; python3 -I harness/derive.py .harness/$t "$@" > /dev/null || die "derive.py $t $*: an edit did not apply"; }
derive anb notx; derive anr notx route; derive ane notx eager; derive and1 notx pagetx; derive and2 notx route pagetx routetx unfinal
copy after .harness/ana2
[ "$(diff -rq .harness/after .harness/anb | sed 's#\.harness/##g')" = "Files after/$CJ/CustomerRepository.java and anb/$CJ/CustomerRepository.java differ" ] || die "B's copy must differ from after/ by CustomerRepository.java alone"
mbuild "$(off .harness/before "$R_PLAIN" package) -DskipTests" .harness/build-before.log ".harness/before (before/, the README's package line, -DskipTests: its tests are unit 27's)"
mbuild "$(off .harness/after "$R_PLAIN" package)" .harness/build-after.log ".harness/after (after/, the README's package line; its tests ran)"
[ "$(summ4 .harness/build-after.log)" = '18 0 0 0' ] || die "after/'s tests: $(summ4 .harness/build-after.log) - expected 18 0 0 0"
mbuild "$(off .harness/anb "$R_PLAIN" package)" .harness/build-anb.log ".harness/anb (B, labelled: the read with no transaction; the README's package line, its tests ran)"
[ "$(summ4 .harness/build-anb.log)" = '18 0 0 0' ] || die "B's tests: $(summ4 .harness/build-anb.log) - the tests did not notice: expected 18 0 0 0"
for t in ana2 anr ane and1 and2; do mbuild "$(off .harness/$t "$R_PLAIN" package) -DskipTests" .harness/build-$t.log ".harness/$t (labelled; the same line, -DskipTests)"; done
for t in before after anb ana2 anr ane and1 and2; do (cd .harness/$t && eval "$R_EXTRACT") > .harness/extract-$t.log 2>&1 < /dev/null || die "the extract of $t failed: $(tail -3 .harness/extract-$t.log)"; done
for a in org/springframework/boot/spring-boot-starter-parent/4.1.2/spring-boot-starter-parent-4.1.2.pom org/hibernate/orm/hibernate-core/7.4.13.Final/hibernate-core-7.4.13.Final.jar org/springframework/data/spring-data-jpa/4.1.2/spring-data-jpa-4.1.2.jar org/springframework/spring-tx/7.0.10/spring-tx-7.0.10.jar com/h2database/h2/2.5.250/h2-2.5.250.jar; do
  [ -e "$M2/$a" ] || die "$a is not in .m2-demo - README.md, The repository"; done
(cd .harness/after && eval "$R_TOKEN") || die "the token was not written"
TOKEN=$(head -n 1 .harness/after/$TF); [ ${#TOKEN} = 32 ] || die "the generated token is not 32 characters"
for t in before anb ana2 anr ane and1 and2; do mkdir -p .harness/$t/secrets/tiffinbox && (umask 077 && cp .harness/after/$TF .harness/$t/$TF); done
for t in before after anb ana2 anr ane and1 and2; do [ "$(stat -f '%Lp' .harness/$t/$TF)" = 600 ] || die "the token's file in $t must be mode 0600"; done
echo "  the token: generated once (openssl rand -hex 16, the README's line, in .harness/after), copied into every tree's $TF, mode 0600, never printed"
jc "$L_JAVAC" .harness/javac.log; [ "$JE" = 0 ] || die "the harness did not compile: $(head -5 .harness/javac.log)"
[ ! -e .harness/hc/probe/u/ex ] || die "the exercise's class compiled into the wrong place"
echo "  extracted eight jars ($(for t in before after anb ana2 anr ane and1 and2; do ls .harness/$t/$XD/lib | wc -l | tr -d ' '; done | paste -sd/ -) libraries: before/after/B/A'/(a)/(b)/(d)/(d) un-finaled); the harness compiled once - .harness/hc over after/'s"
# the H2 TCP server: one JVM for this run, loopback only, every TiffinBox database on it (mem:NAME), the second connection its Shell
[ "$(listeners 20088)" = 0 ] || die "something listens on 20088"
echo "\$ $L_H2S" >&3
(eval "$L_H2S") > .harness/h2server.log 2>&1 < /dev/null & spid=$!
i=0; while [ $i -lt 120 ] && [ "$(listeners 20088)" = 0 ]; do kill -0 "$spid" 2> /dev/null || break; sleep 0.25; i=$((i + 1)); done
[ "$(listeners 20088)" = 1 ] || { cat .harness/h2server.log >&3; die "the H2 server never listened on 20088"; }
[ "$(lsof -nP -a -p "$spid" -iTCP -sTCP:LISTEN 2> /dev/null | awk 'NR > 1 { print $9 }' | sort -u | paste -sd' ' -)" = '127.0.0.1:20088' ] || die "the H2 server must listen on 127.0.0.1:20088 alone"
H2SL=$($G -m1 'TCP server running at' .harness/h2server.log || true); [ "$H2SL" = 'TCP server running at tcp://localhost:20088 (only local connections)' ] || die "the H2 server's line: ${H2SL:-none}"
echo "  the H2 server: $H2SL - listens on 127.0.0.1:20088 alone"
# ---- helpers ------------------------------------------------------------------------------------------------------------
raw() { local t=$1; shift; cat "$@" 2> /dev/null | LC_ALL=C $G -aoF -- "$t" | wc -l | tr -d ' '; }
LOGS=0; GENW=0
genw() { local n; n=$($G -c 'GenerationTarget encountered exception' "$1" || true); GENW=$((GENW + n)); }
mask() { awk -v t="$TOKEN" -v u="$U" -v up="$UP" -v hm="$HOME" -v me="$ME" '
  function lit(x) { gsub(/[][\\.^$*+?(){}|\/]/, "\\\\&", x); return x }
  function enc(x) { gsub(/ /, "%20", x); return x }
  BEGIN { T = lit(t); P = lit(u); Q = lit(up); H = lit(hm); PE = lit(enc(u)); QE = lit(enc(up)); M = "(^|[^A-Za-z0-9_])" lit(me) "([^A-Za-z0-9_]|$)" }
  { gsub(T, "[masked: the token]"); gsub(P, "…"); gsub(PE, "…"); gsub(Q, "…/.."); gsub(QE, "…/.."); gsub(H, "~")
    gsub(/ using Java [0-9][0-9.]+/, " using Java <version>")
    gsub(/jdbc:h2:mem:[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]-[0-9a-f-]+/, "jdbc:h2:mem:<uuid>")
    gsub(/SessionImpl\([0-9]+</, "SessionImpl(<n><")
    gsub(/\$\$Lambda\/0x[0-9a-f]+/, "$$Lambda/<n>")
    gsub(/repository scanning in [0-9]+ ms\./, "repository scanning in <n> ms.")
    gsub(/started on [A-Z][a-z][a-z] [A-Z][a-z][a-z] [ 0-9][0-9]? [0-9][0-9]:[0-9][0-9]:[0-9][0-9] [A-Z]+ [0-9][0-9][0-9][0-9]/, "started on <date>")
    gsub(/CONSTRAINT_INDEX_[0-9]+/, "CONSTRAINT_INDEX_<n>"); gsub(/CONSTRAINT_[0-9]+/, "CONSTRAINT_<n>")
    gsub(/"timestamp":"[^"]*"/, "\"timestamp\":\"<time>\"")
    gsub(/@[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]+/, "@…")
    gsub(/virtual-[0-9]+/, "virtual-<n>"); gsub(/omcat-handler-[0-9]+/, "omcat-handler-<n>"); gsub(/ rows, [0-9]+ ms\)/, " rows)")
    while (match($0, M)) { pre = substr($0, 1, RSTART - 1); s = substr($0, RSTART, RLENGTH); post = substr($0, RSTART + RLENGTH)
      sub(lit(me), "<user>", s); $0 = pre s post }
    print }'; }
printf '%s\n' 'Starting XMain using Java 25.0.4.1' "$U/x" "$UP/y" "$HOME/z" 'org.h2.jdbc.JdbcConnection@1a2b3c4d' 'EntityManager [SessionImpl(1895617509<open>)]' 'Finished Spring Data repository scanning in 25 ms. Found 1 JPA repository interface.' "token $TOKEN" 'url=jdbc:h2:mem:184c1fae-3bb5-4208-80fb-a59190f705ec user=SA' '{"timestamp":"2026-11-11T16:07:00.140Z","status":500}' 'JDBC [x.HibernateTransactionManager$$Lambda/0x000003ff01b8a310@5d9576a0]' 'source=x@6b3e12b5, started on Wed Nov 11 19:51:00 CET 2026]' '"PUBLIC.CONSTRAINT_52 INDEX PUBLIC.CONSTRAINT_INDEX_5 ON' > .harness/p1
[ "$(mask < .harness/p1)" = "$(printf '%s\n' 'Starting XMain using Java <version>' '…/x' '…/../y' '~/z' 'org.h2.jdbc.JdbcConnection@…' 'EntityManager [SessionImpl(<n><open>)]' 'Finished Spring Data repository scanning in <n> ms. Found 1 JPA repository interface.' 'token [masked: the token]' 'url=jdbc:h2:mem:<uuid> user=SA' '{"timestamp":"<time>","status":500}' 'JDBC [x.HibernateTransactionManager$$Lambda/<n>@…]' 'source=x@…, started on <date>]' '"PUBLIC.CONSTRAINT_<n> INDEX PUBLIC.CONSTRAINT_INDEX_<n> ON')" ] || die "mask: the planted JDK version, folders, home, identity hash, EntityManager identity, scan time, the token, a generated database name, a 500's timestamp, a lambda class's address, a context's start date and H2's constraint names must be masked"
rm -f .harness/p1
HA=('--spring.datasource.url=jdbc:h2:mem:u29;DB_CLOSE_DELAY=-1' --logging.config=../../harness/logback.xml --spring.jpa.hibernate.ddl-auto=none --spring.jpa.open-in-view=false --spring.jpa.properties.hibernate.generate_statistics=true --spring.main.banner-mode=off --spring.thymeleaf.check-template-location=false)
HE=""
hrun() { local c i=0 e=0
  c=$(printf 'cd .harness/run && %s\n' "${HL:-$L_H}")
  if [ "${HL:-$L_H}" != "$L_X" ]; then echo "\$ V=($(printf '%s ' "${V[@]}" | sed 's/ $//'))"; fi
  echo "\$ A=($(printf '%q ' "${A[@]}" | sed 's/ $//'))"; echo "\$ $c"
  (eval "$(exe "$c")") > .harness/h.log 2>&1 < /dev/null & pid=$!
  while kill -0 "$pid" 2> /dev/null && [ $i -lt 1000 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$pid" 2> /dev/null && { kill "$pid"; die "the harness run was still running after 250 s - its alarm should have stopped it"; }
  wait "$pid" || e=$?; pid=""; HE=$e; LOGS=$((LOGS + 1)); genw .harness/h.log
  [ "$HE" != 142 ] || die "the harness JVM's alarm fired (exit 142) - a run that does not end by itself is a failed receipt (R.247)"; }
hview() { sed -E 's/[[:space:]]+$//; s/^/  /' .harness/h.log; echo "  exit $HE · 'GenerationTarget encountered exception': $($G -c 'GenerationTarget encountered exception' .harness/h.log || true)"; }
unpub=""
cap() { local nm=$1 i; shift
  for i in 1 2 3; do "$@" > .harness/cap.raw 2>&1 || true; [ -z "$pid$lpid$mpid$xpid" ] || die "$nm left a process running"
    raw "$TOKEN" .harness/cap.raw > ".harness/raw-$nm.$i"
    mask < .harness/cap.raw > ".r-$nm.$i"; done
  CH=$(md5 -q ".r-$nm.1")
  [ "$CH" = "$(md5 -q ".r-$nm.2")" ] && [ "$CH" = "$(md5 -q ".r-$nm.3")" ] || die "$nm drifts across three runs (diff .r-$nm.1 .r-$nm.2 .r-$nm.3)"
  mv ".r-$nm.1" ".r-$nm.out"; rm -f ".r-$nm.2" ".r-$nm.3"; }
pub() { local nm=$1 h pub; h=$(md5 -q ".r-$nm.out")
  pub=$(awk -v n="$nm" '$1 == n { print $2 }' receipts.md5 2> /dev/null || true)
  if [ -z "$pub" ]; then printf '  %-13s md5 %s  3/3  (no published hash)\n' "$nm" "$h"; unpub="$unpub $nm"
  elif [ "$pub" = "$h" ]; then printf '  %-13s md5 %s  3/3  = published\n' "$nm" "$h"
  else printf '  %-13s md5 %s  3/3  DIFFERS from the published %s\n' "$nm" "$h" "$pub"
    die "$nm is not the published capture - suspect another JDK, Boot or Maven, a busy machine, a variable of yours, or an edited source; diff .r-$nm.out against its block in README.md"; fi; }
cdiff() { diff -U0 "$1" "$2" | tail -n +3 > .harness/code.diff || true
  echo "  its diff (diff -U0, its file names cut) - hunks: $($G -c '^@@ ' .harness/code.diff || true) · lines out: $($G -c '^-' .harness/code.diff || true) · in: $($G -c '^+' .harness/code.diff || true) - whole:"
  sed 's/^/    /' .harness/code.diff; }
summ() { $G -E '^\[(INFO|ERROR|WARNING)\] Tests run: [0-9]+, Failures: [0-9]+, Errors: [0-9]+, Skipped: [0-9]+$' "$1" | tail -1 | sed -E 's/.*Tests run: ([0-9]+), Failures: ([0-9]+), Errors: ([0-9]+), Skipped: ([0-9]+)$/tests \1 · failures \2 · errors \3 · skipped \4/'; }
reports() { local s t
  python3 -I harness/surefire.py "$1/$SR" | sed 's/^/  /'
  s=$(summ "$2"); t=$(python3 -I harness/surefire.py "$1/$SR" | sed -n 's/^  in all: [0-9]* reports · //p')
  echo "  Surefire's console summary (its Results line): ${s:-none} · the reports' sum the same: $( [ -n "$s" ] && [ "$s" = "$t" ] && echo yes || echo no)"; }
# ---- TiffinBox: started from its tree, readiness polled, asked, stopped by its pid ---------------------------------------------
first() { $G -m1 -E ' : Starting ' "$1" | sed 's/^.* : //; s/ with PID .*$//; s/ using Java [0-9][0-9.]*/ using Java <version>/'; }
sec() { local s; s=$(cd "$1/secrets" 2> /dev/null && find . -type f | sed 's#^\./##' | sort | paste -sd' ' -)
  [ "$s" = tiffinbox/shutdown-token ] || die "$1/secrets holds more than the token's file (${s:-nothing})"
  echo "  secrets/ before the start: $s (mode $(stat -f '%Lp' "$1/secrets/$s")) - the token's file, and nothing else"; }
dir() { printf '%s\n' "$1" | sed -n 's/^cd \([^ ]*\) && .*/\1/p'; }
start() { [ "$(listeners "$2")" = 0 ] || die "something listens on $2 before the start"; sec "$(dir "$1")"; echo "\$ $1"; : > .harness/run.out; (eval "$(exe "$1")") >> .harness/run.out 2>&1 < /dev/null & pid=$!; }
addrs() { lsof -nP -a -p "$1" -iTCP -sTCP:LISTEN 2> /dev/null | awk 'NR > 1 { print $9 }' | sort -u | paste -sd' ' -; }
up() { local a="" i=0
  while [ $i -lt 480 ]; do a=$(addrs "$pid"); case " $a " in *":$1 "*) break ;; esac; kill -0 "$pid" 2> /dev/null || break; sleep 0.25; i=$((i + 1)); done
  case " $a " in *":$1 "*) ;; *) tail -20 .harness/run.out >&3; die "it never listened on $1" ;; esac
  echo "  listens on: $a"; echo "  Boot's first line: $(first .harness/run.out)"; }
ready() { local i=0 c=""
  while [ $i -lt 480 ]; do c=$(curl -s --noproxy '*' -o /dev/null -w '%{http_code}' "http://127.0.0.1:$1/actuator/health/readiness" 2> /dev/null || true); [ "$c" = 200 ] && break
    kill -0 "$pid" 2> /dev/null || { tail -20 .harness/run.out >&3; die "it exited before readiness answered 200"; }
    sleep 0.25; i=$((i + 1)); done
  [ "$c" = 200 ] || die "readiness never answered 200 on $1"; echo "  GET /actuator/health/readiness -> 200"; }
LASTE=""
stopit() { local i=0 e=0; kill "$pid" 2> /dev/null || true
  while kill -0 "$pid" 2> /dev/null && [ $i -lt 120 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$pid" 2> /dev/null && { kill -9 "$pid"; die "the server on $1 was still running after its SIGTERM"; }
  wait "$pid" || e=$?; pid=""; LASTE=$e
  [ "$(listeners "$1")" = 0 ] || die "something still listens on $1"; echo "  stopped by its pid (SIGTERM): exit $LASTE · listening on $1 now: 0"; }
gone() { local i=0 e=0
  while kill -0 "$pid" 2> /dev/null && [ $i -lt 60 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$pid" 2> /dev/null && { kill "$pid"; die "the server on $1 was still running after POST /shutdown"; }
  wait "$pid" || e=$?; pid=""; LASTE=$e
  [ "$(listeners "$1")" = 0 ] || die "something still listens on $1"; }
lvl() { $G -cE "^[0-9]{4}-[0-9]{2}-[0-9]{2}T[^ ]+ +$1 " "$2" || true; }
logtok() { local t; t=$(raw "$TOKEN" .harness/run.out); LOGS=$((LOGS + 1)); genw .harness/run.out; [ "$t" = 0 ] || die "a TiffinBox log held the token ($t)"; echo "  its log: the token 0 times"; }
lines() { wc -l < .harness/run.out | tr -d ' '; }
settle() { local a b i=0; a=$(lines); while [ $i -lt 20 ]; do sleep 0.25; b=$(lines); [ "$a" = "$b" ] && break; a=$b; i=$((i + 1)); done; }
# req 'CURL LINE' PORT [DIR]: one request - its answer (a 500's body by its status and path); then the log lines it added: the
# transaction manager's create / commit / rollback lines, the interceptor's, Hibernate's refusal, WARN and ERROR - and a request
# that failed, its exception (Spring MVC's "Request processing failed: ...")
TXL='^(Creating new transaction with name |Initiating transaction |Participating transaction failed|Transactional code has requested rollback)'
req() { local n0 n1 c
  n0=$(lines); c=$(url "$1" "$2"); echo "\$ ${3:+cd $3 && }$c"
  echo "  -> $( ( [ -z "${3:-}" ] || cd "$3"; eval "$c" ) 2> /dev/null < /dev/null | sed -E 's/"pricePerMeal":[0-9]+,//g; s/"mealsPerDay":[0-9]+,//g' || true)"
  settle; n1=$(lines); sed -n "$((n0 + 1)),${n1}p" .harness/run.out > .harness/req.log
  echo "  the log lines it added - WARN: $(lvl WARN .harness/req.log) · ERROR: $(lvl ERROR .harness/req.log):"
  TX="$TXL" awk '/^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T[^ ]+ +[A-Z]+ [0-9]+ --- \[/ { s = $0; i = index(s, " --- ["); s = substr(s, i + 6); i = index(s, "] "); s = substr(s, i + 2)
    i = index(s, " : "); lg = substr(s, 1, i - 1); sub(/ +$/, "", lg); m = substr(s, i + 3); sub(/[ \t]+$/, "", m)
    if (m ~ /threw exception \[Request processing failed: /) { sub(/^.*threw exception \[Request processing failed: /, "", m); sub(/\] with root cause$/, "", m); print "    the request failed: " m; next }
    if (lg ~ /JpaTransactionManager$/ && m !~ ENVIRON["TX"]) next
    if (lg ~ /JpaTransactionManager$|TransactionInterceptor$|orm\.jdbc\.error$/ || $2 == "WARN" || $2 == "ERROR") print "    " $2 " " lg ": " (length(m) > 200 ? substr(m, 1, 200) " …" : m) }' .harness/req.log; }
names() { $G -oE '"name":"[A-Za-z]+"' | sed 's/"name":"//; s/"$//' | paste -sd' ' -; }
# startfail 'RUN LINE' PORT: a start that must fail by itself - its exit, its port never bound, and its log's WARN and ERROR lines
# (level, logger: message) and every "Caused by:" line of its stack trace (the frames dropped)
startfail() { local p=$2 i=0 e=0
  start "$1" $p
  while kill -0 "$pid" 2> /dev/null && [ $i -lt 480 ]; do [ "$(listeners $p)" = 0 ] || break; sleep 0.25; i=$((i + 1)); done
  kill -0 "$pid" 2> /dev/null && { kill "$pid"; die "the server on $p is still running (or listens) - its start was to fail"; }
  wait "$pid" || e=$?; pid=""; LASTE=$e
  echo "  the JVM ended by itself: exit $e · listening on $p: $(listeners $p)"
  echo "  Boot's first line: $(first .harness/run.out)"
  echo "  its log - every WARN and ERROR line (level, logger: message) and the exception's own line and every 'Caused by:' line, each cut at 220 characters:"
  awk '/^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T[^ ]+ +[A-Z]+ [0-9]+ --- \[/ { s = $0; i = index(s, " --- ["); s = substr(s, i + 6); i = index(s, "] "); s = substr(s, i + 2)
    i = index(s, " : "); lg = substr(s, 1, i - 1); sub(/^ +/, "", lg); sub(/ +$/, "", lg); m = substr(s, i + 3); sub(/[ \t]+$/, "", m); gsub(/\[jar:nested:[^]]*\]/, "[jar:nested:<the jar>]", m)
    if ($2 == "WARN" || $2 == "ERROR") print "    " $2 " " lg ": " (length(m) > 220 ? substr(m, 1, 220) " …" : m); next }
    /^Caused by: / || /^[a-z][A-Za-z0-9_.]*\.[A-Z][A-Za-z0-9_$]*(Exception|Error): / { m = $0; sub(/[ \t]+$/, "", m); gsub(/\[jar:nested:[^]]*\]/, "[jar:nested:<the jar>]", m); print "    " (length(m) > 220 ? substr(m, 1, 220) " …" : m) }' .harness/run.out
  logtok; rm -f .harness/run.out; }
# ---- the requests: each between two markers this script appends to the JVM's log (opened for append), read per request -----
cat > .harness/seg.py <<'PY'
import re, sys
L = re.compile(r"^\S+\s+(\w+)\s+\d+ --- \[\s*([^\]]+)\] (\S+)\s*: (.*)$")
def kind(t): return "virtual" if t.startswith("virtual-") else ("request" if "handler" in t or "nio-" in t else "other:" + t)
sql = {"virtual": 0, "request": 0}; vth = set(); create = {}; part = 0; op = []; cl = []; fail = []; warn = 0
for l in open(sys.argv[1], encoding="utf-8", errors="replace"):
    m = L.match(l.rstrip("\n"))
    if not m: continue
    lv, th, lg, msg = m.groups(); k = kind(th)
    if lv == "WARN": warn += 1
    if lg == "org.hibernate.SQL":
        sql[k] = sql.get(k, 0) + 1
        if k == "virtual": vth.add(th)
    elif lg.endswith("JpaTransactionManager"):
        c = re.match(r"Creating new transaction with name \[([^\]]+)\]", msg)
        if c: create[(c.group(1), k)] = create.get((c.group(1), k), 0) + 1
        if msg.startswith("Participating in existing transaction"): part += 1
    elif lg.endswith("OpenEntityManagerInViewInterceptor"):
        if msg.startswith("Opening JPA EntityManager"): op.append(k)
        if msg.startswith("Closing JPA EntityManager"): cl.append(k)
    f = re.search(r"threw exception \[Request processing failed: (.*?)\]( with root cause)?$", msg)
    if f: fail.append((k, th, f.group(1)))
print("  between its markers: SQL lines %d - on virtual threads %d (%d threads), on the request thread %d" % (sum(sql.values()), sql["virtual"], len(vth), sql["request"]))
for (n, k), c in sorted(create.items()): print("  the manager: Creating new transaction with name [%s] - %d, on the %s thread%s" % (n, c, k, "s" if k == "virtual" else ""))
print("  the manager: Participating in existing transaction - %d" % part)
print("  OpenEntityManagerInViewInterceptor: Opening %d (on the request thread %d) · Closing %d (on the request thread %d)" % (len(op), op.count("request"), len(cl), cl.count("request")))
for k, th, msg in fail: print("  the request failed, on the %s thread [%s]: %s" % (k, th, msg))
print("  WARN lines: %d" % warn)
PY
cat > .harness/chk29.py <<'PY'
import re, sys
def second(path):
    t = open(path, encoding="utf-8").read()
    return re.findall(r"^(\w+)\s*\|\s*(\d+)\s*$", t, re.M), re.findall(r"^(\d+)\s*\|\s*(\w+)\s*$", t, re.M)
mode = sys.argv[1]
if mode == "A":      # A's witness (S5.15): the table parsed, the column found by its header, each row against the second connection's sum
    html = open(sys.argv[2], encoding="utf-8").read(); sums, _ = second(sys.argv[3])
    rows = re.findall(r"<tr>(.*?)</tr>", html, re.S)
    if not rows or "<th>Paused days</th>" not in rows[0]:
        print("  A's check: no table with a Paused days header - FAIL"); sys.exit(1)
    head = re.findall(r"<th>(.*?)</th>", rows[0]); col = head.index("Paused days")
    cells = [re.findall(r"<td>(.*?)</td>", r) for r in rows[1:]]
    page = [(c[0], c[col]) for c in cells]
    ok = page == sums and len(sums) == 4
    print("  A's check: the header 'Paused days' is column %d; the page %s; the second connection's sum %s - %s" % (col + 1, " · ".join("%s %s" % p for p in page), " · ".join("%s %s" % p for p in sums), "PASS" if ok else "FAIL"))
    sys.exit(0 if ok else 1)
if mode == "B":      # B's witness (S5.15): the 500's cause bound - the request thread's line with the exception for the key derived
    seg = open(sys.argv[2], encoding="utf-8").read(); _, ids = second(sys.argv[3])
    key, name = ids[0]
    lie = re.findall(r"\[\s*([^\]]+)\] \S+\s*: Servlet\.service\(\) for servlet \[dispatcherServlet\] in context with path \[\] threw exception "
                     r"\[Request processing failed: java\.util\.concurrent\.ExecutionException: org\.hibernate\.LazyInitializationException: Cannot lazily "
                     rf"initialize collection of role 'com\.tiffinbox\.CustomerEntity\.pauses' with key '{key}' \(no session\)\]", seg)
    req = [t for t in lie if "handler" in t]
    virt = sorted(set(re.findall(r"\[\s*(virtual-\d+)\] org\.hibernate\.SQL", seg)))
    ok = len(req) == 1 and len(lie) == 1 and len(virt) > 0
    print("  B's check: the key derived - the first customer by name on the second connection: %s, id %s; the cause line with that key on the request thread: %d; the read's SQL on virtual threads: %d - %s" % (name, key, len(req), len(virt), "PASS" if ok else "FAIL"))
    sys.exit(0 if ok else 1)
PY
U29M=U29MARK
mark() { printf '%s %s\n' "$U29M" "$1" >> .harness/run.out; }
seg() { awk -v a="$U29M $1 start" -v b="$U29M $1 end" '$0 == a { f = 1; next } $0 == b { f = 0 } f' .harness/run.out; }
# rq LABEL PATH ACCEPT PORT: one request - its status (a JSON body printed, an HTML page parsed below), then its own log lines
rq() { local l=$1 p=$4 code
  mark "$l start"; echo "\$ curl -s --noproxy '*' -H 'Accept: $3' http://127.0.0.1:$p$2"
  code=$(curl -s --noproxy '*' -o .harness/body-$l -w '%{http_code}' -H "Accept: $3" "http://127.0.0.1:$p$2" 2> /dev/null || true)
  settle; mark "$l end"; seg "$l" > .harness/seg-$l.log
  case $3 in application/json) echo "  -> $code $(sed -E 's/"timestamp":"[^"]*"/"timestamp":"<time>"/' .harness/body-$l | cut -c1-200)" ;; *) echo "  -> $code" ;; esac
  python3 -I -B .harness/seg.py .harness/seg-$l.log; }
# second DB: the second connection - H2's own Shell over TCP, the same database, run by this script while TiffinBox still runs
second() { local DB=$1 Q
  echo "the second connection (H2's Shell over TCP, mem:$DB):"
  for Q in "$Q_SUM" "$Q_IDS"; do echo "\$ $L_SHELL" | sed "s#\\\$DB#$DB#; s#\\\$Q#$Q#"; done
  Q=$Q_SUM; (eval "$L_SHELL") > .harness/second-sum.txt 2>&1 < /dev/null || die "the second connection failed: $(head -3 .harness/second-sum.txt)"
  Q=$Q_IDS; (eval "$L_SHELL") > .harness/second-ids.txt 2>&1 < /dev/null || die "the second connection failed: $(head -3 .harness/second-ids.txt)"
  cat .harness/second-sum.txt .harness/second-ids.txt > .harness/second.txt; sed 's/^/  /' .harness/second.txt; }
chkA() { local e=0; python3 -I -B .harness/chk29.py A ".harness/body-$1" .harness/second.txt || e=$?; echo "  exit $e"; }
chkB() { local e=0; python3 -I -B .harness/chk29.py B ".harness/seg-$1.log" .harness/second.txt || e=$?; echo "  exit $e"; }
beans() { curl -s --noproxy '*' "http://127.0.0.1:$1/actuator/beans" > .harness/beans.json 2> /dev/null || true
  echo "\$ curl -s --noproxy '*' http://127.0.0.1:$1/actuator/beans"
  echo "  OpenEntityManagerInViewInterceptor beans (the beans' types read by python3 -I): $(python3 -I -c 'import json,sys; d=json.load(open(sys.argv[1])); print(sum(1 for c in d["contexts"].values() for n,b in c["beans"].items() if b.get("type","").endswith(".OpenEntityManagerInViewInterceptor")))' .harness/beans.json 2> /dev/null || echo 'no answer')"; }
up2() { up $1; ready $1; }
# the dashboard, twice as a page, once as JSON - B and every copy built on it
dash3() { rq req1 /dashboard text/html $1; rq req2 /dashboard text/html $1; rq json /dashboard application/json $1; }
OSIVL=--logging.level.org.springframework.orm.jpa.support.OpenEntityManagerInViewInterceptor=debug
BEANSX=--management.endpoints.web.exposure.include=health,beans
# ---- the captures --------------------------------------------------------------------------------------------------------
lazy() { echo "lazy - the placeholder and the proxy: one harness JVM over after/'s libraries:"; V=(-Ds=lazy); A=("${HA[@]}"); hrun; hview; }
anchor() { local f
  echo "the change - after/ against before/ (diff -rq, the file names):"
  diff -rq before after | sed -E 's#^Files before/(.*) and after/.* differ$#  \1#' | sort
  for f in $CJ/CustomerRepository.java $CJ/Dashboard.java tiffinbox-web/src/main/resources/templates/dashboard.html; do echo "$f:"; cdiff "before/$f" "after/$f"; done
  echo "B - labelled: after/ without the read's transaction (.harness/anb, derive.py notx; its tests ran: run, failures, errors, skipped $(summ4 .harness/build-anb.log)), port 20080:"
  echo "  its difference from after/ - $CJ/CustomerRepository.java:"; cdiff .harness/after/$CJ/CustomerRepository.java .harness/anb/$CJ/CustomerRepository.java
  start "$(tb anb 20080 u29b)" 20080; up2 20080
  rq list /customers application/json 20080; dash3 20080; second u29b; chkB req1; chkB req2; chkB json
  echo "  the seven on B (\$CURLSET 20080 .harness/anb/$TF) - its dashboard line, the 500's timestamp masked:"
  "$CURLSET" 20080 ".harness/anb/$TF" | $G ' -> ' | $G '^GET   /dashboard ' | sed -E 's/"timestamp":"[^"]*"/"timestamp":"<time>"/; s/^/    /' || true
  gone 20080; echo "  exit $LASTE (POST /shutdown)"; logtok; rm -f .harness/run.out
  echo "the H2 user trap - labelled: after/'s jar on the H2 server's TCP URL without --spring.datasource.username=sa, port 20081:"
  local l; l=$(tb after 20081 u29nouser); startfail "${l/ --spring.datasource.username=sa/}" 20081
  for f in after:20081:u29a:A ana2:20082:u29a2:A2; do
    echo "${f##*:} - .harness/${f%%:*} ($( [ "${f##*:}" = A ] && echo "after/'s jar" || echo "after/ copied again and built again")), port $(echo "$f" | cut -d: -f2):"
    start "$(tb "${f%%:*}" "$(echo "$f" | cut -d: -f2)" "$(echo "$f" | cut -d: -f3)")" "$(echo "$f" | cut -d: -f2)"; up2 "$(echo "$f" | cut -d: -f2)"
    rq list /customers application/json "$(echo "$f" | cut -d: -f2)"; dash3 "$(echo "$f" | cut -d: -f2)"; second "$(echo "$f" | cut -d: -f3)"; chkA req1; chkA req2
    stopit "$(echo "$f" | cut -d: -f2)"; logtok; rm -f .harness/run.out; done; }
wrong() { local e
  echo "(a) open-in-view switched on - B with the labelled request-thread route (.harness/anr, derive.py notx route), port 20083:"
  echo "  its difference from B - $WJ/TiffinBoxServer.java:"; cdiff .harness/anb/$WJ/TiffinBoxServer.java .harness/anr/$WJ/TiffinBoxServer.java
  start "$(tb anr 20083 u29osiv --spring.jpa.open-in-view=true $OSIVL $BEANSX)" 20083; up2 20083
  dash3 20083; rq paused /customers/paused application/json 20083; beans 20083; second u29osiv; chkB req1; chkB req2
  stopit 20083; logtok; rm -f .harness/run.out
  echo "(a) the control - the same copy without the flag (open-in-view false, TiffinBox's own setting), port 20084:"
  start "$(tb anr 20084 u29osivoff $OSIVL $BEANSX)" 20084; up2 20084
  dash3 20084; rq paused /customers/paused application/json 20084; beans 20084
  stopit 20084; logtok; rm -f .harness/run.out
  echo "(a) the held connection - open-in-view's two calls made by hand: one harness JVM over after/'s libraries:"; V=(-Ds=held); A=("${HA[@]}"); hrun; hview
  echo "(b) EAGER - labelled: B with pauses fetch = EAGER (.harness/ane, derive.py notx eager), port 20085:"
  echo "  its difference from B - $CJ/CustomerEntity.java:"; cdiff .harness/anb/$CJ/CustomerEntity.java .harness/ane/$CJ/CustomerEntity.java
  start "$(tb ane 20085 u29eager)" 20085; up2 20085; rq list /customers application/json 20085; rq req1 /dashboard text/html 20085; second u29eager; chkA req1
  stopit 20085; logtok; rm -f .harness/run.out
  echo "(b) EAGER in the harness - ECustomer, the anchor's tables, pauses EAGER: one harness JVM over after/'s libraries:"; V=(-Ds=eager); A=("${HA[@]}"); hrun; hview
  echo "(c) enable_lazy_load_no_trans - B (.harness/anb) with the property on, port 20086:"
  start "$(tb anb 20086 u29notrans --spring.jpa.properties.hibernate.enable_lazy_load_no_trans=true)" 20086; up2 20086; rq req1 /dashboard text/html 20086; second u29notrans; chkA req1
  stopit 20086; logtok; rm -f .harness/run.out
  echo "(c) in the harness, the property on: one harness JVM over after/'s libraries:"; V=(-Ds=notrans); A=("${HA[@]}" --spring.jpa.properties.hibernate.enable_lazy_load_no_trans=true); hrun; hview
  echo "  its WARN lines (grep -c '^WARN '): $($G -c '^WARN ' .harness/h.log || true)"
  echo "(d) the controller's transaction - labelled: B with @Transactional(readOnly = true) on DashboardPage.page, the class still final (.harness/and1, derive.py notx pagetx), port 20087 - the start:"
  echo "  its difference from B - $WJ/DashboardPage.java:"; cdiff .harness/anb/$WJ/DashboardPage.java .harness/and1/$WJ/DashboardPage.java
  startfail "$(tb and1 20087 u29final)" 20087
  echo "(d) un-finaled - labelled: B with the route, both transactions and neither class final (.harness/and2, derive.py notx route pagetx routetx unfinal), port 20087:"
  echo "  its difference from (d)'s first copy - the two controllers:"; for f in DashboardPage TiffinBoxServer; do echo "  $WJ/$f.java:"; cdiff .harness/and1/$WJ/$f.java .harness/and2/$WJ/$f.java; done
  start "$(tb and2 20087 u29unfinal)" 20087; up2 20087; rq req1 /dashboard text/html 20087; rq paused /customers/paused application/json 20087; second u29unfinal; chkB req1
  stopit 20087; logtok; rm -f .harness/run.out
  echo "(e) the read's own transaction, and Hibernate.initialize in it: one harness JVM over after/'s libraries:"; V=(-Ds=tx); A=("${HA[@]}"); hrun; hview; }
L_SQL=$(mine "$R_RUN --logging.level.org.hibernate.SQL=debug")
sqlseg() { sed -n "${1},${2}p" .harness/run.out | $G -cE ' org\.hibernate\.SQL +: ' || true; }
seven7() { local t p n0 ns
  for t in before:20080 after:20081; do p=${t#*:}; t=${t%:*}
    echo "the seven - $t/'s jar, port $p, a fresh JVM (TiffinBox's own in-memory database), Hibernate's SQL logger on:"
    start "$(at .harness/$t $p "$L_SQL")" $p; up $p; ready $p; n0=$(lines)
    echo "\$ \$CURLSET $p .harness/$t/$TF"
    "$CURLSET" $p ".harness/$t/$TF" | $G ' -> ' > .harness/responses.txt || true
    awk '{ gsub(/"timestamp":"[^"]*"/, "\"timestamp\":\"…\""); print }' .harness/responses.txt > .harness/seven-$t.txt
    gone $p
    echo "  exit $LASTE · the seven responses: $(wc -l < .harness/seven-$t.txt | tr -d ' ') lines · md5 $(md5 -q .harness/seven-$t.txt)"
    echo "  its dashboard line: $($G '^GET   /dashboard ' .harness/seven-$t.txt | cut -c1-120)"
    echo "  its log's org.hibernate.SQL lines during the seven: $(sqlseg "$((n0 + 1))" '$')"
    logtok; rm -f .harness/run.out; done
  echo "  the seven, after/ against before/: lines that differ: $(diff .harness/seven-before.txt .harness/seven-after.txt | $G -c '^[<>]' || true)"; }
tests() { local c e=0 n
  echo "TiffinBox's tests - after/ copied to .harness/tests, the README's line, offline:"
  rm -rf .harness/tests; copy after .harness/tests
  c=$(off .harness/tests "$R_TEST"); echo "\$ $c"
  (eval "$c") > .harness/tests.log 2>&1 < /dev/null & mpid=$!; wait "$mpid" || e=$?; mpid=""
  n=$($G -cE '^\[INFO\] Download(ing|ed) from ' .harness/tests.log || true)
  echo "  exit $e · $($G -m1 -oE 'BUILD (SUCCESS|FAILURE)' .harness/tests.log || echo 'no BUILD line') · offline: $( [ "$n" = 0 ] && echo yes || echo "no - $n lines say Maven downloaded")"
  echo "  Surefire's reports ($SR, read by harness/surefire.py):"; reports .harness/tests .harness/tests.log
  echo "  which test classes run the real CustomerRepository or Dashboard - each test source's @MockitoBean lines (R.190):"
  for c in TiffinBoxWebTest FullStackTest FeedTest; do echo "    $c.java: CustomerRepository $($G -c '^ *@MockitoBean CustomerRepository ' .harness/tests/tiffinbox-web/src/test/java/com/tiffinbox/web/$c.java || true) · Dashboard $($G -c '^ *@MockitoBean Dashboard ' .harness/tests/tiffinbox-web/src/test/java/com/tiffinbox/web/$c.java || true)"; done
  echo "  B's reports - labelled: .harness/anb, built with its tests by the README's package line (the tests did not notice - a guard):"
  python3 -I harness/surefire.py .harness/anb/$SR | sed 's/^/  /'
  echo "  its log's WARN lines: $(lvl WARN .harness/tests.log) · ERROR lines: $(lvl ERROR .harness/tests.log) · the token in it and every report: $(raw "$TOKEN" .harness/tests.log .harness/tests/$SR/*) times"; }
X27=9cf92b8cae3abfd0f1c0706bfe7a4373                # Boot's script since unit 27's C2 - ../c7-unit27/xcheck.sql; no mapping moves in 29
[ "$(md5 -q xcheck.sql)" = "$X27" ] && cmp -s xcheck.sql ../c7-unit27/xcheck.sql || die "xcheck.sql is not ../c7-unit27/xcheck.sql (md5 $X27)"
XA=('--spring.datasource.url=jdbc:h2:mem:x29;DB_CLOSE_DELAY=-1' --logging.config=../../harness/logback.xml --spring.jpa.hibernate.ddl-auto=none --spring.main.banner-mode=off --spring.thymeleaf.check-template-location=false --spring.jpa.properties.jakarta.persistence.schema-generation.scripts.action=create --spring.jpa.properties.jakarta.persistence.schema-generation.scripts.create-target=hibernate-ddl.sql)
xcheck() {
  echo "the harness's DDL over after/'s libraries - probe.x.XMain (@EntityScan(\"com.tiffinbox\") alone: no repository, no seed), scripts.action=create (a file, never run):"
  rm -f .harness/run/hibernate-ddl.sql; A=("${XA[@]}"); HL=$L_X; hrun; hview; HL=""
  [ -f .harness/run/hibernate-ddl.sql ] || die "xcheck: no script over after/'s libraries"
  mv .harness/run/hibernate-ddl.sql .harness/ddl-after.sql
  echo "  .harness/ddl-after.sql - every line:"; sed -E 's/FK[0-9a-z]{20,}/FK<name>/g; s/^/    /' .harness/ddl-after.sql
  echo "  its md5: $(md5 -q .harness/ddl-after.sql) · the filed xcheck.sql: $(md5 -q xcheck.sql) · cmp: $(cmp -s .harness/ddl-after.sql xcheck.sql && echo 'the same, byte for byte' || echo differ) · the version lesson's xcheck.sql: $(cmp -s .harness/ddl-after.sql ../c7-unit27/xcheck.sql && echo 'the same, byte for byte' || echo differ)"; }
# ---- exercise: the README's commands, then the solution's - in ONE shell, bash, then zsh ----------------------------------------
block() { awk '/^```bash$/ { if (!d) { f = 1 }; next } f && /^```$/ { f = 0; d = 1 } f' "$1"; }
where() { case "$1" in "$U") echo "this unit's folder" ;; "$U"/*) echo "${1#"$U"/}" ;; *) echo "outside this unit's folder" ;; esac; }
exsh() { local sh=$1 i=0 e1 d1 e2 d2
  rm -rf .harness/ex; rm -f .harness/ex-*.st .harness/ex-*.out .harness/mine.log
  case $sh in bash) env -i HOME="$HOME" PATH="$XPATH" /bin/bash --noprofile --norc .harness/ex-drive.sh "$U" > .harness/ex-shell.out 2>&1 < /dev/null & xpid=$! ;;
              zsh) env -i HOME="$HOME" PATH="$XPATH" /bin/zsh -f .harness/ex-drive.sh "$U" > .harness/ex-shell.out 2>&1 < /dev/null & xpid=$! ;; esac
  while kill -0 "$xpid" 2> /dev/null && [ $i -lt 1200 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$xpid" 2> /dev/null && { killtree "$xpid"; die "the exercise's $sh still ran after 300 s"; }
  wait "$xpid" || true; xpid=""
  [ -f .harness/ex-readme.st ] && [ -f .harness/ex-sol.st ] || { cat .harness/ex-shell.out .harness/ex-readme.out .harness/ex-sol.out 2> /dev/null | tail -20 >&3; die "the exercise's $sh did not reach the end of both blocks"; }
  read -r e1 d1 < .harness/ex-readme.st; read -r e2 d2 < .harness/ex-sol.st
  echo "in $sh ($( [ $sh = bash ] && echo '/bin/bash --noprofile --norc' || echo '/bin/zsh -f')) - the README's lines:"
  echo "  the block's exit $e1 · what it printed (trailing spaces dropped):"; sed -E 's/[[:space:]]+$//; s/^/    /' .harness/ex-readme.out
  echo "  the shell is now in: $(where "$d1")"
  echo "  then the solution's lines, in the same shell - the block's exit $e2 · what it printed (trailing spaces dropped):"; sed -E 's/[[:space:]]+$//; s/^/    /' .harness/ex-sol.out
  echo "  the shell is now in: $(where "$d2") · the classes it compiled: $(cd .harness/ex/classes 2> /dev/null && find . -name '*.class' | sed 's#^\./##' | sort | paste -sd' ' -) · the shell's own output: $(wc -l < .harness/ex-shell.out | tr -d ' ') lines"; }
exercise() { local setup sol
  setup=$(block exercise/README.md); sol=$(block exercise/SOLUTION.md)
  [ -n "$setup" ] && [ -n "$sol" ] || die "exercise/README.md or SOLUTION.md no longer gives its commands"
  printf '%s\n' "$sol" | sed -n 1p | $G -qxF 'export JAVA_HOME=/opt/homebrew/opt/openjdk@25' || die "SOLUTION.md's first line must export this script's JAVA_HOME"
  [ "$(printf '%s\n' "$setup" | $G -c .)" = "$(printf '%s\n' "$sol" | $G -c .)" ] || die "SOLUTION.md's block must have the README's lines, one changed"
  [ "$(diff <(printf '%s\n' "$setup") <(printf '%s\n' "$sol") | $G -c '^[<>]')" = 2 ] || die "SOLUTION.md's block must be the README's with one line changed"
  printf '%s\n' "$setup" | $G -qF -- '"${A[@]}"' && printf '%s\n' "$setup" | $G -qE '^A=\(' || die "exercise/README.md must pass its arguments as an array, A (R.164, R.193)"
  printf '%s\n' "$setup" | $G -E ' java ' | $G -qF "perl -e 'alarm " || die "exercise/README.md's JVM must run under its alarm (R.247)"
  printf '%s\n' "$setup" > .harness/ex-readme.sh; printf '%s\n' "$sol" > .harness/ex-sol.sh
  cat > .harness/ex-drive.sh <<'DRV'
cd "$1" || exit 1
. "$1/.harness/ex-readme.sh" > "$1/.harness/ex-readme.out" 2>&1 < /dev/null
echo "$? $PWD" > "$1/.harness/ex-readme.st"
cd "$1" || exit 1
. "$1/.harness/ex-sol.sh" > "$1/.harness/ex-sol.out" 2>&1 < /dev/null
echo "$? $PWD" > "$1/.harness/ex-sol.st"
DRV
  echo "exercise/README.md's $(printf '%s\n' "$setup" | $G -c .) lines, then exercise/SOLUTION.md's, exactly as written, one after the other in ONE shell - env -i (HOME, and the PATH this script was started with), started in this folder:"
  echo "the README's lines:"; printf '%s\n' "$setup" | sed 's/^/  $ /'
  echo "the solution's line that differs:"; diff <(printf '%s\n' "$setup") <(printf '%s\n' "$sol") | $G '^>' | sed 's/^> /  $ /'
  exsh bash; exsh zsh; }
blk() { awk -v a="$2" -v b="$3" 'index($0, a) == 1 { f = 1; next } b != "" && index($0, b) == 1 { f = 0 } f' ".r-$1.out"; }
has() { printf '%s\n' "$1" | $G -qxF -- "$2" || die "$3: expected the line: $2"; }
nhas() { ! printf '%s\n' "$1" | $G -qF -- "$2" || die "$3: did not expect: $2"; }
cnt() { printf '%s\n' "$1" | $G -cxF -- "$2" || true; }
# ---- the checks: every number and string the video says, read off its capture -------------------------------------------------
# S4.13 (R.270): Framework's version beside HHH000001 and Spring Data's, once per harness JVM, never typed
VERL='  PROBE Hibernate ORM core version (org.hibernate.Version.getVersionString()): 7.4.13.Final'
VERH='  INFO  [main] org.hibernate.orm.core : HHH000001: Hibernate ORM core version 7.4.13.Final'
VERD='  PROBE Spring Data JPA version (JpaRepository.class.getPackage().getImplementationVersion()): 4.1.2'
VERF='  PROBE Spring Framework version (Transactional.class.getPackage().getImplementationVersion()): 7.0.10'
DBL='  PROBE database: H2 2.5.250 | url jdbc:h2:mem:u29;DB_CLOSE_DELAY=-1'
FOUND1='  INFO  [main] org.springframework.data.repository.config.RepositoryConfigurationDelegate : Finished Spring Data repository scanning in <n> ms. Found 1 JPA repository interface.'
ver() { local c=$1
  [ "$(cnt "$c" "$VERL")" = "$2" ] && [ "$(cnt "$c" "$VERH")" = "$2" ] && [ "$(cnt "$c" "$VERD")" = "$2" ] && [ "$(cnt "$c" "$VERF")" = "$2" ] || die "$3: the version lines - getVersionString(), Hibernate's HHH000001, Spring Data JPA's 4.1.2 and Spring Framework's 7.0.10 - once in each of its $2 harness JVMs (S4.13)"
  [ "$(cnt "$c" "$DBL")" = "$2" ] && [ "$(cnt "$c" "$FOUND1")" = "$2" ] && [ "$(cnt "$c" "  exit 0 · 'GenerationTarget encountered exception': 0")" = "$2" ] || die "$3: the database line (H2 2.5.250), Spring Data's Found 1 and exit 0 - in each of its $2 harness JVMs"; }
# the three witnesses of one step (S5.1): Statistics, the SQL logger's events, the JDBC proxy - equal, or the step's check fails
w3() { local l; l=$(printf '%s\n' "$1" | sed -n "s/^  PROBE ${2:-counts}: //p" | head -1)
  python3 -I -c 'import re,sys; l=sys.argv[1]; g=lambda k: int(re.search(k+r" (\d+)", l).group(1))
s=g("Statistics.getPrepareStatementCount"); q=g("org.hibernate.SQL lines"); p=g("JDBC proxy prepareStatement")
print(s if s == q == p else "MISMATCH %d %d %d" % (s, q, p), g("getConnection"), g("sessionOpenCount"), g("collectionFetchCount"), g("rows read"))' "$l"; }
# the key: the first customer by name, read by the harness's second connection
LZK=""; LZN=""; LZX=""; LZP=""; LZC=""; LZB=""
chk_lazy() { local C b w
  C=$(cat .r-lazy.out); ver "$C" 1 lazy
  LZK=$(printf '%s\n' "$C" | sed -n 's/^  PROBE the second connection reads, by name: \[\([0-9]*\) \([A-Za-z]*\),.*/\1/p'); LZN=$(printf '%s\n' "$C" | sed -n 's/^  PROBE the second connection reads, by name: \[\([0-9]*\) \([A-Za-z]*\),.*/\2/p')
  [ -n "$LZK" ] && [ -n "$LZN" ] || die "lazy: the second connection's first customer by name"
  b=$(blk lazy '  PROBE >>> findAll' '  PROBE <<< findAll')
  has "$b" '  PROBE caller: tx active false · name null · thread virtual false' "lazy: no transaction around the caller"
  LZB=$(printf '%s\n' "$b" | sed -n "s/^  PROBE loaded 4 customers · the first by name: $LZN (id $LZK) · her pauses: class \([^ ]*\) · Hibernate.isInitialized false$/\1/p")
  [ "$LZB" = org.hibernate.collection.spi.PersistentBag ] || die "lazy: the first customer's pauses - a PersistentBag, not read: ${LZB:-none}"
  w=$(w3 "$b" 'counts after findAll'); [ "$w" = '1 1 1 0 4' ] || die "lazy: findAll - one statement, three witnesses, one connection: $w"
  LZX=$(printf '%s\n' "$b" | sed -n 's/^  PROBE threw: //p')
  [ "$LZX" = "org.hibernate.LazyInitializationException: Cannot lazily initialize collection of role 'com.tiffinbox.CustomerEntity.pauses' with key '$LZK' (no session)" ] || die "lazy: 7.4.13's text with the derived key $LZK (S5.4): ${LZX:-none}"
  b=$(blk lazy '  PROBE >>> getReferenceById(3)' '  PROBE <<< getReferenceById(3)')
  LZC=$(printf '%s\n' "$b" | sed -n 's/^  PROBE class \([^ ]*\) · Hibernate.isInitialized false · getId() 3$/\1/p'); [ "$LZC" = 'com.tiffinbox.CustomerEntity$HibernateProxy' ] || die "lazy: getReferenceById(3) - Hibernate's proxy, getId() 3: ${LZC:-none}"
  w=$(w3 "$b" 'counts after getId()'); [ "${w%% *}" = 0 ] || die "lazy: getId() sent no statement: $w"
  LZP=$(printf '%s\n' "$b" | sed -n 's/^  PROBE threw: //p'); [ "$LZP" = 'org.hibernate.LazyInitializationException: Could not initialize proxy [com.tiffinbox.CustomerEntity#3] - no session' ] || die "lazy: getName() on the proxy (S5.4): ${LZP:-none}"
  b=$(blk lazy "  PROBE >>> pauses loaded in a transaction" "  PROBE <<< pauses loaded")
  has "$b" '  PROBE the first pause'"'"'s customer: class com.tiffinbox.CustomerEntity$HibernateProxy · Hibernate.isInitialized false · getId() 3' "lazy: a pause's customer, a proxy"
  has "$b" "  PROBE threw: $LZP" "lazy: a pause's customer refuses the same way"
  echo "  lazy: findAll outside a transaction - 1 statement (three witnesses), $LZN's pauses a $LZB not read, then $LZX; getReferenceById(3) - $LZC, getId() 3 with 0 statements, getName(): $LZP; a pause's customer the same"; }
SEVL='GET   /dashboard  -> 500 application/json  {"timestamp":"<time>","status":500,"error":"Internal Server Error","path":"/dashboard"}'
JSON4='{"customers":4,"monthRevenue":24300,"pausedDays":5,"names":["Meera","Priya","Ravi","Sunil"]}'
SQ() { printf '  between its markers: SQL lines %s - on virtual threads %s (%s threads), on the request thread %s' "$1" "$2" "$3" "$4"; }
CRT() { printf '  the manager: Creating new transaction with name [%s] - %s, on the %s' "$1" "$2" "$3"; }
FINDALL=org.springframework.data.jpa.repository.support.SimpleJpaRepository.findAll
ABX=""; AP=""; ANU=""
chk_anchor() { local AN B N A A2 l
  AN=$(cat .r-anchor.out)
  [ "$(printf '%s\n' "$AN" | sed -n '/^the change - after/,/^tiffinbox-core/p' | $G '^  ' | paste -sd' ' -)" = "  README.md   $CJ/CustomerRepository.java   $CJ/Dashboard.java   tiffinbox-web/src/main/resources/templates/dashboard.html" ] || die "anchor: the change - README.md and three files"
  B=$(blk anchor 'B - labelled' 'the H2 user trap'); N=$(blk anchor 'the H2 user trap' 'A - '); A=$(blk anchor 'A - ' 'A2 - '); A2=$(blk anchor 'A2 - ' '')
  has "$AN" "B - labelled: after/ without the read's transaction (.harness/anb, derive.py notx; its tests ran: run, failures, errors, skipped 18 0 0 0), port 20080:" "anchor B: labelled, its 18 tests passed (a guard - the tests did not notice)"
  has "$B" '    -    @Transactional(readOnly = true)' "anchor B: the read's annotation, the one line out"
  [ "$(cnt "$B" '  -> 500')" = 2 ] && [ "$(cnt "$B" '  -> 500 {"timestamp":"<time>","status":500,"error":"Internal Server Error","path":"/dashboard"}')" = 1 ] || die "anchor B: the page twice and the JSON once, 500"
  [ "$(printf '%s\n' "$B" | $G -c '^  B.s check: .* - PASS$')" = 3 ] && [ "$(cnt "$B" '  exit 0')" = 3 ] || die "anchor B: the cause bound in each of the three requests (S5.15)"
  ABX=$(printf '%s\n' "$B" | sed -n 's/^  the request failed, on the request thread \[omcat-handler-<n>\]: //p' | sort -u)
  [ "$(printf '%s\n' "$ABX" | $G -c .)" = 1 ] && [ "$ABX" = "java.util.concurrent.ExecutionException: $LZX" ] || die "anchor B: one failure line, on the request thread, the harness's exception inside ExecutionException: ${ABX:-none}"
  [ "$(cnt "$B" "$(SQ 4 4 4 0)")" = 3 ] || die "anchor B: the read's SQL on the virtual threads, 4 lines a request"
  has "$B" "    $SEVL" "anchor B: the seven's dashboard line 500 (its hash is not published: the timestamp)"
  has "$N" '  the JVM ended by itself: exit 1 · listening on 20081: 0' "anchor: the H2 user trap - the start fails, no port (S5.20)"
  ANU=$(printf '%s\n' "$N" | sed -n 's/^    Caused by: org.h2.jdbc.JdbcSQLInvalidAuthorizationSpecException: //p'); [ "$ANU" = 'Wrong user name or password [28000-250]' ] || die "anchor: the H2 user trap's line: ${ANU:-none}"
  for l in "$A:20081" "$A2:20082"; do
    has "${l%:*}" "  listens on: 127.0.0.1:${l##*:}" "anchor A: loopback"; has "${l%:*}" "  stopped by its pid (SIGTERM): exit 143 · listening on ${l##*:} now: 0" "anchor A: stopped"
    [ "$(cnt "${l%:*}" '  -> 200')" = 2 ] && has "${l%:*}" "  -> 200 $JSON4" "anchor A: the page twice 200, the JSON's four keys"
    [ "$(cnt "${l%:*}" "$(SQ 8 8 4 0)")" = 3 ] && [ "$(cnt "${l%:*}" "$(SQ 1 0 0 1)")" = 1 ] || die "anchor A: 8 SQL lines a dashboard request, on the virtual threads; GET /customers 1"
    [ "$(cnt "${l%:*}" "$(CRT com.tiffinbox.CustomerRepository.pausedDaysByCustomer 1 'virtual threads')")" = 3 ] && [ "$(cnt "${l%:*}" '  the manager: Participating in existing transaction - 1')" = 3 ] || die "anchor A: the manager creates pausedDaysByCustomer's transaction and findAll joins it, each request"
    [ "$(printf '%s\n' "${l%:*}" | $G -c "^  A's check: the header 'Paused days' is column 6; .* - PASS$")" = 2 ] || die "anchor A: the column parsed by its header, row by row against the second connection (S5.15)"; done
  AP=$(printf '%s\n' "$A" | sed -n "s/^  A's check: the header 'Paused days' is column 6; the page \(.*\); the second connection's sum .* - PASS$/\1/p" | sort -u)
  [ "$AP" = 'Meera 0 · Priya 2 · Ravi 0 · Sunil 3' ] || die "anchor A: the page's column: ${AP:-none}"
  [ "$(printf '%s\n' "$A" | sed 's/2008[12]/<port>/g; s/u29a2\{0,1\}/<db>/g; s#\.harness/a[a-z0-9]*#.harness/<A>#g; s/^A2\{0,1\} - .*$//')" = "$(printf '%s\n' "$A2" | sed 's/2008[12]/<port>/g; s/u29a2\{0,1\}/<db>/g; s#\.harness/a[a-z0-9]*#.harness/<A>#g; s/^A2\{0,1\} - .*$//')" ] || die "anchor A': after/ built again prints what A printed (R.1)"
  echo "  anchor: the change - CustomerRepository, Dashboard, dashboard.html, the README; B (labelled, its 18 tests passed): the page and the JSON 500, each bound to $ABX on the request thread, the read's SQL on virtual threads; the H2 user trap: exit 1, $ANU; A: 200, the column $AP = the second connection, 8 SQL lines a request, the manager's pausedDaysByCustomer; A' = A"; }
# (a)'s switch-on check (S5.16): every dashboard request's interceptor lines on the request thread, and one interceptor bean - a run
# without the flag fails it; it is run on both and must pass on the first and fail on the control
osivchk() { local o; o=$(printf '%s\n' "$1" | $G -c '^  OpenEntityManagerInViewInterceptor: Opening 2 (on the request thread 2) · Closing 2 (on the request thread 2)$' || true)
  [ "$o" = 3 ] && printf '%s\n' "$1" | $G -qxF '  OpenEntityManagerInViewInterceptor beans (the beans'"'"' types read by python3 -I): 1'; }
WA=""; WAR=""; WH=""; WB=""; WBH=""; WC=""; WD1=""; WD2=""; WDT=""
chk_wrong() { local W ON OFF H E EH C CH D1 D2 TX w
  W=$(cat .r-wrong.out)
  ON=$(blk wrong '(a) open-in-view switched on' '(a) the control'); OFF=$(blk wrong '(a) the control' '(a) the held'); H=$(blk wrong '(a) the held' '(b) EAGER - labelled')
  E=$(blk wrong '(b) EAGER - labelled' '(b) EAGER in the harness'); EH=$(blk wrong '(b) EAGER in the harness' '(c) enable'); C=$(blk wrong '(c) enable' '(c) in the harness'); CH=$(blk wrong '(c) in the harness' '(d) the controller')
  D1=$(blk wrong "(d) the controller" '(d) un-finaled'); D2=$(blk wrong '(d) un-finaled' '(e) the read'); TX=$(blk wrong '(e) the read' '')
  osivchk "$ON" || die "(a): open-in-view on - the interceptor's Opening/Closing 2 each on the request thread in every dashboard request, and its bean (S5.16)"
  ! osivchk "$OFF" || die "(a): the control must fail the switch-on check - it passed (a check that cannot fail, R.226)"
  [ "$(cnt "$OFF" '  OpenEntityManagerInViewInterceptor: Opening 0 (on the request thread 0) · Closing 0 (on the request thread 0)')" = 4 ] && has "$OFF" "  OpenEntityManagerInViewInterceptor beans (the beans' types read by python3 -I): 0" "(a) control: 0 lines, 0 beans"
  [ "$(cnt "$ON" '  -> 500')" = 2 ] && [ "$(printf '%s\n' "$ON" | $G -c '^  B.s check: .* - PASS$')" = 2 ] && [ "$(cnt "$ON" "$(SQ 4 4 4 0)")" = 3 ] || die "(a): the dashboard still 500, the cause bound, the read's SQL on virtual threads"
  WAR=$(printf '%s\n' "$ON" | sed -n 's/^  -> 200 //p'); [ "$WAR" = '{"Meera":0,"Priya":2,"Ravi":0,"Sunil":3}' ] && has "$ON" "$(SQ 5 0 0 5)" "(a) route: 5 SQL lines on the request thread" && has "$ON" '  OpenEntityManagerInViewInterceptor: Opening 1 (on the request thread 1) · Closing 1 (on the request thread 1)' "(a) route: one interceptor Opening" || die "(a): the route 200 from the same JVM: ${WAR:-none}"
  has "$OFF" "  -> 500 {\"timestamp\":\"<time>\",\"status\":500,\"error\":\"Internal Server Error\",\"path\":\"/customers/paused\"}" "(a) control: the route 500 without the flag"
  ver "$(printf '%s\n%s\n%s\n%s\n' "$H" "$EH" "$CH" "$TX")" 4 "wrong's harness JVMs"
  has "$H" '  PROBE after the reads: Hikari active 1' "(a) held: active 1 after the reads"; has "$H" '  PROBE before the close: Hikari active 1' "(a) held: still 1 before the close"; has "$H" "  PROBE after the close (afterCompletion's call): Hikari active 0" "(a) held: 0 after the close"
  w=$(w3 "$(printf '%s\n' "$H" | sed -n '/>>> findAll + pauses on the bound thread/,/<<< findAll/p')"); [ "$w" = '5 1 0 4 6' ] || die "(a) held: the bound thread's read, 5 statements, one connection: $w"
  has "$H" "  PROBE threw: java.util.concurrent.ExecutionException: $LZX" "(a) held: the same read on a virtual thread refused"
  WH='Hikari active 1 after the reads, 1 before the close, 0 after it'
  [ "$(cnt "$E" "$(SQ 5 0 0 5)")" = 1 ] && [ "$(cnt "$E" "$(SQ 12 12 4 0)")" = 1 ] && [ "$(printf '%s\n' "$E" | $G -c "^  A's check: .* - PASS$")" = 1 ] || die "(b): GET /customers 5 SQL lines, the dashboard 12, the column right"
  w=$(w3 "$(printf '%s\n' "$EH" | sed -n '/>>> ECustomer (pauses EAGER): em.find/,/<<< ECustomer (pauses EAGER): em.find/p')"); [ "${w%% *}" = 1 ] || die "(b) harness: em.find - 1 statement: $w"
  w=$(w3 "$(printf '%s\n' "$EH" | sed -n '/>>> ECustomer (pauses EAGER): select/,/<<< ECustomer (pauses EAGER): select/p')"); [ "$w" = '5 1 1 4 6' ] || die "(b) harness: the JPQL list - 1 + 4 statements: $w"
  WB='GET /customers 1 -> 5 SQL lines, the dashboard 8 -> 12; harness em.find 1, a JPQL list 5'
  [ "$(cnt "$C" '  -> 200')" = 1 ] && has "$C" "$(SQ 8 8 4 0)" "(c): 8 SQL lines" && [ "$(printf '%s\n' "$C" | $G -c "^  A's check: .* - PASS$")" = 1 ] || die "(c): the page 200, 8 lines, the column right"
  w=$(w3 "$CH"); [ "$w" = '5 5 5 4 6' ] || die "(c) harness: 5 statements, getConnection 5, sessionOpenCount 5: $w"
  has "$CH" '  PROBE hibernate.generate_statistics true · hibernate.enable_lazy_load_no_trans true' "(c): the property read back on"
  WC=$(printf '%s\n' "$CH" | sed -n "s/^  its WARN lines (grep -c '^WARN '): //p"); [ "$WC" = 0 ] || die "(c): its WARN lines: ${WC:-none}"
  has "$D1" '  the JVM ended by itself: exit 1 · listening on 20087: 0' "(d): the start fails, no port (S5.20)"
  WD1=$(printf '%s\n' "$D1" | sed -n 's/^    Caused by: \(org.springframework.aop.framework.AopConfigException: .*\)$/\1/p'); WD2=$(printf '%s\n' "$D1" | sed -n 's/^    Caused by: \(java.lang.IllegalArgumentException: .*\)$/\1/p')
  [ "$WD1" = 'org.springframework.aop.framework.AopConfigException: Could not generate CGLIB subclass of class com.tiffinbox.web.DashboardPage: Common causes of this problem include using a final class or a non-visible clas …' ] && [ "$WD2" = 'java.lang.IllegalArgumentException: Cannot subclass final class com.tiffinbox.web.DashboardPage' ] || die "(d): the refusal's two lines, from that step's log (S5.20): ${WD1:-none} / ${WD2:-none}"
  ! printf '%s\n' "$D1" | $G -q -- '-> 500' || die "(d): the final class's step answered a request - it must be the refusal, not \"still 500\""
  has "$D2" "$(CRT com.tiffinbox.web.DashboardPage.page 1 'request thread')" "(d) un-finaled: the controller's transaction on the request thread"
  has "$D2" "$(CRT "$FINDALL" 2 'virtual threads')" "(d) un-finaled: findAll creates its own on the virtual threads"
  [ "$(cnt "$D2" '  -> 500')" = 1 ] && [ "$(printf '%s\n' "$D2" | $G -c '^  B.s check: .* - PASS$')" = 1 ] || die "(d) un-finaled: still 500, the cause bound"
  has "$D2" "$(CRT com.tiffinbox.web.TiffinBoxServer.paused 1 'request thread')" "(d) route: the route's transaction" && has "$D2" "$(SQ 5 0 0 5)" "(d) route: 5 lines" && has "$D2" '  -> 200 {"Meera":0,"Priya":2,"Ravi":0,"Sunil":3}' "(d) route: 200"
  has "$TX" "  PROBE threw: $LZX" "(e): the read with no transaction refused"
  w=$(w3 "$(printf '%s\n' "$TX" | sed -n '/>>> the page.s read in @Transactional/,/<<< the page.s read in @Transactional/p')"); [ "$w" = '5 1 1 4 6' ] || die "(e): the read's own transaction - 1 + 4: $w"
  w=$(w3 "$(printf '%s\n' "$TX" | sed -n '/>>> Hibernate.initialize/,/<<< Hibernate.initialize/p')"); [ "$w" = '5 1 1 4 6' ] || die "(e): Hibernate.initialize - the same 5: $w"
  echo "  wrong: (a) open-in-view - the dashboard still 500 (cause bound), Opening/Closing 2/2 a request on the request thread, beans 1; the control 0/0, beans 0 (the check fails on it); the route 200, 5 SQL lines, $WAR; $WH · (b) EAGER - $WB · (c) no_trans - the page 200, 8 lines; harness 5 statements, getConnection 5, sessionOpenCount 5, WARN lines $WC · (d) final: exit 1, $WD2; un-finaled: DashboardPage.page's transaction on the request thread, findAll's own on the virtual threads, still 500; the route 200, 5 lines · (e) the read's transaction 5, Hibernate.initialize 5"; }
S466=466c20ed7e0d5439cb052f32ce09de1b
SVB=""; SVA=""
chk_seven() { local SV
  SV=$(cat .r-seven.out)
  [ "$(cnt "$SV" "  exit 0 · the seven responses: 7 lines · md5 $S466")" = 2 ] && has "$SV" '  the seven, after/ against before/: lines that differ: 0' "seven: $S466 on both trees (a guard)" || die "seven: $S466 on both trees"
  SVB=$(printf '%s\n' "$SV" | sed -n "s/^  its log's org.hibernate.SQL lines during the seven: //p" | sed -n 1p); SVA=$(printf '%s\n' "$SV" | sed -n "s/^  its log's org.hibernate.SQL lines during the seven: //p" | sed -n 2p)
  [ -n "$SVB" ] && [ -n "$SVA" ] || die "seven: the SQL lines during the seven"
  echo "  seven: $S466 on before/ and after/, 0 lines differ (a guard); SQL lines during the seven $SVB -> $SVA (the JSON dashboard runs the fourth read too)"; }
chk_tests() { local TS l
  TS=$(cat .r-tests.out)
  for l in '    TEST-com.tiffinbox.web.TiffinBoxWebTest.xml: tests 14 · failures 0 · errors 0 · skipped 0' '    TEST-com.tiffinbox.web.FullStackTest.xml: tests 3 · failures 0 · errors 0 · skipped 0' '    TEST-com.tiffinbox.web.FeedTest.xml: tests 1 · failures 0 · errors 0 · skipped 0' \
      "  Surefire's console summary (its Results line): tests 18 · failures 0 · errors 0 · skipped 0 · the reports' sum the same: yes" '  exit 0 · BUILD SUCCESS · offline: yes' \
      '    TiffinBoxWebTest.java: CustomerRepository 1 · Dashboard 1' '    FullStackTest.java: CustomerRepository 1 · Dashboard 0'; do has "$TS" "$l" "tests"; done
  [ "$(cnt "$TS" '    in all: 3 reports · tests 18 · failures 0 · errors 0 · skipped 0')" = 2 ] || die "tests: 18 on after/ and 18 on B (labelled)"
  echo "  tests: 18 (14/3/1) on after/ from the reports, the console the same; 18 on B too - a guard (R.190; C7-4)"; }
chk_xcheck() { local XC
  XC=$(cat .r-xcheck.out)
  has "$XC" "  its md5: $X27 · the filed xcheck.sql: $X27 · cmp: the same, byte for byte · the version lesson's xcheck.sql: the same, byte for byte" "xcheck: after/'s script = unit 27's, byte for byte (no mapping moved)"
  [ "$(cnt "$XC" "$VERH")" = 1 ] || die "xcheck: HHH000001"
  echo "  xcheck: after/'s script $X27 = xcheck.sql = ../c7-unit27/xcheck.sql"; }
EXQ="Your turn: the README's page lists each customer's paused days and fails outside a transaction. Make it work without open-in-view."
EXW=$(printf '%s\n' "$EXQ" | wc -w | tr -d ' ')
EXB=""; EXS=""
chk_exercise() { local EB EZ b ER ES w
  EB=$(blk exercise "in bash" "in zsh"); EZ=$(blk exercise "in zsh" "")
  for b in "$EB" "$EZ"; do
    ER=$(printf '%s\n' "$b" | sed '/then the solution/,$d'); ES=$(printf '%s\n' "$b" | sed -n '/then the solution/,$p')
    has "$ER" '    the JVM: exit 0' "exercise: the README runs"; has "$ES" '    the JVM: exit 0' "exercise: the solution runs"
    EXB=$(printf '%s\n' "$ER" | sed -n 's/^    PROBE the page threw: //p'); EXS=$(printf '%s\n' "$ES" | sed -n 's/^    PROBE the page: //p')
    [ "$EXB" = "org.hibernate.LazyInitializationException: Cannot lazily initialize collection of role 'probe.u.ex.Diner.breaks' with key '2' (no session)" ] || die "exercise: the README's run - the page refused: ${EXB:-none}"
    [ "$EXS" = '{Meera=0, Priya=2, Ravi=0, Sunil=3}' ] || die "exercise: the solution's page: ${EXS:-none}"
    has "$ES" '    [main] org.springframework.orm.jpa.JpaTransactionManager : Creating new transaction with name [probe.u.ex.Page.pausedDays]' "exercise: the read's own transaction"
    nhas "$ER" 'Page.pausedDays]' "exercise broken: no transaction for the read"
    [ "$EXB" != "$EXS" ] || die "exercise: broken and solved must differ (R.196)"
    [ "$(printf '%s\n' "$b" | $G -c "^  the shell is now in: this unit's folder")" = 2 ] || die "exercise: the shell back in this folder"; done
  [ "$(printf '%s\n' "$EB" | $G -v '^in ')" = "$(printf '%s\n' "$EZ" | $G -v '^in ')" ] || die "exercise: bash and zsh print the same"
  w=$(printf '%s\n' "$EB" | sed '/then the solution/,$d' | sed -n '/^  the block.s exit /,/^  the shell is now in: /p' | sed '1d;$d' | sed 's/^    //')
  [ "$(wib exercise/README.md)" = "$w" ] || die "exercise/README.md's \"What it prints\" block is not what the README's lines printed: $(diff <(wib exercise/README.md) <(printf '%s\n' "$w") | head -3 | paste -sd' ' -)"
  w=$(printf '%s\n' "$EB" | sed -n '/then the solution/,$p' | sed -n '/then the solution/,/^  the shell is now in: /p' | sed '1d;$d' | sed 's/^    //')
  [ "$(wib exercise/SOLUTION.md)" = "$w" ] || die "exercise/SOLUTION.md's \"What it prints\" block is not what the solution's lines printed: $(diff <(wib exercise/SOLUTION.md) <(printf '%s\n' "$w") | head -3 | paste -sd' ' -)"
  $G -qxF -- "**Your turn:** ${EXQ#Your turn: }" exercise/README.md || die "exercise/README.md: the spoken exercise line"
  [ "$EXW" = 20 ] || die "exercise: the spoken line is the brief's 20 words: $EXW"
  echo "  exercise: bash and zsh alike - the README as written: $EXB; the solution (one line: @Transactional(readOnly = true) on the read): $EXS; each file's What it prints = the run; $EXW words"; }
cap lazy lazy; chk_lazy; pub lazy
cap anchor anchor; chk_anchor; pub anchor
cap wrong wrong; chk_wrong; pub wrong
cap seven seven7; chk_seven; pub seven
cap tests tests; chk_tests; pub tests
cap xcheck xcheck; chk_xcheck; pub xcheck
cap exercise exercise; chk_exercise; pub exercise

# the values the video says are the captures', never typed: README.md holds them, composed here from the checks' reads
VS="the values the video may say: on H2 2.5.250, Spring Framework 7.0.10, Spring Data JPA 4.1.2, Hibernate 7.4.13.Final - lazy: findAll outside a transaction 1 statement, $LZN's pauses $LZB, Hibernate.isInitialized false, then $LZX (the key $LZK: $LZN, the first by name); getReferenceById(3): $LZC, getId() 3 with 0 statements, getName(): $LZP · anchor B (no transaction, 18 tests passed): the page and the JSON 500, the cause on the request thread: $ABX; the seven's line $SEVL · the H2 user trap: $ANU · A: 200, Paused days $AP (column 6, = the second connection), 8 SQL lines a dashboard request, the manager: Creating new transaction with name [com.tiffinbox.CustomerRepository.pausedDaysByCustomer], Participating in existing transaction · wrong (a): still 500, Opening 2 · Closing 2 a request on the request thread, beans 1; the control 0 · 0, beans 0; the route 200, 5 SQL lines, $WAR; $WH · (b): $WB · (c): the page 200, 8 SQL lines; sessionOpenCount 5, getConnection 5, WARN lines $WC · (d): exit 1, $WD2; un-finaled still 500; the route 200, 5 SQL lines · (e): 5, Hibernate.initialize 5 · seven: $S466 before and after · tests: 18 (14/3/1), on B 18 · xcheck: $X27 · exercise: $EXB -> $EXS ($EXW words)"
$G -qF -- "$VS" README.md || die "README.md does not state the values these captures give ('$VS') - a typed value: $($G -oE 'the values the video may say: [^*`]*' README.md | head -1 | cut -c1-300)"
echo "  README.md states the captures' values: $VS"
# hygiene: every capture and every file this unit holds - 0 raw tokens
for f in .harness/raw-*; do [ "$(cat "$f")" = 0 ] || die "a capture's raw output held the token ($f)"; done
for f in .r-*.out README.md exercise/README.md exercise/SOLUTION.md receipts.md5 .harness/*.log; do [ "$(raw "$TOKEN" "$f")" = 0 ] || die "$f holds the token, raw"; done
DN=$(dishes .r-*.out); [ -z "$DN" ] || die "a capture holds an Indian dish name (R.215): $DN"
[ "$LOGS" -gt 0 ] || die "no JVM ran"
[ "$GENW" = 0 ] || die "a schema step failed in a log: 'GenerationTarget encountered exception' $GENW times (R.213)"
for f in .r-*.out; do
  ! $G -qE '/Users/|/private/|/home/|/var/folders/' "$f" || die "$f holds an absolute path"
  ! $G -vE '^    [-+ ]' "$f" | $G -qE 'c[0-9]-unit[0-9]|unit ?[0-9]' || die "$f holds a unit number (a source's diff lines, quoted whole, aside)"
  ! $G -qE ' (with PID|started by) |Time elapsed|time="| in [0-9.]+ seconds' "$f" || die "$f holds Boot's process line, a time or Boot's seconds"
  ! $G -qE '^ *[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9][T ]|"timestamp":"?[0-9]|(exec|handler|task)-[0-9]|started on [A-Z]' "$f" || die "$f holds a log time, a timestamp, a thread number or a context's start date"
  ! $G -qE 'using Java [0-9]|Darwin|arm64|aarch64|musl' "$f" || die "$f holds an OS or a JDK version token (R.151)"
  ! $G -qE 'jdbc:h2:mem:[0-9a-f]{8}-' "$f" || die "$f holds a generated database name, unmasked"
  ! $G -qE 'SessionImpl\([0-9]|scanning in [0-9]+ ms|Lambda/0x' "$f" || die "$f holds an EntityManager's identity, a lambda's address or a scan time, unmasked"
  ! $G -qE '[0-9]+\.[0-9]+ ms|[0-9] ms\b' "$f" || die "$f holds a millisecond figure (R.207)"
  ! $G -qE '^ +at [a-z]' "$f" || die "$f holds a stack frame"
  ! $G -oE 'https?://[^ /]*' "$f" | $G -qvxE 'http://127\.0\.0\.1:2008[0-7]' || die "$f holds a URL (only TiffinBox's own loopback ports 20080-20087 may appear)"; done
for f in .r-*.out; do ! $G -E '^ *\$ .*(^|[ (])java ' "$f" | $G -vF -- "java $JL " > /dev/null || die "$f starts a JVM without its locale pinned (S6.1)"
  ! $G -E '^ *\$ .*(^|[ (])java -D' "$f" | $G -vF -- "perl -e 'alarm " > /dev/null || die "$f starts a JVM without its alarm (R.247)"; done
K1='pki''ll'; K2='kill''all'; ! $G -v '^ *#' receipts.sh | $G -qwE "$K1|$K2" || die "receipts.sh names $K1 or $K2 - every process is stopped by its pid"
for f in receipts.sh exercise/README.md exercise/SOLUTION.md; do ! $G -nE '(^|[;&|({] *)wait *($|[;&|)}])' "$f" | $G -vE '^[0-9]+: *#' > /dev/null || die "$f has a bare wait (S6.9)"; done
! $G -rq 'probe\.u' after/tiffinbox-web after/tiffinbox-core || die "the anchor's code names the course's harness - it is never TiffinBox's"
! $G -rqE '^package com\.tiffinbox' harness/src || die "a harness class sits in com.tiffinbox (R.43)"
! $G -rqE 'Thread\.sleep' harness/src || die "a harness sleeps (S4.18)"
[ -z "$(find . "$UP" -maxdepth 1 \( -name '*.mv.db' -o -name '*.trace.db' \) 2> /dev/null; find . -path ./.m2-demo -prune -o -path ./.harness -prune -o \( -name '*.mv.db' -o -name '*.trace.db' \) -print)" ] || die "an H2 database file exists outside .harness - every H2 here is in memory (R.195)"
echo "  hygiene: raw token copies after mask: 0 in $(ls .harness/raw-* | wc -l | tr -d ' ') raw capture runs, $(ls .r-*.out | wc -l | tr -d ' ') captures and every log ($LOGS JVM logs); 'GenerationTarget encountered exception' 0; no path, unit number, time, millisecond figure, OS token, unmasked identity or generated name, URL or stack frame in any capture; every JVM pinned and under its alarm; no kill by name; no bare wait; no sleep in the harness; no H2 file"
# ---- the end: the anchor, the ports ----------------------------------------------------------------------------------------
if [ -n "$spid" ] && kill "$spid" 2> /dev/null; then wait "$spid" 2> /dev/null || true; fi; spid=""
anchornote end
for p in $PORTS; do [ "$(listeners $p)" = 0 ] || die "something listens on $p at the end"; done
echo "  ports: nothing listens on 18425, 8080, 35729 or 20080-20089 at the end - TiffinBox bound 20080-20087 and stopped, the H2 server 20088 and stopped; 20089 never bound"
[ -z "$unpub" ] || die "no published hash for:$unpub - check the captures, then copy the md5s above into receipts.md5 and run again"
echo "c7-unit29: every capture 3/3 and = published; every spoken number asserted; 0 raw tokens; no port bound but 20080-20088"
