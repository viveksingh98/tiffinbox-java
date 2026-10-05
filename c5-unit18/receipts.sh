#!/bin/bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25.0.4.1 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
set -e
cd "$(dirname "$0")"
# Course 5 · Virtual Threads in Boot - this unit's receipts. TiffinBox has run on virtual threads since the Core Java II
# capstone: its own code builds three executors that hand out virtual threads. Boot has one switch for them,
# spring.threads.virtual.enabled. This unit changes NOTHING in TiffinBox (brief ⚑7): it measures what the switch reaches
# and what stays exactly as it was. Five captures, each run three times and hashed; cap() DIES when a hash differs from
# receipts.md5; every number the video says is asserted at the bottom by a check that can fail; the demo token is masked
# (gsub) and the last checks count 0 raw copies in every capture.
#   own      TiffinBox's own threads, by grep, in a copy of the frozen tree: three executors, all virtual; one platform
#            thread, started to stop the server; no file that asks Spring for a thread
#   decides  the switch in Boot's own metadata (its default), then TiffinBox's own jar with --debug (the conditions
#            evaluation report): A the switch not set · B on · A' = A - the two bean methods that build the bean named
#            applicationTaskExecutor, the condition that picks one, and the seven responses
#   switch   the harness (harness/threads/VThreads.java) on TiffinBox's context: A not set · B on · A' = A - Boot's
#            executor and twenty tasks, Boot's scheduler and two jobs, TiffinBox's own executors read through private fields
#   alive    TiffinBox's own jar, A not set · B on: the Java threads a thread dump lists as not daemons; Boot's metadata for
#            spring.main.keep-alive; the seven responses
#   exercise exercise/README.md's commands, run exactly as written, then the solution's (exercise/solution/SOLUTION.md)
# "The frozen tree" is ../c5-unit13/after (TiffinBox as the executable-jar lesson left it - the anchor today), COPIED to
# .harness/after and built there, clean: this script never writes into another unit's folder. Every run starts in
# .harness/after, which holds a config tree with the demo token (secrets/), as the frozen tree's README asks: TiffinBox does
# not start without its token. The harness's class path comes from the frozen tree's own jar: the README's extract command,
# run as written in .harness/after, and the README's class-path command with the harness's classes in front.
# Commands are printed exactly as they run: each goes through eval. "$CURLSET" is the comparison set since the secrets
# lesson (../c5-unit11/curlset.sh: the seven requests, POST /shutdown with the token's header read from the file).
# Masks and filters (README.md declares each; sub/gsub only): the demo token becomes "[masked: the 26-character token]", this
# folder's absolute path "…", the folder above it "…/..", and the home folder "~", in every line of every capture (gsub).
# Nothing else varies: thread names are printed as a sorted set (which job ran on which thread moves from run to run, and is
# never printed), thread ids and PIDs never. Boot's log is counted, never printed whole: the report shows the blocks of the
# two applicationTaskExecutor methods, javap the two methods' signatures and annotations, the thread dump the names of the
# Java threads that are not daemons and the dispatcher's own frame.
# Ports (brief ⚑10, 18890-18899): decides A and A' 18890, B 18891 · switch A and A' 18892, B 18893 · alive A 18894, B 18895 ·
# the exercise 18899 (its README's own port). 18896-18898 unused. 18425 is checked free too: it is TiffinBox's default.

# One run at a time: two runs share .harness/ and the ports, and one would corrupt the other.
mkdir .r-lock 2> /dev/null || { echo "  *** another receipts.sh is running in this folder (.r-lock exists) - if none is, rmdir .r-lock ***"; exit 1; }
# On every exit - the end, a failed check, or Ctrl-C - stop the JVM this script started in the background, if it still
# runs, and drop the lock. A background job of a non-interactive shell ignores the terminal's Ctrl-C, so without the kill
# an interrupted run would leave TiffinBox listening. $pid is cleared whenever the JVM has been reaped. The clean-up ignores
# a second Ctrl-C, and nothing in it can fail under set -e (a JVM stopped by SIGTERM exits 143), so it always reaches the
# rmdir; the script still exits 130 after an interrupt (tested: README.md, "Interrupted").
pid=""
trap 'trap "" INT TERM; if [ -n "$pid" ] && kill "$pid" 2> /dev/null; then wait "$pid" 2> /dev/null || true; fi; rmdir .r-lock 2> /dev/null || true' EXIT
trap 'exit 130' INT TERM
exec 3>&1                                            # die() speaks to the terminal even inside a redirected capture
die() { echo "  *** $* ***" >&3; exit 1; }
java -version 2>&1 | grep -q 'version "25' || die "JDK 25 needed; JAVA_HOME gives: $(java -version 2>&1 | head -1)"
command -v jcmd > /dev/null && jcmd -h 2>&1 | grep -q . || die "jcmd (the JDK's own) is needed"
command -v openssl > /dev/null || die "openssl is needed: the exercise's README makes its own token with it"
# A variable of yours must not become a property source: every TIFFINBOX_* and SPRING_* variable, and the two variables
# that inject JVM flags, are removed from this script's environment before anything runs. MAVEN_OPTS and MAVEN_ARGS too.
for v in $(env | sed -n 's/^\(TIFFINBOX_[A-Za-z0-9_]*\|SPRING_[A-Za-z0-9_]*\|JAVA_TOOL_OPTIONS\|JDK_JAVA_OPTIONS\|MAVEN_OPTS\|MAVEN_ARGS\)=.*/\1/p'); do unset "$v"; done
[ -e secrets ] && die "this folder holds a secrets/ - remove it: every run here starts in .harness/after"
M2="$PWD/.m2-demo"; U="$PWD"; UP="$(cd .. && pwd)"
FROZEN=../c5-unit13/after                            # the frozen tree: read, copied, never built in place
JAR=tiffinbox-web/target/tiffinbox-web-1.0.0.jar
TF=secrets/tiffinbox/shutdown-token                  # the config tree's file for tiffinbox.shutdown-token
# The demo token. FAKE, and meant to look it: it guards nothing but a demo server on 127.0.0.1 that every capture stops. It
# is written into .harness/after/secrets/ (git-ignored) when this script runs, and no capture prints it: see mask().
TOKEN=not-a-real-token-demo-only
[ ${#TOKEN} = 26 ] || die "the demo token must be 26 characters"
CURLSET=../c5-unit11/curlset.sh                      # the comparison set: the seven requests, POST /shutdown with the header
[ -f "$CURLSET" ] || die "$CURLSET is missing"
[ -f "$FROZEN/pom.xml" ] && [ -f "$FROZEN/README.md" ] || die "the frozen tree $FROZEN is missing"
[ -d "$M2/org/springframework/boot/spring-boot-starter-parent/4.1.1" ] || die ".m2-demo is missing or incomplete - README.md, The repository"

# The ports, BEFORE anything is wiped (a survivor of an interrupted run answers POST /shutdown only with its token, which
# lives in .harness/ - so the message names the process to kill).
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
for p in 18425 18890 18891 18892 18893 18894 18895 18896 18897 18898 18899; do
  [ "$(listeners $p)" = 0 ] || die "something already listens on $p - this unit's ports must be free; if it is a TiffinBox an interrupted run left behind, stop it: kill $(lsof -nP -iTCP:$p -sTCP:LISTEN -t 2> /dev/null | paste -sd' ' -)"; done

# ---- build: a copy of the frozen tree under .harness/, clean, offline ----------------------------------------------------
rm -rf .harness; mkdir -p .harness
rsync -a --exclude target "$FROZEN/" .harness/after/
# build DIR LOG: a clean build, offline first, its log kept in LOG (never printed whole); Maven Central only if the offline
# build could not resolve something - and the terminal says which (offline: yes / no), so a run that went online is never
# silent.
build() { local how=yes ec=0
  (cd "$1" && mvn -o -B -Dmaven.repo.local="$M2" -DskipTests clean package > "$U/$2" 2>&1) || ec=$?
  if [ $ec != 0 ] && grep -qE 'offline mode|Could not resolve|could not be resolved|Cannot access' "$2"; then
    how="no - the offline build could not resolve an artifact, so Maven Central was asked"; ec=0
    (cd "$1" && mvn -B -Dmaven.repo.local="$M2" -DskipTests clean package > "$U/$2" 2>&1) || ec=$?; fi
  [ $ec = 0 ] || { tail -30 "$2" >&3; die "build failed: $1"; }
  echo "  built $1 · offline: $how · exit $ec"; }
build .harness/after .harness/build-after.log

# The token's config tree, inside the copy, where the frozen tree's README puts it: one file, the token and a newline,
# readable by its owner alone.
mkdir -p .harness/after/secrets/tiffinbox; (umask 077 && printf '%s\n' "$TOKEN" > ".harness/after/$TF")
chmod 700 .harness/after/secrets .harness/after/secrets/tiffinbox

# readme PATTERN: the first line of the frozen tree's README (its copy) that matches PATTERN - so a label never claims what
# the README says
readme() { grep -m1 -E "$1" .harness/after/README.md || true; }
RUNCMD=$(readme '^java -jar tiffinbox-web/target/tiffinbox-web-1\.0\.0\.jar --tiffinbox\.port=18431$')
EXTRACT=$(readme '^java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1\.0\.0\.jar extract --destination [^ ]+$')
CPCMD=$(readme '^java -cp "[^"]+" com\.tiffinbox\.web\.TiffinBoxServer --tiffinbox\.port=18431$')
[ -n "$RUNCMD" ] && [ -n "$EXTRACT" ] && [ -n "$CPCMD" ] || die "the frozen tree's README no longer gives the run, extract and class-path commands"
XD=${EXTRACT##* }                                    # the README's extract destination, inside the copy's target/
RCP=$(printf '%s\n' "$CPCMD" | sed -n 's/^java -cp "\([^"]*\)" .*/\1/p')
# The harness's class path: the README's extract command, run as written in the copy, then the README's class path with the
# harness's classes in front. javac reads the same jars.
(cd .harness/after && eval "$EXTRACT") > .harness/extract.log 2>&1 || { cat .harness/extract.log >&3; die "the README's extract command failed"; }
javac -cp ".harness/after/$XD/tiffinbox-web-1.0.0.jar:.harness/after/$XD/lib/*" -d .harness/classes harness/threads/VThreads.java || die "the harness did not compile"
HCMD="java -cp \"../classes:$RCP\" threads.VThreads"   # run from .harness/after; the port and any flag follow
echo "  the harness: compiled against the frozen tree's own jar, extracted as its README says"

# raw TOKEN FILE...: how many times TOKEN appears, raw, in the files (occurrences, not lines)
raw() { local t=$1; shift; cat "$@" | grep -oF -- "$t" | wc -l | tr -d ' '; }
warns() { echo "WARN lines $(grep -c ' WARN ' "$1" || true) · ERROR lines $(grep -c ' ERROR ' "$1" || true)"; }
# start 'COMMAND': print it exactly as typed, run it in the background (eval, from this folder; exec, so $pid is java's own
# pid), its standard output to .harness/jar.out and its standard error to .harness/jar.err
start() { echo "\$ $1"; (eval "${1/ java / exec java }") > .harness/jar.out 2> .harness/jar.err < /dev/null & pid=$!; }
# listening: what the operating system says the process listens on (lsof), once it listens - or "nothing" once it exited
listening() { local a="" i=0
  while [ $i -lt 160 ]; do
    a=$(lsof -nP -a -p "$pid" -iTCP -sTCP:LISTEN 2> /dev/null | awk 'NR > 1 { print $9 }' | sort -u | paste -sd' ' -)
    [ -n "$a" ] && break; kill -0 "$pid" 2> /dev/null || break; sleep 0.25; i=$((i + 1)); done
  echo "${a:-nothing}"; }
# up: the line after a start - where it listens, and its WARN/ERROR lines so far; dies if it never listened
up() { local l; l=$(listening); [ "$l" != nothing ] || { tail -20 .harness/jar.out >&3; die "it never listened"; }
  echo "  listens on: $l · $(warns .harness/jar.out)"; }
# seven PORT: the comparison set's seven requests (POST /shutdown carries the header, read from the copy's token file),
# printed as run; the JVM must leave within 15 s of them, and the port must be free again. Never call it inside $(...):
# wait needs this shell.
seven() { local i e=0
  echo "\$ \$CURLSET $1 .harness/after/$TF"
  "$CURLSET" "$1" ".harness/after/$TF" | grep ' -> ' > .harness/responses.txt || true
  grep '^POST ' .harness/responses.txt || echo "(no POST line)"
  i=0; while kill -0 "$pid" 2> /dev/null && [ $i -lt 60 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$pid" 2> /dev/null && { kill "$pid"; die "the server on $1 was still running 15 s after POST /shutdown"; }
  wait "$pid" || e=$?; pid=""
  [ "$(listeners "$1")" = 0 ] || die "something still listens on $1"
  echo "  exit $e · the seven responses: $(wc -l < .harness/responses.txt | tr -d ' ') lines · md5 $(md5 -q .harness/responses.txt)"; }
# harness 'COMMAND' PORT: print the command exactly as typed, run it (in the background, so a hung run can be stopped: it
# must exit within 60 s), then print the harness's own lines - its standard error, whole - and count Boot's log (its
# standard output)
harness() { local i=0 e=0
  start "$1"
  while kill -0 "$pid" 2> /dev/null && [ $i -lt 240 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$pid" 2> /dev/null && { kill "$pid"; die "the harness was still running after 60 s: $1"; }
  wait "$pid" || e=$?; pid=""
  cat .harness/jar.err
  echo "  Boot's log (standard output): $(wc -l < .harness/jar.out | tr -d ' ') lines, not shown · $(warns .harness/jar.out) · exit $e · listening on $2 now: $(listeners "$2")"; }

# mask: the demo token becomes a label naming its length; this folder's path "…", the folder above it "…/..", the home
# folder "~" - in every line (gsub)
mask() { awk -v t="$TOKEN" -v u="$U" -v up="$UP" -v hm="$HOME" '
  function lit(x) { gsub(/[][\\.^$*+?(){}|\/]/, "\\\\&", x); return x }
  function enc(x) { gsub(/ /, "%20", x); return x }
  BEGIN { T = lit(t); P = lit(u); Q = lit(up); H = lit(hm); PE = lit(enc(u)); QE = lit(enc(up)) }
  { gsub(T, "[masked: the 26-character token]"); gsub(P, "…"); gsub(PE, "…"); gsub(Q, "…/.."); gsub(QE, "…/.."); gsub(H, "~"); print }'; }

unpub=""
cap() { local nm=$1 h pub i; shift
  for i in 1 2 3; do "$@" > .harness/cap.raw 2>&1 || true; [ -z "$pid" ] || die "$nm left a JVM running"
    raw "$TOKEN" .harness/cap.raw > ".harness/raw-$nm.$i"; mask < .harness/cap.raw > ".r-$nm.$i"; done
  h=$(md5 -q ".r-$nm.1")
  [ "$h" = "$(md5 -q ".r-$nm.2")" ] && [ "$h" = "$(md5 -q ".r-$nm.3")" ] || die "$nm drifts across three runs (diff .r-$nm.1 .r-$nm.2 .r-$nm.3)"
  mv ".r-$nm.1" ".r-$nm.out"; rm -f ".r-$nm.2" ".r-$nm.3"
  pub=$(awk -v n="$nm" '$1 == n { print $2 }' receipts.md5 2> /dev/null || true)
  if [ -z "$pub" ]; then printf '  %-9s md5 %s  3/3  (no published hash)\n' "$nm" "$h"; unpub="$unpub $nm"
  elif [ "$pub" = "$h" ]; then printf '  %-9s md5 %s  3/3  = published\n' "$nm" "$h"
  else printf '  %-9s md5 %s  3/3  DIFFERS from the published %s\n' "$nm" "$h" "$pub"
    die "$nm is not the published capture - suspect another JDK, Boot or Maven, a busy port, a variable of yours, or an edited source; diff .r-$nm.out against its block in README.md"; fi; }

# ---- own: the threads TiffinBox starts itself ---------------------------------------------------------------------------
own() {
  echo "TiffinBox as the executable-jar lesson froze it (the anchor today) - a copy, .harness/after, built clean:"
  echo "\$ cd .harness/after && grep -rno --include='*.java' 'Executors\.[A-Za-z]*()' ."
  (cd .harness/after && grep -rno --include='*.java' 'Executors\.[A-Za-z]*()' . | sort) | sed 's/^/  /'
  echo "  executors: $(cd .harness/after && grep -rno --include='*.java' 'Executors\.[A-Za-z]*()' . | wc -l | tr -d ' ') · each one newVirtualThreadPerTaskExecutor: $(cd .harness/after && grep -rno --include='*.java' 'Executors\.newVirtualThreadPerTaskExecutor()' . | wc -l | tr -d ' ')"
  echo "\$ cd .harness/after && grep -rnoE --include='*.java' 'Thread\.of[A-Za-z]*\(\)|new Thread\(' ."
  (cd .harness/after && grep -rnoE --include='*.java' 'Thread\.of[A-Za-z]*\(\)|new Thread\(' . | sort) | sed 's/^/  /' || true
  echo "  threads started by hand: $(cd .harness/after && grep -rnoE --include='*.java' 'Thread\.of[A-Za-z]*\(\)|new Thread\(' . | wc -l | tr -d ' ') · a platform thread among them: $(cd .harness/after && grep -rno --include='*.java' 'Thread\.ofPlatform()' . | wc -l | tr -d ' ')"
  echo "\$ cd .harness/after && grep -rlE --include='*.java' 'org\.springframework\.(scheduling|core\.task)|@Async|@Scheduled' ."
  echo "  files that name Spring's task or scheduling packages, @Async or @Scheduled: $(cd .harness/after && grep -rlE --include='*.java' 'org\.springframework\.(scheduling|core\.task)|@Async|@Scheduled' . | wc -l | tr -d ' ') · Java files searched: $(cd .harness/after && find . -name '*.java' -not -path '*/target/*' | wc -l | tr -d ' ')"; }
cap own own

# ---- decides: the switch, its default, and the condition that reads it ------------------------------------------------------
# meta KEY FIELD: that field of KEY's entry in Boot's own metadata files (META-INF/spring-configuration-metadata.json, in
# every jar the frozen tree's jar carries; pretty-printed, one field per line), as "JAR: VALUE", or "none"
meta() { local j out=""
  for j in .harness/after/"$XD"/lib/*.jar; do
    unzip -l "$j" META-INF/spring-configuration-metadata.json > /dev/null 2>&1 || continue
    out="$out$(unzip -p "$j" META-INF/spring-configuration-metadata.json | awk -v k="\"name\": \"$1\"," -v f="\"$2\": " -v jar="${j##*/}" '
      index($0, k) { e = 1; next }
      e && index($0, f) { s = substr($0, index($0, f) + length(f)); sub(/,$/, "", s); gsub(/"/, "", s); print jar ": " s; exit }
      e && /^    }/ { print jar ": none"; exit }')"
  done
  echo "${out:-not in any metadata file}"; }
# method LOG NAME: the report's block for the bean method NAME of TaskExecutorConfiguration - its header and every line
# below it up to the blank line that ends the block, whichever section (positive or negative matches) it sits in
method() { awk -v h="   TaskExecutorConfigurations.TaskExecutorConfiguration#$2" '
  index($0, h) == 1 && (substr($0, length(h) + 1, 1) == ":" || substr($0, length(h) + 1, 9) == " matched:") { f = 1; print; next }
  f && $0 == "" { f = 0 } f { print }' "$1"; }
# threading LOG: every OnThreadingCondition line of the report, each paired with the bean method whose block holds it;
# counted, with the bean methods the condition matched ("@ConditionalOnThreading found …"), sorted
threading() { local rows
  rows=$(awk '/^   [A-Za-z]/ { hdr = $1; sub(/:$/, "", hdr) } /\(OnThreadingCondition\)$/ { print hdr "\t" (index($0, "@ConditionalOnThreading found ") ? "found" : "not") }' "$1")
  echo "  OnThreadingCondition lines in the report: $(printf '%s\n' "$rows" | grep -c . || true) · each under a bean method of TaskExecutorConfigurations or TaskSchedulingConfigurations: $(printf '%s\n' "$rows" | grep -cE '^(TaskExecutorConfigurations|TaskSchedulingConfigurations)\.[A-Za-z]+#' || true)"
  echo "  bean methods it matched: $(printf '%s\n' "$rows" | grep -c "$(printf '\t')found\$" || true) · $(printf '%s\n' "$rows" | grep "$(printf '\t')found\$" | cut -f1 | sed 's/^.*#//' | sort | paste -sd' ' -)"; }
decides() { local run
  echo "the switch in Boot's own metadata (META-INF/spring-configuration-metadata.json, in the jars the frozen tree's jar carries):"
  echo "  spring.threads.virtual.enabled · in $(meta spring.threads.virtual.enabled type | sed 's/: .*//') · type $(meta spring.threads.virtual.enabled type | sed 's/^[^:]*: //') · defaultValue $(meta spring.threads.virtual.enabled defaultValue | sed 's/^[^:]*: //')"
  echo "  its description: $(meta spring.threads.virtual.enabled description | sed 's/^[^:]*: //')"
  echo "  properties in those metadata files with \"virtual\" in their name: $(for j in .harness/after/"$XD"/lib/*.jar; do unzip -p "$j" META-INF/spring-configuration-metadata.json 2> /dev/null | grep -oiE '"name": "[^"]*virtual[^"]*"' || true; done | sed 's/^"name": "//; s/"$//' | sort -u | awk '{ a[++n] = $0 } END { s = ""; for (i = 1; i <= n; i++) s = s " " a[i]; print n " ·" s }')"
  echo "the bean methods that build the bean named applicationTaskExecutor, read from Boot's class file (javap: each method's"
  echo "signature, packages cut, and the values of its @Bean and @ConditionalOnThreading; javap's other lines not shown):"
  echo "\$ cd .harness/after && javap -v -cp $XD/lib/spring-boot-autoconfigure-4.1.1.jar 'org.springframework.boot.autoconfigure.task.TaskExecutorConfigurations\$TaskExecutorConfiguration'"
  (cd .harness/after && javap -v -cp "$XD/lib/spring-boot-autoconfigure-4.1.1.jar" 'org.springframework.boot.autoconfigure.task.TaskExecutorConfigurations$TaskExecutorConfiguration') > .harness/javap.txt 2>&1
  awk 'function out() { if (m != "" && b != "") print "  " m " · @Bean(" b ") · @ConditionalOnThreading(" c ")"; m = ""; b = ""; c = "" }
    /^  [a-z][A-Za-z0-9_.$]* [A-Za-z0-9_]+\(.*\);$/ { out(); m = $0; sub(/^  /, "", m); sub(/;$/, "", m); gsub(/[a-z0-9_]+\./, "", m); next }
    /^        org\.springframework\.context\.annotation\.Bean\($/ { w = "b"; next }
    /^        org\.springframework\.boot\.autoconfigure\.condition\.ConditionalOnThreading\($/ { w = "c"; next }
    w != "" && /^          value=/ { v = $0; sub(/^          value=/, "", v); if (w == "b") b = v; else { sub(/^.*;\./, "", v); c = v }; w = ""; next }
    END { out() }' .harness/javap.txt
  echo "  javap printed $(wc -l < .harness/javap.txt | tr -d ' ') lines; the class's methods, its constructor aside: $(awk '/^  [a-z][A-Za-z0-9_.$]* [A-Za-z0-9_]+\(.*\);$/' .harness/javap.txt | wc -l | tr -d ' '), each one above"
  echo "the run command the frozen tree's README gives: $RUNCMD"
  for run in "A|18890|" "B|18891| --spring.threads.virtual.enabled=true" "A'|18890|"; do
    IFS='|' read -r lbl port flag <<< "$run"
    case $lbl in
      A) echo "A - the switch not set (Boot's default) · that command, from .harness/after, its port 18431 made 18890, --debug after it:" ;;
      B) echo "B - the same command, the switch on after --debug, port 18891:" ;;
      *) echo "A' - A re-run:" ;; esac
    start "cd .harness/after && ${RUNCMD/18431/$port} --debug$flag"; up; seven "$port"
    echo "  its log: $(wc -l < .harness/jar.out | tr -d ' ') lines · the report's blocks for the two bean methods named applicationTaskExecutor:"
    method .harness/jar.out applicationTaskExecutor; method .harness/jar.out applicationTaskExecutorVirtualThreads
    threading .harness/jar.out; done; }
cap decides decides

# ---- switch: what the switch reaches, and what it leaves alone ---------------------------------------------------------------
switch() { local run
  echo "the harness's class path, from the frozen tree's own jar - its README's extract command, run as written in .harness/after:"
  echo "\$ cd .harness/after && $EXTRACT"
  echo "  $XD: $(ls ".harness/after/$XD" | paste -sd' ' -) · lib/: $(ls ".harness/after/$XD/lib" | grep -c '\.jar$') jars"
  echo "the README's class-path command, the harness's classes (.harness/classes) in front, its main class threads.VThreads:"
  echo "  $CPCMD"
  for run in "A|18892|" "B|18893| --spring.threads.virtual.enabled=true" "A'|18892|"; do
    IFS='|' read -r lbl port flag <<< "$run"
    case $lbl in
      A) echo "A - the switch not set (Boot's default):" ;;
      B) echo "B - the switch on:" ;;
      *) echo "A' - A re-run:" ;; esac
    harness "cd .harness/after && $HCMD --tiffinbox.port=$port$flag" "$port"; done; }
cap switch switch

# ---- alive: what holds TiffinBox's JVM open --------------------------------------------------------------------------------
# nondaemon: jcmd's thread dump of $pid, taken once main has returned (the dump is polled until no thread is named "main":
# TiffinBox listens before main returns), reduced to the Java threads (a "#<number>" after the name) without the word
# daemon - their names, sorted, and how many. The rest of the dump (daemon threads, the JVM's own threads, every stack) is
# not shown: the daemon threads' count moves with the virtual threads' carriers.
nondaemon() { local i=0
  while [ $i -lt 40 ]; do jcmd "$pid" Thread.print > .harness/dump.txt 2>&1 || true
    grep -q '^"main" #' .harness/dump.txt || break; sleep 0.25; i=$((i + 1)); done
  grep -q '^"main" #' .harness/dump.txt && die "main never returned"
  echo "  Java threads that are not daemons: $(grep '^"' .harness/dump.txt | grep -E ' #[0-9]+ ' | grep -vc ' daemon ' || true) · $(grep '^"' .harness/dump.txt | grep -E ' #[0-9]+ ' | grep -v ' daemon ' | sed 's/^\("[^"]*"\).*/\1/' | sort | paste -sd' ' -)"
  echo "  \"HTTP-Dispatcher\", its frame from the JDK's HTTP server (version and line cut): $(awk '/^"HTTP-Dispatcher" #/ { f = 1; next } f && /^$/ { exit } f && /^\tat sun\.net\.httpserver\./ { s = $0; sub(/^\tat /, "", s); sub(/@[^\/]*\/[^)]*\)$/, ")", s); print s; exit }' .harness/dump.txt)"; }
alive() { local run
  echo "Boot's own metadata (META-INF/spring-configuration-metadata.json), its entry for spring.main.keep-alive:"
  echo "  spring.main.keep-alive · in $(meta spring.main.keep-alive defaultValue | sed 's/: .*//') · defaultValue $(meta spring.main.keep-alive defaultValue | sed 's/^[^:]*: //')"
  echo "  its description: $(meta spring.main.keep-alive description | sed 's/^[^:]*: //')"
  for run in "A|18894|" "B|18895| --spring.threads.virtual.enabled=true"; do
    IFS='|' read -r lbl port flag <<< "$run"
    case $lbl in
      A) echo "A - the switch not set · the frozen tree's run command, from .harness/after, its port 18431 made 18894:" ;;
      *) echo "B - the switch on, port 18895:" ;; esac
    start "cd .harness/after && ${RUNCMD/18431/$port}$flag"; up
    echo '$ jcmd "$pid" Thread.print     ($pid: the java process this script started)'
    nondaemon; seven "$port"; done; }
cap alive alive

# ---- exercise: the README's commands, exactly as written, then the solution's ---------------------------------------------
# block FILE: the lines of FILE's first ```bash block
block() { awk '/^```bash$/ { if (!d) { f = 1 }; next } f && /^```$/ { f = 0; d = 1 } f' "$1"; }
exercise() { local setup run sol
  setup=$(block exercise/README.md | grep -v ' java -cp ')
  run=$(block exercise/README.md | grep ' java -cp ')
  sol=$(grep -m1 -E '^cd \.harness/mine/after && SPRING_THREADS_VIRTUAL_ENABLED=true java -cp ' exercise/solution/SOLUTION.md || true)
  [ -n "$setup" ] && [ -n "$run" ] && [ -n "$sol" ] || die "exercise/README.md or SOLUTION.md no longer gives its commands"
  # The setup lines name the frozen tree's folder, which carries a unit number: they are counted here, never printed (they
  # are in exercise/README.md, and this script runs them exactly as written).
  echo "exercise/README.md's commands, run exactly as written from this folder:"
  echo "  its first $(printf '%s\n' "$setup" | grep -c .) lines - copy the frozen tree to .harness/mine/after, build it offline, extract its jar, compile the harness, write a token:"
  ec=0; (eval "$setup") > .harness/ex-setup.log 2>&1 < /dev/null || ec=$?
  [ $ec = 0 ] || { tail -20 .harness/ex-setup.log >&3; die "the exercise's setup failed"; }
  echo "  exit $ec · printed: $(grep -c . .harness/ex-setup.log || true) line(s) · the token: $(wc -c < .harness/mine/after/$TF | tr -d ' ') bytes, $(stat -f %Sp .harness/mine/after/$TF) · .harness/mine/classes: $(find .harness/mine/classes -name '*.class' | wc -l | tr -d ' ') classes"
  echo "  its last line:"
  harness "$run" 18899
  echo "the solution's command (exercise/solution/SOLUTION.md), run exactly as written:"
  harness "$sol" 18899; }
cap exercise exercise

echo
# ---- every number the video says, asserted. Each check reads a line a program computed - never a label this script prints
# ---- unconditionally - and names the words it pays for. (The "$ ..." command lines are echoes of what ran: the published
# ---- md5 pins them, and no check pretends to test them.)
x() { grep -qE -- "$2" ".r-$1.out" || die "$1: expected /$2/"; }
n() { grep -cE -- "$2" ".r-$1.out" || true; }                                            # how many lines match
blk() { awk -v a="$2" -v b="$3" 'index($0, a) == 1 { f = 1; next } b != "" && index($0, b) == 1 { f = 0 } f' ".r-$1.out"; }
S115='115c36bac276128e245ca57df11c2891'

# THE TOKEN: no capture holds the demo token, raw - counted on each run's own output BEFORE masking - and neither does
# anything this unit ships for reading
for f in .harness/raw-*; do [ "$(cat "$f")" = 0 ] || die "a capture's raw output held the demo token ($f)"; done
for f in .r-*.out README.md exercise/README.md exercise/solution/SOLUTION.md receipts.md5 harness/threads/VThreads.java aot-side/AotSwitch.java; do
  [ -f "$f" ] || continue; [ "$(raw "$TOKEN" "$f")" = 0 ] || die "$f holds the demo token, raw"; done
for f in .r-*.out; do ! grep -qE '/Users/|/private/|/home/' "$f" || die "$f holds an absolute path"; done
echo "  token: 0 raw copies in $(ls .harness/raw-* | wc -l | tr -d ' ') raw capture runs, in $(ls .r-*.out | wc -l | tr -d ' ') captures, the READMEs, the harness and receipts.md5; no absolute path in any capture"
# "TiffinBox's code builds three executors ... All three hand out virtual threads. And no file asks Spring for a thread."
x own '^  executors: 3 · each one newVirtualThreadPerTaskExecutor: 3$'
[ "$(n own '^  \./.*:Executors\.newVirtualThreadPerTaskExecutor\(\)$')" = 3 ] || die "own: three grep lines, each the virtual-thread executor"
x own "^  files that name Spring's task or scheduling packages, @Async or @Scheduled: 0 · Java files searched: 10\$"
x own '^  threads started by hand: 1 · a platform thread among them: 1$'
echo "  own: 3 executors, each newVirtualThreadPerTaskExecutor · 0 of 10 files name Spring's task code · 1 platform thread by hand"

# "Boot has one switch for virtual threads ... Its own metadata file gives the default: false."
x decides '^  spring\.threads\.virtual\.enabled · in spring-boot-autoconfigure-4\.1\.1\.jar · type java\.lang\.Boolean · defaultValue false$'
x decides '^  properties in those metadata files with "virtual" in their name: 1 · spring\.threads\.virtual\.enabled$'
# "Its class file holds two bean methods with one bean name ... One wants platform threads ... The other wants virtual ones."
x decides '^  SimpleAsyncTaskExecutor applicationTaskExecutorVirtualThreads\(SimpleAsyncTaskExecutorBuilder\) · @Bean\(\["applicationTaskExecutor"\]\) · @ConditionalOnThreading\(VIRTUAL\)$'
x decides '^  ThreadPoolTaskExecutor applicationTaskExecutor\(ThreadPoolTaskExecutorBuilder\) · @Bean\(\["applicationTaskExecutor"\]\) · @ConditionalOnThreading\(PLATFORM\)$'
x decides "^  javap printed [0-9]+ lines; the class's methods, its constructor aside: 2, each one above\$"
# "switch not set, and the report says the platform method matched. Switch on: the virtual method matched instead. Off
# again: the first answer, line for line. Every threading condition in the report sits in Boot's task configuration. And
# TiffinBox served the same seven responses every time."
DA=$(blk decides 'A - ' 'B - '); DB=$(blk decides 'B - ' "A' - "); DA2=$(blk decides "A' - " '')
[ "$DA" = "$DA2" ] || die "decides: A' is not A, line for line"
printf '%s\n' "$DA" | grep -A1 -xF '   TaskExecutorConfigurations.TaskExecutorConfiguration#applicationTaskExecutor matched:' | grep -qxF '      - @ConditionalOnThreading found PLATFORM (OnThreadingCondition)' || die "decides A: the platform method matched"
printf '%s\n' "$DA" | grep -qxF '         - @ConditionalOnThreading did not find VIRTUAL (OnThreadingCondition)' || die "decides A: the virtual method did not match"
printf '%s\n' "$DB" | grep -A1 -xF '   TaskExecutorConfigurations.TaskExecutorConfiguration#applicationTaskExecutorVirtualThreads matched:' | grep -qxF '      - @ConditionalOnThreading found VIRTUAL (OnThreadingCondition)' || die "decides B: the virtual method matched"
printf '%s\n' "$DB" | grep -qxF '         - @ConditionalOnThreading did not find PLATFORM (OnThreadingCondition)' || die "decides B: the platform method did not match"
printf '%s\n' "$DA" | grep -qxF '  OnThreadingCondition lines in the report: 4 · each under a bean method of TaskExecutorConfigurations or TaskSchedulingConfigurations: 4' || die "decides A: every threading condition in the task configurations"
printf '%s\n' "$DB" | grep -qxF '  OnThreadingCondition lines in the report: 6 · each under a bean method of TaskExecutorConfigurations or TaskSchedulingConfigurations: 6' || die "decides B: every threading condition in the task configurations"
[ "$(n decides "^  exit 0 · the seven responses: 7 lines · md5 $S115\$")" = 3 ] || die "decides: the seven responses, 115c36ba..., every run"
[ "$(n decides '^  listens on: 127\.0\.0\.1:1889[01] · WARN lines 0 · ERROR lines 0$')" = 3 ] || die "decides: three runs, no warning"
echo "  decides: default false, 1 property · 2 methods, PLATFORM / VIRTUAL · A platform matched, B virtual, A' = A · 4/4, 6/6 · 115c36ba... x3"

# "Our harness ... hands Boot's executor twenty short tasks. Switch not set: ThreadPoolTaskExecutor ... The twenty tasks
# shared eight platform threads. Switch on: SimpleAsyncTaskExecutor. Twenty tasks, twenty virtual threads. ... Off again:
# eight."
SA=$(blk switch 'A - the switch not set' 'B - the switch on'); SB=$(blk switch 'B - the switch on' "A' - A re-run"); SA2=$(blk switch "A' - A re-run" '')
[ "$SA" = "$SA2" ] || die "switch: A' is not A, line for line"
grep -qE '^    static final int TASKS = 20;$' harness/threads/VThreads.java && grep -qF 'Thread.sleep(100);' harness/threads/VThreads.java || die "the harness: twenty tasks of 100 ms"
printf '%s\n' "$SA" | grep -qxF "Boot's executor, the bean applicationTaskExecutor: org.springframework.scheduling.concurrent.ThreadPoolTaskExecutor" || die "switch A: ThreadPoolTaskExecutor"
printf '%s\n' "$SA" | grep -qxF '20 tasks -> distinct threads 8 · virtual [false]' || die "switch A: 20 tasks on 8 platform threads"
printf '%s\n' "$SB" | grep -qxF "Boot's executor, the bean applicationTaskExecutor: org.springframework.core.task.SimpleAsyncTaskExecutor" || die "switch B: SimpleAsyncTaskExecutor"
printf '%s\n' "$SB" | grep -qxF '20 tasks -> distinct threads 20 · virtual [true]' || die "switch B: 20 tasks on 20 virtual threads"
printf '%s\n' "$SA" | grep -qxF 'the switch, as the environment holds it: spring.threads.virtual.enabled = (not set)' || die "switch A: the switch not set"
printf '%s\n' "$SB" | grep -qxF 'the switch, as the environment holds it: spring.threads.virtual.enabled = true · from commandLineArgs' || die "switch B: the switch on, from the flag"
# "The server's executor: ThreadPerTaskExecutor ... Switch off, on, off again: the same class." "The context holds two
# executor beans, and both are Boot's."
[ "$(n switch "^  TiffinBox's HttpServer executor: java\.util\.concurrent\.ThreadPerTaskExecutor\$")" = 3 ] || die "switch: the server's executor, the same class every run"
[ "$(n switch "^  TiffinBox's OrderQueue executor: java\.util\.concurrent\.ThreadPerTaskExecutor\$")" = 3 ] || die "switch: the kitchen's executor, the same class every run"
[ "$(n switch "^the context's beans of type java\.util\.concurrent\.Executor: 2 · applicationTaskExecutor taskScheduler\$")" = 3 ] || die "switch: two executor beans, both Boot's, every run"
# "the harness adds two jobs, each firing every fifty milliseconds. Switch not set: ThreadPoolTaskScheduler. Six firings, one
# thread, scheduling one, shared by both jobs. ... In Boot's default, it still does. Switch on: SimpleAsyncTaskScheduler. Six
# firings, six virtual threads, and the jobs shared none. Off again: one thread."
[ "$(grep -c '@Scheduled(fixedRate = 50)' harness/threads/VThreads.java)" = 2 ] && grep -qE '^    static final int FIRINGS = 3;$' harness/threads/VThreads.java || die "the harness: two jobs, every 50 ms, three firings each kept"
printf '%s\n' "$SA" | grep -qxF "Boot's scheduler, the bean taskScheduler: org.springframework.scheduling.concurrent.ThreadPoolTaskScheduler" || die "switch A: ThreadPoolTaskScheduler"
printf '%s\n' "$SA" | grep -qxF '  the 6 firings -> distinct threads 1 · used by both jobs 1 · virtual [false] · daemon [false] · names scheduling-1' || die "switch A: six firings, one thread, shared"
printf '%s\n' "$SB" | grep -qxF "Boot's scheduler, the bean taskScheduler: org.springframework.scheduling.concurrent.SimpleAsyncTaskScheduler" || die "switch B: SimpleAsyncTaskScheduler"
printf '%s\n' "$SB" | grep -qE '^  the 6 firings -> distinct threads 6 · used by both jobs 0 · virtual \[true\] · daemon \[true\] · names( scheduling-[0-9]+){6}$' || die "switch B: six firings, six virtual threads, none shared"
# "Switch not set, Boot's eight task threads were not daemons. Switch on, all twenty were."
printf '%s\n' "$SA" | grep -qxF '  daemon [false] · names task-1 … task-8' || die "switch A: eight task threads, not daemons"
printf '%s\n' "$SB" | grep -qxF '  daemon [true] · names task-1 … task-20' || die "switch B: twenty task threads, daemons"
[ "$(n switch '^  Boot.s log \(standard output\): 18 lines, not shown · WARN lines 0 · ERROR lines 0 · exit 0 · listening on 1889[23] now: 0$')" = 3 ] || die "switch: three clean runs"
echo "  switch: A ThreadPoolTaskExecutor 20 -> 8, B SimpleAsyncTaskExecutor 20 -> 20 virtual, A' = A · scheduler 6 -> 1 shared / 6 virtual, 0 shared · 2 Executor beans · ThreadPerTaskExecutor x3"

# "A thread dump ... shows two that aren't daemons, switch off or on. DestroyJavaVM ... HTTP-Dispatcher runs the JDK's HTTP
# server ... Boot's metadata describes a keep-alive property for apps with no such thread."
[ "$(n alive '^  Java threads that are not daemons: 2 · "DestroyJavaVM" "HTTP-Dispatcher"$')" = 2 ] || die "alive: two non-daemon threads, off and on"
[ "$(n alive '^  "HTTP-Dispatcher", its frame from the JDK.s HTTP server \(version and line cut\): sun\.net\.httpserver\.ServerImpl\$Dispatcher\.run\(jdk\.httpserver\)$')" = 2 ] || die "alive: the dispatcher runs the JDK's HTTP server"
[ "$(n alive "^  exit 0 · the seven responses: 7 lines · md5 $S115\$")" = 2 ] || die "alive: 115c36ba..., off and on"
x alive '^  its description: Whether to keep the application alive even if there are no more non-daemon threads\.$'
x alive '^\$ cd \.harness/after && java -jar tiffinbox-web/target/tiffinbox-web-1\.0\.0\.jar --tiffinbox\.port=18895 --spring\.threads\.virtual\.enabled=true$'
echo "  alive: 2 non-daemon threads (DestroyJavaVM, HTTP-Dispatcher) off and on · keep-alive described · 115c36ba... x2"

# the exercise's end state: every line exercise/README.md calls "Done" is a line of this capture, after the solution's command
XE=$(blk exercise "the solution's command" '')
for l in "the switch, as the environment holds it: spring.threads.virtual.enabled = true · from systemEnvironment" \
         "20 tasks -> distinct threads 20 · virtual [true]" "  TiffinBox's HttpServer executor: java.util.concurrent.ThreadPerTaskExecutor"; do
  printf '%s\n' "$XE" | grep -qxF -- "$l" || die "exercise: the solution's run printed no line: $l"
  awk '/^\*\*Done\*\*/ { f = 1 } f' exercise/README.md | grep -qxF -- "$l" || die "exercise/README.md: Done names no line: $l"
  grep -qxF -- "$l" exercise/solution/SOLUTION.md || die "SOLUTION.md: the measured run shows no line: $l"; done
x exercise '^20 tasks -> distinct threads 8 · virtual \[false\]$'
x exercise '^  exit 0 · printed: 0 line\(s\) · the token: 33 bytes, -rw------- · \.harness/mine/classes: 3 classes$'
echo "  exercise: the README as written -> 8; the variable -> 20 virtual, from systemEnvironment, ThreadPerTaskExecutor"
[ -z "$unpub" ] || die "no published hash for:$unpub - check the captures, then copy the md5s above into receipts.md5 and run again"
echo "c5-unit18: every capture 3/3 and = published; every spoken number asserted; 0 raw demo tokens in every capture"
