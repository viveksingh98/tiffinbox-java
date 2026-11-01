#!/bin/bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25.0.4.1 on the author's Mac: point it at your JDK 25
XPATH=$PATH                                           # the PATH you started this with: the exercise's own shells get it
export PATH="$JAVA_HOME/bin:$PATH"
# Course 7 · Entity States - this unit's receipts. No change to the anchor: anchor/ is the link to ../c7-unit03/after (=
# ../c7-tiffinbox, asserted below). Nine captures, each run three times and hashed; cap() DIES when a hash differs from
# receipts.md5; every number the video says is asserted by a check that can fail, right after its capture; the demo token is
# masked, and the checks count 0 raw copies of it in every capture and every log.
#   transient        a new CustomerEntity: its id, and contains() asked INSIDE one TransactionTemplate beside a control (a customer
#                    found in the same transaction: contains true); the statements before the control (0); asked again outside
#   managed          persist a new Kavya (the INSERT at persist: before the "before commit" marker), set 3 before the commit (the
#                    UPDATE after the marker); contains true; the anchor's repository reads 3
#   detached         A/B/A' - A: find Kavya, set 2, commit (an UPDATE; the anchor reads 2); B (one flip: the step detach, one line
#                    of St.java): find, detach, set 2, commit (no UPDATE, flushes 0; the anchor keeps 3); A' = A
#   merge            Kavya loaded in a transaction that ended, set 2, merge in a new one: SELECT, then UPDATE at the commit; merge
#                    returns another object; contains(det) false, contains(m) true; the anchor reads 2
#   persistdetached  the failure receipt (Course 4 §2e) and its A': persist of that detached instance - Jakarta's
#                    EntityExistsException around Hibernate's PersistentObjectException, each with its jar, 0 statements, exit 1
#                    (the trio); A' merge of the same instance, exit 0
#   removed          find, remove: contains false before the commit, the DELETE after the marker, the anchor no longer finds Kavya
#   states           the four states as a table - every cell read by this script from the four captures above, never typed
#   tests            TiffinBox's tests on the anchor (the README's line, offline): Surefire's reports, the console's summary beside
#   exercise         exercise/README.md's commands, then exercise/SOLUTION.md's two blocks, read from the files and run as written,
#                    in ONE env -i shell - /bin/bash, then again in /bin/zsh -f; each block a fresh JVM
# Every span of database work is bracketed by the harness's "PROBE X begin" / "PROBE X end" lines and followed by Hibernate's
# Statistics for it: the receipt counts the SQL logger's lines between the markers, by kind, and asserts both witnesses agree.
# The harness (harness/src, package probe.jpa, outside com.tiffinbox): Probe and Steps are the first-entity lesson's, byte for byte
# (../c7-unit03/harness, md5 asserted); Five (the configuration a run joins: --spring.main.sources=probe.jpa.Five) and St (an
# ApplicationRunner that acts only when the run sets --probe.st) are this unit's. It is compiled with javac -parameters against
# the anchor's extracted jar into .harness/hc. Its run options travel as an array, V (R.193). Commands are printed exactly as they
# run: each goes through eval. harness/surefire.py (the testing lesson's, byte for byte) reads Surefire's reports;
# harness/dur7.py (Course 7's builders' duration pattern, byte for byte, md5 asserted) gates this unit's prose. "$M2" is this
# unit's own repository, .m2-demo.
# The locale: the JVM ignores LC_ALL on macOS - every JVM this script starts has its locale pinned on its run line (-Duser.language=en
# -Duser.country=US), and the checks refuse a java line without it; the test JVM's comes from the POM's argLine.
# The network: every Maven build runs offline (-o) against .m2-demo and says so ("offline: yes"). A build that cannot resolve an
# artifact offline is run once more without -o and says so, naming the artifact the offline build missed and the repositories
# that answered the retry, by the ids and URL schemes its log names ("offline: no - ..."); it never names a repository the log
# does not. At run time nothing leaves 127.0.0.1, and every database is H2 in this JVM's memory.
# Masks (README.md declares each; awk gsub only): the demo token "[masked: the N-character token]"; this folder "…", the folder
# above it "…/..", home "~", your user name "<user>"; " using Java <version>"; H2's generated database name "jdbc:h2:mem:<uuid>";
# an identity hash "@…". A JVM's log is never printed whole: the harness's PROBE lines, the lines of named loggers, an exception's
# first line and its distinct "Caused by" lines; WARN and ERROR lines counted. A Maven log: its BUILD line, Surefire's reports,
# the console's summary; the rest counted. No duration is captured.
# Ports (§P, 19840-19849): transient 19840 · managed 19841 · detached 19842 · merge 19843 · persistdetached 19844 · removed 19845
# · exercise 19846 · 19849 never bound. Each port's runs are sequential, each JVM waited for by its pid before the next. 18425
# (TiffinBox's default), 8080 and 35729 are checked free too, and never bound. states and tests bind none.
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
for t in python3 rsync lsof unzip mvn md5 cmp git /bin/zsh; do command -v $t > /dev/null || die "$t is needed"; done
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
SR=tiffinbox-web/target/surefire-reports
XD=tiffinbox-web/target/extracted                    # the jar, extracted (the anchor's own line), in a tree
TF=secrets/tiffinbox/shutdown-token
TOKEN=demo-token-for-the-entity-states-lesson
[ ${#TOKEN} = 39 ] || die "the demo token must be 39 characters: the captures name its length"
HS=harness/src/probe/jpa
for f in harness/surefire.py harness/dur7.py $HS/Probe.java $HS/Steps.java $HS/Five.java $HS/St.java exercise/README.md exercise/SOLUTION.md README.md receipts.md5; do [ -f "$f" ] || die "$f is missing"; done
[ "$(ls harness | paste -sd' ' -)" = 'dur7.py src surefire.py' ] && [ "$(cd harness/src && find . -type f | sed 's#^\./##' | sort | paste -sd' ' -)" = 'probe/jpa/Five.java probe/jpa/Probe.java probe/jpa/St.java probe/jpa/Steps.java' ] || die "harness/ holds another file"
[ "$(ls exercise | paste -sd' ' -)" = 'README.md SOLUTION.md' ] || die "exercise/ holds another file"
cmp -s harness/surefire.py ../c6-unit28/harness/surefire.py || die "harness/surefire.py is not the testing lesson's (../c6-unit28/harness/surefire.py), byte for byte"
# the first-entity lesson's two harness files, byte for byte - by md5 (as that lesson committed them) and against the files themselves
[ "$(md5 -q $HS/Probe.java)" = fc0c06932cd2cd8c912f304328b367b8 ] && [ "$(md5 -q $HS/Steps.java)" = e316b9418711b0c142d3b7c7519d9215 ] || die "Probe.java / Steps.java are not the first-entity lesson's (md5 fc0c0693… / e316b941…)"
cmp -s $HS/Probe.java ../c7-unit03/$HS/Probe.java && cmp -s $HS/Steps.java ../c7-unit03/$HS/Steps.java || die "Probe.java / Steps.java differ from ../c7-unit03/harness's"
echo "  the harness: Probe.java fc0c06932cd2cd8c912f304328b367b8 and Steps.java e316b9418711b0c142d3b7c7519d9215 - the first-entity lesson's, byte for byte; Five, St this unit's"
# Course 7's builders' duration pattern, byte for byte (Section 1 states no duration, R.172)
[ "$(md5 -q harness/dur7.py)" = 41667fed9ffcefe171389eed7e654e66 ] || die "harness/dur7.py is not the builders' dur7.py (md5 41667fed…)"
if [ -f ../../../data-jpa-hibernate/_builders/dur7.py ]; then cmp -s harness/dur7.py ../../../data-jpa-hibernate/_builders/dur7.py || die "harness/dur7.py differs from the builders' ../../../data-jpa-hibernate/_builders/dur7.py"
  echo "  (terminal only) harness/dur7.py = the builders' _builders/dur7.py, byte for byte" >&3
else echo "  (terminal only) the builders' _builders/dur7.py is not beside this clone: its md5 above is the check" >&3; fi
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
PORTS="18425 8080 35729 19840 19841 19842 19843 19844 19845 19846 19849"
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
# This unit's own lines (README.md, "The commands this unit adds") - each asserted to be exactly that
mine() { grep -m1 -xF -- "$1" README.md > /dev/null || die "README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
JL='-Duser.language=en -Duser.country=US'
XC=".harness/anchor/$XD/tiffinbox-web-1.0.0.jar:.harness/anchor/$XD/lib/*"     # the anchor's extracted jar, from this folder
L_H=$(mine "java $JL -cp \"../hc:tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*\" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431 \"\${V[@]}\"")
L_JAVAC=$(mine "javac -parameters -d .harness/hc -cp \"$XC\" $HS/Five.java $HS/Probe.java $HS/St.java $HS/Steps.java")
# The derivation, asserted: one change, and nothing else
P_='java -cp "'; Q_="java $JL -cp \"../hc:"; [ "${R_CP/"$P_"/$Q_} \"\${V[@]}\"" = "$L_H" ] || die "the harness line must be the anchor's extracted-jar line with $JL, ../hc first on the class path and the options array after it, and nothing else"
off() { local c=${2/mvn -B /mvn -o -B -Dmaven.repo.local=\"\$M2\" }
  [ -n "${3:-}" ] && c=${c/ $3/ clean $3}
  printf 'cd %s && %s\n' "$1" "$c"; }
# at DIR PORT 'README LINE': the README's line run from DIR, its port 18431 made PORT
at() { local l=${3/--tiffinbox.port=18431/--tiffinbox.port=$2}; printf 'cd %s && %s\n' "$1" "$l"; }
# hl PORT: the harness line, run from .harness/anchor, its port made PORT
hl() { at .harness/anchor "$1" "$L_H"; }
exe() { printf '%s\n' "$1" | sed -E 's/&& (([A-Z_]+=[^ ]* )*)/\&\& \1exec /'; }
[ "$(exe "$(hl 19840)")" = "cd .harness/anchor && exec java $JL -cp \"../hc:tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*\" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19840 \"\${V[@]}\"" ] || die "hl(): the run line is not README.md's"
echo "  the commands: anchor/README.md gives the $(grep -c '^R_[A-Z]*=$(readme ' receipts.sh) lines this script runs or derives from; README.md the $(grep -c '^L_[A-Z0-9]*=$(mine ' receipts.sh) this unit adds"
JV=$(java -version 2>&1 | sed -n 's/.*version "\([^"]*\)".*/\1/p' | head -1)
echo "  (terminal only) the JDK is $JV - Boot's first line names it; the captures say Java <version>" >&3

# ---- build: before the captures - the anchor copied and built with the README's package line, offline (its tests run); its jar
# ---- extracted (the anchor's line); the harness compiled against it ------------------------------------------------------------
# mbuild COMMAND LOG WHAT: offline first. If the offline build fails for want of an artifact, its log is kept beside (LOG with
# -offline), the first artifact it names is read from it, and the build runs once more without -o; the label then names that
# artifact and every repository the retry's log says it downloaded from - id, URL scheme, count - and counts the downloads whose
# URL is http(s). It never says "Maven Central" unless the log does.
mbuild() { local how=yes ec=0 c=$1 miss got web
  (eval "$c") > "$2" 2>&1 < /dev/null & mpid=$!; wait "$mpid" || ec=$?; mpid=""
  if [ $ec != 0 ] && grep -qE 'offline mode|Could not resolve|could not be resolved|Cannot access|No plugin found for prefix' "$2"; then
    cp "$2" "${2%.log}-offline.log"
    miss=$(grep -oE 'the artifact [^ ]+ has not been downloaded' "$2" | head -1 | sed -E 's/^the artifact ([^ ]+) has not been downloaded$/\1/')
    [ -n "$miss" ] || miss=$(grep -oE 'Could not find artifact [^ ]+|No plugin found for prefix [^ ]+|Non-resolvable parent POM for [^ ]+' "$2" | head -1)
    ec=0; (eval "${c/mvn -o -B /mvn -B }") > "$2" 2>&1 < /dev/null & mpid=$!; wait "$mpid" || ec=$?; mpid=""
    got=$(sed -n -E 's/^\[INFO\] Downloaded from ([^ :]+): ([a-z]+):.*/\1 (\2)/p' "$2" | sort | uniq -c | awk '{ printf "%s%s %s %d", (NR > 1 ? ", " : ""), $2, $3, $1 }')
    web=$(grep -cE '^\[INFO\] Downloaded from [^ ]+: https?://' "$2" || true)
    how="no - the offline build could not resolve ${miss:-an artifact (none named in its log)} from .m2-demo, so it ran once more without -o; that run downloaded from: ${got:-nothing}; of them over http(s): $web"; fi
  [ $ec = 0 ] || { tail -30 "$2" >&3
    ! grep -qE 'Could not resolve|could not be resolved|Could not transfer|Cannot access' "$2" || die "build failed: $3 - Maven could resolve Boot's parent and plugins neither from .m2-demo nor from a repository it could reach: a fresh clone's first run needs .m2-demo seeded (README.md, The repository)"
    die "build failed: $3"; }
  echo "  built $3 · offline: $how · exit $ec · 'Downloaded from' lines in its log: $(grep -c '^\[INFO\] Downloaded from ' "$2" || true)"; }
tree() { mkdir -p "$1/secrets/tiffinbox"; (umask 077 && printf '%s\n' "$TOKEN" > "$1/$TF"); chmod 700 "$1/secrets" "$1/secrets/tiffinbox"; }
copy() { rm -rf "$2"; rsync -a --exclude target --exclude secrets --exclude .m2-demo "$1/" "$2/"; tree "$2"; }
copy anchor .harness/anchor
mbuild "$(off .harness/anchor "$R_PLAIN" package)" .harness/build-anchor.log ".harness/anchor (the anchor, the README's package line; its tests ran)"
for a in org/springframework/boot/spring-boot-starter-parent/4.1.2/spring-boot-starter-parent-4.1.2.pom org/hibernate/orm/hibernate-core/7.4.13.Final/hibernate-core-7.4.13.Final.jar org/springframework/boot/spring-boot-starter-data-jpa/4.1.2/spring-boot-starter-data-jpa-4.1.2.jar jakarta/persistence/jakarta.persistence-api/3.2.0/jakarta.persistence-api-3.2.0.jar; do
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
    while (match($0, M)) { pre = substr($0, 1, RSTART - 1); s = substr($0, RSTART, RLENGTH); post = substr($0, RSTART + RLENGTH)
      sub(lit(me), "<user>", s); $0 = pre s post }
    print }'; }
printf '%s\n' 'Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1' 'url=jdbc:h2:mem:184c1fae-3bb5-4208-80fb-a59190f705ec user=SA' "$TOKEN" 'PROBE   merge returned same object: false | identityHashCode det @3446ab40 m @43851574 | the pair equal: false' > .harness/p1
[ "$(mask < .harness/p1)" = "$(printf '%s\n' 'Starting TiffinBoxServer v1.0.0 using Java <version>' 'url=jdbc:h2:mem:<uuid> user=SA' '[masked: the 39-character token]' 'PROBE   merge returned same object: false | identityHashCode det @… m @… | the pair equal: false')" ] || die "mask: the planted JDK version, generated database name, token and identity hashes must be masked"
# view FILE 'LOGGER-REGEX': a run's log, in order: the harness's PROBE lines, the lines of the named loggers (level, logger:
# message; "Started TiffinBoxServer" without its seconds; a message over 260 characters cut there), and for an ERROR line of
# SpringApplication ("Application run failed") the exception's first line and each distinct "Caused by:" line (at most four,
# each cut at 260 characters); its frames and the rest counted, never shown
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
HV=(--spring.main.sources=probe.jpa.Five --spring.jpa.properties.hibernate.generate_statistics=true)    # every harness run's two
SQLD=--logging.level.org.hibernate.SQL=debug
BIND=--logging.level.org.hibernate.orm.jdbc.bind=trace
SQLV='org\.hibernate\.SQL'
unpub=""
cap() { local nm=$1 h pub i; shift
  for i in 1 2 3; do "$@" > .harness/cap.raw 2>&1 || true; [ -z "$pid$mpid$xpid" ] || die "$nm left a process running"
    raw "$TOKEN" .harness/cap.raw > ".harness/raw-$nm.$i"; mask < .harness/cap.raw > ".r-$nm.$i"; done
  h=$(md5 -q ".r-$nm.1")
  [ "$h" = "$(md5 -q ".r-$nm.2")" ] && [ "$h" = "$(md5 -q ".r-$nm.3")" ] || die "$nm drifts across three runs (diff .r-$nm.1 .r-$nm.2 .r-$nm.3)"
  mv ".r-$nm.1" ".r-$nm.out"; rm -f ".r-$nm.2" ".r-$nm.3"
  pub=$(awk -v n="$nm" '$1 == n { print $2 }' receipts.md5 2> /dev/null || true)
  if [ -z "$pub" ]; then printf '  %-15s md5 %s  3/3  (no published hash)\n' "$nm" "$h"; unpub="$unpub $nm"
  elif [ "$pub" = "$h" ]; then printf '  %-15s md5 %s  3/3  = published\n' "$nm" "$h"
  else printf '  %-15s md5 %s  3/3  DIFFERS from the published %s\n' "$nm" "$h" "$pub"
    die "$nm is not the published capture - suspect another JDK, Boot or Maven, a busy machine, a busy port, a variable of yours, or an edited source; diff .r-$nm.out against its block in README.md"; fi; }
summ() { grep -E '^\[(INFO|ERROR|WARNING)\] Tests run: [0-9]+, Failures: [0-9]+, Errors: [0-9]+, Skipped: [0-9]+$' "$1" | tail -1 | sed -E 's/.*Tests run: ([0-9]+), Failures: ([0-9]+), Errors: ([0-9]+), Skipped: ([0-9]+)$/tests \1 · failures \2 · errors \3 · skipped \4/'; }
# reports DIR LOG: Surefire's reports (harness/surefire.py), then the console's summary beside their sum (R.144)
reports() { local s t
  python3 -I harness/surefire.py "$1/$SR" | sed 's/^/  /'
  s=$(summ "$2"); t=$(python3 -I harness/surefire.py "$1/$SR" | sed -n 's/^  in all: [0-9]* reports · //p')
  echo "  Surefire's console summary (its Results line): ${s:-none} · the reports' sum the same: $( [ -n "$s" ] && [ "$s" = "$t" ] && echo yes || echo no)"; }
# Checks: each reads a line a program computed - the harness's own line, a count of log lines - never a label printed unconditionally
blk() { awk -v a="$2" -v b="$3" 'index($0, a) == 1 { f = 1; next } b != "" && index($0, b) == 1 { f = 0 } f' ".r-$1.out"; }
has() { printf '%s\n' "$1" | grep -qxF -- "$2" || die "$3: expected the line: $2"; }
nhas() { ! printf '%s\n' "$1" | grep -qF -- "$2" || die "$3: did not expect: $2"; }
# wit SPAN: the two witnesses of one span (R.184) - the SQL logger's lines between "PROBE SPAN begin" and "PROBE SPAN end", by
# kind, and Hibernate's Statistics for the span (its own "PROBE SPAN | " line) - and whether they agree, kind by kind
wit() { local n a b c d s
  set -- "$1" $(awk -v x="PROBE $1 begin" -v y="PROBE $1 end" 'index($0, x) == 1 { f = 1; next } index($0, y) == 1 { f = 0 }
    f && / org\.hibernate\.SQL  *: / { n++; k = $0; sub(/.* org\.hibernate\.SQL  *: /, "", k); split(k, w, " "); c[w[1]]++ }
    END { print n + 0, c["select"] + 0, c["insert"] + 0, c["update"] + 0, c["delete"] + 0 }' .harness/run.out)
  s=$(sed -n -E "s/^PROBE $1 \| statements ([0-9]+) \| loads [0-9]+ \| inserts ([0-9]+) \| updates ([0-9]+) \| deletes ([0-9]+) \| .*/\1 \2 \3 \4/p" .harness/run.out | head -1)
  echo "  the two witnesses for $1 - the SQL logger's lines between '$1 begin' and its end: $2 (select $3 · insert $4 · update $5 · delete $6) · Statistics: ${s:+statements ${s%% *}} · inserts/updates/deletes ${s#* } · they agree: $( [ -n "$s" ] && [ "$s" = "$2 $4 $5 $6" ] && echo yes || echo no)"; }
# order SPAN: the SQL logger's lines of a span on each side of its "... - before commit" line (R.192, R.197), by kind
order() { awk -v x="PROBE $1 begin" -v y="PROBE $1 end" 'index($0, x) == 1 { f = 1; next } index($0, y) == 1 { f = 0 } !f { next }
    /^PROBE .* - before commit$/ { m = 1; next }
    / org\.hibernate\.SQL  *: / { k = $0; sub(/.* org\.hibernate\.SQL  *: /, "", k); split(k, w, " "); if (m) A[w[1]]++; else B[w[1]]++ }
    END { printf "  the order around the line \"... - before commit\" (R.197): %s - before it: select %d · insert %d · update %d · delete %d | after it, before '"'"'%s'"'"': select %d · insert %d · update %d · delete %d\n", (m ? "marker found" : "NO MARKER"), B["select"], B["insert"], B["update"], B["delete"], y, A["select"], A["insert"], A["update"], A["delete"] }' .harness/run.out | sed "s/'PROBE /'/"; }
SEL='    DEBUG org.hibernate.SQL: select ce1_0.id,ce1_0.meal_type,ce1_0.meals_per_day,ce1_0.name,ce1_0.price_per_meal from customer ce1_0 where ce1_0.id=?'
INS='    DEBUG org.hibernate.SQL: insert into customer (meal_type,meals_per_day,name,price_per_meal,id) values (?,?,?,?,default)'
UPD='    DEBUG org.hibernate.SQL: update customer set meal_type=?,meals_per_day=?,name=?,price_per_meal=? where id=?'
DEL='    DEBUG org.hibernate.SQL: delete from customer where id=?'
POOL='  its pool: HikariPool-1 - Added connection conn0: url=jdbc:h2:mem:tiffinbox · Hibernate: HHH000001: Hibernate ORM core version 7.4.13.Final · WARN lines: 0 · ERROR lines: 0'
SETUP3='  PROBE setup | statements 1 | loads 0 | inserts 1 | updates 0 | deletes 0 | flushes 1 | transactions 1'
ok0() { printf '%s\n' "$1" | grep -qE '^  exit 0 · ' || die "$2: exit 0"; }

# ---- transient: a new object, and what the EntityManager says of it inside a transaction ------------------------------------
transient() {
  echo "the anchor and the harness (step transient), Hibernate's SQL logger at DEBUG, port 19840:"
  V=("${HV[@]}" --probe.st=transient "$SQLD"); hrun 19840; view .harness/run.out "$SQLV"
  echo "  the transient's own two witnesses - the SQL logger's lines between 'transient begin' and the line 'the new Kavya': $(awk 'index($0, "PROBE transient begin") == 1 { f = 1; next } index($0, "PROBE   the new Kavya: ") == 1 { f = 0 } f && / org\.hibernate\.SQL  *: / { n++ } END { print n + 0 }' .harness/run.out) · Statistics read on that line: $(sed -n 's/^PROBE   the new Kavya: .* | statements so far \([0-9]*\)$/\1/p' .harness/run.out | head -1)"
  wit transient; hres; }
c_transient() { local TR; TR=$(cat .r-transient.out)
  for l in '  PROBE   the control, found in the same transaction: Ravi | contains true - before commit' '  PROBE   in a transaction: true' \
      '  PROBE   the new Kavya: id null | contains false | statements so far 0' \
      "  the transient's own two witnesses - the SQL logger's lines between 'transient begin' and the line 'the new Kavya': 0 · Statistics read on that line: 0" \
      "  the two witnesses for transient - the SQL logger's lines between 'transient begin' and its end: 1 (select 1 · insert 0 · update 0 · delete 0) · Statistics: statements 1 · inserts/updates/deletes 0 0 0 · they agree: yes" \
      '  PROBE transient | statements 1 | loads 1 | inserts 0 | updates 0 | deletes 0 | flushes 1 | transactions 1' \
      '  PROBE   asked again outside any transaction (never a state'"'"'s witness): the new Kavya contains false | the control contains false' \
      "  PROBE anchor repo reads Kavya's mealsPerDay: no Kavya - not in the table" "$SEL" "$POOL"; do has "$TR" "$l" "transient: contains false inside the transaction, beside the control's true; 0 statements"; done
  ok0 "$TR" transient
  echo "  transient: id null, contains false asked inside the transaction - the control found there contains true; 0 statements before the control (0 and 0); outside, both false; the anchor finds no Kavya"; }

# ---- managed: persist, and a change before the commit -------------------------------------------------------------------
managed() {
  echo "the anchor and the harness (step managed), Hibernate's SQL logger at DEBUG and its bind logger at TRACE, port 19841 - in the order the log printed them:"
  V=("${HV[@]}" --probe.st=managed "$SQLD" "$BIND"); hrun 19841; view .harness/run.out "$SQLV"'|org\.hibernate\.orm\.jdbc\.bind'
  echo "  the INSERT and persist() (R.192): insert lines before the line 'after persist()': $(awk 'index($0, "PROBE managed begin") == 1 { f = 1; next } index($0, "PROBE   after persist(): ") == 1 { f = 0 } f && / org\.hibernate\.SQL  *: insert / { n++ } END { print n + 0 }' .harness/run.out)"
  order managed; wit managed; hres; }
c_managed() { local MG; MG=$(cat .r-managed.out)
  for l in '  PROBE   before persist: id null' "$INS" '    TRACE org.hibernate.orm.jdbc.bind: binding parameter (1:VARCHAR) <- [VEG]' \
      '    TRACE org.hibernate.orm.jdbc.bind: binding parameter (2:INTEGER) <- [2]' '    TRACE org.hibernate.orm.jdbc.bind: binding parameter (3:VARCHAR) <- [Kavya]' \
      '    TRACE org.hibernate.orm.jdbc.bind: binding parameter (4:INTEGER) <- [110]' '  PROBE   after persist(): id 5 | contains true' \
      '  PROBE   field set to 3, no save called, contains true - before commit' "$UPD" '    TRACE org.hibernate.orm.jdbc.bind: binding parameter (2:INTEGER) <- [3]' \
      '    TRACE org.hibernate.orm.jdbc.bind: binding parameter (5:BIGINT) <- [5]' \
      "  the INSERT and persist() (R.192): insert lines before the line 'after persist()': 1" \
      "  the order around the line \"... - before commit\" (R.197): marker found - before it: select 0 · insert 1 · update 0 · delete 0 | after it, before 'managed end': select 0 · insert 0 · update 1 · delete 0" \
      "  the two witnesses for managed - the SQL logger's lines between 'managed begin' and its end: 2 (select 0 · insert 1 · update 1 · delete 0) · Statistics: statements 2 · inserts/updates/deletes 1 1 0 · they agree: yes" \
      '  PROBE managed | statements 2 | loads 0 | inserts 1 | updates 1 | deletes 0 | flushes 1 | transactions 1' \
      "  PROBE anchor repo reads Kavya's mealsPerDay: 3" "$POOL"; do has "$MG" "$l" "managed: the INSERT at persist, the UPDATE at the commit"; done
  ok0 "$MG" managed
  echo "  managed: the INSERT ran at persist (before 'after persist()', before the marker), id 5, contains true; set 3 - the UPDATE after the marker (all four columns); statements 2 = 2 SQL lines, inserts 1, updates 1; the anchor reads 3"; }

# ---- detached: A/B/A' - find, change, commit; with detach, nothing reaches the table -----------------------------------------
detached() {
  echo "A - the anchor and the harness (steps setup, change: find Kavya, set 2, one TransactionTemplate), Hibernate's SQL logger at DEBUG, port 19842:"
  V=("${HV[@]}" --probe.st=setup,change "$SQLD"); hrun 19842; view .harness/run.out "$SQLV"; wit setup; order change; wit change; hres
  echo "B - A with one flip, the harness's step: detach (St.java's change(), its one line that differs - em.detach(c) after the find), port 19842:"
  grep -nF 'if (detach) em.detach(c);' $HS/St.java | sed -E 's/^([0-9]+): +/  St.java line \1: /'
  V=("${HV[@]}" --probe.st=setup,detach "$SQLD"); hrun 19842; view .harness/run.out "$SQLV"; wit setup; order detach; wit detach; hres
  echo "A' - A again (a fresh JVM), port 19842:"
  V=("${HV[@]}" --probe.st=setup,change "$SQLD"); hrun 19842; view .harness/run.out "$SQLV"; wit setup; order change; wit change; hres; }
c_detached() { local DA DB DA2 b
  DA=$(blk detached "A - the anchor" "B - A with"); DB=$(blk detached "B - A with" "A' - A again"); DA2=$(blk detached "A' - A again" "")
  for b in "$DA" "$DA2"; do
    for l in "$SETUP3" '  PROBE setup end - after commit: id 5' '  PROBE   loaded: Kavya | mealsPerDay 3 | contains true' '  PROBE   field set to 2, no save called, contains true - before commit' "$UPD" \
        "  the order around the line \"... - before commit\" (R.197): marker found - before it: select 1 · insert 0 · update 0 · delete 0 | after it, before 'change end': select 0 · insert 0 · update 1 · delete 0" \
        "  the two witnesses for change - the SQL logger's lines between 'change begin' and its end: 2 (select 1 · insert 0 · update 1 · delete 0) · Statistics: statements 2 · inserts/updates/deletes 0 1 0 · they agree: yes" \
        '  PROBE change | statements 2 | loads 1 | inserts 0 | updates 1 | deletes 0 | flushes 1 | transactions 1' "  PROBE anchor repo reads Kavya's mealsPerDay: 2" "$POOL"; do has "$b" "$l" "detached A: the change reaches the table"; done
    ok0 "$b" "detached A"; done
  [ "$(printf '%s\n' "$DA")" = "$(printf '%s\n' "$DA2")" ] || die "detached: A' = A, line for line"
  for l in "  the two witnesses for detach - the SQL logger's lines between 'detach begin' and its end: 1 (select 1 · insert 0 · update 0 · delete 0) · Statistics: statements 1 · inserts/updates/deletes 0 0 0 · they agree: yes" \
      '  PROBE detach | statements 1 | loads 1 | inserts 0 | updates 0 | deletes 0 | flushes 0 | transactions 1' "  PROBE anchor repo reads Kavya's mealsPerDay: 3" \
      "  the order around the line \"... - before commit\" (R.197): marker found - before it: select 1 · insert 0 · update 0 · delete 0 | after it, before 'detach end': select 0 · insert 0 · update 0 · delete 0" \
      "$SETUP3" '  PROBE   loaded: Kavya | mealsPerDay 3 | contains true' '  PROBE   field set to 2, no save called, contains false - before commit' "$POOL"; do has "$DB" "$l" "detached B: detach - no UPDATE, the table keeps 3"; done
  ok0 "$DB" "detached B"
  [ "$(printf '%s\n' "$DB" | grep -cE '^  St\.java line [0-9]+: if \(detach\) em\.detach\(c\);$')" = 1 ] || die "detached B: the one line that differs, shown"
  nhas "$DB" "$UPD" "detached B: no UPDATE"
  [ "$(printf '%s\n' "$DA" | grep -cxF -- "$UPD")" = 1 ] || die "detached A: one UPDATE line"
  echo "  detached: A find, set 2, commit - the UPDATE after the marker, updates 1, the anchor reads 2; B the same with detach - contains false, no UPDATE, updates 0, flushes 0, the anchor keeps 3; A' = A"; }

# ---- merge: a detached instance, changed, merged in a new transaction ------------------------------------------------------
merge() {
  echo "the anchor and the harness (steps setup, merge), Hibernate's SQL logger at DEBUG, port 19843:"
  V=("${HV[@]}" --probe.st=setup,merge "$SQLD"); hrun 19843; view .harness/run.out "$SQLV"; wit setup; wit merge-load; order merge; wit merge; hres; }
c_merge() { local MR; MR=$(cat .r-merge.out)
  for l in "  the two witnesses for merge - the SQL logger's lines between 'merge begin' and its end: 2 (select 1 · insert 0 · update 1 · delete 0) · Statistics: statements 2 · inserts/updates/deletes 0 1 0 · they agree: yes" "$SETUP3" '  PROBE merge-load end - after commit: loaded Kavya | mealsPerDay 3' '  PROBE merge-load | statements 1 | loads 1 | inserts 0 | updates 0 | deletes 0 | flushes 1 | transactions 1' \
      '  PROBE   field set to 2 on that instance, outside any transaction' \
      '  PROBE   merge returned same object: false | identityHashCode det @… m @… | the pair equal: false' \
      '  PROBE   contains(det) false | contains(m) true | m.mealsPerDay 2 - before commit' \
      "  the order around the line \"... - before commit\" (R.197): marker found - before it: select 1 · insert 0 · update 0 · delete 0 | after it, before 'merge end': select 0 · insert 0 · update 1 · delete 0" \
      "  the two witnesses for merge - the SQL logger's lines between 'merge begin' and its end: 2 (select 1 · insert 0 · update 1 · delete 0) · Statistics: statements 2 · inserts/updates/deletes 0 1 0 · they agree: yes" \
      "  the two witnesses for merge-load - the SQL logger's lines between 'merge-load begin' and its end: 1 (select 1 · insert 0 · update 0 · delete 0) · Statistics: statements 1 · inserts/updates/deletes 0 0 0 · they agree: yes" \
      '  PROBE merge | statements 2 | loads 1 | inserts 0 | updates 1 | deletes 0 | flushes 1 | transactions 1' "  PROBE anchor repo reads Kavya's mealsPerDay: 2" "$POOL"; do has "$MR" "$l" "merge: SELECT at merge, UPDATE at the commit, another object"; done
  ok0 "$MR" merge
  echo "  merge: SELECT at merge, the UPDATE after the marker (2 = 2 SQL lines, updates 1); merge returned same object: false; contains(det) false, contains(m) true; the anchor reads 2"; }

# ---- persistdetached: the failure receipt and its A' -------------------------------------------------------------------------
trio() { local l; l=$(awk '/ ERROR [0-9]+ --- \[.*SpringApplication *: Application run failed/ { f = 1; next } f && NF > 0 { print; exit }' .harness/run.out)
  echo "  the trio (Course 4 §2e): exit $HE · ${l%%: *} · ${l#*: }"; }
persistdetached() {
  echo "B - the failure: the anchor and the harness (steps setup, persistdetached: persist of an instance loaded in a transaction that ended), Hibernate's SQL logger at DEBUG, port 19844:"
  V=("${HV[@]}" --probe.st=setup,persistdetached "$SQLD"); hrun 19844; view .harness/run.out "$SQLV"; wit persistdetached-load; wit persistdetached; trio; hres
  echo "A' - B with merge in place of persist (step mergedetached, the same instance, unchanged), port 19844:"
  V=("${HV[@]}" --probe.st=setup,mergedetached "$SQLD"); hrun 19844; view .harness/run.out "$SQLV"; wit mergedetached-load; wit mergedetached; hres; }
c_persistdetached() { local PB PA
  PB=$(blk persistdetached "B - the failure" "A' - B with"); PA=$(blk persistdetached "A' - B with" "")
  for l in '  the trio (Course 4 §2e): exit 1 · jakarta.persistence.EntityExistsException · Detached entity passed to persist: com.tiffinbox.CustomerEntity' "$SETUP3" '  PROBE persistdetached-load end - after commit: loaded Kavya | id 5' \
      '  PROBE   thrown: jakarta.persistence.EntityExistsException (in jakarta.persistence-api-3.2.0.jar)' \
      '  PROBE   its cause: org.hibernate.PersistentObjectException (in hibernate-core-7.4.13.Final.jar)' \
      "  the two witnesses for persistdetached - the SQL logger's lines between 'persistdetached begin' and its end: 0 (select 0 · insert 0 · update 0 · delete 0) · Statistics: statements 0 · inserts/updates/deletes 0 0 0 · they agree: yes" \
      '  PROBE persistdetached | statements 0 | loads 0 | inserts 0 | updates 0 | deletes 0 | flushes 0 | transactions 1' "  PROBE anchor repo reads Kavya's mealsPerDay: 3" \
      '    ERROR o.s.boot.SpringApplication: Application run failed' '  its pool: HikariPool-1 - Added connection conn0: url=jdbc:h2:mem:tiffinbox · Hibernate: HHH000001: Hibernate ORM core version 7.4.13.Final · WARN lines: 0 · ERROR lines: 1' \
      '      jakarta.persistence.EntityExistsException: Detached entity passed to persist: com.tiffinbox.CustomerEntity' \
      '      Caused by: org.hibernate.PersistentObjectException: Detached entity passed to persist: com.tiffinbox.CustomerEntity'; do has "$PB" "$l" "persistdetached B: the failure receipt"; done
  printf '%s\n' "$PB" | grep -qE '^  exit 1 · ' || die "persistdetached B: exit 1"
  for l in "$SETUP3" '  PROBE   merge returned same object: false' '  PROBE   merge(det) returned - before commit' \
      "  the two witnesses for mergedetached - the SQL logger's lines between 'mergedetached begin' and its end: 1 (select 1 · insert 0 · update 0 · delete 0) · Statistics: statements 1 · inserts/updates/deletes 0 0 0 · they agree: yes" \
      '  PROBE mergedetached | statements 1 | loads 1 | inserts 0 | updates 0 | deletes 0 | flushes 1 | transactions 1' "  PROBE anchor repo reads Kavya's mealsPerDay: 3" "$POOL"; do has "$PA" "$l" "persistdetached A': merge of the same instance"; done
  ok0 "$PA" "persistdetached A'"
  nhas "$PA" 'Application run failed' "persistdetached A': no failure"
  echo "  persistdetached: B exit 1 · jakarta.persistence.EntityExistsException (jakarta.persistence-api-3.2.0) · Detached entity passed to persist: com.tiffinbox.CustomerEntity, cause org.hibernate.PersistentObjectException (hibernate-core-7.4.13.Final), 0 statements (0 and 0); A' merge of the same instance: exit 0, 1 SELECT, updates 0"; }

# ---- removed: remove - contains false at once, the DELETE at the commit ------------------------------------------------------
removed() {
  echo "the anchor and the harness (steps setup, removed), Hibernate's SQL logger at DEBUG, port 19845:"
  V=("${HV[@]}" --probe.st=setup,removed "$SQLD"); hrun 19845; view .harness/run.out "$SQLV"; wit setup; order removed; wit removed; hres; }
c_removed() { local RM; RM=$(cat .r-removed.out)
  for l in "$SETUP3" "  PROBE anchor repo reads Kavya's mealsPerDay: 3" '  PROBE   loaded: Kavya | contains true' '  PROBE   remove(c) called, contains false - before commit' "$DEL" \
      "  the order around the line \"... - before commit\" (R.197): marker found - before it: select 1 · insert 0 · update 0 · delete 0 | after it, before 'removed end': select 0 · insert 0 · update 0 · delete 1" \
      "  the two witnesses for removed - the SQL logger's lines between 'removed begin' and its end: 2 (select 1 · insert 0 · update 0 · delete 1) · Statistics: statements 2 · inserts/updates/deletes 0 0 1 · they agree: yes" \
      '  PROBE removed | statements 2 | loads 1 | inserts 0 | updates 0 | deletes 1 | flushes 1 | transactions 1' "  PROBE anchor repo reads Kavya's mealsPerDay: no Kavya - not in the table" "$POOL"; do has "$RM" "$l" "removed: contains false before the commit, the DELETE after the marker"; done
  ok0 "$RM" removed
  echo "  removed: remove - contains false before the commit; delete from customer where id=? after the marker; statements 2 = 2, deletes 1; the anchor finds no Kavya (it read 3 before)"; }

# ---- states: the table, every cell read from the captures above -----------------------------------------------------------
# cell FILE START END REGEX: the first line of a capture's block (START .. END; END empty = to the end) matching REGEX
cell() { awk -v a="$2" -v b="$3" -v p="$4" 'index($0, a) == 1 { f = 1; next } b != "" && index($0, b) == 1 { f = 0 } f && $0 ~ p { print; exit }' ".r-$1.out"; }
after() { awk -v a="$2" -v b="$3" -v s="  PROBE $4 | " 'index($0, a) == 1 { f = 1; next } b != "" && index($0, b) == 1 { f = 0 } f && index($0, s) == 1 { g = 1; next } f && g && /^  PROBE anchor repo reads / { sub(/^  PROBE anchor repo reads Kavya.s mealsPerDay: /, ""); print; exit }' ".r-$1.out"; }
nst() { cell "$1" "$2" "$3" "^  PROBE $4 [|] statements " | sed -E 's/^.* \| statements ([0-9]+) \| loads [0-9]+ \| inserts ([0-9]+) \| updates ([0-9]+) \| deletes ([0-9]+) \| .*/\1 (insert \2 · update \3 · delete \4)/'; }
ctn() { cell "$1" "$2" "$3" "$4" | sed -E 's/^.*contains (true|false).*$/\1/'; }
states() { local c s a
  echo "the four states - each cell read by this script from the captures' files (.r-transient.out, .r-managed.out, .r-detached.out's B, .r-removed.out), never typed:"
  echo "  state     | the step (capture)     | statements (Statistics, the state's own span) | contains, asked inside the transaction | the anchor's repository reads Kavya's mealsPerDay"
  s=$(cell transient "the anchor" "" '^  PROBE   the new Kavya: ' | sed -E 's/^.* \| statements so far ([0-9]+)$/\1 (before the control)/'); c=$(ctn transient "the anchor" "" '^  PROBE   the new Kavya: '); a=$(after transient "the anchor" "" transient)
  echo "  transient | transient (transient)  | $s | $c | $a"
  s=$(nst managed "the anchor" "" managed); c=$(ctn managed "the anchor" "" ' - before commit$'); a=$(after managed "the anchor" "" managed)
  echo "  managed   | managed (managed)      | $s | $c | $a"
  s=$(nst detached "B - A with" "A' - A again" detach); c=$(ctn detached "B - A with" "A' - A again" ' - before commit$'); a=$(after detached "B - A with" "A' - A again" detach)
  echo "  detached  | detach (detached, B)   | $s | $c | $a"
  s=$(nst removed "the anchor" "" removed); c=$(ctn removed "the anchor" "" ' - before commit$'); a=$(after removed "the anchor" "" removed)
  echo "  removed   | removed (removed)      | $s | $c | $a"
  s=$(nst merge "the anchor" "" merge); c=$(cell merge "the anchor" "" '^  PROBE   contains[(]det[)] ' | sed -E 's/^  PROBE   (contains\(det\) [a-z]+ \| contains\(m\) [a-z]+).*$/\1/'); a=$(after merge "the anchor" "" merge)
  echo "  and back: detached -> merge (merge) | $s | $c | $a"; }
c_states() { local SS; SS=$(cat .r-states.out)
  for l in '  transient | transient (transient)  | 0 (before the control) | false | no Kavya - not in the table' \
      '  managed   | managed (managed)      | 2 (insert 1 · update 1 · delete 0) | true | 3' \
      '  detached  | detach (detached, B)   | 1 (insert 0 · update 0 · delete 0) | false | 3' \
      '  removed   | removed (removed)      | 2 (insert 0 · update 0 · delete 1) | false | no Kavya - not in the table' \
      '  and back: detached -> merge (merge) | 2 (insert 0 · update 1 · delete 0) | contains(det) false | contains(m) true | 2'; do has "$SS" "$l" "states: the table read from the captures"; done
  [ "$(printf '%s\n' "$SS" | grep -cE '^  (transient|managed|detached|removed) +[|] ')" = 4 ] && [ "$(printf '%s\n' "$SS" | grep -c '^  and back: ')" = 1 ] || die "states: four rows and the way back, nothing else"
  echo "  states: transient 0 · false · no Kavya; managed 2 · true · 3; detached 1 · false · 3; removed 2 · false · no Kavya; merge 2 · det false, m true · 2 - read from the captures"; }

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

# ---- exercise: the README's commands, then the solution's two blocks - in ONE shell, bash, then zsh -------------------------------
# block FILE N: the Nth bash block of FILE
block() { awk -v n="${2:-1}" '/^```bash$/ { k++; if (k == n) f = 1; next } f && /^```$/ { f = 0 } f' "$1"; }
where() { case "$1" in "$U") echo "this unit's folder" ;; "$U"/*) echo "${1#"$U"/}" ;; *) echo "outside this unit's folder" ;; esac; }
exsh() { local sh=$1 i=0 e1 d1 e2 d2 e3 d3
  rm -f .harness/ex-*.st .harness/ex-*.out .harness/mine.log
  case $sh in bash) env -i HOME="$HOME" PATH="$XPATH" /bin/bash --noprofile --norc .harness/ex-drive.sh "$U" > .harness/ex-shell.out 2>&1 < /dev/null & xpid=$! ;;
              zsh) env -i HOME="$HOME" PATH="$XPATH" /bin/zsh -f .harness/ex-drive.sh "$U" > .harness/ex-shell.out 2>&1 < /dev/null & xpid=$! ;; esac
  while kill -0 "$xpid" 2> /dev/null && [ $i -lt 1440 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$xpid" 2> /dev/null && { killtree "$xpid"; die "the exercise's $sh still ran after 360 s"; }
  wait "$xpid" || true; xpid=""
  [ -f .harness/ex-readme.st ] && [ -f .harness/ex-sol.st ] && [ -f .harness/ex-sol2.st ] || { cat .harness/ex-shell.out .harness/ex-readme.out .harness/ex-sol.out .harness/ex-sol2.out 2> /dev/null | tail -20 >&3; die "the exercise's $sh did not reach the end of all three blocks"; }
  read -r e1 d1 < .harness/ex-readme.st; read -r e2 d2 < .harness/ex-sol.st; read -r e3 d3 < .harness/ex-sol2.st
  echo "in $sh ($( [ $sh = bash ] && echo '/bin/bash --noprofile --norc' || echo '/bin/zsh -f')) - the README's lines:"
  echo "  the block's exit $e1 · what it printed:"; sed 's/^/    /' .harness/ex-readme.out
  echo "  the shell is now in: $(where "$d1") · listening on 19846 now: $(listeners 19846)"
  echo "  then the solution's lines, in the same shell - the block's exit $e2 · what it printed:"; sed 's/^/    /' .harness/ex-sol.out
  echo "  the shell is now in: $(where "$d2") · listening on 19846 now: $(listeners 19846)"
  echo "  then the other solution's lines, in the same shell - the block's exit $e3 · what it printed:"; sed 's/^/    /' .harness/ex-sol2.out
  echo "  the shell is now in: $(where "$d3") · listening on 19846 now: $(listeners 19846) · the demo token in the JVM's log: $(raw "$TOKEN" .harness/mine.log) times"; }
exercise() { local setup sol sol2 b
  setup=$(block exercise/README.md 1); sol=$(block exercise/SOLUTION.md 1); sol2=$(block exercise/SOLUTION.md 2)
  [ -n "$setup" ] && [ -n "$sol" ] && [ -n "$sol2" ] || die "exercise/README.md or SOLUTION.md (two blocks) no longer gives its commands"
  [ -z "$(block exercise/README.md 2)" ] && [ -z "$(block exercise/SOLUTION.md 3)" ] || die "exercise/README.md gives one block, SOLUTION.md two"
  for b in "$setup" "$sol" "$sol2"; do printf '%s\n' "$b" | sed -n 1p | grep -qxF 'export JAVA_HOME=/opt/homebrew/opt/openjdk@25' || die "the exercise's blocks must start by exporting this script's JAVA_HOME"; done
  for b in "$sol" "$sol2"; do
    [ "$(printf '%s\n' "$setup" | grep -c .)" = "$(printf '%s\n' "$b" | grep -c .)" ] && [ "$(diff <(printf '%s\n' "$setup") <(printf '%s\n' "$b") | grep -c '^[<>]')" = 2 ] || die "each of SOLUTION.md's blocks must be the README's with one line changed"; done
  printf '%s\n' "$setup" | grep -qF -- '"${V[@]}"' && printf '%s\n' "$setup" | grep -qE '^V=\(' || die "exercise/README.md must pass its options as an array, V (R.164, R.193)"
  printf '%s\n' "$setup" | grep -qF -- "--tiffinbox.port=19846" || die "exercise/README.md must run on port 19846"
  printf '%s\n' "$setup" > .harness/ex-readme.sh; printf '%s\n' "$sol" > .harness/ex-sol.sh; printf '%s\n' "$sol2" > .harness/ex-sol2.sh
  cat > .harness/ex-drive.sh <<'DRV'
cd "$1" || exit 1
. "$1/.harness/ex-readme.sh" > "$1/.harness/ex-readme.out" 2>&1 < /dev/null
echo "$? $PWD" > "$1/.harness/ex-readme.st"
cd "$1" || exit 1
. "$1/.harness/ex-sol.sh" > "$1/.harness/ex-sol.out" 2>&1 < /dev/null
echo "$? $PWD" > "$1/.harness/ex-sol.st"
cd "$1" || exit 1
. "$1/.harness/ex-sol2.sh" > "$1/.harness/ex-sol2.out" 2>&1 < /dev/null
echo "$? $PWD" > "$1/.harness/ex-sol2.st"
DRV
  sec .harness/anchor
  echo "exercise/README.md's $(printf '%s\n' "$setup" | grep -c .) lines, then exercise/SOLUTION.md's two blocks, exactly as written, one after the other in ONE shell - env -i (HOME, and the PATH this script was started with), started in this folder; each block starts its own JVM:"
  echo "the README's lines:"; printf '%s\n' "$setup" | sed 's/^/  $ /'
  echo "the solution's line that differs:"; diff <(printf '%s\n' "$setup") <(printf '%s\n' "$sol") | grep '^>' | sed 's/^> /  $ /'
  echo "the other solution's line that differs:"; diff <(printf '%s\n' "$setup") <(printf '%s\n' "$sol2") | grep '^>' | sed 's/^> /  $ /'
  exsh bash; exsh zsh; }
lastread() { printf '%s\n' "$1" | sed -n "s/^    PROBE anchor repo reads Kavya's mealsPerDay: //p" | tail -1; }
c_exercise() { local EXB EXZ b ER ES ES2
  EXB=$(blk exercise "in bash" "in zsh"); EXZ=$(blk exercise "in zsh" "")
  for b in "$EXB" "$EXZ"; do
    ER=$(printf '%s\n' "$b" | sed '/^  then the solution.s lines/,$d'); ES=$(printf '%s\n' "$b" | sed -n '/^  then the solution.s lines/,/^  then the other solution.s lines/p'); ES2=$(printf '%s\n' "$b" | sed -n '/^  then the other solution.s lines/,$p')
    for B_ in "$ER" "$ES" "$ES2"; do
      for l in '    exit 0' '    PROBE setup | statements 1 | loads 0 | inserts 1 | updates 0 | deletes 0 | flushes 1 | transactions 1' '    PROBE setup end - after commit: id 5'; do has "$B_" "$l" "exercise: each block persists Kavya with 2 (id 5)"; done
      [ "$(printf '%s\n' "$B_" | grep -cxF "    PROBE anchor repo reads Kavya's mealsPerDay: 2")" -ge 1 ] || die "exercise: the anchor reads 2 after the persist"; done
    has "$ER" '    PROBE ex-detach | statements 1 | loads 1 | inserts 0 | updates 0 | deletes 0 | flushes 0 | transactions 1' "exercise: the README as written - updates 0"
    has "$ES" '    PROBE ex-merge | statements 3 | loads 2 | inserts 0 | updates 1 | deletes 0 | flushes 2 | transactions 2' "exercise: the solution - merge, updates 1"
    has "$ES2" '    PROBE ex-plain | statements 2 | loads 1 | inserts 0 | updates 1 | deletes 0 | flushes 1 | transactions 1' "exercise: the other solution - no detach, updates 1"
    [ "$(lastread "$ER")" = 2 ] && [ "$(lastread "$ES")" = 3 ] && [ "$(lastread "$ES2")" = 3 ] || die "exercise: the anchor reads 2 after the README, 3 after each solution"
    [ "$(lastread "$ER")" != "$(lastread "$ES")" ] || die "exercise: broken = solved"
    nhas "$ER" 'ex-merge' "exercise: the README's half ran a solution"; nhas "$ES" 'ex-detach' "exercise: the solution's half ran the README's step"
    [ "$(printf '%s\n' "$b" | grep -cE "^  the shell is now in: this unit's folder · listening on 19846 now: 0")" = 3 ] || die "exercise: the shell back in this folder, nothing listening"; done
  [ "$(printf '%s\n' "$EXB" | grep -v '^in ')" = "$(printf '%s\n' "$EXZ" | grep -v '^in ')" ] || die "exercise: bash and zsh print the same"
  EXQ="Your turn: the README changes a customer after detaching it, and the database never hears. Make the change reach the table."
  grep -qxF -- "**Your turn:** ${EXQ#Your turn: }" exercise/README.md || die "exercise/README.md: the spoken exercise line"
  [ "$(printf '%s\n' "$EXQ" | wc -w | tr -d ' ')" -le 25 ] || die "exercise: the spoken line is over 25 words"
  block exercise/README.md 1 | grep -qF -- '--probe.st=ex-detach)' && block exercise/SOLUTION.md 1 | grep -qF -- '--probe.st=ex-merge)' && block exercise/SOLUTION.md 2 | grep -qF -- '--probe.st=ex-plain)' || die "exercise: the README's array runs ex-detach, the solution's ex-merge, the other ex-plain"
  echo "  exercise: bash and zsh alike - the README as written: ex-detach, updates 0, the anchor reads 2; the solution ex-merge: updates 1, 3; the other ex-plain: updates 1, 3; each block a fresh JVM, the shell back in this folder, nothing listening"; }

# ---- the captures, each followed by its checks ------------------------------------------------------------------------------------
cap transient transient; c_transient
cap managed managed; c_managed
cap detached detached; c_detached
cap merge merge; c_merge
cap persistdetached persistdetached; c_persistdetached
cap removed removed; c_removed
cap states states; c_states
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
# R.195: no database file anywhere in this unit's folder outside .harness/ (every database here is H2 in memory)
[ -z "$(find . -path ./.harness -prune -o -path ./.m2-demo -prune -o \( -name '*.mv.db' -o -name '*.trace.db' -o -name data -type d \) -print | head -3)" ] || die "a database file or a data/ folder outside .harness/: $(find . -path ./.harness -prune -o -path ./.m2-demo -prune -o \( -name '*.mv.db' -o -name '*.trace.db' -o -name data -type d \) -print | head -3 | paste -sd' ' -)"
echo "  tokens: 0 raw copies in $(ls .harness/raw-* | wc -l | tr -d ' ') raw capture runs, in $(ls .r-*.out | wc -l | tr -d ' ') captures, every file this unit ships, every build log and the log of every JVM ($LOGS); no path, no unit number, no time, no generated database name, no unmasked identity hash, no stack frame in any capture; every JVM's locale pinned; every start's secrets/ listed; no kill by name; no bare wait; options as arrays; no database file outside .harness/"

D_=$(diff -rq -x .m2-demo -x target -x secrets anchor/ ../c7-tiffinbox 2>&1 || true); [ -z "$D_" ] || die "anchor/ is no longer ../c7-tiffinbox at the end"
for p in $PORTS; do [ "$(listeners $p)" = 0 ] || die "something listens on $p at the end"; done
echo "  ports: nothing listens on 18425, 8080, 35729 or 19840-19849 at the end; 19849 never bound"
[ -z "$unpub" ] || die "no published hash for:$unpub - check the captures, then copy the md5s above into receipts.md5 and run again"
echo "c7-unit05: every capture 3/3 and = published; every spoken number asserted; 0 raw demo tokens; duration words 0; anchor/ = ../c7-tiffinbox (no anchor change)"
