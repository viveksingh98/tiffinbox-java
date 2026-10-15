#!/bin/bash
XPATH=$PATH                                           # the PATH you started this with: the exercise's own shell gets it
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25.0.4.1 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# GRAALVM_HOME names a GraalVM JDK 25 (README.md, "The GraalVM"): the native build reads it. Without it, this script makes every
# capture that needs no GraalVM, filling .m2-demo on the way, then stops before the native build.
# Course 6 · Validation on the Way In - this unit's receipts. The anchor changes: Customer's four components carry Bean Validation's
# constraints (tiffinbox-core), and TiffinBoxServer's POST /customers marks its body @Valid and takes a BindingResult beside it - a
# body that breaks a rule is answered 400 with each broken field and its rule's message, before anything is stored; a body that
# keeps every rule goes on as before (201 and a Location, or 409 by H2's SQLSTATE 23505). Nine captures, each run three times and
# hashed; cap() DIES when a hash differs from receipts.md5; every number the video says is asserted at the bottom by a check that can
# fail; the demo token is masked (gsub), and the checks count 0 raw copies of it in every capture, in the log of every run - the
# container's included - in every file this unit ships, in the binary and in the image's layers.
#   constraints  the previous tree against after/: the files that differ, the two Java files' code lines and their diffs, the jar's
#                libraries; the seven on after/; Spring MVC's mapping logger at TRACE - the routes it registers, POST /customers with
#                its new parameter; Boot's web group at DEBUG - a body that breaks four rules, and one that keeps them, each with every
#                line the log gained for it
#   before       the previous tree: the request-body lesson's empty name, zero meals, a price of -5 and LUNCH - created, its Location
#                followed; a misspelt key - H2's refusal, a 500; what /customers lists
#   answer       A/B/A': the same bodies on after/ - each broken field and its message, 400, nothing stored; four meals; a new name
#                201 and the same name again 409 (A); a copy of after/ without the BindingResult - Boot's 400 and one WARN line (B);
#                A again (A')
#   validator    after/ with the harness's Who joined: the validator Spring MVC binds a body with, what it wraps, and the locale; the
#                refused body again, from a client that asks for German
#   typo         after/: the misspelt key, refused before the database is asked; an unknown property, still ignored; 2.7 meals, still
#                Jackson's refusal
#   methods      the harness's controllers: a constraint on a request parameter with no @Validated (Spring MVC's own method validation)
#                and with @Validated (Boot's post-processor's subclass), Boot's body naming each exception; then @Validated on a
#                final class - the start stops
#   keys         Boot's error keys: their metadata; spring.web.error.include-binding-errors=always on after/ (the method answers) and
#                on the copy without the BindingResult (Boot's body lists every field error, whole)
#   exercise     exercise/README.md's commands, then exercise/solution/SOLUTION.md's, read from the files and run as written, one after
#                the other in ONE shell a viewer could have: env -i, /bin/bash, started in this folder
#   forms        the native build of after/; what Spring's AOT step registers, on the previous tree and on after/; then four forms -
#                the jar, the AOT jar, the binary, the image: each one's address, the seven (masked), exit 0; then, on a second start of
#                each, the refused body (400, its four fields), a new customer (201, its Location followed), the same name again
#                (409) and POST /shutdown without the token (403)
# "The previous tree" is ../c6-unit10/after (the anchor before this change: the response lesson's frozen tree), COPIED under
# .harness/before; after/ is this unit's frozen copy of ../c6-tiffinbox after the change, COPIED under .harness/after. This script
# never writes into another unit's folder, and never builds a frozen tree in place. Every run of TiffinBox starts in a folder under
# .harness/ that holds a config tree with a fake token (secrets/), as the README asks - the container's too, mounted read-only.
# Commands are printed exactly as they run: each goes through eval. "$CURLSET" is the comparison set since the secrets lesson
# (../c5-unit11/curlset.sh: the seven requests, POST /shutdown with the token's header read from the file). "$M2" is this unit's
# own repository, .m2-demo. The harness - harness/probe/web/*.java (compiled with -parameters): Who, MethodPlain, MethodValidated,
# MethodFinal, Unbound - the course's, never TiffinBox's: outside com.tiffinbox, joined by --spring.main.sources on the extracted
# jar's class path; harness/shutdown.sh (POST /shutdown, the token read from its file) - is named on every capture that uses it.
# Every run passes options only. The seven always run on a fresh JVM, before any POST: a POST stores a customer, and three of the
# seven list customers; and every POST of one run names a customer no earlier POST of that run named, unless the capture says it
# posts a name again.
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
# string, epoch milliseconds) in the seven and wherever Spring's error body is printed; H2's constraint and index names, in the
# quoted string after "violation: ", become "…"; the number in a class name Spring generated ($$SpringCGLIB$$N) becomes "<n>"; where
# a native-image warning names the file it read an option from, the file's URL - or "null", which it prints when the path holds a
# space - becomes "…". Field errors - in Boot's errors array and in Spring MVC's WARN line - come in an order that moves between runs
# (Hibernate Validator hands them over as a set): they are printed sorted by field, and said so. A run's log lines are printed from
# their logger on (no time, no process id, no thread); Boot's first line is cut before " with PID". Long logs and answers go through
# a declared filter, and what it cuts is counted or bounded. No image, container or ID is printed but the base image's digest. No
# duration is captured: the native build's seconds, and the 20-minute bound, go to the terminal only.
# Ports (brief ⚑1, 19410-19419): after/'s jar 19410 · the previous tree 19411 · after/ with the harness joined 19412 · the copy
# without the BindingResult 19413 · the AOT jar 19414 · the harness's final class 19415 (it never listens) · the image 19417 · the
# binary 19418 · the exercise 19419 (19416 is never bound). 18425 (TiffinBox's default) and 8080 (Tomcat's) are checked free too,
# and never bound on this machine (18425 only inside a container).
# Docker names (no unit number): the image tiffinbox-valid:1.0.0 and the container tiffinbox-valid. Each is checked absent before
# the first run - a name already there may be yours, and this script removes only what it creates - and removed on every exit: the
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
IMG=tiffinbox-valid:1.0.0; BOX=tiffinbox-valid
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
for t in python3 curl rsync lsof unzip javac docker openssl; do command -v $t > /dev/null || die "$t is needed"; done
# A variable of yours must not become a property source, a JVM flag, a build setting, a native-image option or a docker build
# setting: every TIFFINBOX_*, SPRING_*, MANAGEMENT_*, SERVER_*, LOGGING_*, COMPOSE_*, BUILDKIT_* and BUILDX_* variable, DEBUG (Boot
# reads it as --debug), the variables that inject JVM flags, MAVEN_OPTS, MAVEN_ARGS, NATIVE_IMAGE_OPTIONS, DOCKER_BUILDKIT,
# DOCKER_DEFAULT_PLATFORM and SOURCE_DATE_EPOCH are removed first. GRAALVM_HOME stays: it says which GraalVM to use; so do
# DOCKER_HOST and DOCKER_CONTEXT: they say which Docker answers. (SPRING_WEB_ERROR_INCLUDE_BINDING_ERRORS of yours would change
# Boot's error body in every capture; SERVER_ADDRESS or SERVER_PORT beat the alias; TIFFINBOX_SHUTDOWN_TOKEN the config tree.)
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
PREV=../c6-unit10/after                              # the previous tree: the anchor before this change - read, copied
[ -e secrets ] && die "this folder holds a secrets/ - remove it: every run here starts in a folder under .harness/"
for t in "$PREV" after; do
  [ -f "$t/pom.xml" ] && [ -f "$t/README.md" ] && [ -f "$t/Dockerfile" ] && [ -f "$t/.dockerignore" ] || die "the tree $t (its pom.xml, README.md, Dockerfile or .dockerignore) is missing"
  [ -e "$t/secrets" ] || [ -e "$t/target" ] || [ -e "$t/tiffinbox-web/target" ] || [ -e "$t/tiffinbox-core/target" ] && die "$t holds a secrets/ or a target/ - it is a frozen copy, never built in place"
  grep -qx 'secrets/' "$t/.dockerignore" || die "$t's .dockerignore no longer keeps secrets/ out of a build context"; done
M2="$PWD/.m2-demo"; U="$PWD"; UP="$(cd .. && pwd)"; ME="$(id -un)"
W=tiffinbox-web/src/main/java/com/tiffinbox/web     # the web module's Java sources, in a tree
C=tiffinbox-core/src/main/java/com/tiffinbox        # the core module's Java sources, in a tree
JARP=tiffinbox-web/target/tiffinbox-web-1.0.0.jar    # the executable jar, in a tree's web module
BIN=tiffinbox-web/target/tiffinbox-web               # the binary native:compile-no-fork writes, in a tree's web module
TF=secrets/tiffinbox/shutdown-token                  # the config tree's file for tiffinbox.shutdown-token
# The demo token. FAKE, and meant to look it: it guards nothing but a demo server on 127.0.0.1 that every capture stops. It is
# written into .harness/*/secrets/ (git-ignored) when this script runs, and no capture prints it: see mask().
TOKEN=not-a-real-token-demo-only
[ ${#TOKEN} = 26 ] || die "the demo token must be 26 characters: the published captures name its length"
CURLSET=../c5-unit11/curlset.sh                      # the comparison set: the seven requests, POST /shutdown with the header
[ -f "$CURLSET" ] || die "$CURLSET is missing"
HWS='harness/probe/web/MethodFinal.java harness/probe/web/MethodPlain.java harness/probe/web/MethodValidated.java harness/probe/web/Unbound.java harness/probe/web/Who.java'
for f in harness/shutdown.sh $HWS exercise/README.md exercise/solution/SOLUTION.md README.md; do [ -f "$f" ] || die "$f is missing"; done
[ "$(ls harness/probe/web | paste -sd' ' -)" = 'MethodFinal.java MethodPlain.java MethodValidated.java Unbound.java Who.java' ] || die "harness/probe/web holds another file: javac compiles all of it"

# The ports and the Docker names, BEFORE anything is wiped (a survivor of an interrupted run answers POST /shutdown only with its
# token, which lives in .harness/ - so the message names the process to kill).
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
for p in 18425 8080 19410 19411 19412 19413 19414 19415 19416 19417 19418 19419; do
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
# Boot's web group at DEBUG (the embedded-Tomcat lesson's line); Spring MVC's mapping logger at TRACE, the kitchen at DEBUG (the
# request-mapping lesson's); POST /shutdown without the token (the secrets lesson's line); the request-body lesson's POST; the
# response lesson's line, that POST with its answer's Location printed - and this unit's line in the anchor's README: the same
# with the request-body lesson's empty name as its body
R_WEB=$(readme "$J --logging.level.web=debug")
R_SCAN=$(readme "$J --logging.level.kitchen=debug --logging.level.org.springframework.web.servlet.mvc.method.annotation.RequestMappingHandlerMapping=trace")
R_403=$(readme "curl -s -w ' %{http_code}\n' -X POST http://127.0.0.1:18431/shutdown")
R_ADD=$(readme "curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '{\"name\":\"Asha\",\"mealsPerDay\":2,\"pricePerMeal\":110,\"mealType\":\"VEG\"}' http://127.0.0.1:18431/customers")
R_LOC=$(readme "curl -s -w ' %{http_code} · Location: [%header{location}]\n' -H 'Content-Type: application/json' --data '{\"name\":\"Asha\",\"mealsPerDay\":2,\"pricePerMeal\":110,\"mealType\":\"VEG\"}' http://127.0.0.1:18431/customers")
R_BAD=$(readme "curl -s -w ' %{http_code} · Location: [%header{location}]\n' -H 'Content-Type: application/json' --data '{\"name\":\"\",\"mealsPerDay\":0,\"pricePerMeal\":-5,\"mealType\":\"LUNCH\"}' http://127.0.0.1:18431/customers")
[ "${R_WEB#"$J "}" = '--logging.level.web=debug' ] || die "the README's options"
O_WEB=${R_WEB#"$J "}
LW=' · Location: [%header{location}]'
r=${R_LOC/"$LW"/}; [ "$r" = "$R_ADD" ] || die "the anchor's Location line must be the request-body lesson's POST with the Location printed, and nothing else"
# This unit's own lines (README.md, "The commands this unit adds") - each asserted to be exactly that: the anchor's run line with one
# of Boot's error keys (keys, methods); the anchor's refused-body line with a client's Accept-Language header (validator); the
# harness's javac line, against after/'s extracted jar, with -parameters (constraints)
mine() { grep -m1 -xF -- "$1" README.md > /dev/null || die "README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
L_KEYS=$(mine "$J --spring.web.error.include-binding-errors=always")
L_EXC=$(mine "$J --spring.web.error.include-exception=true")
L_DE=$(mine "curl -s -w ' %{http_code} · Location: [%header{location}]\n' -H 'Accept-Language: de' -H 'Content-Type: application/json' --data '{\"name\":\"\",\"mealsPerDay\":0,\"pricePerMeal\":-5,\"mealType\":\"LUNCH\"}' http://127.0.0.1:18431/customers")
L_JAVAC=$(mine 'javac -parameters -d .harness/hc -cp ".harness/after/tiffinbox-web/target/extracted/lib/*:.harness/after/tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar" harness/probe/web/MethodFinal.java harness/probe/web/MethodPlain.java harness/probe/web/MethodValidated.java harness/probe/web/Unbound.java harness/probe/web/Who.java')
[ "${L_JAVAC#* -cp \"*\" }" = "$HWS" ] || die "the harness's javac line must compile the five files in harness/probe/web, and nothing else"
O_KEYS=${L_KEYS#"$J "}; O_EXC=${L_EXC#"$J "}
[ "$O_KEYS" = '--spring.web.error.include-binding-errors=always' ] && [ "$O_EXC" = '--spring.web.error.include-exception=true' ] || die "the keys' lines must be the anchor's run line with one option each, and nothing else"
r=${L_DE/" -H 'Accept-Language: de'"/}; [ "$r" = "$R_BAD" ] || die "the German line must be the anchor's refused-body line with -H 'Accept-Language: de', and nothing else"
# ADATA: the request-body lesson's JSON body; PREF: its curl and options, before the body; LPREF: the Location line's. pc()
# and plc() build the same lines for another port, path and body - and must give the README's lines back
ADATA=${R_ADD#* --data \'}; ADATA=${ADATA%%\' http://*}
BDATA=${R_BAD#* --data \'}; BDATA=${BDATA%%\' http://*}
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
# the README writes it; plc the same for the Location line; lc 'LINE' PORT PATH 'BODY' the same for any line of that shape
pc() { printf "%s --data '%s' %s\n" "$PREF" "$3" "$(qurl "$1" "$2")"; }
plc() { printf "%s --data '%s' %s\n" "$LPREF" "$3" "$(qurl "$1" "$2")"; }
lc() { printf "%s --data '%s' %s\n" "${1% --data *}" "$4" "$(qurl "$2" "$3")"; }
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
undock() { local c=${1#cd * && }; c=${c/--progress=plain /}; c=${c/" $UARG"/}; c=${c//$IMG/tiffinbox-docker:1.0.0}; c=${c/--name $BOX /--name tiffinbox }; c=${c/127.0.0.1:1941?:18425/127.0.0.1:18431:18425}; printf '%s\n' "$c"; }
[ "$(undock "$(dbuild .harness/x)")" = "$R_DBUILD" ] || die "not the README's build line with the declared changes: $(dbuild .harness/x)"
[ "$(undock "$(drun .harness/x 19417)")" = "$R_DRUN" ] || die "not the README's run line with the declared changes: $(drun .harness/x 19417)"
C_PRE=$(off .harness/pre "$R_INSTALL" install)
for c in "$C_PRE" "$(off .harness/x "$R_PLAIN" package)" "$(off .harness/x "$R_PNAT" package)" "$(off .harness/x "$R_NATIVE")"; do
  r=$(dev "$c"); [ "$r" = "$R_PLAIN" ] || [ "$r" = "$R_PNAT" ] || [ "$r" = "$R_INSTALL" ] || [ "$r" = "$R_NATIVE" ] || die "not a README line with the offline changes: $c"; done
[ "$(exe "$(at .harness/x 19410 "$R_RUN")")" = 'cd .harness/x && exec java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19410' ] || die "exe()"
[ "$(hcp .harness/x 19412 probe.web.Who "$O_EXC")" = 'cd .harness/x && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19412 --spring.main.sources=probe.web.Who --spring.web.error.include-exception=true' ] || die "hcp()"
[ "$(bc 19410 /customers/Asha)" = "curl -s -w ' %{http_code}\n' http://127.0.0.1:19410/customers/Asha" ] || die "bc()"
[ "$(pc 18431 /customers "$ADATA")" = "$R_ADD" ] && [ "$(plc 18431 /customers "$ADATA")" = "$R_LOC" ] && [ "$(plc 18431 /customers "$BDATA")" = "$R_BAD" ] && [ "$(lc "$L_DE" 18431 /customers "$BDATA")" = "$L_DE" ] && [ "$ADATA" = '{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' ] && [ "$BDATA" = '{"name":"","mealsPerDay":0,"pricePerMeal":-5,"mealType":"LUNCH"}' ] || die "pc(), plc(), lc(): not the README's POST lines"
echo "  the commands: after/README.md gives all 20 lines this script runs or derives from; README.md the 4 this unit adds"

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
# vwarn FROM: the WARN lines after line FROM, as logl prints them - but a line that lists field errors (Spring MVC's
# MethodArgumentNotValidException) is cut after "with N errors", and the field errors it lists follow, one a line: the field, the
# value it was given, the rule's message - sorted by field, because Hibernate Validator hands them over as a set, and their order
# moves between runs (README.md, Masks); the codes and arguments each one carries are counted, not shown
vwarn() { python3 - .harness/run.out "$1" <<'PY'
import re, sys
lines = open(sys.argv[1], encoding="utf-8", errors="replace").read().splitlines()[int(sys.argv[2]):]
for l in lines:
    m = re.search(r" (WARN) [0-9]+ --- \[[^]]*\] (.*?) +: (.*)$", l)
    if not m: continue
    lv, lg, msg = m.group(1), m.group(2).strip(), m.group(3)
    msg = re.sub(r"@[0-9a-f]{5,}", "@…", msg)
    k = re.search(r" with (\d+) errors?: \[", msg)
    if not k: print("    %s %s: %s" % (lv, lg, msg)); continue
    print("    %s %s: %s: …" % (lv, lg, msg[:k.end() - 3]))
    parts = msg[k.end() - 1:].split("[Field error in object '")[1:]
    rows = []
    for p in parts:
        f = re.search(r"on field '([^']*)': rejected value \[(.*?)\]; codes \[", p)
        dm = p.rfind("; default message [")
        rows.append((f.group(1), f.group(2), p[dm + len("; default message ["):p.index("]", dm + len("; default message ["))]))
    print("      the field errors it lists: %d, sorted by field (the order moves between runs) - each: its field, the value it was given, the rule's message; its codes and arguments not shown:" % len(rows))
    for f, v, d in sorted(rows): print("        %s [%s]: %s" % (f, v, d))
PY
}
# wans FROM FILE: an answer (FILE) and the WARN lines its request added after line FROM, at the level the run was started with:
# the answer's last line ends with their count, each one follows (vwarn: a field-error line cut, its errors sorted)
wans() { local w; settle; w=$(logl "$1" WARN | grep -c . || true)
  awk -v w="$w" '{ l[NR] = $0 } END { for (i = 1; i <= NR; i++) print "  " l[i] (i == NR ? " · WARN lines it added: " w : "") }' "$2"
  [ "$w" = 0 ] || vwarn "$1"; }
# ask PORT PATH: the one-customer line (body and status), its path PATH, printed and run, the answer's timestamp masked; then the
# WARN lines the request added (wans)
ask() { local c n0; n0=$(mark); c=$(bc "$@"); echo "\$ $c"; (eval "$c") 2>&1 < /dev/null | tsmask > .harness/ask.txt; wans "$n0" .harness/ask.txt; }
# locof FILE: the Location an answer printed by the Location line holds - between "Location: [" and the line's last "]"
locof() { sed -n 's/^.* · Location: \[\(.*\)\]$/\1/p' "$1" | tail -1; }
# pl PORT 'BODY' [PATH]: the Location line in the anchor's README - a POST with its answer's Location printed - its port, path
# (/customers) and body swapped, printed and run, the answer's timestamp masked; the Location it printed kept in .harness/loc.txt;
# then the WARN lines its request added (wans). lpl 'LINE' PORT 'BODY': the same for another line of that shape (the German one)
pl() { local c n0; n0=$(mark); c=$(plc "$1" "${3:-/customers}" "$2"); echo "\$ $c"; (eval "$c") 2>&1 < /dev/null | tsmask > .harness/ask.txt; locof .harness/ask.txt > .harness/loc.txt; wans "$n0" .harness/ask.txt; }
lpl() { local c n0; n0=$(mark); c=$(lc "$1" "$2" /customers "$3"); echo "\$ $c"; (eval "$c") 2>&1 < /dev/null | tsmask > .harness/ask.txt; locof .harness/ask.txt > .harness/loc.txt; wans "$n0" .harness/ask.txt; }
# fol: the Location the last POST printed, followed with the binding lesson's one-customer line (fo) - printed and run, the answer's
# timestamp masked; then the WARN lines it added
fol() { local c n0; n0=$(mark); c=$(fo); echo "\$ $c"; (eval "$c") 2>&1 < /dev/null | tsmask > .harness/ask.txt; wans "$n0" .harness/ask.txt; }
# erec FROM [BOUND]: each ERROR record the log gained after line FROM - its level, its logger and its message (H2's constraint and index
# names, the quoted string after "violation: ", made "…"), then the record's next line when it is not blank (the SQL statement, H2's
# error code at its end); then its stack frames, bounded (over BOUND - 50 unless named), its other lines (the exception printed again, a blank line), counted, none shown; and how
# many WARN lines came with it
erec() { settle; awk -v from="$1" -v bd="${2:-50}" '
  NR <= from { next }
  / [A-Z]+ [0-9]+ --- \[/ { inr = 0 }
  / (WARN|ERROR) [0-9]+ --- \[/ { s = $0; i = index(s, " --- ["); s = substr(s, i + 6); i = index(s, "] "); s = substr(s, i + 2)
    i = index(s, " : "); lg = substr(s, 1, i - 1); sub(/ +$/, "", lg); m = substr(s, i + 3); gsub(/violation: "[^"]*"/, "violation: \"…\"", m)
    print "    " $2 " " lg ": " m; nx = 1; inr = 1; if ($2 == "WARN") w++; next }
  nx == 1 { nx = 0; if (NF == 0) { ot++; next }; print "      " $0; next }
  /^\tat / { fr++; next }
  inr { ot++ }
  END { print "    its stack frames: " (fr > bd ? "over " bd : fr + 0) ", its other lines: " (ot + 0) " - none shown · WARN lines it added: " (w + 0) }' .harness/run.out; }
# p5 PORT 'BODY': a POST with its Location printed that ends in a 500 - the answer, then the log's record of it (erec); ask5 PORT
# PATH: the one-customer line that ends in a 500, the same way, its frames bounded at 40 (a validation failure's trace is shorter than
# H2's)
p5() { local c n0; n0=$(mark); c=$(plc "$1" /customers "$2"); echo "\$ $c"; (eval "$c") 2>&1 < /dev/null | tsmask | sed 's/^/  /'; erec "$n0"; }
ask5() { local c n0; n0=$(mark); c=$(bc "$1" "$2"); echo "\$ $c"; (eval "$c") 2>&1 < /dev/null | tsmask | sed 's/^/  /'; erec "$n0" 40; }
# rp 'COMMAND': a curl line, printed and run, the answer indented, the timestamp masked
rp() { echo "\$ $1"; (eval "$1") 2>&1 < /dev/null | tsmask | sed 's/^/  /'; }
# rl PORT 'BODY' / rfol: pl and fol for the four forms - the answer printed, no WARN count (a container's log is read only when it
# has stopped)
rl() { local c; c=$(plc "$1" /customers "$2"); echo "\$ $c"; (eval "$c") 2>&1 < /dev/null | tsmask > .harness/ask.txt; locof .harness/ask.txt > .harness/loc.txt; sed 's/^/  /' .harness/ask.txt; }
rfol() { local c; c=$(fo); echo "\$ $c"; (eval "$c") 2>&1 < /dev/null | tsmask | sed 's/^/  /'; }
# dbg FROM: every line the log gained after line FROM, from its logger on (logger: message) - the date in an error map Spring MVC
# writes (timestamp=...,) made "…" (README.md, Masks); dreq 'COMMAND': at DEBUG - the command printed and run, its answer (the
# timestamp masked), then every line the log gained for it, counted
dbg() { awk -v from="$1" 'NR > from && / [A-Z]+ [0-9]+ --- \[/ { s = $0; i = index(s, " --- ["); s = substr(s, i + 6); i = index(s, "] "); s = substr(s, i + 2)
    i = index(s, " : "); lg = substr(s, 1, i - 1); sub(/ +$/, "", lg); m = substr(s, i + 3); gsub(/timestamp=[^,]*,/, "timestamp=…,", m); print "    " lg ": " m }' .harness/run.out; }
dreq() { local n0 k; n0=$(mark); echo "\$ $1"; (eval "$1") 2>&1 < /dev/null | tsmask | sed 's/^/  /'; settle
  k=$(dbg "$n0" | grep -c . || true); echo "  the lines the log gained for it, Boot's web group at DEBUG (logger: message) - all $k:"; dbg "$n0"; }
# reg: Spring MVC's RequestMappingHandlerMapping, its lines before Boot's started line - each record's logger, level and message, and
# under it the blocks it lists, a block's routes sorted (the order it registers them in is a reflection's)
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
    END { flush() }' .harness/pre.txt; }
# blkraw FROM TO: this capture so far, the lines after the line that starts with FROM, up to the next line that starts with TO (to
# the end when TO is empty); asame A B A2 B2: yes when A's block (A up to B) and A2's (A2 up to B2), their labels aside, are the same
# line for line - an A' against its A
blkraw() { awk -v a="$1" -v b="$2" 'index($0, a) == 1 { f = 1; next } b != "" && index($0, b) == 1 { f = 0 } f' .harness/cap.raw; }
asame() { [ "$(blkraw "$1" "$2")" = "$(blkraw "$3" "$4")" ] && [ -n "$(blkraw "$3" "$4")" ] && echo yes || echo no; }
# bmeta JAR KEY: Boot's own metadata for a key - its type, its default, its description, and its deprecation when it has one - read
# from JAR in after/'s extracted lib
bmeta() { python3 - ".harness/after/tiffinbox-web/target/extracted/lib/$1" "$2" <<'PY'
import json, os, sys, zipfile
d = json.loads(zipfile.ZipFile(sys.argv[1]).read("META-INF/spring-configuration-metadata.json"))
p = {x["name"]: x for x in d.get("properties", [])}; j = os.path.basename(sys.argv[1]); k = sys.argv[2]; e = p.get(k)
if not e: print("  Boot's metadata (%s): %s - in none of its entries" % (j, k))
else:
    dv = e.get("defaultValue"); dp = e.get("deprecation")
    print("  Boot's metadata (%s) - %s · its type: %s · its default: %s · its description: %s%s" % (j, k, e.get("type", "none").rsplit(".", 1)[-1], "none" if dv is None else json.dumps(dv), e.get("description", "none"),
          "" if not dp else " · deprecated: level %s, since %s, replaced by %s" % (dp.get("level", "none"), dp.get("since", "none"), dp.get("replacement", "none"))))
PY
}
WARNS() { echo "  WARN lines in this run's log, at Boot's default level: $(logl 0 WARN | grep -c . || true) · ERROR lines: $(logl 0 ERROR | grep -c . || true)"; }

# ---- constraints: the change, registered and read ----------------------------------------------------------------------------
# The code lines (neither comment nor blank, nor an import) that name what the change adds: a constraint, in Customer.java; @Valid
# (never @Validated), a BindingResult and @Validated, in TiffinBoxServer.java - counted before and after
CONRE='@(NotBlank|NotNull|Min|Max|Pattern)([^A-Za-z]|$)'
acount() { grep -oE "@$2([^A-Za-z]|\$)" "$1" | wc -l | tr -d ' '; }
cwhat() { printf '@NotBlank %s · @NotNull %s · @Min %s · @Max %s · @Pattern %s' "$(acount "$1" NotBlank)" "$(acount "$1" NotNull)" "$(acount "$1" Min)" "$(acount "$1" Max)" "$(acount "$1" Pattern)"; }
cdiff() { local b=$1 a=$2; diff -U0 "$b" "$a" | tail -n +3 > .harness/code.diff || true
  echo "  its code lines' diff (diff -U0 of the lines above, its file names cut) - hunks: $(grep -c '^@@ ' .harness/code.diff || true) · lines out: $(grep -c '^-' .harness/code.diff || true) · in: $(grep -c '^+' .harness/code.diff || true) - whole:"
  sed 's/^/    /' .harness/code.diff; }
constraints() { local f n m c
  echo "the previous tree and after/, both copied under .harness/ with a config tree, each built with the README's line (offline):"
  copy "$PREV" .harness/before; copy after .harness/after
  pbuild .harness/before "the previous tree"; pbuild .harness/after "after/"
  echo "both jars extracted (the README's line) - the class path the harness runs on:"
  extract .harness/before; extract .harness/after
  echo "the harness, compiled against after/'s own jar - with -parameters:"
  c=$L_JAVAC
  echo "\$ $c"; rm -rf .harness/hc; (eval "$c") > .harness/javac.log 2>&1 < /dev/null || { cat .harness/javac.log >&3; die "the harness did not compile against after/'s jar"; }
  echo "  exit 0 · its classes: $(cd .harness/hc && find . -name '*.class' | sed 's#^\./##' | sort | paste -sd' ' -)"
  echo "the files that differ:"
  echo "\$ diff -rq -x target -x secrets .harness/before .harness/after"
  diff -rq -x target -x secrets .harness/before .harness/after | sed 's/^/  /' || true
  (cd after && find . -type f | sed 's#^\./##' | sort) > .harness/files.txt
  n=0; m=0; while IFS= read -r f; do m=$((m + 1)); cmp -s ".harness/before/$f" ".harness/after/$f" && n=$((n + 1)); done < .harness/files.txt
  echo "  after/'s files: $m · byte for byte the previous tree's: $n · those above differ: $((m - n))"
  f="$C/Customer.java"
  code ".harness/before/$f" > .harness/cb.txt; code ".harness/after/$f" > .harness/ca.txt
  grep -v '^import ' .harness/cb.txt > .harness/cbi.txt || true; grep -v '^import ' .harness/ca.txt > .harness/cai.txt || true
  echo "  Customer.java: $(lines ".harness/before/$f") lines -> $(lines ".harness/after/$f") · its lines that are neither comment nor blank: $(wc -l < .harness/cb.txt | tr -d ' ') -> $(wc -l < .harness/ca.txt | tr -d ' '), of them - imports left out - naming a constraint: $(grep -cE "$CONRE" .harness/cbi.txt || true) -> $(grep -cE "$CONRE" .harness/cai.txt || true) · the constraints they name: $(cwhat .harness/cbi.txt) -> $(cwhat .harness/cai.txt)"
  cdiff .harness/cb.txt .harness/ca.txt
  f="$W/TiffinBoxServer.java"
  code ".harness/before/$f" > .harness/fb.txt; code ".harness/after/$f" > .harness/fa.txt
  grep -v '^import ' .harness/fb.txt > .harness/fbi.txt || true; grep -v '^import ' .harness/fa.txt > .harness/fai.txt || true
  echo "  TiffinBoxServer.java: $(lines ".harness/before/$f") lines -> $(lines ".harness/after/$f") · its lines that are neither comment nor blank: $(wc -l < .harness/fb.txt | tr -d ' ') -> $(wc -l < .harness/fa.txt | tr -d ' '), of them - imports left out - naming @Valid: $(grep -cE '@Valid([^A-Za-z]|$)' .harness/fbi.txt || true) -> $(grep -cE '@Valid([^A-Za-z]|$)' .harness/fai.txt || true) · a BindingResult: $(grep -c 'BindingResult' .harness/fbi.txt || true) -> $(grep -c 'BindingResult' .harness/fai.txt || true) · @Validated: $(grep -c '@Validated' .harness/fbi.txt || true) -> $(grep -c '@Validated' .harness/fai.txt || true)"
  cdiff .harness/fb.txt .harness/fa.txt
  diff .harness/before/README.md .harness/after/README.md > .harness/file.diff || true
  echo "  README.md - the anchor's README: lines added $(grep -c '^> ' .harness/file.diff || true), removed $(grep -c '^< ' .harness/file.diff || true) - its new section and the history notes the change made false (not shown)"
  libs .harness/before/$JARP > .harness/lb.txt; libs .harness/after/$JARP > .harness/la.txt
  echo "the executable jar's BOOT-INF/lib: $(wc -l < .harness/lb.txt | tr -d ' ') jars -> $(wc -l < .harness/la.txt | tr -d ' ') · the same names: $(cmp -s .harness/lb.txt .harness/la.txt && echo yes || echo no)"
  echo "the seven - after/, the README's run line, port 19410, a fresh JVM:"
  start "$(at .harness/after 19410 "$R_RUN")"; up 19410; ready 19410; seven 19410 .harness/after
  echo "registered - after/, the request-mapping lesson's line - Spring MVC's mapping logger at TRACE, the kitchen at DEBUG - port 19410:"
  start "$(at .harness/after 19410 "$R_SCAN")"; up 19410; ready 19410; reg
  stop 19410 .harness/after
  echo "read - after/, the embedded-Tomcat lesson's line - Boot's web group at DEBUG - port 19410: the anchor's refused-body line, then the request-body lesson's POST:"
  start "$(at .harness/after 19410 "$R_WEB")"; up 19410; ready 19410
  dreq "$(url "$R_BAD" 19410)"
  dreq "$(url "$R_ADD" 19410)"
  stop 19410 .harness/after; }

# ---- before: what the previous tree stores --------------------------------------------------------------------------------------
ROHAN='{"name":"Rohan","mealsPerDay":1,"pricePerMeal":110,"mealTyp":"VEG"}'
before() {
  echo "the previous tree, the README's run line, port 19411 - the anchor's refused-body line (the request-body lesson's empty name, zero meals, a price of -5, LUNCH), its Location followed; a misspelt key; then every customer:"
  start "$(at .harness/before 19411 "$R_RUN")"; up 19411; ready 19411
  pl 19411 "$BDATA"; fol
  p5 19411 "$ROHAN"
  ask 19411 /customers
  WARNS
  stop 19411 .harness/before; }

# ---- answer: A/B/A' - the BindingResult ---------------------------------------------------------------------------------------
TARA='{"name":"Tara","mealsPerDay":4,"pricePerMeal":110,"mealType":"VEG"}'
# plantb FILE OUT: TiffinBoxServer.java without the BindingResult - the parameter out of add's signature, and the three lines that
# answer from it deleted - a planted copy for B
PLANTA='    ResponseEntity<?> add(@Valid @RequestBody Customer customer, BindingResult errors) throws SQLException {'
PLANTB='    ResponseEntity<?> add(@Valid @RequestBody Customer customer) throws SQLException {'
PLANT1='        if (errors.hasErrors()) {'
PLANT2='            return ResponseEntity.badRequest().body(fieldMessages(errors));'
PLANT3='        }'
plantb() { awk -v a="$PLANTA" -v b="$PLANTB" -v l1="$PLANT1" -v l2="$PLANT2" -v l3="$PLANT3" '
    k == 1 { if ($0 != l1) bad = 1; k++; next } k == 2 { if ($0 != l2) bad = 1; k++; next } k == 3 { if ($0 != l3) bad = 1; k = 0; next }
    $0 == a { print b; n++; k = 1; next } { print } END { exit (n == 1 && !bad ? 0 : 1) }' "$1" > "$2" || die "plantb: add's signature and the three lines that answer from its BindingResult are not in $1 exactly once"; }
answera() { start "$(at .harness/after 19410 "$R_RUN")"; up 19410; ready 19410
  pl 19410 "$BDATA"; ask 19410 /customers
  echo "  four meals a day; then a new name, and the same name again:"
  pl 19410 "$TARA"; pl 19410 "$ADATA"; pl 19410 "$ADATA"
  WARNS
  stop 19410 .harness/after; }
answer() {
  echo "A - after/, the README's run line, port 19410 - the anchor's refused-body line, then every customer:"
  answera
  echo "B - a copy of after/ without the BindingResult - its diff: the parameter out, and the three lines that answer from it - then built the same way, port 19413:"
  copy after .harness/plant; plantb "after/$W/TiffinBoxServer.java" ".harness/plant/$W/TiffinBoxServer.java"
  echo "\$ diff -U0 after/$W/TiffinBoxServer.java .harness/plant/$W/TiffinBoxServer.java"
  diff -U0 "after/$W/TiffinBoxServer.java" ".harness/plant/$W/TiffinBoxServer.java" | tail -n +3 | sed 's/^/  /' || true
  pbuild .harness/plant "the copy"
  start "$(at .harness/plant 19413 "$R_RUN")"; up 19413; ready 19413
  pl 19413 "$BDATA"; ask 19413 /customers
  WARNS
  stop 19413 .harness/plant
  echo "A' - A again, on a fresh JVM:"
  answera
  echo "A' against A, its label aside, line for line the same: $(asame 'A - after/' 'B - a copy' "A' - A again" '')"; }

# ---- validator: who checks the body -----------------------------------------------------------------------------------------------
validator() {
  echo "after/ with the harness's Who joined, port 19412 - the validator Spring MVC binds a request's body with, read off the running application:"
  start "$(hcp .harness/after 19412 probe.web.Who)"; up 19412; ready 19412
  ask 19412 /probe/who/validator
  echo "  the anchor's refused-body line, then this unit's line - the same, from a client whose Accept-Language header asks for German:"
  pl 19412 "$BDATA"; lpl "$L_DE" 19412 "$BDATA"
  WARNS
  stop 19412 .harness/after; }

# ---- typo: the misspelt key, and what validation does not see --------------------------------------------------------------------
KIRAN='{"name":"Kiran","mealsPerDay":1,"pricePerMeal":110,"mealType":"VEG","loyaltyPoints":5}'
MOHAN='{"name":"Mohan","mealsPerDay":2.7,"pricePerMeal":110,"mealType":"VEG"}'
typo() {
  echo "after/, the README's run line, port 19410 - a misspelt key; a full body with a property the record does not have; two point seven meals:"
  start "$(at .harness/after 19410 "$R_RUN")"; up 19410; ready 19410
  pl 19410 "$ROHAN"; ask 19410 /customers/Rohan
  pl 19410 "$KIRAN"; fol
  pl 19410 "$MOHAN"; ask 19410 /customers/Mohan
  WARNS
  stop 19410 .harness/after; }

# ---- methods: which validation runs -----------------------------------------------------------------------------------------------
# failed PORT: a start that must end by itself - the JVM polled until it exits (up to 120 s), its exit code; Boot's first and
# started lines; then the log's WARN and ERROR records (from their logger on), the exception line under them, every "Caused by:"
# line, and the stack frames, bounded, none shown; the log counted (logtok)
failed() { local i=0 e=0
  while kill -0 "$pid" 2> /dev/null && [ $i -lt 480 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$pid" 2> /dev/null && { kill "$pid"; die "it still ran 120 s after its start"; }
  wait "$pid" || e=$?; pid=""
  echo "  exit $e · Boot's first line: $(first .harness/run.out) · Boot's started line: $(started .harness/run.out | grep -c . || true) · listening on $1 now: $(listeners "$1")"
  echo "  its WARN and ERROR records (logger: message), the exception under them, and every Caused by line:"
  awk '/ (WARN|ERROR) [0-9]+ --- \[/ { s = $0; i = index(s, " --- ["); s = substr(s, i + 6); i = index(s, "] "); s = substr(s, i + 2)
      i = index(s, " : "); lg = substr(s, 1, i - 1); sub(/ +$/, "", lg); print "    " $2 " " lg ": " substr(s, i + 3); next }
    /^[a-z][A-Za-z0-9_]*(\.[A-Za-z0-9_$]+)+(Exception|Error): / { print "    " $0; next }
    /^Caused by: / { print "    " $0; next }
    /^\tat / { fr++ }
    END { print "    its stack frames: " (fr > 40 ? "over 40" : fr + 0) " - none shown" }' .harness/run.out
  logtok; }
methods() {
  bmeta spring-boot-autoconfigure-4.1.1.jar spring.web.error.include-exception
  echo "after/ with the harness's Who, MethodPlain and MethodValidated joined, and this unit's include-exception option, port 19412:"
  start "$(hcp .harness/after 19412 probe.web.Who,probe.web.MethodPlain,probe.web.MethodValidated "$O_EXC")"; up 19412; ready 19412
  ask 19412 /probe/who/proxies
  echo "  a constraint on a request parameter (@Min(1) int meals), no @Validated on the class - MethodPlain:"
  ask 19412 '/probe/method/plain?meals=1'; ask 19412 '/probe/method/plain?meals=0'
  echo "  the same route with @Validated on the class - MethodValidated:"
  ask 19412 '/probe/method/validated?meals=1'; ask5 19412 '/probe/method/validated?meals=0'
  WARNS
  stop 19412 .harness/after
  echo "who resolved the 400 - MethodPlain joined, Boot's web group at DEBUG (the embedded-Tomcat lesson's option), port 19412:"
  start "$(hcp .harness/after 19412 probe.web.MethodPlain "$O_WEB")"; up 19412; ready 19412
  dreq "$(bc 19412 '/probe/method/plain?meals=0')"
  stop 19412 .harness/after
  echo "a final class - the same route with @Validated, on a class that is final, MethodFinal joined, port 19415:"
  start "$(hcp .harness/after 19415 probe.web.MethodFinal)"
  failed 19415; }

# ---- keys: Boot's error keys ----------------------------------------------------------------------------------------------------
# berr: an answer of Boot's error body, as pl wrote it (.harness/ask.txt): its keys, its status - then its errors array, sorted by
# field (the order moves between runs: README.md, Masks), each entry's keys counted, each entry whole (its keys sorted)
# plb PORT 'BODY': the Location line, that body, printed and run, the answer's timestamp masked - the answer through berr, never
# printed raw; then the WARN lines its request added (vwarn)
plb() { local c n0 w; n0=$(mark); c=$(plc "$1" /customers "$2"); echo "\$ $c"; (eval "$c") 2>&1 < /dev/null | tsmask > .harness/ask.txt; berr
  settle; w=$(logl "$n0" WARN | grep -c . || true); echo "  WARN lines it added: $w"; [ "$w" = 0 ] || vwarn "$n0"; }
berr() { python3 - .harness/ask.txt <<'PY'
import json, sys
l = open(sys.argv[1], encoding="utf-8").read().splitlines()[-1]
b, _, s = l.rpartition(" 400 · Location: ")
d = json.loads(b)
print("  Boot's body - its keys: %s · its status %s · then curl's: 400 · Location: %s" % (" ".join(sorted(d)), d.get("status"), s))
e = sorted(d.get("errors", []), key=lambda x: x.get("field", ""))
ks = sorted(set(k for x in e for k in x))
print("  its errors: %d entries, sorted by field (the order moves between runs) - each with the same %d keys: %s" % (len(e), len(ks), " ".join(ks)) if all(sorted(x) == ks for x in e) else "  its errors: %d entries, their keys differ" % len(e))
for x in e: print("    " + json.dumps(x, sort_keys=True, separators=(",", ":"), ensure_ascii=False))
PY
}
keys() {
  bmeta spring-boot-autoconfigure-4.1.1.jar spring.web.error.include-binding-errors
  bmeta spring-boot-web-server-4.1.1.jar "server"".error.include-binding-errors"
  echo "the anchor - after/, this unit's line: the README's run line with Boot's include-binding-errors key, port 19410 - the anchor's refused-body line:"
  start "$(at .harness/after 19410 "$L_KEYS")"; up 19410; ready 19410
  pl 19410 "$BDATA"
  stop 19410 .harness/after
  echo "the copy - the copy without the BindingResult (answer's B), the same line, port 19413:"
  start "$(at .harness/plant 19413 "$L_KEYS")"; up 19413; ready 19413
  plb 19413 "$BDATA"
  stop 19413 .harness/plant; }

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
# the key the exercise ships with - Boot 3's, which Boot 4 no longer reads - and the one its solution gives; named in pieces here, so
# no line of this script spells Boot 3's key whole (S2.13's check below)
K3="--server"; K3="$K3.error.include-binding-errors=always"; K4='--spring.web.error.include-binding-errors=always'
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
  echo "  the shell is now in: $(where "$d1") · the copy's own token in its log: $(raw "$(head -1 .harness/mine/after/$TF)" .harness/ex-readme.log) times · WARN lines in its log: $(grep -c ' WARN ' .harness/ex-readme.log || true) · its lines that name the key it was given (include-binding-errors): $(grep -c 'include-binding-errors' .harness/ex-readme.log || true) · listening on 19419 now: $(listeners 19419)"
  echo "the solution's $(printf '%s\n' "$sol" | grep -c .) lines, next, in the same shell:"
  printf '%s\n' "$sol" | sed 's/^/  $ /'
  echo "  exit $e2 · what they printed:"; sed 's/^/    /' .harness/ex-sol.out
  echo "  the shell is now in: $(where "$d2") · the copy's own token in its log: $(raw "$(head -1 .harness/mine/after/$TF)" .harness/mine/run.log) times · WARN lines in its log: $(grep -c ' WARN ' .harness/mine/run.log || true) · its lines that name the key it was given (include-binding-errors): $(grep -c 'include-binding-errors' .harness/mine/run.log || true) · listening on 19419 now: $(listeners 19419)"; }

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
# reflection entries counted, the types only one of them registers, the entries that differ and how; Customer's entry in each; its
# resource entries counted
AOTF=tiffinbox-web/target/spring-aot/main/resources/META-INF/native-image/com.tiffinbox/tiffinbox-web/reachability-metadata.json
aotcmp() { python3 - "$1/$AOTF" "$2/$AOTF" <<'PY'
import json, sys
a, b = (json.load(open(p)) for p in sys.argv[1:3])
ra, rb = a.get("reflection", []), b.get("reflection", [])
def key(e): return json.dumps(e.get("type"), sort_keys=True)
A = {key(e): e for e in ra}; B = {key(e): e for e in rb}
only_a = sorted(t for t in A if t not in B); only_b = sorted(t for t in B if t not in A)
ch = sorted(t for t in A if t in B and json.dumps(A[t], sort_keys=True) != json.dumps(B[t], sort_keys=True))
print("  Spring's generated metadata (%s) - the previous tree's against after/'s: reflection entries %d -> %d · types only one of them registers: %d · entries that differ: %d%s" % (sys.argv[1].split("/target/", 1)[1], len(ra), len(rb), len(only_a) + len(only_b), len(ch), (" - " + ", ".join(json.loads(t) for t in ch)) if ch else ""))
def sig(m): return "%s(%s)" % (m["name"], ", ".join(x.rsplit(".", 1)[-1] for x in m.get("parameterTypes", [])))
for t in ch:
    ma = sorted(sig(m) for m in A[t].get("methods", [])); mb = sorted(sig(m) for m in B[t].get("methods", []))
    other = {k: v for k, v in A[t].items() if k != "methods"} != {k: v for k, v in B[t].items() if k != "methods"}
    print("    %s - its methods only before: %s · only after: %s · anything else that differs: %s" % (json.loads(t), " ".join(m for m in ma if m not in mb) or "none", " ".join(m for m in mb if m not in ma) or "none", "yes" if other else "no"))
def what(e):
    k = [x for x in ("allDeclaredFields", "allDeclaredConstructors") if e.get(x)]
    return " · ".join(["all declared fields" if x == "allDeclaredFields" else "all declared constructors" for x in k] + ["%d methods (%s)" % (len(e.get("methods", [])), " ".join(sorted(m["name"] for m in e.get("methods", []))))])
t = json.dumps("com.tiffinbox.Customer")
print("  reflection entries naming com.tiffinbox.Customer: %d -> %d · the same entry: %s%s" % (int(t in A), int(t in B), "yes" if t in A and t in B and json.dumps(A[t], sort_keys=True) == json.dumps(B[t], sort_keys=True) else "no", (" - " + what(B[t])) if t in B else ""))
print("  resource entries: %d -> %d · the same: %s" % (len(a.get("resources", [])), len(b.get("resources", [])), "yes" if json.dumps(a.get("resources"), sort_keys=True) == json.dumps(b.get("resources"), sort_keys=True) else "no"))
PY
}
# lbk LABEL: a form's loopback, read off its own block of this capture so far - every "listens on:" line of the block says
# "loopback only: yes" (the image: published on 127.0.0.1 alone, docker port, both runs)
lbk() { awk -v a="$1" 'index($0, a) == 1 { f = 1; next } /^[1-4] the / { f = 0 } f' .harness/cap.raw > .harness/blk.txt
  if [ "$1" = '4 the image' ]; then [ "$(grep -c '^  docker port: ' .harness/blk.txt)" = 2 ] && [ "$(grep -cE '^  docker port: 18425/tcp -> 127\.0\.0\.1:19417$' .harness/blk.txt)" = 2 ] && echo yes || echo no
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
# The field-error filter, checked on a planted log before any capture: a WARN line listing two field errors - in the order a run
# might give them, the second's arguments holding a "default message [" of their own - must come out cut after its count, the two
# errors sorted by field, each with its value and its own message
cp .harness/run.out .harness/run.keep 2> /dev/null || true
printf '%s\n' "2026-10-15T00:00:00.000Z  WARN 1 --- [planted] .w.s.m.s.DefaultHandlerExceptionResolver : Resolved [org.springframework.web.bind.MethodArgumentNotValidException: Validation failed for argument [0] in x with 2 errors: [Field error in object 'c' on field 'zeta': rejected value [9]; codes [Z]; arguments [r: codes [c.zeta,zeta]; arguments []; default message [zeta]]; default message [must be small]] [Field error in object 'c' on field 'alpha': rejected value []; codes [A]; arguments [r: codes [c.alpha,alpha]; arguments []; default message [alpha]]; default message [must not be blank]] ]" > .harness/run.out
PL=$(vwarn 0)
[ "$PL" = "$(printf '%s\n' "    WARN .w.s.m.s.DefaultHandlerExceptionResolver: Resolved [org.springframework.web.bind.MethodArgumentNotValidException: Validation failed for argument [0] in x with 2 errors: …" "      the field errors it lists: 2, sorted by field (the order moves between runs) - each: its field, the value it was given, the rule's message; its codes and arguments not shown:" "        alpha []: must not be blank" "        zeta [9]: must be small")" ] || die "vwarn: the planted field-error line does not come out cut and sorted (.harness/run.out)"
rm -f .harness/run.out .harness/run.keep
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
# froutes PORT: the anchor's refused-body line; a new customer with its Location printed, the Location followed; the same name again;
# POST /shutdown without the token (the secrets lesson's line) - each answer printed (the timestamp masked)
froutes() { rl "$1" "$BDATA"; rl "$1" "$ADATA"; rfol; rl "$1" "$ADATA"; rp "$(url "$R_403" "$1")"; }
dseven() { echo "\$ \$CURLSET $1 .harness/after/$TF"
  "$CURLSET" "$1" ".harness/after/$TF" | grep ' -> ' > .harness/responses.txt || true
  tsmask < .harness/responses.txt > .harness/responses.m.txt
  grep '^POST ' .harness/responses.m.txt | sed 's/^/  /' || echo "  (no POST line)"
  dgone "$BOX"; [ "$(listeners "$1")" = 0 ] || die "something still listens on $1"
  echo "  exit $LASTE · the seven responses: $(wc -l < .harness/responses.m.txt | tr -d ' ') lines · lines the timestamp mask changed: $(diff .harness/responses.txt .harness/responses.m.txt | grep -c '^<' || true) · md5 $(md5 -q .harness/responses.m.txt)"
  dlog "$BOX"; echo "  its log (docker logs): Boot's first line: $(first .harness/run.out) · the demo token 0 times · X-Shutdown-Token 0 times"
  docker rm "$BOX" > /dev/null; }
BAD4='  {"mealType":"must match \"VEG|NON_VEG|VEGAN\"","mealsPerDay":"must be greater than or equal to 1","name":"must not be blank","pricePerMeal":"must be greater than or equal to 1"} 400 · Location: []'
forms() {
  echo "the native build - after/ copied to .harness/nat with a config tree; the README's two Maven lines, offline; \$GRAALVM_HOME names the GraalVM:"
  copy after .harness/nat
  nbuild .harness/nat; nlines .harness/nat.native.log; nresult .harness/nat.native.log
  echo "  file: $(file -b ".harness/nat/$BIN" | sed 's/ [A-Za-z0-9_]*$//') · the demo token in its bytes: $(raw "$TOKEN" ".harness/nat/$BIN")"
  echo "what Spring's AOT step registered - the previous tree built with the README's native-profile line too (.harness/natb), then its metadata against after/'s:"
  copy "$PREV" .harness/natb; pbuild .harness/natb "the previous tree, the profile native" "$R_PNAT"
  aotcmp .harness/natb .harness/nat
  echo "1 the jar - .harness/after, the README's run line, port 19410:"
  start "$(at .harness/after 19410 "$R_RUN")"; up 19410; ready 19410; tline; seven 19410 .harness/after
  echo "  then the refused body, a new customer, the same name again and POST /shutdown without the token, on a second start of the jar:"
  start "$(at .harness/after 19410 "$R_RUN")"; up 19410; ready 19410; froutes 19410; stop 19410 .harness/after
  echo "2 the AOT jar - .harness/nat (the profile native's jar), the README's AOT line, port 19414:"
  start "$(at .harness/nat 19414 "$R_AOTRUN")"; up 19414; ready 19414; tline; seven 19414 .harness/nat
  echo "  then the same four, on a second start of the AOT jar:"
  start "$(at .harness/nat 19414 "$R_AOTRUN")"; up 19414; ready 19414; froutes 19414; stop 19414 .harness/nat
  echo "3 the binary - .harness/nat, the README's line, port 19418:"
  start "$(at .harness/nat 19418 "$R_BIN")"; up 19418; ready 19418; tline; seven 19418 .harness/nat
  echo "  then the same four, on a second start of the binary:"
  start "$(at .harness/nat 19418 "$R_BIN")"; up 19418; ready 19418; froutes 19418; stop 19418 .harness/nat
  echo "4 the image - after/'s Dockerfile (the README's build line, this script's tag), the README's run line with your user, published on 127.0.0.1:19417:"
  image
  dstart "$(drun .harness/after 19417)"; ready 19417 "$BOX"; dbind 19417
  dseven 19417
  echo "  then the same four, on a second container of the image - TiffinBox listens on 18425 inside it:"
  dstart "$(drun .harness/after 19417)"; ready 19417 "$BOX"; dbind 19417
  froutes 19417
  post 19417 .harness/after; dgone "$BOX"; [ "$(listeners 19417)" = 0 ] || die "something still listens on 19417"
  dlog "$BOX"; echo "  exit $LASTE · its log (docker logs): the demo token 0 times · X-Shutdown-Token 0 times"
  docker rm "$BOX" > /dev/null
  echo "four forms, one tree: the seven (masked) $(grep -cE '^  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 2 · md5 87ca7efc8584dcccd40e6b956db1de9b$' .harness/cap.raw) of 4 times 87ca7efc8584dcccd40e6b956db1de9b · the refused body 400, its four fields named $(grep -cxF -- "$BAD4" .harness/cap.raw) of 4 · a new customer, 201 and a Location on 127.0.0.1 and the form's own port $(grep -cE '^  \{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"\} 201 · Location: \[http://127\.0\.0\.1:(19410|19414|19418|19417)/customers/Asha\]$' .harness/cap.raw) of 4, the Location followed 200 $(grep -cxF '  {"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 200' .harness/cap.raw) of 4 · the same name again 409 $(grep -cxF '   409 · Location: []' .harness/cap.raw) of 4 · POST /shutdown without the token 403 $(grep -cxF '  {"error":"forbidden"} 403' .harness/cap.raw) of 4"
  echo "  loopback, form by form: the jar $(lbk '1 the jar') · the AOT jar $(lbk '2 the AOT jar') · the binary $(lbk '3 the binary') · the image, published on 127.0.0.1 alone $(lbk '4 the image')"; }



cap constraints constraints
cap before before
cap answer answer
cap validator validator
cap typo typo
cap methods methods
cap keys keys
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
for f in .r-*.out README.md exercise/README.md exercise/solution/SOLUTION.md receipts.md5 harness/shutdown.sh $HWS .harness/nat/$BIN; do
  [ -f "$f" ] || continue; case $f in .harness/nat*) NBIN=$((NBIN + 1)) ;; esac
  [ "$(raw "$TOKEN" "$f")" = 0 ] || die "$f holds the demo token, raw"; done
[ "$NBIN" = 1 ] || die "one binary was built, $NBIN were checked"
for f in .r-*.out; do ! grep -qE '/Users/|/private/|/home/|/var/folders/' "$f" || die "$f holds an absolute path"; [ -z "${GRAALVM_HOME:-}" ] || ! grep -qF "$GRAALVM_HOME" "$f" || die "$f holds the GraalVM's folder"; ! grep -qE 'c[0-9]-unit[0-9]|unit ?[0-9]' "$f" || die "$f holds a unit number"; ! grep -qE ' (with PID|started by) ' "$f" || die "$f holds Boot's process line"; ! grep -qE '^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T|"timestamp":"?[0-9]|timestamp=[A-Z0-9]|(exec|handler|task|utility)-[0-9]|GMT' "$f" || die "$f holds a log line's time, a timestamp, a date or a thread's number"; ! grep -q "^$(printf '\t')at " "$f" || die "$f shows a stack frame"; ! grep -qE 'SpringCGLIB\$\$[0-9]' "$f" || die "$f holds a generated class's number"; ! grep -qE 'sha256:[0-9a-f]{64}' "$f" || [ "$(grep -cE 'sha256:[0-9a-f]{64}' "$f")" = "$(grep -cE 'eclipse-temurin(:25-jre)?@sha256:[0-9a-f]{64}' "$f")" ] || die "$f holds an ID other than the base image's digest"; ! grep -qE ':8080([^0-9]|$)' "$f" || die "$f shows a bind on 8080"; ! grep -q $'\r' "$f" || die "$f holds a carriage return"; done
for f in receipts.sh README.md exercise/README.md exercise/solution/SOLUTION.md harness/shutdown.sh $HWS; do [ -f "$f" ] || continue; ! grep -qE "exposure\.include='?\*" "$f" || die "$f exposes every endpoint (R.42)"; done
# S2.13: Boot 4.1 reads only spring.web.error.*, and Boot 3's keys (server, then error) are ignored without a word - so no file of
# this unit names one, the anchor's tree included, but the labelled exercise: exercise/README.md names it on one line alone, its
# bash block's run line (the shipped fault)
for f in receipts.sh exercise/solution/SOLUTION.md harness/shutdown.sh $HWS; do ! grep -E 'server\.error\.' "$f" | grep -vE '^ *#' > /dev/null || die "$f names one of Boot 3's error keys (server, then error) - Boot 4.1 reads only spring.web.error.* (S2.13)"; done
# README.md names it only inside the captures it pastes whole: each of its lines that does is a line of keys' capture (Boot's metadata
# for the old name) or of the exercise's (the run line it printed)
grep -E 'server\.error\.' README.md > .harness/s213.txt || true
while IFS= read -r l; do grep -qxF -- "$l" .r-keys.out || grep -qxF -- "$l" .r-exercise.out || die "README.md names one of Boot 3's error keys outside the keys and exercise captures it pastes (S2.13): $l"; done < .harness/s213.txt
! grep -rE 'server\.error\.' after > /dev/null || die "after/ names one of Boot 3's error keys (S2.13)"
[ "$(grep -cE 'server\.error\.' exercise/README.md)" = 1 ] && [ "$(block exercise/README.md | grep -cE 'server\.error\.')" = 1 ] && [ "$(block exercise/README.md | grep -cF -- " $K3 ")" = 1 ] || die "exercise/README.md must name Boot 3's key on its run line alone, as an option (S2.13: only inside the labelled exercise)"
for f in receipts.sh README.md exercise/README.md exercise/solution/SOLUTION.md; do [ -f "$f" ] || continue; ! grep -E 'docker run ' "$f" | grep -vE '^#' | grep -E ' -p "?[0-9]+:' > /dev/null || die "$f publishes a port on every address (-p without 127.0.0.1:)"; done
# no capture runs a command with a URL that is not 127.0.0.1's
for f in .r-*.out; do ! grep -E '^\$ ' "$f" | grep -oE 'https?://[^ '"'"']+' | grep -vE '^http://127\.0\.0\.1:' > /dev/null || die "$f runs a command with a URL that is not 127.0.0.1's"; done
NL=$(cat .r-*.out | grep -cE "^  its log: the demo token 0 times · X-Shutdown-Token 0 times\$" || true)
echo "  tokens: 0 raw copies in $(ls .harness/raw-* | wc -l | tr -d ' ') raw capture runs, in $(ls .r-*.out | wc -l | tr -d ' ') captures; the demo token 0 in the logs of every JVM that served or failed ($LOGS here; the published captures' $NL) and every container ($CLOGS here), the image's layers (forms), the READMEs, the harness, the exercise, receipts.md5 and the binary; no absolute path, no GraalVM folder, no unit number, no process line, no log time, no timestamp, no date, no thread number, no stack frame, no generated class's number, no ID but the base image's digest, no 8080, no carriage return in any capture; Boot 3's error key only on the exercise's run line; every docker run publishes on 127.0.0.1 only; every command a capture runs asks 127.0.0.1"

S87C='87ca7efc8584dcccd40e6b956db1de9b'
WA() { printf '%s · WARN lines it added: %s' "$1" "$2"; }
E4XX() { printf '  {"timestamp":"…","status":%s,"error":"%s","path":"%s"}' "$1" "$2" "$3"; }
# the commands as a capture shows them ($ first): RQ 'LINE' PORT - a README line at PORT; LQ PORT 'BODY' [PATH] - the Location line
# with that body; BQ PORT PATH - the one-customer line
RQ() { printf '$ %s' "$(url "$1" "$2")"; }
LQ() { printf '$ %s' "$(plc "$1" "${3:-/customers}" "$2")"; }
BQ() { printf '$ %s' "$(bc "$1" "$2")"; }
[ "$(LQ 19410 "$BDATA")" = "\$ $(url "$R_BAD" 19410)" ] && [ "$(LQ 19410 "$ADATA")" = "\$ $(url "$R_LOC" 19410)" ] && [ "$(BQ 19410 /customers/Ravi)" = "\$ $(url "$R_ONE" 19410)" ] || die "the checks' own command lines are not the README's"
ASHA1='{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}'
EMPTY1='{"name":"","mealsPerDay":0,"pricePerMeal":-5,"mealType":"LUNCH"}'
A201() { printf '  %s 201 · Location: [%s]' "${2:-$ASHA1}" "$1"; }
C409='   409 · Location: []'
FOUR='{"mealType":"must match \"VEG|NON_VEG|VEGAN\"","mealsPerDay":"must be greater than or equal to 1","name":"must not be blank","pricePerMeal":"must be greater than or equal to 1"}'
F400="  $FOUR 400 · Location: []"
[ "$F400" = "$BAD4" ] || die "the checks' refused-body answer is not forms' own"
SEED4='[{"name":"Meera","mealsPerDay":1,"pricePerMeal":150,"mealType":"NON_VEG"},{"name":"Priya","mealsPerDay":1,"pricePerMeal":120,"mealType":"VEGAN"},{"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"},{"name":"Sunil","mealsPerDay":3,"pricePerMeal":100,"mealType":"VEG"}]'
H2NULL='    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: Servlet.service() for servlet [dispatcherServlet] in context with path [] threw exception [Request processing failed: org.h2.jdbc.JdbcSQLIntegrityConstraintViolationException: NULL not allowed for column "MEAL_TYPE"; SQL statement:'
H2SQL='      INSERT INTO customer (name, meals_per_day, price_per_meal, meal_type) VALUES (?, ?, ?, ?) [23502-250]] with root cause'
TRACE50='    its stack frames: over 50, its other lines: 4 - none shown · WARN lines it added: 0'
E500L="$(E4XX 500 'Internal Server Error' /customers) 500 · Location: []"
ROHAN1='  {"mealType":"must not be null"} 400 · Location: []'

# "the record's components carry constraints ... a name that isn't blank, one to three meals, a price of at least one, a meal type that's
#  there and is one of three. The add method marks its body Valid ... and takes a binding result right after it" - 22 of 25 files, 56 jars,
#  the seven, the route registered with its new parameter, the method's own 400 at DEBUG
CO=$(cat .r-constraints.out)
for l in '  built the previous tree · offline: yes · exit 0' '  built after/ · offline: yes · exit 0' "  after/'s files: 25 · byte for byte the previous tree's: 22 · those above differ: 3"; do has "$CO" "$l" "constraints: the builds and the files"; done
[ "$(n constraints '^  Files ')" = 3 ] && [ "$(n constraints '^  Only in ')" = 0 ] || die "constraints: three files differ, none added or deleted"
for f in README.md "$C/Customer.java" "$W/TiffinBoxServer.java"; do x constraints "^  Files \.harness/before/$f and \.harness/after/$f differ\$"; done
has "$CO" '  exit 0 · its classes: probe/web/MethodFinal.class probe/web/MethodPlain.class probe/web/MethodValidated.class probe/web/Unbound.class probe/web/Who.class' "constraints: the harness, five classes"
has "$CO" "\$ $L_JAVAC" "constraints: the harness's javac line, -parameters"
has "$CO" '  Customer.java: 8 lines -> 27 · its lines that are neither comment nor blank: 6 -> 14, of them - imports left out - naming a constraint: 0 -> 4 · the constraints they name: @NotBlank 0 · @NotNull 0 · @Min 0 · @Max 0 · @Pattern 0 -> @NotBlank 1 · @NotNull 1 · @Min 2 · @Max 1 · @Pattern 1' "constraints: the record's four components, six constraints"
for l in '    -public record Customer(String name, int mealsPerDay, int pricePerMeal, String mealType) {' '    +public record Customer(@NotBlank String name,' '    +                       @Min(1) @Max(3) int mealsPerDay,' '    +                       @Min(1) int pricePerMeal,' '    +                       @NotNull @Pattern(regexp = "VEG|NON_VEG|VEGAN") String mealType) {'; do has "$CO" "$l" "constraints: Customer's diff"; done
has "$CO" '  TiffinBoxServer.java: 241 lines -> 273 · its lines that are neither comment nor blank: 127 -> 141, of them - imports left out - naming @Valid: 0 -> 1 · a BindingResult: 0 -> 2 · @Validated: 0 -> 0' "constraints: @Valid 1, a BindingResult, no @Validated"
for l in '    -    ResponseEntity<Customer> add(@RequestBody Customer customer) throws SQLException {' '    +    ResponseEntity<?> add(@Valid @RequestBody Customer customer, BindingResult errors) throws SQLException {' '    +        if (errors.hasErrors()) {' '    +            return ResponseEntity.badRequest().body(fieldMessages(errors));' '    +    private static Map<String, String> fieldMessages(BindingResult errors) {' '    +        var out = new TreeMap<String, String>();' '    +            out.put(e.getField(), e.getDefaultMessage());'; do has "$CO" "$l" "constraints: TiffinBoxServer's diff"; done
x constraints "^the executable jar's BOOT-INF/lib: 56 jars -> 56 · the same names: yes\$"
has "$CO" "  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 2 · md5 $S87C" "constraints: the seven, unchanged"
for l in '        {POST [/customers]}: add(Customer,BindingResult)' "    s.w.s.m.m.a.RequestMappingHandlerMapping: DEBUG 9 mappings in 'requestMappingHandlerMapping'"; do has "$CO" "$l" "constraints: registered with its BindingResult, 9 mappings"; done
CR=$(blk constraints 'read - after/' '')
[ "$(aft "$(RQ "$R_BAD" 19410)" "$CR")" = "$F400" ] && [ "$(aft "$(RQ "$R_ADD" 19410)" "$CR")" = "  $ASHA1 201" ] || die "constraints: at DEBUG, the refused body 400 with its four fields, the new customer 201"
[ "$(printf '%s\n' "$CR" | grep -cxF "  the lines the log gained for it, Boot's web group at DEBUG (logger: message) - all 6:")" = 2 ] || die "constraints: six DEBUG lines each"
[ "$(printf '%s\n' "$CR" | grep -cxF '    s.w.s.m.m.a.RequestMappingHandlerMapping: Mapped to com.tiffinbox.web.TiffinBoxServer#add(Customer, BindingResult)')" = 2 ] || die "constraints: both mapped to add(Customer, BindingResult)"
for l in '    m.m.a.RequestResponseBodyMethodProcessor: Read "application/json;charset=UTF-8" to [Customer[name=, mealsPerDay=0, pricePerMeal=-5, mealType=LUNCH]]' '    o.s.web.servlet.DispatcherServlet: Completed 400 BAD_REQUEST' '    o.s.web.servlet.DispatcherServlet: Completed 201 CREATED'; do has "$CR" "$l" "constraints: read, then answered by the method"; done
printf '%s\n' "$CR" | grep -qxF '    o.s.w.s.m.m.a.HttpEntityMethodProcessor: Writing [{mealType=must match "VEG|NON_VEG|VEGAN", mealsPerDay=must be greater than or equal to 1, name=must  (truncated)...]' || die "constraints: the method's map, written by HttpEntityMethodProcessor"
! printf '%s\n' "$CR" | grep -q 'Resolved \[' || die "constraints: no exception resolved - the method answered"
echo "  constraints: 3 files (Customer.java 8 -> 27, 4 components, 6 constraints; TiffinBoxServer.java 241 -> 273, @Valid 0 -> 1, BindingResult 0 -> 2, @Validated 0; the README); 22 of 25 byte for byte; 56 libraries; the seven $S87C; TRACE add(Customer,BindingResult), 9 mappings; DEBUG 6 lines each, the refused body 400 written by the method, no exception resolved"

# "Post a customer with an empty name, zero meals a day, a price of minus five and a meal type of lunch. TiffinBox says two oh one ... and a
#  Location that's a four oh four. Misspell one key and it's a five hundred, with over fifty stack frames in the log."
BE=$(cat .r-before.out)
[ "$(aft "$(LQ 19411 "$BDATA")" "$BE")" = "$(WA "$(A201 http://127.0.0.1:19411/customers/ "$EMPTY1")" 0)" ] || die "before: the empty name created, its Location /customers/"
[ "$(aft "$(BQ 19411 /customers/)" "$BE")" = "$(WA "$(E4XX 404 'Not Found' /customers/) 404" 0)" ] || die "before: that Location, a 404"
[ "$(aft "$(LQ 19411 "$ROHAN")" "$BE")" = "$E500L" ] && has "$BE" "$H2NULL" "before" && has "$BE" "$H2SQL" "before: 23502" && has "$BE" "$TRACE50" "before: over 50 frames" || die "before: the misspelt key, H2's 23502, a 500"
L5=$(aft "$(BQ 19411 /customers)" "$BE"); [ "$(printf '%s\n' "$L5" | grep -o '"name":"' | wc -l | tr -d ' ')" = 5 ] && case $L5 in "  [$EMPTY1,"*) true ;; *) false ;; esac || die "before: five listed, the empty name first"
has "$BE" "  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 1" "before: one ERROR line, no WARN"
echo "  before: the empty name 201, its Location /customers/ a 404, listed first of 5; the misspelt key 500 (23502), over 50 frames, 1 ERROR"

# "A: the same body now gets four hundred, bad request ... four of them, nothing stored. Four meals a day: at most three. A valid name: two
#  oh one, and the same name again is still four oh nine. B: ... Boot's four hundred, no field at all, and one WARN line that lists the four
#  errors ... A again: the same as A."
AA=$(blk answer 'A - after/' 'B - a copy'); AB=$(blk answer 'B - a copy' "A' - A again"); AA2=$(blk answer "A' - A again" "A' against A")
for b in "$AA" "$AA2"; do
  [ "$(aft "$(LQ 19410 "$BDATA")" "$b")" = "$(WA "$F400" 0)" ] || die "answer A/A': the refused body, 400, its four fields"
  [ "$(aft "$(BQ 19410 /customers)" "$b")" = "$(WA "  $SEED4 200" 0)" ] || die "answer A/A': nothing stored - the four seed customers"
  [ "$(aft "$(LQ 19410 "$TARA")" "$b")" = "$(WA '  {"mealsPerDay":"must be less than or equal to 3"} 400 · Location: []' 0)" ] || die "answer A/A': four meals, at most three"
  [ "$(aftn 1 "$(LQ 19410 "$ADATA")" "$b")" = "$(WA "$(A201 http://127.0.0.1:19410/customers/Asha)" 0)" ] && [ "$(aftn 2 "$(LQ 19410 "$ADATA")" "$b")" = "$(WA "$C409" 0)" ] || die "answer A/A': a new name 201, the same again 409"
  has "$b" "  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0" "answer A/A': nothing in the log"; done
for l in '  @@ -159,4 +159 @@' "  -$PLANTA" "  -$PLANT1" "  -$PLANT2" "  -$PLANT3" "  +$PLANTB" '  built the copy · offline: yes · exit 0'; do has "$AB" "$l" "answer B: the copy"; done
[ "$(aft "$(LQ 19413 "$BDATA")" "$AB")" = "$(WA "$(E4XX 400 'Bad Request' /customers) 400 · Location: []" 1)" ] || die "answer B: Boot's 400, no field, one WARN line"
has "$AB" '    WARN .w.s.m.s.DefaultHandlerExceptionResolver: Resolved [org.springframework.web.bind.MethodArgumentNotValidException: Validation failed for argument [0] in org.springframework.http.ResponseEntity<?> com.tiffinbox.web.TiffinBoxServer.add(com.tiffinbox.Customer) throws java.sql.SQLException with 4 errors: …' "answer B: the WARN line, 4 errors"
has "$AB" "      the field errors it lists: 4, sorted by field (the order moves between runs) - each: its field, the value it was given, the rule's message; its codes and arguments not shown:" "answer B: four listed"
for l in '        mealType [LUNCH]: must match "VEG|NON_VEG|VEGAN"' '        mealsPerDay [0]: must be greater than or equal to 1' '        name []: must not be blank' '        pricePerMeal [-5]: must be greater than or equal to 1'; do has "$AB" "$l" "answer B: the four, each once"; done
[ "$(aft "$(BQ 19413 /customers)" "$AB")" = "$(WA "  $SEED4 200" 0)" ] && has "$AB" "  WARN lines in this run's log, at Boot's default level: 1 · ERROR lines: 0" "answer B" || die "answer B: nothing stored, one WARN"
x answer "^A' against A, its label aside, line for line the same: yes\$"
echo "  answer: A the refused body 400, 4 fields, 0 WARN, nothing stored; 4 meals - at most 3; Asha 201, again 409; B (no BindingResult) Boot's 400, no field, 1 WARN listing 4 errors (sorted); A' = A"

# "Spring MVC's handler adapter validates with a bean called mvc validator, Boot's adapter, wrapped around the very validator factory Boot
#  declared, Hibernate Validator inside ... ask in German and the same four come back in German."
VA=$(cat .r-validator.out)
for l in "  beans of Spring's Validator type (org.springframework.validation.Validator): 2 [defaultValidator, mvcValidator]" "  beans of Bean Validation's Validator type (jakarta.validation.Validator): 1 [defaultValidator]" "  mvcValidator, the bean Spring MVC's configuration declares: org.springframework.boot.validation.autoconfigure.ValidatorAdapter" '    its target: org.springframework.validation.beanvalidation.LocalValidatorFactoryBean · the very bean defaultValidator, the same object: true' "  defaultValidator, unwrapped to Bean Validation's own Validator: org.hibernate.validator.internal.engine.ValidatorImpl" "  Spring MVC's handler adapter (requestMappingHandlerAdapter) binds and validates with: mvcValidator, the same object" "  the JVM's locale, the one Hibernate Validator writes its messages in when a request names none: en_US"; do has "$VA" "$l" "validator: the chain"; done
[ "$(aft "$(LQ 19412 "$BDATA")" "$VA")" = "$(WA "$F400" 0)" ] || die "validator: the refused body, English"
[ "$(aft "\$ $(lc "$L_DE" 19412 /customers "$BDATA")" "$VA")" = "$(WA '  {"mealType":"muss mit \"VEG|NON_VEG|VEGAN\" übereinstimmen","mealsPerDay":"muss größer-gleich 1 sein","name":"darf nicht leer sein","pricePerMeal":"muss größer-gleich 1 sein"} 400 · Location: []' 0)" ] || die "validator: the same four, in German"
echo "  validator: 2 Spring Validator beans, 1 Bean Validation one; mvcValidator = ValidatorAdapter -> the very defaultValidator (LocalValidatorFactoryBean) -> Hibernate Validator's ValidatorImpl; the adapter binds with it; en_US; Accept-Language: de -> the four in German"

# "The misspelt key is still ignored by Jackson, so the meal type arrives as null ... must not be null, a four hundred, before the database is
#  asked. No stack trace, nothing stored. A property the record doesn't have is still ignored ... And two point seven meals is still Jackson's
#  own refusal."
TY=$(cat .r-typo.out)
[ "$(aft "$(LQ 19410 "$ROHAN")" "$TY")" = "$(WA "$ROHAN1" 0)" ] && [ "$(aft "$(BQ 19410 /customers/Rohan)" "$TY")" = "$(WA "$(E4XX 404 'Not Found' /customers/Rohan) 404" 0)" ] || die "typo: must not be null, nothing stored"
[ "$(aft "$(LQ 19410 "$KIRAN")" "$TY")" = "$(WA '  {"name":"Kiran","mealsPerDay":1,"pricePerMeal":110,"mealType":"VEG"} 201 · Location: [http://127.0.0.1:19410/customers/Kiran]' 0)" ] && [ "$(aft "$(BQ 19410 /customers/Kiran)" "$TY")" = "$(WA '  {"name":"Kiran","mealsPerDay":1,"pricePerMeal":110,"mealType":"VEG"} 200' 0)" ] || die "typo: an unknown property ignored, 201"
[ "$(aft "$(LQ 19410 "$MOHAN")" "$TY")" = "$(WA "$(E4XX 400 'Bad Request' /customers) 400 · Location: []" 1)" ] && has "$TY" '    WARN .w.s.m.s.DefaultHandlerExceptionResolver: Resolved [org.springframework.http.converter.HttpMessageNotReadableException: JSON parse error: Cannot coerce Floating-point value (2.7) to `int` value (but could if coercion was enabled using `CoercionConfig`)]' "typo" || die "typo: 2.7, Jackson's 400 and its WARN line"
has "$TY" "  WARN lines in this run's log, at Boot's default level: 1 · ERROR lines: 0" "typo: no ERROR line"
echo "  typo: mealTyp -> {\"mealType\":\"must not be null\"} 400, not stored, 0 ERROR; loyaltyPoints ignored, 201; 2.7 -> Jackson's 400, 1 WARN"

# "A rule on a request parameter, with no Validated on the class: Spring MVC checks it itself, four hundred, no WARN line. Put Validated on
#  the class, and Boot's post-processor ... swaps in a subclass whose check throws: five hundred, and a trace. On a final class, the start
#  stops. TiffinBox's server is final"
ME_=$(cat .r-methods.out)
for l in "  Boot's metadata (spring-boot-autoconfigure-4.1.1.jar) - spring.web.error.include-exception · its type: Boolean · its default: false · its description: Include the \"exception\" attribute." '  the post-processor that adds method validation (MethodValidationPostProcessor): 1 [methodValidationPostProcessor] · its class: org.springframework.boot.validation.beanvalidation.FilteredMethodValidationPostProcessor' '  the beans it is told to leave alone (MethodValidationExcludeFilter): 1 [org.springframework.boot.context.properties.EnableConfigurationPropertiesRegistrar.methodValidationExcludeFilter]' '  TiffinBoxServer: final true · @Validated on the class false · the object the context holds: com.tiffinbox.web.TiffinBoxServer - a subclass Spring generated: false' '  TiffinBoxProperties: final true · @Validated on the class true · the object the context holds: com.tiffinbox.TiffinBoxProperties - a subclass Spring generated: false' '  MethodPlain: final false · @Validated on the class false · the object the context holds: probe.web.MethodPlain - a subclass Spring generated: false' '  MethodValidated: final false · @Validated on the class true · the object the context holds: probe.web.MethodValidated$$SpringCGLIB$$<n> - a subclass Spring generated: true'; do has "$ME_" "$l" "methods: the beans"; done
[ "$(aft "$(BQ 19412 '/probe/method/plain?meals=1')" "$ME_")" = "$(WA '  meals=1 200' 0)" ] && [ "$(aft "$(BQ 19412 '/probe/method/validated?meals=1')" "$ME_")" = "$(WA '  meals=1 200' 0)" ] || die "methods: a good value, 200 both"
[ "$(aft "$(BQ 19412 '/probe/method/plain?meals=0')" "$ME_")" = "$(WA '  {"timestamp":"…","status":400,"error":"Bad Request","exception":"org.springframework.web.method.annotation.HandlerMethodValidationException","path":"/probe/method/plain"} 400' 0)" ] || die "methods: no @Validated - Spring MVC's own, 400, no WARN"
[ "$(aft "$(BQ 19412 '/probe/method/validated?meals=0')" "$ME_")" = '  {"timestamp":"…","status":500,"error":"Internal Server Error","exception":"jakarta.validation.ConstraintViolationException","path":"/probe/method/validated"} 500' ] && has "$ME_" '    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: Servlet.service() for servlet [dispatcherServlet] in context with path [] threw exception [Request processing failed: jakarta.validation.ConstraintViolationException: meals.meals: must be greater than or equal to 1] with root cause' "methods" || die "methods: @Validated - the subclass's ConstraintViolationException, 500, Tomcat's ERROR line"
x methods '^    its stack frames: over 40, its other lines: [0-9]+ - none shown · WARN lines it added: 0$'
has "$ME_" "  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 1" "methods: no WARN, one ERROR"
MD=$(blk methods 'who resolved the 400 - ' 'a final class - ')
[ "$(aft "$(BQ 19412 '/probe/method/plain?meals=0')" "$MD")" = '  {"timestamp":"…","status":400,"error":"Bad Request","path":"/probe/method/plain"} 400' ] || die "methods: at DEBUG, the same 400"
has "$MD" '    .w.s.m.a.ResponseStatusExceptionResolver: Resolved [org.springframework.web.method.annotation.HandlerMethodValidationException: 400 BAD_REQUEST "Validation failure"]' "methods: Spring MVC's ResponseStatusExceptionResolver resolved it - at DEBUG"
MF=$(blk methods 'a final class - ' '')
has "$MF" '  exit 1 · Boot'"'"'s first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1 · Boot'"'"'s started line: 0 · listening on 19415 now: 0' "methods: the final class - exit 1, never started"
for l in '    ERROR o.s.boot.SpringApplication: Application run failed' '    Caused by: org.springframework.aop.framework.AopConfigException: Could not generate CGLIB subclass of class probe.web.MethodFinal: Common causes of this problem include using a final class or a non-visible class' '    Caused by: java.lang.IllegalArgumentException: Cannot subclass final class probe.web.MethodFinal' '    its stack frames: over 40 - none shown'; do has "$MF" "$l" "methods: the final class's failure"; done
echo "  methods: include-exception default false; no @Validated -> HandlerMethodValidationException 400, 0 WARN; @Validated -> a generated subclass, ConstraintViolationException 500, 1 ERROR; final + @Validated -> exit 1, Cannot subclass final class; TiffinBoxServer final, no @Validated, no subclass; TiffinBoxProperties final + @Validated, no subclass (1 exclude filter)"

# "Where the method answers, the key changes nothing. On the copy without the binding result, each error comes out whole: eight keys apiece"
KE=$(cat .r-keys.out); KA_=$(blk keys 'the anchor - ' 'the copy - '); KB_=$(blk keys 'the copy - ' '')
has "$KE" "  Boot's metadata (spring-boot-autoconfigure-4.1.1.jar) - spring.web.error.include-binding-errors · its type: ErrorProperties\$IncludeAttribute · its default: \"never\" · its description: When to include \"errors\" attribute." "keys: Boot 4's key, default never"
K3N=${K3#--}; K3N=${K3N%=always}; K4N=${K4#--}; K4N=${K4N%=always}
has "$KE" "  Boot's metadata (spring-boot-web-server-4.1.1.jar) - $K3N · its type: none · its default: \"never\" · its description: When to include \"errors\" attribute. · deprecated: level error, since 4.0.0, replaced by $K4N" "keys: Boot 3's key, deprecated at level error since 4.0.0"
[ "$(aft "$(LQ 19410 "$BDATA")" "$KA_")" = "$(WA "$F400" 0)" ] || die "keys: on the anchor the method answers, the key changes nothing"
for l in "  Boot's body - its keys: error errors path status timestamp · its status 400 · then curl's: 400 · Location: []" '  its errors: 4 entries, sorted by field (the order moves between runs) - each with the same 8 keys: arguments bindingFailure code codes defaultMessage field objectName rejectedValue' '  WARN lines it added: 1'; do has "$KB_" "$l" "keys: Boot's body with every field error, whole"; done
[ "$(printf '%s\n' "$KB_" | grep -cE '^    \{"arguments":\[.*"bindingFailure":false,"code":"(NotBlank|Min|Pattern)","codes":\[.*"defaultMessage":"[^"]*.*"field":"(mealType|mealsPerDay|name|pricePerMeal)","objectName":"customer","rejectedValue":.*\}$')" = 4 ] || die "keys: four entries, each whole"
echo "  keys: Boot 4's key default never, Boot 3's deprecated (level error, since 4.0.0); the anchor's map unchanged; the copy: errors, 4 entries, 8 keys each"

# the exercise's end state: the README's commands, then the solution's, in ONE env -i shell - each leaves the shell in this folder; the line
# exercise/README.md calls "Done" is a line of this capture, after the solution's lines, and of SOLUTION.md's measured run
XS=$(blk exercise "the README's" "the solution's"); XE=$(blk exercise "the solution's" '')
l='status: 400 · errors: 3 · fields: mealType mealsPerDay name'; l0='status: 400 · errors: 0 · fields: none'
has "$XE" "    $l" "exercise: the solution"; has "$XS" "    $l0" "exercise: as shipped"
awk '/^\*\*Done\*\*/ { f = 1 } f' exercise/README.md | grep -qxF -- "$l" || die "exercise/README.md: Done names no such line"
grep -qxF -- "$l" exercise/solution/SOLUTION.md || die "SOLUTION.md: the measured run shows no such line"
grep -qF -- "\`$l0\`" exercise/README.md || die "exercise/README.md: the shipped line's answer is not named"
has "$XS" '  exit 0 · what they printed:' "exercise: the README's commands, exit 0"; has "$XE" '  exit 0 · what they printed:' "exercise: the solution's lines, exit 0"
has "$XS" "  the shell is now in: this unit's folder · the copy's own token in its log: 0 times · WARN lines in its log: 1 · its lines that name the key it was given (include-binding-errors): 0 · listening on 19419 now: 0" "exercise: the README's commands - the key named nowhere in the log, the shell in this unit's folder"
has "$XE" "  the shell is now in: this unit's folder · the copy's own token in its log: 0 times · WARN lines in its log: 1 · its lines that name the key it was given (include-binding-errors): 0 · listening on 19419 now: 0" "exercise: the solution's lines leave the shell in this unit's folder"
[ "$(printf '%s\n' "$XE" | grep -c '^  \$ export ')" = 2 ] || die "exercise: SOLUTION.md gives the README's two export lines"
r=$(printf '%s\n' "$XS" | grep '^  \$ (cd \.harness/mine/after && ' | sed 's/^  \$ //'); r2=$(printf '%s\n' "$XE" | grep '^  \$ (cd \.harness/mine/after && ' | sed 's/^  \$ //')
P_=" $K4 "; R_=" $K3 "; t=${r2/"$P_"/$R_}
[ "$t" = "$r" ] && [ "$r2" != "$r" ] || die "exercise: the solution's line is the README's last line with Boot 3's key given Boot 4's name, and nothing else"
echo "  exercise: one env -i shell - the README as written (Boot 3's key) -> errors 0, the key named in 0 log lines; the solution (Boot 4's name) -> errors 3, mealType mealsPerDay name; the shell in this unit's folder after each"

# "Every form validates: the jar, the AOT jar, built ahead of time, the native binary and the image, each answering four hundred with the same
#  four fields, two oh one for a new name, four oh nine for a repeat, on loopback ... the same six hundred and sixty-five entries as before"
x forms '^  exit 0 · BUILD SUCCESS · stages it printed: 8 of the 8 it announces · its lines that say the metadata repository was downloaded over http, or failed to: 0 · offline: yes$'
x forms '^  file: Mach-O 64-bit executable · the demo token in its bytes: 0$'
x forms '^  built the previous tree, the profile native · offline: yes · exit 0$'
x forms "^  Spring's generated metadata \(spring-aot/main/resources/META-INF/native-image/com\.tiffinbox/tiffinbox-web/reachability-metadata\.json\) - the previous tree's against after/'s: reflection entries 665 -> 665 · types only one of them registers: 0 · entries that differ: 1 - com\.tiffinbox\.web\.TiffinBoxServer\$"
x forms '^    com\.tiffinbox\.web\.TiffinBoxServer - its methods only before: add\(Customer\) · only after: add\(Customer, BindingResult\) · anything else that differs: no$'
x forms '^  reflection entries naming com\.tiffinbox\.Customer: 1 -> 1 · the same entry: yes - all declared fields · all declared constructors · 4 methods \(mealType mealsPerDay name pricePerMeal\)$'
x forms '^  resource entries: 26 -> 26 · the same: yes$'
x forms "^four forms, one tree: the seven \(masked\) 4 of 4 times $S87C · the refused body 400, its four fields named 4 of 4 · a new customer, 201 and a Location on 127\.0\.0\.1 and the form's own port 4 of 4, the Location followed 200 4 of 4 · the same name again 409 4 of 4 · POST /shutdown without the token 403 4 of 4\$"
x forms '^  loopback, form by form: the jar yes · the AOT jar yes · the binary yes · the image, published on 127\.0\.0\.1 alone yes$'
# each form's block runs from its label to the next form's (a label:port:next label triple - a case inside $( ) is a syntax error to
# /bin/bash 3.2)
for t in '1 the jar:19410:2 the AOT jar' '2 the AOT jar:19414:3 the binary' '3 the binary:19418:4 the image' '4 the image:19417:four forms, one tree'; do lb_=${t%%:*}; r_=${t#*:}; p_=${r_%%:*}; nx_=${r_#*:}
  b=$(blk forms "$lb_ - " "$nx_")
  has "$b" "$F400" "forms $lb_: the refused body, its four fields"
  has "$b" "$(A201 "http://127.0.0.1:$p_/customers/Asha")" "forms $lb_: 201 and the Location on its own port"
  has "$b" "\$ curl -s -w ' %{http_code}\\n' http://127.0.0.1:$p_/customers/Asha" "forms $lb_: the Location followed"
  has "$b" "  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 2 · md5 $S87C" "forms $lb_: the seven"; done
[ "$(n forms "^  Boot's first line: Starting AOT-processed TiffinBoxServer v1\.0\.0 using Java 25\.0\.4\.1\$")" = 2 ] && [ "$(n forms "^  Boot's first line: Starting AOT-processed TiffinBoxServer using Java 25\.0\.4\.1\$")" = 2 ] || die "forms: the AOT jar and the binary, AOT-processed, both starts"
[ "$(n forms '^  inside the container, listening: \[::\]:18425$')" = 2 ] && [ "$(n forms '^  docker port: 18425/tcp -> 127\.0\.0\.1:19417$')" = 2 ] || die "forms: the image, two containers, 18425 inside, published on 127.0.0.1:19417 alone"
x forms '^  its lines that say pull: 0 · '
x forms '^  the image saved \(docker save\): [1-9][0-9]* blobs, its [1-9][0-9]* layers among them, each read whole \(gzip ones unpacked\) · the demo token in them: 0$'
echo "  forms: 8 of 8 stages, offline, Mach-O, 0 tokens; the AOT metadata 665 -> 665, one entry differs (TiffinBoxServer: add's parameters), Customer's the same; the jar, the AOT jar, the binary, the image: the seven $S87C 4 of 4, the refused body's four fields 4 of 4, 201 + its form's own Location 4 of 4, followed 200 4 of 4, 409 4 of 4, 403 4 of 4; loopback form by form; the image's layers 0 tokens"

cmp -s after/README.md ../c6-tiffinbox/README.md || echo "  (after/README.md and ../c6-tiffinbox/README.md differ - the anchor has moved past this unit's after/)" >&3
[ -z "$unpub" ] || die "no published hash for:$unpub - check the captures, then copy the md5s above into receipts.md5 and run again"
echo "c6-unit12: every capture 3/3 and = published; every spoken number asserted; 0 raw demo tokens in every capture, every log, the container's log, the image's layers and the binary; nothing of this run left on Docker"
