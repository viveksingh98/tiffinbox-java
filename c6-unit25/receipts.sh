#!/bin/bash
XPATH=$PATH                                           # the PATH you started this with: the exercise's own shell gets it
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25.0.4.1 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# Course 6 · RestClient - this unit's receipts. No anchor change: anchor/ is the link to ../c6-unit24/after, the tree the sessions
# lesson froze (= c6-tiffinbox at Section 4's end). This script copies that tree under .harness/anchor, builds it and runs it - as its
# README runs it, and on its class path with the two jars Boot's RestClient starter adds (harness/pom.xml, read by Maven's
# dependency:build-classpath) and the course's harness joined (harness/probe/web, outside com.tiffinbox) - and calls a stub: a small
# stand-in server on this computer (harness/stub/Stub.java, the JDK's own HTTP server, one source file) that serves Core Java II's five
# files and prints every request whole. Spring's RestClient does Core Java II's HttpClient job again, and the captures show what changed.
# Seven captures, each run three times and hashed; cap() DIES when a hash differs from receipts.md5; every number the video says is
# asserted at the bottom by a check that can fail; the demo token is masked (gsub), and the checks count 0 raw copies of it in every
# capture, in the log of every run, in the stub's dump of every run and in every file this unit ships.
#   change     the anchor built and extracted (61 libraries); the harness POM's class path - the jars the anchor's lib/ lacks, by name,
#              each with its class count, the two that hold classes joined; the harness compiled; the seven on the jar, then on the
#              harness line, the same, byte for byte; the client beans by name, read off the running context
#   same       Core Java II's five files in the stub's www/, md5 against ../c2-unit28/www; the stub started, its bind read off its pid;
#              the request factory read off three clients; the list into records, the month total; one file into one record; the
#              stub's dump of both requests, whole; the HTTP2-Settings value against Core Java II's README; no Accept header
#   status     the four-oh-four as an exception (its class, status, message, classes up to RestClientException); exchange() - the
#              status, no exception; onStatus; a default status handler on a cloned builder, and a later clone without it; 500 and
#              503; C (labelled): one builder configured, then built twice - the handler carried into the later client
#   timeouts   Boot's own metadata for spring.http.clients. and for Boot 3's spelling; A the plural read-timeout key, 1s, against
#              the stub's 3-second answer: cancelled; B Boot 3's singular key: answered; A' = A; C (labelled) connect-timeout alone:
#              answered; D (labelled) no key: answered - each a fresh JVM, judged by the outcome line, never by a clock
#   defaults   a redirect through Boot's builder and through RestClient.create(); the observations of both, in one scrape of
#              /actuator/prometheus; C (labelled) the redirects key at dont-follow
#   failure    a harness route on TiffinBox that calls the stub: the stub's 500, its 404, its 200 - TiffinBox's answer and the stub's,
#              each WARN and ERROR record; the stub down on 19549 (asserted free): the exception and its cause
#   exercise   exercise/README.md's commands, then exercise/solution/SOLUTION.md's, read from the files and run as written, one after
#              the other in ONE shell a viewer could have: env -i, /bin/bash, started in this folder
# "The anchor" is anchor/, the link to ../c6-unit24/after, COPIED under .harness/anchor; this script never writes into another unit's
# folder, and never builds a frozen tree in place. Every run of TiffinBox starts in .harness/anchor, which holds a config tree with a
# fake token (secrets/), as the README asks. Commands are printed exactly as they run: each goes through eval. "$CURLSET" is the
# comparison set since the secrets lesson (../c5-unit11/curlset.sh: the seven requests, POST /shutdown with the token's header read
# from the file). "$M2" is this unit's own repository, .m2-demo. The harness - harness/probe/web (compiled with -parameters): Calls
# (an ApplicationRunner: the cases --probe.cases names, one CALL line each), CallRoutes (GET /probe/remote?path=..., a route that
# calls the stub), Row (a record: one customer) - is the course's, never TiffinBox's: outside com.tiffinbox, joined by
# --spring.main.sources on the extracted jar's class path, and named on every capture that uses it; harness/pom.xml names Boot's
# RestClient starter for dependency:build-classpath (R.26); harness/stub/ is the stub and Core Java II's www/, copied (the client
# lessons after this one copy the stub byte for byte); harness/keys.py reads a jar's configuration metadata (the upload lesson's, byte
# for byte), harness/meta.py one key's entry with its deprecation; harness/shutdown.sh is POST /shutdown with the token read from its
# file (the filters lesson's, byte for byte). Every run passes options only. The seven run first, on a fresh JVM of the jar.
# The locale: the JVM ignores LC_ALL on macOS - it takes the Mac's first language - and Spring's, Jackson's and Tomcat's messages in
# the log and in the answers are written in the JVM's locale: so every JVM this script starts - TiffinBox and the stub - has its locale
# pinned on its run line (-Duser.language=en -Duser.country=US, before -jar, -cp or the source file), every harness JVM and the stub
# print it, and the checks assert en_US.
# The network: every Maven build runs offline (-o) against .m2-demo and says so ("offline: yes"); a build that cannot resolve an
# artifact offline goes to Maven Central once, and says that ("offline: no - ..."). No native build, no Docker and no browser: this
# unit measures the JVM alone, with curl and the stub. At run time nothing leaves 127.0.0.1: TiffinBox and the stub listen there,
# every request goes there, and Logback writes to the terminal only.
# Masks and filters (README.md declares each; awk sub/gsub only): the demo token becomes "[masked: the N-character token]" (N its
# own length); this folder's absolute path "…", the folder above it "…/..", the home folder "~"; your user name "<user>" - in every
# line of every capture. The JDK's version in the client's User-Agent becomes "<version>" (printed once on the terminal, R.136).
# Spring's error timestamp becomes "…" (both forms) in the seven and wherever an answer is printed. A run's log lines are printed from
# their logger on (no time, no process id, no thread); Boot's first line is cut before " with PID". A WARN or ERROR record is printed
# as its level, logger and message, then the exception line under it; its stack frames are bounded ("over 40") and its other lines
# counted, never shown. The stub's dump is printed whole where a capture reads what a client sent (same), and elsewhere as one line
# per request with its header count; a request a client cancelled has its answer cut (when it lands is timing). A scrape of
# /actuator/prometheus is kept to ^http_client_requests_seconds_count, sorted, the kept lines counted. No duration is captured: a
# timeout is judged by the call's outcome - answered or cancelled - against a stub that waits three times the timeout.
# Ports (brief ⚑1, 19540-19549): TiffinBox 19540-19544 (one JVM at a time), the stub 19546, 19549 never bound (asserted free: the stub
# is down); 19545, 19547, 19548 unused. Captures run one after another, each JVM and each stub stopped before the next starts. 18425
# (TiffinBox's default), 8080 (Tomcat's) and 35729 (DevTools' Live Reload) are checked free too, and never bound.
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
# On every exit - the end, a failed check, or Ctrl-C - stop the processes this script started in the background ($pid, TiffinBox;
# $spid, the stub; $xpid, the exercise's shell, with every process under it - its Maven, its JVMs, its curl), if they still run, then
# sweep(): anything of this run still alive in its process group - a TiffinBox JVM, a stub, a Maven - is stopped. After an interrupt,
# a capture's unfinished runs (.r-NAME.1-3) go too; after a failed check they stay, for the diff the message names. The clean-up
# ignores a second Ctrl-C, and nothing in it can fail under set -e, so it always reaches the rmdir; the script still exits 130 after
# an interrupt (README.md, "Interrupted"). $pid, $spid and $xpid are cleared whenever their process has been reaped. sweep() kills only
# processes of this run's own process group - start each run in a group of its own (README.md, "Interrupted"). No wait in this script
# is bare: each names its pid.
pid=""; spid=""; xpid=""
sweep() { local g i l
  g=$(ps -o pgid= -p $$ 2> /dev/null | tr -d ' ') || g=""
  [ -n "$g" ] || return 0
  i=0; while [ $i -lt 20 ]; do
    l=$(ps -axo pid=,pgid=,command= 2> /dev/null | awk -v g="$g" -v me=$$ '
      $2 == g && $1 != me && $3 != "awk" && $3 != "ps" && (index($0, "tiffinbox-web-1.0.0.jar") || index($0, "com.tiffinbox.web.TiffinBoxServer") || index($0, "stub/Stub.java") || index($0, "org.codehaus.plexus.classworlds.launcher.Launcher")) { print $1 }' | paste -sd' ' -) || l=""
    [ -n "$l" ] || return 0
    if [ $i -lt 10 ]; then kill $l 2> /dev/null || true; else kill -9 $l 2> /dev/null || true; fi
    sleep 0.5; i=$((i + 1)); done; }
# desc PID: every process under PID - its children, theirs, and so on (ps, by parent); killtree PID: PID and all of them, TERM
desc() { ps -axo pid=,ppid= 2> /dev/null | awk -v r="$1" '{ p[$1] = $2 } END { n = 1; q[1] = r; for (i = 1; i <= n; i++) for (c in p) if (p[c] == q[i]) { q[++n] = c; print c } }'; }
killtree() { local d; d=$(desc "$1"); kill "$1" $d 2> /dev/null || true; }
trap 'trap "" INT TERM; [ -z "$xpid" ] || killtree "$xpid"; for p in "$pid" "$spid" "$xpid"; do if [ -n "$p" ] && kill "$p" 2> /dev/null; then wait "$p" 2> /dev/null || true; fi; done; sweep || true; [ -z "$INTR" ] || rm -f .r-*.[123]; rmdir .r-lock 2> /dev/null || true' EXIT
INTR=""; trap 'INTR=1; exit 130' INT TERM
exec 3>&1                                            # die() speaks to the terminal even inside a redirected capture
die() { echo "  *** $* ***" >&3; exit 1; }
java -version 2>&1 | grep -q 'version "25' || die "JDK 25 needed; JAVA_HOME gives: $(java -version 2>&1 | head -1)"
# Boot's first line names the JDK ("using Java 25.0.4.1"): machine data, masked in every capture as "using Java <version>" (RED S5
# #426/#472) - the version printed here once, on the terminal
JV=$(java -version 2>&1 | sed -n '1s/.*version "\([^"]*\)".*/\1/p')
echo "  (terminal only) the JDK is $JV - Boot's first line names it; the captures say Java <version>"
for t in python3 curl rsync lsof unzip javac mvn cmp md5; do command -v $t > /dev/null || die "$t is needed"; done
# A variable of yours must not become a property source, a JVM flag or a build setting: every TIFFINBOX_*, SPRING_*, MANAGEMENT_*,
# SERVER_* and LOGGING_* variable, DEBUG (Boot reads it as --debug), the variables that inject JVM flags, MAVEN_OPTS, MAVEN_ARGS and
# NATIVE_IMAGE_OPTIONS are removed first (the last course's failure lesson's loop, verbatim: sed -E, a canary planted under every
# name first, and the run stops if one survives). This unit runs no Docker, so COMPOSE_* is not in the list. (A
# SPRING_HTTP_CLIENTS_READ_TIMEOUT of yours would set the very timeout this unit shows unset; a JAVA_TOOL_OPTIONS could set every
# JVM's locale.)
for v in TIFFINBOX_CANARY SPRING_CANARY MANAGEMENT_CANARY SERVER_CANARY LOGGING_CANARY DEBUG JAVA_TOOL_OPTIONS JDK_JAVA_OPTIONS _JAVA_OPTIONS MAVEN_OPTS MAVEN_ARGS NATIVE_IMAGE_OPTIONS; do export "$v=planted-canary"; done
for v in $(env | sed -n -E 's/^(TIFFINBOX_[A-Za-z0-9_]*|SPRING_[A-Za-z0-9_]*|MANAGEMENT_[A-Za-z0-9_]*|SERVER_[A-Za-z0-9_]*|LOGGING_[A-Za-z0-9_]*|DEBUG|JAVA_TOOL_OPTIONS|JDK_JAVA_OPTIONS|_JAVA_OPTIONS|MAVEN_OPTS|MAVEN_ARGS|NATIVE_IMAGE_OPTIONS)=.*/\1/p'); do unset "$v"; done
[ -z "$(env | grep -- '=planted-canary$')" ] || die "a variable survived the clean-up above: $(env | grep -- '=planted-canary$' | sed 's/=.*//' | paste -sd' ' -)"
# Every request this script makes goes to 127.0.0.1: an HTTP proxy named in your environment would carry curl's requests to that
# proxy instead - 127.0.0.1 and localhost go first in no_proxy and NO_PROXY.
export no_proxy="127.0.0.1,localhost${no_proxy:+,$no_proxy}" NO_PROXY="127.0.0.1,localhost${NO_PROXY:+,$NO_PROXY}"
[ -e secrets ] && die "this folder holds a secrets/ - remove it: every run here starts in a folder under .harness/"
[ -L anchor ] && [ "$(readlink anchor)" = ../c6-unit24/after ] || die "anchor must be the link to ../c6-unit24/after - this unit changes nothing in the anchor"
[ -f anchor/pom.xml ] && [ -f anchor/README.md ] && [ -f anchor/tiffinbox-web/pom.xml ] || die "the anchor (its pom.xml, README.md or web module's pom.xml) is missing"
[ -e anchor/secrets ] || [ -e anchor/target ] || [ -e anchor/tiffinbox-web/target ] || [ -e anchor/tiffinbox-core/target ] || [ -e anchor/tiffinbox-local.yaml ] && die "anchor/ holds a secrets/, a target/ or a tiffinbox-local.yaml - it is a frozen copy, never built in place"
M2="$PWD/.m2-demo"; U="$PWD"; UP="$(cd .. && pwd)"; ME="$(id -un)"
TF=secrets/tiffinbox/shutdown-token                  # the config tree's file for tiffinbox.shutdown-token
# The demo token. FAKE, and meant to look it: it guards nothing but a demo server on 127.0.0.1 that every capture stops. It is
# written into .harness/anchor/secrets/ (git-ignored) when this script runs, and no capture prints it: see mask().
TOKEN=demo-token-for-calls-that-go-out
[ ${#TOKEN} = 32 ] || die "the demo token must be 32 characters: the published captures name its length"
CURLSET=../c5-unit11/curlset.sh                      # the comparison set: the seven requests, POST /shutdown with the header
[ -f "$CURLSET" ] || die "$CURLSET is missing"
C2=../c2-unit28                                      # Core Java II's HttpClient lesson: its www/ and its README, read, never written
WWW='customers.json meera.json priya.json ravi.json sunil.json'
HWS='harness/probe/web/CallRoutes.java harness/probe/web/Calls.java harness/probe/web/Row.java'
for f in harness/pom.xml harness/stub/Stub.java harness/shutdown.sh harness/keys.py harness/meta.py $HWS exercise/README.md exercise/solution/SOLUTION.md README.md $C2/README.md; do [ -f "$f" ] || die "$f is missing"; done
for w in $WWW; do [ -f "harness/stub/www/$w" ] && [ -f "$C2/www/$w" ] || die "harness/stub/www/$w or $C2/www/$w is missing"; done
[ "$(ls harness/probe/web | paste -sd' ' -)" = 'CallRoutes.java Calls.java Row.java' ] || die "harness/probe/web holds another file: javac compiles all of it"
[ "$(ls harness/stub/www | paste -sd' ' -)" = "$WWW" ] && [ "$(ls $C2/www | paste -sd' ' -)" = "$WWW" ] || die "harness/stub/www must hold Core Java II's five files, and nothing else"
[ "$(ls harness/stub | paste -sd' ' -)" = 'Stub.java www' ] || die "harness/stub holds another file"
[ "$(ls exercise/solution | paste -sd' ' -)" = 'SOLUTION.md' ] && [ "$(ls exercise | paste -sd' ' -)" = 'README.md solution' ] || die "exercise/ holds another file: the exercise is the README's commands, the solution a key"
[ ! -e harness/target ] || die "harness/target exists - dependency:build-classpath builds nothing; remove it"
cmp -s harness/shutdown.sh ../c6-unit18/harness/shutdown.sh || die "harness/shutdown.sh must be the filters lesson's, byte for byte"
cmp -s harness/keys.py ../c6-unit20/harness/keys.py || die "harness/keys.py must be the upload lesson's, byte for byte"
# Boot 3's spelling of the client keys (the singular one) - built here, never written whole in this file: the check at the bottom
# refuses it in every file of this unit outside the labelled break B and the exercise's broken README (R.138)
K1='spring.http.client'; K1="$K1."

# The ports, BEFORE anything is wiped (a survivor of an interrupted run answers POST /shutdown only with its token, which lives in
# .harness/ - so the message names the process to kill).
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
for p in 18425 8080 35729 19540 19541 19542 19543 19544 19545 19546 19547 19548 19549; do
  [ "$(listeners $p)" = 0 ] || die "something already listens on $p - this unit's ports must be free; if it is a TiffinBox or a stub an interrupted run left behind, stop it: kill $(lsof -nP -iTCP:$p -sTCP:LISTEN -t 2> /dev/null | paste -sd' ' -)"; done

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
# lines with the JVM's locale pinned; the class-path line with each timeout or redirect key as an option; the harness POM's class
# path; the harness's javac line; the stub's run line; md5 of the two www/ folders; Core Java II's HTTP2-Settings line; the metadata
# readers; the anchor's Content-Type line at the harness route; the scrape saved to a file
mine() { grep -m1 -xF -- "$1" README.md > /dev/null || die "README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
JL='-Duser.language=en -Duser.country=US'
LIBD=.harness/anchor/tiffinbox-web/target/extracted/lib
HTTPJ=.harness/xlib/spring-boot-http-client-4.1.1.jar
L_RUNL=$(mine "java $JL -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431")
L_CPL=$(mine "java $JL -cp $CPL")
L_A=$(mine "$L_CPL --spring.http.clients.read-timeout=1s")
L_B=$(mine "$L_CPL --${K1}read-timeout=1s")
L_C=$(mine "$L_CPL --spring.http.clients.connect-timeout=1s")
L_R=$(mine "$L_CPL --spring.http.clients.redirects=dont-follow")
L_HCP=$(mine 'mvn -o -B -q -Dmaven.repo.local="$M2" -f harness/pom.xml dependency:build-classpath -Dmdep.outputFile="$PWD/.harness/harness.cp"')
L_JAVAC=$(mine "javac -parameters -d .harness/hc -cp \"$LIBD/*:.harness/xlib/*\" $HWS")
L_STUB=$(mine "java $JL harness/stub/Stub.java --port=19546 --www=harness/stub/www")
L_MD5=$(mine 'for f in harness/stub/www/*.json; do echo "$(md5 -q "$f") $(md5 -q "$C2/www/${f##*/}") ${f##*/}"; done')
L_H2=$(mine "grep -o 'HTTP2-Settings: [A-Za-z0-9+/=]*' \"\$C2/README.md\"")
L_KEYS=$(mine "python3 harness/keys.py $HTTPJ spring.http.clients.")
L_META=$(mine "python3 harness/meta.py $HTTPJ ${K1}read-timeout")
L_REM=$(mine "curl -s$WT 'http://127.0.0.1:18431/probe/remote?path=/status/500'")
L_PROM=$(mine "curl -s -o .harness/prom.txt -w ' %{http_code}\n' http://127.0.0.1:18431/actuator/prometheus")
# The derivations, each asserted
P_='java '; Q_="java $JL "; r=${R_RUN/"$P_"/$Q_}; r2=${R_CP/"$P_"/$Q_}
[ "$r" = "$L_RUNL" ] && [ "$r2" = "$L_CPL" ] || die "the pinned lines must be the anchor's run and class-path lines with $JL after java, and nothing else"
O_A=${L_A#"$L_CPL "}; O_B=${L_B#"$L_CPL "}; O_C=${L_C#"$L_CPL "}; O_R=${L_R#"$L_CPL "}
[ "$O_A" = '--spring.http.clients.read-timeout=1s' ] && [ "$O_B" = "--${K1}read-timeout=1s" ] && [ "$O_C" = '--spring.http.clients.connect-timeout=1s' ] && [ "$O_R" = '--spring.http.clients.redirects=dont-follow' ] || die "the A, B, C and redirect lines must be the pinned class-path line with one key as an option, and nothing else"
[ "${O_A/clients./client.}" = "$O_B" ] || die "B must be A with Boot 3's singular spelling, and nothing else"
[ "${L_JAVAC#* -cp \"*\" }" = "$HWS" ] || die "the harness's javac line must compile the three files in harness/probe/web, and nothing else"
P_=' http://127.0.0.1:18431/customers/Nobody'; Q_=" 'http://127.0.0.1:18431/probe/remote?path=/status/500'"; r=${R_PD/"$P_"/$Q_}
[ "$r" = "$L_REM" ] || die "the remote line must be the anchor's Content-Type line at the harness route, and nothing else"
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
# PORT, the two jars the starter adds (../xlib) and the harness's classes (../hc) on the class path, CLASSES joined
# (--spring.main.sources=); OPTIONS after
hcp() { local c; c=$(at "$1" "$2" "$R_CP"); c=${c/lib\/\*\"/lib\/*:..\/xlib\/*:..\/hc\"}; printf '%s --spring.main.sources=%s%s\n' "$c" "$3" "${4:+ $4}"; }
# url 'curl LINE' PORT: the line, its port 18431 made PORT; rq PORT PATH: this unit's remote line, its port PORT, the stub's PATH
url() { printf '%s\n' "${1/:18431\//:$2/}"; }
rq() { local c; c=$(url "$L_REM" "$1"); printf '%s\n' "${c/path=\/status\/500/path=$2}"; }
# exe 'COMMAND': the command with "exec" after its "cd DIR && " - so $pid is the program's
exe() { printf '%s\n' "$1" | sed -E 's/&& (([A-Z_]+=[^ ]* )*)/\&\& \1exec /'; }
C_PRE=$(off .harness/pre "$R_PLAIN" package)
[ "$(dev "$C_PRE")" = "$R_PLAIN" ] || die "not the README's build line with the offline changes: $C_PRE"
[ "$(exe "$(at .harness/x 19540 "$R_RUN")")" = "cd .harness/x && exec ${L_RUNL/18431/19540}" ] && [ "$(at .harness/x 18431 "$R_CP")" = "cd .harness/x && $L_CPL" ] && [ "$(at .harness/x 18431 "$R_EXTRACT")" = "cd .harness/x && $R_EXTRACT" ] || die "at(): the pinned lines are not README.md's"
[ "$(hcp .harness/x 19543 probe.web.Calls "--probe.cases=slow $O_A")" = 'cd .harness/x && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../xlib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19543 --spring.main.sources=probe.web.Calls --probe.cases=slow --spring.http.clients.read-timeout=1s' ] || die "hcp()"
[ "$(rq 18431 /status/500)" = "$L_REM" ] && [ "$(rq 19542 /week-9.json)" = "curl -s$WT 'http://127.0.0.1:19542/probe/remote?path=/week-9.json'" ] || die "rq()"
echo "  the commands: anchor/README.md gives the 6 lines this script runs or derives from; README.md the 15 this unit adds"

# ---- build: before the captures - the anchor built once, the harness POM's class path read once (on a fresh clone these fill
# ---- .m2-demo); what .m2-demo holds ---------------------------------------------------------------------------------------------
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
mbuild "$L_HCP" .harness/hcp-pre.log "the harness POM's class path"
[ ! -e harness/target ] || die "dependency:build-classpath wrote harness/target"
for a in spring-boot-restclient spring-boot-http-client spring-boot-starter-restclient; do
  [ -f "$M2/org/springframework/boot/$a/4.1.1/$a-4.1.1.jar" ] || die "$a 4.1.1 is not in .m2-demo after the first builds"; done
[ ! -e "$M2/org/apache/httpcomponents/client5/httpclient5" ] || [ -z "$(grep -F httpclient5 .harness/harness.cp || true)" ] || die "httpclient5 is on the harness's class path - every factory sentence would change"
echo "  .m2-demo holds Boot's RestClient starter and the two jars it brings, 4.1.1"


# ---- helpers ------------------------------------------------------------------------------------------------------------
# raw TOKEN FILE...: how many times TOKEN appears, raw, in the files (occurrences, not lines; binary files read as text)
raw() { local t=$1; shift; cat "$@" | LC_ALL=C grep -aoF -- "$t" | wc -l | tr -d ' '; }
LOGS=0; DUMPS=0; LASTE=""                            # logs counted: served runs; the stub's dumps counted
first() { grep -m1 -E ' : Starting |^main Starting ' "$1" | sed 's/^.* : //; s/^main //; s/ with PID .*$//'; }
start() { echo "\$ $1"; (eval "$(exe "$1")") > .harness/run.out 2> .harness/run.err < /dev/null & pid=$!; }
# addrs PID: the addresses the process PID listens on, read off the process (lsof, by pid - its command name is never printed)
addrs() { lsof -nP -a -p "$1" -iTCP -sTCP:LISTEN 2> /dev/null | awk 'NR > 1 { print $9 }' | sort -u | paste -sd' ' -; }
# listening PID [PORT]: addrs, polled until the process listens (on PORT, when given) - every 0.25 s, up to 120 s
listening() { local a="" i=0
  while [ $i -lt 480 ]; do
    a=$(addrs "$1"); if [ -n "$2" ]; then case " $a " in *":$2 "*) break ;; esac; elif [ -n "$a" ]; then break; fi
    kill -0 "$1" 2> /dev/null || break; sleep 0.25; i=$((i + 1)); done
  echo "${a:-nothing}"; }
# lb ADDRESSES: yes when every one is 127.0.0.1:<port> - the check R.78 asks for, on the address read off the process
lb() { local a n=0; for a in $1; do n=$((n + 1)); case $a in 127.0.0.1:*) ;; *) echo no; return ;; esac; done; [ $n -gt 0 ] && echo yes || echo no; }
up() { local l; l=$(listening "$pid" "$1"); [ "$l" != nothing ] || { tail -20 .harness/run.out >&3; die "it never listened"; }
  case " $l " in *':8080 '*|*':35729 '*|*':19549 '*) kill -9 "$pid" 2> /dev/null || true; die "it listened on 8080, 35729 or 19549 - never bound by this script";; esac
  echo "  listens on: $l · loopback only: $(lb "$l")"; echo "  Boot's first line: $(first .harness/run.out)"; }
# ready PORT: readiness asked until it answers 200 - every 0.25 s, up to 120 s, not printed - then the README's readiness line,
# printed and run once. No assertion before it (R.41, R.75). A JVM ($pid) that exits first stops the run. (The harness's Calls runs
# its cases before readiness answers: a runner is done before Boot's application is ready.)
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
# The stub. sstart: its run line (this unit's), printed and run from this folder, its output to .harness/stub.out; then its bind,
# read off its pid (polled until it listens on 19546, up to 120 s - it compiles itself first), and the locale it printed. sstop: the
# stub stopped by its pid (TERM: it has no shutdown route), waited for, 19546 free; its dump counted - the demo token 0 times and the
# header X-Shutdown-Token 0 times (R.137) - and how many requests it printed.
sstart() { local l; echo "\$ $L_STUB"; (eval "exec $L_STUB") > .harness/stub.out 2>&1 < /dev/null & spid=$!
  l=$(listening "$spid" 19546); [ "$l" != nothing ] || { tail -20 .harness/stub.out >&3; die "the stub never listened"; }
  echo "  the stub listens on: $l · loopback only: $(lb "$l") · its locale: $(grep -m1 "^STUB the JVM's locale: " .harness/stub.out | sed "s/^.*locale: //")"; }
sstop() { local e=0 t h n
  kill "$spid" 2> /dev/null || true; wait "$spid" || e=$?; spid=""
  [ "$(listeners 19546)" = 0 ] || die "something still listens on 19546"
  t=$(raw "$TOKEN" .harness/stub.out); h=$(LC_ALL=C grep -aoi -- 'x-shutdown-token' .harness/stub.out | wc -l | tr -d ' '); n=$(grep -c '^STUB [A-Z]* /' .harness/stub.out || true)
  DUMPS=$((DUMPS + 1)); [ "$t" = 0 ] && [ "$h" = 0 ] || die "the stub's dump held the demo token ($t) or its header's name ($h)"
  echo "  the stub: stopped by its pid · exit $e · listening on 19546 now: 0 · requests in its dump: $n · the demo token 0 times · X-Shutdown-Token $h times"
  [ -z "$(grep -m1 '^STUB-H user-agent: ' .harness/stub.out)" ] || grep -m1 '^STUB-H user-agent: ' .harness/stub.out | sed 's/^STUB-H user-agent: //' > .harness/ua.txt; }
mask() { awk -v t="$TOKEN" -v u="$U" -v up="$UP" -v hm="$HOME" -v me="$ME" -v tl="${#TOKEN}" '
  function lit(x) { gsub(/[][\\.^$*+?(){}|\/]/, "\\\\&", x); return x }
  function enc(x) { gsub(/ /, "%20", x); return x }
  BEGIN { T = lit(t); P = lit(u); Q = lit(up); H = lit(hm); PE = lit(enc(u)); QE = lit(enc(up)); M = "(^|[^A-Za-z0-9_])" lit(me) "([^A-Za-z0-9_]|$)" }
  { gsub(T, "[masked: the " tl "-character token]"); gsub(P, "…"); gsub(PE, "…")
    gsub(Q, "…/.."); gsub(QE, "…/.."); gsub(H, "~"); gsub(/\$\$SpringCGLIB\$\$[0-9]+/, "$$SpringCGLIB$$<n>")
    gsub(/Java-http-client\/[0-9][0-9.]*/, "Java-http-client/<version>")
    gsub(/ using Java [0-9][0-9.]*/, " using Java <version>")
    if (match($0, /java\.io\.IOException: /)) { pre = substr($0, 1, RSTART + RLENGTH - 1); post = substr($0, RSTART + RLENGTH); i = index(post, " - ")
      $0 = pre "<the OS'"'"'s words>" (i ? substr(post, i) : "") }
    while (match($0, M)) { pre = substr($0, 1, RSTART - 1); s = substr($0, RSTART, RLENGTH); post = substr($0, RSTART + RLENGTH)
      sub(lit(me), "<user>", s); $0 = pre s post }
    print }'; }

unpub=""
cap() { local nm=$1 h pub i; shift
  for i in 1 2 3; do "$@" > .harness/cap.raw 2>&1 || true; [ -z "$pid" ] && [ -z "$spid" ] && [ -z "$xpid" ] || die "$nm left a process running"
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
# settle [FILE]: the file (the run's log unless named) stops growing (the same length twice, 0.5 s apart; up to 15 s) - a request's
# last line is written just after its answer leaves
settle() { local i=0 a b=-1 f=${1:-.harness/run.out}; while [ $i -lt 30 ]; do a=$(wc -l < "$f" | tr -d ' '); [ "$a" = "$b" ] && return 0; b=$a; sleep 0.5; i=$((i + 1)); done; die "$f never settled"; }
mark() { settle; wc -l < .harness/run.out | tr -d ' '; }
smark() { settle .harness/stub.out; wc -l < .harness/stub.out | tr -d ' '; }
# logl FROM [LEVELS]: the run's lines after line FROM at those levels (WARN|ERROR unless named), from their level and logger on
logl() { awk -v from="$1" -v lv="${2:-WARN|ERROR}" 'NR > from && $0 ~ (" (" lv ") [0-9]+ --- \\[") { l = $2; s = $0; i = index(s, " --- ["); s = substr(s, i + 6); i = index(s, "] "); s = substr(s, i + 2)
    i = index(s, " : "); lg = substr(s, 1, i - 1); sub(/ +$/, "", lg); msg = substr(s, i + 3)
    gsub(/@[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]+/, "@…", msg); print "    " l " " lg ": " msg }' .harness/run.out; }
# recs FROM: each WARN or ERROR record the log gained after line FROM (the harness's CALL lines skipped) - its level, its logger and
# its message; then the exception line under it (the first line after the record that is neither blank nor a stack frame); its stack
# frames, bounded ("over 40"), and its other lines, counted - none shown
recs() { awk -v from="$1" '
  function out() { if (inr) print "      its stack frames: " (fr > 40 ? "over 40" : fr + 0) ", its other lines: " (ot + 0) " - none shown"; inr = 0; fr = 0; ot = 0; ex = 0 }
  NR <= from { next }
  /^CALL / { next }
  / [A-Z]+ [0-9]+ --- \[/ { out() }
  / (WARN|ERROR) [0-9]+ --- \[/ { s = $0; i = index(s, " --- ["); s = substr(s, i + 6); i = index(s, "] "); s = substr(s, i + 2)
    i = index(s, " : "); lg = substr(s, 1, i - 1); sub(/ +$/, "", lg); m = substr(s, i + 3); gsub(/@[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]+/, "@…", m)
    print "    " $2 " " lg ": " m; inr = 1; ex = 1; next }
  inr && /^\tat / { fr++; next }
  inr && ex && NF > 0 { print "      " $0; ex = 0; next }
  inr { ot++ }
  END { out() }' .harness/run.out; }
lvl() { grep -cE "^[0-9]{4}-[0-9]{2}-[0-9]{2}T[^ ]+ +$1 " "$2" || true; }
WARNS() { settle; echo "  WARN lines in this run's log, at Boot's default level: $(logl 0 WARN | grep -c . || true) · ERROR lines: $(logl 0 ERROR | grep -c . || true) · lines that say \"deprecat\": $(grep -ci deprecat .harness/run.out .harness/run.err | awk -F: '{ s += $NF } END { print s + 0 }')"; }
# counted FROM: the WARN and ERROR lines the log gained after line FROM, as " · WARN lines it added: N · ERROR lines: M"
counted() { local w e; settle; w=$(logl "$1" WARN | grep -c . || true); e=$(logl "$1" ERROR | grep -c . || true); printf ' · WARN lines it added: %s · ERROR lines: %s' "$w" "$e"; }
# calls: the harness's CALL lines (Calls), in the order they printed, whole - after its "done" line, which must be there
calls() { grep -q '^CALL done$' .harness/run.out || { tail -20 .harness/run.out >&3; die "the harness's Calls never printed done"; }
  echo "  the harness's lines (Calls), in the order they printed: $(grep -c '^CALL ' .harness/run.out)"; grep '^CALL ' .harness/run.out | sed 's/^CALL /    /'; }
rloc() { echo "  the JVM's locale (the harness's CallRoutes): $(grep -m1 "^ROUTE the JVM's locale: " .harness/run.out | sed "s/^.*locale: //")"; }
loc() { echo "  the JVM's locale (the harness's Calls): $(grep -m1 "^CALL the JVM's locale: " .harness/run.out | sed "s/^.*locale: //")"; }
# The stub's dump. sdump FROM: every line it printed after line FROM, whole, each after a "|" (the requests, every header, every
# answer); sreqs FROM: one line per request after line FROM - its method and URI, its header count, and the stub's answer (the line
# after its headers); sonly FROM: one line per request, its method and URI and its header count - the answers cut: after a client
# cancelled, the stub's answer lands when its wait ends, and where that line falls in the dump is timing (R.121)
sdump() { local n; n=$(awk -v f="$1" 'NR > f' .harness/stub.out | grep -c . || true); echo "  the stub's dump since, whole: $n lines"; awk -v f="$1" 'NR > f { print "    | " $0 }' .harness/stub.out; }
sreqs() { awk -v f="$1" 'NR <= f { next } /^STUB [A-Z]+ \// { if (q != "") print q " · headers: " h " · no answer"; q = "    " $2 " " $3; h = 0; next } /^STUB-H / { h++; next }
    /^STUB-ANSWER / { a = $0; sub(/^STUB-ANSWER /, "", a); if (q == "") print "    a late answer, its request above: " a; else print q " · headers: " h " · the stub answered " a; q = ""; next } END { if (q != "") print q " · headers: " h " · no answer" }' .harness/stub.out; }
sonly() { awk -v f="$1" 'NR <= f { next } /^STUB [A-Z]+ \// { if (q != "") print q " · headers: " h; q = "    " $2 " " $3; h = 0; next } /^STUB-H / { if (q != "") h++; next }
    /^STUB-(ANSWER|FAIL) / { if (q != "") print q " · headers: " h; q = ""; next } END { if (q != "") print q " · headers: " h; print "    its answers: cut - after a cancelled call, where its answer lands in the dump is timing" }' .harness/stub.out; }
# promf FILE: the scrape kept to its client-request counts (^http_client_requests_seconds_count), sorted, the kept lines counted
# beside the scrape's own line count
promf() { local k n o; k=$(grep -c '^http_client_requests_seconds_count' "$1" || true); n=$(wc -l < "$1" | tr -d ' ')
  o=$((n - k)); [ $o -gt 150 ] && o="over 150 (their number moves from run to run: the JVM's own meters)"
  echo "  kept: $k of the scrape's lines, by the filter ^http_client_requests_seconds_count, sorted · the others not shown: $o"
  grep '^http_client_requests_seconds_count' "$1" | sort | sed 's/^/    /' || true; }
# pagef: a curl answer through its filter - a JSON answer, a problem detail too, as it came, its error timestamp masked
pagef() { tsmask | sed 's/^/  /'; }
# blkraw FROM TO: this capture so far, the lines after the line that starts with FROM, up to the next line that starts with TO (to
# the end when TO is empty); asame A B A2 B2: yes when A's block (A up to B) and A2's (A2 up to B2), their labels aside, are the same
# line for line - an A' against its A
blkraw() { awk -v a="$1" -v b="$2" 'index($0, a) == 1 { f = 1; next } b != "" && index($0, b) == 1 { f = 0 } f' .harness/cap.raw; }
asame() { [ "$(blkraw "$1" "$2")" = "$(blkraw "$3" "$4")" ] && [ -n "$(blkraw "$3" "$4")" ] && echo yes || echo no; }
# The level counts, the record filter, the stub's dump filters and the scrape filter, checked on planted inputs before any capture
# (R.65, R.120): a harness line that says ERROR, one WARN and one ERROR record - each count must be 1 by the log's own line shape,
# where a bare ' ERROR ' counts 2; a planted dump with a header given twice, an answer, a request with no answer; a planted scrape
mkdir -p .harness
{ printf '%s\n' 'CALL 5xx /status/500 org.springframework.web.client.HttpServerErrorException$InternalServerError - status 500 - message: 500 Internal Server Error: ERROR' '2026-10-22T00:00:00.000+02:00  WARN 1 --- [planted] o.s.web.servlet.PageNotFound             : planted warning' '2026-10-22T00:00:00.001+02:00 ERROR 1 --- [planted] o.a.c.c.C.[.[.[/].[dispatcherServlet]    : planted error' 'java.lang.IllegalStateException: planted' "$(printf '\tat a')" 'CALL done'; } > .harness/run.out
[ "$(logl 0 ERROR | grep -c .)" = 1 ] && [ "$(logl 0 WARN | grep -c .)" = 1 ] && [ "$(lvl ERROR .harness/run.out)" = 1 ] && [ "$(lvl WARN .harness/run.out)" = 1 ] && [ "$(grep -c ' ERROR' .harness/run.out)" = 2 ] || die "the level counts: the planted log must give 1 WARN and 1 ERROR by line shape (a bare ' ERROR' gives 2)"
[ "$(recs 0)" = "$(printf '%s\n' '    WARN o.s.web.servlet.PageNotFound: planted warning' '      its stack frames: 0, its other lines: 0 - none shown' '    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: planted error' '      java.lang.IllegalStateException: planted' '      its stack frames: 1, its other lines: 0 - none shown')" ] || die "recs: the planted log's harness lines must be skipped (.harness/run.out)"
printf '%s\n' 'STUB listening on /127.0.0.1:19546' 'STUB GET /a.json headers=[Accept-encoding, Host]' 'STUB-H accept-encoding: gzip' 'STUB-H accept-encoding: deflate' 'STUB-H host: 127.0.0.1:19546' 'STUB-ANSWER 404 text/plain 9 bytes' 'STUB GET /slow?ms=3000 headers=[Host]' 'STUB-H host: 127.0.0.1:19546' 'STUB GET /b.json headers=[Host]' 'STUB-H host: 127.0.0.1:19546' 'STUB-ANSWER 200 application/json 73 bytes' 'STUB-ANSWER 200 application/json 13 bytes' > .harness/stub.out
PL=$(sreqs 1); [ "$PL" = "$(printf '%s\n' '    GET /a.json · headers: 3 · the stub answered 404 text/plain 9 bytes' '    GET /slow?ms=3000 · headers: 1 · no answer' '    GET /b.json · headers: 1 · the stub answered 200 application/json 73 bytes' '    a late answer, its request above: 200 application/json 13 bytes')" ] || die "sreqs: the planted dump does not come out as declared (got: $PL)"
PL=$(sonly 1); [ "$PL" = "$(printf '%s\n' '    GET /a.json · headers: 3' '    GET /slow?ms=3000 · headers: 1' '    GET /b.json · headers: 1' '    its answers: cut - after a cancelled call, where its answer lands in the dump is timing')" ] || die "sonly: the planted dump does not come out as declared (got: $PL)"
PL=$(sdump 1); [ "$(printf '%s\n' "$PL" | sed -n 1p)" = "  the stub's dump since, whole: 11 lines" ] && [ "$(printf '%s\n' "$PL" | grep -c '^    | STUB-H accept-encoding: ')" = 2 ] || die "sdump: the planted dump must come out whole, a header given twice as two lines"
printf '%s\n' '# HELP x' 'http_client_requests_seconds_count{uri="/{f}"} 2' 'jvm_threads_live_threads 30' 'http_client_requests_seconds_count{uri="/a"} 1' > .harness/p1
PL=$(promf .harness/p1); [ "$PL" = "$(printf '%s\n' '  kept: 2 of the scrape'"'"'s lines, by the filter ^http_client_requests_seconds_count, sorted · the others not shown: 2' '    http_client_requests_seconds_count{uri="/a"} 1' '    http_client_requests_seconds_count{uri="/{f}"} 2')" ] || die "promf: the planted scrape does not come out as declared (got: $PL)"
printf '%s\n' 'Java-http-client/25.0.4.1 and Java-http-client/23' "$TOKEN" > .harness/p1
[ "$(mask < .harness/p1)" = "$(printf '%s\n' 'Java-http-client/<version> and Java-http-client/<version>' '[masked: the 32-character token]')" ] || die "mask: the planted User-Agent versions and token must be masked"
[ "$(printf '%s\n' 'Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1' | mask)" = 'Starting TiffinBoxServer v1.0.0 using Java <version>' ] || die "mask: the planted Boot first line's JDK version must be masked (RED S5 #426/#472)"
rm -f .harness/run.out .harness/stub.out .harness/p1
echo "  the filters: the record filter, the stub's dump filters, the scrape filter and the masks print their planted inputs as declared; a harness line that says ERROR is no ERROR line; a header given twice is two lines"

# ---- change: what joins - the anchor, the starter's jars, the harness, the seven, the beans --------------------------------------
change() { local n0 e=0
  echo "the anchor - anchor/, copied under .harness/ with a config tree, built with its README's line (offline), its jar extracted (the README's line):"
  copy anchor .harness/anchor; pbuild .harness/anchor "the anchor"; extract .harness/anchor
  echo "  the anchor's libraries (its extracted lib/): $(ls "$LIBD" | grep -c '\.jar$') · Boot's RestClient module among them: $(ls "$LIBD" | grep -c '^spring-boot-restclient-' || true) · httpclient5: $(ls "$LIBD" | grep -c '^httpclient5-' || true)"
  echo "what Boot's RestClient starter brings - the harness POM's class path (this unit's line), each jar it lists by name against the anchor's lib/:"
  rm -f .harness/harness.cp; echo "\$ $L_HCP"; mbuild "$L_HCP" .harness/hcp.log "the harness POM's class path"
  [ ! -e harness/target ] || die "dependency:build-classpath wrote harness/target"
  rm -rf .harness/xlib; mkdir -p .harness/xlib
  tr ':' '\n' < .harness/harness.cp | grep . > .harness/hcp.lst
  echo "  the jars it lists: $(wc -l < .harness/hcp.lst | tr -d ' ') · in the anchor's lib/ already, by name (the version is in the name): $(while IFS= read -r j; do [ -e "$LIBD/${j##*/}" ] && echo x; done < .harness/hcp.lst | grep -c . || true) · not:"
  while IFS= read -r j; do [ -e "$LIBD/${j##*/}" ] && continue
    n=$(unzip -l "$j" | grep -c '\.class$' || true); if [ "$n" -gt 0 ]; then cp "$j" .harness/xlib/; w="joined (.harness/xlib)"; else w="not joined: no class - a starter is its POM's dependencies"; fi
    echo "    ${j##*/} · classes: $n · $w"; done < .harness/hcp.lst
  echo "  the class path the harness runs on: the anchor's $(ls "$LIBD" | grep -c '\.jar$') libraries + $(ls .harness/xlib | grep -c '\.jar$') = $(( $(ls "$LIBD" | grep -c '\.jar$') + $(ls .harness/xlib | grep -c '\.jar$') ))"
  echo "the harness, compiled against the anchor's own jars and those two - with -parameters (this unit's line):"
  echo "\$ $L_JAVAC"; rm -rf .harness/hc; (eval "$L_JAVAC") > .harness/javac.log 2>&1 < /dev/null || { cat .harness/javac.log >&3; die "the harness did not compile against the anchor's jars"; }
  echo "  exit 0 · what javac printed: $(wc -l < .harness/javac.log | tr -d ' ') lines · its classes: $(cd .harness/hc && find . -name '*.class' | sed 's#^\./##' | sort | paste -sd' ' -)"
  echo "whose classes - each read off the one jar on that class path that holds it (unzip -l, by name):"
  for c in org/springframework/web/client/RestClient org/springframework/http/client/JdkClientHttpRequestFactory org/springframework/boot/restclient/autoconfigure/RestClientAutoConfiguration org/springframework/boot/restclient/RestTemplateBuilder org/springframework/boot/http/client/JdkClientHttpRequestFactoryBuilder org/springframework/boot/http/client/HttpClientSettings; do
    echo "  ${c##*/} · in: $(for j in "$LIBD"/*.jar .harness/xlib/*.jar; do unzip -l "$j" "$c.class" > /dev/null 2>&1 && echo "${j##*/}"; done | paste -sd' ' -)"; done
  echo "the seven - the anchor, the README's run line (its locale pinned), port 19540, a fresh JVM:"
  start "$(at .harness/anchor 19540 "$R_RUN")"; up 19540; ready 19540; seven 19540 .harness/anchor; WARNS; logl 0 WARN
  echo "the seven - the anchor on its class path, the two jars and the harness joined (Calls, CallRoutes; no cases), port 19541, a fresh JVM:"
  start "$(hcp .harness/anchor 19541 probe.web.Calls,probe.web.CallRoutes)"; up 19541; ready 19541; seven 19541 .harness/anchor; WARNS; logl 0 WARN
  echo "the lines that moved - the README's run line's seven against the harness line's, masked, line for line:"
  python3 - .harness/seven-19540.txt .harness/seven-19541.txt <<'PY'
import sys
a = open(sys.argv[1], encoding="utf-8").read().splitlines(); b = open(sys.argv[2], encoding="utf-8").read().splitlines()
d = [i for i in range(max(len(a), len(b))) if i >= len(a) or i >= len(b) or a[i] != b[i]]
s = [i for i in range(min(len(a), len(b))) if a[i] == b[i]]
print("  lines that differ: %d%s · the same, byte for byte: %d (%s)" % (len(d), (" (" + " ".join(str(i + 1) for i in d) + ")") if d else "", len(s), " ".join(str(i + 1) for i in s)))
PY
  echo "the client's beans - the same line, the cases beans and factory, port 19542, a fresh JVM (no stub: neither case calls one):"
  start "$(hcp .harness/anchor 19542 probe.web.Calls "--probe.cases=beans,factory")"; up 19542; ready 19542; loc; calls
  WARNS; stop 19542 .harness/anchor; }

# ---- same: Core Java II's job, through Spring's RestClient ------------------------------------------------------------------------
same() { local n0 s0 h1 h2
  echo "the files - this unit's www/ against Core Java II's (this unit's line):"
  echo "\$ $L_MD5"; (eval "$L_MD5") 2>&1 < /dev/null | sed 's/^/  /'
  echo "  the same md5, file by file: $(for w in $WWW; do [ "$(md5 -q "harness/stub/www/$w")" = "$(md5 -q "$C2/www/$w")" ] && echo x; done | grep -c . || true) of 5 · customers.json: $(wc -c < harness/stub/www/customers.json | tr -d ' ') bytes"
  echo "the stub - this unit's line, from this folder, port 19546:"
  sstart
  echo "the job - the anchor on its class path, the two jars and the harness joined (Calls), the cases factory and same, port 19540, a fresh JVM:"
  s0=$(smark); start "$(hcp .harness/anchor 19540 probe.web.Calls "--probe.cases=factory,same")"; up 19540; ready 19540; loc; calls
  echo "what the client sent, and what the stub answered - the stub's dump of the job's requests:"
  sdump "$s0"
  echo "  the request for customers.json: Accept headers: $(awk '/^STUB GET \/customers\.json /{f=1;next} /^STUB-ANSWER/{f=0} f && /^STUB-H accept: /' .harness/stub.out | grep -c . || true) · accept-encoding values: $(awk '/^STUB GET \/customers\.json /{f=1;next} /^STUB-ANSWER/{f=0} f && /^STUB-H accept-encoding: /{sub(/^STUB-H accept-encoding: /, ""); print}' .harness/stub.out | paste -sd' ' -) · the same headers as meera.json's, by name: $( [ "$(awk '/^STUB GET \/customers\.json /' .harness/stub.out | sed 's/^.* headers=//')" = "$(awk '/^STUB GET \/meera\.json /' .harness/stub.out | sed 's/^.* headers=//')" ] && echo yes || echo no)"
  echo "the HTTP2-Settings value - Core Java II's README (this unit's line), against the stub's dump:"
  echo "\$ $L_H2"; (eval "$L_H2") 2>&1 < /dev/null | sed 's/^/  /'
  h1=$(eval "$L_H2" | sed -n '1s/^HTTP2-Settings: //p'); h2=$(awk '/^STUB GET \/customers\.json /{f=1;next} /^STUB-ANSWER/{f=0} f && /^STUB-H http2-settings: /{sub(/^STUB-H http2-settings: /, ""); print}' .harness/stub.out)
  echo "  Core Java II's: ${#h1} characters · the stub saw: ${#h2} characters · equal: $( [ -n "$h1" ] && [ "$h1" = "$h2" ] && echo yes || echo no)"
  WARNS; stop 19540 .harness/anchor
  sstop; }

# ---- status: the four-oh-four, and the statuses around it -------------------------------------------------------------------------
status() { local s0
  echo "the stub - this unit's line, port 19546:"
  sstart
  echo "the statuses - the anchor on its class path, the two jars and the harness joined (Calls), five cases, port 19541, a fresh JVM:"
  s0=$(smark); start "$(hcp .harness/anchor 19541 probe.web.Calls "--probe.cases=404,exchange,onstatus,default,5xx")"; up 19541; ready 19541; loc; calls
  echo "  the stub's dump since, one line a request (its headers counted - same prints them whole):"; sreqs "$s0"
  WARNS; stop 19541 .harness/anchor
  echo "C (labelled) - one injected builder configured, then built twice, never cloned (the case leak), port 19542, a fresh JVM:"
  s0=$(smark); start "$(hcp .harness/anchor 19542 probe.web.Calls "--probe.cases=leak")"; up 19542; ready 19542; loc; calls
  echo "  the stub's dump since, one line a request:"; sreqs "$s0"
  WARNS; stop 19542 .harness/anchor
  sstop; }

# ---- timeouts: the key's spelling, A/B/A'; C and D labelled -----------------------------------------------------------------------
trun() { start "$(hcp .harness/anchor "$1" probe.web.Calls "--probe.cases=slow${2:+ $2}")"; up "$1"; ready "$1"; loc; calls; WARNS; stop "$1" .harness/anchor; }
timeouts() { local s0
  echo "the keys - what Boot's own metadata declares (in spring-boot-http-client-4.1.1.jar, one of the two jars the starter adds; this unit's lines):"
  echo "\$ $L_KEYS"; (eval "$L_KEYS") 2>&1 < /dev/null | sed 's/^/  /'
  echo "\$ $L_META"; (eval "$L_META") 2>&1 < /dev/null | sed 's/^/  /'
  echo "the stub - this unit's line, port 19546 (its /slow?ms=3000 answers after three seconds):"
  sstart; s0=$(smark)
  echo "A - the anchor on its class path, the two jars and the harness joined (Calls, the case slow), the read timeout at one second, port 19543, a fresh JVM:"
  trun 19543 "$O_A"
  echo "B - the same, the key in Boot 3's spelling (the singular), port 19544, a fresh JVM:"
  trun 19544 "$O_B"
  echo "A' - A again, port 19543, a fresh JVM:"
  trun 19543 "$O_A"
  echo "A' against A, its label aside, line for line the same: $(asame "A - " "B - " "A' - " "A' against A")"
  echo "C (labelled) - the connect timeout alone, at one second, port 19544, a fresh JVM:"
  trun 19544 "$O_C"
  echo "D (labelled) - no timeout key at all, port 19543, a fresh JVM:"
  trun 19543 ""
  echo "the requests the stub saw, one line a request:"; sonly "$s0"
  sstop; }

# ---- defaults: what Boot's builder decides - a redirect, an observation -----------------------------------------------------------
defaults() { local s0
  echo "the stub - this unit's line, port 19546 (its /redirect answers 302, Location: /ravi.json):"
  sstart
  echo "both ways in one JVM - the anchor on its class path, the two jars and the harness joined (Calls), the cases redirect and metrics, port 19540, a fresh JVM:"
  s0=$(smark); start "$(hcp .harness/anchor 19540 probe.web.Calls "--probe.cases=redirect,metrics")"; up 19540; ready 19540; loc; calls
  echo "  the stub's dump since, one line a request:"; sreqs "$s0"
  echo "what was observed - one scrape of the same JVM's /actuator/prometheus (this unit's line):"
  rm -f .harness/prom.txt; local p; p=$(url "$L_PROM" 19540); echo "\$ $p"; (eval "$p") 2>&1 < /dev/null | sed 's/^/  /'; promf .harness/prom.txt
  WARNS; stop 19540 .harness/anchor
  echo "C (labelled) - the redirects key at dont-follow (this unit's line, as an option), the case redirect, port 19541, a fresh JVM:"
  s0=$(smark); start "$(hcp .harness/anchor 19541 probe.web.Calls "--probe.cases=redirect $O_R")"; up 19541; ready 19541; loc; calls
  echo "  the stub's dump since, one line a request:"; sreqs "$s0"
  WARNS; stop 19541 .harness/anchor
  sstop; }

# ---- failure: when the other side fails ------------------------------------------------------------------------------------------
failure() { local s0 n0 p e
  echo "the stub - this unit's line, port 19546:"
  sstart
  echo "  19549, where no stub runs: listening $(listeners 19549) (lsof, by port)"
  echo "a route that calls the stub - the anchor on its class path, the two jars and the harness joined (Calls, CallRoutes), the case down, port 19542, a fresh JVM:"
  start "$(hcp .harness/anchor 19542 probe.web.Calls,probe.web.CallRoutes "--probe.cases=down")"; up 19542; ready 19542; loc; rloc; calls
  for p in /status/500 /week-9.json /ravi.json; do
    n0=$(mark); s0=$(smark); e=0; local c; c=$(rq 19542 "$p"); echo "\$ $c"; (eval "$c") > .harness/rq.out 2>&1 < /dev/null || e=$?
    echo "  TiffinBox's answer, curl's exit code $e$(counted "$n0"):"; pagef < .harness/rq.out
    echo "  the stub's answer, from its dump:"; sreqs "$s0"
    recs "$n0"; done
  WARNS; stop 19542 .harness/anchor
  sstop; }

block() { awk '/^```bash$/ { if (!d) { f = 1 }; next } f && /^```$/ { f = 0; d = 1 } f' "$1"; }
# The shell a viewer has: env -i - nothing this script set reaches it (its JAVA_HOME, the JDK at the front of its PATH, LC_ALL,
# no_proxy, CURL_HOME) - with HOME and the PATH you started this script with; /bin/bash without profile or rc files, started in this
# folder. A driver in .harness/ runs the README's block, then SOLUTION.md's, as a viewer pastes them - each with its output, its exit
# code and the folder it left the shell in kept apart (absolute paths: a command that moved the shell must not move these files),
# and the README's run log and the stub's kept before the solution's run writes its own. Bounded (600 s); on the way out, or past the
# bound, the shell and every process under it are stopped (killtree).
# where DIR: the folder the shell was left in - this unit's folder, a folder under it (named), or elsewhere
where() { case "$1" in "$U") echo "this unit's folder" ;; "$U"/*) echo "${1#"$U"/}" ;; *) echo "outside this unit's folder" ;; esac; }
exercise() { local setup sol i=0 e1 d1 e2 d2 l1 l2
  setup=$(block exercise/README.md); sol=$(block exercise/solution/SOLUTION.md)
  [ -n "$setup" ] && [ -n "$sol" ] || die "exercise/README.md or SOLUTION.md no longer gives its commands"
  [ "$(printf '%s\n' "$sol" | grep -c .)" = 4 ] || die "SOLUTION.md's first bash block must be the README's two export lines, the solution's one line and the README's last line"
  [ "$(printf '%s\n' "$sol" | sed -n 1,2p)" = "$(printf '%s\n' "$setup" | sed -n 1,2p)" ] || die "SOLUTION.md must start with the README's two export lines (a new shell's java may be another JDK)"
  printf '%s\n' "$sol" | sed -n 1p | grep -qxF 'export JAVA_HOME=/opt/homebrew/opt/openjdk@25' || die "SOLUTION.md's first line must export this script's JAVA_HOME"
  printf '%s\n' "$sol" | sed -n 3p | grep -qxF 'T=--spring.http.clients.read-timeout=1s' || die "SOLUTION.md's third line must spell the key as Boot 4.1 reads it: T=--spring.http.clients.read-timeout=1s"
  printf '%s\n' "$setup" | grep -qxF "T=--${K1}read-timeout=1s" || die "exercise/README.md must give the client Boot 3's spelling of the key"
  l1=$(printf '%s\n' "$setup" | tail -1); l2=$(printf '%s\n' "$sol" | sed -n 4p)
  [ "$l1" = "$l2" ] || die "SOLUTION.md's last line must be the README's last line, unchanged: the fix is the key, not the command"
  rm -f .harness/ex-*
  printf '%s\n' "$setup" > .harness/ex-readme.sh; printf '%s\n' "$sol" > .harness/ex-sol.sh
  cat > .harness/ex-drive.sh <<'DRV'
cd "$1" || exit 1
. "$1/.harness/ex-readme.sh" > "$1/.harness/ex-readme.out" 2>&1 < /dev/null
echo "$? $PWD" > "$1/.harness/ex-readme.st"
cp "$1/.harness/mine/run.log" "$1/.harness/ex-readme.log" 2> /dev/null
cp "$1/.harness/mine/stub.log" "$1/.harness/ex-readme.stub" 2> /dev/null
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
  echo "  the shell is now in: $(where "$d1") · the JVM's locale in its log: $(grep -m1 "^ROUTE the JVM's locale: " .harness/ex-readme.log | sed "s/^.*locale: //") (CallRoutes), in the stub's: $(grep -m1 "^STUB the JVM's locale: " .harness/ex-readme.stub | sed "s/^.*locale: //") · the copy's own token in its log: $(raw "$(head -1 .harness/mine/anchor/$TF)" .harness/ex-readme.log) times, in the stub's dump: $(raw "$(head -1 .harness/mine/anchor/$TF)" .harness/ex-readme.stub) times · WARN lines in its log: $(lvl WARN .harness/ex-readme.log) · ERROR lines: $(lvl ERROR .harness/ex-readme.log) · listening on 19544 now: $(listeners 19544) · on 19546: $(listeners 19546)"
  echo "the solution's $(printf '%s\n' "$sol" | grep -c .) lines, next, in the same shell:"
  printf '%s\n' "$sol" | sed 's/^/  $ /'
  echo "  exit $e2 · what they printed:"; sed 's/^/    /' .harness/ex-sol.out
  echo "  the shell is now in: $(where "$d2") · the JVM's locale in its log: $(grep -m1 "^ROUTE the JVM's locale: " .harness/mine/run.log | sed "s/^.*locale: //") (CallRoutes), in the stub's: $(grep -m1 "^STUB the JVM's locale: " .harness/mine/stub.log | sed "s/^.*locale: //") · the copy's own token in its log: $(raw "$(head -1 .harness/mine/anchor/$TF)" .harness/mine/run.log) times, in the stub's dump: $(raw "$(head -1 .harness/mine/anchor/$TF)" .harness/mine/stub.log) times · WARN lines in its log: $(lvl WARN .harness/mine/run.log) · ERROR lines: $(lvl ERROR .harness/mine/run.log) · listening on 19544 now: $(listeners 19544) · on 19546: $(listeners 19546)"
  echo "  the solution's ERROR record in its log (.harness/mine/run.log), from its logger on:"
  cp .harness/mine/run.log .harness/run.out; recs 0; }

cap change change
cap same same
cap status status
cap timeouts timeouts
cap defaults defaults
cap failure failure
cap exercise exercise
echo
# ---- every number the video says, asserted. Each check reads a line a program computed - never a label this script prints
# ---- unconditionally - and names the words it pays for.
# blk NAME FROM TO: the capture's lines after the line that starts with FROM, up to the next line that starts with TO (to the end when
# TO is empty) - the labels handed to awk through its environment, which keeps a backslash a backslash (-v would turn \n into a newline)
blk() { A="$2" B="$3" awk 'index($0, ENVIRON["A"]) == 1 { f = 1; next } ENVIRON["B"] != "" && index($0, ENVIRON["B"]) == 1 { f = 0 } f' ".r-$1.out"; }
has() { printf '%s\n' "$1" | grep -qxF -- "$2" || die "$3: expected the line: $2"; }
nhas() { ! printf '%s\n' "$1" | grep -qxF -- "$2" || die "$3: did not expect the line: $2"; }
cnt() { printf '%s\n' "$1" | grep -cxF -- "$2" || true; }
# THE TOKEN: no capture holds it, raw - counted on each run's own output BEFORE masking - and neither does any log (each counted when
# it was read: logtok()), nor any stub dump (sstop()), nor anything this unit ships for reading
for f in .harness/raw-*; do [ "$(cat "$f")" = "0" ] || die "a capture's raw output held the token ($f: $(cat "$f"))"; done
SHIP="README.md exercise/README.md exercise/solution/SOLUTION.md receipts.md5 harness/pom.xml harness/stub/Stub.java harness/shutdown.sh harness/keys.py harness/meta.py $HWS"
for f in .r-*.out $SHIP; do [ "$(raw "$TOKEN" "$f")" = 0 ] || die "$f holds the demo token, raw"; done
for f in .r-*.out; do ! grep -qE '/Users/|/private/|/home/|/var/folders/' "$f" || die "$f holds an absolute path"; ! grep -qE 'c[0-9]-unit[0-9]|unit ?[0-9]' "$f" || die "$f holds a unit number"; ! grep -qE ' (with PID|started by) ' "$f" || die "$f holds Boot's process line"; ! grep -qE '^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T|"timestamp":"?[0-9]|(exec|handler|task|omcat-handler)-[0-9]' "$f" || die "$f holds a log time, a timestamp or a thread number"; ! grep -qE 'Java-http-client/[0-9]|Java/[0-9]+\.[0-9]| using Java [0-9]|Macintosh|Mac OS X|Windows NT|X11;|Linux x86' "$f" || die "$f holds a JDK version (a client's, or Boot's first line's) or a platform (R.128, R.136)"; ! grep -qE ':8080|:35729|:18425/' "$f" || die "$f names 8080, 35729 or 18425"; ! grep -q "$(printf '\r')" "$f" || die "$f holds a carriage return"; ! grep -qE '[0-9]+ ?ms\b|[0-9]+\.[0-9]+ ?s(econds)?\b|Started .* in ' "$f" || die "$f holds a duration (R.121, R.139)"; ! grep -qE '^\s+at [a-z]' "$f" || die "$f holds a stack frame"; done
# S3.9 (R.105): no wait in this script, its checks or the exercise is bare - each names its pid ($! or a variable)
for f in receipts.sh exercise/README.md exercise/solution/SOLUTION.md; do ! grep -nE '(^|[;&|({] *)wait *($|[;&|)}])' "$f" | grep -vE '^[0-9]+: *#' > /dev/null || die "$f has a bare wait (S3.9)"; done
# R.79/S1.3: nothing is stopped by name - no pkill, no killall
PK='p''kill|kill''all'
for f in receipts.sh exercise/README.md exercise/solution/SOLUTION.md; do ! grep -nE "\\b($PK)\\b" "$f" | grep -vE '^[0-9]+: *#' > /dev/null || die "$f stops a process by name"; done
# R.96: no running step piped into head
! grep -nE '(eval|receipts\.sh|java |mvn ).*\| *head' receipts.sh | grep -vE '^[0-9]+: *#' | grep -vF 'JAVA_HOME gives: $(java -version 2>&1 | head -1)' > /dev/null || die "receipts.sh pipes a running step into head (R.96)"
for f in receipts.sh README.md exercise/README.md exercise/solution/SOLUTION.md $HWS; do ! grep -qE "exposure\.include='?\*" "$f" || die "$f exposes every endpoint (R.42)"; done
# R.99: Boot 4.1 reads only spring.web.error.* - no file of this unit names one of Boot 3's error keys (split here, so this line does
# not spell it)
K3='server'; K3="$K3.error."
for f in receipts.sh $SHIP; do ! grep -qF "$K3" "$f" || die "$f names one of Boot 3's error keys (R.99)"; done
# R.138: Boot 3's spelling of the client keys (the singular one) only in the labelled break B and the exercise's broken README: never in
# this script (built above, never written), the solution, the harness or the stub; in README.md only on B's lines, the metadata
# line, the timeouts capture and the exercise's sections
for f in receipts.sh exercise/solution/SOLUTION.md harness/pom.xml harness/stub/Stub.java harness/meta.py harness/keys.py harness/shutdown.sh $HWS; do ! grep -qF "$K1" "$f" || die "$f spells Boot 3's client key (R.138)"; done
[ "$(grep -cF "$K1" exercise/README.md)" -ge 1 ] || die "exercise/README.md must ship Boot 3's spelling: it is the exercise"
BADK=$(awk -v k="$K1" '/^## / { s = $0 } index($0, k) && s !~ /^## (The commands this unit adds|4 · timeouts|7 · exercise|Exercise|LINES OVERTURNED)/ { print NR }' README.md | paste -sd' ' -)
[ -z "$BADK" ] || die "README.md spells Boot 3's client key outside the commands, the timeouts and the exercise (lines $BADK; R.138)"
# R.114 (S3.18): no harness class reaches the anchor - its tree names none of them (as whole words)
for c in Calls CallRoutes probe.web Stub; do ! grep -rqwF "$c" anchor/tiffinbox-web/src anchor/tiffinbox-core/src || die "the anchor's sources name $c (a whole word) - the harness is shown on the harness, never in the anchor"; done
# no capture runs a command with a URL that is not 127.0.0.1's; the stub binds the loopback address
for f in .r-*.out; do ! grep -E '^ *\$ ' "$f" | grep -oE 'https?://[^ '"'"']+' | grep -vE '^http://127\.0\.0\.1:' > /dev/null || die "$f runs a command with a URL that is not 127.0.0.1's"; done
grep -qF 'new InetSocketAddress(InetAddress.getLoopbackAddress(), port)' harness/stub/Stub.java || die "the stub must bind the loopback address"
for f in $HWS harness/stub/Stub.java exercise/README.md; do ! grep -qE 'https?://localhost|localhost:' "$f" || die "$f names localhost - every URL is 127.0.0.1's (R.82)"; done
# S4.1: every java line a capture starts pins the JVM's locale (the extract line prints nothing a locale changes) - the stub's too
for f in .r-*.out; do ! grep -E '^ *\$ (cd [^ ]+ && )?(exec )?java ' "$f" | grep -vF -- "java $JL " | grep -vF -- 'java -Djarmode=tools ' > /dev/null || die "$f starts a JVM without its locale pinned (S4.1)"; done
for f in exercise/README.md exercise/solution/SOLUTION.md; do ! grep -oE '\{ java [^>]*' "$f" | grep -vF -- "{ java $JL " > /dev/null || die "$f: the exercise's java lines must pin the JVM's locale (S4.1)"; done
[ "$(grep -oE '\{ java [^>]*' exercise/README.md | grep -c .)" = 2 ] || die "exercise/README.md must start two JVMs (the stub, TiffinBox), each in a subshell job"
# httpclient5 never joins (S5.3): not on the harness's class path, not in the anchor's lib/
! grep -qF httpclient5 .harness/harness.cp && [ -z "$(ls "$LIBD" | grep '^httpclient5-' || true)" ] || die "httpclient5 is on the class path - every factory sentence would change"
# R.115: no browser is used here - the exercise names one only to say none is needed
[ "$(grep -oi 'browser' exercise/README.md | wc -l | tr -d ' ')" = 1 ] && grep -i 'browser' exercise/README.md | grep -qF 'browser are needed' && [ "$(grep -oi 'browser' exercise/solution/SOLUTION.md | wc -l | tr -d ' ')" = 0 ] || die "the exercise speaks of a browser (R.115) - none is used"
# the stub is Core Java II's files and nothing else in www/, and its copy is this folder's (the next lessons compare theirs to it)
for w in $WWW; do cmp -s "harness/stub/www/$w" "$C2/www/$w" || die "harness/stub/www/$w is not Core Java II's, byte for byte"; done
NL=$(cat .r-*.out | grep -cE "^  its log: the demo token 0 times · X-Shutdown-Token 0 times\$" || true)
ND=$(cat .r-*.out | grep -cE "· the demo token 0 times · X-Shutdown-Token 0 times\$" || true)
echo "  tokens: 0 raw copies in $(ls .harness/raw-* | wc -l | tr -d ' ') raw capture runs, in $(ls .r-*.out | wc -l | tr -d ' ') captures; the demo token 0 in the logs of every JVM that served ($LOGS here; the published captures' $NL) and in every stub dump ($DUMPS here; the published captures' $ND), the READMEs, the harness, the stub and receipts.md5; no absolute path, no unit number, no process line, no log time, no timestamp, no thread number, no client JDK version, no platform, no duration, no stack frame, no URL but 127.0.0.1's; every JVM's locale pinned; Boot 3's client key only where it is the lesson"

S466='466c20ed7e0d5439cb052f32ce09de1b'
LOC="  the JVM's locale (the harness's Calls): en_US"
SL="  the stub listens on: 127.0.0.1:19546 · loopback only: yes · its locale: en_US"
DONE="    done"
UA0=$(cat .harness/ua.txt 2> /dev/null || true)

# "the starter adds two jars ... sixty-one ... the beans: a builder bean, a new one for each place that asks ... a request factory
# builder: the JDK's ... no RestClient bean, no RestTemplate bean" - change
CO=$(cat .r-change.out)
has "$CO" '  built the anchor · offline: yes · exit 0' "change: the anchor built offline"
has "$CO" "  the anchor's libraries (its extracted lib/): 61 · Boot's RestClient module among them: 0 · httpclient5: 0" "change: 61 libraries, no RestClient module, no httpclient5"
has "$CO" "  built the harness POM's class path · offline: yes · exit 0" "change: the harness POM's class path, offline"
has "$CO" "  the jars it lists: 31 · in the anchor's lib/ already, by name (the version is in the name): 25 · not:" "change: 31 listed, 25 there"
for s in spring-boot-starter-restclient-4.1.1.jar spring-boot-starter-4.1.1.jar spring-boot-starter-logging-4.1.1.jar spring-boot-starter-jackson-4.1.1.jar; do
  has "$CO" "    $s · classes: 0 · not joined: no class - a starter is its POM's dependencies" "change: $s, no class"; done
has "$CO" "    spring-boot-restclient-4.1.1.jar · classes: 29 · joined (.harness/xlib)" "change: spring-boot-restclient joined"
has "$CO" "    spring-boot-http-client-4.1.1.jar · classes: 88 · joined (.harness/xlib)" "change: spring-boot-http-client joined"
[ "$(printf '%s\n' "$CO" | grep -c '^    .*\.jar · classes: ')" = 6 ] || die "change: six jars the anchor lacks"
has "$CO" "  the class path the harness runs on: the anchor's 61 libraries + 2 = 63" "change: 61 + 2 = 63"
has "$CO" "  exit 0 · what javac printed: 0 lines · its classes: probe/web/CallRoutes.class probe/web/Calls\$1.class probe/web/Calls\$MenuMissing.class probe/web/Calls.class probe/web/Row.class" "change: the harness compiled, no warning"
[ "$(cnt "$CO" "  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 0 · md5 $S466")" = 2 ] || die "change: the seven $S466 on both lines"
[ "$(cnt "$CO" '    WARN o.s.web.servlet.PageNotFound: Request method '"'"'GET'"'"' is not supported')" = 2 ] || die "change: the seven's one WARN, PageNotFound, on both lines"
has "$CO" '  lines that differ: 0 · the same, byte for byte: 7 (1 2 3 4 5 6 7)' "change: the same, byte for byte: 7"
has "$CO" "$LOC" "change: the locale"
for l in '    beans RestClient.Builder: restClientBuilder (scope prototype) -> org.springframework.web.client.DefaultRestClientBuilder' \
         '    beans RestTemplateBuilder: restTemplateBuilder (scope singleton) -> org.springframework.boot.restclient.RestTemplateBuilder' \
         '    beans ClientHttpRequestFactoryBuilder: clientHttpRequestFactoryBuilder (scope singleton) -> org.springframework.boot.http.client.JdkClientHttpRequestFactoryBuilder' \
         '    beans HttpClientSettings: httpClientSettings (scope singleton) -> org.springframework.boot.http.client.HttpClientSettings' \
         '    beans RestClient: no bean' '    beans RestTemplate: no bean' '    beans two injection points, one builder object: false' "$DONE"; do has "$CO" "$l" "change: $l"; done
for l in 'RestClient · in: spring-web-7.0.9.jar' 'JdkClientHttpRequestFactory · in: spring-web-7.0.9.jar' 'RestClientAutoConfiguration · in: spring-boot-restclient-4.1.1.jar' 'RestTemplateBuilder · in: spring-boot-restclient-4.1.1.jar' 'JdkClientHttpRequestFactoryBuilder · in: spring-boot-http-client-4.1.1.jar' 'HttpClientSettings · in: spring-boot-http-client-4.1.1.jar'; do has "$CO" "  $l" "change: the owner, $l"; done
for w in "Boot's builder bean" 'RestClient.create()' 'RestClient.builder()'; do has "$CO" "    factory $w: org.springframework.http.client.JdkClientHttpRequestFactory" "change: the factory, $w"; done
for l in "$(printf '%s\n' "$CO" | grep '^  WARN lines in this run' )"; do :; done
[ "$(printf '%s\n' "$CO" | grep -c "^  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0 · lines that say \"deprecat\": 0\$")" = 1 ] || die "change: the beans run 0/0"
echo "  change: 61 libraries; the starter's class path 31 jars, 25 in lib/, 6 not - 4 starters (0 classes), spring-boot-restclient (29) and spring-boot-http-client (88) joined: 63; the seven $S466 on both lines, the same, byte for byte: 7; restClientBuilder prototype, two injections two objects; restTemplateBuilder; JdkClientHttpRequestFactoryBuilder; httpClientSettings; no RestClient, no RestTemplate bean; the factory JdkClientHttpRequestFactory three ways"

# "the same five files ... the same JDK client underneath ... four records, twenty-four thousand three hundred ... it offers HTTP two
# the same way, the same settings string ... and sends no Accept header" - same
SO=$(cat .r-same.out)
has "$SO" "  the same md5, file by file: 5 of 5 · customers.json: 307 bytes" "same: Core Java II's five files, 307 bytes"
has "$SO" "$SL" "same: the stub, loopback, en_US"; has "$SO" "$LOC" "same: the locale"
for r in 'Ravi, mealsPerDay=2, pricePerMeal=120, veg=true] - a month: 7200' 'Meera, mealsPerDay=1, pricePerMeal=150, veg=true] - a month: 4500' 'Sunil, mealsPerDay=3, pricePerMeal=100, veg=false] - a month: 9000' 'Priya, mealsPerDay=1, pricePerMeal=120, veg=true] - a month: 3600'; do has "$SO" "    same Row[name=$r" "same: the row $r"; done
has "$SO" '    same rows: 4 - month total: 24300' "same: four rows, 24300"
[ $((2 * 120 * 30 + 150 * 30 + 3 * 100 * 30 + 120 * 30)) = 24300 ] || die "same: the month"
has "$SO" '    same one file, body(Row.class): Row[name=Meera, mealsPerDay=1, pricePerMeal=150, veg=true]' "same: one file, one record"
for w in "Boot's builder bean" 'RestClient.create()' 'RestClient.builder()'; do has "$SO" "    factory $w: org.springframework.http.client.JdkClientHttpRequestFactory" "same: the factory, $w"; done
for l in '    | STUB GET /customers.json headers=[Accept-encoding, Connection, Host, Http2-settings, Upgrade, User-agent]' '    | STUB-H accept-encoding: gzip' '    | STUB-H accept-encoding: deflate' '    | STUB-H connection: Upgrade, HTTP2-Settings' '    | STUB-H host: 127.0.0.1:19546' '    | STUB-H http2-settings: AAEAAEAAAAIAAAAAAAMAAAAAAAQBAAAAAAUAAEAAAAYABgAA' '    | STUB-H upgrade: h2c' '    | STUB-H user-agent: Java-http-client/<version>' '    | STUB-ANSWER 200 application/json 307 bytes' '    | STUB GET /meera.json headers=[Accept-encoding, Connection, Host, Http2-settings, Upgrade, User-agent]' '    | STUB-ANSWER 200 application/json 73 bytes'; do has "$SO" "$l" "same: the dump's line $l"; done
CJ=$(printf '%s\n' "$SO" | awk '/^    \| STUB GET \/customers\.json /{f=1} f{print} f && /^    \| STUB-ANSWER/{exit}')
[ "$CJ" = "$(printf '%s\n' '    | STUB GET /customers.json headers=[Accept-encoding, Connection, Host, Http2-settings, Upgrade, User-agent]' '    | STUB-H accept-encoding: gzip' '    | STUB-H accept-encoding: deflate' '    | STUB-H connection: Upgrade, HTTP2-Settings' '    | STUB-H host: 127.0.0.1:19546' '    | STUB-H http2-settings: AAEAAEAAAAIAAAAAAAMAAAAAAAQBAAAAAAUAAEAAAAYABgAA' '    | STUB-H upgrade: h2c' '    | STUB-H user-agent: Java-http-client/<version>' '    | STUB-ANSWER 200 application/json 307 bytes')" ] || die "same: the customers.json request, whole, line for line - got: $CJ"
has "$SO" "  the stub's dump since, whole: 18 lines" "same: the dump, 18 lines - two requests, seven headers and an answer each"
has "$SO" "  the request for customers.json: Accept headers: 0 · accept-encoding values: gzip deflate · the same headers as meera.json's, by name: yes" "same: no Accept; gzip and deflate"
has "$SO" '  HTTP2-Settings: AAEAAEAAAAIAAAAAAAMAAAAAAAQBAAAAAAUAAEAAAAYABgAA' "same: Core Java II's README's line"
has "$SO" "  Core Java II's: 48 characters · the stub saw: 48 characters · equal: yes" "same: the HTTP2-Settings value, equal"
has "$SO" "  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0 · lines that say \"deprecat\": 0" "same: 0/0"
has "$SO" "  the stub: stopped by its pid · exit 143 · listening on 19546 now: 0 · requests in its dump: 2 · the demo token 0 times · X-Shutdown-Token 0 times" "same: the stub's two requests, 0 tokens"
grep -qF 'jwebserver -p 8234 -d "$PWD/www"' "$C2/README.md" && grep -qF '`body bytes: 307`' "$C2/README.md" && grep -qF 'month total `24300`' "$C2/README.md" && grep -qF '`week-9.json: 404`' "$C2/README.md" || die "same: Core Java II's README no longer gives jwebserver, 307, 24300 or week-9.json's 404"
grep -qF 'connectTimeout(Duration.ofSeconds(2))' "$C2/ApiCall.java" && grep -qF '.timeout(Duration.ofSeconds(5))' "$C2/ApiCall.java" || die "same: Core Java II's two timeouts (2 s, 5 s) are not in its ApiCall.java"
case "$UA0" in Java-http-client/[0-9]*) ;; *) die "same: the stub saw no Java-http-client User-Agent" ;; esac
echo "  same: 5 of 5 md5 = Core Java II's, 307 bytes; the stub 127.0.0.1:19546 en_US; JdkClientHttpRequestFactory three ways; 4 rows, 24300; meera.json one record; customers.json's dump whole - accept-encoding gzip and deflate, Connection: Upgrade, HTTP2-Settings, upgrade h2c, HTTP2-Settings = Core Java II's (48 characters, equal), no Accept; 0 tokens in the stub's dump · the User-Agent, masked in every capture (terminal only): $UA0"

# "a four-oh-four ... throws: not found ... its message carries the stub's own body ... exchange gives you the status, and no exception
# ... onStatus ... a default status handler on a clone ... five hundred, five oh three ... C: the handler carried into the next client" - status
ST=$(cat .r-status.out); SA=$(blk status "the statuses - " "C (labelled)"); SC=$(blk status "C (labelled)" '')
has "$SA" "$LOC" "status: the locale"; has "$SC" "$LOC" "status C: the locale"; has "$ST" "$SL" "status: the stub"
has "$SA" '    404 org.springframework.web.client.HttpClientErrorException$NotFound - status 404 - message: 404 Not Found: "not found"' "status: the 404's exception"
has "$SA" '    404 its classes, up: NotFound > HttpClientErrorException > HttpStatusCodeException > RestClientResponseException > RestClientException > NestedRuntimeException - a RestClientException: true' "status: the classes up"
has "$SA" '    exchange /week-9.json -> 404 NOT_FOUND - no exception' "status: exchange, no exception"
has "$SA" '    onstatus probe.web.Calls$MenuMissing | message: no menu at /week-9.json, the stub said 404 | cause: none' "status: onStatus"
has "$SA" '    default /week-9.json probe.web.Calls$MenuMissing | message: the stub said 404 for /week-9.json | cause: none' "status: the default handler, 404"
has "$SA" '    default /status/500 probe.web.Calls$MenuMissing | message: the stub said 500 for /status/500 | cause: none' "status: the default handler, 500"
has "$SA" '    default a later client, another clone: org.springframework.web.client.HttpClientErrorException$NotFound' "status: a later clone, NotFound again"
has "$SA" '    5xx /status/500 org.springframework.web.client.HttpServerErrorException$InternalServerError - status 500 - message: 500 Internal Server Error: "{"status":500,"from":"stub"}"' "status: 500"
has "$SA" '    5xx /status/503 org.springframework.web.client.HttpServerErrorException$ServiceUnavailable - status 503 - message: 503 Service Unavailable: "{"status":503,"from":"stub"}"' "status: 503"
nhas "$SA" '    404 no exception' "status: the 404 threw"
has "$SA" '    GET /week-9.json · headers: 7 · the stub answered 404 text/plain 9 bytes' "status: the stub's 404"
[ "$(cnt "$SA" '    GET /week-9.json · headers: 7 · the stub answered 404 text/plain 9 bytes')" = 5 ] || die "status: five calls to week-9.json, each a 404"
has "$SC" '    leak the client it was configured for: probe.web.Calls$MenuMissing' "status C: the configured client"
has "$SC" '    leak a later client, the same builder: probe.web.Calls$MenuMissing' "status C: the later client carries the handler"
grep -qF 'second.baseUrl(stub).defaultStatusHandler(' harness/probe/web/Calls.java && grep -qF 'RestClient later = second.baseUrl(stub).build();' harness/probe/web/Calls.java && [ "$(grep -c 'first.clone()' harness/probe/web/Calls.java)" -ge 9 ] && ! grep -qE 'first\.(baseUrl|defaultStatusHandler|build)\(' harness/probe/web/Calls.java || die "status: every case but leak configures a clone of the builder; leak configures the injected one"
for b in "$SA" "$SC"; do has "$b" "  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0 · lines that say \"deprecat\": 0" "status: 0/0"; done
echo "  status: week-9.json -> HttpClientErrorException\$NotFound 404, message 404 Not Found: \"not found\" (the stub's body); up to RestClientException; exchange -> 404 NOT_FOUND, no exception; onStatus -> MenuMissing; the default handler on a clone -> MenuMissing for 404 and 500, a later clone NotFound; 500 InternalServerError, 503 ServiceUnavailable; C: the injected builder, configured, carries the handler into a later client; 0/0"

# "A, the plural key, one second: cancelled - request cancelled, not Core Java II's words ... B, Boot 3's spelling: the answer, after
# the stub's whole wait, and not one warning ... A again ... C, connect timeout alone: answered ... D, no key: answered" - timeouts
TO=$(cat .r-timeouts.out)
TA=$(blk timeouts "A - " "B - "); TB=$(blk timeouts "B - " "A' - "); TA2=$(blk timeouts "A' - " "A' against A"); TC=$(blk timeouts "C (labelled)" "D (labelled)"); TD=$(blk timeouts "D (labelled)" "the requests the stub saw")
has "$TO" '  spring.http.clients.connect-timeout · default none · Duration' "timeouts: connect-timeout, no default"
has "$TO" '  spring.http.clients.read-timeout · default none · Duration' "timeouts: read-timeout, no default"
has "$TO" '  spring.http.clients.redirects · default none · HttpRedirects' "timeouts: the redirects key"
has "$TO" '  7 keys under spring.http.clients.' "timeouts: seven keys"
has "$TO" "  ${K1}read-timeout · default none · Duration" "timeouts: Boot 3's key declared"
has "$TO" '    deprecated · since 4.0.0 · level: not given · replacement: spring.http.clients.read-timeout' "timeouts: deprecated since 4.0.0, the replacement"
CANC='    slow /slow?ms=3000 cancelled: org.springframework.web.client.ResourceAccessException | message: I/O error on GET request for "http://127.0.0.1:19546/slow": Request cancelled | cause: java.net.http.HttpTimeoutException: Request cancelled'
ANS='    slow /slow?ms=3000 answered: {"slow":true}'
Z3="  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0 · lines that say \"deprecat\": 0"
for b in "$TA" "$TA2"; do has "$b" "$CANC" "timeouts A: cancelled"; nhas "$b" "$ANS" "timeouts A: not answered"; done
for b in "$TB" "$TC" "$TD"; do has "$b" "$ANS" "timeouts B/C/D: answered"; nhas "$b" "$CANC" "timeouts B/C/D: not cancelled"; done
for b in "$TA" "$TB" "$TA2" "$TC" "$TD"; do has "$b" "$LOC" "timeouts: the locale"; has "$b" "$Z3" "timeouts: 0 WARN, 0 ERROR, 0 deprecat"; done
has "$TB" "\$ $(hcp .harness/anchor 19544 probe.web.Calls "--probe.cases=slow $O_B")" "timeouts B: its line"
has "$TA2" "\$ $(hcp .harness/anchor 19543 probe.web.Calls "--probe.cases=slow $O_A")" "timeouts A': its \$ line (R.16, S5.2)"
has "$TO" "A' against A, its label aside, line for line the same: yes" "timeouts: A' = A"
[ "$(cnt "$TO" '    GET /slow?ms=3000 · headers: 7')" = 5 ] || die "timeouts: five JVMs, one call each to the stub's slow answer"
grep -qF 'Thread.sleep(q != null && q.startsWith("ms=") ? Long.parseLong(q.substring(3)) : 3000);' harness/stub/Stub.java || die "timeouts: the stub's wait is ms=, 3000 unless named"
echo "  timeouts: metadata - 7 keys under spring.http.clients., read-timeout and connect-timeout no default; Boot 3's read-timeout deprecated since 4.0.0, replacement spring.http.clients.read-timeout; A 1s -> ResourceAccessException ... Request cancelled, cause HttpTimeoutException: Request cancelled; B (Boot 3's key) -> answered, 0 WARN, 0 deprecat; A' = A; C connect-timeout -> answered; D no key -> answered; never a clock"

# "Boot's builder follows the redirect - two hundred, Ravi's row; RestClient.create() hands you the three oh two ... the observations:
# the builder's calls under the template, create()'s nowhere ... C: the key at dont-follow - three oh two" - defaults
DO=$(cat .r-defaults.out); DA=$(blk defaults "both ways in one JVM" "C (labelled)"); DC=$(blk defaults "C (labelled)" '')
has "$DA" "    redirect Boot's builder: /redirect -> 200 { \"name\": \"Ravi\",  \"mealsPerDay\": 2, \"pricePerMeal\": 120, \"veg\": true  }" "defaults: the builder follows"
has "$DA" "    redirect RestClient.create(): /redirect -> 302 moved" "defaults: create() does not"
has "$DC" "    redirect Boot's builder: /redirect -> 302 moved" "defaults C: dont-follow"
has "$DC" "    redirect RestClient.create(): /redirect -> 302 moved" "defaults C: create() the same"
has "$DA" '    GET /ravi.json · headers: 7 · the stub answered 200 application/json 73 bytes' "defaults: the followed request"
[ "$(cnt "$DA" '    GET /redirect · headers: 7 · the stub answered 302 text/plain 5 bytes')" = 2 ] && [ "$(cnt "$DC" '    GET /redirect · headers: 7 · the stub answered 302 text/plain 5 bytes')" = 2 ] && [ "$(printf '%s\n' "$DC" | grep -c '    GET /ravi.json')" = 0 ] || die "defaults: two 302s each way; under dont-follow no request for ravi.json"
has "$DA" '    metrics Boot'"'"'s builder: 2 calls, uri template /{f} - RestClient.create(): 3 calls, uri template /{name}' "defaults: the metrics case"
[ "$(cnt "$DA" '    GET /ravi.json · headers: 7 · the stub answered 200 application/json 73 bytes')" = 3 ] && [ "$(cnt "$DA" '    GET /priya.json · headers: 7 · the stub answered 200 application/json 73 bytes')" = 3 ] || die "defaults: ravi.json 3 times (1 followed + 2), priya.json 3 times - every call reached the stub"
has "$DA" '    http_client_requests_seconds_count{client_name="127.0.0.1",error="none",exception="none",method="GET",outcome="SUCCESS",status="200",uri="/{f}"} 2' "defaults: the builder's two calls, uri /{f}"
has "$DA" '    http_client_requests_seconds_count{client_name="127.0.0.1",error="none",exception="none",method="GET",outcome="SUCCESS",status="200",uri="/redirect"} 1' "defaults: the builder's redirect, observed once"
[ "$(printf '%s\n' "$DA" | grep -c 'uri="/{name}"')" = 0 ] && [ "$(printf '%s\n' "$DA" | grep -c '^    http_client_requests_seconds_count')" = 2 ] || die "defaults: create()'s calls observed nowhere - 2 kept lines, none for /{name}"
has "$DA" '  kept: 2 of the scrape'"'"'s lines, by the filter ^http_client_requests_seconds_count, sorted · the others not shown: over 150 (their number moves from run to run: the JVM'"'"'s own meters)' "defaults: kept 2"
for b in "$DA" "$DC"; do has "$b" "$LOC" "defaults: the locale"; has "$b" "$Z3" "defaults: 0/0"; done
echo "  defaults: /redirect - Boot's builder 200 Ravi's row, RestClient.create() 302; one scrape: uri=\"/{f}\" 2 (the builder), uri=\"/redirect\" 1, nothing for create()'s /{name} (3 calls the stub saw); C dont-follow -> 302 both"

# "the route's answer is TiffinBox's five hundred, Boot's four keys ... the stub's four-oh-four is TiffinBox's five hundred too ...
# one ERROR each, Tomcat's ... the stub's own words inside it ... the stub down: an exception with no message" - failure
FO=$(cat .r-failure.out)
has "$FO" '  19549, where no stub runs: listening 0 (lsof, by port)' "failure: 19549 free"
has "$FO" '    down org.springframework.web.client.ResourceAccessException | message: I/O error on GET request for "http://127.0.0.1:19549/customers.json": null | cause: java.net.ConnectException: null' "failure: the stub down"
F5=$(blk failure "\$ $(rq 19542 /status/500)" "\$ $(rq 19542 /week-9.json)"); F4=$(blk failure "\$ $(rq 19542 /week-9.json)" "\$ $(rq 19542 /ravi.json)"); F2=$(blk failure "\$ $(rq 19542 /ravi.json)" "  WARN lines in this run")
FJ='  {"timestamp":"…","status":500,"error":"Internal Server Error","path":"/probe/remote"} 500 · Content-Type: [application/json]'
for b in "$F5" "$F4"; do has "$b" "  TiffinBox's answer, curl's exit code 0 · WARN lines it added: 0 · ERROR lines: 1:" "failure: one ERROR"; has "$b" "$FJ" "failure: TiffinBox's 500, four keys"; done
has "$F5" '    GET /status/500 · headers: 7 · the stub answered 500 application/json 28 bytes' "failure: the stub's 500"
has "$F4" '    GET /week-9.json · headers: 7 · the stub answered 404 text/plain 9 bytes' "failure: the stub's 404"
has "$F5" '    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: Servlet.service() for servlet [dispatcherServlet] in context with path [] threw exception [Request processing failed: org.springframework.web.client.HttpServerErrorException$InternalServerError: 500 Internal Server Error: "{"status":500,"from":"stub"}"] with root cause' "failure: Tomcat's ERROR, the stub's body in it"
has "$F4" '    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: Servlet.service() for servlet [dispatcherServlet] in context with path [] threw exception [Request processing failed: org.springframework.web.client.HttpClientErrorException$NotFound: 404 Not Found: "not found"] with root cause' "failure: Tomcat's ERROR for the 404"
has "$F2" "  TiffinBox's answer, curl's exit code 0 · WARN lines it added: 0 · ERROR lines: 0:" "failure: the control, 0/0"
has "$F2" '   200 · Content-Type: [text/plain;charset=UTF-8]' "failure: the control, 200"
has "$F2" '    GET /ravi.json · headers: 7 · the stub answered 200 application/json 73 bytes' "failure: the control's stub answer"
has "$FO" "  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 2 · lines that say \"deprecat\": 0" "failure: the run, 2 ERROR"
has "$FO" "$LOC" "failure: the locale"; has "$FO" "  the JVM's locale (the harness's CallRoutes): en_US" "failure: the route's locale"
has "$FO" "  the stub: stopped by its pid · exit 143 · listening on 19546 now: 0 · requests in its dump: 3 · the demo token 0 times · X-Shutdown-Token 0 times" "failure: 3 requests reached the stub, 0 tokens"
echo "  failure: 19549 free -> ResourceAccessException ... : null, cause java.net.ConnectException: null; the stub's 500 and its 404 -> TiffinBox's 500 (timestamp, status, error, path), 1 ERROR each, Tomcat's [dispatcherServlet], the stub's body in the 500's; ravi.json -> 200 text/plain, 0/0; 0 tokens in the stub's dump"

# the exercise's files as shipped (read again here, so a check that the exercise capture makes cannot be skipped): SOLUTION.md is the
# README's two exports, the plural key and the README's last line, unchanged; the README ships Boot 3's spelling
XR=$(block exercise/README.md); XL=$(block exercise/solution/SOLUTION.md)
[ "$(printf '%s\n' "$XL" | grep -c .)" = 4 ] && [ "$(printf '%s\n' "$XL" | sed -n 1,2p)" = "$(printf '%s\n' "$XR" | sed -n 1,2p)" ] && [ "$(printf '%s\n' "$XL" | sed -n 3p)" = 'T=--spring.http.clients.read-timeout=1s' ] && [ "$(printf '%s\n' "$XL" | sed -n 4p)" = "$(printf '%s\n' "$XR" | tail -1)" ] && printf '%s\n' "$XR" | grep -qxF "T=--${K1}read-timeout=1s" || die "exercise: SOLUTION.md must be the README's two exports, T=--spring.http.clients.read-timeout=1s and the README's last line; the README must ship Boot 3's key"
# the exercise's end state: the README's commands, then the solution's, in ONE env -i shell - each leaves the shell in this folder
XS=$(blk exercise "the README's" "the solution's"); XE=$(blk exercise "the solution's" '')
l='the slow call: 500 · Request cancelled in its log: 1'; l0='the slow call: 200 · Request cancelled in its log: 0'
has "$XE" "    $l" "exercise: the solution"; has "$XS" "    $l0" "exercise: as shipped"
awk '/^\*\*Done\*\*/ { f = 1 } f' exercise/README.md | grep -qxF -- "$l" || die "exercise/README.md: Done names no such line"
grep -qxF -- "$l" exercise/solution/SOLUTION.md || die "SOLUTION.md: the measured run shows no such line"
grep -qF -- "\`$l0\`" exercise/README.md || die "exercise/README.md: the shipped line's answer is not named"
has "$XS" '  exit 0 · what they printed:' "exercise: the README's commands, exit 0"; has "$XE" '  exit 0 · what they printed:' "exercise: the solution's lines, exit 0"
has "$XS" "  the shell is now in: this unit's folder · the JVM's locale in its log: en_US (CallRoutes), in the stub's: en_US · the copy's own token in its log: 0 times, in the stub's dump: 0 times · WARN lines in its log: 0 · ERROR lines: 0 · listening on 19544 now: 0 · on 19546: 0" "exercise: as shipped, 0/0, nothing left"
has "$XE" "  the shell is now in: this unit's folder · the JVM's locale in its log: en_US (CallRoutes), in the stub's: en_US · the copy's own token in its log: 0 times, in the stub's dump: 0 times · WARN lines in its log: 0 · ERROR lines: 1 · listening on 19544 now: 0 · on 19546: 0" "exercise: the solution, 1 ERROR, nothing left"
has "$XE" '    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: Servlet.service() for servlet [dispatcherServlet] in context with path [] threw exception [Request processing failed: org.springframework.web.client.ResourceAccessException: I/O error on GET request for "http://127.0.0.1:19546/slow": Request cancelled] with root cause' "exercise: the solution's ERROR, Request cancelled"
[ "$(printf '%s\n' "$XE" | grep -c '^  \$ export ')" = 2 ] || die "exercise: SOLUTION.md gives the README's two export lines"
EXQ="Your turn: the README gives the client a one-second read timeout, yet the slow kitchen still makes it wait. Fix the key, and call again."
grep -qxF -- "**Your turn:** ${EXQ#Your turn: }" exercise/README.md || die "exercise/README.md: the spoken exercise line"
[ "$(printf '%s\n' "$EXQ" | wc -w | tr -d ' ')" -le 25 ] || die "exercise: the spoken line is over 25 words"
echo "  exercise: one env -i shell - the README as written (Boot 3's key) -> $l0; the solution (the plural key) -> $l; the shell in this unit's folder after each, 19544 and 19546 free"

[ -z "$unpub" ] || die "no published hash for:$unpub - check the captures, then copy the md5s above into receipts.md5 and run again"
echo "c6-unit25: every capture 3/3 and = published; every spoken number asserted; 0 raw demo tokens in every capture, every log and every stub dump"
