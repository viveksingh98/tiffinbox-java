#!/bin/bash
XPATH=$PATH                                           # the PATH you started this with: the exercise's own shell gets it
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25.0.4.1 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# Course 6 · RestTemplate: What You Will Meet in Old Code - this unit's receipts. No anchor change: anchor/ is the link to
# ../c6-unit24/after, the tree the sessions lesson froze (= c6-tiffinbox at Section 4's end). This script copies that tree under
# .harness/anchor, builds it and runs it - as its README runs it, and on its class path with the two jars Boot's RestClient starter
# adds (harness/pom.xml, read by Maven's dependency:build-classpath) and the course's harness joined (harness/probe/web, outside
# com.tiffinbox): RestTemplate - the client older Spring code calls out with - beside RestClient, and the line that moves a template's
# setup to RestClient. Every call goes to the stub - a small stand-in server on this computer (harness/stub/Stub.java, the RestClient
# lesson's, copied byte for byte: the JDK's own HTTP server, one source file) that prints every request whole.
# Six captures, each run three times and hashed; cap() DIES when a hash differs from receipts.md5; every number the video says is
# asserted at the bottom by a check that can fail; the demo token is masked (gsub), and the checks count 0 raw copies of it in every
# capture, in the log of every run, in the stub's dump of every run and in every file this unit ships.
#   status     the anchor built and extracted (61 libraries); the harness POM's class path - the jars the anchor's lib/ lacks, by
#              name, each with its class count, the two that hold classes joined; the harness compiled (deprecation warnings on);
#              the stub against the RestClient lesson's, md5 for md5; what the class files say about deprecation - RestTemplate and
#              every class nested in it, then Boot's RestTemplateBuilder (javap -v -p, harness/deps.py); the owners, read off the
#              jars; the seven on the jar, then on the harness line, the same, byte for byte; the client beans by name
#   side       the stub started, its bind read off its pid; the same 404 through a template and through RestClient, one row each way,
#              the template's message converters; the stub's dump of the six requests, whole, and their Accept headers, counted
#   factories  the request factory: A Boot's builder's template, B new RestTemplate(), A' = A - each a fresh JVM and a fresh stub: the
#              factory read off the template, one row, one redirect followed; the stub's dump, whole, and what it says, counted
#   migrate    a template with an interceptor (X-Via), then RestClient.create(template) and RestClient.builder(template), then
#              RestClient.create(): what each was built with, read off it, one row each; the stub's dump, whole, X-Via and Accept
#              counted; one scrape of /actuator/prometheus
#   who        which class files name RestTemplate (harness/who.py): every jar of the class path the harness runs on, TiffinBox's own
#              two among them; the two test modules' jars, read from .m2-demo (not on that class path); what the class files of the
#              classes it finds say about deprecation; TiffinBox's sources and the harness's, grepped for the word
#   exercise   exercise/README.md's commands, then exercise/solution/SOLUTION.md's, read from the files and run as written, one after
#              the other in ONE shell a viewer could have: env -i, /bin/bash, started in this folder
# "The anchor" is anchor/, the link to ../c6-unit24/after, COPIED under .harness/anchor; this script never writes into another unit's
# folder, and never builds a frozen tree in place. Every run of TiffinBox starts in .harness/anchor, which holds a config tree with a
# fake token (secrets/), as the README asks. Commands are printed exactly as they run: each goes through eval. "$CURLSET" is the
# comparison set since the secrets lesson (../c5-unit11/curlset.sh: the seven requests, POST /shutdown with the token's header read
# from the file). "$M2" is this unit's own repository, .m2-demo. "$S25" is the RestClient lesson's stub folder
# (../c6-unit25/harness/stub), read, never written. The harness - harness/probe/web: Templates (an ApplicationRunner: the cases
# --probe.cases names, one TPL line each), TemplateRoutes (GET /probe/old through a template, GET /probe/moved through the RestClient
# the call was moved to: the exercise's routes), Via (an interceptor that adds X-Via), Row (the RestClient lesson's record, byte for
# byte) - is the course's, never TiffinBox's: outside com.tiffinbox, joined by --spring.main.sources on the extracted jar's class path,
# and named on every capture that uses it; harness/pom.xml names Boot's RestClient starter for dependency:build-classpath (R.26);
# harness/stub/ is the RestClient lesson's stub, byte for byte; harness/deps.py reads a class's deprecation off its class files
# (javap); harness/who.py finds the class files that name a class; harness/shutdown.sh is POST /shutdown with the token read from its
# file (the filters lesson's, byte for byte). Every run passes options only. The seven run first, on a fresh JVM of the jar.
# The locale: the JVM ignores LC_ALL on macOS - it takes the Mac's first language - and Spring's, Jackson's and Tomcat's messages in
# the log and in the answers are written in the JVM's locale: so every JVM this script starts - TiffinBox and the stub - has its locale
# pinned on its run line (-Duser.language=en -Duser.country=US, right after java), every one prints it, and the checks assert en_US.
# The network: every Maven build runs offline (-o) against .m2-demo and says so ("offline: yes"); a build that cannot resolve an
# artifact offline goes to Maven Central once, and says that ("offline: no - ..."). No native build, no Docker and no browser: this
# unit measures the JVM alone, with curl and the stub. At run time nothing leaves 127.0.0.1: TiffinBox and the stub listen there,
# every request goes there, and Logback writes to the terminal only.
# Masks and filters (README.md declares each; awk sub/gsub only): the demo token becomes "[masked: the N-character token]" (N its
# own length); this folder's absolute path "…", the folder above it "…/..", the home folder "~"; your user name "<user>" - in every
# line of every capture. The JDK's version in a client's User-Agent - the JDK HttpClient's (Java-http-client/25.0.4.1) and
# HttpURLConnection's (Java/25.0.4.1) - becomes "<version>" (each printed once on the terminal, R.136). Spring's error timestamp
# becomes "…" (both forms) in the seven and wherever an answer is printed. A run's log lines are printed from their logger on (no
# time, no process id, no thread); Boot's first line is cut before " with PID". A WARN or ERROR record is printed as its level,
# logger and message, then the exception line under it; its stack frames are bounded ("over 40") and its other lines counted, never
# shown. The stub's dump is printed whole where a capture reads what a client sent (side, factories, migrate). A scrape of
# /actuator/prometheus is kept to ^http_client_requests_seconds_count, sorted, the kept lines counted. javap's output is read by
# harness/deps.py and never printed: its line count is. who.py lists the jars where a class file names the class, and TiffinBox's
# own, and counts the others. No duration is captured.
# Ports (brief ⚑1, 19560-19569): TiffinBox 19560-19564 (one JVM at a time), the stub 19566, 19569 never bound (asserted free); 19565,
# 19567, 19568 unused. Captures run one after another, each JVM and each stub stopped before the next starts. 18425 (TiffinBox's
# default), 8080 (Tomcat's) and 35729 (DevTools' Live Reload) are checked free too, and never bound.
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
# ignores a second Ctrl-C, and nothing in it can fail under set -e, so it always reaches the rmdir; the script still exits 130 after an
# interrupt (README.md, "Interrupted"). $pid, $spid and $xpid are cleared whenever their process has been reaped. sweep() kills only
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
for t in python3 curl rsync lsof unzip javac javap mvn cmp md5; do command -v $t > /dev/null || die "$t is needed"; done
# A variable of yours must not become a property source, a JVM flag or a build setting: every TIFFINBOX_*, SPRING_*, MANAGEMENT_*,
# SERVER_* and LOGGING_* variable, DEBUG (Boot reads it as --debug), the variables that inject JVM flags, MAVEN_OPTS, MAVEN_ARGS and
# NATIVE_IMAGE_OPTIONS are removed first (the last course's failure lesson's loop, verbatim: sed -E, a canary planted under every
# name first, and the run stops if one survives). This unit runs no Docker, so COMPOSE_* is not in the list. (A JAVA_TOOL_OPTIONS of
# yours could set every JVM's locale; a SPRING_HTTP_CLIENTS_* could change every client this unit builds from Boot's builders.)
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
TOKEN=demo-token-for-the-old-templates
[ ${#TOKEN} = 32 ] || die "the demo token must be 32 characters: the published captures name its length"
CURLSET=../c5-unit11/curlset.sh                      # the comparison set: the seven requests, POST /shutdown with the header
[ -f "$CURLSET" ] || die "$CURLSET is missing"
S25=../c6-unit25/harness/stub                        # the RestClient lesson's stub: read, never written
SMD5=42b656ddba1e9f80107495c65dacc975                # its Stub.java, as that lesson published it
WWW='customers.json meera.json priya.json ravi.json sunil.json'
HWS='harness/probe/web/Row.java harness/probe/web/TemplateRoutes.java harness/probe/web/Templates.java harness/probe/web/Via.java'
for f in harness/pom.xml harness/stub/Stub.java harness/shutdown.sh harness/deps.py harness/who.py $HWS exercise/README.md exercise/solution/SOLUTION.md README.md "$S25/Stub.java"; do [ -f "$f" ] || die "$f is missing"; done
[ "$(ls harness/probe/web | paste -sd' ' -)" = 'Row.java TemplateRoutes.java Templates.java Via.java' ] || die "harness/probe/web holds another file: javac compiles all of it"
[ "$(ls harness | paste -sd' ' -)" = 'deps.py pom.xml probe shutdown.sh stub who.py' ] || die "harness/ holds another file"
[ "$(ls harness/stub/www | paste -sd' ' -)" = "$WWW" ] && [ "$(ls "$S25/www" | paste -sd' ' -)" = "$WWW" ] || die "harness/stub/www must hold the RestClient lesson's five files, and nothing else"
[ "$(ls harness/stub | paste -sd' ' -)" = 'Stub.java www' ] || die "harness/stub holds another file"
[ "$(ls exercise/solution | paste -sd' ' -)" = 'SOLUTION.md' ] && [ "$(ls exercise | paste -sd' ' -)" = 'README.md solution' ] || die "exercise/ holds another file: the exercise is the README's commands, the solution one line"
[ ! -e harness/target ] || die "harness/target exists - dependency:build-classpath builds nothing; remove it"
# The stub is the RestClient lesson's, byte for byte - its md5 as that lesson published it (brief ⚑3: a read of a frozen folder)
[ "$(md5 -q harness/stub/Stub.java)" = "$SMD5" ] && [ "$(md5 -q "$S25/Stub.java")" = "$SMD5" ] || die "harness/stub/Stub.java must be the RestClient lesson's, md5 $SMD5"
for w in $WWW; do cmp -s "harness/stub/www/$w" "$S25/www/$w" || die "harness/stub/www/$w is not the RestClient lesson's, byte for byte"; done
cmp -s harness/shutdown.sh ../c6-unit18/harness/shutdown.sh || die "harness/shutdown.sh must be the filters lesson's, byte for byte"
cmp -s harness/probe/web/Row.java ../c6-unit25/harness/probe/web/Row.java || die "harness/probe/web/Row.java must be the RestClient lesson's, byte for byte"
# The exercise as shipped: the README copies the harness's sources and the viewer edits the copy (never harness/); the route ships the
# moved call as RestClient.create(), once - the exercise
grep -qxF 'mkdir -p .harness/mine/src && cp harness/probe/web/*.java .harness/mine/src/' exercise/README.md || die "exercise/README.md must copy the harness's sources to .harness/mine/src - the exercise edits the copy, never harness/"
[ "$(grep -c 'RestClient\.create()' harness/probe/web/TemplateRoutes.java)" = 1 ] && [ "$(grep -c 'RestClient\.create(template)' harness/probe/web/TemplateRoutes.java)" = 0 ] || die "harness/probe/web/TemplateRoutes.java must ship the moved call as RestClient.create(), once: it is the exercise"
# Boot 3's spelling of the client keys (the singular one) - built here, never written whole in this file: no file of this unit spells
# it (R.138)
K1='spring.http.client'; K1="$K1."

# The ports, BEFORE anything is wiped (a survivor of an interrupted run answers POST /shutdown only with its token, which lives in
# .harness/ - so the message names the process to kill).
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
for p in 18425 8080 35729 19560 19561 19562 19563 19564 19565 19566 19567 19568 19569; do
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
# This unit's own lines (README.md, "The commands this unit adds") - each asserted to be exactly that: the anchor's run and class-path
# lines with the JVM's locale pinned; the harness POM's class path; the two test modules' jars, fetched into .m2-demo; the harness's javac line; the stub's run line; md5 of the stub
# against the RestClient lesson's; the deprecation reader on RestTemplate and on Boot's builder; the class-file search on the class
# path the harness runs on and on the two test modules' jars; the deprecation reader on the classes that search finds; the source grep;
# the scrape saved to a file
mine() { grep -m1 -xF -- "$1" README.md > /dev/null || die "README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
JL='-Duser.language=en -Duser.country=US'
LIBD=.harness/anchor/tiffinbox-web/target/extracted/lib
EXJ=.harness/anchor/tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar
RTC='"$M2/org/springframework/boot/spring-boot-resttestclient/4.1.1/spring-boot-resttestclient-4.1.1.jar"'
STJ='"$M2/org/springframework/spring-test/7.0.9/spring-test-7.0.9.jar"'
L_RUNL=$(mine "java $JL -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431")
L_CPL=$(mine "java $JL -cp $CPL")
L_HCP=$(mine 'mvn -o -B -q -Dmaven.repo.local="$M2" -f harness/pom.xml dependency:build-classpath -Dmdep.outputFile="$PWD/.harness/harness.cp"')
L_GETR=$(mine 'mvn -o -B -q -Dmaven.repo.local="$M2" -f harness/pom.xml dependency:get -Dartifact=org.springframework.boot:spring-boot-resttestclient:4.1.1 -Dtransitive=false')
L_GETS=$(mine 'mvn -o -B -q -Dmaven.repo.local="$M2" -f harness/pom.xml dependency:get -Dartifact=org.springframework:spring-test:7.0.9 -Dtransitive=false')
L_JAVAC=$(mine "javac -parameters -Xlint:deprecation -d .harness/hc -cp \"$LIBD/*:.harness/xlib/*\" $HWS")
L_STUB=$(mine "java $JL harness/stub/Stub.java --port=19566 --www=harness/stub/www")
L_MD5=$(mine 'for f in Stub.java www/customers.json www/meera.json www/priya.json www/ravi.json www/sunil.json; do echo "$(md5 -q "harness/stub/$f") $(md5 -q "$S25/$f") $f"; done')
L_DEPRT=$(mine "python3 harness/deps.py $LIBD/spring-web-7.0.9.jar org.springframework.web.client.RestTemplate")
L_DEPRB=$(mine "python3 harness/deps.py .harness/xlib/spring-boot-restclient-4.1.1.jar org.springframework.boot.restclient.RestTemplateBuilder")
L_WHO=$(mine "python3 harness/who.py org/springframework/web/client/RestTemplate $EXJ $LIBD/*.jar .harness/xlib/*.jar")
L_WHOT=$(mine "python3 harness/who.py org/springframework/web/client/RestTemplate $RTC $STJ")
L_DEPHC=$(mine "python3 harness/deps.py $LIBD/spring-boot-http-converter-4.1.1.jar org.springframework.boot.http.converter.autoconfigure.HttpMessageConverters")
L_DEPTR=$(mine "python3 harness/deps.py $RTC org.springframework.boot.resttestclient.TestRestTemplate")
L_DEPMS=$(mine "python3 harness/deps.py $STJ org.springframework.test.web.client.MockRestServiceServer")
L_GREP=$(mine "grep -rlw RestTemplate anchor/tiffinbox-core/src anchor/tiffinbox-web/src harness/probe/web | sort")
L_PROM=$(mine "curl -s -o .harness/prom.txt -w ' %{http_code}\n' http://127.0.0.1:18431/actuator/prometheus")
# The derivations, each asserted
P_='java '; Q_="java $JL "; r=${R_RUN/"$P_"/$Q_}; r2=${R_CP/"$P_"/$Q_}
[ "$r" = "$L_RUNL" ] && [ "$r2" = "$L_CPL" ] || die "the pinned lines must be the anchor's run and class-path lines with $JL after java, and nothing else"
[ "${L_JAVAC#* -cp \"*\" }" = "$HWS" ] || die "the harness's javac line must compile the four files in harness/probe/web, and nothing else"
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
# url 'curl LINE' PORT: the line, its port 18431 made PORT
url() { printf '%s\n' "${1/:18431\//:$2/}"; }
# exe 'COMMAND': the command with "exec" after its "cd DIR && " - so $pid is the program's
exe() { printf '%s\n' "$1" | sed -E 's/&& (([A-Z_]+=[^ ]* )*)/\&\& \1exec /'; }
C_PRE=$(off .harness/pre "$R_PLAIN" package)
[ "$(dev "$C_PRE")" = "$R_PLAIN" ] || die "not the README's build line with the offline changes: $C_PRE"
[ "$(exe "$(at .harness/x 19560 "$R_RUN")")" = "cd .harness/x && exec ${L_RUNL/18431/19560}" ] && [ "$(at .harness/x 18431 "$R_CP")" = "cd .harness/x && $L_CPL" ] && [ "$(at .harness/x 18431 "$R_EXTRACT")" = "cd .harness/x && $R_EXTRACT" ] || die "at(): the pinned lines are not README.md's"
[ "$(hcp .harness/x 19562 probe.web.Templates "--probe.cases=side")" = 'cd .harness/x && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../xlib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19562 --spring.main.sources=probe.web.Templates --probe.cases=side' ] || die "hcp()"
echo "  the commands: anchor/README.md gives the 5 lines this script runs or derives from; README.md the 17 this unit adds"

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
mbuild "$L_GETR" .harness/get-r.log "spring-boot-resttestclient 4.1.1, fetched into .m2-demo if it is not there (who reads it)"
mbuild "$L_GETS" .harness/get-s.log "spring-test 7.0.9, fetched into .m2-demo if it is not there (who reads it)"
[ ! -e harness/target ] || die "a build wrote harness/target"
for a in spring-boot-restclient spring-boot-http-client spring-boot-starter-restclient spring-boot-resttestclient; do
  [ -f "$M2/org/springframework/boot/$a/4.1.1/$a-4.1.1.jar" ] || die "$a 4.1.1 is not in .m2-demo after the first builds"; done
[ -f "$M2/org/springframework/spring-test/7.0.9/spring-test-7.0.9.jar" ] || die "spring-test 7.0.9 is not in .m2-demo (who reads it)"
[ ! -e "$M2/org/apache/httpcomponents/client5/httpclient5" ] || [ -z "$(grep -F httpclient5 .harness/harness.cp || true)" ] || die "httpclient5 is on the harness's class path - every factory sentence would change"
echo "  .m2-demo holds Boot's RestClient starter and the two jars it brings, 4.1.1, and the two test modules' jars who reads"

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
  case " $l " in *':8080 '*|*':35729 '*|*':19569 '*) kill -9 "$pid" 2> /dev/null || true; die "it listened on 8080, 35729 or 19569 - never bound by this script";; esac
  echo "  listens on: $l · loopback only: $(lb "$l")"; echo "  Boot's first line: $(first .harness/run.out)"; }
# ready PORT: readiness asked until it answers 200 - every 0.25 s, up to 120 s, not printed - then the README's readiness line,
# printed and run once. No assertion before it (R.41, R.75). A JVM ($pid) that exits first stops the run. (The harness's Templates runs
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
# read off its pid (polled until it listens on 19566, up to 120 s - it compiles itself first), and the locale it printed. sstop: the
# stub stopped by its pid (TERM: it has no shutdown route), waited for, 19566 free; its dump counted - the demo token 0 times and the
# header X-Shutdown-Token 0 times (R.137) - and how many requests it printed. Every start begins a new dump (and the stub's payment
# numbers start again at pay-1).
sstart() { local l; echo "\$ $L_STUB"; (eval "exec $L_STUB") > .harness/stub.out 2>&1 < /dev/null & spid=$!
  l=$(listening "$spid" 19566); [ "$l" != nothing ] || { tail -20 .harness/stub.out >&3; die "the stub never listened"; }
  echo "  the stub listens on: $l · loopback only: $(lb "$l") · its locale: $(grep -m1 "^STUB the JVM's locale: " .harness/stub.out | sed "s/^.*locale: //")"; }
sstop() { local e=0 t h n
  kill "$spid" 2> /dev/null || true; wait "$spid" || e=$?; spid=""
  [ "$(listeners 19566)" = 0 ] || die "something still listens on 19566"
  t=$(raw "$TOKEN" .harness/stub.out); h=$(LC_ALL=C grep -aoi -- 'x-shutdown-token' .harness/stub.out | wc -l | tr -d ' '); n=$(grep -c '^STUB [A-Z]* /' .harness/stub.out || true)
  DUMPS=$((DUMPS + 1)); [ "$t" = 0 ] && [ "$h" = 0 ] || die "the stub's dump held the demo token ($t) or its header's name ($h)"
  echo "  the stub: stopped by its pid · exit $e · listening on 19566 now: 0 · requests in its dump: $n · the demo token 0 times · X-Shutdown-Token $h times"
  grep '^STUB-H user-agent: ' .harness/stub.out | sed 's/^STUB-H user-agent: //' >> .harness/ua.txt || true; }
mask() { awk -v t="$TOKEN" -v u="$U" -v up="$UP" -v hm="$HOME" -v me="$ME" -v tl="${#TOKEN}" '
  function lit(x) { gsub(/[][\\.^$*+?(){}|\/]/, "\\\\&", x); return x }
  function enc(x) { gsub(/ /, "%20", x); return x }
  BEGIN { T = lit(t); P = lit(u); Q = lit(up); H = lit(hm); PE = lit(enc(u)); QE = lit(enc(up)); M = "(^|[^A-Za-z0-9_])" lit(me) "([^A-Za-z0-9_]|$)" }
  { gsub(T, "[masked: the " tl "-character token]"); gsub(P, "…"); gsub(PE, "…")
    gsub(Q, "…/.."); gsub(QE, "…/.."); gsub(H, "~"); gsub(/\$\$SpringCGLIB\$\$[0-9]+/, "$$SpringCGLIB$$<n>")
    gsub(/\$Proxy[0-9]+/, "$Proxy<n>")
    gsub(/Java-http-client\/[0-9][0-9.]*/, "Java-http-client/<version>")
    gsub(/ using Java [0-9][0-9.]*/, " using Java <version>")
    gsub(/Java\/[0-9][0-9.]*/, "Java/<version>")
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
smark() { settle .harness/stub.out; wc -l < .harness/stub.out | tr -d ' '; }
# logl FROM [LEVELS]: the run's lines after line FROM at those levels (WARN|ERROR unless named), from their level and logger on
logl() { awk -v from="$1" -v lv="${2:-WARN|ERROR}" 'NR > from && $0 ~ (" (" lv ") [0-9]+ --- \\[") { l = $2; s = $0; i = index(s, " --- ["); s = substr(s, i + 6); i = index(s, "] "); s = substr(s, i + 2)
    i = index(s, " : "); lg = substr(s, 1, i - 1); sub(/ +$/, "", lg); msg = substr(s, i + 3)
    gsub(/@[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]+/, "@…", msg); print "    " l " " lg ": " msg }' "${3:-.harness/run.out}"; }
# recs FROM: each WARN or ERROR record the log gained after line FROM (the harness's PAY lines skipped) - its level, its logger and
# its message; then the exception line under it (the first line after the record that is neither blank nor a stack frame); its stack
# frames, bounded ("over 40"), and its other lines, counted - none shown
recs() { awk -v from="$1" '
  function out() { if (inr) print "      its stack frames: " (fr > 40 ? "over 40" : fr + 0) ", its other lines: " (ot + 0) " - none shown"; inr = 0; fr = 0; ot = 0; ex = 0 }
  NR <= from { next }
  /^(TPL|ROUTE) / { next }
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
# tpls: the harness's TPL lines (Templates), in the order they printed, whole - after its "done" line, which must be there
tpls() { grep -q '^TPL done$' .harness/run.out || { tail -20 .harness/run.out >&3; die "the harness's Templates never printed done"; }
  echo "  the harness's lines (Templates), in the order they printed: $(grep -c '^TPL ' .harness/run.out)"; grep '^TPL ' .harness/run.out | sed 's/^TPL /    /'; }
loc() { echo "  the JVM's locale (the harness's Templates): $(grep -m1 "^TPL the JVM's locale: " .harness/run.out | sed "s/^.*locale: //")"; }
# The stub's dump. sdump FROM: every line it printed after line FROM, whole, each after a "|" (the requests, every header, every
# body, every answer); sreqs FROM: one line per request after line FROM - its method and URI, its header count, and the stub's answer
# (the line after its headers and body)
sdump() { local n; n=$(awk -v f="$1" 'NR > f' .harness/stub.out | grep -c . || true); echo "  the stub's dump since, whole: $n lines"; awk -v f="$1" 'NR > f { print "    | " $0 }' .harness/stub.out; }
sreqs() { awk -v f="$1" 'NR <= f { next } /^STUB [A-Z]+ \// { if (q != "") print q " · headers: " h " · no answer"; q = "    " $2 " " $3; h = 0; next } /^STUB-H / { h++; next }
    /^STUB-ANSWER / { a = $0; sub(/^STUB-ANSWER /, "", a); if (q == "") print "    a late answer, its request above: " a; else print q " · headers: " h " · the stub answered " a; q = ""; next } END { if (q != "") print q " · headers: " h " · no answer" }' .harness/stub.out; }
# promf FILE: the scrape kept to its client-request counts (^http_client_requests_seconds_count), sorted, the kept lines counted
# beside the scrape's own line count
promf() { local k n o; k=$(grep -c '^http_client_requests_seconds_count' "$1" || true); n=$(wc -l < "$1" | tr -d ' ')
  o=$((n - k)); [ $o -gt 150 ] && o="over 150 (their number moves from run to run: the JVM's own meters)"
  echo "  kept: $k of the scrape's lines, by the filter ^http_client_requests_seconds_count, sorted · the others not shown: $o"
  grep '^http_client_requests_seconds_count' "$1" | sort | sed 's/^/    /' || true; }
scrape() { rm -f .harness/prom.txt; local p; p=$(url "$L_PROM" "$1"); echo "\$ $p"; (eval "$p") 2>&1 < /dev/null | sed 's/^/  /'; promf .harness/prom.txt; }
# blkraw FROM TO: this capture so far, the lines after the line that starts with FROM, up to the next line that starts with TO (to
# the end when TO is empty); asame A B A2 B2: yes when A's block (A up to B) and A2's (A2 up to B2), their labels aside, are the same
# line for line - an A' against its A
blkraw() { awk -v a="$1" -v b="$2" 'index($0, a) == 1 { f = 1; next } b != "" && index($0, b) == 1 { f = 0 } f' .harness/cap.raw; }
asame() { [ "$(blkraw "$1" "$2")" = "$(blkraw "$3" "$4")" ] && [ -n "$(blkraw "$3" "$4")" ] && echo yes || echo no; }
# The level counts, the record filter, the stub's dump filters, the scrape filter and the masks, checked on planted inputs before any
# capture (R.65, R.120): a harness line that says ERROR, one WARN and one ERROR record - each count must be 1 by the log's own line
# shape, where a bare ' ERROR ' counts 2; a planted dump with a header given twice, a body, an answer, a request with no answer; a
# planted scrape; two proxy class names, two client versions and the token
mkdir -p .harness
{ printf '%s\n' 'TPL side RestClient, retrieve /week-9.json -> org.springframework.web.client.HttpClientErrorException$NotFound | status 404 | message: ERROR' '2026-10-22T00:00:00.000+02:00  WARN 1 --- [planted] o.s.web.servlet.PageNotFound             : planted warning' '2026-10-22T00:00:00.001+02:00 ERROR 1 --- [planted] o.a.c.c.C.[.[.[/].[dispatcherServlet]    : planted error' 'java.lang.IllegalStateException: planted' "$(printf '\tat a')" 'TPL done'; } > .harness/run.out
[ "$(logl 0 ERROR | grep -c .)" = 1 ] && [ "$(logl 0 WARN | grep -c .)" = 1 ] && [ "$(lvl ERROR .harness/run.out)" = 1 ] && [ "$(lvl WARN .harness/run.out)" = 1 ] && [ "$(grep -c ' ERROR' .harness/run.out)" = 2 ] || die "the level counts: the planted log must give 1 WARN and 1 ERROR by line shape (a bare ' ERROR' gives 2)"
[ "$(recs 0)" = "$(printf '%s\n' '    WARN o.s.web.servlet.PageNotFound: planted warning' '      its stack frames: 0, its other lines: 0 - none shown' '    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: planted error' '      java.lang.IllegalStateException: planted' '      its stack frames: 1, its other lines: 0 - none shown')" ] || die "recs: the planted log's harness lines must be skipped (.harness/run.out)"
printf '%s\n' 'STUB listening on /127.0.0.1:19566' 'STUB POST /payments headers=[Content-type, Host]' 'STUB-H content-type: application/json' 'STUB-H host: 127.0.0.1:19566' 'STUB-BODY {"customer":"Ravi","amount":7200}' 'STUB-ANSWER 201 application/json 62 bytes' 'STUB GET /payments/slow headers=[Host]' 'STUB-H host: 127.0.0.1:19566' 'STUB GET /payments/pay-1 headers=[Accept-encoding, Host]' 'STUB-H accept-encoding: gzip' 'STUB-H accept-encoding: deflate' 'STUB-H host: 127.0.0.1:19566' 'STUB-ANSWER 200 application/json 62 bytes' 'STUB-ANSWER 200 application/json 13 bytes' > .harness/stub.out
PL=$(sreqs 1); [ "$PL" = "$(printf '%s\n' '    POST /payments · headers: 2 · the stub answered 201 application/json 62 bytes' '    GET /payments/slow · headers: 1 · no answer' '    GET /payments/pay-1 · headers: 3 · the stub answered 200 application/json 62 bytes' '    a late answer, its request above: 200 application/json 13 bytes')" ] || die "sreqs: the planted dump does not come out as declared (got: $PL)"
PL=$(sdump 1); [ "$(printf '%s\n' "$PL" | sed -n 1p)" = "  the stub's dump since, whole: 13 lines" ] && [ "$(printf '%s\n' "$PL" | grep -c '^    | STUB-H accept-encoding: ')" = 2 ] && [ "$(printf '%s\n' "$PL" | grep -c '^    | STUB-BODY ')" = 1 ] || die "sdump: the planted dump must come out whole, a header given twice as two lines, its body kept"
printf '%s\n' '# HELP x' 'http_client_requests_seconds_count{uri="/payments/{id}"} 2' 'jvm_threads_live_threads 30' 'http_client_requests_seconds_count{uri="/payments"} 1' > .harness/p1
PL=$(promf .harness/p1); [ "$PL" = "$(printf '%s\n' '  kept: 2 of the scrape'"'"'s lines, by the filter ^http_client_requests_seconds_count, sorted · the others not shown: 2' '    http_client_requests_seconds_count{uri="/payments"} 1' '    http_client_requests_seconds_count{uri="/payments/{id}"} 2')" ] || die "promf: the planted scrape does not come out as declared (got: $PL)"
printf '%s\n' 'Java-http-client/25.0.4.1 and Java-http-client/23 and Java/25.0.4.1' 'jdk.proxy2.$Proxy84 and jdk.proxy3.$Proxy7 and App$$SpringCGLIB$$0' "$TOKEN" > .harness/p1
[ "$(mask < .harness/p1)" = "$(printf '%s\n' 'Java-http-client/<version> and Java-http-client/<version> and Java/<version>' 'jdk.proxy2.$Proxy<n> and jdk.proxy3.$Proxy<n> and App$$SpringCGLIB$$<n>' '[masked: the 32-character token]')" ] || die "mask: the planted User-Agent versions, proxy numbers and token must be masked"
[ "$(printf '%s\n' 'Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1' | mask)" = 'Starting TiffinBoxServer v1.0.0 using Java <version>' ] || die "mask: the planted Boot first line's JDK version must be masked (RED S5 #426/#472)"
rm -f .harness/run.out .harness/stub.out .harness/p1
echo "  the filters: the record filter, the stub's dump filters, the scrape filter and the masks print their planted inputs as declared; a harness line that says ERROR is no ERROR line; a header given twice is two lines"

# ---- status: where it stands - the anchor, the starter's jars, the harness, the stub, the class files, the seven, the beans ------
status() { local c
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
  echo "the harness, compiled against the anchor's own jars and those two - with javac's deprecation warnings on (this unit's line):"
  echo "\$ $L_JAVAC"; rm -rf .harness/hc; (eval "$L_JAVAC") > .harness/javac.log 2>&1 < /dev/null || { cat .harness/javac.log >&3; die "the harness did not compile against the anchor's jars"; }
  echo "  exit 0 · what javac printed: $(wc -l < .harness/javac.log | tr -d ' ') lines · its classes: $(cd .harness/hc && find . -name '*.class' | sed 's#^\./##' | sort | paste -sd' ' -)"
  echo "the stub - this folder's copy against the RestClient lesson's (\$S25), md5 for md5 (this unit's line):"
  echo "\$ $L_MD5"; (eval "$L_MD5") 2>&1 < /dev/null | sed 's/^/  /'
  echo "  the same md5, file by file: $(for f in Stub.java $(for w in $WWW; do echo "www/$w"; done); do [ "$(md5 -q "harness/stub/$f")" = "$(md5 -q "$S25/$f")" ] && echo x; done | grep -c . || true) of 6 · routes this unit adds to it: 0"
  echo "where RestTemplate stands - what its class files say about deprecation: the class and every class nested in it, each read with javap -v -p (this unit's line):"
  echo "\$ $L_DEPRT"; (eval "$L_DEPRT") 2>&1 < /dev/null | sed 's/^/  /'
  echo "Boot's builder for it - the same reader, on the one class (this unit's line):"
  echo "\$ $L_DEPRB"; (eval "$L_DEPRB") 2>&1 < /dev/null | sed 's/^/  /'
  echo "whose classes - each read off the one jar on that class path that holds it (unzip -l, by name):"
  for c in org/springframework/web/client/RestTemplate org/springframework/web/client/RestClient org/springframework/http/client/ClientHttpRequestInterceptor org/springframework/http/client/JdkClientHttpRequestFactory org/springframework/http/client/SimpleClientHttpRequestFactory org/springframework/boot/restclient/RestTemplateBuilder org/springframework/boot/restclient/autoconfigure/RestTemplateAutoConfiguration; do
    echo "  $(printf '%s' "$c" | tr / .) · in: $(for j in "$LIBD"/*.jar .harness/xlib/*.jar; do unzip -l "$j" "$c.class" > /dev/null 2>&1 && echo "${j##*/}"; done | paste -sd' ' -)"; done
  echo "the seven - the anchor, the README's run line (its locale pinned), port 19560, a fresh JVM:"
  start "$(at .harness/anchor 19560 "$R_RUN")"; up 19560; ready 19560; seven 19560 .harness/anchor; WARNS; logl 0 WARN
  echo "the seven - the anchor on its class path, the two jars and the harness joined (Templates, TemplateRoutes; the case beans), port 19561, a fresh JVM:"
  start "$(hcp .harness/anchor 19561 probe.web.Templates,probe.web.TemplateRoutes --probe.cases=beans)"; up 19561; ready 19561; loc; tpls; seven 19561 .harness/anchor; WARNS; logl 0 WARN
  echo "the lines that moved - the README's run line's seven against the harness line's, masked, line for line:"
  python3 - .harness/seven-19560.txt .harness/seven-19561.txt <<'PY'
import sys
a = open(sys.argv[1], encoding="utf-8").read().splitlines(); b = open(sys.argv[2], encoding="utf-8").read().splitlines()
d = [i for i in range(max(len(a), len(b))) if i >= len(a) or i >= len(b) or a[i] != b[i]]
s = [i for i in range(min(len(a), len(b))) if a[i] == b[i]]
print("  lines that differ: %d%s · the same, byte for byte: %d (%s)" % (len(d), (" (" + " ".join(str(i + 1) for i in d) + ")") if d else "", len(s), " ".join(str(i + 1) for i in s)))
PY
}

# reqs FROM: one line per request the stub printed after line FROM - its method and URI, then the headers a capture reads: Accept,
# accept-encoding (every value), upgrade, user-agent, X-Via - each value as sent, "none" when the request had no such header; then the
# counts over those requests
reqs() { awk -v f="$1" '
  function flush() { if (q == "") return; n++; print "    " q " · accept: " (ac == "" ? "none" : ac) " · accept-encoding: " (ae == "" ? "none" : ae) " · upgrade: " (up == "" ? "none" : up) " · user-agent: " (ua == "" ? "none" : ua) " · x-via: " (xv == "" ? "none" : xv)
    if (ac != "") na++; if (ae != "") ne++; if (up != "") nu++; if (xv != "") nx++; q = "" }
  NR <= f { next }
  /^STUB [A-Z]+ \// { flush(); q = $2 " " $3; ac = ""; ae = ""; up = ""; ua = ""; xv = ""; next }
  /^STUB-H accept: / { ac = substr($0, 16); next }
  /^STUB-H accept-encoding: / { ae = (ae == "" ? "" : ae ", ") substr($0, 25); next }
  /^STUB-H upgrade: / { up = substr($0, 17); next }
  /^STUB-H user-agent: / { ua = substr($0, 20); next }
  /^STUB-H x-via: / { xv = substr($0, 15); next }
  END { flush(); print "  the requests: " n + 0 " · with an Accept header: " na + 0 " · with accept-encoding: " ne + 0 " · with upgrade: " nu + 0 " · with X-Via: " nx + 0 }' .harness/stub.out; }

# ---- side: the same job, the same exceptions - a template beside RestClient -----------------------------------------------------
side() { local s0
  echo "the stub - this unit's line, port 19566:"
  sstart
  echo "side by side - the anchor on its class path, the two jars and the harness joined (Templates), the case side, port 19562, a fresh JVM:"
  s0=$(smark); start "$(hcp .harness/anchor 19562 probe.web.Templates --probe.cases=side)"; up 19562; ready 19562; loc; tpls
  echo "what the clients sent, and what the stub answered - the stub's dump of the calls, whole:"
  sdump "$s0"
  echo "  what each request carried, one line a request:"; reqs "$s0"
  WARNS; stop 19562 .harness/anchor
  sstop; }

# ---- factories: A Boot's builder's template, B new RestTemplate(), A' = A ----------------------------------------------------
frun() { local s0
  sstart; s0=$(smark)
  start "$(hcp .harness/anchor "$1" probe.web.Templates "--probe.cases=$2")"; up "$1"; ready "$1"; loc; tpls
  sdump "$s0"
  echo "  what each request carried, one line a request:"; reqs "$s0"
  WARNS; stop "$1" .harness/anchor; sstop; }
factories() {
  echo "  19569, never bound: listening $(listeners 19569) (lsof, by port)"
  echo "A - the template from Boot's builder (RestTemplateBuilder.build()), the case boot, a fresh stub, port 19563, a fresh JVM:"
  frun 19563 boot
  echo "B - new RestTemplate(), the case new, a fresh stub, port 19560, a fresh JVM:"
  frun 19560 new
  echo "A' - A again, a fresh stub, port 19563, a fresh JVM:"
  frun 19563 boot
  echo "A' against A, its label aside, line for line the same: $(asame "A - " "B - " "A' - " "A' against A")"; }

# ---- migrate: the move - a template with an interceptor, and RestClient built from it ---------------------------------------------
migrate() { local s0
  echo "the stub - this unit's line, port 19566:"
  sstart; s0=$(smark)
  echo "the move - the anchor on its class path, the two jars and the harness joined (Templates), the case migrate, port 19561, a fresh JVM:"
  start "$(hcp .harness/anchor 19561 probe.web.Templates --probe.cases=migrate)"; up 19561; ready 19561; loc; tpls
  echo "what the clients sent - the stub's dump of the four calls, whole:"
  sdump "$s0"
  echo "  what each request carried, one line a request:"; reqs "$s0"
  echo "what was observed - one scrape of the same JVM's /actuator/prometheus (this unit's line):"
  scrape 19561
  WARNS; stop 19561 .harness/anchor
  sstop; }

# ---- who: who still names it - class files, then sources ----------------------------------------------------------------------
who() {
  echo "which class files name RestTemplate - every jar on the class path the harness runs on: TiffinBox's own jar, the anchor's $(ls "$LIBD" | grep -c '\.jar$') libraries (tiffinbox-core among them), the $(ls .harness/xlib | grep -c '\.jar$') the starter adds (this unit's line):"
  echo "\$ $L_WHO"; (eval "$L_WHO") 2>&1 < /dev/null | sed 's/^/  /'
  echo "the two test modules' jars - in .m2-demo, not on that class path (this unit's line):"
  echo "\$ $L_WHOT"; (eval "$L_WHOT") 2>&1 < /dev/null | sed 's/^/  /'
  echo "what the class files of three of the classes found say about deprecation - the same reader (this unit's lines):"
  for c in "$L_DEPHC" "$L_DEPTR" "$L_DEPMS"; do echo "\$ $c"; (eval "$c") 2>&1 < /dev/null | sed 's/^/  /'; done
  echo "the sources - TiffinBox's two modules and the harness, the word RestTemplate (this unit's line):"
  echo "\$ $L_GREP"; (eval "$L_GREP") 2>&1 < /dev/null | sed 's/^/  /'
  echo "  files that name it: under anchor/ $( (eval "$L_GREP") 2> /dev/null | grep -c '^anchor/' || true) · under harness/ $( (eval "$L_GREP") 2> /dev/null | grep -c '^harness/' || true)"; }

block() { awk '/^```bash$/ { if (!d) { f = 1 }; next } f && /^```$/ { f = 0; d = 1 } f' "$1"; }
# The shell a viewer has: env -i - nothing this script set reaches it (its JAVA_HOME, the JDK at the front of its PATH, LC_ALL,
# no_proxy, CURL_HOME) - with HOME and the PATH you started this script with; /bin/bash without profile or rc files, started in this
# folder. A driver in .harness/ runs the README's block, then SOLUTION.md's, as a viewer pastes them - each with its output, its exit
# code and the folder it left the shell in kept apart (absolute paths: a command that moved the shell must not move these files),
# and the README's run log, the stub's and the route's source kept before the solution's run writes its own. Bounded (600 s); on the
# way out, or past the bound, the shell and every process under it are stopped (killtree).
# where DIR: the folder the shell was left in - this unit's folder, a folder under it (named), or elsewhere
where() { case "$1" in "$U") echo "this unit's folder" ;; "$U"/*) echo "${1#"$U"/}" ;; *) echo "outside this unit's folder" ;; esac; }
SOLL="sed -i '' 's/RestClient\\.create()/RestClient.create(template)/' .harness/mine/src/TemplateRoutes.java"
exercise() { local setup sol i=0 e1 d1 e2 d2 l1 l2
  setup=$(block exercise/README.md); sol=$(block exercise/solution/SOLUTION.md)
  [ -n "$setup" ] && [ -n "$sol" ] || die "exercise/README.md or SOLUTION.md no longer gives its commands"
  [ "$(printf '%s\n' "$sol" | grep -c .)" = 4 ] || die "SOLUTION.md's first bash block must be the README's two export lines, the solution's one line and the README's last line"
  [ "$(printf '%s\n' "$sol" | sed -n 1,2p)" = "$(printf '%s\n' "$setup" | sed -n 1,2p)" ] || die "SOLUTION.md must start with the README's two export lines (a new shell's java may be another JDK)"
  printf '%s\n' "$sol" | sed -n 1p | grep -qxF 'export JAVA_HOME=/opt/homebrew/opt/openjdk@25' || die "SOLUTION.md's first line must export this script's JAVA_HOME"
  printf '%s\n' "$sol" | sed -n 3p | grep -qxF -- "$SOLL" || die "SOLUTION.md's third line must be the one change: $SOLL"
  l1=$(printf '%s\n' "$setup" | tail -1); l2=$(printf '%s\n' "$sol" | sed -n 4p)
  [ "$l1" = "$l2" ] || die "SOLUTION.md's last line must be the README's last line, unchanged: the fix is the route's one line, not the command"
  rm -f .harness/ex-*
  printf '%s\n' "$setup" > .harness/ex-readme.sh; printf '%s\n' "$sol" > .harness/ex-sol.sh
  cat > .harness/ex-drive.sh <<'DRV'
cd "$1" || exit 1
. "$1/.harness/ex-readme.sh" > "$1/.harness/ex-readme.out" 2>&1 < /dev/null
echo "$? $PWD" > "$1/.harness/ex-readme.st"
cp "$1/.harness/mine/run.log" "$1/.harness/ex-readme.log" 2> /dev/null
cp "$1/.harness/mine/stub.log" "$1/.harness/ex-readme.stub" 2> /dev/null
grep -n 'RestClient\.create(' "$1/.harness/mine/src/TemplateRoutes.java" > "$1/.harness/ex-readme.src" 2> /dev/null
. "$1/.harness/ex-sol.sh" > "$1/.harness/ex-sol.out" 2>&1 < /dev/null
echo "$? $PWD" > "$1/.harness/ex-sol.st"
grep -n 'RestClient\.create(' "$1/.harness/mine/src/TemplateRoutes.java" > "$1/.harness/ex-sol.src" 2> /dev/null
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
  echo "  the moved call in the route's copy (.harness/mine/src/TemplateRoutes.java): $(cat .harness/ex-readme.src)"
  echo "  the shell is now in: $(where "$d1") · the JVM's locale in its log: $(grep -m1 "^ROUTE the JVM's locale: " .harness/ex-readme.log | sed "s/^.*locale: //") (TemplateRoutes), in the stub's: $(grep -m1 "^STUB the JVM's locale: " .harness/ex-readme.stub | sed "s/^.*locale: //") · the copy's own token in its log: $(raw "$(head -1 .harness/mine/anchor/$TF)" .harness/ex-readme.log) times, in the stub's dump: $(raw "$(head -1 .harness/mine/anchor/$TF)" .harness/ex-readme.stub) times · WARN lines in its log: $(lvl WARN .harness/ex-readme.log) · ERROR lines: $(lvl ERROR .harness/ex-readme.log) · listening on 19564 now: $(listeners 19564) · on 19566: $(listeners 19566)"
  echo "  the stub's dump of the README's run, one line a request:"; cp .harness/ex-readme.stub .harness/stub.out; reqs 0
  echo "the solution's $(printf '%s\n' "$sol" | grep -c .) lines, next, in the same shell:"
  printf '%s\n' "$sol" | sed 's/^/  $ /'
  echo "  exit $e2 · what they printed:"; sed 's/^/    /' .harness/ex-sol.out
  echo "  the moved call in the route's copy: $(cat .harness/ex-sol.src)"
  echo "  the shell is now in: $(where "$d2") · the JVM's locale in its log: $(grep -m1 "^ROUTE the JVM's locale: " .harness/mine/run.log | sed "s/^.*locale: //") (TemplateRoutes), in the stub's: $(grep -m1 "^STUB the JVM's locale: " .harness/mine/stub.log | sed "s/^.*locale: //") · the copy's own token in its log: $(raw "$(head -1 .harness/mine/anchor/$TF)" .harness/mine/run.log) times, in the stub's dump: $(raw "$(head -1 .harness/mine/anchor/$TF)" .harness/mine/stub.log) times · WARN lines in its log: $(lvl WARN .harness/mine/run.log) · ERROR lines: $(lvl ERROR .harness/mine/run.log) · listening on 19564 now: $(listeners 19564) · on 19566: $(listeners 19566)"
  echo "  the stub's dump of the solution's run, one line a request:"; cp .harness/mine/stub.log .harness/stub.out; reqs 0
  rm -f .harness/stub.out; }

cap status status
cap side side
cap factories factories
cap migrate migrate
cap who who
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
SHIP="README.md exercise/README.md exercise/solution/SOLUTION.md receipts.md5 harness/pom.xml harness/stub/Stub.java harness/shutdown.sh harness/deps.py harness/who.py $HWS"
for f in .r-*.out $SHIP; do [ "$(raw "$TOKEN" "$f")" = 0 ] || die "$f holds the demo token, raw"; done
for f in .r-*.out; do ! grep -qE '/Users/|/private/|/home/|/var/folders/' "$f" || die "$f holds an absolute path"; ! grep -qE 'c[0-9]-unit[0-9]|unit ?[0-9]' "$f" || die "$f holds a unit number"; ! grep -qE ' (with PID|started by) ' "$f" || die "$f holds Boot's process line"; ! grep -qE '^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T|"timestamp":"?[0-9]|(exec|handler|task|omcat-handler)-[0-9]' "$f" || die "$f holds a log time, a timestamp or a thread number"; ! grep -qE 'Java-http-client/[0-9]|Java/[0-9]+\.[0-9]| using Java [0-9]|Macintosh|Mac OS X|Windows NT|X11;|Linux x86' "$f" || die "$f holds a JDK version (a client's, or Boot's first line's) or a platform (R.128, R.136)"; ! grep -qE '\$Proxy[0-9]|SpringCGLIB\$\$[0-9]' "$f" || die "$f holds a proxy class's number (masked: it moves with the class path)"; ! grep -qE ':8080|:35729|:18425/' "$f" || die "$f names 8080, 35729 or 18425"; ! grep -q "$(printf '\r')" "$f" || die "$f holds a carriage return"; ! grep -qE '[0-9]+ ?ms\b|[0-9]+\.[0-9]+ ?s(econds)?\b|Started .* in ' "$f" || die "$f holds a duration (R.121, R.139)"; ! grep -qE '^\s+at [a-z]' "$f" || die "$f holds a stack frame"; done
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
# R.138: Boot 3's spelling of the client keys (the singular one) nowhere in this unit - this script builds it, never writes it
for f in receipts.sh $SHIP; do ! grep -qF "$K1" "$f" || die "$f spells Boot 3's client key (R.138)"; done
# R.114 (S3.18): no harness class reaches the anchor - its tree names none of them (as whole words)
for c in Templates TemplateRoutes Via probe.web Stub RestTemplate; do ! grep -rqwF "$c" anchor/tiffinbox-web/src anchor/tiffinbox-core/src || die "the anchor's sources name $c (a whole word) - the harness is shown on the harness, never in the anchor"; done
# no capture runs a command with a URL that is not 127.0.0.1's; the stub binds the loopback address
for f in .r-*.out; do ! grep -E '^ *\$ ' "$f" | grep -oE 'https?://[^ '"'"']+' | grep -vE '^http://127\.0\.0\.1:' > /dev/null || die "$f runs a command with a URL that is not 127.0.0.1's"; done
grep -qF 'new InetSocketAddress(InetAddress.getLoopbackAddress(), port)' harness/stub/Stub.java || die "the stub must bind the loopback address"
for f in $HWS harness/stub/Stub.java exercise/README.md exercise/solution/SOLUTION.md; do ! grep -qE 'https?://localhost|localhost:' "$f" || die "$f names localhost - every URL is 127.0.0.1's (R.82)"; done
# S4.1: every java line a capture starts pins the JVM's locale (the extract line prints nothing a locale changes) - the stub's too
for f in .r-*.out; do ! grep -E '^ *\$ (cd [^ ]+ && )?(exec )?java ' "$f" | grep -vF -- "java $JL " | grep -vF -- 'java -Djarmode=tools ' > /dev/null || die "$f starts a JVM without its locale pinned (S4.1)"; done
for f in exercise/README.md exercise/solution/SOLUTION.md; do ! grep -oE '\{ java [^>]*' "$f" | grep -vF -- "{ java $JL " > /dev/null || die "$f: the exercise's java lines must pin the JVM's locale (S4.1)"; done
[ "$(grep -oE '\{ java [^>]*' exercise/README.md | grep -c .)" = 2 ] || die "exercise/README.md must start two JVMs (the stub, TiffinBox), each in a subshell job"
# httpclient5 never joins (S5.3): not on the harness's class path, not in the anchor's lib/
! grep -qF httpclient5 .harness/harness.cp && [ -z "$(ls "$LIBD" | grep '^httpclient5-' || true)" ] || die "httpclient5 is on the class path - every factory sentence would change"
# R.115: no browser is used here - the exercise names one only to say none is needed
[ "$(grep -oi 'browser' exercise/README.md | wc -l | tr -d ' ')" = 1 ] && grep -i 'browser' exercise/README.md | grep -qF 'browser are needed' && [ "$(grep -oi 'browser' exercise/solution/SOLUTION.md | wc -l | tr -d ' ')" = 0 ] || die "the exercise speaks of a browser (R.115) - none is used"
# R.141's twin: every RestClient built from Boot's injected builder is built on a clone(); the template's builder is Boot's immutable one
[ "$(grep -c 'clients\.clone()' harness/probe/web/Templates.java)" = "$(grep -cE 'clients\.' harness/probe/web/Templates.java)" ] || die "Templates.java configures Boot's injected RestClient.Builder without clone() (R.141)"
# "deprecated" and "maintenance mode" are said of nothing here but what deps.py read: no shipped prose calls RestTemplate either (the
# READMEs name both words only to say they are never said)
for f in README.md exercise/README.md exercise/solution/SOLUTION.md; do ! grep -qiE 'RestTemplate (is|was|has been) (now )?(deprecated|in maintenance mode)|(is|was|now) in maintenance mode' "$f" || die "$f calls RestTemplate deprecated or in maintenance mode (brief ⚑8)"; done
NL=$(cat .r-*.out | grep -cE "^  its log: the demo token 0 times · X-Shutdown-Token 0 times\$" || true)
ND=$(cat .r-*.out | grep -cE "· the demo token 0 times · X-Shutdown-Token 0 times\$" || true)
echo "  tokens: 0 raw copies in $(ls .harness/raw-* | wc -l | tr -d ' ') raw capture runs, in $(ls .r-*.out | wc -l | tr -d ' ') captures; the demo token 0 in the logs of every JVM that ran ($LOGS here; the published captures' $NL) and in every stub dump ($DUMPS here; the published captures' $ND), the READMEs, the harness, the stub and receipts.md5; no absolute path, no unit number, no process line, no log time, no timestamp, no thread number, no client JDK version, no platform, no duration, no stack frame, no URL but 127.0.0.1's; every JVM's locale pinned; Boot 3's client key nowhere"
echo "  the User-Agents the stub saw, masked in every capture (terminal only): $(sort -u .harness/ua.txt 2> /dev/null | paste -sd' ' -)"

S466='466c20ed7e0d5439cb052f32ce09de1b'
LOC="  the JVM's locale (the harness's Templates): en_US"
SL="  the stub listens on: 127.0.0.1:19566 · loopback only: yes · its locale: en_US"
DONE="    done"
Z3="  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0 · lines that say \"deprecat\": 0"
UA="Java-http-client/<version>"
MEERA='Row[name=Meera, mealsPerDay=1, pricePerMeal=150, veg=true]'; RAVI='Row[name=Ravi, mealsPerDay=2, pricePerMeal=120, veg=true]'
JA='application/json, application/*+json'
UAS=$(sort -u .harness/ua.txt 2> /dev/null | paste -sd' ' -)

# "not deprecated in Framework seven point zero ... Boot still makes a builder bean ... the same seven" - status
TO=$(cat .r-status.out)
has "$TO" '  built the anchor · offline: yes · exit 0' "status: the anchor built offline"
has "$TO" "  the anchor's libraries (its extracted lib/): 61 · Boot's RestClient module among them: 0 · httpclient5: 0" "status: 61 libraries"
has "$TO" "  the jars it lists: 31 · in the anchor's lib/ already, by name (the version is in the name): 25 · not:" "status: 31 listed, 25 there"
has "$TO" "    spring-boot-restclient-4.1.1.jar · classes: 29 · joined (.harness/xlib)" "status: spring-boot-restclient joined"
has "$TO" "    spring-boot-http-client-4.1.1.jar · classes: 88 · joined (.harness/xlib)" "status: spring-boot-http-client joined"
[ "$(printf '%s\n' "$TO" | grep -c '^    .*\.jar · classes: 0 · not joined: no class')" = 4 ] && [ "$(printf '%s\n' "$TO" | grep -c '^    .*\.jar · classes: ')" = 6 ] || die "status: six jars the anchor lacks, four of them starters"
has "$TO" "  the class path the harness runs on: the anchor's 61 libraries + 2 = 63" "status: 61 + 2 = 63"
has "$TO" "  exit 0 · what javac printed: 0 lines · its classes: probe/web/Row.class probe/web/TemplateRoutes.class probe/web/Templates.class probe/web/Via.class" "status: the harness compiled, no deprecation warning"
has "$TO" "  $SMD5 $SMD5 Stub.java" "status: the stub's md5, the RestClient lesson's"
has "$TO" "  the same md5, file by file: 6 of 6 · routes this unit adds to it: 0" "status: the stub copied, byte for byte"
has "$TO" "\$ $L_DEPRT" "status: the deprecation reader's line"
has "$TO" "  class files read: 5 · Deprecated attributes in all: 0" "status: RestTemplate, 0 Deprecated attributes (not deprecated in Framework 7.0)"
[ "$(printf '%s\n' "$TO" | grep -c '^  org\.springframework\.web\.client\.RestTemplate[$ ].* · Deprecated attributes: on the class 0, on members 0$')" = 5 ] || die "status: RestTemplate and its four nested classes, each 0 on the class and 0 on members"
has "$TO" "  org.springframework.web.client.RestTemplate · javap: 4215 lines · members: 85 · Deprecated attributes: on the class 0, on members 0" "status: RestTemplate's 85 members read"
has "$TO" '  org.springframework.boot.restclient.RestTemplateBuilder · javap: 2780 lines · members: 60 · Deprecated attributes: on the class 0, on members 1 · public org.springframework.boot.restclient.RestTemplateBuilder rootUri(java.lang.String) (@Deprecated(forRemoval=true, since="4.1.0"))' "status: Boot's builder - one member deprecated, rootUri (the reader can count one)"
for l in 'org.springframework.web.client.RestTemplate · in: spring-web-7.0.9.jar' 'org.springframework.web.client.RestClient · in: spring-web-7.0.9.jar' 'org.springframework.http.client.ClientHttpRequestInterceptor · in: spring-web-7.0.9.jar' 'org.springframework.http.client.JdkClientHttpRequestFactory · in: spring-web-7.0.9.jar' 'org.springframework.http.client.SimpleClientHttpRequestFactory · in: spring-web-7.0.9.jar' 'org.springframework.boot.restclient.RestTemplateBuilder · in: spring-boot-restclient-4.1.1.jar' 'org.springframework.boot.restclient.autoconfigure.RestTemplateAutoConfiguration · in: spring-boot-restclient-4.1.1.jar'; do has "$TO" "  $l" "status: an owner (R.134)"; done
[ "$(cnt "$TO" "  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 0 · md5 $S466")" = 2 ] || die "status: the seven $S466 on both lines"
[ "$(cnt "$TO" '    WARN o.s.web.servlet.PageNotFound: Request method '"'"'GET'"'"' is not supported')" = 2 ] || die "status: the seven's one WARN, PageNotFound, on both lines"
has "$TO" '  lines that differ: 0 · the same, byte for byte: 7 (1 2 3 4 5 6 7)' "status: the same, byte for byte: 7"
has "$TO" "$LOC" "status: the locale"; has "$TO" "$DONE" "status: Templates done"
has "$TO" '    beans RestTemplateBuilder: restTemplateBuilder (scope singleton) -> org.springframework.boot.restclient.RestTemplateBuilder | made by: org.springframework.boot.restclient.autoconfigure.RestTemplateAutoConfiguration' "status: Boot still makes a restTemplateBuilder bean"
has "$TO" '    beans RestTemplate: no bean' "status: no RestTemplate bean"
has "$TO" '    beans RestClient.Builder: restClientBuilder (scope prototype) -> org.springframework.web.client.DefaultRestClientBuilder | made by: org.springframework.boot.restclient.autoconfigure.RestClientAutoConfiguration' "status: restClientBuilder"
has "$TO" '    beans RestClient: no bean' "status: no RestClient bean"
echo "  status: 61 + 2 = 63; javac -Xlint:deprecation 0 lines; the stub 6 of 6 md5 = the RestClient lesson's ($SMD5); RestTemplate and its 4 nested classes: 0 Deprecated attributes (85 members of RestTemplate read); RestTemplateBuilder: 1 of 60, rootUri (forRemoval, since 4.1.0); owners spring-web / spring-boot-restclient; the seven $S466 on both lines, the same, byte for byte: 7; restTemplateBuilder (singleton, RestTemplateAutoConfiguration), no RestTemplate bean"

# "the same not found, a message that names the URL ... an Accept header RestClient never sends ... five message converters" - side
SO=$(cat .r-side.out)
has "$SO" "$SL" "side: the stub, loopback, en_US"; has "$SO" "$LOC" "side: the locale"; has "$SO" "$DONE" "side: done"
ST404='    side the template, getForObject /week-9.json -> org.springframework.web.client.HttpClientErrorException$NotFound | status 404 | message: 404 Not Found on GET request for "http://127.0.0.1:19566/week-9.json": "not found"'
RC404='    side RestClient, retrieve /week-9.json -> org.springframework.web.client.HttpClientErrorException$NotFound | status 404 | message: 404 Not Found: "not found"'
has "$SO" "$ST404" "side: the template's NotFound, its message naming the URL"
has "$SO" "$RC404" "side: RestClient's NotFound"
has "$SO" '    side the same exception class: true' "side: the same exception class"
nhas "$SO" '    side the template, getForObject /week-9.json: no exception' "side: the template threw"
has "$SO" "    side the template, getForObject /{f} meera.json, Row.class -> $MEERA" "side: the template's row"
has "$SO" "    side RestClient, retrieve /{f} meera.json, body(Row.class) -> $MEERA" "side: RestClient's row"
has "$SO" "    side the template's message converters: 5 [org.springframework.http.converter.ByteArrayHttpMessageConverter, org.springframework.http.converter.StringHttpMessageConverter, org.springframework.http.converter.ResourceHttpMessageConverter, org.springframework.http.converter.support.AllEncompassingFormHttpMessageConverter, org.springframework.http.converter.json.JacksonJsonHttpMessageConverter]" "side: five converters, Jackson's last"
has "$SO" "    GET /week-9.json · accept: text/plain, application/json, application/*+json, */* · accept-encoding: gzip, deflate · upgrade: h2c · user-agent: $UA · x-via: none" "side: the template's String request, its Accept"
has "$SO" "    GET /meera.json · accept: $JA · accept-encoding: gzip, deflate · upgrade: h2c · user-agent: $UA · x-via: none" "side: the template's Row request, accept application/json, application/*+json"
[ "$(cnt "$SO" "    GET /week-9.json · accept: none · accept-encoding: gzip, deflate · upgrade: h2c · user-agent: $UA · x-via: none")" = 1 ] && [ "$(cnt "$SO" "    GET /meera.json · accept: none · accept-encoding: gzip, deflate · upgrade: h2c · user-agent: $UA · x-via: none")" = 1 ] || die "side: RestClient's two requests, no Accept"
has "$SO" "  the requests: 4 · with an Accept header: 2 · with accept-encoding: 4 · with upgrade: 4 · with X-Via: 0" "side: 4 requests, 2 with Accept (the template's)"
[ "$(printf '%s\n' "$SO" | grep -c '^    | STUB-H accept: ')" = 2 ] || die "side: the dump itself holds two Accept lines"
has "$SO" "  the stub's dump since, whole: 38 lines" "side: the dump, 38 lines"
has "$SO" "$Z3" "side: 0/0"
has "$SO" "  the stub: stopped by its pid · exit 143 · listening on 19566 now: 0 · requests in its dump: 4 · the demo token 0 times · X-Shutdown-Token 0 times" "side: four requests, 0 tokens"
echo "  side: the template's 404 and RestClient's - the same HttpClientErrorException\$NotFound; the template's message names the URL; the same row both ways; 5 message converters, Jackson's last; the stub: Accept on the template's 2 requests (text/plain, application/json, application/*+json, */* for a String; application/json, application/*+json for a Row), on RestClient's 0"

# "Boot's builder: the JDK's client ... new RestTemplate(): HttpURLConnection, Java slash, no upgrade, no accept-encoding ... both
# followed the redirect - GET ... A again" - factories
FO=$(cat .r-factories.out); FA=$(blk factories "A - " "B - "); FB=$(blk factories "B - " "A' - "); FA2=$(blk factories "A' - " "A' against A")
has "$FO" '  19569, never bound: listening 0 (lsof, by port)' "factories: 19569 free"
for b in "$FA" "$FA2"; do has "$b" '    boot its request factory: org.springframework.http.client.JdkClientHttpRequestFactory' "factories A: JdkClientHttpRequestFactory"
  has "$b" "    boot getForObject /{f} meera.json -> $MEERA" "factories A: the row"; has "$b" "    boot getForEntity /redirect -> 200 $RAVI" "factories A: the redirect followed"
  for u in /meera.json /redirect /ravi.json; do has "$b" "    GET $u · accept: $JA · accept-encoding: gzip, deflate · upgrade: h2c · user-agent: $UA · x-via: none" "factories A: $u through the JDK client"; done
  has "$b" "  the requests: 3 · with an Accept header: 3 · with accept-encoding: 3 · with upgrade: 3 · with X-Via: 0" "factories A: three requests, h2c, accept-encoding"
  has "$b" '    | STUB-ANSWER 302 text/plain 5 bytes' "factories A: the stub's 302"
  has "$b" "$LOC" "factories: the locale"; has "$b" "$Z3" "factories: 0/0"; has "$b" "$SL" "factories: a fresh stub"; done
has "$FB" '    new its request factory: org.springframework.http.client.SimpleClientHttpRequestFactory' "factories B: SimpleClientHttpRequestFactory"
has "$FB" "    new getForObject /{f} meera.json -> $MEERA" "factories B: the row"; has "$FB" "    new getForEntity /redirect -> 200 $RAVI" "factories B: the redirect followed"
for u in /meera.json /redirect /ravi.json; do has "$FB" "    GET $u · accept: $JA · accept-encoding: none · upgrade: none · user-agent: Java/<version> · x-via: none" "factories B: $u through HttpURLConnection"; done
has "$FB" "  the requests: 3 · with an Accept header: 3 · with accept-encoding: 0 · with upgrade: 0 · with X-Via: 0" "factories B: no upgrade, no accept-encoding"
has "$FB" '    | STUB-ANSWER 302 text/plain 5 bytes' "factories B: the stub's 302"
has "$FB" "$LOC" "factories B: the locale"; has "$FB" "$Z3" "factories B: 0/0"; has "$FB" "$SL" "factories B: a fresh stub"
[ "$(printf '%s\n' "$FO" | grep -c '^    | STUB GET /redirect ')" = 3 ] && [ "$(printf '%s\n' "$FO" | grep -c '^    | STUB [A-Z]* ' | tr -d ' ')" = 9 ] && [ "$(printf '%s\n' "$FO" | grep '^    | STUB [A-Z]* ' | grep -vc '^    | STUB GET ' || true)" = 0 ] || die "factories: nine requests, every one a GET - the redirect was measured for GET only"
has "$FA2" "\$ $(hcp .harness/anchor 19563 probe.web.Templates --probe.cases=boot)" "factories A': its \$ line (S5.2)"
has "$FB" "\$ $(hcp .harness/anchor 19560 probe.web.Templates --probe.cases=new)" "factories B: its line"
has "$FO" "A' against A, its label aside, line for line the same: yes" "factories: A' = A"
case "$UAS" in 'Java-http-client/'[0-9]*' Java/'[0-9]*) ;; *) die "factories: the stub saw the two raw User-Agents (terminal: $UAS)" ;; esac
echo "  factories: A Boot's builder -> JdkClientHttpRequestFactory: Java-http-client, h2c, accept-encoding gzip and deflate; B new RestTemplate() -> SimpleClientHttpRequestFactory: Java/<version>, no upgrade, no accept-encoding; both followed /redirect (GET, 9 requests, all GET); A' = A, its \$ line shown"

# "an interceptor ... RestClient.create(template) and RestClient.builder(template): X-Via on both, the template's factory ... observed
# ... still no Accept ... create() of its own: none of it" - migrate
MO=$(cat .r-migrate.out)
has "$MO" "$SL" "migrate: the stub"; has "$MO" "$LOC" "migrate: the locale"; has "$MO" "$DONE" "migrate: done"
has "$MO" '    migrate the template: its interceptors [probe.web.Via] | its request factory org.springframework.http.client.InterceptingClientHttpRequestFactory' "migrate: the template's interceptor"
for k in 'RestClient.create(template)' 'RestClient.builder(template).build()'; do has "$MO" "    migrate $k: its interceptors [probe.web.Via] | its request factory org.springframework.http.client.JdkClientHttpRequestFactory" "migrate: $k keeps the interceptor and the factory"
  has "$MO" "    migrate $k, retrieve /{f} ravi.json -> $RAVI" "migrate: $k's row"; done
has "$MO" '    migrate RestClient.create(): its interceptors none | its request factory org.springframework.http.client.JdkClientHttpRequestFactory' "migrate: create() has no interceptor"
has "$MO" "    migrate the template, getForObject /{f} ravi.json -> $RAVI" "migrate: the template's row"
has "$MO" "    GET /ravi.json · accept: $JA · accept-encoding: gzip, deflate · upgrade: h2c · user-agent: $UA · x-via: template-interceptor" "migrate: the template's request"
[ "$(cnt "$MO" "    GET /ravi.json · accept: none · accept-encoding: gzip, deflate · upgrade: h2c · user-agent: $UA · x-via: template-interceptor")" = 2 ] || die "migrate: the two migrated requests - X-Via, no Accept"
has "$MO" "    GET /ravi.json · accept: none · accept-encoding: gzip, deflate · upgrade: h2c · user-agent: $UA · x-via: none" "migrate: create()'s request, no X-Via"
has "$MO" "  the requests: 4 · with an Accept header: 1 · with accept-encoding: 4 · with upgrade: 4 · with X-Via: 3" "migrate: 4 requests, X-Via 3, Accept 1"
[ "$(printf '%s\n' "$MO" | grep -c '^    | STUB-H x-via: template-interceptor$')" = 3 ] || die "migrate: the dump itself holds three X-Via lines"
has "$MO" '    http_client_requests_seconds_count{client_name="127.0.0.1",error="none",exception="none",method="GET",outcome="SUCCESS",status="200",uri="/{f}"} 3' "migrate: three observed under /{f} - the template and both migrated clients"
has "$MO" "  kept: 1 of the scrape's lines, by the filter ^http_client_requests_seconds_count, sorted · the others not shown: over 150 (their number moves from run to run: the JVM's own meters)" "migrate: kept 1"
[ "$(printf '%s\n' "$MO" | grep -c 'uri="/{name}"')" = 0 ] || die "migrate: create()'s call (/{name}) observed"
has "$MO" "$Z3" "migrate: 0/0"
has "$MO" "  the stub: stopped by its pid · exit 143 · listening on 19566 now: 0 · requests in its dump: 4 · the demo token 0 times · X-Shutdown-Token 0 times" "migrate: four requests, 0 tokens"
grep -qF 'RestClient fromCreate = RestClient.create(t);' harness/probe/web/Templates.java && grep -qF 'RestClient fromBuilder = RestClient.builder(t).build();' harness/probe/web/Templates.java && grep -qF 'RestClient plain = RestClient.create();' harness/probe/web/Templates.java || die "migrate: the three clients are create(template), builder(template).build() and create()"
echo "  migrate: the template (Via) -> X-Via, Accept; RestClient.create(template) and RestClient.builder(template) -> X-Via on both, JdkClientHttpRequestFactory, no Accept; RestClient.create() -> none; one scrape: /{f} 3, /{name} absent"

# "who still names it: spring-web, Boot's own modules, a converter class itself deprecated since four point oh, the test helpers ...
# TiffinBox: nothing" - who
WO=$(cat .r-who.out)
has "$WO" "\$ $L_WHO" "who: its line"
has "$WO" '  tiffinbox-web-1.0.0.jar · class files: 11 · naming it: 0' "who: TiffinBox's web jar, 0"
has "$WO" '  tiffinbox-core-1.0.0.jar · class files: 9 · naming it: 0' "who: TiffinBox's core jar, 0"
has "$WO" '  spring-web-7.0.9.jar · class files: 1325 · naming it: 9' "who: spring-web 9"
has "$WO" '  spring-boot-http-converter-4.1.1.jar · class files: 45 · naming it: 1' "who: spring-boot-http-converter 1"
has "$WO" '      org.springframework.boot.http.converter.autoconfigure.HttpMessageConverters' "who: HttpMessageConverters"
has "$WO" '  spring-boot-restclient-4.1.1.jar · class files: 29 · naming it: 6' "who: spring-boot-restclient 6"
has "$WO" '  jars where no class file names it: 59 (not listed)' "who: 59 jars, none (counted cut)"
has "$WO" '  jars read: 64 · class files read: 16587 · naming org.springframework.web.client.RestTemplate: 16' "who: 64 jars, 16 class files"
has "$WO" '  spring-boot-resttestclient-4.1.1.jar · class files: 19 · naming it: 1' "who: spring-boot-resttestclient 1"
has "$WO" '      org.springframework.boot.resttestclient.TestRestTemplate' "who: TestRestTemplate"
has "$WO" '  spring-test-7.0.9.jar · class files: 658 · naming it: 2' "who: spring-test 2"
has "$WO" '      org.springframework.test.web.client.MockRestServiceServer' "who: MockRestServiceServer"
has "$WO" '  org.springframework.boot.http.converter.autoconfigure.HttpMessageConverters · javap: 1149 lines · members: 19 · Deprecated attributes: on the class 1, on members 0 · the class (@Deprecated(since="4.0.0"))' "who: HttpMessageConverters, @Deprecated(since = 4.0.0)"
has "$WO" '  org.springframework.boot.resttestclient.TestRestTemplate · javap: 2643 lines · members: 63 · Deprecated attributes: on the class 0, on members 0' "who: TestRestTemplate, the class not deprecated"
has "$WO" '  class files read: 7 · Deprecated attributes in all: 0' "who: MockRestServiceServer, 0"
has "$WO" '  files that name it: under anchor/ 0 · under harness/ 2' "who: TiffinBox's sources 0, the harness's 2 (the grep can find it)"
[ "$(printf '%s\n' "$WO" | awk -F'naming it: ' '/ · naming it: / { s += $2 } END { print s + 0 }')" = 19 ] || die "who: the per-jar counts add up to 16 + 3"
echo "  who: 64 jars, 16587 class files, 16 name RestTemplate - spring-web 9, spring-boot-restclient 6, HttpMessageConverters 1 (itself @Deprecated(since=\"4.0.0\")); TiffinBox's 2 jars 0, its sources 0; the test modules: TestRestTemplate 1, MockRestServiceServer 2"

# the exercise's files as shipped (read again here, so a check that the exercise capture makes cannot be skipped)
XR=$(block exercise/README.md); XL=$(block exercise/solution/SOLUTION.md)
[ "$(printf '%s\n' "$XL" | grep -c .)" = 4 ] && [ "$(printf '%s\n' "$XL" | sed -n 1,2p)" = "$(printf '%s\n' "$XR" | sed -n 1,2p)" ] && [ "$(printf '%s\n' "$XL" | sed -n 3p)" = "$SOLL" ] && [ "$(printf '%s\n' "$XL" | sed -n 4p)" = "$(printf '%s\n' "$XR" | tail -1)" ] || die "exercise: SOLUTION.md is the README's exports, the one sed line, the README's last line"
XS=$(blk exercise "the README's" "the solution's"); XE=$(blk exercise "the solution's" '')
l='the old call: 200 · the moved call: 200 · requests at the stub with X-Via: 2 of 2 · observed calls: 2'; l0='the old call: 200 · the moved call: 200 · requests at the stub with X-Via: 1 of 2 · observed calls: 1'
has "$XE" "    $l" "exercise: the solution"; has "$XS" "    $l0" "exercise: as shipped"
awk '/^\*\*Done\*\*/ { f = 1 } f' exercise/README.md | grep -qxF -- "$l" || die "exercise/README.md: Done names no such line"
grep -qxF -- "$l" exercise/solution/SOLUTION.md || die "SOLUTION.md: the measured run shows no such line"
grep -qF -- "\`$l0\`" exercise/README.md || die "exercise/README.md: the shipped line's answer is not named"
has "$XS" '  exit 0 · what they printed:' "exercise: the README's commands, exit 0"; has "$XE" '  exit 0 · what they printed:' "exercise: the solution's lines, exit 0"
has "$XS" '  the moved call in the route'"'"'s copy (.harness/mine/src/TemplateRoutes.java): 26:        this.moved = RestClient.create();' "exercise: shipped with create()"
has "$XE" '  the moved call in the route'"'"'s copy: 26:        this.moved = RestClient.create(template);' "exercise: the solution's create(template)"
for b in "$XS" "$XE"; do has "$b" "  the shell is now in: this unit's folder · the JVM's locale in its log: en_US (TemplateRoutes), in the stub's: en_US · the copy's own token in its log: 0 times, in the stub's dump: 0 times · WARN lines in its log: 0 · ERROR lines: 0 · listening on 19564 now: 0 · on 19566: 0" "exercise: the shell, the locale, 0 tokens, 0/0, nothing left"; done
has "$XS" "    GET /ravi.json · accept: none · accept-encoding: gzip, deflate · upgrade: h2c · user-agent: $UA · x-via: none" "exercise: the moved call, no X-Via"
has "$XS" "  the requests: 2 · with an Accept header: 1 · with accept-encoding: 2 · with upgrade: 2 · with X-Via: 1" "exercise: shipped, X-Via 1 of 2"
has "$XE" "    GET /ravi.json · accept: none · accept-encoding: gzip, deflate · upgrade: h2c · user-agent: $UA · x-via: template-interceptor" "exercise: the moved call, X-Via, still no Accept"
has "$XE" "  the requests: 2 · with an Accept header: 1 · with accept-encoding: 2 · with upgrade: 2 · with X-Via: 2" "exercise: solved, X-Via 2 of 2"
[ "$(printf '%s\n' "$XE" | grep -c '^  \$ export ')" = 2 ] || die "exercise: SOLUTION.md gives the README's two export lines"
EXQ="Your turn: the README moved the old call to RestClient and lost its X-Via header. Build the client from the template, and call again."
grep -qxF -- "**Your turn:** ${EXQ#Your turn: }" exercise/README.md || die "exercise/README.md: the spoken exercise line"
[ "$(printf '%s\n' "$EXQ" | wc -w | tr -d ' ')" -le 25 ] || die "exercise: the spoken line is over 25 words"
echo "  exercise: one env -i shell - the README as written (RestClient.create()) -> $l0; the solution (RestClient.create(template)) -> $l; the shell in this unit's folder after each, 19564 and 19566 free"

[ -z "$unpub" ] || die "no published hash for:$unpub - check the captures, then copy the md5s above into receipts.md5 and run again"
echo "c6-unit27: every capture 3/3 and = published; every spoken number asserted; 0 raw demo tokens in every capture, every log and every stub dump"
