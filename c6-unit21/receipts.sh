#!/bin/bash
XPATH=$PATH                                           # the PATH you started this with: the exercise's own shell gets it
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25.0.4.1 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# Course 6 · SSE and Streaming Responses - this unit's receipts. No anchor change: anchor/ is the link to ../c6-unit16/after, the tree
# the problem-detail lesson froze (= c6-tiffinbox at Section 3's end, the tree the viewer last saw). This script copies that tree under
# .harness/anchor, builds it and runs it - as its README runs it, and on its class path with the course's harness joined
# (harness/probe/web, outside com.tiffinbox) - and shows an answer that keeps coming: a stream of server-sent events, read by curl, made
# by an emitter, and what ends it - the last event, a timeout with nothing sent, a timeout mid-stream, and a reader that leaves.
# Six captures, each run three times and hashed; cap() DIES when a hash differs from receipts.md5; every number the video says is
# asserted at the bottom by a check that can fail; the demo token is masked (gsub), and the checks count 0 raw copies of it in every
# capture, in the log of every run and in every file this unit ships.
#   events     the anchor built and extracted; the harness compiled; the seven on the jar; curl's own help for -N; a feed of three events
#              read by curl as it came (the headers, then the stream) - each event a customer from TiffinBox's own list, and its kitchen's
#              cooked count, beside the seven's own GET /customers and GET /kitchen
#   dispatch   the same feed with the filters lesson's hooks joined (a filter bean, a once-per-request filter, a filter registered for every
#              dispatch type, the interceptor): who runs on the REQUEST dispatch, on the clock's thread, and on the ASYNC dispatch; C
#              (labelled): beside them, a once-per-request filter whose ASYNC skip is turned off
#   timeout    A/B/A': Boot's own metadata for spring.mvc.async.; A, the key unset - read off Spring's environment, Tomcat's connector and
#              the request's own async context - and a feed with no events: its answer; B, the key at 2s for one run (an option): the
#              same three values read, the same answer; A', A again
#   committed  B's key, an endless feed: events, then the timeout - the client's end, the server's one WARN, its logger read off the jar
#              (javap) and its sentence found in Spring MVC's jar
#   gone       the key unset, an endless feed, curl leaving after 2 seconds (--max-time): curl's exit code, and what the server learns,
#              and when - at a send
#   exercise   exercise/README.md's commands, then exercise/solution/SOLUTION.md's, read from the files and run as written, one after
#              the other in ONE shell a viewer could have: env -i, /bin/bash, started in this folder
# "The anchor" is anchor/, the link to ../c6-unit16/after, COPIED under .harness/anchor; this script never writes into another unit's
# folder, and never builds a frozen tree in place. Every run of TiffinBox starts in .harness/anchor, which holds a config tree with a
# fake token (secrets/), as the README asks. Commands are printed exactly as they run: each goes through eval. "$CURLSET" is the
# comparison set since the secrets lesson (../c5-unit11/curlset.sh: the seven requests, POST /shutdown with the token's header read
# from the file). "$M2" is this unit's own repository, .m2-demo. The harness - harness/probe/web (compiled with -parameters): Feed (the
# feed: an SseEmitter, a platform thread's clock walking TiffinBox's own CustomerRepository and reading its own OrderQueue, every
# callback stopping the clock), Timeouts (the timeout key in Spring's environment, Tomcat's connector's async timeout, and a filter that
# reads the request's own), OnceAsync (a once-per-request filter that runs on the ASYNC dispatch) and, byte for byte, the filters
# lesson's Trace, Hooks, Interceptor, PlainFilter, OnceFilter, EveryFilter, EveryRegistration and ProbeOops - is the course's, never
# TiffinBox's: outside com.tiffinbox, joined by --spring.main.sources on the extracted jar's class path, and named on every capture
# that uses it; harness/keys.py reads a jar's configuration metadata (the upload lesson's, byte for byte); harness/shutdown.sh is POST
# /shutdown with the token read from its file (the filters lesson's, byte for byte). Every run passes options only. The seven run
# first, on a fresh JVM of the jar.
# The locale: the JVM ignores LC_ALL on macOS - it takes the Mac's first language - and Spring's, Jackson's and Tomcat's messages in
# the log and in the answers are written in the JVM's locale: so every JVM this script starts has its locale pinned on its run line
# (-Duser.language=en -Duser.country=US, before -jar or -cp: at() puts it there, README.md "The commands this unit adds"), and every
# harness JVM prints it (Feed), and the checks assert en_US.
# The network: every Maven build runs offline (-o) against .m2-demo and says so ("offline: yes"); a build that cannot resolve an
# artifact offline goes to Maven Central once, and says that ("offline: no - ..."). No native build, no Docker and no browser: this unit
# measures the JVM alone, with curl. At run time nothing leaves 127.0.0.1: TiffinBox listens there, every request goes there, and
# Logback writes to the terminal only.
# Masks and filters (README.md declares each; awk sub/gsub only): the demo token becomes "[masked: the N-character token]" (N its
# own length); this folder's absolute path "…", the folder above it "…/..", the home folder "~"; your user name "<user>" - in every
# line of every capture. Spring's error timestamp becomes "…" (both forms) in the seven and wherever an answer is printed. An answer's
# Date header keeps its name, its value becomes "…"; a header line loses its carriage return and its trailing space. A run's log lines
# are printed from their logger on (no time, no process id, no thread); Boot's first line is cut before " with PID". A WARN or ERROR
# record is printed as its level, logger and message, then the exception line under it; its stack frames are bounded ("over 40") and
# its other lines counted, never shown. The harness's lines are printed in the order they ran, numbered from 1 for each request (the
# JVM's running number is checked to rise, never shown); a thread's own number is "<n>" (the harness prints it so). A stream curl
# read is printed whole when it is bounded (three events); an endless one by its first event and checks on every event - never by how
# many came, which is timing (R.121), and no duration is captured: a timeout is read, never timed.
# Ports (brief ⚑1, 19500-19509): events - the seven 19500, the harness 19501 · dispatch 19502, C 19503 · timeout - A and A' 19504, B
# 19505 · committed 19506 · gone 19507 · the exercise 19509 (19508 unused). Captures run one after another, each JVM stopped before the
# next starts on its port. 18425 (TiffinBox's default), 8080 (Tomcat's) and 35729 (DevTools' Live Reload) are checked free too, and
# never bound.
set -e
# bash 5.2 and later turn an & in the replacement of ${x/pattern/replacement} into the matched text (patsub_replacement, on by
# default). Switched off, so /bin/bash 3.2 (./receipts.sh) and a newer bash (bash receipts.sh) run the same commands; 3.2 has no
# such option.
shopt -u patsub_replacement 2> /dev/null || true
# One locale for every tool, whatever yours is: sort's order, and what a program prints, follow it. The published captures were
# made with no locale set, which is the C locale. (The JVM ignores it on macOS: its locale is pinned per JVM, above.)
export LC_ALL=C
cd "$(dirname "$0")"
# One run at a time: two runs share .harness/ and the ports, and one would corrupt the other.
mkdir .r-lock 2> /dev/null || { echo "  *** another receipts.sh is running in this folder (.r-lock exists) - if none is, rmdir .r-lock ***"; exit 1; }
# On every exit - the end, a failed check, or Ctrl-C - stop the processes this script started in the background ($pid, a server;
# $xpid, the exercise's shell, with every process under it - its Maven, its JVM, its curl), if they still run, then sweep(): anything
# of this run still alive in its process group - a TiffinBox JVM, a Maven - is stopped. After an interrupt, a capture's unfinished
# runs (.r-NAME.1-3) go too; after a failed check they stay, for the diff the message names. The clean-up ignores a second Ctrl-C,
# and nothing in it can fail under set -e, so it always reaches the rmdir; the script still exits 130 after an interrupt (README.md,
# "Interrupted"). $pid and $xpid are cleared whenever their process has been reaped. sweep() kills only processes of this run's own
# process group - start each run in a group of its own (README.md, "Interrupted"). No wait in this script is bare: each names its pid.
pid=""; xpid=""
sweep() { local g i l
  g=$(ps -o pgid= -p $$ 2> /dev/null | tr -d ' ') || g=""
  [ -n "$g" ] || return 0
  i=0; while [ $i -lt 20 ]; do
    l=$(ps -axo pid=,pgid=,command= 2> /dev/null | awk -v g="$g" -v me=$$ '
      $2 == g && $1 != me && $3 != "awk" && $3 != "ps" && (index($0, "tiffinbox-web-1.0.0.jar") || index($0, "com.tiffinbox.web.TiffinBoxServer") || index($0, "org.codehaus.plexus.classworlds.launcher.Launcher")) { print $1 }' | paste -sd' ' -) || l=""
    [ -n "$l" ] || return 0
    if [ $i -lt 10 ]; then kill $l 2> /dev/null || true; else kill -9 $l 2> /dev/null || true; fi
    sleep 0.5; i=$((i + 1)); done; }
# desc PID: every process under PID - its children, theirs, and so on (ps, by parent); killtree PID: PID and all of them, TERM
desc() { ps -axo pid=,ppid= 2> /dev/null | awk -v r="$1" '{ p[$1] = $2 } END { n = 1; q[1] = r; for (i = 1; i <= n; i++) for (c in p) if (p[c] == q[i]) { q[++n] = c; print c } }'; }
killtree() { local d; d=$(desc "$1"); kill "$1" $d 2> /dev/null || true; }
trap 'trap "" INT TERM; [ -z "$xpid" ] || killtree "$xpid"; for p in "$pid" "$xpid"; do if [ -n "$p" ] && kill "$p" 2> /dev/null; then wait "$p" 2> /dev/null || true; fi; done; sweep || true; [ -z "$INTR" ] || rm -f .r-*.[123]; rmdir .r-lock 2> /dev/null || true' EXIT
INTR=""; trap 'INTR=1; exit 130' INT TERM
exec 3>&1                                            # die() speaks to the terminal even inside a redirected capture
die() { echo "  *** $* ***" >&3; exit 1; }
java -version 2>&1 | grep -q 'version "25' || die "JDK 25 needed; JAVA_HOME gives: $(java -version 2>&1 | head -1)"
for t in python3 curl rsync lsof unzip javac mvn cmp; do command -v $t > /dev/null || die "$t is needed"; done
# A variable of yours must not become a property source, a JVM flag or a build setting: every TIFFINBOX_*, SPRING_*, MANAGEMENT_*,
# SERVER_* and LOGGING_* variable, DEBUG (Boot reads it as --debug), the variables that inject JVM flags, MAVEN_OPTS, MAVEN_ARGS and
# NATIVE_IMAGE_OPTIONS are removed first (the last course's failure lesson's loop, verbatim: sed -E, a canary planted under every
# name first, and the run stops if one survives). This unit runs no Docker, so COMPOSE_* is not in the list. (A
# SPRING_MVC_ASYNC_REQUEST_TIMEOUT of yours would set the very timeout this unit reads as unset; a JAVA_TOOL_OPTIONS could set every
# JVM's locale.)
for v in TIFFINBOX_CANARY SPRING_CANARY MANAGEMENT_CANARY SERVER_CANARY LOGGING_CANARY DEBUG JAVA_TOOL_OPTIONS JDK_JAVA_OPTIONS _JAVA_OPTIONS MAVEN_OPTS MAVEN_ARGS NATIVE_IMAGE_OPTIONS; do export "$v=planted-canary"; done
for v in $(env | sed -n -E 's/^(TIFFINBOX_[A-Za-z0-9_]*|SPRING_[A-Za-z0-9_]*|MANAGEMENT_[A-Za-z0-9_]*|SERVER_[A-Za-z0-9_]*|LOGGING_[A-Za-z0-9_]*|DEBUG|JAVA_TOOL_OPTIONS|JDK_JAVA_OPTIONS|_JAVA_OPTIONS|MAVEN_OPTS|MAVEN_ARGS|NATIVE_IMAGE_OPTIONS)=.*/\1/p'); do unset "$v"; done
[ -z "$(env | grep -- '=planted-canary$')" ] || die "a variable survived the clean-up above: $(env | grep -- '=planted-canary$' | sed 's/=.*//' | paste -sd' ' -)"
# Every request this script makes goes to 127.0.0.1: an HTTP proxy named in your environment would carry curl's requests to that
# proxy instead - 127.0.0.1 and localhost go first in no_proxy and NO_PROXY.
export no_proxy="127.0.0.1,localhost${no_proxy:+,$no_proxy}" NO_PROXY="127.0.0.1,localhost${NO_PROXY:+,$NO_PROXY}"
[ -e secrets ] && die "this folder holds a secrets/ - remove it: every run here starts in a folder under .harness/"
[ -L anchor ] && [ "$(readlink anchor)" = ../c6-unit16/after ] || die "anchor must be the link to ../c6-unit16/after - this unit changes nothing in the anchor"
[ -f anchor/pom.xml ] && [ -f anchor/README.md ] && [ -f anchor/tiffinbox-web/pom.xml ] || die "the anchor (its pom.xml, README.md or web module's pom.xml) is missing"
[ -e anchor/secrets ] || [ -e anchor/target ] || [ -e anchor/tiffinbox-web/target ] || [ -e anchor/tiffinbox-core/target ] || [ -e anchor/tiffinbox-local.yaml ] && die "anchor/ holds a secrets/, a target/ or a tiffinbox-local.yaml - it is a frozen copy, never built in place"
M2="$PWD/.m2-demo"; U="$PWD"; UP="$(cd .. && pwd)"; ME="$(id -un)"
TF=secrets/tiffinbox/shutdown-token                  # the config tree's file for tiffinbox.shutdown-token
# The demo token. FAKE, and meant to look it: it guards nothing but a demo server on 127.0.0.1 that every capture stops. It is
# written into .harness/anchor/secrets/ (git-ignored) when this script runs, and no capture prints it: see mask().
TOKEN=demo-token-for-a-feed-that-ends
[ ${#TOKEN} = 31 ] || die "the demo token must be 31 characters: the published captures name its length"
CURLSET=../c5-unit11/curlset.sh                      # the comparison set: the seven requests, POST /shutdown with the header
[ -f "$CURLSET" ] || die "$CURLSET is missing"
HWS='harness/probe/web/EveryFilter.java harness/probe/web/EveryRegistration.java harness/probe/web/Feed.java harness/probe/web/Hooks.java harness/probe/web/Interceptor.java harness/probe/web/OnceAsync.java harness/probe/web/OnceFilter.java harness/probe/web/PlainFilter.java harness/probe/web/ProbeOops.java harness/probe/web/Timeouts.java harness/probe/web/Trace.java'
for f in harness/shutdown.sh harness/keys.py $HWS exercise/README.md exercise/KitchenFeed.java exercise/solution/SOLUTION.md README.md; do [ -f "$f" ] || die "$f is missing"; done
[ "$(ls harness/probe/web | paste -sd' ' -)" = 'EveryFilter.java EveryRegistration.java Feed.java Hooks.java Interceptor.java OnceAsync.java OnceFilter.java PlainFilter.java ProbeOops.java Timeouts.java Trace.java' ] || die "harness/probe/web holds another file: javac compiles all of it"
[ "$(ls exercise/solution | paste -sd' ' -)" = 'SOLUTION.md' ] || die "exercise/solution holds another file: the solution is a query, not a class"
# The filters lesson's hooks, byte for byte - what it measured is what runs here
for c in Trace Hooks Interceptor PlainFilter OnceFilter EveryFilter EveryRegistration ProbeOops; do
  cmp -s harness/probe/web/$c.java ../c6-unit18/harness/probe/web/$c.java || die "harness/probe/web/$c.java must be the filters lesson's, byte for byte"; done
cmp -s harness/shutdown.sh ../c6-unit18/harness/shutdown.sh || die "harness/shutdown.sh must be the filters lesson's, byte for byte"
cmp -s harness/keys.py ../c6-unit20/harness/keys.py || die "harness/keys.py must be the upload lesson's, byte for byte"

# The ports, BEFORE anything is wiped (a survivor of an interrupted run answers POST /shutdown only with its token, which lives in
# .harness/ - so the message names the process to kill).
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
for p in 18425 8080 35729 19500 19501 19502 19503 19504 19505 19506 19507 19508 19509; do
  [ "$(listeners $p)" = 0 ] || die "something already listens on $p - this unit's ports must be free; if it is a TiffinBox an interrupted run left behind, stop it: kill $(lsof -nP -iTCP:$p -sTCP:LISTEN -t 2> /dev/null | paste -sd' ' -)"; done

# ---- the commands: read from anchor/README.md, the anchor's own, and asserted - each line must be there, whole ---------------
readme() { grep -m1 -xF -- "$1" anchor/README.md > /dev/null || die "anchor/README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
J='java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431'
CPL='"tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431'
R_PLAIN=$(readme 'mvn -B package')
R_RUN=$(readme "$J")
R_EXTRACT=$(readme 'java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted')
R_CP=$(readme "java -cp $CPL")
R_READY=$(readme "curl -s -w ' %{http_code}\n' http://127.0.0.1:18431/actuator/health/readiness")
R_PD=$(readme "curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' http://127.0.0.1:18431/customers/Nobody")
WT=" -w ' %{http_code} · Content-Type: [%{content_type}]\n'"
[ "${R_PD#curl -s}" = "$WT http://127.0.0.1:18431/customers/Nobody" ] || die "the anchor's Content-Type line"
# This unit's own lines (README.md, "The commands this unit adds") - each asserted to be exactly that: the anchor's run and class-path
# lines with the JVM's locale pinned; the class-path line with Boot's timeout key for Spring MVC; the harness's javac line; the metadata reader;
# javap on Boot's handler; the sentence counted in Spring MVC's jar; curl's own help for -N; the stream read as it comes, headers first
# (-N -D -); the anchor's Content-Type line with -N, the headers and the body saved to files, a bound on curl's time, at the feed
mine() { grep -m1 -xF -- "$1" README.md > /dev/null || die "README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
JL='-Duser.language=en -Duser.country=US'
LIBD=.harness/anchor/tiffinbox-web/target/extracted/lib
L_RUNL=$(mine "java $JL -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431")
L_CPL=$(mine "java $JL -cp $CPL")
L_B=$(mine "$L_CPL --spring.mvc.async.request-timeout=2s")
L_JAVAC=$(mine "javac -parameters -d .harness/hc -cp \"$LIBD/*\" $HWS")
L_KEYS=$(mine "python3 harness/keys.py $LIBD/spring-boot-webmvc-4.1.1.jar spring.mvc.async.")
L_JAVAP=$(mine "javap -cp $LIBD/spring-boot-webmvc-4.1.1.jar org.springframework.boot.webmvc.autoconfigure.ProblemDetailsExceptionHandler")
L_SENT=$(mine "unzip -p $LIBD/spring-webmvc-7.0.9.jar org/springframework/web/servlet/mvc/method/annotation/ResponseEntityExceptionHandler.class | grep -ac 'Response already committed. Ignoring'")
L_HELP=$(mine "curl --help all | grep -e '--no-buffer'")
L_SSE=$(mine "curl -s -N -D - 'http://127.0.0.1:18431/probe/feed?orders=3'")
L_GET=$(mine "curl -s -N -D .harness/head.txt -o .harness/body.txt$WT --max-time 60 'http://127.0.0.1:18431/probe/feed?orders=0'")
# The derivations, each asserted
P_='java '; Q_="java $JL "; r=${R_RUN/"$P_"/$Q_}; r2=${R_CP/"$P_"/$Q_}
[ "$r" = "$L_RUNL" ] && [ "$r2" = "$L_CPL" ] || die "the pinned lines must be the anchor's run and class-path lines with $JL after java, and nothing else"
O_B=${L_B#"$L_CPL "}; [ "$O_B" = '--spring.mvc.async.request-timeout=2s' ] || die "the B line must be the pinned class-path line with Boot's timeout key for Spring MVC, and nothing else"
[ "${L_JAVAC#* -cp \"*\" }" = "$HWS" ] || die "the harness's javac line must compile the eleven files in harness/probe/web, and nothing else"
P_='curl -s '; Q_='curl -s -N -D .harness/head.txt -o .harness/body.txt '; r=${R_PD/"$P_"/$Q_}; P_=' http://127.0.0.1:18431/customers/Nobody'; Q_=" --max-time 60 'http://127.0.0.1:18431/probe/feed?orders=0'"; r=${r/"$P_"/$Q_}
[ "$r" = "$L_GET" ] || die "the saved-answer line must be the anchor's Content-Type line with -N, -D and -o, a bound on curl's time and the feed, and nothing else"
# off DIR 'README mvn LINE' [PHASE]: the README's Maven line as this script runs it - from DIR, offline (-o), this unit's own
# repository, and for a build phase (package) clean and without tests. dev() takes those four things back out, and must give the
# README's line again: so the command on screen is the README's, with exactly those changes.
off() { local c=${2/mvn -B /mvn -o -B -Dmaven.repo.local=\"\$M2\" }
  [ -n "$3" ] && c=${c/ $3/ -DskipTests clean $3}
  printf 'cd %s && %s\n' "$1" "$c"; }
dev() { local c=${1#cd * && }; c=${c/ -o -B -Dmaven.repo.local=\"\$M2\" / -B }; c=${c/ -DskipTests clean / }; printf '%s\n' "$c"; }
# at DIR PORT 'README LINE': the README's line run from DIR, its port 18431 made PORT - and a java line with the JVM's locale pinned
# right after "java" (this unit's pinned lines show the form, and at() must give them back)
at() { local l=${3/--tiffinbox.port=18431/--tiffinbox.port=$2}; case $l in 'java -Djarmode=tools '*) ;; 'java '*) l="java $JL ${l#java }" ;; esac; printf 'cd %s && %s\n' "$1" "$l"; }
# hcp DIR PORT CLASSES ['OPTIONS']: the README's class-path line - the extracted jar, TiffinBox's own main - from DIR, its port made
# PORT, the harness's classes added to the class path (../hc) and CLASSES joined (--spring.main.sources=); OPTIONS after
hcp() { local c; c=$(at "$1" "$2" "$R_CP"); c=${c/lib\/\*\"/lib\/*:..\/hc\"}; printf '%s --spring.main.sources=%s%s\n' "$c" "$3" "${4:+ $4}"; }
# url 'curl LINE' PORT: the line, its port 18431 made PORT
url() { printf '%s\n' "${1/:18431\//:$2/}"; }
# sq PORT: this unit's stream line, its port PORT
sq() { url "$L_SSE" "$1"; }
# gq PORT ORDERS [SECONDS]: this unit's saved-answer line, its port PORT, orders=ORDERS, curl's bound SECONDS (60 unless named)
gq() { local c; c=$(url "$L_GET" "$1"); c=${c/orders=0/orders=$2}; [ -z "${3:-}" ] || c=${c/--max-time 60/--max-time $3}; printf '%s\n' "$c"; }
# exe 'COMMAND': the command with "exec" after its "cd DIR && " - so $pid is the program's
exe() { printf '%s\n' "$1" | sed -E 's/&& (([A-Z_]+=[^ ]* )*)/\&\& \1exec /'; }
C_PRE=$(off .harness/pre "$R_PLAIN" package)
[ "$(dev "$C_PRE")" = "$R_PLAIN" ] || die "not the README's build line with the offline changes: $C_PRE"
[ "$(exe "$(at .harness/x 19500 "$R_RUN")")" = "cd .harness/x && exec ${L_RUNL/18431/19500}" ] && [ "$(at .harness/x 18431 "$R_CP")" = "cd .harness/x && $L_CPL" ] && [ "$(at .harness/x 18431 "$R_EXTRACT")" = "cd .harness/x && $R_EXTRACT" ] || die "at(): the pinned lines are not README.md's"
[ "$(hcp .harness/x 19505 probe.web.Feed "$O_B")" = 'cd .harness/x && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19505 --spring.main.sources=probe.web.Feed --spring.mvc.async.request-timeout=2s' ] || die "hcp()"
[ "$(sq 18431)" = "$L_SSE" ] && [ "$(gq 18431 0)" = "$L_GET" ] && [ "$(gq 19507 -1 2)" = "curl -s -N -D .harness/head.txt -o .harness/body.txt$WT --max-time 2 'http://127.0.0.1:19507/probe/feed?orders=-1'" ] || die "sq() or gq()"
echo "  the commands: anchor/README.md gives the 6 lines this script runs or derives from; README.md the 10 this unit adds"

# ---- build: before the captures - the anchor built once (on a fresh clone this fills .m2-demo); what .m2-demo holds ---------------
rm -rf .harness; mkdir -p .harness
# mbuild 'COMMAND' LOG LABEL: the command, run as printed (eval), its log kept in LOG (never printed whole); Maven Central only if the
# offline build could not resolve something - and the line says which (offline: yes / no), so a run that went online is never
# silent (inside a capture, "no" changes the capture's hash: cap() then dies).
mbuild() { local how=yes ec=0 c=$1
  (eval "$c") > "$2" 2>&1 < /dev/null || ec=$?
  if [ $ec != 0 ] && grep -qE 'offline mode|Could not resolve|could not be resolved|Cannot access|No plugin found for prefix' "$2"; then
    how="no - the offline build could not resolve an artifact, so Maven Central was asked"; ec=0
    (eval "${c/mvn -o -B /mvn -B }") > "$2" 2>&1 < /dev/null || ec=$?; fi
  [ $ec = 0 ] || { tail -30 "$2" >&3
    ! grep -qE 'Could not resolve|could not be resolved|Could not transfer|Cannot access' "$2" || die "build failed: $3 - Maven could resolve Boot's parent and plugins neither from .m2-demo nor from Maven Central: a fresh clone's first run needs the network once, to fill .m2-demo"
    die "build failed: $3"; }
  echo "  built $3 · offline: $how · exit $ec"; }
# tree FOLDER: a config tree in FOLDER/secrets holding one file, the demo token and a newline, readable by its owner alone
tree() { mkdir -p "$1/secrets/tiffinbox"; (umask 077 && printf '%s\n' "$TOKEN" > "$1/$TF"); chmod 700 "$1/secrets" "$1/secrets/tiffinbox"; }
copy() { rm -rf "$2" "$2".*; rsync -a --exclude target --exclude secrets "$1/" "$2/"; tree "$2"; }
rsync -a --exclude target --exclude secrets anchor/ .harness/pre/
mbuild "$C_PRE" .harness/build-pre.log ".harness/pre (the anchor)"
[ -f "$M2/org/springframework/boot/spring-boot-starter-webmvc/4.1.1/spring-boot-starter-webmvc-4.1.1.jar" ] || die "Spring MVC's starter is not in .m2-demo after the first build"
echo "  .m2-demo holds Spring MVC's starter"


# ---- helpers ------------------------------------------------------------------------------------------------------------
# raw TOKEN FILE...: how many times TOKEN appears, raw, in the files (occurrences, not lines; binary files read as text)
raw() { local t=$1; shift; cat "$@" | LC_ALL=C grep -aoF -- "$t" | wc -l | tr -d ' '; }
LOGS=0; LASTE=""                                     # logs counted: served runs
first() { grep -m1 -E ' : Starting |^main Starting ' "$1" | sed 's/^.* : //; s/^main //; s/ with PID .*$//'; }
start() { echo "\$ $1"; (eval "$(exe "$1")") > .harness/run.out 2> .harness/run.err < /dev/null & pid=$!; }
# addrs: the addresses the process $pid listens on, read off the process (lsof, by pid - its command name is never printed)
addrs() { lsof -nP -a -p "$pid" -iTCP -sTCP:LISTEN 2> /dev/null | awk 'NR > 1 { print $9 }' | sort -u | paste -sd' ' -; }
# listening [PORT]: addrs, polled until the process listens (on PORT, when given) - every 0.25 s, up to 120 s
listening() { local a="" i=0
  while [ $i -lt 480 ]; do
    a=$(addrs); if [ -n "$1" ]; then case " $a " in *":$1 "*) break ;; esac; elif [ -n "$a" ]; then break; fi
    kill -0 "$pid" 2> /dev/null || break; sleep 0.25; i=$((i + 1)); done
  echo "${a:-nothing}"; }
# lb ADDRESSES: yes when every one is 127.0.0.1:<port> - the check R.78 asks for, on the address read off the process
lb() { local a n=0; for a in $1; do n=$((n + 1)); case $a in 127.0.0.1:*) ;; *) echo no; return ;; esac; done; [ $n -gt 0 ] && echo yes || echo no; }
up() { local l; l=$(listening "$1"); [ "$l" != nothing ] || { tail -20 .harness/run.out >&3; die "it never listened"; }
  case " $l " in *':8080 '*|*':35729 '*) kill -9 "$pid" 2> /dev/null || true; die "it listened on 8080 or 35729 - never bound by this script";; esac
  echo "  listens on: $l · loopback only: $(lb "$l")"; echo "  Boot's first line: $(first .harness/run.out)"; }
# ready PORT: readiness asked until it answers 200 - every 0.25 s, up to 120 s, not printed - then the README's readiness line,
# printed and run once. No assertion before it (R.41, R.75). A JVM ($pid) that exits first stops the run.
ready() { local i=0 c=""
  while [ $i -lt 480 ]; do c=$(curl -s -o /dev/null -w '%{http_code}' "http://127.0.0.1:$1/actuator/health/readiness" 2> /dev/null || true); [ "$c" = 200 ] && break
    kill -0 "$pid" 2> /dev/null || { tail -20 .harness/run.out >&3; die "it exited before readiness answered 200"; }
    sleep 0.25; i=$((i + 1)); done
  [ "$c" = 200 ] || die "readiness never answered 200 on $1"
  local r; r=$(url "$R_READY" "$1"); echo "\$ $r"; (eval "$r") 2>&1 < /dev/null | sed 's/^/  /'; }
# logtok: the demo token 0 times in the last run's log, and the header's name 0 times
logtok() { local t h; t=$(raw "$TOKEN" .harness/run.out .harness/run.err); h=$(cat .harness/run.out .harness/run.err | LC_ALL=C grep -aoi -- 'x-shutdown-token' | wc -l | tr -d ' ')
  LOGS=$((LOGS + 1)); [ "$t" = 0 ] && [ "$h" = 0 ] || die "a log held the demo token ($t) or its header's name ($h)"
  echo "  its log: the demo token 0 times · X-Shutdown-Token $h times"; }
# tsmask: Spring's error timestamp, both forms (an ISO-8601 string, epoch milliseconds), becomes "…" (README.md, Masks)
tsmask() { awk '{ gsub(/"timestamp":"[^"]*"/, "\"timestamp\":\"…\""); gsub(/"timestamp":[0-9]+/, "\"timestamp\":…"); print }'; }
# exited PORT: after a POST /shutdown - the JVM must leave within 15 s, the port must be free; its exit code
exited() { local i=0 e=0
  while kill -0 "$pid" 2> /dev/null && [ $i -lt 60 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$pid" 2> /dev/null && { kill "$pid"; die "the server on $1 was still running 15 s after POST /shutdown"; }
  wait "$pid" || e=$?; pid=""; LASTE=$e
  [ "$(listeners "$1")" = 0 ] || die "something still listens on $1"; }
# seven PORT DIR: the comparison set's seven requests (POST /shutdown carries the header, read from DIR's token file), the POST
# line printed; the JVM must leave within 15 s of them, the port must be free; its exit code; the md5 of the seven after the
# timestamp mask and how many lines the mask changed; the log counted (logtok) - the masked set kept as .harness/seven-PORT.txt
seven() { local m
  echo "\$ \$CURLSET $1 $2/$TF"
  "$CURLSET" "$1" "$2/$TF" | grep ' -> ' > .harness/responses.txt || true
  tsmask < .harness/responses.txt > .harness/responses.m.txt
  grep '^POST ' .harness/responses.m.txt | sed 's/^/  /' || echo "  (no POST line)"
  exited "$1"
  m=$(diff .harness/responses.txt .harness/responses.m.txt | grep -c '^<' || true)
  echo "  exit $LASTE · the seven responses: $(wc -l < .harness/responses.m.txt | tr -d ' ') lines · lines the timestamp mask changed: $m · md5 $(md5 -q .harness/responses.m.txt)"
  cp .harness/responses.m.txt ".harness/seven-$1.txt"
  logtok; }
# post PORT DIR: POST /shutdown with DIR's token (harness/shutdown.sh) - its answer, its Content-Length header, the timestamp masked
post() { echo "\$ harness/shutdown.sh $1 $2/$TF"; harness/shutdown.sh "$1" "$2/$TF" | tsmask | sed 's/^/  /'; }
# stop PORT DIR: POST /shutdown with DIR's token; the JVM must leave, the port must be free; its exit code; its log counted (logtok)
stop() { post "$1" "$2"; exited "$1"; echo "  exit $LASTE · listening on $1 now: 0"; logtok; }
mask() { awk -v t="$TOKEN" -v u="$U" -v up="$UP" -v hm="$HOME" -v me="$ME" -v tl="${#TOKEN}" '
  function lit(x) { gsub(/[][\\.^$*+?(){}|\/]/, "\\\\&", x); return x }
  function enc(x) { gsub(/ /, "%20", x); return x }
  BEGIN { T = lit(t); P = lit(u); Q = lit(up); H = lit(hm); PE = lit(enc(u)); QE = lit(enc(up)); M = "(^|[^A-Za-z0-9_])" lit(me) "([^A-Za-z0-9_]|$)" }
  { gsub(T, "[masked: the " tl "-character token]"); gsub(P, "…"); gsub(PE, "…")
    gsub(Q, "…/.."); gsub(QE, "…/.."); gsub(H, "~"); gsub(/\$\$SpringCGLIB\$\$[0-9]+/, "$$SpringCGLIB$$<n>")
    if (match($0, /java\.io\.IOException: /)) { pre = substr($0, 1, RSTART + RLENGTH - 1); post = substr($0, RSTART + RLENGTH); i = index(post, " - ")
      $0 = pre "<the OS'"'"'s words>" (i ? substr(post, i) : "") }
    while (match($0, M)) { pre = substr($0, 1, RSTART - 1); s = substr($0, RSTART, RLENGTH); post = substr($0, RSTART + RLENGTH)
      sub(lit(me), "<user>", s); $0 = pre s post }
    print }'; }

unpub=""
cap() { local nm=$1 h pub i; shift
  for i in 1 2 3; do "$@" > .harness/cap.raw 2>&1 || true; [ -z "$pid" ] && [ -z "$xpid" ] || die "$nm left a process running"
    raw "$TOKEN" .harness/cap.raw > ".harness/raw-$nm.$i"; mask < .harness/cap.raw > ".r-$nm.$i"; done
  h=$(md5 -q ".r-$nm.1")
  [ "$h" = "$(md5 -q ".r-$nm.2")" ] && [ "$h" = "$(md5 -q ".r-$nm.3")" ] || die "$nm drifts across three runs (diff .r-$nm.1 .r-$nm.2 .r-$nm.3)"
  mv ".r-$nm.1" ".r-$nm.out"; rm -f ".r-$nm.2" ".r-$nm.3"
  pub=$(awk -v n="$nm" '$1 == n { print $2 }' receipts.md5 2> /dev/null || true)
  if [ -z "$pub" ]; then printf '  %-9s md5 %s  3/3  (no published hash)\n' "$nm" "$h"; unpub="$unpub $nm"
  elif [ "$pub" = "$h" ]; then printf '  %-9s md5 %s  3/3  = published\n' "$nm" "$h"
  else printf '  %-9s md5 %s  3/3  DIFFERS from the published %s\n' "$nm" "$h" "$pub"
    die "$nm is not the published capture - suspect another JDK, Boot, Maven or curl, a busy machine, a busy port, a variable of yours, or an edited source; diff .r-$nm.out against its block in README.md"; fi; }
pbuild() { local c; c=$(off "$1" "$R_PLAIN" package); echo "\$ $c"; mbuild "$c" "$1.build.log" "$2"; }
extract() { local c="cd $1 && $R_EXTRACT"; echo "\$ $c"; (eval "$c") > .harness/extract.log 2>&1 < /dev/null || die "the README's extract line failed in $1"; echo "  exit 0"; }
# settle: the log stops growing (the same length twice, 0.5 s apart; up to 15 s) - a request's last line is written just after
# its answer leaves
settle() { local i=0 a b=-1; while [ $i -lt 30 ]; do a=$(wc -l < .harness/run.out | tr -d ' '); [ "$a" = "$b" ] && return 0; b=$a; sleep 0.5; i=$((i + 1)); done; die "the log never settled"; }
mark() { settle; wc -l < .harness/run.out | tr -d ' '; }
# logl FROM [LEVELS]: the run's lines after line FROM at those levels (WARN|ERROR unless named), from their level and logger on
logl() { awk -v from="$1" -v lv="${2:-WARN|ERROR}" 'NR > from && $0 ~ (" (" lv ") [0-9]+ --- \\[") { l = $2; s = $0; i = index(s, " --- ["); s = substr(s, i + 6); i = index(s, "] "); s = substr(s, i + 2)
    i = index(s, " : "); lg = substr(s, 1, i - 1); sub(/ +$/, "", lg); msg = substr(s, i + 3)
    gsub(/@[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]+/, "@…", msg); print "    " l " " lg ": " msg }' .harness/run.out; }
# recs FROM: each WARN or ERROR record the log gained after line FROM (the harness's lines skipped) - its level, its logger and its
# message; then the exception line under it (the first line after the record that is neither blank nor a stack frame); its stack
# frames, bounded ("over 40"), and its other lines, counted - none shown
recs() { awk -v from="$1" '
  function out() { if (inr) print "      its stack frames: " (fr > 40 ? "over 40" : fr + 0) ", its other lines: " (ot + 0) " - none shown"; inr = 0; fr = 0; ot = 0; ex = 0 }
  NR <= from { next }
  /^HOOK [0-9]+ / { next }
  / [A-Z]+ [0-9]+ --- \[/ { out() }
  / (WARN|ERROR) [0-9]+ --- \[/ { s = $0; i = index(s, " --- ["); s = substr(s, i + 6); i = index(s, "] "); s = substr(s, i + 2)
    i = index(s, " : "); lg = substr(s, 1, i - 1); sub(/ +$/, "", lg); m = substr(s, i + 3); gsub(/@[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]+/, "@…", m)
    print "    " $2 " " lg ": " m; inr = 1; ex = 1; next }
  inr && /^\tat / { fr++; next }
  inr && ex && NF > 0 { print "      " $0; ex = 0; next }
  inr { ot++ }
  END { out() }' .harness/run.out; }
# pagef: a curl answer through its filter - any HTML page as its <h1> and its length, never shown (none is expected here); curl's
# status line after it; a JSON answer - a problem detail too - as it came, its error timestamp masked
pagef() { python3 -c '
import re, sys
for l in sys.stdin.read().splitlines():
    if l.startswith("<html>") or l.lower().startswith("<!doctype html"):
        h = re.search(r"<h1>(.*?)</h1>", l)
        tail = l[l.index("</html>") + len("</html>"):] if "</html>" in l else ""
        print("  an HTML page - its <h1>: %s · %d characters, not shown%s" % (h.group(1) if h else "none", len(l) - len(tail), " · then curl'"'"'s:" + tail if tail else ""))
    else:
        print("  " + re.sub(r"\"timestamp\":[0-9]+", "\"timestamp\":…", re.sub(r"\"timestamp\":\"[^\"]*\"", "\"timestamp\":\"…\"", l)))'; }
WARNS() { settle; echo "  WARN lines in this run's log, at Boot's default level: $(logl 0 WARN | grep -c . || true) · ERROR lines: $(logl 0 ERROR | grep -c . || true)"; }
# The level counts, the record filter, the harness-line filter, the header filter, the stream filter and the event check, checked on
# planted inputs before any capture (R.65, R.120): a harness line that names the ERROR dispatch, one WARN and one ERROR record - each
# count must be 1 by the log's own line shape, where a bare ' ERROR ' counts 2; a falling running number stops the run; a header file's
# carriage returns, trailing spaces and Date come out as declared; a planted stream's events are judged whole, cut, out of order or
# with a stranger in them
lvl() { grep -cE "^[0-9]{4}-[0-9]{2}-[0-9]{2}T[^ ]+ +$1 " "$2" || true; }
# The harness's lines (Trace): HOOK, the JVM's running number, then what ran. hk FROM: the harness's lines the log gained after line
# FROM, in the order they printed, numbered from 1 - the running number must rise line by line (checked, never shown)
hk() { local o; o=$(awk -v from="$1" 'NR > from && /^HOOK [0-9]+ / { n = $2 + 0; if (k && n <= last) bad = 1; last = n; s = $0; sub(/^HOOK [0-9]+ /, "", s); l[++k] = s }
    END { if (bad) exit 3; print "  the harness'"'"'s lines it printed, in order: " (k + 0); for (i = 1; i <= k; i++) printf "    %2d %s\n", i, l[i] }' .harness/run.out) || die "the harness's lines after line $1 are out of order"
  printf '%s\n' "$o"; }
# counted FROM: the WARN and ERROR lines the log gained after line FROM, as " · WARN lines it added: N · ERROR lines: M"
counted() { local w e; settle; w=$(logl "$1" WARN | grep -c . || true); e=$(logl "$1" ERROR | grep -c . || true); printf ' · WARN lines it added: %s · ERROR lines: %s' "$w" "$e"; }
# hdrs FILE: the headers curl saved (-D), as they came - each line without its carriage return and trailing space, Date's value "…" -
# counted; then whether the answer had a Content-Length and a Transfer-Encoding
hdrs() { local n; [ -f "$1" ] || { echo "  the headers curl saved: none - curl wrote no header file (no header came)"; return 0; }; n=$(tr -d '\r' < "$1" | grep -c . || true)
  echo "  the headers curl saved, as they came: $n lines, the status line first (Date's value masked):"
  tr -d '\r' < "$1" | grep . | sed -E 's/ +$//; s/^(Date|date): .*/\1: …/; s/^/    /'
  echo "  Content-Length: $(tr -d '\r' < "$1" | awk -F': ' 'tolower($1) == "content-length" { print $2; f = 1 } END { if (!f) print "none" }') · Transfer-Encoding: $(tr -d '\r' < "$1" | awk -F': ' 'tolower($1) == "transfer-encoding" { print $2; f = 1 } END { if (!f) print "none" }')"; }
# strm FILE: what curl printed with -D - (the headers, a blank line, then the stream), as it came: counted, each line without its
# carriage return and trailing space, Date's value "…", every line after a "|" (a blank line is "|" alone)
strm() { echo "  what curl printed, as it came: $(wc -l < "$1" | tr -d ' ') lines, the headers first (each line's carriage return and trailing space dropped, Date's value masked):"
  tr -d '\r' < "$1" | sed -E 's/ +$//; s/^(Date|date): .*/\1: …/' | awk '{ print "    |" ($0 == "" ? "" : " " $0) }'; }
# evs FILE MODE: a stream's events, judged against the anchor's own data as the seven read it (.harness/seven-19500.txt: GET
# /customers, GET /kitchen) - every event whole (id, event, data, then a blank line), the ids from 1 in order, each event's customer
# the next in the anchor's list, its meals a day the anchor's, its kitchen count the anchor's; whether the last line is blank (the
# stream ended between two events). MODE whole: how many, then every line; MODE first: never how many (timing, R.121), the first
# event's lines only
evs() { python3 - "$1" "$2" .harness/seven-19500.txt <<'PY'
import json, re, sys
f, mode, seven = sys.argv[1:4]
cust = kit = None
for l in open(seven, encoding="utf-8"):
    m = re.match(r"GET +(/\S+) +-> \d+ \S+ +(.*)$", l.rstrip("\n"))
    if m and m.group(1) == "/customers": cust = json.loads(m.group(2))
    if m and m.group(1) == "/kitchen": kit = json.loads(m.group(2))["ordersCooked"]
b = open(f, encoding="utf-8").read()
blocks = b.split("\n\n")
tail = blocks.pop()                      # what follows the last blank line: "" when the stream ended between events
ok = bool(blocks) and cust is not None and kit is not None
for i, blk in enumerate(blocks, 1):
    ls = blk.split("\n")
    if len(ls) != 3 or ls[0] != "id:%d" % i or ls[1] != "event:order" or not ls[2].startswith("data:"):
        ok = False; break
    try:
        d = json.loads(ls[2][5:])
    except ValueError:
        ok = False; break
    c = cust[(i - 1) % len(cust)]
    if d != {"order": i, "customer": c["name"], "mealsPerDay": c["mealsPerDay"], "kitchenCooked": kit}:
        ok = False; break
yes = "yes" if ok else "no"
last = "yes" if tail == "" and b.endswith("\n\n") else "no"
what = "every one whole (id, event, data, then a blank line), the ids from 1 in order, each event's customer the next in the anchor's list with the anchor's meals a day, its kitchen count the anchor's"
if mode == "whole":
    print("  the body curl saved: %d events · %s: %s · the last line blank: %s" % (len(blocks), what, yes, last))
    for l in b.split("\n")[:-1]: print("    |" + ("" if l == "" else " " + l))
else:
    print("  the body curl saved: its events - how many is timing, not shown · %s: %s · the last line blank: %s · its first event:" % (what, yes, last))
    for l in (blocks[0].split("\n") if blocks else []): print("    | " + l)
PY
}
# answer FILE: a body that is one line of JSON (a problem detail), whole, its error timestamp masked; or "nothing"
answer() { if [ ! -s "$1" ]; then echo "  the body curl saved: nothing"; return; fi
  echo "  the body curl saved, whole ($(wc -l < "$1" | tr -d ' ') newlines):"; tsmask < "$1" | awk '{ print "    | " $0 }'; }
mkdir -p .harness
{ printf '%s\n' 'HOOK 0001 EveryFilter     in  ERROR /error' '2026-10-22T00:00:00.000+02:00  WARN 1 --- [planted] o.s.b.w.a.ProblemDetailsExceptionHandler : planted warning' '2026-10-22T00:00:00.001+02:00 ERROR 1 --- [planted] o.a.c.c.C.[.[.[/].[dispatcherServlet]    : planted error' 'java.lang.IllegalStateException: planted' "$(printf '\tat a')" 'HOOK 0002 Feed            onTimeout on tomcat-handler-<n> (virtual: true) - the clock: stopped'; } > .harness/run.out
[ "$(logl 0 ERROR | grep -c .)" = 1 ] && [ "$(logl 0 WARN | grep -c .)" = 1 ] && [ "$(lvl ERROR .harness/run.out)" = 1 ] && [ "$(lvl WARN .harness/run.out)" = 1 ] && [ "$(grep -c ' ERROR ' .harness/run.out)" = 2 ] || die "the level counts: the planted log must give 1 WARN and 1 ERROR by line shape (a bare ' ERROR ' gives 2)"
[ "$(recs 0)" = "$(printf '%s\n' '    WARN o.s.b.w.a.ProblemDetailsExceptionHandler: planted warning' '      its stack frames: 0, its other lines: 0 - none shown' '    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: planted error' '      java.lang.IllegalStateException: planted' '      its stack frames: 1, its other lines: 0 - none shown')" ] || die "recs: the planted log's harness lines must be skipped (.harness/run.out)"
PL=$(hk 0); [ "$PL" = "$(printf '%s\n' "  the harness's lines it printed, in order: 2" '     1 EveryFilter     in  ERROR /error' '     2 Feed            onTimeout on tomcat-handler-<n> (virtual: true) - the clock: stopped')" ] || die "hk: the planted harness lines do not come out as declared"
printf '%s\n' 'HOOK 0007 Feed            sent event 2 (Priya)' 'HOOK 0006 Feed            sent event 1 (Meera)' > .harness/run.out
( hk 0 > /dev/null 2>&1 3> /dev/null ) && die "hk: a falling running number must stop the run"
printf 'HTTP/1.1 200 \r\nContent-Type: text/event-stream\r\nDate: Thu, 22 Oct 2026 07:12:44 GMT\r\nTransfer-Encoding: chunked\r\n\r\n' > .harness/p1
PL=$(hdrs .harness/p1); [ "$PL" = "$(printf '%s\n' '  the headers curl saved, as they came: 4 lines, the status line first (Date'"'"'s value masked):' '    HTTP/1.1 200' '    Content-Type: text/event-stream' '    Date: …' '    Transfer-Encoding: chunked' '  Content-Length: none · Transfer-Encoding: chunked')" ] || die "hdrs: the planted headers do not come out as declared"
printf 'HTTP/1.1 200 \r\nDate: Thu, 22 Oct 2026 07:12:44 GMT\r\n\r\nid:1\n\n' > .harness/p1
PL=$(strm .harness/p1); [ "$PL" = "$(printf '%s\n' "  what curl printed, as it came: 5 lines, the headers first (each line's carriage return and trailing space dropped, Date's value masked):" '    | HTTP/1.1 200' '    | Date: …' '    |' '    | id:1' '    |')" ] || die "strm: the planted stream does not come out as declared"
printf '%s\n' 'GET   /customers  -> 200 application/json  [{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"},{"name":"Bo","mealsPerDay":1,"pricePerMeal":100,"mealType":"VEG"}]' 'GET   /kitchen    -> 200 application/json  {"ordersCooked":7,"ordersValue":9}' > .harness/seven-19500.txt
E1='id:1\nevent:order\ndata:{"order":1,"customer":"Asha","mealsPerDay":2,"kitchenCooked":7}\n\n'; E2='id:2\nevent:order\ndata:{"order":2,"customer":"Bo","mealsPerDay":1,"kitchenCooked":7}\n\n'; E3='id:3\nevent:order\ndata:{"order":3,"customer":"Asha","mealsPerDay":2,"kitchenCooked":7}\n\n'
printf "$E1$E2$E3" > .harness/p1; printf "$E1$E3" > .harness/p2; printf "$E1$E2"'id:3\nevent:or' > .harness/p3; printf "${E1}${E2/Bo/Zed}" > .harness/p4; printf "${E1}${E2/:7/:8}" > .harness/p5
PL=$(evs .harness/p1 whole); [ "$PL" = "$(printf '%s\n' "  the body curl saved: 3 events · every one whole (id, event, data, then a blank line), the ids from 1 in order, each event's customer the next in the anchor's list with the anchor's meals a day, its kitchen count the anchor's: yes · the last line blank: yes" '    | id:1' '    | event:order' '    | data:{"order":1,"customer":"Asha","mealsPerDay":2,"kitchenCooked":7}' '    |' '    | id:2' '    | event:order' '    | data:{"order":2,"customer":"Bo","mealsPerDay":1,"kitchenCooked":7}' '    |' '    | id:3' '    | event:order' '    | data:{"order":3,"customer":"Asha","mealsPerDay":2,"kitchenCooked":7}' '    |')" ] || die "evs: the planted whole stream does not come out as declared"
for p in p2 p4 p5; do evs .harness/$p first | grep -q "kitchen count the anchor's: no · the last line blank: yes · its first event:\$" || die "evs: the planted stream .harness/$p must be judged no"; done
evs .harness/p3 first | grep -q "kitchen count the anchor's: yes · the last line blank: no · its first event:\$" || die "evs: a stream cut inside an event must say its last line is not blank"
rm -f .harness/run.out .harness/p1 .harness/p2 .harness/p3 .harness/p4 .harness/p5 .harness/seven-19500.txt
echo "  the filters: the record, harness-line, header and stream filters print their planted inputs as declared; a harness line that says ERROR is no ERROR line; a falling running number stops the run; the event check says no to a stream out of order, with a stranger or a wrong count, and sees a cut"

# loc: the JVM's locale, as the harness's Feed printed it when Spring made it
loc() { local l; l=$(grep -m1 -E "^HOOK [0-9]+ Feed +the JVM's locale: " .harness/run.out | sed "s/^.*the JVM's locale: //"); echo "  the JVM's locale (the harness's Feed): ${l:-not printed}"; }
# atstart: what Timeouts printed when the web server had started (the key in Spring's environment, Tomcat's connector), spaces squeezed
atstart() { local l; l=$(grep -m1 -E '^HOOK [0-9]+ Timeouts +spring\.mvc\.async\.request-timeout ' .harness/run.out | sed -E 's/^HOOK [0-9]+ //; s/  +/ /g'); echo "  the harness at start: ${l:-not printed}"; }
# done_ FROM: the harness's onCompletion line after line FROM, waited for - every 0.25 s, up to 120 s (the stream's end, whatever ended it)
done_() { local i=0; while [ $i -lt 480 ]; do awk -v from="$1" 'NR > from && /^HOOK [0-9]+ Feed +onCompletion /' .harness/run.out | grep -q . && return 0
    kill -0 "$pid" 2> /dev/null || die "the JVM exited before the stream completed"; sleep 0.25; i=$((i + 1)); done; die "the stream never completed (no onCompletion in 120 s)"; }
# fq 'COMMAND' [endless]: this unit's saved-answer line (or the stream line's sibling), printed and run - the files it writes removed
# first, so nothing read here is an earlier answer's (R.119) - then the stream's end waited for (done_); curl's line and exit code, the
# WARN and ERROR lines it added; the headers (hdrs); the body - a stream judged (evs: whole, or by its first event when endless), any
# other answer whole (answer); every harness line it printed; each WARN or ERROR record
fq() { local n0 e=0 c ct; n0=$(mark); rm -f .harness/head.txt .harness/body.txt; echo "\$ $1"; (eval "$1") > .harness/gq.out 2>&1 < /dev/null || e=$?
  done_ "$n0"; c=$(counted "$n0"); echo "  curl's line:$(cat .harness/gq.out) · curl's exit code: $e$c"; hdrs .harness/head.txt
  ct=$(tr -d '\r' < .harness/head.txt | awk -F': ' 'tolower($1) == "content-type" { print $2 }')
  if [ "$ct" = text/event-stream ]; then if [ "${2:-}" = endless ]; then evs .harness/body.txt first; else evs .harness/body.txt whole; fi; else answer .harness/body.txt; fi
  hk "$n0"; case "$c" in *': 0 · ERROR lines: 0') ;; *) recs "$n0" ;; esac; }
# blkraw FROM TO: this capture so far, the lines after the line that starts with FROM, up to the next line that starts with TO (to
# the end when TO is empty); asame A B A2 B2: yes when A's block (A up to B) and A2's (A2 up to B2), their labels aside, are the same
# line for line - an A' against its A
blkraw() { awk -v a="$1" -v b="$2" 'index($0, a) == 1 { f = 1; next } b != "" && index($0, b) == 1 { f = 0 } f' .harness/cap.raw; }
asame() { [ "$(blkraw "$1" "$2")" = "$(blkraw "$3" "$4")" ] && [ -n "$(blkraw "$3" "$4")" ] && echo yes || echo no; }
HOOKS=probe.web.Feed,probe.web.Hooks,probe.web.PlainFilter,probe.web.OnceFilter,probe.web.EveryRegistration
TIMED=probe.web.Feed,probe.web.Timeouts

# ---- events: the anchor, the harness, the seven, curl's -N, a feed read as it came ----------------------------------------------
events() {
  echo "the anchor - anchor/, copied under .harness/ with a config tree, built with its README's line (offline), its jar extracted (the README's line):"
  copy anchor .harness/anchor; pbuild .harness/anchor "the anchor"; extract .harness/anchor
  echo "the harness, compiled against the anchor's own jar - with -parameters (this unit's line):"
  echo "\$ $L_JAVAC"; rm -rf .harness/hc; (eval "$L_JAVAC") > .harness/javac.log 2>&1 < /dev/null || { cat .harness/javac.log >&3; die "the harness did not compile against the anchor's jar"; }
  echo "  exit 0 · its classes: $(cd .harness/hc && find . -name '*.class' | sed 's#^\./##' | sort | paste -sd' ' -)"
  echo "the seven - the anchor, the README's run line (its locale pinned), port 19500, a fresh JVM:"
  start "$(at .harness/anchor 19500 "$R_RUN")"; up 19500; ready 19500; seven 19500 .harness/anchor; WARNS; logl 0 WARN
  echo "the anchor's own data, as the seven read it (.harness/seven-19500.txt):"
  python3 -c '
import json, re, sys
for l in open(sys.argv[1], encoding="utf-8"):
    m = re.match(r"GET +(/\S+) +-> \d+ \S+ +(.*)$", l.rstrip("\n"))
    if m and m.group(1) == "/customers": print("  GET /customers, in its order: " + " ".join("%s (%d a day)" % (c["name"], c["mealsPerDay"]) for c in json.loads(m.group(2))))
    if m and m.group(1) == "/kitchen": print("  GET /kitchen: ordersCooked %d" % json.loads(m.group(2))["ordersCooked"])' .harness/seven-19500.txt
  echo "curl's own help for -N (this unit's line):"
  echo "\$ $L_HELP"; (eval "$L_HELP") 2>&1 < /dev/null | sed -E 's/ +/ /g; s/^ */  /'
  echo "the feed - the anchor on its class path, the harness joined (Feed), port 19501: three events, read as they came (this unit's line):"
  start "$(hcp .harness/anchor 19501 probe.web.Feed)"; up 19501; ready 19501; loc
  local n0 e=0 c; n0=$(mark); c=$(sq 19501); rm -f .harness/sse.txt .harness/sse-body.txt; echo "\$ $c"; (eval "$c") > .harness/sse.txt 2> .harness/sse.err < /dev/null || e=$?
  done_ "$n0"; echo "  curl's exit code: $e · what it wrote to its error stream: $(wc -c < .harness/sse.err | tr -d ' ') bytes$(counted "$n0")"
  strm .harness/sse.txt
  tr -d '\r' < .harness/sse.txt | awk 'f { print } /^$/ && !f { f = 1 }' > .harness/sse-body.txt
  evs .harness/sse-body.txt whole | sed -n 1p | sed 's/^  the body curl saved: /  the stream, after the headers: /'
  hk "$n0"
  WARNS; stop 19501 .harness/anchor; }

# ---- dispatch: who runs, on which dispatch; C labelled ---------------------------------------------------------------------------
dispatch() {
  echo "the hooks - the anchor on its class path, the harness joined (Feed and the filters lesson's Hooks, PlainFilter, OnceFilter, EveryRegistration), port 19502: the same three events:"
  start "$(hcp .harness/anchor 19502 "$HOOKS")"; up 19502; ready 19502; loc
  fq "$(gq 19502 3)"
  WARNS; stop 19502 .harness/anchor
  echo "C (labelled) - the same, and OnceAsync beside them (a once-per-request filter that runs on the ASYNC dispatch), port 19503:"
  start "$(hcp .harness/anchor 19503 "$HOOKS,probe.web.OnceAsync")"; up 19503; ready 19503; loc
  fq "$(gq 19503 3)"
  WARNS; stop 19503 .harness/anchor; }

# ---- timeout: nothing comes, A/B/A' ------------------------------------------------------------------------------------------------
trun() { start "$(hcp .harness/anchor "$1" "$TIMED" "${2:-}")"; up "$1"; ready "$1"; loc; atstart
  fq "$(gq "$1" 0)"
  WARNS; stop "$1" .harness/anchor; }
timeout() {
  echo "the key - what Boot's own metadata declares under spring.mvc.async. (in spring-boot-webmvc-4.1.1.jar, from the anchor's extracted lib/; this unit's line):"
  echo "\$ $L_KEYS"; (eval "$L_KEYS") 2>&1 < /dev/null | sed 's/^/  /'
  echo "A - the anchor on its class path, the harness joined (Feed, Timeouts), the key unset, port 19504: a feed asked for no events:"
  trun 19504 ""
  echo "B - the same, the key at two seconds for this run (this unit's line: the key, as an option), port 19505:"
  trun 19505 "$O_B"
  echo "A' - A again, a fresh JVM, port 19504:"
  trun 19504 ""
  echo "A' against A, its label aside, line for line the same: $(asame "A - " "B - " "A' - " "A' against A")"
  echo "D (labelled) - the key by its effect, a bound and not a clock: the same request with curl bounded to ten seconds (this unit's line, --max-time 10); A's JVM, the key unset, port 19504:"
  tbound 19504 ""
  echo "then B's JVM, the key at two seconds, port 19505:"
  tbound 19505 "$O_B"; }
# tbound PORT [OPTION]: the feed asked for no events, curl bounded to 10 s (fq waits for the stream's onCompletion, as for every
# stream: when curl gave up first, that wait is the server's own timeout coming later - a wait, never a witness: no time is printed)
tbound() { start "$(hcp .harness/anchor "$1" "$TIMED" "${2:-}")"; up "$1"; ready "$1"; loc; atstart
  fq "$(gq "$1" 0 10)"
  WARNS; stop "$1" .harness/anchor; }

# ---- committed: events, then the timeout --------------------------------------------------------------------------------------------
committed() {
  echo "mid-stream - the anchor on its class path, the harness joined (Feed, Timeouts), B's key (two seconds), port 19506: an endless feed:"
  start "$(hcp .harness/anchor 19506 "$TIMED" "$O_B")"; up 19506; ready 19506; loc; atstart
  fq "$(gq 19506 -1)" endless
  WARNS; stop 19506 .harness/anchor
  echo "whose WARN - Boot's handler, read off its jar (this unit's line), then its sentence, counted in Spring MVC's class (this unit's line):"
  echo "\$ $L_JAVAP"; (eval "$L_JAVAP") 2>&1 < /dev/null | sed 's/^/  /'
  echo "\$ $L_SENT"; (eval "$L_SENT") 2>&1 < /dev/null | sed 's/^/  /'; }

# ---- gone: the reader leaves -----------------------------------------------------------------------------------------------------
gone() {
  echo "the reader leaves - the anchor on its class path, the harness joined (Feed, Timeouts), the key unset, port 19507: an endless feed, curl bounded to two seconds:"
  start "$(hcp .harness/anchor 19507 "$TIMED")"; up 19507; ready 19507; loc; atstart
  fq "$(gq 19507 -1 2)" endless
  grep -oE 'java\.io\.IOException: [^-]*[^ -]' .harness/run.out > .harness/gone-os.txt || true
  WARNS; stop 19507 .harness/anchor; }
block() { awk '/^```bash$/ { if (!d) { f = 1 }; next } f && /^```$/ { f = 0; d = 1 } f' "$1"; }
# The shell a viewer has: env -i - nothing this script set reaches it (its JAVA_HOME, the JDK at the front of its PATH, LC_ALL,
# no_proxy, CURL_HOME) - with HOME and the PATH you started this script with; /bin/bash without profile or rc files, started in this
# folder. A driver in .harness/ runs the README's block, then SOLUTION.md's, as a viewer pastes them - each with its output, its exit
# code and the folder it left the shell in kept apart (absolute paths: a command that moved the shell must not move these files),
# and the README's run log kept before the solution's run writes its own. Bounded (600 s); on the way out, or past the bound, the
# shell and every process under it are stopped (killtree).
# where DIR: the folder the shell was left in - this unit's folder, a folder under it (named), or elsewhere
where() { case "$1" in "$U") echo "this unit's folder" ;; "$U"/*) echo "${1#"$U"/}" ;; *) echo "outside this unit's folder" ;; esac; }
exercise() { local setup sol i=0 e1 d1 e2 d2 l1 l2
  setup=$(block exercise/README.md); sol=$(block exercise/solution/SOLUTION.md)
  [ -n "$setup" ] && [ -n "$sol" ] || die "exercise/README.md or SOLUTION.md no longer gives its commands"
  [ "$(printf '%s\n' "$sol" | grep -c .)" = 4 ] || die "SOLUTION.md's first bash block must be the README's two export lines, the solution's one line and the README's last line"
  [ "$(printf '%s\n' "$sol" | sed -n 1,2p)" = "$(printf '%s\n' "$setup" | sed -n 1,2p)" ] || die "SOLUTION.md must start with the README's two export lines (a new shell's java may be another JDK)"
  printf '%s\n' "$sol" | sed -n 1p | grep -qxF 'export JAVA_HOME=/opt/homebrew/opt/openjdk@25' || die "SOLUTION.md's first line must export this script's JAVA_HOME"
  printf '%s\n' "$sol" | sed -n 3p | grep -qxF 'N=3' || die "SOLUTION.md's third line must ask for three orders: N=3"
  printf '%s\n' "$setup" | grep -qxF 'N=0' || die "exercise/README.md must ask for no orders: N=0"
  printf '%s\n' "$setup" | grep -qxF "printf 'spring.mvc.async.request-timeout: 2s\\n' > .harness/mine/anchor/tiffinbox-local.yaml" || die "exercise/README.md must write the timeout key into the copy's tiffinbox-local.yaml"
  l1=$(printf '%s\n' "$setup" | tail -1); l2=$(printf '%s\n' "$sol" | sed -n 4p)
  [ "$l1" = "$l2" ] || die "SOLUTION.md's last line must be the README's last line, unchanged: the fix is the query, not the command"
  rm -f .harness/ex-*
  printf '%s\n' "$setup" > .harness/ex-readme.sh; printf '%s\n' "$sol" > .harness/ex-sol.sh
  cat > .harness/ex-drive.sh <<'DRV'
cd "$1" || exit 1
. "$1/.harness/ex-readme.sh" > "$1/.harness/ex-readme.out" 2>&1 < /dev/null
echo "$? $PWD" > "$1/.harness/ex-readme.st"
cp "$1/.harness/mine/run.log" "$1/.harness/ex-readme.log" 2> /dev/null
cp "$1/.harness/mine/feed.txt" "$1/.harness/ex-readme.feed" 2> /dev/null
. "$1/.harness/ex-sol.sh" > "$1/.harness/ex-sol.out" 2>&1 < /dev/null
echo "$? $PWD" > "$1/.harness/ex-sol.st"
DRV
  env -i HOME="$HOME" PATH="$XPATH" /bin/bash --noprofile --norc .harness/ex-drive.sh "$U" > .harness/ex-shell.out 2>&1 < /dev/null & xpid=$!
  while kill -0 "$xpid" 2> /dev/null && [ $i -lt 2400 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$xpid" 2> /dev/null && { killtree "$xpid"; die "the exercise's shell still ran after 600 s"; }
  wait "$xpid" || true; xpid=""
  [ -f .harness/ex-readme.st ] && [ -f .harness/ex-sol.st ] || { cat .harness/ex-shell.out .harness/ex-readme.out .harness/ex-sol.out 2> /dev/null | tail -20 >&3; die "the exercise's shell did not reach the end of both blocks"; }
  read -r e1 d1 < .harness/ex-readme.st; read -r e2 d2 < .harness/ex-sol.st
  [ "$e1" = 0 ] || { tail -20 .harness/ex-readme.out >&3; die "the exercise's commands failed: exit $e1"; }
  [ "$e2" = 0 ] || { tail -20 .harness/ex-sol.out >&3; die "the solution's lines failed: exit $e2"; }
  echo "exercise/README.md's commands, then the solution's lines (exercise/solution/SOLUTION.md), exactly as written, one after the other in ONE shell - env -i (HOME, and the PATH this script was started with), /bin/bash --noprofile --norc, started in this folder:"
  echo "the README's $(printf '%s\n' "$setup" | grep -c .) lines:"
  printf '%s\n' "$setup" | sed 's/^/  $ /'
  echo "  exit $e1 · what they printed:"; sed 's/^/    /' .harness/ex-readme.out
  echo "  the shell is now in: $(where "$d1") · the stream it saved: $(grep -c '^data:' .harness/ex-readme.feed || true) data lines · the JVM's locale in its log: $(grep -m1 "^KitchenFeed: the JVM's locale: " .harness/ex-readme.log | sed "s/^.*locale: //") · the copy's own token in its log: $(raw "$(head -1 .harness/mine/anchor/$TF)" .harness/ex-readme.log) times · WARN lines in its log: $(lvl WARN .harness/ex-readme.log) · ERROR lines: $(lvl ERROR .harness/ex-readme.log) · listening on 19509 now: $(listeners 19509)"
  echo "the solution's $(printf '%s\n' "$sol" | grep -c .) lines, next, in the same shell:"
  printf '%s\n' "$sol" | sed 's/^/  $ /'
  echo "  exit $e2 · what they printed:"; sed 's/^/    /' .harness/ex-sol.out
  echo "  the shell is now in: $(where "$d2") · the stream it saved: $(grep -c '^data:' .harness/mine/feed.txt || true) data lines · the JVM's locale in its log: $(grep -m1 "^KitchenFeed: the JVM's locale: " .harness/mine/run.log | sed "s/^.*locale: //") · the copy's own token in its log: $(raw "$(head -1 .harness/mine/anchor/$TF)" .harness/mine/run.log) times · WARN lines in its log: $(lvl WARN .harness/mine/run.log) · ERROR lines: $(lvl ERROR .harness/mine/run.log) · listening on 19509 now: $(listeners 19509)"
  echo "  the stream the solution saved, .harness/mine/feed.txt, whole:"
  awk '{ print "    |" ($0 == "" ? "" : " " $0) }' .harness/mine/feed.txt
  echo "  the key file the README wrote, .harness/mine/anchor/tiffinbox-local.yaml, whole: $(grep -c . .harness/mine/anchor/tiffinbox-local.yaml) line"
  sed 's/^/    /' .harness/mine/anchor/tiffinbox-local.yaml; }

cap events events
cap dispatch dispatch
cap timeout timeout
cap committed committed
cap gone gone
cap exercise exercise
echo
# ---- every number the video says, asserted. Each check reads a line a program computed - never a label this script prints
# ---- unconditionally - and names the words it pays for.
x() { grep -qE -- "$2" ".r-$1.out" || die "$1: expected /$2/"; }
blk() { awk -v a="$2" -v b="$3" 'index($0, a) == 1 { f = 1; next } b != "" && index($0, b) == 1 { f = 0 } f' ".r-$1.out"; }
has() { printf '%s\n' "$1" | grep -qxF -- "$2" || die "$3: expected the line: $2"; }
# aft CMDLINE BLOCK: the line after the first line of BLOCK that is exactly CMDLINE (a command's first answer line) - the line is
# handed to awk through its environment, which keeps a backslash a backslash (-v would turn \n into a newline)
aft() { printf '%s\n' "$2" | C="$1" awk 'f { print; exit } $0 == ENVIRON["C"] { f = 1 }'; }
nhas() { ! printf '%s\n' "$1" | grep -qxF -- "$2" || die "$3: did not expect the line: $2"; }
# seg BLOCK 'COMMAND': the lines a command printed in BLOCK - from the line after "$ COMMAND" up to the next "$ " line or label line
seg() { printf '%s\n' "$1" | C="\$ $2" awk 'f && (/^\$ / || /^[A-Za-z]/) { exit } f { print } $0 == ENVIRON["C"] { f = 1 }'; }
# hl SEGMENT: its harness lines, numbers and padding taken off ("Feed sent event 1 (Meera) on ..."), one a line, joined by "|"
hl() { printf '%s\n' "$1" | awk '/^ +[0-9]+ [A-Z][A-Za-z]+ +/ { $1 = ""; sub(/^ /, ""); gsub(/ +/, " "); print }' | paste -sd'|' -; }
# THE TOKEN: no capture holds it, raw - counted on each run's own output BEFORE masking - and neither does any log (each counted when
# it was read: logtok()), nor anything this unit ships for reading
for f in .harness/raw-*; do [ "$(cat "$f")" = "0" ] || die "a capture's raw output held the token ($f: $(cat "$f"))"; done
for f in .r-*.out README.md exercise/README.md exercise/KitchenFeed.java exercise/solution/SOLUTION.md receipts.md5 harness/shutdown.sh harness/keys.py $HWS; do
  [ "$(raw "$TOKEN" "$f")" = 0 ] || die "$f holds the demo token, raw"; done
for f in .r-*.out; do ! grep -qE '/Users/|/private/|/home/|/var/folders/' "$f" || die "$f holds an absolute path"; ! grep -qE 'c[0-9]-unit[0-9]|unit ?[0-9]' "$f" || die "$f holds a unit number"; ! grep -qE ' (with PID|started by) ' "$f" || die "$f holds Boot's process line"; ! grep -qE '^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T|"timestamp":"?[0-9]|timestamp=[A-Z0-9]|(exec|handler|task|utility|clock)-[0-9]|GMT|CES?T|[A-Z][a-z][a-z] [A-Z][a-z][a-z] [0-9]+ [0-9][0-9]:[0-9][0-9]' "$f" || die "$f holds a log line's time, a timestamp, a date or a thread's number"; ! grep -q "^$(printf '\t')at " "$f" || die "$f shows a stack frame"; ! grep -qE 'SpringCGLIB\$\$[0-9]' "$f" || die "$f holds a generated class's number"; ! grep -qE ':(8080|35729)([^0-9]|$)' "$f" || die "$f shows a bind on 8080 or 35729"; ! grep -q $'\r' "$f" || die "$f holds a carriage return"; ! grep -qiE '<html>|<!doctype' "$f" || die "$f shows an HTML page whole"; ! grep -qiE '[0-9]+ (ms|s) (after|later)|took [0-9]|elapsed' "$f" || die "$f states a duration (R.121)"; done
# an endless stream is never counted (R.121): committed and gone print no number of events, and no event past the first
for n in committed gone; do ! grep -qE 'saved: [0-9]+ events|^    \| id:2$' ".r-$n.out" || die "$n counts an endless stream's events (R.121)"; done
for f in receipts.sh README.md exercise/README.md exercise/KitchenFeed.java exercise/solution/SOLUTION.md harness/shutdown.sh harness/keys.py $HWS; do ! grep -qE "exposure\.include='?\*" "$f" || die "$f exposes every endpoint (R.42)"; done
# S3.21 (R.99): Boot 4.1 reads only spring.web.error.*, and Boot 3's keys (server, then error) are ignored without a word - no file of
# this unit names one (the name is split here, so this line does not spell it)
K3='server'; K3="$K3.error."
for f in receipts.sh README.md exercise/README.md exercise/KitchenFeed.java exercise/solution/SOLUTION.md harness/shutdown.sh harness/keys.py $HWS; do ! grep -qF "$K3" "$f" || die "$f names one of Boot 3's error keys - Boot 4.1 reads only spring.web.error.* (S3.21)"; done
# S3.18 (R.114): no harness class reaches the anchor - its tree names none of them (as whole words), and no capture runs one but on a
# class-path line that joins it by --spring.main.sources
for c in Feed Timeouts OnceAsync KitchenFeed probe.web; do ! grep -rqwF "$c" anchor/tiffinbox-web/src anchor/tiffinbox-core/src || die "the anchor's sources name $c (a whole word) - the harness is shown on the harness, never in the anchor (S3.18)"; done
# S3.9 (R.105): no wait in this script, its checks or the exercise is bare - each names its pid ($! or a variable)
for f in receipts.sh exercise/README.md exercise/solution/SOLUTION.md; do ! grep -nE '(^|[;&|({] *)wait *($|[;&|)}])' "$f" | grep -vE '^[0-9]+: *#' > /dev/null || die "$f has a bare wait (S3.9)"; done
# no capture runs a command with a URL that is not 127.0.0.1's
for f in .r-*.out; do ! grep -E '^ *\$ ' "$f" | grep -oE 'https?://[^ '"'"']+' | grep -vE '^http://127\.0\.0\.1:' > /dev/null || die "$f runs a command with a URL that is not 127.0.0.1's"; done
# S4.1: every java line a capture starts pins the JVM's locale (the extract line prints nothing a locale changes)
for f in .r-*.out; do ! grep -E '^ *\$ (cd [^ ]+ && )?(exec )?java ' "$f" | grep -vF -- "java $JL " | grep -vF -- 'java -Djarmode=tools ' > /dev/null || die "$f starts a JVM without its locale pinned (S4.1)"; done
for f in exercise/README.md exercise/solution/SOLUTION.md; do [ "$(grep -c '{ java ' "$f")" = 1 ] && grep '{ java ' "$f" | grep -qF -- "{ java $JL -cp " || die "$f: the exercise's java line must pin the JVM's locale (S4.1)"; done
# R.115: no browser is used here - the exercise names one only to say none is needed
[ "$(grep -oi 'browser' exercise/README.md | wc -l | tr -d ' ')" = 1 ] && grep -i 'browser' exercise/README.md | grep -qF 'browser are needed)' && [ "$(grep -oi 'browser' exercise/solution/SOLUTION.md | wc -l | tr -d ' ')" = 0 ] || die "the exercise speaks of a browser (R.115) - none is used"
NL=$(cat .r-*.out | grep -cE "^  its log: the demo token 0 times · X-Shutdown-Token 0 times\$" || true)
echo "  tokens: 0 raw copies in $(ls .harness/raw-* | wc -l | tr -d ' ') raw capture runs, in $(ls .r-*.out | wc -l | tr -d ' ') captures; the demo token 0 in the logs of every JVM that served ($LOGS here; the published captures' $NL), the READMEs, the harness, the exercise and receipts.md5; no absolute path, no unit number, no process line, no log time, no timestamp, no date, no thread number, no stack frame, no whole HTML page, no 8080 or 35729, no carriage return, no duration, no count of an endless stream's events in any capture; no Boot 3 error key; no harness class in the anchor; no bare wait; every java line's locale pinned; every URL a capture runs is 127.0.0.1's"

S466='466c20ed7e0d5439cb052f32ce09de1b'
LOC="  the JVM's locale (the harness's Feed): en_US"
Z00=' · WARN lines it added: 0 · ERROR lines: 0'
EV() { printf '    | data:{"order":%s,"customer":"%s","mealsPerDay":%s,"kitchenCooked":120}' "$1" "$2" "$3"; }
WHOLE="every one whole (id, event, data, then a blank line), the ids from 1 in order, each event's customer the next in the anchor's list with the anchor's meals a day, its kitchen count the anchor's: yes · the last line blank: yes"
P503='    | {"instance":"/probe/feed","status":503,"title":"Service Unavailable"}'
HR="Feed the handler returns the emitter, nothing sent yet, on tomcat-handler-<n> (virtual: true)"
SENT3="Feed sent event 1 (Meera) on kitchen-clock (virtual: false)|Feed sent event 2 (Priya) on kitchen-clock (virtual: false)|Feed sent event 3 (Ravi) on kitchen-clock (virtual: false) - the last asked: complete()"
DONE="Feed onCompletion on tomcat-handler-<n> (virtual: true) - the clock: stopped"

# "a reply that keeps coming ... text event-stream, chunked ... id, event, data, a blank line ... three events, then curl's exit
# code, zero ... Meera, Priya, Ravi - TiffinBox's own list ... the kitchen's count, a hundred and twenty ... dash N: no buffering" - events
EO=$(cat .r-events.out)
has "$EO" '  built the anchor · offline: yes · exit 0' "events: the anchor built offline"
has "$EO" "  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 0 · md5 $S466" "events: the seven $S466"
has "$EO" '    WARN o.s.web.servlet.PageNotFound: Request method '"'"'GET'"'"' is not supported' "events: the seven's one WARN, PageNotFound"
has "$EO" '  exit 0 · its classes: probe/web/EveryFilter.class probe/web/EveryRegistration.class probe/web/Feed.class probe/web/Hooks.class probe/web/Interceptor.class probe/web/OnceAsync.class probe/web/OnceFilter.class probe/web/PlainFilter.class probe/web/ProbeOops.class probe/web/Timeouts$Leaving.class probe/web/Timeouts.class probe/web/Trace.class' "events: the harness's classes"
has "$EO" '  GET /customers, in its order: Meera (1 a day) Priya (1 a day) Ravi (2 a day) Sunil (3 a day)' "events: the anchor's list"
has "$EO" '  GET /kitchen: ordersCooked 120' "events: the anchor's kitchen"
has "$EO" '  -N, --no-buffer Disable buffering of the output stream' "events: curl's own word for -N"
has "$EO" "$LOC" "events: the locale"
S_E=$(seg "$EO" "$(sq 19501)")
has "$S_E" "  curl's exit code: 0 · what it wrote to its error stream: 0 bytes$Z00" "events: curl exit 0, 0/0"
has "$S_E" '  what curl printed, as it came: 17 lines, the headers first (each line'"'"'s carriage return and trailing space dropped, Date'"'"'s value masked):' "events: 17 lines"
for l in '    | HTTP/1.1 200' '    | Content-Type: text/event-stream' '    | Transfer-Encoding: chunked' '    | id:1' '    | event:order' '    | id:3'; do has "$S_E" "$l" "events: the wire's line $l"; done
has "$S_E" "$(EV 1 Meera 1)" "events: event 1, Meera"; has "$S_E" "$(EV 2 Priya 1)" "events: event 2, Priya"; has "$S_E" "$(EV 3 Ravi 2)" "events: event 3, Ravi"
nhas "$S_E" '    | id:4' "events: three events, no fourth"
[ "$(printf '%s\n' "$S_E" | grep -cxF '    |')" = 4 ] || die "events: one blank line after the headers, one after each of three events"
has "$S_E" "  the stream, after the headers: 3 events · $WHOLE" "events: 3 events, each whole, the anchor's data"
[ "$(hl "$S_E")" = "$HR - orders asked: 3|$SENT3|$DONE" ] || die "events: the harness's lines - got: $(hl "$S_E")"
grep -qF 'private final CustomerRepository customers;' harness/probe/web/Feed.java && grep -qF 'List<Customer> all = customers.findAll();' harness/probe/web/Feed.java && grep -qF 'data.put("kitchenCooked", kitchen.cooked());' harness/probe/web/Feed.java || die "events: the feed reads TiffinBox's own CustomerRepository and OrderQueue"
grep -qF 'SseEmitter emitter = new SseEmitter();' harness/probe/web/Feed.java && grep -qF 'Thread.ofPlatform().name("kitchen-clock").daemon(true)' harness/probe/web/Feed.java || die "events: an emitter with no timeout of its own, a daemon platform clock"
echo "  events: the seven $S466, 1 WARN (PageNotFound); curl's help: -N, --no-buffer; 200 text/event-stream, chunked, id/event/data/blank x3 (Meera, Priya, Ravi, kitchenCooked 120 = the seven's), curl exit 0; the handler returns on tomcat-handler, sends on kitchen-clock, onCompletion; en_US, 0/0"

# "the handler returns at once ... a second pass, an async dispatch ... the interceptor's preHandle again, postHandle, afterCompletion
# ... the plain filter and the once-per-request filter never see it ... C: turn its skip off, and it does" - dispatch
DO=$(cat .r-dispatch.out); DA=$(blk dispatch "the hooks - " "C (labelled)"); DC=$(blk dispatch "C (labelled)" '')
[ "$(printf '%s\n' "$DO" | grep -c "^$LOC\$")" = 2 ] || die "dispatch: two JVMs, each en_US"
S_D=$(seg "$DA" "$(gq 19502 3)"); S_C=$(seg "$DC" "$(gq 19503 3)")
for s in "$S_D" "$S_C"; do has "$s" "  curl's line: 200 · Content-Type: [text/event-stream] · curl's exit code: 0$Z00" "dispatch: 200, 0/0"; has "$s" "  the body curl saved: 3 events · $WHOLE" "dispatch: the same three events"; done
W_D="EveryFilter in REQUEST /probe/feed|PlainFilter in REQUEST /probe/feed|OnceFilter in REQUEST /probe/feed|Interceptor preHandle REQUEST /probe/feed handler Feed#feed|$HR - orders asked: 3|OnceFilter out REQUEST /probe/feed status 200|PlainFilter out REQUEST /probe/feed status 200|EveryFilter out REQUEST /probe/feed status 200|$SENT3|EveryFilter in ASYNC /probe/feed|Interceptor preHandle ASYNC /probe/feed handler Feed#feed|Interceptor postHandle ASYNC /probe/feed status 200 committed true|Interceptor afterCompletion ASYNC /probe/feed status 200 exception none|EveryFilter out ASYNC /probe/feed status 200|$DONE"
[ "$(hl "$S_D")" = "$W_D" ] || die "dispatch: the hooks, in order - got: $(hl "$S_D")"
has "$S_D" "  the harness's lines it printed, in order: 17" "dispatch: 17 lines"
W_C="EveryFilter in REQUEST /probe/feed|PlainFilter in REQUEST /probe/feed|OnceFilter in REQUEST /probe/feed|OnceAsync in REQUEST /probe/feed|Interceptor preHandle REQUEST /probe/feed handler Feed#feed|$HR - orders asked: 3|OnceAsync out REQUEST /probe/feed status 200|OnceFilter out REQUEST /probe/feed status 200|PlainFilter out REQUEST /probe/feed status 200|EveryFilter out REQUEST /probe/feed status 200|$SENT3|EveryFilter in ASYNC /probe/feed|OnceAsync in ASYNC /probe/feed|Interceptor preHandle ASYNC /probe/feed handler Feed#feed|Interceptor postHandle ASYNC /probe/feed status 200 committed true|Interceptor afterCompletion ASYNC /probe/feed status 200 exception none|OnceAsync out ASYNC /probe/feed status 200|EveryFilter out ASYNC /probe/feed status 200|$DONE"
[ "$(hl "$S_C")" = "$W_C" ] || die "dispatch C: the hooks, in order - got: $(hl "$S_C")"
[ "$(hl "$S_D" | tr '|' '\n' | grep -c ' ASYNC ')" = 5 ] && [ "$(hl "$S_D" | tr '|' '\n' | grep -E '^(PlainFilter|OnceFilter) ' | grep -c ' ASYNC ')" = 0 ] && [ "$(hl "$S_D" | tr '|' '\n' | grep -c '^Interceptor .* REQUEST ')" = 1 ] || die "dispatch: 5 ASYNC lines, none from PlainFilter or OnceFilter; one interceptor line on REQUEST"
grep -qF 'return false;' harness/probe/web/OnceAsync.java && grep -qF 'protected boolean shouldNotFilterAsyncDispatch()' harness/probe/web/OnceAsync.java && grep -qF 'extends OncePerRequestFilter' harness/probe/web/OnceFilter.java && ! grep -q 'shouldNotFilterAsyncDispatch' harness/probe/web/OnceFilter.java || die "dispatch C: OnceAsync turns the ASYNC skip off; OnceFilter keeps OncePerRequestFilter's own"
echo "  dispatch: REQUEST - every filter in, preHandle, the handler returns, filters out 200, no postHandle; 3 sends on kitchen-clock; ASYNC - EveryFilter, preHandle again, postHandle committed true, afterCompletion; PlainFilter and OnceFilter never on ASYNC; C OnceAsync (skip off) runs on ASYNC; 0/0"

# "nothing comes: five oh three ... a problem detail, Service Unavailable ... the key: nobody set it ... Tomcat's connector: thirty
# thousand milliseconds ... the request's own: thirty thousand ... B, two seconds: two thousand, the same answer ... A again" - timeout
TO=$(cat .r-timeout.out); TA=$(blk timeout "A - " "B - "); TB=$(blk timeout "B - " "A' - "); TA2=$(blk timeout "A' - " "A' against A")
has "$TO" '  spring.mvc.async.request-timeout · default none · Duration' "timeout: the key's metadata, no default"
has "$TO" '  1 keys under spring.mvc.async.' "timeout: one key"
[ "$(printf '%s\n' "$TO" | grep -c "^$LOC\$")" = 5 ] || die "timeout: five JVMs, each en_US"
T_A="  the harness at start: Timeouts spring.mvc.async.request-timeout in Spring's environment: null - Tomcat's connector, its async timeout: 30000 ms"
T_B="  the harness at start: Timeouts spring.mvc.async.request-timeout in Spring's environment: 2s - Tomcat's connector, its async timeout: 30000 ms"
has "$TA" "$T_A" "timeout A: the key unset, the connector's 30000 ms"; has "$TB" "$T_B" "timeout B: 2s, the connector unchanged"
has "$TB" "\$ $(hcp .harness/anchor 19505 "$TIMED" "$O_B")" "timeout B: its line"
S_TA=$(seg "$TA" "$(gq 19504 0)"); S_TB=$(seg "$TB" "$(gq 19505 0)"); S_TA2=$(seg "$TA2" "$(gq 19504 0)")
for s in "$S_TA" "$S_TB" "$S_TA2"; do
  has "$s" "  curl's line: 503 · Content-Type: [application/problem+json] · curl's exit code: 0$Z00" "timeout: 503 problem detail, 0/0"
  has "$s" "$P503" "timeout: the body"; has "$s" '    Connection: close' "timeout: Connection: close"; done
TW() { printf '%s' "$HR - orders asked: 0|Timeouts the REQUEST dispatch leaves; the request is async, its timeout: $1 ms|Feed onTimeout on tomcat-handler-<n> (virtual: true) - the clock: none - no events were asked|Feed onCompletion on tomcat-handler-<n> (virtual: true) - the clock: none - no events were asked"; }
[ "$(hl "$S_TA")" = "$(TW 30000)" ] || die "timeout A: the request's own timeout 30000 ms, onTimeout, onCompletion - got: $(hl "$S_TA")"
[ "$(hl "$S_TB")" = "$(TW 2000)" ] || die "timeout B: the request's own timeout 2000 ms, onTimeout, onCompletion - got: $(hl "$S_TB")"
has "$TO" "A' against A, its label aside, line for line the same: yes" "timeout: A' = A"
[ $((30 * 1000)) = 30000 ] && [ $((2 * 1000)) = 2000 ] || die "timeout: seconds"
# D (RED S4 #350): curl bounded to 10 s - with the key unset curl gives up first (exit 28, no status) and the server times out later,
# into nothing (onTimeout, onCompletion, 0/0); with B's key the same bound gets the 503
TD=$(blk timeout "D (labelled) - " "then B's JVM"); TE=$(blk timeout "then B's JVM" "")
S_TD=$(seg "$TD" "$(gq 19504 0 10)"); S_TE=$(seg "$TE" "$(gq 19505 0 10)")
has "$TD" "$T_A" "timeout D: A's JVM, the key unset"; has "$TE" "$T_B" "timeout D: B's JVM, 2s"
has "$S_TD" "  curl's line: 000 · Content-Type: [] · curl's exit code: 28$Z00" "timeout D: unset - curl gave up first, no status"
[ "$(hl "$S_TD")" = "$(TW 30000)" ] || die "timeout D: unset - later, the server's own 30000 ms timeout, onTimeout, onCompletion - got: $(hl "$S_TD")"
[ "$(hl "$S_TE")" = "$(TW 2000)" ] || die "timeout D: 2s - the request's 2000 ms, onTimeout, onCompletion - got: $(hl "$S_TE")"
has "$TD" "  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0" "timeout D: unset, 0/0"
has "$S_TE" "  curl's line: 503 · Content-Type: [application/problem+json] · curl's exit code: 0$Z00" "timeout D: 2s - the 503 inside the bound"
has "$S_TE" "$P503" "timeout D: 2s - the body"
echo "  timeout: metadata - 1 key, request-timeout, no default; A - the environment null, Tomcat's connector 30000 ms, the request's 30000 ms -> 503 problem detail Service Unavailable, Connection: close, onTimeout, 0/0; B 2s - the connector 30000, the request's 2000 -> the same 503; A' = A; D curl bounded to 10 s - unset: exit 28, no status, the server's timeout later (onTimeout, onCompletion, 0/0); 2s: the 503"

# "events, then the time runs out ... curl ends cleanly, exit zero, a two hundred it already had ... one warning: Response already
# committed ... logged under Boot's handler; the sentence is its parent's, Spring MVC's" - committed
CO=$(cat .r-committed.out); S_M=$(seg "$CO" "$(gq 19506 -1)")
has "$CO" "$LOC" "committed: the locale"; has "$CO" "$T_B" "committed: B's key"
has "$S_M" "  curl's line: 200 · Content-Type: [text/event-stream] · curl's exit code: 0 · WARN lines it added: 1 · ERROR lines: 0" "committed: 200, curl exit 0, 1 WARN"
has "$S_M" "  the body curl saved: its events - how many is timing, not shown · $WHOLE · its first event:" "committed: every event whole, the stream ended between events"
has "$S_M" "$(EV 1 Meera 1)" "committed: the first event"
has "$S_M" '    WARN o.s.b.w.a.ProblemDetailsExceptionHandler: Response already committed. Ignoring: org.springframework.web.context.request.async.AsyncRequestTimeoutException' "committed: the WARN, its logger"
[ "$(hl "$S_M")" = "$HR - orders asked: endless|Timeouts the REQUEST dispatch leaves; the request is async, its timeout: 2000 ms|Feed sent event 1 (Meera) on kitchen-clock (virtual: false) - an endless feed prints its first send only|Feed onTimeout on tomcat-handler-<n> (virtual: true) - the clock: stopped|$DONE" ] || die "committed: the harness's lines - got: $(hl "$S_M")"
has "$CO" '  class org.springframework.boot.webmvc.autoconfigure.ProblemDetailsExceptionHandler extends org.springframework.web.servlet.mvc.method.annotation.ResponseEntityExceptionHandler {' "committed: Boot's handler extends Spring MVC's"
[ "$(aft "\$ $L_SENT" "$CO")" = '  1' ] || die "committed: the sentence once in ResponseEntityExceptionHandler"
has "$CO" "  WARN lines in this run's log, at Boot's default level: 1 · ERROR lines: 0" "committed: the run 1 WARN"
echo "  committed: B 2s, endless - 200 text/event-stream, curl exit 0, every event whole, the last line blank; onTimeout; 1 WARN o.s.b.w.a.ProblemDetailsExceptionHandler 'Response already committed. Ignoring: ...AsyncRequestTimeoutException'; the class extends ResponseEntityExceptionHandler, whose bytes hold the sentence once"

# "curl gives up after two seconds: exit twenty-eight ... the server finds out at a send: broken pipe ... onError, then onCompletion
# ... not a warning" - gone
GO=$(cat .r-gone.out); S_G=$(seg "$GO" "$(gq 19507 -1 2)")
has "$GO" "$LOC" "gone: the locale"; has "$GO" "$T_A" "gone: the key unset"
has "$S_G" "  curl's line: 200 · Content-Type: [text/event-stream] · curl's exit code: 28$Z00" "gone: curl exit 28, 0/0"
has "$S_G" "$(EV 1 Meera 1)" "gone: the first event"
printf '%s\n' "$S_G" | grep -qE "^  the body curl saved: its events - how many is timing, not shown · every one whole .*: yes · " || die "gone: every event curl saved whole"
[ "$(hl "$S_G")" = "$HR - orders asked: endless|Timeouts the REQUEST dispatch leaves; the request is async, its timeout: 30000 ms|Feed sent event 1 (Meera) on kitchen-clock (virtual: false) - an endless feed prints its first send only|Feed onError on tomcat-handler-<n> (virtual: true): AsyncRequestNotUsableException: Servlet container error notification for disconnected client - the failed send, on the clock's thread: AsyncRequestNotUsableException: ServletResponse failed to flushBuffer: java.io.IOException: <the OS's words> - the clock: stopped|$DONE" ] || die "gone: the harness's lines - got: $(hl "$S_G")"
has "$GO" "  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0" "gone: the run 0/0"
for cb in onTimeout onError onCompletion; do grep -qE "emitter\.$cb\(" harness/probe/web/Feed.java || die "gone: Feed registers $cb"; done
[ "$(grep -c 'stop(f)' harness/probe/web/Feed.java)" = 3 ] || die "gone: all three callbacks stop the clock"
GOS=$(head -1 .harness/gone-os.txt 2> /dev/null || true)
case "$GOS" in 'java.io.IOException: '?*) ;; *) die "gone: the failed send's exception must be a java.io.IOException with the OS's words - got: [$GOS]" ;; esac
echo "  gone: curl --max-time 2 -> exit 28 (200 text/event-stream, every event whole); the server: onError (disconnected client; the failed send: an IOException), onCompletion, the clock stopped; 0/0 · the OS's words, this run (printed here, never in a capture): ${GOS#java.io.IOException: }"

# the exercise's end state: the README's commands, then the solution's, in ONE env -i shell - each leaves the shell in this folder
XS=$(blk exercise "the README's" "the solution's"); XE=$(blk exercise "the solution's" '')
l='the feed: 200 text/event-stream · events: 3'; l0='the feed: 503 application/problem+json · events: 0'
has "$XE" "    $l" "exercise: the solution"; has "$XS" "    $l0" "exercise: as shipped"
awk '/^\*\*Done\*\*/ { f = 1 } f' exercise/README.md | grep -qxF -- "$l" || die "exercise/README.md: Done names no such line"
grep -qxF -- "$l" exercise/solution/SOLUTION.md || die "SOLUTION.md: the measured run shows no such line"
grep -qF -- "\`$l0\`" exercise/README.md || die "exercise/README.md: the shipped line's answer is not named"
has "$XS" '  exit 0 · what they printed:' "exercise: the README's commands, exit 0"; has "$XE" '  exit 0 · what they printed:' "exercise: the solution's lines, exit 0"
has "$XS" "  the shell is now in: this unit's folder · the stream it saved: 0 data lines · the JVM's locale in its log: en_US · the copy's own token in its log: 0 times · WARN lines in its log: 0 · ERROR lines: 0 · listening on 19509 now: 0" "exercise: as shipped, 0/0 in its log"
has "$XE" "  the shell is now in: this unit's folder · the stream it saved: 3 data lines · the JVM's locale in its log: en_US · the copy's own token in its log: 0 times · WARN lines in its log: 0 · ERROR lines: 0 · listening on 19509 now: 0" "exercise: the solution, 0/0 in its log"
for d in Meera Priya Ravi; do has "$XE" "    | data:$d" "exercise: the event for $d"; done
has "$XE" '    spring.mvc.async.request-timeout: 2s' "exercise: the key the README writes"
grep -qxF 'N=3' exercise/solution/SOLUTION.md && grep -qxF 'N=0' exercise/README.md || die "exercise: N=0 shipped, N=3 the solution"
[ "$(printf '%s\n' "$XE" | grep -c '^  \$ export ')" = 2 ] || die "exercise: SOLUTION.md gives the README's two export lines"
EXQ="Your turn: the README's feed answers five oh three, after the key's two seconds, not thirty. Ask for three orders, and count the events."
grep -qxF -- "**Your turn:** ${EXQ#Your turn: }" exercise/README.md || die "exercise/README.md: the spoken exercise line"
[ "$(printf '%s\n' "$EXQ" | wc -w | tr -d ' ')" -le 25 ] || die "exercise: the spoken line is over 25 words"
echo "  exercise: one env -i shell - the README as written (N=0, the key 2s) -> $l0; the solution (N=3) -> $l; the shell in this unit's folder after each"

[ -z "$unpub" ] || die "no published hash for:$unpub - check the captures, then copy the md5s above into receipts.md5 and run again"
echo "c6-unit21: every capture 3/3 and = published; every spoken number asserted; 0 raw demo tokens in every capture and every log"
