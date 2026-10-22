#!/bin/bash
XPATH=$PATH                                           # the PATH you started this with: the exercise's own shell gets it
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25.0.4.1 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# Course 6 · Filters vs Interceptors vs Advice - this unit's receipts. No anchor change: anchor/ is the link to ../c6-unit16/after, the
# tree the problem-detail lesson froze (= c6-tiffinbox at Section 3's end, the tree the viewer last saw). This script copies that tree
# under .harness/anchor, builds it and runs it - as its README runs it, and on its class path with the course's harness joined
# (harness/probe/web, outside com.tiffinbox) - and shows the three places that can touch every request: a servlet filter, Spring MVC's
# handler interceptor, and an advice. Each hook prints a line when it runs (the harness's Trace), so the order is the program's own.
# Five captures, each run three times and hashed; cap() DIES when a hash differs from receipts.md5; every number the video says is
# asserted at the bottom by a check that can fail; the demo token is masked (gsub), and the checks count 0 raw copies of it in every
# capture, in the log of every run and in every file this unit ships.
#   chain      the anchor built and extracted; the harness compiled; the seven on the jar; then the chain of filters Tomcat built for
#              one request, read from inside a filter, four ways: the harness's three filters joined (PlainFilter, a bean, @Order(1);
#              OnceFilter, a bean, @Order(2); EveryFilter in a filter registration at order 0); the registration at order 5; at
#              Integer.MIN_VALUE; and PlainFilter wrapped in a registration of its own that sets no order
#   order      every hook joined: a small answer, a long one (2,000 items), and Actuator's health - each with every hook line it ran,
#              in order, and whether the header postHandle sets reached curl
#   throws     every hook joined: an exception from the controller that the advice handles, one nobody handles, one from the
#              interceptor that the advice handles, the same type from a filter - each answer, its hooks, its WARN and ERROR lines
#   dispatch   A/B/A': an exception from the OncePerRequestFilter - A, as the class ships (it skips Tomcat's ERROR dispatch); B, its skip
#              switched off for one run (this unit's option); A', A again; C (labelled): the filter registered for every dispatch
#              throws; D (labelled): the interceptor throws on every dispatch; E (labelled): D with /error excluded from the interceptor
#   exercise   exercise/README.md's commands, then exercise/solution/SOLUTION.md's, read from the files and run as written, one after
#              the other in ONE shell a viewer could have: env -i, /bin/bash, started in this folder
# "The anchor" is anchor/, the link to ../c6-unit16/after, COPIED under .harness/anchor; this script never writes into another unit's
# folder, and never builds a frozen tree in place. Every run of TiffinBox starts in .harness/anchor, which holds a config tree with a
# fake token (secrets/), as the README asks. Commands are printed exactly as they run: each goes through eval. "$CURLSET" is the
# comparison set since the secrets lesson (../c5-unit11/curlset.sh: the seven requests, POST /shutdown with the token's header read
# from the file). "$M2" is this unit's own repository, .m2-demo. The harness - harness/probe/web (compiled with -parameters): Trace
# (every hook's line), PlainFilter, OnceFilter, EveryFilter with EveryRegistration and PlainRegistration (three filters, two filter
# registrations), Interceptor with Hooks (a handler interceptor and the configurer that adds it), ProbeAdvice (an exception handler and a
# response-body advice), ProbeRoutes and ProbeOops (four routes, one exception type) - is the course's, never TiffinBox's: outside
# com.tiffinbox, joined by --spring.main.sources on the extracted jar's class path, and named on every capture that uses it;
# harness/shutdown.sh is POST /shutdown with the token read from its file. Every run passes options only (this unit's own keys,
# probe.*, are read by the harness from Spring's environment). The seven run first, on a fresh JVM of the jar.
# The locale: the JVM ignores LC_ALL on macOS - it takes the Mac's first language - and Spring's, Jackson's and Tomcat's messages in
# the log and in the answers are written in the JVM's locale: so every JVM this script starts has its locale pinned on its run line
# (-Duser.language=en -Duser.country=US, before -jar or -cp: at() puts it there, README.md "The commands this unit adds"), and every
# harness JVM prints it (Hooks), and the checks assert en_US.
# The network: every Maven build runs offline (-o) against .m2-demo and says so ("offline: yes"); a build that cannot resolve an
# artifact offline goes to Maven Central once, and says that ("offline: no - ..."). No native build, no Docker and no browser: this unit
# measures the JVM alone, with curl. At run time nothing leaves 127.0.0.1: TiffinBox listens there, every request goes there, and
# Logback writes to the terminal only.
# Masks and filters (README.md declares each; awk sub/gsub only): the demo token becomes "[masked: the N-character token]" (N its
# own length); this folder's absolute path "…", the folder above it "…/..", the home folder "~"; your user name "<user>" - in every
# line of every capture. Spring's error timestamp becomes "…" (both forms) in the seven and wherever an answer is printed. Tomcat's own
# HTML page is printed as its <h1> and its length, never whole. A run's log lines are printed from their logger on (no time, no process
# id, no thread); Boot's first line is cut before " with PID". A WARN or ERROR record is printed as its level, logger and message, then
# the exception line under it; its stack frames are bounded ("over 40") and its other lines counted, never shown. The harness's hook
# lines are printed in the order they ran, numbered from 1 for each request (the JVM's own running number is checked to rise, never
# shown: readiness polls change it from run to run). A saved answer (the long list) is printed as whether it parses, how many items it
# holds, its first and its last; never its byte count. No duration is captured.
# Ports (brief ⚑1, 19470-19479): chain - the seven and order 0 19470, order 5 19471, MIN_VALUE 19472, wrapped 19473 · order 19474 ·
# throws 19475 · dispatch - A and A' 19476, B 19477, C and D 19478, E 19471 · the exercise 19479. Captures run one after another, each
# JVM stopped before the next starts on its port. 18425 (TiffinBox's default), 8080 (Tomcat's) and 35729 (DevTools' Live Reload) are
# checked free too, and never bound.
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
for t in python3 curl rsync lsof unzip javac mvn; do command -v $t > /dev/null || die "$t is needed"; done
# A variable of yours must not become a property source, a JVM flag or a build setting: every TIFFINBOX_*, SPRING_*, MANAGEMENT_*,
# SERVER_* and LOGGING_* variable, DEBUG (Boot reads it as --debug), the variables that inject JVM flags, MAVEN_OPTS, MAVEN_ARGS and
# NATIVE_IMAGE_OPTIONS are removed first (the last course's failure lesson's loop, verbatim: sed -E, a canary planted under every
# name first, and the run stops if one survives). This unit runs no Docker, so COMPOSE_* is not in the list. (A
# SPRING_MVC_PROBLEMDETAILS_ENABLED of yours would answer Spring MVC's own errors another way; SPRING_WEB_ERROR_* would change Boot's
# error body; a JAVA_TOOL_OPTIONS could set every JVM's locale.)
for v in TIFFINBOX_CANARY SPRING_CANARY MANAGEMENT_CANARY SERVER_CANARY LOGGING_CANARY DEBUG JAVA_TOOL_OPTIONS JDK_JAVA_OPTIONS _JAVA_OPTIONS MAVEN_OPTS MAVEN_ARGS NATIVE_IMAGE_OPTIONS; do export "$v=planted-canary"; done
for v in $(env | sed -n -E 's/^(TIFFINBOX_[A-Za-z0-9_]*|SPRING_[A-Za-z0-9_]*|MANAGEMENT_[A-Za-z0-9_]*|SERVER_[A-Za-z0-9_]*|LOGGING_[A-Za-z0-9_]*|DEBUG|JAVA_TOOL_OPTIONS|JDK_JAVA_OPTIONS|_JAVA_OPTIONS|MAVEN_OPTS|MAVEN_ARGS|NATIVE_IMAGE_OPTIONS)=.*/\1/p'); do unset "$v"; done
[ -z "$(env | grep -- '=planted-canary$')" ] || die "a variable survived the clean-up above: $(env | grep -- '=planted-canary$' | sed 's/=.*//' | paste -sd' ' -)"
# Every request this script makes goes to 127.0.0.1: an HTTP proxy named in your environment would carry curl's requests to that
# proxy instead - 127.0.0.1 and localhost go first in no_proxy and NO_PROXY.
export no_proxy="127.0.0.1,localhost${no_proxy:+,$no_proxy}" NO_PROXY="127.0.0.1,localhost${NO_PROXY:+,$NO_PROXY}"
# This unit's own keys are probe.* - the harness reads them from Spring's environment, where a PROBE_* variable of yours would set them
# too (relaxed binding): each is removed the same way, a canary planted first.
export PROBE_CANARY=planted-canary
for v in $(env | sed -n -E 's/^(PROBE_[A-Za-z0-9_]*)=.*/\1/p'); do unset "$v"; done
[ -z "$(env | grep -- '=planted-canary$')" ] || die "a variable survived the clean-up above: $(env | grep -- '=planted-canary$' | sed 's/=.*//' | paste -sd' ' -)"
[ -e secrets ] && die "this folder holds a secrets/ - remove it: every run here starts in a folder under .harness/"
[ -L anchor ] && [ "$(readlink anchor)" = ../c6-unit16/after ] || die "anchor must be the link to ../c6-unit16/after - this unit changes nothing in the anchor"
[ -f anchor/pom.xml ] && [ -f anchor/README.md ] && [ -f anchor/tiffinbox-web/pom.xml ] || die "the anchor (its pom.xml, README.md or web module's pom.xml) is missing"
[ -e anchor/secrets ] || [ -e anchor/target ] || [ -e anchor/tiffinbox-web/target ] || [ -e anchor/tiffinbox-core/target ] || [ -e anchor/tiffinbox-local.yaml ] && die "anchor/ holds a secrets/, a target/ or a tiffinbox-local.yaml - it is a frozen copy, never built in place"
M2="$PWD/.m2-demo"; U="$PWD"; UP="$(cd .. && pwd)"; ME="$(id -un)"
TF=secrets/tiffinbox/shutdown-token                  # the config tree's file for tiffinbox.shutdown-token
# The demo token. FAKE, and meant to look it: it guards nothing but a demo server on 127.0.0.1 that every capture stops. It is
# written into .harness/anchor/secrets/ (git-ignored) when this script runs, and no capture prints it: see mask().
TOKEN=demo-token-for-three-hooks
[ ${#TOKEN} = 26 ] || die "the demo token must be 26 characters: the published captures name its length"
CURLSET=../c5-unit11/curlset.sh                      # the comparison set: the seven requests, POST /shutdown with the header
[ -f "$CURLSET" ] || die "$CURLSET is missing"
HWS='harness/probe/web/EveryFilter.java harness/probe/web/EveryRegistration.java harness/probe/web/Hooks.java harness/probe/web/Interceptor.java harness/probe/web/OnceFilter.java harness/probe/web/PlainFilter.java harness/probe/web/PlainRegistration.java harness/probe/web/ProbeAdvice.java harness/probe/web/ProbeOops.java harness/probe/web/ProbeRoutes.java harness/probe/web/Trace.java'
for f in harness/shutdown.sh $HWS exercise/README.md exercise/Guard.java exercise/solution/SOLUTION.md exercise/solution/Guard.java README.md; do [ -f "$f" ] || die "$f is missing"; done
[ "$(ls harness/probe/web | paste -sd' ' -)" = 'EveryFilter.java EveryRegistration.java Hooks.java Interceptor.java OnceFilter.java PlainFilter.java PlainRegistration.java ProbeAdvice.java ProbeOops.java ProbeRoutes.java Trace.java' ] || die "harness/probe/web holds another file: javac compiles all of it"

# The ports, BEFORE anything is wiped (a survivor of an interrupted run answers POST /shutdown only with its token, which lives in
# .harness/ - so the message names the process to kill).
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
for p in 18425 8080 35729 19470 19471 19472 19473 19474 19475 19476 19477 19478 19479; do
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
WT=" -w ' %{http_code} · Content-Type: [%{content_type}]\n'"; WH=" -w ' %{http_code} · Content-Type: [%{content_type}] · X-Post-Handle: [%header{x-post-handle}]\n'"
[ "${R_PD#curl -s}" = "$WT http://127.0.0.1:18431/customers/Nobody" ] || die "the anchor's Content-Type line"
# This unit's own lines (README.md, "The commands this unit adds") - each asserted to be exactly that: the anchor's run and class-path
# lines with the JVM's locale pinned; the class-path line with one of this unit's keys; the harness's javac line; the anchor's
# Content-Type line with the header postHandle sets printed too, one request header and the harness's path; the same, saving its
# answer to a file, another path
mine() { grep -m1 -xF -- "$1" README.md > /dev/null || die "README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
JL='-Duser.language=en -Duser.country=US'
L_RUNL=$(mine "java $JL -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431")
L_CPL=$(mine "java $JL -cp $CPL")
L_ORD5=$(mine "$L_CPL --probe.every.order=5")
L_ORDMIN=$(mine "$L_CPL --probe.every.order=-2147483648")
L_ONCE=$(mine "$L_CPL --probe.once.error=true")
L_EXCL=$(mine "$L_CPL --probe.exclude=/error")
L_JAVAC=$(mine "javac -parameters -d .harness/hc -cp \".harness/anchor/tiffinbox-web/target/extracted/lib/*\" $HWS")
L_HQ=$(mine "curl -s$WH -H 'X-Boom: once' http://127.0.0.1:18431/probe/ok")
L_GOT=$(mine "curl -s -o .harness/got.txt$WH http://127.0.0.1:18431/probe/big")
# The derivations, each asserted
P_='java '; Q_="java $JL "; r=${R_RUN/"$P_"/$Q_}; r2=${R_CP/"$P_"/$Q_}
[ "$r" = "$L_RUNL" ] && [ "$r2" = "$L_CPL" ] || die "the pinned lines must be the anchor's run and class-path lines with $JL after java, and nothing else"
for l_ in "$L_ORD5" "$L_ORDMIN" "$L_ONCE" "$L_EXCL"; do o_=${l_#"$L_CPL "}; case $o_ in --probe.*=*) ;; *) die "a class-path line with one of this unit's keys more: $l_" ;; esac; [ "${o_#* }" = "$o_" ] || die "one option, no more: $l_"; done
O_ORD5=${L_ORD5#"$L_CPL "}; O_ORDMIN=${L_ORDMIN#"$L_CPL "}; O_ONCE=${L_ONCE#"$L_CPL "}; O_EXCL=${L_EXCL#"$L_CPL "}
[ "${L_JAVAC#* -cp \"*\" }" = "$HWS" ] || die "the harness's javac line must compile the eleven files in harness/probe/web, and nothing else"
r=${R_PD/"$WT"/$WH}; P_='/customers/Nobody'; Q_='/probe/ok'; r=${r/"$P_"/$Q_}; P_=" http://"; Q_=" -H 'X-Boom: once' http://"; r=${r/"$P_"/$Q_}
[ "$r" = "$L_HQ" ] || die "the hook line must be the anchor's Content-Type line with X-Post-Handle printed, one header and /probe/ok, and nothing else"
r=${R_PD/"$WT"/ -o .harness/got.txt$WH}; P_='/customers/Nobody'; Q_='/probe/big'; r=${r/"$P_"/$Q_}
[ "$r" = "$L_GOT" ] || die "the saved-answer line must be the anchor's Content-Type line with -o, X-Post-Handle printed and /probe/big, and nothing else"
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
# hq PORT PATH ['HEADER: VALUE']: this unit's hook line - the body, the status, curl's Content-Type and the X-Post-Handle header the
# answer carried - its path PATH, and one request header when given (none: curl sends only its own)
hq() { local c=${L_HQ% http://*} P_=" -H 'X-Boom: once'" Q_=""; c=${c/"$P_"/$Q_}; [ -z "${3:-}" ] || c="$c -H '$3'"; printf '%s http://127.0.0.1:%s%s\n' "$c" "$1" "$2"; }
# gq PORT PATH: this unit's saved-answer line, its port PORT and its path PATH
gq() { local c=${L_GOT/:18431\//:$1/}; printf '%s\n' "${c/\/probe\/big/$2}"; }
# exe 'COMMAND': the command with "exec" after its "cd DIR && " - so $pid is the program's
exe() { printf '%s\n' "$1" | sed -E 's/&& (([A-Z_]+=[^ ]* )*)/\&\& \1exec /'; }
C_PRE=$(off .harness/pre "$R_PLAIN" package)
[ "$(dev "$C_PRE")" = "$R_PLAIN" ] || die "not the README's build line with the offline changes: $C_PRE"
[ "$(exe "$(at .harness/x 19470 "$R_RUN")")" = "cd .harness/x && exec ${L_RUNL/18431/19470}" ] && [ "$(at .harness/x 18431 "$R_CP")" = "cd .harness/x && $L_CPL" ] && [ "$(at .harness/x 18431 "$R_EXTRACT")" = "cd .harness/x && $R_EXTRACT" ] || die "at(): the pinned lines are not README.md's"
[ "$(hcp .harness/x 19477 probe.web.OnceFilter "$O_ONCE")" = 'cd .harness/x && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19477 --spring.main.sources=probe.web.OnceFilter --probe.once.error=true' ] || die "hcp()"
[ "$(hq 18431 /probe/ok 'X-Boom: once')" = "$L_HQ" ] && [ "$(gq 18431 /probe/big)" = "$L_GOT" ] && [ "$(hq 19474 /actuator/health)" = "curl -s$WH http://127.0.0.1:19474/actuator/health" ] || die "hq() or gq()"
echo "  the commands: anchor/README.md gives the 6 lines this script runs or derives from; README.md the 9 this unit adds"

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
# gone PORT: after a POST /shutdown - the JVM must leave within 15 s, the port must be free; its exit code
gone() { local i=0 e=0
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
  gone "$1"
  m=$(diff .harness/responses.txt .harness/responses.m.txt | grep -c '^<' || true)
  echo "  exit $LASTE · the seven responses: $(wc -l < .harness/responses.m.txt | tr -d ' ') lines · lines the timestamp mask changed: $m · md5 $(md5 -q .harness/responses.m.txt)"
  cp .harness/responses.m.txt ".harness/seven-$1.txt"
  logtok; }
# post PORT DIR: POST /shutdown with DIR's token (harness/shutdown.sh) - its answer, its Content-Length header, the timestamp masked
post() { echo "\$ harness/shutdown.sh $1 $2/$TF"; harness/shutdown.sh "$1" "$2/$TF" | tsmask | sed 's/^/  /'; }
# stop PORT DIR: POST /shutdown with DIR's token; the JVM must leave, the port must be free; its exit code; its log counted (logtok)
stop() { post "$1" "$2"; gone "$1"; echo "  exit $LASTE · listening on $1 now: 0"; logtok; }
mask() { awk -v t="$TOKEN" -v u="$U" -v up="$UP" -v hm="$HOME" -v me="$ME" -v tl="${#TOKEN}" '
  function lit(x) { gsub(/[][\\.^$*+?(){}|\/]/, "\\\\&", x); return x }
  function enc(x) { gsub(/ /, "%20", x); return x }
  BEGIN { T = lit(t); P = lit(u); Q = lit(up); H = lit(hm); PE = lit(enc(u)); QE = lit(enc(up)); M = "(^|[^A-Za-z0-9_])" lit(me) "([^A-Za-z0-9_]|$)" }
  { gsub(T, "[masked: the " tl "-character token]"); gsub(P, "…"); gsub(PE, "…")
    gsub(Q, "…/.."); gsub(QE, "…/.."); gsub(H, "~"); gsub(/\$\$SpringCGLIB\$\$[0-9]+/, "$$SpringCGLIB$$<n>")
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
    die "$nm is not the published capture - suspect another JDK, Boot or Maven, a busy machine, a busy port, a variable of yours, or an edited source; diff .r-$nm.out against its block in README.md"; fi; }
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
# recs FROM: each WARN or ERROR record the log gained after line FROM (the harness's hook lines skipped) - its level, its logger and its message; then the exception line
# under it (the first line after the record that is neither blank nor a stack frame); its stack frames, bounded ("over 40"), and its
# other lines, counted - none shown
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
# pagef: a curl answer through its filter - Boot's Whitelabel page printed as its <h1> and its error line, its created date masked and
# its paragraph counted, never shown; any other HTML page (Tomcat's own) as its <h1> and its length, never shown; curl's status line
# after it; a JSON answer - a problem detail too - as it came, its error timestamp masked
pagef() { python3 -c '
import re, sys
for l in sys.stdin.read().splitlines():
    if l.startswith("<html>") or l.lower().startswith("<!doctype html"):
        h = re.search(r"<h1>(.*?)</h1>", l); e = re.search(r"<div>(There was an unexpected error .*?)</div>", l); c = re.search(r"<div id=.created.>[^<]*</div>", l)
        tail = l[l.index("</html>") + len("</html>"):] if "</html>" in l else ""
        ps = len(re.findall(r"<p>", l))
        if l.startswith("<html>") and h and e and c and tail:
            print("  the Whitelabel page (Boot'"'"'s) - its <h1>: %s · its error line: %s · its created date: masked · its paragraphs: %d, not shown · then curl'"'"'s:%s" % (h.group(1), e.group(1), ps, tail))
        else: print("  an HTML page, not the Whitelabel page - its <h1>: %s · %d characters, not shown%s" % (h.group(1) if h else "none", len(l) - len(tail), " · then curl'"'"'s:" + tail if tail else ""))
    else:
        print("  " + re.sub(r"\"timestamp\":[0-9]+", "\"timestamp\":…", re.sub(r"\"timestamp\":\"[^\"]*\"", "\"timestamp\":\"…\"", l)))'; }
# blkraw FROM TO: this capture so far, the lines after the line that starts with FROM, up to the next line that starts with TO (to
# the end when TO is empty); asame A B A2 B2: yes when A's block (A up to B) and A2's (A2 up to B2), their labels aside, are the same
# line for line - an A' against its A; ssame: the same, the line that started each block's JVM (its $ cd ... line) aside
blkraw() { awk -v a="$1" -v b="$2" 'index($0, a) == 1 { f = 1; next } b != "" && index($0, b) == 1 { f = 0 } f' .harness/cap.raw; }
asame() { [ "$(blkraw "$1" "$2")" = "$(blkraw "$3" "$4")" ] && [ -n "$(blkraw "$3" "$4")" ] && echo yes || echo no; }
ssame() { [ "$(blkraw "$1" "$2" | grep -v '^\$ cd ')" = "$(blkraw "$3" "$4" | grep -v '^\$ cd ')" ] && [ -n "$(blkraw "$3" "$4")" ] && echo yes || echo no; }
WARNS() { settle; echo "  WARN lines in this run's log, at Boot's default level: $(logl 0 WARN | grep -c . || true) · ERROR lines: $(logl 0 ERROR | grep -c . || true)"; }
# The filters, checked on planted inputs before any capture (R.65): a Whitelabel page and Tomcat's page must come out as declared
PL=$(printf '%s\n' "<html><body><h1>Whitelabel Error Page</h1><p>planted paragraph</p><div id='created'>Sun Oct 18 07:04:55 CEST 2026</div><div>There was an unexpected error (type=Internal Server Error, status=500).</div></body></html> 500 · Content-Type: [text/html;charset=UTF-8]" '<!doctype html><html lang="en"><head><title>HTTP Status 400 – Bad Request</title></head><body><h1>HTTP Status 400 – Bad Request</h1></body></html> 400 · Content-Type: [text/html]' '{"timestamp":"2026-10-18T07:04:55.123Z","status":500} 500' | pagef)
EXP=$(printf '%s\n' "  the Whitelabel page (Boot's) - its <h1>: Whitelabel Error Page · its error line: There was an unexpected error (type=Internal Server Error, status=500). · its created date: masked · its paragraphs: 1, not shown · then curl's: 500 · Content-Type: [text/html;charset=UTF-8]" "  an HTML page, not the Whitelabel page - its <h1>: HTTP Status 400 – Bad Request · 146 characters, not shown · then curl's: 400 · Content-Type: [text/html]" '  {"timestamp":"…","status":500} 500')
[ "$PL" = "$EXP" ] || die "pagef: the planted pages do not come out as declared"
# The record filter, checked on a planted log: a WARN record with a blank line, its exception line and 45 frames, then an ERROR
# record with 3 frames, must come out as two records, each with its exception line, frames bounded and counted
mkdir -p .harness
{ printf '%s\n' '2026-10-18T00:00:00.000Z  WARN 1 --- [planted] .m.m.a.ExceptionHandlerExceptionResolver : Failure in planted' '' 'org.example.PlantedException: planted reason'
  i=0; while [ $i -lt 45 ]; do printf '\tat planted.Frame%s(Planted.java)\n' $i; i=$((i + 1)); done
  printf '%s\n' '' '2026-10-18T00:00:00.001Z ERROR 1 --- [planted] o.a.c.c.C.[.[.[/].[dispatcherServlet]    : planted error' '' 'org.example.Other: other reason' "$(printf '\tat a')" "$(printf '\tat b')" "$(printf '\tat c')"; } > .harness/run.out
PL=$(recs 0)
[ "$PL" = "$(printf '%s\n' '    WARN .m.m.a.ExceptionHandlerExceptionResolver: Failure in planted' '      org.example.PlantedException: planted reason' '      its stack frames: over 40, its other lines: 2 - none shown' '    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: planted error' '      org.example.Other: other reason' '      its stack frames: 3, its other lines: 1 - none shown')" ] || die "recs: the planted records do not come out as declared (.harness/run.out)"
rm -f .harness/run.out
# The saved-answer filter (sumf), checked on planted answers: a line of text, JSON that parses, JSON that does not, nothing at all
sumf() { python3 - "$1" <<'PY'
import json, sys
b = open(sys.argv[1], "rb").read()
if not b: print("  what curl got: nothing"); sys.exit()
t = b.decode("utf-8", "replace")
try: o = json.loads(t)
except ValueError: o = None
if isinstance(o, list): print("  what curl got: JSON that parses - a list of %d · its first: %s · its last: %s" % (len(o), json.dumps(o[0], separators=(",", ":")), json.dumps(o[-1], separators=(",", ":"))))
elif o is not None: print("  what curl got: JSON that parses - %s" % json.dumps(o, separators=(",", ":")))
elif t.lstrip().startswith(("[", "{")): print("  what curl got: JSON that does not parse - its first 40 characters: %s" % t[:40])
else:
    ls = t.split("\n"); print("  what curl got: %d line%s of text%s - %s" % (len([x for x in ls if x]), "" if len([x for x in ls if x]) == 1 else "s", ", the last one ended" if t.endswith("\n") else ", the last one cut", " · ".join(repr(x) for x in ls if x)))
PY
}
printf 'half\n' > .harness/p1; printf '[{"a":1},{"a":2}]' > .harness/p2; printf '[{"a":1},{"a"' > .harness/p3; : > .harness/p4
PL=$(for f in p1 p2 p3 p4; do sumf .harness/$f; done)
[ "$PL" = "$(printf '%s\n' "  what curl got: 1 line of text, the last one ended - 'half'" '  what curl got: JSON that parses - a list of 2 · its first: {"a":1} · its last: {"a":2}' '  what curl got: JSON that does not parse - its first 40 characters: [{"a":1},{"a"' '  what curl got: nothing')" ] || die "sumf: the planted answers do not come out as declared"
rm -f .harness/p1 .harness/p2 .harness/p3 .harness/p4
echo "  the filters: the answer filter, the record filter and the saved-answer filter print their planted inputs as declared"

# The harness's hook lines (Trace): HOOK, the JVM's running number, then what ran. hk FROM: the hook lines the log gained after line
# FROM, in the order they printed, numbered from 1 - the running number must rise line by line (checked, never shown: readiness polls,
# which pass the filters too, change it from run to run)
hk() { local o; o=$(awk -v from="$1" 'NR > from && /^HOOK [0-9]+ / { n = $2 + 0; if (k && n <= last) bad = 1; last = n; s = $0; sub(/^HOOK [0-9]+ /, "", s); l[++k] = s }
    END { if (bad) exit 3; print "  the hooks it ran, in the order they printed: " (k + 0); for (i = 1; i <= k; i++) printf "    %2d %s\n", i, l[i] }' .harness/run.out) || die "the hook lines after line $1 are out of order"
  printf '%s\n' "$o"; }
# rh 'COMMAND': a curl line, printed and run, its answer through pagef; then the WARN and ERROR lines the request added, counted on the
# answer's last line; then every hook it ran (hk); then each WARN or ERROR record (recs)
rh() { local n0 w e; n0=$(mark); echo "\$ $1"; (eval "$1") 2>&1 < /dev/null | pagef > .harness/ask.txt
  settle; w=$(logl "$n0" WARN | grep -c . || true); e=$(logl "$n0" ERROR | grep -c . || true)
  awk -v w="$w" -v e="$e" '{ l[NR] = $0 } END { for (i = 1; i <= NR; i++) print l[i] (i == NR ? " · WARN lines it added: " w " · ERROR lines: " e : "") }' .harness/ask.txt
  hk "$n0"; [ "$w$e" = 00 ] || recs "$n0"; }
# gh PORT PATH: this unit's saved-answer line, printed and run; curl's line and exit code; what curl got (sumf); the WARN and ERROR
# lines it added; every hook it ran
gh() { local n0 c e=0 w r; n0=$(mark); c=$(gq "$1" "$2"); rm -f .harness/got.txt; echo "\$ $c"; (eval "$c") > .harness/gq.out 2>&1 < /dev/null || e=$?
  echo "  curl's line:$(cat .harness/gq.out) · curl's exit code: $e"; sumf .harness/got.txt; settle
  w=$(logl "$n0" WARN | grep -c . || true); r=$(logl "$n0" ERROR | grep -c . || true)
  echo "  WARN lines it added: $w · ERROR lines: $r"; hk "$n0"; [ "$w$r" = 00 ] || recs "$n0"; }
# loc: the JVM's locale, as the harness's Hooks printed it when Spring made it
loc() { local l; l=$(grep -m1 -E "^HOOK [0-9]+ Hooks +the JVM's locale: " .harness/run.out | sed "s/^.*the JVM's locale: //"); echo "  the JVM's locale (the harness's Hooks): ${l:-not printed}"; }
# chn FROM: the chain of filters Tomcat built for the request after line FROM, as everyFilter read it from inside - one filter a line,
# its name and its class, in the order Tomcat calls them - and whether the plain filter read the same chain
chn() { local e p
  e=$(awk -v from="$1" 'NR > from && /^HOOK [0-9]+ EveryFilter +the chain Tomcat built: / { sub(/^.*the chain Tomcat built: /, ""); print; exit }' .harness/run.out)
  p=$(awk -v from="$1" 'NR > from && /^HOOK [0-9]+ PlainFilter +the chain Tomcat built: / { sub(/^.*the chain Tomcat built: /, ""); print; exit }' .harness/run.out)
  [ -n "$e" ] || die "everyFilter printed no chain"
  echo "  the chain Tomcat built for it, read from inside everyFilter - ${e%%:*}, in the order Tomcat calls them:"
  printf '%s\n' "${e#*: }" | tr '|' '\n' | sed 's/^ *//; s/ *$//; s/^/    /'
  echo "  read from inside the plain filter too, the same: $([ "$e" = "$p" ] && echo yes || echo no)"; }
ALL=probe.web.PlainFilter,probe.web.OnceFilter,probe.web.EveryRegistration,probe.web.Hooks,probe.web.ProbeAdvice,probe.web.ProbeRoutes
WRAPPED=probe.web.PlainRegistration,probe.web.OnceFilter,probe.web.EveryRegistration,probe.web.Hooks,probe.web.ProbeAdvice,probe.web.ProbeRoutes

# ---- chain: the filters' order, read off Tomcat ------------------------------------------------------------------------------------
# crun PORT CLASSES ['OPTION']: a JVM with CLASSES joined; one request that asks both filters to read the chain (X-Chain: on); the
# answer; the chain; the run's WARN and ERROR lines; stopped
crun() { local n0 c; start "$(hcp .harness/anchor "$1" "$2" "${3:-}")"; up "$1"; ready "$1"; loc
  n0=$(mark); c=$(hq "$1" /probe/ok 'X-Chain: on'); echo "\$ $c"; (eval "$c") 2>&1 < /dev/null | pagef; settle; chn "$n0"; WARNS; stop "$1" .harness/anchor; }
chain() {
  echo "the anchor - anchor/, copied under .harness/ with a config tree, built with its README's line (offline), its jar extracted (the README's line):"
  copy anchor .harness/anchor; pbuild .harness/anchor "the anchor"; extract .harness/anchor
  echo "the harness, compiled against the anchor's own jar - with -parameters (this unit's line):"
  echo "\$ $L_JAVAC"; rm -rf .harness/hc; (eval "$L_JAVAC") > .harness/javac.log 2>&1 < /dev/null || { cat .harness/javac.log >&3; die "the harness did not compile against the anchor's jar"; }
  echo "  exit 0 · its classes: $(cd .harness/hc && find . -name '*.class' | sed 's#^\./##' | sort | paste -sd' ' -)"
  echo "the seven - the anchor, the README's run line (its locale pinned), port 19470, a fresh JVM:"
  start "$(at .harness/anchor 19470 "$R_RUN")"; up 19470; ready 19470; seven 19470 .harness/anchor; WARNS; logl 0 WARN
  echo "order 0 - the anchor on its class path, the harness's three filters joined - PlainFilter (a bean, @Order(1)), OnceFilter (a bean, @Order(2)), EveryFilter (in EveryRegistration, a filter registration at order 0) - with Hooks, ProbeAdvice and ProbeRoutes, port 19470:"
  crun 19470 "$ALL"
  echo "order 5 - the same, the registration at order 5 for this run (this unit's line), port 19471:"
  crun 19471 "$ALL" "$O_ORD5"
  echo "order MIN_VALUE - the same, the registration at Integer.MIN_VALUE for this run (this unit's line), port 19472:"
  crun 19472 "$ALL" "$O_ORDMIN"
  echo "wrapped - PlainFilter (its class still @Order(1)) inside PlainRegistration, a filter registration that sets no order, joined instead of the bean, port 19473:"
  crun 19473 "$WRAPPED"; }

# ---- order: one request, every hook ------------------------------------------------------------------------------------------------
order() {
  echo "one request - the anchor on its class path, every hook joined, port 19474: a small answer; a long one (2,000 items), saved to a file; Actuator's health:"
  start "$(hcp .harness/anchor 19474 "$ALL")"; up 19474; ready 19474; loc
  rh "$(hq 19474 /probe/ok)"
  gh 19474 /probe/big
  rh "$(hq 19474 /actuator/health)"
  WARNS; stop 19474 .harness/anchor; }

# ---- throws: who still gets a say ----------------------------------------------------------------------------------------------------
throws() {
  echo "who still gets a say - the anchor on its class path, every hook joined, port 19475: the controller throws a ProbeOops (ProbeAdvice handles it), then an IllegalStateException (nobody does); the interceptor throws a ProbeOops; the plain filter throws a ProbeOops:"
  start "$(hcp .harness/anchor 19475 "$ALL")"; up 19475; ready 19475; loc
  rh "$(hq 19475 /probe/oops)"
  rh "$(hq 19475 /probe/boom)"
  rh "$(hq 19475 /probe/ok 'X-Boom: pre-oops')"
  rh "$(hq 19475 /probe/ok 'X-Boom: plain-oops')"
  WARNS; stop 19475 .harness/anchor; }

# ---- dispatch: twice - A/B/A' OncePerRequestFilter and the ERROR dispatch; C, D, E labelled -------------------------------------------
drun() { start "$(hcp .harness/anchor "$1" "$ALL" "${2:-}")"; up "$1"; ready "$1"; loc; rh "$(hq "$1" /probe/ok 'X-Boom: once')"; WARNS; stop "$1" .harness/anchor; }
dispatch() {
  echo "A - the anchor on its class path, every hook joined, port 19476: X-Boom: once - the OncePerRequestFilter throws, as the class ships (it skips the ERROR dispatch):"
  drun 19476
  echo "B - the same, its skip switched off for this run (this unit's line: shouldNotFilterErrorDispatch() answers false), port 19477:"
  drun 19477 "$O_ONCE"
  echo "A' - A again, a fresh JVM, port 19476:"
  drun 19476
  echo "A' against A, its label aside, line for line the same: $(asame "A - " "B - " "A' - " "A' against A")"
  echo "C (labelled) - every hook joined, port 19478: X-Boom: every - the filter EveryRegistration registers for every dispatch type throws:"
  start "$(hcp .harness/anchor 19478 "$ALL")"; up 19478; ready 19478; loc
  rh "$(hq 19478 /probe/ok 'X-Boom: every')"
  echo "D (labelled) - the same JVM: X-Boom: pre-all - the interceptor throws on every dispatch:"
  rh "$(hq 19478 /probe/ok 'X-Boom: pre-all')"
  WARNS; stop 19478 .harness/anchor
  echo "E (labelled) - D with the error path excluded from the interceptor for this run (this unit's line: excludePathPatterns), port 19471:"
  start "$(hcp .harness/anchor 19471 "$ALL" "$O_EXCL")"; up 19471; ready 19471; loc
  rh "$(hq 19471 /probe/ok 'X-Boom: pre-all')"
  WARNS; stop 19471 .harness/anchor; }

# ---- exercise: the README's commands, exactly as written, then the solution's - in ONE shell --------------------------------------
block() { awk '/^```bash$/ { if (!d) { f = 1 }; next } f && /^```$/ { f = 0; d = 1 } f' "$1"; }
# The shell a viewer has: env -i - nothing this script set reaches it (its JAVA_HOME, the JDK at the front of its PATH, LC_ALL,
# no_proxy) - with HOME and the PATH you started this script with; /bin/bash without profile or rc files, started in this folder.
# A driver in .harness/ runs the README's block, then SOLUTION.md's, as a viewer pastes them - each with its output, its exit code
# and the folder it left the shell in kept apart (absolute paths: a command that moved the shell must not move these files), and
# the README's run log kept before the solution's run writes its own. Bounded (600 s); on the way out, or past the bound, the shell
# and every process under it are stopped (killtree).
# where DIR: the folder the shell was left in - this unit's folder, a folder under it (named), or elsewhere
where() { case "$1" in "$U") echo "this unit's folder" ;; "$U"/*) echo "${1#"$U"/}" ;; *) echo "outside this unit's folder" ;; esac; }
# lvl LEVEL FILE: the log lines at LEVEL in FILE, by the log's own line shape (a date first) - never a bare ' ERROR ' (R.120)
lvl() { grep -cE "^[0-9]{4}-[0-9]{2}-[0-9]{2}T[^ ]+ +$1 " "$2" || true; }
exercise() { local setup sol i=0 e1 d1 e2 d2 l1 l2
  setup=$(block exercise/README.md); sol=$(block exercise/solution/SOLUTION.md)
  [ -n "$setup" ] && [ -n "$sol" ] || die "exercise/README.md or SOLUTION.md no longer gives its commands"
  [ "$(printf '%s\n' "$sol" | grep -c .)" = 4 ] || die "SOLUTION.md's first bash block must be the README's two export lines, the solution's copy line and the README's last line"
  [ "$(printf '%s\n' "$sol" | sed -n 1,2p)" = "$(printf '%s\n' "$setup" | sed -n 1,2p)" ] || die "SOLUTION.md must start with the README's two export lines (a new shell's java may be another JDK)"
  printf '%s\n' "$sol" | sed -n 1p | grep -qxF 'export JAVA_HOME=/opt/homebrew/opt/openjdk@25' || die "SOLUTION.md's first line must export this script's JAVA_HOME"
  printf '%s\n' "$sol" | sed -n 3p | grep -qxF 'cp exercise/solution/Guard.java .harness/mine/Guard.java' || die "SOLUTION.md's third line must copy the solution's Guard.java over the copy's"
  l1=$(printf '%s\n' "$setup" | tail -1); l2=$(printf '%s\n' "$sol" | sed -n 4p)
  [ "$l1" = "$l2" ] || die "SOLUTION.md's last line must be the README's last line, unchanged: the fix is in the class, not the command"
  rm -f .harness/ex-*
  printf '%s\n' "$setup" > .harness/ex-readme.sh; printf '%s\n' "$sol" > .harness/ex-sol.sh
  cat > .harness/ex-drive.sh <<'DRV'
cd "$1" || exit 1
. "$1/.harness/ex-readme.sh" > "$1/.harness/ex-readme.out" 2>&1 < /dev/null
echo "$? $PWD" > "$1/.harness/ex-readme.st"
cp "$1/.harness/mine/run.log" "$1/.harness/ex-readme.log" 2> /dev/null
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
  echo "  the shell is now in: $(where "$d1") · the JVM's locale in its log: $(grep -m1 "^Guard: the JVM's locale: " .harness/ex-readme.log | sed "s/^.*locale: //") · the copy's own token in its log: $(raw "$(head -1 .harness/mine/anchor/$TF)" .harness/ex-readme.log) times · WARN lines in its log: $(lvl WARN .harness/ex-readme.log) · ERROR lines: $(lvl ERROR .harness/ex-readme.log) · listening on 19479 now: $(listeners 19479)"
  echo "the solution's $(printf '%s\n' "$sol" | grep -c .) lines, next, in the same shell:"
  printf '%s\n' "$sol" | sed 's/^/  $ /'
  echo "  exit $e2 · what they printed:"; sed 's/^/    /' .harness/ex-sol.out
  echo "  the shell is now in: $(where "$d2") · the JVM's locale in its log: $(grep -m1 "^Guard: the JVM's locale: " .harness/mine/run.log | sed "s/^.*locale: //") · the copy's own token in its log: $(raw "$(head -1 .harness/mine/anchor/$TF)" .harness/mine/run.log) times · WARN lines in its log: $(lvl WARN .harness/mine/run.log) · ERROR lines: $(lvl ERROR .harness/mine/run.log) · listening on 19479 now: $(listeners 19479)"
  echo "  the change the solution's Guard.java makes (diff -U0, its hunks):"
  diff -U0 exercise/Guard.java .harness/mine/Guard.java | sed -n '3,$p' | sed 's/^/    /' || true; }

# The level counts, checked on a planted log before any capture (R.120): a hook line that names the ERROR dispatch, one WARN record and one
# ERROR record (with its exception line) - each count must be 1, by the log's own line shape; a bare ' ERROR ' would count 3
{ printf '%s\n' 'HOOK 0001 EveryFilter     in  ERROR /error' '2026-10-22T00:00:00.000+02:00  WARN 1 --- [planted] o.s.web.servlet.PageNotFound      : planted warning' '2026-10-22T00:00:00.001+02:00 ERROR 1 --- [planted] o.a.c.c.C.[.[.[/].[dispatcherServlet]    : planted error' 'java.lang.IllegalStateException: planted' "$(printf '\tat a')" 'HOOK 0002 EveryFilter     out ERROR /error status 500'; } > .harness/run.out
[ "$(logl 0 ERROR | grep -c .)" = 1 ] && [ "$(logl 0 WARN | grep -c .)" = 1 ] && [ "$(lvl ERROR .harness/run.out)" = 1 ] && [ "$(lvl WARN .harness/run.out)" = 1 ] && [ "$(grep -c ' ERROR ' .harness/run.out)" = 3 ] || die "the level counts: the planted log must give 1 WARN and 1 ERROR by line shape (a bare ' ERROR ' gives 3)"
[ "$(recs 0)" = "$(printf '%s\n' '    WARN o.s.web.servlet.PageNotFound: planted warning' '      its stack frames: 0, its other lines: 0 - none shown' '    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: planted error' '      java.lang.IllegalStateException: planted' '      its stack frames: 1, its other lines: 0 - none shown')" ] || die "recs: the planted log's hook lines must be skipped (.harness/run.out)"
PL=$(hk 0); [ "$PL" = "$(printf '%s\n' '  the hooks it ran, in the order they printed: 2' '     1 EveryFilter     in  ERROR /error' '     2 EveryFilter     out ERROR /error status 500')" ] || die "hk: the planted hook lines do not come out as declared"
printf '%s\n' 'HOOK 0007 EveryFilter     in  REQUEST /x' 'HOOK 0006 EveryFilter     out REQUEST /x status 200' > .harness/run.out
( hk 0 > /dev/null 2>&1 3> /dev/null ) && die "hk: a falling running number must stop the run"
rm -f .harness/run.out
echo "  the level counts, the record filter and the hook filter: planted lines come out as declared; a hook line that says ERROR is no ERROR line; a falling running number stops the run"

cap chain chain
cap order order
cap throws throws
cap dispatch dispatch
cap exercise exercise
echo
# ---- every number the video says, asserted. Each check reads a line a program computed - never a label this script prints
# ---- unconditionally - and names the words it pays for.
x() { grep -qE -- "$2" ".r-$1.out" || die "$1: expected /$2/"; }
n() { grep -cE -- "$2" ".r-$1.out" || true; }
blk() { awk -v a="$2" -v b="$3" 'index($0, a) == 1 { f = 1; next } b != "" && index($0, b) == 1 { f = 0 } f' ".r-$1.out"; }
has() { printf '%s\n' "$1" | grep -qxF -- "$2" || die "$3: expected the line: $2"; }
nhas() { ! printf '%s\n' "$1" | grep -qxF -- "$2" || die "$3: did not expect the line: $2"; }
# aft CMDLINE BLOCK: the line after the first line of BLOCK that is exactly CMDLINE (a command's first answer line) - the line is
# handed to awk through its environment, which keeps a backslash a backslash (-v would turn \n into a newline)
aft() { printf '%s\n' "$2" | C="$1" awk 'f { print; exit } $0 == ENVIRON["C"] { f = 1 }'; }
# ans BLOCK 'COMMAND' 'ANSWER' W E LABEL: the command's answer in BLOCK is ANSWER, with W WARN and E ERROR lines added
ans() { local g; g=$(aft "\$ $2" "$1"); [ "$g" = "$3 · WARN lines it added: $4 · ERROR lines: $5" ] || die "$6: $2 - expected: $3 · $4 WARN · $5 ERROR - got: $g"; }
# THE TOKEN: no capture holds it, raw - counted on each run's own output BEFORE masking - and neither does any log (each counted when
# it was read: logtok()), nor anything this unit ships for reading
for f in .harness/raw-*; do [ "$(cat "$f")" = "0" ] || die "a capture's raw output held the token ($f: $(cat "$f"))"; done
for f in .r-*.out README.md exercise/README.md exercise/Guard.java exercise/solution/SOLUTION.md exercise/solution/Guard.java receipts.md5 harness/shutdown.sh $HWS; do
  [ "$(raw "$TOKEN" "$f")" = 0 ] || die "$f holds the demo token, raw"; done
for f in .r-*.out; do ! grep -qE '/Users/|/private/|/home/|/var/folders/' "$f" || die "$f holds an absolute path"; ! grep -qE 'c[0-9]-unit[0-9]|unit ?[0-9]' "$f" || die "$f holds a unit number"; ! grep -qE ' (with PID|started by) ' "$f" || die "$f holds Boot's process line"; ! grep -qE '^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T|"timestamp":"?[0-9]|timestamp=[A-Z0-9]|(exec|handler|task|utility)-[0-9]|GMT|CES?T|<div id=.created|[A-Z][a-z][a-z] [A-Z][a-z][a-z] [0-9]+ [0-9][0-9]:[0-9][0-9]' "$f" || die "$f holds a log line's time, a timestamp, a date or a thread's number"; ! grep -q "^$(printf '\t')at " "$f" || die "$f shows a stack frame"; ! grep -qE 'SpringCGLIB\$\$[0-9]' "$f" || die "$f holds a generated class's number"; ! grep -qE ':(8080|35729)([^0-9]|$)' "$f" || die "$f shows a bind on 8080 or 35729"; ! grep -q $'\r' "$f" || die "$f holds a carriage return"; ! grep -qiE '<html>|<!doctype' "$f" || die "$f shows an HTML page whole"; done
for f in receipts.sh README.md exercise/README.md exercise/Guard.java exercise/solution/SOLUTION.md exercise/solution/Guard.java harness/shutdown.sh $HWS; do ! grep -qE "exposure\.include='?\*" "$f" || die "$f exposes every endpoint (R.42)"; done
# S3.21 (R.99): Boot 4.1 reads only spring.web.error.*, and Boot 3's keys (server, then error) are ignored without a word - no file of
# this unit names one (the name is split here, so this line does not spell it)
K3='server'; K3="$K3.error."
for f in receipts.sh README.md exercise/README.md exercise/Guard.java exercise/solution/SOLUTION.md exercise/solution/Guard.java harness/shutdown.sh $HWS; do ! grep -qF "$K3" "$f" || die "$f names one of Boot 3's error keys - Boot 4.1 reads only spring.web.error.* (S3.21)"; done
# S3.18 (R.114): no trap reaches the anchor - its tree names none of the harness's classes (as whole words: the anchor's BareArgumentGuard is not the exercise's Guard), and no capture runs one but on a
# class-path line that joins it by --spring.main.sources
for c in PlainFilter OnceFilter EveryFilter EveryRegistration PlainRegistration Interceptor ProbeAdvice ProbeRoutes ProbeOops Guard probe.web; do ! grep -rqwF "$c" anchor/tiffinbox-web/src anchor/tiffinbox-core/src || die "the anchor's sources name $c (a whole word) - a trap is shown on the harness, never in the anchor (S3.18)"; done
# S3.9 (R.105): no wait in this script, its checks or the exercise is bare - each names its pid ($! or a variable)
for f in receipts.sh exercise/README.md exercise/solution/SOLUTION.md; do ! grep -nE '(^|[;&|({] *)wait *($|[;&|)}])' "$f" | grep -vE '^[0-9]+: *#' > /dev/null || die "$f has a bare wait (S3.9)"; done
# no capture runs a command with a URL that is not 127.0.0.1's
for f in .r-*.out; do ! grep -E '^\$ ' "$f" | grep -oE 'https?://[^ '"'"']+' | grep -vE '^http://127\.0\.0\.1:' > /dev/null || die "$f runs a command with a URL that is not 127.0.0.1's"; done
# S3.1: every java line a capture starts pins the JVM's locale (the extract line prints nothing a locale changes)
for f in .r-*.out; do ! grep -E '^ *\$ (cd [^ ]+ && )?(exec )?java ' "$f" | grep -vF -- "java $JL " | grep -vF -- 'java -Djarmode=tools ' > /dev/null || die "$f starts a JVM without its locale pinned (S3.1)"; done
# the exercise's java line pins the JVM's locale too (it starts with M=..., so the check above does not see it)
for f in exercise/README.md exercise/solution/SOLUTION.md; do [ "$(grep -c '{ java ' "$f")" = 1 ] && grep '{ java ' "$f" | grep -qF -- "{ java $JL -cp " || die "$f: the exercise's java line must pin the JVM's locale (S3.1)"; done
NL=$(cat .r-*.out | grep -cE "^  its log: the demo token 0 times · X-Shutdown-Token 0 times\$" || true)
echo "  tokens: 0 raw copies in $(ls .harness/raw-* | wc -l | tr -d ' ') raw capture runs, in $(ls .r-*.out | wc -l | tr -d ' ') captures; the demo token 0 in the logs of every JVM that served ($LOGS here; the published captures' $NL), the READMEs, the harness, the exercise and receipts.md5; no absolute path, no unit number, no process line, no log time, no timestamp, no date, no thread number, no stack frame, no whole HTML page, no 8080 or 35729, no carriage return in any capture; no Boot 3 error key; no harness class in the anchor; no bare wait; every java line's locale pinned; every URL a capture runs is 127.0.0.1's"

S466='466c20ed7e0d5439cb052f32ce09de1b'
XP='X-Post-Handle'
J4() { printf '  {"timestamp":"…","status":500,"error":"Internal Server Error","path":"%s"} 500 · Content-Type: [application/json] · %s: []' "$1" "$XP"; }
TP="  an HTML page, not the Whitelabel page - its <h1>: HTTP Status 500 – Internal Server Error · 451 characters, not shown · then curl's: 500 · Content-Type: [text/html;charset=utf-8] · $XP: []"
PD409() { printf '  {"detail":"%s","instance":"%s","status":409,"title":"Conflict","handler":"ProbeAdvice"} 409 · Content-Type: [application/problem+json] · %s: []' "$1" "$2" "$XP"; }
TOMF='    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: Servlet.service() for servlet [dispatcherServlet] in context with path [] threw exception'
TOM2='    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: Servlet.service() for servlet [dispatcherServlet] threw exception'
TOMH='    ERROR o.a.c.c.C.[Tomcat].[localhost]: Exception Processing [ErrorPage[errorCode=0, location=/error]]'
# seg BLOCK 'COMMAND': the lines a command printed in BLOCK - from the line after "$ COMMAND" up to the next "$ " line or label line
seg() { printf '%s\n' "$1" | C="\$ $2" awk 'f && (/^\$ / || /^[A-Za-z]/) { exit } f { print } $0 == ENVIRON["C"] { f = 1 }'; }
# hl SEGMENT: its hook lines, numbers and padding taken off ("EveryFilter in REQUEST /probe/ok"), one a line
hl() { printf '%s\n' "$1" | awk '/^ +[0-9]+ [A-Z][A-Za-z]+ +/ { $1 = ""; sub(/^ /, ""); gsub(/ +/, " "); print }'; }
# the chain, as everyFilter read it: one line each, "N name (class)"
CHB='characterEncodingFilter (org.springframework.boot.servlet.filter.OrderedCharacterEncodingFilter)|webMvcObservationFilter (org.springframework.web.filter.ServerHttpObservationFilter)|formContentFilter (org.springframework.boot.servlet.filter.OrderedFormContentFilter)|requestContextFilter (org.springframework.boot.servlet.filter.OrderedRequestContextFilter)'
CHT='Tomcat WebSocket (JSR356) Filter (org.apache.tomcat.websocket.server.WsFilter)'
EV='everyFilter (probe.web.EveryFilter)'; PF='plainFilter (probe.web.PlainFilter)'; OF='onceFilter (probe.web.OnceFilter)'; WP='wrappedPlain (probe.web.PlainFilter)'
chainof() { printf '%s\n' "$1" | awk '/^  the chain Tomcat built for it/ { f = 1; next } f && /^    [0-9]+ / { sub(/^    [0-9]+ /, ""); print; next } f { exit }' | paste -sd'|' -; }

# "Eight filters. The four Boot registers, then ours, then Tomcat's web socket filter ... order zero ... order one ... order five ...
# the lowest number there is, ahead of Boot's encoding filter ... wrapped: it drops to the end of ours" - chain
CO=$(cat .r-chain.out)
has "$CO" '  built the anchor · offline: yes · exit 0' "chain: the anchor built offline"
has "$CO" "  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 0 · md5 $S466" "chain: the seven $S466"
has "$CO" '    WARN o.s.web.servlet.PageNotFound: Request method '"'"'GET'"'"' is not supported' "chain: the seven's one WARN, PageNotFound"
has "$CO" '  exit 0 · its classes: probe/web/EveryFilter.class probe/web/EveryRegistration.class probe/web/Hooks.class probe/web/Interceptor.class probe/web/OnceFilter.class probe/web/PlainFilter.class probe/web/PlainRegistration.class probe/web/ProbeAdvice.class probe/web/ProbeOops.class probe/web/ProbeRoutes.class probe/web/Trace.class' "chain: the harness's classes"
K0=$(blk chain "order 0 - " "order 5 - "); K5=$(blk chain "order 5 - " "order MIN_VALUE - "); KM=$(blk chain "order MIN_VALUE - " "wrapped - "); KW=$(blk chain "wrapped - " '')
for t in "K0:$CHB|$EV|$PF|$OF|$CHT" "K5:$CHB|$PF|$OF|$EV|$CHT" "KM:$EV|$CHB|$PF|$OF|$CHT" "KW:$CHB|$EV|$OF|$WP|$CHT"; do
  b_=${t%%:*}; w_=${t#*:}; eval "B_=\$$b_"; [ "$(chainof "$B_")" = "$w_" ] || die "chain $b_: the chain must be: $w_ - got: $(chainof "$B_")"
  has "$B_" "  the chain Tomcat built for it, read from inside everyFilter - 8 filters, in the order Tomcat calls them:" "chain $b_: 8 filters"
  has "$B_" "  read from inside the plain filter too, the same: yes" "chain $b_: the plain filter read the same chain"
  has "$B_" "  the JVM's locale (the harness's Hooks): en_US" "chain $b_: the locale"
  has "$B_" "  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0" "chain $b_: 0 WARN, 0 ERROR"
  has "$B_" "  {\"answer\":\"ok\"} 200 · Content-Type: [application/json] · $XP: [set]" "chain $b_: the answer"; done
has "$K5" "\$ $(hcp .harness/anchor 19471 "$ALL" "$O_ORD5")" "chain: order 5's line"
has "$KM" "\$ $(hcp .harness/anchor 19472 "$ALL" "$O_ORDMIN")" "chain: MIN_VALUE's line"
has "$KW" "\$ $(hcp .harness/anchor 19473 "$WRAPPED")" "chain: the wrapped line"
[ "$(printf '%s\n' "$CHB" | tr '|' '\n' | grep -c .)" = 4 ] || die "chain: Boot's four"
grep -qxF '@Order(1)' harness/probe/web/PlainFilter.java && grep -qxF '@Order(2)' harness/probe/web/OnceFilter.java && grep -qF 'env.getProperty("probe.every.order", Integer.class, 0)' harness/probe/web/EveryRegistration.java && grep -qF 'b.setDispatcherTypes(EnumSet.allOf(DispatcherType.class));' harness/probe/web/EveryRegistration.java || die "chain: the harness's orders (1, 2, the registration's 0) and the registration's dispatch types"
! grep -q 'setOrder' harness/probe/web/PlainRegistration.java && grep -qF 'return new FilterRegistrationBean<>(new PlainFilter());' harness/probe/web/PlainRegistration.java || die "chain: PlainRegistration sets no order"
[ "$O_ORD5" = '--probe.every.order=5' ] && [ "$O_ORDMIN" = '--probe.every.order=-2147483648' ] || die "chain: the orders 5 and Integer.MIN_VALUE"
echo "  chain: the seven $S466, 1 WARN (PageNotFound); order 0 - Boot's 4, everyFilter, plainFilter, onceFilter, Tomcat's WebSocket filter (8); order 5 - after onceFilter; MIN_VALUE - first, ahead of characterEncodingFilter; wrapped - wrappedPlain after onceFilter; each read the same from inside the plain filter, en_US, 0/0"

# "one request ... eleven lines ... filters in, pre-handle, the controller, the advice, post-handle, after-completion, filters out ...
# the header arrives ... two thousand items ... committed ... never arrives ... Actuator's health: the interceptor never runs" - order
OO=$(cat .r-order.out)
has "$OO" "  the JVM's locale (the harness's Hooks): en_US" "order: the locale"
S_OK=$(seg "$OO" "$(hq 19474 /probe/ok)")
has "$S_OK" "  {\"answer\":\"ok\"} 200 · Content-Type: [application/json] · $XP: [set] · WARN lines it added: 0 · ERROR lines: 0" "order: a small answer, the header set"
W_OK='EveryFilter in REQUEST /probe/ok|PlainFilter in REQUEST /probe/ok|OnceFilter in REQUEST /probe/ok|Interceptor preHandle REQUEST /probe/ok handler ProbeRoutes#ok|ProbeRoutes ok|ProbeAdvice beforeBodyWrite /probe/ok body Map1|Interceptor postHandle REQUEST /probe/ok status 200 committed false|Interceptor afterCompletion REQUEST /probe/ok status 200 exception none|OnceFilter out REQUEST /probe/ok status 200|PlainFilter out REQUEST /probe/ok status 200|EveryFilter out REQUEST /probe/ok status 200'
[ "$(hl "$S_OK" | paste -sd'|' -)" = "$W_OK" ] || die "order: the small answer's hooks, in order - got: $(hl "$S_OK" | paste -sd'|' -)"
has "$S_OK" "  the hooks it ran, in the order they printed: 11" "order: eleven hook lines"
S_BIG=$(seg "$OO" "$(gq 19474 /probe/big)")
has "$S_BIG" "  curl's line: 200 · Content-Type: [application/json] · $XP: [] · curl's exit code: 0" "order: the long answer, no header"
has "$S_BIG" '  what curl got: JSON that parses - a list of 2000 · its first: "0123456789" · its last: "0123456789"' "order: 2000 items"
hl "$S_BIG" | grep -qxF 'Interceptor postHandle REQUEST /probe/big status 200 committed true' || die "order: postHandle saw the long answer committed"
[ "$(hl "$S_BIG" | grep -n 'ProbeAdvice beforeBodyWrite' | cut -d: -f1)" = 6 ] && [ "$(hl "$S_BIG" | grep -n 'Interceptor postHandle' | cut -d: -f1)" = 7 ] || die "order: beforeBodyWrite before postHandle"
grep -qF 'Collections.nCopies(2000, "0123456789")' harness/probe/web/ProbeRoutes.java || die "order: the harness's 2,000 items"
S_ACT=$(seg "$OO" "$(hq 19474 /actuator/health)")
has "$S_ACT" "  {\"groups\":[\"liveness\",\"readiness\"],\"status\":\"UP\"} 200 · Content-Type: [application/vnd.spring-boot.actuator.v3+json] · $XP: [] · WARN lines it added: 0 · ERROR lines: 0" "order: Actuator's health"
! hl "$S_ACT" | grep -q '^Interceptor ' && hl "$S_ACT" | grep -qxF 'ProbeAdvice beforeBodyWrite /actuator/health body SystemHealthDescriptor' && [ "$(hl "$S_ACT" | grep -c 'Filter ')" = 6 ] || die "order: Actuator's health - the filters and the advice, no interceptor"
has "$OO" "  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0" "order: 0 WARN, 0 ERROR"
echo "  order: /probe/ok - 11 hooks in order (filters in, preHandle, the route, beforeBodyWrite, postHandle committed false, afterCompletion, filters out), X-Post-Handle set; /probe/big - 2000 items, postHandle committed true, no header; /actuator/health - filters and the advice, no interceptor; 0/0"

# "a four oh nine problem detail ... post-handle never runs ... the interceptor throws the same: four oh nine ... a filter throws it: Boot's
# five hundred, the advice is never asked ... after-completion sees the exception, the filters see two hundred ... the error dispatch"
TO=$(cat .r-throws.out)
has "$TO" "  the JVM's locale (the harness's Hooks): en_US" "throws: the locale"
S_OOP=$(seg "$TO" "$(hq 19475 /probe/oops)"); S_BOOM=$(seg "$TO" "$(hq 19475 /probe/boom)"); S_PRE=$(seg "$TO" "$(hq 19475 /probe/ok 'X-Boom: pre-oops')"); S_PL=$(seg "$TO" "$(hq 19475 /probe/ok 'X-Boom: plain-oops')")
has "$S_OOP" "$(PD409 'the controller says oops' /probe/oops) · WARN lines it added: 0 · ERROR lines: 0" "throws: the controller's ProbeOops - 409 from the advice"
! hl "$S_OOP" | grep -q 'postHandle' && hl "$S_OOP" | grep -qxF 'Interceptor afterCompletion REQUEST /probe/oops status 409 exception none' && hl "$S_OOP" | grep -qxF 'ProbeAdvice @ExceptionHandler(ProbeOops): the controller says oops' || die "throws: the controller's ProbeOops - no postHandle, afterCompletion with none"
has "$S_BOOM" "$(J4 /probe/boom) · WARN lines it added: 0 · ERROR lines: 1" "throws: the route's IllegalStateException - Boot's 500, 1 ERROR"
has "$S_BOOM" "$TOMF [Request processing failed: java.lang.IllegalStateException: the kitchen is on fire] with root cause" "throws: Tomcat's ERROR"
W_BOOM='EveryFilter in REQUEST /probe/boom|PlainFilter in REQUEST /probe/boom|OnceFilter in REQUEST /probe/boom|Interceptor preHandle REQUEST /probe/boom handler ProbeRoutes#boom|ProbeRoutes boom (throws an IllegalStateException)|Interceptor afterCompletion REQUEST /probe/boom status 200 exception IllegalStateException|OnceFilter out REQUEST /probe/boom status 200|PlainFilter out REQUEST /probe/boom status 200|EveryFilter out REQUEST /probe/boom status 200|EveryFilter in ERROR /error|Interceptor preHandle ERROR /error handler BasicErrorController#error|ProbeAdvice beforeBodyWrite /error body LinkedHashMap|Interceptor postHandle ERROR /error status 500 committed true|Interceptor afterCompletion ERROR /error status 500 exception none|EveryFilter out ERROR /error status 500'
[ "$(hl "$S_BOOM" | paste -sd'|' -)" = "$W_BOOM" ] || die "throws: the route's IllegalStateException - its hooks, both passes - got: $(hl "$S_BOOM" | paste -sd'|' -)"
has "$S_PRE" "$(PD409 'the interceptor says oops' /probe/ok) · WARN lines it added: 0 · ERROR lines: 0" "throws: the interceptor's ProbeOops - 409 from the advice"
! hl "$S_PRE" | grep -q 'afterCompletion' && hl "$S_PRE" | grep -qxF 'ProbeAdvice @ExceptionHandler(ProbeOops): the interceptor says oops' || die "throws: the interceptor's ProbeOops - the advice answered, no afterCompletion"
has "$S_PL" "$(J4 /probe/ok) · WARN lines it added: 0 · ERROR lines: 1" "throws: the filter's ProbeOops - Boot's 500, 1 ERROR"
! hl "$S_PL" | grep -q '@ExceptionHandler' && has "$S_PL" "$TOMF" "throws" && has "$S_PL" '      probe.web.ProbeOops: the plain filter says oops' "throws: the filter's ProbeOops under Tomcat's ERROR" || die "throws: the filter's ProbeOops - the advice never asked"
has "$TO" "  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 2" "throws: the run, 0 WARN 2 ERROR"
echo "  throws: the controller's ProbeOops - 409 (ProbeAdvice), no postHandle, afterCompletion none; the route's ISE - Boot's 500, 1 ERROR, afterCompletion ISE at 200, filters out 200, then the ERROR dispatch (everyFilter, the interceptor, the advice); the interceptor's ProbeOops - 409 (ProbeAdvice), no afterCompletion; the filter's ProbeOops - Boot's 500, the advice never asked, 1 ERROR"

# "A: Boot's JSON five hundred, one error line ... B: Tomcat's own HTML page, three error lines ... A again ... the every-dispatch filter, the
# interceptor on every dispatch: the same page ... exclude the error path: Boot's five hundred comes back" - dispatch
DO=$(cat .r-dispatch.out); DA=$(blk dispatch "A - " "B - "); DB=$(blk dispatch "B - " "A' - "); DC=$(blk dispatch "C (labelled)" "D (labelled)"); DD=$(blk dispatch "D (labelled)" "E (labelled)"); DE=$(blk dispatch "E (labelled)" '')
[ "$(printf '%s\n' "$DO" | grep -c "^  the JVM's locale (the harness's Hooks): en_US\$")" = 5 ] || die "dispatch: five JVMs, each en_US"
has "$DA" "$(J4 /probe/ok) · WARN lines it added: 0 · ERROR lines: 1" "dispatch A: Boot's 500, 1 ERROR"
has "$DA" "  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 1" "dispatch A: the run 0/1"
hl "$DA" | grep -qxF 'EveryFilter in ERROR /error' && hl "$DA" | grep -qxF 'Interceptor preHandle ERROR /error handler BasicErrorController#error' && ! hl "$DA" | grep -qE '^(OnceFilter|PlainFilter) in ERROR' || die "dispatch A: the ERROR dispatch - everyFilter and the interceptor, not the plain filter, not onceFilter"
has "$DB" "$TP · WARN lines it added: 0 · ERROR lines: 3" "dispatch B: Tomcat's page, 3 ERROR"
hl "$DB" | grep -qxF 'OnceFilter in ERROR /error' || die "dispatch B: onceFilter runs on the ERROR dispatch"
for l in "$TOMF" "$TOM2" "$TOMH"; do has "$DB" "$l" "dispatch B: Tomcat's three ERROR lines"; done
has "$DO" "A' against A, its label aside, line for line the same: yes" "dispatch: A' = A"
has "$DC" "$TP · WARN lines it added: 0 · ERROR lines: 3" "dispatch C: the every-dispatch filter - Tomcat's page, 3 ERROR"
has "$DD" "$TP · WARN lines it added: 0 · ERROR lines: 3" "dispatch D: the interceptor on every dispatch - Tomcat's page, 3 ERROR"
has "$DD" "  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 6" "dispatch C and D: the run 0/6"
has "$DE" "$(J4 /probe/ok) · WARN lines it added: 0 · ERROR lines: 1" "dispatch E: /error excluded - Boot's 500, 1 ERROR"
! hl "$DE" | grep -q '^Interceptor preHandle ERROR' && hl "$DE" | grep -qxF 'Interceptor preHandle REQUEST /probe/ok handler ProbeRoutes#ok' || die "dispatch E: the interceptor on the request only"
grep -qF 'return !getEnvironment().getProperty("probe.once.error", Boolean.class, false);' harness/probe/web/OnceFilter.java && grep -qF 'r.excludePathPatterns(exclude);' harness/probe/web/Hooks.java || die "dispatch: the harness's two switches"
echo "  dispatch: A - onceFilter throws -> Boot's 500 JSON, 1 ERROR, the ERROR dispatch without onceFilter or the plain filter; B (--probe.once.error=true) -> Tomcat's HTML 500, 3 ERROR (two loggers); A' = A; C every-dispatch filter, D interceptor every dispatch -> Tomcat's page, 3 ERROR each; E /error excluded -> Boot's 500, 1 ERROR"

# the exercise's end state: the README's commands, then the solution's, in ONE env -i shell - each leaves the shell in this folder
XS=$(blk exercise "the README's" "the solution's"); XE=$(blk exercise "the solution's" '')
l='the guard: 500 application/json · ERROR lines: 1'; l0='the guard: 500 text/html;charset=utf-8 · ERROR lines: 3'
has "$XE" "    $l" "exercise: the solution"; has "$XS" "    $l0" "exercise: as shipped"
awk '/^\*\*Done\*\*/ { f = 1 } f' exercise/README.md | grep -qxF -- "$l" || die "exercise/README.md: Done names no such line"
grep -qxF -- "$l" exercise/solution/SOLUTION.md || die "SOLUTION.md: the measured run shows no such line"
grep -qF -- "\`$l0\`" exercise/README.md || die "exercise/README.md: the shipped line's answer is not named"
has "$XS" '  exit 0 · what they printed:' "exercise: the README's commands, exit 0"; has "$XE" '  exit 0 · what they printed:' "exercise: the solution's lines, exit 0"
has "$XS" "  the shell is now in: this unit's folder · the JVM's locale in its log: en_US · the copy's own token in its log: 0 times · WARN lines in its log: 0 · ERROR lines: 3 · listening on 19479 now: 0" "exercise: as shipped, 3 ERROR in its log"
has "$XE" "  the shell is now in: this unit's folder · the JVM's locale in its log: en_US · the copy's own token in its log: 0 times · WARN lines in its log: 0 · ERROR lines: 1 · listening on 19479 now: 0" "exercise: the solution, 1 ERROR in its log"
has "$XE" '    +        if (request.getDispatcherType() != DispatcherType.REQUEST) {' "exercise: the solution's change"
[ "$(printf '%s\n' "$XE" | grep -c '^    [+-]')" = 4 ] && [ "$(printf '%s\n' "$XE" | grep -c '^    -')" = 0 ] || die "exercise: the solution adds four lines and removes none"
[ "$(printf '%s\n' "$XE" | grep -c '^  \$ export ')" = 2 ] || die "exercise: SOLUTION.md gives the README's two export lines"
EXQ="Your turn: the README's interceptor turns a five hundred into Tomcat's own page. Make it skip the error dispatch, and ask again."
grep -qxF -- "**Your turn:** ${EXQ#Your turn: }" exercise/README.md || die "exercise/README.md: the spoken exercise line"
[ "$(printf '%s\n' "$EXQ" | wc -w | tr -d ' ')" -le 25 ] || die "exercise: the spoken line is over 25 words"
echo "  exercise: one env -i shell - the README as written (the guard throws on every dispatch) -> $l0; the solution (it returns early unless REQUEST) -> $l; the shell in this unit's folder after each"

[ -z "$unpub" ] || die "no published hash for:$unpub - check the captures, then copy the md5s above into receipts.md5 and run again"
echo "c6-unit18: every capture 3/3 and = published; every spoken number asserted; 0 raw demo tokens in every capture and every log"
