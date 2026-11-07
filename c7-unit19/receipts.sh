#!/bin/bash
XPATH=$PATH                                           # the PATH you started this with: the exercise's own shells get it
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25.0.4.1 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# Course 7 · Projections: Four Kinds - this unit's receipts. No change to the anchor (brief ⚑11): anchor/ is the link to
# ../c7-unit17/after, Section 3's frozen anchor. The same derived query - the customers of one meal type - returning a closed
# interface, an open one, a record and a type picked per call; a nested projection; the refused fifth, Tuple and Object[].
# Whether the SELECT shrinks is read off the SQL logger's own line - its column list - and Hibernate's entity load count, both,
# for every call (S3.8: a projection claim has two witnesses). Five captures, each run three times and hashed; a hash that
# differs from receipts.md5 stops the run; every number and string the video says is asserted right after its capture by a
# check that can fail. One database: H2 (brief ⚑2), in each JVM's memory, gone with it. No TiffinBox runs here.
#   four      the four kinds (a harness JVM): findNamesByMealType (closed NameAndType), findLabelsByMealType (open Label, @Value),
#             findDtosByMealType (the record NameDto), findByMealType(type, Class<T>) with NameAndType, NameDto and
#             CustomerEntity - each call's SELECT, its column list counted from the line itself, its entity loads from
#             Statistics, the class of what came back; "four SELECTs" counted as the SELECT lines of the first four calls (R.187)
#   nested    the nested projection WithPauses (three harness JVMs: B, A, A'): B outside a transaction - the
#             LazyInitializationException, class and message as captured; A inside one TransactionTemplate - 1 + one SELECT per
#             customer, the statement count read off the log and Statistics; A' = A in a fresh JVM
#   tuple     the refused fifth (a harness JVM): Tuple and Object[] from a JPQL query with aliases, read by alias and by
#             position, beside the closed interface - the three SQL lines byte for byte equal
#   xcheck    the harness's DDL script (@EntityScan("com.tiffinbox") alone, scripts.action=create) against the owning-side
#             lesson's published md5: no mapping moved (R.212, brief ⚑3)
#   exercise  exercise/README.md's commands, then exercise/SOLUTION.md's, read from the files and run as written, in ONE env -i
#             shell - /bin/bash, then again in /bin/zsh -f; each file's "What it prints" block = what it printed
# No anchor change: anchor/ is the link to ../c7-unit17/after. It equals ../c7-tiffinbox until a later unit changes the anchor -
# printed at the start and the end, a note then, never a stop (R.211). The anchor is COPIED under .harness/anchor and built
# there, never in place (its README's package line, offline; its tests run); its jar extracted (the anchor's own line).
# The harness (harness/src, packages probe.q and probe.x, outside com.tiffinbox) is compiled against the anchor's extracted
# libraries with javac -parameters into .harness/hc. probe.q.Main is a Spring Boot context with no web server
# (WebApplicationType.NONE: it binds no port) over the anchor's libraries, @EntityScan on com.tiffinbox - the anchor's entities -
# and @EnableJpaRepositories on probe.q.repo, the harness's own interface (Customers: a JpaRepository of CustomerEntity with the
# projection methods) and its projection types; probe.q.Seed builds the shipped Database in code on the run's own H2 database,
# which seeds it; Hibernate writes no schema (ddl-auto none), its statistics are on; Logback (harness/logback.xml) prints
# Hibernate's SQL logger, its HHH000001 line, the EntityManagerFactory's line and Spring Data's scan line. probe.x.XMain is
# xcheck's context (the entities alone). Each runs from .harness/run. Its JVM flags travel as an array, V, its arguments as an
# array, A (R.193). Every JVM this script starts - the harness's and the exercise's - runs under an alarm (perl -e 'alarm N;
# exec ...': macOS has no timeout); an alarm that fires is a failed receipt (R.247). Commands are printed exactly as they run:
# each goes through eval. harness/dur7.py (Course 7's builders' duration pattern, byte for byte) gates this unit's prose: it
# speaks no time (R.172). "$M2" is this unit's own repository, .m2-demo.
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
# Ports (§P, 19980-19989): this unit binds none. All ten, and 18425 (TiffinBox's default), 8080 and 35729, are checked free at the
# start and the end; 19989 is the one the brief names "never bound".
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
javac -version 2>&1 | $G -q '^javac 25' || die "javac 25 needed (the harness is compiled with it)"
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
XD=tiffinbox-web/target/extracted                    # the jar, extracted (the anchor's own line), in a tree
HS=harness/src/probe/q
HFILES='dur7.py logback.xml src'
SFILES='probe/q/Main.java probe/q/Run.java probe/q/Seed.java probe/q/ex/ExApp.java probe/q/repo/Customers.java probe/q/repo/Label.java probe/q/repo/NameAndType.java probe/q/repo/NameDto.java probe/q/repo/WithPauses.java probe/x/XMain.java'
for f in exercise/README.md exercise/SOLUTION.md README.md receipts.md5; do [ -f "$f" ] || die "$f is missing"; done
[ "$(ls harness | paste -sd' ' -)" = "$HFILES" ] && [ "$(cd harness/src && find . -type f | sed 's#^\./##' | sort | paste -sd' ' -)" = "$SFILES" ] || die "harness/ holds another file, or misses one"
[ "$(ls exercise | paste -sd' ' -)" = 'README.md SOLUTION.md' ] || die "exercise/ holds another file"
[ "$(md5 -q harness/dur7.py)" = 41667fed9ffcefe171389eed7e654e66 ] || die "harness/dur7.py is not the builders' dur7.py (md5 41667fed…)"
if [ -f ../../../data-jpa-hibernate/_builders/dur7.py ]; then cmp -s harness/dur7.py ../../../data-jpa-hibernate/_builders/dur7.py || die "harness/dur7.py differs from the builders' ../../../data-jpa-hibernate/_builders/dur7.py"
  echo "  (terminal only) harness/dur7.py = the builders' _builders/dur7.py, byte for byte" >&3
else echo "  (terminal only) the builders' _builders/dur7.py is not beside this clone: its md5 above is the check" >&3; fi
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
PORTS="18425 8080 35729 19980 19981 19982 19983 19984 19985 19986 19987 19988 19989"
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
# R.225, R.227: a SQL string this unit shows is the logger's, composed into README.md's projection table and its values line by
# this script - a line of README.md holding Hibernate's aliases (ce1_0., p1_0.) anywhere else is a typed SQL string, refused
TS=$($G -nE 'ce1_0\.|p1_0\.' README.md exercise/README.md exercise/SOLUTION.md 2> /dev/null | $G -vE '^([a-zA-Z/.]+:)?[0-9]+:\| [a-z]+ \| `' | $G -vF 'the values the video may say:' | $G -vE '^exercise/[A-Z]+\.md:[0-9]+:org\.hibernate\.SQL : ' | cut -c1-160 | head -3 | paste -sd';' - || true)
[ -z "$TS" ] || die "a typed SQL string outside README.md's composed table and values line and the exercise's measured blocks (R.225, R.227): $TS"
echo "  typed SQL strings: 0 outside README.md's composed table and values line and the exercise's measured blocks"
# S3.8 (R.239), R.225: a column count is the SELECT line's own column list, counted by this script. A count of columns typed in
# the prose is refused - unless the line names the projection it is about (closed, open, record, dynamic, entity, nested,
# tuple): such a line is a claim, and after four it is held against both witnesses, the SELECT's list and the entity loads
NUMW='one|two|three|four|five|six|seven|eight|nine|ten|[0-9]+'
KINDS='closed|open|record|dto|dynamic|entity|nested|tuple'
TC=$($G -niE "\\b($NUMW) columns?\\b" README.md exercise/README.md exercise/SOLUTION.md 2> /dev/null | $G -vF 'the values the video may say:' | $G -vE '^([a-zA-Z/.]+:)?[0-9]+:\| [a-z]+ \| `' | $G -viE "\\b($KINDS)\\b[^.]{0,80}\\b($NUMW) columns?\\b" | cut -c1-160 | head -3 | paste -sd';' - || true)
[ -z "$TC" ] || die "a typed count of columns - the SELECT line's own list is counted by four, and only the values line and the table state it (S3.8/R.239, R.225): $TC"
echo "  typed column counts: 0 (a count that names its projection is held against four's two witnesses after it)"

# ---- the commands: read from anchor/README.md, the anchor's own, and asserted - each line must be there, whole -------------
readme() { $G -m1 -xF -- "$1" anchor/README.md > /dev/null || die "anchor/README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
R_PLAIN=$(readme 'mvn -B package')
R_EXTRACT=$(readme 'java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted')
# This unit's own lines (README.md, "The commands this unit adds") - each asserted to be exactly that
mine() { $G -m1 -xF -- "$1" README.md > /dev/null || die "README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
JL='-Duser.language=en -Duser.country=US'
AL="perl -e 'alarm 240; exec @ARGV'"
L_JAVAC=$(mine "javac -parameters -d .harness/hc -cp \".harness/anchor/$XD/lib/*\" $HS/Main.java $HS/Run.java $HS/Seed.java $HS/repo/Customers.java $HS/repo/Label.java $HS/repo/NameAndType.java $HS/repo/NameDto.java $HS/repo/WithPauses.java harness/src/probe/x/XMain.java")
L_H=$(mine "$AL java $JL -Dstdout.encoding=UTF-8 \"\${V[@]}\" -cp \"../hc:../anchor/$XD/lib/*\" probe.q.Main \"\${A[@]}\"")
L_X=$(mine "$AL java $JL -Dstdout.encoding=UTF-8 -cp \"../hc:../anchor/$XD/lib/*\" probe.x.XMain \"\${A[@]}\"")
off() { local c=${2/mvn -B /mvn -o -B -Dmaven.repo.local=\"\$M2\" }
  [ -n "${3:-}" ] && c=${c/ $3/ clean $3}
  printf 'cd %s && %s\n' "$1" "$c"; }
exe() { printf '%s\n' "$1" | sed -E 's/&& (([A-Z_]+=[^ ]* )*)/\&\& \1exec /'; }
[ "$(off .harness/anchor "$R_PLAIN" package)" = 'cd .harness/anchor && mvn -o -B -Dmaven.repo.local="$M2" clean package' ] || die "off(): the build line is not the anchor README's package line, offline"
echo "  the commands: anchor/README.md gives the $($G -c '^R_[A-Z]*=$(readme ' receipts.sh) lines this script runs; README.md the $($G -c '^L_[A-Z0-9]*=$(mine ' receipts.sh) this unit adds"
JV=$(java -version 2>&1 | sed -n 's/.*version "\([^"]*\)".*/\1/p' | head -1)
echo "  (terminal only) the JDK is $JV - the captures say Java <version>" >&3

# ---- build: before the captures - the anchor copied and built with its README's package line offline (its tests run); its jar
# ---- extracted (the anchor's line); the harness compiled against its libraries ---------------------------------------------
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
for a in org/springframework/boot/spring-boot-starter-parent/4.1.2/spring-boot-starter-parent-4.1.2.pom org/hibernate/orm/hibernate-core/7.4.13.Final/hibernate-core-7.4.13.Final.jar org/springframework/data/spring-data-jpa/4.1.2/spring-data-jpa-4.1.2.jar com/h2database/h2/2.5.250/h2-2.5.250.jar; do
  [ -e "$M2/$a" ] || die "$a is not in .m2-demo - README.md, The repository"; done
jc "$L_JAVAC" .harness/javac.log
[ "$JE" = 0 ] || die "the harness did not compile: $(head -5 .harness/javac.log)"
[ ! -e .harness/hc/probe/q/ex ] || die "the exercise's class was compiled into the harness - it is compiled on its own"
echo "  extracted the anchor's jar ($(ls .harness/anchor/$XD/lib | wc -l | tr -d ' ') libraries); the harness compiled into .harness/hc ($(find .harness/hc -name '*.class' | wc -l | tr -d ' ') classes)"

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
HA=('--spring.datasource.url=jdbc:h2:mem:u19;DB_CLOSE_DELAY=-1' --logging.config=../../harness/logback.xml --spring.jpa.hibernate.ddl-auto=none --spring.main.banner-mode=off --spring.thymeleaf.check-template-location=false --spring.jpa.properties.hibernate.generate_statistics=true)
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

# ---- four: the four kinds - closed, open, record, dynamic three ways; the same rows, each call's SELECT and entity loads ---------
four() { echo "the four kinds - one harness JVM (.harness/hc):"
  V=(-Ds=four); A=("${HA[@]}"); hrun; hview; }

# ---- nested: WithPauses - B outside a transaction (the failure receipt), A and A' inside one TransactionTemplate -----------------
nested() {
  echo "B - findWithPausesByMealType(VEG), then each getPauses(), no transaction (one harness JVM, .harness/hc):"
  V=(-Ds=nested -Dv=B); A=("${HA[@]}"); hrun; hview
  echo "A - the same, inside one TransactionTemplate (one harness JVM):"
  V=(-Ds=nested -Dv=A); A=("${HA[@]}"); hrun; hview
  echo "A' - A again, in a fresh JVM:"
  V=(-Ds=nested -Dv=A); A=("${HA[@]}"); hrun; hview; }

# ---- tuple: the refused fifth - Tuple and Object[] from a JPQL query with aliases, beside the closed interface ---------------------
tuple() { echo "the refused fifth - one harness JVM (.harness/hc):"
  V=(-Ds=tuple); A=("${HA[@]}"); hrun; hview; }

# ---- xcheck: the harness's DDL for the anchor's two entities against Boot's, as the owning-side lesson captured it --------------
X09=f595637014e786fa38606859951e4f97                # Boot's script for CustomerEntity + PauseEntity, as ../c7-unit09's xcheck captured it (R.212)
X09CAP=9072c6f11c8c8e713c997b58d3a79d74             # ../c7-unit09's published xcheck capture
[ "$($G -c "$X09" ../c7-unit09/README.md || true)" -gt 0 ] || die "../c7-unit09/README.md must name $X09 - Boot's script md5 (R.212)"
[ "$(awk '$1 == "xcheck" { print $2 }' ../c7-unit09/receipts.md5)" = "$X09CAP" ] || die "../c7-unit09/receipts.md5's xcheck is not $X09CAP - the capture that holds Boot's script"
XA=('--spring.datasource.url=jdbc:h2:mem:x19;DB_CLOSE_DELAY=-1' --logging.config=../../harness/logback.xml --spring.jpa.hibernate.ddl-auto=none --spring.main.banner-mode=off --spring.thymeleaf.check-template-location=false --spring.jpa.properties.jakarta.persistence.schema-generation.scripts.action=create --spring.jpa.properties.jakarta.persistence.schema-generation.scripts.create-target=hibernate-ddl.sql)
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
DBL='  PROBE database: H2 2.5.250 (2026-08-29) | url jdbc:h2:mem:u19;DB_CLOSE_DELAY=-1'
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
# cols SQL: the SELECT's column list - between "select " and " from " - and its count, counted from the line itself (S3.8)
clist() { printf '%s\n' "$1" | sed -n 's/^select \(.*\) from customer ce1_0.*/\1/p'; }
ccount() { clist "$1" | tr ',' '\n' | $G -c . || true; }
loads() { printf '%s\n' "$1" | sed -n 's/^  PROBE <<< .* · entity loads \([0-9]*\) · queries [0-9]*$/\1/p'; }
WHERE='where ce1_0.meal_type=?'
VEGR='sorted by the harness: [Ravi VEG, Sunil VEG]'
# the README's projection table: one row per call - the kind, the call, the column list Hibernate's logger printed, its count,
# the entity loads, the class that came back - composed from four, never typed
PROWS=""; PN=0
prow() { PROWS="$PROWS| $1 | \`$2\` | \`$3\` | $4 | $5 | \`$6\` |
"; PN=$((PN + 1)); }
CLC=""; CLN=""; OPN=""; OPL=""; REN=""; DYN=""; FOURN=""; CLSQL=""; OPSQL=""; CLL=""; REL=""; OPC=""
chk_four() { local F l b s n ld r k cls kind exp i
  F=$(cat .r-four.out); ver four 1
  i=0
  for l in 'findNamesByMealType(VEG) - a closed interface, NameAndType|closed|2|0|jdk.proxy2.$Proxy<n>|true|Ravi VEG, Sunil VEG' \
           'findLabelsByMealType(VEG) - an open interface, Label|open|5|2|jdk.proxy2.$Proxy<n>|true|Ravi VEG, Sunil VEG' \
           'findDtosByMealType(VEG) - a record, NameDto|record|2|0|probe.q.repo.NameDto|false|NameDto[name=Ravi, mealType=VEG], NameDto[name=Sunil, mealType=VEG]' \
           'findByMealType(VEG, NameAndType.class) - dynamic|dynamic|2|0|jdk.proxy2.$Proxy<n>|true|Ravi VEG, Sunil VEG' \
           'findByMealType(VEG, NameDto.class) - dynamic|dynamic|2|0|probe.q.repo.NameDto|false|NameDto[name=Ravi, mealType=VEG], NameDto[name=Sunil, mealType=VEG]' \
           'findByMealType(VEG, CustomerEntity.class) - dynamic|dynamic|5|2|com.tiffinbox.CustomerEntity|false|Ravi VEG, Sunil VEG'; do
    k=${l%%|*}; exp=${l#*|}; kind=${exp%%|*}
    b=$(call "$F" "$k"); two "$F" "$k" 1 "four $k"
    s=$(sqll "$b"); n=$(ccount "$s"); ld=$(loads "$b"); r=$(res "$b")
    case "$s" in "select "*" from customer ce1_0 $WHERE") ;; *) die "four $k: one SELECT from customer, where on the meal type: $s" ;; esac
    cls=$(printf '%s\n' "$r" | sed -n -E 's/^2 rows · element class: (.*) · a JDK proxy: (true|false) · sorted by the harness: \[.*\]$/\1|\2/p')
    [ "$kind|$n|$ld|$cls|$(printf '%s\n' "$r" | sed -n 's/.* · sorted by the harness: \[\(.*\)\]$/\1/p')" = "$exp" ] || die "four $k: the column list ($n, counted from the SELECT line), the entity loads ($ld, Statistics), the class that came back and the rows - S3.8's two witnesses: expected $exp, read $kind|$n|$ld|$cls|$r"
    prow "$kind" "${k%% - *}" "$(clist "$s")" "$n" "$ld" "${cls%|*}"
    case $i in 0) CLSQL=$s; CLN=$n; CLL=$ld; CLC=$(clist "$s") ;; 1) OPSQL=$s; OPN=$n; OPL=$ld ;; 2) REN=$n; REL=$ld ;; 3) DYN=$n ;; 4) DYN="$DYN / $n" ;; 5) DYN="$DYN / $n" ;; esac
    i=$((i + 1)); done
  # the hook: the closed interface asks for the name and the meal type alone; the open one for every column the entity maps
  [ "$CLC" = 'ce1_0.name,ce1_0.meal_type' ] || die "four: the closed interface's column list - ce1_0.name,ce1_0.meal_type: $CLC"
  [ "$OPSQL" = "$SELC $WHERE" ] || die "four: the open interface's SELECT - every column the entity maps: $OPSQL"
  # "four SELECTs" (R.187): the SELECT lines the first four calls logged - closed, open, record, dynamic with one type - counted
  FOURN=0; for l in 'findNamesByMealType(VEG) - a closed interface, NameAndType' 'findLabelsByMealType(VEG) - an open interface, Label' 'findDtosByMealType(VEG) - a record, NameDto' 'findByMealType(VEG, NameAndType.class) - dynamic'; do
    FOURN=$((FOURN + $(sqll "$(call "$F" "$l")" | $G -c '^select ' || true))); done
  [ "$FOURN" = 4 ] || die "four: the SELECT lines of the four calls - closed, open, record, dynamic with one type (R.187): $FOURN"
  # S3.8 (R.239): a line of the prose that states a column count for a projection is held against both witnesses of that kind
  local CL c w num want ldv
  CL=$($G -niE "\\b($KINDS)\\b[^.]{0,80}\\b($NUMW) columns?\\b" README.md exercise/README.md exercise/SOLUTION.md 2> /dev/null | $G -vF 'the values the video may say:' | $G -vE '^([a-zA-Z/.]+:)?[0-9]+:\| [a-z]+ \| `' || true)
  while IFS= read -r c; do [ -n "$c" ] || continue
    w=$(printf '%s\n' "$c" | perl -ne 'print lc("$1 $2"), "\n" if /\b(closed|open|record|dto|dynamic|entity|nested|tuple)\b[^.]{0,80}?\b(one|two|three|four|five|six|seven|eight|nine|ten|[0-9]+) columns?\b/i' | head -1)
    [ -n "$w" ] || die "a column count the claim check cannot read (S3.8): $(printf '%s\n' "$c" | cut -c1-160)"
    num=${w#* }; case $num in one) num=1 ;; two) num=2 ;; three) num=3 ;; four) num=4 ;; five) num=5 ;; six) num=6 ;; seven) num=7 ;; eight) num=8 ;; nine) num=9 ;; ten) num=10 ;; esac
    case ${w%% *} in closed) want=$CLN; ldv=$CLL ;; open) want=$OPN; ldv=$OPL ;; record|dto) want=$REN; ldv=$REL ;; *) die "a column count said of the ${w%% *} projection - the dynamic one follows its type, and the others are not counted here: name the kind (S3.8): $(printf '%s\n' "$c" | cut -c1-160)" ;; esac
    [ "$num" = "$want" ] && { [ "$want" = 2 ] && [ "$ldv" = 0 ] || [ "$want" != 2 ]; } || die "a line says the ${w%% *} projection selects $num columns - S3.8's two witnesses contradict it: the SELECT's column list $want (four), entity loads $ldv (Statistics): $(printf '%s\n' "$c" | cut -c1-160)"
  done <<< "$CL"
  # the README's table: the rows after its marker line, to the first line that is not a row, must be these, in this order
  [ "$(awk '/^<!-- four: the projection table/ { f = 1; next } f && /^\| [a-z]+ \| `/ { print; next } f && /^\|/ { next } f { exit }' README.md)" = "$(printf '%s' "$PROWS")" ] || die "README.md's projection table is not the capture's - each row is composed from four (kind | call | column list | count | entity loads | class), never typed: $(diff <(awk '/^<!-- four: the projection table/ { f = 1; next } f && /^\| [a-z]+ \| `/ { print; next } f && /^\|/ { next } f { exit }' README.md) <(printf '%s' "$PROWS") | head -4 | paste -sd' ' -)"
  echo "  four: the same rows ($VEGR) six ways - closed $CLN columns / $CLL loads, a JDK proxy; open $OPN / $OPL; record $REN / $REL; dynamic $DYN - each count from the SELECT line itself, each load count from Statistics; $FOURN SELECT lines from the four calls; README.md's table = these $PN rows; H2"; }
NB=""; NBK=""; NAN=""; NAS=""; NAP=""; NAL=""
chk_nested() { local N B A1 A2 l x s n st
  N=$(cat .r-nested.out); ver nested 3
  B=$(blk nested 'B - ' 'A - '); A1=$(blk nested 'A - ' "A' - "); A2=$(blk nested "A' - " '')
  for x in "$B" "$A1" "$A2"; do has "$x" '  PROBE pause (id | customer_id | days), read by a second connection: [1 | 3 | 3, 2 | 4 | 2]' "nested: the seed's two pauses"; done
  # B: outside a transaction - the customers' SELECT, then the first getPauses() fails: class, message, first cause as captured (R.241)
  l='findWithPausesByMealType(VEG), then each getPauses() - no transaction'; [ -n "$(call "$B" "$l")" ] || die "nested B: no call named $l"
  NB=$(thr "$(call "$B" "$l")")
  printf '%s\n' "$NB" | $G -qxE "org\\.hibernate\\.LazyInitializationException: Cannot lazily initialize collection of role 'com\\.tiffinbox\\.CustomerEntity\\.pauses' with key '[0-9]+' \\(no session\\)" || die "nested B: outside a transaction the first getPauses() must fail - org.hibernate.LazyInitializationException: Cannot lazily initialize collection of role 'com.tiffinbox.CustomerEntity.pauses' with key '…' (no session), no cause (S3.10/R.241): ${NB:-it did not fail}"
  NBK=$(printf '%s\n' "$NB" | sed -n "s/.* with key '\\([0-9]*\\)' .*/\\1/p")
  two "$B" "$l" 1 "nested B (the customers' SELECT, then the failure)"
  [ "$(sqll "$(call "$B" "$l")")" = "$SELC $WHERE" ] || die "nested B: its one statement is the customers' SELECT, every column"
  # A and A': inside one TransactionTemplate - 1 + one SELECT per customer, by the log and by Statistics
  l='findWithPausesByMealType(VEG), then each getPauses() - inside one TransactionTemplate'
  for x in "$A1" "$A2"; do
    n=$(res "$(call "$x" "$l")" | sed -n 's/^\([0-9]*\) rows · .*/\1/p'); [ -n "$n" ] && [ "$n" -gt 0 ] || die "nested A/A': the customers it returned"
    two "$x" "$l" $((1 + n)) "nested A/A' (1 + one per customer, $n customers)"
    s=$(sqll "$(call "$x" "$l")")
    [ "$(printf '%s\n' "$s" | sed -n 1p)" = "$SELC $WHERE" ] && [ "$(printf '%s\n' "$s" | sed 1d | sort -u)" = 'select p1_0.customer_id,p1_0.id,p1_0.days from pause p1_0 where p1_0.customer_id=?' ] && [ "$(printf '%s\n' "$s" | sed 1d | $G -c . || true)" = "$n" ] || die "nested A/A': the customers' SELECT, then one pause SELECT per customer: $(printf '%s\n' "$s" | paste -sd'|' -)"
    has "$x" '  PROBE result: 2 rows · element class: jdk.proxy2.$Proxy<n> · a JDK proxy: true · sorted by the harness: [Ravi [], Sunil [3]]' "nested A/A': Ravi with no pause, Sunil with one of three days"
    nhas "$x" 'PROBE threw' "nested A/A': no exception"; done
  [ "$(printf '%s\n' "$A1" | sed 1d)" = "$(printf '%s\n' "$A2" | sed 1d)" ] || die "nested A': A again prints what A printed (R.1)"
  NAN=$n; NAS=$((1 + n)); NAP=$(printf '%s\n' "$s" | sed -n 2p); NAL=$(loads "$(call "$A1" "$l")")
  echo "  nested: B outside a transaction - $NB, after 1 statement, exit 0 (at the call); A and A' in a TransactionTemplate - 1 + $NAN SELECTs = $NAS statements (log and Statistics), [Ravi [], Sunil [3]]"; }
TUA=""; TUL=""; TUSQL=""
chk_tuple() { local T c t a
  T=$(cat .r-tuple.out); ver tuple 1
  c='findNamesByMealType(VEG) - a closed interface, NameAndType'; t='tuplesByMealType(VEG) - Tuple, read by alias'; a='arraysByMealType(VEG) - Object[], read by position'
  two "$T" "$c" 1 "tuple closed"; two "$T" "$t" 1 "tuple Tuple"; two "$T" "$a" 1 "tuple Object[]"
  TUSQL=$(sqll "$(call "$T" "$t")")
  [ "$TUSQL" = "$(sqll "$(call "$T" "$c")")" ] && [ "$(sqll "$(call "$T" "$a")")" = "$TUSQL" ] && [ "$TUSQL" = "$CLSQL" ] || die "tuple: Tuple's and Object[]'s SQL must be the closed interface's, byte for byte (and four's): $TUSQL | $(sqll "$(call "$T" "$c")") | $(sqll "$(call "$T" "$a")")"
  for x in "$t" "$a"; do [ "$(loads "$(call "$T" "$x")")" = 0 ] || die "tuple: $x loads no entity"; done
  has "$T" '  PROBE the aliases of the first tuple: [name, mealType]' "tuple: read by alias"
  has "$T" '  PROBE the length of the first array: 2' "tuple: read by position"
  has "$T" '  PROBE result: 2 rows · element class: org.hibernate.sql.results.internal.TupleImpl · a JDK proxy: false · sorted by the harness: [Ravi VEG, Sunil VEG]' "tuple: Tuple's rows"
  has "$T" '  PROBE result: 2 rows · element class: [Ljava.lang.Object; · a JDK proxy: false · sorted by the harness: [Ravi VEG, Sunil VEG]' "tuple: Object[]'s rows"
  TUA='[name, mealType]'; TUL=2
  echo "  tuple: Tuple (aliases $TUA) and Object[] (length $TUL) - the closed interface's SQL byte for byte, loads 0, the same rows"; }
chk_xcheck() { local XC
  XC=$(cat .r-xcheck.out)
  for l in "$VERH" '  INFO  org.springframework.data.repository.config.RepositoryConfigurationDelegate : Finished Spring Data repository scanning in <n> ms. Found 0 JPA repository interfaces.' "  exit 0 · 'GenerationTarget encountered exception': 0"; do has "$XC" "$l" "xcheck: the entities alone, no repository, a clean start"; done
  [ "$(cnt "$XC" "  its md5: $X09 · the owning-side lesson's (its README names it $($G -c "$X09" ../c7-unit09/README.md || true) times; its xcheck published $X09CAP): $X09 · the same: yes")" = 1 ] || die "xcheck: the harness's script must be Boot's for the anchor's entities, md5 $X09 (R.212) - a mapping moved"
  [ "$(printf '%s\n' "$XC" | $G -c '^    create table \|^    alter table ' || true)" = 3 ] || die "xcheck: two create table lines and one alter table"
  echo "  xcheck: the harness's script (@EntityScan(\"com.tiffinbox\") alone), md5 $X09 = the owning-side lesson's - no mapping moved"; }
EXQ="Your turn: the README's projection selects every column to show two. Make the SELECT ask only for the name and the meal type."
EXW=$(printf '%s\n' "$EXQ" | wc -w | tr -d ' ')
EXB1=""; EXB2=""; EXN1=""; EXN2=""; EXR=""
chk_exercise() { local EXB EXZ b ER ES w s1 s2
  EXB=$(blk exercise "in bash" "in zsh"); EXZ=$(blk exercise "in zsh" "")
  for b in "$EXB" "$EXZ"; do
    ER=$(printf '%s\n' "$b" | sed '/then the solution/,$d'); ES=$(printf '%s\n' "$b" | sed -n '/then the solution/,$p')
    for l in '    the JVM: exit 0' '    Found 1 JPA repository interface.' '    PROBE rows: [Ravi VEG, Sunil VEG]'; do has "$ER" "$l" "exercise: the README - the open projection runs and shows the rows"; has "$ES" "$l" "exercise: the solution runs and shows the same rows"; done
    nhas "$ER" 'PROBE threw' "exercise: the README runs"; nhas "$ES" 'PROBE threw' "exercise: the solution runs"
    s1=$(printf '%s\n' "$ER" | sed -n 's/^    org\.hibernate\.SQL : //p'); s2=$(printf '%s\n' "$ES" | sed -n 's/^    org\.hibernate\.SQL : //p')
    [ "$(printf '%s\n' "$s1" | $G -c . || true)" = 1 ] && [ "$(printf '%s\n' "$s2" | $G -c . || true)" = 1 ] || die "exercise: one SQL line each"
    # broken != solved, by the SELECT's own column list (S3.8): the README's = four's open interface, every column; the solution's
    # = four's closed interface, the name and the meal type
    EXN1=$(ccount "$s1"); EXN2=$(ccount "$s2")
    [ "$s1" = "$OPSQL" ] && [ "$EXN1" = "$OPN" ] || die "exercise: the README's projection selects every column - four's open interface's SELECT ($OPN columns): $s1 ($EXN1, counted from the line)"
    [ "$s2" = "$CLSQL" ] && [ "$EXN2" = "$CLN" ] && [ "$(clist "$s2")" = 'ce1_0.name,ce1_0.meal_type' ] || die "exercise: the solution's SELECT asks for the name and the meal type alone - four's closed interface's ($CLN columns): $s2 ($EXN2, counted from the line)"
    [ "$s1" != "$s2" ] || die "exercise: broken and solved print the same SELECT"
    [ "$(printf '%s\n' "$b" | $G -c "^  the shell is now in: this unit's folder")" = 2 ] || die "exercise: the shell back in this folder"; done
  [ "$(printf '%s\n' "$EXB" | $G -v '^in ')" = "$(printf '%s\n' "$EXZ" | $G -v '^in ')" ] || die "exercise: bash and zsh print the same"
  EXB1=$s1; EXB2=$s2; EXR='[Ravi VEG, Sunil VEG]'
  # each file's "What it prints" block is what the run printed, line for line (never a placeholder: unit 16 shipped two)
  w=$(printf '%s\n' "$EXB" | sed '/then the solution/,$d' | sed -n '/^  the block.s exit /,/^  the shell is now in: /p' | sed '1d;$d' | sed 's/^    //')
  [ "$(wib exercise/README.md)" = "$w" ] || die "exercise/README.md's \"What it prints\" block is not what the README's lines printed: $(diff <(wib exercise/README.md) <(printf '%s\n' "$w") | head -3 | paste -sd' ' -)"
  w=$(printf '%s\n' "$EXB" | sed -n '/then the solution/,$p' | sed -n '/then the solution/,/^  the shell is now in: /p' | sed '1d;$d' | sed 's/^    //')
  [ "$(wib exercise/SOLUTION.md)" = "$w" ] || die "exercise/SOLUTION.md's \"What it prints\" block is not what the solution's lines printed: $(diff <(wib exercise/SOLUTION.md) <(printf '%s\n' "$w") | head -3 | paste -sd' ' -)"
  $G -qxF -- "**Your turn:** ${EXQ#Your turn: }" exercise/README.md || die "exercise/README.md: the spoken exercise line"
  [ "$EXW" -le 25 ] || die "exercise: the spoken line is at most 25 words (R.203): $EXW"
  $G -qxF -- "    @Value(\"#{target.name + ' ' + target.mealType}\") String getLabel();" harness/src/probe/q/ex/ExApp.java || die "exercise: ExApp ships the open projection - Row's @Value line"
  echo "  exercise: bash and zsh alike - the README as written (Row, an open interface): exit 0, $EXR, the SELECT's list $EXN1 columns (= four's open); the solution (one line: Row closed): exit 0, the same rows, $EXN2 columns (= four's closed); each file's What it prints = the run; $EXW words"; }
cap four four; chk_four; pub four
cap nested nested; chk_nested; pub nested
cap tuple tuple; chk_tuple; pub tuple
cap xcheck xcheck; chk_xcheck; pub xcheck
cap exercise exercise; chk_exercise; pub exercise
# the values the video says are the captures', never typed: README.md states them in one line, composed here from what the checks read
VS="the values the video may say: the projections, $PN calls, README.md's table composed from four - the same rows each time, $VEGR · the closed interface: $CLSQL ($CLN columns, $CLL entity loads, a JDK proxy) · the open interface (@Value): $OPSQL ($OPN columns, $OPL entity loads) · the record: $REN columns, $REL entity loads · dynamic with NameAndType / NameDto / CustomerEntity: $DYN columns · four SELECTs: $FOURN SELECT lines from four calls · nested outside a transaction: $NB · nested in a TransactionTemplate: 1 + $NAN SELECTs = $NAS statements, each further one $NAP · Tuple (aliases $TUA) and Object[] (length $TUL): $TUSQL, the closed interface's byte for byte · xcheck: $X09 · exercise: the open Row $EXN1 columns; closed, $EXN2 columns: $EXB2, $EXR ($EXW words)"
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
echo "  ports: nothing listens on 18425, 8080, 35729 or 19980-19989 at the end - this unit bound none; 19989 never bound"
[ -z "$unpub" ] || die "no published hash for:$unpub - check the captures, then copy the md5s above into receipts.md5 and run again"
echo "c7-unit19: every capture 3/3 and = published; every spoken number asserted; no port bound"
