#!/bin/bash
XPATH=$PATH                                           # the PATH you started this with: the exercise's own shell gets it
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25.0.4.1 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# GRAALVM_HOME names a GraalVM JDK 25 (README.md, "The GraalVM"): the native build reads it. Without it, this script makes every
# capture that needs no GraalVM, filling .m2-demo on the way, then stops before the native build.
# Course 6 · Jackson in Spring - this unit's receipts. The anchor changes: application.yaml's first document gains one key,
# spring.jackson.deserialization.accept-float-as-int: false, so a number with a decimal point sent for a whole-number field - two
# point seven meals a day - is refused (Spring MVC's 400) where it was stored as 2. Ten captures, each run three times and hashed;
# cap() DIES when a hash differs from receipts.md5; every number the video says is asserted at the bottom by a check that can fail;
# the demo token is masked (gsub), and the checks count 0 raw copies of it in every capture, in the log of every run - the
# container's included - in every file this unit ships, in the binary and in the image's layers.
#   float      the previous tree against after/: the files that differ, the YAML's lines, where the key sits (its line against the
#              first "---"; a planted copy below it caught); then A/B/A': two point seven meals POSTed to the previous tree (stored as
#              2), to after/ (A: refused, 400), with the key turned back on by a flag (B: stored as 2), to a copy whose key sits below the
#              "---" (C, labelled: stored as 2), and A again on a fresh JVM -
#              A also POSTs what the key refuses with it and what it leaves alone (2.0, a price of 110.5, "2", an unknown property, a
#              missing int, a misspelt key)
#   bean       Boot's mapper read off the running application (the harness's Mapper): its bean, the converter's mapper, Actuator's
#              own, the modules, the naming, and every feature of eight kinds against a plain JsonMapper - on the previous tree, then
#              on after/
#   order      the order Jackson writes properties in: a record of the harness's, a class with the same fields, a map, TiffinBox's
#              own record (the harness's Order)
#   defaults   A/B/A': Boot's defaults for Jackson 2, by flag (spring.jackson.use-jackson2-defaults) - every feature that flips,
#              what a missing int and trailing text get, the class's order, the error's timestamp; the seven under the flag
#   naming     A/B/C/A': the seven, then the seven with SNAKE_CASE (the lines that change), the naming read off Boot's mapper and
#              Actuator's, an explicit @JsonProperty name; C (labelled) a constant Jackson does not have - the start fails
#   rename     a record of the harness's own with @JsonProperty("meals") on one component: written, read, and its Java name sent
#   custom     A/B/A': a JsonMapperBuilderCustomizer bean of the harness's (Strict) that refuses unknown properties - Boot's mapper
#              and Actuator's, an unknown property and a misspelt key, without it and with it
#   three      the correction comment's three differences, on Spring's mapper: an unknown property; java.time with no module (the
#              harness's Dates); Core Java II's configure line compiled against Jackson 3, and Jackson 3's builder
#   exercise   exercise/README.md's commands, then exercise/solution/SOLUTION.md's, read from the files and run as written, one after
#              the other in ONE shell a viewer could have: env -i, /bin/bash, started in this folder
#   forms      the native build of after/ and what Spring's AOT step registered, then four forms - the jar, the AOT jar, the binary,
#              the image: each one's address, the seven (masked), exit 0; then, on a second start of each, a new customer and two
#              point seven meals; on a third start of the AOT jar and the binary, the key turned back on by a flag
# "The previous tree" is ../c6-unit08/after (the anchor before this change: the request-body lesson's frozen tree), COPIED under
# .harness/before; after/ is this unit's frozen copy of ../c6-tiffinbox after the change, COPIED under .harness/after. This script
# never writes into another unit's folder, and never builds a frozen tree in place. Every run of TiffinBox starts in a folder under
# .harness/ that holds a config tree with a fake token (secrets/), as the README asks - the container's too, mounted read-only.
# Commands are printed exactly as they run: each goes through eval. "$CURLSET" is the comparison set since the secrets lesson
# (../c5-unit11/curlset.sh: the seven requests, POST /shutdown with the token's header read from the file). "$M2" is this unit's
# own repository, .m2-demo. The harness - harness/probe/json/Mapper.java, Order.java, Rename.java, Strict.java and Dates.java
# (compiled with -parameters), the course's, never TiffinBox's: outside com.tiffinbox, joined by --spring.main.sources on the
# extracted jar's class path; harness/three/Configure2.java and Configure3.java (compiled on their own, in three); harness/shutdown.sh
# (POST /shutdown, the token read from its file) - is named on every capture that uses it. Every run passes options only. The seven
# always run on a fresh JVM, before any POST: a POST stores a customer, and three of the seven list customers.
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
# string, epoch milliseconds) in the seven and wherever Spring's error body is printed - and where a capture names the timestamp's
# form, every digit of it becomes d; an identity hash after "@" becomes "…"; H2's constraint and index names, in the quoted string
# after "violation: ", become "…"; where a native-image warning names the file it read an option from, the file's URL - or "null",
# which it prints when the path holds a space - becomes "…". A run's log lines are printed from their logger on (no time, no process
# id); Boot's first line is cut before " with PID". Long logs and answers go through a declared filter, and what it cuts is counted or
# bounded. No image, container or ID is printed but the base image's digest. No duration is captured: the native build is judged
# against a bound; seconds go to the terminal.
# Ports (brief ⚑1, 19380-19389): after/'s jar 19380 · the previous tree 19381 · after/ with the harness joined 19382 · the AOT jar
# 19384 · the image 19387 · the binary 19388 · the exercise 19389 (19383, 19385 and 19386 are never bound). 18425 (TiffinBox's
# default) and 8080 (Tomcat's) are checked free too, and never bound on this machine (18425 only inside a container).
# Docker names (no unit number): the image tiffinbox-json:1.0.0 and the container tiffinbox-json. Each is checked absent before the
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
IMG=tiffinbox-json:1.0.0; BOX=tiffinbox-json
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
for t in python3 curl rsync lsof unzip javac docker openssl; do command -v $t > /dev/null || die "$t is needed"; done
# A variable of yours must not become a property source, a JVM flag, a build setting, a native-image option or a docker build
# setting: every TIFFINBOX_*, SPRING_*, MANAGEMENT_*, SERVER_*, LOGGING_*, COMPOSE_*, BUILDKIT_* and BUILDX_* variable, DEBUG (Boot
# reads it as --debug), the variables that inject JVM flags, MAVEN_OPTS, MAVEN_ARGS, NATIVE_IMAGE_OPTIONS, DOCKER_BUILDKIT,
# DOCKER_DEFAULT_PLATFORM and SOURCE_DATE_EPOCH are removed first. GRAALVM_HOME stays: it says which GraalVM to use; so do
# DOCKER_HOST and DOCKER_CONTEXT: they say which Docker answers. (SPRING_JACKSON_DESERIALIZATION_ACCEPT_FLOAT_AS_INT of yours would
# beat this tree's key; SERVER_ADDRESS or SERVER_PORT its alias; TIFFINBOX_SHUTDOWN_TOKEN the config tree.)
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
PREV=../c6-unit08/after                              # the previous tree: the anchor before this change - read, copied
[ -e secrets ] && die "this folder holds a secrets/ - remove it: every run here starts in a folder under .harness/"
for t in "$PREV" after; do
  [ -f "$t/pom.xml" ] && [ -f "$t/README.md" ] && [ -f "$t/Dockerfile" ] && [ -f "$t/.dockerignore" ] || die "the tree $t (its pom.xml, README.md, Dockerfile or .dockerignore) is missing"
  [ -e "$t/secrets" ] || [ -e "$t/target" ] || [ -e "$t/tiffinbox-web/target" ] && die "$t holds a secrets/ or a target/ - it is a frozen copy, never built in place"
  grep -qx 'secrets/' "$t/.dockerignore" || die "$t's .dockerignore no longer keeps secrets/ out of a build context"; done
M2="$PWD/.m2-demo"; U="$PWD"; UP="$(cd .. && pwd)"; ME="$(id -un)"
YAML=tiffinbox-web/src/main/resources/application.yaml
JARP=tiffinbox-web/target/tiffinbox-web-1.0.0.jar    # the executable jar, in a tree's web module
BIN=tiffinbox-web/target/tiffinbox-web               # the binary native:compile-no-fork writes, in a tree's web module
TF=secrets/tiffinbox/shutdown-token                  # the config tree's file for tiffinbox.shutdown-token
# The demo token. FAKE, and meant to look it: it guards nothing but a demo server on 127.0.0.1 that every capture stops. It is
# written into .harness/*/secrets/ (git-ignored) when this script runs, and no capture prints it: see mask().
TOKEN=not-a-real-token-demo-only
[ ${#TOKEN} = 26 ] || die "the demo token must be 26 characters: the published captures name its length"
CURLSET=../c5-unit11/curlset.sh                      # the comparison set: the seven requests, POST /shutdown with the header
[ -f "$CURLSET" ] || die "$CURLSET is missing"
HJ="harness/probe/json/Mapper.java harness/probe/json/Order.java harness/probe/json/Rename.java harness/probe/json/Strict.java harness/probe/json/Dates.java"
for f in harness/shutdown.sh $HJ harness/three/Configure2.java harness/three/Configure3.java exercise/README.md exercise/solution/SOLUTION.md README.md; do [ -f "$f" ] || die "$f is missing"; done
[ "$(ls harness/probe/json | paste -sd' ' -)" = 'Dates.java Mapper.java Order.java Rename.java Strict.java' ] || die "harness/probe/json holds another file: javac compiles all of it"

# The ports and the Docker names, BEFORE anything is wiped (a survivor of an interrupted run answers POST /shutdown only with its
# token, which lives in .harness/ - so the message names the process to kill).
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
for p in 18425 8080 19380 19381 19382 19383 19384 19385 19386 19387 19388 19389; do
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
# the request-body lesson's line: one new customer, its JSON body and its Content-Type on the command line - and this unit's line in
# the anchor's README: the same POST with two point seven meals a day
R_ADD=$(readme "curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '{\"name\":\"Asha\",\"mealsPerDay\":2,\"pricePerMeal\":110,\"mealType\":\"VEG\"}' http://127.0.0.1:18431/customers")
R_FLOAT=$(readme "curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '{\"name\":\"Mohan\",\"mealsPerDay\":2.7,\"pricePerMeal\":110,\"mealType\":\"VEG\"}' http://127.0.0.1:18431/customers")
# This unit's own lines (README.md, "The commands this unit adds") - each asserted to be exactly that: the run line with the key
# turned back on (float B); with Boot's defaults for Jackson 2 (defaults B); with a naming strategy - Jackson's constant (naming B),
# and the same word in lower case (naming C, and the exercise)
mine() { grep -m1 -xF -- "$1" README.md > /dev/null || die "README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
L_FLOATB=$(mine "$J --spring.jackson.deserialization.accept-float-as-int=true")
L_J2=$(mine "$J --spring.jackson.use-jackson2-defaults=true")
L_SNAKE=$(mine "$J --spring.jackson.property-naming-strategy=SNAKE_CASE")
L_SNAKEC=$(mine "$J --spring.jackson.property-naming-strategy=snake_case")
O_FLOATB=${L_FLOATB#"$J "}; O_J2=${L_J2#"$J "}; O_SNAKE=${L_SNAKE#"$J "}; O_SNAKEC=${L_SNAKEC#"$J "}
[ "$O_FLOATB" = '--spring.jackson.deserialization.accept-float-as-int=true' ] && [ "$O_J2" = '--spring.jackson.use-jackson2-defaults=true' ] && [ "$O_SNAKE" = '--spring.jackson.property-naming-strategy=SNAKE_CASE' ] && [ "$O_SNAKEC" = '--spring.jackson.property-naming-strategy=snake_case' ] || die "the README's options"
# C is B with one word changed - the constant's case - and nothing else
r=${L_SNAKE/=SNAKE_CASE/=snake_case}; [ "$r" = "$L_SNAKEC" ] || die "naming: C must be B with the constant in lower case, and nothing else"
# ADATA: the request-body lesson's JSON body; PREF: its curl and options, before the body. pc() builds the same line for another port,
# path and body - and must give the README's two lines back
ADATA=${R_ADD#* --data \'}; ADATA=${ADATA%%\' http://*}
PREF=${R_ADD% --data *}
MOHAN=${R_FLOAT#* --data \'}; MOHAN=${MOHAN%%\' http://*}
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
# qurl PORT PATH: the URL; one that holds a character the shell reads (; ? & * { }) is single-quoted, so eval hands it to curl whole
qurl() { local u="http://127.0.0.1:$1$2"; case $2 in *[\;\?\&\*\{\}]*) u="'$u'" ;; esac; printf '%s\n' "$u"; }
# bc PORT PATH ['CURL OPTIONS']: the binding lesson's one-customer line (the anchor's README) - the body and the status - the same way
bc() { local c=${R_ONE% http://*}; printf '%s%s %s\n' "$c" "${3:+ $3}" "$(qurl "$1" "$2")"; }
# pc PORT PATH 'BODY': the request-body lesson's line in the anchor's README - a POST, its Content-Type application/json - its port,
# its path and its JSON body swapped; the body single-quoted, as the README writes it
pc() { printf "%s --data '%s' %s\n" "$PREF" "$3" "$(qurl "$1" "$2")"; }
# exe 'COMMAND': the command with "exec" after its "cd DIR && " and any NAME=value before the program - so $pid is the program's
exe() { printf '%s\n' "$1" | sed -E 's/&& (([A-Z_]+=[^ ]* )*)/\&\& \1exec /'; }
# The docker lines, as this script runs them: the README's build line with plain progress and this script's own tag; its run line
# with this script's own name and tag, the port published on 127.0.0.1 made PORT, and your user and group added - the config tree
# is yours, mode 0600 (R.74). undock() takes those changes back out, and must give the README's lines again.
UARG='--user "$(id -u):$(id -g)"'
dbuild() { local c=${R_DBUILD/docker build -t tiffinbox-docker:1.0.0 /docker build --progress=plain -t $IMG }; printf 'cd %s && %s\n' "$1" "$c"; }
drun() { local c=${R_DRUN/--name tiffinbox /--name $BOX $UARG }; c=${c/127.0.0.1:18431:18425/127.0.0.1:$2:18425}; c=${c/% tiffinbox-docker:1.0.0/ $IMG}; printf 'cd %s && %s\n' "$1" "$c"; }
undock() { local c=${1#cd * && }; c=${c/--progress=plain /}; c=${c/" $UARG"/}; c=${c//$IMG/tiffinbox-docker:1.0.0}; c=${c/--name $BOX /--name tiffinbox }; c=${c/127.0.0.1:1938?:18425/127.0.0.1:18431:18425}; printf '%s\n' "$c"; }
[ "$(undock "$(dbuild .harness/x)")" = "$R_DBUILD" ] || die "not the README's build line with the declared changes: $(dbuild .harness/x)"
[ "$(undock "$(drun .harness/x 19387)")" = "$R_DRUN" ] || die "not the README's run line with the declared changes: $(drun .harness/x 19387)"
C_PRE=$(off .harness/pre "$R_INSTALL" install)
for c in "$C_PRE" "$(off .harness/x "$R_PLAIN" package)" "$(off .harness/x "$R_PNAT" package)" "$(off .harness/x "$R_NATIVE")"; do
  r=$(dev "$c"); [ "$r" = "$R_PLAIN" ] || [ "$r" = "$R_PNAT" ] || [ "$r" = "$R_INSTALL" ] || [ "$r" = "$R_NATIVE" ] || die "not a README line with the offline changes: $c"; done
[ "$(exe "$(at .harness/x 19380 "$R_RUN")")" = 'cd .harness/x && exec java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19380' ] || die "exe()"
[ "$(hcp .harness/x 19382 probe.json.Mapper "$O_J2")" = 'cd .harness/x && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19382 --spring.main.sources=probe.json.Mapper --spring.jackson.use-jackson2-defaults=true' ] || die "hcp()"
[ "$(bc 19380 /customers/Mohan)" = "curl -s -w ' %{http_code}\n' http://127.0.0.1:19380/customers/Mohan" ] || die "bc()"
[ "$(pc 18431 /customers "$ADATA")" = "$R_ADD" ] && [ "$(pc 18431 /customers "$MOHAN")" = "$R_FLOAT" ] && [ "$ADATA" = '{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' ] && [ "$MOHAN" = '{"name":"Mohan","mealsPerDay":2.7,"pricePerMeal":110,"mealType":"VEG"}' ] || die "pc(): not the anchor's POST lines"
r=${MOHAN/'"Mohan","mealsPerDay":2.7'/'"Asha","mealsPerDay":2'}; [ "$r" = "$ADATA" ] || die "the two point seven body must be the request-body lesson's with its name and meals changed, and nothing else"
echo "  the commands: after/README.md gives all 16 lines this script runs or derives from; README.md the 4 this unit adds"

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
javac -parameters -d .harness/hc -cp ".harness/pre/tiffinbox-web/target/extracted/lib/*" $HJ > .harness/javac.log 2>&1 || { cat .harness/javac.log >&3; die "the harness did not compile against after/'s jar"; }
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
# logtok: the demo token 0 times in the last run's log, and the header's name 0 times
logtok() { local t h; t=$(raw "$TOKEN" .harness/run.out .harness/run.err); h=$(cat .harness/run.out .harness/run.err | LC_ALL=C grep -aoi -- 'x-shutdown-token' | wc -l | tr -d ' ')
  LOGS=$((LOGS + 1)); [ "$t" = 0 ] && [ "$h" = 0 ] || die "a log held the demo token ($t) or its header's name ($h)"
  echo "  its log: the demo token 0 times · X-Shutdown-Token $h times"; }
# tsmask: Spring's error timestamp, both forms (an ISO-8601 string, epoch milliseconds), becomes "…" (README.md, Masks)
tsmask() { awk '{ gsub(/"timestamp":"[^"]*"/, "\"timestamp\":\"…\""); gsub(/"timestamp":[0-9]+/, "\"timestamp\":…"); print }'; }
# tsform FILE...: the error timestamps in the files - unmasked answers - each made a form: every digit becomes d (README.md, Masks);
# each distinct form, and how many times it appears
tsform() { cat "$@" | grep -o '"timestamp":"[^"]*"' | sed 's/[0-9]/d/g' | sort | uniq -c | awk '{ c = $1; $1 = ""; sub(/^ /, ""); printf "%s%s ×%d", (NR > 1 ? " · " : ""), $0, c } END { if (NR == 0) printf "none" }'; }
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
# post PORT DIR: POST /shutdown with DIR's token (harness/shutdown.sh) - its answer, the timestamp masked
post() { echo "\$ harness/shutdown.sh $1 $2/$TF"; harness/shutdown.sh "$1" "$2/$TF" | tsmask | sed 's/^/  /'; }
# stop PORT DIR: POST /shutdown with DIR's token; the JVM must leave, the port must be free; its log counted (logtok)
stop() { post "$1" "$2"; gone "$1"; echo "  exit $LASTE · listening on $1 now: 0"; logtok; }
now() { local p o=""; for p in "$@"; do o="$o${o:+ · }$p $(listeners "$p")"; done; echo "  listening now: $o"; }
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
code() { grep -vE '^[[:space:]]*(#|$)' "$1"; }
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
# ask PORT PATH ['CURL OPTIONS']: the one-customer line (body and status), its path PATH, printed and run, the answer's timestamp
# masked; then the WARN lines the request added (wans)
ask() { local c n0; n0=$(mark); c=$(bc "$@"); echo "\$ $c"; (eval "$c") 2>&1 < /dev/null | tsmask > .harness/ask.txt; wans "$n0" .harness/ask.txt; }
# pj PORT 'BODY' [PATH]: the request-body lesson's POST line (pc) to PATH (/customers) with that JSON body, printed and run, the
# answer's timestamp masked (the unmasked answer kept in .harness/ask.raw, for tsform); then the WARN lines its request added (wans)
pj() { local c n0; n0=$(mark); c=$(pc "$1" "${3:-/customers}" "$2"); echo "\$ $c"; (eval "$c") 2>&1 < /dev/null > .harness/ask.raw; tsmask < .harness/ask.raw > .harness/ask.txt; wans "$n0" .harness/ask.txt; }
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
# rq PORT PATH: the one-customer line for PATH, printed and run, each line of its answer indented - the timestamp masked
rq() { local c; c=$(bc "$@"); echo "\$ $c"; (eval "$c") 2>&1 < /dev/null | tsmask | sed 's/^/  /'; }
# rp 'COMMAND': a curl line, printed and run, the answer indented, the timestamp masked
rp() { echo "\$ $1"; (eval "$1") 2>&1 < /dev/null | tsmask | sed 's/^/  /'; }
# rqf PORT PATH 'ERE': the one-customer line for PATH, printed and run - only the answer's lines that match ERE printed (a declared
# filter), then how many it cut
rqf() { local c n k; c=$(bc "$1" "$2"); echo "\$ $c"; (eval "$c") 2>&1 < /dev/null > .harness/ask.txt; n=$(grep -c . .harness/ask.txt || true)
  grep -E -- "$3" .harness/ask.txt | sed 's/^/  /' || true; k=$(grep -cE -- "$3" .harness/ask.txt || true)
  echo "  (the filter: lines that match /$3/ - $k of the answer's $n lines shown, the other $((n - k)) not)"; }
# blkraw FROM TO: this capture so far, the lines after the line that starts with FROM, up to the next line that starts with TO (to
# the end when TO is empty); asame A B A2: yes when A's block (A up to B) and A2's (A2 to the end), their labels aside, are the same
# line for line - an A' against its A
blkraw() { awk -v a="$1" -v b="$2" 'index($0, a) == 1 { f = 1; next } b != "" && index($0, b) == 1 { f = 0 } f' .harness/cap.raw; }
asame() { [ "$(blkraw "$1" "$2")" = "$(blkraw "$3" '')" ] && [ -n "$(blkraw "$3" '')" ] && echo yes || echo no; }
# plant FILE LINE N: FILE with the key's three lines (jackson:, deserialization:, accept-float-as-int:) taken out of their place and
# put back after the Nth line that is exactly LINE - a planted fault for kplace
plant() { awk -v w="$2" -v nth="$3" 'NR == FNR { if ($0 == "  jackson:") j = FNR; if (j && FNR <= j + 2) h = h $0 "\n"; next }
  j && FNR >= j && FNR <= j + 2 { next } { print } $0 == w && ++c == nth { printf "%s", h }' "$1" "$1"; }

# bmeta KEY...: Boot's own metadata for each key - its type, its default and its description - read from spring-boot-jackson-4.1.1.jar
# (the jar whose metadata declares the spring.jackson keys) in after/'s extracted lib
BJ=.harness/after/tiffinbox-web/target/extracted/lib/spring-boot-jackson-4.1.1.jar
bmeta() { python3 - "$BJ" "$@" <<'PY'
import json, sys, zipfile
d = json.loads(zipfile.ZipFile(sys.argv[1]).read("META-INF/spring-configuration-metadata.json"))
p = {x["name"]: x for x in d.get("properties", [])}
for k in sys.argv[2:]:
    e = p.get(k)
    if not e:
        print("  Boot's metadata (spring-boot-jackson-4.1.1.jar): %s - in none of its entries" % k); continue
    dv = e.get("defaultValue")
    print("  Boot's metadata (spring-boot-jackson-4.1.1.jar) - %s · its type: %s · its default: %s · its description: %s" % (k, e.get("type", "none"), "none" if dv is None else json.dumps(dv), e.get("description", "none")))
PY
}

# ---- float: the previous tree against after/; A/B/A' - two point seven meals a day --------------------------------------------
# kplace FILE: where the key sits in an application.yaml - the top-level key its block is under, its three lines' numbers, and the
# first "---"'s; "in the first document" is yes only when the three lines follow each other under spring:, above that "---"
kplace() { awk '
  /^[a-z][a-z-]*:/ && !j { top = $0; topn = NR }
  /^  jackson:$/ && !j { j = NR; under = top; un = topn }
  /^    deserialization:$/ && j && !d { d = NR }
  /^      accept-float-as-int: false$/ && d && !k { k = NR }
  /^---$/ && !x { x = NR }
  END { ok = (j && d == j + 1 && k == d + 1 && x && k < x && under == "spring:") ? "yes" : "no"
        printf "jackson: line %d, under %s (line %d) · deserialization: line %d · accept-float-as-int: false line %d · the first \"---\" line %d · in the first document: %s\n", j, under, un, d, k, x, ok }' "$1"; }
# ka PORT DIR: two point seven meals POSTed (the anchor's line), then read back - each answer, the WARN lines it added
ka() { pj "$1" "$MOHAN"; ask "$1" /customers/Mohan; }
float() { local c n m
  echo "the previous tree and after/, both copied under .harness/ with a config tree, each built with the README's line (offline):"
  copy "$PREV" .harness/before; copy after .harness/after
  pbuild .harness/before "the previous tree"; pbuild .harness/after "after/"
  echo "both jars extracted (the README's line) - the class path the harness runs on:"
  extract .harness/before; extract .harness/after
  echo "the harness, compiled against after/'s own jar - with -parameters:"
  c="javac -parameters -d .harness/hc -cp \".harness/after/tiffinbox-web/target/extracted/lib/*\" $HJ"
  echo "\$ $c"; rm -rf .harness/hc; (eval "$c") > .harness/javac.log 2>&1 < /dev/null || { cat .harness/javac.log >&3; die "the harness did not compile against after/'s jar"; }
  echo "  exit 0"
  echo "the files that differ:"
  echo "\$ diff -rq -x target -x secrets .harness/before .harness/after"
  diff -rq -x target -x secrets .harness/before .harness/after | sed 's/^/  /' || true
  (cd after && find . -type f | sed 's#^\./##' | sort) > .harness/files.txt
  n=0; m=0; while IFS= read -r f; do m=$((m + 1)); cmp -s ".harness/before/$f" ".harness/after/$f" && n=$((n + 1)); done < .harness/files.txt
  echo "  after/'s files: $m · byte for byte the previous tree's: $n · those above differ: $((m - n))"
  code ".harness/before/$YAML" > .harness/yb.txt; code ".harness/after/$YAML" > .harness/ya.txt
  diff -U1 .harness/yb.txt .harness/ya.txt | tail -n +3 > .harness/yaml.diff || true
  echo "  application.yaml - its lines that are neither comment nor blank: $(wc -l < .harness/yb.txt | tr -d ' ') -> $(wc -l < .harness/ya.txt | tr -d ' ') · their diff (diff -U1, its file names cut) - hunks: $(grep -c '^@@ ' .harness/yaml.diff || true) · lines out: $(grep -c '^-' .harness/yaml.diff || true) · in: $(grep -c '^+' .harness/yaml.diff || true) - whole:"
  sed 's/^/    /' .harness/yaml.diff
  echo "  its comment lines: $(grep -cE '^[[:space:]]*#' ".harness/before/$YAML") -> $(grep -cE '^[[:space:]]*#' ".harness/after/$YAML") · those right above the key: $(awk '/^  jackson:$/ { print n; exit } /^[[:space:]]*#/ { n++; next } { n = 0 }' ".harness/after/$YAML") (not shown)"
  diff .harness/before/README.md .harness/after/README.md > .harness/file.diff || true
  echo "  README.md - the anchor's README: lines added $(grep -c '^> ' .harness/file.diff || true), removed $(grep -c '^< ' .harness/file.diff || true) - its new section and the history notes the change made false (not shown)"
  echo "where the key sits - after/'s application.yaml:"
  echo "  $(kplace ".harness/after/$YAML")"
  # the check, shown failing: a copy whose three lines sit under the second document's spring: - the profile "rush"'s alone
  plant ".harness/after/$YAML" spring: 2 > .harness/planted.yaml
  echo "  a planted copy, the three lines moved under the second document's spring: (the profile rush's): $(kplace .harness/planted.yaml)"; rm -f .harness/planted.yaml
  bmeta spring.jackson.deserialization
  libs .harness/before/$JARP > .harness/lb.txt; libs .harness/after/$JARP > .harness/la.txt
  echo "the executable jar's BOOT-INF/lib: $(wc -l < .harness/lb.txt | tr -d ' ') jars -> $(wc -l < .harness/la.txt | tr -d ' ') · the same names: $(cmp -s .harness/lb.txt .harness/la.txt && echo yes || echo no)"
  echo "before - the previous tree, the README's run line, port 19381 - two point seven meals a day (this unit's line in the anchor's README):"
  start "$(at .harness/before 19381 "$R_RUN")"; up 19381; ready 19381; ka 19381; stop 19381 .harness/before
  echo "A - after/, the README's run line, port 19380:"
  floata
  echo "B - this unit's line: the README's run line with --spring.jackson.deserialization.accept-float-as-int=true, port 19380:"
  start "$(at .harness/after 19380 "$L_FLOATB")"; up 19380; ready 19380; ka 19380; stop 19380 .harness/after
  echo "C (labelled) - a copy of after/ with the key's three lines under the second document's spring: (the planted copy above: the profile rush's), built the same way, the README's run line, port 19380:"
  copy after .harness/plant; plant ".harness/after/$YAML" spring: 2 > ".harness/plant/$YAML"
  echo "  its application.yaml: $(kplace ".harness/plant/$YAML")"
  pbuild .harness/plant "the planted copy"
  start "$(at .harness/plant 19380 "$R_RUN")"; up 19380; ready 19380; ka 19380; stop 19380 .harness/plant
  echo "A' - A again, on a fresh JVM:"
  floata
  echo "A' against A, its label aside, line for line the same: $(asame 'A - after/' 'B - this unit' "A' - A again")"; }
floata() { start "$(at .harness/after 19380 "$R_RUN")"; up 19380; ready 19380; ka 19380
  echo "  what the key refuses with it, and what it leaves alone - one POST each, a name of its own:"
  pj 19380 '{"name":"Nisha","mealsPerDay":2.0,"pricePerMeal":110,"mealType":"VEG"}'
  pj 19380 '{"name":"Raj","mealsPerDay":2,"pricePerMeal":110.5,"mealType":"VEG"}'
  pj 19380 '{"name":"Om","mealsPerDay":"2","pricePerMeal":110,"mealType":"VEG"}'
  pj 19380 '{"name":"Kiran","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG","loyaltyPoints":5}'
  pj 19380 '{"name":"Tara","pricePerMeal":110,"mealType":"VEG"}'
  p5 19380 '{"name":"Rohan","mealsPerDay":1,"pricePerMeal":110,"mealTyp":"VEG"}'
  echo "  WARN lines in this run's log, at Boot's default level: $(logl 0 WARN | grep -c . || true) · ERROR lines: $(logl 0 ERROR | grep -c . || true)"
  stop 19380 .harness/after; }

# ---- bean: Boot's mapper, read off the running application -------------------------------------------------------------------
bean() {
  echo "before - the previous tree (its application.yaml names no spring.jackson key: Boot's defaults), the README's class-path line with the harness's Mapper joined, port 19381:"
  start "$(hcp .harness/before 19381 probe.json.Mapper)"; up 19381; ready 19381; rq 19381 /probe/mapper; stop 19381 .harness/before
  echo "after - after/, this lesson's key in its application.yaml, the same line, port 19382:"
  start "$(hcp .harness/after 19382 probe.json.Mapper)"; up 19382; ready 19382; rq 19382 /probe/mapper; stop 19382 .harness/after; }

# ---- order: the order Jackson writes properties in ----------------------------------------------------------------------------
order() { local p
  echo "after/ with the harness's Order joined, port 19382 - a record of the harness's own, a class with the same three fields, a map they are put in that order, then TiffinBox's own record:"
  start "$(hcp .harness/after 19382 probe.json.Order)"; up 19382; ready 19382
  for p in /probe/order/record /probe/order/class /probe/order/map /probe/order/customer /customers/Ravi; do rq 19382 "$p"; done
  stop 19382 .harness/after; }

# ---- defaults: A/B/A' - Boot's defaults for Jackson 2, by flag ---------------------------------------------------------------------
# feats PORT FILE: every feature of Boot's mapper, as the harness's Mapper lists them (/probe/mapper/all), saved in FILE - the
# command printed, the list not: its count and its status
feats() { local c; c=$(bc "$1" /probe/mapper/all); echo "\$ $c"; (eval "$c") 2>&1 < /dev/null > .harness/all.txt
  sed '$d' .harness/all.txt > "$2"
  echo "  saved, not shown: $(grep -c . "$2" || true) features, each one's name and value · its status:$(tail -1 .harness/all.txt)"; }
# fdiff A B: the features whose value differs between two saved lists - their count, then each, A's value -> B's
fdiff() { awk 'NR == FNR { a[$1] = $2; next } ($1 in a) && a[$1] != $2 { d[++n] = "    " $1 ": " a[$1] " -> " $2 } END { print "  features whose value differs from A'"'"'s: " (n + 0) " of " FNR; for (i = 1; i <= n; i++) print d[i] }' "$1" "$2"; }
DMISS='{"name":"Tara","pricePerMeal":110,"mealType":"VEG"}'
DTRAIL='{"name":"Lata","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} extra'
defaults() {
  bmeta spring.jackson.use-jackson2-defaults
  echo "A - after/ with the harness's Mapper and Order joined, port 19382 - Boot's mapper as this lesson leaves it:"
  defa .harness/fa.txt
  echo "B - the same, with this unit's flag on the harness's class-path line: --spring.jackson.use-jackson2-defaults=true, port 19382:"
  start "$(hcp .harness/after 19382 probe.json.Mapper,probe.json.Order "$O_J2")"; up 19382; ready 19382
  feats 19382 .harness/fb.txt; fdiff .harness/fa.txt .harness/fb.txt
  rq 19382 /probe/order/class
  pj 19382 "$DMISS"; ask 19382 /customers/Tara
  pj 19382 "$DTRAIL"
  pj 19382 "$MOHAN"; echo "  that answer's timestamp, its form: $(tsform .harness/ask.raw)"
  stop 19382 .harness/after
  echo "  then the seven, on a fresh JVM - this unit's line (the README's run line with the flag), port 19380:"
  start "$(at .harness/after 19380 "$L_J2")"; up 19380; ready 19380; seven 19380 .harness/after
  echo "A' - A again, on a fresh JVM:"
  defa .harness/fa2.txt
  echo "A' against A, its label aside, line for line the same: $(asame 'A - after/' 'B - the same' "A' - A again") · its features against A's: $(fdiff .harness/fa.txt .harness/fa2.txt | head -1 | sed 's/^  features whose value differs from A.s: //') differ"; }
defa() { start "$(hcp .harness/after 19382 probe.json.Mapper,probe.json.Order)"; up 19382; ready 19382
  feats 19382 "$1"
  rq 19382 /probe/order/class
  pj 19382 "$DMISS"; echo "  that answer's timestamp, its form: $(tsform .harness/ask.raw)"
  pj 19382 "$DTRAIL"
  stop 19382 .harness/after; }

# ---- naming: A/B/C/A' - a naming strategy -------------------------------------------------------------------------------------
# fails 'COMMAND': a start expected to end by itself, printed as typed and run (eval; exec, so $fpid is the program's own), bounded
# (120 s); its exit code; then its log, read after it exited: Boot's failure analysis (APPLICATION FAILED TO START) counted, its
# stack frames bounded, its Caused by lines counted and the last one printed whole, its WARN and ERROR lines (logger: message, a
# WARN's cut after the exception's name); the token in its log, raw - 0
fails() { local e=0 i=0 t
  echo "\$ $1"; (eval "$(exe "$1")") > .harness/fail.out 2> .harness/fail.err < /dev/null & fpid=$!
  while kill -0 "$fpid" 2> /dev/null && [ $i -lt 480 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$fpid" 2> /dev/null && { kill "$fpid"; die "a start expected to end still ran after 120 s: $1"; }
  wait "$fpid" || e=$?; fpid=""; LASTE=$e
  t=$(raw "$TOKEN" .harness/fail.out .harness/fail.err); FLOGS=$((FLOGS + 1)); [ "$t" = 0 ] || die "a failed start's log held the demo token ($t)"
  echo "  exit $e · its log, read after it exited - Boot's failure analysis (APPLICATION FAILED TO START): $(grep -c '^APPLICATION FAILED TO START$' .harness/fail.out || true) · stack frames: $( n=$(grep -c "^$(printf '\t')at " .harness/fail.out || true); [ "$n" -gt 100 ] && echo 'over 100' || echo "$n"), not shown · Caused by lines: $(grep -c '^Caused by: ' .harness/fail.out || true)"
  awk '/ (WARN|ERROR) [0-9]+ --- \[/ { s = $0; i = index(s, " --- ["); s = substr(s, i + 6); i = index(s, "] "); s = substr(s, i + 2)
    i = index(s, " : "); lg = substr(s, 1, i - 1); sub(/ +$/, "", lg); m = substr(s, i + 3); if (match(m, /attempt: [A-Za-z0-9_.$]+/)) m = substr(m, 1, RSTART + RLENGTH - 1) " …"
    print "    " $2 " " lg ": " m }' .harness/fail.out
  echo "  the last Caused by line: $(grep '^Caused by: ' .harness/fail.out | tail -1)"
  echo "  its standard error: $(wc -l < .harness/fail.err | tr -d ' ') lines · the demo token in its log: 0"; }
naming() {
  bmeta spring.jackson.property-naming-strategy
  echo "A - after/, the README's run line, port 19380 - the seven:"
  start "$(at .harness/after 19380 "$R_RUN")"; up 19380; ready 19380; seven 19380 .harness/after; cp .harness/responses.m.txt .harness/sevenA.txt
  echo "B - this unit's line: the README's run line with --spring.jackson.property-naming-strategy=SNAKE_CASE, port 19380 - the seven:"
  start "$(at .harness/after 19380 "$L_SNAKE")"; up 19380; ready 19380; seven 19380 .harness/after
  diff .harness/sevenA.txt .harness/responses.m.txt > .harness/seven.diff || true
  echo "  the lines that differ from A's seven: $(grep -c '^< ' .harness/seven.diff || true) - $(grep -E '^[0-9]' .harness/seven.diff | paste -sd' ' -):"
  grep -E '^[<>] ' .harness/seven.diff | sed 's/^/    /'
  echo "  then the same flag on the harness's class-path line, Mapper and Rename joined, port 19382:"
  start "$(hcp .harness/after 19382 probe.json.Mapper,probe.json.Rename "$O_SNAKE")"; up 19382; ready 19382
  rqf 19382 /probe/mapper '^property naming|differ in'
  rq 19382 /probe/rename
  stop 19382 .harness/after
  echo "C (labelled) - this unit's line with the constant in lower case: --spring.jackson.property-naming-strategy=snake_case, port 19380:"
  fails "$(at .harness/after 19380 "$L_SNAKEC")"; now 19380
  echo "A' - A again, on a fresh JVM:"
  start "$(at .harness/after 19380 "$R_RUN")"; up 19380; ready 19380; seven 19380 .harness/after
  echo "A' against A, its label aside, line for line the same: $(asame 'A - after/' 'B - this unit' "A' - A again")"; }

# ---- rename: @JsonProperty on a record component ------------------------------------------------------------------------------
rename() {
  echo "after/ with the harness's Rename joined - a record of its own, Meals(String name, @JsonProperty(\"meals\") int mealsPerDay) - port 19382:"
  start "$(hcp .harness/after 19382 probe.json.Rename)"; up 19382; ready 19382
  rq 19382 /probe/rename
  pj 19382 '{"name":"Ravi","meals":3}' /probe/rename
  pj 19382 '{"name":"Ravi","mealsPerDay":3}' /probe/rename
  stop 19382 .harness/after; }

# ---- custom: A/B/A' - a JsonMapperBuilderCustomizer bean ------------------------------------------------------------------------
CKIRAN='{"name":"Kiran","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG","loyaltyPoints":5}'
CROHAN='{"name":"Rohan","mealsPerDay":1,"pricePerMeal":110,"mealTyp":"VEG"}'
MAPF='^features read|^  DeserializationFeature\.FAIL_ON_UNKNOWN_PROPERTIES|^  [A-Za-z]+\.[A-Z_]+ - Boot'
custom() {
  echo "A - after/ with the harness's Mapper joined, port 19382:"
  customa
  echo "B - the harness's Strict joined too (a JsonMapperBuilderCustomizer bean: builder.enable(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES)), port 19382:"
  start "$(hcp .harness/after 19382 probe.json.Mapper,probe.json.Strict)"; up 19382; ready 19382
  rqf 19382 /probe/mapper "$MAPF"
  pj 19382 "$CKIRAN"; pj 19382 "$CROHAN"; ask 19382 /customers/Rohan
  stop 19382 .harness/after
  echo "A' - A again, on a fresh JVM:"
  customa
  echo "A' against A, its label aside, line for line the same: $(asame 'A - after/' 'B - the harness' "A' - A again")"; }
customa() { start "$(hcp .harness/after 19382 probe.json.Mapper)"; up 19382; ready 19382
  rqf 19382 /probe/mapper "$MAPF"
  pj 19382 "$CKIRAN"; p5 19382 "$CROHAN"
  stop 19382 .harness/after; }

# ---- three: the correction comment's three differences ------------------------------------------------------------------------
three() { local c e
  echo "the three differences the correction comment names, on Spring's mapper - after/ with the harness's Dates joined, port 19382:"
  start "$(hcp .harness/after 19382 probe.json.Dates)"; up 19382; ready 19382
  echo "1 an unknown property - Core Java II's own unknown field, loyaltyPoints, in a new customer:"
  pj 19382 "$CKIRAN"
  echo "2 java.time with no module registered - the harness's Dates.When(LocalDate, LocalDateTime, Duration), written by Boot's mapper (Spring MVC's converter), then by a plain JsonMapper:"
  rq 19382 /probe/dates; rq 19382 /probe/dates/plain
  stop 19382 .harness/after
  echo "3 Core Java II's line, as that lesson wrote it (harness/three/Configure2.java, its two lines):"
  grep -n -A1 'ObjectMapper lenient = new ObjectMapper()' harness/three/Configure2.java | sed 's/^/    /'
  c="javac -d .harness/three -cp \".harness/after/tiffinbox-web/target/extracted/lib/*\" harness/three/Configure2.java"
  echo "\$ $c"; e=0; rm -rf .harness/three; (eval "$c") > .harness/three.log 2>&1 < /dev/null || e=$?
  echo "  exit $e · what it printed:"; sed 's/^/    /' .harness/three.log
  echo "  and Jackson 3's way - its builder (harness/three/Configure3.java, its three lines):"
  grep -n -A2 'JsonMapper lenient = JsonMapper.builder()' harness/three/Configure3.java | sed 's/^/    /'
  c="javac -d .harness/three -cp \".harness/after/tiffinbox-web/target/extracted/lib/*\" harness/three/Configure3.java"
  echo "\$ $c"; e=0; (eval "$c") > .harness/three.log 2>&1 < /dev/null || e=$?; echo "  exit $e · what it printed: $(grep -c . .harness/three.log || true) lines"
  c="java -cp \".harness/three:.harness/after/tiffinbox-web/target/extracted/lib/*\" probe.three.Configure3"
  echo "\$ $c"; e=0; (eval "$c") > .harness/three.log 2>&1 < /dev/null || e=$?; echo "  exit $e · what it printed: $(paste -sd' ' .harness/three.log)"; }

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
  echo "  the shell is now in: $(where "$d1") · the copy's own token in its log: $(raw "$(head -1 .harness/mine/after/$TF)" .harness/ex-readme.log) times · listening on 19389 now: $(listeners 19389)"
  echo "the solution's $(printf '%s\n' "$sol" | grep -c .) lines, next, in the same shell:"
  printf '%s\n' "$sol" | sed 's/^/  $ /'
  echo "  exit $e2 · what they printed:"; sed 's/^/    /' .harness/ex-sol.out
  echo "  the shell is now in: $(where "$d2") · the copy's own token in its log: $(raw "$(head -1 .harness/mine/after/$TF)" .harness/mine/run.log) times · WARN lines in its log: $(grep -c ' WARN ' .harness/mine/run.log || true) · listening on 19389 now: $(listeners 19389)"; }

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
  if [ "$1" = '4 the image' ]; then [ "$(grep -c '^  docker port: ' .harness/blk.txt)" = 2 ] && [ "$(grep -cE '^  docker port: 18425/tcp -> 127\.0\.0\.1:19387$' .harness/blk.txt)" = 2 ] && echo yes || echo no
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
# The YAML check, shown failing once before any capture on a planted copy of after/'s file - the three lines under tiffinbox: - and
# passing on after/'s own (float prints it again, and a second plant: below the "---")
plant "after/$YAML" tiffinbox: 1 > .harness/planted.yaml
case "$(kplace .harness/planted.yaml)" in *'under tiffinbox: (line 2)'*'in the first document: no') ;; *) die "kplace: a key under tiffinbox: passes the check (the planted copy .harness/planted.yaml)" ;; esac
case "$(kplace "after/$YAML")" in *'under spring: '*'in the first document: yes') ;; *) die "kplace: after/'s own application.yaml fails the check" ;; esac
rm -f .harness/planted.yaml
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
# routes PORT: a new customer (the request-body lesson's line), read back by the binding lesson's line; two point seven meals (this
# unit's line), and the same name read back - each answer printed (the timestamp masked)
routes() { rp "$(url "$R_ADD" "$1")"; rq "$1" /customers/Asha; rp "$(url "$R_FLOAT" "$1")"; rq "$1" /customers/Mohan; }
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
  echo "  the key, in the application.yaml the native build read (.harness/nat's): $(kplace ".harness/nat/$YAML" | sed 's/^.* · in the first document: /in the first document: /')"
  echo "1 the jar - .harness/after, the README's run line, port 19380:"
  start "$(at .harness/after 19380 "$R_RUN")"; up 19380; ready 19380; tline; seven 19380 .harness/after
  echo "  then a new customer and two point seven meals, on a second start of the jar:"
  start "$(at .harness/after 19380 "$R_RUN")"; up 19380; ready 19380; routes 19380; stop 19380 .harness/after
  echo "2 the AOT jar - .harness/nat (the profile native's jar), the README's AOT line, port 19384:"
  start "$(at .harness/nat 19384 "$R_AOTRUN")"; up 19384; ready 19384; tline; seven 19384 .harness/nat
  echo "  then a new customer and two point seven meals, on a second start of the AOT jar:"
  start "$(at .harness/nat 19384 "$R_AOTRUN")"; up 19384; ready 19384; routes 19384; stop 19384 .harness/nat
  echo "  and on a third, the key turned back on by this unit's flag:"
  start "$(at .harness/nat 19384 "$R_AOTRUN $O_FLOATB")"; up 19384; ready 19384; rp "$(url "$R_FLOAT" 19384)"; rq 19384 /customers/Mohan; stop 19384 .harness/nat
  echo "3 the binary - .harness/nat, the README's line, port 19388:"
  start "$(at .harness/nat 19388 "$R_BIN")"; up 19388; ready 19388; tline; seven 19388 .harness/nat
  echo "  then a new customer and two point seven meals, on a second start of the binary:"
  start "$(at .harness/nat 19388 "$R_BIN")"; up 19388; ready 19388; routes 19388; stop 19388 .harness/nat
  echo "  and on a third, the key turned back on by this unit's flag:"
  start "$(at .harness/nat 19388 "$R_BIN $O_FLOATB")"; up 19388; ready 19388; rp "$(url "$R_FLOAT" 19388)"; rq 19388 /customers/Mohan; stop 19388 .harness/nat
  echo "4 the image - after/'s Dockerfile (the README's build line, this script's tag), the README's run line with your user, published on 127.0.0.1:19387:"
  image
  dstart "$(drun .harness/after 19387)"; ready 19387 "$BOX"; dbind 19387
  dseven 19387
  echo "  then a new customer and two point seven meals, on a second container of the image:"
  dstart "$(drun .harness/after 19387)"; ready 19387 "$BOX"; dbind 19387
  routes 19387
  post 19387 .harness/after; dgone "$BOX"; [ "$(listeners 19387)" = 0 ] || die "something still listens on 19387"
  dlog "$BOX"; echo "  exit $LASTE · its log (docker logs): the demo token 0 times · X-Shutdown-Token 0 times"
  docker rm "$BOX" > /dev/null
  echo "four forms, one tree: the seven (masked) $(grep -cE '^  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 2 · md5 87ca7efc8584dcccd40e6b956db1de9b$' .harness/cap.raw) of 4 times 87ca7efc8584dcccd40e6b956db1de9b · a new customer (POSTed, then read back) $(grep -cxF '  {"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 200' .harness/cap.raw) of 8 · two point seven meals refused $(grep -cxF '  {"timestamp":"…","status":400,"error":"Bad Request","path":"/customers"} 400' .harness/cap.raw) of 4, then not found $(grep -cxF '  {"timestamp":"…","status":404,"error":"Not Found","path":"/customers/Mohan"} 404' .harness/cap.raw) of 4 · the key turned back on by the flag, two point seven stored as 2 $(grep -cxF '  {"name":"Mohan","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 200' .harness/cap.raw) of 4 (the AOT jar and the binary, POSTed, then read back)"
  echo "  loopback, form by form: the jar $(lbk '1 the jar') · the AOT jar $(lbk '2 the AOT jar') · the binary $(lbk '3 the binary') · the image, published on 127.0.0.1 alone $(lbk '4 the image')"; }


cap float float
cap bean bean
cap order order
cap defaults defaults
cap naming naming
cap rename rename
cap custom custom
cap three three
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
# when it was read: logtok(), dlog(), fails()), anything this unit ships for reading, nor the binary this run built
for f in .harness/raw-*; do [ "$(cat "$f")" = "0" ] || die "a capture's raw output held the token ($f: $(cat "$f"))"; done
NBIN=0
for f in .r-*.out README.md exercise/README.md exercise/solution/SOLUTION.md receipts.md5 harness/shutdown.sh $HJ harness/three/*.java .harness/nat/$BIN; do
  [ -f "$f" ] || continue; case $f in .harness/nat*) NBIN=$((NBIN + 1)) ;; esac
  [ "$(raw "$TOKEN" "$f")" = 0 ] || die "$f holds the demo token, raw"; done
[ "$NBIN" = 1 ] || die "one binary was built, $NBIN were checked"
for f in .r-*.out; do ! grep -qE '/Users/|/private/|/home/|/var/folders/' "$f" || die "$f holds an absolute path"; [ -z "${GRAALVM_HOME:-}" ] || ! grep -qF "$GRAALVM_HOME" "$f" || die "$f holds the GraalVM's folder"; ! grep -qE 'c[0-9]-unit[0-9]|unit ?[0-9]' "$f" || die "$f holds a unit number"; ! grep -qE ' (with PID|started by) ' "$f" || die "$f holds Boot's process line"; ! grep -qE '^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T|"timestamp":"?[0-9]|timestamp=[A-Z0-9]|(exec|handler|task|utility)-[0-9]' "$f" || die "$f holds a log line's time, a timestamp or a thread's number"; ! grep -q "^$(printf '\t')at " "$f" || die "$f shows a stack frame"; ! grep -qE 'sha256:[0-9a-f]{64}' "$f" || [ "$(grep -cE 'sha256:[0-9a-f]{64}' "$f")" = "$(grep -cE 'eclipse-temurin(:25-jre)?@sha256:[0-9a-f]{64}' "$f")" ] || die "$f holds an ID other than the base image's digest"; ! grep -qE ':8080([^0-9]|$)' "$f" || die "$f shows a bind on 8080"; ! grep -q $'\r' "$f" || die "$f holds a carriage return"; done
for f in receipts.sh README.md exercise/README.md exercise/solution/SOLUTION.md harness/shutdown.sh; do [ -f "$f" ] || continue; ! grep -qE "exposure\.include='?\*" "$f" || die "$f exposes every endpoint (R.42)"; ! grep -E 'server\.error\.' "$f" | grep -vE '^ *#' > /dev/null || die "$f names one of Boot 3's error keys (server, then error) - Boot 4.1 reads only spring.web.error.* (S2.13)"; done
for f in receipts.sh README.md exercise/README.md exercise/solution/SOLUTION.md; do [ -f "$f" ] || continue; ! grep -E 'docker run ' "$f" | grep -vE '^#' | grep -E ' -p "?[0-9]+:' > /dev/null || die "$f publishes a port on every address (-p without 127.0.0.1:)"; done
NL=$(cat .r-*.out | grep -cE "^  its log: the demo token 0 times · X-Shutdown-Token 0 times\$" || true)
echo "  tokens: 0 raw copies in $(ls .harness/raw-* | wc -l | tr -d ' ') raw capture runs, in $(ls .r-*.out | wc -l | tr -d ' ') captures; the demo token 0 in the logs of every JVM that served ($LOGS here; the published captures' $NL), every start that failed ($FLOGS here) and every container ($CLOGS here), the image's layers (forms), the READMEs, the harness, the exercise, receipts.md5 and the binary; no absolute path, no GraalVM folder, no unit number, no process line, no log time, no timestamp, no thread number, no stack frame, no ID but the base image's digest, no 8080, no carriage return in any capture; every docker run publishes on 127.0.0.1 only"

S87C='87ca7efc8584dcccd40e6b956db1de9b'
RES="    WARN .w.s.m.s.DefaultHandlerExceptionResolver: Resolved [org.springframework."
NR400="${RES}http.converter.HttpMessageNotReadableException: JSON parse error: "
MOHAN2='  {"name":"Mohan","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 200'
KIRAN2='  {"name":"Kiran","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 200'
E4XX() { printf '  {"timestamp":"…","status":%s,"error":"%s","path":"%s"} %s' "$1" "$2" "$3" "$1"; }
WA() { printf '%s · WARN lines it added: %s' "$1" "$2"; }
# PQ PORT 'BODY' [PATH]: the POST line pc() prints for that body, as the capture shows it ($ first); BQ PORT PATH: the one-customer line
PQ() { printf '$ %s' "$(pc "$1" "${3:-/customers}" "$2")"; }
BQ() { printf "\$ curl -s -w ' %%{http_code}\\\\n' http://127.0.0.1:%s%s" "$1" "$2"; }
[ "$(PQ 19380 "$MOHAN")" = "\$ $(url "$R_FLOAT" 19380)" ] && [ "$(BQ 19380 /customers/Mohan)" = "\$ $(bc 19380 /customers/Mohan)" ] || die "the checks' own command lines are not the README's"
E400=$(E4XX 400 'Bad Request' /customers)
COERCE() { printf '%sCannot coerce Floating-point value (%s) to `int` value (but could if coercion was enabled using `CoercionConfig`)]' "$NR400" "$1"; }
NULLINT="${NR400}Cannot map \`null\` into type \`int\` (set \`DeserializationFeature.FAIL_ON_NULL_FOR_PRIMITIVES\` to 'false' to allow)]"
H2NULL='    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: Servlet.service() for servlet [dispatcherServlet] in context with path [] threw exception [Request processing failed: org.h2.jdbc.JdbcSQLIntegrityConstraintViolationException: NULL not allowed for column "MEAL_TYPE"; SQL statement:'
H2SQL='      INSERT INTO customer (name, meals_per_day, price_per_meal, meal_type) VALUES (?, ?, ?, ?) [23502-250]] with root cause'
NISHA='{"name":"Nisha","mealsPerDay":2.0,"pricePerMeal":110,"mealType":"VEG"}'; RAJ='{"name":"Raj","mealsPerDay":2,"pricePerMeal":110.5,"mealType":"VEG"}'
OM='{"name":"Om","mealsPerDay":"2","pricePerMeal":110,"mealType":"VEG"}'

# "TiffinBox answers two hundred, stores two meals, and logs nothing." - and the change itself: one key, three lines, in the first
# document; "It sits in the first document, above the dashes; below them it would belong to the rush profile alone." ... "A: two point
# seven is a four hundred, Jackson's reason in one warning line, and nothing is stored. Two point zero too ... The number two, sent as
# text, still reads. B: the flag set true, stored as two. A again: four hundred."
FB=$(blk float 'before - the previous tree' 'A - after/'); FA=$(blk float 'A - after/' 'B - this unit'); FBB=$(blk float 'B - this unit' "A' - A again"); FA2=$(blk float "A' - A again" "A' against A")
x float '^  built the previous tree · offline: yes · exit 0$'; x float '^  built after/ · offline: yes · exit 0$'
[ "$(n float '^  Files ')" = 2 ] && [ "$(n float '^  Only in ')" = 0 ] || die "float: two files differ, none added or deleted"
for f in README.md tiffinbox-web/src/main/resources/application.yaml; do x float "^  Files \.harness/before/$f and \.harness/after/$f differ\$"; done
x float "^  after/'s files: 25 · byte for byte the previous tree's: 23 · those above differ: 2\$"
x float '^  application\.yaml - its lines that are neither comment nor blank: 47 -> 50 · their diff \(diff -U1, its file names cut\) - hunks: 1 · lines out: 0 · in: 3 - whole:$'
[ "$(blk float '  application.yaml - its lines' '  its comment lines' | paste -sd'|' -)" = '    @@ -27,2 +27,5 @@|           enabled: false|    +  jackson:|    +    deserialization:|    +      accept-float-as-int: false|     logging:' ] || die "float: the YAML's three new lines, after compose's enabled: false, before logging:"
x float '^  its comment lines: 37 -> 41 · those right above the key: 4 \(not shown\)$'
x float '^  jackson: line 54, under spring: \(line 23\) · deserialization: line 55 · accept-float-as-int: false line 56 · the first "---" line 84 · in the first document: yes$'
x float "^  a planted copy, the three lines moved under the second document's spring: \(the profile rush's\): jackson: line [0-9]+, under spring: \(line [0-9]+\) · .* · in the first document: no\$"
x float "^  Boot's metadata \(spring-boot-jackson-4\.1\.1\.jar\) - spring\.jackson\.deserialization · its type: java\.util\.Map<tools\.jackson\.databind\.DeserializationFeature,java\.lang\.Boolean> · its default: none · "
x float "^the executable jar's BOOT-INF/lib: 56 jars -> 56 · the same names: yes\$"
[ "$(aft "$(PQ 19381 "$MOHAN")" "$FB")" = "$(WA "$MOHAN2" 0)" ] && [ "$(aft "$(BQ 19381 /customers/Mohan)" "$FB")" = "$(WA "$MOHAN2" 0)" ] || die "float before: 2.7 stored as 2, 200, no WARN"
for b in "$FA" "$FA2"; do
  [ "$(aft "$(PQ 19380 "$MOHAN")" "$b")" = "$(WA "$E400" 1)" ] && has "$b" "$(COERCE 2.7)" "float A/A': Jackson's reason" || die "float A/A': 2.7 -> 400 and one WARN"
  [ "$(aft "$(BQ 19380 /customers/Mohan)" "$b")" = "$(WA "$(E4XX 404 'Not Found' /customers/Mohan)" 0)" ] || die "float A/A': nothing stored"
  [ "$(aft "$(PQ 19380 "$NISHA")" "$b")" = "$(WA "$E400" 1)" ] && has "$b" "$(COERCE 2.0)" "float A/A': 2.0 too" || die "float A/A': 2.0 -> 400"
  [ "$(aft "$(PQ 19380 "$RAJ")" "$b")" = "$(WA "$E400" 1)" ] && has "$b" "$(COERCE 110.5)" "float A/A': the price too" || die "float A/A': 110.5 -> 400"
  [ "$(aft "$(PQ 19380 "$OM")" "$b")" = "$(WA '  {"name":"Om","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 200' 0)" ] || die "float A/A': \"2\" still read as 2"
  [ "$(aft "$(PQ 19380 "$CKIRAN")" "$b")" = "$(WA "$KIRAN2" 0)" ] || die "float A/A': an unknown property still ignored"
  [ "$(aft "$(PQ 19380 "$DMISS")" "$b")" = "$(WA "$E400" 1)" ] && has "$b" "$NULLINT" "float A/A': the missing int's reason" || die "float A/A': a missing int still 400"
  [ "$(aft "$(PQ 19380 "$CROHAN")" "$b")" = "$(E4XX 500 'Internal Server Error' /customers)" ] && has "$b" "$H2NULL" "float A/A': H2's NULL refusal" && has "$b" "$H2SQL" "float A/A': 23502" || die "float A/A': a misspelt key still ignored - H2's 500"
  has "$b" "  WARN lines in this run's log, at Boot's default level: 4 · ERROR lines: 1" "float A/A': four WARN lines, one per 400; one ERROR"; done
[ "$(aft "$(PQ 19380 "$MOHAN")" "$FBB")" = "$(WA "$MOHAN2" 0)" ] && [ "$(aft "$(BQ 19380 /customers/Mohan)" "$FBB")" = "$(WA "$MOHAN2" 0)" ] || die "float B: the flag - 2.7 stored as 2 again"
printf '%s\n' "$FBB" | grep -q -- ' --spring\.jackson\.deserialization\.accept-float-as-int=true$' || die "float B: the flag on the command line"
FC=$(blk float 'C (labelled)' "A' - A again")
printf '%s\n' "$FC" | grep -qE '^  its application\.yaml: jackson: line [0-9]+, under spring: \(line [0-9]+\) · .* · in the first document: no$' || die "float C: the copy's key below the ---"
has "$FC" '  built the planted copy · offline: yes · exit 0' "float C: built offline"
[ "$(aft "$(PQ 19380 "$MOHAN")" "$FC")" = "$(WA "$MOHAN2" 0)" ] && [ "$(aft "$(BQ 19380 /customers/Mohan)" "$FC")" = "$(WA "$MOHAN2" 0)" ] || die "float C: the key below the --- - a plain run stores 2.7 as 2"
x float "^A' against A, its label aside, line for line the same: yes\$"
echo "  float: 2 files (application.yaml +3 lines, the README); the key in the first document under spring:, above the --- (a planted copy below it caught); 56 libraries, the same; before 2.7 -> 200 stored as 2; A 2.7, 2.0, 110.5 -> 400 + 1 WARN each, a missing int 400, \"2\" and an unknown property 200, a misspelt key H2's 500; B (the flag) 2.7 -> 2; C (the key below the ---) 2.7 -> 2; A' = A"

# "One mapper bean, Jackson three's ... Spring's JSON converter uses that very object; Actuator writes with one of its own. The harness reads
#  a hundred and twenty features, the on-off switches of eight kinds ... On the previous tree they agree on all a hundred and twenty"
BB=$(blk bean 'before - the previous tree' 'after - after/'); BA=$(blk bean 'after - after/' '')
for b in "$BB" "$BA"; do
  has "$b" "  beans of type JsonMapper: 1 - jacksonJsonMapper (tools.jackson.databind.json.JsonMapper) · of type ObjectMapper, Jackson 3's: 1 - jacksonJsonMapper" "bean: one mapper bean"
  has "$b" "  the JSON converter's mapper (JacksonJsonHttpMessageConverter): Boot's bean jacksonJsonMapper itself: yes" "bean: the converter's mapper is that bean"
  has "$b" "  Actuator's mapper (the bean endpointJsonMapper, an EndpointJsonMapper): Boot's bean itself: no" "bean: Actuator's own mapper"
  has "$b" "  modules registered - Boot's mapper: 2 (JacksonComponentModule, JacksonMixinModule) · a plain JsonMapper (JsonMapper.builder().build()): 0" "bean: the modules"
  has "$b" "  property naming - Boot's mapper: none · Actuator's: none · a plain one: none" "bean: no naming"
  has "$b" "  the 8 this lesson names - Boot's mapper · a plain one · Actuator's:" "bean: the eight named"
  for l in 'MapperFeature.SORT_PROPERTIES_ALPHABETICALLY: true · true · true' 'MapperFeature.SORT_CREATOR_PROPERTIES_FIRST: true · true · true' 'SerializationFeature.ORDER_MAP_ENTRIES_BY_KEYS: false · false · false' 'DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES: false · false · false' 'DeserializationFeature.FAIL_ON_NULL_FOR_PRIMITIVES: true · true · true' 'DeserializationFeature.FAIL_ON_TRAILING_TOKENS: true · true · true' 'DateTimeFeature.WRITE_DATES_AS_TIMESTAMPS: false · false · false'; do has "$b" "    $l" "bean: $l"; done; done
FR8='features read: 120 - every constant of 8 kinds (MapperFeature 31, DeserializationFeature 28, SerializationFeature 17, DateTimeFeature 15, EnumFeature 9, JsonNodeFeature 6, StreamReadFeature 7, StreamWriteFeature 7)'
has "$BB" "  $FR8 · Boot's mapper and a plain one differ in: 0" "bean before: all 120 alike"
has "$BB" '    DeserializationFeature.ACCEPT_FLOAT_AS_INT: true · true · true' "bean before: floats accepted as ints"
has "$BA" "  $FR8 · Boot's mapper and a plain one differ in: 1" "bean after: one differs"
has "$BA" "    DeserializationFeature.ACCEPT_FLOAT_AS_INT - Boot's mapper: false · a plain one: true" "bean after: the key's feature"
has "$BA" '    DeserializationFeature.ACCEPT_FLOAT_AS_INT: false · true · true' "bean after: Boot's false, the plain one's and Actuator's true"
echo "  bean: one JsonMapper bean, jacksonJsonMapper, the JSON converter's; Actuator's its own; 2 modules, 0 on a plain one; 120 features of 8 kinds - before 0 differ, after 1 (ACCEPT_FLOAT_AS_INT false)"

# "A class's fields do come out sorted. But a record's components ... in the order declared. And a map keeps the order you put its keys in.
#  TiffinBox answers with records and maps."
OR=$(cat .r-order.out)
[ "$(aft "$(BQ 19382 /probe/order/record)" "$OR")" = '  {"zeta":"z","alpha":1,"mid":"m"} 200' ] || die "order: the record, declared order"
[ "$(aft "$(BQ 19382 /probe/order/class)" "$OR")" = '  {"alpha":1,"mid":"m","zeta":"z"} 200' ] || die "order: the class, sorted"
[ "$(aft "$(BQ 19382 /probe/order/map)" "$OR")" = '  {"zeta":"z","alpha":1,"mid":"m"} 200' ] || die "order: the map, the order its keys were put in"
has "$OR" "  com.tiffinbox.Customer's components, in the order the record declares them: name mealsPerDay pricePerMeal mealType · the same names sorted: mealType mealsPerDay name pricePerMeal" "order: Customer's components"
[ "$(aft "$(BQ 19382 /customers/Ravi)" "$OR")" = '  {"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"} 200' ] || die "order: TiffinBox's record, declared order"
echo "  order: a record zeta alpha mid, a class alpha mid zeta, a map zeta alpha mid; Customer as declared"

# "one flag, use Jackson two defaults ... B: with the flag, thirteen switches flip. A missing meal count is stored as zero ... Text after the
#  closing brace is accepted. The class keeps its declared order, and an error's time ends plus zero zero instead of Z. The seven still
#  match, with timestamps masked. A again: back as it was."
DA=$(blk defaults 'A - after/' 'B - the same'); DB=$(blk defaults 'B - the same' "A' - A again"); DA2=$(blk defaults "A' - A again" "A' against A")
x defaults "^  Boot's metadata \(spring-boot-jackson-4\.1\.1\.jar\) - spring\.jackson\.use-jackson2-defaults · its type: java\.lang\.Boolean · its default: false · its description: Whether to configure Jackson 3 with the same defaults as Spring Boot previously used for Jackson 2\.\$"
for b in "$DA" "$DA2"; do has "$b" "  saved, not shown: 120 features, each one's name and value · its status: 200" "defaults A/A': 120 features"
  [ "$(aft "$(BQ 19382 /probe/order/class)" "$b")" = '  {"alpha":1,"mid":"m","zeta":"z"} 200' ] || die "defaults A/A': the class sorted"
  [ "$(aft "$(PQ 19382 "$DMISS")" "$b")" = "$(WA "$E400" 1)" ] && has "$b" "$NULLINT" "defaults A/A'" || die "defaults A/A': a missing int, 400"
  has "$b" '  that answer'"'"'s timestamp, its form: "timestamp":"dddd-dd-ddTdd:dd:dd.dddZ" ×1' "defaults A/A': the timestamp ends Z"
  [ "$(aft "$(PQ 19382 "$DTRAIL")" "$b")" = "$(WA "$E400" 1)" ] && printf '%s\n' "$b" | grep -qF -- "${NR400}Unrecognized token 'extra'" || die "defaults A/A': trailing text, 400"; done
has "$DB" "  features whose value differs from A's: 13 of 120" "defaults B: thirteen flip"
[ "$(printf '%s\n' "$DB" | grep -cE '^    [A-Za-z]+Feature\.[A-Z_]+: (true -> false|false -> true)$')" = 13 ] || die "defaults B: thirteen listed"
for l in 'MapperFeature.SORT_PROPERTIES_ALPHABETICALLY: true -> false' 'DeserializationFeature.FAIL_ON_NULL_FOR_PRIMITIVES: true -> false' 'DeserializationFeature.FAIL_ON_TRAILING_TOKENS: true -> false' 'DateTimeFeature.WRITE_UTC_AS_OFFSET: false -> true'; do has "$DB" "    $l" "defaults B: $l"; done
! printf '%s\n' "$DB" | grep -qE '^    (DeserializationFeature\.FAIL_ON_UNKNOWN_PROPERTIES|DeserializationFeature\.ACCEPT_FLOAT_AS_INT|DateTimeFeature\.WRITE_DATES_AS_TIMESTAMPS):' || die "defaults B: unknown properties, the key's feature and dates as numbers do not flip"
[ "$(aft "$(BQ 19382 /probe/order/class)" "$DB")" = '  {"zeta":"z","alpha":1,"mid":"m"} 200' ] || die "defaults B: the class, declared order"
[ "$(aft "$(PQ 19382 "$DMISS")" "$DB")" = "$(WA '  {"name":"Tara","mealsPerDay":0,"pricePerMeal":110,"mealType":"VEG"} 200' 0)" ] && [ "$(aft "$(BQ 19382 /customers/Tara)" "$DB")" = "$(WA '  {"name":"Tara","mealsPerDay":0,"pricePerMeal":110,"mealType":"VEG"} 200' 0)" ] || die "defaults B: a missing int stored as 0"
[ "$(aft "$(PQ 19382 "$DTRAIL")" "$DB")" = "$(WA '  {"name":"Lata","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 200' 0)" ] || die "defaults B: trailing text accepted"
[ "$(aft "$(PQ 19382 "$MOHAN")" "$DB")" = "$(WA "$E400" 1)" ] && has "$DB" "$(COERCE 2.7)" "defaults B: the key wins" || die "defaults B: 2.7 still 400"
has "$DB" '  that answer'"'"'s timestamp, its form: "timestamp":"dddd-dd-ddTdd:dd:dd.ddd+dd:dd" ×1' "defaults B: the timestamp ends +00:00"
printf '%s\n' "$DB" | grep -q -- " --spring\.jackson\.use-jackson2-defaults=true\$" || die "defaults B: the flag"
has "$DB" "  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 2 · md5 $S87C" "defaults B: the seven, masked, the same"
has "$DB" '  the timestamps the mask hid, their form: "timestamp":"dddd-dd-ddTdd:dd:dd.ddd+dd:dd" ×2' "defaults B: the seven's two timestamps, +00:00"
x defaults "^A' against A, its label aside, line for line the same: yes · its features against A's: 0 of 120 differ\$"
echo "  defaults: Boot's metadata (default false); B: 13 of 120 features flip - a missing int stored as 0, trailing text 200, the class in declared order, the timestamp +00:00; 2.7 still 400; the seven $S87C masked; A' = A"

# "snake case writes meals per day with underscores. Of the seven, one line changes: the customers list. Maps keep their keys, and Actuator's
#  mapper never sees the setting. ... Write the strategy in lower case and TiffinBox never starts: exit one, no failure analysis from Boot,
#  over a hundred stack frames, and the last cause names the word."
NA=$(blk naming 'A - after/' 'B - this unit'); NB=$(blk naming 'B - this unit' 'C (labelled)'); NC=$(blk naming 'C (labelled)' "A' - A again"); NA2=$(blk naming "A' - A again" "A' against A")
x naming "^  Boot's metadata \(spring-boot-jackson-4\.1\.1\.jar\) - spring\.jackson\.property-naming-strategy · its type: java\.lang\.String · its default: none · its description: One of the constants on Jackson's PropertyNamingStrategies\. "
for b in "$NA" "$NA2"; do has "$b" "  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 2 · md5 $S87C" "naming A/A': the seven"; done
printf '%s\n' "$NB" | grep -qE '^  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 2 · md5 [0-9a-f]{32}$' && ! printf '%s\n' "$NB" | grep -q "md5 $S87C" || die "naming B: the seven, another hash"
has "$NB" "  the lines that differ from A's seven: 1 - 1c1:" "naming B: one line, the first"
printf '%s\n' "$NB" | grep -qE '^    < GET   /customers  -> 200 application/json  \[\{"name":"Meera","mealsPerDay":1,' || die "naming B: A's /customers line"
printf '%s\n' "$NB" | grep -qE '^    > GET   /customers  -> 200 application/json  \[\{"name":"Meera","meals_per_day":1,"price_per_meal":150,"meal_type":"NON_VEG"\},' || die "naming B: snake case keys"
has "$NB" "  property naming - Boot's mapper: SnakeCaseStrategy · Actuator's: none · a plain one: none" "naming B: Boot's mapper alone"
[ "$(aft "$(BQ 19382 /probe/rename)" "$NB")" = '  {"name":"Ravi","meals":2} 200' ] || die "naming B: @JsonProperty beats the strategy"
has "$NC" "  exit 1 · its log, read after it exited - Boot's failure analysis (APPLICATION FAILED TO START): 0 · stack frames: over 100, not shown · Caused by lines: 7" "naming C: exit 1, no analysis, over 100 frames"
has "$NC" "  the last Caused by line: Caused by: java.lang.IllegalStateException: Constant named 'snake_case' not found" "naming C: the last cause names the word"
has "$NC" '    ERROR o.s.boot.SpringApplication: Application run failed' "naming C: Boot's ERROR line"
has "$NC" '  listening now: 19380 0' "naming C: nothing listened"
x naming "^A' against A, its label aside, line for line the same: yes\$"
echo "  naming: Boot's metadata (a constant's name); B SNAKE_CASE: 1 of the 7 lines changes (/customers), Actuator's mapper none, @JsonProperty kept; C snake_case: exit 1, no failure analysis, over 100 frames, 7 causes, the last naming the word; A' = A"

# "the harness record writes meals, and reads meals. Its Java name is now just an unknown property, ignored, so the meal count is missing:
#  four hundred."
RN=$(cat .r-rename.out)
[ "$(aft "$(BQ 19382 /probe/rename)" "$RN")" = '  {"name":"Ravi","meals":2} 200' ] || die "rename: written as meals"
[ "$(aft "$(PQ 19382 '{"name":"Ravi","meals":3}' /probe/rename)" "$RN")" = "$(WA '  {"name":"Ravi","meals":3} 200' 0)" ] || die "rename: read as meals"
[ "$(aft "$(PQ 19382 '{"name":"Ravi","mealsPerDay":3}' /probe/rename)" "$RN")" = "$(WA "$(E4XX 400 'Bad Request' /probe/rename)" 1)" ] && has "$RN" "$NULLINT" "rename: the Java name's reason" || die "rename: the Java name, 400"
echo "  rename: written meals, read meals; mealsPerDay ignored -> the int missing -> 400 + WARN"

# "a builder customizer ... The harness's refuses unknown properties. A: loyalty points ignored, and a misspelt meal type reaches the
#  database as empty, a five hundred. B: both are four hundreds, the reason only in the log. Actuator's mapper stays as it was."
CA=$(blk custom 'A - after/' 'B - the harness'); CB=$(blk custom 'B - the harness' "A' - A again"); CA2=$(blk custom "A' - A again" "A' against A")
for b in "$CA" "$CA2"; do has "$b" "  $FR8 · Boot's mapper and a plain one differ in: 1" "custom A/A': one differs, the key's"
  has "$b" '    DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES: false · false · false' "custom A/A': unknown properties allowed, all three"
  [ "$(aft "$(PQ 19382 "$CKIRAN")" "$b")" = "$(WA "$KIRAN2" 0)" ] || die "custom A/A': loyaltyPoints ignored"
  [ "$(aft "$(PQ 19382 "$CROHAN")" "$b")" = "$(E4XX 500 'Internal Server Error' /customers)" ] && has "$b" "$H2NULL" "custom A/A'" || die "custom A/A': the misspelt key, H2's 500"; done
has "$CB" "  $FR8 · Boot's mapper and a plain one differ in: 2" "custom B: two differ"
has "$CB" "    DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES - Boot's mapper: true · a plain one: false" "custom B: the customizer's feature"
has "$CB" '    DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES: true · false · false' "custom B: Boot's true, Actuator's false"
[ "$(aft "$(PQ 19382 "$CKIRAN")" "$CB")" = "$(WA "$E400" 1)" ] && has "$CB" "${NR400}Unrecognized property \"loyaltyPoints\" (class com.tiffinbox.Customer), not marked as ignorable]" "custom B" || die "custom B: loyaltyPoints refused"
[ "$(aft "$(PQ 19382 "$CROHAN")" "$CB")" = "$(WA "$E400" 1)" ] && has "$CB" "${NR400}Unrecognized property \"mealTyp\" (class com.tiffinbox.Customer), not marked as ignorable]" "custom B" || die "custom B: the misspelt key refused, 400"
[ "$(aft "$(BQ 19382 /customers/Rohan)" "$CB")" = "$(WA "$(E4XX 404 'Not Found' /customers/Rohan)" 0)" ] || die "custom B: nothing stored"
! printf '%s\n' "$CB" | grep -q 'ERROR ' || die "custom B: no ERROR line"
x custom "^A' against A, its label aside, line for line the same: yes\$"
echo "  custom: A unknown 200, typo H2's 500; B (Strict) Boot's FAIL_ON_UNKNOWN_PROPERTIES true, Actuator's false - unknown and typo 400 + WARN, nothing stored; A' = A"

# "An unknown property is ignored, not refused. That lesson's configure line doesn't compile ... the setting goes on its builder. And dates
#  and durations come out as text, with no module registered."
TH=$(cat .r-three.out)
[ "$(aft "$(PQ 19382 "$CKIRAN")" "$TH")" = "$(WA "$KIRAN2" 0)" ] || die "three: an unknown property ignored"
[ "$(aft "$(BQ 19382 /probe/dates)" "$TH")" = '  {"day":"2026-10-14","at":"2026-10-14T12:30:00","took":"PT25M"} 200' ] || die "three: Boot's mapper, ISO strings"
[ "$(aft "$(BQ 19382 /probe/dates/plain)" "$TH")" = '  {"day":"2026-10-14","at":"2026-10-14T12:30:00","took":"PT25M"} · modules registered on it: 0' ] || die "three: a plain mapper, no module, the same"
has "$TH" '    15-                .configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false);' "three: Core Java II's line"
has "$TH" '  exit 1 · what it printed:' "three: javac exit 1"
for l in '    harness/three/Configure2.java:15: error: cannot find symbol' '      symbol:   method configure(DeserializationFeature,boolean)' '      location: class ObjectMapper' '    1 error'; do has "$TH" "$l" "three: javac's message"; done
has "$TH" '  exit 0 · what it printed: 0 lines' "three: the builder compiles"
has "$TH" '  exit 0 · what it printed: false' "three: the builder's mapper, read back"
echo "  three: an unknown property ignored; java.time as ISO strings, a plain mapper with 0 modules the same; Core Java II's configure line exit 1 (cannot find symbol, class ObjectMapper); the builder compiles, false"

# the exercise's end state: the README's commands, then the solution's, in ONE env -i shell - each leaves the shell in this folder;
# the line exercise/README.md calls "Done" is a line of this capture, after the solution's lines, and of SOLUTION.md's measured run;
# the README's own last line, as shipped, prints the failed start's exit code and last cause
XS=$(blk exercise "the README's" "the solution's"); XE=$(blk exercise "the solution's" '')
l="exit 0 · its last cause: none · Ravi's keys: name meals_per_day price_per_meal meal_type"; l0="exit 1 · its last cause: java.lang.IllegalStateException: Constant named 'snake_case' not found · Ravi's keys: none"
has "$XE" "    $l" "exercise: the solution"; has "$XS" "    $l0" "exercise: as shipped"
awk '/^\*\*Done\*\*/ { f = 1 } f' exercise/README.md | grep -qxF -- "$l" || die "exercise/README.md: Done names no such line"
grep -qxF -- "$l" exercise/solution/SOLUTION.md || die "SOLUTION.md: the measured run shows no such line"
grep -qF -- "\`$l0\`" exercise/README.md || die "exercise/README.md: the shipped line's answer is not named"
has "$XS" '  exit 0 · what they printed:' "exercise: the README's commands, exit 0"; has "$XE" '  exit 0 · what they printed:' "exercise: the solution's lines, exit 0"
has "$XS" "  the shell is now in: this unit's folder · the copy's own token in its log: 0 times · listening on 19389 now: 0" "exercise: the README's commands leave the shell in this unit's folder, nothing listening"
has "$XE" "  the shell is now in: this unit's folder · the copy's own token in its log: 0 times · WARN lines in its log: 0 · listening on 19389 now: 0" "exercise: the solution's lines leave the shell in this unit's folder, nothing logged, nothing listening"
[ "$(printf '%s\n' "$XE" | grep -c '^  \$ export ')" = 2 ] || die "exercise: SOLUTION.md gives the README's two export lines"
r=$(printf '%s\n' "$XS" | grep '^  \$ (cd \.harness/mine/after && ' | sed 's/^  \$ //'); r2=$(printf '%s\n' "$XE" | grep '^  \$ (cd \.harness/mine/after && ' | sed 's/^  \$ //')
[ "${r2/=SNAKE_CASE /=snake_case }" = "$r" ] && [ "$r2" != "$r" ] || die "exercise: the solution's last line is the README's with the constant's case changed, and nothing else"
echo "  exercise: one env -i shell - the README as written -> exit 1, the last cause naming snake_case, no keys; the solution's line (SNAKE_CASE) -> exit 0, meals_per_day price_per_meal meal_type; the shell in this unit's folder after each"

# "And every form, the jar, the AOT jar, built ahead of time, the native binary and the image, serves the seven and refuses two point seven,
#  on loopback, this computer only. In the AOT jar and the binary, the flag still turns it back on: Boot reads the key when TiffinBox starts."
x forms '^  exit 0 · BUILD SUCCESS · stages it printed: 8 of the 8 it announces · its duration, against the bound: under 20 minutes · its lines that say the metadata repository was downloaded over http, or failed to: 0 · offline: yes$'
x forms '^  file: Mach-O 64-bit executable · the demo token in its bytes: 0$'
x forms '^  Spring.s generated metadata \(spring-aot/main/resources/META-INF/native-image/com\.tiffinbox/tiffinbox-web/reachability-metadata\.json\): reflection entries naming com\.tiffinbox\.Customer: 1 - all declared fields · all declared constructors · 4 methods \(mealType mealsPerDay name pricePerMeal\)$'
x forms '^  the key, in the application\.yaml the native build read \(\.harness/nat.s\): in the first document: yes$'
x forms "^four forms, one tree: the seven \(masked\) 4 of 4 times $S87C · a new customer \(POSTed, then read back\) 8 of 8 · two point seven meals refused 4 of 4, then not found 4 of 4 · the key turned back on by the flag, two point seven stored as 2 4 of 4 \(the AOT jar and the binary, POSTed, then read back\)\$"
x forms '^  loopback, form by form: the jar yes · the AOT jar yes · the binary yes · the image, published on 127\.0\.0\.1 alone yes$'
for t in '1 the jar' '2 the AOT jar' '3 the binary' '4 the image'; do x forms "^$t - "; done
[ "$(n forms "^  Boot's first line: Starting AOT-processed TiffinBoxServer v1\.0\.0 using Java 25\.0\.4\.1\$")" = 3 ] && [ "$(n forms "^  Boot's first line: Starting AOT-processed TiffinBoxServer using Java 25\.0\.4\.1\$")" = 3 ] || die "forms: the AOT jar and the binary, AOT-processed, all three starts"
[ "$(n forms ' --spring\.jackson\.deserialization\.accept-float-as-int=true$')" = 2 ] || die "forms: the flag, on the AOT jar's third start and the binary's"
[ "$(n forms '^  inside the container, listening: \[::\]:18425$')" = 2 ] && [ "$(n forms '^  docker port: 18425/tcp -> 127\.0\.0\.1:19387$')" = 2 ] || die "forms: the image, two containers, published on 127.0.0.1 alone"
x forms '^  its lines that say pull: 0 · '
x forms '^  the image saved \(docker save\): [1-9][0-9]* blobs, its [1-9][0-9]* layers among them, each read whole \(gzip ones unpacked\) · the demo token in them: 0$'
echo "  forms: 8 of 8 stages, offline, Mach-O, 0 tokens; Customer in the AOT step's metadata; the key in the first document of the YAML it read; the jar, the AOT jar, the binary, the image: the seven $S87C 4 of 4, a new customer 200 4 of 4, 2.7 -> 400 then 404 4 of 4, the flag -> 2 on the AOT jar and the binary; loopback form by form; the image's layers 0 tokens"

cmp -s after/README.md ../c6-tiffinbox/README.md || echo "  (after/README.md and ../c6-tiffinbox/README.md differ - the anchor has moved past this unit's after/)" >&3
[ -z "$unpub" ] || die "no published hash for:$unpub - check the captures, then copy the md5s above into receipts.md5 and run again"
echo "c6-unit09: every capture 3/3 and = published; every spoken number asserted; 0 raw demo tokens in every capture, every log, the container's log, the image's layers and the binary; nothing of this run left on Docker"
