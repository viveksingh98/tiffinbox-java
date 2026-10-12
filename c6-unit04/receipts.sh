#!/bin/bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25.0.4.1 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# GRAALVM_HOME names a GraalVM JDK 25 (README.md, "The GraalVM"): the native build reads it. Without it, this script makes every
# capture that needs no GraalVM, filling .m2-demo on the way, then stops before the native build.
# Course 6 · Embedded Tomcat, Threads and Connectors - this unit's receipts. The anchor changes servers: TiffinBox's own (the
# JDK's HttpServer, since Core Java II) hands its job to embedded Tomcat, under Spring MVC's DispatcherServlet. Ten captures,
# each run three times and hashed; cap() DIES when a hash differs from receipts.md5; every number the video says is asserted at
# the bottom by a check that can fail; the demo token is masked (gsub), and the checks count 0 raw copies of it in every capture,
# in the log of every run - every failed start's and the container's included - in every file this unit ships, and in the binary.
#   change    the previous tree against after/: the files that differ; the three files that did the server's jobs, by their
#             lines; the new handler mapping; the POM, the YAML and the factories file, line by line; the jar's lib/ (46 -> 58)
#   bind      where the alias sits (and the check, failing on a planted copy); D: A after/ - the address read off the process,
#             127.0.0.1 - and Tomcat's own line, which never prints it · B (labelled) the two-server copy, no alias: Tomcat on
#             every interface, stopped at once · A' = A; E (labelled) both names given: Boot's wins; the container: the image
#             from after/'s Dockerfile, every interface of the container, published on 127.0.0.1 alone
#   seven     the comparison set on the previous tree (TiffinBox's own server) and on after/ (Tomcat), the timestamp mask (checked
#             on planted lines first), the line that differs, and why - Boot's web log group at DEBUG, and the JSON converter Spring
#             MVC writes with (the harness's Converters)
#   seam      the finale's other checks, before and after: the prefix match, /actuator, health and the scrape's content types,
#             HEAD, Accept and DELETE; then the two timers
#   pool      Tomcat's platform threads while idle, A/B/A': virtual threads on (application.yaml), off, on again
#   threads   whose thread answers, A/B/A': eight slow requests at once (the harness's route) on virtual threads, then on a pool
#             of two; Boot's task executor each time · C (labelled): the AOT jar, virtual threads off at run time
#   stop      POST /shutdown: the reply, Boot's graceful shutdown, exit 0 - and Boot's own metadata for both settings
#   taken     a port taken: before (TiffinBox's two sentences) and after (Boot's); C (labelled) a bare argument, refused before
#             Tomcat; D (labelled) an address this Mac does not have
#   exercise  exercise/README.md's commands and exercise/solution/SOLUTION.md's, read from the files and run as written
#   forms     the native build of after/, then four forms - the jar, the AOT jar, the binary, the image: each one's address,
#             the seven (masked), exit 0; the binary at DEBUG: its named handler and its virtual thread
# "The previous tree" is ../c5-unit27/after (the anchor before this change; ../c5-tiffinbox and c6-tiffinbox's first commit hold the
# same code), COPIED under .harness/before; after/ is this unit's frozen copy of ../c6-tiffinbox after the change, COPIED under
# .harness/after. This script never writes into another unit's folder, and never builds a frozen tree in place. Every run of
# TiffinBox starts in a folder under .harness/ that holds a config tree with the demo token (secrets/), as the README asks - the
# container's too, mounted read-only. Commands are printed exactly as they run: each goes through eval. "$CURLSET" is the
# comparison set since the secrets lesson (../c5-unit11/curlset.sh: the seven requests, POST /shutdown with the token's header
# read from the file). "$M2" is this unit's own repository, .m2-demo. The harness - harness/probe/web/Threads.java and
# Converters.java (the course's, never TiffinBox's: outside com.tiffinbox, joined by --spring.main.sources, on the extracted jar's
# class path), harness/slow8.sh
# (eight slow requests at once), harness/shutdown.sh (POST /shutdown, the token read from its file) and harness/two.py (the
# two-server copy) - is named on every capture that uses it. Every run passes options only, except the one that shows the refusal.
# The network: every Maven build runs offline (-o) against .m2-demo and says so ("offline: yes"); a build that cannot resolve an
# artifact offline goes to Maven Central once, and says that ("offline: no - ..."). GraalVM's native plugin reads its metadata
# repository (a zip) from .m2-demo - and when the zip is not there it downloads it from GitHub, even under -o: so a native-profile
# build without the zip goes to Maven Central for it at once, and every native build's log is searched for the plugin's own
# download line - found, the run stops. Docker: no pull - eclipse-temurin:25-jre must already be on the daemon, and docker build
# prints how many of its lines say pull. At run time nothing leaves 127.0.0.1: TiffinBox listens there (in a container, on the
# container's own addresses, published on the host's 127.0.0.1 alone; the one wildcard bind, B, is stopped as soon as it
# listens), every request goes there, and Logback writes to the terminal only. 192.0.2.1 (taken D) is never reached: the bind
# fails on this Mac before any packet.
# Masks and filters (README.md declares each; awk sub/gsub only): the demo token becomes "[masked: the N-character token]" (N its
# own length); the GraalVM's folder "$GRAALVM_HOME"; this folder's absolute path "…", the folder above it "…/..", the home folder
# "~"; your user name "<user>" - in every line of every capture. Spring's error timestamp becomes "…" (both forms: an ISO-8601
# string, epoch milliseconds) in the seven and wherever Spring's error body is printed; a thread's number becomes N (exec-N,
# tomcat-handler-N, task-N, Catalina-utility-N); an identity hash after "@" becomes "…"; the date in a DEBUG line's error map
# becomes "…"; where a native-image warning names the file it read an option from, the file's URL - or "null", which it prints
# when the path holds a space - becomes "…". A failed start's log is read after it exited, never printed whole (the failure lesson's shape: frames counted, the
# analysis shown). A run's log lines are printed from their message on (no time, no process id); Boot's first line is cut before
# " with PID". Long DEBUG output goes through a declared filter, and what it cuts is counted. No image, container or ID is
# printed but the base image's digest. No duration is captured: the native build is judged against a bound; seconds go to the
# terminal. No capture compares the environment's names, so macOS's __CF_USER_TEXT_ENCODING (which env -i adds) needs no setting
# aside here.
# Ports (brief ⚑1, 19330-19339): after/'s jar 19330 · the previous tree's 19331 (and E's --tiffinbox.port, never bound) · E's
# --server.port and the idle pools 19332 · threads 19333 · the AOT jar 19334 · the two-server copy 19335 (TiffinBox's own server)
# and 19336 (Tomcat, every interface - B only; taken C and D, never bound) · the image 19337 · the binary 19338 · the exercise
# 19339. 18425 (TiffinBox's default) and 8080 (Tomcat's) are checked free too, and never bound on this machine (18425 only inside
# a container).
# Docker names (no unit number): the image tiffinbox-tomcat:1.0.0 and the container tiffinbox-tomcat. Each is checked absent before
# the first run - a name already there may be yours, and this script removes only what it creates - and removed on every exit:
# the container with docker rm -f, the image by name and by every ID a build of this run recorded. Docker's build cache is not
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
IMG=tiffinbox-tomcat:1.0.0; BOX=tiffinbox-tomcat
OURS=""                                              # set once the start-up checks found none of the Docker names above
# On every exit - the end, a failed check, or Ctrl-C - stop the processes this script started in the background ($pid, a server;
# $fpid, a start expected to end by itself; $xpid, the exercise's commands), if they still run, then sweep(): anything of this run
# still alive in its process group - a TiffinBox JVM, a binary, native-image's driver or builder - is stopped; then dclean(): this
# run's container and image. After an interrupt, a capture's unfinished runs (.r-NAME.1-3) go too; after a failed check they stay,
# for the diff the message names. The clean-up ignores a second Ctrl-C, and nothing in it can fail under set -e, so it always
# reaches the rmdir; the script still exits 130 after an interrupt (README.md, "Interrupted"). $pid, $fpid and $xpid are cleared
# whenever their process has been reaped.
pid=""; fpid=""; xpid=""
sweep() { local g i l
  g=$(ps -o pgid= -p $$ 2> /dev/null | tr -d ' ') || g=""
  [ -n "$g" ] || return 0
  i=0; while [ $i -lt 20 ]; do
    l=$(ps -axo pid=,pgid=,command= 2> /dev/null | awk -v g="$g" -v me=$$ -v gh="${GRAALVM_HOME:-/nonexistent}" '
      $2 == g && $1 != me && $3 != "awk" && $3 != "ps" && (index($0, "vminvocation.args") || index($3, gh "/bin/native-image") || $3 ~ /tiffinbox-web\/target\/tiffinbox-web$/ || index($0, "tiffinbox-web-1.0.0.jar") || index($0, "com.tiffinbox.web.TiffinBoxServer") || index($0, "slow8.sh")) { print $1 }' | paste -sd' ' -) || l=""
    [ -n "$l" ] || return 0
    if [ $i -lt 10 ]; then kill $l 2> /dev/null || true; else kill -9 $l 2> /dev/null || true; fi
    sleep 0.5; i=$((i + 1)); done; }
dclean() { [ -n "$OURS" ] || return 0
  docker rm -f "$BOX" > /dev/null 2>&1 || true
  docker image rm -f "$IMG" $(sort -u .harness/imgids 2> /dev/null) > /dev/null 2>&1 || true; }
trap 'trap "" INT TERM; for p in "$pid" "$fpid" "$xpid"; do if [ -n "$p" ] && kill "$p" 2> /dev/null; then wait "$p" 2> /dev/null || true; fi; done; sweep || true; dclean || true; [ -z "$INTR" ] || rm -f .r-*.[123]; rmdir .r-lock 2> /dev/null || true' EXIT
INTR=""; trap 'INTR=1; exit 130' INT TERM
exec 3>&1                                            # die() speaks to the terminal even inside a redirected capture
die() { echo "  *** $* ***" >&3; exit 1; }
java -version 2>&1 | grep -q 'version "25' || die "JDK 25 needed; JAVA_HOME gives: $(java -version 2>&1 | head -1)"
for t in python3 curl rsync lsof unzip javac docker; do command -v $t > /dev/null || die "$t is needed"; done
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
PREV=../c5-unit27/after                              # the previous tree: the anchor before this change - read, copied
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
for f in harness/shutdown.sh harness/slow8.sh harness/two.py harness/probe/web/Threads.java harness/probe/web/Converters.java exercise/README.md exercise/solution/SOLUTION.md; do [ -f "$f" ] || die "$f is missing"; done

# The ports and the Docker names, BEFORE anything is wiped (a survivor of an interrupted run answers POST /shutdown only with its
# token, which lives in .harness/ - so the message names the process to kill).
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
for p in 18425 8080 19330 19331 19332 19333 19334 19335 19336 19337 19338 19339; do
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
R_TWO=$(readme "$J --server.port=18432")
R_WEB=$(readme "$J --logging.level.web=debug")
R_VOFF=$(readme "$J --spring.threads.virtual.enabled=false")
R_POOL2=$(readme "$J --spring.threads.virtual.enabled=false --server.tomcat.threads.max=2")
R_ADDR=$(readme "$J --tiffinbox.address=192.0.2.1")
R_BARE=$(readme 'TIFFINBOX_PORT=18432 java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar 18431')
R_AOTRUN=$(readme 'java -Dspring.aot.enabled=true -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431')
R_AOTOFF=$(readme "java -Dspring.aot.enabled=true -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --spring.threads.virtual.enabled=false --logging.level.kitchen=debug --logging.pattern.console='%thread %msg%n'")
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
# The options this unit's lines add to the run line: read off the README's lines, never typed.
VOFF=${R_VOFF#"$J "}; POOL2=${R_POOL2#"$J "}; WEBF=${R_WEB#"$J "}
[ "$VOFF" = '--spring.threads.virtual.enabled=false' ] && [ "$POOL2" = '--spring.threads.virtual.enabled=false --server.tomcat.threads.max=2' ] && [ "$WEBF" = '--logging.level.web=debug' ] || die "the README's options"
# off DIR 'README mvn LINE' [PHASE]: the README's Maven line as this script runs it - from DIR, offline (-o), this unit's own
# repository, and for a build phase (package, install) clean and without tests. dev() takes those four things back out, and
# must give the README's line again: so the command on screen is the README's, with exactly those changes.
off() { local c=${2/mvn -B /mvn -o -B -Dmaven.repo.local=\"\$M2\" }
  [ -n "$3" ] && c=${c/ $3/ -DskipTests clean $3}
  printf 'cd %s && %s\n' "$1" "$c"; }
dev() { local c=${1#cd * && }; c=${c/ -o -B -Dmaven.repo.local=\"\$M2\" / -B }; c=${c/ -DskipTests clean / }; printf '%s\n' "$c"; }
# at DIR PORT 'README LINE': the README's line run from DIR, its port 18431 made PORT
at() { printf 'cd %s && %s\n' "$1" "${3/--tiffinbox.port=18431/--tiffinbox.port=$2}"; }
# at2 DIR PORT1 PORT2 'README LINE': the same, and its --server.port=18432 made PORT2
at2() { local c=${4/--tiffinbox.port=18431/--tiffinbox.port=$2}; printf 'cd %s && %s\n' "$1" "${c/--server.port=18432/--server.port=$3}"; }
# bareat DIR VPORT BPORT: the README's old command run from DIR - its variable's port 18432 made VPORT, its bare 18431 made BPORT
bareat() { local c=${R_BARE/TIFFINBOX_PORT=18432/TIFFINBOX_PORT=$2}; printf 'cd %s && %s %s\n' "$1" "${c% 18431}" "$3"; }
# hcp DIR PORT ['FLAGS'] [CLASS]: the README's class-path line - the extracted jar, TiffinBox's own main - from DIR, its port made
# PORT, the harness's classes added to the class path (../hc) and CLASS joined (--spring.main.sources=, probe.web.Threads unless
# named); FLAGS after
hcp() { local c; c=$(at "$1" "$2" "$R_CP"); c=${c/lib\/\*\"/lib\/*:..\/hc\"}; printf '%s --spring.main.sources=%s%s\n' "$c" "${4:-probe.web.Threads}" "${3:+ $3}"; }
# url 'README curl LINE' PORT: the README's curl line, its port 18431 made PORT
url() { printf '%s\n' "${1/:18431\//:$2/}"; }
# qc PORT PATH ['CURL OPTIONS']: the README's status-and-type line, its port made PORT and its path PATH, OPTIONS before the URL
qc() { local c; c=$(url "$R_Q" "$1"); c=${c%/customers}$2; [ -z "$3" ] || c=${c/ http:/ $3 http:}; printf '%s\n' "$c"; }
# exe 'COMMAND': the command with "exec" after its "cd DIR && " and any NAME=value before the program - so $pid is the program's
exe() { printf '%s\n' "$1" | sed -E 's/&& (([A-Z_]+=[^ ]* )*)/\&\& \1exec /'; }
# The docker lines, as this script runs them: the README's build line with plain progress and this script's own tag; its run line
# with this script's own name and tag, the port published on 127.0.0.1 made PORT, and your user and group added - the config tree
# is yours, mode 0600 (R.74). undock() takes those changes back out, and must give the README's lines again.
UARG='--user "$(id -u):$(id -g)"'
dbuild() { local c=${R_DBUILD/docker build -t tiffinbox-docker:1.0.0 /docker build --progress=plain -t $IMG }; printf 'cd %s && %s\n' "$1" "$c"; }
drun() { local c=${R_DRUN/--name tiffinbox /--name $BOX $UARG }; c=${c/127.0.0.1:18431:18425/127.0.0.1:$2:18425}; c=${c/% tiffinbox-docker:1.0.0/ $IMG}; printf 'cd %s && %s\n' "$1" "$c"; }
undock() { local c=${1#cd * && }; c=${c/--progress=plain /}; c=${c/" $UARG"/}; c=${c//$IMG/tiffinbox-docker:1.0.0}; c=${c/--name $BOX /--name tiffinbox }; c=${c/127.0.0.1:1933?:18425/127.0.0.1:18431:18425}; printf '%s\n' "$c"; }
[ "$(undock "$(dbuild .harness/x)")" = "$R_DBUILD" ] || die "not the README's build line with the declared changes: $(dbuild .harness/x)"
[ "$(undock "$(drun .harness/x 19337)")" = "$R_DRUN" ] || die "not the README's run line with the declared changes: $(drun .harness/x 19337)"
C_PRE=$(off .harness/pre "$R_INSTALL" install)
for c in "$C_PRE" "$(off .harness/x "$R_PLAIN" package)" "$(off .harness/x "$R_PNAT" package)" "$(off .harness/x "$R_NATIVE")"; do
  r=$(dev "$c"); [ "$r" = "$R_PLAIN" ] || [ "$r" = "$R_PNAT" ] || [ "$r" = "$R_INSTALL" ] || [ "$r" = "$R_NATIVE" ] || die "not a README line with the offline changes: $c"; done
[ "$(exe "$(at .harness/x 19330 "$R_RUN")")" = 'cd .harness/x && exec java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19330' ] || die "exe()"
[ "$(at2 .harness/x 19331 19332 "$R_TWO")" = 'cd .harness/x && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19331 --server.port=19332' ] || die "at2()"
[ "$(exe "$(bareat .harness/x 19335 19336)")" = 'cd .harness/x && TIFFINBOX_PORT=19335 exec java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar 19336' ] || die "bareat()"
[ "$(hcp .harness/x 19330 "$WEBF" probe.web.Converters)" = 'cd .harness/x && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19330 --spring.main.sources=probe.web.Converters --logging.level.web=debug' ] || die "hcp(), the harness's Converters"
[ "$(hcp .harness/x 19333 "$POOL2")" = 'cd .harness/x && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19333 --spring.main.sources=probe.web.Threads --spring.threads.virtual.enabled=false --server.tomcat.threads.max=2' ] || die "hcp()"
[ "$(qc 19330 /customersXYZ)" = "curl -s -o /dev/null -w '%{http_code} %{content_type}\n' http://127.0.0.1:19330/customersXYZ" ] && [ "$(qc 19330 /customers -I)" = "curl -s -o /dev/null -w '%{http_code} %{content_type}\n' -I http://127.0.0.1:19330/customers" ] || die "qc()"
echo "  the commands: after/README.md gives all 24 lines this script runs or derives from"

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
javac -d .harness/hc -cp ".harness/pre/tiffinbox-web/target/extracted/lib/*" harness/probe/web/Threads.java harness/probe/web/Converters.java > .harness/javac.log 2>&1 || { cat .harness/javac.log >&3; die "the harness did not compile against after/'s jar"; }
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
# tline: Tomcat's own line, from its message on - polled until it is there (up to 30 s)
tline() { local i=0; while ! grep -q 'Tomcat started on port ' .harness/run.out && [ $i -lt 120 ]; do sleep 0.25; i=$((i + 1)); done
  echo "  Tomcat's own line: $(grep -m1 'Tomcat started on port ' .harness/run.out | sed 's/^.* : //; s/^main //')"; }
ask() { local c; c=$(url "$1" "$2"); echo "\$ $c"; (eval "$c") 2>&1 < /dev/null | sed 's/^/  /'; }
# sortj: a JSON answer followed by curl's status (" 200"), its keys sorted - Jackson 2 and Jackson 3 order keys differently
sortj() { python3 -c '
import json, sys
for l in sys.stdin.read().splitlines():
    b, _, s = l.rpartition(" ")
    try: o = json.dumps(json.loads(b), sort_keys=True, separators=(",", ":"))
    except ValueError: print("  " + l); continue
    print("  " + o + " " + s + ("    (keys sorted)" if o != b else ""))'; }
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
# stop PORT DIR: POST /shutdown with DIR's token (harness/shutdown.sh); the JVM must leave, the port must be free
stop() { echo "\$ harness/shutdown.sh $1 $2/$TF"; harness/shutdown.sh "$1" "$2/$TF" | sed 's/^/  /'; gone "$1"; echo "  exit $LASTE · listening on $1 now: 0"; logtok; }
SHAPEAWK='
an { if (NF) ana[++na] = "  " $0; next }
/^Description:$/ { an = 1; ana[++na] = "  " $0; next }
/^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T[^ ]+ +[A-Z]+ +[0-9]+ --- \[/ {
  lv = $2; s = $0; i = index(s, " --- ["); s = substr(s, i + 6); i = index(s, "] "); s = substr(s, i + 2)
  i = index(s, " : "); lg = substr(s, 1, i - 1); sub(/ +$/, "", lg); msg = substr(s, i + 3)
  if (lv == "WARN" || lv == "ERROR") {
    if (lv == "WARN" && match(msg, /attempt: [A-Za-z0-9_.$]+/)) msg = substr(msg, 1, RSTART + RLENGTH - 1) " …"
    ln[++nl] = "  " lv " " lg (msg == "" ? ":" : ": " msg) }
  if (index(msg, "Tomcat started on port ") == 1 || index(msg, "Tomcat initialized with port ") == 1) tc++
  next }
/^\tat / { fr++; if (ne) fx[ne]++; next }
/^\t\.\.\. [0-9]+ (common frames omitted|more)$/ { om += $2; next }
/^Caused by: / { cb++; ex[++ne] = "  " $0; next }
/^([a-z][a-z0-9_]*\.)+[A-Z][A-Za-z0-9_$]*(: .*)?$/ { ex[++ne] = "  " $0; next }
/^APPLICATION FAILED TO START$/ { ban++; next }
/^Error starting ApplicationContext\. To display the condition evaluation report re-run your application with .debug. enabled\.$/ { hint = $0; next }
END {
  by = ""; for (i = 1; i <= ne; i++) by = by (i == 1 ? " = " : " + ") (fx[i] + 0)
  print "  its log, read after it exited: APPLICATION FAILED TO START " (ban + 0) " · stack frames " (fr + 0) (fr ? by : "") " · Caused by: " (cb + 0) " · frames folded as common " (om + 0) " · Tomcat lines " (tc + 0)
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
# tnum: a thread's number becomes N - Tomcat's exec-N and tomcat-handler-N, Boot's task-N, Catalina-utility-N (README.md, Masks)
tnum() { awk '{ gsub(/-exec-[0-9]+/, "-exec-N"); gsub(/tomcat-handler-[0-9]+/, "tomcat-handler-N"); gsub(/task-[0-9]+/, "task-N"); gsub(/Catalina-utility-[0-9]+/, "Catalina-utility-N"); print }'; }
# group: identical lines counted - "  8 × name"
group() { sort | uniq -c | awk '{ n = $1; sub(/^ *[0-9]+ /, ""); print "  " n " × " $0 }'; }
mask() { awk -v t="$TOKEN" -v g="${GRAALVM_HOME:-}" -v u="$U" -v up="$UP" -v hm="$HOME" -v me="$ME" -v tl="${#TOKEN}" '
  function lit(x) { gsub(/[][\\.^$*+?(){}|\/]/, "\\\\&", x); return x }
  function enc(x) { gsub(/ /, "%20", x); return x }
  BEGIN { T = lit(t); G = lit(g); GE = lit(enc(g)); P = lit(u); Q = lit(up); H = lit(hm); PE = lit(enc(u)); QE = lit(enc(up)); M = lit(me) }
  { gsub(T, "[masked: the " tl "-character token]"); if (g != "") { gsub(G, "$GRAALVM_HOME"); gsub(GE, "$GRAALVM_HOME") }; gsub(P, "…"); gsub(PE, "…")
    gsub(Q, "…/.."); gsub(QE, "…/.."); gsub(H, "~"); gsub(M, "<user>"); print }'; }

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
JDKRE='(^|[^A-Za-z])Http(Server|Exchange|Handler)([^A-Za-z]|$)|com\.sun\.net\.httpserver'
code() { grep -vE '^[[:space:]]*(\*|/\*\*|\*/|//|#|<!--|$)' "$1"; }
# xcode FILE: an XML file's lines without its comments (<!-- ... -->, over several lines too) and without blank lines
xcode() { awk '{ l = $0; o = ""; while (l != "") { if (c) { i = index(l, "-->"); if (!i) { l = ""; break }; l = substr(l, i + 3); c = 0 } else { i = index(l, "<!--"); if (!i) { o = o l; l = "" } else { o = o substr(l, 1, i - 1); l = substr(l, i + 4); c = 1 } } }; if (o ~ /[^ ]/) print o }' "$1"; }
lines() { if [ -f "$1" ]; then wc -l < "$1" | tr -d ' '; else echo deleted; fi; }
libs() { unzip -Z1 "$1" | grep -E '^BOOT-INF/lib/.*\.jar$' | sed 's#^BOOT-INF/lib/##' | sort; }

extract() { local c="cd $1 && $R_EXTRACT"; echo "\$ $c"; (eval "$c") > .harness/extract.log 2>&1 < /dev/null || die "the README's extract line failed in $1"; echo "  exit 0"; }

# ---- change: the previous tree against after/ ---------------------------------------------------------------------------------
change() { local f
  echo "the previous tree and after/, both copied under .harness/ with a config tree, each built with the README's line (offline):"
  copy "$PREV" .harness/before; copy after .harness/after
  pbuild .harness/before "the previous tree"; pbuild .harness/after "after/"
  echo "after/'s jar, extracted (the README's line) - the class path the harness joins, in pool and threads:"
  extract .harness/after
  echo "the files that differ:"
  echo "\$ diff -rq -x target -x secrets .harness/before .harness/after"
  diff -rq -x target -x secrets .harness/before .harness/after | sed 's/^/  /' || true
  echo "the three files that did the server's jobs, their lines (wc -l), before -> after:"
  for f in TiffinBoxServer ActuatorRoutes PortTakenFailureAnalyzer; do echo "  $f.java: $(lines ".harness/before/$W/$f.java") -> $(lines ".harness/after/$W/$f.java")"; done
  code ".harness/before/$W/TiffinBoxServer.java" > .harness/fb.txt; code ".harness/after/$W/TiffinBoxServer.java" > .harness/fa.txt
  echo "  TiffinBoxServer.java, its lines that are neither comment nor blank: $(wc -l < .harness/fb.txt | tr -d ' ') -> $(wc -l < .harness/fa.txt | tr -d ' ') · naming the JDK's server (HttpServer, HttpExchange, HttpHandler, com.sun.net.httpserver): $(grep -cE "$JDKRE" .harness/fb.txt || true) -> $(grep -cE "$JDKRE" .harness/fa.txt || true) · the servlet API's (HttpServletRequest, HttpServletResponse): $(grep -cE 'HttpServlet(Request|Response)' .harness/fb.txt || true) -> $(grep -cE 'HttpServlet(Request|Response)' .harness/fa.txt || true)"
  echo "  RouteMapping.java - new; its lines that are neither comment nor blank: $(code ".harness/after/$W/RouteMapping.java" | wc -l | tr -d ' ')"
  code ".harness/after/$W/RouteMapping.java" | sed 's/^/    /'
  xcode .harness/before/tiffinbox-web/pom.xml > .harness/fb.txt; xcode .harness/after/tiffinbox-web/pom.xml > .harness/fa.txt
  echo "  tiffinbox-web/pom.xml - its lines that are neither comment nor blank, the ones that differ:"
  diff .harness/fb.txt .harness/fa.txt | grep -E '^[<>]' | sed 's/^/    /' || true
  echo "  tiffinbox-web/pom.xml - <dependency> $(grep -c '<dependency>' .harness/before/tiffinbox-web/pom.xml) -> $(grep -c '<dependency>' .harness/after/tiffinbox-web/pom.xml) · Boot's plugin's <exclude> $(grep -c '<exclude>' .harness/before/tiffinbox-web/pom.xml) -> $(grep -c '<exclude>' .harness/after/tiffinbox-web/pom.xml) · the native plugin's <exclusion> $(grep -c '<exclusion>' .harness/before/tiffinbox-web/pom.xml) -> $(grep -c '<exclusion>' .harness/after/tiffinbox-web/pom.xml)"
  code ".harness/before/$YAML" > .harness/fb.txt; code ".harness/after/$YAML" > .harness/fa.txt
  echo "  $YAML - its lines that are neither comment nor blank, the ones that differ:"
  diff .harness/fb.txt .harness/fa.txt | grep -E '^[<>]' | sed 's/^/    /' || true
  code ".harness/before/$FAC" > .harness/fb.txt; code ".harness/after/$FAC" > .harness/fa.txt
  echo "  $FAC - its lines that are neither comment nor blank, before then after:"
  sed 's/^/    before /' .harness/fb.txt; sed 's/^/    after  /' .harness/fa.txt
  code ".harness/before/$W/BareArgumentAnalyzer.java" > .harness/fb.txt; code ".harness/after/$W/BareArgumentAnalyzer.java" > .harness/fa.txt
  echo "  BareArgumentAnalyzer.java - its Javadoc lines that differ: $(diff ".harness/before/$W/BareArgumentAnalyzer.java" ".harness/after/$W/BareArgumentAnalyzer.java" | grep -c '^<' || true) · its lines that are neither comment nor blank, against the previous tree's: $(cmp -s .harness/fb.txt .harness/fa.txt && echo the same || echo different)"
  diff .harness/before/README.md .harness/after/README.md > .harness/file.diff || true
  echo "  README.md - the anchor's README: lines added $(grep -c '^> ' .harness/file.diff || true), removed $(grep -c '^< ' .harness/file.diff || true) - its new section and the history notes the change made false (not shown)"
  echo "  tiffinbox-core against the previous tree's (diff -rq -x target): $(diff -rq -x target .harness/before/tiffinbox-core .harness/after/tiffinbox-core | wc -l | tr -d ' ') files differ"
  for f in $W/Route.java $W/TiffinBoxApp.java $W/BareArgumentGuard.java $W/KitchenHealthIndicator.java $W/KitchenMetrics.java pom.xml Dockerfile compose.yaml .dockerignore; do
    echo "  $(basename "$f") against the previous tree's, byte for byte: $(cmp -s ".harness/before/$f" ".harness/after/$f" && echo the same || echo different)"; done
  libs .harness/before/$JARP > .harness/lb.txt; libs .harness/after/$JARP > .harness/la.txt
  echo "the executable jar's BOOT-INF/lib: $(wc -l < .harness/lb.txt | tr -d ' ') jars -> $(wc -l < .harness/la.txt | tr -d ' ') · removed $(comm -23 .harness/lb.txt .harness/la.txt | wc -l | tr -d ' ') · added $(comm -13 .harness/lb.txt .harness/la.txt | wc -l | tr -d ' '):"
  comm -13 .harness/lb.txt .harness/la.txt | sed 's/^/    /'
  echo "  Jackson 3 (tools.jackson) in the jar: before $(grep -cE '^jackson-[a-z-]+-3\.' .harness/lb.txt || true) -> after $(grep -cE '^jackson-[a-z-]+-3\.' .harness/la.txt || true) · Jackson 2 (jackson-databind 2.x): before $(grep -cE '^jackson-databind-2\.' .harness/lb.txt || true) -> after $(grep -cE '^jackson-databind-2\.' .harness/la.txt || true)"; }

# ---- bind: where TiffinBox listens on Tomcat ------------------------------------------------------------------------------------
# place FILE: where server.address and server.port sit in an application.yaml - their line numbers, and the first "---"'s
place() { awk '
  /^server:$/ && !s { s = NR }
  /^  address: \$\{tiffinbox\.address\}$/ && !a { a = NR }
  /^  port: \$\{tiffinbox\.port\}$/ && !p { p = NR }
  /^---$/ && !d { d = NR }
  END { ok = (s && a && p && d && a == s + 1 && p == s + 2 && p < d) ? "yes" : "no"
        printf "server: line %d · address: ${tiffinbox.address} line %d · port: ${tiffinbox.port} line %d · the first \"---\" line %d · in the first document: %s\n", s, a, p, d, ok }' "$1"; }
# blines LOG: docker build's output through its filter - the metadata line, the FROM line, the naming line (each without its step
# number and timing), how many lines say pull, and how many lines are not shown. BuildKit writes a step's end as " done", or as
# " 0.0s done" when the step took measurable time: both are cut.
blines() { local s
  s=$(grep -E '^#[0-9]+ \[internal\] load metadata for |^#[0-9]+ \[[a-z0-9-]+ 1/[0-9]+\] FROM |^#[0-9]+ naming to ' "$1" | sed -E 's/^#[0-9]+ //; s/( [0-9]+\.[0-9]+s)? done$//' | awk '!seen[$0]++')
  printf '%s\n' "$s" | sed 's/^/    /'
  echo "  its lines that say pull: $(grep -ci 'pull' "$1" || true) · its other lines: not shown"; }
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
image() { local c ec=0
  c=$(dbuild .harness/after); echo "\$ $c"
  (eval "$c") > .harness/dbuild.log 2>&1 < /dev/null || ec=$?
  [ $ec = 0 ] || { tail -20 .harness/dbuild.log >&3; die "docker build failed"; }
  docker image inspect -f '{{.Id}}' "$IMG" >> .harness/imgids
  echo "  exit $ec · its lines, through the filter:"; blines .harness/dbuild.log
  echo "  the image: user $(docker image inspect -f '{{.Config.User}}' "$IMG") · entrypoint $(docker image inspect -f '{{json .Config.Entrypoint}}' "$IMG") · its environment's TIFFINBOX_ADDRESS: $(docker image inspect -f '{{range .Config.Env}}{{println .}}{{end}}' "$IMG" | grep '^TIFFINBOX_ADDRESS=' | sed 's/^TIFFINBOX_ADDRESS=//')"; }
bind_() { local c l
  echo "Boot's own metadata, in after/'s jar: $(meta .harness/after/$JARP server.address) · $(meta .harness/after/$JARP server.port)"
  echo "where the alias sits - after/'s application.yaml, then a planted copy with the same three lines moved below the \"---\" (the check must fail there):"
  echo "  after/: $(place .harness/after/$YAML)"
  awk '/^server:$/ { s = 1; b = $0; next } s && /^  (address|port): / { b = b "\n" $0; next } { s = 0; print } END { print b }' .harness/after/$YAML > .harness/planted.yaml
  echo "  the planted copy: $(place .harness/planted.yaml)"; rm -f .harness/planted.yaml
  echo "A - after/, the README's run line, port 19330:"
  start "$(at .harness/after 19330 "$R_RUN")"; up; ready 19330; tline
  stop 19330 .harness/after
  echo "B (labelled) - the two-server copy: the previous tree, Spring MVC's starter added (harness/two.py), no alias; the README's two-name line, ports 19335 and 19336, stopped as soon as Tomcat listens:"
  copy "$PREV" .harness/two; python3 harness/two.py .harness/two
  echo "  harness/two.py: tiffinbox-web/pom.xml's lines that differ from the previous tree's: $(diff .harness/before/tiffinbox-web/pom.xml .harness/two/tiffinbox-web/pom.xml | grep -c '^>' || true) added (the starter) · $(diff .harness/before/tiffinbox-web/pom.xml .harness/two/tiffinbox-web/pom.xml | grep -c '^<' || true) removed (two Jackson 3 excludes) · application.yaml: $(cmp -s .harness/before/$YAML .harness/two/$YAML && echo the same || echo different)"
  pbuild .harness/two "the two-server copy"
  c=$(at2 .harness/two 19335 19336 "$R_TWO")
  case $c in *' --server.port=19336') ;; *) die "B must give Tomcat a port of this unit's: never Boot's default, 8080" ;; esac
  start "$c"; l=$(listening 19336)
  case " $l " in *':8080 '*) kill -9 "$pid" 2> /dev/null || true; die "B listened on 8080";; *' *:19336 '*|*' 127.0.0.1:19336 '*) ;; *) kill "$pid" 2> /dev/null || true; die "B: Tomcat never listened on 19336 ($l)";; esac
  kill "$pid"; local e=0; wait "$pid" || e=$?; pid=""
  echo "  listens on: $l · loopback only: $(lb "$l")"
  echo "  its own line: $(grep -m1 ' : TiffinBox listening on ' .harness/run.out | sed 's/^.* : //') · Tomcat's: $(grep -m1 'Tomcat started on port ' .harness/run.out | sed 's/^.* : //')"
  echo "  stopped by its pid at once (SIGTERM): exit $e"; now 19335 19336; logtok
  echo "A' - A again:"
  start "$(at .harness/after 19330 "$R_RUN")"; up; ready 19330; tline
  stop 19330 .harness/after
  echo "E (labelled) - after/, both names given: the README's two-name line, ports 19331 (--tiffinbox.port) and 19332 (--server.port):"
  start "$(at2 .harness/after 19331 19332 "$R_TWO")"; up; ready 19332; tline; now 19331 19332
  stop 19332 .harness/after
  echo "the container - after/'s Dockerfile (the README's two lines, Maven's above, then Docker), the README's run line with your user, published on 127.0.0.1:19337:"
  image
  dstart "$(drun .harness/after 19337)"; ready 19337 "$BOX"
  dbind 19337
  echo "\$ harness/shutdown.sh 19337 .harness/after/$TF"; harness/shutdown.sh 19337 ".harness/after/$TF" | sed 's/^/  /'
  dgone "$BOX"; dlog "$BOX"
  echo "  its log (docker logs): Tomcat's own line: $(grep -m1 'Tomcat started on port ' .harness/run.out | sed 's/^.* : //') · the demo token 0 times · X-Shutdown-Token 0 times"
  docker rm "$BOX" > /dev/null; now 19337; }

# ---- seven: the comparison set, before and after ----------------------------------------------------------------------------
# settle: the log stops growing (the same length twice, 0.5 s apart; up to 15 s) - a request's last DEBUG line is written just
# after its answer leaves
settle() { local i=0 a b=-1; while [ $i -lt 30 ]; do a=$(wc -l < .harness/run.out | tr -d ' '); [ "$a" = "$b" ] && return 0; b=$a; sleep 0.5; i=$((i + 1)); done; die "the log never settled"; }
# dbg FROM: the run's DEBUG lines after line FROM, from their logger on, an identity hash after "@" and a date in an error map
# made "…" (README.md, Masks)
dbg() { awk -v from="$1" 'NR > from && / DEBUG [0-9]+ --- \[/ { s = $0; i = index(s, " --- ["); s = substr(s, i + 6); i = index(s, "] "); s = substr(s, i + 2)
    i = index(s, " : "); lg = substr(s, 1, i - 1); sub(/ +$/, "", lg); msg = substr(s, i + 3)
    gsub(/@[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]+/, "@…", msg); gsub(/timestamp=[^,]*,/, "timestamp=…,", msg); print "    " lg ": " msg }' .harness/run.out; }
seven_() { local n0 c
  echo "before - the previous tree, TiffinBox's own server: the README's run line, port 19331:"
  start "$(at .harness/before 19331 "$R_RUN")"; up; ready 19331
  echo "  its own line: $(grep -m1 ' : TiffinBox listening on ' .harness/run.out | sed 's/^.* : //')"
  seven 19331 .harness/before; cp .harness/responses.m.txt .harness/s-before.txt
  echo "after - after/, Tomcat: the README's run line, port 19330:"
  start "$(at .harness/after 19330 "$R_RUN")"; up; ready 19330; tline
  seven 19330 .harness/after; cp .harness/responses.m.txt .harness/s-after.txt
  echo "  the seven, the timestamp masked:"; sed 's/^/    /' .harness/s-after.txt
  echo "the mask, checked first on four planted lines - two timestamps as ISO-8601 strings, two as epoch milliseconds:"
  printf '%s\n' '{"timestamp":"2026-10-12T18:01:40.647Z","status":404}' '{"timestamp":"2026-10-12T18:01:41.002Z","status":404}' '{"timestamp":1791827863978,"status":404}' '{"timestamp":1791827864201,"status":404}' > .harness/planted-ts.txt
  echo "  distinct lines before it: $(sort -u .harness/planted-ts.txt | wc -l | tr -d ' ') · after it: $(tsmask < .harness/planted-ts.txt | sort -u | wc -l | tr -d ' ') · $(tsmask < .harness/planted-ts.txt | sort -u | paste -sd' ' -)"; rm -f .harness/planted-ts.txt
  echo "before against after, the lines that differ (diff):"
  diff .harness/s-before.txt .harness/s-after.txt | sed 's/^/  /' || true
  echo "why - after/ on the README's class-path line with the harness's Converters joined, Boot's web log group at DEBUG (the README's option), port 19330: the DispatcherServlet starts at the first request (a readiness poll); Spring MVC's JSON converters; then GET /nowhere, alone:"
  start "$(hcp .harness/after 19330 "$WEBF" probe.web.Converters)"; up; ready 19330
  echo "  at start, TiffinBox's handler mapping: $(grep -m1 "in 'tiffinBoxRoutes'" .harness/run.out | sed 's/^.* : //')"
  c="curl -s http://127.0.0.1:19330/probe/converters"; echo "\$ $c"; (eval "$c") 2>&1 < /dev/null | sed 's/^/  /'
  settle; n0=$(wc -l < .harness/run.out | tr -d ' ')
  c=$(qc 19330 /nowhere); echo "\$ $c"; (eval "$c") 2>&1 < /dev/null | sed 's/^/  /'
  settle
  echo "  its lines at DEBUG - $(dbg "$n0" | grep -c . || true):"; dbg "$n0"
  stop 19330 .harness/after; }

# ---- seam: the finale's other checks, before and after; the two timers ------------------------------------------------------------
# q PORT PATH ['CURL OPTIONS']: the README's status-and-type line, printed and run
q() { local c; c=$(qc "$@"); echo "\$ $c"; (eval "$c") 2>&1 < /dev/null | sed 's/^/  /'; }
# timers PORT: the scrape's count lines for TiffinBox's paths - Boot's http_server_requests (Actuator's own paths left out: the
# readiness polls move them) and TiffinBox's tiffinbox_requests - read until two reads 0.5 s apart agree (up to 15 s)
tread() { curl -s "http://127.0.0.1:$1/actuator/prometheus" | grep -E '^(http_server_requests_seconds_count|tiffinbox_requests_seconds_count)\{' | grep -v 'uri="/actuator' | sort; }
timers() { local i=0 a b=x; while [ $i -lt 30 ]; do a=$(tread "$1"); [ "$a" = "$b" ] && break; b=$a; sleep 0.5; i=$((i + 1)); done
  printf '%s\n' "$a" | sed 's/^/  /'; }
seam1() {
  q "$1" /customersXYZ; q "$1" /customers/; q "$1" /kitchen/anything
  q "$1" /actuator; q "$1" /actuator/health; q "$1" /actuator/prometheus
  q "$1" /customers -I; q "$1" /customers "-H 'Accept: application/xml'"; q "$1" /customers '-X DELETE'; }
seam() {
  echo "before - the previous tree, TiffinBox's own server: the README's run line, port 19331:"
  start "$(at .harness/before 19331 "$R_RUN")"; up; ready 19331
  seam1 19331
  stop 19331 .harness/before
  echo "after - after/, Tomcat: the README's run line, port 19330:"
  start "$(at .harness/after 19330 "$R_RUN")"; up; ready 19330; tline
  seam1 19330
  echo "the two timers now - the scrape's count lines for TiffinBox's paths (Actuator's own left out):"
  timers 19330
  stop 19330 .harness/after; }

# ---- pool: Tomcat's platform threads, idle ---------------------------------------------------------------------------------------
# idle PORT: the harness's /probe/threads - every live platform thread and whether it is a daemon - filtered to Tomcat's (http-nio-,
# container-, Catalina-), its numbers made N and identical lines counted; the JVM's other platform threads counted against a
# bound (their number moves with the virtual-thread scheduler)
idle() { local c="curl -s http://127.0.0.1:$1/probe/threads"; echo "\$ $c"; (eval "$c") > .harness/threads.txt 2>&1 < /dev/null || true
  grep -E '^(http-nio-|container-|Catalina-)' .harness/threads.txt | tnum | group
  echo "  Tomcat's threads: $(grep -cE '^(http-nio-|container-|Catalina-)' .harness/threads.txt || true) · not daemons among them: $(grep -E '^(http-nio-|container-|Catalina-)' .harness/threads.txt | grep -c ' non-daemon$' || true) · the JVM's other platform threads: $( [ "$(grep -cvE '^(http-nio-|container-|Catalina-)' .harness/threads.txt || true)" -lt 40 ] && echo 'fewer than 40' || echo '40 or more'), not shown"; }
pool() {
  echo "Boot's own metadata, in after/'s jar: $(meta .harness/after/$JARP server.tomcat.threads.max) · $(meta .harness/after/$JARP server.tomcat.threads.min-spare) · $(meta .harness/after/$JARP spring.threads.virtual.enabled)"
  echo "A - after/ as built (virtual threads on, application.yaml): the README's class-path line (the jar extracted, change) with the harness joined, port 19332:"
  start "$(hcp .harness/after 19332)"; up; ready 19332; idle 19332; stop 19332 .harness/after
  echo "B - the same with virtual threads off (the README's option):"
  start "$(hcp .harness/after 19332 "$VOFF")"; up; ready 19332; idle 19332; stop 19332 .harness/after
  echo "A' - A again:"
  start "$(hcp .harness/after 19332)"; up; ready 19332; idle 19332; stop 19332 .harness/after; }

# ---- threads: whose thread answers -------------------------------------------------------------------------------------------------
# eight PORT: harness/slow8.sh - eight slow requests at once - each answer's thread, its number made N, identical lines counted;
# the answers and the distinct threads, counted before the mask; then Boot's task executor, asked through the harness
eight() { echo "\$ harness/slow8.sh $1"; harness/slow8.sh "$1" > .harness/slow.txt 2>&1 || true
  tnum < .harness/slow.txt | group
  echo "  answers: $(grep -c ' virtual=' .harness/slow.txt || true) · distinct threads (their numbers, counted before the mask): $(grep ' virtual=' .harness/slow.txt | sort -u | wc -l | tr -d ' ')"
  local c="curl -s http://127.0.0.1:$1/probe/executor"; echo "\$ $c"; (eval "$c") 2>&1 < /dev/null | tnum | sed 's/^/  /'; }
threads() {
  echo "A - after/ as built (virtual threads on, application.yaml): the README's class-path line (the jar extracted, change) with the harness joined, port 19333:"
  start "$(hcp .harness/after 19333)"; up; ready 19333; eight 19333; stop 19333 .harness/after
  echo "B - the README's pool line's two options: virtual threads off, two pool threads at most:"
  start "$(hcp .harness/after 19333 "$POOL2")"; up; ready 19333; eight 19333; stop 19333 .harness/after
  echo "A' - A again:"
  start "$(hcp .harness/after 19333)"; up; ready 19333; eight 19333; stop 19333 .harness/after
  echo "C (labelled) - the AOT jar: after/ built with the profile native (the README's line), run with the README's AOT line - virtual threads off at run time, TiffinBox's line at DEBUG, each line its thread's whole name and the message - port 19334:"
  copy after .harness/aot; pbuild .harness/aot "after/, the profile native (Spring's AOT step)" "$R_PNAT"
  start "$(at .harness/aot 19334 "$R_AOTOFF")"; up; ready 19334
  q 19334 /customers; settle
  echo "  TiffinBox's line for it: $(grep -E '^[^ ]+ GET /customers -> 200$' .harness/run.out | tnum | paste -sd'|' -)"
  stop 19334 .harness/aot; }

# ---- stop: what stops it ------------------------------------------------------------------------------------------------------------
stop_() { local n0
  echo "Boot's own metadata, in after/'s jar: $(meta .harness/after/$JARP server.shutdown) · $(meta .harness/after/$JARP spring.lifecycle.timeout-per-shutdown-phase)"
  echo "after/, the README's run line, port 19330:"
  start "$(at .harness/after 19330 "$R_RUN")"; up; ready 19330; tline
  settle; n0=$(wc -l < .harness/run.out | tr -d ' ')
  stop 19330 .harness/after
  echo "  its log after the POST, from the message on - $(awk -v f="$n0" 'NR > f' .harness/run.out | grep -c . || true) line(s):"
  awk -v f="$n0" 'NR > f' .harness/run.out | sed 's/^.* : /    /'; }

# ---- taken: a port taken, before and after; a bare argument; an address this Mac does not have ------------------------------------
taken() {
  echo "before - the previous tree on port 19331, then the same line again while it holds the port:"
  start "$(at .harness/before 19331 "$R_RUN")"; up; ready 19331
  fails "$(at .harness/before 19331 "$R_RUN")"
  stop 19331 .harness/before
  echo "after - after/ on port 19330, then the same line again while it holds the port:"
  start "$(at .harness/after 19330 "$R_RUN")"; up; ready 19330
  fails "$(at .harness/after 19330 "$R_RUN")"
  stop 19330 .harness/after
  echo "  after/'s spring.factories, the analyzers it names: $(grep '^org.springframework.boot.diagnostics.FailureAnalyzer=' .harness/after/$FAC | sed 's/^[^=]*=//')"
  echo "C (labelled) - after/, a bare argument: the README's old command, its ports 19335 and 19336:"
  fails "$(bareat .harness/after 19335 19336)"; now 19335 19336
  echo "D (labelled) - after/, an address this Mac does not have: the README's line, port 19336:"
  fails "$(at .harness/after 19336 "$R_ADDR")"; now 19336; }

# ---- exercise: the README's commands, exactly as written, then the solution's -------------------------------------------------
block() { awk '/^```bash$/ { if (!d) { f = 1 }; next } f && /^```$/ { f = 0; d = 1 } f' "$1"; }
# xrun 'COMMANDS': run (eval) in the background, bounded (300 s); its output in .harness/x.out; its exit code
xrun() { local i=0; XE=0; (eval "$1") > .harness/x.out 2>&1 < /dev/null & xpid=$!
  while kill -0 "$xpid" 2> /dev/null && [ $i -lt 1200 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$xpid" 2> /dev/null && { kill "$xpid"; die "the exercise's commands still ran after 300 s"; }
  wait "$xpid" || XE=$?; xpid=""; }
exercise() { local setup sol ec
  setup=$(block exercise/README.md); sol=$(block exercise/solution/SOLUTION.md)
  [ -n "$setup" ] && [ -n "$sol" ] || die "exercise/README.md or SOLUTION.md no longer gives its commands"
  [ "$(printf '%s\n' "$sol" | grep -c .)" = 1 ] || die "SOLUTION.md's first bash block must be its one line"
  echo "exercise/README.md's commands, run exactly as written from this folder - $(printf '%s\n' "$setup" | grep -c .) lines:"
  printf '%s\n' "$setup" | sed 's/^/  $ /'
  xrun "$setup"; ec=$XE; [ "$ec" = 0 ] || { tail -20 .harness/x.out >&3; die "the exercise's commands failed: exit $ec"; }
  echo "  exit $ec · what they printed:"; sed 's/^/    /' .harness/x.out
  echo "  the copy's own token in its log: $(raw "$(head -1 .harness/mine/after/$TF)" .harness/mine/run.log) times · listening on 19339 now: $(listeners 19339)"
  echo "the solution's line (exercise/solution/SOLUTION.md), run exactly as written, from this folder:"
  echo "\$ $sol"
  xrun "$sol"; ec=$XE; [ "$ec" = 0 ] || { tail -20 .harness/x.out >&3; die "the solution's line failed: exit $ec"; }
  echo "  exit $ec · what it printed:"; sed 's/^/    /' .harness/x.out
  echo "  listening on 19339 now: $(listeners 19339)"; }

# ---- forms: the native build, then four forms -----------------------------------------------------------------------------------------
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
forms() {
  echo "the native build - after/ copied to .harness/nat with a config tree; the README's two Maven lines, offline; \$GRAALVM_HOME names the GraalVM:"
  copy after .harness/nat
  nbuild .harness/nat; nlines .harness/nat.native.log; nresult .harness/nat.native.log
  echo "  file: $(file -b ".harness/nat/$BIN" | sed 's/ [A-Za-z0-9_]*$//') · the demo token in its bytes: $(raw "$TOKEN" ".harness/nat/$BIN")"
  echo "1 the jar - .harness/after, the README's run line, port 19330:"
  start "$(at .harness/after 19330 "$R_RUN")"; up; ready 19330; tline; seven 19330 .harness/after
  echo "2 the AOT jar - .harness/nat (the profile native's jar), the README's AOT line, port 19334:"
  start "$(at .harness/nat 19334 "$R_AOTRUN")"; up; ready 19334; tline; seven 19334 .harness/nat
  echo "3 the binary - .harness/nat, the README's line, port 19338:"
  start "$(at .harness/nat 19338 "$R_BIN")"; up; ready 19338; tline; seven 19338 .harness/nat
  echo "  the binary at DEBUG - the README's line with Boot's web group and the kitchen at DEBUG, each line its thread's whole name and the message, port 19338:"
  start "$(at .harness/nat 19338 "$R_BINDBG")"; up; ready 19338
  q 19338 /customers; settle
  echo "  its lines for GET /customers that name a handler, and TiffinBox's own: $(grep -E '^[^ ]+ (Mapped to TiffinBox route /customers|GET /customers -> 200)$' .harness/run.out | tnum | paste -sd'|' -)"
  echo "  its WARN lines: $(grep -c 'GC notifications will not be available' .harness/run.out || true) (JvmGcMetrics: GC notifications will not be available - the native binary's known line)"
  stop 19338 .harness/nat
  echo "4 the image - $IMG (the bind capture's), the README's run line with your user, published on 127.0.0.1:19337:"
  dstart "$(drun .harness/after 19337)"; ready 19337 "$BOX"; dbind 19337
  echo "\$ \$CURLSET 19337 .harness/after/$TF"
  "$CURLSET" 19337 ".harness/after/$TF" | grep ' -> ' > .harness/responses.txt || true
  tsmask < .harness/responses.txt > .harness/responses.m.txt
  grep '^POST ' .harness/responses.m.txt | sed 's/^/  /' || echo "  (no POST line)"
  dgone "$BOX"; [ "$(listeners 19337)" = 0 ] || die "something still listens on 19337"
  echo "  exit $LASTE · the seven responses: $(wc -l < .harness/responses.m.txt | tr -d ' ') lines · lines the timestamp mask changed: $(diff .harness/responses.txt .harness/responses.m.txt | grep -c '^<' || true) · md5 $(md5 -q .harness/responses.m.txt)"
  dlog "$BOX"; echo "  its log (docker logs): Boot's first line: $(first .harness/run.out) · the demo token 0 times · X-Shutdown-Token 0 times"
  docker rm "$BOX" > /dev/null
  echo "four forms, one tree: the seven (masked) $(grep -cE '^  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 1 · md5 571faaea42e87e85add8c9548c64c961$' .harness/cap.raw) of 4 times 571faaea42e87e85add8c9548c64c961 · listening on this Mac, loopback only: $(grep -cE '^  listens on: 127\.0\.0\.1:[0-9]+ · loopback only: yes$' .harness/cap.raw) of $(grep -c '^  listens on: ' .harness/cap.raw) runs · the image published on 127.0.0.1 alone: $(grep -cE '^  docker port: 18425/tcp -> 127\.0\.0\.1:19337$' .harness/cap.raw)"; }

cap change change
cap bind bind_
cap seven seven_
cap seam seam
cap pool pool
cap threads threads
cap stop stop_
cap taken taken
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
# THE TOKEN: no capture holds it, raw - counted on each run's own output BEFORE masking - and neither does any log (each counted
# when it was read: fails(), logtok(), dlog()), anything this unit ships for reading, nor the binary this run built
for f in .harness/raw-*; do [ "$(cat "$f")" = 0 ] || die "a capture's raw output held the demo token ($f)"; done
NBIN=0
for f in .r-*.out README.md exercise/README.md exercise/solution/SOLUTION.md receipts.md5 harness/shutdown.sh harness/slow8.sh harness/two.py harness/probe/web/Threads.java harness/probe/web/Converters.java .harness/nat/$BIN; do
  [ -f "$f" ] || continue; case $f in .harness/nat*) NBIN=$((NBIN + 1)) ;; esac
  [ "$(raw "$TOKEN" "$f")" = 0 ] || die "$f holds the demo token, raw"; done
[ "$NBIN" = 1 ] || die "one binary was built, $NBIN were checked"
for f in .r-*.out; do ! grep -qE '/Users/|/private/|/home/|/var/folders/' "$f" || die "$f holds an absolute path"; [ -z "${GRAALVM_HOME:-}" ] || ! grep -qF "$GRAALVM_HOME" "$f" || die "$f holds the GraalVM's folder"; ! grep -qE 'c[0-9]-unit[0-9]|unit ?[0-9]' "$f" || die "$f holds a unit number"; ! grep -qE ' (with PID|started by) ' "$f" || die "$f holds Boot's process line"; ! grep -qE '^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T|"timestamp":"?[0-9]|(exec|handler|task|utility)-[0-9]' "$f" || die "$f holds a log line's time, a timestamp or a thread's number"; ! grep -q "^$(printf '\t')at " "$f" || die "$f shows a stack frame"; ! grep -qE 'sha256:[0-9a-f]{64}' "$f" || [ "$(grep -cE 'sha256:[0-9a-f]{64}' "$f")" = "$(grep -cE 'eclipse-temurin(:25-jre)?@sha256:[0-9a-f]{64}' "$f")" ] || die "$f holds an ID other than the base image's digest"; ! grep -qE ':8080([^0-9]|$)' "$f" || die "$f shows a bind on 8080"; done
for f in receipts.sh README.md exercise/README.md exercise/solution/SOLUTION.md harness/slow8.sh harness/shutdown.sh; do [ -f "$f" ] || continue; ! grep -qE "exposure\.include='?\*" "$f" || die "$f exposes every endpoint (R.42)"; done
for f in receipts.sh README.md exercise/README.md exercise/solution/SOLUTION.md; do [ -f "$f" ] || continue; ! grep -E 'docker run ' "$f" | grep -vE '^#' | grep -E ' -p "?[0-9]+:' > /dev/null || die "$f publishes a port on every address (-p without 127.0.0.1:)"; done
NL=$(cat .r-*.out | grep -cxF "  its log: the demo token 0 times · X-Shutdown-Token 0 times" || true)
echo "  token: 0 raw copies in $(ls .harness/raw-* | wc -l | tr -d ' ') raw capture runs, in $(ls .r-*.out | wc -l | tr -d ' ') captures, in the logs of every start that ended by itself ($FLOGS here), every JVM that served ($LOGS here; the published captures' $NL), every container ($CLOGS here), the READMEs, the harness, the exercise, receipts.md5 and the binary; no absolute path, no GraalVM folder, no unit number, no process line, no log time, no timestamp, no thread number, no stack frame, no ID but the base image's digest, no 8080 in any capture; every docker run publishes on 127.0.0.1 only"

S115='115c36bac276128e245ca57df11c2891'; S571='571faaea42e87e85add8c9548c64c961'
SEVEN0="  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 0 · md5 $S115"
SEVEN1="  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 1 · md5 $S571"
READY='  {"status":"UP"} 200'
STOPPED() { printf '  exit 0 · listening on %s now: 0\n' "$1"; }
LB() { printf '  listens on: 127.0.0.1:%s · loopback only: yes\n' "$1"; }
TC() { printf "  Tomcat's own line: Tomcat started on port %s (http) with context path '/'\n" "$1"; }

# "One dependency adds twelve jars, forty-six to fifty-eight, Jackson three among them. Three files go; one small class comes in."
x change '^  built the previous tree · offline: yes · exit 0$'; x change '^  built after/ · offline: yes · exit 0$'
[ "$(n change '^  (Files|Only in) ')" = 9 ] || die "change: nine paths differ"
x change '^  TiffinBoxServer\.java: 277 -> [0-9]+$'; x change '^  ActuatorRoutes\.java: 196 -> deleted$'; x change '^  PortTakenFailureAnalyzer\.java: 51 -> deleted$'
x change "^  TiffinBoxServer\.java, its lines that are neither comment nor blank: [0-9]+ -> [0-9]+ · naming the JDK's server \(HttpServer, HttpExchange, HttpHandler, com\.sun\.net\.httpserver\): [1-9][0-9]* -> 0 · the servlet API's \(HttpServletRequest, HttpServletResponse\): 0 -> [1-9][0-9]*\$"
x change '^  RouteMapping\.java - new; its lines that are neither comment nor blank: 11$'; x change '^            return new SimpleUrlHandlerMapping\(server\.handlers\(\), 0\);$'
x change '^    >       <artifactId>spring-boot-starter-webmvc</artifactId>$'
x change "^  tiffinbox-web/pom\.xml - <dependency> 7 -> 8 · Boot's plugin's <exclude> 3 -> 1 · the native plugin's <exclusion> 3 -> 1\$"
[ "$(blk change '  tiffinbox-web/src/main/resources/application.yaml - its lines' '  tiffinbox-web/src/main/resources/META-INF' | paste -sd'|' -)" = '    > server:|    >   address: ${tiffinbox.address}|    >   port: ${tiffinbox.port}|    >   threads:|    >     virtual:|    >       enabled: true' ] || die "change: the YAML's six lines"
x change '^    after  org\.springframework\.boot\.diagnostics\.FailureAnalyzer=com\.tiffinbox\.web\.BareArgumentAnalyzer$'
x change "^  BareArgumentAnalyzer\.java - its Javadoc lines that differ: 1 · its lines that are neither comment nor blank, against the previous tree's: the same\$"
x change '^  tiffinbox-core against the previous tree.s \(diff -rq -x target\): 0 files differ$'
[ "$(n change "^  [A-Za-z.]+ against the previous tree's, byte for byte: the same\$")" = 9 ] || die "change: nine files the same"
x change '^the executable jar.s BOOT-INF/lib: 46 jars -> 58 · removed 0 · added 12:$'
x change '^  Jackson 3 \(tools\.jackson\) in the jar: before 0 -> after 2 · Jackson 2 \(jackson-databind 2\.x\): before 1 -> after 1$'
for j in jackson-core-3 jackson-databind-3 spring-webmvc- tomcat-embed-core-; do x change "^    $j"; done
echo "  change: 9 paths; TiffinBoxServer 277 -> N, the JDK's server 0 lines; ActuatorRoutes 196 and the analyzer 51 deleted; RouteMapping 11; the starter in, 2 + 2 Jackson 3 excludes out; the YAML's 6 lines; lib 46 -> 58 (+12, Jackson 3 2)"

# "Tomcat's connector logs a port, never an address. The process says 127.0.0.1. B: no alias, every interface, stopped at once. A again."
x bind "^Boot's own metadata, in after/'s jar: server\.address no default \(spring-boot-web-server-4\.1\.1\.jar\) · server\.port default 8080 \(spring-boot-web-server-4\.1\.1\.jar\)\$"
x bind '^  after/: server: line ([0-9]+) · address: \$\{tiffinbox\.address\} line [0-9]+ · port: \$\{tiffinbox\.port\} line [0-9]+ · the first "---" line [0-9]+ · in the first document: yes$'
x bind '^  the planted copy: .* · in the first document: no$'
BA=$(blk bind 'A - after/' 'B (labelled)'); BB=$(blk bind 'B (labelled)' "A' - A again"); BA2=$(blk bind "A' - A again" 'E (labelled)'); BE=$(blk bind 'E (labelled)' 'the container'); BC=$(blk bind 'the container' '')
for b in "$BA" "$BA2"; do has "$b" "$(LB 19330)" "bind A/A'"; has "$b" "$(TC 19330)" "bind A/A': Tomcat's line"; has "$b" "$(STOPPED 19330)" "bind A/A': exit 0"; done
[ "$(printf '%s\n' "$BA" | grep '^\$ cd')" = "$(printf '%s\n' "$BA2" | grep '^\$ cd')" ] || die "bind: A' is not A's command"
has "$BB" '  listens on: *:19336 127.0.0.1:19335 · loopback only: no' "bind B: every interface"; has "$BB" '  stopped by its pid at once (SIGTERM): exit 143' "bind B: stopped"
has "$BB" '  listening now: 19335 0 · 19336 0' "bind B: both ports free"; has "$BB" "  harness/two.py: tiffinbox-web/pom.xml's lines that differ from the previous tree's: 4 added (the starter) · 8 removed (two Jackson 3 excludes) · application.yaml: the same" "bind B: the copy"
has "$BE" '  listens on: 127.0.0.1:19332 · loopback only: yes' "bind E: Boot's name wins"; has "$BE" '  listening now: 19331 0 · 19332 1' "bind E: the alias's port unbound"
has "$BC" '  its lines that say pull: 0 · its other lines: not shown' "bind: no pull"; has "$BC" '  the image: user ubuntu · entrypoint ["java","-jar","application.jar"] · its environment'"'"'s TIFFINBOX_ADDRESS: 0.0.0.0' "bind: the image"
has "$BC" '  inside the container, listening: [::]:18425' "bind: every interface of the container"; has "$BC" '  docker port: 18425/tcp -> 127.0.0.1:19337' "bind: published on loopback"
has "$BC" '  on this Mac, listening on port 19337: 127.0.0.1:19337' "bind: this Mac's side"; has "$BC" '  0' "bind: docker wait 0"
echo "  bind: metadata no address / 8080; the alias in document 1 (planted: no); A/A' 127.0.0.1:19330; B *:19336, exit 143; E 19332 wins; the container [::]:18425 inside, 127.0.0.1:19337 outside, wait 0"

# "Six lines the same; one differs, GET /nowhere. Static resources, then Boot's error controller. Masked, a new fingerprint."
x seven "^$SEVEN0\$"; x seven "^$SEVEN1\$"; x seven '^  its own line: TiffinBox listening on http://127\.0\.0\.1:19331$'
x seven '^  distinct lines before it: 4 · after it: 2 · '
[ "$(n seven '^  [0-9]+c[0-9]+$')" = 1 ] && x seven '^  5c5$' || die "seven: one line differs, the fifth"
x seven '^  < GET   /nowhere    -> 404 text/html  <h1>404 Not Found</h1>No context found for request$'
x seven '^  > GET   /nowhere    -> 404 application/json  \{"timestamp":"…","status":404,"error":"Not Found","path":"/nowhere"\}$'
[ "$(n seven '^  [<>] ')" = 2 ] || die "seven: two lines in the diff"
x seven "^  at start, TiffinBox's handler mapping: Patterns \[/customers, /dashboard, /kitchen, /revenue, /shutdown\] in 'tiffinBoxRoutes'\$"
x seven '^  converters: [0-9]+ · for application/json: 1$'; x seven '^  org\.springframework\.http\.converter\.json\.JacksonJsonHttpMessageConverter · its mapper: tools\.jackson\.databind\.json\.JsonMapper$'
x seven '^  its lines at DEBUG - 10:$'; x seven 'Mapped to ResourceHttpRequestHandler '; x seven 'NoResourceFoundException'; x seven '"ERROR" dispatch for GET "/error"'; x seven 'BasicErrorController#error'; x seven "Using 'application/json'"
echo "  seven: before 115c36ba..., after 571faaea... (masked, 1 line changed by the mask); the planted mask 4 -> 2; one line differs, 5c5; 10 DEBUG lines: static resources -> /error"

# "The prefix match ends: three paths, two hundred to four oh four. /actuator answers two hundred. HEAD, Accept, DELETE as before. Two timers."
SB=$(blk seam 'before - ' 'after - '); SA=$(blk seam 'after - ' 'the two timers')
for p in customersXYZ customers/ kitchen/anything; do
  has "$(printf '%s\n' "$SB" | grep -A1 "/$p\$")" '  200 application/json' "seam before: /$p"; has "$(printf '%s\n' "$SA" | grep -A1 "/$p\$")" '  404 application/json' "seam after: /$p"; done
has "$(printf '%s\n' "$SB" | grep -A1 '/actuator$')" '  404 application/json' "seam before: /actuator"; has "$(printf '%s\n' "$SA" | grep -A1 '/actuator$')" '  200 application/vnd.spring-boot.actuator.v3+json' "seam after: /actuator"
for b in "$SB" "$SA"; do has "$(printf '%s\n' "$b" | grep -A1 '/actuator/health$')" '  200 application/vnd.spring-boot.actuator.v3+json' "seam: health"; has "$(printf '%s\n' "$b" | grep -A1 '/actuator/prometheus$')" '  200 text/plain;version=0.0.4;charset=utf-8' "seam: the scrape"
  has "$(printf '%s\n' "$b" | grep -A1 ' -I http')" '  405 application/json' "seam: HEAD"; has "$(printf '%s\n' "$b" | grep -A1 'Accept: application/xml')" '  200 application/json' "seam: Accept"; has "$(printf '%s\n' "$b" | grep -A1 'X DELETE')" '  405 application/json' "seam: DELETE"; done
x seam '^  http_server_requests_seconds_count\{error="none",exception="none",method="GET",outcome="CLIENT_ERROR",status="404",uri="/\*\*"\} 3$'
x seam '^  tiffinbox_requests_seconds_count\{route="GET /customers",status="200"\} 1$'; x seam '^  http_server_requests_seconds_count\{.*method="GET",outcome="SUCCESS",status="200",uri="/customers"\} 1$'
echo "  seam: 3 paths 200 -> 404; /actuator 404 -> 200; health and the scrape the same types; HEAD 405, Accept 200 JSON, DELETE 405 both; two timers"

# "Idle, five Tomcat threads, three not daemons, container-0 among them. Virtual threads off: ten exec threads more."
x pool "^Boot's own metadata, in after/'s jar: server\.tomcat\.threads\.max default 200 \(spring-boot-tomcat-4\.1\.1\.jar\) · server\.tomcat\.threads\.min-spare default 10 \(spring-boot-tomcat-4\.1\.1\.jar\) · spring\.threads\.virtual\.enabled default false "
PA=$(blk pool 'A - after/' 'B - the same'); PB=$(blk pool 'B - the same' "A' - A again"); PA2=$(blk pool "A' - A again" '')
for b in "$PA" "$PA2"; do has "$b" "  Tomcat's threads: 5 · not daemons among them: 3 · the JVM's other platform threads: fewer than 40, not shown" "pool A/A'"
  has "$b" '  1 × container-0 non-daemon' "pool A/A': container-0"; has "$b" '  2 × Catalina-utility-N non-daemon' "pool A/A': utility"; ! printf '%s\n' "$b" | grep -q -- '-exec-N' || die "pool A/A': no exec thread"; done
[ "$(printf '%s\n' "$PA" | grep '^\$ cd')" = "$(printf '%s\n' "$PA2" | grep '^\$ cd')" ] || die "pool: A' is not A's command"
has "$PB" '  10 × http-nio-127.0.0.1-19332-exec-N daemon' "pool B: ten exec threads"; has "$PB" "  Tomcat's threads: 15 · not daemons among them: 3 · the JVM's other platform threads: fewer than 40, not shown" "pool B"
echo "  pool: virtual on - 5 Tomcat threads, 3 not daemons (container-0, 2 utility), no exec; off - 15, 10 exec; A' = A"

# "A: eight slow requests, eight virtual threads. B: virtual off, a pool of two - eight answers, two threads. A again. C: the AOT jar still virtual."
TA=$(blk threads 'A - after/' 'B - the README'); TB=$(blk threads 'B - the README' "A' - A again"); TA2=$(blk threads "A' - A again" 'C (labelled)'); TCC=$(blk threads 'C (labelled)' '')
for b in "$TA" "$TA2"; do has "$b" '  8 × tomcat-handler-N virtual=true' "threads A/A'"; has "$b" '  answers: 8 · distinct threads (their numbers, counted before the mask): 8' "threads A/A': eight"; has "$b" '  SimpleAsyncTaskExecutor task-N virtual=true' "threads A/A': Boot's executor"; done
[ "$(printf '%s\n' "$TA" | grep '^\$ cd')" = "$(printf '%s\n' "$TA2" | grep '^\$ cd')" ] || die "threads: A' is not A's command"
has "$TB" '  8 × http-nio-127.0.0.1-19333-exec-N virtual=false' "threads B"; has "$TB" '  answers: 8 · distinct threads (their numbers, counted before the mask): 2' "threads B: two"; has "$TB" '  ThreadPoolTaskExecutor task-N virtual=false' "threads B: the pool executor"
has "$TCC" "  Boot's first line: Starting AOT-processed TiffinBoxServer v1.0.0 using Java 25.0.4.1" "threads C: AOT"; has "$TCC" "  TiffinBox's line for it: tomcat-handler-N GET /customers -> 200" "threads C: still virtual"
printf '%s\n' "$TCC" | grep -q -- '--spring.threads.virtual.enabled=false' || die "threads C: the flag"
echo "  threads: A 8 answers on 8 virtual threads (SimpleAsyncTaskExecutor virtual); B 8 on 2 exec threads (ThreadPoolTaskExecutor); A' = A; C the AOT jar with =false: tomcat-handler"

# "POST /shutdown answers, the context closes, Boot's graceful shutdown - its default - stops Tomcat, exit zero."
x stop "^Boot's own metadata, in after/'s jar: server\.shutdown default graceful \(spring-boot-web-server-4\.1\.1\.jar\) · spring\.lifecycle\.timeout-per-shutdown-phase default 30s "
x stop '^  POST /shutdown -> 200 · curl exit 0$'; x stop "^$(STOPPED 19330)\$"
[ "$(blk stop "  its log after the POST" '' | paste -sd'|' -)" = '    Commencing graceful shutdown. Waiting for active requests to complete|    Graceful shutdown complete' ] || die "stop: the two graceful lines"
x stop '^  its log after the POST, from the message on - 2 line\(s\):$'
echo "  stop: graceful by default (30s a phase); POST -> 200; the two graceful lines; exit 0, 19330 free"

# "Before: TiffinBox's two sentences named the setting. Now Boot's: exit one, no stack trace - its action names no setting."
KB=$(blk taken 'before - ' 'after - '); KA=$(blk taken 'after - ' 'C (labelled)'); KC=$(blk taken 'C (labelled)' 'D (labelled)'); KD=$(blk taken 'D (labelled)' '')
NOF='  its log, read after it exited: APPLICATION FAILED TO START 1 · stack frames 0 · Caused by: 0 · frames folded as common 0 · Tomcat lines '
has "$KB" '  exit 1' "taken before: exit 1"; has "$KB" "${NOF}0" "taken before: no frame"
has "$KB" '  TiffinBox could not listen on 127.0.0.1:19331: something else already listens there.' "taken before: the description"; has "$KB" '  Stop the program on that port, or start TiffinBox on another: --tiffinbox.port=<a free port>.' "taken before: the action names the setting"
has "$KA" '  exit 1' "taken after: exit 1"; has "$KA" "${NOF}1" "taken after: no frame"; has "$KA" '  Web server failed to start. Port 19330 was already in use.' "taken after: Boot's description"
has "$KA" "  Identify and stop the process that's listening on port 19330 or configure this application to listen on another port." "taken after: Boot's action"
printf '%s\n' "$KA" | grep -q 'tiffinbox\.port=<' && die "taken after: Boot's action names no setting"
has "$KA" "  after/'s spring.factories, the analyzers it names: com.tiffinbox.web.BareArgumentAnalyzer" "taken: one analyzer left"
has "$KA" '  WARN ConfigServletWebServerApplicationContext: Exception encountered during context initialization - cancelling refresh attempt: org.springframework.context.ApplicationContextException …' "taken after: a servlet web application"
has "$KC" '  exit 2' "taken C: exit 2"; has "$KC" "${NOF}0" "taken C: before Tomcat"; has "$KC" '  its log: the banner'"'"'s :: Spring Boot :: line 0' "taken C: before the banner"; has "$KC" '  listening now: 19335 0 · 19336 0' "taken C: never bound"
has "$KC" '  TiffinBox reads no bare arguments: argument 1 of 1 is 19336.' "taken C: the refusal"
has "$KD" '  exit 1' "taken D: exit 1"; has "$KD" '  Caused by: org.springframework.boot.web.server.WebServerException: Unable to start embedded Tomcat server' "taken D: Tomcat's"; has "$KD" "  Caused by: java.net.BindException: Can't assign requested address" "taken D: the bind"
printf '%s\n' "$KD" | grep -qE '^  its log, read after it exited: APPLICATION FAILED TO START 0 · stack frames [1-9][0-9]* ' || die "taken D: the trace, no analysis"
echo "  taken: before TiffinBox's two sentences (--tiffinbox.port named); after Boot's, exit 1, 0 frames, no setting named; one analyzer left; C a bare number, exit 2 before the banner; D 192.0.2.1: Unable to start embedded Tomcat server"

# the exercise's end state: the line exercise/README.md calls "Done" is a line of this capture, after the solution's line - and of
# SOLUTION.md's measured run; the README's own line, as shipped, prints 8
XS=$(blk exercise "exercise/README.md's commands" "the solution's line"); XE=$(blk exercise "the solution's line" '')
l='threads that answered: 2'
has "$XE" "    $l" "exercise: the solution"; has "$XS" '    threads that answered: 8' "exercise: as shipped"
awk '/^\*\*Done\*\*/ { f = 1 } f' exercise/README.md | grep -qxF -- "$l" || die "exercise/README.md: Done names no such line"
grep -qxF -- "$l" exercise/solution/SOLUTION.md || die "SOLUTION.md: the measured run shows no such line"
x exercise '^  the copy.s own token in its log: 0 times · listening on 19339 now: 0$'; x exercise '^  listening on 19339 now: 0$'
echo "  exercise: the README as written -> 8; the solution's line -> 2"

# "Every form still serves: the jar, the AOT jar, the binary, the image - loopback, the same masked seven, exit zero."
x forms '^  exit 0 · BUILD SUCCESS · stages it printed: 8 of the 8 it announces · its duration, against the bound: under 20 minutes · its lines that say the metadata repository was downloaded over http, or failed to: 0 · offline: yes$'
x forms '^  file: Mach-O 64-bit executable · the demo token in its bytes: 0$'
x forms "^four forms, one tree: the seven \(masked\) 4 of 4 times $S571 · listening on this Mac, loopback only: 4 of 4 runs · the image published on 127\.0\.0\.1 alone: 1\$"
for t in '1 the jar' '2 the AOT jar' '3 the binary' '4 the image'; do x forms "^$t - "; done
x forms "^  Boot's first line: Starting AOT-processed TiffinBoxServer v1\.0\.0 using Java 25\.0\.4\.1\$"; x forms "^  Boot's first line: Starting AOT-processed TiffinBoxServer using Java 25\.0\.4\.1\$"
x forms '^  its lines for GET /customers that name a handler, and TiffinBox.s own: tomcat-handler-N Mapped to TiffinBox route /customers\|tomcat-handler-N GET /customers -> 200$'
x forms '^  inside the container, listening: \[::\]:18425$'; x forms '^  docker port: 18425/tcp -> 127\.0\.0\.1:19337$'
echo "  forms: 8 of 8 stages, offline, Mach-O, 0 tokens; the jar, the AOT jar, the binary, the image: 4 of 4 571faaea..., loopback; the binary's handler named, on a virtual thread"

cmp -s after/README.md ../c6-tiffinbox/README.md || echo "  (after/README.md and ../c6-tiffinbox/README.md differ - the anchor has moved past this unit's after/)" >&3
[ -z "$unpub" ] || die "no published hash for:$unpub - check the captures, then copy the md5s above into receipts.md5 and run again"
echo "c6-unit04: every capture 3/3 and = published; every spoken number asserted; 0 raw demo tokens in every capture, every log, the container's log and the binary; nothing of this run left on Docker"
