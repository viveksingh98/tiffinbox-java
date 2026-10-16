#!/bin/bash
XPATH=$PATH                                           # the PATH you started this with: the exercise's own shell gets it
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25.0.4.1 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# GRAALVM_HOME names a GraalVM JDK 25 (README.md, "The GraalVM"): the native build reads it. Without it, this script makes every
# capture that needs no GraalVM, filling .m2-demo on the way, then stops before the native build.
# Course 6 · Responses: ResponseEntity and Status Codes - this unit's receipts. The anchor changes: TiffinBoxServer's two POST routes
# answer with a ResponseEntity - a status, headers and a body as one return value. POST /customers answers 201 Created, a Location
# header (the new customer's URL, built from the request's own) and the record - or 409 Conflict for a name that is taken, decided by
# H2's SQLSTATE 23505, never by the exception's class; POST /shutdown answers its 403 by its return value, the servlet response
# parameter gone. Seven captures, each run three times and hashed; cap() DIES when a hash differs from receipts.md5; every number the
# video says is asserted at the bottom by a check that can fail; the demo token is masked (gsub), and the checks count 0 raw copies of
# it in every capture, in the log of every run - the container's included - in every file this unit ships, in the binary and in the
# image's layers.
#   entity     the previous tree against after/: the files that differ, TiffinBoxServer's code lines and their diff, the jar's libraries;
#              the seven on after/; then on each tree, Boot's web group at DEBUG: a new customer and POST /shutdown without the token -
#              each answer, the lines Spring MVC logs for it (the route it mapped to, the return-value handler that wrote it), the
#              403's status line and headers; javap: which of the two return-value handlers flushes the answer it writes
#   created    after/: a new customer - 201, its Location, the Location followed; a name with a space - its Location encoded, followed;
#              the status line and headers of a 201; OPTIONS on /customers and on a Location
#   host       A/B/A' + C, D: the Location the README's line gets (A); the same line with a Host header of the client's (B); A again (A');
#              with X-Forwarded-Host and X-Forwarded-Proto (C, labelled); the same line on the previous tree (D, labelled); Boot's
#              metadata for server.forward-headers-strategy
#   conflict   before/A/C/A': a new name, a taken name and a misspelt key - on the previous tree (200, 500, 500), on after/ (201, the
#              same name again 409, a name the seed already had 409, the misspelt key still 500), on a planted copy whose catch tests
#              the exception's class (C, labelled: the misspelt key a 409 too), and A again
#   statuses   the harness's Statuses: a name nobody has, answered four ways - TiffinBox's own route, ResponseEntity.of, null, an
#              Optional; then a 201 set by @ResponseStatus, and a Location built with the request's query string beside TiffinBox's own
#   exercise   exercise/README.md's commands, then exercise/solution/SOLUTION.md's, read from the files and run as written, one after
#              the other in ONE shell a viewer could have: env -i, /bin/bash, started in this folder
#   forms      the native build of after/ and what Spring's AOT step registered, then four forms - the jar, the AOT jar, the binary,
#              the image: each one's address, the seven (masked), exit 0; then, on a second start of each, a new customer (201, its
#              Location followed), the same name again (409) and POST /shutdown without the token (403)
# "The previous tree" is ../c6-unit09/after (the anchor before this change: the Jackson lesson's frozen tree), COPIED under
# .harness/before; after/ is this unit's frozen copy of ../c6-tiffinbox after the change, COPIED under .harness/after. This script
# never writes into another unit's folder, and never builds a frozen tree in place. Every run of TiffinBox starts in a folder under
# .harness/ that holds a config tree with a fake token (secrets/), as the README asks - the container's too, mounted read-only.
# Commands are printed exactly as they run: each goes through eval. "$CURLSET" is the comparison set since the secrets lesson
# (../c5-unit11/curlset.sh: the seven requests, POST /shutdown with the token's header read from the file). "$M2" is this unit's
# own repository, .m2-demo. The harness - harness/probe/web/Statuses.java (compiled with -parameters), the course's, never
# TiffinBox's: outside com.tiffinbox, joined by --spring.main.sources on the extracted jar's class path; harness/shutdown.sh (POST
# /shutdown, the token read from its file) - is named on every capture that uses it. Every run passes options only. The seven always
# run on a fresh JVM, before any POST: a POST stores a customer, and three of the seven list customers; and every POST of one run
# names a customer no earlier POST of that run named, unless the capture says it posts a name again.
# The network: every Maven build runs offline (-o) against .m2-demo and says so ("offline: yes"); a build that cannot resolve an
# artifact offline goes to Maven Central once, and says that ("offline: no - ..."). GraalVM's native plugin reads its metadata
# repository (a zip) from .m2-demo - and when the zip is not there it downloads it from GitHub, even under -o: so a native-profile
# build without the zip goes to Maven Central for it at once, and every native build's log is searched for the plugin's own
# download line - found, the run stops. Docker: no pull - eclipse-temurin:25-jre must already be on the daemon, and docker build
# prints how many of its lines say pull. At run time nothing leaves 127.0.0.1: TiffinBox listens there (in a container, on the
# container's own addresses, published on the host's 127.0.0.1 alone), every request goes there, and Logback writes to the
# terminal only. A Location that names another host (host B, kitchen.localhost) is printed, never followed.
# Masks and filters (README.md declares each; awk sub/gsub only): the demo token becomes "[masked: the N-character token]" (N its
# own length); the GraalVM's folder "$GRAALVM_HOME"; this folder's absolute path "…", the folder above it "…/..", the home folder
# "~"; your user name "<user>" - in every line of every capture. Spring's error timestamp becomes "…" (both forms: an ISO-8601
# string, epoch milliseconds) in the seven and wherever Spring's error body is printed; an answer's Date header's value becomes "…";
# H2's constraint and index names, in the quoted string after "violation: ", become "…"; where a native-image warning names the file
# it read an option from, the file's URL - or "null", which it prints when the path holds a space - becomes "…". A run's log lines
# are printed from their logger on (no time, no process id, no thread); Boot's first line is cut before " with PID". Long logs and
# answers go through a declared filter, and what it cuts is counted or bounded. No image, container or ID is printed but the base
# image's digest. No duration is captured: the native build's seconds, and the 20-minute bound, go to the terminal only.
# Ports (brief ⚑1, 19390-19399): after/'s jar 19390 · the previous tree 19391 · after/ with the harness joined 19392 · the planted
# copy 19393 · the AOT jar 19394 · the image 19397 · the binary 19398 · the exercise 19399 (19395 and 19396 are never bound). 18425
# (TiffinBox's default) and 8080 (Tomcat's) are checked free too, and never bound on this machine (18425 only inside a container).
# Docker names (no unit number): the image tiffinbox-status:1.0.0 and the container tiffinbox-status. Each is checked absent before
# the first run - a name already there may be yours, and this script removes only what it creates - and removed on every exit: the
# container with docker rm -f, the image by name and by every ID a build of this run recorded. Docker's build cache is not
# pruned: .dockerignore keeps secrets/ out of every build context, so the cache holds no token.
set -e
# bash 5.2 and later turn an & in the replacement of ${x/pattern/replacement} into the matched text (patsub_replacement, on by
# default). Switched off, so /bin/bash 3.2 (./receipts.sh) and a newer bash (bash receipts.sh) run the same commands; 3.2 has no
# such option.
shopt -u patsub_replacement 2> /dev/null || true
# One locale for every tool, whatever yours is: sort's order, and what a program prints, follow it. The published captures were
# made with no locale set, which is the C locale. The JVM ignores LC_ALL on macOS (it takes the Mac's first language), and H2 writes
# its messages in the JVM's: so conflict, the capture that prints them, pins the JVM's locale on each of its run lines
# (-Duser.language=en -Duser.country=US, before -jar) and prints it.
export LC_ALL=C
cd "$(dirname "$0")"
# One run at a time: two runs share .harness/, the ports and the Docker names, and one would corrupt the other.
mkdir .r-lock 2> /dev/null || { echo "  *** another receipts.sh is running in this folder (.r-lock exists) - if none is, rmdir .r-lock ***"; exit 1; }
IMG=tiffinbox-status:1.0.0; BOX=tiffinbox-status
OURS=""                                              # set once the start-up checks found none of the Docker names above
# On every exit - the end, a failed check, or Ctrl-C - stop the processes this script started in the background ($pid, a server;
# $xpid, the exercise's shell, with every process under it - its Maven, its JVM, its curl), if they still run, then sweep(): anything
# of this run still alive in its process group - a TiffinBox JVM, a binary, native-image's driver or builder - is stopped; then
# dclean(): this run's container and image. After an interrupt, a capture's unfinished runs (.r-NAME.1-3) go too; after a failed
# check they stay, for the diff the message names. The clean-up ignores a second Ctrl-C, and nothing in it can fail under set -e, so
# it always reaches the rmdir; the script still exits 130 after an interrupt (README.md, "Interrupted"). $pid and $xpid are cleared
# whenever their process has been reaped. sweep() kills only processes of this run's own process group - start each run in a group
# of its own (README.md, "Interrupted").
pid=""; xpid=""
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
trap 'trap "" INT TERM; [ -z "$xpid" ] || killtree "$xpid"; for p in "$pid" "$xpid"; do if [ -n "$p" ] && kill "$p" 2> /dev/null; then wait "$p" 2> /dev/null || true; fi; done; sweep || true; dclean || true; [ -z "$INTR" ] || rm -f .r-*.[123]; rmdir .r-lock 2> /dev/null || true' EXIT
INTR=""; trap 'INTR=1; exit 130' INT TERM
exec 3>&1                                            # die() speaks to the terminal even inside a redirected capture
die() { echo "  *** $* ***" >&3; exit 1; }
java -version 2>&1 | grep -q 'version "25' || die "JDK 25 needed; JAVA_HOME gives: $(java -version 2>&1 | head -1)"
for t in python3 curl rsync lsof unzip javac javap docker openssl; do command -v $t > /dev/null || die "$t is needed"; done
# A variable of yours must not become a property source, a JVM flag, a build setting, a native-image option or a docker build
# setting: every TIFFINBOX_*, SPRING_*, MANAGEMENT_*, SERVER_*, LOGGING_*, COMPOSE_*, BUILDKIT_* and BUILDX_* variable, DEBUG (Boot
# reads it as --debug), the variables that inject JVM flags, MAVEN_OPTS, MAVEN_ARGS, NATIVE_IMAGE_OPTIONS, DOCKER_BUILDKIT,
# DOCKER_DEFAULT_PLATFORM, SOURCE_DATE_EPOCH, KUBERNETES_SERVICE_HOST and KUBERNETES_SERVICE_PORT are removed first. GRAALVM_HOME stays: it says which GraalVM to use; so do
# DOCKER_HOST and DOCKER_CONTEXT: they say which Docker answers. (SERVER_FORWARD_HEADERS_STRATEGY of yours would make host C read
# the forwarded headers - and so would the two KUBERNETES_SERVICE_* every pod has: Boot reads them as "on Kubernetes" and the forwarded
# headers with it (host E); SERVER_ADDRESS or SERVER_PORT beat the alias; TIFFINBOX_SHUTDOWN_TOKEN the config tree.)
# The list is an extended regular expression (sed -E): /usr/bin/sed's basic ones have no alternation (RED C5-S4 #63). A canary is
# planted under every name first, and the run stops if one survives the loop.
for v in TIFFINBOX_CANARY SPRING_CANARY MANAGEMENT_CANARY SERVER_CANARY LOGGING_CANARY COMPOSE_CANARY BUILDKIT_CANARY BUILDX_CANARY DEBUG JAVA_TOOL_OPTIONS JDK_JAVA_OPTIONS _JAVA_OPTIONS MAVEN_OPTS MAVEN_ARGS NATIVE_IMAGE_OPTIONS DOCKER_BUILDKIT DOCKER_DEFAULT_PLATFORM SOURCE_DATE_EPOCH KUBERNETES_SERVICE_HOST KUBERNETES_SERVICE_PORT; do export "$v=planted-canary"; done
for v in $(env | sed -n -E 's/^(TIFFINBOX_[A-Za-z0-9_]*|SPRING_[A-Za-z0-9_]*|MANAGEMENT_[A-Za-z0-9_]*|SERVER_[A-Za-z0-9_]*|LOGGING_[A-Za-z0-9_]*|COMPOSE_[A-Za-z0-9_]*|BUILDKIT_[A-Za-z0-9_]*|BUILDX_[A-Za-z0-9_]*|DEBUG|JAVA_TOOL_OPTIONS|JDK_JAVA_OPTIONS|_JAVA_OPTIONS|MAVEN_OPTS|MAVEN_ARGS|NATIVE_IMAGE_OPTIONS|DOCKER_BUILDKIT|DOCKER_DEFAULT_PLATFORM|SOURCE_DATE_EPOCH|KUBERNETES_SERVICE_HOST|KUBERNETES_SERVICE_PORT)=.*/\1/p'); do unset "$v"; done
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
PREV=../c6-unit09/after                              # the previous tree: the anchor before this change - read, copied
[ -e secrets ] && die "this folder holds a secrets/ - remove it: every run here starts in a folder under .harness/"
for t in "$PREV" after; do
  [ -f "$t/pom.xml" ] && [ -f "$t/README.md" ] && [ -f "$t/Dockerfile" ] && [ -f "$t/.dockerignore" ] || die "the tree $t (its pom.xml, README.md, Dockerfile or .dockerignore) is missing"
  [ -e "$t/secrets" ] || [ -e "$t/target" ] || [ -e "$t/tiffinbox-web/target" ] && die "$t holds a secrets/ or a target/ - it is a frozen copy, never built in place"
  grep -qx 'secrets/' "$t/.dockerignore" || die "$t's .dockerignore no longer keeps secrets/ out of a build context"; done
M2="$PWD/.m2-demo"; U="$PWD"; UP="$(cd .. && pwd)"; ME="$(id -un)"
W=tiffinbox-web/src/main/java/com/tiffinbox/web     # the web module's Java sources, in a tree
JARP=tiffinbox-web/target/tiffinbox-web-1.0.0.jar    # the executable jar, in a tree's web module
BIN=tiffinbox-web/target/tiffinbox-web               # the binary native:compile-no-fork writes, in a tree's web module
TF=secrets/tiffinbox/shutdown-token                  # the config tree's file for tiffinbox.shutdown-token
# The demo token. FAKE, and meant to look it: it guards nothing but a demo server on 127.0.0.1 that every capture stops. It is
# written into .harness/*/secrets/ (git-ignored) when this script runs, and no capture prints it: see mask().
TOKEN=not-a-real-token-demo-only
[ ${#TOKEN} = 26 ] || die "the demo token must be 26 characters: the published captures name its length"
CURLSET=../c5-unit11/curlset.sh                      # the comparison set: the seven requests, POST /shutdown with the header
[ -f "$CURLSET" ] || die "$CURLSET is missing"
HW=harness/probe/web/Statuses.java
for f in harness/shutdown.sh $HW exercise/README.md exercise/solution/SOLUTION.md README.md; do [ -f "$f" ] || die "$f is missing"; done
[ "$(ls harness/probe/web | paste -sd' ' -)" = 'Statuses.java' ] || die "harness/probe/web holds another file: javac compiles all of it"

# The ports and the Docker names, BEFORE anything is wiped (a survivor of an interrupted run answers POST /shutdown only with its
# token, which lives in .harness/ - so the message names the process to kill).
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
for p in 18425 8080 19390 19391 19392 19393 19394 19395 19396 19397 19398 19399; do
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
R_ONE=$(readme "curl -s -w ' %{http_code}\n' http://127.0.0.1:18431/customers/Ravi")
# Boot's web group at DEBUG (the embedded-Tomcat lesson's line); POST /shutdown without the token (the secrets lesson's line); the
# request-body lesson's POST - and this unit's line in the anchor's README: the same POST with its answer's Location printed
R_WEB=$(readme "$J --logging.level.web=debug")
R_403=$(readme "curl -s -w ' %{http_code}\n' -X POST http://127.0.0.1:18431/shutdown")
R_ADD=$(readme "curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '{\"name\":\"Asha\",\"mealsPerDay\":2,\"pricePerMeal\":110,\"mealType\":\"VEG\"}' http://127.0.0.1:18431/customers")
R_LOC=$(readme "curl -s -w ' %{http_code} · Location: [%header{location}]\n' -H 'Content-Type: application/json' --data '{\"name\":\"Asha\",\"mealsPerDay\":2,\"pricePerMeal\":110,\"mealType\":\"VEG\"}' http://127.0.0.1:18431/customers")
[ "${R_WEB#"$J "}" = '--logging.level.web=debug' ] || die "the README's options"
LW=' · Location: [%header{location}]'
r=${R_LOC/"$LW"/}; [ "$r" = "$R_ADD" ] || die "the anchor's Location line must be the request-body lesson's POST with the Location printed, and nothing else"
# This unit's own lines (README.md, "The commands this unit adds") - each asserted to be exactly that: the Location line with a Host
# header of the client's (host B); with the two forwarded headers (host C); a POST and POST /shutdown without the token, each
# printing its answer's status line and headers (entity, created); OPTIONS, the verbs a path takes (created); a GET that prints its
# answer's status, type and length (statuses); javap on the two return-value handlers (entity); the anchor's run line with the
# JVM's locale pinned before -jar (conflict: H2 writes its messages in the JVM's locale); the anchor's run line with Boot told it
# runs on Kubernetes (host E)
mine() { grep -m1 -xF -- "$1" README.md > /dev/null || die "README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
L_HOST=$(mine "curl -s -w ' %{http_code} · Location: [%header{location}]\n' -H 'Host: kitchen.localhost' -H 'Content-Type: application/json' --data '{\"name\":\"Asha\",\"mealsPerDay\":2,\"pricePerMeal\":110,\"mealType\":\"VEG\"}' http://127.0.0.1:18431/customers")
L_FWD=$(mine "curl -s -w ' %{http_code} · Location: [%header{location}]\n' -H 'X-Forwarded-Host: kitchen.localhost' -H 'X-Forwarded-Proto: https' -H 'Content-Type: application/json' --data '{\"name\":\"Asha\",\"mealsPerDay\":2,\"pricePerMeal\":110,\"mealType\":\"VEG\"}' http://127.0.0.1:18431/customers")
L_HEAD=$(mine "curl -s -o /dev/null -D - -H 'Content-Type: application/json' --data '{\"name\":\"Asha\",\"mealsPerDay\":2,\"pricePerMeal\":110,\"mealType\":\"VEG\"}' http://127.0.0.1:18431/customers")
L_HEAD403=$(mine "curl -s -o /dev/null -D - -X POST http://127.0.0.1:18431/shutdown")
L_OPT=$(mine "curl -s -o /dev/null -w '%{http_code} · Allow: [%header{allow}]\n' -X OPTIONS http://127.0.0.1:18431/customers")
L_ST=$(mine "curl -s -w ' · %{http_code} · Content-Type: [%header{content-type}] · Content-Length: [%header{content-length}]\n' http://127.0.0.1:18431/customers/Nobody")
L_JAVAP=$(mine 'javap -c -p -cp tiffinbox-web/target/extracted/lib/spring-webmvc-7.0.9.jar org.springframework.web.servlet.mvc.method.annotation.HttpEntityMethodProcessor org.springframework.web.servlet.mvc.method.annotation.RequestResponseBodyMethodProcessor')
L_RUNL=$(mine 'java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431')
L_K8S=$(mine "$J --spring.main.cloud-platform=kubernetes")
P_='java -jar '; Q_='java -Duser.language=en -Duser.country=US -jar '; r=${R_RUN/"$P_"/$Q_}; [ "$r" = "$L_RUNL" ] || die "the pinned run line must be the anchor's run line with -Duser.language=en -Duser.country=US before -jar, and nothing else"
[ "${L_K8S#"$J "}" = '--spring.main.cloud-platform=kubernetes' ] || die "host E's line must be the anchor's run line with --spring.main.cloud-platform=kubernetes, and nothing else"
# B is the anchor's Location line with one header added, C with two, and nothing else; the header lines are the anchor's POST and its
# 403 line with -D - in place of -w
r=${L_HOST/" -H 'Host: kitchen.localhost'"/}; [ "$r" = "$R_LOC" ] || die "host: B must be the anchor's Location line with -H 'Host: kitchen.localhost', and nothing else"
r=${L_FWD/" -H 'X-Forwarded-Host: kitchen.localhost' -H 'X-Forwarded-Proto: https'"/}; [ "$r" = "$R_LOC" ] || die "host: C must be the anchor's Location line with the two forwarded headers, and nothing else"
# (the pattern and the replacement are variables, and the result an assignment: /bin/bash 3.2 ends a pattern at a slash even inside quotes,
# and keeps a quoted replacement's quotes inside a quoted expansion)
HDX='curl -s -o /dev/null -D - '; HWX="curl -s -w ' %{http_code}\n' "
r=${L_HEAD/"$HDX"/$HWX}; [ "$r" = "$R_ADD" ] || die "the 201's header line must be the request-body lesson's POST with -o /dev/null -D - for its -w, and nothing else"
r=${L_HEAD403/"$HDX"/$HWX}; [ "$r" = "$R_403" ] || die "the 403's header line must be the secrets lesson's line with -o /dev/null -D - for its -w, and nothing else"
# ADATA: the request-body lesson's JSON body; PREF: its curl and options, before the body; LPREF: this unit's Location line's. pc()
# and plc() build the same lines for another port, path and body - and must give the README's lines back
ADATA=${R_ADD#* --data \'}; ADATA=${ADATA%%\' http://*}
PREF=${R_ADD% --data *}; LPREF=${R_LOC% --data *}
# off DIR 'README mvn LINE' [PHASE]: the README's Maven line as this script runs it - from DIR, offline (-o), this unit's own
# repository, and for a build phase (package, install) clean and without tests. dev() takes those four things back out, and
# must give the README's line again: so the command on screen is the README's, with exactly those changes.
off() { local c=${2/mvn -B /mvn -o -B -Dmaven.repo.local=\"\$M2\" }
  [ -n "$3" ] && c=${c/ $3/ -DskipTests clean $3}
  printf 'cd %s && %s\n' "$1" "$c"; }
dev() { local c=${1#cd * && }; c=${c/ -o -B -Dmaven.repo.local=\"\$M2\" / -B }; c=${c/ -DskipTests clean / }; printf '%s\n' "$c"; }
# at DIR PORT 'README LINE': the README's line run from DIR, its port 18431 made PORT
at() { printf 'cd %s && %s\n' "$1" "${3/--tiffinbox.port=18431/--tiffinbox.port=$2}"; }
# hcp DIR PORT CLASSES ['OPTIONS']: the README's class-path line - the extracted jar, TiffinBox's own main - from DIR, its port made
# PORT, the harness's classes added to the class path (../hc) and CLASSES joined (--spring.main.sources=); OPTIONS after
hcp() { local c; c=$(at "$1" "$2" "$R_CP"); c=${c/lib\/\*\"/lib\/*:..\/hc\"}; printf '%s --spring.main.sources=%s%s\n' "$c" "$3" "${4:+ $4}"; }
# url 'README curl LINE' PORT: the README's curl line, its port 18431 made PORT
url() { printf '%s\n' "${1/:18431\//:$2/}"; }
# qurl PORT PATH: the URL; one that holds a character the shell reads (; ? & * { } or a space) is single-quoted, so eval hands it to
# curl whole
qurl() { local u="http://127.0.0.1:$1$2"; case $2 in *[\;\?\&\*\{\}\ ]*) u="'$u'" ;; esac; printf '%s\n' "$u"; }
# bc PORT PATH: the binding lesson's one-customer line (the anchor's README) - the body and the status - the same way
bc() { local c=${R_ONE% http://*}; printf '%s %s\n' "$c" "$(qurl "$1" "$2")"; }
# pc PORT PATH 'BODY': the request-body lesson's POST line - its port, its path and its JSON body swapped, the body single-quoted as
# the README writes it; plc the same for this unit's Location line; lc 'LINE' PORT PATH 'BODY' the same for any line of that shape
pc() { printf "%s --data '%s' %s\n" "$PREF" "$3" "$(qurl "$1" "$2")"; }
plc() { printf "%s --data '%s' %s\n" "$LPREF" "$3" "$(qurl "$1" "$2")"; }
lc() { printf "%s --data '%s' %s\n" "${1% --data *}" "$4" "$(qurl "$2" "$3")"; }
# stc PORT PATH: this unit's status, type and length line, its port and path swapped
stc() { printf '%s %s\n' "${L_ST% http://*}" "$(qurl "$1" "$2")"; }
# fo: the binding lesson's one-customer line with its URL made the Location the last POST printed (.harness/loc.txt) - single-quoted
# when it holds a character the shell reads; it must be a URL on 127.0.0.1 (never another host's)
fo() { local l u; l=$(cat .harness/loc.txt 2> /dev/null); case $l in http://127.0.0.1:*) ;; *) die "no Location on 127.0.0.1 to follow: [$l]" ;; esac
  u=$l; case $u in *[\;\?\&\*\{\}\ ]*) u="'$u'" ;; esac; printf '%s %s\n' "${R_ONE% http://*}" "$u"; }
# exe 'COMMAND': the command with "exec" after its "cd DIR && " and any NAME=value before the program - so $pid is the program's
exe() { printf '%s\n' "$1" | sed -E 's/&& (([A-Z_]+=[^ ]* )*)/\&\& \1exec /'; }
# The docker lines, as this script runs them: the README's build line with plain progress and this script's own tag; its run line
# with this script's own name and tag, the port published on 127.0.0.1 made PORT, and your user and group added - the config tree
# is yours, mode 0600 (R.74). undock() takes those changes back out, and must give the README's lines again.
UARG='--user "$(id -u):$(id -g)"'
dbuild() { local c=${R_DBUILD/docker build -t tiffinbox-docker:1.0.0 /docker build --progress=plain -t $IMG }; printf 'cd %s && %s\n' "$1" "$c"; }
drun() { local c=${R_DRUN/--name tiffinbox /--name $BOX $UARG }; c=${c/127.0.0.1:18431:18425/127.0.0.1:$2:18425}; c=${c/% tiffinbox-docker:1.0.0/ $IMG}; printf 'cd %s && %s\n' "$1" "$c"; }
undock() { local c=${1#cd * && }; c=${c/--progress=plain /}; c=${c/" $UARG"/}; c=${c//$IMG/tiffinbox-docker:1.0.0}; c=${c/--name $BOX /--name tiffinbox }; c=${c/127.0.0.1:1939?:18425/127.0.0.1:18431:18425}; printf '%s\n' "$c"; }
[ "$(undock "$(dbuild .harness/x)")" = "$R_DBUILD" ] || die "not the README's build line with the declared changes: $(dbuild .harness/x)"
[ "$(undock "$(drun .harness/x 19397)")" = "$R_DRUN" ] || die "not the README's run line with the declared changes: $(drun .harness/x 19397)"
C_PRE=$(off .harness/pre "$R_INSTALL" install)
for c in "$C_PRE" "$(off .harness/x "$R_PLAIN" package)" "$(off .harness/x "$R_PNAT" package)" "$(off .harness/x "$R_NATIVE")"; do
  r=$(dev "$c"); [ "$r" = "$R_PLAIN" ] || [ "$r" = "$R_PNAT" ] || [ "$r" = "$R_INSTALL" ] || [ "$r" = "$R_NATIVE" ] || die "not a README line with the offline changes: $c"; done
[ "$(exe "$(at .harness/x 19390 "$R_RUN")")" = 'cd .harness/x && exec java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19390' ] || die "exe()"
[ "$(hcp .harness/x 19392 probe.web.Statuses)" = 'cd .harness/x && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19392 --spring.main.sources=probe.web.Statuses' ] || die "hcp()"
[ "$(bc 19390 /customers/Asha)" = "curl -s -w ' %{http_code}\n' http://127.0.0.1:19390/customers/Asha" ] || die "bc()"
[ "$(pc 18431 /customers "$ADATA")" = "$R_ADD" ] && [ "$(plc 18431 /customers "$ADATA")" = "$R_LOC" ] && [ "$(lc "$L_HOST" 18431 /customers "$ADATA")" = "$L_HOST" ] && [ "$(lc "$L_FWD" 18431 /customers "$ADATA")" = "$L_FWD" ] && [ "$(lc "$L_HEAD" 18431 /customers "$ADATA")" = "$L_HEAD" ] && [ "$ADATA" = '{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' ] || die "pc(), plc(), lc(): not the README's POST lines"
[ "$(stc 18431 /customers/Nobody)" = "$L_ST" ] && [ "$(url "$L_OPT" 19390)" = "curl -s -o /dev/null -w '%{http_code} · Allow: [%header{allow}]\n' -X OPTIONS http://127.0.0.1:19390/customers" ] || die "stc(), url(): not the README's lines"
echo "  the commands: after/README.md gives all 18 lines this script runs or derives from; README.md the 9 this unit adds"

# ---- build: before the captures - after/'s native install (it fills .m2-demo on a fresh clone); the harness compiled against
# ---- after/'s own jar; what .m2-demo holds --------------------------------------------------------------------------------
rm -rf .harness; mkdir -p .harness; : > .harness/imgids
rsync -a --exclude target --exclude secrets after/ .harness/pre/
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
[ -f "$M2/org/springframework/boot/spring-boot-starter-webmvc/4.1.1/spring-boot-starter-webmvc-4.1.1.jar" ] || die "Spring MVC's starter is not in .m2-demo after the first build"
[ -f "$M2/org/graalvm/buildtools/native-maven-plugin/1.1.8/native-maven-plugin-1.1.8.jar" ] || die "GraalVM's native plugin 1.1.8 is not in .m2-demo after the first build"
[ -f "$ZIP" ] || die "GraalVM's metadata repository is not in .m2-demo after the first build - README.md, The repository"
(cd .harness/pre && eval "$R_EXTRACT") > .harness/extract-pre.log 2>&1 || die "the README's extract line failed on .harness/pre"
javac -parameters -d .harness/hc -cp ".harness/pre/tiffinbox-web/target/extracted/lib/*" $HW > .harness/javac.log 2>&1 || { cat .harness/javac.log >&3; die "the harness did not compile against after/'s jar"; }
echo "  .m2-demo holds Spring MVC's starter, GraalVM's native plugin 1.1.8 and its metadata repository; the harness compiled against after/'s jar"

# ---- helpers ------------------------------------------------------------------------------------------------------------
# raw TOKEN FILE...: how many times TOKEN appears, raw, in the files (occurrences, not lines; binary files read as text)
raw() { local t=$1; shift; cat "$@" | LC_ALL=C grep -aoF -- "$t" | wc -l | tr -d ' '; }
LOGS=0; CLOGS=0; LASTE=""                            # logs counted: served runs, containers
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
# timestamp mask, how many lines the mask changed, and the form of the timestamps it hid; the log counted (logtok). The seven, masked,
# stay in .harness/responses.m.txt
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
# stop PORT DIR: POST /shutdown with DIR's token; the JVM must leave, the port must be free; its log counted (logtok)
stop() { post "$1" "$2"; gone "$1"; echo "  exit $LASTE · listening on $1 now: 0"; logtok; }
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
  for i in 1 2 3; do "$@" > .harness/cap.raw 2>&1 || true; [ -z "$pid" ] && [ -z "$xpid" ] || die "$nm left a process running"
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
# code FILE: a Java file's lines that are neither comment nor blank
code() { grep -vE '^[[:space:]]*(\*|/\*\*|\*/|//|$)' "$1"; }
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
# ask PORT PATH: the one-customer line (body and status), its path PATH, printed and run, the answer's timestamp masked; then the
# WARN lines the request added (wans)
ask() { local c n0; n0=$(mark); c=$(bc "$@"); echo "\$ $c"; (eval "$c") 2>&1 < /dev/null | tsmask > .harness/ask.txt; wans "$n0" .harness/ask.txt; }
# locof FILE: the Location an answer printed by the Location line holds - between "Location: [" and the line's last "]"
locof() { sed -n 's/^.* · Location: \[\(.*\)\]$/\1/p' "$1" | tail -1; }
# pl PORT 'BODY' [PATH]: this unit's line in the anchor's README - a POST with its answer's Location printed - its port, path (/customers)
# and body swapped, printed and run, the answer's timestamp masked; the Location it printed kept in .harness/loc.txt; then the WARN
# lines its request added (wans). lpl 'LINE' PORT 'BODY': the same for another line of that shape (host B and C)
pl() { local c n0; n0=$(mark); c=$(plc "$1" "${3:-/customers}" "$2"); echo "\$ $c"; (eval "$c") 2>&1 < /dev/null | tsmask > .harness/ask.txt; locof .harness/ask.txt > .harness/loc.txt; wans "$n0" .harness/ask.txt; }
lpl() { local c n0; n0=$(mark); c=$(lc "$1" "$2" /customers "$3"); echo "\$ $c"; (eval "$c") 2>&1 < /dev/null | tsmask > .harness/ask.txt; locof .harness/ask.txt > .harness/loc.txt; wans "$n0" .harness/ask.txt; }
# fol: the Location the last POST printed, followed with the binding lesson's one-customer line (fo) - printed and run, the answer's
# timestamp masked; then the WARN lines it added
fol() { local c n0; n0=$(mark); c=$(fo); echo "\$ $c"; (eval "$c") 2>&1 < /dev/null | tsmask > .harness/ask.txt; wans "$n0" .harness/ask.txt; }
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
# p5 PORT 'BODY': a POST with its Location printed that ends in a 500 - the answer, then the log's record of it (erec)
p5() { local c n0; n0=$(mark); c=$(plc "$1" /customers "$2"); echo "\$ $c"; (eval "$c") 2>&1 < /dev/null | tsmask | sed 's/^/  /'; erec "$n0"; }
# rp 'COMMAND': a curl line, printed and run, the answer indented, the timestamp masked
rp() { echo "\$ $1"; (eval "$1") 2>&1 < /dev/null | tsmask | sed 's/^/  /'; }
# rl PORT 'BODY' / rfol: pl and fol for the four forms - the answer printed, no WARN count (a container's log is read only when it
# has stopped)
rl() { local c; c=$(plc "$1" /customers "$2"); echo "\$ $c"; (eval "$c") 2>&1 < /dev/null | tsmask > .harness/ask.txt; locof .harness/ask.txt > .harness/loc.txt; sed 's/^/  /' .harness/ask.txt; }
rfol() { local c; c=$(fo); echo "\$ $c"; (eval "$c") 2>&1 < /dev/null | tsmask | sed 's/^/  /'; }
# ropt 'COMMAND': this unit's OPTIONS line, printed and run - the Allow header's verbs sorted (Spring MVC lists them in the order it
# met the matching methods, which moves between runs: README.md, Masks), and said so
ropt() { echo "\$ $1"; (eval "$1") 2>&1 < /dev/null | awk 'match($0, /Allow: \[[^]]*\]/) { v = substr($0, RSTART + 8, RLENGTH - 9); n = split(v, a, ",")
    for (i = 1; i <= n; i++) for (j = i + 1; j <= n; j++) if (a[j] < a[i]) { t = a[i]; a[i] = a[j]; a[j] = t }
    s = ""; for (i = 1; i <= n; i++) s = s (i > 1 ? "," : "") a[i]; $0 = substr($0, 1, RSTART + 7) s "]" substr($0, RSTART + RLENGTH) " (the verbs sorted)" } { print "  " $0 }'; }
# hdr 'COMMAND': a curl line that prints its answer's status line and headers (-D -), printed and run - the status line in brackets
# (Tomcat ends it with a space: no reason phrase), then each header, name and value, the Date header's value made "…" (README.md,
# Masks); the carriage returns curl keeps are dropped
hdr() { echo "\$ $1"; (eval "$1") 2>&1 < /dev/null | tr -d '\r' | awk 'NF == 0 { next } /^HTTP\// { print "  status line: [" $0 "]"; next }
  { i = index($0, ":"); n = substr($0, 1, i - 1); v = substr($0, i + 1); sub(/^ +/, "", v); if (tolower(n) == "date") v = "…"; print "  " n ": " v }'; }
# dbg FROM: every line the log gained after line FROM, from its logger on (logger: message); dreq 'COMMAND': at DEBUG - the command
# printed and run, its answer (the timestamp masked), then every line the log gained for it, counted
dbg() { awk -v from="$1" 'NR > from && / [A-Z]+ [0-9]+ --- \[/ { s = $0; i = index(s, " --- ["); s = substr(s, i + 6); i = index(s, "] "); s = substr(s, i + 2)
    i = index(s, " : "); lg = substr(s, 1, i - 1); sub(/ +$/, "", lg); print "    " lg ": " substr(s, i + 3) }' .harness/run.out; }
dreq() { local n0 k; n0=$(mark); echo "\$ $1"; (eval "$1") 2>&1 < /dev/null | tsmask | sed 's/^/  /'; settle
  k=$(dbg "$n0" | grep -c . || true); echo "  the lines the log gained for it, Boot's web group at DEBUG (logger: message) - all $k:"; dbg "$n0"; }
# stl PORT PATH: this unit's status, type and length line (stc), printed and run, the answer's timestamp masked; then the WARN lines
stl() { local c n0; n0=$(mark); c=$(stc "$1" "$2"); echo "\$ $c"; (eval "$c") 2>&1 < /dev/null | tsmask > .harness/ask.txt; wans "$n0" .harness/ask.txt; }
# blkraw FROM TO: this capture so far, the lines after the line that starts with FROM, up to the next line that starts with TO (to
# the end when TO is empty); asame A B A2 B2: yes when A's block (A up to B) and A2's (A2 up to B2), their labels aside, are the same
# line for line - an A' against its A
blkraw() { awk -v a="$1" -v b="$2" 'index($0, a) == 1 { f = 1; next } b != "" && index($0, b) == 1 { f = 0 } f' .harness/cap.raw; }
asame() { [ "$(blkraw "$1" "$2")" = "$(blkraw "$3" "$4")" ] && [ -n "$(blkraw "$3" "$4")" ] && echo yes || echo no; }
# bmeta JAR KEY: Boot's own metadata for a key - its type, its default and its description - read from JAR in after/'s extracted lib
bmeta() { python3 - ".harness/after/tiffinbox-web/target/extracted/lib/$1" "$2" <<'PY'
import json, os, sys, zipfile
d = json.loads(zipfile.ZipFile(sys.argv[1]).read("META-INF/spring-configuration-metadata.json"))
p = {x["name"]: x for x in d.get("properties", [])}; j = os.path.basename(sys.argv[1]); k = sys.argv[2]; e = p.get(k)
if not e: print("  Boot's metadata (%s): %s - in none of its entries" % (j, k))
else:
    dv = e.get("defaultValue")
    print("  Boot's metadata (%s) - %s · its type: %s · %s · its description: %s" % (j, k, e.get("type", "none").rsplit(".", 1)[-1], "no default value" if dv is None else "its default: " + json.dumps(dv), e.get("description", "none")))
PY
}

# ---- entity: the change, and who writes each answer ------------------------------------------------------------------------------
# The code lines of TiffinBoxServer.java (neither comment nor blank, nor an import) that name what the change adds and removes,
# counted before and after: a ResponseEntity; the servlet response (HttpServletResponse, setStatus); a SQLSTATE
ENTRE='ResponseEntity'
SERVRE='HttpServletResponse|setStatus\('
SQLRE='getSQLState\(\)'
# flushes FILE CLASS: in javap's output (FILE), the calls to ServletServerHttpResponse.flush inside CLASS's method handleReturnValue
flushes() { awk -v c="$2" '
  /^[a-z].* class / { inc = (index($0, "." c " ") > 0); inm = 0; next }
  inc && /^  [a-z].*\(/ { inm = (index($0, " handleReturnValue(") > 0); next }
  inc && inm && index($0, "ServletServerHttpResponse.flush:()V") { n++ }
  END { print n + 0 }' "$1"; }
entity() { local f n m c
  echo "the previous tree and after/, both copied under .harness/ with a config tree, each built with the README's line (offline):"
  copy "$PREV" .harness/before; copy after .harness/after
  pbuild .harness/before "the previous tree"; pbuild .harness/after "after/"
  echo "both jars extracted (the README's line) - the class path the harness runs on:"
  extract .harness/before; extract .harness/after
  echo "the harness, compiled against after/'s own jar - with -parameters:"
  c="javac -parameters -d .harness/hc -cp \".harness/after/tiffinbox-web/target/extracted/lib/*\" $HW"
  echo "\$ $c"; rm -rf .harness/hc; (eval "$c") > .harness/javac.log 2>&1 < /dev/null || { cat .harness/javac.log >&3; die "the harness did not compile against after/'s jar"; }
  echo "  exit 0"
  echo "the files that differ:"
  echo "\$ diff -rq -x target -x secrets .harness/before .harness/after"
  diff -rq -x target -x secrets .harness/before .harness/after | sed 's/^/  /' || true
  (cd after && find . -type f | sed 's#^\./##' | sort) > .harness/files.txt
  n=0; m=0; while IFS= read -r f; do m=$((m + 1)); cmp -s ".harness/before/$f" ".harness/after/$f" && n=$((n + 1)); done < .harness/files.txt
  echo "  after/'s files: $m · byte for byte the previous tree's: $n · those above differ: $((m - n))"
  f="$W/TiffinBoxServer.java"
  code ".harness/before/$f" > .harness/fb.txt; code ".harness/after/$f" > .harness/fa.txt
  grep -v '^import ' .harness/fb.txt > .harness/fbi.txt || true; grep -v '^import ' .harness/fa.txt > .harness/fai.txt || true
  echo "  TiffinBoxServer.java: $(lines ".harness/before/$f") lines -> $(lines ".harness/after/$f") · its lines that are neither comment nor blank: $(wc -l < .harness/fb.txt | tr -d ' ') -> $(wc -l < .harness/fa.txt | tr -d ' '), of them - imports left out - naming a ResponseEntity: $(grep -cE "$ENTRE" .harness/fbi.txt || true) -> $(grep -cE "$ENTRE" .harness/fai.txt || true) · the servlet response (HttpServletResponse, setStatus): $(grep -cE "$SERVRE" .harness/fbi.txt || true) -> $(grep -cE "$SERVRE" .harness/fai.txt || true) · a SQLSTATE (getSQLState()): $(grep -cE "$SQLRE" .harness/fbi.txt || true) -> $(grep -cE "$SQLRE" .harness/fai.txt || true)"
  diff -U0 .harness/fb.txt .harness/fa.txt | tail -n +3 > .harness/code.diff || true
  echo "  its code lines' diff (diff -U0 of the lines above, its file names cut) - hunks: $(grep -c '^@@ ' .harness/code.diff || true) · lines out: $(grep -c '^-' .harness/code.diff || true) · in: $(grep -c '^+' .harness/code.diff || true) - whole:"
  sed 's/^/    /' .harness/code.diff
  diff .harness/before/README.md .harness/after/README.md > .harness/file.diff || true
  echo "  README.md - the anchor's README: lines added $(grep -c '^> ' .harness/file.diff || true), removed $(grep -c '^< ' .harness/file.diff || true) - its new section and the history notes the change made false (not shown)"
  libs .harness/before/$JARP > .harness/lb.txt; libs .harness/after/$JARP > .harness/la.txt
  echo "the executable jar's BOOT-INF/lib: $(wc -l < .harness/lb.txt | tr -d ' ') jars -> $(wc -l < .harness/la.txt | tr -d ' ') · the same names: $(cmp -s .harness/lb.txt .harness/la.txt && echo yes || echo no)"
  echo "the seven - after/, the README's run line, port 19390, a fresh JVM:"
  start "$(at .harness/after 19390 "$R_RUN")"; up 19390; ready 19390; seven 19390 .harness/after
  echo "before - the previous tree, the README's line with Boot's web group at DEBUG (the embedded-Tomcat lesson's), port 19391 - a new customer, then POST /shutdown without the token:"
  entityrun .harness/before 19391
  echo "after - after/, the same line, port 19390:"
  entityrun .harness/after 19390
  echo "javap - the two return-value handlers, as after/'s spring-webmvc jar holds them (this unit's line, from .harness/after):"
  c="cd .harness/after && $L_JAVAP"; echo "\$ $c"; (eval "$c") > .harness/javap.txt 2>&1 < /dev/null || die "javap failed"
  echo "  exit 0 · in each class's handleReturnValue, the calls to ServletServerHttpResponse.flush - HttpEntityMethodProcessor: $(flushes .harness/javap.txt HttpEntityMethodProcessor) · RequestResponseBodyMethodProcessor: $(flushes .harness/javap.txt RequestResponseBodyMethodProcessor)"; }
# entityrun DIR PORT: the tree at DEBUG - the request-body lesson's POST, the secrets lesson's 403, the 403's status line and headers -
# then POST /shutdown with the token (its Content-Length printed by harness/shutdown.sh)
entityrun() { start "$(at "$1" "$2" "$R_WEB")"; up "$2"; ready "$2"
  dreq "$(url "$R_ADD" "$2")"
  dreq "$(url "$R_403" "$2")"
  hdr "$(url "$L_HEAD403" "$2")"
  stop "$2" "$1"; }

# ---- created: 201 and its Location ---------------------------------------------------------------------------------------------
SUNIL='{"name":"Sunil K","mealsPerDay":1,"pricePerMeal":130,"mealType":"VEG"}'
IRA='{"name":"Ira","mealsPerDay":1,"pricePerMeal":130,"mealType":"VEG"}'
EMPTY='{"name":"","mealsPerDay":0,"pricePerMeal":-5,"mealType":"LUNCH"}'
created() {
  echo "after/, the README's run line, port 19390 - a new customer, this unit's line in the anchor's README (its Location printed), then the Location followed:"
  start "$(at .harness/after 19390 "$R_RUN")"; up 19390; ready 19390
  pl 19390 "$ADATA"; fol
  echo "  a name with a space, the same line - and its Location followed:"
  pl 19390 "$SUNIL"; fol
  echo "  the verbs each path takes - OPTIONS on /customers, then on that Location:"
  ropt "$(url "$L_OPT" 19390)"
  ropt "$(printf '%s %s\n' "${L_OPT% http://*}" "$(cat .harness/loc.txt)")"
  echo "  a third name - the answer's status line and headers (this unit's line):"
  hdr "$(lc "$(url "$L_HEAD" 19390)" 19390 /customers "$IRA")"
  echo "  a body nothing checks yet - the request-body lesson's empty name - the same line, and its Location followed:"
  pl 19390 "$EMPTY"; fol
  ask 19390 /customers
  stop 19390 .harness/after; }

# ---- host: A/B/A' + C, D - the Location, and the request's Host header ---------------------------------------------------------
host() {
  bmeta spring-boot-web-server-4.1.1.jar server.forward-headers-strategy
  echo "A - after/, the README's run line, port 19390 - this unit's line in the anchor's README:"
  hosta
  echo "B - this unit's line: the same with -H 'Host: kitchen.localhost', on a fresh JVM, port 19390 (its Location printed, never followed):"
  start "$(at .harness/after 19390 "$R_RUN")"; up 19390; ready 19390
  lpl "$L_HOST" 19390 "$ADATA"; ask 19390 /customers/Asha
  stop 19390 .harness/after
  echo "A' - A again, on a fresh JVM:"
  hosta
  echo "A' against A, its label aside, line for line the same: $(asame 'A - after/' 'B - this unit' "A' - A again" 'C (labelled)')"
  echo "C (labelled) - this unit's line with -H 'X-Forwarded-Host: kitchen.localhost' -H 'X-Forwarded-Proto: https', on a fresh JVM, port 19390:"
  start "$(at .harness/after 19390 "$R_RUN")"; up 19390; ready 19390
  lpl "$L_FWD" 19390 "$ADATA"
  stop 19390 .harness/after
  echo "D (labelled) - the previous tree, the README's run line, port 19391 - the same line as A:"
  start "$(at .harness/before 19391 "$R_RUN")"; up 19391; ready 19391
  pl 19391 "$ADATA"
  stop 19391 .harness/before
  echo "E (labelled) - C's line on after/ with Boot told it runs on Kubernetes (the run line with --spring.main.cloud-platform=kubernetes), on a fresh JVM, port 19390 (its Location printed, never followed):"
  start "$(at .harness/after 19390 "$L_K8S")"; up 19390; ready 19390
  lpl "$L_FWD" 19390 "$ADATA"
  stop 19390 .harness/after; }
hosta() { start "$(at .harness/after 19390 "$R_RUN")"; up 19390; ready 19390
  pl 19390 "$ADATA"; fol
  stop 19390 .harness/after; }

# ---- conflict: before/A/C/A' - a taken name, by SQLSTATE -------------------------------------------------------------------------
RAVI2='{"name":"Ravi","mealsPerDay":1,"pricePerMeal":99,"mealType":"VEGAN"}'
ROHAN='{"name":"Rohan","mealsPerDay":1,"pricePerMeal":110,"mealTyp":"VEG"}'
# plantc FILE OUT: TiffinBoxServer.java with its one SQLSTATE test made a test of the exception's class - a planted fault for C
PLANTA='            if (NAME_TAKEN.equals(e.getSQLState())) {'
PLANTB='            if (e instanceof java.sql.SQLIntegrityConstraintViolationException) {'
plantc() { awk -v a="$PLANTA" -v b="$PLANTB" '$0 == a { print b; n++; next } { print } END { exit (n == 1 ? 0 : 1) }' "$1" > "$2" || die "plantc: the SQLSTATE line is not in $1 exactly once"; }
conflict() { local c
  echo "the JVM's locale on this capture's run lines - pinned before -jar, as each line below shows (H2 writes its messages in it):"
  c="java -Duser.language=en -Duser.country=US -XshowSettings:properties -version"; echo "\$ $c"
  (eval "$c") 2>&1 < /dev/null | awk '$1 == "user.language" || $1 == "user.country" { print "  " $1 " = " $3 }'
  echo "before - the previous tree, the pinned run line, port 19391 - a new name, a taken name, a misspelt key, each POSTed with its Location printed:"
  start "$(at .harness/before 19391 "$L_RUNL")"; up 19391; ready 19391
  pl 19391 "$ADATA"; p5 19391 "$RAVI2"; p5 19391 "$ROHAN"
  echo "  WARN lines in this run's log, at Boot's default level: $(logl 0 WARN | grep -c . || true) · ERROR lines: $(logl 0 ERROR | grep -c . || true)"
  stop 19391 .harness/before
  echo "A - after/, the pinned run line, port 19390:"
  conflicta
  echo "C (labelled) - a copy of after/ whose catch tests the exception's class instead of its SQLSTATE - its one changed line, then built the same way, port 19393:"
  copy after .harness/plant; plantc "after/$W/TiffinBoxServer.java" ".harness/plant/$W/TiffinBoxServer.java"
  echo "\$ diff -U0 after/$W/TiffinBoxServer.java .harness/plant/$W/TiffinBoxServer.java"
  diff -U0 "after/$W/TiffinBoxServer.java" ".harness/plant/$W/TiffinBoxServer.java" | tail -n +3 | sed 's/^/  /' || true
  pbuild .harness/plant "the planted copy"
  start "$(at .harness/plant 19393 "$L_RUNL")"; up 19393; ready 19393
  pl 19393 "$ADATA"; pl 19393 "$RAVI2"; pl 19393 "$ROHAN"; ask 19393 /customers/Rohan
  echo "  WARN lines in this run's log, at Boot's default level: $(logl 0 WARN | grep -c . || true) · ERROR lines: $(logl 0 ERROR | grep -c . || true)"
  stop 19393 .harness/plant
  echo "A' - A again, on a fresh JVM:"
  conflicta
  echo "A' against A, its label aside, line for line the same: $(asame 'A - after/' 'C (labelled)' "A' - A again" '')"; }
conflicta() { start "$(at .harness/after 19390 "$L_RUNL")"; up 19390; ready 19390
  pl 19390 "$ADATA"
  echo "  the same name again, then its status line and headers (this unit's line), then a name the database already had:"
  pl 19390 "$ADATA"; hdr "$(lc "$(url "$L_HEAD" 19390)" 19390 /customers "$ADATA")"; pl 19390 "$RAVI2"; ask 19390 /customers/Ravi
  echo "  a misspelt key:"
  p5 19390 "$ROHAN"
  echo "  WARN lines in this run's log, at Boot's default level: $(logl 0 WARN | grep -c . || true) · ERROR lines: $(logl 0 ERROR | grep -c . || true)"
  stop 19390 .harness/after; }

# ---- statuses: a name nobody has, four ways; a 201 by annotation; a Location with the query ------------------------------------
LATA='{"name":"Lata","mealsPerDay":1,"pricePerMeal":130,"mealType":"VEG"}'
statuses() { local p
  echo "after/ with the harness's Statuses joined, port 19392 - a name nobody has, then Ravi, asked four ways (this unit's status, type and length line):"
  start "$(hcp .harness/after 19392 probe.web.Statuses)"; up 19392; ready 19392
  for p in /customers/Nobody /probe/statuses/of/Nobody /probe/statuses/null/Nobody /probe/statuses/optional/Nobody /customers/Ravi /probe/statuses/of/Ravi /probe/statuses/null/Ravi /probe/statuses/optional/Ravi; do stl 19392 "$p"; done
  echo "  a 201 by annotation (@ResponseStatus(HttpStatus.CREATED)), POSTed with its Location printed:"
  pl 19392 "$LATA" /probe/statuses/annotated
  echo "  a query string on the request - the harness's route builds its Location with fromCurrentRequest(), TiffinBox's with fromCurrentRequestUri():"
  pl 19392 "$LATA" '/probe/statuses/where?via=app'
  pl 19392 "$LATA" '/customers?via=app'; fol
  echo "  WARN lines in this run's log, at Boot's default level: $(logl 0 WARN | grep -c . || true) · ERROR lines: $(logl 0 ERROR | grep -c . || true)"
  stop 19392 .harness/after; }

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
  echo "  the shell is now in: $(where "$d1") · the copy's own token in its log: $(raw "$(head -1 .harness/mine/after/$TF)" .harness/ex-readme.log) times · WARN lines in its log: $(grep -c ' WARN ' .harness/ex-readme.log || true) · listening on 19399 now: $(listeners 19399)"
  echo "the solution's $(printf '%s\n' "$sol" | grep -c .) lines, next, in the same shell:"
  printf '%s\n' "$sol" | sed 's/^/  $ /'
  echo "  exit $e2 · what they printed:"; sed 's/^/    /' .harness/ex-sol.out
  echo "  the shell is now in: $(where "$d2") · the copy's own token in its log: $(raw "$(head -1 .harness/mine/after/$TF)" .harness/mine/run.log) times · WARN lines in its log: $(grep -c ' WARN ' .harness/mine/run.log || true) · listening on 19399 now: $(listeners 19399)"; }

# ---- forms: the native build, what Spring's AOT step registered, then four forms ---------------------------------------------------
nbuild() { local ci cn s0 s1
  ci=$(off "$1" "$R_INSTALL" install); cn=$(off "$1" "$R_NATIVE")
  echo "\$ $ci"; mbuild "$ci" "$1.install.log" "$1 (both modules, into \$M2)"
  echo "\$ $cn"
  NB_E=0; s0=$(date +%s); (eval "$cn") > "$1.native.log" 2>&1 < /dev/null || NB_E=$?; s1=$(date +%s); NB_S=$((s1 - s0))
  echo "  (terminal only) the native build in $1 took $NB_S s - $( [ $NB_S -lt 1200 ] && echo under || echo OVER ) the 20-minute bound" >&3
  if ghub "$1.native.log"; then echo "  offline: no - GraalVM's native plugin went to GitHub for its metadata repository"; die "the native build in $1: GraalVM's native plugin went over the network - README.md, The repository"; fi; }
nlines() {
  echo "  its lines, in order (the rest - $(grep -cvE '^\[INFO\] --- |^\[INFO\] Found GraalVM|^ - Java version: |^Warning: |^\[[1-8]/8\] |^\[INFO\] BUILD |^The build process encountered ' "$1" || true) lines - not shown):"
  grep -E '^\[INFO\] --- .* @ tiffinbox-web ---$|^\[INFO\] Found GraalVM installation from ' "$1" | sed 's/^\[INFO\] /    /'
  grep -E '^ - Java version: ' "$1" | sed 's/^ - /    /'
  grep -E '^Warning: ' "$1" | sed -E "s/ in '(file:[^']*|null)'/ in '…'/" | sed 's/^/    /'
  grep -E '^\[[1-8]/8\] ' "$1" | sed 's/\.\.\..*$/.../' | sed 's/^/    /'
  grep -E '^The build process encountered |^\[INFO\] BUILD ' "$1" | sed 's/^\[INFO\] //' | sed 's/^/    /'; }
nresult() { echo "  exit $NB_E · $(grep -m1 -oE 'BUILD (SUCCESS|FAILURE)' "$1" || echo 'no BUILD line') · stages it printed: $(grep -cE '^\[[1-8]/8\] ' "$1" || true) of the $(grep -m1 -oE '^\[1/[0-9]+\]' "$1" | sed 's/.*\///; s/]//') it announces · its lines that say the metadata repository was downloaded over http, or failed to: $(grep -cE 'Downloaded GraalVM reachability metadata repository from http|Failed to download from http' "$1" || true) · offline: yes"; }
# aotmeta DIR: Spring's generated reachability metadata in DIR's web module (its AOT step's own file) - the entries for the record
# the routes read and return: what each registers
AOTF=tiffinbox-web/target/spring-aot/main/resources/META-INF/native-image/com.tiffinbox/tiffinbox-web/reachability-metadata.json
aotmeta() { python3 - "$1/$AOTF" <<'PY'
import json, sys
d = json.load(open(sys.argv[1])); refl = d.get("reflection", [])
def what(e):
    k = [x for x in ("allDeclaredFields", "allDeclaredConstructors") if e.get(x)]
    return " · ".join(["all declared fields" if x == "allDeclaredFields" else "all declared constructors" for x in k] + ["%d methods (%s)" % (len(e.get("methods", [])), " ".join(sorted(m["name"] for m in e.get("methods", []))))])
for t in ("com.tiffinbox.Customer",):
    c = [e for e in refl if e.get("type") == t]
    print("  Spring's generated metadata (%s): reflection entries naming %s: %d%s" % (sys.argv[1].split("/target/", 1)[1], t, len(c), (" - " + what(c[0])) if c else ""))
PY
}
# lbk LABEL: a form's loopback, read off its own block of this capture so far - every "listens on:" line of the block says
# "loopback only: yes" (the image: published on 127.0.0.1 alone, docker port, both runs)
lbk() { awk -v a="$1" 'index($0, a) == 1 { f = 1; next } /^[1-4] the / { f = 0 } f' .harness/cap.raw > .harness/blk.txt
  if [ "$1" = '4 the image' ]; then [ "$(grep -c '^  docker port: ' .harness/blk.txt)" = 2 ] && [ "$(grep -cE '^  docker port: 18425/tcp -> 127\.0\.0\.1:19397$' .harness/blk.txt)" = 2 ] && echo yes || echo no
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
# The header filter, checked on a planted answer before any capture: a Date header's value must come out "…", a CR must go, and the
# status line must keep its trailing space inside its brackets
printf 'HTTP/1.1 201 \r\nLocation: http://127.0.0.1:1/x\r\nDate: Wed, 14 Oct 2026 20:09:02 GMT\r\n\r\n' > .harness/planted-hdr.txt
PL=$(hdr 'cat .harness/planted-hdr.txt')
[ "$PL" = "$(printf '%s\n' '$ cat .harness/planted-hdr.txt' '  status line: [HTTP/1.1 201 ]' '  Location: http://127.0.0.1:1/x' '  Date: …')" ] || die "hdr: the planted answer's Date or carriage return survives the filter (.harness/planted-hdr.txt)"
rm -f .harness/planted-hdr.txt
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
# froutes PORT: a new customer with its Location printed (this unit's line in the anchor's README), the Location followed; the same
# name again; POST /shutdown without the token (the secrets lesson's line) - each answer printed (the timestamp masked)
froutes() { rl "$1" "$ADATA"; rfol; rl "$1" "$ADATA"; rp "$(url "$R_403" "$1")"; }
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
  echo "what Spring's AOT step registered for the native build - the record a route reads and the routes return:"
  aotmeta .harness/nat
  echo "1 the jar - .harness/after, the README's run line, port 19390:"
  start "$(at .harness/after 19390 "$R_RUN")"; up 19390; ready 19390; tline; seven 19390 .harness/after
  echo "  then a new customer, the same name again and POST /shutdown without the token, on a second start of the jar:"
  start "$(at .harness/after 19390 "$R_RUN")"; up 19390; ready 19390; froutes 19390; stop 19390 .harness/after
  echo "2 the AOT jar - .harness/nat (the profile native's jar), the README's AOT line, port 19394:"
  start "$(at .harness/nat 19394 "$R_AOTRUN")"; up 19394; ready 19394; tline; seven 19394 .harness/nat
  echo "  then the same three, on a second start of the AOT jar:"
  start "$(at .harness/nat 19394 "$R_AOTRUN")"; up 19394; ready 19394; froutes 19394; stop 19394 .harness/nat
  echo "3 the binary - .harness/nat, the README's line, port 19398:"
  start "$(at .harness/nat 19398 "$R_BIN")"; up 19398; ready 19398; tline; seven 19398 .harness/nat
  echo "  then the same three, on a second start of the binary:"
  start "$(at .harness/nat 19398 "$R_BIN")"; up 19398; ready 19398; froutes 19398; stop 19398 .harness/nat
  echo "4 the image - after/'s Dockerfile (the README's build line, this script's tag), the README's run line with your user, published on 127.0.0.1:19397:"
  image
  dstart "$(drun .harness/after 19397)"; ready 19397 "$BOX"; dbind 19397
  dseven 19397
  echo "  then the same three, on a second container of the image - TiffinBox listens on 18425 inside it:"
  dstart "$(drun .harness/after 19397)"; ready 19397 "$BOX"; dbind 19397
  froutes 19397
  post 19397 .harness/after; dgone "$BOX"; [ "$(listeners 19397)" = 0 ] || die "something still listens on 19397"
  dlog "$BOX"; echo "  exit $LASTE · its log (docker logs): the demo token 0 times · X-Shutdown-Token 0 times"
  docker rm "$BOX" > /dev/null
  echo "four forms, one tree: the seven (masked) $(grep -cE '^  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 2 · md5 87ca7efc8584dcccd40e6b956db1de9b$' .harness/cap.raw) of 4 times 87ca7efc8584dcccd40e6b956db1de9b · a new customer, 201 and a Location on 127.0.0.1 and the form's own port $(grep -cE '^  \{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"\} 201 · Location: \[http://127\.0\.0\.1:(19390|19394|19398|19397)/customers/Asha\]$' .harness/cap.raw) of 4, the Location followed 200 $(grep -cxF '  {"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 200' .harness/cap.raw) of 4 · the same name again 409 $(grep -cxF '   409 · Location: []' .harness/cap.raw) of 4 · POST /shutdown without the token 403 $(grep -cxF '  {"error":"forbidden"} 403' .harness/cap.raw) of 4"
  echo "  loopback, form by form: the jar $(lbk '1 the jar') · the AOT jar $(lbk '2 the AOT jar') · the binary $(lbk '3 the binary') · the image, published on 127.0.0.1 alone $(lbk '4 the image')"; }


cap entity entity
cap created created
cap host host
cap conflict conflict
cap statuses statuses
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
for f in .r-*.out README.md exercise/README.md exercise/solution/SOLUTION.md receipts.md5 harness/shutdown.sh $HW .harness/nat/$BIN; do
  [ -f "$f" ] || continue; case $f in .harness/nat*) NBIN=$((NBIN + 1)) ;; esac
  [ "$(raw "$TOKEN" "$f")" = 0 ] || die "$f holds the demo token, raw"; done
[ "$NBIN" = 1 ] || die "one binary was built, $NBIN were checked"
for f in .r-*.out; do ! grep -qE '/Users/|/private/|/home/|/var/folders/' "$f" || die "$f holds an absolute path"; [ -z "${GRAALVM_HOME:-}" ] || ! grep -qF "$GRAALVM_HOME" "$f" || die "$f holds the GraalVM's folder"; ! grep -qE 'c[0-9]-unit[0-9]|unit ?[0-9]' "$f" || die "$f holds a unit number"; ! grep -qE ' (with PID|started by) ' "$f" || die "$f holds Boot's process line"; ! grep -qE '^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T|"timestamp":"?[0-9]|timestamp=[A-Z0-9]|(exec|handler|task|utility)-[0-9]|GMT' "$f" || die "$f holds a log line's time, a timestamp, a date or a thread's number"; ! grep -q "^$(printf '\t')at " "$f" || die "$f shows a stack frame"; ! grep -qE 'sha256:[0-9a-f]{64}' "$f" || [ "$(grep -cE 'sha256:[0-9a-f]{64}' "$f")" = "$(grep -cE 'eclipse-temurin(:25-jre)?@sha256:[0-9a-f]{64}' "$f")" ] || die "$f holds an ID other than the base image's digest"; ! grep -qE ':8080([^0-9]|$)' "$f" || die "$f shows a bind on 8080"; ! grep -q $'\r' "$f" || die "$f holds a carriage return"; done
for f in receipts.sh README.md exercise/README.md exercise/solution/SOLUTION.md harness/shutdown.sh; do [ -f "$f" ] || continue; ! grep -qE "exposure\.include='?\*" "$f" || die "$f exposes every endpoint (R.42)"; ! grep -E 'server\.error\.' "$f" | grep -vE '^ *#' > /dev/null || die "$f names one of Boot 3's error keys (server, then error) - Boot 4.1 reads only spring.web.error.* (S2.13)"; done
for f in receipts.sh README.md exercise/README.md exercise/solution/SOLUTION.md; do [ -f "$f" ] || continue; ! grep -E 'docker run ' "$f" | grep -vE '^#' | grep -E ' -p "?[0-9]+:' > /dev/null || die "$f publishes a port on every address (-p without 127.0.0.1:)"; done
# A Location naming another host is printed, never followed: no capture runs a command with a URL that is not 127.0.0.1's
for f in .r-*.out; do ! grep -E '^\$ ' "$f" | grep -oE 'https?://[^ '"'"']+' | grep -vE '^http://127\.0\.0\.1:' > /dev/null || die "$f runs a command with a URL that is not 127.0.0.1's"; done
NL=$(cat .r-*.out | grep -cE "^  its log: the demo token 0 times · X-Shutdown-Token 0 times\$" || true)
echo "  tokens: 0 raw copies in $(ls .harness/raw-* | wc -l | tr -d ' ') raw capture runs, in $(ls .r-*.out | wc -l | tr -d ' ') captures; the demo token 0 in the logs of every JVM that served ($LOGS here; the published captures' $NL) and every container ($CLOGS here), the image's layers (forms), the READMEs, the harness, the exercise, receipts.md5 and the binary; no absolute path, no GraalVM folder, no unit number, no process line, no log time, no timestamp, no date, no thread number, no stack frame, no ID but the base image's digest, no 8080, no carriage return in any capture; every docker run publishes on 127.0.0.1 only; every command a capture runs asks 127.0.0.1"

S87C='87ca7efc8584dcccd40e6b956db1de9b'
WA() { printf '%s · WARN lines it added: %s' "$1" "$2"; }
E4XX() { printf '  {"timestamp":"…","status":%s,"error":"%s","path":"%s"}' "$1" "$2" "$3"; }
# the commands as a capture shows them ($ first): RQ 'LINE' PORT - a README line at PORT; LQ PORT 'BODY' [PATH] - this unit's Location
# line with that body; BQ PORT PATH - the one-customer line; HQ 'LINE' PORT - a Location-shaped line of this unit's with Asha's body;
# SQ PORT PATH - the status, type and length line
RQ() { printf '$ %s' "$(url "$1" "$2")"; }
LQ() { printf '$ %s' "$(plc "$1" "${3:-/customers}" "$2")"; }
BQ() { printf '$ %s' "$(bc "$1" "$2")"; }
HQ() { printf '$ %s' "$(lc "$1" "$2" /customers "$ADATA")"; }
SQ() { printf '$ %s' "$(stc "$1" "$2")"; }
[ "$(LQ 19390 "$ADATA")" = "\$ $(url "$R_LOC" 19390)" ] && [ "$(BQ 19390 /customers/Ravi)" = "\$ $(url "$R_ONE" 19390)" ] && [ "$(HQ "$L_HOST" 19390)" = "\$ $(url "$L_HOST" 19390)" ] && [ "$(SQ 19392 /customers/Nobody)" = "\$ $(url "$L_ST" 19392)" ] || die "the checks' own command lines are not the README's"
# aftn N CMDLINE BLOCK: the line after the Nth line of BLOCK that is exactly CMDLINE (aft: the first) - handed to awk through its
# environment, which keeps a backslash a backslash
aftn() { printf '%s\n' "$3" | C="$2" N="$1" awk 'f { print; exit } $0 == ENVIRON["C"] && ++k == ENVIRON["N"] { f = 1 }'; }
ASHA1='{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}'
A201() { printf '  %s 201 · Location: [%s]' "$ASHA1" "$1"; }
A200="  $ASHA1 200"
C409='   409 · Location: []'
E500L="$(E4XX 500 'Internal Server Error' /customers) 500 · Location: []"
H2DUP='    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: Servlet.service() for servlet [dispatcherServlet] in context with path [] threw exception [Request processing failed: org.h2.jdbc.JdbcSQLIntegrityConstraintViolationException: Unique index or primary key violation: "…"; SQL statement:'
H2DUPSQL='      INSERT INTO customer (name, meals_per_day, price_per_meal, meal_type) VALUES (?, ?, ?, ?) [23505-250]] with root cause'
H2NULL='    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: Servlet.service() for servlet [dispatcherServlet] in context with path [] threw exception [Request processing failed: org.h2.jdbc.JdbcSQLIntegrityConstraintViolationException: NULL not allowed for column "MEAL_TYPE"; SQL statement:'
H2SQL='      INSERT INTO customer (name, meals_per_day, price_per_meal, meal_type) VALUES (?, ?, ?, ?) [23502-250]] with root cause'
TRACE50='    its stack frames: over 50, its other lines: 4 - none shown · WARN lines it added: 0'

# "a status, headers and a body as one return value ... the add method returns one now, and so does shutdown, whose four oh three used to
#  be set on the servlet response; that parameter is gone. In the log, a different part of Spring MVC writes these answers ... Same bytes for
#  the four oh three. One header changed: ... it travels in chunks, with no length header. The seven still match."
EN=$(cat .r-entity.out); EB=$(blk entity 'before - the previous tree' 'after - after/'); EA=$(blk entity 'after - after/' 'javap - ')
x entity '^  built the previous tree · offline: yes · exit 0$'; x entity '^  built after/ · offline: yes · exit 0$'
[ "$(n entity '^  Files ')" = 2 ] && [ "$(n entity '^  Only in ')" = 0 ] || die "entity: two files differ, none added or deleted"
for f in README.md "$W/TiffinBoxServer.java"; do x entity "^  Files \.harness/before/$f and \.harness/after/$f differ\$"; done
x entity "^  after/'s files: 25 · byte for byte the previous tree's: 23 · those above differ: 2\$"
has "$EN" '  TiffinBoxServer.java: 215 lines -> 241 · its lines that are neither comment nor blank: 116 -> 127, of them - imports left out - naming a ResponseEntity: 0 -> 6 · the servlet response (HttpServletResponse, setStatus): 2 -> 0 · a SQLSTATE (getSQLState()): 0 -> 1' "entity: the counts"
has "$EN" "  its code lines' diff (diff -U0 of the lines above, its file names cut) - hunks: 10 · lines out: 9 · in: 20 - whole:" "entity: the diff's size"
for l in '    -import jakarta.servlet.http.HttpServletResponse;' '    +    private static final String NAME_TAKEN = "23505";' '    +    ResponseEntity<Customer> add(@RequestBody Customer customer) throws SQLException {' '    +            if (NAME_TAKEN.equals(e.getSQLState())) {' '    +                return ResponseEntity.status(HttpStatus.CONFLICT).build();' '    +            throw e;' '    +        URI location = ServletUriComponentsBuilder.fromCurrentRequestUri().path("/{name}")' '    +                .buildAndExpand(customer.name()).toUri();' '    +        return ResponseEntity.created(location).body(customer);' '    +    ResponseEntity<Map<String, Object>> shutdown(@RequestHeader(name = "X-Shutdown-Token", required = false) String token) {' '    -            response.setStatus(403);' '    +            return ResponseEntity.status(HttpStatus.FORBIDDEN).body(ordered("error", "forbidden"));' '    +        return ResponseEntity.ok(ordered("stopping", true));'; do has "$EN" "$l" "entity: the diff"; done
x entity "^the executable jar's BOOT-INF/lib: 56 jars -> 56 · the same names: yes\$"
has "$EN" "  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 2 · md5 $S87C" "entity: the seven, unchanged"
has "$EN" '  POST  /shutdown   -> 200 application/json  {"stopping":true}' "entity: the seven's POST line"
[ "$(aft "$(RQ "$R_ADD" 19391)" "$EB")" = "$A200" ] && [ "$(aft "$(RQ "$R_ADD" 19390)" "$EA")" = "  $ASHA1 201" ] || die "entity: the same POST, 200 before, 201 after"
[ "$(aft "$(RQ "$R_403" 19391)" "$EB")" = '  {"error":"forbidden"} 403' ] && [ "$(aft "$(RQ "$R_403" 19390)" "$EA")" = '  {"error":"forbidden"} 403' ] || die "entity: the 403's bytes, the same on both trees"
for b in "$EB" "$EA"; do has "$b" "  the lines the log gained for it, Boot's web group at DEBUG (logger: message) - all 6:" "entity: the POST's 6 lines"; has "$b" "  the lines the log gained for it, Boot's web group at DEBUG (logger: message) - all 5:" "entity: the 403's 5 lines"
  has "$b" '    s.w.s.m.m.a.RequestMappingHandlerMapping: Mapped to com.tiffinbox.web.TiffinBoxServer#add(Customer)' "entity: add mapped"
  has "$b" '    m.m.a.RequestResponseBodyMethodProcessor: Read "application/json;charset=UTF-8" to [Customer[name=Asha, mealsPerDay=2, pricePerMeal=110, mealType=VEG]]' "entity: the body read"
  has "$b" '    o.s.web.servlet.DispatcherServlet: Completed 403 FORBIDDEN' "entity: 403"; has "$b" '  status line: [HTTP/1.1 403 ]' "entity: the 403's status line"; done
for l in '    m.m.a.RequestResponseBodyMethodProcessor: Writing [Customer[name=Asha, mealsPerDay=2, pricePerMeal=110, mealType=VEG]]' '    o.s.web.servlet.DispatcherServlet: Completed 200 OK' '    s.w.s.m.m.a.RequestMappingHandlerMapping: Mapped to com.tiffinbox.web.TiffinBoxServer#shutdown(String, HttpServletResponse)' '    m.m.a.RequestResponseBodyMethodProcessor: Writing [{error=forbidden}]' '  Content-Length: 21' '  POST /shutdown -> 200 application/json · Content-Length: 17 · {"stopping":true} · curl exit 0'; do has "$EB" "$l" "entity before"; done
for l in '    o.s.w.s.m.m.a.HttpEntityMethodProcessor: Writing [Customer[name=Asha, mealsPerDay=2, pricePerMeal=110, mealType=VEG]]' '    o.s.web.servlet.DispatcherServlet: Completed 201 CREATED' '    s.w.s.m.m.a.RequestMappingHandlerMapping: Mapped to com.tiffinbox.web.TiffinBoxServer#shutdown(String)' '    o.s.w.s.m.m.a.HttpEntityMethodProcessor: Writing [{error=forbidden}]' '  Transfer-Encoding: chunked' '  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0'; do has "$EA" "$l" "entity after"; done
! printf '%s\n' "$EB" | grep -q 'HttpEntityMethodProcessor' && ! printf '%s\n' "$EA" | grep -qE 'RequestResponseBodyMethodProcessor: (Using|Writing)' || die "entity: who writes the answers - RequestResponseBodyMethodProcessor before, HttpEntityMethodProcessor after, and neither on the other tree"
nhas "$EB" '  Transfer-Encoding: chunked' "entity before: the 403 has its length"; nhas "$EA" '  Content-Length: 21' "entity after: the 403 has no length"
x entity '^  exit 0 · in each class.s handleReturnValue, the calls to ServletServerHttpResponse\.flush - HttpEntityMethodProcessor: 2 · RequestResponseBodyMethodProcessor: 0$'
echo "  entity: 2 files (TiffinBoxServer.java 215 -> 241, ResponseEntity 0 -> 6, the servlet response 2 -> 0, a SQLSTATE 0 -> 1; the README); 56 libraries, the same; the seven $S87C; at DEBUG the same POST 200 -> 201 and the same 403, RequestResponseBodyMethodProcessor -> HttpEntityMethodProcessor, shutdown(String, HttpServletResponse) -> shutdown(String); the 403 Content-Length 21 -> chunked, the shutdown's 17 -> none; javap: flush 2 vs 0"

# "Now a new customer gets two oh one, created, and a Location header ... Follow it: two hundred. A name with a space comes back encoded,
#  percent twenty, and that link works too. OPTIONS ... the collection takes POST, the new address takes GET ... An empty name is created too,
#  and its Location ends in a slash no route takes: four oh four."
CR=$(cat .r-created.out)
SUNIL1='{"name":"Sunil K","mealsPerDay":1,"pricePerMeal":130,"mealType":"VEG"}'
[ "$(aft "$(LQ 19390 "$ADATA")" "$CR")" = "$(WA "$(A201 http://127.0.0.1:19390/customers/Asha)" 0)" ] || die "created: Asha, 201 and her Location"
[ "$(aft "$(BQ 19390 /customers/Asha)" "$CR")" = "$(WA "$A200" 0)" ] || die "created: her Location followed, 200"
[ "$(aft "$(LQ 19390 "$SUNIL")" "$CR")" = "$(WA "  $SUNIL1 201 · Location: [http://127.0.0.1:19390/customers/Sunil%20K]" 0)" ] || die "created: a space, encoded %20"
[ "$(aft "$(BQ 19390 /customers/Sunil%20K)" "$CR")" = "$(WA "  $SUNIL1 200" 0)" ] || die "created: the encoded Location followed, 200"
[ "$(aft "$(RQ "$L_OPT" 19390)" "$CR")" = '  200 · Allow: [GET,HEAD,OPTIONS,POST] (the verbs sorted)' ] || die "created: OPTIONS /customers"
[ "$(aft "\$ ${L_OPT% http://*} http://127.0.0.1:19390/customers/Sunil%20K" "$CR")" = '  200 · Allow: [GET,HEAD,OPTIONS] (the verbs sorted)' ] || die "created: OPTIONS on the Location"
for l in '  status line: [HTTP/1.1 201 ]' '  Location: http://127.0.0.1:19390/customers/Ira' '  Content-Type: application/json' '  Transfer-Encoding: chunked' '  Date: …'; do has "$CR" "$l" "created: the 201's headers"; done
nhas "$CR" '  Content-Length: 0' "created: the 201 has a body"
[ "$(aft "$(LQ 19390 "$EMPTY")" "$CR")" = "$(WA '  {"name":"","mealsPerDay":0,"pricePerMeal":-5,"mealType":"LUNCH"} 201 · Location: [http://127.0.0.1:19390/customers/]' 0)" ] || die "created: the empty name created, its Location /customers/"
[ "$(aft "$(BQ 19390 /customers/)" "$CR")" = "$(WA "$(E4XX 404 'Not Found' /customers/) 404" 0)" ] || die "created: that Location, a 404"
[ "$(aft "$(BQ 19390 /customers)" "$CR" | grep -o '"name":"' | wc -l | tr -d ' ')" = 8 ] || die "created: 4 + 4 customers listed"
echo "  created: Asha 201 + Location, followed 200; Sunil K -> Sunil%20K, followed 200; OPTIONS GET,HEAD,OPTIONS,POST and GET,HEAD,OPTIONS (sorted); the 201's headers - Location, chunked; the empty name 201, its Location /customers/ a 404; 8 listed"

# "Not from TiffinBox's settings: from the request. A: ... and so does the Location. B: send a Host header ... of kitchen dot localhost, and the
#  Location says kitchen dot localhost. A again: the same. C: forwarded headers ... are ignored ... D: the previous tree answered two hundred,
#  with no Location at all."
HA=$(blk host 'A - after/' 'B - this unit'); HB=$(blk host 'B - this unit' "A' - A again"); HA2=$(blk host "A' - A again" "A' against A"); HC=$(blk host 'C (labelled)' 'D (labelled)'); HDD=$(blk host 'D (labelled)' 'E (labelled)'); HE=$(blk host 'E (labelled)' '')
x host "^  Boot's metadata \(spring-boot-web-server-4\.1\.1\.jar\) - server\.forward-headers-strategy · its type: ServerProperties\\\$ForwardHeadersStrategy · no default value · its description: Strategy for handling X-Forwarded-\* headers\.\$"
for b in "$HA" "$HA2"; do [ "$(aft "$(LQ 19390 "$ADATA")" "$b")" = "$(WA "$(A201 http://127.0.0.1:19390/customers/Asha)" 0)" ] && [ "$(aft "$(BQ 19390 /customers/Asha)" "$b")" = "$(WA "$A200" 0)" ] || die "host A/A': the request's 127.0.0.1 and port, followed 200"; done
[ "$(aft "$(HQ "$L_HOST" 19390)" "$HB")" = "$(WA "$(A201 http://kitchen.localhost/customers/Asha)" 0)" ] || die "host B: the Host header's name in the Location, no port"
[ "$(aft "$(BQ 19390 /customers/Asha)" "$HB")" = "$(WA "$A200" 0)" ] || die "host B: stored all the same"
x host "^A' against A, its label aside, line for line the same: yes\$"
[ "$(aft "$(HQ "$L_FWD" 19390)" "$HC")" = "$(WA "$(A201 http://127.0.0.1:19390/customers/Asha)" 0)" ] || die "host C: the forwarded headers ignored"
[ "$(aft "$(LQ 19391 "$ADATA")" "$HDD")" = "$(WA "$A200 · Location: []" 0)" ] || die "host D: the previous tree, 200 and no Location"
has "$HE" "\$ $(at .harness/after 19390 "$L_K8S")" "host E: the run line, Boot told it runs on Kubernetes"
[ "$(aft "$(HQ "$L_FWD" 19390)" "$HE")" = "$(WA "$(A201 https://kitchen.localhost/customers/Asha)" 0)" ] || die "host E: on Kubernetes, the forwarded headers read"
echo "  host: Boot's metadata (no default); A 127.0.0.1:19390 in the Location, followed 200; B Host: kitchen.localhost -> http://kitchen.localhost/customers/Asha (never followed); A' = A; C X-Forwarded-* ignored; D the previous tree 200, no Location; E Boot told it runs on Kubernetes: C's line -> https://kitchen.localhost/customers/Asha"

# "H2 refuses that row with SQLSTATE two three five oh five ... four oh nine, conflict, with no body, nothing in the log. The same name twice:
#  two oh one, then four oh nine ... A misspelt key ... two three five oh two, the very same exception class. A: it stays a five hundred. C, a
#  copy that catches the class: the typo becomes a conflict too, and the log says nothing. A again: as before."
KB=$(blk conflict 'before - the previous tree' 'A - after/'); KA=$(blk conflict 'A - after/' 'C (labelled)'); KC=$(blk conflict 'C (labelled)' "A' - A again"); KA2=$(blk conflict "A' - A again" "A' against A")
[ "$(aft "$(LQ 19391 "$ADATA")" "$KB")" = "$(WA "$A200 · Location: []" 0)" ] || die "conflict before: a new name 200"
[ "$(aft "$(LQ 19391 "$RAVI2")" "$KB")" = "$E500L" ] && has "$KB" "$H2DUP" "conflict before" && has "$KB" "$H2DUPSQL" "conflict before: 23505" || die "conflict before: a taken name, H2's 23505, a 500"
[ "$(aft "$(LQ 19391 "$ROHAN")" "$KB")" = "$E500L" ] && has "$KB" "$H2NULL" "conflict before" && has "$KB" "$H2SQL" "conflict before: 23502" || die "conflict before: the misspelt key, H2's 23502, a 500"
[ "$(printf '%s\n' "$KB" | grep -cxF -- "$TRACE50")" = 2 ] || die "conflict before: two traces of over 50 frames"
has "$KB" "  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 2" "conflict before: 2 ERROR lines"
x conflict '^  user\.language = en$'; x conflict '^  user\.country = US$'
for t in "before:19391" "after:19390" "plant:19393"; do x conflict "^\\\$ cd \\.harness/${t%%:*} && java -Duser\\.language=en -Duser\\.country=US -jar tiffinbox-web/target/tiffinbox-web-1\\.0\\.0\\.jar --tiffinbox\\.port=${t#*:}\$"; done
[ "$(n conflict '^\$ cd .* java -jar ')" = 0 ] || die "conflict: every run line pins the JVM's locale"
for b in "$KA" "$KA2"; do
  [ "$(aftn 1 "$(LQ 19390 "$ADATA")" "$b")" = "$(WA "$(A201 http://127.0.0.1:19390/customers/Asha)" 0)" ] && [ "$(aftn 2 "$(LQ 19390 "$ADATA")" "$b")" = "$(WA "$C409" 0)" ] || die "conflict A/A': the same name twice, 201 then 409"
  [ "$(aft "$(LQ 19390 "$RAVI2")" "$b")" = "$(WA "$C409" 0)" ] && [ "$(aft "$(BQ 19390 /customers/Ravi)" "$b")" = "$(WA '  {"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"} 200' 0)" ] || die "conflict A/A': a seed name 409, its row unchanged"
  [ "$(aft "$(LQ 19390 "$ROHAN")" "$b")" = "$E500L" ] && has "$b" "$H2NULL" "conflict A/A'" && has "$b" "$H2SQL" "conflict A/A': 23502" && has "$b" "$TRACE50" "conflict A/A': its trace" || die "conflict A/A': the misspelt key, still H2's 23502 and a 500"
  has "$b" '  status line: [HTTP/1.1 409 ]' "conflict A/A': the 409's status line"; has "$b" '  Content-Length: 0' "conflict A/A': the bodiless 409 has its length"; nhas "$b" '  Transfer-Encoding: chunked' "conflict A/A': the 409 is not chunked"
  ! printf '%s\n' "$b" | grep -q 'Unique index' || die "conflict A/A': a taken name never reaches the log"
  has "$b" "  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 1" "conflict A/A': 0 WARN, 1 ERROR (the misspelt key's)"; done
for l in '  @@ -146 +146 @@' "  -$PLANTA" "  +$PLANTB" '  built the planted copy · offline: yes · exit 0'; do has "$KC" "$l" "conflict C: the plant"; done
[ "$(aft "$(LQ 19393 "$ADATA")" "$KC")" = "$(WA "$(A201 http://127.0.0.1:19393/customers/Asha)" 0)" ] && [ "$(aft "$(LQ 19393 "$RAVI2")" "$KC")" = "$(WA "$C409" 0)" ] || die "conflict C: a new name 201, a taken one 409"
[ "$(aft "$(LQ 19393 "$ROHAN")" "$KC")" = "$(WA "$C409" 0)" ] && [ "$(aft "$(BQ 19393 /customers/Rohan)" "$KC")" = "$(WA "$(E4XX 404 'Not Found' /customers/Rohan) 404" 0)" ] || die "conflict C: the misspelt key called a conflict, nothing stored"
has "$KC" "  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0" "conflict C: nothing in the log"
x conflict "^A' against A, its label aside, line for line the same: yes\$"
echo "  conflict: the JVM's locale en_US, pinned on every run line; before 200, 500 (23505), 500 (23502), 2 ERROR; A 201, the same name 409, its headers Content-Length: 0, Ravi 409 (unchanged), the misspelt key 500 (23502), 0 WARN, 1 ERROR; C (the class) the misspelt key 409, 0 ERROR; A' = A"

# "Throwing ... four oh four, Boot's error body. Response entity of an empty optional: four oh four, no body. Returning null: two hundred,
#  nothing. Returning the optional itself: two hundred, the word null ... response status created ... adds no Location ... the full request URL
#  drags the query string along"
ST=$(cat .r-statuses.out)
[ "$(aft "$(SQ 19392 /customers/Nobody)" "$ST")" = "$(WA "$(E4XX 404 'Not Found' /customers/Nobody) · 404 · Content-Type: [application/json] · Content-Length: []" 0)" ] || die "statuses: TiffinBox's own 404, Boot's body"
[ "$(aft "$(SQ 19392 /probe/statuses/of/Nobody)" "$ST")" = "$(WA '   · 404 · Content-Type: [] · Content-Length: [0]' 0)" ] || die "statuses: ResponseEntity.of, 404 and no body"
[ "$(aft "$(SQ 19392 /probe/statuses/null/Nobody)" "$ST")" = "$(WA '   · 200 · Content-Type: [] · Content-Length: [0]' 0)" ] || die "statuses: null, 200 and no body"
[ "$(aft "$(SQ 19392 /probe/statuses/optional/Nobody)" "$ST")" = "$(WA '  null · 200 · Content-Type: [application/json] · Content-Length: [4]' 0)" ] || die "statuses: the Optional, 200 and null"
RAVIJ='{"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"}'
for p in /customers/Ravi /probe/statuses/null/Ravi /probe/statuses/optional/Ravi; do [ "$(aft "$(SQ 19392 $p)" "$ST")" = "$(WA "  $RAVIJ · 200 · Content-Type: [application/json] · Content-Length: [67]" 0)" ] || die "statuses: $p, Ravi with his length"; done
[ "$(aft "$(SQ 19392 /probe/statuses/of/Ravi)" "$ST")" = "$(WA "  $RAVIJ · 200 · Content-Type: [application/json] · Content-Length: []" 0)" ] || die "statuses: ResponseEntity.of for Ravi, chunked"
LATA1='{"name":"Lata","mealsPerDay":1,"pricePerMeal":130,"mealType":"VEG"}'
[ "$(aft "$(LQ 19392 "$LATA" /probe/statuses/annotated)" "$ST")" = "$(WA "  $LATA1 201 · Location: []" 0)" ] || die "statuses: @ResponseStatus(CREATED), 201 and no Location"
[ "$(aft "$(LQ 19392 "$LATA" '/probe/statuses/where?via=app')" "$ST")" = "$(WA "  $LATA1 201 · Location: [http://127.0.0.1:19392/probe/statuses/where/Lata?via=app]" 0)" ] || die "statuses: fromCurrentRequest keeps the query"
[ "$(aft "$(LQ 19392 "$LATA" '/customers?via=app')" "$ST")" = "$(WA "  $LATA1 201 · Location: [http://127.0.0.1:19392/customers/Lata]" 0)" ] && [ "$(aft "$(BQ 19392 /customers/Lata)" "$ST")" = "$(WA "  $LATA1 200" 0)" ] || die "statuses: TiffinBox's Location leaves the query out, followed 200"
has "$ST" "  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0" "statuses: nothing logged"
echo "  statuses: Nobody - TiffinBox's 404 + Boot's body, ResponseEntity.of 404 no body, null 200 no body, Optional 200 null; Ravi 200 each (ResponseEntity.of chunked); @ResponseStatus 201, no Location; fromCurrentRequest keeps ?via=app, fromCurrentRequestUri not; 0 WARN"

# the exercise's end state: the README's commands, then the solution's, in ONE env -i shell - each leaves the shell in this folder; the line
# exercise/README.md calls "Done" is a line of this capture, after the solution's lines, and of SOLUTION.md's measured run
XS=$(blk exercise "the README's" "the solution's"); XE=$(blk exercise "the solution's" '')
l="POST: 201 · Location: http://127.0.0.1:19399/customers/Sunil%20K · fetch: 200 · got: Sunil K"; l0="POST: 201 · Location: http://127.0.0.1:19399/customers/Sunil%20K · fetch: 000 · got: none"
has "$XE" "    $l" "exercise: the solution"; has "$XS" "    $l0" "exercise: as shipped"
awk '/^\*\*Done\*\*/ { f = 1 } f' exercise/README.md | grep -qxF -- "$l" || die "exercise/README.md: Done names no such line"
grep -qxF -- "$l" exercise/solution/SOLUTION.md || die "SOLUTION.md: the measured run shows no such line"
grep -qF -- "\`$l0\`" exercise/README.md || die "exercise/README.md: the shipped line's answer is not named"
has "$XS" '  exit 0 · what they printed:' "exercise: the README's commands, exit 0"; has "$XE" '  exit 0 · what they printed:' "exercise: the solution's lines, exit 0"
has "$XS" "  the shell is now in: this unit's folder · the copy's own token in its log: 0 times · WARN lines in its log: 0 · listening on 19399 now: 0" "exercise: the README's commands leave the shell in this unit's folder"
has "$XE" "  the shell is now in: this unit's folder · the copy's own token in its log: 0 times · WARN lines in its log: 0 · listening on 19399 now: 0" "exercise: the solution's lines leave the shell in this unit's folder"
[ "$(printf '%s\n' "$XE" | grep -c '^  \$ export ')" = 2 ] || die "exercise: SOLUTION.md gives the README's two export lines"
r=$(printf '%s\n' "$XS" | grep '^  \$ (cd \.harness/mine/after && ' | sed 's/^  \$ //'); r2=$(printf '%s\n' "$XE" | grep '^  \$ (cd \.harness/mine/after && ' | sed 's/^  \$ //')
F1='"$l")'; F2="'http://127.0.0.1:19399/customers/Sunil K')"; t=${r2/"$F1"/$F2}
[ "$t" = "$r" ] && [ "$r2" != "$r" ] || die "exercise: the solution's last line is the README's with the fetch's URL made the Location (\"\$l\"), and nothing else"
echo "  exercise: one env -i shell - the README as written -> 201, the Location, fetch 000 (curl refuses the raw space); the solution (\"\$l\") -> fetch 200, Sunil K; the shell in this unit's folder after each"

# "And every form, the jar, the AOT jar, built ahead of time, the native binary and the image, answers two oh one with a Location, four oh
#  nine for the same name, and four oh three without the token, all on loopback ... In the container TiffinBox listens on eighteen four
#  twenty-five, yet the Location names the port you asked"
x forms '^  exit 0 · BUILD SUCCESS · stages it printed: 8 of the 8 it announces · its lines that say the metadata repository was downloaded over http, or failed to: 0 · offline: yes$'
x forms '^  file: Mach-O 64-bit executable · the demo token in its bytes: 0$'
x forms '^  Spring.s generated metadata \(spring-aot/main/resources/META-INF/native-image/com\.tiffinbox/tiffinbox-web/reachability-metadata\.json\): reflection entries naming com\.tiffinbox\.Customer: 1 - all declared fields · all declared constructors · 4 methods \(mealType mealsPerDay name pricePerMeal\)$'
x forms "^four forms, one tree: the seven \(masked\) 4 of 4 times $S87C · a new customer, 201 and a Location on 127\.0\.0\.1 and the form's own port 4 of 4, the Location followed 200 4 of 4 · the same name again 409 4 of 4 · POST /shutdown without the token 403 4 of 4\$"
x forms '^  loopback, form by form: the jar yes · the AOT jar yes · the binary yes · the image, published on 127\.0\.0\.1 alone yes$'
# each form's block runs from its label to the next form's (a label:port:next label triple - a case inside $( ) is a syntax error to
# /bin/bash 3.2)
for t in '1 the jar:19390:2 the AOT jar' '2 the AOT jar:19394:3 the binary' '3 the binary:19398:4 the image' '4 the image:19397:four forms, one tree'; do lb_=${t%%:*}; r_=${t#*:}; p_=${r_%%:*}; nx_=${r_#*:}
  b=$(blk forms "$lb_ - " "$nx_")
  has "$b" "$(A201 "http://127.0.0.1:$p_/customers/Asha")" "forms $lb_: 201 and the Location on its own port"
  has "$b" "\$ curl -s -w ' %{http_code}\\n' http://127.0.0.1:$p_/customers/Asha" "forms $lb_: the Location followed"
  has "$b" "  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 2 · md5 $S87C" "forms $lb_: the seven"; done
[ "$(n forms "^  Boot's first line: Starting AOT-processed TiffinBoxServer v1\.0\.0 using Java 25\.0\.4\.1\$")" = 2 ] && [ "$(n forms "^  Boot's first line: Starting AOT-processed TiffinBoxServer using Java 25\.0\.4\.1\$")" = 2 ] || die "forms: the AOT jar and the binary, AOT-processed, both starts"
[ "$(n forms '^  inside the container, listening: \[::\]:18425$')" = 2 ] && [ "$(n forms '^  docker port: 18425/tcp -> 127\.0\.0\.1:19397$')" = 2 ] || die "forms: the image, two containers, 18425 inside, published on 127.0.0.1:19397 alone"
x forms '^  its lines that say pull: 0 · '
x forms '^  the image saved \(docker save\): [1-9][0-9]* blobs, its [1-9][0-9]* layers among them, each read whole \(gzip ones unpacked\) · the demo token in them: 0$'
echo "  forms: 8 of 8 stages, offline, Mach-O, 0 tokens; Customer in the AOT step's metadata; the jar, the AOT jar, the binary, the image: the seven $S87C 4 of 4, a new customer 201 + its form's own Location 4 of 4, followed 200 4 of 4, the same name 409 4 of 4, the 403 4 of 4; the image's Location 127.0.0.1:19397 while it listens on 18425 inside; loopback form by form; the image's layers 0 tokens"

cmp -s after/README.md ../c6-tiffinbox/README.md || echo "  (after/README.md and ../c6-tiffinbox/README.md differ - the anchor has moved past this unit's after/)" >&3
[ -z "$unpub" ] || die "no published hash for:$unpub - check the captures, then copy the md5s above into receipts.md5 and run again"
echo "c6-unit10: every capture 3/3 and = published; every spoken number asserted; 0 raw demo tokens in every capture, every log, the container's log, the image's layers and the binary; nothing of this run left on Docker"
