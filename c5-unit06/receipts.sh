#!/bin/bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25.0.4.1 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# Course 5 · Property Sources and Their Precedence — this unit's receipts. One key, tiffinbox.cooks, set in five places,
# and the property source that answers; TiffinBox's own @PropertySource file found LAST, and too late for the keys Boot
# reads first; then the anchor change (the file renamed application.properties, @PropertySource and the port bridge
# gone), served, and the old run command that still starts on the wrong port without a word. Ten captures, each run
# three times and hashed; cap() DIES when a hash differs from receipts.md5; every number the video says is asserted at
# the bottom by a check that can fail.
#   stack    the key in five places: the live Environment's property sources, in order, and the bean's own field
#   ladder   the top place taken away, one at a time: 7 6 5 4 3 - then A' = all five again (A re-run)
#   late     two keys Boot reads early, in TiffinBox's @PropertySource file and in Boot's own file: when each arrives
#   bridge   the old main's port bridge is a system property: the command line outranks it; a flag first crashes it
#   change   the anchor change, file by file: one file renamed byte for byte, two annotation lines out, three bridge lines out
#   serve    the new command, the seven responses hashed; --debug first; the anchor README's logging command
#   outside  where the moved file ranks now, and two files in the working directory that outrank it
#   break    A the new command · B the old command (a bare port) · A' = A, re-run: which port the OS says it listens on
#   ignored  C a -D typed after the jar · D the same -D before -jar - plus the harness's view of C
# "before" is ../c5-unit04/after (the anchor as the last unit left it), COPIED to .harness/before and built there: this
# script never writes into another unit's folder. after/ is this unit's frozen copy of ../c5-tiffinbox after the change.
# Commands are printed exactly as they run: each goes through eval, so "$BEFORE" / "$AFTER" (the harness's classes plus
# that tree's jars, written to .harness/before.classpath and .harness/after.classpath) expand when it runs.
# Masks and filters (README.md declares each; sub/gsub only): Boot's timestamped log lines are dropped and counted, and
# so are the lines before a harness report (the banner); a kept log message loses its prefix through sub().
# Ports (brief ⚑11, 18660-18669): stack + ladder 18660 · A and A' 18661 · B's bare number 18662 (never bound: B listens
# on 18425, the file's port, by design, stopped at once) · late 18663 · the bridge's positional 18664 (never bound) and
# its flag 18665 · serve 18666, 18667 · outside + ignored 18668 · the exercise 18669.
set -e
cd "$(dirname "$0")"
# One run at a time: two runs share .harness/ and the ports, and one corrupts the other (it happened while authoring: a
# second run's rm -rf .harness took the first run's jars away mid-capture). A second run stops here instead.
mkdir .r-lock 2> /dev/null || { echo "  *** another receipts.sh is running in this folder (.r-lock exists) - if none is, rmdir .r-lock ***"; exit 1; }
trap 'rmdir .r-lock 2> /dev/null' EXIT
exec 3>&1                                            # die() speaks to the terminal even inside a redirected capture
die() { echo "  *** $* ***" >&3; exit 1; }
java -version 2>&1 | grep -q 'version "25' || die "JDK 25 needed; JAVA_HOME gives: $(java -version 2>&1 | head -1)"
# A variable of yours must not become a sixth place: every TIFFINBOX_* and SPRING_* variable, and the two variables
# that inject JVM flags, are removed from this script's environment before anything runs.
for v in $(env | sed -n 's/^\(TIFFINBOX_[A-Za-z0-9_]*\|SPRING_[A-Za-z0-9_]*\|JAVA_TOOL_OPTIONS\|JDK_JAVA_OPTIONS\)=.*/\1/p'); do unset "$v"; done
M2="$PWD/.m2-demo"

# ---- build: the previous tree (copied) and this unit's after/, both clean; then the harness ------------------------------
rm -rf .harness; mkdir -p .harness/before
rsync -a --exclude target ../c5-unit04/after/ .harness/before/
BT=.harness/before; AT=after
build() { (cd "$1" && { mvn -o -q -B -Dmaven.repo.local="$M2" -DskipTests clean package > /dev/null 2>&1 \
                        || mvn -q -B -Dmaven.repo.local="$M2" -DskipTests clean package; }) || die "build failed: $1"; }
build "$BT"; build "$AT"
jars() { echo "$PWD/$1/tiffinbox-web/target/tiffinbox-web-1.0.0.jar:$(ls "$PWD/$1"/tiffinbox-web/target/lib/*.jar | paste -sd: -)"; }
javac -cp "$(jars "$AT")" -d .harness/classes harness/com/tiffinbox/harness/*.java || die "the harness did not compile"
BEFORE="$PWD/.harness/classes:$(jars "$BT")"; AFTER="$PWD/.harness/classes:$(jars "$AT")"
printf '%s\n' "$BEFORE" > .harness/before.classpath; printf '%s\n' "$AFTER" > .harness/after.classpath   # exercise/README.md reads the second

listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
for p in 18425 18660 18661 18662 18663 18664 18665 18666 18667 18668; do
  [ "$(listeners $p)" = 0 ] || die "something already listens on $p - this unit's ports must be free (18425: B binds it by design)"; done

# runh 'COMMAND': print it exactly as typed, run it (eval, in a subshell, from this folder), keep its exit code in $ec.
runh() { echo "\$ $1"; ec=0; (eval "$1") > .harness/run.raw 2>&1 < /dev/null || ec=$?; }
# report START: the harness's own lines, from the first that starts with START. Boot's timestamped log lines are dropped
# everywhere, and the other lines before the report (the banner) too - both counted on one last line.
report() { awk -v start="$1" '
  /^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T[0-9][0-9]:/ { n++; next }
  !f && index($0, start) == 1 { f = 1 }
  f { print; next }
  { m++ }
  END { printf "… elided: %d log line(s) of Boot'"'"'s, and %d line(s) printed before the report (the banner and its blank lines) …\n", n, m }' .harness/run.raw; }
warns() { echo "WARN lines $(grep -c ' WARN ' "$1" || true) · ERROR lines $(grep -c ' ERROR ' "$1" || true)"; }

# startjar DIR 'COMMAND': print the command, start it from DIR in the background (exec: $pid is java's own pid).
startjar() { echo "\$ $2"; (cd "$1" && eval "exec $2") > .harness/jar.log 2>&1 < /dev/null & pid=$!; }
# listening: what the operating system says the process listens on (lsof), once it listens - or "nothing".
listening() { local a="" i=0
  while [ $i -lt 120 ]; do
    a=$(lsof -nP -a -p "$pid" -iTCP -sTCP:LISTEN 2> /dev/null | awk 'NR > 1 { print $9 }' | sort -u | paste -sd' ' -)
    [ -n "$a" ] && break; kill -0 "$pid" 2> /dev/null || break; sleep 0.25; i=$((i + 1)); done
  echo "${a:-nothing}"; }
# stopjar PORT: POST /shutdown on PORT, wait for the JVM to leave, require the port free again. Never call it inside $(...):
# wait needs the shell that started the JVM. Leaves the answer and the exit code in $said and $e.
stopjar() { local i=0; e=0
  said=$(curl -s --max-time 5 -X POST "http://127.0.0.1:$1/shutdown" || true)
  while kill -0 "$pid" 2> /dev/null && [ $i -lt 60 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$pid" 2> /dev/null && { kill "$pid"; die "the server on $1 was still running 15 s after POST /shutdown"; }
  wait "$pid" || e=$?
  [ "$(listeners "$1")" = 0 ] || die "something still listens on $1"; }
# the seven responses of Course 4's comparison set, on PORT, hashed on their own (the set ends with POST /shutdown)
seven() { local i
  for i in $(seq 1 80); do curl -s -o /dev/null "http://127.0.0.1:$1/kitchen" && break; sleep 0.25; done
  ../c4-unit31/curlset.sh "$1" | grep ' -> ' > .harness/responses.txt || true
  i=0; while kill -0 "$pid" 2> /dev/null && [ $i -lt 60 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$pid" 2> /dev/null && { kill "$pid"; die "the server on $1 was still running 15 s after POST /shutdown"; }
  e=0; wait "$pid" || e=$?
  [ "$(listeners "$1")" = 0 ] || die "something still listens on $1"
  echo "  exit $e · the seven responses: $(wc -l < .harness/responses.txt | tr -d ' ') lines · md5 $(md5 -q .harness/responses.txt)"; }

unpub=""
cap() { local nm=$1 h pub i; shift
  for i in 1 2 3; do "$@" > ".r-$nm.$i" 2>&1 || true; done
  h=$(md5 -q ".r-$nm.1")
  [ "$h" = "$(md5 -q ".r-$nm.2")" ] && [ "$h" = "$(md5 -q ".r-$nm.3")" ] || die "$nm drifts across three runs (diff .r-$nm.1 .r-$nm.2 .r-$nm.3)"
  mv ".r-$nm.1" ".r-$nm.out"; rm -f ".r-$nm.2" ".r-$nm.3"
  pub=$(awk -v n="$nm" '$1 == n { print $2 }' receipts.md5 2> /dev/null || true)
  if [ -z "$pub" ]; then printf '  %-8s md5 %s  3/3  (no published hash)\n' "$nm" "$h"; unpub="$unpub $nm"
  elif [ "$pub" = "$h" ]; then printf '  %-8s md5 %s  3/3  = published\n' "$nm" "$h"
  else printf '  %-8s md5 %s  3/3  DIFFERS from the published %s\n' "$nm" "$h" "$pub"
    die "$nm is not the published capture - suspect another JDK, Boot or Maven, a busy port, a variable of yours, or an edited source; diff .r-$nm.out against its block in README.md"; fi; }

# ---- stack: one key, five places, one run ---------------------------------------------------------------------------------
FIVE='TIFFINBOX_COOKS=5 java -Dtiffinbox.cooks=6 -cp "$BEFORE:places" com.tiffinbox.harness.Winner tiffinbox.cooks 18660 --tiffinbox.cooks=7'
stack() { runh "$FIVE"; echo "exit $ec"; report 'KEY '; }
cap stack stack

# ---- ladder: take the top place away, one at a time; then all five again ---------------------------------------------------
rung() { echo "$1"; runh "$2"; echo "  exit $ec · $(grep -m1 '^KEY ' .harness/run.raw)"
         echo "  $(grep -m1 "^the bean's own field" .harness/run.raw)"; }
ladder() {
  rung "A   five places" "$FIVE"
  rung "    the command-line flag taken away" 'TIFFINBOX_COOKS=5 java -Dtiffinbox.cooks=6 -cp "$BEFORE:places" com.tiffinbox.harness.Winner tiffinbox.cooks 18660'
  rung "    the system property taken away" 'TIFFINBOX_COOKS=5 java -cp "$BEFORE:places" com.tiffinbox.harness.Winner tiffinbox.cooks 18660'
  rung "    the environment variable taken away" 'java -cp "$BEFORE:places" com.tiffinbox.harness.Winner tiffinbox.cooks 18660'
  rung "    Boot's file taken away: TiffinBox's own file alone" 'java -cp "$BEFORE" com.tiffinbox.harness.Winner tiffinbox.cooks 18660'
  rung "A′  A, re-run" "$FIVE"; }
cap ladder ladder

# ---- late: two keys Boot reads early - in TiffinBox's @PropertySource file, then in Boot's own file -------------------------
KEYS=logging.level.tiffinbox,spring.main.banner-mode
late() {
  if cmp -s <(cat "$BT"/tiffinbox-web/src/main/resources/tiffinbox.properties late/boot-file/application.properties) late/tiffinbox-file/tiffinbox.properties
  then echo "late/tiffinbox-file/tiffinbox.properties is TiffinBox's own file plus the two lines of late/boot-file/application.properties: yes"
  else echo "late/tiffinbox-file/tiffinbox.properties is TiffinBox's own file plus the two lines of late/boot-file/application.properties: NO"; fi
  for d in tiffinbox-file boot-file; do
    runh "java -cp \"late/$d:\$BEFORE\" com.tiffinbox.harness.When $KEYS 18663"
    echo "exit $ec · route DEBUG lines $(grep -c 'route [A-Z]* /' .harness/run.raw || true) · banner lines $(grep -c ':: Spring Boot ::' .harness/run.raw || true) · $(warns .harness/run.raw)"
    report 'step of SpringApplication.run'; done; }
cap late late

# ---- bridge: the old main copies its first argument into a system property ---------------------------------------------------
bridge() { runh 'java -cp "$BEFORE" com.tiffinbox.harness.Winner tiffinbox.port 18664 --tiffinbox.port=18665'
  echo "exit $ec"; report 'KEY '
  echo "the same tree's own jar, in its tiffinbox-web/target, a flag first and no port:"
  echo "\$ java -jar tiffinbox-web-1.0.0.jar --debug"; e=0
  (cd "$BT/tiffinbox-web/target" && exec java -jar tiffinbox-web-1.0.0.jar --debug) > .harness/jar.log 2>&1 < /dev/null || e=$?
  echo "exit $e · $(grep -m1 '^Caused by: java.lang.NumberFormatException' .harness/jar.log || echo '(no NumberFormatException)') · listening lines $(grep -c 'TiffinBox listening on' .harness/jar.log || true)"; }
cap bridge bridge

# ---- change: the previous tree against after/, file by file (README aside); changed files diffed by git, -U0 -------------
hunk() { git diff --no-index --no-color -U0 "$1" "$2" | grep -E '^[-+]' | grep -vE '^(---|\+\+\+) ' || true; }
change() { local a b n=0 same=0 changed="" gone="" new=""
  a=$(cd "$BT" && find . -type f -not -path '*/target/*' -not -name README.md | sed 's|^\./||' | sort)
  b=$(cd "$AT" && find . -type f -not -path '*/target/*' -not -name README.md | sed 's|^\./||' | sort)
  for f in $a; do if [ -f "$AT/$f" ]; then n=$((n + 1)); if cmp -s "$BT/$f" "$AT/$f"; then same=$((same + 1)); else changed="$changed $f"; fi; else gone="$gone $f"; fi; done
  for f in $b; do [ -f "$BT/$f" ] || new="$new $f"; done
  echo "files, README aside: the previous tree $(echo "$a" | wc -l | tr -d ' ') · after/ $(echo "$b" | wc -l | tr -d ' ') · in both $n: identical $same, changed $(echo $changed | wc -w | tr -d ' ')"
  echo "  only before:$gone"; echo "  only after: $new"
  set -- $gone; local g=$1; set -- $new; local w=$1
  if [ -n "$g" ] && [ -n "$w" ] && cmp -s "$BT/$g" "$AT/$w"; then echo "  the same bytes under the new name: yes"; else echo "  the same bytes under the new name: NO"; fi
  for f in $changed; do
    local all code; all=$(hunk "$BT/$f" "$AT/$f")
    code=$(echo "$all" | grep -vE -e '^[-+][[:space:]]*$' -e '^[-+][[:space:]]*(/\*\*|\*|\*/|//)' || true)
    echo "${f##*/}, every changed line but comments and blanks ($(( $(echo "$all" | grep -c .) - $(echo "$code" | grep -c .) )) of those not shown):"
    echo "$code"; done; }
cap change change

# ---- serve: the new command, in after/tiffinbox-web/target --------------------------------------------------------------------
serve() { local T="$AT/tiffinbox-web/target"
  startjar "$T" 'java -jar tiffinbox-web-1.0.0.jar --tiffinbox.port=18666'; seven 18666
  startjar "$T" 'java -jar tiffinbox-web-1.0.0.jar --debug --tiffinbox.port=18667'; seven 18667
  echo "  the condition report printed: $(grep -c '^CONDITIONS EVALUATION REPORT$' .harness/jar.log || true) time(s)"
  echo "the anchor README's logging command:"
  startjar "$T" 'java -jar tiffinbox-web-1.0.0.jar --tiffinbox.port=18666 --logging.level.tiffinbox=debug'; seven 18666
  echo "  route DEBUG lines $(grep -c 'route [A-Z]* /' .harness/jar.log || true)"; }
cap serve serve

# ---- outside: the moved file's rank, and two files in the working directory that outrank it ------------------------------------------------
outside() { echo "from this folder: no application.properties here, and no config/ folder"
  runh 'java -cp "$AFTER" com.tiffinbox.harness.Winner tiffinbox.cooks --tiffinbox.port=18668'; echo "exit $ec"; report 'KEY '
  echo "from outside/: application.properties (tiffinbox.cooks=$(sed -n 's/^tiffinbox.cooks=//p' outside/application.properties)) and config/application.properties (tiffinbox.cooks=$(sed -n 's/^tiffinbox.cooks=//p' outside/config/application.properties))"
  runh 'cd outside && java -cp "$AFTER" com.tiffinbox.harness.Winner tiffinbox.cooks --tiffinbox.port=18668'; echo "exit $ec"; report 'KEY '; }
cap outside outside

# ---- break: A / B / A', the real jar, in after/tiffinbox-web/target -----------------------------------------------------------
side() { local l; l=$(listening); echo "  the process listens on: $l · listeners on 18662: $(listeners 18662)"
         stopjar "${l##*:}"; echo "  POST /shutdown -> ${said:-(no answer)} · exit $e · $(warns .harness/jar.log)"; }
brk() { local T="$AT/tiffinbox-web/target"
  echo "A   the new command";                              startjar "$T" 'java -jar tiffinbox-web-1.0.0.jar --tiffinbox.port=18661'; side
  echo "B   the old command: the port as a bare argument"; startjar "$T" 'java -jar tiffinbox-web-1.0.0.jar 18662'; side
  echo "A′  A, re-run";                                    startjar "$T" 'java -jar tiffinbox-web-1.0.0.jar --tiffinbox.port=18661'; side; }
cap break brk

# ---- ignored: a -D typed after the jar, and the same -D before -jar ----------------------------------------------------------
cooked() { awk '/ : orders cooked: / { s = $0; sub(/^.* : /, "", s); print s; exit }' .harness/jar.log; }
ignored() { local T="$AT/tiffinbox-web/target"
  echo "C   -D typed after the jar"; startjar "$T" 'java -jar tiffinbox-web-1.0.0.jar --tiffinbox.port=18668 -Dtiffinbox.days=7'
  l=$(listening); stopjar 18668; echo "  listens on $l · $(cooked) · exit $e · $(warns .harness/jar.log)"
  echo "D   the same -D before -jar"; startjar "$T" 'java -Dtiffinbox.days=7 -jar tiffinbox-web-1.0.0.jar --tiffinbox.port=18668'
  l=$(listening); stopjar 18668; echo "  listens on $l · $(cooked) · exit $e · $(warns .harness/jar.log)"
  echo "C, asked through the harness:"
  runh 'java -cp "$AFTER" com.tiffinbox.harness.Winner tiffinbox.days --tiffinbox.port=18668 -Dtiffinbox.days=7'
  echo "  exit $ec · $(grep -m1 '^KEY ' .harness/run.raw)"
  echo "  $(grep -m1 "^the bean's own field" .harness/run.raw)"
  echo "  $(grep -m1 '^non-option arguments' .harness/run.raw)"; }
cap ignored ignored

echo
# ---- every number the video says, asserted. Each check reads a line a program computed - never a label this script prints
# ---- unconditionally - and names the words it pays for. (The "$ ..." command lines are echoes of what ran: the published
# ---- md5 pins them, and no check pretends to test them.)
x() { grep -qE -- "$2" ".r-$1.out" || die "$1: expected /$2/"; }
n() { local c; c=$(grep -cE -- "$3" ".r-$1.out" || true); [ "$c" = "$2" ] || die "$1: expected $2 line(s) matching /$3/, found $c"; }
blk() { awk -v a="$2" -v b="$3" 'index($0, a) == 1 { f = 1; next } b != "" && index($0, b) == 1 { f = 0 } f' ".r-$1.out"; }
row() { awk -v r="$2" '$1 == r && NF >= 3 { print; exit }' ".r-$1.out"; }

# "Five places ... seven, six, five, four, three" · "Eight sources" · "the command line answers: seven" · "the bean's field: seven"
x stack '^exit 0$'
x stack '^KEY tiffinbox\.cooks -> WINNER 7 · from source 2 of 8, commandLineArgs$'
n stack 8 '^ +[0-9]+ '
[ "$(awk '/^ +[0-9]+ / && $3 != "-" && $0 !~ /view over/' .r-stack.out | wc -l | tr -d ' ')" = 5 ] || die "stack: five sources must hold the key"
[ "$(awk '/^ +[0-9]+ / && $3 == "-"' .r-stack.out | awk '{ print $2 }' | paste -sd' ' -)" = "random applicationInfo" ] || die "stack: exactly two sources hold nothing for it"
n stack 1 "^ +1 configurationProperties +7 +\(Boot's view over the sources below it\)$"
x stack '^ +2 commandLineArgs +7$'; x stack '^ +3 systemProperties +6$'
x stack '^ +4 systemEnvironment +5 +origin: System Environment Property "TIFFINBOX_COOKS"$'
x stack "^ +6 Config resource 'class path resource \[application\.properties\]' via location 'optional:classpath:/' 4 +origin: class path resource \[application\.properties\] - 2:17$"
x stack '^ +8 class path resource \[tiffinbox\.properties\] 3$'
x stack "^the bean's own field: OrderQueue\.cooks = 7$"; x stack '^non-option arguments Boot kept: \[18660\]$'
# "the last course's order still holds inside the list": system properties above the environment above TiffinBox's file;
# the command line above all three; Boot's file between the environment and TiffinBox's file, which is last
pos() { awk -v s="$2" '/^ +[0-9]+ / { if (index($0, s) > 0) { print $1; exit } }' ".r-$1.out"; }
[ "$(pos stack commandLineArgs)" -lt "$(pos stack systemProperties)" ] && [ "$(pos stack systemProperties)" -lt "$(pos stack systemEnvironment)" ] \
  && [ "$(pos stack systemEnvironment)" -lt "$(pos stack "Config resource")" ] && [ "$(pos stack "Config resource")" -lt "$(pos stack "tiffinbox.properties")" ] \
  && [ "$(pos stack "tiffinbox.properties")" = 8 ] || die "stack: expected command line < system properties < environment < Boot's file < TiffinBox's file (8 of 8)"
echo "  stack: 8 sources, 5 hold the key (7 6 5 4 3), the view and 2 hold nothing for it; the command line answers, 7; the bean's field 7; TiffinBox's file 8 of 8"

# "take the top one away each time: seven, six, five, four, three - and all five again: seven"
[ "$(grep -o 'WINNER [0-9]*' .r-ladder.out | awk '{ print $2 }' | paste -sd' ' -)" = "7 6 5 4 3 7" ] || die "ladder: expected winners 7 6 5 4 3 7"
[ "$(grep -o 'OrderQueue.cooks = [0-9]*' .r-ladder.out | awk '{ print $3 }' | paste -sd' ' -)" = "7 6 5 4 3 7" ] || die "ladder: the bean's field must equal the winner on every rung"
[ "$(grep -c '^  exit 0 · KEY ' .r-ladder.out)" = 6 ] || die "ladder: six runs, each exit 0"
[ "$(grep -o 'from source [0-9]* of [0-9]*, [A-Za-z]*' .r-ladder.out | awk '{ print $NF }' | paste -sd' ' -)" = "commandLineArgs systemProperties systemEnvironment Config class commandLineArgs" ] \
  || die "ladder: each rung must be answered by the next place down"
[ "$(blk ladder "A   " "    the command")" = "$(blk ladder "A′  " "")" ] || die "ladder: A' is not A, line for line"
echo "  ladder: 7 6 5 4 3, each from the next place down, the field equal every time; A' = A, line for line"

# "TiffinBox's own file ... zero route lines" · "Boot's file: five" · "the banner prints anyway" · "nothing warns"
x late "^late/tiffinbox-file/tiffinbox\.properties is TiffinBox's own file plus the two lines of late/boot-file/application\.properties: yes$"
F1=$(blk late '$ java -cp "late/tiffinbox-file:' '$ java -cp "late/boot-file:'); F2=$(blk late '$ java -cp "late/boot-file:' "")
echo "$F1" | grep -qx 'exit 0 · route DEBUG lines 0 · banner lines 1 · WARN lines 0 · ERROR lines 0' || die "late: TiffinBox's file - exit 0, 0 route lines, the banner printed, nothing warns"
echo "$F2" | grep -qx 'exit 0 · route DEBUG lines 5 · banner lines 0 · WARN lines 0 · ERROR lines 0' || die "late: Boot's file - 5 route lines, no banner"
st() { echo "$1" | awk -v s="$2" 'index($0, s) == 1 { print substr($0, 31) }' | awk '{ print $1, $2, $3, $4 }'; }
[ "$(st "$F1" "environment prepared")" = "- - 6 no" ] && [ "$(st "$F1" "context loaded")" = "- - 6 no" ] \
  && [ "$(st "$F1" "refresh: row-2 step begins")" = "- - 6 no" ] && [ "$(st "$F1" "refresh: row-2 step done")" = "debug off 7 no" ] \
  && [ "$(st "$F1" "context refreshed")" = "debug off 7 no" ] || die "late: TiffinBox's file must arrive in the row-2 step, after the levels are set, and never change them"
[ "$(st "$F2" "environment prepared")" = "debug off 7 yes" ] && [ "$(st "$F2" "context refreshed")" = "debug off 8 yes" ] \
  || die "late: Boot's file must be there when the environment is prepared, the level already DEBUG"
echo "$F1" | grep -qx '  logging.level.tiffinbox  <-  class path resource \[tiffinbox.properties\]' || die "late: the key must come from TiffinBox's file"
echo "$F1" | grep -qx 'the file the class path gives for tiffinbox.properties: late/tiffinbox-file/tiffinbox.properties' || die "late: the class path must give the late/ copy"
echo "$F2" | grep -qx "  logging.level.tiffinbox  <-  Config resource 'class path resource \[application.properties\]' via location 'optional:classpath:/'" || die "late: the key must come from Boot's file"
echo "  late: TiffinBox's file - the key arrives in the row-2 step (6 -> 7 sources), DEBUG never on, 0 route lines, banner 1, 0 WARN;"
echo "        Boot's file - there when the environment is prepared, DEBUG on from the start, 5 route lines, banner 0"

# "the bridge put eighteen six six four in a system property; the command line said eighteen six six five, and won"
x bridge '^KEY tiffinbox\.port -> WINNER 18665 · from source 2 of [0-9]+, commandLineArgs$'
x bridge '^ +2 commandLineArgs +18665$'; x bridge '^ +3 systemProperties +18664$'
x bridge '^ +[0-9]+ class path resource \[tiffinbox\.properties\] 18425$'
x bridge "^the bean's own field: TiffinBoxServer\.port = 18665 · its server's socket: 127\.0\.0\.1:18665$"
# "with a flag first, the bridge copies the flag, and startup crashes"
x bridge '^exit 1 · Caused by: java\.lang\.NumberFormatException: For input string: "--debug" · listening lines 0$'
echo "  bridge: system property 18664 (the bridge) under the command line's 18665 - the winner, and the socket; a flag first: exit 1, NumberFormatException, nothing listening"

# "one file renamed, byte for byte; two lines out of TiffinBoxApp; three out of main; nothing else"
x change '^files, README aside: the previous tree 14 · after/ 14 · in both 13: identical 11, changed 2$'
x change '^  only before: tiffinbox-web/src/main/resources/tiffinbox\.properties$'
x change '^  only after:  tiffinbox-web/src/main/resources/application\.properties$'
x change '^  the same bytes under the new name: yes$'
[ "$(blk change "TiffinBoxApp.java, every changed line" "TiffinBoxServer.java" | paste -sd'|' -)" = \
  '-import org.springframework.context.annotation.PropertySource;|-@PropertySource("classpath:tiffinbox.properties")' ] || die "change: TiffinBoxApp must lose the import and the annotation, and gain no code"
[ "$(blk change "TiffinBoxServer.java, every changed line" "" | paste -sd'|' -)" = \
  '-        if (args.length > 0) {|-            System.setProperty("tiffinbox.port", args[0]);   // the same command line as before|-        }' ] || die "change: main must lose the three bridge lines, and gain nothing"
x change '^TiffinBoxServer\.java, every changed line but comments and blanks \(0 of those not shown\):$'
echo "  change: 14 files each side - 11 identical, 1 renamed byte for byte, 2 changed: -2 lines (TiffinBoxApp), -3 lines (main); comments counted apart"

# "the new command: the same seven answers" · "--debug first works now" · the anchor README's logging line
[ "$(grep -c '^  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891$' .r-serve.out)" = 3 ] || die "serve: the seven responses must hash to 115c36ba..., all three runs"
x serve '^  the condition report printed: 1 time\(s\)$'
x serve '^  route DEBUG lines 5$'
echo "  serve: --tiffinbox.port, --debug first, and the README's logging command - the seven responses 115c36ba... each time; the report 1; 5 route lines"

# "the moved file now ranks sixth of seven" · "two files in the folder you start from outrank it, the config folder's first"
O1=$(blk outside "from this folder" "from outside/"); O2=$(blk outside "from outside/" "")
echo "$O1" | grep -qx "KEY tiffinbox.cooks -> WINNER 3 · from source 6 of 7, Config resource 'class path resource \[application.properties\]' via location 'optional:classpath:/'" || die "outside: the moved file answers 3, source 6 of 7"
echo "$O2" | grep -qx "KEY tiffinbox.cooks -> WINNER 9 · from source 6 of 9, Config resource 'file \[config/application.properties\]' via location 'optional:file:./config/'" || die "outside: ./config/ answers 9, source 6 of 9"
echo "$O2" | grep -qE "^ +7 Config resource 'file \[application\.properties\]' via location 'optional:file:\./' 8 " || die "outside: ./application.properties, 8, is source 7"
echo "$O2" | grep -qE "^ +8 Config resource 'class path resource \[application\.properties\]' via location 'optional:classpath:/' 3 " || die "outside: the packaged file, 3, is source 8"
echo "  outside: the moved file answers from 6 of 7; from the working directory, ./config/ (9) > ./ (8) > the packaged file (3), 9 sources"

# "A: eighteen six six one" · "B: exit zero, no warning - listening on eighteen four two five" · "A': the same as A"
BA=$(blk break "A   " "B   "); BB=$(blk break "B   " "A′  "); BA2=$(blk break "A′  " "")
echo "$BA" | grep -qx '  the process listens on: 127.0.0.1:18661 · listeners on 18662: 0' || die "break A: listening on 18661"
echo "$BB" | grep -qx '  the process listens on: 127.0.0.1:18425 · listeners on 18662: 0' || die "break B: listening on 18425, nothing on 18662"
echo "$BB" | grep -qx '  POST /shutdown -> {"stopping":true} · exit 0 · WARN lines 0 · ERROR lines 0' || die "break B: exit 0, nothing warns"
[ "$BA" = "$BA2" ] || die "break: A' is not A, line for line"
echo "  break: A 18661 · B 18425 (nothing on 18662, 0 WARN, exit 0) · A' = A, line for line"

# "a dash-D after the jar: a hundred and twenty orders, no warning; before it: twenty-eight"
[ "$(blk ignored "C   " "D   " | grep -c '^  listens on 127.0.0.1:18668 · orders cooked:  120 · exit 0 · WARN lines 0 · ERROR lines 0$')" = 1 ] || die "ignored C: 120 orders (days stayed 30), nothing warns"
[ "$(blk ignored "D   " "C, asked" | grep -c '^  listens on 127.0.0.1:18668 · orders cooked:  28 · exit 0 · WARN lines 0 · ERROR lines 0$')" = 1 ] || die "ignored D: 28 orders (days 7)"
x ignored "^  exit 0 · KEY tiffinbox\.days -> WINNER 30 · from source 6 of 7, Config resource 'class path resource \[application\.properties\]' via location 'optional:classpath:/'$"
x ignored "^  the bean's own field: TiffinBoxServer\.days = 30$"
x ignored '^  non-option arguments Boot kept: \[-Dtiffinbox\.days=7\]$'
echo "  ignored: -D after the jar - 120 orders (days 30), 0 WARN, Boot kept it as a non-option argument; before -jar - 28"
[ -z "$unpub" ] || die "no published hash for:$unpub - check the captures, then copy the md5s above into receipts.md5 and run again"
echo "c5-unit06: every capture 3/3 and = published; every spoken number asserted"
