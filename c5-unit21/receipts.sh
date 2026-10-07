#!/bin/bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25.0.4.1 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# GRAALVM_HOME names a GraalVM JDK 25 (README.md, "The GraalVM"): the native build reads it. Without it, this script makes every
# capture that needs no GraalVM - the JVM's, and the exercise's - filling .m2-demo on the way, then stops before the native build.
# Course 5 · Actuator: Endpoints and What They Cost - this unit's receipts. Boot's Actuator added to TiffinBox reaches nothing:
# to Boot, TiffinBox's server (the JDK's own) is no web application, so Boot's HTTP side of Actuator never starts. The anchor
# change: in tiffinbox-web/pom.xml the starter, spring-boot-starter-actuator, and three excludes in Boot's plugin (the Compose
# module and its two Jackson 3 jars, kept out of Spring's AOT step as unit 20's native-plugin exclusions keep them out of the
# binary); ActuatorRoutes.java (new: Boot's own discoverer, Boot's health web extension, a handler); TiffinBoxServer.java (one
# constructor argument, one context: /actuator); application.yaml (the exposure list, written down: health). Eleven captures,
# each run three times and hashed; cap() DIES when a hash differs from receipts.md5; every number the video says is asserted at
# the bottom by a check that can fail; the demo token is masked (gsub), and the last checks count 0 raw copies of it in every
# capture, every file this unit ships, and the binary it built. A heap dump holds the token: it is written under .harness/ only,
# counted, and deleted in the same step - and again by the exit trap.
#   cost      the previous tree, and a copy with Actuator's starter: their jars (BOOT-INF/lib, bytes, imports files); each run
#             exploded with the harness's own listener joined (harness/inspect): Boot's kind of application, bean definitions,
#             auto-configurations registered, endpoint beans, the beans that hand endpoints to an adapter, Boot's MBeans; with
#             the starter, /actuator/health asked; the seven
#   why       that copy's jar with --debug: the condition report's blocks for Actuator's web endpoints, its JMX endpoints,
#             health's web extension and the heap dump endpoint, every gap counted
#   ways      the ways out. JMX: the same copy with spring.jmx.enabled, then every endpoint on JMX (configprops excluded) - the
#             MBeans, and over JMX the names in health's answer; the endpoint classes in the jars, by their annotation (javap).
#             Spring MVC on Tomcat: a copy with Spring MVC's starter too - its jars, two servers in one JVM (Tomcat on
#             127.0.0.1, told so), Tomcat's health and mappings, and the JVM still running after POST /shutdown, then a kill
#   change    the previous tree against after/: the files that differ, ActuatorRoutes.java counted and its key lines, what
#             TiffinBoxServer.java, application.yaml and the web POM gain
#   serve     after/ built the README's way and run as the README runs it: readiness, health, liveness, env (not exposed), a
#             POST to health, the addresses it listens on, the seven
#   aot       Spring's AOT step: B, after/ without Boot's plugin's excludes - its generated code and metadata, its jar run the
#             plain way (the seven), then with the generated code (it stops); A, after/ - the same, and it serves; A's jar with
#             the README's flag that exposes env: the plain way, then with the generated code
#   exposure  the break, the exposure list: A the anchor's list · B a star (every endpoint) · A' = A · C (labelled) a star,
#             configprops excluded - every endpoint id the jars declare, asked once
#   tour      one run with C's flags: what beans, conditions, env, mappings, metrics and threaddump hand over (counted, never a
#             value or a name of this Mac's); env's masking, switched by show-values for one run each; the heap dump, switched
#             on for one run - its floor and the token copies in it, counted two ways
#   start     the start, timed from outside (harness/ttfr.py): the previous tree's jar, the copy with the starter, after/'s jar -
#             six rounds, round 1 a warm-up: the reference against a floor, the other two as ratios of it; never the seconds
#   native    after/ built natively (the README's two Maven lines) and its binary run: readiness, health, the seven; the
#             README's flag on the binary
#   exercise  exercise/README.md's commands and exercise/solution/SOLUTION.md's, read from the files and run as written
# "before" is ../c5-unit20/after (the anchor as the hints lesson left it), COPIED under .harness/; this script never writes into
# another unit's folder. after/ is this unit's frozen copy of ../c5-tiffinbox after the change; it is copied, never built in
# place. Every run of TiffinBox starts in a folder under .harness/ that holds a config tree with the demo token (secrets/), as the
# README asks. Commands are printed exactly as they run: each goes through eval. "$CURLSET" is the comparison set since the secrets
# lesson (../c5-unit11/curlset.sh: the seven requests, POST /shutdown with the token's header read from the file). "$M2" is this
# unit's own repository, .m2-demo. "$pid" is the process the script started.
# The network: every build runs offline (-o) against .m2-demo and says so ("offline: yes"); a build that cannot resolve an
# artifact offline goes to Maven Central once, and says that ("offline: no - ..."). GraalVM's native plugin, under the profile
# native, reads its metadata repository (a zip) from .m2-demo - and when the zip is not there it downloads it from GitHub, even
# under -o (README.md, The repository): so a native-profile build without the zip goes to Maven Central for it at once, never
# offline first, and every build's log is searched for the plugin's own download line - found, the run stops. At run time nothing
# leaves 127.0.0.1: TiffinBox listens there, and the one Tomcat this script starts is told to (--server.address=127.0.0.1).
# Masks and filters (README.md declares each; sub/gsub only): the demo token becomes "[masked: the 26-character token]"; the
# GraalVM's folder "$GRAALVM_HOME"; this folder's absolute path "…", the folder above it "…/..", the home folder "~"; your user
# name "<user>" - in every line of every capture. A Boot log line is printed from its message on, its first line cut before
# " with PID". Logs and Actuator's answers are read, never printed whole: what a capture shows is named, and the rest counted.
# Never printed: an environment variable's or a system property's name, a value from env, health's details, a disk size, a
# thread's stack, a meter's value, the heap dump. No duration is captured: each is judged against a bound; seconds go to the
# terminal.
# Ports (brief ⚑10, 19000-19009): cost 19000 (the previous tree), 19001 (with the starter) · why 19001 · ways 19002 (JMX),
# 19003 (the Tomcat copy's TiffinBox), 19004 (its Tomcat) · serve 19005 · aot 19006 · exposure 19005 · tour 19007 · start 19008 ·
# native 19006 · exercise 19009. 18425 (TiffinBox's default) and 8080 (Tomcat's) are checked free too.
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
# its process group - a TiffinBox JVM (a jar, an extracted class path), a binary, native-image's driver or builder, the clock -
# is stopped. Then the heap dump and the env answer printed with show-values=always, if a run left them: both hold the token. After
# an interrupt, a capture's unfinished runs (.r-NAME.1-3) go too; after a failed check they stay, for the diff the message names.
# The clean-up ignores a second Ctrl-C, and nothing in it can fail under set -e, so it always reaches the rmdir; the script still
# exits 130 after an interrupt (tested: README.md, "Interrupted"). $pid is cleared whenever the process has been reaped.
pid=""
sweep() { local g i l
  g=$(ps -o pgid= -p $$ 2> /dev/null | tr -d ' ') || g=""
  [ -n "$g" ] || return 0
  i=0; while [ $i -lt 20 ]; do
    l=$(ps -axo pid=,pgid=,command= 2> /dev/null | awk -v g="$g" -v me=$$ -v gh="${GRAALVM_HOME:-/nonexistent}" '
      $2 == g && $1 != me && $3 != "awk" && $3 != "ps" && (index($0, "vminvocation.args") || index($3, gh "/bin/native-image") || $3 ~ /tiffinbox-web\/target\/tiffinbox-web$/ || index($0, "tiffinbox-web-1.0.0.jar") || index($0, "com.tiffinbox.web.TiffinBoxServer") || index($0, "harness/ttfr.py")) { print $1 }' | paste -sd' ' -) || l=""
    [ -n "$l" ] || return 0
    if [ $i -lt 10 ]; then kill $l 2> /dev/null || true; else kill -9 $l 2> /dev/null || true; fi
    sleep 0.5; i=$((i + 1)); done; }
secretfiles() { rm -f .harness/*/heap.hprof .harness/*/env-entry.json .harness/mine/run/heap.hprof 2> /dev/null || true; }
trap 'trap "" INT TERM; if [ -n "$pid" ] && kill "$pid" 2> /dev/null; then wait "$pid" 2> /dev/null || true; fi; sweep || true; secretfiles; [ -z "$INTR" ] || rm -f .r-*.[123]; rmdir .r-lock 2> /dev/null || true' EXIT
INTR=""; trap 'INTR=1; exit 130' INT TERM
exec 3>&1                                            # die() speaks to the terminal even inside a redirected capture
die() { echo "  *** $* ***" >&3; exit 1; }
java -version 2>&1 | grep -q 'version "25' || die "JDK 25 needed; JAVA_HOME gives: $(java -version 2>&1 | head -1)"
command -v python3 > /dev/null || die "python3 is needed: harness/ttfr.py is the clock, and Actuator's answers are JSON"
command -v curl > /dev/null || die "curl is needed: every request here is curl's"
# A variable of yours must not become a property source, a JVM flag, a build setting or a native-image option: every
# TIFFINBOX_*, SPRING_*, MANAGEMENT_*, SERVER_* and LOGGING_* variable, DEBUG (Boot reads it as --debug), the variables that inject
# JVM flags, MAVEN_OPTS, MAVEN_ARGS and NATIVE_IMAGE_OPTIONS are removed first. GRAALVM_HOME stays: it says which GraalVM to use.
for v in $(env | sed -n 's/^\(TIFFINBOX_[A-Za-z0-9_]*\|SPRING_[A-Za-z0-9_]*\|MANAGEMENT_[A-Za-z0-9_]*\|SERVER_[A-Za-z0-9_]*\|LOGGING_[A-Za-z0-9_]*\|DEBUG\|JAVA_TOOL_OPTIONS\|JDK_JAVA_OPTIONS\|_JAVA_OPTIONS\|MAVEN_OPTS\|MAVEN_ARGS\|NATIVE_IMAGE_OPTIONS\)=.*/\1/p'); do unset "$v"; done
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
PREV=../c5-unit20/after                              # the previous tree: read, copied, never built in place
JAR=tiffinbox-web/target/tiffinbox-web-1.0.0.jar
BIN=tiffinbox-web/target/tiffinbox-web               # the binary native:compile-no-fork writes, in a tree's web module
TF=secrets/tiffinbox/shutdown-token                  # the config tree's file for tiffinbox.shutdown-token
META=tiffinbox-web/target/spring-aot/main/resources/META-INF/native-image/com.tiffinbox/tiffinbox-web/reachability-metadata.json
SRV=tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java
ROUTES=tiffinbox-web/src/main/java/com/tiffinbox/web/ActuatorRoutes.java
APP=tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxApp.java
# The two dependencies a copy gains, each on one line (the starter alone: cost; the starter and Spring MVC's: ways)
STARTER='    <dependency><groupId>org.springframework.boot</groupId><artifactId>spring-boot-starter-actuator</artifactId></dependency>'
MVC='    <dependency><groupId>org.springframework.boot</groupId><artifactId>spring-boot-starter-webmvc</artifactId></dependency>'
# The demo token. FAKE, and meant to look it: it guards nothing but a demo server on 127.0.0.1 that every capture stops. It is
# written into .harness/*/secrets/ (git-ignored) when this script runs, and no capture prints it: see mask().
TOKEN=not-a-real-token-demo-only
[ ${#TOKEN} = 26 ] || die "the demo token must be 26 characters"
CURLSET=../c5-unit11/curlset.sh                      # the comparison set: the seven requests, POST /shutdown with the header
[ -f "$CURLSET" ] || die "$CURLSET is missing"
[ -f "$PREV/pom.xml" ] && [ -f after/pom.xml ] && [ -f after/README.md ] || die "the previous tree $PREV or after/ is missing"
[ -f harness/ttfr.py ] && [ -x harness/shutdown.sh ] && [ -f harness/inspect/harness/Inspect.java ] || die "harness/ is missing a file"

# The ports, BEFORE anything is wiped (a survivor of an interrupted run answers POST /shutdown only with its token, which lives
# in .harness/ - so the message names the process to kill).
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
for p in 18425 8080 19000 19001 19002 19003 19004 19005 19006 19007 19008 19009; do
  [ "$(listeners $p)" = 0 ] || die "something already listens on $p - this unit's ports must be free; if it is a TiffinBox an interrupted run left behind, stop it: kill $(lsof -nP -iTCP:$p -sTCP:LISTEN -t 2> /dev/null | paste -sd' ' -)"; done

# ---- the commands: read from after/README.md, the anchor's own, and asserted - each line must be there, whole -------------
readme() { grep -m1 -xF -- "$1" after/README.md > /dev/null || die "after/README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
R_PLAIN=$(readme 'mvn -B package')
R_RUN=$(readme 'java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431')
R_EXTRACT=$(readme 'java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted')
R_CP=$(readme 'java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431')
R_PKG=$(readme 'mvn -B -Pnative package')
R_AOTRUN=$(readme 'java -Dspring.aot.enabled=true -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431')
R_GRAAL=$(readme 'export GRAALVM_HOME=/path/to/a/graalvm-jdk-25')
R_INSTALL=$(readme 'mvn -B -Pnative install')
R_NATIVE=$(readme 'mvn -B -Pnative -pl tiffinbox-web native:compile-no-fork')
R_BIN=$(readme 'tiffinbox-web/target/tiffinbox-web --tiffinbox.port=18431')
R_HEALTH=$(readme "curl -s -w ' %{http_code}\n' http://127.0.0.1:18431/actuator/health")
R_LIVE=$(readme "curl -s -w ' %{http_code}\n' http://127.0.0.1:18431/actuator/health/liveness")
R_READY=$(readme "curl -s -w ' %{http_code}\n' http://127.0.0.1:18431/actuator/health/readiness")
R_ENV=$(readme "curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:18431/actuator/env")
R_ENVRUN=$(readme 'java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --management.endpoints.web.exposure.include=health,env')
R_ENVTOK=$(readme "curl -s -w ' %{http_code}\n' http://127.0.0.1:18431/actuator/env/tiffinbox.shutdown-token")
R_STAR=$(readme "java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --management.endpoints.web.exposure.include='*'")
R_STARX=$(readme "java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --management.endpoints.web.exposure.include='*' --management.endpoints.web.exposure.exclude=configprops")
R_HEAPRUN=$(readme 'java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --management.endpoints.web.exposure.include=health,heapdump --management.endpoint.heapdump.access=read-only')
R_HEAP=$(readme "curl -s -o heap.hprof -w '%{http_code}\n' http://127.0.0.1:18431/actuator/heapdump")
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
C_AFTER=$(off .harness/after "$R_INSTALL" install)
for c in "$C_AFTER" "$(off .harness/x "$R_PLAIN" package)" "$(off .harness/x "$R_PKG" package)" "$(off .harness/x "$R_NATIVE")"; do
  r=$(dev "$c"); [ "$r" = "$R_PLAIN" ] || [ "$r" = "$R_PKG" ] || [ "$r" = "$R_INSTALL" ] || [ "$r" = "$R_NATIVE" ] || die "not a README line with the offline changes: $c"; done
[ "$(at .harness/x 19006 "$R_BIN")" = "cd .harness/x && tiffinbox-web/target/tiffinbox-web --tiffinbox.port=19006" ] || die "the binary's run line"
[ "$(url "$R_HEALTH" 19005)" = "curl -s -w ' %{http_code}\n' http://127.0.0.1:19005/actuator/health" ] || die "the health line, its port"
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
  case $c in *' -Pnative '*) [ -f "$ZIP" ] || { c=${c/mvn -o -B /mvn -B }; how="no - GraalVM's metadata repository was not in .m2-demo, so Maven Central was asked for it"; } ;; esac
  (eval "$c") > "$2" 2>&1 < /dev/null || ec=$?
  if [ $ec != 0 ] && [ "$how" = yes ] && grep -qE 'offline mode|Could not resolve|could not be resolved|Cannot access' "$2"; then
    how="no - the offline build could not resolve an artifact, so Maven Central was asked"; ec=0
    (eval "${c/mvn -o -B /mvn -B }") > "$2" 2>&1 < /dev/null || ec=$?; fi
  if ghub "$2"; then echo "  built $3 · offline: no - GraalVM's native plugin went to GitHub for its metadata repository · exit $ec"
    die "$3: GraalVM's native plugin went over the network for its metadata repository - $(grep -m1 -E 'Downloaded GraalVM reachability metadata repository from http|Failed to download from http' "$2" | sed 's/^\[[A-Z]*\] //') - README.md, The repository"; fi
  [ $ec = 0 ] || { tail -30 "$2" >&3
    ! grep -qE 'Could not resolve|could not be resolved|Could not transfer|Cannot access' "$2" || die "build failed: $3 - Maven could resolve Boot's parent and plugins neither from .m2-demo nor from Maven Central: a fresh clone's first run needs the network once, to fill .m2-demo"
    die "build failed: $3"; }
  echo "  built $3 · offline: $how · exit $ec"; }
# tree FOLDER: a config tree in FOLDER/secrets holding one file, the token and a newline, readable by its owner alone
tree() { mkdir -p "$1/secrets/tiffinbox"; (umask 077 && printf '%s\n' "$TOKEN" > "$1/$TF"); chmod 700 "$1/secrets" "$1/secrets/tiffinbox"; }
# The first build is the README's native install: it needs nearly every artifact the captures' Maven lines need - the plain ones, the
# profile native's (process-aot, the plugin's add-reachability-metadata and its metadata repository) and install's - so on a
# fresh clone, whose .m2-demo is empty (git ignores it), this one build fills .m2-demo from Maven Central, once - Actuator's
# jars among them. Its extracted jar is the class path the harness compiles against.
mbuild "$C_AFTER" .harness/build-after.log ".harness/after (after/, the profile native, both modules into \$M2)"
[ -f "$M2/org/springframework/boot/spring-boot-starter-parent/4.1.1/spring-boot-starter-parent-4.1.1.pom" ] || die "Boot's parent POM is not in .m2-demo after the first build"
[ -f "$M2/org/graalvm/buildtools/native-maven-plugin/1.1.8/native-maven-plugin-1.1.8.jar" ] || die "GraalVM's native plugin 1.1.8 is not in .m2-demo after the first build (it is a build extension of the web module)"
[ -f "$ZIP" ] || die "GraalVM's metadata repository is not in .m2-demo after the first build - README.md, The repository"
[ -f "$M2/org/springframework/boot/spring-boot-actuator/4.1.1/spring-boot-actuator-4.1.1.jar" ] || die "Actuator 4.1.1 is not in .m2-demo after the first build"
echo "  .m2-demo holds Boot's parent, Actuator 4.1.1, GraalVM's native plugin 1.1.8 and its metadata repository ($(wc -c < "$ZIP" | tr -d ' ') bytes)"
# One more build before the captures, for what only capture ways builds: Spring MVC's starter - Tomcat, Spring's web jars, Jackson 3.
# On a fresh clone the first build does not fetch them, and a build inside a capture must say "offline: yes".
rsync -a --exclude target --exclude secrets "$PREV/" .harness/fill/
perl -0pi -e "s|\n  </dependencies>|\n$STARTER\n$MVC\n  </dependencies>|" .harness/fill/tiffinbox-web/pom.xml
grep -q '<artifactId>spring-boot-starter-webmvc</artifactId>' .harness/fill/tiffinbox-web/pom.xml || die "the fill build's POM did not get Spring MVC's starter"
mbuild "$(off .harness/fill "$R_PLAIN" package)" .harness/build-fill.log ".harness/fill (the previous tree with Actuator's and Spring MVC's starters, as capture ways builds it)"
tree .harness/after
(cd .harness/after && eval "$R_EXTRACT") > .harness/extract-after.log 2>&1 || { cat .harness/extract-after.log >&3; die "the README's extract command failed in .harness/after"; }
# The harness's listener (harness/inspect/harness/Inspect.java), compiled once into .harness/hc against after/'s own class path;
# every exploded run that joins it puts .harness/hc on its class path (../hc, from beside its config tree)
mkdir -p .harness/hc
javac -d .harness/hc -cp ".harness/after/tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:.harness/after/tiffinbox-web/target/extracted/lib/*" harness/inspect/harness/Inspect.java > .harness/javac.log 2>&1 || { cat .harness/javac.log >&3; die "the harness did not compile"; }
echo "  the harness's listener compiled into .harness/hc"

# ---- helpers ------------------------------------------------------------------------------------------------------------
# raw TOKEN FILE...: how many times TOKEN appears, raw, in the files (occurrences, not lines; binary files read as text)
raw() { local t=$1; shift; cat "$@" | LC_ALL=C grep -aoF -- "$t" | wc -l | tr -d ' '; }
warns() { echo "WARN lines $(grep -c ' WARN ' "$1" || true) · ERROR lines $(grep -c ' ERROR ' "$1" || true)"; }
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
# ask 'README curl LINE' PORT: the README's curl line, its port made PORT, printed and run; what it printed, indented
ask() { local c; c=$(url "$1" "$2"); echo "\$ $c"; (eval "$c") 2>&1 < /dev/null | sed 's/^/  /'; }
# ready PORT: readiness asked until it answers 200 - every 0.25 s, up to 60 s, not printed (the race is the next lesson's) -
# then the README's readiness line, printed and run once. No health, env or other assertion before it (brief S4.15).
ready() { local i=0 c=""
  while [ $i -lt 240 ]; do c=$(curl -s -o /dev/null -w '%{http_code}' "http://127.0.0.1:$1/actuator/health/readiness" 2> /dev/null || true); [ "$c" = 200 ] && break
    kill -0 "$pid" 2> /dev/null || { tail -20 .harness/run.out >&3; die "it exited before readiness answered 200"; }; sleep 0.25; i=$((i + 1)); done
  [ "$c" = 200 ] || die "readiness never answered 200 on $1"
  ask "$R_READY" "$1"; }
# held: the harness's last line printed - up to 40 s - then every line it printed, indented
held() { local i=0
  while [ $i -lt 160 ] && ! grep -q '^harness: done$' .harness/run.out; do kill -0 "$pid" 2> /dev/null || break; sleep 0.25; i=$((i + 1)); done
  grep -q '^harness: done$' .harness/run.out || { tail -20 .harness/run.out >&3; die "the harness never printed its last line"; }
  grep '^harness: ' .harness/run.out | grep -v '^harness: done$' | sed 's/^/  /'; }
# booted: Boot's own line that the context is refreshed and the application started - up to 40 s
booted() { local i=0
  while [ $i -lt 160 ] && ! grep -q ' : Started TiffinBoxServer in ' .harness/run.out; do kill -0 "$pid" 2> /dev/null || break; sleep 0.25; i=$((i + 1)); done
  grep -q ' : Started TiffinBoxServer in ' .harness/run.out || { tail -20 .harness/run.out >&3; die "Boot never said it started"; }; }
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
# causes LOG: the exception Boot's "Application run failed" line names, then each 'Caused by: ' line, in order - each cut after the
# bean or the factory method it names - and before each, how many lines of the log are not shown: the whole chain, every gap
# counted (Course 4's rule)
causes() { awk -v q="'" '
  function show(l) {
    if (match(l, "Error creating bean with name " q "[^" q "]*" q)) l = substr(l, 1, RSTART + RLENGTH - 1) " …"
    else if (match(l, "Factory method " q "[^" q "]*" q " threw exception")) l = substr(l, 1, RSTART + RLENGTH - 1) " …"
    if (p) printf "    … %d line%s not shown …\n", NR - p - 1, (NR - p - 1 == 1) ? "" : "s"
    print "    " l; p = NR }
  / : Application run failed$/ { f = 1; next }
  f && !e && NF { e = 1; show($0); next }
  e && /^Caused by: / { show($0) }' "$1"; }
# fails PORT: after a start that stops - TiffinBox's own line if its server opened first, then how it ended: the exception and
# every cause, Boot's failure analysis (its banner, counted), the stack frames counted, the exit code. Never inside $(...).
fails() { local e=0
  wait "$pid" || e=$?; pid=""
  echo "  TiffinBox's own line, before it stopped: $(grep -m1 -oE 'TiffinBox listening on http://[0-9.:]+' .harness/run.out || echo '(none)')"
  echo "  then: $(grep -m1 -oE 'Application run failed$' .harness/run.out || echo '(no failure line)') - the exception, then each cause, each cut after the bean or the method it names; the lines between, counted:"
  causes .harness/run.out
  echo "  Boot's failure analysis (its banner, APPLICATION FAILED TO START): $(grep -c '^APPLICATION FAILED TO START$' .harness/run.out || true) · stack frames (lines starting 'at '): $(grep -cE '^[[:space:]]+at ' .harness/run.out || true)"
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
# pbuild DIR 'LABEL' ['README mvn LINE']: the README's Maven line (the plain build unless named), offline, from DIR
pbuild() { local c; c=$(off "$1" "${3:-$R_PLAIN}" package); echo "\$ $c"; mbuild "$c" "$1.build.log" "$2"; }
# ins 'LINE' FILE: the perl that puts LINE, whole, before the line '  </dependencies>' of FILE, printed as run; one line added
ins() { local c b a
  c="perl -0pi -e 's|\\n  </dependencies>|\\n$1\\n  </dependencies>|' $2"
  b=$(wc -l < "$2"); echo "\$ $c"; eval "$c"; a=$(wc -l < "$2"); echo "  lines added: $((a - b))"; }
# libs DIR: the names under BOOT-INF/lib/ of DIR's executable jar, one per line, sorted
libs() { unzip -Z1 "$1/$JAR" | sed -n 's|^BOOT-INF/lib/\(.*\.jar\)$|\1|p' | LC_ALL=C sort; }
# imports DIR: how many jars of DIR's extracted lib/ hold an auto-configuration imports file, and how many candidates those files
# list (lines that are neither blank nor a comment)
imports() { local n=0 l=0 j k
  for j in "$1"/tiffinbox-web/target/extracted/lib/*.jar; do
    k=$(unzip -p "$j" META-INF/spring/org.springframework.boot.autoconfigure.AutoConfiguration.imports 2> /dev/null | grep -cvE '^[[:space:]]*(#|$)' || true)
    [ "${k:-0}" -gt 0 ] && { n=$((n + 1)); l=$((l + k)); }; done
  echo "$n jars, $l candidates"; }
# hcp DIR PORT ['FLAGS']: the README's exploded run - the extracted jar on the class path, TiffinBox's own main - from DIR, its
# port made PORT, the harness's classes added to the class path (../hc) and the harness joined, then FLAGS
hcp() { local c; c=$(at "$1" "$2" "$R_CP"); c=${c/lib\/\*\"/lib\/*:..\/hc\"}; printf '%s --spring.main.sources=harness.Inspect%s\n' "$c" "${3:+ $3}"; }

# ---- cost: the starter, counted --------------------------------------------------------------------------------------------
cost() { local b1 b2 d
  echo "the previous tree - the anchor as the hints lesson left it - and a copy of it with one dependency more, Actuator's starter;"
  echo "each built the README's plain way, offline:"
  copy "$PREV" .harness/cost-prev; copy "$PREV" .harness/cost-a1
  pbuild .harness/cost-prev "the previous tree"
  ins "$STARTER" .harness/cost-a1/tiffinbox-web/pom.xml
  pbuild .harness/cost-a1 "the previous tree plus the starter"
  libs .harness/cost-prev > .harness/cost-prev.lib; libs .harness/cost-a1 > .harness/cost-a1.lib
  b1=$(wc -c < .harness/cost-prev/$JAR | tr -d ' '); b2=$(wc -c < .harness/cost-a1/$JAR | tr -d ' ')
  echo "the two executable jars:"
  echo "  jars under BOOT-INF/lib: $(wc -l < .harness/cost-prev.lib | tr -d ' ') and $(wc -l < .harness/cost-a1.lib | tr -d ' ') · only in the first: $(LC_ALL=C comm -23 .harness/cost-prev.lib .harness/cost-a1.lib | wc -l | tr -d ' ') · only in the second: $(LC_ALL=C comm -13 .harness/cost-prev.lib .harness/cost-a1.lib | wc -l | tr -d ' ') -"
  LC_ALL=C comm -13 .harness/cost-prev.lib .harness/cost-a1.lib | paste -sd' ' - | sed 's/^/    /'
  echo "  bytes: $b1 and $b2 · added: $((b2 - b1))"
  for d in prev a1; do (cd .harness/cost-$d && eval "$R_EXTRACT") > .harness/cost-$d.extract.log 2>&1 || die "the README's extract failed in .harness/cost-$d"; done
  echo "  each extracted (the README's extract): the jars that hold an auto-configuration imports file, and the candidates they list - $(imports .harness/cost-prev) · $(imports .harness/cost-a1)"
  echo "each run exploded, as the README runs the extracted jar - TiffinBox's own main - with the harness's own listener joined"
  echo "(--spring.main.sources=harness.Inspect: harness/inspect/harness/Inspect.java, not TiffinBox's). The previous tree, port 19000:"
  start "$(hcp .harness/cost-prev 19000)"; held
  seven 19000 .harness/cost-prev
  echo "with the starter, port 19001:"
  start "$(hcp .harness/cost-a1 19001)"; held
  echo "  every address this process listens on (lsof): $(listening)"
  ask "$R_HEALTH" 19001
  seven 19001 .harness/cost-a1; }

# ---- why: the condition report ----------------------------------------------------------------------------------------------
# report LOG 'NAMES': the condition report's header, then the blocks whose class is one of NAMES, each whole, in the report's order -
# and before each, and after the last, how many of the report's lines are not shown
report() { awk -v want=" $2 " '
  /^CONDITIONS EVALUATION REPORT$/ { r = NR; p = NR; print "    " $0; next }
  !r { next }
  /^[0-9][0-9][0-9][0-9]-/ && NR > r + 5 { if (!end) end = NR; next }
  end { next }
  /^   [A-Za-z][A-Za-z0-9]*:$/ { n = substr($0, 4, length($0) - 4); b = index(want, " " n " ") ? 1 : 0 }
  /^   [A-Za-z]/ && !/^   [A-Za-z][A-Za-z0-9]*:$/ { b = 0 }
  /^$/ { b = 0 }
  b { if (NR > p + 1) printf "    … %d line%s not shown …\n", NR - p - 1, (NR - p - 1 == 1) ? "" : "s"; print "    " $0; p = NR }
  END { if (!end) end = NR + 1; if (end - 1 > p) printf "    … %d line%s not shown …\n", end - 1 - p, (end - 1 - p == 1) ? "" : "s" }' "$1"; }
why() {
  echo "the copy with the starter (built by capture cost), its jar run as the README runs it, with --debug - Boot's condition report,"
  echo "port 19001. Its blocks for Actuator's web endpoints, its JMX endpoints, health's web extension and the heap dump endpoint, each"
  echo "whole, in the report's order; the rest of the report, counted:"
  start "$(at .harness/cost-a1 19001 "$R_RUN") --debug"; up; booted
  seven 19001 .harness/cost-a1
  report .harness/run.out "WebEndpointAutoConfiguration JmxEndpointAutoConfiguration HealthEndpointWebExtensionConfiguration HeapDumpWebEndpointAutoConfiguration"
  echo "  the report's sections: $(grep -cE '^(Positive matches|Negative matches|Exclusions|Unconditional classes):$' .harness/run.out || true) - $(grep -E '^(Positive matches|Negative matches|Exclusions|Unconditional classes):$' .harness/run.out | sed 's/:$//' | paste -sd',' - | sed 's/,/, /g')"; }

# ---- ways: JMX, Tomcat ---------------------------------------------------------------------------------------------------------
# eps DIR: every class in DIR's extracted Boot jars that an endpoint annotation names, read by javap -v - each one's id, and
# those marked web-only (@WebEndpoint); the ids go to .harness/ids.txt (capture exposure asks each one)
eps() { local l=$1/tiffinbox-web/target/extracted/lib j c
  : > .harness/eps.cand
  for j in "$l"/spring-boot-*.jar; do for c in $(unzip -Z1 "$j" | grep '\.class$' | grep -v '\$'); do
    unzip -p "$j" "$c" | LC_ALL=C grep -aqE 'Lorg/springframework/boot/actuate/endpoint/(annotation/Endpoint|web/annotation/WebEndpoint);' && printf '%s\n' "${c%.class}" | tr / . >> .harness/eps.cand || true; done; done
  javap -v -cp "$l/*" $(cat .harness/eps.cand) 2> /dev/null | awk '
    /^(public |final |abstract )*(class|interface|enum) / { s = $0; sub(/ extends .*$/, "", s); sub(/ implements .*$/, "", s); n = split(s, w, " "); k = w[n]; sub(/.*\./, "", k); c = k; next }
    /^RuntimeVisibleAnnotations:$/ { a = 1; next }
    a && /^[A-Za-z]/ { a = 0 }
    a && /^    org\.springframework\.boot\.actuate\.endpoint\.(annotation\.Endpoint|web\.annotation\.WebEndpoint)\($/ { t = ($0 ~ /WebEndpoint/) ? "@WebEndpoint" : "@Endpoint"; f = 1; args = ""; next }
    f && /^    \)$/ { print c, t, args; f = 0; next }
    f { x = $0; sub(/^ */, "", x); sub(/^defaultAccess=Lorg\/springframework\/boot\/actuate\/endpoint\/Access;\./, "defaultAccess=", x); args = args (args == "" ? "" : ", ") x }' | LC_ALL=C sort -t'"' -k2 > .harness/eps.txt
  sed -n 's/.*id="\([a-z]*\)".*/\1/p' .harness/eps.txt > .harness/ids.txt
  echo "  endpoint classes in the jars, by their annotation (javap -v): $(wc -l < .harness/ids.txt | tr -d ' ') - ids: $(paste -sd' ' .harness/ids.txt)"
  echo "  of them web-only (@WebEndpoint), each class and its annotation:"
  grep ' @WebEndpoint ' .harness/eps.txt | sed 's/^\([^ ]*\) @WebEndpoint \(.*\)$/    \1 · @WebEndpoint(\2)/'
  echo "  the ones whose annotation sets defaultAccess=NONE - off unless switched on: $(grep 'defaultAccess=NONE' .harness/eps.txt | sed -n 's/.*id="\([a-z]*\)".*/\1/p' | paste -sd' ' -)"; }
# survivor TOMCAT-LESS-PORT TOMCAT-PORT DIR: the seven against TiffinBox's own server (POST /shutdown included), then - 2 s
# later - whether the process still runs, and what it listens on; then kill (SIGTERM), its exit code and the ports
survivor() { local e=0
  echo "\$ \$CURLSET $1 $3/$TF"
  "$CURLSET" "$1" "$3/$TF" | grep ' -> ' > .harness/responses.txt || true
  grep '^POST ' .harness/responses.txt | sed 's/^/  /' || echo "  (no POST line)"
  sleep 2
  echo "  2 s after POST /shutdown - still running: $(kill -0 "$pid" 2> /dev/null && echo yes || echo no) · listening on: $(lsof -nP -a -p "$pid" -iTCP -sTCP:LISTEN 2> /dev/null | awk 'NR > 1 { print $9 }' | sort -u | paste -sd' ' -)"
  echo "\$ kill \$pid"
  kill "$pid" 2> /dev/null || true; wait "$pid" || e=$?; pid=""
  echo "  exit $e · listening on $1 and $2 now: $(listeners "$1") and $(listeners "$2") · the seven responses: $(wc -l < .harness/responses.txt | tr -d ' ') lines · md5 $(md5 -q .harness/responses.txt)"; }
ways() {
  echo "way 1, JMX - the copy with the starter (capture cost), run exploded with the harness joined, as cost runs it, port 19002:"
  start "$(hcp .harness/cost-a1 19002 '--spring.jmx.enabled=true')"; held
  seven 19002 .harness/cost-a1
  echo "every endpoint on JMX, configprops excluded (the exposure lesson below says why):"
  start "$(hcp .harness/cost-a1 19002 "--spring.jmx.enabled=true --management.endpoints.jmx.exposure.include='*' --management.endpoints.jmx.exposure.exclude=configprops")"; held
  seven 19002 .harness/cost-a1
  eps .harness/cost-a1
  echo "way 2, Spring MVC on Tomcat - a copy of the previous tree with Actuator's starter and Spring MVC's, built offline:"
  copy "$PREV" .harness/ways-mvc
  ins "$STARTER" .harness/ways-mvc/tiffinbox-web/pom.xml; ins "$MVC" .harness/ways-mvc/tiffinbox-web/pom.xml
  pbuild .harness/ways-mvc "the copy with Spring MVC"
  libs .harness/ways-mvc > .harness/ways-mvc.lib
  echo "  jars under BOOT-INF/lib: $(wc -l < .harness/ways-mvc.lib | tr -d ' ') - against the starter alone's $(wc -l < .harness/cost-a1.lib | tr -d ' '): $(LC_ALL=C comm -13 .harness/cost-a1.lib .harness/ways-mvc.lib | wc -l | tr -d ' ') more -"
  LC_ALL=C comm -13 .harness/cost-a1.lib .harness/ways-mvc.lib | paste -sd' ' - | sed 's/^/    /'
  echo "its jar, run as the README runs it - TiffinBox on 19003 - with Tomcat told its port, 19004, and its address, 127.0.0.1; health and"
  echo "mappings exposed on it:"
  start "$(at .harness/ways-mvc 19003 "$R_RUN") --server.port=19004 --server.address=127.0.0.1 --management.endpoints.web.exposure.include=health,mappings"
  echo "  every address this process listens on (lsof): $(listening 2)"
  echo "  Tomcat's own line: $(grep -m1 -oE 'Tomcat started on port [0-9]+ \(http\) with context path .*$' .harness/run.out || echo '(none)')"
  ready 19004
  ask "$R_HEALTH" 19004
  echo "\$ curl -s -o .harness/ways-mappings.json http://127.0.0.1:19004/actuator/mappings"
  curl -s -o .harness/ways-mappings.json http://127.0.0.1:19004/actuator/mappings
  python3 - .harness/ways-mappings.json <<'PY'
import json, sys
d = json.load(open(sys.argv[1])); s = json.dumps(d)
m = d["contexts"]["application"]["mappings"]
print("  its answer: the kinds of mapping it lists - %s · mentions of TiffinBox's five paths (/customers /revenue /dashboard /kitchen /shutdown): %d"
      % (" ".join(sorted(m)), sum(s.count('"' + p) + s.count("'" + p) for p in ("/customers", "/revenue", "/dashboard", "/kitchen", "/shutdown"))))
PY
  survivor 19003 19004 .harness/ways-mvc; }

# ---- change: the previous tree against after/ ---------------------------------------------------------------------------
# gained FILE: the lines diff adds to FILE (after/ against the previous tree) that are neither comment nor blank; and what it
# removes, counted
gained() { diff ".harness/before/$1" ".harness/after/$1" > .harness/file.diff || true
  echo "  $1 - the lines it gains that are neither comment nor blank:"
  sed -n 's/^> //p' .harness/file.diff | awk '{ t = $0; sub(/^[ \t]+/, "", t) } c || t ~ /^<!--/ { c = (t ~ /-->[ \t]*$/) ? 0 : 1; next } t == "" || t ~ /^(\/\*\*|\*|\/\/|#)/ { next } { print "    " $0 }'
  echo "    (diff adds $(grep -c '^> ' .harness/file.diff || true) lines, removes $(grep -c '^< ' .harness/file.diff || true)$(grep '^< ' .harness/file.diff | sed 's/^< *//' | sed 's/^/ - /' | head -1))"; }
change() { local f n
  echo "the previous tree against after/, both copied under .harness/ - the files that differ:"
  echo "\$ diff -rq -x target -x secrets .harness/before .harness/after"
  diff -rq -x target -x secrets .harness/before .harness/after | sed 's/^/  /' || true
  f=.harness/after/$ROUTES; n=$(wc -l < "$f" | tr -d ' ')
  echo "  $ROUTES - new: $n lines · imports $(grep -c '^import ' "$f" || true) · comment lines $(awk '{ t = $0; sub(/^[ \t]+/, "", t) } t ~ /^(\/\*\*|\*|\/\/)/ { n++ } END { print n + 0 }' "$f") · blank $(grep -c '^[[:space:]]*$' "$f" || true) · beans (@Bean) $(grep -c '^    @Bean$' "$f" || true) - its key lines (grep -n):"
  for t in 'WebEndpointDiscoverer webEndpointDiscoverer(' 'var exposure = new IncludeExcludeEndpointFilter<>(' 'List.of(exposure), List.of(OperationFilter.byAccess(access))' '@ConditionalOnAvailableEndpoint(endpoint = HealthEndpoint.class)' 'HealthEndpointWebExtension healthEndpointWebExtension(' 'HttpHandler actuatorHandler(WebEndpointsSupplier endpoints) {' 'for (ExposableWebEndpoint endpoint : endpoints.getEndpoints()) {' 'Map<String, Object> arguments = match(predicate.getPath(), path);' 'Object result = operation.invoke(new InvocationContext(' 'respond(exchange, status, type, result);' '} catch (Exception | LinkageError e) {'; do
    grep -nF -- "$t" "$f" | sed 's/^\([0-9]*\):[ \t]*/    \1: /; s/ *\/\/ .*$//'; done
  gained "$SRV"
  gained tiffinbox-web/src/main/resources/application.yaml
  gained tiffinbox-web/pom.xml
  diff .harness/before/README.md .harness/after/README.md > .harness/file.diff || true
  echo "  README.md - the anchor's README: lines added $(grep -c '^> ' .harness/file.diff || true), removed $(grep -c '^< ' .harness/file.diff || true) - its new section (not shown)"
  echo "  TiffinBoxApp.java against the previous tree's, byte for byte: $(cmp -s ".harness/before/$APP" ".harness/after/$APP" && echo the same || echo different)"; }

# ---- serve: after/, as the README builds and runs it ---------------------------------------------------------------------
serve() {
  echo "after/, copied to .harness/serve with a config tree, built the README's plain way; its jar run as the README runs it, port 19005:"
  copy after .harness/serve
  pbuild .harness/serve "after/"
  libs .harness/serve > .harness/serve.lib
  start "$(at .harness/serve 19005 "$R_RUN")"; up
  echo "readiness first - asked until it answers 200, a bounded poll, not printed - then each request once:"
  ready 19005
  ask "$R_HEALTH" 19005
  ask "$R_LIVE" 19005
  ask "$R_ENV" 19005
  ask "${R_HEALTH/curl -s /curl -s -X POST }" 19005
  echo "  every address this process listens on (lsof): $(listening)"
  seven 19005 .harness/serve all; }

# ---- aot: Spring's ahead-of-time step, without and with Boot's plugin's excludes ---------------------------------------------
# gen DIR: what Spring's AOT step wrote in DIR - its bean-definition classes, the one for Actuator's Jackson configuration, and its
# reachability-metadata.json's entries (read as JSON): all, the Compose module's, Jackson 3's
gen() { local s=$1/tiffinbox-web/target/spring-aot/main/sources
  echo "  Spring's generated code (target/spring-aot/main/sources): bean-definition classes $(find "$s" -name '*__BeanDefinitions.java' | wc -l | tr -d ' ') · for Actuator's Jackson configuration: $(find "$s" -name 'JacksonEndpointAutoConfiguration__BeanDefinitions.java' | sed 's|.*/||' | grep . || echo none)"
  python3 - "$1/$META" <<'PY'
import json, sys
r = json.load(open(sys.argv[1])).get("reflection", [])
t = [json.dumps(e.get("type")) for e in r]
print("  its reachability-metadata.json: reflection entries %d · naming a Docker Compose package (...docker.compose...): %d · naming Jackson 3 (tools.jackson): %d"
      % (len(r), sum(".docker.compose." in x for x in t), sum("tools.jackson." in x for x in t)))
PY
}
# pdel FILE: the perl that deletes Boot's plugin's configuration - every line between its artifactId and its closing tag - printed
# as run, and the lines it deleted
pdel() { local c b a
  c="perl -0pi -e 's|(<artifactId>spring-boot-maven-plugin</artifactId>\\n).*?(      </plugin>)|\$1\$2|s' $1"
  b=$(wc -l < "$1"); echo "\$ $c"; eval "$c"; a=$(wc -l < "$1"); echo "  lines deleted: $((b - a)) · excludes left in the file: $(grep -c '<exclude>' "$1" || true)"; }
aot() {
  echo "B - after/ without Boot's plugin's three excludes (a copy, the plugin's configuration deleted), built with the README's AOT line:"
  echo "the profile native, from Boot's parent - Spring's AOT step, on the plain JDK - offline:"
  copy after .harness/aot-b
  pdel .harness/aot-b/tiffinbox-web/pom.xml
  pbuild .harness/aot-b "B" "$R_PKG"
  gen .harness/aot-b
  echo "B's jar, run the plain way, port 19006:"
  start "$(at .harness/aot-b 19006 "$R_RUN")"; up
  seven 19006 .harness/aot-b
  echo "B's jar, run with the generated code - the README's AOT line, port 19006:"
  start "$(at .harness/aot-b 19006 "$R_AOTRUN")"
  fails 19006
  echo "A - after/ itself, the same build:"
  copy after .harness/aot-a
  pbuild .harness/aot-a "A" "$R_PKG"
  gen .harness/aot-a
  start "$(at .harness/aot-a 19006 "$R_AOTRUN")"; up; ready 19006
  ask "$R_HEALTH" 19006
  seven 19006 .harness/aot-a
  echo "the exposure list under AOT - A's jar with the README's flag line (health and env exposed), the plain way, then the AOT way:"
  start "$(at .harness/aot-a 19006 "$R_ENVRUN")"; up; ready 19006
  ask "$R_ENV" 19006
  seven 19006 .harness/aot-a
  start "$(at .harness/aot-a 19006 "${R_ENVRUN/java -jar /java -Dspring.aot.enabled=true -jar }")"; up; ready 19006
  ask "$R_ENV" 19006
  seven 19006 .harness/aot-a; }

# ---- exposure: the break --------------------------------------------------------------------------------------------------------
exposure() { local id s ok="" ko="" n=0 m=0
  echo "A - after/'s jar (built by capture serve), the anchor's list (application.yaml: health), port 19005:"
  start "$(at .harness/serve 19005 "$R_RUN")"; up; ready 19005
  ask "$R_HEALTH" 19005
  ask "$R_ENV" 19005
  seven 19005 .harness/serve
  echo "B - the same jar, the list a star: every endpoint:"
  start "$(at .harness/serve 19005 "$R_STAR")"
  fails 19005
  echo "  TiffinBox's Jackson in the jar's BOOT-INF/lib: $(grep -E '^jackson-' .harness/serve.lib | paste -sd' ' -) · Jackson 2's time module (jackson-datatype-jsr310) among them: $(grep -c 'jsr310' .harness/serve.lib || true)"
  echo "A' - A again:"
  start "$(at .harness/serve 19005 "$R_RUN")"; up; ready 19005
  ask "$R_HEALTH" 19005
  ask "$R_ENV" 19005
  seven 19005 .harness/serve
  echo "C - labelled, not A': a star, configprops excluded:"
  start "$(at .harness/serve 19005 "$R_STARX")"; up; ready 19005
  echo "every endpoint id the jars declare (capture ways read them), each asked once with the README's env line, its id in env's place:"
  echo "\$ $(url "${R_ENV/actuator\/env/actuator/ID}" 19005) - for each ID"
  for id in $(cat .harness/ids.txt); do s=$(curl -s -o /dev/null -w '%{http_code}' "http://127.0.0.1:19005/actuator/$id" || true)
    if [ "$s" = 200 ]; then ok="$ok $id"; n=$((n + 1)); else ko="$ko $id:$s"; m=$((m + 1)); fi; done
  echo "  200, $n:$ok"
  echo "  not 200, $m:$ko"
  echo "  prometheus' registry (micrometer-registry-prometheus) among the jar's BOOT-INF/lib: $(grep -c '^micrometer-registry-prometheus' .harness/serve.lib || true)"
  seven 19005 .harness/serve; }

# ---- tour: what each endpoint hands over --------------------------------------------------------------------------------------
# get ID FILE PORT: the README's heap-dump line with ID in heapdump's place and FILE in heap.hprof's, run from .harness/serve
get() { local c; c=$(url "$R_HEAP" "$3"); c=${c/-o heap.hprof/-o $2}; c="cd .harness/serve && ${c/actuator\/heapdump/actuator/$1}"; echo "\$ $c"; (eval "$c") 2>&1 < /dev/null | sed 's/^/  /'; }
tour() { local v c
  echo "one run with C's flags - every endpoint but configprops - from .harness/serve (capture serve built it), port 19007; each answer"
  echo "saved beside the config tree, read as JSON, counted - never a value, never a name of this Mac's - and its size against a floor:"
  start "$(at .harness/serve 19007 "$R_STARX")"; up; ready 19007
  get beans beans.json 19007; get conditions conditions.json 19007; get env env.json 19007; get mappings mappings.json 19007
  get metrics metrics.json 19007; get threaddump threaddump.json 19007; get heapdump heap.hprof 19007
  (cd .harness/serve && exec env -0) > .harness/tour-env0
  (cd .harness/serve && python3 - . "$U" ../tour-env0 "$TOKEN") <<'PY'
import json, os, sys
d, home, envfile, token = sys.argv[1:5]
def load(n): return json.load(open(os.path.join(d, n)))
def size(n, floor): return "over %s bytes: %s" % (format(floor, ","), "yes" if os.path.getsize(os.path.join(d, n)) > floor else "no")
jar = os.path.join(home, ".harness/serve/tiffinbox-web/target/tiffinbox-web-1.0.0.jar")
b = load("beans.json")["contexts"]["application"]["beans"]
def names_jar(r): return jar in r or jar.replace(" ", "%20") in r
print("  beans · %s · beans listed: %d · their dependencies, named: %d · beans whose resource names the jar's absolute path (not shown): %d"
      % (size("beans.json", 40000), len(b), sum(len(v.get("dependencies", [])) for v in b.values()), sum(names_jar(v.get("resource") or "") for v in b.values())))
c = load("conditions.json")["contexts"]["application"]
print("  conditions · %s · positive matches %d · negative matches %d · unconditional classes %d"
      % (size("conditions.json", 30000), len(c["positiveMatches"]), len(c["negativeMatches"]), len(c["unconditionalClasses"])))
e = load("env.json"); srcs = e["propertySources"]
def label(n):
    if n.startswith("Config tree "): return "the config tree"
    if n.startswith("Config resource ") and "application.yaml" in n: return "application.yaml"
    return n
parts, vals = [], []
for s in srcs:
    p = s.get("properties", {}); vals += [x.get("value") for x in p.values()]
    if s["name"] == "systemEnvironment":
        # _ is the shell's (bash 5.3 hands it to the JVM, /bin/bash 3.2 does not). __CF_USER_TEXT_ENCODING is macOS's: CoreFoundation
        # writes it into a process's environment when it is missing - under env -i the JVM holds it and env -0 does not.
        aside = {"_", "__CF_USER_TEXT_ENCODING"}
        given = set(x.split("=", 1)[0] for x in open(envfile).read().split("\0") if "=" in x) - aside
        parts.append("systemEnvironment (the names of the variables this run was started with - the same as env -0 lists from the same folder, the shell's _ and macOS's __CF_USER_TEXT_ENCODING aside: %s)" % ("yes" if set(p) - aside == given else "no"))
    else:
        parts.append("%s (%d)" % (label(s["name"]), len(p)))
print("  env · %s · property sources %d, keys in each: %s" % (size("env.json", 5000), len(srcs), " · ".join(parts)))
print("    values that are not ******: %d · the demo token in the answer, raw: %d · the config tree's source name carries this folder's absolute path: %s"
      % (sum(v != "******" for v in vals), open(os.path.join(d, "env.json")).read().count(token), "yes" if any(s["name"].startswith("Config tree '" + home) for s in srcs) else "no"))
print("  mappings · the whole answer, keys sorted: %s" % json.dumps(load("mappings.json"), sort_keys=True))
m = load("metrics.json")["names"]
print("  metrics · names under tiffinbox.: %d · the first part of every name: %s" % (sum(n.startswith("tiffinbox.") for n in m), " ".join(sorted(set(n.split(".")[0] for n in m)))))
t = load("threaddump.json")["threads"]
print("  threaddump · %s · TiffinBox's server thread among the threads it lists, with its stack: %s" % (size("threaddump.json", 10000), ", ".join(sorted(x["threadName"] for x in t if x["threadName"] == "HTTP-Dispatcher")) or "none"))
os.write(3, ("  (terminal only) the answers' sizes here, bytes: %s\n" % " · ".join("%s %d" % (n, os.path.getsize(os.path.join(d, n + ".json"))) for n in ("beans", "conditions", "env", "threaddump", "metrics", "mappings"))).encode())
PY
  echo "  heapdump · what curl wrote into heap.hprof: $(cat .harness/serve/heap.hprof) - the answer's own body, not a heap"
  rm -f .harness/serve/*.json .harness/serve/heap.hprof .harness/tour-env0
  seven 19007 .harness/serve
  echo "env's masking, switched for one run each - the README's flag line (health and env exposed), one flag more, the token's entry asked:"
  for v in when-authorized always; do
    start "$(at .harness/serve 19007 "$R_ENVRUN") --management.endpoint.env.show-values=$v"; up; ready 19007
    c=$(url "$R_ENVTOK" 19007); c="cd .harness/serve && ${c/curl -s /curl -s -o env-entry.json }"
    echo "\$ $c"; (eval "$c") < /dev/null | sed 's/^/  /'
    echo "  its value: $(python3 -c 'import json,sys; v = json.load(open(sys.argv[1]))["property"]["value"]; print("******" if v == "******" else "not ****** - not printed")' .harness/serve/env-entry.json) · the demo token in the answer, raw (grep -a -o): $(raw "$TOKEN" .harness/serve/env-entry.json)"
    rm -f .harness/serve/env-entry.json
    echo "  the answer deleted: $( [ -e .harness/serve/env-entry.json ] && echo no || echo yes)"
    seven 19007 .harness/serve; done
  echo "the heap dump, switched on for one run - the README's two lines; the JVM's temporary folder set to an empty one of its own:"
  rm -rf .harness/tmp && mkdir -p .harness/tmp
  start "$(at .harness/serve 19007 "${R_HEAPRUN/java -jar /java -Djava.io.tmpdir=../tmp -jar }")"; up; ready 19007
  echo "\$ cd .harness/serve && $(url "$R_HEAP" 19007)"
  (cd .harness/serve && eval "$(url "$R_HEAP" 19007)") < /dev/null | sed 's/^/  /'
  echo "  its first bytes: $(head -c 18 .harness/serve/heap.hprof) · over 20,000,000 bytes: $( [ "$(wc -c < .harness/serve/heap.hprof)" -gt 20000000 ] && echo yes || echo no)"
  echo "  the demo token in it - copies (grep -a -o): $(raw "$TOKEN" .harness/serve/heap.hprof) · lines holding it (grep -c -a -F): $(LC_ALL=C grep -c -a -F -- "$TOKEN" .harness/serve/heap.hprof || true)"
  echo "  (terminal only) this heap dump: $(wc -c < .harness/serve/heap.hprof | tr -d ' ') bytes" >&3
  rm -f .harness/serve/heap.hprof
  echo "  the file deleted: $( [ -e .harness/serve/heap.hprof ] && echo no || echo yes) · files left in the JVM's temporary folder: $(ls -A .harness/tmp | wc -l | tr -d ' ')"
  seven 19007 .harness/serve; }

# ---- start: the start, timed from outside ---------------------------------------------------------------------------------------
timing() { local r w s line d
  echo "the start, timed from outside: harness/ttfr.py forks the command, asks /kitchen until the first 200, then sends POST /shutdown"
  echo "with the token. Three jars, each run as the README runs it from beside its config tree, port 19008; 6 rounds, each round the"
  echo "three in turn; round 1 a warm-up:"
  echo "  (terminal only) this Mac: $(sysctl -n machdep.cpu.brand_string) · $(sysctl -n hw.ncpu) cores · $(( $(sysctl -n hw.memsize) / 1073741824 )) GB · $(java -version 2>&1 | head -1) · load $(uptime | sed 's/.*load averages*: //')" >&3
  L1=$(at .harness/cost-prev 19008 "$R_RUN"); L2=$(at .harness/cost-a1 19008 "$R_RUN"); L3=$(at .harness/serve 19008 "$R_RUN")
  echo "  1 the previous tree's jar (capture cost) - \$ $L1"
  echo "  2 that tree plus Actuator's starter (capture cost) - \$ $L2"
  echo "  3 after/'s jar (capture serve) - \$ $L3"
  : > .harness/times.txt
  r=1; while [ $r -le 6 ]; do w=1; while [ $w -le 3 ]; do eval "line=\$L$w"; d=${line#cd }; d=${d%% && *}
      s=$(cd "$d" && python3 "$U/harness/ttfr.py" 19008 "$TF" "$U/.harness/ttfr.out" "$U/.harness/ttfr.err" -- ${line#cd * && })
      printf '%s %s %s\n' "$r" "$w" "$s" >> .harness/times.txt
      [ "$(listeners 19008)" = 0 ] || die "a timed run left 19008 bound"; w=$((w + 1)); done; r=$((r + 1)); done
  echo "  every run: a 200, then exit 0 after POST /shutdown: $(grep -c ' first 200 after [0-9.]* s · exit 0$' .harness/times.txt || true) of $(wc -l < .harness/times.txt | tr -d ' ')"
  echo "each jar's median, the middle of its counted runs; the reference against a floor, the other two against it (the seconds go to"
  echo "the terminal, never to this capture):"
  awk '
    { all[$2]++; if ($1 == 1) next; t[$2, $1] = $6 + 0; k[$2]++ }
    END { q = "\047"
      lk = k[1]; hk = k[1]; for (w = 2; w <= 3; w++) { if (k[w] < lk) lk = k[w]; if (k[w] > hk) hk = k[w] }
      printf "  each jar%ss runs counted: %s of %d - round 1 left out\n", q, (lk == hk) ? lk : lk "-" hk, all[1]
      for (w = 1; w <= 3; w++) { n = 0
        for (r = 2; r <= 6; r++) { x = t[w, r]; i = n; while (i > 0 && v[i] > x) { v[i + 1] = v[i]; i-- }; v[i + 1] = x; n++ }
        med[w] = v[3]; lo[w] = v[1]; hi[w] = v[5] }
      printf "  1 the previous tree%ss jar: its median over 1 s: %s\n", q, (med[1] > 1) ? "yes" : "no"
      printf "  2 against 1: its median over the previous tree%ss: %s · under a quarter more: %s\n", q, (med[2] > med[1]) ? "yes" : "no", (med[2] < med[1] * 1.25) ? "yes" : "no"
      printf "  3 against 1: its median over the previous tree%ss: %s · under a quarter more: %s\n", q, (med[3] > med[1]) ? "yes" : "no", (med[3] < med[1] * 1.25) ? "yes" : "no"
      printf "  (terminal only) 1 the previous tree: %.3f-%.3f s, median %.3f s\n", lo[1], hi[1], med[1] > "/dev/stderr"
      printf "  (terminal only) 2 with the starter: %.3f-%.3f s, median %.3f s - %.3f of 1%ss\n", lo[2], hi[2], med[2], med[2] / med[1], q > "/dev/stderr"
      printf "  (terminal only) 3 after/: %.3f-%.3f s, median %.3f s - %.3f of 1%ss, %.3f of 2%ss\n", lo[3], hi[3], med[3], med[3] / med[1], q, med[3] / med[2], q > "/dev/stderr" }' .harness/times.txt 2>&3; }

# ---- native: after/, built natively, and its binary ----------------------------------------------------------------------------
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
# against the bound (1 minute or more, under 10 minutes), and the network (offline: nbuild stopped the run if the plugin went out)
nresult() { echo "  exit $NB_E · $(grep -m1 -oE 'BUILD (SUCCESS|FAILURE)' "$1" || echo 'no BUILD line') · stages it printed: $(grep -cE '^\[[1-8]/8\] ' "$1" || true) of the $(grep -m1 -oE '^\[1/[0-9]+\]' "$1" | sed 's/.*\///; s/]//') it announces · its duration, against the bound: $( [ $NB_S -ge 60 ] && echo '1 minute or more' || echo 'under 1 minute' ), $( [ $NB_S -lt 600 ] && echo 'under 10 minutes' || echo '10 minutes or more' ) · offline: yes"; }
native() {
  echo "after/, copied to .harness/nat with a config tree; the README's two Maven lines, offline; \$GRAALVM_HOME names the GraalVM:"
  copy after .harness/nat
  nbuild .harness/nat
  nlines .harness/nat.native.log
  nresult .harness/nat.native.log
  echo "  file: $(file -b ".harness/nat/$BIN" | sed 's/ [A-Za-z0-9_]*$//') · the demo token in its bytes: $(raw "$TOKEN" ".harness/nat/$BIN")"
  echo "its binary, run from beside its config tree as the README runs it, port 19006:"
  start "$(at .harness/nat 19006 "$R_BIN")"; up; ready 19006
  ask "$R_HEALTH" 19006
  seven 19006 .harness/nat all
  echo "the same binary, with the README's flag that exposes env:"
  start "$(at .harness/nat 19006 "$R_BIN") --management.endpoints.web.exposure.include=health,env"; up; ready 19006
  ask "$R_ENV" 19006
  seven 19006 .harness/nat; }

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
  echo "  exit $ec · listening on 19009 now: $(listeners 19009)"; }

cap cost cost
cap why why
cap ways ways
cap change change
cap serve serve
cap aot aot
cap exposure exposure
cap tour tour
cap start timing
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
for f in .r-*.out README.md exercise/README.md exercise/solution/SOLUTION.md receipts.md5 harness/ttfr.py harness/shutdown.sh harness/inspect/harness/Inspect.java after/README.md after/tiffinbox-web/src/main/resources/application.yaml .harness/nat/$BIN; do
  [ -f "$f" ] || continue; case $f in .harness/nat/*) NBIN=$((NBIN + 1)) ;; esac
  [ "$(raw "$TOKEN" "$f")" = 0 ] || die "$f holds the demo token, raw"; done
[ "$NBIN" = 1 ] || die "one binary was built, $NBIN were checked"
for f in .r-*.out; do ! grep -qE '/Users/|/private/|/home/|/var/folders/' "$f" || die "$f holds an absolute path"; ! grep -qF "$GRAALVM_HOME" "$f" || die "$f holds the GraalVM's folder"; ! grep -qE 'c[0-9]-unit[0-9]|unit ?[0-9]' "$f" || die "$f holds a unit number"; done
[ -z "$(find .harness -name '*.hprof' -o -name 'env-entry.json' | head -1)" ] || die "a heap dump or an env answer with values was left under .harness/"
echo "  token: 0 raw copies in $(ls .harness/raw-* | wc -l | tr -d ' ') raw capture runs, in $(ls .r-*.out | wc -l | tr -d ' ') captures, the READMEs, the harness, receipts.md5 and the binary; no absolute path, no GraalVM folder, no unit number in any capture; no heap dump left"
# S4.16: a star in an exposure list appears only in the break (B) and with configprops excluded (C, the tour, JMX's star in ways)
# (lines that hold one: allowed when configprops is excluded on the same line, when the line ends with the break's flag - its
# command - or when it is this script's own readme() line for it)
for f in receipts.sh README.md after/README.md exercise/README.md exercise/solution/SOLUTION.md .r-*.out; do
  [ -f "$f" ] || continue
  if grep -nE "exposure\.include='?\*" "$f" | grep -v 'exposure\.exclude=configprops' | grep -vE "exposure\.include='\*'\$" | grep -vF 'R_STAR=$(readme' | grep -q .; then
    grep -nE "exposure\.include='?\*" "$f" | grep -v 'exposure\.exclude=configprops' | grep -vE "exposure\.include='\*'\$" | grep -vF 'R_STAR=$(readme' >&3
    die "$f: a star in an exposure list without configprops excluded, outside the break's own command"; fi; done


# "Spring Boot's answer is Actuator ... It comes as one starter. Added, it brought eight more jars, about two megabytes."
x cost '^  lines added: 1$'
x cost '^  jars under BOOT-INF/lib: 31 and 39 · only in the first: 0 · only in the second: 8 -$'
for j in HdrHistogram-2.2.2 micrometer-core-1.17.1 micrometer-jakarta9-1.17.1 spring-boot-actuator-4.1.1 spring-boot-actuator-autoconfigure-4.1.1 spring-boot-health-4.1.1 spring-boot-micrometer-metrics-4.1.1 spring-boot-micrometer-observation-4.1.1; do
  grep -E '^    HdrHistogram-2\.2\.2\.jar ' .r-cost.out | tr ' ' '\n' | grep -qxF "$j.jar" || die "cost: the new jar $j"; done
BADD=$(sed -n 's/^  bytes: [0-9]* and [0-9]* · added: \([0-9]*\)$/\1/p' .r-cost.out); [ -n "$BADD" ] && [ "$BADD" -gt 1900000 ] && [ "$BADD" -lt 2100000 ] || die "cost: about two megabytes ($BADD)"
x cost '^  each extracted \(the README.s extract\): the jars that hold an auto-configuration imports file, and the candidates they list - 2 jars, 13 candidates · 6 jars, 74 candidates$'
# "Inside, seventy-five more bean definitions, twenty-one more auto-configurations, and one endpoint bean: health. Now ask for slash
# actuator slash health. Four hundred four. Nothing anyone can reach."
[ "$(n cost "^  harness: Boot's kind of application: NONE · the context: AnnotationConfigApplicationContext\$")" = 2 ] || die "cost: NONE, twice"
x cost "^  harness: bean definitions, this harness's own left out: 59\$"; x cost "^  harness: bean definitions, this harness's own left out: 134\$"
x cost '^  harness: auto-configuration classes registered: 10 of the 13 candidates - the rest 10$'
x cost "^  harness: auto-configuration classes registered: 31 of the 74 candidates - Actuator's 5 · Micrometer's 11 · health's 5 · the rest 10\$"
x cost '^  harness: endpoint beans: 0 - no Actuator on this class path$'
x cost '^  harness: endpoint beans: 1 - health · beans that hand endpoints to an adapter \(EndpointsSupplier\): 0$'
[ "$(n cost "^  harness: Boot's MBeans \(org\.springframework\.boot\): 0\$")" = 2 ] || die "cost: no MBean, twice"
x cost '^  every address this process listens on \(lsof\): 127\.0\.0\.1:19001$'
x cost '^  <h1>404 Not Found</h1>No context found for request 404$'
[ "$(n cost "^  exit 0 · the seven responses: 7 lines · md5 $S115\$")" = 2 ] || die "cost: the seven, twice"
[ "$(n cost ' · offline: yes · exit 0$')" = 2 ] || die "cost: two offline builds"
echo "  cost: 31 -> 39 jars (8 named) · +$BADD bytes · imports 2 -> 6 · NONE · definitions 59 -> 134 · auto-configurations 10 -> 31 · endpoint beans 0 -> 1 (health) · 0 suppliers, 0 MBeans · /actuator/health 404 · 115c36ba... x2"

# "Boot's condition report says why. Web endpoints wait for a servlet or reactive web application. JMX endpoints wait for spring dot
# jmx dot enabled. Health's web extension waits for servlet classes."
x why '^       WebEndpointAutoConfiguration:$'
x why '^             - @ConditionalOnWebApplication did not find reactive or servlet web application classes \(OnWebApplicationCondition\)$'
x why '^       JmxEndpointAutoConfiguration:$'
x why "^             - @ConditionalOnBooleanProperty \(spring\.jmx\.enabled=true\) did not find property 'spring\.jmx\.enabled' \(OnPropertyCondition\)\$"
x why '^       HealthEndpointWebExtensionConfiguration:$'
x why '^             - did not find servlet web application classes \(OnWebApplicationCondition\)$'
x why "^             - @ConditionalOnAvailableEndpoint the configured access for endpoint 'heapdump' is NONE \(OnAvailableEndpointCondition\)\$"
[ "$(n why '^    … [0-9]+ lines? not shown …$')" = 5 ] || die "why: the report's five gaps, counted"
x why "^  exit 0 · the seven responses: 7 lines · md5 $S115\$"
echo "  why: the report's four blocks - web endpoints (no servlet or reactive web application), JMX (no spring.jmx.enabled), health's web extension (no servlet classes), heapdump (access NONE) - every gap counted"

# "One: JMX ... Switched on, one MBean, health, details included. Every endpoint on JMX makes eleven, but never heapdump, logfile or
# prometheus: their classes are marked web only."
x ways "^  harness: Boot's MBeans \(org\.springframework\.boot\): 1 - Health\$"
x ways '^  harness: over JMX, Health.s operation health answers - the names in it, every value left out: .*diskSpace\(details\(exists free path threshold total\) status\)'
x ways "^  harness: Boot's MBeans \(org\.springframework\.boot\): 11 - Beans Conditions Env Health Info Loggers Mappings Metrics Sbom Scheduledtasks Threaddump\$"
x ways '^  endpoint classes in the jars, by their annotation \(javap -v\): 19 - ids: auditevents beans conditions configprops env health heapdump httpexchanges info logfile loggers mappings metrics prometheus sbom scheduledtasks shutdown startup threaddump$'
x ways '^    HeapDumpWebEndpoint · @WebEndpoint\(id="heapdump", defaultAccess=NONE\)$'
x ways '^    LogFileWebEndpoint · @WebEndpoint\(id="logfile"\)$'
x ways '^    PrometheusScrapeEndpoint · @WebEndpoint\(id="prometheus"\)$'
x ways '^  the ones whose annotation sets defaultAccess=NONE - off unless switched on: heapdump shutdown$'
[ "$(n ways ' · @WebEndpoint\(')" = 3 ] || die "ways: three web-only endpoint classes"
# "Two: Spring MVC on Tomcat ... Twelve more jars, and a second server in the same JVM. After POST shutdown, TiffinBox's server
# stopped, and the JVM didn't. Tomcat kept it running until a kill signal."
x ways "^  jars under BOOT-INF/lib: 51 - against the starter alone's 39: 12 more -\$"
x ways '^  every address this process listens on \(lsof\): 127\.0\.0\.1:19003 127\.0\.0\.1:19004$'
x ways "^  Tomcat's own line: Tomcat started on port 19004 \(http\) with context path '/'\$"
x ways '^  \{"groups":\["liveness","readiness"\],"status":"UP"\} 200$'
x ways "^  its answer: the kinds of mapping it lists - dispatcherServlets servletFilters servlets · mentions of TiffinBox's five paths .*: 0\$"
x ways '^  2 s after POST /shutdown - still running: yes · listening on: 127\.0\.0\.1:19004$'
x ways "^  exit 143 · listening on 19003 and 19004 now: 0 and 0 · the seven responses: 7 lines · md5 $S115\$"
[ "$(n ways "^  exit 0 · the seven responses: 7 lines · md5 $S115\$")" = 2 ] || die "ways: the two JMX runs serve the seven"
echo "  ways: JMX 1 MBean (Health, details) · 11 with every endpoint · 19 endpoint classes, 3 web-only · Tomcat +12 jars, two addresses on 127.0.0.1, still running 2 s after POST /shutdown, SIGTERM 143 · 115c36ba..."

# "So TiffinBox writes the adapter, from Boot's own parts: one class, ActuatorRoutes, three beans. Boot's discoverer finds every
# endpoint's operations, through two filters: exposure ... and access. Boot's health extension serves health. And a handler matches each
# request to an operation, invokes it, and writes the answer with TiffinBox's own Jackson." - "TiffinBoxServer takes one more
# constructor argument, and hands slash actuator to it. Application dot yaml writes the list down: health."
x change '^  tiffinbox-web/src/main/java/com/tiffinbox/web/ActuatorRoutes\.java - new: [0-9]+ lines · imports [0-9]+ · comment lines [0-9]+ · blank [0-9]+ · beans \(@Bean\) 3 - its key lines \(grep -n\):$'
x change '^    [0-9]+: WebEndpointDiscoverer webEndpointDiscoverer\('
x change '^    [0-9]+: var exposure = new IncludeExcludeEndpointFilter<>\('
x change '^    [0-9]+: advisors\.orderedStream\(\)\.toList\(\), List\.of\(exposure\), List\.of\(OperationFilter\.byAccess\(access\)\)\);$'
x change '^    [0-9]+: HealthEndpointWebExtension healthEndpointWebExtension\('
x change '^    [0-9]+: for \(ExposableWebEndpoint endpoint : endpoints\.getEndpoints\(\)\) \{$'
x change '^    [0-9]+: Object result = operation\.invoke\(new InvocationContext\('
x change '^    [0-9]+: \} catch \(Exception \| LinkageError e\) \{$'
grep -q 'private static final ObjectMapper JSON = new ObjectMapper();' "after/$ROUTES" && grep -q 'com.fasterxml.jackson.databind.ObjectMapper' "after/$ROUTES" || die "ActuatorRoutes writes with TiffinBox's own Jackson 2"
x change '^                        HttpHandler actuator\) \{$'
x change '^            server\.createContext\("/actuator", actuator\);$'
x change '^            include: health$'
x change '^  TiffinBoxApp\.java against the previous tree.s, byte for byte: the same$'
[ "$(n change '^                <exclude>$')" = 3 ] || die "change: the three excludes"
x change '^          <artifactId>spring-boot-starter-actuator</artifactId>$'
cmp -s "after/$APP" "$PREV/$APP" || die "TiffinBoxApp.java changed: it must not (brief ⚑11)"
echo "  change: ActuatorRoutes - 3 beans, exposure and access, invoke, the catch; TiffinBoxServer - the argument, the context; application.yaml - include: health; the POM - the starter, 3 excludes; TiffinBoxApp unedited"

# "Run the jar. Slash actuator slash health: UP, with two groups, liveness and readiness, and no details. Slash env: four hundred
# four, not exposed. A POST to health: four hundred five. One server, one address, the same seven responses."
H='  {"status":"UP","groups":["liveness","readiness"]} 200'
SVE=$(blk serve "\$ curl -s -o /dev/null -w '%{http_code}" '$ curl -s -X POST'); has "$SVE" "  404" "serve: env 404"     # (awk -v reads a backslash as an escape: no \n in the pattern)
x serve '^  \{"status":"UP","groups":\["liveness","readiness"\]\} 200$'
x serve '^  \{"error":"method not allowed"\} 405$'
x serve '^  every address this process listens on \(lsof\): 127\.0\.0\.1:19005$'
x serve "^  exit 0 · the seven responses: 7 lines · md5 $S115\$"
[ "$(n serve ' -> ')" = 7 ] || die "serve: the seven response lines"
echo "  serve: readiness 200 · health UP, liveness and readiness, no details · env 404 · POST 405 · one address · 115c36ba..."

# "And the start, timed from outside. On this Mac, Actuator's jar took longer than the anchor's, but under a quarter longer: the middle
# of five runs."
x start '^  every run: a 200, then exit 0 after POST /shutdown: 18 of 18$'
x start "^  each jar's runs counted: 5 of 6 - round 1 left out\$"
x start "^  1 the previous tree's jar: its median over 1 s: yes\$"
x start "^  2 against 1: its median over the previous tree's: yes · under a quarter more: yes\$"
x start "^  3 against 1: its median over the previous tree's: yes · under a quarter more: yes\$"
echo "  start: 18 of 18 · 5 of 6 counted · the reference over 1 s · the starter's and after/'s medians over it, under a quarter more"

# "Without one more change, Spring's AOT jar stopped at start: NoClassDefFoundError, Jackson 3's JsonMapper, a class the jar doesn't
# hold ... So it generated Actuator's Jackson 3 configuration." - "The change: three excludes in Boot's plugin ... That configuration is
# gone, and the AOT jar serves. A flag can't widen its list: slash env stays four hundred four."
AB=$(blk aot 'B - after/ without' 'A - after/ itself'); AA=$(blk aot 'A - after/ itself' 'the exposure list under AOT'); AX=$(blk aot 'the exposure list under AOT' '')
has "$AB" "  lines deleted: 20 · excludes left in the file: 0" "aot B"
has "$AB" "  Spring's generated code (target/spring-aot/main/sources): bean-definition classes 64 · for Actuator's Jackson configuration: JacksonEndpointAutoConfiguration__BeanDefinitions.java" "aot B"
has "$AB" "  its reachability-metadata.json: reflection entries 399 · naming a Docker Compose package (...docker.compose...): 3 · naming Jackson 3 (tools.jackson): 0" "aot B"
has "$AB" "  exit 0 · the seven responses: 7 lines · md5 $S115" "aot B, the plain way"
has "$AB" "  TiffinBox's own line, before it stopped: TiffinBox listening on http://127.0.0.1:19006" "aot B"
has "$AB" "    org.springframework.beans.factory.BeanCreationException: Error creating bean with name 'endpointJsonMapper' …" "aot B"
has "$AB" "    Caused by: java.lang.NoClassDefFoundError: tools/jackson/databind/json/JsonMapper" "aot B"
has "$AB" "  exit 1 · listening on 19006 now: 0" "aot B"
printf '%s\n' "$AB" | grep -q "^  Boot's failure analysis (its banner, APPLICATION FAILED TO START): 0 · " || die "aot B: no failure analysis"
has "$AA" "  Spring's generated code (target/spring-aot/main/sources): bean-definition classes 63 · for Actuator's Jackson configuration: none" "aot A"
has "$AA" "  its reachability-metadata.json: reflection entries 394 · naming a Docker Compose package (...docker.compose...): 0 · naming Jackson 3 (tools.jackson): 0" "aot A"
has "$AA" "  Boot's first line: Starting AOT-processed TiffinBoxServer v1.0.0 using Java 25.0.4.1" "aot A"
has "$AA" "$H" "aot A"; has "$AA" "  exit 0 · the seven responses: 7 lines · md5 $S115" "aot A"
[ "$(printf '%s\n' "$AX" | grep -E '^  (200|404)$' | tr -d ' ' | paste -sd' ' -)" = "200 404" ] || die "aot: the flag - plain env 200, then AOT env 404"
[ "$(n aot ' · offline: yes · exit 0$')" = 2 ] || die "aot: two offline builds"
echo "  aot: B - Jackson's bean definitions generated, 3 Compose entries, the plain jar 115c36ba..., the AOT jar listening then exit 1 (endpointJsonMapper, JsonMapper) · A - none, 0, AOT 115c36ba... and health · the flag: env 200 plain, 404 AOT"

# "Built native, the binary serves the same seven and health with its groups, and the flag changes nothing there either."
x native '^  built \.harness/nat \(both modules, into \$M2\) · offline: yes · exit 0$'
x native '^  exit 0 · BUILD SUCCESS · stages it printed: 8 of the 8 it announces · its duration, against the bound: 1 minute or more, under 10 minutes · offline: yes$'
x native '^  file: Mach-O 64-bit executable · the demo token in its bytes: 0$'
x native '^  Boot.s first line: Starting AOT-processed TiffinBoxServer using Java 25\.0\.4\.1$'
x native '^  \{"status":"UP","groups":\["liveness","readiness"\]\} 200$'
[ "$(n native "^  exit 0 · the seven responses: 7 lines · md5 $S115\$")" = 2 ] || die "native: the binary stops cleanly twice, the seven"
[ "$(n native ' -> ')" = 8 ] || die "native: the seven response lines and the second run's POST"
NE=$(blk native "the same binary, with the README's flag" ''); has "$NE" "  404" "native: env 404 with the flag"
echo "  native: 8 of 8, offline, 0 tokens in its bytes, AOT-processed, health with its groups, 115c36ba...; the flag - env 404"

# "B, a star, every endpoint: the start stops. NoClassDefFoundError: Jackson 2's time module, which the configprops endpoint needs and
# TiffinBox's Jackson, Course two's library, doesn't carry. No failure analysis, forty-one stack frames. A again: it starts." - "C,
# a star minus configprops: it starts, and eleven of the nineteen endpoints answer."
EA=$(blk exposure "A - after/'s jar" 'B - the same jar'); EB=$(blk exposure 'B - the same jar' "A' - A again"); EA2=$(blk exposure "A' - A again" 'C - labelled'); EC=$(blk exposure 'C - labelled' '')
for b in "$EA" "$EA2"; do has "$b" "$H" "exposure A, A'"; has "$b" "  404" "exposure A, A': env 404"; has "$b" "  exit 0 · the seven responses: 7 lines · md5 $S115" "exposure A, A'"; done
[ "$(printf '%s\n' "$EA" | grep '^\$ cd ')" = "$(printf '%s\n' "$EA2" | grep '^\$ cd ')" ] || die "exposure: A' is not A's command"
has "$EB" "    org.springframework.beans.factory.BeanCreationException: Error creating bean with name 'configurationPropertiesReportEndpoint' …" "exposure B"
has "$EB" "    Caused by: java.lang.NoClassDefFoundError: com/fasterxml/jackson/datatype/jsr310/JavaTimeModule" "exposure B"
has "$EB" "  Boot's failure analysis (its banner, APPLICATION FAILED TO START): 0 · stack frames (lines starting 'at '): 41" "exposure B"
has "$EB" "  exit 1 · listening on 19005 now: 0" "exposure B"
has "$EB" "  TiffinBox's Jackson in the jar's BOOT-INF/lib: jackson-annotations-2.22.jar jackson-core-2.22.2.jar jackson-databind-2.22.2.jar · Jackson 2's time module (jackson-datatype-jsr310) among them: 0" "exposure B"
has "$EC" "  200, 11: beans conditions env health info loggers mappings metrics sbom scheduledtasks threaddump" "exposure C"
has "$EC" "  not 200, 8: auditevents:404 configprops:404 heapdump:404 httpexchanges:404 logfile:404 prometheus:404 shutdown:404 startup:404" "exposure C"
has "$EC" "  prometheus' registry (micrometer-registry-prometheus) among the jar's BOOT-INF/lib: 0" "exposure C"
echo "  exposure: A health 200, env 404 · B exit 1 (configprops, JavaTimeModule), no analysis, 41 frames, no jsr310 jar · A' = A · C 11 of 19 answer 200"

# "Beans: a hundred fifty-three, and six name where the jar sits on disk. Env masks every value, but lists every variable's name.
# Mappings: empty." - "With show-values always, env printed the token itself. Heapdump ... is off by default. Switched on, it handed
# over more than twenty megabytes, with three copies of the shutdown token."
x tour "^  beans · over 40,000 bytes: yes · beans listed: 153 · their dependencies, named: [0-9]+ · beans whose resource names the jar's absolute path \(not shown\): 6\$"
x tour "^  env · over 5,000 bytes: yes · property sources 6, keys in each: .*the same as env -0 lists from the same folder, the shell's _ and macOS's __CF_USER_TEXT_ENCODING aside: yes\)"
x tour "^    values that are not \*\*\*\*\*\*: 0 · the demo token in the answer, raw: 0 · the config tree's source name carries this folder's absolute path: yes\$"
x tour '^  mappings · the whole answer, keys sorted: \{"contexts": \{"application": \{"mappings": \{\}, "parentId": null\}\}\}$'
x tour '^  heapdump · what curl wrote into heap\.hprof: \{"error":"not found"\} - the answer.s own body, not a heap$'
x tour '^  its value: \*\*\*\*\*\* · the demo token in the answer, raw \(grep -a -o\): 0$'
x tour '^  its value: not \*\*\*\*\*\* - not printed · the demo token in the answer, raw \(grep -a -o\): 2$'
x tour '^  its first bytes: JAVA PROFILE 1\.0\.2 · over 20,000,000 bytes: yes$'
x tour '^  the demo token in it - copies \(grep -a -o\): 3 · lines holding it \(grep -c -a -F\): 3$'
x tour "^  the file deleted: yes · files left in the JVM's temporary folder: 0\$"
[ "$(n tour '^  the answer deleted: yes$')" = 2 ] || die "tour: both env answers deleted"
[ "$(n tour "^  exit 0 · the seven responses: 7 lines · md5 $S115\$")" = 4 ] || die "tour: four runs, each stopped by the seven"
echo "  tour: beans 153 (6 name the jar's path) · env every value masked, the run's own names · mappings empty · heapdump 404 · when-authorized masked, always 2 raw copies · the heap dump over 20,000,000 bytes, 3 copies on 3 lines, deleted"

# the exercise's end state: the line exercise/README.md calls "Done" is a line of this capture, after the solution's line - and of
# SOLUTION.md's measured run
XE=$(blk exercise "the solution's line" '')
l="Config tree '…/secrets' · tiffinbox.shutdown-token = ******"
has "$XE" "$l" "exercise"
awk '/^\*\*Done\*\*/ { f = 1 } f' exercise/README.md | grep -qxF -- "$l" || die "exercise/README.md: Done names no such line"
grep -qxF -- "$l" exercise/solution/SOLUTION.md || die "SOLUTION.md: the measured run shows no such line"
x exercise '^  exit 0 · printed: [0-9]+ line\(s\)$'
x exercise '^POST /shutdown -> 200 · curl exit 0$'
x exercise '^  exit 0 · listening on 19009 now: 0$'
echo "  exercise: the README as written, then the solution's line -> the config tree, the value masked"

# the anchor's README states the same numbers
grep -qF '31 → 39' after/README.md && grep -qF '59 bean definitions' after/README.md && grep -qF '134' after/README.md || die "after/README.md: the starter's counts"
grep -qF '`{"status":"UP","groups":["liveness","readiness"]}`' after/README.md || die "after/README.md: health's answer"
grep -qF 'NoClassDefFoundError: tools/jackson/databind/json/JsonMapper' after/README.md && grep -qF 'JavaTimeModule' after/README.md || die "after/README.md: the two failures"
grep -qF 'over 20 MB' after/README.md && grep -qF '3 copies of the shutdown token' after/README.md || die "after/README.md: the heap dump"
cmp -s after/README.md ../c5-tiffinbox/README.md || echo "  (after/README.md and ../c5-tiffinbox/README.md differ - the anchor is not this unit's after/ yet)" >&3
[ -z "$unpub" ] || die "no published hash for:$unpub - check the captures, then copy the md5s above into receipts.md5 and run again"
echo "c5-unit21: every capture 3/3 and = published; every spoken number asserted; 0 raw demo tokens in every capture"
