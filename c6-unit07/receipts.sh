#!/bin/bash
XPATH=$PATH                                           # the PATH you started this with: the exercise's own shell gets it
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25.0.4.1 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# GRAALVM_HOME names a GraalVM JDK 25 (README.md, "The GraalVM"): the native build reads it. Without it, this script makes every
# capture that needs no GraalVM, filling .m2-demo on the way, then stops before the native build.
# Course 6 · @PathVariable, @RequestParam and Defaults - this unit's receipts. The anchor changes: TiffinBox's routes start taking
# values from the request as method parameters - GET /customers/{name} (a path variable; a name nobody has is Spring's
# ResponseStatusException, 404), GET /customers?mealType= (a request parameter, optional) and POST /shutdown's token (a header) -
# CustomerRepository gains findByName, and application.yaml holds at INFO, Boot's default level, the two loggers that print the token at TRACE. Ten captures, each run three times and hashed; cap() DIES when a hash differs from
# receipts.md5; every number the video says is asserted at the bottom by a check that can fail; the demo token is masked (gsub),
# and the checks count 0 raw copies of it in every capture, in the log of every run - every failed start's and the container's
# included - in every file this unit ships, in the binary and in the image's layers.
#   change     the previous tree against after/: the files that differ, the two Java files' lines, their code lines' diff,
#              application.yaml's lines and where its two new loggers sit, the jar's lib/, the files left alone; one customer by name and the vegan ones, asked of each tree; the routes Spring
#              MVC registers at start (TRACE), and the routing table (mappings exposed for one run): whole, and two rows
#   resolvers  who fills a route's parameters: the argument resolvers Spring MVC's adapter holds, and the one that takes each of
#              TiffinBox's parameters (the harness's Resolvers); by name - Boot's parent compiles with -parameters, javap reads the
#              names; C (labelled) a harness route compiled without the flag: a clean start, then a 500
#   path       path variables: a name, a name nobody has (and /nowhere beside it), a dot, an encoded space, an encoded slash
#   params     request parameters: TiffinBox's meal type - a name, a name in the wrong case, empty, twice; then the harness's
#              routes: required, a default value, Optional, a list
#   others     a header, a cookie, a matrix variable, a request attribute (the harness's Bind); the annotations a parameter can
#              carry, read off spring-web's jar, and how many this unit's routes use; and spring-beans' @Value, which binds one too
#   token      A/B/A': POST /shutdown's header, required = false (after/: the method's 403) against required = true (a copy:
#              Spring MVC's 400) - no header, a misspelt one, the right one
#   trace      A/B/A': the two loggers that print the token at TRACE, held at INFO in application.yaml's first document - every
#              logger at TRACE (the README's line), then Boot's web group at TRACE, and the seven, with a second fake token of its
#              own: the previous tree; A after/; B a copy of after/ without those lines; A' = A - how many times each log holds
#              the token, and which logger wrote it
#   timer      Boot's timer for the new route: two names, a name nobody has, the README's /customers/7, a meal type and a
#              wrong one, an encoded slash - the series, by pattern
#   exercise   exercise/README.md's commands, then exercise/solution/SOLUTION.md's, read from the files and run as written, one after
#              the other in ONE shell a viewer could have: env -i, /bin/bash, started in this folder
#   forms      the native build of after/ and what Spring's AOT step registered, then four forms - the jar, the AOT jar, the binary,
#              the image: each one's address, the seven (masked), exit 0; then, on a second start of each, the new routes
# "The previous tree" is ../c6-unit06/after (the anchor before this change: the request-mapping lesson's frozen tree), COPIED
# under .harness/before; after/ is this unit's frozen copy of ../c6-tiffinbox after the change, COPIED under .harness/after. This
# script never writes into another unit's folder, and never builds a frozen tree in place. Every run of TiffinBox starts in a
# folder under .harness/ that holds a config tree with a fake token (secrets/), as the README asks - the container's too, mounted
# read-only. Commands are printed exactly as they run: each goes through eval. "$CURLSET" is the comparison set since the
# secrets lesson (../c5-unit11/curlset.sh: the seven requests, POST /shutdown with the token's header read from the file). "$M2"
# is this unit's own repository, .m2-demo. The harness - harness/probe/web/Resolvers.java and Bind.java (compiled with
# -parameters), harness/bare/probe/bare/NoParams.java (compiled without it, on purpose) - the course's, never TiffinBox's:
# outside com.tiffinbox, joined by --spring.main.sources on the extracted jar's class path; harness/table.py (reads one Actuator
# answer) and harness/shutdown.sh (POST /shutdown, the token read from its file) - is named on every capture that uses it.
# Every run passes options only.
# The network: every Maven build runs offline (-o) against .m2-demo and says so ("offline: yes"); a build that cannot resolve an
# artifact offline goes to Maven Central once, and says that ("offline: no - ..."). GraalVM's native plugin reads its metadata
# repository (a zip) from .m2-demo - and when the zip is not there it downloads it from GitHub, even under -o: so a native-profile
# build without the zip goes to Maven Central for it at once, and every native build's log is searched for the plugin's own
# download line - found, the run stops. Docker: no pull - eclipse-temurin:25-jre must already be on the daemon, and docker build
# prints how many of its lines say pull. At run time nothing leaves 127.0.0.1: TiffinBox listens there (in a container, on the
# container's own addresses, published on the host's 127.0.0.1 alone), every request goes there, and Logback writes to the
# terminal only.
# Masks and filters (README.md declares each; awk sub/gsub only): the demo token becomes "[masked: the N-character token]" (N its
# own length), the trace capture's own fake token "[masked: the trace run's token]"; the GraalVM's folder "$GRAALVM_HOME"; this
# folder's absolute path "…", the folder above it "…/..", the home folder "~"; your user name "<user>" - in every line of every
# capture. Spring's error timestamp becomes "…" (both forms: an ISO-8601 string, epoch milliseconds) in the seven and wherever
# Spring's error body is printed; an identity hash after "@" becomes "…"; a thread's number becomes N (tomcat-handler-N); where a
# native-image warning names the file it read an option from, the file's URL - or "null", which it prints when the path holds a
# space - becomes "…". Lines a log prints in an order that moves from run to run are sorted, and say so: the routes inside one of
# Spring MVC's registration blocks, the routing table's rows with details. A failed start's log is read after it exited, never
# printed whole. A run's log lines are printed from their logger on (no time, no process id); Boot's first line is cut before
# " with PID". Long logs go through a declared filter, and what it cuts is counted or bounded. No image, container or ID is
# printed but the base image's digest. No duration is captured: the native build's seconds, and the 20-minute bound, go to
# the terminal only.
# Ports (brief ⚑1, 19360-19369): after/'s jar 19360 · the previous tree 19361 · after/ with the harness joined 19362 · the harness
# compiled without -parameters 19363 · the AOT jar 19364 · the copy whose header is required 19365 · the image 19367 · the binary
# 19368 · the exercise 19369 · the copy without the two pinned loggers 19366. 18425 (TiffinBox's default) and 8080 (Tomcat's) are checked free too, and never
# bound on this machine (18425 only inside a container).
# Docker names (no unit number): the image tiffinbox-bind:1.0.0 and the container tiffinbox-bind. Each is checked absent before the
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
IMG=tiffinbox-bind:1.0.0; BOX=tiffinbox-bind
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
PREV=../c6-unit06/after                              # the previous tree: the anchor before this change - read, copied
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
# The trace capture's own token, as fake: the only one a log here is MEANT to hold - trace measures which loggers write it - so
# it is never the demo token, it lives in its own two config trees, and both logs are emptied once counted.
TTOK=trace-only-demo-token-fake
[ ${#TTOK} = 26 ] && [ "$TTOK" != "$TOKEN" ] || die "the trace capture's token must be 26 characters, and not the demo token"
CURLSET=../c5-unit11/curlset.sh                      # the comparison set: the seven requests, POST /shutdown with the header
[ -f "$CURLSET" ] || die "$CURLSET is missing"
for f in harness/shutdown.sh harness/table.py harness/probe/web/Resolvers.java harness/probe/web/Bind.java harness/bare/probe/bare/NoParams.java exercise/README.md exercise/solution/SOLUTION.md README.md; do [ -f "$f" ] || die "$f is missing"; done

# The ports and the Docker names, BEFORE anything is wiped (a survivor of an interrupted run answers POST /shutdown only with its
# token, which lives in .harness/ - so the message names the process to kill).
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
for p in 18425 8080 19360 19361 19362 19363 19364 19365 19366 19367 19368 19369; do
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
# the request-mapping lesson's two lines (its section, above this unit's): Spring MVC's mapping logger at TRACE, the kitchen at
# DEBUG; the routing table exposed for one run
L_SCAN=$(readme "$J --logging.level.kitchen=debug --logging.level.org.springframework.web.servlet.mvc.method.annotation.RequestMappingHandlerMapping=trace")
L_EXPO=$(readme "$J --management.endpoints.web.exposure.include=health,prometheus,mappings")
# this unit's two lines in the anchor's README: one customer by name; the vegan ones
R_ONE=$(readme "curl -s -w ' %{http_code}\n' http://127.0.0.1:18431/customers/Ravi")
R_MEAL=$(readme "curl -s -w ' %{http_code}\n' 'http://127.0.0.1:18431/customers?mealType=VEGAN'")
# Course 5's lines, still in the anchor's README: a path under /customers and a POST /shutdown without the header (the metrics
# lesson's), and every logger at TRACE (the logging lesson's "At TRACE, still no token")
R_C7=$(readme "curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:18431/customers/7")
R_POST=$(readme "curl -s -w ' %{http_code}\n' -X POST http://127.0.0.1:18431/shutdown")
R_TRACE=$(readme "$J --logging.level.root=trace")
EXPOF=${L_EXPO#"$J "}
[ "$EXPOF" = '--management.endpoints.web.exposure.include=health,prometheus,mappings' ] && [ "${R_TRACE#"$J "}" = '--logging.level.root=trace' ] || die "the README's options"
# This unit's own lines (README.md, "The commands this unit adds") - each asserted to be exactly that: javap on a tree's extracted
# jar and on the harness's no-parameters class, javac's line for that class (no -parameters) and the class-path line with it
# joined (resolvers C), the routing table read whole and two rows of it (change), Tomcat's own 400 page's title (path), and
# Boot's web group at TRACE (trace)
mine() { grep -m1 -xF -- "$1" README.md > /dev/null || die "README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
L_JAVAP=$(mine 'javap -v -p -cp tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar com.tiffinbox.web.TiffinBoxServer')
L_JAVAP0=$(mine 'javap -v -p -cp ../hc0 probe.bare.NoParams')
L_BARE=$(mine 'java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc0" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431 --spring.main.sources=probe.bare.NoParams')
L_TABLE=$(mine 'curl -s http://127.0.0.1:18431/actuator/mappings | python3 harness/table.py')
L_ROW=$(mine "curl -s http://127.0.0.1:18431/actuator/mappings | python3 harness/table.py row '/customers/{name}'")
L_ROWC=$(mine 'curl -s http://127.0.0.1:18431/actuator/mappings | python3 harness/table.py row /customers')
L_JAVAC0=$(mine 'javac -d .harness/hc0 -cp ".harness/after/tiffinbox-web/target/extracted/lib/*" harness/bare/probe/bare/NoParams.java')
L_WTRACE=$(mine "$J --logging.level.web=trace")
[ "${L_WTRACE#"$J "}" = '--logging.level.web=trace' ] || die "this unit's README: the web group's option"
L_TITLE=$(mine "curl -s http://127.0.0.1:18431/customers/a%2Fb | grep -o '<title>[^<]*</title>'")
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
# bc PORT PATH ['CURL OPTIONS']: this unit's one-customer line (the anchor's README) - the body and the status - the same way
bc() { local c=${R_ONE% http://*}; printf '%s%s %s\n' "$c" "${3:+ $3}" "$(qurl "$1" "$2")"; }
# exe 'COMMAND': the command with "exec" after its "cd DIR && " and any NAME=value before the program - so $pid is the program's
exe() { printf '%s\n' "$1" | sed -E 's/&& (([A-Z_]+=[^ ]* )*)/\&\& \1exec /'; }
# The docker lines, as this script runs them: the README's build line with plain progress and this script's own tag; its run line
# with this script's own name and tag, the port published on 127.0.0.1 made PORT, and your user and group added - the config tree
# is yours, mode 0600 (R.74). undock() takes those changes back out, and must give the README's lines again.
UARG='--user "$(id -u):$(id -g)"'
dbuild() { local c=${R_DBUILD/docker build -t tiffinbox-docker:1.0.0 /docker build --progress=plain -t $IMG }; printf 'cd %s && %s\n' "$1" "$c"; }
drun() { local c=${R_DRUN/--name tiffinbox /--name $BOX $UARG }; c=${c/127.0.0.1:18431:18425/127.0.0.1:$2:18425}; c=${c/% tiffinbox-docker:1.0.0/ $IMG}; printf 'cd %s && %s\n' "$1" "$c"; }
undock() { local c=${1#cd * && }; c=${c/--progress=plain /}; c=${c/" $UARG"/}; c=${c//$IMG/tiffinbox-docker:1.0.0}; c=${c/--name $BOX /--name tiffinbox }; c=${c/127.0.0.1:1936?:18425/127.0.0.1:18431:18425}; printf '%s\n' "$c"; }
[ "$(undock "$(dbuild .harness/x)")" = "$R_DBUILD" ] || die "not the README's build line with the declared changes: $(dbuild .harness/x)"
[ "$(undock "$(drun .harness/x 19367)")" = "$R_DRUN" ] || die "not the README's run line with the declared changes: $(drun .harness/x 19367)"
C_PRE=$(off .harness/pre "$R_INSTALL" install)
for c in "$C_PRE" "$(off .harness/x "$R_PLAIN" package)" "$(off .harness/x "$R_PNAT" package)" "$(off .harness/x "$R_NATIVE")"; do
  r=$(dev "$c"); [ "$r" = "$R_PLAIN" ] || [ "$r" = "$R_PNAT" ] || [ "$r" = "$R_INSTALL" ] || [ "$r" = "$R_NATIVE" ] || die "not a README line with the offline changes: $c"; done
[ "$(exe "$(at .harness/x 19360 "$R_RUN")")" = 'cd .harness/x && exec java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19360' ] || die "exe()"
[ "$(hcp .harness/x 19362 probe.web.Bind)" = 'cd .harness/x && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19362 --spring.main.sources=probe.web.Bind' ] || die "hcp()"
[ "$(qc 19360 /customersXYZ)" = "curl -s -o /dev/null -w '%{http_code} %{content_type}\n' http://127.0.0.1:19360/customersXYZ" ] && [ "$(bc 19362 '/customers?mealType=VEG')" = "curl -s -w ' %{http_code}\n' 'http://127.0.0.1:19362/customers?mealType=VEG'" ] && [ "$(bc 19362 /probe/bind/header "-H 'X-Meal: lunch'")" = "curl -s -w ' %{http_code}\n' -H 'X-Meal: lunch' http://127.0.0.1:19362/probe/bind/header" ] && [ "$(bc 19360 /customers/Ravi)" = "$(url "$R_ONE" 19360)" ] && [ "$(bc 19360 '/customers?mealType=VEGAN')" = "$(url "$R_MEAL" 19360)" ] || die "qc(), bc()"
echo "  the commands: after/README.md gives all 21 lines this script runs or derives from; README.md the 9 this unit adds"

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
  [ "$(raw "$TTOK" .harness/run.out .harness/run.err)" = 0 ] || die "a log held the trace capture's token outside trace"
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
now() { local p o=""; for p in "$@"; do o="$o${o:+ · }$p $(listeners "$p")"; done; echo "  listening now: $o"; }
# tnum: a thread's number becomes N - Tomcat's tomcat-handler-N (README.md, Masks)
tnum() { awk '{ gsub(/tomcat-handler-[0-9]+/, "tomcat-handler-N"); print }'; }
mask() { awk -v t="$TOKEN" -v tt="$TTOK" -v g="${GRAALVM_HOME:-}" -v u="$U" -v up="$UP" -v hm="$HOME" -v me="$ME" -v tl="${#TOKEN}" '
  function lit(x) { gsub(/[][\\.^$*+?(){}|\/]/, "\\\\&", x); return x }
  function enc(x) { gsub(/ /, "%20", x); return x }
  BEGIN { T = lit(t); TT = lit(tt); G = lit(g); GE = lit(enc(g)); P = lit(u); Q = lit(up); H = lit(hm); PE = lit(enc(u)); QE = lit(enc(up)); M = "(^|[^A-Za-z0-9_])" lit(me) "([^A-Za-z0-9_]|$)" }
  { gsub(T, "[masked: the " tl "-character token]"); gsub(TT, "[masked: the trace run'"'"'s token]"); if (g != "") { gsub(G, "$GRAALVM_HOME"); gsub(GE, "$GRAALVM_HOME") }; gsub(P, "…"); gsub(PE, "…")
    gsub(Q, "…/.."); gsub(QE, "…/.."); gsub(H, "~")
    while (match($0, M)) { pre = substr($0, 1, RSTART - 1); s = substr($0, RSTART, RLENGTH); post = substr($0, RSTART + RLENGTH)
      sub(lit(me), "<user>", s); $0 = pre s post }
    print }'; }

unpub=""
cap() { local nm=$1 h pub i; shift
  for i in 1 2 3; do "$@" > .harness/cap.raw 2>&1 || true; [ -z "$pid" ] && [ -z "$fpid" ] && [ -z "$xpid" ] || die "$nm left a process running"
    [ -z "$(docker ps -aq --filter "name=^$BOX\$")" ] || die "$nm left a container"
    echo "$(raw "$TOKEN" .harness/cap.raw) $(raw "$TTOK" .harness/cap.raw)" > ".harness/raw-$nm.$i"; mask < .harness/cap.raw > ".r-$nm.$i"; done
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
# mparams 'JAVAP LINE' DIR METHOD...: javap -v -p, run from DIR as printed - how many of the class's methods carry a
# MethodParameters attribute (the names javac -parameters writes), and the names each METHOD's attribute holds
mparams() { local c="cd $2 && $1"; local d=$2; shift 2; echo "\$ $c"; (eval "$c") > .harness/javap.txt 2>&1 < /dev/null || { cat .harness/javap.txt >&3; die "javap failed: $c"; }
  awk -v want="$*" '
    BEGIN { n = split(want, w, " ") }
    /^  [^ ].*\(.*\).*;$/ { m = $0; sub(/^.* /, "", m); h = $0; if (match(h, /[A-Za-z_$][A-Za-z0-9_$]*\([^)]*\)/)) m = substr(h, RSTART, RLENGTH); seen[m] = 1; inmp = 0; next }
    /^    MethodParameters:$/ { mp++; inmp = 1; nm[m] = ""; has[m] = 1; next }
    inmp && /^      Name +Flags$/ { next }
    inmp && /^      [^ ]/ { nm[m] = nm[m] (nm[m] == "" ? "" : " ") $1; next }
    inmp { inmp = 0 }
    END { o = "  its methods with a MethodParameters attribute: " (mp + 0)
      for (i = 1; i <= n; i++) { k = ""; for (x in seen) if (index(x, w[i] "(") == 1) k = x
        o = o " · " (k == "" ? w[i] "(…)" : k) ": " (k != "" && has[k] ? (nm[k] == "" ? "no names" : nm[k]) : "no names") }
      print o }' .harness/javap.txt; }

# ---- change: the previous tree against after/ ---------------------------------------------------------------------------------
# The lines of TiffinBoxServer.java's code (neither comment nor blank, nor an import) that name what the change moves, counted
# before and after: Spring MVC's binding annotations, the servlet request (the old way to the header), Spring's status exception,
# the routes
BINDRE='@(PathVariable|RequestParam|RequestHeader)([( ]|$)'
SERVRE='HttpServletRequest|getHeader\('
MAPRE='@(GetMapping|PostMapping)\('
change() { local f n
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
  echo "the two Java files, their lines (wc -l), before -> after:"
  for f in "$W/TiffinBoxServer.java" "$CORE/CustomerRepository.java"; do echo "  ${f##*/}: $(lines ".harness/before/$f") -> $(lines ".harness/after/$f")"; done
  code ".harness/before/$W/TiffinBoxServer.java" > .harness/fb.txt; code ".harness/after/$W/TiffinBoxServer.java" > .harness/fa.txt
  code ".harness/before/$CORE/CustomerRepository.java" > .harness/rb.txt; code ".harness/after/$CORE/CustomerRepository.java" > .harness/ra.txt
  grep -v '^import ' .harness/fb.txt > .harness/fbi.txt || true; grep -v '^import ' .harness/fa.txt > .harness/fai.txt || true
  echo "  TiffinBoxServer.java, its lines that are neither comment nor blank: $(wc -l < .harness/fb.txt | tr -d ' ') -> $(wc -l < .harness/fa.txt | tr -d ' '), of them - imports left out - naming:"
  echo "    a value from the request, by Spring MVC's annotation (@PathVariable, @RequestParam, @RequestHeader): $(grep -cE "$BINDRE" .harness/fbi.txt || true) -> $(grep -cE "$BINDRE" .harness/fai.txt || true) · the servlet request (HttpServletRequest, getHeader): $(grep -cE "$SERVRE" .harness/fbi.txt || true) -> $(grep -cE "$SERVRE" .harness/fai.txt || true)"
  echo "    Spring's status exception (ResponseStatusException): $(grep -c 'ResponseStatusException' .harness/fbi.txt || true) -> $(grep -c 'ResponseStatusException' .harness/fai.txt || true) · a route (@GetMapping, @PostMapping): $(grep -cE "$MAPRE" .harness/fbi.txt || true) -> $(grep -cE "$MAPRE" .harness/fai.txt || true)"
  diff -U0 .harness/fb.txt .harness/fa.txt | tail -n +3 > .harness/code.diff || true
  echo "  its code lines' diff (diff -U0 of the lines above, its file names cut): $(grep -c '^@@ ' .harness/code.diff || true) hunks, $(grep -c '^-' .harness/code.diff || true) lines out, $(grep -c '^+' .harness/code.diff || true) in - whole:"
  sed 's/^/    /' .harness/code.diff
  diff -U0 .harness/rb.txt .harness/ra.txt | tail -n +3 > .harness/core.diff || true
  echo "  CustomerRepository.java, its code lines: $(wc -l < .harness/rb.txt | tr -d ' ') -> $(wc -l < .harness/ra.txt | tr -d ' ') - its code lines' diff, the same way: $(grep -c '^@@ ' .harness/core.diff || true) hunks, $(grep -c '^-' .harness/core.diff || true) lines out, $(grep -c '^+' .harness/core.diff || true) in - whole:"
  sed 's/^/    /' .harness/core.diff
  code ".harness/before/$YAML" > .harness/yb.txt; code ".harness/after/$YAML" > .harness/ya.txt
  diff -U1 .harness/yb.txt .harness/ya.txt | tail -n +3 > .harness/y.diff || true
  echo "  application.yaml - its lines that are neither comment nor blank: $(wc -l < .harness/yb.txt | tr -d ' ') -> $(wc -l < .harness/ya.txt | tr -d ' ') · their diff (diff -U1, its file names cut) - hunks: $(grep -c '^@@ ' .harness/y.diff || true) · lines out: $(grep -c '^-' .harness/y.diff || true) · in: $(grep -c '^+' .harness/y.diff || true) - whole:"
  sed 's/^/    /' .harness/y.diff
  echo "  its comment lines: $(grep -cE '^[[:space:]]*#' ".harness/before/$YAML") -> $(grep -cE '^[[:space:]]*#' ".harness/after/$YAML") · where the two loggers sit: $(pplace ".harness/after/$YAML")"
  libs .harness/before/$JARP > .harness/lb.txt; libs .harness/after/$JARP > .harness/la.txt
  echo "the executable jar's BOOT-INF/lib: $(wc -l < .harness/lb.txt | tr -d ' ') jars -> $(wc -l < .harness/la.txt | tr -d ' ') · removed $(comm -23 .harness/lb.txt .harness/la.txt | wc -l | tr -d ' ') · added $(comm -13 .harness/lb.txt .harness/la.txt | wc -l | tr -d ' ')"
  diff .harness/before/README.md .harness/after/README.md > .harness/file.diff || true
  echo "  README.md - the anchor's README: lines added $(grep -c '^> ' .harness/file.diff || true), removed $(grep -c '^< ' .harness/file.diff || true) - its new section and the history notes the change made false (not shown)"
  n=0; for f in pom.xml tiffinbox-web/pom.xml tiffinbox-core/pom.xml Dockerfile compose.yaml .dockerignore $FAC $W/TiffinBoxApp.java $W/BareArgumentGuard.java $W/BareArgumentAnalyzer.java $W/KitchenHealthIndicator.java $W/KitchenMetrics.java $CORE/Customer.java $CORE/MealType.java $CORE/Database.java $CORE/Dashboard.java $CORE/OrderQueue.java $CORE/TiffinBoxProperties.java; do
    cmp -s ".harness/before/$f" ".harness/after/$f" && n=$((n + 1)) || echo "  $f against the previous tree's: different"; done
  echo "  the other files, against the previous tree's, byte for byte the same: $n of 18 (the POMs, the Dockerfile, compose.yaml, .dockerignore, spring.factories, the other five web classes, the other six core classes)"
  echo "what a request can ask - one customer by name, the vegan ones (this unit's two lines in the anchor's README) - before: the previous tree, the README's run line, port 19361:"
  start "$(at .harness/before 19361 "$R_RUN")"; up 19361; ready 19361
  ask 19361 /customers/Ravi; ask 19361 '/customers?mealType=VEGAN'
  stop 19361 .harness/before
  echo "after - after/, the request-mapping lesson's line - Spring MVC's mapping logger at TRACE, the kitchen at DEBUG - port 19360:"
  start "$(at .harness/after 19360 "$L_SCAN")"; up 19360; ready 19360; reg
  ask 19360 /customers/Ravi; ask 19360 '/customers?mealType=VEGAN'
  stop 19360 .harness/after
  echo "the routing table - after/, mappings exposed for one run (the request-mapping lesson's line), port 19360:"
  start "$(at .harness/after 19360 "$L_EXPO")"; up 19360; ready 19360
  c=$(url "$L_TABLE" 19360); echo "\$ $c"; (eval "$c") 2>&1 < /dev/null
  c=$(url "$L_ROW" 19360); echo "\$ $c"; (eval "$c") 2>&1 < /dev/null
  c=$(url "$L_ROWC" 19360); echo "\$ $c"; (eval "$c") 2>&1 < /dev/null
  stop 19360 .harness/after; }
# pplace FILE: where the two pinned loggers sit in an application.yaml - the top-level key their block is under, the lines'
# numbers, the first "---" line, and whether both are in the first document (the one every profile reads)
pplace() { awk '
  /^[a-z][a-z-]*:/ && !l { top = $0; topn = NR }
  /^  level:$/ && !l { l = NR; under = top; un = topn }
  /^    org\.apache\.coyote\.http11\.Http11InputBuffer: info$/ && l && !a { a = NR }
  /^    org\.springframework\.web\.method\.HandlerMethod: info$/ && l && !h { h = NR }
  /^---$/ && !x { x = NR }
  END { ok = (l && a == l + 1 && h == a + 1 && x && h < x && under == "logging:") ? "yes" : "no"
        printf "level: line %d, under %s (line %d) · org.apache.coyote.http11.Http11InputBuffer: info line %d · org.springframework.web.method.HandlerMethod: info line %d · the first \"---\" line %d · in the first document: %s\n", l, under, un, a, h, x, ok }' "$1"; }
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

# ---- resolvers: who fills a route's parameters ------------------------------------------------------------------------------
resolvers() { local c n0
  echo "who fills a route's parameters - after/ on the README's class-path line with the harness's Resolvers joined, port 19362:"
  start "$(hcp .harness/after 19362 probe.web.Resolvers)"; up 19362; ready 19362
  c=$(bc 19362 /probe/resolvers); echo "\$ $c"; (eval "$c") 2>&1 < /dev/null | sed 's/^/  /'
  stop 19362 .harness/after
  echo "by name - Boot's parent POM (the parent TiffinBox's POM inherits) sets the compiler's flag; javap reads what javac wrote into the class:"
  echo "  \$M2/org/springframework/boot/spring-boot-starter-parent/4.1.1/spring-boot-starter-parent-4.1.1.pom, its compiler plugin's configuration: $(grep -n '<parameters>true</parameters>' "$PARENT" | sed 's/^\([0-9]*\): */line \1: /')"
  mparams "$L_JAVAP" .harness/after customer customers shutdown
  echo "C (labelled) - a harness route compiled WITHOUT -parameters (the harness's NoParams, /probe/bare/{name}), joined to after/ on the class-path line (this unit's), port 19363:"
  c=$L_JAVAC0
  echo "\$ $c"; rm -rf .harness/hc0; (eval "$c") > .harness/javac0.log 2>&1 < /dev/null || { cat .harness/javac0.log >&3; die "NoParams did not compile"; }
  echo "  exit 0"
  mparams "$L_JAVAP0" .harness/after name
  start "$(at .harness/after 19363 "$L_BARE")"; up 19363; ready 19363; tline
  echo "  WARN and ERROR lines in its log, from the start: $(logl 0 | grep -c . || true)"
  n0=$(mark); c=$(bc 19363 /probe/bare/Ravi); echo "\$ $c"; (eval "$c") 2>&1 < /dev/null | tsmask | sed 's/^/  /'; settle
  echo "  its lines at WARN and ERROR: $(logl "$n0" | grep -c . || true)"; logl "$n0"; frames
  ask 19363 /customers/Ravi
  stop 19363 .harness/after; }

# ---- path: path variables ----------------------------------------------------------------------------------------------
path() { local c
  echo "after/ on the README's class-path line with the harness's Bind joined (its /probe/bind/name/{name} answers with the value it got), port 19362:"
  start "$(hcp .harness/after 19362 probe.web.Bind)"; up 19362; ready 19362
  ask 19362 /customers/Ravi; ask 19362 /customers/Nobody; ask 19362 /nowhere
  ask 19362 /customers/Ravi.json; ask 19362 /probe/bind/name/Ravi.json; ask 19362 '/probe/bind/name/Sunil%20K'
  st 19362 /customers/a%2Fb
  c=$(url "$L_TITLE" 19362); echo "\$ $c"; (eval "$c") 2>&1 < /dev/null | sed 's/^/  /'
  echo "  WARN and ERROR lines in its log, from the start: $(logl 0 | grep -c . || true)"
  stop 19362 .harness/after; }

# ---- params: request parameters, and their defaults ------------------------------------------------------------------------
params() {
  echo "after/ on the README's class-path line with the harness's Bind joined, port 19362 - TiffinBox's meal type first:"
  start "$(hcp .harness/after 19362 probe.web.Bind)"; up 19362; ready 19362
  ask 19362 '/customers?mealType=VEG'; ask 19362 '/customers?mealType=veg'; ask 19362 '/customers?mealType='; ask 19362 '/customers?mealType=VEG&mealType=VEGAN'
  echo "the harness's routes - required, a default value, Optional, a list:"
  ask 19362 /probe/bind/param; ask 19362 '/probe/bind/param?q='
  ask 19362 /probe/bind/default; ask 19362 '/probe/bind/default?days='; ask 19362 '/probe/bind/default?days=10'
  ask 19362 /probe/bind/optional; ask 19362 '/probe/bind/optional?days=5'
  ask 19362 '/probe/bind/list?tag=a&tag=b'; ask 19362 '/probe/bind/list?tag=a,b'
  echo "  WARN lines in this run's log, at Boot's default level: $(logl 0 WARN | grep -c . || true)"
  stop 19362 .harness/after; }

# ---- others: a header, a cookie, a matrix variable, a request attribute; the annotations, counted ----------------------------------
others() { local c a u o n
  echo "after/ on the README's class-path line with the harness's Bind and Resolvers joined, port 19362:"
  start "$(hcp .harness/after 19362 probe.web.Bind,probe.web.Resolvers)"; up 19362; ready 19362
  ask 19362 /probe/bind/header; ask 19362 /probe/bind/header "-H 'X-Meal: lunch'"
  ask 19362 /probe/bind/cookie; ask 19362 /probe/bind/cookie '-b plan=weekly'
  ask 19362 '/probe/bind/matrix/mon;veg=yes'; ask 19362 /probe/bind/matrix/mon
  ask 19362 /probe/bind/attr
  echo "every annotation a parameter can carry, read off spring-web's jar (the harness's Resolvers):"
  c=$(bc 19362 /probe/annotations); echo "\$ $c"; (eval "$c") 2>&1 < /dev/null > .harness/ann.txt; sed 's/^/  /' .harness/ann.txt
  a=$(sed -n '1s/^.*a parameter can carry [0-9]*: //p' .harness/ann.txt)
  { code ".harness/after/$W/TiffinBoxServer.java"; code harness/probe/web/Bind.java; } > .harness/bindcode.txt
  u=""; o=""; for n in $a; do if grep -qE "${n}([(]|$| )" .harness/bindcode.txt; then u="$u${u:+ }$n"; else o="$o${o:+ }$n"; fi; done
  echo "  of them on a route this unit's captures ask (the code lines of TiffinBoxServer.java and the harness's Bind.java): $(printf '%s\n' $u | grep -c .) - $u"
  echo "  the others: $(printf '%s\n' $o | grep -c .) - $o"
  echo "and one that is not spring-web's: Spring's @Value (spring-beans) binds a parameter too - the harness's /probe/bind/value, @Value(\"\${tiffinbox.port}\") String port:"
  ask 19362 /probe/bind/value
  echo "  WARN lines in this run's log, at Boot's default level: $(logl 0 WARN | grep -c . || true)"
  stop 19362 .harness/after; }

# ---- token: A/B/A' - the header required or not ------------------------------------------------------------------------------
# nohdr PORT: Course 5's line - POST /shutdown with no header at all - printed and run; then the WARN lines it added
nohdr() { local c n0; n0=$(mark); c=$(url "$R_POST" "$1"); echo "\$ $c"; (eval "$c") 2>&1 < /dev/null | tsmask > .harness/ask.txt; wans "$n0" .harness/ask.txt; }
# misspelt PORT DIR: POST /shutdown with the right token in a misspelt header (harness/shutdown.sh's fourth argument); its WARN lines
misspelt() { local n0; n0=$(mark); echo "\$ harness/shutdown.sh $1 $2/$TF /shutdown X-Shutdown-Tokn"; harness/shutdown.sh "$1" "$2/$TF" /shutdown X-Shutdown-Tokn | tsmask > .harness/ask.txt; wans "$n0" .harness/ask.txt; }
token1() { nohdr "$1"; misspelt "$1" "$2"; }
token() {
  echo "A - after/ (its header optional: required = false), the README's run line, port 19360:"
  start "$(at .harness/after 19360 "$R_RUN")"; up 19360; ready 19360; token1 19360 .harness/after; stop 19360 .harness/after
  echo "B - a copy of after/ whose header is required (one attribute changed), built with the README's line, port 19365:"
  copy after .harness/req
  sed 's/@RequestHeader(name = "X-Shutdown-Token", required = false) String token,$/@RequestHeader(name = "X-Shutdown-Token", required = true) String token,/' "after/$W/TiffinBoxServer.java" > ".harness/req/$W/TiffinBoxServer.java"
  echo "  \$ diff -U0 after/$W/TiffinBoxServer.java .harness/req/$W/TiffinBoxServer.java"; diff -U0 "after/$W/TiffinBoxServer.java" ".harness/req/$W/TiffinBoxServer.java" | tail -n +3 | sed 's/^/    /' || true
  pbuild .harness/req "the copy" | sed 's/^/  /'
  start "$(at .harness/req 19365 "$R_RUN")"; up 19365; ready 19365; token1 19365 .harness/req; stop 19365 .harness/req 2
  echo "A' - A again:"
  start "$(at .harness/after 19360 "$R_RUN")"; up 19360; ready 19360; token1 19360 .harness/after; stop 19360 .harness/after; }

# ---- trace: C (labelled) - every logger at TRACE, with a token of its own --------------------------------------------------------
# held: the records of the last run's log that hold $TTOK - each one's level and logger, its first line, and when the token sits on
# a later line of the record, that line too; the token masked, an identity hash after "@" made "…", a carriage return dropped
held() { awk -v tt="$TTOK" '
  { gsub(/\r/, "") }                                  # Tomcat prints the request it received as it came: lines end in CR LF
  function m(x) { while ((i = index(x, tt)) > 0) x = substr(x, 1, i - 1) "[masked: the trace run\047s token]" substr(x, i + length(tt)); gsub(/@[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]+/, "@…", x); return x }
  /^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T[^ ]+ +[A-Z]+ +[0-9]+ --- \[/ { lv = $2; s = $0; i = index(s, " --- ["); s = substr(s, i + 6); i = index(s, "] "); s = substr(s, i + 2)
    i = index(s, " : "); lg = substr(s, 1, i - 1); sub(/ +$/, "", lg); head = lv " " lg ": " substr(s, i + 3); k = 1
    if (index($0, tt)) print "    " m(head); next }
  { k++; if (index($0, tt)) print "    " m(head) "  - the token on the record'"'"'s line " k ": " m($0) }' .harness/run.out; }
# trace1 DIR SRC PORT 'README LINE': SRC's jar copied to DIR, whose config tree holds the trace run's token; the line run there,
# then the seven; the trace run's token counted in the log, and each record that holds it
trace1() { local d=$1 src=$2 p=$3 t h
  rm -rf "$d"; mkdir -p "$d/tiffinbox-web/target"; cp "$src/$JARP" "$d/$JARP"; tree "$d" "$TTOK"
  start "$(at "$d" "$p" "$4")"; up "$p"; ready "$p"
  sevenq "$p" "$d"
  t=$(raw "$TTOK" .harness/run.out .harness/run.err); h=$(raw "$TOKEN" .harness/run.out .harness/run.err)
  echo "  its log, the trace run's token in it: $t · the demo token: $h · the records that hold the trace run's token (level logger: first line):"
  held
  [ "$h" = 0 ] || die "a trace log held the demo token"
  : > .harness/run.out; : > .harness/run.err; rm -rf "$d"; }
trace() {
  echo "the two loggers that print the token at TRACE: the README's line with every logger at TRACE (Course 5's logging lesson: \"At TRACE, still no token\"), then this unit's line with Boot's web group at TRACE, each followed by the seven; each tree's jar copied to a folder whose config tree holds a second fake token, the trace run's own (26 characters):"
  echo "after/'s application.yaml, its first document: $(pplace "after/$YAML")"
  echo "before - the previous tree's jar (no such lines), every logger at TRACE, port 19361:"
  trace1 .harness/trb .harness/before 19361 "$R_TRACE"
  echo "A - after/'s jar (both loggers held at INFO), port 19360:"
  trace1 .harness/tra .harness/after 19360 "$R_TRACE"; trace1 .harness/tra .harness/after 19360 "$L_WTRACE"
  echo "B - a copy of after/ without the two loggers' lines (application.yaml's three lines deleted), built with the README's line, port 19366:"
  copy after .harness/unpin
  awk '!/^  level:$/ && !/^    org\.apache\.coyote\.http11\.Http11InputBuffer: info$/ && !/^    org\.springframework\.web\.method\.HandlerMethod: info$/' "after/$YAML" > ".harness/unpin/$YAML"
  echo "  \$ diff -U0 after/$YAML .harness/unpin/$YAML"; diff -U0 "after/$YAML" ".harness/unpin/$YAML" | tail -n +3 | sed 's/^/    /' || true
  pbuild .harness/unpin "the copy" | sed 's/^/  /'
  trace1 .harness/trc .harness/unpin 19366 "$R_TRACE"; trace1 .harness/trc .harness/unpin 19366 "$L_WTRACE"
  echo "A' - A again:"
  trace1 .harness/tra .harness/after 19360 "$R_TRACE"; trace1 .harness/tra .harness/after 19360 "$L_WTRACE"; }

# ---- timer: one series per route -------------------------------------------------------------------------------------------------
SENT=0
t() { local c; c=$(qc "$@"); echo "\$ $c"; (eval "$c") 2>&1 < /dev/null | sed 's/^/  /'; SENT=$((SENT + 1)); }
tread() { curl -s "http://127.0.0.1:$1/actuator/prometheus" | grep -E '^http_server_requests_seconds_count\{' | sort; }
timer() { local i=0 a b=x all c n0
  echo "after/, the README's run line, port 19360 - seven requests, then the scrape:"
  start "$(at .harness/after 19360 "$R_RUN")"; up 19360; ready 19360; n0=$(mark); SENT=0
  t 19360 /customers/Ravi; t 19360 /customers/Meera; t 19360 /customers/Nobody
  c=$(url "$R_C7" 19360); echo "\$ $c"; (eval "$c") 2>&1 < /dev/null | sed 's/^/  /'; SENT=$((SENT + 1))
  t 19360 '/customers?mealType=VEG'; t 19360 '/customers?mealType=veg'; t 19360 /customers/a%2Fb
  while [ $i -lt 30 ]; do all=$(tread 19360); a=$(printf '%s\n' "$all" | grep -v 'uri="/actuator' || true); [ "$a" = "$b" ] && break; b=$a; sleep 0.5; i=$((i + 1)); done
  echo "  the scrape's count lines for Boot's timer, http_server_requests (Actuator's own series left out):"; printf '%s\n' "$a" | grep . | sed 's/^/    /' || true
  echo "  Actuator's own series, left out: $( [ "$(printf '%s\n' "$all" | grep -c 'uri="/actuator' || true)" -lt 10 ] && echo 'fewer than 10' || echo '10 or more') (the readiness polls and these reads move their counts)"
  echo "  requests sent: $SENT · counted by Boot's timer: $(printf '%s\n' "$a" | awk '{ s += $NF } END { print s + 0 }') · series: $(printf '%s\n' "$a" | grep -c . || true) · their uri tags: $(printf '%s\n' "$a" | sed -n 's/.*uri="\([^"]*\)".*/\1/p' | sort -u | paste -sd' ' -)"
  settle; echo "  WARN lines these requests added, at Boot's default level: $(logl "$n0" WARN | grep -c . || true)"
  stop 19360 .harness/after; }

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
  echo "  the shell is now in: $(where "$d2") · the copy's own token in its log: $(raw "$(head -1 .harness/mine/after/$TF)" .harness/mine/run.log) times · WARN lines in its log: $(grep -c ' WARN ' .harness/mine/run.log || true) · listening on 19369 now: $(listeners 19369)"; }

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
  if [ "$1" = '4 the image' ]; then [ "$(grep -c '^  docker port: ' .harness/blk.txt)" = 2 ] && [ "$(grep -cE '^  docker port: 18425/tcp -> 127\.0\.0\.1:19367$' .harness/blk.txt)" = 2 ] && echo yes || echo no
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
# routes PORT: the new routes, asked of a form - one customer, a name nobody has, a meal type, the meal type in the wrong case,
# POST /shutdown with no header - each answer printed (the timestamp masked)
rq() { local c; c=$(bc "$@"); echo "\$ $c"; (eval "$c") 2>&1 < /dev/null | tsmask | sed 's/^/  /'; }
routes() { local c
  rq "$1" /customers/Ravi; rq "$1" /customers/Nobody; rq "$1" '/customers?mealType=VEGAN'; rq "$1" '/customers?mealType=vegan'
  c=$(url "$R_POST" "$1"); echo "\$ $c"; (eval "$c") 2>&1 < /dev/null | tsmask | sed 's/^/  /'; }
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
  echo "  file: $(file -b ".harness/nat/$BIN" | sed 's/ [A-Za-z0-9_]*$//') · the demo token in its bytes: $(raw "$TOKEN" ".harness/nat/$BIN") · the trace run's: $(raw "$TTOK" ".harness/nat/$BIN")"
  echo "what Spring's AOT step registered for the native build - the record the routes return, and the enum a route's parameter is:"
  aotmeta .harness/nat
  echo "1 the jar - .harness/after, the README's run line, port 19360:"
  start "$(at .harness/after 19360 "$R_RUN")"; up 19360; ready 19360; tline; seven 19360 .harness/after
  echo "  then the new routes, on a second start of the jar:"
  start "$(at .harness/after 19360 "$R_RUN")"; up 19360; ready 19360; routes 19360; stop 19360 .harness/after
  echo "2 the AOT jar - .harness/nat (the profile native's jar), the README's AOT line, port 19364:"
  start "$(at .harness/nat 19364 "$R_AOTRUN")"; up 19364; ready 19364; tline; seven 19364 .harness/nat
  echo "  then the new routes, on a second start of the AOT jar:"
  start "$(at .harness/nat 19364 "$R_AOTRUN")"; up 19364; ready 19364; routes 19364; stop 19364 .harness/nat
  echo "3 the binary - .harness/nat, the README's line, port 19368:"
  start "$(at .harness/nat 19368 "$R_BIN")"; up 19368; ready 19368; tline; seven 19368 .harness/nat
  echo "  then the new routes, on a second start of the binary:"
  start "$(at .harness/nat 19368 "$R_BIN")"; up 19368; ready 19368; routes 19368; stop 19368 .harness/nat
  echo "4 the image - after/'s Dockerfile (the README's build line, this script's tag), the README's run line with your user, published on 127.0.0.1:19367:"
  image
  dstart "$(drun .harness/after 19367)"; ready 19367 "$BOX"; dbind 19367
  dseven 19367
  echo "  then the new routes, on a second container of the image:"
  dstart "$(drun .harness/after 19367)"; ready 19367 "$BOX"; dbind 19367
  routes 19367
  post 19367 .harness/after; dgone "$BOX"; [ "$(listeners 19367)" = 0 ] || die "something still listens on 19367"
  dlog "$BOX"; echo "  exit $LASTE · its log (docker logs): the demo token 0 times · X-Shutdown-Token 0 times"
  docker rm "$BOX" > /dev/null
  echo "four forms, one tree: the seven (masked) $(grep -cE '^  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 2 · md5 87ca7efc8584dcccd40e6b956db1de9b$' .harness/cap.raw) of 4 times 87ca7efc8584dcccd40e6b956db1de9b · Ravi 200 $(grep -cxF '  {"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"} 200' .harness/cap.raw) of 4 · a name nobody has 404 $(grep -cxF '  {"timestamp":"…","status":404,"error":"Not Found","path":"/customers/Nobody"} 404' .harness/cap.raw) of 4 · VEGAN -> Priya $(grep -cxF '  [{"name":"Priya","mealsPerDay":1,"pricePerMeal":120,"mealType":"VEGAN"}] 200' .harness/cap.raw) of 4 · vegan 400 $(grep -cxF '  {"timestamp":"…","status":400,"error":"Bad Request","path":"/customers"} 400' .harness/cap.raw) of 4 · no header 403 $(grep -cxF '  {"error":"forbidden"} 403' .harness/cap.raw) of 4"
  echo "  loopback, form by form: the jar $(lbk '1 the jar') · the AOT jar $(lbk '2 the AOT jar') · the binary $(lbk '3 the binary') · the image, published on 127.0.0.1 alone $(lbk '4 the image')"; }

# pplace's check, shown failing once before any capture (R.65): a planted copy of after/'s application.yaml with the three lines
# moved to the end of the file - under the second document, the profile rush's - must fail it; after/'s own must pass
awk '/^  level:$|^    org\.apache\.coyote\.http11\.Http11InputBuffer: info$|^    org\.springframework\.web\.method\.HandlerMethod: info$/ { held = held $0 "\n"; next } { print } END { printf "logging:\n%s", held }' "after/$YAML" > .harness/planted.yaml
case "$(pplace .harness/planted.yaml)" in *'in the first document: no') ;; *) rm -f .harness/planted.yaml; die "pplace: the planted copy, the loggers below the ---, passes the check" ;; esac; rm -f .harness/planted.yaml
case "$(pplace "after/$YAML")" in *'under logging: '*'in the first document: yes') ;; *) die "pplace: after/'s own application.yaml fails the check" ;; esac
echo "  pplace: a planted copy, the two loggers below the ---, fails the check; after/'s own passes"
cap change change
cap resolvers resolvers
cap path path
cap params params
cap others others
cap token token
cap trace trace
cap timer timer
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
# THE TOKENS: no capture holds either, raw - counted on each run's own output BEFORE masking - and neither does any log (each
# counted when it was read: fails(), logtok(), dlog(); the trace logs hold only the trace run's own, counted there), anything this
# unit ships for reading, nor the binary this run built
for f in .harness/raw-*; do [ "$(cat "$f")" = "0 0" ] || die "a capture's raw output held a token ($f: $(cat "$f"))"; done
NBIN=0
for f in .r-*.out README.md exercise/README.md exercise/solution/SOLUTION.md receipts.md5 harness/shutdown.sh harness/table.py harness/probe/web/*.java harness/bare/probe/bare/*.java .harness/nat/$BIN; do
  [ -f "$f" ] || continue; case $f in .harness/nat*) NBIN=$((NBIN + 1)) ;; esac
  [ "$(raw "$TOKEN" "$f")" = 0 ] || die "$f holds the demo token, raw"
  case $f in .harness/nat*) [ "$(raw "$TTOK" "$f")" = 0 ] || die "$f holds the trace run's token, raw" ;; esac; done
[ "$NBIN" = 1 ] || die "one binary was built, $NBIN were checked"
for f in .r-*.out; do ! grep -qE '/Users/|/private/|/home/|/var/folders/' "$f" || die "$f holds an absolute path"; [ -z "${GRAALVM_HOME:-}" ] || ! grep -qF "$GRAALVM_HOME" "$f" || die "$f holds the GraalVM's folder"; ! grep -qE 'c[0-9]-unit[0-9]|unit ?[0-9]' "$f" || die "$f holds a unit number"; ! grep -qE ' (with PID|started by) ' "$f" || die "$f holds Boot's process line"; ! grep -qE '^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T|"timestamp":"?[0-9]|timestamp=[A-Z0-9]|(exec|handler|task|utility)-[0-9]' "$f" || die "$f holds a log line's time, a timestamp or a thread's number"; ! grep -q "^$(printf '\t')at " "$f" || die "$f shows a stack frame"; ! grep -qE 'sha256:[0-9a-f]{64}' "$f" || [ "$(grep -cE 'sha256:[0-9a-f]{64}' "$f")" = "$(grep -cE 'eclipse-temurin(:25-jre)?@sha256:[0-9a-f]{64}' "$f")" ] || die "$f holds an ID other than the base image's digest"; ! grep -qE ':8080([^0-9]|$)' "$f" || die "$f shows a bind on 8080"; ! grep -q $'\r' "$f" || die "$f holds a carriage return"; done
for f in receipts.sh README.md exercise/README.md exercise/solution/SOLUTION.md harness/shutdown.sh; do [ -f "$f" ] || continue; ! grep -qE "exposure\.include='?\*" "$f" || die "$f exposes every endpoint (R.42)"; ! grep -E 'server\.error\.' "$f" | grep -vE '^ *#' > /dev/null || die "$f names one of Boot 3's error keys (server, then error) - Boot 4.1 reads only spring.web.error.* (S2.13)"; done
for f in receipts.sh README.md exercise/README.md exercise/solution/SOLUTION.md; do [ -f "$f" ] || continue; ! grep -E 'docker run ' "$f" | grep -vE '^#' | grep -E ' -p "?[0-9]+:' > /dev/null || die "$f publishes a port on every address (-p without 127.0.0.1:)"; done
NL=$(cat .r-*.out | grep -cE "^  its log: the demo token 0 times · X-Shutdown-Token [0-9]+ times\$" || true)
echo "  tokens: 0 raw copies of either in $(ls .harness/raw-* | wc -l | tr -d ' ') raw capture runs, in $(ls .r-*.out | wc -l | tr -d ' ') captures; the demo token 0 in the logs of every JVM that served ($LOGS here; the published captures' $NL) and every container ($CLOGS here), the image's layers (forms), the READMEs, the harness, the exercise, receipts.md5 and the binary; no absolute path, no GraalVM folder, no unit number, no process line, no log time, no timestamp, no thread number, no stack frame, no ID but the base image's digest, no 8080, no carriage return in any capture; every docker run publishes on 127.0.0.1 only"

S87C='87ca7efc8584dcccd40e6b956db1de9b'
SEVEN1="  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 2 · md5 $S87C"
STOPPED() { printf '  exit 0 · listening on %s now: 0\n' "$1"; }
SHUT='  POST /shutdown -> 200 application/json · Content-Length: 17 · {"stopping":true} · curl exit 0'
RES="DefaultHandlerExceptionResolver: Resolved [org.springframework.web."

RAVI='  {"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"} 200'
PRIYA='  [{"name":"Priya","mealsPerDay":1,"pricePerMeal":120,"mealType":"VEGAN"}] 200'
FOUR='  [{"name":"Meera","mealsPerDay":1,"pricePerMeal":150,"mealType":"NON_VEG"},{"name":"Priya","mealsPerDay":1,"pricePerMeal":120,"mealType":"VEGAN"},{"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"},{"name":"Sunil","mealsPerDay":3,"pricePerMeal":100,"mealType":"VEG"}] 200'
VEG2='  [{"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"},{"name":"Sunil","mealsPerDay":3,"pricePerMeal":100,"mealType":"VEG"}] 200'
E404() { printf '  {"timestamp":"…","status":404,"error":"Not Found","path":"%s"} 404' "$1"; }
E400() { printf '  {"timestamp":"…","status":400,"error":"Bad Request","path":"%s"} 400' "$1"; }
WA() { printf '%s · WARN lines it added: %s' "$1" "$2"; }
BQ() { local u="http://127.0.0.1:$1$2"; case $2 in *[\;\?\&\*\{\}]*) u="'$u'" ;; esac; printf "\$ curl -s -w ' %%{http_code}\\\\n'%s %s" "${3:+ $3}" "$u"; }
QQ() { printf "\$ curl -s -o /dev/null -w '%%{http_code} %%{content_type}\\\\n' http://127.0.0.1:%s%s" "$1" "$2"; }
WVEG="    WARN .w.s.m.s.${RES}method.annotation.MethodArgumentTypeMismatchException: Method parameter 'mealType': Failed to convert value of type 'java.lang.String' to required type 'com.tiffinbox.MealType'; Failed to convert from type [java.lang.String] to type [@org.springframework.web.bind.annotation.RequestParam com.tiffinbox.MealType] for value [veg]]"
WHDR="    WARN .w.s.m.s.${RES}bind.MissingRequestHeaderException: Required request header 'X-Shutdown-Token' for method parameter type String is not present]"
[ "$(BQ 19360 '/customers?mealType=VEGAN')" = "\$ $(url "$R_MEAL" 19360)" ] && [ "$(BQ 19360 /customers/Ravi)" = "\$ $(url "$R_ONE" 19360)" ] && [ "$(QQ 19360 /customers)" = "\$ $(url "$R_Q" 19360)" ] || die "the checks' own command lines are not the README's"

# "Ask TiffinBox for the vegan customers, and it hands you all four. Ask for Ravi by name: four oh four ... So three values become
#  method parameters, each named by an annotation."
CB=$(blk change 'what a request can ask' 'after - '); CA=$(blk change 'after - ' 'the routing table'); CT=$(blk change 'the routing table' '')
x change '^  built the previous tree · offline: yes · exit 0$'; x change '^  built after/ · offline: yes · exit 0$'
[ "$(n change '^  Files ')" = 4 ] && [ "$(n change '^  Only in ')" = 0 ] || die "change: four files differ, none added or deleted"
for f in README.md tiffinbox-core/src/main/java/com/tiffinbox/CustomerRepository.java tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java tiffinbox-web/src/main/resources/application.yaml; do x change "^  Files \.harness/before/$f and \.harness/after/$f differ\$"; done
x change '^  TiffinBoxServer\.java: 176 -> 197$'; x change '^  CustomerRepository\.java: 50 -> 64$'
x change '^    a value from the request, by Spring MVC.s annotation \(@PathVariable, @RequestParam, @RequestHeader\): 0 -> 3 · the servlet request \(HttpServletRequest, getHeader\): 3 -> 0$'
x change '^    Spring.s status exception \(ResponseStatusException\): 0 -> 1 · a route \(@GetMapping, @PostMapping\): 5 -> 6$'
for l in '    +    List<Customer> customers(@RequestParam(required = false) MealType mealType) throws Exception {' '    +    @GetMapping("/customers/{name}")' '    +    Customer customer(@PathVariable String name) throws Exception {' '    +                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "no customer named " + name));' '    -    Map<String, Object> shutdown(HttpServletRequest request, HttpServletResponse response) {' '    +    Map<String, Object> shutdown(@RequestHeader(name = "X-Shutdown-Token", required = false) String token,' '    +    private boolean holdsToken(String sent) {' '    +    public Optional<Customer> findByName(String name) throws SQLException {' '    +                 "SELECT name, meals_per_day, price_per_meal, meal_type FROM customer WHERE name = ?")) {'; do
  grep -qxF -- "$l" .r-change.out || die "change: the hunk line $l"; done
x change '^the executable jar.s BOOT-INF/lib: 58 jars -> 58 · removed 0 · added 0$'
x change '^  the other files, against the previous tree.s, byte for byte the same: 18 of 18 '
x change '^  application\.yaml - its lines that are neither comment nor blank: 47 -> 50 · their diff \(diff -U1, its file names cut\) - hunks: 1 · lines out: 0 · in: 3 - whole:$'
[ "$(blk change '  application.yaml - its lines' '  its comment lines' | paste -sd'|' -)" = '    @@ -30,2 +30,5 @@|         kitchen: tiffinbox, com.tiffinbox|    +  level:|    +    org.apache.coyote.http11.Http11InputBuffer: info|    +    org.springframework.web.method.HandlerMethod: info|     management:' ] || die "change: application.yaml's three new lines, under logging:"
x change '^  its comment lines: [0-9]+ -> [0-9]+ · where the two loggers sit: level: line [0-9]+, under logging: \(line [0-9]+\) · .* · in the first document: yes$'
[ "$(n change ' against the previous tree.s: different$')" = 0 ] || die "change: a file left alone differs"
has "$CB" "$(WA "$(E404 /customers/Ravi)" 0)" "change before: Ravi is Spring's 404"; has "$CB" "$(WA "$FOUR" 0)" "change before: ?mealType=VEGAN answers all four"
[ "$(aft "$(BQ 19361 '/customers?mealType=VEGAN')" "$CB")" = "$(WA "$FOUR" 0)" ] || die "change before: the four answer the vegan request"
[ "$(printf '%s\n' "$FOUR" | grep -o '"name":' | wc -l | tr -d ' ')" = 4 ] || die "change: four customers"
[ "$(aft "$(BQ 19360 /customers/Ravi)" "$CA")" = "$(WA "$RAVI" 0)" ] && [ "$(aft "$(BQ 19360 '/customers?mealType=VEGAN')" "$CA")" = "$(WA "$PRIYA" 0)" ] || die "change after: Ravi's record, Priya alone"
# "Spring registers six of TiffinBox's routes now, eight mappings in all, each with its parameter types."
has "$CA" '      c.t.w.TiffinBoxServer:' "change: TiffinBox's block at TRACE"
for r in '{GET [/customers/{name}]}: customer(String)' '{GET [/customers]}: customers(MealType)' '{GET [/dashboard]}: dashboard()' '{GET [/kitchen]}: kitchen()' '{GET [/revenue]}: revenue()' '{POST [/shutdown]}: shutdown(String,HttpServletResponse)'; do has "$CA" "        $r" "change: $r"; done
[ "$(printf '%s\n' "$CA" | grep -cE '^        \{(GET|POST) \[/[a-z/{}]+\]\}: [a-z]+\(')" = 6 ] && [ "$(printf '%s\n' "$CA" | grep -cE '^        \{ \[/error\]')" = 2 ] || die "change: six of TiffinBox's, two of Boot's"
has "$CA" "    s.w.s.m.m.a.RequestMappingHandlerMapping: DEBUG 8 mappings in 'requestMappingHandlerMapping'" "change: eight mappings"
printf '%s\n' "$CA" | grep -qE "^  then Boot's started line - logger: message: o\.s\.boot\.tomcat\.TomcatWebServer: Tomcat started on port 19360 " || die "change: registered before Boot's started line"
printf '%s\n' "$CT" | grep -qE '^  dispatcherServlets · dispatcherServlet: 15 rows, ' || die "change: fifteen rows"
has "$CT" "  TiffinBox's rows (its own handler, or a TiffinBoxServer method): 6 · naming a verb: 6 (GET 5 POST 1)" "change: TiffinBox's six rows"
CR=$(blk change "\$ curl -s http://127.0.0.1:19360/actuator/mappings | python3 harness/table.py row /customers" '')
has "$CR" '    details.requestMappingConditions.params = []' "change: the /customers row - the meal type is no part of the match"; has "$CR" '    handler = com.tiffinbox.web.TiffinBoxServer#customers(MealType)' "change: the /customers row's handler"
has "$CT" '    handler = com.tiffinbox.web.TiffinBoxServer#customer(String)' "change: the new row's handler"
printf '%s\n' "$CT" | grep -qE '^  servletFilters: 5, by name: .*webMvcObservationFilter' || die "change: Boot's timer is a servlet filter"
echo "  change: 4 files; 176 -> 197 and 50 -> 64; binding lines 0 -> 3, the servlet request 3 -> 0, ResponseStatusException 0 -> 1, routes 5 -> 6; application.yaml 47 -> 50, the two loggers under logging:, in the first document; lib 58; 18 files the same; before Ravi 404, VEGAN -> all 4; after Ravi 200, VEGAN -> Priya; 6 + 2 = 8 mappings with types; 15 rows, TiffinBox's 6 with verbs; the /customers row's params = []"

# "its adapter holds twenty-eight argument resolvers here ... path variable, resolver three; request param, one; request header, ten ...
#  only with javac's parameters flag, which Boot's parent turns on. C: ... A clean start, then a five hundred, and Spring's own sentence"
VR=$(blk resolvers 'who fills' 'by name'); VN=$(blk resolvers 'by name' 'C (labelled)'); VC=$(blk resolvers 'C (labelled)' '')
has "$VR" '  argument resolvers: 28 · return-value handlers: 15' "resolvers: 28 here"
[ "$(printf '%s\n' "$VR" | grep -cE '^ +[0-9]+ [A-Za-z]+$')" = 28 ] || die "resolvers: 28 listed"
has "$VR" '    1 RequestParamMethodArgumentResolver' "resolvers: one"; has "$VR" '    3 PathVariableMethodArgumentResolver' "resolvers: three"; has "$VR" '   10 RequestHeaderMethodArgumentResolver' "resolvers: ten"
has "$VR" '      String name @PathVariable -> 3 PathVariableMethodArgumentResolver' "resolvers: the path variable's"
has "$VR" '      MealType mealType @RequestParam -> 1 RequestParamMethodArgumentResolver' "resolvers: the request parameter's"
has "$VR" '      String token @RequestHeader -> 10 RequestHeaderMethodArgumentResolver' "resolvers: the header's"
has "$VR" '      HttpServletResponse response -> 17 ServletResponseMethodArgumentResolver' "resolvers: the response's"
has "$VN" '  $M2/org/springframework/boot/spring-boot-starter-parent/4.1.1/spring-boot-starter-parent-4.1.1.pom, its compiler plugin'"'"'s configuration: line 113: <parameters>true</parameters>' "resolvers: Boot's parent turns it on"
has "$VN" '  its methods with a MethodParameters attribute: 7 · customer(java.lang.String): name · customers(com.tiffinbox.MealType): mealType · shutdown(java.lang.String, jakarta.servlet.http.HttpServletResponse): token response' "resolvers: the names javac wrote"
has "$VC" '  its methods with a MethodParameters attribute: 0 · name(java.lang.String): no names' "resolvers C: no names"
printf '%s\n' "$VC" | grep -qE "^  Boot's started line - logger: message: o\.s\.boot\.tomcat\.TomcatWebServer: Tomcat started on port 19363 " || die "resolvers C: Boot's started line"; has "$VC" '  WARN and ERROR lines in its log, from the start: 0' "resolvers C: a clean start"
has "$VC" '  {"timestamp":"…","status":500,"error":"Internal Server Error","path":"/probe/bare/Ravi"} 500' "resolvers C: a five hundred"
has "$VC" "    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: Servlet.service() for servlet [dispatcherServlet] in context with path [] threw exception [Request processing failed: java.lang.IllegalArgumentException: Name for argument of type [java.lang.String] not specified, and parameter name information not available via reflection. Ensure that the compiler uses the '-parameters' flag.] with root cause" "resolvers C: Spring's sentence, in Tomcat's ERROR line"
has "$VC" "  stack frames in its log: over 40, not shown · its exceptions' first lines:" "resolvers C: the trace, bounded"
has "$VC" "$(WA "$RAVI" 0)" "resolvers C: TiffinBox's own route still answers"
echo "  resolvers: 28 (15 return-value handlers); @PathVariable -> 3, @RequestParam -> 1, @RequestHeader -> 10, the response -> 17; the parent's line 113; javap 7 / C 0, no names; C: a clean start, 500, Spring's sentence, over 40 frames"

# "Ravi: two hundred, the record. Nobody: four oh four ... The same shape as slash nowhere's, no warning, and no reason in the body.
#  Ravi dot json stays one whole segment, and percent twenty arrives as a space. An encoded slash gets Tomcat's own HTML four hundred"
PT=$(cat .r-path.out)
[ "$(aft "$(BQ 19362 /customers/Ravi)" "$PT")" = "$(WA "$RAVI" 0)" ] || die "path: Ravi"
[ "$(aft "$(BQ 19362 /customers/Nobody)" "$PT")" = "$(WA "$(E404 /customers/Nobody)" 0)" ] || die "path: Nobody, 404, no WARN"
[ "$(aft "$(BQ 19362 /nowhere)" "$PT")" = "$(WA "$(E404 /nowhere)" 0)" ] || die "path: /nowhere, the same shape"
[ "$(aft "$(BQ 19362 /customers/Ravi.json)" "$PT")" = "$(WA "$(E404 /customers/Ravi.json)" 0)" ] && [ "$(aft "$(BQ 19362 /probe/bind/name/Ravi.json)" "$PT")" = "$(WA '  name=[Ravi.json] 200' 0)" ] || die "path: the whole segment"
[ "$(aft "$(BQ 19362 /probe/bind/name/Sunil%20K)" "$PT")" = "$(WA '  name=[Sunil K] 200' 0)" ] || die "path: %20 is a space"
[ "$(aft "$(QQ 19362 /customers/a%2Fb)" "$PT")" = "$(WA '  400 text/html;charset=utf-8' 0)" ] || die "path: %2F is Tomcat's HTML 400"
has "$PT" '  <title>HTTP Status 400 – Bad Request</title>' "path: Tomcat's page"; has "$PT" '  WARN and ERROR lines in its log, from the start: 0' "path: nothing logged"
echo "  path: Ravi 200; Nobody 404 in /nowhere's shape, 0 WARN; Ravi.json 404 / [Ravi.json]; %20 -> a space; %2F -> Tomcat's HTML 400; 0 WARN/ERROR"

# "Meal type VEG: two customers. Lower case veg: Spring's four hundred, and one warning line ... Empty means no filter, so all four;
#  sent twice, the first wins. ... a required parameter that's missing is four hundred, but an empty one counts. A default value answers
#  missing and empty alike. Optional says empty, and a list takes repeats or commas."
PR=$(cat .r-params.out)
[ "$(aft "$(BQ 19362 '/customers?mealType=VEG')" "$PR")" = "$(WA "$VEG2" 0)" ] || die "params: VEG, two"
[ "$(printf '%s\n' "$VEG2" | grep -o '"name":' | wc -l | tr -d ' ')" = 2 ] || die "params: two customers"
[ "$(aft "$(BQ 19362 '/customers?mealType=veg')" "$PR")" = "$(WA "$(E400 /customers)" 1)" ] && has "$PR" "$WVEG" "params: veg, its WARN line" || die "params: veg, 400"
[ "$(aft "$(BQ 19362 '/customers?mealType=')" "$PR")" = "$(WA "$FOUR" 0)" ] || die "params: empty, all four"
[ "$(aft "$(BQ 19362 '/customers?mealType=VEG&mealType=VEGAN')" "$PR")" = "$(WA "$VEG2" 0)" ] || die "params: twice, the first"
[ "$(aft "$(BQ 19362 /probe/bind/param)" "$PR")" = "$(WA "$(E400 /probe/bind/param)" 1)" ] && has "$PR" "    WARN .w.s.m.s.${RES}bind.MissingServletRequestParameterException: Required request parameter 'q' for method parameter type String is not present]" "params: required, its WARN" || die "params: required, missing"
[ "$(aft "$(BQ 19362 '/probe/bind/param?q=')" "$PR")" = "$(WA '  q=[] 200' 0)" ] || die "params: an empty one counts"
[ "$(aft "$(BQ 19362 /probe/bind/default)" "$PR")" = "$(WA '  days=30 200' 0)" ] && [ "$(aft "$(BQ 19362 '/probe/bind/default?days=')" "$PR")" = "$(WA '  days=30 200' 0)" ] && [ "$(aft "$(BQ 19362 '/probe/bind/default?days=10')" "$PR")" = "$(WA '  days=10 200' 0)" ] || die "params: the default, missing and empty alike"
[ "$(aft "$(BQ 19362 /probe/bind/optional)" "$PR")" = "$(WA '  days=Optional.empty 200' 0)" ] && [ "$(aft "$(BQ 19362 '/probe/bind/optional?days=5')" "$PR")" = "$(WA '  days=Optional[5] 200' 0)" ] || die "params: Optional"
[ "$(aft "$(BQ 19362 '/probe/bind/list?tag=a&tag=b')" "$PR")" = "$(WA '  tag=[a, b] 200' 0)" ] && [ "$(aft "$(BQ 19362 '/probe/bind/list?tag=a,b')" "$PR")" = "$(WA '  tag=[a, b] 200' 0)" ] || die "params: a list, repeats or commas"
has "$PR" "  WARN lines in this run's log, at Boot's default level: 2" "params: two WARN lines in all"
echo "  params: VEG 2; veg 400 + WARN (MealType); empty all 4; twice the first; q missing 400 + WARN, empty []; days 30/30/10; Optional; [a, b] twice; 2 WARN"

# "A required header, or a required cookie ... missing, each is four hundred and a warning. A matrix variable ... is read here by default.
#  A request attribute ... missing: four hundred. ... eleven annotations a parameter can carry. This lesson's routes use six. The other five"
OT=$(cat .r-others.out)
[ "$(aft "$(BQ 19362 /probe/bind/header)" "$OT")" = "$(WA "$(E400 /probe/bind/header)" 1)" ] && has "$OT" "    WARN .w.s.m.s.${RES}bind.MissingRequestHeaderException: Required request header 'X-Meal' for method parameter type String is not present]" "others: the header's WARN" || die "others: a header, missing"
[ "$(aft "$(BQ 19362 /probe/bind/header "-H 'X-Meal: lunch'")" "$OT")" = "$(WA '  meal=lunch 200' 0)" ] || die "others: a header"
[ "$(aft "$(BQ 19362 /probe/bind/cookie)" "$OT")" = "$(WA "$(E400 /probe/bind/cookie)" 1)" ] && has "$OT" "    WARN .w.s.m.s.${RES}bind.MissingRequestCookieException: Required cookie 'plan' for method parameter type String is not present]" "others: the cookie's WARN" || die "others: a cookie, missing"
[ "$(aft "$(BQ 19362 /probe/bind/cookie '-b plan=weekly')" "$OT")" = "$(WA '  plan=weekly 200' 0)" ] || die "others: a cookie"
[ "$(aft "$(BQ 19362 '/probe/bind/matrix/mon;veg=yes')" "$OT")" = "$(WA '  day=mon veg=yes 200' 0)" ] && [ "$(aft "$(BQ 19362 /probe/bind/matrix/mon)" "$OT")" = "$(WA '  day=mon veg=null 200' 0)" ] || die "others: a matrix variable, read by default"
[ "$(aft "$(BQ 19362 /probe/bind/attr)" "$OT")" = "$(WA "$(E400 /probe/bind/attr)" 1)" ] && has "$OT" "    WARN .w.s.m.s.${RES}bind.ServletRequestBindingException: Missing request attribute 'slip' of type String]" "others: the attribute's WARN" || die "others: a request attribute, missing"
has "$OT" '  spring-web-7.0.9.jar · org.springframework.web.bind.annotation: annotations 27 · a parameter can carry 11: @BindParam @CookieValue @MatrixVariable @ModelAttribute @PathVariable @RequestAttribute @RequestBody @RequestHeader @RequestParam @RequestPart @SessionAttribute' "others: eleven"
has "$OT" "  of them on a route this unit's captures ask (the code lines of TiffinBoxServer.java and the harness's Bind.java): 6 - @CookieValue @MatrixVariable @PathVariable @RequestAttribute @RequestHeader @RequestParam" "others: six used"
has "$OT" '  the others: 5 - @BindParam @ModelAttribute @RequestBody @RequestPart @SessionAttribute' "others: the other five"
has "$OT" "  WARN lines in this run's log, at Boot's default level: 3" "others: three WARN lines in all"
[ "$(aft "$(BQ 19362 /probe/bind/value)" "$OT")" = "$(WA '  port=[19362] 200' 0)" ] || die "others: spring-beans' @Value binds a parameter too"
has "$VR" '   13 ExpressionValueMethodArgumentResolver' "resolvers: the adapter's resolver for @Value, 13"
echo "  others: header, cookie, request attribute missing -> 400 + WARN each; matrix veg=yes by default; 27 annotations, 11 for a parameter in spring-web's jar, 6 used, 5 others; spring-beans' @Value binds one too (resolver 13)"

# "Its header is optional ... TiffinBox's own method says four oh three. B: one attribute, required true. Now Spring answers instead,
#  four hundred, with a warning naming the header, and TiffinBox never gets to say forbidden. A again: four oh three."
KA=$(blk token 'A - after/' 'B - a copy'); KB=$(blk token 'B - a copy' "A' - A again"); KA2=$(blk token "A' - A again" '')
for b in "$KA" "$KA2"; do
  [ "$(aft "\$ $(url "$R_POST" 19360)" "$b")" = "$(WA '  {"error":"forbidden"} 403' 0)" ] || die "token A/A': no header, the method's 403"
  [ "$(aft '$ harness/shutdown.sh 19360 .harness/after/secrets/tiffinbox/shutdown-token /shutdown X-Shutdown-Tokn' "$b")" = "$(WA '  POST /shutdown (the token in a header named X-Shutdown-Tokn) -> 403 application/json · Content-Length: 21 · {"error":"forbidden"} · curl exit 0' 0)" ] || die "token A/A': a misspelt header, the method's 403"
  has "$b" "$SHUT" "token A/A': the right one stops it"; has "$b" "$(STOPPED 19360)" "token A/A': exit 0"; has "$b" '  its log: the demo token 0 times · X-Shutdown-Token 0 times' "token A/A': nothing logged"; done
[ "$(printf '%s\n' "$KA" | sed 1d)" = "$(printf '%s\n' "$KA2" | sed 1d)" ] || die "token: A' is not A"
has "$KB" '    -    Map<String, Object> shutdown(@RequestHeader(name = "X-Shutdown-Token", required = false) String token,' "token B: the attribute, before"
has "$KB" '    +    Map<String, Object> shutdown(@RequestHeader(name = "X-Shutdown-Token", required = true) String token,' "token B: the attribute, after"
[ "$(printf '%s\n' "$KB" | grep -cE '^    [-+]    ')" = 2 ] || die "token B: one attribute changed"
has "$KB" '    built the copy · offline: yes · exit 0' "token B: built offline"
[ "$(aft "\$ $(url "$R_POST" 19365)" "$KB")" = "$(WA "$(E400 /shutdown)" 1)" ] || die "token B: no header, Spring's 400"
[ "$(aft '$ harness/shutdown.sh 19365 .harness/req/secrets/tiffinbox/shutdown-token /shutdown X-Shutdown-Tokn' "$KB")" = "$(WA '  POST /shutdown (the token in a header named X-Shutdown-Tokn) -> 400 application/json · Content-Length: none · {"timestamp":"…","status":400,"error":"Bad Request","path":"/shutdown"} · curl exit 0' 1)" ] || die "token B: a misspelt header, Spring's 400"
[ "$(printf '%s\n' "$KB" | grep -cxF -- "$WHDR")" = 2 ] || die "token B: two WARN lines naming the header"
! printf '%s\n' "$KB" | grep -qF 'forbidden' || die "token B: TiffinBox said forbidden"
has "$KB" '  its log: the demo token 0 times · X-Shutdown-Token 2 times' "token B: the header's name twice, the token never"; has "$KB" "$SHUT" "token B: the right one stops it"
echo "  token: A and A' - no header 403, misspelt 403, 0 WARN; B (required = true, one attribute) - 400 + WARN MissingRequestHeaderException x2, no forbidden; the token 0 in every log"

# "One cost, measured: at TRACE, Spring's HandlerMethod prints a route's arguments, the token among them - Boot's web group at TRACE is
#  enough - and Tomcat's Http11InputBuffer prints the raw request when its logger is at TRACE ... both held at INFO ... A: every logger
#  at TRACE, then the web group: zero. B, without those lines: twice, then once. A again: zero."
TB0=$(blk trace 'before - ' 'A - '); TA=$(blk trace 'A - ' 'B - '); TBB=$(blk trace 'B - ' "A' - A again"); TA2=$(blk trace "A' - A again" '')
TCAT="    DEBUG o.a.coyote.http11.Http11InputBuffer: Received [POST /shutdown HTTP/1.1  - the token on the record's line 5: X-Shutdown-Token: [masked: the trace run's token]"
THM="    TRACE o.s.web.method.HandlerMethod: Arguments: [[masked: the trace run's token], org.springframework.web.context.request.async.StandardServletAsyncWebRequest\$LifecycleHttpServletResponse@…]"
TOK() { printf "  its log, the trace run's token in it: %s · the demo token: 0 · the records that hold the trace run's token (level logger: first line):" "$1"; }
# runs BLOCK OPTION: the part of BLOCK from the command line that ends in OPTION to the next command line that starts a JVM
runs() { printf '%s\n' "$1" | awk -v o="$2" 'index($0, "$ cd .harness/tr") == 1 { f = (substr($0, length($0) - length(o) + 1) == o) } f'; }
x trace "^after/'s application\.yaml, its first document: level: line [0-9]+, under logging: \(line [0-9]+\) · .* · in the first document: yes\$"
for b in "$TB0" "$TA" "$TBB" "$TA2"; do has "$b" "$SEVEN1" "trace: the seven, unchanged at TRACE"; done
printf '%s\n' "$TB0" | grep -q -- ' --logging\.level\.root=trace$' || die "trace before: every logger at TRACE"
has "$TB0" "$(TOK 1)" "trace before: once"; has "$TB0" "$TCAT" "trace before: Tomcat's record"; nhas "$TB0" "$THM" "trace before: no HandlerMethod line"
for b in "$TA" "$TBB" "$TA2"; do [ -n "$(runs "$b" ' --logging.level.root=trace')" ] && [ -n "$(runs "$b" ' --logging.level.web=trace')" ] || die "trace: each of A, B, A' runs every logger at TRACE, then the web group at TRACE"; done
for b in "$TA" "$TA2"; do for o in ' --logging.level.root=trace' ' --logging.level.web=trace'; do r=$(runs "$b" "$o")
  has "$r" "$(TOK 0)" "trace A/A'$o: the token 0 times"; nhas "$r" "$TCAT" "trace A/A'$o: no Tomcat record"; nhas "$r" "$THM" "trace A/A'$o: no HandlerMethod line"; done; done
BR=$(runs "$TBB" ' --logging.level.root=trace'); BW=$(runs "$TBB" ' --logging.level.web=trace')
has "$BR" "$(TOK 2)" "trace B, every logger at TRACE: twice"; has "$BR" "$TCAT" "trace B: Tomcat's record"; has "$BR" "$THM" "trace B: Spring MVC's HandlerMethod line"
has "$BW" "$(TOK 1)" "trace B, the web group at TRACE: once"; has "$BW" "$THM" "trace B, web: HandlerMethod's line"; nhas "$BW" "$TCAT" "trace B, web: Tomcat's logger is not in Boot's web group"
[ "$(printf '%s\n' "$TBB" | grep -c '^    -')" = 3 ] && [ "$(printf '%s\n' "$TBB" | grep -c '^    +')" = 0 ] || die "trace B: three lines deleted from the copy's application.yaml, none added"
for l in '    -  level:' '    -    org.apache.coyote.http11.Http11InputBuffer: info' '    -    org.springframework.web.method.HandlerMethod: info'; do has "$TBB" "$l" "trace B: the copy's diff"; done
has "$TBB" '    built the copy · offline: yes · exit 0' "trace B: the copy built offline"
[ "$TA" = "$TA2" ] || die "trace: A' differs from A"
echo "  trace: the two loggers in application.yaml's first document; the seven 87ca7efc... every run; the trace run's token - the previous tree 1 (Tomcat's Http11InputBuffer); A 0 at root=trace and 0 at web=trace; B (without the three lines) 2 (+ Spring MVC's HandlerMethod) and 1 (HandlerMethod alone: Tomcat's logger is not in the web group); A' = A; the demo token 0"

# "Boot's timer files Ravi and Meera under one series, one counted line: customers slash name. Nobody, and the last course's customers
#  slash seven, land there too, as four oh fours. The encoded slash isn't counted at all"
TI=$(cat .r-timer.out)
hs() { printf '    http_server_requests_seconds_count{error="none",exception="none",method="GET",outcome="%s",status="%s",uri="%s"} %s' "$1" "$2" "$3" "$4"; }
has "$TI" "$(hs SUCCESS 200 '/customers/{name}' 2)" "timer: Ravi and Meera, one series"; has "$TI" "$(hs CLIENT_ERROR 404 '/customers/{name}' 2)" "timer: Nobody and /customers/7, 404s there"
has "$TI" "$(hs SUCCESS 200 /customers 1)" "timer: VEG"; has "$TI" "$(hs CLIENT_ERROR 400 /customers 1)" "timer: veg's 400"
[ "$(aft "\$ $(url "$R_C7" 19360)" "$TI")" = '  404' ] || die "timer: the last course's /customers/7, 404"
has "$TI" "  requests sent: 7 · counted by Boot's timer: 6 · series: 4 · their uri tags: /customers /customers/{name}" "timer: seven sent, six counted"
[ "$(aft "$(QQ 19360 /customers/a%2Fb)" "$TI")" = '  400 text/html;charset=utf-8' ] || die "timer: the encoded slash, Tomcat's 400"
has "$TI" "  WARN lines these requests added, at Boot's default level: 1" "timer: one WARN line, the 400's"
echo "  timer: uri=/customers/{name} 200 x2 and 404 x2 (Nobody, /customers/7); /customers 200 and 400; 7 sent, 6 counted; 1 WARN"

# the exercise's end state: the README's commands, then the solution's, in ONE env -i shell - each leaves the shell in this folder;
# the line exercise/README.md calls "Done" is a line of this capture, after the solution's lines, and of SOLUTION.md's measured run;
# the README's own last line, as shipped, prints the 400
XS=$(blk exercise "the README's" "the solution's"); XE=$(blk exercise "the solution's" '')
l='status: 200 · customers: 1 (Priya) · conversion failure: none'; l0="status: 400 · customers: 0 · conversion failure: Failed to convert value of type 'java.lang.String' to required type 'com.tiffinbox.MealType'"
has "$XE" "    $l" "exercise: the solution"; has "$XS" "    $l0" "exercise: as shipped"
awk '/^\*\*Done\*\*/ { f = 1 } f' exercise/README.md | grep -qxF -- "$l" || die "exercise/README.md: Done names no such line"
grep -qxF -- "$l" exercise/solution/SOLUTION.md || die "SOLUTION.md: the measured run shows no such line"
grep -qF -- "\`$l0\`" exercise/README.md || die "exercise/README.md: the shipped line's answer is not named"
has "$XS" '  exit 0 · what they printed:' "exercise: the README's commands, exit 0"; has "$XE" '  exit 0 · what they printed:' "exercise: the solution's lines, exit 0"
has "$XS" "  the shell is now in: this unit's folder · the copy's own token in its log: 0 times · WARN lines in its log: 1" "exercise: the README's commands leave the shell in this unit's folder, one WARN"
has "$XE" "  the shell is now in: this unit's folder · the copy's own token in its log: 0 times · WARN lines in its log: 0 · listening on 19369 now: 0" "exercise: the solution's lines leave the shell in this unit's folder, nothing logged, nothing listening"
[ "$(printf '%s\n' "$XE" | grep -c '^  \$ export ')" = 2 ] || die "exercise: SOLUTION.md gives the README's two export lines"
echo "  exercise: one env -i shell - the README as written -> 400, 0 customers, the conversion failure its WARN names; the solution's lines -> 200, 1 (Priya), no WARN; the shell in this unit's folder after each"

# "And every form, the jar, the AOT jar, built ahead of time, the native binary and the image, serves the seven and the new routes,
#  on loopback, this computer only."
x forms '^  exit 0 · BUILD SUCCESS · stages it printed: 8 of the 8 it announces · its lines that say the metadata repository was downloaded over http, or failed to: 0 · offline: yes$'
x forms '^  file: Mach-O 64-bit executable · the demo token in its bytes: 0 · the trace run.s: 0$'
x forms '^  Spring.s generated metadata \(spring-aot/main/resources/META-INF/native-image/com\.tiffinbox/tiffinbox-web/reachability-metadata\.json\): reflection entries naming com\.tiffinbox\.Customer: 1 - all declared fields · all declared constructors · 4 methods \(mealType mealsPerDay name pricePerMeal\)$'
x forms '^  Spring.s generated metadata \(spring-aot/main/resources/META-INF/native-image/com\.tiffinbox/tiffinbox-web/reachability-metadata\.json\): reflection entries naming com\.tiffinbox\.MealType: 1 - '
x forms "^four forms, one tree: the seven \(masked\) 4 of 4 times $S87C · Ravi 200 4 of 4 · a name nobody has 404 4 of 4 · VEGAN -> Priya 4 of 4 · vegan 400 4 of 4 · no header 403 4 of 4\$"
x forms '^  loopback, form by form: the jar yes · the AOT jar yes · the binary yes · the image, published on 127\.0\.0\.1 alone yes$'
for t in '1 the jar' '2 the AOT jar' '3 the binary' '4 the image'; do x forms "^$t - "; done
[ "$(n forms "^  Boot's first line: Starting AOT-processed TiffinBoxServer v1\.0\.0 using Java 25\.0\.4\.1\$")" = 2 ] && [ "$(n forms "^  Boot's first line: Starting AOT-processed TiffinBoxServer using Java 25\.0\.4\.1\$")" = 2 ] || die "forms: the AOT jar and the binary, AOT-processed, both starts"
[ "$(n forms '^  inside the container, listening: \[::\]:18425$')" = 2 ] && [ "$(n forms '^  docker port: 18425/tcp -> 127\.0\.0\.1:19367$')" = 2 ] || die "forms: the image, two containers, published on 127.0.0.1 alone"
x forms '^  its lines that say pull: 0 · '
x forms '^  the image saved \(docker save\): [1-9][0-9]* blobs, its [1-9][0-9]* layers among them, each read whole \(gzip ones unpacked\) · the demo token in them: 0$'
echo "  forms: 8 of 8 stages, offline, Mach-O, 0 tokens; Customer and MealType in the AOT step's metadata; the jar, the AOT jar, the binary, the image: the seven 87ca7efc... 4 of 4, the new routes 4 of 4, loopback form by form; the image's layers 0 tokens"

cmp -s after/README.md ../c6-tiffinbox/README.md || echo "  (after/README.md and ../c6-tiffinbox/README.md differ - the anchor has moved past this unit's after/)" >&3
[ -z "$unpub" ] || die "no published hash for:$unpub - check the captures, then copy the md5s above into receipts.md5 and run again"
echo "c6-unit07: every capture 3/3 and = published; every spoken number asserted; 0 raw demo tokens in every capture, every log, the container's log, the image's layers and the binary; nothing of this run left on Docker"
