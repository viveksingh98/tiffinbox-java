#!/bin/bash
XPATH=$PATH                                           # the PATH you started this with: the exercise's own shell gets it
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25.0.4.1 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# GRAALVM_HOME names a GraalVM JDK 25 (README.md, "The GraalVM"): the native build reads it. Without it, this script makes every
# capture that needs no GraalVM, filling .m2-demo on the way, then stops before the native build.
# Course 6 · ProblemDetail and RFC 9457 - this unit's receipts. The anchor changes: application.yaml's first document gets one key,
# spring.mvc.problemdetails.enabled: true, so Spring MVC's own errors - no route, a wrong verb, a request it cannot read or convert,
# a type nobody accepts, a body type it cannot read - are answered by Boot's ProblemDetailsExceptionHandler in RFC 9457's shape,
# application/problem+json; TiffinBoxErrors answers CustomerNotFound with a ProblemDetail (title, detail, the name as a member of
# its own); TiffinBoxServer's 400 (the field map as the member "errors"), 403 and 409 carry problem details. Nine captures, each run
# three times and hashed; cap() DIES when a hash differs from receipts.md5; every number the video says is asserted at the bottom by
# a check that can fail; the demo token is masked (gsub), and the checks count 0 raw copies of it in every capture, in the log of
# every run - the container's included - in every file this unit ships, in the binary and in the image's layers.
#   change      the previous tree against after/: the files that differ, application.yaml's new key and where it sits, Boot's
#               metadata for it, TiffinBoxErrors' and TiffinBoxServer's code lines and their diff, the jar's libraries
#   seven       the seven on both trees, each on a fresh JVM: their hashes, the lines that moved, the WARN line and its logger;
#               who answers, read off the running application (the harness's Who): the ResponseEntityExceptionHandler beans, the
#               advice cache in order, the method each advice has for seven exception types; Spring's ProblemDetail class, read
#   own         TiffinBox's own refusals, then and now: a path nobody maps, a name nobody has, a body that breaks four rules, a
#               misspelt key, POST /shutdown without the token, a new customer twice - on the previous tree and on after/
#   accept      a name nobody has for clients that accept only HTML, only XML, and a browser's whole Accept header (Chrome's), each
#               sent by curl, and a path nobody maps for HTML - on after/ and on the previous tree
#   flag        A/B/A': after/ (A); the key off for one run (B); A again (A'); C, labelled: Spring MVC's log-resolved-exception on -
#               nine requests each, every WARN and ERROR line each added
#   edges       what the key does not reach: a route's unexpected exception (the harness's Boom), for JSON and for HTML; Tomcat's
#               own 400 for an encoded slash; Boot's include-message key, which changes the 500 and not a problem detail
#   losers      the ways not taken: TiffinBoxErrors extending ResponseEntityExceptionHandler with no key (a copy); no key at all (a
#               copy), and two misspellings of it; the body checked with no BindingResult beside it (the harness's ValidIn)
#   exercise    exercise/README.md's commands, then exercise/solution/SOLUTION.md's, read from the files and run as written, one after
#               the other in ONE shell a viewer could have: env -i, /bin/bash, started in this folder
#   forms       the native build of after/; what Spring's AOT step registers, on the previous tree and on after/; then four forms -
#               the jar, the AOT jar, the binary, the image: each one's address, the seven (masked), exit 0; then, on a second start of
#               each, a name nobody has (curl's own Accept, and only HTML), a body that breaks four rules, POST /shutdown without the
#               token, a new customer twice
# "The previous tree" is ../c6-unit15/after (the anchor before this change: the exception-handler lesson's frozen tree), COPIED
# under .harness/before; after/ is this unit's frozen copy of ../c6-tiffinbox after the change, COPIED under .harness/after. This
# script never writes into another unit's folder, and never builds a frozen tree in place. Every run of TiffinBox starts in a folder
# under .harness/ that holds a config tree with a fake token (secrets/), as the README asks - the container's too, mounted read-only.
# Commands are printed exactly as they run: each goes through eval. "$CURLSET" is the comparison set since the secrets lesson
# (../c5-unit11/curlset.sh: the seven requests, POST /shutdown with the token's header read from the file). "$M2" is this unit's
# own repository, .m2-demo. The harness - harness/probe/web/*.java (compiled with -parameters): Boom, ValidIn, Who - the course's,
# never TiffinBox's: outside com.tiffinbox, joined by --spring.main.sources on the extracted jar's class path; harness/shutdown.sh
# (POST /shutdown, the token read from its file); harness/subclass/TiffinBoxErrors.java (the advice as a ResponseEntityExceptionHandler);
# harness/exercise/application.yaml and tiffinbox-local.yaml (the exercise's copy: no key in the first, a misspelt one in the second)
# - is named on every capture that uses it. Every run passes options only. The seven always run on a fresh JVM, first.
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
# string, epoch milliseconds) in the seven and wherever Spring's error body is printed - a problem detail carries none, and the mask
# still runs and counts what it changed; Boot's Whitelabel page is printed as its <h1> and its error line, its created date (the
# JVM's time zone) masked and its paragraph counted, never shown; any other HTML page (Tomcat's own) as its <h1> and its length;
# where a native-image warning names the file it read an option from, the file's URL - or "null" - becomes "…". A run's log lines
# are printed from their logger on (no time, no process id, no thread); Boot's first line is cut before " with PID". A WARN or
# ERROR record is printed as its level, logger and message, then the exception line under it; its stack frames are bounded
# ("over 40") and its other lines counted, never shown. A problem detail is printed as the answer's bytes, never re-ordered. No
# image, container or ID is printed but the base image's digest. No duration is captured: the native build's seconds, and the
# 20-minute bound, go to the terminal only.
# Ports (brief ⚑1, 19450-19459): after/'s jar 19450 · the previous tree 19451 · after/ with the harness joined 19452 · the previous
# tree with the harness joined 19453 · the copy whose advice extends ResponseEntityExceptionHandler 19454 · the copy with no key
# 19455 · the AOT jar 19456 · the image 19457 · the binary 19458 · the exercise 19459. 18425 (TiffinBox's default), 8080 (Tomcat's)
# and 35729 (DevTools' Live Reload) are checked free too, and never bound on this machine (18425 only inside a container).
# Docker names (no unit number): the image tiffinbox-problem:1.0.0 and the container tiffinbox-problem. Each is checked absent before
# the first run - a name already there may be yours, and this script removes only what it creates - and removed on every exit: the
# container with docker rm -f, the image by name and by every ID a build of this run recorded. Docker's build cache is not
# pruned: .dockerignore keeps secrets/ out of every build context, so the cache holds no token.
set -e
# bash 5.2 and later turn an & in the replacement of ${x/pattern/replacement} into the matched text (patsub_replacement, on by
# default). Switched off, so /bin/bash 3.2 (./receipts.sh) and a newer bash (bash receipts.sh) run the same commands; 3.2 has no
# such option.
shopt -u patsub_replacement 2> /dev/null || true
# One locale for every tool, whatever yours is: sort's order, and what a program prints, follow it. The published captures were
# made with no locale set, which is the C locale. The JVM ignores LC_ALL on macOS - it takes the Mac's first language - and Spring's
# and Jackson's messages, Hibernate Validator's and H2's, are written in the JVM's locale: so every JVM this script starts has its
# locale pinned on its run line (-Duser.language=en -Duser.country=US, before -jar or -cp: at() puts it there, README.md "The
# commands this unit adds"), and Who prints it. The binary takes no JVM options (its messages were fixed when it was built).
export LC_ALL=C
cd "$(dirname "$0")"
# One run at a time: two runs share .harness/, the ports and the Docker names, and one would corrupt the other.
mkdir .r-lock 2> /dev/null || { echo "  *** another receipts.sh is running in this folder (.r-lock exists) - if none is, rmdir .r-lock ***"; exit 1; }
IMG=tiffinbox-problem:1.0.0; BOX=tiffinbox-problem
OURS=""                                              # set once the start-up checks found none of the Docker names above
# On every exit - the end, a failed check, or Ctrl-C - stop the processes this script started in the background ($pid, a server;
# $xpid, the exercise's shell, with every process under it - its Maven, its JVM, its curl), if they still run, then sweep(): anything
# of this run still alive in its process group - a TiffinBox JVM, a binary, native-image's driver or builder - is stopped; then
# dclean(): this run's container and image. After an interrupt, a capture's unfinished runs (.r-NAME.1-3) go too; after a failed
# check they stay, for the diff the message names. The clean-up ignores a second Ctrl-C, and nothing in it can fail under set -e, so
# it always reaches the rmdir; the script still exits 130 after an interrupt (README.md, "Interrupted"). $pid and $xpid are cleared
# whenever their process has been reaped. sweep() kills only processes of this run's own process group - start each run in a group
# of its own (README.md, "Interrupted"). No wait in this script is bare: each names its pid.
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
for t in python3 curl rsync lsof unzip javac docker openssl; do command -v $t > /dev/null || die "$t is needed"; done
# A variable of yours must not become a property source, a JVM flag, a build setting, a native-image option or a docker build
# setting: every TIFFINBOX_*, SPRING_*, MANAGEMENT_*, SERVER_*, LOGGING_*, COMPOSE_*, BUILDKIT_* and BUILDX_* variable, DEBUG (Boot
# reads it as --debug), the variables that inject JVM flags, MAVEN_OPTS, MAVEN_ARGS, NATIVE_IMAGE_OPTIONS, DOCKER_BUILDKIT,
# DOCKER_DEFAULT_PLATFORM and SOURCE_DATE_EPOCH are removed first. GRAALVM_HOME stays: it says which GraalVM to use; so do
# DOCKER_HOST and DOCKER_CONTEXT: they say which Docker answers. (SPRING_WEB_ERROR_INCLUDE_MESSAGE of yours would put a message in
# Boot's error body in every capture; SPRING_MVC_PROBLEMDETAILS_ENABLED would answer Spring MVC's own errors another way; SERVER_ADDRESS
# or SERVER_PORT beat the alias; TIFFINBOX_SHUTDOWN_TOKEN the config tree.)
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
PREV=../c6-unit15/after                              # the previous tree: the anchor before this change - read, copied
[ -e secrets ] && die "this folder holds a secrets/ - remove it: every run here starts in a folder under .harness/"
for t in "$PREV" after; do
  [ -f "$t/pom.xml" ] && [ -f "$t/README.md" ] && [ -f "$t/Dockerfile" ] && [ -f "$t/.dockerignore" ] || die "the tree $t (its pom.xml, README.md, Dockerfile or .dockerignore) is missing"
  [ -e "$t/secrets" ] || [ -e "$t/target" ] || [ -e "$t/tiffinbox-web/target" ] || [ -e "$t/tiffinbox-core/target" ] && die "$t holds a secrets/ or a target/ - it is a frozen copy, never built in place"
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
HWS='harness/probe/web/Boom.java harness/probe/web/ValidIn.java harness/probe/web/Who.java'
XYAML=harness/exercise/application.yaml               # the exercise's copy: application.yaml without the key
XLOC=harness/exercise/tiffinbox-local.yaml            # the exercise's copy: a developer's own file, the key misspelt
XSUB=harness/subclass/TiffinBoxErrors.java            # the advice as a ResponseEntityExceptionHandler (losers)
for f in harness/shutdown.sh $XYAML $XLOC $XSUB $HWS exercise/README.md exercise/solution/SOLUTION.md README.md; do [ -f "$f" ] || die "$f is missing"; done
[ "$(ls harness/probe/web | paste -sd' ' -)" = 'Boom.java ValidIn.java Who.java' ] || die "harness/probe/web holds another file: javac compiles all of it"

# The ports and the Docker names, BEFORE anything is wiped (a survivor of an interrupted run answers POST /shutdown only with its
# token, which lives in .harness/ - so the message names the process to kill).
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
for p in 18425 8080 35729 19450 19451 19452 19453 19454 19455 19456 19457 19458 19459; do
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
# POST /shutdown without the token (the secrets lesson's line); the exception-handler lesson's line, a name nobody has; the request-body
# lesson's new customer; the Jackson lesson's two point seven meals; the validation lesson's body that breaks four rules; and this
# unit's line in the anchor's README: the exception-handler lesson's line with curl's Content-Type printed
R_403=$(readme "curl -s -w ' %{http_code}\n' -X POST http://127.0.0.1:18431/shutdown")
R_NOBODY=$(readme "curl -s -w ' %{http_code}\n' http://127.0.0.1:18431/customers/Nobody")
R_POST=$(readme "curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '{\"name\":\"Asha\",\"mealsPerDay\":2,\"pricePerMeal\":110,\"mealType\":\"VEG\"}' http://127.0.0.1:18431/customers")
R_27=$(readme "curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '{\"name\":\"Mohan\",\"mealsPerDay\":2.7,\"pricePerMeal\":110,\"mealType\":\"VEG\"}' http://127.0.0.1:18431/customers")
R_BAD=$(readme "curl -s -w ' %{http_code} · Location: [%header{location}]\n' -H 'Content-Type: application/json' --data '{\"name\":\"\",\"mealsPerDay\":0,\"pricePerMeal\":-5,\"mealType\":\"LUNCH\"}' http://127.0.0.1:18431/customers")
R_PD=$(readme "curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' http://127.0.0.1:18431/customers/Nobody")
WS=" -w ' %{http_code}\n'"; WT=" -w ' %{http_code} · Content-Type: [%{content_type}]\n'"; WL_=" -w ' %{http_code} · Location: [%header{location}]\n'"
r=${R_NOBODY/"$WS"/$WT}; [ "$r" = "$R_PD" ] || die "the anchor's new line must be the exception-handler lesson's line with curl's Content-Type printed, and nothing else"
P_='/customers/Ravi'; Q_='/customers/Nobody'; r=${R_ONE/"$P_"/$Q_}; [ "$r" = "$R_NOBODY" ] || die "the exception-handler lesson's line must be the one-customer line with the name Nobody"
# the request bodies, read off the README's lines: a new customer, two point seven meals, four rules broken
bodyof() { local b=${1#*--data \'}; printf '%s\n' "${b%%\' http://*}"; }
B_ASHA=$(bodyof "$R_POST"); B_27=$(bodyof "$R_27"); B_BAD=$(bodyof "$R_BAD")
[ "$B_ASHA" = '{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' ] && [ "$B_BAD" = '{"name":"","mealsPerDay":0,"pricePerMeal":-5,"mealType":"LUNCH"}' ] || die "the request bodies"
r=${R_BAD/"$WL_"/$WS}; P_="$B_BAD"; r=${r/"$P_"/$B_ASHA}; [ "$r" = "$R_POST" ] || die "the validation lesson's line must be the request-body lesson's line with its body and its -w changed"
# two more, made from those (README.md, "The commands this unit adds"): the body cut after its first key - JSON nobody can read - and
# Asha's body with its meal type's key misspelt
B_CUT=${B_ASHA%%\"Asha\"*}; P_='"mealType"'; Q_='"mealTyp"'; B_TYPO=${B_ASHA/"$P_"/$Q_}
[ "$B_CUT" = '{"name":' ] && [ "$B_TYPO" = '{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealTyp":"VEG"}' ] || die "the cut and misspelt bodies"
# This unit's own lines (README.md, "The commands this unit adds") - each asserted to be exactly that: the anchor's run and class-path
# lines with the JVM's locale pinned, and the run line with one option more (the key off; Spring MVC's log-resolved-exception; Boot's
# include-message; the key's two misspellings); the harness's javac line, against after/'s extracted jar, with -parameters; the anchor's
# new line with one Accept header - a browser's type alone, XML alone, and a browser's whole header (Chrome's); the request-body
# lesson's line with curl's Content-Type printed
mine() { grep -m1 -xF -- "$1" README.md > /dev/null || die "README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
L_RUNL=$(mine 'java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431')
L_CPL=$(mine 'java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431')
L_OFF=$(mine "$L_RUNL --spring.mvc.problemdetails.enabled=false")
L_LRE=$(mine "$L_RUNL --spring.mvc.log-resolved-exception=true")
L_MSG=$(mine "$L_RUNL --spring.web.error.include-message=always")
L_SING=$(mine "$L_RUNL --spring.mvc.problemdetail.enabled=true")
L_DASH=$(mine "$L_RUNL --spring.mvc.problem-details.enabled=true")
for l_ in "$L_OFF" "$L_LRE" "$L_MSG" "$L_SING" "$L_DASH"; do o_=${l_#"$L_RUNL "}; case $o_ in --*=*) ;; *) die "a run line with one option more: $l_" ;; esac; [ "${o_#* }" = "$o_" ] || die "one option, no more: $l_"; done
O_OFF=${L_OFF#"$L_RUNL "}; O_LRE=${L_LRE#"$L_RUNL "}; O_MSG=${L_MSG#"$L_RUNL "}; O_SING=${L_SING#"$L_RUNL "}; O_DASH=${L_DASH#"$L_RUNL "}
L_JAVAC=$(mine 'javac -parameters -d .harness/hc -cp ".harness/after/tiffinbox-web/target/extracted/lib/*:.harness/after/tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar" harness/probe/web/Boom.java harness/probe/web/ValidIn.java harness/probe/web/Who.java')
CHROME='text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7'
L_HTML=$(mine "curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html' http://127.0.0.1:18431/customers/Nobody")
L_XML=$(mine "curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: application/xml' http://127.0.0.1:18431/customers/Nobody")
L_CHROME=$(mine "curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: $CHROME' http://127.0.0.1:18431/customers/Nobody")
L_POSTT=$(mine "curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Content-Type: application/json' --data '{\"name\":\"Asha\",\"mealsPerDay\":2,\"pricePerMeal\":110,\"mealType\":\"VEG\"}' http://127.0.0.1:18431/customers")
P_='java '; Q_='java -Duser.language=en -Duser.country=US '; r=${R_RUN/"$P_"/$Q_}; r2=${R_CP/"$P_"/$Q_}
[ "$r" = "$L_RUNL" ] && [ "$r2" = "$L_CPL" ] || die "the pinned lines must be the anchor's run and class-path lines with -Duser.language=en -Duser.country=US after java, and nothing else"
[ "${L_JAVAC#* -cp \"*\" }" = "$HWS" ] || die "the harness's javac line must compile the three files in harness/probe/web, and nothing else"
for t in "text/html:$L_HTML" "application/xml:$L_XML" "$CHROME:$L_CHROME"; do a_=${t%%:*}; l_=${t#*:}
  P_=" -H 'Accept: $a_'"; r=${l_/"$P_"/}; [ "$r" = "$R_PD" ] || die "an Accept line must be the anchor's new line with one Accept header, and nothing else: $l_"; done
r=${R_POST/"$WS"/$WT}; [ "$r" = "$L_POSTT" ] || die "the POST line must be the request-body lesson's with curl's Content-Type printed, and nothing else"
# off DIR 'README mvn LINE' [PHASE]: the README's Maven line as this script runs it - from DIR, offline (-o), this unit's own
# repository, and for a build phase (package, install) clean and without tests. dev() takes those four things back out, and
# must give the README's line again: so the command on screen is the README's, with exactly those changes.
off() { local c=${2/mvn -B /mvn -o -B -Dmaven.repo.local=\"\$M2\" }
  [ -n "$3" ] && c=${c/ $3/ -DskipTests clean $3}
  printf 'cd %s && %s\n' "$1" "$c"; }
dev() { local c=${1#cd * && }; c=${c/ -o -B -Dmaven.repo.local=\"\$M2\" / -B }; c=${c/ -DskipTests clean / }; printf '%s\n' "$c"; }
# at DIR PORT 'README LINE': the README's line run from DIR, its port 18431 made PORT - and a java line with the JVM's locale pinned
# right after "java" (JL: this unit's two pinned lines show the form, and at() must give them back)
JL='-Duser.language=en -Duser.country=US'
at() { local l=${3/--tiffinbox.port=18431/--tiffinbox.port=$2}; case $l in 'java '*) l="java $JL ${l#java }" ;; esac; printf 'cd %s && %s\n' "$1" "$l"; }
# atl DIR PORT 'THIS UNIT'S RUN LINE': one of this unit's pinned run lines (L_*), run from DIR, its port made PORT
atl() { printf 'cd %s && %s\n' "$1" "${3/--tiffinbox.port=18431/--tiffinbox.port=$2}"; }
# hcp DIR PORT CLASSES ['OPTIONS']: the README's class-path line - the extracted jar, TiffinBox's own main - from DIR, its port made
# PORT, the harness's classes added to the class path (../hc) and CLASSES joined (--spring.main.sources=); OPTIONS after
hcp() { local c; c=$(at "$1" "$2" "$R_CP"); c=${c/lib\/\*\"/lib\/*:..\/hc\"}; printf '%s --spring.main.sources=%s%s\n' "$c" "$3" "${4:+ $4}"; }
# url 'README curl LINE' PORT: the README's curl line, its port 18431 made PORT
url() { printf '%s\n' "${1/:18431\//:$2/}"; }
# qurl PORT PATH: the URL; one that holds a character the shell reads (; ? & * { } or a space) is single-quoted, so eval hands it to
# curl whole
qurl() { local u="http://127.0.0.1:$1$2"; case $2 in *[\;\?\&\*\{\}\ ]*) u="'$u'" ;; esac; printf '%s\n' "$u"; }
# bc PORT PATH: the path-variable lesson's one-customer line (the anchor's README) - the body and the status - the same way
bc() { local c=${R_ONE% http://*}; printf '%s %s\n' "$c" "$(qurl "$1" "$2")"; }
# tq PORT PATH ['ACCEPT']: the anchor's new line - the body, the status and curl's Content-Type - its path PATH, and, when given, one
# Accept header (as this unit's Accept lines add it); with none, curl's own Accept: */*
tq() { local c=${R_PD% http://*} h=""; [ -z "${3:-}" ] || h=" -H 'Accept: $3'"; printf '%s%s %s\n' "$c" "$h" "$(qurl "$1" "$2")"; }
# pq PORT 'BODY' ['CONTENT-TYPE']: this unit's POST line - the request-body lesson's with Content-Type printed - its body BODY, and
# its Content-Type header CONTENT-TYPE when given (a form's: the 415)
pq() { local c=${L_POSTT/:18431\//:$1/} P_="$B_ASHA" Q_="$2"; c=${c/"$P_"/$Q_}; if [ -n "${3:-}" ]; then P_="-H 'Content-Type: application/json'"; Q_="-H 'Content-Type: $3'"; c=${c/"$P_"/$Q_}; fi; printf '%s\n' "$c"; }
# xq PORT: POST /shutdown without the token - the secrets lesson's line - with curl's Content-Type printed
xq() { local r=${R_403/"$WS"/$WT}; url "$r" "$1"; }
# exe 'COMMAND': the command with "exec" after its "cd DIR && " and any NAME=value before the program - so $pid is the program's
exe() { printf '%s\n' "$1" | sed -E 's/&& (([A-Z_]+=[^ ]* )*)/\&\& \1exec /'; }
# The docker lines, as this script runs them: the README's build line with plain progress and this script's own tag; its run line
# with this script's own name and tag, the port published on 127.0.0.1 made PORT, and your user and group added - the config tree
# is yours, mode 0600 (R.74). undock() takes those changes back out, and must give the README's lines again.
UARG='--user "$(id -u):$(id -g)"'
dbuild() { local c=${R_DBUILD/docker build -t tiffinbox-docker:1.0.0 /docker build --progress=plain -t $IMG }; printf 'cd %s && %s\n' "$1" "$c"; }
drun() { local c=${R_DRUN/--name tiffinbox /--name $BOX $UARG }; c=${c/127.0.0.1:18431:18425/127.0.0.1:$2:18425}; c=${c/% tiffinbox-docker:1.0.0/ $IMG}; printf 'cd %s && %s\n' "$1" "$c"; }
undock() { local c=${1#cd * && }; c=${c/--progress=plain /}; c=${c/" $UARG"/}; c=${c//$IMG/tiffinbox-docker:1.0.0}; c=${c/--name $BOX /--name tiffinbox }; c=${c/127.0.0.1:1945?:18425/127.0.0.1:18431:18425}; printf '%s\n' "$c"; }
[ "$(undock "$(dbuild .harness/x)")" = "$R_DBUILD" ] || die "not the README's build line with the declared changes: $(dbuild .harness/x)"
[ "$(undock "$(drun .harness/x 19457)")" = "$R_DRUN" ] || die "not the README's run line with the declared changes: $(drun .harness/x 19457)"
C_PRE=$(off .harness/pre "$R_INSTALL" install)
for c in "$C_PRE" "$(off .harness/x "$R_PLAIN" package)" "$(off .harness/x "$R_PNAT" package)" "$(off .harness/x "$R_NATIVE")"; do
  r=$(dev "$c"); [ "$r" = "$R_PLAIN" ] || [ "$r" = "$R_PNAT" ] || [ "$r" = "$R_INSTALL" ] || [ "$r" = "$R_NATIVE" ] || die "not a README line with the offline changes: $c"; done
[ "$(exe "$(at .harness/x 19450 "$R_RUN")")" = 'cd .harness/x && exec java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19450' ] || die "exe()"
[ "$(at .harness/x 18431 "$R_RUN")" = "cd .harness/x && $L_RUNL" ] && [ "$(at .harness/x 18431 "$R_CP")" = "cd .harness/x && $L_CPL" ] && [ "$(at .harness/x 19458 "$R_BIN")" = 'cd .harness/x && tiffinbox-web/target/tiffinbox-web --tiffinbox.port=19458' ] && [ "$(atl .harness/x 18431 "$L_OFF")" = "cd .harness/x && $L_OFF" ] || die "at(): the pinned lines are not README.md's, or the binary's line got the JVM's options"
[ "$(hcp .harness/x 19452 probe.web.Who "$O_MSG")" = 'cd .harness/x && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19452 --spring.main.sources=probe.web.Who --spring.web.error.include-message=always' ] || die "hcp()"
[ "$(tq 18431 /customers/Nobody)" = "$R_PD" ] && [ "$(tq 18431 /customers/Nobody text/html)" = "$L_HTML" ] && [ "$(pq 18431 "$B_ASHA")" = "$L_POSTT" ] && [ "$(tq 19450 '/customers?mealType=veg')" = "curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' 'http://127.0.0.1:19450/customers?mealType=veg'" ] || die "tq() or pq()"
[ "$(pq 19450 "$B_ASHA" application/x-www-form-urlencoded)" = "curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Content-Type: application/x-www-form-urlencoded' --data '$B_ASHA' http://127.0.0.1:19450/customers" ] && [ "$(xq 19450)" = "curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -X POST http://127.0.0.1:19450/shutdown" ] || die "pq() with a form's type, or xq()"
echo "  the commands: after/README.md gives all 20 lines this script runs or derives from; README.md the 12 this unit adds"
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
HCP0=".harness/pre/tiffinbox-web/target/extracted/lib/*:.harness/pre/tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar"
javac -parameters -d .harness/hc -cp "$HCP0" $HWS > .harness/javac.log 2>&1 || { cat .harness/javac.log >&3; die "the harness did not compile against after/'s jar"; }
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
  case " $l " in *':8080 '*|*':35729 '*) kill -9 "$pid" 2> /dev/null || true; die "it listened on 8080 or 35729 - never bound by this script";; esac
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
# timestamp mask, how many lines the mask changed, and the form of the timestamps it hid; the log counted (logtok)
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
    gsub(Q, "…/.."); gsub(QE, "…/.."); gsub(H, "~"); gsub(/\$\$SpringCGLIB\$\$[0-9]+/, "$$SpringCGLIB$$<n>")
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
  if [ -z "$pub" ]; then printf '  %-11s md5 %s  3/3  (no published hash)\n' "$nm" "$h"; unpub="$unpub $nm"
  elif [ "$pub" = "$h" ]; then printf '  %-11s md5 %s  3/3  = published\n' "$nm" "$h"
  else printf '  %-11s md5 %s  3/3  DIFFERS from the published %s\n' "$nm" "$h" "$pub"
    die "$nm is not the published capture - suspect another JDK, GraalVM, Boot, Maven or Docker, another base image, a busy machine, a busy port, a variable of yours, or an edited source; diff .r-$nm.out against its block in README.md"; fi; }
copy() { rm -rf "$2" "$2".*; rsync -a --exclude target --exclude secrets "$1/" "$2/"; tree "$2"; }
pbuild() { local c; c=$(off "$1" "${3:-$R_PLAIN}" package); echo "\$ $c"; mbuild "$c" "$1.build.log" "$2"; }
# code FILE: a Java file's lines that are neither comment nor blank
code() { grep -vE '^[[:space:]]*(\*|/\*\*|\*/|//|$)' "$1"; }
lines() { if [ -f "$1" ]; then wc -l < "$1" | tr -d ' '; else echo none; fi; }
libs() { unzip -Z1 "$1" | grep -E '^BOOT-INF/lib/.*\.jar$' | sed 's#^BOOT-INF/lib/##' | sort; }
extract() { local c="cd $1 && $R_EXTRACT"; echo "\$ $c"; (eval "$c") > .harness/extract.log 2>&1 < /dev/null || die "the README's extract line failed in $1"; echo "  exit 0"; }
# settle: the log stops growing (the same length twice, 0.5 s apart; up to 15 s) - a request's last line is written just after
# its answer leaves
settle() { local i=0 a b=-1; while [ $i -lt 30 ]; do a=$(wc -l < .harness/run.out | tr -d ' '); [ "$a" = "$b" ] && return 0; b=$a; sleep 0.5; i=$((i + 1)); done; die "the log never settled"; }
mark() { settle; wc -l < .harness/run.out | tr -d ' '; }
# logl FROM [LEVELS]: the run's lines after line FROM at those levels (WARN|ERROR unless named), from their level and logger on
logl() { awk -v from="$1" -v lv="${2:-WARN|ERROR}" 'NR > from && $0 ~ (" (" lv ") [0-9]+ --- \\[") { l = $2; s = $0; i = index(s, " --- ["); s = substr(s, i + 6); i = index(s, "] "); s = substr(s, i + 2)
    i = index(s, " : "); lg = substr(s, 1, i - 1); sub(/ +$/, "", lg); msg = substr(s, i + 3)
    gsub(/@[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]+/, "@…", msg); print "    " l " " lg ": " msg }' .harness/run.out; }
# recs FROM: each WARN or ERROR record the log gained after line FROM - its level, its logger and its message; then the exception line
# under it (the first line after the record that is neither blank nor a stack frame); its stack frames, bounded ("over 40"), and its
# other lines, counted - none shown
recs() { awk -v from="$1" '
  function out() { if (inr) print "      its stack frames: " (fr > 40 ? "over 40" : fr + 0) ", its other lines: " (ot + 0) " - none shown"; inr = 0; fr = 0; ot = 0; ex = 0 }
  NR <= from { next }
  / [A-Z]+ [0-9]+ --- \[/ { out() }
  / (WARN|ERROR) [0-9]+ --- \[/ { s = $0; i = index(s, " --- ["); s = substr(s, i + 6); i = index(s, "] "); s = substr(s, i + 2)
    i = index(s, " : "); lg = substr(s, 1, i - 1); sub(/ +$/, "", lg); m = substr(s, i + 3); gsub(/@[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]+/, "@…", m)
    print "    " $2 " " lg ": " m; inr = 1; ex = 1; next }
  inr && /^\tat / { fr++; next }
  inr && ex && NF > 0 { print "      " $0; ex = 0; next }
  inr { ot++ }
  END { out() }' .harness/run.out; }
# pagef: a curl answer through its filter - Boot's Whitelabel page (an HTML answer) printed as its <h1> and its error line, its created
# date masked and its paragraph counted, never shown; any other HTML page (Tomcat's own) as its <h1> and its length, never shown; curl's
# status line after it; a JSON answer - a problem detail too - as it came, its error timestamp masked
pagef() { python3 -c '
import re, sys
for l in sys.stdin.read().splitlines():
    if l.startswith("<html>") or l.lower().startswith("<!doctype html"):
        h = re.search(r"<h1>(.*?)</h1>", l); e = re.search(r"<div>(There was an unexpected error .*?)</div>", l); c = re.search(r"<div id=.created.>[^<]*</div>", l)
        tail = l[l.index("</html>") + len("</html>"):] if "</html>" in l else ""
        ps = len(re.findall(r"<p>", l))
        if l.startswith("<html>") and h and e and c and tail:
            print("  the Whitelabel page (Boot'"'"'s) - its <h1>: %s · its error line: %s · its created date: masked · its paragraphs: %d, not shown · then curl'"'"'s:%s" % (h.group(1), e.group(1), ps, tail))
        else: print("  an HTML page, not the Whitelabel page - its <h1>: %s · %d characters, not shown%s" % (h.group(1) if h else "none", len(l) - len(tail), " · then curl'"'"'s:" + tail if tail else ""))
    else:
        print("  " + re.sub(r"\"timestamp\":[0-9]+", "\"timestamp\":…", re.sub(r"\"timestamp\":\"[^\"]*\"", "\"timestamp\":\"…\"", l)))'; }
# rq 'COMMAND' [nolog]: a curl line, printed and run, its answer through pagef; then - unless nolog - the WARN and ERROR lines the
# request added, counted on the answer's last line, and each record (recs)
rq() { local n0 w e; [ -n "${2:-}" ] || n0=$(mark); echo "\$ $1"; (eval "$1") 2>&1 < /dev/null | pagef > .harness/ask.txt
  if [ -n "${2:-}" ]; then cat .harness/ask.txt; return 0; fi
  settle; w=$(logl "$n0" WARN | grep -c . || true); e=$(logl "$n0" ERROR | grep -c . || true)
  awk -v w="$w" -v e="$e" '{ l[NR] = $0 } END { for (i = 1; i <= NR; i++) print l[i] (i == NR ? " · WARN lines it added: " w " · ERROR lines: " e : "") }' .harness/ask.txt
  [ "$w$e" = 00 ] || recs "$n0"; }
# ask PORT PATH: the one-customer line, its path PATH, through rq; hq 'LINE' PORT: one of this unit's Accept lines at PORT, through rq
ask() { rq "$(bc "$1" "$2")"; }
hq() { rq "$(url "$1" "$2")" "${3:-}"; }
# dbg FROM: every line the log gained after line FROM, from its logger on (logger: message); dreq 'COMMAND': at DEBUG - the command
# printed and run, its answer (the timestamp masked), then every line the log gained for it, counted
dbg() { awk -v from="$1" 'NR > from && / [A-Z]+ [0-9]+ --- \[/ { s = $0; i = index(s, " --- ["); s = substr(s, i + 6); i = index(s, "] "); s = substr(s, i + 2)
    i = index(s, " : "); lg = substr(s, 1, i - 1); sub(/ +$/, "", lg); m = substr(s, i + 3); gsub(/timestamp=[^,]*,/, "timestamp=…,", m); print "    " lg ": " m }' .harness/run.out; }
dreq() { local n0 k; n0=$(mark); echo "\$ $1"; (eval "$1") 2>&1 < /dev/null | tsmask | sed 's/^/  /'; settle
  k=$(dbg "$n0" | grep -c . || true); echo "  the lines the log gained for it, Boot's web group at DEBUG (logger: message) - all $k:"; dbg "$n0"; }
# blkraw FROM TO: this capture so far, the lines after the line that starts with FROM, up to the next line that starts with TO (to
# the end when TO is empty); asame A B A2 B2: yes when A's block (A up to B) and A2's (A2 up to B2), their labels aside, are the same
# line for line - an A' against its A
blkraw() { awk -v a="$1" -v b="$2" 'index($0, a) == 1 { f = 1; next } b != "" && index($0, b) == 1 { f = 0 } f' .harness/cap.raw; }
asame() { [ "$(blkraw "$1" "$2")" = "$(blkraw "$3" "$4")" ] && [ -n "$(blkraw "$3" "$4")" ] && echo yes || echo no; }
WARNS() { echo "  WARN lines in this run's log, at Boot's default level: $(logl 0 WARN | grep -c . || true) · ERROR lines: $(logl 0 ERROR | grep -c . || true)"; }
# ---- change: one key, a problem detail of TiffinBox's own, and the 400, 403 and 409 -----------------------------------------
cdiff() { diff -U0 "$1" "$2" | tail -n +3 > .harness/code.diff || true
  echo "  its code lines' diff (diff -U0 of the lines above, its file names cut) - hunks: $(grep -c '^@@ ' .harness/code.diff || true) · lines out: $(grep -c '^-' .harness/code.diff || true) · in: $(grep -c '^+' .harness/code.diff || true) - whole:"
  sed 's/^/    /' .harness/code.diff; }
YML=tiffinbox-web/src/main/resources/application.yaml
# meta JAR KEY: Boot's configuration metadata for KEY, read off the jar's own META-INF/spring-configuration-metadata.json
meta() { unzip -p "$1" META-INF/spring-configuration-metadata.json | python3 -c '
import json, sys
k = sys.argv[1]; d = json.load(sys.stdin)
p = [x for x in d.get("properties", []) if x["name"] == k]
if len(p) != 1: print("  %s: %d entries" % (k, len(p))); sys.exit(0)
p = p[0]; print("  %s - type %s · default %s · %s" % (k, p["type"].rsplit(".", 1)[-1], json.dumps(p.get("defaultValue")), p.get("description", "")))' "$2"; }
change() { local f n m k kl dl
  echo "the previous tree and after/, both copied under .harness/ with a config tree, each built with the README's line (offline):"
  copy "$PREV" .harness/before; copy after .harness/after
  pbuild .harness/before "the previous tree"; pbuild .harness/after "after/"
  echo "both jars extracted (the README's line) - the class path the harness runs on:"
  extract .harness/before; extract .harness/after
  echo "the harness, compiled against after/'s own jar - with -parameters:"
  echo "\$ $L_JAVAC"; rm -rf .harness/hc; (eval "$L_JAVAC") > .harness/javac.log 2>&1 < /dev/null || { cat .harness/javac.log >&3; die "the harness did not compile against after/'s jar"; }
  echo "  exit 0 · its classes: $(cd .harness/hc && find . -name '*.class' | sed 's#^\./##' | sort | paste -sd' ' -)"
  echo "the files that differ, and the files only one tree has:"
  echo "\$ diff -rq -x target -x secrets .harness/before .harness/after"
  diff -rq -x target -x secrets .harness/before .harness/after | sed 's/^/  /' || true
  (cd after && find . -type f | sed 's#^\./##' | sort) > .harness/files.txt
  n=0; m=0; k=0; while IFS= read -r f; do m=$((m + 1)); if [ ! -e ".harness/before/$f" ]; then k=$((k + 1)); elif cmp -s ".harness/before/$f" ".harness/after/$f"; then n=$((n + 1)); fi; done < .harness/files.txt
  echo "  after/'s files: $m · byte for byte the previous tree's: $n · new: $k · those that differ: $((m - n - k))"
  echo "  application.yaml: $(lines ".harness/before/$YML") lines -> $(lines ".harness/after/$YML") · the diff (diff -U0, its file names cut) - whole:"
  diff -U0 ".harness/before/$YML" ".harness/after/$YML" | tail -n +3 | sed 's/^/    /' || true
  kl=$(awk '/^  mvc:$/ { a = NR } a && NR == a + 1 && /^    problemdetails:$/ { b = NR } b && NR == b + 1 && /^      enabled: true$/ { print NR; exit }' ".harness/after/$YML")
  dl=$(grep -nx -- '---' ".harness/after/$YML" | head -1 | cut -d: -f1)
  echo "  the key spring.mvc.problemdetails.enabled: true - its line: ${kl:-none} · the first document ends at line ${dl:-none} (---) · in the first document: $( [ -n "$kl" ] && [ -n "$dl" ] && [ "$kl" -lt "$dl" ] && echo yes || echo no)"
  echo "  Boot's own metadata for it, and for the key that logs what a resolver resolved (spring-boot-webmvc-4.1.1.jar, META-INF/spring-configuration-metadata.json):"
  meta .harness/after/tiffinbox-web/target/extracted/lib/spring-boot-webmvc-4.1.1.jar spring.mvc.problemdetails.enabled
  meta .harness/after/tiffinbox-web/target/extracted/lib/spring-boot-webmvc-4.1.1.jar spring.mvc.log-resolved-exception
  f="$W/TiffinBoxErrors.java"; code ".harness/before/$f" > .harness/fb.txt; code ".harness/after/$f" > .harness/fa.txt
  echo "  TiffinBoxErrors.java: $(lines ".harness/before/$f") lines -> $(lines ".harness/after/$f") · its lines that are neither comment nor blank: $(wc -l < .harness/fb.txt | tr -d ' ') -> $(wc -l < .harness/fa.txt | tr -d ' ') · naming ProblemDetail: $(grep -c 'ProblemDetail' .harness/fb.txt || true) -> $(grep -c 'ProblemDetail' .harness/fa.txt || true) · @ResponseStatus: $(grep -c '@ResponseStatus' .harness/fb.txt || true) -> $(grep -c '@ResponseStatus' .harness/fa.txt || true)"
  cdiff .harness/fb.txt .harness/fa.txt
  f="$W/TiffinBoxServer.java"; code ".harness/before/$f" > .harness/fb.txt; code ".harness/after/$f" > .harness/fa.txt
  echo "  TiffinBoxServer.java: $(lines ".harness/before/$f") lines -> $(lines ".harness/after/$f") · its lines that are neither comment nor blank: $(wc -l < .harness/fb.txt | tr -d ' ') -> $(wc -l < .harness/fa.txt | tr -d ' ') · naming ProblemDetail: $(grep -c 'ProblemDetail' .harness/fb.txt || true) -> $(grep -c 'ProblemDetail' .harness/fa.txt || true) · naming \"forbidden\": $(grep -c '"forbidden"' .harness/fb.txt || true) -> $(grep -c '"forbidden"' .harness/fa.txt || true)"
  cdiff .harness/fb.txt .harness/fa.txt
  diff .harness/before/README.md .harness/after/README.md > .harness/file.diff || true
  echo "  README.md - the anchor's README: lines added $(grep -c '^> ' .harness/file.diff || true), removed $(grep -c '^< ' .harness/file.diff || true) - its new section and the history notes the change made false (not shown)"
  libs .harness/before/$JARP > .harness/lb.txt; libs .harness/after/$JARP > .harness/la.txt
  echo "the executable jar's BOOT-INF/lib: $(wc -l < .harness/lb.txt | tr -d ' ') jars -> $(wc -l < .harness/la.txt | tr -d ' ') · the same names: $(cmp -s .harness/lb.txt .harness/la.txt && echo yes || echo no)"
  unzip -Z1 .harness/before/$JARP | grep '^BOOT-INF/classes/com/tiffinbox/web/.*\.class$' | sed 's#.*/##' | sort > .harness/cb.txt || true
  unzip -Z1 .harness/after/$JARP | grep '^BOOT-INF/classes/com/tiffinbox/web/.*\.class$' | sed 's#.*/##' | sort > .harness/ca.txt || true
  echo "the classes in the jar's com/tiffinbox/web: $(wc -l < .harness/cb.txt | tr -d ' ') -> $(wc -l < .harness/ca.txt | tr -d ' ') · the same names: $(cmp -s .harness/cb.txt .harness/ca.txt && echo yes || echo no)"; }

# ---- seven: the comparison set on both trees; the lines that moved; who answers ------------------------------------------------
# moved BEFORE AFTER: the two masked sets, line by line - each line that differs, before and after; the numbers of those that do not
moved() { python3 - "$1" "$2" <<'PY'
import sys
a = open(sys.argv[1]).read().splitlines(); b = open(sys.argv[2]).read().splitlines()
assert len(a) == len(b) == 7, (len(a), len(b))
d = [i for i in range(7) if a[i] != b[i]]; s = [i for i in range(7) if a[i] == b[i]]
print("  lines that differ: %d (%s) · the same, byte for byte: %d (%s)" % (len(d), " ".join(str(i + 1) for i in d), len(s), " ".join(str(i + 1) for i in s)))
for i in d:
    print("    line %d, the previous tree: %s" % (i + 1, a[i]))
    print("    line %d, after/:            %s" % (i + 1, b[i]))
PY
}
sevens() {
  echo "the seven - the previous tree, the README's run line, port 19451, a fresh JVM:"
  start "$(at .harness/before 19451 "$R_RUN")"; up 19451; ready 19451; seven 19451 .harness/before; cp .harness/responses.m.txt .harness/seven-before.txt
  WARNS; logl 0 WARN
  echo "the seven - after/, the README's run line, port 19450, a fresh JVM:"
  start "$(at .harness/after 19450 "$R_RUN")"; up 19450; ready 19450; seven 19450 .harness/after; cp .harness/responses.m.txt .harness/seven-after.txt
  WARNS; logl 0 WARN
  echo "the lines that moved - the previous tree's seven against after/'s, masked, line for line:"
  moved .harness/seven-before.txt .harness/seven-after.txt
  echo "who answers - after/ with the harness's Who joined, port 19452 - read off the running application:"
  start "$(hcp .harness/after 19452 probe.web.Who)"; up 19452; ready 19452
  ask 19452 /probe/who/advice; ask 19452 /probe/who/problem
  stop 19452 .harness/after
  echo "the previous tree with Who joined, port 19453:"
  start "$(hcp .harness/before 19453 probe.web.Who)"; up 19453; ready 19453
  ask 19453 /probe/who/advice
  stop 19453 .harness/before; }

# ---- own: TiffinBox's own refusals, then and now ------------------------------------------------------------------------------------
ownq() { rq "$(tq "$1" /nowhere)"; rq "$(tq "$1" /customers/Nobody)"; rq "$(pq "$1" "$B_BAD")"; rq "$(pq "$1" "$B_TYPO")"; rq "$(xq "$1")"
  rq "$(pq "$1" "$B_ASHA")"; rq "$(pq "$1" "$B_ASHA")"; WARNS; }
own() {
  echo "the previous tree - a path nobody maps, a name nobody has, a body that breaks four rules, a misspelt key, POST /shutdown without the token, a new customer twice - port 19451:"
  start "$(at .harness/before 19451 "$R_RUN")"; up 19451; ready 19451; ownq 19451; stop 19451 .harness/before
  echo "after/ - the same seven requests, port 19450:"
  start "$(at .harness/after 19450 "$R_RUN")"; up 19450; ready 19450; ownq 19450; stop 19450 .harness/after; }

# ---- accept: what a client that accepts something else gets ------------------------------------------------------------------------
accq() { hq "$L_HTML" "$1"; hq "$L_XML" "$1"; hq "$L_CHROME" "$1"; rq "$(tq "$1" /nowhere text/html)"; WARNS; }
accept() {
  echo "after/ - a name nobody has, asked by three clients, each sent by curl: one that accepts only HTML (a browser's type), one that accepts only XML, and a browser's whole Accept header (Chrome's); then a path nobody maps, for HTML - port 19450:"
  start "$(at .harness/after 19450 "$R_RUN")"; up 19450; ready 19450; accq 19450; stop 19450 .harness/after
  echo "the previous tree - the same four, port 19451:"
  start "$(at .harness/before 19451 "$R_RUN")"; up 19451; ready 19451; accq 19451; stop 19451 .harness/before; }

# ---- flag: A/B/A' - the key on, off, on; C, labelled - Spring MVC's log-resolved-exception -------------------------------------------
flagq() { rq "$(tq "$1" /nowhere)"; rq "$(tq "$1" /shutdown)"; rq "$(tq "$1" '/customers?mealType=veg')"; rq "$(pq "$1" "$B_CUT")"; rq "$(pq "$1" "$B_27")"
  rq "$(pq "$1" "$B_ASHA" application/x-www-form-urlencoded)"; rq "$(tq "$1" /customers application/xml)"; rq "$(tq "$1" /customers/Nobody)"; rq "$(pq "$1" "$B_BAD")"; WARNS; }
flag() {
  echo "A - after/, the README's run line, port 19450 - nine requests: Spring MVC's own errors, then TiffinBox's own two:"
  start "$(at .harness/after 19450 "$R_RUN")"; up 19450; ready 19450; flagq 19450; stop 19450 .harness/after
  echo "B - after/ with the key off for this run (this unit's line), port 19450:"
  start "$(atl .harness/after 19450 "$L_OFF")"; up 19450; ready 19450; flagq 19450; stop 19450 .harness/after
  echo "A' - A again, on a fresh JVM:"
  start "$(at .harness/after 19450 "$R_RUN")"; up 19450; ready 19450; flagq 19450; stop 19450 .harness/after
  echo "A' against A, its label aside, line for line the same: $(asame 'A - after/' 'B - after/' "A' - A again" "A' against A")"
  echo "C (labelled) - A with Spring MVC's log-resolved-exception on for this run (this unit's line), port 19450:"
  start "$(atl .harness/after 19450 "$L_LRE")"; up 19450; ready 19450; flagq 19450; stop 19450 .harness/after; }

# ---- edges: what the key does not reach ----------------------------------------------------------------------------------------------
edges() {
  echo "after/ with the harness's Boom joined - a route that throws what nobody handles - port 19452:"
  start "$(hcp .harness/after 19452 probe.web.Boom)"; up 19452; ready 19452
  rq "$(tq 19452 /probe/boom)"; rq "$(tq 19452 /probe/boom text/html)"; rq "$(tq 19452 /customers/a%2Fb)"; rq "$(tq 19452 /nowhere)"
  WARNS; stop 19452 .harness/after
  echo "the same, with Boot's include-message key on for this run (this unit's line's option), port 19452:"
  start "$(hcp .harness/after 19452 probe.web.Boom "$O_MSG")"; up 19452; ready 19452
  rq "$(tq 19452 /probe/boom)"; rq "$(tq 19452 /nowhere)"
  WARNS; stop 19452 .harness/after
  echo "a path nobody maps, without the key and with it, the same bytes: $( [ "$(blkraw "after/ with the harness's Boom" "the same, with Boot's" | grep -A1 -F -- "\$ $(tq 19452 /nowhere)" | sed -n 2p | sed 's/ · WARN lines.*//')" = "$(blkraw "the same, with Boot's" "a path nobody maps" | grep -A1 -F -- "\$ $(tq 19452 /nowhere)" | sed -n 2p | sed 's/ · WARN lines.*//')" ] && echo yes || echo no)"; }

# ---- losers: the ways not taken ----------------------------------------------------------------------------------------------------------
# nokey FILE OUT: after/'s application.yaml without the key's block - its comment and its three lines - the planted copy (exactly one
# block, or it dies)
nokey() { python3 - "$1" "$2" <<'PY' || die "nokey: the key's block is not in $1 exactly once"
import sys
s = open(sys.argv[1]).read(); a = "  # Course 6: Spring MVC's own errors"; b = "  mvc:\n    problemdetails:\n      enabled: true\n"
assert s.count(a) == 1 and s.count(b) == 1 and s.index(a) < s.index(b)
i = s.index(a); j = s.index(b) + len(b); open(sys.argv[2], "w").write(s[:i] + s[j:])
PY
}
lq() { rq "$(tq "$1" /nowhere)"; rq "$(tq "$1" /shutdown)"; rq "$(tq "$1" '/customers?mealType=veg')"; rq "$(pq "$1" "$B_CUT")"; rq "$(tq "$1" /customers/Nobody)"; rq "$(pq "$1" "$B_BAD")"; }
losers() {
  echo "after/ with the harness's Who and ValidIn joined, port 19452 - the advice cache, six answers, then a body checked with no BindingResult beside it:"
  start "$(hcp .harness/after 19452 probe.web.Who,probe.web.ValidIn)"; up 19452; ready 19452
  ask 19452 /probe/who/advice; lq 19452
  rq "$(pq 19452 "$B_BAD" | sed 's#/customers$#/probe/valid#')"
  WARNS; stop 19452 .harness/after
  echo "the copy whose advice extends ResponseEntityExceptionHandler, with no key - its two changed files - built the same way, port 19454:"
  copy after .harness/sub; cp "$XSUB" ".harness/sub/$W/TiffinBoxErrors.java"; nokey "after/$YML" ".harness/sub/$YML"
  echo "\$ diff -U0 after/$W/TiffinBoxErrors.java .harness/sub/$W/TiffinBoxErrors.java"
  diff -U0 "after/$W/TiffinBoxErrors.java" ".harness/sub/$W/TiffinBoxErrors.java" | tail -n +3 | sed 's/^/  /' || true
  echo "\$ diff -U0 after/$YML .harness/sub/$YML"
  diff -U0 "after/$YML" ".harness/sub/$YML" | tail -n +3 | sed 's/^/  /' || true
  pbuild .harness/sub "the copy"; extract .harness/sub
  start "$(hcp .harness/sub 19454 probe.web.Who)"; up 19454; ready 19454
  ask 19454 /probe/who/advice; lq 19454
  WARNS; stop 19454 .harness/sub
  blkraw "after/ with the harness's Who and ValidIn" "the copy whose advice" | awk '/^\$ curl /{ f = 1; next } f { print; f = 0 }' | sed -n '3,8p' > .harness/l1.txt
  blkraw "the copy whose advice" "the copy with no key" | awk '/^\$ curl /{ f = 1; next } f { print; f = 0 }' | sed -n '3,8p' > .harness/l2.txt
  echo "  the six answers, the copy's against after/'s, line for line: $(cmp -s .harness/l1.txt .harness/l2.txt && [ "$(wc -l < .harness/l1.txt | tr -d ' ')" = 6 ] && echo 'the same' || echo different)"
  echo "the copy with no key - after/'s application.yaml without the key's block, the previous lesson's file byte for byte - built the same way, port 19455:"
  copy after .harness/nokey; nokey "after/$YML" ".harness/nokey/$YML"
  echo "  the copy's application.yaml against the previous tree's: $(cmp -s ".harness/nokey/$YML" "$PREV/$YML" && echo 'the same, byte for byte' || echo different)"
  pbuild .harness/nokey "the copy"
  start "$(at .harness/nokey 19455 "$R_RUN")"; up 19455; ready 19455
  rq "$(tq 19455 /nowhere)"; rq "$(tq 19455 '/customers?mealType=veg')"; rq "$(tq 19455 /customers/Nobody)"
  WARNS; stop 19455 .harness/nokey
  echo "the copy with no key, the key misspelt on the run line - singular, as the class is named (this unit's line), port 19455:"
  start "$(atl .harness/nokey 19455 "$L_SING")"; up 19455; ready 19455
  rq "$(tq 19455 /nowhere)"; WARNS
  echo "  its log's lines that name problemdetail: $(grep -ci 'problemdetail' .harness/run.out || true)"
  stop 19455 .harness/nokey
  echo "the copy with no key, the key written with a dash (this unit's line), port 19455:"
  start "$(atl .harness/nokey 19455 "$L_DASH")"; up 19455; ready 19455
  rq "$(tq 19455 /nowhere)"; WARNS; stop 19455 .harness/nokey; }
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
  [ "$(printf '%s\n' "$sol" | grep -c .)" = 4 ] || die "SOLUTION.md's first bash block must be its two export lines, the line it adds and the README's last line"
  [ "$(printf '%s\n' "$sol" | sed -n 1,2p)" = "$(printf '%s\n' "$setup" | sed -n 1,2p)" ] || die "SOLUTION.md must start with the README's two export lines (a new shell's java may be another JDK)"
  printf '%s\n' "$sol" | sed -n 1p | grep -qxF 'export JAVA_HOME=/opt/homebrew/opt/openjdk@25' || die "SOLUTION.md's first line must export this script's JAVA_HOME"
  [ "$(printf '%s\n' "$sol" | sed -n 4p)" = "$(printf '%s\n' "$setup" | tail -1)" ] || die "SOLUTION.md's last line must be the README's last line, exactly"
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
  echo "  the shell is now in: $(where "$d1") · the copy's own token in its log: $(raw "$(head -1 .harness/mine/after/$TF)" .harness/ex-readme.log) times · WARN lines in its log: $(grep -c ' WARN ' .harness/ex-readme.log || true) · ERROR lines: $(grep -c ' ERROR ' .harness/ex-readme.log || true) · lines that name problemdetail: $(grep -ci 'problemdetail' .harness/ex-readme.log || true) · listening on 19459 now: $(listeners 19459)"
  echo "the solution's $(printf '%s\n' "$sol" | grep -c .) lines, next, in the same shell:"
  printf '%s\n' "$sol" | sed 's/^/  $ /'
  echo "  exit $e2 · what they printed:"; sed 's/^/    /' .harness/ex-sol.out
  echo "  the shell is now in: $(where "$d2") · the copy's own token in its log: $(raw "$(head -1 .harness/mine/after/$TF)" .harness/mine/run.log) times · WARN lines in its log: $(grep -c ' WARN ' .harness/mine/run.log || true) · ERROR lines: $(grep -c ' ERROR ' .harness/mine/run.log || true) · listening on 19459 now: $(listeners 19459)"
  echo "  the copy's tiffinbox-local.yaml now, whole:"; sed 's/^/    /' .harness/mine/after/tiffinbox-local.yaml
  echo "  the copy's application.yaml against after/'s: $(cmp -s ".harness/mine/after/$YML" "after/$YML" && echo 'the same' || echo 'without the key')"; }

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
# aotcmp BEFORE AFTER: Spring's generated reachability metadata (its AOT step's own file) in each tree's web module, compared - its
# reflection entries counted, the types only one of them registers (named), the entries that differ and how; its resource entries
AOTF=tiffinbox-web/target/spring-aot/main/resources/META-INF/native-image/com.tiffinbox/tiffinbox-web/reachability-metadata.json
aotcmp() { python3 - "$1/$AOTF" "$2/$AOTF" <<'PY'
import json, sys
a, b = (json.load(open(p)) for p in sys.argv[1:3])
ra, rb = a.get("reflection", []), b.get("reflection", [])
def key(e): return json.dumps(e.get("type"), sort_keys=True)
A = {key(e): e for e in ra}; B = {key(e): e for e in rb}
only_a = sorted(t for t in A if t not in B); only_b = sorted(t for t in B if t not in A)
ch = sorted(t for t in A if t in B and json.dumps(A[t], sort_keys=True) != json.dumps(B[t], sort_keys=True))
print("  Spring's generated metadata (%s) - the previous tree's against after/'s: reflection entries %d -> %d · types only the previous tree registers: %s · only after/: %s · entries that differ: %d%s" % (sys.argv[1].split("/target/", 1)[1], len(ra), len(rb), ", ".join(json.loads(t) for t in only_a) or "none", ", ".join(json.loads(t) for t in only_b) or "none", len(ch), (" - " + ", ".join(json.loads(t) for t in ch)) if ch else ""))
def sig(m): return "%s(%s)" % (m["name"], ", ".join(x.rsplit(".", 1)[-1] for x in m.get("parameterTypes", [])))
def what(e):
    k = [x for x in sorted(e) if x not in ("type", "methods")]
    ms = e.get("methods", [])
    return " · ".join(k + ["%d method%s (%s)" % (len(ms), "" if len(ms) == 1 else "s", " ".join(sorted(sig(m) for m in ms)))])
for t in only_b: print("    %s - %s" % (json.loads(t), what(B[t])))
for t in ch:
    ma = sorted(sig(m) for m in A[t].get("methods", [])); mb = sorted(sig(m) for m in B[t].get("methods", []))
    other = {k: v for k, v in A[t].items() if k != "methods"} != {k: v for k, v in B[t].items() if k != "methods"}
    print("    %s - its methods only before: %s · only after: %s · anything else that differs: %s" % (json.loads(t), " ".join(m for m in ma if m not in mb) or "none", " ".join(m for m in mb if m not in ma) or "none", "yes" if other else "no"))
print("  resource entries: %d -> %d · the same: %s" % (len(a.get("resources", [])), len(b.get("resources", [])), "yes" if json.dumps(a.get("resources"), sort_keys=True) == json.dumps(b.get("resources"), sort_keys=True) else "no"))
PY
}
# lbk LABEL: a form's loopback, read off its own block of this capture so far - every "listens on:" line of the block says
# "loopback only: yes" (the image: published on 127.0.0.1 alone, docker port, both runs)
lbk() { awk -v a="$1" 'index($0, a) == 1 { f = 1; next } /^[1-4] the / { f = 0 } f' .harness/cap.raw > .harness/blk.txt
  if [ "$1" = '4 the image' ]; then [ "$(grep -c '^  docker port: ' .harness/blk.txt)" = 2 ] && [ "$(grep -cE '^  docker port: 18425/tcp -> 127\.0\.0\.1:19457$' .harness/blk.txt)" = 2 ] && echo yes || echo no
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
# The page filter, checked on planted answers before any capture: a Whitelabel page with its created date and curl's status after it
# must come out as its <h1> and its error line, the date masked; a page of another shape must come out counted, never shown
PL=$(printf '%s\n' "<html><body><h1>Whitelabel Error Page</h1><p>planted paragraph</p><div id='created'>Sat Oct 17 07:04:55 CEST 2026</div><div>There was an unexpected error (type=Internal Server Error, status=500).</div></body></html> 500 · Content-Type: [text/html;charset=UTF-8]" '<!doctype html><html lang="en"><head><title>HTTP Status 400 – Bad Request</title></head><body><h1>HTTP Status 400 – Bad Request</h1></body></html> 400 · Content-Type: [text/html]' | pagef)
[ "$PL" = "$(printf '%s\n' "  the Whitelabel page (Boot's) - its <h1>: Whitelabel Error Page · its error line: There was an unexpected error (type=Internal Server Error, status=500). · its created date: masked · its paragraphs: 1, not shown · then curl's: 500 · Content-Type: [text/html;charset=UTF-8]" "  an HTML page, not the Whitelabel page - its <h1>: HTTP Status 400 – Bad Request · 146 characters, not shown · then curl's: 400 · Content-Type: [text/html]")" ] || die "pagef: the planted pages do not come out as declared"
# The record filter, checked on a planted log before any capture: a WARN record with a blank line, its exception line and 45 frames,
# then an ERROR record with 3 frames, must come out as two records, each with its exception line, frames bounded and counted
{ printf '%s\n' '2026-10-17T00:00:00.000Z  WARN 1 --- [planted] .m.m.a.ExceptionHandlerExceptionResolver : Failure in planted' '' 'org.example.PlantedException: planted reason'
  i=0; while [ $i -lt 45 ]; do printf '\tat planted.Frame%s(Planted.java)\n' $i; i=$((i + 1)); done
  printf '%s\n' '' '2026-10-17T00:00:00.001Z ERROR 1 --- [planted] o.a.c.c.C.[.[.[/].[dispatcherServlet]    : planted error' '' 'org.example.Other: other reason' "$(printf '\tat a')" "$(printf '\tat b')" "$(printf '\tat c')"; } > .harness/run.out
PL=$(recs 0)
[ "$PL" = "$(printf '%s\n' '    WARN .m.m.a.ExceptionHandlerExceptionResolver: Failure in planted' '      org.example.PlantedException: planted reason' '      its stack frames: over 40, its other lines: 2 - none shown' '    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: planted error' '      org.example.Other: other reason' '      its stack frames: 3, its other lines: 1 - none shown')" ] || die "recs: the planted records do not come out as declared (.harness/run.out)"
rm -f .harness/run.out
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
# froutes PORT: a name nobody has, a name with a space, Ravi, the name nobody has for a client that accepts only HTML, POST /shutdown
# without the token (the secrets lesson's line) - each answer printed (timestamp masked, a page through pagef); no log counted (a
# container's log is read only when it has stopped)
# froutes PORT: a name nobody has (curl's own Accept, and only HTML), a body that breaks four rules, POST /shutdown without the token, a
# new customer twice - each answer printed as it came (a page through pagef); no log counted (a container's log is read only when it
# has stopped)
froutes() { rq "$(tq "$1" /customers/Nobody)" nolog; hq "$L_HTML" "$1" nolog; rq "$(pq "$1" "$B_BAD")" nolog; rq "$(xq "$1")" nolog
  rq "$(pq "$1" "$B_ASHA")" nolog; rq "$(pq "$1" "$B_ASHA")" nolog; }
dseven() { echo "\$ \$CURLSET $1 .harness/after/$TF"
  "$CURLSET" "$1" ".harness/after/$TF" | grep ' -> ' > .harness/responses.txt || true
  tsmask < .harness/responses.txt > .harness/responses.m.txt
  grep '^POST ' .harness/responses.m.txt | sed 's/^/  /' || echo "  (no POST line)"
  dgone "$BOX"; [ "$(listeners "$1")" = 0 ] || die "something still listens on $1"
  echo "  exit $LASTE · the seven responses: $(wc -l < .harness/responses.m.txt | tr -d ' ') lines · lines the timestamp mask changed: $(diff .harness/responses.txt .harness/responses.m.txt | grep -c '^<' || true) · md5 $(md5 -q .harness/responses.m.txt)"
  dlog "$BOX"; echo "  its log (docker logs): Boot's first line: $(first .harness/run.out) · the demo token 0 times · X-Shutdown-Token 0 times"
  docker rm "$BOX" > /dev/null; }
S466='466c20ed7e0d5439cb052f32ce09de1b'
PJ=' · Content-Type: [application/problem+json]'
PDNOB='  {"detail":"no customer named Nobody","instance":"/customers/Nobody","status":404,"title":"Customer not found","name":"Nobody"} 404'"$PJ"
PDBAD='  {"detail":"the customer breaks 4 rules","instance":"/customers","status":400,"title":"Invalid customer","errors":{"mealType":"must match \"VEG|NON_VEG|VEGAN\"","mealsPerDay":"must be greater than or equal to 1","name":"must not be blank","pricePerMeal":"must be greater than or equal to 1"}} 400'"$PJ"
PD403='  {"detail":"the shutdown token is missing or wrong","instance":"/shutdown","status":403,"title":"Forbidden"} 403'"$PJ"
PD201='  {"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 201 · Content-Type: [application/json]'
PD409='  {"detail":"a customer named Asha already exists","instance":"/customers","status":409,"title":"Conflict"} 409'"$PJ"
forms() {
  echo "the native build - after/ copied to .harness/nat with a config tree; the README's two Maven lines, offline; \$GRAALVM_HOME names the GraalVM:"
  copy after .harness/nat
  nbuild .harness/nat; nlines .harness/nat.native.log; nresult .harness/nat.native.log
  echo "  file: $(file -b ".harness/nat/$BIN" | sed 's/ [A-Za-z0-9_]*$//') · the demo token in its bytes: $(raw "$TOKEN" ".harness/nat/$BIN")"
  echo "what Spring's AOT step registered - the previous tree built with the README's native-profile line too (.harness/natb), then its metadata against after/'s:"
  copy "$PREV" .harness/natb; pbuild .harness/natb "the previous tree, the profile native" "$R_PNAT"
  aotcmp .harness/natb .harness/nat
  echo "1 the jar - .harness/after, the README's run line, port 19450:"
  start "$(at .harness/after 19450 "$R_RUN")"; up 19450; ready 19450; tline; seven 19450 .harness/after
  echo "  then a name nobody has (curl's own Accept, and only HTML), a body that breaks four rules, POST /shutdown without the token and a new customer twice, on a second start of the jar:"
  start "$(at .harness/after 19450 "$R_RUN")"; up 19450; ready 19450; froutes 19450; stop 19450 .harness/after
  echo "2 the AOT jar - .harness/nat (the profile native's jar), the README's AOT line, port 19456:"
  start "$(at .harness/nat 19456 "$R_AOTRUN")"; up 19456; ready 19456; tline; seven 19456 .harness/nat
  echo "  then the same six, on a second start of the AOT jar:"
  start "$(at .harness/nat 19456 "$R_AOTRUN")"; up 19456; ready 19456; froutes 19456; stop 19456 .harness/nat
  echo "3 the binary - .harness/nat, the README's line, port 19458:"
  start "$(at .harness/nat 19458 "$R_BIN")"; up 19458; ready 19458; tline; seven 19458 .harness/nat
  echo "  then the same six, on a second start of the binary:"
  start "$(at .harness/nat 19458 "$R_BIN")"; up 19458; ready 19458; froutes 19458; stop 19458 .harness/nat
  echo "4 the image - after/'s Dockerfile (the README's build line, this script's tag), the README's run line with your user, published on 127.0.0.1:19457:"
  image
  dstart "$(drun .harness/after 19457)"; ready 19457 "$BOX"; dbind 19457
  dseven 19457
  echo "  then the same six, on a second container of the image - TiffinBox listens on 18425 inside it:"
  dstart "$(drun .harness/after 19457)"; ready 19457 "$BOX"; dbind 19457
  froutes 19457
  post 19457 .harness/after; dgone "$BOX"; [ "$(listeners 19457)" = 0 ] || die "something still listens on 19457"
  dlog "$BOX"; echo "  exit $LASTE · its log (docker logs): the demo token 0 times · X-Shutdown-Token 0 times"
  docker rm "$BOX" > /dev/null
  echo "four forms, one tree: the seven (masked) $(grep -cE "^  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 0 · md5 $S466\$" .harness/cap.raw) of 4 times $S466, the timestamp mask changing 0 lines · a name nobody has - curl's own Accept, and only HTML - 404 and the name, a problem detail: $(grep -cxF -- "$PDNOB" .harness/cap.raw) of 8 · four rules broken, a problem detail with its errors: $(grep -cxF -- "$PDBAD" .harness/cap.raw) of 4 · POST /shutdown without the token, a 403 problem detail: $(grep -cxF -- "$PD403" .harness/cap.raw) of 4 · a new customer, 201: $(grep -cxF -- "$PD201" .harness/cap.raw) of 4 · the same again, a 409 problem detail: $(grep -cxF -- "$PD409" .harness/cap.raw) of 4"
  echo "  loopback, form by form: the jar $(lbk '1 the jar') · the AOT jar $(lbk '2 the AOT jar') · the binary $(lbk '3 the binary') · the image, published on 127.0.0.1 alone $(lbk '4 the image')"; }



cap change change
cap seven sevens
cap own own
cap accept accept
cap flag flag
cap edges edges
cap losers losers
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
# handed to awk through its environment, which keeps a backslash a backslash (-v would turn \n into a newline); aftn N: the Nth
aft() { printf '%s\n' "$2" | C="$1" awk 'f { print; exit } $0 == ENVIRON["C"] { f = 1 }'; }
aftn() { printf '%s\n' "$3" | C="$2" N="$1" awk 'f { print; exit } $0 == ENVIRON["C"] && ++k == ENVIRON["N"] { f = 1 }'; }
# THE TOKEN: no capture holds it, raw - counted on each run's own output BEFORE masking - and neither does any log (each counted
# when it was read: logtok(), dlog()), anything this unit ships for reading, nor the binary this run built
for f in .harness/raw-*; do [ "$(cat "$f")" = "0" ] || die "a capture's raw output held the token ($f: $(cat "$f"))"; done
NBIN=0
for f in .r-*.out README.md exercise/README.md exercise/solution/SOLUTION.md receipts.md5 harness/shutdown.sh $XYAML $XLOC $XSUB $HWS .harness/nat/$BIN; do
  [ -f "$f" ] || continue; case $f in .harness/nat*) NBIN=$((NBIN + 1)) ;; esac
  [ "$(raw "$TOKEN" "$f")" = 0 ] || die "$f holds the demo token, raw"; done
[ "$NBIN" = 1 ] || die "one binary was built, $NBIN were checked"
for f in .r-*.out; do ! grep -qE '/Users/|/private/|/home/|/var/folders/' "$f" || die "$f holds an absolute path"; [ -z "${GRAALVM_HOME:-}" ] || ! grep -qF "$GRAALVM_HOME" "$f" || die "$f holds the GraalVM's folder"; ! grep -qE 'c[0-9]-unit[0-9]|unit ?[0-9]' "$f" || die "$f holds a unit number"; ! grep -qE ' (with PID|started by) ' "$f" || die "$f holds Boot's process line"; ! grep -qE '^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T|"timestamp":"?[0-9]|timestamp=[A-Z0-9]|(exec|handler|task|utility)-[0-9]|GMT|CES?T|<div id=.created|[A-Z][a-z][a-z] [A-Z][a-z][a-z] [0-9]+ [0-9][0-9]:[0-9][0-9]' "$f" || die "$f holds a log line's time, a timestamp, a date or a thread's number"; ! grep -q "^$(printf '\t')at " "$f" || die "$f shows a stack frame"; ! grep -qE 'SpringCGLIB\$\$[0-9]' "$f" || die "$f holds a generated class's number"; ! grep -qE 'sha256:[0-9a-f]{64}' "$f" || [ "$(grep -cE 'sha256:[0-9a-f]{64}' "$f")" = "$(grep -cE 'eclipse-temurin(:25-jre)?@sha256:[0-9a-f]{64}' "$f")" ] || die "$f holds an ID other than the base image's digest"; ! grep -qE ':(8080|35729)([^0-9]|$)' "$f" || die "$f shows a bind on 8080 or 35729"; ! grep -q $'\r' "$f" || die "$f holds a carriage return"; ! grep -qiE '<html>|<!doctype' "$f" || die "$f shows an HTML page whole"; done
for f in receipts.sh README.md exercise/README.md exercise/solution/SOLUTION.md harness/shutdown.sh $HWS; do [ -f "$f" ] || continue; ! grep -qE "exposure\.include='?\*" "$f" || die "$f exposes every endpoint (R.42)"; done
# S3.21 (R.99): Boot 4.1 reads only spring.web.error.*, and Boot 3's keys (server, then error) are ignored without a word - no file of
# this unit names one, the anchor's tree included (the name is split here, so this line does not spell it)
K3='server'; K3="$K3.error."
for f in receipts.sh README.md exercise/README.md exercise/solution/SOLUTION.md harness/shutdown.sh $XYAML $XLOC $XSUB $HWS; do ! grep -qF "$K3" "$f" || die "$f names one of Boot 3's error keys - Boot 4.1 reads only spring.web.error.* (S3.21)"; done
! grep -rqF "$K3" after || die "after/ names one of Boot 3's error keys (S3.21)"
for f in receipts.sh README.md exercise/README.md exercise/solution/SOLUTION.md; do [ -f "$f" ] || continue; ! grep -E 'docker run ' "$f" | grep -vE '^#' | grep -E ' -p "?[0-9]+:' > /dev/null || die "$f publishes a port on every address (-p without 127.0.0.1:)"; done
# S3.9 (R.105): no wait in this script, its checks or the exercise is bare - each names its pid ($! or a variable)
for f in receipts.sh exercise/README.md exercise/solution/SOLUTION.md; do ! grep -nE '(^|[;&|({] *)wait *($|[;&|)}])' "$f" | grep -vE '^[0-9]+: *#' > /dev/null || die "$f has a bare wait (S3.9)"; done
# no capture runs a command with a URL that is not 127.0.0.1's
for f in .r-*.out; do ! grep -E '^\$ ' "$f" | grep -oE 'https?://[^ '"'"']+' | grep -vE '^http://127\.0\.0\.1:' > /dev/null || die "$f runs a command with a URL that is not 127.0.0.1's"; done
# S3.1: every java line a capture starts pins the JVM's locale - the binary's alone takes none
for f in .r-*.out; do ! grep -E '^\$ (cd [^ ]+ && )?(exec )?java ' "$f" | grep -vF -- 'java -Duser.language=en -Duser.country=US ' | grep -vF -- 'java -Djarmode=tools ' > /dev/null || die "$f starts a JVM without its locale pinned (S3.1)"; done
NL=$(cat .r-*.out | grep -cE "^  its log: the demo token 0 times · X-Shutdown-Token 0 times\$" || true)
echo "  tokens: 0 raw copies in $(ls .harness/raw-* | wc -l | tr -d ' ') raw capture runs, in $(ls .r-*.out | wc -l | tr -d ' ') captures; the demo token 0 in the logs of every JVM that served ($LOGS here; the published captures' $NL) and every container ($CLOGS here), the image's layers (forms), the READMEs, the harness, the exercise, receipts.md5 and the binary; no absolute path, no GraalVM folder, no unit number, no process line, no log time, no timestamp, no date, no thread number, no stack frame, no whole HTML page, no 8080 or 35729, no carriage return in any capture; no Boot 3 error key; no bare wait; every java line's locale pinned; every docker run publishes on 127.0.0.1 alone; every URL a capture runs is 127.0.0.1's"

S87C='87ca7efc8584dcccd40e6b956db1de9b'
RQ() { printf '$ %s' "$1"; }
Z() { printf '%s · WARN lines it added: %s · ERROR lines: %s' "$1" "$2" "$3"; }
BOOT4() { printf '  {"timestamp":"…","status":%s,"error":"%s","path":"%s"} %s · Content-Type: [application/json]' "$1" "$2" "$3" "$1"; }
WL() { printf "  the Whitelabel page (Boot's) - its <h1>: Whitelabel Error Page · its error line: There was an unexpected error (type=%s, status=%s). · its created date: masked · its paragraphs: 1, not shown · then curl's: %s · Content-Type: [text/html;charset=UTF-8]" "$1" "$2" "$2"; }
PD404='  {"detail":"No static resource nowhere.","instance":"/nowhere","status":404,"title":"Not Found"} 404'"$PJ"
PD405='  {"detail":"Method '"'"'GET'"'"' is not supported.","instance":"/shutdown","status":405,"title":"Method Not Allowed"} 405'"$PJ"
PDVEG='  {"detail":"Failed to convert '"'"'mealType'"'"' with value: '"'"'veg'"'"'","instance":"/customers","status":400,"title":"Bad Request"} 400'"$PJ"
PDREAD='  {"detail":"Failed to read request","instance":"/customers","status":400,"title":"Bad Request"} 400'"$PJ"
PDTYPO='  {"detail":"the customer breaks 1 rule","instance":"/customers","status":400,"title":"Invalid customer","errors":{"mealType":"must not be null"}} 400'"$PJ"
PNF='    WARN o.s.web.servlet.PageNotFound: Request method '"'"'GET'"'"' is not supported'
TOME='    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: Servlet.service() for servlet [dispatcherServlet] in context with path [] threw exception [Request processing failed: com.tiffinbox.web.CustomerNotFound: no customer named Nobody] with root cause'
FAILW='    WARN .m.m.a.ExceptionHandlerExceptionResolver: Failure in @ExceptionHandler com.tiffinbox.web.TiffinBoxErrors#notFound(CustomerNotFound)'

# "One key ... spring dot mvc dot problem details dot enabled ... false by default, Boot's own metadata says ... in the first document"
CO=$(cat .r-change.out)
for l in '  built the previous tree · offline: yes · exit 0' '  built after/ · offline: yes · exit 0' "  after/'s files: 27 · byte for byte the previous tree's: 23 · new: 0 · those that differ: 4" \
         '  application.yaml: 98 lines -> 106 · the diff (diff -U0, its file names cut) - whole:' '    @@ -56,0 +57,8 @@' '    +  mvc:' '    +    problemdetails:' '    +      enabled: true' \
         '  the key spring.mvc.problemdetails.enabled: true - its line: 64 · the first document ends at line 99 (---) · in the first document: yes' \
         '  spring.mvc.problemdetails.enabled - type Boolean · default false · Whether RFC 9457 Problem Details support should be enabled.' \
         '  TiffinBoxErrors.java: 28 lines -> 30 · its lines that are neither comment nor blank: 14 -> 15 · naming ProblemDetail: 0 -> 3 · @ResponseStatus: 1 -> 0' \
         '    +        problem.setTitle("Customer not found");' '    +        problem.setProperty("name", e.name());' \
         '  TiffinBoxServer.java: 274 lines -> 296 · its lines that are neither comment nor blank: 140 -> 155 · naming ProblemDetail: 0 -> 6 · naming "forbidden": 1 -> 0' \
         '    +                return problem(HttpStatus.CONFLICT, "a customer named " + customer.name() + " already exists");' '    +            return problem(HttpStatus.FORBIDDEN, "the shutdown token is missing or wrong");' \
         '    +        problem.setProperty("errors", fields);' "the executable jar's BOOT-INF/lib: 56 jars -> 56 · the same names: yes" "the classes in the jar's com/tiffinbox/web: 9 -> 9 · the same names: yes"; do has "$CO" "$l" "change"; done
[ "$(n change '^  Files ')" = 4 ] && [ "$(n change '^  Only in ')" = 0 ] || die "change: four files differ, none new"
x change '^  spring\.mvc\.log-resolved-exception - type Boolean · default false · '
echo "  change: one key on line 64, above the --- at 99; Boot's metadata default false; TiffinBoxErrors returns a ProblemDetail (title, name), no @ResponseStatus; TiffinBoxServer 274 -> 296, forbidden 1 -> 0; 23 of 27 byte for byte; 56 libraries"

# "The seven move by two lines ... the four-oh-four and the four-oh-five ... no timestamp, the mask changes nothing ... one warning line, now
#  from another logger ... Boot's handler first, at order zero, then ours ... type: null ... six fields"
SV=$(cat .r-seven.out)
has "$SV" "  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 2 · md5 $S87C" "seven: the previous tree"
has "$SV" "  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 0 · md5 $S466" "seven: after/, 466c20ed, the mask 0"
has "$SV" "  the timestamps the mask hid, their form: none" "seven: no timestamp"
has "$SV" '  lines that differ: 2 (5 6) · the same, byte for byte: 5 (1 2 3 4 7)' "seven: lines 5 and 6"
has "$SV" '    line 5, after/:            GET   /nowhere    -> 404 application/problem+json  {"detail":"No static resource nowhere.","instance":"/nowhere","status":404,"title":"Not Found"}' "seven: line 5"
has "$SV" '    line 6, after/:            GET   /shutdown   -> 405 application/problem+json  {"detail":"Method '"'"'GET'"'"' is not supported.","instance":"/shutdown","status":405,"title":"Method Not Allowed"}' "seven: line 6"
B7=$(blk seven "the seven - the previous tree" "the seven - after/"); A7=$(blk seven "the seven - after/" "the lines that moved")
has "$B7" "  WARN lines in this run's log, at Boot's default level: 1 · ERROR lines: 0" "seven: before, 1 WARN"; printf '%s\n' "$B7" | grep -q '^    WARN \.w\.s\.m\.s\.DefaultHandlerExceptionResolver: ' || die "seven: before, the WARN is DefaultHandlerExceptionResolver's"
has "$A7" "  WARN lines in this run's log, at Boot's default level: 1 · ERROR lines: 0" "seven: after, 1 WARN"; has "$A7" '    WARN o.s.web.servlet.PageNotFound: Request method '"'"'GET'"'"' is not supported' "seven: after, PageNotFound"
WA=$(blk seven "who answers - " "the previous tree with Who"); WB=$(blk seven "the previous tree with Who" "")
for l in '  the ResponseEntityExceptionHandler beans: 1' "  ExceptionHandlerExceptionResolver's advice cache, in the order it asks: 2" '    1 org.springframework.boot.webmvc.autoconfigure.ProblemDetailsExceptionHandler · its order: 0' \
         '        @ExceptionHandler handleException, from ResponseEntityExceptionHandler - takes 20 exception types' '    2 com.tiffinbox.web.TiffinBoxErrors · its order: 2147483647' \
         "  a CustomerNotFound, each advice's method for it, in that order: ProblemDetailsExceptionHandler: none · TiffinBoxErrors: notFound" \
         "  a NoResourceFoundException, each advice's method for it, in that order: ProblemDetailsExceptionHandler: handleException · TiffinBoxErrors: none" \
         "  an IllegalStateException, each advice's method for it, in that order: ProblemDetailsExceptionHandler: none · TiffinBoxErrors: none" "  the JVM's locale: en_US" \
         "  ProblemDetail's instance fields, in the order the class declares them: 6 - type (URI), title (String), status (int), detail (String), instance (URI), properties (Map)" \
         '  ProblemDetail.forStatus(HttpStatus.NOT_FOUND), nothing else set - type: null · title: Not Found · status: 404 · detail: null · instance: null · properties: null'; do has "$WA" "$l" "seven: who answers"; done
for l in '  the ResponseEntityExceptionHandler beans: 0' "  ExceptionHandlerExceptionResolver's advice cache, in the order it asks: 1"; do has "$WB" "$l" "seven: the previous tree's advice"; done
echo "  seven: $S87C (mask 2) -> $S466 (mask 0), lines 5 and 6; WARN 1 -> 1, DefaultHandlerExceptionResolver -> PageNotFound; Boot's handler order 0 then TiffinBoxErrors; ProblemDetail 6 fields, type null"

# "Three ways to say no ... Boot's four keys, our own error key, a bare field map ... a four-oh-nine with no body ... now every one of them a
#  problem detail ... four rules ... the misspelt key, one rule"
OB=$(blk own "the previous tree - " "after/ - the same"); OA=$(blk own "after/ - the same" "")
[ "$(aft "$(RQ "$(tq 19451 /nowhere)")" "$OB")" = "$(Z "$(BOOT4 404 'Not Found' /nowhere)" 0 0)" ] || die "own: before, Boot's four keys"
[ "$(aft "$(RQ "$(tq 19451 /customers/Nobody)")" "$OB")" = "$(Z '  {"error":"no customer named Nobody"} 404 · Content-Type: [application/json]' 0 0)" ] || die "own: before, the error key"
aft "$(RQ "$(pq 19451 "$B_BAD")")" "$OB" | grep -q '^  {"mealType":"must match' || die "own: before, the field map"
[ "$(aft "$(RQ "$(xq 19451)")" "$OB")" = "$(Z '  {"error":"forbidden"} 403 · Content-Type: [application/json]' 0 0)" ] || die "own: before, forbidden"
[ "$(aftn 2 "$(RQ "$(pq 19451 "$B_ASHA")")" "$OB")" = "$(Z '   409 · Content-Type: []' 0 0)" ] || die "own: before, the empty 409"
[ "$(aft "$(RQ "$(tq 19450 /nowhere)")" "$OA")" = "$(Z "$PD404" 0 0)" ] && [ "$(aft "$(RQ "$(tq 19450 /customers/Nobody)")" "$OA")" = "$(Z "$PDNOB" 0 0)" ] && [ "$(aft "$(RQ "$(pq 19450 "$B_BAD")")" "$OA")" = "$(Z "$PDBAD" 0 0)" ] || die "own: after, 404s and the 400"
[ "$(aft "$(RQ "$(pq 19450 "$B_TYPO")")" "$OA")" = "$(Z "$PDTYPO" 0 0)" ] && [ "$(aft "$(RQ "$(xq 19450)")" "$OA")" = "$(Z "$PD403" 0 0)" ] && [ "$(aft "$(RQ "$(pq 19450 "$B_ASHA")")" "$OA")" = "$(Z "$PD201" 0 0)" ] && [ "$(aftn 2 "$(RQ "$(pq 19450 "$B_ASHA")")" "$OA")" = "$(Z "$PD409" 0 0)" ] || die "own: after, the typo, the 403, 201 and the 409"
has "$OA" "  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0" "own: after, 0 and 0"
echo "  own: before - Boot's four keys, {\"error\"}, the field map, forbidden, an empty 409; after - every one a problem detail, 4 rules, 1 rule, 403, 409; 0 WARN 0 ERROR"

# "Only HTML, only XML, a browser's whole header: the same problem detail, four oh four, no warning ... the last lesson's five hundreds"
AA=$(blk accept "after/ - a name nobody has" "the previous tree - the same four"); AB=$(blk accept "the previous tree - the same four" "")
for l in "$L_HTML" "$L_XML" "$L_CHROME"; do [ "$(aft "$(RQ "$(url "$l" 19450)")" "$AA")" = "$(Z "$PDNOB" 0 0)" ] || die "accept: after, $l"; done
[ "$(aft "$(RQ "$(tq 19450 /nowhere text/html)")" "$AA")" = "$(Z "$PD404" 0 0)" ] || die "accept: after, /nowhere for HTML"
has "$AA" "  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0" "accept: after, 0 and 0"
[ "$(aft "$(RQ "$(url "$L_HTML" 19451)")" "$AB")" = "$(Z "$(WL 'Internal Server Error' 500)" 1 1)" ] && [ "$(aft "$(RQ "$(url "$L_XML" 19451)")" "$AB")" = "$(Z '   500 · Content-Type: []' 1 1)" ] || die "accept: before, the two 500s"
[ "$(aft "$(RQ "$(url "$L_CHROME" 19451)")" "$AB")" = "$(Z '  {"error":"no customer named Nobody"} 404 · Content-Type: [application/json]' 0 0)" ] && [ "$(printf '%s\n' "$AB" | grep -cxF -- "$FAILW")" = 2 ] && [ "$(printf '%s\n' "$AB" | grep -cxF -- "$TOME")" = 2 ] || die "accept: before, Chrome's JSON, the failed handler and Tomcat's ERROR twice"
echo "  accept: after - only HTML, only XML, Chrome's: the 404 problem detail, 0 and 0; before - 500, 500 (1 WARN + 1 ERROR each), 404 JSON"

# "With the key, the reason left the log: no warning for the four hundreds, the four fifteen, the four oh six ... the four oh five still logs
#  one, from another logger ... unreadable: failed to read request ... B: Boot's four keys, a warning each ... A again ... C: the reason back,
#  one warning for every answer, a missing customer too, two for the four oh five"
FA=$(blk flag "A - after/" "B - after/"); FB=$(blk flag "B - after/" "A' - A again"); FC=$(blk flag "C (labelled)" "")
[ "$(aft "$(RQ "$(tq 19450 /nowhere)")" "$FA")" = "$(Z "$PD404" 0 0)" ] && [ "$(aft "$(RQ "$(tq 19450 /shutdown)")" "$FA")" = "$(Z "$PD405" 1 0)" ] && [ "$(aft "$(RQ "$(tq 19450 '/customers?mealType=veg')")" "$FA")" = "$(Z "$PDVEG" 0 0)" ] || die "flag A: 404, 405 (1 WARN), the type mismatch"
[ "$(aft "$(RQ "$(pq 19450 "$B_CUT")")" "$FA")" = "$(Z "$PDREAD" 0 0)" ] && [ "$(aft "$(RQ "$(pq 19450 "$B_27")")" "$FA")" = "$(Z "$PDREAD" 0 0)" ] || die "flag A: unreadable and 2.7 - Failed to read request, 0 WARN"
aft "$(RQ "$(pq 19450 "$B_ASHA" application/x-www-form-urlencoded)")" "$FA" | grep -qE '"status":415,.* 415 · Content-Type: \[application/problem\+json\] · WARN lines it added: 0 · ERROR lines: 0$' || die "flag A: 415, 0 WARN"
aft "$(RQ "$(tq 19450 /customers application/xml)")" "$FA" | grep -qE '"status":406,.* 406 · Content-Type: \[application/problem\+json\] · WARN lines it added: 0 · ERROR lines: 0$' || die "flag A: 406, a body, 0 WARN"
has "$FA" "$PNF" "flag A: the 405's WARN is PageNotFound's"; has "$FA" "  WARN lines in this run's log, at Boot's default level: 1 · ERROR lines: 0" "flag A: 1 WARN in nine"
[ "$(aft "$(RQ "$(tq 19450 /nowhere)")" "$FB")" = "$(Z "$(BOOT4 404 'Not Found' /nowhere)" 0 0)" ] && [ "$(aft "$(RQ "$(tq 19450 /shutdown)")" "$FB")" = "$(Z "$(BOOT4 405 'Method Not Allowed' /shutdown)" 1 0)" ] || die "flag B: Boot's four keys"
[ "$(aft "$(RQ "$(tq 19450 /customers/Nobody)")" "$FB")" = "$(Z "$PDNOB" 0 0)" ] && [ "$(aft "$(RQ "$(pq 19450 "$B_BAD")")" "$FB")" = "$(Z "$PDBAD" 0 0)" ] || die "flag B: TiffinBox's own still problem details"
[ "$(aft "$(RQ "$(tq 19450 /customers application/xml)")" "$FB")" = "$(Z '   406 · Content-Type: []' 1 0)" ] || die "flag B: the empty 406"
has "$FB" '    WARN .w.s.m.s.DefaultHandlerExceptionResolver: Resolved [org.springframework.http.converter.HttpMessageNotReadableException: JSON parse error: Unexpected end-of-input within/between Object entries]' "flag B: Jackson's reason, in the WARN"
has "$FB" "  WARN lines in this run's log, at Boot's default level: 6 · ERROR lines: 0" "flag B: 6 WARN"
x flag "^A' against A, its label aside, line for line the same: yes\$"
[ "$(aft "$(RQ "$(tq 19450 /nowhere)")" "$FC")" = "$(Z "$PD404" 1 0)" ] && [ "$(aft "$(RQ "$(tq 19450 /shutdown)")" "$FC")" = "$(Z "$PD405" 2 0)" ] && [ "$(aft "$(RQ "$(tq 19450 /customers/Nobody)")" "$FC")" = "$(Z "$PDNOB" 1 0)" ] && [ "$(aft "$(RQ "$(pq 19450 "$B_BAD")")" "$FC")" = "$(Z "$PDBAD" 0 0)" ] || die "flag C: one WARN per resolved exception, the 404s too, two for the 405, none for the method's own 400"
has "$FC" '    WARN .m.m.a.ExceptionHandlerExceptionResolver: Resolved [org.springframework.http.converter.HttpMessageNotReadableException: JSON parse error: Unexpected end-of-input within/between Object entries]' "flag C: the reason back"
has "$FC" "  WARN lines in this run's log, at Boot's default level: 9 · ERROR lines: 0" "flag C: 9 WARN"
echo "  flag: A 1 WARN in nine (PageNotFound), unreadable and 2.7 'Failed to read request' 0 WARN; B Boot's four keys, 6 WARN (DHER), the reason in the WARN, the empty 406, ours still problem details; A' = A; C 9 WARN - 404 1, 405 2, Nobody 1, the method's 400 0"

# "A route's own unexpected five hundred is still Boot's body, with its timestamp, and the white-label page for HTML ... Tomcat's page for a
#  slash it refuses ... include-message changes that body and not a problem detail"
EA=$(blk edges "after/ with the harness's Boom" "the same, with Boot's"); EB=$(blk edges "the same, with Boot's" "a path nobody maps")
[ "$(aft "$(RQ "$(tq 19452 /probe/boom)")" "$EA")" = "$(Z '  {"timestamp":"…","status":500,"error":"Internal Server Error","path":"/probe/boom"} 500 · Content-Type: [application/json]' 0 1)" ] || die "edges: Boot's 500"
[ "$(aft "$(RQ "$(tq 19452 /probe/boom text/html)")" "$EA")" = "$(Z "$(WL 'Internal Server Error' 500)" 0 1)" ] || die "edges: the Whitelabel 500"
aft "$(RQ "$(tq 19452 /customers/a%2Fb)")" "$EA" | grep -qE "^  an HTML page, not the Whitelabel page - its <h1>: HTTP Status 400 – Bad Request · [0-9]+ characters, not shown · then curl's: 400 · Content-Type: \[text/html;charset=utf-8\] · WARN lines it added: 0 · ERROR lines: 0\$" || die "edges: Tomcat's 400"
[ "$(aft "$(RQ "$(tq 19452 /probe/boom)")" "$EB")" = "$(Z '  {"timestamp":"…","status":500,"error":"Internal Server Error","message":"the kitchen is on fire","path":"/probe/boom"} 500 · Content-Type: [application/json]' 0 1)" ] || die "edges: include-message, the message in the 500"
x edges '^a path nobody maps, without the key and with it, the same bytes: yes$'
echo "  edges: the 500 Boot's body (timestamp), 1 ERROR Tomcat's; Whitelabel for HTML; Tomcat's %2F page; include-message: the 500 gains message, the problem detail the same"

# "Extend the Framework's own handler instead, with no key: the same answers, byte for byte, one advice ... no key at all: Boot's four keys
#  ... a letter missing and Boot never says ... a dash is fine ... no BindingResult: invalid request content, no field"
LA=$(blk losers "after/ with the harness's Who and ValidIn" "the copy whose advice"); LS=$(blk losers "the copy whose advice" "the copy with no key - "); LN=$(blk losers "the copy with no key - " "the copy with no key, the key misspelt"); LG=$(blk losers "the copy with no key, the key misspelt" "the copy with no key, the key written"); LD=$(blk losers "the copy with no key, the key written" "")
[ "$(aft "$(RQ "$(pq 19452 "$B_BAD" | sed 's#/customers$#/probe/valid#')")" "$LA")" = "$(Z '  {"detail":"Invalid request content.","instance":"/probe/valid","status":400,"title":"Bad Request"} 400'"$PJ" 0 0)" ] || die "losers: no BindingResult - Invalid request content., no field"
for l in '  the ResponseEntityExceptionHandler beans: 1' '    tiffinBoxErrors - com.tiffinbox.web.TiffinBoxErrors' "  ExceptionHandlerExceptionResolver's advice cache, in the order it asks: 1" '  +final class TiffinBoxErrors extends ResponseEntityExceptionHandler {' '  built the copy · offline: yes · exit 0'; do has "$LS" "$l" "losers: the subclass"; done
has "$LS" "  the six answers, the copy's against after/'s, line for line: the same" "losers: the subclass, the same answers"
has "$LN" "  the copy's application.yaml against the previous tree's: the same, byte for byte" "losers: no key = the previous lesson's file"
[ "$(aft "$(RQ "$(tq 19455 /nowhere)")" "$LN")" = "$(Z "$(BOOT4 404 'Not Found' /nowhere)" 0 0)" ] && [ "$(aft "$(RQ "$(tq 19455 /customers/Nobody)")" "$LN")" = "$(Z "$PDNOB" 0 0)" ] || die "losers: no key - Boot's four keys for Spring MVC's, ours a problem detail"
aft "$(RQ "$(tq 19455 '/customers?mealType=veg')")" "$LN" | grep -qF '· WARN lines it added: 1 · ERROR lines: 0' || die "losers: no key - the type mismatch's WARN"
[ "$(aft "$(RQ "$(tq 19455 /nowhere)")" "$LG")" = "$(Z "$(BOOT4 404 'Not Found' /nowhere)" 0 0)" ] && has "$LG" "  its log's lines that name problemdetail: 0" "losers: singular, silent" || die "losers: the singular key - Boot's four keys, silent"
[ "$(aft "$(RQ "$(tq 19455 /nowhere)")" "$LD")" = "$(Z "$PD404" 0 0)" ] || die "losers: the dashed key - a problem detail"
echo "  losers: no BindingResult -> Invalid request content.; extends ResponseEntityExceptionHandler, no key -> 1 handler bean, 1 advice, the six answers the same; no key -> Boot's four keys, ours a problem detail; problemdetail (singular) -> Boot's, 0 lines; problem-details -> a problem detail"

# the exercise's end state: the README's commands, then the solution's, in ONE env -i shell
XS=$(blk exercise "the README's" "the solution's"); XE=$(blk exercise "the solution's" '')
l='nowhere: 404 · Content-Type: application/problem+json'; l0='nowhere: 404 · Content-Type: application/json'
has "$XE" "    $l" "exercise: the solution"; has "$XS" "    $l0" "exercise: as shipped"
awk '/^\*\*Done\*\*/ { f = 1 } f' exercise/README.md | grep -qxF -- "$l" || die "exercise/README.md: Done names no such line"
grep -qxF -- "$l" exercise/solution/SOLUTION.md || die "SOLUTION.md: the measured run shows no such line"
grep -qF -- "\`$l0\`" exercise/README.md || die "exercise/README.md: the shipped line's answer is not named"
has "$XS" '  exit 0 · what they printed:' "exercise: the README's commands, exit 0"; has "$XE" '  exit 0 · what they printed:' "exercise: the solution's lines, exit 0"
has "$XS" "  the shell is now in: this unit's folder · the copy's own token in its log: 0 times · WARN lines in its log: 0 · ERROR lines: 0 · lines that name problemdetail: 0 · listening on 19459 now: 0" "exercise: silent, the token 0, the port free"
has "$XE" "  the shell is now in: this unit's folder · the copy's own token in its log: 0 times · WARN lines in its log: 0 · ERROR lines: 0 · listening on 19459 now: 0" "exercise: the shell in this unit's folder"
has "$XE" '        problemdetails:' "exercise: the key fixed"; has "$XE" "  the copy's application.yaml against after/'s: without the key" "exercise: the copy has no key of its own"
[ "$(printf '%s\n' "$XE" | grep -c '^  \$ export ')" = 2 ] || die "exercise: SOLUTION.md gives the README's two export lines"
cmp -s "$XYAML" "$PREV/$YML" || die "harness/exercise/application.yaml must be the previous tree's, byte for byte"
nokey "after/$YML" .harness/nokey-check.yaml; cmp -s "$XYAML" .harness/nokey-check.yaml || die "harness/exercise/application.yaml must be after/'s without the key's block"
grep -qx '    problemdetail:' "$XLOC" && [ "$(grep -c 'problemdetails' "$XLOC")" = 0 ] || die "harness/exercise/tiffinbox-local.yaml must carry the singular key"
EXQ="Your turn: the README's copy still answers a missing path with Boot's four keys. Find the misspelt key, fix it, and read the content type."
grep -qxF -- "**Your turn:** ${EXQ#Your turn: }" exercise/README.md || die "exercise/README.md: the spoken exercise line"
[ "$(printf '%s\n' "$EXQ" | wc -w | tr -d ' ')" -le 25 ] || die "exercise: the spoken line is over 25 words"
echo "  exercise: one env -i shell - the README as written (problemdetail, singular) -> application/json, silent; the solution (problemdetails) -> application/problem+json; the shell in this unit's folder after each"

# "Every form serves it: the jar, the AOT jar, the native binary and the image ... the seven with the new hash, the missing customer as a
#  problem detail even for HTML, the four-rule four hundred, the four oh three and the four oh nine, on loopback ... no hint"
x forms '^  exit 0 · BUILD SUCCESS · stages it printed: 8 of the 8 it announces · its lines that say the metadata repository was downloaded over http, or failed to: 0 · offline: yes$'
x forms '^  file: Mach-O 64-bit executable · the demo token in its bytes: 0$'
x forms '^  built the previous tree, the profile native · offline: yes · exit 0$'
x forms "^  Spring's generated metadata \(spring-aot/main/resources/META-INF/native-image/com\.tiffinbox/tiffinbox-web/reachability-metadata\.json\) - the previous tree's against after/'s: reflection entries 666 -> 670 · types only the previous tree registers: none · only after/: org\.springframework\.boot\.webmvc\.autoconfigure\.ProblemDetailsExceptionHandler, .*org\.springframework\.web\.servlet\.mvc\.method\.annotation\.ResponseEntityExceptionHandler · entries that differ: 0\$"
x forms '^  resource entries: 26 -> 26 · the same: yes$'
x forms "^four forms, one tree: the seven \(masked\) 4 of 4 times $S466, the timestamp mask changing 0 lines · a name nobody has - curl's own Accept, and only HTML - 404 and the name, a problem detail: 8 of 8 · four rules broken, a problem detail with its errors: 4 of 4 · POST /shutdown without the token, a 403 problem detail: 4 of 4 · a new customer, 201: 4 of 4 · the same again, a 409 problem detail: 4 of 4\$"
x forms '^  loopback, form by form: the jar yes · the AOT jar yes · the binary yes · the image, published on 127\.0\.0\.1 alone yes$'
for t in '1 the jar:19450:2 the AOT jar' '2 the AOT jar:19456:3 the binary' '3 the binary:19458:4 the image' '4 the image:19457:four forms, one tree'; do lb_=${t%%:*}; r_=${t#*:}; p_=${r_%%:*}; nx_=${r_#*:}
  b=$(blk forms "$lb_ - " "$nx_")
  [ "$(aft "$(RQ "$(tq "$p_" /customers/Nobody)")" "$b")" = "$PDNOB" ] && [ "$(aft "$(RQ "$(url "$L_HTML" "$p_")")" "$b")" = "$PDNOB" ] && [ "$(aft "$(RQ "$(pq "$p_" "$B_BAD")")" "$b")" = "$PDBAD" ] || die "forms $lb_: the problem details, on its own port"
  [ "$(aft "$(RQ "$(xq "$p_")")" "$b")" = "$PD403" ] && [ "$(aftn 2 "$(RQ "$(pq "$p_" "$B_ASHA")")" "$b")" = "$PD409" ] || die "forms $lb_: the 403 and the 409"
  has "$b" "  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 0 · md5 $S466" "forms $lb_: the seven"; done
[ "$(n forms "^  Boot's first line: Starting AOT-processed TiffinBoxServer v1\.0\.0 using Java 25\.0\.4\.1\$")" = 2 ] && [ "$(n forms "^  Boot's first line: Starting AOT-processed TiffinBoxServer using Java 25\.0\.4\.1\$")" = 2 ] || die "forms: the AOT jar and the binary, AOT-processed, both starts"
[ "$(n forms '^  inside the container, listening: \[::\]:18425$')" = 2 ] && [ "$(n forms '^  docker port: 18425/tcp -> 127\.0\.0\.1:19457$')" = 2 ] || die "forms: the image, two containers, 18425 inside, published on 127.0.0.1:19457 alone"
x forms '^  its lines that say pull: 0 · '
x forms '^  the image saved \(docker save\): [1-9][0-9]* blobs, its [1-9][0-9]* layers among them, each read whole \(gzip ones unpacked\) · the demo token in them: 0$'
echo "  forms: 8 of 8 stages, offline, Mach-O, 0 tokens; the AOT metadata 666 -> 670, Boot's handler and ResponseEntityExceptionHandler among the new; the jar, the AOT jar, the binary, the image: the seven $S466 4 of 4 (mask 0), Nobody's problem detail 8 of 8, the 400 with errors, 403, 201, 409 4 of 4 each; loopback form by form; the image's layers 0 tokens"

cmp -s after/README.md ../c6-tiffinbox/README.md || echo "  (after/README.md and ../c6-tiffinbox/README.md differ - the anchor has moved past this unit's after/)" >&3
[ -z "$unpub" ] || die "no published hash for:$unpub - check the captures, then copy the md5s above into receipts.md5 and run again"
echo "c6-unit16: every capture 3/3 and = published; every spoken number asserted; 0 raw demo tokens in every capture, every log, the container's log, the image's layers and the binary; nothing of this run left on Docker"
