#!/bin/bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25.0.4.1 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# Course 5 · Profiles, Groups and spring.config.import — this unit's receipts. TiffinBox had one profile, "rush", written as
# a second document in application.yaml. This unit composes its configuration from four sources: the base document, the
# rush document, a profile of its own file (application-audit.yaml: TiffinBox's logging at debug), and a developer's own
# git-ignored file that application.yaml imports (optional:file:./tiffinbox-local.yaml) - with a group, "lunch", that
# switches on rush and audit together (the anchor change). Then how Boot ranks the four, and three mistakes: one that starts
# without a word, and two that stop the start. Eight captures, each run three times and hashed; cap() DIES when a hash
# differs from receipts.md5; every number the video says is asserted at the bottom by a check that can fail.
#   change   the previous tree against after/, file by file: application.yaml's changed lines, the two new files whole, and
#            what git makes of tiffinbox-local.yaml under after/'s .gitignore (in a throwaway repository)
#   group    no profile, then lunch: Boot's profile line, the stack, TiffinBox's route lines at debug
#   import   A this folder, no tiffinbox-local.yaml · B the same command from local/, which holds one · A' = A
#   stack    lunch from local/: all four sources in one stack · the same two profiles named the other way round
#   break    A lunch · B lnch, one letter missing · A' = A
#   loud     the import without optional: and no file · spring.profiles.active inside the audit's file, lunch on · the same
#            file with no profile
#   serve    after/'s jar: the seven responses - plain, and the anchor README's logging, rush and lunch commands
#   files    every demo file against the file it stands in for (diff)
# "before" is ../c5-unit09/after (the anchor as the last unit left it), COPIED to .harness/before: this script never writes
# into another unit's folder, and nothing in it runs the previous tree - `change` reads its files. after/ is this unit's
# frozen copy of ../c5-tiffinbox after the change, built in place, clean.
# Commands are printed exactly as they run: each goes through eval, so "$AFTER" (the harness's classes plus after/'s jars,
# written to .harness/after.classpath) and "$M2" (this unit's own repository, .m2-demo) expand when it runs. A harness
# command runs from this folder, or from local/ when it says `cd local &&` - the folder TiffinBox starts in is the folder
# application.yaml's import looks in. A folder in front of after/ on a class path (required/, inprofile/) holds one file
# that the class path then gives instead of the jar's own; `files` shows how each differs from the anchor's.
# Masks and filters (README.md declares each; sub/gsub only): Boot's timestamped log lines are dropped from a harness report
# and counted, and so are the lines between the harness's first line and its report (the banner); a kept log message loses
# its prefix through sub(); a failed start shows Boot's failure report without its blank lines and its rows of asterisks,
# or - when Boot printed none - the exception's own line and its last two "Caused by:" lines, a [jar:file:…] or [file:…]
# location cut to […] (gsub); the rest is counted.
# Ports (brief ⚑11, 18700-18709): serve 18700 · group 18701 · import 18702 · stack 18703 · break 18704 · loud 18705 (the
# first two runs never bind) · the exercise 18709.
set -e
cd "$(dirname "$0")"
# One run at a time: two runs share .harness/ and the ports, and one would corrupt the other.
mkdir .r-lock 2> /dev/null || { echo "  *** another receipts.sh is running in this folder (.r-lock exists) - if none is, rmdir .r-lock ***"; exit 1; }
trap 'rmdir .r-lock 2> /dev/null' EXIT
exec 3>&1                                            # die() speaks to the terminal even inside a redirected capture
die() { echo "  *** $* ***" >&3; exit 1; }
java -version 2>&1 | grep -q 'version "25' || die "JDK 25 needed; JAVA_HOME gives: $(java -version 2>&1 | head -1)"
# A variable of yours must not become a property source: every TIFFINBOX_* and SPRING_* variable, and the two variables
# that inject JVM flags, are removed from this script's environment before anything runs. MAVEN_OPTS and MAVEN_ARGS too.
for v in $(env | sed -n 's/^\(TIFFINBOX_[A-Za-z0-9_]*\|SPRING_[A-Za-z0-9_]*\|JAVA_TOOL_OPTIONS\|JDK_JAVA_OPTIONS\|MAVEN_OPTS\|MAVEN_ARGS\)=.*/\1/p'); do unset "$v"; done
# application.yaml imports ./tiffinbox-local.yaml from the folder TiffinBox starts in: this folder must hold none (the runs
# here are the "absent" ones), and local/ must hold the one the "present" runs read.
[ -e tiffinbox-local.yaml ] && die "this folder holds a tiffinbox-local.yaml - remove it: the runs from here are the ones without it"
[ -f local/tiffinbox-local.yaml ] || die "local/tiffinbox-local.yaml is missing"
M2="$PWD/.m2-demo"
YAML=tiffinbox-web/src/main/resources/application.yaml
AUDIT=tiffinbox-web/src/main/resources/application-audit.yaml

# ---- build: after/, clean; the previous tree is only copied (its files are read, never run) --------------------------------
rm -rf .harness; mkdir -p .harness
rsync -a --exclude target ../c5-unit09/after/ .harness/before/
BT=.harness/before; AT=after
build() { (cd "$1" && { mvn -o -q -B -Dmaven.repo.local="$M2" -DskipTests clean package > /dev/null 2>&1 \
                        || mvn -q -B -Dmaven.repo.local="$M2" -DskipTests clean package; }) || die "build failed: $1"; }
build "$AT"
[ -e "$AT/tiffinbox-web/target/tiffinbox-local.yaml" ] && die "after/tiffinbox-web/target holds a tiffinbox-local.yaml"
jars() { echo "$PWD/$1/tiffinbox-web/target/tiffinbox-web-1.0.0.jar:$(ls "$PWD/$1"/tiffinbox-web/target/lib/*.jar | paste -sd: -)"; }
javac -parameters -cp "$(jars "$AT")" -d .harness/classes harness/com/tiffinbox/harness/*.java || die "the harness did not compile"
AFTER="$PWD/.harness/classes:$(jars "$AT")"
printf '%s\n' "$AFTER" > .harness/after.classpath

listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
for p in 18425 18700 18701 18702 18703 18704 18705; do
  [ "$(listeners $p)" = 0 ] || die "something already listens on $p - this unit's ports must be free"; done

# runh 'COMMAND': print it exactly as typed, run it (eval, in a subshell, from this folder), keep its exit code in $ec.
runh() { echo "\$ $1"; ec=0; (eval "$1") > .harness/run.raw 2>&1 < /dev/null || ec=$?; }
warns() { echo "WARN lines $(grep -c ' WARN ' "$1" || true) · ERROR lines $(grep -c ' ERROR ' "$1" || true)"; }
routes() { grep -c 'route [A-Z]* /' "$1" || true; }
# said FILE MESSAGE...: the first log line whose message starts with one of the MESSAGEs, its prefix (time, level, pid,
# thread, logger) cut by sub() - or "(no such line)"
said() { local f=$1; shift; awk -v ms="$(printf '%s\034' "$@")" '
  BEGIN { n = split(ms, m, "\034") - 1 }
  { s = $0; sub(/^[0-9][0-9][0-9][0-9]-[^ ]* +[A-Z]+ [0-9]+ --- \[[^]]*\] [^:]* : /, "", s)
    for (i = 1; i <= n; i++) if (index(s, m[i]) == 1) { print s; f = 1; exit } }
  END { if (!f) print "(no such line)" }' "$f"; }
profiles() { said "$1" 'The following ' 'No active profile set'; }
# report: the harness's own lines - its first line (the files), then everything from "active profiles: " on. Boot's
# timestamped log lines are dropped everywhere, and the other lines before the report (the banner) too - both counted.
report() { awk '
  /^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T[0-9][0-9]:/ { n++; next }
  NR == 1 && index($0, "the class path gives: ") == 1 { print; next }
  !f && index($0, "active profiles: ") == 1 { f = 1 }
  f { print; next }
  { m++ }
  END { printf "… elided: %d log line(s) of Boot'"'"'s, and %d line(s) printed before the report (the banner and its blank lines) …\n", n, m }' .harness/run.raw; }
# a failed start: how far it got (exit, WARN/ERROR lines, banner and listening lines), the files the class path gave, then
# Boot's own failure report without its blank lines and its rows of asterisks - or, when there is none, the exception's own
# line and its last two "Caused by:" lines, a [jar:file:…] or [file:…] location cut to […] by gsub - then the exception the
# harness names, and the count of the run's lines not shown
failed() { local shown
  echo "  exit $ec · $(warns .harness/run.raw) · banner lines $(grep -c ':: Spring Boot ::' .harness/run.raw || true) · listening lines $(grep -c 'TiffinBox listening on' .harness/run.raw || true)"
  grep -m1 '^the class path gives: ' .harness/run.raw | sed 's/^/  /' > .harness/fail.txt || true
  if grep -q '^APPLICATION FAILED TO START$' .harness/run.raw; then
    awk '/^APPLICATION FAILED TO START$/ { f = 1 } /^the exception TiffinBox.s main threw: / { f = 0 } f && !/^[*]+$/ && !/^[[:space:]]*$/ { print "  " $0 }' .harness/run.raw >> .harness/fail.txt
  else { grep -m1 -E '^[a-z][a-z0-9_]*(\.[A-Za-z0-9_$]+)+(Exception|Error)(: |$)' .harness/run.raw || echo "(no exception line)"
         grep '^Caused by: ' .harness/run.raw | tail -2; } | awk '{ gsub(/\[jar:file:[^]]*\]/, "[…]"); gsub(/\[file:[^]]*\]/, "[…]"); print "  " $0 }' >> .harness/fail.txt; fi
  cat .harness/fail.txt
  grep -m1 "^the exception TiffinBox's main threw: " .harness/run.raw | sed 's/^/  /' || true
  shown=$(( $(wc -l < .harness/fail.txt) + $(grep -c "^the exception TiffinBox's main threw: " .harness/run.raw || true) ))
  echo "  … $(( $(wc -l < .harness/run.raw) - shown )) more line(s) of this run's output not shown: Boot's log, blank lines, rows of asterisks, stack frames …"; }
# stack 'COMMAND': a harness run - exit code, WARN/ERROR lines, TiffinBox's route lines at debug and Boot's profile line,
# then the harness's report; or, if the start failed, how far it got and why
stack() { runh "$1"
  if [ "$ec" = 0 ]; then
    echo "exit $ec · $(warns .harness/run.raw) · route DEBUG lines $(routes .harness/run.raw) · Boot: $(profiles .harness/run.raw)"; report
  else failed; fi; }

# startjar DIR 'COMMAND': print the command, start it from DIR in the background (exec: $pid is java's own pid).
startjar() { echo "\$ $2"; (cd "$1" && eval "exec $2") > .harness/jar.log 2>&1 < /dev/null & pid=$!; }
# the seven responses of Course 4's comparison set, on PORT, hashed on their own (the set ends with POST /shutdown); the
# JVM must leave within 15 s of it, and the port must be free again. Never call it inside $(...): wait needs this shell.
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
  if [ -z "$pub" ]; then printf '  %-7s md5 %s  3/3  (no published hash)\n' "$nm" "$h"; unpub="$unpub $nm"
  elif [ "$pub" = "$h" ]; then printf '  %-7s md5 %s  3/3  = published\n' "$nm" "$h"
  else printf '  %-7s md5 %s  3/3  DIFFERS from the published %s\n' "$nm" "$h" "$pub"
    die "$nm is not the published capture - suspect another JDK, Boot or Maven, a busy port, a variable of yours, a tiffinbox-local.yaml where none belongs, or an edited source; diff .r-$nm.out against its block in README.md"; fi; }

# ---- change: the previous tree against after/, file by file (README aside) --------------------------------------------------
# code FILE: its code lines - blank lines and comments dropped (YAML and .gitignore: lines starting #)
code() { awk '{ t = $0; sub(/^[ \t]+/, "", t) } t == "" || index(t, "#") == 1 { next } { print }' "$1"; }
pm() { git diff --no-index --no-color -U0 "$1" "$2" | grep -E '^[-+]' | grep -vE '^(---|\+\+\+) ' || true; }   # changed lines, +/-
whole() { awk '{ printf "%3d | %s\n", NR, $0 }' "$1"; }
change() { local a b n=0 same=0 changed="" gone="" new="" f all cod gi
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
    echo "${f##*/}, every changed line but comments and blanks ($(( all - $(echo "$cod" | grep -c . || true) )) of those not shown):"
    echo "${cod:-  (none)}"; done
  for f in $new; do echo "new: $f, whole"; whole "$AT/$f"; done
  rm -rf .harness/git; mkdir -p .harness/git; cp "$AT/.gitignore" .harness/git/; : > .harness/git/tiffinbox-local.yaml
  git -C .harness/git init -q
  echo "a throwaway git repository holding after/.gitignore and an empty tiffinbox-local.yaml:"
  echo "\$ git check-ignore -v tiffinbox-local.yaml"
  if gi=$(git -C .harness/git check-ignore -v tiffinbox-local.yaml); then printf '%s\n' "$gi" | awk '{ gsub(/\t/, "   "); print }'; else echo "(not ignored)"; fi
  echo "\$ git status --porcelain --ignored"
  git -C .harness/git status --porcelain --ignored; }
cap change change

# ---- group: no profile, then the group lunch --------------------------------------------------------------------------------------
group() {
  echo "no profile"; stack 'java -cp "$AFTER" com.tiffinbox.harness.Stack tiffinbox.cooks --tiffinbox.port=18701'
  echo "lunch, the group"; stack 'java -cp "$AFTER" com.tiffinbox.harness.Stack tiffinbox.cooks --tiffinbox.port=18701 --spring.profiles.active=lunch'; }
cap group group

# ---- import: the developer's file, absent and present ----------------------------------------------------------------------------
imp() {
  echo "A   this folder: no tiffinbox-local.yaml"; stack 'java -cp "$AFTER" com.tiffinbox.harness.Stack tiffinbox.cooks --tiffinbox.port=18702'
  echo "B   local/: a tiffinbox-local.yaml, cooks: 4"; stack 'cd local && java -cp "$AFTER" com.tiffinbox.harness.Stack tiffinbox.cooks --tiffinbox.port=18702'
  echo "A′  A, re-run"; stack 'java -cp "$AFTER" com.tiffinbox.harness.Stack tiffinbox.cooks --tiffinbox.port=18702'; }
cap import imp

# ---- stack: all four sources at once, and the profiles named the other way round ---------------------------------------------------
stk() {
  echo "lunch, from local/: every source TiffinBox's configuration is composed from"
  stack 'cd local && java -cp "$AFTER" com.tiffinbox.harness.Stack tiffinbox.cooks --tiffinbox.port=18703 --spring.profiles.active=lunch'
  echo "the same two profiles, named the other way round: audit,rush"
  stack 'cd local && java -cp "$AFTER" com.tiffinbox.harness.Stack tiffinbox.cooks --tiffinbox.port=18703 --spring.profiles.active=audit,rush'; }
cap stack stk

# ---- break: a profile's name, misspelt -------------------------------------------------------------------------------------------
brk() {
  echo "A   lunch"; stack 'java -cp "$AFTER" com.tiffinbox.harness.Stack tiffinbox.cooks --tiffinbox.port=18704 --spring.profiles.active=lunch'
  echo "B   lnch: one letter missing"; stack 'java -cp "$AFTER" com.tiffinbox.harness.Stack tiffinbox.cooks --tiffinbox.port=18704 --spring.profiles.active=lnch'
  echo "A′  A, re-run"; stack 'java -cp "$AFTER" com.tiffinbox.harness.Stack tiffinbox.cooks --tiffinbox.port=18704 --spring.profiles.active=lunch'; }
cap break brk

# ---- loud: two mistakes that stop the start, and one that waits ----------------------------------------------------------------------
loud() {
  echo "required/: the import without optional:, and no tiffinbox-local.yaml in this folder"
  stack 'java -cp "required:$AFTER" com.tiffinbox.harness.Stack tiffinbox.cooks --tiffinbox.port=18705'
  echo "inprofile/: spring.profiles.active inside the audit's own file, lunch on"
  stack 'java -cp "inprofile:$AFTER" com.tiffinbox.harness.Stack tiffinbox.cooks --tiffinbox.port=18705 --spring.profiles.active=lunch'
  echo "the same inprofile/ file, no profile"
  stack 'java -cp "inprofile:$AFTER" com.tiffinbox.harness.Stack tiffinbox.cooks --tiffinbox.port=18705'; }
cap loud loud

# ---- serve: after/'s jar, in after/tiffinbox-web/target -----------------------------------------------------------------------------
serve() { local T="$AT/tiffinbox-web/target"
  startjar "$T" 'java -jar tiffinbox-web-1.0.0.jar --tiffinbox.port=18700'; seven 18700
  echo "  TiffinBox's log: $(said .harness/jar.log 'meal types:') · Boot: $(profiles .harness/jar.log)"
  echo "the anchor README's logging command:"
  startjar "$T" 'java -jar tiffinbox-web-1.0.0.jar --tiffinbox.port=18700 --logging.level.tiffinbox=debug'; seven 18700
  echo "  route DEBUG lines $(routes .harness/jar.log)"
  echo "the lunch rush alone, as the anchor README gives it:"
  startjar "$T" 'java -jar tiffinbox-web-1.0.0.jar --tiffinbox.port=18700 --spring.profiles.active=rush'; seven 18700
  echo "  Boot: $(profiles .harness/jar.log) · route DEBUG lines $(routes .harness/jar.log)"
  echo "the group, as the anchor README now gives it:"
  startjar "$T" 'java -jar tiffinbox-web-1.0.0.jar --tiffinbox.port=18700 --spring.profiles.active=lunch'; seven 18700
  echo "  Boot: $(profiles .harness/jar.log) · route DEBUG lines $(routes .harness/jar.log)"; }
cap serve serve

# ---- files: every demo file, against the file it stands in for -------------------------------------------------------------------
files() {
  against() { if cmp -s "$1" "$2"; then echo "$2: $3, byte for byte"
              else echo "$2, against $3:"; diff "$1" "$2" | sed 's/^/  /' || true; fi; }
  against "$AT/$YAML" required/application.yaml "after/'s application.yaml"
  against "$AT/$AUDIT" inprofile/application-audit.yaml "after/'s application-audit.yaml"
  echo "local/tiffinbox-local.yaml, whole - after/ has no such file (its .gitignore keeps one out of git):"; whole local/tiffinbox-local.yaml; }
cap files files

echo
# ---- every number the video says, asserted. Each check reads a line a program computed - never a label this script prints
# ---- unconditionally - and names the words it pays for. (The "$ ..." command lines are echoes of what ran: the published
# ---- md5 pins them, and no check pretends to test them.)
x() { grep -qE -- "$2" ".r-$1.out" || die "$1: expected /$2/"; }
blk() { awk -v a="$2" -v b="$3" 'index($0, a) == 1 { f = 1; next } b != "" && index($0, b) == 1 { f = 0 } f' ".r-$1.out"; }
has1() { printf '%s\n' "$1" | grep -qxF -- "$2" || die "$3: expected the line: $2"; }     # an exact line inside a block
cnt() { printf '%s\n' "$1" | grep -cE -- "$2" || true; }                                 # lines of a block matching a pattern
row() { printf '%s\n' "$1" | grep -E "^ +[0-9]+ $2" | head -1 | awk '{ print $1 }'; }   # a source's position in a stack
S_AUDIT="Config resource 'class path resource \[application-audit\.yaml\]' via location 'optional:classpath:/'"
S_DOC1="Config resource 'class path resource \[application\.yaml\]' via location 'optional:classpath:/' \(document #1\)"
S_DOC0="Config resource 'class path resource \[application\.yaml\]' via location 'optional:classpath:/' \(document #0\)"
S_LOCAL="Config resource 'file \[tiffinbox-local\.yaml\]' via location 'optional:file:\./tiffinbox-local\.yaml'"

# "Rush already lives in application dot yaml, as a second document. Audit gets a file of its own, with one key: TiffinBox's
# logging, at debug. And a profile group, lunch, is one name for both." · "Application dot yaml imports tiffinbox-local dot yaml
# ... and marks it optional" · "git ignores that file, so it stays out of the repository" · the anchor change: one file
# changed, two new
x change '^files, README aside: the previous tree 16 · after/ 18 · in both 16: identical 15, changed 1$'
x change '^  only before: \(none\)$'; x change '^  only after:  \.gitignore tiffinbox-web/src/main/resources/application-audit\.yaml$'
CY=$(blk change 'application.yaml, every changed line' 'new: ')
[ "$(printf '%s\n' "$CY" | paste -sd'|' -)" = '+spring:|+  profiles:|+    group:|+      lunch: rush,audit|+  config:|+    import: optional:file:./tiffinbox-local.yaml' ] \
  || die "change: application.yaml gains the group and the optional import, nothing else"
CA=$(blk change 'new: tiffinbox-web/src/main/resources/application-audit.yaml, whole' 'a throwaway')
[ "$(printf '%s\n' "$CA" | grep -v '^ *[0-9]* | #' | paste -sd'|' -)" = '  3 | logging:|  4 |   level:|  5 |     tiffinbox: debug' ] || die "change: the audit's file holds one key, logging.level.tiffinbox: debug"
x change '^  2 \| tiffinbox-local\.yaml$'
x change '^\.gitignore:2:tiffinbox-local\.yaml   tiffinbox-local\.yaml$'; x change '^!! tiffinbox-local\.yaml$'
echo "  change: 16 -> 18 files (application.yaml: the group lunch: rush,audit and the optional import; new: application-audit.yaml, one key; .gitignore); git ignores tiffinbox-local.yaml"

# "One flag, lunch, and Boot's own line says three profiles are active: lunch, rush and audit. Six cooks, from the rush
# document. And five route lines at debug." · "Boot had already read the audit's file before refresh"
G0=$(blk group 'no profile' 'lunch, the group'); G1=$(blk group 'lunch, the group' '')
has1 "$G0" 'exit 0 · WARN lines 0 · ERROR lines 0 · route DEBUG lines 0 · Boot: No active profile set, falling back to 1 default profile: "default"' group
has1 "$G1" 'exit 0 · WARN lines 0 · ERROR lines 0 · route DEBUG lines 5 · Boot: The following 3 profiles are active: "lunch", "rush", "audit"' group
has1 "$G1" 'active profiles: [lunch, rush, audit]' group
has1 "$G1" 'before refresh: 9 property sources · one from application-audit.yaml among them: true · after refresh: 9, the same list in the same order: true' group
printf '%s\n' "$G1" | grep -qE "^KEY tiffinbox\.cooks -> WINNER 6 · from source 7 of 9, $S_DOC1$" || die "group: lunch's winner must be 6, from the rush document"
has1 "$G1" "the bean's own field: OrderQueue.cooks = 6" group
echo "  group: lunch -> 3 profiles (lunch, rush, audit), WINNER 6 from document #1, route DEBUG lines 0 -> 5, the audit's file in the environment before refresh"

# "A: no file here. Exit zero, three cooks, and no source for it at all." · "B: the same command, from a folder that has the
# file. Four cooks. The import sits directly above the file that imported it, so it wins. A again: three."
IA=$(blk import 'A   ' 'B   '); IB=$(blk import 'B   ' 'A′  '); IA2=$(blk import 'A′  ' '')
has1 "$IA" 'exit 0 · WARN lines 0 · ERROR lines 0 · route DEBUG lines 0 · Boot: No active profile set, falling back to 1 default profile: "default"' import
printf '%s\n' "$IA" | grep -q "the working folder's tiffinbox-local.yaml: absent$" || die "import: A runs where no local file is"
printf '%s\n' "$IA" | grep -qE "^KEY tiffinbox\.cooks -> WINNER 3 · from source 6 of 7, $S_DOC0$" || die "import: A's winner must be 3, from the base document"
[ "$(cnt "$IA" "^ +[0-9]+ $S_LOCAL")" = 0 ] || die "import: A must hold no source for the local file"
printf '%s\n' "$IB" | grep -q "the working folder's tiffinbox-local.yaml: present$" || die "import: B runs where the local file is"
printf '%s\n' "$IB" | grep -qE "^KEY tiffinbox\.cooks -> WINNER 4 · from source 6 of 8, $S_LOCAL$" || die "import: B's winner must be 4, from the local file"
[ "$(row "$IB" "$S_LOCAL 4 ")" = 6 ] && [ "$(row "$IB" "$S_DOC0 3 ")" = 7 ] || die "import: the local file must sit directly above application.yaml's document #0"
[ "$IA" = "$IA2" ] || die "import: A' is not A, line for line"
echo "  import: A absent -> 3, 7 sources, none for the file · B present -> 4, source 6, directly above document #0 (7) · A' = A"

# "This is the stack ...: every property source, in the order Boot asks them ... Of the four, the audit's own file ranks
# first. Then the rush document, then your local file, then the base document. The first that holds cooks answers: six, from the rush. Your four
# loses." · "All four at once" · "Swap it: audit, then rush. The same stack, row for row. Here, a profile's own file ranks
# above both documents in application dot yaml, whichever order you type."
K1=$(blk stack 'lunch, from local/' 'the same two profiles'); K2=$(blk stack 'the same two profiles' '')
printf '%s\n' "$K1" | grep -qE "^KEY tiffinbox\.cooks -> WINNER 6 · from source 7 of 10, $S_DOC1$" || die "stack: lunch with the local file must answer 6, from the rush document"
[ "$(cnt "$K1" '^ +[0-9]+ ')" = 10 ] && [ "$(cnt "$K1" '^ +[0-9]+ Config resource ')" = 4 ] || die "stack: every one of the 10 sources printed, 4 of them config files"
[ "$(row "$K1" "$S_AUDIT -$")" = 6 ] && [ "$(row "$K1" "$S_DOC1 6 ")" = 7 ] && [ "$(row "$K1" "$S_LOCAL 4 ")" = 8 ] && [ "$(row "$K1" "$S_DOC0 3 ")" = 9 ] \
  || die "stack: the order must be the audit's file 6, the rush document 7 (6), the local file 8 (4), the base document 9 (3)"
has1 "$K1" "the bean's own field: OrderQueue.cooks = 6" stack
has1 "$K2" 'exit 0 · WARN lines 0 · ERROR lines 0 · route DEBUG lines 5 · Boot: The following 2 profiles are active: "audit", "rush"' stack
[ "$(printf '%s\n' "$K1" | sed -n '/^KEY /,/^the bean/p')" = "$(printf '%s\n' "$K2" | sed -n '/^KEY /,/^the bean/p')" ] || die "stack: audit,rush must give the same stack, row for row"
echo "  stack: 10 sources, 4 config files: audit's file 6 > rush document 7 > local file 8 > base document 9; WINNER 6 · audit,rush: the same rows"

# "A: lunch. Six cooks, five route lines." · "B: one letter missing ... Exit zero, zero warnings. Boot's own line lists it as
# active, the name you typed, and nothing is composed for it: three cooks from the base document, zero route lines. A again:
# six."
BA=$(blk break 'A   ' 'B   '); BB=$(blk break 'B   ' 'A′  '); BA2=$(blk break 'A′  ' '')
has1 "$BA" 'exit 0 · WARN lines 0 · ERROR lines 0 · route DEBUG lines 5 · Boot: The following 3 profiles are active: "lunch", "rush", "audit"' break
printf '%s\n' "$BA" | grep -qE "^KEY tiffinbox\.cooks -> WINNER 6 · from source 7 of 9, $S_DOC1$" || die "break: A must answer 6"
has1 "$BB" 'exit 0 · WARN lines 0 · ERROR lines 0 · route DEBUG lines 0 · Boot: The following 1 profile is active: "lnch"' break
has1 "$BB" 'active profiles: [lnch]' break
printf '%s\n' "$BB" | grep -qE "^KEY tiffinbox\.cooks -> WINNER 3 · from source 6 of 7, $S_DOC0$" || die "break: B must answer 3, from the base document"
[ "$(cnt "$BB" '^ +[0-9]+ Config resource ')" = 1 ] || die "break: B composes nothing for lnch - one config source, the base document"
has1 "$BB" "the bean's own field: OrderQueue.cooks = 3" break
[ "$BA" = "$BA2" ] || die "break: A' is not A, line for line"
echo "  break: A lunch 6, 5 route lines · B lnch exit 0, 0 WARN, \"lnch\" active, 1 config source, 3, 0 route lines · A' = A"

# "Take optional off the import, with no file in the folder: exit one, before the banner even prints. The report points at the
# import's line and says it: prefix it with optional." · "Put profiles active inside the audit's file and start lunch: exit
# one, naming the file, line eight, column thirteen. Start with no profile and it runs, because that file is never read."
L1=$(blk loud 'required/' 'inprofile/'); L2=$(blk loud 'inprofile/' 'the same inprofile/'); L3=$(blk loud 'the same inprofile/' '')
has1 "$L1" '  exit 1 · WARN lines 0 · ERROR lines 1 · banner lines 0 · listening lines 0' loud
printf '%s\n' "$L1" | grep -q '^  the class path gives: application.yaml <- required/application.yaml · ' || die "loud: the first run must read required/application.yaml"
has1 "$L1" "  Config data resource 'file [tiffinbox-local.yaml]' via location 'file:./tiffinbox-local.yaml' does not exist" loud
has1 "$L1" "  Check that the value 'file:./tiffinbox-local.yaml' at class path resource [application.yaml] - 21:13 is correct, or prefix it with 'optional:'" loud
has1 "$L2" '  exit 1 · WARN lines 0 · ERROR lines 1 · banner lines 0 · listening lines 0' loud
has1 "$L2" "  org.springframework.boot.context.config.InvalidConfigDataPropertyException: Property 'spring.profiles.active' imported from location 'class path resource [application-audit.yaml]' is invalid in a profile specific resource [origin: class path resource [application-audit.yaml] - 8:13]" loud
has1 "$L3" 'exit 0 · WARN lines 0 · ERROR lines 0 · route DEBUG lines 0 · Boot: No active profile set, falling back to 1 default profile: "default"' loud
printf '%s\n' "$L3" | grep -q ' · one from application-audit.yaml among them: false · ' || die "loud: with no profile, the audit's file is never read"
printf '%s\n' "$L3" | grep -q '^the class path gives: .* · application-audit.yaml <- inprofile/application-audit.yaml · ' || die "loud: the third run must still have inprofile/'s file on its class path"
[ "$(blk files 'required/application.yaml, against' 'inprofile/' | paste -sd'|' -)" = '  21c21|  <     import: optional:file:./tiffinbox-local.yaml|  ---|  >     import: file:./tiffinbox-local.yaml' ] \
  || die "files: required/ must drop optional: from the import line alone"
[ "$(blk files 'inprofile/application-audit.yaml, against' 'local/' | paste -sd'|' -)" = '  5a6,8|  > spring:|  >   profiles:|  >     active: rush' ] \
  || die "files: inprofile/ must add spring.profiles.active: rush (line 8), nothing else"
x files '^  3 \|   cooks: 4$'
echo "  loud: without optional: exit 1, 0 banner, the Action names 21:13 and 'optional:' · profiles.active in the audit's file: exit 1, 0 banner, 8:13 · no profile: exit 0, the file never read"

# "the last course's seven requests" are not spoken here; the anchor's commands still serve the same seven responses
[ "$(grep -c '^  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891$' .r-serve.out)" = 4 ] || die "serve: the seven responses must hash to 115c36ba..., all four runs"
x serve '^  TiffinBox.s log: meal types:     \[VEG, NON_VEG, VEGAN\] · '; x serve '^  route DEBUG lines 5$'
x serve '^  Boot: The following 1 profile is active: "rush" · route DEBUG lines 0$'
x serve '^  Boot: The following 3 profiles are active: "lunch", "rush", "audit" · route DEBUG lines 5$'
echo "  serve: the seven responses 115c36ba... (plain, logging, rush, lunch); the list's log line"

[ -z "$unpub" ] || die "no published hash for:$unpub - check the captures, then copy the md5s above into receipts.md5 and run again"
echo "c5-unit10: every capture 3/3 and = published; every spoken number asserted"
