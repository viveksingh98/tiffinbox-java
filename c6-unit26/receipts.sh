#!/bin/bash
XPATH=$PATH                                           # the PATH you started this with: the exercise's own shell gets it
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25.0.4.1 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# Course 6 · HTTP Interface Clients: @HttpExchange - this unit's receipts. No anchor change: anchor/ is the link to
# ../c6-unit24/after, the tree the sessions lesson froze (= c6-tiffinbox at Section 4's end). This script copies that tree under
# .harness/anchor, builds it and runs it - as its README runs it, and on its class path with the two jars Boot's RestClient starter
# adds (harness/pom.xml, read by Maven's dependency:build-classpath) and the course's harness joined (harness/probe/web, outside
# com.tiffinbox): a payment client that is one Java interface (Payments) and no implementation, registered in a service group by one
# line (PaymentConfig). It calls the stub - a small stand-in server on this computer (harness/stub/Stub.java, the RestClient lesson's,
# copied byte for byte: the JDK's own HTTP server, one source file) that answers POST /payments and GET /payments/<id> and prints
# every request whole. And it processes a five-class application of its own ahead of time (harness/aot-app/), offline.
# Seven captures, each run three times and hashed; cap() DIES when a hash differs from receipts.md5; every number the video says is
# asserted at the bottom by a check that can fail; the demo token is masked (gsub), and the checks count 0 raw copies of it in every
# capture, in the log of every run, in the stub's dump of every run and in every file this unit ships.
#   interface  the anchor built and extracted (61 libraries); the harness POM's class path - the jars the anchor's lib/ lacks, by name,
#              each with its class count, the two that hold classes joined; the harness compiled; the stub against the RestClient
#              lesson's, md5 for md5; the interface, whole; the configuration's one line; the stub's own HttpExchange (the JDK's);
#              the owners, read off the jars; the seven on the jar, then on the harness line, the same, byte for byte
#   proxy      the two types named HttpExchange and the owners, read off the running JVM; the beans by name; what answers for the
#              interface - its class (the number masked), the JDK's test, Spring's, its interfaces, its invocation handler
#   calls      the stub started, its bind read off its pid; five calls through the interface - pay, payForEntity, find, find a
#              payment that is not there, pay nothing; the stub's dump of them, whole, and what the POSTs carried, counted
#   group      the group's keys, from Boot's own metadata and the class it binds; the group's read timeout, one second, against the
#              stub's three-second answer: cancelled; one scrape of /actuator/prometheus; C (labelled) no timeout key: answered
#   aot        C (labelled): the five-class app built offline with Boot's process-aot; the generated bean definition; the hints it
#              wrote; run on the JVM, then with -Dspring.aot.enabled=true - each against the stub
#   ways       who builds the proxy: A the group's (@ImportHttpServices), one pay, one scrape; B the same interface by hand
#              (HttpServiceProxyFactory over RestClient.create()), beside the group's, one scrape; A' = A - each a fresh JVM and a
#              fresh stub
#   exercise   exercise/README.md's commands, then exercise/solution/SOLUTION.md's, read from the files and run as written, one after
#              the other in ONE shell a viewer could have: env -i, /bin/bash, started in this folder
# "The anchor" is anchor/, the link to ../c6-unit24/after, COPIED under .harness/anchor; this script never writes into another unit's
# folder, and never builds a frozen tree in place (nor harness/aot-app: it is copied to .harness/aot first). Every run of TiffinBox
# starts in .harness/anchor, which holds a config tree with a fake token (secrets/), as the README asks. Commands are printed exactly
# as they run: each goes through eval. "$CURLSET" is the comparison set since the secrets lesson (../c5-unit11/curlset.sh: the seven
# requests, POST /shutdown with the token's header read from the file). "$M2" is this unit's own repository, .m2-demo. "$S25" is the
# RestClient lesson's stub folder (../c6-unit25/harness/stub), read, never written. The harness - harness/probe/web (compiled with
# -parameters: @PathVariable String id is named by its parameter): Payments (the interface: Spring's @HttpExchange, @PostExchange,
# @GetExchange), Charge and Payment (records), PaymentConfig (@ImportHttpServices: the group "payments"), Pays (an ApplicationRunner:
# the cases --probe.cases names, one PAY line each), PayRoutes (GET /probe/pay, a route that pays through the interface) - is the
# course's, never TiffinBox's: outside com.tiffinbox, joined by --spring.main.sources on the extracted jar's class path, and named on
# every capture that uses it; harness/pom.xml names Boot's RestClient starter for dependency:build-classpath (R.26); harness/stub/ is
# the RestClient lesson's stub, byte for byte; harness/aot-app/ is the five-class app (its own POM); harness/hints.py reads the hints
# file process-aot writes; harness/keys.py reads a jar's configuration metadata (the upload lesson's, byte for byte); harness/meta.py is
# the RestClient lesson's, byte for byte; harness/shutdown.sh is POST /shutdown with the token read from its file (the filters lesson's,
# byte for byte). Every run passes options only. The seven run first, on a fresh JVM of the jar.
# The locale: the JVM ignores LC_ALL on macOS - it takes the Mac's first language - and Spring's, Jackson's and Tomcat's messages in
# the log and in the answers are written in the JVM's locale: so every JVM this script starts - TiffinBox, the stub and the AOT app -
# has its locale pinned on its run line (-Duser.language=en -Duser.country=US, right after java), every one prints it, and the checks
# assert en_US.
# The network: every Maven build runs offline (-o) against .m2-demo and says so ("offline: yes"); a build that cannot resolve an
# artifact offline goes to Maven Central once, and says that ("offline: no - ..."). No native build, no Docker and no browser: this
# unit measures the JVM alone, with curl and the stub. At run time nothing leaves 127.0.0.1: TiffinBox and the stub listen there,
# every request goes there, the AOT app listens nowhere, and Logback writes to the terminal only.
# Masks and filters (README.md declares each; awk sub/gsub only): the demo token becomes "[masked: the N-character token]" (N its
# own length); this folder's absolute path "…", the folder above it "…/..", the home folder "~"; your user name "<user>" - in every
# line of every capture. The JDK's version in the client's User-Agent becomes "<version>" (printed once on the terminal, R.136). The
# number in a JDK proxy's class name ($Proxy84) becomes "$Proxy<n>" - it moves with the class path (printed once on the terminal), and
# so does CGLIB's ($$SpringCGLIB$$<n>). Spring's error timestamp becomes "…" (both forms) in the seven and wherever an answer is
# printed. A run's log lines are printed from their logger on (no time, no process id, no thread); Boot's first line is cut before
# " with PID". A WARN or ERROR record is printed as its level, logger and message, then the exception line under it; its stack frames
# are bounded ("over 40") and its other lines counted, never shown. The stub's dump is printed whole where a capture reads what a
# client sent (calls), and elsewhere as one line per request with its header count; where a call is cancelled the stub's answers are
# cut (when one lands is timing). A scrape of /actuator/prometheus is kept to ^http_client_requests_seconds_count, sorted, the kept
# lines counted. No duration is captured: a timeout is judged by the call's outcome - answered or cancelled - against a stub that
# waits three times the timeout.
# Ports (brief ⚑1, 19550-19559): TiffinBox 19550-19554 (one JVM at a time), the stub 19556, 19559 never bound (asserted free); the AOT
# app has no server and no port; 19555, 19557, 19558 unused. Captures run one after another, each JVM and each stub stopped before
# the next starts. 18425 (TiffinBox's default), 8080 (Tomcat's) and 35729 (DevTools' Live Reload) are checked free too, and never bound.
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
# On every exit - the end, a failed check, or Ctrl-C - stop the processes this script started in the background ($pid, TiffinBox or
# the AOT app; $spid, the stub; $xpid, the exercise's shell, with every process under it - its Maven, its JVMs, its curl), if they
# still run, then sweep(): anything of this run still alive in its process group - a TiffinBox JVM, an AOT app, a stub, a Maven - is
# stopped. After an interrupt, a capture's unfinished runs (.r-NAME.1-3) go too; after a failed check they stay, for the diff the
# message names. The clean-up ignores a second Ctrl-C, and nothing in it can fail under set -e, so it always reaches the rmdir; the
# script still exits 130 after an interrupt (README.md, "Interrupted"). $pid, $spid and $xpid are cleared whenever their process has
# been reaped. sweep() kills only processes of this run's own process group - start each run in a group of its own (README.md,
# "Interrupted"). No wait in this script is bare: each names its pid.
pid=""; spid=""; xpid=""
sweep() { local g i l
  g=$(ps -o pgid= -p $$ 2> /dev/null | tr -d ' ') || g=""
  [ -n "$g" ] || return 0
  i=0; while [ $i -lt 20 ]; do
    l=$(ps -axo pid=,pgid=,command= 2> /dev/null | awk -v g="$g" -v me=$$ '
      $2 == g && $1 != me && $3 != "awk" && $3 != "ps" && (index($0, "tiffinbox-web-1.0.0.jar") || index($0, "com.tiffinbox.web.TiffinBoxServer") || index($0, "stub/Stub.java") || index($0, "aot-app-1.0.0.jar") || index($0, "org.codehaus.plexus.classworlds.launcher.Launcher")) { print $1 }' | paste -sd' ' -) || l=""
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
for t in python3 curl rsync lsof unzip javac javap mvn cmp md5; do command -v $t > /dev/null || die "$t is needed"; done
# A variable of yours must not become a property source, a JVM flag or a build setting: every TIFFINBOX_*, SPRING_*, MANAGEMENT_*,
# SERVER_* and LOGGING_* variable, DEBUG (Boot reads it as --debug), the variables that inject JVM flags, MAVEN_OPTS, MAVEN_ARGS and
# NATIVE_IMAGE_OPTIONS are removed first (the last course's failure lesson's loop, verbatim: sed -E, a canary planted under every
# name first, and the run stops if one survives). This unit runs no Docker, so COMPOSE_* is not in the list. (A
# SPRING_HTTP_SERVICECLIENT_PAYMENTS_BASEURL of yours would point the group somewhere this unit never named; a JAVA_TOOL_OPTIONS could
# set every JVM's locale.)
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
TOKEN=demo-token-for-an-http-interface
[ ${#TOKEN} = 32 ] || die "the demo token must be 32 characters: the published captures name its length"
CURLSET=../c5-unit11/curlset.sh                      # the comparison set: the seven requests, POST /shutdown with the header
[ -f "$CURLSET" ] || die "$CURLSET is missing"
S25=../c6-unit25/harness/stub                        # the RestClient lesson's stub: read, never written
SMD5=42b656ddba1e9f80107495c65dacc975                # its Stub.java, as that lesson published it
WWW='customers.json meera.json priya.json ravi.json sunil.json'
HWS='harness/probe/web/Charge.java harness/probe/web/PayRoutes.java harness/probe/web/Payment.java harness/probe/web/PaymentConfig.java harness/probe/web/Payments.java harness/probe/web/Pays.java'
AWS='harness/aot-app/src/main/java/probe/aot/App.java harness/aot-app/src/main/java/probe/aot/Charge.java harness/aot-app/src/main/java/probe/aot/Payment.java harness/aot-app/src/main/java/probe/aot/PaymentConfig.java harness/aot-app/src/main/java/probe/aot/Payments.java'
for f in harness/pom.xml harness/aot-app/pom.xml harness/stub/Stub.java harness/shutdown.sh harness/keys.py harness/meta.py harness/hints.py $HWS $AWS exercise/README.md exercise/solution/SOLUTION.md README.md "$S25/Stub.java"; do [ -f "$f" ] || die "$f is missing"; done
[ "$(ls harness/probe/web | paste -sd' ' -)" = 'Charge.java PayRoutes.java Payment.java PaymentConfig.java Payments.java Pays.java' ] || die "harness/probe/web holds another file: javac compiles all of it"
[ "$(ls harness/aot-app/src/main/java/probe/aot | paste -sd' ' -)" = 'App.java Charge.java Payment.java PaymentConfig.java Payments.java' ] && [ "$(ls harness/aot-app | paste -sd' ' -)" = 'pom.xml src' ] || die "harness/aot-app must be its POM and its five classes, and nothing else (no target/: it is built from a copy)"
[ "$(ls harness/stub/www | paste -sd' ' -)" = "$WWW" ] && [ "$(ls "$S25/www" | paste -sd' ' -)" = "$WWW" ] || die "harness/stub/www must hold the RestClient lesson's five files, and nothing else"
[ "$(ls harness/stub | paste -sd' ' -)" = 'Stub.java www' ] || die "harness/stub holds another file"
[ "$(ls exercise/solution | paste -sd' ' -)" = 'SOLUTION.md' ] && [ "$(ls exercise | paste -sd' ' -)" = 'README.md solution' ] || die "exercise/ holds another file: the exercise is the README's commands, the solution a key"
[ ! -e harness/target ] || die "harness/target exists - dependency:build-classpath builds nothing; remove it"
# The stub is the RestClient lesson's, byte for byte - its md5 as that lesson published it (brief ⚑3: a read of a frozen folder)
[ "$(md5 -q harness/stub/Stub.java)" = "$SMD5" ] && [ "$(md5 -q "$S25/Stub.java")" = "$SMD5" ] || die "harness/stub/Stub.java must be the RestClient lesson's, md5 $SMD5"
for w in $WWW; do cmp -s "harness/stub/www/$w" "$S25/www/$w" || die "harness/stub/www/$w is not the RestClient lesson's, byte for byte"; done
cmp -s harness/shutdown.sh ../c6-unit18/harness/shutdown.sh || die "harness/shutdown.sh must be the filters lesson's, byte for byte"
cmp -s harness/keys.py ../c6-unit20/harness/keys.py || die "harness/keys.py must be the upload lesson's, byte for byte"
cmp -s harness/meta.py ../c6-unit25/harness/meta.py || die "harness/meta.py must be the RestClient lesson's, byte for byte"
# Boot 3's spelling of the client keys (the singular one) - built here, never written whole in this file: no file of this unit spells
# it (R.138)
K1='spring.http.client'; K1="$K1."
KB='--spring.http.serviceclient.payments.base-url=http://127.0.0.1:19556'

# The ports, BEFORE anything is wiped (a survivor of an interrupted run answers POST /shutdown only with its token, which lives in
# .harness/ - so the message names the process to kill).
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
for p in 18425 8080 35729 19550 19551 19552 19553 19554 19555 19556 19557 19558 19559; do
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
# lines with the JVM's locale pinned; the class-path line with the group's base URL, then with its read timeout too; the harness POM's
# class path; the harness's javac line; the stub's run line; md5 of the stub against the RestClient lesson's; the interface, the
# configuration's line and the stub's HttpExchange; the metadata reader and javap; the AOT app's build, its generated line, its hints,
# its two run lines; the scrape saved to a file
mine() { grep -m1 -xF -- "$1" README.md > /dev/null || die "README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
JL='-Duser.language=en -Duser.country=US'
LIBD=.harness/anchor/tiffinbox-web/target/extracted/lib
HTTPJ=.harness/xlib/spring-boot-http-client-4.1.1.jar
HINTF=target/spring-aot/main/resources/META-INF/native-image/probe.aot/aot-app/reachability-metadata.json
L_RUNL=$(mine "java $JL -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431")
L_CPL=$(mine "java $JL -cp $CPL")
L_BASE=$(mine "$L_CPL $KB")
L_RT=$(mine "$L_BASE --spring.http.serviceclient.payments.read-timeout=1s")
L_HCP=$(mine 'mvn -o -B -q -Dmaven.repo.local="$M2" -f harness/pom.xml dependency:build-classpath -Dmdep.outputFile="$PWD/.harness/harness.cp"')
L_JAVAC=$(mine "javac -parameters -d .harness/hc -cp \"$LIBD/*:.harness/xlib/*\" $HWS")
L_STUB=$(mine "java $JL harness/stub/Stub.java --port=19556 --www=harness/stub/www")
L_MD5=$(mine 'for f in Stub.java www/customers.json www/meera.json www/priya.json www/ravi.json www/sunil.json; do echo "$(md5 -q "harness/stub/$f") $(md5 -q "$S25/$f") $f"; done')
L_SRC=$(mine "sed -n '/^@HttpExchange/,\$p' harness/probe/web/Payments.java")
L_CONF=$(mine "grep -n '^@' harness/probe/web/PaymentConfig.java")
L_JDKX=$(mine "grep -n 'HttpExchange' harness/stub/Stub.java")
L_KEYS=$(mine "python3 harness/keys.py $HTTPJ spring.http.serviceclient")
L_JAVAP=$(mine "javap -cp $HTTPJ org.springframework.boot.http.client.autoconfigure.HttpClientProperties org.springframework.boot.http.client.autoconfigure.HttpClientSettingsProperties")
L_AOTB=$(mine 'mvn -o -B -Dmaven.repo.local="$M2" clean package')
L_GEN=$(mine "grep -n 'getClient' target/spring-aot/main/sources/probe/aot/Payments__BeanDefinitions.java")
L_HINTS=$(mine "python3 ../../harness/hints.py $HINTF probe.aot.Charge probe.aot.Payment probe.aot.Payments")
L_AJVM=$(mine "java $JL -jar target/aot-app-1.0.0.jar $KB")
L_AAOT=$(mine "java $JL -Dspring.aot.enabled=true -jar target/aot-app-1.0.0.jar $KB")
L_PROM=$(mine "curl -s -o .harness/prom.txt -w ' %{http_code}\n' http://127.0.0.1:18431/actuator/prometheus")
# The derivations, each asserted
P_='java '; Q_="java $JL "; r=${R_RUN/"$P_"/$Q_}; r2=${R_CP/"$P_"/$Q_}
[ "$r" = "$L_RUNL" ] && [ "$r2" = "$L_CPL" ] || die "the pinned lines must be the anchor's run and class-path lines with $JL after java, and nothing else"
O_B=${L_BASE#"$L_CPL "}; O_RT=${L_RT#"$L_CPL "}
[ "$O_B" = "$KB" ] && [ "$O_RT" = "$KB --spring.http.serviceclient.payments.read-timeout=1s" ] || die "the group's lines must be the pinned class-path line with the group's keys as options, and nothing else"
[ "${L_JAVAC#* -cp \"*\" }" = "$HWS" ] || die "the harness's javac line must compile the six files in harness/probe/web, and nothing else"
[ "${L_AAOT/ -Dspring.aot.enabled=true / }" = "$L_AJVM" ] || die "the AOT run line must be the JVM run line with -Dspring.aot.enabled=true, and nothing else"
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
[ "$(exe "$(at .harness/x 19550 "$R_RUN")")" = "cd .harness/x && exec ${L_RUNL/18431/19550}" ] && [ "$(at .harness/x 18431 "$R_CP")" = "cd .harness/x && $L_CPL" ] && [ "$(at .harness/x 18431 "$R_EXTRACT")" = "cd .harness/x && $R_EXTRACT" ] || die "at(): the pinned lines are not README.md's"
[ "$(hcp .harness/x 19553 probe.web.PaymentConfig,probe.web.Pays "--probe.cases=calls $O_B")" = 'cd .harness/x && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../xlib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19553 --spring.main.sources=probe.web.PaymentConfig,probe.web.Pays --probe.cases=calls --spring.http.serviceclient.payments.base-url=http://127.0.0.1:19556' ] || die "hcp()"
echo "  the commands: anchor/README.md gives the 5 lines this script runs or derives from; README.md the 19 this unit adds"

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
rsync -a harness/aot-app/ .harness/aot-pre/
mbuild "cd .harness/aot-pre && $L_AOTB" .harness/aot-pre.log ".harness/aot-pre (the AOT app)"
[ ! -e harness/target ] && [ ! -e harness/aot-app/target ] || die "a build wrote harness/target or harness/aot-app/target"
for a in spring-boot-restclient spring-boot-http-client spring-boot-starter-restclient; do
  [ -f "$M2/org/springframework/boot/$a/4.1.1/$a-4.1.1.jar" ] || die "$a 4.1.1 is not in .m2-demo after the first builds"; done
[ ! -e "$M2/org/apache/httpcomponents/client5/httpclient5" ] || [ -z "$(grep -F httpclient5 .harness/harness.cp || true)" ] || die "httpclient5 is on the harness's class path - every factory sentence would change"
echo "  .m2-demo holds Boot's RestClient starter and the two jars it brings, 4.1.1, and everything the AOT app's build needs"


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
  case " $l " in *':8080 '*|*':35729 '*|*':19559 '*) kill -9 "$pid" 2> /dev/null || true; die "it listened on 8080, 35729 or 19559 - never bound by this script";; esac
  echo "  listens on: $l · loopback only: $(lb "$l")"; echo "  Boot's first line: $(first .harness/run.out)"; }
# ready PORT: readiness asked until it answers 200 - every 0.25 s, up to 120 s, not printed - then the README's readiness line,
# printed and run once. No assertion before it (R.41, R.75). A JVM ($pid) that exits first stops the run. (The harness's Pays runs
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
# read off its pid (polled until it listens on 19556, up to 120 s - it compiles itself first), and the locale it printed. sstop: the
# stub stopped by its pid (TERM: it has no shutdown route), waited for, 19556 free; its dump counted - the demo token 0 times and the
# header X-Shutdown-Token 0 times (R.137) - and how many requests it printed. Every start begins a new dump (and the stub's payment
# numbers start again at pay-1).
sstart() { local l; echo "\$ $L_STUB"; (eval "exec $L_STUB") > .harness/stub.out 2>&1 < /dev/null & spid=$!
  l=$(listening "$spid" 19556); [ "$l" != nothing ] || { tail -20 .harness/stub.out >&3; die "the stub never listened"; }
  echo "  the stub listens on: $l · loopback only: $(lb "$l") · its locale: $(grep -m1 "^STUB the JVM's locale: " .harness/stub.out | sed "s/^.*locale: //")"; }
sstop() { local e=0 t h n
  kill "$spid" 2> /dev/null || true; wait "$spid" || e=$?; spid=""
  [ "$(listeners 19556)" = 0 ] || die "something still listens on 19556"
  t=$(raw "$TOKEN" .harness/stub.out); h=$(LC_ALL=C grep -aoi -- 'x-shutdown-token' .harness/stub.out | wc -l | tr -d ' '); n=$(grep -c '^STUB [A-Z]* /' .harness/stub.out || true)
  DUMPS=$((DUMPS + 1)); [ "$t" = 0 ] && [ "$h" = 0 ] || die "the stub's dump held the demo token ($t) or its header's name ($h)"
  echo "  the stub: stopped by its pid · exit $e · listening on 19556 now: 0 · requests in its dump: $n · the demo token 0 times · X-Shutdown-Token $h times"
  [ -z "$(grep -m1 '^STUB-H user-agent: ' .harness/stub.out)" ] || grep -m1 '^STUB-H user-agent: ' .harness/stub.out | sed 's/^STUB-H user-agent: //' > .harness/ua.txt; }
mask() { awk -v t="$TOKEN" -v u="$U" -v up="$UP" -v hm="$HOME" -v me="$ME" -v tl="${#TOKEN}" '
  function lit(x) { gsub(/[][\\.^$*+?(){}|\/]/, "\\\\&", x); return x }
  function enc(x) { gsub(/ /, "%20", x); return x }
  BEGIN { T = lit(t); P = lit(u); Q = lit(up); H = lit(hm); PE = lit(enc(u)); QE = lit(enc(up)); M = "(^|[^A-Za-z0-9_])" lit(me) "([^A-Za-z0-9_]|$)" }
  { gsub(T, "[masked: the " tl "-character token]"); gsub(P, "…"); gsub(PE, "…")
    gsub(Q, "…/.."); gsub(QE, "…/.."); gsub(H, "~"); gsub(/\$\$SpringCGLIB\$\$[0-9]+/, "$$SpringCGLIB$$<n>")
    gsub(/\$Proxy[0-9]+/, "$Proxy<n>")
    gsub(/Java-http-client\/[0-9][0-9.]*/, "Java-http-client/<version>")
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
  /^(PAY|ROUTE|AOT) / { next }
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
# pays: the harness's PAY lines (Pays), in the order they printed, whole - after its "done" line, which must be there
pays() { grep -q '^PAY done$' .harness/run.out || { tail -20 .harness/run.out >&3; die "the harness's Pays never printed done"; }
  echo "  the harness's lines (Pays), in the order they printed: $(grep -c '^PAY ' .harness/run.out)"; grep '^PAY ' .harness/run.out | sed 's/^PAY /    /'; }
loc() { echo "  the JVM's locale (the harness's Pays): $(grep -m1 "^PAY the JVM's locale: " .harness/run.out | sed "s/^.*locale: //")"; }
# The stub's dump. sdump FROM: every line it printed after line FROM, whole, each after a "|" (the requests, every header, every
# body, every answer); sreqs FROM: one line per request after line FROM - its method and URI, its header count, and the stub's answer
# (the line after its headers and body); sonly FROM: one line per request after line FROM, its method and URI and its header count -
# the answers cut: after a client cancelled, the stub's answer lands when its wait ends, and where that line falls in the dump is
# timing (R.121)
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
{ printf '%s\n' 'PAY calls find pay-99 -> org.springframework.web.client.HttpClientErrorException$NotFound | status 404 | message: ERROR' '2026-10-22T00:00:00.000+02:00  WARN 1 --- [planted] o.s.web.servlet.PageNotFound             : planted warning' '2026-10-22T00:00:00.001+02:00 ERROR 1 --- [planted] o.a.c.c.C.[.[.[/].[dispatcherServlet]    : planted error' 'java.lang.IllegalStateException: planted' "$(printf '\tat a')" 'PAY done'; } > .harness/run.out
[ "$(logl 0 ERROR | grep -c .)" = 1 ] && [ "$(logl 0 WARN | grep -c .)" = 1 ] && [ "$(lvl ERROR .harness/run.out)" = 1 ] && [ "$(lvl WARN .harness/run.out)" = 1 ] && [ "$(grep -c ' ERROR' .harness/run.out)" = 2 ] || die "the level counts: the planted log must give 1 WARN and 1 ERROR by line shape (a bare ' ERROR' gives 2)"
[ "$(recs 0)" = "$(printf '%s\n' '    WARN o.s.web.servlet.PageNotFound: planted warning' '      its stack frames: 0, its other lines: 0 - none shown' '    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: planted error' '      java.lang.IllegalStateException: planted' '      its stack frames: 1, its other lines: 0 - none shown')" ] || die "recs: the planted log's harness lines must be skipped (.harness/run.out)"
printf '%s\n' 'STUB listening on /127.0.0.1:19556' 'STUB POST /payments headers=[Content-type, Host]' 'STUB-H content-type: application/json' 'STUB-H host: 127.0.0.1:19556' 'STUB-BODY {"customer":"Ravi","amount":7200}' 'STUB-ANSWER 201 application/json 62 bytes' 'STUB GET /payments/slow headers=[Host]' 'STUB-H host: 127.0.0.1:19556' 'STUB GET /payments/pay-1 headers=[Accept-encoding, Host]' 'STUB-H accept-encoding: gzip' 'STUB-H accept-encoding: deflate' 'STUB-H host: 127.0.0.1:19556' 'STUB-ANSWER 200 application/json 62 bytes' 'STUB-ANSWER 200 application/json 13 bytes' > .harness/stub.out
PL=$(sreqs 1); [ "$PL" = "$(printf '%s\n' '    POST /payments · headers: 2 · the stub answered 201 application/json 62 bytes' '    GET /payments/slow · headers: 1 · no answer' '    GET /payments/pay-1 · headers: 3 · the stub answered 200 application/json 62 bytes' '    a late answer, its request above: 200 application/json 13 bytes')" ] || die "sreqs: the planted dump does not come out as declared (got: $PL)"
PL=$(sonly 1); [ "$PL" = "$(printf '%s\n' '    POST /payments · headers: 2' '    GET /payments/slow · headers: 1' '    GET /payments/pay-1 · headers: 3' '    its answers: cut - after a cancelled call, where its answer lands in the dump is timing')" ] || die "sonly: the planted dump does not come out as declared (got: $PL)"
PL=$(sdump 1); [ "$(printf '%s\n' "$PL" | sed -n 1p)" = "  the stub's dump since, whole: 13 lines" ] && [ "$(printf '%s\n' "$PL" | grep -c '^    | STUB-H accept-encoding: ')" = 2 ] && [ "$(printf '%s\n' "$PL" | grep -c '^    | STUB-BODY ')" = 1 ] || die "sdump: the planted dump must come out whole, a header given twice as two lines, its body kept"
printf '%s\n' '# HELP x' 'http_client_requests_seconds_count{uri="/payments/{id}"} 2' 'jvm_threads_live_threads 30' 'http_client_requests_seconds_count{uri="/payments"} 1' > .harness/p1
PL=$(promf .harness/p1); [ "$PL" = "$(printf '%s\n' '  kept: 2 of the scrape'"'"'s lines, by the filter ^http_client_requests_seconds_count, sorted · the others not shown: 2' '    http_client_requests_seconds_count{uri="/payments"} 1' '    http_client_requests_seconds_count{uri="/payments/{id}"} 2')" ] || die "promf: the planted scrape does not come out as declared (got: $PL)"
printf '%s\n' 'Java-http-client/25.0.4.1 and Java-http-client/23' 'jdk.proxy2.$Proxy84 and jdk.proxy3.$Proxy7 and App$$SpringCGLIB$$0' "$TOKEN" > .harness/p1
[ "$(mask < .harness/p1)" = "$(printf '%s\n' 'Java-http-client/<version> and Java-http-client/<version>' 'jdk.proxy2.$Proxy<n> and jdk.proxy3.$Proxy<n> and App$$SpringCGLIB$$<n>' '[masked: the 32-character token]')" ] || die "mask: the planted User-Agent versions, proxy numbers and token must be masked"
rm -f .harness/run.out .harness/stub.out .harness/p1
echo "  the filters: the record filter, the stub's dump filters, the scrape filter and the masks print their planted inputs as declared; a harness line that says ERROR is no ERROR line; a header given twice is two lines"

# ---- interface: what joins - the anchor, the starter's jars, the harness, the stub, the interface, the seven ----------------------
interface() { local c
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
  echo "the stub - this folder's copy against the RestClient lesson's (\$S25), md5 for md5 (this unit's line):"
  echo "\$ $L_MD5"; (eval "$L_MD5") 2>&1 < /dev/null | sed 's/^/  /'
  echo "  the same md5, file by file: $(for f in Stub.java $(for w in $WWW; do echo "www/$w"; done); do [ "$(md5 -q "harness/stub/$f")" = "$(md5 -q "$S25/$f")" ] && echo x; done | grep -c . || true) of 6 · routes this unit adds to it: 0"
  echo "the interface - the whole of it, from its annotation on (this unit's line):"
  echo "\$ $L_SRC"; (eval "$L_SRC") 2>&1 < /dev/null | sed 's/^/  /'
  echo "  its methods: $(grep -cE '^    [A-Za-z<>]+ [a-zA-Z]+\(' harness/probe/web/Payments.java) · a class in harness/ that implements it: $(grep -lE 'implements[^{]*Payments' $HWS 2> /dev/null | grep -c . || true)"
  echo "the configuration - its annotations (this unit's line):"
  echo "\$ $L_CONF"; (eval "$L_CONF") 2>&1 < /dev/null | sed 's/^/  /'
  echo "the stub's own HttpExchange - the JDK server's type, in the stub's code (this unit's line):"
  echo "\$ $L_JDKX"; (eval "$L_JDKX") 2>&1 < /dev/null | sed 's/^/  /'
  echo "whose classes - each read off the one jar on that class path that holds it (unzip -l, by name):"
  for c in org/springframework/web/service/annotation/HttpExchange org/springframework/web/service/registry/ImportHttpServices org/springframework/web/service/invoker/HttpServiceProxyFactory org/springframework/web/client/support/RestClientAdapter org/springframework/boot/restclient/autoconfigure/service/HttpServiceClientAutoConfiguration org/springframework/boot/http/client/autoconfigure/service/HttpServiceClientProperties; do
    echo "  $(printf '%s' "$c" | tr / .) · in: $(for j in "$LIBD"/*.jar .harness/xlib/*.jar; do unzip -l "$j" "$c.class" > /dev/null 2>&1 && echo "${j##*/}"; done | paste -sd' ' -)"; done
  echo "the seven - the anchor, the README's run line (its locale pinned), port 19550, a fresh JVM:"
  start "$(at .harness/anchor 19550 "$R_RUN")"; up 19550; ready 19550; seven 19550 .harness/anchor; WARNS; logl 0 WARN
  echo "the seven - the anchor on its class path, the two jars and the harness joined (PaymentConfig, Pays, PayRoutes; the group's base URL; no cases), port 19551, a fresh JVM:"
  start "$(hcp .harness/anchor 19551 probe.web.PaymentConfig,probe.web.Pays,probe.web.PayRoutes "$O_B")"; up 19551; ready 19551; seven 19551 .harness/anchor; WARNS; logl 0 WARN
  echo "the lines that moved - the README's run line's seven against the harness line's, masked, line for line:"
  python3 - .harness/seven-19550.txt .harness/seven-19551.txt <<'PY'
import sys
a = open(sys.argv[1], encoding="utf-8").read().splitlines(); b = open(sys.argv[2], encoding="utf-8").read().splitlines()
d = [i for i in range(max(len(a), len(b))) if i >= len(a) or i >= len(b) or a[i] != b[i]]
s = [i for i in range(min(len(a), len(b))) if a[i] == b[i]]
print("  lines that differ: %d%s · the same, byte for byte: %d (%s)" % (len(d), (" (" + " ".join(str(i + 1) for i in d) + ")") if d else "", len(s), " ".join(str(i + 1) for i in s)))
PY
}

# ---- proxy: who implements it ---------------------------------------------------------------------------------------------------
proxy() {
  echo "who answers for the interface - the anchor on its class path, the two jars and the harness joined (PaymentConfig, Pays), the group's base URL, the cases types, beans and proxy, port 19552, a fresh JVM (no stub: no case calls one):"
  start "$(hcp .harness/anchor 19552 probe.web.PaymentConfig,probe.web.Pays "--probe.cases=types,beans,proxy $O_B")"; up 19552; ready 19552; loc; pays
  grep -m1 '^PAY proxy class: ' .harness/run.out | sed 's/^PAY proxy class: //; s/ |.*$//' > .harness/proxyn.txt
  WARNS; stop 19552 .harness/anchor; }

# ---- calls: five calls through the interface, and what the stub saw -----------------------------------------------------------
calls() { local s0
  echo "the stub - this unit's line, port 19556:"
  sstart
  echo "the calls - the anchor on its class path, the two jars and the harness joined (PaymentConfig, Pays), the group's base URL, the case calls, port 19553, a fresh JVM:"
  s0=$(smark); start "$(hcp .harness/anchor 19553 probe.web.PaymentConfig,probe.web.Pays "--probe.cases=calls $O_B")"; up 19553; ready 19553; loc; pays
  echo "what the client sent, and what the stub answered - the stub's dump of the five calls:"
  sdump "$s0"
  awk -v f="$s0" 'NR <= f { next } /^STUB [A-Z]+ \// { n++; m = $2; if (m == "POST") p++; next } /^STUB-H accept: / { a++ } m == "POST" && /^STUB-H content-type: application\/json$/ { j++ } m == "POST" && /^STUB-H transfer-encoding: chunked$/ { c++ } /^STUB-H content-length: / { l++ } /^STUB-BODY / { b++ }
    END { print "  the requests: " n + 0 " · POSTs: " p + 0 " · POSTs with content-type: application/json: " j + 0 " · with transfer-encoding: chunked: " c + 0 " · requests with a content-length header: " l + 0 " · with an Accept header: " a + 0 " · bodies: " b + 0 }' .harness/stub.out
  WARNS; stop 19553 .harness/anchor
  sstop; }

# ---- group: the group's own keys, its read timeout, its observations --------------------------------------------------------------
group() { local s0
  echo "the group's keys - what Boot's own metadata declares (in spring-boot-http-client-4.1.1.jar, one of the two jars the starter adds), and the class each group binds to (this unit's lines):"
  echo "\$ $L_KEYS"; (eval "$L_KEYS") 2>&1 < /dev/null | sed 's/^/  /'
  echo "\$ $L_JAVAP"; (eval "$L_JAVAP") > .harness/javap.out 2>&1 < /dev/null || die "javap could not read the two classes"
  echo "  what javap printed: $(wc -l < .harness/javap.out | tr -d ' ') lines · kept: its two class lines and their setters, $(grep -cE '(^public|^  public void set)' .harness/javap.out) lines"
  grep -E '(^public|^  public void set)' .harness/javap.out | sed 's/^  public void /    set /; s/^public /  /; s/ {$//'
  echo "the stub - this unit's line, port 19556 (its /payments/slow answers after three seconds):"
  sstart; s0=$(smark)
  echo "the group's read timeout at one second - the anchor on its class path, the two jars and the harness joined (PaymentConfig, Pays), the cases calls and slow, port 19550, a fresh JVM:"
  start "$(hcp .harness/anchor 19550 probe.web.PaymentConfig,probe.web.Pays "--probe.cases=calls,slow $O_RT")"; up 19550; ready 19550; loc; pays
  echo "what was observed - one scrape of the same JVM's /actuator/prometheus (this unit's line):"
  scrape 19550
  WARNS; stop 19550 .harness/anchor
  echo "C (labelled) - the group's base URL alone, no timeout key, the case slow, port 19551, a fresh JVM:"
  start "$(hcp .harness/anchor 19551 probe.web.PaymentConfig,probe.web.Pays "--probe.cases=slow $O_B")"; up 19551; ready 19551; loc; pays
  WARNS; stop 19551 .harness/anchor
  echo "the requests the stub saw, one line a request:"; sonly "$s0"
  sstop; }

# ---- aot: C (labelled) - ahead of time, on the five-class app ----------------------------------------------------------------
# arun 'COMMAND' NAME: the AOT app's command, run from .harness/aot (no server, no port: it pays once and exits), waited for by its
# pid; its exit code, Boot's first line, its AOT lines, its WARN and ERROR counts, its log counted (logtok)
arun() { local e=0 c="cd .harness/aot && $1"; echo "\$ $c"; (eval "$(exe "$c")") > .harness/run.out 2> .harness/run.err < /dev/null & pid=$!
  wait "$pid" || e=$?; pid=""
  echo "  exit $e · Boot's first line: $(first .harness/run.out)"
  echo "  its lines (App), in the order they printed: $(grep -c '^AOT ' .harness/run.out)"; grep '^AOT ' .harness/run.out | sed 's/^AOT /    /'
  echo "  WARN lines in its log: $(logl 0 WARN | grep -c . || true) · ERROR lines: $(logl 0 ERROR | grep -c . || true) · server jars in its jar (Tomcat, Jetty, Undertow, Netty): $(unzip -l .harness/aot/target/aot-app-1.0.0.jar | grep -cE 'BOOT-INF/lib/(tomcat|jetty|undertow|netty)' || true) - it serves nothing, and listens nowhere"
  logtok; }
aot() { local n0 n1 s0
  echo "C (labelled) - ahead of time, on the aot app: harness/aot-app/, its own POM, five classes, Boot's RestClient starter, no web server (the anchor and the harness cannot be processed together: the harness joins TiffinBox only at run time):"
  echo "  its classes: $(cd harness/aot-app/src/main/java && find . -name '*.java' | sed 's#^\./##' | sort | paste -sd' ' -)"
  echo "  its interface's annotation and method lines, against the harness's without its slow method: the same: $( [ "$(grep -E '^(@HttpExchange|    @|    [A-Z])' harness/aot-app/src/main/java/probe/aot/Payments.java)" = "$(grep -E '^(@HttpExchange|    @|    [A-Z])' harness/probe/web/Payments.java | grep -v slow)" ] && echo yes || echo no) · its configuration's annotation lines, against the harness's: the same: $( [ "$(grep '^@' harness/aot-app/src/main/java/probe/aot/PaymentConfig.java)" = "$(grep '^@' harness/probe/web/PaymentConfig.java)" ] && echo yes || echo no)"
  rm -rf .harness/aot; rsync -a harness/aot-app/ .harness/aot/
  n0=$(find "$M2" -type f | wc -l | tr -d ' ')
  echo "built from a copy (.harness/aot), offline, its process-aot goal bound in its POM (this unit's line):"
  echo "\$ cd .harness/aot && $L_AOTB"; mbuild "cd .harness/aot && $L_AOTB" .harness/aot.build.log "the AOT app"
  n1=$(find "$M2" -type f | wc -l | tr -d ' ')
  echo "  files .m2-demo gained: $((n1 - n0)) · harness/aot-app/target: $([ -e harness/aot-app/target ] && echo there || echo absent) · process-aot ran: $(grep -c 'spring-boot:4.1.1:process-aot (process-aot)' .harness/aot.build.log)"
  echo "  the classes it generated for probe.aot (target/spring-aot/main/sources): $(cd .harness/aot/target/spring-aot/main/sources/probe/aot && ls | paste -sd' ' -)"
  echo "the generated bean definition - what builds the payments bean ahead of time (this unit's line):"
  echo "\$ cd .harness/aot && $L_GEN"; (cd .harness/aot && eval "$L_GEN") 2>&1 < /dev/null | sed 's/^ */  /'
  echo "the hints it wrote for a native image (this unit's line):"
  echo "\$ cd .harness/aot && $L_HINTS"; (cd .harness/aot && eval "$L_HINTS") 2>&1 < /dev/null | sed 's/^/  /'
  echo "the stub - this unit's line, port 19556:"
  sstart; s0=$(smark)
  echo "on the JVM - the app's jar, the group's base URL (this unit's line):"
  arun "$L_AJVM"
  echo "ahead of time - the same jar with -Dspring.aot.enabled=true: the generated code instead of the configuration classes (this unit's line):"
  arun "$L_AAOT"
  grep -m1 '^AOT proxy class: ' .harness/run.out | sed 's/^AOT proxy class: //; s/ |.*$//' > .harness/proxyn-aot.txt
  echo "  the stub's dump since, one line a request:"; sreqs "$s0"
  sstop; }

# ---- ways: who builds the proxy - A the group's, B by hand, A' = A -----------------------------------------------------------
wrun() { local s0
  sstart; s0=$(smark)
  start "$(hcp .harness/anchor "$1" probe.web.PaymentConfig,probe.web.Pays "--probe.cases=$2 $O_B")"; up "$1"; ready "$1"; loc; pays
  echo "  the stub's dump since, one line a request:"; sreqs "$s0"
  echo "  what was observed - one scrape of the same JVM's /actuator/prometheus (this unit's line):"; scrape "$1"
  WARNS; stop "$1" .harness/anchor; sstop; }
ways() {
  echo "  19559, never bound: listening $(listeners 19559) (lsof, by port)"
  echo "A - the group's client (@ImportHttpServices, Boot's builder underneath), the cases proxy and pay, a fresh stub, port 19552, a fresh JVM:"
  wrun 19552 proxy,pay
  echo "B - the same interface by hand (HttpServiceProxyFactory over RestClient.create(), the case hand), then the group's pay, a fresh stub, port 19553, a fresh JVM:"
  wrun 19553 hand,pay
  echo "A' - A again, a fresh stub, port 19552, a fresh JVM:"
  wrun 19552 proxy,pay
  echo "A' against A, its label aside, line for line the same: $(asame "A - " "B - " "A' - " "A' against A")"; }

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
  printf '%s\n' "$sol" | sed -n 3p | grep -qxF "B=$KB" || die "SOLUTION.md's third line must give the group its base URL: B=$KB"
  printf '%s\n' "$setup" | grep -qxF 'B=' || die "exercise/README.md must ship the group with no base URL (B=)"
  ! printf '%s\n' "$setup" | grep -qF 'base-url' || die "exercise/README.md must not name the base URL's key: it is the exercise"
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
  echo "  the shell is now in: $(where "$d1") · the JVM's locale in its log: $(grep -m1 "^ROUTE the JVM's locale: " .harness/ex-readme.log | sed "s/^.*locale: //") (PayRoutes), in the stub's: $(grep -m1 "^STUB the JVM's locale: " .harness/ex-readme.stub | sed "s/^.*locale: //") · the copy's own token in its log: $(raw "$(head -1 .harness/mine/anchor/$TF)" .harness/ex-readme.log) times, in the stub's dump: $(raw "$(head -1 .harness/mine/anchor/$TF)" .harness/ex-readme.stub) times · WARN lines in its log: $(lvl WARN .harness/ex-readme.log) · ERROR lines: $(lvl ERROR .harness/ex-readme.log) · listening on 19554 now: $(listeners 19554) · on 19556: $(listeners 19556)"
  echo "  the README's ERROR record in its log (.harness/mine/run.log, kept before the solution's run), from its logger on:"
  cp .harness/ex-readme.log .harness/run.out; recs 0
  echo "  the first stack frame under its root cause is in the module: $(awk '/^java.lang.IllegalArgumentException: URI with undefined scheme$/ { getline; sub(/^\tat /, ""); sub(/\/.*$/, ""); print; exit }' .harness/ex-readme.log) (the JDK's HttpClient)"
  echo "the solution's $(printf '%s\n' "$sol" | grep -c .) lines, next, in the same shell:"
  printf '%s\n' "$sol" | sed 's/^/  $ /'
  echo "  exit $e2 · what they printed:"; sed 's/^/    /' .harness/ex-sol.out
  echo "  the shell is now in: $(where "$d2") · the JVM's locale in its log: $(grep -m1 "^ROUTE the JVM's locale: " .harness/mine/run.log | sed "s/^.*locale: //") (PayRoutes), in the stub's: $(grep -m1 "^STUB the JVM's locale: " .harness/mine/stub.log | sed "s/^.*locale: //") · the copy's own token in its log: $(raw "$(head -1 .harness/mine/anchor/$TF)" .harness/mine/run.log) times, in the stub's dump: $(raw "$(head -1 .harness/mine/anchor/$TF)" .harness/mine/stub.log) times · WARN lines in its log: $(lvl WARN .harness/mine/run.log) · ERROR lines: $(lvl ERROR .harness/mine/run.log) · listening on 19554 now: $(listeners 19554) · on 19556: $(listeners 19556)"; }

cap interface interface
cap proxy proxy
cap calls calls
cap group group
cap aot aot
cap ways ways
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
SHIP="README.md exercise/README.md exercise/solution/SOLUTION.md receipts.md5 harness/pom.xml harness/aot-app/pom.xml harness/stub/Stub.java harness/shutdown.sh harness/keys.py harness/meta.py harness/hints.py $HWS $AWS"
for f in .r-*.out $SHIP; do [ "$(raw "$TOKEN" "$f")" = 0 ] || die "$f holds the demo token, raw"; done
for f in .r-*.out; do ! grep -qE '/Users/|/private/|/home/|/var/folders/' "$f" || die "$f holds an absolute path"; ! grep -qE 'c[0-9]-unit[0-9]|unit ?[0-9]' "$f" || die "$f holds a unit number"; ! grep -qE ' (with PID|started by) ' "$f" || die "$f holds Boot's process line"; ! grep -qE '^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T|"timestamp":"?[0-9]|(exec|handler|task|omcat-handler)-[0-9]' "$f" || die "$f holds a log time, a timestamp or a thread number"; ! grep -qE 'Java-http-client/[0-9]|Java/[0-9]+\.[0-9]|Macintosh|Mac OS X|Windows NT|X11;|Linux x86' "$f" || die "$f holds a client's JDK version or a platform (R.128, R.136)"; ! grep -qE '\$Proxy[0-9]|SpringCGLIB\$\$[0-9]' "$f" || die "$f holds a proxy class's number (masked: it moves with the class path)"; ! grep -qE ':8080|:35729|:18425/' "$f" || die "$f names 8080, 35729 or 18425"; ! grep -q "$(printf '\r')" "$f" || die "$f holds a carriage return"; ! grep -qE '[0-9]+ ?ms\b|[0-9]+\.[0-9]+ ?s(econds)?\b|Started .* in ' "$f" || die "$f holds a duration (R.121, R.139)"; ! grep -qE '^\s+at [a-z]' "$f" || die "$f holds a stack frame"; done
# S3.9 (R.105): no wait in this script, its checks or the exercise is bare - each names its pid ($! or a variable)
for f in receipts.sh exercise/README.md exercise/solution/SOLUTION.md; do ! grep -nE '(^|[;&|({] *)wait *($|[;&|)}])' "$f" | grep -vE '^[0-9]+: *#' > /dev/null || die "$f has a bare wait (S3.9)"; done
# R.79/S1.3: nothing is stopped by name - no pkill, no killall
PK='p''kill|kill''all'
for f in receipts.sh exercise/README.md exercise/solution/SOLUTION.md; do ! grep -nE "\\b($PK)\\b" "$f" | grep -vE '^[0-9]+: *#' > /dev/null || die "$f stops a process by name"; done
# R.96: no running step piped into head
! grep -nE '(eval|receipts\.sh|java |mvn ).*\| *head' receipts.sh | grep -vE '^[0-9]+: *#' | grep -vF 'JAVA_HOME gives: $(java -version 2>&1 | head -1)' > /dev/null || die "receipts.sh pipes a running step into head (R.96)"
for f in receipts.sh README.md exercise/README.md exercise/solution/SOLUTION.md $HWS $AWS; do ! grep -qE "exposure\.include='?\*" "$f" || die "$f exposes every endpoint (R.42)"; done
# R.99: Boot 4.1 reads only spring.web.error.* - no file of this unit names one of Boot 3's error keys (split here, so this line does
# not spell it)
K3='server'; K3="$K3.error."
for f in receipts.sh $SHIP; do ! grep -qF "$K3" "$f" || die "$f names one of Boot 3's error keys (R.99)"; done
# R.138: Boot 3's spelling of the client keys (the singular one) nowhere in this unit - this script builds it, never writes it
for f in receipts.sh $SHIP; do ! grep -qF "$K1" "$f" || die "$f spells Boot 3's client key (R.138)"; done
# R.114 (S3.18): no harness class reaches the anchor - its tree names none of them (as whole words)
for c in Payments PaymentConfig PayRoutes Pays probe.web probe.aot Stub HttpExchange ImportHttpServices; do ! grep -rqwF "$c" anchor/tiffinbox-web/src anchor/tiffinbox-core/src || die "the anchor's sources name $c (a whole word) - the harness is shown on the harness, never in the anchor"; done
# no capture runs a command with a URL that is not 127.0.0.1's; the stub binds the loopback address
for f in .r-*.out; do ! grep -E '^ *\$ ' "$f" | grep -oE 'https?://[^ '"'"']+' | grep -vE '^http://127\.0\.0\.1:' > /dev/null || die "$f runs a command with a URL that is not 127.0.0.1's"; done
grep -qF 'new InetSocketAddress(InetAddress.getLoopbackAddress(), port)' harness/stub/Stub.java || die "the stub must bind the loopback address"
for f in $HWS $AWS harness/stub/Stub.java exercise/README.md exercise/solution/SOLUTION.md; do ! grep -qE 'https?://localhost|localhost:' "$f" || die "$f names localhost - every URL is 127.0.0.1's (R.82)"; done
# S4.1: every java line a capture starts pins the JVM's locale (the extract line prints nothing a locale changes) - the stub's and the
# AOT app's too
for f in .r-*.out; do ! grep -E '^ *\$ (cd [^ ]+ && )?(exec )?java ' "$f" | grep -vF -- "java $JL " | grep -vF -- 'java -Djarmode=tools ' > /dev/null || die "$f starts a JVM without its locale pinned (S4.1)"; done
for f in exercise/README.md exercise/solution/SOLUTION.md; do ! grep -oE '\{ java [^>]*' "$f" | grep -vF -- "{ java $JL " > /dev/null || die "$f: the exercise's java lines must pin the JVM's locale (S4.1)"; done
[ "$(grep -oE '\{ java [^>]*' exercise/README.md | grep -c .)" = 2 ] || die "exercise/README.md must start two JVMs (the stub, TiffinBox), each in a subshell job"
# S2.16: the harness compiles with -parameters (@PathVariable String id is named by its parameter), and so does the exercise
grep -qF 'javac -parameters ' exercise/README.md && [ "$(grep -c '^javac -parameters ' README.md)" = 1 ] || die "the harness must compile with -parameters (S2.16)"
# httpclient5 never joins (S5.3): not on the harness's class path, not in the anchor's lib/
! grep -qF httpclient5 .harness/harness.cp && [ -z "$(ls "$LIBD" | grep '^httpclient5-' || true)" ] || die "httpclient5 is on the class path - every factory sentence would change"
# R.115: no browser is used here - the exercise names one only to say none is needed
[ "$(grep -oi 'browser' exercise/README.md | wc -l | tr -d ' ')" = 1 ] && grep -i 'browser' exercise/README.md | grep -qF 'browser are needed' && [ "$(grep -oi 'browser' exercise/solution/SOLUTION.md | wc -l | tr -d ' ')" = 0 ] || die "the exercise speaks of a browser (R.115) - none is used"
# R.146: two types named HttpExchange - every harness file that names Spring's says so by package, and the interface's import is Spring's
grep -qxF 'import org.springframework.web.service.annotation.HttpExchange;' harness/probe/web/Payments.java && grep -qxF 'import org.springframework.web.service.annotation.HttpExchange;' harness/aot-app/src/main/java/probe/aot/Payments.java && grep -qF 'com.sun.net.httpserver.HttpExchange' harness/probe/web/Payments.java || die "Payments.java must import Spring's HttpExchange and name the JDK's by package (R.146)"
NL=$(cat .r-*.out | grep -cE "^  its log: the demo token 0 times · X-Shutdown-Token 0 times\$" || true)
ND=$(cat .r-*.out | grep -cE "· the demo token 0 times · X-Shutdown-Token 0 times\$" || true)
echo "  tokens: 0 raw copies in $(ls .harness/raw-* | wc -l | tr -d ' ') raw capture runs, in $(ls .r-*.out | wc -l | tr -d ' ') captures; the demo token 0 in the logs of every JVM that ran ($LOGS here; the published captures' $NL) and in every stub dump ($DUMPS here; the published captures' $ND), the READMEs, the harness, the stub and receipts.md5; no absolute path, no unit number, no process line, no log time, no timestamp, no thread number, no client JDK version, no proxy number, no platform, no duration, no stack frame, no URL but 127.0.0.1's; every JVM's locale pinned; Boot 3's client key nowhere"

S466='466c20ed7e0d5439cb052f32ce09de1b'
LOC="  the JVM's locale (the harness's Pays): en_US"
SL="  the stub listens on: 127.0.0.1:19556 · loopback only: yes · its locale: en_US"
DONE="    done"
Z3="  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0 · lines that say \"deprecat\": 0"
UA0=$(cat .harness/ua.txt 2> /dev/null || true); PN0=$(cat .harness/proxyn.txt 2> /dev/null || true); PA0=$(cat .harness/proxyn-aot.txt 2> /dev/null || true)
PROXYI='[org.springframework.aop.SpringProxy, org.springframework.aop.framework.Advised, org.springframework.core.DecoratingProxy, probe.web.Payments]'
REC1='Payment[id=pay-1, status=PAID, customer=Ravi, amount=7200]'

# "one interface ... a method per call ... no implementation at all ... one line ... the starter adds two jars" - interface
IO=$(cat .r-interface.out)
has "$IO" '  built the anchor · offline: yes · exit 0' "interface: the anchor built offline"
has "$IO" "  the anchor's libraries (its extracted lib/): 61 · Boot's RestClient module among them: 0 · httpclient5: 0" "interface: 61 libraries"
has "$IO" "  the jars it lists: 31 · in the anchor's lib/ already, by name (the version is in the name): 25 · not:" "interface: 31 listed, 25 there"
has "$IO" "    spring-boot-restclient-4.1.1.jar · classes: 29 · joined (.harness/xlib)" "interface: spring-boot-restclient joined"
has "$IO" "    spring-boot-http-client-4.1.1.jar · classes: 88 · joined (.harness/xlib)" "interface: spring-boot-http-client joined"
[ "$(printf '%s\n' "$IO" | grep -c '^    .*\.jar · classes: 0 · not joined: no class')" = 4 ] && [ "$(printf '%s\n' "$IO" | grep -c '^    .*\.jar · classes: ')" = 6 ] || die "interface: six jars the anchor lacks, four of them starters"
has "$IO" "  the class path the harness runs on: the anchor's 61 libraries + 2 = 63" "interface: 61 + 2 = 63"
has "$IO" "  exit 0 · what javac printed: 0 lines · its classes: probe/web/Charge.class probe/web/PayRoutes.class probe/web/Payment.class probe/web/PaymentConfig.class probe/web/Payments.class probe/web/Pays.class" "interface: the harness compiled, no warning"
has "$IO" "  $SMD5 $SMD5 Stub.java" "interface: the stub's md5, the RestClient lesson's"
has "$IO" "  the same md5, file by file: 6 of 6 · routes this unit adds to it: 0" "interface: the stub copied, byte for byte"
for l in '  @HttpExchange("/payments")' '  public interface Payments {' '      @PostExchange' '      Payment pay(@RequestBody Charge charge);' '      ResponseEntity<Payment> payForEntity(@RequestBody Charge charge);' '      @GetExchange("/{id}")' '      Payment find(@PathVariable String id);' '      @GetExchange("/slow")' '      String slow();'; do has "$IO" "$l" "interface: the interface's line $l"; done
has "$IO" "  its methods: 4 · a class in harness/ that implements it: 0" "interface: four methods, no implementation"
[ "$(grep -cE 'implements[^{]*Payments|new Payments\(' $HWS $AWS | awk -F: '{ s += $NF } END { print s + 0 }')" = 0 ] || die "interface: a harness class implements Payments"
has "$IO" '  8:@ImportHttpServices(group = "payments", types = Payments.class)' "interface: the configuration's one line"
has "$IO" '  89:void send(HttpExchange ex, int code, String type, String body) throws java.io.IOException {' "interface: the stub's HttpExchange (the JDK's)"
for l in 'org.springframework.web.service.annotation.HttpExchange · in: spring-web-7.0.9.jar' 'org.springframework.web.service.registry.ImportHttpServices · in: spring-web-7.0.9.jar' 'org.springframework.web.service.invoker.HttpServiceProxyFactory · in: spring-web-7.0.9.jar' 'org.springframework.web.client.support.RestClientAdapter · in: spring-web-7.0.9.jar' 'org.springframework.boot.restclient.autoconfigure.service.HttpServiceClientAutoConfiguration · in: spring-boot-restclient-4.1.1.jar' 'org.springframework.boot.http.client.autoconfigure.service.HttpServiceClientProperties · in: spring-boot-http-client-4.1.1.jar'; do has "$IO" "  $l" "interface: the owner, $l"; done
[ "$(cnt "$IO" "  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 0 · md5 $S466")" = 2 ] || die "interface: the seven $S466 on both lines"
[ "$(cnt "$IO" '    WARN o.s.web.servlet.PageNotFound: Request method '"'"'GET'"'"' is not supported')" = 2 ] || die "interface: the seven's one WARN, PageNotFound, on both lines"
has "$IO" '  lines that differ: 0 · the same, byte for byte: 7 (1 2 3 4 5 6 7)' "interface: the same, byte for byte: 7"
echo "  interface: 61 libraries + 2 = 63; the stub 6 of 6 md5 = the RestClient lesson's ($SMD5); Payments - @HttpExchange(\"/payments\"), 4 methods, 0 implementations; @ImportHttpServices(group = \"payments\", types = Payments.class); the stub's own HttpExchange the JDK's; owners spring-web / spring-boot-restclient / spring-boot-http-client; the seven $S466 on both lines, the same, byte for byte: 7"

# "Spring's annotation, the JDK server's type ... a proxy, the kind Course four opened ... its name has a hash in it" - proxy
PO=$(cat .r-proxy.out)
has "$PO" "$LOC" "proxy: the locale"
has "$PO" '    types org.springframework.web.service.annotation.HttpExchange | an annotation: true | from: spring-web-7.0.9.jar' "proxy: Spring's HttpExchange"
has "$PO" '    types com.sun.net.httpserver.HttpExchange | an annotation: false | from: module jdk.httpserver' "proxy: the JDK's HttpExchange"
has "$PO" "    beans of type Payments: ['payments#probe.web.Payments']" "proxy: the bean's name, quoted"
has "$PO" "    beans whose name says httpservice: 6" "proxy: six group beans"
has "$PO" "    beans 'httpServiceProxyRegistry' -> org.springframework.web.service.registry.HttpServiceProxyRegistry" "proxy: the registry"
has "$PO" '    proxy class: jdk.proxy2.$Proxy<n> | its superclass: java.lang.reflect.Proxy' "proxy: a JDK proxy class, its number masked"
has "$PO" '    proxy Proxy.isProxyClass: true | AopUtils.isJdkDynamicProxy: true | AopUtils.isCglibProxy: false' "proxy: the JDK's test and Spring's"
has "$PO" "    proxy interfaces: $PROXYI" "proxy: the four interfaces"
has "$PO" '    proxy invocation handler: org.springframework.aop.framework.JdkDynamicAopProxy' "proxy: the handler"
has "$PO" "$DONE" "proxy: Pays done"; has "$PO" "$Z3" "proxy: 0/0"
case "$PN0" in 'jdk.proxy2.$Proxy'[0-9]*) ;; *) die "proxy: the raw proxy class was not read (.harness/proxyn.txt: $PN0)" ;; esac
echo "  proxy: Spring's HttpExchange an annotation from spring-web, the JDK's a type from module jdk.httpserver; 'payments#probe.web.Payments'; jdk.proxy2.\$Proxy<n> extends java.lang.reflect.Proxy, isProxyClass true, isJdkDynamicProxy true, CGLIB false; SpringProxy, Advised, DecoratingProxy, Payments; JdkDynamicAopProxy · the proxy class, masked in every capture (terminal only): $PN0"

# "pay ... the record ... two hundred and one and where it lives ... JSON, chunked, no Accept ... not found ... four twenty-two" - calls
CO=$(cat .r-calls.out)
has "$CO" "$SL" "calls: the stub, loopback, en_US"; has "$CO" "$LOC" "calls: the locale"
has "$CO" "    calls pay -> $REC1" "calls: pay, the record"
has "$CO" '    calls payForEntity -> 201 | Location: /payments/pay-2 | Payment[id=pay-2, status=PAID, customer=Meera, amount=4500]' "calls: payForEntity, 201 and its Location"
has "$CO" "    calls find pay-1 -> $REC1" "calls: find"
has "$CO" '    calls find pay-99 -> org.springframework.web.client.HttpClientErrorException$NotFound | status 404 | message: 404 Not Found: "{"title":"Not Found","status":404,"detail":"no payment pay-99"}"' "calls: NotFound"
has "$CO" '    calls pay amount 0 -> org.springframework.web.client.HttpClientErrorException$UnprocessableContent | status 422 | message: 422 Unprocessable Content: "{"title":"Unprocessable","status":422,"detail":"amount must be positive"}"' "calls: UnprocessableContent, 422"
nhas "$CO" '    calls find pay-99 -> no exception' "calls: the 404 threw"
CP1=$(printf '%s\n' "$CO" | awk '/^    \| STUB POST \/payments /{f=1} f{print} f && /^    \| STUB-ANSWER/{exit}')
[ "$CP1" = "$(printf '%s\n' '    | STUB POST /payments headers=[Accept-encoding, Connection, Content-type, Host, Http2-settings, Transfer-encoding, Upgrade, User-agent]' '    | STUB-H accept-encoding: gzip' '    | STUB-H accept-encoding: deflate' '    | STUB-H connection: Upgrade, HTTP2-Settings' '    | STUB-H content-type: application/json' '    | STUB-H host: 127.0.0.1:19556' '    | STUB-H http2-settings: AAEAAEAAAAIAAAAAAAMAAAAAAAQBAAAAAAUAAEAAAAYABgAA' '    | STUB-H transfer-encoding: chunked' '    | STUB-H upgrade: h2c' '    | STUB-H user-agent: Java-http-client/<version>' '    | STUB-BODY {"customer":"Ravi","amount":7200}' '    | STUB-ANSWER 201 application/json 62 bytes')" ] || die "calls: the first POST, whole, line for line - got: $CP1"
has "$CO" "  the stub's dump since, whole: 54 lines" "calls: the dump, 54 lines"
has "$CO" "  the requests: 5 · POSTs: 3 · POSTs with content-type: application/json: 3 · with transfer-encoding: chunked: 3 · requests with a content-length header: 0 · with an Accept header: 0 · bodies: 3" "calls: JSON, chunked, no Content-Length, no Accept"
has "$CO" '    | STUB GET /payments/pay-99 headers=[Accept-encoding, Connection, Host, Http2-settings, Upgrade, User-agent]' "calls: find pay-99 reached the stub"
has "$CO" '    | STUB-ANSWER 422 application/problem+json 73 bytes' "calls: the stub's 422"
has "$CO" "$Z3" "calls: 0/0"
has "$CO" "  the stub: stopped by its pid · exit 143 · listening on 19556 now: 0 · requests in its dump: 5 · the demo token 0 times · X-Shutdown-Token 0 times" "calls: five requests, 0 tokens"
case "$UA0" in Java-http-client/[0-9]*) ;; *) die "calls: the stub saw no Java-http-client User-Agent" ;; esac
echo "  calls: pay -> $REC1; payForEntity -> 201, Location /payments/pay-2; find pay-1; find pay-99 -> HttpClientErrorException\$NotFound 404; amount 0 -> \$UnprocessableContent 422; the first POST whole - content-type application/json, transfer-encoding chunked, its body; 5 requests, 3 POSTs chunked, 0 content-length, 0 Accept; 0 tokens · the User-Agent, masked in every capture (terminal only): $UA0"

# "a service group ... its own keys ... its own read timeout: cancelled ... observed under templates ... C, no key: answered" - group
GO=$(cat .r-group.out); GA=$(blk group "the group's read timeout" "C (labelled)"); GC=$(blk group "C (labelled)" "the requests the stub saw")
has "$GO" '  spring.http.serviceclient · default none · HttpClientProperties>' "group: the metadata's one key, a map"
has "$GO" '  1 keys under spring.http.serviceclient' "group: one key"
has "$GO" '  class org.springframework.boot.http.client.autoconfigure.HttpClientProperties extends org.springframework.boot.http.client.autoconfigure.HttpClientSettingsProperties' "group: HttpClientProperties"
has "$GO" '    set setBaseUrl(java.lang.String);' "group: base-url"
has "$GO" '    set setReadTimeout(java.time.Duration);' "group: read-timeout, inherited"
has "$GO" '  what javap printed: 22 lines · kept: its two class lines and their setters, 8 lines' "group: javap's lines counted"
unzip -p .m2-demo/org/springframework/boot/spring-boot-http-client/4.1.1/spring-boot-http-client-4.1.1.jar META-INF/spring-configuration-metadata.json | grep -qF '"type": "java.util.Map<String,org.springframework.boot.http.client.autoconfigure.HttpClientProperties>"' || die "group: the metadata's spring.http.serviceclient is no longer a map to HttpClientProperties"
CANC='    slow /payments/slow cancelled: org.springframework.web.client.ResourceAccessException | message: I/O error on GET request for "http://127.0.0.1:19556/payments/slow": Request cancelled | cause: java.net.http.HttpTimeoutException: Request cancelled'
ANS='    slow /payments/slow answered: {"slow":true}'
has "$GA" "$CANC" "group: the group's timeout, cancelled"; nhas "$GA" "$ANS" "group: not answered"
has "$GC" "$ANS" "group C: answered"; nhas "$GC" "$CANC" "group C: not cancelled"
has "$GA" "    calls pay -> $REC1" "group: the calls answered under the timeout"
for l in 'error="none",exception="none",method="POST",outcome="SUCCESS",status="201",uri="/payments"} 2' 'error="none",exception="none",method="GET",outcome="SUCCESS",status="200",uri="/payments/{id}"} 1' 'error="NotFound",exception="NotFound",method="GET",outcome="CLIENT_ERROR",status="404",uri="/payments/{id}"} 1' 'error="UnprocessableContent",exception="UnprocessableContent",method="POST",outcome="CLIENT_ERROR",status="422",uri="/payments"} 1' 'error="ResourceAccessException",exception="ResourceAccessException",method="GET",outcome="UNKNOWN",status="CLIENT_ERROR",uri="/payments/slow"} 1'; do has "$GA" "    http_client_requests_seconds_count{client_name=\"127.0.0.1\",$l" "group: observed, $l"; done
has "$GA" '  kept: 5 of the scrape'"'"'s lines, by the filter ^http_client_requests_seconds_count, sorted · the others not shown: over 150 (their number moves from run to run: the JVM'"'"'s own meters)' "group: kept 5"
[ "$(printf '%s\n' "$GA" | grep -c 'uri="/payments/pay-')" = 0 ] || die "group: an observation tagged with a payment's id, not the template"
has "$GA" "\$ $(hcp .harness/anchor 19550 probe.web.PaymentConfig,probe.web.Pays "--probe.cases=calls,slow $O_RT")" "group: its line"
for b in "$GA" "$GC"; do has "$b" "$LOC" "group: the locale"; has "$b" "$Z3" "group: 0/0"; done
[ "$(cnt "$GO" '    GET /payments/slow · headers: 7')" = 2 ] || die "group: two JVMs, one call each to the stub's slow answer"
grep -qF 'Thread.sleep(q != null && q.startsWith("ms=") ? Long.parseLong(q.substring(3)) : 3000);' harness/stub/Stub.java || die "group: the stub's wait is 3000 unless named"
echo "  group: spring.http.serviceclient - a map to HttpClientProperties (setBaseUrl, setReadTimeout ...); the group's read-timeout 1s -> Request cancelled (HttpTimeoutException); one scrape - uri=\"/payments\" 201 2, 422 1; uri=\"/payments/{id}\" 200 1, 404 1; /payments/slow 1; C no timeout key -> answered; never a clock"

# "ahead of time ... the generated code calls the registry ... a proxy hint with the four interfaces ... the same kind of proxy, the
# same record" - aot (C, labelled)
AO=$(cat .r-aot.out); AJ=$(blk aot "on the JVM - " "ahead of time - "); AA=$(blk aot "ahead of time - " "")
has "$AO" '  its classes: probe/aot/App.java probe/aot/Charge.java probe/aot/Payment.java probe/aot/PaymentConfig.java probe/aot/Payments.java' "aot: five classes"
has "$AO" "  its interface's annotation and method lines, against the harness's without its slow method: the same: yes · its configuration's annotation lines, against the harness's: the same: yes" "aot: the same interface and configuration"
has "$AO" '  built the AOT app · offline: yes · exit 0' "aot: built offline"
has "$AO" '  files .m2-demo gained: 0 · harness/aot-app/target: absent · process-aot ran: 1' "aot: 0 files fetched, process-aot ran"
has "$AO" '  20:    return registeredBean.getBeanFactory().getBean("httpServiceProxyRegistry", HttpServiceProxyRegistry.class).getClient("payments", Payments.class);' "aot: the generated getClient line"
has "$AO" '  JDK-proxy hints: 1' "aot: one proxy hint"
has "$AO" '    proxy: [probe.aot.Payments, org.springframework.aop.SpringProxy, org.springframework.aop.framework.Advised, org.springframework.core.DecoratingProxy]' "aot: the hint's four interfaces"
has "$AO" '    probe.aot.Charge · allDeclaredFields allDeclaredConstructors · methods: amount() customer()' "aot: Charge's binding hints"
has "$AO" '    probe.aot.Payment · allDeclaredFields allDeclaredConstructors · methods: amount() customer() id() status()' "aot: Payment's binding hints"
has "$AJ" '  exit 0 · Boot'"'"'s first line: Starting App v1.0.0 using Java 25.0.4.1' "aot: the JVM run's first line"
has "$AA" '  exit 0 · Boot'"'"'s first line: Starting AOT-processed App v1.0.0 using Java 25.0.4.1' "aot: Boot's AOT-processed line"
[ "$(printf '%s\n' "$AJ" | grep -c 'AOT-processed')" = 0 ] || die "aot: the JVM run says AOT-processed"
for b in "$AJ" "$AA"; do has "$b" '    the JVM'"'"'s locale: en_US' "aot: the locale"; has "$b" '    proxy class: jdk.proxy2.$Proxy<n> | Proxy.isProxyClass: true | AopUtils.isJdkDynamicProxy: true' "aot: a JDK proxy"
  has "$b" '    proxy interfaces: [org.springframework.aop.SpringProxy, org.springframework.aop.framework.Advised, org.springframework.core.DecoratingProxy, probe.aot.Payments]' "aot: the four interfaces"
  has "$b" '  WARN lines in its log: 0 · ERROR lines: 0 · server jars in its jar (Tomcat, Jetty, Undertow, Netty): 0 - it serves nothing, and listens nowhere' "aot: 0/0, no server"; done
has "$AJ" "    pay -> $REC1" "aot: the JVM run's record"
has "$AA" '    pay -> Payment[id=pay-2, status=PAID, customer=Ravi, amount=7200]' "aot: the AOT run's record"
has "$AO" "  the stub: stopped by its pid · exit 143 · listening on 19556 now: 0 · requests in its dump: 2 · the demo token 0 times · X-Shutdown-Token 0 times" "aot: two payments at the stub"
case "$PA0" in 'jdk.proxy2.$Proxy'[0-9]*) ;; *) die "aot: the raw proxy class was not read (.harness/proxyn-aot.txt: $PA0)" ;; esac
! grep -qE -- '-Pnative|native:compile|native-maven-plugin|GRAALVM' harness/aot-app/pom.xml exercise/README.md || die "aot: no native build in this unit - nothing may run or name one as run"
echo "  aot (C): five classes, process-aot offline (0 files fetched); Payments__BeanDefinitions -> getClient(\"payments\", Payments.class); one JDK-proxy hint [Payments, SpringProxy, Advised, DecoratingProxy]; Charge, Payment binding hints; Starting App, then Starting AOT-processed App; the same JDK proxy, the record, both; no native build · the AOT run's proxy class, masked (terminal only): $PA0"

# "A, the group's: observed ... B by hand: the same kind of proxy, the record, and not observed - in the same scrape ... A again" - ways
WO=$(cat .r-ways.out); WA=$(blk ways "A - " "B - "); WB=$(blk ways "B - " "A' - "); WA2=$(blk ways "A' - " "A' against A")
has "$WO" '  19559, never bound: listening 0 (lsof, by port)' "ways: 19559 free"
OBS='    http_client_requests_seconds_count{client_name="127.0.0.1",error="none",exception="none",method="POST",outcome="SUCCESS",status="201",uri="/payments"} 1'
KEPT1='  kept: 1 of the scrape'"'"'s lines, by the filter ^http_client_requests_seconds_count, sorted · the others not shown: over 150 (their number moves from run to run: the JVM'"'"'s own meters)'
for b in "$WA" "$WB" "$WA2"; do has "$b" "$OBS" "ways: the group's pay, observed once"; has "$b" "$KEPT1" "ways: one kept line"; has "$b" "$LOC" "ways: the locale"; has "$b" "$Z3" "ways: 0/0"; has "$b" "$SL" "ways: a fresh stub"; done
for b in "$WA" "$WA2"; do has "$b" "    pay the group's client -> $REC1" "ways A: the record"; has "$b" "    proxy interfaces: $PROXYI" "ways A: the proxy"; [ "$(cnt "$b" '    POST /payments · headers: 9 · the stub answered 201 application/json 62 bytes')" = 1 ] || die "ways A: one POST"; done
has "$WB" '    hand class: jdk.proxy2.$Proxy<n> | its superclass: java.lang.reflect.Proxy' "ways B: a JDK proxy"
has "$WB" '    hand Proxy.isProxyClass: true | AopUtils.isJdkDynamicProxy: true | AopUtils.isCglibProxy: false' "ways B: the same kind"
has "$WB" "    hand interfaces: $PROXYI" "ways B: the same interfaces"
has "$WB" '    hand the same class as the group'"'"'s: true' "ways B: the same class"
has "$WB" '    hand pay -> Payment[id=pay-1, status=PAID, customer=Priya, amount=3600]' "ways B: the record"
has "$WB" '    pay the group'"'"'s client -> Payment[id=pay-2, status=PAID, customer=Ravi, amount=7200]' "ways B: the group's pay beside it"
[ "$(printf '%s\n' "$WB" | grep -c '^    POST /payments · headers: 9 · the stub answered 201 ')" = 2 ] || die "ways B: two POSTs reached the stub, one observed"
has "$WB" "\$ $(hcp .harness/anchor 19553 probe.web.PaymentConfig,probe.web.Pays "--probe.cases=hand,pay $O_B")" "ways B: its line"
has "$WA2" "\$ $(hcp .harness/anchor 19552 probe.web.PaymentConfig,probe.web.Pays "--probe.cases=proxy,pay $O_B")" "ways A': its \$ line (R.16, S5.2)"
has "$WO" "A' against A, its label aside, line for line the same: yes" "ways: A' = A"
grep -qF 'HttpServiceProxyFactory.builderFor(RestClientAdapter.create(RestClient.create(stub))).build()' harness/probe/web/Pays.java || die "ways B: the hand-made client is HttpServiceProxyFactory over RestClient.create()"
echo "  ways: A the group's - JdkDynamicAopProxy, the record, uri=\"/payments\" 201 1; B by hand - the same proxy class, the record, 2 POSTs at the stub and still 1 observation (the group's); A' = A"

# the exercise's files as shipped (read again here, so a check that the exercise capture makes cannot be skipped)
XR=$(block exercise/README.md); XL=$(block exercise/solution/SOLUTION.md)
[ "$(printf '%s\n' "$XL" | grep -c .)" = 4 ] && [ "$(printf '%s\n' "$XL" | sed -n 1,2p)" = "$(printf '%s\n' "$XR" | sed -n 1,2p)" ] && [ "$(printf '%s\n' "$XL" | sed -n 3p)" = "B=$KB" ] && [ "$(printf '%s\n' "$XL" | sed -n 4p)" = "$(printf '%s\n' "$XR" | tail -1)" ] && printf '%s\n' "$XR" | grep -qxF 'B=' && ! printf '%s\n' "$XR" | grep -qF base-url || die "exercise: SOLUTION.md must be the README's two exports, B=$KB and the README's last line; the README must ship B= and no base-url"
XS=$(blk exercise "the README's" "the solution's"); XE=$(blk exercise "the solution's" '')
l='readiness: 200 · the pay call: 200 · its payment: pay-1 · URI with undefined scheme in its log: 0 · requests the stub saw: 1'; l0='readiness: 200 · the pay call: 500 · its payment: none · URI with undefined scheme in its log: 1 · requests the stub saw: 0'
has "$XE" "    $l" "exercise: the solution"; has "$XS" "    $l0" "exercise: as shipped"
awk '/^\*\*Done\*\*/ { f = 1 } f' exercise/README.md | grep -qxF -- "$l" || die "exercise/README.md: Done names no such line"
grep -qxF -- "$l" exercise/solution/SOLUTION.md || die "SOLUTION.md: the measured run shows no such line"
grep -qF -- "\`$l0\`" exercise/README.md || die "exercise/README.md: the shipped line's answer is not named"
has "$XS" '  exit 0 · what they printed:' "exercise: the README's commands, exit 0"; has "$XE" '  exit 0 · what they printed:' "exercise: the solution's lines, exit 0"
has "$XS" "  the shell is now in: this unit's folder · the JVM's locale in its log: en_US (PayRoutes), in the stub's: en_US · the copy's own token in its log: 0 times, in the stub's dump: 0 times · WARN lines in its log: 0 · ERROR lines: 1 · listening on 19554 now: 0 · on 19556: 0" "exercise: as shipped, 0 WARN, 1 ERROR, nothing left"
has "$XE" "  the shell is now in: this unit's folder · the JVM's locale in its log: en_US (PayRoutes), in the stub's: en_US · the copy's own token in its log: 0 times, in the stub's dump: 0 times · WARN lines in its log: 0 · ERROR lines: 0 · listening on 19554 now: 0 · on 19556: 0" "exercise: the solution, 0/0, nothing left"
has "$XS" '    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: Servlet.service() for servlet [dispatcherServlet] in context with path [] threw exception [Request processing failed: java.lang.IllegalArgumentException: URI with undefined scheme] with root cause' "exercise: Tomcat's ERROR, URI with undefined scheme"
has "$XS" "  the first stack frame under its root cause is in the module: java.net.http (the JDK's HttpClient)" "exercise: the JDK client's words"
[ "$(printf '%s\n' "$XE" | grep -c '^  \$ export ')" = 2 ] || die "exercise: SOLUTION.md gives the README's two export lines"
EXQ="Your turn: the README's payment client starts fine and fails on every call. Tell the group where the payment service lives, and pay again."
grep -qxF -- "**Your turn:** ${EXQ#Your turn: }" exercise/README.md || die "exercise/README.md: the spoken exercise line"
[ "$(printf '%s\n' "$EXQ" | wc -w | tr -d ' ')" -le 25 ] || die "exercise: the spoken line is over 25 words"
echo "  exercise: one env -i shell - the README as written (B= empty) -> $l0; the solution (the group's base-url) -> $l; the shell in this unit's folder after each, 19554 and 19556 free"

[ -z "$unpub" ] || die "no published hash for:$unpub - check the captures, then copy the md5s above into receipts.md5 and run again"
echo "c6-unit26: every capture 3/3 and = published; every spoken number asserted; 0 raw demo tokens in every capture, every log and every stub dump"
