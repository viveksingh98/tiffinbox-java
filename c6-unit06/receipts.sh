#!/bin/bash
XPATH=$PATH                                           # the PATH you started this with: the exercise's own shell gets it
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25.0.4.1 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# GRAALVM_HOME names a GraalVM JDK 25 (README.md, "The GraalVM"): the native build reads it. Without it, this script makes every
# capture that needs no GraalVM, filling .m2-demo on the way, then stops before the native build.
# Course 6 · @RestController and Request Mapping - this unit's receipts. The anchor changes: TiffinBox's routes stop being found
# by a router of its own (an annotation, a scan by reflection, a TreeMap, the verb checked inside its handler) and become Spring
# MVC's own request mappings - TiffinBoxServer a @RestController, its five routes @GetMapping and @PostMapping. Eleven captures,
# each run three times and hashed; cap() DIES when a hash differs from receipts.md5; every number the video says is asserted at
# the bottom by a check that can fail; the demo token is masked (gsub), and the checks count 0 raw copies of it in every capture,
# in the log of every run - every failed start's and the container's included - in every file this unit ships, in the binary
# and in the image's layers.
#   change    the previous tree against after/: the files that differ; the router's two files, deleted; TiffinBoxServer's code
#             lines - the router's, the hint's, the timer's, the DEBUG line's, Jackson 2's - before and after; the diff -U0 hunks
#             that change an annotation; the class read by the harness's Stereotype; the jar's lib/; the files left alone
#   scan      what registers the routes at start: the previous tree (TiffinBox's own lines, at DEBUG) against after/ - Spring
#             MVC's RequestMappingHandlerMapping at TRACE, each route with its verb, before Boot's started line
#   rows      the routing table (mappings exposed for one run): TiffinBox's rows before (a path and a handler's name) and after
#             (a verb, a pattern and the method), every key of the /customers row
#   verbs     who decides the verbs, before and after: HEAD, OPTIONS, DELETE, GET /shutdown, POST /shutdown without the token, an
#             XML Accept header - each answer's status, type, Allow and Content-Length, and the WARN lines each added
#   seven     the comparison set before and after (one line differs, GET /shutdown), each server's status line and header
#             names, the WARN lines the seven logged; why, at DEBUG (C, labelled: the harness's Converters joined) - and who
#             writes TiffinBox's answers now, read off the running adapter
#   json      who writes the answers, by taking a class away: the README's missing-class lines (a Jackson 2 class deleted)
#             before and after; C (labelled) a Jackson 3 class deleted instead
#   patterns  A/B/A': a pattern with ** in the middle (the harness's MidPattern) - A refused at start, B the legacy parser by
#             flag, A' = A; then the literals: whole paths, a prefix, a literal beside a variable, {*rest}, a path parameter,
#             POST /shutdownXYZ with the token (the harness's Patterns)
#   timers    who times and logs each answer: the previous tree (TiffinBox's timer and its line per answer) against after/
#             (Boot's timer alone, by pattern; the kitchen quiet); C (labelled) Boot's web group at DEBUG - the request as typed
#   stop      POST /shutdown, a controller method now, A/B/A': A Boot's default, B --server.shutdown=immediate, A' = A - the
#             reply, the exit, Boot's graceful lines
#   exercise  exercise/README.md's commands, then exercise/solution/SOLUTION.md's, read from the files and run as written, one after
#             the other in ONE shell a viewer could have: env -i, /bin/bash, started in this folder
#   forms     the native build of after/ and what Spring's AOT step registered (C, labelled: a route returning Object), then four
#             forms - the jar, the AOT jar, the binary, the image: each one's address, the seven (masked), exit 0
# "The previous tree" is ../c6-unit04/after (the anchor before this change: the embedded-Tomcat lesson's frozen tree), COPIED under
# .harness/before; after/ is this unit's frozen copy of ../c6-tiffinbox after the change, COPIED under .harness/after. This script
# never writes into another unit's folder, and never builds a frozen tree in place. Every run of TiffinBox starts in a folder under
# .harness/ that holds a config tree with the demo token (secrets/), as the README asks - the container's too, mounted read-only.
# Commands are printed exactly as they run: each goes through eval. "$CURLSET" is the comparison set since the secrets lesson
# (../c5-unit11/curlset.sh: the seven requests, POST /shutdown with the token's header read from the file). "$M2" is this unit's
# own repository, .m2-demo. The harness - harness/probe/web/Stereotype.java, Converters.java, Patterns.java and MidPattern.java
# (the course's, never TiffinBox's: outside com.tiffinbox; Stereotype runs alone, the others join by --spring.main.sources, all on
# the extracted jar's class path), harness/table.py (reads one Actuator answer) and harness/shutdown.sh (POST /shutdown, the
# token read from its file) - is named on every capture that uses it. Every run passes options only.
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
# the date in a DEBUG line's error map becomes "…"; a thread's number becomes N (tomcat-handler-N); where a native-image warning
# names the file it read an option from, the file's URL - or "null", which it prints when the path holds a space - becomes "…".
# Lines a log prints in an order that moves from run to run are sorted, and say so: the routes inside one of Spring MVC's
# registration blocks, TiffinBox's own route lines at start, the routing table's rows with details. A failed start's log is read
# after it exited, never printed whole (frames counted, the analysis shown). A run's log lines are printed from their logger on
# (no time, no process id); Boot's first line is cut before " with PID". Long logs go through a declared filter, and what it cuts
# is counted or bounded. No image, container or ID is printed but the base image's digest. No duration is captured: the native
# build is judged against a bound; seconds go to the terminal.
# Ports (brief ⚑1, 19350-19359): after/'s jar 19350 · the previous tree 19351 · after/ with the harness joined 19352 · the
# mid-path pattern's A/B/A' 19353 · the AOT jar 19354 · the missing-class copies of after/ 19355 · stop 19356 · the image 19357 ·
# the binary 19358 · the exercise 19359. 18425 (TiffinBox's default) and 8080 (Tomcat's) are checked free too, and never bound on
# this machine (18425 only inside a container).
# Docker names (no unit number): the image tiffinbox-mvc:1.0.0 and the container tiffinbox-mvc. Each is checked absent before the
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
IMG=tiffinbox-mvc:1.0.0; BOX=tiffinbox-mvc
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
      $2 == g && $1 != me && $3 != "awk" && $3 != "ps" && (index($0, "vminvocation.args") || index($3, gh "/bin/native-image") || $3 ~ /tiffinbox-web\/target\/tiffinbox-web$/ || index($0, "tiffinbox-web-1.0.0.jar") || index($0, "com.tiffinbox.web.TiffinBoxServer") || index($0, "probe.web.Stereotype")) { print $1 }' | paste -sd' ' -) || l=""
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
for t in python3 curl rsync lsof unzip zip javac docker openssl; do command -v $t > /dev/null || die "$t is needed"; done
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
PREV=../c6-unit04/after                              # the previous tree: the anchor before this change - read, copied
[ -e secrets ] && die "this folder holds a secrets/ - remove it: every run here starts in a folder under .harness/"
for t in "$PREV" after; do
  [ -f "$t/pom.xml" ] && [ -f "$t/README.md" ] && [ -f "$t/Dockerfile" ] && [ -f "$t/.dockerignore" ] || die "the tree $t (its pom.xml, README.md, Dockerfile or .dockerignore) is missing"
  [ -e "$t/secrets" ] || [ -e "$t/target" ] || [ -e "$t/tiffinbox-web/target" ] && die "$t holds a secrets/ or a target/ - it is a frozen copy, never built in place"
  grep -qx 'secrets/' "$t/.dockerignore" || die "$t's .dockerignore no longer keeps secrets/ out of a build context"; done
M2="$PWD/.m2-demo"; U="$PWD"; UP="$(cd .. && pwd)"; ME="$(id -un)"
W=tiffinbox-web/src/main/java/com/tiffinbox/web     # TiffinBox's web classes, in a tree
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
for f in harness/shutdown.sh harness/table.py harness/probe/web/Stereotype.java harness/probe/web/Converters.java harness/probe/web/Patterns.java harness/probe/web/MidPattern.java exercise/README.md exercise/solution/SOLUTION.md README.md; do [ -f "$f" ] || die "$f is missing"; done

# The ports and the Docker names, BEFORE anything is wiped (a survivor of an interrupted run answers POST /shutdown only with its
# token, which lives in .harness/ - so the message names the process to kill).
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
for p in 18425 8080 19350 19351 19352 19353 19354 19355 19356 19357 19358 19359; do
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
R_WEB=$(readme "$J --logging.level.web=debug")
R_KDBG=$(readme "$J --logging.level.kitchen=debug")
R_AOTRUN=$(readme 'java -Dspring.aot.enabled=true -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431')
R_GRAAL=$(readme 'export GRAALVM_HOME=/path/to/a/graalvm-jdk-25')
R_INSTALL=$(readme 'mvn -B -Pnative install')
R_NATIVE=$(readme 'mvn -B -Pnative -pl tiffinbox-web native:compile-no-fork')
R_BIN=$(readme 'tiffinbox-web/target/tiffinbox-web --tiffinbox.port=18431')
R_BINDBG=$(readme "tiffinbox-web/target/tiffinbox-web --tiffinbox.port=18431 --logging.level.web=debug --logging.level.kitchen=debug --logging.pattern.console='%thread %msg%n'")
R_EXTRACT=$(readme 'java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted')
R_CP=$(readme 'java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431')
R_DBUILD=$(readme 'docker build -t tiffinbox-docker:1.0.0 .')
R_DRUN=$(readme 'docker run -d --name tiffinbox -m 512m -v "$PWD/secrets:/app/secrets:ro" -p 127.0.0.1:18431:18425 tiffinbox-docker:1.0.0')
R_READY=$(readme "curl -s -w ' %{http_code}\n' http://127.0.0.1:18431/actuator/health/readiness")
R_Q=$(readme "curl -s -o /dev/null -w '%{http_code} %{content_type}\n' http://127.0.0.1:18431/customers")
# The README's lines for a class the answer needs, deleted (Course 5's missing-class demo, in the anchor's README): a copy of the
# extracted jar under target/hang, one class out of a Jackson jar, the copy's jar run, /customers asked with a five-second limit
R_HANG1=$(readme 'rm -rf tiffinbox-web/target/hang && mkdir tiffinbox-web/target/hang && cp tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar tiffinbox-web/target/hang/ && cp -R tiffinbox-web/target/extracted/lib tiffinbox-web/target/hang/lib')
R_HANG2=$(readme "zip -q -d tiffinbox-web/target/hang/lib/jackson-databind-2.22.2.jar 'com/fasterxml/jackson/databind/jdk14/JDK14Util*'")
R_HANG3=$(readme 'java -jar tiffinbox-web/target/hang/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --logging.level.kitchen=debug')
R_HANG4=$(readme "curl -s -m 5 -w ' %{http_code}\n' http://127.0.0.1:18431/customers")
WEBF=${R_WEB#"$J "}; KDBGF=${R_KDBG#"$J "}
[ "$WEBF" = '--logging.level.web=debug' ] && [ "$KDBGF" = '--logging.level.kitchen=debug' ] || die "the README's options"
# This unit's own lines (README.md, "The commands this unit adds") - each asserted to be exactly that: the start with Spring MVC's
# mapping logger at TRACE and the kitchen at DEBUG (scan), the routing table exposed for one run and read (rows), one answer's
# status, type, Allow and Content-Length (verbs), one answer's status line and headers (seven), the legacy parser (patterns),
# Boot's shutdown made immediate (stop), a Jackson 3 class deleted from the hang copy (json), and the harness's Stereotype
mine() { grep -m1 -xF -- "$1" README.md > /dev/null || die "README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
L_SCAN=$(mine "$J --logging.level.kitchen=debug --logging.level.org.springframework.web.servlet.mvc.method.annotation.RequestMappingHandlerMapping=trace")
L_EXPO=$(mine "$J --management.endpoints.web.exposure.include=health,prometheus,mappings")
L_TABLE=$(mine 'curl -s http://127.0.0.1:18431/actuator/mappings | python3 harness/table.py')
L_ROW=$(mine 'curl -s http://127.0.0.1:18431/actuator/mappings | python3 harness/table.py row /customers')
L_V=$(mine "curl -s -o /dev/null -w '%{http_code} %{content_type} · Allow: %header{allow} · Content-Length: %header{content-length}\n' http://127.0.0.1:18431/customers")
L_HDR=$(mine 'curl -s -D - -o /dev/null http://127.0.0.1:18431/customers')
L_ANT=$(mine "$J --spring.mvc.pathmatch.matching-strategy=ant-path-matcher")
L_IMM=$(mine "$J --server.shutdown=immediate")
L_J3=$(mine "zip -q -d tiffinbox-web/target/hang/lib/jackson-databind-3.1.5.jar 'tools/jackson/databind/util/RecordUtil*'")
L_ST=$(mine 'java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" probe.web.Stereotype com.tiffinbox.web.TiffinBoxServer')
SCANF=${L_SCAN#"$J "}; EXPOF=${L_EXPO#"$J "}; ANTF=${L_ANT#"$J "}; IMM=${L_IMM#"$J "}
[ "$ANTF" = '--spring.mvc.pathmatch.matching-strategy=ant-path-matcher' ] && [ "$IMM" = '--server.shutdown=immediate' ] && [ "$EXPOF" = '--management.endpoints.web.exposure.include=health,prometheus,mappings' ] || die "this unit's README: its options"
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
# qc PORT PATH ['CURL OPTIONS']: the README's status-and-type line, its port made PORT and its path PATH, OPTIONS before the URL;
# a URL that holds a character the shell reads (; ? & *) is single-quoted, so eval hands it to curl whole
qurl() { local u="http://127.0.0.1:$1$2"; case $2 in *[\;\?\&\*]*) u="'$u'" ;; esac; printf '%s\n' "$u"; }
qc() { local c; c=$(url "$R_Q" "$1"); c=${c% http://*}; printf '%s%s %s\n' "$c" "${3:+ $3}" "$(qurl "$1" "$2")"; }
# vc PORT PATH ['CURL OPTIONS']: this unit's verbs line the same way - status, type, Allow and Content-Length
vc() { local c; c=$(url "$L_V" "$1"); c=${c% http://*}; printf '%s%s %s\n' "$c" "${3:+ $3}" "$(qurl "$1" "$2")"; }
# exe 'COMMAND': the command with "exec" after its "cd DIR && " and any NAME=value before the program - so $pid is the program's
exe() { printf '%s\n' "$1" | sed -E 's/&& (([A-Z_]+=[^ ]* )*)/\&\& \1exec /'; }
# The docker lines, as this script runs them: the README's build line with plain progress and this script's own tag; its run line
# with this script's own name and tag, the port published on 127.0.0.1 made PORT, and your user and group added - the config tree
# is yours, mode 0600 (R.74). undock() takes those changes back out, and must give the README's lines again.
UARG='--user "$(id -u):$(id -g)"'
dbuild() { local c=${R_DBUILD/docker build -t tiffinbox-docker:1.0.0 /docker build --progress=plain -t $IMG }; printf 'cd %s && %s\n' "$1" "$c"; }
drun() { local c=${R_DRUN/--name tiffinbox /--name $BOX $UARG }; c=${c/127.0.0.1:18431:18425/127.0.0.1:$2:18425}; c=${c/% tiffinbox-docker:1.0.0/ $IMG}; printf 'cd %s && %s\n' "$1" "$c"; }
undock() { local c=${1#cd * && }; c=${c/--progress=plain /}; c=${c/" $UARG"/}; c=${c//$IMG/tiffinbox-docker:1.0.0}; c=${c/--name $BOX /--name tiffinbox }; c=${c/127.0.0.1:1935?:18425/127.0.0.1:18431:18425}; printf '%s\n' "$c"; }
[ "$(undock "$(dbuild .harness/x)")" = "$R_DBUILD" ] || die "not the README's build line with the declared changes: $(dbuild .harness/x)"
[ "$(undock "$(drun .harness/x 19357)")" = "$R_DRUN" ] || die "not the README's run line with the declared changes: $(drun .harness/x 19357)"
C_PRE=$(off .harness/pre "$R_INSTALL" install)
for c in "$C_PRE" "$(off .harness/x "$R_PLAIN" package)" "$(off .harness/x "$R_PNAT" package)" "$(off .harness/x "$R_NATIVE")"; do
  r=$(dev "$c"); [ "$r" = "$R_PLAIN" ] || [ "$r" = "$R_PNAT" ] || [ "$r" = "$R_INSTALL" ] || [ "$r" = "$R_NATIVE" ] || die "not a README line with the offline changes: $c"; done
[ "$(exe "$(at .harness/x 19350 "$R_RUN")")" = 'cd .harness/x && exec java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19350' ] || die "exe()"
[ "$(hcp .harness/x 19352 probe.web.Converters "$WEBF")" = 'cd .harness/x && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19352 --spring.main.sources=probe.web.Converters --logging.level.web=debug' ] || die "hcp()"
[ "$(qc 19350 /customersXYZ)" = "curl -s -o /dev/null -w '%{http_code} %{content_type}\n' http://127.0.0.1:19350/customersXYZ" ] && [ "$(vc 19350 /customers -I)" = "curl -s -o /dev/null -w '%{http_code} %{content_type} · Allow: %header{allow} · Content-Length: %header{content-length}\n' -I http://127.0.0.1:19350/customers" ] && [ "$(qc 19352 '/customers;x=1')" = "curl -s -o /dev/null -w '%{http_code} %{content_type}\n' 'http://127.0.0.1:19352/customers;x=1'" ] || die "qc(), vc()"
echo "  the commands: after/README.md gives all 21 lines this script runs or derives from; README.md the 10 this unit adds"

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
# tree FOLDER: a config tree in FOLDER/secrets holding one file, the token and a newline, readable by its owner alone
tree() { mkdir -p "$1/secrets/tiffinbox"; (umask 077 && printf '%s\n' "$TOKEN" > "$1/$TF"); chmod 700 "$1/secrets" "$1/secrets/tiffinbox"; }
mbuild "$C_PRE" .harness/build-pre.log ".harness/pre (after/, the profile native, both modules into \$M2)"
mbuild "$(off .harness/pre0 "$R_PLAIN" package)" .harness/build-pre0.log ".harness/pre0 (the previous tree)"
[ -f "$M2/org/springframework/boot/spring-boot-starter-webmvc/4.1.1/spring-boot-starter-webmvc-4.1.1.jar" ] || die "Spring MVC's starter is not in .m2-demo after the first build"
[ -f "$M2/org/graalvm/buildtools/native-maven-plugin/1.1.8/native-maven-plugin-1.1.8.jar" ] || die "GraalVM's native plugin 1.1.8 is not in .m2-demo after the first build"
[ -f "$ZIP" ] || die "GraalVM's metadata repository is not in .m2-demo after the first build - README.md, The repository"
(cd .harness/pre && eval "$R_EXTRACT") > .harness/extract-pre.log 2>&1 || die "the README's extract line failed on .harness/pre"
javac -parameters -d .harness/hc -cp ".harness/pre/tiffinbox-web/target/extracted/lib/*" harness/probe/web/*.java > .harness/javac.log 2>&1 || { cat .harness/javac.log >&3; die "the harness did not compile against after/'s jar"; }
echo "  .m2-demo holds Spring MVC's starter, GraalVM's native plugin 1.1.8 and its metadata repository; the harness compiled against after/'s jar"

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
logtok() { local t h; t=$(raw "$TOKEN" .harness/run.out .harness/run.err); h=$(cat .harness/run.out .harness/run.err | LC_ALL=C grep -aoi -- 'x-shutdown-token' | wc -l | tr -d ' ')
  LOGS=$((LOGS + 1)); [ "$t" = 0 ] && [ "$h" = 0 ] || die "a log held the demo token ($t) or its header's name ($h)"
  echo "  its log: the demo token 0 times · X-Shutdown-Token 0 times"; }
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
# timestamp mask, and how many lines the mask changed; its log counted (logtok)
seven() { local m
  echo "\$ \$CURLSET $1 $2/$TF"
  "$CURLSET" "$1" "$2/$TF" | grep ' -> ' > .harness/responses.txt || true
  tsmask < .harness/responses.txt > .harness/responses.m.txt
  grep '^POST ' .harness/responses.m.txt | sed 's/^/  /' || echo "  (no POST line)"
  gone "$1"
  m=$(diff .harness/responses.txt .harness/responses.m.txt | grep -c '^<' || true)
  echo "  exit $LASTE · the seven responses: $(wc -l < .harness/responses.m.txt | tr -d ' ') lines · lines the timestamp mask changed: $m · md5 $(md5 -q .harness/responses.m.txt)"
  logtok; }
# post PORT DIR [PATH]: POST PATH (/shutdown) with DIR's token (harness/shutdown.sh) - its answer, the timestamp masked
post() { echo "\$ harness/shutdown.sh $1 $2/$TF${3:+ $3}"; harness/shutdown.sh "$1" "$2/$TF" ${3:+"$3"} | tsmask | sed 's/^/  /'; }
# stop PORT DIR: POST /shutdown with DIR's token; the JVM must leave, the port must be free
stop() { post "$1" "$2"; gone "$1"; echo "  exit $LASTE · listening on $1 now: 0"; logtok; }
# glines: Boot's two graceful-shutdown lines in the last run's log (.harness/run.out), counted - read after the JVM (or the
# container) is gone
glines() { echo "  Boot's graceful-shutdown lines in its log: $(grep -cE 'Commencing graceful shutdown\. Waiting for active requests to complete|Graceful shutdown complete' .harness/run.out || true)"; }
SHAPEAWK='
an { if (NF) ana[++na] = "  " $0; next }
/^Description:$/ { an = 1; ana[++na] = "  " $0; next }
/^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T[^ ]+ +[A-Z]+ +[0-9]+ --- \[/ {
  lv = $2; s = $0; i = index(s, " --- ["); s = substr(s, i + 6); i = index(s, "] "); s = substr(s, i + 2)
  i = index(s, " : "); lg = substr(s, 1, i - 1); sub(/ +$/, "", lg); msg = substr(s, i + 3)
  if (lv == "WARN" || lv == "ERROR") {
    if (lv == "WARN" && match(msg, /attempt: [A-Za-z0-9_.$]+/)) msg = substr(msg, 1, RSTART + RLENGTH - 1) " …"
    ln[++nl] = "  " lv " " lg (msg == "" ? ":" : ": " msg) }
  if (index(msg, "Tomcat started on port ") == 1 || index(msg, "Tomcat initialized with port ") == 1) tc++   # (TomcatWebServer: a class of Boot)
  next }
/^\tat / { fr++; if (ne) fx[ne]++; next }
/^\t\.\.\. [0-9]+ (common frames omitted|more)$/ { om += $2; next }
/^Caused by: / { cb++; ex[++ne] = "  " $0; next }
/^([a-z][a-z0-9_]*\.)+[A-Z][A-Za-z0-9_$]*(: .*)?$/ { ex[++ne] = "  " $0; next }
/^APPLICATION FAILED TO START$/ { ban++; next }
/^Error starting ApplicationContext\. To display the condition evaluation report re-run your application with .debug. enabled\.$/ { hint = $0; next }
END {
  by = ""; for (i = 1; i <= ne; i++) by = by (i == 1 ? " = " : " + ") (fx[i] + 0)
  print "  its log, read after it exited: APPLICATION FAILED TO START " (ban + 0) " · stack frames " (fr + 0) (fr ? by : "") " · Caused by: " (cb + 0) " · frames folded as common " (om + 0) " · Boot\047s Tomcat lines " (tc + 0)
  for (i = 1; i <= nl; i++) print ln[i]
  for (i = 1; i <= ne; i++) print ex[i]
  if (hint != "") print "  the hint Boot logs: " hint
  for (i = 1; i <= na; i++) print ana[i] }'
heard() { echo "  its log: the banner's :: Spring Boot :: line $(grep -c ':: Spring Boot ::' "$1" || true)"; }
# fails 'COMMAND': a start expected to end by itself, printed as typed and run (eval; exec, so $fpid is the program's own),
# bounded (120 s); its exit code; its log's shape (SHAPEAWK), how far it got (heard); the token in its log, raw - 0
fails() { local e=0 i=0 t
  echo "\$ $1"; (eval "$(exe "$1")") > .harness/fail.out 2> .harness/fail.err < /dev/null & fpid=$!
  while kill -0 "$fpid" 2> /dev/null && [ $i -lt 480 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$fpid" 2> /dev/null && { kill "$fpid"; die "a start expected to end still ran after 120 s: $1"; }
  wait "$fpid" || e=$?; fpid=""; LASTE=$e
  echo "  exit $e"
  t=$(raw "$TOKEN" .harness/fail.out .harness/fail.err); FLOGS=$((FLOGS + 1)); [ "$t" = 0 ] || die "a failed start's log held the demo token ($t)"
  awk "$SHAPEAWK" .harness/fail.out; heard .harness/fail.out
  echo "  its standard error: $(wc -l < .harness/fail.err | tr -d ' ') lines · the demo token in its log: 0"; }
now() { local p o=""; for p in "$@"; do o="$o${o:+ · }$p $(listeners "$p")"; done; echo "  listening now: $o"; }
# meta JAR NAME: Boot's own metadata for a setting - its default, and the jar inside JAR whose metadata declares it
meta() { python3 - "$1" "$2" <<'PY'
import io, json, sys, zipfile
z = zipfile.ZipFile(sys.argv[1]); want = sys.argv[2]; out = []
for j in sorted(e for e in z.namelist() if e.startswith("BOOT-INF/lib/") and e.endswith(".jar")):
    i = zipfile.ZipFile(io.BytesIO(z.read(j))); n = "META-INF/spring-configuration-metadata.json"
    if n in i.namelist():
        for p in json.loads(i.read(n)).get("properties", []):
            if p["name"] == want:
                d = p.get("defaultValue")
                out.append("%s %s (%s)" % (want, "no default" if d is None else "default " + (d if isinstance(d, str) else json.dumps(d)), j.split("/")[-1]))
print(" · ".join(out) if out else want + ": in no jar's metadata")
PY
}
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
# warns FROM: the WARN lines a request added after line FROM, at the level the run was started with - counted, then each one
warns() { local n; n=$(logl "$1" WARN | grep -c . || true); echo "  WARN lines it added: $n"; [ "$n" = 0 ] || logl "$1" WARN; }
# hdr PORT: one answer's status line - in brackets, so a trailing space shows - and its headers, by name in the order they came
# (this unit's line, GET /customers): the seven print status, type and body alone, and this is what they leave out
hdr() { local c; c=$(url "$L_HDR" "$1"); echo "\$ $c"; (eval "$c") 2> /dev/null < /dev/null | tr -d '\r' > .harness/hdr.txt || true
  echo "  its status line: [$(head -1 .harness/hdr.txt)] · its headers, by name: $(sed -n '2,/^$/p' .harness/hdr.txt | sed -n 's/:.*$//p' | paste -sd' ' -)"; }

# ---- change: the previous tree against after/ ---------------------------------------------------------------------------------
# The lines of TiffinBoxServer.java's code (neither comment nor blank) that name each job the change moves, counted before and
# after: the router's parts (its annotation in use, the scan, its TreeMap, the reflective call), Course 5's hint, TiffinBox's own
# timer, a DEBUG line of TiffinBox's, its own Jackson 2 mapper, and Spring MVC's mapping annotations
ROUTERRE='@Route|scanRoutes|TreeMap|\.invoke\('
TIMERRE='tiffinbox\.requests|Timer|MeterRegistry'
MAPRE='@(RestController|GetMapping|PostMapping)([^A-Za-z]|$)'
# a hunk line that adds or removes a class or route annotation: the one before the class (@Component, @RestController, the hint)
# or before a route (@Route, @GetMapping, @PostMapping)
ANNRE='^[-+] *@(Component|RestController|RegisterReflectionForBinding|Route|GetMapping|PostMapping)([^A-Za-z]|$)'
# stereo DIR: the harness's Stereotype run on DIR's extracted jar (this unit's line) - what the class's annotations add up to
stereo() { local c="cd $1 && $L_ST"; echo "\$ $c"; (eval "$c") 2>&1 < /dev/null | sed 's/^/  /'; }
change() { local f
  echo "the previous tree and after/, both copied under .harness/ with a config tree, each built with the README's line (offline):"
  copy "$PREV" .harness/before; copy after .harness/after
  pbuild .harness/before "the previous tree"; pbuild .harness/after "after/"
  echo "both jars extracted (the README's line) - the class path the harness runs on:"
  extract .harness/before; extract .harness/after
  echo "the harness, compiled against after/'s own jar - with -parameters, so a method's parameter names are in its class file:"
  local c="javac -parameters -d .harness/hc -cp \".harness/after/tiffinbox-web/target/extracted/lib/*\" harness/probe/web/*.java"
  echo "\$ $c"; rm -rf .harness/hc; (eval "$c") > .harness/javac.log 2>&1 < /dev/null || { cat .harness/javac.log >&3; die "the harness did not compile against after/'s jar"; }
  echo "  exit 0"
  echo "the files that differ:"
  echo "\$ diff -rq -x target -x secrets .harness/before .harness/after"
  diff -rq -x target -x secrets .harness/before .harness/after | sed 's/^/  /' || true
  echo "the router's two files, and the server, their lines (wc -l), before -> after:"
  for f in Route RouteMapping TiffinBoxServer; do echo "  $f.java: $(lines ".harness/before/$W/$f.java") -> $(lines ".harness/after/$W/$f.java")"; done
  code ".harness/before/$W/TiffinBoxServer.java" > .harness/fb.txt; code ".harness/after/$W/TiffinBoxServer.java" > .harness/fa.txt
  echo "  TiffinBoxServer.java, its lines that are neither comment nor blank: $(wc -l < .harness/fb.txt | tr -d ' ') -> $(wc -l < .harness/fa.txt | tr -d ' '), of them naming:"
  echo "    the router's parts (@Route, scanRoutes, its TreeMap, invoke): $(grep -cE "$ROUTERRE" .harness/fb.txt || true) -> $(grep -cE "$ROUTERRE" .harness/fa.txt || true)"
  echo "    the hint (@RegisterReflectionForBinding): $(grep -c 'RegisterReflectionForBinding' .harness/fb.txt || true) -> $(grep -c 'RegisterReflectionForBinding' .harness/fa.txt || true) · the router's annotation's hint, @Reflective, in Route.java: $(grep -c '^@Reflective' ".harness/before/$W/Route.java" || true) -> $( [ -f ".harness/after/$W/Route.java" ] && grep -c '^@Reflective' ".harness/after/$W/Route.java" || echo 'the file is deleted')"
  echo "    TiffinBox's own timer (tiffinbox.requests, Timer, MeterRegistry): $(grep -cE "$TIMERRE" .harness/fb.txt || true) -> $(grep -cE "$TIMERRE" .harness/fa.txt || true) · a DEBUG line of TiffinBox's (LOG.log(DEBUG, …)): $(grep -c 'LOG\.log(DEBUG' .harness/fb.txt || true) -> $(grep -c 'LOG\.log(DEBUG' .harness/fa.txt || true)"
  echo "    its own Jackson 2 mapper (ObjectMapper, JSON.write…): $(grep -cE 'ObjectMapper|JSON\.write' .harness/fb.txt || true) -> $(grep -cE 'ObjectMapper|JSON\.write' .harness/fa.txt || true) · Spring MVC's mapping annotations (@RestController, @GetMapping, @PostMapping): $(grep -cE "$MAPRE" .harness/fb.txt || true) -> $(grep -cE "$MAPRE" .harness/fa.txt || true)"
  diff -U0 .harness/fb.txt .harness/fa.txt | tail -n +3 > .harness/code.diff || true
  echo "  its code lines' diff (diff -U0 of the lines above, its file names cut): $(grep -c '^@@ ' .harness/code.diff || true) hunks, $(grep -c '^-' .harness/code.diff || true) lines out, $(grep -c '^+' .harness/code.diff || true) in - the $(awk -v re="$ANNRE" '/^@@ / { if (a) n++; a = 0; next } $0 ~ re { a = 1 } END { if (a) n++; print n + 0 }' .harness/code.diff) hunks that change a class or route annotation, whole:"
  awk -v re="$ANNRE" '/^@@ / { if (a) printf "%s", b; b = $0 "\n"; a = 0; next } { b = b $0 "\n" } $0 ~ re { a = 1 } END { if (a) printf "%s", b }' .harness/code.diff | sed 's/^/    /'
  echo "the class, read by the harness's Stereotype - no server, no context: java on the extracted jar's class path, before then after:"
  stereo .harness/before; stereo .harness/after
  libs .harness/before/$JARP > .harness/lb.txt; libs .harness/after/$JARP > .harness/la.txt
  echo "the executable jar's BOOT-INF/lib: $(wc -l < .harness/lb.txt | tr -d ' ') jars -> $(wc -l < .harness/la.txt | tr -d ' ') · removed $(comm -23 .harness/lb.txt .harness/la.txt | wc -l | tr -d ' ') · added $(comm -13 .harness/lb.txt .harness/la.txt | wc -l | tr -d ' ') · Jackson 2 (jackson-databind 2.x) $(grep -cE '^jackson-databind-2\.' .harness/lb.txt || true) -> $(grep -cE '^jackson-databind-2\.' .harness/la.txt || true) · Jackson 3 (jackson-databind 3.x) $(grep -cE '^jackson-databind-3\.' .harness/lb.txt || true) -> $(grep -cE '^jackson-databind-3\.' .harness/la.txt || true)"
  diff .harness/before/README.md .harness/after/README.md > .harness/file.diff || true
  echo "  README.md - the anchor's README: lines added $(grep -c '^> ' .harness/file.diff || true), removed $(grep -c '^< ' .harness/file.diff || true) - its new section and the history notes the change made false (not shown)"
  echo "  tiffinbox-core against the previous tree's (diff -rq -x target): $(diff -rq -x target .harness/before/tiffinbox-core .harness/after/tiffinbox-core | wc -l | tr -d ' ') files differ"
  for f in $W/TiffinBoxApp.java $W/BareArgumentGuard.java $W/BareArgumentAnalyzer.java $W/KitchenHealthIndicator.java $W/KitchenMetrics.java $YAML $FAC tiffinbox-web/pom.xml pom.xml Dockerfile compose.yaml .dockerignore; do
    echo "  $f against the previous tree's, byte for byte: $(cmp -s ".harness/before/$f" ".harness/after/$f" && echo the same || echo different)"; done; }

# ---- scan: what registers the routes at start ---------------------------------------------------------------------------------
# reg: the run's lines up to Boot's started line - TiffinBox's own lines that name a route (logger tiffinbox: route …, routes
# mapped …; the route lines sorted - the scan finds them in the order getDeclaredMethods gives, which moves), and Spring MVC's
# RequestMappingHandlerMapping lines (each block's routes sorted, the order they are found in moves too), from the level on
reg() { awk '/ : Tomcat started on port / { exit } { print }' .harness/run.out > .harness/pre.txt
  local r; r=$(grep -E ' tiffinbox +: route ' .harness/pre.txt | sed 's/^.* : //' | sort || true)
  echo "  TiffinBox's own lines that name a route, before Boot's started line (logger tiffinbox; the route lines sorted): $(printf '%s' "$r" | grep -c . || true) + $(grep -cE ' tiffinbox +: routes mapped:' .harness/pre.txt || true)"
  [ -z "$r" ] || printf '%s\n' "$r" | sed 's/^/    tiffinbox: /'
  grep -E ' tiffinbox +: routes mapped:' .harness/pre.txt | sed 's/^.* : /    tiffinbox: /' || true
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
scan() {
  echo "before - the previous tree: this unit's line - TiffinBox's own logger group, kitchen, at DEBUG, and Spring MVC's RequestMappingHandlerMapping at TRACE - port 19351:"
  start "$(at .harness/before 19351 "$L_SCAN")"; up; ready 19351; reg
  stop 19351 .harness/before
  echo "after - after/, the same line, port 19350:"
  start "$(at .harness/after 19350 "$L_SCAN")"; up; ready 19350; reg
  stop 19350 .harness/after; }

# ---- rows: the routing table, before and after ------------------------------------------------------------------------------
rows1() { local c
  c=$(url "$L_TABLE" "$1"); echo "\$ $c"; (eval "$c") 2>&1 < /dev/null
  c=$(url "$L_ROW" "$1"); echo "\$ $c"; (eval "$c") 2>&1 < /dev/null; }
rows() {
  echo "before - the previous tree, mappings exposed for this one run (this unit's line), port 19351:"
  start "$(at .harness/before 19351 "$L_EXPO")"; up; ready 19351; rows1 19351; stop 19351 .harness/before
  echo "after - after/, the same line, port 19350:"
  start "$(at .harness/after 19350 "$L_EXPO")"; up; ready 19350; rows1 19350; stop 19350 .harness/after; }

# ---- verbs: who decides the verbs, before and after ------------------------------------------------------------------------------
# v LABEL PORT PATH ['CURL OPTIONS']: this unit's verbs line, printed and run; then the WARN lines the request added to the log, at
# Boot's default level (INFO: the README's run line sets no level); and one line for the table at the end of the run - LABEL, the
# answer (an empty field named: no type, Allow none, Content-Length none) and the WARN lines it added
VSUM=""
v() { local c n0 w lab=$1; shift; n0=$(mark); c=$(vc "$@"); echo "\$ $c"; (eval "$c") > .harness/v.txt 2>&1 < /dev/null || true; sed 's/^/  /' .harness/v.txt; settle; warns "$n0"
  w=$(logl "$n0" WARN | grep -c . || true)
  VSUM="$VSUM$(printf '\n    %-25s -> %s · WARN lines: %s' "$lab" "$(sed 's/^\([0-9][0-9][0-9]\)  · /\1 (no type) · /; s/Allow:  · /Allow: none · /; s/Content-Length: $/Content-Length: none/' .harness/v.txt)" "$w")"; }
verbs1() { VSUM=""
  v 'HEAD /customers' "$1" /customers -I; v 'OPTIONS /customers' "$1" /customers '-X OPTIONS'; v 'DELETE /customers' "$1" /customers '-X DELETE'
  v 'GET /shutdown' "$1" /shutdown; v 'POST /shutdown, no token' "$1" /shutdown '-X POST'
  v 'GET /customers, XML only' "$1" /customers "-H 'Accept: application/xml'"; v 'GET /customers' "$1" /customers
  echo "  these answers, one line each (the request -> status, type, Allow, Content-Length · the WARN lines it added):$VSUM"
  echo "  WARN lines in this run's log, at Boot's default level: $(logl 0 WARN | grep -c . || true)"; }
verbs() {
  echo "before - the previous tree, the README's run line, port 19351:"
  start "$(at .harness/before 19351 "$R_RUN")"; up; ready 19351; verbs1 19351; stop 19351 .harness/before
  echo "after - after/, the same line, port 19350:"
  start "$(at .harness/after 19350 "$R_RUN")"; up; ready 19350; tline; verbs1 19350; stop 19350 .harness/after; }

# ---- seven: the comparison set, before and after; why, at DEBUG -------------------------------------------------------------------
seven_() { local n0 c
  echo "before - the previous tree, the README's run line, port 19351:"
  start "$(at .harness/before 19351 "$R_RUN")"; up; ready 19351; hdr 19351
  seven 19351 .harness/before; cp .harness/responses.m.txt .harness/s-before.txt
  echo "  its WARN lines, at Boot's default level: $(logl 0 WARN | grep -c . || true)"
  echo "after - after/, the same line, port 19350:"
  start "$(at .harness/after 19350 "$R_RUN")"; up; ready 19350; tline; hdr 19350
  seven 19350 .harness/after; cp .harness/responses.m.txt .harness/s-after.txt
  echo "  its WARN lines, at Boot's default level: $(logl 0 WARN | grep -c . || true)"; logl 0 WARN
  echo "  the seven, the timestamp masked:"; sed 's/^/    /' .harness/s-after.txt
  echo "before against after, the lines that differ (diff):"
  diff .harness/s-before.txt .harness/s-after.txt | sed 's/^/  /' || true
  echo "C (labelled) - why: after/ on the README's class-path line with the harness's Converters joined, Boot's web log group at DEBUG (the README's option), port 19352 - Spring MVC's JSON converters, then GET /customers and GET /shutdown, each alone:"
  start "$(hcp .harness/after 19352 probe.web.Converters "$WEBF")"; up; ready 19352
  c="curl -s http://127.0.0.1:19352/probe/converters"; echo "\$ $c"; (eval "$c") 2>&1 < /dev/null | sed 's/^/  /'
  n0=$(mark)
  echo "  the DEBUG lines before it - the start, the readiness polls (their number moves), /probe/converters: $( [ "$(logl 0 DEBUG "$n0" | grep -c . || true)" -gt 20 ] && echo 'more than 20' || echo '20 or fewer'), not shown"
  c=$(qc 19352 /customers); echo "\$ $c"; (eval "$c") 2>&1 < /dev/null | sed 's/^/  /'
  n1=$(mark); echo "  its lines at DEBUG, WARN and ERROR - all $(logl "$n0" 'DEBUG|WARN|ERROR' "$n1" | grep -c . || true) of them:"; logl "$n0" 'DEBUG|WARN|ERROR' "$n1"
  c=$(qc 19352 /shutdown); echo "\$ $c"; (eval "$c") 2>&1 < /dev/null | sed 's/^/  /'
  n2=$(mark); echo "  its lines at DEBUG, WARN and ERROR - all $(logl "$n1" 'DEBUG|WARN|ERROR' "$n2" | grep -c . || true) of them:"; logl "$n1" 'DEBUG|WARN|ERROR' "$n2"
  stop 19352 .harness/after; }

# ---- json: who writes TiffinBox's answers - a class taken away ----------------------------------------------------------------
# runl DIR 'LINE': a README line run from DIR as printed (eval), its output kept out of the capture, its exit code printed
runl() { local c="cd $1 && $2" e=0; echo "\$ $c"; (eval "$c") > .harness/runl.log 2>&1 < /dev/null || e=$?; echo "  exit $e"; [ $e = 0 ] || { cat .harness/runl.log >&3; die "the line failed: $c"; }; }
# frames: the stack frames in the run's log, bounded - TiffinBox's own, the JVM's and Tomcat's move with the class path
frames() { local n; n=$(grep -c "^$(printf '\t')at " .harness/run.out || true)
  if [ "$n" = 0 ]; then echo "  stack frames in its log: 0"; return; fi
  echo "  stack frames in its log: $( [ "$n" -gt 50 ] && echo 'over 50' || echo "$n"), not shown · its exceptions' first lines:"
  grep -E '^([a-z][a-z0-9_]*\.)+[A-Z][A-Za-z0-9_$]*(: .*)?$|^Caused by: ' .harness/run.out | sed 's/^/    /' || true; }
hang() { local n0 c
  runl "$1" "$R_HANG1"; runl "$1" "$3"
  start "$(at "$1" "$2" "$R_HANG3")"; up; ready "$2"
  n0=$(mark); c=$(url "$R_HANG4" "$2"); echo "\$ $c"; (eval "$c") 2>&1 < /dev/null | tsmask | sed 's/^/  /'
  c=$(url "$R_HANG4" "$2"); c=${c%/customers}/kitchen; echo "\$ $c"; (eval "$c") 2>&1 < /dev/null | sed 's/^/  /'
  settle; echo "  its lines at WARN and ERROR since readiness: $(logl "$n0" | grep -c . || true)"; logl "$n0"
  local o; o=$(grep -E ' tiffinbox +: (GET|UNKNOWN|POST) ' .harness/run.out | sed 's/^.* : //' | paste -sd'|' - | sed 's/|/ · /g')
  echo "  TiffinBox's own lines for an answer (logger tiffinbox, at DEBUG): ${o:-none}"
  frames; stop "$2" "$1"; }
json() {
  echo "before - the previous tree: the README's lines for a class the answer needs, deleted - Jackson 2's JDK14Util out of a copy of the extracted jar's lib/ - port 19351:"
  hang .harness/before 19351 "$R_HANG2"
  echo "after - after/, the same lines, port 19355:"
  hang .harness/after 19355 "$R_HANG2"
  echo "C (labelled) - after/, a Jackson 3 class deleted instead (this unit's line), port 19355:"
  hang .harness/after 19355 "$L_J3"; }

# ---- patterns: A/B/A' - a pattern the default parser refuses; then the literals ---------------------------------------------------
patterns() { local c n0 p
  echo "Boot's own metadata, in after/'s jar: $(meta .harness/after/$JARP spring.mvc.pathmatch.matching-strategy)"
  echo "A - after/ on the README's class-path line with the harness's MidPattern joined (a route on /probe/kitchen/**/today), port 19353:"
  fails "$(hcp .harness/after 19353 probe.web.MidPattern)"; now 19353
  echo "B - the same with the legacy parser (this unit's option):"
  start "$(hcp .harness/after 19353 probe.web.MidPattern "$ANTF")"; up; ready 19353
  n0=$(mark)
  for p in /probe/kitchen/a/b/today /probe/kitchen/today /customers /customers/; do c=$(qc 19353 "$p"); echo "\$ $c"; (eval "$c") 2>&1 < /dev/null | sed 's/^/  /'; done
  settle; echo "  WARN and ERROR lines in its log, from the start: $(logl 0 | grep -c . || true)"
  stop 19353 .harness/after
  echo "A' - A again:"
  fails "$(hcp .harness/after 19353 probe.web.MidPattern)"; now 19353
  echo "the literals - after/ on the class-path line with the harness's Patterns joined (/probe/menu/{day}, /probe/menu/today, /probe/files/{*rest}), the default parser, port 19352:"
  start "$(hcp .harness/after 19352 probe.web.Patterns)"; up; ready 19352
  n0=$(mark)
  for p in /customersXYZ /customers/ /customers.json /CUSTOMERS '/customers;x=1'; do c=$(qc 19352 "$p"); echo "\$ $c"; (eval "$c") 2>&1 < /dev/null | sed 's/^/  /'; done
  for p in /probe/menu/today /probe/menu/mon /probe/menu/mon/lunch /probe/files/a/b/c.txt; do c="curl -s -w ' %{http_code}\n' http://127.0.0.1:19352$p"; echo "\$ $c"; (eval "$c") 2>&1 < /dev/null | tsmask | sed 's/^/  /'; done
  post 19352 .harness/after /shutdownXYZ
  c=$(qc 19352 /customers); echo "\$ $c"; (eval "$c") 2>&1 < /dev/null | sed 's/^/  /'
  settle; echo "  WARN lines these requests added, at Boot's default level: $(logl "$n0" WARN | grep -c . || true)"
  stop 19352 .harness/after; }

# ---- timers: who times and logs each answer, before and after ----------------------------------------------------------------------
# t PORT PATH ['CURL OPTIONS']: the README's status-and-type line, printed and run; SENT counts the requests
SENT=0
t() { local c; c=$(qc "$@"); echo "\$ $c"; (eval "$c") 2>&1 < /dev/null | sed 's/^/  /'; SENT=$((SENT + 1)); }
treq() { SENT=0; t "$1" /customers; t "$1" '/customers?mealType=VEG'; t "$1" /customersXYZ; t "$1" /customers '-X DELETE'; t "$1" /customers '-X OPTIONS'; }
# tread PORT: the scrape's count lines for both timers - Boot's http_server_requests, TiffinBox's tiffinbox_requests - read until
# two reads half a second apart agree (up to 15 s); Actuator's own series left out and bounded (the readiness polls and these
# reads move their counts)
tread() { curl -s "http://127.0.0.1:$1/actuator/prometheus" | grep -E '^(http_server_requests_seconds_count|tiffinbox_requests_seconds_count)\{' | sort; }
timers1() { local i=0 a b=x all
  while [ $i -lt 30 ]; do all=$(tread "$1"); a=$(printf '%s\n' "$all" | grep -v 'uri="/actuator' || true); [ "$a" = "$b" ] && break; b=$a; sleep 0.5; i=$((i + 1)); done
  echo "  the scrape's count lines for both timers (Actuator's own series left out):"; printf '%s\n' "$a" | grep . | sed 's/^/    /' || true
  echo "  Actuator's own series, left out: $( [ "$(printf '%s\n' "$all" | grep -c 'uri="/actuator' || true)" -lt 10 ] && echo 'fewer than 10' || echo '10 or more') (the readiness polls and these reads move their counts)"
  echo "  requests sent: $SENT · counted by Boot's timer: $(printf '%s\n' "$a" | grep '^http_server_requests' | awk '{ s += $NF } END { print s + 0 }') · by TiffinBox's: $(printf '%s\n' "$a" | grep '^tiffinbox_requests' | awk '{ s += $NF } END { print s + 0 }') · Boot's series: $(printf '%s\n' "$a" | grep -c '^http_server_requests' || true) · TiffinBox's: $(printf '%s\n' "$a" | grep -c '^tiffinbox_requests' || true)"; }
timers() { local n0
  echo "before - the previous tree, the README's line with the kitchen at DEBUG, port 19351:"
  start "$(at .harness/before 19351 "$R_KDBG")"; up; ready 19351; n0=$(mark); treq 19351; settle
  echo "  TiffinBox's own lines for these answers (logger tiffinbox, at DEBUG): $(logl "$n0" DEBUG | grep -c ' tiffinbox: ' || true)"; logl "$n0" DEBUG | grep ' tiffinbox: ' || true
  timers1 19351; stop 19351 .harness/before
  echo "after - after/, the same line, port 19350:"
  start "$(at .harness/after 19350 "$R_KDBG")"; up; ready 19350; n0=$(mark); treq 19350; settle
  echo "  TiffinBox's own lines for these answers (logger tiffinbox, at DEBUG): $(logl "$n0" DEBUG | grep -c ' tiffinbox: ' || true) · any DEBUG line of the kitchen group's loggers (tiffinbox, com.tiffinbox…): $(logl "$n0" DEBUG | grep -cE ' (tiffinbox|com\.tiffinbox[A-Za-z0-9_.]*|c\.t\.[A-Za-z0-9_.]*): ' || true)"
  timers1 19350; stop 19350 .harness/after
  echo "C (labelled) - after/, Boot's web log group at DEBUG (the README's line), port 19350 - one request with a query string:"
  start "$(at .harness/after 19350 "$R_WEB")"; up; ready 19350; n0=$(mark)
  t 19350 '/customers?mealType=VEG'; settle
  echo "  the DispatcherServlet's line for it (level logger: message): $(logl "$n0" DEBUG | grep 'DispatcherServlet: GET ' | sed 's/^ *//')"
  echo "  its other DEBUG lines: $(logl "$n0" DEBUG | grep -vc 'DispatcherServlet: GET ' || true), not shown"
  stop 19350 .harness/after; }

# ---- stop: POST /shutdown, a controller method - A/B/A' ---------------------------------------------------------------------------
stop_() {
  echo "Boot's own metadata, in after/'s jar: $(meta .harness/after/$JARP server.shutdown)"
  echo "A - Boot's default: after/, the README's run line, port 19356 - one request, then POST /shutdown:"
  start "$(at .harness/after 19356 "$R_RUN")"; up; ready 19356; t 19356 /customers; stop 19356 .harness/after; glines
  echo "B - the same, Boot's shutdown made immediate (this unit's option):"
  start "$(at .harness/after 19356 "$L_IMM")"; up; ready 19356; t 19356 /customers; stop 19356 .harness/after; glines
  echo "A' - A again:"
  start "$(at .harness/after 19356 "$R_RUN")"; up; ready 19356; t 19356 /customers; stop 19356 .harness/after; glines; }

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
  echo "  the shell is now in: $(where "$d1") · the copy's own token in its log: $(raw "$(head -1 .harness/mine/after/$TF)" .harness/ex-readme.log) times"
  echo "the solution's $(printf '%s\n' "$sol" | grep -c .) lines, next, in the same shell:"
  printf '%s\n' "$sol" | sed 's/^/  $ /'
  echo "  exit $e2 · what they printed:"; sed 's/^/    /' .harness/ex-sol.out
  echo "  the shell is now in: $(where "$d2") · the copy's own token in its log: $(raw "$(head -1 .harness/mine/after/$TF)" .harness/mine/run.log) times · listening on 19359 now: $(listeners 19359)"; }

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
# aotmeta DIR: Spring's generated reachability metadata in DIR's web module (its AOT step's own file) - the reflection entries,
# and the entry for TiffinBox's Customer record: what it registers
AOTF=tiffinbox-web/target/spring-aot/main/resources/META-INF/native-image/com.tiffinbox/tiffinbox-web/reachability-metadata.json
aotmeta() { python3 - "$1/$AOTF" <<'PY'
import json, sys
d = json.load(open(sys.argv[1])); refl = d.get("reflection", [])
c = [e for e in refl if e.get("type") == "com.tiffinbox.Customer"]
def what(e):
    k = [x for x in ("allDeclaredFields", "allDeclaredConstructors") if e.get(x)]
    return " · ".join(["all declared fields" if x == "allDeclaredFields" else "all declared constructors" for x in k] + ["%d methods (%s)" % (len(e.get("methods", [])), " ".join(sorted(m["name"] for m in e.get("methods", []))))])
print("  Spring's generated metadata (%s): reflection entries naming com.tiffinbox.Customer: %d%s" % (sys.argv[1].split("/target/", 1)[1], len(c), (" - " + what(c[0])) if c else ""))
PY
}
# lbk LABEL: a form's loopback, read off its own block of this capture so far - every "listens on:" line of the block says
# "loopback only: yes" (the image: published on 127.0.0.1 alone, docker port)
lbk() { awk -v a="$1" 'index($0, a) == 1 { f = 1; next } /^[1-4] the / { f = 0 } f' .harness/cap.raw > .harness/blk.txt
  if [ "$1" = '4 the image' ]; then grep -qE '^  docker port: 18425/tcp -> 127\.0\.0\.1:19357$' .harness/blk.txt && [ "$(grep -c '^  docker port: ' .harness/blk.txt)" = 1 ] && echo yes || echo no
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
forms() {
  echo "the native build - after/ copied to .harness/nat with a config tree; the README's two Maven lines, offline; \$GRAALVM_HOME names the GraalVM:"
  copy after .harness/nat
  nbuild .harness/nat; nlines .harness/nat.native.log; nresult .harness/nat.native.log
  echo "  file: $(file -b ".harness/nat/$BIN" | sed 's/ [A-Za-z0-9_]*$//') · the demo token in its bytes: $(raw "$TOKEN" ".harness/nat/$BIN")"
  echo "what Spring's AOT step registered for the native build - the record the routes return, with no hint in the tree (code lines naming @RegisterReflectionForBinding in its Java sources: $(find .harness/nat/tiffinbox-web/src .harness/nat/tiffinbox-core/src -name '*.java' | sort | while IFS= read -r f; do code "$f"; done | grep -c 'RegisterReflectionForBinding' || true)):"
  aotmeta .harness/nat
  echo "  C (labelled) - a copy of after/ whose customers() returns Object (its one line changed), built with the profile native (the README's line) - Spring's AOT step only:"
  copy after .harness/obj
  sed 's/^    List<Customer> customers() throws Exception {$/    Object customers() throws Exception {/' "after/$W/TiffinBoxServer.java" > ".harness/obj/$W/TiffinBoxServer.java"
  echo "  \$ diff -U0 after/$W/TiffinBoxServer.java .harness/obj/$W/TiffinBoxServer.java"; diff -U0 "after/$W/TiffinBoxServer.java" ".harness/obj/$W/TiffinBoxServer.java" | tail -n +3 | sed 's/^/    /' || true
  pbuild .harness/obj "the copy, the profile native (Spring's AOT step)" "$R_PNAT" | sed 's/^/  /'
  aotmeta .harness/obj | sed 's/^/  /'
  echo "1 the jar - .harness/after, the README's run line, port 19350:"
  start "$(at .harness/after 19350 "$R_RUN")"; up; ready 19350; tline; seven 19350 .harness/after; glines
  echo "2 the AOT jar - .harness/nat (the profile native's jar), the README's AOT line, port 19354:"
  start "$(at .harness/nat 19354 "$R_AOTRUN")"; up; ready 19354; tline; seven 19354 .harness/nat; glines
  echo "3 the binary - .harness/nat, the README's line, port 19358:"
  start "$(at .harness/nat 19358 "$R_BIN")"; up; ready 19358; tline; seven 19358 .harness/nat; glines
  echo "  the binary at DEBUG - the README's line with Boot's web group and the kitchen at DEBUG, each line its thread's whole name and the message, port 19358:"
  start "$(at .harness/nat 19358 "$R_BINDBG")"; up; ready 19358
  t 19358 /customers; settle
  echo "  its line for GET /customers that names the handler: $(grep -E '^[^ ]+ Mapped to com\.tiffinbox\.web\.TiffinBoxServer#customers\(\)$' .harness/run.out | tnum | paste -sd'|' -) · its other lines - the start, the readiness polls (their number moves), the rest of this request: $( [ "$(grep -cvE '^[^ ]+ Mapped to com\.tiffinbox\.web\.TiffinBoxServer#customers\(\)$' .harness/run.out || true)" -gt 40 ] && echo 'more than 40' || echo '40 or fewer'), not shown"
  stop 19358 .harness/nat
  echo "4 the image - after/'s Dockerfile (the README's build line, this script's tag), the README's run line with your user, published on 127.0.0.1:19357:"
  image
  dstart "$(drun .harness/after 19357)"; ready 19357 "$BOX"; dbind 19357
  echo "\$ \$CURLSET 19357 .harness/after/$TF"
  "$CURLSET" 19357 ".harness/after/$TF" | grep ' -> ' > .harness/responses.txt || true
  tsmask < .harness/responses.txt > .harness/responses.m.txt
  grep '^POST ' .harness/responses.m.txt | sed 's/^/  /' || echo "  (no POST line)"
  dgone "$BOX"; [ "$(listeners 19357)" = 0 ] || die "something still listens on 19357"
  echo "  exit $LASTE · the seven responses: $(wc -l < .harness/responses.m.txt | tr -d ' ') lines · lines the timestamp mask changed: $(diff .harness/responses.txt .harness/responses.m.txt | grep -c '^<' || true) · md5 $(md5 -q .harness/responses.m.txt)"
  dlog "$BOX"; echo "  its log (docker logs): Boot's first line: $(first .harness/run.out) · the demo token 0 times · X-Shutdown-Token 0 times"; glines
  docker rm "$BOX" > /dev/null
  echo "four forms, one tree: the seven (masked) $(grep -cE '^  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 2 · md5 87ca7efc8584dcccd40e6b956db1de9b$' .harness/cap.raw) of 4 times 87ca7efc8584dcccd40e6b956db1de9b"
  echo "  loopback, form by form: the jar $(lbk '1 the jar') · the AOT jar $(lbk '2 the AOT jar') · the binary $(lbk '3 the binary') (its DEBUG run among them) · the image, published on 127.0.0.1 alone $(lbk '4 the image')"; }

cap change change
cap scan scan
cap rows rows
cap verbs verbs
cap seven seven_
cap json json
cap patterns patterns
cap timers timers
cap stop stop_
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
# when it was read: fails(), logtok(), dlog()), anything this unit ships for reading, nor the binary this run built
for f in .harness/raw-*; do [ "$(cat "$f")" = 0 ] || die "a capture's raw output held the demo token ($f)"; done
NBIN=0
for f in .r-*.out README.md exercise/README.md exercise/solution/SOLUTION.md receipts.md5 harness/shutdown.sh harness/table.py harness/probe/web/*.java .harness/nat/$BIN; do
  [ -f "$f" ] || continue; case $f in .harness/nat*) NBIN=$((NBIN + 1)) ;; esac
  [ "$(raw "$TOKEN" "$f")" = 0 ] || die "$f holds the demo token, raw"; done
[ "$NBIN" = 1 ] || die "one binary was built, $NBIN were checked"
for f in .r-*.out; do ! grep -qE '/Users/|/private/|/home/|/var/folders/' "$f" || die "$f holds an absolute path"; [ -z "${GRAALVM_HOME:-}" ] || ! grep -qF "$GRAALVM_HOME" "$f" || die "$f holds the GraalVM's folder"; ! grep -qE 'c[0-9]-unit[0-9]|unit ?[0-9]' "$f" || die "$f holds a unit number"; ! grep -qE ' (with PID|started by) ' "$f" || die "$f holds Boot's process line"; ! grep -qE '^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T|"timestamp":"?[0-9]|timestamp=[A-Z0-9]|(exec|handler|task|utility)-[0-9]' "$f" || die "$f holds a log line's time, a timestamp or a thread's number"; ! grep -q "^$(printf '\t')at " "$f" || die "$f shows a stack frame"; ! grep -qE 'sha256:[0-9a-f]{64}' "$f" || [ "$(grep -cE 'sha256:[0-9a-f]{64}' "$f")" = "$(grep -cE 'eclipse-temurin(:25-jre)?@sha256:[0-9a-f]{64}' "$f")" ] || die "$f holds an ID other than the base image's digest"; ! grep -qE ':8080([^0-9]|$)' "$f" || die "$f shows a bind on 8080"; done
for f in receipts.sh README.md exercise/README.md exercise/solution/SOLUTION.md harness/shutdown.sh; do [ -f "$f" ] || continue; ! grep -qE "exposure\.include='?\*" "$f" || die "$f exposes every endpoint (R.42)"; ! grep -E 'server\.error\.' "$f" | grep -vE '^ *#' > /dev/null || die "$f names one of Boot 3's error keys (server, then error) - Boot 4.1 reads only spring.web.error.* (S2.13)"; done
for f in receipts.sh README.md exercise/README.md exercise/solution/SOLUTION.md; do [ -f "$f" ] || continue; ! grep -E 'docker run ' "$f" | grep -vE '^#' | grep -E ' -p "?[0-9]+:' > /dev/null || die "$f publishes a port on every address (-p without 127.0.0.1:)"; done
NL=$(cat .r-*.out | grep -cxF "  its log: the demo token 0 times · X-Shutdown-Token 0 times" || true)
echo "  token: 0 raw copies in $(ls .harness/raw-* | wc -l | tr -d ' ') raw capture runs, in $(ls .r-*.out | wc -l | tr -d ' ') captures, in the logs of every start that ended by itself ($FLOGS here), every JVM that served ($LOGS here; the published captures' $NL), every container ($CLOGS here), the image's layers (forms), the READMEs, the harness, the exercise, receipts.md5 and the binary; no absolute path, no GraalVM folder, no unit number, no process line, no log time, no timestamp, no thread number, no stack frame, no ID but the base image's digest, no 8080 in any capture; every docker run publishes on 127.0.0.1 only"

S571='571faaea42e87e85add8c9548c64c961'; S87C='87ca7efc8584dcccd40e6b956db1de9b'
SEVEN0="  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 1 · md5 $S571"
SEVEN1="  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 2 · md5 $S87C"
STOPPED() { printf '  exit 0 · listening on %s now: 0\n' "$1"; }
LB() { printf '  listens on: 127.0.0.1:%s · loopback only: yes\n' "$1"; }
SHUT='  POST /shutdown -> 200 application/json · Content-Length: 17 · {"stopping":true} · curl exit 0'
RES="DefaultHandlerExceptionResolver: Resolved [org.springframework.web."

# "At Component becomes at Rest Controller; each at Route becomes at Get Mapping or at Post Mapping ... Each method names its return
#  type. The router's two files are deleted, and its ten lines drop to zero ... a controller ... whatever they return is the answer."
x change '^  built the previous tree · offline: yes · exit 0$'; x change '^  built after/ · offline: yes · exit 0$'
[ "$(n change '^  (Files|Only in) ')" = 4 ] || die "change: four paths differ"
x change '^  Only in \.harness/before/tiffinbox-web/src/main/java/com/tiffinbox/web: Route\.java$'; x change '^  Only in \.harness/before/tiffinbox-web/src/main/java/com/tiffinbox/web: RouteMapping\.java$'
x change '^  Route\.java: 24 -> deleted$'; x change '^  RouteMapping\.java: 20 -> deleted$'; x change '^  TiffinBoxServer\.java: 285 -> 176$'
x change '^    the router.s parts \(@Route, scanRoutes, its TreeMap, invoke\): 10 -> 0$'
x change '^    the hint \(@RegisterReflectionForBinding\): 2 -> 0 · '
x change "^    TiffinBox's own timer \(tiffinbox\.requests, Timer, MeterRegistry\): [1-9][0-9]* -> 0 · a DEBUG line of TiffinBox's \(LOG\.log\(DEBUG, …\)\): 2 -> 0\$"
x change "^    its own Jackson 2 mapper \(ObjectMapper, JSON\.write…\): 3 -> 0 · Spring MVC's mapping annotations \(@RestController, @GetMapping, @PostMapping\): 0 -> 6\$"
x change ' - the 6 hunks that change a class or route annotation, whole:$'
for l in '    -@Component' '    -@RegisterReflectionForBinding(Customer.class)' '    +@RestController' '    -    @Route(path = "/customers")' '    -    Object customers() throws Exception {' '    +    @GetMapping("/customers")' '    +    List<Customer> customers() throws Exception {' '    +    Map<String, Object> revenue() throws Exception {' '    +    Map<String, Object> dashboard() throws Exception {' '    +    Map<String, Object> kitchen() {' '    -    @Route(path = "/shutdown", method = "POST")' '    +    @PostMapping("/shutdown")' '    +    Map<String, Object> shutdown(HttpServletRequest request, HttpServletResponse response) {' '    +        Thread.ofPlatform().start(context::close);'; do
  grep -qxF -- "$l" .r-change.out || die "change: the hunk line $l"; done
[ "$(n change '^    \+    @GetMapping\("/[a-z]+"\)$')" = 4 ] && [ "$(n change '^    -    @Route\(path = "/[a-z]+"\)$')" = 4 ] || die "change: four @Route -> @GetMapping"
CB=$(blk change '$ cd .harness/before && java -cp' '$ cd .harness/after && java -cp'); CA=$(blk change '$ cd .harness/after && java -cp' 'the executable jar')
has "$CB" '  TiffinBoxServer - as Spring reads it (AnnotatedElementUtils.hasAnnotation): @RestController no · @Controller no · @Component yes · @ResponseBody no' "change: the class before"
has "$CA" '  TiffinBoxServer - the annotations on the class itself: @RestController' "change: the class's one annotation"
has "$CA" '  TiffinBoxServer - as Spring reads it (AnnotatedElementUtils.hasAnnotation): @RestController yes · @Controller yes · @Component yes · @ResponseBody yes' "change: a controller, a component, a response body"
has "$CA" '  @RestController - the annotations it carries (java.lang.annotation'"'"'s left out): @Controller @ResponseBody' "change: @RestController's own"
has "$CA" '  @Controller - the annotations it carries (java.lang.annotation'"'"'s left out): @Component' "change: @Controller's own"
x change '^the executable jar.s BOOT-INF/lib: 58 jars -> 58 · removed 0 · added 0 · Jackson 2 \(jackson-databind 2\.x\) 1 -> 1 · Jackson 3 \(jackson-databind 3\.x\) 1 -> 1$'
x change '^  tiffinbox-core against the previous tree.s \(diff -rq -x target\): 0 files differ$'
[ "$(n change "^  [A-Za-z0-9_./-]+ against the previous tree's, byte for byte: the same\$")" = 12 ] || die "change: twelve files the same"
echo "  change: 4 paths; Route 24 and RouteMapping 20 deleted; TiffinBoxServer 285 -> 176, the router's lines 10 -> 0, the hint, the timer, the DEBUG line and Jackson 2's mapper out, 6 mapping annotations in; 6 annotation hunks; the class: @RestController = @Controller (@Component) + @ResponseBody; lib 58 -> 58; 12 files the same"

# "Before, TiffinBox logged its own route lines at start. Now Spring MVC's handler mapping ... lists TiffinBox's five, seven mappings
#  in all, before Tomcat starts ... The routing table still has fourteen rows ... a verb, a pattern and the method."
SB=$(blk scan 'before - ' 'after - '); SA=$(blk scan 'after - ' '')
has "$SB" "  TiffinBox's own lines that name a route, before Boot's started line (logger tiffinbox; the route lines sorted): 5 + 1" "scan before: TiffinBox's route lines"
for r in 'GET /customers -> customers()' 'GET /dashboard -> dashboard()' 'GET /kitchen -> kitchen()' 'GET /revenue -> revenue()' 'POST /shutdown -> shutdown()'; do has "$SB" "    tiffinbox: route $r" "scan before: $r"; done
has "$SB" "    s.w.s.m.m.a.RequestMappingHandlerMapping: DEBUG 2 mappings in 'requestMappingHandlerMapping'" "scan before: Boot's two"
has "$SA" "  TiffinBox's own lines that name a route, before Boot's started line (logger tiffinbox; the route lines sorted): 0 + 0" "scan after: none of TiffinBox's"
has "$SA" '      c.t.w.TiffinBoxServer:' "scan after: TiffinBox's block"
for r in '{GET [/customers]}: customers()' '{GET [/dashboard]}: dashboard()' '{GET [/kitchen]}: kitchen()' '{GET [/revenue]}: revenue()' '{POST [/shutdown]}: shutdown(HttpServletRequest,HttpServletResponse)'; do has "$SA" "        $r" "scan after: $r"; done
has "$SA" '      o.s.b.w.a.e.BasicErrorController:' "scan after: Boot's error controller's block"; [ "$(printf '%s\n' "$SA" | grep -cE '^        \{ \[/error\]')" = 2 ] || die "scan after: Boot's two error routes"
has "$SA" "    s.w.s.m.m.a.RequestMappingHandlerMapping: DEBUG 7 mappings in 'requestMappingHandlerMapping'" "scan after: seven mappings"
for b in "$SB" "$SA"; do printf '%s\n' "$b" | grep -qE "^  then Boot's started line - logger: message: o\.s\.boot\.tomcat\.TomcatWebServer: Tomcat started on port 1935[01] " || die "scan: the registration comes before Boot's started line"; done
RB=$(blk rows 'before - ' 'after - '); RA=$(blk rows 'after - ' '')
for b in "$RB" "$RA"; do printf '%s\n' "$b" | grep -qE '^  dispatcherServlets · dispatcherServlet: 14 rows, ' || die "rows: fourteen rows"; done
has "$RB" "  TiffinBox's rows (its own handler, or a TiffinBoxServer method): 5 · naming a verb: 0" "rows before: no verb"
has "$RB" '    6  /customers -> TiffinBox route /customers' "rows before: a path and a handler's name"; has "$RB" '  /customers - 2 keys: handler predicate' "rows before: two keys"
has "$RA" "  TiffinBox's rows (its own handler, or a TiffinBoxServer method): 5 · naming a verb: 5 (GET 4 POST 1)" "rows after: five verbs"
has "$RA" '    6  {GET [/customers]} -> TiffinBoxServer#customers()' "rows after: a verb, a pattern, the method"; has "$RA" '    details.requestMappingConditions.methods = ["GET"]' "rows after: GET"
has "$RA" '    details.handlerMethod.descriptor = ()Ljava/util/List;' "rows after: customers() returns a List"
echo "  scan: before TiffinBox's 5 route lines + routes mapped, 2 mappings; after 0 of TiffinBox's, its 5 at TRACE + Boot's 2 = 7, before Boot's started line; rows: 14 both, TiffinBox's 5 with 0 -> 5 verbs (GET 4 POST 1)"

# "HEAD ... it was a four oh five, now it's two hundred. OPTIONS lists GET, HEAD and OPTIONS. DELETE is still four oh five, but the Allow
#  header now says GET ... XML used to get JSON anyway. Now it's a four oh six ... the four oh five and the four oh six each add one
#  warning line ... TiffinBox's own four oh five added none." Read off each run's own table: the request, its answer, its WARN lines.
VB=$(blk verbs 'before - ' 'after - '); VA=$(blk verbs 'after - ' '')
vl() { printf '    %-25s -> %s · WARN lines: %s' "$1" "$2" "$3"; }
for p in "HEAD /customers|405 application/json · Allow: none · Content-Length: 30|0|200 application/json · Allow: none · Content-Length: 282|0" \
         "OPTIONS /customers|405 application/json · Allow: none · Content-Length: 30|0|200 (no type) · Allow: GET,HEAD,OPTIONS · Content-Length: 0|0" \
         "DELETE /customers|405 application/json · Allow: none · Content-Length: 30|0|405 application/json · Allow: GET · Content-Length: none|1" \
         "GET /shutdown|405 application/json · Allow: none · Content-Length: 30|0|405 application/json · Allow: POST · Content-Length: none|1" \
         "POST /shutdown, no token|403 application/json · Allow: none · Content-Length: 21|0|403 application/json · Allow: none · Content-Length: 21|0" \
         "GET /customers, XML only|200 application/json · Allow: none · Content-Length: 282|0|406 (no type) · Allow: none · Content-Length: 0|1" \
         "GET /customers|200 application/json · Allow: none · Content-Length: 282|0|200 application/json · Allow: none · Content-Length: 282|0"; do
  IFS='|' read -r lab b0 w0 a1 w1 <<VL
$p
VL
  has "$VB" "$(vl "$lab" "$b0" "$w0")" "verbs before: $lab"; has "$VA" "$(vl "$lab" "$a1" "$w1")" "verbs after: $lab"; done
[ "$(printf '%s\n' "$VB" | grep -c ' · WARN lines: ')" = 7 ] && [ "$(printf '%s\n' "$VA" | grep -c ' · WARN lines: ')" = 7 ] || die "verbs: seven answers in each table"
has "$VA" "    WARN .w.s.m.s.$RES""HttpRequestMethodNotSupportedException: Request method 'DELETE' is not supported]" "verbs: the DELETE's WARN, Spring MVC's"
has "$VA" "    WARN .w.s.m.s.$RES""HttpRequestMethodNotSupportedException: Request method 'GET' is not supported]" "verbs: GET /shutdown's WARN"
has "$VA" "    WARN .w.s.m.s.$RES""HttpMediaTypeNotAcceptableException: No acceptable representation]" "verbs: the 406's WARN"
has "$VB" "  WARN lines in this run's log, at Boot's default level: 0" "verbs before: 0 WARN"; has "$VA" "  WARN lines in this run's log, at Boot's default level: 3" "verbs after: 3 WARN"
echo "  verbs: HEAD 405 -> 200 (282); OPTIONS 405 -> 200 Allow GET,HEAD,OPTIONS; DELETE 405 -> 405 Allow GET; GET /shutdown -> Allow POST; 403 both; XML 200 -> 406; WARN 0 -> 1 per 405 and 406, 0 for HEAD, OPTIONS, 403"

# "Six lines match, byte for byte. GET shutdown changes ... Spring answers four oh five itself, Allow POST, and Boot's error controller
#  writes the body. Masked, that's our new fingerprint, and the seven now log one warning." / "Spring's message converter ... Jackson
#  three ... Remove one of Jackson two's, customers still answers. Remove one of Jackson three's, it's a five hundred."
x seven "^$SEVEN0\$"; x seven "^$SEVEN1\$"
[ "$(n seven "^  its status line: \[HTTP/1\.1 200 \] · its headers, by name: Content-Type Content-Length Date\$")" = 2 ] || die "seven: the status line and header names, the same before and after"
[ "$(n seven '^  [0-9]+c[0-9]+$')" = 1 ] && x seven '^  6c6$' || die "seven: one line differs, the sixth"
x seven '^  < GET   /shutdown   -> 405 application/json  \{"error":"method not allowed"\}$'
x seven '^  > GET   /shutdown   -> 405 application/json  \{"timestamp":"…","status":405,"error":"Method Not Allowed","path":"/shutdown"\}$'
[ "$(n seven '^  [<>] ')" = 2 ] || die "seven: two lines in the diff"
VS0=$(blk seven 'before - ' 'after - '); VS1=$(blk seven 'after - ' 'before against after')
has "$VS0" "  its WARN lines, at Boot's default level: 0" "seven before: 0 WARN"; has "$VS1" "  its WARN lines, at Boot's default level: 1" "seven after: one WARN"
has "$VS1" "    WARN .w.s.m.s.$RES""HttpRequestMethodNotSupportedException: Request method 'GET' is not supported]" "seven after: GET /shutdown's WARN"
VC=$(blk seven 'C (labelled)' '')
has "$VC" '  converters: 6 · for application/json: 1' "seven C: the converters"; has "$VC" '  org.springframework.http.converter.json.JacksonJsonHttpMessageConverter · its mapper: tools.jackson.databind.json.JsonMapper' "seven C: Jackson 3's mapper"
has "$VC" '    DEBUG s.w.s.m.m.a.RequestMappingHandlerMapping: Mapped to com.tiffinbox.web.TiffinBoxServer#customers()' "seven C: the method"
printf '%s\n' "$VC" | grep -qE '^    DEBUG m\.m\.a\.RequestResponseBodyMethodProcessor: Writing \[\[Customer\[name=Meera, ' || die "seven C: Writing [[Customer[..."
has "$VC" "    DEBUG m.m.a.RequestResponseBodyMethodProcessor: Using 'application/json', given [*/*] and supported [application/json, application/*+json]" "seven C: Using 'application/json'"
has "$VC" '    DEBUG o.s.web.servlet.DispatcherServlet: Completed 405 METHOD_NOT_ALLOWED' "seven C: 405"; has "$VC" '    DEBUG o.s.web.servlet.DispatcherServlet: "ERROR" dispatch for GET "/error", parameters={}' "seven C: the error dispatch"
has "$VC" '    DEBUG s.w.s.m.m.a.RequestMappingHandlerMapping: Mapped to org.springframework.boot.webmvc.autoconfigure.error.BasicErrorController#error(HttpServletRequest)' "seven C: Boot's error controller"
has "$VC" '    DEBUG o.s.w.s.m.m.a.HttpEntityMethodProcessor: Writing [{timestamp=…, status=405, error=Method Not Allowed, path=/shutdown}]' "seven C: its body"
JB=$(blk json 'before - ' 'after - '); JA=$(blk json 'after - ' 'C (labelled)'); JC=$(blk json 'C (labelled)' '')
has "$JB" '  {"error":"ClassNotFoundException"} 500' "json before: Jackson 2's class out: TiffinBox's 500"; has "$JB" '    ERROR tiffinbox: GET /customers failed' "json before: TiffinBox's ERROR"
has "$JA" '  [{"name":"Meera","mealsPerDay":1,"pricePerMeal":150,"mealType":"NON_VEG"},{"name":"Priya","mealsPerDay":1,"pricePerMeal":120,"mealType":"VEGAN"},{"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"},{"name":"Sunil","mealsPerDay":3,"pricePerMeal":100,"mealType":"VEG"}] 200' "json after: Jackson 2's class out, /customers 200"
has "$JA" '  its lines at WARN and ERROR since readiness: 0' "json after: nothing logged"
has "$JC" '  {"timestamp":"…","status":500,"error":"Internal Server Error","path":"/customers"} 500' "json C: Jackson 3's class out: Boot's 500"
has "$JC" '    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: Servlet.service() for servlet [dispatcherServlet] in context with path [] threw exception [Handler dispatch failed: java.lang.NoClassDefFoundError: tools/jackson/databind/util/RecordUtil] with root cause' "json C: Tomcat's ERROR line"
for b in "$JB" "$JA" "$JC"; do has "$b" '  {"ordersCooked":120,"ordersValue":24300} 200' "json: /kitchen answers"; done
printf '%s\n' "$JC" | grep -qxF '  stack frames in its log: over 50, not shown · its exceptions'"'"' first lines:' || die "json C: the trace, bounded"
echo "  seven: before 571faaea... (1 masked), after 87ca7efc... (2 masked); 6c6, GET /shutdown, Spring's 405; status line and headers the same; WARN 0 -> 1; C: 6 converters, Jackson 3's JsonMapper, Mapped to ...#customers(), the error dispatch to BasicErrorController; json: Jackson 2's class out 500 -> 200, Jackson 3's out 500 (Handler dispatch failed)"

# "Customers X Y Z, a trailing slash, dot json, capitals: four oh four, all of them. Post shutdown X Y Z, token and all, is a four oh
#  four, and TiffinBox keeps serving ... a fixed word beats a hole beside it, and star rest takes the rest" / "Two stars in the
#  middle ... exit one, a caret under the stars, and Boot's action names the legacy parser. B ... the route answers. A again: refused."
x patterns "^Boot's own metadata, in after/'s jar: spring\.mvc\.pathmatch\.matching-strategy default path-pattern-parser \(spring-boot-webmvc-4\.1\.1\.jar\)\$"
PA=$(blk patterns 'A - after/' 'B - the same'); PB=$(blk patterns 'B - the same' "A' - A again"); PA2=$(blk patterns "A' - A again" 'the literals'); PL=$(blk patterns 'the literals' '')
for b in "$PA" "$PA2"; do has "$b" '  exit 1' "patterns A/A': exit 1"; has "$b" "  its log, read after it exited: APPLICATION FAILED TO START 1 · stack frames 0 · Caused by: 0 · frames folded as common 0 · Boot's Tomcat lines 1" "patterns A/A': no frame"
  has "$b" '  Invalid mapping pattern detected:' "patterns A/A'"; has "$b" '  /probe/kitchen/**/today' "patterns A/A': the pattern"; has "$b" '                 ^' "patterns A/A': the caret under **"
  has "$b" '  {*...} or ** pattern elements should be placed at the start or end of the pattern' "patterns A/A': the rule"
  has "$b" "  Fix this pattern in your application or switch to the legacy parser implementation with 'spring.mvc.pathmatch.matching-strategy=ant_path_matcher'." "patterns A/A': Boot's action"
  has "$b" '  listening now: 19353 0' "patterns A/A': never bound"; done
[ "$(printf '%s\n' "$PA" | grep '^\$ cd')" = "$(printf '%s\n' "$PA2" | grep '^\$ cd')" ] || die "patterns: A' is not A's command"
printf '%s\n' "$PB" | grep -q -- ' --spring\.mvc\.pathmatch\.matching-strategy=ant-path-matcher$' || die "patterns B: the flag"
[ "$(aft "\$ curl -s -o /dev/null -w '%{http_code} %{content_type}\n' http://127.0.0.1:19353/probe/kitchen/a/b/today" "$PB")" = '  200 text/plain;charset=UTF-8' ] || die "patterns B: the mid-path route answers"
has "$PB" '  WARN and ERROR lines in its log, from the start: 0' "patterns B: 0 WARN"; has "$PB" "$(STOPPED 19353)" "patterns B: exit 0"
for p in /customersXYZ /customers/ /customers.json /CUSTOMERS; do [ "$(aft "\$ curl -s -o /dev/null -w '%{http_code} %{content_type}\n' http://127.0.0.1:19352$p" "$PL")" = '  404 application/json' ] || die "patterns: $p 404"; done
[ "$(aft "\$ curl -s -o /dev/null -w '%{http_code} %{content_type}\n' 'http://127.0.0.1:19352/customers;x=1'" "$PL")" = '  200 application/json' ] || die "patterns: /customers;x=1 200"
has "$PL" '  the literal route: today' "patterns: a literal beats a variable"; has "$PL" '  day=mon' "patterns: the variable"; has "$PL" '  rest=/a/b/c.txt' "patterns: {*rest}"
has "$PL" '  POST /shutdownXYZ -> 404 application/json · Content-Length: none · {"timestamp":"…","status":404,"error":"Not Found","path":"/shutdownXYZ"} · curl exit 0' "patterns: POST /shutdownXYZ with the token: 404"
[ "$(printf '%s\n' "$PL" | awk '/POST \/shutdownXYZ -> / { f = 1; next } f && /^  [0-9][0-9][0-9] / { print; exit }')" = '  200 application/json' ] || die "patterns: still serving after POST /shutdownXYZ"
has "$PL" '  WARN lines these requests added, at Boot'"'"'s default level: 0' "patterns: the 404s logged no WARN"
echo "  patterns: default path-pattern-parser; A/A' exit 1, the caret, 0 frames, the legacy parser named; B 200, 0 WARN; 4 near paths 404, ;x=1 200, literal over variable, {*rest}; POST /shutdownXYZ 404 with the token, still serving, 0 WARN"

# "Boot's timer counts by pattern: customers, with or without a query string, is one series; a four oh four is slash star star; a
#  wrong verb, and OPTIONS, are UNKNOWN. And Spring's debug line prints the request as the client typed it, values masked."
TB=$(blk timers 'before - ' 'after - '); TA=$(blk timers 'after - ' 'C (labelled)'); TC=$(blk timers 'C (labelled)' '')
has "$TB" "  TiffinBox's own lines for these answers (logger tiffinbox, at DEBUG): 4" "timers before: 4 lines of TiffinBox's"
has "$TB" '    tiffinbox_requests_seconds_count{route="GET /customers",status="200"} 2' "timers before: TiffinBox's timer"
has "$TB" "  requests sent: 5 · counted by Boot's timer: 5 · by TiffinBox's: 4 · Boot's series: 4 · TiffinBox's: 2" "timers before: the sums"
has "$TA" "  TiffinBox's own lines for these answers (logger tiffinbox, at DEBUG): 0 · any DEBUG line of the kitchen group's loggers (tiffinbox, com.tiffinbox…): 0" "timers after: the kitchen quiet"
has "$TA" '    http_server_requests_seconds_count{error="none",exception="none",method="GET",outcome="SUCCESS",status="200",uri="/customers"} 2' "timers after: one series for /customers, with and without a query"
has "$TA" '    http_server_requests_seconds_count{error="none",exception="none",method="GET",outcome="CLIENT_ERROR",status="404",uri="/**"} 1' "timers after: the 404 under /**"
has "$TA" '    http_server_requests_seconds_count{error="none",exception="none",method="DELETE",outcome="CLIENT_ERROR",status="405",uri="UNKNOWN"} 1' "timers after: the 405 UNKNOWN"
has "$TA" '    http_server_requests_seconds_count{error="none",exception="none",method="OPTIONS",outcome="SUCCESS",status="200",uri="UNKNOWN"} 1' "timers after: OPTIONS UNKNOWN"
has "$TA" "  requests sent: 5 · counted by Boot's timer: 5 · by TiffinBox's: 0 · Boot's series: 4 · TiffinBox's: 0" "timers after: TiffinBox's timer gone"
! printf '%s\n' "$TA" | grep -q 'tiffinbox_requests' || die "timers after: a tiffinbox_requests line"
has "$TC" '  the DispatcherServlet'"'"'s line for it (level logger: message): DEBUG o.s.web.servlet.DispatcherServlet: GET "/customers?mealType=VEG", parameters={masked}' "timers C: the request as typed, parameters masked"
echo "  timers: before TiffinBox's 4 lines, its timer 2 series; after 0 lines, no tiffinbox_requests; Boot's: /customers x2 (one with a query) one series, /** 404, UNKNOWN for DELETE 405 and OPTIONS 200; C GET \"/customers?mealType=VEG\", parameters={masked}"

# "Shutdown is a controller method now: it starts a thread that closes the context, and returns its answer. That answer arrived with
#  graceful shutdown, and with immediate shutdown too."
x stop "^Boot's own metadata, in after/'s jar: server\.shutdown default graceful \(spring-boot-web-server-4\.1\.1\.jar\)\$"
QA=$(blk stop 'A - ' 'B - '); QB=$(blk stop 'B - ' "A' - A again"); QA2=$(blk stop "A' - A again" '')
for b in "$QA" "$QB" "$QA2"; do has "$b" "$SHUT" "stop: the answer arrived"; has "$b" "$(STOPPED 19356)" "stop: exit 0"; done
for b in "$QA" "$QA2"; do has "$b" "  Boot's graceful-shutdown lines in its log: 2" "stop A/A': graceful"; done
has "$QB" "  Boot's graceful-shutdown lines in its log: 0" "stop B: immediate"; printf '%s\n' "$QB" | grep -q -- ' --server\.shutdown=immediate$' || die "stop B: the option"
[ "$(printf '%s\n' "$QA" | grep -v '^  its log: ')" = "$(printf '%s\n' "$QA2" | grep -v '^  its log: ')" ] || die "stop: A' differs from A"
echo "  stop: graceful by default; A, B (immediate) and A' - the answer {\"stopping\":true} (17 bytes), exit 0; graceful lines 2 / 0 / 2"

# the exercise's end state: the README's commands, then the solution's, in ONE env -i shell - each leaves the shell in this folder;
# the line exercise/README.md calls "Done" is a line of this capture, after the solution's lines, and of SOLUTION.md's measured run;
# the README's own last line, as shipped, prints the 405
XS=$(blk exercise "the README's" "the solution's"); XE=$(blk exercise "the solution's" '')
l='status: 200 · Allow: none · customers: 4'; l0='status: 405 · Allow: GET · customers: 0'
has "$XE" "    $l" "exercise: the solution"; has "$XS" "    $l0" "exercise: as shipped"
awk '/^\*\*Done\*\*/ { f = 1 } f' exercise/README.md | grep -qxF -- "$l" || die "exercise/README.md: Done names no such line"
grep -qxF -- "$l" exercise/solution/SOLUTION.md || die "SOLUTION.md: the measured run shows no such line"
grep -qF -- "\`$l0\`" exercise/README.md || die "exercise/README.md: the shipped line's answer is not named"
has "$XS" '  exit 0 · what they printed:' "exercise: the README's commands, exit 0"; has "$XE" '  exit 0 · what they printed:' "exercise: the solution's lines, exit 0"
has "$XS" "  the shell is now in: this unit's folder · the copy's own token in its log: 0 times" "exercise: the README's commands leave the shell in this unit's folder"
has "$XE" "  the shell is now in: this unit's folder · the copy's own token in its log: 0 times · listening on 19359 now: 0" "exercise: the solution's lines leave the shell in this unit's folder, nothing listening"
[ "$(printf '%s\n' "$XE" | grep -c '^  \$ export ')" = 2 ] || die "exercise: SOLUTION.md gives the README's two export lines"
echo "  exercise: one env -i shell - the README as written -> 405, Allow: GET, 0 customers; the solution's lines -> 200, 4 customers; the shell in this unit's folder after each"

# "The record's hint is gone: Spring's AOT step ... registers the record itself. Return a plain object, and nothing's registered. The
#  jar, the AOT jar, the native binary and the image all answer the same masked seven, on loopback."
x forms '^  exit 0 · BUILD SUCCESS · stages it printed: 8 of the 8 it announces · its duration, against the bound: under 20 minutes · its lines that say the metadata repository was downloaded over http, or failed to: 0 · offline: yes$'
x forms '^  file: Mach-O 64-bit executable · the demo token in its bytes: 0$'
x forms '^what Spring.s AOT step registered for the native build - the record the routes return, with no hint in the tree \(code lines naming @RegisterReflectionForBinding in its Java sources: 0\):$'
x forms '^  Spring.s generated metadata \(spring-aot/main/resources/META-INF/native-image/com\.tiffinbox/tiffinbox-web/reachability-metadata\.json\): reflection entries naming com\.tiffinbox\.Customer: 1 - all declared fields · all declared constructors · 4 methods \(mealType mealsPerDay name pricePerMeal\)$'
x forms '^    \+    Object customers\(\) throws Exception \{$'; [ "$(n forms '^    [-+]    ')" = 2 ] || die "forms C: one line changed"
x forms '^    built the copy, the profile native \(Spring.s AOT step\) · offline: yes · exit 0$'
x forms '^    Spring.s generated metadata \(spring-aot/main/resources/META-INF/native-image/com\.tiffinbox/tiffinbox-web/reachability-metadata\.json\): reflection entries naming com\.tiffinbox\.Customer: 0$'
x forms "^four forms, one tree: the seven \(masked\) 4 of 4 times $S87C\$"
x forms '^  loopback, form by form: the jar yes · the AOT jar yes · the binary yes \(its DEBUG run among them\) · the image, published on 127\.0\.0\.1 alone yes$'
for t in '1 the jar' '2 the AOT jar' '3 the binary' '4 the image'; do x forms "^$t - "; done
x forms "^  Boot's first line: Starting AOT-processed TiffinBoxServer v1\.0\.0 using Java 25\.0\.4\.1\$"; x forms "^  Boot's first line: Starting AOT-processed TiffinBoxServer using Java 25\.0\.4\.1\$"
x forms '^  its line for GET /customers that names the handler: tomcat-handler-N Mapped to com\.tiffinbox\.web\.TiffinBoxServer#customers\(\) · its other lines - the start, the readiness polls \(their number moves\), the rest of this request: more than 40, not shown$'
x forms '^  inside the container, listening: \[::\]:18425$'; x forms '^  docker port: 18425/tcp -> 127\.0\.0\.1:19357$'; x forms '^  its lines that say pull: 0 · '
x forms '^  the image saved \(docker save\): [1-9][0-9]* blobs, its [1-9][0-9]* layers among them, each read whole \(gzip ones unpacked\) · the demo token in them: 0$'
echo "  forms: 8 of 8 stages, offline, Mach-O, 0 tokens; no hint in the sources, Customer registered by the AOT step (1; a copy returning Object: 0); the jar, the AOT jar, the binary, the image: 4 of 4 87ca7efc..., loopback form by form; the binary's handler is TiffinBoxServer#customers(); the image's layers 0 tokens"

cmp -s after/README.md ../c6-tiffinbox/README.md || echo "  (after/README.md and ../c6-tiffinbox/README.md differ - the anchor has moved past this unit's after/)" >&3
[ -z "$unpub" ] || die "no published hash for:$unpub - check the captures, then copy the md5s above into receipts.md5 and run again"
echo "c6-unit06: every capture 3/3 and = published; every spoken number asserted; 0 raw demo tokens in every capture, every log, the container's log, the image's layers and the binary; nothing of this run left on Docker"
