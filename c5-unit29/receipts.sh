#!/bin/bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25.0.4.1 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# GRAALVM_HOME names a GraalVM JDK 25 (README.md, "The GraalVM"): the native build reads it. Without it, this script makes every
# capture that needs no GraalVM - the JVM's, Docker's, Compose's and the exercise's - filling .m2-demo on the way, then stops
# before the native build.
# Course 5 · Capstone: TiffinBox Boots - this unit's receipts. One tree, five forms: the executable jar, the jar ahead of time
# (Spring's AOT), the native binary, the image (the anchor's Dockerfile) and the developer's class path with its database (the
# anchor's compose.yaml). Each serves the same seven answers and readiness 200; Actuator, the meters, the logs, failure analysis
# and the bare-argument refusal are shown on the forms that carry them. This unit changes NOTHING in the anchor (brief ⚑11):
# the tree is ../c5-unit27/after, read and copied, never built in place. Eight captures, each run three times and hashed; cap()
# DIES when a hash differs from receipts.md5; every number the video says is asserted at the bottom by a check that can fail; the
# demo token is masked (gsub), and the checks count 0 raw copies of it in every capture, in the log of every run - every failed
# start's, every container's included - in every file this unit ships, and in the binary it builds.
#   image     the anchor README's two lines - mvn -B package, then docker build (plain progress, this script's own tag) - and its
#             docker run line with your user added: the build's network lines, the base image's digest, the image's user and
#             entrypoint; readiness, the seven, docker wait 0, the container's log (the token 0 times)
#   fails     the break, one argument: A the jar, the README's run line · B the same line and a bare 19151 · A' = A; then a port
#             taken (the failure lesson's two sentences, on the jar) · D (labelled): a bare 19151 after the image name · E
#             (labelled): the action's own option after the image name - the container's port moves, the published one answers
#             nothing
#   ops       operating it, on the JVM: health and its groups, the kitchen in readiness; a level changed while it runs (loggers,
#             exposed by a flag); six of the seven requests; the scrape - the kitchen's two counters and one timer series per
#             route; one DEBUG line per answer, from the POST on
#   dev       the README's dev line on the anchor's own compose.yaml (project tiffinbox-dev, Postgres on 127.0.0.1:18881): the
#             file's project name read back, and what an inherited COMPOSE_PROJECT_NAME does to it; Compose's lines, the seven,
#             exit 0, the container Exited (0) by Boot's stop; then docker compose -p tiffinbox-dev down -v
#   promises  the course's first promise, one capture line each: auto-configuration (the jar's imports files and entries, and
#             how many applied - the condition report of --debug), Actuator (health, the scrape), one runnable jar (java -jar,
#             the seven), Docker (the image, the seven)
#   exercise  exercise/README.md's commands and exercise/solution/SOLUTION.md's, read from the files and run as written
#   native    the tree built natively (the README's two Maven lines): the binary - readiness, health, the scrape, loggers by
#             flag (404: the build fixed the endpoints), a port taken (the two sentences), the seven; C (labelled): a bare 19151
#   forms     one tree, five forms - the jar, the AOT jar, the binary, the image, the dev class path: each one's readiness and
#             the seven
# "The tree" is ../c5-unit27/after (the anchor as the command-line lesson left it; ../c5-tiffinbox holds the same files),
# COPIED under .harness/; this script never writes into another unit's folder. Every run of TiffinBox starts in a folder under
# .harness/ that holds a config tree with the demo token (secrets/), as the README asks - the container's too, mounted read-only.
# Commands are printed exactly as they run: each goes through eval. "$CURLSET" is the comparison set since the secrets lesson
# (../c5-unit11/curlset.sh: the seven requests, POST /shutdown with the token's header read from the file). "$M2" is this unit's
# own repository, .m2-demo. No harness class: harness/six.sh (six GETs) and harness/shutdown.sh (POST /shutdown with the token
# read from its file) are shell. Every run passes options only, except the three that show the refusal (brief ⚑18).
# The network: every Maven build runs offline (-o) against .m2-demo and says so ("offline: yes"); a build that cannot resolve an
# artifact offline goes to Maven Central once, and says that ("offline: no - ..."). GraalVM's native plugin reads its metadata
# repository (a zip) from .m2-demo - and when the zip is not there it downloads it from GitHub, even under -o: so a native-profile
# build without the zip goes to Maven Central for it at once, and every build's log is searched for the plugin's own download
# line - found, the run stops. Docker: no pull - the two base images must already be on the daemon (eclipse-temurin:25-jre for
# the Dockerfile, postgres:18-alpine for compose.yaml), and each docker build and each Compose start prints how many of its lines
# say pull. At run time nothing leaves 127.0.0.1: TiffinBox listens there (in a container, on the container's own addresses,
# published on the host's 127.0.0.1 alone), every request goes there, and Logback writes to the terminal only.
# Masks and filters (README.md declares each; sub/gsub only): the demo token becomes "[masked: the 26-character token]"; the
# GraalVM's folder "$GRAALVM_HOME"; this folder's absolute path "…", the folder above it "…/..", the home folder "~"; your user
# name "<user>" - in every line of every capture. A failed start's log is read after it exited, never printed whole (the failure
# lesson's shape: frames counted, the analysis shown). A run's log lines are printed from their message on (no time, no process
# id); Boot's first line is cut before " with PID" (in a container it goes on "started by ? in /app": never printed). JSON
# answers from Actuator are printed with their keys sorted (the bridge writes them in the order reflection lists them, which has
# moved under load); a scrape is filtered to TiffinBox's own meters, and a timer's series to their count lines (its sums and
# maxima are seconds). docker build is read through a filter: its metadata line, its FROM line (the base image's digest) and its
# naming line - step numbers and timings cut, the rest counted. No image, container or volume ID is printed. Compose's own
# lines are shown sorted (Compose creates the network and the volume side by side, so their order moves). No duration is
# captured: the native build is judged against a bound; seconds go to the terminal.
# Ports (brief ⚑1, 19150-19159): fails A, A' and the port taken, forms' jar 19150 · the bare argument 19151 (never bound) · ops
# 19152 · promises' jar 19153 · forms' AOT jar 19154 · the image 19155 (image, fails D, promises, forms) · dev 19156 · the binary
# 19157 · the exercise 19159. And Compose's Postgres on 127.0.0.1:18881 - the anchor's compose.yaml (brief ⚑12). 18425 (TiffinBox's
# default) and 8080 (Tomcat's) are checked free too, and never bound on this machine (18425 only inside a container).
# Docker names (no unit number, brief S5.17): the image tiffinbox-capstone:1.0.0 and the container tiffinbox-capstone; the
# exercise's tiffinbox-mine:1.0.0 and tiffinbox-mine; the Compose project tiffinbox-dev (compose.yaml's name:) - its network
# tiffinbox-dev_default, its container tiffinbox-dev-postgres-1, its volume tiffinbox-dev_data. Each is checked absent before the
# first run - a name already there may be yours, and this script removes only what it creates - and removed on every exit: the
# containers with docker rm -f, the images by name and by every ID a build of this run recorded, the project with docker compose
# -p tiffinbox-dev down -v. Docker's build cache is not pruned: .dockerignore keeps secrets/ out of every build context, so the
# cache holds no token.
set -e
# bash 5.2 and later turn an & in the replacement of ${x/pattern/replacement} into the matched text (patsub_replacement, on by
# default). Switched off, so /bin/bash 3.2 (./receipts.sh) and a newer bash (bash receipts.sh) run the same commands; 3.2 has no
# such option. (exe() inserts its "exec" with sed, not with ${x/a/b}.)
shopt -u patsub_replacement 2> /dev/null || true
cd "$(dirname "$0")"
# One run at a time: two runs share .harness/, the ports and the Docker names, and one would corrupt the other.
mkdir .r-lock 2> /dev/null || { echo "  *** another receipts.sh is running in this folder (.r-lock exists) - if none is, rmdir .r-lock ***"; exit 1; }
IMG=tiffinbox-capstone:1.0.0; BOX=tiffinbox-capstone; XIMG=tiffinbox-mine:1.0.0; XBOX=tiffinbox-mine; PROJ=tiffinbox-dev
OURS=""                                              # set once the start-up checks found none of the Docker names above
# On every exit - the end, a failed check, or Ctrl-C - stop the processes this script started in the background ($pid, a server;
# $fpid, a start expected to end by itself), if they still run, then sweep(): anything of this run still alive in its process
# group - a TiffinBox JVM, a binary, native-image's driver or builder, a docker command Boot's Compose support started - is
# stopped; then dclean(): this run's containers, images and Compose project. After an interrupt, a capture's unfinished runs
# (.r-NAME.1-3) go too; after a failed check they stay, for the diff the message names. The clean-up ignores a second Ctrl-C, and
# nothing in it can fail under set -e, so it always reaches the rmdir; the script still exits 130 after an interrupt (README.md,
# "Interrupted"). $pid and $fpid are cleared whenever their process has been reaped.
pid=""; fpid=""
sweep() { local g i l
  g=$(ps -o pgid= -p $$ 2> /dev/null | tr -d ' ') || g=""
  [ -n "$g" ] || return 0
  i=0; while [ $i -lt 20 ]; do
    l=$(ps -axo pid=,pgid=,command= 2> /dev/null | awk -v g="$g" -v me=$$ -v gh="${GRAALVM_HOME:-/nonexistent}" '
      $2 == g && $1 != me && $3 != "awk" && $3 != "ps" && (index($0, "vminvocation.args") || index($3, gh "/bin/native-image") || $3 ~ /tiffinbox-web\/target\/tiffinbox-web$/ || index($0, "tiffinbox-web-1.0.0.jar") || index($0, "com.tiffinbox.web.TiffinBoxServer") || index($0, "compose --file ")) { print $1 }' | paste -sd' ' -) || l=""
    [ -n "$l" ] || return 0
    if [ $i -lt 10 ]; then kill $l 2> /dev/null || true; else kill -9 $l 2> /dev/null || true; fi
    sleep 0.5; i=$((i + 1)); done; }
# projcount: the containers, volumes and networks Docker lists for the Compose project, by its label
projcount() { local c v n
  c=$(docker ps -aq --filter "label=com.docker.compose.project=$PROJ" 2> /dev/null | grep -c . || true)
  v=$(docker volume ls -q --filter "label=com.docker.compose.project=$PROJ" 2> /dev/null | grep -c . || true)
  n=$(docker network ls -q --filter "label=com.docker.compose.project=$PROJ" 2> /dev/null | grep -c . || true)
  echo $((c + v + n)); }
dclean() { local k=0
  [ -n "$OURS" ] || return 0
  docker rm -f "$BOX" "$XBOX" > /dev/null 2>&1 || true
  while [ "$(projcount)" != 0 ] && [ $k -lt 15 ]; do docker compose -p "$PROJ" down -v > /dev/null 2>&1 || true; k=$((k + 1)); [ "$(projcount)" = 0 ] || sleep 1; done
  docker image rm -f "$IMG" "$XIMG" $(sort -u .harness/imgids 2> /dev/null) > /dev/null 2>&1 || true; }
trap 'trap "" INT TERM; for p in "$pid" "$fpid"; do if [ -n "$p" ] && kill "$p" 2> /dev/null; then wait "$p" 2> /dev/null || true; fi; done; sweep || true; dclean || true; [ -z "$INTR" ] || rm -f .r-*.[123]; rmdir .r-lock 2> /dev/null || true' EXIT
INTR=""; trap 'INTR=1; exit 130' INT TERM
exec 3>&1                                            # die() speaks to the terminal even inside a redirected capture
die() { echo "  *** $* ***" >&3; exit 1; }
java -version 2>&1 | grep -q 'version "25' || die "JDK 25 needed; JAVA_HOME gives: $(java -version 2>&1 | head -1)"
command -v python3 > /dev/null || die "python3 is needed: JSON answers, the scrape and the condition report are read through filters"
command -v curl > /dev/null || die "curl is needed: every request here is curl's"
command -v rsync > /dev/null || die "rsync is needed: every tree is copied with it"
command -v docker > /dev/null || die "docker is needed: the image and Compose are two of the five forms"
# A variable of yours must not become a property source, a JVM flag, a build setting, a native-image option, a Compose setting or
# a docker build setting: every TIFFINBOX_*, SPRING_*, MANAGEMENT_*, SERVER_*, LOGGING_*, COMPOSE_* (an inherited
# COMPOSE_PROJECT_NAME renames the project Boot starts - measured, the dev capture), BUILDKIT_* and BUILDX_* variable, DEBUG (Boot
# reads it as --debug), the variables that inject JVM flags, MAVEN_OPTS, MAVEN_ARGS, NATIVE_IMAGE_OPTIONS, DOCKER_BUILDKIT,
# DOCKER_DEFAULT_PLATFORM and SOURCE_DATE_EPOCH are removed first. GRAALVM_HOME stays: it says which GraalVM to use; so do
# DOCKER_HOST and DOCKER_CONTEXT: they say which Docker answers.
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
  echo "  GRAALVM_HOME is not set: this run fills .m2-demo, makes the captures that need no GraalVM - the JVM's, Docker's, Compose's and the exercise's - and stops before the native build (README.md, The GraalVM)"
else
  [ -x "$GRAALVM_HOME/bin/native-image" ] || die "GRAALVM_HOME must name a GraalVM JDK 25 (its bin/native-image) - README.md, The GraalVM"
  NIV=$("$GRAALVM_HOME/bin/native-image" --version 2>&1 || true)
  printf '%s\n' "$NIV" | grep -q '^native-image 25\.0\.4\.1 ' && printf '%s\n' "$NIV" | grep -q 'GraalVM CE 25\.3\.4\.1+1\.1' || die "the published captures were made with GraalVM CE 25.3.4.1 (native-image 25.0.4.1); GRAALVM_HOME gives: $(printf '%s\n' "$NIV" | head -1)"
  export GRAALVM_HOME; fi
# Docker: it must answer, Compose must be there, and both base images must already be on the daemon - this script never pulls.
docker info > /dev/null 2>&1 || die "Docker does not answer - start it (OrbStack: orb start; Docker Desktop: open it), then run again"
docker compose version > /dev/null 2>&1 || die "docker compose is needed: the dev form is the anchor's compose.yaml"
for b in eclipse-temurin:25-jre postgres:18-alpine; do docker image inspect "$b" > /dev/null 2>&1 || die "$b is not on this Docker - pull it once (docker pull $b: network, a build-time resolution), then run again"; done
TREE=anchor                                          # the tree: a link to ../c5-unit27/after, the anchor as the command-line lesson left it - read, copied
[ -e secrets ] && die "this folder holds a secrets/ - remove it: every run here starts in a folder under .harness/"
[ -f "$TREE/pom.xml" ] && [ -f "$TREE/README.md" ] && [ -f "$TREE/Dockerfile" ] && [ -f "$TREE/.dockerignore" ] && [ -f "$TREE/compose.yaml" ] || die "the tree $TREE (its pom.xml, README.md, Dockerfile, .dockerignore or compose.yaml) is missing"
[ -e "$TREE/secrets" ] || [ -e "$TREE/target" ] || [ -e "$TREE/tiffinbox-web/target" ] && die "$TREE holds a secrets/ or a target/ - it is a frozen copy, never built in place"
grep -qx 'secrets/' "$TREE/.dockerignore" || die "the tree's .dockerignore no longer keeps secrets/ out of a build context"
M2="$PWD/.m2-demo"; U="$PWD"; UP="$(cd .. && pwd)"; ME="$(id -un)"
BIN=tiffinbox-web/target/tiffinbox-web               # the binary native:compile-no-fork writes, in a tree's web module
JARP=tiffinbox-web/target/tiffinbox-web-1.0.0.jar    # the executable jar, in a tree's web module
CPF=tiffinbox-web/target/classpath.txt               # the class path the README's class-path line writes
TF=secrets/tiffinbox/shutdown-token                  # the config tree's file for tiffinbox.shutdown-token
# The demo token. FAKE, and meant to look it: it guards nothing but a demo server on 127.0.0.1 that every capture stops. It is
# written into .harness/*/secrets/ (git-ignored) when this script runs, and no capture prints it: see mask().
TOKEN=not-a-real-token-demo-only
[ ${#TOKEN} = 26 ] || die "the demo token must be 26 characters"
CURLSET=../c5-unit11/curlset.sh                      # the comparison set: the seven requests, POST /shutdown with the header
[ -f "$CURLSET" ] || die "$CURLSET is missing"
for f in harness/shutdown.sh harness/six.sh exercise/README.md exercise/solution/SOLUTION.md; do [ -f "$f" ] || die "$f is missing"; done

# The ports and the Docker names, BEFORE anything is wiped.
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
for p in 18425 8080 18881 19150 19151 19152 19153 19154 19155 19156 19157 19158 19159; do
  [ "$(listeners $p)" = 0 ] || die "something already listens on $p - this unit's ports must be free; if it is a TiffinBox or a container an interrupted run left behind, stop it"; done
for b in "$BOX" "$XBOX"; do [ -z "$(docker ps -aq --filter "name=^$b\$" 2> /dev/null)" ] || die "a container named $b exists - it may be yours, and this script removes only what it creates; remove it yourself (docker rm -f $b), then run again"; done
for i in "$IMG" "$XIMG"; do docker image inspect "$i" > /dev/null 2>&1 && die "an image named $i exists - it may be yours; remove it yourself (docker image rm $i), then run again"; done
[ "$(projcount)" = 0 ] || die "Docker lists containers, volumes or networks of the Compose project $PROJ - a dev run of TiffinBox left them, or another unit or RED is using it (brief ⚑12: it is one unit's at a time). This script removes only what it creates; remove them yourself (docker compose -p $PROJ down -v), then run again"
OURS=yes

# ---- the commands: read from the tree's README.md, the anchor's own, and asserted - each line must be there, whole -----------
readme() { grep -m1 -xF -- "$1" "$TREE/README.md" > /dev/null || die "$TREE/README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
R_PLAIN=$(readme 'mvn -B package')
R_CPB=$(readme 'mvn -B package dependency:build-classpath -Dmdep.outputFile=target/classpath.txt')
R_RUN=$(readme 'java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431')
R_DEBUG=$(readme 'java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --debug')
R_LOGX=$(readme 'java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --management.endpoints.web.exposure.include=health,prometheus,loggers')
R_SHOWC=$(readme 'java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --management.endpoint.health.show-components=always')
R_AOTRUN=$(readme 'java -Dspring.aot.enabled=true -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431')
R_GRAAL=$(readme 'export GRAALVM_HOME=/path/to/a/graalvm-jdk-25')
R_INSTALL=$(readme 'mvn -B -Pnative install')
R_NATIVE=$(readme 'mvn -B -Pnative -pl tiffinbox-web native:compile-no-fork')
R_BIN=$(readme 'tiffinbox-web/target/tiffinbox-web --tiffinbox.port=18431')
R_BINLOGX=$(readme 'tiffinbox-web/target/tiffinbox-web --tiffinbox.port=18431 --management.endpoints.web.exposure.include=health,prometheus,loggers')
R_DEV=$(readme 'java -cp "tiffinbox-web/target/classes:$(cat tiffinbox-web/target/classpath.txt)" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431 --spring.profiles.active=dev')
R_DBUILD=$(readme 'docker build -t tiffinbox-docker:1.0.0 .')
R_DRUN=$(readme 'docker run -d --name tiffinbox -m 512m -v "$PWD/secrets:/app/secrets:ro" -p 127.0.0.1:18431:18425 tiffinbox-docker:1.0.0')
R_READY=$(readme "curl -s -w ' %{http_code}\n' http://127.0.0.1:18431/actuator/health/readiness")
R_HEALTH=$(readme "curl -s -w ' %{http_code}\n' http://127.0.0.1:18431/actuator/health")
R_KITCHEN=$(readme "curl -s -w ' %{http_code}\n' http://127.0.0.1:18431/kitchen")
R_SCRAPE=$(readme "curl -s -o scrape.txt -w '%{http_code} %{content_type}\n' http://127.0.0.1:18431/actuator/prometheus")
R_LOGPOST=$(readme "curl -s -w ' %{http_code}\n' -X POST -H 'Content-Type: application/json' -d '{\"configuredLevel\":\"DEBUG\"}' http://127.0.0.1:18431/actuator/loggers/kitchen")
R_LOGGERS=$(readme "curl -s -o loggers.json -w '%{http_code}\n' http://127.0.0.1:18431/actuator/loggers")
# off DIR 'README mvn LINE' [PHASE]: the README's Maven line as this script runs it - from DIR, offline (-o), this unit's own
# repository, and for a build phase (package, install) clean and without tests. dev() takes those four things back out, and
# must give the README's line again: so the command on screen is the README's, with exactly those changes.
off() { local c=${2/mvn -B /mvn -o -B -Dmaven.repo.local=\"\$M2\" }
  [ -n "$3" ] && c=${c/ $3/ -DskipTests clean $3}
  printf 'cd %s && %s\n' "$1" "$c"; }
dev() { local c=${1#cd * && }; c=${c/ -o -B -Dmaven.repo.local=\"\$M2\" / -B }; c=${c/ -DskipTests clean / }; printf '%s\n' "$c"; }
# at DIR PORT 'README LINE': the README's line run from DIR, its port 18431 made PORT
at() { printf 'cd %s && %s\n' "$1" "${3/--tiffinbox.port=18431/--tiffinbox.port=$2}"; }
# url 'README curl LINE' PORT: the README's curl line, its port 18431 made PORT
url() { printf '%s\n' "${1/:18431\//:$2/}"; }
# exe 'COMMAND': the command with "exec" after its "cd DIR && " - so $pid is the program's own
exe() { printf '%s\n' "$1" | sed -E 's/&& (([A-Z_]+=[^ ]* )*)/\&\& \1exec /'; }
# The ops line: the README's loggers line (health, prometheus and loggers exposed for one run) with the readiness line's flag from
# the health lesson (components shown) added - both flags the README gives, on one start
SHOWC=${R_SHOWC#java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 }
[ "$SHOWC" = '--management.endpoint.health.show-components=always' ] || die "the health lesson's flag"
R_OPS="$R_LOGX $SHOWC"
# The docker lines, as this script runs them: the README's build line with plain progress and this script's own tag; its run line
# with this script's own name and tag, the port published on 127.0.0.1 made PORT, and your user and group added - the config
# tree is yours, mode 0600 (brief S5.27). undock() takes those changes back out, and must give the README's lines again.
UARG='--user "$(id -u):$(id -g)"'
dbuild() { local c=${R_DBUILD/docker build -t tiffinbox-docker:1.0.0 /docker build --progress=plain -t $IMG }; printf 'cd %s && %s\n' "$1" "$c"; }
drun() { local c=${R_DRUN/--name tiffinbox /--name $BOX $UARG }; c=${c/127.0.0.1:18431:18425/127.0.0.1:$2:18425}; c=${c/% tiffinbox-docker:1.0.0/ $IMG}; printf 'cd %s && %s%s\n' "$1" "$c" "${3:+ $3}"; }
undock() { local c=${1#cd * && }; c=${c/--progress=plain /}; c=${c/" $UARG"/}; c=${c//$IMG/tiffinbox-docker:1.0.0}; c=${c/--name $BOX /--name tiffinbox }; c=${c/127.0.0.1:1915?:18425/127.0.0.1:18431:18425}; printf '%s\n' "$c"; }
[ "$(undock "$(dbuild .harness/x)")" = "$R_DBUILD" ] || die "not the README's build line with the declared changes: $(dbuild .harness/x)"
[ "$(undock "$(drun .harness/x 19155)")" = "$R_DRUN" ] || die "not the README's run line with the declared changes: $(drun .harness/x 19155)"
[ "$(drun .harness/x 19155 19151)" = 'cd .harness/x && docker run -d --name tiffinbox-capstone --user "$(id -u):$(id -g)" -m 512m -v "$PWD/secrets:/app/secrets:ro" -p 127.0.0.1:19155:18425 tiffinbox-capstone:1.0.0 19151' ] || die "drun(), an argument after the image name"
C_PRE=$(off .harness/pre "$R_INSTALL" install)
for c in "$C_PRE" "$(off .harness/x "$R_PLAIN" package)" "$(off .harness/x "$R_CPB" package)" "$(off .harness/x "$R_NATIVE")"; do
  r=$(dev "$c"); [ "$r" = "$R_PLAIN" ] || [ "$r" = "$R_CPB" ] || [ "$r" = "$R_INSTALL" ] || [ "$r" = "$R_NATIVE" ] || die "not a README line with the offline changes: $c"; done
[ "$(exe "$(at .harness/x 19150 "$R_RUN")")" = 'cd .harness/x && exec java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19150' ] || die "exe()"
echo "  the commands: $TREE/README.md gives all 22 lines this script runs or derives from"

# ---- build: one tree before the captures - the README's native install, then its class-path line; what .m2-demo holds -----
rm -rf .harness; mkdir -p .harness; : > .harness/imgids
rsync -a --exclude target --exclude secrets "$TREE/" .harness/pre/
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
# The first build is the README's native install: it needs nearly every artifact the captures' Maven lines need - so on a fresh
# clone, whose .m2-demo is empty (git ignores it), this one build fills .m2-demo from Maven Central, once. The second is the
# README's class-path line: Maven's dependency plugin, which no earlier build uses (the command-line lesson's finding), so every
# capture's build says "offline: yes".
mbuild "$C_PRE" .harness/build-pre.log ".harness/pre (the tree, the profile native, both modules into \$M2)"
mbuild "$(off .harness/pre "$R_CPB" package)" .harness/build-pre-cp.log ".harness/pre again (the README's class-path line: Maven's dependency plugin into \$M2)"
[ -f "$M2/org/springframework/boot/spring-boot-starter-parent/4.1.1/spring-boot-starter-parent-4.1.1.pom" ] || die "Boot's parent POM is not in .m2-demo after the first build"
[ -f "$M2/org/graalvm/buildtools/native-maven-plugin/1.1.8/native-maven-plugin-1.1.8.jar" ] || die "GraalVM's native plugin 1.1.8 is not in .m2-demo after the first build"
[ -f "$ZIP" ] || die "GraalVM's metadata repository is not in .m2-demo after the first build - README.md, The repository"
[ -s .harness/pre/$CPF ] || die "the README's class-path line wrote no $CPF"
echo "  .m2-demo holds Boot's parent, GraalVM's native plugin 1.1.8, its metadata repository and Maven's dependency plugin"

# ---- helpers ------------------------------------------------------------------------------------------------------------
# raw TOKEN FILE...: how many times TOKEN appears, raw, in the files (occurrences, not lines; binary files read as text)
raw() { local t=$1; shift; cat "$@" | LC_ALL=C grep -aoF -- "$t" | wc -l | tr -d ' '; }
LOGS=0; FLOGS=0; CLOGS=0; LASTE=""                   # logs counted: served runs, starts that ended by themselves, containers
first() { grep -m1 ' : Starting ' "$1" | sed 's/^.* : //; s/ with PID .*$//'; }
start() { echo "\$ $1"; (eval "$(exe "$1")") > .harness/run.out 2> .harness/run.err < /dev/null & pid=$!; }
listening() { local a="" i=0
  while [ $i -lt 240 ]; do
    a=$(lsof -nP -a -p "$pid" -iTCP -sTCP:LISTEN 2> /dev/null | awk 'NR > 1 { print $9 }' | sort -u | paste -sd' ' -)
    [ -n "$a" ] && break; kill -0 "$pid" 2> /dev/null || break; sleep 0.25; i=$((i + 1)); done
  echo "${a:-nothing}"; }
up() { local l; l=$(listening); [ "$l" != nothing ] || { tail -20 .harness/run.out >&3; die "it never listened"; }
  echo "  listens on: $l"; echo "  Boot's first line: $(first .harness/run.out)"; }
ask() { local c; c=$(url "$1" "$2"); echo "\$ $c"; (eval "$c") 2>&1 < /dev/null | sed 's/^/  /'; }
# sortj: a JSON answer followed by curl's status (" 200"), its keys sorted - the bridge writes keys in reflection's order
sortj() { python3 -c '
import json, sys
for l in sys.stdin.read().splitlines():
    b, _, s = l.rpartition(" ")
    try: o = json.dumps(json.loads(b), sort_keys=True, separators=(",", ":"))
    except ValueError: print("  " + l); continue
    print("  " + o + " " + s + ("    (keys sorted)" if o != b else ""))'; }
askj() { local c; c=$(url "$1" "$2"); echo "\$ $c"; (eval "$c") 2>&1 < /dev/null | sortj; }
# ready PORT: readiness asked until it answers 200 - every 0.25 s, up to 60 s, not printed - then the README's readiness line,
# printed and run once. No assertion before it (brief S5.28): readiness holds the kitchen, and its database. A JVM ($pid) that
# exits first stops the run.
ready() { local i=0 c=""
  while [ $i -lt 240 ]; do c=$(curl -s -o /dev/null -w '%{http_code}' "http://127.0.0.1:$1/actuator/health/readiness" 2> /dev/null || true); [ "$c" = 200 ] && break
    if [ -n "$pid" ]; then kill -0 "$pid" 2> /dev/null || { tail -20 .harness/run.out >&3; die "it exited before readiness answered 200"; }; fi
    if [ -n "${2:-}" ]; then [ "$(docker inspect -f '{{.State.Running}}' "$2" 2> /dev/null)" = true ] || { docker logs "$2" 2>&1 | tail -20 >&3; die "the container exited before readiness answered 200"; }; fi
    sleep 0.25; i=$((i + 1)); done
  [ "$c" = 200 ] || die "readiness never answered 200 on $1"
  askj "$R_READY" "$1"; }
logtok() { local t h; t=$(raw "$TOKEN" .harness/run.out .harness/run.err); h=$(cat .harness/run.out .harness/run.err | LC_ALL=C grep -aoi -- 'x-shutdown-token' | wc -l | tr -d ' ')
  LOGS=$((LOGS + 1)); [ "$t" = 0 ] && [ "$h" = 0 ] || die "a log held the demo token ($t) or its header's name ($h)"
  echo "  its log: the demo token 0 times · X-Shutdown-Token 0 times"; }
heard() { echo "  its log: the banner's :: Spring Boot :: line $(grep -c ':: Spring Boot ::' "$1" || true) · TiffinBox listening $(grep -c 'TiffinBox listening on ' "$1" || true)"; }
# seven PORT DIR: the comparison set's seven requests (POST /shutdown carries the header, read from DIR's token file), the POST
# line printed; the JVM must leave within 15 s of them, the port must be free; its exit code and md5; its log counted (logtok)
seven() { local i e=0
  echo "\$ \$CURLSET $1 $2/$TF"
  "$CURLSET" "$1" "$2/$TF" | grep ' -> ' > .harness/responses.txt || true
  grep '^POST ' .harness/responses.txt | sed 's/^/  /' || echo "  (no POST line)"
  i=0; while kill -0 "$pid" 2> /dev/null && [ $i -lt 60 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$pid" 2> /dev/null && { kill "$pid"; die "the server on $1 was still running 15 s after POST /shutdown"; }
  wait "$pid" || e=$?; pid=""; LASTE=$e
  [ "$(listeners "$1")" = 0 ] || die "something still listens on $1"
  echo "  exit $e · the seven responses: $(wc -l < .harness/responses.txt | tr -d ' ') lines · md5 $(md5 -q .harness/responses.txt)"
  logtok; }
# ends PORT: after a POST /shutdown - the JVM must leave within 15 s, the port must be free; its exit code, its log counted
ends() { local i=0 e=0
  while kill -0 "$pid" 2> /dev/null && [ $i -lt 60 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$pid" 2> /dev/null && { kill "$pid"; die "the server on $1 was still running 15 s after POST /shutdown"; }
  wait "$pid" || e=$?; pid=""; LASTE=$e
  [ "$(listeners "$1")" = 0 ] || die "something still listens on $1"
  echo "  exit $e · listening on $1 now: 0"; logtok; }
stop() { echo "\$ harness/shutdown.sh $1 $2/$TF"; harness/shutdown.sh "$1" "$2/$TF" | sed 's/^/  /'; ends "$1"; }
SHAPEAWK='
an { if (NF) ana[++na] = "  " $0; next }
/^Description:$/ { an = 1; ana[++na] = "  " $0; next }
/^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T[^ ]+ +[A-Z]+ +[0-9]+ --- \[/ {
  lv = $2; s = $0; i = index(s, " --- ["); s = substr(s, i + 6); i = index(s, "] "); s = substr(s, i + 2)
  i = index(s, " : "); lg = substr(s, 1, i - 1); sub(/ +$/, "", lg); msg = substr(s, i + 3)
  if (lv == "WARN" || lv == "ERROR" || lv == "DEBUG") {
    if (lv == "WARN" && match(msg, /attempt: [A-Za-z0-9_.$]+/)) msg = substr(msg, 1, RSTART + RLENGTH - 1) " …"
    ln[++nl] = "  " lv " " lg (msg == "" ? ":" : ": " msg) }
  next }
/^\tat / { fr++; if (ne) fx[ne]++; next }
/^\t\.\.\. [0-9]+ (common frames omitted|more)$/ { om += $2; next }
/^Caused by: / { cb++; ex[++ne] = "  " $0; next }
/^([a-z][a-z0-9_]*\.)+[A-Z][A-Za-z0-9_$]*(: .*)?$/ { ex[++ne] = "  " $0; next }
/^APPLICATION FAILED TO START$/ { ban++; next }
/^Error starting ApplicationContext\. To display the condition evaluation report re-run your application with .debug. enabled\.$/ { hint = $0; next }
END {
  by = ""; for (i = 1; i <= ne; i++) by = by (i == 1 ? " = " : " + ") (fx[i] + 0)
  print "  its log, read after it exited: APPLICATION FAILED TO START " (ban + 0) " · stack frames " (fr + 0) (fr ? by : "") " · Caused by: " (cb + 0) " · frames folded as common " (om + 0)
  for (i = 1; i <= nl; i++) print ln[i]
  for (i = 1; i <= ne; i++) print ex[i]
  if (hint != "") print "  the hint Boot logs: " hint
  for (i = 1; i <= na; i++) print ana[i] }'
# fails 'COMMAND': a start expected to end by itself, printed as typed and run (eval; exec, so $fpid is the program's own),
# bounded (60 s); its exit code; its log's shape (SHAPEAWK), how far it got (heard); the token in its log, raw - 0
fails() { local e=0 i=0 t
  echo "\$ $1"; (eval "$(exe "$1")") > .harness/fail.out 2> .harness/fail.err < /dev/null & fpid=$!
  while kill -0 "$fpid" 2> /dev/null && [ $i -lt 240 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$fpid" 2> /dev/null && { kill "$fpid"; die "a start expected to end still ran after 60 s: $1"; }
  wait "$fpid" || e=$?; fpid=""; LASTE=$e
  echo "  exit $e"
  t=$(raw "$TOKEN" .harness/fail.out .harness/fail.err); FLOGS=$((FLOGS + 1)); [ "$t" = 0 ] || die "a failed start's log held the demo token ($t)"
  awk "$SHAPEAWK" .harness/fail.out; heard .harness/fail.out
  echo "  its standard error: $(wc -l < .harness/fail.err | tr -d ' ') lines · the demo token in its log: 0"; }
now() { local p o=""; for p in "$@"; do o="$o${o:+ · }$p $(listeners "$p")"; done; echo "  listening now: $o"; }
# ---- containers
# dstart 'COMMAND': a docker run -d line, printed exactly as typed, run (eval); the container ID it prints is not shown
dstart() { local ec=0; echo "\$ $1"; (eval "$1") > .harness/d.out 2> .harness/d.err < /dev/null || ec=$?
  [ $ec = 0 ] || { cat .harness/d.err >&3; die "docker run failed: exit $ec"; }; }
# dgone NAME: the container polled until it is not running (60 s) - then the README's own way to wait, docker wait, printed
dgone() { local i=0 e
  while [ "$(docker inspect -f '{{.State.Running}}' "$1" 2> /dev/null)" = true ] && [ $i -lt 240 ]; do sleep 0.25; i=$((i + 1)); done
  [ "$(docker inspect -f '{{.State.Running}}' "$1" 2> /dev/null)" != true ] || die "the container $1 still ran after 60 s"
  echo "\$ docker wait $1"; e=$(docker wait "$1"); echo "  $e"; LASTE=$e; }
# dlog NAME: the container's log (docker logs, both streams) into .harness/run.out, the token and its header's name counted (0)
dlog() { local t h; docker logs "$1" > .harness/run.out 2>&1 || true; : > .harness/run.err
  t=$(raw "$TOKEN" .harness/run.out); h=$(LC_ALL=C grep -aoi -- 'x-shutdown-token' .harness/run.out | wc -l | tr -d ' ')
  CLOGS=$((CLOGS + 1)); [ "$t" = 0 ] && [ "$h" = 0 ] || die "a container's log held the demo token ($t) or its header's name ($h)"; }
# dseven PORT DIR NAME: the seven against a container (POST /shutdown last), docker wait, the port free; the container's log:
# Boot's first line, TiffinBox's own lines about the kitchen and its address, the token 0 times; then docker rm
dseven() {
  echo "\$ \$CURLSET $1 $2/$TF"
  "$CURLSET" "$1" "$2/$TF" | grep ' -> ' > .harness/responses.txt || true
  grep '^POST ' .harness/responses.txt | sed 's/^/  /' || echo "  (no POST line)"
  dgone "$3"; [ "$(listeners "$1")" = 0 ] || die "something still listens on $1"
  echo "  exit $LASTE · the seven responses: $(wc -l < .harness/responses.txt | tr -d ' ') lines · md5 $(md5 -q .harness/responses.txt)"
  dlog "$3"
  echo "  its log (docker logs): Boot's first line: $(first .harness/run.out)"
  echo "  its log: $(grep -m1 ' : orders cooked: ' .harness/run.out | sed 's/^.* : //') · $(grep -m1 ' : TiffinBox listening on ' .harness/run.out | sed 's/^.* : //') · the demo token 0 times · X-Shutdown-Token 0 times"
  docker rm "$3" > /dev/null; }
# dfails 'COMMAND' NAME: a container expected to exit by itself - started, waited for, its exit code; its log's shape and how far
# it got; the token 0 times; docker rm
dfails() { dstart "$1"; dgone "$2"; dlog "$2"; awk "$SHAPEAWK" .harness/run.out; heard .harness/run.out
  echo "  its log (docker logs): the demo token 0 times"; docker rm "$2" > /dev/null; }
mask() { awk -v t="$TOKEN" -v g="${GRAALVM_HOME:-}" -v u="$U" -v up="$UP" -v hm="$HOME" -v me="$ME" '
  function lit(x) { gsub(/[][\\.^$*+?(){}|\/]/, "\\\\&", x); return x }
  function enc(x) { gsub(/ /, "%20", x); return x }
  BEGIN { T = lit(t); G = lit(g); GE = lit(enc(g)); P = lit(u); Q = lit(up); H = lit(hm); PE = lit(enc(u)); QE = lit(enc(up)); M = lit(me) }
  { gsub(T, "[masked: the 26-character token]"); if (g != "") { gsub(G, "$GRAALVM_HOME"); gsub(GE, "$GRAALVM_HOME") }; gsub(P, "…"); gsub(PE, "…")
    gsub(Q, "…/.."); gsub(QE, "…/.."); gsub(H, "~"); gsub(M, "<user>"); print }'; }

unpub=""
cap() { local nm=$1 h pub i; shift
  for i in 1 2 3; do "$@" > .harness/cap.raw 2>&1 || true; [ -z "$pid" ] && [ -z "$fpid" ] || die "$nm left a process running"
    [ -z "$(docker ps -aq --filter "name=^$BOX\$")$(docker ps -aq --filter "name=^$XBOX\$")" ] || die "$nm left a container"
    [ "$(projcount)" = 0 ] || die "$nm left the Compose project's containers, volumes or networks"
    raw "$TOKEN" .harness/cap.raw > ".harness/raw-$nm.$i"; mask < .harness/cap.raw > ".r-$nm.$i"; done
  h=$(md5 -q ".r-$nm.1")
  [ "$h" = "$(md5 -q ".r-$nm.2")" ] && [ "$h" = "$(md5 -q ".r-$nm.3")" ] || die "$nm drifts across three runs (diff .r-$nm.1 .r-$nm.2 .r-$nm.3)"
  mv ".r-$nm.1" ".r-$nm.out"; rm -f ".r-$nm.2" ".r-$nm.3"
  pub=$(awk -v n="$nm" '$1 == n { print $2 }' receipts.md5 2> /dev/null || true)
  if [ -z "$pub" ]; then printf '  %-11s md5 %s  3/3  (no published hash)\n' "$nm" "$h"; unpub="$unpub $nm"
  elif [ "$pub" = "$h" ]; then printf '  %-11s md5 %s  3/3  = published\n' "$nm" "$h"
  else printf '  %-11s md5 %s  3/3  DIFFERS from the published %s\n' "$nm" "$h" "$pub"
    die "$nm is not the published capture - suspect another JDK, GraalVM, Boot, Maven or Docker, another base image, a busy machine, a busy port, a variable of yours, or an edited source; diff .r-$nm.out against its block in README.md"; fi; }
copy() { rm -rf "$2" "$2".*; rsync -a --exclude target --exclude secrets "$1/" "$2/"; tree "$2"; }
pbuild() { local c; c=$(off "$1" "${3:-$R_PLAIN}" package); echo "\$ $c"; mbuild "$c" "$1.build.log" "$2"; }

# ---- image: the README's two lines, then its run line ------------------------------------------------------------------------
# blines LOG: docker build's output through its filter - the metadata line, the FROM line, the naming line (each without its step
# number and timing), how many lines say pull, and how many lines are not shown. BuildKit writes a step's end as " done", or as
# " 0.0s done" when the step took measurable time: both are cut (a filter that cut " done" alone kept "naming to … 0.0s" beside
# "naming to …", and a fresh clone's image capture drifted - RED C5-S5 #41).
blines() { local s
  s=$(grep -E '^#[0-9]+ \[internal\] load metadata for |^#[0-9]+ \[[a-z0-9-]+ 1/[0-9]+\] FROM |^#[0-9]+ naming to ' "$1" | sed -E 's/^#[0-9]+ //; s/( [0-9]+\.[0-9]+s)? done$//' | awk '!seen[$0]++')
  printf '%s\n' "$s" | sed 's/^/    /'
  echo "  its lines that say pull: $(grep -ci 'pull' "$1" || true) · its other lines: not shown"; }
# The filter, checked on a planted log before any capture: three naming lines - without a timing, with 0.0s, with 0.1s - must come
# out as one line, the image's name alone. (The old filter gives three: measured.)
printf '%s\n' '#14 naming to docker.io/library/planted:1 done' '#14 naming to docker.io/library/planted:1 0.0s done' '#15 naming to docker.io/library/planted:1 0.1s done' > .harness/planted-dbuild.log
PL=$(blines .harness/planted-dbuild.log)
[ "$(printf '%s\n' "$PL" | grep -c 'naming to')" = 1 ] && printf '%s\n' "$PL" | grep -qxF '    naming to docker.io/library/planted:1' || die "blines: a timing survives the filter (the planted log .harness/planted-dbuild.log)"
rm -f .harness/planted-dbuild.log
image() {
  echo "the tree, copied to .harness/serve with a config tree beside the README - the README's two lines, Maven then Docker:"
  copy "$TREE" .harness/serve
  pbuild .harness/serve "the tree"
  echo "  .dockerignore beside the Dockerfile keeps out: $(grep -v '^#' .harness/serve/.dockerignore | grep . | paste -sd' ' -)"
  local c ec=0; c=$(dbuild .harness/serve); echo "\$ $c"
  (eval "$c") > .harness/dbuild.log 2>&1 < /dev/null || ec=$?
  [ $ec = 0 ] || { tail -20 .harness/dbuild.log >&3; die "docker build failed"; }
  docker image inspect -f '{{.Id}}' "$IMG" >> .harness/imgids
  echo "  exit $ec · its lines, through the filter:"; blines .harness/dbuild.log
  echo "  the base image on this Docker: $(docker image inspect -f '{{range .RepoDigests}}{{println .}}{{end}}' eclipse-temurin:25-jre | grep -m1 '^eclipse-temurin@')"
  echo "  the image: user $(docker image inspect -f '{{.Config.User}}' "$IMG") · entrypoint $(docker image inspect -f '{{json .Config.Entrypoint}}' "$IMG") · /app holds: $(docker run --rm --entrypoint ls "$IMG" -A /app | paste -sd' ' -)"
  echo "the README's run line - your user added, the port published on 127.0.0.1:19155:"
  dstart "$(drun .harness/serve 19155)"
  ready 19155 "$BOX"
  echo "  docker port: $(docker port "$BOX" | paste -sd' ' -)"
  echo "  the container's user id is yours (id -u): $([ "$(docker exec "$BOX" id -u)" = "$(id -u)" ] && echo yes || echo no)"
  dseven 19155 .harness/serve "$BOX"; }

# ---- fails: the break - one argument; a port taken; D, the image --------------------------------------------------------------
fails_() {
  echo "the tree, copied to .harness/serve with a config tree, built with the README's class-path line (offline):"
  copy "$TREE" .harness/serve
  pbuild .harness/serve "the tree" "$R_CPB"
  echo "A - the jar, the README's run line, port 19150:"
  start "$(at .harness/serve 19150 "$R_RUN")"; up; ready 19150
  seven 19150 .harness/serve
  echo "B - the same line, and a bare 19151:"
  fails "$(at .harness/serve 19150 "$R_RUN") 19151"
  now 19150 19151
  echo "A' - A again:"
  start "$(at .harness/serve 19150 "$R_RUN")"; up; ready 19150
  seven 19150 .harness/serve
  echo "the failure lesson's analysis, on the jar - the same line while the first one holds the port:"
  start "$(at .harness/serve 19150 "$R_RUN")"; up; ready 19150
  fails "$(at .harness/serve 19150 "$R_RUN")"
  seven 19150 .harness/serve
  echo "D (labelled) - the image, a bare 19151 after the image name:"
  dfails "$(drun .harness/serve 19155 19151)" "$BOX"
  now 19155 19151
  echo "E (labelled) - the image, D's action followed: --tiffinbox.port=19157 after the image name, published as before (127.0.0.1:19155):"
  dstart "$(drun .harness/serve 19155 --tiffinbox.port=19157)"
  dheard "$BOX"
  echo "  its log: $(docker logs "$BOX" 2>&1 | grep -m1 ' : TiffinBox listening on ' | sed 's/^.* : //')"
  echo "  docker port: $(docker port "$BOX" | paste -sd' ' -)"
  echo "\$ curl -s -o /dev/null -w '%{http_code}\\n' http://127.0.0.1:19155/actuator/health/readiness"
  echo "  $(curl -s -o /dev/null -w '%{http_code}' --max-time 10 http://127.0.0.1:19155/actuator/health/readiness 2> /dev/null || true)"
  echo "  listening on this machine: 19155 $(listeners 19155 | sed 's/^[1-9][0-9]*$/Docker/') · 19157 $(listeners 19157)"
  echo "\$ docker stop tiffinbox-capstone"; docker stop "$BOX" > /dev/null
  dgone "$BOX"; dlog "$BOX"; echo "  its log (docker logs): the demo token 0 times"; docker rm "$BOX" > /dev/null; }
# dheard NAME: the container's log polled until TiffinBox says it listens (60 s); a container that exits first stops the run
dheard() { local i=0
  while ! docker logs "$1" 2>&1 | grep -q ' : TiffinBox listening on ' && [ $i -lt 240 ]; do
    [ "$(docker inspect -f '{{.State.Running}}' "$1" 2> /dev/null)" = true ] || { docker logs "$1" 2>&1 | tail -20 >&3; die "the container $1 exited before TiffinBox listened"; }
    sleep 0.25; i=$((i + 1)); done
  docker logs "$1" 2>&1 | grep -q ' : TiffinBox listening on ' || die "TiffinBox never listened in the container $1"; }

# ---- ops: operating it, on the JVM ---------------------------------------------------------------------------------------------
# tlines FILE: a scrape's lines for TiffinBox's own meters - the two counters, and the timer's count per series (its sums and
# maxima are seconds: counted, not shown)
tlines() { grep -E '^tiffinbox_orders_(cooked|value)_total |^tiffinbox_requests_seconds_count\{' "$1" | sed 's/^/  /'
  echo "  the timer's sum and max lines (seconds): $(grep -cE '^tiffinbox_requests_seconds_(sum|max)\{' "$1" || true), not shown · the scrape's other lines (the JVM's, the process's, the system's: their number moves): $( [ "$(grep -cvE '^tiffinbox_' "$1" || true)" -gt 100 ] && echo 'over 100' || echo '100 or fewer'), not shown"; }
# dbg LOG: TiffinBox's DEBUG lines (its logger, tiffinbox), from their message on
dbg() { grep -E ' DEBUG [0-9]+ --- \[.*\] tiffinbox +: ' "$1" | sed 's/^.* : /    /'; }
ops() {
  echo "the jar (.harness/serve) - the README's loggers line, with the health lesson's flag; port 19152:"
  start "$(at .harness/serve 19152 "$R_OPS")"; up; ready 19152
  askj "$R_HEALTH" 19152
  ask "$R_KITCHEN" 19152
  echo "  TiffinBox's DEBUG lines so far: $(dbg .harness/run.out | grep -c . || true)"
  ask "$R_LOGPOST" 19152
  echo "\$ harness/six.sh 19152"; harness/six.sh 19152 | sed 's/^/  /'
  local s; s=$(url "$R_SCRAPE" 19152); echo "\$ cd .harness/serve && $s"; (cd .harness/serve && eval "$s") 2>&1 < /dev/null | sed 's/^/  /'
  tlines .harness/serve/scrape.txt; rm -f .harness/serve/scrape.txt
  stop 19152 .harness/serve
  echo "  TiffinBox's DEBUG lines, from the POST on - $(dbg .harness/run.out | grep -c . || true):"; dbg .harness/run.out; }

# ---- dev: the README's dev line, the anchor's compose.yaml ---------------------------------------------------------------------
# cstate: what Docker lists for the Compose project now - each container with its state and exit code, each volume, each network
cstate() { local c
  c=$(docker ps -a --filter "label=com.docker.compose.project=$PROJ" --format '{{.Names}}' | sort | while read -r n; do printf '%s %s (exit %s)\n' "$n" "$(docker inspect -f '{{.State.Status}}' "$n")" "$(docker inspect -f '{{.State.ExitCode}}' "$n")"; done | paste -sd' ' -)
  echo "  containers: ${c:-(none)}"
  c=$(docker volume ls -q --filter "label=com.docker.compose.project=$PROJ" | sort | paste -sd' ' -); echo "  volumes: ${c:-(none)}"
  c=$(docker network ls --filter "label=com.docker.compose.project=$PROJ" --format '{{.Name}}' | sort | paste -sd' ' -); echo "  networks: ${c:-(none)}"; }
devcap() {
  echo "the compose.yaml in .harness/serve (the folder TiffinBox starts in), against the anchor's own, ../c5-tiffinbox/compose.yaml: $(cmp -s ../c5-tiffinbox/compose.yaml .harness/serve/compose.yaml && echo the same || echo different)"
  echo "\$ cd .harness/serve && docker compose config --format json    # its project name, read back"
  echo "  name: $(cd .harness/serve && docker compose config --format json | python3 -c 'import json, sys; print(json.load(sys.stdin)["name"])')"
  echo "\$ cd .harness/serve && COMPOSE_PROJECT_NAME=planted-canary docker compose config --format json    # a leftover variable"
  echo "  name: $(cd .harness/serve && COMPOSE_PROJECT_NAME=planted-canary docker compose config --format json | python3 -c 'import json, sys; print(json.load(sys.stdin)["name"])')"
  echo "the project $PROJ before the run: containers, volumes and networks $(projcount) · listening on 18881: $(listeners 18881)"
  echo "the README's dev line - Maven's class path, the profile dev; port 19156:"
  start "$(at .harness/serve 19156 "$R_DEV")"; up; ready 19156
  echo "  the project while TiffinBox runs: $(docker ps -a --filter "label=com.docker.compose.project=$PROJ" --format '{{.Names}} {{.State}} {{.Ports}}')"
  seven 19156 .harness/serve
  echo "  its log: $(grep -m1 ' : The following 1 profile is active: ' .harness/run.out | sed 's/^.* : //') · $(grep -m1 ' : Using Docker Compose file ' .harness/run.out | sed 's/^.* : //')"
  echo "  Compose's lines in its log that say Created, Started or Healthy, sorted:"
  grep -E 'DockerCli +: ' .harness/run.out | sed 's/^.* : *//; s/ *$//' | grep -E ' (Created|Started|Healthy)$' | sort | sed 's/^/    /'
  echo "  lines that say Pulling: $(grep -c 'Pulling' .harness/run.out || true) · WARN lines: $(grep -cE '^[0-9-]+T[^ ]+ +WARN ' .harness/run.out || true) · ERROR lines: $(grep -cE '^[0-9-]+T[^ ]+ +ERROR ' .harness/run.out || true)"
  echo "  Jackson 3 (tools.jackson) on this class path: $(tr ':' '\n' < .harness/serve/$CPF | grep -c '/tools/jackson/' || true) jars · in the executable jar's lib/: $(unzip -Z1 .harness/serve/$JARP | grep -cE '^BOOT-INF/lib/jackson-[a-z-]+-3\.' || true)"
  echo "the project after TiffinBox exited (Boot's stop):"; cstate
  echo "\$ docker compose -p $PROJ down -v"
  docker compose -p "$PROJ" down -v > .harness/down.log 2>&1 || die "docker compose down failed"
  echo "  exit 0"; echo "the project now:"; cstate; }

# ---- promises: the course's first promise, one line each ----------------------------------------------------------------------
# imports JAR: the AutoConfiguration.imports files in the executable jar's lib/ and their entries (comments and blank lines left
# out), written to .harness/imports.txt, one class a line; one line per jar
imports() { python3 - "$1" <<'PY'
import io, sys, zipfile
z = zipfile.ZipFile(sys.argv[1]); n = "META-INF/spring/org.springframework.boot.autoconfigure.AutoConfiguration.imports"; out = []; nf = 0
for j in sorted(e for e in z.namelist() if e.startswith("BOOT-INF/lib/") and e.endswith(".jar")):
    i = zipfile.ZipFile(io.BytesIO(z.read(j)))
    if n in i.namelist():
        e = [l.strip() for l in i.read(n).decode().splitlines() if l.strip() and not l.strip().startswith("#")]
        print("    %s: %d" % (j.split("/")[-1], len(e))); out += e; nf += 1
open(".harness/imports.txt", "w").write("\n".join(out) + "\n")
print("  files: %d · entries: %d" % (nf, len(out)))
PY
}
# applied LOG: the condition evaluation report of a --debug run, against .harness/imports.txt - an entry applied when its class
# is a positive match or an unconditional class; skipped when it is a negative match; every entry must be one or the other
applied() { python3 - "$1" <<'PY'
import re, sys
t = open(sys.argv[1]).read().splitlines()
def at(s): return t.index(s)
p, n, x, u = at("Positive matches:"), at("Negative matches:"), at("Exclusions:"), at("Unconditional classes:")
top = lambda a, b: set(re.match(r"^   (\S+?):?( matched:?| - .*)?$", l).group(1) for l in t[a:b] if re.match(r"^   \S", l))
pos, neg = top(p, n), top(n, x)
unc = set(l.strip() for l in t[u + 1:] if re.match(r"^    \S", l))
L = [l for l in open(".harness/imports.txt").read().splitlines() if l]
a = [e for e in L if e.rsplit(".", 1)[1] in pos or e in unc]; s = [e for e in L if e not in a and e.rsplit(".", 1)[1] in neg]
print("  the condition report: of the %d entries listed, applied %d (positive matches %d, unconditional %d) · skipped %d (negative matches) · neither %d"
      % (len(L), len(a), len([e for e in a if e not in unc]), len([e for e in a if e in unc]), len(s), len(L) - len(a) - len(s)))
PY
}
promises() {
  echo "auto-configuration - the executable jar's lib/ (.harness/serve), its AutoConfiguration.imports files and their entries:"
  imports .harness/serve/$JARP
  echo "  how many applied - the README's --debug line (Boot's condition evaluation report), port 19153:"
  start "$(at .harness/serve 19153 "$R_DEBUG")"; up; ready 19153
  seven 19153 .harness/serve
  applied .harness/run.out
  echo "Actuator, and one runnable jar - the README's run line, port 19153:"
  start "$(at .harness/serve 19153 "$R_RUN")"; up; ready 19153
  askj "$R_HEALTH" 19153
  local s; s=$(url "$R_SCRAPE" 19153); echo "\$ cd .harness/serve && $s"; (cd .harness/serve && eval "$s") 2>&1 < /dev/null | sed 's/^/  /'
  grep -E '^tiffinbox_orders_(cooked|value)_total ' .harness/serve/scrape.txt | sed 's/^/  /'; rm -f .harness/serve/scrape.txt
  seven 19153 .harness/serve
  echo "Docker - the image (tiffinbox-capstone:1.0.0, the image capture's), the README's run line with your user:"
  dstart "$(drun .harness/serve 19155)"; ready 19155 "$BOX"
  dseven 19155 .harness/serve "$BOX"; }

# ---- exercise: the README's commands, exactly as written, then the solution's ---------------------------------------------
block() { awk '/^```bash$/ { if (!d) { f = 1 }; next } f && /^```$/ { f = 0; d = 1 } f' "$1"; }
exercise() { local setup sol ec=0
  setup=$(block exercise/README.md); sol=$(block exercise/solution/SOLUTION.md)
  [ -n "$setup" ] && [ -n "$sol" ] || die "exercise/README.md or SOLUTION.md no longer gives its commands"
  [ "$(printf '%s\n' "$sol" | grep -c .)" = 1 ] || die "SOLUTION.md's first bash block must be its one line"
  echo "exercise/README.md's commands, run exactly as written from this folder - $(printf '%s\n' "$setup" | grep -c .) lines:"
  printf '%s\n' "$setup" | sed 's/^/  $ /'
  (eval "$setup") > .harness/ex-setup.log 2>&1 < /dev/null || ec=$?
  [ $ec = 0 ] || { tail -20 .harness/ex-setup.log >&3; die "the exercise's setup failed"; }
  docker image inspect -f '{{.Id}}' "$XIMG" >> .harness/imgids
  echo "  exit $ec · printed: $(grep -c . .harness/ex-setup.log || true) line(s)"
  echo "the solution's line (exercise/solution/SOLUTION.md), run exactly as written, from this folder:"
  echo "\$ $sol"
  ec=0; (eval "$sol") 2>&1 < /dev/null || ec=$?
  echo "  exit $ec · listening on 19159 now: $(listeners 19159) · the container tiffinbox-mine: $(docker ps -aq --filter "name=^$XBOX\$" | grep -c . || true)"
  echo "\$ docker image rm $XIMG"; docker image rm "$XIMG" > /dev/null; echo "  removed"; }

# ---- native: the tree built natively; the binary ------------------------------------------------------------------------------
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
  grep -E '^Warning: ' "$1" | sed "s/ in 'file:[^']*'/ in '…'/" | sed 's/^/    /'
  grep -E '^\[[1-8]/8\] ' "$1" | sed 's/\.\.\..*$/.../' | sed 's/^/    /'
  grep -E '^The build process encountered |^\[INFO\] BUILD ' "$1" | sed 's/^\[INFO\] //' | sed 's/^/    /'; }
nresult() { echo "  exit $NB_E · $(grep -m1 -oE 'BUILD (SUCCESS|FAILURE)' "$1" || echo 'no BUILD line') · stages it printed: $(grep -cE '^\[[1-8]/8\] ' "$1" || true) of the $(grep -m1 -oE '^\[1/[0-9]+\]' "$1" | sed 's/.*\///; s/]//') it announces · its duration, against the bound: $( [ $NB_S -ge 60 ] && echo '1 minute or more' || echo 'under 1 minute' ), $( [ $NB_S -lt 1200 ] && echo 'under 20 minutes' || echo '20 minutes or more' ) · offline: yes"; }
native() {
  echo "the tree, copied to .harness/nat with a config tree; the README's two Maven lines, offline; \$GRAALVM_HOME names the GraalVM:"
  copy "$TREE" .harness/nat
  nbuild .harness/nat
  nlines .harness/nat.native.log
  nresult .harness/nat.native.log
  echo "  file: $(file -b ".harness/nat/$BIN" | sed 's/ [A-Za-z0-9_]*$//') · the demo token in its bytes: $(raw "$TOKEN" ".harness/nat/$BIN")"
  echo "the binary - the README's loggers line, port 19157:"
  start "$(at .harness/nat 19157 "$R_BINLOGX")"; up; ready 19157
  askj "$R_HEALTH" 19157
  local s; s=$(url "$R_SCRAPE" 19157); echo "\$ cd .harness/nat && $s"; (cd .harness/nat && eval "$s") 2>&1 < /dev/null | sed 's/^/  /'
  grep -E '^tiffinbox_orders_(cooked|value)_total ' .harness/nat/scrape.txt | sed 's/^/  /'; rm -f .harness/nat/scrape.txt
  s=$(url "$R_LOGGERS" 19157); echo "\$ cd .harness/nat && $s"; (cd .harness/nat && eval "$s") 2>&1 < /dev/null | sed 's/^/  /'; rm -f .harness/nat/loggers.json
  echo "a port taken - the README's line, while the first binary holds 19157:"
  fails "$(at .harness/nat 19157 "$R_BIN")"
  seven 19157 .harness/nat
  echo "C (labelled) - the binary, the README's line and a bare 19151:"
  fails "$(at .harness/nat 19157 "$R_BIN") 19151"
  now 19157 19151; }

# ---- forms: one tree, five forms ----------------------------------------------------------------------------------------------
forms() {
  echo "1 the jar - .harness/serve, the README's run line, port 19150:"
  start "$(at .harness/serve 19150 "$R_RUN")"; up; ready 19150; seven 19150 .harness/serve
  echo "2 the AOT jar - .harness/nat (the profile native's jar), the README's AOT line, port 19154:"
  start "$(at .harness/nat 19154 "$R_AOTRUN")"; up; ready 19154; seven 19154 .harness/nat
  echo "3 the binary - .harness/nat, the README's line, port 19157:"
  start "$(at .harness/nat 19157 "$R_BIN")"; up; ready 19157; seven 19157 .harness/nat
  echo "4 the image - tiffinbox-capstone:1.0.0 (the image capture's), the README's run line with your user, port 19155:"
  dstart "$(drun .harness/serve 19155)"; ready 19155 "$BOX"; dseven 19155 .harness/serve "$BOX"
  echo "5 the dev class path - .harness/serve, the README's dev line (Compose starts compose.yaml's Postgres), port 19156:"
  start "$(at .harness/serve 19156 "$R_DEV")"; up; ready 19156; seven 19156 .harness/serve
  docker compose -p "$PROJ" down -v > .harness/down.log 2>&1 || die "docker compose down failed"
  echo "  then docker compose -p $PROJ down -v: containers, volumes and networks $(projcount)"
  echo "five forms, one tree: the seven's md5 $(grep -c '^  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891$' .harness/cap.raw) of 5 times 115c36bac276128e245ca57df11c2891 · readiness {\"status\":\"UP\"} 200 $(grep -c '^  {"status":"UP"} 200$' .harness/cap.raw) of 5"; }

cap image image
cap fails fails_
cap ops ops
cap dev devcap
cap promises promises
# Without a GraalVM the run stops here, the exercise's capture made first (it needs none): .m2-demo is filled, and every capture
# so far matched receipts.md5 - or cap() would have stopped the run.
if [ $GOK = no ]; then cap exercise exercise
  die "GRAALVM_HOME is not set: .m2-demo is filled, and the captures that need no GraalVM matched receipts.md5, the exercise's included; the native build needs a GraalVM JDK 25 - README.md, The GraalVM"; fi
cap exercise exercise
cap native native
cap forms forms

echo
# ---- every number the video says, asserted. Each check reads a line a program computed - never a label this script prints
# ---- unconditionally - and names the words it pays for.
x() { grep -qE -- "$2" ".r-$1.out" || die "$1: expected /$2/"; }
n() { grep -cE -- "$2" ".r-$1.out" || true; }
blk() { awk -v a="$2" -v b="$3" 'index($0, a) == 1 { f = 1; next } b != "" && index($0, b) == 1 { f = 0 } f' ".r-$1.out"; }
has() { printf '%s\n' "$1" | grep -qxF -- "$2" || die "$3: expected the line: $2"; }
S115='115c36bac276128e245ca57df11c2891'
SEVEN="  exit 0 · the seven responses: 7 lines · md5 $S115"
READY='  {"status":"UP"} 200'
LOGOK="  its log: the demo token 0 times · X-Shutdown-Token 0 times"
NOTRACE="  its log, read after it exited: APPLICATION FAILED TO START 1 · stack frames 0 · Caused by: 0 · frames folded as common 0"
NOSTART="  its log: the banner's :: Spring Boot :: line 0 · TiffinBox listening 0"
DESC="  TiffinBox reads no bare arguments: "
# refused 'TEXT' WHAT 'N of M': the refusal - the analysis and no frame, no banner, no listening line; the bare 19151 placed
refused() { has "$1" "$NOTRACE" "$2: two sentences, no frame"; has "$1" "$NOSTART" "$2: before the banner, never listened"
  has "$1" "${DESC}argument $3 is 19151." "$2: the description"; has "$1" "  To set the port, give it as an option: --tiffinbox.port=19151." "$2: the action"; }
taken() { has "$1" "  exit 1" "$2: exit 1"; has "$1" "$NOTRACE" "$2: two sentences, no frame"
  has "$1" "  TiffinBox could not listen on 127.0.0.1:$3: something else already listens there." "$2: the description"; }
# THE TOKEN: no capture holds it, raw - counted on each run's own output BEFORE masking - and neither does any log (each counted
# when it was read: fails(), logtok(), dlog()), anything this unit ships for reading, nor the binary this run built
for f in .harness/raw-*; do [ "$(cat "$f")" = 0 ] || die "a capture's raw output held the demo token ($f)"; done
NBIN=0
for f in .r-*.out README.md exercise/README.md exercise/solution/SOLUTION.md receipts.md5 harness/shutdown.sh harness/six.sh .harness/nat/$BIN; do
  [ -f "$f" ] || continue; case $f in .harness/nat*) NBIN=$((NBIN + 1)) ;; esac
  [ "$(raw "$TOKEN" "$f")" = 0 ] || die "$f holds the demo token, raw"; done
[ "$NBIN" = 1 ] || [ $GOK = no ] || die "one binary was built, $NBIN were checked"
for f in .r-*.out; do ! grep -qE '/Users/|/private/|/home/|/var/folders/' "$f" || die "$f holds an absolute path"; [ -z "${GRAALVM_HOME:-}" ] || ! grep -qF "$GRAALVM_HOME" "$f" || die "$f holds the GraalVM's folder"; ! grep -qE 'c[0-9]-unit[0-9]|unit ?[0-9]' "$f" || die "$f holds a unit number"; ! grep -qE ' (with PID|started by) ' "$f" || die "$f holds Boot's process line"; ! grep -qE '^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T|virtual-[0-9]' "$f" || die "$f holds a log line's time or a thread's number"; ! grep -q "^$(printf '\t')at " "$f" || die "$f shows a stack frame"; ! grep -qE 'sha256:[0-9a-f]{64}' "$f" || [ "$(grep -cE 'sha256:[0-9a-f]{64}' "$f")" = "$(grep -cE 'eclipse-temurin(:25-jre)?@sha256:[0-9a-f]{64}' "$f")" ] || die "$f holds an ID other than the base image's digest"; done
for f in receipts.sh README.md exercise/README.md exercise/solution/SOLUTION.md; do [ -f "$f" ] || continue; ! grep -E 'docker run ' "$f" | grep -vE '^#' | grep -E ' -p "?[0-9]+:' > /dev/null || die "$f publishes a port on every address (-p without 127.0.0.1:)"; done
NL=$(cat .r-*.out | grep -cxF "$LOGOK" || true)
echo "  token: 0 raw copies in $(ls .harness/raw-* | wc -l | tr -d ' ') raw capture runs, in $(ls .r-*.out | wc -l | tr -d ' ') captures, in the logs of every start that ended by itself ($FLOGS here), every JVM that served ($LOGS here; the published captures' $NL), every container ($CLOGS here), the READMEs, the harness, the exercise, receipts.md5 and the binary; no absolute path, no GraalVM folder, no unit number, no process line, no log time, no thread number, no stack frame, no ID but the base image's digest in any capture; every docker run publishes on 127.0.0.1 only"

# "The image: the anchor's Dockerfile packs the jar. The build pulled nothing; the container runs as you, the token mounted
# read-only; the seven, and docker wait says zero."
x image '^\$ cd \.harness/serve && docker build --progress=plain -t tiffinbox-capstone:1\.0\.0 \.$'
x image '^    \[internal\] load metadata for docker\.io/library/eclipse-temurin:25-jre$'; x image '^  its lines that say pull: 0 · '
x image '^  the image: user ubuntu · entrypoint \["java","-jar","application\.jar"\] · /app holds: application\.jar lib$'
x image '^\$ cd \.harness/serve && docker run -d --name tiffinbox-capstone --user "\$\(id -u\):\$\(id -g\)" -m 512m -v "\$PWD/secrets:/app/secrets:ro" -p 127\.0\.0\.1:19155:18425 tiffinbox-capstone:1\.0\.0$'
x image '^  docker port: 18425/tcp -> 127\.0\.0\.1:19155$'; x image "^  the container's user id is yours \(id -u\): yes\$"; x image "^$READY\$"
x image "^$SEVEN\$"; x image '^\$ docker wait tiffinbox-capstone$'
x image '^  its log: orders cooked:  120 · TiffinBox listening on http://0\.0\.0\.0:18425 · the demo token 0 times · X-Shutdown-Token 0 times$'
echo "  image: the README's build, 0 pull lines, user ubuntu, exec form; run as you on 127.0.0.1:19155; readiness 200; 115c36ba...; docker wait 0; token 0 in its log"

# "A: the jar, the seven. B: one bare number - exit two, nothing listening. A again: the seven. A taken port: two sentences. After
# the image name: exit two too."
F0=$(blk fails 'A - the jar' 'B - the same'); FB=$(blk fails 'B - the same' "A' - A again"); FA2=$(blk fails "A' - A again" "the failure lesson"); FT=$(blk fails "the failure lesson" "D (labelled)"); FD=$(blk fails "D (labelled)" "E (labelled)"); FE=$(blk fails "E (labelled)" '')
has "$F0" "$SEVEN" "fails A"; has "$FA2" "$SEVEN" "fails A'"
[ "$(printf '%s\n' "$F0" | grep '^\$ cd')" = "$(printf '%s\n' "$FA2" | grep '^\$ cd')" ] || die "fails: A' is not A's command"
has "$FB" "  exit 2" "fails B: exit 2"; refused "$FB" "fails B" "2 of 2"; has "$FB" "  listening now: 19150 0 · 19151 0" "fails B: never bound"
taken "$FT" "fails, a port taken" 19150; has "$FT" "$SEVEN" "fails, the first one still serves"
refused "$FD" "fails D" "1 of 1"; has "$FD" "\$ docker wait tiffinbox-capstone" "fails D: docker wait"; [ "$(printf '%s\n' "$FD" | grep -cx '  2')" = 1 ] || die "fails D: docker wait 2"
has "$FD" "  listening now: 19155 0 · 19151 0" "fails D: never bound"
# "In a container, that option moves the container's own port: the published one answers nothing."
has "$FE" "  its log: TiffinBox listening on http://0.0.0.0:19157" "fails E: TiffinBox moved inside the container"
has "$FE" "  docker port: 18425/tcp -> 127.0.0.1:19155" "fails E: still published to 18425"
has "$FE" "  000" "fails E: the published port answers nothing"; has "$FE" "  listening on this machine: 19155 Docker · 19157 0" "fails E: 19157 is the container's"
echo "  fails: A 115c36ba... · B exit 2, 0 frames, never bound · A' 115c36ba... · a port taken: exit 1, two sentences · D the image: docker wait 2, the same sentences · E the action followed in a container: listens on 19157 inside, 19155 answers 000"

# "Health: up, with its two groups; readiness holds the kitchen. At INFO, no line per answer; one POST to loggers and every answer
# gets one. The scrape: a hundred and twenty orders, one timer series per route."
x ops '^  \{"components":\{"diskSpace":\{"status":"UP"\},.*\},"groups":\["liveness","readiness"\],"status":"UP"\} 200    \(keys sorted\)$'
x ops '^  \{"components":\{"kitchen":\{"status":"UP"\},"readinessState":\{"status":"UP"\}\},"status":"UP"\} 200    \(keys sorted\)$'
x ops '^  \{"ordersCooked":120,"ordersValue":24300\} 200$'; x ops "^  TiffinBox's DEBUG lines so far: 0\$"; x ops '^   204$'
x ops '^  tiffinbox_orders_cooked_total 120\.0$'; x ops '^  tiffinbox_orders_value_total 24300\.0$'
[ "$(n ops '^  tiffinbox_requests_seconds_count\{')" = 5 ] || die "ops: five timer series"
x ops '^  tiffinbox_requests_seconds_count\{route="UNKNOWN",status="405"\} 1$'
x ops "^  TiffinBox's DEBUG lines, from the POST on - 6:\$"; x ops '^    POST /shutdown -> 200$'
echo "  ops: health UP + 2 groups; readiness = kitchen + readinessState; DEBUG 0 at INFO, then 204, then 6; scrape 120.0 / 24300.0, 5 timer series"

# "Compose for development: Boot started Postgres from the anchor's own file, on loopback; the seven; exit zero; Boot's stop left
# the container exited, zero. A leftover variable renames the project."
x dev "^the compose\.yaml in \.harness/serve \(the folder TiffinBox starts in\), against the anchor.s own, \.\./c5-tiffinbox/compose\.yaml: the same\$"
x dev '^  name: tiffinbox-dev$'; x dev '^  name: planted-canary$'
x dev '^  the project while TiffinBox runs: tiffinbox-dev-postgres-1 running 127\.0\.0\.1:18881->5432/tcp$'; x dev "^$SEVEN\$"
x dev '^  lines that say Pulling: 0 · WARN lines: 0 · ERROR lines: 0$'
x dev '^  Jackson 3 \(tools\.jackson\) on this class path: 2 jars · in the executable jar.s lib/: 0$'
x dev '^  containers: tiffinbox-dev-postgres-1 exited \(exit 0\)$'; x dev '^  volumes: tiffinbox-dev_data$'
[ "$(blk dev 'the project now:' '' | paste -sd'|' -)" = '  containers: (none)|  volumes: (none)|  networks: (none)' ] || die "dev: down -v left nothing"
echo "  dev: the anchor's compose.yaml, tiffinbox-dev (planted-canary with the variable), Postgres on 127.0.0.1:18881, 115c36ba..., 0 pulls, 0 WARN, exited (0), then nothing"

# "Auto-configuration: six files, seventy-four entries, thirty-one applied here. Actuator: health and the scrape. One runnable jar:
# the seven. Docker: the seven."
x promises '^  files: 6 · entries: 74$'
x promises '^  the condition report: of the 74 entries listed, applied 31 \(positive matches [0-9]+, unconditional [0-9]+\) · skipped 43 \(negative matches\) · neither 0$'
[ "$(n promises "^$SEVEN\$")" = 3 ] || die "promises: the seven, three times"
x promises '^  tiffinbox_orders_cooked_total 120\.0$'; x promises '^  \{"groups":\["liveness","readiness"\],"status":"UP"\} 200    \(keys sorted\)$'
echo "  promises: 6 imports files, 74 entries, 31 applied (43 skipped, 0 neither); health UP + groups; scrape 120.0; the jar 115c36ba...; the image 115c36ba..."

# the exercise's end state: the line exercise/README.md calls "Done" is a line of this capture, after the solution's line - and of
# SOLUTION.md's measured run
XE=$(blk exercise "the solution's line" '')
l='the kitchen, ten days, in the image: {"ordersCooked":40,"ordersValue":8100}'
has "$XE" "$l" "exercise"
awk '/^\*\*Done\*\*/ { f = 1 } f' exercise/README.md | grep -qxF -- "$l" || die "exercise/README.md: Done names no such line"
grep -qxF -- "$l" exercise/solution/SOLUTION.md || die "SOLUTION.md: the measured run shows no such line"
x exercise '^  exit 0 · printed: 0 line\(s\)$'; x exercise '^  exit 0 · listening on 19159 now: 0 · the container tiffinbox-mine: 0$'
echo "  exercise: the README as written, then the solution's line -> 40 orders, 8100, in the image"

# "The binary: readiness, health, the scrape; no loggers - the build fixed the endpoints; a taken port, two sentences; a bare
# number, exit two."
if [ $GOK = yes ]; then
  x native '^  exit 0 · BUILD SUCCESS · stages it printed: 8 of the 8 it announces · its duration, against the bound: 1 minute or more, under 20 minutes · offline: yes$'
  x native '^  file: Mach-O 64-bit executable · the demo token in its bytes: 0$'
  N1=$(blk native "the binary - the README's loggers" "a port taken"); N2=$(blk native "a port taken" "C (labelled)"); N3=$(blk native "C (labelled)" '')
  has "$N1" "$READY" "native: readiness"; has "$N1" "  tiffinbox_orders_cooked_total 120.0" "native: the scrape"; has "$N1" "  404" "native: no loggers"
  has "$N1" "  Boot's first line: Starting AOT-processed TiffinBoxServer using Java 25.0.4.1" "native: AOT-processed"
  taken "$N2" "native, a port taken" 19157; has "$N2" "$SEVEN" "native: the seven"
  has "$N3" "  exit 2" "native C: exit 2"; refused "$N3" "native C" "2 of 2"; has "$N3" "  listening now: 19157 0 · 19151 0" "native C: never bound"
  # "One tree, five forms: the jar, the AOT jar, the binary, the image, the dev class path - each one ready, each the same seven."
  x forms '^five forms, one tree: the seven.s md5 5 of 5 times 115c36bac276128e245ca57df11c2891 · readiness \{"status":"UP"\} 200 5 of 5$'
  for t in '1 the jar' '2 the AOT jar' '3 the binary' '4 the image' '5 the dev class path'; do x forms "^$t - "; done
  x forms '^  Boot.s first line: Starting AOT-processed TiffinBoxServer v1\.0\.0 using Java 25\.0\.4\.1$'
  x forms '^  then docker compose -p tiffinbox-dev down -v: containers, volumes and networks 0$'
  echo "  native: 8 of 8, offline, Mach-O, 0 tokens; readiness, health, scrape 120.0, loggers 404, a port taken: two sentences; C exit 2 · forms: 5 of 5 ready, 5 of 5 115c36ba..."
fi
cmp -s "$TREE/README.md" ../c5-tiffinbox/README.md || echo "  (the anchor has moved past ../c5-unit27/after: this unit's captures are of that tree)" >&3
[ -z "$unpub" ] || die "no published hash for:$unpub - check the captures, then copy the md5s above into receipts.md5 and run again"
echo "c5-unit29: every capture 3/3 and = published; every spoken number asserted; 0 raw demo tokens in every capture, every log, every container's log and the binary; nothing of this run left on Docker"
