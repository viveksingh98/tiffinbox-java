#!/bin/bash
XPATH=$PATH                                           # the PATH you started this with: the exercise's own shells get it
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25.0.4.1 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# Course 7 · Optimistic Locking with @Version - this unit's receipts. The course's ninth change to the anchor, Section 4's second and
# last (brief flag 1, C2): before/ is the link to ../c7-unit26/after; after/ is this unit's tree, ../c7-tiffinbox equals it, and it
# is Section 4's frozen anchor. CustomerEntity gains @Version private Long version and getVersion(); Database's customer table gains
# version BIGINT NOT NULL DEFAULT 0. Nine captures, each run three times and hashed; a hash that differs from receipts.md5 stops the
# run; every number and string the video says is asserted right after its capture by a check that can fail. One database: H2, in
# each JVM's memory.
#   version   the column (harness, over after/'s libraries): a new customer's INSERT binds version 0; an edit's UPDATE sets version
#             one more and carries the old one in its where clause; read back
#   race      two edits of Ravi at once, ordered by latches (A loads, B loads, B adds 5 and commits, A adds 1 and commits), three
#             rounds per JVM: B over before/'s libraries (no version: both commit, the +5 lost - the failure receipt); A over
#             after/'s (A's UPDATE matches no row: ObjectOptimisticLockingFailureException); A' over after/ built again
#   merge     a stale copy saved after another transaction moved the row (harness, after/'s): the second message, no UPDATE sent
#   modes     LockModeType.OPTIMISTIC and OPTIMISTIC_FORCE_INCREMENT on a load that changes nothing (harness, after/'s)
#   anchor    the change (after/ against before/), the sentences that stated the old DDL (R.250); TiffinBox B/A/A'/C (S4.9):
#             B = the entity alone (after/ with before/'s Database: no column) - the start fails; A = after/ - POST 201, 409, and
#             the first edit of a seeded customer (harness over after/'s libraries); A' built again; C = a nullable column
#             (labelled) - TiffinBox starts and answers, and the first edit of a seeded customer fails at its commit
#   seven     before/'s jar and after/'s, the seven each, Hibernate's SQL logger on (a guard, R.190; the select lists differ)
#   tests     TiffinBox's tests on after/ (the README's line, offline), from Surefire's reports (C7-4)
#   xcheck    the harness's DDL script over before/'s libraries and over after/'s: before/'s = the owning-side lesson's published
#             md5; after/'s = xcheck.sql, filed in this folder (R.252: the hash moved); the one line that differs
#   exercise  exercise/README.md's commands, then exercise/SOLUTION.md's, read from the files and run as written, in ONE env -i
#             shell - /bin/bash, then again in /bin/zsh -f; each file's "What it prints" block = what it printed
# Every tree is COPIED under .harness/ and built there, never in place, with the README's package line, offline (before/, after/ and
# C run their tests inside that build; B and A' are built with -DskipTests). The harness (harness/src, packages probe.t and probe.x,
# outside com.tiffinbox) is compiled twice with javac -parameters: against before/'s extracted libraries into .harness/hc (race B)
# and against after/'s into .harness/hce (everything else; C's and A''s libraries hold the same CustomerEntity). probe.t.Main is a
# Spring Boot context with no web server (WebApplicationType.NONE: it binds no port), @EntityScan and @EnableJpaRepositories on
# com.tiffinbox - the anchor's own CustomerEntityRepository; probe.t.Seed builds the shipped Database in code on the run's own H2
# database; ddl-auto none. Logback (harness/logback.xml) prints each line's thread, Hibernate's SQL logger and its bind logger
# (TRACE: the version values each statement binds), and the transaction manager's DEBUG lines (S4.1's first witness). The method's
# own TransactionSynchronizationManager print is the second witness; the third is the second connection: DriverManager on the same
# jdbc:h2:mem:u27 URL, read after the call returned or threw. The race's order is kept by CountDownLatches and read off the capture
# (S4.6, S4.18) - no sleep anywhere in the harness. Every JVM's flags travel as an array, V, its arguments as an array, A (R.193);
# every JVM runs under an alarm (perl -e 'alarm N; exec ...': macOS has no timeout); an alarm that fires is a failed receipt (R.247).
# Commands are printed exactly as they run: each goes through eval. harness/dur7.py (Course 7's builders' duration pattern, byte for
# byte) and S4.7's duration-meaning family gate this unit's prose: it speaks no time (R.172, R.264). "$M2" is this unit's .m2-demo.
# "$CURLSET" is ../c5-unit11/curlset.sh (the seven, POST /shutdown last). harness/surefire.py (the testing lesson's, byte for byte)
# reads Surefire's reports. The locale: every JVM has its locale pinned on its run line (-Duser.language=en -Duser.country=US).
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
# Ports (§P, 20060-20069): 20060 anchor B · 20061 anchor A · 20062 A' · 20063 unused (A's POSTs run on 20061) · 20064 seven before/
# · 20065 seven after/ · 20066 unused (xcheck binds none) · 20067 anchor C · 20068 unused · 20069 never bound; all ten, 18425
# (TiffinBox's default), 8080 and 35729 checked free at the start and the end.
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
[ -L before ] && [ "$(readlink before)" = ../c7-unit26/after ] || die "before must be the link to ../c7-unit26/after - the anchor before this change"
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
    echo "  the anchor ($1): after/ is this unit's tree (C2) - a later anchor change has moved ../c7-tiffinbox on"; fi; }
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
SFILES='probe/t/Edit27.java probe/t/H.java probe/t/Main.java probe/t/Run.java probe/t/Seed.java probe/t/ex/ExApp.java probe/x/XMain.java'
for f in exercise/README.md exercise/SOLUTION.md README.md receipts.md5 xcheck.sql; do [ -f "$f" ] || die "$f is missing"; done
[ "$(ls harness | paste -sd' ' -)" = "$HFILES" ] && [ "$(cd harness/src && find . -type f | sed 's#^\./##' | sort | paste -sd' ' -)" = "$SFILES" ] || die "harness/ holds another file, or misses one"
[ "$(ls exercise | paste -sd' ' -)" = 'README.md SOLUTION.md' ] || die "exercise/ holds another file"
[ "$(md5 -q harness/dur7.py)" = 41667fed9ffcefe171389eed7e654e66 ] || die "harness/dur7.py is not the builders' dur7.py (md5 41667fed…)"
if [ -f ../../../data-jpa-hibernate/_builders/dur7.py ]; then cmp -s harness/dur7.py ../../../data-jpa-hibernate/_builders/dur7.py || die "harness/dur7.py differs from the builders' _builders/dur7.py"
  echo "  (terminal only) harness/dur7.py = the builders' _builders/dur7.py, byte for byte" >&3
else echo "  (terminal only) the builders' _builders/dur7.py is not beside this clone: its md5 above is the check" >&3; fi
cmp -s harness/surefire.py ../c6-unit28/harness/surefire.py || die "harness/surefire.py is not the testing lesson's (../c6-unit28/harness/surefire.py), byte for byte"
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
PORTS="18425 8080 35729 20060 20061 20062 20063 20064 20065 20066 20067 20068 20069"
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
# the brief's exercise line for this unit (pinned, its 22 words) says "twice at once" - two edits together, no time; that one
# sentence, whole, is taken out the same way (For RED: the 27 builder needs the same, or the brief's line changes)
EXL = "the README edits Ravi twice at once, and one edit disappears without an error. Make the losing edit fail loudly."
assert FAM.search(EXL) and not FAM.search(("x " + EXL + " y").replace(EXL, ""))
n = f = 0
for p in sys.argv[2:]:
    for i, l in enumerate(open(p, encoding="utf-8"), 1):
        l = l.replace(C13, "").replace(EXL, "")
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
# after/README.md's unit 27 section - the anchor's own prose about this change, read by the gates below with the unit's prose
SECT=$(awk '/^## Course 7 · unit 27 /{f=1} f && /^## / && !/unit 27 /{f=0} f' after/README.md)
[ -n "$SECT" ] || die "after/README.md has no Course 7 · unit 27 section"
printf '%s\n' "$SECT" > .harness/section.md
# S4.8 + S4.14 (R.265, R.271): a refused reading - Hibernate's old message with its "unsaved-value mapping" clause, which this
# Hibernate does not print (merge prints the second message, race the first) - in no line of this unit's prose, the anchor's unit 27
# section or the two changed sources
UV=$($G -niE 'unsaved-value|or deleted by another transaction \(or' $PROSE .harness/section.md after/$CJ/CustomerEntity.java after/$CJ/Database.java 2> /dev/null | cut -c1-160 | head -3 | paste -sd';' - || true)
[ -z "$UV" ] || die "S4.8: a refused name - the unsaved-value mapping message is not this Hibernate's (merge and race print the two it does): $UV"
echo "  S4.8's refused names: 0 ('unsaved-value', the old message's clause) over README.md, exercise/, after/README.md's unit 27 section and the two changed sources"
# R.225: a SQL string this unit shows is the logger's - a line of README.md holding an INSERT's or UPDATE's head, a lock mode's
# SELECT, Hibernate's alias or the count's SELECT is a typed SQL string, refused; the values block (composed by this script from the
# captures and compared whole, below) is the one place they appear
SQLRE='insert into customer|update customer|select version|ce1_0\.|select count\(\*\) from customer'
TS=$(awk '/^<!-- values: begin -->$/ { v = 1; next } /^<!-- values: end -->$/ { v = 0; next } !v { print NR ": " $0 }' README.md | $G -E "$SQLRE" | cut -c1-160 | head -3 | paste -sd';' - || true)
[ -z "$TS" ] || die "a typed SQL string in README.md (R.225): $TS"
echo "  typed SQL strings: 0 in README.md outside its values block"
# R.250 + R.252: C2 moves Hibernate's own DDL for the entities - every sentence in after/ that said it is unit 09's is rewritten to
# say it was, and that it moved here. The old sentences (each read off before/, asserted there first): 0 in after/'s README; the
# note that amends each, 4; the old md5 0 anywhere in after/; in this unit's README the old md5 only beside the new one
OLDD=("Boot's own DDL for the entities is unit 09's, byte for byte (\`xcheck\`)." "Boot's own DDL for the entities is unit 09's," "Boot's own DDL for the entities unit 09's, byte for")
NOTE27="*(Course 7, unit 27: it moved there — the \`version\` column; its section below)*"
OB=0; for s in "${OLDD[@]}"; do n=$($G -cF -- "$s" before/README.md || true); OB=$((OB + n))
  [ "$($G -cF -- "$s" after/README.md || true)" = 0 ] || die "R.250: after/README.md still says the entities' DDL is unit 09's: $s"; done
[ "$OB" = 6 ] || die "R.250: before/README.md must hold the old DDL sentences 6 times (two whole, their prefix three times with the split one, the unit 26 one): $OB"
[ "$($G -cF -- "$NOTE27" after/README.md || true)" = 4 ] || die "R.250: after/README.md must amend the four DDL sentences with the unit 27 note"
OM=$($G -rln f595637014 after 2> /dev/null | paste -sd' ' - || true)
[ -z "$OM" ] || die "R.250: the old DDL md5 is still in after/: $OM"
OL=$($G -n f595637014 README.md | $G -v 9cf92b8c | cut -c1-160 | head -2 | paste -sd';' - || true)
[ -z "$OL" ] || die "R.250: README.md names the old DDL md5 without the new one beside it: $OL"
[ "$($G -c '^    @Version$' after/$CJ/CustomerEntity.java)" = 1 ] && [ "$($G -c '^    private Long version;$' after/$CJ/CustomerEntity.java)" = 1 ] && [ "$($G -c '^    public Long getVersion() {$' after/$CJ/CustomerEntity.java)" = 1 ] || die "C2: after/'s CustomerEntity must carry @Version private Long version and getVersion()"
[ "$($G -c 'Version' before/$CJ/CustomerEntity.java || true)" = 0 ] || die "C2: before/'s CustomerEntity must have no version"
[ "$($G -cxF '                    version       BIGINT      NOT NULL DEFAULT 0' after/$CJ/Database.java)" = 1 ] && [ "$($G -ci 'version' before/$CJ/Database.java || true)" = 0 ] || die "C2: after/'s Database must create version BIGINT NOT NULL DEFAULT 0, before/'s no version"
echo "  R.250: the DDL sentences that said unit 09's - 6 lines in before/README.md, 0 in after/'s; the unit 27 note 4 times; the old md5 0 in after/ and only beside the new one here; C2's field, getter and column in after/, none in before/"

# ---- the commands: read from after/README.md, the anchor's own, and asserted - each line must be there, whole -------------
readme() { $G -m1 -xF -- "$1" after/README.md > /dev/null || die "after/README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
R_PLAIN=$(readme 'mvn -B package')
R_TEST=$(readme 'mvn -B clean test')
R_EXTRACT=$(readme 'java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted')
R_RUN=$(readme 'java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431')
R_POST=$(readme "curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '{\"name\":\"Asha\",\"mealsPerDay\":2,\"pricePerMeal\":110,\"mealType\":\"VEG\"}' http://127.0.0.1:18431/customers")
R_GET=$(readme 'curl -s -w '"' %{http_code}\\n'"' http://127.0.0.1:18431/customers')
R_TOKEN=$(readme 'mkdir -p secrets/tiffinbox && (umask 077 && printf '"'"'%s\n'"'"' "$(openssl rand -hex 16)" > secrets/tiffinbox/shutdown-token)')
mine() { $G -m1 -xF -- "$1" README.md > /dev/null || die "README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
JL='-Duser.language=en -Duser.country=US'
AL="perl -e 'alarm 240; exec @ARGV'"
HSRC="$HS/Edit27.java $HS/H.java $HS/Main.java $HS/Run.java $HS/Seed.java harness/src/probe/x/XMain.java"
L_JAVAC=$(mine "javac -parameters -d .harness/hc -cp \".harness/before/$XD/lib/*\" $HSRC")
L_JAVACE=$(mine "javac -parameters -d .harness/hce -cp \".harness/after/$XD/lib/*\" $HSRC")
L_H=$(mine "$AL java $JL -Dstdout.encoding=UTF-8 \"\${V[@]}\" -cp \"../hc:../before/$XD/lib/*\" probe.t.Main \"\${A[@]}\"")
L_HE=$(mine "$AL java $JL -Dstdout.encoding=UTF-8 \"\${V[@]}\" -cp \"../hce:../after/$XD/lib/*\" probe.t.Main \"\${A[@]}\"")
L_HA2=$(mine "$AL java $JL -Dstdout.encoding=UTF-8 \"\${V[@]}\" -cp \"../hce:../ana2/$XD/lib/*\" probe.t.Main \"\${A[@]}\"")
L_HC=$(mine "$AL java $JL -Dstdout.encoding=UTF-8 \"\${V[@]}\" -cp \"../hce:../anc/$XD/lib/*\" probe.t.Main \"\${A[@]}\"")
L_X=$(mine "$AL java $JL -Dstdout.encoding=UTF-8 -cp \"../hce:../after/$XD/lib/*\" probe.x.XMain \"\${A[@]}\"")
L_XB=$(mine "$AL java $JL -Dstdout.encoding=UTF-8 -cp \"../hce:../before/$XD/lib/*\" probe.x.XMain \"\${A[@]}\"")
L_B=$(mine "cp before/$CJ/Database.java .harness/anb/$CJ/Database.java")
L_C=$(mine "perl -pi -e 's/^( +version +BIGINT) +NOT NULL DEFAULT 0\$/\$1/' .harness/anc/$CJ/Database.java")
L_SQL=$(mine "$R_RUN --logging.level.org.hibernate.SQL=debug")
off() { local c=${2/mvn -B /mvn -o -B -Dmaven.repo.local=\"\$M2\" }
  [ -n "${3:-}" ] && c=${c/ $3/ clean $3}
  printf 'cd %s && %s\n' "$1" "$c"; }
exe() { printf '%s\n' "$1" | sed -E 's/&& (([A-Z_]+=[^ ]* )*)/\&\& \1exec /'; }
at() { local l=${3/--tiffinbox.port=18431/--tiffinbox.port=$2}; case $l in 'java '*) l="$AL java $JL ${l#java }" ;; esac; printf 'cd %s && %s\n' "$1" "$l"; }
url() { printf '%s\n' "$1" | sed "s#http://127.0.0.1:18431#http://127.0.0.1:$2#; s#^curl -s #curl -s --noproxy '*' #"; }
[ "$(off .harness/after "$R_PLAIN" package)" = 'cd .harness/after && mvn -o -B -Dmaven.repo.local="$M2" clean package' ] || die "off(): the build line is not the README's package line, offline"
[ "$(exe "$(at .harness/after 20061 "$R_RUN")")" = "cd .harness/after && exec $AL java $JL -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=20061" ] || die "at(): the run line is not the README's"
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
# anchor B: after/ with before/'s Database.java (L_B: the entity alone, no column) - that file, asserted the only difference; A' a
# second copy of after/ (R.1: a fresh build); C: after/ with the column's NOT NULL DEFAULT 0 taken off (L_C) - that one line
copy after .harness/anb; (eval "$L_B") || die "L_B did not run"
ABD=$(diff -rq .harness/after .harness/anb | sed 's#\.harness/##g' | paste -sd'|' - || true)
[ "$ABD" = "Files after/$CJ/Database.java and anb/$CJ/Database.java differ" ] || die "anchor B's copy must differ from after/ by Database.java alone: ${ABD:-no difference}"
copy after .harness/anc; (eval "$L_C") || die "L_C did not run"
ACD=$(diff -r .harness/after .harness/anc | $G -E '^[<>]' | paste -sd'|' - || true)
[ "$ACD" = '<                     version       BIGINT      NOT NULL DEFAULT 0|>                     version       BIGINT' ] || die "C's copy must differ from after/ by the column's NOT NULL DEFAULT 0, and nothing else: ${ACD:-no difference}"
copy after .harness/ana2
mbuild "$(off .harness/before "$R_PLAIN" package)" .harness/build-before.log ".harness/before (before/, the README's package line; its tests ran)"
[ "$(summ4 .harness/build-before.log)" = '18 0 0 0' ] || die "before/'s tests: $(summ4 .harness/build-before.log) - expected 18 0 0 0"
mbuild "$(off .harness/after "$R_PLAIN" package)" .harness/build-after.log ".harness/after (after/, the README's package line; its tests ran)"
[ "$(summ4 .harness/build-after.log)" = '18 0 0 0' ] || die "after/'s tests: $(summ4 .harness/build-after.log) - expected 18 0 0 0"
mbuild "$(off .harness/anb "$R_PLAIN" package) -DskipTests" .harness/build-anb.log ".harness/anb (anchor B, labelled: the entity alone; the same line, -DskipTests)"
mbuild "$(off .harness/ana2 "$R_PLAIN" package) -DskipTests" .harness/build-ana2.log ".harness/ana2 (anchor A', after/ copied again; the same line, -DskipTests)"
mbuild "$(off .harness/anc "$R_PLAIN" package)" .harness/build-anc.log ".harness/anc (anchor C, labelled: a nullable column; the README's package line, its tests ran)"
[ "$(summ4 .harness/build-anc.log)" = '18 0 0 0' ] || die "anchor C's tests: $(summ4 .harness/build-anc.log) - the tests did not notice: expected 18 0 0 0"
echo "  the tests inside the builds (each build's summary lines summed): before/ $(summ4 .harness/build-before.log) · after/ $(summ4 .harness/build-after.log) · C $(summ4 .harness/build-anc.log) (run, failures, errors, skipped)"
for t in before after anb ana2 anc; do (cd .harness/$t && eval "$R_EXTRACT") > .harness/extract-$t.log 2>&1 < /dev/null || die "the extract of $t failed: $(tail -3 .harness/extract-$t.log)"; done
for a in org/springframework/boot/spring-boot-starter-parent/4.1.2/spring-boot-starter-parent-4.1.2.pom org/hibernate/orm/hibernate-core/7.4.13.Final/hibernate-core-7.4.13.Final.jar org/springframework/data/spring-data-jpa/4.1.2/spring-data-jpa-4.1.2.jar org/springframework/spring-tx/7.0.10/spring-tx-7.0.10.jar com/h2database/h2/2.5.250/h2-2.5.250.jar; do
  [ -e "$M2/$a" ] || die "$a is not in .m2-demo - README.md, The repository"; done
(cd .harness/after && eval "$R_TOKEN") || die "the token was not written"
TOKEN=$(head -n 1 .harness/after/$TF); [ ${#TOKEN} = 32 ] || die "the generated token is not 32 characters"
for t in before anb ana2 anc; do mkdir -p .harness/$t/secrets/tiffinbox && (umask 077 && cp .harness/after/$TF .harness/$t/$TF); done
for t in before after anb ana2 anc; do [ "$(stat -f '%Lp' .harness/$t/$TF)" = 600 ] || die "the token's file in $t must be mode 0600"; done
echo "  the token: generated once (openssl rand -hex 16, the README's line, in .harness/after), copied into every tree's $TF, mode 0600, never printed"
jc "$L_JAVAC" .harness/javac.log; [ "$JE" = 0 ] || die "the harness did not compile (hc): $(head -5 .harness/javac.log)"
jc "$L_JAVACE" .harness/javace.log; [ "$JE" = 0 ] || die "the harness did not compile (hce): $(head -5 .harness/javace.log)"
[ ! -e .harness/hc/probe/t/ex ] && [ ! -e .harness/hce/probe/t/ex ] || die "the exercise's class compiled into the wrong place"
cmp -s .harness/after/$XD/lib/tiffinbox-core-1.0.0.jar .harness/ana2/$XD/lib/tiffinbox-core-1.0.0.jar 2> /dev/null; echo "  (terminal only) after/'s and A''s core jars byte-equal: $( [ $? = 0 ] && echo yes || echo no) - the harness classes compiled against after/'s run over both" >&3
echo "  extracted five jars ($(for t in before after anb ana2 anc; do ls .harness/$t/$XD/lib | wc -l | tr -d ' '; done | paste -sd/ -) libraries: before/after/B/A'/C); the harness compiled twice - .harness/hc over before/'s, .harness/hce over after/'s"
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
HA=('--spring.datasource.url=jdbc:h2:mem:u27;DB_CLOSE_DELAY=-1' --logging.config=../../harness/logback.xml --spring.jpa.hibernate.ddl-auto=none --spring.main.banner-mode=off --spring.thymeleaf.check-template-location=false)
HE=""
hrun() { local c i=0 e=0
  c=$(printf 'cd .harness/run && %s\n' "${HL:-$L_H}")
  if [ "${HL:-$L_H}" != "$L_X" ] && [ "${HL:-$L_H}" != "$L_XB" ]; then echo "\$ V=($(printf '%s ' "${V[@]}" | sed 's/ $//'))"; fi
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
    i = index(s, " : "); lg = substr(s, 1, i - 1); sub(/^ +/, "", lg); sub(/ +$/, "", lg); m = substr(s, i + 3); sub(/[ \t]+$/, "", m)
    if ($2 == "WARN" || $2 == "ERROR") print "    " $2 " " lg ": " (length(m) > 220 ? substr(m, 1, 220) " …" : m); next }
    /^Caused by: / || /^[a-z][A-Za-z0-9_.]*\.[A-Z][A-Za-z0-9_$]*(Exception|Error): / { m = $0; sub(/[ \t]+$/, "", m); print "    " (length(m) > 220 ? substr(m, 1, 220) " …" : m) }' .harness/run.out
  logtok; rm -f .harness/run.out; }
# ---- the captures --------------------------------------------------------------------------------------------------------
version() { echo "version - the column: one harness JVM over after/'s libraries:"; V=(-Ds=version); A=("${HA[@]}"); HL=$L_HE; hrun; HL=""; hview; }
race() { echo "race - B: before/'s libraries (CustomerEntity with no version), one harness JVM, three rounds - the failure receipt:"
  V=(-Ds=race); A=("${HA[@]}"); hrun; hview
  echo "race - A: after/'s libraries (CustomerEntity with @Version), one harness JVM, three rounds:"; HL=$L_HE; hrun; HL=""; hview
  echo "race - A': .harness/ana2's libraries (after/ copied again and built again), one harness JVM, three rounds:"; HL=$L_HA2; hrun; HL=""; hview; }
merge() { echo "merge - a stale copy: one harness JVM over after/'s libraries:"; V=(-Ds=merge); A=("${HA[@]}"); HL=$L_HE; hrun; HL=""; hview; }
modes() { echo "modes - two lock modes: one harness JVM over after/'s libraries:"; V=(-Ds=modes); A=("${HA[@]}"); HL=$L_HE; hrun; HL=""; hview; }
POSTK=${R_POST/\"name\":\"Asha\"/\"name\":\"Kavya\"}
anchorup() { local t=$1 p=$2
  start "$(at .harness/$t $p "$R_RUN")" $p; up $p; ready $p
  echo "  POST /customers, Kavya (the README's JSON line, the name Kavya):"; req "$POSTK" $p
  echo "  the same again:"; req "$POSTK" $p
  echo "  then:"; echo "\$ $(url "$R_GET" $p)"; echo "  -> the names: $(eval "$(url "$R_GET" $p)" 2> /dev/null | names)"
  stopit $p; logtok; rm -f .harness/run.out; }
anchor() { local f
  echo "the change - after/ against before/ (diff -rq, the file names):"
  diff -rq before after | sed -E 's#^Files before/(.*) and after/.* differ$#  \1#; s#^Only in after/(.*): (.*)$#  \1/\2 (new)#' | sort
  for f in $CJ/CustomerEntity.java $CJ/Database.java; do echo "$f:"; cdiff "before/$f" "after/$f"; done
  echo "B - labelled: the entity alone - after/ with before/'s Database.java, no version column (.harness/anb, built -DskipTests), port 20060 - the start:"
  echo "  its difference from after/: $(diff -rq -x target -x secrets .harness/after .harness/anb | sed -E 's#^Files \.harness/after/(.*) and .* differ$#\1#')"
  startfail "$(at .harness/anb 20060 "$R_RUN")" 20060
  echo "A - after/'s jar (@Version, the column NOT NULL DEFAULT 0), port 20061:"; anchorup after 20061
  echo "A - the first edit of a seeded customer: one harness JVM over after/'s libraries:"; V=(-Ds=seededit); A=("${HA[@]}"); HL=$L_HE; hrun; HL=""; hview
  echo "A' - after/ copied again and built again (.harness/ana2), port 20062:"; anchorup ana2 20062
  echo "C - labelled: a nullable column - after/ with the column's NOT NULL DEFAULT 0 taken off (.harness/anc, built; its tests ran: run, failures, errors, skipped $(summ4 .harness/build-anc.log)), port 20067:"
  echo "  its one line: $(diff .harness/after/$CJ/Database.java .harness/anc/$CJ/Database.java | $G '^>' | sed 's/^> *//')"
  anchorup anc 20067
  echo "C - the first edit of a seeded customer: one harness JVM over C's libraries:"; V=(-Ds=seededit); A=("${HA[@]}"); HL=$L_HC; hrun; HL=""; hview; }
sqlseg() { sed -n "${1},${2}p" .harness/run.out | $G -cE ' org\.hibernate\.SQL +: ' || true; }
seven7() { local t p n0 ns
  for t in before:20064 after:20065; do p=${t#*:}; t=${t%:*}
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
    sed -n "$((n0 + 1)),\$p" .harness/run.out | sed -n -E 's/^.* org\.hibernate\.SQL +: (.*)$/\1/p' | sort | uniq -c | sed -E 's/^ *([0-9]+) (.*)$/    \1 x \2/' | tee .harness/stm-$t.txt
    logtok; rm -f .harness/run.out; done
  echo "  the seven, after/ against before/: lines that differ: $(diff .harness/seven-before.txt .harness/seven-after.txt | $G -c '^[<>]' || true)"
  echo "  the statements during the seven, after/ against before/ (diff, each with how often):"; diff .harness/stm-before.txt .harness/stm-after.txt | $G '^[<>]' | sed 's/^/  /' || true; }
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
X27=9cf92b8cae3abfd0f1c0706bfe7a4373                # Boot's script after C2 - xcheck.sql, filed in this folder (the brief's, RED #1214)
[ "$($G -c "$X09" ../c7-unit09/README.md || true)" -gt 0 ] || die "../c7-unit09/README.md must name $X09 - Boot's script md5 (R.212)"
[ "$(awk '$1 == "xcheck" { print $2 }' ../c7-unit09/receipts.md5)" = "$X09CAP" ] || die "../c7-unit09/receipts.md5's xcheck is not $X09CAP - the capture that holds Boot's script"
[ "$(md5 -q xcheck.sql)" = "$X27" ] || die "xcheck.sql is not the filed script (md5 $X27)"
XA=('--spring.datasource.url=jdbc:h2:mem:x27;DB_CLOSE_DELAY=-1' --logging.config=../../harness/logback.xml --spring.jpa.hibernate.ddl-auto=none --spring.main.banner-mode=off --spring.thymeleaf.check-template-location=false --spring.jpa.properties.jakarta.persistence.schema-generation.scripts.action=create --spring.jpa.properties.jakarta.persistence.schema-generation.scripts.create-target=hibernate-ddl.sql)
xcheck() { local t
  for t in before after; do
    echo "the harness's DDL over $t/'s libraries - probe.x.XMain (@EntityScan(\"com.tiffinbox\") alone: no repository, no seed), scripts.action=create (a file, never run):"
    rm -f .harness/run/hibernate-ddl.sql
    A=("${XA[@]}"); if [ $t = before ]; then HL=$L_XB; else HL=$L_X; fi; hrun; hview; HL=""
    [ -f .harness/run/hibernate-ddl.sql ] || die "xcheck: no script over $t/'s libraries"
    mv .harness/run/hibernate-ddl.sql .harness/ddl-$t.sql
    echo "  .harness/ddl-$t.sql - every line:"; sed -E 's/FK[0-9a-z]{20,}/FK<name>/g; s/^/    /' .harness/ddl-$t.sql
    echo "  its md5: $(md5 -q .harness/ddl-$t.sql)"; done
  echo "the two scripts - \$ diff .harness/ddl-before.sql .harness/ddl-after.sql:"; diff .harness/ddl-before.sql .harness/ddl-after.sql | sed -E 's/FK[0-9a-z]{20,}/FK<name>/g; s/^/  /' || true
  echo "  the after/ line with ', version bigint not null' taken out = the before/ line: $( [ "$(diff .harness/ddl-before.sql .harness/ddl-after.sql | $G '^>' | sed 's/^> //; s/, version bigint not null//')" = "$(diff .harness/ddl-before.sql .harness/ddl-after.sql | $G '^<' | sed 's/^< //')" ] && echo yes || echo no)"
  echo "  before/'s md5: $(md5 -q .harness/ddl-before.sql) · the owning-side lesson's (its README names it $($G -c "$X09" ../c7-unit09/README.md || true) times; its xcheck published $X09CAP): $X09 · the same: $( [ "$(md5 -q .harness/ddl-before.sql)" = "$X09" ] && echo yes || echo no)"
  echo "  after/'s md5: $(md5 -q .harness/ddl-after.sql) · the filed xcheck.sql: $(md5 -q xcheck.sql) · cmp: $(cmp -s .harness/ddl-after.sql xcheck.sql && echo 'the same, byte for byte' || echo differ)"; }
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
# S4.13 (R.270): Framework's version in the same capture beside HHH000001 and Spring Data's - once per harness JVM, never typed
VERL='  PROBE Hibernate ORM core version (org.hibernate.Version.getVersionString()): 7.4.13.Final'
VERH='  INFO  [main] org.hibernate.orm.core : HHH000001: Hibernate ORM core version 7.4.13.Final'
VERD='  PROBE Spring Data JPA version (JpaRepository.class.getPackage().getImplementationVersion()): 4.1.2'
VERF='  PROBE Spring Framework version (Transactional.class.getPackage().getImplementationVersion()): 7.0.10'
DBL='  PROBE database: H2 2.5.250 | url jdbc:h2:mem:u27;DB_CLOSE_DELAY=-1'
SEEDL='  PROBE seeded by the shipped Database (createAndSeed); the second connection reads: customer rows 4 [1 Ravi, 2 Meera, 3 Sunil, 4 Priya]'
FOUND1='  INFO  [main] org.springframework.data.repository.config.RepositoryConfigurationDelegate : Finished Spring Data repository scanning in <n> ms. Found 1 JPA repository interface.'
VFA="  PROBE CustomerEntity's version field: java.lang.Long version · @Version true"
VFB="  PROBE CustomerEntity's version field: none - the class has no version field"
ver() { local c; c=$1
  [ "$(cnt "$c" "$VERL")" = "$2" ] && [ "$(cnt "$c" "$VERH")" = "$2" ] && [ "$(cnt "$c" "$VERD")" = "$2" ] && [ "$(cnt "$c" "$VERF")" = "$2" ] || die "$3: the version lines - getVersionString(), Hibernate's HHH000001, Spring Data JPA's 4.1.2 and Spring Framework's 7.0.10 - once in each of its $2 harness JVMs (S4.13)"
  [ "$(cnt "$c" "$DBL")" = "$2" ] && [ "$(cnt "$c" "$SEEDL")" = "$2" ] && [ "$(cnt "$c" "$FOUND1")" = "$2" ] || die "$3: the database: line (H2 2.5.250), the shipped seed read by the second connection and Spring Data's Found 1 - in each of its $2 harness JVMs"
  [ "$(cnt "$c" "  exit 0 · 'GenerationTarget encountered exception': 0")" = "$2" ] || die "$3: each of its $2 harness JVMs ends by itself, exit 0"; }
TXP='JpaTransactionManager : '
# sqlb.py CAPTURE-BLOCK-FILE PREFIX [N]: the Nth statement Hibernate's SQL logger printed that starts with PREFIX, and the values
# its bind logger printed right after it, named by the statement's own placeholders (a column list, or col=? pairs; where-clause
# pairs marked "where") - read off the capture, never typed
cat > .harness/sqlb.py <<'PY'
import re, sys
L = [l.rstrip("\n") for l in open(sys.argv[1], encoding="utf-8")]
pre = sys.argv[2]; occ = int(sys.argv[3]) if len(sys.argv) > 3 else 1
k = 0
for i, l in enumerate(L):
    m = re.match(r"^  DEBUG \[([^\]]+)\] org\.hibernate\.SQL : (.*)$", l)
    if not (m and m.group(2).startswith(pre)): continue
    k += 1
    if k != occ: continue
    th, st = m.groups(); vals = []
    for x in L[i + 1:]:
        b = re.match(r"^  TRACE \[" + re.escape(th) + r"\] org\.hibernate\.orm\.jdbc\.bind : binding parameter \((\d+):\w+\) <- \[(.*)\]$", x)
        if not b: break
        if int(b.group(1)) != len(vals) + 1: sys.exit("bind out of order: " + x)
        vals.append(b.group(2))
    names = []
    mi = re.match(r"^insert into \w+ \(([^)]*)\) values \(([^)]*)\)$", st)
    if mi:
        names = [c for c, v in zip(mi.group(1).split(","), mi.group(2).split(",")) if v == "?"]
    else:
        head, _, where = st.partition(" where ")
        names = re.findall(r"(\w+)=\?", head) + ["where " + w for w in re.findall(r"(\w+)=\?", where)]
    if len(names) != len(vals): sys.exit("placeholders %d, binds %d: %s" % (len(names), len(vals), st))
    print(th); print(st); print(" · ".join("%s=%s" % p for p in zip(names, vals)))
    sys.exit(0)
sys.exit("no statement starting with: " + pre)
PY
sqlb() { python3 -I -B .harness/sqlb.py "$@" || die "sqlb: $*"; }
INS=""; INSB=""; UPD=""; UPDB=""; RBK=""
chk_version() { local C x
  C=$(cat .r-version.out); ver "$C" 1 version; has "$C" "$VFA" "version: the field and its annotation, read off the class"
  blk version '  PROBE >>> a new customer' '  PROBE <<< a new customer' > .harness/b1
  x=$(sqlb .harness/b1 'insert into customer'); INS=$(printf '%s\n' "$x" | sed -n 2p); INSB=$(printf '%s\n' "$x" | sed -n 3p)
  printf '%s\n' "$INS" | $G -qE '^insert into customer \(.*,version,id\) values \(.*,default\)$' || die "version: the INSERT names version, then id (default): $INS"
  printf '%s\n' "$INSB" | $G -qE '(^| · )version=0$' || die "version: the INSERT binds version 0: $INSB"
  has "$C" '  PROBE save returned Kavya · id 5 · version 0' "version: the saved entity's version 0"
  has "$C" '  PROBE after: the second connection reads Kavya · meals_per_day 2 · version 0' "version: the row's version 0, by the second connection"
  blk version '  PROBE >>> an edit' '  PROBE <<< an edit' > .harness/b1
  x=$(sqlb .harness/b1 'update customer'); UPD=$(printf '%s\n' "$x" | sed -n 2p); UPDB=$(printf '%s\n' "$x" | sed -n 3p)
  printf '%s\n' "$UPD" | $G -qE '^update customer set .*,version=\? where id=\? and version=\?$' || die "version: the UPDATE sets version and checks it in its where clause: $UPD"
  printf '%s\n' "$UPDB" | $G -qE ' · version=1 · where id=5 · where version=0$' || die "version: the UPDATE binds the new version 1 and, in its where clause, the old 0: $UPDB"
  [ "$($G -cF -- "${TXP}Creating new transaction with name [probe.t.Edit27.edit]" .harness/b1)" = 1 ] && [ "$($G -c "${TXP}Initiating transaction commit" .harness/b1)" = 1 ] || die "version: the edit is one transaction, Edit27.edit's, committed"
  [ "$(awk -v t="${TXP}Initiating transaction commit" 'index($0, t) { c = NR } / org\.hibernate\.SQL : update customer / { u = NR } END { print (c && u > c) ? "yes" : "no" }' .harness/b1)" = yes ] || die "version: the UPDATE is sent at the commit, after the method returned"
  has "$C" '  PROBE after: the second connection reads Kavya · meals_per_day 3 · version 1' "version: the row after the edit: version 1"
  RBK=$(printf '%s\n' "$C" | sed -n 's/^  PROBE findById returned Kavya · //p')
  [ "$RBK" = 'mealsPerDay 3 · version 1' ] || die "version: read back - version 1: ${RBK:-none}"
  echo "  version: $INS binds $INSB; the edit: $UPD binds $UPDB (sent at the commit); read back $RBK"; }
# order.py BLOCK B|A: the race's three rounds, each read off the capture (S4.6, S4.18): A loaded, then B loaded, then B's commit and
# UPDATE, then A's change, then A's commit and UPDATE - by line order and thread; each UPDATE's binds; the outcome line
cat > .harness/order.py <<'PY'
import re, subprocess, sys
f, mode = sys.argv[1], sys.argv[2]
L = [l.rstrip("\n") for l in open(f, encoding="utf-8")]
bad = []; n = 0; ups = set()
def first(blk, pat, th=None):
    for i, l in enumerate(blk):
        if re.search(pat, l) and (th is None or l.startswith("  DEBUG [%s] " % th) or l.startswith("  TRACE [%s] " % th)): return i
    return -1
for r in (1, 2, 3):
    a = next((i for i, l in enumerate(L) if l.startswith("  PROBE >>> round %d · " % r)), None); b = L.index("  PROBE <<< round %d" % r) if a is not None else None
    if a is None: bad.append("round %d: no block" % r); continue
    blk = L[a:b + 1]; n += 1
    steps = [first(blk, r"^  PROBE A loaded Ravi · mealsPerDay 2"), first(blk, r"^  PROBE B loaded Ravi · mealsPerDay 2"),
             first(blk, r"JpaTransactionManager : Initiating transaction commit$", "B"), first(blk, r"org\.hibernate\.SQL : update customer ", "B"),
             first(blk, r"^  PROBE A sets mealsPerDay 3 and returns"), first(blk, r"JpaTransactionManager : Initiating transaction commit$", "A"),
             first(blk, r"org\.hibernate\.SQL : update customer ", "A")]
    if -1 in steps or steps != sorted(steps): bad.append("round %d: the order A loaded < B loaded < B commit < B UPDATE < A sets < A commit < A UPDATE: %s" % (r, steps)); continue
    open(f + ".r", "w").write("\n".join(blk) + "\n")
    bu = subprocess.run([sys.executable, "-I", "-B", sys.argv[3], f + ".r", "update customer", "1"], capture_output=True, text=True).stdout.split("\n")
    au = subprocess.run([sys.executable, "-I", "-B", sys.argv[3], f + ".r", "update customer", "2"], capture_output=True, text=True).stdout.split("\n")
    if bu[0] != "B" or au[0] != "A": bad.append("round %d: the two UPDATEs are B's, then A's: %s %s" % (r, bu[:1], au[:1])); continue
    ups.add(bu[1]); ups.add(au[1])
    print("round %d · order: A loaded, B loaded, B committed (its UPDATE), A changed, A committed (its UPDATE) · B's UPDATE binds %s · A's UPDATE binds %s" % (r, bu[2], au[2]))
    if mode == "A":
        rb = first(blk, r"JpaTransactionManager : Initiating transaction rollback after commit exception$", "A")
        if rb < steps[-1]: bad.append("round %d: A's rollback after its commit's exception" % r)
if len(ups) != 1: bad.append("the UPDATE statement differs between rounds: %s" % sorted(ups))
for x in bad: print("  mismatch: " + x)
print("UPDATE: %s" % (sorted(ups)[0] if ups else "none")); print("rounds %d · mismatches %d" % (n, len(bad)))
sys.exit(1 if bad else 0)
PY
RCB=""; RCA=""; RUB=""; RUA=""; RAX=""; RAC1=""; RAC2=""; ROB=""; ROA=""
chk_race() { local B A A2 o r
  B=$(blk race 'race - B:' 'race - A:'); A=$(blk race 'race - A:' "race - A':"); A2=$(blk race "race - A':" '')
  ver "$B" 1 "race B"; ver "$A" 1 "race A"; ver "$A2" 1 "race A'"
  has "$B" "$VFB" "race B: before/'s CustomerEntity has no version"; has "$A" "$VFA" "race A: after/'s CustomerEntity has @Version"
  printf '%s\n' "$B" > .harness/rb; printf '%s\n' "$A" > .harness/ra
  o=$(python3 -I -B .harness/order.py .harness/rb B .harness/sqlb.py) || die "race B: $(printf '%s\n' "$o" | $G -E 'mismatch|^rounds' | head -3 | paste -sd';' -)"
  [ "$(printf '%s\n' "$o" | tail -1)" = 'rounds 3 · mismatches 0' ] || die "race B: three rounds, in the latches' order"
  RUB=$(printf '%s\n' "$o" | sed -n 's/^UPDATE: //p'); ROB=$(printf '%s\n' "$o" | $G '^round 1 ' | sed 's/^round 1 · //')
  o=$(python3 -I -B .harness/order.py .harness/ra A .harness/sqlb.py) || die "race A: $(printf '%s\n' "$o" | $G -E 'mismatch|^rounds' | head -3 | paste -sd';' -)"
  [ "$(printf '%s\n' "$o" | tail -1)" = 'rounds 3 · mismatches 0' ] || die "race A: three rounds, in the latches' order"
  RUA=$(printf '%s\n' "$o" | sed -n 's/^UPDATE: //p'); ROA=$(printf '%s\n' "$o" | $G '^round 1 ' | sed 's/^round 1 · //')
  printf '%s\n' "$RUA" | $G -qE ' where id=\? and version=\?$' && ! printf '%s\n' "$RUB" | $G -q 'version' || die "race: A's UPDATE checks the version, B's names none: $RUA / $RUB"
  for r in 1 2 3; do
    has "$B" "  PROBE round $r · B committed, mealsPerDay 7 · A committed, mealsPerDay 3 · after both: the second connection reads Ravi · meals_per_day 3" "race B round $r: both commit, Ravi 3 - the +5 lost, no exception (the failure receipt)"
    has "$A" "  PROBE round $r · B committed, mealsPerDay 7 · A threw org.springframework.orm.ObjectOptimisticLockingFailureException · after both: the second connection reads Ravi · meals_per_day 7 · version 1" "race A round $r: A threw, Ravi 7"; done
  nhas "$B" 'threw' "race B: no exception in any round"
  RCB=3; RCA=7
  RAX=$(printf '%s\n' "$A" | sed -n 's/^  PROBE A threw: //p' | sort -u)
  [ "$(printf '%s\n' "$A" | $G -c '^  PROBE A threw: ')" = 3 ] && [ "$(printf '%s\n' "$RAX" | $G -c .)" = 1 ] || die "race A: the same exception in each of the three rounds"
  [ "$RAX" = "org.springframework.orm.ObjectOptimisticLockingFailureException: Unexpected row count (expected row count 1 but was 0) [$RUA] for entity [com.tiffinbox.CustomerEntity with id '1']" ] || die "race A: the exception's class, message, statement and entity (CustomerEntity itself, RE-MEASURE 6): ${RAX:-none}"
  RAC1=$(printf '%s\n' "$A" | sed -n 's/^  PROBE caused by: \(org\.hibernate\.StaleObjectStateException\): .*/\1/p' | sort -u); RAC2=$(printf '%s\n' "$A" | sed -n 's/^  PROBE caused by: \(org\.hibernate\.StaleStateException\): .*/\1/p' | sort -u)
  [ "$(printf '%s\n' "$A" | $G -cxF "  PROBE caused by: org.hibernate.StaleObjectStateException: ${RAX#*: }")" = 3 ] && [ "$(printf '%s\n' "$A" | $G -cxF "  PROBE caused by: org.hibernate.StaleStateException: Unexpected row count (expected row count 1 but was 0) [$RUA]")" = 3 ] || die "race A: its causes - StaleObjectStateException (the same message), then StaleStateException (the statement alone) - in each round"
  [ "$(printf '%s\n' "$A" | sed "s#\.\./after/#../<tree>/#")" = "$(printf '%s\n' "$A2" | sed "s#\.\./ana2/#../<tree>/#")" ] || die "race A': after/ built again prints what A printed (R.1)"
  echo "  race B (before/, no version): $ROB; every round B committed 7, A committed 3, Ravi 3, no exception; A (after/): $ROA; every round A threw $RAX ← $RAC1 ← $RAC2, Ravi 7; A' = A"; }
MGX=""; MGC=""
chk_merge() { local C
  C=$(cat .r-merge.out); ver "$C" 1 merge; has "$C" "$VFA" "merge: @Version"
  has "$C" "  PROBE findById returned a copy of Ravi · mealsPerDay 2 · version 0 · the copy is detached: its call's transaction committed" "merge: the copy at version 0"
  has "$C" '  PROBE after: the second connection reads Ravi · meals_per_day 3 · version 1' "merge: another transaction moved the row to version 1"
  blk merge '  PROBE >>> save(stale)' '  PROBE <<< save(stale)' > .harness/b1
  MGX=$(sed -n 's/^  PROBE save threw: //p' .harness/b1)
  [ "$MGX" = "org.springframework.orm.ObjectOptimisticLockingFailureException: Row was already updated or deleted by another transaction for entity [com.tiffinbox.CustomerEntity with id '1']" ] || die "merge: the second message, the same class: ${MGX:-none}"
  $G -qxF "  PROBE caused by: org.hibernate.StaleObjectStateException: ${MGX#*: }" .harness/b1 || die "merge: its cause, StaleObjectStateException"
  MGC=$($G -c ' org\.hibernate\.SQL : update ' .harness/b1 || true)
  [ "$MGC" = 0 ] && [ "$($G -c ' org\.hibernate\.SQL : select ' .harness/b1)" = 1 ] || die "merge: one SELECT and no UPDATE sent for the stale save: updates $MGC"
  $G -q "${TXP}Initiating transaction rollback$" .harness/b1 || die "merge: save's transaction rolled back"
  [ "$(printf '%s\n' "$C" | $G -cxF '  PROBE after: the second connection reads Ravi · meals_per_day 3 · version 1')" = 2 ] || die "merge: the row unchanged by the stale save"
  echo "  merge: save(stale) threw $MGX ← StaleObjectStateException; SQL during it: one select, $MGC updates; the row stays meals 3, version 1"; }
MOO=""; MOF=""; MOFB=""
chk_modes() { local C
  C=$(cat .r-modes.out); ver "$C" 1 modes
  blk modes '  PROBE >>> OPTIMISTIC ·' '  PROBE <<< OPTIMISTIC' > .harness/b1
  MOO=$(awk -v t="${TXP}Initiating transaction commit" 'index($0, t) { c = 1; next } c && / org\.hibernate\.SQL : / { sub(/^.* org\.hibernate\.SQL : /, ""); print }' .harness/b1)
  [ "$MOO" = 'select version as version_ from customer where id=?' ] || die "modes: OPTIMISTIC - at the commit, one SELECT of the version: ${MOO:-none}"
  has "$C" '  PROBE after: the second connection reads Ravi · meals_per_day 2 · version 0' "modes: OPTIMISTIC leaves the version 0"
  blk modes '  PROBE >>> OPTIMISTIC_FORCE_INCREMENT' '  PROBE <<< OPTIMISTIC_FORCE_INCREMENT' > .harness/b1
  x=$(sqlb .harness/b1 'update customer'); MOF=$(printf '%s\n' "$x" | sed -n 2p); MOFB=$(printf '%s\n' "$x" | sed -n 3p)
  [ "$MOF" = 'update customer set version=? where id=? and version=?' ] && [ "$MOFB" = 'version=1 · where id=1 · where version=0' ] || die "modes: OPTIMISTIC_FORCE_INCREMENT - an UPDATE of the version alone, no data column: $MOF ($MOFB)"
  [ "$(awk -v t="${TXP}Initiating transaction commit" 'index($0, t) { c = NR } / org\.hibernate\.SQL : update / { u = NR } END { print (c && u > c) ? "yes" : "no" }' .harness/b1)" = yes ] || die "modes: the force increment is sent at the commit"
  has "$C" '  PROBE after: the second connection reads Ravi · meals_per_day 2 · version 1' "modes: OPTIMISTIC_FORCE_INCREMENT - the version 1, the meals unchanged"
  echo "  modes: OPTIMISTIC - at the commit $MOO; OPTIMISTIC_FORCE_INCREMENT - $MOF binds $MOFB, meals unchanged, version 1"; }
ABX=""; ABC=""; ABS=""; ABCH=""; AA2=""; AA3=""; AAG=""; ASE=""; ASEB=""; AC2=""; AC3=""; ACX=""; ACR=""
chk_anchor() { local AN B A AE A2 C CE l x
  AN=$(cat .r-anchor.out)
  [ "$(printf '%s\n' "$AN" | sed -n '/^the change - after/,/^tiffinbox-core\/src\/main\/java\/com\/tiffinbox\/CustomerEntity.java:$/p' | $G '^  ' | paste -sd' ' -)" = "  README.md   $CJ/CustomerEntity.java   $CJ/Database.java" ] || die "anchor: the change is the README, CustomerEntity.java and Database.java - nothing else"
  for l in '    +import jakarta.persistence.Version;' '    +    @Version' '    +    private Long version;' '    +    public Long getVersion() {' '    -                    meal_type     VARCHAR(10) NOT NULL' '    +                    meal_type     VARCHAR(10) NOT NULL,' '    +                    version       BIGINT      NOT NULL DEFAULT 0'; do has "$AN" "$l" "anchor: the change"; done
  B=$(blk anchor 'B - labelled' 'A - after'); A=$(blk anchor "A - after/'s jar" 'A - the first edit'); AE=$(blk anchor 'A - the first edit' "A' - "); A2=$(blk anchor "A' - " 'C - labelled'); C=$(blk anchor 'C - labelled' 'C - the first edit'); CE=$(blk anchor 'C - the first edit' '')
  has "$B" "  its difference from after/: $CJ/Database.java" "anchor B: labelled, Database.java alone"
  has "$B" '  the JVM ended by itself: exit 1 · listening on 20060: 0' "anchor B: the start fails by itself, exit 1, no port"
  ABX=$(printf '%s\n' "$B" | sed -n 's/^    WARN org\.hibernate\.orm\.jdbc\.error: \(Column .*\)$/\1/p')
  ABS=$(printf '%s\n' "$B" | sed -n 's/^    WARN org\.hibernate\.orm\.jdbc\.error: HHH000247: ErrorCode: [0-9]*, SQLState: \([0-9A-Z]*\)$/\1/p')
  [ "$ABX" = 'Column "CE1_0.VERSION" not found; SQL statement:' ] && [ "$ABS" = 42S22 ] || die "anchor B: H2's refusal and its SQLState, as Hibernate logged them (S4.8): ${ABX:-none} / ${ABS:-none}"
  ABCH=$(printf '%s\n' "$B" | sed -n -E 's/^    (Caused by: )?([a-z][A-Za-z0-9_.]*\.[A-Z][A-Za-z0-9_$]*(Exception|Error)): .*$/\2/p' | paste -sd' ' -)
  [ "$ABCH" = 'org.springframework.beans.factory.BeanCreationException org.springframework.dao.InvalidDataAccessResourceUsageException org.hibernate.exception.SQLGrammarException org.h2.jdbc.JdbcSQLSyntaxErrorException' ] || die "anchor B: the chain - each class with its package (S4.8): ${ABCH:-none}"
  has "$B" "    org.springframework.beans.factory.BeanCreationException: Error creating bean with name 'tiffinBoxServer': Invocation of init method failed" "anchor B: the bean that read the table first"
  has "$B" '    Caused by: org.h2.jdbc.JdbcSQLSyntaxErrorException: Column "CE1_0.VERSION" not found; SQL statement:' "anchor B: the first cause, H2's own"
  for l in "$A:20061" "$A2:20062" "$C:20067"; do has "${l%:*}" "  listens on: 127.0.0.1:${l##*:}" "anchor: on loopback ${l##*:}"; has "${l%:*}" '  GET /actuator/health/readiness -> 200' "anchor: ready"
    has "${l%:*}" "  stopped by its pid (SIGTERM): exit 143 · listening on ${l##*:} now: 0" "anchor: stopped"; has "${l%:*}" '  its log: the token 0 times' "anchor: no token"; done
  ans() { printf '%s\n' "$1" | awk -v k="$2" 'index($0, "$ ") == 1 && index($0, k) { n++; if (n == '"${3:-1}"') { getline; sub(/^  -> /, ""); print; exit } }'; }
  AA2=$(ans "$A" '/customers' 1); AA3=$(ans "$A" '/customers' 2); AC2=$(ans "$C" '/customers' 1); AC3=$(ans "$C" '/customers' 2)
  [ "$AA2" = '{"name":"Kavya","mealType":"VEG"} 201' ] && [ "$AC2" = "$AA2" ] || die "anchor: the first POST 201 on A and on C: $AA2 / $AC2"
  [ "$AA3" = '{"detail":"a customer named Kavya already exists","instance":"/customers","status":409,"title":"Conflict"} 409' ] && [ "$AC3" = "$AA3" ] || die "anchor: the duplicate POST - 409 on A and on C, as before the change: ${AA3:-none} / ${AC3:-none}"
  AAG=$(printf '%s\n' "$A" | sed -n 's/^  -> the names: //p'); [ "$AAG" = 'Kavya Meera Priya Ravi Sunil' ] && [ "$(printf '%s\n' "$C" | sed -n 's/^  -> the names: //p')" = "$AAG" ] || die "anchor: the names after, A and C: $AAG"
  ver "$AE" 1 "anchor A's edit"; ver "$CE" 1 "anchor C's edit"
  has "$AE" '  PROBE before: the second connection reads Ravi · meals_per_day 2 · version 0' "anchor A: the seeded row's version 0 (the column's default)"
  printf '%s\n' "$AE" > .harness/b1; x=$(sqlb .harness/b1 'update customer'); ASE=$(printf '%s\n' "$x" | sed -n 2p); ASEB=$(printf '%s\n' "$x" | sed -n 3p)
  printf '%s\n' "$ASEB" | $G -qE ' · version=1 · where id=1 · where version=0$' || die "anchor A: the seeded edit's UPDATE binds version 1, where version 0: $ASEB"
  has "$AE" '  PROBE the edit returned' "anchor A: the seeded edit committed"; has "$AE" '  PROBE after: the second connection reads Ravi · meals_per_day 3 · version 1' "anchor A: Ravi 3, version 1"
  [ "$(printf '%s\n' "$A" | sed 's/2006[12]/<port>/g; s#\.harness/a[a-z0-9]*#.harness/<A>#g')" = "$(printf '%s\n' "$A2" | sed 's/2006[12]/<port>/g; s#\.harness/a[a-z0-9]*#.harness/<A>#g')" ] || die "anchor A': after/ built again prints what A printed (R.1)"
  has "$AN" "C - labelled: a nullable column - after/ with the column's NOT NULL DEFAULT 0 taken off (.harness/anc, built; its tests ran: run, failures, errors, skipped 18 0 0 0), port 20067:" "anchor C: labelled, its 18 tests passed (the tests did not notice)"
  has "$C" '  its one line: version       BIGINT' "anchor C: the one line"
  has "$CE" '  PROBE before: the second connection reads Ravi · meals_per_day 2 · version null' "anchor C: the seeded row's version null"
  ACX=$(printf '%s\n' "$CE" | sed -n 's/^  PROBE the edit threw: //p'); ACR=$(printf '%s\n' "$CE" | sed -n 's/^  PROBE caused by: //p' | paste -sd'|' -)
  [ "$ACX" = 'org.springframework.transaction.TransactionSystemException: Could not commit JPA transaction' ] || die "anchor C: the commit's failure: ${ACX:-none}"
  [ "$ACR" = 'jakarta.persistence.RollbackException: Error while committing the transaction [Cannot invoke "java.lang.Long.longValue()" because "current" is null]|java.lang.NullPointerException: Cannot invoke "java.lang.Long.longValue()" because "current" is null' ] || die "anchor C: the chain - RollbackException, then the NullPointerException: ${ACR:-none}"
  $G -q "${TXP}Initiating transaction commit$" <<< "$CE" || die "anchor C: it failed at the commit"
  has "$CE" '  PROBE after: the second connection reads Ravi · meals_per_day 2 · version null' "anchor C: Ravi unchanged"
  echo "  anchor: the change - CustomerEntity (@Version private Long version, getVersion()), Database (version BIGINT NOT NULL DEFAULT 0), the README; B (labelled, the entity alone): exit 1, $ABX (SQLState $ABS), the chain $ABCH; A: $AA2 · $AA3 · the seeded edit $ASE binds $ASEB, Ravi version 1; A' = A; C (labelled, nullable, 18 tests passed): ${AC2##* } · ${AC3##* } · the seeded edit: $ACX ← ${ACR//|/ ← }"; }
S466=466c20ed7e0d5439cb052f32ce09de1b
SQB=""; SQA=""; SVD=""
chk_seven() { local SV b a x
  SV=$(cat .r-seven.out); b=$(blk seven 'the seven - before' 'the seven - after'); a=$(blk seven 'the seven - after' '')
  [ "$(cnt "$SV" "  exit 0 · the seven responses: 7 lines · md5 $S466")" = 2 ] || die "seven: $S466 on both trees (a guard: the version is in no answer)"
  has "$SV" '  the seven, after/ against before/: lines that differ: 0' "seven: 0 lines differ"
  SQB=$(printf '%s\n' "$b" | sed -n -E 's/^  its log.s org\.hibernate\.SQL lines: ([0-9]+) in all - .* during the seven: ([0-9]+)$/\1 \2/p')
  SQA=$(printf '%s\n' "$a" | sed -n -E 's/^  its log.s org\.hibernate\.SQL lines: ([0-9]+) in all - .* during the seven: ([0-9]+)$/\1 \2/p')
  [ -n "$SQB" ] && [ "$SQB" = "$SQA" ] || die "seven: Hibernate's SQL lines the same count on both trees: $SQB / $SQA"
  [ "$(printf '%s\n' "$b" | sed -n '/the statements during the seven, each/,$p' | $G '^    [0-9]')" = "$(printf '%s\n' "$a" | sed -n '/the statements during the seven, each/,$p' | $G '^    [0-9]' | sed 's/,ce1_0\.version / /')" ] || die "seven: after/'s statements are before/'s with ce1_0.version read too, and nothing else"
  SVD=$(printf '%s\n' "$SV" | sed -n 's/^  > *[0-9]* x //p' | paste -sd'|' -)
  [ -n "$SVD" ] && ! printf '%s\n' "$SVD" | tr '|' '\n' | $G -qv ',ce1_0\.version from customer ce1_0' || die "seven: the statements that differ each read ce1_0.version: ${SVD:-none}"
  for x in "$b" "$a"; do has "$x" '  its log - Spring Data'"'"'s scan: Found 1 JPA repository interface. · HHH000001: HHH000001: Hibernate ORM core version 7.4.13.Final' "seven: Found 1"; done
  echo "  seven: $S466 on before/ and after/, 0 lines differ (a guard); Hibernate's SQL lines in the log ${SQB%% *}, during the seven ${SQB#* }, on both trees; after/'s that differ: $SVD"; }
XB=""; XAF=""; XDL=""
chk_xcheck() { local XC l
  XC=$(cat .r-xcheck.out)
  [ "$(cnt "$XC" "$VERH")" = 2 ] && [ "$(cnt "$XC" "  exit 0 · 'GenerationTarget encountered exception': 0")" = 2 ] && [ "$(cnt "$XC" '  INFO  [main] org.springframework.data.repository.config.RepositoryConfigurationDelegate : Finished Spring Data repository scanning in <n> ms. Found 0 JPA repository interfaces.')" = 2 ] || die "xcheck: two JVMs, the entities alone, no repository, a clean start each"
  XB=$(printf '%s\n' "$XC" | sed -n 's/^  before\/.s md5: \([0-9a-f]*\) · .* the same: yes$/\1/p'); XAF=$(printf '%s\n' "$XC" | sed -n "s/^  after\/'s md5: \([0-9a-f]*\) · the filed xcheck.sql: [0-9a-f]* · cmp: the same, byte for byte$/\1/p")
  [ "$XB" = "$X09" ] || die "xcheck: before/'s script must be the owning-side lesson's, md5 $X09 (R.212): ${XB:-none}"
  [ "$XAF" = "$X27" ] || die "xcheck: after/'s script must be the filed xcheck.sql, md5 $X27, byte for byte: ${XAF:-none}"
  [ "$(printf '%s\n' "$XC" | sed -n '/^the two scripts/,/^  the after/p' | $G -c '^  [<>] ')" = 2 ] && has "$XC" '  1c1' "xcheck: the two scripts differ in one line"
  has "$XC" "  the after/ line with ', version bigint not null' taken out = the before/ line: yes" "xcheck: the one line differs by version bigint not null alone"
  XDL='version bigint not null'
  [ "$(printf '%s\n' "$XC" | $G -c '^    create table \|^    alter table ')" = 6 ] || die "xcheck: two create table lines and one alter table, each script"
  echo "  xcheck: before/'s script $XB = the owning-side lesson's; after/'s $XAF = xcheck.sql; one line differs: $XDL"; }
chk_tests() { local TS l
  TS=$(cat .r-tests.out)
  for l in '    TEST-com.tiffinbox.web.TiffinBoxWebTest.xml: tests 14 · failures 0 · errors 0 · skipped 0' '    TEST-com.tiffinbox.web.FullStackTest.xml: tests 3 · failures 0 · errors 0 · skipped 0' '    TEST-com.tiffinbox.web.FeedTest.xml: tests 1 · failures 0 · errors 0 · skipped 0' \
      '    in all: 3 reports · tests 18 · failures 0 · errors 0 · skipped 0' "  Surefire's console summary (its Results line): tests 18 · failures 0 · errors 0 · skipped 0 · the reports' sum the same: yes" '  exit 0 · BUILD SUCCESS · offline: yes' \
      '    TiffinBoxWebTest.java: 1' '    FullStackTest.java: 1' '    FeedTest.java: 0'; do has "$TS" "$l" "tests"; done
  echo "  tests: 18 (14/3/1) from the reports, the console the same; the real CustomerRepository in FeedTest (TiffinBoxWebTest and FullStackTest mock it) - a guard (R.190; C7-4)"; }
EXQ="Your turn: the README edits Ravi twice at once, and one edit disappears without an error. Make the losing edit fail loudly."
EXW=$(printf '%s\n' "$EXQ" | wc -w | tr -d ' ')
EXBA=""; EXBR=""; EXSA=""; EXSR=""
chk_exercise() { local EB EZ b ER ES w l
  EB=$(blk exercise "in bash" "in zsh"); EZ=$(blk exercise "in zsh" "")
  for b in "$EB" "$EZ"; do
    ER=$(printf '%s\n' "$b" | sed '/then the solution/,$d'); ES=$(printf '%s\n' "$b" | sed -n '/then the solution/,$p')
    for l in '    the JVM: exit 0' '    PROBE edit B committed: mealsPerDay 7'; do has "$ER" "$l" "exercise: the README runs"; has "$ES" "$l" "exercise: the solution runs"; done
    EXBA=$(printf '%s\n' "$ER" | sed -n 's/^    PROBE edit A //p'); EXBR=$(printf '%s\n' "$ER" | sed -n 's/^    PROBE after both edits, its own JDBC connection reads: //p')
    [ "$EXBA" = 'committed: mealsPerDay 3' ] && [ "$EXBR" = 'Ravi mealsPerDay 3' ] || die "exercise: the README's run - both commit, Ravi 3, no error (S4.16): ${EXBA:-none} / ${EXBR:-none}"
    EXSA=$(printf '%s\n' "$ES" | sed -n 's/^    PROBE edit A //p'); EXSR=$(printf '%s\n' "$ES" | sed -n 's/^    PROBE after both edits, its own JDBC connection reads: //p')
    printf '%s\n' "$EXSA" | $G -qE "^threw: org\.springframework\.orm\.ObjectOptimisticLockingFailureException: Unexpected row count \(expected row count 1 but was 0\) \[update diner set .*version=\? where id=\? and version=\?\] for entity \[probe\.t\.ex\.Diner with id '1'\]$" && [ "$EXSR" = 'Ravi mealsPerDay 7' ] || die "exercise: the solution's end state - A threw, Ravi 7 (S4.16): ${EXSA:-none} / ${EXSR:-none}"
    has "$ES" '    [A] org.springframework.orm.jpa.JpaTransactionManager : Initiating transaction rollback after commit exception' "exercise solved: A's commit failed and rolled back"
    nhas "$ER" 'rollback' "exercise broken: nothing rolled back"
    [ "$EXBR" != "$EXSR" ] || die "exercise: broken and solved must differ - by the row, never only the exit code"
    [ "$(printf '%s\n' "$b" | $G -c "^  the shell is now in: this unit's folder")" = 2 ] || die "exercise: the shell back in this folder"; done
  [ "$(printf '%s\n' "$EB" | $G -v '^in ')" = "$(printf '%s\n' "$EZ" | $G -v '^in ')" ] || die "exercise: bash and zsh print the same"
  w=$(printf '%s\n' "$EB" | sed '/then the solution/,$d' | sed -n '/^  the block.s exit /,/^  the shell is now in: /p' | sed '1d;$d' | sed 's/^    //')
  [ "$(wib exercise/README.md)" = "$w" ] || die "exercise/README.md's \"What it prints\" block is not what the README's lines printed: $(diff <(wib exercise/README.md) <(printf '%s\n' "$w") | head -3 | paste -sd' ' -)"
  w=$(printf '%s\n' "$EB" | sed -n '/then the solution/,$p' | sed -n '/then the solution/,/^  the shell is now in: /p' | sed '1d;$d' | sed 's/^    //')
  [ "$(wib exercise/SOLUTION.md)" = "$w" ] || die "exercise/SOLUTION.md's \"What it prints\" block is not what the solution's lines printed: $(diff <(wib exercise/SOLUTION.md) <(printf '%s\n' "$w") | head -3 | paste -sd' ' -)"
  $G -qxF -- "**Your turn:** ${EXQ#Your turn: }" exercise/README.md || die "exercise/README.md: the spoken exercise line"
  [ "$EXW" -le 25 ] || die "exercise: the spoken line is at most 25 words (R.203): $EXW"
  $G -qxF '    private Long version;' harness/src/probe/t/ex/ExApp.java && ! $G -q '@Version' harness/src/probe/t/ex/ExApp.java || die "exercise: ExApp ships Diner's version field without @Version"
  echo "  exercise: bash and zsh alike - the README as written: A $EXBA, $EXBR; the solution (one line: @Version on the field): A $EXSA, $EXSR; each file's What it prints = the run; $EXW words"; }
cap version version; chk_version; pub version
cap race race; chk_race; pub race
cap merge merge; chk_merge; pub merge
cap modes modes; chk_modes; pub modes
cap anchor anchor; chk_anchor; pub anchor
cap seven seven7; chk_seven; pub seven
cap tests tests; chk_tests; pub tests
cap xcheck xcheck; chk_xcheck; pub xcheck
cap exercise exercise; chk_exercise; pub exercise

# the values the video says are the captures', never typed: README.md holds them, composed here from the checks' reads
VS="the values the video may say: on H2 2.5.250, Spring Framework 7.0.10, Spring Data JPA 4.1.2, Hibernate 7.4.13.Final - version: $INS binds $INSB; an edit: $UPD binds $UPDB; read back $RBK · race B (no version, 3/3): Ravi $RCB, both committed, no exception; A (@Version, 3/3): Ravi $RCA, A threw $RAX ← $RAC1 ← $RAC2 · merge: $MGX, updates sent $MGC · modes: OPTIMISTIC $MOO; OPTIMISTIC_FORCE_INCREMENT $MOF ($MOFB) · anchor B (the entity alone): exit 1, $ABX SQLState $ABS; A: ${AA2##* } · ${AA3##* }, the seeded edit binds $ASEB; C (nullable, 18 tests passed): $ACX ← ${ACR//|/ ← } · seven: $S466, SQL lines ${SQB%% *}, during the seven ${SQB#* }, both trees; the select lists read ce1_0.version · tests: 18 (14/3/1) · xcheck: $X09 -> $X27, the one line: $XDL · exercise: A $EXBA, $EXBR -> @Version: A threw, $EXSR ($EXW words)"
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
  ! $G -oE 'https?://[^ /]*' "$f" | $G -qvxE 'http://127\.0\.0\.1:2006[0-7]' || die "$f holds a URL (only TiffinBox's own loopback ports 20060-20067 may appear)"; done
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
echo "  ports: nothing listens on 18425, 8080, 35729 or 20060-20069 at the end - TiffinBox bound 20060-20062, 20064, 20065 and 20067 and stopped; 20063, 20066 and 20068 unused; 20069 never bound"
[ -z "$unpub" ] || die "no published hash for:$unpub - check the captures, then copy the md5s above into receipts.md5 and run again"
echo "c7-unit27: every capture 3/3 and = published; every spoken number asserted; 0 raw tokens; no port bound but 20060-20062, 20064, 20065, 20067"
