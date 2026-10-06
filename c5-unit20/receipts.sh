#!/bin/bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25.0.4.1 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# GRAALVM_HOME must name a GraalVM JDK 25 before you run this (README.md, "The GraalVM"): the native builds read it.
# Course 5 · What Breaks in Native, and the Hints That Fix It - this unit's receipts. A native image calls by reflection only
# what its build registered. Spring's ahead-of-time step (AOT) registers what Spring itself calls; TiffinBox's router, its JSON
# writer and its settings' validator call more. The anchor change: three hints, Spring's own annotations, one line each -
# @Reflective on the annotation Route, @RegisterReflectionForBinding(Customer.class) on TiffinBoxServer, @Reflective on
# TiffinBoxProperties.isShutdownTokenLongEnough() - and, in tiffinbox-web/pom.xml, the native plugin's <exclusions>, which keep
# the optional Docker Compose module and its Jackson 3 out of the binary. This script shows what changed, what each hint adds to
# Spring's reachability-metadata.json, builds the binaries and runs them - the hints all in, then one out at a time - and times
# the binary's start from outside. Six captures, each run three times and hashed; cap() DIES when a hash differs from
# receipts.md5; every number the video says is asserted at the bottom by a check that can fail; the demo token is masked (gsub),
# and the last checks count 0 raw copies of it in every capture, every file this unit ships, and every binary it built.
#   change    where after/'s code calls by reflection (grep -n); the previous tree against after/: the files that differ, the
#             lines each Java file and the POM gain; both trees built the plain way (the jars, entry by entry), and each jar run
#             on the JVM as the README runs it: the seven
#   metadata  both trees built with Boot's profile native, on the plain JDK: Spring's reachability-metadata.json, entry by entry -
#             what the three hints add to 262; after/'s jar run with the generated code (the seven); E, the general tool: a copy
#             of after/ whose token rule is registered by a RuntimeHintsRegistrar instead of @Reflective - the file it writes
#   native    the README's native build of the previous tree, then of after/: the build's lines, the jars on native-image's class
#             path against the executable jar's, the names from the Compose module and from Jackson 3 in each binary's bytes,
#             and each binary run from beside its config tree - the previous tree's stops at start, after/'s serves the seven
#   breaks    the hints one at a time: A after/'s binary · B the binding hint out · A' = A · C the route annotation's hint out ·
#             D the token rule's hint out (the other two in) - each of B, C, D a copy of after/ with one line deleted, built as
#             the README builds it, its metadata against A's, and its binary run
#   ladder    the start, timed from outside (harness/ttfr.py: from the fork to the first 200): the executable jar and after/'s
#             binary, six rounds, round 1 a warm-up - the binary's median against a band, and against the jar's median; never
#             the seconds (terminal only)
#   exercise  exercise/README.md's commands and exercise/solution/SOLUTION.md's, read from the files and run as written
# "before" is ../c5-unit19/after (the anchor as the AOT lesson left it), COPIED under .harness/; this script never writes into
# another unit's folder. after/ is this unit's frozen copy of ../c5-tiffinbox after the change; it is copied, never built in
# place. Every run of TiffinBox starts in a folder under .harness/ that holds a config tree with the demo token (secrets/), as the
# README asks: TiffinBox does not start without its token. Commands are printed exactly as they run: each goes through eval.
# "$CURLSET" is the comparison set since the secrets lesson (../c5-unit11/curlset.sh: the seven requests, POST /shutdown with the
# token's header read from the file). "$M2" is this unit's own repository, .m2-demo.
# Masks and filters (README.md declares each; sub/gsub only): the demo token becomes "[masked: the 26-character token]"; the
# GraalVM's folder "$GRAALVM_HOME"; this folder's absolute path "…", the folder above it "…/..", the home folder "~"; your user
# name "<user>" - in every line of every capture. A Boot log line is printed from its message on, and its first line is cut
# before " with PID". Maven's and native-image's logs are read, never printed whole: the lines a capture shows are named, and the
# rest counted. No duration is captured: each one is judged against a bound, and its seconds go to the terminal.
# Ports (brief ⚑10, 18910-18919): change 18910 (the previous tree's jar), 18911 (after/'s) · metadata 18912 · native 18913
# (after/'s binary), 18914 (the previous tree's, which stops before it binds) · breaks 18913 (A, A'), 18915 (B), 18916 (C), 18917
# (D, which stops before it binds) · ladder 18918 · 18919 unused. 18425 is checked free too: it is TiffinBox's default port.
set -e
# bash 5.2 and later turn an & in the replacement of ${x/pattern/replacement} into the matched text (patsub_replacement, on by
# default): start()'s "&& exec " would become "&& && exec ". Switched off, so /bin/bash 3.2 (./receipts.sh) and a newer bash
# (bash receipts.sh) run the same commands; 3.2 has no such option.
shopt -u patsub_replacement 2> /dev/null || true
cd "$(dirname "$0")"
# One run at a time: two runs share .harness/ and the ports, and one would corrupt the other.
mkdir .r-lock 2> /dev/null || { echo "  *** another receipts.sh is running in this folder (.r-lock exists) - if none is, rmdir .r-lock ***"; exit 1; }
# On every exit - the end, a failed check, or Ctrl-C - stop the process this script started in the background, if it still runs
# (a TiffinBox jar or binary: a background job of a non-interactive shell ignores the terminal's Ctrl-C), then sweep(): anything
# of a native build still alive in this run's process group, and any binary, is stopped. Maven, native-image and harness/ttfr.py
# run in the foreground: Ctrl-C reaches them, and ttfr.py stops the process it started before it exits; the sweep is for what a
# signal leaves behind - native-image's builder runs as "java @…/vminvocation.args", with no class name to look for. The clean-up
# ignores a second Ctrl-C, and nothing in it can fail under set -e, so it always reaches the rmdir; the script still exits 130
# after an interrupt (tested: README.md, "Interrupted"). $pid is cleared whenever the process has been reaped.
pid=""
# sweep: up to 10 s - every process in this run's process group whose command line is native-image's driver (in
# $GRAALVM_HOME/bin), its builder (vminvocation.args) or a TiffinBox binary under .harness/ gets TERM, then KILL after 5 s
sweep() { local g i l
  g=$(ps -o pgid= -p $$ 2> /dev/null | tr -d ' ') || g=""
  [ -n "$g" ] || return 0
  i=0; while [ $i -lt 20 ]; do
    l=$(ps -axo pid=,pgid=,command= 2> /dev/null | awk -v g="$g" -v me=$$ -v gh="${GRAALVM_HOME:-/nonexistent}" '
      $2 == g && $1 != me && $3 != "awk" && $3 != "ps" && (index($0, "vminvocation.args") || index($3, gh "/bin/native-image") || $3 ~ /tiffinbox-web\/target\/tiffinbox-web$/) { print $1 }' | paste -sd' ' -) || l=""
    [ -n "$l" ] || return 0
    if [ $i -lt 10 ]; then kill $l 2> /dev/null || true; else kill -9 $l 2> /dev/null || true; fi
    sleep 0.5; i=$((i + 1)); done; }
trap 'trap "" INT TERM; if [ -n "$pid" ] && kill "$pid" 2> /dev/null; then wait "$pid" 2> /dev/null || true; fi; sweep || true; rmdir .r-lock 2> /dev/null || true' EXIT
trap 'exit 130' INT TERM
exec 3>&1                                            # die() speaks to the terminal even inside a redirected capture
die() { echo "  *** $* ***" >&3; exit 1; }
java -version 2>&1 | grep -q 'version "25' || die "JDK 25 needed; JAVA_HOME gives: $(java -version 2>&1 | head -1)"
command -v python3 > /dev/null || die "python3 is needed: harness/ttfr.py is the clock, and the metadata file is JSON"
command -v curl > /dev/null || die "curl is needed: the seven requests are curl's"
# A variable of yours must not become a property source, a JVM flag, a build setting or a native-image option: every
# TIFFINBOX_* and SPRING_* variable, the two variables that inject JVM flags, MAVEN_OPTS, MAVEN_ARGS and NATIVE_IMAGE_OPTIONS are
# removed first. GRAALVM_HOME stays: it says which GraalVM to use.
for v in $(env | sed -n 's/^\(TIFFINBOX_[A-Za-z0-9_]*\|SPRING_[A-Za-z0-9_]*\|JAVA_TOOL_OPTIONS\|JDK_JAVA_OPTIONS\|MAVEN_OPTS\|MAVEN_ARGS\|NATIVE_IMAGE_OPTIONS\)=.*/\1/p'); do unset "$v"; done
# The GraalVM: named by GRAALVM_HOME, never guessed and never printed (its folder is masked). The captures were made with
# GraalVM CE 25.3.4.1 (native-image 25.0.4.1); another build would print other lines, so it is refused here, not minutes in.
[ -n "${GRAALVM_HOME:-}" ] && [ -x "$GRAALVM_HOME/bin/native-image" ] || die "GRAALVM_HOME must name a GraalVM JDK 25 (its bin/native-image) - README.md, The GraalVM"
NIV=$("$GRAALVM_HOME/bin/native-image" --version 2>&1 || true)
printf '%s\n' "$NIV" | grep -q '^native-image 25\.0\.4\.1 ' && printf '%s\n' "$NIV" | grep -q 'GraalVM CE 25\.3\.4\.1+1\.1' || die "the published captures were made with GraalVM CE 25.3.4.1 (native-image 25.0.4.1); GRAALVM_HOME gives: $(printf '%s\n' "$NIV" | head -1)"
export GRAALVM_HOME
[ -e secrets ] && die "this folder holds a secrets/ - remove it: every run here starts in a folder under .harness/"
[ -e after/secrets ] || [ -e after/tiffinbox-local.yaml ] || [ -e after/target ] && die "after/ holds a secrets/, a tiffinbox-local.yaml or a target/ - it is the anchor's frozen copy, never built in place; remove them"
M2="$PWD/.m2-demo"; U="$PWD"; UP="$(cd .. && pwd)"; ME="$(id -un)"
PREV=../c5-unit19/after                              # the previous tree: read, copied, never built in place
JAR=tiffinbox-web/target/tiffinbox-web-1.0.0.jar
BIN=tiffinbox-web/target/tiffinbox-web               # the binary native:compile-no-fork writes, in a tree's web module
TF=secrets/tiffinbox/shutdown-token                  # the config tree's file for tiffinbox.shutdown-token
META=tiffinbox-web/target/spring-aot/main/resources/META-INF/native-image/com.tiffinbox/tiffinbox-web/reachability-metadata.json
SRV=tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java
ROUTE=tiffinbox-web/src/main/java/com/tiffinbox/web/Route.java
PROPS=tiffinbox-core/src/main/java/com/tiffinbox/TiffinBoxProperties.java
APP=tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxApp.java
# The demo token. FAKE, and meant to look it: it guards nothing but a demo server on 127.0.0.1 that every capture stops. It is
# written into .harness/*/secrets/ (git-ignored) when this script runs, and no capture prints it: see mask().
TOKEN=not-a-real-token-demo-only
[ ${#TOKEN} = 26 ] || die "the demo token must be 26 characters"
CURLSET=../c5-unit11/curlset.sh                      # the comparison set: the seven requests, POST /shutdown with the header
[ -f "$CURLSET" ] || die "$CURLSET is missing"
[ -f "$PREV/pom.xml" ] && [ -f after/pom.xml ] && [ -f after/README.md ] || die "the previous tree $PREV or after/ is missing"
[ -f harness/ttfr.py ] && [ -x harness/shutdown.sh ] && [ -f harness/hints/ValidatorHints.java ] || die "harness/ is missing a file"

# The ports, BEFORE anything is wiped (a survivor of an interrupted run answers POST /shutdown only with its token, which lives
# in .harness/ - so the message names the process to kill).
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
for p in 18425 18910 18911 18912 18913 18914 18915 18916 18917 18918 18919; do
  [ "$(listeners $p)" = 0 ] || die "something already listens on $p - this unit's ports must be free; if it is a TiffinBox an interrupted run left behind, stop it: kill $(lsof -nP -iTCP:$p -sTCP:LISTEN -t 2> /dev/null | paste -sd' ' -)"; done

# ---- the commands: read from after/README.md, the anchor's own, and asserted - each line must be there, whole -------------
readme() { grep -m1 -xF -- "$1" after/README.md > /dev/null || die "after/README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
R_PLAIN=$(readme 'mvn -B package')
R_PKG=$(readme 'mvn -B -Pnative package')
R_RUN=$(readme 'java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431')
R_AOTRUN=$(readme 'java -Dspring.aot.enabled=true -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431')
R_GRAAL=$(readme 'export GRAALVM_HOME=/path/to/a/graalvm-jdk-25')
R_INSTALL=$(readme 'mvn -B -Pnative install')
R_NATIVE=$(readme 'mvn -B -Pnative -pl tiffinbox-web native:compile-no-fork')
R_BIN=$(readme 'tiffinbox-web/target/tiffinbox-web --tiffinbox.port=18431')
# off DIR 'README mvn LINE' [PHASE]: the README's Maven line as this script runs it - from DIR, offline (-o), this unit's own
# repository, and for a build phase (package, install) clean and without tests. dev() takes those four things back out, and
# must give the README's line again: so the command on screen is the README's, with exactly those changes.
off() { local c=${2/mvn -B /mvn -o -B -Dmaven.repo.local=\"\$M2\" }
  [ -n "$3" ] && c=${c/ $3/ -DskipTests clean $3}
  printf 'cd %s && %s\n' "$1" "$c"; }
dev() { local c=${1#cd * && }; c=${c/ -o -B -Dmaven.repo.local=\"\$M2\" / -B }; c=${c/ -DskipTests clean / }; printf '%s\n' "$c"; }
# at DIR PORT 'README LINE': the README's line run from DIR, its port 18431 made PORT
at() { printf 'cd %s && %s\n' "$1" "${3/--tiffinbox.port=18431/--tiffinbox.port=$2}"; }
C_AFTER=$(off .harness/after "$R_PLAIN" package)
for c in "$C_AFTER" "$(off .harness/x "$R_PKG" package)" "$(off .harness/x "$R_INSTALL" install)" "$(off .harness/x "$R_NATIVE")"; do
  r=$(dev "$c"); [ "$r" = "$R_PLAIN" ] || [ "$r" = "$R_PKG" ] || [ "$r" = "$R_INSTALL" ] || [ "$r" = "$R_NATIVE" ] || die "not a README line with the offline changes: $c"; done
[ "$(at .harness/x 18913 "$R_BIN")" = "cd .harness/x && tiffinbox-web/target/tiffinbox-web --tiffinbox.port=18913" ] || die "the binary's run line"
echo "  the commands: after/README.md gives all 8 lines this script runs or derives from"

# ---- build: one tree before the captures - after/, the plain way - for the ladder's jar; then the parent check -------------
rm -rf .harness; mkdir -p .harness
rsync -a --exclude target --exclude secrets "$PREV/" .harness/before/
rsync -a after/ .harness/after/
# mbuild 'COMMAND' LOG LABEL: the command, run as printed (eval), its log kept in LOG (never printed whole); Maven Central only
# if the offline build could not resolve something - and the line says which (offline: yes / no), so a run that went online is
# never silent (inside a capture, "no" changes the capture's hash: cap() then dies).
mbuild() { local how=yes ec=0
  (eval "$1") > "$2" 2>&1 < /dev/null || ec=$?
  if [ $ec != 0 ] && grep -qE 'offline mode|Could not resolve|could not be resolved|Cannot access' "$2"; then
    how="no - the offline build could not resolve an artifact, so Maven Central was asked"; ec=0
    (eval "${1/mvn -o -B /mvn -B }") > "$2" 2>&1 < /dev/null || ec=$?; fi
  [ $ec = 0 ] || { tail -30 "$2" >&3
    ! grep -qE 'Could not resolve|could not be resolved|Could not transfer|Cannot access' "$2" || die "build failed: $3 - Maven could resolve Boot's parent and plugins neither from .m2-demo nor from Maven Central: a fresh clone's first run needs the network once, to fill .m2-demo"
    die "build failed: $3"; }
  echo "  built $3 · offline: $how · exit $ec"; }
# tree FOLDER: a config tree in FOLDER/secrets holding one file, the token and a newline, readable by its owner alone
tree() { mkdir -p "$1/secrets/tiffinbox"; (umask 077 && printf '%s\n' "$TOKEN" > "$1/$TF"); chmod 700 "$1/secrets" "$1/secrets/tiffinbox"; }
mbuild "$C_AFTER" .harness/build-after.log ".harness/after (after/, the plain way)"
# Boot's parent POM: in .m2-demo now - the first build put it there if it was not (a fresh clone's .m2-demo is empty: git
# ignores it, and the offline build's failure sends that first build to Maven Central, once)
[ -f "$M2/org/springframework/boot/spring-boot-starter-parent/4.1.1/spring-boot-starter-parent-4.1.1.pom" ] || die "Boot's parent POM is not in .m2-demo after the first build"
[ -f "$M2/org/graalvm/buildtools/native-maven-plugin/1.1.8/native-maven-plugin-1.1.8.jar" ] || die "GraalVM's native plugin 1.1.8 is not in .m2-demo after the first build (it is a build extension of the web module)"
tree .harness/after

# ---- helpers ------------------------------------------------------------------------------------------------------------
# raw TOKEN FILE...: how many times TOKEN appears, raw, in the files (occurrences, not lines; binary files read as text)
raw() { local t=$1; shift; cat "$@" | LC_ALL=C grep -aoF -- "$t" | wc -l | tr -d ' '; }
warns() { echo "WARN lines $(grep -c ' WARN ' "$1" || true) · ERROR lines $(grep -c ' ERROR ' "$1" || true)"; }
# first LOG: Boot's first log line, from its message on, cut before " with PID"
first() { grep -m1 ' : Starting ' "$1" | sed 's/^.* : //; s/ with PID .*$//'; }
# start 'COMMAND': print it exactly as typed, run it in the background (eval, from this folder; exec, so $pid is the program's
# own pid), its standard output to .harness/run.out and its standard error to .harness/run.err
start() { echo "\$ $1"; (eval "${1/&& /&& exec }") > .harness/run.out 2> .harness/run.err < /dev/null & pid=$!; }
# listening: what the operating system says the process listens on (lsof), once it listens - or "nothing" once it exited
listening() { local a="" i=0
  while [ $i -lt 160 ]; do
    a=$(lsof -nP -a -p "$pid" -iTCP -sTCP:LISTEN 2> /dev/null | awk 'NR > 1 { print $9 }' | sort -u | paste -sd' ' -)
    [ -n "$a" ] && break; kill -0 "$pid" 2> /dev/null || break; sleep 0.25; i=$((i + 1)); done
  echo "${a:-nothing}"; }
# up [binary]: the line after a start - where it listens, its WARN/ERROR lines so far, Boot's first line; dies if it never
# listened
up() { local l; l=$(listening); [ "$l" != nothing ] || { tail -20 .harness/run.out >&3; die "it never listened"; }
  echo "  listens on: $l · $(warns .harness/run.out)"; echo "  Boot's first line: $(first .harness/run.out)"; }
# seven PORT DIR [all]: the comparison set's seven requests (POST /shutdown carries the header, read from DIR's token file),
# printed as run - every response line with "all", else the POST line; the process must leave within 15 s of them, and the port
# must be free again. Never call it inside $(...): wait needs this shell.
seven() { local i e=0
  echo "\$ \$CURLSET $1 $2/$TF"
  "$CURLSET" "$1" "$2/$TF" | grep ' -> ' > .harness/responses.txt || true
  if [ "$3" = all ]; then sed 's/^/  /' .harness/responses.txt; else grep '^POST ' .harness/responses.txt || echo "(no POST line)"; fi
  i=0; while kill -0 "$pid" 2> /dev/null && [ $i -lt 60 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$pid" 2> /dev/null && { kill "$pid"; die "the server on $1 was still running 15 s after POST /shutdown"; }
  wait "$pid" || e=$?; pid=""
  [ "$(listeners "$1")" = 0 ] || die "something still listens on $1"
  echo "  exit $e · the seven responses: $(wc -l < .harness/responses.txt | tr -d ' ') lines · md5 $(md5 -q .harness/responses.txt)"; }
# stops PORT: after a start that never listens - where it listened (nothing), how it ended, its last cause cut after the method
# it names, the exit code. Never call it inside $(...).
stops() { local e=0
  echo "  listened on: $(listening)"
  wait "$pid" || e=$?; pid=""
  echo "  then: $(grep -m1 -E '^Application run failed$' .harness/run.out || echo '(no failure line)') · lines starting 'Caused by: ' $(grep -c '^Caused by: ' .harness/run.out || true) - the last, to the method it names:"
  grep '^Caused by: ' .harness/run.out | tail -1 | sed "s/'\. To allow this operation.*\$/'./" | sed 's/^/    /'
  echo "  its first frame outside GraalVM's own and the JDK's: $(awk '/^Caused by: org\.graalvm\.nativeimage\.MissingReflectionRegistrationError/ { f = 1 } f && /^\tat / && !/com\.oracle\.svm|java\.base/ { sub(/^\tat /, ""); print; exit }' .harness/run.out)"
  echo "  exit $e · listening on $1 now: $(listeners "$1") · its output: $(wc -l < .harness/run.out | tr -d ' ') lines, $(wc -l < .harness/run.err | tr -d ' ') on standard error"; }

# mask: the demo token becomes a label naming its length; the GraalVM's folder "$GRAALVM_HOME"; this folder's path "…", the
# folder above it "…/..", the home folder "~" (each also in its URL form, spaces as %20); the user name "<user>" - in every
# line (gsub). The GraalVM's folder is masked before the home folder, which holds it.
mask() { awk -v t="$TOKEN" -v g="$GRAALVM_HOME" -v u="$U" -v up="$UP" -v hm="$HOME" -v me="$ME" '
  function lit(x) { gsub(/[][\\.^$*+?(){}|\/]/, "\\\\&", x); return x }
  function enc(x) { gsub(/ /, "%20", x); return x }
  BEGIN { T = lit(t); G = lit(g); GE = lit(enc(g)); P = lit(u); Q = lit(up); H = lit(hm); PE = lit(enc(u)); QE = lit(enc(up)); M = lit(me) }
  { gsub(T, "[masked: the 26-character token]"); gsub(G, "$GRAALVM_HOME"); gsub(GE, "$GRAALVM_HOME"); gsub(P, "…"); gsub(PE, "…")
    gsub(Q, "…/.."); gsub(QE, "…/.."); gsub(H, "~"); gsub(M, "<user>"); print }'; }

unpub=""
cap() { local nm=$1 h pub i; shift
  for i in 1 2 3; do "$@" > .harness/cap.raw 2>&1 || true; [ -z "$pid" ] || die "$nm left a process running"
    raw "$TOKEN" .harness/cap.raw > ".harness/raw-$nm.$i"; mask < .harness/cap.raw > ".r-$nm.$i"; done
  h=$(md5 -q ".r-$nm.1")
  [ "$h" = "$(md5 -q ".r-$nm.2")" ] && [ "$h" = "$(md5 -q ".r-$nm.3")" ] || die "$nm drifts across three runs (diff .r-$nm.1 .r-$nm.2 .r-$nm.3)"
  mv ".r-$nm.1" ".r-$nm.out"; rm -f ".r-$nm.2" ".r-$nm.3"
  pub=$(awk -v n="$nm" '$1 == n { print $2 }' receipts.md5 2> /dev/null || true)
  if [ -z "$pub" ]; then printf '  %-9s md5 %s  3/3  (no published hash)\n' "$nm" "$h"; unpub="$unpub $nm"
  elif [ "$pub" = "$h" ]; then printf '  %-9s md5 %s  3/3  = published\n' "$nm" "$h"
  else printf '  %-9s md5 %s  3/3  DIFFERS from the published %s\n' "$nm" "$h" "$pub"
    die "$nm is not the published capture - suspect another JDK, GraalVM, Boot or Maven, a busy machine, a busy port, a variable of yours, or an edited source; diff .r-$nm.out against its block in README.md"; fi; }
# copy SRC DEST: a tree copied without its target/ and secrets/, then a config tree of its own
copy() { rm -rf "$2" "$2".*.log; rsync -a --exclude target --exclude secrets "$1/" "$2/"; tree "$2"; }
# del 'LINE' FILE: the sed that deletes LINE (a whole line) from FILE, printed as run; exactly one line must go
del() { local before after
  before=$(grep -cxF -- "$1" "$2" || true); [ "$before" = 1 ] || die "$2 holds the line '$1' $before times, not once"
  echo "\$ sed -i '' '/^$1\$/d' $2"
  sed -i '' "/^$1\$/d" "$2"; after=$(grep -cxF -- "$1" "$2" || true)
  echo "  lines deleted: $((before - after))"; }
# metadiff A B LA LB: two reachability-metadata.json files, read as JSON (python3), entry by entry: the counts, then every entry
# only in one of them, and every entry that differs (its methods, when only they differ), named
metadiff() { python3 - "$1" "$2" "$3" "$4" <<'PY'
import json, sys
a, b = (json.load(open(p)) for p in sys.argv[1:3]); la, lb = sys.argv[3], sys.argv[4]
def key(e): return json.dumps(e.get("type"), sort_keys=True)
def name(e): t = e.get("type"); return t if isinstance(t, str) else json.dumps(t, sort_keys=True)
def meths(e): return " ".join(m["name"] for m in e.get("methods", [])) or "(none)"
def desc(e): return " · ".join([name(e)] + [k for k, v in e.items() if v is True] + (["methods " + meths(e)] if "methods" in e else []))
A = {key(e): e for e in a["reflection"]}; B = {key(e): e for e in b["reflection"]}
same = [k for k in A if k in B and A[k] == B[k]]; ch = sorted(k for k in A if k in B and A[k] != B[k])
oa = sorted(k for k in A if k not in B); ob = sorted(k for k in B if k not in A)
print("  reflection entries: %d and %d · the same in both: %d · only in %s: %d · only in %s: %d · different: %d · resources: %d and %d, the same: %s"
      % (len(a["reflection"]), len(b["reflection"]), len(same), la, len(oa), lb, len(ob), len(ch),
         len(a.get("resources", [])), len(b.get("resources", [])), "yes" if a.get("resources") == b.get("resources") else "no"))
for k in oa: print("  only in %s: %s" % (la, desc(A[k])))
for k in ob: print("  only in %s: %s" % (lb, desc(B[k])))
for k in ch:
    x, y = dict(A[k]), dict(B[k]); x.pop("methods", None); y.pop("methods", None)
    if x == y: print("  different: %s · methods %s -> %s" % (" · ".join([name(A[k])] + [kk for kk, v in x.items() if v is True]), meths(A[k]), meths(B[k])))
    else: print("  different: %s -> %s" % (desc(A[k]), desc(B[k])))
print("  entries for com.tiffinbox.web.Route: %d and %d" % (sum(1 for e in a["reflection"] if e.get("type") == "com.tiffinbox.web.Route"), sum(1 for e in b["reflection"] if e.get("type") == "com.tiffinbox.web.Route")))
PY
}
# nbuild DIR: the README's two Maven lines on DIR - both modules installed into $M2, then the binary from the web module alone -
# printed as run; native-image's log kept in DIR.native.log, never printed whole; its duration to the terminal, and kept for
# nresult() in NB_E and NB_S. Never call it inside $(...).
NB_E=0; NB_S=0
nbuild() { local ci cn s0 s1
  ci=$(off "$1" "$R_INSTALL" install); cn=$(off "$1" "$R_NATIVE")
  echo "\$ $ci"; mbuild "$ci" "$1.install.log" "$1 (both modules, into \$M2)"
  echo "\$ $cn"
  NB_E=0; s0=$(date +%s); (eval "$cn") > "$1.native.log" 2>&1 < /dev/null || NB_E=$?; s1=$(date +%s); NB_S=$((s1 - s0))
  echo "  (terminal only) the native build in $1 took $NB_S s" >&3; }
# nlines LOG: native-image's lines a capture shows, in order - the plugin's goal and the GraalVM it found, the builder's Java,
# its warnings (the file URL cut), the stage names (their timings cut), what the analysis found reachable, the warning count and
# Maven's result - and how many it does not show
nlines() {
  echo "  its lines, in order (the rest - $(grep -cvE '^\[INFO\] --- |^\[INFO\] Found GraalVM|^ - Java version: |^Warning: |^\[[1-8]/8\] |found reachable$|^\[INFO\] BUILD |^The build process encountered ' "$1" || true) lines - not shown):"
  grep -E '^\[INFO\] --- .* @ tiffinbox-web ---$|^\[INFO\] Found GraalVM installation from ' "$1" | sed 's/^\[INFO\] /    /'
  grep -E '^ - Java version: ' "$1" | sed 's/^ - /    /'
  grep -E '^Warning: ' "$1" | sed "s/ in 'file:[^']*'/ in '…'/" | sed 's/^/    /'
  grep -E '^\[[1-8]/8\] ' "$1" | sed 's/\.\.\..*$/.../' | sed 's/^/    /'
  grep -E 'found reachable$' "$1" | sed 's/^ */    /'
  grep -E '^The build process encountered |^\[INFO\] BUILD ' "$1" | sed 's/^\[INFO\] //' | sed 's/^/    /'; }
# nresult LOG: the native build's result - its exit, Maven's result, the stages against the count it announces, its duration
# against the bound (1 minute or more, under 10 minutes)
nresult() { echo "  exit $NB_E · $(grep -m1 -oE 'BUILD (SUCCESS|FAILURE)' "$1" || echo 'no BUILD line') · stages it printed: $(grep -cE '^\[[1-8]/8\] ' "$1" || true) of the $(grep -m1 -oE '^\[1/[0-9]+\]' "$1" | sed 's/.*\///; s/]//') it announces · its duration, against the bound: $( [ $NB_S -ge 60 ] && echo '1 minute or more' || echo 'under 1 minute' ), $( [ $NB_S -lt 600 ] && echo 'under 10 minutes' || echo '10 minutes or more' )"; }
# names BINARY PREFIX: the distinct names in the binary's bytes that start with PREFIX (a package name, dotted)
names() { LC_ALL=C grep -aoE "$(printf '%s' "$2" | sed 's/\./\\./g')[A-Za-z0-9_.\$]+" "$1" | LC_ALL=C sort -u || true; }
# cpath DIR: the jars on native-image's class path (the plugin's own command line, names only) against the executable jar's
# BOOT-INF/lib - and, for each jar only on native-image's, its class files
cpath() { local o
  grep -m1 '^\[INFO\] Executing: ' "$1.native.log" | grep -oE '[^/:]+\.jar' | LC_ALL=C sort -u > "$1.ni-cp.txt" || true
  unzip -Z1 "$1/$JAR" | grep '^BOOT-INF/lib/.*\.jar$' | sed 's|^BOOT-INF/lib/||' | LC_ALL=C sort -u > "$1.jar-lib.txt"
  o=$(LC_ALL=C comm -23 "$1.ni-cp.txt" "$1.jar-lib.txt" | paste -sd' ' -)
  echo "  the jars on native-image's class path (the plugin's command line, names only): $(wc -l < "$1.ni-cp.txt" | tr -d ' ') · in the executable jar's BOOT-INF/lib: $(wc -l < "$1.jar-lib.txt" | tr -d ' ') · only in the jar: $(LC_ALL=C comm -13 "$1.ni-cp.txt" "$1.jar-lib.txt" | paste -sd' ' -)"
  echo "  only on native-image's: $o"
  for j in $o; do echo "    $j - its class files: $(unzip -Z1 "$(find "$M2" -name "$j" -type f | head -1)" | grep -c '\.class$' || true)"; done; }
# inbin DIR: the names from the Compose module and from Jackson 3 in DIR's binary's bytes - each list counted, the short one shown
inbin() { local b=$1/$BIN c j
  names "$b" 'org.springframework.boot.docker.compose.' > "$1.compose.txt"; names "$b" 'tools.jackson.' > "$1.jackson3.txt"
  c=$(wc -l < "$1.compose.txt" | tr -d ' '); j=$(wc -l < "$1.jackson3.txt" | tr -d ' ')
  echo "  in the binary's bytes, distinct names under org.springframework.boot.docker.compose.: $c · under tools.jackson.: $j"
  if [ "$j" -le 5 ] && [ "$j" -gt 0 ]; then
    echo "    those $j: $(paste -sd' ' "$1.jackson3.txt")"
    echo "    each one named in a class of spring-boot-4.1.1.jar, under org/springframework/boot/json/: $(n=0; while read -r x; do unzip -p "$M2/org/springframework/boot/spring-boot/4.1.1/spring-boot-4.1.1.jar" 'org/springframework/boot/json/*.class' | LC_ALL=C grep -aqF -e "$x" -e "$(printf '%s' "$x" | tr . /)" && n=$((n + 1)); done < "$1.jackson3.txt"; echo "$n of $j")"; fi; }

# ---- change: the previous tree against after/ ---------------------------------------------------------------------------
# added FILE: the lines diff adds to FILE (after/ against the previous tree) that are neither comment nor blank, and the counts
added() { diff ".harness/before/$1" ".harness/after/$1" > .harness/file.diff || true
  echo "  $1:"
  grep '^> ' .harness/file.diff | sed 's/^> //' | awk '/^[ \t]*(\/\*|\*|\/\/)/ { next } /^[ \t]*$/ { next } { print "    " $0 }'
  echo "    (diff removes $(grep -c '^< ' .harness/file.diff || true) - comment lines $(grep '^< ' .harness/file.diff | sed 's/^< //' | awk '/^[ \t]*(\/\*|\*|\/\/)/ { n++ } END { print n + 0 }') · adds $(grep -c '^> ' .harness/file.diff || true) - not shown: $(grep '^> ' .harness/file.diff | sed 's/^> //' | awk '/^[ \t]*(\/\*|\*|\/\/)/ { n++ } END { print n + 0 }') comment lines, $(grep -c '^> *$' .harness/file.diff || true) blank)"; }
# calls FILE 'TEXT'...: each line of after/'s FILE that holds TEXT, with its number (grep -n), its indentation cut
calls() { local f=$1 t; shift; for t in "$@"; do grep -nF -- "$t" ".harness/after/$f" | sed 's/^\([0-9]*\):[ \t]*/\1: /' | sed "s|^|  ${f##*/}:|"; done; }
change() { local d t
  echo "where after/'s code calls by reflection - the router, finding its routes and calling one; Jackson, writing each route's answer - and the"
  echo "rule Hibernate Validator calls while Boot binds the settings (grep -n):"
  calls "$SRV" 'for (Method m : getClass().getDeclaredMethods()) {' 'respond(exchange, 200, handler.invoke(this));' 'byte[] body = JSON.writeValueAsBytes(value);'
  calls "$PROPS" '@AssertTrue(message = ' 'public boolean isShutdownTokenLongEnough() {'
  echo "the previous tree - the anchor as the AOT lesson left it - against after/, both copied under .harness/:"
  echo "\$ diff -rq -x target -x secrets .harness/before .harness/after"
  (diff -rq -x target -x secrets .harness/before .harness/after || true) | sed 's/^/  /'
  echo "the lines diff adds to each Java file - comment and blank lines counted, not shown:"
  for f in "$ROUTE" "$SRV" "$PROPS"; do added "$f"; done
  echo "after/'s tiffinbox-web/pom.xml against the previous one - every line diff adds, its comment lines counted, not shown:"
  diff .harness/before/tiffinbox-web/pom.xml .harness/after/tiffinbox-web/pom.xml > .harness/pom.diff || true
  grep '^> ' .harness/pom.diff | sed 's/^> //' | awk '/^ *<!--/ { c = 1 } c { if (/-->/) c = 0; next } /^ *$/ { next } { print "  " $0 }'
  echo "  lines diff removes: $(grep -c '^< ' .harness/pom.diff || true) · adds: $(grep -c '^> ' .harness/pom.diff || true) - not shown: a comment of $(grep '^> ' .harness/pom.diff | sed 's/^> //' | awk '/^ *<!--/ { c = 1 } c { n++; if (/-->/) c = 0 } END { print n + 0 }') lines, and $(grep -c '^> *$' .harness/pom.diff || true) blank"
  echo "both trees, built the plain way - the README's Maven line, offline, clean, each in a copy of its own:"
  for t in before after; do copy ".harness/$t" ".harness/plain-$t"; done
  t=$(off .harness/plain-before "$R_PLAIN" package); echo "\$ $t"; mbuild "$t" .harness/build-plain-before.log "the previous tree"
  t=$(off .harness/plain-after "$R_PLAIN" package); echo "\$ $t"; mbuild "$t" .harness/build-plain-after.log "after/"
  unzip -lv ".harness/plain-before/$JAR" | awk 'NF == 8 && $7 ~ /^[0-9a-f]{8}$/ { print $8, $7 }' | LC_ALL=C sort > .harness/ent-before.txt
  unzip -lv ".harness/plain-after/$JAR" | awk 'NF == 8 && $7 ~ /^[0-9a-f]{8}$/ { print $8, $7 }' | LC_ALL=C sort > .harness/ent-after.txt
  d=$(LC_ALL=C comm -3 .harness/ent-before.txt .harness/ent-after.txt | awk '{ print $1 }' | LC_ALL=C sort -u | paste -sd' ' -)
  echo "  the two executable jars, entry by entry: entries $(wc -l < .harness/ent-before.txt | tr -d ' ') and $(wc -l < .harness/ent-after.txt | tr -d ' ') · the same name and content (CRC-32): $(LC_ALL=C comm -12 .harness/ent-before.txt .harness/ent-after.txt | wc -l | tr -d ' ') · different: $(printf '%s\n' "$d" | wc -w | tr -d ' ') - ${d:-none}"
  echo "  the names under BOOT-INF/lib/ of both: the same: $(cmp -s <(grep '^BOOT-INF/lib/' .harness/ent-before.txt | awk '{ print $1 }') <(grep '^BOOT-INF/lib/' .harness/ent-after.txt | awk '{ print $1 }') && echo yes || echo no) · jars under it: $(grep -c '^BOOT-INF/lib/.*\.jar ' .harness/ent-after.txt || true) · the Compose module's or Jackson 3's among them: $(grep -cE '^BOOT-INF/lib/(spring-boot-docker-compose|jackson-(core|databind)-3)[^ ]*\.jar ' .harness/ent-after.txt || true)"
  echo "each jar on the JVM, as the README runs it, from beside its config tree:"
  start "$(at .harness/plain-before 18910 "$R_RUN")"; up; seven 18910 .harness/plain-before
  start "$(at .harness/plain-after 18911 "$R_RUN")"; up; seven 18911 .harness/plain-after; }
cap change change

# ---- metadata: what the hints add to Spring's reachability-metadata.json ----------------------------------------------------
metadata() { local t
  echo "both trees, built with Boot's profile native - the README's line, offline, clean, on the plain JDK; Spring's process-aot writes"
  echo "reachability-metadata.json, the file a native build reads:"
  for t in before after; do copy ".harness/$t" ".harness/meta-$t"; done
  t=$(off .harness/meta-before "$R_PKG" package); echo "\$ $t"; mbuild "$t" .harness/build-meta-before.log "the previous tree"
  t=$(off .harness/meta-after "$R_PKG" package); echo "\$ $t"; mbuild "$t" .harness/build-meta-after.log "after/"
  echo "  the JDK Maven ran on (mvn -version): $(mvn -version 2>&1 | grep -m1 '^Java version: ' | sed 's/, vendor: .*$//') · a native-image in it: $( [ -e "$JAVA_HOME/bin/native-image" ] && echo yes || echo no)"
  echo "the two files, entry by entry - the previous tree's against after/'s:"
  metadiff ".harness/meta-before/$META" ".harness/meta-after/$META" "the previous tree's" "after/'s"
  echo "after/'s jar from that build, on the JVM with the generated code - the README's AOT run, its port made 18912:"
  start "$(at .harness/meta-after 18912 "$R_AOTRUN")"; up; seven 18912 .harness/meta-after
  echo "E - the general tool: a copy of after/ whose token rule is registered by code - a RuntimeHintsRegistrar - not by @Reflective:"
  copy .harness/after .harness/meta-e
  del '    @Reflective' ".harness/meta-e/$PROPS"
  echo "\$ cp harness/hints/ValidatorHints.java .harness/meta-e/tiffinbox-web/src/main/java/com/tiffinbox/web/"
  cp harness/hints/ValidatorHints.java .harness/meta-e/tiffinbox-web/src/main/java/com/tiffinbox/web/
  t="s/^public class TiffinBoxApp {\$/@org.springframework.context.annotation.ImportRuntimeHints(ValidatorHints.class) public class TiffinBoxApp {/"
  echo "\$ sed -i '' '$t' .harness/meta-e/$APP"; sed -i '' "$t" ".harness/meta-e/$APP"
  echo "  its TiffinBoxApp.java against after/'s: lines diff changes $(diff ".harness/after/$APP" ".harness/meta-e/$APP" | grep -c '^> ' || true) - now:"
  grep -F 'ImportRuntimeHints' ".harness/meta-e/$APP" | sed 's/^/    /'
  echo "  harness/hints/ValidatorHints.java, the code that registers the method (its lines from 'public void registerHints'):"
  awk '/public void registerHints/ { f = 1 } f { print "    | " $0 } f && /;$/ { exit }' harness/hints/ValidatorHints.java
  t=$(off .harness/meta-e "$R_PKG" package); echo "\$ $t"; mbuild "$t" .harness/build-meta-e.log "E"
  echo "  E's reachability-metadata.json against after/'s, byte for byte: $(cmp -s ".harness/meta-after/$META" ".harness/meta-e/$META" && echo the same || echo different)"
  echo "  E's entry for the settings record: $(python3 -c 'import json,sys; e=[x for x in json.load(open(sys.argv[1]))["reflection"] if x.get("type")=="com.tiffinbox.TiffinBoxProperties"][0]; print(" · ".join([e["type"]]+[k for k,v in e.items() if v is True]+["methods "+" ".join(m["name"] for m in e.get("methods",[]))]))' ".harness/meta-e/$META")"; }
cap metadata metadata

# ---- native: the binaries of the previous tree and of after/ ---------------------------------------------------------------
native() {
  echo "the previous tree - the AOT lesson's anchor: no hints, no exclusions - copied to .harness/nat-p with a config tree; the README's two"
  echo "Maven lines, offline; \$GRAALVM_HOME names the GraalVM:"
  copy .harness/before .harness/nat-p
  nbuild .harness/nat-p
  echo "  $(grep -E 'found reachable$' .harness/nat-p.native.log | sed 's/^ *//')"
  nresult .harness/nat-p.native.log
  cpath .harness/nat-p
  inbin .harness/nat-p
  echo "  the demo token in its bytes: $(raw "$TOKEN" ".harness/nat-p/$BIN")"
  echo "its binary, run from beside its config tree as the README runs it, port 18914:"
  start "$(at .harness/nat-p 18914 "$R_BIN")"; stops 18914
  echo "after/ - the three hints and the exclusions - copied to .harness/nat-a with a config tree; the same two lines:"
  copy .harness/after .harness/nat-a
  nbuild .harness/nat-a
  nlines .harness/nat-a.native.log
  nresult .harness/nat-a.native.log
  echo "  file: $(file -b ".harness/nat-a/$BIN" | sed 's/ [A-Za-z0-9_]*$//') · the demo token in its bytes: $(raw "$TOKEN" ".harness/nat-a/$BIN")"
  cpath .harness/nat-a
  inbin .harness/nat-a
  echo "its binary, run from beside its config tree as the README runs it, port 18913:"
  start "$(at .harness/nat-a 18913 "$R_BIN")"; up; seven 18913 .harness/nat-a; }
cap native native

# ---- breaks: the hints, one at a time ----------------------------------------------------------------------------------------
# variant LETTER LINE FILE: after/ copied to .harness/nat-LETTER, LINE deleted from FILE, built as the README builds it; its
# metadata against A's (.harness/nat-a, built by native)
variant() { local d=.harness/nat-$1
  copy .harness/after "$d"
  del "$2" "$d/$3"
  nbuild "$d"
  echo "  $(grep -E 'found reachable$' "$d.native.log" | sed 's/^ *//')"
  nresult "$d.native.log"
  echo "  the demo token in its bytes: $(raw "$TOKEN" "$d/$BIN") · its reachability-metadata.json against A's:"
  metadiff ".harness/nat-a/$META" "$d/$META" "A's" "$(printf '%s' "$1" | tr a-z A-Z)'s" | grep -v '^  entries for com\.tiffinbox\.web\.Route: '; }
breaks() { local e
  echo "the hints, one at a time. A: after/'s binary, built by capture native. B, C and D: a copy of after/ with one hint's line deleted,"
  echo "built with the README's two Maven lines, offline; each binary run from beside its config tree as the README runs it."
  echo "A - after/'s binary, port 18913:"
  start "$(at .harness/nat-a 18913 "$R_BIN")"; up; seven 18913 .harness/nat-a all
  cp .harness/responses.txt .harness/responses-A.txt
  echo "B - without the binding hint, in .harness/nat-b:"
  variant b '@RegisterReflectionForBinding(Customer.class)' "$SRV"
  start "$(at .harness/nat-b 18915 "$R_BIN")"; up; seven 18915 .harness/nat-b all
  echo "  response lines different from A's: $(diff .harness/responses-A.txt .harness/responses.txt | grep -c '^> ' || true) - $(diff .harness/responses-A.txt .harness/responses.txt | grep '^> ' | awk '{ print $2, $3 }' | paste -sd',' -)"
  echo "A' - A re-run:"
  start "$(at .harness/nat-a 18913 "$R_BIN")"; up; seven 18913 .harness/nat-a
  echo "  its seven against A's, line for line: $(cmp -s .harness/responses-A.txt .harness/responses.txt && echo the same || echo different)"
  echo "C - without the route annotation's @Reflective, in .harness/nat-c:"
  variant c '@Reflective' "$ROUTE"
  start "$(at .harness/nat-c 18916 "$R_BIN")"; up
  echo "  TiffinBox's own line: $(grep -m1 ' : routes mapped: ' .harness/run.out | sed 's/^.* : //')"
  printf '%s\n' "\$ curl -s -m 5 -o /dev/null -w '%{http_code}\\n' http://127.0.0.1:18916/kitchen"
  e=0; o=$(curl -s -m 5 -o /dev/null -w '%{http_code}\n' http://127.0.0.1:18916/kitchen) || e=$?; echo "  printed: $o · curl exit $e"
  echo "\$ harness/shutdown.sh 18916 .harness/nat-c/$TF"
  harness/shutdown.sh 18916 ".harness/nat-c/$TF" | sed 's/^/  /'
  echo "  still running: $(kill -0 "$pid" 2> /dev/null && echo yes || echo no) · its standard error, each line naming a thread, to the method it names:"
  grep '^Exception in thread ' .harness/run.err | sed "s/'\. To allow this operation.*\$/'./" | sed 's/^/    /'
  echo "\$ kill \$pid    # SIGTERM, to the binary this script started"
  e=0; kill "$pid"; wait "$pid" || e=$?; pid=""
  echo "  exit $e · listening on 18916 now: $(listeners 18916)"
  echo "D - without the token rule's @Reflective - the router's and the record's hints still in - in .harness/nat-d:"
  variant d '    @Reflective' "$PROPS"
  start "$(at .harness/nat-d 18917 "$R_BIN")"; stops 18917; }
cap breaks breaks

# ---- ladder: the binary's start, timed from outside --------------------------------------------------------------------------
L1=$(at .harness/after 18918 "$R_RUN"); L2=$(at .harness/nat-a 18918 "$R_BIN")
ladder() { local r w s line d
  echo "the start, timed from outside: harness/ttfr.py forks the command, asks /kitchen until the first 200, then sends POST /shutdown"
  echo "with the token. Two ways, each from beside its config tree, port 18918; 6 rounds, each round both ways in turn; round 1 is a warm-up."
  echo "  (terminal only) this Mac: $(sysctl -n machdep.cpu.brand_string) · $(sysctl -n hw.ncpu) cores · $(( $(sysctl -n hw.memsize) / 1073741824 )) GB · $(java -version 2>&1 | head -1)" >&3
  echo "  1 the executable jar, after/ built the plain way - \$ $L1"
  echo "  2 after/'s binary, built by capture native - \$ $L2"
  : > .harness/times.txt
  r=1; while [ $r -le 6 ]; do w=1; while [ $w -le 2 ]; do eval "line=\$L$w"; d=${line#cd }; d=${d%% && *}
      s=$(cd "$d" && python3 "$U/harness/ttfr.py" 18918 "$TF" "$U/.harness/ttfr.out" "$U/.harness/ttfr.err" -- ${line#cd * && })
      printf '%s %s %s\n' "$r" "$w" "$s" >> .harness/times.txt
      [ "$(listeners 18918)" = 0 ] || die "a timed run left 18918 bound"; w=$((w + 1)); done; r=$((r + 1)); done
  echo "  every run: a 200, then exit 0 after POST /shutdown: $(grep -c ' first 200 after [0-9.]* s · exit 0$' .harness/times.txt || true) of $(wc -l < .harness/times.txt | tr -d ' ')"
  echo "the 5 counted rounds - each way's median, the middle of its 5 runs; the binary's against a band, then against the jar's (the seconds go to the terminal, never to this capture):"
  awk '
    { if ($1 == 1) next; t[$2, $1] = $6 + 0 }
    END {
      for (w = 1; w <= 2; w++) { n = 0
        for (r = 2; r <= 6; r++) { x = t[w, r]; i = n; while (i > 0 && v[i] > x) { v[i + 1] = v[i]; i-- }; v[i + 1] = x; n++ }
        med[w] = v[3]; lo[w] = v[1]; hi[w] = v[5] }
      printf "  2 the binary: its median over 0.01 s and under 0.1 s: %s\n", (med[2] > 0.01 && med[2] < 0.1) ? "yes" : "no"
      printf "  2 against 1: the binary%ss median under a tenth of the jar%ss: %s\n", "\047", "\047", (med[2] < med[1] / 10) ? "yes" : "no"
      printf "  (terminal only) 1 the executable jar: %.3f-%.3f s, median %.3f s\n", lo[1], hi[1], med[1] > "/dev/stderr"
      printf "  (terminal only) 2 the binary: %.3f-%.3f s, median %.3f s\n", lo[2], hi[2], med[2] > "/dev/stderr" }' .harness/times.txt 2>&3; }
cap ladder ladder

# ---- exercise: the README's commands, exactly as written, then the solution's ---------------------------------------------
# block FILE: the lines of FILE's first ```bash block
block() { awk '/^```bash$/ { if (!d) { f = 1 }; next } f && /^```$/ { f = 0; d = 1 } f' "$1"; }
exercise() { local setup sol ec=0
  setup=$(block exercise/README.md); sol=$(block exercise/solution/SOLUTION.md)
  [ -n "$setup" ] && [ -n "$sol" ] || die "exercise/README.md or SOLUTION.md no longer gives its commands"
  [ "$(printf '%s\n' "$sol" | grep -c .)" = 1 ] || die "SOLUTION.md's first bash block must be its one line"
  echo "exercise/README.md's commands, run exactly as written from this folder - $(printf '%s\n' "$setup" | grep -c .) lines:"
  printf '%s\n' "$setup" | sed 's/^/  $ /'
  (eval "$setup") > .harness/ex-setup.log 2>&1 < /dev/null || ec=$?
  [ $ec = 0 ] || { tail -20 .harness/ex-setup.log >&3; die "the exercise's setup failed"; }
  echo "  exit $ec · printed: $(grep -c . .harness/ex-setup.log || true) line(s)"
  echo "the solution's line (exercise/solution/SOLUTION.md), run exactly as written, from this folder:"
  echo "\$ $sol"
  ec=0; (eval "$sol") 2>&1 < /dev/null || ec=$?
  echo "  exit $ec"; }
cap exercise exercise

echo
# ---- every number the video says, asserted. Each check reads a line a program computed - never a label this script prints
# ---- unconditionally - and names the words it pays for. (The "$ ..." command lines are echoes of what ran: the published
# ---- md5 pins them, and no check pretends to test them.)
x() { grep -qE -- "$2" ".r-$1.out" || die "$1: expected /$2/"; }
n() { grep -cE -- "$2" ".r-$1.out" || true; }                                            # how many lines match
blk() { awk -v a="$2" -v b="$3" 'index($0, a) == 1 { f = 1; next } b != "" && index($0, b) == 1 { f = 0 } f' ".r-$1.out"; }
S115='115c36bac276128e245ca57df11c2891'
# has 'TEXT' MESSAGE: TEXT (a variable holding a capture's block) holds the line, whole
has() { printf '%s\n' "$1" | grep -qxF -- "$2" || die "$3: expected the line: $2"; }

# THE TOKEN: no capture holds the demo token, raw - counted on each run's own output BEFORE masking - and neither does anything
# this unit ships for reading, nor any binary this run built
for f in .harness/raw-*; do [ "$(cat "$f")" = 0 ] || die "a capture's raw output held the demo token ($f)"; done
NBIN=0
for f in .r-*.out README.md exercise/README.md exercise/solution/SOLUTION.md receipts.md5 harness/ttfr.py harness/shutdown.sh harness/hints/ValidatorHints.java after/README.md .harness/nat-*/$BIN; do
  [ -f "$f" ] || continue; case $f in .harness/nat-*) NBIN=$((NBIN + 1)) ;; esac
  [ "$(raw "$TOKEN" "$f")" = 0 ] || die "$f holds the demo token, raw"; done
[ "$NBIN" = 5 ] || die "five binaries were built, $NBIN were checked"
for f in .r-*.out; do ! grep -qE '/Users/|/private/|/home/' "$f" || die "$f holds an absolute path"; ! grep -qF "$GRAALVM_HOME" "$f" || die "$f holds the GraalVM's folder"; ! grep -qE 'c[0-9]-unit[0-9]|unit ?[0-9]' "$f" || die "$f holds a unit number"; done
echo "  token: 0 raw copies in $(ls .harness/raw-* | wc -l | tr -d ' ') raw capture runs, in $(ls .r-*.out | wc -l | tr -d ' ') captures, the READMEs, the harness, receipts.md5 and the $NBIN binaries; no absolute path, no GraalVM folder, no unit number in any capture"

# "TiffinBox does three things that build cannot follow": the router finds its routes and calls one, Jackson writes every answer,
# Hibernate Validator calls the token rule - where after/'s code does each (change), and each one breaking on its own (breaks)
x change '^  TiffinBoxServer\.java:[0-9]+: for \(Method m : getClass\(\)\.getDeclaredMethods\(\)\) \{$'
x change '^  TiffinBoxServer\.java:[0-9]+: respond\(exchange, 200, handler\.invoke\(this\)\);$'
x change '^  TiffinBoxServer\.java:[0-9]+: byte\[\] body = JSON\.writeValueAsBytes\(value\);$'
x change '^  TiffinBoxProperties\.java:[0-9]+: public boolean isShutdownTokenLongEnough\(\) \{$'
# "Spring has a fix for each: hints ... At-Reflective on the Route annotation ... at-RegisterReflectionForBinding on the server,
# naming Customer ... at-Reflective on the token rule itself." - one annotation and its import per file, nothing else in Java
[ "$(n change '^  Files ')" = 5 ] || die "change: five files differ"
CA=$(blk change '  tiffinbox-web/src/main/java/com/tiffinbox/web/Route.java:' '  tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java:')
CB=$(blk change '  tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java:' '  tiffinbox-core/src/main/java/com/tiffinbox/TiffinBoxProperties.java:')
CC=$(blk change '  tiffinbox-core/src/main/java/com/tiffinbox/TiffinBoxProperties.java:' "after/'s tiffinbox-web/pom.xml")
for b in "$CA" "$CB" "$CC"; do [ "$(printf '%s\n' "$b" | grep -vc '^    (diff ')" = 2 ] || die "change: a Java file gains a line that is neither its annotation, its import, a comment nor blank"; done
has "$CA" "    @Reflective" "change Route"; has "$CA" "    import org.springframework.aot.hint.annotation.Reflective;" "change Route"
has "$CB" "    @RegisterReflectionForBinding(Customer.class)" "change TiffinBoxServer"; has "$CB" "    import org.springframework.aot.hint.annotation.RegisterReflectionForBinding;" "change TiffinBoxServer"
has "$CC" "        @Reflective" "change TiffinBoxProperties"; has "$CC" "    import org.springframework.aot.hint.annotation.Reflective;" "change TiffinBoxProperties"
printf '%s\n' "$CA" "$CB" "$CC" | grep '^    (diff removes ' | awk '{ split($0, a, " - comment lines "); split(a[1], r, "removes "); split(a[2], c, " "); if (r[2] + 0 != c[1] + 0) bad = 1 } END { exit bad }' || die "change: diff removed a line that is not a comment"
x change '^                <groupId>org\.springframework\.boot</groupId>$'
x change '^                <artifactId>spring-boot-docker-compose</artifactId>$'
[ "$(n change '^                <groupId>tools\.jackson\.core</groupId>$')" = 2 ] || die "change: the two Jackson 3 exclusions"
# "On a plain JVM they change nothing you can see. The jar before and after serves the same seven responses, hash for hash."
x change '^  the two executable jars, entry by entry: entries 170 and 170 · the same name and content \(CRC-32\): 166 · different: 4 - BOOT-INF/classes/com/tiffinbox/web/Route\.class BOOT-INF/classes/com/tiffinbox/web/TiffinBoxServer\.class BOOT-INF/lib/tiffinbox-core-1\.0\.0\.jar META-INF/maven/com\.tiffinbox/tiffinbox-web/pom\.xml$'
x change "^  the names under BOOT-INF/lib/ of both: the same: yes · jars under it: 31 · the Compose module's or Jackson 3's among them: 0\$"
[ "$(n change "^  exit 0 · the seven responses: 7 lines · md5 $S115\$")" = 2 ] || die "change: both jars serve the seven, 115c36ba..."
[ "$(n change ' · offline: yes · exit 0$')" = 2 ] || die "change: two offline builds"
echo "  change: the three call sites · 5 files · one annotation (+ import) per Java file · the 3 exclusions · jars 166 of 170 the same, 31 jars, no Compose, no Jackson 3 · 115c36ba... x2"

# "Spring's AOT step, on the plain JDK, writes its reachability metadata ... Two hundred sixty-two entries became two hundred
# sixty-three. Customer is new, with its four accessors. The server's entry gained its five routes. The settings record gained
# the token rule." "A RuntimeHintsRegistrar ... registered the token rule instead of the annotation. The file came out the same,
# byte for byte."
x metadata '^  the JDK Maven ran on \(mvn -version\): Java version: 25\.0\.4\.1 · a native-image in it: no$'
x metadata "^  reflection entries: 262 and 263 · the same in both: 260 · only in the previous tree's: 0 · only in after/'s: 1 · different: 2 · resources: 16 and 16, the same: yes\$"
x metadata "^  only in after/'s: com\.tiffinbox\.Customer · allDeclaredFields · allDeclaredConstructors · methods mealsPerDay mealType name pricePerMeal\$"
x metadata '^  different: com\.tiffinbox\.TiffinBoxProperties · allDeclaredFields · methods <init> -> <init> isShutdownTokenLongEnough$'
x metadata '^  different: com\.tiffinbox\.web\.TiffinBoxServer · allDeclaredFields · methods start stop -> customers dashboard kitchen revenue shutdown start stop$'
x metadata '^  entries for com\.tiffinbox\.web\.Route: 0 and 0$'
x metadata "^  Boot's first line: Starting AOT-processed TiffinBoxServer v1\.0\.0 using Java 25\.0\.4\.1\$"
x metadata "^  exit 0 · the seven responses: 7 lines · md5 $S115\$"
x metadata '^  lines deleted: 1$'
x metadata '^    @org\.springframework\.context\.annotation\.ImportRuntimeHints\(ValidatorHints\.class\) public class TiffinBoxApp \{$'
x metadata "^    \|                 ReflectionUtils\.findMethod\(TiffinBoxProperties\.class, \"isShutdownTokenLongEnough\"\), ExecutableMode\.INVOKE\);\$"
x metadata "^  E's reachability-metadata\.json against after/'s, byte for byte: the same\$"
[ "$(n metadata ' · offline: yes · exit 0$')" = 3 ] || die "metadata: three offline builds"
grep -q 'TiffinBoxApp' after/tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxApp.java && ! grep -q 'ImportRuntimeHints' after/tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxApp.java || die "after/'s TiffinBoxApp must not import runtime hints"
cmp -s after/tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxApp.java "$PREV/tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxApp.java" || die "TiffinBoxApp.java changed: it must not (brief ⚑9)"
echo "  metadata: the plain JDK · 262 -> 263 · Customer new, 4 accessors · the server +5 routes · the record +the token rule · Route 0 · the AOT jar 115c36ba... · E (registrar on a copy's TiffinBoxApp): the same file, byte for byte · after/'s TiffinBoxApp unedited"

# "Rebuilt here, last lesson's binary still stops on the third. Hibernate Validator called the token rule, and nothing had
# registered it." "Build the binary ... Eight stages, and build success." "Boot's first line says AOT-processed, and the seven
# responses match the jar's" "The native plugin builds from Maven's class path, not from the jar's ... thirty-four names from
# the Compose module, nine hundred ninety-one from Jackson 3. With three exclusions in the plugin: zero, and three names Spring
# Boot's own JSON code mentions."
NP=$(blk native 'the previous tree - the AOT lesson' 'after/ - the three hints'); NA=$(blk native 'after/ - the three hints' '')
[ "$(n native '^  built \.harness/nat-[pa] \(both modules, into \$M2\) · offline: yes · exit 0$')" = 2 ] || die "native: two offline installs"
[ "$(n native '^  exit 0 · BUILD SUCCESS · stages it printed: 8 of the 8 it announces · its duration, against the bound: 1 minute or more, under 10 minutes$')" = 2 ] || die "native: two green builds, 8 of 8, 1-10 min"
has "$NP" "  the jars on native-image's class path (the plugin's command line, names only): 36 · in the executable jar's BOOT-INF/lib: 31 · only in the jar: spring-boot-jarmode-tools-4.1.1.jar" "native, the previous tree"
has "$NP" "  only on native-image's: jackson-core-3.1.5.jar jackson-databind-3.1.5.jar spring-boot-docker-compose-4.1.1.jar spring-boot-starter-4.1.1.jar spring-boot-starter-logging-4.1.1.jar spring-boot-starter-validation-4.1.1.jar" "native, the previous tree"
has "$NP" "  in the binary's bytes, distinct names under org.springframework.boot.docker.compose.: 34 · under tools.jackson.: 991" "native, the previous tree"
has "$NP" "  listened on: nothing" "native, the previous tree"
has "$NP" "    Caused by: org.graalvm.nativeimage.MissingReflectionRegistrationError: Cannot reflectively invoke method 'public boolean com.tiffinbox.TiffinBoxProperties.isShutdownTokenLongEnough()'." "native, the previous tree"
printf '%s\n' "$NP" | grep -qE "^  its first frame outside GraalVM's own and the JDK's: org\.hibernate\.validator\.internal\.util\.ReflectionHelper\.getValue\(ReflectionHelper\.java:[0-9]+\)\$" || die "native, the previous tree: Hibernate Validator's frame"
printf '%s\n' "$NP" | grep -qE '^  exit 1 · listening on 18914 now: 0 · ' || die "native, the previous tree: exit 1"
has "$NA" "    --- native:1.1.8:compile-no-fork (default-cli) @ tiffinbox-web ---" "native, after/"
has "$NA" "    Found GraalVM installation from GRAALVM_HOME variable." "native, after/"
has "$NA" "    Java version: 25.0.4.1+1, vendor version: GraalVM CE 25.3.4.1+1.1" "native, after/"
has "$NA" "    BUILD SUCCESS" "native, after/"
has "$NA" "  file: Mach-O 64-bit executable · the demo token in its bytes: 0" "native, after/"
has "$NA" "  the jars on native-image's class path (the plugin's command line, names only): 33 · in the executable jar's BOOT-INF/lib: 31 · only in the jar: spring-boot-jarmode-tools-4.1.1.jar" "native, after/"
has "$NA" "  only on native-image's: spring-boot-starter-4.1.1.jar spring-boot-starter-logging-4.1.1.jar spring-boot-starter-validation-4.1.1.jar" "native, after/"
[ "$(printf '%s\n' "$NA" | grep -c '^    spring-boot-starter[a-z-]*-4\.1\.1\.jar - its class files: 0$')" = 3 ] || die "native, after/: three starters, no class in any"
has "$NA" "  in the binary's bytes, distinct names under org.springframework.boot.docker.compose.: 0 · under tools.jackson.: 3" "native, after/"
has "$NA" "    each one named in a class of spring-boot-4.1.1.jar, under org/springframework/boot/json/: 3 of 3" "native, after/"
has "$NA" "  Boot's first line: Starting AOT-processed TiffinBoxServer using Java 25.0.4.1" "native, after/"
has "$NA" "  exit 0 · the seven responses: 7 lines · md5 $S115" "native, after/"
echo "  native: the previous tree - 8 of 8, 36 jars, Compose 34 and Jackson 3 991 names, exit 1 on the token rule, Hibernate Validator's frame · after/ - 8 of 8, 33 jars (+3 empty starters), 0 and 3 (spring-boot's JSON classes name them), AOT-processed, 115c36ba..."

# "A is the binary with all three. B deletes the binding hint ... Its metadata loses Customer. Slash customers now answers five
# hundred: InvalidDefinitionException, from Jackson. The other six answers are unchanged. A again: the same seven." "C deletes
# the route hint. The router still finds all five routes ... Calling one is not ... no answer in five seconds ... POST shutdown
# ... no answer either, and a kill stops it." "D deletes the token rule's hint and keeps the other two. The binary stops at start"
BA=$(blk breaks 'A - after/' 'B - '); BB=$(blk breaks 'B - ' "A' - "); BA2=$(blk breaks "A' - " 'C - '); BC=$(blk breaks 'C - ' 'D - '); BD=$(blk breaks 'D - ' '')
has "$BA" "  exit 0 · the seven responses: 7 lines · md5 $S115" "breaks A"
[ "$(printf '%s\n' "$BA" | grep -c '^  [A-Z]* *  /[a-z]* *-> ')" = 7 ] || die "breaks A: seven response lines"
has "$BB" "  lines deleted: 1" "breaks B"
has "$BB" "  reflection entries: 263 and 262 · the same in both: 262 · only in A's: 1 · only in B's: 0 · different: 0 · resources: 16 and 16, the same: yes" "breaks B"
has "$BB" "  only in A's: com.tiffinbox.Customer · allDeclaredFields · allDeclaredConstructors · methods mealsPerDay mealType name pricePerMeal" "breaks B"
has "$BB" '  GET   /customers  -> 500 application/json  {"error":"InvalidDefinitionException"}' "breaks B"
has "$BB" "  response lines different from A's: 1 - GET /customers" "breaks B"
printf '%s\n' "$BB" | grep -qE '^  exit 0 · the seven responses: 7 lines · md5 [0-9a-f]{32}$' || die "breaks B: the binary stopped after POST /shutdown"
has "$BA2" "  exit 0 · the seven responses: 7 lines · md5 $S115" "breaks A'"
has "$BA2" "  its seven against A's, line for line: the same" "breaks A'"
[ "$(printf '%s\n' "$BA" | grep '^\$ cd ')" = "$(printf '%s\n' "$BA2" | grep '^\$ cd ')" ] || die "breaks: A' is not A's command"
has "$BC" "  different: com.tiffinbox.web.TiffinBoxServer · allDeclaredFields · methods customers dashboard kitchen revenue shutdown start stop -> start stop" "breaks C"
has "$BC" "  TiffinBox's own line: routes mapped:  [GET /customers, GET /dashboard, GET /kitchen, GET /revenue, POST /shutdown]" "breaks C"
has "$BC" "  printed: 000 · curl exit 28" "breaks C"
has "$BC" "  POST /shutdown -> 000 · curl exit 28" "breaks C"
has "$BC" "  still running: yes · its standard error, each line naming a thread, to the method it names:" "breaks C"
has "$BC" "    Exception in thread \"\" org.graalvm.nativeimage.MissingReflectionRegistrationError: Cannot reflectively invoke method 'java.lang.Object com.tiffinbox.web.TiffinBoxServer.kitchen()'." "breaks C"
has "$BC" "    Exception in thread \"\" org.graalvm.nativeimage.MissingReflectionRegistrationError: Cannot reflectively invoke method 'java.lang.Object com.tiffinbox.web.TiffinBoxServer.shutdown()'." "breaks C"
has "$BC" "  exit 143 · listening on 18916 now: 0" "breaks C"
has "$BD" "  different: com.tiffinbox.TiffinBoxProperties · allDeclaredFields · methods <init> isShutdownTokenLongEnough -> <init>" "breaks D"
has "$BD" "  listened on: nothing" "breaks D"
has "$BD" "    Caused by: org.graalvm.nativeimage.MissingReflectionRegistrationError: Cannot reflectively invoke method 'public boolean com.tiffinbox.TiffinBoxProperties.isShutdownTokenLongEnough()'." "breaks D"
printf '%s\n' "$BD" | grep -qE '^  exit 1 · listening on 18917 now: 0 · ' || die "breaks D: exit 1"
[ "$(n breaks '^  exit 0 · BUILD SUCCESS · stages it printed: 8 of the 8 it announces · its duration, against the bound: 1 minute or more, under 10 minutes$')" = 3 ] || die "breaks: three green builds"
[ "$(n breaks '^  built \.harness/nat-[bcd] \(both modules, into \$M2\) · offline: yes · exit 0$')" = 3 ] || die "breaks: three offline installs"
[ "$(n breaks '^  the demo token in its bytes: 0 · ')" = 3 ] || die "breaks: no token in a binary"
echo "  breaks: A 115c36ba... · B Customer gone, /customers 500 InvalidDefinitionException, 1 line of 7 · A' = A · C routes mapped 5, no answer in 5 s (GET, POST /shutdown), invoke kitchen()/shutdown(), SIGTERM 143 · D exit 1 on the token rule"

# "Same clock, from the process's start to its first answer, two ways, six rounds, the first a warm-up, on this Mac." "The
# binary's middle run: under a tenth of a second, and under a tenth of the jar's." (The jar's own seconds are a reference, judged
# only through the ratio: they moved from about 1.3 s to about 1.6 s between two runs of this script, on the same Mac.)
x ladder '^  every run: a 200, then exit 0 after POST /shutdown: 12 of 12$'
x ladder '^the 5 counted rounds - each way'
x ladder '^  2 the binary: its median over 0\.01 s and under 0\.1 s: yes$'
x ladder "^  2 against 1: the binary's median under a tenth of the jar's: yes\$"
echo "  ladder: 12 of 12 served · the binary's median 0.01-0.1 s, under a tenth of the jar's"

# the exercise's end state: the line exercise/README.md calls "Done" is a line of this capture, after the solution's line - and of
# SOLUTION.md's measured run
XE=$(blk exercise "the solution's line" '')
l='com.tiffinbox.Customer entries - with the hint: 1, methods mealsPerDay mealType name pricePerMeal · deleted, built again: 0'
has "$XE" "$l" "exercise"
awk '/^\*\*Done\*\*/ { f = 1 } f' exercise/README.md | grep -qxF -- "$l" || die "exercise/README.md: Done names no such line"
grep -qxF -- "$l" exercise/solution/SOLUTION.md || die "SOLUTION.md: the measured run shows no such line"
x exercise '^  exit 0 · printed: [0-9]+ line\(s\)$'
echo "  exercise: the README as written, then the solution's line -> with the hint 1, four accessors · deleted 0"

# the anchor's README states the same numbers
grep -qF '262 reflection entries before,' after/README.md && grep -qF '263 after' after/README.md || die "after/README.md: the metadata counts"
grep -qF '`500 {"error":"InvalidDefinitionException"}`' after/README.md || die "after/README.md: B's answer"
grep -qF '34 distinct names' after/README.md && grep -qF '991 from Jackson 3' after/README.md || die "after/README.md: the binary's bytes"
grep -qF 'the binary under a tenth of a second' after/README.md || die "after/README.md: the start"
[ -z "$unpub" ] || die "no published hash for:$unpub - check the captures, then copy the md5s above into receipts.md5 and run again"
echo "c5-unit20: every capture 3/3 and = published; every spoken number asserted; 0 raw demo tokens in every capture"
