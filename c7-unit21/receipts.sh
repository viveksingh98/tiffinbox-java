#!/bin/bash
XPATH=$PATH                                           # the PATH you started this with: the exercise's own shells get it
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25.0.4.1 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# Course 7 · Query By Example and Querydsl - this unit's receipts. No change to the anchor (brief ⚑11): anchor/ is the link to
# ../c7-unit17/after, Section 3's frozen anchor. Query by Example asks with an object - a probe, the example object: Spring
# Data JPA 4.1 writes a where condition for every field of it that is not null, and an int left at zero is not null. Querydsl
# asks with typed paths its processor generates from the entity sources (QCustomerEntity). Five captures, each run three times
# and hashed; a hash that differs from receipts.md5 stops the run; every number and string the video says is asserted right
# after its capture by a check that can fail. One database: H2, in each JVM's memory, gone with it. No TiffinBox runs here.
#   probe     the trap, the failure receipt (three harness JVMs: B, A, A'): B Example.of(new CustomerEntity(null, 0, 0, VEG)) -
#             a where condition for the meal type AND the two int zeros, 0 rows; A the same probe with
#             withIgnorePaths("mealsPerDay", "pricePerMeal") - the meal type alone, Ravi and Sunil; A' A again
#   matcher   one harness JVM: a string matcher (withIgnoreCase().withStringMatcher(CONTAINING)) - lower(...) like ? escape;
#             matchingAny() against matching() on one probe - or against and, their two normal forms' md5s printed (RED #910);
#             count(Example); the fluent findBy(example, q -> q.sortBy(...).first()); the normalizer refusing a planted mixed line
#   querydsl  Querydsl's processor run by javac over the anchor's three entity sources (byte copies) with -proc:full
#             -processorpath naming its jars - the generated files counted by find, QCustomerEntity's fields read off it; the
#             control, the same jars on the class path alone - 0 generated; one harness JVM: where Querydsl's classes are loaded
#             from, three predicates through QuerydslPredicateExecutor, a count, a JPAQueryFactory query with any()
#   xcheck    the harness's DDL script (@EntityScan("com.tiffinbox") alone, scripts.action=create) against the owning-side
#             lesson's published md5: no mapping moved (R.212, brief ⚑3)
#   exercise  exercise/README.md's commands, then exercise/SOLUTION.md's, read from the files and run as written, in ONE env -i
#             shell - /bin/bash, then again in /bin/zsh -f; each file's "What it prints" block = what it printed
# Query by Example's SQL is captured in a NORMAL FORM (S3.6/R.237, RED #910): Spring Data writes its where terms in an order
# that changes from JVM to JVM, so each SQL line of probe and matcher is rewritten by .harness/qbe.awk - the terms of its where
# clause sorted under their connective, "where and: [t1, t2]" or "where or: [t1, t2]" (one term: "and: [t]"), the order by /
# fetch that follows kept as logged; a line mixing and with or is REFUSED (exit 1: it has no normal form); the raw line is kept
# out of the hash - printed to the terminal only, with its JVM - and its term set is asserted equal to the normal form's.
# The choose table (README.md) is composed from probe A, the Criteria lesson's spec capture (read off its README, its hash
# asserted) and querydsl: no capture of its own, no new claim.
# No anchor change: anchor/ is the link to ../c7-unit17/after. It equals ../c7-tiffinbox until a later unit changes the anchor -
# printed at the start and the end, a note then, never a stop (R.211). The anchor is COPIED under .harness/anchor and built
# there, never in place (its README's package line, offline; its tests run); its jar extracted (the anchor's own line).
# The harness (harness/src, packages probe.q and probe.x, outside com.tiffinbox) is compiled against the anchor's extracted
# libraries, Querydsl's run-time jars and the Q classes the processor wrote (.harness/qcls), with javac -parameters into
# .harness/hc. probe.q.Main is a Spring Boot context with no web server (WebApplicationType.NONE: it binds no port) over those,
# @EntityScan on com.tiffinbox - the anchor's entities - and @EnableJpaRepositories on probe.q.repo, the harness's own
# interface (Customers: JpaRepository - with Query by Example's methods - and QuerydslPredicateExecutor of CustomerEntity);
# probe.q.Seed builds the shipped Database in code on the run's own H2 database, which seeds it; Hibernate writes no schema
# (ddl-auto none), its statistics are on; Logback (harness/logback.xml) prints Hibernate's SQL logger, its HHH000001 line, the
# EntityManagerFactory's line and Spring Data's scan line. probe.x.XMain is xcheck's context (the entities alone). Each runs
# from .harness/run. Its JVM flags travel as an array, V, its arguments as an array, A (R.193). Every JVM this script starts -
# the harness's and the exercise's - runs under an alarm (perl -e 'alarm N; exec ...': macOS has no timeout); an alarm that
# fires is a failed receipt (R.247). Commands are printed exactly as they run: each goes through eval. harness/dur7.py (Course
# 7's builders' duration pattern, byte for byte) gates this unit's prose: it speaks no time (R.172). "$M2" is this unit's own
# repository, .m2-demo.
# The processor (S3.17/R.248, RED #901): harness/apt/pom.xml names querydsl-apt (jakarta) at Boot's ${querydsl.version} and the
# Jakarta Persistence API; Maven's dependency:build-classpath lists their jars from .m2-demo (offline), and javac gets them by
# name after -proc:full -processorpath ("$AP" on screen - every entry a .jar under $M2, no wildcard: a lib/* there is not
# expanded); harness/qd/pom.xml names querydsl-jpa (jakarta) the same way, and its list ("$QR") joins the class path. The
# generated files are counted by find -type f, never typed; a count other than the two Q sources stops the run.
# The locale: the JVM ignores LC_ALL on macOS - every JVM this script starts has its locale pinned on its run line (-Duser.language=en
# -Duser.country=US), and the checks refuse a java line without it.
# The network: every Maven build runs offline (-o) against .m2-demo and says so ("offline: yes"). A build that cannot resolve an
# artifact offline is run once more without -o and says so, naming the artifact the offline build missed and the repositories
# that answered the retry, by the ids and URL schemes its log names ("offline: no - ..."); it never names a repository the log
# does not. At run time nothing leaves the machine: every database is H2 in a JVM's memory, and no JVM here binds a port. This
# unit reads no version file: the section's dated sweep is the brief's (R.223; _research/spring-boot-metadata-2026-11-07.xml).
# Masks (README.md declares each; awk gsub only): this folder "…", the folder above it "…/..", home "~", your user name "<user>";
# " using Java <version>"; an identity hash "@…"; the JDK's proxy class number "$Proxy<n>"; an EntityManager's identity
# "SessionImpl(<n><open>)"; Spring Data's scan time "scanning in <n> ms"; H2's generated constraint and index names
# "CONSTRAINT_<n>", "CONSTRAINT_INDEX_<n>". A harness JVM's log is printed whole (every line it prints, trailing spaces dropped),
# Query by Example's SQL lines in their normal form (above).
# Ports (§P, 20000-20009): this unit binds none. All ten, and 18425 (TiffinBox's default), 8080 and 35729, are checked free at the
# start and the end; 20009 is the one the brief names "never bound".
# bash 5.2 and later turn an & in the replacement of ${x/pattern/replacement} into the matched text (patsub_replacement, on by
# default). Switched off, so /bin/bash 3.2 (./receipts.sh) and a newer bash (bash receipts.sh) run the same commands.
shopt -u patsub_replacement 2> /dev/null || true
export LC_ALL=C
cd "$(dirname "$0")"
mkdir .r-lock 2> /dev/null || { echo "  *** another receipts.sh is running in this folder (.r-lock exists) - if none is, rmdir .r-lock ***"; exit 1; }
U="$PWD"; UP="$(cd .. && pwd)"; ME="$(id -un)"; G=/usr/bin/grep
# On every exit - the end, a failed check, or Ctrl-C - stop what this script started in the background, if it still runs: $pid (a
# JVM), $mpid (a Maven or a javac, with every process under it), $xpid (an exercise shell, with every process under it); then
# sweep(): anything of this run still alive in its process group - a harness JVM, a javac, a Maven - is stopped. After an
# interrupt a capture's unfinished runs (.r-NAME.1-3) go too; after a failed check they stay. The clean-up ignores a second
# Ctrl-C, and the script still exits 130 after an interrupt (README.md, "Interrupted"). No wait in this script is bare.
pid=""; mpid=""; xpid=""
sweep() { local g i l
  g=$(ps -o pgid= -p $$ 2> /dev/null | tr -d ' ') || g=""
  [ -n "$g" ] || return 0
  i=0; while [ $i -lt 20 ]; do
    l=$(ps -axo pid=,pgid=,command= 2> /dev/null | awk -v g="$g" -v me=$$ '
      $2 == g && $1 != me && $3 != "awk" && $3 != "ps" && (index($0, "probe.q.") || index($0, "probe.x.") || $3 ~ /(^|\/)javac$/ || index($0, "jdk.compiler/com.sun.tools.javac") || index($0, "org.codehaus.plexus.classworlds.launcher.Launcher")) { print $1 }' | paste -sd' ' -) || l=""
    [ -n "$l" ] || return 0
    if [ $i -lt 10 ]; then kill $l 2> /dev/null || true; else kill -9 $l 2> /dev/null || true; fi
    sleep 0.5; i=$((i + 1)); done; }
desc() { ps -axo pid=,ppid= 2> /dev/null | awk -v r="$1" '{ p[$1] = $2 } END { n = 1; q[1] = r; for (i = 1; i <= n; i++) for (c in p) if (p[c] == q[i]) { q[++n] = c; print c } }'; }
killtree() { local d; d=$(desc "$1"); kill "$1" $d 2> /dev/null || true; }
trap 'trap "" INT TERM; for p in "$mpid" "$xpid"; do [ -z "$p" ] || killtree "$p"; done; for p in "$pid" "$mpid" "$xpid"; do if [ -n "$p" ] && kill "$p" 2> /dev/null; then wait "$p" 2> /dev/null || true; fi; done; sweep || true; [ -z "$INTR" ] || rm -f .r-*.[123]; rmdir .r-lock 2> /dev/null || true' EXIT
INTR=""; trap 'INTR=1; exit 130' INT TERM
exec 3>&1                                            # die() speaks to the terminal even inside a redirected capture
die() { echo "  *** $* ***" >&3; exit 1; }
java -version 2>&1 | $G -q 'version "25' || die "JDK 25 needed; JAVA_HOME gives: $(java -version 2>&1 | head -1)"
javac -version 2>&1 | $G -q '^javac 25' || die "javac 25 needed (the harness and the Q classes are compiled with it)"
for t in python3 perl rsync lsof mvn md5 cmp javap find /bin/zsh; do command -v $t > /dev/null || die "$t is needed"; done
# A variable of yours must not become a property source, a JVM flag or a build setting (the problem-detail lesson's loop: a canary
# planted under every name first, and the run stops if one survives).
for v in TIFFINBOX_CANARY SPRING_CANARY MANAGEMENT_CANARY SERVER_CANARY LOGGING_CANARY PROBE_CANARY DEBUG JAVA_TOOL_OPTIONS JDK_JAVA_OPTIONS _JAVA_OPTIONS MAVEN_ARGS; do export "$v=planted-canary"; done
for v in $(env | sed -n -E 's/^(TIFFINBOX_[A-Za-z0-9_]*|SPRING_[A-Za-z0-9_]*|MANAGEMENT_[A-Za-z0-9_]*|SERVER_[A-Za-z0-9_]*|LOGGING_[A-Za-z0-9_]*|PROBE_[A-Za-z0-9_]*|DEBUG|JAVA_TOOL_OPTIONS|JDK_JAVA_OPTIONS|_JAVA_OPTIONS|MAVEN_ARGS)=.*/\1/p'); do unset "$v"; done
[ -z "$(env | $G -- '=planted-canary$')" ] || die "a variable survived the clean-up above: $(env | $G -- '=planted-canary$' | sed 's/=.*//' | paste -sd' ' -)"
[ -e secrets ] && die "this folder holds a secrets/ - nothing here needs one"
# No anchor change (brief ⚑11): anchor/ is the link to ../c7-unit17/after - Section 3's frozen anchor. It equals ../c7-tiffinbox
# until a later unit changes the anchor - a note then, never a stop (R.211, the Course 6 form)
[ -L anchor ] && [ "$(readlink anchor)" = ../c7-unit17/after ] || die "anchor must be the link to ../c7-unit17/after - Section 3's frozen anchor; this unit changes nothing in it"
[ -f anchor/pom.xml ] && [ -f anchor/README.md ] || die "the anchor (its pom.xml or README.md) is missing"
[ -e anchor/secrets ] || [ -e anchor/target ] || [ -e anchor/tiffinbox-web/target ] || [ -e anchor/tiffinbox-core/target ] || [ -e anchor/tiffinbox-local.yaml ] || [ -e anchor/hibernate-ddl.sql ] && die "anchor/ holds a secrets/, a target/, a tiffinbox-local.yaml or a hibernate-ddl.sql - it is a frozen copy, never built in place"
[ -d ../c7-tiffinbox ] || die "../c7-tiffinbox is missing"
anchornote() { local d; d=$(diff -rq -x .m2-demo -x target -x secrets -x .harness anchor/ ../c7-tiffinbox 2>&1 || true)
  if [ -z "$d" ]; then echo "  the anchor ($1): anchor/ = ../c7-unit17/after (frozen); diff -rq -x .m2-demo -x target -x secrets -x .harness anchor/ ../c7-tiffinbox: empty - no anchor change in this unit"
  else echo "  (anchor/ and ../c7-tiffinbox differ - the anchor has moved past the tree this unit reads: $(printf '%s\n' "$d" | head -3 | paste -sd';' -))" >&3
    echo "  the anchor ($1): anchor/ = ../c7-unit17/after (frozen) - no anchor change in this unit"; fi; }
anchornote start
M2="$PWD/.m2-demo"
CJ=tiffinbox-core/src/main/java/com/tiffinbox        # the core module's sources, in a tree
XD=tiffinbox-web/target/extracted                    # the jar, extracted (the anchor's own line), in a tree
HS=harness/src/probe/q
ENTS='CustomerEntity.java MealType.java PauseEntity.java'   # the anchor's entity sources the processor reads (byte copies)
HFILES='apt dur7.py logback.xml qd src'
SFILES='probe/q/Main.java probe/q/Run.java probe/q/Seed.java probe/q/ex/ExApp.java probe/q/repo/Customers.java probe/x/XMain.java'
for f in exercise/README.md exercise/SOLUTION.md README.md receipts.md5 harness/apt/pom.xml harness/qd/pom.xml; do [ -f "$f" ] || die "$f is missing"; done
[ "$(ls harness | paste -sd' ' -)" = "$HFILES" ] && [ "$(cd harness/src && find . -type f | sed 's#^\./##' | sort | paste -sd' ' -)" = "$SFILES" ] && [ "$(ls harness/apt | paste -sd' ' -)" = pom.xml ] && [ "$(ls harness/qd | paste -sd' ' -)" = pom.xml ] || die "harness/ holds another file, or misses one"
[ "$(ls exercise | paste -sd' ' -)" = 'README.md SOLUTION.md' ] || die "exercise/ holds another file"
[ "$(md5 -q harness/dur7.py)" = 41667fed9ffcefe171389eed7e654e66 ] || die "harness/dur7.py is not the builders' dur7.py (md5 41667fed…)"
if [ -f ../../../data-jpa-hibernate/_builders/dur7.py ]; then cmp -s harness/dur7.py ../../../data-jpa-hibernate/_builders/dur7.py || die "harness/dur7.py differs from the builders' ../../../data-jpa-hibernate/_builders/dur7.py"
  echo "  (terminal only) harness/dur7.py = the builders' _builders/dur7.py, byte for byte" >&3
else echo "  (terminal only) the builders' _builders/dur7.py is not beside this clone: its md5 above is the check" >&3; fi
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
PORTS="18425 8080 35729 20000 20001 20002 20003 20004 20005 20006 20007 20008 20009"
for p in $PORTS; do
  [ "$(listeners $p)" = 0 ] || die "something already listens on $p - this unit's ports must be free; if it is a process an interrupted run left behind, stop it: kill $(lsof -nP -iTCP:$p -sTCP:LISTEN -t 2> /dev/null | paste -sd' ' -)"; done
rm -rf .harness; mkdir -p .harness/run .harness/hc

# ---- the prose gates: no duration word (R.172); English names only (R.215); the placeholders unit 16 shipped; typed values -----
cat > .harness/dur.py <<'PY'
import importlib.util, sys
spec = importlib.util.spec_from_file_location("dur7", sys.argv[1]); m = importlib.util.module_from_spec(spec); spec.loader.exec_module(m)
n = 0
for f in sys.argv[2:]:
    for i, l in enumerate(open(f, encoding="utf-8"), 1):
        for w in m.DUR.finditer(l):
            n += 1
            print("  %s line %d: %s  <- not allowed: this unit speaks no time" % (f, i, w.group(0)))
print("duration words: %d" % n)
PY
DW=$(python3 -I -B .harness/dur.py harness/dur7.py README.md exercise/README.md exercise/SOLUTION.md) || die "dur7's gate did not run"
printf '%s\n' "$DW" | tail -1 | $G -qxF 'duration words: 0' || die "dur7.DUR found a duration word - this unit speaks no time (R.172): $(printf '%s\n' "$DW" | $G 'not allowed' | paste -sd';' -)"
echo "  duration words: 0 (dur7.DUR over README.md, exercise/README.md, exercise/SOLUTION.md) - this unit speaks no time"
# R.215: meals and dishes have English names here - the AI voice mispronounces Indian dish names (the course's memory rule); the
# list is refused, whole words, any case, in this unit's prose, its harness and (at the end) every capture
DISH='thali|khichdi|dal|daal|paneer|biryani|roti|chapati|chapatti|naan|sabzi|sabji|idli|dosa|sambar|rasam|rajma|chole|chana|poha|upma|paratha|pulao|pulav|raita|korma|tikka|masala|samosa|pakora|pakoda|halwa|kheer|jalebi|ladoo|laddu|vada|bhaji|aloo|gobi|jain'
dishes() { $G -rniwE -- "$DISH" "$@" 2> /dev/null | cut -c1-160 | head -3 | paste -sd';' - || true; }
DN=$(dishes README.md exercise harness/src)
[ -z "$DN" ] || die "an Indian dish name (R.215: English names only): $DN"
echo "  dish names: 0 ($(printf '%s\n' "$DISH" | tr '|' '\n' | wc -l | tr -d ' ') refused, whole words, any case, over README.md, exercise/, harness/src)"
# the exercise's "What it prints" blocks hold what the run printed (exercise checks it, line for line) - never a placeholder (unit
# 16 shipped EXERCISE-README-OUTPUT and EXERCISE-SOLUTION-OUTPUT under such a heading), never an empty block
PH=$($G -rnE 'EXERCISE-[A-Z-]*OUTPUT|[A-Z]+-OUTPUT\b|[A-Z]+-PARAGRAPH\b|TODO|TBD|PLACEHOLDER' README.md exercise 2> /dev/null | cut -c1-160 | head -3 | paste -sd';' - || true)
[ -z "$PH" ] || die "a placeholder line in this unit's prose - the exercise's blocks hold the measured output: $PH"
# wib FILE: the fenced block under the file's "What it prints" line
wib() { awk '/^What it prints/ { w = 1; next } w == 1 && /^```$/ { w = 2; next } w == 2 && /^```$/ { exit } w == 2 { print }' "$1"; }
for f in exercise/README.md exercise/SOLUTION.md; do [ "$($G -c '^What it prints' "$f")" = 1 ] && [ -n "$(wib "$f" | $G -v '^ *$' || true)" ] || die "$f must hold one \"What it prints\" line and, under it, a block that is not empty"; done
echo "  placeholders: 0 · each exercise file's \"What it prints\" block not empty (exercise compares it with the run, line for line)"
# S3.10 (R.241): an exception is read off the log as its class with its package - never typed from memory; the 3.x name of
# Spring Data's property exception is not in spring-data-commons-4.1.2.jar, and no version is credited with it (RED #931)
OLDP='org\.springframework\.data\.mapping\.PropertyReferenceException'
OP=$($G -rnE -- "$OLDP" README.md exercise harness/src 2> /dev/null | cut -c1-160 | head -3 | paste -sd';' - || true)
[ -z "$OP" ] || die "a line names the exception by the package it does not have on Spring Data JPA 4.1.2 - S3.10 (R.241): $OP"
echo "  S3.10's refused class name: 0 lines over README.md, exercise/, harness/src"
# R.225, S3.17 (RED #902): the number of files the processor writes is querydsl's find count, stated once, in the values line
# this script composes - a count of generated, Q or source files typed anywhere else in the prose is refused
NUMW='one|two|three|four|five|six|seven|eight|nine|ten|eleven|twelve|thirteen|fourteen|fifteen|[0-9]+'
TG=$($G -niE "\\b($NUMW) (generated( files| sources| classes)?|(Q|metamodel|query|source) (files|classes|sources)|files (generated|written))\\b" README.md exercise/README.md exercise/SOLUTION.md 2> /dev/null | $G -vF 'the values the video may say:' | cut -c1-160 | head -3 | paste -sd';' - || true)
[ -z "$TG" ] || die "a typed count of the processor's files - querydsl counts them by find, and only the values line states them (R.225, S3.17): $TG"
echo "  typed generated-file counts: 0 (querydsl's find count is in the values line only)"
# R.225, R.227: a SQL string this unit shows is the logger's, composed into README.md's choose table and its values line by this
# script - a line of README.md holding Hibernate's alias (ce1_0.) anywhere else is a typed SQL string, refused
TS=$($G -nF 'ce1_0.' README.md 2> /dev/null | $G -vE '^[0-9]+:\| (Query by Example|Specification|Querydsl) \| `' | $G -vF 'the values the video may say:' | cut -c1-160 | head -3 | paste -sd';' - || true)
[ -z "$TS" ] || die "a typed SQL string in README.md outside the choose table and the values line (R.225, R.227): $TS"
echo "  typed SQL strings: 0 in README.md outside its composed table and values line"
# S3.6: the order of Query by Example's terms is not this unit's to say - a line that claims a fixed order is refused
QO=$($G -niE '(always|every time|each time) (writes|puts|lists|orders)[^.]{0,60}(terms|conditions|predicates)|(terms|conditions|predicates) (always|in a fixed order|in the same order)' README.md exercise/README.md exercise/SOLUTION.md 2> /dev/null | cut -c1-160 | head -3 | paste -sd';' - || true)
[ -z "$QO" ] || die "a line claims Query by Example writes its terms in a fixed order - measured: the order changes between JVMs (S3.6): $QO"
echo "  a fixed-order claim for Query by Example's terms: 0 lines"

# ---- the commands: read from anchor/README.md, the anchor's own, and asserted - each line must be there, whole -------------
readme() { $G -m1 -xF -- "$1" anchor/README.md > /dev/null || die "anchor/README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
R_PLAIN=$(readme 'mvn -B package')
R_EXTRACT=$(readme 'java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted')
# This unit's own lines (README.md, "The commands this unit adds") - each asserted to be exactly that
mine() { $G -m1 -xF -- "$1" README.md > /dev/null || die "README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
JL='-Duser.language=en -Duser.country=US'
AL="perl -e 'alarm 240; exec @ARGV'"
EL=".harness/ents/CustomerEntity.java .harness/ents/MealType.java .harness/ents/PauseEntity.java"
L_APT=$(mine 'cd .harness/apt && mvn -o -B -Dmaven.repo.local="$M2" dependency:build-classpath -Dmdep.outputFile=cp.txt')
L_QD=$(mine 'cd .harness/qd && mvn -o -B -Dmaven.repo.local="$M2" dependency:build-classpath -Dmdep.outputFile=cp.txt')
L_Q=$(mine "javac -proc:full -processorpath \"\$AP\" -cp \".harness/anchor/$XD/lib/*:\$QR\" -s .harness/qsrc -d .harness/qcls $EL")
L_CTL=$(mine "javac -cp \".harness/anchor/$XD/lib/*:\$QR:\$AP\" -s .harness/ctl/src -d .harness/ctl/cls $EL")
L_JAVAC=$(mine "javac -parameters -d .harness/hc -cp \".harness/anchor/$XD/lib/*:\$QR:.harness/qcls\" $HS/Main.java $HS/Run.java $HS/Seed.java $HS/repo/Customers.java harness/src/probe/x/XMain.java")
L_H=$(mine "$AL java $JL -Dstdout.encoding=UTF-8 \"\${V[@]}\" -cp \"../hc:../qcls:\$QR:../anchor/$XD/lib/*\" probe.q.Main \"\${A[@]}\"")
L_X=$(mine "$AL java $JL -Dstdout.encoding=UTF-8 -cp \"../hc:../anchor/$XD/lib/*\" probe.x.XMain \"\${A[@]}\"")
off() { local c=${2/mvn -B /mvn -o -B -Dmaven.repo.local=\"\$M2\" }
  [ -n "${3:-}" ] && c=${c/ $3/ clean $3}
  printf 'cd %s && %s\n' "$1" "$c"; }
exe() { printf '%s\n' "$1" | sed -E 's/&& (([A-Z_]+=[^ ]* )*)/\&\& \1exec /'; }
[ "$(off .harness/anchor "$R_PLAIN" package)" = 'cd .harness/anchor && mvn -o -B -Dmaven.repo.local="$M2" clean package' ] || die "off(): the build line is not the anchor README's package line, offline"
case "$L_CTL" in *processorpath*|*-proc:*) die "the control's javac line must name no processor flag - the processor on the class path alone (S3.17)" ;; esac
echo "  the commands: anchor/README.md gives the $($G -c '^R_[A-Z]*=$(readme ' receipts.sh) lines this script runs; README.md the $($G -c '^L_[A-Z0-9]*=$(mine ' receipts.sh) this unit adds"
JV=$(java -version 2>&1 | sed -n 's/.*version "\([^"]*\)".*/\1/p' | head -1)
echo "  (terminal only) the JDK is $JV - the captures say Java <version>" >&3

# ---- build: before the captures - the anchor copied and built with its README's package line offline (its tests run); its jar
# ---- extracted (the anchor's line); Querydsl's two class paths resolved by Maven; the Q classes; the harness ----------------
# mbuild COMMAND LOG WHAT: offline first. If the offline build fails for want of an artifact, its log is kept beside (LOG with
# -offline), the first artifact it names is read from it, and the build runs once more without -o; the label then names that
# artifact and every repository the retry's log says it downloaded from - id, URL scheme, count - and counts the downloads whose
# URL is http(s). It never says "Maven Central" unless the log does.
mbuild() { local how=yes ec=0 c=$1 miss got web
  (eval "$c") > "$2" 2>&1 < /dev/null & mpid=$!; wait "$mpid" || ec=$?; mpid=""
  if [ $ec != 0 ] && $G -qE 'offline mode|Could not resolve|could not be resolved|Cannot access|No plugin found for prefix' "$2"; then
    cp "$2" "${2%.log}-offline.log"
    miss=$($G -oE 'the artifact [^ ]+ has not been downloaded' "$2" | head -1 | sed -E 's/^the artifact ([^ ]+) has not been downloaded$/\1/')
    [ -n "$miss" ] || miss=$($G -oE 'Could not find artifact [^ ]+|No plugin found for prefix [^ ]+|Non-resolvable parent POM for [^ ]+' "$2" | head -1)
    ec=0; (eval "${c/mvn -o -B /mvn -B }") > "$2" 2>&1 < /dev/null & mpid=$!; wait "$mpid" || ec=$?; mpid=""
    got=$(sed -n -E 's/^\[INFO\] Downloaded from ([^ :]+): ([a-z]+):.*/\1 (\2)/p' "$2" | sort | uniq -c | awk '{ printf "%s%s %s %d", (NR > 1 ? ", " : ""), $2, $3, $1 }')
    web=$($G -cE '^\[INFO\] Downloaded from [^ ]+: https?://' "$2" || true)
    how="no - the offline build could not resolve ${miss:-an artifact (none named in its log)} from .m2-demo, so it ran once more without -o; that run downloaded from: ${got:-nothing}; of them over http(s): $web"; fi
  [ $ec = 0 ] || { tail -30 "$2" >&3
    ! $G -qE 'Could not resolve|could not be resolved|Could not transfer|Cannot access' "$2" || die "build failed: $3 - Maven could resolve Boot's parent and plugins neither from .m2-demo nor from a repository it could reach: a fresh clone's first run needs .m2-demo seeded (README.md, The repository)"
    die "build failed: $3"; }
  echo "  built $3 · offline: $how · exit $ec · 'Downloaded from' lines in its log: $($G -c '^\[INFO\] Downloaded from ' "$2" || true)"; }
# jc COMMAND LOG: a javac, in the background like a build (its pid in mpid: an interrupt stops it), its exit code in JE
JE=""
jc() { local ec=0; (eval "$1") > "$2" 2>&1 < /dev/null & mpid=$!; wait "$mpid" || ec=$?; mpid=""; JE=$ec; }
rsync -a --exclude target --exclude secrets --exclude .m2-demo anchor/ .harness/anchor/
rsync -a --exclude target --exclude secrets --exclude .m2-demo anchor/ .harness/anchor/
mbuild "$(off .harness/anchor "$R_PLAIN" package)" .harness/build-anchor.log ".harness/anchor (anchor/, its README's package line; its tests ran)"
(cd .harness/anchor && eval "$R_EXTRACT") > .harness/extract.log 2>&1 < /dev/null || die "the extract failed: $(tail -3 .harness/extract.log)"
for a in org/springframework/boot/spring-boot-starter-parent/4.1.2/spring-boot-starter-parent-4.1.2.pom org/hibernate/orm/hibernate-core/7.4.13.Final/hibernate-core-7.4.13.Final.jar org/springframework/data/spring-data-jpa/4.1.2/spring-data-jpa-4.1.2.jar com/h2database/h2/2.5.250/h2-2.5.250.jar com/querydsl/querydsl-apt/5.1.0/querydsl-apt-5.1.0-jakarta.jar com/querydsl/querydsl-jpa/5.1.0/querydsl-jpa-5.1.0-jakarta.jar; do
  [ -e "$M2/$a" ] || die "$a is not in .m2-demo - README.md, The repository"; done
# cpl NAME LIST: a class path Maven listed - every entry a jar under .m2-demo, named one by one (no wildcard), each one there
M2RE=$(printf '%s' "$M2" | sed 's/[][\.*^$/]/\\&/g')
cpl() { local n; n=$(printf '%s\n' "$2" | tr ':' '\n' | $G -c . || true)
  [ "$n" -gt 0 ] && [ -z "$(printf '%s\n' "$2" | tr ':' '\n' | $G -vE "^$M2RE/.+\\.jar$" || true)" ] || die "$1 must be jars under .m2-demo, named one by one (no wildcard): $(printf '%s\n' "$2" | cut -c1-200)"
  printf '%s\n' "$2" | tr ':' '\n' > ".harness/$1.lines"
  while IFS= read -r f; do [ -f "$f" ] || die "$1 names a jar that is not there: $f"; done < ".harness/$1.lines"; }
# Querydsl's processor path and its run-time jars: each POM copied, Maven's list of its jars (offline)
mkdir -p .harness/apt .harness/qd; cp harness/apt/pom.xml .harness/apt/pom.xml; cp harness/qd/pom.xml .harness/qd/pom.xml
mbuild "$L_APT" .harness/build-apt.log ".harness/apt (harness/apt/pom.xml: Querydsl's processor path, dependency:build-classpath)"
mbuild "$L_QD" .harness/build-qd.log ".harness/qd (harness/qd/pom.xml: Querydsl's run-time jars, dependency:build-classpath)"
AP=$(cat .harness/apt/cp.txt); QR=$(cat .harness/qd/cp.txt)
cpl ap "$AP"; cpl qr "$QR"
$G -qE '/querydsl-apt-[0-9.]+-jakarta\.jar$' .harness/ap.lines && $G -qE '/jakarta\.persistence-api-3\.2\.0\.jar$' .harness/ap.lines || die "the processor path must hold querydsl-apt (jakarta) and jakarta.persistence-api-3.2.0.jar, each by name (Step 11: without the API the processor cannot load jakarta.persistence.Entity)"
$G -qE '/querydsl-jpa-[0-9.]+-jakarta\.jar$' .harness/qr.lines && $G -qE '/querydsl-core-[0-9.]+\.jar$' .harness/qr.lines || die "Querydsl's run-time jars must hold querydsl-jpa (jakarta) and querydsl-core"
APN=$($G -c . .harness/ap.lines); QRN=$($G -c . .harness/qr.lines)
# the anchor's entity sources, byte copies - each md5 asserted equal to the frozen tree's (⚑11)
mkdir -p .harness/ents
for f in $ENTS; do cp "anchor/$CJ/$f" .harness/ents/; [ "$(md5 -q ".harness/ents/$f")" = "$(md5 -q "anchor/$CJ/$f")" ] || die ".harness/ents/$f is not the anchor's, byte for byte"; done
# the Q classes the harness compiles against - the processor run as querydsl runs it; its files counted by find (the S3.17 check)
mkdir -p .harness/qsrc .harness/qcls
jc "$L_Q" .harness/q-build.log
[ "$JE" = 0 ] || die "the Q classes' javac failed (exit $JE): $(head -5 .harness/q-build.log)"
QSN=$(find .harness/qsrc -type f | wc -l | tr -d ' ')
[ "$QSN" -gt 0 ] && [ -f .harness/qsrc/com/tiffinbox/QCustomerEntity.java ] && [ -f .harness/qsrc/com/tiffinbox/QPauseEntity.java ] || die "the generated files: $QSN (find .harness/qsrc -type f) - the processor never ran, and QCustomerEntity was not written (S3.17/R.248: on the class path alone JDK 25 runs no processor)"
[ "$(cd .harness/qsrc && find . -type f | sed 's#^\./##' | sort | paste -sd' ' -)" = 'com/tiffinbox/QCustomerEntity.java com/tiffinbox/QPauseEntity.java' ] || die "the generated files must be QCustomerEntity.java and QPauseEntity.java alone: $(cd .harness/qsrc && find . -type f | paste -sd' ' -)"
# the line itself, after the count (the count is the check that can fail - R.226; the line's shape a second guard)
case "$L_Q" in *' -proc:full -processorpath "$AP" '*) ;; *) die "the Q classes' javac line must name -proc:full and -processorpath (S3.17/R.248): $L_Q" ;; esac
# the harness runs against the anchor's own entity classes (its jar): the processor's copies of them are dropped, its Q* kept
for f in $ENTS; do rm -f ".harness/qcls/com/tiffinbox/${f%.java}.class"; done
[ "$(cd .harness/qcls && find . -type f | sed 's#^\./##' | sort | paste -sd' ' -)" = 'com/tiffinbox/QCustomerEntity.class com/tiffinbox/QPauseEntity.class' ] || die ".harness/qcls must hold the two Q classes alone"
jc "$L_JAVAC" .harness/javac.log
[ "$JE" = 0 ] || die "the harness did not compile: $(head -5 .harness/javac.log)"
[ ! -e .harness/hc/probe/q/ex ] || die "the exercise's class was compiled into the harness - it is compiled on its own"
echo "  extracted the anchor's jar ($(ls .harness/anchor/$XD/lib | wc -l | tr -d ' ') libraries); the processor path: $APN jars; Querydsl's run-time jars: $QRN; the Q classes written ($QSN files) and kept; the harness compiled into .harness/hc"
# ---- helpers ------------------------------------------------------------------------------------------------------------
LOGS=0; GENW=0
genw() { local n; n=$($G -c 'GenerationTarget encountered exception' "$1" || true); GENW=$((GENW + n)); }
mask() { awk -v u="$U" -v up="$UP" -v hm="$HOME" -v me="$ME" '
  function lit(x) { gsub(/[][\\.^$*+?(){}|\/]/, "\\\\&", x); return x }
  function enc(x) { gsub(/ /, "%20", x); return x }
  BEGIN { P = lit(u); Q = lit(up); H = lit(hm); PE = lit(enc(u)); QE = lit(enc(up)); M = "(^|[^A-Za-z0-9_])" lit(me) "([^A-Za-z0-9_]|$)" }
  { gsub(P, "…"); gsub(PE, "…"); gsub(Q, "…/.."); gsub(QE, "…/.."); gsub(H, "~")
    gsub(/ using Java [0-9][0-9.]+/, " using Java <version>")
    gsub(/\$Proxy[0-9]+/, "$Proxy<n>")
    gsub(/SessionImpl\([0-9]+<open>\)/, "SessionImpl(<n><open>)")
    gsub(/repository scanning in [0-9]+ ms\./, "repository scanning in <n> ms.")
    gsub(/CONSTRAINT_INDEX_[0-9A-F]+/, "CONSTRAINT_INDEX_<n>"); gsub(/CONSTRAINT_[0-9A-F]+ /, "CONSTRAINT_<n> ")
    gsub(/@[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]+/, "@…")
    while (match($0, M)) { pre = substr($0, 1, RSTART - 1); s = substr($0, RSTART, RLENGTH); post = substr($0, RSTART + RLENGTH)
      sub(lit(me), "<user>", s); $0 = pre s post }
    print }'; }
printf '%s\n' 'Starting XMain using Java 25.0.4.1' "$U/x" "$UP/y" "$HOME/z" 'org.h2.jdbc.JdbcConnection@1a2b3c4d' 'class: jdk.proxy2.$Proxy128' 'EntityManager [SessionImpl(1895617509<open>)]' 'Finished Spring Data repository scanning in 25 ms. Found 1 JPA repository interface.' '"PUBLIC.CONSTRAINT_52 INDEX PUBLIC.CONSTRAINT_INDEX_5 ON PUBLIC.CUSTOMER' > .harness/p1
[ "$(mask < .harness/p1)" = "$(printf '%s\n' 'Starting XMain using Java <version>' '…/x' '…/../y' '~/z' 'org.h2.jdbc.JdbcConnection@…' 'class: jdk.proxy2.$Proxy<n>' 'EntityManager [SessionImpl(<n><open>)]' 'Finished Spring Data repository scanning in <n> ms. Found 1 JPA repository interface.' '"PUBLIC.CONSTRAINT_<n> INDEX PUBLIC.CONSTRAINT_INDEX_<n> ON PUBLIC.CUSTOMER')" ] || die "mask: the planted JDK version, folders, home, identity hash, proxy number, EntityManager identity, scan time and H2's generated names must be masked"
rm -f .harness/p1
# the harness's arguments: this run's own H2 database (in this JVM's memory, kept while the context lives), the harness's
# Logback file, no schema written, no banner, the anchor's Thymeleaf jar not looking for templates, Hibernate's statistics on
HA=('--spring.datasource.url=jdbc:h2:mem:u21;DB_CLOSE_DELAY=-1' --logging.config=../../harness/logback.xml --spring.jpa.hibernate.ddl-auto=none --spring.main.banner-mode=off --spring.thymeleaf.check-template-location=false --spring.jpa.properties.hibernate.generate_statistics=true)
# hrun: the harness line (V, A set by the caller; HL the line - L_H, or L_X for xcheck), run from .harness/run; it exits by
# itself (its alarm: 240 s); its exit code in HE; its log .harness/h.log
HE=""
hrun() { local c i=0 e=0
  c=$(printf 'cd .harness/run && %s\n' "${HL:-$L_H}")
  [ "${HL:-$L_H}" = "$L_X" ] || echo "\$ V=($(printf '%s ' "${V[@]}" | sed 's/ $//'))"
  echo "\$ A=($(printf '%q ' "${A[@]}" | sed 's/ $//'))"; echo "\$ $c"
  (eval "$(exe "$c")") > .harness/h.log 2>&1 < /dev/null & pid=$!
  while kill -0 "$pid" 2> /dev/null && [ $i -lt 1000 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$pid" 2> /dev/null && { kill "$pid"; die "the harness run was still running after 250 s - its alarm should have stopped it"; }
  wait "$pid" || e=$?; pid=""; HE=$e; LOGS=$((LOGS + 1)); genw .harness/h.log
  [ "$HE" != 142 ] || die "the harness JVM's alarm fired (exit 142) - a run that does not end by itself is a failed receipt (R.247)"; }
# hview: the harness's whole log (PROBE lines, the named loggers' lines), trailing spaces dropped; then its exit code
hview() { sed -E 's/[[:space:]]+$//; s/^/  /' .harness/h.log; echo "  exit $HE · 'GenerationTarget encountered exception': $($G -c 'GenerationTarget encountered exception' .harness/h.log || true)"; }
unpub=""
# cap NAME FUNCTION: three runs, masked, compared; the capture's checks run next; pub NAME then compares it with receipts.md5
cap() { local nm=$1 i; shift
  for i in 1 2 3; do "$@" > .harness/cap.raw 2>&1 || true; [ -z "$pid$mpid$xpid" ] || die "$nm left a process running"
    mask < .harness/cap.raw > ".r-$nm.$i"; done
  CH=$(md5 -q ".r-$nm.1")
  [ "$CH" = "$(md5 -q ".r-$nm.2")" ] && [ "$CH" = "$(md5 -q ".r-$nm.3")" ] || die "$nm drifts across three runs (diff .r-$nm.1 .r-$nm.2 .r-$nm.3)"
  mv ".r-$nm.1" ".r-$nm.out"; rm -f ".r-$nm.2" ".r-$nm.3"; }
pub() { local nm=$1 h pub; h=$(md5 -q ".r-$nm.out")
  pub=$(awk -v n="$nm" '$1 == n { print $2 }' receipts.md5 2> /dev/null || true)
  if [ -z "$pub" ]; then printf '  %-9s md5 %s  3/3  (no published hash)\n' "$nm" "$h"; unpub="$unpub $nm"
  elif [ "$pub" = "$h" ]; then printf '  %-9s md5 %s  3/3  = published\n' "$nm" "$h"
  else printf '  %-9s md5 %s  3/3  DIFFERS from the published %s\n' "$nm" "$h" "$pub"
    die "$nm is not the published capture - suspect another JDK, Boot or Maven, a busy machine, a variable of yours, or an edited source; diff .r-$nm.out against its block in README.md"; fi; }

# ---- Query by Example's normal form (S3.6/R.237, RED #910) ---------------------------------------------------------------
# .harness/qbe.awk RAW: every SQL logger line with a where clause is rewritten - its where terms (split on its one connective,
# " and " or " or ") sorted, written "where and: [t1, t2]" / "where or: [t1, t2]" (one term: "and: [t]"), what follows the
# where clause (" order by ", " fetch first ", " offset ") kept as logged; the next line says how many terms the raw line had,
# its connective, and whether its term set equals the normal form's (each read again from the two texts). The raw line itself
# goes to the file RAW, never to the capture. A line with both " and " and " or " in its where clause has no normal form: it is
# REFUSED, and the awk exits 1.
cat > .harness/qbe.awk <<'AWK'
function srt(a, n,   i, j, t) { for (i = 2; i <= n; i++) { t = a[i]; for (j = i - 1; j >= 1 && a[j] > t; j--) a[j + 1] = a[j]; a[j + 1] = t } }
function cut(s,   k, m, x) { m = 0; split(" order by | fetch first | offset ", x, "|"); for (k = 1; k <= 3; k++) { if (index(s, x[k]) && (m == 0 || index(s, x[k]) < m)) m = index(s, x[k]) } return m }
/^DEBUG org\.hibernate\.SQL : / && index($0, " where ") {
  sql = substr($0, 27); print sql > raw
  i = index(sql, " where "); head = substr(sql, 1, i - 1); rest = substr(sql, i + 7)
  m = cut(rest); if (m) { body = substr(rest, 1, m - 1); tail = substr(rest, m) } else { body = rest; tail = "" }
  ha = index(body, " and ") > 0; ho = index(body, " or ") > 0
  if (ha && ho) { print "REFUSED: a Query by Example line mixing and with or has no normal form (S3.6): " sql; bad = 1; next }
  c = ho ? "or" : "and"; n = split(body, t, " " c " "); srt(t, n)
  nf = t[1]; for (k = 2; k <= n; k++) nf = nf ", " t[k]
  print "DEBUG org.hibernate.SQL (normal form, S3.6) : " head " where " c ": [" nf "]" tail
  # the set, read again: the raw terms sorted on their own, against the normal form's list split back
  n2 = split(body, u, " " c " "); srt(u, n2); s1 = u[1]; for (k = 2; k <= n2; k++) s1 = s1 "|" u[k]
  n3 = split(nf, v, ", "); s2 = v[1]; for (k = 2; k <= n3; k++) s2 = s2 "|" v[k]
  print "QBE the raw line: " n2 " term" (n2 == 1 ? "" : "s") ", " (n2 == 1 ? "no connective" : "joined by " c) " · its term set = the normal form's: " (s1 == s2 && n2 == n3 ? "yes" : "no")
  next }
{ print }
END { exit bad }
AWK
# the self-test, before any capture: a planted two-order pair must give one normal form; a planted mixed line must be refused
printf '%s\n' 'DEBUG org.hibernate.SQL : select x from customer ce1_0 where ce1_0.b=? and ce1_0.a=? order by ce1_0.name fetch first ? rows only' > .harness/p1
printf '%s\n' 'DEBUG org.hibernate.SQL : select x from customer ce1_0 where ce1_0.a=? and ce1_0.b=? order by ce1_0.name fetch first ? rows only' > .harness/p2
[ "$(awk -v raw=/dev/null -f .harness/qbe.awk .harness/p1)" = "$(awk -v raw=/dev/null -f .harness/qbe.awk .harness/p2)" ] && [ "$(awk -v raw=/dev/null -f .harness/qbe.awk .harness/p1 | head -1)" = 'DEBUG org.hibernate.SQL (normal form, S3.6) : select x from customer ce1_0 where and: [ce1_0.a=?, ce1_0.b=?] order by ce1_0.name fetch first ? rows only' ] || die "qbe.awk: two orders of one where clause must give one normal form"
printf '%s\n' 'DEBUG org.hibernate.SQL : select x from customer ce1_0 where ce1_0.b=? or ce1_0.a=?' > .harness/p1
[ "$(awk -v raw=/dev/null -f .harness/qbe.awk .harness/p1 | head -1)" = 'DEBUG org.hibernate.SQL (normal form, S3.6) : select x from customer ce1_0 where or: [ce1_0.a=?, ce1_0.b=?]' ] || die "qbe.awk: an or line keeps its connective (RED #910)"
MIXL='DEBUG org.hibernate.SQL : select ce1_0.id from customer ce1_0 where ce1_0.meal_type=? and ce1_0.meals_per_day=? or ce1_0.name=?'
printf '%s\n' "$MIXL" > .harness/p1
QE=0; awk -v raw=/dev/null -f .harness/qbe.awk .harness/p1 > .harness/p2 || QE=$?
[ "$QE" = 1 ] && $G -q '^REFUSED: ' .harness/p2 || die "qbe.awk: a line mixing and with or must be REFUSED, exit 1 (S3.6): exit $QE"
rm -f .harness/p1 .harness/p2
echo "  qbe.awk: two orders of one where clause give one normal form; and and or keep their connectives; a mixed line is REFUSED, exit 1"
# hviewq: hview, Query by Example's SQL in its normal form; the raw lines to the terminal only, with the JVM's label (RE-MEASURE 9)
RAWN=0
hviewq() { local e=0
  : > .harness/raw.log
  awk -v raw=.harness/raw.log -f .harness/qbe.awk .harness/h.log > .harness/hq.log || e=$?
  [ "$e" = 0 ] || die "$1: a Query by Example line the normal form refuses (S3.6): $($G '^REFUSED: ' .harness/hq.log | head -1)"
  sed -E 's/[[:space:]]+$//; s/^/  /' .harness/hq.log; echo "  exit $HE · 'GenerationTarget encountered exception': $($G -c 'GenerationTarget encountered exception' .harness/h.log || true)"
  RAWN=$((RAWN + 1))
  while IFS= read -r l; do echo "  (terminal only, never hashed) $1, JVM $RAWN, raw: $l" >&3; printf '%s\t%s\n' "$1" "$l" >> .harness/raw-all.log; done < .harness/raw.log
  rm -f .harness/raw.log; }

# ---- probe: the trap - B the probe as constructed (the failure receipt), A and A' the two ints ignored ---------------------
probe() { echo "B - Example.of(new CustomerEntity(null, 0, 0, VEG)): the probe as the constructor makes it - the failure receipt (one harness JVM, .harness/hc):"
  V=(-Ds=probe -Dv=B); A=("${HA[@]}"); hrun; hviewq "probe B"
  echo "A - the same probe, ExampleMatcher.matching().withIgnorePaths(\"mealsPerDay\", \"pricePerMeal\") (one harness JVM):"
  V=(-Ds=probe -Dv=A); A=("${HA[@]}"); hrun; hviewq "probe A"
  echo "A' - A again, in a fresh JVM:"
  V=(-Ds=probe -Dv=A); A=("${HA[@]}"); hrun; hviewq "probe A'"; }

# ---- matcher: a string matcher, matchingAny against matching, count, the fluent query; the normalizer's refusal -----------
matcher() { local o a
  echo "the matchers - one harness JVM (.harness/hc):"
  V=(-Ds=matcher); A=("${HA[@]}"); hrun; hviewq matcher
  o=$(sed -n 's/^DEBUG org\.hibernate\.SQL (normal form, S3\.6) : .* where \(or: \[.*\]\)$/\1/p' .harness/hq.log | head -1)
  a=$(sed -n 's/^DEBUG org\.hibernate\.SQL (normal form, S3\.6) : .* where \(and: \[ce1_0\.meal_type=?, ce1_0\.name=?\]\)$/\1/p' .harness/hq.log | head -1)
  echo "the two normal forms of one probe (Meera, VEG; the two ints ignored) - matchingAny()'s where: ${o:-none} · md5 $(printf '%s' "$o" | md5 -q) · matching()'s where: ${a:-none} · md5 $(printf '%s' "$a" | md5 -q) · they differ: $( [ -n "$o" ] && [ -n "$a" ] && [ "$(printf '%s' "$o" | md5 -q)" != "$(printf '%s' "$a" | md5 -q)" ] && echo yes || echo no)"
  printf '%s\n' "$MIXL" > .harness/mix.log
  echo "the normal form, fed a planted line that mixes and with or (it is no Query by Example line - written here, never logged):"
  echo "  $MIXL"
  local e=0; awk -v raw=/dev/null -f .harness/qbe.awk .harness/mix.log > .harness/mix.out || e=$?
  sed 's/^/  /' .harness/mix.out; echo "  qbe.awk's exit $e"; }

# ---- querydsl: the processor (and its control), the generated class, three predicates, a count, any() ----------------------
# gen DIR: the files the processor wrote under DIR, counted and named by find -type f (R.226: a count that can fail)
gen() { echo "  \$ find ${1#.harness/} -type f | wc -l: $(find "$1" -type f 2> /dev/null | wc -l | tr -d ' ')"
  [ ! -d "$1" ] || (cd "$1" && find . -type f | sed 's#^\./#    #' | sort); }
querydsl() { echo "the processor - Querydsl's apt over the anchor's entity sources (byte copies in .harness/ents, each md5 = the anchor's):"
  for f in $ENTS; do echo "  .harness/ents/$f · md5 $(md5 -q ".harness/ents/$f") · the anchor's: $( [ "$(md5 -q ".harness/ents/$f")" = "$(md5 -q "anchor/$CJ/$f")" ] && echo the same || echo DIFFERENT)"; done
  echo "  AP: the processor path, Maven's list - $APN jars, each named: $(sed 's#.*/##' .harness/ap.lines | paste -sd' ' -)"
  echo "  QR: Querydsl's run-time jars, Maven's list - $QRN jars, each named: $(sed 's#.*/##' .harness/qr.lines | paste -sd' ' -)"
  rm -rf .harness/q-run; mkdir -p .harness/q-run/qsrc .harness/q-run/qcls
  echo "\$ ${L_Q//.harness\/q/.harness/q-run/q}"
  jc "${L_Q//.harness\/q/.harness/q-run/q}" .harness/q-run.log
  echo "  exit $JE · what javac printed: $($G -c . .harness/q-run.log || true) lines"; sed 's/^/    /' .harness/q-run.log
  echo "  the generated sources (the -s folder) - every file:"; gen .harness/q-run/qsrc
  echo "  each the same as the build's: $(diff -r .harness/qsrc .harness/q-run/qsrc > /dev/null 2>&1 && echo yes || echo no)"
  echo "  QCustomerEntity.java's lines naming the class and its fields (\$ grep -nE '^public class |^    public final ' ...):"
  $G -nE '^public class |^    public final ' .harness/q-run/qsrc/com/tiffinbox/QCustomerEntity.java 2> /dev/null | sed -E 's/^([0-9]+):[[:space:]]*/    \1: /'
  echo "the control - the same jars on the class path alone, no processor flag:"
  rm -rf .harness/ctl; mkdir -p .harness/ctl/src .harness/ctl/cls
  echo "\$ $L_CTL"; jc "$L_CTL" .harness/ctl.log
  echo "  exit $JE · what javac printed: $($G -c . .harness/ctl.log || true) lines"; gen .harness/ctl/src
  echo "  the classes it compiled: $(cd .harness/ctl/cls && find . -type f | sed 's#^\./##' | sort | paste -sd' ' -)"
  echo "the queries - one harness JVM (.harness/hc, the Q classes the build's processor wrote in .harness/qcls):"
  V=(-Ds=querydsl); A=("${HA[@]}"); hrun; hview; }

# ---- xcheck: the harness's DDL for the anchor's two entities against Boot's, as the owning-side lesson captured it --------------
X09=f595637014e786fa38606859951e4f97                # Boot's script for CustomerEntity + PauseEntity, as ../c7-unit09's xcheck captured it (R.212)
X09CAP=9072c6f11c8c8e713c997b58d3a79d74             # ../c7-unit09's published xcheck capture
[ "$($G -c "$X09" ../c7-unit09/README.md || true)" -gt 0 ] || die "../c7-unit09/README.md must name $X09 - Boot's script md5 (R.212)"
[ "$(awk '$1 == "xcheck" { print $2 }' ../c7-unit09/receipts.md5)" = "$X09CAP" ] || die "../c7-unit09/receipts.md5's xcheck is not $X09CAP - the capture that holds Boot's script"
XA=('--spring.datasource.url=jdbc:h2:mem:x21;DB_CLOSE_DELAY=-1' --logging.config=../../harness/logback.xml --spring.jpa.hibernate.ddl-auto=none --spring.main.banner-mode=off --spring.thymeleaf.check-template-location=false --spring.jpa.properties.jakarta.persistence.schema-generation.scripts.action=create --spring.jpa.properties.jakarta.persistence.schema-generation.scripts.create-target=hibernate-ddl.sql)
xcheck() {
  echo "the harness's DDL - probe.x.XMain (@EntityScan(\"com.tiffinbox\") alone, no repository, no seed), scripts.action=create (a file, never run):"
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
# R.222 and S3.15 (R.246): a version-shaped claim prints its versions in the same capture - Hibernate's own HHH000001 line, the
# harness's getVersionString() line, and Spring Data JPA's version from its jar's manifest - once per harness JVM, never typed
VERL='  PROBE Hibernate ORM core version (org.hibernate.Version.getVersionString()): 7.4.13.Final'
VERH='  INFO  org.hibernate.orm.core : HHH000001: Hibernate ORM core version 7.4.13.Final'
VERD='  PROBE Spring Data JPA version (JpaRepository.class.getPackage().getImplementationVersion()): 4.1.2'
DBL='  PROBE database: H2 2.5.250 (2026-08-29) | url jdbc:h2:mem:u21;DB_CLOSE_DELAY=-1'
SEEDL='  PROBE seeded by the shipped Database (createAndSeed); read by a second connection - customer (id | name | meal_type | meals_per_day | price_per_meal): [1 | Ravi | VEG | 2 | 120, 2 | Meera | NON_VEG | 1 | 150, 3 | Sunil | VEG | 3 | 100, 4 | Priya | VEGAN | 1 | 120]'
PAUL='  PROBE pause (id | customer | days), read the same way: [1 | Sunil | 3, 2 | Priya | 2]'
FOUND1='  INFO  org.springframework.data.repository.config.RepositoryConfigurationDelegate : Finished Spring Data repository scanning in <n> ms. Found 1 JPA repository interface.'
ver() { local c; c=$(cat ".r-$1.out")
  [ "$(cnt "$c" "$VERL")" = "$2" ] && [ "$(cnt "$c" "$VERH")" = "$2" ] && [ "$(cnt "$c" "$VERD")" = "$2" ] || die "$1: the version lines - getVersionString(), Hibernate's HHH000001 and Spring Data JPA's 4.1.2 - once in each of its $2 harness JVMs (R.222, S3.15/R.246)"
  [ "$(cnt "$c" "$DBL")" = "$2" ] && [ "$(cnt "$c" "$SEEDL")" = "$2" ] && [ "$(cnt "$c" "$FOUND1")" = "$2" ] && [ "$(cnt "$c" "$PAUL")" = "$2" ] || die "$1: the database: line, H2 2.5.250, the shipped seed and Spring Data's Found 1, in each of its $2 harness JVMs (R.217: this unit speaks for H2 only)"
  [ "$(cnt "$c" "  exit 0 · 'GenerationTarget encountered exception': 0")" = "$2" ] || die "$1: each of its $2 harness JVMs ends by itself, exit 0 (a call failure is not a start failure, S3.9)"; }
# R.184: a statement count has two witnesses from one call - the SQL logger's lines between ">>> label" and "<<< label", and
# Hibernate's Statistics for that call (getPrepareStatementCount, printed on the "<<<" line)
call() { printf '%s\n' "$1" | awk -v a="  PROBE >>> $2" -v b="  PROBE <<< $2 · " 'index($0, a) == 1 && length($0) == length(a) { f = 1 } f { print } f && index($0, b) == 1 { f = 0 }'; }
# sqll: the SQL lines of a block - as logged, or (probe, matcher) in Query by Example's normal form
sqll() { printf '%s\n' "$1" | $G -E '^  DEBUG org\.hibernate\.SQL( \(normal form, S3\.6\))? : ' | sed -E 's/^  DEBUG org\.hibernate\.SQL( \(normal form, S3\.6\))? : //' || true; }
qraw() { printf '%s\n' "$1" | sed -n 's/^  QBE the raw line: //p'; }
two() { local b n p; b=$(call "$1" "$2"); [ -n "$b" ] || die "$4: no call named $2"
  n=$(sqll "$b" | $G -c . || true); p=$(printf '%s\n' "$b" | sed -n 's/^  PROBE <<< .* · statements (getPrepareStatementCount) \([0-9]*\) · .*/\1/p')
  [ "$n" = "$3" ] && [ "$p" = "$3" ] || die "$4: $3 statements - the SQL log's lines ($n) and getPrepareStatementCount() (${p:-none}) both (R.184)"; }
res() { printf '%s\n' "$1" | sed -n 's/^  PROBE result: //p'; }
thr() { printf '%s\n' "$1" | sed -n 's/^  PROBE threw: //p'; }
SELC='select ce1_0.id,ce1_0.meal_type,ce1_0.meals_per_day,ce1_0.name,ce1_0.price_per_meal from customer ce1_0'
# wh SQL: the SQL from its from-clause's alias on - "customer ce1_0" and what follows it (the where clause, an order by, a page)
wh() { printf '%s\n' "$1" | sed 's/^.* from customer ce1_0//; s/^ //'; }
PIL='  PROBE the probe: new CustomerEntity(null, 0, 0, VEG) · its fields: id null · name null · mealsPerDay 0 · pricePerMeal 0 · mealType VEG · pauses []'
PBW=""; PBN=""; PBR=""; PAW=""; PAR=""; PAS=""
chk_probe() { local B A1 A2 l s q x
  ver probe 3
  B=$(blk probe 'B - ' 'A - '); A1=$(blk probe 'A - ' "A' - "); A2=$(blk probe "A' - " '')
  for x in "$B" "$A1" "$A2"; do has "$x" "$PIL" "probe: the probe's fields, as the constructor set them"; done
  # B: the probe as constructed - a term for the meal type and one for each int left at zero; 0 rows (the hook, S3.6's normal form)
  l='findAll(Example.of(probe))'; two "$B" "$l" 1 "probe B"
  s=$(sqll "$(call "$B" "$l")"); case "$s" in "$SELC where and: ["*"]") ;; *) die "probe B: one SELECT of the entity's five columns, its where clause in the normal form: $s" ;; esac
  PBW=$(wh "$s"); PBN=$(printf '%s\n' "$PBW" | sed -n 's/^where and: \[\(.*\)\]$/\1/p' | awk -F', ' '{ print NF }')
  [ "$PBW" = 'where and: [ce1_0.meal_type=?, ce1_0.meals_per_day=?, ce1_0.price_per_meal=?]' ] || die "probe B: the two int zeros are values - the meal type's term and one for each int, under and (the hook): $PBW"
  q=$(qraw "$(call "$B" "$l")"); [ "$q" = "$PBN terms, joined by and · its term set = the normal form's: yes" ] || die "probe B: the raw line's terms - $PBN, joined by and, the same set as the normal form's (S3.6): $q"
  # the null name, the null id and the empty pauses add nothing: no term names them, no join (said as the terms printed)
  case "$PBW" in *name*|*ce1_0.id*|*pause*|*join*) die "probe B: the null name, null id and empty pauses add no term: $PBW" ;; esac
  PBR=$(res "$(call "$B" "$l")"); [ "$PBR" = '0 rows · names, sorted by the harness: []' ] || die "probe B: 0 rows - no customer has 0 meals a day at 0 a meal (the failure receipt): $PBR"
  # A and A': the two ints ignored - the meal type's term alone, Ravi and Sunil, in two fresh JVMs
  l='findAll(Example.of(probe, ExampleMatcher.matching().withIgnorePaths("mealsPerDay", "pricePerMeal")))'
  for x in "$A1" "$A2"; do two "$x" "$l" 1 "probe A/A'"
    [ "$(sqll "$(call "$x" "$l")")" = "$SELC where and: [ce1_0.meal_type=?]" ] || die "probe A/A': withIgnorePaths - the meal type's term alone: $(sqll "$(call "$x" "$l")")"
    [ "$(qraw "$(call "$x" "$l")")" = '1 term, no connective · its term set = the normal form'"'"'s: yes' ] || die "probe A/A': the raw line - one term"
    has "$x" '  PROBE result: 2 rows · names, sorted by the harness: [Ravi, Sunil]' "probe A/A': the vegetarian customers"; done
  [ "$(printf '%s\n' "$A1" | sed 1d)" = "$(printf '%s\n' "$A2" | sed 1d)" ] || die "probe A': A again prints what A printed (R.1)"
  PAS=$(sqll "$(call "$A1" "$l")"); PAW=$(wh "$PAS"); PAR=$(res "$(call "$A1" "$l")")
  echo "  probe: B Example.of(new CustomerEntity(null, 0, 0, VEG)) - $PBW ($PBN terms), $PBR; A and A' withIgnorePaths(\"mealsPerDay\", \"pricePerMeal\") - $PAW, $PAR; the null name, id and pauses add no term; Spring Data JPA 4.1.2 in each JVM"; }
MCW=""; MESC=""; MCR=""; MOW=""; MOR=""; MOH=""; MAW=""; MAR=""; MAH=""; MCS=""; MCN=""; MFS=""; MFR=""
chk_matcher() { local M l s
  M=$(cat .r-matcher.out); ver matcher 1
  l='findAll(Example.of(new CustomerEntity("R", 0, 0, null), ints.withIgnoreCase().withStringMatcher(CONTAINING)))'; two "$M" "$l" 1 "matcher containing"
  s=$(sqll "$(call "$M" "$l")"); MCW=$(wh "$s")
  [ "$s" = "$SELC $MCW" ] && case "$MCW" in "where and: [lower(ce1_0.name) like ? escape '"*"']") true ;; *) false ;; esac || die "matcher: CONTAINING with withIgnoreCase - lower(ce1_0.name) like ?, one term: $s"
  MESC=$(printf '%s\n' "$MCW" | $G -oE "escape '[^']*'" || true); [ "$MESC" = "escape '\\'" ] || die "matcher: the escape character, read off the log - Spring Data's like writes escape '\\' (R.227): ${MESC:-none}"
  MCR=$(res "$(call "$M" "$l")"); [ "$MCR" = '3 rows · names, sorted by the harness: [Meera, Priya, Ravi]' ] || die "matcher containing: an r in the name, any case: $MCR"
  # matchingAny against matching, one probe - or against and, and two different hashes (RED #910)
  l='findAll(Example.of(new CustomerEntity("Meera", 0, 0, VEG), ExampleMatcher.matchingAny().withIgnorePaths("mealsPerDay", "pricePerMeal")))'; two "$M" "$l" 1 "matcher matchingAny"
  MOW=$(wh "$(sqll "$(call "$M" "$l")")"); MOR=$(res "$(call "$M" "$l")")
  [ "$MOW" = 'where or: [ce1_0.meal_type=?, ce1_0.name=?]' ] || die "matcher: matchingAny() - the two terms under or (RED #910): $MOW"
  [ "$(qraw "$(call "$M" "$l")")" = '2 terms, joined by or · its term set = the normal form'"'"'s: yes' ] || die "matcher matchingAny: the raw line - two terms joined by or"
  [ "$MOR" = '3 rows · names, sorted by the harness: [Meera, Ravi, Sunil]' ] || die "matcher matchingAny: Meera or a vegetarian: $MOR"
  l='findAll(Example.of(new CustomerEntity("Meera", 0, 0, VEG), ExampleMatcher.matching().withIgnorePaths("mealsPerDay", "pricePerMeal")))'; two "$M" "$l" 1 "matcher matching"
  MAW=$(wh "$(sqll "$(call "$M" "$l")")"); MAR=$(res "$(call "$M" "$l")")
  [ "$MAW" = 'where and: [ce1_0.meal_type=?, ce1_0.name=?]' ] && [ "$MAR" = '0 rows · names, sorted by the harness: []' ] || die "matcher: matching() on the same probe - the same terms under and, 0 rows (Meera is not vegetarian): $MAW · $MAR"
  MOH=$(printf '%s' "${MOW#where }" | md5 -q); MAH=$(printf '%s' "${MAW#where }" | md5 -q)
  [ "$MOH" != "$MAH" ] || die "matcher: the or form and the and form must hash differently (RED #910)"
  has "$M" "the two normal forms of one probe (Meera, VEG; the two ints ignored) - matchingAny()'s where: ${MOW#where } · md5 $MOH · matching()'s where: ${MAW#where } · md5 $MAH · they differ: yes" "matcher: the two normal forms' md5s, printed in the capture (RED #910)"
  l='count(Example.of(new CustomerEntity(null, 0, 0, VEG), ints))'; two "$M" "$l" 1 "matcher count"
  MCS=$(sqll "$(call "$M" "$l")"); MCN=$(res "$(call "$M" "$l")")
  [ "$MCS" = "select count(ce1_0.id) from customer ce1_0 $PAW" ] && [ "$MCN" = 2 ] || die "matcher: count(Example) - a count of the ids, probe A's where clause, 2: $MCS · $MCN"
  l='findBy(Example.of(new CustomerEntity(null, 0, 0, VEG), ints), q -> q.sortBy(Sort.by("name")).first())'; two "$M" "$l" 1 "matcher findBy"
  MFS=$(sqll "$(call "$M" "$l")"); MFR=$(res "$(call "$M" "$l")")
  [ "$MFS" = "$SELC $PAW order by ce1_0.name fetch first ? rows only" ] && [ "$MFR" = 'Optional[Ravi]' ] || die "matcher: the fluent findBy - order by the name (unique, S3.7), fetch first ? rows only, Ravi: $MFS · $MFR"
  has "$M" "  REFUSED: a Query by Example line mixing and with or has no normal form (S3.6): ${MIXL#DEBUG org.hibernate.SQL : }" "matcher: the planted mixed line is refused"
  has "$M" "  qbe.awk's exit 1" "matcher: the refusal exits 1"
  echo "  matcher: CONTAINING + withIgnoreCase - $MCW, $MCR; matchingAny() - $MOW ($MOH), $MOR; matching() - $MAW ($MAH), $MAR; count(Example) $MCN; findBy(...first()) - order by ce1_0.name fetch first ? rows only, $MFR; a mixed line REFUSED, exit 1"; }
QGN=""; QDV=""; QF=""; QCTL=""; QP1=""; QP2=""; QS1=""; QR1=""; QS2=""; QR2=""; QESC=""; QS3=""; QN3=""; QS4=""; QR4=""; QW1=""
chk_querydsl() { local Q P C H l v
  Q=$(cat .r-querydsl.out); ver querydsl 1
  P=$(blk querydsl 'the processor - ' 'the control - '); C=$(blk querydsl 'the control - ' 'the queries - '); H=$(blk querydsl 'the queries - ' '')
  for f in $ENTS; do printf '%s\n' "$P" | $G -qE "^  \\.harness/ents/$f · md5 [0-9a-f]{32} · the anchor's: the same$" || die "querydsl: .harness/ents/$f must be the anchor's byte for byte (⚑11)"; done
  # the version: read off the jars' names Maven listed - the apt, the core, the jpa jar must agree (never typed)
  QDV=$(printf '%s\n' "$P" | sed -n -E 's/^  AP: .* querydsl-apt-([0-9][0-9.]*)-jakarta\.jar .*/\1/p')
  v=$(printf '%s\n' "$P" | sed -n -E 's/^  QR: .*each named: querydsl-jpa-([0-9][0-9.]*)-jakarta\.jar querydsl-core-([0-9][0-9.]*)\.jar .*/\1 \2/p')
  [ -n "$QDV" ] && [ "$v" = "$QDV $QDV" ] || die "querydsl: the version, read off the jars Maven listed - querydsl-apt, querydsl-jpa and querydsl-core alike: ${QDV:-none} / ${v:-none}"
  printf '%s\n' "$P" | $G -qE '^  AP: .* jakarta\.persistence-api-3\.2\.0\.jar( |$)' || die "querydsl: the processor path names jakarta.persistence-api-3.2.0.jar (Step 11)"
  # S3.17 (R.248), RED #901: the generated files - counted by find in this capture, never typed; the control's 0 beside them
  has "$P" '  exit 0 · what javac printed: 0 lines' "querydsl: the processor's javac - exit 0, silent"
  QGN=$(printf '%s\n' "$P" | sed -n -E 's/^  \$ find q-run\/qsrc -type f \| wc -l: ([0-9]+)$/\1/p')
  [ -n "$QGN" ] && [ "$QGN" -gt 0 ] || die "querydsl: the generated files (find q-run/qsrc -type f): ${QGN:-none} - the processor never ran (S3.17/R.248)"
  [ "$(printf '%s\n' "$P" | $G -cE '^    com/tiffinbox/Q[A-Za-z]+\.java$')" = "$QGN" ] || die "querydsl: every generated file is a Q source, named by find"
  for l in '    com/tiffinbox/QCustomerEntity.java' '    com/tiffinbox/QPauseEntity.java' '  each the same as the build'"'"'s: yes'; do has "$P" "$l" "querydsl: QCustomerEntity and QPauseEntity, the same as the build's"; done
  printf '%s\n' "$P" | $G -qE '^    [0-9]+: public class QCustomerEntity extends EntityPathBase<CustomerEntity> \{$' || die "querydsl: QCustomerEntity extends EntityPathBase<CustomerEntity>"
  # QCustomerEntity's fields, read off the generated file (type and name) - the six the brief names must be among them
  QF=$(printf '%s\n' "$P" | sed -n -E 's/^    [0-9]+: public final (.*[^ ]) = .*$/\1/p')
  for l in 'NumberPath<Long> id' 'NumberPath<Integer> mealsPerDay' 'EnumPath<MealType> mealType' 'StringPath name' 'ListPath<PauseEntity, QPauseEntity> pauses' 'NumberPath<Integer> pricePerMeal'; do
    printf '%s\n' "$QF" | $G -qxF -- "$l" || die "querydsl: QCustomerEntity.java has no field $l - read off the generated file: $(printf '%s\n' "$QF" | paste -sd';' -)"; done
  QCTL=$(printf '%s\n' "$C" | sed -n -E 's/^  \$ find ctl\/src -type f \| wc -l: ([0-9]+)$/\1/p')
  has "$C" '  exit 0 · what javac printed: 0 lines' "querydsl: the control - javac exit 0, silent"
  [ "$QCTL" = 0 ] || die "querydsl: the control - the processor on the class path alone writes nothing (S3.17, RED #901): $QCTL"
  has "$C" '  the classes it compiled: com/tiffinbox/CustomerEntity.class com/tiffinbox/MealType.class com/tiffinbox/PauseEntity.class' "querydsl: the control compiles the entities alone - no QCustomerEntity"
  # provenance: where the class loader found Querydsl's classes (the jars, never typed)
  QP1=$(printf '%s\n' "$H" | sed -n -E 's#^  PROBE EntityPathBase is loaded from: …/\.m2-demo/com/querydsl/querydsl-core/[0-9.]+/([^/]+\.jar)$#\1#p')
  QP2=$(printf '%s\n' "$H" | sed -n -E 's#^  PROBE JPAQueryFactory is loaded from: …/\.m2-demo/com/querydsl/querydsl-jpa/[0-9.]+/([^/]+\.jar)$#\1#p')
  [ "$QP1" = "querydsl-core-$QDV.jar" ] && [ "$QP2" = "querydsl-jpa-$QDV-jakarta.jar" ] || die "querydsl: the provenance lines - EntityPathBase from querydsl-core, JPAQueryFactory from querydsl-jpa (jakarta), both in .m2-demo: ${QP1:-none} · ${QP2:-none}"
  has "$H" '  PROBE QCustomerEntity is loaded from: …/.harness/qcls/ · its superclass: com.querydsl.core.types.dsl.EntityPathBase' "querydsl: QCustomerEntity from the processor's output"
  l='findAll(c.mealType.eq(VEG).and(c.mealsPerDay.goe(2)))'; two "$H" "$l" 1 "querydsl and"
  QS1=$(sqll "$(call "$H" "$l")"); QR1=$(res "$(call "$H" "$l")"); QW1=$(wh "$QS1")
  [ "$QS1" = "$SELC where ce1_0.meal_type=? and ce1_0.meals_per_day>=?" ] && [ "$QR1" = '2 rows · names, sorted by the harness: [Ravi, Sunil]' ] || die "querydsl: eq and goe - where ce1_0.meal_type=? and ce1_0.meals_per_day>=?, [Ravi, Sunil]: $QS1 · $QR1"
  l='findAll(c.name.containsIgnoreCase("r"), Sort.by("name"))'; two "$H" "$l" 1 "querydsl containsIgnoreCase"
  QS2=$(sqll "$(call "$H" "$l")"); QR2=$(res "$(call "$H" "$l")")
  QESC=$(printf '%s\n' "$QS2" | $G -oE "escape '[^']*'" || true)
  [ "$QS2" = "$SELC where lower(ce1_0.name) like ? $QESC order by ce1_0.name" ] && [ "$QESC" = "escape '!'" ] && [ "$QR2" = '3 rows · names, in the query'"'"'s order: [Meera, Priya, Ravi]' ] || die "querydsl: containsIgnoreCase with a Sort - lower(...) like ? escape '!' order by ce1_0.name, read off the log (R.227): $QS2 · $QR2"
  [ "$QESC" != "$MESC" ] || die "querydsl: Querydsl's escape and Query by Example's are read off two logs - they differ on this stack"
  l='count(c.name.containsIgnoreCase("r"))'; two "$H" "$l" 1 "querydsl count"
  QS3=$(sqll "$(call "$H" "$l")"); QN3=$(res "$(call "$H" "$l")")
  [ "$QS3" = "select count(ce1_0.id) from customer ce1_0 where lower(ce1_0.name) like ? $QESC" ] && [ "$QN3" = 3 ] || die "querydsl: count(predicate) - $QS3 · $QN3"
  l='new JPAQueryFactory(em).selectFrom(c).where(c.pauses.any().days.gt(1)).orderBy(c.name.asc()).fetch()'; two "$H" "$l" 1 "querydsl any()"
  QS4=$(sqll "$(call "$H" "$l")"); QR4=$(res "$(call "$H" "$l")")
  [ "$QS4" = "$SELC where exists(select 1 from pause p1_0 where p1_0.days>? and ce1_0.id=p1_0.customer_id) order by ce1_0.name" ] && [ "$QR4" = '2 rows · names, in the query'"'"'s order: [Priya, Sunil]' ] || die "querydsl: pauses.any() - where exists(select 1 from pause ...), [Priya, Sunil]: $QS4 · $QR4"
  # a Querydsl field named in the prose must be one the generated file holds (never typed from memory)
  local pf; pf=$($G -ohE '(NumberPath|StringPath|EnumPath|ListPath|SetPath|BooleanPath|ComparablePath|DatePath|DateTimePath|SimplePath)<[^>]*> [A-Za-z_]+|StringPath [A-Za-z_]+' README.md exercise/README.md exercise/SOLUTION.md 2> /dev/null | sort -u || true)
  while IFS= read -r l; do [ -z "$l" ] || printf '%s\n' "$QF" | $G -qxF -- "$l" || die "a Querydsl field in the prose that QCustomerEntity.java does not hold - read the generated file, never memory: $l"; done <<< "$pf"
  echo "  querydsl: Querydsl $QDV (the jars' names) - -proc:full -processorpath ($APN jars): $QGN files by find, QCustomerEntity's $(printf '%s\n' "$QF" | $G -c .) fields read off it; the control 0; eq/goe - $QW1, $QR1; containsIgnoreCase - $QESC; count $QN3; any() - exists(select 1 from pause ...), $QR4; EntityPathBase from $QP1, JPAQueryFactory from $QP2"; }
chk_xcheck() { local XC
  XC=$(cat .r-xcheck.out)
  for l in "$VERH" '  INFO  org.springframework.data.repository.config.RepositoryConfigurationDelegate : Finished Spring Data repository scanning in <n> ms. Found 0 JPA repository interfaces.' "  exit 0 · 'GenerationTarget encountered exception': 0"; do has "$XC" "$l" "xcheck: the entities alone, no repository, a clean start"; done
  [ "$(cnt "$XC" "  its md5: $X09 · the owning-side lesson's (its README names it $($G -c "$X09" ../c7-unit09/README.md || true) times; its xcheck published $X09CAP): $X09 · the same: yes")" = 1 ] || die "xcheck: the harness's script must be Boot's for the anchor's entities, md5 $X09 (R.212) - a mapping moved"
  [ "$(printf '%s\n' "$XC" | $G -c '^    create table \|^    alter table ' || true)" = 3 ] || die "xcheck: two create table lines and one alter table"
  echo "  xcheck: the harness's script (@EntityScan(\"com.tiffinbox\") alone), md5 $X09 = the owning-side lesson's - no mapping moved"; }
EXQ="Your turn: the README searches by example for vegetarian customers and finds nobody. Make the example ignore what you never set."
EXW=$(printf '%s\n' "$EXQ" | wc -w | tr -d ' ')
EXB0=""; EXS0=""; EXSN=""; EXI=""
chk_exercise() { local EXB EXZ b ER ES w
  EXB=$(blk exercise "in bash" "in zsh"); EXZ=$(blk exercise "in zsh" "")
  for b in "$EXB" "$EXZ"; do
    ER=$(printf '%s\n' "$b" | sed '/then the solution/,$d'); ES=$(printf '%s\n' "$b" | sed -n '/then the solution/,$p')
    for l in '    the JVM: exit 0' '    Found 1 JPA repository interface.' '    PROBE the matcher ignores: []'; do has "$ER" "$l" "exercise: the README - the probe as constructed, nothing ignored"; done
    EXB0=$(printf '%s\n' "$ER" | sed -n 's/^    PROBE vegetarian customers: \([0-9]*\) · .*/\1/p')
    # broken = probe B: the same 0 rows, read off probe B's capture
    [ -n "$EXB0" ] && [ "$EXB0 rows · names, sorted by the harness: []" = "$PBR" ] || die "exercise: the README's search finds what probe B found ($PBR): ${EXB0:-none}"
    EXS0=$(printf '%s\n' "$ES" | sed -n 's/^    PROBE vegetarian customers: \([0-9]*\) · .*/\1/p'); EXSN=$(printf '%s\n' "$ES" | sed -n 's/^    PROBE vegetarian customers: [0-9]* · //p')
    EXI=$(printf '%s\n' "$ES" | sed -n 's/^    PROBE the matcher ignores: //p')
    for l in '    the JVM: exit 0' '    Found 1 JPA repository interface.'; do has "$ES" "$l" "exercise: the solution runs"; done
    # solved = probe A: the same names, the two ints ignored
    [ "$EXS0 rows · names, sorted by the harness: $EXSN" = "$PAR" ] && [ "$EXI" = '[mealsPerDay, pricePerMeal]' ] || die "exercise: the solution finds what probe A found ($PAR), the two ints ignored: $EXS0 · $EXSN · $EXI"
    [ "$EXB0" != "$EXS0" ] || die "exercise: broken and solved must differ - by the rows found, never the exit code"
    nhas "$b" 'PROBE threw' "exercise: neither run fails - the probe's mistake is silent"
    [ "$(printf '%s\n' "$b" | $G -c "^  the shell is now in: this unit's folder")" = 2 ] || die "exercise: the shell back in this folder"; done
  [ "$(printf '%s\n' "$EXB" | $G -v '^in ')" = "$(printf '%s\n' "$EXZ" | $G -v '^in ')" ] || die "exercise: bash and zsh print the same"
  # each file's "What it prints" block is what the run printed, line for line (never a placeholder: unit 16 shipped two)
  w=$(printf '%s\n' "$EXB" | sed '/then the solution/,$d' | sed -n '/^  the block.s exit /,/^  the shell is now in: /p' | sed '1d;$d' | sed 's/^    //')
  [ "$(wib exercise/README.md)" = "$w" ] || die "exercise/README.md's \"What it prints\" block is not what the README's lines printed: $(diff <(wib exercise/README.md) <(printf '%s\n' "$w") | head -3 | paste -sd' ' -)"
  w=$(printf '%s\n' "$EXB" | sed -n '/then the solution/,$p' | sed -n '/then the solution/,/^  the shell is now in: /p' | sed '1d;$d' | sed 's/^    //')
  [ "$(wib exercise/SOLUTION.md)" = "$w" ] || die "exercise/SOLUTION.md's \"What it prints\" block is not what the solution's lines printed: $(diff <(wib exercise/SOLUTION.md) <(printf '%s\n' "$w") | head -3 | paste -sd' ' -)"
  $G -qxF -- "**Your turn:** ${EXQ#Your turn: }" exercise/README.md || die "exercise/README.md: the spoken exercise line"
  [ "$EXW" -le 25 ] || die "exercise: the spoken line is at most 25 words (R.203): $EXW"
  $G -qF 'CustomerEntity probe = new CustomerEntity(null, 0, 0, MealType.VEG);' harness/src/probe/q/ex/ExApp.java && $G -qF 'Example<CustomerEntity> example = Example.of(probe);' harness/src/probe/q/ex/ExApp.java || die "exercise: ExApp ships probe B - the probe as constructed, Example.of(probe)"
  echo "  exercise: bash and zsh alike - the README as written (Example.of(probe)): exit 0, $EXB0 vegetarian customers (= probe B); the solution (one line: withIgnorePaths(\"mealsPerDay\", \"pricePerMeal\")): exit 0, $EXS0 - $EXSN (= probe A), ignored $EXI; each file's What it prints = the run; $EXW words"; }
cap probe probe; chk_probe; pub probe
cap matcher matcher; chk_matcher; pub matcher
cap querydsl querydsl; chk_querydsl; pub querydsl
cap xcheck xcheck; chk_xcheck; pub xcheck
cap exercise exercise; chk_exercise; pub exercise
# the raw lines, per JVM, over this run (RE-MEASURE 9): never hashed - each query's distinct raw orders, to the terminal only
echo "  (terminal only, never hashed) Query by Example's raw lines over this run's $(cut -f1 .harness/raw-all.log | sort -u | wc -l | tr -d ' ') labels and $RAWN JVMs - distinct raw lines per query: $(cut -f2 .harness/raw-all.log | sed -E 's/ where .*//' | sort -u | wc -l | tr -d ' ') SELECT shapes; the three-term probe B: $($G -F 'probe B' .harness/raw-all.log | cut -f2 | sort -u | wc -l | tr -d ' ') orders in $($G -cF 'probe B' .harness/raw-all.log) JVMs; matchingAny's or line: $(cut -f2 .harness/raw-all.log | $G -F ' or ' | sort -u | wc -l | tr -d ' ') orders in $(cut -f2 .harness/raw-all.log | $G -cF ' or ') JVMs" >&3

# ---- choose: a slide, not a capture - three SQLs side by side, composed from probe A, the Criteria lesson's spec and querydsl ---
S18=fb76cb020b6d2a5d304b2b24e25081da                # ../c7-unit18's published spec capture (its search table's source)
[ "$(awk '$1 == "spec" { print $2 }' ../c7-unit18/receipts.md5 2> /dev/null)" = "$S18" ] || die "../c7-unit18/receipts.md5's spec is not $S18 - the capture the choose table cites"
SROW=$($G -m1 -F '| 1 | `findAll(search("r", null, null))` | ' ../c7-unit18/README.md 2> /dev/null || true)
SPW=$(printf '%s\n' "$SROW" | awk -F' \\| ' '{ print $3 }' | sed 's/^`//; s/`$//'); SPR=$(printf '%s\n' "$SROW" | awk -F' \\| ' '{ print $4 }' | sed 's/ |$//')
[ -n "$SPW" ] && [ -n "$SPR" ] || die "../c7-unit18/README.md must give its one-filter row, findAll(search(\"r\", null, null))"
CROWS="| Query by Example | \`findAll(Example.of(probe, ExampleMatcher.matching().withIgnorePaths(\"mealsPerDay\", \"pricePerMeal\")))\` (probe A) | \`$PAW\` | $PAR |
| Specification | \`findAll(search(\"r\", null, null))\` (the Criteria lesson's spec, ${S18:0:8}) | \`$SPW\` | $SPR |
| Querydsl | \`findAll(c.mealType.eq(VEG).and(c.mealsPerDay.goe(2)))\` (querydsl) | \`$QW1\` | $QR1 |"
[ "$(awk '/^<!-- choose: three SQLs side by side/ { f = 1; next } f && /^\| (Query by Example|Specification|Querydsl) \|/ { print; next } f && /^\|/ { next } f { exit }' README.md)" = "$CROWS" ] || die "README.md's choose table is not the captures' - each row is composed from probe A, the Criteria lesson's spec row and querydsl, never typed: $(diff <(awk '/^<!-- choose: three SQLs side by side/ { f = 1; next } f && /^\| (Query by Example|Specification|Querydsl) \|/ { print; next } f && /^\|/ { next } f { exit }' README.md) <(printf '%s\n' "$CROWS") | head -4 | paste -sd' ' -)"
echo "  choose: README.md's table = probe A, the Criteria lesson's one-filter row (its spec capture $S18) and querydsl's first predicate - composed, no capture of its own"
# the values the video says are the captures', never typed: README.md states them in one line, composed here from what the checks read
VS="the values the video may say: probe, on Spring Data JPA 4.1.2 - B Example.of(new CustomerEntity(null, 0, 0, VEG)): $PBW ($PBN terms in the raw line; the null name, id and pauses: no term) -> $PBR · A withIgnorePaths(\"mealsPerDay\", \"pricePerMeal\"): $PAW -> $PAR · Query by Example's like: $MESC ($MCW -> $MCR) · matchingAny(): $MOW (md5 $MOH) -> $MOR · matching(), the same probe: $MAW (md5 $MAH) -> $MAR · count(Example): $MCS -> $MCN · findBy(..., q -> q.sortBy(Sort.by(\"name\")).first()): $MFS -> $MFR · a line mixing and with or: REFUSED, exit 1 · Querydsl $QDV (jakarta), the processor with -proc:full -processorpath ($APN jars): $QGN files by find - QCustomerEntity.java, QPauseEntity.java; on the class path alone: $QCTL · QCustomerEntity's fields: $(printf '%s\n' "$QF" | paste -sd';' - | sed 's/;/; /g') · eq(VEG).and(goe(2)): $QW1 -> $QR1 · containsIgnoreCase(\"r\") with Sort.by(\"name\"): Querydsl's like $QESC -> $QR2 · count(predicate): $QS3 -> $QN3 · pauses.any().days.gt(1): $(wh "$QS4") -> $QR4 · EntityPathBase from $QP1, JPAQueryFactory from $QP2 · xcheck: $X09 · exercise: Example.of(probe) -> $EXB0; withIgnorePaths -> $EXS0 $EXSN ($EXW words)"
$G -qF -- "$VS" README.md || die "README.md does not state the values these captures give ('$VS') - a typed value: $($G -oE 'the values the video may say: [^*`]*' README.md | head -1 | cut -c1-300)"
echo "  README.md states the captures' values: $VS"

# hygiene: every capture and every file this unit holds
DN=$(dishes .r-*.out); [ -z "$DN" ] || die "a capture holds an Indian dish name (R.215): $DN"
[ "$LOGS" -gt 0 ] || die "no harness JVM ran"
[ "$GENW" = 0 ] || die "a schema step failed in a log: 'GenerationTarget encountered exception' $GENW times (R.213)"
for f in .r-*.out; do
  ! $G -qE '/Users/|/private/|/home/|/var/folders/' "$f" || die "$f holds an absolute path"
  ! $G -qE 'c[0-9]-unit[0-9]|unit ?[0-9]' "$f" || die "$f holds a unit number"
  ! $G -qE ' (with PID|started by) |Time elapsed|time="| in [0-9.]+ seconds' "$f" || die "$f holds Boot's process line, a time or Boot's seconds"
  ! $G -qE '^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T|"timestamp":"?[0-9]|(exec|handler|task)-[0-9]' "$f" || die "$f holds a log time, a timestamp or a thread number"
  ! $G -qE 'using Java [0-9]|Darwin|arm64|aarch64|musl' "$f" || die "$f holds an OS or a JDK version token (R.151)"
  ! $G -qE 'jdbc:h2:mem:[0-9a-f]{8}-' "$f" || die "$f holds a generated database name, unmasked"
  ! $G -qE '\$Proxy[0-9]|SessionImpl\([0-9]|scanning in [0-9]+ ms|CONSTRAINT_[0-9]' "$f" || die "$f holds a proxy number, an EntityManager's identity, a scan time or an H2 constraint name, unmasked"
  ! $G -qE '[0-9]+\.[0-9]+ ms|[0-9] ms\b' "$f" || die "$f holds a millisecond figure (R.207)"
  ! $G -qE 'Last modified|SHA-256 checksum|Classfile ' "$f" || die "$f holds javap -v's header (a date, a checksum, a path)"
  ! $G -qE '^ +at [a-z]' "$f" || die "$f holds a stack frame"
  ! $G -qE 'https?://' "$f" || die "$f holds a URL"; done
# every JVM: its locale pinned on its java line (S6.1), and under its alarm (R.247)
for f in .r-*.out; do ! $G -E '^ *\$ .*(^|[ (])java ' "$f" | $G -v '^ *\$ javap ' | $G -vF -- "java $JL " > /dev/null || die "$f starts a JVM without its locale pinned (S6.1)"
  ! $G -E '^ *\$ .*(^|[ (])java -D' "$f" | $G -vF -- "perl -e 'alarm " > /dev/null || die "$f starts a JVM without its alarm (R.247)"; done
K1='pki''ll'; K2='kill''all'; ! $G -v '^ *#' receipts.sh | $G -qwE "$K1|$K2" || die "receipts.sh names $K1 or $K2 - every process is stopped by its pid"
for f in receipts.sh exercise/README.md exercise/SOLUTION.md; do ! $G -nE '(^|[;&|({] *)wait *($|[;&|)}])' "$f" | $G -vE '^[0-9]+: *#' > /dev/null || die "$f has a bare wait (S6.9)"; done
for f in receipts.sh README.md exercise/README.md exercise/SOLUTION.md; do ! $G -nE '^[A-Za-z_][A-Za-z_0-9]*="?--[^ "]+ +--' "$f" > /dev/null || die "$f holds a one-string multi-option variable (R.193)"; done
! $G -rq 'probe\.q' anchor/tiffinbox-web anchor/tiffinbox-core || die "the anchor's code names the course's harness - it is never TiffinBox's"
! $G -rqE '^package com\.tiffinbox' harness/src || die "a harness class sits in com.tiffinbox (R.43)"
[ -z "$(find . "$UP" -maxdepth 1 \( -name '*.mv.db' -o -name '*.trace.db' \) 2> /dev/null; find . -path ./.m2-demo -prune -o \( -name '*.mv.db' -o -name '*.trace.db' \) -print)" ] || die "an H2 database file exists - every H2 here is in memory (R.195)"
echo "  hygiene: $(ls .r-*.out | wc -l | tr -d ' ') captures, $LOGS harness JVM logs; 'GenerationTarget encountered exception' 0; no path, unit number, time, millisecond figure, OS token, unmasked proxy number, identity or generated name, URL, javap header or stack frame in any capture; every JVM pinned and under its alarm; no H2 file"

# ---- the end: the anchor, the ports ----------------------------------------------------------------------------------------
anchornote end
for p in $PORTS; do [ "$(listeners $p)" = 0 ] || die "something listens on $p at the end"; done
echo "  ports: nothing listens on 18425, 8080, 35729 or 20000-20009 at the end - this unit bound none; 20009 never bound"
[ -z "$unpub" ] || die "no published hash for:$unpub - check the captures, then copy the md5s above into receipts.md5 and run again"
echo "c7-unit21: every capture 3/3 and = published; every spoken number asserted; no port bound"
