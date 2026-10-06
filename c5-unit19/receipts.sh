#!/bin/bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25.0.4.1 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# GRAALVM_HOME names a GraalVM JDK 25 (README.md, "The GraalVM"): the native build reads it. Without it, this script makes every
# capture that needs no GraalVM - the JVM's, and the exercise's - filling .m2-demo on the way, then stops before the native build.
# Course 5 · AOT Processing and Native Image - this unit's receipts. Spring's ahead-of-time step (AOT) settles TiffinBox's
# configuration while the jar is built: it writes the bean definitions as Java code, and a reachability-metadata.json for a
# closed-world build. The anchor change: tiffinbox-web/pom.xml declares GraalVM's Native Build Tools plugin, bare (Boot's
# parent manages 1.1.8). This script builds the trees, opens what the AOT step wrote, runs its jar on the JVM, shows the
# setting it froze, times the start from outside, builds the native binary and runs it. Eight captures, each run three times
# and hashed; cap() DIES when a hash differs from receipts.md5; every number the video says is asserted at the bottom by a
# check that can fail; the demo token is masked (gsub), and the last checks count 0 raw copies of it - and of the exercise's
# own token - in every capture, every file this unit ships, and the native binary itself.
#   change    the previous tree against after/: the files that differ, the POM's new lines; both trees built the plain way
#             (the jars, entry by entry) and with Boot's profile native (the goals each build ran on tiffinbox-web)
#   generated after/ built with the profile native, on the plain JDK: what process-aot wrote - sources, classes, resources -
#             one generated bean definition whole, native-image.properties whole, reachability-metadata.json's keys and
#             TiffinBox's entries in it; the jar's manifest; what the plugin's add-reachability-metadata copied
#   onjvm     that jar on the JVM: A as the README runs it · B with -Dspring.aot.enabled=true · A' = A - Boot's first line and
#             the seven responses; then the harness (harness/aot/Frozen.java) counts the context's bean definitions, A/B/A'
#   frozen    the break - the harness, the switch spring.threads.virtual.enabled on: A the JVM · B AOT · A' = A; C a second
#             copy built with the switch on, run with AOT and without the switch; the bean method process-aot wrote down for
#             Boot's executor in each tree, and the condition on each of the two candidates (javap, Boot's own class)
#   async     a harness with an @Async method (harness/aot/Calls.java), processed ahead of time by the class process-aot
#             runs: A the JVM, the switch on · B AOT, the switch on · A' = A
#   ladder    the start, timed from outside the JVM (harness/ttfr.py: from the fork to the first 200): six ways, six rounds,
#             round 1 a warm-up - the executable jar · + Spring's AOT · the jar extracted · + the JDK's AOT cache · + both ·
#             the executable jar + the JDK's AOT cache; the executable jar's median against a floor, every other way's against
#             the executable jar's (a ratio) - never their seconds (those go to the terminal)
#   native    the README's native build of a copy of after/ (GraalVM's version, the plugin's, the stages, what the analysis
#             found reachable, the result, its duration against a bound), the binary and its strings, the binary run from
#             beside its config tree - the exception it stops on and every cause under it; C native:compile from the root
#   exercise  exercise/README.md's commands and exercise/solution/SOLUTION.md's, read from the files and run as written
# "before" is ../c5-unit17/after (the anchor as the Compose lesson left it), COPIED to .harness/before; this script never
# writes into another unit's folder. after/ is this unit's frozen copy of ../c5-tiffinbox after the change; it is copied,
# never built in place. Every run of TiffinBox starts in a folder under .harness/ that holds a config tree with the demo token
# (secrets/), as the README asks: TiffinBox does not start without its token. Commands are printed exactly as they run: each
# goes through eval. "$CURLSET" is the comparison set since the secrets lesson (../c5-unit11/curlset.sh: the seven requests,
# POST /shutdown with the token's header read from the file). "$M2" is this unit's own repository, .m2-demo.
# The network: every build runs offline (-o) against .m2-demo and says so ("offline: yes"); a build that cannot resolve an
# artifact offline goes to Maven Central once, and says that ("offline: no - ..."). One more way out is caught, never allowed:
# GraalVM's native plugin, under the profile native, reads its metadata repository (a zip) from .m2-demo - and when the zip is
# not there, it does not fail, even under -o: it downloads the zip from GitHub (README.md, The repository). So a native-profile
# build without the zip goes to Maven Central for it, never offline first; and every build's log is searched for the plugin's
# own download line: if the plugin went to GitHub, the build's line says "offline: no", and the run stops.
# Masks and filters (README.md declares each; sub/gsub only): the demo token becomes "[masked: the 26-character token]"; the
# GraalVM's folder "$GRAALVM_HOME"; this folder's absolute path "…", the folder above it "…/..", the home folder "~"; your user
# name "<user>" - in every line of every capture. A Boot log line is printed from its message on, and its first line is cut
# before " with PID". Maven's and native-image's logs are read, never printed whole: the lines a capture shows are named, and
# the rest counted. No duration is captured: each one is judged against a bound, and its seconds go to the terminal.
# Ports (brief ⚑10, 18900-18909): onjvm 18900 (A, A'), 18901 (B), its harness 18902 (A, A'), 18903 (B) · frozen 18904 (A, A'),
# 18905 (B), 18906 (C) · async 18907 (A, A'), 18908 (B) · ladder 18909 (the training runs and every timed start) · native
# 18909 (the binary's run). 18425 is checked free too: it is TiffinBox's default port.
set -e
# bash 5.2 and later turn an & in the replacement of ${x/pattern/replacement} into the matched text (patsub_replacement, on by
# default): start()'s "&& exec " would become "&& && exec ". Switched off, so /bin/bash 3.2 (./receipts.sh) and a newer bash
# (bash receipts.sh) run the same commands; 3.2 has no such option.
shopt -u patsub_replacement 2> /dev/null || true
cd "$(dirname "$0")"
# One run at a time: two runs share .harness/ and the ports, and one would corrupt the other.
mkdir .r-lock 2> /dev/null || { echo "  *** another receipts.sh is running in this folder (.r-lock exists) - if none is, rmdir .r-lock ***"; exit 1; }
# On every exit - the end, a failed check, or Ctrl-C - stop the process this script started in the background, if it still
# runs, and drop the lock. A background job of a non-interactive shell ignores the terminal's Ctrl-C, so without the kill an
# interrupted run would leave TiffinBox listening. $pid is cleared whenever the process has been reaped. Maven, native-image
# and harness/ttfr.py run in the foreground: Ctrl-C reaches them, and ttfr.py stops the JVM it started before it exits. The
# clean-up ignores a second Ctrl-C, and nothing in it can fail under set -e, so it always reaches the rmdir; the script still
# exits 130 after an interrupt (tested: README.md, "Interrupted"). Then sweep(): anything of a native build still alive in this
# run's process group, and the binary, is stopped - native-image's builder runs as "java @…/vminvocation.args", with no class
# name to look for.
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
command -v openssl > /dev/null || die "openssl is needed: the exercise's README makes its own token with it"
# A variable of yours must not become a property source, a JVM flag, a build setting or a native-image option: every
# TIFFINBOX_* and SPRING_* variable, the two variables that inject JVM flags, MAVEN_OPTS, MAVEN_ARGS and NATIVE_IMAGE_OPTIONS are
# removed first. GRAALVM_HOME stays: it says which GraalVM to use.
for v in $(env | sed -n 's/^\(TIFFINBOX_[A-Za-z0-9_]*\|SPRING_[A-Za-z0-9_]*\|JAVA_TOOL_OPTIONS\|JDK_JAVA_OPTIONS\|MAVEN_OPTS\|MAVEN_ARGS\|NATIVE_IMAGE_OPTIONS\)=.*/\1/p'); do unset "$v"; done
# The GraalVM: named by GRAALVM_HOME, never guessed and never printed (its folder is masked). The captures were made with
# GraalVM CE 25.3.4.1 (native-image 25.0.4.1); another build would print other lines, so it is refused here, not 3 minutes in.
# Not set at all: no native build - the run fills .m2-demo, makes every capture that needs no GraalVM, the exercise's included,
# and stops where the native build would start (GOK=no).
GOK=yes
if [ -z "${GRAALVM_HOME:-}" ]; then GOK=no; unset GRAALVM_HOME
  echo "  GRAALVM_HOME is not set: this run fills .m2-demo, makes the captures that need no GraalVM - the JVM's, and the exercise's - and stops before the native build (README.md, The GraalVM)"
else
  [ -x "$GRAALVM_HOME/bin/native-image" ] || die "GRAALVM_HOME must name a GraalVM JDK 25 (its bin/native-image) - README.md, The GraalVM"
  NIV=$("$GRAALVM_HOME/bin/native-image" --version 2>&1 || true)
  printf '%s\n' "$NIV" | grep -q '^native-image 25\.0\.4\.1 ' && printf '%s\n' "$NIV" | grep -q 'GraalVM CE 25\.3\.4\.1+1\.1' || die "the published captures were made with GraalVM CE 25.3.4.1 (native-image 25.0.4.1); GRAALVM_HOME gives: $(printf '%s\n' "$NIV" | head -1)"
  export GRAALVM_HOME; fi
[ -e secrets ] && die "this folder holds a secrets/ - remove it: every run here starts in a folder under .harness/"
[ -e after/secrets ] || [ -e after/tiffinbox-local.yaml ] || [ -e after/target ] && die "after/ holds a secrets/, a tiffinbox-local.yaml or a target/ - it is the anchor's frozen copy, never built in place; remove them"
M2="$PWD/.m2-demo"; U="$PWD"; UP="$(cd .. && pwd)"; ME="$(id -un)"
PREV=../c5-unit17/after                              # the previous tree: read, copied, never built in place
JAR=tiffinbox-web/target/tiffinbox-web-1.0.0.jar
TF=secrets/tiffinbox/shutdown-token                  # the config tree's file for tiffinbox.shutdown-token
# The demo token. FAKE, and meant to look it: it guards nothing but a demo server on 127.0.0.1 that every capture stops. It is
# written into .harness/*/secrets/ (git-ignored) when this script runs, and no capture prints it: see mask().
TOKEN=not-a-real-token-demo-only
[ ${#TOKEN} = 26 ] || die "the demo token must be 26 characters"
CURLSET=../c5-unit11/curlset.sh                      # the comparison set: the seven requests, POST /shutdown with the header
[ -f "$CURLSET" ] || die "$CURLSET is missing"
[ -f "$PREV/pom.xml" ] && [ -f after/pom.xml ] && [ -f after/README.md ] || die "the previous tree $PREV or after/ is missing"
[ -f harness/aot/Frozen.java ] && [ -f harness/aot/Calls.java ] && [ -f harness/ttfr.py ] || die "harness/ is missing a file"

# The ports, BEFORE anything is wiped (a survivor of an interrupted run answers POST /shutdown only with its token, which lives
# in .harness/ - so the message names the process to kill).
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
for p in 18425 18900 18901 18902 18903 18904 18905 18906 18907 18908 18909; do
  [ "$(listeners $p)" = 0 ] || die "something already listens on $p - this unit's ports must be free; if it is a TiffinBox an interrupted run left behind, stop it: kill $(lsof -nP -iTCP:$p -sTCP:LISTEN -t 2> /dev/null | paste -sd' ' -)"; done

# ---- the commands: read from after/README.md, the anchor's own, and asserted - each line must be there, whole -------------
readme() { grep -m1 -xF -- "$1" after/README.md > /dev/null || die "after/README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
R_PLAIN=$(readme 'mvn -B package')
R_PKG=$(readme 'mvn -B -Pnative package')
R_RUN=$(readme 'java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431')
R_AOTRUN=$(readme 'java -Dspring.aot.enabled=true -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431')
R_EXTRACT=$(readme 'java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted')
R_TRAIN=$(readme 'java -XX:AOTCacheOutput=tiffinbox-web/target/tiffinbox.aot -Dspring.aot.enabled=true -Dspring.context.exit=onRefresh -jar tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431')
R_CACHED=$(readme 'java -XX:AOTCache=tiffinbox-web/target/tiffinbox.aot -Dspring.aot.enabled=true -jar tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431')
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
C_PLAINB=$(off .harness/plain-before "$R_PLAIN" package); C_PLAINA=$(off .harness/plain-after "$R_PLAIN" package)
C_NPB=$(off .harness/np-before "$R_PKG" package); C_NPA=$(off .harness/np-after "$R_PKG" package)
C_GEN=$(off .harness/gen "$R_PKG" package); C_AFTER=$(off .harness/after "$R_INSTALL" install)
C_ON="$(off .harness/built-on "$R_PKG" package) -Dspring-boot.aot.jvmArguments=-Dspring.threads.virtual.enabled=true"
C_INSTALL=$(off .harness/native "$R_INSTALL" install); C_NATIVE=$(off .harness/native "$R_NATIVE")
C_ROOT="cd .harness/native && mvn -o -B -Dmaven.repo.local=\"\$M2\" -Pnative native:compile"
for c in "$C_PLAINB" "$C_PLAINA" "$C_NPB" "$C_NPA" "$C_GEN" "$C_AFTER" "$C_INSTALL" "$C_NATIVE"; do
  r=$(dev "$c"); [ "$r" = "$R_PLAIN" ] || [ "$r" = "$R_PKG" ] || [ "$r" = "$R_INSTALL" ] || [ "$r" = "$R_NATIVE" ] || die "not a README line with the offline changes: $c"; done
[ "$(dev "${C_ON% -Dspring-boot.aot.jvmArguments=*}")" = "$R_PKG" ] || die "C's build must be the README's, plus one property"
[ "${C_ROOT#cd .harness/native && }" = "mvn -o -B -Dmaven.repo.local=\"\$M2\" -Pnative native:compile" ] || die "the root's native:compile"
echo "  the commands: after/README.md gives all 11 lines this script runs or derives from"

# ---- build: the trees under .harness/, each a copy, each clean, offline first --------------------------------------------
rm -rf .harness; mkdir -p .harness
rsync -a --exclude target --exclude secrets "$PREV/" .harness/before/
rsync -a after/ .harness/after/
# ZIP: GraalVM's reachability metadata repository, as Maven Central serves it - the native plugin reads it from .m2-demo
ZIP="$M2/org/graalvm/buildtools/graalvm-reachability-metadata/1.1.8/graalvm-reachability-metadata-1.1.8-repository.zip"
# ghub LOG: the native plugin went over the network for its metadata repository - downloaded it (from GitHub, when the zip is not
# in $M2), or tried to (its own two lines). Never allowed: the caller says "offline: no" and stops.
ghub() { grep -qE 'Downloaded GraalVM reachability metadata repository from http|Failed to download from http' "$1"; }
# mbuild 'COMMAND' LOG LABEL [fails]: the command, run as printed (eval), its log kept in LOG (never printed whole); Maven
# Central only if the offline build could not resolve something - and the line says which (offline: yes / no), so a run that
# went online is never silent (inside a capture, "no" changes the capture's hash: cap() then dies). A native-profile build while
# the metadata repository is not in $M2 goes to Maven Central at once (offline, the plugin would fetch it from GitHub instead).
# A build meant to fail ("fails") must fail for its own reason, not for a missing artifact.
mbuild() { local how=yes ec=0 c=$1
  case $c in *' -Pnative '*) [ -f "$ZIP" ] || { c=${c/mvn -o -B /mvn -B }; how="no - GraalVM's metadata repository was not in .m2-demo, so Maven Central was asked for it"; } ;; esac
  (eval "$c") > "$2" 2>&1 < /dev/null || ec=$?
  if [ $ec != 0 ] && [ "$how" = yes ] && grep -qE 'offline mode|Could not resolve|could not be resolved|Cannot access' "$2"; then
    how="no - the offline build could not resolve an artifact, so Maven Central was asked"; ec=0
    (eval "${c/mvn -o -B /mvn -B }") > "$2" 2>&1 < /dev/null || ec=$?; fi
  if ghub "$2"; then echo "  $3 · offline: no - GraalVM's native plugin went to GitHub for its metadata repository · exit $ec"
    die "$3: GraalVM's native plugin went over the network for its metadata repository - $(grep -m1 -E 'Downloaded GraalVM reachability metadata repository from http|Failed to download from http' "$2" | sed 's/^\[[A-Z]*\] //') - README.md, The repository"; fi
  if [ "$4" = fails ]; then [ $ec != 0 ] || die "$3 was meant to fail, and passed"
    ! grep -qE 'Could not resolve|could not be resolved|Could not transfer|Cannot access' "$2" || die "$3 failed for a missing artifact, not for its own reason"
  else [ $ec = 0 ] || { tail -30 "$2" >&3
    ! grep -qE 'Could not resolve|could not be resolved|Could not transfer|Cannot access' "$2" || die "build failed: $3 - Maven could resolve Boot's parent and plugins neither from .m2-demo nor from Maven Central: a fresh clone's first run needs the network once, to fill .m2-demo"
    die "build failed: $3"; }; fi
  if [ "$4" = fails ]; then echo "  ran $3 · offline: $how · exit $ec"; else echo "  built $3 · offline: $how · exit $ec"; fi; }
# tree FOLDER: a config tree in FOLDER/secrets holding one file, the token and a newline, readable by its owner alone
tree() { mkdir -p "$1/secrets/tiffinbox"; (umask 077 && printf '%s\n' "$TOKEN" > "$1/$TF"); chmod 700 "$1/secrets" "$1/secrets/tiffinbox"; }
# The first build is the README's native install: it needs every artifact the captures' Maven lines need - the plain ones, the
# profile native's (process-aot, the plugin's add-reachability-metadata and its metadata repository) and install's - so on a
# fresh clone, whose .m2-demo is empty (git ignores it), this one build fills .m2-demo from Maven Central, once.
mbuild "$C_AFTER" .harness/build-after.log ".harness/after (after/, the profile native, both modules into \$M2)"
[ -f "$M2/org/springframework/boot/spring-boot-starter-parent/4.1.1/spring-boot-starter-parent-4.1.1.pom" ] || die "Boot's parent POM is not in .m2-demo after the first build"
[ -f "$M2/org/graalvm/buildtools/native-maven-plugin/1.1.8/native-maven-plugin-1.1.8.jar" ] || die "GraalVM's native plugin 1.1.8 is not in .m2-demo after the first build (it is a build extension of the web module)"
[ -f "$ZIP" ] || die "GraalVM's metadata repository is not in .m2-demo after the first build - README.md, The repository"
echo "  .m2-demo holds Boot's parent, GraalVM's native plugin 1.1.8 and its metadata repository ($(wc -c < "$ZIP" | tr -d ' ') bytes)"
tree .harness/after
rsync -a --exclude target after/ .harness/built-on/; tree .harness/built-on
mbuild "$C_ON" .harness/build-on.log ".harness/built-on (after/ again, the switch on while process-aot runs)"
XD=${R_EXTRACT##* }                                  # the README's extract destination, inside a tree's target/
for t in after built-on; do (cd ".harness/$t" && eval "$R_EXTRACT") > ".harness/extract-$t.log" 2>&1 || { cat ".harness/extract-$t.log" >&3; die "the README's extract command failed in .harness/$t"; }; done
HCP="tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*"
javac -cp ".harness/after/$XD/tiffinbox-web-1.0.0.jar:.harness/after/$XD/lib/*" -d .harness/classes harness/aot/Frozen.java harness/aot/Calls.java || die "the harness did not compile"
echo "  the harness: compiled against the jar process-aot left in .harness/after, extracted as the README says"

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
# up: the line after a start - where it listens, its WARN/ERROR lines so far, Boot's first line; dies if it never listened
up() { local l; l=$(listening); [ "$l" != nothing ] || { tail -20 .harness/run.out >&3; die "it never listened"; }
  echo "  listens on: $l · $(warns .harness/run.out)"; echo "  Boot's first line: $(first .harness/run.out)"; }
# seven PORT DIR: the comparison set's seven requests (POST /shutdown carries the header, read from DIR's token file), printed
# as run; the process must leave within 15 s of them, and the port must be free again. Never call it inside $(...): wait needs
# this shell.
seven() { local i e=0
  echo "\$ \$CURLSET $1 $2/$TF"
  "$CURLSET" "$1" "$2/$TF" | grep ' -> ' > .harness/responses.txt || true
  grep '^POST ' .harness/responses.txt || echo "(no POST line)"
  i=0; while kill -0 "$pid" 2> /dev/null && [ $i -lt 60 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$pid" 2> /dev/null && { kill "$pid"; die "the server on $1 was still running 15 s after POST /shutdown"; }
  wait "$pid" || e=$?; pid=""
  [ "$(listeners "$1")" = 0 ] || die "something still listens on $1"
  echo "  exit $e · the seven responses: $(wc -l < .harness/responses.txt | tr -d ' ') lines · md5 $(md5 -q .harness/responses.txt)"; }
# harness 'COMMAND' PORT: print the command exactly as typed, run it (in the background, so a hung run can be stopped: it must
# exit within 60 s), then print the harness's own lines - its standard error, the definition list counted, not shown - and
# count Boot's log (its standard output)
harness() { local i=0 e=0
  start "$1"
  while kill -0 "$pid" 2> /dev/null && [ $i -lt 240 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$pid" 2> /dev/null && { kill "$pid"; die "the harness was still running after 60 s: $1"; }
  wait "$pid" || e=$?; pid=""
  grep -v '^  definition ' .harness/run.err || true
  grep '^  definition ' .harness/run.err | sed 's/^  definition //' > .harness/defs.txt || true
  [ "$(grep -c '^  definition ' .harness/run.err || true)" = 0 ] || echo "  (the definitions' names: $(wc -l < .harness/defs.txt | tr -d ' ') lines, not shown)"
  echo "  Boot's log (standard output): $(wc -l < .harness/run.out | tr -d ' ') lines, not shown · $(warns .harness/run.out) · exit $e · listening on $2 now: $(listeners "$2")"; }

# mask: the demo token becomes a label naming its length; the GraalVM's folder "$GRAALVM_HOME"; this folder's path "…", the
# folder above it "…/..", the home folder "~" (each also in its URL form, spaces as %20); the user name "<user>" - in every
# line (gsub). The GraalVM's folder is masked before the home folder, which holds it (and not at all when GRAALVM_HOME is not set).
mask() { awk -v t="$TOKEN" -v g="${GRAALVM_HOME:-}" -v u="$U" -v up="$UP" -v hm="$HOME" -v me="$ME" '
  function lit(x) { gsub(/[][\\.^$*+?(){}|\/]/, "\\\\&", x); return x }
  function enc(x) { gsub(/ /, "%20", x); return x }
  BEGIN { T = lit(t); G = lit(g); GE = lit(enc(g)); P = lit(u); Q = lit(up); H = lit(hm); PE = lit(enc(u)); QE = lit(enc(up)); M = lit(me) }
  { gsub(T, "[masked: the 26-character token]"); if (g != "") { gsub(G, "$GRAALVM_HOME"); gsub(GE, "$GRAALVM_HOME") }; gsub(P, "…"); gsub(PE, "…")
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
# goals LOG: the goals Maven ran on tiffinbox-web, its own lines ("--- plugin:version:goal (execution) @ tiffinbox-web ---")
goals() { grep -E '^\[INFO\] --- .* @ tiffinbox-web ---$' "$1" | sed 's/^\[INFO\] --- //; s/ @ tiffinbox-web ---$//'; }
# causes LOG: the exception Boot's failure line names, then each 'Caused by: ' line, in order - each cut after the bean it names
# (GraalVM's, the last, after the method it names) - and before each, how many lines of the log are not shown: the whole chain,
# every gap counted (Course 4's rule)
causes() { awk -v q="'" '
  /^Application run failed$/ { f = NR; next }
  f && (NR == f + 1 || /^Caused by: /) {
    l = $0
    if (match(l, "Error creating bean with name " q "[^" q "]*" q)) l = substr(l, 1, RSTART + RLENGTH - 1) " …"
    else if (match(l, q "\\. To allow this operation")) l = substr(l, 1, RSTART + 1)
    if (p) printf "    … %d lines not shown …\n", NR - p - 1
    print "    " l; p = NR }' "$1"; }

# ---- change: the previous tree against after/ ---------------------------------------------------------------------------
change() { local d t
  echo "the previous tree - the anchor as the Compose lesson left it - against after/, both copied under .harness/:"
  echo "\$ diff -rq -x target -x secrets .harness/before .harness/after"
  (diff -rq -x target -x secrets .harness/before .harness/after || true) | sed 's/^/  /'
  echo "after/'s tiffinbox-web/pom.xml against the previous one - every line diff adds, its comment lines counted, not shown:"
  diff .harness/before/tiffinbox-web/pom.xml .harness/after/tiffinbox-web/pom.xml > .harness/pom.diff || true
  grep '^> ' .harness/pom.diff | sed 's/^> //' | awk '/^ *<!--/ { c = 1 } c { if (/-->/) c = 0; next } /^ *$/ { next } { print "  " $0 }'
  echo "  lines diff removes: $(grep -c '^< ' .harness/pom.diff || true) · adds: $(grep -c '^> ' .harness/pom.diff || true) - not shown: a comment of $(grep '^> ' .harness/pom.diff | sed 's/^> //' | awk '/^ *<!--/ { c = 1 } c { n++; if (/-->/) c = 0 } END { print n + 0 }') lines, and $(grep -c '^> *$' .harness/pom.diff || true) blank"
  echo "Boot's parent, the version it manages for that plugin (spring-boot-dependencies-4.1.1.pom, in \$M2):"
  echo "  $(grep -o '<native-build-tools-plugin.version>[^<]*</native-build-tools-plugin.version>' "$M2/org/springframework/boot/spring-boot-dependencies/4.1.1/spring-boot-dependencies-4.1.1.pom")"
  echo "both trees, built the plain way - the README's Maven line, offline, clean, each in a copy of its own:"
  for t in before after; do rm -rf ".harness/plain-$t"; rsync -a --exclude target ".harness/$t/" ".harness/plain-$t/"; rm -rf ".harness/plain-$t/secrets"; done
  echo "\$ $C_PLAINB"; mbuild "$C_PLAINB" .harness/build-plain-before.log "the previous tree"
  echo "\$ $C_PLAINA"; mbuild "$C_PLAINA" .harness/build-plain-after.log "after/"
  unzip -lv ".harness/plain-before/$JAR" | awk 'NF == 8 && $7 ~ /^[0-9a-f]{8}$/ { print $8, $7 }' | LC_ALL=C sort > .harness/ent-before.txt
  unzip -lv ".harness/plain-after/$JAR" | awk 'NF == 8 && $7 ~ /^[0-9a-f]{8}$/ { print $8, $7 }' | LC_ALL=C sort > .harness/ent-after.txt
  d=$(LC_ALL=C comm -3 .harness/ent-before.txt .harness/ent-after.txt | awk '{ print $1 }' | LC_ALL=C sort -u | paste -sd' ' -)
  echo "  the two executable jars, entry by entry: entries $(wc -l < .harness/ent-before.txt | tr -d ' ') and $(wc -l < .harness/ent-after.txt | tr -d ' ') · the same name and content (CRC-32): $(LC_ALL=C comm -12 .harness/ent-before.txt .harness/ent-after.txt | wc -l | tr -d ' ') · different: $(printf '%s\n' "$d" | wc -w | tr -d ' ') - ${d:-none}"
  echo "both trees, built with Boot's profile native - the README's line, offline, clean:"
  for t in before after; do rm -rf ".harness/np-$t"; rsync -a --exclude target ".harness/$t/" ".harness/np-$t/"; rm -rf ".harness/np-$t/secrets"; done
  echo "\$ $C_NPB"; mbuild "$C_NPB" .harness/build-np-before.log "the previous tree"
  echo "\$ $C_NPA"; mbuild "$C_NPA" .harness/build-np-after.log "after/"
  echo "  the goals each ran on tiffinbox-web that the plain build did not (Maven's own lines):"
  goals .harness/build-plain-before.log > .harness/g-plain.txt
  echo "  the previous tree: $(goals .harness/build-np-before.log | grep -vxF -f .harness/g-plain.txt | paste -sd'|' - | sed 's/|/ · /g')"
  echo "  after/: $(goals .harness/build-np-after.log | grep -vxF -f .harness/g-plain.txt | paste -sd'|' - | sed 's/|/ · /g')"; }
cap change change

# ---- generated: what process-aot wrote ------------------------------------------------------------------------------------
GEN=tiffinbox-web/target/spring-aot/main
META=resources/META-INF/native-image/com.tiffinbox/tiffinbox-web
generated() { local g=.harness/gen/$GEN
  rm -rf .harness/gen; rsync -a --exclude target after/ .harness/gen/
  echo "after/, copied to .harness/gen, built with Boot's profile native - the README's line, offline, clean, on the plain JDK:"
  echo "\$ $C_GEN"; mbuild "$C_GEN" .harness/build-gen.log ".harness/gen"
  echo "  the JDK Maven ran on (mvn -version): $(mvn -version 2>&1 | grep -m1 '^Java version: ' | sed 's/, vendor: .*$//') · a native-image in it: $( [ -e "$JAVA_HOME/bin/native-image" ] && echo yes || echo no)"
  echo "  the goals Maven ran on tiffinbox-web (its own lines; the rest of its log - $(grep -cv '^\[INFO\] --- .* @ tiffinbox-web ---$' .harness/build-gen.log || true) lines - not shown):"
  goals .harness/build-gen.log | sed 's/^/    /'
  echo "  process-aot ran TiffinBox's main to read its configuration - Boot's first line in the build's log: $(first .harness/build-gen.log) · lines saying TiffinBox listening: $(grep -c 'TiffinBox listening' .harness/build-gen.log || true)"
  echo "what process-aot wrote, $GEN/:"
  echo "  sources/: $(find "$g/sources" -type f -name '*.java' | wc -l | tr -d ' ') Java files · TiffinBox's own, under com/tiffinbox/: $(find "$g/sources/com/tiffinbox" -type f -name '*.java' | wc -l | tr -d ' ')"
  (cd "$g/sources" && find com/tiffinbox -type f -name '*.java' | sort) | sed 's/^/    /'
  echo "  classes/: $(find "$g/classes" -type f | wc -l | tr -d ' ') files · resources/: $(find "$g/resources" -type f | wc -l | tr -d ' ') files"
  (cd "$g" && find resources -type f | sort) | sed 's/^/    /'
  echo "one of TiffinBox's own, whole: sources/com/tiffinbox/web/TiffinBoxServer__BeanDefinitions.java ($(wc -l < "$g/sources/com/tiffinbox/web/TiffinBoxServer__BeanDefinitions.java" | tr -d ' ') lines; its blank lines not shown)"
  grep -v '^ *$' "$g/sources/com/tiffinbox/web/TiffinBoxServer__BeanDefinitions.java" | sed 's/^/  | /'
  echo "$META/native-image.properties, whole:"
  awk '{ print "  | " $0 }' "$g/$META/native-image.properties"
  echo "$META/reachability-metadata.json, read as JSON (python3):"
  python3 - "$g/$META/reachability-metadata.json" <<'PY'
import json, sys
d = json.load(open(sys.argv[1]))
print("  its top-level keys: " + " · ".join(k + (" " + str(len(v)) + " entries" if isinstance(v, list) else " " + json.dumps(v)) for k, v in d.items()))
mine = [e for e in d["reflection"] if isinstance(e.get("type"), str) and e["type"].startswith("com.tiffinbox.")]
print("  reflection entries naming com.tiffinbox: %d" % len(mine))
for e in mine:
    parts = [e["type"]] + [k for k, v in e.items() if v is True] + (["methods " + " ".join(m["name"] for m in e["methods"])] if "methods" in e else [])
    print("    " + " · ".join(parts))
for t in ("com.tiffinbox.Customer", "com.tiffinbox.web.Route"):
    print("  entries for %s: %d" % (t, sum(1 for e in d["reflection"] if e.get("type") == t)))
PY
  echo "  files named reflect-config.json anywhere under .harness/gen: $(find .harness/gen -name reflect-config.json | wc -l | tr -d ' ')"
  echo "the jar it packaged: its manifest says $(unzip -p ".harness/gen/$JAR" META-INF/MANIFEST.MF | tr -d '\r' | grep '^Spring-Boot-Native-Processed:') · its entries whose name ends __BeanDefinitions.class: $(unzip -Z1 ".harness/gen/$JAR" | grep -c '__BeanDefinitions\.class$' || true)"
  echo "what the plugin's add-reachability-metadata added, by its own log ($(grep -c '^\[INFO\] \[graalvm reachability metadata repository for ' .harness/build-gen.log || true) lines, counted):"
  echo "  $(grep -m1 '^\[INFO\] Using GraalVM reachability metadata repository version ' .harness/build-gen.log | sed 's/^\[INFO\] //')"
  echo "  reachability-metadata.json files it put under target/classes/META-INF/native-image/, beside Spring's: $(find .harness/gen/tiffinbox-web/target/classes/META-INF/native-image -name reachability-metadata.json -not -path '*/com.tiffinbox/*' | wc -l | tr -d ' ')"
  echo "  jars it found no entry for at their own version, so it took an older one's: $(grep -c 'Configuration directory not found. Trying latest version.$' .harness/build-gen.log || true) - H2's: $(grep -m1 'for com.h2database:h2:[^]]*\]: Configuration directory is ' .harness/build-gen.log | sed 's/^.*for \(com\.h2database:h2:[^]]*\)\]: Configuration directory is /\1 -> /')"; }
cap generated generated

# ---- onjvm: that jar on the JVM ------------------------------------------------------------------------------------------
onjvm() { local run
  echo "the jar process-aot left in .harness/after (README's native-profile build), on the JVM:"
  for run in "A|18900|$R_RUN" "B|18901|$R_AOTRUN" "A'|18900|$R_RUN"; do
    IFS='|' read -r lbl port cmd <<< "$run"
    case $lbl in
      A) echo "A - as the README runs it, its port 18431 made 18900:" ;;
      B) echo "B - the README's AOT run, -Dspring.aot.enabled=true, port 18901:" ;;
      *) echo "A' - A re-run:" ;; esac
    start "$(at .harness/after "$port" "$cmd")"; up; seven "$port" .harness/after; done
  echo "the harness (harness/aot/Frozen.java): TiffinBox's context, its main application class TiffinBoxServer, its bean definitions counted:"
  for run in "A|18902|" "B|18903|-Dspring.aot.enabled=true " "A'|18902|"; do
    IFS='|' read -r lbl port flag <<< "$run"
    case $lbl in
      A) echo "A - the JVM, port 18902:" ;;
      B) echo "B - -Dspring.aot.enabled=true, port 18903:" ;;
      *) echo "A' - A re-run, port 18902:" ;; esac
    harness "cd .harness/after && java ${flag}-cp \"../classes:$HCP\" aot.Frozen --tiffinbox.port=$port" "$port"
    cp .harness/defs.txt ".harness/defs-$lbl.txt"; done
  echo "  definitions in A and not in B: $(comm -23 .harness/defs-A.txt .harness/defs-B.txt | wc -l | tr -d ' ') · in B and not in A: $(comm -13 .harness/defs-A.txt .harness/defs-B.txt | wc -l | tr -d ' ') · A' against A: $(cmp -s .harness/defs-A.txt ".harness/defs-A'.txt" && echo the same names || echo different)"
  comm -23 .harness/defs-A.txt .harness/defs-B.txt | sed 's/^/    /'; }
cap onjvm onjvm

# ---- frozen: the break - a setting decided at build time -------------------------------------------------------------------
frozen() { local run n
  echo "the harness again, the switch on after the port - spring.threads.virtual.enabled=true:"
  for run in "A|18904||after| --spring.threads.virtual.enabled=true" "B|18905|-Dspring.aot.enabled=true |after| --spring.threads.virtual.enabled=true" "A'|18904||after| --spring.threads.virtual.enabled=true" "C|18906|-Dspring.aot.enabled=true |built-on|"; do
    IFS='|' read -r lbl port flag t sw <<< "$run"
    case $lbl in
      A) echo "A - the JVM, the switch on, port 18904:" ;;
      B) echo "B - the same, -Dspring.aot.enabled=true, port 18905:" ;;
      A\') echo "A' - A re-run:" ;;
      *) echo "C - a second copy, .harness/built-on, built with the switch on while process-aot ran; run with AOT, the switch not set, port 18906:"
         echo "\$ $C_ON" ;; esac
    harness "cd .harness/$t && java ${flag}-cp \"../classes:$HCP\" aot.Frozen --tiffinbox.port=$port$sw" "$port"; done
  echo "the code process-aot generated for Boot's executor, sources/org/springframework/boot/autoconfigure/task/TaskExecutorConfigurations__BeanDefinitions.java:"
  for t in after built-on; do
    n=$(sed -n 's/^.*BeanInstanceSupplier\.<\([A-Za-z]*\)>forFactoryMethod(TaskExecutorConfigurations\.TaskExecutorConfiguration\.class, "\(applicationTaskExecutor[A-Za-z]*\)".*$/the bean method \2, type \1/p' ".harness/$t/$GEN/sources/org/springframework/boot/autoconfigure/task/TaskExecutorConfigurations__BeanDefinitions.java")
    echo "  .harness/$t - the bean applicationTaskExecutor comes from: ${n:-(no such line)} · bean methods named for it: $(printf '%s\n' "$n" | grep -c . || true)"; done
  echo "the condition on each candidate, in Boot's own class - javap -v, TaskExecutorConfigurations\$TaskExecutorConfiguration, in \$M2's spring-boot-autoconfigure-4.1.1.jar:"
  javap -v -cp "$M2/org/springframework/boot/spring-boot-autoconfigure/4.1.1/spring-boot-autoconfigure-4.1.1.jar" 'org.springframework.boot.autoconfigure.task.TaskExecutorConfigurations$TaskExecutorConfiguration' 2> /dev/null | awk '
    /^  [^ #].*\(.*\);$/ { m = $0; sub(/\(.*$/, "", m); sub(/^.* /, "", m) }
    /ConditionalOnThreading\($/ { getline v; sub(/^.*Threading;\./, "", v); print "  the bean method " m " · @ConditionalOnThreading(" v ")" }'; }
cap frozen frozen

# ---- async: an @Async method, processed ahead of time ----------------------------------------------------------------------
C_PROC="cd .harness/after && java -cp \"../classes:$HCP\" org.springframework.boot.SpringApplicationAotProcessor aot.Calls ../calls/sources ../calls/resources ../calls/classes com.tiffinbox harness"
C_CJAVAC="javac -cp \".harness/calls/classes:.harness/classes:.harness/after/$XD/tiffinbox-web-1.0.0.jar:.harness/after/$XD/lib/*\" -d .harness/calls/classes \$(find .harness/calls/sources -name '*.java')"
async() { local run e=0
  echo "the harness with an @Async method (harness/aot/Calls.java) is its own application: processed ahead of time by the class process-aot runs,"
  echo "Boot's SpringApplicationAotProcessor (its main class, then where to write sources, resources and classes, then a group and an artifact name):"
  rm -rf .harness/calls
  echo "\$ $C_PROC"; (eval "$C_PROC") > .harness/proc.log 2>&1 < /dev/null || e=$?
  echo "  exit $e · Boot's log: $(wc -l < .harness/proc.log | tr -d ' ') lines, not shown · written: $(find .harness/calls/sources -name '*.java' | wc -l | tr -d ' ') Java files · $(find .harness/calls/classes -type f | wc -l | tr -d ' ') class files (proxy classes, made by the processor) · $(find .harness/calls/resources -type f | wc -l | tr -d ' ') resources"
  echo "\$ $C_CJAVAC"; e=0; (eval "$C_CJAVAC") > .harness/cjavac.log 2>&1 || e=$?
  echo "  exit $e · .harness/calls/classes now: $(find .harness/calls/classes -name '*.class' | wc -l | tr -d ' ') classes"
  for run in "A|18907|" "B|18908|-Dspring.aot.enabled=true " "A'|18907|"; do
    IFS='|' read -r lbl port flag <<< "$run"
    case $lbl in
      A) echo "A - the JVM, the switch on, port 18907:" ;;
      B) echo "B - -Dspring.aot.enabled=true, the switch on, port 18908:" ;;
      *) echo "A' - A re-run:" ;; esac
    harness "cd .harness/after && java ${flag}-cp \"../calls/classes:../calls/resources:../classes:$HCP\" aot.Calls --tiffinbox.port=$port --spring.threads.virtual.enabled=true" "$port"; done; }
cap async async

# ---- ladder: the start, timed from outside ------------------------------------------------------------------------------
# The README's three lines give ways 1, 2 and 5 and the training run; the others are those lines with a flag taken out (3, 4) or
# the executable jar in the extracted jar's place (6: the cache trained on, and run with, the jar itself).
T_PLAIN="${R_TRAIN/tiffinbox.aot -Dspring.aot.enabled=true /plain.aot }"
T_JAR="${T_PLAIN/plain.aot -Dspring.context.exit=onRefresh -jar tiffinbox-web\/target\/extracted\//jar.aot -Dspring.context.exit=onRefresh -jar tiffinbox-web/target/}"
W1=$(at .harness/after 18909 "$R_RUN"); W2=$(at .harness/after 18909 "$R_AOTRUN")
W5=$(at .harness/after 18909 "$R_CACHED"); W3=${W5/-XX:AOTCache=tiffinbox-web\/target\/tiffinbox.aot -Dspring.aot.enabled=true /}
W4=${W5/tiffinbox.aot -Dspring.aot.enabled=true /plain.aot }
W6=${W4/plain.aot -jar tiffinbox-web\/target\/extracted\//jar.aot -jar tiffinbox-web/target/}
[ "$W3" != "$W5" ] && [ "$W4" != "$W5" ] && [ "$W6" != "$W4" ] && [ "$T_PLAIN" != "$R_TRAIN" ] && [ "$T_JAR" != "$T_PLAIN" ] || die "the ladder's derived commands"
[ "$W6" = "cd .harness/after && java -XX:AOTCache=tiffinbox-web/target/jar.aot -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18909" ] || die "the ladder's sixth way: $W6"
[ "$T_JAR" = "java -XX:AOTCacheOutput=tiffinbox-web/target/jar.aot -Dspring.context.exit=onRefresh -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431" ] || die "the sixth way's training run: $T_JAR"
NAMES="the executable jar|+ Spring's AOT|the jar extracted|extracted + the JDK's AOT cache|extracted + the JDK's AOT cache + Spring's AOT|the executable jar + the JDK's AOT cache"
# train 'COMMAND': a training run - the context refreshes, then exits (spring.context.exit=onRefresh); the JDK writes the cache
train() { local e=0
  echo "\$ $1"; (eval "$1") > .harness/train.log 2>&1 < /dev/null || e=$?
  [ "$(listeners 18909)" = 0 ] || die "the training run left 18909 bound"
  echo "  exit $e · the JDK's own line: $(grep -m1 '^AOTCache creation is complete: ' .harness/train.log | sed 's/ [0-9][0-9]* bytes$/ [its size in bytes]/')"; }
ladder() { local r w s line
  echo "the start, timed from outside the JVM: harness/ttfr.py forks the command, asks /kitchen until the first 200, then sends POST /shutdown"
  echo "with the token. Every way runs from .harness/after, port 18909; 6 rounds, each round the six ways in turn; round 1 is a warm-up, not counted."
  echo "  (terminal only) this Mac: $(sysctl -n machdep.cpu.brand_string) · $(sysctl -n hw.ncpu) cores · $(( $(sysctl -n hw.memsize) / 1073741824 )) GB · $(java -version 2>&1 | head -1)" >&3
  echo "first, the README's extract (done in .harness/after already) and three training runs - one command records the run and writes the cache:"
  echo "\$ cd .harness/after && $R_EXTRACT"
  rm -f .harness/after/tiffinbox-web/target/*.aot .harness/after/tiffinbox-web/target/*.aot.config
  train "$(at .harness/after 18909 "$T_PLAIN")"; train "$(at .harness/after 18909 "$R_TRAIN")"; train "$(at .harness/after 18909 "$T_JAR")"
  echo "the six ways:"
  w=1; while [ $w -le 6 ]; do eval "line=\$W$w"; echo "  $w \$ $line"; w=$((w + 1)); done
  : > .harness/times.txt
  r=1; while [ $r -le 6 ]; do w=1; while [ $w -le 6 ]; do eval "line=\$W$w"
      s=$(cd .harness/after && python3 ../../harness/ttfr.py 18909 "$TF" ../ttfr.out ../ttfr.err -- ${line#cd .harness/after && })
      printf '%s %s %s\n' "$r" "$w" "$s" >> .harness/times.txt
      [ "$(listeners 18909)" = 0 ] || die "a timed run left 18909 bound"; w=$((w + 1)); done; r=$((r + 1)); done
  echo "  every run: a 200, then exit 0 after POST /shutdown: $(grep -c ' first 200 after [0-9.]* s · exit 0$' .harness/times.txt || true) of $(wc -l < .harness/times.txt | tr -d ' ')"
  echo "each way's median, the middle of its counted runs - the executable jar's against a floor, every other way's against the executable"
  echo "jar's (the seconds go to the terminal, never to this capture):"
  awk -v names="$NAMES" '
    { all[$2]++; if ($1 == 1) next; t[$2, $1] = $6 + 0; k[$2]++ }
    END { split(names, nm, "|"); q = "\047"
      lk = k[1]; hk = k[1]; for (w = 2; w <= 6; w++) { if (k[w] < lk) lk = k[w]; if (k[w] > hk) hk = k[w] }
      printf "  each way%ss runs counted: %s of %d - round 1 left out\n", q, (lk == hk) ? lk : lk "-" hk, all[1]
      for (w = 1; w <= 6; w++) { n = 0
        for (r = 2; r <= 6; r++) { x = t[w, r]; i = n; while (i > 0 && v[i] > x) { v[i + 1] = v[i]; i-- }; v[i + 1] = x; n++ }
        med[w] = v[3]; lo[w] = v[1]; hi[w] = v[5] }
      printf "  1 %s: its median over 1 s: %s\n", nm[1], (med[1] > 1) ? "yes" : "no"
      printf "  2 %s: its median under the executable jar%ss: %s · over three quarters of it: %s\n", nm[2], q, (med[2] < med[1]) ? "yes" : "no", (med[2] > 0.75 * med[1]) ? "yes" : "no"
      printf "  3 %s: its median under the executable jar%ss: %s\n", nm[3], q, (med[3] < med[1]) ? "yes" : "no"
      for (w = 4; w <= 5; w++) printf "  %d %s: its median under half the executable jar%ss: %s\n", w, nm[w], q, (med[w] < med[1] / 2) ? "yes" : "no"
      printf "  6 %s: its median under the executable jar%ss: %s · over half of it: %s\n", nm[6], q, (med[6] < med[1]) ? "yes" : "no", (med[6] > med[1] / 2) ? "yes" : "no"
      for (w = 1; w <= 6; w++) printf "  (terminal only) %d %s: %.3f-%.3f s, median %.3f s, %.0f%% of the executable jar%ss\n", w, nm[w], lo[w], hi[w], med[w], 100 * med[w] / med[1], q > "/dev/stderr" }' .harness/times.txt 2>&3; }
cap ladder ladder

# ---- native: the binary ----------------------------------------------------------------------------------------------------
native() { local s0 s1 e=0 b=.harness/native/tiffinbox-web/target/tiffinbox-web
  rm -rf .harness/native; rsync -a --exclude target after/ .harness/native/; tree .harness/native
  echo "after/, copied to .harness/native, a config tree beside its README - the README's two Maven lines, offline; \$GRAALVM_HOME names the GraalVM:"
  echo "\$ $C_INSTALL"; mbuild "$C_INSTALL" .harness/build-install.log ".harness/native (both modules, into \$M2)"
  echo "\$ $C_NATIVE"
  s0=$(date +%s); (eval "$C_NATIVE") > .harness/build-native.log 2>&1 < /dev/null || e=$?; s1=$(date +%s)
  echo "  (terminal only) the native build took $((s1 - s0)) s" >&3
  if ghub .harness/build-native.log; then echo "  offline: no - GraalVM's native plugin went to GitHub for its metadata repository"; die "the native build: GraalVM's native plugin went over the network for its metadata repository - README.md, The repository"; fi
  echo "  its lines, in order (the rest - $(grep -cvE '^\[INFO\] --- |^\[INFO\] Found GraalVM|^ - Java version: |^Warning: |^\[[1-8]/8\] |found reachable$|^\[INFO\] BUILD |^The build process encountered ' .harness/build-native.log || true) lines - not shown):"
  grep -E '^\[INFO\] --- .* @ tiffinbox-web ---$|^\[INFO\] Found GraalVM installation from ' .harness/build-native.log | sed 's/^\[INFO\] /    /'
  grep -E '^ - Java version: ' .harness/build-native.log | sed 's/^ - /    /'
  grep -E '^Warning: ' .harness/build-native.log | sed "s/ in 'file:[^']*'/ in '…'/" | sed 's/^/    /'
  grep -E '^\[[1-8]/8\] ' .harness/build-native.log | sed 's/\.\.\..*$/.../' | sed 's/^/    /'
  grep -E 'found reachable$' .harness/build-native.log | sed 's/^ */    /'
  grep -E '^The build process encountered |^\[INFO\] BUILD ' .harness/build-native.log | sed 's/^\[INFO\] //' | sed 's/^/    /'
  echo "  exit $e · stages it printed: $(grep -cE '^\[[1-8]/8\] ' .harness/build-native.log || true) of the $(grep -m1 -oE '^\[1/[0-9]+\]' .harness/build-native.log | sed 's/.*\///; s/]//') it announces · its duration, against the bound: $( [ $((s1 - s0)) -ge 60 ] && echo '1 minute or more' || echo 'under 1 minute' ), $( [ $((s1 - s0)) -lt 600 ] && echo 'under 10 minutes' || echo '10 minutes or more' ) · offline: yes"
  echo "the binary, $b:"
  echo "  file: $(file -b "$b" | sed 's/ [A-Za-z0-9_]*$//') · the demo token in its bytes: $(raw "$TOKEN" "$b") · the files native-image wrote beside it: $(ls .harness/native/tiffinbox-web/target | grep -c '\.dylib$' || true) .dylib - $(ls .harness/native/tiffinbox-web/target | grep '\.dylib$' | sed 's/\.dylib$//' | head -3 | paste -sd' ' -) …"
  grep -m1 '^\[INFO\] Executing: ' .harness/build-native.log | grep -oE '[^/:]+\.jar' | sort -u > .harness/ni-cp.txt || true
  unzip -Z1 ".harness/native/$JAR" | grep '^BOOT-INF/lib/.*\.jar$' | sed 's|^BOOT-INF/lib/||' | sort -u > .harness/jar-lib.txt
  echo "  the jars on native-image's class path (the plugin's command line, names only): $(wc -l < .harness/ni-cp.txt | tr -d ' ') · in the executable jar's BOOT-INF/lib: $(wc -l < .harness/jar-lib.txt | tr -d ' ') · only on native-image's: $(comm -23 .harness/ni-cp.txt .harness/jar-lib.txt | paste -sd' ' -) · only in the jar: $(comm -13 .harness/ni-cp.txt .harness/jar-lib.txt | wc -l | tr -d ' ')"
  echo "the binary run, from .harness/native - its config tree beside it - as the README runs it, port 18909:"
  start "$(at .harness/native 18909 "$R_BIN")"
  echo "  listened on: $(listening)"
  e=0; wait "$pid" || e=$?; pid=""
  echo "  Boot's banner, its last line: $(grep -m1 ':: Spring Boot ::' .harness/run.out | sed 's/^ *//')"
  echo "  Boot's first line: $(first .harness/run.out)"
  echo "  then: $(grep -m1 -E '^Application run failed$' .harness/run.out || echo '(no failure line)')"
  echo "  the exception it names, then its causes - $(grep -c '^Caused by: ' .harness/run.out || true) lines start 'Caused by: ' - each cut after the bean it names, the last after the method; the lines between, counted:"
  causes .harness/run.out
  echo "  its first frame outside GraalVM's own and the JDK's: $(awk '/^Caused by: org\.graalvm\.nativeimage\.MissingReflectionRegistrationError/ { f = 1 } f && /^\tat / && !/com\.oracle\.svm|java\.base/ { sub(/^\tat /, ""); print; exit }' .harness/run.out)"
  echo "  exit $e · listening on 18909 now: $(listeners 18909) · its output: $(wc -l < .harness/run.out | tr -d ' ') lines, $(wc -l < .harness/run.err | tr -d ' ') on standard error"
  echo "  that method, in after/'s tiffinbox-core/src/main/java/com/tiffinbox/TiffinBoxProperties.java (its line and the one above):"
  grep -B1 'public boolean isShutdownTokenLongEnough()' after/tiffinbox-core/src/main/java/com/tiffinbox/TiffinBoxProperties.java | sed 's/^ */    /'
  echo "C - native:compile from the root, as a single-module project runs it:"
  echo "\$ $C_ROOT"; mbuild "$C_ROOT" .harness/build-root.log "native:compile from the root" fails
  echo "  the project it ran on first, and its error: $(grep -m1 '^\[ERROR\] Failed to execute goal ' .harness/build-root.log | sed 's/^\[ERROR\] Failed to execute goal //; s/ -> \[Help 1\]$//')"; }

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
# Without a GraalVM the run stops here, the exercise's capture made first (it needs none): .m2-demo is filled, and every capture
# so far matched receipts.md5 - or cap() would have stopped the run.
if [ $GOK = no ]; then cap exercise exercise
  die "GRAALVM_HOME is not set: .m2-demo is filled, and the captures that need no GraalVM matched receipts.md5, the exercise's included; the native build needs a GraalVM JDK 25 - README.md, The GraalVM"; fi
cap native native
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
# this unit ships for reading, nor the native binary the last native build wrote
for f in .harness/raw-*; do [ "$(cat "$f")" = 0 ] || die "a capture's raw output held the demo token ($f)"; done
for f in .r-*.out README.md exercise/README.md exercise/solution/SOLUTION.md receipts.md5 harness/aot/Frozen.java harness/aot/Calls.java harness/ttfr.py after/README.md .harness/native/tiffinbox-web/target/tiffinbox-web; do
  [ -f "$f" ] || continue; [ "$(raw "$TOKEN" "$f")" = 0 ] || die "$f holds the demo token, raw"; done
for f in .r-*.out; do ! grep -qE '/Users/|/private/|/home/' "$f" || die "$f holds an absolute path"; ! grep -qF "$GRAALVM_HOME" "$f" || die "$f holds the GraalVM's folder"; done
echo "  token: 0 raw copies in $(ls .harness/raw-* | wc -l | tr -d ' ') raw capture runs, in $(ls .r-*.out | wc -l | tr -d ' ') captures, the READMEs, the harness, receipts.md5 and the native binary; no absolute path, no GraalVM folder in any capture"

# "TiffinBox's web module declares one more plugin, GraalVM's Native Build Tools. No version: Boot's parent manages one point one
# point eight."
x change '^  Files \.harness/before/README\.md and \.harness/after/README\.md differ$'
x change '^  Files \.harness/before/tiffinbox-web/pom\.xml and \.harness/after/tiffinbox-web/pom\.xml differ$'
[ "$(n change '^  Files ')" = 2 ] || die "change: exactly two files differ"
x change '^          <groupId>org\.graalvm\.buildtools</groupId>$'
x change '^          <artifactId>native-maven-plugin</artifactId>$'
! blk change "after/'s tiffinbox-web/pom.xml" "Boot's parent" | grep -q '<version>' || die "change: the declaration names a version"
x change '^  lines diff removes: 0 · adds: 10 - not shown: a comment of 5 lines, and 1 blank$'
x change '^  <native-build-tools-plugin\.version>1\.1\.8</native-build-tools-plugin\.version>$'
x change '^  the two executable jars, entry by entry: entries 170 and 170 · the same name and content \(CRC-32\): 169 · different: 1 - META-INF/maven/com\.tiffinbox/tiffinbox-web/pom\.xml$'
x change '^  the previous tree: spring-boot:4\.1\.1:process-aot \(process-aot\)$'
x change '^  after/: native:1\.1\.8:add-reachability-metadata \(add-reachability-metadata\) · spring-boot:4\.1\.1:process-aot \(process-aot\)$'
[ "$(n change ' · offline: yes · exit 0$')" = 4 ] || die "change: four offline builds"
echo "  change: 2 files · the plugin declared, no version · the parent's 1.1.8 · plain jars 169 of 170 entries the same (the POM) · process-aot both, add-reachability-metadata after/ only"

# "Build with Boot's native profile, still on the plain JDK. Boot's process-aot ran, and wrote thirty-five Java files, forty-five
# classes and two resources." "Open one ... a plain call with four arguments. Start runs after it, stop before it goes. Nine of the
# thirty-five are TiffinBox's. One is where the context starts: an initializer, named after the main class."
x generated '^  built \.harness/gen · offline: yes · exit 0$'
x generated '^  the JDK Maven ran on \(mvn -version\): Java version: 25\.0\.4\.1 · a native-image in it: no$'
x generated '^    spring-boot:4\.1\.1:process-aot \(process-aot\)$'
x generated "^  process-aot ran TiffinBox's main to read its configuration - Boot's first line in the build's log: Starting TiffinBoxServer using Java 25\.0\.4\.1 · lines saying TiffinBox listening: 0\$"
x generated "^  sources/: 35 Java files · TiffinBox's own, under com/tiffinbox/: 9\$"
[ "$(n generated '^    com/tiffinbox/.*\.java$')" = 9 ] || die "generated: nine of TiffinBox's own sources listed"
x generated '^    com/tiffinbox/web/TiffinBoxServer__ApplicationContextInitializer\.java$'
x generated '^  \| Args = -H:Class=com\.tiffinbox\.web\.TiffinBoxServer \\$'
x generated '^  classes/: 45 files · resources/: 2 files$'
x generated '^  \|             \.withGenerator\(\(registeredBean, args\) -> new TiffinBoxServer\(args\.get\(0\), args\.get\(1\), args\.get\(2\), args\.get\(3\)\)\);$'
x generated '^  \|     beanDefinition\.setInitMethodNames\("start"\);$'
x generated '^  \|     beanDefinition\.setDestroyMethodNames\("stop"\);$'
# "Spring generated reachability metadata dot json: two hundred sixty-two reflection entries." (not Course 3's reflect config)
# "It lists TiffinBox's server too, and allows two of its methods by reflection: start and stop."
x generated '^  its top-level keys: comment "Spring Framework 7\.0\.9" · reflection 262 entries · resources 16 entries$'
x generated '^  files named reflect-config\.json anywhere under \.harness/gen: 0$'
x generated '^    com\.tiffinbox\.web\.TiffinBoxServer · allDeclaredFields · methods start stop$'
# the exercise's answer, and "nothing had registered that method" (the validator's, below)
x generated '^  reflection entries naming com\.tiffinbox: 9$'
x generated '^  entries for com\.tiffinbox\.Customer: 0$'
x generated '^    com\.tiffinbox\.TiffinBoxProperties · allDeclaredFields · methods <init>$'
x generated '^the jar it packaged: its manifest says Spring-Boot-Native-Processed: true · '
echo "  generated: the plain JDK (no native-image in it) · process-aot · 35 sources, 9 TiffinBox's, 45 classes, 2 resources · the constructor call, start, stop · 262 entries, 0 reflect-config.json · the server: start stop · 9 · Customer 0"

# "Tell it to use the generated code ... and Boot's first line says AOT-processed. The seven responses didn't change. Count the
# bean definitions: fifty-nine without it, fifty-five with. Three of the missing four are hooks the last course took out ..."
JA=$(blk onjvm 'A - as the README' "B - the README's AOT"); JB=$(blk onjvm "B - the README's AOT" "A' - A re-run:"); JA2=$(blk onjvm "A' - A re-run:" 'the harness (')
[ "$JA" = "$JA2" ] || die "onjvm: A' is not A, line for line"
has "$JA" "  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1" "onjvm A"
has "$JB" "  Boot's first line: Starting AOT-processed TiffinBoxServer v1.0.0 using Java 25.0.4.1" "onjvm B"
[ "$(n onjvm "^  exit 0 · the seven responses: 7 lines · md5 $S115\$")" = 3 ] || die "onjvm: the seven responses, 115c36ba..., all three runs"
[ "$(n onjvm '^  listens on: 127\.0\.0\.1:1890[01] · WARN lines 0 · ERROR lines 0$')" = 3 ] || die "onjvm: three runs, no warning"
HA=$(blk onjvm 'A - the JVM, port 18902' 'B - -Dspring'); HB=$(blk onjvm 'B - -Dspring' "A' - A re-run, port"); HA2=$(blk onjvm "A' - A re-run, port" '  definitions in A')
[ "$HA" = "$HA2" ] || die "onjvm: the harness's A' is not A, line for line"
has "$HA" "the context's bean definitions: 59" "onjvm harness A"; has "$HB" "the context's bean definitions: 55" "onjvm harness B"
has "$HB" "spring.aot.enabled, the system property: true" "onjvm harness B"
x onjvm "^  definitions in A and not in B: 4 · in B and not in A: 0 · A' against A: the same names\$"
for d in internalConfigurationAnnotationProcessor internalAutowiredAnnotationProcessor internalCommonAnnotationProcessor; do x onjvm "^    org\.springframework\.context\.annotation\.$d\$"; done
x onjvm '^    org\.springframework\.boot\.autoconfigure\.internalCachingMetadataReaderFactory$'
echo "  onjvm: 'AOT-processed' in B only · 115c36ba... x3 · definitions 59 / 55 / 59 · the 4 missing: three annotation processors and Boot's metadata-reader cache"

# "Last lesson's switch ... on a plain JVM: SimpleAsyncTaskExecutor. Twenty tasks, twenty virtual threads. The same switch with AOT
# on. The environment still says true. ... the pool: eight platform threads, and no warning. AOT off again: twenty. Now build with
# the switch on, and run without it: virtual threads. The build decided."
FA=$(blk frozen 'A - the JVM' 'B - '); FB=$(blk frozen 'B - ' "A' - "); FA2=$(blk frozen "A' - " 'C - '); FC=$(blk frozen 'C - ' 'the code process-aot')
[ "$FA" = "$FA2" ] || die "frozen: A' is not A, line for line"
has "$FA" "the switch, as the environment holds it: spring.threads.virtual.enabled = true · from commandLineArgs" "frozen A"
has "$FA" "Boot's executor, the bean applicationTaskExecutor: org.springframework.core.task.SimpleAsyncTaskExecutor" "frozen A"
has "$FA" "20 tasks -> distinct threads 20 · virtual [true]" "frozen A"
has "$FB" "spring.aot.enabled, the system property: true" "frozen B"
has "$FB" "the switch, as the environment holds it: spring.threads.virtual.enabled = true · from commandLineArgs" "frozen B"
has "$FB" "Boot's executor, the bean applicationTaskExecutor: org.springframework.scheduling.concurrent.ThreadPoolTaskExecutor" "frozen B"
has "$FB" "20 tasks -> distinct threads 8 · virtual [false]" "frozen B"
printf '%s\n' "$FB" | grep -qE '^  Boot.s log \(standard output\): [0-9]+ lines, not shown · WARN lines 0 · ERROR lines 0 · exit 0 · listening on 18905 now: 0$' || die "frozen B: no warning, no error"
has "$FC" "spring.aot.enabled, the system property: true" "frozen C"
has "$FC" "the switch, as the environment holds it: spring.threads.virtual.enabled = (not set)" "frozen C"
has "$FC" "Boot's executor, the bean applicationTaskExecutor: org.springframework.core.task.SimpleAsyncTaskExecutor" "frozen C"
has "$FC" "20 tasks -> distinct threads 20 · virtual [true]" "frozen C"
# "Boot's executor has two bean methods, each with a condition on the switch. Process-aot checked them at build time and kept only
# the winner." - the conditions read off Boot's class (javap), one bean method written down per tree
x frozen '^  \.harness/after - the bean applicationTaskExecutor comes from: the bean method applicationTaskExecutor, type ThreadPoolTaskExecutor · bean methods named for it: 1$'
x frozen '^  \.harness/built-on - the bean applicationTaskExecutor comes from: the bean method applicationTaskExecutorVirtualThreads, type SimpleAsyncTaskExecutor · bean methods named for it: 1$'
x frozen '^  the bean method applicationTaskExecutorVirtualThreads · @ConditionalOnThreading\(VIRTUAL\)$'
x frozen '^  the bean method applicationTaskExecutor · @ConditionalOnThreading\(PLATFORM\)$'
[ "$(n frozen '^  the bean method applicationTaskExecutor[A-Za-z]* · @ConditionalOnThreading\(')" = 2 ] || die "frozen: two candidates, two conditions"
echo "  frozen: A SimpleAsync 20 virtual · B the switch true, ThreadPool 8 platform, 0 warnings · A' = A · C built on: virtual, the switch not set · one bean method written down per tree · two candidates, @ConditionalOnThreading VIRTUAL / PLATFORM"

# @Async under AOT (BLUE B's question; the README's answer): the pool, eight platform threads
QA=$(blk async 'A - the JVM' 'B - '); QB=$(blk async 'B - ' "A' - "); QA2=$(blk async "A' - " '')
[ "$QA" = "$QA2" ] || die "async: A' is not A, line for line"
has "$QA" "20 @Async calls -> distinct threads 20 · virtual [true]" "async A"
has "$QB" "Boot's executor, the bean applicationTaskExecutor: org.springframework.scheduling.concurrent.ThreadPoolTaskExecutor" "async B"
has "$QB" "20 @Async calls -> distinct threads 8 · virtual [false]" "async B"
x async '^  exit 0 · Boot.s log: [0-9]+ lines, not shown · written: [0-9]+ Java files · [0-9]+ class files'
echo "  async: @Async 20 virtual on the JVM, 8 platform under AOT, A' = A"

# "TiffinBox's jar takes over a second to start on this Mac." "Six rounds, the first a warm-up, on this Mac." "The executable jar:
# its middle run of five, over a second. Spring's AOT alone: a little faster. Then the JDK's AOT cache ... trained once on the
# extracted jar. Extracted and cached: under half the jar's time. Cached without extracting: over half." The executable jar is
# judged against a floor only (a warm machine moved its median from 1.2 s to 2.1 s - README); every other way, against it.
x ladder '^  every run: a 200, then exit 0 after POST /shutdown: 36 of 36$'
x ladder "^  each way's runs counted: 5 of 6 - round 1 left out\$"
x ladder '^  1 the executable jar: its median over 1 s: yes$'
x ladder "^  2 \+ Spring's AOT: its median under the executable jar's: yes · over three quarters of it: yes\$"
x ladder "^  3 the jar extracted: its median under the executable jar's: yes\$"
x ladder "^  4 extracted \+ the JDK's AOT cache: its median under half the executable jar's: yes\$"
x ladder "^  5 extracted \+ the JDK's AOT cache \+ Spring's AOT: its median under half the executable jar's: yes\$"
x ladder "^  6 the executable jar \+ the JDK's AOT cache: its median under the executable jar's: yes · over half of it: yes\$"
[ "$(n ladder "^  exit 0 · the JDK's own line: AOTCache creation is complete: tiffinbox-web/target/(plain|tiffinbox|jar)\.aot \[its size in bytes\]\$")" = 3 ] || die "ladder: three training runs, each wrote its cache"
echo "  ladder: 36 of 36 served · 5 of 6 counted · the jar over 1 s · + AOT under it, over 3/4 · extracted under it · extracted + the cache (+ AOT) under half · the jar + the cache: over half"

# "It needs a GraalVM JDK, named by a variable. Install both modules, then build the web module alone. Eight stages, for minutes,
# not seconds. Build success." "Run the binary ... Boot's banner, and the same line, AOT-processed. Then exit one. Hibernate
# Validator called TiffinBox's token-length rule by reflection, and nothing had registered that method."
x native '^  built \.harness/native \(both modules, into \$M2\) · offline: yes · exit 0$'
x native '^    --- native:1\.1\.8:compile-no-fork \(default-cli\) @ tiffinbox-web ---$'
x native '^    Found GraalVM installation from GRAALVM_HOME variable\.$'
x native '^    Java version: 25\.0\.4\.1\+1, vendor version: GraalVM CE 25\.3\.4\.1\+1\.1$'
x native '^    BUILD SUCCESS$'
x native '^  exit 0 · stages it printed: 8 of the 8 it announces · its duration, against the bound: 1 minute or more, under 10 minutes · offline: yes$'
x native '^  file: Mach-O 64-bit executable · the demo token in its bytes: 0 · '
x native '^  listened on: nothing$'
x native "^  Boot's banner, its last line: :: Spring Boot :: +\(v4\.1\.1\)\$"
x native "^  Boot's first line: Starting AOT-processed TiffinBoxServer using Java 25\.0\.4\.1\$"
x native '^  then: Application run failed$'
# the whole chain on screen: the server, its repository, the database, the settings record, then GraalVM's refusal - every gap counted
x native "^  the exception it names, then its causes - 4 lines start 'Caused by: ' - "
x native "^    org\.springframework\.beans\.factory\.UnsatisfiedDependencyException: Error creating bean with name 'tiffinBoxServer' …\$"
x native "^    Caused by: org\.springframework\.beans\.factory\.UnsatisfiedDependencyException: Error creating bean with name 'customerRepository' …\$"
x native "^    Caused by: org\.springframework\.beans\.factory\.UnsatisfiedDependencyException: Error creating bean with name 'database' …\$"
x native "^    Caused by: org\.springframework\.beans\.factory\.BeanCreationException: Error creating bean with name 'tiffinbox-com\.tiffinbox\.TiffinBoxProperties' …\$"
[ "$(n native '^    … [0-9]+ lines not shown …$')" = 4 ] || die "native: the chain's four gaps, each counted"
x native "^    Caused by: org\.graalvm\.nativeimage\.MissingReflectionRegistrationError: Cannot reflectively invoke method 'public boolean com\.tiffinbox\.TiffinBoxProperties\.isShutdownTokenLongEnough\(\)'\.\$"
x native "^  its first frame outside GraalVM's own and the JDK's: org\.hibernate\.validator\.internal\.util\.ReflectionHelper\.getValue\(ReflectionHelper\.java:[0-9]+\)\$"
x native '^  exit 1 · listening on 18909 now: 0 · '
x native '^    @AssertTrue\(message = "tiffinbox\.shutdown-token must be 16 characters or more"\)$'
x native "^  the jars on native-image's class path \(the plugin's command line, names only\): 36 · in the executable jar's BOOT-INF/lib: 31 · only on native-image's: jackson-core-3\.1\.5\.jar jackson-databind-3\.1\.5\.jar spring-boot-docker-compose-4\.1\.1\.jar "
x native '^  ran native:compile from the root · offline: yes · exit 1$'
x native 'on project tiffinbox-parent: Image classpath is empty\.'
echo "  native: plugin 1.1.8 · GRAALVM_HOME · GraalVM CE 25.3.4.1 · 8 of 8 · BUILD SUCCESS, exit 0, 1-10 min, offline · token 0 · banner, AOT-processed, exit 1, the chain server -> repository -> database -> settings -> isShutdownTokenLongEnough, the validator's frame · 36 jars vs 31 · the root: Image classpath is empty"

# the exercise's end state: the line exercise/README.md calls "Done" is a line of this capture, after the solution's line - and of
# SOLUTION.md's measured run
XE=$(blk exercise "the solution's line" '')
l='reflection entries naming com.tiffinbox: 9 · com.tiffinbox.Customer: 0'
has "$XE" "$l" "exercise"
awk '/^\*\*Done\*\*/ { f = 1 } f' exercise/README.md | grep -qxF -- "$l" || die "exercise/README.md: Done names no such line"
grep -qxF -- "$l" exercise/solution/SOLUTION.md || die "SOLUTION.md: the measured run shows no such line"
x exercise '^  exit 0 · printed: [0-9]+ line\(s\)$'
echo "  exercise: the README as written, then the solution's line -> 9 · Customer 0"

# the anchor's README states the same numbers, and the repository's own .gitignore keeps this unit's folders out
grep -qF '59 bean definitions without it, 55 with it' after/README.md || die "after/README.md: the definitions"
grep -qF 'jar over a second; Spring' after/README.md || die "after/README.md: the ladder"
grep -qF "isShutdownTokenLongEnough()'" after/README.md || die "after/README.md: the binary's failure"
[ -z "$unpub" ] || die "no published hash for:$unpub - check the captures, then copy the md5s above into receipts.md5 and run again"
echo "c5-unit19: every capture 3/3 and = published; every spoken number asserted; 0 raw demo tokens in every capture"
