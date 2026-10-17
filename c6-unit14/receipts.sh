#!/bin/bash
XPATH=$PATH                                           # the PATH you started this with: the exercise's own shell gets it
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25.0.4.1 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# Course 6 · Boot's Default Error Response - this unit's receipts. No anchor change: anchor/ is the link to ../c6-unit12/after, the
# tree the validation lesson froze (= c6-tiffinbox at Section 2's end, the tree the viewer last saw). This script copies that tree
# under .harness/anchor, builds it and runs it - as its README runs it, and on its class path with the course's harness joined
# (harness/probe/web, outside com.tiffinbox) - and asks it for every error it can give: who writes the answer, what each answer says
# and what it leaves out, where the reason went, what a client that asks for HTML gets, what Boot's error keys add, and what DevTools
# turns on. Seven captures, each run three times and hashed; cap() DIES when a hash differs from receipts.md5; every number the video
# says is asserted at the bottom by a check that can fail; the demo token is masked (gsub), and the checks count 0 raw copies of it in
# every capture, in the log of every run and in every file this unit ships.
#   path      the anchor built and extracted; the harness compiled; the seven on the jar; who writes an error answer, read off the
#             running application (the harness's Who: the error controller, the error attributes, the exception resolvers in order);
#             then, at DEBUG, a route that throws and a path no route takes - every line each request added
#   shapes    the catalogue: every error TiffinBox can give - fourteen requests and the one POST the duplicate needs - each answer
#             whole (curl's own Accept), then the answers' shapes, counted
#   reasons   the same requests on a fresh JVM: each answer's status and the WARN and ERROR lines it added, each record by its
#             logger
#   html      the same requests, each with a browser's Accept type (text/html, sent by curl): the Whitelabel page, the answers that
#             became 406s, the WARN lines
#   message   Boot's metadata for its error keys; A/B/A': spring.web.error.include-message - A, Boot's default; B, always; A', A
#             again - each on a name nobody has, a meal type no route takes, and a route that puts a header's value into its
#             exception's message (a planted canary, counted in the answer and in the log); C (labelled): include-stacktrace
#   devtools  the anchor's class path with DevTools 4.1.1 added (from .m2-demo), restart enabled, Live Reload off: the property
#             source named devtools read off the environment, what the answers gain, the WARN line a 404 gains, the canary, the exit
#             code; then restart disabled: no property source, the answers as without DevTools, the exit code
#   exercise  exercise/README.md's commands, then exercise/solution/SOLUTION.md's, read from the files and run as written, one after
#             the other in ONE shell a viewer could have: env -i, /bin/bash, started in this folder
# "The anchor" is anchor/, the link to ../c6-unit12/after, COPIED under .harness/anchor; this script never writes into another unit's
# folder, and never builds a frozen tree in place. Every run of TiffinBox starts in .harness/anchor, which holds a config tree with a
# fake token (secrets/), as the README asks. Commands are printed exactly as they run: each goes through eval. "$CURLSET" is the
# comparison set since the secrets lesson (../c5-unit11/curlset.sh: the seven requests, POST /shutdown with the token's header read
# from the file). "$M2" is this unit's own repository, .m2-demo. "$NOTE" is the planted canary: 26 random hexadecimal digits made
# when this script starts (openssl rand -hex 13), never the token, never printed (masked). The harness - harness/probe/web (compiled
# with -parameters): Boom (two routes that throw), Who (reads the error side of the running application, and its property sources) -
# is the course's, never TiffinBox's: outside com.tiffinbox, joined by --spring.main.sources on the extracted jar's class path, and
# named on every capture that uses it; harness/shutdown.sh is POST /shutdown with the token read from its file. Every run passes
# options only. The seven run first, on a fresh JVM of the jar.
# The locale: the JVM ignores LC_ALL on macOS - it takes the Mac's first language - and Spring's, Jackson's and Tomcat's messages in
# the log, the messages Boot's include-message key puts in an answer, and Boot's Whitelabel page are written in the JVM's locale: so
# every JVM this script starts has its locale pinned on its run line (-Duser.language=en -Duser.country=US, before -jar or -cp: at()
# puts it there, README.md "The commands this unit adds"), and Who prints it.
# The network: every Maven build runs offline (-o) against .m2-demo and says so ("offline: yes"); a build that cannot resolve an
# artifact offline goes to Maven Central once, and says that ("offline: no - ..."). DevTools' jar is read from .m2-demo, where the
# seed holds it; a fresh clone's first build cannot fetch it (no POM names it), so the script asks Maven for it once, by name
# (dependency:get, offline first, and says which). No native build and no Docker: this unit measures the JVM alone. At run time
# nothing leaves 127.0.0.1: TiffinBox listens there, every request goes there, Live Reload is off (35729 is never bound), and
# Logback writes to the terminal only.
# Masks and filters (README.md declares each; awk sub/gsub only): the demo token becomes "[masked: the N-character token]" and the
# canary "[masked: the N-character canary]" (N their own lengths); this folder's absolute path "…", the folder above it "…/..", the
# home folder "~"; your user name "<user>" - in every line of every capture. Spring's error timestamp becomes "…" (both JSON forms),
# in the seven and wherever an answer is printed; in a map Spring MVC logs at DEBUG, "timestamp=…,". Boot's Whitelabel page is
# printed as its <h1> and its error line, its created date (the JVM's time zone) masked and its paragraph counted, never shown;
# Tomcat's own error page as its <title>, the rest counted; a "trace" in an answer as its first line and its frames, counted, never
# shown. A run's log lines are printed from their logger on (no time, no process id, no thread); Boot's first line is cut before
# " with PID"; DevTools' own line, written before logging starts, from its level on. A WARN or ERROR record is printed as its level,
# logger and message, then the exception line under it; its stack frames are bounded ("over 40") and its other lines counted, never
# shown. No duration is captured.
# Ports (brief ⚑1, 19430-19439): path 19430 · shapes 19431 · reasons 19432 · html 19433 · message A and A' 19434, B 19435, C 19436 ·
# devtools, restart enabled 19437, disabled 19438 · the exercise 19439. 18425 (TiffinBox's default), 8080 (Tomcat's) and 35729
# (DevTools' Live Reload) are checked free too, and never bound.
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
for t in python3 curl rsync lsof unzip javac openssl mvn; do command -v $t > /dev/null || die "$t is needed"; done
# A variable of yours must not become a property source, a JVM flag or a build setting: every TIFFINBOX_*, SPRING_*, MANAGEMENT_*,
# SERVER_* and LOGGING_* variable, DEBUG (Boot reads it as --debug), the variables that inject JVM flags, MAVEN_OPTS, MAVEN_ARGS and
# NATIVE_IMAGE_OPTIONS are removed first (the last course's failure lesson's loop, verbatim: sed -E, a canary planted under every
# name first, and the run stops if one survives). This unit runs no Docker, so COMPOSE_* is not in the list. (A SPRING_WEB_ERROR_* of
# yours would put a message or a trace into every answer here; SPRING_DEVTOOLS_* would switch restart or Live Reload; a
# JAVA_TOOL_OPTIONS could set every JVM's locale.)
for v in TIFFINBOX_CANARY SPRING_CANARY MANAGEMENT_CANARY SERVER_CANARY LOGGING_CANARY DEBUG JAVA_TOOL_OPTIONS JDK_JAVA_OPTIONS _JAVA_OPTIONS MAVEN_OPTS MAVEN_ARGS NATIVE_IMAGE_OPTIONS; do export "$v=planted-canary"; done
for v in $(env | sed -n -E 's/^(TIFFINBOX_[A-Za-z0-9_]*|SPRING_[A-Za-z0-9_]*|MANAGEMENT_[A-Za-z0-9_]*|SERVER_[A-Za-z0-9_]*|LOGGING_[A-Za-z0-9_]*|DEBUG|JAVA_TOOL_OPTIONS|JDK_JAVA_OPTIONS|_JAVA_OPTIONS|MAVEN_OPTS|MAVEN_ARGS|NATIVE_IMAGE_OPTIONS)=.*/\1/p'); do unset "$v"; done
[ -z "$(env | grep -- '=planted-canary$')" ] || die "a variable survived the clean-up above: $(env | grep -- '=planted-canary$' | sed 's/=.*//' | paste -sd' ' -)"
# Every request this script makes goes to 127.0.0.1: an HTTP proxy named in your environment would carry curl's requests to that
# proxy instead - 127.0.0.1 and localhost go first in no_proxy and NO_PROXY.
export no_proxy="127.0.0.1,localhost${no_proxy:+,$no_proxy}" NO_PROXY="127.0.0.1,localhost${NO_PROXY:+,$NO_PROXY}"
[ -e secrets ] && die "this folder holds a secrets/ - remove it: every run here starts in a folder under .harness/"
[ -L anchor ] && [ "$(readlink anchor)" = ../c6-unit12/after ] || die "anchor must be the link to ../c6-unit12/after - this unit changes nothing in the anchor"
[ -f anchor/pom.xml ] && [ -f anchor/README.md ] && [ -f anchor/tiffinbox-web/pom.xml ] || die "the anchor (its pom.xml, README.md or web module's pom.xml) is missing"
[ -e anchor/secrets ] || [ -e anchor/target ] || [ -e anchor/tiffinbox-web/target ] || [ -e anchor/tiffinbox-core/target ] || [ -e anchor/tiffinbox-local.yaml ] && die "anchor/ holds a secrets/, a target/ or a tiffinbox-local.yaml - it is a frozen copy, never built in place"
M2="$PWD/.m2-demo"; U="$PWD"; UP="$(cd .. && pwd)"; ME="$(id -un)"
JARP=tiffinbox-web/target/tiffinbox-web-1.0.0.jar    # the executable jar, in a tree's web module
TF=secrets/tiffinbox/shutdown-token                  # the config tree's file for tiffinbox.shutdown-token
DTJ=org/springframework/boot/spring-boot-devtools/4.1.1/spring-boot-devtools-4.1.1.jar   # DevTools' jar, inside $M2
# The demo token. FAKE, and meant to look it: it guards nothing but a demo server on 127.0.0.1 that every capture stops. It is
# written into .harness/anchor/secrets/ (git-ignored) when this script runs, and no capture prints it: see mask().
TOKEN=fake-token-for-error-pages
[ ${#TOKEN} = 26 ] || die "the demo token must be 26 characters: the published captures name its length"
# The canary (S3.10): what a client puts in the harness's X-Order-Note header, which Boom quotes in its exception's message. Random,
# made now, never the token; masked in every capture, counted wherever a capture says where it went.
NOTE=$(openssl rand -hex 13); export NOTE
[ ${#NOTE} = 26 ] && [ "$NOTE" != "$TOKEN" ] || die "the canary must be 26 characters, and never the token"
CURLSET=../c5-unit11/curlset.sh                      # the comparison set: the seven requests, POST /shutdown with the header
[ -f "$CURLSET" ] || die "$CURLSET is missing"
HWS='harness/probe/web/Boom.java harness/probe/web/Who.java'
for f in harness/shutdown.sh $HWS exercise/README.md exercise/solution/SOLUTION.md README.md; do [ -f "$f" ] || die "$f is missing"; done
[ "$(ls harness/probe/web | paste -sd' ' -)" = 'Boom.java Who.java' ] || die "harness/probe/web holds another file: javac compiles all of it"

# The ports, BEFORE anything is wiped (a survivor of an interrupted run answers POST /shutdown only with its token, which lives in
# .harness/ - so the message names the process to kill).
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
for p in 18425 8080 35729 19430 19431 19432 19433 19434 19435 19436 19437 19438 19439; do
  [ "$(listeners $p)" = 0 ] || die "something already listens on $p - this unit's ports must be free; if it is a TiffinBox an interrupted run left behind, stop it: kill $(lsof -nP -iTCP:$p -sTCP:LISTEN -t 2> /dev/null | paste -sd' ' -)"; done

# ---- the commands: read from anchor/README.md, the anchor's own, and asserted - each line must be there, whole ---------------
readme() { grep -m1 -xF -- "$1" anchor/README.md > /dev/null || die "anchor/README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
J='java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431'
CPL='"tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431'
ASHA='{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}'
R_PLAIN=$(readme 'mvn -B package')
R_RUN=$(readme "$J")
R_WEB=$(readme "$J --logging.level.web=debug")
R_EXTRACT=$(readme 'java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted')
R_CP=$(readme "java -cp $CPL")
R_READY=$(readme "curl -s -w ' %{http_code}\n' http://127.0.0.1:18431/actuator/health/readiness")
R_ONE=$(readme "curl -s -w ' %{http_code}\n' http://127.0.0.1:18431/customers/Ravi")
R_GQ=$(readme "curl -s -w ' %{http_code}\n' 'http://127.0.0.1:18431/customers?mealType=VEGAN'")
R_POST=$(readme "curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '$ASHA' http://127.0.0.1:18431/customers")
R_27=$(readme "curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '{\"name\":\"Mohan\",\"mealsPerDay\":2.7,\"pricePerMeal\":110,\"mealType\":\"VEG\"}' http://127.0.0.1:18431/customers")
R_403=$(readme "curl -s -w ' %{http_code}\n' -X POST http://127.0.0.1:18431/shutdown")
[ "${R_WEB#"$J "}" = '--logging.level.web=debug' ] || die "the README's options"
O_WEB=${R_WEB#"$J "}
# This unit's own lines (README.md, "The commands this unit adds") - each asserted to be exactly that: the anchor's run and class-path
# lines with the JVM's locale pinned; the class-path line with one of Boot's error keys; the DevTools line, restart enabled and
# disabled; the harness's javac line; the catalogue's curl line (the one-customer line with curl's Content-Type printed); the
# harness's two questions; the canary's request
mine() { grep -m1 -xF -- "$1" README.md > /dev/null || die "README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
JL='-Duser.language=en -Duser.country=US'
L_RUNL=$(mine "java $JL -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431")
L_CPL=$(mine "java $JL -cp $CPL")
L_MSG=$(mine "java $JL -cp $CPL --spring.web.error.include-message=always")
L_STK=$(mine "java $JL -cp $CPL --spring.web.error.include-stacktrace=always")
DCP='"tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:$M2/'"$DTJ"'" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431 --spring.devtools.livereload.enabled=false'
L_DEV=$(mine "java $JL -Dspring.devtools.restart.enabled=true -cp $DCP")
L_DEVOFF=$(mine "java $JL -Dspring.devtools.restart.enabled=false -cp $DCP")
L_JAVAC=$(mine "javac -parameters -d .harness/hc -cp \".harness/anchor/tiffinbox-web/target/extracted/lib/*\" $HWS")
WT=" -w ' %{http_code} · Content-Type: [%{content_type}]\n'"; WS=" -w ' %{http_code}\n'"
L_WT=$(mine "curl -s$WT http://127.0.0.1:18431/customers/Ravi")
L_WHO=$(mine "curl -s http://127.0.0.1:18431/probe/who/errors")
L_WHOD=$(mine "curl -s http://127.0.0.1:18431/probe/who/devtools")
L_NOTE=$(mine "curl -s$WS -H \"X-Order-Note: \$NOTE\" http://127.0.0.1:18431/probe/boom-note")
# The derivations, each asserted: the pinned lines are the anchor's run and class-path lines with the two options after java, and
# nothing else; the key lines are the pinned class-path line with one option at the end; the DevTools lines are the pinned class-path
# line with one option before -cp, DevTools' jar at the end of the class path and Live Reload's option at the end; the catalogue's line
# is the one-customer line with Content-Type printed; the canary's line is the readiness line with one header and another path
P_='java '; Q_="java $JL "; r=${R_RUN/"$P_"/$Q_}; r2=${R_CP/"$P_"/$Q_}
[ "$r" = "$L_RUNL" ] && [ "$r2" = "$L_CPL" ] || die "the pinned lines must be the anchor's run and class-path lines with $JL after java, and nothing else"
[ "$L_MSG" = "$L_CPL --spring.web.error.include-message=always" ] && [ "$L_STK" = "$L_CPL --spring.web.error.include-stacktrace=always" ] || die "a key line must be the pinned class-path line with one option, and nothing else"
for t in true false; do [ "$t" = true ] && l_=$L_DEV || l_=$L_DEVOFF
  r=$(python3 -c 'import sys; l, t, j = sys.argv[1:]; s = " --spring.devtools.livereload.enabled=false"; l = l.replace(" -Dspring.devtools.restart.enabled=%s -cp " % t, " -cp ", 1).replace(":$M2/" + j + "\"", "\"", 1); print(l[:-len(s)] if l.endswith(s) else l)' "$l_" "$t" "$DTJ")
  [ "$r" = "$L_CPL" ] || die "a DevTools line must be the pinned class-path line with restart's option, DevTools' jar and Live Reload's option, and nothing else: $l_"; done
r=${L_WT/"$WT"/$WS}; [ "$r" = "$R_ONE" ] || die "the catalogue's line must be the one-customer line with Content-Type printed, and nothing else"
r=${L_NOTE/" -H \"X-Order-Note: \$NOTE\""/}; r=${r/probe\/boom-note/actuator/health/readiness}; [ "$r" = "$R_READY" ] || die "the canary's line must be the readiness line with one header and another path, and nothing else"
[ "${L_JAVAC#* -cp \"*\" }" = "$HWS" ] || die "the harness's javac line must compile the two files in harness/probe/web, and nothing else"
# off DIR 'README mvn LINE' [PHASE]: the README's Maven line as this script runs it - from DIR, offline (-o), this unit's own
# repository, and for a build phase (package) clean and without tests. dev() takes those four things back out, and must give the
# README's line again: so the command on screen is the README's, with exactly those changes.
off() { local c=${2/mvn -B /mvn -o -B -Dmaven.repo.local=\"\$M2\" }
  [ -n "$3" ] && c=${c/ $3/ -DskipTests clean $3}
  printf 'cd %s && %s\n' "$1" "$c"; }
dev() { local c=${1#cd * && }; c=${c/ -o -B -Dmaven.repo.local=\"\$M2\" / -B }; c=${c/ -DskipTests clean / }; printf '%s\n' "$c"; }
# at DIR PORT 'LINE': the line run from DIR, its port 18431 made PORT - and a java line that does not pin the JVM's locale gets it
# pinned right after "java" (this unit's pinned lines show the form, and at() must give them back)
at() { local l=${3/--tiffinbox.port=18431/--tiffinbox.port=$2}; case $l in "java $JL "*|'java -Djarmode=tools '*) ;; 'java '*) l="java $JL ${l#java }" ;; esac; printf 'cd %s && %s\n' "$1" "$l"; }
# hcp 'LINE' DIR PORT CLASSES ['OPTIONS']: a class-path run line from DIR, its port made PORT, the harness's classes added to the
# class path right after lib/* (../hc), CLASSES joined (--spring.main.sources=) after the line's own options, then OPTIONS
hcp() { local c; c=$(at "$2" "$3" "$1"); c=${c/lib\/\*/lib/*:../hc}; printf '%s --spring.main.sources=%s%s\n' "$c" "$4" "${5:+ $5}"; }
# url 'curl LINE' PORT: the line, its port 18431 made PORT
url() { printf '%s\n' "${1/:18431\//:$2/}"; }
# qurl PORT PATH: the URL; one that holds a character the shell reads (; ? & * { } or a space) is single-quoted, so eval hands it to
# curl whole
qurl() { local u="http://127.0.0.1:$1$2"; case $2 in *[\;\?\&\*\{\}\ ]*) u="'$u'" ;; esac; printf '%s\n' "$u"; }
# cq PORT 'OPTIONS' PATH: the catalogue's line - curl, its -w with the status and the Content-Type - with OPTIONS (an Accept header, a
# method, a Content-Type and a body: as the anchor's README writes them) and the path swapped
CQW=${L_WT% http://*}
cq() { printf '%s%s %s\n' "$CQW" "${2:+ $2}" "$(qurl "$1" "$3")"; }
# exe 'COMMAND': the command with "exec" after its "cd DIR && " and any NAME=value before the program - so $pid is the program's
exe() { printf '%s\n' "$1" | sed -E 's/&& (([A-Z_]+=[^ ]* )*)/\&\& \1exec /'; }
C_PRE=$(off .harness/pre "$R_PLAIN" package)
[ "$(dev "$C_PRE")" = "$R_PLAIN" ] || die "not the README's build line with the offline changes: $C_PRE"
[ "$(exe "$(at .harness/x 19430 "$R_RUN")")" = "cd .harness/x && exec ${L_RUNL/18431/19430}" ] && [ "$(at .harness/x 18431 "$R_CP")" = "cd .harness/x && $L_CPL" ] && [ "$(at .harness/x 18431 "$L_DEV")" = "cd .harness/x && $L_DEV" ] && [ "$(at .harness/x 18431 "$R_EXTRACT")" = "cd .harness/x && $R_EXTRACT" ] || die "at(): the pinned lines are not README.md's"
[ "$(hcp "$L_CPL" .harness/x 19434 probe.web.Boom "$O_WEB")" = 'cd .harness/x && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19434 --spring.main.sources=probe.web.Boom --logging.level.web=debug' ] || die "hcp()"
[ "$(hcp "$L_DEV" .harness/x 19437 probe.web.Boom)" = 'cd .harness/x && java -Duser.language=en -Duser.country=US -Dspring.devtools.restart.enabled=true -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc:$M2/org/springframework/boot/spring-boot-devtools/4.1.1/spring-boot-devtools-4.1.1.jar" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19437 --spring.devtools.livereload.enabled=false --spring.main.sources=probe.web.Boom' ] || die "hcp(): DevTools"
[ "$(cq 18431 '' /customers/Ravi)" = "$L_WT" ] && [ "$(cq 19431 '' '/customers?mealType=veg')" = "curl -s$WT 'http://127.0.0.1:19431/customers?mealType=veg'" ] || die "cq(): not the README's line"
echo "  the commands: anchor/README.md gives the 12 lines this script runs or derives from; README.md the 13 this unit adds"

# ---- build: before the captures - the anchor built once (on a fresh clone this fills .m2-demo); DevTools' jar; what .m2-demo holds
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
# tree FOLDER [TOKEN]: a config tree in FOLDER/secrets holding one file, the token (the demo token unless named) and a newline,
# readable by its owner alone
tree() { mkdir -p "$1/secrets/tiffinbox"; (umask 077 && printf '%s\n' "${2:-$TOKEN}" > "$1/$TF"); chmod 700 "$1/secrets" "$1/secrets/tiffinbox"; }
copy() { rm -rf "$2" "$2".*; rsync -a --exclude target --exclude secrets "$1/" "$2/"; tree "$2"; }
rsync -a --exclude target --exclude secrets anchor/ .harness/pre/
mbuild "$C_PRE" .harness/build-pre.log ".harness/pre (the anchor)"
[ -f "$M2/org/springframework/boot/spring-boot-starter-webmvc/4.1.1/spring-boot-starter-webmvc-4.1.1.jar" ] || die "Spring MVC's starter is not in .m2-demo after the first build"
# DevTools: no POM of the anchor names it (this unit adds nothing to the tree), so a fresh clone's build never fetches it. Asked for
# by name, offline first: from the seed it is already there.
if [ ! -f "$M2/$DTJ" ]; then
  mbuild "cd .harness/pre && mvn -o -B -Dmaven.repo.local=\"\$M2\" dependency:get -Dartifact=org.springframework.boot:spring-boot-devtools:4.1.1 -Dtransitive=false" .harness/devtools-get.log "DevTools 4.1.1's jar, by name (dependency:get)"; fi
[ -f "$M2/$DTJ" ] || die "DevTools 4.1.1's jar is not in .m2-demo"
echo "  .m2-demo holds Spring MVC's starter and DevTools 4.1.1's jar"

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
# sortj: a JSON answer followed by curl's status (" 200"), its keys sorted, its error timestamp masked
sortj() { python3 -c '
import json, re, sys
for l in sys.stdin.read().splitlines():
    b, _, s = l.rpartition(" ")
    try: o = json.dumps(json.loads(b), sort_keys=True, separators=(",", ":"))
    except ValueError: print("  " + l); continue
    o = re.sub(r"\"timestamp\":(\"[^\"]*\"|[0-9]+)", "\"timestamp\":\"…\"", o)
    print("  " + o + " " + s + ("    (keys sorted)" if o != re.sub(r"\"timestamp\":(\"[^\"]*\"|[0-9]+)", "\"timestamp\":\"…\"", b) else ""))'; }
askj() { local c; c=$(url "$1" "$2"); echo "\$ $c"; (eval "$c") 2>&1 < /dev/null | sortj; }
# ready PORT: readiness asked until it answers 200 - every 0.25 s, up to 120 s, not printed - then the README's readiness line,
# printed and run once. No assertion before it (R.41, R.75). A JVM ($pid) that exits first stops the run.
ready() { local i=0 c=""
  while [ $i -lt 480 ]; do c=$(curl -s -o /dev/null -w '%{http_code}' "http://127.0.0.1:$1/actuator/health/readiness" 2> /dev/null || true); [ "$c" = 200 ] && break
    kill -0 "$pid" 2> /dev/null || { tail -20 .harness/run.out >&3; die "it exited before readiness answered 200"; }
    sleep 0.25; i=$((i + 1)); done
  [ "$c" = 200 ] || die "readiness never answered 200 on $1"
  askj "$R_READY" "$1"; }
# logtok: the demo token 0 times in the last run's log, and the header's name 0 times
logtok() { local t h; t=$(raw "$TOKEN" .harness/run.out .harness/run.err); h=$(cat .harness/run.out .harness/run.err | LC_ALL=C grep -aoi -- 'x-shutdown-token' | wc -l | tr -d ' ')
  LOGS=$((LOGS + 1)); [ "$t" = 0 ] && [ "$h" = 0 ] || die "a log held the demo token ($t) or its header's name ($h)"
  echo "  its log: the demo token 0 times · X-Shutdown-Token $h times"; }
# tsmask: Spring's error timestamp, both forms (an ISO-8601 string, epoch milliseconds), becomes "…" (README.md, Masks)
tsmask() { awk '{ gsub(/"timestamp":"[^"]*"/, "\"timestamp\":\"…\""); gsub(/"timestamp":[0-9]+/, "\"timestamp\":…"); print }'; }
# tsform FILE...: the error timestamps in the files - unmasked answers - each made a form: every digit of its date and time becomes d,
# its zone kept (README.md, Masks); each distinct form, and how many times it appears
tsform() { cat "$@" | grep -o '"timestamp":"[^"]*"' | python3 -c 'import re, sys
for l in sys.stdin: print(re.sub(r"^(\"timestamp\":\")([0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}(\.[0-9]+)?)", lambda m: m.group(1) + re.sub(r"[0-9]", "d", m.group(2)), l.rstrip("\n")))' | sort | uniq -c | awk '{ c = $1; $1 = ""; sub(/^ /, ""); printf "%s%s ×%d", (NR > 1 ? " · " : ""), $0, c } END { if (NR == 0) printf "none" }'; }
# gone PORT: after a POST /shutdown - the JVM must leave within 15 s, the port must be free; its exit code
gone() { local i=0 e=0
  while kill -0 "$pid" 2> /dev/null && [ $i -lt 60 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$pid" 2> /dev/null && { kill "$pid"; die "the server on $1 was still running 15 s after POST /shutdown"; }
  wait "$pid" || e=$?; pid=""; LASTE=$e
  [ "$(listeners "$1")" = 0 ] || die "something still listens on $1"; }
# seven PORT DIR: the comparison set's seven requests (POST /shutdown carries the header, read from DIR's token file), the POST
# line printed; the JVM must leave within 15 s of them, the port must be free; its exit code; the md5 of the seven after the
# timestamp mask, how many lines the mask changed, and the form of the timestamps it hid; the log counted (logtok)
seven() { local m
  echo "\$ \$CURLSET $1 $2/$TF"
  "$CURLSET" "$1" "$2/$TF" | grep ' -> ' > .harness/responses.txt || true
  tsmask < .harness/responses.txt > .harness/responses.m.txt
  grep '^POST ' .harness/responses.m.txt | sed 's/^/  /' || echo "  (no POST line)"
  gone "$1"
  m=$(diff .harness/responses.txt .harness/responses.m.txt | grep -c '^<' || true)
  echo "  exit $LASTE · the seven responses: $(wc -l < .harness/responses.m.txt | tr -d ' ') lines · lines the timestamp mask changed: $m · md5 $(md5 -q .harness/responses.m.txt)"
  echo "  the timestamps the mask hid, their form: $(tsform .harness/responses.txt)"
  logtok; }
# post PORT DIR: POST /shutdown with DIR's token (harness/shutdown.sh) - its answer, its Content-Length header, the timestamp masked
post() { echo "\$ harness/shutdown.sh $1 $2/$TF"; harness/shutdown.sh "$1" "$2/$TF" | tsmask | sed 's/^/  /'; }
# stop PORT DIR: POST /shutdown with DIR's token; the JVM must leave, the port must be free; its exit code; its log counted (logtok)
stop() { post "$1" "$2"; gone "$1"; echo "  exit $LASTE · listening on $1 now: 0"; logtok; }
mask() { awk -v t="$TOKEN" -v cn="$NOTE" -v u="$U" -v up="$UP" -v hm="$HOME" -v me="$ME" -v tl="${#TOKEN}" -v cl="${#NOTE}" '
  function lit(x) { gsub(/[][\\.^$*+?(){}|\/]/, "\\\\&", x); return x }
  function enc(x) { gsub(/ /, "%20", x); return x }
  BEGIN { T = lit(t); C = lit(cn); P = lit(u); Q = lit(up); H = lit(hm); PE = lit(enc(u)); QE = lit(enc(up)); M = "(^|[^A-Za-z0-9_])" lit(me) "([^A-Za-z0-9_]|$)" }
  { gsub(T, "[masked: the " tl "-character token]"); gsub(C, "[masked: the " cl "-character canary]"); gsub(P, "…"); gsub(PE, "…")
    gsub(Q, "…/.."); gsub(QE, "…/.."); gsub(H, "~")
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
# its paragraph counted, never shown; Tomcat's own error page as its <title>, its other characters counted; another HTML page counted;
# a JSON answer with its error timestamp masked, and a "trace" in it cut to "…", then its first line and its frames, counted; an empty
# answer as "(no body)" - each followed by curl's status line
pagef() { python3 -c '
import json, re, sys
def ts(x): return re.sub(r"\"timestamp\":[0-9]+", "\"timestamp\":…", re.sub(r"\"timestamp\":\"[^\"]*\"", "\"timestamp\":\"…\"", x))
for l in sys.stdin.read().splitlines():
    low = l.lower()
    if low.startswith("<html>") or low.startswith("<!doctype html>"):
        end = low.index("</html>") + len("</html>") if "</html>" in low else len(l)
        page, tail = l[:end], l[end:]
        h = re.search(r"<h1>(.*?)</h1>", page); e = re.search(r"<div>(There was an unexpected error .*?)</div>", page); c = re.search(r"<div id=.created.>[^<]*</div>", page); t = re.search(r"<title>(.*?)</title>", page)
        if page.startswith("<html><body><h1>Whitelabel Error Page</h1>") and h and e and c:
            print("  the Whitelabel page (Boot'"'"'s) - its <h1>: %s · its error line: %s · its created date: masked · its paragraphs: %d, not shown · then curl'"'"'s:%s" % (h.group(1), e.group(1), len(re.findall(r"<p>", page)), tail))
        elif low.startswith("<!doctype html>") and t and h:
            print("  an HTML page - its <title>: %s · its <h1>: %s · its other characters: %d, not shown · then curl'"'"'s:%s" % (t.group(1), h.group(1), len(page) - len(t.group(0)) - len(h.group(0)), tail))
        else: print("  an HTML page of another shape: %d characters, not shown · then curl'"'"'s:%s" % (len(page), tail))
    elif l.startswith("{") and "\"trace\":\"" in l:
        m = re.search(r"\"trace\":\"((?:[^\"\\]|\\.)*)\"", l)
        tr = json.loads("\"" + m.group(1) + "\""); lines = tr.split("\n"); fr = sum(1 for x in lines if x.startswith("\tat "))
        print("  " + ts(l[:m.start()] + "\"trace\":\"…\"" + l[m.end():]))
        print("    its \"trace\", cut above: its first line: %s · its frames (\\tat): %d · its other lines: %d - none shown" % (lines[0], fr, len([x for x in lines[1:] if x and not x.startswith("\tat ")])))
    elif l.startswith(" "): print("  (no body) ·" + l)
    else: print("  " + ts(l))'; }
# rq 'COMMAND' [MODE]: a curl line, printed and run, its answer through pagef; then the WARN and ERROR lines the request added,
# counted on the answer's first line (the one with curl's status), and each record (recs). MODE nolog: the answer alone; MODE status: the answer's status line
# alone (its body cut, "the body: N lines, not shown"), then the counts and the records
rq() { local n0 w e; [ "${2:-}" = nolog ] || n0=$(mark); echo "\$ $1"; (eval "$1") 2>&1 < /dev/null > .harness/ans.raw || true; pagef < .harness/ans.raw > .harness/ask.txt
  if [ "${2:-}" = nolog ]; then cat .harness/ask.txt; return 0; fi
  if [ "${2:-}" = status ]; then python3 -c '
import re, sys
s = open(sys.argv[1], encoding="utf-8").read().rstrip("\n"); m = re.search(r" (\d{3} · Content-Type: \[[^]]*\])$", s)
print("  the answer: " + m.group(1) + (" · its body: in shapes, not here" if m.start() > 0 else " · no body"))' .harness/ans.raw > .harness/ask.txt; fi
  settle; w=$(logl "$n0" WARN | grep -c . || true); e=$(logl "$n0" ERROR | grep -c . || true)
  awk -v w="$w" -v e="$e" '{ print $0 (NR == 1 ? " · WARN lines it added: " w " · ERROR lines: " e : "") }' .harness/ask.txt
  [ "$w$e" = 00 ] || recs "$n0"; }
# nq PORT: the canary's request (this unit's line) at PORT through rq, then where the canary went: how many times it is in the
# answer, raw, and in the lines the log gained for it - counted before any mask
nq() { local n0 a l; n0=$(mark); rq "$(url "$L_NOTE" "$1")"; a=$(raw "$NOTE" .harness/ans.raw); settle
  l=$(awk -v from="$n0" 'NR > from' .harness/run.out | LC_ALL=C grep -aoF -- "$NOTE" | wc -l | tr -d ' ')
  echo "  the canary (\$NOTE) in this answer: $a times · in the lines the log gained for it: $l times"; }
# dbg FROM: every line the log gained after line FROM, from its logger on (logger: message) - a map's timestamp masked; the lines
# that are no log line (a stack trace's), counted, never shown. dreq 'COMMAND': at DEBUG - the command printed and run, its answer
# (the timestamp masked), then every line the log gained for it, counted
dbg() { awk -v from="$1" 'NR > from && / [A-Z]+ [0-9]+ --- \[/ { s = $0; i = index(s, " --- ["); s = substr(s, i + 6); i = index(s, "] "); s = substr(s, i + 2)
    i = index(s, " : "); lg = substr(s, 1, i - 1); sub(/ +$/, "", lg); m = substr(s, i + 3); gsub(/timestamp=[^,]*,/, "timestamp=…,", m); print "    " lg ": " m }' .harness/run.out; }
dreq() { local n0 k o; n0=$(mark); echo "\$ $1"; (eval "$1") 2>&1 < /dev/null | tsmask | sed 's/^/  /'; settle
  k=$(dbg "$n0" | grep -c . || true); o=$(awk -v from="$n0" 'NR > from && !/ [A-Z]+ [0-9]+ --- \[/' .harness/run.out | grep -c . || true)
  echo "  the lines the log gained for it, Boot's web group at DEBUG (logger: message) - its log lines, all $k, and $o other lines (a stack trace's: frames and blank lines), not shown:"; dbg "$n0"; }
# blkraw FROM TO: this capture so far, the lines after the line that starts with FROM, up to the next line that starts with TO (to
# the end when TO is empty); asame A B A2 B2: yes when A's block (A up to B) and A2's (A2 up to B2), their labels aside, are the same
# line for line - an A' against its A
blkraw() { awk -v a="$1" -v b="$2" 'index($0, a) == 1 { f = 1; next } b != "" && index($0, b) == 1 { f = 0 } f' .harness/cap.raw; }
asame() { [ "$(blkraw "$1" "$2")" = "$(blkraw "$3" "$4")" ] && [ -n "$(blkraw "$3" "$4")" ] && echo yes || echo no; }
WARNS() { settle; echo "  WARN lines in this run's log, at Boot's default level: $(logl 0 WARN | grep -c . || true) · ERROR lines: $(logl 0 ERROR | grep -c . || true)"; }
# rp 'COMMAND': a command, printed and run, its output indented
rp() { echo "\$ $1"; (eval "$1") 2>&1 < /dev/null | sed 's/^/  /'; }
# bmeta KEY...: Boot's own metadata for each key - the jar in the anchor's extracted lib that declares it, its type, its default,
# its description, and the values its hint names
bmeta() { python3 - .harness/anchor/tiffinbox-web/target/extracted/lib "$@" <<'PY'
import glob, json, os, sys, zipfile
p = {}
for j in sorted(glob.glob(os.path.join(sys.argv[1], "*.jar"))):
    z = zipfile.ZipFile(j)
    if "META-INF/spring-configuration-metadata.json" not in z.namelist(): continue
    d = json.loads(z.read("META-INF/spring-configuration-metadata.json"))
    for x in d.get("properties", []): p.setdefault(x["name"], (os.path.basename(j), x, [v for h in d.get("hints", []) if h["name"] == x["name"] for v in h.get("values", [])]))
for k in sys.argv[2:]:
    if k not in p: print("  Boot's metadata - %s: in none of the jars" % k); continue
    j, e, hv = p[k]; dv = e.get("defaultValue")
    print("  Boot's metadata (%s) - %s · its type: %s · its default: %s · its description: %s" % (j, k, e.get("type", "none").rsplit(".", 1)[-1], "no default value" if dv is None else json.dumps(dv), e.get("description", "none")))
    if hv: print("    the values its hint names: %d%s" % (len(hv), "".join(" · %s - %s" % (v["value"], v.get("description", "none")) for v in hv)))
PY
}
# the filters, checked on planted inputs before any capture (R.65): a Whitelabel page, Tomcat's page, a page of another shape, a
# trace, an empty answer, a JSON answer; and a planted log - a WARN with 45 frames, an ERROR with 3
FT=$(printf '%s\n' "<html><body><h1>Whitelabel Error Page</h1><p>x</p><div id='created'>Sat Oct 17 09:49:42 CEST 2026</div><div>There was an unexpected error (type=Not Found, status=404).</div></body></html> 404 · Content-Type: [text/html;charset=UTF-8]" '<!doctype html><html lang="en"><head><title>HTTP Status 400 – Bad Request</title><style>x</style></head><body><h1>HTTP Status 400 – Bad Request</h1></body></html> 400 · Content-Type: [text/html;charset=utf-8]' '<html><p>other</p></html> 200' '{"timestamp":"2026-10-17T07:49:58.419Z","status":500,"trace":"java.lang.IllegalStateException: x\n\tat a.b(C.java:1)\n\tat d.e(F.java:2)\nCaused by: y\n\tat g.h(I.java:3)","path":"/p"} 500' ' 406 · Content-Type: []' '{"timestamp":1760000000000,"status":404} 404' | pagef)
[ "$FT" = "$(printf '%s\n' "  the Whitelabel page (Boot's) - its <h1>: Whitelabel Error Page · its error line: There was an unexpected error (type=Not Found, status=404). · its created date: masked · its paragraphs: 1, not shown · then curl's: 404 · Content-Type: [text/html;charset=UTF-8]" "  an HTML page - its <title>: HTTP Status 400 – Bad Request · its <h1>: HTTP Status 400 – Bad Request · its other characters: 80, not shown · then curl's: 400 · Content-Type: [text/html;charset=utf-8]" "  an HTML page of another shape: 25 characters, not shown · then curl's: 200" '  {"timestamp":"…","status":500,"trace":"…","path":"/p"} 500' '    its "trace", cut above: its first line: java.lang.IllegalStateException: x · its frames (\tat): 3 · its other lines: 1 - none shown' '  (no body) · 406 · Content-Type: []' '  {"timestamp":…,"status":404} 404')" ] || { printf '%s\n' "$FT" >&3; die "the answer filter (pagef) does not print the planted answers as declared"; }
printf '%s\n' '2026-10-17T09:49:32.042+02:00  WARN 1 --- [t-1] .w.s.m.s.DefaultHandlerExceptionResolver : Resolved [x]' 'org.example.X: planted' > .harness/run.out
i=0; while [ $i -lt 45 ]; do printf '\tat a.b(C.java:%d)\n' $i >> .harness/run.out; i=$((i + 1)); done
printf '%s\n' '2026-10-17T09:49:32.042+02:00 ERROR 1 --- [t-1] o.a.c.c.C.[.[.[/].[dispatcherServlet]    : boom' 'java.lang.IllegalStateException: y' '	at a.b(C.java:1)' '	at a.b(C.java:2)' '	at a.b(C.java:3)' '' '2026-10-17T09:49:32.042+02:00  INFO 1 --- [t-1] x.Y : after' >> .harness/run.out
[ "$(recs 0)" = "$(printf '%s\n' '    WARN .w.s.m.s.DefaultHandlerExceptionResolver: Resolved [x]' '      org.example.X: planted' '      its stack frames: over 40, its other lines: 0 - none shown' '    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: boom' '      java.lang.IllegalStateException: y' '      its stack frames: 3, its other lines: 1 - none shown')" ] || { recs 0 >&3; die "the record filter (recs) does not print the planted log as declared"; }
rm -f .harness/run.out
echo "  the filters: the answer filter and the record filter print their planted inputs as declared"

# the catalogue: every error TiffinBox can give, and the one POST the duplicate needs - OPTIONS and PATH for cq(); the anchor's README
# writes each kind (its GET line with a meal type, its POST line, its 2.7 line, its refused-body line, its POST /shutdown line)
BAD='{"name":"","mealsPerDay":0,"pricePerMeal":-5,"mealType":"LUNCH"}'; LATA='{"name":"Lata","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}'
JS="-H 'Content-Type: application/json'"
r=$(readme "curl -s -w ' %{http_code} · Location: [%header{location}]\n' $JS --data '$BAD' http://127.0.0.1:18431/customers")
CAT_N=15
catq() { local p=$1
  CQ1=$(cq "$p" "" '/customers?mealType=veg'); CQ2=$(cq "$p" "$JS --data '{\"name\":'" /customers)
  CQ3=$(cq "$p" "$JS --data '{\"name\":\"Mohan\",\"mealsPerDay\":2.7,\"pricePerMeal\":110,\"mealType\":\"VEG\"}'" /customers)
  CQ4=$(cq "$p" "$JS --data '$BAD'" /customers); CQ5=$(cq "$p" "" /customers/a%2Fb); CQ6=$(cq "$p" "-X POST" /shutdown)
  CQ7=$(cq "$p" "" /nowhere); CQ8=$(cq "$p" "" /customers/Nobody); CQ9=$(cq "$p" "" /shutdown); CQ10=$(cq "$p" "-X DELETE" /customers)
  CQ11=$(cq "$p" "-H 'Accept: application/xml'" /customers/Ravi); CQ12=$(cq "$p" "--data 'name=Asha'" /customers)
  CQ13=$(cq "$p" "$JS --data '$LATA'" /customers); CQ14=$CQ13; CQ15=$(cq "$p" "" /probe/boom)
  if [ -n "$2" ]; then local k=1; while [ $k -le $CAT_N ]; do eval "c_=\$CQ$k"
      case $c_ in *"-H 'Accept: "*) c_=$(printf '%s\n' "$c_" | sed "s#-H 'Accept: [^']*'#-H 'Accept: $2'#") ;; *) c_=${c_/"$CQW "/"$CQW -H 'Accept: $2' "} ;; esac
      eval "CQ$k=\$c_"; k=$((k + 1)); done; fi; }
# each request's kind of line, asserted against the anchor's own: the GET line, the POST line, the 2.7 line, the refused body's
catq 18431 ""
[ "${CQ1/"$WT"/$WS}" = "${R_GQ/VEGAN/veg}" ] && [ "${CQ3/"$WT"/$WS}" = "$R_27" ] && [ "${CQ6/"$WT"/$WS}" = "$R_403" ] && [ "${CQ13/"$WT"/$WS}" = "${R_POST/Asha\",/Lata\",}" ] || die "the catalogue's lines are not the anchor's lines with Content-Type printed and their values swapped"
r=${r/" -w ' %{http_code} · Location: [%header{location}]\n'"/$WT}; [ "$r" = "$CQ4" ] || die "the refused body's line is not the anchor's"

# ---- path: who writes an error answer ------------------------------------------------------------------------------------
path() {
  echo "the anchor - anchor/, copied under .harness/ with a config tree, built with its README's line (offline):"
  copy anchor .harness/anchor; pbuild .harness/anchor "the anchor"
  echo "  and its jar extracted (the README's line) - the class path the harness runs on:"
  extract .harness/anchor
  echo "the harness, compiled against the anchor's own jar - with -parameters (this unit's line):"
  echo "\$ $L_JAVAC"; rm -rf .harness/hc; (eval "$L_JAVAC") > .harness/javac.log 2>&1 < /dev/null || { cat .harness/javac.log >&3; die "the harness did not compile against the anchor's jar"; }
  echo "  exit 0 · its classes: $(cd .harness/hc && find . -name '*.class' | sed 's#^\./##' | sort | paste -sd' ' -)"
  echo "the seven - the anchor, the README's run line (its locale pinned), port 19430, a fresh JVM:"
  start "$(at .harness/anchor 19430 "$R_RUN")"; up 19430; ready 19430; seven 19430 .harness/anchor
  WARNS; logl 0 WARN
  echo "who writes an error answer - the anchor on its class path, the harness's Who and Boom joined, port 19430, read off the running application:"
  start "$(hcp "$L_CPL" .harness/anchor 19430 probe.web.Who,probe.web.Boom)"; up 19430; ready 19430
  rp "$(url "$L_WHO" 19430)"
  stop 19430 .harness/anchor
  echo "at DEBUG - the embedded-Tomcat lesson's option (Boot's web group at DEBUG), the same class path, port 19430: a route that throws (the harness's Boom), then a path no route takes:"
  start "$(hcp "$L_CPL" .harness/anchor 19430 probe.web.Who,probe.web.Boom "$O_WEB")"; up 19430; ready 19430
  dreq "$(cq 19430 "" /probe/boom)"
  dreq "$(cq 19430 "" /nowhere)"
  stop 19430 .harness/anchor; }

# ---- shapes: every error, each answer whole ---------------------------------------------------------------------------------
# shapesum: the answers this capture printed (.harness/answers.txt: one per request, the status and the answer), each error answer
# (a status of 400 or more) given a shape - a JSON answer by its keys, sorted; an HTML page by its <title> or <h1>; no body - and
# the shapes counted, each with its statuses in the catalogue's order
shapesum() { python3 - .harness/answers.txt <<'PY'
import json, re, sys
rows = [l.rstrip("\n").split("\t", 2) for l in open(sys.argv[1], encoding="utf-8")]
shapes, order, n = {}, [], 0
for st, ty, body in rows:
    if int(st) < 400: continue
    n += 1
    if body == "": k = "no body, no Content-Type" if ty == "" else "no body, Content-Type " + ty
    elif body.lstrip().startswith("{"):
        k = "JSON (%s), its keys: %s" % (ty, " ".join(sorted(json.loads(body))))
    else:
        t = re.search(r"<title>(.*?)</title>", body) or re.search(r"<h1>(.*?)</h1>", body)
        k = "an HTML page (%s): %s" % (ty, t.group(1) if t else "?")
    if k not in shapes: shapes[k] = []; order.append(k)
    shapes[k].append(st)
print("the error answers: %d · their shapes: %d" % (n, len(order)))
for i, k in enumerate(order, 1): print("  %d %s - %d answers: %s" % (i, k, len(shapes[k]), " ".join(shapes[k])))
PY
}
shapes() { local k=1 c
  echo "the catalogue - the anchor on its class path, the harness's Boom joined, port 19431, a fresh JVM; curl's own Accept (*/*) unless a line names one:"
  start "$(hcp "$L_CPL" .harness/anchor 19431 probe.web.Boom)"; up 19431; ready 19431
  catq 19431 ""; : > .harness/answers.txt
  while [ $k -le $CAT_N ]; do eval "c=\$CQ$k"
    rq "$c" nolog
    python3 - .harness/ans.raw >> .harness/answers.txt <<'PY'
import re, sys
s = open(sys.argv[1], encoding="utf-8").read().rstrip("\n")
m = re.search(r" (\d{3}) · Content-Type: \[([^]]*)\]$", s)
print("%s\t%s\t%s" % (m.group(1), m.group(2), s[:m.start()]))
PY
    k=$((k + 1)); done
  WARNS
  stop 19431 .harness/anchor
  shapesum; }

# ---- reasons: where the reason went -----------------------------------------------------------------------------------------
reasons() { local k=1 c
  echo "the same requests - the anchor on its class path, the harness's Boom joined, port 19432, a fresh JVM: each answer's status, then the WARN and ERROR lines it added, at Boot's default level:"
  start "$(hcp "$L_CPL" .harness/anchor 19432 probe.web.Boom)"; up 19432; ready 19432
  catq 19432 ""
  while [ $k -le $CAT_N ]; do eval "c=\$CQ$k"; rq "$c" status; k=$((k + 1)); done
  WARNS
  stop 19432 .harness/anchor; }

# ---- html: a browser's Accept type ------------------------------------------------------------------------------------------
html() { local k=1 c
  echo "the same requests, each with a browser's Accept type, text/html, sent by curl (the 406's own XML header made text/html too) - the anchor on its class path, the harness's Boom joined, port 19433, a fresh JVM:"
  start "$(hcp "$L_CPL" .harness/anchor 19433 probe.web.Boom)"; up 19433; ready 19433
  catq 19433 text/html
  while [ $k -le $CAT_N ]; do eval "c=\$CQ$k"; rq "$c"; k=$((k + 1)); done
  WARNS
  stop 19433 .harness/anchor; }

# ---- message: Boot's error keys; A/B/A' include-message; C, labelled: include-stacktrace ------------------------------------------
msgq() { rq "$(cq "$1" "" /customers/Nobody)"; rq "$(cq "$1" "" '/customers?mealType=veg')"; nq "$1"; }
msga() { start "$(hcp "$L_CPL" .harness/anchor 19434 probe.web.Boom)"; up 19434; ready 19434; msgq 19434; WARNS; stop 19434 .harness/anchor; }
message() {
  echo "Boot's error keys, read off its own metadata in the anchor's jars:"
  bmeta spring.web.error.include-message spring.web.error.include-exception spring.web.error.include-stacktrace spring.web.error.include-binding-errors spring.web.error.include-path
  echo "A - the anchor on its class path (this unit's line), the harness's Boom joined, port 19434: a name nobody has, a meal type no route takes, and a route that quotes a header in its exception's message - the canary in that header:"
  msga
  echo "B - the same, with Boot's include-message key set to always (this unit's line), port 19435:"
  start "$(hcp "$L_MSG" .harness/anchor 19435 probe.web.Boom)"; up 19435; ready 19435; msgq 19435; WARNS; stop 19435 .harness/anchor
  echo "A' - A again, a fresh JVM, port 19434:"
  msga
  echo "A' against A, its label aside, line for line the same: $(asame "A - " "B - " "A' - " "A' against A")"
  echo "C (labelled) - include-stacktrace set to always instead (this unit's line), port 19436: the route that throws, then the canary's:"
  start "$(hcp "$L_STK" .harness/anchor 19436 probe.web.Boom)"; up 19436; ready 19436
  rq "$(cq 19436 "" /probe/boom)"; nq 19436; WARNS; stop 19436 .harness/anchor; }

# ---- devtools: DevTools' defaults, restart enabled and disabled ----------------------------------------------------------------------
# dtline: DevTools' own lines - the one it writes before logging starts (from its level on: no time, no thread), and Boot's
# "Devtools property defaults" lines (logger: message) - each counted
dtline() { local a b
  a=$(grep -E '^[0-9:.]+ \[[^]]*\] [A-Z]+ org\.springframework\.boot\.devtools\.' .harness/run.out | sed -E 's/^[0-9:.]+ \[[^]]*\] //' | sort | uniq -c | awk '{ c = $1; $1 = ""; sub(/^ /, ""); printf "    %s ×%d\n", $0, c }')
  b=$(dbg 0 | grep 'DevToolsPropertyDefaultsPostProcessor' || true)
  echo "  DevTools' line before logging starts:"; printf '%s\n' "${a:-    none}"
  echo "  Boot's DevTools lines in the log (logger: message):"; printf '%s\n' "${b:-    none}"; }
devq() { echo "  listening on 35729 (Live Reload's port) now: $(listeners 35729)"
  rp "$(url "$L_WHOD" "$1")"
  rq "$(cq "$1" "" /customers/Nobody)"; rq "$(cq "$1" "" /probe/boom)"; nq "$1"; WARNS; }
devtools() {
  echo "the anchor's class path, as the README extracts it, with DevTools 4.1.1's jar added from \$M2 (the folders layout: this unit's line), restart enabled, Live Reload off, the harness's Who and Boom joined, port 19437:"
  start "$(hcp "$L_DEV" .harness/anchor 19437 probe.web.Who,probe.web.Boom)"; up 19437; ready 19437
  dtline; devq 19437
  stop 19437 .harness/anchor
  echo "the same with restart disabled (this unit's line), port 19438:"
  start "$(hcp "$L_DEVOFF" .harness/anchor 19438 probe.web.Who,probe.web.Boom)"; up 19438; ready 19438
  dtline; devq 19438
  stop 19438 .harness/anchor; }

# ---- exercise: the README's commands, exactly as written, then the solution's - in ONE shell --------------------------------------
block() { awk '/^```bash$/ { if (!d) { f = 1 }; next } f && /^```$/ { f = 0; d = 1 } f' "$1"; }
# The shell a viewer has: env -i - nothing this script set reaches it (its JAVA_HOME, the JDK at the front of its PATH, LC_ALL,
# no_proxy, $NOTE) - with HOME and the PATH you started this script with; /bin/bash without profile or rc files, started in this
# folder. A driver in .harness/ runs the README's block, then SOLUTION.md's, as a viewer pastes them - each with its output, its exit
# code and the folder it left the shell in kept apart (absolute paths: a command that moved the shell must not move these files),
# and the README's run log and saved answer kept before the solution's run writes its own. Bounded (600 s); on the way out, or past
# the bound, the shell and every process under it are stopped (killtree).
# where DIR: the folder the shell was left in - this unit's folder, a folder under it (named), or elsewhere
where() { case "$1" in "$U") echo "this unit's folder" ;; "$U"/*) echo "${1#"$U"/}" ;; *) echo "outside this unit's folder" ;; esac; }
exercise() { local setup sol i=0 e1 d1 e2 d2 l1 l2
  setup=$(block exercise/README.md); sol=$(block exercise/solution/SOLUTION.md)
  [ -n "$setup" ] && [ -n "$sol" ] || die "exercise/README.md or SOLUTION.md no longer gives its commands"
  [ "$(printf '%s\n' "$sol" | grep -c .)" = 3 ] || die "SOLUTION.md's first bash block must be the README's two export lines and its last line, one header changed"
  [ "$(printf '%s\n' "$sol" | sed -n 1,2p)" = "$(printf '%s\n' "$setup" | sed -n 1,2p)" ] || die "SOLUTION.md must start with the README's two export lines (a new shell's java may be another JDK)"
  printf '%s\n' "$sol" | sed -n 1p | grep -qxF 'export JAVA_HOME=/opt/homebrew/opt/openjdk@25' || die "SOLUTION.md's first line must export this script's JAVA_HOME"
  l1=$(printf '%s\n' "$setup" | tail -1); l2=$(printf '%s\n' "$sol" | sed -n 3p)
  r=$(python3 -c 'import sys; a, b = "-H \x27Accept: text/html\x27", "-H \x27Accept: application/json\x27"; l = sys.argv[1]; print(l.replace(a, b, 1) if l.count(a) == 1 else "")' "$l1")
  [ "$r" = "$l2" ] && [ "$l1" != "$l2" ] || die "SOLUTION.md's last line must be the README's last line with its Accept header made application/json, and nothing else"
  rm -f .harness/ex-*
  printf '%s\n' "$setup" > .harness/ex-readme.sh; printf '%s\n' "$sol" > .harness/ex-sol.sh
  cat > .harness/ex-drive.sh <<'DRV'
cd "$1" || exit 1
. "$1/.harness/ex-readme.sh" > "$1/.harness/ex-readme.out" 2>&1 < /dev/null
echo "$? $PWD" > "$1/.harness/ex-readme.st"
cp "$1/.harness/mine/run.log" "$1/.harness/ex-readme.log" 2> /dev/null
cp "$1/.harness/mine/got.txt" "$1/.harness/ex-readme.got" 2> /dev/null
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
  echo "  the answer it saved (../got.txt), through this script's answer filter:"; { cat .harness/ex-readme.got; echo; } | pagef | sed 's/^/  /'
  echo "  the shell is now in: $(where "$d1") · the copy's own token in its log: $(raw "$(head -1 .harness/mine/anchor/$TF)" .harness/ex-readme.log) times · WARN lines in its log: $(grep -c ' WARN ' .harness/ex-readme.log || true) · ERROR lines: $(grep -c ' ERROR ' .harness/ex-readme.log || true) · listening on 19439 now: $(listeners 19439)"
  echo "the solution's $(printf '%s\n' "$sol" | grep -c .) lines, next, in the same shell:"
  printf '%s\n' "$sol" | sed 's/^/  $ /'
  echo "  exit $e2 · what they printed:"; sed 's/^/    /' .harness/ex-sol.out
  echo "  the answer it saved (../got.txt), through this script's answer filter:"; { cat .harness/mine/got.txt; echo; } | pagef | sed 's/^/  /'
  echo "  the shell is now in: $(where "$d2") · the copy's own token in its log: $(raw "$(head -1 .harness/mine/anchor/$TF)" .harness/mine/run.log) times · WARN lines in its log: $(grep -c ' WARN ' .harness/mine/run.log || true) · ERROR lines: $(grep -c ' ERROR ' .harness/mine/run.log || true) · listening on 19439 now: $(listeners 19439)"; }

cap path path
cap shapes shapes
cap reasons reasons
cap html html
cap message message
cap devtools devtools
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
# handed to awk through its environment, which keeps a backslash a backslash (-v would turn \n into a newline); aftn N: the Nth
aft() { printf '%s\n' "$2" | C="$1" awk 'f { print; exit } $0 == ENVIRON["C"] { f = 1 }'; }
aftn() { printf '%s\n' "$3" | C="$2" N="$1" awk 'f { print; exit } $0 == ENVIRON["C"] && ++k == ENVIRON["N"] { f = 1 }'; }
# THE TOKEN: no capture holds it, raw - counted on each run's own output BEFORE masking - and neither does any log (each counted
# when it was read: logtok()), nor anything this unit ships for reading. The canary: no capture holds it raw either (each run's own
# canary; masked), and no file this unit ships holds this run's
for f in .harness/raw-*; do [ "$(cat "$f")" = "0" ] || die "a capture's raw output held the token ($f: $(cat "$f"))"; done
for f in .r-*.out README.md exercise/README.md exercise/solution/SOLUTION.md receipts.md5 harness/shutdown.sh $HWS; do
  [ "$(raw "$TOKEN" "$f")" = 0 ] || die "$f holds the demo token, raw"; [ "$(raw "$NOTE" "$f")" = 0 ] || die "$f holds this run's canary, raw"; done
for f in .r-*.out; do ! grep -qE '/Users/|/private/|/home/|/var/folders/' "$f" || die "$f holds an absolute path"; ! grep -qE 'c[0-9]-unit[0-9]|unit ?[0-9]' "$f" || die "$f holds a unit number"; ! grep -qE ' (with PID|started by) ' "$f" || die "$f holds Boot's process line"; ! grep -qE '^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T|^ *[0-9][0-9]:[0-9][0-9]:[0-9][0-9]|"timestamp":"?[0-9]|timestamp=[A-Z0-9]|(exec|handler|task|utility)-[0-9]|GMT|CES?T|<div id=.created|[A-Z][a-z][a-z] [A-Z][a-z][a-z] [0-9]+ [0-9][0-9]:[0-9][0-9]' "$f" || die "$f holds a log line's time, a timestamp, a date or a thread's number"; ! grep -q "^$(printf '\t')at " "$f" || die "$f shows a stack frame"; ! grep -qF '\tat ' "$f" || [ "$(grep -cF '\tat ' "$f")" = "$(grep -cF 'its frames (\tat): ' "$f")" ] || die "$f shows a trace's frame"; ! grep -qE ':(8080|35729)([^0-9]|$)' "$f" || die "$f shows a bind on 8080 or 35729"; ! grep -q $'\r' "$f" || die "$f holds a carriage return"; ! grep -qi '<html' "$f" || die "$f shows an HTML page whole"; done
for f in receipts.sh README.md exercise/README.md exercise/solution/SOLUTION.md harness/shutdown.sh $HWS; do ! grep -qE "exposure\.include='?\*" "$f" || die "$f exposes every endpoint (R.42)"; done
# S3.21 (R.99): Boot 4.1 reads only spring.web.error.*, and Boot 3's keys (server, then error) are ignored without a word - no file of
# this unit names one (the name is split here, so this line does not spell it)
K3='server'; K3="$K3.error."
for f in receipts.sh README.md exercise/README.md exercise/solution/SOLUTION.md harness/shutdown.sh $HWS; do ! grep -qF "$K3" "$f" || die "$f names one of Boot 3's error keys - Boot 4.1 reads only spring.web.error.* (S3.21)"; done
# S3.9 (R.105): no wait in this script, its checks or the exercise is bare - each names its pid ($! or a variable)
for f in receipts.sh exercise/README.md exercise/solution/SOLUTION.md; do ! grep -nE '(^|[;&|({] *)wait *($|[;&|)}])' "$f" | grep -vE '^[0-9]+: *#' > /dev/null || die "$f has a bare wait (S3.9)"; done
# no capture runs a command with a URL that is not 127.0.0.1's
for f in .r-*.out; do ! grep -E '^\$ ' "$f" | grep -oE 'https?://[^ '"'"']+' | grep -vE '^http://127\.0\.0\.1:' > /dev/null || die "$f runs a command with a URL that is not 127.0.0.1's"; done
# S3.1: every java line a capture starts pins the JVM's locale (the extract line prints nothing a locale changes)
for f in .r-*.out; do ! grep -E '^ *\$ (cd [^ ]+ && )?(exec )?java ' "$f" | grep -vF -- "java $JL " | grep -vF -- 'java -Djarmode=tools ' > /dev/null || die "$f starts a JVM without its locale pinned (S3.1)"; done
# S3.13: every DevTools run turns Live Reload off on its line
for f in .r-*.out; do ! grep -E '^\$ .*spring-boot-devtools' "$f" | grep -vF -- '--spring.devtools.livereload.enabled=false' > /dev/null || die "$f starts DevTools with Live Reload on (S3.13)"; done
NL=$(cat .r-*.out | grep -cE "^  its log: the demo token 0 times · X-Shutdown-Token 0 times\$" || true)
echo "  tokens: 0 raw copies in $(ls .harness/raw-* | wc -l | tr -d ' ') raw capture runs, in $(ls .r-*.out | wc -l | tr -d ' ') captures; the demo token 0 in the logs of every JVM that served ($LOGS here; the published captures' $NL), the READMEs, the harness, the exercise and receipts.md5; this run's canary in none of them, raw; no absolute path, no unit number, no process line, no log time, no timestamp, no date, no thread number, no stack frame, no whole HTML page, no 8080 or 35729, no carriage return in any capture; no Boot 3 error key; no bare wait; every java line's locale pinned; every DevTools line Live Reload off; every URL a capture runs is 127.0.0.1's"

S87C='87ca7efc8584dcccd40e6b956db1de9b'
Z() { printf '%s · WARN lines it added: %s · ERROR lines: %s' "$1" "$2" "$3"; }
WL() { printf "  the Whitelabel page (Boot's) - its <h1>: Whitelabel Error Page · its error line: There was an unexpected error (type=%s, status=%s). · its created date: masked · its paragraphs: 1, not shown · then curl's: %s · Content-Type: [text/html;charset=UTF-8]" "$1" "$2" "$2"; }
BOOT() { printf '  {"timestamp":"…","status":%s,"error":"%s","path":"%s"} %s · Content-Type: [application/json]' "$1" "$2" "$3" "$1"; }
TOMP="  an HTML page - its <title>: HTTP Status 400 – Bad Request · its <h1>: HTTP Status 400 – Bad Request · its other characters: 349, not shown · then curl's: 400 · Content-Type: [text/html;charset=utf-8]"
TOME='    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: Servlet.service() for servlet [dispatcherServlet] in context with path [] threw exception [Request processing failed: java.lang.IllegalStateException: the kitchen is on fire] with root cause'
TOMN='    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: Servlet.service() for servlet [dispatcherServlet] in context with path [] threw exception [Request processing failed: java.lang.IllegalStateException: the kitchen could not read the note [masked: the 26-character canary]] with root cause'
F40='      its stack frames: over 40, its other lines: 2 - none shown'
DH='    WARN .w.s.m.s.DefaultHandlerExceptionResolver: Resolved ['

# "Who writes it ... Boot's error controller, on a second pass, the error dispatch" - path: the beans, the resolvers, DEBUG's lines
PO=$(cat .r-path.out)
has "$PO" '  built the anchor · offline: yes · exit 0' "path: the anchor built offline"
has "$PO" "  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 2 · md5 $S87C" "path: the seven $S87C"
has "$PO" '  exit 0 · its classes: probe/web/Boom.class probe/web/Who.class' "path: the harness, two classes"
for l in '  ErrorController beans: basicErrorController - org.springframework.boot.webmvc.autoconfigure.error.BasicErrorController' '  ErrorAttributes beans: errorAttributes - org.springframework.boot.webmvc.error.DefaultErrorAttributes' '  ResponseEntityExceptionHandler beans: 0' "  the HandlerExceptionResolver beans, in the order the DispatcherServlet asks them: 2" '    1 errorAttributes - org.springframework.boot.webmvc.error.DefaultErrorAttributes' '    2 handlerExceptionResolver - org.springframework.web.servlet.handler.HandlerExceptionResolverComposite' '        2.1 org.springframework.web.servlet.mvc.method.annotation.ExceptionHandlerExceptionResolver' '        2.2 org.springframework.web.servlet.mvc.annotation.ResponseStatusExceptionResolver' '        2.3 org.springframework.web.servlet.mvc.support.DefaultHandlerExceptionResolver' "  ExceptionHandlerExceptionResolver's advice cache: 0 advices" "  the JVM's locale: en_US"; do has "$PO" "$l" "path: who writes an error answer"; done
PD=$(blk path "at DEBUG" '')
for l in '    o.s.web.servlet.DispatcherServlet: Failed to complete request: java.lang.IllegalStateException: the kitchen is on fire' "${TOME#    ERROR }" '    o.s.web.servlet.DispatcherServlet: "ERROR" dispatch for GET "/error", parameters={}' '    s.w.s.m.m.a.RequestMappingHandlerMapping: Mapped to org.springframework.boot.webmvc.autoconfigure.error.BasicErrorController#error(HttpServletRequest)' '    o.s.web.servlet.DispatcherServlet: Exiting from "ERROR" dispatch, status 500' "    .w.s.m.s.DefaultHandlerExceptionResolver: Resolved [org.springframework.web.servlet.resource.NoResourceFoundException: No static resource nowhere for request '/nowhere'.]" '    o.s.web.servlet.DispatcherServlet: Exiting from "ERROR" dispatch, status 404'; do
  case $l in '    '*) has "$PD" "$l" "path: DEBUG" ;; *) has "$PD" "    $l" "path: DEBUG, Tomcat's ERROR line" ;; esac; done
[ "$(printf '%s\n' "$PD" | grep -c '"ERROR" dispatch for GET "/error"')" = 2 ] && [ "$(printf '%s\n' "$PD" | grep -c 'Mapped to org.springframework.boot.webmvc.autoconfigure.error.BasicErrorController#error')" = 2 ] || die "path: two requests, two error dispatches, each to Boot's error controller"
echo "  path: the seven $S87C; BasicErrorController and DefaultErrorAttributes (Boot's); 2 resolver beans, DefaultErrorAttributes first, the composite's 3; 0 advices; at DEBUG: Tomcat's ERROR line, then the error dispatch to BasicErrorController, for the 500 and the 404"

# "Fifteen requests ... five shapes" - shapes: each answer, and the shapes counted
SO=$(cat .r-shapes.out)
for t in "1:$(BOOT 400 'Bad Request' /customers)" "4:  {\"mealType\":\"must match \\\"VEG|NON_VEG|VEGAN\\\"\",\"mealsPerDay\":\"must be greater than or equal to 1\",\"name\":\"must not be blank\",\"pricePerMeal\":\"must be greater than or equal to 1\"} 400 · Content-Type: [application/json]" "5:$TOMP" "6:  {\"error\":\"forbidden\"} 403 · Content-Type: [application/json]" "7:$(BOOT 404 'Not Found' /nowhere)" "8:$(BOOT 404 'Not Found' /customers/Nobody)" "9:$(BOOT 405 'Method Not Allowed' /shutdown)" "11:  (no body) · 406 · Content-Type: []" "12:$(BOOT 415 'Unsupported Media Type' /customers)" "14:  (no body) · 409 · Content-Type: []" "15:$(BOOT 500 'Internal Server Error' /probe/boom)"; do
  k_=${t%%:*}; a_=${t#*:}; catq 19431 ""; eval "c_=\$CQ$k_"
  [ "$k_" = 14 ] && g_=$(aftn 2 "\$ $c_" "$SO") || g_=$(aft "\$ $c_" "$SO"); [ "$g_" = "$a_" ] || die "shapes: request $k_ ($c_) answers: $a_"; done
for l in 'the error answers: 14 · their shapes: 5' '  1 JSON (application/json), its keys: error path status timestamp - 9 answers: 400 400 400 404 404 405 405 415 500' '  2 JSON (application/json), its keys: mealType mealsPerDay name pricePerMeal - 1 answers: 400' '  3 an HTML page (text/html;charset=utf-8): HTTP Status 400 – Bad Request - 1 answers: 400' '  4 JSON (application/json), its keys: error - 1 answers: 403' '  5 no body, no Content-Type - 2 answers: 406 409'; do has "$SO" "$l" "shapes: the shapes counted"; done
[ "$(n shapes '^\$ curl ')" = "$((CAT_N + 1))" ] || die "shapes: the catalogue's $CAT_N requests and the readiness line"
echo "  shapes: 15 requests, 14 error answers, 5 shapes - Boot's four keys for nine (400 x3, 404 x2, 405 x2, 415, 500), the method's field map, Tomcat's HTML 400, {\"error\":\"forbidden\"}, no body for the 406 and the 409; Nobody's 404 names nobody"

# "the reason is in one warning line ... a four oh four, nothing ... the five hundred, Tomcat's error line" - reasons: counted per request
RO=$(cat .r-reasons.out)
catq 19432 ""
for t in "1:400:1:0" "2:400:1:0" "3:400:1:0" "4:400:0:0" "5:400:0:0" "6:403:0:0" "7:404:0:0" "8:404:0:0" "9:405:1:0" "10:405:1:0" "11:406:1:0" "12:415:1:0" "13:201:0:0" "14:409:0:0" "15:500:0:1"; do
  k_=${t%%:*}; r_=${t#*:}; s_=${r_%%:*}; r_=${r_#*:}; w_=${r_%%:*}; e_=${r_#*:}; eval "c_=\$CQ$k_"
  [ "$k_" = 14 ] && a_=$(aftn 2 "\$ $c_" "$RO") || a_=$(aft "\$ $c_" "$RO"); case $a_ in "  the answer: $s_ · Content-Type: "*" · WARN lines it added: $w_ · ERROR lines: $e_") ;; *) die "reasons: request $k_ ($c_): $s_, $w_ WARN, $e_ ERROR - got: $a_" ;; esac; done
has "$RO" "  WARN lines in this run's log, at Boot's default level: 7 · ERROR lines: 1" "reasons: 7 WARN, 1 ERROR in all"
[ "$(printf '%s\n' "$RO" | grep -cF "$DH")" = 7 ] || die "reasons: every WARN is Spring MVC's DefaultHandlerExceptionResolver's"
for l in "${DH}org.springframework.http.converter.HttpMessageNotReadableException: JSON parse error: Unexpected end-of-input within/between Object entries]" "${DH}org.springframework.web.HttpMediaTypeNotAcceptableException: No acceptable representation]" "$TOME" "      java.lang.IllegalStateException: the kitchen is on fire" "$F40"; do has "$RO" "$l" "reasons: the records"; done
printf '%s\n' "$RO" | grep -qF "${DH}org.springframework.web.method.annotation.MethodArgumentTypeMismatchException: Method parameter 'mealType': Failed to convert value" || die "reasons: the type mismatch's WARN"
echo "  reasons: one WARN (Spring MVC's DefaultHandlerExceptionResolver) for each 400 Boot answered, each 405, the 406, the 415 - 7; none for either 404, the method's 400, the 403, the 409; the 500: Tomcat's ERROR line, over 40 frames"

# "Ask as a browser does ... the Whitelabel page ... TiffinBox's own answers become four oh sixes" - html
HO=$(cat .r-html.out)
catq 19433 text/html
for t in "1:$(WL 'Bad Request' 400):1:0" "4:$(WL 'Not Acceptable' 406):1:0" "5:$TOMP:0:0" "6:$(WL 'Not Acceptable' 406):1:0" "7:$(WL 'Not Found' 404):0:0" "8:$(WL 'Not Found' 404):0:0" "11:$(WL 'Not Acceptable' 406):1:0" "13:$(WL 'Not Acceptable' 406):1:0" "14:  (no body) · 409 · Content-Type: []:0:0" "15:$(WL 'Internal Server Error' 500):0:1"; do
  k_=${t%%:*}; r_=${t#*:}; e_=${r_##*:}; r_=${r_%:*}; w_=${r_##*:}; a_=${r_%:*}; eval "c_=\$CQ$k_"
  [ "$k_" = 14 ] && g_=$(aftn 2 "\$ $c_" "$HO") || g_=$(aft "\$ $c_" "$HO"); [ "$g_" = "$(Z "$a_" "$w_" "$e_")" ] || die "html: request $k_ ($c_)"; done
has "$HO" "  WARN lines in this run's log, at Boot's default level: 10 · ERROR lines: 1" "html: 10 WARN, 1 ERROR"
[ "$(n html '^  the Whitelabel page')" = 13 ] || die "html: 13 answers are the Whitelabel page"
echo "  html: text/html - the Whitelabel page for 13 of 15 (its <h1>, type and status; the created date masked): /nowhere 404, Nobody 404, the 500; the method's 400, the 403, Ravi and Lata's 201 become 406s, each a WARN; Tomcat's page and the empty 409 unchanged"

# "include-message ... the reason in the answer, and the canary with it" - message: A/B/A', C
MO=$(cat .r-message.out)
for l in '  Boot'"'"'s metadata (spring-boot-autoconfigure-4.1.1.jar) - spring.web.error.include-message · its type: ErrorProperties$IncludeAttribute · its default: "never" · its description: When to include "message" attribute.' '  Boot'"'"'s metadata (spring-boot-autoconfigure-4.1.1.jar) - spring.web.error.include-stacktrace · its type: ErrorProperties$IncludeAttribute · its default: "never" · its description: When to include the "trace" attribute.' '  Boot'"'"'s metadata (spring-boot-autoconfigure-4.1.1.jar) - spring.web.error.include-exception · its type: Boolean · its default: false · its description: Include the "exception" attribute.' '  Boot'"'"'s metadata (spring-boot-autoconfigure-4.1.1.jar) - spring.web.error.include-path · its type: ErrorProperties$IncludeAttribute · its default: "always" · its description: When to include "path" attribute.'; do has "$MO" "$l" "message: Boot's metadata"; done
MA=$(blk message "A - " "B - "); MB=$(blk message "B - " "A' - "); MC=$(blk message "C (labelled)" '')
has "$MO" "A' against A, its label aside, line for line the same: yes" "message: A' = A"
has "$MA" "$(Z "$(BOOT 404 'Not Found' /customers/Nobody)" 0 0)" "message A: Nobody, no message"
has "$MA" "  the canary (\$NOTE) in this answer: 0 times · in the lines the log gained for it: 2 times" "message A: the canary 0 in the answer, 2 in the log"
has "$MA" "$TOMN" "message A: Tomcat's ERROR line quotes the note"
has "$MB" "$(Z '  {"timestamp":"…","status":404,"error":"Not Found","message":"no customer named Nobody","path":"/customers/Nobody"} 404 · Content-Type: [application/json]' 0 0)" "message B: Nobody's message"
has "$MB" "  the canary (\$NOTE) in this answer: 1 times · in the lines the log gained for it: 2 times" "message B: the canary 1 in the answer, 2 in the log"
printf '%s\n' "$MB" | grep -qF '"message":"Method parameter '"'"'mealType'"'"': Failed to convert value of type ' || die "message B: the type mismatch's reason in the answer"
printf '%s\n' "$MB" | grep -qF '"message":"the kitchen could not read the note [masked: the 26-character canary]"' || die "message B: the canary in the 500's message"
has "$MC" "    its \"trace\", cut above: its first line: java.lang.IllegalStateException: the kitchen is on fire · its frames (\\tat): 44 · its other lines: 0 - none shown" "message C: 44 frames"
has "$MC" "  the canary (\$NOTE) in this answer: 1 times · in the lines the log gained for it: 2 times" "message C: the canary 1 in the answer (the trace's first line)"
echo "  message: include-message default never; A: no message, the canary 0 in the answer, 2 in the log; B: Nobody's name and the type mismatch's reason in the answer, the canary 1; A' = A; C: include-stacktrace - 44 frames, the canary 1"

# "DevTools ... nine defaults ... three error keys ... a trace ... a warning line for the four oh four ... exit one; restart off: none"
DO=$(cat .r-devtools.out); D1=$(blk devtools "the anchor's class path" "the same with restart disabled"); D2=$(blk devtools "the same with restart disabled" '')
has "$D1" '  the property source named devtools: 9 keys, sorted' "devtools: 9 keys"
for k in 'spring.web.error.include-binding-errors = always' 'spring.web.error.include-message = always' 'spring.web.error.include-stacktrace = always' 'spring.mvc.log-resolved-exception = true' 'spring.template.provider.cache = false' 'spring.web.resources.cache.period = 0' 'spring.web.resources.chain.cache = false' 'server.servlet.session.persistent = true' 'server.servlet.jsp.init-parameters.development = true'; do has "$D1" "    $k" "devtools: the key $k"; done
[ "$(printf '%s\n' "$D1" | grep -c '^    spring\.web\.error\.')" = 3 ] || die "devtools: three error keys"
has "$D1" '  spring.web.error.include-message: always · from: devtools' "devtools: include-message from devtools"
has "$D1" '    .e.DevToolsPropertyDefaultsPostProcessor: Devtools property defaults active! Set '"'"'spring.devtools.add-properties'"'"' to '"'"'false'"'"' to disable' "devtools: Boot's DevTools line"
has "$D1" "    WARN .w.s.m.a.ResponseStatusExceptionResolver: Resolved [org.springframework.web.server.ResponseStatusException: 404 NOT_FOUND \"no customer named Nobody\"]" "devtools: the 404 gains a WARN"
has "$D1" "    its \"trace\", cut above: its first line: java.lang.IllegalStateException: the kitchen is on fire · its frames (\\tat): 44 · its other lines: 0 - none shown" "devtools: the 500's trace, 44 frames"
has "$D1" "  the canary (\$NOTE) in this answer: 2 times · in the lines the log gained for it: 2 times" "devtools: the canary twice in the answer"
has "$D1" '  listening on 35729 (Live Reload'"'"'s port) now: 0' "devtools: Live Reload never bound"
has "$D1" '  exit 1 · listening on 19437 now: 0' "devtools: restart enabled, exit 1"
has "$D2" '  the property source named devtools: none' "devtools: restart disabled, no property source"
has "$D2" '  spring.web.error.include-message: not set · from: none' "devtools: restart disabled, the key not set"
has "$D2" "$(Z "$(BOOT 404 'Not Found' /customers/Nobody)" 0 0)" "devtools: restart disabled, Boot's four keys, 0 WARN"
has "$D2" "  the canary (\$NOTE) in this answer: 0 times · in the lines the log gained for it: 2 times" "devtools: restart disabled, the canary 0 in the answer"
has "$D2" '  exit 0 · listening on 19438 now: 0' "devtools: restart disabled, exit 0"
x devtools 'INFO org\.springframework\.boot\.devtools\.restart\.RestartApplicationListener -- Restart enabled irrespective'
x devtools 'INFO org\.springframework\.boot\.devtools\.restart\.RestartApplicationListener -- Restart disabled due to System property'
for b in "$D1" "$D2"; do [ "$(printf '%s\n' "$b" | grep -c '^  listens on: 127\.0\.0\.1:1943[78] · loopback only: yes$')" = 1 ] || die "devtools: one address, loopback"; done
echo "  devtools: restart enabled - the property source devtools, 9 keys, 3 of them error keys and log-resolved-exception; the 404 gains a message, a trace and Spring MVC's WARN; the 500 a trace of 44 frames; the canary twice in the answer; 35729 free; exit 1 - restart disabled: no property source, Boot's four keys, 0 WARN, the canary 0, exit 0"

# the exercise's end state: the README's commands, then the solution's, in ONE env -i shell - each leaves the shell in this folder; the
# line exercise/README.md calls "Done" is a line of this capture, after the solution's lines, and of SOLUTION.md's measured run
XS=$(blk exercise "the README's" "the solution's"); XE=$(blk exercise "the solution's" '')
l='status: 404 · Content-Type: application/json'; l0='status: 404 · Content-Type: text/html;charset=UTF-8'
has "$XE" "    $l" "exercise: the solution"; has "$XS" "    $l0" "exercise: as shipped"
has "$XS" "    $(WL 'Not Found' 404 | sed 's/^  //; s/ · then curl.s: .*$/ · then curl'"'"'s:/')" "exercise: as shipped, the Whitelabel page"
has "$XE" '    {"timestamp":"…","status":404,"error":"Not Found","path":"/customers/Nobody"}' "exercise: the solution, Boot's four keys"
awk '/^\*\*Done\*\*/ { f = 1 } f' exercise/README.md | grep -qxF -- "$l" || die "exercise/README.md: Done names no such line"
grep -qxF -- "$l" exercise/solution/SOLUTION.md || die "SOLUTION.md: the measured run shows no such line"
grep -qF -- "\`$l0\`" exercise/README.md || die "exercise/README.md: the shipped line's answer is not named"
has "$XS" '  exit 0 · what they printed:' "exercise: the README's commands, exit 0"; has "$XE" '  exit 0 · what they printed:' "exercise: the solution's lines, exit 0"
for b in "$XS" "$XE"; do has "$b" "  the shell is now in: this unit's folder · the copy's own token in its log: 0 times · WARN lines in its log: 0 · ERROR lines: 0 · listening on 19439 now: 0" "exercise: the shell in this unit's folder, the token 0, the port free"; done
[ "$(printf '%s\n' "$XE" | grep -c '^  \$ export ')" = 2 ] || die "exercise: SOLUTION.md gives the README's two export lines"
EXQ="Your turn: the README's request gets an HTML page, not JSON. Read its Content-Type, change one header, and read the status again."
grep -qxF -- "**Your turn:** ${EXQ#Your turn: }" exercise/README.md || die "exercise/README.md: the spoken exercise line"
[ "$(printf '%s\n' "$EXQ" | wc -w | tr -d ' ')" -le 25 ] || die "exercise: the spoken line is over 25 words"
echo "  exercise: one env -i shell - the README as written (Accept: text/html) -> 404 text/html, the Whitelabel page; the solution (Accept: application/json) -> 404 application/json, Boot's four keys; the shell in this unit's folder after each"

[ -z "$unpub" ] || die "no published hash for:$unpub - check the captures, then copy the md5s above into receipts.md5 and run again"
echo "c6-unit14: every capture 3/3 and = published; every spoken number asserted; 0 raw demo tokens in every capture and every log; the canary only where a capture counts it"
