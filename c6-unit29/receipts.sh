#!/bin/bash
XPATH=$PATH                                           # the PATH you started this with: the exercise's own shell gets it
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25.0.4.1 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# Course 6 · API Versioning in Framework 7 - this unit's receipts. No anchor change: anchor/ is the link to ../c6-unit28/after, the
# tree the web-layer testing lesson froze (= c6-tiffinbox at Section 5's end). This script copies that tree under .harness/anchor,
# builds it and runs it - as its README runs it, and on its class path with the two jars Boot's RestClient starter adds
# (harness/pom.xml, read by Maven's dependency:build-classpath) and the course's harness joined (harness/probe/web, outside
# com.tiffinbox): one path, GET /menu, answered by three handlers, one per version (Menu, on TiffinBox's own repository); the same
# three with the version in the path (MenuPath); version 1.0 marked for removal (Deprecations); a runner whose RestClients insert a
# version (Versions); an HTTP interface in a service group, versioned by the group's keys (MenuApi, MenuGroup). It calls the stub - a
# small stand-in server on this computer (harness/stub/Stub.java, the RestClient lesson's, copied byte for byte: the JDK's own HTTP
# server, one source file) that prints every request whole.
# Eight captures, each run three times and hashed; cap() DIES when a hash differs from receipts.md5; every number the video says is
# asserted at the bottom by a check that can fail; the demo token is masked (gsub), and the checks count 0 raw copies of it in every
# capture, in the log of every run, in the stub's dump of every run and in every file this unit ships.
#   surface      the anchor built and extracted (61 libraries); the seven on its README's run line, a fresh JVM; the harness POM's
#                class path, the two jars joined; the harness compiled; the version attribute, read off spring-web; the three
#                handlers' mappings; Boot's eight spring.mvc.apiversion keys, from its own metadata; the resolvers and the
#                exceptions, read off the jar, each with its parents; the owners
#   strategy     A a header strategy with a default: it starts, and the header picks the handler; B no strategy: it does not
#                start; A' = A - each a fresh JVM
#   where        one fresh JVM per strategy - header, query parameter, media-type parameter, path segment - the same three
#                handlers, one request each, and the version sent somewhere else
#   unversioned  a header strategy with no default: the seven, every line that differs; required=false; a default of 1.0: the
#                seven; C (labelled) problem details off
#   baseline     1.1+ - 1.1, 1.2, 1; then 1.2 made a supported version
#   deprecation  1.0 marked for removal - the headers on a 1.0 answer, a 2.0 answer and an unversioned one, read off the headers;
#                the seven beside them; /actuator/mappings, exposed for one run
#   client       the stub; RestClient with each inserter; the stub's dump, a line per request; no inserter; the media-type pair end
#                to end; the service group's keys - default, the setter's spelling, none
#   exercise     exercise/README.md's commands, then exercise/solution/SOLUTION.md's, read from the files and run as written, one
#                after the other in ONE shell a viewer could have: env -i, /bin/bash, started in this folder
# "The anchor" is anchor/, the link to ../c6-unit28/after, COPIED under .harness/anchor; this script never writes into another unit's
# folder, and never builds a frozen tree in place. Every run of TiffinBox starts in .harness/anchor, which holds a config tree with a
# fake token (secrets/), as the README asks. Commands are printed exactly as they run: each goes through eval. "$CURLSET" is the
# comparison set since the secrets lesson (../c5-unit11/curlset.sh: the seven requests, POST /shutdown with the token's header read
# from the file). "$M2" is this unit's own repository, .m2-demo. "$S25" is the RestClient lesson's stub folder
# (../c6-unit25/harness/stub), read, never written. The harness - harness/probe/web, compiled with -parameters - is the course's,
# never TiffinBox's: outside com.tiffinbox, joined by --spring.main.sources on the extracted jar's class path, and named on every
# capture that uses it; harness/pom.xml names Boot's RestClient starter for dependency:build-classpath (R.26); harness/stub/ is the
# RestClient lesson's stub, byte for byte; harness/keys.py reads a jar's configuration metadata (the upload lesson's, byte for byte);
# harness/shutdown.sh is POST /shutdown with the token read from its file (the filters lesson's, byte for byte). Every run passes
# options only. The seven run first, on a fresh JVM of the jar.
# The locale: the JVM ignores LC_ALL on macOS - it takes the Mac's first language - and Spring's, Jackson's and Tomcat's messages in
# the log and in the answers are written in the JVM's locale: so every JVM this script starts - TiffinBox and the stub - has its
# locale pinned on its run line (-Duser.language=en -Duser.country=US, right after java), every one prints it, and the checks assert
# en_US. No request sends Accept-Language (curl sends none; the JDK's client sends none - the stub's dump shows every header).
# The network: every Maven build runs offline (-o) against .m2-demo and says so ("offline: yes"); a build that cannot resolve an
# artifact offline goes to Maven Central once, and says that ("offline: no - ..."). No native build, no Docker and no browser: this
# unit measures the JVM alone, with curl and the stub. At run time nothing leaves 127.0.0.1: TiffinBox and the stub listen there,
# every request goes there, and Logback writes to the terminal only. The deprecation link (http://127.0.0.1/docs/menu-1.0) is a
# header's text, never requested.
# Masks and filters (README.md declares each; awk sub/gsub only): the demo token becomes "[masked: the N-character token]" (N its
# own length); this folder's absolute path "…", the folder above it "…/..", the home folder "~"; your user name "<user>" - in every
# line of every capture. The JDK's version in the client's User-Agent becomes "<version>" (printed once on the terminal, R.136), and
# so does the one in Boot's first line (" using Java <version>", R.151). The handler method a failed start names - the first one
# the mapping scan met, which no rule fixes - becomes "<the first handler method the scan met>". Spring's error timestamp becomes
# "…" (both forms) in the seven and wherever an answer is printed. A run's log lines are printed from their logger on (no time, no
# process id, no thread); Boot's first line is cut before " with PID". A WARN or ERROR record is printed as its level, logger and
# message, then the exception line under it; its stack frames are bounded ("over 40") and its other lines counted, never shown. An
# answer's headers are kept by a declared filter, the kept lines counted beside the total. The stub's dump is one line per request
# with the header that carries the version, or none. /actuator/mappings is kept to the predicates that name /menu, the total beside
# them. No duration is captured.
# Ports (brief ⚑1, 19580-19589): TiffinBox 19580-19585 (one JVM at a time, each port asserted free before each start), the stub
# 19587, 19589 never bound (asserted free); 19586 and 19588 unused. Captures run one after another, each JVM stopped before the next
# starts - by POST /shutdown where it answers, else by its pid (a strategy with no default answers POST /shutdown 400). 18425
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
# $spid, the stub; $xpid, the exercise's shell, with every process under it - its Maven, its JVM, its curl), if they still run, then
# sweep(): anything of this run still alive in its process group - a TiffinBox JVM, a stub, a Maven - is stopped. After an
# interrupt, a capture's unfinished runs (.r-NAME.1-3) go too; after a failed check they stay, for the diff the message names. The
# clean-up ignores a second Ctrl-C, and nothing in it can fail under set -e, so it always reaches the rmdir; the script still exits
# 130 after an interrupt (README.md, "Interrupted"). $pid, $spid and $xpid are cleared whenever their process has been reaped.
# sweep() kills only processes of this run's own process group - start each run in a group of its own (README.md, "Interrupted").
# No wait in this script is bare: each names its pid.
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
# Boot's first line names the JDK ("using Java 25.0.4.1"): machine data, masked in every capture as "using Java <version>" (R.151) -
# the version printed here once, on the terminal
JV=$(java -version 2>&1 | sed -n '1s/.*version "\([^"]*\)".*/\1/p')
echo "  (terminal only) the JDK is $JV - Boot's first line names it; the captures say Java <version>"
for t in python3 curl rsync lsof unzip javac javap mvn cmp md5; do command -v $t > /dev/null || die "$t is needed"; done
# A variable of yours must not become a property source, a JVM flag or a build setting: every TIFFINBOX_*, SPRING_*, MANAGEMENT_*,
# SERVER_* and LOGGING_* variable, DEBUG (Boot reads it as --debug), the variables that inject JVM flags, MAVEN_OPTS, MAVEN_ARGS and
# NATIVE_IMAGE_OPTIONS are removed first (the last course's failure lesson's loop, verbatim: sed -E, a canary planted under every
# name first, and the run stops if one survives). This unit runs no Docker, so COMPOSE_* is not in the list. (A
# SPRING_MVC_APIVERSION_DEFAULT of yours would give every strategy here a default; a JAVA_TOOL_OPTIONS could set every JVM's locale.)
for v in TIFFINBOX_CANARY SPRING_CANARY MANAGEMENT_CANARY SERVER_CANARY LOGGING_CANARY DEBUG JAVA_TOOL_OPTIONS JDK_JAVA_OPTIONS _JAVA_OPTIONS MAVEN_OPTS MAVEN_ARGS NATIVE_IMAGE_OPTIONS; do export "$v=planted-canary"; done
for v in $(env | sed -n -E 's/^(TIFFINBOX_[A-Za-z0-9_]*|SPRING_[A-Za-z0-9_]*|MANAGEMENT_[A-Za-z0-9_]*|SERVER_[A-Za-z0-9_]*|LOGGING_[A-Za-z0-9_]*|DEBUG|JAVA_TOOL_OPTIONS|JDK_JAVA_OPTIONS|_JAVA_OPTIONS|MAVEN_OPTS|MAVEN_ARGS|NATIVE_IMAGE_OPTIONS)=.*/\1/p'); do unset "$v"; done
[ -z "$(env | grep -- '=planted-canary$')" ] || die "a variable survived the clean-up above: $(env | grep -- '=planted-canary$' | sed 's/=.*//' | paste -sd' ' -)"
# Every request this script makes goes to 127.0.0.1: an HTTP proxy named in your environment would carry curl's requests to that
# proxy instead - 127.0.0.1 and localhost go first in no_proxy and NO_PROXY.
export no_proxy="127.0.0.1,localhost${no_proxy:+,$no_proxy}" NO_PROXY="127.0.0.1,localhost${NO_PROXY:+,$NO_PROXY}"
[ -e secrets ] && die "this folder holds a secrets/ - remove it: every run here starts in a folder under .harness/"
[ -L anchor ] && [ "$(readlink anchor)" = ../c6-unit28/after ] || die "anchor must be the link to ../c6-unit28/after - this unit changes nothing in the anchor"
[ -f anchor/pom.xml ] && [ -f anchor/README.md ] && [ -f anchor/tiffinbox-web/pom.xml ] || die "the anchor (its pom.xml, README.md or web module's pom.xml) is missing"
[ -e anchor/secrets ] || [ -e anchor/target ] || [ -e anchor/tiffinbox-web/target ] || [ -e anchor/tiffinbox-core/target ] || [ -e anchor/tiffinbox-local.yaml ] && die "anchor/ holds a secrets/, a target/ or a tiffinbox-local.yaml - it is a frozen copy, never built in place"
M2="$PWD/.m2-demo"; U="$PWD"; UP="$(cd .. && pwd)"; ME="$(id -un)"
TF=secrets/tiffinbox/shutdown-token                  # the config tree's file for tiffinbox.shutdown-token
# The demo token. FAKE, and meant to look it: it guards nothing but a demo server on 127.0.0.1 that every capture stops. It is
# written into .harness/anchor/secrets/ (git-ignored) when this script runs, and no capture prints it: see mask().
TOKEN=demo-token-for-api-versioning-ok
[ ${#TOKEN} = 32 ] || die "the demo token must be 32 characters: the published captures name its length"
CURLSET=../c5-unit11/curlset.sh                      # the comparison set: the seven requests, POST /shutdown with the header
[ -f "$CURLSET" ] || die "$CURLSET is missing"
S25=../c6-unit25/harness/stub                        # the RestClient lesson's stub: read, never written
SMD5=42b656ddba1e9f80107495c65dacc975                # its Stub.java, as that lesson published it
WWW='customers.json meera.json priya.json ravi.json sunil.json'
HWS='harness/probe/web/Deprecations.java harness/probe/web/Menu.java harness/probe/web/MenuApi.java harness/probe/web/MenuGroup.java harness/probe/web/MenuPath.java harness/probe/web/Versions.java'
for f in harness/pom.xml harness/stub/Stub.java harness/shutdown.sh harness/keys.py $HWS exercise/README.md exercise/solution/SOLUTION.md README.md "$S25/Stub.java"; do [ -f "$f" ] || die "$f is missing"; done
[ "$(ls harness/probe/web | paste -sd' ' -)" = 'Deprecations.java Menu.java MenuApi.java MenuGroup.java MenuPath.java Versions.java' ] || die "harness/probe/web holds another file: javac compiles all of it"
[ "$(ls harness | paste -sd' ' -)" = 'keys.py pom.xml probe shutdown.sh stub' ] || die "harness/ holds another file"
[ "$(ls harness/stub/www | paste -sd' ' -)" = "$WWW" ] && [ "$(ls "$S25/www" | paste -sd' ' -)" = "$WWW" ] || die "harness/stub/www must hold the RestClient lesson's five files, and nothing else"
[ "$(ls harness/stub | paste -sd' ' -)" = 'Stub.java www' ] || die "harness/stub holds another file"
[ "$(ls exercise/solution | paste -sd' ' -)" = 'SOLUTION.md' ] && [ "$(ls exercise | paste -sd' ' -)" = 'README.md solution' ] || die "exercise/ holds another file: the exercise is the README's commands, the solution a key"
[ ! -e harness/target ] || die "harness/target exists - dependency:build-classpath builds nothing; remove it"
# The stub is the RestClient lesson's, byte for byte - its md5 as that lesson published it (a read of a frozen folder); this unit adds
# no route to it
[ "$(md5 -q harness/stub/Stub.java)" = "$SMD5" ] && [ "$(md5 -q "$S25/Stub.java")" = "$SMD5" ] || die "harness/stub/Stub.java must be the RestClient lesson's, md5 $SMD5"
for w in $WWW; do cmp -s "harness/stub/www/$w" "$S25/www/$w" || die "harness/stub/www/$w is not the RestClient lesson's, byte for byte"; done
cmp -s harness/shutdown.sh ../c6-unit18/harness/shutdown.sh || die "harness/shutdown.sh must be the filters lesson's, byte for byte"
cmp -s harness/keys.py ../c6-unit20/harness/keys.py || die "harness/keys.py must be the upload lesson's, byte for byte"
# The group's default version: Boot binds it from a field that carries @Name("default") - the key is ...apiversion.default. The
# setter's kebab case, which the binding rule of the client lessons (R.150) would give, is the labelled break of client (C): built
# here, never written whole in this file, and refused by a last check in every file this unit ships but README.md's labelled lines
DV='default'; DV="$DV-version"
# Boot 3's spelling of the client keys (the singular one) - built here, never written whole in this file (R.138)
K1='spring.http.client'; K1="$K1."
SB='--probe.stub=http://127.0.0.1:19587'
GB='--spring.http.serviceclient.menu.base-url=http://127.0.0.1:19587'
# The strategies' keys (Boot 4.1.1's metadata spells each: surface) - every option a capture passes is one of these, or Boot's
H='--spring.mvc.apiversion.use.header=API-Version'
Q='--spring.mvc.apiversion.use.query-parameter=version'
MT="'--spring.mvc.apiversion.use.media-type-parameter[application/json]=v'"
PS='--spring.mvc.apiversion.use.path-segment=1'
D10='--spring.mvc.apiversion.default=1.0'

# The ports, BEFORE anything is wiped (a survivor of an interrupted run answers POST /shutdown only with its token, which lives in
# .harness/ - so the message names the process to kill).
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
for p in 18425 8080 35729 19580 19581 19582 19583 19584 19585 19586 19587 19588 19589; do
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
# lines with the JVM's locale pinned; the harness POM's class path; the harness's javac line; the stub's run line; md5 of the stub
# against the RestClient lesson's; javap of the version attribute; the handlers' mappings; the metadata reader; the field's @Name;
# the two HttpExchange lines; a request and a request's headers, each saved to a file; the mappings saved to a file
mine() { grep -m1 -xF -- "$1" README.md > /dev/null || die "README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
JL='-Duser.language=en -Duser.country=US'
LIBD=.harness/anchor/tiffinbox-web/target/extracted/lib
HTTPJ=.harness/xlib/spring-boot-http-client-4.1.1.jar
L_RUNL=$(mine "java $JL -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431")
L_CPL=$(mine "java $JL -cp $CPL")
L_HCP=$(mine 'mvn -o -B -q -Dmaven.repo.local="$M2" -f harness/pom.xml dependency:build-classpath -Dmdep.outputFile="$PWD/.harness/harness.cp"')
L_JAVAC=$(mine "javac -parameters -d .harness/hc -cp \"$LIBD/*:.harness/xlib/*\" $HWS")
L_STUB=$(mine "java $JL harness/stub/Stub.java --port=19587 --www=harness/stub/www")
L_MD5=$(mine 'for f in Stub.java www/customers.json www/meera.json www/priya.json www/ravi.json www/sunil.json; do echo "$(md5 -q "harness/stub/$f") $(md5 -q "$S25/$f") $f"; done')
L_JAVAP=$(mine "javap -cp $LIBD/spring-web-7.0.9.jar org.springframework.web.bind.annotation.GetMapping org.springframework.web.bind.annotation.RequestMapping")
L_MAPS=$(mine "grep -n -E 'GetMapping\\(|^public class' harness/probe/web/Menu.java harness/probe/web/MenuPath.java")
L_KEYS=$(mine "python3 harness/keys.py $LIBD/spring-boot-webmvc-4.1.1.jar spring.mvc.apiversion")
L_NAME=$(mine "javap -v -p -cp $HTTPJ org.springframework.boot.http.client.autoconfigure.ApiversionProperties")
L_JDKX=$(mine "grep -n 'HttpExchange' harness/stub/Stub.java harness/probe/web/MenuApi.java")
L_ASK=$(mine "curl -s -o .harness/body.txt -w '%{http_code} %{content_type}' http://127.0.0.1:18431/menu")
L_HEAD=$(mine "curl -s -D .harness/head.txt -o .harness/body.txt -w '%{http_code}' http://127.0.0.1:18431/menu")
L_MAP=$(mine "curl -s -o .harness/mappings.json -w ' %{http_code}\n' http://127.0.0.1:18431/actuator/mappings")
# The derivations, each asserted
P_='java '; Q_="java $JL "; r=${R_RUN/"$P_"/$Q_}; r2=${R_CP/"$P_"/$Q_}
[ "$r" = "$L_RUNL" ] && [ "$r2" = "$L_CPL" ] || die "the pinned lines must be the anchor's run and class-path lines with $JL after java, and nothing else"
[ "${L_JAVAC#* -cp \"*\" }" = "$HWS" ] || die "the harness's javac line must compile the six files in harness/probe/web, and nothing else"
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
[ "$(exe "$(at .harness/x 19580 "$R_RUN")")" = "cd .harness/x && exec ${L_RUNL/18431/19580}" ] && [ "$(at .harness/x 18431 "$R_CP")" = "cd .harness/x && $L_CPL" ] && [ "$(at .harness/x 18431 "$R_EXTRACT")" = "cd .harness/x && $R_EXTRACT" ] || die "at(): the pinned lines are not README.md's"
[ "$(hcp .harness/x 19583 probe.web.Menu,probe.web.Versions "$H $D10")" = 'cd .harness/x && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../xlib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19583 --spring.main.sources=probe.web.Menu,probe.web.Versions --spring.mvc.apiversion.use.header=API-Version --spring.mvc.apiversion.default=1.0' ] || die "hcp()"
echo "  the commands: anchor/README.md gives the 5 lines this script runs or derives from; README.md the 14 this unit adds"
# ---- build: before the captures - the anchor built once, the harness POM's class path read once (on a fresh clone these fill
# ---- .m2-demo); what .m2-demo holds ---------------------------------------------------------------------------------------------
rm -rf .harness; mkdir -p .harness
# mbuild 'COMMAND' LOG LABEL: the command, run as printed (eval), its log kept in LOG (never printed whole); Maven Central only if the
# offline build could not resolve something - and the line says which (offline: yes / no), so a run that went online is never
# silent (inside a capture, "no" changes the capture's hash: cap() then dies).
mbuild() { local how=yes ec=0 c=$1
  (eval "$c") > "$2" 2>&1 < /dev/null || ec=$?
  if [ $ec != 0 ] && grep -qE 'offline mode|Could not resolve|could not be resolved|Cannot access|No plugin found for prefix' "$2"; then
    how="no - the offline build could not resolve an artifact, so the configured repository was asked (Maven Central unless your settings name a mirror)"; ec=0
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
[ ! -e harness/target ] || die "a build wrote harness/target"
for a in spring-boot-restclient spring-boot-http-client spring-boot-starter-restclient; do
  [ -f "$M2/org/springframework/boot/$a/4.1.1/$a-4.1.1.jar" ] || die "$a 4.1.1 is not in .m2-demo after the first builds"; done
[ ! -e "$M2/org/apache/httpcomponents/client5/httpclient5" ] || [ -z "$(grep -F httpclient5 .harness/harness.cp || true)" ] || die "httpclient5 is on the harness's class path - every factory sentence would change"
echo "  .m2-demo holds Boot's RestClient starter and the two jars it brings, 4.1.1"

# ---- helpers ------------------------------------------------------------------------------------------------------------
# raw TOKEN FILE...: how many times TOKEN appears, raw, in the files (occurrences, not lines; binary files read as text)
raw() { local t=$1; shift; cat "$@" | LC_ALL=C grep -aoF -- "$t" | wc -l | tr -d ' '; }
LOGS=0; DUMPS=0; LASTE=""                            # logs counted: served runs; the stub's dumps counted
first() { grep -m1 -E ' : Starting |^main Starting ' "$1" | sed 's/^.* : //; s/^main //; s/ with PID .*$//'; }
start() { local p; p=$(printf '%s\n' "$1" | sed -n 's/.*--tiffinbox\.port=\([0-9]*\).*/\1/p'); [ -n "$p" ] && [ "$(listeners "$p")" = 0 ] || die "port ${p:-?} is not free before a start"
  echo "\$ $1"; (eval "$(exe "$1")") > .harness/run.out 2> .harness/run.err < /dev/null & pid=$!; }
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
# seven PORT DIR: the comparison set's seven requests (POST /shutdown carries the header, read from DIR's token file), every line
# printed, the timestamp masked; how many lines the run's log gained during the seven (settled before and after) and the WARN and
# ERROR records among them; then the JVM: when POST /shutdown answered 2xx it must leave within 15 s and free the port - else (a
# strategy with no default answers it 400, R.152) it is stopped by its pid, and the exit line says so; the md5 of the seven after
# the timestamp mask and how many lines the mask changed; the log counted (logtok) - the masked set kept as .harness/seven-NAME.txt
seven() { local m n0 n1 how=""
  settle; n0=$(wc -l < .harness/run.out | tr -d ' ')
  echo "\$ \$CURLSET $1 $2/$TF"
  "$CURLSET" "$1" "$2/$TF" | grep ' -> ' > .harness/responses.txt || true
  tsmask < .harness/responses.txt > .harness/responses.m.txt
  sed 's/^/  /' .harness/responses.m.txt
  settle; n1=$(wc -l < .harness/run.out | tr -d ' ')
  echo "  the log's lines during the seven: $((n1 - n0)) · its WARN and ERROR records among them: $(logl "$n0" | grep -c . || true)"; logl "$n0"
  if grep -qE '^POST +/shutdown +-> 2[0-9][0-9] ' .harness/responses.txt; then exited "$1"
  else kill "$pid" 2> /dev/null || true; LASTE=0; wait "$pid" || LASTE=$?; pid=""; [ "$(listeners "$1")" = 0 ] || die "something still listens on $1"
    how=" (POST /shutdown answered $(grep -E '^POST +/shutdown' .harness/responses.txt | awk '{ print $4 }'): stopped by its pid)"; fi
  m=$(diff .harness/responses.txt .harness/responses.m.txt | grep -c '^<' || true)
  echo "  exit $LASTE$how · the seven responses: $(wc -l < .harness/responses.m.txt | tr -d ' ') lines · lines the timestamp mask changed: $m · md5 $(md5 -q .harness/responses.m.txt)"
  cp .harness/responses.m.txt ".harness/seven-$3.txt"
  logtok; }
# diff7 A B: the seven of run A against run B's, masked, line for line - which lines differ and which are the same, byte for byte
diff7() { python3 - ".harness/seven-$1.txt" ".harness/seven-$2.txt" <<'PY7'
import sys
a = open(sys.argv[1], encoding="utf-8").read().splitlines(); b = open(sys.argv[2], encoding="utf-8").read().splitlines()
d = [i for i in range(max(len(a), len(b))) if i >= len(a) or i >= len(b) or a[i] != b[i]]
s = [i for i in range(min(len(a), len(b))) if a[i] == b[i]]
print("  lines that differ: %d%s · the same, byte for byte: %d%s" % (len(d), (" (" + " ".join(str(i + 1) for i in d) + ")") if d else "", len(s), (" (" + " ".join(str(i + 1) for i in s) + ")") if s else ""))
PY7
}
# halt PORT DIR: POST /shutdown with DIR's token; when it answered 2xx the JVM must leave within 15 s and free the port; else (400:
# a strategy with no default, R.152) it is stopped by its pid - the line says which; its exit code; its log counted (logtok)
halt() { local o c e=0
  echo "\$ harness/shutdown.sh $1 $2/$TF"; o=$(harness/shutdown.sh "$1" "$2/$TF" | tsmask); echo "  $o"; c=$(printf '%s\n' "$o" | awk '{ print $4 }')
  case $c in 2[0-9][0-9]) exited "$1"; echo "  exit $LASTE · listening on $1 now: 0" ;;
    *) kill "$pid" 2> /dev/null || true; wait "$pid" || e=$?; pid=""; LASTE=$e; [ "$(listeners "$1")" = 0 ] || die "something still listens on $1"
       echo "  POST /shutdown answered $c: stopped by its pid · exit $e · listening on $1 now: 0" ;; esac
  logtok; }
# nostart PORT: the JVM started last ($pid) must exit before it ever listens on PORT (polled every 0.25 s, up to 120 s); its exit
# code; Boot's first line; its WARN and ERROR records (recs); every "Caused by:" line of its log, the last one its root cause; its
# log counted (logtok)
nostart() { local i=0 e=0
  while kill -0 "$pid" 2> /dev/null && [ $i -lt 480 ]; do [ "$(listeners "$1")" = 0 ] || { kill -9 "$pid"; die "it started on $1"; }; sleep 0.25; i=$((i + 1)); done
  kill -0 "$pid" 2> /dev/null && { kill "$pid"; die "it neither started nor stopped within 120 s"; }
  wait "$pid" || e=$?; pid=""
  echo "  exit $e · listening on $1: $(listeners "$1") (lsof, by port) · readiness never asked · Boot's first line: $(first .harness/run.out)"
  echo "  its WARN and ERROR records:"; recs 0
  echo "  its \"Caused by:\" lines, in the order they printed: $(grep -c '^Caused by: ' .harness/run.out || true) - the last is the root cause"
  grep '^Caused by: ' .harness/run.out | sed 's/^/    /'
  logtok; }
# The stub. sstart: its run line (this unit's), printed and run from this folder, its output to .harness/stub.out; then its bind,
# read off its pid (polled until it listens on 19587, up to 120 s - it compiles itself first), and the locale it printed. sstop: the
# stub stopped by its pid (TERM: it has no shutdown route), waited for, 19587 free; its dump counted - the demo token 0 times and the
# header X-Shutdown-Token 0 times (R.137) - and how many requests it printed. Every start begins a new dump (and the stub's payment
# numbers start again at pay-1).
sstart() { local l; echo "\$ $L_STUB"; (eval "exec $L_STUB") > .harness/stub.out 2>&1 < /dev/null & spid=$!
  l=$(listening "$spid" 19587); [ "$l" != nothing ] || { tail -20 .harness/stub.out >&3; die "the stub never listened"; }
  echo "  the stub listens on: $l · loopback only: $(lb "$l") · its locale: $(grep -m1 "^STUB the JVM's locale: " .harness/stub.out | sed "s/^.*locale: //")"; }
sstop() { local e=0 t h n
  kill "$spid" 2> /dev/null || true; wait "$spid" || e=$?; spid=""
  [ "$(listeners 19587)" = 0 ] || die "something still listens on 19587"
  t=$(raw "$TOKEN" .harness/stub.out); h=$(LC_ALL=C grep -aoi -- 'x-shutdown-token' .harness/stub.out | wc -l | tr -d ' '); n=$(grep -c '^STUB [A-Z]* /' .harness/stub.out || true)
  DUMPS=$((DUMPS + 1)); [ "$t" = 0 ] && [ "$h" = 0 ] || die "the stub's dump held the demo token ($t) or its header's name ($h)"
  echo "  the stub: stopped by its pid · exit $e · listening on 19587 now: 0 · requests in its dump: $n · the demo token 0 times · X-Shutdown-Token $h times"
  [ -z "$(grep -m1 '^STUB-H user-agent: ' .harness/stub.out)" ] || grep -m1 '^STUB-H user-agent: ' .harness/stub.out | sed 's/^STUB-H user-agent: //' > .harness/ua.txt; }
mask() { awk -v t="$TOKEN" -v u="$U" -v up="$UP" -v hm="$HOME" -v me="$ME" -v tl="${#TOKEN}" '
  function lit(x) { gsub(/[][\\.^$*+?(){}|\/]/, "\\\\&", x); return x }
  function enc(x) { gsub(/ /, "%20", x); return x }
  BEGIN { T = lit(t); P = lit(u); Q = lit(up); H = lit(hm); PE = lit(enc(u)); QE = lit(enc(up)); M = "(^|[^A-Za-z0-9_])" lit(me) "([^A-Za-z0-9_]|$)" }
  { gsub(T, "[masked: the " tl "-character token]"); gsub(P, "…"); gsub(PE, "…")
    gsub(Q, "…/.."); gsub(QE, "…/.."); gsub(H, "~");
    gsub(/Java-http-client\/[0-9][0-9.]*/, "Java-http-client/<version>")
    gsub(/ using Java [0-9][0-9.]*/, " using Java <version>")
    gsub(/java\.util\.Map probe\.web\.[A-Za-z]+\.[A-Za-z0-9]+\(\)( throws [A-Za-z.]+)?/, "<the first handler method the scan met>")
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
# recs FROM: each WARN or ERROR record the log gained after line FROM (the harness's VER lines skipped) - its level, its logger and
# its message; then the exception line under it (the first line after the record that is neither blank nor a stack frame); its stack
# frames, bounded ("over 40"), and its other lines, counted - none shown
recs() { awk -v from="$1" '
  function out() { if (inr) print "      its stack frames: " (fr > 40 ? "over 40" : fr + 0) ", its other lines: " (ot + 0) " - none shown"; inr = 0; fr = 0; ot = 0; ex = 0 }
  NR <= from { next }
  /^VER / { next }
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
# vers: the harness's VER lines, whole - after Versions' "done" line, which must be there: Versions' lines in the order they printed,
# then MenuGroup's (two runners: which of them runs first is not fixed, so each one's lines are kept together); vloc: the JVM's locale, as Versions printed it
vers() { grep -q '^VER done$' .harness/run.out || { tail -20 .harness/run.out >&3; die "the harness's Versions never printed done"; }
  echo "  the harness's lines (Versions', in the order they printed, then MenuGroup's): $(grep -c '^VER ' .harness/run.out)"; grep '^VER ' .harness/run.out | grep -v "^VER the JVM's locale: " | grep -v '^VER group ' | sed 's/^VER /    /'
  grep '^VER group ' .harness/run.out | sed 's/^VER /    /' || true; }
vloc() { echo "  the JVM's locale (the harness's Versions): $(grep -m1 "^VER the JVM's locale: " .harness/run.out | sed "s/^.*locale: //")"; }
# The stub's dump. sdump FROM: every line it printed after line FROM, whole, each after a "|" (the requests, every header, every
# body, every answer); sreqs FROM: one line per request after line FROM - its method and URI, its header count, and the stub's answer
# (the line after its headers and body)
sdump() { local n; n=$(awk -v f="$1" 'NR > f' .harness/stub.out | grep -c . || true); echo "  the stub's dump since, whole: $n lines"; awk -v f="$1" 'NR > f { print "    | " $0 }' .harness/stub.out; }
sreqs() { awk -v f="$1" 'NR <= f { next } /^STUB [A-Z]+ \// { if (q != "") print q " · headers: " h " · no answer"; q = "    " $2 " " $3; h = 0; next } /^STUB-H / { h++; next }
    /^STUB-ANSWER / { a = $0; sub(/^STUB-ANSWER /, "", a); if (q == "") print "    a late answer, its request above: " a; else print q " · headers: " h " · the stub answered " a; q = ""; next } END { if (q != "") print q " · headers: " h " · no answer" }' .harness/stub.out; }
# blkraw FROM TO: this capture so far, the lines after the line that starts with FROM, up to the next line that starts with TO (to
# the end when TO is empty); asame A B A2 B2: yes when A's block (A up to B) and A2's (A2 up to B2), their labels aside, are the same
# line for line - an A' against its A
blkraw() { awk -v a="$1" -v b="$2" 'index($0, a) == 1 { f = 1; next } b != "" && index($0, b) == 1 { f = 0 } f' .harness/cap.raw; }
asame() { [ "$(blkraw "$1" "$2")" = "$(blkraw "$3" "$4")" ] && [ -n "$(blkraw "$3" "$4")" ] && echo yes || echo no; }
# ask PORT ['CURL OPTIONS'] [PATH]: this unit's request line (README.md) - its port made PORT, OPTIONS before the URL, /menu made
# PATH - printed and run; then what curl wrote: the status and the content type, and the body, the timestamp masked
ask() { local c r; c=$(url "$L_ASK" "$1"); [ -z "$3" ] || c="${c%/menu}$3"; [ -z "$2" ] || c=${c/ http:\/\/127/ $2 http://127}
  rm -f .harness/body.txt; echo "\$ $c"; r=$(eval "$c" 2>&1 < /dev/null) || true; echo "  -> $r · $(tsmask < .harness/body.txt 2> /dev/null)"; }
# heads PORT ['CURL OPTIONS'] [PATH]: this unit's header line (README.md), the same way - the status; the answer's header lines,
# counted (the status line among them), and kept by the declared filter ^(Deprecation|Sunset|Link|Content-Type): (any case); the body
HF='^(deprecation|sunset|link|content-type): '
heads() { local c r; c=$(url "$L_HEAD" "$1"); [ -z "$3" ] || c="${c%/menu}$3"; [ -z "$2" ] || c=${c/ http:\/\/127/ $2 http://127}
  rm -f .harness/body.txt .harness/head.txt; echo "\$ $c"; r=$(eval "$c" 2>&1 < /dev/null) || true
  tr -d '\r' < .harness/head.txt | grep . > .harness/head.n.txt || true
  echo "  -> $r · its header lines: $(wc -l < .harness/head.n.txt | tr -d ' ') · kept, by ^(Deprecation|Sunset|Link|Content-Type): (any case): $(grep -ciE "$HF" .harness/head.n.txt || true)"
  grep -iE "$HF" .harness/head.n.txt | sed 's/^/    /' || true
  echo "    its body: $(tsmask < .harness/body.txt)"; }
# sver FROM: the stub's dump after line FROM, one line per request - its method and URI; the three headers a version can ride on
# (api-version, accept, content-type), each with its value or "none"; how many headers it had; and the stub's answer
sver() { awk -v f="$1" 'function fl() { if (q != "") print q " · api-version: " av " · accept: " ac " · content-type: " ct " · headers: " h " · " (an == "" ? "no answer" : "the stub answered " an); q = "" }
    NR <= f { next }
    /^STUB [A-Z]+ \// { fl(); q = "    " $2 " " $3; h = 0; av = "none"; ac = "none"; ct = "none"; an = ""; next }
    /^STUB-H / { if (q == "") next; h++; v = $0; sub(/^STUB-H [^:]*: /, "", v)
      if (index($0, "STUB-H api-version: ") == 1) av = v; if (index($0, "STUB-H accept: ") == 1) ac = v; if (index($0, "STUB-H content-type: ") == 1) ct = v; next }
    /^STUB-ANSWER / { an = $0; sub(/^STUB-ANSWER /, "", an); fl(); next }
    END { fl() }' .harness/stub.out; }
# mapsf FILE: /actuator/mappings' answer - every predicate its dispatcherServlets list, counted; kept, by the filter "/menu" (the
# predicates that name the path), sorted
mapsf() { python3 - "$1" <<'PYM'
import json, sys
d = json.load(open(sys.argv[1], encoding="utf-8"))
p = [m.get("predicate", "") for c in d["contexts"].values() for ms in c["mappings"].get("dispatcherServlets", {}).values() for m in ms]
k = sorted(x for x in p if "/menu" in x)
print("  the predicates its dispatcherServlets list: %d · kept, by the filter \"/menu\", sorted: %d" % (len(p), len(k)))
for x in k: print("    " + x)
PYM
}
# The level counts, the record filter, the stub's dump filters and the masks, checked on planted inputs before any capture (R.65,
# R.120): a harness line that says ERROR, one WARN and one ERROR record - each count must be 1 by the log's own line shape, where a
# bare ' ERROR ' counts 2; a planted dump with a header given twice, a version header, a body, an answer, a request with no answer;
# two client versions, Boot's first line, a handler method a failed start names, and the token
mkdir -p .harness
{ printf '%s\n' 'VER path !! org.springframework.web.client.HttpClientErrorException$NotFound: 404 Not Found: ERROR' '2026-10-22T00:00:00.000+02:00  WARN 1 --- [planted] o.s.web.servlet.PageNotFound             : planted warning' '2026-10-22T00:00:00.001+02:00 ERROR 1 --- [planted] o.s.boot.SpringApplication               : planted error' 'java.lang.IllegalStateException: planted' "$(printf '\tat a')" 'VER done'; } > .harness/run.out
[ "$(logl 0 ERROR | grep -c .)" = 1 ] && [ "$(logl 0 WARN | grep -c .)" = 1 ] && [ "$(lvl ERROR .harness/run.out)" = 1 ] && [ "$(lvl WARN .harness/run.out)" = 1 ] && [ "$(grep -c ' ERROR' .harness/run.out)" = 2 ] || die "the level counts: the planted log must give 1 WARN and 1 ERROR by line shape (a bare ' ERROR' gives 2)"
[ "$(recs 0)" = "$(printf '%s\n' '    WARN o.s.web.servlet.PageNotFound: planted warning' '      its stack frames: 0, its other lines: 0 - none shown' '    ERROR o.s.boot.SpringApplication: planted error' '      java.lang.IllegalStateException: planted' '      its stack frames: 1, its other lines: 0 - none shown')" ] || die "recs: the planted log's harness lines must be skipped (.harness/run.out)"
printf '%s\n' 'STUB listening on /127.0.0.1:19587' 'STUB GET /customers.json headers=[Accept, Api-version, Host]' 'STUB-H accept: application/json' 'STUB-H api-version: 1.1' 'STUB-H host: 127.0.0.1:19587' 'STUB-ANSWER 200 application/json 13 bytes' 'STUB POST /payments headers=[Accept-encoding, Content-type, Host]' 'STUB-H accept-encoding: gzip' 'STUB-H accept-encoding: deflate' 'STUB-H content-type: application/json;v=1.1' 'STUB-H host: 127.0.0.1:19587' 'STUB-BODY {"customer":"Ravi","amount":7200}' 'STUB-ANSWER 201 application/json 62 bytes' 'STUB GET /1.1/customers.json headers=[Host]' 'STUB-H host: 127.0.0.1:19587' > .harness/stub.out
PL=$(sver 1); [ "$PL" = "$(printf '%s\n' '    GET /customers.json · api-version: 1.1 · accept: application/json · content-type: none · headers: 3 · the stub answered 200 application/json 13 bytes' '    POST /payments · api-version: none · accept: none · content-type: application/json;v=1.1 · headers: 4 · the stub answered 201 application/json 62 bytes' '    GET /1.1/customers.json · api-version: none · accept: none · content-type: none · headers: 1 · no answer')" ] || die "sver: the planted dump does not come out as declared (got: $PL)"
PL=$(sreqs 1); [ "$PL" = "$(printf '%s\n' '    GET /customers.json · headers: 3 · the stub answered 200 application/json 13 bytes' '    POST /payments · headers: 4 · the stub answered 201 application/json 62 bytes' '    GET /1.1/customers.json · headers: 1 · no answer')" ] || die "sreqs: the planted dump does not come out as declared (got: $PL)"
printf '%s\n' 'Java-http-client/25.0.4.1 and Java-http-client/23' 'Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1' 'Invalid mapping on handler class [probe.web.Menu]: java.util.Map probe.web.Menu.count() throws java.sql.SQLException' "$TOKEN" > .harness/p1
[ "$(mask < .harness/p1)" = "$(printf '%s\n' 'Java-http-client/<version> and Java-http-client/<version>' 'Starting TiffinBoxServer v1.0.0 using Java <version>' 'Invalid mapping on handler class [probe.web.Menu]: <the first handler method the scan met>' '[masked: the 32-character token]')" ] || die "mask: the planted User-Agent versions, Boot's JDK version, the handler method and the token must be masked"
printf '%s\n' '{"contexts":{"application":{"mappings":{"dispatcherServlets":{"dispatcherServlet":[{"predicate":"{GET [/menu], version [2.0]}"},{"predicate":"{GET [/customers]}"},{"predicate":"{GET [/menu], version [1.0]}"}]}}}}}' > .harness/p1
PL=$(mapsf .harness/p1); [ "$PL" = "$(printf '%s\n' '  the predicates its dispatcherServlets list: 3 · kept, by the filter "/menu", sorted: 2' '    {GET [/menu], version [1.0]}' '    {GET [/menu], version [2.0]}')" ] || die "mapsf: the planted answer does not come out as declared (got: $PL)"
printf 'HTTP/1.1 200 \r\nDeprecation: @1\r\nsunset: x\r\nVary: Origin\r\n\r\n' > .harness/head.txt; tr -d '\r' < .harness/head.txt | grep . > .harness/head.n.txt
[ "$(grep -ciE "$HF" .harness/head.n.txt)" = 2 ] && [ "$(wc -l < .harness/head.n.txt | tr -d ' ')" = 4 ] || die "heads: the planted headers must give 4 lines, 2 kept (any case)"
rm -f .harness/run.out .harness/stub.out .harness/p1 .harness/head.txt .harness/head.n.txt
echo "  the filters: the record filter, the stub's dump filters, the mappings filter, the header filter and the masks print their planted inputs as declared; a harness line that says ERROR is no ERROR line"

# ---- surface: the attribute, the keys, the classes - read off the jars; the seven -----------------------------------------------
surface() { local c j n
  echo "the anchor - anchor/, copied under .harness/ with a config tree, built with its README's line (offline), its jar extracted (the README's line):"
  copy anchor .harness/anchor; pbuild .harness/anchor "the anchor"; extract .harness/anchor
  echo "  the anchor's libraries (its extracted lib/): $(ls "$LIBD" | grep -c '\.jar$') · Boot's RestClient module among them: $(ls "$LIBD" | grep -c '^spring-boot-restclient-' || true) · httpclient5: $(ls "$LIBD" | grep -c '^httpclient5-' || true)"
  echo "the seven - the anchor, the README's run line (its locale pinned), port 19580, a fresh JVM:"
  start "$(at .harness/anchor 19580 "$R_RUN")"; up 19580; ready 19580; seven 19580 .harness/anchor base; WARNS
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
  echo "the version attribute - the two mapping annotations, read off spring-web (this unit's line):"
  echo "\$ $L_JAVAP"; (eval "$L_JAVAP") > .harness/javap.out 2>&1 < /dev/null || die "javap could not read the two annotations"
  echo "  what javap printed: $(wc -l < .harness/javap.out | tr -d ' ') lines · kept: each annotation's line and its version attribute, $(grep -cE '^public interface|version\(\);' .harness/javap.out) lines"
  grep -E '^public interface|version\(\);' .harness/javap.out | sed 's/^/  /; s/ {$//'
  echo "the harness's handlers - one path, three versions, and the same three in the path (this unit's line):"
  echo "\$ $L_MAPS"; (eval "$L_MAPS") 2>&1 < /dev/null | sed 's/^/  /'
  echo "  mappings with a version: $(grep -c 'GetMapping(.*version = ' harness/probe/web/Menu.java harness/probe/web/MenuPath.java | awk -F: '{ s += $NF } END { print s + 0 }') · on /menu: $(grep -c 'GetMapping(path = "/menu", version = ' harness/probe/web/Menu.java) · in TiffinBox's own sources: $(grep -rc 'version = ' anchor/tiffinbox-web/src/main anchor/tiffinbox-core/src/main | awk -F: '{ s += $NF } END { print s + 0 }')"
  echo "Boot's keys - what spring-boot-webmvc's own metadata declares under spring.mvc.apiversion (this unit's line):"
  echo "\$ $L_KEYS"; (eval "$L_KEYS") 2>&1 < /dev/null | sed 's/^/  /'
  # keys.py (byte for byte the upload lesson's) prints a type from its last dot on - for a generic type, its tail ("String>"); the
  # cut types whole, read off the same metadata, beside it
  echo "  the types keys.py cut, whole (it keeps what follows the last dot): $(python3 -c 'import json,sys,zipfile; m=json.loads(zipfile.ZipFile(sys.argv[1]).read("META-INF/spring-configuration-metadata.json")); print(" · ".join(p["name"].rsplit(".", 1)[1] + " " + p["type"] for p in m["properties"] if p["name"].startswith("spring.mvc.apiversion.") and p["type"].endswith(">")))' "$LIBD/spring-boot-webmvc-4.1.1.jar")"
  echo "the versioning classes - every class of spring-web-7.0.9.jar's org.springframework.web.accept whose name says ApiVersion, inner classes aside, read with javap (its declaration line):"
  j="$LIBD/spring-web-7.0.9.jar"
  for c in $(unzip -Z1 "$j" 'org/springframework/web/accept/*ApiVersion*.class' | grep -v '\$' | sed 's/\.class$//' | tr / . | sort); do
    javap -cp "$j" "$c" | sed -n 2p | sed 's/ {$//; s/org\.springframework\.web\.accept\.//g; s/org\.springframework\.web\.server\.//g; s/^/  /'; done
  echo "  the classes that implement ApiVersionResolver - the places a version is read: $(for c in $(unzip -Z1 "$j" 'org/springframework/web/accept/*.class' | grep -v '\$' | sed 's/\.class$//' | tr / .); do javap -cp "$j" "$c" | sed -n 2p | grep -q 'implements .*org\.springframework\.web\.accept\.ApiVersionResolver' && echo "${c##*.}"; done | sort | paste -sd' ' -)"
  echo "  the exceptions, each followed up its parents to the first class outside the package:"
  for c in $(unzip -Z1 "$j" 'org/springframework/web/accept/*Exception.class' | sed 's/\.class$//' | tr / . | sort); do
    n=$c; l=${c##*.}; while :; do n=$(javap -cp "$j" "$n" | sed -n 2p | sed -n 's/.* extends \([^ ]*\).*/\1/p'); l="$l -> ${n##*.}"; case $n in org.springframework.web.accept.*) ;; *) break ;; esac; done
    echo "    $l"; done
  echo "whose classes - each read off the one jar on that class path that holds it (unzip -l, by name):"
  for c in org/springframework/web/bind/annotation/GetMapping org/springframework/web/accept/ApiVersionStrategy org/springframework/web/accept/StandardApiVersionDeprecationHandler org/springframework/web/client/ApiVersionInserter org/springframework/web/servlet/config/annotation/ApiVersionConfigurer 'org/springframework/boot/webmvc/autoconfigure/WebMvcProperties$Apiversion' org/springframework/boot/http/client/autoconfigure/ApiversionProperties; do
    echo "  $(printf '%s' "$c" | tr / .) · in: $(for j in "$LIBD"/*.jar .harness/xlib/*.jar; do unzip -l "$j" "$c.class" > /dev/null 2>&1 && echo "${j##*/}"; done | paste -sd' ' -)"; done; }

# ---- strategy: A a header strategy with a default; B no strategy; A' = A -------------------------------------------------------
arun() { start "$(hcp .harness/anchor 19580 probe.web.Menu,probe.web.Versions "$H $D10")"; up 19580; ready 19580; vloc; vers
  ask 19580 "-H 'API-Version: 1.0'"; ask 19580 "-H 'API-Version: 1.1'"; ask 19580 "-H 'API-Version: 2.0'"; ask 19580
  WARNS; halt 19580 .harness/anchor; }
strategy() {
  echo "A - a header strategy with a default: the harness's Menu and Versions joined, the header API-Version, 1.0 for a request without one, port 19580, a fresh JVM:"
  arun
  echo "B - the same handlers, no spring.mvc.apiversion key, port 19581, a fresh JVM:"
  start "$(hcp .harness/anchor 19581 probe.web.Menu,probe.web.Versions)"; nostart 19581
  echo "A' - A again, port 19580, a fresh JVM:"
  arun
  echo "A' against A, its label aside, line for line the same: $(asame "A - " "B - " "A' - " "A' against A")"; }

# ---- where: one fresh JVM per strategy, the same handlers, the version sent somewhere else -------------------------------------
where_() {
  echo "  19589, never bound: listening $(listeners 19589) (lsof, by port)"
  echo "the header - Menu and Versions, the header API-Version, no default, port 19580, a fresh JVM:"
  start "$(hcp .harness/anchor 19580 probe.web.Menu,probe.web.Versions "$H")"; up 19580; ready 19580; vloc; vers
  ask 19580 "-H 'API-Version: 1.0'"; ask 19580 "-H 'API-Version: 1.1'"; ask 19580 "-H 'API-Version: 2.0'"
  echo "  the control - the version in the query instead:"; ask 19580 "" "/menu?version=1.0"
  WARNS; halt 19580 .harness/anchor
  echo "the query parameter - Menu and Versions, the parameter version, no default, port 19581, a fresh JVM:"
  start "$(hcp .harness/anchor 19581 probe.web.Menu,probe.web.Versions "$Q")"; up 19581; ready 19581; vloc; vers
  ask 19581 "" "/menu?version=1.0"; ask 19581 "" "/menu?version=1.1"; ask 19581 "" "/menu?version=2.0"
  echo "  the control - the version in the header instead:"; ask 19581 "-H 'API-Version: 1.0'"
  WARNS; halt 19581 .harness/anchor
  echo "the media-type parameter - Menu and Versions, the parameter v of application/json, no default, port 19582, a fresh JVM:"
  start "$(hcp .harness/anchor 19582 probe.web.Menu,probe.web.Versions "$MT")"; up 19582; ready 19582; vloc; vers
  ask 19582 "-H 'Accept: application/json;v=1.0'"; ask 19582 "-H 'Accept: application/json;v=1.1'"; ask 19582 "-H 'Accept: application/json;v=2.0'"
  echo "  the control - the parameter on Content-Type instead of Accept:"; ask 19582 "-H 'Content-Type: application/json;v=1.0'"
  WARNS; halt 19582 .harness/anchor
  echo "the path segment - MenuPath and Versions, the segment at index 1, no default, port 19583, a fresh JVM:"
  start "$(hcp .harness/anchor 19583 probe.web.MenuPath,probe.web.Versions "$PS")"; up 19583; ready 19583; vloc; vers
  ask 19583 "" "/api/1.0/menu"; ask 19583 "" "/api/1.1/menu"; ask 19583 "" "/api/2.0/menu"; ask 19583 "" "/api/v1/menu"
  echo "  the control - the version in the header instead, on a path with no segment for it:"; ask 19583 "-H 'API-Version: 1.0'" "/customers"
  WARNS; halt 19583 .harness/anchor; }

# ---- unversioned: the routes that never asked for a version ----------------------------------------------------------------------
unversioned() {
  echo "a header strategy, no default - Menu and Versions, the header API-Version, port 19580, a fresh JVM - and the seven:"
  start "$(hcp .harness/anchor 19580 probe.web.Menu,probe.web.Versions "$H")"; up 19580; ready 19580; vloc; vers
  ask 19580; seven 19580 .harness/anchor hdr; WARNS
  echo "  against the seven on the README's run line (surface, md5 $(md5 -q .harness/seven-base.txt)), line for line:"; diff7 base hdr
  echo "required=false - the same, and spring.mvc.apiversion.required=false, port 19581, a fresh JVM - and the seven:"
  start "$(hcp .harness/anchor 19581 probe.web.Menu,probe.web.Versions "$H --spring.mvc.apiversion.required=false")"; up 19581; ready 19581; vloc; vers
  ask 19581; seven 19581 .harness/anchor req; WARNS
  echo "  against the seven on the README's run line, line for line:"; diff7 base req
  echo "a default - the header strategy and a default version, 1.0, port 19582, a fresh JVM - and the seven:"
  start "$(hcp .harness/anchor 19582 probe.web.Menu,probe.web.Versions "$H $D10")"; up 19582; ready 19582; vloc; vers
  ask 19582; seven 19582 .harness/anchor def; WARNS
  echo "  against the seven on the README's run line, line for line:"; diff7 base def
  echo "C (labelled) - the header strategy, no default, and TiffinBox's problem details switched off for this run (spring.mvc.problemdetails.enabled=false), port 19583, a fresh JVM:"
  start "$(hcp .harness/anchor 19583 probe.web.Menu,probe.web.Versions "$H --spring.mvc.problemdetails.enabled=false")"; up 19583; ready 19583; vloc; vers
  ask 19583; ask 19583 "" "/customers"
  WARNS; halt 19583 .harness/anchor; }

# ---- baseline: 1.1+ -------------------------------------------------------------------------------------------------------------
baseline() {
  echo "the baseline - the header strategy, a default of 1.0, port 19580, a fresh JVM:"
  start "$(hcp .harness/anchor 19580 probe.web.Menu,probe.web.Versions "$H $D10")"; up 19580; ready 19580; vloc; vers
  ask 19580 "-H 'API-Version: 1.1'"; ask 19580 "-H 'API-Version: 1.2'"; ask 19580 "-H 'API-Version: 1'"
  WARNS; halt 19580 .harness/anchor
  echo "1.2 made a supported version - the same, and spring.mvc.apiversion.supported=1.2, port 19581, a fresh JVM:"
  start "$(hcp .harness/anchor 19581 probe.web.Menu,probe.web.Versions "$H $D10 --spring.mvc.apiversion.supported=1.2")"; up 19581; ready 19581; vloc; vers
  ask 19581 "-H 'API-Version: 1.2'"
  WARNS; halt 19581 .harness/anchor; }

# ---- deprecation: 1.0 marked for removal - read off the headers -----------------------------------------------------------------
deprecation() {
  echo "1.0 marked for removal - Menu, Versions and Deprecations, the header strategy, a default of 1.0, port 19580, a fresh JVM:"
  start "$(hcp .harness/anchor 19580 probe.web.Menu,probe.web.Versions,probe.web.Deprecations "$H $D10")"; up 19580; ready 19580; vloc; vers
  heads 19580 "-H 'API-Version: 1.0'"; heads 19580 "-H 'API-Version: 2.0'"
  echo "  an unversioned route, no version sent:"; heads 19580 "" "/customers"
  seven 19580 .harness/anchor dep; WARNS
  echo "  against the seven on the README's run line, line for line:"; diff7 base dep
  echo "the mappings - Menu and Versions, the header strategy, a default of 1.0, and Actuator's mappings endpoint exposed for this run only, port 19581, a fresh JVM:"
  start "$(hcp .harness/anchor 19581 probe.web.Menu,probe.web.Versions "$H $D10 --management.endpoints.web.exposure.include=health,prometheus,mappings")"; up 19581; ready 19581; vloc; vers
  rm -f .harness/mappings.json; c=$(url "$L_MAP" 19581); echo "\$ $c"; (eval "$c") 2>&1 < /dev/null | sed 's/^/  /'; mapsf .harness/mappings.json
  WARNS; halt 19581 .harness/anchor; }

# ---- client: the other end - the inserters, the media-type pair, the group's keys --------------------------------------------
crun() { local s0; s0=$(smark); start "$(hcp .harness/anchor "$1" "$2" "$3")"; up "$1"; ready "$1"; vloc; vers
  echo "  the stub's dump since, one line a request:"; sver "$s0"; WARNS; halt "$1" .harness/anchor; }
client() {
  echo "the stub - this folder's copy against the RestClient lesson's (\$S25), md5 for md5 (this unit's line):"
  echo "\$ $L_MD5"; (eval "$L_MD5") 2>&1 < /dev/null | sed 's/^/  /'
  echo "  the same md5, file by file: $(for f in Stub.java $(for w in $WWW; do echo "www/$w"; done); do [ "$(md5 -q "harness/stub/$f")" = "$(md5 -q "$S25/$f")" ] && echo x; done | grep -c . || true) of 6 · routes this unit adds to it: 0"
  echo "two types named HttpExchange - the stub's (the JDK server's) and the interface's (Spring's), each line with its file (this unit's line):"
  echo "\$ $L_JDKX"; (eval "$L_JDKX") 2>&1 < /dev/null | sed 's/^/  /'
  echo "the stub - this unit's line, port 19587:"
  sstart
  echo "the inserters - Menu and Versions, the header strategy, no default, the cases header, query, path, media, mediapost, none and selfheader (RestClient.builder() with one inserter each, every call asking for 1.1), port 19580, a fresh JVM:"
  crun 19580 probe.web.Menu,probe.web.Versions "$H $SB --probe.self=http://127.0.0.1:19580 --probe.cases=header,query,path,media,mediapost,none,selfheader"
  echo "the media-type pair end to end - Menu and Versions, the media-type strategy, no default, the case selfmedia (the media-type inserter, Accept: application/json, 1.1, to this JVM's /menu), port 19581, a fresh JVM:"
  crun 19581 probe.web.Menu,probe.web.Versions "$MT --probe.self=http://127.0.0.1:19581 --probe.cases=selfmedia"
  echo "the group's default version - the field it binds to, read with javap -v (this unit's line), kept to the field and its annotation:"
  echo "\$ $L_NAME"; (eval "$L_NAME") > .harness/javapv.out 2>&1 < /dev/null || die "javap -v could not read ApiversionProperties"
  echo "  what javap printed: $(wc -l < .harness/javapv.out | tr -d ' ') lines · kept: $(awk '/^  private java\.lang\.String defaultVersion;$/ { f = 1 } f && /^$/ { exit } f && (/defaultVersion;$/ || /RuntimeVisibleAnnotations:/ || /bind\.Name\(/ || /value=/) { n++ } END { print n + 0 }' .harness/javapv.out) lines"
  awk '/^  private java\.lang\.String defaultVersion;$/ { f = 1 } f && /^$/ { exit } f && (/defaultVersion;$/ || /RuntimeVisibleAnnotations:/ || /bind\.Name\(/ || /value=/) { sub(/^ +/, ""); print "    " $0 }' .harness/javapv.out
  echo "  its setter: $(grep -c '^  public void setDefaultVersion(java.lang.String);$' .harness/javapv.out) (setDefaultVersion)"
  echo "the group - MenuGroup and Versions, the group menu's base URL, its version in the header API-Version, its default version 1.1 (...apiversion.default), port 19582, a fresh JVM:"
  crun 19582 probe.web.MenuGroup,probe.web.Versions "$GB --spring.http.serviceclient.menu.apiversion.insert.header=API-Version --spring.http.serviceclient.menu.apiversion.default=1.1"
  echo "C (labelled) - the same, the default version spelled by the setter's name (...apiversion.$DV), port 19583, a fresh JVM:"
  crun 19583 probe.web.MenuGroup,probe.web.Versions "$GB --spring.http.serviceclient.menu.apiversion.insert.header=API-Version --spring.http.serviceclient.menu.apiversion.$DV=1.1"
  echo "no group keys for the version - the base URL alone, port 19584, a fresh JVM:"
  crun 19584 probe.web.MenuGroup,probe.web.Versions "$GB"
  sstop; }

block() { awk '/^```bash$/ { if (!d) { f = 1 }; next } f && /^```$/ { f = 0; d = 1 } f' "$1"; }
# The shell a viewer has: env -i - nothing this script set reaches it (its JAVA_HOME, the JDK at the front of its PATH, LC_ALL,
# no_proxy, CURL_HOME) - with HOME and the PATH you started this script with; /bin/bash without profile or rc files, started in this
# folder. A driver in .harness/ runs the README's block, then SOLUTION.md's, as a viewer pastes them - each with its output, its exit
# code and the folder it left the shell in kept apart (absolute paths: a command that moved the shell must not move these files),
# and the README's run log and seven kept before the solution's run writes its own. Bounded (600 s); on the way out, or past the
# bound, the shell and every process under it are stopped (killtree).
# where DIR: the folder the shell was left in - this unit's folder, a folder under it (named), or elsewhere
where() { case "$1" in "$U") echo "this unit's folder" ;; "$U"/*) echo "${1#"$U"/}" ;; *) echo "outside this unit's folder" ;; esac; }
VX='V=(--spring.mvc.apiversion.use.header=API-Version)'
VS='V=(--spring.mvc.apiversion.use.header=API-Version --spring.mvc.apiversion.default=1.0)'
exercise() { local setup sol i=0 e1 d1 e2 d2 l1 l2 tk
  setup=$(block exercise/README.md); sol=$(block exercise/solution/SOLUTION.md)
  [ -n "$setup" ] && [ -n "$sol" ] || die "exercise/README.md or SOLUTION.md no longer gives its commands"
  [ "$(printf '%s\n' "$sol" | grep -c .)" = 5 ] || die "SOLUTION.md's first bash block must be the README's two export lines, its CURLSET line, the solution's one line and the README's last line"
  [ "$(printf '%s\n' "$sol" | sed -n 1,2p)" = "$(printf '%s\n' "$setup" | sed -n 1,2p)" ] || die "SOLUTION.md must start with the README's two export lines (a new shell's java may be another JDK)"
  printf '%s\n' "$sol" | sed -n 1p | grep -qxF 'export JAVA_HOME=/opt/homebrew/opt/openjdk@25' || die "SOLUTION.md's first line must export this script's JAVA_HOME"
  [ "$(printf '%s\n' "$sol" | sed -n 3p)" = "$(printf '%s\n' "$setup" | grep '^CURLSET=')" ] || die "SOLUTION.md's third line must be the README's CURLSET line"
  printf '%s\n' "$sol" | sed -n 4p | grep -qxF -- "$VS" || die "SOLUTION.md's fourth line must give unversioned requests a version: $VS"
  printf '%s\n' "$setup" | grep -qxF -- "$VX" || die "exercise/README.md must ship the header strategy alone: $VX"
  ! printf '%s\n' "$setup" | grep -qF 'apiversion.default' || die "exercise/README.md must not name the default's key: it is the exercise"
  l1=$(printf '%s\n' "$setup" | tail -1); l2=$(printf '%s\n' "$sol" | sed -n 5p)
  [ "$l1" = "$l2" ] || die "SOLUTION.md's last line must be the README's last line, unchanged: the fix is the key, not the command"
  rm -f .harness/ex-* .harness/exz-*
  printf '%s\n' "$setup" > .harness/ex-readme.sh; printf '%s\n' "$sol" > .harness/ex-sol.sh
  cat > .harness/ex-drive.sh <<'DRV'
cd "$1" || exit 1
. "$1/.harness/ex-readme.sh" > "$1/.harness/$2readme.out" 2>&1 < /dev/null
echo "$? $PWD" > "$1/.harness/$2readme.st"
cp "$1/.harness/mine/run.log" "$1/.harness/$2readme.log" 2> /dev/null
cp "$1/.harness/mine/seven.txt" "$1/.harness/$2readme.seven" 2> /dev/null
. "$1/.harness/ex-sol.sh" > "$1/.harness/$2sol.out" 2>&1 < /dev/null
echo "$? $PWD" > "$1/.harness/$2sol.st"
DRV
  # the same driver twice: /bin/bash, then /bin/zsh -f (the Mac's Terminal shell, which never splits an unquoted variable - RED S6 #527)
  env -i HOME="$HOME" PATH="$XPATH" /bin/bash --noprofile --norc .harness/ex-drive.sh "$U" ex- > .harness/ex-shell.out 2>&1 < /dev/null & xpid=$!
  while kill -0 "$xpid" 2> /dev/null && [ $i -lt 2400 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$xpid" 2> /dev/null && { killtree "$xpid"; die "the exercise's shell still ran after 600 s"; }
  wait "$xpid" || true; xpid=""
  cp .harness/mine/run.log .harness/ex-sol.log 2> /dev/null; cp .harness/mine/seven.txt .harness/ex-sol.seven 2> /dev/null; i=0
  tk=$(head -1 .harness/mine/anchor/$TF 2> /dev/null)
  env -i HOME="$HOME" PATH="$XPATH" /bin/zsh -f .harness/ex-drive.sh "$U" exz- > .harness/exz-shell.out 2>&1 < /dev/null & xpid=$!
  while kill -0 "$xpid" 2> /dev/null && [ $i -lt 2400 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$xpid" 2> /dev/null && { killtree "$xpid"; die "the exercise's zsh shell still ran after 600 s"; }
  wait "$xpid" || true; xpid=""
  [ -f .harness/exz-readme.st ] && [ -f .harness/exz-sol.st ] || { cat .harness/exz-shell.out .harness/exz-readme.out .harness/exz-sol.out 2> /dev/null | tail -20 >&3; die "the exercise's zsh shell did not reach the end of both blocks"; }
  [ -f .harness/ex-readme.st ] && [ -f .harness/ex-sol.st ] || { cat .harness/ex-shell.out .harness/ex-readme.out .harness/ex-sol.out 2> /dev/null | tail -20 >&3; die "the exercise's shell did not reach the end of both blocks"; }
  read -r e1 d1 < .harness/ex-readme.st; read -r e2 d2 < .harness/ex-sol.st
  [ "$e1" = 0 ] || { tail -20 .harness/ex-readme.out >&3; die "the exercise's commands failed: exit $e1"; }
  [ "$e2" = 0 ] || { tail -20 .harness/ex-sol.out >&3; die "the solution's lines failed: exit $e2"; }
  echo "exercise/README.md's commands, then the solution's lines (exercise/solution/SOLUTION.md), exactly as written, one after the other in ONE shell - env -i (HOME, and the PATH this script was started with), /bin/bash --noprofile --norc, started in this folder:"
  echo "the README's $(printf '%s\n' "$setup" | grep -c .) lines:"
  printf '%s\n' "$setup" | sed 's/^/  $ /'
  echo "  exit $e1 · what they printed:"; sed 's/^/    /' .harness/ex-readme.out
  echo "  the seven it saved (.harness/mine/seven.txt, kept before the solution's run):"; sed 's/^/    /' .harness/ex-readme.seven
  echo "  the shell is now in: $(where "$d1") · the copy's own token in its log: $(raw "$tk" .harness/ex-readme.log) times, in the seven: $(raw "$tk" .harness/ex-readme.seven) times · WARN lines in its log: $(lvl WARN .harness/ex-readme.log) · ERROR lines: $(lvl ERROR .harness/ex-readme.log) · listening on 19585 now: $(listeners 19585)"
  echo "the solution's $(printf '%s\n' "$sol" | grep -c .) lines, next, in the same shell:"
  printf '%s\n' "$sol" | sed 's/^/  $ /'
  echo "  exit $e2 · what they printed:"; sed 's/^/    /' .harness/ex-sol.out
  echo "  the seven it saved:"; sed 's/^/    /' .harness/ex-sol.seven
  echo "  the shell is now in: $(where "$d2") · the copy's own token in its log: $(raw "$tk" .harness/ex-sol.log) times, in the seven: $(raw "$tk" .harness/ex-sol.seven) times · WARN lines in its log: $(lvl WARN .harness/ex-sol.log) · ERROR lines: $(lvl ERROR .harness/ex-sol.log) · listening on 19585 now: $(listeners 19585)"
  read -r e1 d1 < .harness/exz-readme.st; read -r e2 d2 < .harness/exz-sol.st
  echo "the same two blocks again, in ONE new shell - env -i, /bin/zsh -f (zsh, the Mac's Terminal shell; it never splits an unquoted variable):"
  echo "  the README's lines: exit $e1 · what they printed:"; sed 's/^/    /' .harness/exz-readme.out
  echo "  the solution's lines: exit $e2 · what they printed:"; sed 's/^/    /' .harness/exz-sol.out
  tz=$(head -1 .harness/mine/anchor/$TF)
  echo "  the shell is now in: $(where "$d2") · its copy's own token in its log: $(raw "$tz" .harness/mine/run.log) times, in the seven: $(raw "$tz" .harness/mine/seven.txt) times · listening on 19585 now: $(listeners 19585)"; }

cap surface surface
cap strategy strategy
cap where where_
cap unversioned unversioned
cap baseline baseline
cap deprecation deprecation
cap client client
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
SHIP="README.md exercise/README.md exercise/solution/SOLUTION.md receipts.md5 harness/pom.xml harness/stub/Stub.java harness/shutdown.sh harness/keys.py $HWS"
for f in .r-*.out $SHIP; do [ "$(raw "$TOKEN" "$f")" = 0 ] || die "$f holds the demo token, raw"; done
for f in .r-*.out; do ! grep -qE '/Users/|/private/|/home/|/var/folders/' "$f" || die "$f holds an absolute path"; ! grep -E 'c[0-9]-unit[0-9]|unit ?[0-9]' "$f" | grep -vxF '  $ CURLSET="$PWD/../c5-unit11/curlset.sh"' > /dev/null || die "$f holds a unit number (the exercise's CURLSET line, the comparison set's path, aside)"; ! grep -qE ' (with PID|started by) ' "$f" || die "$f holds Boot's process line"; ! grep -qE '^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T|"timestamp":"?[0-9]|(exec|handler|task|omcat-handler)-[0-9]' "$f" || die "$f holds a log time, a timestamp or a thread number"; ! grep -qE 'Java-http-client/[0-9]|Java/[0-9]+\.[0-9]| using Java [0-9]|Macintosh|Mac OS X|Windows NT|X11;|Linux x86' "$f" || die "$f holds a JDK version (a client's, or Boot's first line's) or a platform (R.128, R.136, R.151)"; ! grep -qE 'probe\.web\.[A-Za-z]+\.[a-zA-Z0-9]+\(\)' "$f" || die "$f names the handler method a failed start met first (masked: the scan's order is no rule)"; ! grep -qE ':8080|:35729|:18425/' "$f" || die "$f names 8080, 35729 or 18425"; ! grep -q "$(printf '\r')" "$f" || die "$f holds a carriage return"; ! grep -qE '[0-9]+ ?ms\b|[0-9]+\.[0-9]+ ?s(econds)?\b|Started .* in ' "$f" || die "$f holds a duration (⚑10)"; ! grep -qE '^\s+at [a-z]' "$f" || die "$f holds a stack frame"; ! grep -qE '^ +Date: ' "$f" || die "$f holds a Date header"; done
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
# R.154 (S6.25): the group's default version is ...apiversion.default (the field's @Name); the setter's kebab case appears in no file
# this unit ships, but in README.md's lines that label it client's C - and in the captures only on client's C block
for f in receipts.sh exercise/README.md exercise/solution/SOLUTION.md $HWS harness/pom.xml; do ! grep -qF "$DV" "$f" || die "$f spells the group's default version by the setter's name ($DV) - Boot binds it as ...apiversion.default (R.154)"; done
# README.md: only on a line that labels client's C, or inside its copy of the client capture (section 7, whole)
! awk '/^## 7 · client/ { f = 1 } /^## 8 · / { f = 0 } !f' README.md | grep -F "$DV" | grep -vF 'C (labelled)' > /dev/null || die "README.md spells $DV outside a line that labels it client's C (R.154)"
for f in .r-*.out; do [ "$f" = .r-client.out ] || ! grep -qF "$DV" "$f" || die "$f spells $DV - only client's C may"; done
[ "$(awk '/^C \(labelled\)/ { f = 1 } /^no group keys/ { f = 0 } f' .r-client.out | grep -cF "$DV")" = "$(grep -cF "$DV" .r-client.out)" ] || die "client: $DV appears outside its C block"
# R.114 (S3.18): no harness class reaches the anchor - its tree names none of them (as whole words)
for c in Menu MenuPath Deprecations Versions MenuApi MenuGroup probe.web Stub HttpExchange ImportHttpServices apiversion; do ! grep -rqwF "$c" anchor/tiffinbox-web/src anchor/tiffinbox-core/src || die "the anchor's sources name $c (a whole word) - the harness is shown on the harness, never in the anchor"; done
# no capture runs a command with a URL that is not 127.0.0.1's; the stub binds the loopback address
for f in .r-*.out; do ! grep -E '^ *\$ ' "$f" | grep -oE 'https?://[^ '"'"']+' | grep -vE '^http://127\.0\.0\.1:' > /dev/null || die "$f runs a command with a URL that is not 127.0.0.1's"; done
grep -qF 'new InetSocketAddress(InetAddress.getLoopbackAddress(), port)' harness/stub/Stub.java || die "the stub must bind the loopback address"
for f in $HWS harness/stub/Stub.java exercise/README.md exercise/solution/SOLUTION.md; do ! grep -qE 'https?://localhost|localhost:' "$f" || die "$f names localhost - every URL is 127.0.0.1's (R.82)"; done
# S6.1: every java line a capture starts pins the JVM's locale (the extract line prints nothing a locale changes) - the stub's too
for f in .r-*.out; do ! grep -E '^ *\$ (cd [^ ]+ && )?(exec )?java ' "$f" | grep -vF -- "java $JL " | grep -vF -- 'java -Djarmode=tools ' > /dev/null || die "$f starts a JVM without its locale pinned (S6.1)"; done
for f in exercise/README.md exercise/solution/SOLUTION.md; do ! grep -oE '\{ java [^>]*' "$f" | grep -vF -- "{ java $JL " > /dev/null || die "$f: the exercise's java lines must pin the JVM's locale (S6.1)"; done
[ "$(grep -oE '\{ java [^>]*' exercise/README.md | grep -c .)" = 1 ] || die "exercise/README.md must start one JVM, TiffinBox's jar, in a subshell job"
# S2.16: the harness compiles with -parameters
[ "$(grep -c '^javac -parameters ' README.md)" = 1 ] || die "the harness must compile with -parameters (S2.16)"
# httpclient5 never joins (S5.3): not on the harness's class path, not in the anchor's lib/
! grep -qF httpclient5 .harness/harness.cp && [ -z "$(ls "$LIBD" | grep '^httpclient5-' || true)" ] || die "httpclient5 is on the class path - every factory sentence would change"
# R.115: no browser is used here - the exercise names one only to say none is needed
[ "$(grep -oi 'browser' exercise/README.md | wc -l | tr -d ' ')" = 1 ] && grep -i 'browser' exercise/README.md | grep -qF 'browser are needed' && [ "$(grep -oi 'browser' exercise/solution/SOLUTION.md | wc -l | tr -d ' ')" = 0 ] || die "the exercise speaks of a browser (R.115) - none is used"
# R.146 (S6.21): two types named HttpExchange - the interface imports Spring's and names the JDK's by package
grep -qxF 'import org.springframework.web.service.annotation.HttpExchange;' harness/probe/web/MenuApi.java && grep -qF 'com.sun.net.httpserver.HttpExchange' harness/probe/web/MenuApi.java || die "MenuApi.java must import Spring's HttpExchange and name the JDK's by package (R.146)"
# R.141: every RestClient is built from a builder of its own, once - the harness never keeps or injects a RestClient.Builder
! grep -qE 'RestClient\.Builder' $HWS || die "the harness keeps a RestClient.Builder (R.141: a mutable builder is built once, never shared)"
NL=$(cat .r-*.out | grep -cE "^  its log: the demo token 0 times · X-Shutdown-Token 0 times\$" || true)
ND=$(cat .r-*.out | grep -cE "· the demo token 0 times · X-Shutdown-Token 0 times\$" || true)
echo "  tokens: 0 raw copies in $(ls .harness/raw-* | wc -l | tr -d ' ') raw capture runs, in $(ls .r-*.out | wc -l | tr -d ' ') captures; the demo token 0 in the logs of every JVM that ran ($LOGS here; the published captures' $NL) and in every stub dump ($DUMPS here; the published captures' $ND), the READMEs, the harness, the stub and receipts.md5; no absolute path, no unit number, no process line, no log time, no timestamp, no thread number, no client JDK version, no Boot JDK version, no handler method of a failed start, no platform, no duration, no stack frame, no Date header, no URL but 127.0.0.1's; every JVM's locale pinned; Boot 3's client key and the setter's spelling of the group's default nowhere but client's C"

S466='466c20ed7e0d5439cb052f32ce09de1b'; S7D3='7d36b99ea48f2bb5fc961fbac1fd8a6a'
LOC="  the JVM's locale (the harness's Versions): en_US"
SL="  the stub listens on: 127.0.0.1:19587 · loopback only: yes · its locale: en_US"
Z3="  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0 · lines that say \"deprecat\": 0"
W1="  WARN lines in this run's log, at Boot's default level: 1 · ERROR lines: 0 · lines that say \"deprecat\": 0"
UA0=$(cat .harness/ua.txt 2> /dev/null || true)
REQ='{"detail":"API version is required.","instance":"/menu","status":400,"title":"Bad Request"}'
N10='{"handler":"1.0","body":["Meera","Priya","Ravi","Sunil"]}'; N11='{"handler":"1.1+","body":4}'; N20='{"handler":"2.0","body":24300}'
ASKQ="\$ curl -s -o .harness/body.txt -w '%{http_code} %{content_type}'"
PID400='  POST /shutdown answered 400: stopped by its pid · exit 143 · listening on'

# "version on GetMapping ... three handlers ... eight keys, none with a default ... four resolvers ... three exceptions" - surface
SO=$(cat .r-surface.out)
has "$SO" '  built the anchor · offline: yes · exit 0' "surface: the anchor built offline"
has "$SO" "  the anchor's libraries (its extracted lib/): 61 · Boot's RestClient module among them: 0 · httpclient5: 0" "surface: 61 libraries"
has "$SO" "  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 0 · md5 $S466" "surface: the seven $S466"
has "$SO" "  the class path the harness runs on: the anchor's 61 libraries + 2 = 63" "surface: 61 + 2 = 63"
has "$SO" '    public abstract java.lang.String version();' "surface: version() read off spring-web"
[ "$(cnt "$SO" '    public abstract java.lang.String version();')" = 2 ] && [ "$(printf '%s\n' "$SO" | grep -cE '^  public interface org\.springframework\.web\.bind\.annotation\.(GetMapping|RequestMapping) extends java\.lang\.annotation\.Annotation$')" = 2 ] || die "surface: GetMapping and RequestMapping, each with version()"
for l in '  harness/probe/web/Menu.java:20:    @GetMapping(path = "/menu", version = "1.0")' '  harness/probe/web/Menu.java:25:    @GetMapping(path = "/menu", version = "1.1+")' '  harness/probe/web/Menu.java:30:    @GetMapping(path = "/menu", version = "2.0")'; do has "$SO" "$l" "surface: the handler $l"; done
has "$SO" "  mappings with a version: 6 · on /menu: 3 · in TiffinBox's own sources: 0" "surface: three on /menu, none in TiffinBox"
NK=$(printf '%s\n' "$SO" | grep -cE '^  spring\.mvc\.apiversion\.[a-z.-]+ · default none · ' || true)
[ "$NK" = 8 ] && has "$SO" '  8 keys under spring.mvc.apiversion' "surface: eight keys" && [ "$(printf '%s\n' "$SO" | grep -E '^  spring\.mvc\.apiversion\.' | grep -vc ' · default none · ' || true)" = 0 ] || die "surface: eight keys, none with a default ($NK)"
for k in default detect-supported required supported use.header use.media-type-parameter use.path-segment use.query-parameter; do printf '%s\n' "$SO" | grep -qE "^  spring\\.mvc\\.apiversion\\.$k · default none · " || die "surface: the key $k"; done
has "$SO" "  the types keys.py cut, whole (it keeps what follows the last dot): supported java.util.List<java.lang.String> · media-type-parameter java.util.Map<org.springframework.http.MediaType,java.lang.String>" "surface: the two cut types, whole"
has "$SO" '  the classes that implement ApiVersionResolver - the places a version is read: HeaderApiVersionResolver MediaTypeParamApiVersionResolver PathApiVersionResolver QueryApiVersionResolver' "surface: four resolvers"
NE=$(blk surface "  the exceptions, each" "whose classes" | grep -c ' -> ResponseStatusException$' || true); NA=$(blk surface "  the exceptions, each" "whose classes" | grep -c . || true)
[ "$NE" = 3 ] && [ "$NA" = 3 ] || die "surface: three exceptions, each a ResponseStatusException ($NE of $NA)"
has "$SO" '    NotAcceptableApiVersionException -> InvalidApiVersionException -> ResponseStatusException' "surface: NotAcceptable under Invalid"
for l in 'org.springframework.web.bind.annotation.GetMapping · in: spring-web-7.0.9.jar' 'org.springframework.web.accept.ApiVersionStrategy · in: spring-web-7.0.9.jar' 'org.springframework.web.accept.StandardApiVersionDeprecationHandler · in: spring-web-7.0.9.jar' 'org.springframework.web.client.ApiVersionInserter · in: spring-web-7.0.9.jar' 'org.springframework.web.servlet.config.annotation.ApiVersionConfigurer · in: spring-webmvc-7.0.9.jar' 'org.springframework.boot.webmvc.autoconfigure.WebMvcProperties$Apiversion · in: spring-boot-webmvc-4.1.1.jar' 'org.springframework.boot.http.client.autoconfigure.ApiversionProperties · in: spring-boot-http-client-4.1.1.jar'; do has "$SO" "  $l" "surface: owner $l"; done
echo "  surface: 61 + 2 = 63; version() on GetMapping and RequestMapping (spring-web 7.0.9); 3 handlers on /menu, 0 versions in TiffinBox; $NK keys, none with a default; 4 resolvers; $NE exceptions, each a ResponseStatusException; owners spring-web / spring-webmvc / spring-boot-webmvc / spring-boot-http-client; the seven $S466"

# "A: it starts, the header picks ... B: it does not start ... A' = A" - strategy
TA=$(blk strategy "A - " "B - "); TB=$(blk strategy "B - " "A' - "); TA2=$(blk strategy "A' - " "A' against A")
for b in "$TA" "$TA2"; do has "$b" "$LOC" "strategy A: the locale"; has "$b" "  -> 200 application/json · $N10" "strategy A: 1.0"; has "$b" "  -> 200 application/json · $N11" "strategy A: 1.1"; has "$b" "  -> 200 application/json · $N20" "strategy A: 2.0"
  [ "$(cnt "$b" "  -> 200 application/json · $N10")" = 2 ] || die "strategy A: 1.0 asked, and none asked: the 1.0 handler twice"; has "$b" "$Z3" "strategy A: 0/0"; has "$b" "  exit 0 · listening on 19580 now: 0" "strategy A: POST /shutdown stopped it"; done
has "$TA2" "\$ $(hcp .harness/anchor 19580 probe.web.Menu,probe.web.Versions "$H $D10")" "strategy A': its \$ line (S6.2)"
has "$TB" "\$ $(hcp .harness/anchor 19581 probe.web.Menu,probe.web.Versions)" "strategy B: its \$ line, no key"
has "$TB" '  exit 1 · listening on 19581: 0 (lsof, by port) · readiness never asked · Boot'"'"'s first line: Starting TiffinBoxServer v1.0.0 using Java <version>' "strategy B: exit 1, never listened"
has "$TB" '    ERROR o.s.boot.SpringApplication: Application run failed' "strategy B: Boot's SpringApplication ERROR (S6.5)"
has "$TB" '    Caused by: java.lang.IllegalStateException: API version specified, but no ApiVersionStrategy configured' "strategy B: Framework's sentence"
[ "$(printf '%s\n' "$TB" | grep '^    Caused by: ' | tail -1)" = '    Caused by: java.lang.IllegalStateException: API version specified, but no ApiVersionStrategy configured' ] || die "strategy B: the sentence is the root cause"
printf '%s\n' "$TB" | grep -qF "Error creating bean with name 'requestMappingHandlerMapping'" && printf '%s\n' "$TB" | grep -qF '<the first handler method the scan met>' || die "strategy B: the bean that failed, the method masked"
[ "$(printf '%s\n' "$TB" | grep -cE '^    (WARN|ERROR) ')" = 2 ] || die "strategy B: two records, a WARN and the ERROR"
has "$(cat .r-strategy.out)" "A' against A, its label aside, line for line the same: yes" "strategy: A' = A"
echo "  strategy: A header + default 1.0 -> 1.0/1.1+/2.0 by the header, none -> 1.0, POST /shutdown stops it; B no key -> exit 1, never listened, SpringApplication ERROR, root cause 'API version specified, but no ApiVersionStrategy configured', the method masked; A' = A"

# "header, query, the media type's parameter, the path ... the version anywhere else: four hundred" - where
WO=$(cat .r-where.out); WH=$(blk where "the header - " "the query parameter - "); WQ=$(blk where "the query parameter - " "the media-type parameter - "); WM=$(blk where "the media-type parameter - " "the path segment - "); WP=$(blk where "the path segment - " "")
has "$WO" '  19589, never bound: listening 0 (lsof, by port)' "where: 19589 free"
for b in "$WH" "$WQ" "$WM" "$WP"; do has "$b" "$LOC" "where: the locale"; has "$b" "$Z3" "where: the version 400s log nothing"; printf '%s\n' "$b" | grep -qF "$PID400" || die "where: a JVM with no default stopped by its pid"; done
for b in "$WH" "$WQ"; do has "$b" "  -> 200 application/json · $N10" "where: 1.0"; has "$b" "  -> 200 application/json · $N11" "where: 1.1+"; has "$b" "  -> 200 application/json · $N20" "where: 2.0"; has "$b" "  -> 400 application/problem+json · $REQ" "where: the control, 400 required"; done
has "$WH" "$ASKQ http://127.0.0.1:19580/menu?version=1.0" "where: the header JVM's control sends the query"
has "$WQ" "$ASKQ -H 'API-Version: 1.0' http://127.0.0.1:19581/menu" "where: the query JVM's control sends the header"
has "$WM" "  -> 200 application/json;v=1.0 · $N10" "where: Accept v=1.0, Content-Type echoes ;v=1.0"; has "$WM" "  -> 200 application/json;v=1.1 · $N11" "where: v=1.1"; has "$WM" "  -> 200 application/json;v=2.0 · $N20" "where: v=2.0"
has "$WM" "$ASKQ -H 'Content-Type: application/json;v=1.0' http://127.0.0.1:19582/menu" "where: the media JVM's control"; has "$WM" "  -> 400 application/problem+json · $REQ" "where: Content-Type is not read: 400"
for v in 1.0 1.1 2.0 v1; do has "$WP" "$ASKQ http://127.0.0.1:19583/api/$v/menu" "where: /api/$v/menu"; done
[ "$(cnt "$WP" '  -> 200 application/json · {"handler":"1.0","body":"the path"}')" = 2 ] && has "$WP" '  -> 200 application/json · {"handler":"1.1+","body":"the path"}' "where: path 1.1+" && has "$WP" '  -> 200 application/json · {"handler":"2.0","body":"the path"}' "where: path 2.0" || die "where: the path's three, v1 as 1.0"
has "$WP" '  -> 400 application/problem+json · {"detail":"Invalid API version: '"'"'No path segment at index 1'"'"'.","instance":"/customers","status":400,"title":"Bad Request"}' "where: the path JVM's control"
echo "  where: header / ?version= / Accept ;v= (Content-Type echoes ;v=1.0) / /api/{v}/menu (v1 -> 1.0) - the same three handlers; the version elsewhere -> 400 (required; the path: No path segment at index 1); 0 WARN for the 400s; every JVM stopped by its pid"

# "five of the seven answer four hundred ... required false: the newest ... a default: the same, byte for byte, seven ... C" - unversioned
UH=$(blk unversioned "a header strategy, no default - " "required=false - "); UR=$(blk unversioned "required=false - " "a default - "); UD=$(blk unversioned "a default - " "C (labelled)"); UC=$(blk unversioned "C (labelled)" "")
has "$UH" "  -> 400 application/problem+json · $REQ" "unversioned: /menu with no version, 400 required"
has "$UH" "  exit 143 (POST /shutdown answered 400: stopped by its pid) · the seven responses: 7 lines · lines the timestamp mask changed: 0 · md5 $S7D3" "unversioned: the seven $S7D3, stopped by its pid (R.152)"
has "$UH" '  lines that differ: 5 (1 2 3 4 7) · the same, byte for byte: 2 (5 6)' "unversioned: 5 differ"
[ "$(printf '%s\n' "$UH" | grep -cF '  -> 400 application/problem+json  {"detail":"API version is required."')" = 5 ] || die "unversioned: five of the seven say API version is required"
has "$UH" "  POST  /shutdown   -> 400 application/problem+json  {\"detail\":\"API version is required.\",\"instance\":\"/shutdown\",\"status\":400,\"title\":\"Bad Request\"}" "unversioned: POST /shutdown 400"
has "$UH" '  the log'"'"'s lines during the seven: 1 · its WARN and ERROR records among them: 1' "unversioned: the seven's 400s log nothing (one line: the 405's WARN)"
has "$UH" '    WARN o.s.web.servlet.PageNotFound: Request method '"'"'GET'"'"' is not supported' "unversioned: the one line is the 405's"
has "$UR" "  -> 200 application/json · $N20" "unversioned: required=false -> the 2.0 handler"
has "$UR" "  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 0 · md5 $S466" "unversioned: required=false, the seven $S466"
has "$UD" "  -> 200 application/json · $N10" "unversioned: a default -> 1.0"
has "$UD" "  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 0 · md5 $S466" "unversioned: a default, the seven $S466"
for b in "$UR" "$UD"; do has "$b" '  lines that differ: 0 · the same, byte for byte: 7 (1 2 3 4 5 6 7)' "unversioned: the same, byte for byte: 7"; done
has "$UC" '  -> 400 application/json · {"timestamp":"…","status":400,"error":"Bad Request","path":"/menu"}' "unversioned C: Boot's four keys (R.133)"
has "$UC" "\$ $(hcp .harness/anchor 19583 probe.web.Menu,probe.web.Versions "$H --spring.mvc.problemdetails.enabled=false")" "unversioned C: its \$ line"
printf '%s\n' "$UC" | grep -qF "$PID400" || die "unversioned C: stopped by its pid"
grep -qxF '  mvc:' anchor/tiffinbox-web/src/main/resources/application.yaml && grep -A1 -xF '    problemdetails:' anchor/tiffinbox-web/src/main/resources/application.yaml | grep -qxF '      enabled: true' || die "unversioned: TiffinBox's own application.yaml must switch problem details on - the 400's body rests on it (R.133)"
echo "  unversioned: header, no default - the seven $S7D3, 5 differ (1 2 3 4 7), POST /shutdown 400, stopped by its pid, 1 log line (the 405's); required=false -> 2.0, the seven $S466; default 1.0 -> 1.0, the seven $S466, the same 7; C problem details off -> Boot's four keys"

# "1.1 and later ... 1.2 is refused until it is supported ... 1 reads as 1.0.0" - baseline
BO=$(cat .r-baseline.out); B1=$(blk baseline "the baseline - " "1.2 made"); B2=$(blk baseline "1.2 made" "")
has "$B1" "  -> 200 application/json · $N11" "baseline: 1.1 -> 1.1+"
has "$B1" '  -> 400 application/problem+json · {"detail":"Invalid API version: '"'"'1.2.0'"'"'.","instance":"/menu","status":400,"title":"Bad Request"}' "baseline: 1.2 -> 400 Invalid '1.2.0'"
has "$B1" "$ASKQ -H 'API-Version: 1' http://127.0.0.1:19580/menu" "baseline: 1 sent"; has "$B1" "  -> 200 application/json · $N10" "baseline: 1 -> 1.0"
has "$B2" "$ASKQ -H 'API-Version: 1.2' http://127.0.0.1:19581/menu" "baseline: 1.2 sent"; has "$B2" "  -> 200 application/json · $N11" "baseline: 1.2 supported -> 1.1+"
for b in "$B1" "$B2"; do has "$b" "$Z3" "baseline: 0/0"; has "$b" "$LOC" "baseline: the locale"; done
echo "  baseline: 1.1 -> 1.1+; 1.2 -> 400 Invalid API version: '1.2.0'; 1 -> 1.0; supported=1.2 -> 1.2 -> 1.1+"

# "Deprecation, Sunset, Link on a one-point-oh answer ... on customers too ... the seven do not see it ... the mappings" - deprecation
DO=$(cat .r-deprecation.out)
DEP='    Deprecation: @1790812800'; SUN='    Sunset: Thu, 1 Apr 2027 00:00:00 GMT'; LNK='    Link: <http://127.0.0.1/docs/menu-1.0>; rel="deprecation"; type="text/html"'
D1=$(blk deprecation "\$ curl -s -D .harness/head.txt -o .harness/body.txt -w '%{http_code}' -H 'API-Version: 1.0'" "\$ curl -s -D .harness/head.txt -o .harness/body.txt -w '%{http_code}' -H 'API-Version: 2.0'")
D2=$(blk deprecation "\$ curl -s -D .harness/head.txt -o .harness/body.txt -w '%{http_code}' -H 'API-Version: 2.0'" "  an unversioned route")
D3=$(blk deprecation "\$ curl -s -D .harness/head.txt -o .harness/body.txt -w '%{http_code}' http://127.0.0.1:19580/customers" "\$ \$CURLSET")
for l in "$DEP" "$SUN" "$LNK"; do has "$D1" "$l" "deprecation: 1.0 carries $l"; has "$D3" "$l" "deprecation: the unversioned /customers carries $l"; nhas "$D2" "$l" "deprecation: 2.0 carries none"; done
has "$D1" "    its body: $N10" "deprecation: the 1.0 answer"; has "$D2" "    its body: $N20" "deprecation: the 2.0 answer"
has "$D2" '  -> 200 · its header lines: 4 · kept, by ^(Deprecation|Sunset|Link|Content-Type): (any case): 1' "deprecation: 2.0 keeps Content-Type alone"
[ "$(cnt "$DO" '  -> 200 · its header lines: 7 · kept, by ^(Deprecation|Sunset|Link|Content-Type): (any case): 4')" = 2 ] || die "deprecation: the 1.0 answer and /customers, 4 kept each"
has "$DO" "  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 0 · md5 $S466" "deprecation: the seven $S466 beside the headers"
has "$DO" '  lines that differ: 0 · the same, byte for byte: 7 (1 2 3 4 5 6 7)' "deprecation: the seven cannot see a header (R.153)"
has "$DO" '  the predicates its dispatcherServlets list: 22 · kept, by the filter "/menu", sorted: 3' "deprecation: the mappings, 3 of 22"
for v in 1.0 1.1+ 2.0; do has "$DO" "    {GET [/menu], version [$v]}" "deprecation: the predicate version [$v]"; done
has "$DO" "\$ $(hcp .harness/anchor 19581 probe.web.Menu,probe.web.Versions "$H $D10 --management.endpoints.web.exposure.include=health,prometheus,mappings")" "deprecation: the exposure flag on its run's line only (R.42)"
[ "$(grep -c 'exposure.include' .r-deprecation.out)" = 1 ] && ! grep -qF 'exposure.include' .r-surface.out .r-strategy.out .r-where.out .r-unversioned.out .r-baseline.out .r-client.out || die "deprecation: the exposure flag on one run only"
grep -qF 'setSunsetDate(ZonedDateTime.of(2027, 4, 1, 0, 0, 0, 0, ZoneOffset.UTC))' harness/probe/web/Deprecations.java && grep -qF 'setDeprecationDate(ZonedDateTime.of(2026, 10, 1, 0, 0, 0, 0, ZoneOffset.UTC))' harness/probe/web/Deprecations.java || die "deprecation: the harness's dates"
[ "$(TZ=UTC date -j -f '%Y-%m-%d %H:%M:%S' '2026-10-01 00:00:00' +%s)" = 1790812800 ] || die "deprecation: @1790812800 must be 1 October 2026, midnight UTC - the deprecation date, in seconds"
echo "  deprecation: 1.0 -> Deprecation @1790812800 (1 October 2026, UTC), Sunset Thu, 1 Apr 2027, Link rel=deprecation; 2.0 -> none; unversioned /customers -> all three; the seven $S466, the same 7; /actuator/mappings: 3 of 22 predicates, version [1.0] [1.1+] [2.0]"

# "api-version, the query, the path ... the media type: nothing on a GET, Content-Type on a POST ... no inserter ... the group" - client
CO=$(cat .r-client.out); CI=$(blk client "the inserters - " "the media-type pair"); CM=$(blk client "the media-type pair" "the group's default version"); CG=$(blk client "the group - " "C (labelled)"); CC=$(blk client "C (labelled)" "no group keys"); CN=$(blk client "no group keys" "")
has "$CO" "  $SMD5 $SMD5 Stub.java" "client: the stub's md5, the RestClient lesson's"
has "$CO" "  the same md5, file by file: 6 of 6 · routes this unit adds to it: 0" "client: the stub copied, byte for byte"
has "$CO" '  harness/stub/Stub.java:89:void send(HttpExchange ex, int code, String type, String body) throws java.io.IOException {' "client: the stub's HttpExchange (the JDK's)"
has "$CO" '  harness/probe/web/MenuApi.java:4:import org.springframework.web.service.annotation.HttpExchange;' "client: the interface's HttpExchange (Spring's)"
has "$CO" "$SL" "client: the stub, loopback, en_US"
for l in '    header -> 200 OK' '    query -> 200 OK' '    path !! org.springframework.web.client.HttpClientErrorException$NotFound: 404 Not Found: "not found"' '    media -> 200 OK' '    mediapost -> 201 CREATED' '    none !! java.lang.IllegalStateException: No ApiVersionInserter configured' "    selfheader -> $N11"; do has "$CI" "$l" "client: $l"; done
has "$CI" '    GET /customers.json · api-version: 1.1 · accept: application/json · content-type: none · headers: 9 · the stub answered 200 application/json 307 bytes' "client: the header inserter -> api-version: 1.1"
has "$CI" '    GET /customers.json?version=1.1 · api-version: none · accept: application/json · content-type: none · headers: 8 · the stub answered 200 application/json 307 bytes' "client: the query inserter -> ?version=1.1"
has "$CI" '    GET /1.1/customers.json · api-version: none · accept: application/json · content-type: none · headers: 8 · the stub answered 404 text/plain 9 bytes' "client: the path inserter -> /1.1/customers.json, the stub's 404"
has "$CI" '    GET /customers.json · api-version: none · accept: application/json · content-type: none · headers: 8 · the stub answered 200 application/json 307 bytes' "client: the media inserter's GET carries no version"
has "$CI" '    POST /payments · api-version: none · accept: application/json · content-type: application/json;v=1.1 · headers: 10 · the stub answered 201 application/json 62 bytes' "client: the media inserter writes ;v=1.1 on Content-Type"
[ "$(printf '%s\n' "$CI" | grep -c '^    [A-Z]* /.* · api-version: ')" = 5 ] || die "client: five requests reached the stub - the case none sent nothing (the IllegalStateException is before any request)"
[ "$(printf '%s\n' "$CI" | grep -c 'v=1\.1')" = 1 ] || die "client: ;v=1.1 on one request only, the POST"
has "$CM" '    selfmedia !! org.springframework.web.client.HttpClientErrorException$BadRequest: 400 Bad Request: "'"$REQ"'"' "client: the media-type pair end to end - the server reads Accept, the client wrote nothing there: 400"
has "$CO" '  what javap printed: 150 lines · kept: 4 lines' "client: javap -v, 4 kept"
for l in '    private java.lang.String defaultVersion;' '    org.springframework.boot.context.properties.bind.Name(' '    value="default"'; do has "$CO" "$l" "client: @Name(\"default\") on defaultVersion (R.154)"; done
has "$CO" '  its setter: 1 (setDefaultVersion)' "client: the setter that R.150's rule would read"
has "$CG" '    GET /ravi.json · api-version: 1.1 · accept: none · content-type: none · headers: 8 · the stub answered 200 application/json 73 bytes' "client: the group's default 1.1 on the wire"
for b in "$CG" "$CC"; do has "$b" '    GET /meera.json · api-version: 2.0 · accept: none · content-type: none · headers: 8 · the stub answered 200 application/json 73 bytes' "client: the method's 2.0 on the wire"; done
has "$CC" '    GET /ravi.json · api-version: none · accept: none · content-type: none · headers: 7 · the stub answered 200 application/json 73 bytes' "client C: the setter's spelling binds nothing - ravi sends no version"
has "$CC" "\$ $(hcp .harness/anchor 19583 probe.web.MenuGroup,probe.web.Versions "$GB --spring.http.serviceclient.menu.apiversion.insert.header=API-Version --spring.http.serviceclient.menu.apiversion.$DV=1.1")" "client C: its \$ line"
for f in ravi meera; do has "$CN" "    GET /$f.json · api-version: none · accept: none · content-type: none · headers: 7 · the stub answered 200 application/json 73 bytes" "client: no group keys - $f sends no version"; done
for b in "$CG" "$CC" "$CN"; do has "$b" '    group ravi -> 73 characters' "client: ravi answered"; has "$b" '    group meera -> 73 characters' "client: meera answered - no exception"; [ "$(printf '%s\n' "$b" | grep -c '^    group [a-z]* !! ' || true)" = 0 ] || die "client: a group call threw"; done
has "$CO" "  the stub: stopped by its pid · exit 143 · listening on 19587 now: 0 · requests in its dump: 11 · the demo token 0 times · X-Shutdown-Token 0 times" "client: eleven requests, 0 tokens"
for b in "$CI" "$CM" "$CG" "$CC" "$CN"; do has "$b" "$LOC" "client: the locale"; has "$b" "$Z3" "client: 0/0"; done
case "$UA0" in Java-http-client/[0-9]*) ;; *) die "client: the stub saw no Java-http-client User-Agent" ;; esac
echo "  client: the stub md5 = the RestClient lesson's ($SMD5), 6 of 6; header -> api-version: 1.1; query -> ?version=1.1; path -> /1.1/customers.json (the stub's 404); media: nothing on the GET, content-type: application/json;v=1.1 on the POST; the media pair end to end -> 400 required; no inserter -> IllegalStateException, nothing sent; the group: default=1.1 -> api-version 1.1, the method's 2.0; @Name(\"default\") -> the setter's spelling sends nothing; no keys -> meera's 2.0 dropped, no exception; 11 requests, 0 tokens · the User-Agent, masked in every capture (terminal only): $UA0"

# the exercise's files as shipped (read again here, so a check that the exercise capture makes cannot be skipped)
XR=$(block exercise/README.md); XL=$(block exercise/solution/SOLUTION.md)
[ "$(printf '%s\n' "$XL" | grep -c .)" = 5 ] && [ "$(printf '%s\n' "$XL" | sed -n 1,2p)" = "$(printf '%s\n' "$XR" | sed -n 1,2p)" ] && [ "$(printf '%s\n' "$XL" | sed -n 4p)" = "$VS" ] && [ "$(printf '%s\n' "$XL" | sed -n 5p)" = "$(printf '%s\n' "$XR" | tail -1)" ] && printf '%s\n' "$XR" | grep -qxF -- "$VX" && ! printf '%s\n' "$XR" | grep -qF apiversion.default || die "exercise: SOLUTION.md must be the README's two exports, its CURLSET line, $VS and the README's last line; the README must ship $VX and no default"
XS=$(blk exercise "the README's" "the solution's"); XE=$(blk exercise "the solution's" 'the same two blocks again'); XZ=$(blk exercise 'the same two blocks again' '')
l="the seven: md5 $S466 · answered 400: 0 · TiffinBox stopped by: POST /shutdown"; l0="the seven: md5 $S7D3 · answered 400: 5 · TiffinBox stopped by: its pid - POST /shutdown answered 400"
has "$XE" "    $l" "exercise: the solution"; has "$XS" "    $l0" "exercise: as shipped"
awk '/^\*\*Done\*\*/ { f = 1 } f' exercise/README.md | grep -qxF -- "$l" || die "exercise/README.md: Done names no such line"
grep -qxF -- "$l" exercise/solution/SOLUTION.md || die "SOLUTION.md: the measured run shows no such line"
grep -qF -- "\`$l0\`" exercise/README.md || die "exercise/README.md: the shipped line's answer is not named"
has "$XS" '  exit 0 · what they printed:' "exercise: the README's commands, exit 0"; has "$XE" '  exit 0 · what they printed:' "exercise: the solution's lines, exit 0"
has "$XS" "  the shell is now in: this unit's folder · the copy's own token in its log: 0 times, in the seven: 0 times · WARN lines in its log: 1 · ERROR lines: 0 · listening on 19585 now: 0" "exercise: as shipped, the 405's WARN, nothing left"
has "$XE" "  the shell is now in: this unit's folder · the copy's own token in its log: 0 times, in the seven: 0 times · WARN lines in its log: 1 · ERROR lines: 0 · listening on 19585 now: 0" "exercise: the solution, nothing left"
[ "$(printf '%s\n' "$XE" | grep -c '^  \$ export ')" = 2 ] || die "exercise: SOLUTION.md gives the README's two export lines"
# RED S6 #527: the same two blocks in zsh (the Mac's Terminal shell) print the same two lines - and no block passes an unquoted variable
# that could hold two options (zsh never splits one: the two would arrive as one word)
has "$XZ" "    $l0" "exercise (zsh): as shipped"; has "$XZ" "    $l" "exercise (zsh): the solution"
has "$XZ" "  the README's lines: exit 0 · what they printed:" "exercise (zsh): the README's commands, exit 0"; has "$XZ" "  the solution's lines: exit 0 · what they printed:" "exercise (zsh): the solution's lines, exit 0"
has "$XZ" "  the shell is now in: this unit's folder · its copy's own token in its log: 0 times, in the seven: 0 times · listening on 19585 now: 0" "exercise (zsh): nothing left"
[ "$(printf '%s\n' "$XZ" | grep -c '^    the seven: md5 ')" = 2 ] || die "exercise (zsh): two lines printed, one per block"
for f in exercise/README.md exercise/solution/SOLUTION.md; do ! block "$f" | grep -qE '(^|[^"{])\$V([^A-Za-z0-9_{]|$)|^V="[^"]* ' || die "$f passes V unquoted or as one string - zsh would hand the options over as one word (RED S6 #527): V=( ... ) and \"\${V[@]}\""; done
EXQ="Your turn: the README turns on header versioning, and old routes now answer four hundred. Give unversioned requests a version, and run the seven again."
grep -qxF -- "**Your turn:** ${EXQ#Your turn: }" exercise/README.md || die "exercise/README.md: the spoken exercise line"
[ "$(printf '%s\n' "$EXQ" | wc -w | tr -d ' ')" -le 25 ] || die "exercise: the spoken line is over 25 words"
echo "  exercise: one env -i shell - the README as written (the header key alone) -> $l0; the solution (+ the default 1.0) -> $l; the shell in this unit's folder after each, 19585 free; the same two lines again in one zsh shell; no block passes V unquoted (RED S6 #527)"

[ -z "$unpub" ] || die "no published hash for:$unpub - check the captures, then copy the md5s above into receipts.md5 and run again"
echo "c6-unit29: every capture 3/3 and = published; every spoken number asserted; 0 raw demo tokens in every capture, every log and every stub dump"
