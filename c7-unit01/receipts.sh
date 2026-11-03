#!/bin/bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25.0.4.1 on the author's Mac: point it at your JDK 25
XPATH=$PATH                                           # the PATH you started this with: the exercise's own shells get it
export PATH="$JAVA_HOME/bin:$PATH"
# Course 7 · The Object-Relational Mismatch, Named - this unit's receipts. No change to the anchor: anchor/ is the link to
# ../c7-unit03/after (= ../c7-tiffinbox, asserted below). Four captures, each run three times and hashed; cap() DIES when a hash
# differs from receipts.md5; every number the video says is asserted by a check that can fail, right after its capture.
#   file      Course 2's class, read off disk: ../c2-unit38/src/main/java/JdbcCustomerRepository.java - its lines (wc -l), its
#             md5, its class line, its URL (Db.java's, a file database), its lesson's title (Course 2's README) - and beside it
#             the anchor's own CustomerRepository (@Component, its in-memory URL); R.162's check: neither is ever the other
#   count     the ten named patterns of the brief's list, in its order, each one command (/usr/bin/grep -oE 'P' FILE | wc -l:
#             occurrences), its matched text printed with grep -noE and asserted at its lines; the list itself counted
#             (counts 10 · kinds 6: the list's kind tags and the run-made K5)
#   identity  Course 2's JdbcCustomerRepository run as Course 2 ran it - on a pool built by Course 2's pool() line for line,
#             only the URL this run's (H2 in memory, its trace on) - by harness/C7Identity.java (default package), from
#             .harness/run/: findById(1) twice - two prepareStatements, two SELECTs, on one connection borrowed twice; two
#             objects, equal records; afterwards no database file anywhere (R.195)
#   exercise  exercise/README.md's lines, then exercise/SOLUTION.md's, read from the files and run as written, in ONE env -i shell
#             - /bin/bash, then again in /bin/zsh -f
# Course 2's sources are never built in place and never changed: they are copied (cmp-checked) into .harness/c2, where Course
# 2's own README line resolves their class path (Maven, offline, against .m2-demo) and javac compiles them with the harness.
# The harness never names Course 2's Db: Db's static initialiser opens ./data/tiffinbox, a file, in the working directory.
# Commands are printed exactly as they run: each goes through eval. harness/dur7.py (Course 7's builders' duration pattern,
# byte for byte, md5 asserted) gates this unit's prose. "$M2" is this unit's own repository, .m2-demo. Every grep that counts
# is /usr/bin/grep (BSD grep 2.6.0): an interactive zsh may alias grep to another program.
# The locale: the JVM ignores LC_ALL on macOS - the one java line here has its locale pinned (-Duser.language=en
# -Duser.country=US), and a check refuses a java line without it.
# The network: the one Maven run is offline (-o) against .m2-demo and says so ("offline: yes"). A run that cannot resolve an
# artifact offline is run once more without -o and says so, naming the artifact the offline run missed and the repositories
# that answered the retry, by the ids and URL schemes its log names ("offline: no - ..."); it never names a repository the log
# does not. At run time nothing is sent anywhere: no port is bound, and the one database is H2 in the JVM's memory.
# Masks (README.md declares each; awk gsub only): this folder "…", the folder above it "…/..", home "~", your user name "<user>";
# " using Java <version>"; H2's object numbers "conn<n>" / "prep<n>"; an identity hash "@…". No duration is captured.
# Ports (§P, 19800-19809): none bound - a plain JVM, no server; all ten checked free first and last, 19809 among them.
set -e
# bash 5.2 and later turn an & in the replacement of ${x/pattern/replacement} into the matched text (patsub_replacement, on by
# default). Switched off, so /bin/bash 3.2 (./receipts.sh) and a newer bash (bash receipts.sh) run the same commands.
shopt -u patsub_replacement 2> /dev/null || true
export LC_ALL=C
cd "$(dirname "$0")"
mkdir .r-lock 2> /dev/null || { echo "  *** another receipts.sh is running in this folder (.r-lock exists) - if none is, rmdir .r-lock ***"; exit 1; }
U="$PWD"; UP="$(cd .. && pwd)"; ME="$(id -un)"
G=/usr/bin/grep
# On every exit - the end, a failed check, or Ctrl-C - stop what this script started in the background, if it still runs: $pid (the
# harness JVM), $mpid (the Maven run, with every process under it), $xpid (an exercise shell, with every process under it); then
# sweep(): anything of this run still alive in its process group - the harness JVM, a Maven - is stopped. After an interrupt a
# capture's unfinished runs (.r-NAME.1-3) go too; after a failed check they stay. The clean-up ignores a second Ctrl-C, and the
# script still exits 130 after an interrupt (README.md, "Interrupted"). No wait in this script is bare.
pid=""; mpid=""; xpid=""
sweep() { local g i l
  g=$(ps -o pgid= -p $$ 2> /dev/null | tr -d ' ') || g=""
  [ -n "$g" ] || return 0
  i=0; while [ $i -lt 20 ]; do
    l=$(ps -axo pid=,pgid=,command= 2> /dev/null | awk -v g="$g" -v me=$$ '
      $2 == g && $1 != me && $3 != "awk" && $3 != "ps" && (index($0, " C7Identity") || index($0, "org.codehaus.plexus.classworlds.launcher.Launcher")) { print $1 }' | paste -sd' ' -) || l=""
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
for t in python3 rsync lsof mvn md5 cmp /bin/zsh $G; do command -v $t > /dev/null || die "$t is needed"; done
# A variable of yours must not become a JVM flag or a build setting (the problem-detail lesson's loop: a canary planted under
# every name first, and the run stops if one survives).
for v in JAVA_TOOL_OPTIONS JDK_JAVA_OPTIONS _JAVA_OPTIONS MAVEN_ARGS CLASSPATH DEBUG; do export "$v=planted-canary"; done
for v in JAVA_TOOL_OPTIONS JDK_JAVA_OPTIONS _JAVA_OPTIONS MAVEN_ARGS CLASSPATH DEBUG; do unset "$v"; done
[ -z "$(env | $G -- '=planted-canary$')" ] || die "a variable survived the clean-up above: $(env | $G -- '=planted-canary$' | sed 's/=.*//' | paste -sd' ' -)"
# No anchor change: anchor/ is the link to ../c7-unit03/after, which IS ../c7-tiffinbox, byte for byte (local repository and build
# output aside)
[ -L anchor ] && [ "$(readlink anchor)" = ../c7-unit03/after ] || die "anchor must be the link to ../c7-unit03/after - this unit changes nothing in the anchor"
[ -f anchor/pom.xml ] && [ -f anchor/README.md ] || die "the anchor (its pom.xml or README.md) is missing"
[ -d ../c7-tiffinbox ] || die "../c7-tiffinbox is missing"
D_=$(diff -rq -x .m2-demo -x target -x secrets anchor/ ../c7-tiffinbox 2>&1 || true)
[ -z "$D_" ] || die "anchor/ is not ../c7-tiffinbox: $(printf '%s\n' "$D_" | head -3 | paste -sd';' -)"
echo "  the anchor: anchor/ -> ../c7-unit03/after; diff -rq -x .m2-demo -x target -x secrets against ../c7-tiffinbox: empty - no anchor change"
# Course 2's lesson, as committed: never built in place (no target/, no data/), its six sources and its POM
C2=../c2-unit38
C2S=$C2/src/main/java
C2F=$C2S/JdbcCustomerRepository.java                 # Course 2's class - the one this lesson opens
C2DB=$C2S/Db.java                                    # Course 2's database class: its URL, its schema, its pool()
AF=anchor/tiffinbox-core/src/main/java/com/tiffinbox/CustomerRepository.java     # the anchor's own repository
AY=anchor/tiffinbox-web/src/main/resources/application.yaml                     # the anchor's settings: its URL
[ "$(cd $C2S 2> /dev/null && ls | paste -sd' ' -)" = 'Customer.java Db.java JdbcCustomerRepository.java MealType.java RepoDemo.java Repository.java' ] && [ -f $C2/pom.xml ] && [ -f $C2/README.md ] || die "$C2 must hold its README, its pom.xml and its six sources"
[ ! -e $C2/target ] && [ ! -e $C2/data ] || die "$C2 holds a target/ or a data/ - Course 2's lesson is never built or run in place"
[ -f $AF ] && [ -f $AY ] || die "the anchor's CustomerRepository.java or application.yaml is missing"
for f in harness/dur7.py harness/C7Identity.java exercise/README.md exercise/SOLUTION.md README.md receipts.md5; do [ -f "$f" ] || die "$f is missing"; done
[ "$(ls harness | paste -sd' ' -)" = 'C7Identity.java dur7.py' ] || die "harness/ holds another file"
[ "$(ls exercise | paste -sd' ' -)" = 'README.md SOLUTION.md' ] || die "exercise/ holds another file"
# Course 7's builders' duration pattern, byte for byte (Section 1 states no duration, R.172)
[ "$(md5 -q harness/dur7.py)" = 41667fed9ffcefe171389eed7e654e66 ] || die "harness/dur7.py is not the builders' dur7.py (md5 41667fed…)"
if [ -f ../../../data-jpa-hibernate/_builders/dur7.py ]; then cmp -s harness/dur7.py ../../../data-jpa-hibernate/_builders/dur7.py || die "harness/dur7.py differs from the builders' ../../../data-jpa-hibernate/_builders/dur7.py"
  echo "  (terminal only) harness/dur7.py = the builders' _builders/dur7.py, byte for byte" >&3
else echo "  (terminal only) the builders' _builders/dur7.py is not beside this clone: its md5 above is the check" >&3; fi
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
PORTS="19800 19801 19802 19803 19804 19805 19806 19807 19808 19809"
for p in $PORTS; do
  [ "$(listeners $p)" = 0 ] || die "something already listens on $p - this unit's ports must be free; if it is a process an interrupted run left behind, stop it: kill $(lsof -nP -iTCP:$p -sTCP:LISTEN -t 2> /dev/null | paste -sd' ' -)"; done
# the database files a run of Course 2's Db would leave - none may be here before the run, so none can be mistaken for one after
dbfiles() { find "$1" -path "$1/.m2-demo" -prune -o \( -name '*.mv.db' -o -name '*.trace.db' -o \( -name data -type d \) \) -print 2> /dev/null | wc -l | tr -d ' '; }
rootdb() { local n=0 f; [ -e ../data ] && n=$((n + 1)); for f in ../*.mv.db ../*.trace.db; do [ -e "$f" ] && n=$((n + 1)); done; echo $n; }
rm -rf .harness
[ "$(dbfiles .)" = 0 ] && [ "$(rootdb)" = 0 ] || die "a database file or a data/ folder is already in this folder or in the repository's root - remove it first (R.195)"
mkdir -p .harness

# ---- duration words: 0 - dur7's DUR over this unit's prose (README.md, the exercise's two files); a match stops the run -----------
cat > .harness/dur.py <<'PY'
import importlib.util, sys
spec = importlib.util.spec_from_file_location("dur7", sys.argv[1]); m = importlib.util.module_from_spec(spec); spec.loader.exec_module(m)
n = 0
for f in sys.argv[2:]:
    for i, l in enumerate(open(f, encoding="utf-8"), 1):
        for w in m.DUR.finditer(l):
            n += 1
            print("  %s line %d: %s" % (f, i, w.group(0)))
print("duration words: %d" % n)
PY
DW=$(python3 -I -B .harness/dur.py harness/dur7.py README.md exercise/README.md exercise/SOLUTION.md) || die "dur7's gate did not run"
[ "$(printf '%s\n' "$DW" | tail -1)" = 'duration words: 0' ] || die "dur7.DUR found duration words (Section 1 states none, R.172): $(printf '%s\n' "$DW" | paste -sd';' -)"
echo "  duration words: 0 (dur7.DUR over README.md, exercise/README.md, exercise/SOLUTION.md)"

# ---- the commands: Course 2's own line, read from its README and asserted there whole; this unit's lines, from README.md -------
c2readme() { $G -qF -- "\`$1\`" $C2/README.md || die "$C2/README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
R_CP=$(c2readme 'mvn -q dependency:build-classpath -Dmdep.outputFile=cp.txt')
R_RUN=$(c2readme 'java -cp "target/classes:$(cat cp.txt)" RepoDemo')
mine() { $G -m1 -xF -- "$1" README.md > /dev/null || die "README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
JL='-Duser.language=en -Duser.country=US'
L_CP=$(mine 'mvn -o -B -Dmaven.repo.local="$M2" dependency:build-classpath -Dmdep.outputFile=cp.txt')
L_JAVAC=$(mine 'javac -d .harness/classes -cp "$(cat .harness/c2/cp.txt)" .harness/c2/src/main/java/*.java harness/C7Identity.java')
L_RUN=$(mine "java $JL -cp \"../classes:\$(cat ../c2/cp.txt)\" C7Identity")
# The derivations, asserted: Course 2's class-path line with -q made offline (-o -B and this unit's repository), and nothing else;
# Course 2's run line with the locale, the class folder and the class path file where this unit keeps them, and the harness's main
[ "${R_CP/mvn -q /mvn -o -B -Dmaven.repo.local=\"\$M2\" }" = "$L_CP" ] || die "the class-path line must be Course 2's README line with -q made -o -B -Dmaven.repo.local=\"\$M2\", and nothing else"
X_=${R_RUN/java -cp /java $JL -cp }; X_=${X_/target\/classes:/..\/classes:}; X_=${X_/cat cp.txt/cat ..\/c2\/cp.txt}; X_=${X_/ RepoDemo/ C7Identity}
[ "$X_" = "$L_RUN" ] || die "the run line must be Course 2's README run line with the locale, ../classes, ../c2/cp.txt and C7Identity, and nothing else"
echo "  the commands: $C2/README.md gives the 2 lines this script derives from; README.md the $($G -c '^L_[A-Z]*=$(mine ' receipts.sh) this unit adds"
JV=$(java -version 2>&1 | sed -n 's/.*version "\([^"]*\)".*/\1/p' | head -1)
echo "  (terminal only) the JDK is $JV · the shell running this script: bash $BASH_VERSION" >&3

# ---- build: Course 2's sources copied, their class path resolved offline by Course 2's own line, compiled with the harness -------
M2="$PWD/.m2-demo"
# mbuild COMMAND LOG WHAT: offline first. If the offline run fails for want of an artifact, its log is kept beside (LOG with
# -offline), the first artifact it names is read from it, and the run happens once more without -o; the label then names that
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
    how="no - the offline run could not resolve ${miss:-an artifact (none named in its log)} from .m2-demo, so it ran once more without -o; that run downloaded from: ${got:-nothing}; of them over http(s): $web"; fi
  [ $ec = 0 ] || { tail -30 "$2" >&3
    ! $G -qE 'Could not resolve|could not be resolved|Could not transfer|Cannot access' "$2" || die "Maven failed: $3 - it could resolve the class path neither from .m2-demo nor from a repository it could reach: seed .m2-demo first (README.md, The repository)"
    die "Maven failed: $3"; }
  echo "  ran $3 · offline: $how · exit $ec · 'Downloaded from' lines in its log: $($G -c '^\[INFO\] Downloaded from ' "$2" || true)"; }
mkdir -p .harness/c2/src/main/java .harness/classes
cp $C2/pom.xml .harness/c2/pom.xml; cp $C2S/*.java .harness/c2/src/main/java/
for f in pom.xml $(cd $C2S && ls); do g=$f; [ $f = pom.xml ] || g=src/main/java/$f; cmp -s $C2/$g .harness/c2/$g || die "the copy of $C2/$g differs"; done
echo "  copied $C2/pom.xml and its $(ls .harness/c2/src/main/java | wc -l | tr -d ' ') sources into .harness/c2 (each cmp-equal; $C2 itself is never built)"
mbuild "cd .harness/c2 && $L_CP" .harness/cp.log "Course 2's class-path line on .harness/c2 (its POM)"
# the class path: the POM's three dependencies at the POM's versions (read from it), and the one they bring (Hikari's slf4j-api)
pv() { sed -n -E "s#.*<artifactId>$1</artifactId><version>([^<]+)</version>.*#\1#p" .harness/c2/pom.xml; }
H2V=$(pv h2); HKV=$(pv HikariCP); SSV=$(pv slf4j-simple)
[ -n "$H2V" ] && [ -n "$HKV" ] && [ -n "$SSV" ] || die "the POM no longer names h2, HikariCP and slf4j-simple with a version each"
CPJ=$(tr ':' '\n' < .harness/c2/cp.txt | sed 's#.*/##' | paste -sd' ' -)
[ "$CPJ" = "h2-$H2V.jar HikariCP-$HKV.jar slf4j-api-$SSV.jar slf4j-simple-$SSV.jar" ] || die "the class path is not the POM's (h2 $H2V, HikariCP $HKV, slf4j-simple $SSV + slf4j-api): $CPJ"
while IFS= read -r j; do case $j in "$M2"/*) [ -f "$j" ] || die "$j is missing" ;; *) die "a class path entry outside .m2-demo: $j" ;; esac; done <<EOF
$(tr ':' '\n' < .harness/c2/cp.txt)
EOF
echo "  the class path (cp.txt, every jar in .m2-demo): $CPJ"
(eval "$L_JAVAC") > .harness/javac.log 2>&1 < /dev/null || die "Course 2's sources and the harness did not compile: $(head -5 .harness/javac.log)"
echo "  compiled Course 2's $(ls .harness/c2/src/main/java | wc -l | tr -d ' ') sources and harness/C7Identity.java into .harness/classes (javac $JV)"

# ---- helpers ------------------------------------------------------------------------------------------------------------
mask() { awk -v u="$U" -v up="$UP" -v hm="$HOME" -v me="$ME" '
  function lit(x) { gsub(/[][\\.^$*+?(){}|\/]/, "\\\\&", x); return x }
  function enc(x) { gsub(/ /, "%20", x); return x }
  BEGIN { P = lit(u); Q = lit(up); H = lit(hm); PE = lit(enc(u)); QE = lit(enc(up)); M = "(^|[^A-Za-z0-9_])" lit(me) "([^A-Za-z0-9_]|$)" }
  { gsub(P, "…"); gsub(PE, "…"); gsub(Q, "…/.."); gsub(QE, "…/.."); gsub(H, "~")
    gsub(/ using Java [0-9][0-9.]+/, " using Java <version>")
    gsub(/conn[0-9]+/, "conn<n>"); gsub(/prep[0-9]+/, "prep<n>")
    gsub(/@[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]+/, "@…")
    while (match($0, M)) { pre = substr($0, 1, RSTART - 1); s = substr($0, RSTART, RLENGTH); post = substr($0, RSTART + RLENGTH)
      sub(lit(me), "<user>", s); $0 = pre s post }
    print }'; }
printf '%s\n' 'Starting X using Java 25.0.4.1' '/**/PreparedStatement prep12 = conn3.prepareStatement("SELECT 1");' 'C7Identity@1b2c3d4e' "$U/x" > .harness/p1
[ "$(mask < .harness/p1)" = "$(printf '%s\n' 'Starting X using Java <version>' '/**/PreparedStatement prep<n> = conn<n>.prepareStatement("SELECT 1");' 'C7Identity@…' '…/x')" ] || die "mask: the planted JDK version, H2 object numbers, identity hash and this folder must be masked"
unpub=""
cap() { local nm=$1 h pub i; shift
  for i in 1 2 3; do "$@" > .harness/cap.raw 2>&1 || true; [ -z "$pid$mpid$xpid" ] || die "$nm left a process running"
    mask < .harness/cap.raw > ".r-$nm.$i"; done
  h=$(md5 -q ".r-$nm.1")
  [ "$h" = "$(md5 -q ".r-$nm.2")" ] && [ "$h" = "$(md5 -q ".r-$nm.3")" ] || die "$nm drifts across three runs (diff .r-$nm.1 .r-$nm.2 .r-$nm.3)"
  mv ".r-$nm.1" ".r-$nm.out"; rm -f ".r-$nm.2" ".r-$nm.3"
  pub=$(awk -v n="$nm" '$1 == n { print $2 }' receipts.md5 2> /dev/null || true)
  if [ -z "$pub" ]; then printf '  %-15s md5 %s  3/3  (no published hash)\n' "$nm" "$h"; unpub="$unpub $nm"
  elif [ "$pub" = "$h" ]; then printf '  %-15s md5 %s  3/3  = published\n' "$nm" "$h"
  else printf '  %-15s md5 %s  3/3  DIFFERS from the published %s\n' "$nm" "$h" "$pub"
    die "$nm is not the published capture - suspect another JDK, H2, Hikari or grep, a busy machine, a variable of yours, or an edited source; diff .r-$nm.out against its block in README.md"; fi; }
# Checks: each reads a line a program computed - a command's own output, a count of lines - never a label printed unconditionally
blk() { awk -v a="$2" -v b="$3" 'index($0, a) == 1 { f = 1; next } b != "" && index($0, b) == 1 { f = 0 } f' ".r-$1.out"; }
has() { printf '%s\n' "$1" | $G -qxF -- "$2" || die "$3: expected the line: $2"; }
# show CMD: the command as it runs (one $ line), then what it printed, each line indented; its exit code kept in SE
SE=0
show() { echo "\$ $1"; SE=0; (eval "$1") > .harness/show.out 2>&1 < /dev/null || SE=$?; sed 's/^/  /' .harness/show.out; }
# after TEXT LINE: the line that follows LINE (an exact match) in TEXT
# (awk -v would read the backslashes in a pattern as escapes: the line travels in the environment instead)
after() { printf '%s\n' "$1" | AX="$2" awk 'BEGIN { x = ENVIRON["AX"] } f { print; exit } $0 == x { f = 1 }'; }
# below TEXT LINE: the indented lines that follow LINE (an exact match) in TEXT, unindented
below() { printf '%s\n' "$1" | AX="$2" awk 'BEGIN { x = ENVIRON["AX"] } $0 == x { f = 1; next } f && /^  / { sub(/^  /, ""); print; next } { f = 0 }'; }
kind() { case "$2" in jdbc:h2:mem:*) echo "in memory - jdbc:h2:mem:, gone with the JVM" ;; jdbc:h2:./*|jdbc:h2:~/*|jdbc:h2:file:*) echo "a file - H2 opens ${2#jdbc:h2:}.mv.db, relative to the working directory" ;; *) echo "neither: $2" ;; esac; }

# ---- file: Course 2's class, read off disk, and the anchor's beside it (C7-2, R.162, R.169) ---------------------------------
file() { local t u a w1 w2
  t=$(sed -n -E '1s/^# [^ ]+ — (.*) \(JDK [^)]*\)$/\1/p' $C2/README.md)
  echo "Course 2's class - the lesson \"$t\" (the first line of $C2/README.md):"
  show "wc -l < $C2F | tr -d ' '"
  show "md5 -q $C2F"
  show "$G -cE '^package ' $C2F"
  show "$G -nE '^public final class |private final DataSource' $C2F"
  show "$G -nE 'URL *= ' $C2DB"
  u=$(sed -n -E 's/^ *public static final String URL *= "([^"]+)";$/\1/p' $C2DB)
  echo "  its database (Db.java's URL, which Db.pool() hands Hikari): $(kind $C2DB "$u")"
  echo "beside it, the anchor's own class - in the tree this course starts from (anchor/ = ../c7-tiffinbox):"
  show "wc -l < $AF | tr -d ' '"
  show "$G -nE '^package |^@Component|^public final class ' $AF"
  show "$G -nE 'jdbc-url:' $AY"
  a=$(sed -n -E 's/^  jdbc-url: ([^ ]+)$/\1/p' $AY)
  echo "  its database (tiffinbox.jdbc-url, which Database opens with DriverManager): $(kind $AF "$a")"
  show "$G -rlw JdbcCustomerRepository anchor/tiffinbox-core anchor/tiffinbox-web | wc -l | tr -d ' '"
  w1=$(infolder "$C2F" ../c2-unit38/src/main/java/ "in Course 2's folder" "NOT in Course 2's folder")
  w2=$(infolder "$AF" anchor/ "in the anchor" "NOT in the anchor")
  echo "R.162: the class labelled Course 2's - $w1 · package lines $($G -cE '^package ' $C2F || true) · @Component lines $($G -c '^@Component' $C2F || true) · class $(sed -n -E 's/^public final class ([A-Za-z]+).*/\1/p' $C2F) · its URL $(kind $C2DB "$u" | sed 's/ - .*//')"
  echo "R.162: the anchor's class - $w2 · package $(sed -n -E 's/^package ([a-z.]+);$/\1/p' $AF) · @Component lines $($G -c '^@Component' $AF || true) · class $(sed -n -E 's/^public final class ([A-Za-z]+).*/\1/p' $AF) · its URL $(kind $AF "$a" | sed 's/ - .*//')"; }
# infolder PATH PREFIX YES NO
infolder() { case "$1" in "$2"*) echo "$3" ;; *) echo "$4" ;; esac; }
c_file() { local F; F=$(cat .r-file.out)
  # R.162 / R.169, first: the class this lesson opens is Course 2's, never the anchor's - and the anchor's is never called Course 2's
  has "$F" "R.162: the class labelled Course 2's - in Course 2's folder · package lines 0 · @Component lines 0 · class JdbcCustomerRepository · its URL a file" "file: R.162 - the class labelled Course 2's must be c2-unit38's JdbcCustomerRepository (no package, no @Component, a file database), never the anchor's"
  has "$F" "R.162: the anchor's class - in the anchor · package com.tiffinbox · @Component lines 1 · class CustomerRepository · its URL in memory" "file: R.162 - the anchor's class is the anchor's CustomerRepository"
  has "$F" "Course 2's class - the lesson \"TiffinBox on a Real Database: The JDBC Repository\" (the first line of $C2/README.md):" "file: Course 2's lesson, by its title"
  has "$F" "\$ wc -l < $C2F | tr -d ' '" "file: the line count is wc -l's"
  [ "$(after "$F" "\$ wc -l < $C2F | tr -d ' '")" = '  114' ] || die "file: Course 2's class has 114 lines (wc -l)"
  [ "$(after "$F" "\$ md5 -q $C2F")" = '  17b9ab390ffe7187231d34e35cf7a869' ] || die "file: Course 2's class is the file Course 2 published (md5 17b9ab39…)"
  has "$F" '  12:public final class JdbcCustomerRepository implements Repository<Customer, Long> {' "file: the class line"
  has "$F" '  17:    public static final String URL  = "jdbc:h2:./data/tiffinbox";' "file: Db.java:17, the URL"
  has "$F" "  its database (Db.java's URL, which Db.pool() hands Hikari): a file - H2 opens ./data/tiffinbox.mv.db, relative to the working directory" "file: Course 2's database is a file"
  has "$F" '  11:@Component' "file: the anchor's @Component"
  has "$F" '  3:  jdbc-url: jdbc:h2:mem:tiffinbox;DB_CLOSE_DELAY=-1' "file: the anchor's URL"
  has "$F" "  its database (tiffinbox.jdbc-url, which Database opens with DriverManager): in memory - jdbc:h2:mem:, gone with the JVM" "file: the anchor's database is in memory"
  [ "$(after "$F" "\$ $G -rlw JdbcCustomerRepository anchor/tiffinbox-core anchor/tiffinbox-web | wc -l | tr -d ' '")" = '  0' ] || die "file: the anchor holds no JdbcCustomerRepository"
  echo "  file: Course 2's JdbcCustomerRepository - 114 lines, md5 17b9ab39…, Db.java:17 a file (jdbc:h2:./data/tiffinbox), called back by its title; beside it the anchor's @Component CustomerRepository on jdbc:h2:mem:tiffinbox; the anchor holds no JdbcCustomerRepository; R.162 holds"; }

# ---- count: the ten named patterns, one command each, their matched text asserted (⚑9, R.187) --------------------------------
# THE LIST - the brief's ten patterns, in its order: a kind tag and its name, a tab, the pattern in single quotes. README.md carries the same ten
# commands (asserted). Its entries are counted: counts = the entries, kinds = the distinct tags plus K5, which is run, not grepped.
TAB=$(printf '\t')
# (read, not $(cat <<...): bash 3.2's command substitution misreads a here-document holding a quote or a parenthesis)
IFS= read -r -d '' PATTERNS <<'LIST' || true
K1 SQL as strings	'(SELECT|MERGE INTO|DELETE FROM) '
K2 mapping by hand	'rs\.get[A-Z]'
K2 mapping by hand	'ps\.set[A-Z]'
K2 mapping by hand	'MealType\.valueOf|mealType\(\)\.name\(\)'
K3 SQLException by hand	'catch \(SQLException e\)'
K3 SQLException by hand	'throw new IllegalStateException\("'
K4 no unit of work	'ds\.getConnection\(\)'
K4 no unit of work	'setAutoCommit|commit\(\)|rollback\('
K6 the id and the dialect	'KEY \(id\)'
K6 the id and the dialect	'getGeneratedKeys'
LIST
PATTERNS=${PATTERNS%?}                               # the here-document's last newline
K5='K5 no identity - run, not grepped: the identity capture'
ocmd() { printf "%s -oE '%s' %s | wc -l" "$G" "$1" "$C2F"; }
ncmd() { printf "%s -noE '%s' %s" "$G" "$1" "$C2F"; }
ccmd() { printf "%s -cE '%s' %s" "$G" "$1" "$C2F"; }
count() { local n=0 k p c o tags nk ne
  while IFS= read -r l; do n=$((n + 1)); k=${l%%"$TAB"*}; p=${l#*"$TAB"}; p=${p#\'}; p=${p%\'}
    echo "$n · $k"
    show "$(ocmd "$p")"
    show "$(ncmd "$p")"
    if [ "$p" = 'rs\.get[A-Z]' ]; then show "$(ccmd "$p")"
      o=$(eval "$(ocmd "$p")" | tr -d ' '); c=$(eval "$(ccmd "$p")" || true)
      echo "  rs.get: occurrences $o (grep -o, one per match) · lines $c (grep -c counts lines, not matches)"; fi
  done <<EOF
$PATTERNS
EOF
  echo "$K5"
  tags=$( { printf '%s\n' "$PATTERNS" | sed 's/ .*//'; echo "${K5%% *}"; } | sort -u | paste -sd' ' -)
  ne=$(printf '%s\n' "$PATTERNS" | $G -c .); nk=$(printf '%s\n' "$tags" | wc -w | tr -d ' ')
  echo "the list: counts $ne · kinds $nk ($tags)"; }
# what each command must print - its count, then its matched text at its lines (grep -noE), in the list's order
EXP_N="6 7 9 2 6 7 6 0 1 0"
EXP_1='22:SELECT |36:SELECT |50:MERGE INTO |69:DELETE FROM |80:SELECT |96:SELECT '
EXP_2='87:rs.getL|102:rs.getL|111:rs.getL|111:rs.getS|111:rs.getS|112:rs.getS|112:rs.getB'
EXP_3='39:ps.setL|53:ps.setL|54:ps.setS|55:ps.setS|56:ps.setS|57:ps.setB|70:ps.setL|84:ps.setL|99:ps.setL'
EXP_4='56:mealType().name()|112:MealType.valueOf'
EXP_5='29:catch (SQLException e)|43:catch (SQLException e)|61:catch (SQLException e)|72:catch (SQLException e)|89:catch (SQLException e)|105:catch (SQLException e)'
EXP_6='30:throw new IllegalStateException("|44:throw new IllegalStateException("|59:throw new IllegalStateException("|62:throw new IllegalStateException("|73:throw new IllegalStateException("|90:throw new IllegalStateException("|106:throw new IllegalStateException("'
EXP_7='23:ds.getConnection()|37:ds.getConnection()|51:ds.getConnection()|68:ds.getConnection()|82:ds.getConnection()|97:ds.getConnection()'
EXP_8=''
EXP_9='50:KEY (id)'
EXP_10=''
c_count() { local C i=0 p o m e got
  C=$(cat .r-count.out)
  # the list is named and counted (R.187, R.196): ten entries, six kinds - a ninth or an eleventh entry fails here
  has "$C" 'the list: counts 10 · kinds 6 (K1 K2 K3 K4 K5 K6)' "count: the list - counts 10 · kinds 6"
  while IFS= read -r l; do i=$((i + 1)); p=${l#*"$TAB"}; p=${p#\'}; p=${p%\'}
    o=$(after "$C" "\$ $(ocmd "$p")" | tr -d ' ')
    e=$(echo $EXP_N | cut -d' ' -f$i)
    [ "$o" = "$e" ] || die "count: pattern $i ($p) - grep -oE | wc -l printed ${o:-nothing}, expected $e"
    m=$(below "$C" "\$ $(ncmd "$p")" | paste -sd'|' -)
    eval "got=\$EXP_$i"
    [ "$m" = "$got" ] || die "count: pattern $i ($p) - the matched text at its lines (grep -noE) is '${m}', expected '${got}' (R.187: the text, not the count alone)"
  done <<EOF
$PATTERNS
EOF
  has "$C" "  rs.get: occurrences 7 (grep -o, one per match) · lines 4 (grep -c counts lines, not matches)" "count: seven reads in four lines"
  # README.md carries the same ten commands, word for word, and no other count command on Course 2's file
  while IFS= read -r l; do p=${l#*"$TAB"}; p=${p#\'}; p=${p%\'}; $G -qxF -- "$(ocmd "$p")" README.md || die "README.md does not carry the list's command: $(ocmd "$p")"; done <<EOF
$PATTERNS
EOF
  [ "$($G -cE "^$G -oE '.*' \.\./c2-unit38/src/main/java/JdbcCustomerRepository\.java \| wc -l\$" README.md)" = "$(printf '%s\n' "$PATTERNS" | $G -c .)" ] || die "README.md's count commands are not the list's, one for one"
  echo "  count: the ten in the brief's order - $(echo $EXP_N | sed 's/ /\//g'); each matched text asserted at its lines; rs.get 7 occurrences in 4 lines; getGeneratedKeys 0, KEY (id) 1; counts 10 · kinds 6; README.md carries the same ten commands"; }

# ---- identity: Course 2's repository, run as Course 2 ran it, from .harness/run/ (R.195; RE-MEASURE 8) ---------------------------
# hv: the run's log, filtered - the harness's C7 lines, Hikari's lines from the main thread, and between the first find's begin
# and the second find's end H2's trace of each prepareStatement and each SELECT on customers; the rest (H2's plans, its other
# calls, its timestamps, the pool's own background work) is never printed; from a SELECT's comment H2's " t:N" (the milliseconds
# the statement took, printed only when it took one or more) is removed - no duration is captured. Then what the script reads.
hv() { awk '
  /^C7 / { print "  " $0; if ($0 ~ /^C7 first findById\(1\) begin/) f = 1; if ($0 ~ /^C7 second findById\(1\) end/) f = 0; next }
  /^\[main\] INFO com\.zaxxer\.hikari\./ { s = $0; sub(/^\[main\] INFO com\.zaxxer\.hikari\.[A-Za-z.]+ - /, "", s); print "  Hikari: " s; next }
  f && /^\/\*\*\/PreparedStatement prep[0-9]+ = conn[0-9]+\.prepareStatement\(/ { print "    H2 trace: " $0; next }
  f && /^\/\*SQL [^*]*\*\/SELECT .* FROM customers WHERE id = / { s = $0; sub(/ t:[0-9]+\*\//, "*/", s); print "    H2 trace: " s; next }' "$1"; }
# spans: in each find, H2's prepareStatement and SELECT lines; the connections the prepareStatements were made on
span() { awk -v a="C7 $1 findById(1) begin" -v b="C7 $1 findById(1) end" 'index($0, a) == 1 { f = 1; next } index($0, b) == 1 { f = 0 } f' "$2"; }
idrun() { local c i=0 e=0 p1 s1 p2 s2 cs d
  rm -rf .harness/run; mkdir .harness/run
  c="cd .harness/run && $L_RUN"
  echo "\$ $c"
  (eval "${c/&& java /&& exec java }") > .harness/id.out 2>&1 < /dev/null & pid=$!
  while kill -0 "$pid" 2> /dev/null && [ $i -lt 240 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$pid" 2> /dev/null && { kill "$pid"; die "the identity JVM was still running after 60 s"; }
  wait "$pid" || e=$?; pid=""
  echo "  exit $e"
  hv .harness/id.out
  p1=$(span first .harness/id.out | $G -cE '^/\*\*/PreparedStatement prep[0-9]+ = conn[0-9]+\.prepareStatement\(' || true)
  s1=$(span first .harness/id.out | $G -cE '^/\*SQL [^*]*\*/SELECT .* FROM customers WHERE id = ' || true)
  p2=$(span second .harness/id.out | $G -cE '^/\*\*/PreparedStatement prep[0-9]+ = conn[0-9]+\.prepareStatement\(' || true)
  s2=$(span second .harness/id.out | $G -cE '^/\*SQL [^*]*\*/SELECT .* FROM customers WHERE id = ' || true)
  cs=$( { span first .harness/id.out; span second .harness/id.out; } | sed -n -E 's/^\/\*\*\/PreparedStatement prep[0-9]+ = (conn[0-9]+)\.prepareStatement\(.*/\1/p')
  d=$(printf '%s\n' "$cs" | $G . | sort -u | $G -c . || true)
  echo "  read from H2's trace: the first find - prepareStatement $p1 · SELECT $s1 | the second find - prepareStatement $p2 · SELECT $s2"
  echo "  the connections the two prepareStatements were made on: $(printf '%s\n' "$cs" | paste -sd' ' -) - distinct: $d"
  echo "  database files after the run (R.195):"
  echo "    in .harness/run/, the JVM's working directory: $(ls -A .harness/run | $G -c . || true) entries"
  echo "    find . -name '*.mv.db' -not -path './.harness/*' (outside .harness/): $(find . -name '*.mv.db' -not -path './.harness/*' | wc -l | tr -d ' ') lines"
  echo "    this folder, .harness/ included (*.mv.db, *.trace.db, data/): $(dbfiles .) · the repository's root (../data, ../*.mv.db, ../*.trace.db): $(rootdb)"; }
CT_A='CREATE TABLE customers ('; CT_B=')""");'                                     # Db.reset's customers table, first and last line
IN_A='INSERT INTO customers (id, name, email, meal_type) VALUES'; IN_B='""");'         # and its rows
same() { [ "$1" = "$2" ] && echo yes || echo no; }
identity() { local c1 c2 i1 i2 p1 p2 nd
  c1=$(dbblk "$CT_A" "$CT_B" $C2DB); c2=$(dbblk "$CT_A" "$CT_B" harness/C7Identity.java)
  i1=$(dbblk "$IN_A" "$IN_B" $C2DB); i2=$(dbblk "$IN_A" "$IN_B" harness/C7Identity.java)
  p1=$(pm $C2DB); p2=$(pm harness/C7Identity.java)
  nd=$(sed 's#//.*##' harness/C7Identity.java | $G -cw 'Db' || true)
  echo "the table and its rows - Db.reset's, text for text, in harness/C7Identity.java (read from both files):"
  echo "  CREATE TABLE customers: $(printf '%s\n' "$c1" | $G -c .) lines in Db.java · the harness's the same: $(same "$c1" "$c2")"
  echo "  INSERT INTO customers: $(printf '%s\n' "$i1" | $G -c .) lines · the harness's the same: $(same "$i1" "$i2")"
  echo "the pool - Db.pool(), line for line (read from both files):"
  printf '%s\n' "$p1" | sed 's/^/  | /'
  echo "  the harness's pool(): the same $(printf '%s\n' "$p2" | $G -c .) lines: $(same "$p1" "$p2") · USER $(cv USER harness/C7Identity.java) = Db's $(cv USER $C2DB) · PASS $(cv PASS harness/C7Identity.java) = Db's $(cv PASS $C2DB) · URL - Db's $(cv URL $C2DB), the harness's $(cv URL harness/C7Identity.java)"
  echo "  lines of the harness that name Db (comments aside): $nd"
  idrun; }
dbblk() { awk -v a="$1" -v b="$2" 'index($0, a) { f = 1 } f { print } f && index($0, b) { exit }' "$3"; }
pm() { awk '/^    private static HikariDataSource pool\(\) \{$/ { f = 1 } f { print } f && /^    }$/ { exit }' "$1"; }
cv() { sed -n -E "s/^ *(public )?static final String $1 *= (\"[^\"]*\");.*/\2/p" "$2"; }
c_identity() { local I; I=$(cat .r-identity.out)
  # R.195 first: the run left no database file - not in its working directory, not anywhere in this folder, not in the root
  has "$I" "    in .harness/run/, the JVM's working directory: 0 entries" "identity: R.195 - the run wrote nothing into .harness/run/ (a call into Course 2's Db writes data/tiffinbox.mv.db there)"
  has "$I" "    this folder, .harness/ included (*.mv.db, *.trace.db, data/): 0 · the repository's root (../data, ../*.mv.db, ../*.trace.db): 0" "identity: R.195 - no database file anywhere"
  has "$I" "    find . -name '*.mv.db' -not -path './.harness/*' (outside .harness/): 0 lines" "identity: R.195 - the brief's find"
  has "$I" "  exit 0" "identity: the JVM exits 0"
  has "$I" "  the connections the two prepareStatements were made on: conn<n> conn<n> - distinct: 1" "identity: one connection, borrowed twice (an unpooled source makes two)"
  has "$I" "  lines of the harness that name Db (comments aside): 0" "identity: the harness never names Db"
  has "$I" "  CREATE TABLE customers: 8 lines in Db.java · the harness's the same: yes" "identity: Db.reset's CREATE TABLE customers, text for text"
  has "$I" "  INSERT INTO customers: 5 lines · the harness's the same: yes" "identity: Db.reset's rows, text for text"
  has "$I" '  the harness'"'"'s pool(): the same 9 lines: yes · USER "sa" = Db'"'"'s "sa" · PASS "" = Db'"'"'s "" · URL - Db'"'"'s "jdbc:h2:./data/tiffinbox", the harness'"'"'s "jdbc:h2:mem:c7identity;DB_CLOSE_DELAY=-1;TRACE_LEVEL_SYSTEM_OUT=3"' "identity: the pool is Db.pool(), line for line, only the URL this run's"
  has "$I" '  | '"        cfg.setMaximumPoolSize(5);" "identity: maximumPoolSize 5"
  has "$I" '  | '"        cfg.setPoolName(\"tiffinbox-pool\");" "identity: the pool name tiffinbox-pool"
  has "$I" "  Hikari: tiffinbox-pool - Added connection conn<n>: url=jdbc:h2:mem:c7identity user=SA" "identity: Course 2's pool, on this run's in-memory database"
  has "$I" "  read from H2's trace: the first find - prepareStatement 1 · SELECT 1 | the second find - prepareStatement 1 · SELECT 1" "identity: two prepareStatements, two SELECTs - one each find"
  has "$I" '    H2 trace: /*SQL l:69 #:1*/SELECT id, name, email, meal_type, active FROM customers WHERE id = ? {1: CAST(1 AS BIGINT)};' "identity: the SELECT, with its bind"
  has "$I" "  C7 same object: false | equal records: true" "identity: two objects, equal records"
  [ "$(printf '%s\n' "$I" | $G -c '^    H2 trace: ')" = 4 ] || die "identity: four H2 trace lines - two prepareStatements, two SELECTs"
  echo "  identity: Db.reset's table and rows and Db.pool()'s nine lines in the harness, only the URL in memory; the harness names no Db; findById(1) twice - prepareStatement 1 + SELECT 1 each, both on one connection (distinct 1); same object false, equal records true; exit 0; no database file in .harness/run/, in this folder or in the root"; }

# ---- exercise: the README's lines, then the solution's - in ONE shell, bash, then zsh (R.164, R.196) ---------------------------
# block FILE N: the Nth bash block of FILE
block() { awk -v n="${2:-1}" '/^```bash$/ { k++; if (k == n) f = 1; next } f && /^```$/ { f = 0 } f' "$1"; }
where() { case "$1" in "$U") echo "this unit's folder" ;; "$U"/*) echo "${1#"$U"/}" ;; *) echo "outside this unit's folder" ;; esac; }
exsh() { local sh=$1 i=0 e1 d1 e2 d2
  rm -f .harness/ex-*.st .harness/ex-*.out
  case $sh in bash) env -i HOME="$HOME" PATH="$XPATH" /bin/bash --noprofile --norc .harness/ex-drive.sh "$U" > .harness/ex-shell.out 2>&1 < /dev/null & xpid=$! ;;
              zsh) env -i HOME="$HOME" PATH="$XPATH" /bin/zsh -f .harness/ex-drive.sh "$U" > .harness/ex-shell.out 2>&1 < /dev/null & xpid=$! ;; esac
  while kill -0 "$xpid" 2> /dev/null && [ $i -lt 240 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$xpid" 2> /dev/null && { killtree "$xpid"; die "the exercise's $sh still ran after 60 s"; }
  wait "$xpid" || true; xpid=""
  [ -f .harness/ex-readme.st ] && [ -f .harness/ex-sol.st ] || { cat .harness/ex-shell.out .harness/ex-readme.out .harness/ex-sol.out 2> /dev/null | tail -20 >&3; die "the exercise's $sh did not reach the end of both blocks"; }
  read -r e1 d1 < .harness/ex-readme.st; read -r e2 d2 < .harness/ex-sol.st
  echo "in $sh ($( [ $sh = bash ] && echo '/bin/bash --noprofile --norc' || echo '/bin/zsh -f')) - the README's lines:"
  echo "  the block's exit $e1 · what it printed:"; sed 's/^/    /' .harness/ex-readme.out
  echo "  the shell is now in: $(where "$d1")"
  echo "  then the solution's lines, in the same shell - the block's exit $e2 · what it printed:"; sed 's/^/    /' .harness/ex-sol.out
  echo "  the shell is now in: $(where "$d2") · the shell's own output: $($G -c . .harness/ex-shell.out || true) lines"; }
exercise() { local setup sol
  setup=$(block exercise/README.md 1); sol=$(block exercise/SOLUTION.md 1)
  [ -n "$setup" ] && [ -n "$sol" ] || die "exercise/README.md or SOLUTION.md no longer gives its commands"
  [ -z "$(block exercise/README.md 2)" ] && [ -z "$(block exercise/SOLUTION.md 2)" ] || die "exercise/README.md and SOLUTION.md give one block each"
  [ "$(printf '%s\n' "$setup" | $G -c .)" = "$(printf '%s\n' "$sol" | $G -c .)" ] && [ "$(diff <(printf '%s\n' "$setup") <(printf '%s\n' "$sol") | $G -c '^[<>]')" = 2 ] || die "SOLUTION.md's block must be the README's with one line changed"
  printf '%s\n' "$setup" | sed -n 1p | $G -qE "^P='[^']+'\$" || die "exercise/README.md's first line must set the pattern, P='...'"
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
c_exercise() { local EXB EXZ b ER ES
  EXB=$(blk exercise "in bash" "in zsh"); EXZ=$(blk exercise "in zsh" "")
  for b in "$EXB" "$EXZ"; do
    ER=$(printf '%s\n' "$b" | sed '/^  then the solution.s lines/,$d'); ES=$(printf '%s\n' "$b" | sed -n '/^  then the solution.s lines/,$p')
    # the matched text at the matched lines, then the count (R.187, R.196): a pattern that gives 2 with the wrong text fails here
    [ "$(printf '%s\n' "$ER" | sed -n 's/^    //p' | sed -E 's/^ +//' | paste -sd'|' -)" = '54:.name()|56:.name()|112:MealType.valueOf|3' ] || die "exercise: the README as written - 54:.name() (the customer's name getter), 56:.name(), 112:MealType.valueOf, and 3"
    [ "$(printf '%s\n' "$ES" | sed -n 's/^    //p' | sed -E 's/^ +//' | paste -sd'|' -)" = '56:mealType().name()|112:MealType.valueOf|2' ] || die "exercise: the solution - exactly 56:mealType().name() and 112:MealType.valueOf, and 2 (the text at the lines, not the count alone)"
    has "$ER" "  the block's exit 0 · what it printed:" "exercise: the README's block exits 0"
    has "$ES" "  then the solution's lines, in the same shell - the block's exit 0 · what it printed:" "exercise: the solution's block exits 0"
    [ "$(printf '%s\n' "$b" | $G -c "^  the shell is now in: this unit's folder")" = 2 ] || die "exercise: the shell back in this folder after each block"
    has "$ES" "  the shell is now in: this unit's folder · the shell's own output: 0 lines" "exercise: the shell itself printed nothing"; done
  [ "$(printf '%s\n' "$EXB" | $G -v '^in ')" = "$(printf '%s\n' "$EXZ" | $G -v '^in ')" ] || die "exercise: bash and zsh print the same"
  # the solution's pattern is the list's fourth entry: the count the lesson speaks
  [ "$(block exercise/SOLUTION.md 1 | sed -n 1p)" = "P=$(printf '%s\n' "$PATTERNS" | sed -n 4p | sed "s/^[^$TAB]*$TAB//")" ] || die "exercise: SOLUTION.md's pattern must be the list's fourth, the enum conversions"
  EXQ='Your turn: the README counts enum conversions with a pattern that also catches a getter. Fix the pattern until it counts two.'
  $G -qxF -- "**Your turn:** ${EXQ#Your turn: }" exercise/README.md || die "exercise/README.md: the spoken exercise line"
  [ "$(printf '%s\n' "$EXQ" | wc -w | tr -d ' ')" -le 25 ] || die "exercise: the spoken line is over 25 words"
  echo "  exercise: bash and zsh alike - the README as written: 3 (54:.name(), 56:.name(), 112:MealType.valueOf - a getter among them); the solution: 2 (56:mealType().name(), 112:MealType.valueOf); broken 3 != solved 2, each block exit 0, the shell back in this folder"; }

# ---- the captures, each followed by its checks ------------------------------------------------------------------------------------
cap file file; c_file
cap count count; c_count
cap identity identity; c_identity
cap exercise exercise; c_exercise

# ---- hygiene: paths, times, pins - every capture, every file this unit ships -----------------------------------------------------
# no capture prints a path, a version token of the OS or the JDK, a time, a pid, a unit number other than Course 2's folder
# (the lesson opens c2-unit38's file by its path), an unmasked H2 object number or identity hash, or a stack frame
for f in .r-*.out; do
  ! $G -qE '/Users/|/private/|/home/|/var/folders/' "$f" || die "$f holds an absolute path"
  ! sed 's/c2-unit38//g' "$f" | $G -qE 'c[0-9]-unit[0-9]|unit ?[0-9]' || die "$f holds a unit number other than Course 2's folder"
  ! $G -qE ' (with PID|started by) | in [0-9.]+ seconds' "$f" || die "$f holds a process line or seconds"
  ! $G -qE '[0-9]{4}-[0-9]{2}-[0-9]{2}[T ][0-9]{2}:[0-9]{2}|[0-9]{2}:[0-9]{2}:[0-9]{2}' "$f" || die "$f holds a time"
  ! $G -qE 'using Java [0-9]|Darwin|arm64|aarch64' "$f" || die "$f holds an OS or a JDK version token (R.151)"
  ! $G -qE 'conn[0-9]|prep[0-9]' "$f" || die "$f holds an H2 object number, unmasked"
  ! $G -qE '/\*SQL [^*]* t:[0-9]' "$f" || die "$f holds H2's statement time (t:N)"
  ! $G -qE '@[0-9a-f]{5,}' "$f" || die "$f holds an identity hash, unmasked (they differ run to run)"
  ! $G -qE '^ +at [a-z]|Exception in thread' "$f" || die "$f holds a stack frame or an uncaught exception"; done
for f in .r-*.out; do ! $G -E '^ *\$ ' "$f" | $G -oE 'https?://[^ '"'"']+' > /dev/null || die "$f runs a command with a URL"; done
for f in .r-*.out; do ! $G -E '^ *\$ .*(^|[ &(])java ' "$f" | $G -vF -- "java $JL " > /dev/null || die "$f starts a JVM without its locale pinned (S6.1)"; done
for f in .r-*.out; do ! $G -E '^ *\$ ' "$f" | $G -E '(^|[ |(])grep ' | $G -vE "(^|[ |(])$G " > /dev/null || die "$f runs a bare grep - every count here is $G's"; done
K1='pki''ll'; K2='kill''all'; ! $G -v '^ *#' receipts.sh | $G -qwE "$K1|$K2" || die "receipts.sh names $K1 or $K2 - every process is stopped by its pid"
for f in receipts.sh exercise/README.md exercise/SOLUTION.md; do ! $G -nE '(^|[;&|({] *)wait *($|[;&|)}])' "$f" | $G -vE '^[0-9]+: *#' > /dev/null || die "$f has a bare wait (S6.9)"; done
# R.193: run options travel as an array - no variable holds several options in one string
for f in receipts.sh README.md exercise/README.md exercise/SOLUTION.md; do ! $G -nE '^[A-Za-z_][A-Za-z_0-9]*="?--[^ "]+ +--' "$f" > /dev/null || die "$f holds a one-string multi-option variable (R.193)"; done
! $G -qE '^package ' harness/C7Identity.java || die "harness/C7Identity.java must be in the default package, as Course 2's classes are"
[ "$(sed 's#//.*##' harness/C7Identity.java | $G -cw 'Db' || true)" = 0 ] || die "harness/C7Identity.java names Db - Db's static initialiser opens ./data/tiffinbox (R.195)"
! $G -rqw C7Identity anchor/tiffinbox-core anchor/tiffinbox-web || die "the anchor's code names the course's harness"
# R.195: no database file anywhere in this folder (.harness/ included) or in the repository's root, after every run
[ "$(dbfiles .)" = 0 ] && [ "$(rootdb)" = 0 ] || die "a database file or a data/ folder in this folder or in the repository's root: $(find . -path ./.m2-demo -prune -o \( -name '*.mv.db' -o -name '*.trace.db' -o -name data -type d \) -print | head -3 | paste -sd' ' -)"
[ ! -e $C2/target ] && [ ! -e $C2/data ] || die "$C2 gained a target/ or a data/"
echo "  hygiene: no path, no unit number but Course 2's folder, no time, no unmasked H2 object number or identity hash, no stack frame in any capture; every JVM's locale pinned; every count /usr/bin/grep's; no kill by name; no bare wait; options as arrays; the harness in the default package, naming no Db; no database file in this folder or the root; $C2 untouched"

D_=$(diff -rq -x .m2-demo -x target -x secrets anchor/ ../c7-tiffinbox 2>&1 || true); [ -z "$D_" ] || die "anchor/ is no longer ../c7-tiffinbox at the end"
for p in $PORTS; do [ "$(listeners $p)" = 0 ] || die "something listens on $p at the end"; done
echo "  ports: nothing listens on 19800-19809 at the end; none was bound"
[ -z "$unpub" ] || die "no published hash for:$unpub - check the captures, then copy the md5s above into receipts.md5 and run again"
echo "c7-unit01: every capture 3/3 and = published; every spoken number asserted; duration words 0; no database file; anchor/ = ../c7-tiffinbox (no anchor change)"
