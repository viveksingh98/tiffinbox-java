#!/bin/bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25.0.4.1 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# GRAALVM_HOME names a GraalVM JDK 25 (README.md, "The GraalVM"): the native build reads it. Without it, this script makes every
# capture that needs no GraalVM - the JVM's, and the exercise's - filling .m2-demo on the way, then stops before the native build.
# Course 5 · CLI, Banners and Application Arguments - this unit's receipts. The port typed the way Courses 2 to 4 typed it - a bare
# number after the jar - started TiffinBox somewhere else without a word: Boot makes a property only of --name=value, and hands
# every other argument to the runners, where nothing in TiffinBox reads it. The anchor change (brief ⚑2, ⚑3, ⚑4):
# BareArgumentGuard.java (new: a listener for Boot's ApplicationEnvironmentPreparedEvent that refuses a bare argument, exit code 2,
# printing only a bare number of one to five digits), BareArgumentAnalyzer.java (new: its failure analysis), META-INF/spring.factories
# (the listener's key added, the analyzer added to the FailureAnalyzer key, the comment rewritten) and TiffinBoxApp.java (one
# Javadoc sentence, RED C5-S2 #8). Twelve captures, each run three times and hashed; cap() DIES when a hash differs from
# receipts.md5; every number the video says is asserted at the bottom by a check that can fail; the demo token is masked (gsub),
# and the checks count 0 raw copies of it in every capture, in the log of every run - every failed start's included - in every
# file this unit ships, and in the binary it builds. A planted canary, passed after a space, is counted in every log it could
# reach: 0 (and 1 in the command that carried it - the counter counts).
#   bare      the previous tree, the README's old command - the port in TIFFINBOX_PORT, a bare number after the jar: it listens on
#             the variable's port, the bare one has no listener, the seven
#   refuse    the break, a bare argument: A after/, the README's run line · B the README's old command · A' = A
#   args      the harness's runner (Report) joined to the previous tree: what Boot hands a runner - option names, non-option
#             arguments, an option's values, the count; the kitchen read; then on after/, options only: SpringApplication.exit 3
#   order     after/ with the harness's witness (Order, named in its own spring.factories) and one runner: Boot's hooks in the
#             order its output prints them - environment, banner, context, refresh (TiffinBox listening), runners, ready
#   change    the previous tree against after/: the guard and the analyzer (their code lines), the factories file, TiffinBoxApp's
#             Javadoc hunk (diff -U0), the rest the same; the sentence's measurement - the harness's Sources, without and with
#             default properties
#   late      C (labelled): the same check as a runner (the harness's LateGuard) - on the previous tree it refuses after TiffinBox
#             listened; joined to after/, the anchor's guard refuses first
#   dashd     D (labelled): a -D option after the jar - the previous tree drops it (120 orders); after/ refuses it; the README's
#             line with -D before -jar: 40
#   canary    E (labelled): a planted canary passed after a space - the previous tree, then after/: exit 1, then 2, the canary 0
#             times in each log
#   codes     the exit codes, each measured: POST /shutdown 0 · a port taken 1 · a bare argument 2 · SpringApplication.exit 3
#             (the harness) · SIGTERM 143
#   banner    the README's banner file: the jar, the folders (the README's class-path line), Boot's own banner, banner-mode off
#   native    after/ built natively (the README's two Maven lines): what Spring's AOT step registered; the AOT jar and the binary,
#             each refusing a bare argument and serving without it; the binary's banner
#   exercise  exercise/README.md's commands and exercise/solution/SOLUTION.md's, read from the files and run as written
# "before" is ../c5-unit26/after (the anchor as the failure lesson left it), COPIED under .harness/; this script never writes into
# another unit's folder. after/ is this unit's frozen copy of ../c5-tiffinbox after the change; it is copied, never built in
# place. Every run of TiffinBox starts in a folder under .harness/ that holds a config tree with the demo token (secrets/), as the
# README asks. Commands are printed exactly as they run: each goes through eval. "$CURLSET" is the comparison set since the secrets
# lesson (../c5-unit11/curlset.sh: the seven requests, POST /shutdown with the token's header read from the file). "$M2" is this
# unit's own repository, .m2-demo. The harness (harness/probe/cli/: Report, LateGuard, Order, Sources; harness/order/: Order's
# spring.factories) is compiled into .harness/hc and joined by --spring.main.sources (Order by its own file, ../ho; Sources runs
# alone): it lives outside com.tiffinbox, and it is the course's, never TiffinBox's. No harness passes a bare word to a guarded
# tree except to show the refusal (brief ⚑18).
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
# exception's class, marked " …"), Boot's hint about the condition report and the analysis - from "Description:" to its end,
# blank lines left out - are shown. A run's banner lines and its lines of Boot's and TiffinBox's log are counted or printed from
# their message on (no time, no process id). Boot's first line is printed from its message on, cut before " with PID". No duration
# is captured: the native build is judged against a bound; seconds go to the terminal.
# Ports (brief ⚑1, 19060-19069): refuse A 19060 · bare and refuse B 19061 (TIFFINBOX_PORT) and 19062 (the bare argument: never
# bound) · args 19063 · order 19064 · late 19065 · dashd 19066 · canary 19067 · codes 19068 · banner, native and the exercise
# 19069. change's runs open no port. 18425 (TiffinBox's default) and 8080 (Tomcat's) are checked free too, and never bound.
set -e
# bash 5.2 and later turn an & in the replacement of ${x/pattern/replacement} into the matched text (patsub_replacement, on by
# default). Switched off, so /bin/bash 3.2 (./receipts.sh) and a newer bash (bash receipts.sh) run the same commands; 3.2 has no
# such option. (exe() inserts its "exec" with sed, not with ${x/a/b}.)
shopt -u patsub_replacement 2> /dev/null || true
cd "$(dirname "$0")"
# One run at a time: two runs share .harness/ and the ports, and one would corrupt the other.
mkdir .r-lock 2> /dev/null || { echo "  *** another receipts.sh is running in this folder (.r-lock exists) - if none is, rmdir .r-lock ***"; exit 1; }
# On every exit - the end, a failed check, or Ctrl-C - stop the processes this script started in the background ($pid, a server;
# $fpid, a start expected to end by itself), if they still run (a background job of a non-interactive shell ignores the terminal's
# Ctrl-C), then sweep(): anything of this run still alive in its process group - a TiffinBox JVM (a jar, an extracted class path,
# a folder run), the harness's Sources, a binary, native-image's driver or builder - is stopped. After an interrupt, a capture's
# unfinished runs (.r-NAME.1-3) go too; after a failed check they stay, for the diff the message names. The clean-up ignores a
# second Ctrl-C, and nothing in it can fail under set -e, so it always reaches the rmdir; the script still exits 130 after an
# interrupt (README.md, "Interrupted"). $pid and $fpid are cleared whenever their process has been reaped.
pid=""; fpid=""
sweep() { local g i l
  g=$(ps -o pgid= -p $$ 2> /dev/null | tr -d ' ') || g=""
  [ -n "$g" ] || return 0
  i=0; while [ $i -lt 20 ]; do
    l=$(ps -axo pid=,pgid=,command= 2> /dev/null | awk -v g="$g" -v me=$$ -v gh="${GRAALVM_HOME:-/nonexistent}" '
      $2 == g && $1 != me && $3 != "awk" && $3 != "ps" && (index($0, "vminvocation.args") || index($3, gh "/bin/native-image") || $3 ~ /tiffinbox-web\/target\/tiffinbox-web$/ || index($0, "tiffinbox-web-1.0.0.jar") || index($0, "com.tiffinbox.web.TiffinBoxServer") || index($0, "probe.cli.Sources")) { print $1 }' | paste -sd' ' -) || l=""
    [ -n "$l" ] || return 0
    if [ $i -lt 10 ]; then kill $l 2> /dev/null || true; else kill -9 $l 2> /dev/null || true; fi
    sleep 0.5; i=$((i + 1)); done; }
trap 'trap "" INT TERM; for p in "$pid" "$fpid"; do if [ -n "$p" ] && kill "$p" 2> /dev/null; then wait "$p" 2> /dev/null || true; fi; done; sweep || true; [ -z "$INTR" ] || rm -f .r-*.[123]; rmdir .r-lock 2> /dev/null || true' EXIT
INTR=""; trap 'INTR=1; exit 130' INT TERM
exec 3>&1                                            # die() speaks to the terminal even inside a redirected capture
die() { echo "  *** $* ***" >&3; exit 1; }
java -version 2>&1 | grep -q 'version "25' || die "JDK 25 needed; JAVA_HOME gives: $(java -version 2>&1 | head -1)"
command -v javac > /dev/null || die "javac is needed: the harness's classes are compiled here"
command -v python3 > /dev/null || die "python3 is needed: Spring's AOT metadata is read through a filter"
command -v curl > /dev/null || die "curl is needed: every request here is curl's"
command -v rsync > /dev/null || die "rsync is needed: every tree is copied with it"
command -v unzip > /dev/null || die "unzip is needed: banner reads the jar's manifest"
# A variable of yours must not become a property source, a JVM flag, a build setting or a native-image option: every
# TIFFINBOX_*, SPRING_*, MANAGEMENT_*, SERVER_* and LOGGING_* variable, DEBUG (Boot reads it as --debug), the variables that inject
# JVM flags, MAVEN_OPTS, MAVEN_ARGS and NATIVE_IMAGE_OPTIONS are removed first. GRAALVM_HOME stays: it says which GraalVM to use.
# (A TIFFINBOX_PORT of yours would move every run here; the captures set it only on the one command that shows it.)
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
[ -e after/secrets ] || [ -e after/tiffinbox-web/secrets ] || [ -e after/tiffinbox-local.yaml ] || [ -e after/target ] || [ -e after/banner.txt ] && die "after/ holds a secrets/, a tiffinbox-local.yaml, a banner.txt or a target/ - it is the anchor's frozen copy, never built in place; remove them"
M2="$PWD/.m2-demo"; U="$PWD"; UP="$(cd .. && pwd)"; ME="$(id -un)"
PREV=../c5-unit26/after                              # the previous tree: read, copied, never built in place
BIN=tiffinbox-web/target/tiffinbox-web               # the binary native:compile-no-fork writes, in a tree's web module
TF=secrets/tiffinbox/shutdown-token                  # the config tree's file for tiffinbox.shutdown-token
GUARD=tiffinbox-web/src/main/java/com/tiffinbox/web/BareArgumentGuard.java
ANA=tiffinbox-web/src/main/java/com/tiffinbox/web/BareArgumentAnalyzer.java
FAC=tiffinbox-web/src/main/resources/META-INF/spring.factories
APP=tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxApp.java
EXL=tiffinbox-web/target/extracted/lib               # the extracted jar's lib/, in a tree's web module
AOTMETA=tiffinbox-web/target/spring-aot/main/resources/META-INF/native-image/com.tiffinbox/tiffinbox-web/reachability-metadata.json
# The demo token. FAKE, and meant to look it: it guards nothing but a demo server on 127.0.0.1 that every capture stops. It is
# written into .harness/*/secrets/ (git-ignored) when this script runs, and no capture prints it: see mask().
TOKEN=not-a-real-token-demo-only
[ ${#TOKEN} = 26 ] || die "the demo token must be 26 characters"
# The canary: not a secret - a value no capture may hold except in the one command that carries it (canary, E).
CAN=planted-canary-value
CURLSET=../c5-unit11/curlset.sh                      # the comparison set: the seven requests, POST /shutdown with the header
[ -f "$CURLSET" ] || die "$CURLSET is missing"
[ -f "$PREV/pom.xml" ] && [ -f after/pom.xml ] && [ -f after/README.md ] || die "the previous tree $PREV or after/ is missing"
for f in harness/shutdown.sh harness/seven.sh harness/probe/cli/Report.java harness/probe/cli/LateGuard.java harness/probe/cli/Order.java harness/probe/cli/Sources.java harness/probe/sources.properties harness/order/META-INF/spring.factories; do [ -f "$f" ] || die "harness/ is missing $f"; done

# The ports, BEFORE anything is wiped (a survivor of an interrupted run answers POST /shutdown only with its token, which lives
# in .harness/ - so the message names the process to kill).
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
for p in 18425 8080 19060 19061 19062 19063 19064 19065 19066 19067 19068 19069; do
  [ "$(listeners $p)" = 0 ] || die "something already listens on $p - this unit's ports must be free; if it is a TiffinBox an interrupted run left behind, stop it: kill $(lsof -nP -iTCP:$p -sTCP:LISTEN -t 2> /dev/null | paste -sd' ' -)"; done

# ---- the commands: read from after/README.md, the anchor's own, and asserted - each line must be there, whole -------------
readme() { grep -m1 -xF -- "$1" after/README.md > /dev/null || die "after/README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
R_PLAIN=$(readme 'mvn -B package')
R_CPB=$(readme 'mvn -B package dependency:build-classpath -Dmdep.outputFile=target/classpath.txt')
R_RUN=$(readme 'java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431')
R_BARE=$(readme 'TIFFINBOX_PORT=18432 java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar 18431')
R_DLATE=$(readme 'java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 -Dtiffinbox.days=10')
R_DFIRST=$(readme 'java -Dtiffinbox.days=10 -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431')
R_KITCHEN=$(readme "curl -s -w ' %{http_code}\n' http://127.0.0.1:18431/kitchen")
R_BFILE=$(readme "printf '%s\n' 'title=[\${application.title}] version=[\${application.version}] boot=[\${spring-boot.version}]' > banner.txt")
R_BJAR=$(readme 'java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --spring.banner.location=file:banner.txt')
R_BDIR=$(readme 'java -cp "tiffinbox-web/target/classes:$(cat tiffinbox-web/target/classpath.txt)" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431 --spring.banner.location=file:banner.txt')
R_BBIN=$(readme 'tiffinbox-web/target/tiffinbox-web --tiffinbox.port=18431 --spring.banner.location=file:banner.txt')
R_BOFF=$(readme 'java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --spring.main.banner-mode=off')
R_AOTRUN=$(readme 'java -Dspring.aot.enabled=true -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431')
R_GRAAL=$(readme 'export GRAALVM_HOME=/path/to/a/graalvm-jdk-25')
R_INSTALL=$(readme 'mvn -B -Pnative install')
R_NATIVE=$(readme 'mvn -B -Pnative -pl tiffinbox-web native:compile-no-fork')
R_BIN=$(readme 'tiffinbox-web/target/tiffinbox-web --tiffinbox.port=18431')
R_EXTRACT=$(readme 'java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted')
R_CP=$(readme 'java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431')
R_READY=$(readme "curl -s -w ' %{http_code}\n' http://127.0.0.1:18431/actuator/health/readiness")
# off DIR 'README mvn LINE' [PHASE]: the README's Maven line as this script runs it - from DIR, offline (-o), this unit's own
# repository, and for a build phase (package, install) clean and without tests. dev() takes those four things back out, and
# must give the README's line again: so the command on screen is the README's, with exactly those changes.
off() { local c=${2/mvn -B /mvn -o -B -Dmaven.repo.local=\"\$M2\" }
  [ -n "$3" ] && c=${c/ $3/ -DskipTests clean $3}
  printf 'cd %s && %s\n' "$1" "$c"; }
dev() { local c=${1#cd * && }; c=${c/ -o -B -Dmaven.repo.local=\"\$M2\" / -B }; c=${c/ -DskipTests clean / }; printf '%s\n' "$c"; }
# at DIR PORT 'README LINE': the README's line run from DIR, its port 18431 made PORT
at() { printf 'cd %s && %s\n' "$1" "${3/--tiffinbox.port=18431/--tiffinbox.port=$2}"; }
# bareat DIR VPORT BPORT: the README's old command run from DIR - its variable's port 18432 made VPORT, its bare 18431 made BPORT
bareat() { local c=${R_BARE/TIFFINBOX_PORT=18432/TIFFINBOX_PORT=$2}; printf 'cd %s && %s %s\n' "$1" "${c% 18431}" "$3"; }
# url 'README curl LINE' PORT: the README's curl line, its port 18431 made PORT
url() { printf '%s\n' "${1/:18431\//:$2/}"; }
# hcp DIR PORT SOURCES ['FLAGS'] [EXTRA]: the README's exploded run - the extracted jar on the class path, TiffinBox's own main -
# from DIR, its port made PORT, the harness's classes added to the class path (../hc, then EXTRA) and SOURCES joined
# (--spring.main.sources); FLAGS after
hcp() { local c; c=$(at "$1" "$2" "$R_CP"); c=${c/lib\/\*\"/lib\/*:..\/hc${5:+:$5}\"}; printf '%s --spring.main.sources=%s%s\n' "$c" "$3" "${4:+ $4}"; }
# sources DIR 'FLAG': the same class path, the harness's Sources as the main class instead of TiffinBox's (no port, no web)
sources() { local c; c=$(at "$1" 18431 "$R_CP"); c=${c/lib\/\*\"/lib\/*:..\/hc\"}; printf '%s probe.cli.Sources %s\n' "${c% com.tiffinbox.web.TiffinBoxServer *}" "$2"; }
# exe 'COMMAND': the command with "exec" after its "cd DIR && " and any NAME=value before the program - so $pid is the program's
exe() { printf '%s\n' "$1" | sed -E 's/&& (([A-Z_]+=[^ ]* )*)/\&\& \1exec /'; }
C_AFTER=$(off .harness/after "$R_INSTALL" install)
for c in "$C_AFTER" "$(off .harness/x "$R_PLAIN" package)" "$(off .harness/x "$R_CPB" package)" "$(off .harness/x "$R_NATIVE")"; do
  r=$(dev "$c"); [ "$r" = "$R_PLAIN" ] || [ "$r" = "$R_CPB" ] || [ "$r" = "$R_INSTALL" ] || [ "$r" = "$R_NATIVE" ] || die "not a README line with the offline changes: $c"; done
[ "$(bareat .harness/x 19061 19062)" = 'cd .harness/x && TIFFINBOX_PORT=19061 java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar 19062' ] || die "the old command, its ports"
[ "$(exe "$(bareat .harness/x 19061 19062)")" = 'cd .harness/x && TIFFINBOX_PORT=19061 exec java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar 19062' ] || die "exe(), after a variable"
[ "$(hcp .harness/x 19064 probe.cli.Report '' ../ho)" = 'cd .harness/x && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc:../ho" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19064 --spring.main.sources=probe.cli.Report' ] || die "the exploded run with the harness's witness"
[ "$(hcp .harness/x 19063 probe.cli.Report '--tiffinbox.days=10 19062')" = 'cd .harness/x && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19063 --spring.main.sources=probe.cli.Report --tiffinbox.days=10 19062' ] || die "the exploded run with the harness's runner"
[ "$(sources .harness/x --probe.defaults=no)" = 'cd .harness/x && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" probe.cli.Sources --probe.defaults=no' ] || die "the harness's Sources"
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
echo "  .m2-demo holds Boot's parent, GraalVM's native plugin 1.1.8 and its metadata repository ($(wc -c < "$ZIP" | tr -d ' ') bytes)"
# The README's class-path line needs Maven's dependency plugin, which no build before it uses: run once here, before the captures,
# so a fresh clone fetches it now (offline first, then Maven Central once, and the line says which) and every capture's build says
# "offline: yes". It rebuilds .harness/after without the profile native; the harness is compiled against this build's jar.
mbuild "$(off .harness/after "$R_CPB" package)" .harness/build-cp.log ".harness/after again (the README's class-path line: Maven's dependency plugin into \$M2)"
[ -s .harness/after/tiffinbox-web/target/classpath.txt ] || die "the README's class-path line wrote no tiffinbox-web/target/classpath.txt"
# The harness: Report, LateGuard, Order and Sources compiled against the jar the first build made (extracted: its classes and the
# jars it ships), into .harness/hc - outside every tree, outside com.tiffinbox - with Sources' one file beside them; Order's
# spring.factories copied alone into .harness/ho, joined to the class path of the order capture only
(cd .harness/after && eval "$R_EXTRACT") > .harness/extract-after.log 2>&1 || { cat .harness/extract-after.log >&3; die "the README's extract command failed in .harness/after"; }
javac -d .harness/hc -cp ".harness/after/tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:.harness/after/$EXL/*" harness/probe/cli/*.java > .harness/javac.log 2>&1 || { cat .harness/javac.log >&3; die "the harness did not compile"; }
cp harness/probe/sources.properties .harness/hc/probe/sources.properties
mkdir -p .harness/ho && rsync -a harness/order/ .harness/ho/
echo "  the harness: harness/probe/cli/ compiled into .harness/hc ($(find .harness/hc -name '*.class' | wc -l | tr -d ' ') classes); harness/order/ copied to .harness/ho"

# ---- helpers ------------------------------------------------------------------------------------------------------------
# raw TOKEN FILE...: how many times TOKEN appears, raw, in the files (occurrences, not lines; binary files read as text)
raw() { local t=$1; shift; cat "$@" | LC_ALL=C grep -aoF -- "$t" | wc -l | tr -d ' '; }
LOGS=0                                               # how many runs' logs were counted for the token and its header
FLOGS=0                                              # how many logs of starts that ended by themselves were counted for the token
LASTE=""                                             # the exit code of the last run that ended
# first LOG: Boot's first log line, from its message on, cut before " with PID"
first() { grep -m1 ' : Starting ' "$1" | sed 's/^.* : //; s/ with PID .*$//'; }
# start 'COMMAND': print it exactly as typed, run it in the background (eval, from this folder; exec, so $pid is the program's
# own pid), its standard output to .harness/run.out and its standard error to .harness/run.err
start() { echo "\$ $1"; (eval "$(exe "$1")") > .harness/run.out 2> .harness/run.err < /dev/null & pid=$!; }
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
# ready PORT: readiness asked until it answers 200 - every 0.25 s, up to 60 s, not printed - then the README's readiness line,
# printed and run once. No assertion before it (brief S5.28): readiness holds the kitchen, and its database.
ready() { local i=0 c=""
  while [ $i -lt 240 ]; do c=$(curl -s -o /dev/null -w '%{http_code}' "http://127.0.0.1:$1/actuator/health/readiness" 2> /dev/null || true); [ "$c" = 200 ] && break
    kill -0 "$pid" 2> /dev/null || { tail -20 .harness/run.out >&3; die "it exited before readiness answered 200"; }; sleep 0.25; i=$((i + 1)); done
  [ "$c" = 200 ] || die "readiness never answered 200 on $1"
  ask "$R_READY" "$1"; }
# logtok: the log of the run that just ended (standard output and error) counted for the demo token, for its header's name
# (X-Shutdown-Token, in any case) and for the canary, raw - each must be 0
logtok() { local t h k; t=$(raw "$TOKEN" .harness/run.out .harness/run.err); h=$(cat .harness/run.out .harness/run.err | LC_ALL=C grep -aoi -- 'x-shutdown-token' | wc -l | tr -d ' '); k=$(raw "$CAN" .harness/run.out .harness/run.err)
  LOGS=$((LOGS + 1)); [ "$t" = 0 ] && [ "$h" = 0 ] && [ "$k" = 0 ] || die "a log held the demo token ($t), its header's name ($h) or the canary ($k)"
  echo "  its log: the demo token 0 times · X-Shutdown-Token 0 times"; }
# heard LOG: what a run's log says about how far the start got - Boot's banner (its ":: Spring Boot ::" line), TiffinBox's
# listening line - counted
heard() { echo "  its log: the banner's :: Spring Boot :: line $(grep -c ':: Spring Boot ::' "$1" || true) · TiffinBox listening $(grep -c 'TiffinBox listening on ' "$1" || true)"; }
# seven PORT DIR [all]: the comparison set's seven requests (POST /shutdown carries the header, read from DIR's token file),
# printed as run - every response line with "all", else the POST line; the process must leave within 15 s of them, and the port
# must be free again; then its log counted for the token, its header and the canary (logtok). Never call it inside $(...): wait
# needs this shell.
seven() { local i e=0
  echo "\$ \$CURLSET $1 $2/$TF"
  "$CURLSET" "$1" "$2/$TF" | grep ' -> ' > .harness/responses.txt || true
  if [ "$3" = all ]; then sed 's/^/  /' .harness/responses.txt; else grep '^POST ' .harness/responses.txt | sed 's/^/  /' || echo "  (no POST line)"; fi
  i=0; while kill -0 "$pid" 2> /dev/null && [ $i -lt 60 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$pid" 2> /dev/null && { kill "$pid"; die "the server on $1 was still running 15 s after POST /shutdown"; }
  wait "$pid" || e=$?; pid=""; LASTE=$e
  [ "$(listeners "$1")" = 0 ] || die "something still listens on $1"
  echo "  exit $e · the seven responses: $(wc -l < .harness/responses.txt | tr -d ' ') lines · md5 $(md5 -q .harness/responses.txt)"
  logtok; }
# stop PORT DIR: POST /shutdown on PORT with DIR's token (harness/shutdown.sh), then as ends()
stop() { echo "\$ harness/shutdown.sh $1 $2/$TF"; harness/shutdown.sh "$1" "$2/$TF" | sed 's/^/  /'; ends "$1"; }
# ends PORT: after a POST /shutdown - the process must leave within 15 s, the port must be free; its exit code, then its log
# counted (logtok)
ends() { local i=0 e=0
  while kill -0 "$pid" 2> /dev/null && [ $i -lt 60 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$pid" 2> /dev/null && { kill "$pid"; die "the server on $1 was still running 15 s after POST /shutdown"; }
  wait "$pid" || e=$?; pid=""; LASTE=$e
  [ "$(listeners "$1")" = 0 ] || die "something still listens on $1"
  echo "  exit $e · listening on $1 now: 0"; logtok; }
# cooked: TiffinBox's own line at start about the kitchen, from its message on (the run that just ended)
cooked() { echo "  its log: $(grep -m1 ' : orders cooked: ' .harness/run.out | sed 's/^.* : //')"; }
# A Boot log line, as Logback writes it: "<time> <LEVEL> <pid> --- [<thread>] <logger, padded to 40> : <message>".
# SHAPEAWK: a failed start's log (its standard output), read whole and printed as its shape: the analysis banner, the stack
# frames ("at" lines), the "Caused by:" lines and the frames Logback folds as common ("... N common frames omitted"), counted; the
# WARN, ERROR and DEBUG lines from their level on, a WARN's message cut after its exception's class (" …"); the first line of
# each exception, and the frames under each one; Boot's hint about the condition report; then the analysis, from "Description:"
# to its end, its blank lines left out
SHAPEAWK='
an { if (NF) ana[++na] = "  " $0; next }
/^Description:$/ { an = 1; ana[++na] = "  " $0; next }
/^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T[^ ]+ +[A-Z]+ +[0-9]+ --- \[/ {
  lv = $2; s = $0; i = index(s, " --- ["); s = substr(s, i + 6); i = index(s, "] "); s = substr(s, i + 2)
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
END {
  by = ""; for (i = 1; i <= ne; i++) by = by (i == 1 ? " = " : " + ") (fx[i] + 0)
  print "  its log, read after it exited: APPLICATION FAILED TO START " (ban + 0) " · stack frames " (fr + 0) (fr ? by : "") " · Caused by: " (cb + 0) " · frames folded as common " (om + 0)
  for (i = 1; i <= nl; i++) print ln[i]
  for (i = 1; i <= ne; i++) print ex[i]
  if (hint != "") print "  the hint Boot logs: " hint
  for (i = 1; i <= na; i++) print ana[i] }'
# ended 'COMMAND': a start expected to end by itself - a failure, or a harness's exit - printed exactly as typed and run (eval,
# from this folder; exec, so $fpid is the program's own pid), its standard output to .harness/fail.out and its standard error to
# .harness/fail.err - bounded: polled for 60 s (no timeout command here); then its exit code, and the token and the canary in
# both, raw - which must be 0 (fails() and quits() print the rest)
ended() { local e=0 i=0 t k
  echo "\$ $1"; (eval "$(exe "$1")") > .harness/fail.out 2> .harness/fail.err < /dev/null & fpid=$!
  while kill -0 "$fpid" 2> /dev/null && [ $i -lt 240 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$fpid" 2> /dev/null && { kill "$fpid"; die "a start expected to end still ran after 60 s: $1"; }
  wait "$fpid" || e=$?; fpid=""; LASTE=$e
  echo "  exit $e"
  t=$(raw "$TOKEN" .harness/fail.out .harness/fail.err); k=$(raw "$CAN" .harness/fail.out .harness/fail.err); FLOGS=$((FLOGS + 1))
  [ "$t" = 0 ] && [ "$k" = 0 ] || die "a log held the demo token ($t) or the canary ($k)"; }
# fails 'COMMAND': ended(), then the log's shape (SHAPEAWK), how far the start got (heard), its standard error's line count and
# the token in its log
fails() { ended "$1"; awk "$SHAPEAWK" .harness/fail.out; heard .harness/fail.out
  echo "  its standard error: $(wc -l < .harness/fail.err | tr -d ' ') lines · the demo token in its log: 0"; }
# quits 'COMMAND': ended(), then the harness's own lines (from "harness: " on), how far the start got (heard), and its log's
# analysis banner and stack frames, counted
quits() { ended "$1"; sed -n 's/^harness: /  harness: /p' .harness/fail.out; heard .harness/fail.out
  echo "  its log: APPLICATION FAILED TO START $(grep -c '^APPLICATION FAILED TO START$' .harness/fail.out || true) · stack frames $(grep -c "^$(printf '\t')at " .harness/fail.out || true) · the demo token 0"; }
# now PORT...: what listens on each port now (lsof), after the run ended
now() { local p o=""; for p in "$@"; do o="$o${o:+ · }$p $(listeners "$p")"; done; echo "  listening now: $o"; }
# code FILE: FILE's lines that are neither comment nor blank, their leading blanks kept
code() { grep -vE '^[[:space:]]*(\*|/\*\*|\*/|//|#|$)' "$1"; }
# aotmeta FILE: what Spring's AOT step wrote for the binary about TiffinBox's names in spring.factories (reachability-metadata.json,
# from process-aot): the resource META-INF/spring.factories, and each class's reflection entry
aotmeta() { python3 - "$1" <<'PY'
import json, sys
d = json.load(open(sys.argv[1]))
res = [r.get("glob", r.get("pattern")) for r in d.get("resources", [])]
print("  the resource META-INF/spring.factories: %s" % ("yes" if "META-INF/spring.factories" in res else "no"))
for t in ("com.tiffinbox.web.BareArgumentGuard", "com.tiffinbox.web.BareArgumentAnalyzer", "com.tiffinbox.web.PortTakenFailureAnalyzer"):
    hit = [e for e in d.get("reflection", []) if e.get("type") == t]
    print("  reflection entries for %s: %d%s" % (t, len(hit), "".join(" · " + " ".join(sorted(k for k, v in e.items() if v is True)) for e in hit)))
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
# pbuild DIR 'LABEL' ['README LINE']: the README's plain Maven line (or LINE), offline, from DIR
pbuild() { local c; c=$(off "$1" "${3:-$R_PLAIN}" package); echo "\$ $c"; mbuild "$c" "$1.build.log" "$2"; }
# extract DIR: the README's extract line, from DIR (after a clean build: the destination must not exist)
extract() { echo "\$ cd $1 && $R_EXTRACT"
  (cd "$1" && eval "$R_EXTRACT") > "$1.extract.log" 2>&1 || { cat "$1.extract.log" >&3; die "the extract failed in $1"; }
  echo "  extracted: exit 0 · its lib/ holds $(ls "$1/$EXL" | wc -l | tr -d ' ') jars"; }

# ---- bare: the previous tree, the README's old command --------------------------------------------------------------------
bare() {
  echo "the previous tree (the anchor as the failure lesson left it), copied to .harness/prev with a config tree, built the"
  echo "README's plain way and extracted; then the README's old command - the port in TIFFINBOX_PORT (19061), a bare 19062:"
  copy "$PREV" .harness/prev
  pbuild .harness/prev "the previous tree"
  extract .harness/prev
  start "$(bareat .harness/prev 19061 19062)"; up; ready 19061
  echo "  listening on 19062: $(listeners 19062)"
  seven 19061 .harness/prev all; }

# ---- refuse: the break - a bare argument ------------------------------------------------------------------------------------
refuse() {
  echo "after/, copied to .harness/serve with a config tree, built with the README's class-path line (offline) and extracted:"
  copy after .harness/serve
  pbuild .harness/serve "after/" "$R_CPB"
  echo "  tiffinbox-web/target/classpath.txt: $([ -s .harness/serve/tiffinbox-web/target/classpath.txt ] && echo written || echo missing)"
  extract .harness/serve
  echo "A - after/, the README's run line, port 19060:"
  start "$(at .harness/serve 19060 "$R_RUN")"; up; ready 19060
  seven 19060 .harness/serve all
  echo "B - after/, the README's old command: the port in TIFFINBOX_PORT (19061), a bare 19062:"
  fails "$(bareat .harness/serve 19061 19062)"
  now 19061 19062
  echo "A' - A again:"
  start "$(at .harness/serve 19060 "$R_RUN")"; up; ready 19060
  seven 19060 .harness/serve; }

# ---- args: what Boot hands a runner ---------------------------------------------------------------------------------------------
args() {
  echo "the harness's Report (a runner) joined to the previous tree - the README's exploded run, ../hc on the class path - with"
  echo "two options and a bare number, port 19063:"
  start "$(hcp .harness/prev 19063 probe.cli.Report '--tiffinbox.days=10 19062')"; up; ready 19063
  ask "$R_KITCHEN" 19063
  stop 19063 .harness/prev
  sed -n 's/^harness: /  harness: /p' .harness/run.out
  echo "  listening on 19062: $(listeners 19062)"
  echo "after/ - the same runner, options only, and --probe.exit=3 (Report ends the start through SpringApplication.exit):"
  quits "$(hcp .harness/serve 19063 probe.cli.Report '--tiffinbox.days=10 --probe.exit=3')"
  now 19063; }

# ---- order: Boot's hooks, in the order its output prints them ---------------------------------------------------------------------
# marks LOG: the lines that mark a hook, in the order they are in the output - the harness's Order lines, Boot's banner, TiffinBox's
# listening line, the runner's line, Boot's Started line - numbered
marks() { awk '/^hook: / { print ++n " " $0; next } /:: Spring Boot ::/ { print ++n " the banner"; next }
  / : TiffinBox listening on / { print ++n " TiffinBox listening - its @PostConstruct, in the refresh"; next }
  /^harness: option names / { print ++n " the runner (the harness'"'"'s Report)"; next }
  / : Started TiffinBoxServer in / { print ++n " Boot'"'"'s Started line"; next }' "$1" | sed 's/^/  /'; }
order() {
  echo "after/ with the harness's witness - Order, named in its own spring.factories (../ho on the class path) - and its Report as"
  echo "the one runner; port 19064:"
  start "$(hcp .harness/serve 19064 probe.cli.Report '' ../ho)"; up; ready 19064
  seven 19064 .harness/serve
  echo "the start, read from its output after it stopped - each hook's line, in order:"
  marks .harness/run.out; }

# ---- change: the previous tree against after/ ---------------------------------------------------------------------------------
change() { local f
  echo "the previous tree against after/, both copied under .harness/ - the files that differ:"
  echo "\$ diff -rq -x target -x secrets .harness/before .harness/after"
  diff -rq -x target -x secrets .harness/before .harness/after | sed 's/^/  /' || true
  for f in "$GUARD" "$ANA"; do
    echo "  $f - new; its lines that are neither comment nor blank: $(code ".harness/after/$f" | wc -l | tr -d ' ')"
    code ".harness/after/$f" | sed 's/^/    /'; done
  code ".harness/before/$FAC" > .harness/fb.txt; code ".harness/after/$FAC" > .harness/fa.txt
  echo "  $FAC - its lines that are neither comment nor blank, before then after:"
  sed 's/^/    before /' .harness/fb.txt; sed 's/^/    after  /' .harness/fa.txt
  echo "  $FAC - its comment lines: before $(grep -c '^#' ".harness/before/$FAC" || true), after $(grep -c '^#' ".harness/after/$FAC" || true)"
  echo "  $APP - the hunks (diff -U0, without its two file lines):"
  diff -U0 ".harness/before/$APP" ".harness/after/$APP" | sed '1,2d' | sed 's/^/    /' || true
  code ".harness/before/$APP" > .harness/fb.txt; code ".harness/after/$APP" > .harness/fa.txt
  echo "  $APP - its lines that are neither comment nor blank, against the previous tree's: $(cmp -s .harness/fb.txt .harness/fa.txt && echo the same || echo different)"
  diff .harness/before/README.md .harness/after/README.md > .harness/file.diff || true
  echo "  README.md - the anchor's README: lines added $(grep -c '^> ' .harness/file.diff || true), removed $(grep -c '^< ' .harness/file.diff || true) - its new section and five history notes (not shown)"
  echo "  tiffinbox-core against the previous tree's (diff -rq -x target): $(diff -rq -x target .harness/before/tiffinbox-core .harness/after/tiffinbox-core | wc -l | tr -d ' ') files differ"
  for f in TiffinBoxServer PortTakenFailureAnalyzer ActuatorRoutes KitchenHealthIndicator KitchenMetrics Route; do f=tiffinbox-web/src/main/java/com/tiffinbox/web/$f.java
    echo "  $(basename "$f") against the previous tree's, byte for byte: $(cmp -s ".harness/before/$f" ".harness/after/$f" && echo the same || echo different)"; done
  for f in tiffinbox-web/src/main/resources/application.yaml tiffinbox-web/pom.xml pom.xml; do
    echo "  $f against the previous tree's, byte for byte: $(cmp -s ".harness/before/$f" ".harness/after/$f" && echo the same || echo different)"; done
  echo "the Javadoc's sentence, measured - the harness's Sources (a configuration class, one @PropertySource file, no web server) on"
  echo "after/'s extracted class path, from .harness/serve and its config tree; without default properties, then with them:"
  for f in --probe.defaults=no --probe.defaults=yes; do
    echo "\$ $(sources .harness/serve "$f")"
    (eval "$(sources .harness/serve "$f")") > .harness/src.out 2>&1 < /dev/null || { tail -20 .harness/src.out >&3; die "the harness's Sources failed"; }
    sed -n 's/^harness: /  harness: /p' .harness/src.out
    [ "$(raw "$TOKEN" .harness/src.out)" = 0 ] || die "the harness's Sources printed the demo token"; done; }

# ---- late: C (labelled) - the same check as a runner ----------------------------------------------------------------------------
late() {
  echo "C (labelled) - the same check as a runner: the harness's LateGuard joined to the previous tree, a bare number, port 19065:"
  fails "$(hcp .harness/prev 19065 probe.cli.LateGuard 19062)"
  echo "  in its log, TiffinBox's listening line comes before Boot's Application run failed: $(awk '/ : TiffinBox listening on / && !l { l = NR } / : Application run failed$/ && !f { f = NR } END { print (l && f && l < f) ? "yes" : "no" }' .harness/fail.out)"
  now 19065 19062
  echo "the same runner joined to after/ - the anchor's guard runs first:"
  fails "$(hcp .harness/serve 19065 probe.cli.LateGuard 19062)"
  now 19065 19062; }

# ---- dashd: D (labelled) - a -D option after the jar -------------------------------------------------------------------------------
dashd() {
  echo "D (labelled) - a -D option after the jar: the previous tree, the README's line, port 19066:"
  start "$(at .harness/prev 19066 "$R_DLATE")"; up; ready 19066
  ask "$R_KITCHEN" 19066
  stop 19066 .harness/prev; cooked
  echo "after/ - the same line:"
  fails "$(at .harness/serve 19066 "$R_DLATE")"
  now 19066
  echo "after/ - the README's line with the -D before -jar:"
  start "$(at .harness/serve 19066 "$R_DFIRST")"; up; ready 19066
  ask "$R_KITCHEN" 19066
  stop 19066 .harness/serve; cooked; }

# ---- canary: E (labelled) - a value typed after a space ----------------------------------------------------------------------------
canary() { local c
  echo "E (labelled) - a value typed after a space: the README's run line, port 19067, then --tiffinbox.shutdown-token and a"
  echo "planted canary (not a token) as the next argument. The previous tree:"
  c="$(at .harness/prev 19067 "$R_RUN") --tiffinbox.shutdown-token $CAN"; fails "$c"
  echo "  the canary: in the command above $(printf '%s\n' "$c" | LC_ALL=C grep -oF -- "$CAN" | wc -l | tr -d ' ') · in its log (standard output and error) $(raw "$CAN" .harness/fail.out .harness/fail.err)"
  now 19067
  echo "after/:"
  c="$(at .harness/serve 19067 "$R_RUN") --tiffinbox.shutdown-token $CAN"; fails "$c"
  echo "  the canary: in the command above $(printf '%s\n' "$c" | LC_ALL=C grep -oF -- "$CAN" | wc -l | tr -d ' ') · in its log (standard output and error) $(raw "$CAN" .harness/fail.out .harness/fail.err)"
  now 19067; }

# ---- codes: the exit codes, each measured ----------------------------------------------------------------------------------------
codes() { local e0 e1 e2 e3 e9 e=0
  echo "0 - after/, the README's run line, port 19068; POST /shutdown is the seventh request:"
  start "$(at .harness/serve 19068 "$R_RUN")"; up; ready 19068
  seven 19068 .harness/serve; e0=$LASTE
  echo "1 - a failed start: the same line while the first one holds the port (the failure lesson's analysis):"
  start "$(at .harness/serve 19068 "$R_RUN")"; up; ready 19068
  fails "$(at .harness/serve 19068 "$R_RUN")"; e1=$LASTE
  seven 19068 .harness/serve
  echo "2 - a bare argument: the README's run line and a bare 19062:"
  fails "$(at .harness/serve 19068 "$R_RUN") 19062"; e2=$LASTE
  echo "3 - the harness's Report, options only, --probe.exit=3: SpringApplication.exit with a generator that returns 3:"
  quits "$(hcp .harness/serve 19068 probe.cli.Report '--probe.exit=3')"; e3=$LASTE
  echo "143 - SIGTERM: the README's run line, then kill:"
  start "$(at .harness/serve 19068 "$R_RUN")"; up; ready 19068
  echo "\$ kill \$pid    # SIGTERM, to the JVM this script started"
  kill "$pid"; wait "$pid" || e=$?; pid=""; e9=$e
  echo "  exit $e"; now 19068; logtok
  echo "the five, as measured above: POST /shutdown $e0 · a failed start $e1 · a bare argument $e2 · SpringApplication.exit $e3 · SIGTERM $e9"; }

# ---- banner: the README's banner file; the jar, the folders, Boot's own banner, banner-mode off ---------------------------------------
# blines LOG: the banner as printed - the lines before Boot's first log line - its non-blank lines, and Boot's own banner's line counted
blines() { awk '/^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T/ { exit } NF { n++; if ($0 ~ /^title=/) print "  the banner: " $0 } END { print "  lines before Boot'"'"'s first log line, not blank: " n + 0 }' "$1"
  echo "  the banner's :: Spring Boot :: line: $(grep -c ':: Spring Boot ::' "$1" || true)"; }
banner() { local c
  echo "after/'s folder (.harness/serve), the README's banner file:"
  echo "\$ cd .harness/serve && $R_BFILE"; (cd .harness/serve && eval "$R_BFILE")
  echo "  $(cat .harness/serve/banner.txt)"
  echo "the jar - the README's banner line, port 19069:"
  start "$(at .harness/serve 19069 "$R_BJAR")"; up; ready 19069; seven 19069 .harness/serve; blines .harness/run.out
  echo "  where the jar's title and version are written - its manifest, read with unzip (the two lines):"
  echo "\$ cd .harness/serve && unzip -p tiffinbox-web/target/tiffinbox-web-1.0.0.jar META-INF/MANIFEST.MF | grep -E '^Implementation-(Title|Version):'"
  (cd .harness/serve && unzip -p tiffinbox-web/target/tiffinbox-web-1.0.0.jar META-INF/MANIFEST.MF) | tr -d '\r' | grep -E '^Implementation-(Title|Version):' | sed 's/^/  /'
  echo "  the folders' manifest: tiffinbox-web/target/classes/META-INF/MANIFEST.MF $([ -e .harness/serve/tiffinbox-web/target/classes/META-INF/MANIFEST.MF ] && echo exists || echo 'does not exist')"
  echo "the folders - the README's class-path line (the build wrote tiffinbox-web/target/classpath.txt):"
  start "$(at .harness/serve 19069 "$R_BDIR")"; up; ready 19069; seven 19069 .harness/serve; blines .harness/run.out
  echo "the jar with Boot's own banner - the README's run line:"
  start "$(at .harness/serve 19069 "$R_RUN")"; up; ready 19069; seven 19069 .harness/serve; blines .harness/run.out
  echo "the jar, banner-mode off - the README's line:"
  start "$(at .harness/serve 19069 "$R_BOFF")"; up; ready 19069; seven 19069 .harness/serve; blines .harness/run.out
  rm -f .harness/serve/banner.txt; }

# ---- native: after/, built natively; the AOT jar and the binary ---------------------------------------------------------------------
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
# against the bound (1 minute or more, under 20 minutes), and the network (offline: nbuild stopped the run if the plugin went out)
nresult() { echo "  exit $NB_E · $(grep -m1 -oE 'BUILD (SUCCESS|FAILURE)' "$1" || echo 'no BUILD line') · stages it printed: $(grep -cE '^\[[1-8]/8\] ' "$1" || true) of the $(grep -m1 -oE '^\[1/[0-9]+\]' "$1" | sed 's/.*\///; s/]//') it announces · its duration, against the bound: $( [ $NB_S -ge 60 ] && echo '1 minute or more' || echo 'under 1 minute' ), $( [ $NB_S -lt 1200 ] && echo 'under 20 minutes' || echo '20 minutes or more' ) · offline: yes"; }
native() {
  echo "after/, copied to .harness/nat with a config tree; the README's two Maven lines, offline; \$GRAALVM_HOME names the GraalVM:"
  copy after .harness/nat
  nbuild .harness/nat
  nlines .harness/nat.native.log
  nresult .harness/nat.native.log
  echo "  file: $(file -b ".harness/nat/$BIN" | sed 's/ [A-Za-z0-9_]*$//') · the demo token in its bytes: $(raw "$TOKEN" ".harness/nat/$BIN")"
  echo "what Spring's AOT step wrote for the binary - .harness/nat's reachability-metadata.json (process-aot), through a filter:"
  aotmeta ".harness/nat/$AOTMETA"
  echo "the AOT jar - the README's AOT line, port 19069, and a bare 19062:"
  fails "$(at .harness/nat 19069 "$R_AOTRUN") 19062"
  now 19069 19062
  echo "the AOT jar - the README's AOT line, as written:"
  start "$(at .harness/nat 19069 "$R_AOTRUN")"; up; ready 19069; seven 19069 .harness/nat
  echo "the binary - the README's line, port 19069, and a bare 19062:"
  fails "$(at .harness/nat 19069 "$R_BIN") 19062"
  now 19069 19062
  echo "the binary - the README's banner line, the README's banner file written beside it:"
  echo "\$ cd .harness/nat && $R_BFILE"; (cd .harness/nat && eval "$R_BFILE")
  start "$(at .harness/nat 19069 "$R_BBIN")"; up; ready 19069; seven 19069 .harness/nat all; blines .harness/run.out; }

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
  echo "  exit $ec · listening on 19069 now: $(listeners 19069)"
  tok=$(head -1 .harness/mine/after/$TF)
  echo "  its logs (.harness/mine/after/jar.log, folders.log): its own token $(raw "$tok" .harness/mine/after/jar.log .harness/mine/after/folders.log) times · X-Shutdown-Token $(cat .harness/mine/after/jar.log .harness/mine/after/folders.log | LC_ALL=C grep -aoi -- 'x-shutdown-token' | wc -l | tr -d ' ') times"; }

cap bare bare
cap refuse refuse
cap args args
cap order order
cap change change
cap late late
cap dashd dashd
cap canary canary
cap codes codes
cap banner banner
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
# has 'TEXT' 'LINE' MESSAGE: TEXT (a variable holding a capture's block) holds the line, whole
has() { printf '%s\n' "$1" | grep -qxF -- "$2" || die "$3: expected the line: $2"; }
S115='115c36bac276128e245ca57df11c2891'
SEVEN="  exit 0 · the seven responses: 7 lines · md5 $S115"
LOGOK="  its log: the demo token 0 times · X-Shutdown-Token 0 times"
ERR0="  its standard error: 0 lines · the demo token in its log: 0"
NOTRACE="  its log, read after it exited: APPLICATION FAILED TO START 1 · stack frames 0 · Caused by: 0 · frames folded as common 0"
NOSTART="  its log: the banner's :: Spring Boot :: line 0 · TiffinBox listening 0"
DESC="  TiffinBox reads no bare arguments: "
# refused 'TEXT' WHAT: a block that holds the refusal - exit 2, the analysis and no frame, no banner, no listening line, no token
refused() { has "$1" "  exit 2" "$2: exit 2"; has "$1" "$NOTRACE" "$2: two sentences, no frame"; has "$1" "$NOSTART" "$2: before the banner, never listened"
  has "$1" "  ERROR o.s.b.d.LoggingFailureAnalysisReporter:" "$2: Boot's reporter"; has "$1" "$ERR0" "$2: no token"
  [ "$(printf '%s\n' "$1" | grep -c 'Application run failed')" = 0 ] || die "$2: no trace"; }
# THE TOKEN: no capture holds the demo token, raw - counted on each run's own output BEFORE masking - and neither does any failed
# start's log (ended() died on one), any served run's log (seven() and ends() counted each, with the header's name and the canary),
# anything this unit ships for reading, nor the binary this run built
for f in .harness/raw-*; do [ "$(cat "$f")" = 0 ] || die "a capture's raw output held the demo token ($f)"; done
NBIN=0
for f in .r-*.out README.md exercise/README.md exercise/solution/SOLUTION.md receipts.md5 harness/shutdown.sh harness/seven.sh harness/probe/cli/*.java harness/probe/sources.properties harness/order/META-INF/spring.factories after/README.md "after/$GUARD" "after/$ANA" "after/$FAC" "after/$APP" .harness/nat/$BIN; do
  [ -f "$f" ] || continue; case $f in .harness/nat*) NBIN=$((NBIN + 1)) ;; esac
  [ "$(raw "$TOKEN" "$f")" = 0 ] || die "$f holds the demo token, raw"; done
[ "$NBIN" = 1 ] || [ $GOK = no ] || die "one binary was built, $NBIN were checked"
# THE CANARY: in the captures only where the command that carried it is printed (canary's two "$" lines), never in a log line
[ "$(cat .r-*.out | grep -F -- "$CAN" | grep -vc '^\$ ' || true)" = 0 ] || die "the canary reached a capture outside its command line"
for f in .r-*.out; do ! grep -qE '/Users/|/private/|/home/|/var/folders/' "$f" || die "$f holds an absolute path"; [ -z "${GRAALVM_HOME:-}" ] || ! grep -qF "$GRAALVM_HOME" "$f" || die "$f holds the GraalVM's folder"; ! grep -qE 'c[0-9]-unit[0-9]|unit ?[0-9]' "$f" || die "$f holds a unit number"; ! grep -qE ' (with PID|started by) ' "$f" || die "$f holds Boot's process line"; ! grep -qE '^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T|virtual-[0-9]' "$f" || die "$f holds a log line's time or a thread's number"; ! grep -q "^$(printf '\t')at " "$f" || die "$f shows a stack frame"; done
NX=$(n exercise '^  its logs \(\.harness/mine/after/jar\.log, folders\.log\): its own token 0 times · X-Shutdown-Token 0 times$'); [ "$NX" = 1 ] || die "exercise: its logs, its own token and the header"
NF=$(cat .r-*.out | grep -cxF "$ERR0" || true); NL=$(cat .r-*.out | grep -cxF "$LOGOK" || true)
echo "  token: 0 raw copies in $(ls .harness/raw-* | wc -l | tr -d ' ') raw capture runs, in $(ls .r-*.out | wc -l | tr -d ' ') captures, in the logs of every start that ended by itself ($FLOGS counted here, the published captures' $NF failed starts each with 0), in the logs of every run that served ($LOGS counted here, the published captures' $NL each with 0 tokens and 0 header names), the READMEs, the harness, the exercise, receipts.md5 and the binary; the canary only in its two command lines; no absolute path, no GraalVM folder, no unit number, no process line, no log time, no thread number, no stack frame in any capture"

# "Type the port the way Courses two to four did: java, the jar, then the number. TiffinBox starts, serves the same seven answers -
# on the variable's port. The number you typed has no listener."
x bare '^\$ cd \.harness/prev && TIFFINBOX_PORT=19061 java -jar tiffinbox-web/target/tiffinbox-web-1\.0\.0\.jar 19062$'
x bare '^  listens on: 127\.0\.0\.1:19061$'; x bare '^  listening on 19062: 0$'; x bare "^$SEVEN\$"
echo "  bare: the previous tree, TIFFINBOX_PORT=19061 and a bare 19062 - listens on 19061 only, 19062 has no listener, 115c36ba..."

# "Boot hands a runner the start's arguments, parsed: the options, by name - each one also a property - and the rest, the
# non-option arguments, which nothing in TiffinBox reads. Ten days became forty orders; nineteen-oh-six-two went nowhere."
G1=$(blk args 'the harness' 'after/ - the same runner'); G2=$(blk args 'after/ - the same runner' '')
has "$G1" "  harness: option names [spring.main.sources, tiffinbox.days, tiffinbox.port] · non-option arguments [19062] · tiffinbox.days [10] · source arguments 4" "args: what the runner got"
has "$G1" '  {"ordersCooked":40,"ordersValue":8100} 200' "args: the option became a property"; has "$G1" "  listening on 19062: 0" "args: the bare number, nowhere"
has "$G2" "  exit 3" "args: exit 3"; has "$G2" "  harness: SpringApplication.exit returned 3" "args: the generator's code"; has "$G2" "  its log: the banner's :: Spring Boot :: line 1 · TiffinBox listening 1" "args: a runner runs after the port opened"
printf '%s\n' "$G2" | grep -qF 'non-option arguments [] ·' || die "args: after/, options only"
echo "  args: option names, non-option [19062], tiffinbox.days [10], 4 arguments; /kitchen 40 orders; after/: exit 3 via SpringApplication.exit"

# "environment, banner, context, refresh - where TiffinBox's port opens - then the runners, and only then ready"
O=$(blk order 'the start, read from its output' '')
[ "$(printf '%s\n' "$O" | sed 's/^  [0-9]* //' | paste -sd'|' -)" = "hook: ApplicationStartingEvent|hook: ApplicationEnvironmentPreparedEvent|the banner|hook: ApplicationContextInitializedEvent|hook: ApplicationPreparedEvent|TiffinBox listening - its @PostConstruct, in the refresh|hook: ContextRefreshedEvent|Boot's Started line|hook: ApplicationStartedEvent|hook: AvailabilityChangeEvent CORRECT|the runner (the harness's Report)|hook: ApplicationReadyEvent|hook: AvailabilityChangeEvent ACCEPTING_TRAFFIC|hook: ContextClosedEvent" ] || die "order: the hooks, in order"
[ "$(printf '%s\n' "$O" | awk '{ print $1 }' | paste -sd' ' -)" = "1 2 3 4 5 6 7 8 9 10 11 12 13 14" ] || die "order: fourteen marks, numbered"
x order "^$SEVEN\$"
echo "  order: starting, environment prepared, the banner, context initialized, prepared, TiffinBox listening, refreshed, started, live, the runner, ready, accepting traffic, closed"

# "the guard: one listener, about forty lines with its exception; its analyzer: one method; one key added to spring factories;
# and one sentence in TiffinBoxApp's Javadoc, measured: the file ranks nine of nine, nine of ten with default properties"
[ "$(n change '^  (Files|Only in) ')" = 5 ] || die "change: five paths"
x change '^  tiffinbox-web/src/main/java/com/tiffinbox/web/BareArgumentGuard\.java - new; its lines that are neither comment nor blank: 57$'
x change '^  tiffinbox-web/src/main/java/com/tiffinbox/web/BareArgumentAnalyzer\.java - new; its lines that are neither comment nor blank: 9$'
for t in '    class BareArgumentGuard implements ApplicationListener<ApplicationEnvironmentPreparedEvent> {' \
  '            List<String> bare = new DefaultApplicationArguments(event.getArgs()).getNonOptionArgs();' \
  '        static final class BareArguments extends RuntimeException implements ExitCodeGenerator {' \
  '                    if (a.matches("[0-9]{1,5}")) {' '                    } else if (a.startsWith("-D")) {' \
  '                        found.add(at + " (not shown)");' '                return 2;' \
  '    class BareArgumentAnalyzer extends AbstractFailureAnalyzer<BareArgumentGuard.BareArguments> {'; do grep -qxF -- "$t" .r-change.out || die "change: $t"; done
[ "$(grep -c 'found.add(at + " is " + a)' .r-change.out)" = 1 ] || die "change: a bare argument printed in one branch only, the number's"
x change '^    after  org\.springframework\.context\.ApplicationListener=com\.tiffinbox\.web\.BareArgumentGuard$'
x change '^    after  org\.springframework\.boot\.diagnostics\.FailureAnalyzer=com\.tiffinbox\.web\.PortTakenFailureAnalyzer,com\.tiffinbox\.web\.BareArgumentAnalyzer$'
[ "$(n change '^    (before|after ) ')" = 3 ] || die "change: one key before, two after"
x change '^    @@ -18,2 \+18,2 @@$'; [ "$(n change '^    [-+] \* ')" = 4 ] || die "change: TiffinBoxApp, two lines out, two in"
x change '^    \+ \* later, during refresh: it ranks below every source Boot adds but one - default properties, set in code, which Boot$'
x change "^  tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxApp\.java - its lines that are neither comment nor blank, against the previous tree's: the same\$"
x change '^  harness: the @PropertySource file ranks 9 of 9 · probe\.key = from the @PropertySource file$'
x change '^  harness: the @PropertySource file ranks 9 of 10 · probe\.key = from the @PropertySource file$'
x change '^  harness: default properties set · sources 10: .* · 9 class path resource \[probe/sources\.properties\] · 10 defaultProperties$'
x change '^  tiffinbox-core against the previous tree.s \(diff -rq -x target\): 0 files differ$'
for t in TiffinBoxServer.java PortTakenFailureAnalyzer.java ActuatorRoutes.java KitchenHealthIndicator.java KitchenMetrics.java Route.java tiffinbox-web/src/main/resources/application.yaml tiffinbox-web/pom.xml pom.xml; do x change "^  $t against the previous tree.s, byte for byte: the same\$"; done
[ "$(diff -rq -x target -x secrets "$PREV" after | wc -l | tr -d ' ')" = 5 ] || die "change: after/ differs from the previous tree in more than the README, TiffinBoxApp, the factories file and the two classes"
echo "  change: 5 paths · the guard 57 code lines, the analyzer 9 · spring.factories 1 key -> 2 · TiffinBoxApp: one Javadoc sentence, code the same · the file 9 of 9, 9 of 10 with default properties · the rest the same"

# "A: the port as an option, the seven. B: the old command, refused - exit two, no banner, nothing listening, no stack trace, two
# sentences. A again: the seven."
RA=$(blk refuse 'A - after/' 'B - after/'); RB=$(blk refuse 'B - after/' "A' - A again"); RA2=$(blk refuse "A' - A again" '')
has "$RA" "$SEVEN" "refuse A: the seven"; has "$RA2" "$SEVEN" "refuse A': the seven"
[ "$(printf '%s\n' "$RA" | grep '^\$ cd .harness/serve && java')" = "$(printf '%s\n' "$RA2" | grep '^\$ cd .harness/serve && java')" ] || die "refuse: A' is not A's command"
refused "$RB" "refuse B"; has "$RB" "${DESC}argument 1 of 1 is 19062." "refuse B: the description"; has "$RB" "  To set the port, give it as an option: --tiffinbox.port=19062." "refuse B: the action"
has "$RB" "  listening now: 19061 0 · 19062 0" "refuse B: neither port"
echo "  refuse: A 115c36ba... · B exit 2, 0 frames, 0 banner, 0 listening, argument 1 of 1 is 19062, --tiffinbox.port=19062 · A' 115c36ba..."

# "the same check as a runner: exit two - after TiffinBox listened, twenty-one frames, no explanation. On the new tree the listener
# refuses first, and the runner never runs."
L1=$(blk late 'C (labelled)' 'the same runner joined'); L2=$(blk late 'the same runner joined' '')
has "$L1" "  exit 2" "late: exit 2"; has "$L1" "  its log, read after it exited: APPLICATION FAILED TO START 0 · stack frames 21 = 21 · Caused by: 0 · frames folded as common 0" "late: 21 frames, no analysis"
has "$L1" "  its log: the banner's :: Spring Boot :: line 1 · TiffinBox listening 1" "late: it listened"; has "$L1" "  in its log, TiffinBox's listening line comes before Boot's Application run failed: yes" "late: listened first"
has "$L1" '  probe.cli.LateGuard$Refused: a runner refused 1 bare argument(s)' "late: the runner's refusal"
refused "$L2" "late on after/"; has "$L2" "${DESC}argument 3 of 3 is 19062." "late on after/: the anchor's guard"
echo "  late: the runner - exit 2 after TiffinBox listened, 21 frames, no analysis · on after/: the guard first, 0 frames"

# "a -D after the jar: before, a hundred and twenty orders, silently; now exit two, and the action says Java's -D options go before
# -jar - and there, forty"
D1=$(blk dashd 'D (labelled)' 'after/ - the same line'); D2=$(blk dashd 'after/ - the same line' "after/ - the README's line with"); D3=$(blk dashd "after/ - the README's line with" '')
has "$D1" '  {"ordersCooked":120,"ordersValue":24300} 200' "dashd: 120, silently"; has "$D1" "  its log: orders cooked:  120" "dashd: the log says 120"
refused "$D2" "dashd after/"; has "$D2" "${DESC}argument 2 of 2 starts with -D (not shown)." "dashd: placed, not shown"
has "$D2" "  Java's -D options go before -jar; after it, give a setting as --name=value." "dashd: the action"
[ "$(printf '%s\n' "$D2" | grep -c 'tiffinbox.days')" = 1 ] || die "dashd: the -D printed only in the command"
has "$D3" '  {"ordersCooked":40,"ordersValue":8100} 200' "dashd: 40 with -D before -jar"; has "$D3" "  its log: orders cooked:  40" "dashd: the log says 40"
echo "  dashd: the previous tree 120 silently · after/ exit 2, argument 2 of 2 starts with -D, not shown · -D before -jar: 40"

# (receipt only, a chip) "a value typed after a space is a bare argument - never printed: the canary 0 times in either log"
E1=$(blk canary 'E (labelled)' 'after/:'); E2=$(blk canary 'after/:' '')
has "$E1" "  exit 1" "canary before: exit 1"; has "$E1" '      Value: ""' "canary before: Boot binds an empty token"
has "$E1" "  the canary: in the command above 1 · in its log (standard output and error) 0" "canary before: counted, 0"
refused "$E2" "canary after/"; has "$E2" "${DESC}argument 3 of 3 (not shown)." "canary after/: placed, not shown"; has "$E2" "  Give a setting as --name=value, in one argument." "canary after/: the action"
has "$E2" "  the canary: in the command above 1 · in its log (standard output and error) 0" "canary after/: counted, 0"
echo "  canary: the previous tree exit 1 (an empty token), after/ exit 2 (argument 3 of 3, not shown); the canary 1 in each command, 0 in each log"

# "zero after POST shutdown, one for a failed start, two for a bare argument, three from a runner's exit, a hundred and
# forty-three for SIGTERM"
x codes '^the five, as measured above: POST /shutdown 0 · a failed start 1 · a bare argument 2 · SpringApplication\.exit 3 · SIGTERM 143$'
x codes '^  exit 143$'; x codes '^  harness: SpringApplication\.exit returned 3$'; [ "$(n codes '^  exit 2$')" = 1 ] && [ "$(n codes '^  exit 1$')" = 1 ] && [ "$(n codes '^  exit 3$')" = 1 ] || die "codes: one of each"
x codes '^  TiffinBox could not listen on 127\.0\.0\.1:19068: something else already listens there\.$'
echo "  codes: 0 · 1 · 2 · 3 · 143, each from its own run"

# "the jar prints TiffinBox Web, version one point oh point oh; from the folders, empty brackets; Boot's version prints in both.
# banner-mode off: none."
B1=$(blk banner 'the jar - the README' 'the folders'); B2=$(blk banner 'the folders' "the jar with Boot's own"); B3=$(blk banner "the jar with Boot's own" 'the jar, banner-mode off'); B4=$(blk banner 'the jar, banner-mode off' '')
has "$B1" "  the banner: title=[TiffinBox Web] version=[1.0.0] boot=[4.1.1]" "banner: the jar"; has "$B2" "  the banner: title=[] version=[] boot=[4.1.1]" "banner: the folders"
has "$B2" "  Boot's first line: Starting TiffinBoxServer using Java 25.0.4.1" "banner: the folders' first line has no version"
has "$B1" "  Implementation-Title: TiffinBox Web" "banner: the manifest's title"; has "$B1" "  Implementation-Version: 1.0.0" "banner: the manifest's version"
has "$B1" "  the folders' manifest: tiffinbox-web/target/classes/META-INF/MANIFEST.MF does not exist" "banner: no manifest in the folders"
has "$B3" "  the banner's :: Spring Boot :: line: 1" "banner: Boot's own"; has "$B4" "  lines before Boot's first log line, not blank: 0" "banner: off"; has "$B4" "  the banner's :: Spring Boot :: line: 0" "banner: off, none"
for b in "$B1" "$B2" "$B3" "$B4"; do has "$b" "$SEVEN" "banner: the seven"; done
echo "  banner: the jar title=[TiffinBox Web] version=[1.0.0] boot=[4.1.1] · the folders title=[] version=[] boot=[4.1.1] · Boot's own 1 · off 0"

# "In the AOT jar and in the native binary the same refusal, before any port; without the argument, the seven. The binary's
# banner: empty brackets." The AOT step registered the listener as it registers an analyzer.
if [ $GOK = yes ]; then
  x native '^  exit 0 · BUILD SUCCESS · stages it printed: 8 of the 8 it announces · its duration, against the bound: 1 minute or more, under 20 minutes · offline: yes$'
  x native '^  file: Mach-O 64-bit executable · the demo token in its bytes: 0$'; x native '^  the resource META-INF/spring\.factories: yes$'
  for t in BareArgumentGuard BareArgumentAnalyzer PortTakenFailureAnalyzer; do x native "^  reflection entries for com\\.tiffinbox\\.web\\.$t: 1 · allDeclaredConstructors\$"; done
  V1=$(blk native "the AOT jar - the README's AOT line, port" "the AOT jar - the README's AOT line, as"); V2=$(blk native "the AOT jar - the README's AOT line, as" "the binary - the README's line, port"); V3=$(blk native "the binary - the README's line, port" "the binary - the README's banner"); V4=$(blk native "the binary - the README's banner" '')
  for b in "$V1" "$V3"; do refused "$b" "native"; has "$b" "${DESC}argument 2 of 2 is 19062." "native: the description"; has "$b" "  listening now: 19069 0 · 19062 0" "native: never bound"; done
  has "$V2" "$SEVEN" "native: the AOT jar serves"; has "$V2" "  Boot's first line: Starting AOT-processed TiffinBoxServer v1.0.0 using Java 25.0.4.1" "native: AOT-processed"
  has "$V4" "$SEVEN" "native: the binary serves"; has "$V4" "  the banner: title=[] version=[] boot=[4.1.1]" "native: the binary's banner"
  echo "  native: 8 of 8, offline, Mach-O, 0 tokens · the AOT step registered the guard, its analyzer and spring.factories · AOT jar and binary: exit 2, never bound; then the seven · the binary's banner title=[] version=[] boot=[4.1.1]"
fi

# the exercise's end state: the line exercise/README.md calls "Done" is a line of this capture, after the solution's line - and of
# SOLUTION.md's measured run
XE=$(blk exercise "the solution's line" '')
l="the jar: TiffinBox version=[1.0.0] · the folders: TiffinBox version=[]"
has "$XE" "$l" "exercise"
awk '/^\*\*Done\*\*/ { f = 1 } f' exercise/README.md | grep -qxF -- "$l" || die "exercise/README.md: Done names no such line"
grep -qxF -- "$l" exercise/solution/SOLUTION.md || die "SOLUTION.md: the measured run shows no such line"
x exercise '^  exit 0 · printed: 0 line\(s\)$'; x exercise '^  exit 0 · listening on 19069 now: 0$'
echo "  exercise: the README as written, then the solution's line -> the jar version=[1.0.0], the folders version=[]"

# the anchor's README states the same numbers
for t in 'TiffinBox reads no bare' 'To set the port, give it as an option: --tiffinbox.port=18431.' '`{"ordersCooked":40,"ordersValue":8100} 200`' '`argument 2 of 2 starts with -D (not shown)`' 'cooked 120 orders, not 40' '`143` SIGTERM' 'The jar: `title=[TiffinBox Web] version=[1.0.0] boot=[4.1.1]`; the folders: `title=[] version=[] boot=[4.1.1]`; the native' 'binary: `title=[] version=[] boot=[4.1.1]`' '9 of 9' '9 of 10'; do
  grep -qF -- "$t" after/README.md || die "after/README.md no longer states: $t"; done
cmp -s after/README.md ../c5-tiffinbox/README.md || echo "  (after/README.md and ../c5-tiffinbox/README.md differ - the anchor has moved past this unit's after/, or is not it yet)" >&3
[ -z "$unpub" ] || die "no published hash for:$unpub - check the captures, then copy the md5s above into receipts.md5 and run again"
echo "c5-unit27: every capture 3/3 and = published; every spoken number asserted; 0 raw demo tokens and 0 canaries in every capture's logs, every failed start's report and every run's log"
