#!/bin/bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25.0.4.1 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# GRAALVM_HOME names a GraalVM JDK 25 (README.md, "The GraalVM"): the native build reads it. Without it, this script makes every
# capture that needs no GraalVM - the JVM's, and the exercise's - filling .m2-demo on the way, then stops before the native build.
# Course 5 · Failure Analysis - this unit's receipts. Started twice on one port, TiffinBox's second start died under forty stack
# frames and not one sentence from Boot: Boot's own port analyzer serves Boot's own web servers. The anchor change (brief ⚑8):
# PortTakenFailureAnalyzer.java (new: a failure analyzer for java.net.BindException, Boot's Environment through its constructor,
# the address and the port, nothing else), tiffinbox-web/src/main/resources/META-INF/spring.factories (new: its one line) and
# TiffinBoxServer.java (handle()'s catch around a route: Exception | LinkageError - a missing class answers 500 instead of leaving
# the client waiting). Nine captures, each run three times and hashed; cap() DIES when a hash differs from receipts.md5; every
# number the video says is asserted at the bottom by a check that can fail; the demo token is masked (gsub), and the checks count
# 0 raw copies of it in every capture, in the log of every run - every failed start's report included - in every answer saved on
# the way, in every file this unit ships, and in the two binaries it builds.
#   taken      the previous tree started twice on one port: the second exits 1 - its log's shape (frames, its exceptions, no
#              analysis); the first one still serves the seven
#   analyzers  after/ built and extracted: Boot's failure analyzers by jar (each jar's spring.factories, parsed), and the two jars
#              that hold Boot's port analyzer, not shipped; the README's malformed-value line - Boot's analysis, the value printed
#   cycle      the harness's Cook and Rail (each needs the other, through a setter): plain Spring starts them; joined to after/,
#              Boot's default stops the start - the cycle drawn; Boot's metadata for the switch; the README's switch: the seven
#   change     the previous tree against after/: the new analyzer (its code lines), its factories line, the catch clause and
#              its ERROR line, the bridge's catch and its ERROR lines
#   analysis   the break, the analyzer's one line, a first TiffinBox holding the port: A after/ · B the line deleted · A' = A; then
#              C (labelled): the same class as a @Component, no factories file - Boot's loader of analyzers (javap), and that bean,
#              read from its context; D (labelled): an address this machine does not have; E (labelled): another bean's bind on
#              the held port (the harness's Elsewhere) - neither is TiffinBox's port taken, and neither gets the analysis
#   debug      after/, the port held, the README's --debug line: the trace back beside the analysis, the condition report counted
#   hang       C (labelled): the failure after the start - the README's lines delete one class jackson-databind needs from a copy
#              of the extracted lib; the previous tree's catch, then after/'s: no answer against a 500, the log's line, the timer;
#              then after/'s copy at INFO: the error in the log, and the bridge's catch - a body it cannot read, logged by its class
#   native     after/ built natively (the README's two Maven lines): what Spring's AOT step registered, the AOT jar and the binary
#              each started twice on one port; then C (labelled): the hints lesson's break, the route annotation's @Reflective
#              deleted, built natively - a 500 where that lesson's binary never answered, and the error in its log
#   exercise   exercise/README.md's commands and exercise/solution/SOLUTION.md's, read from the files and run as written
# "before" is ../c5-unit24/after (the anchor as the logging lesson left it), COPIED under .harness/; this script never writes into
# another unit's folder. after/ is this unit's frozen copy of ../c5-tiffinbox after the change; it is copied, never built in
# place. Every run of TiffinBox starts in a folder under .harness/ that holds a config tree with the demo token (secrets/), as the
# README asks. Commands are printed exactly as they run: each goes through eval. "$CURLSET" is the comparison set since the secrets
# lesson (../c5-unit11/curlset.sh: the seven requests, POST /shutdown with the token's header read from the file). "$M2" is this
# unit's own repository, .m2-demo. The harness (harness/probe/cycle/: Cook, Rail, Plain, Tally; harness/probe/bind/: Elsewhere) is
# compiled into .harness/hc and joined by --spring.main.sources (Plain runs alone): it lives outside com.tiffinbox, and it is the
# course's, never TiffinBox's.
# The network: every build runs offline (-o) against .m2-demo and says so ("offline: yes"); a build that cannot resolve an
# artifact offline goes to Maven Central once, and says that ("offline: no - ..."). GraalVM's native plugin, under the profile
# native, reads its metadata repository (a zip) from .m2-demo - and when the zip is not there it downloads it from GitHub, even
# under -o (README.md, The repository): so a native-profile build without the zip goes to Maven Central for it at once, never
# offline first, and every build's log is searched for the plugin's own download line - found, the run stops. At run time nothing
# leaves 127.0.0.1: TiffinBox listens there, every request goes there, and Logback writes to the terminal only.
# Masks and filters (README.md declares each; sub/gsub only): the demo token becomes "[masked: the 26-character token]"; the
# GraalVM's folder "$GRAALVM_HOME"; this folder's absolute path "…", the folder above it "…/..", the home folder "~"; your user
# name "<user>" - in every line of every capture. A failed start's log is read after it exited, never printed whole: its stack
# frames, its "Caused by:" lines and the frames Logback folds as common are counted, never shown (a frame carries a line number);
# the first line of each exception, the WARN, ERROR and DEBUG lines from their level on (a WARN's message cut after its
# exception's class, marked " …"), Boot's hint about the condition report, the condition report's sections (counted) and the
# analysis - from "Description:" to its end, blank lines left out - are shown. A running TiffinBox's answer lines are read after
# it stopped, with their time, process id and virtual thread masked. Boot's first line is printed from its message on, cut
# before " with PID". The beans answer is written beside the run's config tree, read through a filter and deleted. No duration
# is captured: the native builds are judged against a bound; seconds go to the terminal.
# Ports (brief ⚑10, 19050-19059): taken 19050 · cycle 19051 · analysis 19052 and 19053 · debug 19054 · hang 19055 · native 19056
# and 19057 · exercise 19059; 19058 is checked and never used. analyzers' one start fails before TiffinBox opens a port. 18425
# (TiffinBox's default) and 8080 (Tomcat's) are checked free too.
set -e
# bash 5.2 and later turn an & in the replacement of ${x/pattern/replacement} into the matched text (patsub_replacement, on by
# default): start()'s "&& exec " would become "&& && exec ". Switched off, so /bin/bash 3.2 (./receipts.sh) and a newer bash
# (bash receipts.sh) run the same commands; 3.2 has no such option.
shopt -u patsub_replacement 2> /dev/null || true
cd "$(dirname "$0")"
# One run at a time: two runs share .harness/ and the ports, and one would corrupt the other.
mkdir .r-lock 2> /dev/null || { echo "  *** another receipts.sh is running in this folder (.r-lock exists) - if none is, rmdir .r-lock ***"; exit 1; }
# On every exit - the end, a failed check, or Ctrl-C - stop the processes this script started in the background ($pid, a server;
# $fpid, a start expected to fail), if they still run (a background job of a non-interactive shell ignores the terminal's
# Ctrl-C), then sweep(): anything of this run still alive in its process group - a TiffinBox JVM (a jar, an extracted class path,
# the thin jar of the hang's copy), the harness's Plain, a binary, native-image's driver or builder - is stopped. Then the answers
# saved on the way, if a run left one. After an interrupt, a capture's unfinished runs (.r-NAME.1-3) go too; after a failed check
# they stay, for the diff the message names. The clean-up ignores a second Ctrl-C, and nothing in it can fail under set -e, so it
# always reaches the rmdir; the script still exits 130 after an interrupt (tested: README.md, "Interrupted"). $pid and $fpid are
# cleared whenever their process has been reaped.
pid=""; fpid=""
sweep() { local g i l
  g=$(ps -o pgid= -p $$ 2> /dev/null | tr -d ' ') || g=""
  [ -n "$g" ] || return 0
  i=0; while [ $i -lt 20 ]; do
    l=$(ps -axo pid=,pgid=,command= 2> /dev/null | awk -v g="$g" -v me=$$ -v gh="${GRAALVM_HOME:-/nonexistent}" '
      $2 == g && $1 != me && $3 != "awk" && $3 != "ps" && (index($0, "vminvocation.args") || index($3, gh "/bin/native-image") || $3 ~ /tiffinbox-web\/target\/tiffinbox-web$/ || index($0, "tiffinbox-web-1.0.0.jar") || index($0, "com.tiffinbox.web.TiffinBoxServer") || index($0, "probe.cycle.Plain")) { print $1 }' | paste -sd' ' -) || l=""
    [ -n "$l" ] || return 0
    if [ $i -lt 10 ]; then kill $l 2> /dev/null || true; else kill -9 $l 2> /dev/null || true; fi
    sleep 0.5; i=$((i + 1)); done; }
machinefiles() { rm -f .harness/*/beans.json .harness/*/scrape.txt 2> /dev/null || true; }
trap 'trap "" INT TERM; for p in "$pid" "$fpid"; do if [ -n "$p" ] && kill "$p" 2> /dev/null; then wait "$p" 2> /dev/null || true; fi; done; sweep || true; machinefiles; [ -z "$INTR" ] || rm -f .r-*.[123]; rmdir .r-lock 2> /dev/null || true' EXIT
INTR=""; trap 'INTR=1; exit 130' INT TERM
exec 3>&1                                            # die() speaks to the terminal even inside a redirected capture
die() { echo "  *** $* ***" >&3; exit 1; }
java -version 2>&1 | grep -q 'version "25' || die "JDK 25 needed; JAVA_HOME gives: $(java -version 2>&1 | head -1)"
command -v javac > /dev/null || die "javac is needed: the harness's classes are compiled here"
command -v python3 > /dev/null || die "python3 is needed: the jars' spring.factories, Boot's metadata and the beans answer are read through a filter"
command -v curl > /dev/null || die "curl is needed: every request here is curl's"
command -v zip > /dev/null && command -v unzip > /dev/null || die "zip and unzip are needed: the hang's lines delete a class from a copy of a jar"
# A variable of yours must not become a property source, a JVM flag, a build setting or a native-image option: every
# TIFFINBOX_*, SPRING_*, MANAGEMENT_*, SERVER_* and LOGGING_* variable, DEBUG (Boot reads it as --debug), the variables that inject
# JVM flags, MAVEN_OPTS, MAVEN_ARGS and NATIVE_IMAGE_OPTIONS are removed first. GRAALVM_HOME stays: it says which GraalVM to use.
# (A DEBUG of yours would print the condition report and the trace in every failed start a capture counts.)
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
PREV=../c5-unit24/after                              # the previous tree: read, copied, never built in place
JAR=tiffinbox-web/target/tiffinbox-web-1.0.0.jar
BIN=tiffinbox-web/target/tiffinbox-web               # the binary native:compile-no-fork writes, in a tree's web module
TF=secrets/tiffinbox/shutdown-token                  # the config tree's file for tiffinbox.shutdown-token
SRV=tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java
ANA=tiffinbox-web/src/main/java/com/tiffinbox/web/PortTakenFailureAnalyzer.java
FAC=tiffinbox-web/src/main/resources/META-INF/spring.factories
ROUTE=tiffinbox-web/src/main/java/com/tiffinbox/web/Route.java
EXL=tiffinbox-web/target/extracted/lib               # the extracted jar's lib/, in a tree's web module
AOTMETA=tiffinbox-web/target/spring-aot/main/resources/META-INF/native-image/com.tiffinbox/tiffinbox-web/reachability-metadata.json
# The demo token. FAKE, and meant to look it: it guards nothing but a demo server on 127.0.0.1 that every capture stops. It is
# written into .harness/*/secrets/ (git-ignored) when this script runs, and no capture prints it: see mask().
TOKEN=not-a-real-token-demo-only
[ ${#TOKEN} = 26 ] || die "the demo token must be 26 characters"
CURLSET=../c5-unit11/curlset.sh                      # the comparison set: the seven requests, POST /shutdown with the header
[ -f "$CURLSET" ] || die "$CURLSET is missing"
[ -f "$PREV/pom.xml" ] && [ -f after/pom.xml ] && [ -f after/README.md ] || die "the previous tree $PREV or after/ is missing"
for f in harness/shutdown.sh harness/seven.sh harness/jars/pom.xml harness/probe/cycle/Cook.java harness/probe/cycle/Rail.java harness/probe/cycle/Plain.java harness/probe/cycle/Tally.java harness/probe/bind/Elsewhere.java; do [ -f "$f" ] || die "harness/ is missing $f"; done

# The ports, BEFORE anything is wiped (a survivor of an interrupted run answers POST /shutdown only with its token, which lives
# in .harness/ - so the message names the process to kill).
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
for p in 18425 8080 19050 19051 19052 19053 19054 19055 19056 19057 19058 19059; do
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
R_BINK=$(readme 'tiffinbox-web/target/tiffinbox-web --tiffinbox.port=18431 --logging.level.kitchen=debug')
R_EXTRACT=$(readme 'java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted')
R_CP=$(readme 'java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431')
R_READY=$(readme "curl -s -w ' %{http_code}\n' http://127.0.0.1:18431/actuator/health/readiness")
R_STATUS=$(readme "curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:18431/customers/7")
R_DEBUGRUN=$(readme 'java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --debug')
R_NINETEEN=$(readme 'java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=nineteen')
R_CIRC=$(readme 'java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --spring.main.allow-circular-references=true')
R_BEANS=$(readme 'java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --management.endpoints.web.exposure.include=health,prometheus,metrics,beans')
R_BEANSGET=$(readme "curl -s -o beans.json -w '%{http_code}\n' http://127.0.0.1:18431/actuator/beans")
R_H1=$(readme 'rm -rf tiffinbox-web/target/hang && mkdir tiffinbox-web/target/hang && cp tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar tiffinbox-web/target/hang/ && cp -R tiffinbox-web/target/extracted/lib tiffinbox-web/target/hang/lib')
R_H2=$(readme "zip -q -d tiffinbox-web/target/hang/lib/jackson-databind-2.22.2.jar 'com/fasterxml/jackson/databind/jdk14/JDK14Util*'")
R_H3=$(readme 'java -jar tiffinbox-web/target/hang/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --logging.level.kitchen=debug')
R_H4=$(readme "curl -s -m 5 -w ' %{http_code}\n' http://127.0.0.1:18431/customers")
R_H5=$(readme 'java -jar tiffinbox-web/target/hang/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --management.endpoints.web.exposure.include=health,prometheus,sbom')
R_H7=$(readme "curl -s -w ' %{http_code}\n' http://127.0.0.1:18431/actuator/sbom")
R_H6=$(readme "curl -s -X GET -d 'oops, not json' -w ' %{http_code}\n' http://127.0.0.1:18431/actuator/health")
R_ADDR=$(readme 'java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --tiffinbox.address=192.0.2.1')
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
# hcp DIR PORT SOURCES ['FLAGS']: the README's exploded run - the extracted jar on the class path, TiffinBox's own main - from
# DIR, its port made PORT, the harness's classes added to the class path (../hc) and SOURCES joined (--spring.main.sources); FLAGS
# after
hcp() { local c; c=$(at "$1" "$2" "$R_CP"); c=${c/lib\/\*\"/lib\/*:..\/hc\"}; printf '%s --spring.main.sources=%s%s\n' "$c" "$3" "${4:+ $4}"; }
# plain DIR: the same class path, the harness's Plain as the main class instead of TiffinBox's (no port, no Boot)
plain() { local c; c=$(at "$1" 18431 "$R_CP"); c=${c/lib\/\*\"/lib\/*:..\/hc\"}; printf '%s probe.cycle.Plain\n' "${c% com.tiffinbox.web.TiffinBoxServer *}"; }
F_DEBUG=$(flag "$R_DEBUGRUN"); F_CIRC=$(flag "$R_CIRC"); F_BEANS=$(flag "$R_BEANS"); F_KITCHEN=$(flag "$R_BINK")
[ "$F_DEBUG" = --debug ] && [ "$F_CIRC" = --spring.main.allow-circular-references=true ] && [ "$F_BEANS" = --management.endpoints.web.exposure.include=health,prometheus,metrics,beans ] && [ "$F_KITCHEN" = --logging.level.kitchen=debug ] || die "a README flag line does not end in its one flag"
K=/kitchen; R_K5=${R_H4/\/customers/$K}             # the hang's curl line, its path /customers made /kitchen (native C)
[ "$R_K5" = "curl -s -m 5 -w ' %{http_code}\n' http://127.0.0.1:18431/kitchen" ] || die "the five-second line for /kitchen"
C_AFTER=$(off .harness/after "$R_INSTALL" install)
for c in "$C_AFTER" "$(off .harness/x "$R_PLAIN" package)" "$(off .harness/x "$R_NATIVE")"; do
  r=$(dev "$c"); [ "$r" = "$R_PLAIN" ] || [ "$r" = "$R_INSTALL" ] || [ "$r" = "$R_NATIVE" ] || die "not a README line with the offline changes: $c"; done
[ "$(hcp .harness/x 19051 probe.cycle.Cook,probe.cycle.Rail "$F_CIRC")" = 'cd .harness/x && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19051 --spring.main.sources=probe.cycle.Cook,probe.cycle.Rail --spring.main.allow-circular-references=true' ] || die "the exploded run with the harness"
[ "$(plain .harness/x)" = 'cd .harness/x && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" probe.cycle.Plain' ] || die "the harness's Plain"
[ "$(hcp .harness/x 19053 probe.bind.Elsewhere --probe.bind.port=19052)" = 'cd .harness/x && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19053 --spring.main.sources=probe.bind.Elsewhere --probe.bind.port=19052' ] || die "the exploded run with the harness's Elsewhere"
echo "  the commands: after/README.md gives all 27 lines this script runs or derives from"

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
# The first build is the README's native install: it needs nearly every artifact the captures' Maven lines need - the plain ones,
# the profile native's (process-aot, the plugin's add-reachability-metadata and its metadata repository) and install's - so on a
# fresh clone, whose .m2-demo is empty (git ignores it), this one build fills .m2-demo from Maven Central, once.
mbuild "$C_AFTER" .harness/build-after.log ".harness/after (after/, the profile native, both modules into \$M2)"
[ -f "$M2/org/springframework/boot/spring-boot-starter-parent/4.1.1/spring-boot-starter-parent-4.1.1.pom" ] || die "Boot's parent POM is not in .m2-demo after the first build"
[ -f "$M2/org/graalvm/buildtools/native-maven-plugin/1.1.8/native-maven-plugin-1.1.8.jar" ] || die "GraalVM's native plugin 1.1.8 is not in .m2-demo after the first build (it is a build extension of the web module)"
[ -f "$ZIP" ] || die "GraalVM's metadata repository is not in .m2-demo after the first build - README.md, The repository"
# Boot's web-server and Tomcat modules: the analyzers capture reads their spring.factories from $M2 - TiffinBox never ships them,
# so no build of TiffinBox's fetches them. The harness's POM (harness/jars/pom.xml: the two jars alone, every transitive dependency
# excluded, no code) resolves them from a copy under .harness/, the way every build resolves (offline, or Maven Central once, and
# the line says which) - on a fresh clone, from Maven Central, once.
rsync -a harness/jars/ .harness/jars/
mbuild 'cd .harness/jars && mvn -o -B -Dmaven.repo.local="$M2" -q compile' .harness/jars.log "the harness's POM for Boot's web-server and Tomcat modules (their two jars, into \$M2)"
for a in spring-boot-web-server spring-boot-tomcat; do [ -f "$M2/org/springframework/boot/$a/4.1.1/$a-4.1.1.jar" ] || die "Boot's $a 4.1.1 is not in .m2-demo"; done
echo "  .m2-demo holds Boot's parent, GraalVM's native plugin 1.1.8 and its metadata repository ($(wc -c < "$ZIP" | tr -d ' ') bytes), and Boot's web-server and Tomcat modules 4.1.1"
# The harness: Cook, Rail and Plain compiled against the jar the first build made (extracted: its classes and the jars it ships),
# into .harness/hc - outside every tree, outside com.tiffinbox
(cd .harness/after && eval "$R_EXTRACT") > .harness/extract-after.log 2>&1 || { cat .harness/extract-after.log >&3; die "the README's extract command failed in .harness/after"; }
javac -d .harness/hc -cp ".harness/after/tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:.harness/after/$EXL/*" harness/probe/cycle/*.java harness/probe/bind/*.java > .harness/javac.log 2>&1 || { cat .harness/javac.log >&3; die "the harness did not compile"; }
echo "  the harness: harness/probe/cycle/ and bind/ compiled into .harness/hc ($(find .harness/hc -name '*.class' | wc -l | tr -d ' ') classes)"

# ---- helpers ------------------------------------------------------------------------------------------------------------
# raw TOKEN FILE...: how many times TOKEN appears, raw, in the files (occurrences, not lines; binary files read as text)
raw() { local t=$1; shift; cat "$@" | LC_ALL=C grep -aoF -- "$t" | wc -l | tr -d ' '; }
SEEN=0                                               # how many answers saved on the way were counted for the token, raw
LOGS=0                                               # how many runs' logs were counted for the token and its header
FLOGS=0                                              # how many failed starts' logs were counted for the token
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
status() { ask "$(topath "$R_STATUS" "$1")" "$2"; }
# get DIR PORT 'README curl LINE': the README's line that writes a file (beans.json), run from DIR - beside the run's config
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
# scraped PORT 'ROUTE': the same barrier for an answer whose status the capture is there to show: the scrape asked until it has a
# count for ROUTE, whatever the status; then its line for ROUTE, printed
scraped() { local i=0 c=""
  while [ $i -lt 150 ]; do
    c=$(curl -s "http://127.0.0.1:$1/actuator/prometheus" 2> /dev/null | grep -F "tiffinbox_requests_seconds_count{route=\"$2\"," || true)
    [ -n "$c" ] && break; sleep 0.1; i=$((i + 1)); done
  [ -n "$c" ] || die "the scrape on $1 never counted an answer for $2"
  echo "  the scrape's line for $2: $c"; }
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
# ends PORT: after a POST /shutdown the caller sent - the process must leave within 15 s, the port must be free; its exit code,
# then its log counted (logtok)
ends() { local i=0 e=0
  while kill -0 "$pid" 2> /dev/null && [ $i -lt 60 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$pid" 2> /dev/null && { kill "$pid"; die "the server on $1 was still running 15 s after POST /shutdown"; }
  wait "$pid" || e=$?; pid=""
  [ "$(listeners "$1")" = 0 ] || die "something still listens on $1"
  echo "  exit $e · listening on $1 now: 0"; logtok; }
# same PORT: whether the process listening on PORT is still the one this script started - no restart, the port never closed
same() { echo "  the process listening on $1: the one started above: $([ "$(lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null)" = "$pid" ] && echo yes || echo no)"; }
# A Boot log line, as Logback writes it: "<time> <LEVEL> <pid> --- [<thread>] <logger, padded to 40> : <message>".
# lmask: a log line's time, process id and a virtual thread's name (with its padding) masked - gsub, the rest of the line kept
lmask() { awk '{ gsub(/^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T[0-9][0-9]:[0-9][0-9]:[0-9][0-9]\.[0-9][0-9][0-9](Z|[+-][0-9][0-9]:[0-9][0-9])/, "<time>")
  gsub(/ [0-9]+ --- \[/, " <pid> --- ["); gsub(/\[ *virtual-[0-9]+\]/, "[    virtual-<n>]"); print }'; }
# answers LOG: TiffinBox's answer lines - its own logger's DEBUG lines that are not route lines (written at start) - whole, masked
answers() { awk '/^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T[^ ]+ +DEBUG +[0-9]+ --- \[/ {
    s = $0; i = index(s, " --- ["); s = substr(s, i + 6); i = index(s, "] "); s = substr(s, i + 2)
    i = index(s, " : "); lg = substr(s, 1, i - 1); sub(/ +$/, "", lg); msg = substr(s, i + 3)
    if (lg == "tiffinbox" && msg !~ /^route /) print }' "$1" | lmask | sed 's/^/  /'
  echo "  its answer lines: $(awk '/ DEBUG [0-9]+ --- .* tiffinbox +: / && !/ tiffinbox +: route / { n++ } END { print n + 0 }' "$1")"; }
# SHAPEAWK: a failed start's log (its standard output), read whole and printed as its shape: the analysis banner, the stack
# frames ("at" lines), the "Caused by:" lines and the frames Logback folds as common ("... N common frames omitted"), counted; the
# WARN, ERROR and DEBUG lines from their level on, a WARN's message cut after its exception's class (" …"); the first line of each
# exception, and the frames under each one ("stack frames 40 = 25 + 15"); Boot's hint about the condition report; the condition report's sections, counted; then the analysis, from
# "Description:" to its end, its blank lines left out
SHAPEAWK='
an { if (NF) ana[++na] = "  " $0; next }
/^Description:$/ { an = 1; ana[++na] = "  " $0; next }
/^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T[^ ]+ +[A-Z]+ +[0-9]+ --- \[/ {
  sec = ""; lv = $2; s = $0; i = index(s, " --- ["); s = substr(s, i + 6); i = index(s, "] "); s = substr(s, i + 2)
  i = index(s, " : "); lg = substr(s, 1, i - 1); sub(/ +$/, "", lg); msg = substr(s, i + 3)
  if (lv == "WARN" || lv == "ERROR" || lv == "DEBUG") {
    if (lv == "WARN" && match(msg, /attempt: [A-Za-z0-9_.$]+/)) msg = substr(msg, 1, RSTART + RLENGTH - 1) " …"
    ln[++nl] = "  " lv " " lg (msg == "" ? ":" : ": " msg) }
  next }
/^\tat / { fr++; if (ne) fx[ne]++; next }
/^\t\.\.\. [0-9]+ (common frames omitted|more)$/ { om += $2; next }
/^Caused by: / { cb++; ex[++ne] = "  " $0; next }
/^([a-z][a-z0-9_]*\.)+[A-Z][A-Za-z0-9_$]*(: .*)?$/ { ex[++ne] = "  " $0; next }
/^APPLICATION FAILED TO START$/ { ban++; next }
/^Error starting ApplicationContext\. To display the condition evaluation report re-run your application with .debug. enabled\.$/ { hint = $0; next }
/^CONDITIONS EVALUATION REPORT$/ { rep++; next }
/^Positive matches:$/ { sec = "pos"; next }
/^Negative matches:$/ { sec = "neg"; next }
/^Exclusions:$/ { sec = "exc"; next }
/^Unconditional classes:$/ { sec = "unc"; next }
sec == "pos" && /^   [^ ]/ { pos++ }
sec == "neg" && /^   [^ ]/ { neg++ }
sec == "unc" && /^    [^ ]/ { unc++ }
END {
  by = ""; for (i = 1; i <= ne; i++) by = by (i == 1 ? " = " : " + ") (fx[i] + 0)
  print "  its log, read after it exited: APPLICATION FAILED TO START " (ban + 0) " · stack frames " (fr + 0) (fr ? by : "") " · Caused by: " (cb + 0) " · frames folded as common " (om + 0)
  for (i = 1; i <= nl; i++) print ln[i]
  for (i = 1; i <= ne; i++) print ex[i]
  if (hint != "") print "  the hint Boot logs: " hint
  if (rep) print "  the condition report: CONDITIONS EVALUATION REPORT " rep " · positive matches " (pos + 0) " · negative matches " (neg + 0) " · unconditional classes " (unc + 0)
  for (i = 1; i <= na; i++) print ana[i] }'
# fails 'COMMAND': a start expected to fail, printed exactly as typed and run (eval, from this folder; exec, so $fpid is the
# program's own pid), its standard output to .harness/fail.out and its standard error to .harness/fail.err - bounded: polled for
# 60 s (no timeout command here); then its exit code, its log's shape (SHAPEAWK), its standard error's line count, and the demo
# token in both, raw - which must be 0
fails() { local e=0 i=0 t
  echo "\$ $1"; (eval "${1/&& /&& exec }") > .harness/fail.out 2> .harness/fail.err < /dev/null & fpid=$!
  while kill -0 "$fpid" 2> /dev/null && [ $i -lt 240 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$fpid" 2> /dev/null && { kill "$fpid"; die "a start expected to fail still ran after 60 s: $1"; }
  wait "$fpid" || e=$?; fpid=""
  echo "  exit $e"
  awk "$SHAPEAWK" .harness/fail.out
  t=$(raw "$TOKEN" .harness/fail.out .harness/fail.err); FLOGS=$((FLOGS + 1)); [ "$t" = 0 ] || die "a failed start's log held the demo token ($t)"
  echo "  its standard error: $(wc -l < .harness/fail.err | tr -d ' ') lines · the demo token in its log: $t"; }
# errs FILE: a running TiffinBox's standard error, read after it stopped: its uncaught exceptions, frames and "Caused by:" lines,
# counted; the first exception's line and its first cause's, shown
errs() { awk '/^Exception in thread / { n++; if (h == "") h = $0 } /^\tat / { fr++ } /^Caused by: / { cb++; if (c == "") c = $0 }
  END { print "  its standard error: uncaught exceptions " (n + 0) " · stack frames " (fr + 0) " · Caused by: " (cb + 0)
        if (h != "") print "    " h; if (c != "") print "    " c }' "$1"; }
# catches FILE: every catch clause in FILE's handle(), with its line number (the method's first line to its closing brace)
catches() { awk '/ void handle\(HttpExchange / { f = 1 } f && /catch \(/ { l = $0; sub(/^[ \t]+/, "", l); print "    " FNR ": " l } f && /^    }$/ { f = 0 }' "$1"; }
# code FILE: FILE's lines that are neither comment nor blank, their leading blanks kept
code() { grep -vE '^[[:space:]]*(\*|/\*\*|\*/|//|#|$)' "$1"; }
# census JAR...: each jar's META-INF/spring.factories, read like java.util.Properties (a line ending in a backslash continues on
# the next; # and ! start a comment), the key org.springframework.boot.diagnostics.FailureAnalyzer split at its commas - per jar
# that has it: its name, how many it names, then each one's simple class name; then the totals
census() { python3 - "$@" <<'PY'
import os, sys, zipfile
KEY = "org.springframework.boot.diagnostics.FailureAnalyzer"
def entries(text):
    out, buf = {}, None
    for line in text.splitlines():
        s = line.strip()
        if buf is None and (not s or s[0] in "#!"):
            continue
        cont = s.endswith("\\")
        part = s[:-1] if cont else s
        buf = part if buf is None else buf + part
        if cont:
            continue
        k, _, v = buf.partition("=")
        out.setdefault(k.strip(), []).extend(n.strip() for n in v.split(",") if n.strip())
        buf = None
    return out
jars = withkey = total = 0
for path in sorted(sys.argv[1:], key=lambda p: (os.path.basename(p).startswith("tiffinbox"), os.path.basename(p))):
    jars += 1
    with zipfile.ZipFile(path) as z:
        if "META-INF/spring.factories" not in z.namelist():
            continue
        text = z.read("META-INF/spring.factories").decode("utf-8")
    names = entries(text).get(KEY, [])
    if not names:
        continue
    withkey += 1; total += len(names)
    print("  %s: %d" % (os.path.basename(path), len(names)))
    for n in names:
        print("    " + n.rsplit(".", 1)[-1])
print("  jars read: %d · with the key: %d · analyzers named: %d" % (jars, withkey, total))
PY
}
# meta JAR NAME: Boot's own metadata for a property (META-INF/spring-configuration-metadata.json): its type, default, declarer
meta() { python3 - "$1" "$2" <<'PY'
import json, sys, zipfile
d = json.loads(zipfile.ZipFile(sys.argv[1]).read("META-INF/spring-configuration-metadata.json"))
for x in d["properties"]:
    if x["name"] == sys.argv[2]:
        print("  %s: %s · default %s · declared by %s" % (x["name"], x["type"], json.dumps(x.get("defaultValue")), x["sourceType"]))
PY
}
# beanof FILE NAME: the beans answer (JSON) through a filter - how many beans are named NAME, and each one's type and scope
beanof() { python3 - "$1" "$2" <<'PY'
import json, sys
d = json.load(open(sys.argv[1]))
found = [b for ctx in d["contexts"].values() for n, b in ctx["beans"].items() if n == sys.argv[2]]
print("  beans named %s in its context: %d" % (sys.argv[2], len(found)))
for b in found:
    print("    type %s · scope %s" % (b["type"], b["scope"]))
PY
}
# aotmeta FILE: what Spring's AOT step wrote for the binary about the analyzer (reachability-metadata.json, from process-aot): the
# resource META-INF/spring.factories, and the analyzer's reflection entry
aotmeta() { python3 - "$1" <<'PY'
import json, sys
d = json.load(open(sys.argv[1]))
res = [r.get("glob", r.get("pattern")) for r in d.get("resources", [])]
print("  the resource META-INF/spring.factories: %s" % ("yes" if "META-INF/spring.factories" in res else "no"))
hit = [e for e in d.get("reflection", []) if e.get("type") == "com.tiffinbox.web.PortTakenFailureAnalyzer"]
print("  reflection entries for com.tiffinbox.web.PortTakenFailureAnalyzer: %d%s" % (len(hit), "".join(" · " + " ".join(sorted(k for k, v in e.items() if v is True)) for e in hit)))
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
  for i in 1 2 3; do "$@" > .harness/cap.raw 2>&1 || true; [ -z "$pid" ] && [ -z "$fpid" ] || die "$nm left a process running"
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
# extract DIR: the README's extract line, from DIR (after a clean build: the destination must not exist)
extract() { echo "\$ cd $1 && $R_EXTRACT"
  (cd "$1" && eval "$R_EXTRACT") > "$1.extract.log" 2>&1 || { cat "$1.extract.log" >&3; die "the extract failed in $1"; }
  echo "  extracted: exit 0 · its lib/ holds $(ls "$1/$EXL" | wc -l | tr -d ' ') jars"; }

# ---- taken: the previous tree, started twice on one port --------------------------------------------------------------------
taken() {
  echo "the previous tree (the anchor as the logging lesson left it), copied to .harness/prev with a config tree, built the"
  echo "README's plain way; the README's run line, port 19050 - TiffinBox, started once:"
  copy "$PREV" .harness/prev
  pbuild .harness/prev "the previous tree"
  start "$(at .harness/prev 19050 "$R_RUN")"; up; ready 19050
  echo "and again - the same line, the same port, while the first one runs:"
  fails "$(at .harness/prev 19050 "$R_RUN")"
  echo "the first one, after the second exited:"
  same 19050
  seven 19050 .harness/prev all; }

# ---- analyzers: Boot's failure analyzers, by jar; a malformed value ----------------------------------------------------------
analyzers() {
  echo "after/, copied to .harness/serve with a config tree, built the README's plain way, then extracted (the README's extract line):"
  copy after .harness/serve
  pbuild .harness/serve "after/"
  extract .harness/serve
  echo "Boot's failure analyzers - every jar of the extracted class path (lib/, then the thin jar that holds TiffinBox's own"
  echo "classes): its META-INF/spring.factories, the key org.springframework.boot.diagnostics.FailureAnalyzer, its value parsed:"
  census ".harness/serve/$EXL/"*.jar .harness/serve/tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar
  echo "Boot's port analyzer - Boot's web-server module and its Tomcat module, read from \$M2; TiffinBox ships neither:"
  census "$M2/org/springframework/boot/spring-boot-web-server/4.1.1/spring-boot-web-server-4.1.1.jar" "$M2/org/springframework/boot/spring-boot-tomcat/4.1.1/spring-boot-tomcat-4.1.1.jar"
  echo "  in TiffinBox's lib/: spring-boot-web-server $(ls ".harness/serve/$EXL" | grep -c '^spring-boot-web-server-' || true) jars · spring-boot-tomcat $(ls ".harness/serve/$EXL" | grep -c '^spring-boot-tomcat-' || true) jars"
  echo "a malformed value - the README's line, a word where the port goes:"
  fails "cd .harness/serve && $R_NINETEEN"; }

# ---- cycle: Course 4's setter cycle, plain Spring and Boot --------------------------------------------------------------------
cycle() {
  echo "the harness's Cook and Rail (harness/probe/cycle/): each needs the other, through a setter. Plain Spring first - the"
  echo "harness's Plain registers the two in an AnnotationConfigApplicationContext, no Boot, on after/'s extracted class path:"
  echo "\$ $(plain .harness/serve)"
  (eval "$(plain .harness/serve)") 2>&1 < /dev/null | sed 's/^/  /'
  echo "Boot - the README's exploded run, the two joined by --spring.main.sources, port 19051:"
  fails "$(hcp .harness/serve 19051 probe.cycle.Cook,probe.cycle.Rail)"
  echo "  listening on 19051 now: $(listeners 19051) · TiffinBox's listening line in its log: $(grep -c 'TiffinBox listening on' .harness/fail.out || true)"
  echo "Boot's own metadata for the switch - spring-boot-4.1.1.jar's META-INF/spring-configuration-metadata.json, from the extracted lib:"
  meta ".harness/serve/$EXL/spring-boot-4.1.1.jar" spring.main.allow-circular-references
  echo "the README's switch, on the same run:"
  start "$(hcp .harness/serve 19051 probe.cycle.Cook,probe.cycle.Rail "$F_CIRC")"; up; ready 19051
  seven 19051 .harness/serve all
  echo "  its log: APPLICATION FAILED TO START $(grep -c 'APPLICATION FAILED TO START' .harness/run.out || true) · WARN lines $(grep -cE '^[0-9-]+T[^ ]+ +WARN ' .harness/run.out || true)"; }

# ---- change: the previous tree against after/ ---------------------------------------------------------------------------------
change() { local f
  echo "the previous tree against after/, both copied under .harness/ - the files that differ:"
  echo "\$ diff -rq -x target -x secrets .harness/before .harness/after"
  diff -rq -x target -x secrets .harness/before .harness/after | sed 's/^/  /' || true
  echo "  $ANA - new; its lines that are neither comment nor blank: $(code ".harness/after/$ANA" | wc -l | tr -d ' ')"
  code ".harness/after/$ANA" | sed 's/^/    /'
  echo "  $FAC - new; its lines that are neither comment nor blank: $(code ".harness/after/$FAC" | wc -l | tr -d ' ')"
  code ".harness/after/$FAC" | sed 's/^/    /'
  diff ".harness/before/$SRV" ".harness/after/$SRV" > .harness/file.diff || true
  echo "  $SRV - diff adds $(grep -c '^> ' .harness/file.diff || true) lines, removes $(grep -c '^< ' .harness/file.diff || true); the lines that are code, not comment:"
  grep -E '^[<>] ' .harness/file.diff | grep -vE '^[<>] +(\*|/\*\*|\*/|//)' | sed 's/^/    /'
  echo "  every catch clause in handle(), before and after (grep -n):"
  catches ".harness/before/$SRV" | sed 's/^    /    before /'; catches ".harness/after/$SRV" | sed 's/^    /    after  /'
  diff .harness/before/README.md .harness/after/README.md > .harness/file.diff || true
  echo "  README.md - the anchor's README: lines added $(grep -c '^> ' .harness/file.diff || true), removed $(grep -c '^< ' .harness/file.diff || true) - its new section (not shown)"
  echo "  tiffinbox-core against the previous tree's (diff -rq -x target): $(diff -rq -x target .harness/before/tiffinbox-core .harness/after/tiffinbox-core | wc -l | tr -d ' ') files differ"
  f=tiffinbox-web/src/main/java/com/tiffinbox/web/ActuatorRoutes.java
  diff ".harness/before/$f" ".harness/after/$f" > .harness/file.diff || true
  echo "  $f - diff adds $(grep -c '^> ' .harness/file.diff || true) lines, removes $(grep -c '^< ' .harness/file.diff || true); the lines that are code, not comment:"
  grep -E '^[<>] ' .harness/file.diff | grep -vE '^[<>] +(\*|/\*\*|\*/|//)' | sed 's/^/    /'
  for f in TiffinBoxApp KitchenHealthIndicator KitchenMetrics Route; do f=tiffinbox-web/src/main/java/com/tiffinbox/web/$f.java
    echo "  $(basename "$f") against the previous tree's, byte for byte: $(cmp -s ".harness/before/$f" ".harness/after/$f" && echo the same || echo different)"; done
  for f in tiffinbox-web/src/main/resources/application.yaml tiffinbox-web/pom.xml pom.xml; do
    echo "  $f against the previous tree's, byte for byte: $(cmp -s ".harness/before/$f" ".harness/after/$f" && echo the same || echo different)"; done; }

# ---- analysis: the break - the analyzer's one line -----------------------------------------------------------------------
analysis() { local c
  echo "the break: the analyzer's one line. A first TiffinBox holds port 19052 - after/'s jar (.harness/serve), the README's run line:"
  start "$(at .harness/serve 19052 "$R_RUN")"; up; ready 19052
  echo "each run below is a second TiffinBox, the same line, on that port."
  echo "A - after/ (.harness/serve):"
  fails "$(at .harness/serve 19052 "$R_RUN")"
  echo "B - a copy of after/ without the factories line (.harness/noline), built the README's plain way:"
  copy after .harness/noline
  c="sed -i '' '/^org\\.springframework\\.boot\\.diagnostics\\.FailureAnalyzer=/d' .harness/noline/$FAC"; echo "\$ $c"; eval "$c"
  echo "\$ diff after/$FAC .harness/noline/$FAC"; diff "after/$FAC" ".harness/noline/$FAC" | sed 's/^/  /' || true
  pbuild .harness/noline "the copy without the line"
  fails "$(at .harness/noline 19052 "$R_RUN")"
  echo "A' - A again:"
  fails "$(at .harness/serve 19052 "$R_RUN")"
  echo "C (labelled) - the same class as a bean: a copy of after/ (.harness/bean), @Component on the class, no factories file:"
  copy after .harness/bean
  c="sed -i '' 's/^class PortTakenFailureAnalyzer /@org.springframework.stereotype.Component class PortTakenFailureAnalyzer /' .harness/bean/$ANA && rm .harness/bean/$FAC"; echo "\$ $c"; eval "$c"
  echo "\$ diff -r -x target -x secrets after .harness/bean"; diff -r -x target -x secrets after .harness/bean | sed 's/^/  /' || true
  pbuild .harness/bean "the copy with the bean"
  fails "$(at .harness/bean 19052 "$R_RUN")"
  echo "where Boot gets its analyzers - spring-boot 4.1.1's FailureAnalyzers, its calls read by javap (filtered, counted):"
  echo "\$ javap -c -p -cp \"\$M2/org/springframework/boot/spring-boot/4.1.1/spring-boot-4.1.1.jar\" org.springframework.boot.diagnostics.FailureAnalyzers"
  javap -c -p -cp "$M2/org/springframework/boot/spring-boot/4.1.1/spring-boot-4.1.1.jar" org.springframework.boot.diagnostics.FailureAnalyzers > .harness/javap.txt 2>&1 || die "javap could not read FailureAnalyzers"
  sed -n 's#^.* \(invoke[a-z]*\) .*// .*Method org/springframework/core/io/support/SpringFactoriesLoader\.\([A-Za-z]*\):.*$#  \1 SpringFactoriesLoader.\2#p' .harness/javap.txt
  echo "  calls that ask the context for a bean (getBean, getBeansOfType, getBeanProvider, getBeanNamesForType): $(grep -cE '\.(getBean|getBeansOfType|getBeanProvider|getBeanNamesForType):' .harness/javap.txt || true)"
  echo "D (labelled) - an address this machine does not have (192.0.2.1, kept for documentation): the README's address line, port 19053:"
  fails "$(at .harness/serve 19053 "$R_ADDR")"
  echo "E (labelled) - another bean's bind, on the port the first TiffinBox holds: after/'s extracted class path with the harness's"
  echo "Elsewhere joined (a bean that binds 127.0.0.1 and probe.bind.port when it is created); TiffinBox itself on 19053, free:"
  fails "$(hcp .harness/serve 19053 probe.bind.Elsewhere --probe.bind.port=19052)"
  echo "the first TiffinBox, after the six:"
  same 19052
  seven 19052 .harness/serve
  echo "C's context, on a free port - the README's beans line, port 19053:"
  start "$(at .harness/bean 19053 "$R_BEANS")"; up; ready 19053
  get .harness/bean 19053 "$R_BEANSGET"
  beanof .harness/bean/beans.json portTakenFailureAnalyzer; gone .harness/bean/beans.json
  seven 19053 .harness/bean; }

# ---- debug: the trace, still there -----------------------------------------------------------------------------------------------
debug() {
  echo "the trace, back: a first TiffinBox holds port 19054 - after/'s jar (.harness/serve), the README's run line:"
  start "$(at .harness/serve 19054 "$R_RUN")"; up; ready 19054
  echo "a second, on the same port - the README's --debug line:"
  fails "$(at .harness/serve 19054 "$R_DEBUGRUN")"
  echo "the first TiffinBox, after the second exited:"
  same 19054
  seven 19054 .harness/serve; }

# ---- hang: the failure after the start ---------------------------------------------------------------------------------------
# hangrun SRC DIR 'LABEL': SRC copied to DIR with a config tree, built and extracted; its catch clauses; the README's two lines that
# make the copy without the class; the README's run line for the copy, port 19055; the README's five-second line for /customers,
# its curl exit; /dashboard; the scrape's line for /customers (a barrier: its answer's line is decided); POST /shutdown; then its
# answer lines and its standard error, read after it stopped
hangrun() { local c e=0 o
  echo "$3, copied to $2 with a config tree, built the README's plain way, extracted:"
  copy "$1" "$2"; pbuild "$2" "$3"; extract "$2"
  echo "  every catch clause in its handle() (grep -n):"; catches "$2/$SRV"
  for c in "$R_H1" "$R_H2"; do echo "\$ cd $2 && $c"; (cd "$2" && eval "$c") > "$2.hang.log" 2>&1 < /dev/null || { cat "$2.hang.log" >&3; die "the README's hang line failed in $2: $c"; }; done
  echo "  entries under jdk14/JDK14Util in jackson-databind: the copy's $(unzip -l "$2/tiffinbox-web/target/hang/lib/jackson-databind-2.22.2.jar" | grep -c 'databind/jdk14/JDK14Util' || true) · the extracted lib's $(unzip -l "$2/$EXL/jackson-databind-2.22.2.jar" | grep -c 'databind/jdk14/JDK14Util' || true)"
  start "$(at "$2" 19055 "$R_H3")"; up; ready 19055
  c=$(url "$R_H4" 19055); echo "\$ $c"; o=$( (eval "$c") 2>&1 < /dev/null) || e=$?; printf '%s\n' "$o" | sed 's/^/  /'; echo "  curl exit $e"
  status /dashboard 19055
  scraped 19055 'GET /customers'; answered 19055 'GET /dashboard' 200 1
  echo "\$ harness/shutdown.sh 19055 $2/$TF"; harness/shutdown.sh 19055 "$2/$TF" | sed 's/^/  /'
  ends 19055
  answers .harness/run.out
  errs .harness/run.err; }
hang() { local c e=0 o
  echo "C (labelled) - the failure after the start: one class jackson-databind needs for a record, deleted from a copy of the"
  echo "extracted lib by the README's lines - in the previous tree, then in after/; port 19055."
  hangrun "$PREV" .harness/hb "the previous tree"
  hangrun after .harness/ha "after/"
  echo "after/'s copy again (.harness/ha), at INFO, Boot's default - the README's run line for the copy, no kitchen flag; it"
  echo "exposes sbom for this one run (Actuator's endpoint for a software bill of materials: it needs the same class):"
  start "$(at .harness/ha 19055 "$R_H5")"; up; ready 19055
  c=$(url "$R_H4" 19055); echo "\$ $c"; o=$( (eval "$c") 2>&1 < /dev/null) || e=$?; printf '%s\n' "$o" | sed 's/^/  /'; echo "  curl exit $e"
  scraped 19055 'GET /customers'
  echo "the bridge's catch - the README's sbom line; then its line that sends a body to health, a read: the bridge reads a body only"
  echo "for a write that takes one (the Actuator lesson's fix), so this one never reaches the catch:"
  ask "$R_H7" 19055
  ask "$R_H6" 19055
  echo "\$ harness/shutdown.sh 19055 .harness/ha/$TF"; harness/shutdown.sh 19055 ".harness/ha/$TF" | sed 's/^/  /'
  ends 19055
  awk "$SHAPEAWK" .harness/run.out
  echo "  the body's words in its log: oops $(cat .harness/run.out .harness/run.err | grep -c oops || true) · not json $(cat .harness/run.out .harness/run.err | grep -c 'not json' || true)"
  errs .harness/run.err; }

# ---- native: after/, built natively; the AOT jar and the binary on a taken port; C, the hints lesson's break -------------------
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
# twice DIR 'README LINE': the line started once on 19056 (the first, held), then again (fails), then the first's seven
twice() {
  start "$(at "$1" 19056 "$2")"; up; ready 19056
  fails "$(at "$1" 19056 "$2")"
  seven 19056 "$1"; }
native() { local c e=0 o
  echo "after/, copied to .harness/nat with a config tree; the README's two Maven lines, offline; \$GRAALVM_HOME names the GraalVM:"
  copy after .harness/nat
  nbuild .harness/nat
  nlines .harness/nat.native.log
  nresult .harness/nat.native.log
  echo "  file: $(file -b ".harness/nat/$BIN" | sed 's/ [A-Za-z0-9_]*$//') · the demo token in its bytes: $(raw "$TOKEN" ".harness/nat/$BIN")"
  echo "what Spring's AOT step wrote for the binary - .harness/nat's reachability-metadata.json (process-aot), through a filter:"
  aotmeta ".harness/nat/$AOTMETA"
  echo "the AOT jar, started twice on one port - the README's AOT line, port 19056:"
  twice .harness/nat "$R_AOTRUN"
  echo "the binary, started twice on one port - the README's line:"
  twice .harness/nat "$R_BIN"
  echo "C (labelled) - the hints lesson's break: a copy of after/ (.harness/natc) without the route annotation's @Reflective, built"
  echo "natively; the README's line with the kitchen flag, port 19057:"
  copy after .harness/natc
  c="sed -i '' '/^@Reflective\$/d' .harness/natc/$ROUTE"; echo "\$ $c"; eval "$c"
  echo "\$ diff after/$ROUTE .harness/natc/$ROUTE"; diff "after/$ROUTE" ".harness/natc/$ROUTE" | sed 's/^/  /' || true
  nbuild .harness/natc
  nresult .harness/natc.native.log
  echo "  the demo token in its bytes: $(raw "$TOKEN" ".harness/natc/$BIN")"
  start "$(at .harness/natc 19057 "$R_BINK")"; up; ready 19057
  c=$(url "$R_K5" 19057); echo "\$ $c"; o=$( (eval "$c") 2>&1 < /dev/null) || e=$?; printf '%s\n' "$o" | sed 's/^/  /'; echo "  curl exit $e"
  scraped 19057 'GET /kitchen'
  echo "\$ harness/shutdown.sh 19057 .harness/natc/$TF"; harness/shutdown.sh 19057 ".harness/natc/$TF" | sed 's/^/  /'
  echo "  still running: $(kill -0 "$pid" 2> /dev/null && echo yes || echo no)"
  echo "\$ kill \$pid    # SIGTERM, to the binary this script started"
  e=0; kill "$pid"; wait "$pid" || e=$?; pid=""
  echo "  exit $e · listening on 19057 now: $(listeners 19057)"
  logtok
  answers .harness/run.out
  awk "$SHAPEAWK" .harness/run.out | grep -v '^  DEBUG ' || true     # its errors; the DEBUG lines are counted above (the route lines' order is not fixed)
  errs .harness/run.err; }

# ---- exercise: the README's commands, exactly as written, then the solution's ---------------------------------------------
# block FILE: the lines of FILE's first ```bash block
block() { awk '/^```bash$/ { if (!d) { f = 1 }; next } f && /^```$/ { f = 0; d = 1 } f' "$1"; }
exercise() { local setup sol ec=0 tok
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
  echo "  exit $ec · listening on 19059 now: $(listeners 19059)"
  tok=$(head -1 .harness/mine/after/$TF)
  echo "  its log (.harness/mine/run.log): its own token $(raw "$tok" .harness/mine/run.log) times · X-Shutdown-Token $(LC_ALL=C grep -aoi -- 'x-shutdown-token' .harness/mine/run.log | wc -l | tr -d ' ') times"; }

cap taken taken
cap analyzers analyzers
cap cycle cycle
cap change change
cap analysis analysis
cap debug debug
cap hang hang
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
SEVEN="  exit 0 · the seven responses: 7 lines · md5 $S115"
LOGOK="  its log: the demo token 0 times · X-Shutdown-Token 0 times"
ERR0="  its standard error: 0 lines · the demo token in its log: 0"
TRACE40="  its log, read after it exited: APPLICATION FAILED TO START 0 · stack frames 40 = 25 + 15 · Caused by: 1 · frames folded as common 24"
NOTRACE="  its log, read after it exited: APPLICATION FAILED TO START 1 · stack frames 0 · Caused by: 0 · frames folded as common 0"
BINDL="  Caused by: java.net.BindException: Address already in use"
ACT="  Stop the program on that port, or start TiffinBox on another: --tiffinbox.port=<a free port>."
ANS='<time> DEBUG <pid> --- [    virtual-<n>] tiffinbox                                : '
# has 'TEXT' 'LINE' MESSAGE: TEXT (a variable holding a capture's block) holds the line, whole
has() { printf '%s\n' "$1" | grep -qxF -- "$2" || die "$3: expected the line: $2"; }
# cnt 'TEXT' 'LINE': how many times TEXT holds the line, whole
cnt() { printf '%s\n' "$1" | grep -cxF -- "$2" || true; }
# THE TOKEN: no capture holds the demo token, raw - counted on each run's own output BEFORE masking - and neither does any answer
# saved on the way (gone() died on one), any failed start's log (fails() died on one), any served run's log (seven() and ends()
# counted each, with the header's name), anything this unit ships for reading, nor either binary this run built
for f in .harness/raw-*; do [ "$(cat "$f")" = 0 ] || die "a capture's raw output held the demo token ($f)"; done
NBIN=0
for f in .r-*.out README.md exercise/README.md exercise/solution/SOLUTION.md exercise/solution/probe/cycle/*.java receipts.md5 harness/shutdown.sh harness/seven.sh harness/jars/pom.xml harness/probe/cycle/*.java harness/probe/bind/*.java after/README.md "after/$ANA" "after/$FAC" "after/$SRV" .harness/nat/$BIN .harness/natc/$BIN; do
  [ -f "$f" ] || continue; case $f in .harness/nat*) NBIN=$((NBIN + 1)) ;; esac
  [ "$(raw "$TOKEN" "$f")" = 0 ] || die "$f holds the demo token, raw"; done
[ "$NBIN" = 2 ] || die "two binaries were built, $NBIN were checked"
for f in .r-*.out; do ! grep -qE '/Users/|/private/|/home/|/var/folders/' "$f" || die "$f holds an absolute path"; ! grep -qF "$GRAALVM_HOME" "$f" || die "$f holds the GraalVM's folder"; ! grep -qE 'c[0-9]-unit[0-9]|unit ?[0-9]' "$f" || die "$f holds a unit number"; ! grep -qE ' (with PID|started by) ' "$f" || die "$f holds Boot's process line"; ! grep -qE '^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T|virtual-[0-9]' "$f" || die "$f holds a log line's time or a thread's number"; ! grep -q "^$(printf '\t')at " "$f" || die "$f shows a stack frame"; done
[ -z "$(find .harness -name beans.json | head -1)" ] || die "an answer saved on the way was left under .harness/"
NX=$(n exercise '^  its log \(\.harness/mine/run\.log\): its own token 0 times · X-Shutdown-Token 0 times$'); [ "$NX" = 1 ] || die "exercise: its log, its own token and the header"
NF=$(cat .r-*.out | grep -cxF "$ERR0" || true); NL=$(cat .r-*.out | grep -cxF "$LOGOK" || true)
echo "  token: 0 raw copies in $(ls .harness/raw-* | wc -l | tr -d ' ') raw capture runs, in $(ls .r-*.out | wc -l | tr -d ' ') captures, in the $SEEN answers saved on the way (each counted, then deleted), in the reports of every failed start ($FLOGS counted here, the published captures' $NF each with 0), in the logs of every run that served ($LOGS counted here, the published captures' $NL each with 0 tokens and 0 header names), the READMEs, the harness, the exercise's solution, receipts.md5 and both binaries; no absolute path, no GraalVM folder, no unit number, no process line, no log time, no thread number, no stack frame in any capture"
# S4.16: no star in an exposure list anywhere in this unit - its scripts, its READMEs, its captures
for f in receipts.sh README.md exercise/README.md exercise/solution/SOLUTION.md .r-*.out; do
  [ -f "$f" ] || continue
  ! grep -nE "exposure\.include='?\*" "$f" | grep -vF 'grep -nE "exposure' | grep -q . || die "$f: a star in an exposure list"; done

# "TiffinBox is already running, and you start it again on the same port. The second one dies ... a stack trace ... Each line of it
# is a frame. Forty frames here, and one line that matters: BindException, address already in use. From Boot, no explanation, only
# a hint to rerun with debug. And the first one never noticed: the same seven answers."
T1=$(blk taken 'and again' 'the first one, after'); T2=$(blk taken 'the first one, after' '')
x taken '^\$ cd \.harness/prev && java -jar tiffinbox-web/target/tiffinbox-web-1\.0\.0\.jar --tiffinbox\.port=19050$'
[ "$(n taken '^\$ cd \.harness/prev && java -jar tiffinbox-web/target/tiffinbox-web-1\.0\.0\.jar --tiffinbox\.port=19050$')" = 2 ] || die "taken: the same line twice"
has "$T1" "  exit 1" "taken: exit 1"; has "$T1" "$TRACE40" "taken: forty frames, no banner"; has "$T1" "$BINDL" "taken: the BindException"
has "$T1" "  ERROR o.s.boot.SpringApplication: Application run failed" "taken: Boot's trace"
has "$T1" "  the hint Boot logs: Error starting ApplicationContext. To display the condition evaluation report re-run your application with 'debug' enabled." "taken: the hint"
[ "$(printf '%s\n' "$T1" | grep -c '^  Description:')" = 0 ] || die "taken: no analysis"
has "$T2" "  the process listening on 19050: the one started above: yes" "taken: the first one"; has "$T2" "$SEVEN" "taken: the seven"
echo "  taken: the second exits 1 - 40 frames (25 + 15), 1 Caused by: java.net.BindException, 0 banners, Boot's hint; the first: the same process, 115c36ba..."

# "TiffinBox's jars carry twenty-one of Boot's, each one a name in a file called spring factories ... You've met three of them ...
# Type a word where the port goes, and Boot explains that too, quoting the value ... Boot's port analyzer lives in its web-server
# module ... TiffinBox doesn't ship it"
A1=$(blk analyzers "Boot's failure analyzers" "Boot's port analyzer"); A2=$(blk analyzers "Boot's port analyzer" 'a malformed value'); A3=$(blk analyzers 'a malformed value' '')
x analyzers '^  extracted: exit 0 · its lib/ holds 46 jars$'
has "$A1" "  spring-boot-4.1.1.jar: 18" "analyzers: spring-boot 18"; has "$A1" "  spring-boot-autoconfigure-4.1.1.jar: 2" "analyzers: autoconfigure 2"
has "$A1" "  spring-boot-micrometer-metrics-4.1.1.jar: 1" "analyzers: the metrics module 1"; has "$A1" "  tiffinbox-web-1.0.0.jar: 1" "analyzers: TiffinBox's 1"
[ "$(printf '%s\n' "$A1" | grep -cE '^  [^ ].*\.jar: [0-9]+$')" = 4 ] && has "$A1" "  jars read: 47 · with the key: 4 · analyzers named: 22" "analyzers: 22 = Boot's 21 + 1" || die "analyzers: four jars, 22 names"
[ "$(printf '%s\n' "$A1" | grep -cE '^    [A-Za-z]+FailureAnalyzer$')" = 22 ] || die "analyzers: 22 names listed"
for a in NoSuchBeanDefinitionFailureAnalyzer BindValidationFailureAnalyzer ConfigDataNotFoundFailureAnalyzer BeanCurrentlyInCreationFailureAnalyzer BindFailureAnalyzer PortTakenFailureAnalyzer; do has "$A1" "    $a" "analyzers: $a"; done
[ "$(printf '%s\n' "$A1" | grep -c 'PortInUse')" = 0 ] || die "analyzers: no port analyzer of Boot's on TiffinBox's class path"
has "$A2" "  spring-boot-web-server-4.1.1.jar: 2" "analyzers: the web-server module"; has "$A2" "    PortInUseFailureAnalyzer" "analyzers: Boot's port analyzer"
has "$A2" "  spring-boot-tomcat-4.1.1.jar: 1" "analyzers: Tomcat's"; has "$A2" "  in TiffinBox's lib/: spring-boot-web-server 0 jars · spring-boot-tomcat 0 jars" "analyzers: not shipped"
has "$A3" "  exit 1" "analyzers: exit 1"; has "$A3" "$NOTRACE" "analyzers: analysed, 0 frames"
has "$A3" "  Failed to bind properties under 'tiffinbox.port' to java.lang.Integer:" "analyzers: the bind analysis"; has "$A3" '      Value: "nineteen"' "analyzers: the value, quoted"
has "$A3" "  Update your application's configuration" "analyzers: its action"
echo "  analyzers: spring-boot 18 + autoconfigure 2 + metrics 1 = Boot's 21, TiffinBox's 1 · PortInUseFailureAnalyzer in spring-boot-web-server, 0 such jars shipped · nineteen: analysed, the value quoted"

# "Plain Spring still starts them. Boot refuses: exit one, an analysis that draws the cycle, and an action naming the switch, allow
# circular references. Its default, in Boot's own metadata: false. Set it to true, and the seven answers come back."
C1=$(blk cycle "Boot - the README" "Boot's own metadata"); C3=$(blk cycle "the README's switch" '')
x cycle '^  harness: plain Spring, Cook and Rail - the context started: true · allowCircularReferences: true · the cook.s rail is the rail bean: true · the rail.s cook is the cook bean: true$'
has "$C1" "  exit 1" "cycle: exit 1"; has "$C1" "$NOTRACE" "cycle: analysed"
has "$C1" "  The dependencies of some of the beans in the application context form a cycle:" "cycle: the description"
[ "$(printf '%s\n' "$C1" | sed -n '/^  The dependencies of some/,/^  Action:$/p' | sed '1d;$d' | paste -sd'|' -)" = "  ┌─────┐|  |  cook|  ↑     ↓|  |  rail|  └─────┘" ] || die "cycle: the cycle drawn, cook and rail"
printf '%s\n' "$C1" | grep -q '^  Relying upon circular references is discouraged and they are prohibited by default\. .* by setting spring\.main\.allow-circular-references to true\.$' || die "cycle: the action names the switch"
has "$C1" "  listening on 19051 now: 0 · TiffinBox's listening line in its log: 0" "cycle: never listened"
x cycle '^  spring\.main\.allow-circular-references: java\.lang\.Boolean · default false · declared by org\.springframework\.boot\.SpringApplication$'
printf '%s\n' "$C3" | grep -q -- '--spring\.main\.allow-circular-references=true$' || die "cycle: the switch line"
has "$C3" "$SEVEN" "cycle: the seven"; has "$C3" "  its log: APPLICATION FAILED TO START 0 · WARN lines 0" "cycle: no banner"
echo "  cycle: plain Spring - started, allowCircularReferences true · Boot - exit 1, cook <-> rail drawn, the switch named; default false (metadata); the switch - the seven"

# "The analyzer waits for a BindException, takes Boot's environment through its constructor, and builds two sentences from the
# address and the port - only when the port is in use and the bind is TiffinBox's own; otherwise it steps aside. Nothing else ...
# One line in spring factories names it. And one catch clause in handle"
[ "$(n change '^  (Files|Only in) ')" = 5 ] || die "change: five paths"
x change '^  Only in \.harness/after/tiffinbox-web/src/main/java/com/tiffinbox/web: PortTakenFailureAnalyzer\.java$'
x change '^  Only in \.harness/after/tiffinbox-web/src/main/resources: META-INF$'
x change '^  Files \.harness/before/tiffinbox-web/src/main/java/com/tiffinbox/web/ActuatorRoutes\.java and '
x change '^  tiffinbox-web/src/main/java/com/tiffinbox/web/PortTakenFailureAnalyzer\.java - new; its lines that are neither comment nor blank: 28$'
for t in '    class PortTakenFailureAnalyzer extends AbstractFailureAnalyzer<BindException> {' '        PortTakenFailureAnalyzer(Environment environment) {' \
  '            if (!"Address already in use".equals(cause.getMessage()) || !thrownIn(TiffinBoxServer.class, "start", cause)) {' \
  '                return null;                             // not TiffinBox'"'"'s port taken: Boot keeps the trace' \
  '                if (frame.getClassName().equals(type.getName()) && frame.getMethodName().equals(method)) {' \
  '            String where = environment.getProperty("tiffinbox.address") + ":" + environment.getProperty("tiffinbox.port");' \
  '            return new FailureAnalysis("TiffinBox could not listen on " + where + ": something else already listens there.",'; do grep -qxF -- "$t" .r-change.out || die "change: $t"; done
[ "$(grep -o 'getProperty(' .r-change.out | wc -l | tr -d ' ')" = 2 ] || die "change: two properties read, no more"
x change '^  tiffinbox-web/src/main/resources/META-INF/spring\.factories - new; its lines that are neither comment nor blank: 1$'
x change '^    org\.springframework\.boot\.diagnostics\.FailureAnalyzer=com\.tiffinbox\.web\.PortTakenFailureAnalyzer$'
x change '^    before [0-9]+: \} catch \(Exception e\) \{$'; x change '^    after  [0-9]+: \} catch \(Exception \| LinkageError e\) \{ '
[ "$(n change '^    (before|after ) [0-9]+: ')" = 2 ] || die "change: one catch clause in handle(), before and after"
x change '^    >                 LOG\.log\(System\.Logger\.Level\.ERROR, key \+ " failed", e\);'
CA=$(blk change '  tiffinbox-web/src/main/java/com/tiffinbox/web/ActuatorRoutes.java - diff adds' '  TiffinBoxApp.java')
x change '^  tiffinbox-web/src/main/java/com/tiffinbox/web/ActuatorRoutes\.java - diff adds 6 lines, removes 0; the lines that are code, not comment:$'
[ "$(printf '%s\n' "$CA" | grep -c 'log\.log(System\.Logger\.Level\.ERROR, "an actuator request failed')" = 2 ] || die "change: the bridge's catch logs, two ways"
printf '%s\n' "$CA" | grep -qF 'log.log(System.Logger.Level.ERROR, "an actuator request failed: {0}", e.getClass().getName());' || die "change: the bridge logs an exception by its class alone"
x change '^  tiffinbox-core against the previous tree.s \(diff -rq -x target\): 0 files differ$'
for t in TiffinBoxApp.java KitchenHealthIndicator.java KitchenMetrics.java Route.java tiffinbox-web/src/main/resources/application.yaml tiffinbox-web/pom.xml pom.xml; do x change "^  $t against the previous tree.s, byte for byte: the same\$"; done
[ "$(diff -rq -x target -x secrets "$PREV" after | wc -l | tr -d ' ')" = 5 ] || die "change: after/ differs from the previous tree in more than the README, the server, the bridge, the analyzer and META-INF"
echo "  change: 5 paths · the analyzer, 28 code lines, two properties read, null unless in use and TiffinBoxServer.start's own bind · one factories line · one catch clause, Exception -> Exception | LinkageError, its ERROR line · the bridge's catch: ERROR, the trace for a LinkageError, the class alone otherwise · the rest the same"

# "A: the port taken, exit one, zero frames, two sentences. B: delete that one line, and the forty frames are back. A again: zero.
# And C: the same class as a component, no line. Forty frames, though its context held the bean."
NA=$(blk analysis 'A - after/' 'B - a copy'); NB=$(blk analysis 'B - a copy' "A' - A again"); NA2=$(blk analysis "A' - A again" 'C (labelled)'); NC=$(blk analysis 'C (labelled)' 'where Boot gets its analyzers'); NJ=$(blk analysis 'where Boot gets its analyzers' 'D (labelled)'); ND=$(blk analysis 'D (labelled)' 'E (labelled)'); NE=$(blk analysis 'E (labelled)' 'the first TiffinBox, after'); N6=$(blk analysis "C's context" '')
for b in "$NA" "$NA2"; do has "$b" "  exit 1" "analysis A: exit 1"; has "$b" "$NOTRACE" "analysis A: 0 frames"; has "$b" "  TiffinBox could not listen on 127.0.0.1:19052: something else already listens there." "analysis A: the sentence"; has "$b" "$ACT" "analysis A: the action"; has "$b" "  ERROR o.s.b.d.LoggingFailureAnalysisReporter:" "analysis A: Boot's reporter"; has "$b" "$ERR0" "analysis A: no token"; done
[ "$(printf '%s\n' "$NA" | sed -n '/^  Description:$/,$p' | grep -cvE '^  (Description|Action):$|^  its standard error: ')" = 2 ] || die "analysis A: two sentences"
[ "$(printf '%s\n' "$NA" | grep '^\$ ')" = "$(printf '%s\n' "$NA2" | grep '^\$ ')" ] || die "analysis: A' is not A's command"
has "$NB" "  < org.springframework.boot.diagnostics.FailureAnalyzer=com.tiffinbox.web.PortTakenFailureAnalyzer" "analysis B: the line deleted"
for b in "$NB" "$NC"; do has "$b" "  exit 1" "analysis B/C: exit 1"; has "$b" "$TRACE40" "analysis B/C: forty frames, no banner"; has "$b" "$BINDL" "analysis B/C: the BindException"; done
has "$NC" "  > @org.springframework.stereotype.Component class PortTakenFailureAnalyzer extends AbstractFailureAnalyzer<BindException> {" "analysis C: the bean"
has "$NC" "  Only in after/tiffinbox-web/src/main/resources/META-INF: spring.factories" "analysis C: no factories file"
x analysis '^  the process listening on 19052: the one started above: yes$'
has "$N6" "  beans named portTakenFailureAnalyzer in its context: 1" "analysis C: the context held the bean"; has "$N6" "    type com.tiffinbox.web.PortTakenFailureAnalyzer · scope singleton" "analysis C: its type"
has "$N6" "  the demo token in it: 0 · deleted: yes" "analysis C: the answer counted, deleted"
# "Boot loads analyzers through spring factories' loader, and never asks the context for one."
[ "$(printf '%s\n' "$NJ" | grep -E '^  invoke' | sort -u | paste -sd'|' -)" = '  invokestatic SpringFactoriesLoader.forDefaultResourceLocation|  invokevirtual SpringFactoriesLoader.load' ] || die "analysis: FailureAnalyzers loads through SpringFactoriesLoader, and only that"
has "$NJ" "  calls that ask the context for a bean (getBean, getBeansOfType, getBeanProvider, getBeanNamesForType): 0" "analysis: no bean asked for"
# "only when the port is in use and the bind is TiffinBox's own; anything else, it steps aside, and Boot prints the trace"
for b in "$ND" "$NE"; do has "$b" "  exit 1" "analysis D/E: exit 1"; [ "$(printf '%s\n' "$b" | grep -c 'already listens')" = 0 ] || die "analysis D/E: no claim that something listens"
  printf '%s\n' "$b" | grep -qE '^  its log, read after it exited: APPLICATION FAILED TO START 0 · stack frames [1-9][0-9]* ' || die "analysis D/E: the trace, no banner"; has "$b" "$ERR0" "analysis D/E: no token"; done
has "$ND" "  Caused by: java.net.BindException: Can't assign requested address" "analysis D: not a taken port"
has "$ND" "  org.springframework.beans.factory.BeanCreationException: Error creating bean with name 'tiffinBoxServer': Invocation of init method failed" "analysis D: TiffinBox's own bind"
has "$NE" "$BINDL" "analysis E: in use"; has "$NE" "  org.springframework.beans.factory.BeanCreationException: Error creating bean with name 'elsewhere': Invocation of init method failed" "analysis E: another bean's bind"
[ "$(n analysis "^$SEVEN\$")" = 2 ] || die "analysis: the seven, twice"
echo "  analysis: A 0 frames, the sentence · B 40 · A' 0 · C 40 - Boot loads analyzers through SpringFactoriesLoader, asks the context for none · D (192.0.2.1) and E (another bean's bind): the trace, no claim"

# "Add debug, and the trace comes back, thirty-nine frames, beside the analysis and Boot's condition report."
D1=$(blk debug 'a second, on the same port' 'the first TiffinBox, after')
has "$D1" "  exit 1" "debug: exit 1"; has "$D1" "  its log, read after it exited: APPLICATION FAILED TO START 1 · stack frames 39 = 39 · Caused by: 0 · frames folded as common 0" "debug: 39 frames, the banner"
has "$D1" "  DEBUG o.s.b.d.LoggingFailureAnalysisReporter: Application failed to start due to an exception" "debug: the reporter logs the trace"
has "$D1" "  java.net.BindException: Address already in use" "debug: the BindException's own"
printf '%s\n' "$D1" | grep -qE '^  the condition report: CONDITIONS EVALUATION REPORT 1 · positive matches [0-9]+ · negative matches [0-9]+ · unconditional classes [0-9]+$' || die "debug: the condition report"
has "$D1" "  TiffinBox could not listen on 127.0.0.1:19054: something else already listens there." "debug: the same sentence"
x debug "^$SEVEN\$"
echo "  debug: 39 frames (the BindException's own: 15 + the 24 folded), the condition report, the same sentence"

# "slash customers never answers, and curl gives up after five seconds. Yet the log says minus one, and the timer counted it ...
# It's an error, not an exception, so it walked straight past catch exception. The new catch takes both: five hundred, logged and timed."
HB=$(blk hang 'the previous tree, copied' 'after/, copied'); HA=$(blk hang 'after/, copied' "after/'s copy again"); HI=$(blk hang "after/'s copy again" '')
[ "$R_H4" = "curl -s -m 5 -w ' %{http_code}\n' http://127.0.0.1:18431/customers" ] || die "hang: the five-second line"
printf '%s\n' "$HB" | grep -qE '^    [0-9]+: \} catch \(Exception e\) \{$' || die "hang: the previous tree catches Exception"
printf '%s\n' "$HA" | grep -qE '^    [0-9]+: \} catch \(Exception \| LinkageError e\) \{ ' || die "hang: after/ catches Exception | LinkageError"
for b in "$HB" "$HA"; do has "$b" "  entries under jdk14/JDK14Util in jackson-databind: the copy's 0 · the extracted lib's 4" "hang: the class deleted from the copy"; has "$b" "  ${ANS}GET /dashboard -> 200" "hang: the server lives"; has "$b" "  POST /shutdown -> 200 · curl exit 0" "hang: it stops"; has "$b" "$LOGOK" "hang: no token"; done
has "$HB" "   000" "hang: no answer"; has "$HB" "  curl exit 28" "hang: curl gave up"
has "$HB" '  the scrape'"'"'s line for GET /customers: tiffinbox_requests_seconds_count{route="GET /customers",status="-1"} 1' "hang: the timer counted -1"
has "$HB" "  ${ANS}GET /customers -> -1" "hang: the log says -1"
has "$HB" '    Exception in thread "" java.lang.NoClassDefFoundError: com/fasterxml/jackson/databind/jdk14/JDK14Util' "hang: the error, uncaught"
printf '%s\n' "$HB" | grep -qE '^  its standard error: uncaught exceptions 1 · stack frames [0-9]+ · Caused by: 1$' || die "hang: one uncaught exception"
has "$HA" '  {"error":"ClassNotFoundException"} 500' "hang: five hundred"; has "$HA" "  curl exit 0" "hang: answered"
has "$HA" '  the scrape'"'"'s line for GET /customers: tiffinbox_requests_seconds_count{route="GET /customers",status="500"} 1' "hang: timed"
has "$HA" "  ${ANS}GET /customers -> 500" "hang: logged"; has "$HA" "  its standard error: uncaught exceptions 0 · stack frames 0 · Caused by: 0" "hang: nothing uncaught"
# "The new catch takes both: five hundred, the error logged, and timed." - at INFO, Boot's default
has "$HI" '  {"error":"ClassNotFoundException"} 500' "hang INFO: five hundred"; has "$HI" '  {"error":"NoClassDefFoundError"} 500' "hang INFO: sbom, five hundred"; has "$HI" '  {"status":"UP","groups":["liveness","readiness"]} 200' "hang INFO: a body on a read, never read"
has "$HI" '  the scrape'"'"'s line for GET /customers: tiffinbox_requests_seconds_count{route="GET /customers",status="500"} 1' "hang INFO: timed"
has "$HI" "  ERROR tiffinbox: GET /customers failed" "hang INFO: the route's error, logged"
has "$HI" "  ERROR tiffinbox: an actuator request failed" "hang INFO: the bridge's LinkageError, logged"
[ "$(printf '%s\n' "$HI" | grep -c 'an actuator request failed: ')" = 0 ] || die "hang INFO: the body on a read reached the bridge's catch"
[ "$(printf '%s\n' "$HI" | grep -cxF '  java.lang.NoClassDefFoundError: com/fasterxml/jackson/databind/jdk14/JDK14Util')" -ge 1 ] || die "hang INFO: the error's own line"
printf '%s\n' "$HI" | grep -qE '^  its log, read after it exited: APPLICATION FAILED TO START 0 · stack frames [1-9][0-9]* ' || die "hang INFO: the traces, counted"
has "$HI" "  the body's words in its log: oops 0 · not json 0" "hang INFO: never what the client sent"
has "$HI" "  its standard error: uncaught exceptions 0 · stack frames 0 · Caused by: 0" "hang INFO: nothing uncaught"; has "$HI" "$LOGOK" "hang INFO: no token"
echo "  hang: catch (Exception e) - 000, curl exit 28, the line and the timer say -1, NoClassDefFoundError uncaught · catch (Exception | LinkageError e) - 500, logged and timed, 0 uncaught · at INFO: the route's error and the bridge's LinkageError at ERROR; a body on a read never read (200), the body's words 0"

# "Built natively, the AOT jar and the binary, each started twice on one port, print the same two sentences: the AOT step registered
# the file and the analyzer's constructors." "And in the native binary, the hints lesson's break, rebuilt: five hundred, missing
# reflection registration error"
NRES='^  exit 0 · BUILD SUCCESS · stages it printed: 8 of the 8 it announces · its duration, against the bound: 1 minute or more, under 20 minutes · offline: yes$'
[ "$(n native "$NRES")" = 2 ] || die "native: two native builds, 8 of 8 each, inside the bound, offline"
x native '^  file: Mach-O 64-bit executable · the demo token in its bytes: 0$'; x native '^  the demo token in its bytes: 0$'
x native '^  the resource META-INF/spring\.factories: yes$'; x native '^  reflection entries for com\.tiffinbox\.web\.PortTakenFailureAnalyzer: 1 · allDeclaredConstructors$'
for lb in "the AOT jar, started twice" "the binary, started twice"; do
  b=$(awk -v a="$lb" 'index($0, a) == 1 { f = 1; print; next } f && /^(the AOT jar|the binary|C \(labelled\))/ { f = 0 } f' .r-native.out)
  printf '%s\n' "$b" | grep -q "^  Boot's first line: Starting AOT-processed TiffinBoxServer" || die "native: AOT-processed ($lb)"
  has "$b" "  exit 1" "native: exit 1 ($lb)"; has "$b" "$NOTRACE" "native: 0 frames ($lb)"; has "$b" "  TiffinBox could not listen on 127.0.0.1:19056: something else already listens there." "native: the sentence ($lb)"; has "$b" "$ACT" "native: the action ($lb)"; has "$b" "$SEVEN" "native: the first one's seven ($lb)"; done
NC5=$(blk native 'C (labelled)' '')
has "$NC5" "  < @Reflective" "native C: the hint deleted"
has "$NC5" '  {"error":"MissingReflectionRegistrationError"} 500' "native C: five hundred"; has "$NC5" "  curl exit 0" "native C: answered"
has "$NC5" '  the scrape'"'"'s line for GET /kitchen: tiffinbox_requests_seconds_count{route="GET /kitchen",status="500"} 1' "native C: timed"
has "$NC5" "  POST /shutdown -> 500 · curl exit 0" "native C: shutdown is a route too"; has "$NC5" "  still running: yes" "native C: still running"
has "$NC5" "  exit 143 · listening on 19057 now: 0" "native C: SIGTERM"; has "$NC5" "  ${ANS}GET /kitchen -> 500" "native C: logged"
has "$NC5" "  its standard error: uncaught exceptions 0 · stack frames 0 · Caused by: 0" "native C: nothing uncaught"
has "$NC5" "  ERROR tiffinbox: GET /kitchen failed" "native C: the error logged"; has "$NC5" "  ERROR tiffinbox: POST /shutdown failed" "native C: the shutdown route's error logged"
[ "$(printf '%s\n' "$NC5" | grep -c '^  org\.graalvm\.nativeimage\.MissingReflectionRegistrationError: ')" -ge 1 ] || die "native C: the error's own line"
echo "  native: 2 builds, 8 of 8, offline · the AOT step registered spring.factories and the analyzer · the AOT jar and the binary: the sentence, 0 frames · C: /kitchen 500 MissingReflectionRegistrationError, POST 500, SIGTERM 143"

# the exercise's end state: the line exercise/README.md calls "Done" is a line of this capture, after the solution's line - and of
# SOLUTION.md's measured run
XE=$(blk exercise "the solution's line" '')
l="Cook and Rail started · cook depends on [shift] and counts 12 slips · rail depends on [shift] and counts 3 hands · the seven $S115 · APPLICATION FAILED TO START 0"
has "$XE" "$l" "exercise"
awk '/^\*\*Done\*\*/ { f = 1 } f' exercise/README.md | grep -qxF -- "$l" || die "exercise/README.md: Done names no such line"
grep -qxF -- "$l" exercise/solution/SOLUTION.md || die "SOLUTION.md: the measured run shows no such line"
x exercise '^  exit 0 · printed: 0 line\(s\)$'; x exercise '^  exit 0 · listening on 19059 now: 0$'
echo "  exercise: the README as written, then the solution's line -> Cook and Rail started, each depending on the shift alone (12 slips, 3 hands), 115c36ba..., 0 banners"

# the anchor's README states the same numbers
for t in 'it printed 40 stack frames and no analysis' '21 in the jars TiffinBox ships (`spring-boot` 18, `spring-boot-autoconfigure` 2,' '`spring-boot-micrometer-metrics` 1)' '`PortInUseFailureAnalyzer`, lives in' 'defaults to `false`' '`{"error":"ClassNotFoundException"} 500`' '`GET /customers -> -1`' '`{"error":"MissingReflectionRegistrationError"} 500`' '**`catch (Exception | LinkageError e)`**' 'The analysis for the taken port comes from the AOT jar' '`Can'"'"'t assign requested address`' '`GET /customers failed`'; do
  grep -qF -- "$t" after/README.md || die "after/README.md no longer states: $t"; done
cmp -s after/README.md ../c5-tiffinbox/README.md || echo "  (after/README.md and ../c5-tiffinbox/README.md differ - the anchor has moved past this unit's after/: it is unit 27's after/ now)" >&3
[ -z "$unpub" ] || die "no published hash for:$unpub - check the captures, then copy the md5s above into receipts.md5 and run again"
echo "c5-unit26: every capture 3/3 and = published; every spoken number asserted; 0 raw demo tokens in every capture, every saved answer, every failed start's report and every run's log"
