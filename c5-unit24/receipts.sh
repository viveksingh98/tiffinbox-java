#!/bin/bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25.0.4.1 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# GRAALVM_HOME names a GraalVM JDK 25 (README.md, "The GraalVM"): the native build reads it. Without it, this script makes every
# capture that needs no GraalVM - the JVM's, and the exercise's - filling .m2-demo on the way, then stops before the native build.
# Course 5 · Logging in Boot - this unit's receipts. TiffinBox logged nothing per request, even at DEBUG, and nothing changed a
# level while it ran: a level meant a restart. The anchor change (brief ⚑6): TiffinBoxServer.java (handle()'s finally logs one
# line per answer at DEBUG through TiffinBox's own System.Logger - the route and the status the timer tags, before the timer
# stops) and application.yaml (logging.group.kitchen: tiffinbox, com.tiffinbox). The loggers endpoint is exposed by a flag, for
# one run (⚑3), never in application.yaml. Ten captures, each run three times and hashed; cap() DIES when a hash differs from
# receipts.md5; every number the video says is asserted at the bottom by a check that can fail; the demo token is masked (gsub),
# and the checks count 0 raw copies of it in every capture, in the log of every run (with the shutdown header's name: 0), in every
# answer saved on the way, in every file this unit ships, and in the binary it builds.
#   before    the previous tree with the first lesson's flag (TiffinBox's own logger at DEBUG from the start): the loggers
#             endpoint 404, the seven, then its log - DEBUG lines by logger: the route lines at start, 0 for the answers
#   change    the previous tree against after/: the files that differ, TiffinBoxServer.java's key lines (the DEBUG line, before
#             the timer stops), what application.yaml gains, the POM's one removed line and the two Java logging files, gone;
#             everything else byte for byte
#   path      after/ built and extracted, run with the harness's Road joined and the README's loggers flag: java.util.logging's
#             root handler, Logback's root appender and listeners; the README's POST to DEBUG and back, each seen by Road from
#             Logback, java.util.logging and System.Logger, and one request after each; then C (labelled): the root to DEBUG
#             after the group's null - and on a fresh process
#   files     the two Java logging files of Course 3 and the exec plugin's argument, measured on the previous tree, which still
#             ships them: A the README's line with the debug file, Road joined (what java.util.logging read, what Boot left);
#             B the README's exec:exec line (logging.properties); both read for the file's own output - standard error, its
#             bare format; C (labelled) the harness's Jul, no Boot, with each file: that output, counted the same way; then
#             retired here - after/ holds neither file nor the argument, and the exec line still serves
#   groups    after/'s jar, the README's loggers flag: every logger through a filter (the groups, the levels, TiffinBox's
#             loggers; never a total), the group alone; then Boot's own groups web and sql at DEBUG - the seven, the log
#   runtime   after/'s jar, the README's loggers flag: three requests at INFO, the README's POST to DEBUG, three more, the
#             README's POST back to null, three more - one process, its log read behind a barrier
#   lock      the README's read-only line: the POST 405, the level unchanged; then C (labelled): the writes the bridge refuses
#             (no JSON Content-Type, no body: 415), and a group then one of its members
#   names     the break, which name the level is set on: A the group · B com.tiffinbox alone · A' = A; then C (labelled): a
#             group and a member at start, both orders; every logger at TRACE - the seven, the token and its header counted
#   native    after/ built natively (the README's two Maven lines): the AOT jar and the binary - the loggers flag (404) and the
#             kitchen flag (the answer's line); then C (labelled): a copy built with loggers in application.yaml's list
#   exercise  exercise/README.md's commands and exercise/solution/SOLUTION.md's, read from the files and run as written
# "before" is ../c5-unit23/after (the anchor as the metrics lesson left it), COPIED under .harness/; this script never writes into
# another unit's folder. after/ is this unit's frozen copy of ../c5-tiffinbox after the change; it is copied, never built in
# place. Every run of TiffinBox starts in a folder under .harness/ that holds a config tree with the demo token (secrets/), as the
# README asks. Commands are printed exactly as they run: each goes through eval. "$CURLSET" is the comparison set since the secrets
# lesson (../c5-unit11/curlset.sh: the seven requests, POST /shutdown with the token's header read from the file). "$M2" is this
# unit's own repository, .m2-demo. The harness (harness/probe/logging/: Road, joined by --spring.main.sources; Jul, a plain main
# run alone) is compiled into .harness/hc: it lives outside com.tiffinbox, and it is the course's, never TiffinBox's.
# The network: every build runs offline (-o) against .m2-demo and says so ("offline: yes"); a build that cannot resolve an
# artifact offline goes to Maven Central once, and says that ("offline: no - ..."). GraalVM's native plugin, under the profile
# native, reads its metadata repository (a zip) from .m2-demo - and when the zip is not there it downloads it from GitHub, even
# under -o (README.md, The repository): so a native-profile build without the zip goes to Maven Central for it at once, never
# offline first, and every build's log is searched for the plugin's own download line - found, the run stops. At run time nothing
# leaves 127.0.0.1: TiffinBox listens there, every request goes there, and Logback writes to the terminal only (no file, no
# network appender).
# Masks and filters (README.md declares each; sub/gsub only): the demo token becomes "[masked: the 26-character token]"; the
# GraalVM's folder "$GRAALVM_HOME"; this folder's absolute path "…", the folder above it "…/..", the home folder "~"; your user
# name "<user>" - in every line of every capture. A log line a capture shows has its time "<time>", its process id "<pid>" and a
# virtual thread's name "virtual-<n>" (with its padding); logs are read, never printed whole - what a capture shows is named, and
# the rest counted. Boot's first line is printed from its message on, cut before " with PID". The loggers answer is written to a
# file beside the run's config tree, read through a filter, and deleted in the same step. No duration is captured: the native
# build is judged against a bound; seconds go to the terminal.
# Ports (brief ⚑10, 19030-19039): before 19030 · path 19031 · files 19032 · groups 19033 · runtime 19034 · lock 19035 · names
# 19036 · native 19037 · exercise 19039. 18425 (TiffinBox's default) and 8080 (Tomcat's) are checked free too.
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
# its process group - a TiffinBox JVM (a jar, an extracted class path), the JVM Maven's exec plugin forked, Maven running it, a
# binary, native-image's driver or builder - is stopped. Then the answers saved on the way, if a run left one. After an interrupt,
# a capture's unfinished runs (.r-NAME.1-3) go too; after a failed check they stay, for the diff the message names. The clean-up
# ignores a second Ctrl-C, and nothing in it can fail under set -e, so it always reaches the rmdir; the script still exits 130
# after an interrupt (tested: README.md, "Interrupted"). $pid is cleared whenever the process has been reaped.
pid=""
sweep() { local g i l
  g=$(ps -o pgid= -p $$ 2> /dev/null | tr -d ' ') || g=""
  [ -n "$g" ] || return 0
  i=0; while [ $i -lt 20 ]; do
    l=$(ps -axo pid=,pgid=,command= 2> /dev/null | awk -v g="$g" -v me=$$ -v gh="${GRAALVM_HOME:-/nonexistent}" '
      $2 == g && $1 != me && $3 != "awk" && $3 != "ps" && (index($0, "vminvocation.args") || index($3, gh "/bin/native-image") || $3 ~ /tiffinbox-web\/target\/tiffinbox-web$/ || index($0, "tiffinbox-web-1.0.0.jar") || index($0, "com.tiffinbox.web.TiffinBoxServer") || index($0, "exec:exec")) { print $1 }' | paste -sd' ' -) || l=""
    [ -n "$l" ] || return 0
    if [ $i -lt 10 ]; then kill $l 2> /dev/null || true; else kill -9 $l 2> /dev/null || true; fi
    sleep 0.5; i=$((i + 1)); done; }
machinefiles() { rm -f .harness/*/loggers.json .harness/*/scrape.txt .harness/mine/*/loggers.json 2> /dev/null || true; }
trap 'trap "" INT TERM; if [ -n "$pid" ] && kill "$pid" 2> /dev/null; then wait "$pid" 2> /dev/null || true; fi; sweep || true; machinefiles; [ -z "$INTR" ] || rm -f .r-*.[123]; rmdir .r-lock 2> /dev/null || true' EXIT
INTR=""; trap 'INTR=1; exit 130' INT TERM
exec 3>&1                                            # die() speaks to the terminal even inside a redirected capture
die() { echo "  *** $* ***" >&3; exit 1; }
java -version 2>&1 | grep -q 'version "25' || die "JDK 25 needed; JAVA_HOME gives: $(java -version 2>&1 | head -1)"
command -v javac > /dev/null || die "javac is needed: the harness's Road is compiled here"
command -v python3 > /dev/null || die "python3 is needed: Actuator's loggers answer is JSON, read through a filter"
command -v curl > /dev/null || die "curl is needed: every request here is curl's"
# A variable of yours must not become a property source, a JVM flag, a build setting or a native-image option: every
# TIFFINBOX_*, SPRING_*, MANAGEMENT_*, SERVER_* and LOGGING_* variable, DEBUG (Boot reads it as --debug), the variables that inject
# JVM flags, MAVEN_OPTS, MAVEN_ARGS and NATIVE_IMAGE_OPTIONS are removed first. GRAALVM_HOME stays: it says which GraalVM to use.
# (A LOGGING_LEVEL_ROOT of yours would change every log a capture counts.)
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
[ -e after/secrets ] || [ -e after/tiffinbox-web/secrets ] || [ -e after/tiffinbox-local.yaml ] || [ -e after/target ] && die "after/ holds a secrets/, a tiffinbox-local.yaml or a target/ - it is the anchor's frozen copy, never built in place; remove them"
M2="$PWD/.m2-demo"; U="$PWD"; UP="$(cd .. && pwd)"; ME="$(id -un)"
PREV=../c5-unit23/after                              # the previous tree: read, copied, never built in place
JAR=tiffinbox-web/target/tiffinbox-web-1.0.0.jar
BIN=tiffinbox-web/target/tiffinbox-web               # the binary native:compile-no-fork writes, in a tree's web module
TF=secrets/tiffinbox/shutdown-token                  # the config tree's file for tiffinbox.shutdown-token
SRV=tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java
YAML=tiffinbox-web/src/main/resources/application.yaml
POM=tiffinbox-web/pom.xml
JULF=tiffinbox-web/logging.properties                # the two Java logging files of Course 3: the previous tree ships them,
#                                                      after/ does not (brief ⚑6b, RED: deleted here, after files measured them)
JULD=tiffinbox-web/logging-debug.properties
# The demo token. FAKE, and meant to look it: it guards nothing but a demo server on 127.0.0.1 that every capture stops. It is
# written into .harness/*/secrets/ (git-ignored) when this script runs, and no capture prints it: see mask().
TOKEN=not-a-real-token-demo-only
[ ${#TOKEN} = 26 ] || die "the demo token must be 26 characters"
CURLSET=../c5-unit11/curlset.sh                      # the comparison set: the seven requests, POST /shutdown with the header
[ -f "$CURLSET" ] || die "$CURLSET is missing"
[ -f "$PREV/pom.xml" ] && [ -f after/pom.xml ] && [ -f after/README.md ] || die "the previous tree $PREV or after/ is missing"
for f in harness/shutdown.sh harness/probe/logging/Road.java harness/probe/logging/Jul.java; do [ -f "$f" ] || die "harness/ is missing $f"; done

# The ports, BEFORE anything is wiped (a survivor of an interrupted run answers POST /shutdown only with its token, which lives
# in .harness/ - so the message names the process to kill).
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
for p in 18425 8080 19030 19031 19032 19033 19034 19035 19036 19037 19038 19039; do
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
R_EXTRACT=$(readme 'java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted')
R_CP=$(readme 'java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431')
R_EXEC=$(readme 'mvn -q -B -pl tiffinbox-web exec:exec')
R_READY=$(readme "curl -s -w ' %{http_code}\n' http://127.0.0.1:18431/actuator/health/readiness")
R_STATUS=$(readme "curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:18431/customers/7")
R_SCRAPE=$(readme "curl -s -o scrape.txt -w '%{http_code} %{content_type}\n' http://127.0.0.1:18431/actuator/prometheus")
R_TBX=$(readme 'java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --logging.level.tiffinbox=debug')
R_KITCHEN=$(readme 'java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --logging.level.kitchen=debug')
R_COMT=$(readme 'java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --logging.level.com.tiffinbox=debug')
R_WEB=$(readme 'java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --logging.level.web=debug')
R_SQL=$(readme 'java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --logging.level.sql=debug')
R_TRACE=$(readme 'java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --logging.level.root=trace')
R_PREC1=$(readme 'java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --logging.level.kitchen=debug --logging.level.tiffinbox=info')
R_PREC2=$(readme 'java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --logging.level.tiffinbox=info --logging.level.kitchen=debug')
R_LOGGERS=$(readme 'java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --management.endpoints.web.exposure.include=health,prometheus,loggers')
R_LOCKED=$(readme 'java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --management.endpoints.web.exposure.include=health,prometheus,loggers --management.endpoint.loggers.access=read-only')
R_JUL=$(readme 'java -Djava.util.logging.config.file=tiffinbox-web/logging-debug.properties -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431')
R_BINK=$(readme 'tiffinbox-web/target/tiffinbox-web --tiffinbox.port=18431 --logging.level.kitchen=debug')
R_BINL=$(readme 'tiffinbox-web/target/tiffinbox-web --tiffinbox.port=18431 --management.endpoints.web.exposure.include=health,prometheus,loggers')
R_ALL=$(readme "curl -s -o loggers.json -w '%{http_code}\n' http://127.0.0.1:18431/actuator/loggers")
R_GROUP=$(readme "curl -s -w ' %{http_code}\n' http://127.0.0.1:18431/actuator/loggers/kitchen")
R_DEBUG=$(readme "curl -s -w ' %{http_code}\n' -X POST -H 'Content-Type: application/json' -d '{\"configuredLevel\":\"DEBUG\"}' http://127.0.0.1:18431/actuator/loggers/kitchen")
R_RESET=$(readme "curl -s -w ' %{http_code}\n' -X POST -H 'Content-Type: application/json' -d '{\"configuredLevel\":null}' http://127.0.0.1:18431/actuator/loggers/kitchen")
R_NOTYPE=$(readme "curl -s -w ' %{http_code}\n' -X POST -d '{\"configuredLevel\":\"DEBUG\"}' http://127.0.0.1:18431/actuator/loggers/kitchen")
R_EMPTY=$(readme "curl -s -w ' %{http_code}\n' -X POST http://127.0.0.1:18431/actuator/loggers/kitchen")
R_MEMBER=$(readme "curl -s -w ' %{http_code}\n' -X POST -H 'Content-Type: application/json' -d '{\"configuredLevel\":\"INFO\"}' http://127.0.0.1:18431/actuator/loggers/tiffinbox")
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
# flag 'README LINE': what the README's run line adds after the port
flag() { printf '%s\n' "${1##*--tiffinbox.port=18431 }"; }
# topath 'README curl LINE' PATH: the README's status line, its path /customers/7 made PATH
topath() { printf '%s\n' "${1/\/customers\/7/$2}"; }
# member NAME: the README's line that asks for the group kitchen, asking for the logger NAME instead
member() { printf '%s\n' "${R_GROUP/loggers\/kitchen/loggers/$1}"; }
# R_ROOT: the README's POST to DEBUG, sent to the root logger (ROOT, Boot's name for it) instead of the group
R_ROOT=${R_DEBUG/loggers\/kitchen/loggers/ROOT}
# hcp DIR PORT ['JVMFLAG'] ['FLAGS']: the README's exploded run - the extracted jar on the class path, TiffinBox's own main -
# from DIR, its port made PORT, the harness's classes added to the class path (../hc) and Road joined (--spring.main.sources);
# JVMFLAG, if given, before -cp (the README's debug-file line's -D), FLAGS after
hcp() { local c; c=$(at "$1" "$2" "$R_CP"); c=${c/lib\/\*\"/lib\/*:..\/hc\"}; [ -z "$3" ] || c=${c/ java -cp / java $3 -cp }
  printf '%s --spring.main.sources=probe.logging.Road%s\n' "$c" "${4:+ $4}"; }
# xc DIR PORT: the README's exec:exec line as this script runs it - from DIR (its web module; tiffinbox-core as the first build
# installed it), offline, this unit's own repository, its port from TIFFINBOX_PORT (Boot reads the variable as tiffinbox.port; the
# exec plugin's arguments are fixed)
xc() { printf 'cd %s && env TIFFINBOX_PORT=%s %s\n' "$1" "$2" "${R_EXEC/mvn -q -B /mvn -o -q -B -Dmaven.repo.local=\"\$M2\" }"; }
F_LOGGERS=$(flag "$R_LOGGERS"); F_KITCHEN=$(flag "$R_KITCHEN"); J_DEBUGFILE=${R_JUL%% -jar *}; J_DEBUGFILE=${J_DEBUGFILE#java }
[ "$F_LOGGERS" = --management.endpoints.web.exposure.include=health,prometheus,loggers ] && [ "$F_KITCHEN" = --logging.level.kitchen=debug ] || die "a README flag line does not end in its one flag"
[ "$J_DEBUGFILE" = -Djava.util.logging.config.file=tiffinbox-web/logging-debug.properties ] || die "the README's debug-file line"
C_AFTER=$(off .harness/after "$R_INSTALL" install)
for c in "$C_AFTER" "$(off .harness/x "$R_PLAIN" package)" "$(off .harness/x "$R_NATIVE")"; do
  r=$(dev "$c"); [ "$r" = "$R_PLAIN" ] || [ "$r" = "$R_INSTALL" ] || [ "$r" = "$R_NATIVE" ] || die "not a README line with the offline changes: $c"; done
[ "$(hcp .harness/x 19031 "" "$F_LOGGERS")" = 'cd .harness/x && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19031 --spring.main.sources=probe.logging.Road --management.endpoints.web.exposure.include=health,prometheus,loggers' ] || die "the exploded run with the harness"
[ "$(hcp .harness/x 19032 "$J_DEBUGFILE")" = 'cd .harness/x && java -Djava.util.logging.config.file=tiffinbox-web/logging-debug.properties -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19032 --spring.main.sources=probe.logging.Road' ] || die "the exploded run with the debug file"
[ "$(xc .harness/after 19032)" = 'cd .harness/after && env TIFFINBOX_PORT=19032 mvn -o -q -B -Dmaven.repo.local="$M2" -pl tiffinbox-web exec:exec' ] || die "the exec line"
[ "$R_ROOT" = "curl -s -w ' %{http_code}\n' -X POST -H 'Content-Type: application/json' -d '{\"configuredLevel\":\"DEBUG\"}' http://127.0.0.1:18431/actuator/loggers/ROOT" ] || die "the root's POST"
[ "$(member com.tiffinbox)" = "curl -s -w ' %{http_code}\n' http://127.0.0.1:18431/actuator/loggers/com.tiffinbox" ] || die "the member line"
[ "$(at .harness/x 19037 "$R_AOTRUN") $F_KITCHEN" = "cd .harness/x && java -Dspring.aot.enabled=true -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19037 --logging.level.kitchen=debug" ] || die "the AOT line with the kitchen flag"
echo "  the commands: after/README.md gives all 38 lines this script runs or derives from"

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
# repository is not in $M2 goes to Maven Central at once (offline, the plugin would fetch it from GitHub instead). A goal named by
# its prefix (exec:help) whose plugin is not in $M2 fails offline with "No plugin found for prefix": that is resolution too.
mbuild() { local how=yes ec=0 c=$1
  case $c in *' -Pnative '*) [ -f "$ZIP" ] || { c=${c/mvn -o -B /mvn -B }; how="no - GraalVM's metadata repository was not in .m2-demo, so Maven Central was asked for it"; } ;; esac
  (eval "$c") > "$2" 2>&1 < /dev/null || ec=$?
  if [ $ec != 0 ] && [ "$how" = yes ] && grep -qE 'offline mode|Could not resolve|could not be resolved|Cannot access|No plugin found for prefix' "$2"; then
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
# profile native's (process-aot, the plugin's add-reachability-metadata and its metadata repository), install's, and the exec
# plugin's (resolved by the exec capture, offline) - so on a fresh clone, whose .m2-demo is empty (git ignores it), this one build
# fills .m2-demo from Maven Central, once.
mbuild "$C_AFTER" .harness/build-after.log ".harness/after (after/, the profile native, both modules into \$M2)"
[ -f "$M2/org/springframework/boot/spring-boot-starter-parent/4.1.1/spring-boot-starter-parent-4.1.1.pom" ] || die "Boot's parent POM is not in .m2-demo after the first build"
[ -f "$M2/org/graalvm/buildtools/native-maven-plugin/1.1.8/native-maven-plugin-1.1.8.jar" ] || die "GraalVM's native plugin 1.1.8 is not in .m2-demo after the first build (it is a build extension of the web module)"
[ -f "$ZIP" ] || die "GraalVM's metadata repository is not in .m2-demo after the first build - README.md, The repository"
[ -f "$M2/ch/qos/logback/logback-classic/1.5.38/logback-classic-1.5.38.jar" ] && [ -f "$M2/org/slf4j/jul-to-slf4j/2.0.18/jul-to-slf4j-2.0.18.jar" ] || die "Logback 1.5.38 and SLF4J's jul-to-slf4j 2.0.18 are not in .m2-demo after the first build"
# The exec plugin: files' B runs the README's exec:exec line offline, inside a capture, where nothing may go online. No build phase
# reaches the plugin, so on a fresh clone the first build does not fill it in: its help goal resolves it here, once, the way every
# build does (offline, or Maven Central once, and the line says which).
mbuild 'cd .harness/after && mvn -o -B -Dmaven.repo.local="$M2" -q -pl tiffinbox-web exec:help' .harness/exec-help.log "the exec plugin (its help goal: resolved for the exec run)"
[ -f "$M2/org/codehaus/mojo/exec-maven-plugin/3.6.4/exec-maven-plugin-3.6.4.jar" ] || die "the exec plugin 3.6.4 is not in .m2-demo"
echo "  .m2-demo holds Boot's parent, Logback 1.5.38 and jul-to-slf4j 2.0.18, the exec plugin 3.6.4, GraalVM's native plugin 1.1.8 and its metadata repository ($(wc -c < "$ZIP" | tr -d ' ') bytes)"
# The harness: Road.java compiled against the jar the first build made (extracted: its classes and the jars it ships), into
# .harness/hc - outside every tree, outside com.tiffinbox
(cd .harness/after && eval "$R_EXTRACT") > .harness/extract-after.log 2>&1 || { cat .harness/extract-after.log >&3; die "the README's extract command failed in .harness/after"; }
javac -d .harness/hc -cp ".harness/after/tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:.harness/after/tiffinbox-web/target/extracted/lib/*" harness/probe/logging/*.java > .harness/javac.log 2>&1 || { cat .harness/javac.log >&3; die "the harness did not compile"; }
echo "  the harness: harness/probe/logging/ compiled into .harness/hc ($(find .harness/hc -name '*.class' | wc -l | tr -d ' ') classes)"

# ---- helpers ------------------------------------------------------------------------------------------------------------
# raw TOKEN FILE...: how many times TOKEN appears, raw, in the files (occurrences, not lines; binary files read as text)
raw() { local t=$1; shift; cat "$@" | LC_ALL=C grep -aoF -- "$t" | wc -l | tr -d ' '; }
SEEN=0                                               # how many answers saved on the way were counted for the token, raw
LOGS=0                                               # how many runs' logs were counted for the token and its header
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
# upchild PORT: up() for a process that does not listen itself - Maven's exec plugin, which forks the JVM that does: the port's
# listener, and whether it is a child of the process this script started
upchild() { local i=0 l=""
  while [ $i -lt 240 ]; do l=$(lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | head -1); [ -n "$l" ] && break
    kill -0 "$pid" 2> /dev/null || { tail -20 .harness/run.out >&3; die "it exited before anything listened on $1"; }; sleep 0.25; i=$((i + 1)); done
  [ -n "$l" ] || die "nothing listened on $1"
  echo "  listens on: $(lsof -nP -a -p "$l" -iTCP -sTCP:LISTEN 2> /dev/null | awk 'NR > 1 { print $9 }' | sort -u | paste -sd' ' -) · the process listening: a child of the one started above (the JVM the exec plugin forks): $([ "$(ps -o ppid= -p "$l" | tr -d ' ')" = "$pid" ] && echo yes || echo no)"
  echo "  Boot's first line: $(first .harness/run.out)"; }
# ask 'README curl LINE' PORT: the README's curl line, its port made PORT, printed and run; what it printed, indented
ask() { local c; c=$(url "$1" "$2"); echo "\$ $c"; (eval "$c") 2>&1 < /dev/null | sed 's/^/  /'; }
# status PATH PORT: the README's status-only line, its path made PATH and its port PORT, printed and run
status() { ask "$(topath "$R_STATUS" "$1")" "$2"; }
# get DIR PORT 'README curl LINE': the README's line that writes a file (loggers.json), run from DIR - beside the run's config
# tree - its port made PORT; what curl prints (the status), indented
get() { local c; c="cd $1 && $(url "$3" "$2")"; echo "\$ $c"; (eval "$c") 2>&1 < /dev/null | sed 's/^/  /'; }
# gone FILE: the token counted in a saved answer, raw, then the file deleted - the line says both
gone() { local t; t=$(raw "$TOKEN" "$1"); SEEN=$((SEEN + 1)); [ "$t" = 0 ] || die "$1 held the demo token, raw"
  rm -f "$1"; echo "  the demo token in it: $t · deleted: $([ -f "$1" ] && echo no || echo yes)"; }
# ready PORT: readiness asked until it answers 200 - every 0.25 s, up to 60 s, not printed - then the README's readiness line,
# printed and run once. No assertion before it (brief S4.15): readiness holds the kitchen, and its database.
ready() { local i=0 c=""
  while [ $i -lt 240 ]; do c=$(curl -s -o /dev/null -w '%{http_code}' "http://127.0.0.1:$1/actuator/health/readiness" 2> /dev/null || true); [ "$c" = 200 ] && break
    kill -0 "$pid" 2> /dev/null || { tail -20 .harness/run.out >&3; die "it exited before readiness answered 200"; }; sleep 0.25; i=$((i + 1)); done
  [ "$c" = 200 ] || die "readiness never answered 200 on $1"
  ask "$R_READY" "$1"; }
# answered PORT 'ROUTE' STATUS N: a barrier, not printed - the scrape asked (read from a pipe, never written to a file) every 0.1 s,
# up to 15 s, until it counts N answers for ROUTE and STATUS. TiffinBoxServer writes an answer's DEBUG line - or decides not to -
# before its timer stops: once the scrape counts N, the N answers' lines are in the log, or never will be.
answered() { local i=0 c=""
  while [ $i -lt 150 ]; do
    c=$(curl -s "http://127.0.0.1:$1/actuator/prometheus" 2> /dev/null | awk -v k="tiffinbox_requests_seconds_count{route=\"$2\",status=\"$3\"} " 'index($0, k) == 1 { print substr($0, length(k) + 1) }' || true)
    [ "$c" = "$4" ] && return 0; sleep 0.1; i=$((i + 1)); done
  die "the scrape on $1 never counted $4 answers for $2 $3 (it counts: ${c:-none})"; }
# logtok: the log of the run that just ended (standard output and error) counted for the demo token and for its header's name
# (X-Shutdown-Token, in any case), raw - each must be 0
logtok() { local t h; t=$(raw "$TOKEN" .harness/run.out .harness/run.err); h=$(cat .harness/run.out .harness/run.err | LC_ALL=C grep -aoi -- 'x-shutdown-token' | wc -l | tr -d ' ')
  LOGS=$((LOGS + 1)); [ "$t" = 0 ] && [ "$h" = 0 ] || die "a log held the demo token ($t) or its header's name ($h)"
  echo "  its log: the demo token $t times · X-Shutdown-Token $h times"; }
# seven PORT DIR [all]: the comparison set's seven requests (POST /shutdown carries the header, read from DIR's token file),
# printed as run - every response line with "all", else the POST line; the process must leave within 15 s of them, and the port
# must be free again; then its log counted for the token and its header (logtok). Never call it inside $(...): wait needs this shell.
seven() { local i e=0
  echo "\$ \$CURLSET $1 $2/$TF"
  "$CURLSET" "$1" "$2/$TF" | grep ' -> ' > .harness/responses.txt || true
  if [ "$3" = all ]; then sed 's/^/  /' .harness/responses.txt; else grep '^POST ' .harness/responses.txt | sed 's/^/  /' || echo "  (no POST line)"; fi
  i=0; while kill -0 "$pid" 2> /dev/null && [ $i -lt 60 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$pid" 2> /dev/null && { kill "$pid"; die "the server on $1 was still running 15 s after POST /shutdown"; }
  wait "$pid" || e=$?; pid=""
  [ "$(listeners "$1")" = 0 ] || die "something still listens on $1"
  echo "  exit $e · the seven responses: $(wc -l < .harness/responses.txt | tr -d ' ') lines · md5 $(md5 -q .harness/responses.txt)"
  logtok; }
# same PORT: whether the process listening on PORT is still the one this script started - no restart, the port never closed
same() { echo "  the process listening on $1: the one started above: $([ "$(lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null)" = "$pid" ] && echo yes || echo no)"; }
# A Boot log line, as Logback writes it: "<time> <LEVEL> <pid> --- [<thread>] <logger, padded to 40> : <message>".
# lmask: a log line's time, process id and a virtual thread's name (with its padding) masked - gsub, the rest of the line kept
lmask() { awk '{ gsub(/^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T[0-9][0-9]:[0-9][0-9]:[0-9][0-9]\.[0-9][0-9][0-9](Z|[+-][0-9][0-9]:[0-9][0-9])/, "<time>")
  gsub(/ [0-9]+ --- \[/, " <pid> --- ["); gsub(/\[ *virtual-[0-9]+\]/, "[    virtual-<n>]"); print }'; }
# LOGAWK: each DEBUG line of a Boot log split into its logger and its message, then KIND says what to do: "count" prints how many
# DEBUG lines there are - TiffinBox's own (its route lines, written at start, and its answer lines) and every other logger by
# name; "answers" prints TiffinBox's answer lines whole; "shown" prints them and the DEBUG lines of the loggers under com.tiffinbox,
# whole, in the log's order
LOGAWK='
/^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T[^ ]+ +DEBUG +[0-9]+ --- \[/ {
  s = $0; i = index(s, " --- ["); s = substr(s, i + 6); i = index(s, "] "); s = substr(s, i + 2)
  i = index(s, " : "); lg = substr(s, 1, i - 1); sub(/ +$/, "", lg); msg = substr(s, i + 3)
  n++
  if (lg == "tiffinbox") { if (msg ~ /^route /) r++; else { a++; if (kind == "answers" || kind == "shown") print } }
  else { o[lg]++; if (kind == "shown" && index(lg, "com.tiffinbox") == 1) print } }
END { if (kind != "count") exit
  line = "  its DEBUG lines: " (n + 0) " · tiffinbox: " (r + 0) " route lines, " (a + 0) " answer lines"
  k = 0; for (x in o) nm[++k] = x
  for (i = 1; i <= k; i++) for (j = i + 1; j <= k; j++) if (nm[j] < nm[i]) { t = nm[i]; nm[i] = nm[j]; nm[j] = t }
  for (i = 1; i <= k; i++) line = line " · " nm[i] ": " o[nm[i]]
  if (k == 0) line = line " · no other logger"
  print line }'
debugs() { awk -v kind=count "$LOGAWK" "$1"; }
answers() { awk -v kind=answers "$LOGAWK" "$1" | lmask | sed 's/^/  /'; }
shown() { awk -v kind=shown "$LOGAWK" "$1" | lmask | sed 's/^/  /'; }
# road FROM: the harness's lines in the log, from its FROM-th on (Road prints "harness: ..." to standard output)
road() { grep '^harness: ' .harness/run.out | sed -n "$1,\$p" | sed 's/^/  /'; }
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

# ---- before: the previous tree - DEBUG from the start, and nothing per request ------------------------------------------------
before() {
  echo "the previous tree (the anchor as the metrics lesson left it), copied to .harness/prev with a config tree, built the README's"
  echo "plain way; run with the first lesson's flag line - TiffinBox's own logger at DEBUG, from the start - port 19030:"
  copy "$PREV" .harness/prev
  pbuild .harness/prev "the previous tree"
  start "$(at .harness/prev 19030 "$R_TBX")"; up; ready 19030
  echo "a level, while it runs - the loggers endpoint:"
  ask "$(member tiffinbox)" 19030
  seven 19030 .harness/prev all
  echo "its log, read after the stop:"
  debugs .harness/run.out; }

# ---- change: the previous tree against after/ ---------------------------------------------------------------------------------
gained() { diff ".harness/before/$1" ".harness/after/$1" > .harness/file.diff || true
  echo "  $1 - the lines it gains that are neither comment nor blank:"
  sed -n 's/^> //p' .harness/file.diff | awk '{ t = $0; sub(/^[ \t]+/, "", t) } t == "" || t ~ /^(\/\*\*|\*|\/\/|#)/ { next } { print "    " $0 }'
  echo "    (diff adds $(grep -c '^> ' .harness/file.diff || true) lines, removes $(grep -c '^< ' .harness/file.diff || true))"; }
# keys FILE 'LINE'...: each line's number in FILE (grep -n), its leading blanks cut - every one must be there
keys() { local f=$1 t; shift; for t in "$@"; do grep -nF -- "$t" "$f" | sed 's/^\([0-9]*\):[ \t]*/    \1: /' | grep . || die "change: $f no longer holds: $t"; done; }
change() { local f
  echo "the previous tree against after/, both copied under .harness/ - the files that differ:"
  echo "\$ diff -rq -x target -x secrets .harness/before .harness/after"
  diff -rq -x target -x secrets .harness/before .harness/after | sed 's/^/  /' || true
  diff ".harness/before/$SRV" ".harness/after/$SRV" > .harness/file.diff || true
  echo "  $SRV - diff adds $(grep -c '^> ' .harness/file.diff || true) lines, removes $(grep -c '^< ' .harness/file.diff || true); the code lines it removes:"
  grep -E '^< +\.' .harness/file.diff | sed 's/^< */    < /'
  echo "  its key lines now (grep -n):"
  keys ".harness/after/$SRV" 'private static final System.Logger LOG = System.getLogger("tiffinbox");' '} finally {' \
    'String route = handler != null ? key : "UNKNOWN";' 'String status = Integer.toString(exchange.getResponseCode());' \
    'LOG.log(DEBUG, "{0} -> {1}", route, status);' 'sample.stop(Timer.builder("tiffinbox.requests")' '.tag("route", route)' '.tag("status", status)'
  gained "$YAML"
  diff .harness/before/README.md .harness/after/README.md > .harness/file.diff || true
  echo "  README.md - the anchor's README: lines added $(grep -c '^> ' .harness/file.diff || true), removed $(grep -c '^< ' .harness/file.diff || true) - its new section (not shown)"
  echo "  tiffinbox-core against the previous tree's (diff -rq -x target): $(diff -rq -x target .harness/before/tiffinbox-core .harness/after/tiffinbox-core | wc -l | tr -d ' ') files differ"
  for f in TiffinBoxApp ActuatorRoutes KitchenHealthIndicator KitchenMetrics; do f=tiffinbox-web/src/main/java/com/tiffinbox/web/$f.java
    echo "  $(basename "$f") against the previous tree's, byte for byte: $(cmp -s ".harness/before/$f" ".harness/after/$f" && echo the same || echo different)"; done
  diff ".harness/before/$POM" ".harness/after/$POM" > .harness/file.diff || true
  echo "  $POM - diff adds $(grep -c '^> ' .harness/file.diff || true) lines, removes $(grep -c '^< ' .harness/file.diff || true):"
  grep -E '^[<>] ' .harness/file.diff | sed 's/^\([<>]\) */    \1 /'
  for f in "$JULF" "$JULD"; do
    echo "  $f - in the previous tree: $([ -f ".harness/before/$f" ] && echo yes || echo no) · in after/: $([ -e ".harness/after/$f" ] && echo yes || echo no)"; done; }

# ---- path: one line's road - java.util.logging, the bridge, Logback - and a level carried back ---------------------------------
path() {
  echo "after/, copied to .harness/serve with a config tree, built the README's plain way, then extracted (the README's extract line):"
  copy after .harness/serve
  pbuild .harness/serve "after/"
  echo "\$ cd .harness/serve && $R_EXTRACT"
  (cd .harness/serve && eval "$R_EXTRACT") > .harness/serve.extract.log 2>&1 || { cat .harness/serve.extract.log >&3; die "the extract failed in .harness/serve"; }
  echo "  extracted: exit 0 · its lib/ holds $(ls .harness/serve/tiffinbox-web/target/extracted/lib | wc -l | tr -d ' ') jars"
  echo "run from the extracted class path with the harness's Road joined, and the README's loggers flag - port 19031:"
  start "$(hcp .harness/serve 19031 "" "$F_LOGGERS")"; up; ready 19031
  echo "the road, as Road read it when TiffinBox was ready:"
  road 1
  echo "the README's POST - the group kitchen to DEBUG - then one request:"
  ask "$R_DEBUG" 19031
  road 6
  status /kitchen 19031; answered 19031 'GET /kitchen' 200 1
  echo "  its answer lines so far:"; answers .harness/run.out
  echo "the README's POST - the group back to null - then one request:"
  ask "$R_RESET" 19031
  road 7
  status /kitchen 19031; answered 19031 'GET /kitchen' 200 2
  echo "  its answer lines so far: $(awk -v kind=answers "$LOGAWK" .harness/run.out | wc -l | tr -d ' ')"
  echo "C (labelled) - after null, the root: the README's POST to DEBUG, sent to the root logger (ROOT), then one request:"
  ask "$R_ROOT" 19031
  road 8
  ask "$(member tiffinbox)" 19031
  status /kitchen 19031; answered 19031 'GET /kitchen' 200 3
  echo "  its answer lines so far: $(awk -v kind=answers "$LOGAWK" .harness/run.out | wc -l | tr -d ' ')"
  seven 19031 .harness/serve
  echo "C (labelled) - the same root POST on a fresh process, the group never set: the same run line, port 19031:"
  start "$(hcp .harness/serve 19031 "" "$F_LOGGERS")"; up; ready 19031
  ask "$R_ROOT" 19031
  road 6
  ask "$(member tiffinbox)" 19031
  status /kitchen 19031; answered 19031 'GET /kitchen' 200 1
  echo "  its answer lines: $(awk -v kind=answers "$LOGAWK" .harness/run.out | wc -l | tr -d ' ')"
  seven 19031 .harness/serve; }

# ---- files: the Java logging files of Course 3 and the exec plugin's argument - measured on the previous tree, retired here ---
# julout: the run's two streams read for what java.util.logging's own console handler would print. Its format, the files'
# %5$s%n, is the message alone: TiffinBox's route and orders-cooked messages at the start of a line, and it writes to standard
# error. Logback writes the same messages to standard output, after a time, a level and a logger's name.
julout() { echo "  standard error: $(wc -l < .harness/run.err | tr -d ' ') lines · in the file's bare format, on either stream: route lines $(cat .harness/run.out .harness/run.err | grep -c '^route ' || true), orders-cooked lines $(cat .harness/run.out .harness/run.err | grep -c '^orders cooked:' || true)"; }
# named PORT: whether the JVM listening on PORT was started with the exec plugin's argument - its command line read (ps), never
# printed: only the answer
named() { local l; l=$(lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | head -1)
  echo "  the forked JVM's command line names logging.properties: $(ps -o command= -p "$l" 2> /dev/null | grep -q -- '-Djava.util.logging.config.file=logging.properties' && echo yes || echo no)"; }
files() { local f c
  echo "the two Java logging files and the exec plugin's argument, on the previous tree, which still ships them - their lines"
  echo "that are neither comment nor blank, and the argument (grep -n):"
  for f in "$JULF" "$JULD"; do echo "  $f:"; grep -vE '^[[:space:]]*(#|$)' "$PREV/$f" | sed 's/^/    /'; done
  echo "  $POM:"; grep -nF 'java.util.logging.config.file' "$PREV/$POM" | sed 's/^\([0-9]*\):[ \t]*/    \1: /'
  echo "the previous tree, copied to .harness/jul with a config tree, built the README's plain way, then extracted:"
  copy "$PREV" .harness/jul
  pbuild .harness/jul "the previous tree"
  echo "\$ cd .harness/jul && $R_EXTRACT"
  (cd .harness/jul && eval "$R_EXTRACT") > .harness/jul.extract.log 2>&1 || { cat .harness/jul.extract.log >&3; die "the extract failed in .harness/jul"; }
  echo "  extracted: exit 0 · its lib/ holds $(ls .harness/jul/tiffinbox-web/target/extracted/lib | wc -l | tr -d ' ') jars"
  echo "A - the README's line with the debug file, from that tree's extracted class path, Road joined - port 19032:"
  start "$(hcp .harness/jul 19032 "$J_DEBUGFILE")"; up; ready 19032
  road 1
  seven 19032 .harness/jul
  debugs .harness/run.out; julout
  echo "B - the README's exec line, from that tree: the exec plugin passes its argument (logging.properties). Its port from"
  echo "TIFFINBOX_PORT, its config tree in tiffinbox-web/ (the folder the plugin's JVM starts in) - port 19032:"
  tree .harness/jul/tiffinbox-web
  start "$(xc .harness/jul 19032)"; upchild 19032; named 19032; ready 19032
  echo "  its log's line for the orders cooked:"; grep -m1 ' : orders cooked:' .harness/run.out | lmask | sed 's/^/    /'
  seven 19032 .harness/jul/tiffinbox-web
  debugs .harness/run.out; julout
  echo "C (labelled) - the same files with no Boot to replace them: the harness's Jul, a plain main that logs one route line at"
  echo "DEBUG and the orders cooked at INFO through System.Logger(\"tiffinbox\"), from that tree, with each file:"
  for f in "$JULD" "$JULF"; do
    c="cd .harness/jul && java -Djava.util.logging.config.file=$f -cp ../hc probe.logging.Jul"; echo "\$ $c"
    (eval "$c") > .harness/run.out 2> .harness/run.err < /dev/null || die "the harness's Jul failed with $f"
    julout; done
  echo "retired here - after/, this unit's tree:"
  for f in "$JULF" "$JULD"; do echo "  $f: $([ -e "after/$f" ] && echo there || echo deleted)"; done
  echo "  $POM - lines that name java.util.logging.config.file: $(grep -cF 'java.util.logging.config.file' "after/$POM" || true)"
  echo "the README's exec line on after/ (.harness/after, the tree the first build installed), the argument gone - port 19032:"
  tree .harness/after/tiffinbox-web
  start "$(xc .harness/after 19032)"; upchild 19032; named 19032; ready 19032
  seven 19032 .harness/after/tiffinbox-web; }

# ---- groups: every logger, through a filter; the group; Boot's own groups on TiffinBox ----------------------------------------
# loggers FILE: the loggers answer (JSON) through a filter - its size against a floor, its keys, the levels, every group with its
# members, the loggers' names by first word (never the total: it moves), and TiffinBox's loggers (tiffinbox, com.tiffinbox...)
loggers() { python3 - "$1" <<'PY'
import json, os, sys
f = sys.argv[1]; d = json.load(open(f))
print("  its size, against a floor: over 30,000 bytes: %s · its keys: %s" % ("yes" if os.path.getsize(f) > 30000 else "no", " ".join(sorted(d))))
print("  levels: %s" % " ".join(d["levels"]))
for g in sorted(d["groups"]):
    v = d["groups"][g]
    print("  group %s: configuredLevel %s · %d members: %s" % (g, json.dumps(v["configuredLevel"]), len(v["members"]), ", ".join(v["members"])))
L = d["loggers"]
print("  loggers: their names' first words: %s · how many: not counted (the total moves)" % " ".join(sorted(set(k.split(".")[0] for k in L))))
for k in sorted(L):
    if k == "tiffinbox" or k.startswith("com.tiffinbox"):
        print("  logger %s: %s" % (k, json.dumps(L[k], sort_keys=True)))
PY
}
groups() { local r
  echo "after/'s jar (.harness/serve), the README's loggers flag line - port 19033:"
  start "$(at .harness/serve 19033 "$R_LOGGERS")"; up; ready 19033
  echo "every logger - the README's line, written to loggers.json beside the run's config tree, read through a filter:"
  get .harness/serve 19033 "$R_ALL"; loggers .harness/serve/loggers.json; gone .harness/serve/loggers.json
  echo "the group alone:"
  ask "$R_GROUP" 19033
  seven 19033 .harness/serve
  echo "Boot's own groups on TiffinBox - the README's line for each, the seven, then the log:"
  for r in "$R_WEB" "$R_SQL"; do
    start "$(at .harness/serve 19033 "$r")"; up; ready 19033
    seven 19033 .harness/serve
    debugs .harness/run.out; done
  echo "Boot's own metadata - spring-boot 4.1.1's META-INF/spring-configuration-metadata.json, read from \$M2:"
  python3 - "$M2/org/springframework/boot/spring-boot/4.1.1/spring-boot-4.1.1.jar" <<'PY'
import json, sys, zipfile
d = json.loads(zipfile.ZipFile(sys.argv[1]).read("META-INF/spring-configuration-metadata.json"))
p = {x["name"]: x for x in d["properties"]}; hv = {x["name"]: [v["value"] for v in x.get("values", [])] for x in d["hints"]}
print("  logging.group: %s" % p["logging.group"]["type"])
print("  logging.structured.format.console: its values %s" % " ".join(hv["logging.structured.format.console"]))
PY
}

# ---- runtime: INFO, DEBUG, INFO - one process ---------------------------------------------------------------------------------
three() { status /customers "$1"; status /customers "$1"; status /customers "$1"; answered "$1" 'GET /customers' 200 "$2"; }
runtime() {
  echo "after/'s jar (.harness/serve), the README's loggers flag line - port 19034:"
  start "$(at .harness/serve 19034 "$R_LOGGERS")"; up; ready 19034
  ask "$R_GROUP" 19034
  echo "INFO - three requests:"
  three 19034 3
  echo "  answer lines in its log: $(awk -v kind=answers "$LOGAWK" .harness/run.out | wc -l | tr -d ' ')"
  echo "the README's POST - the group to DEBUG:"
  ask "$R_DEBUG" 19034; ask "$(member tiffinbox)" 19034
  echo "DEBUG - three requests:"
  three 19034 6
  echo "  answer lines in its log: $(awk -v kind=answers "$LOGAWK" .harness/run.out | wc -l | tr -d ' ')"; answers .harness/run.out
  echo "the README's POST - the group back to null:"
  ask "$R_RESET" 19034; ask "$(member tiffinbox)" 19034
  echo "INFO again - three requests:"
  three 19034 9
  echo "  answer lines in its log: $(awk -v kind=answers "$LOGAWK" .harness/run.out | wc -l | tr -d ' ')"
  same 19034
  seven 19034 .harness/serve
  debugs .harness/run.out; }

# ---- lock: read-only; the writes the bridge takes; a group, then a member -------------------------------------------------------
lock() {
  echo "the lock - the README's read-only line, port 19035:"
  start "$(at .harness/serve 19035 "$R_LOCKED")"; up; ready 19035
  ask "$R_DEBUG" 19035; ask "$R_GROUP" 19035
  seven 19035 .harness/serve
  echo "C (labelled) - the writes the bridge refuses: the README's loggers flag line, port 19035:"
  start "$(at .harness/serve 19035 "$R_LOGGERS")"; up; ready 19035
  echo "the README's POST without a JSON Content-Type (curl -d sends a form's):"; ask "$R_NOTYPE" 19035; ask "$R_GROUP" 19035
  echo "the README's POST with no body:"; ask "$R_EMPTY" 19035; ask "$R_GROUP" 19035
  echo "C (labelled) - the group to DEBUG, then its member tiffinbox to INFO (the README's two POSTs), and one request:"
  ask "$R_DEBUG" 19035; ask "$R_MEMBER" 19035
  ask "$R_GROUP" 19035; ask "$(member tiffinbox)" 19035; ask "$(member com.tiffinbox)" 19035
  status /customers 19035; answered 19035 'GET /customers' 200 1
  echo "  answer lines in its log: $(awk -v kind=answers "$LOGAWK" .harness/run.out | wc -l | tr -d ' ')"
  seven 19035 .harness/serve; }

# ---- names: the break - which name the level is set on ------------------------------------------------------------------------
one() { start "$(at .harness/serve 19036 "$1")"; up; ready 19036
  status /customers 19036; answered 19036 'GET /customers' 200 1
  debugs .harness/run.out; shown .harness/run.out
  seven 19036 .harness/serve; }
names() {
  echo "the break: which name the level is set on. One request in every run, then the log's DEBUG lines; port 19036."
  echo "A - the README's line: the group kitchen at DEBUG:"; one "$R_KITCHEN"
  echo "B - the README's line: only com.tiffinbox at DEBUG:"; one "$R_COMT"
  echo "A' - A again:"; one "$R_KITCHEN"
  echo "C (labelled) - a group and one of its members at start, both orders (the README's two lines):"
  one "$R_PREC1"; one "$R_PREC2"
  echo "C (labelled) - every logger at TRACE (the README's root line): the seven, the last one carrying the token's header:"
  start "$(at .harness/serve 19036 "$R_TRACE")"; up; ready 19036
  seven 19036 .harness/serve all
  echo "  its log, against a floor: over 1,000 lines: $([ "$(cat .harness/run.out .harness/run.err | wc -l | tr -d ' ')" -gt 1000 ] && echo yes || echo no) · its answer lines:"; answers .harness/run.out; }

# ---- native: after/, built natively; the AOT jar and the binary; C, loggers in the built list ---------------------------------
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
# against the bound (1 minute or more, under 20 minutes: native builds here took up to 8 under load), and the network
# (offline: nbuild stopped the run if the plugin went out)
nresult() { echo "  exit $NB_E · $(grep -m1 -oE 'BUILD (SUCCESS|FAILURE)' "$1" || echo 'no BUILD line') · stages it printed: $(grep -cE '^\[[1-8]/8\] ' "$1" || true) of the $(grep -m1 -oE '^\[1/[0-9]+\]' "$1" | sed 's/.*\///; s/]//') it announces · its duration, against the bound: $( [ $NB_S -ge 60 ] && echo '1 minute or more' || echo 'under 1 minute' ), $( [ $NB_S -lt 1200 ] && echo 'under 20 minutes' || echo '20 minutes or more' ) · offline: yes"; }
# nloggers: after a start with the loggers flag - the endpoint asked, then the README's POST
nloggers() { ready 19037; ask "$(member tiffinbox)" 19037; ask "$R_DEBUG" 19037; seven 19037 .harness/nat; }
# nkitchen [all]: after a start with the kitchen flag - one request; the scrape (the README's line, written beside the run's config
# tree), its status and content type, and its one line for that request, then deleted; the log's DEBUG lines, the answer line; the seven
nkitchen() { ready 19037; status /customers 19037; answered 19037 'GET /customers' 200 1
  get .harness/nat 19037 "$R_SCRAPE"
  echo "  its line for the request: $(grep -F 'tiffinbox_requests_seconds_count{route="GET /customers",status="200"} ' .harness/nat/scrape.txt)"; gone .harness/nat/scrape.txt
  debugs .harness/run.out; answers .harness/run.out; seven 19037 .harness/nat "$1"; }
native() {
  echo "after/, copied to .harness/nat with a config tree; the README's two Maven lines, offline; \$GRAALVM_HOME names the GraalVM:"
  copy after .harness/nat
  nbuild .harness/nat
  nlines .harness/nat.native.log
  nresult .harness/nat.native.log
  echo "  file: $(file -b ".harness/nat/$BIN" | sed 's/ [A-Za-z0-9_]*$//') · the demo token in its bytes: $(raw "$TOKEN" ".harness/nat/$BIN")"
  echo "the AOT jar - the README's AOT line with the README's loggers flag, port 19037:"
  start "$(at .harness/nat 19037 "$R_AOTRUN") $F_LOGGERS"; up; nloggers
  echo "the AOT jar - the README's AOT line with the README's kitchen flag:"
  start "$(at .harness/nat 19037 "$R_AOTRUN") $F_KITCHEN"; up; nkitchen
  echo "the binary - the README's line with the loggers flag:"
  start "$(at .harness/nat 19037 "$R_BINL")"; up; nloggers
  echo "the binary - the README's line with the kitchen flag:"
  start "$(at .harness/nat 19037 "$R_BINK")"; up; nkitchen all
  echo "C (labelled) - loggers in the list it is built with: a copy of after/ (.harness/natl), application.yaml's exposure line"
  echo "changed; built with the README's native install (the AOT jar - no native-image run):"
  copy after .harness/natl
  sed -i '' 's/^        include: health,prometheus$/        include: health,prometheus,loggers/' ".harness/natl/$YAML"
  echo "\$ diff after/$YAML .harness/natl/$YAML"
  diff "after/$YAML" ".harness/natl/$YAML" | sed 's/^/  /' || true
  echo "\$ $(off .harness/natl "$R_INSTALL" install)"; mbuild "$(off .harness/natl "$R_INSTALL" install)" .harness/natl.install.log ".harness/natl (both modules, into \$M2)"
  start "$(at .harness/natl 19037 "$R_AOTRUN")"; up; ready 19037
  ask "$R_GROUP" 19037; ask "$R_DEBUG" 19037
  status /customers 19037; answered 19037 'GET /customers' 200 1
  answers .harness/run.out
  seven 19037 .harness/natl; }

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
  echo "  exit $ec · listening on 19039 now: $(listeners 19039)"
  echo "  its log (.harness/mine/run.log): the demo token $(raw "$TOKEN" .harness/mine/run.log) times · X-Shutdown-Token $(LC_ALL=C grep -aoi -- 'x-shutdown-token' .harness/mine/run.log | wc -l | tr -d ' ') times"; }

cap before before
cap change change
cap path path
cap files files
cap groups groups
cap runtime runtime
cap lock lock
cap names names
# Without a GraalVM the run stops here, the exercise's capture made first (it needs none): .m2-demo is filled, and every capture
# so far matched receipts.md5 - or cap() would have stopped the run.
if [ $GOK = no ]; then cap exercise exercise
  die "GRAALVM_HOME is not set: .m2-demo is filled, and the captures that need no GraalVM matched receipts.md5, the exercise's included; the native build needs a GraalVM JDK 25 - README.md, The GraalVM"; fi
cap native native
cap exercise exercise

echo
# ---- every number the video says, asserted (below) ----------------------------------------------------------------------------
# ---- every number the video says, asserted. Each check reads a line a program computed - never a label this script prints
# ---- unconditionally - and names the words it pays for. (The "$ ..." command lines are echoes of what ran: the published
# ---- md5 pins them, and no check pretends to test them.)
x() { grep -qE -- "$2" ".r-$1.out" || die "$1: expected /$2/"; }
n() { grep -cE -- "$2" ".r-$1.out" || true; }                                            # how many lines match
blk() { awk -v a="$2" -v b="$3" 'index($0, a) == 1 { f = 1; next } b != "" && index($0, b) == 1 { f = 0 } f' ".r-$1.out"; }
S115='115c36bac276128e245ca57df11c2891'
SEVEN="  exit 0 · the seven responses: 7 lines · md5 $S115"
LOGOK="  its log: the demo token 0 times · X-Shutdown-Token 0 times"
ANS='<time> DEBUG <pid> --- [    virtual-<n>] tiffinbox                                : '
# has 'TEXT' 'LINE' MESSAGE: TEXT (a variable holding a capture's block) holds the line, whole
has() { printf '%s\n' "$1" | grep -qxF -- "$2" || die "$3: expected the line: $2"; }
# cnt 'TEXT' 'LINE': how many times TEXT holds the line, whole
cnt() { printf '%s\n' "$1" | grep -cxF -- "$2" || true; }
# THE TOKEN: no capture holds the demo token, raw - counted on each run's own output BEFORE masking - and neither does any answer
# saved on the way (gone() died on one), any run's log (seven() counted each, with the header's name), anything this unit ships
# for reading, nor the binary this run built
for f in .harness/raw-*; do [ "$(cat "$f")" = 0 ] || die "a capture's raw output held the demo token ($f)"; done
NBIN=0
for f in .r-*.out README.md exercise/README.md exercise/solution/SOLUTION.md receipts.md5 harness/shutdown.sh harness/probe/logging/Road.java harness/probe/logging/Jul.java after/README.md "after/$YAML" "after/$SRV" .harness/nat/$BIN; do
  [ -f "$f" ] || continue; case $f in .harness/nat*) NBIN=$((NBIN + 1)) ;; esac
  [ "$(raw "$TOKEN" "$f")" = 0 ] || die "$f holds the demo token, raw"; done
[ "$NBIN" = 1 ] || die "one binary was built, $NBIN were checked"
for f in .r-*.out; do ! grep -qE '/Users/|/private/|/home/|/var/folders/' "$f" || die "$f holds an absolute path"; ! grep -qF "$GRAALVM_HOME" "$f" || die "$f holds the GraalVM's folder"; ! grep -qE 'c[0-9]-unit[0-9]|unit ?[0-9]' "$f" || die "$f holds a unit number"; ! grep -qE ' (with PID|started by) ' "$f" || die "$f holds Boot's process line"; ! grep -qE '^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T|virtual-[0-9]' "$f" || die "$f holds a log line's time or a thread's number"; done
[ -z "$(find .harness \( -name loggers.json -o -name scrape.txt \) | head -1)" ] || die "an answer saved on the way was left under .harness/"
NLOG=$(cat .r-*.out | grep -cxF "$LOGOK" || true); NX=$(n exercise '^  its log \(\.harness/mine/run\.log\): the demo token 0 times · X-Shutdown-Token 0 times$')
[ "$NX" = 1 ] || die "exercise: its log, the token and its header"
echo "  token: 0 raw copies in $(ls .harness/raw-* | wc -l | tr -d ' ') raw capture runs, in $(ls .r-*.out | wc -l | tr -d ' ') captures, in the $SEEN answers saved on the way (each counted, then deleted), in the logs of every run ($LOGS counted here, the published captures' $((NLOG + NX)) each with 0 tokens and 0 header names), the READMEs, the harness, receipts.md5 and the binary; no absolute path, no GraalVM folder, no unit number, no process line, no log time or thread number in any capture"
# S4.16: no star in an exposure list anywhere in this unit - its scripts, its READMEs, its captures
for f in receipts.sh README.md exercise/README.md exercise/solution/SOLUTION.md .r-*.out; do
  [ -f "$f" ] || continue
  ! grep -nE "exposure\.include='?\*" "$f" | grep -vF 'grep -nE "exposure' | grep -q . || die "$f: a star in an exposure list"; done

# "A logger is a named source of log lines ... its level decides how much it says ... TiffinBox's logger to debug with the first
# lesson's flag. Five route lines at start, then the seven requests: zero lines. And no switch while it runs: the loggers endpoint
# answers four hundred four."
BE=$(blk before 'a level, while it runs' '')
x before "^\\\$ cd \\.harness/prev && java -jar tiffinbox-web/target/tiffinbox-web-1\\.0\\.0\\.jar --tiffinbox\\.port=19030 --logging\\.level\\.tiffinbox=debug\$"
has "$BE" '  {"error":"not found"} 404' "before: no loggers endpoint"
has "$BE" "$SEVEN" "before: the seven"; has "$BE" "$LOGOK" "before: the log, no token"
has "$BE" "  its DEBUG lines: 5 · tiffinbox: 5 route lines, 0 answer lines · no other logger" "before: 5 route lines, 0 answer lines"
x before ' · offline: yes · exit 0$'
echo "  before: DEBUG from the start - 5 route lines, 0 for the seven answers · loggers 404 · 115c36ba..."

# "The change: two files of code, and the README ... one debug line per answer: the route and the status, the same two values the
# timer tags ... written before the timer stops ... a log group ... TiffinBox's own logger, plus the loggers under com dot tiffinbox."
[ "$(n change '^  Files ')" = 4 ] && [ "$(n change '^  Only in ')" = 2 ] || die "change: four files differ, two removed, none added"
x change '^  Files \.harness/before/tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer\.java and '
x change '^  Files \.harness/before/tiffinbox-web/src/main/resources/application\.yaml and '
x change '^  Files \.harness/before/README\.md and '; x change '^  Files \.harness/before/tiffinbox-web/pom\.xml and '
x change '^  Only in \.harness/before/tiffinbox-web: logging\.properties$'; x change '^  Only in \.harness/before/tiffinbox-web: logging-debug\.properties$'
[ "$(blk change '  tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java - diff adds' '  its key lines now' | paste -sd'|' -)" = '    < .tag("route", handler != null ? key : "UNKNOWN")|    < .tag("status", Integer.toString(exchange.getResponseCode()))' ] || die "change: the two tag lines it removes"
CK=$(blk change '  its key lines now' '  tiffinbox-web/src/main/resources/application.yaml')
L1=$(printf '%s\n' "$CK" | sed -n 's/^    \([0-9]*\): LOG\.log(DEBUG, "{0} -> {1}", route, status);.*/\1/p'); L2=$(printf '%s\n' "$CK" | sed -n 's/^    \([0-9]*\): sample\.stop(Timer\.builder("tiffinbox\.requests").*/\1/p')
LF=$(printf '%s\n' "$CK" | sed -n 's/^    \([0-9]*\): } finally {.*/\1/p')
[ -n "$L1" ] && [ -n "$L2" ] && [ -n "$LF" ] && [ "$LF" -lt "$L1" ] && [ "$L1" -lt "$L2" ] || die "change: the DEBUG line sits in the finally, before the timer stops"
has "$CK" '    65: private static final System.Logger LOG = System.getLogger("tiffinbox");' "change: TiffinBox's own logger, named tiffinbox"
for t in '.tag("route", route)' '.tag("status", status)' 'String route = handler != null ? key : "UNKNOWN";'; do printf '%s\n' "$CK" | grep -qE "^    [0-9]+: $(printf '%s' "$t" | sed 's/[][\.*^$(){}?+|/]/\\&/g')\$" || die "change: $t"; done
[ "$(blk change '  tiffinbox-web/src/main/resources/application.yaml - the lines it gains' '  README.md' | sed 's/^ *//' | paste -sd'|' -)" = "logging:|group:|kitchen: tiffinbox, com.tiffinbox|(diff adds 8 lines, removes 0)" ] || die "change: application.yaml gains the group"
x change '^  tiffinbox-core against the previous tree.s \(diff -rq -x target\): 0 files differ$'
for t in TiffinBoxApp.java ActuatorRoutes.java KitchenHealthIndicator.java KitchenMetrics.java; do x change "^  $t against the previous tree.s, byte for byte: the same\$"; done
[ "$(blk change '  tiffinbox-web/pom.xml - diff adds' '  tiffinbox-web/logging.properties - ' | paste -sd'|' -)" = '    < <argument>-Djava.util.logging.config.file=logging.properties</argument>' ] || die "change: the POM loses the exec argument, nothing else"
x change '^  tiffinbox-web/pom\.xml - diff adds 0 lines, removes 1:$'
for t in logging.properties logging-debug.properties; do x change "^  tiffinbox-web/$t - in the previous tree: yes · in after/: no\$"; done
[ "$(diff -rq -x target -x secrets "$PREV" after | wc -l | tr -d ' ')" = 6 ] || die "change: after/ differs from the previous tree in more than the README, the server, the YAML, the POM and the two files"
echo "  change: 4 files differ, 2 deleted · the DEBUG line in the finally, before the timer stops, route and status · the group kitchen: tiffinbox, com.tiffinbox · the POM: the exec argument gone · core, the bridge, the indicator and the meters: the same"

# "TiffinBox writes through the JDK's System Logger ... Java's own logging ... one handler, the SLF4J bridge ... Logback's root
# logger writes through one appender, CONSOLE." "the level change propagator, copies the level back ... debug becomes FINE ...
# System Logger's debug check says yes. One request, one line. Back to null, and it's quiet again."
PA=$(blk path 'the road, as Road read it' 'the README.s POST - the group kitchen to DEBUG'); PB=$(blk path 'the README'"'"'s POST - the group kitchen to DEBUG' 'the README'"'"'s POST - the group back to null'); PC=$(blk path 'the README'"'"'s POST - the group back to null' 'C (labelled) - after null')
PD=$(blk path 'C (labelled) - after null' 'C (labelled) - the same root POST'); PE=$(blk path 'C (labelled) - the same root POST' '')
x path '^  extracted: exit 0 · its lib/ holds 46 jars$'
has "$PA" "  harness: java.util.logging's root logger - its handlers: [org.slf4j.bridge.SLF4JBridgeHandler] · its level: INFO" "path: the bridge on JUL's root"
has "$PA" "  harness: Logback's root logger - its appenders: [CONSOLE ch.qos.logback.core.ConsoleAppender] · its level: INFO" "path: one appender, CONSOLE"
has "$PA" "  harness: Logback's listeners: [ch.qos.logback.classic.jul.LevelChangePropagator, io.micrometer.core.instrument.binder.logging.LogbackMetrics\$1]" "path: the propagator"
has "$PA" "  harness: at start - TiffinBox's logger: Logback's tiffinbox INFO · java.util.logging's tiffinbox null · System.Logger DEBUG loggable: false" "path: silent at start"
has "$PB" "   204" "path: the POST"
has "$PB" "  harness: Logback's tiffinbox changed - TiffinBox's logger: Logback's tiffinbox DEBUG · java.util.logging's tiffinbox FINE · System.Logger DEBUG loggable: true" "path: DEBUG is FINE"
has "$PB" "  ${ANS}GET /kitchen -> 200" "path: one request, one line"
has "$PC" "  harness: Logback's tiffinbox changed - TiffinBox's logger: Logback's tiffinbox INFO · java.util.logging's tiffinbox INFO · System.Logger DEBUG loggable: false" "path: back"
has "$PC" "  its answer lines so far: 1" "path: quiet again"
# "Back to null, and it's quiet. But Java's logging keeps INFO pinned on TiffinBox's logger: a later root change shows debug in
# Actuator, and prints nothing."
has "$PD" "   204" "path C: the root's POST"
has "$PD" "  harness: Logback's ROOT changed - TiffinBox's logger: Logback's tiffinbox DEBUG · java.util.logging's tiffinbox INFO · System.Logger DEBUG loggable: false" "path C: java.util.logging pinned at INFO"
has "$PD" '  {"configuredLevel":null,"effectiveLevel":"DEBUG"} 200' "path C: Actuator reports DEBUG"
has "$PD" "  its answer lines so far: 1" "path C: no line"; has "$PD" "$SEVEN" "path: the seven"
has "$PE" "   204" "path C, fresh: the root's POST"
has "$PE" "  harness: Logback's ROOT changed - TiffinBox's logger: Logback's tiffinbox DEBUG · java.util.logging's tiffinbox null · System.Logger DEBUG loggable: true" "path C, fresh: java.util.logging follows the root"
has "$PE" '  {"configuredLevel":null,"effectiveLevel":"DEBUG"} 200' "path C, fresh: Actuator reports DEBUG"
has "$PE" "  its answer lines: 1" "path C, fresh: the line"; has "$PE" "$SEVEN" "path C, fresh: the seven"
[ "$(printf '%s\n' "$PE" | grep -c '^  harness: ')" = 1 ] || die "path C, fresh: Road's one line after its start"
echo "  path: JUL's root -> SLF4JBridgeHandler -> Logback's CONSOLE · LevelChangePropagator: DEBUG -> FINE, loggable; one line; null -> INFO, quiet · C: after null, the root at DEBUG - Actuator DEBUG, JUL pinned INFO, 0 lines; fresh, the same POST - 1 line"

# "the logging file that quietly stopped working ... Java's logging did read it: its properties still say FINE. Then Boot put its
# bridge on the root and took the level from Logback: INFO, zero debug lines. The exec plugin's file is just as dead, so this
# lesson deletes both."
FA=$(blk files 'A - ' 'B - '); FB=$(blk files 'B - ' 'C (labelled)'); FC=$(blk files 'C (labelled)' 'retired here'); FR=$(blk files 'retired here' '')
JUL0="  standard error: 0 lines · in the file's bare format, on either stream: route lines 0, orders-cooked lines 0"
has "$(blk files '  tiffinbox-web/logging-debug.properties:' '  tiffinbox-web/pom.xml')" "    .level   = FINE" "files: the debug file asks for FINE"
x files '^    [0-9]+: <argument>-Djava\.util\.logging\.config\.file=logging\.properties</argument>$'
x files '^  built the previous tree · offline: yes · exit 0$'
has "$FA" "  harness: what java.util.logging's configuration file asked for (LogManager's properties) - handlers: java.util.logging.ConsoleHandler · .level: FINE" "files: JUL read the file"
has "$FA" "  harness: java.util.logging's root logger - its handlers: [org.slf4j.bridge.SLF4JBridgeHandler] · its level: INFO" "files: Boot's bridge, INFO"
has "$FA" "  its DEBUG lines: 0 · tiffinbox: 0 route lines, 0 answer lines · no other logger" "files: zero DEBUG lines"
has "$FA" "$JUL0" "files A: nothing in the file's own output"
has "$FB" "  listens on: 127.0.0.1:19032 · the process listening: a child of the one started above (the JVM the exec plugin forks): yes" "files: exec forks"
has "$FB" "  the forked JVM's command line names logging.properties: yes" "files B: the argument was passed"
has "$FB" "    <time>  INFO <pid> --- [           main] tiffinbox                                : orders cooked:  120" "files: Logback's format, not the file's"
has "$FB" "  its DEBUG lines: 0 · tiffinbox: 0 route lines, 0 answer lines · no other logger" "files: exec, zero DEBUG lines"
has "$FB" "$JUL0" "files B: nothing in the file's own output"
[ "$(printf '%s\n' "$FC" | grep -E '^  standard error: ' | paste -sd'|' -)" = "  standard error: 2 lines · in the file's bare format, on either stream: route lines 1, orders-cooked lines 1|  standard error: 1 lines · in the file's bare format, on either stream: route lines 0, orders-cooked lines 1" ] || die "files C: with no Boot, the debug file prints both lines bare on standard error, the other one"
for t in logging.properties logging-debug.properties; do has "$FR" "  tiffinbox-web/$t: deleted" "files: $t retired"; done
has "$FR" "  tiffinbox-web/pom.xml - lines that name java.util.logging.config.file: 0" "files: the argument retired"
has "$FR" "  the forked JVM's command line names logging.properties: no" "files: after/'s exec run, no argument"; has "$FR" "$SEVEN" "files: after/'s exec run serves"
[ "$(n files "^$SEVEN\$")" = 3 ] || die "files: the seven, three times"
echo "  files: on the previous tree - the debug file read (.level FINE), root still the bridge at INFO, 0 DEBUG lines, nothing in its own format or on standard error · exec:exec with the argument: Logback's format, 0 · C, no Boot: 2 and 1 bare lines on standard error · retired here: after/'s exec line serves"

# "Expose loggers for one run, and Boot lists every logger and three groups. Kitchen is ours. Web and SQL are Boot's own: five and
# three of Spring's web and JDBC loggers. Set either to debug on TiffinBox and you get zero debug lines."
GA=$(blk groups 'every logger' "Boot's own groups"); GB=$(blk groups "Boot's own groups" '')
has "$GA" "  its size, against a floor: over 30,000 bytes: yes · its keys: groups levels loggers" "groups: the loggers answer"
has "$GA" "  levels: OFF ERROR WARN INFO DEBUG TRACE" "groups: the levels"
has "$GA" "  group kitchen: configuredLevel null · 2 members: tiffinbox, com.tiffinbox" "groups: kitchen"
printf '%s\n' "$GA" | grep -qE '^  group sql: configuredLevel null · 3 members: ' && printf '%s\n' "$GA" | grep -qE '^  group web: configuredLevel null · 5 members: ' || die "groups: web 5, sql 3"
[ "$(printf '%s\n' "$GA" | grep -c '^  group ')" = 3 ] || die "groups: three groups"
has "$GA" '  logger tiffinbox: {"configuredLevel": null, "effectiveLevel": "INFO"}' "groups: tiffinbox"
has "$GA" '  logger com.tiffinbox.web.TiffinBoxServer: {"configuredLevel": null, "effectiveLevel": "INFO"}' "groups: Spring's logger for TiffinBox"
has "$GA" '  {"configuredLevel":null,"members":["tiffinbox","com.tiffinbox"]} 200' "groups: the group alone"
x groups '^\$ cd \.harness/serve && java -jar tiffinbox-web/target/tiffinbox-web-1\.0\.0\.jar --tiffinbox\.port=19033 --logging\.level\.web=debug$'
x groups '^\$ cd \.harness/serve && java -jar tiffinbox-web/target/tiffinbox-web-1\.0\.0\.jar --tiffinbox\.port=19033 --logging\.level\.sql=debug$'
[ "$(cnt "$GB" "  its DEBUG lines: 0 · tiffinbox: 0 route lines, 0 answer lines · no other logger")" = 2 ] || die "groups: web and sql, zero DEBUG lines each"
[ "$(n groups "^$SEVEN\$")" = 3 ] || die "groups: the seven, three times"
has "$GB" "  logging.structured.format.console: its values ecs gelf logstash" "groups: structured logging, Boot's metadata"
has "$GB" "  logging.group: java.util.Map<java.lang.String,java.util.List<java.lang.String>>" "groups: a group is a name and a list"
echo "  groups: kitchen (2), sql (3), web (5) · web and sql at DEBUG: 0 DEBUG lines each · the seven unchanged · structured: ecs gelf logstash"

# "Three requests at INFO: zero lines. POST debug to the kitchen group: two hundred four. Three more requests: three lines. POST
# null: back to INFO, three more requests, still three. The same process listened the whole time."
R1=$(blk runtime 'INFO - three requests' 'the README'"'"'s POST - the group to DEBUG'); R2=$(blk runtime 'the README'"'"'s POST - the group to DEBUG' 'the README'"'"'s POST - the group back to null'); R3=$(blk runtime 'the README'"'"'s POST - the group back to null' '')
[ "$(cnt "$R1" '  200')" = 3 ] && has "$R1" "  answer lines in its log: 0" "runtime: INFO, 0" || die "runtime: three requests at INFO"
has "$R2" "   204" "runtime: 204"; has "$R2" '  {"configuredLevel":"DEBUG","effectiveLevel":"DEBUG"} 200' "runtime: DEBUG"
[ "$(cnt "$R2" "  ${ANS}GET /customers -> 200")" = 3 ] && has "$R2" "  answer lines in its log: 3" "runtime: 3" || die "runtime: three lines"
has "$R3" "   204" "runtime: null 204"; has "$R3" '  {"configuredLevel":null,"effectiveLevel":"INFO"} 200' "runtime: INFO again"
has "$R3" "  answer lines in its log: 3" "runtime: still 3"; has "$R3" "  the process listening on 19034: the one started above: yes" "runtime: one process"
has "$R3" "  its DEBUG lines: 3 · tiffinbox: 0 route lines, 3 answer lines · no other logger" "runtime: the whole log, after the stop"
has "$R3" "$SEVEN" "runtime: the seven"
echo "  runtime: 0 -> 204 -> 3 -> 204 -> 3, one process"

# "read-only: the same POST answers four hundred five, and the level stays. Like Boot's own adapter, the bridge takes a write only as
# JSON: without that content type, or with no body at all, four fifteen, and the group stays." (RED C5-S4 #46: the bridge's request
# handling, fixed in the Actuator lesson's anchor)
K1=$(blk lock 'the lock - ' 'C (labelled) - the writes'); K2=$(blk lock 'C (labelled) - the writes' 'C (labelled) - the group to DEBUG'); K3=$(blk lock 'C (labelled) - the group to DEBUG' '')
has "$K1" '  {"error":"method not allowed"} 405' "lock: 405"; has "$K1" '  {"configuredLevel":null,"members":["tiffinbox","com.tiffinbox"]} 200' "lock: the level stays"
x lock '^\$ cd \.harness/serve && java -jar tiffinbox-web/target/tiffinbox-web-1\.0\.0\.jar --tiffinbox\.port=19035 --management\.endpoints\.web\.exposure\.include=health,prometheus,loggers --management\.endpoint\.loggers\.access=read-only$'
[ "$(printf '%s\n' "$K2" | sed -n '/^the README.s POST without a JSON Content-Type/,/^the README.s POST with no body:$/p' | grep -cxF -e '  {"error":"unsupported media type"} 415' -e '  {"configuredLevel":null,"members":["tiffinbox","com.tiffinbox"]} 200')" = 2 ] || die "lock: no JSON Content-Type, 415 and the group unchanged"
[ "$(printf '%s\n' "$K2" | sed -n '/^the README.s POST with no body:$/,$p' | grep -cxF -e '  {"error":"unsupported media type"} 415' -e '  {"configuredLevel":null,"members":["tiffinbox","com.tiffinbox"]} 200')" = 2 ] || die "lock: no body, 415 and the group unchanged"
[ "$(printf '%s\n' "$K2" | grep -c ' 204$')" = 0 ] || die "lock: a refused write answered 204"
has "$K3" '  {"configuredLevel":"DEBUG","members":["tiffinbox","com.tiffinbox"]} 200' "lock: the group still says DEBUG"
has "$K3" '  {"configuredLevel":"INFO","effectiveLevel":"INFO"} 200' "lock: the member, INFO"
has "$K3" '  {"configuredLevel":"DEBUG","effectiveLevel":"DEBUG"} 200' "lock: the other member, DEBUG"
has "$K3" "  answer lines in its log: 0" "lock: the member's last write wins"
[ "$(n lock "^$SEVEN\$")" = 2 ] || die "lock: the seven, twice"
echo "  lock: read-only 405, level unchanged · no JSON Content-Type 415 · no body 415 · the group unchanged · group DEBUG then member INFO: the member's write wins, the group still says DEBUG"

# "A: the group at debug, one request, one answer line. B: only com dot tiffinbox, the same request, zero answer lines ... All B
# prints is Spring's own line about TiffinBox. A again: one. And at trace, on every logger, the seven requests leave the token zero
# times in the log."
NA=$(blk names 'A - ' 'B - '); NB=$(blk names 'B - ' "A' - "); NA2=$(blk names "A' - " 'C (labelled) - a group'); NP=$(blk names 'C (labelled) - a group' 'C (labelled) - every logger'); NT=$(blk names 'C (labelled) - every logger' '')
SPRING='  <time> DEBUG <pid> --- [           main] com.tiffinbox.web.TiffinBoxServer        : Running with Spring Boot v4.1.1, Spring v7.0.9'
for b in "$NA" "$NA2"; do has "$b" "  its DEBUG lines: 7 · tiffinbox: 5 route lines, 1 answer lines · com.tiffinbox.web.TiffinBoxServer: 1" "names A: one answer line"; has "$b" "  ${ANS}GET /customers -> 200" "names A: the line"; has "$b" "$SPRING" "names A: Spring's line"; done
has "$NB" "  its DEBUG lines: 1 · tiffinbox: 0 route lines, 0 answer lines · com.tiffinbox.web.TiffinBoxServer: 1" "names B: zero answer lines"
has "$NB" "$SPRING" "names B: Spring's own line about TiffinBox"; [ "$(cnt "$NB" "  ${ANS}GET /customers -> 200")" = 0 ] || die "names B: no answer line"
[ "$(printf '%s\n' "$NA" | grep '^\$ cd ')" = "$(printf '%s\n' "$NA2" | grep '^\$ cd ')" ] || die "names: A' is not A's command"
[ "$(cnt "$NP" "  its DEBUG lines: 7 · tiffinbox: 5 route lines, 1 answer lines · com.tiffinbox.web.TiffinBoxServer: 1")" = 2 ] || die "names C: the group won, both orders"
for r in 'GET /customers -> 200' 'GET /revenue -> 200' 'GET /dashboard -> 200' 'GET /kitchen -> 200' 'UNKNOWN -> 405' 'POST /shutdown -> 200'; do has "$NT" "  $ANS$r" "names C, TRACE: the answer lines"; done
[ "$(printf '%s\n' "$NT" | grep -c "^  <time> DEBUG ")" = 6 ] || die "names C, TRACE: six answer lines for the seven"
has "$NT" "$LOGOK" "names C, TRACE: no token, no header"; x names '^  its log, against a floor: over 1,000 lines: yes · its answer lines:$'
[ "$(n names "^$SEVEN\$")" = 6 ] || die "names: the seven, six times"
echo "  names: A 1 answer line · B 0 (Spring's 1 line) · A' 1 · both orders at start: the group won · TRACE: 6 answer lines, 0 tokens, 0 header names"

# "In the AOT jar and the native binary, loggers by flag answers four hundred four, so a level changes only at start: the kitchen
# flag still prints the answer's line. Build a copy with loggers in its list, and the AOT jar switches live."
NRES='^  exit 0 · BUILD SUCCESS · stages it printed: 8 of the 8 it announces · its duration, against the bound: 1 minute or more, under 20 minutes · offline: yes$'
[ "$(n native "$NRES")" = 1 ] || die "native: one native build, 8 of 8, inside the bound, offline"
x native '^  built \.harness/nat \(both modules, into \$M2\) · offline: yes · exit 0$'
x native '^  file: Mach-O 64-bit executable · the demo token in its bytes: 0$'
for lb in 'the AOT jar - the README'"'"'s AOT line with the README'"'"'s loggers flag' 'the binary - the README'"'"'s line with the loggers flag'; do
  b=$(awk -v a="$lb" 'index($0, a) == 1 { f = 1; print; next } f && /^(the AOT jar|the binary|C \(labelled\))/ { f = 0 } f' .r-native.out)
  [ "$(cnt "$b" '  {"error":"not found"} 404')" = 2 ] || die "native: loggers by flag, 404 twice ($lb)"; done
for lb in 'the AOT jar - the README'"'"'s AOT line with the README'"'"'s kitchen flag' 'the binary - the README'"'"'s line with the kitchen flag'; do
  b=$(awk -v a="$lb" 'index($0, a) == 1 { f = 1; print; next } f && /^(the AOT jar|the binary|C \(labelled\))/ { f = 0 } f' .r-native.out)
  printf '%s\n' "$b" | grep -q "^  Boot's first line: Starting AOT-processed TiffinBoxServer" || die "native: AOT-processed ($lb)"
  has "$b" "  its DEBUG lines: 7 · tiffinbox: 5 route lines, 1 answer lines · com.tiffinbox.web.TiffinBoxServer: 1" "native: the level at start ($lb)"
  has "$b" "  ${ANS}GET /customers -> 200" "native: the answer's line ($lb)"
  has "$b" "  200 text/plain;version=0.0.4;charset=utf-8" "native: the scrape ($lb)"
  has "$b" '  its line for the request: tiffinbox_requests_seconds_count{route="GET /customers",status="200"} 1' "native: the scrape counts the request ($lb)"
  has "$b" "  the demo token in it: 0 · deleted: yes" "native: the scrape, counted and deleted ($lb)"; done
NC=$(blk native 'C (labelled) - loggers in the list' '')
has "$NC" '  >         include: health,prometheus,loggers' "native C: the list"; has "$NC" '  {"configuredLevel":null,"members":["tiffinbox","com.tiffinbox"]} 200' "native C: loggers 200"
has "$NC" "   204" "native C: the POST"; has "$NC" "  ${ANS}GET /customers -> 200" "native C: the line"
[ "$(n native "^$SEVEN\$")" = 5 ] || die "native: the seven, five times (the AOT jar twice, the binary twice, the copy)"
echo "  native: 1 build, 8 of 8, offline · the AOT jar and the binary: loggers by flag 404 (GET and POST), the kitchen flag at start: the answer's line, the scrape 200 counting it · C: loggers in the built list - 200, 204, the line"

# the exercise's end state: the line exercise/README.md calls "Done" is a line of this capture, after the solution's line - and of
# SOLUTION.md's measured run
XE=$(blk exercise "the solution's line" '')
l='loggers/tiffinbox DEBUG · loggers/com.tiffinbox INFO · request DEBUG lines 1'
has "$XE" "$l" "exercise"
awk '/^\*\*Done\*\*/ { f = 1 } f' exercise/README.md | grep -qxF -- "$l" || die "exercise/README.md: Done names no such line"
grep -qxF -- "$l" exercise/solution/SOLUTION.md || die "SOLUTION.md: the measured run shows no such line"
x exercise '^  exit 0 · printed: 0 line\(s\)$'
x exercise '^POST /shutdown -> 200 · curl exit 0$'
x exercise '^  exit 0 · listening on 19039 now: 0$'
echo "  exercise: the README as written, then the solution's line -> tiffinbox DEBUG, com.tiffinbox INFO, 1 request line"

# the anchor's README states the same numbers
for t in '`GET /customers -> 200`' '`UNKNOWN -> 405`' '**`logging.group.kitchen: tiffinbox, com.tiffinbox`**' '`org.slf4j.bridge.SLF4JBridgeHandler`' 'appender, `CONSOLE`' 'three requests at INFO, 0 lines; the POST, `204`; three more, 3 lines; `null`, `204`; three more,' 'The POST answers `405`, and the level stays' 'answers `415` here' '`web` (5 members) and `sql` (3)' 'its `.level = FINE`' '`loggers` by flag answers 404' 'the log holds the token 0 times and the header'"'"'s name 0 times' 'print their six lines' 'Spring'"'"'s one line about TiffinBox and 0 lines per answer' 'the seven requests add six'; do
  grep -qF -- "$t" after/README.md || die "after/README.md no longer states: $t"; done
cmp -s after/README.md ../c5-tiffinbox/README.md || echo "  (after/README.md and ../c5-tiffinbox/README.md differ - the anchor has moved past this unit's after/: it is unit 27's after/ now)" >&3
[ -z "$unpub" ] || die "no published hash for:$unpub - check the captures, then copy the md5s above into receipts.md5 and run again"
echo "c5-unit24: every capture 3/3 and = published; every spoken number asserted; 0 raw demo tokens in every capture, every saved answer and every run's log"
