#!/bin/bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25.0.4.1 on the author's Mac: point it at your JDK 25
XPATH=$PATH                                           # the PATH you started this with: the exercise's own shells get it
export PATH="$JAVA_HOME/bin:$PATH"
# Course 7 · The Persistence Context - this unit's receipts. No change to the anchor: anchor/ is the link to ../c7-unit03/after
# (= ../c7-tiffinbox, asserted below). Seven captures, each run three times and hashed; cap() DIES when a hash differs from
# receipts.md5; every number the video says is asserted by a check that can fail, right after its capture; the demo token is
# masked, and the checks count 0 raw copies of it in every capture and every log.
#   twofinds  A/B/A' - two finds of one customer: A in one TransactionTemplate; B (one flip: the harness's step) the same two finds
#             on the EntityManager Spring injects, no transaction, outside any request; A' = A. Each: the SELECT lines the SQL
#             logger printed between the step's markers AND Hibernate's Statistics, asserted equal; same object, with the two
#             identity hashes (masked: they differ run to run) and whether they are equal
#   own       C (labelled) - the same two finds, no transaction, on an EntityManager the code makes (emf.createEntityManager()):
#             contains, joinedToTransaction, its handler class and jar
#   request   C/D (labelled) - GET /probe/twofinds, two finds in a request with no transaction: C open-in-view as the anchor ships it
#             (false), D with --spring.jpa.open-in-view=true; one JVM each, curl against it, stopped by its pid
#   dirty     find, setMealsPerDay(3), no save: the SELECT, the marker "before commit", the UPDATE after it (all four columns), the
#             counts, and the anchor's own repository reading 3
#   boundary  what decides: the transaction manager read off the context and the injected EntityManager's handler read off the field,
#             each with its jar; the template's lines in the harness; then (labelled) H2's trace on Boot's URL: Course 2's
#             setAutoCommit(false) / commit() / setAutoCommit(true) counted for the two finds in a transaction and without one
#   tests     TiffinBox's tests on the anchor (the README's line, offline): Surefire's reports, the console's summary beside their sum
#   exercise  exercise/README.md's commands, then exercise/SOLUTION.md's, read from the files and run as written, in ONE env -i
#             shell - /bin/bash, then again in /bin/zsh -f
# The harness (harness/src, package probe.jpa, outside com.tiffinbox): Probe and Steps are the first-entity lesson's, byte for byte
# (../c7-unit03/harness, md5 asserted); Four (the configuration a run joins: --spring.main.sources=probe.jpa.Four), Pc (an
# ApplicationRunner that acts only when the run sets --probe.pc) and Web (GET /probe/twofinds) are this unit's. It is compiled with
# javac -parameters against the anchor's extracted jar into .harness/hc. Its run options travel as an array, V (R.193). Commands are
# printed exactly as they run: each goes through eval. harness/surefire.py (the testing lesson's, byte for byte) reads Surefire's
# reports; harness/dur7.py (Course 7's builders' duration pattern, byte for byte, md5 asserted) gates this unit's prose. "$M2" is
# this unit's own repository, .m2-demo.
# The locale: the JVM ignores LC_ALL on macOS - every JVM this script starts has its locale pinned on its run line (-Duser.language=en
# -Duser.country=US), and the checks refuse a java line without it; the test JVM's comes from the POM's argLine.
# The network: every Maven build runs offline (-o) against .m2-demo and says so ("offline: yes"); a build that cannot resolve an
# artifact offline goes to Maven Central once, and says that ("offline: no - ..."). At run time nothing leaves 127.0.0.1, and every
# database is H2 in this JVM's memory.
# Masks (README.md declares each; awk gsub only): the demo token "[masked: the N-character token]"; this folder "…", the folder
# above it "…/..", home "~", your user name "<user>"; " using Java <version>"; H2's generated database name "jdbc:h2:mem:<uuid>";
# an identity hash "@…"; H2's trace connection number "conn<n>". A JVM's log is never printed whole: the harness's PROBE lines, the
# lines of named loggers, an exception's first line and its distinct "Caused by" lines; WARN and ERROR lines counted; H2's trace
# lines counted, and the JDBC calls named printed. A Maven log: its BUILD line, Surefire's reports, the console's summary; the rest
# counted. No duration is captured.
# Ports (§P, 19830-19839): twofinds 19830 · own 19831 · request 19832 · dirty 19833 · boundary 19834 · exercise 19835 · 19839 never
# bound. Each port's runs are sequential, each JVM waited for by its pid before the next. 18425 (TiffinBox's default), 8080 and
# 35729 are checked free too, and never bound. tests binds none (Surefire's mock environment).
set -e
# bash 5.2 and later turn an & in the replacement of ${x/pattern/replacement} into the matched text (patsub_replacement, on by
# default). Switched off, so /bin/bash 3.2 (./receipts.sh) and a newer bash (bash receipts.sh) run the same commands.
shopt -u patsub_replacement 2> /dev/null || true
export LC_ALL=C
cd "$(dirname "$0")"
mkdir .r-lock 2> /dev/null || { echo "  *** another receipts.sh is running in this folder (.r-lock exists) - if none is, rmdir .r-lock ***"; exit 1; }
U="$PWD"; UP="$(cd .. && pwd)"; ME="$(id -un)"
# On every exit - the end, a failed check, or Ctrl-C - stop what this script started in the background, if it still runs: $pid (a
# JVM), $mpid (a Maven, with every process under it - Surefire's test JVM), $xpid (an exercise shell, with every process under it);
# then sweep(): anything of this run still alive in its process group - a TiffinBox JVM, a Maven, Surefire's fork - is stopped.
# After an interrupt a capture's unfinished runs (.r-NAME.1-3) go too; after a failed check they stay. The clean-up ignores a second
# Ctrl-C, and the script still exits 130 after an interrupt (README.md, "Interrupted"). No wait in this script is bare.
pid=""; mpid=""; xpid=""
sweep() { local g i l
  g=$(ps -o pgid= -p $$ 2> /dev/null | tr -d ' ') || g=""
  [ -n "$g" ] || return 0
  i=0; while [ $i -lt 20 ]; do
    l=$(ps -axo pid=,pgid=,command= 2> /dev/null | awk -v g="$g" -v me=$$ '
      $2 == g && $1 != me && $3 != "awk" && $3 != "ps" && (index($0, "tiffinbox-web-1.0.0.jar") || index($0, "com.tiffinbox.web.TiffinBoxServer") || index($0, "surefirebooter") || index($0, "org.codehaus.plexus.classworlds.launcher.Launcher")) { print $1 }' | paste -sd' ' -) || l=""
    [ -n "$l" ] || return 0
    if [ $i -lt 10 ]; then kill $l 2> /dev/null || true; else kill -9 $l 2> /dev/null || true; fi
    sleep 0.5; i=$((i + 1)); done; }
desc() { ps -axo pid=,ppid= 2> /dev/null | awk -v r="$1" '{ p[$1] = $2 } END { n = 1; q[1] = r; for (i = 1; i <= n; i++) for (c in p) if (p[c] == q[i]) { q[++n] = c; print c } }'; }
killtree() { local d; d=$(desc "$1"); kill "$1" $d 2> /dev/null || true; }
trap 'trap "" INT TERM; for p in "$mpid" "$xpid"; do [ -z "$p" ] || killtree "$p"; done; for p in "$pid" "$mpid" "$xpid"; do if [ -n "$p" ] && kill "$p" 2> /dev/null; then wait "$p" 2> /dev/null || true; fi; done; sweep || true; [ -z "$INTR" ] || rm -f .r-*.[123]; rmdir .r-lock 2> /dev/null || true' EXIT
INTR=""; trap 'INTR=1; exit 130' INT TERM
exec 3>&1                                            # die() speaks to the terminal even inside a redirected capture
die() { echo "  *** $* ***" >&3; exit 1; }
java -version 2>&1 | grep -q 'version "25' || die "JDK 25 needed; JAVA_HOME gives: $(java -version 2>&1 | head -1)"
javac -version 2>&1 | grep -q '^javac 25' || die "javac 25 needed (the harness is compiled with it)"
for t in python3 curl rsync lsof unzip mvn md5 cmp git /bin/zsh; do command -v $t > /dev/null || die "$t is needed"; done
# A variable of yours must not become a property source, a JVM flag or a build setting (the problem-detail lesson's loop: a canary
# planted under every name first, and the run stops if one survives).
for v in TIFFINBOX_CANARY SPRING_CANARY MANAGEMENT_CANARY SERVER_CANARY LOGGING_CANARY PROBE_CANARY DEBUG JAVA_TOOL_OPTIONS JDK_JAVA_OPTIONS _JAVA_OPTIONS MAVEN_ARGS; do export "$v=planted-canary"; done
for v in $(env | sed -n -E 's/^(TIFFINBOX_[A-Za-z0-9_]*|SPRING_[A-Za-z0-9_]*|MANAGEMENT_[A-Za-z0-9_]*|SERVER_[A-Za-z0-9_]*|LOGGING_[A-Za-z0-9_]*|PROBE_[A-Za-z0-9_]*|DEBUG|JAVA_TOOL_OPTIONS|JDK_JAVA_OPTIONS|_JAVA_OPTIONS|MAVEN_ARGS)=.*/\1/p'); do unset "$v"; done
[ -z "$(env | grep -- '=planted-canary$')" ] || die "a variable survived the clean-up above: $(env | grep -- '=planted-canary$' | sed 's/=.*//' | paste -sd' ' -)"
export no_proxy="127.0.0.1,localhost${no_proxy:+,$no_proxy}" NO_PROXY="127.0.0.1,localhost${NO_PROXY:+,$NO_PROXY}"
[ -e secrets ] && die "this folder holds a secrets/ - remove it: every run here starts in a folder under .harness/"
# No anchor change: anchor/ is the link to ../c7-unit03/after, which IS ../c7-tiffinbox, byte for byte (local repository and build
# output aside)
[ -L anchor ] && [ "$(readlink anchor)" = ../c7-unit03/after ] || die "anchor must be the link to ../c7-unit03/after - this unit changes nothing in the anchor"
[ -f anchor/pom.xml ] && [ -f anchor/README.md ] || die "the anchor (its pom.xml or README.md) is missing"
[ -e anchor/secrets ] || [ -e anchor/target ] || [ -e anchor/tiffinbox-web/target ] || [ -e anchor/tiffinbox-core/target ] || [ -e anchor/tiffinbox-local.yaml ] && die "anchor/ holds a secrets/, a target/ or a tiffinbox-local.yaml - it is a frozen copy, never built in place"
[ -d ../c7-tiffinbox ] || die "../c7-tiffinbox is missing"
D_=$(diff -rq -x .m2-demo -x target -x secrets anchor/ ../c7-tiffinbox 2>&1 || true)
[ -z "$D_" ] || die "anchor/ is not ../c7-tiffinbox: $(printf '%s\n' "$D_" | head -3 | paste -sd';' -)"
echo "  the anchor: anchor/ -> ../c7-unit03/after; diff -rq -x .m2-demo -x target -x secrets against ../c7-tiffinbox: empty - no anchor change"
M2="$PWD/.m2-demo"
CJ=tiffinbox-core/src/main/java/com/tiffinbox        # the core module's sources, in a tree
SR=tiffinbox-web/target/surefire-reports
XD=tiffinbox-web/target/extracted                    # the jar, extracted (the anchor's own line), in a tree
TF=secrets/tiffinbox/shutdown-token
TOKEN=demo-token-for-the-persistence-context
[ ${#TOKEN} = 38 ] || die "the demo token must be 38 characters: the captures name its length"
HS=harness/src/probe/jpa
for f in harness/surefire.py harness/dur7.py $HS/Probe.java $HS/Steps.java $HS/Four.java $HS/Pc.java $HS/Web.java exercise/README.md exercise/SOLUTION.md README.md receipts.md5; do [ -f "$f" ] || die "$f is missing"; done
[ "$(ls harness | paste -sd' ' -)" = 'dur7.py src surefire.py' ] && [ "$(cd harness/src && find . -type f | sed 's#^\./##' | sort | paste -sd' ' -)" = 'probe/jpa/Four.java probe/jpa/Pc.java probe/jpa/Probe.java probe/jpa/Steps.java probe/jpa/Web.java' ] || die "harness/ holds another file"
[ "$(ls exercise | paste -sd' ' -)" = 'README.md SOLUTION.md' ] || die "exercise/ holds another file"
cmp -s harness/surefire.py ../c6-unit28/harness/surefire.py || die "harness/surefire.py is not the testing lesson's (../c6-unit28/harness/surefire.py), byte for byte"
# the first-entity lesson's two harness files, byte for byte - by md5 (as that lesson committed them) and against the files themselves
[ "$(md5 -q $HS/Probe.java)" = fc0c06932cd2cd8c912f304328b367b8 ] && [ "$(md5 -q $HS/Steps.java)" = e316b9418711b0c142d3b7c7519d9215 ] || die "Probe.java / Steps.java are not the first-entity lesson's (md5 fc0c0693… / e316b941…)"
cmp -s $HS/Probe.java ../c7-unit03/$HS/Probe.java && cmp -s $HS/Steps.java ../c7-unit03/$HS/Steps.java || die "Probe.java / Steps.java differ from ../c7-unit03/harness's"
echo "  the harness: Probe.java fc0c06932cd2cd8c912f304328b367b8 and Steps.java e316b9418711b0c142d3b7c7519d9215 - the first-entity lesson's, byte for byte; Four, Pc, Web this unit's"
# Course 7's builders' duration pattern, byte for byte (Section 1 states no duration, R.172)
[ "$(md5 -q harness/dur7.py)" = 41667fed9ffcefe171389eed7e654e66 ] || die "harness/dur7.py is not the builders' dur7.py (md5 41667fed…)"
if [ -f ../../../data-jpa-hibernate/_builders/dur7.py ]; then cmp -s harness/dur7.py ../../../data-jpa-hibernate/_builders/dur7.py || die "harness/dur7.py differs from the builders' ../../../data-jpa-hibernate/_builders/dur7.py"
  echo "  (terminal only) harness/dur7.py = the builders' _builders/dur7.py, byte for byte" >&3
else echo "  (terminal only) the builders' _builders/dur7.py is not beside this clone: its md5 above is the check" >&3; fi
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
PORTS="18425 8080 35729 19830 19831 19832 19833 19834 19835 19839"
for p in $PORTS; do
  [ "$(listeners $p)" = 0 ] || die "something already listens on $p - this unit's ports must be free; if it is a process an interrupted run left behind, stop it: kill $(lsof -nP -iTCP:$p -sTCP:LISTEN -t 2> /dev/null | paste -sd' ' -)"; done
rm -rf .harness; mkdir -p .harness

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

# ---- the commands: read from anchor/README.md, the anchor's own, and asserted - each line must be there, whole -------------
readme() { grep -m1 -xF -- "$1" anchor/README.md > /dev/null || die "anchor/README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
R_PLAIN=$(readme 'mvn -B package')
R_TEST=$(readme 'mvn -B clean test')
R_EXTRACT=$(readme 'java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted')
R_CP=$(readme 'java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431')
R_HEALTH=$(readme "curl -s -w ' %{http_code}\n' http://127.0.0.1:18431/actuator/health")
# This unit's own lines (README.md, "The commands this unit adds") - each asserted to be exactly that
mine() { grep -m1 -xF -- "$1" README.md > /dev/null || die "README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
JL='-Duser.language=en -Duser.country=US'
XC=".harness/anchor/$XD/tiffinbox-web-1.0.0.jar:.harness/anchor/$XD/lib/*"     # the anchor's extracted jar, from this folder
L_H=$(mine "java $JL -cp \"../hc:tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*\" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431 \"\${V[@]}\"")
L_JAVAC=$(mine "javac -parameters -d .harness/hc -cp \"$XC\" $HS/Four.java $HS/Pc.java $HS/Probe.java $HS/Steps.java $HS/Web.java")
L_ROUTE=$(mine "curl -s -w ' %{http_code}\n' http://127.0.0.1:18431/probe/twofinds")
L_KILL=$(mine 'kill "$pid"')
# The derivations, each asserted: one change each, and nothing else
P_='java -cp "'; Q_="java $JL -cp \"../hc:"; [ "${R_CP/"$P_"/$Q_} \"\${V[@]}\"" = "$L_H" ] || die "the harness line must be the anchor's extracted-jar line with $JL, ../hc first on the class path and the options array after it, and nothing else"
P_=/actuator/health; Q_=/probe/twofinds; [ "${R_HEALTH/"$P_"/$Q_}" = "$L_ROUTE" ] || die "the route's curl must be the anchor's health line with the path /probe/twofinds, and nothing else"
off() { local c=${2/mvn -B /mvn -o -B -Dmaven.repo.local=\"\$M2\" }
  [ -n "${3:-}" ] && c=${c/ $3/ clean $3}
  printf 'cd %s && %s\n' "$1" "$c"; }
# at DIR PORT 'README LINE': the README's line run from DIR, its port 18431 made PORT
at() { local l=${3/--tiffinbox.port=18431/--tiffinbox.port=$2}; printf 'cd %s && %s\n' "$1" "$l"; }
# hl PORT: the harness line, run from .harness/anchor, its port made PORT
hl() { at .harness/anchor "$1" "$L_H"; }
url() { printf '%s\n' "${1/:18431\//:$2/}"; }
exe() { printf '%s\n' "$1" | sed -E 's/&& (([A-Z_]+=[^ ]* )*)/\&\& \1exec /'; }
[ "$(exe "$(hl 19830)")" = "cd .harness/anchor && exec java $JL -cp \"../hc:tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*\" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19830 \"\${V[@]}\"" ] || die "hl(): the run line is not README.md's"
echo "  the commands: anchor/README.md gives the $(grep -c '^R_[A-Z]*=$(readme ' receipts.sh) lines this script runs or derives from; README.md the $(grep -c '^L_[A-Z0-9]*=$(mine ' receipts.sh) this unit adds"
JV=$(java -version 2>&1 | sed -n 's/.*version "\([^"]*\)".*/\1/p' | head -1)
echo "  (terminal only) the JDK is $JV - Boot's first line names it; the captures say Java <version>" >&3

# ---- build: before the captures - the anchor copied and built with the README's package line, offline (its tests run); its jar
# ---- extracted (the anchor's line); the harness compiled against it ------------------------------------------------------------
mbuild() { local how=yes ec=0 c=$1
  (eval "$c") > "$2" 2>&1 < /dev/null & mpid=$!; wait "$mpid" || ec=$?; mpid=""
  if [ $ec != 0 ] && grep -qE 'offline mode|Could not resolve|could not be resolved|Cannot access|No plugin found for prefix' "$2"; then
    how="no - the offline build could not resolve an artifact, so Maven Central was asked"; ec=0
    (eval "${c/mvn -o -B /mvn -B }") > "$2" 2>&1 < /dev/null & mpid=$!; wait "$mpid" || ec=$?; mpid=""; fi
  [ $ec = 0 ] || { tail -30 "$2" >&3
    ! grep -qE 'Could not resolve|could not be resolved|Could not transfer|Cannot access' "$2" || die "build failed: $3 - Maven could resolve Boot's parent and plugins neither from .m2-demo nor from Maven Central: a fresh clone's first run needs .m2-demo seeded (README.md, The repository) or the network once"
    die "build failed: $3"; }
  echo "  built $3 · offline: $how · exit $ec"; }
tree() { mkdir -p "$1/secrets/tiffinbox"; (umask 077 && printf '%s\n' "$TOKEN" > "$1/$TF"); chmod 700 "$1/secrets" "$1/secrets/tiffinbox"; }
copy() { rm -rf "$2"; rsync -a --exclude target --exclude secrets --exclude .m2-demo "$1/" "$2/"; tree "$2"; }
copy anchor .harness/anchor
mbuild "$(off .harness/anchor "$R_PLAIN" package)" .harness/build-anchor.log ".harness/anchor (the anchor, the README's package line; its tests ran)"
for a in org/springframework/boot/spring-boot-starter-parent/4.1.2/spring-boot-starter-parent-4.1.2.pom org/hibernate/orm/hibernate-core/7.4.13.Final/hibernate-core-7.4.13.Final.jar org/springframework/boot/spring-boot-starter-data-jpa/4.1.2/spring-boot-starter-data-jpa-4.1.2.jar; do
  [ -e "$M2/$a" ] || die "$a is not in .m2-demo after the build - README.md, The repository"; done
(cd .harness/anchor && eval "$R_EXTRACT") > .harness/extract.log 2>&1 < /dev/null || die "the extract failed: $(tail -3 .harness/extract.log)"
mkdir -p .harness/hc; (eval "$L_JAVAC") > .harness/javac.log 2>&1 < /dev/null || die "the harness did not compile: $(head -5 .harness/javac.log)"
echo "  extracted the anchor's jar ($(ls .harness/anchor/$XD/lib | wc -l | tr -d ' ') libraries) and compiled the harness into .harness/hc"

# ---- helpers ------------------------------------------------------------------------------------------------------------
raw() { local t=$1; shift; cat "$@" 2> /dev/null | LC_ALL=C grep -aoF -- "$t" | wc -l | tr -d ' '; }
LOGS=0
first() { grep -m1 -E ' : Starting ' "$1" | sed 's/^.* : //; s/ with PID .*$//; s/ using Java [0-9][0-9.]*/ using Java <version>/'; }
sec() { local s; s=$(cd "$1/secrets" 2> /dev/null && find . -type f | sed 's#^\./##' | sort | paste -sd' ' -)
  [ "$s" = tiffinbox/shutdown-token ] || die "$1/secrets holds more than the token's file (${s:-nothing}) - every file there is a key (R.158)"
  echo "  secrets/ before the start: $s - the token's file, and nothing else"; }
addrs() { lsof -nP -a -p "$1" -iTCP -sTCP:LISTEN 2> /dev/null | awk 'NR > 1 { print $9 }' | sort -u | paste -sd' ' -; }
listening() { local a="" i=0
  while [ $i -lt 480 ]; do a=$(addrs "$1"); case " $a " in *":$2 "*) break ;; esac; kill -0 "$1" 2> /dev/null || break; sleep 0.25; i=$((i + 1)); done
  echo "${a:-nothing}"; }
lb() { local a n=0; for a in $1; do n=$((n + 1)); case $a in 127.0.0.1:*) ;; *) echo no; return ;; esac; done; [ $n -gt 0 ] && echo yes || echo no; }
up() { local l; l=$(listening "$pid" "$1"); [ "$l" != nothing ] || { tail -20 .harness/run.out >&3; die "it never listened on $1"; }
  case " $l " in *':8080 '*|*':35729 '*|*':19839 '*) kill -9 "$pid" 2> /dev/null || true; die "it listened on 8080, 35729 or 19839 - never bound by this script";; esac
  echo "  listens on: $l · loopback only: $(lb "$l")"; echo "  Boot's first line: $(first .harness/run.out)"; }
ready() { local i=0 c=""
  while [ $i -lt 480 ]; do c=$(curl -s -o /dev/null -w '%{http_code}' "http://127.0.0.1:$1/actuator/health/readiness" 2> /dev/null || true); [ "$c" = 200 ] && break
    kill -0 "$pid" 2> /dev/null || { tail -20 .harness/run.out >&3; die "it exited before readiness answered 200"; }
    sleep 0.25; i=$((i + 1)); done
  [ "$c" = 200 ] || die "readiness never answered 200 on $1"; }
logtok() { local t; t=$(raw "$TOKEN" "${1:-.harness/run.out}"); LOGS=$((LOGS + 1)); [ "$t" = 0 ] || die "a log held the demo token ($t)"
  echo "  its log: the demo token 0 times"; }
lvl() { grep -cE "^[0-9]{4}-[0-9]{2}-[0-9]{2}T[^ ]+ +$1 " "$2" || true; }
# jlog FILE: which database the run's pool opened (Hikari's line), Hibernate's version line, WARN/ERROR counted
jlog() { local h v
  h=$(grep -m1 -oE 'HikariPool-1 - Added connection conn0: url=[^ ]+' "$1" || true); v=$(grep -m1 -oE 'HHH000001: Hibernate ORM core version [^ ]+' "$1" || true)
  echo "  its pool: ${h:-no Hikari line - no DataSource pool in this run} · Hibernate: ${v:-no Hibernate line} · WARN lines: $(lvl WARN "$1") · ERROR lines: $(lvl ERROR "$1")"; }
mask() { awk -v t="$TOKEN" -v u="$U" -v up="$UP" -v hm="$HOME" -v me="$ME" -v tl="${#TOKEN}" '
  function lit(x) { gsub(/[][\\.^$*+?(){}|\/]/, "\\\\&", x); return x }
  function enc(x) { gsub(/ /, "%20", x); return x }
  BEGIN { T = lit(t); P = lit(u); Q = lit(up); H = lit(hm); PE = lit(enc(u)); QE = lit(enc(up)); M = "(^|[^A-Za-z0-9_])" lit(me) "([^A-Za-z0-9_]|$)" }
  { gsub(T, "[masked: the " tl "-character token]"); gsub(P, "…"); gsub(PE, "…"); gsub(Q, "…/.."); gsub(QE, "…/.."); gsub(H, "~")
    gsub(/ using Java [0-9][0-9.]+/, " using Java <version>")
    gsub(/jdbc:h2:mem:[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]-[0-9a-f-]+/, "jdbc:h2:mem:<uuid>")
    gsub(/@[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]+/, "@…")
    gsub(/\/\*\*\/conn[0-9]+\./, "/**/conn<n>.")
    while (match($0, M)) { pre = substr($0, 1, RSTART - 1); s = substr($0, RSTART, RLENGTH); post = substr($0, RSTART + RLENGTH)
      sub(lit(me), "<user>", s); $0 = pre s post }
    print }'; }
printf '%s\n' 'Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1' 'url=jdbc:h2:mem:184c1fae-3bb5-4208-80fb-a59190f705ec user=SA' "$TOKEN" 'PROBE   same object (a == b): false | identityHashCode @3446ab40 @43851574' '    /**/conn11.setAutoCommit(false);' > .harness/p1
[ "$(mask < .harness/p1)" = "$(printf '%s\n' 'Starting TiffinBoxServer v1.0.0 using Java <version>' 'url=jdbc:h2:mem:<uuid> user=SA' '[masked: the 38-character token]' 'PROBE   same object (a == b): false | identityHashCode @… @…' '    /**/conn<n>.setAutoCommit(false);')" ] || die "mask: the planted JDK version, generated database name, token, identity hashes and connection number must be masked"
# view FILE 'LOGGER-REGEX': a run's log, in order: the harness's PROBE lines, the lines of the named loggers (level, logger:
# message; "Started TiffinBoxServer" without its seconds; a message over 260 characters cut there), and for an ERROR line of
# SpringApplication ("Application run failed") the exception's first line and each distinct "Caused by:" line (at most four,
# each cut at 260 characters); its frames, H2's trace lines and the rest counted, never shown
view() { awk -v pat="$2" '
  function cut(x) { gsub(/@[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]+/, "@…", x); sub(/[ \t]+$/, "", x); return length(x) > 260 ? substr(x, 1, 260) " … (" length(x) - 260 " more characters)" : x }
  /^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T[^ ]+ +[A-Z]+ [0-9]+ --- \[/ { ex = 0
    s = $0; i = index(s, " --- ["); s = substr(s, i + 6); i = index(s, "] "); s = substr(s, i + 2)
    i = index(s, " : "); lg = substr(s, 1, i - 1); sub(/ +$/, "", lg); m = substr(s, i + 3)
    if (m ~ /^Starting /) next
    if (m ~ /^Started TiffinBoxServer in /) m = "Started TiffinBoxServer"
    if (lg ~ /SpringApplication$/ && $2 == "ERROR") { print "    " $2 " " lg ": " cut(m); ex = 1; nc = 0; delete seen; next }
    if (lg ~ pat) print "    " $2 " " lg ": " cut(m)
    next }
  /^PROBE / { ex = 0; print "  " cut($0); next }
  ex == 1 && NF > 0 && !/^\tat / && !/^\t\.\.\. / && !/^Caused by: / { print "      " cut($0); ex = 2; next }
  ex && /^Caused by: / { c = cut($0); if (!(c in seen) && nc < 4) { seen[c] = 1; nc++; print "      " c } }' "$1"; }
# vshow: the options array as a line you can paste - an element with a shell character in it single-quoted
vshow() { local e o=""; for e in "${V[@]}"; do case $e in *[\;\&\|\<\>\(\)\$\`\"\'\ \*\?]*) e="'$e'" ;; esac; o="$o $e"; done; printf '%s\n' "${o# }"; }
# hrun PORT: the harness line (V, the options array, set by the caller), run from .harness/anchor; it starts, runs its steps and
# exits by itself (bounded: 120 s); its exit code in HE; nothing left listening on PORT
HE=""
hrun() { local c i=0 e=0
  c=$(hl "$1"); sec .harness/anchor
  echo "\$ V=($(vshow))"
  echo "\$ $c"
  (eval "$(exe "$c")") > .harness/run.out 2>&1 < /dev/null & pid=$!
  while kill -0 "$pid" 2> /dev/null && [ $i -lt 480 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$pid" 2> /dev/null && { kill "$pid"; die "the harness run on $1 was still running after 120 s"; }
  wait "$pid" || e=$?; pid=""; HE=$e
  [ "$(listeners "$1")" = 0 ] || die "something still listens on $1 after the harness run"
  logtok > /dev/null; }
# hres: the run's end - its exit code, Boot's first line, which database its pool opened, the counts
hres() { echo "  exit $HE · Boot's first line: $(first .harness/run.out)"; jlog .harness/run.out; }
HV=(--spring.main.sources=probe.jpa.Four --spring.jpa.properties.hibernate.generate_statistics=true)    # every harness run's two
SQLD=--logging.level.org.hibernate.SQL=debug
unpub=""
cap() { local nm=$1 h pub i; shift
  for i in 1 2 3; do "$@" > .harness/cap.raw 2>&1 || true; [ -z "$pid$mpid$xpid" ] || die "$nm left a process running"
    raw "$TOKEN" .harness/cap.raw > ".harness/raw-$nm.$i"; mask < .harness/cap.raw > ".r-$nm.$i"; done
  h=$(md5 -q ".r-$nm.1")
  [ "$h" = "$(md5 -q ".r-$nm.2")" ] && [ "$h" = "$(md5 -q ".r-$nm.3")" ] || die "$nm drifts across three runs (diff .r-$nm.1 .r-$nm.2 .r-$nm.3)"
  mv ".r-$nm.1" ".r-$nm.out"; rm -f ".r-$nm.2" ".r-$nm.3"
  pub=$(awk -v n="$nm" '$1 == n { print $2 }' receipts.md5 2> /dev/null || true)
  if [ -z "$pub" ]; then printf '  %-9s md5 %s  3/3  (no published hash)\n' "$nm" "$h"; unpub="$unpub $nm"
  elif [ "$pub" = "$h" ]; then printf '  %-9s md5 %s  3/3  = published\n' "$nm" "$h"
  else printf '  %-9s md5 %s  3/3  DIFFERS from the published %s\n' "$nm" "$h" "$pub"
    die "$nm is not the published capture - suspect another JDK, Boot or Maven, a busy machine, a busy port, a variable of yours, or an edited source; diff .r-$nm.out against its block in README.md"; fi; }
summ() { grep -E '^\[(INFO|ERROR|WARNING)\] Tests run: [0-9]+, Failures: [0-9]+, Errors: [0-9]+, Skipped: [0-9]+$' "$1" | tail -1 | sed -E 's/.*Tests run: ([0-9]+), Failures: ([0-9]+), Errors: ([0-9]+), Skipped: ([0-9]+)$/tests \1 · failures \2 · errors \3 · skipped \4/'; }
# reports DIR LOG: Surefire's reports (harness/surefire.py), then the console's summary beside their sum (R.144)
reports() { local s t
  python3 -I harness/surefire.py "$1/$SR" | sed 's/^/  /'
  s=$(summ "$2"); t=$(python3 -I harness/surefire.py "$1/$SR" | sed -n 's/^  in all: [0-9]* reports · //p')
  echo "  Surefire's console summary (its Results line): ${s:-none} · the reports' sum the same: $( [ -n "$s" ] && [ "$s" = "$t" ] && echo yes || echo no)"; }
# Checks: each reads a line a program computed - the harness's own line, a count of log lines - never a label printed unconditionally
x() { grep -qE -- "$2" ".r-$1.out" || die "$1: expected /$2/"; }
blk() { awk -v a="$2" -v b="$3" 'index($0, a) == 1 { f = 1; next } b != "" && index($0, b) == 1 { f = 0 } f' ".r-$1.out"; }
has() { printf '%s\n' "$1" | grep -qxF -- "$2" || die "$3: expected the line: $2"; }
nhas() { ! printf '%s\n' "$1" | grep -qF -- "$2" || die "$3: did not expect: $2"; }
cnt() { printf '%s\n' "$1" | grep -cxF -- "$2" || true; }
SEL=' org\.hibernate\.SQL  *: select '
# between FILE STEP REGEX: the log's lines matching REGEX between the harness's "PROBE STEP begin" and "PROBE STEP end", counted
between() { awk -v a="PROBE $2 begin" -v b="PROBE $2 end" -v p="$3" 'index($0, a) == 1 { f = 1; next } index($0, b) == 1 { f = 0 } f && $0 ~ p { n++ } END { print n + 0 }' "$1"; }
# twit STEP: the two witnesses of one step's statement count (R.184) - the SQL logger's SELECT lines between its markers, and
# Hibernate's Statistics (the step's own counts line) - and whether they agree
twit() { local l s
  l=$(between .harness/run.out "$1" "$SEL"); s=$(sed -n "s/^PROBE $1 | statements \([0-9]*\) .*/\1/p" .harness/run.out | head -1)
  echo "  the two witnesses - SELECT lines the SQL logger printed between '$1 begin' and its end: $l · Statistics: statements ${s:-none} · they agree: $( [ -n "$s" ] && [ "$l" = "$s" ] && echo yes || echo no)"; }

# ---- twofinds: two finds of one customer, in a transaction and without one ---------------------------------------------------
twofinds() {
  echo "A - the anchor and the harness (step twofinds-tx: both finds in one TransactionTemplate), Hibernate's SQL logger at DEBUG, port 19830:"
  V=("${HV[@]}" --probe.pc=twofinds-tx "$SQLD"); hrun 19830; view .harness/run.out 'org\.hibernate\.SQL'; twit twofinds-tx; hres
  echo "B - A with one flip, the harness's step: twofinds-notx (the same two finds on the EntityManager Spring injects, no transaction, an ApplicationRunner - outside any request), port 19830:"
  V=("${HV[@]}" --probe.pc=twofinds-notx "$SQLD"); hrun 19830; view .harness/run.out 'org\.hibernate\.SQL'; twit twofinds-notx; hres
  echo "A' - A again (a fresh JVM), port 19830:"
  V=("${HV[@]}" --probe.pc=twofinds-tx "$SQLD"); hrun 19830; view .harness/run.out 'org\.hibernate\.SQL'; twit twofinds-tx; hres; }
c_twofinds() { local TA TB TA2 b
  TA=$(blk twofinds "A - the anchor" "B - A with"); TB=$(blk twofinds "B - A with" "A' - A again"); TA2=$(blk twofinds "A' - A again" "")
  for b in "$TA" "$TA2"; do
    for l in "  the two witnesses - SELECT lines the SQL logger printed between 'twofinds-tx begin' and its end: 1 · Statistics: statements 1 · they agree: yes" \
        '  PROBE twofinds-tx | statements 1 | loads 1 | updates 0 | flushes 1 | transactions 1' '  PROBE   same object (a == b): true | identityHashCode @… @… | the pair equal: true' \
        '  PROBE   in a transaction: true' '  PROBE   first find -> Ravi | second -> Ravi' \
        '    DEBUG org.hibernate.SQL: select ce1_0.id,ce1_0.meal_type,ce1_0.meals_per_day,ce1_0.name,ce1_0.price_per_meal from customer ce1_0 where ce1_0.id=?' \
        '  its pool: HikariPool-1 - Added connection conn0: url=jdbc:h2:mem:tiffinbox · Hibernate: HHH000001: Hibernate ORM core version 7.4.13.Final · WARN lines: 0 · ERROR lines: 0'; do has "$b" "$l" "twofinds A: one SELECT, one object"; done
    printf '%s\n' "$b" | grep -qE '^  exit 0 · ' || die "twofinds A: exit 0"; done
  [ "$(printf '%s\n' "$TA" | grep -v '^\$ ')" = "$(printf '%s\n' "$TA2" | grep -v '^\$ ')" ] && [ "$(printf '%s\n' "$TA" | grep '^\$ ')" = "$(printf '%s\n' "$TA2" | grep '^\$ ')" ] || die "twofinds: A' = A, line for line"
  for l in "  the two witnesses - SELECT lines the SQL logger printed between 'twofinds-notx begin' and its end: 2 · Statistics: statements 2 · they agree: yes" \
      '  PROBE twofinds-notx | statements 2 | loads 2 | updates 0 | flushes 0 | transactions 0' '  PROBE   same object (a == b): false | identityHashCode @… @… | the pair equal: false' \
      '  PROBE   in a transaction: false' '  PROBE   contains the first, asked afterwards: false'; do has "$TB" "$l" "twofinds B: two SELECTs, two objects"; done
  printf '%s\n' "$TB" | grep -qE '^  exit 0 · ' || die "twofinds B: exit 0"
  [ "$(printf '%s\n' "$TB" | grep -cE '^    DEBUG org\.hibernate\.SQL: select ')" = 2 ] && [ "$(printf '%s\n' "$TA" | grep -cE '^    DEBUG org\.hibernate\.SQL: select ')" = 1 ] || die "twofinds: the SELECT lines shown, 1 (A) and 2 (B)"
  echo "  twofinds: A in one TransactionTemplate - 1 SELECT (the log's line and Statistics' statements 1), the same object; B no transaction, the injected EntityManager - 2 SELECTs (2 and 2), two objects, contains false; A' = A"; }

# ---- own: an EntityManager the code makes ----------------------------------------------------------------------------------------
own() {
  echo "C (labelled: another EntityManager) - the anchor and the harness (step own: emf.createEntityManager(), two finds, no transaction), Hibernate's SQL logger at DEBUG, port 19831:"
  V=("${HV[@]}" --probe.pc=own "$SQLD"); hrun 19831; view .harness/run.out 'org\.hibernate\.SQL'; twit own; hres; }
c_own() { local O; O=$(cat .r-own.out)
  for l in "  the two witnesses - SELECT lines the SQL logger printed between 'own begin' and its end: 1 · Statistics: statements 1 · they agree: yes" \
      '  PROBE own | statements 1 | loads 1 | updates 0 | flushes 0 | transactions 0' '  PROBE   same object (a == b): true | identityHashCode @… @… | the pair equal: true' \
      '  PROBE   in a transaction: false' '  PROBE   contains true | joinedToTransaction false' \
      '  PROBE   a JDK proxy: true | handler org.springframework.orm.jpa.ExtendedEntityManagerCreator$ExtendedEntityManagerInvocationHandler (in spring-orm-7.0.10.jar)'; do has "$O" "$l" "own: one SELECT, one object, no transaction"; done
  printf '%s\n' "$O" | grep -qE '^  exit 0 · ' || die "own: exit 0"
  echo "  own: emf.createEntityManager(), no transaction - 1 SELECT (1 and 1), the same object, contains true, joinedToTransaction false; handler ExtendedEntityManagerCreator\$ExtendedEntityManagerInvocationHandler (spring-orm-7.0.10)"; }

# ---- request: two finds in an HTTP request, no transaction - open-in-view decides ---------------------------------------------
# hstart PORT: the harness line with V (no --probe.pc: the JVM serves), run from .harness/anchor, in the background
hstart() { local c; c=$(hl "$1"); sec .harness/anchor; echo "\$ V=($(vshow))"; echo "\$ $c"; (eval "$(exe "$c")") > .harness/run.out 2>&1 < /dev/null & pid=$!; }
# byPid PORT: stop the JVM by its pid (SIGTERM), wait for it; its exit code; nothing left listening
byPid() { local e=0; echo "\$ $L_KILL    (\$pid: the JVM this capture started)"; kill "$pid"; wait "$pid" || e=$?; pid=""
  [ "$(listeners "$1")" = 0 ] || die "something still listens on $1 after the stop"
  echo "  exit $e · listening on $1 now: 0"; }
rq() { local c l s
  up 19832; ready 19832
  c=$(url "$L_ROUTE" 19832); echo "\$ $c"; (eval "$c") < /dev/null > .harness/route.txt 2>&1 || true; sed 's/^/  /' .harness/route.txt
  byPid 19832
  view .harness/run.out 'org\.hibernate\.SQL'
  l=$(grep -cE "$SEL" .harness/run.out || true); s=$(sed -n 's/.* | statements \([0-9]*\) | .*/\1/p' .harness/route.txt | head -1)
  echo "  the two witnesses - SELECT lines the SQL logger printed in this JVM (the request's alone: Hibernate wrote no SQL at the start): $l · the route's Statistics: statements ${s:-none} · they agree: $( [ -n "$s" ] && [ "$l" = "$s" ] && echo yes || echo no)"
  jlog .harness/run.out; logtok; }
request() {
  echo "C (labelled: in a request) - the anchor and the harness, no step: the JVM serves; open-in-view as the anchor ships it (application.yaml: false), port 19832:"
  V=("${HV[@]}" "$SQLD"); hstart 19832; rq
  echo "D (labelled: C with one flip) - --spring.jpa.open-in-view=true, port 19832:"
  V=("${HV[@]}" "$SQLD" --spring.jpa.open-in-view=true); hstart 19832; rq; }
c_request() { local C D
  C=$(blk request "C (labelled" "D (labelled"); D=$(blk request "D (labelled" "")
  printf '%s\n' "$C" | grep -qE '^  open-in-view: property false \| OpenEntityManagerInViewInterceptor beans 0 \| ' || die "request C: open-in-view must be false here, the anchor's own value (interceptor beans 0) - C is labelled with no open-in-view option"
  printf '%s\n' "$D" | grep -qE '^  open-in-view: property true \| OpenEntityManagerInViewInterceptor beans 1 \| ' || die "request D: open-in-view must be true here (interceptor beans 1) - D is labelled with the one flip"
  has "$C" '  open-in-view: property false | OpenEntityManagerInViewInterceptor beans 0 | same object (a == b): false | in a transaction: false | statements 2 | loads 2 200' "request C: open-in-view false - 2 statements, two objects"
  has "$C" '  the two witnesses - SELECT lines the SQL logger printed in this JVM (the request'"'"'s alone: Hibernate wrote no SQL at the start): 2 · the route'"'"'s Statistics: statements 2 · they agree: yes' "request C: 2 SELECT lines"
  has "$D" '  open-in-view: property true | OpenEntityManagerInViewInterceptor beans 1 | same object (a == b): true | in a transaction: false | statements 1 | loads 1 200' "request D: open-in-view true - 1 statement, one object"
  has "$D" '  the two witnesses - SELECT lines the SQL logger printed in this JVM (the request'"'"'s alone: Hibernate wrote no SQL at the start): 1 · the route'"'"'s Statistics: statements 1 · they agree: yes' "request D: 1 SELECT line"
  nhas "$C" 'open-in-view=true' "request C: no open-in-view option"; has "$D" '$ V=(--spring.main.sources=probe.jpa.Four --spring.jpa.properties.hibernate.generate_statistics=true --logging.level.org.hibernate.SQL=debug --spring.jpa.open-in-view=true)' "request D: the one flip, named"
  for b in "$C" "$D"; do has "$b" '  exit 143 · listening on 19832 now: 0' "request: each JVM stopped by its pid (SIGTERM: 143)"; has "$b" '  listens on: 127.0.0.1:19832 · loopback only: yes' "request: loopback"; done
  echo "  request: GET /probe/twofinds, no transaction - C open-in-view false (interceptor beans 0): 2 SELECTs (log 2, Statistics 2), two objects; D open-in-view=true (beans 1): 1 (1 and 1), the same object; each JVM stopped by its pid"; }

# ---- dirty: a field changed, no save - and an UPDATE at the commit -------------------------------------------------------------
dirty() { local l s
  echo "the anchor and the harness (step dirty), Hibernate's SQL logger at DEBUG and its bind logger at TRACE, port 19833 - in the order the log printed them:"
  V=("${HV[@]}" --probe.pc=dirty "$SQLD" --logging.level.org.hibernate.orm.jdbc.bind=trace); hrun 19833; view .harness/run.out 'org\.hibernate\.SQL|org\.hibernate\.orm\.jdbc\.bind'; hres
  echo "  the order around the marker 'before commit' (R.197): $(awk '
    index($0, "PROBE dirty begin") == 1 { a = 1; next }
    a && !m && / org\.hibernate\.SQL  *: select / { s++ }
    a && !m && / org\.hibernate\.SQL  *: update / { ub++ }
    index($0, "PROBE   field set to 3, no save called, before commit") == 1 { m = 1; next }
    m && !e && / org\.hibernate\.SQL  *: update customer / { u++ }
    index($0, "PROBE dirty end - after commit") == 1 { e = 1 }
    END { printf "SELECTs before it: %d · UPDATEs before it: %d · UPDATEs after it, before after commit: %d", s, ub, u }' .harness/run.out)"
  l=$(between .harness/run.out dirty ' org\.hibernate\.SQL  *: '); s=$(sed -n 's/^PROBE dirty | statements \([0-9]*\) .*/\1/p' .harness/run.out | head -1)
  echo "  the two witnesses - SQL lines between 'dirty begin' and its end: $l · Statistics: statements ${s:-none} · they agree: $( [ -n "$s" ] && [ "$l" = "$s" ] && echo yes || echo no)"; }
c_dirty() { local DY; DY=$(cat .r-dirty.out)
  for l in "  the order around the marker 'before commit' (R.197): SELECTs before it: 1 · UPDATEs before it: 0 · UPDATEs after it, before after commit: 1" \
      '    DEBUG org.hibernate.SQL: select ce1_0.id,ce1_0.meal_type,ce1_0.meals_per_day,ce1_0.name,ce1_0.price_per_meal from customer ce1_0 where ce1_0.id=?' \
      '  PROBE   loaded: Ravi | mealsPerDay 2' '  PROBE   field set to 3, no save called, before commit' \
      '    DEBUG org.hibernate.SQL: update customer set meal_type=?,meals_per_day=?,name=?,price_per_meal=? where id=?' \
      '    TRACE org.hibernate.orm.jdbc.bind: binding parameter (1:VARCHAR) <- [VEG]' '    TRACE org.hibernate.orm.jdbc.bind: binding parameter (2:INTEGER) <- [3]' \
      '    TRACE org.hibernate.orm.jdbc.bind: binding parameter (3:VARCHAR) <- [Ravi]' '    TRACE org.hibernate.orm.jdbc.bind: binding parameter (4:INTEGER) <- [120]' '    TRACE org.hibernate.orm.jdbc.bind: binding parameter (5:BIGINT) <- [1]' \
      '  PROBE dirty | statements 2 | loads 1 | updates 1 | flushes 1 | transactions 1' "  PROBE anchor repo reads Ravi's mealsPerDay: 3" \
      "  the two witnesses - SQL lines between 'dirty begin' and its end: 2 · Statistics: statements 2 · they agree: yes"; do has "$DY" "$l" "dirty"; done
  printf '%s\n' "$DY" | grep -qE '^  exit 0 · ' || die "dirty: exit 0"
  echo "  dirty: SELECT, then the marker 'before commit', then update customer set meal_type=?,meals_per_day=?,name=?,price_per_meal=? where id=? (all four columns, 5 binds) - no save called; statements 2 = 2 SQL lines, updates 1; the anchor's repository reads 3"; }

# ---- boundary: what decides - the transaction manager, the injected EntityManager, and Course 2's JDBC calls under them ---------
TRL='^/[*][*]/conn[0-9]+[.](setAutoCommit[(](true|false)[)]|commit[(][)]|rollback[(][)]);$'
tcnt() { echo "setAutoCommit(false) $(between .harness/run.out "$1" '^/[*][*]/conn[0-9]+[.]setAutoCommit[(]false[)];$') · commit() $(between .harness/run.out "$1" '^/[*][*]/conn[0-9]+[.]commit[(][)];$') · setAutoCommit(true) $(between .harness/run.out "$1" '^/[*][*]/conn[0-9]+[.]setAutoCommit[(]true[)];$') · rollback() $(between .harness/run.out "$1" '^/[*][*]/conn[0-9]+[.]rollback[(][)];$')"; }
boundary() {
  echo "the template's lines - the harness's Pc.java, where a step has a boundary:"
  grep -nE 'new TransactionTemplate\(tm\)|tx\.execute' $HS/Pc.java | sed -E 's/^([0-9]+): +/  Pc.java line \1: /'
  echo "the anchor and the harness (step boundary: read off the context and off the injected field), port 19834:"
  V=("${HV[@]}" --probe.pc=boundary); hrun 19834; view .harness/run.out 'org\.hibernate\.SQL'; hres
  echo "B (labelled: H2's trace on Boot's URL) - steps twofinds-tx then twofinds-notx, spring.datasource.url given H2's TRACE_LEVEL_SYSTEM_OUT=3 (the same database, jdbc:h2:mem:tiffinbox), port 19834:"
  V=("${HV[@]}" --probe.pc=twofinds-tx,twofinds-notx "$SQLD" '--spring.datasource.url=jdbc:h2:mem:tiffinbox;DB_CLOSE_DELAY=-1;TRACE_LEVEL_SYSTEM_OUT=3'); hrun 19834
  view .harness/run.out 'org\.hibernate\.SQL'; hres
  echo "  H2's trace (never shown whole; H2 numbers its connections - conn<n>): the JDBC calls named here, between each step's markers, counted and in order:"
  for s in twofinds-tx twofinds-notx; do
    echo "  $s: $(tcnt $s)"
    awk -v a="PROBE $s begin" -v b="PROBE $s end" -v p="$TRL" 'index($0, a) == 1 { f = 1; next } index($0, b) == 1 { f = 0 } f && $0 ~ p { print "    " $0 }' .harness/run.out; done
  echo "  before the steps - TiffinBox's Database seeding the table on its own DriverManager connection: setAutoCommit(false) $(awk '/^PROBE /{ exit } /^\/[*][*]\/conn[0-9]+[.]setAutoCommit[(]false[)];$/ { n++ } END { print n + 0 }' .harness/run.out) · commit() $(awk '/^PROBE /{ exit } /^\/[*][*]\/conn[0-9]+[.]commit[(][)];$/ { n++ } END { print n + 0 }' .harness/run.out) - Database.java's own lines:"
  grep -nE 'setAutoCommit\(|\.commit\(\)' anchor/$CJ/Database.java | sed -E 's/^([0-9]+): +/    Database.java line \1: /'; }
c_boundary() { local B0 BT
  B0=$(blk boundary "the anchor and the harness (step boundary" "B (labelled"); BT=$(blk boundary "B (labelled" "")
  for l in '  PROBE transaction manager: org.springframework.orm.jpa.JpaTransactionManager (in spring-orm-7.0.10.jar)' \
      '  PROBE injected EntityManager: a JDK proxy: true | handler org.springframework.orm.jpa.SharedEntityManagerCreator$SharedEntityManagerInvocationHandler (in spring-orm-7.0.10.jar)'; do has "$B0" "$l" "boundary: the manager and the handler, read off"; done
  printf '%s\n' "$B0" | grep -qE '^  exit 0 · ' || die "boundary: exit 0"
  [ "$(blk boundary "the template's lines" "the anchor and the harness (step boundary" | grep -cE '^  Pc\.java line [0-9]+: ')" -ge 3 ] || die "boundary: the template's lines shown"
  for l in '  twofinds-tx: setAutoCommit(false) 1 · commit() 2 · setAutoCommit(true) 1 · rollback() 0' '  twofinds-notx: setAutoCommit(false) 0 · commit() 0 · setAutoCommit(true) 0 · rollback() 0' \
      '  PROBE twofinds-tx | statements 1 | loads 1 | updates 0 | flushes 1 | transactions 1' '  PROBE twofinds-notx | statements 2 | loads 2 | updates 0 | flushes 0 | transactions 0' \
      '  its pool: HikariPool-1 - Added connection conn0: url=jdbc:h2:mem:tiffinbox · Hibernate: HHH000001: Hibernate ORM core version 7.4.13.Final · WARN lines: 0 · ERROR lines: 0'; do has "$BT" "$l" "boundary B: H2's trace counts"; done
  [ "$(blk boundary "  twofinds-tx: " "  twofinds-notx: " | paste -sd'|' -)" = '    /**/conn<n>.setAutoCommit(false);|    /**/conn<n>.commit();|    /**/conn<n>.setAutoCommit(true);|    /**/conn<n>.commit();' ] || die "boundary B: the JDBC calls in order, in a transaction - setAutoCommit(false), commit(), setAutoCommit(true), commit()"
  printf '%s\n' "$BT" | grep -qE '^  exit 0 · ' || die "boundary B: exit 0"
  echo "  boundary: JpaTransactionManager (spring-orm-7.0.10); the injected EntityManager's handler SharedEntityManagerCreator\$SharedEntityManagerInvocationHandler (spring-orm-7.0.10); H2's trace - in a transaction setAutoCommit(false) 1 · commit() 2 · setAutoCommit(true) 1, without one none"; }

# ---- tests: TiffinBox's tests, read from Surefire's reports -----------------------------------------------------------------------
tests() { local c e=0 n
  echo "TiffinBox's tests - the anchor copied to .harness/tests, the README's line, offline:"
  copy anchor .harness/tests
  c=$(off .harness/tests "$R_TEST"); echo "\$ $c"
  (eval "$c") > .harness/tests.log 2>&1 < /dev/null & mpid=$!; wait "$mpid" || e=$?; mpid=""
  n=$(grep -cE '^\[INFO\] Download(ing|ed) from ' .harness/tests.log || true)
  echo "  exit $e · $(grep -m1 -oE 'BUILD (SUCCESS|FAILURE)' .harness/tests.log || echo 'no BUILD line') · offline: $( [ "$n" = 0 ] && echo yes || echo "no - $n lines say Maven downloaded")"
  echo "  Surefire's reports ($SR, read by harness/surefire.py):"; reports .harness/tests .harness/tests.log
  echo "  Hibernate in the tests' log - lines that say Initialized JPA EntityManagerFactory: $(grep -c 'Initialized JPA EntityManagerFactory' .harness/tests.log || true) · Hibernate's SQL lines: $(grep -c ' org\.hibernate\.SQL  *: ' .harness/tests.log || true)"
  echo "  its log's WARN lines: $(lvl WARN .harness/tests.log) · ERROR lines: $(lvl ERROR .harness/tests.log) (the tests' own kitchen-on-fire cases) · the demo token in it and every report: $(raw "$TOKEN" .harness/tests.log .harness/tests/$SR/*) times"; }
EIGHT='  in all: 3 reports · tests 18 · failures 0 · errors 0 · skipped 0'
CONS="  Surefire's console summary (its Results line): tests 18 · failures 0 · errors 0 · skipped 0 · the reports' sum the same: yes"
c_tests() { local TS; TS=$(cat .r-tests.out)
  for l in '    TEST-com.tiffinbox.web.TiffinBoxWebTest.xml: tests 14 · failures 0 · errors 0 · skipped 0' '    TEST-com.tiffinbox.web.FullStackTest.xml: tests 3 · failures 0 · errors 0 · skipped 0' '    TEST-com.tiffinbox.web.FeedTest.xml: tests 1 · failures 0 · errors 0 · skipped 0' \
      "  $EIGHT" "$CONS" '  exit 0 · BUILD SUCCESS · offline: yes' '  Hibernate in the tests'"'"' log - lines that say Initialized JPA EntityManagerFactory: 2 · Hibernate'"'"'s SQL lines: 0'; do has "$TS" "$l" "tests"; done
  echo "  tests: TiffinBoxWebTest 14, FullStackTest 3, FeedTest 1 - 18 from the reports, the console the same; 2 EntityManagerFactories started, 0 SQL lines - no change"; }

# ---- exercise: the README's commands, then the solution's - in ONE shell, bash, then zsh ----------------------------------------
block() { awk '/^```bash$/ { if (!d) { f = 1 }; next } f && /^```$/ { f = 0; d = 1 } f' "$1"; }
where() { case "$1" in "$U") echo "this unit's folder" ;; "$U"/*) echo "${1#"$U"/}" ;; *) echo "outside this unit's folder" ;; esac; }
exsh() { local sh=$1 i=0 e1 d1 e2 d2
  rm -f .harness/ex-*.st .harness/ex-*.out .harness/mine.log
  case $sh in bash) env -i HOME="$HOME" PATH="$XPATH" /bin/bash --noprofile --norc .harness/ex-drive.sh "$U" > .harness/ex-shell.out 2>&1 < /dev/null & xpid=$! ;;
              zsh) env -i HOME="$HOME" PATH="$XPATH" /bin/zsh -f .harness/ex-drive.sh "$U" > .harness/ex-shell.out 2>&1 < /dev/null & xpid=$! ;; esac
  while kill -0 "$xpid" 2> /dev/null && [ $i -lt 960 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$xpid" 2> /dev/null && { killtree "$xpid"; die "the exercise's $sh still ran after 240 s"; }
  wait "$xpid" || true; xpid=""
  [ -f .harness/ex-readme.st ] && [ -f .harness/ex-sol.st ] || { cat .harness/ex-shell.out .harness/ex-readme.out .harness/ex-sol.out 2> /dev/null | tail -20 >&3; die "the exercise's $sh did not reach the end of both blocks"; }
  read -r e1 d1 < .harness/ex-readme.st; read -r e2 d2 < .harness/ex-sol.st
  echo "in $sh ($( [ $sh = bash ] && echo '/bin/bash --noprofile --norc' || echo '/bin/zsh -f')) - the README's lines:"
  echo "  the block's exit $e1 · what it printed:"; sed 's/^/    /' .harness/ex-readme.out
  echo "  the shell is now in: $(where "$d1") · listening on 19835 now: $(listeners 19835)"
  echo "  then the solution's lines, in the same shell - the block's exit $e2 · what it printed:"; sed 's/^/    /' .harness/ex-sol.out
  echo "  the shell is now in: $(where "$d2") · listening on 19835 now: $(listeners 19835) · the demo token in the JVM's log: $(raw "$TOKEN" .harness/mine.log) times"; }
exercise() { local setup sol
  setup=$(block exercise/README.md); sol=$(block exercise/SOLUTION.md)
  [ -n "$setup" ] && [ -n "$sol" ] || die "exercise/README.md or SOLUTION.md no longer gives its commands"
  printf '%s\n' "$setup" | sed -n 1p | grep -qxF 'export JAVA_HOME=/opt/homebrew/opt/openjdk@25' && printf '%s\n' "$sol" | sed -n 1p | grep -qxF 'export JAVA_HOME=/opt/homebrew/opt/openjdk@25' || die "the exercise's blocks must start by exporting this script's JAVA_HOME"
  [ "$(printf '%s\n' "$setup" | grep -c .)" = "$(printf '%s\n' "$sol" | grep -c .)" ] || die "SOLUTION.md's block must have the README's lines, one changed"
  [ "$(diff <(printf '%s\n' "$setup") <(printf '%s\n' "$sol") | grep -c '^[<>]')" = 2 ] || die "SOLUTION.md's block must be the README's with one line changed"
  printf '%s\n' "$setup" | grep -qF -- '"${V[@]}"' && printf '%s\n' "$setup" | grep -qE '^V=\(' || die "exercise/README.md must pass its options as an array, V (R.164, R.193)"
  printf '%s\n' "$setup" | grep -qF -- "--tiffinbox.port=19835" || die "exercise/README.md must run on port 19835"
  printf '%s\n' "$setup" > .harness/ex-readme.sh; printf '%s\n' "$sol" > .harness/ex-sol.sh
  cat > .harness/ex-drive.sh <<'DRV'
cd "$1" || exit 1
. "$1/.harness/ex-readme.sh" > "$1/.harness/ex-readme.out" 2>&1 < /dev/null
echo "$? $PWD" > "$1/.harness/ex-readme.st"
cd "$1" || exit 1
. "$1/.harness/ex-sol.sh" > "$1/.harness/ex-sol.out" 2>&1 < /dev/null
echo "$? $PWD" > "$1/.harness/ex-sol.st"
DRV
  sec .harness/anchor
  echo "exercise/README.md's $(printf '%s\n' "$setup" | grep -c .) lines, then exercise/SOLUTION.md's, exactly as written, one after the other in ONE shell - env -i (HOME, and the PATH this script was started with), started in this folder; each block starts its own JVM:"
  echo "the README's lines:"; printf '%s\n' "$setup" | sed 's/^/  $ /'
  echo "the solution's line that differs:"; diff <(printf '%s\n' "$setup") <(printf '%s\n' "$sol") | grep '^>' | sed 's/^> /  $ /'
  exsh bash; exsh zsh; }
c_exercise() { local EXB EXZ b
  EXB=$(blk exercise "in bash" "in zsh"); EXZ=$(blk exercise "in zsh" "")
  for b in "$EXB" "$EXZ"; do
    ER=$(printf '%s\n' "$b" | sed '/^  then the solution.s lines/,$d'); ES=$(printf '%s\n' "$b" | sed -n '/^  then the solution.s lines/,$p')
    for l in '    exit 0' '    PROBE   in a transaction: false' '    PROBE twofinds-notx | statements 2 | loads 2 | updates 0 | flushes 0 | transactions 0' '    PROBE   same object (a == b): false | identityHashCode @… @… | the pair equal: false'; do has "$ER" "$l" "exercise: the README as written - statements 2, two objects"; done
    for l in '    exit 0' '    PROBE   in a transaction: true' '    PROBE twofinds-tx | statements 1 | loads 1 | updates 0 | flushes 1 | transactions 1' '    PROBE   same object (a == b): true | identityHashCode @… @… | the pair equal: true'; do has "$ES" "$l" "exercise: the solution - statements 1, one object"; done
    nhas "$ER" 'twofinds-tx' "exercise: the README's half ran the transaction step"; nhas "$ES" 'twofinds-notx' "exercise: the solution's half ran the step without a transaction"
    [ "$(printf '%s\n' "$b" | grep -cE "^  the shell is now in: this unit's folder · listening on 19835 now: 0")" = 2 ] || die "exercise: the shell back in this folder, nothing listening"; done
  [ "$(printf '%s\n' "$EXB" | grep -v '^in ')" = "$(printf '%s\n' "$EXZ" | grep -v '^in ')" ] || die "exercise: bash and zsh print the same"
  EXQ="Your turn: the README's two finds hit the database twice. Give them one transaction and watch it drop to one."
  grep -qxF -- "**Your turn:** ${EXQ#Your turn: }" exercise/README.md || die "exercise/README.md: the spoken exercise line"
  [ "$(printf '%s\n' "$EXQ" | wc -w | tr -d ' ')" -le 25 ] || die "exercise: the spoken line is over 25 words"
  block exercise/README.md | grep -qF -- '--probe.pc=twofinds-notx)' && block exercise/SOLUTION.md | grep -qF -- '--probe.pc=twofinds-tx)' || die "exercise: the README's array runs twofinds-notx, the solution's twofinds-tx"
  echo "  exercise: bash and zsh alike - the README as written: statements 2, same object false; the solution: statements 1, true; each block a fresh JVM, the shell back in this folder, nothing listening"; }

# ---- the captures, each followed by its checks ------------------------------------------------------------------------------------
cap twofinds twofinds; c_twofinds
cap own own; c_own
cap request request; c_request
cap dirty dirty; c_dirty
cap boundary boundary; c_boundary
cap tests tests; c_tests
cap exercise exercise; c_exercise

# ---- hygiene: tokens, paths, times, pins - every capture, every file this unit ships, every log -----------------------------------
for f in .harness/raw-*; do [ "$(cat "$f")" = "0" ] || die "a capture's raw output held the token ($f: $(cat "$f"))"; done
for f in .r-*.out README.md exercise/README.md exercise/SOLUTION.md receipts.md5 $HS/*.java .harness/*.log; do [ "$(raw "$TOKEN" "$f")" = 0 ] || die "$f holds the demo token, raw"; done
[ "$LOGS" -gt 0 ] || die "a token count never ran"
# no capture prints a path, a version token of the OS or the JDK, a time, a pid, a random port, a unit number or a stack frame
for f in .r-*.out; do
  ! grep -qE '/Users/|/private/|/home/|/var/folders/' "$f" || die "$f holds an absolute path"
  ! grep -qE 'c[0-9]-unit[0-9]|unit ?[0-9]' "$f" || die "$f holds a unit number"
  ! grep -qE ' (with PID|started by) |surefirebooter|Time elapsed|time="| in [0-9.]+ seconds' "$f" || die "$f holds Boot's process line, a Surefire booter path, a time or Boot's seconds"
  ! grep -qE '^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9][T ]|"timestamp":"?[0-9]|(exec|handler|task)-[0-9]|\$Proxy[0-9]' "$f" || die "$f holds a log time, a timestamp, a thread number or a proxy class number"
  ! grep -qE 'using Java [0-9]|Darwin|arm64|aarch64' "$f" || die "$f holds an OS or a JDK version token (R.151)"
  ! grep -qE 'jdbc:h2:mem:[0-9a-f]{8}-' "$f" || die "$f holds a generated database name, unmasked"
  ! grep -qE '@[0-9a-f]{5,}' "$f" || die "$f holds an identity hash, unmasked (they differ run to run)"
  ! grep -qE '(127\.0\.0\.1:|port )(49|5[0-9]|6[0-5])[0-9][0-9][0-9]([^0-9]|$)' "$f" || die "$f holds a random port (R.147)"
  ! grep -qE '^ +at [a-z]' "$f" || die "$f holds a stack frame"; done
for f in .r-*.out; do ! grep -E '^ *\$ ' "$f" | grep -oE 'https?://[^ '"'"']+' | grep -vE '^http://127\.0\.0\.1:' > /dev/null || die "$f runs a command with a URL that is not 127.0.0.1's"; done
for f in .r-*.out; do ! grep -E '^ *\$ \(?(cd [^ ]+ && )?(exec )?java ' "$f" | grep -vF -- "java $JL " > /dev/null || die "$f starts a JVM without its locale pinned (S6.1)"; done
for f in .r-*.out; do a=$(grep -cE '^\$ cd \.harness/[a-z]+ && java ' "$f" || true); b=$(grep -cxF "  secrets/ before the start: tiffinbox/shutdown-token - the token's file, and nothing else" "$f" || true)
  [ "$a" = "$b" ] || [ "$f" = .r-exercise.out ] || die "$f: $a starts, $b secrets/ listings (R.158)"; done
K1='pki''ll'; K2='kill''all'; ! grep -v '^ *#' receipts.sh | grep -qwE "$K1|$K2" || die "receipts.sh names $K1 or $K2 - every process is stopped by its pid"
for f in receipts.sh exercise/README.md exercise/SOLUTION.md; do ! grep -nE '(^|[;&|({] *)wait *($|[;&|)}])' "$f" | grep -vE '^[0-9]+: *#' > /dev/null || die "$f has a bare wait (S6.9)"; done
# R.193: run options travel as an array - no variable holds several options in one string
for f in receipts.sh README.md exercise/README.md exercise/SOLUTION.md; do ! grep -nE '^[A-Za-z_][A-Za-z_0-9]*="?--[^ "]+ +--' "$f" > /dev/null || die "$f holds a one-string multi-option variable (R.193)"; done
! grep -rq 'probe\.jpa' anchor/tiffinbox-web anchor/tiffinbox-core || die "the anchor's code names the course's harness - it is never TiffinBox's"
! grep -rqE '^package com\.tiffinbox' harness/src || die "a harness class sits in com.tiffinbox (R.43)"
echo "  tokens: 0 raw copies in $(ls .harness/raw-* | wc -l | tr -d ' ') raw capture runs, in $(ls .r-*.out | wc -l | tr -d ' ') captures, every file this unit ships, every build log and the log of every JVM ($LOGS); no path, no unit number, no time, no generated database name, no unmasked identity hash, no stack frame in any capture; every JVM's locale pinned; every start's secrets/ listed; no kill by name; no bare wait; options as arrays"

D_=$(diff -rq -x .m2-demo -x target -x secrets anchor/ ../c7-tiffinbox 2>&1 || true); [ -z "$D_" ] || die "anchor/ is no longer ../c7-tiffinbox at the end"
for p in $PORTS; do [ "$(listeners $p)" = 0 ] || die "something listens on $p at the end"; done
echo "  ports: nothing listens on 18425, 8080, 35729 or 19830-19839 at the end; 19839 never bound"
[ -z "$unpub" ] || die "no published hash for:$unpub - check the captures, then copy the md5s above into receipts.md5 and run again"
echo "c7-unit04: every capture 3/3 and = published; every spoken number asserted; 0 raw demo tokens; duration words 0; anchor/ = ../c7-tiffinbox (no anchor change)"
