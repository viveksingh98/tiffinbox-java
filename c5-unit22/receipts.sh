#!/bin/bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25.0.4.1 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# GRAALVM_HOME names a GraalVM JDK 25 (README.md, "The GraalVM"): the native build reads it. Without it, this script makes every
# capture that needs no GraalVM - the JVM's, and the exercise's - filling .m2-demo on the way, then stops before the native build.
# Course 5 · Health Indicators, Liveness and Readiness - this unit's receipts. TiffinBox's health said UP while its database was
# gone, and TiffinBox's own routes answer before Boot calls it live or ready. The anchor change: KitchenHealthIndicator.java
# (new: a HealthIndicator bean - the component "kitchen" - UP while the database answers, DOWN with the error's class name when it
# does not) and application.yaml (management.endpoint.health.group.readiness.include: readinessState,kitchen - the kitchen joins
# readiness, never liveness). Nine captures, each run three times and hashed; cap() DIES when a hash differs from receipts.md5;
# every number the video says is asserted at the bottom by a check that can fail; the demo token is masked (gsub), and the last
# checks count 0 raw copies of it in every capture, every file this unit ships, and the binary it built.
#   parts     the previous tree: with the database closed by the harness, health still UP while /customers answers 500; what
#             health is made of - its components and its two groups, shown by the README's flag; the switch for the groups
#             (the README's line) and the older key Boot no longer reads, each for one run, and both as Boot's metadata states them
#   race      after/'s extracted jar run with the harness's witness, polled from the fork by harness/race.py: what /kitchen,
#             liveness and readiness answered, in order - never a count - then the log's order: TiffinBox's server, Boot's
#             started line, the states Boot published
#   change    the previous tree against after/: the files that differ, KitchenHealthIndicator.java counted and its key lines,
#             what application.yaml gains; ActuatorRoutes.java, TiffinBoxServer.java and TiffinBoxApp.java byte for byte
#   kitchen   after/ built the README's way and run as the README runs it: health, the kitchen's own path; then the README's
#             flag lines - the components, the details (the kitchen asked alone); then the README's line that switches the
#             groups off, which stops the start now
#   dead      after/ with the database closed by the harness, the details flag: health through a filter (each component's
#             status), liveness, readiness, the kitchen's path, /customers and /kitchen, the seven
#   groups    the break, the database closed in every run: A after/ (the kitchen in readiness) · B the README's line without
#             it · A' = A
#   trap      C (labelled): readiness changed by hand - from a runner, then after Boot's own ready - with the harness's
#             witness; then a SIGTERM, and what the context publishes as it closes; the jar's classes that name the state
#   native    after/ built natively (the README's two Maven lines): the AOT jar, then the binary - readiness with the kitchen in
#             it, the kitchen's path, the seven
#   exercise  exercise/README.md's commands and exercise/solution/SOLUTION.md's, read from the files and run as written
# "before" is ../c5-unit21/after (the anchor as the Actuator lesson left it), COPIED under .harness/; this script never writes into
# another unit's folder. after/ is this unit's frozen copy of ../c5-tiffinbox after the change; it is copied, never built in
# place. Every run of TiffinBox starts in a folder under .harness/ that holds a config tree with the demo token (secrets/), as the
# README asks. Commands are printed exactly as they run: each goes through eval. "$CURLSET" is the comparison set since the secrets
# lesson (../c5-unit11/curlset.sh: the seven requests, POST /shutdown with the token's header read from the file). "$M2" is this
# unit's own repository, .m2-demo. "$pid" is the process the script started.
# The network: every build runs offline (-o) against .m2-demo and says so ("offline: yes"); a build that cannot resolve an
# artifact offline goes to the remote repository once - Maven Central, or the mirror your settings name - and says that ("offline: no - ..."). GraalVM's native plugin, under the profile
# native, reads its metadata repository (a zip) from .m2-demo - and when the zip is not there it downloads it from GitHub, even
# under -o (README.md, The repository): so a native-profile build without the zip goes to Maven Central for it at once, never
# offline first, and every build's log is searched for the plugin's own download line - found, the run stops. At run time nothing
# leaves 127.0.0.1: TiffinBox listens there, and every request goes there.
# Masks and filters (README.md declares each; sub/gsub only): the demo token becomes "[masked: the 26-character token]"; the
# GraalVM's folder "$GRAALVM_HOME"; this folder's absolute path "…", the folder above it "…/..", the home folder "~"; your user
# name "<user>" - in every line of every capture. A Boot log line is printed from its message on, its first line cut before
# " with PID", Boot's started line before " in ". Logs are read, never printed whole: what a capture shows is named, and the rest
# counted. Never printed: health's details for the whole application (a disk's sizes, the folder TiffinBox runs in) - only the
# kitchen's own details, and the readiness group's. No duration is captured: each is judged against a bound; seconds go to the
# terminal.
# Ports (brief ⚑10, 19010-19019): parts 19010 · race 19011 · kitchen 19012 · dead 19013 · groups 19014 · trap 19015 · native 19016
# · exercise 19019. 18425 (TiffinBox's default) and 8080 (Tomcat's) are checked free too.
set -e
# bash 5.2 and later turn an & in the replacement of ${x/pattern/replacement} into the matched text (patsub_replacement, on by
# default): start()'s "&& exec " would become "&& && exec ". Switched off, so /bin/bash 3.2 (./receipts.sh) and a newer bash
# (bash receipts.sh) run the same commands; 3.2 has no such option.
shopt -u patsub_replacement 2> /dev/null || true
cd "$(dirname "$0")"
# One run at a time: two runs share .harness/ and the ports, and one would corrupt the other.
mkdir .r-lock 2> /dev/null || { echo "  *** another receipts.sh is running in this folder (.r-lock exists) - if none is, rmdir .r-lock ***"; exit 1; }
# On every exit - the end, a failed check, or Ctrl-C - stop the process this script started in the background, if it still runs
# (a background job of a non-interactive shell ignores the terminal's Ctrl-C), then sweep(): anything of this run still alive in
# its process group - a TiffinBox JVM (a jar, an extracted class path), a binary, native-image's driver or builder, the race's
# poller - is stopped. Then health's whole answer with details, if a run left it (it names a disk's sizes and a folder). After an
# interrupt, a capture's unfinished runs (.r-NAME.1-3) go too; after a failed check they stay, for the diff the message names.
# The clean-up ignores a second Ctrl-C, and nothing in it can fail under set -e, so it always reaches the rmdir; the script still
# exits 130 after an interrupt (tested: README.md, "Interrupted"). $pid is cleared whenever the process has been reaped.
pid=""
sweep() { local g i l
  g=$(ps -o pgid= -p $$ 2> /dev/null | tr -d ' ') || g=""
  [ -n "$g" ] || return 0
  i=0; while [ $i -lt 20 ]; do
    l=$(ps -axo pid=,pgid=,command= 2> /dev/null | awk -v g="$g" -v me=$$ -v gh="${GRAALVM_HOME:-/nonexistent}" '
      $2 == g && $1 != me && $3 != "awk" && $3 != "ps" && (index($0, "vminvocation.args") || index($3, gh "/bin/native-image") || $3 ~ /tiffinbox-web\/target\/tiffinbox-web$/ || index($0, "tiffinbox-web-1.0.0.jar") || index($0, "com.tiffinbox.web.TiffinBoxServer") || index($0, "harness/race.py")) { print $1 }' | paste -sd' ' -) || l=""
    [ -n "$l" ] || return 0
    if [ $i -lt 10 ]; then kill $l 2> /dev/null || true; else kill -9 $l 2> /dev/null || true; fi
    sleep 0.5; i=$((i + 1)); done; }
machinefiles() { rm -f .harness/*/health.json 2> /dev/null || true; }
trap 'trap "" INT TERM; if [ -n "$pid" ] && kill "$pid" 2> /dev/null; then wait "$pid" 2> /dev/null || true; fi; sweep || true; machinefiles; [ -z "$INTR" ] || rm -f .r-*.[123]; rmdir .r-lock 2> /dev/null || true' EXIT
INTR=""; trap 'INTR=1; exit 130' INT TERM
exec 3>&1                                            # die() speaks to the terminal even inside a redirected capture
die() { echo "  *** $* ***" >&3; exit 1; }
java -version 2>&1 | grep -q 'version "25' || die "JDK 25 needed; JAVA_HOME gives: $(java -version 2>&1 | head -1)"
command -v python3 > /dev/null || die "python3 is needed: harness/race.py polls the start, and health's answers are JSON"
command -v curl > /dev/null || die "curl is needed: every request here is curl's"
# A variable of yours must not become a property source, a JVM flag, a build setting or a native-image option: every
# TIFFINBOX_*, SPRING_*, MANAGEMENT_*, SERVER_* and LOGGING_* variable, DEBUG (Boot reads it as --debug), the variables that inject
# JVM flags, MAVEN_OPTS, MAVEN_ARGS and NATIVE_IMAGE_OPTIONS are removed first. GRAALVM_HOME stays: it says which GraalVM to use.
# The list is an extended regular expression (sed -E): /usr/bin/sed's basic ones have no alternation, so the \| this loop once
# used matched nothing and removed no variable at all (measured: RED C5-S4 #63). A canary is planted under every name first, and
# the run stops if one survives the loop.
for v in TIFFINBOX_CANARY SPRING_CANARY MANAGEMENT_CANARY SERVER_CANARY LOGGING_CANARY DEBUG JAVA_TOOL_OPTIONS JDK_JAVA_OPTIONS _JAVA_OPTIONS MAVEN_OPTS MAVEN_ARGS NATIVE_IMAGE_OPTIONS; do export "$v=planted-canary"; done
for v in $(env | sed -n -E 's/^(TIFFINBOX_[A-Za-z0-9_]*|SPRING_[A-Za-z0-9_]*|MANAGEMENT_[A-Za-z0-9_]*|SERVER_[A-Za-z0-9_]*|LOGGING_[A-Za-z0-9_]*|DEBUG|JAVA_TOOL_OPTIONS|JDK_JAVA_OPTIONS|_JAVA_OPTIONS|MAVEN_OPTS|MAVEN_ARGS|NATIVE_IMAGE_OPTIONS)=.*/\1/p'); do unset "$v"; done
[ -z "$(env | grep -- '=planted-canary$')" ] || die "a variable survived the clean-up above: $(env | grep -- '=planted-canary$' | sed 's/=.*//' | paste -sd' ' -)"
# Every request this script makes goes to 127.0.0.1. An HTTP proxy named in your environment (http_proxy and the rest) would
# carry curl's requests to that proxy instead of to TiffinBox: 127.0.0.1 and localhost go first in no_proxy and NO_PROXY.
export no_proxy="127.0.0.1,localhost${no_proxy:+,$no_proxy}" NO_PROXY="127.0.0.1,localhost${NO_PROXY:+,$NO_PROXY}"
# The GraalVM: named by GRAALVM_HOME, never guessed and never printed (its folder is masked). The captures were made with
# GraalVM CE 25.3.4.1 (native-image 25.0.4.1); another build would print other lines, so it is refused here, not minutes in.
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
PREV=../c5-unit21/after                              # the previous tree: read, copied, never built in place
JAR=tiffinbox-web/target/tiffinbox-web-1.0.0.jar
BIN=tiffinbox-web/target/tiffinbox-web               # the binary native:compile-no-fork writes, in a tree's web module
TF=secrets/tiffinbox/shutdown-token                  # the config tree's file for tiffinbox.shutdown-token
KHI=tiffinbox-web/src/main/java/com/tiffinbox/web/KitchenHealthIndicator.java
SRV=tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java
ROUTES=tiffinbox-web/src/main/java/com/tiffinbox/web/ActuatorRoutes.java
APP=tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxApp.java
YAML=tiffinbox-web/src/main/resources/application.yaml
# The demo token. FAKE, and meant to look it: it guards nothing but a demo server on 127.0.0.1 that every capture stops. It is
# written into .harness/*/secrets/ (git-ignored) when this script runs, and no capture prints it: see mask().
TOKEN=not-a-real-token-demo-only
[ ${#TOKEN} = 26 ] || die "the demo token must be 26 characters"
CURLSET=../c5-unit11/curlset.sh                      # the comparison set: the seven requests, POST /shutdown with the header
[ -f "$CURLSET" ] || die "$CURLSET is missing"
[ -f "$PREV/pom.xml" ] && [ -f after/pom.xml ] && [ -f after/README.md ] || die "the previous tree $PREV or after/ is missing"
for f in harness/race.py harness/shutdown.sh harness/probe/health/CloseDb.java harness/probe/health/Witness.java harness/probe/health/Refuse.java harness/probe/health/RefuseLater.java; do [ -f "$f" ] || die "harness/ is missing $f"; done

# The ports, BEFORE anything is wiped (a survivor of an interrupted run answers POST /shutdown only with its token, which lives
# in .harness/ - so the message names the process to kill).
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
for p in 18425 8080 19010 19011 19012 19013 19014 19015 19016 19017 19018 19019; do
  [ "$(listeners $p)" = 0 ] || die "something already listens on $p - this unit's ports must be free; if it is a TiffinBox an interrupted run left behind, stop it: kill $(lsof -nP -iTCP:$p -sTCP:LISTEN -t 2> /dev/null | paste -sd' ' -)"; done

# ---- the commands: read from after/README.md, the anchor's own, and asserted - each line must be there, whole -------------
readme() { grep -m1 -xF -- "$1" after/README.md > /dev/null || die "after/README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
R_PLAIN=$(readme 'mvn -B package')
R_RUN=$(readme 'java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431')
R_EXTRACT=$(readme 'java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted')
R_CP=$(readme 'java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431')
R_AOTRUN=$(readme 'java -Dspring.aot.enabled=true -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431')
R_GRAAL=$(readme 'export GRAALVM_HOME=/path/to/a/graalvm-jdk-25')
R_INSTALL=$(readme 'mvn -B -Pnative install')
R_NATIVE=$(readme 'mvn -B -Pnative -pl tiffinbox-web native:compile-no-fork')
R_BIN=$(readme 'tiffinbox-web/target/tiffinbox-web --tiffinbox.port=18431')
R_HEALTH=$(readme "curl -s -w ' %{http_code}\n' http://127.0.0.1:18431/actuator/health")
R_LIVE=$(readme "curl -s -w ' %{http_code}\n' http://127.0.0.1:18431/actuator/health/liveness")
R_READY=$(readme "curl -s -w ' %{http_code}\n' http://127.0.0.1:18431/actuator/health/readiness")
R_ENV=$(readme "curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:18431/actuator/env")
R_COMP=$(readme 'java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --management.endpoint.health.show-components=always')
R_KITCHEN=$(readme "curl -s -w ' %{http_code}\n' http://127.0.0.1:18431/actuator/health/kitchen")
R_DETAILS=$(readme 'java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --management.endpoint.health.show-details=always')
R_NOKITCHEN=$(readme 'java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --management.endpoint.health.group.readiness.include=readinessState')
R_CUSTOMERS=$(readme "curl -s -w ' %{http_code}\n' http://127.0.0.1:18431/customers")
R_PROBES=$(readme 'java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --management.endpoint.health.probes.enabled=false')
# off DIR 'README mvn LINE' [PHASE]: the README's Maven line as this script runs it - from DIR, offline (-o), this unit's own
# repository, and for a build phase (package, install) clean and without tests. dev() takes those four things back out, and
# must give the README's line again: so the command on screen is the README's, with exactly those changes.
off() { local c=${2/mvn -B /mvn -o -B -Dmaven.repo.local=\"\$M2\" }
  [ -n "$3" ] && c=${c/ $3/ -DskipTests clean $3}
  printf 'cd %s && %s\n' "$1" "$c"; }
dev() { local c=${1#cd * && }; c=${c/ -o -B -Dmaven.repo.local=\"\$M2\" / -B }; c=${c/ -DskipTests clean / }; printf '%s\n' "$c"; }
# at DIR PORT 'README LINE': the README's line run from DIR, its port 18431 made PORT
at() { printf 'cd %s && %s\n' "$1" "${3/--tiffinbox.port=18431/--tiffinbox.port=$2}"; }
# url 'README curl LINE' PORT: the README's curl line, its port 18431 made PORT
url() { printf '%s\n' "${1/:18431\//:$2/}"; }
# flag 'README LINE': what the README's run line adds after the port - one flag
flag() { printf '%s\n' "${1##*--tiffinbox.port=18431 }"; }
# hcp DIR PORT SOURCES ['FLAGS']: the README's exploded run - the extracted jar on the class path, TiffinBox's own main - from DIR,
# its port made PORT, the harness's classes added to the class path (../hc) and SOURCES joined (--spring.main.sources), then FLAGS
hcp() { local c; c=$(at "$1" "$2" "$R_CP"); c=${c/lib\/\*\"/lib\/*:..\/hc\"}; printf '%s --spring.main.sources=%s%s\n' "$c" "$3" "${4:+ $4}"; }
F_COMP=$(flag "$R_COMP"); F_DETAILS=$(flag "$R_DETAILS"); F_NOKITCHEN=$(flag "$R_NOKITCHEN"); F_PROBES=$(flag "$R_PROBES")
[ "$F_COMP" = --management.endpoint.health.show-components=always ] && [ "$F_DETAILS" = --management.endpoint.health.show-details=always ] && [ "$F_NOKITCHEN" = --management.endpoint.health.group.readiness.include=readinessState ] && [ "$F_PROBES" = --management.endpoint.health.probes.enabled=false ] || die "a README flag line does not end in its one flag"
C_AFTER=$(off .harness/after "$R_INSTALL" install)
for c in "$C_AFTER" "$(off .harness/x "$R_PLAIN" package)" "$(off .harness/x "$R_NATIVE")"; do
  r=$(dev "$c"); [ "$r" = "$R_PLAIN" ] || [ "$r" = "$R_INSTALL" ] || [ "$r" = "$R_NATIVE" ] || die "not a README line with the offline changes: $c"; done
[ "$(at .harness/x 19016 "$R_BIN")" = "cd .harness/x && tiffinbox-web/target/tiffinbox-web --tiffinbox.port=19016" ] || die "the binary's run line"
[ "$(url "$R_HEALTH" 19012)" = "curl -s -w ' %{http_code}\n' http://127.0.0.1:19012/actuator/health" ] || die "the health line, its port"
[ "$(hcp .harness/x 19013 probe.health.CloseDb)" = 'cd .harness/x && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19013 --spring.main.sources=probe.health.CloseDb' ] || die "the exploded run with the harness"
echo "  the commands: after/README.md gives all 20 lines this script runs or derives from"

# ---- build: one tree before the captures - after/, the README's native install; then what .m2-demo holds ------------------
rm -rf .harness; mkdir -p .harness
rsync -a --exclude target --exclude secrets "$PREV/" .harness/before/
rsync -a after/ .harness/after/
# ZIP: GraalVM's reachability metadata repository, as Maven Central serves it - the native plugin reads it from .m2-demo
ZIP="$M2/org/graalvm/buildtools/graalvm-reachability-metadata/1.1.8/graalvm-reachability-metadata-1.1.8-repository.zip"
# ghub LOG: the native plugin went over the network for its metadata repository - downloaded it (from GitHub, when the zip is not
# in $M2), or tried to (its own two lines). Never allowed: the caller says "offline: no" and stops.
ghub() { grep -qE 'Downloaded GraalVM reachability metadata repository from http|Failed to download from http' "$1"; }
# mbuild 'COMMAND' LOG LABEL: the command, run as printed (eval), its log kept in LOG (never printed whole); Maven Central only
# if the offline build could not resolve something - and the line says which (offline: yes / no), so a run that went online is
# never silent (inside a capture, "no" changes the capture's hash: cap() then dies). A native-profile build while the metadata
# repository is not in $M2 goes to Maven Central at once (offline, the plugin would fetch it from GitHub instead).
mbuild() { local how=yes ec=0 c=$1
  case $c in *' -Pnative '*) [ -f "$ZIP" ] || { c=${c/mvn -o -B /mvn -B }; how="no - GraalVM's metadata repository was not in .m2-demo, so the remote repository (Central or your mirror) was asked for it"; } ;; esac
  (eval "$c") > "$2" 2>&1 < /dev/null || ec=$?
  if [ $ec != 0 ] && [ "$how" = yes ] && grep -qE 'offline mode|Could not resolve|could not be resolved|Cannot access' "$2"; then
    how="no - the offline build could not resolve an artifact, so the remote repository (Central or your mirror) was asked"; ec=0
    (eval "${c/mvn -o -B /mvn -B }") > "$2" 2>&1 < /dev/null || ec=$?; fi
  if ghub "$2"; then echo "  built $3 · offline: no - GraalVM's native plugin went to GitHub for its metadata repository · exit $ec"
    die "$3: GraalVM's native plugin went over the network for its metadata repository - $(grep -m1 -E 'Downloaded GraalVM reachability metadata repository from http|Failed to download from http' "$2" | sed 's/^\[[A-Z]*\] //') - README.md, The repository"; fi
  [ $ec = 0 ] || { tail -30 "$2" >&3
    ! grep -qE 'Could not resolve|could not be resolved|Could not transfer|Cannot access' "$2" || die "build failed: $3 - Maven could resolve Boot's parent and plugins neither from .m2-demo nor from the remote repository (Central or your mirror): a fresh clone's first run needs the network once, to fill .m2-demo"
    die "build failed: $3"; }
  echo "  built $3 · offline: $how · exit $ec"; }
# tree FOLDER: a config tree in FOLDER/secrets holding one file, the token and a newline, readable by its owner alone
tree() { mkdir -p "$1/secrets/tiffinbox"; (umask 077 && printf '%s\n' "$TOKEN" > "$1/$TF"); chmod 700 "$1/secrets" "$1/secrets/tiffinbox"; }
# The first build is the README's native install: it needs nearly every artifact the captures' Maven lines need - the plain ones, the
# profile native's (process-aot, the plugin's add-reachability-metadata and its metadata repository) and install's - so on a
# fresh clone, whose .m2-demo is empty (git ignores it), this one build fills .m2-demo from Maven Central, once. Its extracted jar
# is the class path the harness compiles against, and the folder race, dead, groups and trap run in.
mbuild "$C_AFTER" .harness/build-after.log ".harness/after (after/, the profile native, both modules into \$M2)"
[ -f "$M2/org/springframework/boot/spring-boot-starter-parent/4.1.1/spring-boot-starter-parent-4.1.1.pom" ] || die "Boot's parent POM is not in .m2-demo after the first build"
[ -f "$M2/org/graalvm/buildtools/native-maven-plugin/1.1.8/native-maven-plugin-1.1.8.jar" ] || die "GraalVM's native plugin 1.1.8 is not in .m2-demo after the first build (it is a build extension of the web module)"
[ -f "$ZIP" ] || die "GraalVM's metadata repository is not in .m2-demo after the first build - README.md, The repository"
[ -f "$M2/org/springframework/boot/spring-boot-health/4.1.1/spring-boot-health-4.1.1.jar" ] || die "spring-boot-health 4.1.1 is not in .m2-demo after the first build"
echo "  .m2-demo holds Boot's parent, spring-boot-health 4.1.1, GraalVM's native plugin 1.1.8 and its metadata repository ($(wc -c < "$ZIP" | tr -d ' ') bytes)"
tree .harness/after
(cd .harness/after && eval "$R_EXTRACT") > .harness/extract-after.log 2>&1 || { cat .harness/extract-after.log >&3; die "the README's extract command failed in .harness/after"; }
# The harness's classes (harness/probe/health/*.java), compiled once into .harness/hc against after/'s own class path; every
# exploded run that joins one puts .harness/hc on its class path (../hc, from beside its config tree)
mkdir -p .harness/hc
javac -d .harness/hc -cp ".harness/after/tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:.harness/after/tiffinbox-web/target/extracted/lib/*" harness/probe/health/*.java > .harness/javac.log 2>&1 || { cat .harness/javac.log >&3; die "the harness did not compile"; }
echo "  the harness's four classes compiled into .harness/hc"

# ---- helpers ------------------------------------------------------------------------------------------------------------
# raw TOKEN FILE...: how many times TOKEN appears, raw, in the files (occurrences, not lines; binary files read as text)
raw() { local t=$1; shift; cat "$@" | LC_ALL=C grep -aoF -- "$t" | wc -l | tr -d ' '; }
# first LOG: Boot's first log line, from its message on, cut before " with PID"
first() { grep -m1 ' : Starting ' "$1" | sed 's/^.* : //; s/ with PID .*$//'; }
# start 'COMMAND': print it exactly as typed, run it in the background (eval, from this folder; exec, so $pid is the program's
# own pid), its standard output to .harness/run.out and its standard error to .harness/run.err
start() { echo "\$ $1"; (eval "${1/&& /&& exec }") > .harness/run.out 2> .harness/run.err < /dev/null & pid=$!; }
# listening [N]: what the operating system says the process listens on (lsof), once it listens on N addresses (1 unless said)
# - or what it listened on when it exited ("nothing" if never)
listening() { local a="" i=0 n=${1:-1}
  while [ $i -lt 160 ]; do
    a=$(lsof -nP -a -p "$pid" -iTCP -sTCP:LISTEN 2> /dev/null | awk 'NR > 1 { print $9 }' | sort -u | paste -sd' ' -)
    [ -n "$a" ] && [ "$(printf '%s\n' "$a" | wc -w | tr -d ' ')" -ge "$n" ] && break; kill -0 "$pid" 2> /dev/null || break; sleep 0.25; i=$((i + 1)); done
  echo "${a:-nothing}"; }
# up: the line after a start - where it listens, Boot's first line; dies if it never listened
up() { local l; l=$(listening); [ "$l" != nothing ] || { tail -20 .harness/run.out >&3; die "it never listened"; }
  echo "  listens on: $l"; echo "  Boot's first line: $(first .harness/run.out)"; }
# sortjson: a line "BODY CODE" whose BODY is a JSON object is printed with the object's keys sorted, compact (Python's json) - every
# other line as it came. The bridge writes Boot's health answers with TiffinBox's Jackson 2, which orders an answer's properties as
# reflection lists them, and that order moved between runs here ("status" before or after "details"): sorted, the capture holds
# what the answer says, not the order a run happened to list it in (S4.6).
sortjson() { python3 -c '
import json, sys
for line in sys.stdin:
    line = line.rstrip("\n"); body, sep, code = line.rpartition(" ")
    if sep and body.startswith("{"):
        try: line = json.dumps(json.loads(body), sort_keys=True, separators=(",", ":")) + " " + code
        except ValueError: pass
    print(line)'; }
# ask 'README curl LINE' PORT: the README's curl line, its port made PORT, printed and run; what it printed, a JSON object's keys
# sorted (sortjson), indented
ask() { local c; c=$(url "$1" "$2"); echo "\$ $c"; (eval "$c") 2>&1 < /dev/null | sortjson | sed 's/^/  /'; }
# ready PORT: readiness asked until it answers 200 - every 0.25 s, up to 60 s, not printed (the race has a capture of its own) -
# then the README's readiness line, printed and run once. No health assertion before it (brief S4.15), except where readiness is
# the thing measured: there, the harness's own last line is waited for instead (held).
ready() { local i=0 c=""
  while [ $i -lt 240 ]; do c=$(curl -s -o /dev/null -w '%{http_code}' "http://127.0.0.1:$1/actuator/health/readiness" 2> /dev/null || true); [ "$c" = 200 ] && break
    kill -0 "$pid" 2> /dev/null || { tail -20 .harness/run.out >&3; die "it exited before readiness answered 200"; }; sleep 0.25; i=$((i + 1)); done
  [ "$c" = 200 ] || die "readiness never answered 200 on $1"
  ask "$R_READY" "$1"; }
# held: the harness's last line ("harness: done") waited for - up to 40 s - then every line the harness printed so far, indented
held() { local i=0
  while [ $i -lt 160 ] && ! grep -q '^harness: done$' .harness/run.out; do kill -0 "$pid" 2> /dev/null || break; sleep 0.25; i=$((i + 1)); done
  grep -q '^harness: done$' .harness/run.out || { tail -20 .harness/run.out >&3; die "the harness never printed its last line"; }
  grep '^harness: ' .harness/run.out | grep -v '^harness: done$' | sed 's/^/  /'; }
# booted: Boot's own line that the context is refreshed and the application started - up to 40 s
booted() { local i=0
  while [ $i -lt 160 ] && ! grep -q ' : Started TiffinBoxServer in ' .harness/run.out; do kill -0 "$pid" 2> /dev/null || break; sleep 0.25; i=$((i + 1)); done
  grep -q ' : Started TiffinBoxServer in ' .harness/run.out || { tail -20 .harness/run.out >&3; die "Boot never said it started"; }
  echo "  Boot's started line, waited for (its times cut): $(grep -m1 ' : Started TiffinBoxServer in ' .harness/run.out | sed 's/^.* : //; s/ in .*$//')"; }
# seven PORT DIR [all]: the comparison set's seven requests (POST /shutdown carries the header, read from DIR's token file),
# printed as run - every response line with "all", else the POST line; the process must leave within 15 s of them, and the port
# must be free again. Never call it inside $(...): wait needs this shell.
seven() { local i e=0
  echo "\$ \$CURLSET $1 $2/$TF"
  "$CURLSET" "$1" "$2/$TF" | grep ' -> ' > .harness/responses.txt || true
  if [ "$3" = all ]; then sed 's/^/  /' .harness/responses.txt; else grep '^POST ' .harness/responses.txt | sed 's/^/  /' || echo "  (no POST line)"; fi
  i=0; while kill -0 "$pid" 2> /dev/null && [ $i -lt 60 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$pid" 2> /dev/null && { kill "$pid"; die "the server on $1 was still running 15 s after POST /shutdown"; }
  wait "$pid" || e=$?; pid=""
  [ "$(listeners "$1")" = 0 ] || die "something still listens on $1"
  echo "  exit $e · the seven responses: $(wc -l < .harness/responses.txt | tr -d ' ') lines · md5 $(md5 -q .harness/responses.txt)"; }
# analysed PORT: after a start that stops with Boot's failure analysis - TiffinBox's own line if its server opened first, the
# banner and the stack frames counted, the analysis's description and action whole, the exit code. Never inside $(...).
analysed() { local e=0
  wait "$pid" || e=$?; pid=""
  echo "  TiffinBox's own line, before it stopped: $(grep -m1 -oE 'TiffinBox listening on http://[0-9.:]+' .harness/run.out || echo '(none)')"
  echo "  Boot's failure analysis (its banner, APPLICATION FAILED TO START): $(grep -c '^APPLICATION FAILED TO START$' .harness/run.out || true) · stack frames (lines starting 'at '): $(grep -cE '^[[:space:]]+at ' .harness/run.out || true) - the analysis, every line after its banner but the blank ones:"
  awk '/^APPLICATION FAILED TO START$/ { f = 1; next } f && NF && $0 !~ /^\*+$/ { print "    " $0 }' .harness/run.out
  echo "  exit $e · listening on $1 now: $(listeners "$1")"; }
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
# copy SRC DEST: a tree copied without its target/ and secrets/, then a config tree of its own
copy() { rm -rf "$2" "$2".*; rsync -a --exclude target --exclude secrets "$1/" "$2/"; tree "$2"; }
# pbuild DIR 'LABEL': the README's plain Maven line, offline, from DIR
pbuild() { local c; c=$(off "$1" "$R_PLAIN" package); echo "\$ $c"; mbuild "$c" "$1.build.log" "$2"; }
# filtered PORT DIR: health's whole answer saved beside DIR's config tree (the README's env line, its file and its path changed),
# read as JSON - its status and each component's status, never a detail (they hold a disk's sizes and a folder's path) - and
# deleted in the same step
filtered() { local c; c=$(url "$R_ENV" "$1"); c="cd $2 && ${c/-o \/dev\/null/-o health.json}"; c=${c/actuator\/env/actuator/health}
  echo "\$ $c"; (eval "$c") 2>&1 < /dev/null | sed 's/^/  /'
  python3 - "$2/health.json" <<'PY'
import json, sys
d = json.load(open(sys.argv[1]))
print("  its answer, through a filter - the status, then each component's status (details never printed): %s · %s"
      % (d["status"], " · ".join("%s %s" % (k, v["status"]) for k, v in sorted(d.get("components", {}).items()))))
PY
  rm -f "$2/health.json"; echo "  the answer deleted: $([ -f "$2/health.json" ] && echo no || echo yes)"; }

# ---- parts: the previous tree - blind to the database; its components and groups; the switch for the groups ----------------
# order JAR: Boot's status order - the statuses Status.DEFAULT_ORDER lists, in order, read from JAR's class with javap -c (the four
# fields loaded just before the list is stored); health and each group answer the first of them that a component holds (RED C5-S4 #15)
order() { javap -c -p -cp "$1" org.springframework.boot.health.contributor.Status | awk '
  /static \{\};/ { s = 1 }
  s && /putstatic .*Field DEFAULT_ORDER:/ { print substr(o, 2); exit }
  s && /putstatic/ { o = "" }
  s && /getstatic .*Field [A-Z_]+:Lorg\/springframework\/boot\/health\/contributor\/Status;/ { f = $NF; sub(/:.*/, "", f); o = o " " f }'; }
parts() {
  echo "the previous tree (the anchor as the Actuator lesson left it), copied to .harness/prev with a config tree, built the README's"
  echo "plain way and extracted (the README's extract line):"
  copy "$PREV" .harness/prev
  pbuild .harness/prev "the previous tree"
  (cd .harness/prev && eval "$R_EXTRACT") > .harness/prev.extract.log 2>&1 || { cat .harness/prev.extract.log >&3; die "the extract failed in .harness/prev"; }
  echo "1 - the database closed by the harness once TiffinBox is ready: the README's exploded run, the harness joined, port 19010:"
  start "$(hcp .harness/prev 19010 probe.health.CloseDb)"; up; held
  ask "$R_HEALTH" 19010
  ask "$R_CUSTOMERS" 19010
  seven 19010 .harness/prev
  echo "2 - what health is made of: the README's line that shows the components, the same jar, port 19010:"
  start "$(at .harness/prev 19010 "$R_COMP")"; up; ready 19010
  ask "$R_HEALTH" 19010
  ask "$R_LIVE" 19010
  seven 19010 .harness/prev
  echo "  how health and each group pick their answer - Boot's status order, Status.DEFAULT_ORDER in spring-boot-health 4.1.1 (javap -c,"
  echo "  the jar's lib): $(order .harness/prev/tiffinbox-web/target/extracted/lib/spring-boot-health-4.1.1.jar) - the first of them a component holds"
  echo "3 - the switch for the groups: the README's line, the components shown too:"
  start "$(at .harness/prev 19010 "$R_PROBES") $F_COMP"; up; booted
  ask "$R_HEALTH" 19010
  ask "$R_LIVE" 19010
  ask "$R_READY" 19010
  seven 19010 .harness/prev
  echo "4 - the older key in its place (management.health.probes.enabled):"
  start "$(at .harness/prev 19010 "${R_PROBES/management.endpoint.health.probes/management.health.probes}")"; up; ready 19010
  ask "$R_LIVE" 19010
  seven 19010 .harness/prev
  echo "the two keys, as Boot's own metadata states them (spring-boot-health's spring-configuration-metadata.json, in the jar's lib):"
  python3 - .harness/prev/tiffinbox-web/target/extracted/lib/spring-boot-health-4.1.1.jar <<'PY'
import json, sys, zipfile
d = json.loads(zipfile.ZipFile(sys.argv[1]).read("META-INF/spring-configuration-metadata.json"))
for p in d["properties"]:
    if p["name"] in ("management.endpoint.health.probes.enabled", "management.health.probes.enabled"):
        x = p.get("deprecation")
        print("  %s · default %s%s" % (p["name"], str(p.get("defaultValue")).lower(),
              " · deprecated since %s, level %s, replaced by %s" % (x["since"], x["level"], x["replacement"]) if x else ""))
PY
}

# ---- race: who answers first, polled from the fork --------------------------------------------------------------------------
race() { local c l n f
  echo "after/'s jar, extracted by the run's first build (.harness/after), run exploded with the harness's witness joined;"
  echo "harness/race.py forks it and asks /kitchen, liveness and readiness in turn, as fast as it can, until all three answer 200 -"
  echo "it prints only what holds in every run, never a count - then POST /shutdown, port 19011:"
  l=$(hcp .harness/after 19011 probe.health.Witness)
  c="cd .harness/after && python3 ../../harness/race.py 19011 $TF ../race.out ../race.err -- ${l#cd .harness/after && }"
  echo "\$ $c"; (eval "$c") 2>&1 < /dev/null | sed 's/^/  /'
  [ "$(listeners 19011)" = 0 ] || die "race left 19011 bound"
  n=$(grep -cE ' : TiffinBox listening on | : Started TiffinBoxServer in |^harness: ' .harness/race.out || true)
  f=$(grep -c ' : Obtaining singleton bean ' .harness/race.out || true)
  echo "the run's log, in order - TiffinBox's line, Boot's started line (its times cut), the witness's lines. Not shown: the other"
  echo "$(( $(wc -l < .harness/race.out | tr -d ' ') - n - f )) lines (Boot's banner and starting lines, TiffinBox's own), and Spring's notes that a request's thread obtained"
  echo "a bean while the main thread held the singleton lock - $( [ "$f" -lt 10 ] && echo 'fewer than 10' || echo "$f, not fewer than 10" ), a bound: their number moves from run to run:"
  grep -E ' : TiffinBox listening on | : Started TiffinBoxServer in |^harness: ' .harness/race.out | sed 's/^.* : //; s/^\(Started TiffinBoxServer\) in .*$/\1/' | sed 's/^/  /'; }

# ---- change: the previous tree against after/ ---------------------------------------------------------------------------------
gained() { diff ".harness/before/$1" ".harness/after/$1" > .harness/file.diff || true
  echo "  $1 - the lines it gains that are neither comment nor blank:"
  sed -n 's/^> //p' .harness/file.diff | awk '{ t = $0; sub(/^[ \t]+/, "", t) } t == "" || t ~ /^(\/\*\*|\*|\/\/|#)/ { next } { print "    " $0 }'
  echo "    (diff adds $(grep -c '^> ' .harness/file.diff || true) lines, removes $(grep -c '^< ' .harness/file.diff || true))"; }
change() { local f t
  echo "the previous tree against after/, both copied under .harness/ - the files that differ:"
  echo "\$ diff -rq -x target -x secrets .harness/before .harness/after"
  diff -rq -x target -x secrets .harness/before .harness/after | sed 's/^/  /' || true
  f=.harness/after/$KHI
  echo "  $KHI - new: $(wc -l < "$f" | tr -d ' ') lines · imports $(grep -c '^import ' "$f" || true) · comment lines $(awk '{ t = $0; sub(/^[ \t]+/, "", t) } t ~ /^(\/\*\*|\*|\/\/)/ { n++ } END { print n + 0 }' "$f") · blank $(grep -c '^[[:space:]]*$' "$f" || true) - its key lines (grep -n):"
  for t in '@Component' 'public final class KitchenHealthIndicator implements HealthIndicator {' 'public Health health() {' 'return Health.up()' '.withDetail("customers", repo.findAll().size())' '.withDetail("ordersCooked", kitchen.cooked())' '} catch (Exception e) {' 'return Health.down().withDetail("error", e.getClass().getSimpleName()).build();'; do
    grep -nF -- "$t" "$f" | sed 's/^\([0-9]*\):[ \t]*/    \1: /'; done
  gained "$YAML"
  diff .harness/before/README.md .harness/after/README.md > .harness/file.diff || true
  echo "  README.md - the anchor's README: lines added $(grep -c '^> ' .harness/file.diff || true), removed $(grep -c '^< ' .harness/file.diff || true) - its new section (not shown)"
  for t in "$ROUTES" "$SRV" "$APP"; do
    echo "  $(basename "$t") against the previous tree's, byte for byte: $(cmp -s ".harness/before/$t" ".harness/after/$t" && echo the same || echo different)"; done; }

# ---- kitchen: after/, as the README builds and runs it -------------------------------------------------------------------------
kitchen() {
  echo "after/, copied to .harness/serve with a config tree, built the README's plain way; its jar run as the README runs it, port 19012:"
  copy after .harness/serve
  pbuild .harness/serve "after/"
  start "$(at .harness/serve 19012 "$R_RUN")"; up; ready 19012
  ask "$R_HEALTH" 19012
  ask "$R_KITCHEN" 19012
  seven 19012 .harness/serve
  echo "the README's line that shows the components:"
  start "$(at .harness/serve 19012 "$R_COMP")"; up; ready 19012
  ask "$R_HEALTH" 19012
  ask "$R_KITCHEN" 19012
  seven 19012 .harness/serve
  echo "the README's line that shows the details - the kitchen asked alone (health's whole answer would show a disk and a folder):"
  start "$(at .harness/serve 19012 "$R_DETAILS")"; up; ready 19012
  ask "$R_KITCHEN" 19012
  seven 19012 .harness/serve
  echo "the README's line that switches the groups off:"
  start "$(at .harness/serve 19012 "$R_PROBES")"
  analysed 19012; }

# ---- dead: the database closed by the harness ----------------------------------------------------------------------------------
dead() {
  echo "after/'s jar, extracted (.harness/after), run exploded with the harness joined - it closes the database once TiffinBox is"
  echo "ready - and the README's details flag, port 19013:"
  start "$(hcp .harness/after 19013 probe.health.CloseDb "$F_DETAILS")"; up; held
  filtered 19013 .harness/after
  ask "$R_LIVE" 19013
  ask "$R_READY" 19013
  ask "$R_KITCHEN" 19013
  ask "$R_CUSTOMERS" 19013
  ask "${R_CUSTOMERS/\/customers//kitchen}" 19013
  seven 19013 .harness/after all; }

# ---- groups: the break --------------------------------------------------------------------------------------------------------
groups() {
  echo "the break: which group the kitchen joins. In every run the harness closes the database once TiffinBox is ready; after/'s"
  echo "jar, extracted (.harness/after), run exploded, port 19014."
  echo "A - after/ as it is (application.yaml: readiness includes readinessState,kitchen):"
  start "$(hcp .harness/after 19014 probe.health.CloseDb)"; up; held
  ask "$R_LIVE" 19014; ask "$R_READY" 19014; ask "$R_CUSTOMERS" 19014
  seven 19014 .harness/after
  echo "B - the README's flag that leaves the kitchen out of readiness:"
  start "$(hcp .harness/after 19014 probe.health.CloseDb "$F_NOKITCHEN")"; up; held
  ask "$R_LIVE" 19014; ask "$R_READY" 19014; ask "$R_CUSTOMERS" 19014
  seven 19014 .harness/after
  echo "A' - A again:"
  start "$(hcp .harness/after 19014 probe.health.CloseDb)"; up; held
  ask "$R_LIVE" 19014; ask "$R_READY" 19014; ask "$R_CUSTOMERS" 19014
  seven 19014 .harness/after; }

# ---- trap: readiness changed by hand ------------------------------------------------------------------------------------------
handmade() { local e=0
  echo "C (labelled) - readiness changed by hand: after/'s jar, extracted (.harness/after), run exploded with the harness's witness,"
  echo "port 19015."
  echo "1 - a runner publishes REFUSING_TRAFFIC (the harness's Refuse):"
  start "$(hcp .harness/after 19015 probe.health.Witness,probe.health.Refuse)"; up; ready 19015
  ask "$R_HEALTH" 19015
  seven 19015 .harness/after
  echo "  the witness's lines, in order:"; grep '^harness: ' .harness/run.out | sed 's/^/    /'
  echo "2 - after Boot's own ACCEPTING_TRAFFIC, a thread publishes REFUSING_TRAFFIC (the harness's RefuseLater); then a SIGTERM:"
  start "$(hcp .harness/after 19015 probe.health.Witness,probe.health.RefuseLater)"; up; held
  ask "$R_HEALTH" 19015
  ask "$R_LIVE" 19015
  ask "$R_READY" 19015
  echo "\$ kill -TERM \$pid"; kill -TERM "$pid"; wait "$pid" || e=$?; pid=""
  echo "  exit $e · listening on 19015 now: $(listeners 19015)"
  echo "  the witness's lines from the context's close on: $(awk '/^harness: the context closes/ { f = 1 } f && /^harness: / { n++ } END { print n + 0 }' .harness/run.out) - $(grep '^harness: the context closes' .harness/run.out | sed 's/^harness: //') · states published after it: $(awk '/^harness: the context closes/ { f = 1; next } f && /^harness: [A-Za-z]*State / { n++ } END { print n + 0 }' .harness/run.out)"
  echo "  the classes in the jar's BOOT-INF/lib whose bytes name REFUSING_TRAFFIC (read from .harness/after's extracted lib):"
  python3 - .harness/after/tiffinbox-web/target/extracted/lib <<'PY'
import os, sys, zipfile
found = []
for j in sorted(os.listdir(sys.argv[1])):
    z = zipfile.ZipFile(os.path.join(sys.argv[1], j))
    found += [n[:-6].rsplit("/", 1)[-1] for n in z.namelist() if n.endswith(".class") and b"REFUSING_TRAFFIC" in z.read(n)]
print("    %d jars read · %d classes: %s" % (len(os.listdir(sys.argv[1])), len(found), " ".join(sorted(found))))
PY
}

# ---- native: after/, built natively; the AOT jar and the binary ------------------------------------------------------------------
# nbuild DIR: the README's native install, then its native:compile-no-fork - both offline, from DIR; the native build's log kept in
# DIR.native.log (never printed whole), its seconds to the terminal
nbuild() { local ci cn s0 s1
  ci=$(off "$1" "$R_INSTALL" install); cn=$(off "$1" "$R_NATIVE")
  echo "\$ $ci"; mbuild "$ci" "$1.install.log" "$1 (both modules, into \$M2)"
  echo "\$ $cn"
  NB_E=0; s0=$(date +%s); (eval "$cn") > "$1.native.log" 2>&1 < /dev/null || NB_E=$?; s1=$(date +%s); NB_S=$((s1 - s0))
  echo "  (terminal only) the native build in $1 took $NB_S s" >&3
  if ghub "$1.native.log"; then echo "  offline: no - GraalVM's native plugin went to GitHub for its metadata repository"; die "the native build in $1: GraalVM's native plugin went over the network for its metadata repository - README.md, The repository"; fi; }
# nlines LOG: native-image's lines a capture shows, in order - the plugin's goal and the GraalVM it found, the builder's Java,
# its warnings (the file URL cut), the stage names (their timings cut), the warning count and Maven's result - and how many it
# does not show
nlines() {
  echo "  its lines, in order (the rest - $(grep -cvE '^\[INFO\] --- |^\[INFO\] Found GraalVM|^ - Java version: |^Warning: |^\[[1-8]/8\] |^\[INFO\] BUILD |^The build process encountered ' "$1" || true) lines - not shown):"
  grep -E '^\[INFO\] --- .* @ tiffinbox-web ---$|^\[INFO\] Found GraalVM installation from ' "$1" | sed 's/^\[INFO\] /    /'
  grep -E '^ - Java version: ' "$1" | sed 's/^ - /    /'
  grep -E '^Warning: ' "$1" | sed "s/ in 'file:[^']*'/ in '…'/" | sed 's/^/    /'
  grep -E '^\[[1-8]/8\] ' "$1" | sed 's/\.\.\..*$/.../' | sed 's/^/    /'
  grep -E '^The build process encountered |^\[INFO\] BUILD ' "$1" | sed 's/^\[INFO\] //' | sed 's/^/    /'; }
# nresult LOG: the native build's result - its exit, Maven's result, the stages against the count it announces, its duration
# against the bound (1 minute or more, under 20 minutes: this Mac's native builds took up to 15 under load - RED C5-S4 #8, the brief's
# ERRATA), and the network (offline: nbuild stopped the run if the plugin went out)
nresult() { echo "  exit $NB_E · $(grep -m1 -oE 'BUILD (SUCCESS|FAILURE)' "$1" || echo 'no BUILD line') · stages it printed: $(grep -cE '^\[[1-8]/8\] ' "$1" || true) of the $(grep -m1 -oE '^\[1/[0-9]+\]' "$1" | sed 's/.*\///; s/]//') it announces · its duration, against the bound: $( [ $NB_S -ge 60 ] && echo '1 minute or more' || echo 'under 1 minute' ), $( [ $NB_S -lt 1200 ] && echo 'under 20 minutes' || echo '20 minutes or more' ) · offline: yes"; }
native() {
  echo "after/, copied to .harness/nat with a config tree; the README's two Maven lines, offline; \$GRAALVM_HOME names the GraalVM:"
  copy after .harness/nat
  nbuild .harness/nat
  nlines .harness/nat.native.log
  nresult .harness/nat.native.log
  echo "  file: $(file -b ".harness/nat/$BIN" | sed 's/ [A-Za-z0-9_]*$//') · the demo token in its bytes: $(raw "$TOKEN" ".harness/nat/$BIN")"
  echo "the AOT jar - the README's AOT line, with the README's flag that shows the components, port 19016:"
  start "$(at .harness/nat 19016 "$R_AOTRUN") $F_COMP"; up; ready 19016
  ask "$R_KITCHEN" 19016
  seven 19016 .harness/nat
  echo "the binary - the README's line, the same flag:"
  start "$(at .harness/nat 19016 "$R_BIN") $F_COMP"; up; ready 19016
  ask "$R_KITCHEN" 19016
  seven 19016 .harness/nat all; }

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
  echo "  exit $ec · listening on 19019 now: $(listeners 19019)"; }

cap parts parts
cap race race
cap change change
cap kitchen kitchen
cap dead dead
cap groups groups
cap trap handmade
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
# this unit ships for reading, nor the binary this run built
for f in .harness/raw-*; do [ "$(cat "$f")" = 0 ] || die "a capture's raw output held the demo token ($f)"; done
NBIN=0
for f in .r-*.out README.md exercise/README.md exercise/solution/SOLUTION.md receipts.md5 harness/race.py harness/shutdown.sh harness/probe/health/*.java after/README.md "after/$YAML" "after/$KHI" .harness/nat/$BIN; do
  [ -f "$f" ] || continue; case $f in .harness/nat/*) NBIN=$((NBIN + 1)) ;; esac
  [ "$(raw "$TOKEN" "$f")" = 0 ] || die "$f holds the demo token, raw"; done
[ "$NBIN" = 1 ] || die "one binary was built, $NBIN were checked"
for f in .r-*.out; do ! grep -qE '/Users/|/private/|/home/|/var/folders/' "$f" || die "$f holds an absolute path"; ! grep -qF "$GRAALVM_HOME" "$f" || die "$f holds the GraalVM's folder"; ! grep -qE 'c[0-9]-unit[0-9]|unit ?[0-9]' "$f" || die "$f holds a unit number"; ! grep -qE '"(total|free|path)":' "$f" || die "$f holds a disk's details"; done
[ -z "$(find .harness -name health.json | head -1)" ] || die "health's whole answer was left under .harness/"
echo "  token: 0 raw copies in $(ls .harness/raw-* | wc -l | tr -d ' ') raw capture runs, in $(ls .r-*.out | wc -l | tr -d ' ') captures, the READMEs, the harness, receipts.md5 and the binary; no absolute path, no GraalVM folder, no unit number, no disk detail in any capture"
# S4.16: no star in an exposure list anywhere in this unit - its scripts, its READMEs, its captures
for f in receipts.sh README.md exercise/README.md exercise/solution/SOLUTION.md .r-*.out; do
  [ -f "$f" ] || continue
  ! grep -nE "exposure\.include='?\*" "$f" | grep -vF 'grep -nE "exposure' | grep -q . || die "$f: a star in an exposure list"; done

H2='{"groups":["liveness","readiness"],"status":"UP"}'
# "Lunch rush. The harness closes TiffinBox's database. Slash customers: five hundred. Slash actuator slash health: UP."
PA1=$(blk parts '1 - the database closed' '2 - what health is made of')
has "$PA1" "  harness: readiness ACCEPTING_TRAFFIC, then H2's SHUTDOWN: the database is closed" "parts 1"
has "$PA1" "  harness: the same URL, connected again: a database with 0 tables" "parts 1: the new, empty database"
has "$PA1" "  $H2 200" "parts 1: health UP"
has "$PA1" '  {"error":"JdbcSQLSyntaxErrorException"} 500' "parts 1: /customers 500"
# "Shown by a flag: five components ... and two groups."
PA2=$(blk parts '2 - what health is made of' '3 - the switch')
has "$PA2" '  {"components":{"diskSpace":{"status":"UP"},"livenessState":{"status":"UP"},"ping":{"status":"UP"},"readinessState":{"status":"UP"},"ssl":{"status":"UP"}},"groups":["liveness","readiness"],"status":"UP"} 200' "parts 2: five components, two groups"
[ "$(printf '%s\n' "$PA2" | grep -cxF '  {"status":"UP"} 200')" = 2 ] || die "parts 2: Boot's own groups show no components, even with the flag"
NCOMP0=$(printf '%s\n' "$PA2" | grep -m1 '"components":{"diskSpace"' | grep -oE '"[A-Za-z]+":\{"status":"UP"\}' | wc -l | tr -d ' ')
[ "$NCOMP0" = 5 ] || die "parts: five components ($NCOMP0)"
# "...answers UP, DOWN or out of service; health takes the first in Boot's order: DOWN, then out of service, then UP." (RED C5-S4 #15)
has "$PA2" "  the jar's lib): DOWN OUT_OF_SERVICE UP UNKNOWN - the first of them a component holds" "parts 2: Boot's status order"
PA3=$(blk parts '3 - the switch' '4 - the older key'); PA4=$(blk parts '4 - the older key' 'the two keys')
has "$PA3" '  {"components":{"diskSpace":{"status":"UP"},"ping":{"status":"UP"},"ssl":{"status":"UP"}},"status":"UP"} 200' "parts 3: no groups, no states"
[ "$(printf '%s\n' "$PA3" | grep -cxF '   404')" = 2 ] || die "parts 3: liveness and readiness 404"
[ "$(printf '%s\n' "$PA4" | grep -cxF '  {"status":"UP"} 200')" = 2 ] || die "parts 4: the older key changes nothing"
x parts '^  management\.endpoint\.health\.probes\.enabled · default true$'
x parts '^  management\.health\.probes\.enabled · default false · deprecated since 2\.3\.2, level error, replaced by management\.endpoint\.health\.probes\.enabled$'
[ "$(n parts "^  exit 0 · the seven responses: 7 lines · md5 $S115\$")" = 3 ] || die "parts: the seven, three times"
x parts ' · offline: yes · exit 0$'
echo "  parts: dead database - health UP, /customers 500 · 5 components, 2 groups (Boot's own: no components shown) · probes off: 404, 404 · the older key: nothing (deprecated 2.3.2, error)"

# "Polled from the moment the process forks: slash kitchen answered two hundred while liveness and readiness both said five oh
# three. ... Boot publishes live after the refresh, and ready after that."
x race '^  the first round in which all three answered: /kitchen 200 · liveness 503 \{"status":"DOWN"\} · readiness 503 \{"status":"OUT_OF_SERVICE"\}$'
x race '^  /kitchen answered 200 at least once while liveness and readiness both answered 503: yes$'
x race '^  the last round: /kitchen 200 · liveness 200 \{"status":"UP"\} · readiness 200 \{"status":"UP"\}$'
x race '^  exit 0 after POST /shutdown 200$'
RO=$(blk race "a bean while the main thread held" '' | sed 's/^  //' | paste -sd'|' -)
[ "$RO" = "TiffinBox listening on http://127.0.0.1:19011|Started TiffinBoxServer|harness: LivenessState CORRECT - published on the thread main|harness: ReadinessState ACCEPTING_TRAFFIC - published on the thread main|harness: the context closes - on the thread SpringApplicationShutdownHook" ] || die "race: the log's order ($RO)"
echo "  race: /kitchen 200 while liveness 503 (DOWN) and readiness 503 (OUT_OF_SERVICE) · then 200/200/200 · the log: listening, Started, CORRECT, ACCEPTING_TRAFFIC"

# "So the kitchen gets an indicator: one bean ... Boot names the component after the bean ... And one line in application dot yaml
# puts it in the readiness group. ActuatorRoutes, the Actuator lesson's bridge, didn't change a byte."
x change '^  Only in \.harness/after/tiffinbox-web/src/main/java/com/tiffinbox/web: KitchenHealthIndicator\.java$'
x change '^  tiffinbox-web/src/main/java/com/tiffinbox/web/KitchenHealthIndicator\.java - new: [0-9]+ lines · imports 5 · comment lines [0-9]+ · blank [0-9]+ - its key lines \(grep -n\):$'
x change '^    [0-9]+: public final class KitchenHealthIndicator implements HealthIndicator \{$'
x change '^    [0-9]+: \.withDetail\("customers", repo\.findAll\(\)\.size\(\)\)$'
x change '^    [0-9]+: return Health\.down\(\)\.withDetail\("error", e\.getClass\(\)\.getSimpleName\(\)\)\.build\(\);$'
x change '^              include: readinessState,kitchen$'
for t in ActuatorRoutes TiffinBoxServer TiffinBoxApp; do x change "^  $t\\.java against the previous tree.s, byte for byte: the same\$"; done
cmp -s "after/$APP" "$PREV/$APP" && cmp -s "after/$ROUTES" "$PREV/$ROUTES" || die "TiffinBoxApp.java or ActuatorRoutes.java changed: neither may (brief ⚑11; the bridge needs no change)"
[ "$(diff -rq -x target -x secrets "$PREV" after | wc -l | tr -d ' ')" = 3 ] || die "change: after/ differs from the previous tree in more than the README, the YAML and the new class"
echo "  change: KitchenHealthIndicator new (5 imports, UP with customers, DOWN with the error's class) · include: readinessState,kitchen · the bridge, the server and the app byte for byte the same"

# "Health: UP, two groups. Slash actuator slash health slash kitchen: four oh four ... With show-components, six components, kitchen
# UP. With show-details, on the kitchen alone: four customers, a hundred twenty orders cooked."
KA=$(blk kitchen "after/, copied to .harness/serve" "the README's line that shows the components"); KB=$(blk kitchen "the README's line that shows the components" "the README's line that shows the details"); KC=$(blk kitchen "the README's line that shows the details" "the README's line that switches"); KD=$(blk kitchen "the README's line that switches" '')
has "$KA" "  $H2 200" "kitchen: health"; has "$KA" "   404" "kitchen: its path 404 without the flag"
has "$KB" '  {"components":{"diskSpace":{"status":"UP"},"kitchen":{"status":"UP"},"livenessState":{"status":"UP"},"ping":{"status":"UP"},"readinessState":{"status":"UP"},"ssl":{"status":"UP"}},"groups":["liveness","readiness"],"status":"UP"} 200' "kitchen: six components"
has "$KB" '  {"components":{"kitchen":{"status":"UP"},"readinessState":{"status":"UP"}},"status":"UP"} 200' "kitchen: readiness holds the kitchen"
has "$KB" '  {"status":"UP"} 200' "kitchen: its path 200 with the flag"
NCOMP1=$(printf '%s\n' "$KB" | grep -m1 '"components":{"diskSpace"' | grep -oE '"[A-Za-z]+":\{"status":"UP"\}' | wc -l | tr -d ' ')
[ "$NCOMP1" = 6 ] || die "kitchen: six components ($NCOMP1)"
has "$KC" '  {"details":{"customers":4,"ordersCooked":120},"status":"UP"} 200' "kitchen: the details"
has "$KD" "  TiffinBox's own line, before it stopped: TiffinBox listening on http://127.0.0.1:19012" "kitchen: probes off"
has "$KD" "    Health contributor 'readinessState' defined in 'management.endpoint.health.group.readiness.include' does not exist" "kitchen: probes off, Boot's sentence"
has "$KD" "  Boot's failure analysis (its banner, APPLICATION FAILED TO START): 1 · stack frames (lines starting 'at '): 0 - the analysis, every line after its banner but the blank ones:" "kitchen: probes off, analysed"
has "$KD" "  exit 1 · listening on 19012 now: 0" "kitchen: probes off, exit 1"
[ "$(n kitchen "^  exit 0 · the seven responses: 7 lines · md5 $S115\$")" = 3 ] || die "kitchen: the seven, three times"
echo "  kitchen: health UP, kitchen 404 hidden · 6 components, kitchen UP, readiness = kitchen + readinessState · 4 customers, 120 orders · probes off: exit 1, Boot names readinessState"

# "Health: five oh three, kitchen DOWN, and the kitchen says why: JdbcSQLSyntaxErrorException ... the table is gone. Liveness: two
# hundred. Readiness: five oh three. Slash customers: five hundred. Slash kitchen: two hundred, from memory."
x dead "^  harness: readiness ACCEPTING_TRAFFIC, then H2's SHUTDOWN: the database is closed\$"
# "H2 opened a new, empty database under the same name, so the table is gone."
x dead '^  harness: the same URL, connected again: a database with 0 tables$'
x dead "^  503\$"
x dead "^  its answer, through a filter - the status, then each component's status \(details never printed\): DOWN · diskSpace UP · kitchen DOWN · livenessState UP · ping UP · readinessState UP · ssl UP\$"
x dead '^  the answer deleted: yes$'
x dead '^  \{"status":"UP"\} 200$'
x dead '^  \{"components":\{"kitchen":\{"details":\{"error":"JdbcSQLSyntaxErrorException"\},"status":"DOWN"\},"readinessState":\{"status":"UP"\}\},"status":"DOWN"\} 503$'
x dead '^  \{"details":\{"error":"JdbcSQLSyntaxErrorException"\},"status":"DOWN"\} 503$'
x dead '^  \{"error":"JdbcSQLSyntaxErrorException"\} 500$'
x dead '^  \{"ordersCooked":120,"ordersValue":24300\} 200$'
x dead '^  GET   /kitchen    -> 200 application/json  \{"ordersCooked":120,"ordersValue":24300\}$'
x dead '^  exit 0 · the seven responses: 7 lines · md5 '
DEADMD5=$(sed -n 's/^  exit 0 · the seven responses: 7 lines · md5 \([0-9a-f]*\)$/\1/p' .r-dead.out); [ -n "$DEADMD5" ] && [ "$DEADMD5" != "$S115" ] || die "dead: the seven with the database gone differ from 115c36ba..."
echo "  dead: a new database, 0 tables · health 503 (kitchen DOWN, the rest UP) · liveness 200 · readiness 503 (kitchen: JdbcSQLSyntaxErrorException) · /customers 500 · /kitchen 200"

# "A, the anchor: readiness five oh three, liveness two hundred ... B, readiness without the kitchen: two hundred ... A again: five oh
# three."
GA=$(blk groups 'A - after/ as it is' 'B - the README'); GB=$(blk groups "B - the README" "A' - A again"); GA2=$(blk groups "A' - A again" '')
for b in "$GA" "$GA2"; do has "$b" '  {"status":"UP"} 200' "groups A, A': liveness 200"; has "$b" '  {"status":"DOWN"} 503' "groups A, A': readiness 503"; has "$b" '  {"error":"JdbcSQLSyntaxErrorException"} 500' "groups A, A': /customers 500"; done
[ "$(printf '%s\n' "$GB" | grep -cxF '  {"status":"UP"} 200')" = 2 ] || die "groups B: liveness and readiness 200"
has "$GB" '  {"error":"JdbcSQLSyntaxErrorException"} 500' "groups B: /customers 500"
[ "$(printf '%s\n' "$GA" | grep '^\$ cd ')" = "$(printf '%s\n' "$GA2" | grep '^\$ cd ')" ] || die "groups: A' is not A's command"
[ "$(n groups "^  exit 0 · the seven responses: 7 lines · md5 $DEADMD5\$")" = 3 ] || die "groups: the seven as dead's, three times"
[ "$(n groups '^  harness: the same URL, connected again: a database with 0 tables$')" = 3 ] || die "groups: the database new and empty in all three"
echo "  groups: A readiness 503, liveness 200 · B readiness 200, liveness 200 · A' = A · /customers 500 in all three"

# "From a runner, it's lost: Boot publishes accepting traffic last, after the runners. Published after ready, readiness says five oh
# three, out of service. And on a stop signal, TiffinBox stopped without a word to readiness."
TR1=$(blk trap '1 - a runner publishes' '2 - after Boot'); TR2=$(blk trap '2 - after Boot' '')
has "$TR1" "  $H2 200" "trap 1: health 200"
[ "$(printf '%s\n' "$TR1" | grep '^    harness: ' | paste -sd'|' -)" = "    harness: LivenessState CORRECT - published on the thread main|    harness: a runner publishes REFUSING_TRAFFIC|    harness: ReadinessState REFUSING_TRAFFIC - published on the thread main|    harness: ReadinessState ACCEPTING_TRAFFIC - published on the thread main|    harness: the context closes - on the thread SpringApplicationShutdownHook" ] || die "trap 1: Boot's order"
has "$TR2" "  harness: ReadinessState REFUSING_TRAFFIC - published on the thread harness-refuse" "trap 2"
has "$TR2" '  {"groups":["liveness","readiness"],"status":"OUT_OF_SERVICE"} 503' "trap 2: health"
has "$TR2" '  {"status":"UP"} 200' "trap 2: liveness"
has "$TR2" '  {"status":"OUT_OF_SERVICE"} 503' "trap 2: readiness"
has "$TR2" "  exit 143 · listening on 19015 now: 0" "trap 2: SIGTERM"
has "$TR2" "  the witness's lines from the context's close on: 1 - the context closes - on the thread SpringApplicationShutdownHook · states published after it: 0" "trap 2: nothing published on close"
has "$TR2" "    39 jars read · 3 classes: ApplicationAvailability ReadinessState ReadinessStateHealthIndicator" "trap 2: the jar's classes"
echo "  trap: a runner's REFUSING overwritten (CORRECT, runner, REFUSING, ACCEPTING) · after ready: 503 OUT_OF_SERVICE · SIGTERM 143, no state on close · 3 classes name it"

# "The AOT jar and the native binary: readiness two hundred with the kitchen in it, kitchen UP, and the same seven responses."
x native '^  built \.harness/nat \(both modules, into \$M2\) · offline: yes · exit 0$'
x native '^  exit 0 · BUILD SUCCESS · stages it printed: 8 of the 8 it announces · its duration, against the bound: 1 minute or more, under 20 minutes · offline: yes$'
x native '^  file: Mach-O 64-bit executable · the demo token in its bytes: 0$'
[ "$(n native '^  Boot.s first line: Starting AOT-processed TiffinBoxServer')" = 2 ] || die "native: AOT-processed, twice"
[ "$(n native '^  \{"components":\{"kitchen":\{"status":"UP"\},"readinessState":\{"status":"UP"\}\},"status":"UP"\} 200$')" = 2 ] || die "native: readiness with the kitchen, twice"
[ "$(n native '^  \{"status":"UP"\} 200$')" = 2 ] || die "native: the kitchen's path, twice"
[ "$(n native "^  exit 0 · the seven responses: 7 lines · md5 $S115\$")" = 2 ] || die "native: the seven, twice"
echo "  native: 8 of 8, offline, 0 tokens in its bytes · the AOT jar and the binary: readiness with the kitchen UP, its path 200, 115c36ba..."

# the exercise's end state: the line exercise/README.md calls "Done" is a line of this capture, after the solution's line - and of
# SOLUTION.md's measured run
XE=$(blk exercise "the solution's line" '')
l='liveness {"status":"DOWN"} [503]'
has "$XE" "$l" "exercise"
awk '/^\*\*Done\*\*/ { f = 1 } f' exercise/README.md | grep -qxF -- "$l" || die "exercise/README.md: Done names no such line"
grep -qxF -- "$l" exercise/solution/SOLUTION.md || die "SOLUTION.md: the measured run shows no such line"
x exercise '^  exit 0 · printed: [0-9]+ line\(s\)$'
x exercise '^POST /shutdown -> 200 · curl exit 0$'
x exercise '^  exit 0 · listening on 19019 now: 0$'
echo "  exercise: the README as written, then the solution's line -> liveness DOWN, 503"

# the anchor's README states the same numbers
grep -qF '`{"customers":4,"ordersCooked":120}`' after/README.md || die "after/README.md: the kitchen's details"
grep -qF '`/kitchen` answered 200 at least once while liveness and readiness both answered 503' after/README.md || die "after/README.md: the race"
grep -qF "Health contributor 'readinessState'" after/README.md && grep -qF '`{"status":"OUT_OF_SERVICE"}` 503' after/README.md || die "after/README.md: the switch, the trap"
cmp -s after/README.md ../c5-tiffinbox/README.md || echo "  (after/README.md and ../c5-tiffinbox/README.md differ - the anchor is not this unit's after/ yet)" >&3
[ -z "$unpub" ] || die "no published hash for:$unpub - check the captures, then copy the md5s above into receipts.md5 and run again"
echo "c5-unit22: every capture 3/3 and = published; every spoken number asserted; 0 raw demo tokens in every capture"
