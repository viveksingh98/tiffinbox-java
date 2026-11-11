#!/bin/bash
XPATH=$PATH                                           # the PATH you started this with: the exercise's own shells get it
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25.0.4.1 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# Course 7 · Rollback Rules - this unit's receipts. The course's eighth change to the anchor, Section 4's first (brief flag 1, C1):
# before/ is the link to ../c7-unit17/after (Section 3's frozen anchor); after/ is this unit's tree, and ../c7-tiffinbox equals it.
# TiffinBox gets its first @Transactional - on CustomerRepository.add, with rollbackFor = SQLException.class - and so loses `final`;
# add publishes CustomerAdded inside its transaction, CustomerFeed hears it with @TransactionalEventListener (after the commit), and
# the three web classes that told the feed themselves no longer do (nor take CustomerFeed). Ten captures, each run three times and
# hashed; a hash that differs from receipts.md5 stops the run; every number and string the video says is asserted right after its
# capture by a check that can fail. One database: H2, in each JVM's memory.
#   rules         the ten rows (harness, over before/'s libraries): a checked exception, rollbackFor, a RuntimeException,
#                 noRollbackFor, an Error, an exception caught inside, setRollbackOnly(), and JTA's annotation three ways; each row
#                 its attribute (this context's TransactionAttributeSource), the manager's line, the interceptor's TRACE line, the
#                 method's own print and the second connection's read after the call (S4.1)
#   allexceptions the same ten rows, LABELLED: the profile allx - @EnableTransactionManagement(rollbackOn = ALL_EXCEPTIONS); the
#                 annotation's default read off spring-tx's jar (javap -v); Boot's TransactionProperties' fields (javap -p)
#   twowrites     a customer saved, a checked FileNotFoundException before her pause; then rollbackFor (harness, before/'s)
#   events        the listeners (harness, over after/'s libraries, S4.10): a plain @EventListener before the commit, AFTER_COMMIT
#                 after it, AFTER_ROLLBACK, no transaction (skipped), an AFTER_COMMIT listener that throws (the row kept), and the
#                 anchor's own CustomerRepository.add with a listener for its CustomerAdded
#   anchor        the change (after/ against before/), the sentences that state the feed's source (R.250); TiffinBox A/B/A'/B'
#                 (S4.9): B = after/ with the rule taken off add (plain @Transactional) - POST Kavya 201, the same again 500, the
#                 import 500 - and its 18 tests passed; A = after/ - 201, 409, the import 200 added 2; B' and A' built again
#   feed          after/'s jar, a listener on GET /customers/feed, then Course 6's three adds - a JSON POST, a form POST, an upload's
#                 row: three customer-added events; B'' = after/ with add's @Transactional taken off (the event published with
#                 no transaction) - its tests: FeedTest's TimeoutException
#   seven         before/'s jar and after/'s, the seven each, Hibernate's SQL logger on (a guard, R.190)
#   tests         TiffinBox's tests on after/ (the README's line, offline), from Surefire's reports (C7-4)
#   xcheck        the harness's DDL script over after/'s libraries against the owning-side lesson's published md5 (R.212)
#   exercise      exercise/README.md's commands, then exercise/SOLUTION.md's, read from the files and run as written, in ONE env -i
#                 shell - /bin/bash, then again in /bin/zsh -f; each file's "What it prints" block = what it printed
# Every tree is COPIED under .harness/ and built there, never in place, with the README's package line, offline (before/ and after/
# and B run their tests inside that build; B', A' and the B'' copy are built or tested as said). The harness (harness/src, packages
# probe.t, probe.t.ev and probe.x, outside com.tiffinbox) is compiled twice with javac -parameters: probe.t and probe.x against
# before/'s extracted libraries into .harness/hc (rules, allexceptions, twowrites), and all three against after/'s into .harness/hce
# (events, xcheck; probe.t.ev reads the anchor's CustomerAdded, which only after/ has). probe.t.Main is a Spring Boot context with no
# web server (WebApplicationType.NONE: it binds no port), @EntityScan and @EnableJpaRepositories on com.tiffinbox - the anchor's own
# CustomerEntityRepository; probe.t.Seed builds the shipped Database in code on the run's own H2 database; ddl-auto none. Logback
# (harness/logback.xml) prints Hibernate's SQL logger, the transaction manager's DEBUG lines (S4.1's first witness), the transaction
# interceptor's TRACE lines and the transaction event package's DEBUG lines. The method's own TransactionSynchronizationManager print
# is the second witness; the third is the second connection: DriverManager on the same jdbc:h2:mem:u26 URL, read after the call
# returned or threw - and, in events, inside each listener (S4.10). Every JVM's flags travel as an array, V, its arguments as an
# array, A (R.193); every JVM runs under an alarm (perl -e 'alarm N; exec ...': macOS has no timeout); an alarm that fires is a failed
# receipt (R.247). Commands are printed exactly as they run: each goes through eval. harness/dur7.py (Course 7's builders' duration
# pattern, byte for byte) and S4.7's duration-meaning family gate this unit's prose: it speaks no time (R.172, R.264). "$M2" is this
# unit's .m2-demo. "$CURLSET" is ../c5-unit11/curlset.sh (the seven, POST /shutdown last). harness/surefire.py (the testing lesson's,
# byte for byte) reads Surefire's reports. The locale: every JVM has its locale pinned on its run line (-Duser.language=en
# -Duser.country=US).
# The network: every Maven run is offline (-o) against .m2-demo and says so ("offline: yes"); a build that cannot resolve an artifact
# offline is run once more without -o and says so, naming what it fetched. At run time nothing leaves the machine: H2 in memory;
# TiffinBox listens on 127.0.0.1 only and is asked on the loopback. This unit reads no version file: the section's dated sweep is the
# brief's (R.223; _research/spring-boot-metadata-2026-11-10.xml, spring-data-bom-metadata-2026-11-10.xml).
# TiffinBox's token: generated here once (the anchor README's own line, in .harness/after) and copied into every tree's
# secrets/tiffinbox/shutdown-token, mode 0600, never printed, masked in every log; the captures and logs are counted for raw copies
# (0). TiffinBox is stopped by its pid, or - in seven - by the comparison set's POST /shutdown.
# Masks (README.md declares each; awk gsub only): the token; this folder "…", the folder above "…/..", home "~", your user name
# "<user>"; " using Java <version>"; an identity hash "@…"; an EntityManager's identity "SessionImpl(<n><open>)"; a lambda class's
# address "$$Lambda/<n>"; Spring Data's scan time; TiffinBox's generated database name "jdbc:h2:mem:<uuid>"; a context's "started on
# <date>"; H2's constraint names "CONSTRAINT_<n>" / "CONSTRAINT_INDEX_<n>"; a 500's "timestamp".
# Ports (§P, 20050-20059): 20050 anchor B · 20051 anchor A · 20052 B' · 20053 A' · 20054 feed · 20055 seven before/ · 20056 seven
# after/ · 20057 unused (xcheck binds none) · 20058 unused · 20059 never bound; all ten, 18425 (TiffinBox's default), 8080 and 35729
# checked free at the start and the end.
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
pid=""; lpid=""; mpid=""; xpid=""
sweep() { local g i l
  g=$(ps -o pgid= -p $$ 2> /dev/null | tr -d ' ') || g=""
  [ -n "$g" ] || return 0
  i=0; while [ $i -lt 20 ]; do
    l=$(ps -axo pid=,pgid=,command= 2> /dev/null | awk -v g="$g" -v me=$$ '
      $2 == g && $1 != me && $3 != "awk" && $3 != "ps" && (index($0, "probe.t.") || index($0, "probe.x.") || index($0, "tiffinbox-web-1.0.0.jar") || index($0, "/customers/feed") || index($0, "surefirebooter") || $3 ~ /(^|\/)javac$/ || index($0, "jdk.compiler/com.sun.tools.javac") || index($0, "org.codehaus.plexus.classworlds.launcher.Launcher")) { print $1 }' | paste -sd' ' -) || l=""
    [ -n "$l" ] || return 0
    if [ $i -lt 10 ]; then kill $l 2> /dev/null || true; else kill -9 $l 2> /dev/null || true; fi
    sleep 0.5; i=$((i + 1)); done; }
desc() { ps -axo pid=,ppid= 2> /dev/null | awk -v r="$1" '{ p[$1] = $2 } END { n = 1; q[1] = r; for (i = 1; i <= n; i++) for (c in p) if (p[c] == q[i]) { q[++n] = c; print c } }'; }
killtree() { local d; d=$(desc "$1"); kill "$1" $d 2> /dev/null || true; }
trap 'trap "" INT TERM; for p in "$mpid" "$xpid"; do [ -z "$p" ] || killtree "$p"; done; for p in "$pid" "$lpid" "$mpid" "$xpid"; do if [ -n "$p" ] && kill "$p" 2> /dev/null; then wait "$p" 2> /dev/null || true; fi; done; sweep || true; [ -z "$INTR" ] || rm -f .r-*.[123]; rmdir .r-lock 2> /dev/null || true' EXIT
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
[ -L before ] && [ "$(readlink before)" = ../c7-unit17/after ] || die "before must be the link to ../c7-unit17/after - the anchor before this change"
[ -d after ] && [ ! -L after ] || die "after/ must be this unit's own tree, not a link"
for t in before after; do
  [ -f "$t/pom.xml" ] && [ -f "$t/README.md" ] || die "the tree $t (its pom.xml or README.md) is missing"
  [ -e "$t/secrets" ] || [ -e "$t/target" ] || [ -e "$t/tiffinbox-web/target" ] || [ -e "$t/tiffinbox-core/target" ] || [ -e "$t/tiffinbox-local.yaml" ] || [ -e "$t/hibernate-ddl.sql" ] && die "$t holds a secrets/, a target/, a tiffinbox-local.yaml or a hibernate-ddl.sql - it is a frozen copy, never built in place"
  true; done
# after/ is this unit's tree; the anchor, ../c7-tiffinbox, equals it until a later unit (27) changes the anchor - a note then, never
# a stop (R.211)
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
HS=harness/src/probe/t
HFILES='dur7.py logback.xml src surefire.py'
SFILES='probe/t/AllX.java probe/t/H.java probe/t/Jta26.java probe/t/Main.java probe/t/Rb26.java probe/t/Run.java probe/t/Seed.java probe/t/ev/Added.java probe/t/ev/Ev26.java probe/t/ev/FeedListeners.java probe/t/ev/FeedSvc.java probe/t/ex/ExApp.java probe/x/XMain.java'
for f in exercise/README.md exercise/SOLUTION.md README.md receipts.md5; do [ -f "$f" ] || die "$f is missing"; done
[ "$(ls harness | paste -sd' ' -)" = "$HFILES" ] && [ "$(cd harness/src && find . -type f | sed 's#^\./##' | sort | paste -sd' ' -)" = "$SFILES" ] || die "harness/ holds another file, or misses one"
[ "$(ls exercise | paste -sd' ' -)" = 'README.md SOLUTION.md' ] || die "exercise/ holds another file"
[ "$(md5 -q harness/dur7.py)" = 41667fed9ffcefe171389eed7e654e66 ] || die "harness/dur7.py is not the builders' dur7.py (md5 41667fed…)"
if [ -f ../../../data-jpa-hibernate/_builders/dur7.py ]; then cmp -s harness/dur7.py ../../../data-jpa-hibernate/_builders/dur7.py || die "harness/dur7.py differs from the builders' _builders/dur7.py"
  echo "  (terminal only) harness/dur7.py = the builders' _builders/dur7.py, byte for byte" >&3
else echo "  (terminal only) the builders' _builders/dur7.py is not beside this clone: its md5 above is the check" >&3; fi
cmp -s harness/surefire.py ../c6-unit28/harness/surefire.py || die "harness/surefire.py is not the testing lesson's (../c6-unit28/harness/surefire.py), byte for byte"
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
PORTS="18425 8080 35729 20050 20051 20052 20053 20054 20055 20056 20057 20058 20059"
for p in $PORTS; do
  [ "$(listeners $p)" = 0 ] || die "something already listens on $p - this unit's ports must be free; if it is a process an interrupted run left behind, stop it: kill $(lsof -nP -iTCP:$p -sTCP:LISTEN -t 2> /dev/null | paste -sd' ' -)"; done
rm -rf .harness; mkdir -p .harness/run .harness/hc .harness/hce

# ---- the prose gates ----------------------------------------------------------------------------------------------------------
PROSE='README.md exercise/README.md exercise/SOLUTION.md'
# R.172 + S4.7 (R.264, RED #1211): dur7.DUR, and BLUE's duration-meaning family beside it
cat > .harness/dur.py <<'PY'
import importlib.util, re, sys
spec = importlib.util.spec_from_file_location("dur7", sys.argv[1]); m = importlib.util.module_from_spec(spec); spec.loader.exec_module(m)
FAM = re.compile(r"\b(?:forever|for ever|at once|immediately|instantly|instant(?:ly)?|right away|in no time|a moment|momentar(?:y|ily)|"
                 r"(?:one|two|three|four|five|six|seven|eight|nine|ten|a|\d+)\s+(?:second|minute|hour)s?|half a second|eventually)\b", re.I)
for t, want in (("forever", 1), ("at once", 1), ("immediately", 1), ("one second", 1), ("a moment", 1), ("3 seconds", 1),
                ("a timeout of one, as configured", 0), ("the second connection reads Ravi", 0), ("another bean", 0)):
    assert bool(m.DUR.search(t) or FAM.search(t)) == bool(want), t
# the Course 13 sentence (the brief's §LEDGER, pinned byte for byte, R.252) says "a second system" - an ordinal, no time; that one
# sentence, whole, is taken out of a line before the family reads it, and nothing else is (RED: the 26 builder needs the same)
C13 = "One transaction covers one database; a second system that must hear about the same change can fail after the commit."
assert FAM.search(C13) and not FAM.search(("x " + C13 + " y").replace(C13, ""))
n = f = 0
for p in sys.argv[2:]:
    for i, l in enumerate(open(p, encoding="utf-8"), 1):
        l = l.replace(C13, "")
        for w in m.DUR.finditer(l):
            n += 1; print("  %s line %d: %s  <- dur7: this unit speaks no time" % (p, i, w.group(0)))
        for w in FAM.finditer(l):
            f += 1; print("  %s line %d: %s  <- S4.7's family: a duration meaning" % (p, i, w.group(0)))
print("duration words: %d · duration meanings: %d" % (n, f))
PY
DW=$(python3 -I -B .harness/dur.py harness/dur7.py $PROSE) || die "the duration gate did not run (or its self-test failed)"
printf '%s\n' "$DW" | tail -1 | $G -qxF 'duration words: 0 · duration meanings: 0' || die "a duration word or meaning - this unit speaks no time (R.172, S4.7): $(printf '%s\n' "$DW" | $G '<-' | paste -sd';' -)"
echo "  duration words: 0 (dur7.DUR) · duration meanings: 0 (S4.7's family) over README.md, exercise/README.md, exercise/SOLUTION.md"
DISH='thali|khichdi|dal|daal|paneer|biryani|roti|chapati|chapatti|naan|sabzi|sabji|idli|dosa|sambar|rasam|rajma|chole|chana|poha|upma|paratha|pulao|pulav|raita|korma|tikka|masala|samosa|pakora|pakoda|halwa|kheer|jalebi|ladoo|laddu|vada|bhaji|aloo|gobi|jain'
dishes() { $G -rniwE -- "$DISH" "$@" 2> /dev/null | cut -c1-160 | head -3 | paste -sd';' - || true; }
DN=$(dishes README.md exercise harness/src)
[ -z "$DN" ] || die "an Indian dish name (R.215: English names only): $DN"
echo "  dish names: 0 ($(printf '%s\n' "$DISH" | tr '|' '\n' | wc -l | tr -d ' ') refused, whole words, any case, over README.md, exercise/, harness/src)"
PH=$($G -rnE 'EXERCISE-[A-Z-]*OUTPUT|[A-Z]+-OUTPUT\b|[A-Z]+-PARAGRAPH\b|TODO|TBD|PLACEHOLDER' README.md exercise 2> /dev/null | cut -c1-160 | head -3 | paste -sd';' - || true)
[ -z "$PH" ] || die "a placeholder line in this unit's prose - the exercise's blocks hold the measured output: $PH"
wib() { awk '/^What it prints/ { w = 1; next } w == 1 && /^```$/ { w = 2; next } w == 2 && /^```$/ { exit } w == 2 { print }' "$1"; }
for f in exercise/README.md exercise/SOLUTION.md; do [ "$($G -c '^What it prints' "$f")" = 1 ] && [ -n "$(wib "$f" | $G -v '^ *$' || true)" ] || die "$f must hold one \"What it prints\" line and, under it, a block that is not empty"; done
echo "  placeholders: 0 · each exercise file's \"What it prints\" block not empty (exercise compares it with the run, line for line)"
# after/README.md's unit 26 section - the anchor's own prose about this change, read by the gates below with the unit's prose
SECT=$(awk '/^## Course 7 · unit 26 /{f=1} f && /^## / && !/unit 26 /{f=0} f' after/README.md)
[ -n "$SECT" ] || die "after/README.md has no Course 7 · unit 26 section"
printf '%s\n' "$SECT" > .harness/section.md
# S4.10 + S4.14 (R.267, R.271): "the transaction has ended" said of the after-commit listener is refused - inside it
# isActualTransactionActive prints true (events); "the listener runs outside the transaction" likewise. Per sentence; a sentence
# that negates, or that quotes the capture's isActualTransactionActive, passes. The self-test runs its cases first.
cat > .harness/s410.py <<'PY'
import re, sys
END = re.compile(r"\btransaction\b[^.!?]*\b(?:has|had|is|was)\s+(?:already\s+)?(?:ended|over|finished|closed|gone|complete[d]?)\b"
                 r"|\b(?:after|once)\s+the\s+transaction\s+(?:has\s+)?(?:ended|is over|finished|closed)\b"
                 r"|\blistener\w*\b[^.!?]*\bruns?\b[^.!?]*\boutside\b[^.!?]*\btransaction\b", re.I)
OK = re.compile(r"\bnot\b|\bnever\b|\brefused\b|isActualTransactionActive|n't\b", re.I)
def bad(s): return bool(END.search(s)) and not OK.search(s)
cases = [("Inside the listener the transaction has ended.", True), ("After the commit the transaction is over, so the listener reads it.", True),
         ("The listener runs outside the transaction.", True), ("Once the transaction has ended, the feed is told.", True),
         ("Inside it, isActualTransactionActive prints true: never say the transaction has ended.", False),
         ("The listener hears the event after the commit, on the same thread.", False),
         ("A rolled-back add never reaches the feed.", False), ("The commit ran; the listener ran after it.", False)]
m = sum(bad(t) != w for t, w in cases)
assert m == 0, "s410 self-test: %d mismatches" % m
n = 0
for p in sys.argv[1:]:
    t = open(p, encoding="utf-8").read().replace("\n", " ")
    for s in re.split(r"(?<=[.!?])\s+", t):
        if bad(s):
            n += 1; print("  %s: %s  <- S4.10: inside AFTER_COMMIT isActualTransactionActive prints true" % (p, s.strip()[:160]))
print("S4.10 refused sentences: %d (self-test: %d cases, 0 mismatches)" % (n, len(cases)))
PY
SW=$(python3 -I -B .harness/s410.py $PROSE .harness/section.md after/$CJ/CustomerRepository.java after/$CJ/CustomerAdded.java after/$WJ/CustomerFeed.java) || die "S4.10's gate did not run (or its self-test failed)"
printf '%s\n' "$SW" | tail -1 | $G -q '^S4.10 refused sentences: 0 ' || die "S4.10: $(printf '%s\n' "$SW" | $G '<-' | head -3 | paste -sd';' -)"
echo "  $(printf '%s\n' "$SW" | tail -1) over README.md, exercise/, after/README.md's unit 26 section and the three event sources"
# R.225: a SQL string this unit shows is the logger's - a line of README.md holding the INSERT's head, Hibernate's alias or the
# count's SELECT is a typed SQL string, refused
SQLRE='insert into customer|ce1_0\.|select count\(\*\) from customer'
TS=$($G -nE "$SQLRE" README.md 2> /dev/null | cut -c1-160 | head -3 | paste -sd';' - || true)
[ -z "$TS" ] || die "a typed SQL string in README.md (R.225): $TS"
echo "  typed SQL strings: 0 in README.md"
# R.250: C1 moves who tells the feed - every sentence in after/ that stated the old mechanism is rewritten. The old sentences (each
# read off before/, asserted there first), the call and the field: 0 in after/'s sources and its README's unit 26 section; the class
# no longer final; the three web classes take no CustomerFeed
OLDS=('is sent to every client listening to CustomerFeed first.' 'A row that is stored is told to CustomerFeed,' 'every customer this route stores is told to CustomerFeed' 'stores - through the JSON API (TiffinBoxServer), the form (DashboardPage) or an upload (CustomerImport) - is sent to every' 'new customer (since the capstone, as they hear the JSON API'"'"'s)')
for s in "${OLDS[@]}"; do [ "$($G -rcF -- "$s" before/$WJ | awk -F: '{ n += $2 } END { print n + 0 }')" = 1 ] || die "R.250: before/ must hold the old sentence once: $s"
  [ "$($G -rcF -- "$s" after/$WJ after/$CJ .harness/section.md | awk -F: '{ n += $2 } END { print n + 0 }')" = 0 ] || die "R.250: after/ still states the old mechanism: $s"; done
FA=$($G -rn 'feed\.added' after/tiffinbox-web/src after/tiffinbox-core/src .harness/section.md | cut -c1-160 | paste -sd';' - || true)
[ -z "$FA" ] || die "R.250 (RED #1201): a feed.added call or sentence left in after/: $FA"
FF=$($G -nE 'CustomerFeed feed' after/$WJ/TiffinBoxServer.java after/$WJ/DashboardPage.java after/$WJ/CustomerImport.java | cut -c1-160 | paste -sd';' - || true)
[ -z "$FF" ] || die "RED #1201: a web class still takes CustomerFeed: $FF"
$G -qx 'public class CustomerRepository {' after/$CJ/CustomerRepository.java && $G -qx 'public final class CustomerRepository {' before/$CJ/CustomerRepository.java || die "C1: CustomerRepository is final on before/ and not on after/"
FB=$($G -rc 'feed\.added' before/$WJ | awk -F: '{ n += $2 } END { print n + 0 }')
[ "$FB" = 3 ] || die "before/'s web classes must call feed.added three times (TiffinBoxServer, DashboardPage, CustomerImport): $FB"
echo "  R.250: the five sentences that said the web layer tells the feed - once each in before/, 0 in after/'s sources and its unit 26 section; feed.added calls before/ $FB, after/ 0; the three web classes take no CustomerFeed; CustomerRepository final before/, not after/"

# ---- the commands: read from after/README.md, the anchor's own, and asserted - each line must be there, whole -------------
readme() { $G -m1 -xF -- "$1" after/README.md > /dev/null || die "after/README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
R_PLAIN=$(readme 'mvn -B package')
R_TEST=$(readme 'mvn -B clean test')
R_EXTRACT=$(readme 'java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted')
R_RUN=$(readme 'java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431')
R_POST=$(readme "curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '{\"name\":\"Asha\",\"mealsPerDay\":2,\"pricePerMeal\":110,\"mealType\":\"VEG\"}' http://127.0.0.1:18431/customers")
R_FORM=$(readme "curl -s -w ' %{http_code} · Location: [%header{location}]\n' -H 'Content-Type: application/x-www-form-urlencoded' --data 'name=Lata&mealsPerDay=2&pricePerMeal=120&mealType=VEG' http://127.0.0.1:18431/customers")
R_IMPORT=$(readme 'curl -s -w '"' %{http_code}\\n'"' -F "file=@customers.csv;type=text/csv" http://127.0.0.1:18431/customers/import')
R_GET=$(readme 'curl -s -w '"' %{http_code}\\n'"' http://127.0.0.1:18431/customers')
R_FEED=$(readme 'curl -s -N http://127.0.0.1:18431/customers/feed')
R_TOKEN=$(readme 'mkdir -p secrets/tiffinbox && (umask 077 && printf '"'"'%s\n'"'"' "$(openssl rand -hex 16)" > secrets/tiffinbox/shutdown-token)')
mine() { $G -m1 -xF -- "$1" README.md > /dev/null || die "README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
JL='-Duser.language=en -Duser.country=US'
AL="perl -e 'alarm 240; exec @ARGV'"
L_JAVAC=$(mine "javac -parameters -d .harness/hc -cp \".harness/before/$XD/lib/*\" $HS/AllX.java $HS/H.java $HS/Jta26.java $HS/Main.java $HS/Rb26.java $HS/Run.java $HS/Seed.java")
L_JAVACE=$(mine "javac -parameters -d .harness/hce -cp \".harness/after/$XD/lib/*\" $HS/AllX.java $HS/H.java $HS/Jta26.java $HS/Main.java $HS/Rb26.java $HS/Run.java $HS/Seed.java $HS/ev/Added.java $HS/ev/Ev26.java $HS/ev/FeedListeners.java $HS/ev/FeedSvc.java harness/src/probe/x/XMain.java")
L_H=$(mine "$AL java $JL -Dstdout.encoding=UTF-8 \"\${V[@]}\" -cp \"../hc:../before/$XD/lib/*\" probe.t.Main \"\${A[@]}\"")
L_HE=$(mine "$AL java $JL -Dstdout.encoding=UTF-8 \"\${V[@]}\" -cp \"../hce:../after/$XD/lib/*\" probe.t.Main \"\${A[@]}\"")
L_X=$(mine "$AL java $JL -Dstdout.encoding=UTF-8 -cp \"../hce:../after/$XD/lib/*\" probe.x.XMain \"\${A[@]}\"")
L_B=$(mine "perl -pi -e 's/^    \\@Transactional\\(rollbackFor = SQLException\\.class\\)\$/    \\@Transactional/' .harness/anb/$CJ/CustomerRepository.java")
L_BPP=$(mine "perl -ni -e 'print unless /^    \\@Transactional\\(rollbackFor = SQLException\\.class\\)\$/' .harness/bpp/$CJ/CustomerRepository.java")
L_TX=$(mine "$R_RUN --logging.level.org.springframework.orm.jpa.JpaTransactionManager=debug")
L_SQL=$(mine "$R_RUN --logging.level.org.hibernate.SQL=debug")
off() { local c=${2/mvn -B /mvn -o -B -Dmaven.repo.local=\"\$M2\" }
  [ -n "${3:-}" ] && c=${c/ $3/ clean $3}
  printf 'cd %s && %s\n' "$1" "$c"; }
exe() { printf '%s\n' "$1" | sed -E 's/&& (([A-Z_]+=[^ ]* )*)/\&\& \1exec /'; }
at() { local l=${3/--tiffinbox.port=18431/--tiffinbox.port=$2}; case $l in 'java '*) l="$AL java $JL ${l#java }" ;; esac; printf 'cd %s && %s\n' "$1" "$l"; }
url() { printf '%s\n' "$1" | sed "s#http://127.0.0.1:18431#http://127.0.0.1:$2#; s#^curl -s #curl -s --noproxy '*' #"; }
[ "$(off .harness/after "$R_PLAIN" package)" = 'cd .harness/after && mvn -o -B -Dmaven.repo.local="$M2" clean package' ] || die "off(): the build line is not the README's package line, offline"
[ "$(exe "$(at .harness/after 20051 "$R_RUN")")" = "cd .harness/after && exec $AL java $JL -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=20051" ] || die "at(): the run line is not the README's"
echo "  the commands: after/README.md gives the $($G -c '^R_[A-Z]*=$(readme ' receipts.sh) lines this script runs; README.md the $($G -c '^L_[A-Z0-9]*=$(mine ' receipts.sh) this unit adds"
JV=$(java -version 2>&1 | sed -n 's/.*version "\([^"]*\)".*/\1/p' | head -1)
echo "  (terminal only) the JDK is $JV - the captures say Java <version>" >&3

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
# anchor B: after/ with the rule taken off add (L_B: plain @Transactional) - that one line, asserted the only difference; B' a second
# copy of B, A' a second copy of after/ (R.1: a fresh build each); B'': after/ with add's annotation line removed (L_BPP)
copy after .harness/anb; (eval "$L_B") || die "L_B did not run"
ABD=$(diff -r .harness/after .harness/anb | $G -E '^[<>]' | paste -sd'|' - || true)
[ "$ABD" = '<     @Transactional(rollbackFor = SQLException.class)|>     @Transactional' ] || die "anchor B's copy must differ from after/ by add's rule taken off, and nothing else: ${ABD:-no difference}"
copy after .harness/bpp; (eval "$L_BPP") || die "L_BPP did not run"
BPD=$(diff -r .harness/after .harness/bpp | $G -E '^[<>]' | paste -sd'|' - || true)
[ "$BPD" = '<     @Transactional(rollbackFor = SQLException.class)' ] || die "B'' must differ from after/ by add's annotation line removed, and nothing else: ${BPD:-no difference}"
copy .harness/anb .harness/anb2; copy after .harness/ana2
mbuild "$(off .harness/before "$R_PLAIN" package)" .harness/build-before.log ".harness/before (before/, the README's package line; its tests ran)"
[ "$(summ4 .harness/build-before.log)" = '18 0 0 0' ] || die "before/'s tests: $(summ4 .harness/build-before.log) - expected 18 0 0 0"
mbuild "$(off .harness/after "$R_PLAIN" package)" .harness/build-after.log ".harness/after (after/, the README's package line; its tests ran)"
[ "$(summ4 .harness/build-after.log)" = '18 0 0 0' ] || die "after/'s tests: $(summ4 .harness/build-after.log) - expected 18 0 0 0"
mbuild "$(off .harness/anb "$R_PLAIN" package)" .harness/build-anb.log ".harness/anb (anchor B, labelled: add's rule taken off; the README's package line, its tests ran)"
[ "$(summ4 .harness/build-anb.log)" = '18 0 0 0' ] || die "anchor B's tests: $(summ4 .harness/build-anb.log) - the tests did not notice: expected 18 0 0 0"
mbuild "$(off .harness/anb2 "$R_PLAIN" package) -DskipTests" .harness/build-anb2.log ".harness/anb2 (anchor B', B copied again; the same line, -DskipTests)"
mbuild "$(off .harness/ana2 "$R_PLAIN" package) -DskipTests" .harness/build-ana2.log ".harness/ana2 (anchor A', after/ copied again; the same line, -DskipTests)"
echo "  the tests inside the builds (each build's summary lines summed): before/ $(summ4 .harness/build-before.log) · after/ $(summ4 .harness/build-after.log) · B $(summ4 .harness/build-anb.log) (run, failures, errors, skipped)"
for t in before after anb anb2 ana2; do (cd .harness/$t && eval "$R_EXTRACT") > .harness/extract-$t.log 2>&1 < /dev/null || die "the extract of $t failed: $(tail -3 .harness/extract-$t.log)"; done
for a in org/springframework/boot/spring-boot-starter-parent/4.1.2/spring-boot-starter-parent-4.1.2.pom org/hibernate/orm/hibernate-core/7.4.13.Final/hibernate-core-7.4.13.Final.jar org/springframework/data/spring-data-jpa/4.1.2/spring-data-jpa-4.1.2.jar org/springframework/spring-tx/7.0.10/spring-tx-7.0.10.jar com/h2database/h2/2.5.250/h2-2.5.250.jar; do
  [ -e "$M2/$a" ] || die "$a is not in .m2-demo - README.md, The repository"; done
(cd .harness/after && eval "$R_TOKEN") || die "the token was not written"
TOKEN=$(head -n 1 .harness/after/$TF); [ ${#TOKEN} = 32 ] || die "the generated token is not 32 characters"
for t in before anb anb2 ana2 bpp; do mkdir -p .harness/$t/secrets/tiffinbox && (umask 077 && cp .harness/after/$TF .harness/$t/$TF); done
for t in before after anb anb2 ana2 bpp; do [ "$(stat -f '%Lp' .harness/$t/$TF)" = 600 ] || die "the token's file in $t must be mode 0600"; done
echo "  the token: generated once (openssl rand -hex 16, the README's line, in .harness/after), copied into every tree's $TF, mode 0600, never printed"
jc "$L_JAVAC" .harness/javac.log; [ "$JE" = 0 ] || die "the harness did not compile (hc): $(head -5 .harness/javac.log)"
jc "$L_JAVACE" .harness/javace.log; [ "$JE" = 0 ] || die "the harness did not compile (hce): $(head -5 .harness/javace.log)"
[ ! -e .harness/hc/probe/t/ex ] && [ ! -e .harness/hce/probe/t/ex ] && [ ! -e .harness/hc/probe/t/ev ] || die "the exercise's class, or the events classes, compiled into the wrong place"
echo "  extracted five jars ($(for t in before after anb anb2 ana2; do ls .harness/$t/$XD/lib | wc -l | tr -d ' '; done | paste -sd/ -) libraries: before/after/B/B'/A'); the harness compiled twice - .harness/hc over before/'s, .harness/hce over after/'s"
printf '%s\n' 'name,mealsPerDay,pricePerMeal,mealType' 'Asha,1,100,VEG' 'Ravi,2,120,VEG' 'Dev,2,110,VEGAN' > .harness/customers.csv
mkdir -p .harness/feedrow && printf '%s\n' 'name,mealsPerDay,pricePerMeal,mealType' 'Dev,2,110,VEGAN' > .harness/feedrow/customers.csv
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
    while (match($0, M)) { pre = substr($0, 1, RSTART - 1); s = substr($0, RSTART, RLENGTH); post = substr($0, RSTART + RLENGTH)
      sub(lit(me), "<user>", s); $0 = pre s post }
    print }'; }
printf '%s\n' 'Starting XMain using Java 25.0.4.1' "$U/x" "$UP/y" "$HOME/z" 'org.h2.jdbc.JdbcConnection@1a2b3c4d' 'EntityManager [SessionImpl(1895617509<open>)]' 'Finished Spring Data repository scanning in 25 ms. Found 1 JPA repository interface.' "token $TOKEN" 'url=jdbc:h2:mem:184c1fae-3bb5-4208-80fb-a59190f705ec user=SA' '{"timestamp":"2026-11-11T16:07:00.140Z","status":500}' 'JDBC [x.HibernateTransactionManager$$Lambda/0x000003ff01b8a310@5d9576a0]' 'source=x@6b3e12b5, started on Wed Nov 11 19:51:00 CET 2026]' '"PUBLIC.CONSTRAINT_52 INDEX PUBLIC.CONSTRAINT_INDEX_5 ON' > .harness/p1
[ "$(mask < .harness/p1)" = "$(printf '%s\n' 'Starting XMain using Java <version>' '…/x' '…/../y' '~/z' 'org.h2.jdbc.JdbcConnection@…' 'EntityManager [SessionImpl(<n><open>)]' 'Finished Spring Data repository scanning in <n> ms. Found 1 JPA repository interface.' 'token [masked: the token]' 'url=jdbc:h2:mem:<uuid> user=SA' '{"timestamp":"<time>","status":500}' 'JDBC [x.HibernateTransactionManager$$Lambda/<n>@…]' 'source=x@…, started on <date>]' '"PUBLIC.CONSTRAINT_<n> INDEX PUBLIC.CONSTRAINT_INDEX_<n> ON')" ] || die "mask: the planted JDK version, folders, home, identity hash, EntityManager identity, scan time, the token, a generated database name, a 500's timestamp, a lambda class's address, a context's start date and H2's constraint names must be masked"
rm -f .harness/p1
HA=('--spring.datasource.url=jdbc:h2:mem:u26;DB_CLOSE_DELAY=-1' --logging.config=../../harness/logback.xml --spring.jpa.hibernate.ddl-auto=none --spring.main.banner-mode=off --spring.thymeleaf.check-template-location=false)
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
start() { [ "$(listeners "$2")" = 0 ] || die "something listens on $2 before the start"; sec "$(dir "$1")"; echo "\$ $1"; (eval "$(exe "$1")") > .harness/run.out 2>&1 < /dev/null & pid=$!; }
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
# ---- the captures --------------------------------------------------------------------------------------------------------
rules() { echo "rules - the ten rows, one harness JVM over before/'s libraries (Boot's transaction manager as built):"; V=(-Ds=rules); A=("${HA[@]}"); hrun; hview; }
SPRT=$(ls .harness/before/$XD/lib | $G -xE 'spring-tx-[0-9.]+\.jar' || true); BTX=$(ls .harness/before/$XD/lib | $G -xE 'spring-boot-transaction-[0-9.]+\.jar' || true)
[ -n "$SPRT" ] && [ -n "$BTX" ] || die "spring-tx's or spring-boot-transaction's jar is not among before/'s libraries"
allexceptions() { echo "allexceptions - LABELLED allx: the same ten rows with the harness's profile allx, @EnableTransactionManagement(rollbackOn = RollbackOn.ALL_EXCEPTIONS) (one harness JVM over before/'s libraries):"
  V=(-Ds=rules); A=("${HA[@]}" --spring.profiles.active=allx); hrun; hview
  echo "the annotation's default, read off the jar - \$ javap -v -cp .harness/before/$XD/lib/$SPRT org.springframework.transaction.annotation.EnableTransactionManagement (its rollbackOn method and its default):"
  javap -v -cp ".harness/before/$XD/lib/$SPRT" org.springframework.transaction.annotation.EnableTransactionManagement 2> /dev/null | awk '/RollbackOn rollbackOn\(\);/ { f = 1 } f && /AnnotationDefault:/ { g = 1 } f { print "  " $0 } g && /RUNTIME_EXCEPTIONS|ALL_EXCEPTIONS/ { exit }' | sed -E 's/[[:space:]]+$//; s/#[0-9]+/#<n>/g'
  echo "Boot's transaction properties (spring.transaction.*) - \$ javap -p -cp .harness/before/$XD/lib/$BTX org.springframework.boot.transaction.autoconfigure.TransactionProperties (its fields):"
  javap -p -cp ".harness/before/$XD/lib/$BTX" org.springframework.boot.transaction.autoconfigure.TransactionProperties 2> /dev/null | $G -E '^  private ' | sed 's/^/  /'; }
twowrites() { echo "twowrites - one harness JVM over before/'s libraries:"; V=(-Ds=twowrites); A=("${HA[@]}"); hrun; hview; }
events() { echo "events - one harness JVM over after/'s libraries (the anchor's CustomerRepository and CustomerAdded):"; V=(-Ds=events); A=("${HA[@]}"); HL=$L_HE; hrun; HL=""; hview; }
POSTK=${R_POST/\"name\":\"Asha\"/\"name\":\"Kavya\"}
anchorrun() { local t=$1 p=$2
  start "$(at .harness/$t $p "$L_TX")" $p; up $p; ready $p
  echo "  POST /customers, Kavya (the README's JSON line, the name Kavya):"; req "$POSTK" $p
  echo "  the same again:"; req "$POSTK" $p
  echo "  POST /customers/import - the file .harness/customers.csv: $(paste -sd'|' .harness/customers.csv)"; req "$R_IMPORT" $p .harness
  echo "  then:"; echo "\$ $(url "$R_GET" $p)"; echo "  -> the names: $(eval "$(url "$R_GET" $p)" 2> /dev/null | names)"
  stopit $p; logtok; rm -f .harness/run.out; }
anchor() { local f
  echo "the change - after/ against before/ (diff -rq, the file names):"
  diff -rq before after | sed -E 's#^Files before/(.*) and after/.* differ$#  \1#; s#^Only in after/(.*): (.*)$#  \1/\2 (new)#' | sort
  for f in $CJ/CustomerRepository.java $WJ/CustomerFeed.java $WJ/TiffinBoxServer.java $WJ/DashboardPage.java $WJ/CustomerImport.java; do echo "$f:"; cdiff "before/$f" "after/$f"; done
  echo "$CJ/CustomerAdded.java (new) - its code, comments dropped:"; $G -vE '^ *(/\*\*|\*|\*/)' "after/$CJ/CustomerAdded.java" | $G -v '^$' | sed 's/^/    /'
  echo "the feed's call - \$ grep -c 'feed\\.added' over each tree's web classes: before/ $($G -rc 'feed\.added' before/$WJ | awk -F: '{ n += $2 } END { print n + 0 }') · after/ $($G -rc 'feed\.added' after/$WJ | awk -F: '{ n += $2 } END { print n + 0 }')"
  echo "B - labelled: after/ with add's rule taken off - a plain @Transactional (.harness/anb, built; its tests ran: run, failures, errors, skipped $(summ4 .harness/build-anb.log)), port 20050 - the failure receipt:"
  echo "  its one line: $(diff .harness/after/$CJ/CustomerRepository.java .harness/anb/$CJ/CustomerRepository.java | $G '^>' | sed 's/^> *//')"
  anchorrun anb 20050
  echo "A - after/'s jar (@Transactional(rollbackFor = SQLException.class)), port 20051:"; anchorrun after 20051
  echo "B' - B copied again and built again (.harness/anb2), port 20052:"; anchorrun anb2 20052
  echo "A' - after/ copied again and built again (.harness/ana2), port 20053:"; anchorrun ana2 20053; }
# the feed: a listener (the README's curl -N line, to a file), Course 6's three adds, the events counted; B'': the tests on a copy
# whose add publishes with no transaction
listen() { local c i=0; c=$(url "$R_FEED" "$1"); echo "\$ $c > $2 &"
  (eval "exec $c") > "$2" 2> /dev/null < /dev/null & lpid=$!
  while ! $G -q '^:listening' "$2" 2> /dev/null && [ $i -lt 80 ]; do kill -0 "$lpid" 2> /dev/null || break; sleep 0.25; i=$((i + 1)); done
  echo "  the listener's first line: $(head -1 "$2")"; }
dl() { local i=0; while [ "$($G -c '^data:' "$1" 2> /dev/null || true)" -lt "$2" ] && [ $i -lt 80 ]; do sleep 0.25; i=$((i + 1)); done
  echo "  data lines in the listener's file: $($G -c '^data:' "$1" || true) (waited for $2)"; }
lend() { local i=0 e=0
  while kill -0 "$lpid" 2> /dev/null && [ $i -lt 80 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$lpid" 2> /dev/null && { kill "$lpid"; die "the listener's curl was still running after the server stopped"; }
  wait "$lpid" || e=$?; lpid=""; echo "  the listener's curl: exit $e"; }
feed() { local c e=0
  echo "the feed - after/'s jar, port 20054, a listener connected - then Course 6's three adds: a JSON add, a form add, an upload's row:"
  start "$(at .harness/after 20054 "$R_RUN")" 20054; up 20054; ready 20054
  listen 20054 .harness/feed.txt
  echo "  the JSON API:"; c=$(url "$R_POST" 20054); echo "\$ $c"; echo "  -> $(eval "$c" 2> /dev/null < /dev/null | sed -E 's/"pricePerMeal":[0-9]+,//g; s/"mealsPerDay":[0-9]+,//g')"
  echo "  the form:"; c=$(url "$R_FORM" 20054); echo "\$ $c"; echo "  -> $(eval "$c" 2> /dev/null < /dev/null | tail -1)"
  echo "  an upload of one row - .harness/feedrow/customers.csv: $(paste -sd'|' .harness/feedrow/customers.csv):"; c=$(url "$R_IMPORT" 20054); echo "\$ cd .harness/feedrow && $c"; echo "  -> $(cd .harness/feedrow && eval "$c" 2> /dev/null < /dev/null)"
  dl .harness/feed.txt 3
  stopit 20054; lend; logtok; rm -f .harness/run.out
  echo "  the listener's file, every line but the blank ones:"; $G -v '^$' .harness/feed.txt | sed -E 's/"pricePerMeal":[0-9]+,//g; s/"mealsPerDay":[0-9]+,//g; s/^/    /'
  echo "  customer-added events: $($G -cx 'event:customer-added' .harness/feed.txt || true) · their names: $($G '^data:' .harness/feed.txt | names)"
  echo "B'' - labelled: after/ with add's @Transactional line removed (.harness/bpp) - CustomerAdded published with no transaction around it; its tests, the README's line, offline:"
  echo "  its one line out: $(diff .harness/after/$CJ/CustomerRepository.java .harness/bpp/$CJ/CustomerRepository.java | $G '^<' | sed 's/^< *//')"
  rm -rf .harness/bpp/tiffinbox-web/target .harness/bpp/tiffinbox-core/target
  c=$(off .harness/bpp "$R_TEST"); echo "\$ $c"
  (eval "$c") > .harness/bpp.log 2>&1 < /dev/null & mpid=$!; wait "$mpid" || e=$?; mpid=""
  echo "  exit $e · $($G -m1 -oE 'BUILD (SUCCESS|FAILURE)' .harness/bpp.log || echo 'no BUILD line') · offline: $( [ "$($G -cE '^\[INFO\] Download(ing|ed) from ' .harness/bpp.log || true)" = 0 ] && echo yes || echo no)"
  echo "  Surefire's reports ($SR, read by harness/surefire.py):"; reports .harness/bpp .harness/bpp.log; }
sqlseg() { sed -n "${1},${2}p" .harness/run.out | $G -cE ' org\.hibernate\.SQL +: ' || true; }
seven7() { local t p n0 ns
  for t in before:20055 after:20056; do p=${t#*:}; t=${t%:*}
    echo "the seven - $t/'s jar, port $p, a fresh JVM, Hibernate's SQL logger on:"
    start "$(at .harness/$t $p "$L_SQL")" $p; up $p; ready $p; n0=$(lines)
    echo "\$ \$CURLSET $p .harness/$t/$TF"
    "$CURLSET" $p ".harness/$t/$TF" | $G ' -> ' > .harness/responses.txt || true
    awk '{ gsub(/"timestamp":"[^"]*"/, "\"timestamp\":\"…\""); print }' .harness/responses.txt > .harness/seven-$t.txt
    $G '^POST ' .harness/seven-$t.txt | sed 's/^/  /' || echo "  (no POST line)"
    gone $p
    echo "  exit $LASTE · the seven responses: $(wc -l < .harness/seven-$t.txt | tr -d ' ') lines · md5 $(md5 -q .harness/seven-$t.txt)"
    echo "  its log - Spring Data's scan: $($G -m1 -oE 'Found [0-9]+ JPA repository interfaces?\.' .harness/run.out || echo 'no scan line') · HHH000001: $($G -m1 -oE 'HHH000001: Hibernate ORM core version [^ ]+' .harness/run.out || echo none)"
    ns=$($G -n -m1 'Started TiffinBoxServer in ' .harness/run.out | cut -d: -f1); [ -n "$ns" ] || die "no Started line in the $t run's log"
    echo "  its log's org.hibernate.SQL lines: $($G -cE ' org\.hibernate\.SQL +: ' .harness/run.out || true) in all - before Started TiffinBoxServer (the start): $(sqlseg 1 "$ns") · from there to readiness's 200: $(sqlseg "$ns" "$n0") · during the seven: $(sqlseg "$((n0 + 1))" '$')"
    echo "  the statements during the seven, each with how often:"
    sed -n "$((n0 + 1)),\$p" .harness/run.out | sed -n -E 's/^.* org\.hibernate\.SQL +: (.*)$/\1/p' | sort | uniq -c | sed -E 's/^ *([0-9]+) (.*)$/    \1 x \2/'
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
  echo "  which test classes run the real CustomerRepository - each test source's @MockitoBean CustomerRepository lines (R.190):"
  for c in TiffinBoxWebTest FullStackTest FeedTest; do echo "    $c.java: $($G -c '^ *@MockitoBean CustomerRepository ' .harness/tests/tiffinbox-web/src/test/java/com/tiffinbox/web/$c.java || true)"; done
  echo "  its log's WARN lines: $(lvl WARN .harness/tests.log) · ERROR lines: $(lvl ERROR .harness/tests.log) · the token in it and every report: $(raw "$TOKEN" .harness/tests.log .harness/tests/$SR/*) times"; }
X09=f595637014e786fa38606859951e4f97                # Boot's script for CustomerEntity + PauseEntity, as ../c7-unit09's xcheck captured it (R.212)
X09CAP=9072c6f11c8c8e713c997b58d3a79d74             # ../c7-unit09's published xcheck capture
[ "$($G -c "$X09" ../c7-unit09/README.md || true)" -gt 0 ] || die "../c7-unit09/README.md must name $X09 - Boot's script md5 (R.212)"
[ "$(awk '$1 == "xcheck" { print $2 }' ../c7-unit09/receipts.md5)" = "$X09CAP" ] || die "../c7-unit09/receipts.md5's xcheck is not $X09CAP - the capture that holds Boot's script"
XA=('--spring.datasource.url=jdbc:h2:mem:x26;DB_CLOSE_DELAY=-1' --logging.config=../../harness/logback.xml --spring.jpa.hibernate.ddl-auto=none --spring.main.banner-mode=off --spring.thymeleaf.check-template-location=false --spring.jpa.properties.jakarta.persistence.schema-generation.scripts.action=create --spring.jpa.properties.jakarta.persistence.schema-generation.scripts.create-target=hibernate-ddl.sql)
xcheck() {
  echo "the harness's DDL over after/'s libraries - probe.x.XMain (@EntityScan(\"com.tiffinbox\") alone: no repository, no seed), scripts.action=create (a file, never run):"
  rm -f .harness/run/hibernate-ddl.sql
  A=("${XA[@]}"); HL=$L_X; hrun; hview; HL=""
  echo "  .harness/run/hibernate-ddl.sql - every line:"; sed -E 's/FK[0-9a-z]{20,}/FK<name>/g; s/^/    /' .harness/run/hibernate-ddl.sql
  echo "  its md5: $(md5 -q .harness/run/hibernate-ddl.sql) · the owning-side lesson's (its README names it $($G -c "$X09" ../c7-unit09/README.md || true) times; its xcheck published $X09CAP): $X09 · the same: $( [ "$(md5 -q .harness/run/hibernate-ddl.sql)" = "$X09" ] && echo yes || echo no)"
  rm -f .harness/run/hibernate-ddl.sql; }
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
# ---- the checks of what the video says from each capture, right after it ----------------------------------------------------
blk() { awk -v a="$2" -v b="$3" 'index($0, a) == 1 { f = 1; next } b != "" && index($0, b) == 1 { f = 0 } f' ".r-$1.out"; }
has() { printf '%s\n' "$1" | $G -qxF -- "$2" || die "$3: expected the line: $2"; }
nhas() { ! printf '%s\n' "$1" | $G -qF -- "$2" || die "$3: did not expect: $2"; }
cnt() { printf '%s\n' "$1" | $G -cxF -- "$2" || true; }
# S4.13 (R.270): Framework's version in the same capture beside HHH000001 and Spring Data's - once per harness JVM, never typed
VERL='  PROBE Hibernate ORM core version (org.hibernate.Version.getVersionString()): 7.4.13.Final'
VERH='  INFO  org.hibernate.orm.core : HHH000001: Hibernate ORM core version 7.4.13.Final'
VERD='  PROBE Spring Data JPA version (JpaRepository.class.getPackage().getImplementationVersion()): 4.1.2'
VERF='  PROBE Spring Framework version (Transactional.class.getPackage().getImplementationVersion()): 7.0.10'
DBL='  PROBE database: H2 2.5.250 | url jdbc:h2:mem:u26;DB_CLOSE_DELAY=-1'
SEEDL='  PROBE seeded by the shipped Database (createAndSeed); the second connection reads: customer rows 4 [1 Ravi, 2 Meera, 3 Sunil, 4 Priya]'
FOUND1='  INFO  org.springframework.data.repository.config.RepositoryConfigurationDelegate : Finished Spring Data repository scanning in <n> ms. Found 1 JPA repository interface.'
ver() { local c; c=$1
  [ "$(cnt "$c" "$VERL")" = "$2" ] && [ "$(cnt "$c" "$VERH")" = "$2" ] && [ "$(cnt "$c" "$VERD")" = "$2" ] && [ "$(cnt "$c" "$VERF")" = "$2" ] || die "$3: the version lines - getVersionString(), Hibernate's HHH000001, Spring Data JPA's 4.1.2 and Spring Framework's 7.0.10 - once in each of its $2 harness JVMs (S4.13)"
  [ "$(cnt "$c" "$DBL")" = "$2" ] && [ "$(cnt "$c" "$SEEDL")" = "$2" ] && [ "$(cnt "$c" "$FOUND1")" = "$2" ] || die "$3: the database: line (H2 2.5.250), the shipped seed read by the second connection and Spring Data's Found 1 - in each of its $2 harness JVMs"
  [ "$(cnt "$c" "  exit 0 · 'GenerationTarget encountered exception': 0")" = "$2" ] || die "$3: each of its $2 harness JVMs ends by itself, exit 0"; }
TXP='  DEBUG org.springframework.orm.jpa.JpaTransactionManager : '
TIP='  TRACE org.springframework.transaction.interceptor.TransactionInterceptor : '
# the row checker (S4.1, S4.2, R.226): reads one capture's rows; checks each row's outcome against the expected column below (the
# receipt's check, never the README's text), the method's own print inside, the manager's line (commit for KEPT, rollback for gone)
# and the interceptor's completing line in the row's own block, one read by the second connection after the manager's last line;
# prints the table rows README.md must hold and "mismatches N"; exits 1 on any mismatch
cat > .harness/rows.py <<'PY'
import re, sys
cap, want = sys.argv[1], sys.argv[2]      # want: rules | allx | twowrites
TXP = "  DEBUG org.springframework.orm.jpa.JpaTransactionManager : "
TIP = "  TRACE org.springframework.transaction.interceptor.TransactionInterceptor : "
EXP = {"rules": {"checked exception": "KEPT", "checked, rollbackFor = Exception.class": "gone", "RuntimeException": "gone",
                 "RuntimeException, noRollbackFor = Boom.class": "KEPT", "an Error": "gone", "RuntimeException caught inside": "KEPT",
                 "setRollbackOnly(), no exception": "gone", "JTA's annotation, checked": "KEPT", "JTA's annotation, RuntimeException": "gone",
                 "JTA's annotation, checked, rollbackOn = Exception.class": "gone"},
       "twowrites": {"two writes, a checked exception between them": "KEPT", "two writes, rollbackFor = Exception.class": "gone"}}
EXP["allx"] = dict(EXP["rules"], **{"checked exception": "gone", "JTA's annotation, checked": "gone"})
L = [l.rstrip("\n") for l in open(cap, encoding="utf-8")]
bad = []; rows = []
for i, l in enumerate(L):
    m = re.match(r"^  PROBE row (.+?) · (\w+)\.(\w+) · attribute (\S+) · (\w+) (KEPT|gone)( · her pauses \d+)? · (returned|threw \w+)$", l)
    if not m: continue
    label, cls, meth, attr, name, got, pz, how = m.groups(); rows.append(label)
    a = L.index("  PROBE >>> row " + label); b = L.index("  PROBE <<< row " + label); blk = L[a:b + 1]
    exp = EXP[want].get(label)
    if got != exp: bad.append("%s: got %s expected %s" % (label, got, exp))
    mgr = [x[len(TXP):] for x in blk if x.startswith(TXP)]
    if not any(x.startswith("Creating new transaction with name [probe.t.%s.%s]: %s" % (cls, meth, attr)) for x in mgr): bad.append("%s: no Creating line with its attribute" % label)
    end = "Initiating transaction commit" if got == "KEPT" else "Initiating transaction rollback"
    other = "Initiating transaction rollback" if got == "KEPT" else "Initiating transaction commit"
    if end not in mgr or other in mgr: bad.append("%s: the manager's line is not %s alone" % (label, end))
    if not any(x.startswith("  PROBE   ") and ("tx active true · name probe.t.%s.%s · readOnly false" % (cls, meth)) in x for x in blk): bad.append("%s: no print inside its own transaction" % label)
    comp = [x[len(TIP):] for x in blk if x.startswith(TIP + "Completing transaction for [probe.t.%s.%s]" % (cls, meth))]
    if how.startswith("threw") and not (comp and " after exception: " in comp[0]): bad.append("%s: no interceptor line 'Completing transaction for [...] after exception'" % label)
    if how == "returned" and not (comp and " after exception" not in comp[0]): bad.append("%s: the interceptor's completing line must be the plain one" % label)
    afters = [j for j, x in enumerate(blk) if x.startswith("  PROBE after: the second connection reads ")]
    mj = [j for j, x in enumerate(blk) if x.startswith(TXP)]
    if len(afters) != 1 or afters[0] < mj[-1]: bad.append("%s: one read by the second connection, after the manager's last line (S4.1)" % label)
    if label.startswith("setRollbackOnly") and "Transactional code has requested rollback" not in mgr: bad.append("setRollbackOnly: no 'Transactional code has requested rollback'")
    if want != "allx" or label in ("checked exception", "JTA's annotation, checked"):
        print("| %s | `%s.%s` | `%s` | %s %s%s | %s |" % (label, cls, meth, attr, name, got, pz or "", how))
if rows != list(EXP[want]): bad.append("the rows: %s, expected %s" % (rows, list(EXP[want])))
for x in bad: print("  mismatch: " + x)
print("rows %d · mismatches %d" % (len(rows), len(bad)))
sys.exit(1 if bad else 0)
PY
RTBL=""; RCH=""; RSRO=""
chk_rules() { local C o
  C=$(cat .r-rules.out); ver "$C" 1 rules
  has "$C" '  PROBE transaction manager bean: transactionManager · org.springframework.orm.jpa.JpaTransactionManager' "rules: Boot's manager"
  has "$C" '  PROBE spring.profiles.active as this context read it: (none)' "rules: no profile (the allx switch off)"
  o=$(python3 -I -B .harness/rows.py .r-rules.out rules) || die "rules: $(printf '%s\n' "$o" | $G -E 'mismatch|^rows' | head -4 | paste -sd';' -)"
  [ "$(printf '%s\n' "$o" | tail -1)" = 'rows 10 · mismatches 0' ] || die "rules: ten rows, mismatches 0"
  RTBL=$(printf '%s\n' "$o" | $G '^| ' || true); [ "$(printf '%s\n' "$RTBL" | $G -c . || true)" = 10 ] || die "rules: the table's ten rows"
  RCH=$(printf '%s\n' "$C" | sed -n "s/^${TIP}\(Completing transaction for \[probe.t.Rb26.checked\] after exception: .*\)$/\1/p")
  [ "$RCH" = 'Completing transaction for [probe.t.Rb26.checked] after exception: probe.t.H$CheckedBoom: checked, after saving Asha' ] || die "rules: the checked row's interceptor line: ${RCH:-none}"
  o=$(awk '$0 == "  PROBE >>> row checked exception" { f = 1 } f { print } $0 == "  PROBE <<< row checked exception" { f = 0 }' .r-rules.out)
  [ "$(printf '%s\n' "$o" | $G -n -F "$RCH" | cut -d: -f1)" -lt "$(printf '%s\n' "$o" | $G -n -xF "${TXP}Initiating transaction commit" | cut -d: -f1)" ] || die "rules: the checked row - the exception reached the interceptor, then the commit"
  has "$o" '  PROBE after: the second connection reads customer rows 5 [1 Ravi, 2 Meera, 3 Sunil, 4 Priya, 5 Asha]' "rules: Asha kept, by the second connection"
  RSRO=$(awk '$0 == "  PROBE >>> row setRollbackOnly(), no exception" { f = 1 } f && /Transactional code has requested rollback/ { print "Transactional code has requested rollback"; exit }' .r-rules.out)
  echo "  rules: 10 rows, mismatches 0 against the brief's table, each with its attribute, the manager's line, the interceptor's line, its own print and the second connection's read after; the checked row: $RCH, then Initiating transaction commit, Asha kept; setRollbackOnly: $RSRO"; }
ATBL=""; ADEF=""; AKEYS=""
chk_allexceptions() { local C o
  C=$(cat .r-allexceptions.out); ver "$C" 1 allexceptions
  has "$C" "allexceptions - LABELLED allx: the same ten rows with the harness's profile allx, @EnableTransactionManagement(rollbackOn = RollbackOn.ALL_EXCEPTIONS) (one harness JVM over before/'s libraries):" "allexceptions: LABELLED in its own header"
  has "$C" '  PROBE spring.profiles.active as this context read it: allx' "allexceptions: the profile allx, as the context read it"
  o=$(python3 -I -B .harness/rows.py .r-allexceptions.out allx) || die "allexceptions: $(printf '%s\n' "$o" | $G -E 'mismatch|^rows' | head -4 | paste -sd';' -)"
  [ "$(printf '%s\n' "$o" | tail -1)" = 'rows 10 · mismatches 0' ] || die "allexceptions: ten rows"
  ATBL=$(printf '%s\n' "$o" | $G '^| ' || true); [ "$(printf '%s\n' "$ATBL" | $G -c . || true)" = 2 ] || die "allexceptions: the two rows that change"
  $G -q ' · attribute PROPAGATION_REQUIRED,ISOLATION_DEFAULT,+probe.t.H$Boom,-java.lang.Exception · Omar KEPT · threw Boom$' .r-allexceptions.out || die "allexceptions: noRollbackFor still KEPT, its attribute read"
  has "$C" '      AnnotationDefault:' "allexceptions: javap's AnnotationDefault"
  ADEF=$(printf '%s\n' "$C" | $G -oE 'RollbackOn;\.[A-Z_]+$' | tail -1 | sed 's/^RollbackOn;\./RollbackOn./')
  [ "$ADEF" = RollbackOn.RUNTIME_EXCEPTIONS ] || die "allexceptions: the annotation's default read off the jar: ${ADEF:-none}"
  AKEYS=$(printf '%s\n' "$C" | sed -n -E 's/^    private [^ ]+ ([A-Za-z]+);$/\1/p' | paste -sd' ' -)
  [ "$AKEYS" = 'defaultTimeout rollbackOnCommitFailure' ] || die "allexceptions: Boot's TransactionProperties - its two fields, no rollbackOn key: ${AKEYS:-none}"
  echo "  allexceptions (LABELLED allx): checked gone, JTA checked gone, noRollbackFor still KEPT; the default $ADEF; Boot's spring.transaction properties: $AKEYS"; }
TWK=""; TWR=""
chk_twowrites() { local C o
  C=$(cat .r-twowrites.out); ver "$C" 1 twowrites
  o=$(python3 -I -B .harness/rows.py .r-twowrites.out twowrites) || die "twowrites: $(printf '%s\n' "$o" | $G -E 'mismatch|^rows' | head -4 | paste -sd';' -)"
  TWK=$(sed -n 's/^  PROBE row two writes, a checked exception between them · .* · \(Kavya KEPT · her pauses [0-9]* · threw [A-Za-z]*\)$/\1/p' .r-twowrites.out)
  TWR=$(sed -n 's/^  PROBE row two writes, rollbackFor = Exception.class · .* · \(Kira gone · her pauses [0-9]* · threw [A-Za-z]*\)$/\1/p' .r-twowrites.out)
  [ "$TWK" = 'Kavya KEPT · her pauses 0 · threw FileNotFoundException' ] && [ "$TWR" = 'Kira gone · her pauses 0 · threw FileNotFoundException' ] || die "twowrites: Kavya kept without her pause, Kira gone: $TWK / $TWR"
  has "$C" '  PROBE threw: java.io.FileNotFoundException: pauses.csv (the pause file is missing)' "twowrites: the checked exception"
  echo "  twowrites: $TWK; with rollbackFor: $TWR"; }
EVP=""; EVA=""; EVS=""; EVT=""; EVK=""; EVL=""
chk_events() { local C x
  C=$(cat .r-events.out); ver "$C" 1 events
  has "$C" '  PROBE the anchor'"'"'s CustomerRepository bean: com.tiffinbox.CustomerRepository$$SpringCGLIB$$<n> · isCglibProxy true' "events: the anchor's CustomerRepository is a class proxy (final gone)"
  cs() { awk -v a="  PROBE >>> case $1" -v b="  PROBE <<< case $1" '$0 == a { f = 1 } f { print } $0 == b { f = 0 }' .r-events.out; }
  x=$(cs 'a transaction that commits (Lena)')
  EVP=$(printf '%s\n' "$x" | sed -n 's/^  PROBE   @EventListener heard Lena · //p'); EVA=$(printf '%s\n' "$x" | sed -n 's/^  PROBE   @TransactionalEventListener(AFTER_COMMIT) heard Lena · //p')
  [ "$EVP" = 'thread main · isActualTransactionActive true · isSynchronizationActive true · the second connection sees the row false' ] || die "events: the plain listener runs before the commit - the second connection does not see the row (S4.10): ${EVP:-none}"
  [ "$EVA" = 'thread main · isActualTransactionActive true · isSynchronizationActive false · the second connection sees the row true' ] || die "events: AFTER_COMMIT - the same thread, the row visible, isActualTransactionActive true (S4.10): ${EVA:-none}"
  [ "$(printf '%s\n' "$x" | $G -n '@EventListener heard Lena' | cut -d: -f1)" -lt "$(printf '%s\n' "$x" | $G -nxF "${TXP}Initiating transaction commit" | cut -d: -f1)" ] && [ "$(printf '%s\n' "$x" | $G -nxF "${TXP}Initiating transaction commit" | cut -d: -f1)" -lt "$(printf '%s\n' "$x" | $G -n 'AFTER_COMMIT) heard Lena' | cut -d: -f1)" ] || die "events: the order - the plain listener, the commit, the AFTER_COMMIT listener"
  x=$(cs 'a transaction that rolls back after publishing (Zoe)')
  has "$x" '  PROBE   @EventListener heard Zoe · thread main · isActualTransactionActive true · isSynchronizationActive true · the second connection sees the row false' "events: the plain listener heard a customer the transaction then rolled back"
  nhas "$x" 'AFTER_COMMIT) heard Zoe' "events: no AFTER_COMMIT for a rollback"; has "$x" "${TXP}Initiating transaction rollback" "events: Zoe rolled back"
  has "$x" '  PROBE after: the second connection reads customer rows 4 [1 Ravi, 2 Meera, 3 Sunil, 4 Priya] · Zoe gone' "events: Zoe gone"
  x=$(cs 'no transaction around the publish (Ivan)')
  EVS=$(printf '%s\n' "$x" | sed -n 's/^  DEBUG org.springframework.transaction.event.TransactionalApplicationListenerMethodAdapter : \(No transaction is active - skipping\) .*/\1/p' | sort -u)
  [ "$EVS" = 'No transaction is active - skipping' ] && [ "$(printf '%s\n' "$x" | $G -c 'No transaction is active - skipping' || true)" = 2 ] || die "events: with no transaction both transactional listeners are skipped, DEBUG: ${EVS:-none}"
  nhas "$x" 'AFTER_COMMIT) heard Ivan' "events: Ivan never reaches AFTER_COMMIT"
  has "$x" '  PROBE   @EventListener heard Ivan · thread main · isActualTransactionActive false · isSynchronizationActive false · the second connection sees the row true' "events: the plain listener still hears Ivan"
  x=$(cs 'an AFTER_COMMIT listener that throws (Omar)')
  EVT=$(printf '%s\n' "$x" | sed -n 's/^  ERROR org.springframework.transaction.support.TransactionSynchronizationUtils : //p')
  [ "$EVT" = 'TransactionSynchronization.afterCompletion threw exception' ] || die "events: the throwing listener - afterCompletion threw exception: ${EVT:-none}"
  has "$x" '  PROBE the call returned' "events: the caller returned normally"; has "$x" '  PROBE after: the second connection reads customer rows 5 [1 Ravi, 2 Meera, 3 Sunil, 4 Priya, 5 Omar] · Omar KEPT' "events: Omar's row kept (the Course 13 sentence)"
  x=$(cs "the anchor's CustomerRepository.add (Kavya)")
  EVL=$(printf '%s\n' "$x" | sed -n "s/^${TXP}\(Creating new transaction with name \[com.tiffinbox.CustomerRepository.add\]: .*\)$/\1/p")
  [ "$EVL" = 'Creating new transaction with name [com.tiffinbox.CustomerRepository.add]: PROPAGATION_REQUIRED,ISOLATION_DEFAULT,-java.sql.SQLException' ] || die "events: the add's own transaction line: ${EVL:-none}"
  EVK=$(printf '%s\n' "$x" | sed -n "s/^  PROBE   @TransactionalEventListener heard the anchor's CustomerAdded(Kavya) · //p")
  [ "$EVK" = 'thread main · isActualTransactionActive true · isSynchronizationActive false · the second connection sees the row true' ] || die "events: the anchor's CustomerAdded heard after the commit: ${EVK:-none}"
  x=$(cs "the anchor's CustomerRepository.add, a name that is taken (Ravi)")
  nhas "$x" "heard the anchor's CustomerAdded" "events: a refused add publishes nothing that is heard"; has "$x" "${TXP}Initiating transaction rollback" "events: the refused add rolled back (rollbackFor)"
  echo "  events: plain @EventListener $EVP · AFTER_COMMIT $EVA · no transaction: $EVS (twice) · a throwing AFTER_COMMIT listener: $EVT, the caller returned, Omar kept · the anchor's add: $EVL, its CustomerAdded heard: $EVK"; }
AB2=""; AB3=""; ABX=""; ABI=""; ABG=""; AA2=""; AA3=""; AAI=""; AAG=""; ABOV=""
chk_anchor() { local AN B A B2 A2 l
  AN=$(cat .r-anchor.out)
  [ "$(printf '%s\n' "$AN" | sed -n '/^the change - after/,/^tiffinbox-core\/src\/main\/java\/com\/tiffinbox\/CustomerRepository.java:$/p' | $G '^  ' | paste -sd' ' -)" = "  README.md   $CJ/CustomerAdded.java (new)   $CJ/CustomerRepository.java   $WJ/CustomerFeed.java   $WJ/CustomerImport.java   $WJ/DashboardPage.java   $WJ/TiffinBoxServer.java" ] || die "anchor: the change is the README, CustomerAdded.java (new), CustomerRepository.java, CustomerFeed.java, CustomerImport.java, DashboardPage.java and TiffinBoxServer.java - nothing else"
  for l in '    -public final class CustomerRepository {' '    +public class CustomerRepository {' '    +    @Transactional(rollbackFor = SQLException.class)' '    +            events.publishEvent(new CustomerAdded(customer));' '    +    @TransactionalEventListener' '    +    void stored(CustomerAdded e) {' '    -        feed.added(customer);' '    -            feed.added(customer);' '    +    public CustomerRepository(CustomerEntityRepository customers, ApplicationEventPublisher events) {' "the feed's call - \$ grep -c 'feed\\.added' over each tree's web classes: before/ 3 · after/ 0" '    public record CustomerAdded(Customer customer) {'; do has "$AN" "$l" "anchor: the change"; done
  B=$(blk anchor 'B - labelled' 'A - '); A=$(blk anchor 'A - ' "B' - "); B2=$(blk anchor "B' - " "A' - "); A2=$(blk anchor "A' - " '')
  has "$AN" "B - labelled: after/ with add's rule taken off - a plain @Transactional (.harness/anb, built; its tests ran: run, failures, errors, skipped 18 0 0 0), port 20050 - the failure receipt:" "anchor B: labelled, its 18 tests passed (the tests did not notice)"
  has "$AN" '  its one line: @Transactional' "anchor B: the one line"
  for l in "$B:20050" "$A:20051" "$B2:20052" "$A2:20053"; do has "${l%:*}" "  listens on: 127.0.0.1:${l##*:}" "anchor: on loopback ${l##*:}"; has "${l%:*}" '  GET /actuator/health/readiness -> 200' "anchor: ready"
    has "${l%:*}" "  stopped by its pid (SIGTERM): exit 143 · listening on ${l##*:} now: 0" "anchor: stopped"; has "${l%:*}" '  its log: the token 0 times' "anchor: no token"; done
  ans() { printf '%s\n' "$1" | awk -v k="$2" 'index($0, "$ ") == 1 && index($0, k) { n++; if (n == '"${3:-1}"') { getline; sub(/^  -> /, ""); print; exit } }'; }
  AB2=$(ans "$B" '/customers' 1); AB3=$(ans "$B" '/customers' 2); ABI=$(ans "$B" '/customers/import' 1)
  AA2=$(ans "$A" '/customers' 1); AA3=$(ans "$A" '/customers' 2); AAI=$(ans "$A" '/customers/import' 1)
  [ "$AB2" = '{"name":"Kavya","mealType":"VEG"} 201' ] && [ "$AA2" = "$AB2" ] || die "anchor: the first POST 201 on both: $AB2 / $AA2"
  [ "${AB3##* }" = 500 ] && printf '%s\n' "$AB3" | $G -qF '"status":500,"error":"Internal Server Error","path":"/customers"' || die "anchor B: the duplicate POST - 500 (the failure receipt): ${AB3:-none}"
  [ "$AA3" = '{"detail":"a customer named Kavya already exists","instance":"/customers","status":409,"title":"Conflict"} 409' ] || die "anchor A: the duplicate POST - 409, as before the change: ${AA3:-none}"
  ABX=$(printf '%s\n' "$B" | sed -n 's/^    the request failed: //p' | sort -u)
  [ "$ABX" = 'org.springframework.transaction.UnexpectedRollbackException: Transaction silently rolled back because it has been marked as rollback-only' ] || die "anchor B: the exception the server logged: ${ABX:-none}"
  ABOV=$(printf '%s\n' "$B" | sed -n 's/^    ERROR o\.s\.t\.i\.TransactionInterceptor: //p' | sort -u)
  [ "$ABOV" = 'Application exception overridden by commit exception' ] || die "anchor B: the interceptor's ERROR line: ${ABOV:-none}"
  [ "$(printf '%s\n' "$B" | $G -cxF '    DEBUG o.s.orm.jpa.JpaTransactionManager: Creating new transaction with name [com.tiffinbox.CustomerRepository.add]: PROPAGATION_REQUIRED,ISOLATION_DEFAULT' || true)" -ge 2 ] || die "anchor B: add's plain attribute line"
  [ "$(printf '%s\n' "$A" | $G -cxF '    DEBUG o.s.orm.jpa.JpaTransactionManager: Creating new transaction with name [com.tiffinbox.CustomerRepository.add]: PROPAGATION_REQUIRED,ISOLATION_DEFAULT,-java.sql.SQLException' || true)" -ge 2 ] || die "anchor A: add's line, -java.sql.SQLException"
  nhas "$A" 'Application exception overridden' "anchor A: no overridden exception"; nhas "$A" 'the request failed' "anchor A: no failed request"
  [ "${ABI##* }" = 500 ] && printf '%s\n' "$ABI" | $G -qF '"path":"/customers/import"' || die "anchor B: the import - 500: ${ABI:-none}"
  [ "$AAI" = '{"file":"customers.csv","added":2,"refused":{"line 3":"a customer named Ravi already exists"}} 200' ] || die "anchor A: the import - 200, added 2, line 3 refused: ${AAI:-none}"
  ABG=$(printf '%s\n' "$B" | sed -n 's/^  -> the names: //p'); AAG=$(printf '%s\n' "$A" | sed -n 's/^  -> the names: //p')
  [ "$ABG" = 'Asha Kavya Meera Priya Ravi Sunil' ] && [ "$AAG" = 'Asha Dev Kavya Meera Priya Ravi Sunil' ] || die "anchor: the names after - B Asha stored before the import's 500, Dev never reached; A Asha and Dev: $ABG / $AAG"
  [ "$(printf '%s\n' "$B" | sed -n '/^  secrets/,$p' | sed 's/2005[02]/<port>/g; s#\.harness/anb2*#.harness/<B>#g')" = "$(printf '%s\n' "$B2" | sed 's/2005[02]/<port>/g; s#\.harness/anb2*#.harness/<B>#g')" ] || die "anchor B': B built again prints what B printed (R.1)"
  [ "$(printf '%s\n' "$A" | sed 's/2005[13]/<port>/g; s#\.harness/a[a-z0-9]*#.harness/<A>#g')" = "$(printf '%s\n' "$A2" | sed 's/2005[13]/<port>/g; s#\.harness/a[a-z0-9]*#.harness/<A>#g')" ] || die "anchor A': after/ built again prints what A printed (R.1)"
  echo "  anchor: the change - CustomerRepository (final gone, @Transactional(rollbackFor = SQLException.class), the publisher), CustomerAdded (new), CustomerFeed (the listener), the three web classes (no feed, no call), the README; B (labelled, 18 tests passed): $AB2 · $AB3 (the server: $ABOV · $ABX) · import $ABI · after: $ABG; A: $AA2 · $AA3 · import $AAI · after: $AAG; B' = B, A' = A"; }
FDN=""; FDS=""; FBT=""; FBR=""
chk_feed() { local F B
  F=$(blk feed 'the feed - ' "B'' - "); B=$(blk feed "B'' - " '')
  has "$F" '  the listener'"'"'s first line: :listening' "feed: the listener connected"
  has "$F" '  -> {"name":"Asha","mealType":"VEG"} 201' "feed: the JSON add 201"
  has "$F" '  ->  302 · Location: [http://127.0.0.1:20054/dashboard]' "feed: the form add 302, the redirect to the dashboard"
  has "$F" '  -> {"file":"customers.csv","added":1,"refused":{}} 200' "feed: the upload's row added"
  has "$F" '  data lines in the listener'"'"'s file: 3 (waited for 3)' "feed: three data lines"
  FDN=$(printf '%s\n' "$F" | sed -n 's/^  customer-added events: \([0-9]*\) · their names: \(.*\)$/\1 \2/p')
  [ "$FDN" = '3 Asha Lata Dev' ] || die "feed: 3 customer-added events, Asha, Lata, Dev (C6/31's three adds, RED #1201): ${FDN:-none}"
  has "$F" '  the listener'"'"'s curl: exit 0' "feed: the stream ended at the shutdown"
  has "$B" "  its one line out: @Transactional(rollbackFor = SQLException.class)" "feed B'': labelled, the one line"
  FBT=$(printf '%s\n' "$B" | sed -n 's/^      ERROR  aListenerHearsANewCustomer - //p'); [ "$FBT" = java.util.concurrent.TimeoutException ] || die "feed B'': FeedTest must fail with TimeoutException - the event published with no transaction is skipped: ${FBT:-none}"
  FBR=$(printf '%s\n' "$B" | sed -n "s/^  Surefire's console summary (its Results line): \(.*\) · the reports' sum the same: yes$/\1/p")
  [ "$FBR" = 'tests 18 · failures 0 · errors 1 · skipped 0' ] || die "feed B'': 18 tests, 1 error (FeedTest): ${FBR:-none}"
  has "$B" '    TEST-com.tiffinbox.web.FeedTest.xml: tests 1 · failures 0 · errors 1 · skipped 0' "feed B'': FeedTest's report"
  echo "  feed: a listener, Course 6's three adds (JSON 201, form 302, one upload row 200) -> $FDN; B'' (labelled, add without @Transactional): FeedTest $FBT, $FBR"; }
S466=466c20ed7e0d5439cb052f32ce09de1b
SQB=""; SQA=""
chk_seven() { local SV b a x
  SV=$(cat .r-seven.out); b=$(blk seven 'the seven - before' 'the seven - after'); a=$(blk seven 'the seven - after' '')
  [ "$(cnt "$SV" "  exit 0 · the seven responses: 7 lines · md5 $S466")" = 2 ] || die "seven: $S466 on both trees (a guard)"
  has "$SV" '  the seven, after/ against before/: lines that differ: 0' "seven: 0 lines differ"
  SQB=$(printf '%s\n' "$b" | sed -n -E 's/^  its log.s org\.hibernate\.SQL lines: ([0-9]+) in all - .* during the seven: ([0-9]+)$/\1 \2/p')
  SQA=$(printf '%s\n' "$a" | sed -n -E 's/^  its log.s org\.hibernate\.SQL lines: ([0-9]+) in all - .* during the seven: ([0-9]+)$/\1 \2/p')
  [ -n "$SQB" ] && [ "$SQB" = "$SQA" ] || die "seven: Hibernate's SQL lines the same on both trees (RED #1214 - the seven's statements do not move): $SQB / $SQA"
  [ "$(printf '%s\n' "$b" | sed -n '/the statements during the seven/,$p' | $G '^    [0-9]')" = "$(printf '%s\n' "$a" | sed -n '/the statements during the seven/,$p' | $G '^    [0-9]')" ] || die "seven: the statements during the seven, the same on both"
  for x in "$b" "$a"; do has "$x" '  its log - Spring Data'"'"'s scan: Found 1 JPA repository interface. · HHH000001: HHH000001: Hibernate ORM core version 7.4.13.Final' "seven: Found 1"; done
  echo "  seven: $S466 on before/ and after/, 0 lines differ (a guard); Hibernate's SQL lines in the log ${SQB%% *}, during the seven ${SQB#* }, the same on both trees"; }
chk_tests() { local TS l
  TS=$(cat .r-tests.out)
  for l in '    TEST-com.tiffinbox.web.TiffinBoxWebTest.xml: tests 14 · failures 0 · errors 0 · skipped 0' '    TEST-com.tiffinbox.web.FullStackTest.xml: tests 3 · failures 0 · errors 0 · skipped 0' '    TEST-com.tiffinbox.web.FeedTest.xml: tests 1 · failures 0 · errors 0 · skipped 0' \
      '    in all: 3 reports · tests 18 · failures 0 · errors 0 · skipped 0' "  Surefire's console summary (its Results line): tests 18 · failures 0 · errors 0 · skipped 0 · the reports' sum the same: yes" '  exit 0 · BUILD SUCCESS · offline: yes' \
      '    TiffinBoxWebTest.java: 1' '    FullStackTest.java: 1' '    FeedTest.java: 0'; do has "$TS" "$l" "tests"; done
  echo "  tests: 18 (14/3/1) from the reports, the console the same; the real CustomerRepository in FeedTest (TiffinBoxWebTest and FullStackTest mock it) - a guard (R.190; C7-4)"; }
chk_xcheck() { local XC
  XC=$(cat .r-xcheck.out)
  for l in "$VERH" '  INFO  org.springframework.data.repository.config.RepositoryConfigurationDelegate : Finished Spring Data repository scanning in <n> ms. Found 0 JPA repository interfaces.' "  exit 0 · 'GenerationTarget encountered exception': 0"; do has "$XC" "$l" "xcheck: the entities alone, no repository, a clean start"; done
  [ "$(cnt "$XC" "  its md5: $X09 · the owning-side lesson's (its README names it $($G -c "$X09" ../c7-unit09/README.md || true) times; its xcheck published $X09CAP): $X09 · the same: yes")" = 1 ] || die "xcheck: the harness's script must be Boot's for the anchor's entities, md5 $X09 (R.212) - a mapping moved"
  [ "$(printf '%s\n' "$XC" | $G -c '^    create table \|^    alter table ' || true)" = 3 ] || die "xcheck: two create table lines and one alter table"
  echo "  xcheck: the harness's script over after/'s libraries, md5 $X09 = the owning-side lesson's - no mapping moved"; }
EXQ="Your turn: the README's method fails with a checked exception and the customer is still saved. Make it roll back."
EXW=$(printf '%s\n' "$EXQ" | wc -w | tr -d ' ')
EXBT=""; EXBR=""; EXST=""; EXSR=""
chk_exercise() { local EB EZ b ER ES w l
  EB=$(blk exercise "in bash" "in zsh"); EZ=$(blk exercise "in zsh" "")
  for b in "$EB" "$EZ"; do
    ER=$(printf '%s\n' "$b" | sed '/then the solution/,$d'); ES=$(printf '%s\n' "$b" | sed -n '/then the solution/,$p')
    for l in '    the JVM: exit 0' '    Found 1 JPA repository interface.' '    Creating new transaction with name [probe.t.ex.SignUp.signUp]'; do has "$ER" "$l" "exercise: the README runs"; has "$ES" "$l" "exercise: the solution runs"; done
    EXBT=$(printf '%s\n' "$ER" | sed -n 's/^    PROBE signUp(Kavya) threw: //p'); EXBR=$(printf '%s\n' "$ER" | sed -n 's/^    PROBE after the call, its own JDBC connection reads: //p')
    [ "$EXBT" = 'java.io.FileNotFoundException: welcome-letter.txt (the letter template is missing)' ] && [ "$EXBR" = 'customer rows 5 · Kavya kept' ] || die "exercise: the README's run - the checked exception, Kavya kept (S4.16): ${EXBT:-none} / ${EXBR:-none}"
    has "$ER" '    Initiating transaction commit' "exercise broken: the checked exception commits"
    EXST=$(printf '%s\n' "$ES" | sed -n 's/^    PROBE signUp(Kavya) threw: //p'); EXSR=$(printf '%s\n' "$ES" | sed -n 's/^    PROBE after the call, its own JDBC connection reads: //p')
    [ "$EXST" = "$EXBT" ] && [ "$EXSR" = 'customer rows 4 · Kavya gone' ] || die "exercise: the solution's end state - the same exception, Kavya gone (S4.16): ${EXST:-none} / ${EXSR:-none}"
    has "$ES" '    Initiating transaction rollback' "exercise solved: rolled back"
    [ "$EXBR" != "$EXSR" ] || die "exercise: broken and solved must differ - by the rows, never only the exit code"
    [ "$(printf '%s\n' "$b" | $G -c "^  the shell is now in: this unit's folder")" = 2 ] || die "exercise: the shell back in this folder"; done
  [ "$(printf '%s\n' "$EB" | $G -v '^in ')" = "$(printf '%s\n' "$EZ" | $G -v '^in ')" ] || die "exercise: bash and zsh print the same"
  w=$(printf '%s\n' "$EB" | sed '/then the solution/,$d' | sed -n '/^  the block.s exit /,/^  the shell is now in: /p' | sed '1d;$d' | sed 's/^    //')
  [ "$(wib exercise/README.md)" = "$w" ] || die "exercise/README.md's \"What it prints\" block is not what the README's lines printed: $(diff <(wib exercise/README.md) <(printf '%s\n' "$w") | head -3 | paste -sd' ' -)"
  w=$(printf '%s\n' "$EB" | sed -n '/then the solution/,$p' | sed -n '/then the solution/,/^  the shell is now in: /p' | sed '1d;$d' | sed 's/^    //')
  [ "$(wib exercise/SOLUTION.md)" = "$w" ] || die "exercise/SOLUTION.md's \"What it prints\" block is not what the solution's lines printed: $(diff <(wib exercise/SOLUTION.md) <(printf '%s\n' "$w") | head -3 | paste -sd' ' -)"
  $G -qxF -- "**Your turn:** ${EXQ#Your turn: }" exercise/README.md || die "exercise/README.md: the spoken exercise line"
  [ "$EXW" -le 25 ] || die "exercise: the spoken line is at most 25 words (R.203): $EXW"
  $G -qxF '    @Transactional' harness/src/probe/t/ex/ExApp.java || die "exercise: ExApp ships signUp with the plain annotation"
  echo "  exercise: bash and zsh alike - the README as written: threw $EXBT, $EXBR; the solution (one line: rollbackFor = Exception.class): $EXSR; each file's What it prints = the run; $EXW words"; }
cap rules rules; chk_rules; pub rules
cap allexceptions allexceptions; chk_allexceptions; pub allexceptions
cap twowrites twowrites; chk_twowrites; pub twowrites
cap events events; chk_events; pub events
cap anchor anchor; chk_anchor; pub anchor
cap feed feed; chk_feed; pub feed
cap seven seven7; chk_seven; pub seven
cap tests tests; chk_tests; pub tests
cap xcheck xcheck; chk_xcheck; pub xcheck
cap exercise exercise; chk_exercise; pub exercise

# the table and the values the video says are the captures', never typed: README.md holds them, composed here from the checks' reads
printf '%s\n' "$RTBL" "$ATBL" | while IFS= read -r l; do $G -qxF -- "$l" README.md || { echo "  *** README.md's rules table does not hold the capture's row: $l ***" >&3; exit 1; }; done || exit 1
[ "$($G -cE '^\| .* \| `(Rb26|Jta26)\.' README.md || true)" = 12 ] || die "README.md's two rule tables: ten rows and two, each the capture's"
echo "  README.md's rule tables: the ten rows and allx's two = the captures' (built by rows.py)"
VS="the values the video may say: on H2 2.5.250, Spring Framework 7.0.10, Spring Data JPA 4.1.2, Hibernate 7.4.13.Final - rules: 10 rows, mismatches 0; checked KEPT · rollbackFor gone · RuntimeException gone · noRollbackFor KEPT · Error gone · caught KEPT · setRollbackOnly gone ($RSRO) · JTA checked KEPT · JTA runtime gone · JTA rollbackOn gone; the checked row: $RCH, then Initiating transaction commit · allexceptions (LABELLED): checked gone, JTA checked gone, noRollbackFor KEPT; default $ADEF; Boot's keys: $AKEYS · twowrites: $TWK; rollbackFor: $TWR · events: plain $EVP; AFTER_COMMIT $EVA; no transaction: $EVS; throwing listener: $EVT, the row kept; the anchor's add: $EVL · anchor B (18 tests passed): ${AB2##* } · ${AB3##* } ($ABOV · $ABX) · import ${ABI##* }; A: ${AA2##* } · ${AA3##* } · import $AAI · feed: $FDN; B'': FeedTest $FBT ($FBR) · seven: $S466, SQL lines ${SQB%% *}, during the seven ${SQB#* }, both trees · tests: 18 (14/3/1) · xcheck: $X09 · exercise: $EXBT, $EXBR -> rollbackFor = Exception.class: $EXSR ($EXW words)"
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
  ! $G -oE 'https?://[^ /]*' "$f" | $G -qvxE 'http://127\.0\.0\.1:2005[0-6]' || die "$f holds a URL (only TiffinBox's own loopback ports 20050-20056 may appear)"; done
for f in .r-*.out; do ! $G -E '^ *\$ .*(^|[ (])java ' "$f" | $G -vF -- "java $JL " > /dev/null || die "$f starts a JVM without its locale pinned (S6.1)"
  ! $G -E '^ *\$ .*(^|[ (])java -D' "$f" | $G -vF -- "perl -e 'alarm " > /dev/null || die "$f starts a JVM without its alarm (R.247)"; done
K1='pki''ll'; K2='kill''all'; ! $G -v '^ *#' receipts.sh | $G -qwE "$K1|$K2" || die "receipts.sh names $K1 or $K2 - every process is stopped by its pid"
for f in receipts.sh exercise/README.md exercise/SOLUTION.md; do ! $G -nE '(^|[;&|({] *)wait *($|[;&|)}])' "$f" | $G -vE '^[0-9]+: *#' > /dev/null || die "$f has a bare wait (S6.9)"; done
! $G -rq 'probe\.t' after/tiffinbox-web after/tiffinbox-core || die "the anchor's code names the course's harness - it is never TiffinBox's"
! $G -rqE '^package com\.tiffinbox' harness/src || die "a harness class sits in com.tiffinbox (R.43)"
! $G -rqE 'Thread\.sleep' harness/src || die "a harness sleeps (S4.18)"
[ -z "$(find . "$UP" -maxdepth 1 \( -name '*.mv.db' -o -name '*.trace.db' \) 2> /dev/null; find . -path ./.m2-demo -prune -o -path ./.harness -prune -o \( -name '*.mv.db' -o -name '*.trace.db' \) -print)" ] || die "an H2 database file exists outside .harness - every H2 here is in memory (R.195)"
echo "  hygiene: raw token copies after mask: 0 in $(ls .harness/raw-* | wc -l | tr -d ' ') raw capture runs, $(ls .r-*.out | wc -l | tr -d ' ') captures and every log ($LOGS JVM logs); 'GenerationTarget encountered exception' 0; no path, unit number, time, millisecond figure, OS token, unmasked identity or generated name, URL or stack frame in any capture; every JVM pinned and under its alarm; no kill by name; no bare wait; no sleep in the harness; no H2 file"
# ---- the end: the anchor, the ports ----------------------------------------------------------------------------------------
anchornote end
for p in $PORTS; do [ "$(listeners $p)" = 0 ] || die "something listens on $p at the end"; done
echo "  ports: nothing listens on 18425, 8080, 35729 or 20050-20059 at the end - TiffinBox bound 20050-20056 and stopped; 20057-20058 unused; 20059 never bound"
[ -z "$unpub" ] || die "no published hash for:$unpub - check the captures, then copy the md5s above into receipts.md5 and run again"
echo "c7-unit26: every capture 3/3 and = published; every spoken number asserted; 0 raw tokens; no port bound but 20050-20056"
