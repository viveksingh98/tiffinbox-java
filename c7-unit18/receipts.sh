#!/bin/bash
XPATH=$PATH                                           # the PATH you started this with: the exercise's own shells get it
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25.0.4.1 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# Course 7 · Criteria API and Specifications - this unit's receipts. No change to the anchor (brief ⚑11): anchor/ is the link to
# ../c7-unit17/after, Section 3's frozen anchor. A search with three optional filters, each a Specification - one condition as an
# object - combined by Spring Data JPA 4.1 from the ones given; the field names as strings, and as the static metamodel
# hibernate-processor writes from the anchor's entity sources. Five captures, each run three times and hashed; a hash that
# differs from receipts.md5 stops the run; every number and string the video says is asserted right after its capture by a
# check that can fail. One database: H2 (brief ⚑2: 18 is an H2 unit), in each JVM's memory, gone with it. No TiffinBox runs here.
#   spec      the search (a harness JVM): the same findAll(spec) call with none, one, two and three filters - four where
#             clauses, one SELECT each (the SQL logger's lines and Statistics); Specification.allOf(list) against
#             unrestricted().and(...) - the SQL byte for byte; unrestricted() alone; count(spec); findAll(spec, PageRequest) -
#             the SELECT and its count query
#   nulls     the failure receipt (three harness JVMs: B, A, A'): B the old idiom, where(null) and then and(...) -
#             IllegalArgumentException: Specification must not be null, 0 statements; and(null) beside it; A and A' allOf(list)
#             in fresh JVMs; Specification read off the jar (javap: its methods, the Deprecated attributes counted); the
#             harness's own -Xlint:deprecation compile, its warnings counted
#   meta      strings vs the metamodel: hibernate-processor run by javac over the anchor's three entity sources (byte copies)
#             with -processorpath naming its jars - the generated files counted by find; the control, the processor on the
#             class path alone - 0 generated; B r.get("nmae") (compiles, fails at the call); A and A' r.get(CustomerEntity_.name);
#             CustomerEntity_.nmae typed - javac refuses it, exit 1
#   xcheck    the harness's DDL script (@EntityScan("com.tiffinbox") alone, scripts.action=create) against the owning-side
#             lesson's published md5: no mapping moved (R.212, brief ⚑3)
#   exercise  exercise/README.md's commands, then exercise/SOLUTION.md's, read from the files and run as written, in ONE env -i
#             shell - /bin/bash, then again in /bin/zsh -f; each file's "What it prints" block = what it printed
# No anchor change: anchor/ is the link to ../c7-unit17/after. It equals ../c7-tiffinbox until a later unit changes the anchor -
# printed at the start and the end, a note then, never a stop (R.211). The anchor is COPIED under .harness/anchor and built
# there, never in place (its README's package line, offline; its tests run); its jar extracted (the anchor's own line).
# The harness (harness/src, packages probe.q and probe.x, outside com.tiffinbox) is compiled against the anchor's extracted
# libraries and the metamodel classes the processor wrote (.harness/mcls), with javac -parameters -Xlint:deprecation into
# .harness/hc. probe.q.Main is a Spring Boot context with no web server (WebApplicationType.NONE: it binds no port) over the
# anchor's libraries, @EntityScan on com.tiffinbox - the anchor's entities - and @EnableJpaRepositories on probe.q.repo, the
# harness's own interface (Customers: JpaRepository and JpaSpecificationExecutor of CustomerEntity); probe.q.Seed builds the
# shipped Database in code on the run's own H2 database, which seeds it; Hibernate writes no schema (ddl-auto none), its
# statistics are on; Logback (harness/logback.xml) prints Hibernate's SQL logger, its HHH000001 line, the EntityManagerFactory's
# line and Spring Data's scan line. probe.x.XMain is xcheck's context (the entities alone). Each runs from .harness/run. Its JVM
# flags travel as an array, V, its arguments as an array, A (R.193). Every JVM this script starts - the harness's and the
# exercise's - runs under an alarm (perl -e 'alarm N; exec ...': macOS has no timeout); an alarm that fires is a failed receipt
# (R.247). Commands are printed exactly as they run: each goes through eval. harness/dur7.py (Course 7's builders' duration
# pattern, byte for byte) gates this unit's prose: it speaks no time (R.172). "$M2" is this unit's own repository, .m2-demo.
# The processor (S3.17/R.248, RED #901): harness/proc/pom.xml names hibernate-processor alone; Maven's dependency:build-classpath
# lists its jars from .m2-demo (offline), and javac gets them by name after -processorpath ("$PP" on screen - every entry a .jar
# under $M2, no wildcard: a lib/* there is not expanded); the generated files are counted by find -type f, never typed.
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
# "CONSTRAINT_<n>", "CONSTRAINT_INDEX_<n>". A harness JVM's log is printed whole (every line it prints, trailing spaces dropped).
# Ports (§P, 19970-19979): this unit binds none. All ten, and 18425 (TiffinBox's default), 8080 and 35729, are checked free at the
# start and the end; 19979 is the one the brief names "never bound".
set -e
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
javac -version 2>&1 | $G -q '^javac 25' || die "javac 25 needed (the harness and the metamodel are compiled with it)"
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
HFILES='dur7.py logback.xml proc src'
SFILES='probe/q/Filters.java probe/q/Main.java probe/q/Run.java probe/q/Seed.java probe/q/ex/ExApp.java probe/q/repo/Customers.java probe/q/typo/MetaTypo.java probe/x/XMain.java'
for f in exercise/README.md exercise/SOLUTION.md README.md receipts.md5 harness/proc/pom.xml; do [ -f "$f" ] || die "$f is missing"; done
[ "$(ls harness | paste -sd' ' -)" = "$HFILES" ] && [ "$(cd harness/src && find . -type f | sed 's#^\./##' | sort | paste -sd' ' -)" = "$SFILES" ] && [ "$(ls harness/proc | paste -sd' ' -)" = pom.xml ] || die "harness/ holds another file, or misses one"
[ "$(ls exercise | paste -sd' ' -)" = 'README.md SOLUTION.md' ] || die "exercise/ holds another file"
[ "$(md5 -q harness/dur7.py)" = 41667fed9ffcefe171389eed7e654e66 ] || die "harness/dur7.py is not the builders' dur7.py (md5 41667fed…)"
if [ -f ../../../data-jpa-hibernate/_builders/dur7.py ]; then cmp -s harness/dur7.py ../../../data-jpa-hibernate/_builders/dur7.py || die "harness/dur7.py differs from the builders' ../../../data-jpa-hibernate/_builders/dur7.py"
  echo "  (terminal only) harness/dur7.py = the builders' _builders/dur7.py, byte for byte" >&3
else echo "  (terminal only) the builders' _builders/dur7.py is not beside this clone: its md5 above is the check" >&3; fi
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
PORTS="18425 8080 35729 19970 19971 19972 19973 19974 19975 19976 19977 19978 19979"
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
# RED #931: the where(null) idiom is refused "on Spring Data JPA 4.1" - no other version is credited with accepting it
S3=$($G -niE '(spring data( jpa)?|spring boot) ?[23](\.[0-9x]+)*( and [23](\.[0-9x]+)*)?[^.]{0,80}(where\(null\)|null specification|accepted|accepts|allowed)|(where\(null\)|the old idiom)[^.]{0,80}(spring data( jpa)?|spring boot) ?[23](\.[0-9x]+)*' README.md exercise/README.md exercise/SOLUTION.md 2> /dev/null | cut -c1-160 | head -3 | paste -sd';' - || true)
[ -z "$S3" ] || die "a line credits a Spring Data or Boot 2/3 version with the where(null) idiom - no such jar here, the claim is memory (RED #931): $S3"
echo "  S3.10's refused class name: 0 lines over README.md, exercise/, harness/src; a 2.x/3.x version credited with where(null): 0 lines"
# R.225, S3.17 (RED #902): the number of files the processor writes is meta's find count, stated once, in the values line this
# script composes - a count of generated, metamodel or index files typed anywhere else in the prose is refused
NUMW='one|two|three|four|five|six|seven|eight|nine|ten|eleven|twelve|thirteen|fourteen|fifteen|[0-9]+'
TG=$($G -niE "\\b($NUMW) (generated( files| sources| classes)?|(metamodel|index|entity/index) files|files (generated|written)|files in entity/index)\\b" README.md exercise/README.md exercise/SOLUTION.md 2> /dev/null | $G -vF 'the values the video may say:' | cut -c1-160 | head -3 | paste -sd';' - || true)
[ -z "$TG" ] || die "a typed count of the processor's files - meta counts them by find, and only the values line states them (R.225, S3.17): $TG"
echo "  typed generated-file counts: 0 (meta's find count is in the values line only)"
# R.225, R.227: a SQL string this unit shows is the logger's, composed into README.md's search table and its values line by this
# script - a line of README.md holding Hibernate's alias (ce1_0.) anywhere else is a typed SQL string, refused
TS=$($G -nF 'ce1_0.' README.md 2> /dev/null | $G -vE '^[0-9]+:\| [0-9] \| `' | $G -vF 'the values the video may say:' | cut -c1-160 | head -3 | paste -sd';' - || true)
[ -z "$TS" ] || die "a typed SQL string in README.md outside the search table and the values line (R.225, R.227): $TS"
echo "  typed SQL strings: 0 in README.md outside its composed table and values line"

# ---- the commands: read from anchor/README.md, the anchor's own, and asserted - each line must be there, whole -------------
readme() { $G -m1 -xF -- "$1" anchor/README.md > /dev/null || die "anchor/README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
R_PLAIN=$(readme 'mvn -B package')
R_EXTRACT=$(readme 'java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted')
# This unit's own lines (README.md, "The commands this unit adds") - each asserted to be exactly that
mine() { $G -m1 -xF -- "$1" README.md > /dev/null || die "README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
JL='-Duser.language=en -Duser.country=US'
AL="perl -e 'alarm 240; exec @ARGV'"
EL=".harness/ents/CustomerEntity.java .harness/ents/MealType.java .harness/ents/PauseEntity.java"
L_PROC=$(mine 'cd .harness/proc && mvn -o -B -Dmaven.repo.local="$M2" dependency:build-classpath -Dmdep.outputFile=cp.txt')
L_META=$(mine "javac -proc:full -processorpath \"\$PP\" -cp \".harness/anchor/$XD/lib/*\" -s .harness/msrc -d .harness/mcls $EL")
L_CTL=$(mine "javac -cp \".harness/anchor/$XD/lib/*:\$PP\" -s .harness/ctl/src -d .harness/ctl/cls $EL")
L_JAVAC=$(mine "javac -parameters -Xlint:deprecation -d .harness/hc -cp \".harness/anchor/$XD/lib/*:.harness/mcls\" $HS/Filters.java $HS/Main.java $HS/Run.java $HS/Seed.java $HS/repo/Customers.java harness/src/probe/x/XMain.java")
L_TYPO=$(mine "javac -d .harness/tc -cp \".harness/anchor/$XD/lib/*:.harness/mcls\" $HS/typo/MetaTypo.java")
L_H=$(mine "$AL java $JL -Dstdout.encoding=UTF-8 \"\${V[@]}\" -cp \"../hc:../mcls:../anchor/$XD/lib/*\" probe.q.Main \"\${A[@]}\"")
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
# ---- extracted (the anchor's line); the processor's class path resolved by Maven; the metamodel; the harness ----------------
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
mbuild "$(off .harness/anchor "$R_PLAIN" package)" .harness/build-anchor.log ".harness/anchor (anchor/, its README's package line; its tests ran)"
(cd .harness/anchor && eval "$R_EXTRACT") > .harness/extract.log 2>&1 < /dev/null || die "the extract failed: $(tail -3 .harness/extract.log)"
for a in org/springframework/boot/spring-boot-starter-parent/4.1.2/spring-boot-starter-parent-4.1.2.pom org/hibernate/orm/hibernate-core/7.4.13.Final/hibernate-core-7.4.13.Final.jar org/springframework/data/spring-data-jpa/4.1.2/spring-data-jpa-4.1.2.jar com/h2database/h2/2.5.250/h2-2.5.250.jar org/hibernate/orm/hibernate-processor/7.4.13.Final/hibernate-processor-7.4.13.Final.jar; do
  [ -e "$M2/$a" ] || die "$a is not in .m2-demo - README.md, The repository"; done
# the processor's class path: its POM copied, Maven's list of its jars (offline); every entry a jar under .m2-demo, no wildcard
mkdir -p .harness/proc; cp harness/proc/pom.xml .harness/proc/pom.xml
mbuild "$L_PROC" .harness/build-proc.log ".harness/proc (harness/proc/pom.xml: hibernate-processor's class path, dependency:build-classpath)"
PP=$(cat .harness/proc/cp.txt)
PPN=$(printf '%s\n' "$PP" | tr ':' '\n' | $G -c . || true)
[ "$PPN" -gt 0 ] && [ -z "$(printf '%s\n' "$PP" | tr ':' '\n' | $G -vE "^$(printf '%s' "$M2" | sed 's/[][\.*^$/]/\\&/g')/.+\\.jar$" || true)" ] || die "the processor's class path must be jars under .m2-demo, named one by one (no wildcard): $(printf '%s\n' "$PP" | cut -c1-200)"
printf '%s\n' "$PP" | tr ':' '\n' > .harness/proc/cp.lines
while IFS= read -r f; do [ -f "$f" ] || die "the processor's class path names a jar that is not there: $f"; done < .harness/proc/cp.lines
printf '%s\n' "$PP" | tr ':' '\n' | $G -q '/hibernate-processor-7\.4\.13\.Final\.jar$' || die "the processor's class path must hold hibernate-processor-7.4.13.Final.jar"
# the anchor's entity sources, byte copies - each md5 asserted equal to the frozen tree's (⚑11)
mkdir -p .harness/ents
for f in $ENTS; do cp "anchor/$CJ/$f" .harness/ents/; [ "$(md5 -q ".harness/ents/$f")" = "$(md5 -q "anchor/$CJ/$f")" ] || die ".harness/ents/$f is not the anchor's, byte for byte"; done
# the metamodel the harness compiles against - the processor run as meta runs it; its files counted by find (the S3.17 check)
mkdir -p .harness/msrc .harness/mcls
jc "$L_META" .harness/meta-build.log
[ "$JE" = 0 ] || die "the metamodel's javac failed (exit $JE): $(head -5 .harness/meta-build.log)"
MSN=$(find .harness/msrc -type f | wc -l | tr -d ' ')
[ "$MSN" -gt 0 ] && [ -f .harness/msrc/com/tiffinbox/CustomerEntity_.java ] || die "the generated files: $MSN (find .harness/msrc -type f) - the processor never ran, and CustomerEntity_ was not written (S3.17/R.248: on the class path alone JDK 25 runs no processor)"
# the line itself, after the count (the count is the check that can fail - R.226; the line's shape a second guard)
case "$L_META" in *' -proc:full -processorpath "$PP" '*) ;; *) die "the metamodel's javac line must name -proc:full and -processorpath (S3.17/R.248): $L_META" ;; esac
# the harness runs against the anchor's own entity classes (its jar): the processor's copies of them are dropped, its *_ kept
for f in $ENTS; do rm -f ".harness/mcls/com/tiffinbox/${f%.java}.class"; done
[ "$(cd .harness/mcls && find . -type f | sed 's#^\./##' | sort | paste -sd' ' -)" = 'com/tiffinbox/CustomerEntity_.class com/tiffinbox/PauseEntity_.class' ] || die ".harness/mcls must hold the two metamodel classes alone"
jc "$L_JAVAC" .harness/javac.log
[ "$JE" = 0 ] || die "the harness did not compile: $(head -5 .harness/javac.log)"
[ ! -e .harness/hc/probe/q/ex ] && [ ! -e .harness/hc/probe/q/typo ] || die "the exercise's or the typo's class was compiled into the harness - each is compiled on its own"
echo "  extracted the anchor's jar ($(ls .harness/anchor/$XD/lib | wc -l | tr -d ' ') libraries); the processor's class path: $PPN jars; the metamodel written ($MSN files) and its two classes kept; the harness compiled into .harness/hc"

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
HA=('--spring.datasource.url=jdbc:h2:mem:u18;DB_CLOSE_DELAY=-1' --logging.config=../../harness/logback.xml --spring.jpa.hibernate.ddl-auto=none --spring.main.banner-mode=off --spring.thymeleaf.check-template-location=false --spring.jpa.properties.hibernate.generate_statistics=true)
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

# ---- spec: the search - none, one, two, three filters; allOf against unrestricted().and; count; a page ------------------------
spec() { echo "the search - one harness JVM (.harness/hc):"
  V=(-Ds=spec); A=("${HA[@]}"); hrun; hview; }

# ---- nulls: 4.x refuses null - B the old idiom (the failure receipt), A and A' allOf(list); the API read off the jar ------------
SDJ=".harness/anchor/$XD/lib/spring-data-jpa-4.1.2.jar"
SPEC=org.springframework.data.jpa.domain.Specification
nulls() { local v
  echo "Specification as Spring Data JPA's jar declares it - \$ javap -cp $SDJ $SPEC (its member lines):"
  javap -cp "$SDJ" "$SPEC" 2>&1 | $G -E '^  public ' | sed 's/^  /    /'
  v=$(javap -v -cp "$SDJ" "$SPEC" 2>&1)
  echo "  its member lines: $(javap -cp "$SDJ" "$SPEC" 2>&1 | $G -cE '^  public ' || true) · \$ javap -v ... | grep -c Deprecated: $(printf '%s\n' "$v" | $G -c Deprecated || true) · RuntimeVisibleAnnotations naming java/lang/Deprecated: $(printf '%s\n' "$v" | $G -c 'Ljava/lang/Deprecated;' || true)"
  echo "the harness's own compile - javac -parameters -Xlint:deprecation (its Specification calls among the sources): exit 0 · its output lines: $($G -c . .harness/javac.log || true) · warnings: $($G -c 'warning:' .harness/javac.log || true)"
  echo "B - Specification.where(null), then and(...) - the failure receipt (one harness JVM, .harness/hc):"
  V=(-Ds=nulls -Dv=B); A=("${HA[@]}"); hrun; hview
  echo "A - Specification.allOf(list), the filters it has (one harness JVM, .harness/hc):"
  V=(-Ds=nulls -Dv=A); A=("${HA[@]}"); hrun; hview
  echo "A' - A again, in a fresh JVM:"
  V=(-Ds=nulls -Dv=A); A=("${HA[@]}"); hrun; hview; }

# ---- meta: strings vs the metamodel - the processor (and its control), B the string's typo, A and A', javac's refusal -----------
# gen DIR: the files the processor wrote under DIR, counted and named by find -type f (R.226: a count that can fail)
gen() { echo "  \$ find ${1#.harness/} -type f | wc -l: $(find "$1" -type f 2> /dev/null | wc -l | tr -d ' ')"
  [ ! -d "$1" ] || (cd "$1" && find . -type f | sed 's#^\./#    #' | sort); }
meta() { echo "the processor - hibernate-processor over the anchor's entity sources (byte copies in .harness/ents, each md5 = the anchor's):"
  for f in $ENTS; do echo "  .harness/ents/$f · md5 $(md5 -q ".harness/ents/$f") · the anchor's: $( [ "$(md5 -q ".harness/ents/$f")" = "$(md5 -q "anchor/$CJ/$f")" ] && echo the same || echo DIFFERENT)"; done
  echo "  PP: the processor's class path, Maven's list - $(printf '%s\n' "$PP" | tr ':' '\n' | $G -c . || true) jars, each named (the first: $(printf '%s\n' "$PP" | tr ':' '\n' | sed -n 1p | sed "s#^$M2/#\$M2/#"))"
  rm -rf .harness/meta-run; mkdir -p .harness/meta-run/msrc .harness/meta-run/mcls
  echo "\$ ${L_META//.harness\/m/.harness/meta-run/m}"
  jc "${L_META//.harness\/m/.harness/meta-run/m}" .harness/meta-run.log
  echo "  exit $JE · what javac printed:"; sed 's/^/    /' .harness/meta-run.log
  echo "  the generated sources (the -s folder) - every file:"; gen .harness/meta-run/msrc
  echo "  in its entity/index folder: $(find .harness/meta-run/msrc/entity/index -type f 2> /dev/null | wc -l | tr -d ' ') files · the source files (*.java): $(find .harness/meta-run/msrc -type f -name '*.java' | wc -l | tr -d ' ') · each the same as the build's: $(diff -r .harness/msrc .harness/meta-run/msrc > /dev/null 2>&1 && echo yes || echo no)"
  echo "  CustomerEntity_.java's lines naming the class, its annotations and the name field:"
  $G -nE '^@StaticMetamodel|^@Generated|^public abstract class |SingularAttribute<CustomerEntity, String> name;' .harness/meta-run/msrc/com/tiffinbox/CustomerEntity_.java 2> /dev/null | sed -E 's/^([0-9]+):[[:space:]]*/    \1: /'
  echo "the control - the same jars on the class path alone, no processor flag:"
  rm -rf .harness/ctl; mkdir -p .harness/ctl/src .harness/ctl/cls
  echo "\$ $L_CTL"; jc "$L_CTL" .harness/ctl.log
  echo "  exit $JE · what javac printed: $($G -c . .harness/ctl.log || true) lines"; gen .harness/ctl/src
  echo "  the classes it compiled: $(cd .harness/ctl/cls && find . -type f | sed 's#^\./##' | sort | paste -sd' ' -)"
  echo "B - the field's name as a string, typed wrong: r.get(\"nmae\") (one harness JVM, .harness/hc - it compiled):"
  V=(-Ds=meta -Dv=B); A=("${HA[@]}"); hrun; hview
  echo "A - the metamodel's field: r.get(CustomerEntity_.name) (one harness JVM):"
  V=(-Ds=meta -Dv=A); A=("${HA[@]}"); hrun; hview
  echo "A' - A again, in a fresh JVM:"
  V=(-Ds=meta -Dv=A); A=("${HA[@]}"); hrun; hview
  echo "the metamodel's field, typed wrong - CustomerEntity_.nmae in $HS/typo/MetaTypo.java, compiled on its own:"
  rm -rf .harness/tc; mkdir -p .harness/tc
  echo "\$ $L_TYPO"; jc "$L_TYPO" .harness/typo.log
  echo "  exit $JE · what javac printed:"; sed -E 's/[[:space:]]+$//; s/^/    /' .harness/typo.log
  echo "  the classes it wrote: $(find .harness/tc -type f | wc -l | tr -d ' ')"; }

# ---- xcheck: the harness's DDL for the anchor's two entities against Boot's, as the owning-side lesson captured it --------------
X09=f595637014e786fa38606859951e4f97                # Boot's script for CustomerEntity + PauseEntity, as ../c7-unit09's xcheck captured it (R.212)
X09CAP=9072c6f11c8c8e713c997b58d3a79d74             # ../c7-unit09's published xcheck capture
[ "$($G -c "$X09" ../c7-unit09/README.md || true)" -gt 0 ] || die "../c7-unit09/README.md must name $X09 - Boot's script md5 (R.212)"
[ "$(awk '$1 == "xcheck" { print $2 }' ../c7-unit09/receipts.md5)" = "$X09CAP" ] || die "../c7-unit09/receipts.md5's xcheck is not $X09CAP - the capture that holds Boot's script"
XA=('--spring.datasource.url=jdbc:h2:mem:x18;DB_CLOSE_DELAY=-1' --logging.config=../../harness/logback.xml --spring.jpa.hibernate.ddl-auto=none --spring.main.banner-mode=off --spring.thymeleaf.check-template-location=false --spring.jpa.properties.jakarta.persistence.schema-generation.scripts.action=create --spring.jpa.properties.jakarta.persistence.schema-generation.scripts.create-target=hibernate-ddl.sql)
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
DBL='  PROBE database: H2 2.5.250 (2026-08-29) | url jdbc:h2:mem:u18;DB_CLOSE_DELAY=-1'
SEEDL='  PROBE seeded by the shipped Database (createAndSeed); read by a second connection - customer (id | name | meal_type | meals_per_day): [1 | Ravi | VEG | 2, 2 | Meera | NON_VEG | 1, 3 | Sunil | VEG | 3, 4 | Priya | VEGAN | 1]'
FOUND1='  INFO  org.springframework.data.repository.config.RepositoryConfigurationDelegate : Finished Spring Data repository scanning in <n> ms. Found 1 JPA repository interface.'
ver() { local c; c=$(cat ".r-$1.out")
  [ "$(cnt "$c" "$VERL")" = "$2" ] && [ "$(cnt "$c" "$VERH")" = "$2" ] && [ "$(cnt "$c" "$VERD")" = "$2" ] || die "$1: the version lines - getVersionString(), Hibernate's HHH000001 and Spring Data JPA's 4.1.2 - once in each of its $2 harness JVMs (R.222, S3.15/R.246)"
  [ "$(cnt "$c" "$DBL")" = "$2" ] && [ "$(cnt "$c" "$SEEDL")" = "$2" ] && [ "$(cnt "$c" "$FOUND1")" = "$2" ] || die "$1: the database: line, H2 2.5.250, the shipped seed and Spring Data's Found 1, in each of its $2 harness JVMs (R.217: this unit speaks for H2 only)"
  [ "$(cnt "$c" "  exit 0 · 'GenerationTarget encountered exception': 0")" = "$2" ] || die "$1: each of its $2 harness JVMs ends by itself, exit 0 (a call failure is not a start failure, S3.9)"; }
# R.184: a statement count has two witnesses from one call - the SQL logger's lines between ">>> label" and "<<< label", and
# Hibernate's Statistics for that call (getPrepareStatementCount, printed on the "<<<" line)
call() { printf '%s\n' "$1" | awk -v a="  PROBE >>> $2" -v b="  PROBE <<< $2 · " 'index($0, a) == 1 && length($0) == length(a) { f = 1 } f { print } f && index($0, b) == 1 { f = 0 }'; }
sqll() { printf '%s\n' "$1" | $G '^  DEBUG org\.hibernate\.SQL : ' | sed 's/^  DEBUG org\.hibernate\.SQL : //' || true; }
two() { local b n p; b=$(call "$1" "$2"); [ -n "$b" ] || die "$4: no call named $2"
  n=$(sqll "$b" | $G -c . || true); p=$(printf '%s\n' "$b" | sed -n 's/^  PROBE <<< .* · statements (getPrepareStatementCount) \([0-9]*\) · .*/\1/p')
  [ "$n" = "$3" ] && [ "$p" = "$3" ] || die "$4: $3 statements - the SQL log's lines ($n) and getPrepareStatementCount() (${p:-none}) both (R.184)"; }
res() { printf '%s\n' "$1" | sed -n 's/^  PROBE result: //p'; }
thr() { printf '%s\n' "$1" | sed -n 's/^  PROBE threw: //p'; }
SELC='select ce1_0.id,ce1_0.meal_type,ce1_0.meals_per_day,ce1_0.name,ce1_0.price_per_meal from customer ce1_0'
# wh SQL: the SQL from its from-clause's alias on - "customer ce1_0" and what follows it (the where clause, an order by, a page)
wh() { printf '%s\n' "$1" | sed 's/^.* from customer ce1_0//; s/^ //'; }
# the README's search table: one row per call - the filters given, the call, the where clause Hibernate's logger printed for
# it, what it returned - composed from spec, never typed
QROWS=""; QN=0
qrow() { local r w; [ -n "$3" ] && w="\`$3\`" || w='no where clause'; r="| $1 | \`$2\` | $w | $4 |"; QROWS="$QROWS$r
"; QN=$((QN + 1)); }
W0=""; W1=""; W2=""; W3=""; WEQ=""; CNTS=""; CNTR=""; PGS=""; PGR=""; CRESC=""
chk_spec() { local SP l s w b i n
  SP=$(cat .r-spec.out); ver spec 1
  i=0
  for l in 'findAll(search(null, null, null))' 'findAll(search("r", null, null))' 'findAll(search("r", VEG, null))' 'findAll(search("r", VEG, 2))'; do
    b=$(call "$SP" "$l"); two "$SP" "$l" 1 "spec $l"
    has "$b" "  PROBE filters given: $i" "spec $l: the filters given"
    s=$(sqll "$b"); case "$s" in "$SELC"*) ;; *) die "spec $l: the SELECT names the entity's five columns: $s" ;; esac
    w=$(wh "$s"); n=$(printf '%s\n' "$w" | $G -oE ' and ' | wc -l | tr -d ' ')
    # S3 hook: none, one, two, three conditions - no where for none, then where and one condition more each time
    if [ $i = 0 ]; then [ -z "$w" ] || die "spec: no filter given - no where clause: $w"
    else case "$w" in 'where '*) ;; *) die "spec $l: a where clause: $w" ;; esac
      [ "$n" = $((i - 1)) ] || die "spec $l: $i conditions, joined by and ($n)"; fi
    case $i in 0) W0=$w ;; 1) W1=$w ;; 2) W2=$w ;; 3) W3=$w ;; esac
    qrow "$i" "$l" "$w" "$(res "$b")"; i=$((i + 1)); done
  [ "$W2" = "$W1 and ce1_0.meal_type=?" ] && [ "$W3" = "$W2 and ce1_0.meals_per_day>=?" ] || die "spec: each filter adds its own condition to the clause before it: $W1 | $W2 | $W3"
  [ "$W1" = "where lower(ce1_0.name) like ? escape ''" ] || die "spec: the name filter - cb.like over cb.lower, no escape character given: Hibernate writes escape '' on H2 (the brief's hazard): $W1"
  CRESC="escape ''"
  for l in '  PROBE result: 4 rows · names, sorted by the harness: [Meera, Priya, Ravi, Sunil]' '  PROBE result: 3 rows · names, sorted by the harness: [Meera, Priya, Ravi]'; do has "$SP" "$l" "spec: the rows"; done
  [ "$(cnt "$SP" '  PROBE result: 1 rows · names, sorted by the harness: [Ravi]')" = 4 ] || die "spec: two filters, three filters, allOf and the chain - Ravi"
  # allOf(list) against unrestricted().and(...) - the SQL byte for byte (the brief's spec beat; the plant "made to differ" fails here)
  local la='findAll(Specification.allOf(nameContains("r"), mealType(VEG), minMeals(2)))' lu='findAll(Specification.<CustomerEntity>unrestricted().and(nameContains("r")).and(mealType(VEG)).and(minMeals(2)))'
  two "$SP" "$la" 1 "spec allOf"; two "$SP" "$lu" 1 "spec unrestricted().and"
  [ "$(sqll "$(call "$SP" "$la")")" = "$(sqll "$(call "$SP" "$lu")")" ] && [ "$(sqll "$(call "$SP" "$la")")" = "$SELC $W3" ] || die "spec: Specification.allOf(three filters) and unrestricted().and(...).and(...).and(...) must log the same SQL, byte for byte - and the search's three-filter SQL: $(sqll "$(call "$SP" "$la")") | $(sqll "$(call "$SP" "$lu")")"
  [ "$(res "$(call "$SP" "$la")")" = "$(res "$(call "$SP" "$lu")")" ] || die "spec: the two combinations return the same rows"
  WEQ="yes (cmp of the two logged lines: equal)"
  l='findAll(Specification.unrestricted())'; two "$SP" "$l" 1 "spec unrestricted()"; [ "$(sqll "$(call "$SP" "$l")")" = "$SELC" ] || die "spec: unrestricted() alone - no where clause"
  # count(spec): one statement, a count of ids; the page: its SELECT and the count query Spring Data adds
  l='count(nameContains("r"))'; two "$SP" "$l" 1 "spec count"; CNTS=$(sqll "$(call "$SP" "$l")"); CNTR=$(res "$(call "$SP" "$l")")
  [ "$CNTS" = "select count(ce1_0.id) from customer ce1_0 $W1" ] && [ "$CNTR" = 3 ] || die "spec: count(spec) - select count(ce1_0.id) from customer ce1_0 $W1, 3: $CNTS · $CNTR"
  l='findAll(nameContains("r"), PageRequest.of(0, 1, Sort.by("name")))'; two "$SP" "$l" 2 "spec page"; PGS=$(sqll "$(call "$SP" "$l")"); PGR=$(res "$(call "$SP" "$l")")
  [ "$(printf '%s\n' "$PGS" | paste -sd'|' -)" = "$SELC $W1 order by ce1_0.name offset ? rows fetch first ? rows only|$CNTS" ] || die "spec: the page - its SELECT (order by ce1_0.name, offset/fetch) and then the count query: $(printf '%s\n' "$PGS" | paste -sd'|' -)"
  [ "$PGR" = 'total 3 · pages 3 · page 0: [Meera]' ] || die "spec: the page - total 3, 3 pages, Meera first by name: $PGR"
  # the README's table: the rows after its marker line, to the first line that is not a row, must be these, in this order
  [ "$(awk '/^<!-- spec: the search table/ { f = 1; next } f && /^\| [0-9]/ { print; next } f && /^\|/ { next } f { exit }' README.md)" = "$(printf '%s' "$QROWS")" ] || die "README.md's search table is not the capture's - each row is composed from spec (filters | call | where clause | returned), never typed: $(diff <(awk '/^<!-- spec: the search table/ { f = 1; next } f && /^\| [0-9]/ { print; next } f && /^\|/ { next } f { exit }' README.md) <(printf '%s' "$QROWS") | head -4 | paste -sd' ' -)"
  echo "  spec: the same findAll(search(...)) with 0, 1, 2, 3 filters - no where, then 1, 2, 3 conditions, one SELECT each (log and Statistics); allOf = unrestricted().and byte for byte; count(spec) $CNTR; the page - SELECT then its count, $PGR; README.md's table = these $QN rows; H2"; }
NB=""; NB2=""; NA=""; DEPN=""; LINTW=""; SPM=""
chk_nulls() { local N B A1 A2 l
  N=$(cat .r-nulls.out); ver nulls 3
  B=$(blk nulls 'B - ' 'A - '); A1=$(blk nulls 'A - ' "A' - "); A2=$(blk nulls "A' - " '')
  SPM=$(printf '%s\n' "$N" | sed -n -E 's/^  its member lines: ([0-9]+) · .*/\1/p')
  DEPN=$(printf '%s\n' "$N" | sed -n -E 's/^  its member lines: [0-9]+ · \$ javap -v \.\.\. \| grep -c Deprecated: ([0-9]+) · RuntimeVisibleAnnotations naming java\/lang\/Deprecated: ([0-9]+)$/\1 \2/p')
  [ -n "$SPM" ] && [ "$SPM" -gt 0 ] && [ -n "$DEPN" ] || die "nulls: javap's member lines and its Deprecated counts"
  for l in '    public static <T> org.springframework.data.jpa.domain.Specification<T> where(org.springframework.data.jpa.domain.Specification<T>);' '    public static <T> org.springframework.data.jpa.domain.Specification<T> unrestricted();' '    public static <T> org.springframework.data.jpa.domain.Specification<T> allOf(java.lang.Iterable<org.springframework.data.jpa.domain.Specification<T>>);' '    public default org.springframework.data.jpa.domain.Specification<T> and(org.springframework.data.jpa.domain.Specification<T>);'; do has "$N" "$l" "nulls: Specification's API, read off the jar"; done
  LINTW=$(printf '%s\n' "$N" | sed -n -E 's/^the harness.s own compile - javac -parameters -Xlint:deprecation .*: exit 0 · its output lines: ([0-9]+) · warnings: ([0-9]+)$/\1 \2/p')
  [ -n "$LINTW" ] || die "nulls: the harness's -Xlint:deprecation compile, its output counted"
  # the deprecation claim the plan expected is refused while javap counts none (the plant "Deprecated claimed")
  if [ "$DEPN" = "0 0" ]; then DC=$($G -niE '\b(is|are|was|were|been|marked|now|gets?|got|stays?) (deprecated|marked deprecated)\b|\bdeprecated (in|since|on|by) |@Deprecated (on|in)' README.md exercise/README.md exercise/SOLUTION.md 2> /dev/null | cut -c1-160 | head -3 | paste -sd';' - || true)
    [ -z "$DC" ] || die "a line says something in Specification is deprecated - javap counts 0 Deprecated attributes in it on Spring Data JPA 4.1.2 (nulls): $DC"; fi
  [ "$LINTW" = "0 0" ] || die "nulls: the harness's -Xlint:deprecation compile prints nothing: $LINTW"
  # B: where(null) - refused at the call, before any SQL (0 statements; the JVM ends exit 0: a call failure, S3.9); class + message (R.241)
  l='Specification.where((Specification<CustomerEntity>) null).and(nameContains("r"))'; two "$B" "$l" 0 "nulls B where(null)"
  NB=$(thr "$(call "$B" "$l")"); [ "$NB" = 'java.lang.IllegalArgumentException: Specification must not be null' ] || die "nulls B: where(null) - java.lang.IllegalArgumentException: Specification must not be null (class, message, no cause - R.241): ${NB:-it did not fail}"
  l='Specification.<CustomerEntity>unrestricted().and((Specification<CustomerEntity>) null)'; two "$B" "$l" 0 "nulls B and(null)"
  NB2=$(thr "$(call "$B" "$l")"); [ "$NB2" = 'java.lang.IllegalArgumentException: Other specification must not be null' ] || die "nulls B: and(null) - java.lang.IllegalArgumentException: Other specification must not be null: ${NB2:-it did not fail}"
  nhas "$B" 'DEBUG org.hibernate.SQL' "nulls B: no SQL at all"
  # A and A': allOf(list) - the filters it has; the same SQL as spec's one-filter search, the same rows, in two fresh JVMs
  l='findAll(Specification.allOf(List.of(nameContains("r"))))'
  for x in "$A1" "$A2"; do two "$x" "$l" 1 "nulls A/A'"; [ "$(sqll "$(call "$x" "$l")")" = "$SELC $W1" ] || die "nulls A/A': allOf(list) - spec's one-filter SQL"; has "$x" '  PROBE result: 3 rows · names, sorted by the harness: [Meera, Priya, Ravi]' "nulls A/A': the rows"; nhas "$x" 'PROBE threw' "nulls A/A': no exception"; done
  [ "$(printf '%s\n' "$A1" | sed 1d)" = "$(printf '%s\n' "$A2" | sed 1d)" ] || die "nulls A': A again prints what A printed (R.1)"
  NA="$SELC $W1"
  echo "  nulls: B where(null) - $NB, and(null) - $NB2, 0 statements, exit 0 (at the call); A and A' allOf(list) - spec's one-filter SQL, the same three rows; Specification's $SPM members, Deprecated ${DEPN% *} (javap -v), the -Xlint:deprecation compile ${LINTW#* } warnings; Spring Data JPA 4.1.2 printed in each JVM"; }
MGN=""; MIX=""; MSRC=""; MCTL=""; MB=""; MAS=""; MNAME=""; MTY=""; MTYE=""
chk_meta() { local M P B A1 A2 C T l
  M=$(cat .r-meta.out); ver meta 3
  P=$(blk meta 'the processor - ' 'the control - '); C=$(blk meta 'the control - ' 'B - '); B=$(blk meta 'B - ' 'A - '); A1=$(blk meta 'A - ' "A' - "); A2=$(blk meta "A' - " 'the metamodel'"'"'s field, typed wrong'); T=$(blk meta 'the metamodel'"'"'s field, typed wrong' '')
  for f in $ENTS; do printf '%s\n' "$P" | $G -qE "^  \\.harness/ents/$f · md5 [0-9a-f]{32} · the anchor's: the same$" || die "meta: .harness/ents/$f must be the anchor's byte for byte (⚑11)"; done
  has "$P" '  exit 0 · what javac printed:' "meta: the processor's javac - exit 0"
  has "$P" '    Note: Hibernate compile-time tooling 7.4.13.Final' "meta: the processor names itself and its version"
  # S3.17 (R.248), RED #902: the generated files - counted by find in this capture, never typed; the control's 0 beside them
  MGN=$(printf '%s\n' "$P" | sed -n -E 's/^  \$ find meta-run\/msrc -type f \| wc -l: ([0-9]+)$/\1/p')
  MIX=$(printf '%s\n' "$P" | sed -n -E 's/^  in its entity\/index folder: ([0-9]+) files · the source files \(\*\.java\): ([0-9]+) · each the same as the build.s: (yes|no)$/\1 \2 \3/p')
  [ -n "$MGN" ] && [ "$MGN" -gt 0 ] || die "meta: the generated files (find meta-run/msrc -type f): ${MGN:-none} - the processor never ran (S3.17/R.248: on the class path alone JDK 25 runs no processor)"
  set -- $MIX; [ $# = 3 ] && [ "$3" = yes ] && [ "$2" = 2 ] && [ $(($1 + $2)) = "$MGN" ] || die "meta: the generated files - $MGN by find = the entity/index files + the two metamodel sources, and the same as the build's: $MIX"
  MSRC="CustomerEntity_.java, PauseEntity_.java"
  for l in '    ./com/tiffinbox/CustomerEntity_.java' '    ./com/tiffinbox/PauseEntity_.java'; do has "$P" "${l/.\//}" "meta: the two metamodel sources"; done
  for l in '    12: @StaticMetamodel(CustomerEntity.class)' '    13: @Generated("org.hibernate.processor.HibernateProcessor")' '    14: public abstract class CustomerEntity_ {'; do has "$P" "$l" "meta: CustomerEntity_ - @StaticMetamodel, @Generated by the processor"; done
  printf '%s\n' "$P" | $G -qE '^    [0-9]+: public static volatile SingularAttribute<CustomerEntity, String> name;$' || die "meta: CustomerEntity_ - public static volatile SingularAttribute<CustomerEntity, String> name"
  MCTL=$(printf '%s\n' "$C" | sed -n -E 's/^  \$ find ctl\/src -type f \| wc -l: ([0-9]+)$/\1/p')
  has "$C" '  exit 0 · what javac printed: 0 lines' "meta: the control - javac exit 0, silent"
  [ "$MCTL" = 0 ] || die "meta: the control - the processor on the class path alone writes nothing (S3.17): $MCTL"
  has "$C" '  the classes it compiled: com/tiffinbox/CustomerEntity.class com/tiffinbox/MealType.class com/tiffinbox/PauseEntity.class' "meta: the control compiles the entities alone - no CustomerEntity_"
  # B: the string's typo compiles and fails at the call (after its marker, 0 statements, exit 0 - S3.9); class, message, first cause
  l='findAll((r, q, cb) -> cb.equal(r.get("nmae"), "Ravi"))'; two "$B" "$l" 0 "meta B"
  MB=$(thr "$(call "$B" "$l")")
  [ "$MB" = "org.springframework.dao.InvalidDataAccessApiUsageException: Could not resolve attribute 'nmae' of 'com.tiffinbox.CustomerEntity' <- org.hibernate.query.sqm.PathElementException: Could not resolve attribute 'nmae' of 'com.tiffinbox.CustomerEntity'" ] || die "meta B: r.get(\"nmae\") at the call - InvalidDataAccessApiUsageException: Could not resolve attribute 'nmae' ... <- PathElementException (class, message, first cause - S3.10/R.241): ${MB:-it did not fail}"
  # A and A': the metamodel's field - filled by Hibernate, the where clause on the name
  l='findAll((r, q, cb) -> cb.equal(r.get(CustomerEntity_.name), "Ravi"))'
  for x in "$A1" "$A2"; do two "$x" "$l" 1 "meta A/A'"; has "$x" '  PROBE CustomerEntity_.name, as Hibernate filled it: com.tiffinbox.CustomerEntity#name(BASIC) · its Java type: java.lang.String' "meta A/A': CustomerEntity_.name filled"
    has "$x" '  PROBE result: 1 rows · names, sorted by the harness: [Ravi]' "meta A/A': Ravi"; done
  MAS=$(sqll "$(call "$A1" "$l")"); [ "$MAS" = "$SELC where ce1_0.name=?" ] || die "meta A: where ce1_0.name=?: $MAS"
  [ "$(printf '%s\n' "$A1" | sed 1d)" = "$(printf '%s\n' "$A2" | sed 1d)" ] || die "meta A': A again prints what A printed (R.1)"
  MNAME='com.tiffinbox.CustomerEntity#name(BASIC)'
  # the javac refusal: CustomerEntity_.nmae - exit 1, cannot find symbol, no class written (the plant "the typo compiled" fails here)
  MTYE=$(printf '%s\n' "$T" | sed -n -E 's/^  exit ([0-9]+) · what javac printed:$/\1/p')
  [ "$MTYE" = 1 ] || die "meta: CustomerEntity_.nmae - javac must refuse it, exit 1: exit ${MTYE:-none}"
  for l in '    harness/src/probe/q/typo/MetaTypo.java:16: error: cannot find symbol' '      symbol:   variable nmae' '      location: class CustomerEntity_' '    1 error' '  the classes it wrote: 0'; do has "$T" "$l" "meta: javac's refusal"; done
  MTY="harness/src/probe/q/typo/MetaTypo.java:16: error: cannot find symbol · symbol: variable nmae · location: class CustomerEntity_"
  echo "  meta: the processor (-proc:full -processorpath, $PPN jars) - $MGN files by find ($MSRC + ${MIX%% *} in entity/index), the control on the class path alone 0; B r.get(\"nmae\") compiles, at the call: $MB; A and A' CustomerEntity_.name ($MNAME) - where ce1_0.name=?, [Ravi]; CustomerEntity_.nmae - javac exit $MTYE, cannot find symbol"; }
chk_xcheck() { local XC
  XC=$(cat .r-xcheck.out)
  for l in "$VERH" '  INFO  org.springframework.data.repository.config.RepositoryConfigurationDelegate : Finished Spring Data repository scanning in <n> ms. Found 0 JPA repository interfaces.' "  exit 0 · 'GenerationTarget encountered exception': 0"; do has "$XC" "$l" "xcheck: the entities alone, no repository, a clean start"; done
  [ "$(cnt "$XC" "  its md5: $X09 · the owning-side lesson's (its README names it $($G -c "$X09" ../c7-unit09/README.md || true) times; its xcheck published $X09CAP): $X09 · the same: yes")" = 1 ] || die "xcheck: the harness's script must be Boot's for the anchor's entities, md5 $X09 (R.212) - a mapping moved"
  [ "$(printf '%s\n' "$XC" | $G -c '^    create table \|^    alter table ' || true)" = 3 ] || die "xcheck: two create table lines and one alter table"
  echo "  xcheck: the harness's script (@EntityScan(\"com.tiffinbox\") alone), md5 $X09 = the owning-side lesson's - no mapping moved"; }
EXQ="Your turn: the README's search passes a filter it does not have, and Spring Data four refuses it. Combine the filters it has."
EXW=$(printf '%s\n' "$EXQ" | wc -w | tr -d ' ')
EXS=""; EXSQL=""; EXT=""
chk_exercise() { local EXB EXZ b ER ES f w
  EXB=$(blk exercise "in bash" "in zsh"); EXZ=$(blk exercise "in zsh" "")
  for b in "$EXB" "$EXZ"; do
    ER=$(printf '%s\n' "$b" | sed '/then the solution/,$d'); ES=$(printf '%s\n' "$b" | sed -n '/then the solution/,$p')
    for l in '    the JVM: exit 1' '    Found 1 JPA repository interface.'; do has "$ER" "$l" "exercise: the README - the search fails"; done
    # the same refusal nulls B shows (class and message, R.241) - read here off the exercise's own chain, nothing else
    [ "$(printf '%s\n' "$ER" | $G -E '^    PROBE (threw|caused by): ' | paste -sd'|' -)" = "    PROBE threw: $NB" ] || die "exercise: the README's run must fail with nulls B's refusal and nothing else - $NB"
    nhas "$ER" 'org.hibernate.SQL' "exercise: the README's run sends no SQL"; nhas "$ER" 'PROBE customers' "exercise: the README never gets its rows"
    EXT=$(printf '%s\n' "$ER" | sed -n 's/^    PROBE threw: //p')
    EXSQL=$(printf '%s\n' "$ES" | sed -n 's/^    org\.hibernate\.SQL : //p'); EXS=$(printf '%s\n' "$ES" | sed -n 's/^    PROBE customers: //p')
    for l in '    the JVM: exit 0' '    Found 1 JPA repository interface.' '    PROBE customers: [Ravi]'; do has "$ES" "$l" "exercise: the solution - allOf(filters), the customers it finds"; done
    [ "$EXSQL" = "$SELC $W1 and ce1_0.meals_per_day>=?" ] || die "exercise: the solution's SQL - spec's name condition and the meals condition, no meal type: $EXSQL"
    nhas "$ES" 'PROBE threw' "exercise: the solution runs"
    [ "$(printf '%s\n' "$b" | $G -c "^  the shell is now in: this unit's folder")" = 2 ] || die "exercise: the shell back in this folder"; done
  [ "$(printf '%s\n' "$EXB" | $G -v '^in ')" = "$(printf '%s\n' "$EXZ" | $G -v '^in ')" ] || die "exercise: bash and zsh print the same"
  # each file's "What it prints" block is what the run printed, line for line (never a placeholder: unit 16 shipped two)
  w=$(printf '%s\n' "$EXB" | sed '/then the solution/,$d' | sed -n '/^  the block.s exit /,/^  the shell is now in: /p' | sed '1d;$d' | sed 's/^    //')
  [ "$(wib exercise/README.md)" = "$w" ] || die "exercise/README.md's \"What it prints\" block is not what the README's lines printed: $(diff <(wib exercise/README.md) <(printf '%s\n' "$w") | head -3 | paste -sd' ' -)"
  w=$(printf '%s\n' "$EXB" | sed -n '/then the solution/,$p' | sed -n '/then the solution/,/^  the shell is now in: /p' | sed '1d;$d' | sed 's/^    //')
  [ "$(wib exercise/SOLUTION.md)" = "$w" ] || die "exercise/SOLUTION.md's \"What it prints\" block is not what the solution's lines printed: $(diff <(wib exercise/SOLUTION.md) <(printf '%s\n' "$w") | head -3 | paste -sd' ' -)"
  $G -qxF -- "**Your turn:** ${EXQ#Your turn: }" exercise/README.md || die "exercise/README.md: the spoken exercise line"
  [ "$EXW" -le 25 ] || die "exercise: the spoken line is at most 25 words (R.203): $EXW"
  $G -qF 'Specification<CustomerEntity> spec = Specification.where(byType).and(byName).and(byMeals);' harness/src/probe/q/ex/ExApp.java && $G -qF 'Specification<CustomerEntity> byType = null;' harness/src/probe/q/ex/ExApp.java || die "exercise: ExApp ships the old idiom - where(byType), byType null"
  echo "  exercise: bash and zsh alike - the README as written (where(byType) with no meal type given): exit 1, Found 1, $EXT, no SQL; the solution (one line: Specification.allOf(filters)): exit 0, the name and meals conditions, $EXS; each file's What it prints = the run; $EXW words"; }
cap spec spec; chk_spec; pub spec
cap nulls nulls; chk_nulls; pub nulls
cap meta meta; chk_meta; pub meta
cap xcheck xcheck; chk_xcheck; pub xcheck
cap exercise exercise; chk_exercise; pub exercise
# the derived lesson's like, beside the Criteria one (the brief's hazard): read off its README, its like capture published
D16="findByNameContainingIgnoreCase(\"r\")"
DESC=$($G -m1 -F -- "| \`$D16\` |" ../c7-unit16/README.md 2> /dev/null | $G -oF "escape '\\'" | head -1 || true)
[ "$DESC" = "escape '\\'" ] && [ "$(awk '$1 == "derived" { print $2 }' ../c7-unit16/receipts.md5 2> /dev/null)" = 314e79d6305573120462d7a215f3557d ] || die "the derived-query lesson's README must give its $D16 row ending escape '\\', its derived capture published"
DERH=$(awk '$1 == "derived" { print $2 }' ../c7-unit16/receipts.md5)
# the values the video says are the captures', never typed: README.md states them in one line, composed here from what the checks read
VS="the values the video may say: the search, $QN calls, README.md's table composed from spec - none, one, two, three filters: one SELECT each · allOf(list) = unrestricted().and(...): $WEQ · count(spec): $CNTS -> $CNTR · findAll(spec, PageRequest.of(0, 1, Sort.by(\"name\"))): 2 statements, $PGR · the Criteria like writes $CRESC (spec), the derived Containing wrote $DESC (the derived-query lesson's table, its derived capture $DERH) · where(null), on Spring Data JPA 4.1.2: $NB, 0 statements; and(null): $NB2 · allOf(list): $NA · Specification: $SPM members, ${DEPN% *} Deprecated (javap -v), the -Xlint:deprecation compile ${LINTW#* } warnings · the processor, hibernate-processor 7.4.13.Final with -proc:full -processorpath ($PPN jars): $MGN files by find - $MSRC and ${MIX%% *} in entity/index; on the class path alone: $MCTL · r.get(\"nmae\"), at the call: $MB · r.get(CustomerEntity_.name): $MAS · CustomerEntity_.nmae: javac exit $MTYE, $MTY · xcheck: $X09 · exercise: $EXT; allOf(filters): $EXSQL, $EXS ($EXW words)"
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
echo "  ports: nothing listens on 18425, 8080, 35729 or 19970-19979 at the end - this unit bound none; 19979 never bound"
[ -z "$unpub" ] || die "no published hash for:$unpub - check the captures, then copy the md5s above into receipts.md5 and run again"
echo "c7-unit18: every capture 3/3 and = published; every spoken number asserted; no port bound"
