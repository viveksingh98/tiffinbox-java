#!/bin/bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25.0.4.1 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# Course 5 · Validating Configuration — this unit's receipts. The previous tree bound TiffinBox's settings into one record
# and turned a missing key into a zero. This unit makes the configuration refuse to start instead: the validation starter
# in tiffinbox-web, the constraint annotations' API in tiffinbox-core, constraints and @Validated on the record, and Integer
# for its three numbers (the anchor change). Then when that refusal gets its turn, and what "you get it free" means for
# method validation under Boot. Ten captures, each run three times and hashed; cap() DIES when a hash differs from
# receipts.md5; every number the video says is asserted at the bottom by a check that can fail.
#   change      the previous tree against after/, file by file: every changed code line, the record whole, the readers
#               that take it, the metadata file's zero defaults
#   imports     after/'s lib/ against the previous tree's: the new jars, and the jars that carry an imports file
#   unvalidated the previous tree's jar, as its README runs it: zero cooks, then minus one
#   break       cooks: 0 in a file: A this tree · B this tree minus @Validated (novalidated/) · A' = A · C the previous tree
#               (no validation at all)
#   starter     A this tree, a good file · B the starter taken out (the API alone) · A' = A · C the API taken out too (build)
#               · D the starter taken out AND @Validated: what asks for a validator
#   order       four bad values in one file: A this tree · B Database back on a @Value placeholder · A' = A - then A's
#               command six more times, unsorted: does Boot's own order of the blocks change from run to run?
#   boxed       the days line deleted: A this tree (Integer, @NotNull) · B the record with int, no @NotNull · A' = A ·
#               C this tree minus @Validated: where the null goes
#   method      method validation: A this tree · B the previous tree (no starter) · A' = A · C the harness without -parameters
#   serve       this tree's jar: the seven responses and the list's log line; the logging flag and the lunch-rush flag
#               after/README.md gives (each read from the file, not typed here)
#   files       every demo file against the file it stands in for (diff)
# "before" is ../c5-unit08/after (the anchor as the last unit left it), COPIED to .harness/before and built there: this
# script never writes into another unit's folder. after/ is this unit's frozen copy of ../c5-tiffinbox after the change.
# Every build is a clean one, run in a copy under .harness/ (after/ itself is built in place, as the tree the others copy).
# Commands are printed exactly as they run: each goes through eval, so "$BEFORE" / "$AFTER" / "$ATVALUE" / "$INTRECORD" /
# "$NOSTARTER" / "$NOPARAMS" / "$NOVALID" / "$NOSTARTER_NOVALID" (the harness's classes plus that tree's jars, written to
# .harness/*.classpath) and "$M2" (this unit's own repository, .m2-demo) expand when it runs. A folder in front of a tree on a class path (cooks0/, nodays/,
# fourbad/) holds one application.yaml that the class path then gives instead of the jar's own; `files` shows how each
# differs from the anchor's.
# Masks and filters (README.md declares each; sub/gsub only): Boot's timestamped log lines are dropped and counted, and so
# are the lines before a harness report (the banner); a kept log message loses its prefix through sub(); a failure report
# is shown without its blank lines and its rows of asterisks, the rest counted, and a report with more than one Property:
# block has its blocks sorted by name (brief ⚑7); SpringCGLIB$$<digits> becomes SpringCGLIB$$<n> and a compiler error's
# absolute path becomes …/ (gsub); the builds are reduced to counts.
# Ports (brief ⚑11, 18690-18699): serve 18690 · unvalidated 18691 · break 18692 (A never binds) · starter 18693 (B never
# binds) · order 18694 (never binds) · boxed 18695 (never binds) · method 18696 · the exercise 18699.
set -e
cd "$(dirname "$0")"
# One run at a time: two runs share .harness/ and the ports, and one would corrupt the other.
mkdir .r-lock 2> /dev/null || { echo "  *** another receipts.sh is running in this folder (.r-lock exists) - if none is, rmdir .r-lock ***"; exit 1; }
# On every exit - the end, a failed check, or Ctrl-C - stop the JVM this script started in the background, if it still
# runs, and drop the lock. A background job of a non-interactive shell ignores the terminal's Ctrl-C, so without the kill
# an interrupted run would leave TiffinBox listening. $pid is cleared whenever the JVM has been reaped. The clean-up
# ignores a second Ctrl-C, and nothing in it can fail under set -e (a JVM stopped by SIGTERM exits 143), so it always
# reaches the rmdir; the script still exits 130 after an interrupt (tested: README.md, "Interrupted").
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
DB=tiffinbox-core/src/main/java/com/tiffinbox/Database.java
YAML=tiffinbox-web/src/main/resources/application.yaml
WEBPOM=tiffinbox-web/pom.xml; COREPOM=tiffinbox-core/pom.xml

# ---- build: the previous tree (copied), after/, and three variants of after/ (copied), all clean -------------------------
rm -rf .harness; mkdir -p .harness
rsync -a --exclude target ../c5-unit08/after/ .harness/before/
variant() { rm -rf ".harness/$1"; rsync -a --exclude target after/ ".harness/$1/"; }
variant atvalue; cp atvalue/Database.java ".harness/atvalue/$DB"
variant intrecord; cp intrecord/TiffinBoxProperties.java ".harness/intrecord/$REC"
variant nostarter; cp nostarter/$WEBPOM ".harness/nostarter/$WEBPOM"
variant novalid; cp novalidated/TiffinBoxProperties.java ".harness/novalid/$REC"
variant nostarter-novalid; cp nostarter/$WEBPOM ".harness/nostarter-novalid/$WEBPOM"; cp novalidated/TiffinBoxProperties.java ".harness/nostarter-novalid/$REC"
BT=.harness/before; AT=after
# build DIR: a clean build, offline first; Maven Central only if the offline build fails - and the terminal says which
# (offline: yes / no), so a run that went online is never silent.
build() { local how=yes
  (cd "$1" && mvn -o -q -B -Dmaven.repo.local="$M2" -DskipTests clean package > /dev/null 2>&1) \
    || { how="no - the offline build failed, so Maven Central was asked"
         (cd "$1" && mvn -q -B -Dmaven.repo.local="$M2" -DskipTests clean package) || die "build failed: $1"; }
  echo "  built $1 · offline: $how"; }
build "$BT"; build "$AT"; build .harness/atvalue; build .harness/intrecord; build .harness/nostarter; build .harness/novalid
build .harness/nostarter-novalid
jars() { echo "$PWD/$1/tiffinbox-web/target/tiffinbox-web-1.0.0.jar:$(ls "$PWD/$1"/tiffinbox-web/target/lib/*.jar | paste -sd: -)"; }
# The harness is compiled twice from the same sources: with -parameters, as Boot's parent compiles TiffinBox (method), and
# without it (method C).
javac -parameters -cp "$(jars "$AT")" -d .harness/classes harness/com/tiffinbox/harness/*.java || die "the harness did not compile"
javac -cp "$(jars "$AT")" -d .harness/noparams harness/com/tiffinbox/harness/*.java || die "the harness did not compile (no -parameters)"
BEFORE="$PWD/.harness/classes:$(jars "$BT")"; AFTER="$PWD/.harness/classes:$(jars "$AT")"
ATVALUE="$PWD/.harness/classes:$(jars .harness/atvalue)"; INTRECORD="$PWD/.harness/classes:$(jars .harness/intrecord)"
NOSTARTER="$PWD/.harness/classes:$(jars .harness/nostarter)"; NOPARAMS="$PWD/.harness/noparams:$(jars "$AT")"
NOVALID="$PWD/.harness/classes:$(jars .harness/novalid)"; NOSTARTER_NOVALID="$PWD/.harness/classes:$(jars .harness/nostarter-novalid)"
for v in BEFORE AFTER ATVALUE INTRECORD NOSTARTER NOPARAMS NOVALID NOSTARTER_NOVALID; do
  eval "printf '%s\n' \"\$$v\"" > ".harness/$(echo $v | tr 'A-Z' 'a-z').classpath"; done

listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
for p in 18425 18690 18691 18692 18693 18694 18695 18696; do
  [ "$(listeners $p)" = 0 ] || die "something already listens on $p - this unit's ports must be free; if it is a TiffinBox an interrupted run left behind, stop it: curl -X POST http://127.0.0.1:$p/shutdown"; done

# runh 'COMMAND': print it exactly as typed, run it (eval, in a subshell, from this folder), keep its exit code in $ec.
runh() { echo "\$ $1"; ec=0; (eval "$1") > .harness/run.raw 2>&1 < /dev/null || ec=$?; }
# report START: the harness's own lines, from the first that starts with START. Boot's timestamped log lines are dropped
# everywhere, and the other lines before the report (the banner) too - both counted on one last line. SpringCGLIB$$<digits>
# is masked to SpringCGLIB$$<n> (gsub).
report() { awk -v start="$1" '
  /^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T[0-9][0-9]:/ { n++; next }
  !f && index($0, start) == 1 { f = 1 }
  f { gsub(/\$\$SpringCGLIB\$\$[0-9]+/, "$$SpringCGLIB$$<n>"); print; next }
  { m++ }
  END { printf "… elided: %d log line(s) of Boot'"'"'s, and %d line(s) printed before the report (the banner and its blank lines) …\n", n, m }' .harness/run.raw; }
warns() { echo "WARN lines $(grep -c ' WARN ' "$1" || true) · ERROR lines $(grep -c ' ERROR ' "$1" || true)"; }
run() { runh "$1"; echo "exit $ec · $(warns .harness/run.raw)"; report "$2"; }
# said FILE MESSAGE: TiffinBox's (or Boot's) own INFO line that starts with MESSAGE, its prefix (time, level, pid, thread,
# logger) cut by sub() - or "(no such line)"
said() { awk -v m="$2" '{ s = $0; sub(/^[0-9][0-9][0-9][0-9]-[^ ]* +[A-Z]+ [0-9]+ --- \[[^]]*\] [^:]* : /, "", s) } index(s, m) == 1 { print s; f = 1; exit } END { if (!f) print "(no such line)" }' "$1"; }
# sortblocks: a failure report's "Property:" blocks (Property, Value, Origin, Reason), sorted by the Property line when there
# are two or more - Boot's order varies between runs (brief ⚑7) - with one line that says so; every other line as it is.
sortblocks() { awk '
  function flush(  i, j, tk, tb) {
    if (nb > 1) { for (i = 2; i <= nb; i++) { tk = key[i]; tb = blk[i]; j = i - 1
                    while (j > 0 && key[j] > tk) { key[j + 1] = key[j]; blk[j + 1] = blk[j]; j-- } key[j + 1] = tk; blk[j + 1] = tb }
                  print "  (the " nb " Property: blocks below are sorted by name - README.md, masks)" }
    for (i = 1; i <= nb; i++) printf "%s", blk[i]
    nb = 0 }
  /^      Property: / { nb++; key[nb] = $0; blk[nb] = $0 "\n"; inb = 1; next }
  inb && /^      (Value|Origin|Reason): / { blk[nb] = blk[nb] $0 "\n"; next }
  { inb = 0; flush(); print }
  END { flush() }'; }
# a failed start: how far it got (exit, WARN/ERROR lines, TiffinBox's listening line, and the Property:, SQLException and
# stack-frame lines counted), the file the class path gave, then Boot's own failure report without its blank lines and its
# rows of asterisks (or, when there is none, the LAST TWO "Caused by:" lines - the root cause and the bean it broke - with a
# [jar:file:…] or [file:…] location cut to […] by gsub), then the exception the harness names (a harness run only), and the
# count of the run's lines not shown
failed() { local shown
  echo "  exit $ec · $(warns .harness/run.raw) · listening lines $(grep -c 'TiffinBox listening on' .harness/run.raw || true)"
  echo "  Property: lines $(grep -c '^    Property: ' .harness/run.raw || true) · SQLException lines $(grep -c 'SQLException' .harness/run.raw || true) · stack-frame lines $(grep -cE '^[[:space:]]+at ' .harness/run.raw || true)"
  grep -m1 '^the class path gives: ' .harness/run.raw | sed 's/^/  /' > .harness/fail.txt || true
  if grep -q '^APPLICATION FAILED TO START$' .harness/run.raw; then
    awk '/^APPLICATION FAILED TO START$/ { f = 1 } /^the exception TiffinBox.s main threw: / { f = 0 } f && !/^[*]+$/ && !/^[[:space:]]*$/ { print "  " $0 }' .harness/run.raw | sortblocks >> .harness/fail.txt
  else grep '^Caused by: ' .harness/run.raw | tail -2 | awk '{ gsub(/\[jar:file:[^]]*\]/, "[…]"); gsub(/\[file:[^]]*\]/, "[…]"); print "  " $0 }' >> .harness/fail.txt
    grep -q '^  Caused by: ' .harness/fail.txt || echo "  (no Caused by: line)" >> .harness/fail.txt; fi
  cat .harness/fail.txt
  grep -m1 "^the exception TiffinBox's main threw: " .harness/run.raw | sed 's/^/  /' || true
  shown=$(( $(grep -cv '^  (the [0-9]* Property: blocks below are sorted by name' .harness/fail.txt) + $(grep -c "^the exception TiffinBox's main threw: " .harness/run.raw || true) ))
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
# served DIR 'COMMAND': start it from DIR; if it listens, the harness's lines, TiffinBox's orders-cooked line, the /kitchen
# response and the seven responses; if it exits, how far it got and why (failed)
served() { local l
  startjar "$1" "$2"; l=$(listening)
  if [ "$l" = nothing ]; then ec=0; wait "$pid" || ec=$?; pid=""; cp .harness/jar.log .harness/run.raw; failed
  else seven "${l##*:}" > .harness/seven.txt
    echo "  listens on: $l · $(warns .harness/jar.log)"
    grep -E '^the (record|class path gives)' .harness/jar.log | sed 's/^/  /' || true
    echo "  TiffinBox's log: $(said .harness/jar.log 'orders cooked:')"
    echo "  $(grep ' /kitchen ' .harness/responses.txt)"; cat .harness/seven.txt; fi; }

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
values() { grep -rhoE --include='*.java' '@Value\("\$\{tiffinbox\.' "$1" | wc -l | tr -d ' '; }
# takers TREE: the classes whose constructor takes the record, each as module/File.java - so "two of them live in core" is read
takers() { local f x; f=$(grep -rlE --include='*.java' 'TiffinBoxProperties settings\)' "$1" | sort)
  echo "$(echo "$f" | grep -c . || true):$(for x in $f; do x=${x#$1/}; printf ' %s' "${x%%/*}/${x##*/}"; done)"; }
zeros() { unzip -p "$1/tiffinbox-web/target/lib/tiffinbox-core-1.0.0.jar" META-INF/spring-configuration-metadata.json | grep -c '"defaultValue": 0' || true; }
change() { local a b n=0 same=0 changed="" gone="" new="" f all cod
  a=$(cd "$BT" && find . -type f -not -path '*/target/*' -not -name README.md | sed 's|^\./||' | sort)
  b=$(cd "$AT" && find . -type f -not -path '*/target/*' -not -name README.md | sed 's|^\./||' | sort)
  for f in $a; do if [ -f "$AT/$f" ]; then n=$((n + 1)); if cmp -s "$BT/$f" "$AT/$f"; then same=$((same + 1)); else changed="$changed $f"; fi; else gone="$gone $f"; fi; done
  for f in $b; do [ -f "$BT/$f" ] || new="$new $f"; done
  echo "files, README aside: the previous tree $(echo "$a" | wc -l | tr -d ' ') · after/ $(echo "$b" | wc -l | tr -d ' ') · in both $n: identical $same, changed $(echo $changed | wc -w | tr -d ' ')"
  echo "  only before:${gone:- (none)}"; echo "  only after: ${new:- (none)}"
  mkdir -p .harness/code
  for f in $changed; do
    code "$BT/$f" > .harness/code/b; code "$AT/$f" > .harness/code/a
    all=$(pm "$BT/$f" "$AT/$f" | grep -c . || true); cod=$(pm .harness/code/b .harness/code/a)
    echo "$(short "$f"), every changed line but comments and blanks ($(( all - $(echo "$cod" | grep -c . || true) )) of those not shown):"
    echo "${cod:-  (none)}"; done
  echo "the record, whole, after/: $REC"; awk '{ printf "%3d | %s\n", NR, $0 }' "$AT/$REC"
  echo "TiffinBox's @Value placeholders: the previous tree $(values "$BT") · after/ $(values "$AT")"
  echo "classes whose constructor takes the record (TiffinBoxProperties settings): the previous tree $(takers "$BT") · after/ $(takers "$AT")"
  echo "\"defaultValue\": 0 entries in the core jar's metadata file: the previous tree $(zeros "$BT") · after/ $(zeros "$AT")"; }
cap change change

# ---- imports: after/'s lib/ against the previous tree's ---------------------------------------------------------------------
IMP=META-INF/spring/org.springframework.boot.autoconfigure.AutoConfiguration.imports
lib() { ls "$1/tiffinbox-web/target/lib"; }
withimp() { local j; for j in "$1"/tiffinbox-web/target/lib/*.jar; do unzip -l "$j" "$IMP" > /dev/null 2>&1 && echo "${j##*/}"; done; true; }
imports() { local nb na
  nb=$(lib "$BT" | wc -l | tr -d ' '); na=$(lib "$AT" | wc -l | tr -d ' ')
  echo "jars in tiffinbox-web/target/lib: the previous tree $nb · after/ $na"
  echo "  new in after/: $(comm -13 <(lib "$BT") <(lib "$AT") | paste -sd' ' -)"
  echo "  gone from after/: $(comm -23 <(lib "$BT") <(lib "$AT") | paste -sd' ' - | grep . || echo '(none)')"
  echo "jars in lib/ that carry $IMP:"
  echo "  the previous tree $(withimp "$BT" | wc -l | tr -d ' '): $(withimp "$BT" | paste -sd' ' -)"
  echo "  after/ $(withimp "$AT" | wc -l | tr -d ' '): $(withimp "$AT" | paste -sd' ' -)"
  echo "\$ unzip -p after/tiffinbox-web/target/lib/spring-boot-validation-4.1.1.jar $IMP"
  unzip -p "$AT/tiffinbox-web/target/lib/spring-boot-validation-4.1.1.jar" "$IMP" | grep -v '^[[:space:]]*$' | awk '{ printf "%3d | %s\n", NR, $0 }'
  echo "the starter's own jar, spring-boot-starter-validation-4.1.1.jar: .class entries $(unzip -l "$AT/tiffinbox-web/target/lib/spring-boot-starter-validation-4.1.1.jar" | grep -c '\.class$' || true)"; }
cap imports imports

# ---- unvalidated: the previous tree's jar, in .harness/before/tiffinbox-web/target ----------------------------------------
unvalidated() { local T="$BT/tiffinbox-web/target"
  echo "the previous tree's jar (no validation), zero cooks from the command line:"
  served "$T" 'java -jar tiffinbox-web-1.0.0.jar --tiffinbox.port=18691 --tiffinbox.cooks=0'
  echo "the same jar, minus one cook:"
  served "$T" 'java -jar tiffinbox-web-1.0.0.jar --tiffinbox.port=18691 --tiffinbox.cooks=-1'
  echo "  lines that name the key (cooks, in any case): $(grep -ci 'cooks' .harness/run.raw || true) · NullPointerException lines: $(grep -c 'NullPointerException' .harness/run.raw || true) · output lines in all: $(wc -l < .harness/run.raw | tr -d ' ')"; }
cap unvalidated unvalidated

# ---- break: cooks: 0 in a file ------------------------------------------------------------------------------------------------
brk() {
  echo "A   this tree, cooks0/ in front of its jar's file"; served . 'java -cp "cooks0:$AFTER" com.tiffinbox.harness.Serve --tiffinbox.port=18692'
  echo "B   novalidated/: this tree minus @Validated - every constraint kept - the same cooks0/ file"; served . 'java -cp "cooks0:$NOVALID" com.tiffinbox.harness.Serve --tiffinbox.port=18692'
  echo "A′  A, re-run"; served . 'java -cp "cooks0:$AFTER" com.tiffinbox.harness.Serve --tiffinbox.port=18692'
  echo "C   the previous tree (no starter, no constraints, no @Validated), the same cooks0/ file"; served . 'java -cp "cooks0:$BEFORE" com.tiffinbox.harness.Serve --tiffinbox.port=18692'; }
cap break brk

# ---- starter: the starter taken out, then the API too ----------------------------------------------------------------------
# mvncount DIR: a clean offline build of a copy, reduced to counts, and the compiler's first error with its path cut (gsub)
mvncount() { local d="$1"
  echo "\$ cd $d && mvn -o -B -Dmaven.repo.local=\"\$M2\" -DskipTests clean package"
  ec=0; (cd "$d" && mvn -o -B -Dmaven.repo.local="$M2" -DskipTests clean package) > .harness/mvn.log 2>&1 < /dev/null || ec=$?
  echo "  exit $ec · $(grep -m1 -oE 'BUILD (SUCCESS|FAILURE)' .harness/mvn.log || echo 'no BUILD line') · WARNING lines $(grep -c '^\[WARNING\]' .harness/mvn.log || true) · ERROR lines $(grep -c '^\[ERROR\]' .harness/mvn.log || true)"
  echo "  the compiler's error lines ([ERROR] …java:[line,column] …): $(grep -cE '^\[ERROR\] /.*\.java:\[[0-9]+,[0-9]+\] ' .harness/mvn.log || true) · in: $(grep -oE '^\[ERROR\] /.*\.java:\[' .harness/mvn.log | sed 's|.*/||; s|:\[$||' | sort -u | paste -sd' ' -)"
  grep -m1 -E '^\[ERROR\] /.*\.java:\[[0-9]+,[0-9]+\] ' .harness/mvn.log | awk '{ gsub(/\/.*\/tiffinbox-core\//, "…/tiffinbox-core/"); print "  the first: " $0 }'; }
starter() {
  echo "A   this tree, its own file"; served . 'java -cp "$AFTER" com.tiffinbox.harness.Serve --tiffinbox.port=18693'
  echo "B   the starter taken out: nostarter/tiffinbox-web/pom.xml (the API jar still comes from tiffinbox-core), its own file"
  echo "  lib/: $(lib .harness/nostarter | wc -l | tr -d ' ') jars · jakarta.validation-api among them: $(lib .harness/nostarter | grep -c '^jakarta.validation-api' || true) · hibernate-validator among them: $(lib .harness/nostarter | grep -c '^hibernate-validator' || true)"
  served . 'java -cp "$NOSTARTER" com.tiffinbox.harness.Serve --tiffinbox.port=18693'
  echo "A′  A, re-run"; served . 'java -cp "$AFTER" com.tiffinbox.harness.Serve --tiffinbox.port=18693'
  echo "C   the API taken out too: this tree with nostarter/tiffinbox-web/pom.xml and noapi/tiffinbox-core/pom.xml, built"
  variant noapi; cp nostarter/$WEBPOM ".harness/noapi/$WEBPOM"; cp noapi/$COREPOM ".harness/noapi/$COREPOM"; mvncount .harness/noapi
  echo "D   the starter taken out AND @Validated: nostarter/tiffinbox-web/pom.xml and novalidated/, its own file"
  echo "  lib/: $(lib .harness/nostarter-novalid | wc -l | tr -d ' ') jars · jakarta.validation-api among them: $(lib .harness/nostarter-novalid | grep -c '^jakarta.validation-api' || true) · hibernate-validator among them: $(lib .harness/nostarter-novalid | grep -c '^hibernate-validator' || true)"
  served . 'java -cp "$NOSTARTER_NOVALID" com.tiffinbox.harness.Serve --tiffinbox.port=18693'; }
cap starter starter

# ---- order: four bad values in one file ------------------------------------------------------------------------------------------
order() {
  echo "A   this tree, fourbad/ in front of its jar's file"; served . 'java -cp "fourbad:$AFTER" com.tiffinbox.harness.Serve --tiffinbox.port=18694'
  echo "B   atvalue/: Database back on a @Value placeholder, the same fourbad/ file"; served . 'java -cp "fourbad:$ATVALUE" com.tiffinbox.harness.Serve --tiffinbox.port=18694'
  echo "A′  A, re-run"; served . 'java -cp "fourbad:$AFTER" com.tiffinbox.harness.Serve --tiffinbox.port=18694'
  # Boot's own order: the capture above sorts the blocks (README, masks). Here A's command runs six more times and the
  # Property: lines are read in the order Boot printed them. Only "more than one order" is printed: which orders come up,
  # and how many, differ between runs, so a count would never hash the same twice.
  local i n seen=""
  for i in 1 2 3 4 5 6; do
    (eval 'java -cp "fourbad:$AFTER" com.tiffinbox.harness.Serve --tiffinbox.port=18694') > .harness/run.raw 2>&1 < /dev/null || true
    seen="$seen$(grep '^    Property: ' .harness/run.raw | sed 's/^ *Property: //' | paste -sd' ' -)"$'\n'; done
  n=$(printf '%s' "$seen" | sort -u | grep -c . || true)
  echo "Boot's own order, unsorted: A's command 6 more times, its Property: lines as Boot printed them - 4 blocks every run: $([ "$(printf '%s' "$seen" | awk '{ print NF }' | sort -u)" = 4 ] && echo yes || echo no) · more than one order among the 6: $([ "$n" -gt 1 ] && echo yes || echo no)"; }
cap order order

# ---- boxed: a key nobody wrote, as an int and as an Integer ----------------------------------------------------------------------
boxed() {
  echo "A   this tree (Integer, @NotNull @Min(1)), nodays/ in front of its jar's file"; served . 'java -cp "nodays:$AFTER" com.tiffinbox.harness.Serve --tiffinbox.port=18695'
  echo "B   intrecord/: the record with int (@Min(1), no @NotNull), the same nodays/ file"; served . 'java -cp "nodays:$INTRECORD" com.tiffinbox.harness.Serve --tiffinbox.port=18695'
  echo "A′  A, re-run"; served . 'java -cp "nodays:$AFTER" com.tiffinbox.harness.Serve --tiffinbox.port=18695'
  echo "C   novalidated/: this tree minus @Validated, the same nodays/ file"; served . 'java -cp "nodays:$NOVALID" com.tiffinbox.harness.Serve --tiffinbox.port=18695'; }
cap boxed boxed

# ---- method: method validation, asked of Boot ---------------------------------------------------------------------------------------
PARENT=.m2-demo/org/springframework/boot/spring-boot-starter-parent/4.1.1/spring-boot-starter-parent-4.1.1.pom
method() {
  echo "Boot's parent POM, the compiler's flag: $(grep -n '<parameters>true</parameters>' "$PARENT" | sed 's/^\([0-9]*\): */line \1: /') ($(grep -c '<parameters>' "$PARENT") such line)"
  echo "A   this tree"; run 'java -cp "$AFTER" com.tiffinbox.harness.Hire --tiffinbox.port=18696' 'parameter names'
  echo "B   the previous tree: no validation starter"; run 'java -cp "$BEFORE" com.tiffinbox.harness.Hire --tiffinbox.port=18696' 'parameter names'
  echo "A′  A, re-run"; run 'java -cp "$AFTER" com.tiffinbox.harness.Hire --tiffinbox.port=18696' 'parameter names'
  echo "C   this tree, the harness compiled without -parameters"; run 'java -cp "$NOPARAMS" com.tiffinbox.harness.Hire --tiffinbox.port=18696' 'parameter names'; }
cap method method

# ---- serve: this tree's jar, in after/tiffinbox-web/target -----------------------------------------------------------------
# readme FLAG: the flag after/README.md's run command gives after the port, on the line whose flag starts --FLAG - read
# from the file, so a label never claims what the README says
readme() { sed -nE "s/^.*java -jar tiffinbox-web\/target\/tiffinbox-web-1\.0\.0\.jar --tiffinbox\.port=[0-9]+ (--$1[^\` ]*).*$/\1/p" "$AT/README.md" | head -1; }
serve() { local T="$AT/tiffinbox-web/target" f
  startjar "$T" 'java -jar tiffinbox-web-1.0.0.jar --tiffinbox.port=18690'; seven 18690
  echo "  TiffinBox's log: $(said .harness/jar.log 'meal types:')"
  f=$(readme logging.level); [ -n "$f" ] || die "after/README.md no longer gives a logging command"
  echo "the logging flag after/README.md gives, after the port: $f"
  startjar "$T" "java -jar tiffinbox-web-1.0.0.jar --tiffinbox.port=18690 $f"; seven 18690
  echo "  route DEBUG lines $(grep -c 'route [A-Z]* /' .harness/jar.log || true)"
  f=$(readme spring.profiles); [ -n "$f" ] || die "after/README.md no longer gives the lunch-rush command"
  echo "the lunch-rush flag after/README.md gives, after the port: $f"
  startjar "$T" "java -jar tiffinbox-web-1.0.0.jar --tiffinbox.port=18690 $f"; seven 18690
  echo "  Boot: $(said .harness/jar.log 'The following')"; }
cap serve serve

# ---- files: every demo file, against the file it stands in for ---------------------------------------------------------------------
files() { local f
  against() { if cmp -s "$1" "$2"; then echo "$2: $3, byte for byte"
              else echo "$2, against $3:"; diff "$1" "$2" | sed 's/^/  /' || true; fi; }
  for f in cooks0 nodays fourbad; do against "$AT/$YAML" "$f/application.yaml" "the anchor's application.yaml"; done
  against "$AT/$DB" atvalue/Database.java "after/'s Database.java"
  against "$AT/$REC" intrecord/TiffinBoxProperties.java "after/'s TiffinBoxProperties.java"
  against "$AT/$REC" novalidated/TiffinBoxProperties.java "after/'s TiffinBoxProperties.java"
  against "$BT/$WEBPOM" nostarter/$WEBPOM "the previous tree's $WEBPOM"
  against "$AT/$WEBPOM" nostarter/$WEBPOM "after/'s $WEBPOM"
  against "$BT/$COREPOM" noapi/$COREPOM "the previous tree's $COREPOM"
  against "$AT/$COREPOM" noapi/$COREPOM "after/'s $COREPOM"; }
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

# "A zero set on purpose does the same. Here's the previous version with zero cooks: exit zero, zero orders cooked, and the
# kitchen still answers two hundred, OK." (spoken "it starts": the exit 0 is read after POST /shutdown) · "Minus one is
# louder. Exit one, and forty-five lines of stack trace ... They end in the kitchen's constructor: count less than zero.
# Not one line names the key, and not one is a null pointer exception."
U0=$(blk unvalidated 'the previous tree' 'the same jar'); U1=$(blk unvalidated 'the same jar' '')
has1 "$U0" "  TiffinBox's log: orders cooked:  0" unvalidated
has1 "$U0" '  GET   /kitchen    -> 200 application/json  {"ordersCooked":0,"ordersValue":0}' unvalidated
has1 "$U0" '  exit 0 · the seven responses: 7 lines · md5 48c20805358e969bfc65e9197ce3b541' unvalidated
has1 "$U1" '  exit 1 · WARN lines 1 · ERROR lines 1 · listening lines 0' unvalidated
has1 "$U1" '  Property: lines 0 · SQLException lines 0 · stack-frame lines 45' unvalidated
has1 "$U1" '  Caused by: org.springframework.beans.BeanInstantiationException: Failed to instantiate [com.tiffinbox.OrderQueue]: Constructor threw exception' unvalidated
has1 "$U1" '  Caused by: java.lang.IllegalArgumentException: count < 0' unvalidated
x unvalidated '^  lines that name the key \(cooks, in any case\): 0 · NullPointerException lines: 0 · output lines in all: [0-9]+$'
echo "  unvalidated: cooks 0 -> exit 0, 0 cooked, /kitchen 200, 48c20805... · cooks -1 -> exit 1, 45 frames, OrderQueue's constructor, count < 0, 0 lines name the key, 0 NPE"

# "Core gains Bean Validation's API ... The record gets its rules: not blank, not null, at least one, not empty. And
# Validated, on the record, asks Boot's binder, which fills the record, to check them. The web module gains the validation
# starter." · the anchor change: three files changed, nothing new · "all three readers take the record. Two of them live
# in core, so the record does too." · "the metadata file no longer promises a zero"
x change '^files, README aside: the previous tree 16 · after/ 16 · in both 16: identical 13, changed 3$'
x change '^  only before: \(none\)$'; x change '^  only after:  \(none\)$'
CC=$(blk change 'tiffinbox-core/pom.xml, every changed line' 'TiffinBoxProperties.java, every'); CR=$(blk change 'TiffinBoxProperties.java, every changed line' 'tiffinbox-web/pom.xml, every')
CW=$(blk change 'tiffinbox-web/pom.xml, every changed line' 'the record, whole')
[ "$(printf '%s\n' "$CC" | paste -sd'|' -)" = '+    <dependency>|+      <groupId>jakarta.validation</groupId>|+      <artifactId>jakarta.validation-api</artifactId>|+    </dependency>' ] \
  || die "change: tiffinbox-core/pom.xml gains jakarta.validation-api, nothing else"
[ "$(printf '%s\n' "$CW" | paste -sd'|' -)" = '+    <dependency>|+      <groupId>org.springframework.boot</groupId>|+      <artifactId>spring-boot-starter-validation</artifactId>|+    </dependency>' ] \
  || die "change: tiffinbox-web/pom.xml gains spring-boot-starter-validation, nothing else"
has1 "$CR" '+@Validated' change
has1 "$CR" '+public record TiffinBoxProperties(@NotBlank String jdbcUrl, @NotNull @Min(1) Integer cooks, @NotNull @Min(1) Integer days,' change
has1 "$CR" '+                                  @NotNull @Min(1) Integer port, @NotEmpty List<MealType> mealTypes) {' change
[ "$(cnt "$CR" '^-')" = 1 ] && [ "$(cnt "$CR" '^\+import ')" = 5 ] || die "change: the record loses its old header, and gains five imports"
x change '^TiffinBox.s @Value placeholders: the previous tree 0 · after/ 0$'
x change '^classes whose constructor takes the record \(TiffinBoxProperties settings\): the previous tree 3: tiffinbox-core/Database\.java tiffinbox-core/OrderQueue\.java tiffinbox-web/TiffinBoxServer\.java · after/ 3: tiffinbox-core/Database\.java tiffinbox-core/OrderQueue\.java tiffinbox-web/TiffinBoxServer\.java$'
x change '^"defaultValue": 0 entries in the core jar.s metadata file: the previous tree 3 · after/ 0$'
echo "  change: 3 files changed (core POM + the API, web POM + the starter, the record: @Validated, constraints, Integer); @Value 0; 3 readers take the record, 2 of them in core; metadata zero defaults 3 -> 0"

# "A: zero cooks, written in the file. Exit one, and the port never opened. Boot's report gives the property, the value, its
# origin, line four, column ten, and the reason." · "B: this version without Validated, every rule kept, same file. It
# starts, and cooks nothing ... A again: the same report. C, the previous version, behaves like B." (B's and C's exit 0 is
# read after POST /shutdown; the voice says "it starts", not "exit zero")
KA=$(blk break 'A   ' 'B   '); KB=$(blk break 'B   ' 'A′  '); KA2=$(blk break 'A′  ' 'C   '); KC=$(blk break 'C   ' '')
has1 "$KA" '  exit 1 · WARN lines 1 · ERROR lines 1 · listening lines 0' break
has1 "$KA" '  the class path gives: application.yaml <- cooks0/application.yaml · application.properties <- none' break
[ "$(printf '%s\n' "$KA" | grep -A3 '^      Property: ' | paste -sd'|' -)" = '      Property: tiffinbox.cooks|      Value: "0"|      Origin: class path resource [application.yaml] - 4:10|      Reason: must be greater than or equal to 1' ] \
  || die "break: A's report must be the one block - property, value, origin 4:10, reason"
for K in "$KB" "$KC"; do
  has1 "$K" '  listens on: 127.0.0.1:18692 · WARN lines 0 · ERROR lines 0' break
  has1 "$K" "  TiffinBox's log: orders cooked:  0" break
  has1 "$K" '  exit 0 · the seven responses: 7 lines · md5 48c20805358e969bfc65e9197ce3b541' break; done
has1 "$KB" '$ java -cp "cooks0:$NOVALID" com.tiffinbox.harness.Serve --tiffinbox.port=18692' break
has1 "$KC" '$ java -cp "cooks0:$BEFORE" com.tiffinbox.harness.Serve --tiffinbox.port=18692' break
[ "$KA" = "$KA2" ] || die "break: A' is not A, line for line"
[ "$(blk files 'novalidated/TiffinBoxProperties.java, against' 'nostarter/' | paste -sd'|' -)" = '  30d29|  < @Validated' ] || die "files: novalidated/ must delete @Validated alone"
[ "$(blk files 'cooks0/application.yaml, against' 'nodays/' | paste -sd'|' -)" = '  4c4|  <   cooks: 3|  ---|  >   cooks: 0' ] || die "files: cooks0/ must change cooks alone"
x files '^  4c4$'                                                                  # line four of the file is cooks
echo "  break: A exit 1, 0 listening, the report (tiffinbox.cooks, \"0\", 4:10, the reason) · B (minus @Validated) listens, 0 cooked, 48c20805... · A' = A · C (the previous tree) the same as B"

# "The starter adds seven jars. One of them carries its own imports file ... TiffinBox had one; now it has two, and the new
# one names a single class: the validation auto-configuration."
x imports '^jars in tiffinbox-web/target/lib: the previous tree 26 · after/ 33$'
x imports '^  new in after/: classmate-1\.7\.3\.jar hibernate-validator-9\.1\.3\.Final\.jar jakarta\.validation-api-3\.1\.1\.jar jboss-logging-3\.6\.3\.Final\.jar spring-boot-starter-validation-4\.1\.1\.jar spring-boot-validation-4\.1\.1\.jar tomcat-embed-el-11\.0\.24\.jar$'
x imports '^  gone from after/: \(none\)$'
x imports '^  the previous tree 1: spring-boot-autoconfigure-4\.1\.1\.jar$'
x imports '^  after/ 2: spring-boot-autoconfigure-4\.1\.1\.jar spring-boot-validation-4\.1\.1\.jar$'
[ "$(grep -cE '^ +[0-9]+ \| ' .r-imports.out)" = 1 ] && x imports '^  1 \| org\.springframework\.boot\.validation\.autoconfigure\.ValidationAutoConfiguration$' \
  || die "imports: the new imports file must name one class, ValidationAutoConfiguration"
echo "  imports: lib/ 26 -> 33 (7 new, 0 gone); imports files 1 -> 2; the new one: 1 class, ValidationAutoConfiguration"

# "Take the starter out and keep the annotations' jar, the API: TiffinBox refuses to start, even with a good file ... Starter
# back: it starts. Take the API out too, and the record doesn't compile. D: no starter and no Validated: it starts.
# Validated asked for a validator, and nobody provided one."
SA=$(blk starter 'A   ' 'B   '); SB=$(blk starter 'B   ' 'A′  '); SA2=$(blk starter 'A′  ' 'C   '); SC=$(blk starter 'C   ' 'D   ')
SD=$(blk starter 'D   ' '')
has1 "$SA" '  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891' starter
has1 "$SB" '  lib/: 27 jars · jakarta.validation-api among them: 1 · hibernate-validator among them: 0' starter
has1 "$SB" '  exit 1 · WARN lines 1 · ERROR lines 1 · listening lines 0' starter
has1 "$SB" '  the class path gives: application.yaml <- tiffinbox-web-1.0.0.jar!/application.yaml · application.properties <- none' starter
has1 "$SB" '  The Bean Validation API is on the classpath but no implementation could be found' starter
has1 "$SB" '  Add an implementation, such as Hibernate Validator, to the classpath' starter
[ "$SA" = "$SA2" ] || die "starter: A' is not A, line for line"
has1 "$SC" '  exit 1 · BUILD FAILURE · WARNING lines 0 · ERROR lines 52' starter
x starter '^  the compiler.s error lines \(\[ERROR\] …java:\[line,column\] …\): [0-9]+ · in: TiffinBoxProperties\.java$'
has1 "$SC" '  the first: [ERROR] …/tiffinbox-core/src/main/java/com/tiffinbox/TiffinBoxProperties.java:[3,38] package jakarta.validation.constraints does not exist' starter
x files '^nostarter/tiffinbox-web/pom\.xml: the previous tree.s tiffinbox-web/pom\.xml, byte for byte$'
x files '^noapi/tiffinbox-core/pom\.xml: the previous tree.s tiffinbox-core/pom\.xml, byte for byte$'
has1 "$SD" '  lib/: 27 jars · jakarta.validation-api among them: 1 · hibernate-validator among them: 0' starter
has1 "$SD" '$ java -cp "$NOSTARTER_NOVALID" com.tiffinbox.harness.Serve --tiffinbox.port=18693' starter
has1 "$SD" '  listens on: 127.0.0.1:18693 · WARN lines 0 · ERROR lines 0' starter
has1 "$SD" "  TiffinBox's log: orders cooked:  120" starter
has1 "$SD" '  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891' starter
echo "  starter: A 115c36ba... · B (API alone, 27 jars) exit 1, no implementation · A' = A · C (no API) BUILD FAILURE, every compiler error in TiffinBoxProperties.java · D (no starter, no @Validated) listens, 120 cooked, 115c36ba..."

# "Now four bad values in one file ... One report lists all four, and there's no SQL error. And the names are the record's Java
# names, not the keys as the file spells them" (on screen: jdbcUrl, mealTypes) · "B: put the database back on a Value placeholder, one file changed. Exit one, and no
# report at all: the database's startup method ran first and failed, no suitable driver for an empty address." · the chip
# "Boot's own order changes from run to run - the capture sorts the blocks": six more unsorted runs, more than one order
OA=$(blk order 'A   ' 'B   '); OB=$(blk order 'B   ' 'A′  '); OA2=$(blk order 'A′  ' "Boot's own order")
has1 "$OA" '  exit 1 · WARN lines 1 · ERROR lines 1 · listening lines 0' order
has1 "$OA" '  Property: lines 4 · SQLException lines 0 · stack-frame lines 0' order
[ "$(printf '%s\n' "$OA" | grep '^      Property: ' | paste -sd'|' -)" = '      Property: tiffinbox.cooks|      Property: tiffinbox.days|      Property: tiffinbox.jdbcUrl|      Property: tiffinbox.mealTypes' ] \
  || die "order: A's report must list the four, by the record's names"
has1 "$OA" '      Origin: class path resource [application.yaml] - 3:13' order; has1 "$OA" '      Reason: must not be blank' order
has1 "$OA" '      Value: "[]"' order; has1 "$OA" '      Reason: must not be empty' order
has1 "$OB" '  exit 1 · WARN lines 1 · ERROR lines 1 · listening lines 0' order
x order '^  Property: lines 0 · SQLException lines 1 · stack-frame lines [0-9]+$'
has1 "$OB" "  Caused by: org.springframework.beans.factory.BeanCreationException: Error creating bean with name 'database': Invocation of init method failed" order
has1 "$OB" '  Caused by: java.sql.SQLException: No suitable driver found for ' order
[ "$OA" = "$OA2" ] || die "order: A' is not A, line for line"
[ "$(blk files 'atvalue/Database.java, against' 'intrecord/' | grep -c '^  [<>] ')" = 5 ] && [ "$(blk files 'atvalue/Database.java, against' 'intrecord/' | grep -c '^  > .*@Value("\${tiffinbox.jdbc-url}")')" = 1 ] \
  || die "files: atvalue/Database.java must put the constructor back on @Value, and nothing else"
FB=$(blk files 'fourbad/application.yaml, against' 'atvalue/')
has1 "$FB" '  >   jdbc-url: ""' files; has1 "$FB" '  >   cooks: 0' files; has1 "$FB" '  <   days: 30' files; has1 "$FB" '  >   meal-types: []' files
[ "$(printf '%s\n' "$FB" | grep -c '^  > ')" = 3 ] || die "files: fourbad/ writes three lines and deletes days"
x order "^Boot's own order, unsorted: A's command 6 more times, its Property: lines as Boot printed them - 4 blocks every run: yes · more than one order among the 6: yes$"
echo "  order: A exit 1, one report, 4 properties (cooks days jdbcUrl mealTypes), 0 SQLException · B (Database on @Value) exit 1, 0 Property lines, database's init method, No suitable driver · A' = A · unsorted: more than one order in 6 runs"

# "Delete the days line. A, this version: value null, must not be null." · "B, the same record with plain ints and no
# NotNull: value zero, a value nobody wrote, and no origin line, because nothing wrote it. A again: null." · "C: this
# version without Validated. The null goes unchecked into the server's constructor, and the start dies: a null pointer
# exception."
XA=$(blk boxed 'A   ' 'B   '); XB=$(blk boxed 'B   ' 'A′  '); XA2=$(blk boxed 'A′  ' 'C   '); XC=$(blk boxed 'C   ' '')
[ "$(printf '%s\n' "$XA" | grep -A2 '^      Property: ' | paste -sd'|' -)" = '      Property: tiffinbox.days|      Value: "null"|      Reason: must not be null' ] || die "boxed: A must read null, no origin, must not be null"
[ "$(printf '%s\n' "$XB" | grep -A2 '^      Property: ' | paste -sd'|' -)" = '      Property: tiffinbox.days|      Value: "0"|      Reason: must be greater than or equal to 1' ] || die "boxed: B must read 0, no origin"
[ "$(cnt "$XA" '^      Origin: ')" = 0 ] && [ "$(cnt "$XB" '^      Origin: ')" = 0 ] || die "boxed: neither report may carry an Origin line"
[ "$XA" = "$XA2" ] || die "boxed: A' is not A, line for line"
[ "$(blk files 'nodays/application.yaml, against' 'fourbad/' | paste -sd'|' -)" = '  5d4|  <   days: 30' ] || die "files: nodays/ must delete the days line alone"
[ "$(blk files 'intrecord/TiffinBoxProperties.java, against' 'novalidated/' | grep -c '^  [<>] ')" = 4 ] || die "files: intrecord/ must change the record's header alone"
has1 "$XC" '$ java -cp "nodays:$NOVALID" com.tiffinbox.harness.Serve --tiffinbox.port=18695' boxed
has1 "$XC" '  exit 1 · WARN lines 1 · ERROR lines 1 · listening lines 0' boxed
has1 "$XC" '  Property: lines 0 · SQLException lines 0 · stack-frame lines 37' boxed
has1 "$XC" '  Caused by: org.springframework.beans.BeanInstantiationException: Failed to instantiate [com.tiffinbox.web.TiffinBoxServer]: Constructor threw exception' boxed
has1 "$XC" '  Caused by: java.lang.NullPointerException: Cannot invoke "java.lang.Integer.intValue()" because the return value of "com.tiffinbox.TiffinBoxProperties.days()" is null' boxed
echo "  boxed: A (Integer) \"null\", must not be null, no Origin · B (int) \"0\", no Origin · A' = A · C (minus @Validated) exit 1, 0 Property lines, TiffinBoxServer's constructor, NullPointerException on days()"

# "the validation auto-configuration declares the post-processor ... The previous version, without the starter, has none." ·
# "call hire with zero cooks: rejected, as hire
# dot cooks. That name needs the compiler's parameters flag, which Boot's parent switches on; without it, arg zero. An object
# argument is checked when it's marked Valid; without Valid, the call just returns. The bean is a subclass Spring generated,
# and that's where the check happens."
x method '^Boot.s parent POM, the compiler.s flag: line [0-9]+: <parameters>true</parameters> \(1 such line\)$'
MA=$(blk method 'A   ' 'B   '); MB=$(blk method 'B   ' 'A′  '); MA2=$(blk method 'A′  ' 'C   '); MC=$(blk method 'C   ' '')
has1 "$MA" 'exit 0 · WARN lines 0 · ERROR lines 0' method
has1 "$MA" 'MethodValidationPostProcessor beans: [methodValidationPostProcessor] · methodValidationPostProcessor is declared by org.springframework.boot.validation.autoconfigure.ValidationAutoConfiguration.methodValidationPostProcessor()' method
has1 "$MA" 'the hiring bean'"$Q"'s class: com.tiffinbox.harness.Hiring$$SpringCGLIB$$<n> · a subclass of Hiring: true' method
has1 "$MA" 'hire(0) -> threw jakarta.validation.ConstraintViolationException: hire.cooks: must be greater than or equal to 1' method
has1 "$MA" 'take(new Slip(0)), its parameter marked @Valid -> threw jakarta.validation.ConstraintViolationException: take.slip.meals: must be greater than or equal to 1' method
has1 "$MA" 'takeUnchecked(new Slip(0)), no @Valid -> returned 0' method
has1 "$MA" "parameter names, as compiled: TiffinBox's OrderQueue(TiffinBoxProperties) -> settings (present: true) · the harness's Hiring.hire(int) -> cooks (present: true)" method
has1 "$MB" 'MethodValidationPostProcessor beans: []' method
has1 "$MB" 'the hiring bean'"$Q"'s class: com.tiffinbox.harness.Hiring · a subclass of Hiring: false' method
has1 "$MB" 'hire(0) -> returned 0' method
[ "$MA" = "$MA2" ] || die "method: A' is not A, line for line"
has1 "$MC" "parameter names, as compiled: TiffinBox's OrderQueue(TiffinBoxProperties) -> settings (present: true) · the harness's Hiring.hire(int) -> arg0 (present: false)" method
has1 "$MC" 'hire(0) -> threw jakarta.validation.ConstraintViolationException: hire.arg0: must be greater than or equal to 1' method
echo "  method: parent <parameters>true</parameters> · A 1 post-processor (ValidationAutoConfiguration), a CGLIB subclass, hire.cooks, @Valid checked, unchecked returned 0 · B none, plain class, returned 0 · A' = A · C hire.arg0"

# "the last course's seven requests get the same answers" (the anchor's run command and README commands, unchanged)
[ "$(grep -c '^  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891$' .r-serve.out)" = 3 ] || die "serve: the seven responses must hash to 115c36ba..., all three runs"
x serve '^  TiffinBox.s log: meal types:     \[VEG, NON_VEG, VEGAN\]$'; x serve '^  route DEBUG lines 5$'; x serve '^  Boot: The following 1 profile is active: "rush"$'
x serve '^the logging flag after/README\.md gives, after the port: --logging\.level\.tiffinbox=debug$'
x serve '^the lunch-rush flag after/README\.md gives, after the port: --spring\.profiles\.active=rush$'
echo "  serve: the seven responses 115c36ba... (plain, and the README's logging and lunch-rush flags); the list's log line"

[ -z "$unpub" ] || die "no published hash for:$unpub - check the captures, then copy the md5s above into receipts.md5 and run again"
echo "c5-unit09: every capture 3/3 and = published; every spoken number asserted"
