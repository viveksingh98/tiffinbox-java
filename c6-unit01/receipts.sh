#!/bin/bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25.0.4.1 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# Course 6 · What Happens Between curl and Your Method - this unit's receipts, the course's first. The last course ended with
# TiffinBox answering HTTP through a server of its own (the JDK's, with the router Core Java II wrote) and Spring's routing table
# empty. This unit puts Spring MVC beside it, on a COPY, and asks both servers one question: who called your method? No anchor
# change: the tree is ../c5-unit27/after, reached through the link `anchor` (= ../c5-tiffinbox, checked), read and copied under
# .harness/, never built in place. The copy is the anchor with ONE dependency line added to the web module's POM and the Boot
# plugin's two Jackson 3 excludes dropped - that file, whole, is mvc/tiffinbox-web/pom.xml. No native build, no Docker, no
# GraalVM. Five captures, each run three times and hashed; cap() DIES when a hash differs from receipts.md5; every number the
# video says is asserted at the bottom by a check that can fail; the demo token is masked (gsub), and the checks count 0 raw
# copies of it in every capture, in the log of every JVM, and in every file this unit ships.
#   before    where the last course left it: the anchor alone (the README's run line) - its one listener, the seven, exit 0;
#             then the copy - the POM's diff, the jars each executable jar carries, the copy's run line: two servers in one JVM,
#             each named by its port and its own log line, both addresses read off the process; the seven on TiffinBox's port;
#             after POST /shutdown TiffinBox's port is closed and the JVM lives on, so it is stopped by its process id
#   toy       the toy path: a copy of the copy with ONE line added to TiffinBox's customers() (its diff -U0 hunk first) that
#             prints the frames the stack walker shows when -Dprobe.stack=true; GET /customers on TiffinBox's own port - the
#             frames, grouped by the declared filter; then C (labelled): GET /nowhere on TiffinBox's own port
#   path      the industrial path: the harness's @RestController (probe.path.Stack, outside com.tiffinbox) on Tomcat's port
#             returns its own stack - the thread, the frames, grouped bottom to top by the declared filter
#   log       the path in Spring's own words - the anchor README's web line (Boot's log group web at DEBUG) on the copy: A GET
#             /probe/stack · B GET /nowhere, a path nobody declared · A' = A, its $ command shown - each with the lines it
#             added at DEBUG
#   exercise  exercise/README.md's commands, exactly as written (the misspelt option), then exercise/solution/SOLUTION.md's
#             line, then the README's run line again (A')
# Commands are printed exactly as they run: each goes through eval. "$CURLSET" is the comparison set since the last course's
# secrets lesson (../c5-unit11/curlset.sh: the seven requests, POST /shutdown with the token's header read from the file). "$M2"
# is this unit's own repository, .m2-demo. "$pid" is the JVM's process id, as the shell that started it knows it (never printed).
# The harness is harness/probe/path/Stack.java, compiled into .harness/hc against the copy's own extracted jar. Every run passes
# options only (the anchor's guard refuses a bare argument).
# The network: every Maven build runs offline (-o) against .m2-demo and says so ("offline: yes"); a build that cannot resolve an
# artifact offline goes to Maven Central once, and says that ("offline: no - ..."); every build's log is searched for the native
# plugin's two metadata-download lines too (no build here runs the profile native). At run time nothing leaves 127.0.0.1: both
# servers listen there (Tomcat only because every run passes --server.address=127.0.0.1: without it, it binds every interface),
# every request goes there, and Logback writes to the terminal only.
# Masks and filters (README.md declares each; gsub, and the user name by index() as a whole word): the demo token becomes
# "[masked: the N-character token]", N its own length; this folder's absolute path "…", the folder above it "…/..", the home
# folder "~"; a Tomcat request thread's number "exec-N" / "tomcat-handler-N"; an identity hash "@<hash>"; Spring's error timestamp
# - in its JSON (an ISO-8601 string, or epoch milliseconds) and in its DEBUG line (a date) - "<masked: ...>" naming the form; last,
# your user name "<user>". A log line is printed
# from its logger on (its time, level, process id and thread cut). Frames are grouped by GROUPAWK below (README.md, Filters).
# No duration is captured.
# Ports (brief ⚑1, 19300-19309): before 19300 (the anchor alone, then the copy's TiffinBox) and 19301 (the copy's Tomcat) · toy
# 19302 / 19303 · path 19304 / 19305 · log 19306 / 19307 · the exercise 19308 / 19309 (TiffinBox's / Tomcat's). 18425
# (TiffinBox's default) and 8080 (Tomcat's) are checked free too, and never bound.
set -e
# bash 5.2 and later turn an & in the replacement of ${x/pattern/replacement} into the matched text (patsub_replacement, on by
# default). Switched off, so /bin/bash 3.2 (./receipts.sh) and a newer bash (bash receipts.sh) run the same commands; 3.2 has no
# such option.
shopt -u patsub_replacement 2> /dev/null || true
cd "$(dirname "$0")"
# One run at a time: two runs share .harness/ and the ports, and one would corrupt the other.
mkdir .r-lock 2> /dev/null || { echo "  *** another receipts.sh is running in this folder (.r-lock exists) - if none is, rmdir .r-lock ***"; exit 1; }
# On every exit - the end, a failed check, or Ctrl-C - stop the JVM this script started in the background ($pid), if it still
# runs, then sweep(): anything of this run still alive in its process group - a TiffinBox JVM (the exercise's own included), a
# Maven build - is stopped. After an interrupt, a capture's unfinished runs (.r-NAME.1-3) go too; after a failed check they stay,
# for the diff the message names. The clean-up ignores a second Ctrl-C, and nothing in it can fail under set -e, so it always
# reaches the rmdir; the script still exits 130 after an interrupt (README.md, "Interrupted").
pid=""
sweep() { local g i l
  g=$(ps -o pgid= -p $$ 2> /dev/null | tr -d ' ') || g=""
  [ -n "$g" ] || return 0
  i=0; while [ $i -lt 20 ]; do
    l=$(ps -axo pid=,pgid=,command= 2> /dev/null | awk -v g="$g" -v me=$$ '
      $2 == g && $1 != me && $3 != "awk" && $3 != "ps" && (index($0, "tiffinbox-web-1.0.0.jar") || index($0, "com.tiffinbox.web.TiffinBoxServer") || index($0, "plexus-classworlds")) { print $1 }' | paste -sd' ' -) || l=""
    [ -n "$l" ] || return 0
    if [ $i -lt 10 ]; then kill $l 2> /dev/null || true; else kill -9 $l 2> /dev/null || true; fi
    sleep 0.5; i=$((i + 1)); done; }
trap 'trap "" INT TERM; if [ -n "$pid" ] && kill "$pid" 2> /dev/null; then wait "$pid" 2> /dev/null || true; fi; sweep || true; [ -z "$INTR" ] || rm -f .r-*.[123]; rmdir .r-lock 2> /dev/null || true' EXIT
INTR=""; trap 'INTR=1; exit 130' INT TERM
exec 3>&1                                            # die() speaks to the terminal even inside a redirected capture
die() { echo "  *** $* ***" >&3; exit 1; }
java -version 2>&1 | grep -q 'version "25' || die "JDK 25 needed; JAVA_HOME gives: $(java -version 2>&1 | head -1)"
for t in curl rsync lsof md5 javac jar seq; do command -v $t > /dev/null || die "$t is needed here"; done
# A variable of yours must not become a property source, a JVM flag or a build setting: every TIFFINBOX_*, SPRING_*, MANAGEMENT_*,
# SERVER_* and LOGGING_* variable, DEBUG (Boot reads it as --debug), the variables that inject JVM flags, MAVEN_OPTS, MAVEN_ARGS and
# NATIVE_IMAGE_OPTIONS are removed first (the last course's loop, verbatim: sed -E, a canary planted under every name first, and
# the run stops if one survives - RED C5-S4 #63). This unit runs no Docker, so COMPOSE_* is not in the list (brief S1.14).
for v in TIFFINBOX_CANARY SPRING_CANARY MANAGEMENT_CANARY SERVER_CANARY LOGGING_CANARY DEBUG JAVA_TOOL_OPTIONS JDK_JAVA_OPTIONS _JAVA_OPTIONS MAVEN_OPTS MAVEN_ARGS NATIVE_IMAGE_OPTIONS; do export "$v=planted-canary"; done
for v in $(env | sed -n -E 's/^(TIFFINBOX_[A-Za-z0-9_]*|SPRING_[A-Za-z0-9_]*|MANAGEMENT_[A-Za-z0-9_]*|SERVER_[A-Za-z0-9_]*|LOGGING_[A-Za-z0-9_]*|DEBUG|JAVA_TOOL_OPTIONS|JDK_JAVA_OPTIONS|_JAVA_OPTIONS|MAVEN_OPTS|MAVEN_ARGS|NATIVE_IMAGE_OPTIONS)=.*/\1/p'); do unset "$v"; done
[ -z "$(env | grep -- '=planted-canary$')" ] || die "a variable survived the clean-up above: $(env | grep -- '=planted-canary$' | sed 's/=.*//' | paste -sd' ' -)"
# Every request this script makes goes to 127.0.0.1: an HTTP proxy named in your environment would carry curl's requests to that
# proxy instead - 127.0.0.1 and localhost go first in no_proxy and NO_PROXY.
export no_proxy="127.0.0.1,localhost${no_proxy:+,$no_proxy}" NO_PROXY="127.0.0.1,localhost${NO_PROXY:+,$NO_PROXY}"
[ -e secrets ] && die "this folder holds a secrets/ - remove it: every run here starts in a folder under .harness/"
[ -L anchor ] && [ "$(readlink anchor)" = ../c5-unit27/after ] || die "anchor must be the link to ../c5-unit27/after - this unit changes nothing in the anchor"
[ -e anchor/secrets ] || [ -e anchor/tiffinbox-web/secrets ] || [ -e anchor/tiffinbox-local.yaml ] || [ -e anchor/target ] || [ -e anchor/tiffinbox-web/target ] || [ -e anchor/banner.txt ] && die "anchor/ (../c5-unit27/after) holds a secrets/, a tiffinbox-local.yaml, a banner.txt or a target/ - it is the anchor's frozen copy, never built in place; remove them"
M2="$PWD/.m2-demo"; U="$PWD"; UP="$(cd .. && pwd)"; ME="$(id -un)"
TF=secrets/tiffinbox/shutdown-token                  # the config tree's file for tiffinbox.shutdown-token
# The demo token. FAKE, and meant to look it: it guards nothing but a demo server on 127.0.0.1 that every capture stops. It is
# written into .harness/*/secrets/ (git-ignored) when this script runs, and no capture prints it: see mask().
TOKEN=not-a-real-token-demo-only
CURLSET=../c5-unit11/curlset.sh                      # the comparison set: the seven requests, POST /shutdown with the header
[ -f "$CURLSET" ] || die "$CURLSET is missing"
[ -f anchor/pom.xml ] && [ -f anchor/README.md ] || die "anchor/ (../c5-unit27/after) is missing"
for f in mvc/tiffinbox-web/pom.xml harness/probe/path/Stack.java README.md exercise/README.md exercise/solution/SOLUTION.md; do [ -f "$f" ] || die "$f is missing"; done
SRV=tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java
WPOM=tiffinbox-web/pom.xml

# The ports, BEFORE anything is wiped.
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
for p in 18425 8080 19300 19301 19302 19303 19304 19305 19306 19307 19308 19309; do
  [ "$(listeners $p)" = 0 ] || die "something already listens on $p - this unit's ports must be free; if it is a TiffinBox an interrupted run left behind, stop it: kill $(lsof -nP -iTCP:$p -sTCP:LISTEN -t 2> /dev/null | paste -sd' ' -)"; done

# ---- the commands: read from anchor/README.md (the anchor's own) and from this unit's README.md (the copy's options), and
# ---- asserted - each line must be there, whole
readme() { grep -m1 -xF -- "$1" anchor/README.md > /dev/null || die "anchor/README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
ours() { grep -m1 -xF -- "$1" README.md > /dev/null || die "README.md (this unit's) no longer gives the line: $1"; printf '%s\n' "$1"; }
R_PLAIN=$(readme 'mvn -B package')
R_RUN=$(readme 'java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431')
R_KDEBUG=$(readme 'java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --logging.level.kitchen=debug')
R_WEB=$(readme 'java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --logging.level.web=debug')
R_EXTRACT=$(readme 'java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted')
R_CP=$(readme 'java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431')
R_READY=$(readme "curl -s -w ' %{http_code}\n' http://127.0.0.1:18431/actuator/health/readiness")
# The copy's lines (this unit's README): each is an anchor line above with the copy's options added - Tomcat's address and port
# (Tomcat binds every interface without the address), and for the harness's runs its classes on the class path (../hc, beside
# the copy) and its class joined (--spring.main.sources). Each is asserted to be exactly that, so nothing else changed.
COPY='--server.address=127.0.0.1 --server.port=18432'
R_MRUN=$(ours "java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 $COPY")
R_TOY=$(ours "java -Dprobe.stack=true -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --logging.level.kitchen=debug $COPY")
R_HCP=$(ours "java -cp \"tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc\" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431 $COPY --spring.main.sources=probe.path.Stack")
R_HWEB=$(ours "java -cp \"tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc\" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431 --logging.level.web=debug $COPY --spring.main.sources=probe.path.Stack")
R_STACK=$(ours "curl -s http://127.0.0.1:18432/probe/stack")
R_ASK=$(ours "curl -s -o /dev/null -w '%{http_code} %{content_type}\n' http://127.0.0.1:18432/probe/stack")
R_NOWH=$(ours "curl -s -w ' %{http_code} %{content_type}\n' http://127.0.0.1:18432/nowhere")
R_TCUST=$(ours "curl -s -o /dev/null -w '%{http_code} %{content_type}\n' http://127.0.0.1:18431/customers")
R_TNOWH=$(ours "curl -s -w ' %{http_code} %{content_type}\n' http://127.0.0.1:18431/nowhere")
[ "$R_MRUN" = "$R_RUN $COPY" ] || die "the copy's run line: the README's run line and the copy's two options"
[ "$R_TOY" = "${R_KDEBUG/java -jar/java -Dprobe.stack=true -jar} $COPY" ] || die "the toy's line: the README's DEBUG line, the probe's switch and the copy's two options"
[ "$R_HCP" = "${R_CP/lib\/\*\"/lib/*:../hc\"} $COPY --spring.main.sources=probe.path.Stack" ] || die "the harness's line: the README's class-path line, the harness's classes, the copy's options, the harness joined"
[ "$R_HWEB" = "${R_HCP/--tiffinbox.port=18431 /--tiffinbox.port=18431 ${R_WEB##* } }" ] || die "the harness's web line: the harness's line and the README's web flag"
[ "${R_WEB##* }" = "--logging.level.web=debug" ] && [ "${R_KDEBUG##* }" = "--logging.level.kitchen=debug" ] || die "the README's two DEBUG flags"
# off DIR 'README mvn LINE': the README's Maven line as this script runs it - from DIR, offline (-o), this unit's own repository,
# clean and without tests. dev() takes those things back out, and must give the README's line again.
off() { local c=${2/mvn -B /mvn -o -B -Dmaven.repo.local=\"\$M2\" }; c=${c/ package/ -DskipTests clean package}; printf 'cd %s && %s\n' "$1" "$c"; }
dev() { local c=${1#cd * && }; c=${c/ -o -B -Dmaven.repo.local=\"\$M2\" / -B }; c=${c/ -DskipTests clean / }; printf '%s\n' "$c"; }
# at DIR TPORT CPORT 'LINE': the line run from DIR, TiffinBox's port 18431 made TPORT, Tomcat's 18432 made CPORT
at() { local c=${4/--tiffinbox.port=18431/--tiffinbox.port=$2}; c=${c/--server.port=18432/--server.port=$3}; printf 'cd %s && %s\n' "$1" "$c"; }
# url 'curl LINE' PORT: the curl line, its port (18431 or 18432) made PORT
url() { local c=${1/:18431\//:$2/}; printf '%s\n' "${c/:18432\//:$2/}"; }
# exe 'COMMAND': the command with "exec" after its "cd DIR && " - so $pid is the program's own
exe() { printf '%s\n' "$1" | sed -E 's/&& (([A-Z_]+=[^ ]* )*)/\&\& \1exec /'; }
[ "$(dev "$(off .harness/x "$R_PLAIN")")" = "$R_PLAIN" ] || die "not the README's build line with the offline changes"
[ "$(at .harness/x 19304 19305 "$R_HCP")" = 'cd .harness/x && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19304 --server.address=127.0.0.1 --server.port=19305 --spring.main.sources=probe.path.Stack' ] || die "at(), the harness's line"
[ "$(exe "$(at .harness/x 19300 19301 "$R_MRUN")")" = 'cd .harness/x && exec java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19300 --server.address=127.0.0.1 --server.port=19301' ] || die "exe()"
[ "$(url "$R_TNOWH" 19302)" = "curl -s -w ' %{http_code} %{content_type}\n' http://127.0.0.1:19302/nowhere" ] && [ "$(url "$R_NOWH" 19307)" = "curl -s -w ' %{http_code} %{content_type}\n' http://127.0.0.1:19307/nowhere" ] || die "url()"
echo "  the commands: anchor/README.md gives the 7 lines this script runs or derives from; README.md the copy's 10"

# ---- build: before the captures - the copy, the anchor, the toy; on a fresh clone (.m2-demo empty: git ignores it) the first
# ---- build fills .m2-demo, once. No capture builds anything but the exercise, whose README builds its own copy.
rm -rf .harness; mkdir -p .harness
# ghub LOG: the native plugin went over the network for its metadata repository. No build here runs the profile native, so its
# two download lines can never be there - and if one is, the run stops.
ghub() { grep -qE 'Downloaded GraalVM reachability metadata repository from http|Failed to download from http' "$1"; }
# mbuild 'COMMAND' LOG LABEL: the command, run as printed (eval), its log kept in LOG (never printed whole); Maven Central only if
# the offline build could not resolve something - and the line says which (offline: yes / no), so a run that went online is
# never silent.
mbuild() { local how=yes ec=0 c=$1
  (eval "$c") > "$2" 2>&1 < /dev/null || ec=$?
  if [ $ec != 0 ] && grep -qE 'offline mode|Could not resolve|could not be resolved|Cannot access|No plugin found for prefix' "$2"; then
    how="no - the offline build could not resolve an artifact, so Maven Central was asked"; ec=0
    (eval "${c/mvn -o -B /mvn -B }") > "$2" 2>&1 < /dev/null || ec=$?; fi
  if ghub "$2"; then die "$3: GraalVM's native plugin went over the network for its metadata repository - README.md, The repository"; fi
  [ $ec = 0 ] || { tail -30 "$2" >&3
    ! grep -qE 'Could not resolve|could not be resolved|Could not transfer|Cannot access' "$2" || die "build failed: $3 - Maven could resolve neither from .m2-demo nor from Maven Central: a fresh clone's first run needs the network once, to fill .m2-demo"
    die "build failed: $3"; }
  echo "  built $3 · offline: $how · exit $ec"; }
# tree FOLDER: a config tree in FOLDER/secrets holding one file, the token and a newline, readable by its owner alone
tree() { mkdir -p "$1/secrets/tiffinbox"; (umask 077 && printf '%s\n' "$TOKEN" > "$1/$TF"); chmod 700 "$1/secrets" "$1/secrets/tiffinbox"; }
# The copy: the anchor, and this unit's mvc/tiffinbox-web/pom.xml over its web module's POM - nothing else.
rsync -a --exclude target --exclude secrets anchor/ .harness/mvc/; cp mvc/$WPOM .harness/mvc/$WPOM; tree .harness/mvc
mbuild "$(off .harness/mvc "$R_PLAIN")" .harness/build-mvc.log ".harness/mvc (the copy: Spring MVC beside TiffinBox's server; the README's plain build)"
rsync -a --exclude target --exclude secrets anchor/ .harness/anchor/; tree .harness/anchor
mbuild "$(off .harness/anchor "$R_PLAIN")" .harness/build-anchor.log ".harness/anchor (the anchor as the last course left it)"
# The toy: the copy, and ONE line added to TiffinBox's customers() - the frames the stack walker shows, printed when the JVM runs
# with -Dprobe.stack=true. It lives in this script and under .harness/ only; the anchor's file is never touched.
TOYLINE='        if (Boolean.getBoolean("probe.stack")) StackWalker.getInstance().forEach(f -> System.out.println("probe: " + f.getClassName() + "." + f.getMethodName()));'
rsync -a --exclude target --exclude secrets .harness/mvc/ .harness/toy/; tree .harness/toy
awk -v l="$TOYLINE" '{ print } /^    Object customers\(\) throws Exception \{$/ { print l; n++ } END { if (n != 1) exit 3 }' anchor/$SRV > .harness/toy/$SRV || die "the toy's line: customers() not found once in the anchor's TiffinBoxServer.java"
mbuild "$(off .harness/toy "$R_PLAIN")" .harness/build-toy.log ".harness/toy (the copy, one line added to customers())"
for d in mvc anchor toy; do [ -f .harness/$d/tiffinbox-web/target/tiffinbox-web-1.0.0.jar ] || die "the README's build made no jar in .harness/$d"; done
# The harness: Stack compiled against the copy's own jar, extracted (the README's extract line) - its classes and the jars it
# ships - into .harness/hc, outside every tree and outside com.tiffinbox.
(cd .harness/mvc && eval "$R_EXTRACT") > .harness/extract.log 2>&1 || { cat .harness/extract.log >&3; die "the README's extract command failed in .harness/mvc"; }
javac -d .harness/hc -cp ".harness/mvc/tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:.harness/mvc/tiffinbox-web/target/extracted/lib/*" harness/probe/path/Stack.java > .harness/javac.log 2>&1 || { cat .harness/javac.log >&3; die "the harness did not compile"; }
echo "  the harness: harness/probe/path/Stack.java compiled into .harness/hc ($(find .harness/hc -name '*.class' | wc -l | tr -d ' ') class) against the copy's extracted jar"

# ---- helpers ------------------------------------------------------------------------------------------------------------
# raw TOKEN FILE...: how many times TOKEN appears, raw, in the files (occurrences, not lines; binary files read as text)
raw() { local t=$1; shift; cat "$@" | LC_ALL=C grep -aoF -- "$t" | wc -l | tr -d ' '; }
LOGS=0
start() { echo "\$ $1"; (eval "$(exe "$1")") > .harness/run.out 2> .harness/run.err < /dev/null & pid=$!; }
# msg PATTERN: the first line of the run's log whose message matches PATTERN, printed from its message on
msg() { grep -m1 -E " : $1" .harness/run.out | sed 's/^.* : //' || true; }
# ready PORT: readiness asked until it answers 200 - every 0.25 s, up to 60 s, not printed - then the README's readiness line,
# printed and run once (brief S1.13: on a two-server run this is Tomcat's port; TiffinBox's own answers 503 before Tomcat
# starts). The JVM is checked alive on every round, and the stop runs on every path (the trap).
ready() { local i=0 c=""
  while [ $i -lt 240 ]; do c=$(curl -s -o /dev/null -w '%{http_code}' "http://127.0.0.1:$1/actuator/health/readiness" 2> /dev/null || true); [ "$c" = 200 ] && break
    kill -0 "$pid" 2> /dev/null || { tail -20 .harness/run.out >&3; die "it exited before readiness answered 200"; }; sleep 0.25; i=$((i + 1)); done
  [ "$c" = 200 ] || die "readiness never answered 200 on $1"
  local q; q=$(url "$R_READY" "$1"); echo "\$ $q"; (eval "$q") 2>&1 < /dev/null | sed 's/^/  /'; }
# addrs PORT...: the addresses the JVM listens on, read off its process (after readiness: both servers are up by then); each must
# be 127.0.0.1 and one of PORT... - the answer is printed, computed, and the checks below read it
addrs() { local a w p ok=yes
  a=$(lsof -nP -a -p "$pid" -iTCP -sTCP:LISTEN 2> /dev/null | awk 'NR > 1 { print $9 }' | sort -u | paste -sd' ' -)
  w=" $*"; for p in $a; do case "$p" in 127.0.0.1:*) case "$w " in *" ${p#127.0.0.1:} "*) ;; *) ok=no ;; esac ;; *) ok=no ;; esac; done
  [ "$(printf '%s\n' $a | grep -c .)" = $# ] || ok=no
  echo "  listening, read off its process: ${a:-nothing} · on 127.0.0.1 alone, each a port of this run: $ok"; }
# own TPORT [CPORT]: each server's own line - TiffinBox's, and Tomcat's when there is one (Tomcat's never names the address)
own() { echo "  TiffinBox's own line ($1): $(msg 'TiffinBox listening on ')"
  [ -z "${2:-}" ] || echo "  Tomcat's own line ($2): $(msg 'Tomcat started on port ')"; }
logtok() { local t h; t=$(raw "$TOKEN" .harness/run.out .harness/run.err); h=$(cat .harness/run.out .harness/run.err | LC_ALL=C grep -aoi -- 'x-shutdown-token' | wc -l | tr -d ' ')
  LOGS=$((LOGS + 1)); [ "$t" = 0 ] && [ "$h" = 0 ] || die "a log held the demo token ($t) or its header's name ($h)"
  echo "  its log: the demo token 0 times · X-Shutdown-Token 0 times · WARN lines $(grep -cE '^[0-9-]+T[^ ]+ +WARN ' .harness/run.out || true) · ERROR lines $(grep -cE '^[0-9-]+T[^ ]+ +ERROR ' .harness/run.out || true)"; }
now() { local p o=""; for p in "$@"; do o="$o${o:+ · }$p $(listeners "$p")"; done; echo "  listening now: $o"; }
# gone PORT: wait until nothing listens on PORT - every 0.25 s, up to 15 s
gone() { local i=0; while [ "$(listeners "$1")" != 0 ] && [ $i -lt 60 ]; do sleep 0.25; i=$((i + 1)); done; [ "$(listeners "$1")" = 0 ] || die "$1 still listened 15 s after POST /shutdown"; }
# seven PORT DIR: the comparison set's seven requests against a JVM that serves them alone - every response line printed; the JVM
# must leave within 15 s of POST /shutdown and the port must be free; its exit code and the md5; its log counted (logtok)
seven() { local i e=0
  echo "\$ \$CURLSET $1 $2/$TF"
  "$CURLSET" "$1" "$2/$TF" | grep ' -> ' > .harness/responses.txt || true
  sed 's/^/  /' .harness/responses.txt
  i=0; while kill -0 "$pid" 2> /dev/null && [ $i -lt 60 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$pid" 2> /dev/null && { kill "$pid"; die "the server on $1 was still running 15 s after POST /shutdown"; }
  wait "$pid" || e=$?; pid=""
  [ "$(listeners "$1")" = 0 ] || die "something still listens on $1"
  echo "  exit $e · the seven responses: $(wc -l < .harness/responses.txt | tr -d ' ') lines · md5 $(md5 -q .harness/responses.txt)"
  logtok; }
# halt TPORT CPORT: the JVM stopped by its process id (TERM), waited for (30 s at most), its exit code; Tomcat's own lines on the
# way out; both ports free; its log counted (logtok). Never pkill.
halt() { local i=0 e=0
  echo "\$ kill \"\$pid\"    # TERM, by its process id"
  kill "$pid" 2> /dev/null || true
  while kill -0 "$pid" 2> /dev/null && [ $i -lt 120 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$pid" 2> /dev/null && { kill -9 "$pid"; die "the JVM on $1/$2 was still running 30 s after TERM"; }
  wait "$pid" || e=$?; pid=""
  echo "  exit $e · Tomcat's own lines on the way out: $(grep -E ' : (Commencing graceful shutdown|Graceful shutdown complete)' .harness/run.out | sed 's/^.* : //' | paste -sd'|' - | sed 's/|/ · /g')"
  now "$1" "$2"; [ "$(listeners "$1")$(listeners "$2")" = 00 ] || die "a port of the JVM on $1/$2 is still taken"
  logtok; }
# seven2 TPORT CPORT DIR: the seven against TiffinBox's port while Tomcat serves beside it - every response line printed and the
# md5; then which server stopped: TiffinBox's port closed (waited for, 15 s at most) - and whether the JVM lived, checked again 2 s
# later, with what it still listens on; then halt
seven2() {
  echo "\$ \$CURLSET $1 $3/$TF"
  "$CURLSET" "$1" "$3/$TF" | grep ' -> ' > .harness/responses.txt || true
  sed 's/^/  /' .harness/responses.txt
  echo "  the seven responses: $(wc -l < .harness/responses.txt | tr -d ' ') lines · md5 $(md5 -q .harness/responses.txt)"
  gone "$1"; sleep 2
  echo "  after POST /shutdown: TiffinBox's port $1, listening: $(listeners "$1") · the JVM, 2 s later: $(kill -0 "$pid" 2> /dev/null && echo alive || echo gone) · it listens on: $(lsof -nP -a -p "$pid" -iTCP -sTCP:LISTEN 2> /dev/null | awk 'NR > 1 { print $9 }' | sort -u | paste -sd' ' -)"
  halt "$1" "$2"; }
# ---- frames
# GROUPAWK: the declared filter (README.md, Filters). Input: "N frame" lines, the top of the stack first (N counts down to 1).
# Each frame takes the first layer whose rule matches its class; the top frame is "your method". Printed bottom to top: each
# layer's frames, and its classes in the order they first appear from the bottom ("×k" when a class shows k frames); then the
# total and the frames no rule took (0, or the run stops at the checks).
GROUPAWK='
function layer(f, top) {
  if (top) return "your method"
  if (f ~ /^java\.lang\.(Thread|VirtualThread)\.|^java\.util\.concurrent\.|^org\.apache\.tomcat\.util\.threads\./) return "the thread"
  if (f ~ /^org\.apache\.tomcat\.util\.net\.|^org\.apache\.coyote\.|^org\.apache\.catalina\.connector\./) return "the connector"
  if (f ~ /^sun\.net\.httpserver\.ServerImpl\$Exchange\./) return "the JDK server"
  if (f ~ /^org\.apache\.catalina\.core\.Standard|^org\.apache\.catalina\.valves\.|^org\.apache\.catalina\.authenticator\./) return "the container"
  if (f ~ /^org\.apache\.catalina\.core\.ApplicationFilterChain\.|^org\.springframework\.web\.filter\.|^org\.apache\.tomcat\.websocket\.server\.WsFilter\.|^com\.sun\.net\.httpserver\.Filter\$|^sun\.net\.httpserver\.(AuthFilter|ServerImpl\$Exchange\$LinkHandler)\./) return "the filters"
  if (f ~ /^jakarta\.servlet\.|^org\.springframework\.web\.servlet\.FrameworkServlet\./) return "the servlet"
  if (f ~ /^org\.springframework\.web\.(servlet|method)\./) return "Spring MVC"
  if (f ~ /^com\.tiffinbox\./) return "TiffinBox router"
  return "unmatched" }
function simple(f,   c) { c = f; sub(/\.[^.]*$/, "", c); sub(/^.*\./, "", c); return c }
/^ *[0-9]+ [^ ]+$/ { n++; fr[n] = $2 }
END {
  for (i = n; i >= 1; i--) {
    l = layer(fr[i], i == 1); if (!(l in cnt)) { ord[++nl] = l }; cnt[l]++
    c = (i == 1) ? simple(fr[i]) "." meth(fr[i]) : simple(fr[i])
    k = l SUBSEP c; if (!(k in kc)) { kord[l, ++nk[l]] = c }; kc[k]++ }
  for (j = 1; j <= nl; j++) { l = ord[j]; s = ""
    for (m = 1; m <= nk[l]; m++) { c = kord[l, m]; s = s (m > 1 ? " · " : "") c (kc[l, c] > 1 ? " ×" kc[l, c] : "") }
    printf "  %2d  %-14s %s\n", cnt[l], l, s }
  printf "  %2d  in all · frames no rule took: %d\n", n, cnt["unmatched"] + 0 }
function meth(f,   m) { m = f; sub(/^.*\./, "", m); return m }'
# frames FILE: the frame lines of FILE ("N frame"), counted and printed as they came, then grouped (GROUPAWK)
frames() { echo "  bottom to top, grouped by the README's filter - frames · layer · classes:"; awk "$GROUPAWK" "$1"; }
# ---- TiffinBox's own lines at DEBUG, and its timer (read from a scrape through the bridge, which neither logs nor times)
ANS='^[0-9-]+T[^ ]+ +DEBUG [0-9]+ --- \[[^]]*\] tiffinbox +: [A-Z]+ [^ ]+ -> [0-9]+$|^[0-9-]+T[^ ]+ +DEBUG [0-9]+ --- \[[^]]*\] tiffinbox +: UNKNOWN -> [0-9]+$'
dcount() { grep -cE "$ANS" .harness/run.out || true; }
dlines() { grep -E "$ANS" .harness/run.out | awk -v from="$1" 'NR > from { s = $0; sub(/^.* tiffinbox +: /, "", s); print "    " s }'; }
total() { curl -s "http://127.0.0.1:$1/actuator/prometheus" | grep '^tiffinbox_requests_seconds_count{' | awk '{ s += $NF } END { print s + 0 }'; }
# tsettle PORT: wait until every answer TiffinBox timed has its line at DEBUG and nothing moved for half a second (its line is
# written, and its timer stopped, just after the answer leaves) - every 0.5 s, up to 20 s
tsettle() { local i=0 a b p=""
  while [ $i -lt 40 ]; do a=$(total "$1"); b=$(dcount); [ "$a" = "$b" ] && [ "$a" = "$p" ] && return 0; p=$a; sleep 0.5; i=$((i + 1)); done
  die "TiffinBox's timer ($a) and its lines at DEBUG ($b) never settled on $1"; }
# ---- Spring's lines at DEBUG (the log group web): every DEBUG line a request added, printed from its logger on
WEBL='^[0-9-]+T[^ ]+ +DEBUG [0-9]+ --- \['
wcount() { grep -cE "$WEBL" .harness/run.out || true; }
# wsettle: wait until the DEBUG lines stop moving for half a second and the last one ends a request (Completed, or the end of the
# ERROR dispatch) - every 0.5 s, up to 20 s
wsettle() { local i=0 a p=-1 l
  while [ $i -lt 40 ]; do a=$(wcount); l=$(grep -E "$WEBL" .harness/run.out | tail -1)
    if [ "$a" = "$p" ]; then case "$l" in *' : Completed '*|*' : Exiting from "ERROR" dispatch'*) return 0 ;; esac; fi
    p=$a; sleep 0.5; i=$((i + 1)); done
  die "Spring's lines at DEBUG never settled"; }
wlines() { grep -E "$WEBL" .harness/run.out | awk -v from="$1" 'NR > from { s = $0; sub(/^.*--- \[[^]]*\] /, "", s); i = index(s, " : "); lg = substr(s, 1, i - 1); sub(/ +$/, "", lg); print "    " lg ": " substr(s, i + 3) }'; }
# mask: the demo token becomes a label naming its length; this folder's path "…", the folder above it "…/..", the home folder "~"
# (each also in its URL form, spaces as %20); a Tomcat request thread's number; an identity hash; Spring's error timestamp, in each
# form it takes; last, your user name "<user>" - as a whole word only, so a short name never eats a word it is part of - in every
# line (gsub; the user name by index(), the only mask that must see word boundaries)
mask() { awk -v t="$TOKEN" -v u="$U" -v up="$UP" -v hm="$HOME" -v me="$ME" '
  function lit(x) { gsub(/[][\\.^$*+?(){}|\/]/, "\\\\&", x); return x }
  function enc(x) { gsub(/ /, "%20", x); return x }
  function ids(s,   o) { o = ""; while (match(s, /[A-Za-z0-9_$]@[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]+/)) { o = o substr(s, 1, RSTART) "@<hash>"; s = substr(s, RSTART + RLENGTH) }; return o s }
  function word(s, w, r,   o, i, a, z) { o = ""; if (w == "") return s
    while ((i = index(s, w)) > 0) { a = substr(s, i - 1, 1); z = substr(s, i + length(w), 1)
      if ((i == 1 || a !~ /[A-Za-z0-9_]/) && z !~ /[A-Za-z0-9_]/) { o = o substr(s, 1, i - 1) r } else { o = o substr(s, 1, i + length(w) - 1) }
      s = substr(s, i + length(w)) }
    return o s }
  BEGIN { T = lit(t); P = lit(u); Q = lit(up); H = lit(hm); PE = lit(enc(u)); QE = lit(enc(up)); TL = "[masked: the " length(t) "-character token]" }
  { gsub(T, TL); gsub(P, "…"); gsub(PE, "…"); gsub(Q, "…/.."); gsub(QE, "…/.."); gsub(H, "~")
    gsub(/-exec-[0-9]+/, "-exec-N"); gsub(/tomcat-handler-[0-9]+/, "tomcat-handler-N")
    gsub(/"timestamp":"[^"]*"/, "\"timestamp\":\"<masked: an ISO-8601 time>\""); gsub(/"timestamp":[0-9]+/, "\"timestamp\":<masked: epoch milliseconds>")
    gsub(/timestamp=[A-Z][a-z][a-z] [A-Z][a-z][a-z] [ 0-9][0-9] [0-9][0-9]:[0-9][0-9]:[0-9][0-9] [A-Za-z0-9+:-]+ [0-9][0-9][0-9][0-9]/, "timestamp=<masked: a date>")
    print word(ids($0), me, "<user>") }'; }
unpub=""
cap() { local nm=$1 h pub i; shift
  for i in 1 2 3; do "$@" > .harness/cap.raw 2>&1 || true; [ -z "$pid" ] || die "$nm left a process running"
    for p in 19300 19301 19302 19303 19304 19305 19306 19307 19308 19309; do [ "$(listeners $p)" = 0 ] || die "$nm left $p taken"; done
    raw "$TOKEN" .harness/cap.raw > ".harness/raw-$nm.$i"; mask < .harness/cap.raw > ".r-$nm.$i"; done
  h=$(md5 -q ".r-$nm.1")
  [ "$h" = "$(md5 -q ".r-$nm.2")" ] && [ "$h" = "$(md5 -q ".r-$nm.3")" ] || die "$nm drifts across three runs (diff .r-$nm.1 .r-$nm.2 .r-$nm.3)"
  mv ".r-$nm.1" ".r-$nm.out"; rm -f ".r-$nm.2" ".r-$nm.3"
  pub=$(awk -v n="$nm" '$1 == n { print $2 }' receipts.md5 2> /dev/null || true)
  if [ -z "$pub" ]; then printf '  %-9s md5 %s  3/3  (no published hash)\n' "$nm" "$h"; unpub="$unpub $nm"
  elif [ "$pub" = "$h" ]; then printf '  %-9s md5 %s  3/3  = published\n' "$nm" "$h"
  else printf '  %-9s md5 %s  3/3  DIFFERS from the published %s\n' "$nm" "$h" "$pub"
    die "$nm is not the published capture - suspect another JDK, Boot or Maven, a busy machine, a busy port, a variable of yours, or an edited source; diff .r-$nm.out against its block in README.md"; fi; }

# ---- before: where the last course left it, and the copy ----------------------------------------------------------------------
before() { local P=19300 T=19301
  echo "where the last course left it - the anchor, TiffinBox's own server alone: the README's run line, from .harness/anchor, port $P:"
  start "$(at .harness/anchor $P 0 "$R_RUN")"; ready $P; addrs $P; own $P
  seven $P .harness/anchor
  echo "the anchor against the last course's own anchor, ../c5-tiffinbox (diff -rq; target/, secrets/, .m2-demo/ and .harness/ left out): $(diff -rq -x target -x secrets -x .m2-demo -x .harness anchor/ ../c5-tiffinbox/ | wc -l | tr -d ' ') differences"
  echo "the copy - Spring MVC beside TiffinBox's server - against the anchor (diff -rq, target/ and secrets/ left out):"
  diff -rq -x target -x secrets anchor/ .harness/mvc/ | sed 's/^Files anchor\/\(.*\) and .* differ$/  differs: \1/'
  echo "\$ diff -U0 anchor/$WPOM mvc/$WPOM"
  diff -U0 anchor/$WPOM mvc/$WPOM | tail -n +3 | sed 's/^/  /' || true
  echo "the jars each executable jar carries (BOOT-INF/lib):"
  jar tf .harness/anchor/tiffinbox-web/target/tiffinbox-web-1.0.0.jar | grep -E '^BOOT-INF/lib/.+\.jar$' | sed 's/^BOOT-INF\/lib\///' | sort > .harness/lib-anchor.txt
  jar tf .harness/mvc/tiffinbox-web/target/tiffinbox-web-1.0.0.jar | grep -E '^BOOT-INF/lib/.+\.jar$' | sed 's/^BOOT-INF\/lib\///' | sort > .harness/lib-mvc.txt
  echo "  the anchor's: $(grep -c . .harness/lib-anchor.txt) · the copy's: $(grep -c . .harness/lib-mvc.txt) · only in the copy's: $(comm -13 .harness/lib-anchor.txt .harness/lib-mvc.txt | grep -c .) · only in the anchor's: $(comm -23 .harness/lib-anchor.txt .harness/lib-mvc.txt | grep -c . || true)"
  comm -13 .harness/lib-anchor.txt .harness/lib-mvc.txt | sed 's/^/    + /'
  echo "the copy, two servers in one JVM - the copy's run line (README.md: the anchor's, Tomcat's address and port added), from .harness/mvc, ports $P and $T:"
  start "$(at .harness/mvc $P $T "$R_MRUN")"; ready $T; addrs $P $T; own $P $T
  echo "the seven, on TiffinBox's own port:"
  seven2 $P $T .harness/mvc; }

# ---- toy: TiffinBox's own server, asked who called customers() --------------------------------------------------------------
toy() { local P=19302 T=19303 d0
  echo "the toy path - the copy again, with one line added to TiffinBox's customers() (diff -U0, the anchor's file against the toy's):"
  echo "\$ diff -U0 anchor/$SRV .harness/toy/$SRV"
  diff -U0 anchor/$SRV .harness/toy/$SRV | tail -n +3 | sed 's/^/  /' || true
  start "$(at .harness/toy $P $T "$R_TOY")"; ready $T; addrs $P $T; own $P $T
  echo "GET /customers on TiffinBox's own port - the method its router calls:"
  d0=$(dcount); echo "\$ $(url "$R_TCUST" $P)"; (eval "$(url "$R_TCUST" $P)") 2>&1 < /dev/null | sed 's/^/  /'
  tsettle $P
  grep '^probe: ' .harness/run.out | sed 's/^probe: //' | awk '{ l[NR] = $0 } END { for (i = 1; i <= NR; i++) printf "  %2d %s\n", NR - i + 1, l[i] }' > .harness/toy-frames.txt
  echo "  the frames the stack walker shows, printed by the line in customers(): $(grep -c . .harness/toy-frames.txt)"
  cat .harness/toy-frames.txt
  frames .harness/toy-frames.txt
  echo "  how handle() calls the method - the anchor's TiffinBoxServer.java, $(grep -n 'handler\.invoke(this)' anchor/$SRV | sed 's/^\([0-9]*\): */line \1: /') - reflection (Method.invoke): no frame of it above, the stack walker hides reflection's own"
  echo "  TiffinBox's lines at DEBUG it added: $(( $(dcount) - d0 ))"; dlines "$d0"
  echo "C (labelled) - GET /nowhere on TiffinBox's own port, a path no route declares:"
  d0=$(dcount); echo "\$ $(url "$R_TNOWH" $P)"; (eval "$(url "$R_TNOWH" $P)") 2>&1 < /dev/null | sed 's/^/  /'
  tsettle $P
  echo "  TiffinBox's lines at DEBUG it added: $(( $(dcount) - d0 ))"; dlines "$d0"
  echo "  the line in customers() printed, in all: $(grep -c '^probe: ' .harness/run.out) frames"
  halt $P $T; }

# ---- path: the harness's method on Tomcat, asked the same question -------------------------------------------------------------
path() { local P=19304 T=19305
  echo "the industrial path - the harness's @RestController (probe.path.Stack, outside com.tiffinbox) on Tomcat's port; the class path: the extracted jar plus the harness's classes (README.md):"
  start "$(at .harness/mvc $P $T "$R_HCP")"; ready $T; addrs $P $T; own $P $T
  echo "  its log at INFO, from the first request on Tomcat's port (readiness's) - logger: message: $(grep -m1 ' : Initializing Spring ' .harness/run.out | sed 's/^.*--- \[[^]]*\] //; s/ *: /: /')"
  echo "\$ $(url "$R_STACK" $T)"
  (eval "$(url "$R_STACK" $T)") 2>&1 < /dev/null > .harness/stack.txt || true
  sed 's/^/  /' .harness/stack.txt
  frames .harness/stack.txt
  echo "  the filters themselves - each class whose name ends in Filter, bottom to top (OncePerRequestFilter, the base class Spring's filters share, left out): $(awk '/^ *[0-9]+ [^ ]+$/ { c = $2; sub(/\.[^.]*$/, "", c); l[++n] = c } END { for (i = n; i >= 1; i--) { c = l[i]; t = c; sub(/^.*\./, "", t); if (t ~ /Filter$/ && t != "OncePerRequestFilter" && !(c in seen)) { seen[c] = 1; k++; o = o (k > 1 ? " · " : "") (c ~ /^org\.springframework\./ ? "Spring: " : (c ~ /^org\.apache\./ ? "Tomcat: " : "")) t } }; print k + 0 " - " o }' .harness/stack.txt)"
  halt $P $T; }

# ---- log: the path in Spring's own words -----------------------------------------------------------------------------------------
# ask 'curl LINE' PORT LABEL: the request printed and run; then the lines it added at DEBUG, once they settled
ask() { local c w0; c=$(url "$1" "$2"); w0=$(wcount)
  echo "\$ $c"; (eval "$c") 2>&1 < /dev/null | sed 's/^/  /'
  wsettle; echo "  its lines at DEBUG: $(( $(wcount) - w0 ))"; wlines "$w0"; }
logcap() { local P=19306 T=19307 w
  echo "the anchor README's web line (Boot's log group web at DEBUG) on the copy, with the harness - README.md, ports $P and $T:"
  start "$(at .harness/mvc $P $T "$R_HWEB")"; ready $T; addrs $P $T; own $P $T
  wsettle; echo "  Spring's lines at DEBUG before A - readiness, and the DispatcherServlet's set-up at the first request - are not shown: their number moves with the polls readiness took"
  echo "A - GET /probe/stack on Tomcat's port, the harness's route:"
  ask "$R_ASK" $T
  echo "B - GET /nowhere on Tomcat's port, a path nobody declared:"
  ask "$R_NOWH" $T
  echo "A' - A again:"
  ask "$R_ASK" $T
  halt $P $T; }

# ---- exercise: the README's commands, exactly as written, then the solution's, then A' ----------------------------------------
block() { awk '/^```bash$/ { if (!d) { f = 1 }; next } f && /^```$/ { f = 0; d = 1 } f' "$1"; }
exout() { echo "  exit $1 · printed:"; sed 's/^/    /' .harness/ex.log
  echo "  its log (.harness/mine/mvc/run.log): lines that name spring.threads.virtual.enable $(grep -cE 'virtual\.enable([^d]|$)' .harness/mine/mvc/run.log || true) · WARN lines $(grep -cE '^[0-9-]+T[^ ]+ +WARN ' .harness/mine/mvc/run.log || true) · ERROR lines $(grep -cE '^[0-9-]+T[^ ]+ +ERROR ' .harness/mine/mvc/run.log || true) · Tomcat started $(grep -c ' : Tomcat started on port 19309 ' .harness/mine/mvc/run.log || true) · TiffinBox listening $(grep -c ' : TiffinBox listening on http://127.0.0.1:19308$' .harness/mine/mvc/run.log || true)"
  now 19308 19309; }
exercise() { local setup sol run ec=0 tok
  setup=$(block exercise/README.md); sol=$(block exercise/solution/SOLUTION.md)
  [ -n "$setup" ] && [ -n "$sol" ] || die "exercise/README.md or SOLUTION.md no longer gives its commands"
  [ "$(printf '%s\n' "$sol" | grep -c .)" = 1 ] || die "SOLUTION.md's first bash block must be its one line"
  run=$(printf '%s\n' "$setup" | tail -1)
  [ "${run/--spring.threads.virtual.enable=true /--spring.threads.virtual.enabled=true }" = "$sol" ] && [ "$run" != "$sol" ] || die "the solution must be the README's run line with one word mended"
  echo "A - exercise/README.md's commands, run exactly as written from this folder - $(printf '%s\n' "$setup" | grep -c .) lines:"
  printf '%s\n' "$setup" | sed 's/^/  $ /'
  (eval "$setup") > .harness/ex.log 2>&1 < /dev/null || ec=$?
  exout $ec; cp .harness/mine/stack.txt .harness/ex-a.txt
  echo "B - the solution's line (exercise/solution/SOLUTION.md), run exactly as written, from this folder:"
  echo "\$ $sol"
  ec=0; (eval "$sol") > .harness/ex.log 2>&1 < /dev/null || ec=$?
  exout $ec; cp .harness/mine/stack.txt .harness/ex-b.txt
  sed -n 's/^ *[0-9][0-9]* //p' .harness/ex-a.txt | sort > .harness/ex-a.s; sed -n 's/^ *[0-9][0-9]* //p' .harness/ex-b.txt | sort > .harness/ex-b.s
  echo "  A's frames against B's: the frames that left $(comm -23 .harness/ex-a.s .harness/ex-b.s | grep -c . || true) · the frames that came $(comm -13 .harness/ex-a.s .harness/ex-b.s | grep -c . || true) · the rest, the same: $(comm -12 .harness/ex-a.s .harness/ex-b.s | grep -c . || true)"
  comm -23 .harness/ex-a.s .harness/ex-b.s | sed 's/^/    left: /'; comm -13 .harness/ex-a.s .harness/ex-b.s | sed 's/^/    came: /'
  echo "A' - A again: the README's run line, as written:"
  echo "\$ $run"
  ec=0; (eval "$run") > .harness/ex.log 2>&1 < /dev/null || ec=$?
  exout $ec
  tok=$(head -1 .harness/mine/mvc/$TF); [ ${#tok} = 26 ] || die "the exercise's own token: 26 characters"
  echo "  the exercise's own token (26 random characters, its config tree's): in its log $(raw "$tok" .harness/mine/mvc/run.log) times · in what it printed $(raw "$tok" .harness/ex.log) times"; }

cap before before
cap toy toy
cap path path
cap log logcap
cap exercise exercise

echo
# ---- every number the video says, asserted. Each check reads a line a program computed - never a label this script prints
# ---- unconditionally - and names the words it pays for.
x() { grep -qE -- "$2" ".r-$1.out" || die "$1: expected /$2/"; }
blk() { awk -v a="$2" -v b="$3" 'index($0, a) == 1 { f = 1; next } b != "" && index($0, b) == 1 { f = 0 } f' ".r-$1.out"; }
has() { printf '%s\n' "$1" | grep -qxF -- "$2" || die "$3: expected the line: $2"; }
cnt() { printf '%s\n' "$1" | grep -cxF -- "$2" || true; }
S115='115c36bac276128e245ca57df11c2891'
READY='  {"status":"UP"} 200'
LOGOK="  its log: the demo token 0 times · X-Shutdown-Token 0 times · WARN lines 0 · ERROR lines 0"
# THE TOKEN: no capture holds it, raw - counted on each run's own output BEFORE masking - and neither does any log (each counted
# when it was read: logtok()) nor anything this unit ships for reading
for f in .harness/raw-*; do [ "$(cat "$f")" = 0 ] || die "a capture's raw output held the demo token ($f)"; done
for f in .r-*.out README.md exercise/README.md exercise/solution/SOLUTION.md receipts.md5 harness/probe/path/Stack.java mvc/$WPOM; do
  [ -f "$f" ] || continue; [ "$(raw "$TOKEN" "$f")" = 0 ] || die "$f holds the demo token, raw"; done
for f in .r-*.out; do ! grep -qE '/Users/|/private/|/home/|/var/folders/' "$f" || die "$f holds an absolute path"; ! grep -qE 'c[0-9]-unit[0-9]|[Uu]nit ?[0-9]' "$f" || die "$f holds a unit number"
  ! grep -qE ' (with PID|started by) ' "$f" || die "$f holds Boot's process line"; ! grep -qE '^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T' "$f" || die "$f holds a log time"
  ! grep -qE 'exec-[0-9]|tomcat-handler-[0-9]|virtual-[0-9]|@[0-9a-f]{6,}' "$f" || die "$f holds a thread number or an identity hash"
  ! grep -qE '"timestamp":"?[0-9]|timestamp=[A-Z][a-z]' "$f" || die "$f holds Spring's error timestamp, unmasked"
  ! grep -q 'offline: no' "$f" || die "$f holds a build that went online"; done
for f in README.md exercise/README.md exercise/solution/SOLUTION.md .r-*.out; do ! grep -E -- '--server\.port=' "$f" | grep -vE -- '--server\.address=127\.0\.0\.1 --server\.port=' > /dev/null || die "$f starts Tomcat without --server.address=127.0.0.1 (it would bind every interface)"; done
for f in receipts.sh README.md exercise/README.md exercise/solution/SOLUTION.md; do ! grep -qE 'exposure\.include=\*|exposure\.include=.\*' "$f" || die "$f exposes every endpoint"; done
NL=$(cat .r-*.out | grep -cxF "$LOGOK" || true)
echo "  token: 0 raw copies in $(ls .harness/raw-* | wc -l | tr -d ' ') raw capture runs, in $(ls .r-*.out | wc -l | tr -d ' ') captures, in the log of every JVM that served ($LOGS here; the published captures' $NL), the READMEs, the harness, the POM and receipts.md5; no absolute path, no unit number, no log time, no thread number, no raw timestamp"

# LOOP 'TEXT' PORTS WHAT: the listening line - on 127.0.0.1 alone, the run's own ports
loop() { has "$1" "  listening, read off its process: $2 · on 127.0.0.1 alone, each a port of this run: yes" "$3: listening on 127.0.0.1 alone"; }
HALT="  exit 143 · Tomcat's own lines on the way out: Commencing graceful shutdown. Waiting for active requests to complete · Graceful shutdown complete"
# "The last course ended here: TiffinBox's own server, the seven. One dependency line puts Spring MVC beside it: twelve jars more,
# Tomcat among them. Two servers in one JVM, each on its own port, both on this computer only. The seven: the same."
B0=$(blk before 'where the last course left it' 'the copy - Spring MVC'); B1=$(blk before 'the copy, two servers' '')
loop "$B0" "127.0.0.1:19300" "before, the anchor"; has "$B0" "  TiffinBox's own line (19300): TiffinBox listening on http://127.0.0.1:19300" "before: the anchor's line"
has "$B0" "  exit 0 · the seven responses: 7 lines · md5 $S115" "before: the anchor's seven, exit 0"; has "$B0" "$LOGOK" "before: the anchor's log"
x before '^the anchor against the last course.s own anchor, \.\./c5-tiffinbox .*: 0 differences$'
x before '^  differs: tiffinbox-web/pom\.xml$'; [ "$(grep -c '^  differs: ' .r-before.out)" = 1 ] || die "before: one file differs"
[ "$(blk before '$ diff -U0 anchor/tiffinbox-web/pom.xml' 'the jars each' | grep -c '^  +')" = 1 ] || die "before: one line added"
x before '^  \+    <dependency><groupId>org\.springframework\.boot</groupId><artifactId>spring-boot-starter-webmvc</artifactId></dependency>$'
[ "$(blk before '$ diff -U0 anchor/tiffinbox-web/pom.xml' 'the jars each' | grep -c '^  -  *<exclude>$')" = 2 ] || die "before: two excludes dropped"
[ "$(blk before '$ diff -U0 anchor/tiffinbox-web/pom.xml' 'the jars each' | grep -c '^  -  *<groupId>tools\.jackson\.core</groupId>$')" = 2 ] || die "before: both excludes Jackson 3's"
NJA=$(sed -n 's/^  the anchor.s: \([0-9]*\) · .*/\1/p' .r-before.out); NJM=$(sed -n 's/^  the anchor.s: [0-9]* · the copy.s: \([0-9]*\) · .*/\1/p' .r-before.out)
x before "^  the anchor's: $NJA · the copy's: $NJM · only in the copy's: 12 · only in the anchor's: 0\$"; [ $((NJM - NJA)) = 12 ] || die "before: twelve jars more"
for j in tomcat-embed-core spring-webmvc spring-web jackson-databind-3; do x before "^    \+ $j"; done
loop "$B1" "127.0.0.1:19300 127.0.0.1:19301" "before, the copy"
has "$B1" "  TiffinBox's own line (19300): TiffinBox listening on http://127.0.0.1:19300" "before: TiffinBox's line"
has "$B1" "  Tomcat's own line (19301): Tomcat started on port 19301 (http) with context path '/'" "before: Tomcat's line"
has "$B1" "  the seven responses: 7 lines · md5 $S115" "before: the copy's seven"
has "$B1" "  after POST /shutdown: TiffinBox's port 19300, listening: 0 · the JVM, 2 s later: alive · it listens on: 127.0.0.1:19301" "before: TiffinBox's server stopped, the JVM lived"
has "$B1" "$HALT" "before: stopped by its process id"; has "$B1" "  listening now: 19300 0 · 19301 0" "before: both ports free"; has "$B1" "$LOGOK" "before: the copy's log"
echo "  before: the anchor 127.0.0.1:19300, the seven $S115, exit 0 · = ../c5-tiffinbox · the copy: 1 file, +1 line, 2 excludes; jars $NJA -> $NJM (+12) · 127.0.0.1:19300 + :19301, each its own line · the seven $S115 · TiffinBox stopped, the JVM lived; TERM -> 143, graceful, both free"

# "TiffinBox's own server needs eleven frames, on a virtual thread: the JDK's server, its own filter chain, your router, your method."
x toy '^  @@ -106,0 \+107 @@$'; [ "$(blk toy '$ diff -U0 anchor/' '$ cd .harness/toy' | grep -c '^  [+-]')" = 1 ] || die "toy: one line added"
loop "$(cat .r-toy.out)" "127.0.0.1:19302 127.0.0.1:19303" "toy"
x toy "^  Tomcat's own line \(19303\): Tomcat started on port 19303 \(http\) with context path '/'\$"
NTOY=$(sed -n 's/^  the frames the stack walker shows, printed by the line in customers(): \([0-9]*\)$/\1/p' .r-toy.out); [ "$NTOY" = 11 ] || die "toy: eleven frames"
x toy '^   1 java\.lang\.VirtualThread\.run$'; x toy '^  11 com\.tiffinbox\.web\.TiffinBoxServer\.customers$'
x toy '^  11  in all · frames no rule took: 0$'
x toy '^   2  the thread +VirtualThread · ThreadPerTaskExecutor\$TaskRunner$'; x toy '^   1  the JDK server +ServerImpl\$Exchange$'
x toy '^   5  the filters +Filter\$Chain ×3 · ServerImpl\$Exchange\$LinkHandler · AuthFilter$'; x toy '^   2  TiffinBox router +TiffinBoxServer ×2$'
x toy '^   1  your method +TiffinBoxServer\.customers$'
x toy '^  how handle\(\) calls the method - the anchor.s TiffinBoxServer\.java, line [0-9]+: respond\(exchange, 200, handler\.invoke\(this\)\); - reflection \(Method\.invoke\): no frame of it above, the stack walker hides reflection.s own$'
[ "$(grep -c 'java\.lang\.reflect\.\|jdk\.internal\.reflect\.' .r-toy.out .r-path.out | awk -F: '{ s += $2 } END { print s }')" = 0 ] || die "a reflection frame shows"
x toy '^  10 com\.tiffinbox\.web\.TiffinBoxServer\.handle$'
T1=$(blk toy 'GET /customers on' 'C (labelled)'); TC=$(blk toy 'C (labelled)' '')
has "$T1" "  200 application/json" "toy: /customers 200"; has "$T1" "  TiffinBox's lines at DEBUG it added: 1" "toy: one line"; has "$T1" "    GET /customers -> 200" "toy: its line"
has "$TC" "  <h1>404 Not Found</h1>No context found for request 404 text/html" "toy C: the JDK's page"; has "$TC" "  TiffinBox's lines at DEBUG it added: 0" "toy C: no line"
has "$TC" "  the line in customers() printed, in all: 11 frames" "toy C: customers() not called"
has "$TC" "$HALT" "toy: stopped by its process id"; has "$TC" "  listening now: 19302 0 · 19303 0" "toy: both ports free"
echo "  toy: one line added; 11 frames, VirtualThread.run at the bottom; 2 thread · 1 JDK server · 5 filters · 2 router · 1 method; C: the JDK's 404, 0 lines"

# "Spring's needs forty-five: Tomcat's pool thread, four; the connector, six; the container, six; the filter chain, fifteen, five
# filters; the servlet, five; the DispatcherServlet and the handler adapter, eight; your method, one."
loop "$(cat .r-path.out)" "127.0.0.1:19304 127.0.0.1:19305" "path"
x path "^  Tomcat's own line \(19305\): Tomcat started on port 19305 \(http\) with context path '/'\$"
x path '^  thread http-nio-127\.0\.0\.1-19305-exec-N · virtual false$'; x path '^  frames the stack walker shows: 45$'
x path '^  45 probe\.path\.Stack\.frames$'; x path '^   1 java\.lang\.Thread\.run$'
x path '^  45  in all · frames no rule took: 0$'
x path '^   4  the thread +Thread · TaskThread\$WrappingRunnable · ThreadPoolExecutor\$Worker · ThreadPoolExecutor$'
x path '^   6  the connector +SocketProcessorBase · NioEndpoint\$SocketProcessor · AbstractProtocol\$ConnectionHandler · AbstractProcessorLight · Http11Processor · CoyoteAdapter$'
x path '^   6  the container +StandardEngineValve · ErrorReportValve · StandardHostValve · AuthenticatorBase · StandardContextValve · StandardWrapperValve$'
x path '^  15  the filters +ApplicationFilterChain ×6 · OncePerRequestFilter ×4 · CharacterEncodingFilter · ServerHttpObservationFilter · FormContentFilter · RequestContextFilter · WsFilter$'
x path '^   5  the servlet +HttpServlet ×2 · FrameworkServlet ×3$'
x path '^   8  Spring MVC +DispatcherServlet ×2 · AbstractHandlerMethodAdapter · RequestMappingHandlerAdapter ×2 · ServletInvocableHandlerMethod · InvocableHandlerMethod ×2$'
x path '^   1  your method +Stack\.frames$'
x path "^  its log at INFO, from the first request on Tomcat's port \(readiness's\) - logger: message: o\.a\.c\.c\.C\.\[Tomcat\]\.\[localhost\]\.\[/\]: Initializing Spring DispatcherServlet 'dispatcherServlet'\$"
x path '^  the filters themselves - .*: 5 - Spring: CharacterEncodingFilter · Spring: ServerHttpObservationFilter · Spring: FormContentFilter · Spring: RequestContextFilter · Tomcat: WsFilter$'
x path "^$HALT\$"; x path '^  listening now: 19304 0 · 19305 0$'
echo "  path: 45 frames on http-nio-…-exec-N, not virtual: 4 thread · 6 connector · 6 container · 15 filters (5 filters: 4 Spring's, Tomcat's WsFilter) · 5 servlet · 8 Spring MVC · 1 method; 0 unmatched"

# "A: five lines - the request, mapped to your method, completed 200. B: slash nowhere still finds a handler, the static-resource
# one; an exception; the container sends it back through the DispatcherServlet, to Boot's error controller; JSON, four oh four.
# A again: the same five lines."
loop "$(cat .r-log.out)" "127.0.0.1:19306 127.0.0.1:19307" "log"
LA=$(blk log 'A - GET' 'B - GET'); LB=$(blk log 'B - GET' "A' - A again"); LA2=$(blk log "A' - A again" '$ kill "$pid"')
has "$LA" "  200 text/plain;charset=UTF-8" "log A: 200"; has "$LA" "  its lines at DEBUG: 5" "log A: five lines"
has "$LA" '    o.s.web.servlet.DispatcherServlet: GET "/probe/stack", parameters={}' "log A: the request"
has "$LA" '    s.w.s.m.m.a.RequestMappingHandlerMapping: Mapped to probe.path.Stack#frames()' "log A: mapped to the method"
has "$LA" '    o.s.web.servlet.DispatcherServlet: Completed 200 OK' "log A: completed"
[ "$(printf '%s\n' "$LA" | sed -n '/its lines at DEBUG/,$p')" = "$(printf '%s\n' "$LA2" | sed -n '/its lines at DEBUG/,$p')" ] || die "log: A' is not A's lines"
[ "$(printf '%s\n' "$LA" | grep '^\$ ')" = "$(printf '%s\n' "$LA2" | grep '^\$ ')" ] || die "log: A' is not A's command"
has "$LB" '  {"timestamp":"<masked: an ISO-8601 time>","status":404,"error":"Not Found","path":"/nowhere"} 404 application/json' "log B: Spring's 404, JSON"
has "$LB" "  its lines at DEBUG: 10" "log B: ten lines"
has "$LB" '    o.s.w.s.handler.SimpleUrlHandlerMapping: Mapped to ResourceHttpRequestHandler [classpath [META-INF/resources/], classpath [resources/], classpath [static/], classpath [public/], ServletContext [/]]' "log B: the static-resource handler"
has "$LB" "    .w.s.m.s.DefaultHandlerExceptionResolver: Resolved [org.springframework.web.servlet.resource.NoResourceFoundException: No static resource nowhere for request '/nowhere'.]" "log B: the exception"
has "$LB" '    o.s.web.servlet.DispatcherServlet: Completed 404 NOT_FOUND' "log B: completed 404"
has "$LB" '    o.s.web.servlet.DispatcherServlet: "ERROR" dispatch for GET "/error", parameters={}' "log B: the ERROR dispatch"
has "$LB" '    s.w.s.m.m.a.RequestMappingHandlerMapping: Mapped to org.springframework.boot.webmvc.autoconfigure.error.BasicErrorController#error(HttpServletRequest)' "log B: Boot's error controller"
has "$LB" '    o.s.w.s.m.m.a.HttpEntityMethodProcessor: Writing [{timestamp=<masked: a date>, status=404, error=Not Found, path=/nowhere}]' "log B: the body written"
[ "$(cnt "$LB" '    o.s.web.servlet.DispatcherServlet: GET "/nowhere", parameters={}')" = 1 ] && [ "$(printf '%s\n' "$LB" | grep -c '^    o\.s\.web\.servlet\.DispatcherServlet: ' || true)" = 4 ] || die "log B: through the DispatcherServlet twice"
x log "^$HALT\$"; x log '^  listening now: 19306 0 · 19307 0$'
echo "  log: A 200, 5 lines (GET, mapped to probe.path.Stack#frames(), completed) · B 404 JSON, 10 lines: ResourceHttpRequestHandler, NoResourceFoundException, the ERROR dispatch, BasicErrorController · A' = A"

# the exercise's end state: the line exercise/README.md calls "Done" is a line of this capture, after the solution's line - and of
# SOLUTION.md's measured run; A and A' print the README's broken result, and Boot says nothing about the misspelt key
EA=$(blk exercise 'A - exercise' 'B - the solution'); EB=$(blk exercise 'B - the solution' "A' - A again"); EA2=$(blk exercise "A' - A again" '')
END42='frames the stack walker shows: 42 · the bottom frame: java.lang.VirtualThread.run'
END45='frames the stack walker shows: 45 · the bottom frame: java.lang.Thread.run'
has "$EB" "    $END42" "exercise B: the end state"; has "$EA" "    $END45" "exercise A: the misspelt option"; has "$EA2" "    $END45" "exercise A': A again"
awk '/^\*\*Done\*\*/ { f = 1 } f' exercise/README.md | grep -qxF -- "$END42" || die "exercise/README.md: Done names no such line"
grep -qxF -- "$END42" exercise/solution/SOLUTION.md || die "SOLUTION.md: the measured run shows no such line"
for b in "$EA" "$EA2"; do has "$b" "  its log (.harness/mine/mvc/run.log): lines that name spring.threads.virtual.enable 0 · WARN lines 0 · ERROR lines 0 · Tomcat started 1 · TiffinBox listening 1" "exercise: Boot silent about the misspelt key"; done
has "$EB" "  its log (.harness/mine/mvc/run.log): lines that name spring.threads.virtual.enable 0 · WARN lines 0 · ERROR lines 0 · Tomcat started 1 · TiffinBox listening 1" "exercise B: its log"
x exercise '^  A.s frames against B.s: the frames that left 4 · the frames that came 1 · the rest, the same: 41$'
for f in java.lang.Thread.run 'org.apache.tomcat.util.threads.TaskThread$WrappingRunnable.run' 'org.apache.tomcat.util.threads.ThreadPoolExecutor$Worker.run' org.apache.tomcat.util.threads.ThreadPoolExecutor.runWorker; do has "$EB" "    left: $f" "exercise: $f left"; done
has "$EB" "    came: java.lang.VirtualThread.run" "exercise: VirtualThread.run came"
[ "$(grep -c '^  listening now: 19308 0 · 19309 0$' .r-exercise.out)" = 3 ] || die "exercise: both ports free after each run"
x exercise '^  the exercise.s own token \(26 random characters, its config tree.s\): in its log 0 times · in what it printed 0 times$'
echo "  exercise: the README as written -> 45, Thread.run, not a word from Boot about the key · the solution -> 42, VirtualThread.run (4 left, 1 came) · A' -> 45"
echo "  (this unit measures the last course's final tree, ../c5-unit27/after = ../c5-tiffinbox, and a copy of it; the course's anchor, ../c6-tiffinbox, is the embedded-Tomcat lesson's to change, and is not read here)" >&3
[ -z "$unpub" ] || die "no published hash for:$unpub - check the captures, then copy the md5s above into receipts.md5 and run again"
echo "c6-unit01: every capture 3/3 and = published; every spoken number asserted; 0 raw demo tokens in every capture and every log; every server on 127.0.0.1 alone; every JVM stopped by its process id"
