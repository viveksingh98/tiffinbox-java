#!/bin/bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25.0.4.1 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# Course 5 · Secrets: What Not to Commit — this unit's receipts. Until now anyone who could reach TiffinBox's port could stop
# it: POST /shutdown asked for nothing. This unit gives TiffinBox a secret with a job - tiffinbox.shutdown-token, required,
# asked for in an X-Shutdown-Token header - imported from a config tree (optional:configtree:./secrets/, the second import
# in application.yaml's list), with its length rule written so that a failure report cannot print it (the anchor change).
# Then where a secret must never live, where it can, who can read it there, and the one place nobody looks. Nine captures,
# each run three times and hashed; cap() DIES when a hash differs from receipts.md5; every number the video says is
# asserted at the bottom by a check that can fail - and no capture holds a demo token: each is masked (gsub), and the last
# checks count 0 raw copies in every capture.
#   change   the previous tree against after/, file by file: every changed code line; what git makes of secrets/ and
#            tiffinbox-local.yaml under after/'s .gitignore (in a throwaway repository)
#   door     after/'s jar, the token in a config tree: Course 4's seven requests (no header) · this unit's (the header)
#   required after/'s jar, no token anywhere
#   git      the anti-pattern, in a throwaway repository under .harness/: commit the token, delete it, look again
#   where    the token on the command line, in either environment spelling, in a config tree: ps, ps eww, POST /shutdown
#   ranks    the harness: the token's stack with lunch on and a token in tiffinbox-local.yaml AND in the config tree
#   break    the length rule on the token itself (sized/, a copy of after/): A 26 characters · B 15 · A' = A ·
#            C after/ as shipped (the rule a yes-or-no method), 15
#   serve    after/'s jar: this unit's seven, plain and with the anchor README's logging, rush and lunch commands; the token
#            counted in every run's whole output
#   files    every demo file against the file it stands in for (diff)
# "before" is ../c5-unit10/after (the anchor as the last unit left it), COPIED to .harness/before: its files are compared,
# never run, and this script never writes into another unit's folder. after/ is this unit's frozen copy of ../c5-tiffinbox
# after the change, built in place, clean; .harness/sized is a copy of it with one file swapped (sized/), built clean.
# Every run starts in a folder under .harness/ that this script makes: application.yaml's two imports look in the folder
# TiffinBox starts in (./tiffinbox-local.yaml, ./secrets/). empty/ holds neither · tree/ a config tree with the 26-character
# token · short/ one with the 15-character token · both/ a config tree AND a tiffinbox-local.yaml, each with a token.
# Commands are printed exactly as they run: each goes through eval, so "$TOKEN" and "$AFTER" (the harness's classes plus
# after/'s jars, written to .harness/after.classpath) expand only when it runs - the printed line never holds a token.
# Masks and filters (README.md declares each; sub/gsub only): the three demo tokens become "[masked: the N-character token]"
# and this folder's absolute path becomes "…", in every line of every capture (gsub); Boot's timestamped log lines are
# dropped from a harness report and counted, and so are the lines between the harness's first line and its report (the
# banner); a failed start shows Boot's failure report without its blank lines and its rows of asterisks, the rest counted;
# a log line's level and logger are read off it (match), its time and pid never printed; ps eww's output is cut to its
# words that start TIFFINBOX_ (the rest is this shell's environment); git runs with a fixed author, committer and date and
# without your configuration, so its hashes are the same on every run.
# Ports (brief ⚑11, 18710-18719): door 18710 · required 18711 (never binds) · where 18712 · ranks 18713 · break 18714 (B and C
# never bind) · serve 18715 · the exercise 18719.
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
[ -e secrets ] && die "this folder holds a secrets/ - remove it: every run here starts in a folder under .harness/"
M2="$PWD/.m2-demo"; U="$PWD"
REC=tiffinbox-core/src/main/java/com/tiffinbox/TiffinBoxProperties.java
YAML=tiffinbox-web/src/main/resources/application.yaml
TF=secrets/tiffinbox/shutdown-token                  # the config tree's file for tiffinbox.shutdown-token
# The demo tokens. FAKE, and meant to look it: they guard nothing but a demo server on 127.0.0.1 that every capture stops.
# They are written into files under .harness/ (git-ignored) when this script runs, and no capture prints one: see mask().
TOKEN=not-a-real-token-demo-only                     # 26 characters: TiffinBox's token in every run that starts
SHORT=kitchen-door-42                                # 15 characters: one short of the length rule (break)
LOCAL=a-plain-file-token-22c                         # 22 characters: a developer's token in tiffinbox-local.yaml (ranks)
[ ${#TOKEN} = 26 ] && [ ${#SHORT} = 15 ] && [ ${#LOCAL} = 22 ] || die "the demo tokens must be 26, 15 and 22 characters"

# ---- build: after/, clean, and sized/'s copy of it, clean; the previous tree is only copied (its files are read, never run) ---
rm -rf .harness; mkdir -p .harness
rsync -a --exclude target ../c5-unit10/after/ .harness/before/
rsync -a --exclude target after/ .harness/sized/; cp sized/TiffinBoxProperties.java ".harness/sized/$REC"
BT=.harness/before; AT=after
build() { (cd "$1" && { mvn -o -q -B -Dmaven.repo.local="$M2" -DskipTests clean package > /dev/null 2>&1 \
                        || mvn -q -B -Dmaven.repo.local="$M2" -DskipTests clean package; }) || die "build failed: $1"; }
build "$AT"; build .harness/sized
jars() { echo "$PWD/$1/tiffinbox-web/target/tiffinbox-web-1.0.0.jar:$(ls "$PWD/$1"/tiffinbox-web/target/lib/*.jar | paste -sd: -)"; }
javac -parameters -cp "$(jars "$AT")" -d .harness/classes harness/com/tiffinbox/harness/*.java || die "the harness did not compile"
AFTER="$PWD/.harness/classes:$(jars "$AT")"
printf '%s\n' "$AFTER" > .harness/after.classpath

# ---- the folders the runs start in -------------------------------------------------------------------------------------------
# tree FOLDER TOKEN: a config tree in FOLDER/secrets holding one file, the token and a newline, readable by its owner alone
tree() { mkdir -p "$1/secrets/tiffinbox"; (umask 077 && printf '%s\n' "$2" > "$1/$TF"); chmod 700 "$1/secrets" "$1/secrets/tiffinbox"; }
mkdir -p .harness/empty
tree .harness/tree "$TOKEN"; tree .harness/short "$SHORT"; tree .harness/both "$TOKEN"
# a developer's own file, as an editor saves it under the usual umask (022): a plain file, with a token in it
(umask 022 && printf 'tiffinbox:\n  shutdown-token: %s\n' "$LOCAL" > .harness/both/tiffinbox-local.yaml)

listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
for p in 18425 18710 18711 18712 18713 18714 18715; do
  [ "$(listeners $p)" = 0 ] || die "something already listens on $p - this unit's ports must be free"; done

# raw TOKEN FILE...: how many times TOKEN appears, raw, in the files (occurrences, not lines)
raw() { local t=$1; shift; cat "$@" | grep -oF -- "$t" | wc -l | tr -d ' '; }
warns() { echo "WARN lines $(grep -c ' WARN ' "$1" || true) · ERROR lines $(grep -c ' ERROR ' "$1" || true)"; }
routes() { grep -c 'route [A-Z]* /' "$1" || true; }
# said FILE MESSAGE: the first log line whose message starts with MESSAGE, its prefix (time, level, pid, thread, logger) cut
# by sub() - or "(no such line)"
said() { awk -v m="$2" '{ s = $0; sub(/^[0-9][0-9][0-9][0-9]-[^ ]* +[A-Z]+ [0-9]+ --- \[[^]]*\] [^:]* : /, "", s) } index(s, m) == 1 { print s; f = 1; exit } END { if (!f) print "(no such line)" }' "$1"; }
# reporter FILE: the level and the logger of the line that logs Boot's failure report, read off it by match() - its time and
# pid never printed
reporter() { awk '/ o\.s\.b\.d\.LoggingFailureAnalysisReporter / { if (match($0, / [A-Z]+ [0-9]+ --- /)) { l = substr($0, RSTART + 1, RLENGTH - 1); sub(/ .*/, "", l) }
  print "logged at " l " by o.s.b.d.LoggingFailureAnalysisReporter"; f = 1; exit } END { if (!f) print "(no such line)" }' "$1"; }
# stat FILE: its permissions, its size in bytes, its name
st() { stat -f '%Sp %z bytes %N' "$1"; }

# runf 'COMMAND': print it exactly as typed, run it in the foreground (eval, in a subshell, from this folder), its standard
# output to .harness/run.out and its standard error to .harness/run.err; its exit code in $ec
runf() { echo "\$ $1"; ec=0; (eval "$1") > .harness/run.out 2> .harness/run.err < /dev/null || ec=$?; }
# a failed start: how far it got (exit, WARN/ERROR, banner and listening lines), each stream's size, then Boot's own failure
# report without its blank lines and its rows of asterisks, and the count of the run's lines not shown
failed() { local o=$1 e=$2 n
  echo "  exit $ec · $(warns "$o") · banner lines $(grep -c ':: Spring Boot ::' "$o" || true) · listening lines $(grep -c 'TiffinBox listening on' "$o" || true)"
  echo "  standard output $(wc -l < "$o" | tr -d ' ') lines · standard error $(wc -l < "$e" | tr -d ' ') lines · the report: $(reporter "$o")"
  awk '/^APPLICATION FAILED TO START$/ { f = 1 } f && !/^[*]+$/ && !/^[[:space:]]*$/ { print "  " $0 }' "$o" > .harness/fail.txt
  [ -s .harness/fail.txt ] || echo "  (no failure report)" > .harness/fail.txt
  cat .harness/fail.txt
  n=$(( $(cat "$o" "$e" | wc -l) - $(grep -c . .harness/fail.txt) ))
  echo "  … $n more line(s) of this run's output not shown: the banner, Boot's log, the blank lines and the stack frames …"; }

# startjar 'COMMAND': print it exactly as typed, run it in the background (eval, from this folder; exec, so $pid is java's
# own pid), its standard output to .harness/jar.out and its standard error to .harness/jar.err
startjar() { echo "\$ $1"; (eval "${1/java -jar/exec java -jar}") > .harness/jar.out 2> .harness/jar.err < /dev/null & pid=$!; }
# listening: what the operating system says the process listens on (lsof), once it listens - or "nothing" once it exited
listening() { local a="" i=0
  while [ $i -lt 120 ]; do
    a=$(lsof -nP -a -p "$pid" -iTCP -sTCP:LISTEN 2> /dev/null | awk 'NR > 1 { print $9 }' | sort -u | paste -sd' ' -)
    [ -n "$a" ] && break; kill -0 "$pid" 2> /dev/null || break; sleep 0.25; i=$((i + 1)); done
  echo "${a:-nothing}"; }
# seven PORT TOKENFILE: this unit's seven requests (POST /shutdown carries the header, read from TOKENFILE), printed as run;
# the JVM must leave within 15 s of them, and the port must be free again. Never call it inside $(...): wait needs this shell.
seven() { local i
  echo "\$ ./curlset.sh $1 $2"
  ./curlset.sh "$1" "$2" | grep ' -> ' > .harness/responses.txt || true
  grep '^POST ' .harness/responses.txt || echo "(no POST line)"
  i=0; while kill -0 "$pid" 2> /dev/null && [ $i -lt 60 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$pid" 2> /dev/null && { kill "$pid"; die "the server on $1 was still running 15 s after POST /shutdown"; }
  e=0; wait "$pid" || e=$?
  [ "$(listeners "$1")" = 0 ] || die "something still listens on $1"
  echo "  exit $e · the seven responses: $(wc -l < .harness/responses.txt | tr -d ' ') lines · md5 $(md5 -q .harness/responses.txt)"; }
# up: the line after a start - where it listens, and its WARN/ERROR lines so far; dies if it never listened
up() { local l; l=$(listening); [ "$l" != nothing ] || { cat .harness/jar.out >&3; die "it never listened"; }
  echo "  listens on: $l · $(warns .harness/jar.out)"; }
# tokens T: this run's whole output (both streams), the raw token counted
tokens() { echo "  the token, raw, in this run's whole output: $(raw "$1" .harness/jar.out .harness/jar.err) (standard output $(wc -l < .harness/jar.out | tr -d ' ') lines · standard error $(wc -l < .harness/jar.err | tr -d ' ') lines)"; }

# mask: every demo token becomes a label naming its length, and this folder's absolute path becomes "…" - in every line (gsub)
mask() { awk -v t="$TOKEN" -v s="$SHORT" -v l="$LOCAL" -v u="$U" '
  function lit(x) { gsub(/[][\\.^$*+?(){}|\/]/, "\\\\&", x); return x }
  BEGIN { T = lit(t); S = lit(s); L = lit(l); P = lit(u) }
  { gsub(T, "[masked: the 26-character token]"); gsub(S, "[masked: the 15-character token]")
    gsub(L, "[masked: the 22-character token]"); gsub(P, "…"); print }'; }

unpub=""
cap() { local nm=$1 h pub i; shift
  for i in 1 2 3; do "$@" > .harness/cap.raw 2>&1 || true; mask < .harness/cap.raw > ".r-$nm.$i"; done
  h=$(md5 -q ".r-$nm.1")
  [ "$h" = "$(md5 -q ".r-$nm.2")" ] && [ "$h" = "$(md5 -q ".r-$nm.3")" ] || die "$nm drifts across three runs (diff .r-$nm.1 .r-$nm.2 .r-$nm.3)"
  mv ".r-$nm.1" ".r-$nm.out"; rm -f ".r-$nm.2" ".r-$nm.3"
  pub=$(awk -v n="$nm" '$1 == n { print $2 }' receipts.md5 2> /dev/null || true)
  if [ -z "$pub" ]; then printf '  %-8s md5 %s  3/3  (no published hash)\n' "$nm" "$h"; unpub="$unpub $nm"
  elif [ "$pub" = "$h" ]; then printf '  %-8s md5 %s  3/3  = published\n' "$nm" "$h"
  else printf '  %-8s md5 %s  3/3  DIFFERS from the published %s\n' "$nm" "$h" "$pub"
    die "$nm is not the published capture - suspect another JDK, Boot or Maven, a busy port, a variable of yours, or an edited source; diff .r-$nm.out against its block in README.md"; fi; }

# ---- change: the previous tree against after/, file by file (README aside) --------------------------------------------------
# code FILE: its code lines - blank lines and comments dropped (Java: /* */ blocks and lines starting * or //; YAML and
# .gitignore: lines starting #)
code() { local j=0; case "$1" in *.java) j=1;; esac; awk -v java="$j" '
  { t = $0; sub(/^[ \t]+/, "", t) }
  inc { if (index(t, "*/")) inc = 0; next }
  java && index(t, "/*") == 1 { if (!index(t, "*/")) inc = 1; next }
  java && (index(t, "//") == 1 || index(t, "*") == 1) { next }
  !java && index(t, "#") == 1 { next }
  t == "" { next }
  { print }' "$1"; }
pm() { git diff --no-index --no-color -U0 "$1" "$2" | grep -E '^[-+]' | grep -vE '^(---|\+\+\+) ' || true; }   # changed lines, +/-
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
  rm -rf .harness/git; mkdir -p .harness/git/secrets/tiffinbox; cp "$AT/.gitignore" .harness/git/
  : > .harness/git/tiffinbox-local.yaml; : > ".harness/git/$TF"
  git -C .harness/git init -q
  echo "a throwaway git repository holding after/.gitignore, an empty tiffinbox-local.yaml and an empty $TF:"
  echo "\$ git check-ignore -v $TF tiffinbox-local.yaml"
  if gi=$(git -C .harness/git check-ignore -v "$TF" tiffinbox-local.yaml); then printf '%s\n' "$gi" | awk '{ gsub(/\t/, "   "); print }'; else echo "(not ignored)"; fi
  echo "\$ git status --porcelain --ignored"
  git -C .harness/git status --porcelain --ignored; }
cap change change

# ---- door: the secret with a job - Course 4's seven requests, then this unit's -----------------------------------------------
door() {
  echo "the token, in a config tree in tree/: $(cd .harness/tree && st "$TF")"
  startjar 'cd .harness/tree && java -jar ../../after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18710'; up
  echo "Course 4's seven requests, as they stand - no header:"
  echo "\$ ../c4-unit31/curlset.sh 18710"
  ../c4-unit31/curlset.sh 18710 | grep ' -> ' > .harness/c4.txt || true
  grep '^POST ' .harness/c4.txt || echo "(no POST line)"
  echo "  the seven responses: $(wc -l < .harness/c4.txt | tr -d ' ') lines · md5 $(md5 -q .harness/c4.txt)"
  sleep 2
  echo "  2 s after that POST /shutdown: the JVM $(kill -0 "$pid" 2> /dev/null && echo 'is still running' || echo 'has exited') · listening on 18710: $(listeners 18710) process(es)"
  echo "this unit's seven requests - the same seven, the last one with the token in its header, read from the tree's file:"
  seven 18710 ".harness/tree/$TF"
  echo "  the first six responses of the two sets: $(head -6 .harness/c4.txt | cmp -s - <(head -6 .harness/responses.txt) && echo identical || echo DIFFERENT)"
  tokens "$TOKEN"; }
cap door door

# ---- required: no token anywhere ----------------------------------------------------------------------------------------------
required() {
  echo "empty/ holds $(ls -A .harness/empty | wc -l | tr -d ' ') file(s) · TIFFINBOX_ variables in this script's environment: $(env | grep -c '^TIFFINBOX_' || true)"
  runf 'cd .harness/empty && java -jar ../../after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18711'
  failed .harness/run.out .harness/run.err; }
cap required required

# ---- git: the anti-pattern, in a throwaway repository -----------------------------------------------------------------------------
gitdemo() { local c
  rm -rf .harness/gitdemo; mkdir -p .harness/gitdemo
  echo "a throwaway repository of its own, in .harness/gitdemo (which this repository ignores):"
  for c in 'git init -q -b main' \
           "printf 'tiffinbox:\\n  cooks: 3\\n' > application.yaml && git add application.yaml && git commit -q -m 'config'" \
           "printf '  shutdown-token: %s\\n' \"\$TOKEN\" >> application.yaml && git commit -q -am 'make it start'" \
           "sed -i '' '/shutdown-token/d' application.yaml && git commit -q -am 'remove the token'" \
           'git log --oneline' \
           'git grep -c "$TOKEN" HEAD; echo "exit $?"' \
           'grep -c "$TOKEN" application.yaml; echo "exit $?"' \
           'git log -S "$TOKEN" --oneline' \
           'git show HEAD~1:application.yaml'; do
    echo "\$ $c"
    (cd .harness/gitdemo && export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1 GIT_AUTHOR_NAME=demo \
      GIT_AUTHOR_EMAIL=demo@example.invalid GIT_COMMITTER_NAME=demo GIT_COMMITTER_EMAIL=demo@example.invalid \
      GIT_AUTHOR_DATE='2026-09-30T12:00:00+0000' GIT_COMMITTER_DATE='2026-09-30T12:00:00+0000' && eval "$c") 2>&1 || true; done
  echo "commits in the history: $(git -C .harness/gitdemo rev-list --count HEAD) · commits git log -S names: $(git -C .harness/gitdemo log -S "$TOKEN" --oneline | wc -l | tr -d ' ') · the token, raw, in HEAD's files: $(git -C .harness/gitdemo grep -oF "$TOKEN" HEAD | wc -l | tr -d ' ') · in HEAD~1's application.yaml: $(git -C .harness/gitdemo show HEAD~1:application.yaml | grep -oF "$TOKEN" | wc -l | tr -d ' ')"; }
cap git gitdemo

# ---- where: three places the token can come from, and who can read it there ------------------------------------------------------
# where1 LABEL NAME 'COMMAND': start it; what ps prints of the process, without and with its environment; this unit's seven;
# one row for the table (NAME, the two counts, POST's status)
where1() { local pc pe env
  echo "$1"; startjar "$3"; up
  ps -o command= -p "$pid" > .harness/ps.txt; ps eww -o command= -p "$pid" > .harness/pse.txt
  pc=$(raw "$TOKEN" .harness/ps.txt); pe=$(raw "$TOKEN" .harness/pse.txt)
  echo '  $ ps -o command= -p "$pid"'; sed 's/^/  /' .harness/ps.txt
  echo '  $ ps eww -o command= -p "$pid"     (its words that start TIFFINBOX_)'
  env=$(tr ' ' '\n' < .harness/pse.txt | grep '^TIFFINBOX_' || true); printf '%s\n' "${env:-(none)}" | sed 's/^/  /'
  seven 18712 ".harness/tree/$TF"
  post=$(grep '^POST ' .harness/responses.txt | awk '{ print $4 }')
  printf '%s\n' "$2|$pc|$pe|$post" >> .harness/where.tab; }
where() { rm -f .harness/where.tab
  where1 "the command line" "the command line" 'cd .harness/empty && java -jar ../../after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18712 --tiffinbox.shutdown-token="$TOKEN"'
  where1 "an environment variable" "TIFFINBOX_SHUTDOWNTOKEN" 'cd .harness/empty && TIFFINBOX_SHUTDOWNTOKEN="$TOKEN" java -jar ../../after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18712'
  where1 "the same variable, the other spelling" "TIFFINBOX_SHUTDOWN_TOKEN" 'cd .harness/empty && TIFFINBOX_SHUTDOWN_TOKEN="$TOKEN" java -jar ../../after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18712'
  where1 "a config tree: secrets/tiffinbox/shutdown-token, in the folder TiffinBox starts in" "a config tree" 'cd .harness/tree && java -jar ../../after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18712'
  echo "the config tree's file:"
  echo "  $(cd .harness/tree && st "$TF") · its folders: $(cd .harness/tree && stat -f '%Sp %N' secrets secrets/tiffinbox | paste -sd' ' -) · its last byte: $(tail -c 1 ".harness/tree/$TF" | od -An -c | tr -d ' ')"
  echo "  the token: $(printf '%s' "$TOKEN" | wc -c | tr -d ' ') characters · the header curlset.sh sends: the file's first line, $(IFS= read -r t < ".harness/tree/$TF"; printf '%s' "$t" | wc -c | tr -d ' ') characters"
  echo "who printed the token, raw:"
  printf '  %-26s %-15s %-8s %s\n' "the token was in" "ps -o command=" "ps eww" "POST /shutdown, the header from the tree's file"
  awk -F'|' '{ printf "  %-26s %-15s %-8s %s\n", $1, $2, $3, $4 }' .harness/where.tab; }
cap where where

# ---- ranks: the token's stack - two imports, and the profiles above them ------------------------------------------------------------
# report: the harness's own lines - its first line (the folder), then everything from "active profiles: " on. Boot's timestamped
# log lines are dropped everywhere, and the other lines before the report (the banner) too - both counted.
report() { awk '
  /^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T[0-9][0-9]:/ { n++; next }
  NR == 1 && index($0, "the working folder: ") == 1 { print; next }
  !f && index($0, "active profiles: ") == 1 { f = 1 }
  f { print; next }
  { m++ }
  END { printf "… elided: %d log line(s) of Boot'"'"'s, and %d line(s) printed before the report (the banner and its blank lines) …\n", n, m }' .harness/run.out; }
ranks() {
  echo "both/: $(cd .harness/both && st "$TF") · $(cd .harness/both && st tiffinbox-local.yaml)"
  echo "  tiffinbox-local.yaml, whole:"; awk '{ printf "  %3d | %s\n", NR, $0 }' .harness/both/tiffinbox-local.yaml
  runf 'cd .harness/both && java -cp "$AFTER" com.tiffinbox.harness.Token --tiffinbox.port=18713 --spring.profiles.active=lunch'
  echo "exit $ec · $(warns .harness/run.out) · Boot: $(said .harness/run.out 'The following ')"; report
  [ "$(listeners 18713)" = 0 ] || die "something still listens on 18713"; }
cap ranks ranks

# ---- break: the leak nobody expects -------------------------------------------------------------------------------------------------
# a start that serves: the token file, the start, this unit's seven, the token counted
okrun() { echo "  the token's file: $(cd "$1" && st "$TF")"; startjar "$2"; up; seven 18714 ".harness/tree/$TF"; tokens "$TOKEN"; }
# a start that fails: the token file, the run, the token counted, Boot's report
badrun() { echo "  the token's file: $(cd "$1" && st "$TF")"; runf "$2"; failed .harness/run.out .harness/run.err
  echo "  the token, raw, in this run's whole output: $(raw "$SHORT" .harness/run.out .harness/run.err) · on standard output $(raw "$SHORT" .harness/run.out) · on standard error $(raw "$SHORT" .harness/run.err)"; }
brk() {
  echo "A   26 characters · sized/: a copy of after/ whose length rule is @Size(min = 16) on the token itself"
  okrun .harness/tree 'cd .harness/tree && java -jar ../sized/tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18714'
  echo "B   15 characters · the same jar"
  badrun .harness/short 'cd .harness/short && java -jar ../sized/tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18714'
  echo "A′  A, re-run"
  okrun .harness/tree 'cd .harness/tree && java -jar ../sized/tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18714'
  echo "C   15 characters · after/, as shipped: the length rule is a yes-or-no method, isShutdownTokenLongEnough()"
  badrun .harness/short 'cd .harness/short && java -jar ../../after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18714'
  [ "$(listeners 18714)" = 0 ] || die "something still listens on 18714"; }
cap break brk

# ---- serve: after/'s jar, the anchor README's commands, from tree/ --------------------------------------------------------------------
serve1() { echo "$1"; startjar "$2"; up; seven 18715 ".harness/tree/$TF"
  echo "  Boot: $(said .harness/jar.out 'The following ' | grep -v '^(no such line)$' || said .harness/jar.out 'No active profile set') · route DEBUG lines $(routes .harness/jar.out)"
  tokens "$TOKEN"; }
# gone PORT: the JVM must leave within 15 s, and the port must be free again; its exit code
gone() { local i=0 e=0
  while kill -0 "$pid" 2> /dev/null && [ $i -lt 60 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$pid" 2> /dev/null && { kill "$pid"; die "the server on $1 was still running 15 s after POST /shutdown"; }
  wait "$pid" || e=$?
  [ "$(listeners "$1")" = 0 ] || die "something still listens on $1"
  echo "  exit $e"; }
# the anchor README's commands, on this unit's port, in a fresh folder: the token made as the README makes it (random - never
# printed, so the capture holds nothing that depends on it), TiffinBox started, POST /shutdown without and with the header
anchor() { local tok
  rm -rf .harness/anchor; mkdir -p .harness/anchor
  echo "the anchor README's commands, on this unit's port, in a fresh folder, anchor/ - its token random, as the README makes it"
  runf "cd .harness/anchor && mkdir -p secrets/tiffinbox && (umask 077 && printf '%s\\n' \"\$(openssl rand -hex 16)\" > secrets/tiffinbox/shutdown-token)"
  echo "  exit $ec · $(cd .harness/anchor && st "$TF") · printed: $(cat .harness/run.out .harness/run.err | wc -l | tr -d ' ') line(s)"
  tok=$(head -n 1 ".harness/anchor/$TF")
  startjar 'cd .harness/anchor && java -jar ../../after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18715'; up
  runf "curl -s -w ' %{http_code}\\n' -X POST http://127.0.0.1:18715/shutdown"; cat .harness/run.out
  sleep 1; echo "  1 s later: the JVM $(kill -0 "$pid" 2> /dev/null && echo 'is still running' || echo 'has exited')"
  runf "cd .harness/anchor && { printf 'X-Shutdown-Token: '; head -n 1 secrets/tiffinbox/shutdown-token; } | curl -s -w ' %{http_code}\\n' -H @- -X POST http://127.0.0.1:18715/shutdown"
  cat .harness/run.out; gone 18715
  echo "  the token, raw, in this run's whole output: $(raw "$tok" .harness/jar.out .harness/jar.err)"; }
serve() {
  anchor
  serve1 "plain" 'cd .harness/tree && java -jar ../../after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18715'
  serve1 "the anchor README's logging command" 'cd .harness/tree && java -jar ../../after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18715 --logging.level.tiffinbox=debug'
  serve1 "the lunch rush alone" 'cd .harness/tree && java -jar ../../after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18715 --spring.profiles.active=rush'
  serve1 "the group, lunch: the audit's logging at debug" 'cd .harness/tree && java -jar ../../after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18715 --spring.profiles.active=lunch'; }
cap serve serve

# ---- files: every demo file, against the file it stands in for -------------------------------------------------------------------
files() {
  against() { if cmp -s "$1" "$2"; then echo "$2: $3, byte for byte"
              else echo "$2, against $3:"; diff "$1" "$2" | sed 's/^/  /' || true; fi; }
  against "$AT/$REC" sized/TiffinBoxProperties.java "after/'s TiffinBoxProperties.java"
  against ../c4-unit31/curlset.sh curlset.sh "../c4-unit31/curlset.sh"; }
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
M26='[masked: the 26-character token]'; M15='[masked: the 15-character token]'; M22='[masked: the 22-character token]'
S115='115c36bac276128e245ca57df11c2891'

# THE TOKENS: no capture holds a demo token, raw - and neither does anything this unit ships for reading
for f in .r-*.out README.md exercise/README.md exercise/solution/SOLUTION.md receipts.md5; do
  [ -f "$f" ] || continue
  for t in "$TOKEN" "$SHORT" "$LOCAL"; do [ "$(raw "$t" "$f")" = 0 ] || die "$f holds a demo token, raw"; done; done
echo "  tokens: 0 raw copies of the three demo tokens in $(ls .r-*.out | wc -l | tr -d ' ') captures, README.md, the exercise and receipts.md5"

# "the route now wants it in a header ... four-oh-three without it" · the anchor change: four files changed
x change '^files, README aside: the previous tree 18 · after/ 18 · in both 18: identical 14, changed 4$'
x change '^  only before: \(none\)$'; x change '^  only after:  \(none\)$'
CR=$(blk change 'TiffinBoxProperties.java, every changed line' 'TiffinBoxServer.java, ')
CG=$(blk change '.gitignore, every changed line' 'TiffinBoxProperties.java, ')
has1 "$CR" '+                                  @NotBlank String shutdownToken) {' change
has1 "$CR" '+    @AssertTrue(message = "tiffinbox.shutdown-token must be 16 characters or more")' change
CS=$(blk change 'TiffinBoxServer.java, every changed line' 'application.yaml, ')
has1 "$CS" '+        if (key.equals("POST /shutdown") && !holdsToken(exchange)) {   // the server keeps running' change
has1 "$CS" '+            respond(exchange, 403, ordered("error", "forbidden"));' change
has1 "$CS" '+        return sent != null && MessageDigest.isEqual(sent.getBytes(StandardCharsets.UTF_8), shutdownToken);' change
CY=$(blk change 'application.yaml, every changed line' 'a throwaway')
[ "$(printf '%s\n' "$CY" | paste -sd'|' -)" = '-    import: optional:file:./tiffinbox-local.yaml|+    import:|+      - optional:file:./tiffinbox-local.yaml|+      - optional:configtree:./secrets/' ] \
  || die "change: application.yaml's import becomes a list of two: the local file, then the config tree - nothing else"
[ "$(printf '%s\n' "$CG" | paste -sd'|' -)" = '+secrets/' ] || die "change: .gitignore gains secrets/, nothing else"
x change '^\.gitignore:4:secrets/   secrets/tiffinbox/shutdown-token$'; x change '^!! secrets/$'; x change '^!! tiffinbox-local\.yaml$'
echo "  change: 4 files changed (the record: the token, @NotBlank, the length rule a method; the server: 403; application.yaml: two imports; .gitignore: secrets/); git ignores secrets/"

# "Course four's seven requests ... the last one gets four-oh-three, and the server is still running. The same seven, with
# the token in the header: two hundred ... and the server stops."
x door '^  listens on: 127\.0\.0\.1:18710 · WARN lines 0 · ERROR lines 0$'
[ "$(grep -c '^POST  /shutdown   -> 403 application/json  {"error":"forbidden"}$' .r-door.out)" = 1 ] || die "door: without the header, POST /shutdown answers 403"
x door '^  the seven responses: 7 lines · md5 11bbc19ca107097dfd6477aa7fb0246b$'
x door '^  2 s after that POST /shutdown: the JVM is still running · listening on 18710: 1 process\(es\)$'
[ "$(grep -c '^POST  /shutdown   -> 200 application/json  {"stopping":true}$' .r-door.out)" = 1 ] || die "door: with the header, POST /shutdown answers 200"
x door "^  exit 0 · the seven responses: 7 lines · md5 $S115\$"
x door '^  the first six responses of the two sets: identical$'
x door '^  the token, raw, in this run.s whole output: 0 '
echo "  door: no header -> 403, 11bbc19c..., still running · the header -> 200, 115c36ba..., exit 0 · the token 0 times in the log"

# "no token anywhere: exit one, before the port opens. Boot's report names the key and says must not be blank"
RQ=$(cat .r-required.out)
has1 "$RQ" '  exit 1 · WARN lines 1 · ERROR lines 1 · banner lines 1 · listening lines 0' required
has1 "$RQ" '      Property: tiffinbox.shutdownToken' required; has1 "$RQ" '      Value: "null"' required
has1 "$RQ" '      Reason: must not be blank' required
x required '^empty/ holds 0 file\(s\) · TIFFINBOX_ variables in this script.s environment: 0$'
echo "  required: no token -> exit 1, 0 listening, tiffinbox.shutdownToken \"null\" must not be blank"

# "A throwaway repository: commit the token to make it start, delete it in the next commit. HEAD holds it zero times. git log
# dash S finds two commits ... git show prints the old file, token and all."
x git '^commits in the history: 3 · commits git log -S names: 2 · the token, raw, in HEAD.s files: 0 · in HEAD~1.s application\.yaml: 1$'
GS=$(blk git '$ git log -S "$TOKEN" --oneline' '$ git show')
[ "$(cnt "$GS" '^[0-9a-f]{7} ')" = 2 ] && [ "$(cnt "$GS" ' (make it start|remove the token)$')" = 2 ] || die "git: git log -S lists the two commits"
has1 "$(blk git '$ git show HEAD~1:application.yaml' 'commits in')" "  shutdown-token: $M26" git
has1 "$(blk git '$ git grep -c "$TOKEN" HEAD; echo "exit $?"' '$ grep')" 'exit 1' git
echo "  git: 3 commits; HEAD 0; git log -S 2 commits; git show HEAD~1 prints it (masked here)"

# "On the command line, ps prints it ... In an environment variable, plain ps doesn't, but ps with the e flag does ... Both
# spellings bind ... In a config tree ... Neither ps shows it. The file holds twenty-seven bytes ... twenty-six characters ...
# Boot trims the newline." (each place's POST /shutdown with the tree's token answers 200: the token each run bound IS it)
WT=$(blk where 'who printed the token, raw:' '')
has1 "$WT" '  the command line           1               1        200' where
has1 "$WT" '  TIFFINBOX_SHUTDOWNTOKEN    0               1        200' where
has1 "$WT" '  TIFFINBOX_SHUTDOWN_TOKEN   0               1        200' where
has1 "$WT" '  a config tree              0               0        200' where
x where "--tiffinbox\.shutdown-token=\[masked: the 26-character token\]$"
x where '^  TIFFINBOX_SHUTDOWNTOKEN=\[masked: the 26-character token\]$'; x where '^  TIFFINBOX_SHUTDOWN_TOKEN=\[masked: the 26-character token\]$'
x where '^  -rw------- 27 bytes secrets/tiffinbox/shutdown-token · its folders: drwx------ secrets drwx------ secrets/tiffinbox · its last byte: \\n$'
x where '^  the token: 26 characters · the header curlset.sh sends: the file.s first line, 26 characters$'
[ "$(grep -c "^  exit 0 · the seven responses: 7 lines · md5 $S115\$" .r-where.out)" = 4 ] || die "where: every place's seven must hash to 115c36ba..."
echo "  where: command line ps 1 / eww 1 · env (both spellings) 0 / 1 · config tree 0 / 0, -rw------- 27 bytes, 26 characters bound · every one 200"

# "application dot yaml now imports two places: your local file, then a folder called secrets ... The later import ranks
# higher: with a token in each, the secrets folder answers." (and the local file is a plain file)
S_TREE="Config tree '…/\.harness/both/\./secrets'"
S_LOC="Config resource 'file \[tiffinbox-local\.yaml\]' via location 'optional:file:\./tiffinbox-local\.yaml'"
S_AUD="Config resource 'class path resource \[application-audit\.yaml\]' via location 'optional:classpath:/'"
S_DOC1="Config resource 'class path resource \[application\.yaml\]' via location 'optional:classpath:/' \(document #1\)"
S_DOC0="Config resource 'class path resource \[application\.yaml\]' via location 'optional:classpath:/' \(document #0\)"
RK=$(cat .r-ranks.out)
has1 "$RK" 'exit 0 · WARN lines 0 · ERROR lines 0 · Boot: The following 3 profiles are active: "lunch", "rush", "audit"' ranks
printf '%s\n' "$RK" | grep -qE "^KEY tiffinbox\.shutdown-token -> WINNER \(26 characters\) · from source 8 of 11, $S_TREE$" || die "ranks: the config tree's token answers, from source 8 of 11"
[ "$(row "$RK" "$S_AUD -$")" = 6 ] && [ "$(row "$RK" "$S_DOC1 -$")" = 7 ] && [ "$(row "$RK" "$S_TREE \(26 characters\) ")" = 8 ] \
  && [ "$(row "$RK" "$S_LOC \(22 characters\) ")" = 9 ] && [ "$(row "$RK" "$S_DOC0 -$")" = 10 ] \
  || die "ranks: the order must be the audit's file 6, the rush document 7, the config tree 8 (26), the local file 9 (22), the base document 10"
has1 "$RK" "the record's token: (26 characters)" ranks
x ranks '^both/: -rw------- 27 bytes secrets/tiffinbox/shutdown-token · -rw-r--r-- 52 bytes tiffinbox-local\.yaml$'
x ranks "^    2 \|   shutdown-token: \[masked: the 22-character token\]$"
echo "  ranks: audit's file 6 > rush document 7 > config tree 8 (26, WINNER) > local file 9 (22, -rw-r--r--) > base document 10"

# "A: twenty-six characters, from the config tree: it starts. B: fifteen. Exit one, and Boot's report prints the token,
# whole, with the file it came from ... at error level ... A again: it starts." · "C ... the same fifteen characters: exit
# one, and the report prints false. The token appears zero times."
BA=$(blk break 'A   ' 'B   '); BB=$(blk break 'B   ' 'A′  '); BA2=$(blk break 'A′  ' 'C   '); BC=$(blk break 'C   ' '')
has1 "$BA" '  the token'"'"'s file: -rw------- 27 bytes secrets/tiffinbox/shutdown-token' break
has1 "$BA" "  exit 0 · the seven responses: 7 lines · md5 $S115" break
printf '%s\n' "$BA" | grep -q '^  the token, raw, in this run.s whole output: 0 ' || die "break: A prints no token"
[ "$BA" = "$BA2" ] || die "break: A' is not A, line for line"
has1 "$BB" '  the token'"'"'s file: -rw------- 16 bytes secrets/tiffinbox/shutdown-token' break
has1 "$BB" '  the token, raw, in this run'"'"'s whole output: 1 · on standard output 1 · on standard error 0' break
printf '%s\n' "$BB" | grep -qE '^  exit 1 · WARN lines 1 · ERROR lines 1 · banner lines 1 · listening lines 0$' || die "break: B exits 1, before listening"
printf '%s\n' "$BB" | grep -qE '^  standard output [0-9]+ lines · standard error 0 lines · the report: logged at ERROR by o\.s\.b\.d\.LoggingFailureAnalysisReporter$' || die "break: B's report is logged at ERROR, on standard output"
has1 "$BB" '      Property: tiffinbox.shutdownToken' break; has1 "$BB" "      Value: \"$M15\"" break
has1 "$BB" '      Origin: file […/.harness/short/./secrets/tiffinbox/shutdown-token] - 1:1' break
has1 "$BB" '      Reason: size must be between 16 and 2147483647' break
has1 "$BC" '  the token, raw, in this run'"'"'s whole output: 0 · on standard output 0 · on standard error 0' break
printf '%s\n' "$BC" | grep -qE '^  exit 1 · WARN lines 1 · ERROR lines 1 · banner lines 1 · listening lines 0$' || die "break: C exits 1, before listening"
has1 "$BC" '      Property: tiffinbox.shutdownTokenLongEnough' break; has1 "$BC" '      Value: "false"' break
has1 "$BC" '      Reason: tiffinbox.shutdown-token must be 16 characters or more' break
[ "$(cnt "$BC" '^      Origin: ')" = 0 ] || die "break: C's report names no file"
echo "  break: A 26 starts, 0 · B 15 exit 1, the report prints it (1, stdout, ERROR), with its file · A' = A · C after/ exit 1, Value \"false\", 0"

# "With lunch on, the audit turns TiffinBox's logging to debug: five route lines, and the token zero times."
[ "$(grep -c "^  exit 0 · the seven responses: 7 lines · md5 $S115\$" .r-serve.out)" = 4 ] || die "serve: the seven responses must hash to 115c36ba..., all four runs"
[ "$(grep -c '^  the token, raw, in this run.s whole output: 0 ' .r-serve.out)" = 4 ] || die "serve: no run's output may hold the token"
x serve '^  Boot: The following 3 profiles are active: "lunch", "rush", "audit" · route DEBUG lines 5$'
x serve '^  Boot: No active profile set, falling back to 1 default profile: "default" · route DEBUG lines 5$'
AN=$(blk serve "the anchor README's commands" 'plain')
has1 "$AN" '  exit 0 · -rw------- 33 bytes secrets/tiffinbox/shutdown-token · printed: 0 line(s)' serve
has1 "$AN" '{"error":"forbidden"} 403' serve; has1 "$AN" '  1 s later: the JVM is still running' serve
has1 "$AN" '{"stopping":true} 200' serve; has1 "$AN" '  exit 0' serve
has1 "$AN" "  the token, raw, in this run's whole output: 0" serve
echo "  serve: the seven 115c36ba... (plain, logging, rush, lunch); lunch: 5 route DEBUG lines, the token 0 times"

# the demo files: sized/ differs from after/'s record in the length rule alone; curlset.sh from Course 4's in the POST alone
FS=$(blk files 'sized/TiffinBoxProperties.java, against' 'curlset.sh, against')
[ "$(cnt "$FS" '^  [<>] ')" = 14 ] && printf '%s\n' "$FS" | grep -qxF '  >                                   @NotBlank @Size(min = 16) String shutdownToken) {' || die "files: sized/ swaps the length rule, nothing else"
FC=$(blk files 'curlset.sh, against' '')
printf '%s\n' "$FC" | grep -qxF '  < req POST /shutdown' && [ "$(cnt "$FC" '^  > [^#]')" = 3 ] || die "files: curlset.sh changes the POST alone (and its comment)"
echo "  files: sized/ swaps the length rule; curlset.sh changes the POST alone"

[ -z "$unpub" ] || die "no published hash for:$unpub - check the captures, then copy the md5s above into receipts.md5 and run again"
echo "c5-unit11: every capture 3/3 and = published; every spoken number asserted; 0 raw demo tokens in every capture"
