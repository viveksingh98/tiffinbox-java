#!/bin/bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25.0.4.1 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# Course 5 · application.yaml in Practice — this unit's receipts. TiffinBox's four keys move from application.properties to
# application.yaml (the anchor change), and what the new format gives and hides: the parser that reads it, a list that is
# three keys, a second document a profile switches on, spellings Boot's view accepts, values YAML retypes as it reads
# them, and indentation mistakes - two loud ones, and one that makes no sound. Eleven captures, each run three times and
# hashed; cap() DIES when a hash differs from receipts.md5; every number the video says is asserted at the bottom by a
# check that can fail.
#   change   the previous tree against after/, file by file: the file that went and the file that came, whole
#   keys     what Boot read out of each tree's file, line by line: the same four keys and values (as text), and three more
#   serve    this tree's jar: the seven responses; then the logging flag and the lunch-rush flag after/README.md gives
#            (each read from the file, not typed here)
#   both     the old file kept beside the YAML, cooks set to 4 in the YAML: which file answers
#   parser   snakeyaml: A this tree's jar · B its lib/ without snakeyaml · A' = A · C the previous tree's, without it
#   list     a YAML list as Boot keeps it, asked three ways; then @Value: A the list · B one comma string · A' = A ·
#            C one numbered key of it
#   docs     the second document: A no profile · B the profile rush · A' = A
#   relaxed  whose code each property source is; then three spellings of tiffinbox.jdbc-url, and Database.url each time;
#            then the camel spelling in a @Value placeholder, the file keeping jdbc-url
#   scalars  three values YAML retypes: A unquoted · B quoted · A' = A
#   break    silent - A the anchor's file, rush on · B the rush block two spaces further in · A' = A;
#            loud - C a tab in front of one key · D one key a space too far in; E the list's last item one space further
#            in - a space YAML can still parse
#   files    every demo file against the anchor's application.yaml (diff), and the two copies checked byte for byte
# "before" is ../c5-unit06/after (the anchor as the last unit left it), COPIED to .harness/before and built there: this
# script never writes into another unit's folder. after/ is this unit's frozen copy of ../c5-tiffinbox after the change.
# Commands are printed exactly as they run: each goes through eval, so "$BEFORE" / "$AFTER" (the harness's classes plus
# that tree's jars, written to .harness/before.classpath and .harness/after.classpath) expand when it runs. A folder in
# front of "$AFTER" on a class path (both/, comma/, camel/, scalars/..., breaks/...) holds one file that the class path
# then gives instead of the jar's own application.yaml; `files` shows how each differs from the anchor's.
# Masks and filters (README.md declares each; sub/gsub only): Boot's timestamped log lines are dropped and counted, and so
# are the lines before a harness report (the banner); a kept log message loses its prefix through sub(); the clock time
# on Logback's first line of a failed start becomes <time>; in `files`, a tab character is shown as <TAB>.
# Ports (brief ⚑11, 18670-18679): serve 18670 · keys 18671 · both 18672 · parser 18673 (B never binds) · list 18674 ·
# docs 18675 · relaxed 18676 (the camel placeholder never binds) · scalars 18677 · break 18678 (C and D never bind) · the
# exercise 18679.
set -e
cd "$(dirname "$0")"
# One run at a time: two runs share .harness/ and the ports, and one would corrupt the other.
mkdir .r-lock 2> /dev/null || { echo "  *** another receipts.sh is running in this folder (.r-lock exists) - if none is, rmdir .r-lock ***"; exit 1; }
# On every exit - the end, a failed check, or Ctrl-C - stop the JVM this script started in the background, if it still
# runs, and drop the lock. A background job of a non-interactive shell ignores the terminal's Ctrl-C, so without the kill
# an interrupted run would leave TiffinBox listening. $pid is cleared whenever the JVM has been reaped. The clean-up
# ignores a second Ctrl-C, and nothing in it can fail under set -e (a JVM stopped by SIGTERM exits 143), so it always
# reaches the rmdir; the script still exits 130 after an interrupt.
pid=""
trap 'trap "" INT TERM; if [ -n "$pid" ] && kill "$pid" 2> /dev/null; then wait "$pid" 2> /dev/null || true; fi; rmdir .r-lock 2> /dev/null || true' EXIT
trap 'exit 130' INT TERM
exec 3>&1                                            # die() speaks to the terminal even inside a redirected capture
die() { echo "  *** $* ***" >&3; exit 1; }
java -version 2>&1 | grep -q 'version "25' || die "JDK 25 needed; JAVA_HOME gives: $(java -version 2>&1 | head -1)"
# A variable of yours must not become a property source: every TIFFINBOX_* and SPRING_* variable, and the two variables
# that inject JVM flags, are removed from this script's environment before anything runs.
for v in $(env | sed -n 's/^\(TIFFINBOX_[A-Za-z0-9_]*\|SPRING_[A-Za-z0-9_]*\|JAVA_TOOL_OPTIONS\|JDK_JAVA_OPTIONS\)=.*/\1/p'); do unset "$v"; done
M2="$PWD/.m2-demo"
YAML=tiffinbox-web/src/main/resources/application.yaml
PROPS=tiffinbox-web/src/main/resources/application.properties

# ---- build: the previous tree (copied) and this unit's after/, both clean; then the harness -----------------------------
rm -rf .harness; mkdir -p .harness/before
rsync -a --exclude target ../c5-unit06/after/ .harness/before/
BT=.harness/before; AT=after
build() { (cd "$1" && { mvn -o -q -B -Dmaven.repo.local="$M2" -DskipTests clean package > /dev/null 2>&1 \
                        || mvn -q -B -Dmaven.repo.local="$M2" -DskipTests clean package; }) || die "build failed: $1"; }
build "$BT"; build "$AT"
jars() { echo "$PWD/$1/tiffinbox-web/target/tiffinbox-web-1.0.0.jar:$(ls "$PWD/$1"/tiffinbox-web/target/lib/*.jar | paste -sd: -)"; }
javac -cp "$(jars "$AT")" -d .harness/classes harness/com/tiffinbox/harness/*.java || die "the harness did not compile"
BEFORE="$PWD/.harness/classes:$(jars "$BT")"; AFTER="$PWD/.harness/classes:$(jars "$AT")"
printf '%s\n' "$BEFORE" > .harness/before.classpath; printf '%s\n' "$AFTER" > .harness/after.classpath   # exercise/README.md reads the second
# parser's B and C: each tree's jar and lib/, copied, with lib/snakeyaml-*.jar deleted from the copy
for t in after before; do src="$AT"; [ "$t" = before ] && src="$BT"
  mkdir -p ".harness/no-snakeyaml-$t/lib"; cp "$src/tiffinbox-web/target/tiffinbox-web-1.0.0.jar" ".harness/no-snakeyaml-$t/"
  cp "$src"/tiffinbox-web/target/lib/*.jar ".harness/no-snakeyaml-$t/lib/"; rm ".harness/no-snakeyaml-$t"/lib/snakeyaml-*.jar; done

listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
for p in 18425 18670 18671 18672 18673 18674 18675 18676 18677 18678; do
  [ "$(listeners $p)" = 0 ] || die "something already listens on $p - this unit's ports must be free; if it is a TiffinBox an interrupted run left behind, stop it: curl -X POST http://127.0.0.1:$p/shutdown"; done

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
run() { runh "$1"; echo "exit $ec · $(warns .harness/run.raw)"; report "$2"; }
# a failed start: the counts that say how far it got, then Boot's report up to the line that says where
yamlfail() { echo "exit $ec · banner lines $(grep -c ':: Spring Boot ::' .harness/run.raw || true) · listening lines $(grep -c 'TiffinBox listening on' .harness/run.raw || true) · lines that name application.yaml $(grep -c 'application\.yaml' .harness/run.raw || true)"
  awk '/Application run failed$/ { f = 1; s = $0; gsub(/^[0-9][0-9]:[0-9][0-9]:[0-9][0-9]\.[0-9][0-9][0-9]/, "<time>", s); print "  " s; next }
       f { print "  " $0 } f && /^ in .reader., line [0-9]+, column [0-9]+:$/ { exit }' .harness/run.raw > .harness/fail.txt
  cat .harness/fail.txt
  grep -m1 "^the exception TiffinBox's main threw: " .harness/run.raw || echo "(no exception line)"
  echo "  … $(( $(wc -l < .harness/run.raw) - $(wc -l < .harness/fail.txt) - 1 )) more line(s) of this run's output not shown: the bad line and its caret, then the stack frames …"; }
# Boot's own INFO line about profiles, its prefix (time, level, pid, thread, logger) cut by sub()
bootsays() { awk '/ : (No active profile set|The following [0-9]+ profiles? (is|are) active)/ { s = $0; sub(/^.* : /, "", s); print s; exit }' "$1"; }

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
  wait "$pid" || e=$?; pid=""
  [ "$(listeners "$1")" = 0 ] || die "something still listens on $1"; }
# jarside: a started jar either listens (then it is stopped with POST /shutdown) or exits (then its exception line is kept)
jarside() { local l; l=$(listening)
  if [ "$l" = nothing ]; then e=0; wait "$pid" || e=$?; pid=""
    echo "  listens on: nothing · exit $e · $(warns .harness/jar.log)"
    echo "  $(grep -m1 -E '^[a-z][a-zA-Z0-9_.$]*(Exception|Error): ' .harness/jar.log || echo '(no exception line)')"
    echo "  … $(( $(wc -l < .harness/jar.log) - 1 )) more line(s) of the jar's output not shown: Logback's first line and the stack frames …"
  else stopjar "${l##*:}"; echo "  listens on: $l · POST /shutdown -> ${said:-(no answer)} · exit $e · $(warns .harness/jar.log)"; fi; }
# the seven responses of Course 4's comparison set, on PORT, hashed on their own (the set ends with POST /shutdown)
seven() { local i
  for i in $(seq 1 80); do curl -s -o /dev/null "http://127.0.0.1:$1/kitchen" && break; sleep 0.25; done
  ../c4-unit31/curlset.sh "$1" | grep ' -> ' > .harness/responses.txt || true
  i=0; while kill -0 "$pid" 2> /dev/null && [ $i -lt 60 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$pid" 2> /dev/null && { kill "$pid"; die "the server on $1 was still running 15 s after POST /shutdown"; }
  e=0; wait "$pid" || e=$?; pid=""
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

# ---- change: the previous tree against after/, file by file (README aside); changed files diffed by git, -U0 ------------
hunk() { git diff --no-index --no-color -U0 "$1" "$2" | grep -E '^[-+]' | grep -vE '^(---|\+\+\+) ' || true; }
change() { local a b n=0 same=0 changed="" gone="" new=""
  a=$(cd "$BT" && find . -type f -not -path '*/target/*' -not -name README.md | sed 's|^\./||' | sort)
  b=$(cd "$AT" && find . -type f -not -path '*/target/*' -not -name README.md | sed 's|^\./||' | sort)
  for f in $a; do if [ -f "$AT/$f" ]; then n=$((n + 1)); if cmp -s "$BT/$f" "$AT/$f"; then same=$((same + 1)); else changed="$changed $f"; fi; else gone="$gone $f"; fi; done
  for f in $b; do [ -f "$BT/$f" ] || new="$new $f"; done
  echo "files, README aside: the previous tree $(echo "$a" | wc -l | tr -d ' ') · after/ $(echo "$b" | wc -l | tr -d ' ') · in both $n: identical $same, changed $(echo $changed | wc -w | tr -d ' ')"
  echo "  only before:$gone"; echo "  only after: $new"
  for f in $changed; do
    local all code; all=$(hunk "$BT/$f" "$AT/$f")
    code=$(echo "$all" | grep -vE -e '^[-+][[:space:]]*$' -e '^[-+][[:space:]]*(/\*\*|\*|\*/|//)' || true)
    echo "${f##*/}, every changed line but comments and blanks ($(( $(echo "$all" | grep -c .) - $(echo "$code" | grep -c . || true) )) of those not shown):"
    [ -n "$code" ] && echo "$code" || echo "  (none)"; done
  echo "the file that went, whole: $PROPS"; awk '{ printf "%3d | %s\n", NR, $0 }' "$BT/$PROPS"
  echo "the file that came, whole: $YAML"; awk '{ printf "%3d | %s\n", NR, $0 }' "$AT/$YAML"; }
cap change change

# ---- keys: what Boot read out of each tree's file, line by line ----------------------------------------------------------
pairs() { sed -nE 's/^  line +[0-9]+ \| .*  ->  ([^ ]+) = (.*) \([A-Za-z]+\)$/\1=\2/p' .harness/run.raw; }
has() { awk -v k="$1" 'index($0, k "=") == 1 { f = 1 } END { exit !f }' "$2"; }     # does file $2 hold key $1?
keys() { local k found=0 same=0 only=""
  echo "the previous tree: application.properties"
  run 'java -cp "$BEFORE" com.tiffinbox.harness.Keys - tiffinbox --tiffinbox.port=18671' 'source '; pairs > .harness/keys-before.txt
  echo "this tree: application.yaml"
  run 'java -cp "$AFTER" com.tiffinbox.harness.Keys - tiffinbox --tiffinbox.port=18671' 'source '; pairs > .harness/keys-after.txt
  while IFS= read -r k; do
    has "${k%%=*}" .harness/keys-after.txt && found=$((found + 1))
    grep -qxF -- "$k" .harness/keys-after.txt && same=$((same + 1)); done < .harness/keys-before.txt
  while IFS= read -r k; do has "${k%%=*}" .harness/keys-before.txt || only="$only ${k%%=*}"; done < .harness/keys-after.txt
  echo "the old file's keys, found in the new file: $found of $(wc -l < .harness/keys-before.txt | tr -d ' ') · with the same value, as text: $same · only in the new file:$only"; }
cap keys keys

# ---- serve: this tree's jar, in after/tiffinbox-web/target -------------------------------------------------------------
# readme FLAG: the flag after/README.md's run command gives after the port, on the line whose flag starts --FLAG - read
# from the file, so a label never claims what the README says
readme() { sed -nE "s/^.*java -jar tiffinbox-web\/target\/tiffinbox-web-1\.0\.0\.jar --tiffinbox\.port=[0-9]+ (--$1[^\` ]*).*$/\1/p" "$AT/README.md" | head -1; }
serve() { local T="$AT/tiffinbox-web/target" f
  startjar "$T" 'java -jar tiffinbox-web-1.0.0.jar --tiffinbox.port=18670'; seven 18670
  f=$(readme logging.level); [ -n "$f" ] || die "after/README.md no longer gives a logging command"
  echo "the logging flag after/README.md gives, after the port: $f"
  startjar "$T" "java -jar tiffinbox-web-1.0.0.jar --tiffinbox.port=18670 $f"; seven 18670
  echo "  route DEBUG lines $(grep -c 'route [A-Z]* /' .harness/jar.log || true)"
  f=$(readme spring.profiles); [ -n "$f" ] || die "after/README.md no longer gives the lunch-rush command"
  echo "the lunch-rush flag after/README.md gives, after the port: $f"
  startjar "$T" "java -jar tiffinbox-web-1.0.0.jar --tiffinbox.port=18670 $f"; seven 18670
  echo "  Boot: $(bootsays .harness/jar.log)"; }
cap serve serve

# ---- both: the old file kept beside the YAML -----------------------------------------------------------------------------
both() { run 'java -cp "both:$AFTER" com.tiffinbox.harness.Winner tiffinbox.cooks --tiffinbox.port=18672' 'KEY '; }
cap both both

# ---- parser: snakeyaml, the jar that reads YAML ------------------------------------------------------------------------------
parser() { local T="$AT/tiffinbox-web/target"
  echo "A   this tree's jar, lib/ as built: $(ls "$T/lib" | wc -l | tr -d ' ') jars, snakeyaml among them: $(ls "$T/lib" | grep '^snakeyaml-' || echo none)"
  startjar "$T" 'java -jar tiffinbox-web-1.0.0.jar --tiffinbox.port=18673'; jarside
  echo "B   a copy of the same jar and lib/, lib/snakeyaml-*.jar deleted: $(ls .harness/no-snakeyaml-after/lib | wc -l | tr -d ' ') jars"
  startjar .harness/no-snakeyaml-after 'java -jar tiffinbox-web-1.0.0.jar --tiffinbox.port=18673'; jarside
  echo "A′  A, re-run"
  startjar "$T" 'java -jar tiffinbox-web-1.0.0.jar --tiffinbox.port=18673'; jarside
  echo "C   the previous tree's jar and lib/ (application.properties), copied, snakeyaml deleted the same way: $(ls .harness/no-snakeyaml-before/lib | wc -l | tr -d ' ') jars"
  startjar .harness/no-snakeyaml-before 'java -jar tiffinbox-web-1.0.0.jar --tiffinbox.port=18673'; jarside; }
cap parser parser

# ---- list: what a YAML list becomes, and @Value asked for it -------------------------------------------------------------------
list() {
  run 'java -cp "$AFTER" com.tiffinbox.harness.ListKey tiffinbox.meal-types --tiffinbox.port=18674' 'source '
  readers
  echo "the harness's reader, the way TiffinBox's classes read a key: $(grep -o '@Value("[^"]*") List<String> mealTypes' harness/com/tiffinbox/harness/MealTypesByValue.java)"
  echo "A   the list as the anchor writes it: three items"
  runh 'java -cp "$AFTER" com.tiffinbox.harness.ByValue --tiffinbox.port=18674'; byvalue
  echo "B   comma/: the same list written as one string"
  runh 'java -cp "comma:$AFTER" com.tiffinbox.harness.ByValue --tiffinbox.port=18674'; byvalue
  echo "A′  A, re-run"
  runh 'java -cp "$AFTER" com.tiffinbox.harness.ByValue --tiffinbox.port=18674'; byvalue
  echo "C   one numbered key of the list: @Value(\"\${tiffinbox.meal-types[0]}\")"
  runh 'java -cp "$AFTER" com.tiffinbox.harness.ItemByValue --tiffinbox.port=18674'; byvalue; }
# how TiffinBox's own classes read their settings: every @Value placeholder naming a tiffinbox key, in after/'s sources
readers() { local f c=0 names=""
  for f in $(grep -rlE --include='*.java' '@Value\("\$\{tiffinbox\.' "$AT" | sort); do
    c=$((c + $(grep -oE '@Value\("\$\{tiffinbox\.' "$f" | wc -l))); names="$names ${f##*/}"; done   # -o: two can share a line
  echo "TiffinBox's own readers, in after/: $c @Value placeholders, in$names"; }
byvalue() { echo "  exit $ec · $(warns .harness/run.raw) · listening lines $(grep -c 'TiffinBox listening on' .harness/run.raw || true)"
  if [ "$ec" = 0 ]; then echo "  $(grep -m1 '^@Value(' .harness/run.raw)"
  else echo "  $(grep -m1 '^Caused by: .*PlaceholderResolutionException' .harness/run.raw || echo '(no placeholder line)')"
       echo "  $(grep -m1 "^the exception TiffinBox's main threw: " .harness/run.raw)"
       echo "  … $(( $(wc -l < .harness/run.raw) - 2 )) more line(s) of this run's output not shown: the banner, Boot's log, its failure report and the stack frames …"; fi; }
cap list list

# ---- docs: the second document, and the profile that switches it on ---------------------------------------------------------------
doc() { runh "$1"; echo "exit $ec · $(warns .harness/run.raw) · Boot: $(bootsays .harness/run.raw)"; report 'KEY '; }
docs() {
  echo "A   no profile"; doc 'java -cp "$AFTER" com.tiffinbox.harness.Winner tiffinbox.cooks --tiffinbox.port=18675'
  echo "B   the profile rush, switched on"; doc 'java -cp "$AFTER" com.tiffinbox.harness.Winner tiffinbox.cooks --tiffinbox.port=18675 --spring.profiles.active=rush'
  echo "A′  A, re-run"; doc 'java -cp "$AFTER" com.tiffinbox.harness.Winner tiffinbox.cooks --tiffinbox.port=18675'; }
cap docs docs

# ---- relaxed: three spellings of one key -----------------------------------------------------------------------------------------
relaxed() {
  run 'java -cp "$AFTER" com.tiffinbox.harness.Sources --tiffinbox.port=18676' 'the property sources'
  echo "an environment variable, underscores for the dot and the dash"
  run "TIFFINBOX_JDBC_URL='jdbc:h2:mem:underscores;DB_CLOSE_DELAY=-1' java -cp \"\$AFTER\" com.tiffinbox.harness.Winner tiffinbox.jdbc-url --tiffinbox.port=18676" 'KEY '
  echo "an environment variable, no underscore for the dash"
  run "TIFFINBOX_JDBCURL='jdbc:h2:mem:nodash;DB_CLOSE_DELAY=-1' java -cp \"\$AFTER\" com.tiffinbox.harness.Winner tiffinbox.jdbc-url --tiffinbox.port=18676" 'KEY '
  echo "camel/: the key written in camel case in the file"
  run 'java -cp "camel:$AFTER" com.tiffinbox.harness.Winner tiffinbox.jdbc-url --tiffinbox.port=18676' 'KEY '
  echo "the other way round: a placeholder in camel case, @Value(\"\${tiffinbox.jdbcUrl}\"), the file keeping jdbc-url"
  runh 'java -cp "$AFTER" com.tiffinbox.harness.CamelByValue --tiffinbox.port=18676'; byvalue; }
cap relaxed relaxed

# ---- scalars: three values YAML retypes as it reads them ----------------------------------------------------------------------------
S3=tiffinbox.country,tiffinbox.sunday,tiffinbox.menu-version
# the pattern snakeyaml's resolver compiles into its BOOL field: the string constant loaded just before that field is set
rule() { local j; j=$(ls "$AT/tiffinbox-web/target/lib" | grep '^snakeyaml-')
  echo "the words a plain YAML value becomes true or false for: the BOOL pattern of org.yaml.snakeyaml.resolver.Resolver, in lib/$j (javap):"
  javap -c -constants -cp "$AT/tiffinbox-web/target/lib/$j" org.yaml.snakeyaml.resolver.Resolver \
    | awk '/ ldc .*\/\/ String / { s = $0; sub(/^.*\/\/ String /, "", s) } /putstatic .*Field BOOL:/ { print "  " s; exit }'; }
scalars() { rule
  echo "A   scalars/unquoted"; run "java -cp \"scalars/unquoted:\$AFTER\" com.tiffinbox.harness.Keys - $S3 --tiffinbox.port=18677" 'source '
  echo "B   scalars/quoted: the same three values in double quotes"; run "java -cp \"scalars/quoted:\$AFTER\" com.tiffinbox.harness.Keys - $S3 --tiffinbox.port=18677" 'source '
  echo "A′  A, re-run"; run "java -cp \"scalars/unquoted:\$AFTER\" com.tiffinbox.harness.Keys - $S3 --tiffinbox.port=18677" 'source '; }
cap scalars scalars

# ---- break: one file swapped through the class path, the same command otherwise -------------------------------------------------------
BK='com.tiffinbox.harness.Keys tiffinbox.cooks tiffinbox.cooks,spring.tiffinbox --tiffinbox.port=18678 --spring.profiles.active=rush'
brk() {
  echo "A   the anchor's own file, the profile rush on"; run "java -cp \"\$AFTER\" $BK" 'source '
  echo "B   breaks/nested: the rush document's tiffinbox block, two spaces further in"; run "java -cp \"breaks/nested:\$AFTER\" $BK" 'source '
  echo "A′  A, re-run"; run "java -cp \"\$AFTER\" $BK" 'source '
  echo "C   breaks/tab: one key's two-space indent replaced by a tab"; runh "java -cp \"breaks/tab:\$AFTER\" $BK"; yamlfail
  echo "D   breaks/over: one key indented one space too far"; runh "java -cp \"breaks/over:\$AFTER\" $BK"; yamlfail
  echo "E   breaks/onespace: the list's last item one space further in than the two above it"
  run 'java -cp "breaks/onespace:$AFTER" com.tiffinbox.harness.Keys - tiffinbox.meal-types --tiffinbox.port=18678' 'source '; }
cap break brk

# ---- files: every demo file, against the anchor's --------------------------------------------------------------------------------------
files() { local f
  for f in both/application.yaml comma/application.yaml camel/application.yaml scalars/unquoted/application.yaml scalars/quoted/application.yaml \
           breaks/nested/application.yaml breaks/tab/application.yaml breaks/over/application.yaml breaks/onespace/application.yaml \
           exercise/application.yaml; do
    if cmp -s "$AT/$YAML" "$f"; then echo "$f: the anchor's application.yaml, byte for byte"
    else echo "$f, against the anchor's application.yaml:"; diff "$AT/$YAML" "$f" | awk '{ gsub(/\t/, "<TAB>"); print "  " $0 }' || true; fi; done
  if cmp -s "$BT/$PROPS" both/application.properties; then echo "both/application.properties: the previous tree's application.properties, byte for byte"
  else echo "both/application.properties: NOT the previous tree's application.properties"; fi; }
cap files files

echo
# ---- every number the video says, asserted. Each check reads a line a program computed - never a label this script prints
# ---- unconditionally - and names the words it pays for. (The "$ ..." command lines are echoes of what ran: the published
# ---- md5 pins them, and no check pretends to test them.)
x() { grep -qE -- "$2" ".r-$1.out" || die "$1: expected /$2/"; }
n() { local c; c=$(grep -cE -- "$3" ".r-$1.out" || true); [ "$c" = "$2" ] || die "$1: expected $2 line(s) matching /$3/, found $c"; }
blk() { awk -v a="$2" -v b="$3" 'index($0, a) == 1 { f = 1; next } b != "" && index($0, b) == 1 { f = 0 } f' ".r-$1.out"; }
has1() { printf '%s\n' "$1" | grep -qxF -- "$2" || die "$3: expected the line: $2"; }     # an exact line inside a block
Q="'"                                                                               # a single quote, inside '...'

# "one key per line, with the word tiffinbox typed four times" · "each dot becomes one level of nesting, so tiffinbox is
# written once" · the anchor change: one file gone, one file new, TiffinBoxApp's comments only, nothing else
x change '^files, README aside: the previous tree 14 · after/ 14 · in both 13: identical 12, changed 1$'
x change '^  only before: tiffinbox-web/src/main/resources/application\.properties$'
x change '^  only after:  tiffinbox-web/src/main/resources/application\.yaml$'
x change '^TiffinBoxApp\.java, every changed line but comments and blanks \([0-9]+ of those not shown\):$'
[ "$(blk change 'TiffinBoxApp.java, every changed line' 'the file that went')" = "  (none)" ] || die "change: TiffinBoxApp must change comments only"
WENT=$(blk change 'the file that went, whole:' 'the file that came, whole:'); CAME=$(blk change 'the file that came, whole:' '')
[ "$(printf '%s\n' "$WENT" | grep -cE '^ +[0-9]+ \| tiffinbox\.[a-z-]+=')" = 4 ] || die "change: the old file must hold four keys, each typed with tiffinbox."
DOC0=$(printf '%s\n' "$CAME" | awk -F' [|] ' '$2 == "---" { exit } { print $2 }')
[ "$(printf '%s\n' "$DOC0" | grep -cx 'tiffinbox:')" = 1 ] && [ "$(printf '%s\n' "$DOC0" | grep -c 'tiffinbox\.')" = 0 ] \
  || die "change: the new file's first document writes tiffinbox once, as a key of its own, and never as tiffinbox."
has1 "$CAME" ' 19 |   cooks: 6' change; has1 "$CAME" ' 17 |       on-profile: rush' change; has1 "$CAME" ' 12 | ---' change
echo "  change: 1 file gone (4 keys, each typed with tiffinbox.), 1 new (tiffinbox: once in document 0; the rush document: 6 cooks), TiffinBoxApp comments only"

# "I asked Boot what it read from each file: the same four keys, the same values, as text"
x keys '^the old file.s keys, found in the new file: 4 of 4 · with the same value, as text: 4 · only in the new file: tiffinbox\.meal-types\[0\] tiffinbox\.meal-types\[1\] tiffinbox\.meal-types\[2\]$'
[ "$(grep -c '^exit 0 · WARN lines 0 · ERROR lines 0$' .r-keys.out)" = 2 ] || die "keys: both trees start, nothing warns"
echo "  keys: the old file's 4 keys in the new file, 4 of 4, the same values; 3 more, the list's"

# "the last course's seven requests get the same answers, one hash"
[ "$(grep -c '^  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891$' .r-serve.out)" = 3 ] || die "serve: the seven responses must hash to 115c36ba..., all three runs"
x serve '^  route DEBUG lines 5$'; x serve '^  Boot: The following 1 profile is active: "rush"$'
x serve '^the logging flag after/README\.md gives, after the port: --logging\.level\.tiffinbox=debug$'
x serve '^the lunch-rush flag after/README\.md gives, after the port: --spring\.profiles\.active=rush$'
echo "  serve: the seven responses 115c36ba... with the new file, with the README's logging command (5 route lines), and with rush on"

# "I kept it, then set four cooks in the YAML. Boot answered three. In the same folder, Boot asks the properties file first"
x both "^KEY tiffinbox\.cooks -> WINNER 3 · from source 6 of 8, Config resource ${Q}class path resource \[application\.properties\]${Q} via location ${Q}optional:classpath:/${Q}$"
x both "^ +7 Config resource ${Q}class path resource \[application\.yaml\]${Q} via location ${Q}optional:classpath:/${Q} \(document #0\) 4 +origin: "
x both '^the bean.s own field: OrderQueue\.cooks = 3$'; x both '^exit 0 · WARN lines 0 · ERROR lines 0$'
x both '^the class path gives: application\.yaml <- both/application\.yaml · application\.properties <- both/application\.properties$'
x files '^both/application\.properties: the previous tree.s application\.properties, byte for byte$'
[ "$(blk files 'both/application.yaml, against' 'comma/application.yaml' | paste -sd'|' -)" = '  4c4|  <   cooks: 3|  ---|  >   cooks: 4' ] || die "files: both/application.yaml must differ from the anchor's in cooks alone, 3 -> 4"
echo "  both: the old file beside the YAML (YAML cooks 4): WINNER 3 from the properties file, source 6 of 8, the YAML's 4 at 7; 0 WARN"

# "I deleted that one jar. Exit one ... Put it back: it starts. The previous version starts fine without it"
PA=$(blk parser 'A   ' 'B   '); PB=$(blk parser 'B   ' 'A′  '); PA2=$(blk parser 'A′  ' 'C   '); PC=$(blk parser 'C   ' '')
OK18673='  listens on: 127.0.0.1:18673 · POST /shutdown -> {"stopping":true} · exit 0 · WARN lines 0 · ERROR lines 0'
has1 "$PA" "$OK18673" parser; has1 "$PC" "$OK18673" parser; [ "$PA" = "$PA2" ] || die "parser: A' is not A, line for line"
has1 "$PB" '  listens on: nothing · exit 1 · WARN lines 0 · ERROR lines 1' parser
has1 "$PB" "  java.lang.IllegalStateException: Attempted to load Config resource 'class path resource [application.yaml]' via location 'optional:classpath:/' but snakeyaml was not found on the classpath" parser
x parser '^A   this tree.s jar, lib/ as built: [0-9]+ jars, snakeyaml among them: snakeyaml-[0-9.]+\.jar$'
[ "$(sed -nE 's/^A   .*: ([0-9]+) jars, .*/\1/p' .r-parser.out)" = "$(( $(sed -nE 's/^B   .*: ([0-9]+) jars$/\1/p' .r-parser.out) + 1 ))" ] || die "parser: B's lib/ must be A's minus one jar"
echo "  parser: A listens, B (no snakeyaml) exit 1 naming application.yaml and snakeyaml, A' = A, C (the previous tree, no snakeyaml) listens"

# "It keeps three keys, numbered zero, one and two" · "by its own name ... null" · "Boot's binder ... puts the three back together"
[ "$(grep -cE '^  line +[0-9]+ \|     - [A-Z_]+ +->  tiffinbox\.meal-types\[[0-2]\] = [A-Z_]+ \(String\)$' .r-list.out)" = 3 ] || die "list: three keys, [0] [1] [2]"
x list '^TiffinBox.s own readers, in after/: 4 @Value placeholders, in Database\.java OrderQueue\.java TiffinBoxServer\.java$'
x list '^env\.getProperty\("tiffinbox\.meal-types"\)    = null$'; x list '^env\.getProperty\("tiffinbox\.meal-types\[1\]"\) = NON_VEG$'
x list '^Boot.s Binder, asked for a List<String> at tiffinbox\.meal-types: \[VEG, NON_VEG, VEGAN\]$'
# "the Value annotation ... exit one, could not resolve placeholder. One comma-separated string: it works. Back to three items: exit one again"
LA=$(blk list 'A   ' 'B   '); LB=$(blk list 'B   ' 'A′  '); LA2=$(blk list 'A′  ' 'C   '); LC=$(blk list 'C   ' '')
has1 "$LA" '  exit 1 · WARN lines 1 · ERROR lines 1 · listening lines 0' list
has1 "$LA" "  Caused by: org.springframework.util.PlaceholderResolutionException: Could not resolve placeholder 'tiffinbox.meal-types' in value \"\${tiffinbox.meal-types}\"" list
has1 "$LB" '  exit 0 · WARN lines 0 · ERROR lines 0 · listening lines 1' list
has1 "$LB" '  @Value("${tiffinbox.meal-types}") List<String> mealTypes = [VEG, NON_VEG, VEGAN]' list
[ "$LA" = "$LA2" ] || die "list: A' is not A, line for line"
# the recap: "Value reads one of them, never the whole list"
has1 "$LC" '  exit 0 · WARN lines 0 · ERROR lines 0 · listening lines 1' list
has1 "$LC" '  @Value("${tiffinbox.meal-types[0]}") String first = VEG' list
[ "$(blk files 'comma/application.yaml, against' 'camel/application.yaml' | grep -c '^  >')" = 1 ] && x files '^  >   meal-types: VEG,NON_VEG,VEGAN$' \
  || die "files: comma/ must replace the list's four lines with one"
echo "  list: 3 keys [0] [1] [2]; the list's own name null; the Binder [VEG, NON_VEG, VEGAN]; @Value A exit 1 (placeholder), B one string exit 0, A' = A; C one numbered key: VEG"

# "Without the profile, that document isn't even a property source: seven sources, three cooks. Switch rush on: eight
# sources, document one above document zero, and six cooks. Switch it off again: three."
DA=$(blk docs 'A   ' 'B   '); DB=$(blk docs 'B   ' 'A′  '); DA2=$(blk docs 'A′  ' '')
has1 "$DA" "KEY tiffinbox.cooks -> WINNER 3 · from source 6 of 7, Config resource 'class path resource [application.yaml]' via location 'optional:classpath:/' (document #0)" docs
[ "$(printf '%s\n' "$DA" | grep -c 'document #1')" = 0 ] || die "docs: without the profile, document 1 must not be a property source"
has1 "$DB" "KEY tiffinbox.cooks -> WINNER 6 · from source 6 of 8, Config resource 'class path resource [application.yaml]' via location 'optional:classpath:/' (document #1)" docs
printf '%s\n' "$DB" | grep -qE '^ +6 .*\(document #1\) 6 +origin: .* - 19:10$' && printf '%s\n' "$DB" | grep -qE '^ +7 .*\(document #0\) 3 +origin: .* - 4:10$' \
  || die "docs: with rush, document 1 (6, line 19) must rank above document 0 (3, line 4)"
has1 "$DA" 'exit 0 · WARN lines 0 · ERROR lines 0 · Boot: No active profile set, falling back to 1 default profile: "default"' docs
has1 "$DB" 'exit 0 · WARN lines 0 · ERROR lines 0 · Boot: The following 1 profile is active: "rush"' docs
[ "$DA" = "$DA2" ] || die "docs: A' is not A, line for line"
echo "  docs: A 7 sources, cooks 3, no document 1; B (rush) 8 sources, document 1 (6) above document 0 (3); A' = A"

# "Underscores for the dot and the dash: the environment-variable source finds it, by Spring's own rule. Drop the dash's
# underscore: that source finds nothing, yet the database gets the value. Camel case in the file works too. Both came
# through Boot's view, a source at the top that searches the others by more spellings."
x relaxed '^ +1 configurationProperties +org\.springframework\.boot\.context\.properties\.source\.ConfigurationPropertySourcesPropertySource$'
x relaxed '^systemEnvironment.s class extends org\.springframework\.core\.env\.SystemEnvironmentPropertySource: true$'
x relaxed '^the method that matches a key to a variable.s name, resolvePropertyName, is declared by org\.springframework\.core\.env\.SystemEnvironmentPropertySource · final: true$'
R1=$(blk relaxed 'an environment variable, underscores' 'an environment variable, no underscore'); R2=$(blk relaxed 'an environment variable, no underscore' 'camel/'); R3=$(blk relaxed 'camel/' 'the other way round'); R4=$(blk relaxed 'the other way round' '')
has1 "$R1" '   4 systemEnvironment          jdbc:h2:mem:underscores;DB_CLOSE_DELAY=-1   origin: System Environment Property "TIFFINBOX_JDBC_URL"' relaxed
has1 "$R1" "the bean's own field: Database.url = jdbc:h2:mem:underscores;DB_CLOSE_DELAY=-1" relaxed
[ "$(printf '%s\n' "$R1" | grep -c 'not under that name')" = 0 ] || die "relaxed: the underscore spelling is found under its own name"
has1 "$R2" '   4 systemEnvironment          -' relaxed
has1 "$R2" "  not under that name: Boot's view found it under the name TIFFINBOX_JDBCURL · System Environment Property \"TIFFINBOX_JDBCURL\"" relaxed
has1 "$R2" "the bean's own field: Database.url = jdbc:h2:mem:nodash;DB_CLOSE_DELAY=-1" relaxed
printf '%s\n' "$R3" | grep -qE "^ +6 Config resource .*\(document #0\) -$" || die "relaxed: the camel-case file holds nothing under tiffinbox.jdbc-url"
has1 "$R3" "  not under that name: Boot's view found it under the name tiffinbox.jdbcUrl · class path resource [application.yaml] - 3:12, the line reads:   jdbcUrl: jdbc:h2:mem:camel;DB_CLOSE_DELAY=-1" relaxed
has1 "$R3" "the bean's own field: Database.url = jdbc:h2:mem:camel;DB_CLOSE_DELAY=-1" relaxed
# the chip: "one way only - a placeholder must use the dashed name"
has1 "$R4" '  exit 1 · WARN lines 1 · ERROR lines 1 · listening lines 0' relaxed
has1 "$R4" "  Caused by: org.springframework.util.PlaceholderResolutionException: Could not resolve placeholder 'tiffinbox.jdbcUrl' in value \"\${tiffinbox.jdbcUrl}\"" relaxed
echo "  relaxed: TIFFINBOX_JDBC_URL found by systemEnvironment itself (Spring's final resolvePropertyName); TIFFINBOX_JDBCURL and jdbcUrl only through Boot's view; Database.url each time;"
echo "           the other way round, @Value(\"\${tiffinbox.jdbcUrl}\") with the file's jdbc-url: exit 1, could not resolve placeholder"

# "NO, a country code, becomes false. It's on snake YAML's own list ... and so is off. Version one point one zero becomes
# one point one. Quote them, and they stay text."
has1 "$(cat .r-scalars.out)" '  ^(?:yes|Yes|YES|no|No|NO|true|True|TRUE|false|False|FALSE|on|On|ON|off|Off|OFF)$' scalars
SA=$(blk scalars 'A   ' 'B   '); SB=$(blk scalars 'B   ' 'A′  '); SA2=$(blk scalars 'A′  ' '')
has1 "$SA" '  line  7 |   country: NO         ->  tiffinbox.country = false (Boolean)' scalars
has1 "$SA" '  line  8 |   sunday: off         ->  tiffinbox.sunday = false (Boolean)' scalars
has1 "$SA" '  line  9 |   menu-version: 1.10  ->  tiffinbox.menu-version = 1.1 (Double)' scalars
has1 "$SB" '  line  7 |   country: "NO"         ->  tiffinbox.country = NO (String)' scalars
has1 "$SB" '  line  8 |   sunday: "off"         ->  tiffinbox.sunday = off (String)' scalars
has1 "$SB" '  line  9 |   menu-version: "1.10"  ->  tiffinbox.menu-version = 1.10 (String)' scalars
[ "$SA" = "$SA2" ] || die "scalars: A' is not A, line for line"
echo "  scalars: NO -> false, off -> false (both in snakeyaml's BOOL pattern), 1.10 -> 1.1; quoted: NO, off, 1.10, as text; A' = A"

# the loud half: "A tab in front of one key: exit one, with a line and a column. That one space: the same. Neither
# error names the file." · the silent half: "A: rush on, six cooks. B: ... two spaces further ... Exit zero, no warning,
# three cooks. The document still loads, but its key is now spring dot tiffinbox dot cooks. A again: six."
BA=$(blk break 'A   ' 'B   '); BB=$(blk break 'B   ' 'A′  '); BA2=$(blk break 'A′  ' 'C   '); BC=$(blk break 'C   ' 'D   '); BD=$(blk break 'D   ' 'E   ')
BE=$(blk break 'E   ' '')
has1 "$BA" "KEY tiffinbox.cooks -> WINNER 6 · the bean's own field: OrderQueue.cooks = 6" break
has1 "$BB" 'exit 0 · WARN lines 0 · ERROR lines 0' break
has1 "$BB" "KEY tiffinbox.cooks -> WINNER 3 · the bean's own field: OrderQueue.cooks = 3" break
has1 "$BB" "source 6 of 8 · Config resource 'class path resource [application.yaml]' via location 'optional:classpath:/' (document #1)" break
has1 "$BB" '  line 19 |     cooks: 6  ->  spring.tiffinbox.cooks = 6 (Integer)' break
[ "$BA" = "$BA2" ] || die "break: A' is not A, line for line"
LOUD='exit 1 · banner lines 0 · listening lines 0 · lines that name application.yaml 0'
has1 "$BC" "$LOUD" break; has1 "$BD" "$LOUD" break
has1 "$BC" "   in 'reader', line 4, column 1:" break; has1 "$BD" "   in 'reader', line 4, column 9:" break
has1 "$BC" "  found character '\\t(TAB)' that cannot start any token. (Do not use \\t(TAB) for indentation)" break
has1 "$BD" '  mapping values are not allowed here' break
[ "$(grep -c "^the exception TiffinBox's main threw: org.yaml.snakeyaml.scanner.ScannerException$" .r-break.out)" = 2 ] || die "break: C and D throw snakeyaml's ScannerException"
[ "$(blk files 'breaks/nested/application.yaml, against' 'breaks/tab/' | paste -sd'|' -)" = '  18,19c18,19|  < tiffinbox:|  <   cooks: 6|  ---|  >   tiffinbox:|  >     cooks: 6' ] \
  || die "files: breaks/nested must move the rush block two spaces further in, nothing else"
[ "$(blk files 'breaks/tab/application.yaml, against' 'breaks/over/' | paste -sd'|' -)" = '  4c4|  <   cooks: 3|  ---|  > <TAB>cooks: 3' ] || die "files: breaks/tab must put a tab in front of one key"
[ "$(blk files 'breaks/over/application.yaml, against' 'breaks/onespace/' | paste -sd'|' -)" = '  4c4|  <   cooks: 3|  ---|  >    cooks: 3' ] || die "files: breaks/over must indent one key one space further"
# "That one space: the same" is D's space only - E: one space YAML can still parse is silent, the third item merged into the second
has1 "$BE" 'exit 0 · WARN lines 0 · ERROR lines 0' break
has1 "$BE" '  line  9 |     - VEG      ->  tiffinbox.meal-types[0] = VEG (String)' break
has1 "$BE" '  line 10 |     - NON_VEG  ->  tiffinbox.meal-types[1] = NON_VEG - VEGAN (String)' break
[ "$(printf '%s\n' "$BE" | grep -c '^  line ')" = 2 ] || die "break: E must leave two keys, the third item merged into the second"
[ "$(blk files 'breaks/onespace/application.yaml, against' 'exercise/' | paste -sd'|' -)" = '  11c11|  <     - VEGAN|  ---|  >      - VEGAN' ] \
  || die "files: breaks/onespace must indent the list's last item one space further, nothing else"
echo "  break: A 6 · B (the block two spaces in) exit 0, 0 WARN, 3, document 1 loaded holding spring.tiffinbox.cooks · A' = A;"
echo "         C (a tab) and D (a space too many) exit 1 at line 4 column 1 and 9, 0 lines naming application.yaml, 0 banner, 0 listening;"
echo "         E (the list's last item one space in) exit 0, 0 WARN: two keys, the third item merged into the second"
x files '^exercise/application\.yaml: the anchor.s application\.yaml, byte for byte$'
[ -z "$unpub" ] || die "no published hash for:$unpub - check the captures, then copy the md5s above into receipts.md5 and run again"
echo "c5-unit07: every capture 3/3 and = published; every spoken number asserted"
