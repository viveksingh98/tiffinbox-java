#!/bin/bash
XPATH=$PATH                                           # the PATH you started this with: the exercise's own shell gets it
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25.0.4.1 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# Course 6 · Error-Handling Traps - this unit's receipts. No anchor change: anchor/ is the link to ../c6-unit16/after, the tree the
# problem-detail lesson froze (= c6-tiffinbox at Section 3's end, the tree the viewer last saw). This script copies that tree under
# .harness/anchor, builds it and runs it - as its README runs it, and on its class path with the course's harness joined
# (harness/probe/web, outside com.tiffinbox) - and shows what still slips past the last three lessons' error handling: an exception
# thrown in a servlet filter, a catch-all exception handler, an answer that fails after it has started to leave, an answer Tomcat
# gives before Spring MVC ever sees the request, and an exception handler that fails itself. Six captures, each run three times and
# hashed; cap() DIES when a hash differs from receipts.md5; every number the video says is asserted at the bottom by a check that
# can fail; the demo token is masked (gsub), and the checks count 0 raw copies of it in every capture, in the log of every run and
# in every file this unit ships.
#   filter     the anchor built and extracted; the harness compiled; the seven on the jar; who answers (the harness's Who: the
#              advice cache in order); A/B/A': a filter that throws (the harness's BoomFilter) - A, alone; B, with a filter ahead of
#              it that hands the exception to Spring MVC's resolvers (ResolvingFilter); A', A again; C (labelled): B with a
#              catch-all joined; D (labelled): A with a catch-all joined; E (labelled): A at DEBUG, every line one request added
#   catchall   the anchor as it ships, then a catch-all exception handler joined three ways - the key off, the key on, ordered
#              first: each one's seven (a fresh JVM, the lines that moved), its advice cache, and eight requests - Spring MVC's
#              own errors, a name nobody has, a route that throws - each with the WARN and ERROR lines it added
#   committed  two routes that fail after the answer has started to leave (the harness's Committed): each answer's status, what
#              curl got and its exit code, the lines the log gained; C (labelled): a short list that fails before anything has left
#   tomcat     an encoded slash at DEBUG (Tomcat's own 400, and the lines the log gained: none) against a request Spring MVC
#              takes; A/B/A': a route that throws, asked for HTML - A, Boot's default; B, Boot's Whitelabel page switched off;
#              A', A again
#   handler    the anchor as it ships: a name nobody has, for clients that accept only HTML, an image, plain text; then an exception
#              handler with a bug joined (the harness's Fragile): a path nobody maps
#   exercise   exercise/README.md's commands, then exercise/solution/SOLUTION.md's, read from the files and run as written, one after
#              the other in ONE shell a viewer could have: env -i, /bin/bash, started in this folder
# "The anchor" is anchor/, the link to ../c6-unit16/after, COPIED under .harness/anchor; this script never writes into another unit's
# folder, and never builds a frozen tree in place. Every run of TiffinBox starts in .harness/anchor, which holds a config tree with a
# fake token (secrets/), as the README asks. Commands are printed exactly as they run: each goes through eval. "$CURLSET" is the
# comparison set since the secrets lesson (../c5-unit11/curlset.sh: the seven requests, POST /shutdown with the token's header read
# from the file). "$M2" is this unit's own repository, .m2-demo. The harness - harness/probe/web (compiled with -parameters): Boom
# (a route that throws), BoomFilter and ResolvingFilter (two filter beans Boot registers), CatchAll and CatchAllFirst (two catch-all
# advices), Committed (two routes that fail mid-answer), Fragile (an exception handler with a bug), Who (the advice cache, read off
# the running application) - is the course's, never TiffinBox's: outside com.tiffinbox, joined by --spring.main.sources on the
# extracted jar's class path, and named on every capture that uses it; harness/shutdown.sh is POST /shutdown with the token read from
# its file. Every run passes options only. The seven run first, on a fresh JVM of the jar.
# The locale: the JVM ignores LC_ALL on macOS - it takes the Mac's first language - and Spring's, Jackson's and Tomcat's messages in
# the log and in the answers, and Boot's Whitelabel page, are written in the JVM's locale: so every JVM this script starts has its
# locale pinned on its run line (-Duser.language=en -Duser.country=US, before -jar or -cp: at() puts it there, README.md "The
# commands this unit adds"), and Who prints it.
# The network: every Maven build runs offline (-o) against .m2-demo and says so ("offline: yes"); a build that cannot resolve an
# artifact offline goes to Maven Central once, and says that ("offline: no - ..."). No native build and no Docker: this unit measures
# the JVM alone. At run time nothing leaves 127.0.0.1: TiffinBox listens there, every request goes there, and Logback writes to the
# terminal only.
# Masks and filters (README.md declares each; awk sub/gsub only): the demo token becomes "[masked: the N-character token]" (N its
# own length); this folder's absolute path "…", the folder above it "…/..", the home folder "~"; your user name "<user>" - in every
# line of every capture. Spring's error timestamp becomes "…" (both forms) in the seven and wherever an answer is printed; in a map
# Spring MVC logs at DEBUG, "timestamp=…,". Boot's Whitelabel page is printed as its <h1> and its error line, its created date (the
# JVM's time zone) masked and its paragraph counted, never shown; any other HTML page (Tomcat's own) as its <h1> and its length. A
# run's log lines are printed from their logger on (no time, no process id, no thread); Boot's first line is cut before " with PID".
# A WARN or ERROR record is printed as its level, logger and message, then the exception line under it; its stack frames are bounded
# ("over 40") and its other lines counted, never shown. A problem detail is printed as the answer's bytes, never re-ordered. An answer
# saved to a file (committed) is printed as its lines, or - JSON - as whether it parses, how many items it holds, its first and its
# last; never its byte count. No duration is captured.
# Ports (brief ⚑1, 19460-19469): filter - the seven, Who, A, A' and D 19460, B 19461, C 19462, E 19463 · catchall - as it ships 19464,
# the key off 19465, the key on 19466, ordered first 19467 · committed 19468 · tomcat - DEBUG 19461, A and A' 19462, B 19463 ·
# handler - as it ships 19464, Fragile 19465 · the exercise 19469. Captures run one after another, each JVM stopped before the next
# starts on its port. 18425 (TiffinBox's default), 8080 (Tomcat's) and 35729 (DevTools' Live Reload) are checked free too, and never
# bound.
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
[ -e secrets ] && die "this folder holds a secrets/ - remove it: every run here starts in a folder under .harness/"
[ -L anchor ] && [ "$(readlink anchor)" = ../c6-unit16/after ] || die "anchor must be the link to ../c6-unit16/after - this unit changes nothing in the anchor"
[ -f anchor/pom.xml ] && [ -f anchor/README.md ] && [ -f anchor/tiffinbox-web/pom.xml ] || die "the anchor (its pom.xml, README.md or web module's pom.xml) is missing"
[ -e anchor/secrets ] || [ -e anchor/target ] || [ -e anchor/tiffinbox-web/target ] || [ -e anchor/tiffinbox-core/target ] || [ -e anchor/tiffinbox-local.yaml ] && die "anchor/ holds a secrets/, a target/ or a tiffinbox-local.yaml - it is a frozen copy, never built in place"
M2="$PWD/.m2-demo"; U="$PWD"; UP="$(cd .. && pwd)"; ME="$(id -un)"
TF=secrets/tiffinbox/shutdown-token                  # the config tree's file for tiffinbox.shutdown-token
# The demo token. FAKE, and meant to look it: it guards nothing but a demo server on 127.0.0.1 that every capture stops. It is
# written into .harness/anchor/secrets/ (git-ignored) when this script runs, and no capture prints it: see mask().
TOKEN=demo-token-for-trap-hunts
[ ${#TOKEN} = 25 ] || die "the demo token must be 25 characters: the published captures name its length"
CURLSET=../c5-unit11/curlset.sh                      # the comparison set: the seven requests, POST /shutdown with the header
[ -f "$CURLSET" ] || die "$CURLSET is missing"
HWS='harness/probe/web/Boom.java harness/probe/web/BoomFilter.java harness/probe/web/CatchAll.java harness/probe/web/CatchAllFirst.java harness/probe/web/Committed.java harness/probe/web/Fragile.java harness/probe/web/ResolvingFilter.java harness/probe/web/Who.java'
for f in harness/shutdown.sh $HWS exercise/README.md exercise/solution/SOLUTION.md README.md; do [ -f "$f" ] || die "$f is missing"; done
[ "$(ls harness/probe/web | paste -sd' ' -)" = 'Boom.java BoomFilter.java CatchAll.java CatchAllFirst.java Committed.java Fragile.java ResolvingFilter.java Who.java' ] || die "harness/probe/web holds another file: javac compiles all of it"

# The ports, BEFORE anything is wiped (a survivor of an interrupted run answers POST /shutdown only with its token, which lives in
# .harness/ - so the message names the process to kill).
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
for p in 18425 8080 35729 19460 19461 19462 19463 19464 19465 19466 19467 19468 19469; do
  [ "$(listeners $p)" = 0 ] || die "something already listens on $p - this unit's ports must be free; if it is a TiffinBox an interrupted run left behind, stop it: kill $(lsof -nP -iTCP:$p -sTCP:LISTEN -t 2> /dev/null | paste -sd' ' -)"; done

# ---- the commands: read from anchor/README.md, the anchor's own, and asserted - each line must be there, whole ---------------
readme() { grep -m1 -xF -- "$1" anchor/README.md > /dev/null || die "anchor/README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
J='java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431'
CPL='"tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431'
R_PLAIN=$(readme 'mvn -B package')
R_RUN=$(readme "$J")
R_WEB=$(readme "$J --logging.level.web=debug")
R_EXTRACT=$(readme 'java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted')
R_CP=$(readme "java -cp $CPL")
R_READY=$(readme "curl -s -w ' %{http_code}\n' http://127.0.0.1:18431/actuator/health/readiness")
R_ONE=$(readme "curl -s -w ' %{http_code}\n' http://127.0.0.1:18431/customers/Ravi")
R_POST=$(readme "curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '{\"name\":\"Asha\",\"mealsPerDay\":2,\"pricePerMeal\":110,\"mealType\":\"VEG\"}' http://127.0.0.1:18431/customers")
R_NOBODY=$(readme "curl -s -w ' %{http_code}\n' http://127.0.0.1:18431/customers/Nobody")
R_PD=$(readme "curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' http://127.0.0.1:18431/customers/Nobody")
WS=" -w ' %{http_code}\n'"; WT=" -w ' %{http_code} · Content-Type: [%{content_type}]\n'"
[ "${R_WEB#"$J "}" = '--logging.level.web=debug' ] || die "the README's options"
O_WEB=${R_WEB#"$J "}
r=${R_NOBODY/"$WS"/$WT}; [ "$r" = "$R_PD" ] || die "the anchor's Content-Type line must be the exception-handler lesson's line with curl's Content-Type printed, and nothing else"
P_='/customers/Ravi'; Q_='/customers/Nobody'; r=${R_ONE/"$P_"/$Q_}; [ "$r" = "$R_NOBODY" ] || die "the exception-handler lesson's line must be the one-customer line with the name Nobody"
B_ASHA='{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}'
r=${R_POST#*--data \'}; [ "${r%%\' http://*}" = "$B_ASHA" ] || die "the request-body lesson's body"
# one more body, made from it (README.md, "The commands this unit adds"): the body cut after its first key - JSON nobody can read
B_CUT=${B_ASHA%%\"Asha\"*}; [ "$B_CUT" = '{"name":' ] || die "the cut body"
# This unit's own lines (README.md, "The commands this unit adds") - each asserted to be exactly that: the anchor's run and class-path
# lines with the JVM's locale pinned; the class-path line with one of Boot's keys (problem details off, the Whitelabel page off); the
# harness's javac line; the anchor's Content-Type line with one header and another path; the request-body lesson's line with curl's
# Content-Type printed; the anchor's Content-Type line saving its answer to a file, another path; the harness's question
mine() { grep -m1 -xF -- "$1" README.md > /dev/null || die "README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
JL='-Duser.language=en -Duser.country=US'
L_RUNL=$(mine "java $JL -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431")
L_CPL=$(mine "java $JL -cp $CPL")
L_OFF=$(mine "$L_CPL --spring.mvc.problemdetails.enabled=false")
L_WL=$(mine "$L_CPL --spring.web.error.whitelabel.enabled=false")
L_JAVAC=$(mine "javac -parameters -d .harness/hc -cp \".harness/anchor/tiffinbox-web/target/extracted/lib/*\" $HWS")
L_BOOM=$(mine "curl -s$WT -H 'X-Boom: status' http://127.0.0.1:18431/customers/Ravi")
L_POSTT=$(mine "curl -s$WT -H 'Content-Type: application/json' --data '$B_ASHA' http://127.0.0.1:18431/customers")
L_GOT=$(mine "curl -s -o .harness/got.txt$WT http://127.0.0.1:18431/probe/committed")
L_WHO=$(mine "curl -s http://127.0.0.1:18431/probe/who/advice")
# The derivations, each asserted
P_='java '; Q_="java $JL "; r=${R_RUN/"$P_"/$Q_}; r2=${R_CP/"$P_"/$Q_}
[ "$r" = "$L_RUNL" ] && [ "$r2" = "$L_CPL" ] || die "the pinned lines must be the anchor's run and class-path lines with $JL after java, and nothing else"
for l_ in "$L_OFF" "$L_WL"; do o_=${l_#"$L_CPL "}; case $o_ in --*=*) ;; *) die "a class-path line with one option more: $l_" ;; esac; [ "${o_#* }" = "$o_" ] || die "one option, no more: $l_"; done
O_OFF=${L_OFF#"$L_CPL "}; O_WL=${L_WL#"$L_CPL "}
[ "${L_JAVAC#* -cp \"*\" }" = "$HWS" ] || die "the harness's javac line must compile the eight files in harness/probe/web, and nothing else"
P_=" -H 'X-Boom: status'"; r=${L_BOOM/"$P_"/}; P_='/customers/Ravi'; Q_='/customers/Nobody'; r=${r/"$P_"/$Q_}; [ "$r" = "$R_PD" ] || die "the filter's line must be the anchor's Content-Type line with one header and the name Ravi, and nothing else"
r=${R_POST/"$WS"/$WT}; [ "$r" = "$L_POSTT" ] || die "the POST line must be the request-body lesson's with curl's Content-Type printed, and nothing else"
P_=' -o .harness/got.txt'; r=${L_GOT/"$P_"/}; P_='/probe/committed'; Q_='/customers/Nobody'; r=${r/"$P_"/$Q_}; [ "$r" = "$R_PD" ] || die "the saved-answer line must be the anchor's Content-Type line with -o and another path, and nothing else"
r=${R_ONE/"$WS"/}; P_='/customers/Ravi'; Q_='/probe/who/advice'; r=${r/"$P_"/$Q_}; [ "$r" = "$L_WHO" ] || die "the harness's question must be the one-customer line without its -w, another path"
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
# qurl PORT PATH: the URL; one that holds a character the shell reads (; ? & * { } or a space) is single-quoted, so eval hands it to
# curl whole
qurl() { local u="http://127.0.0.1:$1$2"; case $2 in *[\;\?\&\*\{\}\ ]*) u="'$u'" ;; esac; printf '%s\n' "$u"; }
# tq PORT PATH ['ACCEPT']: the anchor's Content-Type line - the body, the status and curl's Content-Type - its path PATH, and, when
# given, one Accept header; with none, curl's own Accept: */*
tq() { local c=${R_PD% http://*} h=""; [ -z "${3:-}" ] || h=" -H 'Accept: $3'"; printf '%s%s %s\n' "$c" "$h" "$(qurl "$1" "$2")"; }
# bq PORT WHAT ['ACCEPT']: this unit's filter line - X-Boom: WHAT on the one-customer path - and, when given, one Accept header
bq() { local c=${L_BOOM% http://*} h="" P_="'X-Boom: status'" Q_="'X-Boom: $2'"; c=${c/"$P_"/$Q_}; [ -z "${3:-}" ] || h=" -H 'Accept: $3'"; printf '%s%s %s\n' "$c" "$h" "$(qurl "$1" /customers/Ravi)"; }
# pq PORT 'BODY' ['CONTENT-TYPE']: this unit's POST line, its body BODY, and its Content-Type header CONTENT-TYPE when given
pq() { local c=${L_POSTT/:18431\//:$1/} P_="$B_ASHA" Q_="$2"; c=${c/"$P_"/$Q_}; if [ -n "${3:-}" ]; then P_="-H 'Content-Type: application/json'"; Q_="-H 'Content-Type: $3'"; c=${c/"$P_"/$Q_}; fi; printf '%s\n' "$c"; }
# gq PORT PATH: this unit's saved-answer line, its path PATH
gq() { local c=${L_GOT/:18431\//:$1/}; printf '%s\n' "${c/\/probe\/committed/$2}"; }
# exe 'COMMAND': the command with "exec" after its "cd DIR && " - so $pid is the program's
exe() { printf '%s\n' "$1" | sed -E 's/&& (([A-Z_]+=[^ ]* )*)/\&\& \1exec /'; }
C_PRE=$(off .harness/pre "$R_PLAIN" package)
[ "$(dev "$C_PRE")" = "$R_PLAIN" ] || die "not the README's build line with the offline changes: $C_PRE"
[ "$(exe "$(at .harness/x 19460 "$R_RUN")")" = "cd .harness/x && exec ${L_RUNL/18431/19460}" ] && [ "$(at .harness/x 18431 "$R_CP")" = "cd .harness/x && $L_CPL" ] && [ "$(at .harness/x 18431 "$R_EXTRACT")" = "cd .harness/x && $R_EXTRACT" ] || die "at(): the pinned lines are not README.md's"
[ "$(hcp .harness/x 19465 probe.web.CatchAll "$O_OFF")" = 'cd .harness/x && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19465 --spring.main.sources=probe.web.CatchAll --spring.mvc.problemdetails.enabled=false' ] || die "hcp()"
[ "$(tq 18431 /customers/Nobody)" = "$R_PD" ] && [ "$(bq 18431 status)" = "$L_BOOM" ] && [ "$(pq 18431 "$B_ASHA")" = "$L_POSTT" ] && [ "$(gq 18431 /probe/committed)" = "$L_GOT" ] || die "tq(), bq(), pq() or gq()"
[ "$(bq 19460 state text/html)" = "curl -s$WT -H 'X-Boom: state' -H 'Accept: text/html' http://127.0.0.1:19460/customers/Ravi" ] && [ "$(tq 19460 '/customers?mealType=veg')" = "curl -s$WT 'http://127.0.0.1:19460/customers?mealType=veg'" ] || die "bq() or tq() with a header or a quoted path"
echo "  the commands: anchor/README.md gives the 11 lines this script runs or derives from; README.md the 9 this unit adds"

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
# moved BEFORE AFTER: two masked sets, line by line - each line that differs, before and after; the numbers of those that do not
moved() { python3 - "$1" "$2" <<'PY'
import sys
a = open(sys.argv[1]).read().splitlines(); b = open(sys.argv[2]).read().splitlines()
assert len(a) == len(b) == 7, (len(a), len(b))
d = [i for i in range(7) if a[i] != b[i]]; s = [i for i in range(7) if a[i] == b[i]]
print("  the lines that moved, against the anchor as it ships: %d (%s) · the same, byte for byte: %d (%s)" % (len(d), " ".join(str(i + 1) for i in d) or "none", len(s), " ".join(str(i + 1) for i in s)))
for i in d:
    print("    line %d, as it ships: %s" % (i + 1, a[i]))
    print("    line %d, here:        %s" % (i + 1, b[i]))
PY
}
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
# recs FROM: each WARN or ERROR record the log gained after line FROM - its level, its logger and its message; then the exception line
# under it (the first line after the record that is neither blank nor a stack frame); its stack frames, bounded ("over 40"), and its
# other lines, counted - none shown
recs() { awk -v from="$1" '
  function out() { if (inr) print "      its stack frames: " (fr > 40 ? "over 40" : fr + 0) ", its other lines: " (ot + 0) " - none shown"; inr = 0; fr = 0; ot = 0; ex = 0 }
  NR <= from { next }
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
# rq 'COMMAND': a curl line, printed and run, its answer through pagef; then the WARN and ERROR lines the request added, counted on
# the answer's last line, and each record (recs)
rq() { local n0 w e; n0=$(mark); echo "\$ $1"; (eval "$1") 2>&1 < /dev/null | pagef > .harness/ask.txt
  settle; w=$(logl "$n0" WARN | grep -c . || true); e=$(logl "$n0" ERROR | grep -c . || true)
  awk -v w="$w" -v e="$e" '{ l[NR] = $0 } END { for (i = 1; i <= NR; i++) print l[i] (i == NR ? " · WARN lines it added: " w " · ERROR lines: " e : "") }' .harness/ask.txt
  [ "$w$e" = 00 ] || recs "$n0"; }
# rp 'COMMAND': a command, printed and run, its output indented
rp() { echo "\$ $1"; (eval "$1") 2>&1 < /dev/null | sed 's/^/  /'; }
# dbg FROM: every line the log gained after line FROM, from its logger on (logger: message) - a map's timestamp masked; dreq
# 'COMMAND': at DEBUG - the command printed and run, its answer through pagef, then every log line the request added, counted, and
# how many of them are Spring MVC's DispatcherServlet's; the lines that are no log line (a stack trace's), counted, never shown
dbg() { awk -v from="$1" 'NR > from && / [A-Z]+ [0-9]+ --- \[/ { s = $0; i = index(s, " --- ["); s = substr(s, i + 6); i = index(s, "] "); s = substr(s, i + 2)
    i = index(s, " : "); lg = substr(s, 1, i - 1); sub(/ +$/, "", lg); m = substr(s, i + 3); gsub(/timestamp=[^,]*,/, "timestamp=…,", m); print "    " $2 " " lg ": " m }' .harness/run.out; }
dreq() { local n0 k d o; n0=$(mark); echo "\$ $1"; (eval "$1") 2>&1 < /dev/null | pagef; settle
  k=$(dbg "$n0" | grep -c . || true); d=$(dbg "$n0" | grep -c ' o\.s\.web\.servlet\.DispatcherServlet: ' || true); o=$(awk -v from="$n0" 'NR > from && !/ [A-Z]+ [0-9]+ --- \[/' .harness/run.out | grep -c . || true)
  echo "  the log lines it added, Boot's web group at DEBUG (level logger: message) - all $k, of them Spring MVC's DispatcherServlet's: $d; and $o other lines (a stack trace's), not shown:"; dbg "$n0"; }
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

# ---- filter: a filter that throws (A/B/A'; C, D, E labelled) -------------------------------------------------------------------
fq() { rq "$(bq "$1" status)"; rq "$(bq "$1" state)"; rq "$(bq "$1" state text/html)"; rq "$(tq "$1" /customers/Ravi)"; WARNS; }
frun() { start "$(hcp .harness/anchor "$1" "$2")"; up "$1"; ready "$1"; fq "$1"; stop "$1" .harness/anchor; }
filter() {
  echo "the anchor - anchor/, copied under .harness/ with a config tree, built with its README's line (offline), its jar extracted (the README's line):"
  copy anchor .harness/anchor; pbuild .harness/anchor "the anchor"; extract .harness/anchor
  echo "the harness, compiled against the anchor's own jar - with -parameters (this unit's line):"
  echo "\$ $L_JAVAC"; rm -rf .harness/hc; (eval "$L_JAVAC") > .harness/javac.log 2>&1 < /dev/null || { cat .harness/javac.log >&3; die "the harness did not compile against the anchor's jar"; }
  echo "  exit 0 · its classes: $(cd .harness/hc && find . -name '*.class' | sed 's#^\./##' | sort | paste -sd' ' -)"
  echo "the seven - the anchor, the README's run line (its locale pinned), port 19460, a fresh JVM:"
  start "$(at .harness/anchor 19460 "$R_RUN")"; up 19460; ready 19460; seven 19460 .harness/anchor; WARNS; logl 0 WARN
  echo "who answers - the anchor on its class path, the harness's Who joined, port 19460, read off the running application:"
  start "$(hcp .harness/anchor 19460 probe.web.Who)"; up 19460; ready 19460; rp "$(url "$L_WHO" 19460)"; stop 19460 .harness/anchor
  echo "A - the anchor on its class path, the harness's BoomFilter joined (a filter bean Boot registers), port 19460: X-Boom: status, X-Boom: state, X-Boom: state for HTML (only HTML, sent by curl), then a request the filter lets through:"
  frun 19460 probe.web.BoomFilter
  echo "B - the same, with the harness's ResolvingFilter joined too (a filter bean ordered first, which hands an exception to Spring MVC's resolvers), port 19461:"
  frun 19461 probe.web.ResolvingFilter,probe.web.BoomFilter
  echo "A' - A again, a fresh JVM, port 19460:"
  frun 19460 probe.web.BoomFilter
  echo "A' against A, its label aside, line for line the same: $(asame "A - " "B - " "A' - " "A' against A")"
  echo "C (labelled) - B with the harness's CatchAll joined (an advice with a handler for Exception), port 19462:"
  start "$(hcp .harness/anchor 19462 probe.web.ResolvingFilter,probe.web.BoomFilter,probe.web.CatchAll)"; up 19462; ready 19462
  rq "$(bq 19462 status)"; rq "$(bq 19462 state)"; WARNS; stop 19462 .harness/anchor
  echo "D (labelled) - A with the harness's CatchAll joined, port 19460:"
  frun 19460 probe.web.BoomFilter,probe.web.CatchAll
  echo "D against A, the line that started each JVM aside, line for line the same: $(ssame "A - " "B - " "D (labelled)" "D against A")"
  echo "E (labelled) - A at DEBUG (the embedded-Tomcat lesson's option: Boot's web group), port 19463 - X-Boom: status, every log line it added:"
  start "$(hcp .harness/anchor 19463 probe.web.BoomFilter "$O_WEB")"; up 19463; ready 19463
  dreq "$(bq 19463 status)"; stop 19463 .harness/anchor; }

# ---- catchall: a catch-all exception handler, three ways ------------------------------------------------------------------------
cq8() { rq "$(tq "$1" /nowhere)"; rq "$(tq "$1" /shutdown)"; rq "$(tq "$1" '/customers?mealType=veg')"; rq "$(pq "$1" "$B_CUT")"
  rq "$(pq "$1" "$B_ASHA" application/x-www-form-urlencoded)"; rq "$(tq "$1" /customers application/xml)"; rq "$(tq "$1" /customers/Nobody)"; rq "$(tq "$1" /probe/boom)"; WARNS; }
# crun PORT 'CLASSES' ['OPTION']: the seven on a fresh JVM, the lines that moved (against the anchor as it ships, 19464's), then a
# second JVM: the advice cache and the eight requests
crun() { start "$(hcp .harness/anchor "$1" "probe.web.Who${2:+,$2}" "${3:-}")"; up "$1"; ready "$1"; seven "$1" .harness/anchor; WARNS
  [ "$1" = 19464 ] || moved .harness/seven-19464.txt ".harness/seven-$1.txt"
  echo "  then the advice cache and eight requests, a fresh JVM:"
  start "$(hcp .harness/anchor "$1" "probe.web.Who,probe.web.Boom${2:+,$2}" "${3:-}")"; up "$1"; ready "$1"
  rp "$(url "$L_WHO" "$1")"; cq8 "$1"; stop "$1" .harness/anchor; }
catchall() {
  echo "the anchor as it ships (the key on), on its class path, the harness's Who and Boom joined, port 19464:"
  crun 19464 ""
  echo "the key off for this run (this unit's line), the harness's CatchAll joined (a handler for Exception, the default order), port 19465:"
  crun 19465 probe.web.CatchAll "$O_OFF"
  echo "the key on, as the anchor has it, the harness's CatchAll joined, port 19466:"
  crun 19466 probe.web.CatchAll
  echo "the key on, the harness's CatchAllFirst joined instead (the same handler, ordered first), port 19467:"
  crun 19467 probe.web.CatchAllFirst; }

# ---- committed: an answer that fails after it has started to leave --------------------------------------------------------------
# gqr PORT PATH: this unit's saved-answer line at PORT for PATH, printed and run; curl's status line and exit code; what curl got
# (sumf); the WARN and ERROR lines the request added, counted, and each record
gqr() { local n0 c e=0 w r; n0=$(mark); c=$(gq "$1" "$2"); rm -f .harness/got.txt; echo "\$ $c"; (eval "$c") > .harness/gq.out 2>&1 < /dev/null || e=$?
  echo "  curl's line:$(cat .harness/gq.out) · curl's exit code: $e"; sumf .harness/got.txt; settle
  w=$(logl "$n0" WARN | grep -c . || true); r=$(logl "$n0" ERROR | grep -c . || true)
  echo "  WARN lines it added: $w · ERROR lines: $r"; [ "$w$r" = 00 ] || recs "$n0"; }
committed() {
  echo "the anchor on its class path, the harness's Committed joined, port 19468 - a route that writes a line, flushes it and throws; then a route whose JSON fails at its 1,500th item of 2,000:"
  start "$(hcp .harness/anchor 19468 probe.web.Committed)"; up 19468; ready 19468
  gqr 19468 /probe/committed; gqr 19468 /probe/meals
  echo "C (labelled) - the same JVM: a short list, 10 meals whose 5th fails as Jackson writes it - before anything has gone out:"
  gqr 19468 /probe/short; WARNS; stop 19468 .harness/anchor; }

# ---- tomcat: before Spring MVC; A/B/A' Boot's Whitelabel page ------------------------------------------------------------------
wrun() { start "$(hcp .harness/anchor "$1" probe.web.Boom "${2:-}")"; up "$1"; ready "$1"
  rq "$(tq "$1" /probe/boom text/html)"; rq "$(tq "$1" /probe/boom)"; rq "$(tq "$1" /nowhere text/html)"; WARNS; stop "$1" .harness/anchor; }
tomcat() {
  echo "before Spring MVC - the anchor on its class path, the harness's Boom joined, Boot's web group at DEBUG (the embedded-Tomcat lesson's option), port 19461: a name with an encoded slash, curl's own Accept and JSON's; then a request Spring MVC takes:"
  start "$(hcp .harness/anchor 19461 probe.web.Boom "$O_WEB")"; up 19461; ready 19461
  dreq "$(tq 19461 /customers/a%2Fb)"; dreq "$(tq 19461 /customers/a%2Fb application/json)"; dreq "$(tq 19461 /customers/Ravi)"
  stop 19461 .harness/anchor
  echo "A - the anchor on its class path, the harness's Boom joined, port 19462: a route that throws, for HTML (only HTML, sent by curl) and for curl's own Accept; a path nobody maps, for HTML:"
  wrun 19462
  echo "B - the same, Boot's Whitelabel page switched off for this run (this unit's line), port 19463:"
  wrun 19463 "$O_WL"
  echo "A' - A again, a fresh JVM, port 19462:"
  wrun 19462
  echo "A' against A, its label aside, line for line the same: $(asame "A - " "B - " "A' - " "A' against A")"; }

# ---- handler: answers that do not fail, and a handler that does ------------------------------------------------------------------
handler() {
  echo "the anchor as it ships, the README's run line (its locale pinned), port 19464: a path nobody maps; a name nobody has, for a client that accepts only HTML, only an image, only plain text - each sent by curl:"
  start "$(at .harness/anchor 19464 "$R_RUN")"; up 19464; ready 19464
  rq "$(tq 19464 /nowhere)"; rq "$(tq 19464 /customers/Nobody text/html)"; rq "$(tq 19464 /customers/Nobody image/png)"; rq "$(tq 19464 /customers/Nobody text/plain)"
  WARNS; stop 19464 .harness/anchor
  echo "the anchor on its class path with the harness's Fragile joined - an exception handler with a bug, ordered first, for a path nobody maps - and Who, port 19465:"
  start "$(hcp .harness/anchor 19465 probe.web.Fragile,probe.web.Who)"; up 19465; ready 19465
  rp "$(url "$L_WHO" 19465)"; rq "$(tq 19465 /nowhere)"; rq "$(tq 19465 /customers/Nobody)"; WARNS; stop 19465 .harness/anchor; }

# ---- exercise: the README's commands, exactly as written, then the solution's - in ONE shell --------------------------------------
block() { awk '/^```bash$/ { if (!d) { f = 1 }; next } f && /^```$/ { f = 0; d = 1 } f' "$1"; }
# The shell a viewer has: env -i - nothing this script set reaches it (its JAVA_HOME, the JDK at the front of its PATH, LC_ALL,
# no_proxy) - with HOME and the PATH you started this script with; /bin/bash without profile or rc files, started in this folder.
# A driver in .harness/ runs the README's block, then SOLUTION.md's, as a viewer pastes them - each with its output, its exit code
# and the folder it left the shell in kept apart (absolute paths: a command that moved the shell must not move these files), and
# the README's run log and handler list kept before the solution's run writes its own. Bounded (600 s); on the way out, or past the
# bound, the shell and every process under it are stopped (killtree).
# where DIR: the folder the shell was left in - this unit's folder, a folder under it (named), or elsewhere
where() { case "$1" in "$U") echo "this unit's folder" ;; "$U"/*) echo "${1#"$U"/}" ;; *) echo "outside this unit's folder" ;; esac; }
# hlist FILE: the handler list Who wrote - its advice cache lines (the advices, in order, each with its order) and the line for one
# exception type, a wrong verb's
hlist() { grep -E '^ExceptionHandlerExceptionResolver|^  [0-9] |^a HttpRequestMethodNotSupportedException' "$1" | sed 's/^/    /' || echo "    (no handler list)"; }
exercise() { local setup sol i=0 e1 d1 e2 d2 l1 l2 r
  setup=$(block exercise/README.md); sol=$(block exercise/solution/SOLUTION.md)
  [ -n "$setup" ] && [ -n "$sol" ] || die "exercise/README.md or SOLUTION.md no longer gives its commands"
  [ "$(printf '%s\n' "$sol" | grep -c .)" = 3 ] || die "SOLUTION.md's first bash block must be the README's two export lines and its last line, one class taken out"
  [ "$(printf '%s\n' "$sol" | sed -n 1,2p)" = "$(printf '%s\n' "$setup" | sed -n 1,2p)" ] || die "SOLUTION.md must start with the README's two export lines (a new shell's java may be another JDK)"
  printf '%s\n' "$sol" | sed -n 1p | grep -qxF 'export JAVA_HOME=/opt/homebrew/opt/openjdk@25' || die "SOLUTION.md's first line must export this script's JAVA_HOME"
  l1=$(printf '%s\n' "$setup" | tail -1); l2=$(printf '%s\n' "$sol" | sed -n 3p)
  r=$(python3 -c 'import sys; a, b = "--spring.main.sources=probe.web.CatchAllFirst,probe.web.Who ", "--spring.main.sources=probe.web.Who "; l = sys.argv[1]; print(l.replace(a, b, 1) if l.count(a) == 1 else "")' "$l1")
  [ "$r" = "$l2" ] && [ "$l1" != "$l2" ] || die "SOLUTION.md's last line must be the README's last line with probe.web.CatchAllFirst taken out of its sources, and nothing else"
  rm -f .harness/ex-*
  printf '%s\n' "$setup" > .harness/ex-readme.sh; printf '%s\n' "$sol" > .harness/ex-sol.sh
  cat > .harness/ex-drive.sh <<'DRV'
cd "$1" || exit 1
. "$1/.harness/ex-readme.sh" > "$1/.harness/ex-readme.out" 2>&1 < /dev/null
echo "$? $PWD" > "$1/.harness/ex-readme.st"
cp "$1/.harness/mine/run.log" "$1/.harness/ex-readme.log" 2> /dev/null
cp "$1/.harness/mine/handlers.txt" "$1/.harness/ex-readme.handlers" 2> /dev/null
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
  echo "  the handler list it saved (../handlers.txt) - its advice cache, and a wrong verb's line:"; hlist .harness/ex-readme.handlers
  echo "  the shell is now in: $(where "$d1") · the copy's own token in its log: $(raw "$(head -1 .harness/mine/anchor/$TF)" .harness/ex-readme.log) times · WARN lines in its log: $(grep -c ' WARN ' .harness/ex-readme.log || true) · ERROR lines: $(grep -c ' ERROR ' .harness/ex-readme.log || true) · listening on 19469 now: $(listeners 19469)"
  echo "the solution's $(printf '%s\n' "$sol" | grep -c .) lines, next, in the same shell:"
  printf '%s\n' "$sol" | sed 's/^/  $ /'
  echo "  exit $e2 · what they printed:"; sed 's/^/    /' .harness/ex-sol.out
  echo "  the handler list it saved (../handlers.txt) - its advice cache, and a wrong verb's line:"; hlist .harness/mine/handlers.txt
  echo "  the shell is now in: $(where "$d2") · the copy's own token in its log: $(raw "$(head -1 .harness/mine/anchor/$TF)" .harness/mine/run.log) times · WARN lines in its log: $(grep -c ' WARN ' .harness/mine/run.log || true) · ERROR lines: $(grep -c ' ERROR ' .harness/mine/run.log || true) · listening on 19469 now: $(listeners 19469)"; }

cap filter filter
cap catchall catchall
cap committed committed
cap tomcat tomcat
cap handler handler
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
for f in .r-*.out README.md exercise/README.md exercise/solution/SOLUTION.md receipts.md5 harness/shutdown.sh $HWS; do
  [ "$(raw "$TOKEN" "$f")" = 0 ] || die "$f holds the demo token, raw"; done
for f in .r-*.out; do ! grep -qE '/Users/|/private/|/home/|/var/folders/' "$f" || die "$f holds an absolute path"; ! grep -qE 'c[0-9]-unit[0-9]|unit ?[0-9]' "$f" || die "$f holds a unit number"; ! grep -qE ' (with PID|started by) ' "$f" || die "$f holds Boot's process line"; ! grep -qE '^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T|"timestamp":"?[0-9]|timestamp=[A-Z0-9]|(exec|handler|task|utility)-[0-9]|GMT|CES?T|<div id=.created|[A-Z][a-z][a-z] [A-Z][a-z][a-z] [0-9]+ [0-9][0-9]:[0-9][0-9]' "$f" || die "$f holds a log line's time, a timestamp, a date or a thread's number"; ! grep -q "^$(printf '\t')at " "$f" || die "$f shows a stack frame"; ! grep -qE 'SpringCGLIB\$\$[0-9]' "$f" || die "$f holds a generated class's number"; ! grep -qE ':(8080|35729)([^0-9]|$)' "$f" || die "$f shows a bind on 8080 or 35729"; ! grep -q $'\r' "$f" || die "$f holds a carriage return"; ! grep -qiE '<html>|<!doctype' "$f" || die "$f shows an HTML page whole"; done
for f in receipts.sh README.md exercise/README.md exercise/solution/SOLUTION.md harness/shutdown.sh $HWS; do ! grep -qE "exposure\.include='?\*" "$f" || die "$f exposes every endpoint (R.42)"; done
# S3.21 (R.99): Boot 4.1 reads only spring.web.error.*, and Boot 3's keys (server, then error) are ignored without a word - no file of
# this unit names one (the name is split here, so this line does not spell it)
K3='server'; K3="$K3.error."
for f in receipts.sh README.md exercise/README.md exercise/solution/SOLUTION.md harness/shutdown.sh $HWS; do ! grep -qF "$K3" "$f" || die "$f names one of Boot 3's error keys - Boot 4.1 reads only spring.web.error.* (S3.21)"; done
# S3.18 (R.114): no trap reaches the anchor - its tree names none of the harness's classes, and no capture runs one but on a
# class-path line that joins it by --spring.main.sources
for c in BoomFilter ResolvingFilter CatchAll Fragile Committed; do ! grep -rqF "$c" anchor/tiffinbox-web/src anchor/tiffinbox-core/src || die "the anchor's sources name $c - a trap is shown on the harness, never in the anchor (S3.18)"; done
# S3.9 (R.105): no wait in this script, its checks or the exercise is bare - each names its pid ($! or a variable)
for f in receipts.sh exercise/README.md exercise/solution/SOLUTION.md; do ! grep -nE '(^|[;&|({] *)wait *($|[;&|)}])' "$f" | grep -vE '^[0-9]+: *#' > /dev/null || die "$f has a bare wait (S3.9)"; done
# no capture runs a command with a URL that is not 127.0.0.1's
for f in .r-*.out; do ! grep -E '^\$ ' "$f" | grep -oE 'https?://[^ '"'"']+' | grep -vE '^http://127\.0\.0\.1:' > /dev/null || die "$f runs a command with a URL that is not 127.0.0.1's"; done
# S3.1: every java line a capture starts pins the JVM's locale (the extract line prints nothing a locale changes)
for f in .r-*.out; do ! grep -E '^ *\$ (cd [^ ]+ && )?(exec )?java ' "$f" | grep -vF -- "java $JL " | grep -vF -- 'java -Djarmode=tools ' > /dev/null || die "$f starts a JVM without its locale pinned (S3.1)"; done
NL=$(cat .r-*.out | grep -cE "^  its log: the demo token 0 times · X-Shutdown-Token 0 times\$" || true)
echo "  tokens: 0 raw copies in $(ls .harness/raw-* | wc -l | tr -d ' ') raw capture runs, in $(ls .r-*.out | wc -l | tr -d ' ') captures; the demo token 0 in the logs of every JVM that served ($LOGS here; the published captures' $NL), the READMEs, the harness, the exercise and receipts.md5; no absolute path, no unit number, no process line, no log time, no timestamp, no date, no thread number, no stack frame, no whole HTML page, no 8080 or 35729, no carriage return in any capture; no Boot 3 error key; no trap in the anchor; no bare wait; every java line's locale pinned; every URL a capture runs is 127.0.0.1's"

S466='466c20ed7e0d5439cb052f32ce09de1b'
J4() { printf '  {"timestamp":"…","status":%s,"error":"%s","path":"%s"} %s · Content-Type: [application/json]' "$1" "$2" "$3" "$1"; }
WL() { printf "  the Whitelabel page (Boot's) - its <h1>: Whitelabel Error Page · its error line: There was an unexpected error (type=%s, status=%s). · its created date: masked · its paragraphs: 1, not shown · then curl's: %s · Content-Type: [text/html;charset=UTF-8]" "$1" "$2" "$2"; }
PJ=' · Content-Type: [application/problem+json]'
CA() { printf '  {"detail":"something went wrong","instance":"%s","status":500,"title":"Internal Server Error","handler":"%s"} 500%s' "$1" "$2" "$PJ"; }
PD403='  {"detail":"a filter said no","instance":"/customers/Ravi","status":403,"title":"Forbidden"} 403'"$PJ"
PD404='  {"detail":"No static resource nowhere.","instance":"/nowhere","status":404,"title":"Not Found"} 404'"$PJ"
PD405='  {"detail":"Method '"'"'GET'"'"' is not supported.","instance":"/shutdown","status":405,"title":"Method Not Allowed"} 405'"$PJ"
PDNOB='  {"detail":"no customer named Nobody","instance":"/customers/Nobody","status":404,"title":"Customer not found","name":"Nobody"} 404'"$PJ"
RAVI='  {"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"} 200 · Content-Type: [application/json]'
TOMF='    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: Servlet.service() for servlet [dispatcherServlet] in context with path [] threw exception'
TOMR="$TOMF [Request processing failed: java.lang.IllegalStateException: the kitchen is on fire] with root cause"

# "a filter that throws ... Boot's five hundred, not a problem detail ... a four oh three becomes a five hundred ... the
# DispatcherServlet never saw it ... hand it to Spring MVC's resolvers: four oh three ... the catch-all changes nothing" - filter
FO=$(cat .r-filter.out)
has "$FO" '  built the anchor · offline: yes · exit 0' "filter: the anchor built offline"
has "$FO" "  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 0 · md5 $S466" "filter: the seven $S466"
has "$FO" '    WARN o.s.web.servlet.PageNotFound: Request method '"'"'GET'"'"' is not supported' "filter: the seven's one WARN, PageNotFound"
has "$FO" '  exit 0 · its classes: probe/web/Boom.class probe/web/BoomFilter.class probe/web/CatchAll.class probe/web/CatchAllFirst.class probe/web/Committed$Meal.class probe/web/Committed$ShortMeal.class probe/web/Committed.class probe/web/Fragile.class probe/web/ResolvingFilter.class probe/web/Who.class' "filter: the harness's classes"
for l in '    1 org.springframework.boot.webmvc.autoconfigure.ProblemDetailsExceptionHandler · its order: 0' '        @ExceptionHandler handleException, from ResponseEntityExceptionHandler - takes 20 exception types' '    2 com.tiffinbox.web.TiffinBoxErrors · its order: 2147483647' "  a ResponseStatusException, each advice's method for it, in that order: ProblemDetailsExceptionHandler: handleException · TiffinBoxErrors: none" "  the JVM's locale: en_US"; do has "$FO" "$l" "filter: who answers"; done
FA=$(blk filter "A - " "B - "); FB=$(blk filter "B - " "A' - "); FC=$(blk filter "C (labelled)" "D (labelled)"); FE=$(blk filter "E (labelled)" '')
ans "$FA" "$(bq 19460 status)" "$(J4 500 'Internal Server Error' /customers/Ravi)" 0 1 "filter A: X-Boom: status"
ans "$FA" "$(bq 19460 state)" "$(J4 500 'Internal Server Error' /customers/Ravi)" 0 1 "filter A: X-Boom: state"
ans "$FA" "$(bq 19460 state text/html)" "$(WL 'Internal Server Error' 500)" 0 1 "filter A: X-Boom: state, for HTML"
ans "$FA" "$(tq 19460 /customers/Ravi)" "$RAVI" 0 0 "filter A: a request the filter lets through"
has "$FA" "$TOMF" "filter A: Tomcat's ERROR line"; has "$FA" '      org.springframework.web.server.ResponseStatusException: 403 FORBIDDEN "a filter said no"' "filter A: the 403 under Tomcat's ERROR"
has "$FA" "  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 3" "filter A: 3 ERROR, 0 WARN"
ans "$FB" "$(bq 19461 status)" "$PD403" 0 0 "filter B: X-Boom: status, a 403 problem detail"
ans "$FB" "$(bq 19461 state)" "$(J4 500 'Internal Server Error' /customers/Ravi)" 0 1 "filter B: X-Boom: state, still Boot's 500"
has "$FB" "  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 2" "filter B: 2 ERROR"
has "$FO" "A' against A, its label aside, line for line the same: yes" "filter: A' = A"
ans "$FC" "$(bq 19462 status)" "$PD403" 0 0 "filter C: the 403"
ans "$FC" "$(bq 19462 state)" "$(CA /customers/Ravi CatchAll)" 0 0 "filter C: a silent 500 problem detail"
has "$FC" "  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0" "filter C: 0 WARN, 0 ERROR"
has "$FO" "D against A, the line that started each JVM aside, line for line the same: yes" "filter: D = A - the catch-all changes nothing"
has "$FE" "  the log lines it added, Boot's web group at DEBUG (level logger: message) - all 6, of them Spring MVC's DispatcherServlet's: 2; and 29 other lines (a stack trace's), not shown:" "filter E: 6 lines, 2 the DispatcherServlet's"
has "$FE" '    DEBUG o.s.web.servlet.DispatcherServlet: "ERROR" dispatch for GET "/error", parameters={}' "filter E: the error dispatch"
has "$FE" '    DEBUG o.s.web.servlet.DispatcherServlet: Exiting from "ERROR" dispatch, status 500' "filter E: the error dispatch's end"
has "$FE" '    DEBUG s.w.s.m.m.a.RequestMappingHandlerMapping: Mapped to org.springframework.boot.webmvc.autoconfigure.error.BasicErrorController#error(HttpServletRequest)' "filter E: Boot's error controller"
[ "$(printf '%s\n' "$FE" | grep -c 'DispatcherServlet: ' )" = 2 ] && ! printf '%s\n' "$FE" | grep -qF 'DispatcherServlet: GET "/customers/Ravi"' || die "filter E: the DispatcherServlet saw only the error dispatch"
echo "  filter: the seven $S466, 1 WARN (PageNotFound); A: X-Boom: status and state -> Boot's 500 (Whitelabel for HTML), 1 ERROR each (Tomcat's), the 403 named under it; B: status -> 403 problem detail, 0/0; state still Boot's 500; A' = A; C: + CatchAll -> a 500 problem detail, 0 WARN 0 ERROR; D: A + CatchAll = A; E: 6 lines at DEBUG, the DispatcherServlet's 2 the error dispatch's"

# "the catch-all ... every four hundred a five hundred, and not a line in the log ... the key on: Spring MVC's errors come back,
# a missing customer still five hundred ... ordered first: everything, and even the warning goes" - catchall
CO=$(cat .r-catchall.out)
C0=$(blk catchall "the anchor as it ships" "the key off"); C1=$(blk catchall "the key off" "the key on, as"); C2=$(blk catchall "the key on, as" "the key on, the harness's CatchAllFirst"); C3=$(blk catchall "the key on, the harness's CatchAllFirst" '')
for t in "C0:19464:$S466:1:0" "C1:19465:826dbea9b1929049c516cfa786d15e0b:0:0" "C2:19466:$S466:1:0" "C3:19467:55155d95c6ffcc18b98856c18abcb279:0:0"; do
  IFS=: read -r b_ p_ h_ w_ e_ <<EOF_
$t
EOF_
  eval "B_=\$$b_"; has "$B_" "  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 0 · md5 $h_" "catchall $p_: the seven"; done
has "$C1" "  the lines that moved, against the anchor as it ships: 2 (5 6) · the same, byte for byte: 5 (1 2 3 4 7)" "catchall, the key off: lines 5 and 6"
has "$C2" "  the lines that moved, against the anchor as it ships: 0 (none) · the same, byte for byte: 7 (1 2 3 4 5 6 7)" "catchall, the key on: the seven unchanged"
has "$C3" "  the lines that moved, against the anchor as it ships: 2 (5 6) · the same, byte for byte: 5 (1 2 3 4 7)" "catchall, ordered first: lines 5 and 6"
has "$C1" '  the ResponseEntityExceptionHandler beans: 0' "catchall, the key off: Boot's handler gone"
has "$C1" '    1 probe.web.CatchAll · its order: 2147483647' "catchall, the key off: CatchAll first"
has "$C2" '    2 probe.web.CatchAll · its order: 2147483647' "catchall, the key on: CatchAll second"; has "$C2" '    3 com.tiffinbox.web.TiffinBoxErrors · its order: 2147483647' "catchall, the key on: TiffinBoxErrors third, at the same order"
has "$C3" '    1 probe.web.CatchAllFirst · its order: -2147483648' "catchall, ordered first: CatchAllFirst first"
# the eight requests, each config: the answer's status and its WARN and ERROR lines
cq8l() { printf '%s\n' "$(tq "$1" /nowhere)" "$(tq "$1" /shutdown)" "$(tq "$1" '/customers?mealType=veg')" "$(pq "$1" "$B_CUT")" "$(pq "$1" "$B_ASHA" application/x-www-form-urlencoded)" "$(tq "$1" /customers application/xml)" "$(tq "$1" /customers/Nobody)" "$(tq "$1" /probe/boom)"; }
chk8() { local b=$1 p=$2 want=$3 k=0 c g s w e
  while IFS= read -r c; do k=$((k + 1)); set -- $want; eval "t_=\${$k}"; s=${t_%%/*}; w=${t_#*/}; e=${w#*/}; w=${w%%/*}
    g=$(aft "\$ $c" "$b"); case $g in *" $s · Content-Type: ["*"] · WARN lines it added: $w · ERROR lines: $e") ;; *) die "catchall $p: request $k ($c): $s, $w WARN, $e ERROR - got: $g" ;; esac
  done <<EOF_
$(cq8l "$p")
EOF_
}
chk8 "$C0" 19464 "404/0/0 405/1/0 400/0/0 400/0/0 415/0/0 406/0/0 404/0/0 500/0/1"
chk8 "$C1" 19465 "500/0/0 500/0/0 500/0/0 500/0/0 500/0/0 500/0/0 500/0/0 500/0/0"
chk8 "$C2" 19466 "404/0/0 405/1/0 400/0/0 400/0/0 415/0/0 406/0/0 500/0/0 500/0/0"
chk8 "$C3" 19467 "500/0/0 500/0/0 500/0/0 500/0/0 500/0/0 500/0/0 500/0/0 500/0/0"
ans "$C0" "$(tq 19464 /customers/Nobody)" "$PDNOB" 0 0 "catchall, as it ships: Nobody's 404"
ans "$C0" "$(tq 19464 /probe/boom)" "$(J4 500 'Internal Server Error' /probe/boom)" 0 1 "catchall, as it ships: the route's 500, Tomcat's ERROR"
has "$C0" "$TOMR" "catchall, as it ships: Tomcat's ERROR line"
ans "$C2" "$(tq 19466 /customers/Nobody)" "$(CA /customers/Nobody CatchAll)" 0 0 "catchall, the key on: Nobody a silent 500"
ans "$C2" "$(tq 19466 /probe/boom)" "$(CA /probe/boom CatchAll)" 0 0 "catchall, the key on: the route's 500 silent"
ans "$C2" "$(tq 19466 /shutdown)" "$PD405" 1 0 "catchall, the key on: the 405 survives"
ans "$C3" "$(tq 19467 /shutdown)" "$(CA /shutdown CatchAllFirst)" 0 0 "catchall, ordered first: the 405 a silent 500"
for t in "C0:1:1" "C1:0:0" "C2:1:0" "C3:0:0"; do b_=${t%%:*}; r_=${t#*:}; eval "B_=\$$b_"; [ "$(printf '%s\n' "$B_" | grep "^  WARN lines in this run's log" | tail -1)" = "  WARN lines in this run's log, at Boot's default level: ${r_%%:*} · ERROR lines: ${r_#*:}" ] || die "catchall $b_: the eight requests' run, ${r_%%:*} WARN and ${r_#*:} ERROR"; done
echo "  catchall: as it ships - the seven $S466, the 405 1 WARN (PageNotFound), the route's 500 1 ERROR (Tomcat's); the key off + CatchAll - Boot's handler gone, all eight 500, the seven 826dbea9 (lines 5, 6), 0 WARN 0 ERROR; the key on + CatchAll - Spring MVC's six survive ($S466), Nobody and the route 500, silent; CatchAllFirst - all eight 500, the seven 55155d95, 0 WARN 0 ERROR"

# "a two hundred, half an answer ... Tomcat's error line, and Boot's warning ... valid JSON, fifteen hundred of two thousand, one
# warning" - committed
MO=$(cat .r-committed.out)
has "$MO" "  curl's line: 200 · Content-Type: [text/plain;charset=ISO-8859-1] · curl's exit code: 18" "committed: 200, curl's exit 18"
has "$MO" "  what curl got: 1 line of text, the last one ended - 'half an answer'" "committed: half an answer"
has "$MO" "$TOMF [Request processing failed: java.lang.IllegalStateException: the second half burned] with root cause" "committed: Tomcat's ERROR"
has "$MO" "    WARN o.s.b.w.a.ProblemDetailsExceptionHandler: Response already committed. Ignoring: org.springframework.http.converter.HttpMessageNotWritableException: No converter for [class java.util.LinkedHashMap] with preset Content-Type 'text/plain;charset=ISO-8859-1'" "committed: Boot's WARN"
has "$MO" "  curl's line: 200 · Content-Type: [application/json] · curl's exit code: 0" "committed: the meals, 200, curl's exit 0"
has "$MO" '  what curl got: JSON that parses - a list of 1500 · its first: {"number":1,"name":"meal 1"} · its last: {"number":1500}' "committed: 1500 meals, valid JSON"
has "$MO" "    WARN o.s.b.w.a.ProblemDetailsExceptionHandler: Response already committed. Ignoring: org.springframework.http.converter.HttpMessageNotWritableException: Could not write JSON: meal 1500 burned" "committed: the meals' WARN"
[ "$(printf '%s\n' "$MO" | grep -c '^  WARN lines it added: ')" = 3 ] && has "$MO" "  WARN lines it added: 1 · ERROR lines: 1" "committed" && has "$MO" "  WARN lines it added: 1 · ERROR lines: 0" "committed: the meals, 1 WARN, 0 ERROR"
MC=$(blk committed "C (labelled)" '')
has "$MC" "  curl's line: 500 · Content-Type: [application/problem+json] · curl's exit code: 0" "committed C: a short list that fails - 500, a problem detail"
has "$MC" '  what curl got: JSON that parses - {"detail":"Failed to write request","instance":"/probe/short","status":500,"title":"Internal Server Error"}' "committed C: the problem detail, the reason in it nowhere"
has "$MC" "  WARN lines it added: 0 · ERROR lines: 0" "committed C: silent - 0 WARN, 0 ERROR"
! printf '%s\n' "$MC" | grep -q 'meal 5 burned' || die "committed C: the reason (meal 5 burned) is in neither the answer nor the log"
has "$MO" "  WARN lines in this run's log, at Boot's default level: 2 · ERROR lines: 1" "committed: 2 WARN, 1 ERROR in the run - C added none"
grep -q 'rangeClosed(1, 2000)' harness/probe/web/Committed.java && grep -q 'number == 1500' harness/probe/web/Committed.java && grep -q 'rangeClosed(1, 10).mapToObj(ShortMeal::new)' harness/probe/web/Committed.java && grep -q 'number == 5)' harness/probe/web/Committed.java || die "committed: the harness's 2,000 meals and its 1,500th; 10 meals and the 5th"
echo "  committed: write, flush, throw -> 200 text/plain 'half an answer', curl exit 18, Tomcat's ERROR + Boot's WARN; the meals -> 200, JSON that parses, 1500 of 2000, 1 WARN, 0 ERROR; C: 10 meals, the 5th fails -> a 500 problem detail, 0 WARN 0 ERROR"

# "an encoded slash ... Tomcat's own page, and not one line, even at debug ... the Whitelabel page off: Tomcat's own five hundred,
# three error lines" - tomcat
TO=$(cat .r-tomcat.out); T0=$(blk tomcat "before Spring MVC" "A - "); TA=$(blk tomcat "A - " "B - "); TB=$(blk tomcat "B - " "A' - ")
TP="  an HTML page, not the Whitelabel page - its <h1>: HTTP Status 400 – Bad Request · 431 characters, not shown · then curl's: 400 · Content-Type: [text/html;charset=utf-8]"
for c in "$(tq 19461 /customers/a%2Fb)" "$(tq 19461 /customers/a%2Fb application/json)"; do [ "$(aft "\$ $c" "$T0")" = "$TP" ] || die "tomcat: $c - Tomcat's page"; done
[ "$(printf '%s\n' "$T0" | grep -c "^  the log lines it added, Boot's web group at DEBUG (level logger: message) - all 0, of them Spring MVC's DispatcherServlet's: 0; and 0 other lines")" = 2 ] || die "tomcat: the encoded slash adds 0 lines"
has "$T0" "  the log lines it added, Boot's web group at DEBUG (level logger: message) - all 5, of them Spring MVC's DispatcherServlet's: 2; and 0 other lines (a stack trace's), not shown:" "tomcat: Ravi adds 5 lines"
ans "$TA" "$(tq 19462 /probe/boom text/html)" "$(WL 'Internal Server Error' 500)" 0 1 "tomcat A: the Whitelabel 500"
ans "$TB" "$(tq 19463 /probe/boom text/html)" "  an HTML page, not the Whitelabel page - its <h1>: HTTP Status 500 – Internal Server Error · 451 characters, not shown · then curl's: 500 · Content-Type: [text/html;charset=utf-8]" 0 3 "tomcat B: Tomcat's own 500 page, 3 ERROR"
has "$TB" "    ERROR o.a.c.c.C.[Tomcat].[localhost]: Exception Processing [ErrorPage[errorCode=0, location=/error]]" "tomcat B: Tomcat's host logger"
has "$TB" "    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: Servlet.service() for servlet [dispatcherServlet] threw exception" "tomcat B: the error dispatch fails"
ans "$TB" "$(tq 19463 /probe/boom)" "$(J4 500 'Internal Server Error' /probe/boom)" 0 1 "tomcat B: JSON unchanged"
ans "$TB" "$(tq 19463 /nowhere text/html)" "$PD404" 0 0 "tomcat B: a problem detail unchanged"
has "$TO" "A' against A, its label aside, line for line the same: yes" "tomcat: A' = A"
echo "  tomcat: a%2Fb -> Tomcat's HTML 400, both Accepts, 0 log lines at DEBUG (Ravi: 5, the DispatcherServlet's 2); A: Whitelabel 500, 1 ERROR; B: whitelabel off -> Tomcat's own 500 page, 3 ERROR; JSON and the problem detail unchanged; A' = A"

# "problem details don't fail ... a handler that throws hands the error back: Boot's old four keys, and a warning" - handler
HO=$(cat .r-handler.out); H1=$(blk handler "the anchor as it ships" "the anchor on its class path"); H2=$(blk handler "the anchor on its class path" '')
ans "$H1" "$(tq 19464 /nowhere)" "$PD404" 0 0 "handler: /nowhere"
for a_ in text/html image/png text/plain; do ans "$H1" "$(tq 19464 /customers/Nobody $a_)" "$PDNOB" 0 0 "handler: Nobody for $a_"; done
has "$H2" '    1 probe.web.Fragile · its order: -2147483648' "handler: Fragile first"
ans "$H2" "$(tq 19465 /nowhere)" "$(J4 404 'Not Found' /nowhere)" 1 0 "handler: Fragile -> Boot's four keys"
has "$H2" '    WARN .m.m.a.ExceptionHandlerExceptionResolver: Failure in @ExceptionHandler probe.web.Fragile#noSuchPath(NoResourceFoundException)' "handler: Failure in @ExceptionHandler"
has "$H2" '      java.lang.NullPointerException: Cannot invoke "java.lang.Throwable.getMessage()" because the return value of "org.springframework.web.servlet.resource.NoResourceFoundException.getCause()" is null' "handler: the handler's own NPE"
ans "$H2" "$(tq 19465 /customers/Nobody)" "$PDNOB" 0 0 "handler: Nobody untouched"
echo "  handler: Nobody for text/html, image/png, text/plain -> the 404 problem detail, 0/0; Fragile -> /nowhere Boot's four keys 404, 1 WARN (Failure in @ExceptionHandler, an NPE)"

# the exercise's end state: the README's commands, then the solution's, in ONE env -i shell - each leaves the shell in this folder
XS=$(blk exercise "the README's" "the solution's"); XE=$(blk exercise "the solution's" '')
l='wrong verbs: 405 405'; l0='wrong verbs: 500 500'
has "$XE" "    $l" "exercise: the solution"; has "$XS" "    $l0" "exercise: as shipped"
has "$XS" '      1 probe.web.CatchAllFirst · its order: -2147483648' "exercise: as shipped, CatchAllFirst first"
has "$XE" '      1 org.springframework.boot.webmvc.autoconfigure.ProblemDetailsExceptionHandler · its order: 0' "exercise: the solution, Boot's first"
awk '/^\*\*Done\*\*/ { f = 1 } f' exercise/README.md | grep -qxF -- "$l" || die "exercise/README.md: Done names no such line"
grep -qxF -- "$l" exercise/solution/SOLUTION.md || die "SOLUTION.md: the measured run shows no such line"
grep -qF -- "\`$l0\`" exercise/README.md || die "exercise/README.md: the shipped line's answer is not named"
has "$XS" '  exit 0 · what they printed:' "exercise: the README's commands, exit 0"; has "$XE" '  exit 0 · what they printed:' "exercise: the solution's lines, exit 0"
has "$XS" "  the shell is now in: this unit's folder · the copy's own token in its log: 0 times · WARN lines in its log: 0 · ERROR lines: 0 · listening on 19469 now: 0" "exercise: as shipped, 0 WARN"
has "$XE" "  the shell is now in: this unit's folder · the copy's own token in its log: 0 times · WARN lines in its log: 2 · ERROR lines: 0 · listening on 19469 now: 0" "exercise: the solution, 2 WARN"
[ "$(printf '%s\n' "$XE" | grep -c '^  \$ export ')" = 2 ] || die "exercise: SOLUTION.md gives the README's two export lines"
EXQ="Your turn: the README's run turns every wrong verb into a five hundred. Read the handler list, remove the one that's first, and count again."
grep -qxF -- "**Your turn:** ${EXQ#Your turn: }" exercise/README.md || die "exercise/README.md: the spoken exercise line"
[ "$(printf '%s\n' "$EXQ" | wc -w | tr -d ' ')" -le 25 ] || die "exercise: the spoken line is over 25 words"
echo "  exercise: one env -i shell - the README as written (CatchAllFirst joined) -> wrong verbs: 500 500, 0 WARN; the solution (taken out) -> wrong verbs: 405 405, 2 WARN; the shell in this unit's folder after each"

[ -z "$unpub" ] || die "no published hash for:$unpub - check the captures, then copy the md5s above into receipts.md5 and run again"
echo "c6-unit17: every capture 3/3 and = published; every spoken number asserted; 0 raw demo tokens in every capture and every log"
