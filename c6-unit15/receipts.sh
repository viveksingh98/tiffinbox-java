#!/bin/bash
XPATH=$PATH                                           # the PATH you started this with: the exercise's own shell gets it
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25.0.4.1 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# GRAALVM_HOME names a GraalVM JDK 25 (README.md, "The GraalVM"): the native build reads it. Without it, this script makes every
# capture that needs no GraalVM, filling .m2-demo on the way, then stops before the native build.
# Course 6 · @ExceptionHandler and @RestControllerAdvice - this unit's receipts. The anchor changes: GET /customers/{name} throws
# CustomerNotFound for a name nobody has, where it threw Spring's ResponseStatusException, and a controller advice of TiffinBox's own,
# TiffinBoxErrors, answers it: 404 and {"error":"no customer named X"}, where Boot's body named nobody. Six captures, each run three
# times and hashed; cap() DIES when a hash differs from receipts.md5; every number the video says is asserted at the bottom by a check
# that can fail; the demo token is masked (gsub), and the checks count 0 raw copies of it in every capture, in the log of every run -
# the container's included - in every file this unit ships, in the binary and in the image's layers.
#   change      the previous tree against after/: the files that differ and the two new ones, TiffinBoxServer's code lines and their
#               diff, the two new files' code lines whole, the jar's libraries
#   notfound    the seven on after/, a fresh JVM; a name nobody has, a name with a space, Ravi - on after/ and on the previous tree,
#               each with the WARN and ERROR lines it added; who answers, read off the running application (the harness's Who): the
#               annotations @RestControllerAdvice carries, the exception resolvers in order, the advice cache; who resolved the 404, at
#               DEBUG, on both trees
#   precedence  the harness's controller and advices joined to after/: inside one advice the nearest type; the controller's own
#               handler before any advice; no handler, Boot's 500; a type mismatch, which no handler takes by its type, taken by the
#               IllegalArgumentException handler (its cause's type); then an advice ordered first, handling any RuntimeException with
#               no status - order before nearness, and 200s
#   status      A/B/A': after/ (A); a copy whose handler names no status (B); A again (A'); C, labelled: A asked by clients that accept
#               only HTML, only XML, and a browser's whole Accept header (Chrome's), each sent by curl; D, labelled: the previous tree, the
#               same three
#   exercise    exercise/README.md's commands, then exercise/solution/SOLUTION.md's, read from the files and run as written, one after
#               the other in ONE shell a viewer could have: env -i, /bin/bash, started in this folder
#   forms       the native build of after/; what Spring's AOT step registers, on the previous tree and on after/; then four forms -
#               the jar, the AOT jar, the binary, the image: each one's address, the seven (masked), exit 0; then, on a second start of
#               each, a name nobody has, a name with a space, Ravi, the name nobody has for a client that accepts only HTML, and POST
#               /shutdown without the token; the locale options on the binary's and the image's run lines, counted
# "The previous tree" is ../c6-unit12/after (the anchor before this change: the validation lesson's frozen tree), COPIED under
# .harness/before; after/ is this unit's frozen copy of ../c6-tiffinbox after the change, COPIED under .harness/after. This script
# never writes into another unit's folder, and never builds a frozen tree in place. Every run of TiffinBox starts in a folder under
# .harness/ that holds a config tree with a fake token (secrets/), as the README asks - the container's too, mounted read-only.
# Commands are printed exactly as they run: each goes through eval. "$CURLSET" is the comparison set since the secrets lesson
# (../c5-unit11/curlset.sh: the seven requests, POST /shutdown with the token's header read from the file). "$M2" is this unit's
# own repository, .m2-demo. The harness - harness/probe/web/*.java (compiled with -parameters): Who, Prec, AdviceWide, AdviceFirst -
# the course's, never TiffinBox's: outside com.tiffinbox, joined by --spring.main.sources on the extracted jar's class path;
# harness/shutdown.sh (POST /shutdown, the token read from its file); harness/exercise/TiffinBoxErrors.java (the exercise's copy of
# the advice, one line short) - is named on every capture that uses it. Every run passes options only. The seven always run on a
# fresh JVM, first.
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
# string, epoch milliseconds) in the seven and wherever Spring's error body is printed; Boot's Whitelabel page is printed as its
# <h1> and its error line, its created date (the JVM's time zone) masked and its paragraph counted, never shown; where a native-image
# warning names the file it read an option from, the file's URL - or "null", which it prints when the path holds a space - becomes
# "…". A run's log lines are printed from their logger on (no time, no process id, no thread); Boot's first line is cut before
# " with PID". A WARN or ERROR record is printed as its level, logger and message, then the exception line under it; its stack
# frames are bounded ("over 40") and its other lines counted, never shown. No image, container or ID is printed but the base image's
# digest. No duration is captured: the native build's seconds, and the 20-minute bound, go to the terminal only.
# Ports (brief ⚑1, 19440-19449): after/'s jar 19440 · the previous tree 19441 · after/ with the harness joined 19442 · the copy whose
# handler names no status 19443 · the AOT jar 19444 · the image 19447 · the binary 19448 · the exercise 19449 (19445 and 19446 are
# not used, and are checked free). 18425 (TiffinBox's default), 8080 (Tomcat's) and 35729 (DevTools' Live Reload) are checked free too,
# and never bound on this machine (18425 only inside a container).
# Docker names (no unit number): the image tiffinbox-advice:1.0.0 and the container tiffinbox-advice. Each is checked absent before
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
IMG=tiffinbox-advice:1.0.0; BOX=tiffinbox-advice
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
PREV=../c6-unit12/after                              # the previous tree: the anchor before this change - read, copied
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
HWS='harness/probe/web/AdviceFirst.java harness/probe/web/AdviceWide.java harness/probe/web/Prec.java harness/probe/web/Who.java'
XERR=harness/exercise/TiffinBoxErrors.java           # the exercise's copy of the advice
for f in harness/shutdown.sh $XERR $HWS exercise/README.md exercise/solution/SOLUTION.md README.md; do [ -f "$f" ] || die "$f is missing"; done
[ "$(ls harness/probe/web | paste -sd' ' -)" = 'AdviceFirst.java AdviceWide.java Prec.java Who.java' ] || die "harness/probe/web holds another file: javac compiles all of it"

# The ports and the Docker names, BEFORE anything is wiped (a survivor of an interrupted run answers POST /shutdown only with its
# token, which lives in .harness/ - so the message names the process to kill).
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
for p in 18425 8080 35729 19440 19441 19442 19443 19444 19445 19446 19447 19448 19449; do
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
# Boot's web group at DEBUG (the embedded-Tomcat lesson's line); POST /shutdown without the token (the secrets lesson's line); and this
# unit's line in the anchor's README: the path-variable lesson's one-customer line, its name one nobody has
R_WEB=$(readme "$J --logging.level.web=debug")
R_403=$(readme "curl -s -w ' %{http_code}\n' -X POST http://127.0.0.1:18431/shutdown")
R_NOBODY=$(readme "curl -s -w ' %{http_code}\n' http://127.0.0.1:18431/customers/Nobody")
[ "${R_WEB#"$J "}" = '--logging.level.web=debug' ] || die "the README's options"
O_WEB=${R_WEB#"$J "}
P_='/customers/Ravi'; Q_='/customers/Nobody'; r=${R_ONE/"$P_"/$Q_}; [ "$r" = "$R_NOBODY" ] || die "the anchor's new line must be the one-customer line with the name Nobody, and nothing else"
# This unit's own lines (README.md, "The commands this unit adds") - each asserted to be exactly that: the anchor's run and class-path
# lines with the JVM's locale pinned; the harness's javac line, against after/'s extracted jar, with -parameters; the anchor's new line
# with curl's Content-Type printed and one Accept header - a browser's type alone, XML alone, and a browser's whole header (Chrome's)
mine() { grep -m1 -xF -- "$1" README.md > /dev/null || die "README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
L_RUNL=$(mine 'java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431')
L_CPL=$(mine 'java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431')
L_JAVAC=$(mine 'javac -parameters -d .harness/hc -cp ".harness/after/tiffinbox-web/target/extracted/lib/*:.harness/after/tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar" harness/probe/web/AdviceFirst.java harness/probe/web/AdviceWide.java harness/probe/web/Prec.java harness/probe/web/Who.java')
CHROME='text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7'
L_HTML=$(mine "curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html' http://127.0.0.1:18431/customers/Nobody")
L_XML=$(mine "curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: application/xml' http://127.0.0.1:18431/customers/Nobody")
L_CHROME=$(mine "curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: $CHROME' http://127.0.0.1:18431/customers/Nobody")
P_='java '; Q_='java -Duser.language=en -Duser.country=US '; r=${R_RUN/"$P_"/$Q_}; r2=${R_CP/"$P_"/$Q_}
[ "$r" = "$L_RUNL" ] && [ "$r2" = "$L_CPL" ] || die "the pinned lines must be the anchor's run and class-path lines with -Duser.language=en -Duser.country=US after java, and nothing else"
[ "${L_JAVAC#* -cp \"*\" }" = "$HWS" ] || die "the harness's javac line must compile the four files in harness/probe/web, and nothing else"
WS=" -w ' %{http_code}\n'"; WT=" -w ' %{http_code} · Content-Type: [%{content_type}]\n'"
for t in "text/html:$L_HTML" "application/xml:$L_XML" "$CHROME:$L_CHROME"; do a_=${t%%:*}; l_=${t#*:}
  P_=" -H 'Accept: $a_'"; r=${l_/"$P_"/}; r=${r/"$WT"/$WS}; [ "$r" = "$R_NOBODY" ] || die "an Accept line must be the anchor's new line with Content-Type printed and one Accept header, and nothing else: $l_"; done
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
# exe 'COMMAND': the command with "exec" after its "cd DIR && " and any NAME=value before the program - so $pid is the program's
exe() { printf '%s\n' "$1" | sed -E 's/&& (([A-Z_]+=[^ ]* )*)/\&\& \1exec /'; }
# The docker lines, as this script runs them: the README's build line with plain progress and this script's own tag; its run line
# with this script's own name and tag, the port published on 127.0.0.1 made PORT, and your user and group added - the config tree
# is yours, mode 0600 (R.74). undock() takes those changes back out, and must give the README's lines again.
UARG='--user "$(id -u):$(id -g)"'
dbuild() { local c=${R_DBUILD/docker build -t tiffinbox-docker:1.0.0 /docker build --progress=plain -t $IMG }; printf 'cd %s && %s\n' "$1" "$c"; }
drun() { local c=${R_DRUN/--name tiffinbox /--name $BOX $UARG }; c=${c/127.0.0.1:18431:18425/127.0.0.1:$2:18425}; c=${c/% tiffinbox-docker:1.0.0/ $IMG}; printf 'cd %s && %s\n' "$1" "$c"; }
undock() { local c=${1#cd * && }; c=${c/--progress=plain /}; c=${c/" $UARG"/}; c=${c//$IMG/tiffinbox-docker:1.0.0}; c=${c/--name $BOX /--name tiffinbox }; c=${c/127.0.0.1:1944?:18425/127.0.0.1:18431:18425}; printf '%s\n' "$c"; }
[ "$(undock "$(dbuild .harness/x)")" = "$R_DBUILD" ] || die "not the README's build line with the declared changes: $(dbuild .harness/x)"
[ "$(undock "$(drun .harness/x 19447)")" = "$R_DRUN" ] || die "not the README's run line with the declared changes: $(drun .harness/x 19447)"
C_PRE=$(off .harness/pre "$R_INSTALL" install)
for c in "$C_PRE" "$(off .harness/x "$R_PLAIN" package)" "$(off .harness/x "$R_PNAT" package)" "$(off .harness/x "$R_NATIVE")"; do
  r=$(dev "$c"); [ "$r" = "$R_PLAIN" ] || [ "$r" = "$R_PNAT" ] || [ "$r" = "$R_INSTALL" ] || [ "$r" = "$R_NATIVE" ] || die "not a README line with the offline changes: $c"; done
[ "$(exe "$(at .harness/x 19440 "$R_RUN")")" = 'cd .harness/x && exec java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19440' ] || die "exe()"
[ "$(at .harness/x 18431 "$R_RUN")" = "cd .harness/x && $L_RUNL" ] && [ "$(at .harness/x 18431 "$R_CP")" = "cd .harness/x && $L_CPL" ] && [ "$(at .harness/x 19448 "$R_BIN")" = 'cd .harness/x && tiffinbox-web/target/tiffinbox-web --tiffinbox.port=19448' ] || die "at(): the pinned lines are not README.md's, or the binary's line got the JVM's options"
[ "$(hcp .harness/x 19442 probe.web.Who "$O_WEB")" = 'cd .harness/x && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19442 --spring.main.sources=probe.web.Who --logging.level.web=debug' ] || die "hcp()"
[ "$(bc 19440 /customers/Sunil%20K)" = "curl -s -w ' %{http_code}\n' http://127.0.0.1:19440/customers/Sunil%20K" ] && [ "$(bc 18431 /customers/Nobody)" = "$R_NOBODY" ] && [ "$(bc 19440 '/customers?mealType=veg')" = "curl -s -w ' %{http_code}\n' 'http://127.0.0.1:19440/customers?mealType=veg'" ] || die "bc()"
echo "  the commands: after/README.md gives all 19 lines this script runs or derives from; README.md the 6 this unit adds"

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
# date masked and its paragraph counted, never shown; curl's status line after it; a JSON answer with its error timestamp masked
pagef() { python3 -c '
import re, sys
for l in sys.stdin.read().splitlines():
    if l.startswith("<html>"):
        h = re.search(r"<h1>(.*?)</h1>", l); e = re.search(r"<div>(There was an unexpected error .*?)</div>", l); c = re.search(r"<div id=.created.>[^<]*</div>", l)
        tail = l[l.index("</html>") + len("</html>"):] if "</html>" in l else ""
        ps = len(re.findall(r"<p>", l))
        if h and e and c and tail:
            print("  the Whitelabel page (Boot'"'"'s) - its <h1>: %s · its error line: %s · its created date: masked · its paragraphs: %d, not shown · then curl'"'"'s:%s" % (h.group(1), e.group(1), ps, tail))
        else: print("  an HTML page, not the Whitelabel page: %d characters, not shown%s" % (len(l) - len(tail), " · then curl'"'"'s:" + tail if tail else ""))
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

# ---- change: the exception, the advice, and the throw ----------------------------------------------------------------------
cdiff() { diff -U0 "$1" "$2" | tail -n +3 > .harness/code.diff || true
  echo "  its code lines' diff (diff -U0 of the lines above, its file names cut) - hunks: $(grep -c '^@@ ' .harness/code.diff || true) · lines out: $(grep -c '^-' .harness/code.diff || true) · in: $(grep -c '^+' .harness/code.diff || true) - whole:"
  sed 's/^/    /' .harness/code.diff; }
# newf FILE: a file the previous tree does not have - its lines, and its code lines (neither comment nor blank) whole
newf() { code ".harness/after/$1" > .harness/nf.txt
  echo "  ${1##*/} - new: $(lines ".harness/after/$1") lines · its lines that are neither comment nor blank: $(wc -l < .harness/nf.txt | tr -d ' ') - whole:"
  sed 's/^/    /' .harness/nf.txt; }
change() { local f n m k
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
  f="$W/TiffinBoxServer.java"
  code ".harness/before/$f" > .harness/fb.txt; code ".harness/after/$f" > .harness/fa.txt
  grep -v '^import ' .harness/fb.txt > .harness/fbi.txt || true; grep -v '^import ' .harness/fa.txt > .harness/fai.txt || true
  echo "  TiffinBoxServer.java: $(lines ".harness/before/$f") lines -> $(lines ".harness/after/$f") · its lines that are neither comment nor blank: $(wc -l < .harness/fb.txt | tr -d ' ') -> $(wc -l < .harness/fa.txt | tr -d ' ') · naming ResponseStatusException: $(grep -c 'ResponseStatusException' .harness/fb.txt || true) -> $(grep -c 'ResponseStatusException' .harness/fa.txt || true), of them imports: $(grep -c '^import .*ResponseStatusException' .harness/fb.txt || true) -> $(grep -c '^import .*ResponseStatusException' .harness/fa.txt || true) · naming CustomerNotFound: $(grep -c 'CustomerNotFound' .harness/fb.txt || true) -> $(grep -c 'CustomerNotFound' .harness/fa.txt || true)"
  cdiff .harness/fb.txt .harness/fa.txt
  newf "$W/CustomerNotFound.java"; newf "$W/TiffinBoxErrors.java"
  diff .harness/before/README.md .harness/after/README.md > .harness/file.diff || true
  echo "  README.md - the anchor's README: lines added $(grep -c '^> ' .harness/file.diff || true), removed $(grep -c '^< ' .harness/file.diff || true) - its new section and the history notes the change made false (not shown)"
  libs .harness/before/$JARP > .harness/lb.txt; libs .harness/after/$JARP > .harness/la.txt
  echo "the executable jar's BOOT-INF/lib: $(wc -l < .harness/lb.txt | tr -d ' ') jars -> $(wc -l < .harness/la.txt | tr -d ' ') · the same names: $(cmp -s .harness/lb.txt .harness/la.txt && echo yes || echo no)"
  unzip -Z1 .harness/before/$JARP | grep '^BOOT-INF/classes/com/tiffinbox/web/.*\.class$' | sed 's#.*/##' | sort > .harness/cb.txt || true
  unzip -Z1 .harness/after/$JARP | grep '^BOOT-INF/classes/com/tiffinbox/web/.*\.class$' | sed 's#.*/##' | sort > .harness/ca.txt || true
  echo "the classes in the jar's com/tiffinbox/web: $(wc -l < .harness/cb.txt | tr -d ' ') -> $(wc -l < .harness/ca.txt | tr -d ' ') · only after/'s: $(comm -13 .harness/cb.txt .harness/ca.txt | paste -sd' ' - | grep . || echo none) · only the previous tree's: $(comm -23 .harness/cb.txt .harness/ca.txt | paste -sd' ' - | grep . || echo none)"; }

# ---- notfound: the answer, and who gives it -----------------------------------------------------------------------------------
notfound() {
  echo "the seven - after/, the README's run line, port 19440, a fresh JVM:"
  start "$(at .harness/after 19440 "$R_RUN")"; up 19440; ready 19440; seven 19440 .harness/after
  WARNS; logl 0 WARN
  echo "after/ - a second start, port 19440: a name nobody has (the anchor's new line), a name with a space, then Ravi:"
  start "$(at .harness/after 19440 "$R_RUN")"; up 19440; ready 19440
  ask 19440 /customers/Nobody; ask 19440 /customers/Sunil%20K; ask 19440 /customers/Ravi
  WARNS; stop 19440 .harness/after
  echo "the previous tree - the same three, port 19441:"
  start "$(at .harness/before 19441 "$R_RUN")"; up 19441; ready 19441
  ask 19441 /customers/Nobody; ask 19441 /customers/Sunil%20K; ask 19441 /customers/Ravi
  WARNS; stop 19441 .harness/before
  echo "who answers - after/ with the harness's Who joined, port 19442 - read off the running application:"
  start "$(hcp .harness/after 19442 probe.web.Who)"; up 19442; ready 19442
  ask 19442 /probe/who/advice
  stop 19442 .harness/after
  echo "who resolved it, at DEBUG - the embedded-Tomcat lesson's line (Boot's web group at DEBUG): after/, port 19440:"
  start "$(at .harness/after 19440 "$R_WEB")"; up 19440; ready 19440
  dreq "$(bc 19440 /customers/Nobody)"
  stop 19440 .harness/after
  echo "the previous tree, the same line, port 19441:"
  start "$(at .harness/before 19441 "$R_WEB")"; up 19441; ready 19441
  dreq "$(bc 19441 /customers/Nobody)"
  stop 19441 .harness/before; }

# ---- precedence: which handler wins ---------------------------------------------------------------------------------------------
precs() { ask 19442 /probe/who/advice
  echo "  the harness's Prec - four routes, each throwing one exception; its own handler takes IllegalStateException:"
  ask 19442 /probe/prec/iae; ask 19442 /probe/prec/nfe; ask 19442 /probe/prec/ise; ask 19442 /probe/prec/uoe
  echo "  TiffinBox's own routes - a name nobody has; a meal type that is not one (the path-variable lesson's 400):"
  ask 19442 /customers/Nobody; ask 19442 '/customers?mealType=veg'
  WARNS; stop 19442 .harness/after; }
precedence() {
  echo "after/ with the harness's Who, Prec and AdviceWide joined, port 19442 - AdviceWide at the default order:"
  start "$(hcp .harness/after 19442 probe.web.Who,probe.web.Prec,probe.web.AdviceWide)"; up 19442; ready 19442
  precs
  echo "AdviceFirst joined too - ordered first (Ordered.HIGHEST_PRECEDENCE), one handler for any RuntimeException, no status - port 19442:"
  start "$(hcp .harness/after 19442 probe.web.Who,probe.web.Prec,probe.web.AdviceWide,probe.web.AdviceFirst)"; up 19442; ready 19442
  precs; }

# ---- status: A/B/A' - the handler's @ResponseStatus; C and D, labelled - what a client that accepts other types gets ------------
# plants FILE OUT: TiffinBoxErrors.java without its handler's @ResponseStatus - that one line deleted - a planted copy for B
STLINE='    @ResponseStatus(HttpStatus.NOT_FOUND)'
plants() { awk -v a="$STLINE" '$0 == a { n++; next } { print } END { exit (n == 1 ? 0 : 1) }' "$1" > "$2" || die "plants: the handler's @ResponseStatus line is not in $1 exactly once"; }
statusa() { start "$(at .harness/after 19440 "$R_RUN")"; up 19440; ready 19440
  ask 19440 /customers/Nobody; ask 19440 /customers/Ravi
  WARNS; stop 19440 .harness/after; }
accepts() { hq "$L_HTML" "$1"; hq "$L_XML" "$1"; hq "$L_CHROME" "$1"; WARNS; }
status() {
  echo "A - after/, the README's run line, port 19440 - a name nobody has, then Ravi:"
  statusa
  echo "B - a copy of after/ whose handler names no status - its one changed line - then built the same way, port 19443:"
  copy after .harness/plant; plants "after/$W/TiffinBoxErrors.java" ".harness/plant/$W/TiffinBoxErrors.java"
  echo "\$ diff -U0 after/$W/TiffinBoxErrors.java .harness/plant/$W/TiffinBoxErrors.java"
  diff -U0 "after/$W/TiffinBoxErrors.java" ".harness/plant/$W/TiffinBoxErrors.java" | tail -n +3 | sed 's/^/  /' || true
  echo "  the exercise's copy ($XERR) is this copy's file, byte for byte: $(cmp -s "$XERR" ".harness/plant/$W/TiffinBoxErrors.java" && echo yes || echo no)"
  pbuild .harness/plant "the copy"
  start "$(at .harness/plant 19443 "$R_RUN")"; up 19443; ready 19443
  ask 19443 /customers/Nobody; ask 19443 /customers/Ravi
  WARNS; stop 19443 .harness/plant
  echo "A' - A again, on a fresh JVM:"
  statusa
  echo "A' against A, its label aside, line for line the same: $(asame 'A - after/' 'B - a copy' "A' - A again" "A' against A")"
  echo "C (labelled) - A asked by three clients, each sent by curl: one that accepts only HTML (a browser's type), one that accepts only XML, and a browser's whole Accept header (Chrome's) - port 19440:"
  start "$(at .harness/after 19440 "$R_RUN")"; up 19440; ready 19440
  accepts 19440; stop 19440 .harness/after
  echo "D (labelled) - the previous tree, the same three, port 19441:"
  start "$(at .harness/before 19441 "$R_RUN")"; up 19441; ready 19441
  accepts 19441; stop 19441 .harness/before; }

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
  echo "  the shell is now in: $(where "$d1") · the copy's own token in its log: $(raw "$(head -1 .harness/mine/after/$TF)" .harness/ex-readme.log) times · WARN lines in its log: $(grep -c ' WARN ' .harness/ex-readme.log || true) · ERROR lines: $(grep -c ' ERROR ' .harness/ex-readme.log || true) · listening on 19449 now: $(listeners 19449)"
  echo "the solution's $(printf '%s\n' "$sol" | grep -c .) lines, next, in the same shell:"
  printf '%s\n' "$sol" | sed 's/^/  $ /'
  echo "  exit $e2 · what they printed:"; sed 's/^/    /' .harness/ex-sol.out
  echo "  the shell is now in: $(where "$d2") · the copy's own token in its log: $(raw "$(head -1 .harness/mine/after/$TF)" .harness/mine/run.log) times · WARN lines in its log: $(grep -c ' WARN ' .harness/mine/run.log || true) · ERROR lines: $(grep -c ' ERROR ' .harness/mine/run.log || true) · listening on 19449 now: $(listeners 19449)"
  echo "  the copy's TiffinBoxErrors.java against after/'s now: $(cmp -s ".harness/mine/after/$W/TiffinBoxErrors.java" "after/$W/TiffinBoxErrors.java" && echo 'the same, byte for byte' || echo 'different')"; }

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
  if [ "$1" = '4 the image' ]; then [ "$(grep -c '^  docker port: ' .harness/blk.txt)" = 2 ] && [ "$(grep -cE '^  docker port: 18425/tcp -> 127\.0\.0\.1:19447$' .harness/blk.txt)" = 2 ] && echo yes || echo no
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
PL=$(printf '%s\n' "<html><body><h1>Whitelabel Error Page</h1><p>planted paragraph</p><div id='created'>Sat Oct 17 07:04:55 CEST 2026</div><div>There was an unexpected error (type=Internal Server Error, status=500).</div></body></html> 500 · Content-Type: [text/html;charset=UTF-8]" '<html><body><h1>HTTP Status 400 – Bad Request</h1></body></html> 400 · Content-Type: [text/html]' | pagef)
[ "$PL" = "$(printf '%s\n' "  the Whitelabel page (Boot's) - its <h1>: Whitelabel Error Page · its error line: There was an unexpected error (type=Internal Server Error, status=500). · its created date: masked · its paragraphs: 1, not shown · then curl's: 500 · Content-Type: [text/html;charset=UTF-8]" "  an HTML page, not the Whitelabel page: 64 characters, not shown · then curl's: 400 · Content-Type: [text/html]")" ] || die "pagef: the planted pages do not come out as declared"
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
froutes() { rq "$(bc "$1" /customers/Nobody)" nolog; rq "$(bc "$1" /customers/Sunil%20K)" nolog; rq "$(bc "$1" /customers/Ravi)" nolog
  hq "$L_HTML" "$1" nolog; rq "$(url "$R_403" "$1")" nolog; }
dseven() { echo "\$ \$CURLSET $1 .harness/after/$TF"
  "$CURLSET" "$1" ".harness/after/$TF" | grep ' -> ' > .harness/responses.txt || true
  tsmask < .harness/responses.txt > .harness/responses.m.txt
  grep '^POST ' .harness/responses.m.txt | sed 's/^/  /' || echo "  (no POST line)"
  dgone "$BOX"; [ "$(listeners "$1")" = 0 ] || die "something still listens on $1"
  echo "  exit $LASTE · the seven responses: $(wc -l < .harness/responses.m.txt | tr -d ' ') lines · lines the timestamp mask changed: $(diff .harness/responses.txt .harness/responses.m.txt | grep -c '^<' || true) · md5 $(md5 -q .harness/responses.m.txt)"
  dlog "$BOX"; echo "  its log (docker logs): Boot's first line: $(first .harness/run.out) · the demo token 0 times · X-Shutdown-Token 0 times"
  docker rm "$BOX" > /dev/null; }
NOB='  {"error":"no customer named Nobody"} 404'
forms() {
  echo "the native build - after/ copied to .harness/nat with a config tree; the README's two Maven lines, offline; \$GRAALVM_HOME names the GraalVM:"
  copy after .harness/nat
  nbuild .harness/nat; nlines .harness/nat.native.log; nresult .harness/nat.native.log
  echo "  file: $(file -b ".harness/nat/$BIN" | sed 's/ [A-Za-z0-9_]*$//') · the demo token in its bytes: $(raw "$TOKEN" ".harness/nat/$BIN")"
  echo "what Spring's AOT step registered - the previous tree built with the README's native-profile line too (.harness/natb), then its metadata against after/'s:"
  copy "$PREV" .harness/natb; pbuild .harness/natb "the previous tree, the profile native" "$R_PNAT"
  aotcmp .harness/natb .harness/nat
  echo "1 the jar - .harness/after, the README's run line, port 19440:"
  start "$(at .harness/after 19440 "$R_RUN")"; up 19440; ready 19440; tline; seven 19440 .harness/after
  echo "  then a name nobody has, a name with a space, Ravi, the first for a client that accepts only HTML, and POST /shutdown without the token, on a second start of the jar:"
  start "$(at .harness/after 19440 "$R_RUN")"; up 19440; ready 19440; froutes 19440; stop 19440 .harness/after
  echo "2 the AOT jar - .harness/nat (the profile native's jar), the README's AOT line, port 19444:"
  start "$(at .harness/nat 19444 "$R_AOTRUN")"; up 19444; ready 19444; tline; seven 19444 .harness/nat
  echo "  then the same five, on a second start of the AOT jar:"
  start "$(at .harness/nat 19444 "$R_AOTRUN")"; up 19444; ready 19444; froutes 19444; stop 19444 .harness/nat
  echo "3 the binary - .harness/nat, the README's line, port 19448:"
  start "$(at .harness/nat 19448 "$R_BIN")"; up 19448; ready 19448; tline; seven 19448 .harness/nat
  echo "  then the same five, on a second start of the binary:"
  start "$(at .harness/nat 19448 "$R_BIN")"; up 19448; ready 19448; froutes 19448; stop 19448 .harness/nat
  echo "4 the image - after/'s Dockerfile (the README's build line, this script's tag), the README's run line with your user, published on 127.0.0.1:19447:"
  image
  dstart "$(drun .harness/after 19447)"; ready 19447 "$BOX"; dbind 19447
  dseven 19447
  echo "  then the same five, on a second container of the image - TiffinBox listens on 18425 inside it:"
  dstart "$(drun .harness/after 19447)"; ready 19447 "$BOX"; dbind 19447
  froutes 19447
  post 19447 .harness/after; dgone "$BOX"; [ "$(listeners 19447)" = 0 ] || die "something still listens on 19447"
  dlog "$BOX"; echo "  exit $LASTE · its log (docker logs): the demo token 0 times · X-Shutdown-Token 0 times"
  docker rm "$BOX" > /dev/null
  echo "four forms, one tree: the seven (masked) $(grep -cE '^  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 2 · md5 87ca7efc8584dcccd40e6b956db1de9b$' .harness/cap.raw) of 4 times 87ca7efc8584dcccd40e6b956db1de9b · a name nobody has, 404 and the name $(grep -cxF -- "$NOB" .harness/cap.raw) of 4 · a name with a space, 404 and the name $(grep -cxF -- '  {"error":"no customer named Sunil K"} 404' .harness/cap.raw) of 4 · Ravi 200 $(grep -cxF -- '  {"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"} 200' .harness/cap.raw) of 4 · the name nobody has for a client that accepts only HTML, Boot's 500 page $(grep -cxF -- "  the Whitelabel page (Boot's) - its <h1>: Whitelabel Error Page · its error line: There was an unexpected error (type=Internal Server Error, status=500). · its created date: masked · its paragraphs: 1, not shown · then curl's: 500 · Content-Type: [text/html;charset=UTF-8]" .harness/cap.raw) of 4 · POST /shutdown without the token 403 $(grep -cxF '  {"error":"forbidden"} 403' .harness/cap.raw) of 4"
  echo "  loopback, form by form: the jar $(lbk '1 the jar') · the AOT jar $(lbk '2 the AOT jar') · the binary $(lbk '3 the binary') · the image, published on 127.0.0.1 alone $(lbk '4 the image')"
  echo "  the locale: options on the binary's and the image's run lines: $(printf '%s\n%s\n' "$(at .harness/nat 19448 "$R_BIN")" "$(drun .harness/after 19447)" | grep -o 'user\.language\|user\.country' | wc -l | tr -d ' ') (none passed: the binary runs as the README writes it, the image as its ENTRYPOINT, java -jar, unpinned) - nothing they print here depends on one: each answer above the pinned jar's, 4 of 4"; }



cap change change
cap notfound notfound
cap precedence precedence
cap status status
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
for f in .r-*.out README.md exercise/README.md exercise/solution/SOLUTION.md receipts.md5 harness/shutdown.sh $XERR $HWS .harness/nat/$BIN; do
  [ -f "$f" ] || continue; case $f in .harness/nat*) NBIN=$((NBIN + 1)) ;; esac
  [ "$(raw "$TOKEN" "$f")" = 0 ] || die "$f holds the demo token, raw"; done
[ "$NBIN" = 1 ] || die "one binary was built, $NBIN were checked"
for f in .r-*.out; do ! grep -qE '/Users/|/private/|/home/|/var/folders/' "$f" || die "$f holds an absolute path"; [ -z "${GRAALVM_HOME:-}" ] || ! grep -qF "$GRAALVM_HOME" "$f" || die "$f holds the GraalVM's folder"; ! grep -qE 'c[0-9]-unit[0-9]|unit ?[0-9]' "$f" || die "$f holds a unit number"; ! grep -qE ' (with PID|started by) ' "$f" || die "$f holds Boot's process line"; ! grep -qE '^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T|"timestamp":"?[0-9]|timestamp=[A-Z0-9]|(exec|handler|task|utility)-[0-9]|GMT|CES?T|<div id=.created|[A-Z][a-z][a-z] [A-Z][a-z][a-z] [0-9]+ [0-9][0-9]:[0-9][0-9]' "$f" || die "$f holds a log line's time, a timestamp, a date or a thread's number"; ! grep -q "^$(printf '\t')at " "$f" || die "$f shows a stack frame"; ! grep -qE 'SpringCGLIB\$\$[0-9]' "$f" || die "$f holds a generated class's number"; ! grep -qE 'sha256:[0-9a-f]{64}' "$f" || [ "$(grep -cE 'sha256:[0-9a-f]{64}' "$f")" = "$(grep -cE 'eclipse-temurin(:25-jre)?@sha256:[0-9a-f]{64}' "$f")" ] || die "$f holds an ID other than the base image's digest"; ! grep -qE ':(8080|35729)([^0-9]|$)' "$f" || die "$f shows a bind on 8080 or 35729"; ! grep -q $'\r' "$f" || die "$f holds a carriage return"; ! grep -q '<html>' "$f" || die "$f shows an HTML page whole"; done
for f in receipts.sh README.md exercise/README.md exercise/solution/SOLUTION.md harness/shutdown.sh $HWS; do [ -f "$f" ] || continue; ! grep -qE "exposure\.include='?\*" "$f" || die "$f exposes every endpoint (R.42)"; done
# S3.21 (R.99): Boot 4.1 reads only spring.web.error.*, and Boot 3's keys (server, then error) are ignored without a word - no file of
# this unit names one, the anchor's tree included (the name is split here, so this line does not spell it)
K3='server'; K3="$K3.error."
for f in receipts.sh README.md exercise/README.md exercise/solution/SOLUTION.md harness/shutdown.sh $XERR $HWS; do ! grep -qF "$K3" "$f" || die "$f names one of Boot 3's error keys - Boot 4.1 reads only spring.web.error.* (S3.21)"; done
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
RQ() { printf '$ %s' "$(url "$1" "$2")"; }
BQ() { printf '$ %s' "$(bc "$1" "$2")"; }
[ "$(BQ 19440 /customers/Nobody)" = "\$ $(url "$R_NOBODY" 19440)" ] && [ "$(BQ 19440 /customers/Ravi)" = "\$ $(url "$R_ONE" 19440)" ] || die "the checks' own command lines are not the README's"
Z() { printf '%s · WARN lines it added: %s · ERROR lines: %s' "$1" "$2" "$3"; }
NOB4='  {"error":"no customer named Nobody"} 404'; SUN4='  {"error":"no customer named Sunil K"} 404'
RAVI='  {"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"} 200'
BOOT4() { printf '  {"timestamp":"…","status":404,"error":"Not Found","path":"%s"} 404' "$1"; }
WL() { printf "  the Whitelabel page (Boot's) - its <h1>: Whitelabel Error Page · its error line: There was an unexpected error (type=%s, status=%s). · its created date: masked · its paragraphs: 1, not shown · then curl's: %s · Content-Type: [text/html;charset=UTF-8]" "$1" "$2" "$2"; }
FAILW='    WARN .m.m.a.ExceptionHandlerExceptionResolver: Failure in @ExceptionHandler com.tiffinbox.web.TiffinBoxErrors#notFound(CustomerNotFound)'
FAILX='      org.springframework.web.HttpMediaTypeNotAcceptableException: No acceptable representation'
TOME='    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: Servlet.service() for servlet [dispatcherServlet] in context with path [] threw exception [Request processing failed: com.tiffinbox.web.CustomerNotFound: no customer named Nobody] with root cause'
F40='      its stack frames: over 40, its other lines: 2 - none shown'

# "Throw an exception of your own ... CustomerNotFound, eleven lines of code ... TiffinBoxErrors ... the throw, one line" - the files,
# the diff, the two new classes in the jar, the same 56 libraries
CO=$(cat .r-change.out)
for l in '  built the previous tree · offline: yes · exit 0' '  built after/ · offline: yes · exit 0' "  after/'s files: 27 · byte for byte the previous tree's: 23 · new: 2 · those that differ: 2"; do has "$CO" "$l" "change: the builds and the files"; done
[ "$(n change '^  Files ')" = 2 ] && [ "$(n change '^  Only in ')" = 2 ] || die "change: two files differ, two are new"
for f in README.md "$W/TiffinBoxServer.java"; do x change "^  Files \.harness/before/$f and \.harness/after/$f differ\$"; done
for f in CustomerNotFound TiffinBoxErrors; do has "$CO" "  Only in .harness/after/$W: $f.java" "change: $f.java new"; done
has "$CO" '  exit 0 · its classes: probe/web/AdviceFirst.class probe/web/AdviceWide.class probe/web/Prec.class probe/web/Who.class' "change: the harness, four classes"
has "$CO" "\$ $L_JAVAC" "change: the harness's javac line, -parameters"
has "$CO" '  TiffinBoxServer.java: 273 lines -> 274 · its lines that are neither comment nor blank: 141 -> 140 · naming ResponseStatusException: 2 -> 0, of them imports: 1 -> 0 · naming CustomerNotFound: 0 -> 1' "change: ResponseStatusException out, CustomerNotFound in"
CD=$(blk change "  TiffinBoxServer.java: " "  CustomerNotFound.java - new")
[ "$CD" = "$(printf '%s\n' "  its code lines' diff (diff -U0 of the lines above, its file names cut) - hunks: 2 · lines out: 2 · in: 1 - whole:" '    @@ -17 +16,0 @@' '    -import org.springframework.web.server.ResponseStatusException;' '    @@ -63 +62 @@' '    -                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "no customer named " + name));' '    +                .orElseThrow(() -> new CustomerNotFound(name));')" ] || die "change: TiffinBoxServer's diff is the import out and the one throw"
has "$CO" '  CustomerNotFound.java - new: 19 lines · its lines that are neither comment nor blank: 11 - whole:' "change: CustomerNotFound, 11 code lines"
has "$CO" '  TiffinBoxErrors.java - new: 28 lines · its lines that are neither comment nor blank: 14 - whole:' "change: TiffinBoxErrors, 14 code lines"
for l in '    final class CustomerNotFound extends RuntimeException {' '            super("no customer named " + name);' '    @RestControllerAdvice' '    final class TiffinBoxErrors {' '        @ExceptionHandler(CustomerNotFound.class)' '        @ResponseStatus(HttpStatus.NOT_FOUND)' '        Map<String, String> notFound(CustomerNotFound e) {' '            return Map.of("error", e.getMessage());'; do has "$CO" "$l" "change: the new classes"; done
x change "^the executable jar's BOOT-INF/lib: 56 jars -> 56 · the same names: yes\$"
x change "^the classes in the jar's com/tiffinbox/web: 7 -> 9 · only after/'s: CustomerNotFound\.class TiffinBoxErrors\.class · only the previous tree's: none\$"
grep -qx '    @ResponseStatus(HttpStatus.NOT_FOUND)' "after/$W/TiffinBoxErrors.java" && [ "$(grep -c '@ExceptionHandler' "after/$W/TiffinBoxErrors.java")" = 1 ] || die "change: after/'s advice has one handler, with its status"
echo "  change: TiffinBoxServer 273 -> 274, ResponseStatusException 2 -> 0, the throw CustomerNotFound; CustomerNotFound (11 code lines) and TiffinBoxErrors (14) new; 23 of 27 byte for byte; 56 libraries; 7 -> 9 classes"

# "A customer nobody has ... four oh four, and the body names who you asked for ... no warning line, nothing in the log ... the seven are
#  unchanged ... Before: Boot's body, no name ... the first of three resolvers ... the lowest order ... no error dispatch"
NF=$(cat .r-notfound.out)
has "$NF" "  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 2 · md5 $S87C" "notfound: the seven, unchanged"
N7=$(blk notfound "the seven - after/" "after/ - a second start")
has "$N7" "  WARN lines in this run's log, at Boot's default level: 1 · ERROR lines: 0" "notfound: the seven's run, one WARN line"
printf '%s\n' "$N7" | grep -qE "^    WARN \.w\.s\.m\.s\.DefaultHandlerExceptionResolver: Resolved \[org\.springframework\.web\.HttpRequestMethodNotSupportedException: Request method 'GET' is not supported\]\$" || die "notfound: the seven's one WARN is Spring MVC's DefaultHandlerExceptionResolver, the 405"
NA=$(blk notfound "after/ - a second start" "the previous tree - the same three")
[ "$(aft "$(BQ 19440 /customers/Nobody)" "$NA")" = "$(Z "$NOB4" 0 0)" ] && [ "$(aft "$(BQ 19440 /customers/Sunil%20K)" "$NA")" = "$(Z "$SUN4" 0 0)" ] && [ "$(aft "$(BQ 19440 /customers/Ravi)" "$NA")" = "$(Z "$RAVI" 0 0)" ] || die "notfound: after/ - 404 with the name, twice, Ravi 200, no WARN or ERROR line"
has "$NA" "  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0" "notfound: after/'s log, 0 and 0"
NB=$(blk notfound "the previous tree - the same three" "who answers - ")
[ "$(aft "$(BQ 19441 /customers/Nobody)" "$NB")" = "$(Z "$(BOOT4 /customers/Nobody)" 0 0)" ] && [ "$(aft "$(BQ 19441 /customers/Sunil%20K)" "$NB")" = "$(Z "$(BOOT4 /customers/Sunil%20K)" 0 0)" ] && [ "$(aft "$(BQ 19441 /customers/Ravi)" "$NB")" = "$(Z "$RAVI" 0 0)" ] || die "notfound: the previous tree - Boot's body, no name"
NW=$(blk notfound "who answers - " "who resolved it, at DEBUG")
for l in "  @RestControllerAdvice - the annotations it carries (java.lang.annotation's left out): @ControllerAdvice @ResponseBody" \
         '  the HandlerExceptionResolver beans, in the order the DispatcherServlet asks them: 2' \
         '    1 errorAttributes - org.springframework.boot.webmvc.error.DefaultErrorAttributes' \
         '    2 handlerExceptionResolver - org.springframework.web.servlet.handler.HandlerExceptionResolverComposite' \
         '        2.1 org.springframework.web.servlet.mvc.method.annotation.ExceptionHandlerExceptionResolver' \
         '        2.2 org.springframework.web.servlet.mvc.annotation.ResponseStatusExceptionResolver' \
         '        2.3 org.springframework.web.servlet.mvc.support.DefaultHandlerExceptionResolver' \
         "  ExceptionHandlerExceptionResolver's advice cache, in the order it asks: 1" \
         '    1 com.tiffinbox.web.TiffinBoxErrors · its order: 2147483647' \
         '        @ExceptionHandler notFound - takes CustomerNotFound · @ResponseStatus: NOT_FOUND' \
         "  a CustomerNotFound, each advice's method for it, in that order: TiffinBoxErrors: notFound" \
         "  the JVM's locale: en_US"; do has "$NW" "$l" "notfound: who answers"; done
[ "$(printf '%s\n' "$NW" | grep -c '^        2\.[0-9] ')" = 3 ] || die "notfound: three resolvers in the composite"
ND=$(blk notfound "who resolved it, at DEBUG" "the previous tree, the same line")
for l in "  the lines the log gained for it, Boot's web group at DEBUG (logger: message) - all 7:" '    .m.m.a.ExceptionHandlerExceptionResolver: Using @ExceptionHandler com.tiffinbox.web.TiffinBoxErrors#notFound(CustomerNotFound)' '    .m.m.a.ExceptionHandlerExceptionResolver: Resolved [com.tiffinbox.web.CustomerNotFound: no customer named Nobody]' '    m.m.a.RequestResponseBodyMethodProcessor: Writing [{error=no customer named Nobody}]' '    o.s.web.servlet.DispatcherServlet: Completed 404 NOT_FOUND'; do has "$ND" "$l" "notfound: at DEBUG, the advice"; done
! printf '%s\n' "$ND" | grep -q 'dispatch' || die "notfound: no error dispatch on after/"
NE=$(blk notfound "the previous tree, the same line" "")
for l in "  the lines the log gained for it, Boot's web group at DEBUG (logger: message) - all 9:" '    .w.s.m.a.ResponseStatusExceptionResolver: Resolved [org.springframework.web.server.ResponseStatusException: 404 NOT_FOUND "no customer named Nobody"]' '    o.s.web.servlet.DispatcherServlet: "ERROR" dispatch for GET "/error", parameters={}' '    s.w.s.m.m.a.RequestMappingHandlerMapping: Mapped to org.springframework.boot.webmvc.autoconfigure.error.BasicErrorController#error(HttpServletRequest)' '    o.s.web.servlet.DispatcherServlet: Exiting from "ERROR" dispatch, status 404'; do has "$NE" "$l" "notfound: at DEBUG, the previous tree"; done
echo "  notfound: the seven $S87C; Nobody and Sunil K 404 with the name, 0 WARN 0 ERROR; the previous tree Boot's body, no name; @ControllerAdvice + @ResponseBody; resolver 2.1 of 3, one advice at 2147483647; DEBUG 7 lines, no error dispatch - the previous tree's ResponseStatusExceptionResolver and the error dispatch"

# "inside one advice, the nearest type wins ... the controller's own handler beats every advice ... no handler at all: Boot's five
#  hundred ... an advice ordered first takes everything ... two hundred, even for a customer nobody has"
P1=$(blk precedence "after/ with the harness's Who, Prec and AdviceWide" "AdviceFirst joined too")
P2=$(blk precedence "AdviceFirst joined too" "")
WHO() { printf '  {"who":"%s"} %s' "$1" "$2"; }
for l in "  ExceptionHandlerExceptionResolver's advice cache, in the order it asks: 2" '    1 probe.web.AdviceWide · its order: 2147483647' '    2 com.tiffinbox.web.TiffinBoxErrors · its order: 2147483647' "  a NumberFormatException, each advice's method for it, in that order: AdviceWide: nfe · TiffinBoxErrors: none"; do has "$P1" "$l" "precedence: two advices at the default order, in the order found"; done
[ "$(aft "$(BQ 19442 /probe/prec/iae)" "$P1")" = "$(Z "$(WHO 'AdviceWide: IllegalArgumentException' 400)" 0 0)" ] && [ "$(aft "$(BQ 19442 /probe/prec/nfe)" "$P1")" = "$(Z "$(WHO 'AdviceWide: NumberFormatException' 400)" 0 0)" ] || die "precedence: inside one advice, the nearest type"
[ "$(aft "$(BQ 19442 /probe/prec/ise)" "$P1")" = "$(Z "$(WHO "Prec, the controller's own handler: IllegalStateException" 400)" 0 0)" ] || die "precedence: the controller's own handler"
[ "$(aft "$(BQ 19442 /probe/prec/uoe)" "$P1")" = "$(Z '  {"timestamp":"…","status":500,"error":"Internal Server Error","path":"/probe/prec/uoe"} 500' 0 1)" ] && has "$P1" '    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: Servlet.service() for servlet [dispatcherServlet] in context with path [] threw exception [Request processing failed: java.lang.UnsupportedOperationException: not supported] with root cause' "precedence: no handler" || die "precedence: no handler - Boot's 500, Tomcat's ERROR line"
has "$P1" "  a MethodArgumentTypeMismatchException, each advice's method for it, in that order: AdviceWide: none · TiffinBoxErrors: none" "precedence: no handler takes the type mismatch by its type"
has "$P2" "  a MethodArgumentTypeMismatchException, each advice's method for it, in that order: AdviceFirst: any · AdviceWide: none · TiffinBoxErrors: none" "precedence: AdviceFirst takes the type mismatch by its type"
[ "$(aft "$(BQ 19442 /customers/Nobody)" "$P1")" = "$(Z "$NOB4" 0 0)" ] && [ "$(aft "$(BQ 19442 '/customers?mealType=veg')" "$P1")" = "$(Z "$(WHO 'AdviceWide: IllegalArgumentException' 400)" 0 0)" ] || die "precedence: TiffinBox's 404 kept; the type mismatch taken by AdviceWide's IllegalArgumentException handler"
for l in "  ExceptionHandlerExceptionResolver's advice cache, in the order it asks: 3" '    1 probe.web.AdviceFirst · its order: -2147483648' '        @ExceptionHandler any - takes RuntimeException · @ResponseStatus: none' "  a CustomerNotFound, each advice's method for it, in that order: AdviceFirst: any · AdviceWide: none · TiffinBoxErrors: notFound"; do has "$P2" "$l" "precedence: AdviceFirst first"; done
for p in /probe/prec/iae /probe/prec/nfe /probe/prec/uoe /customers/Nobody '/customers?mealType=veg'; do [ "$(aft "$(BQ 19442 "$p")" "$P2")" = "$(Z "$(WHO 'AdviceFirst: RuntimeException' 200)" 0 0)" ] || die "precedence: AdviceFirst takes $p, 200"; done
[ "$(aft "$(BQ 19442 /probe/prec/ise)" "$P2")" = "$(Z "$(WHO "Prec, the controller's own handler: IllegalStateException" 400)" 0 0)" ] || die "precedence: the controller's own handler, still"
has "$P2" "  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0" "precedence: AdviceFirst's run, 0 and 0"
echo "  precedence: NumberFormatException -> its own handler; IllegalStateException -> the controller's; UnsupportedOperationException -> Boot's 500, 1 ERROR; the type mismatch -> no handler by its type, AdviceWide's IllegalArgumentException handler by its cause, 0 WARN; AdviceFirst (-2147483648) -> 200 for five, the controller's 400 kept"

# "B: the same handler without that one line ... two hundred, with the error in the body ... A again: the same ... C: a client that
#  accepts only HTML ... five hundred, a warning and an error in the log ... only XML ... five hundred ... a browser's whole header ...
#  JSON, four oh four ... the old tree answered all three four oh four"
SA=$(blk status "A - after/" "B - a copy"); SB=$(blk status "B - a copy" "A' - A again"); SC=$(blk status "C (labelled)" "D (labelled)"); SD=$(blk status "D (labelled)" "")
[ "$(aft "$(BQ 19440 /customers/Nobody)" "$SA")" = "$(Z "$NOB4" 0 0)" ] || die "status A: 404"
[ "$(printf '%s\n' "$SB" | sed -n '2,3p')" = "$(printf '%s\n' '  @@ -24 +23,0 @@' '  -    @ResponseStatus(HttpStatus.NOT_FOUND)')" ] || die "status B: the diff is the one line"
has "$SB" "  the exercise's copy ($XERR) is this copy's file, byte for byte: yes" "status B: the exercise ships this copy"
[ "$(aft "$(BQ 19443 /customers/Nobody)" "$SB")" = "$(Z '  {"error":"no customer named Nobody"} 200' 0 0)" ] || die "status B: 200 with the error body"
x status "^A' against A, its label aside, line for line the same: yes\$"
[ "$(aft "$(RQ "$L_HTML" 19440)" "$SC")" = "$(Z "$(WL 'Internal Server Error' 500)" 1 1)" ] && [ "$(aft "$(RQ "$L_XML" 19440)" "$SC")" = "$(Z '   500 · Content-Type: []' 1 1)" ] && [ "$(aft "$(RQ "$L_CHROME" 19440)" "$SC")" = "$(Z '  {"error":"no customer named Nobody"} 404 · Content-Type: [application/json]' 0 0)" ] || die "status C: HTML only 500, XML only 500, a browser's whole header 404 JSON"
[ "$(printf '%s\n' "$SC" | grep -cxF -- "$FAILW")" = 2 ] && [ "$(printf '%s\n' "$SC" | grep -cxF -- "$FAILX")" = 2 ] && [ "$(printf '%s\n' "$SC" | grep -cxF -- "$TOME")" = 2 ] && [ "$(printf '%s\n' "$SC" | grep -cxF -- "$F40")" = 4 ] || die "status C: each 500 - the failed handler's WARN and its reason, Tomcat's ERROR line, frames over 40"
has "$SC" "  WARN lines in this run's log, at Boot's default level: 2 · ERROR lines: 2" "status C: 2 and 2"
[ "$(aft "$(RQ "$L_HTML" 19441)" "$SD")" = "$(Z "$(WL 'Not Found' 404)" 0 0)" ] && [ "$(aft "$(RQ "$L_XML" 19441)" "$SD")" = "$(Z '   404 · Content-Type: []' 0 0)" ] && [ "$(aft "$(RQ "$L_CHROME" 19441)" "$SD")" = "$(Z "$(WL 'Not Found' 404)" 0 0)" ] || die "status D: the previous tree - 404 for all three, the Whitelabel page for a browser"
echo "  status: A 404; B (no @ResponseStatus, one line) 200 with the body, the exercise's copy; A' = A; C HTML only 500, XML only 500 - 1 WARN (No acceptable representation) + 1 ERROR each - a browser's whole header 404 JSON; D the previous tree 404 x3"

# the exercise's end state: the README's commands, then the solution's, in ONE env -i shell - each leaves the shell in this folder; the
# line exercise/README.md calls "Done" is a line of this capture, after the solution's lines, and of SOLUTION.md's measured run
XS=$(blk exercise "the README's" "the solution's"); XE=$(blk exercise "the solution's" '')
l='status: 404 · body: {"error":"no customer named Nobody"}'; l0='status: 200 · body: {"error":"no customer named Nobody"}'
has "$XE" "    $l" "exercise: the solution"; has "$XS" "    $l0" "exercise: as shipped"
awk '/^\*\*Done\*\*/ { f = 1 } f' exercise/README.md | grep -qxF -- "$l" || die "exercise/README.md: Done names no such line"
grep -qxF -- "$l" exercise/solution/SOLUTION.md || die "SOLUTION.md: the measured run shows no such line"
grep -qF -- "\`$l0\`" exercise/README.md || die "exercise/README.md: the shipped line's answer is not named"
has "$XS" '  exit 0 · what they printed:' "exercise: the README's commands, exit 0"; has "$XE" '  exit 0 · what they printed:' "exercise: the solution's lines, exit 0"
for b in "$XS" "$XE"; do has "$b" "  the shell is now in: this unit's folder · the copy's own token in its log: 0 times · WARN lines in its log: 0 · ERROR lines: 0 · listening on 19449 now: 0" "exercise: the shell in this unit's folder, the token 0, the port free"; done
has "$XE" "  the copy's TiffinBoxErrors.java against after/'s now: the same, byte for byte" "exercise: the line added is after/'s line"
[ "$(printf '%s\n' "$XE" | grep -c '^  \$ export ')" = 2 ] || die "exercise: SOLUTION.md gives the README's two export lines"
EXQ="Your turn: the README's request for a missing customer answers two hundred. Find the handler's missing line, add it, and ask again."
grep -qxF -- "**Your turn:** ${EXQ#Your turn: }" exercise/README.md || die "exercise/README.md: the spoken exercise line"
[ "$(printf '%s\n' "$EXQ" | wc -w | tr -d ' ')" -le 25 ] || die "exercise: the spoken line is over 25 words"
echo "  exercise: one env -i shell - the README as written (no status on the handler) -> 200; the solution (the line put back) -> 404; the same body; the shell in this unit's folder after each"

# "Every form serves it: the jar, the AOT jar, built ahead of time, the native binary and the image. Each answers the seven the same,
#  four oh four with the name, two hundred for Ravi, and the same five hundred to a client that only reads HTML, on loopback"
x forms '^  exit 0 · BUILD SUCCESS · stages it printed: 8 of the 8 it announces · its lines that say the metadata repository was downloaded over http, or failed to: 0 · offline: yes$'
x forms '^  file: Mach-O 64-bit executable · the demo token in its bytes: 0$'
x forms '^  built the previous tree, the profile native · offline: yes · exit 0$'
x forms "^  Spring's generated metadata \(spring-aot/main/resources/META-INF/native-image/com\.tiffinbox/tiffinbox-web/reachability-metadata\.json\) - the previous tree's against after/'s: reflection entries 665 -> 666 · types only the previous tree registers: none · only after/: com\.tiffinbox\.web\.TiffinBoxErrors · entries that differ: 0\$"
x forms '^    com\.tiffinbox\.web\.TiffinBoxErrors - 1 method \(notFound\(CustomerNotFound\)\)$'
x forms '^  resource entries: 26 -> 26 · the same: yes$'
x forms "^four forms, one tree: the seven \(masked\) 4 of 4 times $S87C · a name nobody has, 404 and the name 4 of 4 · a name with a space, 404 and the name 4 of 4 · Ravi 200 4 of 4 · the name nobody has for a client that accepts only HTML, Boot's 500 page 4 of 4 · POST /shutdown without the token 403 4 of 4\$"
has "$(cat .r-forms.out)" "  the locale: options on the binary's and the image's run lines: 0 (none passed: the binary runs as the README writes it, the image as its ENTRYPOINT, java -jar, unpinned) - nothing they print here depends on one: each answer above the pinned jar's, 4 of 4" "forms: the binary and the image carry no locale option (S3.1)"
x forms '^  loopback, form by form: the jar yes · the AOT jar yes · the binary yes · the image, published on 127\.0\.0\.1 alone yes$'
# each form's block runs from its label to the next form's (a label:port:next label triple - a case inside $( ) is a syntax error to
# /bin/bash 3.2)
for t in '1 the jar:19440:2 the AOT jar' '2 the AOT jar:19444:3 the binary' '3 the binary:19448:4 the image' '4 the image:19447:four forms, one tree'; do lb_=${t%%:*}; r_=${t#*:}; p_=${r_%%:*}; nx_=${r_#*:}
  b=$(blk forms "$lb_ - " "$nx_")
  [ "$(aft "$(BQ "$p_" /customers/Nobody)" "$b")" = "$NOB4" ] && [ "$(aft "$(BQ "$p_" /customers/Sunil%20K)" "$b")" = "$SUN4" ] && [ "$(aft "$(BQ "$p_" /customers/Ravi)" "$b")" = "$RAVI" ] || die "forms $lb_: 404 with the name, twice, Ravi 200, on its own port"
  [ "$(aft "$(RQ "$L_HTML" "$p_")" "$b")" = "$(WL 'Internal Server Error' 500)" ] || die "forms $lb_: only HTML, Boot's 500 page"
  has "$b" "  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 2 · md5 $S87C" "forms $lb_: the seven"; done
[ "$(n forms "^  Boot's first line: Starting AOT-processed TiffinBoxServer v1\.0\.0 using Java 25\.0\.4\.1\$")" = 2 ] && [ "$(n forms "^  Boot's first line: Starting AOT-processed TiffinBoxServer using Java 25\.0\.4\.1\$")" = 2 ] || die "forms: the AOT jar and the binary, AOT-processed, both starts"
[ "$(n forms '^  inside the container, listening: \[::\]:18425$')" = 2 ] && [ "$(n forms '^  docker port: 18425/tcp -> 127\.0\.0\.1:19447$')" = 2 ] || die "forms: the image, two containers, 18425 inside, published on 127.0.0.1:19447 alone"
x forms '^  its lines that say pull: 0 · '
x forms '^  the image saved \(docker save\): [1-9][0-9]* blobs, its [1-9][0-9]* layers among them, each read whole \(gzip ones unpacked\) · the demo token in them: 0$'
echo "  forms: 8 of 8 stages, offline, Mach-O, 0 tokens; the AOT metadata 665 -> 666, TiffinBoxErrors (notFound) the one new entry; the jar, the AOT jar, the binary, the image: the seven $S87C 4 of 4, Nobody and Sunil K 404 with the name 4 of 4, Ravi 200 4 of 4, only-HTML Boot's 500 page 4 of 4, 403 4 of 4; loopback form by form; the image's layers 0 tokens"

cmp -s after/README.md ../c6-tiffinbox/README.md || echo "  (after/README.md and ../c6-tiffinbox/README.md differ - the anchor has moved past this unit's after/)" >&3
[ -z "$unpub" ] || die "no published hash for:$unpub - check the captures, then copy the md5s above into receipts.md5 and run again"
echo "c6-unit15: every capture 3/3 and = published; every spoken number asserted; 0 raw demo tokens in every capture, every log, the container's log, the image's layers and the binary; nothing of this run left on Docker"
