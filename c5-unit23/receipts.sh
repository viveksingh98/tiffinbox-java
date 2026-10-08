#!/bin/bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25.0.4.1 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# GRAALVM_HOME names a GraalVM JDK 25 (README.md, "The GraalVM"): the native builds read it. Without it, this script makes every
# capture that needs no GraalVM - the JVM's, and the exercise's - filling .m2-demo on the way, then stops before the native build.
# Course 5 · Metrics with Micrometer - this unit's receipts. Actuator already counted the JVM's threads and memory; TiffinBox's
# own orders and answers were counted by nobody, in no format a monitoring server reads. The anchor change: tiffinbox-web's POM
# (micrometer-registry-prometheus), KitchenMetrics.java (new: a MeterBinder bean - two FunctionCounters over the kitchen's own
# getters - and one native hint, @RegisterReflection of com.sun.management.OperatingSystemMXBean), TiffinBoxServer.java (a
# MeterRegistry parameter and a timer around handle(), tagged by the route TiffinBox declares and the status), ActuatorRoutes.java
# (one line: a byte[] answer - the scrape - is written as it is, not as JSON) and application.yaml (exposure health,prometheus).
# Eight captures, each run three times and hashed; cap() DIES when a hash differs from receipts.md5; every number the video says
# is asserted at the bottom by a check that can fail; the demo token is masked (gsub), and the last checks count 0 raw copies of
# it in every capture, every scrape and endpoint answer saved on the way, every file this unit ships, and the binaries it built.
#   before    the previous tree, Actuator's metrics endpoints exposed by the README's flag line: /actuator/prometheus 404 even
#             exposed; the meters' names through a filter (their first words, never a total; none http.*, none tiffinbox.*), the
#             registry bean's class (beans, through a filter), and after a request still no http.* name; the seven
#   change    the previous tree against after/: the files that differ, KitchenMetrics.java counted and its key lines,
#             TiffinBoxServer.java's and ActuatorRoutes.java's changed lines, what the POM and application.yaml gain;
#             tiffinbox-core, TiffinBoxApp.java and KitchenHealthIndicator.java byte for byte
#   scrape    after/ built the README's way: its jar's BOOT-INF/lib against the previous tree's; run as the README runs it:
#             the scrape (status and content type, the tiffinbox_ lines, three lines of one JVM family, its value masked), the
#             same in OpenMetrics (the family's name, its last line); then the README's flag line: the registry bean, the names
#   counter   after/'s jar: /kitchen beside the scrape's two counters; again with the README's --tiffinbox.days=10
#   timer     after/'s jar with the README's flag line: no timer before the first answer; the requests, one by one; the timer's
#             series (sums and maxes masked); then C (labelled): a tag filter on the metrics endpoint, which the bridge passes
#   cardinality  the break, the route tag: A after/ (the route) · B a copy whose tag is the raw path · A' = A - four URLs each
#   native    after/ built natively (the README's two Maven lines): the AOT jar and the binary - the scrape and the seven;
#             Micrometer's own native-image metadata; then B, the hint taken out (C, labelled: B with the CPU-time meter off), A',
#             A's binary again, and D (labelled): the other interface's name in
#             its place - each built natively, each binary's scrape
#   exercise  exercise/README.md's commands and exercise/solution/SOLUTION.md's, read from the files and run as written
# "before" is ../c5-unit22/after (the anchor as the health lesson left it), COPIED under .harness/; this script never writes into
# another unit's folder. after/ is this unit's frozen copy of ../c5-tiffinbox after the change; it is copied, never built in
# place. Every run of TiffinBox starts in a folder under .harness/ that holds a config tree with the demo token (secrets/), as the
# README asks. Commands are printed exactly as they run: each goes through eval. "$CURLSET" is the comparison set since the secrets
# lesson (../c5-unit11/curlset.sh: the seven requests, POST /shutdown with the token's header read from the file). "$M2" is this
# unit's own repository, .m2-demo.
# The network: every build runs offline (-o) against .m2-demo and says so ("offline: yes"); a build that cannot resolve an
# artifact offline goes to the remote repository once - Maven Central, or the mirror your settings name - and says that ("offline: no - ..."). GraalVM's native plugin, under the profile
# native, reads its metadata repository (a zip) from .m2-demo - and when the zip is not there it downloads it from GitHub, even
# under -o (README.md, The repository): so a native-profile build without the zip goes to Maven Central for it at once, never
# offline first, and every build's log is searched for the plugin's own download line - found, the run stops. At run time nothing
# leaves 127.0.0.1: TiffinBox listens there, every request goes there, and Prometheus's registry pushes nothing (it is read).
# Masks and filters (README.md declares each; sub/gsub only): the demo token becomes "[masked: the 26-character token]"; the
# GraalVM's folder "$GRAALVM_HOME"; this folder's absolute path "…", the folder above it "…/..", the home folder "~"; your user
# name "<user>" - in every line of every capture. A timer's sums and maxes, and a JVM meter's value, are masked by name. A scrape,
# a metrics answer and a beans answer are written to a file beside the run's config tree, read through a filter, and deleted in
# the same step (they hold this computer's numbers, a disk's folder, class paths); the exit trap deletes them again. A Boot log
# line is printed from its message on, its first line cut before " with PID". No duration is captured: each native build is
# judged against a bound; seconds go to the terminal.
# Ports (brief ⚑10, 19020-19029): before 19020 · scrape 19021 · counter 19022 · timer 19023 · cardinality 19024 · native 19025 ·
# exercise 19029. 18425 (TiffinBox's default) and 8080 (Tomcat's) are checked free too.
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
# its process group - a TiffinBox JVM (a jar), a binary, native-image's driver or builder - is stopped. Then the answers saved on
# the way, if a run left one (a scrape names a disk's folder; beans, class paths). After an interrupt, a capture's unfinished runs
# (.r-NAME.1-3) go too; after a failed check they stay, for the diff the message names. The clean-up ignores a second Ctrl-C, and
# nothing in it can fail under set -e, so it always reaches the rmdir; the script still exits 130 after an interrupt (tested:
# README.md, "Interrupted"). $pid is cleared whenever the process has been reaped.
pid=""
sweep() { local g i l
  g=$(ps -o pgid= -p $$ 2> /dev/null | tr -d ' ') || g=""
  [ -n "$g" ] || return 0
  i=0; while [ $i -lt 20 ]; do
    l=$(ps -axo pid=,pgid=,command= 2> /dev/null | awk -v g="$g" -v me=$$ -v gh="${GRAALVM_HOME:-/nonexistent}" '
      $2 == g && $1 != me && $3 != "awk" && $3 != "ps" && (index($0, "vminvocation.args") || index($3, gh "/bin/native-image") || $3 ~ /tiffinbox-web\/target\/tiffinbox-web$/ || index($0, "tiffinbox-web-1.0.0.jar") || index($0, "com.tiffinbox.web.TiffinBoxServer")) { print $1 }' | paste -sd' ' -) || l=""
    [ -n "$l" ] || return 0
    if [ $i -lt 10 ]; then kill $l 2> /dev/null || true; else kill -9 $l 2> /dev/null || true; fi
    sleep 0.5; i=$((i + 1)); done; }
machinefiles() { rm -f .harness/*/scrape.txt .harness/*/metrics.json .harness/*/beans.json .harness/mine/*/scrape.txt 2> /dev/null || true; }
trap 'trap "" INT TERM; if [ -n "$pid" ] && kill "$pid" 2> /dev/null; then wait "$pid" 2> /dev/null || true; fi; sweep || true; machinefiles; [ -z "$INTR" ] || rm -f .r-*.[123]; rmdir .r-lock 2> /dev/null || true' EXIT
INTR=""; trap 'INTR=1; exit 130' INT TERM
exec 3>&1                                            # die() speaks to the terminal even inside a redirected capture
die() { echo "  *** $* ***" >&3; exit 1; }
java -version 2>&1 | grep -q 'version "25' || die "JDK 25 needed; JAVA_HOME gives: $(java -version 2>&1 | head -1)"
command -v python3 > /dev/null || die "python3 is needed: Actuator's metrics and beans answers are JSON, read through a filter"
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
PREV=../c5-unit22/after                              # the previous tree: read, copied, never built in place
JAR=tiffinbox-web/target/tiffinbox-web-1.0.0.jar
BIN=tiffinbox-web/target/tiffinbox-web               # the binary native:compile-no-fork writes, in a tree's web module
TF=secrets/tiffinbox/shutdown-token                  # the config tree's file for tiffinbox.shutdown-token
KM=tiffinbox-web/src/main/java/com/tiffinbox/web/KitchenMetrics.java
SRV=tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java
ROUTES=tiffinbox-web/src/main/java/com/tiffinbox/web/ActuatorRoutes.java
APP=tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxApp.java
KHI=tiffinbox-web/src/main/java/com/tiffinbox/web/KitchenHealthIndicator.java
YAML=tiffinbox-web/src/main/resources/application.yaml
POM=tiffinbox-web/pom.xml
MCORE="$M2/io/micrometer/micrometer-core/1.17.1/micrometer-core-1.17.1.jar"
# The demo token. FAKE, and meant to look it: it guards nothing but a demo server on 127.0.0.1 that every capture stops. It is
# written into .harness/*/secrets/ (git-ignored) when this script runs, and no capture prints it: see mask().
TOKEN=not-a-real-token-demo-only
[ ${#TOKEN} = 26 ] || die "the demo token must be 26 characters"
CURLSET=../c5-unit11/curlset.sh                      # the comparison set: the seven requests, POST /shutdown with the header
[ -f "$CURLSET" ] || die "$CURLSET is missing"
[ -f "$PREV/pom.xml" ] && [ -f after/pom.xml ] && [ -f after/README.md ] || die "the previous tree $PREV or after/ is missing"
[ -f harness/shutdown.sh ] || die "harness/ is missing shutdown.sh"

# The ports, BEFORE anything is wiped (a survivor of an interrupted run answers POST /shutdown only with its token, which lives
# in .harness/ - so the message names the process to kill).
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
for p in 18425 8080 19020 19021 19022 19023 19024 19025 19026 19027 19028 19029; do
  [ "$(listeners $p)" = 0 ] || die "something already listens on $p - this unit's ports must be free; if it is a TiffinBox an interrupted run left behind, stop it: kill $(lsof -nP -iTCP:$p -sTCP:LISTEN -t 2> /dev/null | paste -sd' ' -)"; done

# ---- the commands: read from after/README.md, the anchor's own, and asserted - each line must be there, whole -------------
readme() { grep -m1 -xF -- "$1" after/README.md > /dev/null || die "after/README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
R_PLAIN=$(readme 'mvn -B package')
R_RUN=$(readme 'java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431')
R_AOTRUN=$(readme 'java -Dspring.aot.enabled=true -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431')
R_GRAAL=$(readme 'export GRAALVM_HOME=/path/to/a/graalvm-jdk-25')
R_INSTALL=$(readme 'mvn -B -Pnative install')
R_NATIVE=$(readme 'mvn -B -Pnative -pl tiffinbox-web native:compile-no-fork')
R_BIN=$(readme 'tiffinbox-web/target/tiffinbox-web --tiffinbox.port=18431')
R_READY=$(readme "curl -s -w ' %{http_code}\n' http://127.0.0.1:18431/actuator/health/readiness")
R_CUSTOMERS=$(readme "curl -s -w ' %{http_code}\n' http://127.0.0.1:18431/customers")
R_SCRAPE=$(readme "curl -s -o scrape.txt -w '%{http_code} %{content_type}\n' http://127.0.0.1:18431/actuator/prometheus")
R_OPENM=$(readme "curl -s -o scrape.txt -w '%{http_code} %{content_type}\n' -H 'Accept: application/openmetrics-text; version=1.0.0' http://127.0.0.1:18431/actuator/prometheus")
R_PROM3=$(readme "curl -s -o scrape.txt -w '%{http_code} %{content_type}\n' -H 'Accept: application/openmetrics-text;version=1.0.0;q=0.5,application/openmetrics-text;version=0.0.1;q=0.4,text/plain;version=1.0.0;q=0.3,text/plain;version=0.0.4;q=0.2,*/*;q=0.1' http://127.0.0.1:18431/actuator/prometheus")   # the Accept header a Prometheus 3 server sends (RED C5-S4 #18)
R_DAYS=$(readme 'java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --tiffinbox.days=10')
R_STATUS=$(readme "curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:18431/customers/7")
R_FORBID=$(readme "curl -s -w ' %{http_code}\n' -X POST http://127.0.0.1:18431/shutdown")
R_WIDE=$(readme 'java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --management.endpoints.web.exposure.include=health,prometheus,metrics,beans')
R_METRICS=$(readme "curl -s -o metrics.json -w '%{http_code}\n' http://127.0.0.1:18431/actuator/metrics")
R_BEANS=$(readme "curl -s -o beans.json -w '%{http_code}\n' http://127.0.0.1:18431/actuator/beans")
R_TAG=$(readme "curl -s -o metrics.json -w '%{http_code}\n' 'http://127.0.0.1:18431/actuator/metrics/tiffinbox.requests?tag=status:405'")
R_CPUOFF=$(readme 'tiffinbox-web/target/tiffinbox-web --tiffinbox.port=18431 --management.metrics.enable.process.cpu.time=false')
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
# path 'README curl LINE' PATH: the README's status line, its path /customers/7 made PATH
path() { printf '%s\n' "${1/\/customers\/7/$2}"; }
F_WIDE=$(flag "$R_WIDE"); F_DAYS=$(flag "$R_DAYS"); F_CPUOFF=$(flag "$R_CPUOFF")
[ "$F_WIDE" = --management.endpoints.web.exposure.include=health,prometheus,metrics,beans ] && [ "$F_DAYS" = --tiffinbox.days=10 ] && [ "$F_CPUOFF" = --management.metrics.enable.process.cpu.time=false ] || die "a README flag line does not end in its one flag"
C_AFTER=$(off .harness/after "$R_INSTALL" install)
for c in "$C_AFTER" "$(off .harness/x "$R_PLAIN" package)" "$(off .harness/x "$R_NATIVE")"; do
  r=$(dev "$c"); [ "$r" = "$R_PLAIN" ] || [ "$r" = "$R_INSTALL" ] || [ "$r" = "$R_NATIVE" ] || die "not a README line with the offline changes: $c"; done
[ "$(at .harness/x 19025 "$R_BIN")" = "cd .harness/x && tiffinbox-web/target/tiffinbox-web --tiffinbox.port=19025" ] || die "the binary's run line"
[ "$(url "$R_SCRAPE" 19021)" = "curl -s -o scrape.txt -w '%{http_code} %{content_type}\n' http://127.0.0.1:19021/actuator/prometheus" ] || die "the scrape line, its port"
[ "$(path "$(url "$R_STATUS" 19024)" /customersXYZ)" = "curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:19024/customersXYZ" ] || die "the status line, its path"
echo "  the commands: after/README.md gives all 21 lines this script runs or derives from"

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
# fresh clone, whose .m2-demo is empty (git ignores it), this one build fills .m2-demo from Maven Central, once.
mbuild "$C_AFTER" .harness/build-after.log ".harness/after (after/, the profile native, both modules into \$M2)"
[ -f "$M2/org/springframework/boot/spring-boot-starter-parent/4.1.1/spring-boot-starter-parent-4.1.1.pom" ] || die "Boot's parent POM is not in .m2-demo after the first build"
[ -f "$M2/org/graalvm/buildtools/native-maven-plugin/1.1.8/native-maven-plugin-1.1.8.jar" ] || die "GraalVM's native plugin 1.1.8 is not in .m2-demo after the first build (it is a build extension of the web module)"
[ -f "$ZIP" ] || die "GraalVM's metadata repository is not in .m2-demo after the first build - README.md, The repository"
[ -f "$M2/io/micrometer/micrometer-registry-prometheus/1.17.1/micrometer-registry-prometheus-1.17.1.jar" ] && [ -f "$MCORE" ] || die "Micrometer 1.17.1 (core, and the Prometheus registry) is not in .m2-demo after the first build"
echo "  .m2-demo holds Boot's parent, Micrometer 1.17.1 (core and the Prometheus registry), GraalVM's native plugin 1.1.8 and its metadata repository ($(wc -c < "$ZIP" | tr -d ' ') bytes)"

# ---- helpers ------------------------------------------------------------------------------------------------------------
# raw TOKEN FILE...: how many times TOKEN appears, raw, in the files (occurrences, not lines; binary files read as text)
raw() { local t=$1; shift; cat "$@" | LC_ALL=C grep -aoF -- "$t" | wc -l | tr -d ' '; }
SEEN=0                                               # how many answers saved on the way were counted for the token, raw
# first LOG: Boot's first log line, from its message on, cut before " with PID"
first() { grep -m1 ' : Starting ' "$1" | sed 's/^.* : //; s/ with PID .*$//'; }
# start 'COMMAND': print it exactly as typed, run it in the background (eval, from this folder; exec, so $pid is the program's
# own pid), its standard output to .harness/run.out and its standard error to .harness/run.err
start() { echo "\$ $1"; (eval "${1/&& /&& exec }") > .harness/run.out 2> .harness/run.err < /dev/null & pid=$!; }
# listening: what the operating system says the process listens on (lsof) - or what it listened on when it exited ("nothing")
listening() { local a="" i=0
  while [ $i -lt 240 ]; do
    a=$(lsof -nP -a -p "$pid" -iTCP -sTCP:LISTEN 2> /dev/null | awk 'NR > 1 { print $9 }' | sort -u | paste -sd' ' -)
    [ -n "$a" ] && break; kill -0 "$pid" 2> /dev/null || break; sleep 0.25; i=$((i + 1)); done
  echo "${a:-nothing}"; }
# up: the line after a start - where it listens, Boot's first line; dies if it never listened
up() { local l; l=$(listening); [ "$l" != nothing ] || { tail -20 .harness/run.out >&3; die "it never listened"; }
  echo "  listens on: $l"; echo "  Boot's first line: $(first .harness/run.out)"; }
# ask 'README curl LINE' PORT: the README's curl line, its port made PORT, printed and run; what it printed, indented
ask() { local c; c=$(url "$1" "$2"); echo "\$ $c"; (eval "$c") 2>&1 < /dev/null | sed 's/^/  /'; }
# status PATH PORT: the README's status-only line, its path made PATH and its port PORT, printed and run
status() { ask "$(path "$R_STATUS" "$1")" "$2"; }
# get DIR PORT 'README curl LINE': the README's line that writes a file (scrape.txt, metrics.json, beans.json), run from DIR -
# beside the run's config tree - its port made PORT; what curl prints (the status, and a content type), indented
get() { local c; c="cd $1 && $(url "$3" "$2")"; echo "\$ $c"; (eval "$c") 2>&1 < /dev/null | sed 's/^/  /'; }
# gone FILE: the token counted in a saved answer, raw, then the file deleted - the line says both
gone() { local t; t=$(raw "$TOKEN" "$1"); SEEN=$((SEEN + 1)); [ "$t" = 0 ] || die "$1 held the demo token, raw"
  rm -f "$1"; echo "  the demo token in it: $t · deleted: $([ -f "$1" ] && echo no || echo yes)"; }
# ready PORT: readiness asked until it answers 200 - every 0.25 s, up to 60 s, not printed - then the README's readiness line,
# printed and run once. No metrics assertion before it (brief S4.15): readiness holds the kitchen, and its database.
ready() { local i=0 c=""
  while [ $i -lt 240 ]; do c=$(curl -s -o /dev/null -w '%{http_code}' "http://127.0.0.1:$1/actuator/health/readiness" 2> /dev/null || true); [ "$c" = 200 ] && break
    kill -0 "$pid" 2> /dev/null || { tail -20 .harness/run.out >&3; die "it exited before readiness answered 200"; }; sleep 0.25; i=$((i + 1)); done
  [ "$c" = 200 ] || die "readiness never answered 200 on $1"
  ask "$R_READY" "$1"; }
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
# tbx FILE: a scrape's tiffinbox_ lines, in its own order - # HELP, # TYPE and the samples - each timer sum and max masked
tbx() { awk '/^# (HELP|TYPE|UNIT) tiffinbox_|^tiffinbox_/' "$1" | sed -E 's/^(tiffinbox_[a-z_]*_(sum|max)\{[^}]*\}) .*$/\1 <masked: a duration>/; s/^/  /'; }
# words FILE: the first word of every family a scrape declares (# TYPE), each once, sorted
words() { awk '/^# TYPE / { split($3, w, "_"); print w[1] }' "$1" | sort -u | paste -sd' ' -; }
# scraped FILE: what a scrape is made of, through the filter - its families' first words, its tiffinbox_ lines whole (sums and
# maxes masked), and three lines of one JVM family, its value masked; the rest is not printed (this computer's numbers: memory,
# threads, processors, the disk and the folder TiffinBox runs in), and counted as a bound - over 150, 162 to 169 here (RED C5-S4
# #21): its exact number moves (a collection adds jvm_gc_pause)
scraped() { local o
  echo "  its families' first words (# TYPE): $(words "$1")"
  echo "  its tiffinbox_ lines - $(tbx "$1" | wc -l | tr -d ' '), whole (a timer's sums and maxes masked):"
  tbx "$1" | sed 's/^/  /'
  echo "  three lines of one JVM family (its value masked: this computer's own):"
  grep -E '^# (HELP|TYPE) jvm_threads_live_threads |^jvm_threads_live_threads ' "$1" | sed -E 's/^(jvm_threads_live_threads) .*$/\1 <masked: this computer'"'"'s>/; s/^/    /'
  o=$(( $(wc -l < "$1") - $(tbx "$1" | wc -l) - 3 ))
  echo "  every other line: not printed (memory, threads, processors, a disk and its folder) - $( [ $o -gt 150 ] && echo 'over 150' || echo "$o, not over 150" ), a bound: a collection adds a family"; }
# names FILE: Actuator's metrics answer (its names) through a filter - their first words, each once; how many start http. and
# tiffinbox.; the tiffinbox. ones. Never the total (a collection adds jvm.gc.pause).
names() { python3 - "$1" <<'PY'
import json, sys
n = json.load(open(sys.argv[1]))["names"]
t = sorted(x for x in n if x.startswith("tiffinbox."))
print("  its names' first words: %s · names starting http.: %d · tiffinbox.: %d%s"
      % (" ".join(sorted(set(x.split(".")[0] for x in n))), sum(x.startswith("http.") for x in n), len(t), (" - " + " ".join(t)) if t else ""))
PY
}
# registry FILE: Actuator's beans answer through a filter - each bean whose name ends in MeterRegistry, and its class
registry() { python3 - "$1" <<'PY'
import json, sys
d = json.load(open(sys.argv[1]))
for c in sorted(d["contexts"]):
    for b, v in sorted(d["contexts"][c]["beans"].items()):
        if b.endswith("MeterRegistry"):
            print("  the registry bean: %s · %s" % (b, v["type"]))
PY
}
# meter FILE: one meter's metrics answer through a filter - its name, its COUNT, and the names of the tags it still offers
meter() { python3 - "$1" <<'PY'
import json, sys
d = json.load(open(sys.argv[1]))
m = {x["statistic"]: x["value"] for x in d["measurements"]}
print("  %s · COUNT %s · the tags it offers: %s" % (d["name"], m["COUNT"], " ".join(sorted(t["tag"] for t in d["availableTags"])) or "none"))
PY
}
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
  if [ -z "$pub" ]; then printf '  %-11s md5 %s  3/3  (no published hash)\n' "$nm" "$h"; unpub="$unpub $nm"
  elif [ "$pub" = "$h" ]; then printf '  %-11s md5 %s  3/3  = published\n' "$nm" "$h"
  else printf '  %-11s md5 %s  3/3  DIFFERS from the published %s\n' "$nm" "$h" "$pub"
    die "$nm is not the published capture - suspect another JDK, GraalVM, Boot or Maven, a busy machine, a busy port, a variable of yours, or an edited source; diff .r-$nm.out against its block in README.md"; fi; }
# copy SRC DEST: a tree copied without its target/ and secrets/, then a config tree of its own
copy() { rm -rf "$2" "$2".*; rsync -a --exclude target --exclude secrets "$1/" "$2/"; tree "$2"; }
# pbuild DIR 'LABEL': the README's plain Maven line, offline, from DIR
pbuild() { local c; c=$(off "$1" "$R_PLAIN" package); echo "\$ $c"; mbuild "$c" "$1.build.log" "$2"; }
# libs JAR: the names of the jars in an executable jar's BOOT-INF/lib, sorted
libs() { unzip -Z1 "$1" | sed -n 's|^BOOT-INF/lib/\(.*\.jar\)$|\1|p' | sort; }

# ---- before: the previous tree - the meters Actuator already keeps, and no scrape ------------------------------------------
before() {
  echo "the previous tree (the anchor as the health lesson left it), copied to .harness/prev with a config tree, built the README's"
  echo "plain way; run with the README's flag line - Actuator's metrics endpoints exposed for this run - port 19020:"
  copy "$PREV" .harness/prev
  pbuild .harness/prev "the previous tree"
  start "$(at .harness/prev 19020 "$R_WIDE")"; up; ready 19020
  echo "the scrape, exposed by the flag:"
  get .harness/prev 19020 "$R_SCRAPE"
  echo "  what it wrote: $(cat .harness/prev/scrape.txt)"; gone .harness/prev/scrape.txt
  echo "the meters' names:"
  get .harness/prev 19020 "$R_METRICS"; names .harness/prev/metrics.json; gone .harness/prev/metrics.json
  echo "the registry that keeps them:"
  get .harness/prev 19020 "$R_BEANS"; registry .harness/prev/beans.json; gone .harness/prev/beans.json
  echo "one request to TiffinBox, then the names again:"
  status /customers 19020
  get .harness/prev 19020 "$R_METRICS"; names .harness/prev/metrics.json; gone .harness/prev/metrics.json
  seven 19020 .harness/prev; }

# ---- change: the previous tree against after/ ---------------------------------------------------------------------------------
gained() { diff ".harness/before/$1" ".harness/after/$1" > .harness/file.diff || true
  echo "  $1 - the lines it gains that are neither comment nor blank:"
  sed -n 's/^> //p' .harness/file.diff | awk '{ t = $0; sub(/^[ \t]+/, "", t) } x { if (index(t, "-->")) x = 0; next } t ~ /^<!--/ { if (!index(t, "-->")) x = 1; next }
    t == "" || t ~ /^(\/\*\*|\*|\/\/|#)/ { next } { print "    " $0 }'
  echo "    (diff adds $(grep -c '^> ' .harness/file.diff || true) lines, removes $(grep -c '^< ' .harness/file.diff || true))"; }
# keys FILE 'LINE'...: each line's number in FILE (grep -n), its leading blanks cut - every one must be there
keys() { local f=$1 t; shift; for t in "$@"; do grep -nF -- "$t" "$f" | sed 's/^\([0-9]*\):[ \t]*/    \1: /' | grep . || die "change: $f no longer holds: $t"; done; }
change() { local f
  echo "the previous tree against after/, both copied under .harness/ - the files that differ:"
  echo "\$ diff -rq -x target -x secrets .harness/before .harness/after"
  diff -rq -x target -x secrets .harness/before .harness/after | sed 's/^/  /' || true
  gained "$POM"
  f=.harness/after/$KM
  echo "  $KM - new: $(wc -l < "$f" | tr -d ' ') lines · imports $(grep -c '^import ' "$f" || true) · comment lines $(awk '{ t = $0; sub(/^[ \t]+/, "", t) } t ~ /^(\/\*\*|\*|\/\/)/ { n++ } END { print n + 0 }' "$f") · blank $(grep -c '^[[:space:]]*$' "$f" || true) - its key lines (grep -n):"
  keys "$f" '@Component' '@RegisterReflection(classNames = "com.sun.management.OperatingSystemMXBean", memberCategories = MemberCategory.INVOKE_PUBLIC_METHODS)' \
    'public final class KitchenMetrics implements MeterBinder {' 'public void bindTo(MeterRegistry registry) {' \
    'FunctionCounter.builder("tiffinbox.orders.cooked", kitchen, OrderQueue::cooked)' 'FunctionCounter.builder("tiffinbox.orders.value", kitchen, OrderQueue::cookedValue)'
  diff ".harness/before/$SRV" ".harness/after/$SRV" > .harness/file.diff || true
  echo "  $SRV - diff adds $(grep -c '^> ' .harness/file.diff || true) lines, removes $(grep -c '^< ' .harness/file.diff || true) (the body of handle() moves into a try) - its key lines now (grep -n):"
  keys ".harness/after/$SRV" 'HttpHandler actuator, MeterRegistry registry) {' 'Timer.Sample sample = Timer.start(registry);' '} finally {' \
    'sample.stop(Timer.builder("tiffinbox.requests")' '.tag("route", handler != null ? key : "UNKNOWN")' '.tag("status", Integer.toString(exchange.getResponseCode()))'
  diff ".harness/before/$ROUTES" ".harness/after/$ROUTES" > .harness/file.diff || true
  echo "  $ROUTES - its code lines that changed (the comment above them changed too: diff adds $(grep -c '^> ' .harness/file.diff || true) lines, removes $(grep -c '^< ' .harness/file.diff || true)):"
  grep -E '^[<>] +byte\[\] body' .harness/file.diff | sed 's/^\([<>]\) */    \1 /'
  gained "$YAML"
  diff .harness/before/README.md .harness/after/README.md > .harness/file.diff || true
  echo "  README.md - the anchor's README: lines added $(grep -c '^> ' .harness/file.diff || true), removed $(grep -c '^< ' .harness/file.diff || true) - its new section (not shown)"
  echo "  tiffinbox-core against the previous tree's (diff -rq -x target): $(diff -rq -x target .harness/before/tiffinbox-core .harness/after/tiffinbox-core | wc -l | tr -d ' ') files differ"
  for f in "$APP" "$KHI"; do
    echo "  $(basename "$f") against the previous tree's, byte for byte: $(cmp -s ".harness/before/$f" ".harness/after/$f" && echo the same || echo different)"; done; }

# ---- scrape: after/, as the README builds and runs it - the scrape, both formats; the registry --------------------------------
scrape() { local n
  echo "after/, copied to .harness/serve with a config tree, built the README's plain way:"
  copy after .harness/serve
  pbuild .harness/serve "after/"
  libs ".harness/prev/$JAR" > .harness/libs.prev; libs ".harness/serve/$JAR" > .harness/libs.after
  echo "  its jar's BOOT-INF/lib against the previous tree's: $(wc -l < .harness/libs.prev | tr -d ' ') jars -> $(wc -l < .harness/libs.after | tr -d ' ') · added $(comm -13 .harness/libs.prev .harness/libs.after | wc -l | tr -d ' '): $(comm -13 .harness/libs.prev .harness/libs.after | paste -sd' ' -) · removed $(comm -23 .harness/libs.prev .harness/libs.after | wc -l | tr -d ' ')"
  echo "run as the README runs it - no flag: application.yaml exposes health and prometheus - port 19021:"
  start "$(at .harness/serve 19021 "$R_RUN")"; up; ready 19021
  echo "the scrape:"
  get .harness/serve 19021 "$R_SCRAPE"; scraped .harness/serve/scrape.txt; gone .harness/serve/scrape.txt
  echo "the same scrape, asked for in OpenMetrics:"
  get .harness/serve 19021 "$R_OPENM"
  echo "  its tiffinbox_ lines - $(tbx .harness/serve/scrape.txt | wc -l | tr -d ' '), whole:"; tbx .harness/serve/scrape.txt | sed 's/^/  /'
  echo "  its last line: $(tail -n 1 .harness/serve/scrape.txt)"; gone .harness/serve/scrape.txt
  echo "  and with the Accept header a Prometheus 3 server sends with every scrape (its default scrape protocols) - the README's line:"
  get .harness/serve 19021 "$R_PROM3"; gone .harness/serve/scrape.txt
  seven 19021 .harness/serve
  echo "the README's flag line - Actuator's metrics endpoints exposed for this run:"
  start "$(at .harness/serve 19021 "$R_WIDE")"; up; ready 19021
  get .harness/serve 19021 "$R_BEANS"; registry .harness/serve/beans.json; gone .harness/serve/beans.json
  get .harness/serve 19021 "$R_METRICS"; names .harness/serve/metrics.json; gone .harness/serve/metrics.json
  seven 19021 .harness/serve
  echo "C (labelled) - the bridge as the health lesson left it: a copy of after/ (.harness/oldbridge), its ActuatorRoutes.java the"
  echo "previous tree's - the code line that differs:"
  copy after .harness/oldbridge
  cp ".harness/before/$ROUTES" ".harness/oldbridge/$ROUTES"
  echo "\$ diff after/$ROUTES .harness/oldbridge/$ROUTES"
  diff "after/$ROUTES" ".harness/oldbridge/$ROUTES" > .harness/file.diff || true
  grep -E '^[<>] +byte\[\] body' .harness/file.diff | sed 's/^\([<>]\) */  \1 /'
  pbuild .harness/oldbridge "the copy"
  start "$(at .harness/oldbridge 19021 "$R_RUN")"; up; ready 19021
  get .harness/oldbridge 19021 "$R_SCRAPE"
  python3 - .harness/oldbridge/scrape.txt <<'PY2'
import base64, json, sys
b = open(sys.argv[1], "rb").read()
try:
    t = json.loads(b); ok = isinstance(t, str)
except ValueError:
    ok = False
print("  what it wrote - one JSON string: %s · its first 24 characters: %s" % ("yes" if ok else "no", b[:24].decode("ascii", "replace")))
if ok:
    print("  that string, decoded (base64) - its first line: %s" % base64.b64decode(t).decode("utf-8").split("\n", 1)[0])
PY2
  gone .harness/oldbridge/scrape.txt
  seven 19021 .harness/oldbridge; }

# ---- counter: the kitchen's own count, beside the scrape ---------------------------------------------------------------------
counter() {
  echo "after/'s jar (.harness/serve), run as the README runs it, port 19022:"
  start "$(at .harness/serve 19022 "$R_RUN")"; up; ready 19022
  ask "${R_CUSTOMERS/\/customers//kitchen}" 19022
  get .harness/serve 19022 "$R_SCRAPE"; grep -E '^tiffinbox_orders_' .harness/serve/scrape.txt | sed 's/^/  /'; gone .harness/serve/scrape.txt
  seven 19022 .harness/serve
  echo "the README's line with ten days instead of thirty:"
  start "$(at .harness/serve 19022 "$R_DAYS")"; up; ready 19022
  ask "${R_CUSTOMERS/\/customers//kitchen}" 19022
  get .harness/serve 19022 "$R_SCRAPE"; grep -E '^tiffinbox_orders_' .harness/serve/scrape.txt | sed 's/^/  /'; gone .harness/serve/scrape.txt
  seven 19022 .harness/serve; }

# ---- timer: every answer, timed --------------------------------------------------------------------------------------------
timer() {
  echo "after/'s jar (.harness/serve) with the README's flag line - the metrics endpoint exposed too - port 19023:"
  start "$(at .harness/serve 19023 "$R_WIDE")"; up; ready 19023
  echo "before TiffinBox has answered anything:"
  get .harness/serve 19023 "$R_SCRAPE"
  echo "  its tiffinbox_requests lines: $(grep -c '^tiffinbox_requests' .harness/serve/scrape.txt || true)"; gone .harness/serve/scrape.txt
  echo "the requests, one by one - the four routes, a path no route has, a verb the route does not take, the stop without its token:"
  status /customers 19023; status /revenue 19023; status /dashboard 19023; status /kitchen 19023; status /nowhere 19023; status /shutdown 19023
  ask "$R_FORBID" 19023
  echo "the scrape:"
  get .harness/serve 19023 "$R_SCRAPE"
  echo "  its tiffinbox_requests lines, whole (sums and maxes masked):"; tbx .harness/serve/scrape.txt | grep 'tiffinbox_requests' | sed 's/^/  /'
  echo "  series (one per _count line): $(grep -c '^tiffinbox_requests_seconds_count' .harness/serve/scrape.txt || true) · a series for /nowhere: $(grep -c 'nowhere' .harness/serve/scrape.txt || true)"
  gone .harness/serve/scrape.txt
  echo "C (labelled) - the metrics endpoint, the timer asked for alone, then filtered by a tag (Boot's ?tag=):"
  get .harness/serve 19023 "${R_TAG/\?tag=status:405/}"; meter .harness/serve/metrics.json; gone .harness/serve/metrics.json
  get .harness/serve 19023 "$R_TAG"; meter .harness/serve/metrics.json; gone .harness/serve/metrics.json
  seven 19023 .harness/serve; }

# ---- cardinality: the break - what the route tag holds -----------------------------------------------------------------------
four() { local u; for u in /customers/7 /customers/8 /customers /customersXYZ; do status "$u" 19024; done
  get "$1" 19024 "$R_SCRAPE"
  echo "  its tiffinbox_requests_seconds_count lines:"; grep '^tiffinbox_requests_seconds_count' "$1/scrape.txt" | sed 's/^/    /'
  echo "  series: $(grep -c '^tiffinbox_requests_seconds_count' "$1/scrape.txt" || true)"; gone "$1/scrape.txt"
  seven 19024 "$1"; }
cardinality() {
  echo "the break: what the route tag holds. Four URLs in every run - three no route declares; port 19024."
  echo "A - after/'s jar (.harness/serve), as the README runs it (the tag: the route TiffinBox declares):"
  start "$(at .harness/serve 19024 "$R_RUN")"; up; ready 19024
  four .harness/serve
  echo "B - a copy of after/ (.harness/rawtag) whose tag holds the raw path, as the client typed it - the one line that differs:"
  copy after .harness/rawtag
  sed -i '' 's|\.tag("route", handler != null ? key : "UNKNOWN")|.tag("route", exchange.getRequestMethod() + " " + exchange.getRequestURI().getPath())|' ".harness/rawtag/$SRV"
  echo "\$ diff after/$SRV .harness/rawtag/$SRV"
  diff "after/$SRV" ".harness/rawtag/$SRV" | sed 's/^/  /' || true
  pbuild .harness/rawtag "the copy"
  start "$(at .harness/rawtag 19024 "$R_RUN")"; up; ready 19024
  four .harness/rawtag
  echo "A' - A again:"
  start "$(at .harness/serve 19024 "$R_RUN")"; up; ready 19024
  four .harness/serve; }

# ---- native: after/, built natively; the AOT jar and the binary; the hint taken out ------------------------------------------
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
# against the bound (1 minute or more, under 20 minutes: this Mac's native builds took up to 8 under load), and the network
# (offline: nbuild stopped the run if the plugin went out)
nresult() { echo "  exit $NB_E · $(grep -m1 -oE 'BUILD (SUCCESS|FAILURE)' "$1" || echo 'no BUILD line') · stages it printed: $(grep -cE '^\[[1-8]/8\] ' "$1" || true) of the $(grep -m1 -oE '^\[1/[0-9]+\]' "$1" | sed 's/.*\///; s/]//') it announces · its duration, against the bound: $( [ $NB_S -ge 60 ] && echo '1 minute or more' || echo 'under 1 minute' ), $( [ $NB_S -lt 1200 ] && echo 'under 20 minutes' || echo '20 minutes or more' ) · offline: yes"; }
# served DIR PORT: after a start - readiness, one request, the scrape's status and tiffinbox_ samples; the seven
# procs FILE: the process_ families a scrape declares (# TYPE), their names only
procs() { awk '/^# TYPE process_/ { print $3 }' "$1" | paste -sd' ' -; }
served() { ready "$2"; status /customers "$2"
  get "$1" "$2" "$R_SCRAPE"; echo "  its process_ families: $(procs "$1/scrape.txt")"
  echo "  its tiffinbox_ samples (sums and maxes masked):"; tbx "$1/scrape.txt" | grep -v '^  #' | sed 's/^/  /'; gone "$1/scrape.txt"; }
# variant DIR 'SED' 'WHAT': after/ copied to DIR, KitchenMetrics.java changed by SED (the diff shown), built natively; its binary
# run, readiness, one request, the scrape - its status and what it wrote - and the seven
variant() {
  copy after "$1"
  sed -i '' "$2" "$1/$KM"
  echo "\$ diff after/$KM $1/$KM"
  diff "after/$KM" "$1/$KM" | sed 's/^/  /' || true
  nbuild "$1"; nresult "$1.native.log"
  echo "  its binary - the README's line, port 19025:"
  start "$(at "$1" 19025 "$R_BIN")"; up; ready 19025; status /customers 19025
  get "$1" 19025 "$R_SCRAPE"
  if [ "$(head -c 1 "$1/scrape.txt")" = "{" ]; then echo "  what it wrote: $(cat "$1/scrape.txt")"
  else echo "  a scrape - its process_ families: $(procs "$1/scrape.txt")"
    echo "  its tiffinbox_ samples (sums and maxes masked):"; tbx "$1/scrape.txt" | grep -v '^  #' | sed 's/^/  /'; fi
  gone "$1/scrape.txt"
  seven 19025 "$1"; }
native() {
  echo "after/, copied to .harness/nat with a config tree; the README's two Maven lines, offline; \$GRAALVM_HOME names the GraalVM:"
  copy after .harness/nat
  nbuild .harness/nat
  nlines .harness/nat.native.log
  nresult .harness/nat.native.log
  echo "  file: $(file -b ".harness/nat/$BIN" | sed 's/ [A-Za-z0-9_]*$//') · the demo token in its bytes: $(raw "$TOKEN" ".harness/nat/$BIN")"
  echo "the AOT jar - the README's AOT line, port 19025:"
  start "$(at .harness/nat 19025 "$R_AOTRUN")"; up; served .harness/nat 19025
  seven 19025 .harness/nat
  echo "the binary - the README's line:"
  start "$(at .harness/nat 19025 "$R_BIN")"; up; served .harness/nat 19025
  seven 19025 .harness/nat all
  echo "Micrometer's own native-image metadata - micrometer-core 1.17.1's reflect-config.json, read from \$M2 - for com.sun.management:"
  python3 - "$MCORE" <<'PY'
import json, sys, zipfile
z = zipfile.ZipFile(sys.argv[1])
d = json.loads(z.read("META-INF/native-image/io.micrometer/micrometer-core/reflect-config.json"))
for e in d:
    if e["name"].startswith("com.sun.management."):
        print("  %s: %s" % (e["name"], " ".join(sorted(m["name"] for m in e.get("methods", [])))))
names = [m["name"] for e in d if e["name"] == "com.sun.management.OperatingSystemMXBean" for m in e.get("methods", [])]
pm = z.read("io/micrometer/core/instrument/binder/system/ProcessorMetrics.class")
print("  getProcessCpuTime - named in Micrometer's ProcessorMetrics class: %s · listed in its metadata: %s"
      % ("yes" if b"getProcessCpuTime" in pm else "no", "yes" if "getProcessCpuTime" in names else "no"))
PY
  echo "B - the hint taken out: a copy of after/ (.harness/nat-none), its @RegisterReflection line deleted:"
  variant .harness/nat-none '/^@RegisterReflection(/d'
  echo "C (labelled) - B's binary, the README's line that switches the CPU-time meter off (process.cpu.time):"
  start "$(at .harness/nat-none 19025 "$R_CPUOFF")"; up; ready 19025; status /customers 19025
  get .harness/nat-none 19025 "$R_SCRAPE"; echo "  its process_ families: $(procs .harness/nat-none/scrape.txt)"
  echo "  its tiffinbox_ samples (sums and maxes masked):"; tbx .harness/nat-none/scrape.txt | grep -v '^  #' | sed 's/^/  /'; gone .harness/nat-none/scrape.txt
  seven 19025 .harness/nat-none
  echo "A' - A's binary again (.harness/nat, built above) - the README's line:"
  start "$(at .harness/nat 19025 "$R_BIN")"; up; served .harness/nat 19025
  seven 19025 .harness/nat
  echo "D (labelled) - the other interface's name in its place: a copy of after/ (.harness/nat-unix):"
  variant .harness/nat-unix 's|classNames = "com.sun.management.OperatingSystemMXBean"|classNames = "com.sun.management.UnixOperatingSystemMXBean"|'; }

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
  echo "  exit $ec · listening on 19029 now: $(listeners 19029)"; }

cap before before
cap change change
cap scrape scrape
cap counter counter
cap timer timer
cap cardinality cardinality
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
# has 'TEXT' 'LINE' MESSAGE: TEXT (a variable holding a capture's block) holds the line, whole
has() { printf '%s\n' "$1" | grep -qxF -- "$2" || die "$3: expected the line: $2"; }
# THE TOKEN: no capture holds the demo token, raw - counted on each run's own output BEFORE masking - and neither does any answer
# saved on the way (gone() died on one), anything this unit ships for reading, nor the binaries this run built
for f in .harness/raw-*; do [ "$(cat "$f")" = 0 ] || die "a capture's raw output held the demo token ($f)"; done
NBIN=0
for f in .r-*.out README.md exercise/README.md exercise/solution/SOLUTION.md receipts.md5 harness/shutdown.sh after/README.md "after/$YAML" "after/$KM" "after/$SRV" "after/$ROUTES" .harness/nat/$BIN .harness/nat-none/$BIN .harness/nat-unix/$BIN; do
  [ -f "$f" ] || continue; case $f in .harness/nat*) NBIN=$((NBIN + 1)) ;; esac
  [ "$(raw "$TOKEN" "$f")" = 0 ] || die "$f holds the demo token, raw"; done
[ "$NBIN" = 3 ] || die "three binaries were built, $NBIN were checked"
for f in .r-*.out; do ! grep -qE '/Users/|/private/|/home/|/var/folders/' "$f" || die "$f holds an absolute path"; ! grep -qF "$GRAALVM_HOME" "$f" || die "$f holds the GraalVM's folder"; ! grep -qE 'c[0-9]-unit[0-9]|unit ?[0-9]' "$f" || die "$f holds a unit number"; ! grep -qE '^(jvm|process|system|disk|executor|application)_[a-z_]*(\{[^}]*\})? [0-9]' "$f" || die "$f holds a machine meter's value"; done
[ -z "$(find .harness \( -name scrape.txt -o -name metrics.json -o -name beans.json \) | head -1)" ] || die "an answer saved on the way was left under .harness/"
echo "  token: 0 raw copies in $(ls .harness/raw-* | wc -l | tr -d ' ') raw capture runs, in $(ls .r-*.out | wc -l | tr -d ' ') captures, in the $SEEN answers saved on the way (each counted, then deleted), the READMEs, the harness, receipts.md5 and the three binaries; no absolute path, no GraalVM folder, no unit number, no machine meter's value in any capture"
# S4.16: no star in an exposure list anywhere in this unit - its scripts, its READMEs, its captures
for f in receipts.sh README.md exercise/README.md exercise/solution/SOLUTION.md .r-*.out; do
  [ -f "$f" ] || continue
  ! grep -nE "exposure\.include='?\*" "$f" | grep -vF 'grep -nE "exposure' | grep -q . || die "$f: a star in an exposure list"; done
# "Actuator already keeps meters ... JVM, process, system, Logback, disk, in a registry ... a simple one. Not one is TiffinBox's,
# and none is http, even after a request ... Slash actuator slash prometheus: four hundred four, even exposed."
BE=$(blk before 'the scrape, exposed by the flag:' '')
has "$BE" "  404 application/json" "before: the scrape 404"
has "$BE" '  what it wrote: {"error":"not found"}' "before: the bridge's 404"
W0='  its names'"'"' first words: application disk executor jvm logback process system · names starting http.: 0 · tiffinbox.: 0'
[ "$(printf '%s\n' "$BE" | grep -cxF -- "$W0")" = 2 ] || die "before: the names' first words, no http., no tiffinbox. - before and after a request"
has "$BE" "  the registry bean: simpleMeterRegistry · io.micrometer.core.instrument.simple.SimpleMeterRegistry" "before: the registry"
has "$BE" "  200" "before: the request"
x before "^\\\$ cd \\.harness/prev && java -jar tiffinbox-web/target/tiffinbox-web-1\\.0\\.0\\.jar --tiffinbox\\.port=19020 --management\\.endpoints\\.web\\.exposure\\.include=health,prometheus,metrics,beans\$"
[ "$(n before "^  exit 0 · the seven responses: 7 lines · md5 $S115\$")" = 1 ] || die "before: the seven"
x before ' · offline: yes · exit 0$'
echo "  before: prometheus 404 even exposed · names: application disk executor jvm logback process system - no http., no tiffinbox., before and after a request · SimpleMeterRegistry"

# "One dependency, Micrometer's Prometheus registry. One new bean, KitchenMetrics, registers two function counters ... So
# tiffinbox-core doesn't change at all ... a timer around every answer ... tagged with the route and the status. Exposure gains
# prometheus." "One more line, in the bridge ... bytes go out as they are."
[ "$(n change '^  (Files |Only in )')" = 6 ] || die "change: six entries in diff -rq"
x change '^  Only in \.harness/after/tiffinbox-web/src/main/java/com/tiffinbox/web: KitchenMetrics\.java$'
PO=$(blk change '  tiffinbox-web/pom.xml - the lines it gains' '  tiffinbox-web/src/main/java/com/tiffinbox/web/KitchenMetrics.java - new')
[ "$(printf '%s\n' "$PO" | sed 's/^ *//' | paste -sd'|' -)" = "<dependency>|<groupId>io.micrometer</groupId>|<artifactId>micrometer-registry-prometheus</artifactId>|</dependency>|(diff adds 8 lines, removes 0)" ] || die "change: the POM gains the one dependency, no version"
x change '^  tiffinbox-web/src/main/java/com/tiffinbox/web/KitchenMetrics\.java - new: [0-9]+ lines · imports 7 · comment lines [0-9]+ · blank [0-9]+ - its key lines \(grep -n\):$'
[ "$(n change '^    [0-9]+: FunctionCounter\.builder\("tiffinbox\.orders\.(cooked|value)", kitchen, OrderQueue::cooked(Value)?\)$')" = 2 ] || die "change: two FunctionCounters over the kitchen's getters"
x change '^    [0-9]+: public final class KitchenMetrics implements MeterBinder \{$'
x change '^    [0-9]+: @RegisterReflection\(classNames = "com\.sun\.management\.OperatingSystemMXBean", memberCategories = MemberCategory\.INVOKE_PUBLIC_METHODS\)$'
x change '^    [0-9]+: Timer\.Sample sample = Timer\.start\(registry\);$'
x change '^    [0-9]+: \.tag\("route", handler != null \? key : "UNKNOWN"\)$'
x change '^    [0-9]+: \.tag\("status", Integer\.toString\(exchange\.getResponseCode\(\)\)\)$'
x change '^    > byte\[\] body = value == null \? new byte\[0\] : value instanceof byte\[\] bytes \? bytes$'
x change '^            include: health,prometheus$'
x change '^  tiffinbox-core against the previous tree.s \(diff -rq -x target\): 0 files differ$'
for t in TiffinBoxApp KitchenHealthIndicator; do x change "^  $t\\.java against the previous tree.s, byte for byte: the same\$"; done
[ "$(diff -rq -x target -x secrets "$PREV" after | wc -l | tr -d ' ')" = 6 ] || die "change: after/ differs from the previous tree in more than the README, the POM, the YAML, the server, the bridge and the new class"
[ -z "$(diff -rq -x target "$PREV/tiffinbox-core" after/tiffinbox-core)" ] || die "tiffinbox-core changed: it may not (brief ⚑5)"
cmp -s "after/$APP" "$PREV/$APP" || die "TiffinBoxApp.java changed: it may not (brief ⚑11)"
echo "  change: one dependency (no version) · KitchenMetrics new (MeterBinder, 2 FunctionCounters, the hint) · the timer, route and status · bytes in the bridge · health,prometheus · core: 0 files"

# "Prometheus reads an application by scraping it ... the old bridge wrote them as JSON, a quoted base64 string." "Seven more
# jars ... two hundred, plain text. Each meter is a family: a HELP line, a TYPE line, its samples. Dots become underscores, and a
# counter gains underscore total: one hundred twenty. A gauge ... the JVM's live threads, masked." "Ask for OpenMetrics ... the
# family loses underscore total, the sample keeps it, and the page ends with EOF."
x scrape '^  its jar.s BOOT-INF/lib against the previous tree.s: 39 jars -> 46 · added 7: micrometer-registry-prometheus-1\.17\.1\.jar prometheus-metrics-config-1\.7\.0\.jar prometheus-metrics-core-1\.7\.0\.jar prometheus-metrics-exposition-formats-1\.7\.0\.jar prometheus-metrics-exposition-textformats-1\.7\.0\.jar prometheus-metrics-model-1\.7\.0\.jar prometheus-metrics-tracer-common-1\.7\.0\.jar · removed 0$'
SC=$(blk scrape 'the scrape:' 'the same scrape, asked for in OpenMetrics:'); SO=$(blk scrape 'the same scrape, asked for in OpenMetrics:' "the README's flag line"); SR=$(blk scrape "the README's flag line" 'C (labelled)'); SB=$(blk scrape 'C (labelled)' '')
has "$SC" "  200 text/plain;version=0.0.4;charset=utf-8" "scrape: the text format"
for l in "# HELP tiffinbox_orders_cooked_total Orders the kitchen cooked" "# TYPE tiffinbox_orders_cooked_total counter" "tiffinbox_orders_cooked_total 120.0" "# TYPE tiffinbox_orders_value_total counter" "tiffinbox_orders_value_total 24300.0" "# TYPE jvm_threads_live_threads gauge" "jvm_threads_live_threads <masked: this computer's>"; do has "$SC" "    $l" "scrape: the text format's lines"; done
has "$SC" "  its families' first words (# TYPE): application disk executor jvm logback process system tiffinbox" "scrape: the families"
has "$SO" "  200 application/openmetrics-text;version=1.0.0;charset=utf-8" "scrape: OpenMetrics"
has "$SO" "    # TYPE tiffinbox_orders_cooked counter" "scrape: OpenMetrics, no _total in the family"
has "$SO" "    tiffinbox_orders_cooked_total 120.0" "scrape: OpenMetrics, the sample keeps _total"
has "$SO" "  its last line: # EOF" "scrape: # EOF"
has "$SR" "  the registry bean: prometheusMeterRegistry · io.micrometer.prometheusmetrics.PrometheusMeterRegistry" "scrape: the registry"
has "$SR" "  its names' first words: application disk executor jvm logback process system tiffinbox · names starting http.: 0 · tiffinbox.: 2 - tiffinbox.orders.cooked tiffinbox.orders.value" "scrape: the names"
has "$SB" "  200 text/plain;version=0.0.4;charset=utf-8" "scrape: the old bridge's content type"
has "$SB" '  what it wrote - one JSON string: yes · its first 24 characters: "IyBIRUxQIGFwcGxpY2F0aW9' "scrape: the old bridge wrote JSON"
has "$SB" "  that string, decoded (base64) - its first line: # HELP application_ready_time_seconds Time taken for the application to be ready to service requests" "scrape: base64 of the scrape"
[ "$(n scrape "^  exit 0 · the seven responses: 7 lines · md5 $S115\$")" = 3 ] || die "scrape: the seven, three times"
echo "  scrape: 39 -> 46 jars (+7) · 200 text/plain;version=0.0.4 · counter, _total, 120.0 · a gauge · OpenMetrics: no _total in the family, # EOF · PrometheusMeterRegistry · the old bridge: one JSON string, base64"

# "Slash kitchen says one hundred twenty orders, twenty-four thousand three hundred in value, and the scrape says the same. Start
# with ten days instead of thirty: forty, and eight thousand one hundred."
CA=$(blk counter "after/'s jar" "the README's line with ten days"); CB=$(blk counter "the README's line with ten days" '')
has "$CA" '  {"ordersCooked":120,"ordersValue":24300} 200' "counter: /kitchen"; has "$CA" "  tiffinbox_orders_cooked_total 120.0" "counter: 120"; has "$CA" "  tiffinbox_orders_value_total 24300.0" "counter: 24300"
has "$CB" '  {"ordersCooked":40,"ordersValue":8100} 200' "counter: /kitchen, 10 days"; has "$CB" "  tiffinbox_orders_cooked_total 40.0" "counter: 40"; has "$CB" "  tiffinbox_orders_value_total 8100.0" "counter: 8100"
has "$CA" "  exit 0 · the seven responses: 7 lines · md5 $S115" "counter: the seven"
DAYSMD5=$(printf '%s\n' "$CB" | sed -n 's/^  exit 0 · the seven responses: 7 lines · md5 \([0-9a-f]*\)$/\1/p'); [ -n "$DAYSMD5" ] && [ "$DAYSMD5" != "$S115" ] || die "counter: ten days must change the seven (/kitchen)"
echo "  counter: /kitchen 120 and 24300 = the scrape's · ten days: 40 and 8100 = the scrape's"

# "Before the first answer, the scrape has no timer line ... Send the four routes, a path nobody declared, a GET to the shutdown
# route, and a POST without the token. Each route and status gets its own series ... a count and a sum in seconds, a summary, plus
# a max gauge. The wrong verb lands under UNKNOWN, four hundred five. Slash nowhere isn't timed."
x timer '^  its tiffinbox_requests lines: 0$'
TI=$(blk timer 'the requests, one by one' 'C (labelled)')
[ "$(printf '%s\n' "$TI" | grep -cxF '  200')" = 4 ] && has "$TI" "  404" "timer: /nowhere" && has "$TI" "  405" "timer: GET /shutdown" && has "$TI" '  {"error":"forbidden"} 403' "timer: POST without the token" || die "timer: the statuses"
has "$TI" "    # TYPE tiffinbox_requests_seconds summary" "timer: a summary"; has "$TI" "    # TYPE tiffinbox_requests_seconds_max gauge" "timer: max, a gauge"
for r in 'GET /customers",status="200' 'GET /dashboard",status="200' 'GET /kitchen",status="200' 'GET /revenue",status="200' 'POST /shutdown",status="403' 'UNKNOWN",status="405'; do has "$TI" "    tiffinbox_requests_seconds_count{route=\"$r\"} 1" "timer: one count per route and status"; done
has "$TI" "  series (one per _count line): 6 · a series for /nowhere: 0" "timer: six series, none for /nowhere"
[ "$(printf '%s\n' "$TI" | grep -c '_sum{.*} <masked: a duration>$')" = 6 ] && [ "$(printf '%s\n' "$TI" | grep -c '_max{.*} <masked: a duration>$')" = 6 ] || die "timer: six sums and six maxes, masked"
# C: Boot's ?tag= reaches the operation through the bridge (the Actuator lesson's merge of the query string - RED C5-S4 #2)
[ "$(n timer '^  tiffinbox\.requests · COUNT 6\.0 · the tags it offers: route status$')" = 1 ] || die "timer: the timer alone - COUNT 6.0, two tags"
[ "$(n timer '^  tiffinbox\.requests · COUNT 1\.0 · the tags it offers: route$')" = 1 ] || die "timer: ?tag=status:405 must filter - COUNT 1.0, the route tag left"
x timer "^  exit 0 · the seven responses: 7 lines · md5 $S115\$"
echo "  timer: no line before the first answer · 6 series (4 routes, UNKNOWN 405, POST 403), summary + max gauge, /nowhere none · ?tag=status:405 filters: COUNT 6.0, then 1.0"

# "A: the tag holds the route ... one series, four. B: a copy that tags the raw path ... Four URLs, four series. A again: one."
KA=$(blk cardinality 'A - after/' 'B - a copy'); KB=$(blk cardinality 'B - a copy' "A' - A again:"); KA2=$(blk cardinality "A' - A again:" '')
for b in "$KA" "$KA2"; do has "$b" '    tiffinbox_requests_seconds_count{route="GET /customers",status="200"} 4' "cardinality A: one series, 4"; has "$b" "  series: 1" "cardinality A: 1"; done
has "$KB" "  series: 4" "cardinality B: 4 series"
for r in '/customers' '/customers/7' '/customers/8' '/customersXYZ'; do has "$KB" "    tiffinbox_requests_seconds_count{route=\"GET $r\",status=\"200\"} 1" "cardinality B: a series per URL"; done
has "$KB" '  >                     .tag("route", exchange.getRequestMethod() + " " + exchange.getRequestURI().getPath())' "cardinality B: the flip"
[ "$(printf '%s\n' "$KA" | grep '^\$ cd ')" = "$(printf '%s\n' "$KA2" | grep '^\$ cd ')" ] || die "cardinality: A' is not A's command"
[ "$(n cardinality '^  200$')" = 12 ] || die "cardinality: twelve requests, each 200"
[ "$(n cardinality "^  exit 0 · the seven responses: 7 lines · md5 $S115\$")" = 3 ] || die "cardinality: the seven, three times"
echo "  cardinality: A 1 series (4) · B 4 series · A' 1 series (4) · every URL 200"
# "Built ahead of time, the AOT jar and the native binary serve the seven responses and the scrape, the kitchen's counters and the
# timer included." "Micrometer ... its own native metadata lists three of that interface's methods, not the one its CPU-time meter
# calls. Hint out: five hundred, a missing registration. Switch that meter off, and the scrape answers again. The Unix interface's
# name works too: it inherits the method."
NRES='^  exit 0 · BUILD SUCCESS · stages it printed: 8 of the 8 it announces · its duration, against the bound: 1 minute or more, under 20 minutes · offline: yes$'
[ "$(n native "$NRES")" = 3 ] || die "native: three native builds, each 8 of 8, inside the bound, offline"
[ "$(n native '^  built \.harness/nat(-none|-unix)? \(both modules, into \$M2\) · offline: yes · exit 0$')" = 3 ] || die "native: three installs, offline"
x native '^  file: Mach-O 64-bit executable · the demo token in its bytes: 0$'
PROCS='  its process_ families: process_cpu_time_ns_total process_cpu_usage process_files_max_files process_files_open_files process_start_time_seconds process_uptime_seconds'
NAOT=$(blk native 'the AOT jar - ' 'the binary - '); NBIN=$(blk native 'the binary - ' "Micrometer's own native-image metadata")
for b in "$NAOT" "$NBIN"; do
  printf '%s\n' "$b" | grep -q "^  Boot's first line: Starting AOT-processed TiffinBoxServer" || die "native: AOT-processed"
  has "$b" "  200 text/plain;version=0.0.4;charset=utf-8" "native: the scrape"; has "$b" "$PROCS" "native: the CPU-time meter there"
  for l in "    tiffinbox_orders_cooked_total 120.0" "    tiffinbox_orders_value_total 24300.0" '    tiffinbox_requests_seconds_count{route="GET /customers",status="200"} 1'; do has "$b" "$l" "native: the kitchen's counters and the timer"; done
  has "$b" "  exit 0 · the seven responses: 7 lines · md5 $S115" "native: the seven"; done
x native '^  com\.sun\.management\.OperatingSystemMXBean: getCpuLoad getProcessCpuLoad getSystemCpuLoad$'
x native "^  getProcessCpuTime - named in Micrometer's ProcessorMetrics class: yes · listed in its metadata: no\$"
NNONE=$(blk native 'B - the hint taken out' "A' - A's binary again"); NAA=$(blk native "A' - A's binary again" 'D (labelled) - the other interface'); NUNIX=$(blk native 'D (labelled) - the other interface' '')
has "$NNONE" '  < @RegisterReflection(classNames = "com.sun.management.OperatingSystemMXBean", memberCategories = MemberCategory.INVOKE_PUBLIC_METHODS)' "native: the hint's line deleted"
has "$NNONE" "  500 application/json" "native: hint out, 500"
has "$NNONE" '  what it wrote: {"error":"MissingReflectionRegistrationError"}' "native: hint out, the error's name"
has "$NNONE" "\$ cd .harness/nat-none && tiffinbox-web/target/tiffinbox-web --tiffinbox.port=19025 --management.metrics.enable.process.cpu.time=false" "native: the CPU-time switch"
has "$NNONE" "  its process_ families: process_cpu_usage process_files_max_files process_files_open_files process_start_time_seconds process_uptime_seconds" "native: CPU time off, 200 without it"
[ "$(printf '%s\n' "$NNONE" | grep -cxF "  200 text/plain;version=0.0.4;charset=utf-8")" = 1 ] || die "native: hint out, the scrape answers again only with the meter off"
has "$NUNIX" '  > @RegisterReflection(classNames = "com.sun.management.UnixOperatingSystemMXBean", memberCategories = MemberCategory.INVOKE_PUBLIC_METHODS)' "native: the Unix name"
has "$NUNIX" "  200 text/plain;version=0.0.4;charset=utf-8" "native: the Unix name, 200"
has "$NUNIX" "  a scrape - its process_ families: process_cpu_time_ns_total process_cpu_usage process_files_max_files process_files_open_files process_start_time_seconds process_uptime_seconds" "native: the Unix name, every process family"
# A' = A: the same binary, the same answers (RED C5-S4 #19: a flipped attribute is shown A, B, A')
has "$NAA" "\$ cd .harness/nat && tiffinbox-web/target/tiffinbox-web --tiffinbox.port=19025" "native A': A's binary, the README's line"
has "$NAA" "  200 text/plain;version=0.0.4;charset=utf-8" "native A': 200"
has "$NAA" "  its process_ families: process_cpu_time_ns_total process_cpu_usage process_files_max_files process_files_open_files process_start_time_seconds process_uptime_seconds" "native A': every process family"
for l in "    tiffinbox_orders_cooked_total 120.0" "    tiffinbox_orders_value_total 24300.0" '    tiffinbox_requests_seconds_count{route="GET /customers",status="200"} 1'; do has "$NAA" "$l" "native A': the kitchen's counters and the timer"; done
has "$NAA" "  exit 0 · the seven responses: 7 lines · md5 $S115" "native A': the seven"
[ "$(n native "^  exit 0 · the seven responses: 7 lines · md5 $S115\$")" = 6 ] || die "native: the seven, six times (the AOT jar, the binary, B, C, A', D)"
echo "  native: 3 builds, 8 of 8, offline · the AOT jar and the binary: 200, process_cpu_time, 120 / 24300 / the timer, 115c36ba... · metadata: 3 methods, not getProcessCpuTime · B, hint out: 500 MissingReflectionRegistrationError; C, B with CPU time off: 200 · A' = A: 200, every process family · D, the Unix name: 200"

# the exercise's end state: the line exercise/README.md calls "Done" is a line of this capture, after the solution's line - and of
# SOLUTION.md's measured run
XE=$(blk exercise "the solution's line" '')
l='tiffinbox_requests_seconds_count{route="UNKNOWN",status="405"} 3'
has "$XE" "$l" "exercise"
[ "$(printf '%s\n' "$XE" | grep -c '^tiffinbox_requests_seconds_count')" = 1 ] || die "exercise: one series"
awk '/^\*\*Done\*\*/ { f = 1 } f' exercise/README.md | grep -qxF -- "$l" || die "exercise/README.md: Done names no such line"
grep -qxF -- "$l" exercise/solution/SOLUTION.md || die "SOLUTION.md: the measured run shows no such line"
x exercise '^  exit 0 · printed: 0 line\(s\)$'
x exercise '^POST /shutdown -> 200 · curl exit 0$'
x exercise '^  exit 0 · listening on 19029 now: 0$'
echo "  exercise: the README as written, then the solution's line -> three verbs, one series: UNKNOWN 405, 3"

# the anchor's README states the same numbers
for t in '`tiffinbox_orders_cooked_total 120.0`' '`# EOF`' '`route="GET /customers"`, `4`' '`{"error":"MissingReflectionRegistrationError"}`' '`{"ordersCooked":120,"ordersValue":24300}`' 'with `--tiffinbox.days=10`, 40 and' 'from 39 jars to 46'; do
  grep -qF -- "$t" after/README.md || die "after/README.md no longer states: $t"; done
cmp -s after/README.md ../c5-tiffinbox/README.md || echo "  (after/README.md and ../c5-tiffinbox/README.md differ - the anchor has moved past this unit's after/: it is unit 27's after/ now)" >&3
[ -z "$unpub" ] || die "no published hash for:$unpub - check the captures, then copy the md5s above into receipts.md5 and run again"
echo "c5-unit23: every capture 3/3 and = published; every spoken number asserted; 0 raw demo tokens in every capture and every saved answer"
