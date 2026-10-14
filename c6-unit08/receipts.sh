#!/bin/bash
XPATH=$PATH                                           # the PATH you started this with: the exercise's own shell gets it
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25.0.4.1 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# GRAALVM_HOME names a GraalVM JDK 25 (README.md, "The GraalVM"): the native build reads it. Without it, this script makes every
# capture that needs no GraalVM, filling .m2-demo on the way, then stops before the native build.
# Course 6 · Request Bodies and HttpMessageConverter - this unit's receipts. The anchor changes: POST /customers takes a new
# customer as the request's JSON body (@RequestBody Customer), CustomerRepository gains add, and Jackson 2 - tiffinbox-web's
# jackson-databind and the parent's version pin - leaves the build. Nine captures, each run three times and hashed; cap() DIES
# when a hash differs from receipts.md5; every number the video says is asserted at the bottom by a check that can fail; the
# demo token is masked (gsub), and the checks count 0 raw copies of it in every capture, in the log of every run - the
# container's included - in every file this unit ships, in the binary and in the image's layers.
#   change     the previous tree against after/: the files that differ, the two Java files' lines and their code lines' diff,
#              the jar's lib/, the files left alone; a new customer POSTed as JSON to each tree; the routes Spring MVC registers
#              at start (TRACE), and the routing table (mappings exposed for one run)
#   chain      Spring MVC's message converters, in the order its adapter asks them, and which can read or write a Customer for
#              each media type; the JSON one's mapper, and one of its settings beside a plain mapper's (the harness's Converters)
#   body       one POST at DEBUG: the lines Spring MVC logs for it, read and written; the customer read back; then a record of
#              the harness's own whose compact constructor counts its calls (the harness's Body)
#   misfit     bodies that don't fit the record: malformed, empty, an array, a missing int, trailing text; an unknown property,
#              a number as text, a fraction - each answer and the WARN lines it added
#   unchecked  bodies nothing checks yet: an empty name, no meals, a price below zero, a meal type nobody serves - stored; a
#              misspelt key and a name that is taken - H2's refusals, 500s
#   ctype      A/B/A': the request's Content-Type named (A), left to curl's default (B) - the 415 and its Accept header - and A
#              again, on a fresh JVM
#   jackson    one Jackson left: the two POMs' lines, the jar's lib/ by name and by package, why the annotations jar stays and
#              at which version, Actuator's Jackson 2 mapper in Boot's condition report, the last course's missing-class lines;
#              C (labelled) configprops exposed alone, on each tree
#   exercise   exercise/README.md's commands, then exercise/solution/SOLUTION.md's, read from the files and run as written, one after
#              the other in ONE shell a viewer could have: env -i, /bin/bash, started in this folder
#   forms      the native build of after/ and what Spring's AOT step registered, then four forms - the jar, the AOT jar, the binary,
#              the image: each one's address, the seven (masked), exit 0; then, on a second start of each, the new route
# "The previous tree" is ../c6-unit07/after (the anchor before this change: the binding lesson's frozen tree), COPIED under
# .harness/before; after/ is this unit's frozen copy of ../c6-tiffinbox after the change, COPIED under .harness/after. This script
# never writes into another unit's folder, and never builds a frozen tree in place. Every run of TiffinBox starts in a folder under
# .harness/ that holds a config tree with a fake token (secrets/), as the README asks - the container's too, mounted read-only.
# Commands are printed exactly as they run: each goes through eval. "$CURLSET" is the comparison set since the secrets lesson
# (../c5-unit11/curlset.sh: the seven requests, POST /shutdown with the token's header read from the file). "$M2" is this unit's
# own repository, .m2-demo. The harness - harness/probe/web/Converters.java and Body.java (compiled with -parameters) - the
# course's, never TiffinBox's: outside com.tiffinbox, joined by --spring.main.sources on the extracted jar's class path;
# harness/table.py (reads one Actuator answer) and harness/shutdown.sh (POST /shutdown, the token read from its file) - is named on
# every capture that uses it. Every run passes options only. The seven always run on a fresh JVM, before any POST: a POST stores
# a customer, and three of the seven list customers.
# The network: every Maven build runs offline (-o) against .m2-demo and says so ("offline: yes"); a build that cannot resolve an
# artifact offline goes to Maven Central once, and says that ("offline: no - ..."). GraalVM's native plugin reads its metadata
# repository (a zip) from .m2-demo - and when the zip is not there it downloads it from GitHub, even under -o: so a native-profile
# build without the zip goes to Maven Central for it at once, and every native build's log is searched for the plugin's own
# download line - found, the run stops. Docker: no pull - eclipse-temurin:25-jre must already be on the daemon, and docker build
# prints how many of its lines say pull. At run time nothing leaves 127.0.0.1: TiffinBox listens there (in a container, on the
# container's own addresses, published on the host's 127.0.0.1 alone), every request goes there, and Logback writes to the
# terminal only.
# Masks and filters (README.md declares each; awk sub/gsub only): the demo token becomes "[masked: the N-character token]" (N its
# own length); the GraalVM's folder "$GRAALVM_HOME"; this folder's absolute path "…", the folder above it "…/..", the home folder
# "~"; your user name "<user>" - in every line of every capture. Spring's error timestamp becomes "…" (both forms: an ISO-8601
# string, epoch milliseconds) in the seven and wherever Spring's error body is printed; an identity hash after "@" becomes "…";
# H2's constraint and index names, in the quoted string after "violation: ", become "…"; a thread's number becomes N
# (tomcat-handler-N); where a native-image warning names the file it read an option from, the file's URL - or "null", which it
# prints when the path holds a space - becomes "…". Lines a log prints in an order that moves from run to run are sorted, and say
# so: the routes inside one of Spring MVC's registration blocks, the routing table's rows with details. A run's log lines are
# printed from their logger on (no time, no process id); Boot's first line is cut before " with PID". Long logs go through a
# declared filter, and what it cuts is counted or bounded. No image, container or ID is printed but the base image's digest. No
# duration is captured: the native build is judged against a bound; seconds go to the terminal.
# Ports (brief ⚑1, 19370-19379): after/'s jar 19370 · the previous tree 19371 · after/ with the harness joined 19372 · the AOT jar
# 19374 · the image 19377 · the binary 19378 · the exercise 19379 (19373, 19375 and 19376 are never bound). 18425 (TiffinBox's
# default) and 8080 (Tomcat's) are checked free too, and never bound on this machine (18425 only inside a container).
# Docker names (no unit number): the image tiffinbox-body:1.0.0 and the container tiffinbox-body. Each is checked absent before the
# first run - a name already there may be yours, and this script removes only what it creates - and removed on every exit: the
# container with docker rm -f, the image by name and by every ID a build of this run recorded. Docker's build cache is not
# pruned: .dockerignore keeps secrets/ out of every build context, so the cache holds no token.
set -e
# bash 5.2 and later turn an & in the replacement of ${x/pattern/replacement} into the matched text (patsub_replacement, on by
# default). Switched off, so /bin/bash 3.2 (./receipts.sh) and a newer bash (bash receipts.sh) run the same commands; 3.2 has no
# such option.
shopt -u patsub_replacement 2> /dev/null || true
# One locale for every tool, whatever yours is: sort's order, and what a program prints, follow it. The published captures were
# made with no locale set, which is the C locale.
export LC_ALL=C
cd "$(dirname "$0")"
# One run at a time: two runs share .harness/, the ports and the Docker names, and one would corrupt the other.
mkdir .r-lock 2> /dev/null || { echo "  *** another receipts.sh is running in this folder (.r-lock exists) - if none is, rmdir .r-lock ***"; exit 1; }
IMG=tiffinbox-body:1.0.0; BOX=tiffinbox-body
OURS=""                                              # set once the start-up checks found none of the Docker names above
# On every exit - the end, a failed check, or Ctrl-C - stop the processes this script started in the background ($pid, a server;
# $fpid, a start expected to end by itself; $xpid, the exercise's shell, with every process under it - its Maven, its JVM, its
# curl), if they still run, then sweep(): anything of this run still alive in its process group - a TiffinBox JVM, a binary,
# native-image's driver or builder - is stopped; then dclean(): this run's container and image. After an interrupt, a capture's
# unfinished runs (.r-NAME.1-3) go too; after a failed check they stay, for the diff the message names. The clean-up ignores a
# second Ctrl-C, and nothing in it can fail under set -e, so it always reaches the rmdir; the script still exits 130 after an
# interrupt (README.md, "Interrupted"). $pid, $fpid and $xpid are cleared whenever their process has been reaped. sweep() kills
# only processes of this run's own process group - start each run in a group of its own (README.md, "Interrupted").
pid=""; fpid=""; xpid=""
sweep() { local g i l
  g=$(ps -o pgid= -p $$ 2> /dev/null | tr -d ' ') || g=""
  [ -n "$g" ] || return 0
  i=0; while [ $i -lt 20 ]; do
    l=$(ps -axo pid=,pgid=,command= 2> /dev/null | awk -v g="$g" -v me=$$ -v gh="${GRAALVM_HOME:-/nonexistent}" '
      $2 == g && $1 != me && $3 != "awk" && $3 != "ps" && (index($0, "vminvocation.args") || index($3, gh "/bin/native-image") || $3 ~ /tiffinbox-web\/target\/tiffinbox-web$/ || index($0, "tiffinbox-web-1.0.0.jar") || index($0, "com.tiffinbox.web.TiffinBoxServer")) { print $1 }' | paste -sd' ' -) || l=""
    [ -n "$l" ] || return 0
    if [ $i -lt 10 ]; then kill $l 2> /dev/null || true; else kill -9 $l 2> /dev/null || true; fi
    sleep 0.5; i=$((i + 1)); done; }
# desc PID: every process under PID - its children, theirs, and so on (ps, by parent); killtree PID: PID and all of them, TERM
desc() { ps -axo pid=,ppid= 2> /dev/null | awk -v r="$1" '{ p[$1] = $2 } END { n = 1; q[1] = r; for (i = 1; i <= n; i++) for (c in p) if (p[c] == q[i]) { q[++n] = c; print c } }'; }
killtree() { local d; d=$(desc "$1"); kill "$1" $d 2> /dev/null || true; }
dclean() { [ -n "$OURS" ] || return 0
  docker rm -f "$BOX" > /dev/null 2>&1 || true
  docker image rm -f "$IMG" $(sort -u .harness/imgids 2> /dev/null) > /dev/null 2>&1 || true; }
trap 'trap "" INT TERM; [ -z "$xpid" ] || killtree "$xpid"; for p in "$pid" "$fpid" "$xpid"; do if [ -n "$p" ] && kill "$p" 2> /dev/null; then wait "$p" 2> /dev/null || true; fi; done; sweep || true; dclean || true; [ -z "$INTR" ] || rm -f .r-*.[123]; rmdir .r-lock 2> /dev/null || true' EXIT
INTR=""; trap 'INTR=1; exit 130' INT TERM
exec 3>&1                                            # die() speaks to the terminal even inside a redirected capture
die() { echo "  *** $* ***" >&3; exit 1; }
java -version 2>&1 | grep -q 'version "25' || die "JDK 25 needed; JAVA_HOME gives: $(java -version 2>&1 | head -1)"
for t in python3 curl rsync lsof unzip zip javac javap docker openssl; do command -v $t > /dev/null || die "$t is needed"; done
# A variable of yours must not become a property source, a JVM flag, a build setting, a native-image option or a docker build
# setting: every TIFFINBOX_*, SPRING_*, MANAGEMENT_*, SERVER_*, LOGGING_*, COMPOSE_*, BUILDKIT_* and BUILDX_* variable, DEBUG (Boot
# reads it as --debug), the variables that inject JVM flags, MAVEN_OPTS, MAVEN_ARGS, NATIVE_IMAGE_OPTIONS, DOCKER_BUILDKIT,
# DOCKER_DEFAULT_PLATFORM and SOURCE_DATE_EPOCH are removed first. GRAALVM_HOME stays: it says which GraalVM to use; so do
# DOCKER_HOST and DOCKER_CONTEXT: they say which Docker answers. (SERVER_ADDRESS or SERVER_PORT of yours would beat this tree's
# alias; TIFFINBOX_SHUTDOWN_TOKEN would beat the config tree.)
# The list is an extended regular expression (sed -E): /usr/bin/sed's basic ones have no alternation (RED C5-S4 #63). A canary is
# planted under every name first, and the run stops if one survives the loop.
for v in TIFFINBOX_CANARY SPRING_CANARY MANAGEMENT_CANARY SERVER_CANARY LOGGING_CANARY COMPOSE_CANARY BUILDKIT_CANARY BUILDX_CANARY DEBUG JAVA_TOOL_OPTIONS JDK_JAVA_OPTIONS _JAVA_OPTIONS MAVEN_OPTS MAVEN_ARGS NATIVE_IMAGE_OPTIONS DOCKER_BUILDKIT DOCKER_DEFAULT_PLATFORM SOURCE_DATE_EPOCH; do export "$v=planted-canary"; done
for v in $(env | sed -n -E 's/^(TIFFINBOX_[A-Za-z0-9_]*|SPRING_[A-Za-z0-9_]*|MANAGEMENT_[A-Za-z0-9_]*|SERVER_[A-Za-z0-9_]*|LOGGING_[A-Za-z0-9_]*|COMPOSE_[A-Za-z0-9_]*|BUILDKIT_[A-Za-z0-9_]*|BUILDX_[A-Za-z0-9_]*|DEBUG|JAVA_TOOL_OPTIONS|JDK_JAVA_OPTIONS|_JAVA_OPTIONS|MAVEN_OPTS|MAVEN_ARGS|NATIVE_IMAGE_OPTIONS|DOCKER_BUILDKIT|DOCKER_DEFAULT_PLATFORM|SOURCE_DATE_EPOCH)=.*/\1/p'); do unset "$v"; done
[ -z "$(env | grep -- '=planted-canary$')" ] || die "a variable survived the clean-up above: $(env | grep -- '=planted-canary$' | sed 's/=.*//' | paste -sd' ' -)"
# Every request this script makes goes to 127.0.0.1: an HTTP proxy named in your environment would carry curl's requests to that
# proxy instead - 127.0.0.1 and localhost go first in no_proxy and NO_PROXY.
export no_proxy="127.0.0.1,localhost${no_proxy:+,$no_proxy}" NO_PROXY="127.0.0.1,localhost${NO_PROXY:+,$NO_PROXY}"
# The GraalVM: named by GRAALVM_HOME, never guessed and never printed (its folder is masked). The captures were made with
# GraalVM CE 25.3.4.1 (native-image 25.0.4.1); another build would print other lines, so it is refused here, not minutes in.
GOK=yes
if [ -z "${GRAALVM_HOME:-}" ]; then GOK=no; unset GRAALVM_HOME
  echo "  GRAALVM_HOME is not set: this run fills .m2-demo, makes the captures that need no GraalVM and stops before the native build (README.md, The GraalVM)"
else
  [ -x "$GRAALVM_HOME/bin/native-image" ] || die "GRAALVM_HOME must name a GraalVM JDK 25 (its bin/native-image) - README.md, The GraalVM"
  NIV=$("$GRAALVM_HOME/bin/native-image" --version 2>&1 || true)
  printf '%s\n' "$NIV" | grep -q '^native-image 25\.0\.4\.1 ' && printf '%s\n' "$NIV" | grep -q 'GraalVM CE 25\.3\.4\.1+1\.1' || die "the published captures were made with GraalVM CE 25.3.4.1 (native-image 25.0.4.1); GRAALVM_HOME gives: $(printf '%s\n' "$NIV" | head -1)"
  export GRAALVM_HOME; fi
# Docker: docker info first; OrbStack's orb start only if it does not answer, then a bounded wait (60 s) that names the fix. The
# base image must already be on the daemon - this script never pulls.
if ! docker info > /dev/null 2>&1; then
  command -v orb > /dev/null && { orb start > /dev/null 2>&1 || true; }
  i=0; while ! docker info > /dev/null 2>&1 && [ $i -lt 60 ]; do sleep 1; i=$((i + 1)); done
  docker info > /dev/null 2>&1 || die "Docker does not answer - start it (OrbStack: orb start; Docker Desktop: open it), then run again"; fi
docker image inspect eclipse-temurin:25-jre > /dev/null 2>&1 || die "eclipse-temurin:25-jre is not on this Docker - pull it once (docker pull eclipse-temurin:25-jre: network, a build-time resolution), then run again"
PREV=../c6-unit07/after                              # the previous tree: the anchor before this change - read, copied
[ -e secrets ] && die "this folder holds a secrets/ - remove it: every run here starts in a folder under .harness/"
for t in "$PREV" after; do
  [ -f "$t/pom.xml" ] && [ -f "$t/README.md" ] && [ -f "$t/Dockerfile" ] && [ -f "$t/.dockerignore" ] || die "the tree $t (its pom.xml, README.md, Dockerfile or .dockerignore) is missing"
  [ -e "$t/secrets" ] || [ -e "$t/target" ] || [ -e "$t/tiffinbox-web/target" ] && die "$t holds a secrets/ or a target/ - it is a frozen copy, never built in place"
  grep -qx 'secrets/' "$t/.dockerignore" || die "$t's .dockerignore no longer keeps secrets/ out of a build context"; done
M2="$PWD/.m2-demo"; U="$PWD"; UP="$(cd .. && pwd)"; ME="$(id -un)"
W=tiffinbox-web/src/main/java/com/tiffinbox/web     # TiffinBox's web classes, in a tree
CORE=tiffinbox-core/src/main/java/com/tiffinbox     # its core classes
YAML=tiffinbox-web/src/main/resources/application.yaml
FAC=tiffinbox-web/src/main/resources/META-INF/spring.factories
JARP=tiffinbox-web/target/tiffinbox-web-1.0.0.jar    # the executable jar, in a tree's web module
BIN=tiffinbox-web/target/tiffinbox-web               # the binary native:compile-no-fork writes, in a tree's web module
TF=secrets/tiffinbox/shutdown-token                  # the config tree's file for tiffinbox.shutdown-token
# The demo token. FAKE, and meant to look it: it guards nothing but a demo server on 127.0.0.1 that every capture stops. It is
# written into .harness/*/secrets/ (git-ignored) when this script runs, and no capture prints it: see mask().
TOKEN=not-a-real-token-demo-only
[ ${#TOKEN} = 26 ] || die "the demo token must be 26 characters: the published captures name its length"
CURLSET=../c5-unit11/curlset.sh                      # the comparison set: the seven requests, POST /shutdown with the header
[ -f "$CURLSET" ] || die "$CURLSET is missing"
for f in harness/shutdown.sh harness/table.py harness/probe/web/Converters.java harness/probe/web/Body.java exercise/README.md exercise/solution/SOLUTION.md README.md; do [ -f "$f" ] || die "$f is missing"; done

# The ports and the Docker names, BEFORE anything is wiped (a survivor of an interrupted run answers POST /shutdown only with its
# token, which lives in .harness/ - so the message names the process to kill).
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
for p in 18425 8080 19370 19371 19372 19373 19374 19375 19376 19377 19378 19379; do
  [ "$(listeners $p)" = 0 ] || die "something already listens on $p - this unit's ports must be free; if it is a TiffinBox an interrupted run left behind, stop it: kill $(lsof -nP -iTCP:$p -sTCP:LISTEN -t 2> /dev/null | paste -sd' ' -)"; done
[ -z "$(docker ps -aq --filter "name=^$BOX\$" 2> /dev/null)" ] || die "a container named $BOX exists - it may be yours, and this script removes only what it creates; remove it yourself (docker rm -f $BOX), then run again"
docker image inspect "$IMG" > /dev/null 2>&1 && die "an image named $IMG exists - it may be yours; remove it yourself (docker image rm $IMG), then run again"
OURS=yes

# ---- the commands: read from after/README.md, the anchor's own, and asserted - each line must be there, whole -------------
readme() { grep -m1 -xF -- "$1" after/README.md > /dev/null || die "after/README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
J='java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431'
R_PLAIN=$(readme 'mvn -B package')
R_PNAT=$(readme 'mvn -B -Pnative package')
R_RUN=$(readme "$J")
R_AOTRUN=$(readme 'java -Dspring.aot.enabled=true -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431')
R_GRAAL=$(readme 'export GRAALVM_HOME=/path/to/a/graalvm-jdk-25')
R_INSTALL=$(readme 'mvn -B -Pnative install')
R_NATIVE=$(readme 'mvn -B -Pnative -pl tiffinbox-web native:compile-no-fork')
R_BIN=$(readme 'tiffinbox-web/target/tiffinbox-web --tiffinbox.port=18431')
R_EXTRACT=$(readme 'java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted')
R_CP=$(readme 'java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431')
R_DBUILD=$(readme 'docker build -t tiffinbox-docker:1.0.0 .')
R_DRUN=$(readme 'docker run -d --name tiffinbox -m 512m -v "$PWD/secrets:/app/secrets:ro" -p 127.0.0.1:18431:18425 tiffinbox-docker:1.0.0')
R_READY=$(readme "curl -s -w ' %{http_code}\n' http://127.0.0.1:18431/actuator/health/readiness")
R_Q=$(readme "curl -s -o /dev/null -w '%{http_code} %{content_type}\n' http://127.0.0.1:18431/customers")
# the request-mapping lesson's two lines: Spring MVC's mapping logger at TRACE, the kitchen at DEBUG; the routing table exposed
# for one run - and the binding lesson's one-customer line
L_SCAN=$(readme "$J --logging.level.kitchen=debug --logging.level.org.springframework.web.servlet.mvc.method.annotation.RequestMappingHandlerMapping=trace")
L_EXPO=$(readme "$J --management.endpoints.web.exposure.include=health,prometheus,mappings")
R_ONE=$(readme "curl -s -w ' %{http_code}\n' http://127.0.0.1:18431/customers/Ravi")
# this unit's line in the anchor's README: one new customer, its JSON body and its Content-Type on the command line
R_ADD=$(readme "curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '{\"name\":\"Asha\",\"mealsPerDay\":2,\"pricePerMeal\":110,\"mealType\":\"VEG\"}' http://127.0.0.1:18431/customers")
# lines the anchor's README already gave: Boot's web group at DEBUG (the embedded-Tomcat lesson's), Boot's condition report (the
# last course's --debug), and the last course's two lines that copy the extracted jar and delete one class from Jackson 2's jar
R_WEB=$(readme "$J --logging.level.web=debug")
R_DEBUG=$(readme "$J --debug")
R_HANG1=$(readme 'rm -rf tiffinbox-web/target/hang && mkdir tiffinbox-web/target/hang && cp tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar tiffinbox-web/target/hang/ && cp -R tiffinbox-web/target/extracted/lib tiffinbox-web/target/hang/lib')
R_HANG2=$(readme "zip -q -d tiffinbox-web/target/hang/lib/jackson-databind-2.22.2.jar 'com/fasterxml/jackson/databind/jdk14/JDK14Util*'")
EXPOF=${L_EXPO#"$J "}
[ "$EXPOF" = '--management.endpoints.web.exposure.include=health,prometheus,mappings' ] && [ "${R_DEBUG#"$J "}" = '--debug' ] && [ "${R_WEB#"$J "}" = '--logging.level.web=debug' ] || die "the README's options"
# This unit's own lines (README.md, "The commands this unit adds") - each asserted to be exactly that: the routing table read whole
# and its two /customers rows (change); the anchor's POST with its answer's Accept header printed, and the same without its
# Content-Type (ctype); configprops exposed alone for one run, and asked (jackson C); the class path Maven lists (jackson)
mine() { grep -m1 -xF -- "$1" README.md > /dev/null || die "README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
L_TABLE=$(mine 'curl -s http://127.0.0.1:18431/actuator/mappings | python3 harness/table.py')
L_ROW=$(mine "curl -s http://127.0.0.1:18431/actuator/mappings | python3 harness/table.py row '/customers'")
L_A=$(mine "curl -s -w ' %{http_code} · Accept: [%header{accept}]\n' -H 'Content-Type: application/json' --data '{\"name\":\"Asha\",\"mealsPerDay\":2,\"pricePerMeal\":110,\"mealType\":\"VEG\"}' http://127.0.0.1:18431/customers")
L_B=$(mine "curl -s -w ' %{http_code} · Accept: [%header{accept}]\n' --data '{\"name\":\"Asha\",\"mealsPerDay\":2,\"pricePerMeal\":110,\"mealType\":\"VEG\"}' http://127.0.0.1:18431/customers")
L_CONF=$(mine "$J --management.endpoints.web.exposure.include=health,configprops")
L_CONFQ=$(mine "curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:18431/actuator/configprops")
L_MCP=$(mine 'mvn -B -q dependency:build-classpath -Dmdep.outputFile=target/cp.txt')
# B is A with one option taken out - the request's Content-Type - and A is the anchor's line with its answer's Accept header added
CTH=" -H 'Content-Type: application/json'"; ACH=" · Accept: [%header{accept}]"
r=${L_A/"$CTH"/}; [ "$r" = "$L_B" ] || die "ctype: B must be A without its Content-Type, and nothing else"
r=${L_A/"$ACH"/}; [ "$r" = "$R_ADD" ] || die "ctype: A must be the anchor's POST line with the Accept header printed, and nothing else"
# ADATA: the anchor's line's JSON body; PREF: its curl and options, before the body. pc() builds the same line for another port,
# path and body - and must give the README's line back
ADATA=${R_ADD#* --data \'}; ADATA=${ADATA%%\' http://*}
PREF=${R_ADD% --data *}
# off DIR 'README mvn LINE' [PHASE]: the README's Maven line as this script runs it - from DIR, offline (-o), this unit's own
# repository, and for a build phase (package, install) clean and without tests. dev() takes those four things back out, and
# must give the README's line again: so the command on screen is the README's, with exactly those changes.
off() { local c=${2/mvn -B /mvn -o -B -Dmaven.repo.local=\"\$M2\" }
  [ -n "$3" ] && c=${c/ $3/ -DskipTests clean $3}
  printf 'cd %s && %s\n' "$1" "$c"; }
dev() { local c=${1#cd * && }; c=${c/ -o -B -Dmaven.repo.local=\"\$M2\" / -B }; c=${c/ -DskipTests clean / }; printf '%s\n' "$c"; }
# at DIR PORT 'README LINE': the README's line run from DIR, its port 18431 made PORT
at() { printf 'cd %s && %s\n' "$1" "${3/--tiffinbox.port=18431/--tiffinbox.port=$2}"; }
# hcp DIR PORT CLASS ['FLAGS']: the README's class-path line - the extracted jar, TiffinBox's own main - from DIR, its port made
# PORT, the harness's classes added to the class path (../hc) and CLASS joined (--spring.main.sources=); FLAGS after
hcp() { local c; c=$(at "$1" "$2" "$R_CP"); c=${c/lib\/\*\"/lib\/*:..\/hc\"}; printf '%s --spring.main.sources=%s%s\n' "$c" "$3" "${4:+ $4}"; }
# url 'README curl LINE' PORT: the README's curl line, its port 18431 made PORT
url() { printf '%s\n' "${1/:18431\//:$2/}"; }
# qurl PORT PATH: the URL; one that holds a character the shell reads (; ? & * { }) is single-quoted, so eval hands it to curl whole
qurl() { local u="http://127.0.0.1:$1$2"; case $2 in *[\;\?\&\*\{\}]*) u="'$u'" ;; esac; printf '%s\n' "$u"; }
# qc PORT PATH ['CURL OPTIONS']: the README's status-and-type line, its port made PORT and its path PATH, OPTIONS before the URL
qc() { local c; c=$(url "$R_Q" "$1"); c=${c% http://*}; printf '%s%s %s\n' "$c" "${3:+ $3}" "$(qurl "$1" "$2")"; }
# bc PORT PATH ['CURL OPTIONS']: the binding lesson's one-customer line (the anchor's README) - the body and the status - the same way
bc() { local c=${R_ONE% http://*}; printf '%s%s %s\n' "$c" "${3:+ $3}" "$(qurl "$1" "$2")"; }
# pc PORT PATH 'BODY': this unit's line in the anchor's README - a POST, its Content-Type application/json - its port, its path and
# its JSON body swapped; the body single-quoted, as the README writes it
pc() { printf "%s --data '%s' %s\n" "$PREF" "$3" "$(qurl "$1" "$2")"; }
# exe 'COMMAND': the command with "exec" after its "cd DIR && " and any NAME=value before the program - so $pid is the program's
exe() { printf '%s\n' "$1" | sed -E 's/&& (([A-Z_]+=[^ ]* )*)/\&\& \1exec /'; }
# The docker lines, as this script runs them: the README's build line with plain progress and this script's own tag; its run line
# with this script's own name and tag, the port published on 127.0.0.1 made PORT, and your user and group added - the config tree
# is yours, mode 0600 (R.74). undock() takes those changes back out, and must give the README's lines again.
UARG='--user "$(id -u):$(id -g)"'
dbuild() { local c=${R_DBUILD/docker build -t tiffinbox-docker:1.0.0 /docker build --progress=plain -t $IMG }; printf 'cd %s && %s\n' "$1" "$c"; }
drun() { local c=${R_DRUN/--name tiffinbox /--name $BOX $UARG }; c=${c/127.0.0.1:18431:18425/127.0.0.1:$2:18425}; c=${c/% tiffinbox-docker:1.0.0/ $IMG}; printf 'cd %s && %s\n' "$1" "$c"; }
undock() { local c=${1#cd * && }; c=${c/--progress=plain /}; c=${c/" $UARG"/}; c=${c//$IMG/tiffinbox-docker:1.0.0}; c=${c/--name $BOX /--name tiffinbox }; c=${c/127.0.0.1:1937?:18425/127.0.0.1:18431:18425}; printf '%s\n' "$c"; }
[ "$(undock "$(dbuild .harness/x)")" = "$R_DBUILD" ] || die "not the README's build line with the declared changes: $(dbuild .harness/x)"
[ "$(undock "$(drun .harness/x 19377)")" = "$R_DRUN" ] || die "not the README's run line with the declared changes: $(drun .harness/x 19377)"
C_PRE=$(off .harness/pre "$R_INSTALL" install)
for c in "$C_PRE" "$(off .harness/x "$R_PLAIN" package)" "$(off .harness/x "$R_PNAT" package)" "$(off .harness/x "$R_NATIVE")" "$(off .harness/x "$L_MCP")"; do
  r=$(dev "$c"); [ "$r" = "$R_PLAIN" ] || [ "$r" = "$R_PNAT" ] || [ "$r" = "$R_INSTALL" ] || [ "$r" = "$R_NATIVE" ] || [ "$r" = "$L_MCP" ] || die "not a README line with the offline changes: $c"; done
[ "$(exe "$(at .harness/x 19370 "$R_RUN")")" = 'cd .harness/x && exec java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19370' ] || die "exe()"
[ "$(hcp .harness/x 19372 probe.web.Body)" = 'cd .harness/x && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19372 --spring.main.sources=probe.web.Body' ] || die "hcp()"
[ "$(qc 19370 /customersXYZ)" = "curl -s -o /dev/null -w '%{http_code} %{content_type}\n' http://127.0.0.1:19370/customersXYZ" ] && [ "$(bc 19370 /customers/Asha)" = "curl -s -w ' %{http_code}\n' http://127.0.0.1:19370/customers/Asha" ] || die "qc(), bc()"
[ "$(pc 18431 /customers "$ADATA")" = "$R_ADD" ] && [ "$ADATA" = '{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' ] || die "pc(): not the anchor's POST line"
echo "  the commands: after/README.md gives all 22 lines this script runs or derives from; README.md the 7 this unit adds"

# ---- build: before the captures - after/'s native install (it fills .m2-demo on a fresh clone), the previous tree's package;
# ---- the harness compiled against after/'s own jar; what .m2-demo holds ---------------------------------------------------
rm -rf .harness; mkdir -p .harness; : > .harness/imgids
rsync -a --exclude target --exclude secrets after/ .harness/pre/
rsync -a --exclude target --exclude secrets "$PREV/" .harness/pre0/
ZIP="$M2/org/graalvm/buildtools/graalvm-reachability-metadata/1.1.8/graalvm-reachability-metadata-1.1.8-repository.zip"
# ghub LOG: the native plugin went over the network for its metadata repository. Never allowed: the run stops.
ghub() { grep -qE 'Downloaded GraalVM reachability metadata repository from http|Failed to download from http' "$1"; }
# mbuild 'COMMAND' LOG LABEL: the command, run as printed (eval), its log kept in LOG (never printed whole); Maven Central only
# if the offline build could not resolve something - and the line says which (offline: yes / no), so a run that went online is
# never silent (inside a capture, "no" changes the capture's hash: cap() then dies).
mbuild() { local how=yes ec=0 c=$1
  case $c in *' -Pnative '*) [ -f "$ZIP" ] || { c=${c/mvn -o -B /mvn -B }; how="no - GraalVM's metadata repository was not in .m2-demo, so Maven Central was asked for it"; } ;; esac
  (eval "$c") > "$2" 2>&1 < /dev/null || ec=$?
  if [ $ec != 0 ] && [ "$how" = yes ] && grep -qE 'offline mode|Could not resolve|could not be resolved|Cannot access|No plugin found for prefix' "$2"; then
    how="no - the offline build could not resolve an artifact, so Maven Central was asked"; ec=0
    (eval "${c/mvn -o -B /mvn -B }") > "$2" 2>&1 < /dev/null || ec=$?; fi
  if ghub "$2"; then echo "  built $3 · offline: no - GraalVM's native plugin went to GitHub for its metadata repository · exit $ec"
    die "$3: GraalVM's native plugin went over the network for its metadata repository - README.md, The repository"; fi
  [ $ec = 0 ] || { tail -30 "$2" >&3
    ! grep -qE 'Could not resolve|could not be resolved|Could not transfer|Cannot access' "$2" || die "build failed: $3 - Maven could resolve Boot's parent and plugins neither from .m2-demo nor from Maven Central: a fresh clone's first run needs the network once, to fill .m2-demo"
    die "build failed: $3"; }
  echo "  built $3 · offline: $how · exit $ec"; }
# tree FOLDER [TOKEN]: a config tree in FOLDER/secrets holding one file, the token (the demo token unless named) and a newline,
# readable by its owner alone
tree() { mkdir -p "$1/secrets/tiffinbox"; (umask 077 && printf '%s\n' "${2:-$TOKEN}" > "$1/$TF"); chmod 700 "$1/secrets" "$1/secrets/tiffinbox"; }
mbuild "$C_PRE" .harness/build-pre.log ".harness/pre (after/, the profile native, both modules into \$M2)"
mbuild "$(off .harness/pre0 "$R_PLAIN" package)" .harness/build-pre0.log ".harness/pre0 (the previous tree)"
# The dependency plugin's build-classpath (this unit's line, run in jackson) needs the plugin's own dependencies, which none of the
# builds above needed: a fresh clone's .m2-demo would fetch them inside jackson's first run, and that run alone would say
# "offline: no" - the capture would drift. So both trees' class paths are listed once here, before any capture.
mbuild "$(off .harness/pre0 "$L_MCP")" .harness/build-cp0.log ".harness/pre0's class path (this unit's line)"
mbuild "$(off .harness/pre "$L_MCP")" .harness/build-cp.log ".harness/pre's class path (this unit's line)"
[ -f "$M2/org/springframework/boot/spring-boot-starter-webmvc/4.1.1/spring-boot-starter-webmvc-4.1.1.jar" ] || die "Spring MVC's starter is not in .m2-demo after the first build"
[ -f "$M2/org/graalvm/buildtools/native-maven-plugin/1.1.8/native-maven-plugin-1.1.8.jar" ] || die "GraalVM's native plugin 1.1.8 is not in .m2-demo after the first build"
[ -f "$ZIP" ] || die "GraalVM's metadata repository is not in .m2-demo after the first build - README.md, The repository"
PARENT="$M2/org/springframework/boot/spring-boot-starter-parent/4.1.1/spring-boot-starter-parent-4.1.1.pom"
[ -f "$PARENT" ] || die "Boot's parent POM is not in .m2-demo after the first build"
(cd .harness/pre && eval "$R_EXTRACT") > .harness/extract-pre.log 2>&1 || die "the README's extract line failed on .harness/pre"
javac -parameters -d .harness/hc -cp ".harness/pre/tiffinbox-web/target/extracted/lib/*" harness/probe/web/*.java > .harness/javac.log 2>&1 || { cat .harness/javac.log >&3; die "the harness did not compile against after/'s jar"; }
echo "  .m2-demo holds Spring MVC's starter, Boot's parent, GraalVM's native plugin 1.1.8 and its metadata repository; the harness compiled against after/'s jar"

# ---- helpers ------------------------------------------------------------------------------------------------------------
# raw TOKEN FILE...: how many times TOKEN appears, raw, in the files (occurrences, not lines; binary files read as text)
raw() { local t=$1; shift; cat "$@" | LC_ALL=C grep -aoF -- "$t" | wc -l | tr -d ' '; }
LOGS=0; FLOGS=0; CLOGS=0; LASTE=""                   # logs counted: served runs, starts that ended by themselves, containers
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
  case " $l " in *':8080 '*) kill -9 "$pid" 2> /dev/null || true; die "it listened on 8080, Tomcat's default - never bound by this script";; esac
  echo "  listens on: $l · loopback only: $(lb "$l")"; echo "  Boot's first line: $(first .harness/run.out)"; }
# started FILE: Boot's started line - logged by Boot's TomcatWebServer, not by Tomcat - from its logger on (logger: message)
started() { grep -m1 ' : Tomcat started on port ' "$1" | sed 's/^.*--- \[[^]]*\] //; s/ *: /: /'; }
tline() { local i=0; while ! grep -q 'Tomcat started on port ' .harness/run.out && [ $i -lt 120 ]; do sleep 0.25; i=$((i + 1)); done
  echo "  Boot's started line - logger: message: $(started .harness/run.out)"; }
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
# ready PORT [CONTAINER]: readiness asked until it answers 200 - every 0.25 s, up to 120 s, not printed - then the README's
# readiness line, printed and run once. No assertion before it (R.41, R.75). A JVM ($pid) or a container that exits first stops
# the run.
ready() { local i=0 c=""
  while [ $i -lt 480 ]; do c=$(curl -s -o /dev/null -w '%{http_code}' "http://127.0.0.1:$1/actuator/health/readiness" 2> /dev/null || true); [ "$c" = 200 ] && break
    if [ -n "$pid" ]; then kill -0 "$pid" 2> /dev/null || { tail -20 .harness/run.out >&3; die "it exited before readiness answered 200"; }; fi
    if [ -n "${2:-}" ]; then [ "$(docker inspect -f '{{.State.Running}}' "$2" 2> /dev/null)" = true ] || { docker logs "$2" 2>&1 | tail -20 >&3; die "the container exited before readiness answered 200"; }; fi
    sleep 0.25; i=$((i + 1)); done
  [ "$c" = 200 ] || die "readiness never answered 200 on $1"
  askj "$R_READY" "$1"; }
# logtok [N]: the demo token 0 times in the last run's log, and the header's name exactly N times (0 unless named: a WARN line
# of Spring MVC's that names a missing header is the one place it may appear)
logtok() { local t h; t=$(raw "$TOKEN" .harness/run.out .harness/run.err); h=$(cat .harness/run.out .harness/run.err | LC_ALL=C grep -aoi -- 'x-shutdown-token' | wc -l | tr -d ' ')
  LOGS=$((LOGS + 1)); [ "$t" = 0 ] && [ "$h" = "${1:-0}" ] || die "a log held the demo token ($t) or its header's name ($h, expected ${1:-0})"
  echo "  its log: the demo token 0 times · X-Shutdown-Token $h times"; }
# tsmask: Spring's error timestamp, both forms (an ISO-8601 string, epoch milliseconds), becomes "…" (README.md, Masks)
tsmask() { awk '{ gsub(/"timestamp":"[^"]*"/, "\"timestamp\":\"…\""); gsub(/"timestamp":[0-9]+/, "\"timestamp\":…"); print }'; }
# gone PORT: after a POST /shutdown - the JVM must leave within 15 s, the port must be free; its exit code
gone() { local i=0 e=0
  while kill -0 "$pid" 2> /dev/null && [ $i -lt 60 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$pid" 2> /dev/null && { kill "$pid"; die "the server on $1 was still running 15 s after POST /shutdown"; }
  wait "$pid" || e=$?; pid=""; LASTE=$e
  [ "$(listeners "$1")" = 0 ] || die "something still listens on $1"; }
# sevenq PORT DIR: the comparison set's seven requests (POST /shutdown carries the header, read from DIR's token file), the POST
# line printed; the JVM must leave within 15 s of them, the port must be free; its exit code; the md5 of the seven after the
# timestamp mask, and how many lines the mask changed
sevenq() { local m
  echo "\$ \$CURLSET $1 $2/$TF"
  "$CURLSET" "$1" "$2/$TF" | grep ' -> ' > .harness/responses.txt || true
  tsmask < .harness/responses.txt > .harness/responses.m.txt
  grep '^POST ' .harness/responses.m.txt | sed 's/^/  /' || echo "  (no POST line)"
  gone "$1"
  m=$(diff .harness/responses.txt .harness/responses.m.txt | grep -c '^<' || true)
  echo "  exit $LASTE · the seven responses: $(wc -l < .harness/responses.m.txt | tr -d ' ') lines · lines the timestamp mask changed: $m · md5 $(md5 -q .harness/responses.m.txt)"; }
seven() { sevenq "$@"; logtok; }
# post PORT DIR [PATH] [HEADER]: POST PATH (/shutdown) with DIR's token (harness/shutdown.sh), in the header HEADER
# (X-Shutdown-Token unless named) - its answer, the timestamp masked
post() { echo "\$ harness/shutdown.sh $1 $2/$TF${3:+ $3}${4:+ $4}"; harness/shutdown.sh "$1" "$2/$TF" ${3:+"$3"} ${4:+"$4"} | tsmask | sed 's/^/  /'; }
# stop PORT DIR [N]: POST /shutdown with DIR's token; the JVM must leave, the port must be free; its log counted (logtok N)
stop() { post "$1" "$2"; gone "$1"; echo "  exit $LASTE · listening on $1 now: 0"; logtok "${3:-0}"; }
now() { local p o=""; for p in "$@"; do o="$o${o:+ · }$p $(listeners "$p")"; done; echo "  listening now: $o"; }
# tnum: a thread's number becomes N - Tomcat's tomcat-handler-N (README.md, Masks)
tnum() { awk '{ gsub(/tomcat-handler-[0-9]+/, "tomcat-handler-N"); print }'; }
mask() { awk -v t="$TOKEN" -v g="${GRAALVM_HOME:-}" -v u="$U" -v up="$UP" -v hm="$HOME" -v me="$ME" -v tl="${#TOKEN}" '
  function lit(x) { gsub(/[][\\.^$*+?(){}|\/]/, "\\\\&", x); return x }
  function enc(x) { gsub(/ /, "%20", x); return x }
  BEGIN { T = lit(t); G = lit(g); GE = lit(enc(g)); P = lit(u); Q = lit(up); H = lit(hm); PE = lit(enc(u)); QE = lit(enc(up)); M = "(^|[^A-Za-z0-9_])" lit(me) "([^A-Za-z0-9_]|$)" }
  { gsub(T, "[masked: the " tl "-character token]"); if (g != "") { gsub(G, "$GRAALVM_HOME"); gsub(GE, "$GRAALVM_HOME") }; gsub(P, "…"); gsub(PE, "…")
    gsub(Q, "…/.."); gsub(QE, "…/.."); gsub(H, "~")
    while (match($0, M)) { pre = substr($0, 1, RSTART - 1); s = substr($0, RSTART, RLENGTH); post = substr($0, RSTART + RLENGTH)
      sub(lit(me), "<user>", s); $0 = pre s post }
    print }'; }

unpub=""
cap() { local nm=$1 h pub i; shift
  for i in 1 2 3; do "$@" > .harness/cap.raw 2>&1 || true; [ -z "$pid" ] && [ -z "$fpid" ] && [ -z "$xpid" ] || die "$nm left a process running"
    [ -z "$(docker ps -aq --filter "name=^$BOX\$")" ] || die "$nm left a container"
    raw "$TOKEN" .harness/cap.raw > ".harness/raw-$nm.$i"; mask < .harness/cap.raw > ".r-$nm.$i"; done
  h=$(md5 -q ".r-$nm.1")
  [ "$h" = "$(md5 -q ".r-$nm.2")" ] && [ "$h" = "$(md5 -q ".r-$nm.3")" ] || die "$nm drifts across three runs (diff .r-$nm.1 .r-$nm.2 .r-$nm.3)"
  mv ".r-$nm.1" ".r-$nm.out"; rm -f ".r-$nm.2" ".r-$nm.3"
  pub=$(awk -v n="$nm" '$1 == n { print $2 }' receipts.md5 2> /dev/null || true)
  if [ -z "$pub" ]; then printf '  %-9s md5 %s  3/3  (no published hash)\n' "$nm" "$h"; unpub="$unpub $nm"
  elif [ "$pub" = "$h" ]; then printf '  %-9s md5 %s  3/3  = published\n' "$nm" "$h"
  else printf '  %-9s md5 %s  3/3  DIFFERS from the published %s\n' "$nm" "$h" "$pub"
    die "$nm is not the published capture - suspect another JDK, GraalVM, Boot, Maven or Docker, another base image, a busy machine, a busy port, a variable of yours, or an edited source; diff .r-$nm.out against its block in README.md"; fi; }
copy() { rm -rf "$2" "$2".*; rsync -a --exclude target --exclude secrets "$1/" "$2/"; tree "$2"; }
pbuild() { local c; c=$(off "$1" "${3:-$R_PLAIN}" package); echo "\$ $c"; mbuild "$c" "$1.build.log" "$2"; }
code() { grep -vE '^[[:space:]]*(\*|/\*\*|\*/|//|#|<!--|$)' "$1"; }
lines() { if [ -f "$1" ]; then wc -l < "$1" | tr -d ' '; else echo deleted; fi; }
libs() { unzip -Z1 "$1" | grep -E '^BOOT-INF/lib/.*\.jar$' | sed 's#^BOOT-INF/lib/##' | sort; }
extract() { local c="cd $1 && $R_EXTRACT"; echo "\$ $c"; (eval "$c") > .harness/extract.log 2>&1 < /dev/null || die "the README's extract line failed in $1"; echo "  exit 0"; }
# settle: the log stops growing (the same length twice, 0.5 s apart; up to 15 s) - a request's last line is written just after
# its answer leaves
settle() { local i=0 a b=-1; while [ $i -lt 30 ]; do a=$(wc -l < .harness/run.out | tr -d ' '); [ "$a" = "$b" ] && return 0; b=$a; sleep 0.5; i=$((i + 1)); done; die "the log never settled"; }
mark() { settle; wc -l < .harness/run.out | tr -d ' '; }
# logl FROM [LEVELS] [TO]: the run's lines after line FROM (up to line TO) at those levels (an extended regular expression;
# WARN|ERROR unless named), from their level and logger on - an identity hash after "@" and a date in an error map made "…"
# (README.md, Masks)
logl() { awk -v from="$1" -v lv="${2:-WARN|ERROR}" -v to="${3:-0}" 'NR > from && (to == 0 || NR <= to) && $0 ~ (" (" lv ") [0-9]+ --- \\[") { l = $2; s = $0; i = index(s, " --- ["); s = substr(s, i + 6); i = index(s, "] "); s = substr(s, i + 2)
    i = index(s, " : "); lg = substr(s, 1, i - 1); sub(/ +$/, "", lg); msg = substr(s, i + 3)
    gsub(/@[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]+/, "@…", msg); gsub(/timestamp=[^,]*,/, "timestamp=…,", msg); print "    " l " " lg ": " msg }' .harness/run.out; }
# wans FROM FILE: an answer (FILE) and the WARN lines its request added after line FROM, at the level the run was started with:
# the answer's last line ends with their count, each one follows
wans() { local w; settle; w=$(logl "$1" WARN | grep -c . || true)
  awk -v w="$w" '{ l[NR] = $0 } END { for (i = 1; i <= NR; i++) print "  " l[i] (i == NR ? " · WARN lines it added: " w : "") }' "$2"
  [ "$w" = 0 ] || logl "$1" WARN; }
# ask PORT PATH ['CURL OPTIONS']: this unit's one-customer line (body and status), printed and run, the answer's timestamp
# masked; then the WARN lines the request added (wans)
ask() { local c n0; n0=$(mark); c=$(bc "$@"); echo "\$ $c"; (eval "$c") 2>&1 < /dev/null | tsmask > .harness/ask.txt; wans "$n0" .harness/ask.txt; }
# st PORT PATH ['CURL OPTIONS']: the README's status-and-type line, printed and run; then the WARN lines it added (wans)
st() { local c n0; n0=$(mark); c=$(qc "$@"); echo "\$ $c"; (eval "$c") 2>&1 < /dev/null > .harness/ask.txt; wans "$n0" .harness/ask.txt; }
# frames: the stack frames in the run's log, bounded - TiffinBox's own, the JVM's and Tomcat's move with the class path
frames() { local n; n=$(grep -c "^$(printf '\t')at " .harness/run.out || true)
  if [ "$n" = 0 ]; then echo "  stack frames in its log: 0"; return; fi
  echo "  stack frames in its log: $( [ "$n" -gt 40 ] && echo 'over 40' || echo "$n"), not shown · its exceptions' first lines:"
  grep -E '^([a-z][a-z0-9_]*\.)+[A-Z][A-Za-z0-9_$]*(: .*)?$|^Caused by: ' .harness/run.out | sed 's/^/    /' || true; }
# pj PORT 'BODY': this unit's POST line (pc) to /customers with that JSON body, printed and run, the answer's timestamp masked;
# then the WARN lines its request added (wans)
pj() { local c n0; n0=$(mark); c=$(pc "$1" /customers "$2"); echo "\$ $c"; (eval "$c") 2>&1 < /dev/null | tsmask > .harness/ask.txt; wans "$n0" .harness/ask.txt; }
# erec FROM: each ERROR record the log gained after line FROM - its level, its logger and its message (H2's constraint and index
# names, the quoted string after "violation: ", made "…"), then the record's next line (the SQL statement, H2's error code at its
# end); then its stack frames, bounded, its other lines (the exception printed again, a blank line), counted, none shown; and how
# many WARN lines came with it
erec() { settle; awk -v from="$1" '
  NR <= from { next }
  / [A-Z]+ [0-9]+ --- \[/ { inr = 0 }
  / (WARN|ERROR) [0-9]+ --- \[/ { s = $0; i = index(s, " --- ["); s = substr(s, i + 6); i = index(s, "] "); s = substr(s, i + 2)
    i = index(s, " : "); lg = substr(s, 1, i - 1); sub(/ +$/, "", lg); m = substr(s, i + 3); gsub(/violation: "[^"]*"/, "violation: \"…\"", m)
    print "    " $2 " " lg ": " m; nx = 1; inr = 1; if ($2 == "WARN") w++; next }
  nx == 1 { print "      " $0; nx = 0; next }
  /^\tat / { fr++; next }
  inr { ot++ }
  END { print "    its stack frames: " (fr > 50 ? "over 50" : fr + 0) ", its other lines: " (ot + 0) " - none shown · WARN lines it added: " (w + 0) }' .harness/run.out; }
# p5 PORT 'BODY': a POST that ends in a 500 - the answer, then the log's record of it (erec)
p5() { local c n0; n0=$(mark); c=$(pc "$1" /customers "$2"); echo "\$ $c"; (eval "$c") 2>&1 < /dev/null | tsmask | sed 's/^/  /'; erec "$n0"; }
# dbg FROM: every line the log gained after line FROM, from its logger on (logger: message)
dbg() { awk -v from="$1" 'NR > from && / [A-Z]+ [0-9]+ --- \[/ { s = $0; i = index(s, " --- ["); s = substr(s, i + 6); i = index(s, "] "); s = substr(s, i + 2)
    i = index(s, " : "); lg = substr(s, 1, i - 1); sub(/ +$/, "", lg); print "    " lg ": " substr(s, i + 3) }' .harness/run.out; }

# ---- change: the previous tree against after/ ---------------------------------------------------------------------------------
# The code lines of TiffinBoxServer.java (neither comment nor blank, nor an import) that name what the change adds, counted before
# and after: a request body (@RequestBody), a route (@GetMapping, @PostMapping)
BODYRE='@RequestBody([( ]|$)'
MAPRE='@(GetMapping|PostMapping)\('
change() { local f n m c
  echo "the previous tree and after/, both copied under .harness/ with a config tree, each built with the README's line (offline):"
  copy "$PREV" .harness/before; copy after .harness/after
  pbuild .harness/before "the previous tree"; pbuild .harness/after "after/"
  echo "both jars extracted (the README's line) - the class path the harness runs on:"
  extract .harness/before; extract .harness/after
  echo "the harness, compiled against after/'s own jar - with -parameters:"
  c="javac -parameters -d .harness/hc -cp \".harness/after/tiffinbox-web/target/extracted/lib/*\" harness/probe/web/*.java"
  echo "\$ $c"; rm -rf .harness/hc; (eval "$c") > .harness/javac.log 2>&1 < /dev/null || { cat .harness/javac.log >&3; die "the harness did not compile against after/'s jar"; }
  echo "  exit 0"
  echo "the files that differ:"
  echo "\$ diff -rq -x target -x secrets .harness/before .harness/after"
  diff -rq -x target -x secrets .harness/before .harness/after | sed 's/^/  /' || true
  echo "the two Java files, their lines (wc -l), before -> after:"
  for f in "$W/TiffinBoxServer.java" "$CORE/CustomerRepository.java"; do echo "  ${f##*/}: $(lines ".harness/before/$f") -> $(lines ".harness/after/$f")"; done
  code ".harness/before/$W/TiffinBoxServer.java" > .harness/fb.txt; code ".harness/after/$W/TiffinBoxServer.java" > .harness/fa.txt
  code ".harness/before/$CORE/CustomerRepository.java" > .harness/rb.txt; code ".harness/after/$CORE/CustomerRepository.java" > .harness/ra.txt
  grep -v '^import ' .harness/fb.txt > .harness/fbi.txt || true; grep -v '^import ' .harness/fa.txt > .harness/fai.txt || true
  echo "  TiffinBoxServer.java, its lines that are neither comment nor blank: $(wc -l < .harness/fb.txt | tr -d ' ') -> $(wc -l < .harness/fa.txt | tr -d ' '), of them - imports left out - naming a request body (@RequestBody): $(grep -cE "$BODYRE" .harness/fbi.txt || true) -> $(grep -cE "$BODYRE" .harness/fai.txt || true) · a route (@GetMapping, @PostMapping): $(grep -cE "$MAPRE" .harness/fbi.txt || true) -> $(grep -cE "$MAPRE" .harness/fai.txt || true)"
  diff -U0 .harness/fb.txt .harness/fa.txt | tail -n +3 > .harness/code.diff || true
  echo "  its code lines' diff (diff -U0 of the lines above, its file names cut) - hunks: $(grep -c '^@@ ' .harness/code.diff || true) · lines out: $(grep -c '^-' .harness/code.diff || true) · in: $(grep -c '^+' .harness/code.diff || true) - whole:"
  sed 's/^/    /' .harness/code.diff
  diff -U0 .harness/rb.txt .harness/ra.txt | tail -n +3 > .harness/core.diff || true
  echo "  CustomerRepository.java, its code lines: $(wc -l < .harness/rb.txt | tr -d ' ') -> $(wc -l < .harness/ra.txt | tr -d ' ') - its code lines' diff, the same way - hunks: $(grep -c '^@@ ' .harness/core.diff || true) · lines out: $(grep -c '^-' .harness/core.diff || true) · in: $(grep -c '^+' .harness/core.diff || true) - whole:"
  sed 's/^/    /' .harness/core.diff
  echo "  pom.xml and tiffinbox-web/pom.xml: Jackson 2 out - their lines in jackson"
  libs .harness/before/$JARP > .harness/lb.txt; libs .harness/after/$JARP > .harness/la.txt
  echo "the executable jar's BOOT-INF/lib: $(wc -l < .harness/lb.txt | tr -d ' ') jars -> $(wc -l < .harness/la.txt | tr -d ' ') · removed $(comm -23 .harness/lb.txt .harness/la.txt | wc -l | tr -d ' ') · added $(comm -13 .harness/lb.txt .harness/la.txt | wc -l | tr -d ' ') - by name in jackson"
  diff .harness/before/README.md .harness/after/README.md > .harness/file.diff || true
  echo "  README.md - the anchor's README: lines added $(grep -c '^> ' .harness/file.diff || true), removed $(grep -c '^< ' .harness/file.diff || true) - its new section and the history notes the change made false (not shown)"
  (cd after && find . -type f | sed 's#^\./##' | sort) > .harness/files.txt
  n=0; m=0; while IFS= read -r f; do m=$((m + 1)); cmp -s ".harness/before/$f" ".harness/after/$f" && n=$((n + 1)); done < .harness/files.txt
  echo "  after/'s files: $m · byte for byte the previous tree's: $n · the five above differ: $((m - n))"
  echo "a new customer, as JSON - this unit's line in the anchor's README - before: the previous tree, the README's run line, port 19371:"
  start "$(at .harness/before 19371 "$R_RUN")"; up 19371; ready 19371
  pj 19371 "$ADATA"
  stop 19371 .harness/before
  echo "after - after/, the request-mapping lesson's line - Spring MVC's mapping logger at TRACE, the kitchen at DEBUG - port 19370:"
  start "$(at .harness/after 19370 "$L_SCAN")"; up 19370; ready 19370; reg
  pj 19370 "$ADATA"; ask 19370 /customers/Asha
  stop 19370 .harness/after
  echo "the routing table - after/, mappings exposed for one run (the request-mapping lesson's line), port 19370:"
  start "$(at .harness/after 19370 "$L_EXPO")"; up 19370; ready 19370
  c=$(url "$L_TABLE" 19370); echo "\$ $c"; (eval "$c") 2>&1 < /dev/null
  c=$(url "$L_ROW" 19370); echo "\$ $c"; (eval "$c") 2>&1 < /dev/null
  stop 19370 .harness/after; }
# reg: the run's lines up to Boot's started line - Spring MVC's RequestMappingHandlerMapping lines (each block's routes sorted:
# the order they are found in moves between runs), from the level on
reg() { awk '/ : Tomcat started on port / { exit } { print }' .harness/run.out > .harness/pre.txt
  echo "  Spring MVC's RequestMappingHandlerMapping, its lines before Boot's started line (logger: level, message; a block's routes sorted):"
  awk '
    function flush() { if (nb) { n = 0; for (k in rt) delete rt[k]; for (k = 1; k <= nb; k++) rt[k] = blk[k]
        for (a = 1; a <= nb; a++) for (b = a + 1; b <= nb; b++) if (rt[b] < rt[a]) { t = rt[a]; rt[a] = rt[b]; rt[b] = t }
        for (k = 1; k <= nb; k++) print "        " rt[k]; nb = 0 } }
    / [A-Z]+ [0-9]+ --- \[/ { flush(); in_ = 0
      if (index($0, "RequestMappingHandlerMapping : ")) { s = $0; i = index(s, " --- ["); s = substr(s, i + 6); i = index(s, "] "); s = substr(s, i + 2)
        i = index(s, " : "); lg = substr(s, 1, i - 1); sub(/ +$/, "", lg); msg = substr(s, i + 3); print "    " lg ": " $2 (msg == "" ? "" : " " msg); in_ = 1 }
      next }
    in_ && /^\t[^\t{]/ { flush(); sub(/^\t/, ""); print "      " $0; next }
    in_ && /^\t\{/ { sub(/^\t/, ""); blk[++nb] = $0; next }
    END { flush() }' .harness/pre.txt
  echo "  then Boot's started line - logger: message: $(started .harness/run.out)"; }

# ---- chain: Spring MVC's message converters ---------------------------------------------------------------------------------
chain() { local c
  echo "after/ on the README's class-path line with the harness's Converters joined, port 19372:"
  start "$(hcp .harness/after 19372 probe.web.Converters)"; up 19372; ready 19372
  c=$(bc 19372 /probe/converters); echo "\$ $c"; (eval "$c") 2>&1 < /dev/null | sed 's/^/  /'
  stop 19372 .harness/after; }

# ---- body: one POST at DEBUG; a record the harness counts the constructions of ----------------------------------------------
body() { local c n0 k
  echo "after/, the README's line with Boot's web group at DEBUG (the embedded-Tomcat lesson's), port 19370 - one new customer, this unit's line in the anchor's README:"
  start "$(at .harness/after 19370 "$R_WEB")"; up 19370; ready 19370
  n0=$(mark); c=$(url "$R_ADD" 19370); echo "\$ $c"; (eval "$c") 2>&1 < /dev/null | sed 's/^/  /'; settle
  k=$(dbg "$n0" | grep -c . || true)
  echo "  the lines the log gained for it, Boot's web group at DEBUG (logger: message) - all $k:"; dbg "$n0"
  ask 19370 /customers/Asha
  stop 19370 .harness/after
  echo "a record of the harness's own, Body.Plate, whose compact constructor counts its calls - after/ on the README's class-path line with Body joined, port 19372:"
  start "$(hcp .harness/after 19372 probe.web.Body)"; up 19372; ready 19372
  for b in '{"name":"Ravi","count":2}' '{"name":"Meera","count":1}'; do c=$(pc 19372 /probe/body/plate "$b"); echo "\$ $c"; (eval "$c") 2>&1 < /dev/null | sed 's/^/  /'; done
  stop 19372 .harness/after; }

# ---- misfit: bodies that don't fit the record -----------------------------------------------------------------------------------
misfit() {
  echo "after/, the README's run line, port 19370 - bodies that don't fit the record, each sent as this unit's line sends one (its Content-Type application/json):"
  start "$(at .harness/after 19370 "$R_RUN")"; up 19370; ready 19370
  pj 19370 '{"name":"Kiran","mealsPerDay":2'
  pj 19370 ''
  pj 19370 '[{"name":"Kiran","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}]'
  pj 19370 '{"name":"Kiran","pricePerMeal":110,"mealType":"VEG"}'
  pj 19370 '{"name":"Kiran","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} extra'
  echo "and three that are stored:"
  pj 19370 '{"name":"Kiran","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG","loyaltyPoints":5}'
  pj 19370 '{"name":"Lata","mealsPerDay":"2","pricePerMeal":110,"mealType":"VEG"}'
  pj 19370 "$MOHAN"
  ask 19370 /customers/Mohan
  echo "  WARN lines in this run's log, at Boot's default level: $(logl 0 WARN | grep -c . || true)"
  stop 19370 .harness/after; }
MOHAN='{"name":"Mohan","mealsPerDay":2.7,"pricePerMeal":110,"mealType":"VEG"}'

# ---- unchecked: what nothing checks yet -----------------------------------------------------------------------------------------
unchecked() {
  echo "after/, the README's run line, port 19370 - a body nothing checks yet:"
  start "$(at .harness/after 19370 "$R_RUN")"; up 19370; ready 19370
  pj 19370 '{"name":"","mealsPerDay":0,"pricePerMeal":-5,"mealType":"LUNCH"}'
  ask 19370 /customers
  echo "a misspelt key, then a name that is taken - the database refuses each:"
  p5 19370 '{"name":"Rohan","mealsPerDay":1,"pricePerMeal":110,"mealTyp":"VEG"}'
  p5 19370 '{"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"}'
  ask 19370 /customers/Rohan
  echo "  WARN lines in this run's log, at Boot's default level: $(logl 0 WARN | grep -c . || true) · ERROR lines: $(logl 0 ERROR | grep -c . || true)"
  stop 19370 .harness/after; }

# ---- ctype: A/B/A' - the request's Content-Type -----------------------------------------------------------------------------------
# ctl PORT 'LINE': this unit's README line (A or B), its port made PORT, printed and run; then the WARN lines it added
ctl() { local c n0; n0=$(mark); c=$(url "$2" "$1"); echo "\$ $c"; (eval "$c") 2>&1 < /dev/null | tsmask > .harness/ask.txt; wans "$n0" .harness/ask.txt; }
ctype() {
  echo "A - after/, the README's run line, port 19370 - a new customer, its Content-Type named (this unit's line, the answer's Accept header printed):"
  start "$(at .harness/after 19370 "$R_RUN")"; up 19370; ready 19370; ctl 19370 "$L_A"; stop 19370 .harness/after
  echo "B - the same line without its -H 'Content-Type: application/json', one option out: curl names a form for --data, port 19370:"
  start "$(at .harness/after 19370 "$R_RUN")"; up 19370; ready 19370; ctl 19370 "$L_B"; ask 19370 /customers/Asha; stop 19370 .harness/after
  echo "A' - A again, on a fresh JVM:"
  start "$(at .harness/after 19370 "$R_RUN")"; up 19370; ready 19370; ctl 19370 "$L_A"; stop 19370 .harness/after; }

# ---- jackson: one Jackson left --------------------------------------------------------------------------------------------------
# xcode FILE: an XML file's lines that are not comments (a comment may span lines), blank lines dropped
xcode() { python3 - "$1" <<'PY'
import re, sys
s = re.sub(r"<!--.*?-->", "", open(sys.argv[1]).read(), flags=re.S)
print("\n".join(l for l in s.splitlines() if l.strip()))
PY
}
# pkgs: the classes in each tree's extracted lib/ - every jar read - under five packages, before -> after
pkgs() { python3 - .harness/before/tiffinbox-web/target/extracted/lib .harness/after/tiffinbox-web/target/extracted/lib <<'PY'
import glob, os, sys, zipfile
P = ("com/fasterxml/jackson/databind/", "com/fasterxml/jackson/core/", "com/fasterxml/jackson/annotation/", "tools/jackson/databind/", "tools/jackson/core/")
def count(d):
    n = dict.fromkeys(P, 0)
    for j in sorted(glob.glob(os.path.join(d, "*.jar"))):
        for e in zipfile.ZipFile(j).namelist():
            for p in P:
                if e.startswith(p) and e.endswith(".class"): n[p] += 1
    return n
b, a = count(sys.argv[1]), count(sys.argv[2])
for p in P: print("    %s: %d -> %d" % (p, b[p], a[p]))
PY
}
# imports JAR PACKAGE: the jar manifest's Import-Package entry for PACKAGE (its continuation lines joined)
imports() { python3 - "$1" "$2" <<'PY'
import re, sys, zipfile
m = zipfile.ZipFile(sys.argv[1]).read("META-INF/MANIFEST.MF").decode().replace("\r\n", "\n").replace("\n ", "")
h = next((l for l in m.splitlines() if l.startswith("Import-Package: ")), "")[len("Import-Package: "):]
print(next((x for x in re.findall(r'(?:[^,"]|"[^"]*")+', h) if x.split(";")[0] == sys.argv[2]), "none"))
PY
}
# j2rep: Boot's condition report in the run's log - its entries that name Jackson 2's endpoint mapper (Jackson2EndpointAutoConfiguration,
# its bean, and the Spring MVC configurer that uses it): each entry's name, the section it is in, and its first reason
j2rep() { awk '
  /^Positive matches:$/ { sec = "matched"; next } /^Negative matches:$/ { sec = "did not match"; next } /^(Exclusions|Unconditional classes):$/ { sec = ""; next }
  sec != "" && /^   [A-Za-z]/ { e = $0; sub(/^ +/, "", e); sub(/( matched)?:$/, "", e); want = (index(e, "Jackson2EndpointAutoConfiguration") == 1 || index(e, "endpointJackson2ObjectMapperWebMvcConfigurer")); if (want) { printf "    %s - %s", e, sec; pend = 1 }; next }
  pend && /^ +- / { r = $0; sub(/^ +- /, "", r); print ": " r; pend = 0; next }
  sec != "" && /^   [^ ]/ { want = 0 }' .harness/run.out
  echo "    the report's entries in its two lists: $(awk '/^Positive matches:$/ { s = 1; next } /^Negative matches:$/ { s = 2; next } /^(Exclusions|Unconditional classes):$/ { s = 0 } s && /^   [A-Za-z]/ { n++ } END { print (n > 100 ? "over 100" : n + 0) }' .harness/run.out), the others not shown"
  echo "    entries naming Jackson2, in the report's two lists: matched $(awk '/^Positive matches:$/ { s = 1; next } /^Negative matches:$/ { s = 2; next } /^(Exclusions|Unconditional classes):$/ { s = 0 } s == 1 && /^   [A-Za-z]/ && /Jackson2/ { n++ } END { print n + 0 }' .harness/run.out) · did not match $(awk '/^Positive matches:$/ { s = 1; next } /^Negative matches:$/ { s = 2; next } /^(Exclusions|Unconditional classes):$/ { s = 0 } s == 2 && /^   [A-Za-z]/ && /Jackson2/ { n++ } END { print n + 0 }' .harness/run.out)"; }
jackson() { local f c e
  echo "the two POMs, their lines that are not comments - the previous tree's against after/'s (git's patience diff, -U0, the file names cut):"
  for f in pom.xml tiffinbox-web/pom.xml; do
    xcode ".harness/before/$f" > .harness/xb.txt; xcode ".harness/after/$f" > .harness/xa.txt
    git diff --no-index --no-color --diff-algorithm=patience -U0 .harness/xb.txt .harness/xa.txt | grep -E '^(@@|[-+])' | grep -vE '^(---|\+\+\+) ' > .harness/x.diff || true
    echo "  $f - hunks: $(grep -c '^@@ ' .harness/x.diff || true) · lines out: $(grep -c '^-' .harness/x.diff || true) · in: $(grep -c '^+' .harness/x.diff || true):"
    sed 's/^/    /' .harness/x.diff; done
  libs .harness/before/$JARP > .harness/lb.txt; libs .harness/after/$JARP > .harness/la.txt
  echo "the executable jar's BOOT-INF/lib: $(wc -l < .harness/lb.txt | tr -d ' ') jars -> $(wc -l < .harness/la.txt | tr -d ' ')"
  echo "  removed $(comm -23 .harness/lb.txt .harness/la.txt | wc -l | tr -d ' '): $(comm -23 .harness/lb.txt .harness/la.txt | paste -sd' ' -) · added $(comm -13 .harness/lb.txt .harness/la.txt | wc -l | tr -d ' '): $(comm -13 .harness/lb.txt .harness/la.txt | paste -sd' ' -)"
  echo "  their jars named jackson, after: $(grep -i 'jackson' .harness/la.txt | paste -sd' ' -)"
  echo "  the classes in those jars, by package - every jar of each tree's extracted lib/ read, before -> after:"
  pkgs
  echo "the class path Maven lists for tiffinbox-web - the one the native build reads (this unit's line, offline) - its jars named jackson:"
  for t in before after; do c=$(off ".harness/$t" "$L_MCP"); echo "\$ $c"; mbuild "$c" ".harness/$t.cp.log" "the class path of .harness/$t"
    echo "  $(tr ':' '\n' < ".harness/$t/tiffinbox-web/target/cp.txt" | sed 's#^.*/##' | grep -i 'jackson' | sort | paste -sd' ' -)"; done
  echo "who still reads the annotations - after/'s jackson-databind-3.1.5.jar, its manifest's Import-Package for them: $(imports .harness/after/tiffinbox-web/target/extracted/lib/jackson-databind-3.1.5.jar com.fasterxml.jackson.annotation)"
  echo "which version - Boot's BOM (\$M2/org/springframework/boot/spring-boot-dependencies/4.1.1/spring-boot-dependencies-4.1.1.pom): $(grep -m1 -o '<jackson-2-bom.version>[^<]*</jackson-2-bom.version>' "$BOOTDEPS") - the property the previous tree's pom.xml set: $(grep -m1 -o '<jackson-2-bom.version>[^<]*</jackson-2-bom.version>' .harness/before/pom.xml) · Jackson 3's BOM (\$M2/tools/jackson/jackson-bom/3.1.5/jackson-bom-3.1.5.pom): $(grep -m1 -o '<jackson.version.annotations>[^<]*</jackson.version.annotations>' "$JBOM3")"
  echo "Actuator's Jackson 2 mapper - Boot's condition report (the last course's --debug line) - before: the previous tree, port 19371:"
  start "$(at .harness/before 19371 "$R_DEBUG")"; up 19371; ready 19371; j2rep; stop 19371 .harness/before
  echo "after - after/, port 19370:"
  start "$(at .harness/after 19370 "$R_DEBUG")"; up 19370; ready 19370; j2rep; stop 19370 .harness/after
  echo "the last course's missing-class lines (the anchor's README) - a copy of the extracted jar, then one class out of Jackson 2's jar - from after/'s folder:"
  c="cd .harness/after && $R_HANG1"; echo "\$ $c"; e=0; (eval "$c") > .harness/hang.out 2>&1 < /dev/null || e=$?; echo "  exit $e"
  c="cd .harness/after && $R_HANG2"; echo "\$ $c"; e=0; (eval "$c") > .harness/hang.out 2>&1 < /dev/null || e=$?
  echo "  exit $e · what it printed: $(grep . .harness/hang.out | paste -sd' ' -)"
  echo "C (labelled) - configprops, exposed alone for one run (this unit's line) - before: the previous tree, port 19371:"
  start "$(at .harness/before 19371 "$L_CONF")"; up 19371; ready 19371; c=$(url "$L_CONFQ" 19371); echo "\$ $c"; (eval "$c") 2>&1 < /dev/null | sed 's/^/  /'; stop 19371 .harness/before
  echo "after - after/, port 19370:"
  start "$(at .harness/after 19370 "$L_CONF")"; up 19370; ready 19370; c=$(url "$L_CONFQ" 19370); echo "\$ $c"; (eval "$c") 2>&1 < /dev/null | sed 's/^/  /'; stop 19370 .harness/after; }
BOOTDEPS="$M2/org/springframework/boot/spring-boot-dependencies/4.1.1/spring-boot-dependencies-4.1.1.pom"
JBOM3="$M2/tools/jackson/jackson-bom/3.1.5/jackson-bom-3.1.5.pom"
# ---- exercise: the README's commands, exactly as written, then the solution's - in ONE shell --------------------------------------
block() { awk '/^```bash$/ { if (!d) { f = 1 }; next } f && /^```$/ { f = 0; d = 1 } f' "$1"; }
# The shell a viewer has: env -i - nothing this script set reaches it (its JAVA_HOME, the JDK at the front of its PATH, LC_ALL,
# no_proxy) - with HOME and the PATH you started this script with; /bin/bash without profile or rc files, started in this folder.
# A driver in .harness/ runs the README's block, then SOLUTION.md's, as a viewer pastes them - each with its output, its exit
# code and the folder it left the shell in kept apart (absolute paths: a command that moved the shell must not move these files),
# and the README's run log kept before the solution's run writes its own. Bounded (600 s); on the way out, or past the bound, the
# shell and every process under it are stopped (killtree).
# where DIR: the folder the shell was left in - this unit's folder, a folder under it (named), or elsewhere
where() { case "$1" in "$U") echo "this unit's folder" ;; "$U"/*) echo "${1#"$U"/}" ;; *) echo "outside this unit's folder" ;; esac; }
exercise() { local setup sol i=0 e1 d1 e2 d2
  setup=$(block exercise/README.md); sol=$(block exercise/solution/SOLUTION.md)
  [ -n "$setup" ] && [ -n "$sol" ] || die "exercise/README.md or SOLUTION.md no longer gives its commands"
  [ "$(printf '%s\n' "$sol" | grep -c .)" = 3 ] || die "SOLUTION.md's first bash block must be its two export lines and its one command"
  [ "$(printf '%s\n' "$sol" | sed -n 1,2p)" = "$(printf '%s\n' "$setup" | sed -n 1,2p)" ] || die "SOLUTION.md must start with the README's two export lines (a new shell's java may be another JDK)"
  printf '%s\n' "$sol" | sed -n 1p | grep -qxF 'export JAVA_HOME=/opt/homebrew/opt/openjdk@25' || die "SOLUTION.md's first line must export this script's JAVA_HOME"
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
  echo "  the shell is now in: $(where "$d1") · the copy's own token in its log: $(raw "$(head -1 .harness/mine/after/$TF)" .harness/ex-readme.log) times · WARN lines in its log: $(grep -c ' WARN ' .harness/ex-readme.log || true)"
  echo "the solution's $(printf '%s\n' "$sol" | grep -c .) lines, next, in the same shell:"
  printf '%s\n' "$sol" | sed 's/^/  $ /'
  echo "  exit $e2 · what they printed:"; sed 's/^/    /' .harness/ex-sol.out
  echo "  the shell is now in: $(where "$d2") · the copy's own token in its log: $(raw "$(head -1 .harness/mine/after/$TF)" .harness/mine/run.log) times · WARN lines in its log: $(grep -c ' WARN ' .harness/mine/run.log || true) · listening on 19379 now: $(listeners 19379)"; }

# ---- forms: the native build, what Spring's AOT step registered, then four forms ---------------------------------------------------
nbuild() { local ci cn s0 s1
  ci=$(off "$1" "$R_INSTALL" install); cn=$(off "$1" "$R_NATIVE")
  echo "\$ $ci"; mbuild "$ci" "$1.install.log" "$1 (both modules, into \$M2)"
  echo "\$ $cn"
  NB_E=0; s0=$(date +%s); (eval "$cn") > "$1.native.log" 2>&1 < /dev/null || NB_E=$?; s1=$(date +%s); NB_S=$((s1 - s0))
  echo "  (terminal only) the native build in $1 took $NB_S s" >&3
  if ghub "$1.native.log"; then echo "  offline: no - GraalVM's native plugin went to GitHub for its metadata repository"; die "the native build in $1: GraalVM's native plugin went over the network - README.md, The repository"; fi; }
nlines() {
  echo "  its lines, in order (the rest - $(grep -cvE '^\[INFO\] --- |^\[INFO\] Found GraalVM|^ - Java version: |^Warning: |^\[[1-8]/8\] |^\[INFO\] BUILD |^The build process encountered ' "$1" || true) lines - not shown):"
  grep -E '^\[INFO\] --- .* @ tiffinbox-web ---$|^\[INFO\] Found GraalVM installation from ' "$1" | sed 's/^\[INFO\] /    /'
  grep -E '^ - Java version: ' "$1" | sed 's/^ - /    /'
  grep -E '^Warning: ' "$1" | sed -E "s/ in '(file:[^']*|null)'/ in '…'/" | sed 's/^/    /'
  grep -E '^\[[1-8]/8\] ' "$1" | sed 's/\.\.\..*$/.../' | sed 's/^/    /'
  grep -E '^The build process encountered |^\[INFO\] BUILD ' "$1" | sed 's/^\[INFO\] //' | sed 's/^/    /'; }
nresult() { echo "  exit $NB_E · $(grep -m1 -oE 'BUILD (SUCCESS|FAILURE)' "$1" || echo 'no BUILD line') · stages it printed: $(grep -cE '^\[[1-8]/8\] ' "$1" || true) of the $(grep -m1 -oE '^\[1/[0-9]+\]' "$1" | sed 's/.*\///; s/]//') it announces · its duration, against the bound: $( [ $NB_S -lt 1200 ] && echo 'under 20 minutes' || echo '20 minutes or more' ) · its lines that say the metadata repository was downloaded over http, or failed to: $(grep -cE 'Downloaded GraalVM reachability metadata repository from http|Failed to download from http' "$1" || true) · offline: yes"; }
# aotmeta DIR: Spring's generated reachability metadata in DIR's web module (its AOT step's own file) - the entries for the record
# the routes return and the enum a route's parameter is: what each registers
AOTF=tiffinbox-web/target/spring-aot/main/resources/META-INF/native-image/com.tiffinbox/tiffinbox-web/reachability-metadata.json
aotmeta() { python3 - "$1/$AOTF" <<'PY'
import json, sys
d = json.load(open(sys.argv[1])); refl = d.get("reflection", [])
def what(e):
    k = [x for x in ("allDeclaredFields", "allDeclaredConstructors") if e.get(x)]
    return " · ".join(["all declared fields" if x == "allDeclaredFields" else "all declared constructors" for x in k] + ["%d methods (%s)" % (len(e.get("methods", [])), " ".join(sorted(m["name"] for m in e.get("methods", []))))])
for t in ("com.tiffinbox.Customer", "com.tiffinbox.MealType"):
    c = [e for e in refl if e.get("type") == t]
    print("  Spring's generated metadata (%s): reflection entries naming %s: %d%s" % (sys.argv[1].split("/target/", 1)[1], t, len(c), (" - " + what(c[0])) if c else ""))
PY
}
# lbk LABEL: a form's loopback, read off its own block of this capture so far - every "listens on:" line of the block says
# "loopback only: yes" (the image: published on 127.0.0.1 alone, docker port, both runs)
lbk() { awk -v a="$1" 'index($0, a) == 1 { f = 1; next } /^[1-4] the / { f = 0 } f' .harness/cap.raw > .harness/blk.txt
  if [ "$1" = '4 the image' ]; then [ "$(grep -c '^  docker port: ' .harness/blk.txt)" = 2 ] && [ "$(grep -cE '^  docker port: 18425/tcp -> 127\.0\.0\.1:19377$' .harness/blk.txt)" = 2 ] && echo yes || echo no
  else [ "$(grep -c '^  listens on: ' .harness/blk.txt)" -gt 0 ] && [ "$(grep -c '^  listens on: ' .harness/blk.txt)" = "$(grep -cE '^  listens on: 127\.0\.0\.1:[0-9]+ · loopback only: yes$' .harness/blk.txt)" ] && echo yes || echo no; fi; }
# blines LOG: docker build's output through its filter - the metadata line, the FROM line, the naming line (each without its step
# number and timing), how many lines say pull, and the lines not shown, bounded. BuildKit writes a step's end as " done", or as
# " 0.0s done" when the step took measurable time: both are cut.
blines() { local s
  s=$(grep -E '^#[0-9]+ \[internal\] load metadata for |^#[0-9]+ \[[a-z0-9-]+ 1/[0-9]+\] FROM |^#[0-9]+ naming to ' "$1" | sed -E 's/^#[0-9]+ //; s/( [0-9]+\.[0-9]+s)? done$//' | awk '!seen[$0]++')
  printf '%s\n' "$s" | sed 's/^/    /'
  echo "  its lines that say pull: $(grep -ci 'pull' "$1" || true) · its other lines: $( [ "$(wc -l < "$1" | tr -d ' ')" -lt 300 ] && echo 'fewer than 300' || echo '300 or more'), not shown"; }
# The filter, checked on a planted log before any capture: three naming lines - without a timing, with 0.0s, with 0.1s - must come
# out as one line, the image's name alone.
printf '%s\n' '#14 naming to docker.io/library/planted:1 done' '#14 naming to docker.io/library/planted:1 0.0s done' '#15 naming to docker.io/library/planted:1 0.1s done' > .harness/planted-dbuild.log
PL=$(blines .harness/planted-dbuild.log)
[ "$(printf '%s\n' "$PL" | grep -c 'naming to')" = 1 ] && printf '%s\n' "$PL" | grep -qxF '    naming to docker.io/library/planted:1' || die "blines: a timing survives the filter (the planted log .harness/planted-dbuild.log)"
rm -f .harness/planted-dbuild.log
# inside NAME: the sockets a container listens on, read inside it (/proc/net/tcp and tcp6, state 0A) - address and port
inside() { docker exec "$1" cat /proc/net/tcp /proc/net/tcp6 2> /dev/null | awk '
  function hex(x,  i, v) { v = 0; for (i = 1; i <= length(x); i++) v = v * 16 + index("0123456789ABCDEF", toupper(substr(x, i, 1))) - 1; return v }
  $4 == "0A" { split($2, a, ":"); p = hex(a[2]); h = a[1]
    if (h == "00000000000000000000000000000000") ad = "[::]"; else if (h == "00000000") ad = "0.0.0.0"; else if (h == "0100007F") ad = "127.0.0.1"; else if (h == "00000000000000000000000001000000") ad = "[::1]"; else ad = "another address"
    print ad ":" p }' | sort -u | paste -sd' ' -; }
dstart() { local ec=0; echo "\$ $1"; (eval "$1") > .harness/d.out 2> .harness/d.err < /dev/null || ec=$?
  [ $ec = 0 ] || { cat .harness/d.err >&3; die "docker run failed: exit $ec"; }; }
# dgone NAME: the container polled until it is not running (60 s) - then docker wait, printed
dgone() { local i=0 e
  while [ "$(docker inspect -f '{{.State.Running}}' "$1" 2> /dev/null)" = true ] && [ $i -lt 240 ]; do sleep 0.25; i=$((i + 1)); done
  [ "$(docker inspect -f '{{.State.Running}}' "$1" 2> /dev/null)" != true ] || die "the container $1 still ran after 60 s"
  echo "\$ docker wait $1"; e=$(docker wait "$1"); echo "  $e"; LASTE=$e; }
# dlog NAME: the container's log (docker logs, both streams) into .harness/run.out, the token and its header's name counted (0)
dlog() { local t h; docker logs "$1" > .harness/run.out 2>&1 || true; : > .harness/run.err
  t=$(raw "$TOKEN" .harness/run.out); h=$(LC_ALL=C grep -aoi -- 'x-shutdown-token' .harness/run.out | wc -l | tr -d ' ')
  CLOGS=$((CLOGS + 1)); [ "$t" = 0 ] && [ "$h" = 0 ] || die "a container's log held the demo token ($t) or its header's name ($h)"; }
# dbind PORT: where the container listens - inside it, on this Mac (by port, the address alone), and what docker port says
dbind() { echo "  inside the container, listening: $(inside "$BOX")"
  echo "  docker port: $(docker port "$BOX" | paste -sd' ' -)"
  echo "  on this Mac, listening on port $1: $(lsof -nP -iTCP:"$1" -sTCP:LISTEN 2> /dev/null | awk 'NR > 1 { print $9 }' | sort -u | paste -sd' ' -)"; }
# imgtok: the image saved (docker save, into .harness/ - deleted at once): every blob read whole, a gzip one unpacked first, and the
# demo token counted in all of them - an image is searched as the binary is (R.61); .dockerignore keeps secrets/ out of the context
imgtok() { docker save "$IMG" > .harness/img.tar || die "docker save $IMG failed"
  python3 - .harness/img.tar "$TOKEN" <<'PY2'
import gzip, json, sys, tarfile
t = tarfile.open(sys.argv[1]); tok = sys.argv[2].encode(); n = 0; hits = 0
lay = json.load(t.extractfile("manifest.json"))[0]["Layers"]
for m in t.getmembers():
    if not m.isfile() or not m.name.startswith("blobs/"): continue
    b = t.extractfile(m).read(); n += 1
    if b[:2] == b"\x1f\x8b": b = gzip.decompress(b)
    hits += b.count(tok)
print("  the image saved (docker save): %d blobs, its %d layers among them, each read whole (gzip ones unpacked) · the demo token in them: %d" % (n, len(lay), hits))
PY2
  rm -f .harness/img.tar; }
image() { local c ec=0
  c=$(dbuild .harness/after); echo "\$ $c"
  (eval "$c") > .harness/dbuild.log 2>&1 < /dev/null || ec=$?
  [ $ec = 0 ] || { tail -20 .harness/dbuild.log >&3; die "docker build failed"; }
  docker image inspect -f '{{.Id}}' "$IMG" >> .harness/imgids
  echo "  exit $ec · its lines, through the filter:"; blines .harness/dbuild.log
  imgtok; }
# routes PORT: the new route, asked of a form - a new customer (this unit's line in the anchor's README), read back by the binding
# lesson's line; the same body with no Content-Type (B's line); two point seven meals - each answer printed (the timestamp masked)
rq() { local c; c=$(bc "$@"); echo "\$ $c"; (eval "$c") 2>&1 < /dev/null | tsmask | sed 's/^/  /'; }
rp() { echo "\$ $1"; (eval "$1") 2>&1 < /dev/null | tsmask | sed 's/^/  /'; }
routes() {
  rp "$(url "$R_ADD" "$1")"; rq "$1" /customers/Asha; rp "$(url "$L_B" "$1")"; rp "$(pc "$1" /customers "$MOHAN")"; rq "$1" /customers/Mohan; }
dseven() { echo "\$ \$CURLSET $1 .harness/after/$TF"
  "$CURLSET" "$1" ".harness/after/$TF" | grep ' -> ' > .harness/responses.txt || true
  tsmask < .harness/responses.txt > .harness/responses.m.txt
  grep '^POST ' .harness/responses.m.txt | sed 's/^/  /' || echo "  (no POST line)"
  dgone "$BOX"; [ "$(listeners "$1")" = 0 ] || die "something still listens on $1"
  echo "  exit $LASTE · the seven responses: $(wc -l < .harness/responses.m.txt | tr -d ' ') lines · lines the timestamp mask changed: $(diff .harness/responses.txt .harness/responses.m.txt | grep -c '^<' || true) · md5 $(md5 -q .harness/responses.m.txt)"
  dlog "$BOX"; echo "  its log (docker logs): Boot's first line: $(first .harness/run.out) · the demo token 0 times · X-Shutdown-Token 0 times"
  docker rm "$BOX" > /dev/null; }
forms() {
  echo "the native build - after/ copied to .harness/nat with a config tree; the README's two Maven lines, offline; \$GRAALVM_HOME names the GraalVM:"
  copy after .harness/nat
  nbuild .harness/nat; nlines .harness/nat.native.log; nresult .harness/nat.native.log
  echo "  file: $(file -b ".harness/nat/$BIN" | sed 's/ [A-Za-z0-9_]*$//') · the demo token in its bytes: $(raw "$TOKEN" ".harness/nat/$BIN")"
  echo "what Spring's AOT step registered for the native build - the record a route reads and the routes return, and the enum a route's parameter is:"
  aotmeta .harness/nat
  echo "1 the jar - .harness/after, the README's run line, port 19370:"
  start "$(at .harness/after 19370 "$R_RUN")"; up 19370; ready 19370; tline; seven 19370 .harness/after
  echo "  then the new route, on a second start of the jar:"
  start "$(at .harness/after 19370 "$R_RUN")"; up 19370; ready 19370; routes 19370; stop 19370 .harness/after
  echo "2 the AOT jar - .harness/nat (the profile native's jar), the README's AOT line, port 19374:"
  start "$(at .harness/nat 19374 "$R_AOTRUN")"; up 19374; ready 19374; tline; seven 19374 .harness/nat
  echo "  then the new route, on a second start of the AOT jar:"
  start "$(at .harness/nat 19374 "$R_AOTRUN")"; up 19374; ready 19374; routes 19374; stop 19374 .harness/nat
  echo "3 the binary - .harness/nat, the README's line, port 19378:"
  start "$(at .harness/nat 19378 "$R_BIN")"; up 19378; ready 19378; tline; seven 19378 .harness/nat
  echo "  then the new route, on a second start of the binary:"
  start "$(at .harness/nat 19378 "$R_BIN")"; up 19378; ready 19378; routes 19378; stop 19378 .harness/nat
  echo "4 the image - after/'s Dockerfile (the README's build line, this script's tag), the README's run line with your user, published on 127.0.0.1:19377:"
  image
  dstart "$(drun .harness/after 19377)"; ready 19377 "$BOX"; dbind 19377
  dseven 19377
  echo "  then the new route, on a second container of the image:"
  dstart "$(drun .harness/after 19377)"; ready 19377 "$BOX"; dbind 19377
  routes 19377
  post 19377 .harness/after; dgone "$BOX"; [ "$(listeners 19377)" = 0 ] || die "something still listens on 19377"
  dlog "$BOX"; echo "  exit $LASTE · its log (docker logs): the demo token 0 times · X-Shutdown-Token 0 times"
  docker rm "$BOX" > /dev/null
  echo "four forms, one tree: the seven (masked) $(grep -cE '^  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 2 · md5 87ca7efc8584dcccd40e6b956db1de9b$' .harness/cap.raw) of 4 times 87ca7efc8584dcccd40e6b956db1de9b · the new customer's record (POSTed, then read back) $(grep -cxF '  {"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 200' .harness/cap.raw) of 8 · no Content-Type 415 $(grep -cxF '  {"timestamp":"…","status":415,"error":"Unsupported Media Type","path":"/customers"} 415 · Accept: [application/json, application/*+json]' .harness/cap.raw) of 4 · two point seven meals stored as 2 $(grep -cxF '  {"name":"Mohan","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 200' .harness/cap.raw) of 8 (POSTed, then read back)"
  echo "  loopback, form by form: the jar $(lbk '1 the jar') · the AOT jar $(lbk '2 the AOT jar') · the binary $(lbk '3 the binary') · the image, published on 127.0.0.1 alone $(lbk '4 the image')"; }


cap change change
cap chain chain
cap body body
cap misfit misfit
cap unchecked unchecked
cap ctype ctype
cap jackson jackson
# Without a GraalVM the run stops here, the exercise's capture made first (it needs none): .m2-demo is filled, and every capture
# so far matched receipts.md5 - or cap() would have stopped the run.
cap exercise exercise
[ $GOK = yes ] || die "GRAALVM_HOME is not set: .m2-demo is filled, and the captures that need no GraalVM matched receipts.md5, the exercise's included; the native build needs a GraalVM JDK 25 - README.md, The GraalVM"
cap forms forms
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
# THE TOKEN: no capture holds it, raw - counted on each run's own output BEFORE masking - and neither does any log (each counted
# when it was read: logtok(), dlog()), anything this unit ships for reading, nor the binary this run built
for f in .harness/raw-*; do [ "$(cat "$f")" = "0" ] || die "a capture's raw output held the token ($f: $(cat "$f"))"; done
NBIN=0
for f in .r-*.out README.md exercise/README.md exercise/solution/SOLUTION.md receipts.md5 harness/shutdown.sh harness/table.py harness/probe/web/*.java .harness/nat/$BIN; do
  [ -f "$f" ] || continue; case $f in .harness/nat*) NBIN=$((NBIN + 1)) ;; esac
  [ "$(raw "$TOKEN" "$f")" = 0 ] || die "$f holds the demo token, raw"; done
[ "$NBIN" = 1 ] || die "one binary was built, $NBIN were checked"
for f in .r-*.out; do ! grep -qE '/Users/|/private/|/home/|/var/folders/' "$f" || die "$f holds an absolute path"; [ -z "${GRAALVM_HOME:-}" ] || ! grep -qF "$GRAALVM_HOME" "$f" || die "$f holds the GraalVM's folder"; ! grep -qE 'c[0-9]-unit[0-9]|unit ?[0-9]' "$f" || die "$f holds a unit number"; ! grep -qE ' (with PID|started by) ' "$f" || die "$f holds Boot's process line"; ! grep -qE '^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T|"timestamp":"?[0-9]|timestamp=[A-Z0-9]|(exec|handler|task|utility)-[0-9]' "$f" || die "$f holds a log line's time, a timestamp or a thread's number"; ! grep -q "^$(printf '\t')at " "$f" || die "$f shows a stack frame"; ! grep -qE 'sha256:[0-9a-f]{64}' "$f" || [ "$(grep -cE 'sha256:[0-9a-f]{64}' "$f")" = "$(grep -cE 'eclipse-temurin(:25-jre)?@sha256:[0-9a-f]{64}' "$f")" ] || die "$f holds an ID other than the base image's digest"; ! grep -qE ':8080([^0-9]|$)' "$f" || die "$f shows a bind on 8080"; ! grep -q $'\r' "$f" || die "$f holds a carriage return"; done
for f in receipts.sh README.md exercise/README.md exercise/solution/SOLUTION.md harness/shutdown.sh; do [ -f "$f" ] || continue; ! grep -qE "exposure\.include='?\*" "$f" || die "$f exposes every endpoint (R.42)"; ! grep -E 'server\.error\.' "$f" | grep -vE '^ *#' > /dev/null || die "$f names one of Boot 3's error keys (server, then error) - Boot 4.1 reads only spring.web.error.* (S2.13)"; done
for f in receipts.sh README.md exercise/README.md exercise/solution/SOLUTION.md; do [ -f "$f" ] || continue; ! grep -E 'docker run ' "$f" | grep -vE '^#' | grep -E ' -p "?[0-9]+:' > /dev/null || die "$f publishes a port on every address (-p without 127.0.0.1:)"; done
NL=$(cat .r-*.out | grep -cE "^  its log: the demo token 0 times · X-Shutdown-Token [0-9]+ times\$" || true)
echo "  tokens: 0 raw copies in $(ls .harness/raw-* | wc -l | tr -d ' ') raw capture runs, in $(ls .r-*.out | wc -l | tr -d ' ') captures; the demo token 0 in the logs of every JVM that served ($LOGS here; the published captures' $NL) and every container ($CLOGS here), the image's layers (forms), the READMEs, the harness, the exercise, receipts.md5 and the binary; no absolute path, no GraalVM folder, no unit number, no process line, no log time, no timestamp, no thread number, no stack frame, no ID but the base image's digest, no 8080, no carriage return in any capture; every docker run publishes on 127.0.0.1 only"

S87C='87ca7efc8584dcccd40e6b956db1de9b'
SEVEN1="  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 2 · md5 $S87C"
STOPPED() { printf '  exit 0 · listening on %s now: 0\n' "$1"; }
SHUT='  POST /shutdown -> 200 application/json · Content-Length: 17 · {"stopping":true} · curl exit 0'
RES="    WARN .w.s.m.s.DefaultHandlerExceptionResolver: Resolved [org.springframework."
ASHA='  {"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 200'
E4XX() { printf '  {"timestamp":"…","status":%s,"error":"%s","path":"%s"} %s' "$1" "$2" "$3" "$1"; }
WA() { printf '%s · WARN lines it added: %s' "$1" "$2"; }
# PQ PORT 'BODY': the POST line pc() prints for that body, as the capture shows it ($ first)
PQ() { printf '$ %s' "$(pc "$1" /customers "$2")"; }
BQ() { printf "\$ curl -s -w ' %%{http_code}\\\\n' http://127.0.0.1:%s%s" "$1" "$2"; }
[ "$(PQ 19370 "$ADATA")" = "\$ $(url "$R_ADD" 19370)" ] && [ "$(BQ 19370 /customers/Asha)" = "\$ $(bc 19370 /customers/Asha)" ] || die "the checks' own command lines are not the README's"
NR400="${RES}http.converter.HttpMessageNotReadableException: "

# "a POST to slash customers gets four oh five, method not allowed. No route takes a POST there. ... Two hundred, and the record
#  comes back." - and the change itself: one route, one repository method, Jackson 2's two lines out
CB=$(blk change 'a new customer, as JSON' 'after - '); CA=$(blk change 'after - ' 'the routing table'); CT=$(blk change 'the routing table' '')
x change '^  built the previous tree · offline: yes · exit 0$'; x change '^  built after/ · offline: yes · exit 0$'
[ "$(n change '^  Files ')" = 5 ] && [ "$(n change '^  Only in ')" = 0 ] || die "change: five files differ, none added or deleted"
for f in README.md pom.xml tiffinbox-core/src/main/java/com/tiffinbox/CustomerRepository.java tiffinbox-web/pom.xml tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java; do x change "^  Files \.harness/before/$f and \.harness/after/$f differ\$"; done
x change '^  TiffinBoxServer\.java: 197 -> 215$'; x change '^  CustomerRepository\.java: 64 -> 80$'
x change '^  TiffinBoxServer\.java, its lines that are neither comment nor blank: [0-9]+ -> [0-9]+, of them - imports left out - naming a request body \(@RequestBody\): 0 -> 1 · a route \(@GetMapping, @PostMapping\): 6 -> 7$'
for l in '    +    @PostMapping("/customers")' '    +    Customer add(@RequestBody Customer customer) throws Exception {' '    +        repo.add(customer);' '    +        return customer;' '    +    public void add(Customer customer) throws SQLException {' '    +                 "INSERT INTO customer (name, meals_per_day, price_per_meal, meal_type) VALUES (?, ?, ?, ?)")) {' '    +            ps.executeUpdate();'; do
  grep -qxF -- "$l" .r-change.out || die "change: the hunk line $l"; done
x change "^  its code lines' diff \(diff -U0 of the lines above, its file names cut\) - hunks: 2 · lines out: 0 · in: 6 - whole:\$"
x change "^  CustomerRepository\.java, its code lines: 53 -> 64 - its code lines' diff, the same way - hunks: 1 · lines out: 0 · in: 11 - whole:\$"
x change '^the executable jar.s BOOT-INF/lib: 58 jars -> 56 · removed 3 · added 1 - by name in jackson$'
x change "^  after/'s files: 25 · byte for byte the previous tree's: 20 · the five above differ: 5\$"
[ "$(aft "$(PQ 19371 "$ADATA")" "$CB")" = "$(WA "$(E4XX 405 'Method Not Allowed' /customers)" 1)" ] || die "change before: the POST is Spring's 405"
has "$CB" "${RES}web.HttpRequestMethodNotSupportedException: Request method 'POST' is not supported]" "change before: its WARN line"
[ "$(aft "$(PQ 19370 "$ADATA")" "$CA")" = "$(WA "$ASHA" 0)" ] && [ "$(aft "$(BQ 19370 /customers/Asha)" "$CA")" = "$(WA "$ASHA" 0)" ] || die "change after: 200 and the record, read back by name"
# "Spring registers seven of TiffinBox's routes now, nine mappings in all, and the new one names no media type"
has "$CA" '      c.t.w.TiffinBoxServer:' "change: TiffinBox's block at TRACE"
for r in '{GET [/customers/{name}]}: customer(String)' '{GET [/customers]}: customers(MealType)' '{GET [/dashboard]}: dashboard()' '{GET [/kitchen]}: kitchen()' '{GET [/revenue]}: revenue()' '{POST [/customers]}: add(Customer)' '{POST [/shutdown]}: shutdown(String,HttpServletResponse)'; do has "$CA" "        $r" "change: $r"; done
[ "$(printf '%s\n' "$CA" | grep -cE '^        \{(GET|POST) \[/[a-z/{}]+\]\}: [a-z]+\(')" = 7 ] && [ "$(printf '%s\n' "$CA" | grep -cE '^        \{ \[/error\]')" = 2 ] || die "change: seven of TiffinBox's, two of Boot's"
has "$CA" "    s.w.s.m.m.a.RequestMappingHandlerMapping: DEBUG 9 mappings in 'requestMappingHandlerMapping'" "change: nine mappings"
printf '%s\n' "$CT" | grep -qE '^  dispatcherServlets · dispatcherServlet: 16 rows, ' || die "change: sixteen rows"
has "$CT" "  TiffinBox's rows (its own handler, or a TiffinBoxServer method): 7 · naming a verb: 7 (GET 5 POST 2)" "change: TiffinBox's seven rows"
has "$CT" '    7  {POST [/customers]} -> TiffinBoxServer#add(Customer)' "change: the new row"
has "$CT" '  the row for /customers: 2' "change: two rows for /customers"
[ "$(printf '%s\n' "$CT" | grep -cxF '    details.requestMappingConditions.consumes = []')" = 2 ] && has "$CT" '    details.requestMappingConditions.methods = ["POST"]' "change: POST" || die "change: the new route names no media type (consumes = [])"
echo "  change: 5 files; 197 -> 215 and 64 -> 80; @RequestBody 0 -> 1, routes 6 -> 7, no code line out; lib 58 -> 56; 20 of 25 files the same; before the POST 405 + WARN; after 200 and the record, read back; 7 + 2 = 9 mappings; 16 rows, TiffinBox's 7; consumes = []"

# "Here its adapter holds six, and asks them in order which can read a Customer from the body's media type. For JSON, only the sixth
#  says yes, Jackson's, and it writes one too. For a form, or plain text, none does."
CN=$(cat .r-chain.out)
has "$CN" "  message converters: 6 - RequestMappingHandlerAdapter's, in the order it asks them" "chain: six"
[ "$(printf '%s\n' "$CN" | grep -cE '^    [1-6] [A-Za-z]+HttpMessageConverter \[')" = 6 ] || die "chain: six listed"
has "$CN" '    6 JacksonJsonHttpMessageConverter [application/json, application/*+json]' "chain: the sixth, Jackson's"
has "$CN" '    application/json: 1 of 6 - 6 JacksonJsonHttpMessageConverter (read yes, write yes)' "chain: only the sixth, read and write"
has "$CN" '    application/x-www-form-urlencoded: 0 of 6' "chain: a form, none"; has "$CN" '    text/plain: 0 of 6' "chain: plain text, none"
has "$CN" "  the JSON converter's mapper (6 JacksonJsonHttpMessageConverter): tools.jackson.databind.json.JsonMapper · Boot's bean jacksonJsonMapper itself: yes" "chain: Boot's JsonMapper"
# "An unknown property is ignored: Core Java II's Jackson refused one, while Jackson three ignores it, in Boot's mapper ... and in a plain one."
has "$CN" '  FAIL_ON_UNKNOWN_PROPERTIES - Boot'"'"'s mapper: false · a plain JsonMapper (JsonMapper.builder().build()): false' "chain: unknown properties allowed, both mappers"
echo "  chain: 6 converters; for a Customer only the sixth (JacksonJsonHttpMessageConverter) reads and writes, for application/json; a form and text/plain 0 of 6; its mapper Boot's jacksonJsonMapper; unknown properties allowed in Boot's mapper and a plain one"

# "At debug level ... Spring logs what it read: the body as a Customer, every value in the line ... A harness record counts the calls:
#  one per body."
BD=$(blk body 'after/, the README' 'a record of the harness'); BP=$(blk body 'a record of the harness' '')
printf '%s\n' "$BD" | grep -q -- ' --logging\.level\.web=debug$' || die "body: Boot's web group at DEBUG"
[ "$(aft "\$ $(url "$R_ADD" 19370)" "$BD")" = "$ASHA" ] || die "body: 200 and the record"
has "$BD" "  the lines the log gained for it, Boot's web group at DEBUG (logger: message) - all 6:" "body: six lines, all shown"
has "$BD" '    m.m.a.RequestResponseBodyMethodProcessor: Read "application/json;charset=UTF-8" to [Customer[name=Asha, mealsPerDay=2, pricePerMeal=110, mealType=VEG]]' "body: the body it read, every value"
has "$BD" '    m.m.a.RequestResponseBodyMethodProcessor: Writing [Customer[name=Asha, mealsPerDay=2, pricePerMeal=110, mealType=VEG]]' "body: the record it wrote"
has "$BD" '    s.w.s.m.m.a.RequestMappingHandlerMapping: Mapped to com.tiffinbox.web.TiffinBoxServer#add(Customer)' "body: mapped to add"
has "$BD" '    o.s.web.servlet.DispatcherServlet: Completed 200 OK' "body: completed 200"
[ "$(aft "$(BQ 19370 /customers/Asha)" "$BD")" = "$(WA "$ASHA" 0)" ] || die "body: read back"
has "$BP" '  Plate[name=Ravi, count=2] · canonical constructor calls so far: 1 200' "body: one call for the first body"
has "$BP" '  Plate[name=Meera, count=1] · canonical constructor calls so far: 2 200' "body: one more for the second"
echo "  body: at DEBUG 6 lines, Read ... to [Customer[...]] and Writing [Customer[...]]; read back 200; the harness's record: canonical constructor calls 1, then 2"

# "Broken JSON, an empty body, an array, a missing meal count, text after the closing brace: each is a four hundred, and the reason is
#  only in one warning line, never in the answer. Three slip in without a word. ... A number sent as text is read as a number. And two
#  point seven meals a day is stored as two."
MF=$(cat .r-misfit.out); E4=$(E4XX 400 'Bad Request' /customers)
for b in '{"name":"Kiran","mealsPerDay":2' '' '[{"name":"Kiran","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}]' '{"name":"Kiran","pricePerMeal":110,"mealType":"VEG"}' '{"name":"Kiran","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} extra'; do
  [ "$(aft "$(PQ 19370 "$b")" "$MF")" = "$(WA "$E4" 1)" ] || die "misfit: $b - a 400 and one WARN line"; done
for w in "JSON parse error: Unexpected end-of-input: expected close marker for Object" "Required request body is missing: com.tiffinbox.Customer com.tiffinbox.web.TiffinBoxServer.add(com.tiffinbox.Customer)" "JSON parse error: Cannot deserialize value of type \`com.tiffinbox.Customer\` from Array value" "JSON parse error: Cannot map \`null\` into type \`int\` (set \`DeserializationFeature.FAIL_ON_NULL_FOR_PRIMITIVES\` to 'false' to allow)" "JSON parse error: Unrecognized token 'extra'"; do
  printf '%s\n' "$MF" | grep -qF -- "$NR400$w" || die "misfit: the WARN line's reason: $w"; done
[ "$(printf '%s\n' "$MF" | grep -c '"status":400' || true)" = 5 ] || die "misfit: five 400s"
[ "$(aft "$(PQ 19370 '{"name":"Kiran","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG","loyaltyPoints":5}')" "$MF")" = "$(WA '  {"name":"Kiran","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 200' 0)" ] || die "misfit: the unknown property ignored, no WARN"
[ "$(aft "$(PQ 19370 '{"name":"Lata","mealsPerDay":"2","pricePerMeal":110,"mealType":"VEG"}')" "$MF")" = "$(WA '  {"name":"Lata","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 200' 0)" ] || die "misfit: a number as text, read"
[ "$(aft "$(PQ 19370 "$MOHAN")" "$MF")" = "$(WA '  {"name":"Mohan","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 200' 0)" ] && [ "$(aft "$(BQ 19370 /customers/Mohan)" "$MF")" = "$(WA '  {"name":"Mohan","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 200' 0)" ] || die "misfit: 2.7 stored as 2, no WARN"
[ "$(printf '%s\n' "$MF" | grep -c ' 200 · WARN lines it added: 0$' || true)" = 4 ] || die "misfit: three stored, and one read back"
has "$MF" "  WARN lines in this run's log, at Boot's default level: 5" "misfit: five WARN lines in all, one per 400"
echo "  misfit: malformed, empty, an array, a missing int, trailing text -> 400 + 1 WARN each (Jackson's reason in Spring's line); an unknown property, \"2\", 2.7 -> 200, 0 WARN; 2.7 stored as 2"

# "An empty name, zero meals, a price of minus five and a meal type nobody serves: two hundred, stored, and listed first. A misspelt key
#  ... only the database refuses it: a five hundred, and a stack trace of over fifty frames. A name that's taken gets the same."
UC=$(cat .r-unchecked.out)
[ "$(aft "$(PQ 19370 '{"name":"","mealsPerDay":0,"pricePerMeal":-5,"mealType":"LUNCH"}')" "$UC")" = "$(WA '  {"name":"","mealsPerDay":0,"pricePerMeal":-5,"mealType":"LUNCH"} 200' 0)" ] || die "unchecked: stored, 200"
aft "$(BQ 19370 /customers)" "$UC" | grep -q '^  \[{"name":"","mealsPerDay":0,"pricePerMeal":-5,"mealType":"LUNCH"},{"name":"Meera"' || die "unchecked: listed first"
[ "$(aft "$(BQ 19370 /customers)" "$UC" | grep -o '"name":' | wc -l | tr -d ' ')" = 5 ] || die "unchecked: five customers listed"
for b in '{"name":"Rohan","mealsPerDay":1,"pricePerMeal":110,"mealTyp":"VEG"}' '{"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"}'; do
  [ "$(aft "$(PQ 19370 "$b")" "$UC")" = "$(E4XX 500 'Internal Server Error' /customers)" ] || die "unchecked: $b - a 500"; done
has "$UC" '    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: Servlet.service() for servlet [dispatcherServlet] in context with path [] threw exception [Request processing failed: org.h2.jdbc.JdbcSQLIntegrityConstraintViolationException: NULL not allowed for column "MEAL_TYPE"; SQL statement:' "unchecked: H2's NULL refusal, in Tomcat's ERROR line"
has "$UC" '      INSERT INTO customer (name, meals_per_day, price_per_meal, meal_type) VALUES (?, ?, ?, ?) [23502-250]] with root cause' "unchecked: 23502"
has "$UC" '    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: Servlet.service() for servlet [dispatcherServlet] in context with path [] threw exception [Request processing failed: org.h2.jdbc.JdbcSQLIntegrityConstraintViolationException: Unique index or primary key violation: "…"; SQL statement:' "unchecked: H2's unique refusal, the same class"
has "$UC" '      INSERT INTO customer (name, meals_per_day, price_per_meal, meal_type) VALUES (?, ?, ?, ?) [23505-250]] with root cause' "unchecked: 23505"
[ "$(printf '%s\n' "$UC" | grep -cE '^    its stack frames: over 50, its other lines: [0-9]+ - none shown · WARN lines it added: 0$')" = 2 ] || die "unchecked: two traces of over 50 frames, no WARN"
[ "$(aft "$(BQ 19370 /customers/Rohan)" "$UC")" = "$(WA "$(E4XX 404 'Not Found' /customers/Rohan)" 0)" ] || die "unchecked: the misspelt one not stored"
has "$UC" "  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 2" "unchecked: 0 WARN, 2 ERROR"
echo "  unchecked: an empty name, 0 meals, -5, LUNCH -> 200, stored, listed first; the misspelt key -> 500, H2's NULL (23502) in Tomcat's ERROR line; a taken name -> 500 (23505); traces over 50 frames; 0 WARN"

# "A: the README's POST names JSON: two hundred. B: the same line without that header, one option out. Curl then calls the body a form,
#  and Spring answers four fifteen, unsupported media type, with an Accept header listing what it would read: JSON. Nothing is stored.
#  A again: two hundred."
KA=$(blk ctype 'A - after/' 'B - the same'); KB=$(blk ctype 'B - the same' "A' - A again"); KA2=$(blk ctype "A' - A again" '')
for b in "$KA" "$KA2"; do [ "$(aft "\$ $(url "$L_A" 19370)" "$b")" = "$(WA "${ASHA} · Accept: []" 0)" ] || die "ctype A/A': 200, the record, no Accept header"; done
[ "$(printf '%s\n' "$KA" | sed 1d)" = "$(printf '%s\n' "$KA2" | sed 1d)" ] || die "ctype: A' is not A"
[ "$(aft "\$ $(url "$L_B" 19370)" "$KB")" = "$(WA "$(E4XX 415 'Unsupported Media Type' /customers) · Accept: [application/json, application/*+json]" 1)" ] || die "ctype B: 415, the Accept header, one WARN"
has "$KB" "${RES}web.HttpMediaTypeNotSupportedException: Content-Type 'application/x-www-form-urlencoded;charset=UTF-8' is not supported]" "ctype B: a form, in the WARN line"
[ "$(aft "$(BQ 19370 /customers/Asha)" "$KB")" = "$(WA "$(E4XX 404 'Not Found' /customers/Asha)" 0)" ] || die "ctype B: nothing stored"
echo "  ctype: A and A' - 200, the record, Accept []; B (one option out) - 415, Accept [application/json, application/*+json], 1 WARN naming the form; nothing stored"

# "its dependency, and its version pin ... Fifty-eight libraries become fifty-six. The annotations jar stays, because Jackson three reads
#  the same annotations, and takes Boot's own version once the pin is gone. ... Actuator no longer builds a Jackson two mapper."
JK=$(cat .r-jackson.out); JB=$(blk jackson 'Actuator' 'after - after/'); JA=$(blk jackson 'after - after/' 'the last course')
has "$JK" '  pom.xml - hunks: 1 · lines out: 1 · in: 0:' "jackson: the pin, one line"; has "$JK" '    -    <jackson-2-bom.version>2.22.2</jackson-2-bom.version>' "jackson: the pin"
has "$JK" '  tiffinbox-web/pom.xml - hunks: 1 · lines out: 4 · in: 0:' "jackson: the dependency, four lines"
for l in '    -    <dependency>' '    -      <groupId>com.fasterxml.jackson.core</groupId>' '    -      <artifactId>jackson-databind</artifactId>' '    -    </dependency>'; do has "$JK" "$l" "jackson: the dependency's lines"; done
has "$JK" "the executable jar's BOOT-INF/lib: 58 jars -> 56" "jackson: 58 -> 56"
has "$JK" '  removed 3: jackson-annotations-2.22.jar jackson-core-2.22.2.jar jackson-databind-2.22.2.jar · added 1: jackson-annotations-2.21.jar' "jackson: the three out, the one in"
has "$JK" '    com/fasterxml/jackson/databind/: 812 -> 0' "jackson: Jackson 2's databind classes gone"; has "$JK" '    com/fasterxml/jackson/core/: 213 -> 0' "jackson: Jackson 2's core classes gone"
printf '%s\n' "$JK" | grep -qE '^    com/fasterxml/jackson/annotation/: [1-9][0-9]* -> [1-9][0-9]*$' || die "jackson: the annotations stay"
has "$JK" '    tools/jackson/databind/: 904 -> 904' "jackson: Jackson 3 the same"
has "$JK" '  jackson-annotations-2.22.jar jackson-core-2.22.2.jar jackson-core-3.1.5.jar jackson-databind-2.22.2.jar jackson-databind-3.1.5.jar spring-boot-jackson-4.1.1.jar spring-boot-starter-jackson-4.1.1.jar' "jackson: Maven's class path before, both Jacksons"
has "$JK" '  jackson-annotations-2.21.jar jackson-core-3.1.5.jar jackson-databind-3.1.5.jar spring-boot-jackson-4.1.1.jar spring-boot-starter-jackson-4.1.1.jar' "jackson: Maven's class path after, Jackson 2's two out"
has "$JK" "who still reads the annotations - after/'s jackson-databind-3.1.5.jar, its manifest's Import-Package for them: com.fasterxml.jackson.annotation;version=\"[2.21,3)\"" "jackson: Jackson 3 imports the annotations"
printf '%s\n' "$JK" | grep -qF '<jackson-2-bom.version>2.21.5</jackson-2-bom.version> - the property the previous tree'"'"'s pom.xml set: <jackson-2-bom.version>2.22.2</jackson-2-bom.version> · Jackson 3'"'"'s BOM' || die "jackson: Boot's own version of the property"
printf '%s\n' "$JK" | grep -qF '<jackson.version.annotations>2.21</jackson.version.annotations>' || die "jackson: Jackson 3's BOM, 2.21"
printf '%s\n' "$JB" | grep -qF "    Jackson2EndpointAutoConfiguration - matched: @ConditionalOnClass found required classes 'com.fasterxml.jackson.databind.ObjectMapper'" || die "jackson: before, Actuator's Jackson 2 configuration matched"
printf '%s\n' "$JB" | grep -qF "    Jackson2EndpointAutoConfiguration#jackson2EndpointJsonMapper - matched: " || die "jackson: before, its mapper bean"
printf '%s\n' "$JA" | grep -qxF "    Jackson2EndpointAutoConfiguration - did not match: @ConditionalOnClass did not find required class 'com.fasterxml.jackson.databind.ObjectMapper' (OnClassCondition)" || die "jackson: after, Actuator's Jackson 2 configuration did not match"
! printf '%s\n' "$JA" | grep -qF 'jackson2EndpointJsonMapper - matched' || die "jackson: after, no Jackson 2 mapper bean"
[ "$(printf '%s\n' "$JK" | grep -cxF "    the report's entries in its two lists: over 100, the others not shown")" = 2 ] || die "jackson: the report's other entries, bounded"
has "$JB" '    entries naming Jackson2, in the report'"'"'s two lists: matched 3 · did not match 2' "jackson: before 3 matched"; has "$JA" '    entries naming Jackson2, in the report'"'"'s two lists: matched 0 · did not match 4' "jackson: after none matched"
has "$JK" '  exit 12 · what it printed: zip error: Nothing to do! (tiffinbox-web/target/hang/lib/jackson-databind-2.22.2.jar)' "jackson: the last course's zip line, nothing to do"
[ "$(printf '%s\n' "$JK" | grep -A1 -F "/actuator/configprops" | grep -cxF '  200')" = 2 ] || die "jackson C: configprops 200, both trees"
echo "  jackson: the pin (1 line) and the dependency (4 lines) out; lib 58 -> 56 - 3 out, 1 in; databind 812 -> 0, core 213 -> 0, the annotations stay; Maven's class path the same; Jackson 3 imports the annotations; 2.21.5 / 2.21; Jackson2EndpointAutoConfiguration matched -> did not match; zip exit 12; C configprops 200 / 200"

# the exercise's end state: the README's commands, then the solution's, in ONE env -i shell - each leaves the shell in this folder;
# the line exercise/README.md calls "Done" is a line of this capture, after the solution's lines, and of SOLUTION.md's measured run;
# the README's own last line, as shipped, prints the 415
XS=$(blk exercise "the README's" "the solution's"); XE=$(blk exercise "the solution's" '')
l='status: 200 · its Accept header: none · customers now: 5'; l0='status: 415 · its Accept header: application/json, application/*+json · customers now: 4'
has "$XE" "    $l" "exercise: the solution"; has "$XS" "    $l0" "exercise: as shipped"
awk '/^\*\*Done\*\*/ { f = 1 } f' exercise/README.md | grep -qxF -- "$l" || die "exercise/README.md: Done names no such line"
grep -qxF -- "$l" exercise/solution/SOLUTION.md || die "SOLUTION.md: the measured run shows no such line"
grep -qF -- "\`$l0\`" exercise/README.md || die "exercise/README.md: the shipped line's answer is not named"
has "$XS" '  exit 0 · what they printed:' "exercise: the README's commands, exit 0"; has "$XE" '  exit 0 · what they printed:' "exercise: the solution's lines, exit 0"
has "$XS" "  the shell is now in: this unit's folder · the copy's own token in its log: 0 times · WARN lines in its log: 1" "exercise: the README's commands leave the shell in this unit's folder, one WARN"
has "$XE" "  the shell is now in: this unit's folder · the copy's own token in its log: 0 times · WARN lines in its log: 0 · listening on 19379 now: 0" "exercise: the solution's lines leave the shell in this unit's folder, nothing logged, nothing listening"
[ "$(printf '%s\n' "$XE" | grep -c '^  \$ export ')" = 2 ] || die "exercise: SOLUTION.md gives the README's two export lines"
r=$(printf '%s\n' "$XS" | grep '^  \$ (cd \.harness/mine/after && ' | sed 's/^  \$ //'); r2=$(printf '%s\n' "$XE" | grep '^  \$ (cd \.harness/mine/after && ' | sed 's/^  \$ //')
[ "${r2/"$CTH"/}" = "$r" ] || die "exercise: the solution's last line is the README's with the one header added, and nothing else"
echo "  exercise: one env -i shell - the README as written -> 415, the Accept header, 4 customers, 1 WARN; the solution's lines (one header added) -> 200, no Accept header, 5; the shell in this unit's folder after each"

# "And every form, the jar, the AOT jar, built ahead of time, the native binary and the image, serves the seven and the new route, on
#  loopback, this computer only. Two point seven still becomes two, in all four."
x forms '^  exit 0 · BUILD SUCCESS · stages it printed: 8 of the 8 it announces · its duration, against the bound: under 20 minutes · its lines that say the metadata repository was downloaded over http, or failed to: 0 · offline: yes$'
x forms '^  file: Mach-O 64-bit executable · the demo token in its bytes: 0$'
x forms '^  Spring.s generated metadata \(spring-aot/main/resources/META-INF/native-image/com\.tiffinbox/tiffinbox-web/reachability-metadata\.json\): reflection entries naming com\.tiffinbox\.Customer: 1 - all declared fields · all declared constructors · 4 methods \(mealType mealsPerDay name pricePerMeal\)$'
x forms "^four forms, one tree: the seven \(masked\) 4 of 4 times $S87C · the new customer.s record \(POSTed, then read back\) 8 of 8 · no Content-Type 415 4 of 4 · two point seven meals stored as 2 8 of 8 \(POSTed, then read back\)\$"
x forms '^  loopback, form by form: the jar yes · the AOT jar yes · the binary yes · the image, published on 127\.0\.0\.1 alone yes$'
for t in '1 the jar' '2 the AOT jar' '3 the binary' '4 the image'; do x forms "^$t - "; done
[ "$(n forms "^  Boot's first line: Starting AOT-processed TiffinBoxServer v1\.0\.0 using Java 25\.0\.4\.1\$")" = 2 ] && [ "$(n forms "^  Boot's first line: Starting AOT-processed TiffinBoxServer using Java 25\.0\.4\.1\$")" = 2 ] || die "forms: the AOT jar and the binary, AOT-processed, both starts"
[ "$(n forms '^  inside the container, listening: \[::\]:18425$')" = 2 ] && [ "$(n forms '^  docker port: 18425/tcp -> 127\.0\.0\.1:19377$')" = 2 ] || die "forms: the image, two containers, published on 127.0.0.1 alone"
x forms '^  its lines that say pull: 0 · '
x forms '^  the image saved \(docker save\): [1-9][0-9]* blobs, its [1-9][0-9]* layers among them, each read whole \(gzip ones unpacked\) · the demo token in them: 0$'
echo "  forms: 8 of 8 stages, offline, Mach-O, 0 tokens; Customer in the AOT step's metadata; the jar, the AOT jar, the binary, the image: the seven 87ca7efc... 4 of 4, the new customer 200 and read back 4 of 4, no Content-Type 415 4 of 4, 2.7 -> 2 4 of 4, loopback form by form; the image's layers 0 tokens"

cmp -s after/README.md ../c6-tiffinbox/README.md || echo "  (after/README.md and ../c6-tiffinbox/README.md differ - the anchor has moved past this unit's after/)" >&3
[ -z "$unpub" ] || die "no published hash for:$unpub - check the captures, then copy the md5s above into receipts.md5 and run again"
echo "c6-unit08: every capture 3/3 and = published; every spoken number asserted; 0 raw demo tokens in every capture, every log, the container's log, the image's layers and the binary; nothing of this run left on Docker"
