#!/bin/bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25.0.4.1 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# Course 5 · @ConfigurationProperties — this unit's receipts. TiffinBox's four @Value placeholders, in three classes, give
# way to one typed record, TiffinBoxProperties, bound by Boot's binder from every key under "tiffinbox" - the list included
# (the anchor change). Then what it buys and what it quietly costs: the metadata file an IDE reads, and the processor that
# writes it only when it is named on the right path; the enum converter the last course wrote by hand, now Boot's; the
# placeholder resolver, one auto-configuration; and a key deleted from the file, which @Value refused and the record turns
# into a zero. Ten captures, each run three times and hashed; cap() DIES when a hash differs from receipts.md5; every
# number the video says is asserted at the bottom by a check that can fail.
#   change      the previous tree against after/, file by file: every changed code line, the two new files whole, the
#               @Value placeholders counted in each tree
#   record      the record in the running app: A this tree · B built without @EnableConfigurationProperties · A' = A ·
#               C this tree with the profile rush on
#   serve       this tree's jar: the seven responses and the list's log line; then the logging flag and the lunch-rush
#               flag after/README.md gives (each read from the file, not typed here)
#   processor   six builds, one question - is the metadata file written? A the processor as an optional dependency ·
#               B the processor path (after/) · A' = A · C A plus <proc>full</proc> · D the processor path in web only ·
#               E A without <optional>: the processor a plain dependency
#   metadata    the file in this tree's core jar, whole, then read: sections, the @param text, the int defaults; and the
#               jars in lib/ that carry a file of the same name
#   lenient     enum values written loosely: A veg, non-veg, "Vegan " · B the third one vegetarian · A' = A
#   convert     who converts them: Boot's conversion service, and a plain Spring context on the same class path
#   placeholder who resolves placeholders; then a typo: A as TiffinBox runs · B one auto-configuration excluded · A' = A ·
#               C the same typo with a default after the colon
#   break       one key deleted: A this tree · B days deleted · A' = A · C the previous tree, days deleted · D the text
#               key jdbc-url deleted · E the meal-types list deleted
#   files       every demo file against the file it stands in for (diff)
# "before" is ../c5-unit07/after (the anchor as the last unit left it), COPIED to .harness/before and built there: this
# script never writes into another unit's folder. after/ is this unit's frozen copy of ../c5-tiffinbox after the change.
# Every build is a clean one, run in a copy under .harness/ (after/ itself is built in place, as the tree the others copy).
# Commands are printed exactly as they run: each goes through eval, so "$BEFORE" / "$AFTER" / "$NOENABLE" (the harness's
# classes plus that tree's jars, written to .harness/*.classpath) and "$M2" (this unit's own repository, .m2-demo) expand
# when it runs. A folder in front of "$AFTER" on a class path (nodays/, lenient/, vegetarian/) holds one application.yaml
# that the class path then gives instead of the jar's own; `files` shows how each differs from the anchor's.
# Masks and filters (README.md declares each; sub/gsub only): Boot's timestamped log lines are dropped and counted, and so
# are the lines before a harness report (the banner); a kept log message loses its prefix through sub(); a failure
# report is shown without its blank lines and its rows of asterisks, the rest counted; the processor builds are reduced to
# counts (exit, BUILD line, WARNING and ERROR lines, files found).
# Ports (brief ⚑11, 18680-18689): serve 18680 · record 18681 (B never binds) · lenient 18682 (B never binds) ·
# convert 18683 · placeholder 18684 (A never binds) · break 18685 (C and D never bind) · the exercise 18689.
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
# that inject JVM flags, are removed from this script's environment before anything runs. MAVEN_OPTS and MAVEN_ARGS too.
for v in $(env | sed -n 's/^\(TIFFINBOX_[A-Za-z0-9_]*\|SPRING_[A-Za-z0-9_]*\|JAVA_TOOL_OPTIONS\|JDK_JAVA_OPTIONS\|MAVEN_OPTS\|MAVEN_ARGS\)=.*/\1/p'); do unset "$v"; done
M2="$PWD/.m2-demo"
REC=tiffinbox-core/src/main/java/com/tiffinbox/TiffinBoxProperties.java
YAML=tiffinbox-web/src/main/resources/application.yaml
APP=tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxApp.java

# ---- build: the previous tree (copied), after/, and after/ without @EnableConfigurationProperties (copied), all clean ------
rm -rf .harness; mkdir -p .harness/before .harness/noenable
rsync -a --exclude target ../c5-unit07/after/ .harness/before/
rsync -a --exclude target after/ .harness/noenable/; cp noenable/TiffinBoxApp.java ".harness/noenable/$APP"
BT=.harness/before; AT=after; NT=.harness/noenable
build() { (cd "$1" && { mvn -o -q -B -Dmaven.repo.local="$M2" -DskipTests clean package > /dev/null 2>&1 \
                        || mvn -q -B -Dmaven.repo.local="$M2" -DskipTests clean package; }) || die "build failed: $1"; }
build "$BT"; build "$AT"; build "$NT"
jars() { echo "$PWD/$1/tiffinbox-web/target/tiffinbox-web-1.0.0.jar:$(ls "$PWD/$1"/tiffinbox-web/target/lib/*.jar | paste -sd: -)"; }
javac -cp "$(jars "$AT")" -d .harness/classes harness/com/tiffinbox/harness/*.java || die "the harness did not compile"
BEFORE="$PWD/.harness/classes:$(jars "$BT")"; AFTER="$PWD/.harness/classes:$(jars "$AT")"; NOENABLE="$PWD/.harness/classes:$(jars "$NT")"
printf '%s\n' "$BEFORE" > .harness/before.classpath; printf '%s\n' "$AFTER" > .harness/after.classpath   # exercise/README.md reads the second
printf '%s\n' "$NOENABLE" > .harness/noenable.classpath

listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
for p in 18425 18680 18681 18682 18683 18684 18685; do
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
# said FILE MESSAGE: TiffinBox's (or Boot's) own INFO line that starts with MESSAGE, its prefix (time, level, pid, thread,
# logger) cut by sub() - or "(no such line)"
said() { awk -v m="$2" '{ s = $0; sub(/^[0-9][0-9][0-9][0-9]-[^ ]* +[A-Z]+ [0-9]+ --- \[[^]]*\] [^:]* : /, "", s) } index(s, m) == 1 { print s; f = 1; exit } END { if (!f) print "(no such line)" }' "$1"; }
# a failed start: how far it got, then Boot's own failure report without its blank lines and its rows of asterisks (or,
# when there is none, the one "Caused by:" line), then the exception the harness names, and the count of lines not shown
failed() { local shown
  echo "  exit $ec · $(warns .harness/run.raw) · listening lines $(grep -c 'TiffinBox listening on' .harness/run.raw || true)"
  if grep -q '^APPLICATION FAILED TO START$' .harness/run.raw; then
    awk '/^APPLICATION FAILED TO START$/ { f = 1 } /^the exception TiffinBox.s main threw: / { f = 0 } f && !/^[*]+$/ && !/^[[:space:]]*$/ { print "  " $0 }' .harness/run.raw > .harness/fail.txt
  else grep -m1 '^Caused by: ' .harness/run.raw | sed 's/^/  /' > .harness/fail.txt || echo "  (no Caused by: line)" > .harness/fail.txt; fi
  cat .harness/fail.txt
  echo "  $(grep -m1 "^the exception TiffinBox's main threw: " .harness/run.raw || echo '(no exception line)')"
  shown=$(( $(wc -l < .harness/fail.txt) + 1 ))
  echo "  … $(( $(wc -l < .harness/run.raw) - shown )) more line(s) of this run's output not shown: the banner, Boot's log, the blank lines and the stack frames …"; }

# startjar DIR 'COMMAND': print the command, start it from DIR in the background (exec: $pid is java's own pid).
startjar() { echo "\$ $2"; (cd "$1" && eval "exec $2") > .harness/jar.log 2>&1 < /dev/null & pid=$!; }
# listening: what the operating system says the process listens on (lsof), once it listens - or "nothing".
listening() { local a="" i=0
  while [ $i -lt 120 ]; do
    a=$(lsof -nP -a -p "$pid" -iTCP -sTCP:LISTEN 2> /dev/null | awk 'NR > 1 { print $9 }' | sort -u | paste -sd' ' -)
    [ -n "$a" ] && break; kill -0 "$pid" 2> /dev/null || break; sleep 0.25; i=$((i + 1)); done
  echo "${a:-nothing}"; }
# the seven responses of Course 4's comparison set, on PORT, hashed on their own (the set ends with POST /shutdown); the
# JVM must leave within 15 s of it, and the port must be free again. Never call it inside $(...): wait needs this shell.
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
  if [ -z "$pub" ]; then printf '  %-11s md5 %s  3/3  (no published hash)\n' "$nm" "$h"; unpub="$unpub $nm"
  elif [ "$pub" = "$h" ]; then printf '  %-11s md5 %s  3/3  = published\n' "$nm" "$h"
  else printf '  %-11s md5 %s  3/3  DIFFERS from the published %s\n' "$nm" "$h" "$pub"
    die "$nm is not the published capture - suspect another JDK, Boot or Maven, a busy port, a variable of yours, or an edited source; diff .r-$nm.out against its block in README.md"; fi; }

# ---- change: the previous tree against after/, file by file (README aside) --------------------------------------------------
# code FILE: its code lines - blank lines and comments dropped (Java: /* */ blocks and lines starting * or //; XML: <!-- -->)
code() { local x=0; case "$1" in *.xml) x=1;; esac; awk -v xml="$x" '
  { t = $0; sub(/^[ \t]+/, "", t) }
  inc { if (index(t, xml ? "-->" : "*/")) inc = 0; next }
  xml && index(t, "<!--") == 1 { if (!index(t, "-->")) inc = 1; next }
  !xml && index(t, "/*") == 1 { if (!index(t, "*/")) inc = 1; next }
  !xml && (index(t, "//") == 1 || index(t, "*") == 1) { next }
  t == "" { next }
  { print }' "$1"; }
pm() { git diff --no-index --no-color -U0 "$1" "$2" | grep -E '^[-+]' | grep -vE '^(---|\+\+\+) ' || true; }   # changed lines, +/-
short() { case "$1" in pom.xml) echo "pom.xml (the root)";; */pom.xml) echo "$1";; *) echo "${1##*/}";; esac; }
readers() { local f c=0 names=""
  for f in $(grep -rlE --include='*.java' '@Value\("\$\{tiffinbox\.' "$1" | sort); do
    c=$((c + $(grep -oE '@Value\("\$\{tiffinbox\.' "$f" | wc -l | tr -d ' '))); names="$names ${f##*/}"; done   # -o: two can share a line
  echo "$c${names:+, in$names}"; }
change() { local a b n=0 same=0 changed="" gone="" new="" f all cod
  a=$(cd "$BT" && find . -type f -not -path '*/target/*' -not -name README.md | sed 's|^\./||' | sort)
  b=$(cd "$AT" && find . -type f -not -path '*/target/*' -not -name README.md | sed 's|^\./||' | sort)
  for f in $a; do if [ -f "$AT/$f" ]; then n=$((n + 1)); if cmp -s "$BT/$f" "$AT/$f"; then same=$((same + 1)); else changed="$changed $f"; fi; else gone="$gone $f"; fi; done
  for f in $b; do [ -f "$BT/$f" ] || new="$new $f"; done
  echo "files, README aside: the previous tree $(echo "$a" | wc -l | tr -d ' ') · after/ $(echo "$b" | wc -l | tr -d ' ') · in both $n: identical $same, changed $(echo $changed | wc -w | tr -d ' ')"
  echo "  only before:${gone:- (none)}"; echo "  only after: $new"
  mkdir -p .harness/code
  for f in $changed; do
    code "$BT/$f" > .harness/code/b; code "$AT/$f" > .harness/code/a
    all=$(pm "$BT/$f" "$AT/$f" | grep -c . || true); cod=$(pm .harness/code/b .harness/code/a)
    echo "$(short "$f"), every changed line but comments and blanks ($(( all - $(echo "$cod" | grep -c . || true) )) of those not shown):"
    echo "${cod:-  (none)}"; done
  echo "TiffinBox's @Value placeholders: the previous tree $(readers "$BT") · after/ $(readers "$AT")"
  echo "  the keys the previous tree's placeholders name: $(grep -rhoE --include='*.java' '@Value\("\$\{tiffinbox\.[a-z-]+' "$BT" | sed 's/.*{//' | sort -u | paste -sd' ' -)"
  for f in $new; do echo "the new file, whole: $f"; awk '{ printf "%3d | %s\n", NR, $0 }' "$AT/$f"; done; }
cap change change

# ---- record: the record in the running app -----------------------------------------------------------------------------------
record() {
  echo "A   this tree"; run 'java -cp "$AFTER" com.tiffinbox.harness.Props --tiffinbox.port=18681' 'beans of type'
  echo "B   this tree built with noenable/TiffinBoxApp.java: @EnableConfigurationProperties and its two imports taken out"
  runh 'java -cp "$NOENABLE" com.tiffinbox.harness.Props --tiffinbox.port=18681'; failed
  echo "A′  A, re-run"; run 'java -cp "$AFTER" com.tiffinbox.harness.Props --tiffinbox.port=18681' 'beans of type'
  echo "C   this tree, the profile rush on"; run 'java -cp "$AFTER" com.tiffinbox.harness.Props --tiffinbox.port=18681 --spring.profiles.active=rush' 'beans of type'; }
cap record record

# ---- serve: this tree's jar, in after/tiffinbox-web/target -----------------------------------------------------------------
# readme FLAG: the flag after/README.md's run command gives after the port, on the line whose flag starts --FLAG - read
# from the file, so a label never claims what the README says
readme() { sed -nE "s/^.*java -jar tiffinbox-web\/target\/tiffinbox-web-1\.0\.0\.jar --tiffinbox\.port=[0-9]+ (--$1[^\` ]*).*$/\1/p" "$AT/README.md" | head -1; }
serve() { local T="$AT/tiffinbox-web/target" f
  startjar "$T" 'java -jar tiffinbox-web-1.0.0.jar --tiffinbox.port=18680'; seven 18680
  echo "  TiffinBox's log: $(said .harness/jar.log 'meal types:')"
  f=$(readme logging.level); [ -n "$f" ] || die "after/README.md no longer gives a logging command"
  echo "the logging flag after/README.md gives, after the port: $f"
  startjar "$T" "java -jar tiffinbox-web-1.0.0.jar --tiffinbox.port=18680 $f"; seven 18680
  echo "  route DEBUG lines $(grep -c 'route [A-Z]* /' .harness/jar.log || true)"
  f=$(readme spring.profiles); [ -n "$f" ] || die "after/README.md no longer gives the lunch-rush command"
  echo "the lunch-rush flag after/README.md gives, after the port: $f"
  startjar "$T" "java -jar tiffinbox-web-1.0.0.jar --tiffinbox.port=18680 $f"; seven 18680
  echo "  Boot: $(said .harness/jar.log 'The following')"; }
cap serve serve

# ---- processor: five clean builds, each in a copy of after/ with the variant's POMs laid over it ----------------------------
# The metadata file is looked for under both modules' target/ folders; lib/ is web's, where the manifest's Class-Path points.
variant() { rm -rf ".harness/proc-$1"; rsync -a --exclude target after/ ".harness/proc-$1/"; }
mvnrun() { local d=".harness/proc-$1" found n
  echo "\$ cd $d && mvn -o -B -Dmaven.repo.local=\"\$M2\" -DskipTests clean package"
  ec=0; (cd "$d" && mvn -o -B -Dmaven.repo.local="$M2" -DskipTests clean package) > .harness/mvn.log 2>&1 < /dev/null || ec=$?
  echo "  exit $ec · $(grep -m1 -oE 'BUILD (SUCCESS|FAILURE)' .harness/mvn.log || echo 'no BUILD line') · WARNING lines $(grep -c '^\[WARNING\]' .harness/mvn.log || true) · ERROR lines $(grep -c '^\[ERROR\]' .harness/mvn.log || true)"
  found=$(cd "$d" && find tiffinbox-core/target tiffinbox-web/target -name spring-configuration-metadata.json 2> /dev/null | sort)
  n=$(echo "$found" | grep -c . || true)
  echo "  metadata files under the two modules' target/: $n${found:+ · $(echo $found)}"
  if [ "$n" = 1 ]; then
    if [ "$1" = path ]; then cp "$d/$found" .harness/metadata-path.json
    else echo "  the same bytes as B's file: $(cmp -s "$d/$found" .harness/metadata-path.json && echo yes || echo no)"; fi; fi
  echo "  lib/: $(ls "$d/tiffinbox-web/target/lib" | wc -l | tr -d ' ') jars · the processor among them: $(ls "$d/tiffinbox-web/target/lib" | grep -c 'configuration-processor' || true) · named in the manifest's Class-Path: $(unzip -p "$d/tiffinbox-web/target/tiffinbox-web-1.0.0.jar" META-INF/MANIFEST.MF | tr -d '\r\n ' | grep -o 'configuration-processor' | wc -l | tr -d ' ')"; }
processor() {
  echo "A   the processor as an optional dependency: processor/dependency/pom.xml (the root, no processor path) · processor/dependency/tiffinbox-core/pom.xml (the processor, <optional>)"
  variant dependency; cp processor/dependency/pom.xml .harness/proc-dependency/pom.xml
  cp processor/dependency/tiffinbox-core/pom.xml .harness/proc-dependency/tiffinbox-core/pom.xml; mvnrun dependency
  echo "B   this unit's after/, copied: the processor on the compiler's processor path, in the root pom.xml"
  variant path; mvnrun path
  echo "A′  A, re-run"
  variant dependency; cp processor/dependency/pom.xml .harness/proc-dependency/pom.xml
  cp processor/dependency/tiffinbox-core/pom.xml .harness/proc-dependency/tiffinbox-core/pom.xml; mvnrun dependency
  echo "C   A, plus <proc>full</proc> for the compiler: processor/full/pom.xml (the root) · A's tiffinbox-core/pom.xml"
  variant full; cp processor/full/pom.xml .harness/proc-full/pom.xml
  cp processor/dependency/tiffinbox-core/pom.xml .harness/proc-full/tiffinbox-core/pom.xml; mvnrun full
  echo "D   the processor path in tiffinbox-web only: A's root pom.xml · processor/web/tiffinbox-web/pom.xml · after/'s tiffinbox-core/pom.xml"
  variant web; cp processor/dependency/pom.xml .harness/proc-web/pom.xml
  cp processor/web/tiffinbox-web/pom.xml .harness/proc-web/tiffinbox-web/pom.xml; mvnrun web
  echo "E   A without <optional>: A's root pom.xml · processor/plain/tiffinbox-core/pom.xml (the processor a plain dependency)"
  variant plain; cp processor/dependency/pom.xml .harness/proc-plain/pom.xml
  cp processor/plain/tiffinbox-core/pom.xml .harness/proc-plain/tiffinbox-core/pom.xml; mvnrun plain; }
cap processor processor

# ---- metadata: the file in this tree's core jar -------------------------------------------------------------------------------
metadata() { local J=after/tiffinbox-web/target/lib/tiffinbox-core-1.0.0.jar j c=0 names=""
  echo "\$ unzip -p $J META-INF/spring-configuration-metadata.json"
  unzip -p "$J" META-INF/spring-configuration-metadata.json | awk '{ printf "%3d | %s\n", NR, $0 }'
  runh "java -cp \"\$AFTER\" com.tiffinbox.harness.Metadata $J after/$REC"; echo "exit $ec"; cat .harness/run.raw
  echo "the previous tree's core jar, the same question:"
  runh "java -cp \"\$AFTER\" com.tiffinbox.harness.Metadata .harness/before/tiffinbox-web/target/lib/tiffinbox-core-1.0.0.jar after/$REC"; echo "exit $ec"; cat .harness/run.raw
  # the same file name in every jar of lib/ (unzip -l lists the one entry, or fails): Boot's own jars carry one too
  for j in after/tiffinbox-web/target/lib/*.jar; do
    unzip -l "$j" META-INF/spring-configuration-metadata.json > /dev/null 2>&1 && { c=$((c + 1)); names="$names ${j##*/}"; }; done
  echo "the jars in after/'s lib/ that carry a META-INF/spring-configuration-metadata.json: $c of $(ls after/tiffinbox-web/target/lib/*.jar | wc -l | tr -d ' ') ·$names"; }
cap metadata metadata

# ---- lenient: enum values written loosely ------------------------------------------------------------------------------------------
converters() { grep -rlE --include='*.java' 'implements +(Converter|ConverterFactory|GenericConverter)[^A-Za-z]' "$1" | wc -l | tr -d ' '; }
lenient() {
  echo "converters TiffinBox declares, in after/: $(converters "$AT") classes implement Converter, ConverterFactory or GenericConverter"
  echo "A   lenient/: the list written veg, non-veg, \"Vegan \" (a trailing space)"
  run 'java -cp "lenient:$AFTER" com.tiffinbox.harness.Favourite --tiffinbox.port=18682 --tiffinbox.favourite=non-veg' '  line '
  echo "B   vegetarian/: the third item written vegetarian"
  runh 'java -cp "vegetarian:$AFTER" com.tiffinbox.harness.Favourite --tiffinbox.port=18682 --tiffinbox.favourite=non-veg'; failed
  echo "A′  A, re-run"
  run 'java -cp "lenient:$AFTER" com.tiffinbox.harness.Favourite --tiffinbox.port=18682 --tiffinbox.favourite=non-veg' '  line '; }
cap lenient lenient

# ---- convert: Boot's conversion service, and plain Spring's ------------------------------------------------------------------------
convert() { run 'java -cp "$AFTER" com.tiffinbox.harness.Convert --tiffinbox.port=18683' 'Boot - '
  # the run's WARN lines, each as its logger and its message up to the exception's own text (both cut by sub())
  grep ' WARN ' .harness/run.raw | awk '{ s = $0; sub(/^[0-9][0-9][0-9][0-9]-[^ ]* +WARN [0-9]+ --- \[[^]]*\] /, "", s); sub(/: org\.springframework\..*$/, "", s); print "the WARN line: " s }'; }
cap convert convert

# ---- placeholder: who resolves placeholders, and a typo ----------------------------------------------------------------------------
X=org.springframework.boot.autoconfigure.context.PropertyPlaceholderAutoConfiguration
typo() { runh "$1"
  if [ "$ec" = 0 ]; then echo "  exit $ec · $(warns .harness/run.raw) · listening lines $(grep -c 'TiffinBox listening on' .harness/run.raw || true)"
    report '@Value(' | sed 's/^/  /'; else failed; fi; }
placeholder() {
  echo "TiffinBox as it runs: who resolves placeholders"
  run 'java -cp "$AFTER" com.tiffinbox.harness.Placeholders - --tiffinbox.port=18684' 'PropertySourcesPlaceholderConfigurer'
  echo "A   one bean added, with a typo in its placeholder: @Value(\"\${tiffinbox.mael}\") String mael"
  typo 'java -cp "$AFTER" com.tiffinbox.harness.Placeholders mael --tiffinbox.port=18684'
  echo "B   the same, with the one auto-configuration that declares that bean excluded"
  typo "java -cp \"\$AFTER\" com.tiffinbox.harness.Placeholders mael --tiffinbox.port=18684 --spring.autoconfigure.exclude=$X"
  echo "A′  A, re-run"
  typo 'java -cp "$AFTER" com.tiffinbox.harness.Placeholders mael --tiffinbox.port=18684'
  echo "C   the same typo, with a default after the colon: @Value(\"\${tiffinbox.mael:VEG}\") String mael"
  typo 'java -cp "$AFTER" com.tiffinbox.harness.Placeholders mael:VEG --tiffinbox.port=18684'; }
cap placeholder placeholder

# ---- break: one key deleted --------------------------------------------------------------------------------------------------------
# a failed start whose output is a chain of "Caused by:" lines and no failure report: how far it got, the chain's length
# and its last line - the root cause - then the exception the harness names, and the count of lines not shown
rootfail() {
  echo "  exit $ec · $(warns .harness/run.raw) · listening lines $(grep -c 'TiffinBox listening on' .harness/run.raw || true)"
  echo "  \"Caused by:\" lines $(grep -c '^Caused by: ' .harness/run.raw || true) · the last, the root cause: $(grep '^Caused by: ' .harness/run.raw | tail -1 | sed 's/^Caused by: //')"
  echo "  $(grep -m1 "^the exception TiffinBox's main threw: " .harness/run.raw || echo '(no exception line)')"
  echo "  … $(( $(wc -l < .harness/run.raw) - 2 )) more line(s) of this run's output not shown: the banner, Boot's log, the other \"Caused by:\" lines and the stack frames …"; }
# served 'COMMAND' [root]: start it; if it listens, the harness's two lines, TiffinBox's orders-cooked line, the /kitchen
# response and the seven responses; if it exits, how far it got and why (with root: the chain's last "Caused by:")
served() { local l
  startjar . "$1"; l=$(listening)
  if [ "$l" = nothing ]; then ec=0; wait "$pid" || ec=$?; pid=""; cp .harness/jar.log .harness/run.raw
    if [ "${2:-}" = root ]; then rootfail; else failed; fi
  else seven "${l##*:}" > .harness/seven.txt
    echo "  listens on: $l · $(warns .harness/jar.log)"
    grep -E '^the (record|class path gives)' .harness/jar.log | sed 's/^/  /'
    echo "  TiffinBox's log: $(said .harness/jar.log 'orders cooked:')"
    echo "  $(grep ' /kitchen ' .harness/responses.txt)"; cat .harness/seven.txt; fi; }
brk() {
  echo "A   this tree, the anchor's own file"; served 'java -cp "$AFTER" com.tiffinbox.harness.Serve --tiffinbox.port=18685'
  echo "B   nodays/: the anchor's file with the days line deleted"; served 'java -cp "nodays:$AFTER" com.tiffinbox.harness.Serve --tiffinbox.port=18685'
  echo "A′  A, re-run"; served 'java -cp "$AFTER" com.tiffinbox.harness.Serve --tiffinbox.port=18685'
  echo "C   the previous tree (@Value), the same nodays/ file"; served 'java -cp "nodays:$BEFORE" com.tiffinbox.harness.Serve --tiffinbox.port=18685'
  echo "D   nourl/: the anchor's file with the jdbc-url line deleted - text, not a number"
  served 'java -cp "nourl:$AFTER" com.tiffinbox.harness.Serve --tiffinbox.port=18685' root
  echo "E   nomeals/: the anchor's file with the meal-types list deleted"
  served 'java -cp "nomeals:$AFTER" com.tiffinbox.harness.Serve --tiffinbox.port=18685'; }
cap break brk

# ---- files: every demo file, against the file it stands in for ---------------------------------------------------------------------
files() { local f
  against() { if cmp -s "$1" "$2"; then echo "$2: $3, byte for byte"
              else echo "$2, against $3:"; diff "$1" "$2" | sed 's/^/  /' || true; fi; }
  for f in nodays nourl nomeals lenient; do against "$AT/$YAML" "$f/application.yaml" "the anchor's application.yaml"; done
  against lenient/application.yaml vegetarian/application.yaml "lenient/application.yaml"
  against "$AT/$APP" noenable/TiffinBoxApp.java "after/'s TiffinBoxApp.java"
  against "$BT/pom.xml" processor/dependency/pom.xml "the previous tree's pom.xml (the root)"
  against "$AT/pom.xml" processor/dependency/pom.xml "after/'s pom.xml (the root)"
  against "$AT/tiffinbox-core/pom.xml" processor/dependency/tiffinbox-core/pom.xml "after/'s tiffinbox-core/pom.xml"
  against processor/dependency/tiffinbox-core/pom.xml processor/plain/tiffinbox-core/pom.xml "processor/dependency/tiffinbox-core/pom.xml"
  against processor/dependency/pom.xml processor/full/pom.xml "processor/dependency/pom.xml"
  against "$AT/tiffinbox-web/pom.xml" processor/web/tiffinbox-web/pom.xml "after/'s tiffinbox-web/pom.xml"; }
cap files files

echo
# ---- every number the video says, asserted. Each check reads a line a program computed - never a label this script prints
# ---- unconditionally - and names the words it pays for. (The "$ ..." command lines are echoes of what ran: the published
# ---- md5 pins them, and no check pretends to test them.)
x() { grep -qE -- "$2" ".r-$1.out" || die "$1: expected /$2/"; }
blk() { awk -v a="$2" -v b="$3" 'index($0, a) == 1 { f = 1; next } b != "" && index($0, b) == 1 { f = 0 } f' ".r-$1.out"; }
has1() { printf '%s\n' "$1" | grep -qxF -- "$2" || die "$3: expected the line: $2"; }     # an exact line inside a block
cnt() { printf '%s\n' "$1" | grep -cE -- "$2" || true; }                                 # lines of a block matching a pattern
Q="'"                                                                               # a single quote, inside '...'

# "four Value placeholders, in three classes ... None of them reads it" · "Value placeholders: four before, zero after" ·
# "The database, the kitchen and the server now take the record in their constructors" · "One more annotation, on
# TiffinBoxApp" · the anchor change: two new files, six changed, nothing else
x change '^files, README aside: the previous tree 14 · after/ 16 · in both 14: identical 8, changed 6$'
x change '^  only before: \(none\)$'
x change '^  only after:  tiffinbox-core/src/main/java/com/tiffinbox/MealType\.java tiffinbox-core/src/main/java/com/tiffinbox/TiffinBoxProperties\.java$'
x change '^TiffinBox.s @Value placeholders: the previous tree 4, in Database\.java OrderQueue\.java TiffinBoxServer\.java · after/ 0$'
x change '^  the keys the previous tree.s placeholders name: tiffinbox\.cooks tiffinbox\.days tiffinbox\.jdbc-url tiffinbox\.port$'
CD=$(blk change 'Database.java, every changed line' 'OrderQueue.java'); CO=$(blk change 'OrderQueue.java, every changed line' 'TiffinBoxApp.java')
CA=$(blk change 'TiffinBoxApp.java, every changed line' 'TiffinBoxServer.java'); CS=$(blk change 'TiffinBoxServer.java, every changed line' "TiffinBox's @Value")
has1 "$CD" '+    public Database(TiffinBoxProperties settings) {' change; has1 "$CD" '+        this.url = settings.jdbcUrl();' change
has1 "$CO" '+    public OrderQueue(TiffinBoxProperties settings) {' change; has1 "$CO" '+        this.cooks = settings.cooks();' change
has1 "$CS" '+    TiffinBoxServer(CustomerRepository repo, Dashboard dashboard, OrderQueue kitchen, TiffinBoxProperties settings) {' change
has1 "$CS" '+        LOG.log(INFO, "meal types:     {0}", mealTypes);' change
[ "$(printf '%s\n' "$CA" | paste -sd'|' -)" = '+import com.tiffinbox.TiffinBoxProperties;|+import org.springframework.boot.context.properties.EnableConfigurationProperties;|+@EnableConfigurationProperties(TiffinBoxProperties.class)' ] \
  || die "change: TiffinBoxApp's code must gain the annotation and its two imports, nothing else"
for b in "$CD" "$CO" "$CS"; do [ "$(cnt "$b" '@Value')" = "$(cnt "$b" '^-.*@Value')" ] || die "change: a @Value line was added"; done
CP=$(blk change 'pom.xml (the root), every changed line' 'tiffinbox-core/pom.xml'); CC=$(blk change 'tiffinbox-core/pom.xml, every changed line' 'Database.java')
[ "$(cnt "$CP" '^\+')" = 8 ] && [ "$(cnt "$CP" '^-')" = 0 ] && has1 "$CP" '+            <annotationProcessorPaths>' change \
  && has1 "$CP" '+                <artifactId>spring-boot-configuration-processor</artifactId>' change && [ "$(cnt "$CP" '<version>')" = 0 ] \
  || die "change: the root pom.xml gains the processor path, eight code lines and no version"
[ "$(printf '%s\n' "$CC" | paste -sd'|' -)" = '+    <dependency>|+      <groupId>org.springframework.boot</groupId>|+      <artifactId>spring-boot</artifactId>|+    </dependency>' ] \
  || die "change: tiffinbox-core/pom.xml gains spring-boot, nothing else"
NEWREC=$(blk change 'the new file, whole: tiffinbox-core/src/main/java/com/tiffinbox/TiffinBoxProperties.java' '')
has1 "$NEWREC" ' 20 | @ConfigurationProperties("tiffinbox")' change
has1 "$NEWREC" ' 21 | public record TiffinBoxProperties(String jdbcUrl, int cooks, int days, int port, List<MealType> mealTypes) {' change
[ "$(cnt "$NEWREC" '^ +[0-9]+ \|  \* @param ')" = 5 ] || die "change: the record's Javadoc carries five @param lines"
x change '^  4 \| public enum MealType \{ VEG, NON_VEG, VEGAN \}$'
echo "  change: 2 files new (the record, MealType), 6 changed; @Value 4 (Database, OrderQueue, TiffinBoxServer) -> 0; the three constructors take the record"

# "a record ... one annotation naming the prefix, tiffinbox. It has one constructor, and Boot's binder ... fills the record
# through it: every key under tiffinbox, converted to each field's type, the list included" · "registers it as a bean, named
# the prefix, a dash, and the full class name. Build TiffinBox without that annotation, and it doesn't start: no bean of that
# type. Put it back, and it starts." · "Each class holds exactly the record's values"
RA=$(blk record 'A   ' 'B   '); RB=$(blk record 'B   ' 'A′  '); RA2=$(blk record 'A′  ' 'C   '); RC=$(blk record 'C   ' '')
has1 "$RA" 'exit 0 · WARN lines 0 · ERROR lines 0' record
has1 "$RA" 'beans of type TiffinBoxProperties: [tiffinbox-com.tiffinbox.TiffinBoxProperties]' record
has1 "$RA" "its constructors: 1 · its prefix: tiffinbox · Boot's binder fills it by: VALUE_OBJECT" record
has1 "$RA" 'the record: TiffinBoxProperties[jdbcUrl=jdbc:h2:mem:tiffinbox;DB_CLOSE_DELAY=-1, cooks=3, days=30, port=18681, mealTypes=[VEG, NON_VEG, VEGAN]]' record
has1 "$RA" 'the type of each item of its list: [com.tiffinbox.MealType, com.tiffinbox.MealType, com.tiffinbox.MealType]' record
has1 "$RA" "each one the record's own value: true" record
has1 "$RB" '  exit 1 · WARN lines 1 · ERROR lines 1 · listening lines 0' record
has1 "$RB" "  Parameter 0 of constructor in com.tiffinbox.Database required a bean of type 'com.tiffinbox.TiffinBoxProperties' that could not be found." record
[ "$RA" = "$RA2" ] || die "record: A' is not A, line for line"
has1 "$RC" 'the record: TiffinBoxProperties[jdbcUrl=jdbc:h2:mem:tiffinbox;DB_CLOSE_DELAY=-1, cooks=6, days=30, port=18681, mealTypes=[VEG, NON_VEG, VEGAN]]' record
[ "$(blk files 'noenable/TiffinBoxApp.java, against' 'processor/' | grep -c '^  < ')" = 3 ] && [ "$(blk files 'noenable/TiffinBoxApp.java, against' 'processor/' | grep -c '^  > ')" = 0 ] \
  || die "files: noenable/TiffinBoxApp.java must take out three lines and add none"
echo "  record: A one bean, tiffinbox-com.tiffinbox.TiffinBoxProperties, 1 constructor, VALUE_OBJECT, items MealType, readers = record · B (no annotation) exit 1, no bean · A' = A · C rush: cooks 6"

# "The list is finally read, in one line of TiffinBox's log" · "the last course's seven requests get the same answers: one hash"
[ "$(grep -c '^  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891$' .r-serve.out)" = 3 ] || die "serve: the seven responses must hash to 115c36ba..., all three runs"
x serve '^  TiffinBox.s log: meal types:     \[VEG, NON_VEG, VEGAN\]$'; x serve '^  route DEBUG lines 5$'; x serve '^  Boot: The following 1 profile is active: "rush"$'
x serve '^the logging flag after/README\.md gives, after the port: --logging\.level\.tiffinbox=debug$'
x serve '^the lunch-rush flag after/README\.md gives, after the port: --spring\.profiles\.active=rush$'
echo "  serve: the seven responses 115c36ba... (plain, logging, rush); the list's log line [VEG, NON_VEG, VEGAN]"

# "Add it as an optional dependency: build success, zero warnings, and no file" · "Name it on the compiler's processor path
# instead, in TiffinBox's root build file, and the file appears. Back to the dependency: none again" · "Switch processing on with
# one flag, and the same file appears"
PA=$(blk processor 'A   ' 'B   '); PB=$(blk processor 'B   ' 'A′  '); PA2=$(blk processor 'A′  ' 'C   '); PC=$(blk processor 'C   ' 'D   '); PD=$(blk processor 'D   ' 'E   ')
PE=$(blk processor 'E   ' '')
OKB='  exit 0 · BUILD SUCCESS · WARNING lines 0 · ERROR lines 0'
for b in "$PA" "$PB" "$PC" "$PD" "$PE"; do has1 "$b" "$OKB" processor; done
has1 "$PA" "  metadata files under the two modules' target/: 0" processor
has1 "$PB" "  metadata files under the two modules' target/: 1 · tiffinbox-core/target/classes/META-INF/spring-configuration-metadata.json" processor
[ "$PA" = "$PA2" ] || die "processor: A' is not A, line for line"
has1 "$PC" "  metadata files under the two modules' target/: 1 · tiffinbox-core/target/classes/META-INF/spring-configuration-metadata.json" processor
has1 "$PC" "  the same bytes as B's file: yes" processor
has1 "$PD" "  metadata files under the two modules' target/: 0" processor
# "as an optional dependency" (A: lib/ 26, the processor not in it) · the recap's "added as a dependency writes nothing": E,
# the same dependency without <optional>, writes nothing either - and puts the processor in lib/ and the manifest
has1 "$PA" "  lib/: 26 jars · the processor among them: 0 · named in the manifest's Class-Path: 0" processor
has1 "$PE" "  metadata files under the two modules' target/: 0" processor
has1 "$PE" "  lib/: 27 jars · the processor among them: 1 · named in the manifest's Class-Path: 1" processor
[ "$(blk files 'processor/plain/tiffinbox-core/pom.xml, against' 'processor/full/' | grep -c '^  < .*<optional>true</optional>')" = 1 ] \
  && [ "$(blk files 'processor/plain/tiffinbox-core/pom.xml, against' 'processor/full/' | grep '^  [<>] ' | grep -vc '<!--')" = 1 ] \
  || die "files: processor/plain/tiffinbox-core/pom.xml must drop <optional> (and reword its comment), nothing else"
x files '^processor/dependency/pom\.xml: the previous tree.s pom\.xml \(the root\), byte for byte$'
FULL=$(blk files 'processor/full/pom.xml, against' 'processor/web/')
[ "$(printf '%s\n' "$FULL" | grep '^  > ' | grep -vc '^  > *<!--' || true)" = 3 ] && has1 "$FULL" '  >             <proc>full</proc>' files \
  && [ "$(printf '%s\n' "$FULL" | grep -c '^  < ' || true)" = 0 ] || die "files: processor/full/pom.xml must add <proc>full</proc> (in a <configuration>) and nothing else"
echo "  processor: A (a dependency) BUILD SUCCESS, 0 WARNING, 0 files · B (processor path) 1 file · A' = A · C (+ proc full) 1 file, B's bytes · D (web only) 0"
echo "             E (no <optional>) 0 files, lib/ 27 with the processor, against A's 26"

# "One group, five properties, each described by the record's own comments. And every whole number gets a default value: zero"
x metadata '^its sections: groups 1 · properties 5 · hints 0 · ignored properties 0$'
x metadata '^the record.s @param lines: 5 · descriptions that are one of them, word for word, for the same component: 5 of 5$'
x metadata '^the record.s int components: \[cooks, days, port\] · given "defaultValue": 0 in the file: 3 of 3$'
x metadata '^no META-INF/spring-configuration-metadata\.json in tiffinbox-core-1\.0\.0\.jar$'
# the chip: the same file name ships in Boot's own jars, 3 of 26 in lib/
x metadata '^the jars in after/.s lib/ that carry a META-INF/spring-configuration-metadata\.json: 3 of 26 · spring-boot-4\.1\.1\.jar spring-boot-autoconfigure-4\.1\.1\.jar tiffinbox-core-1\.0\.0\.jar$'
echo "  metadata: 1 group, 5 properties, 5 of 5 descriptions the @param text, 3 of 3 ints default 0; the previous tree's jar: no file; 3 of 26 jars carry one"

# "Here the list says veg, non dash veg, and Vegan with a trailing space. The record gets the three constants, and a Value
# placeholder gets non veg too. TiffinBox declares no converter." · "A word it can't match, vegetarian, stops the start, and
# the report lists the valid values. Back to the loose spellings: it starts."
x lenient '^converters TiffinBox declares, in after/: 0 classes implement Converter, ConverterFactory or GenericConverter$'
LA=$(blk lenient 'A   ' 'B   '); LB=$(blk lenient 'B   ' 'A′  '); LA2=$(blk lenient 'A′  ' '')
has1 "$LA" 'exit 0 · WARN lines 0 · ERROR lines 0' lenient
has1 "$LA" '  line  9 |     - veg       ->  tiffinbox.meal-types[0] = "veg"' lenient
has1 "$LA" '  line 10 |     - non-veg   ->  tiffinbox.meal-types[1] = "non-veg"' lenient
has1 "$LA" '  line 11 |     - "Vegan "  ->  tiffinbox.meal-types[2] = "Vegan "' lenient
has1 "$LA" "the record's list: [VEG, NON_VEG, VEGAN] · the type of each item: [com.tiffinbox.MealType]" lenient
has1 "$LA" '@Value("${tiffinbox.favourite}") MealType favourite = NON_VEG' lenient
has1 "$LB" '  exit 1 · WARN lines 1 · ERROR lines 1 · listening lines 0' lenient
has1 "$LB" '      Value: "vegetarian"' lenient
has1 "$LB" "  Update your application's configuration. The following values are valid:" lenient
[ "$(printf '%s\n' "$LB" | grep -A3 'The following values are valid:' | tail -3 | paste -sd'|' -)" = '      NON_VEG|      VEG|      VEGAN' ] || die "lenient: B's report must list the three valid values"
[ "$LA" = "$LA2" ] || die "lenient: A' is not A, line for line"
[ "$(blk files 'vegetarian/application.yaml, against' 'noenable/' | paste -sd'|' -)" = '  11c11|  <     - "Vegan "|  ---|  >     - vegetarian' ] || die "files: vegetarian/ must change the third item alone"
echo "  lenient: A veg / non-veg / \"Vegan \" -> [VEG, NON_VEG, VEGAN], @Value non-veg -> NON_VEG, 0 converters · B vegetarian exit 1, NON_VEG VEG VEGAN listed · A' = A"

# "The context's conversion service, the same Spring mechanism ... is Boot's own subclass here. It holds one more converter,
# Boot's lenient one, and asks it before Spring's. A plain Spring context on the same class path still fails: no matching
# conversion strategy."
x convert '^  the context.s conversion service: org\.springframework\.boot\.convert\.ApplicationConversionService \(spring-boot-4\.1\.1\.jar\)$'
x convert '^  a Spring Framework org\.springframework\.core\.convert\.support\.GenericConversionService: true$'
x convert '^  its converters for String -> Enum, in the order it asks them: org\.springframework\.boot\.convert\.LenientStringToEnumConverterFactory \(spring-boot-4\.1\.1\.jar\) · org\.springframework\.core\.convert\.support\.StringToEnumConverterFactory \(spring-core-7\.0\.9\.jar\)$'
x convert '^  "non-veg" -> MealType, through it: NON_VEG$'
x convert '^  the context.s conversion service: null$'
x convert "^  its last cause: java\.lang\.IllegalStateException: Cannot convert value of type ${Q}java\.lang\.String${Q} to required type ${Q}com\.tiffinbox\.MealType${Q}: no matching editors or conversion strategy found$"
x convert '^the WARN line: s\.c\.a\.AnnotationConfigApplicationContext : Exception encountered during context initialization - cancelling refresh attempt$'
[ "$(grep -c '^the WARN line: ' .r-convert.out)" = 1 ] && x convert '^exit 0 · WARN lines 1 · ERROR lines 0$' || die "convert: the run's one WARN line is the plain context's"
echo "  convert: Boot's ApplicationConversionService (a GenericConversionService) asks Boot's lenient converter first; non-veg -> NON_VEG; plain Spring: no conversion service, no matching conversion strategy"

# "one auto-configuration ... declares that bean. So a typo with no default is loud: exit one" · "Exclude that
# one auto-configuration, and the same typo starts cleanly, with the placeholder's own text injected ... Put it back: exit one."
x placeholder '^PropertySourcesPlaceholderConfigurer beans: \[propertySourcesPlaceholderConfigurer\] · propertySourcesPlaceholderConfigurer is declared by org\.springframework\.boot\.autoconfigure\.context\.PropertyPlaceholderAutoConfiguration\.propertySourcesPlaceholderConfigurer\(\)$'
HA=$(blk placeholder 'A   ' 'B   '); HB=$(blk placeholder 'B   ' 'A′  '); HA2=$(blk placeholder 'A′  ' 'C   '); HC=$(blk placeholder 'C   ' '')
has1 "$HA" '  exit 1 · WARN lines 1 · ERROR lines 1 · listening lines 0' placeholder
has1 "$HA" "  Caused by: org.springframework.util.PlaceholderResolutionException: Could not resolve placeholder 'tiffinbox.mael' in value \"\${tiffinbox.mael}\"" placeholder
has1 "$HB" '  exit 0 · WARN lines 0 · ERROR lines 0 · listening lines 1' placeholder
has1 "$HB" '  @Value("${tiffinbox.mael}") String mael = ${tiffinbox.mael}' placeholder
has1 "$HB" '  PropertySourcesPlaceholderConfigurer beans: []' placeholder
[ "$HA" = "$HA2" ] || die "placeholder: A' is not A, line for line"
# "So a typo with no default is loud" - C: the same typo WITH a default starts, on the default, and nothing warns
has1 "$HC" '  exit 0 · WARN lines 0 · ERROR lines 0 · listening lines 1' placeholder
has1 "$HC" '  @Value("${tiffinbox.mael:VEG}") String mael = VEG' placeholder
echo "  placeholder: one bean, declared by PropertyPlaceholderAutoConfiguration · A typo exit 1 · B that one excluded: exit 0, the text injected, no bean · A' = A · C a default: exit 0, VEG"

# "A: every key, one hundred and twenty orders cooked. B: I deleted the days line ... It starts, no warning. The record says
# zero days, zero orders cooked, and the kitchen answers zero. The hash changes. A again: one hundred and twenty." · "The
# previous version, with Value, refuses to start without that key, and names it."
BA=$(blk break 'A   ' 'B   '); BB=$(blk break 'B   ' 'A′  '); BA2=$(blk break 'A′  ' 'C   '); BC=$(blk break 'C   ' 'D   ')
BD=$(blk break 'D   ' 'E   '); BE=$(blk break 'E   ' '')
has1 "$BA" "  TiffinBox's log: orders cooked:  120" break
has1 "$BA" '  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891' break
has1 "$BB" '  listens on: 127.0.0.1:18685 · WARN lines 0 · ERROR lines 0' break
has1 "$BB" '  the record: TiffinBoxProperties[jdbcUrl=jdbc:h2:mem:tiffinbox;DB_CLOSE_DELAY=-1, cooks=3, days=0, port=18685, mealTypes=[VEG, NON_VEG, VEGAN]]' break
has1 "$BA" '  the record: TiffinBoxProperties[jdbcUrl=jdbc:h2:mem:tiffinbox;DB_CLOSE_DELAY=-1, cooks=3, days=30, port=18685, mealTypes=[VEG, NON_VEG, VEGAN]]' break
has1 "$BA" '  GET   /kitchen    -> 200 application/json  {"ordersCooked":120,"ordersValue":24300}' break
has1 "$BB" "  TiffinBox's log: orders cooked:  0" break
has1 "$BB" '  GET   /kitchen    -> 200 application/json  {"ordersCooked":0,"ordersValue":0}' break
has1 "$BB" '  exit 0 · the seven responses: 7 lines · md5 48c20805358e969bfc65e9197ce3b541' break
[ "$BA" = "$BA2" ] || die "break: A' is not A, line for line"
has1 "$BC" '  exit 1 · WARN lines 1 · ERROR lines 1 · listening lines 0' break
has1 "$BC" "  Caused by: org.springframework.util.PlaceholderResolutionException: Could not resolve placeholder 'tiffinbox.days' in value \"\${tiffinbox.days}\"" break
[ "$(blk files 'nodays/application.yaml, against' 'nourl/' | paste -sd'|' -)" = '  5d4|  <   days: 30' ] || die "files: nodays/ must delete the days line alone"
# the recap: "a missing number becomes zero, not an error; missing text or a list, null" - D: the url is null, and the
# database driver refuses it (exit 1) · E: the list is null, and TiffinBox starts
has1 "$BD" '  exit 1 · WARN lines 1 · ERROR lines 1 · listening lines 0' break
has1 "$BD" '  "Caused by:" lines 3 · the last, the root cause: java.sql.SQLException: The url cannot be null' break
has1 "$BE" '  listens on: 127.0.0.1:18685 · WARN lines 0 · ERROR lines 0' break
has1 "$BE" '  the record: TiffinBoxProperties[jdbcUrl=jdbc:h2:mem:tiffinbox;DB_CLOSE_DELAY=-1, cooks=3, days=30, port=18685, mealTypes=null]' break
[ "$(blk files 'nourl/application.yaml, against' 'nomeals/' | paste -sd'|' -)" = '  3d2|  <   jdbc-url: jdbc:h2:mem:tiffinbox;DB_CLOSE_DELAY=-1' ] || die "files: nourl/ must delete the jdbc-url line alone"
[ "$(blk files 'nomeals/application.yaml, against' 'lenient/' | paste -sd'|' -)" = '  8,11d7|  <   meal-types:|  <     - VEG|  <     - NON_VEG|  <     - VEGAN' ] \
  || die "files: nomeals/ must delete the meal-types list alone"
x metadata '^  tiffinbox\.days +java\.lang\.Integer +default 0 '
echo "  break: A 120 cooked, 115c36ba... · B (days deleted) exit 0, 0 WARN, days=0, 0 cooked, /kitchen zeros, 48c20805... · A' = A · C (@Value) exit 1 naming tiffinbox.days"
echo "         D (jdbc-url deleted) exit 1, root cause: The url cannot be null · E (meal-types deleted) starts, 0 WARN, mealTypes=null"
[ -z "$unpub" ] || die "no published hash for:$unpub - check the captures, then copy the md5s above into receipts.md5 and run again"
echo "c5-unit08: every capture 3/3 and = published; every spoken number asserted"
