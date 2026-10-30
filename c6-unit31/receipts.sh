#!/bin/bash
XPATH=$PATH                                           # the PATH you started this with: the exercise's own shell gets it
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25.0.4.1 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# GRAALVM_HOME names a GraalVM JDK 25 (README.md, "The GraalVM"): the native build reads it. Without it, this script makes every
# capture that needs no GraalVM, filling .m2-demo on the way, then stops before the native build.
# Course 6 · Capstone: The TiffinBox Web App - this unit's receipts. The anchor changes for the last time in Course 6: the tour of
# the application as the course leaves it, and three jobs it still owed - a name length nobody checked (Customer gains
# @Size(max = 60), and TiffinBoxServer's 400 keeps every message a field earned), a bulk upload (CustomerImport, POST
# /customers/import) and a feed of new customers (CustomerFeed, GET /customers/feed, an event stream every add reaches); the tests
# extended (TiffinBoxWebTest, FullStackTest) and one new (FeedTest). Nine captures, each run three times and hashed; cap() DIES when
# a hash differs from receipts.md5; every number the video says is asserted at the bottom by a check that can fail; the demo token
# is masked (gsub), and the checks count 0 raw copies of it in every capture, in the log of every run and every Maven build, in
# every Surefire report, in every file this unit ships, in the binary and in the image's layers.
#   tour      the stereotypes read off after/'s sources, every class counted; the four boxes; /dashboard twice by Accept - the page
#             and the JSON, one path; the routes from /actuator/mappings (exposed for one run), TiffinBox's counted beside the total
#   seven     the seven on after/'s jar and on the previous tree's, each a fresh JVM, line for line; then against TiffinBox's own
#             server's seven, read from the servlet lesson's published capture: each line the same or not, and why
#   retired   Course 5's four web files in after/ (0 of 3, and the fourth kept as a name: its imports read); a second TiffinBox on
#             a port the first holds - Boot's analysis, its analyzer read off the jar that registers it
#   length    A/B/A' - a 61-letter name: A after/ (400), B the previous tree (500, H2's refusal in Tomcat's ERROR line), A' A again;
#             the form; Accept-Language de; C (labelled) 61 spaces, three fresh JVMs, one answer
#   upload    the bulk upload: a CSV with one good row and three bad, the answer, the list after it; no file part; de
#   feed      a listener (curl -N, to a file); a JSON add, a form add, an upload's row - three events; POST /shutdown with the
#             listener connected; C (labelled) a copy whose feed does not end its streams when the context closes
#   tests     TiffinBox's tests, the README's line, the harness's Census joined: Surefire's reports per class, the console's summary
#             beside them; C (labelled) the harness's StreamWait - MockMvcTester and an answer that never ends
#   exercise  exercise/README.md's commands, then exercise/solution/SOLUTION.md's, read from the files and run as written, one after
#             the other in ONE shell a viewer could have: env -i, /bin/bash, started in this folder
#   forms     the native build of after/ (the tests it ran; the Hibernate Validator metadata file's size on the terminal, R.145);
#             then four forms - the jar, the AOT jar, the binary, the image: each one's address, the seven (masked), exit 0; then,
#             on a second start of each, with a listener connected: the three messages, the size message (none and de), the
#             upload, the event it made, the page, and POST /shutdown - the shutdown, and the listener's end
# "The previous tree" is before/, the link to ../c6-unit28/after (the anchor before this change: the web-layer testing lesson's
# frozen tree, which units 29 and 30 read too), COPIED under .harness/before; after/ is this unit's frozen copy of ../c6-tiffinbox
# after the change, COPIED under .harness/ for every build. This script never writes into another unit's folder, and never builds a
# frozen tree in place. Every run of TiffinBox starts in a folder under .harness/ that holds a config tree with a fake token
# (secrets/) - and before every start the script lists that secrets/ folder: the token's file, and nothing else (a file there is a
# key, R.158) - the container's too, mounted read-only; every test runs in tiffinbox-web/ of such a folder, where no secrets/ is:
# the tests' token is a literal written in them. Commands are printed exactly as they run: each goes through eval. "$CURLSET" is
# the comparison set since the secrets lesson (../c5-unit11/curlset.sh: the seven requests, POST /shutdown with the token's header
# read from the file). "$M2" is this unit's own repository, .m2-demo. The harness (copied into a copy's tiffinbox-web/src/test,
# never into after/): Census (a TestExecutionListener, the testing lesson's byte for byte, named in harness/test/resources/META-INF/
# spring.factories) and StreamWait (a test class Surefire runs only when -Dtest names it), in probe.web, outside com.tiffinbox;
# harness/surefire.py reads Surefire's reports (the testing lesson's, byte for byte); harness/shutdown.sh is POST /shutdown with the
# token read from its file (the CORS lesson's, byte for byte); harness/import.csv is the upload's file. The seven always run on a
# fresh JVM, first.
# The locale: the JVM ignores LC_ALL on macOS - every JVM this script starts has its locale pinned on its run line (-Duser.language=en
# -Duser.country=US, before -jar), and the checks refuse a java line without it. A test JVM is Surefire's own (a fork): the POM's
# argLine pins it, and each run's reports say which locale the fork had. The binary takes no JVM options: its messages are the
# ones its build fixed. Every request that gets a validator's message says which Accept-Language it sent.
# The network: every Maven build runs offline (-o) against .m2-demo and says so ("offline: yes"); a build that cannot resolve an
# artifact offline goes to Maven Central once, and says that ("offline: no - ..."). GraalVM's native plugin reads its metadata
# repository (a zip) from .m2-demo - and when the zip is not there it downloads it from GitHub, even under -o: so a native-profile
# build without the zip goes to Maven Central for it at once, and every native build's log is searched for the plugin's own
# download line - found, the run stops. Docker: no pull - eclipse-temurin:25-jre must already be on the daemon. At run time nothing
# leaves 127.0.0.1: TiffinBox listens there (in a container, on the container's own addresses, published on the host's 127.0.0.1
# alone), every request goes there; a test's server listens on 127.0.0.1 too, on a port the system picks (RANDOM_PORT), read off
# the test JVM's pid by Census and masked.
# Masks and filters (README.md declares each; awk sub/gsub only): the demo token becomes "[masked: the N-character token]"; the
# GraalVM's folder "$GRAALVM_HOME"; this folder's absolute path "…", the folder above it "…/..", the home folder "~"; your user name
# "<user>"; a Tomcat request thread's number "tomcat-handler-<n>"; the Java version in Boot's first line " using Java <version>"
# (printed on the terminal once); Tomcat's connector name "http-nio-127.0.0.1-<port>"; Spring's error timestamp "…" (both forms). A
# Maven log is never printed whole: its BUILD line, Surefire's reports (surefire.py) with the console's summary beside their sum,
# the harness's CENSUS and EXCHANGE lines, its WARN and ERROR records, Surefire's own line about a fork that would not exit (counted),
# Mockito's and the JVM's console lines (counted); the rest counted, never shown. A JVM's log: Boot's first line, the lines of named
# loggers (each labelled by its logger), WARN and ERROR counted. A page is its <title> (and a form's messages); a JSON answer its
# bytes, keys sorted. No duration is captured: the native build's seconds, and the 20-minute bound, go to the terminal only; so does
# the Hibernate Validator metadata file's size (R.145: printed, never hashed). Boot's own "30000ms" is Boot's text, in its line.
# Ports (brief ⚑1, 19600-19609): after/'s jar 19600 · the AOT jar 19601 · the binary 19602 · the image 19603 (published on
# 127.0.0.1) · the tour's run 19604 · the previous tree's jar 19605 · the feed's C copy 19606 · the port-taken pair 19607 · 19609
# never bound. A test's server takes the port the system gives (above). 18425 (TiffinBox's default), 8080 (Tomcat's) and 35729
# (DevTools' Live Reload) are checked free too, and never bound on this machine (18425 only inside a container).
# Docker names (no unit number): the image tiffinbox-capstone:1.0.0 and the container tiffinbox-capstone. Each is checked absent
# before the first run - a name already there may be yours, and this script removes only what it creates - and removed on every exit.
set -e
# bash 5.2 and later turn an & in the replacement of ${x/pattern/replacement} into the matched text (patsub_replacement, on by
# default). Switched off, so /bin/bash 3.2 (./receipts.sh) and a newer bash (bash receipts.sh) run the same commands.
shopt -u patsub_replacement 2> /dev/null || true
# One locale for every tool, whatever yours is: sort's order, and what a program prints, follow it. The published captures were
# made with no locale set, which is the C locale. (The JVM ignores it on macOS: its locale is pinned per JVM, above.)
export LC_ALL=C
cd "$(dirname "$0")"
# One run at a time: two runs share .harness/, the ports and the Docker names, and one would corrupt the other.
mkdir .r-lock 2> /dev/null || { echo "  *** another receipts.sh is running in this folder (.r-lock exists) - if none is, rmdir .r-lock ***"; exit 1; }
IMG=tiffinbox-capstone:1.0.0; BOX=tiffinbox-capstone
OURS=""
U="$PWD"; UP="$(cd .. && pwd)"; ME="$(id -un)"
# On every exit - the end, a failed check, or Ctrl-C - stop the processes this script started in the background, if they still run:
# $pid and $pid2 (servers), $lpid (a listener: curl -N), $mpid (a Maven, with every process under it - Surefire's test JVM, the
# native image's builder), $xpid (the exercise's shell, with every process under it); then sweep(): anything of this run still
# alive in its process group - a TiffinBox JVM, a binary, a listener, a Maven, Surefire's fork, native-image's driver or builder -
# is stopped; then dclean(): this run's container and image. After an interrupt, a capture's unfinished runs (.r-NAME.1-3) go too;
# after a failed check they stay, for the diff the message names. The clean-up ignores a second Ctrl-C, and nothing in it can fail
# under set -e; the script still exits 130 after an interrupt (README.md, "Interrupted"). sweep() kills only processes of this
# run's own process group - start each run in a group of its own. No wait in this script is bare: each names its pid.
pid=""; pid2=""; lpid=""; mpid=""; xpid=""
sweep() { local g i l
  g=$(ps -o pgid= -p $$ 2> /dev/null | tr -d ' ') || g=""
  [ -n "$g" ] || return 0
  i=0; while [ $i -lt 20 ]; do
    l=$(ps -axo pid=,pgid=,command= 2> /dev/null | awk -v g="$g" -v me=$$ -v gh="${GRAALVM_HOME:-/nonexistent}" '
      $2 == g && $1 != me && $3 != "awk" && $3 != "ps" && (index($0, "vminvocation.args") || index($3, gh "/bin/native-image") || index($0, "com.oracle.svm") || $3 ~ /tiffinbox-web\/target\/tiffinbox-web$/ || index($0, "tiffinbox-web-1.0.0.jar") || index($0, "com.tiffinbox.web.TiffinBoxServer") || index($0, "/customers/feed") || index($0, "surefirebooter") || index($0, "org.codehaus.plexus.classworlds.launcher.Launcher")) { print $1 }' | paste -sd' ' -) || l=""
    [ -n "$l" ] || return 0
    if [ $i -lt 10 ]; then kill $l 2> /dev/null || true; else kill -9 $l 2> /dev/null || true; fi
    sleep 0.5; i=$((i + 1)); done; }
# desc PID: every process under PID - its children, theirs, and so on (ps, by parent); killtree PID: PID and all of them, TERM
desc() { ps -axo pid=,ppid= 2> /dev/null | awk -v r="$1" '{ p[$1] = $2 } END { n = 1; q[1] = r; for (i = 1; i <= n; i++) for (c in p) if (p[c] == q[i]) { q[++n] = c; print c } }'; }
killtree() { local d; d=$(desc "$1"); kill "$1" $d 2> /dev/null || true; }
dclean() { [ -n "$OURS" ] || return 0
  docker rm -f "$BOX" > /dev/null 2>&1 || true
  docker image rm -f "$IMG" $(sort -u .harness/imgids 2> /dev/null) > /dev/null 2>&1 || true; }
trap 'trap "" INT TERM; for p in "$mpid" "$xpid"; do [ -z "$p" ] || killtree "$p"; done; for p in "$lpid" "$pid" "$pid2" "$mpid" "$xpid"; do if [ -n "$p" ] && kill "$p" 2> /dev/null; then wait "$p" 2> /dev/null || true; fi; done; sweep || true; dclean || true; [ -z "$INTR" ] || rm -f .r-*.[123]; rmdir .r-lock 2> /dev/null || true' EXIT
INTR=""; trap 'INTR=1; exit 130' INT TERM
exec 3>&1                                            # die() speaks to the terminal even inside a redirected capture
die() { echo "  *** $* ***" >&3; exit 1; }
java -version 2>&1 | grep -q 'version "25' || die "JDK 25 needed; JAVA_HOME gives: $(java -version 2>&1 | head -1)"
for t in python3 curl rsync lsof unzip mvn docker openssl md5 cmp file; do command -v $t > /dev/null || die "$t is needed"; done
# A test's lsof (the harness's Census reads the test server's bind with it) is found through the PATH the test JVM inherits
case ":$PATH:" in *:/usr/sbin:*) ;; *) die "PATH must name /usr/sbin - the test JVM runs lsof from it (README.md, \"Run it\")" ;; esac
# A variable of yours must not become a property source, a JVM flag, a build setting, a native-image option or a docker build
# setting (the problem-detail lesson's loop, verbatim: sed -E, a canary planted under every name first, and the run stops if one
# survives).
for v in TIFFINBOX_CANARY SPRING_CANARY MANAGEMENT_CANARY SERVER_CANARY LOGGING_CANARY COMPOSE_CANARY BUILDKIT_CANARY BUILDX_CANARY DEBUG JAVA_TOOL_OPTIONS JDK_JAVA_OPTIONS _JAVA_OPTIONS MAVEN_OPTS MAVEN_ARGS NATIVE_IMAGE_OPTIONS DOCKER_BUILDKIT DOCKER_DEFAULT_PLATFORM SOURCE_DATE_EPOCH; do export "$v=planted-canary"; done
for v in $(env | sed -n -E 's/^(TIFFINBOX_[A-Za-z0-9_]*|SPRING_[A-Za-z0-9_]*|MANAGEMENT_[A-Za-z0-9_]*|SERVER_[A-Za-z0-9_]*|LOGGING_[A-Za-z0-9_]*|COMPOSE_[A-Za-z0-9_]*|BUILDKIT_[A-Za-z0-9_]*|BUILDX_[A-Za-z0-9_]*|DEBUG|JAVA_TOOL_OPTIONS|JDK_JAVA_OPTIONS|_JAVA_OPTIONS|MAVEN_OPTS|MAVEN_ARGS|NATIVE_IMAGE_OPTIONS|DOCKER_BUILDKIT|DOCKER_DEFAULT_PLATFORM|SOURCE_DATE_EPOCH)=.*/\1/p'); do unset "$v"; done
[ -z "$(env | grep -- '=planted-canary$')" ] || die "a variable survived the clean-up above: $(env | grep -- '=planted-canary$' | sed 's/=.*//' | paste -sd' ' -)"
# Every request this script makes goes to 127.0.0.1: an HTTP proxy named in your environment would carry curl's requests to that
# proxy instead - 127.0.0.1 and localhost go first in no_proxy and NO_PROXY.
export no_proxy="127.0.0.1,localhost${no_proxy:+,$no_proxy}" NO_PROXY="127.0.0.1,localhost${NO_PROXY:+,$NO_PROXY}"
# The GraalVM: named by GRAALVM_HOME, never guessed and never printed (its folder is masked).
GOK=yes
if [ -z "${GRAALVM_HOME:-}" ]; then GOK=no; unset GRAALVM_HOME
  echo "  GRAALVM_HOME is not set: this run fills .m2-demo, makes the captures that need no GraalVM and stops before the native build (README.md, The GraalVM)"
else
  [ -x "$GRAALVM_HOME/bin/native-image" ] || die "GRAALVM_HOME must name a GraalVM JDK 25 (its bin/native-image) - README.md, The GraalVM"
  NIV=$("$GRAALVM_HOME/bin/native-image" --version 2>&1 || true)
  printf '%s\n' "$NIV" | grep -q '^native-image 25\.0\.4\.1 ' && printf '%s\n' "$NIV" | grep -q 'GraalVM CE 25\.3\.4\.1+1\.1' || die "the published captures were made with GraalVM CE 25.3.4.1 (native-image 25.0.4.1); GRAALVM_HOME gives: $(printf '%s\n' "$NIV" | head -1)"
  export GRAALVM_HOME; fi
# Docker: docker info first; OrbStack's orb start only if it does not answer, then a bounded wait (60 s) that names the fix.
if ! docker info > /dev/null 2>&1; then
  command -v orb > /dev/null && { orb start > /dev/null 2>&1 || true; }
  i=0; while ! docker info > /dev/null 2>&1 && [ $i -lt 60 ]; do sleep 1; i=$((i + 1)); done
  docker info > /dev/null 2>&1 || die "Docker does not answer - start it (OrbStack: orb start; Docker Desktop: open it), then run again"; fi
docker image inspect eclipse-temurin:25-jre > /dev/null 2>&1 || die "eclipse-temurin:25-jre is not on this Docker - pull it once (docker pull eclipse-temurin:25-jre: network, a build-time resolution), then run again"
[ -e secrets ] && die "this folder holds a secrets/ - remove it: every run here starts in a folder under .harness/"
[ -L before ] && [ "$(readlink before)" = ../c6-unit28/after ] || die "before must be the link to ../c6-unit28/after - the anchor before this change"
PREV=before
for t in "$PREV" after; do
  [ -f "$t/pom.xml" ] && [ -f "$t/README.md" ] && [ -f "$t/Dockerfile" ] && [ -f "$t/.dockerignore" ] || die "the tree $t (its pom.xml, README.md, Dockerfile or .dockerignore) is missing"
  [ -e "$t/secrets" ] || [ -e "$t/target" ] || [ -e "$t/tiffinbox-web/target" ] || [ -e "$t/tiffinbox-core/target" ] || [ -e "$t/tiffinbox-local.yaml" ] && die "$t holds a secrets/, a target/ or a tiffinbox-local.yaml - it is a frozen copy, never built in place"
  grep -qx 'secrets/' "$t/.dockerignore" || die "$t's .dockerignore no longer keeps secrets/ out of a build context"; done
M2="$PWD/.m2-demo"
TT=tiffinbox-web/src/test/java                      # the web module's test sources, in a tree
MJ=tiffinbox-web/src/main/java/com/tiffinbox/web    # the web module's main sources
CJ=tiffinbox-core/src/main/java/com/tiffinbox       # the core module's sources
SR=tiffinbox-web/target/surefire-reports            # Surefire's reports, in a built tree
JARP=tiffinbox-web/target/tiffinbox-web-1.0.0.jar    # the executable jar, in a tree's web module
BIN=tiffinbox-web/target/tiffinbox-web               # the binary native:compile-no-fork writes, in a tree's web module
TF=secrets/tiffinbox/shutdown-token                  # the config tree's file for tiffinbox.shutdown-token
HVF=META-INF/native-image/org.hibernate.validator/hibernate-validator/9.1.3.Final/reachability-metadata.json   # R.145's file
# The demo token. FAKE, and meant to look it: it guards nothing but a demo server on 127.0.0.1 that every capture stops. It is
# written into .harness/*/secrets/ (git-ignored) when this script runs, and no capture prints it: see mask().
TOKEN=demo-token-for-the-capstone-tour
[ ${#TOKEN} = 32 ] || die "the demo token must be 32 characters: the published captures name its length"
# The tests' token: a literal written in TiffinBoxWebTest, FullStackTest, FeedTest and the harness's StreamWait - not a secret
LIT=not-the-real-token
CURLSET=../c5-unit11/curlset.sh
[ -f "$CURLSET" ] || die "$CURLSET is missing"
OWN=../c6-unit01/README.md                           # the servlet lesson's README: TiffinBox's own server's seven, published
HTS='Census.java StreamWait.java'
for f in harness/shutdown.sh harness/surefire.py harness/import.csv harness/test/resources/META-INF/spring.factories exercise/README.md exercise/customers.csv exercise/solution/SOLUTION.md README.md "$OWN"; do [ -f "$f" ] || die "$f is missing"; done
[ "$(ls harness/test/java/probe/web | paste -sd' ' -)" = "$HTS" ] || die "harness/test/java/probe/web holds another file: Maven compiles all of it"
[ "$(ls harness | paste -sd' ' -)" = 'import.csv shutdown.sh surefire.py test' ] && [ "$(ls harness/test | paste -sd' ' -)" = 'java resources' ] || die "harness/ holds another file"
[ "$(ls exercise | paste -sd' ' -)" = 'README.md customers.csv solution' ] && [ "$(ls exercise/solution | paste -sd' ' -)" = 'SOLUTION.md' ] || die "exercise/ holds another file"
cmp -s harness/shutdown.sh ../c6-unit19/harness/shutdown.sh || die "harness/shutdown.sh is not the CORS lesson's (../c6-unit19/harness/shutdown.sh), byte for byte"
cmp -s harness/surefire.py ../c6-unit28/harness/surefire.py || die "harness/surefire.py is not the testing lesson's (../c6-unit28/harness/surefire.py), byte for byte"
cmp -s harness/test/java/probe/web/Census.java ../c6-unit28/harness/test/java/probe/web/Census.java && cmp -s harness/test/resources/META-INF/spring.factories ../c6-unit28/harness/test/resources/META-INF/spring.factories || die "Census and its spring.factories must be the testing lesson's, byte for byte"
[ "$(cd after/$TT && find . -type f | sed 's#^\./##' | sort | paste -sd' ' -)" = 'com/tiffinbox/web/FeedTest.java com/tiffinbox/web/FullStackTest.java com/tiffinbox/web/TiffinBoxWebTest.java slice/WebSlice.java' ] || die "after/'s test sources hold another file"

listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
for p in 18425 8080 35729 19600 19601 19602 19603 19604 19605 19606 19607 19609; do
  [ "$(listeners $p)" = 0 ] || die "something already listens on $p - this unit's ports must be free; if it is a process an interrupted run left behind, stop it: kill $(lsof -nP -iTCP:$p -sTCP:LISTEN -t 2> /dev/null | paste -sd' ' -)"; done
[ -z "$(docker ps -aq --filter "name=^$BOX\$" 2> /dev/null)" ] || die "a container named $BOX exists - it may be yours, and this script removes only what it creates; remove it yourself (docker rm -f $BOX), then run again"
docker image inspect "$IMG" > /dev/null 2>&1 && die "an image named $IMG exists - it may be yours; remove it yourself (docker image rm $IMG), then run again"
OURS=yes


# ---- the commands: read from after/README.md, the anchor's own, and asserted - each line must be there, whole -------------
readme() { grep -m1 -xF -- "$1" after/README.md > /dev/null || die "after/README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
R_PLAIN=$(readme 'mvn -B package')
R_RUN=$(readme 'java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431')
R_MAP=$(readme 'java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --management.endpoints.web.exposure.include=health,prometheus,mappings')
R_AOTRUN=$(readme 'java -Dspring.aot.enabled=true -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431')
R_GRAAL=$(readme 'export GRAALVM_HOME=/path/to/a/graalvm-jdk-25')
R_INSTALL=$(readme 'mvn -B -Pnative install')
R_NATIVE=$(readme 'mvn -B -Pnative -pl tiffinbox-web native:compile-no-fork')
R_BIN=$(readme 'tiffinbox-web/target/tiffinbox-web --tiffinbox.port=18431')
R_DBUILD=$(readme 'docker build -t tiffinbox-docker:1.0.0 .')
R_DRUN=$(readme 'docker run -d --name tiffinbox -m 512m -v "$PWD/secrets:/app/secrets:ro" -p 127.0.0.1:18431:18425 tiffinbox-docker:1.0.0')
R_READY=$(readme "curl -s -w ' %{http_code}\n' http://127.0.0.1:18431/actuator/health/readiness")
R_PAGE=$(readme "curl -s -H 'Accept: text/html' http://127.0.0.1:18431/dashboard")
R_POST=$(readme "curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '{\"name\":\"Asha\",\"mealsPerDay\":2,\"pricePerMeal\":110,\"mealType\":\"VEG\"}' http://127.0.0.1:18431/customers")
R_FORM=$(readme "curl -s -w ' %{http_code} · Location: [%header{location}]\n' -H 'Content-Type: application/x-www-form-urlencoded' --data 'name=Lata&mealsPerDay=2&pricePerMeal=120&mealType=VEG' http://127.0.0.1:18431/customers")
R_TEST=$(readme 'mvn -B clean test')
R_TESTW=$(readme 'mvn -B -pl tiffinbox-web -Dtest=TiffinBoxWebTest clean test')
# this unit's lines in the anchor's README: the bulk upload and the feed
R_IMPORT=$(readme "curl -s -w ' %{http_code}\n' -F \"file=@customers.csv;type=text/csv\" http://127.0.0.1:18431/customers/import")
R_FEED=$(readme 'curl -s -N http://127.0.0.1:18431/customers/feed')
# This unit's own lines (README.md, "The commands this unit adds") - each asserted to be exactly that
mine() { grep -m1 -xF -- "$1" README.md > /dev/null || die "README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
JL='-Duser.language=en -Duser.country=US'
A61=$(printf 'A%.0s' 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61)
S61=$(printf ' %.0s' 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61)
[ ${#A61} = 61 ] && [ ${#S61} = 61 ] && [ -z "$(printf '%s' "$S61" | tr -d ' ')" ] || die "the 61-letter and 61-space names must be 61 characters"
L_RUNL=$(mine "java $JL -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431")
L_MAPL=$(mine "java $JL -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --management.endpoints.web.exposure.include=health,prometheus,mappings")
L_AOTL=$(mine "java $JL -Dspring.aot.enabled=true -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431")
L_DASH=$(mine 'curl -s http://127.0.0.1:18431/dashboard')
L_BIG=$(mine "curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '{\"name\":\"$A61\",\"mealsPerDay\":2,\"pricePerMeal\":110,\"mealType\":\"VEG\"}' http://127.0.0.1:18431/customers")
L_BIGDE=$(mine "curl -s -w ' %{http_code}\n' -H 'Accept-Language: de' -H 'Content-Type: application/json' --data '{\"name\":\"$A61\",\"mealsPerDay\":2,\"pricePerMeal\":110,\"mealType\":\"VEG\"}' http://127.0.0.1:18431/customers")
L_SPACES=$(mine "curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '{\"name\":\"$S61\",\"mealsPerDay\":2,\"pricePerMeal\":110,\"mealType\":\"VEG\"}' http://127.0.0.1:18431/customers")
L_BIGFORM=$(mine "curl -s -w ' %{http_code} · Location: [%header{location}]\n' -H 'Content-Type: application/x-www-form-urlencoded' --data 'name=$A61&mealsPerDay=2&pricePerMeal=120&mealType=VEG' http://127.0.0.1:18431/customers")
INV='{"name":"","mealsPerDay":0,"pricePerMeal":0,"mealType":"VEG"}'
L_INV=$(mine "curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '$INV' http://127.0.0.1:18431/customers")
L_IMPORT=$(mine "curl -s -w ' %{http_code}\n' -F \"file=@harness/import.csv;type=text/csv\" http://127.0.0.1:18431/customers/import")
L_IMPORTDE=$(mine "curl -s -w ' %{http_code}\n' -H 'Accept-Language: de' -F \"file=@harness/import.csv;type=text/csv\" http://127.0.0.1:18431/customers/import")
L_NOFILE=$(mine "curl -s -w ' %{http_code}\n' -F \"upload=@harness/import.csv;type=text/csv\" http://127.0.0.1:18431/customers/import")
L_CUST=$(mine 'curl -s http://127.0.0.1:18431/customers')
L_MAPS=$(mine 'curl -s http://127.0.0.1:18431/actuator/mappings')            # the mappings lesson's request, its exposure flag on the run line
L_HC=$(mine 'rsync -a harness/test/ .harness/COPY/tiffinbox-web/src/test/')
F_="f=$MJ/CustomerFeed.java"
L_NOEND=$(mine "$F_ && sed '/@EventListener(ContextClosedEvent.class)/d' \"\$f\" > \"\$f.new\" && mv \"\$f.new\" \"\$f\"")
L_STREAM=$(mine 'mvn -B -pl tiffinbox-web -Dtest=StreamWait clean test')
# The derivations, each asserted: one change each, and nothing else
P_='java '; Q_="java $JL "; [ "${R_RUN/"$P_"/$Q_}" = "$L_RUNL" ] && [ "${R_MAP/"$P_"/$Q_}" = "$L_MAPL" ] && [ "${R_AOTRUN/"$P_"/$Q_}" = "$L_AOTL" ] || die "the pinned lines must be the anchor's run lines with $JL after java, and nothing else"
P_=" -H 'Accept: text/html'"; [ "${R_PAGE/"$P_"/}" = "$L_DASH" ] || die "the JSON dashboard line must be the README's page line without its Accept header, and nothing else"
P_='"name":"Asha"'; Q_="\"name\":\"$A61\""; [ "${R_POST/"$P_"/$Q_}" = "$L_BIG" ] || die "the 61-letter POST must be the README's POST with the name made 61 letters, and nothing else"
Q_="\"name\":\"$S61\""; [ "${R_POST/"$P_"/$Q_}" = "$L_SPACES" ] || die "the 61-space POST must be the README's POST with the name made 61 spaces, and nothing else"
P_=" -H 'Content-Type"; Q_=" -H 'Accept-Language: de' -H 'Content-Type"; [ "${L_BIG/"$P_"/$Q_}" = "$L_BIGDE" ] || die "the de POST must be the 61-letter POST with Accept-Language: de, and nothing else"
P_='name=Lata&'; Q_="name=$A61&"; [ "${R_FORM/"$P_"/$Q_}" = "$L_BIGFORM" ] || die "the 61-letter form must be the README's form line with the name made 61 letters, and nothing else"
P_="--data '{\"name\":\"Asha\",\"mealsPerDay\":2,\"pricePerMeal\":110,\"mealType\":\"VEG\"}'"; Q_="--data '$INV'"; [ "${R_POST/"$P_"/$Q_}" = "$L_INV" ] || die "the invalid POST must be the README's POST with the slice test's invalid customer, and nothing else"
P_='file=@customers.csv'; Q_='file=@harness/import.csv'; [ "${R_IMPORT/"$P_"/$Q_}" = "$L_IMPORT" ] || die "the upload line must be the README's with the harness's file, and nothing else"
Q_='upload=@harness/import.csv'; [ "${R_IMPORT/"$P_"/$Q_}" = "$L_NOFILE" ] || die "the no-file line must be the README's with the harness's file in a part named upload, and nothing else"
P_=" -F "; Q_=" -H 'Accept-Language: de' -F "; [ "${L_IMPORT/"$P_"/$Q_}" = "$L_IMPORTDE" ] || die "the de upload must be the upload line with Accept-Language: de, and nothing else"
P_=' -H '"'"'Accept: text/html'"'"' http://127.0.0.1:18431/dashboard'; Q_=' http://127.0.0.1:18431/customers'; [ "${R_PAGE/"$P_"/$Q_}" = "$L_CUST" ] || die "the list line must be the README's page line asking /customers without its header, and nothing else"
P_=' -Dtest=TiffinBoxWebTest '; Q_=' -Dtest=StreamWait '; [ "${R_TESTW/"$P_"/$Q_}" = "$L_STREAM" ] || die "the StreamWait line must be the README's test line with another -Dtest, and nothing else"
off() { local c=${2/mvn -B /mvn -o -B -Dmaven.repo.local=\"\$M2\" }
  [ -n "${3:-}" ] && c=${c/ $3/ clean $3}
  printf 'cd %s && %s\n' "$1" "$c"; }
dev() { local c=${1#cd * && }; c=${c/ -o -B -Dmaven.repo.local=\"\$M2\" / -B }; c=${c/ clean package/ package}; c=${c/ clean install/ install}; printf '%s\n' "$c"; }
for c in "$(off .harness/x "$R_INSTALL" install)" "$(off .harness/x "$R_PLAIN" package)" "$(off .harness/x "$R_NATIVE")" "$(off .harness/x "$R_TESTW")" "$(off .harness/x "$R_TEST")" "$(off .harness/x "$L_STREAM")"; do
  r=$(dev "$c"); [ "$r" = "$R_PLAIN" ] || [ "$r" = "$R_INSTALL" ] || [ "$r" = "$R_NATIVE" ] || [ "$r" = "$R_TESTW" ] || [ "$r" = "$R_TEST" ] || [ "$r" = "$L_STREAM" ] || die "not a README line with the offline changes: $c"; done
# at DIR PORT 'README LINE': the README's line run from DIR, its port 18431 made PORT - a java line with the JVM's locale pinned
at() { local l=${3/--tiffinbox.port=18431/--tiffinbox.port=$2}; case $l in "java $JL "*) ;; 'java '*) l="java $JL ${l#java }" ;; esac; printf 'cd %s && %s\n' "$1" "$l"; }
url() { printf '%s\n' "${1/:18431\//:$2/}"; }
exe() { printf '%s\n' "$1" | sed -E 's/&& (([A-Z_]+=[^ ]* )*)/\&\& \1exec /'; }
UARG='--user "$(id -u):$(id -g)"'
dbuild() { local c=${R_DBUILD/docker build -t tiffinbox-docker:1.0.0 /docker build --progress=plain -t $IMG }; printf 'cd %s && %s\n' "$1" "$c"; }
drun() { local c=${R_DRUN/--name tiffinbox /--name $BOX $UARG }; c=${c/127.0.0.1:18431:18425/127.0.0.1:$2:18425}; c=${c/% tiffinbox-docker:1.0.0/ $IMG}; printf 'cd %s && %s\n' "$1" "$c"; }
undock() { local c=${1#cd * && }; c=${c/--progress=plain /}; c=${c/" $UARG"/}; c=${c//$IMG/tiffinbox-docker:1.0.0}; c=${c/--name $BOX /--name tiffinbox }; c=${c/127.0.0.1:1960?:18425/127.0.0.1:18431:18425}; printf '%s\n' "$c"; }
[ "$(undock "$(dbuild .harness/x)")" = "$R_DBUILD" ] || die "not the README's build line with the declared changes: $(dbuild .harness/x)"
[ "$(undock "$(drun .harness/x 19603)")" = "$R_DRUN" ] || die "not the README's run line with the declared changes: $(drun .harness/x 19603)"
[ "$(exe "$(at .harness/x 19600 "$R_RUN")")" = "cd .harness/x && exec ${L_RUNL/18431/19600}" ] && [ "$(at .harness/x 19601 "$R_AOTRUN")" = "cd .harness/x && ${L_AOTL/18431/19601}" ] && [ "$(at .harness/x 19604 "$R_MAP")" = "cd .harness/x && ${L_MAPL/18431/19604}" ] && [ "$(at .harness/x 19602 "$R_BIN")" = 'cd .harness/x && tiffinbox-web/target/tiffinbox-web --tiffinbox.port=19602' ] || die "at(): the pinned lines are not README.md's, or the binary's line got the JVM's options"
echo "  the commands: after/README.md gives the $(grep -c '^R_[A-Z]*=$(readme ' receipts.sh) lines this script runs or derives from; README.md the $(grep -c '^L_[A-Z]*=$(mine ' receipts.sh) this unit adds"
JV=$(java -version 2>&1 | sed -n 's/.*version "\([^"]*\)".*/\1/p' | head -1)
echo "  (terminal only) the JDK is $JV - Boot's first line names it; the captures say Java <version>" >&3
# ---- build: before the captures - after/'s native-profile install (it fills .m2-demo on a fresh clone, runs the tests, and puts
# ---- both modules into $M2), then after/ and the previous tree with the README's package line (each runs its tree's tests) ----
rm -rf .harness; mkdir -p .harness; : > .harness/imgids
ZIP="$M2/org/graalvm/buildtools/graalvm-reachability-metadata/1.1.8/graalvm-reachability-metadata-1.1.8-repository.zip"
ghub() { grep -qE 'Downloaded GraalVM reachability metadata repository from http|Failed to download from http' "$1"; }
mbuild() { local how=yes ec=0 c=$1
  case $c in *' -Pnative '*) [ -f "$ZIP" ] || { c=${c/mvn -o -B /mvn -B }; how="no - GraalVM's metadata repository was not in .m2-demo, so Maven Central was asked for it"; } ;; esac
  (eval "$c") > "$2" 2>&1 < /dev/null & mpid=$!; wait "$mpid" || ec=$?; mpid=""
  if [ $ec != 0 ] && [ "$how" = yes ] && grep -qE 'offline mode|Could not resolve|could not be resolved|Cannot access|No plugin found for prefix' "$2"; then
    how="no - the offline build could not resolve an artifact, so Maven Central was asked"; ec=0
    (eval "${c/mvn -o -B /mvn -B }") > "$2" 2>&1 < /dev/null & mpid=$!; wait "$mpid" || ec=$?; mpid=""; fi
  if ghub "$2"; then echo "  built $3 · offline: no - GraalVM's native plugin went to GitHub for its metadata repository · exit $ec"
    die "$3: GraalVM's native plugin went over the network for its metadata repository - README.md, The repository"; fi
  [ $ec = 0 ] || { tail -30 "$2" >&3
    ! grep -qE 'Could not resolve|could not be resolved|Could not transfer|Cannot access' "$2" || die "build failed: $3 - Maven could resolve Boot's parent and plugins neither from .m2-demo nor from Maven Central: a fresh clone's first run needs the network once, to fill .m2-demo"
    die "build failed: $3"; }
  echo "  built $3 · offline: $how · exit $ec"; }
# tree FOLDER: a config tree in FOLDER/secrets holding one file, the demo token and a newline, readable by its owner alone
tree() { mkdir -p "$1/secrets/tiffinbox"; (umask 077 && printf '%s\n' "$TOKEN" > "$1/$TF"); chmod 700 "$1/secrets" "$1/secrets/tiffinbox"; }
copy() { rm -rf "$2" "$2".*; rsync -a --exclude target --exclude secrets "$1/" "$2/"; tree "$2"; }
rsync -a --exclude target --exclude secrets after/ .harness/pre/
C_PRE=$(off .harness/pre "$R_INSTALL" install)
mbuild "$C_PRE" .harness/build-pre.log ".harness/pre (after/, the profile native, both modules into \$M2; the tests ran)"
for a in org/springframework/boot/spring-boot-starter-webmvc-test/4.1.1/spring-boot-starter-webmvc-test-4.1.1.pom org/springframework/boot/spring-boot-web-server/4.1.1/spring-boot-web-server-4.1.1.jar org/graalvm/buildtools/native-maven-plugin/1.1.8/native-maven-plugin-1.1.8.jar com/tiffinbox/tiffinbox-core/1.0.0/tiffinbox-core-1.0.0.jar; do
  [ -e "$M2/$a" ] || die "$a is not in .m2-demo after the first build - README.md, The repository"; done
[ -f "$ZIP" ] || die "GraalVM's metadata repository is not in .m2-demo after the first build - README.md, The repository"
copy "$PREV" .harness/before; copy after .harness/after
mbuild "$(off .harness/before "$R_PLAIN" package)" .harness/build-before.log ".harness/before (the previous tree, the README's package line; its tests ran)"
mbuild "$(off .harness/after "$R_PLAIN" package)" .harness/build-after.log ".harness/after (after/, the README's package line; its tests ran)"
echo "  .m2-demo holds Boot's test starter for MVC, GraalVM's native plugin 1.1.8 and its metadata repository, and TiffinBox's two modules"

# ---- helpers ------------------------------------------------------------------------------------------------------------
raw() { local t=$1; shift; cat "$@" 2> /dev/null | LC_ALL=C grep -aoF -- "$t" | wc -l | tr -d ' '; }
LOGS=0; CLOGS=0; MLOGS=0; LASTE=""
first() { grep -m1 -E ' : Starting |^main Starting ' "$1" | sed 's/^.* : //; s/^main //; s/ with PID .*$//; s/ using Java [0-9][0-9.]*/ using Java <version>/'; }
# R.158: the folder a start runs in must hold, in secrets/, the token's file and nothing else - a file there is a key
sec() { local s; s=$(cd "$1/secrets" 2> /dev/null && find . -type f | sed 's#^\./##' | sort | paste -sd' ' -)
  [ "$s" = tiffinbox/shutdown-token ] || die "$1/secrets holds more than the token's file (${s:-nothing}) - every file there is a key (R.158)"
  echo "  secrets/ before the start: $s - the token's file, and nothing else"; }
dir() { printf '%s\n' "$1" | sed -n 's/^cd \([^ ]*\) && .*/\1/p'; }
start() { sec "$(dir "$1")"; echo "\$ $1"; (eval "$(exe "$1")") > .harness/run.out 2> .harness/run.err < /dev/null & pid=$!; }
addrs() { lsof -nP -a -p "$1" -iTCP -sTCP:LISTEN 2> /dev/null | awk 'NR > 1 { print $9 }' | sort -u | paste -sd' ' -; }
listening() { local a="" i=0
  while [ $i -lt 480 ]; do a=$(addrs "$1"); case " $a " in *":$2 "*) break ;; esac; kill -0 "$1" 2> /dev/null || break; sleep 0.25; i=$((i + 1)); done
  echo "${a:-nothing}"; }
lb() { local a n=0; for a in $1; do n=$((n + 1)); case $a in 127.0.0.1:*) ;; *) echo no; return ;; esac; done; [ $n -gt 0 ] && echo yes || echo no; }
# up PORT: the server $pid listens on PORT, loopback only; Boot's first line
up() { local l; l=$(listening "$pid" "$1"); [ "$l" != nothing ] || { tail -20 .harness/run.out >&3; die "it never listened on $1"; }
  case " $l " in *':8080 '*|*':35729 '*|*':19609 '*) kill -9 "$pid" 2> /dev/null || true; die "it listened on 8080, 35729 or 19609 - never bound by this script";; esac
  echo "  listens on: $l · loopback only: $(lb "$l")"; echo "  Boot's first line: $(first .harness/run.out)"; }
sortj() { python3 -c '
import json, re, sys
for l in sys.stdin.read().splitlines():
    b, _, s = l.rpartition(" ")
    try: o = json.dumps(json.loads(b), sort_keys=True, separators=(",", ":"), ensure_ascii=False)
    except ValueError: print("  " + l); continue
    print("  " + o + " " + s + ("    (keys sorted)" if o != b else ""))'; }
askj() { local c; c=$(url "$1" "$2"); echo "\$ $c"; (eval "$c") 2>&1 < /dev/null | tsmask | sortj; }
ready() { local i=0 c=""
  while [ $i -lt 480 ]; do c=$(curl -s -o /dev/null -w '%{http_code}' "http://127.0.0.1:$1/actuator/health/readiness" 2> /dev/null || true); [ "$c" = 200 ] && break
    if [ -n "$pid" ]; then kill -0 "$pid" 2> /dev/null || { tail -20 .harness/run.out >&3; die "it exited before readiness answered 200"; }; fi
    if [ -n "${2:-}" ]; then [ "$(docker inspect -f '{{.State.Running}}' "$2" 2> /dev/null)" = true ] || { docker logs "$2" 2>&1 | tail -20 >&3; die "the container exited before readiness answered 200"; }; fi
    sleep 0.25; i=$((i + 1)); done
  [ "$c" = 200 ] || die "readiness never answered 200 on $1"
  askj "$R_READY" "$1"; }
logtok() { local t h; t=$(raw "$TOKEN" "${1:-.harness/run.out}" "${2:-.harness/run.err}"); h=$(cat "${1:-.harness/run.out}" "${2:-.harness/run.err}" | LC_ALL=C grep -aoi -- 'x-shutdown-token' | wc -l | tr -d ' ')
  LOGS=$((LOGS + 1)); [ "$t" = 0 ] && [ "$h" = 0 ] || die "a log held the demo token ($t) or its header's name ($h)"
  echo "  its log: the demo token 0 times · X-Shutdown-Token $h times"; }
tsmask() { awk '{ gsub(/"timestamp":"[^"]*"/, "\"timestamp\":\"…\""); gsub(/"timestamp":[0-9]+/, "\"timestamp\":…"); print }'; }
# gone PORT [SECONDS]: the server $pid exits within SECONDS (15 unless named) of POST /shutdown; its exit code in LASTE
gone() { local i=0 e=0 n=$(( ${2:-15} * 4 ))
  while kill -0 "$pid" 2> /dev/null && [ $i -lt $n ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$pid" 2> /dev/null && { kill "$pid"; die "the server on $1 was still running ${2:-15} s after POST /shutdown"; }
  wait "$pid" || e=$?; pid=""; LASTE=$e
  [ "$(listeners "$1")" = 0 ] || die "something still listens on $1"; }
seven() { local m
  echo "\$ \$CURLSET $1 $2/$TF"
  "$CURLSET" "$1" "$2/$TF" | grep ' -> ' > .harness/responses.txt || true
  tsmask < .harness/responses.txt > .harness/responses.m.txt
  grep '^POST ' .harness/responses.m.txt | sed 's/^/  /' || echo "  (no POST line)"
  gone "$1"
  m=$(diff .harness/responses.txt .harness/responses.m.txt | grep -c '^<' || true)
  echo "  exit $LASTE · the seven responses: $(wc -l < .harness/responses.m.txt | tr -d ' ') lines · lines the timestamp mask changed: $m · md5 $(md5 -q .harness/responses.m.txt)"
  logtok; }
post() { echo "\$ harness/shutdown.sh $1 $2/$TF"; harness/shutdown.sh "$1" "$2/$TF" | tsmask | sed 's/^/  /'; }
stop() { post "$1" "$2"; gone "$1" "${3:-15}"; echo "  exit $LASTE · listening on $1 now: 0"; logtok; }
lvl() { grep -cE "^[0-9]{4}-[0-9]{2}-[0-9]{2}T[^ ]+ +$1 " "$2" || true; }
# blog FILE 'LOGGER|LOGGER…': the lines of Boot's log format whose logger matches, in order - level, logger, message (an identity
# hash "@…"; a message over 200 characters cut there, the rest counted); then the file's WARN and ERROR lines, counted
blog() { awk -v pat="$2" '
  /^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T[^ ]+ +[A-Z]+ [0-9]+ --- \[/ { s = $0; i = index(s, " --- ["); s = substr(s, i + 6); i = index(s, "] "); s = substr(s, i + 2)
    i = index(s, " : "); lg = substr(s, 1, i - 1); sub(/ +$/, "", lg); m = substr(s, i + 3)
    if (lg !~ pat) next
    gsub(/@[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]+/, "@…", m); if (length(m) > 200) m = substr(m, 1, 200) " … (" length(m) - 200 " more characters)"
    print "    " $2 " " lg ": " m }' "$1"
  echo "  its log's WARN lines: $(lvl WARN "$1") · ERROR lines: $(lvl ERROR "$1")"; }
SHUTL='GracefulShutdown|DefaultLifecycleProcessor'
mask() { awk -v t="$TOKEN" -v g="${GRAALVM_HOME:-}" -v u="$U" -v up="$UP" -v hm="$HOME" -v me="$ME" -v tl="${#TOKEN}" '
  function lit(x) { gsub(/[][\\.^$*+?(){}|\/]/, "\\\\&", x); return x }
  function enc(x) { gsub(/ /, "%20", x); return x }
  BEGIN { T = lit(t); G = lit(g); GE = lit(enc(g)); P = lit(u); Q = lit(up); H = lit(hm); PE = lit(enc(u)); QE = lit(enc(up)); M = "(^|[^A-Za-z0-9_])" lit(me) "([^A-Za-z0-9_]|$)" }
  { gsub(T, "[masked: the " tl "-character token]"); if (g != "") { gsub(G, "$GRAALVM_HOME"); gsub(GE, "$GRAALVM_HOME") }; gsub(P, "…"); gsub(PE, "…")
    gsub(Q, "…/.."); gsub(QE, "…/.."); gsub(H, "~"); gsub(/\$\$SpringCGLIB\$\$[0-9]+/, "$$SpringCGLIB$$<n>")
    gsub(/tomcat-handler-[0-9]+/, "tomcat-handler-<n>"); gsub(/ using Java [0-9][0-9.]+/, " using Java <version>")
    gsub(/http-nio-127\.0\.0\.1-[0-9]+/, "http-nio-127.0.0.1-<port>")
    while (match($0, M)) { pre = substr($0, 1, RSTART - 1); s = substr($0, RSTART, RLENGTH); post = substr($0, RSTART + RLENGTH)
      sub(lit(me), "<user>", s); $0 = pre s post }
    print }'; }
printf '%s\n' 'Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1' 'Tomcat initialized: http-nio-127.0.0.1-19600' "$TOKEN" > .harness/p1
[ "$(mask < .harness/p1)" = "$(printf '%s\n' 'Starting TiffinBoxServer v1.0.0 using Java <version>' 'Tomcat initialized: http-nio-127.0.0.1-<port>' '[masked: the 32-character token]')" ] || die "mask: the planted JDK version, connector name and token must be masked"
# listen PORT FILE: the README's listener line, curl -N, writing to FILE, its pid $lpid; connected when its first line, the feed's
# comment, is in FILE (bounded: 60 s). lend [SECONDS]: the listener exits within SECONDS (15 unless named), its exit code printed
listen() { local c i=0; c="$(url "$R_FEED" "$1") > $2"; echo "\$ $c &"
  (eval "exec $c") 2> /dev/null < /dev/null & lpid=$!
  while [ "$(head -1 "$2" 2> /dev/null)" != ':listening' ] && [ $i -lt 240 ]; do kill -0 "$lpid" 2> /dev/null || break; sleep 0.25; i=$((i + 1)); done
  [ "$(head -1 "$2" 2> /dev/null)" = ':listening' ] || die "the listener on $1 never read the feed's first line"
  echo "  the listener (curl, waited for by its pid): its first line - $(head -1 "$2") - the feed's comment: connected"; }
lend() { local i=0 e=0 n=$(( ${1:-15} * 4 ))
  while kill -0 "$lpid" 2> /dev/null && [ $i -lt $n ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$lpid" 2> /dev/null && { kill "$lpid"; die "the listener was still running ${1:-15} s after the server stopped"; }
  wait "$lpid" || e=$?; lpid=""; echo "  the listener ended: curl exit $e"; }
# events FILE: what the listener read, line by line (a blank line shown as such), then counted
events() { echo "  what it read ($2), every line:"; awk '{ print "    " ($0 == "" ? "(blank)" : $0) }' "$1"
  echo "  events named customer-added: $(grep -c '^event:customer-added$' "$1" || true) · data lines: $(grep -c '^data:' "$1" || true) · id lines: $(grep -c '^id:' "$1" || true) · comment lines: $(grep -c '^:' "$1" || true)"; }

unpub=""
cap() { local nm=$1 h pub i; shift
  for i in 1 2 3; do "$@" > .harness/cap.raw 2>&1 || true; [ -z "$pid$pid2$lpid$mpid$xpid" ] || die "$nm left a process running"
    [ -z "$(docker ps -aq --filter "name=^$BOX\$")" ] || die "$nm left a container"
    raw "$TOKEN" .harness/cap.raw > ".harness/raw-$nm.$i"; mask < .harness/cap.raw > ".r-$nm.$i"; done
  h=$(md5 -q ".r-$nm.1")
  [ "$h" = "$(md5 -q ".r-$nm.2")" ] && [ "$h" = "$(md5 -q ".r-$nm.3")" ] || die "$nm drifts across three runs (diff .r-$nm.1 .r-$nm.2 .r-$nm.3)"
  mv ".r-$nm.1" ".r-$nm.out"; rm -f ".r-$nm.2" ".r-$nm.3"
  pub=$(awk -v n="$nm" '$1 == n { print $2 }' receipts.md5 2> /dev/null || true)
  if [ -z "$pub" ]; then printf '  %-10s md5 %s  3/3  (no published hash)\n' "$nm" "$h"; unpub="$unpub $nm"
  elif [ "$pub" = "$h" ]; then printf '  %-10s md5 %s  3/3  = published\n' "$nm" "$h"
  else printf '  %-10s md5 %s  3/3  DIFFERS from the published %s\n' "$nm" "$h" "$pub"
    die "$nm is not the published capture - suspect another JDK, GraalVM, Boot, Maven or Docker, another base image, a busy machine, a busy port, a variable of yours, or an edited source; diff .r-$nm.out against its block in README.md"; fi; }
# hcopy NAME: after/ copied to .harness/NAME, the harness's test sources and resources added to its web module (this unit's line)
hcopy() { local c=${L_HC/COPY/$1}; copy after ".harness/$1"; echo "\$ $c"; (eval "$c") < /dev/null || die "$c failed"
  echo "  the copy's test sources now: $(cd ".harness/$1/$TT" && find . -name '*.java' | sed 's#^\./##' | sort | sed 's#.*/##' | paste -sd' ' -) · its test resources: $(cd ".harness/$1/tiffinbox-web/src/test/resources" && find . -type f | sed 's#^\./##' | paste -sd' ' -)"; }
lines() { if [ -f "$1" ]; then wc -l < "$1" | tr -d ' '; else echo none; fi; }
cdiff() { diff -U0 "$1" "$2" | tail -n +3 > .harness/code.diff || true
  echo "  its diff (diff -U0, its file names cut) - hunks: $(grep -c '^@@ ' .harness/code.diff || true) · lines out: $(grep -c '^-' .harness/code.diff || true) · in: $(grep -c '^+' .harness/code.diff || true) - whole:"
  sed 's/^/    /' .harness/code.diff; }

# ---- a Maven run of the tests, read: its command, its BUILD line, Surefire's reports (surefire.py), the console's summary beside
# ---- them, the harness's lines, Surefire's line about a fork that would not exit, its WARN and ERROR records, Mockito's and the
# ---- JVM's lines (counted), what was not shown; the tokens counted
# summ LOG: Surefire's console summary - its last "Tests run:" line without " -- in " (the Results line), its four numbers
summ() { grep -E '^\[(INFO|ERROR|WARNING)\] Tests run: [0-9]+, Failures: [0-9]+, Errors: [0-9]+, Skipped: [0-9]+$' "$1" | tail -1 | sed -E 's/.*Tests run: ([0-9]+), Failures: ([0-9]+), Errors: ([0-9]+), Skipped: ([0-9]+)$/tests \1 · failures \2 · errors \3 · skipped \4/'; }
HL='^(CENSUS|EXCHANGE) '
# dec: the harness prints ASCII (the test JVM's console under LC_ALL=C is), each other character as a backslash, u and four hex
# digits (Census.print); this turns each back into its character, UTF-8 - nothing else in a line changes
dec() { python3 -c 'import re, sys; sys.stdout.buffer.write(re.sub(r"\\u([0-9a-f]{4})", lambda m: chr(int(m.group(1), 16)), sys.stdin.buffer.read().decode("ascii")).encode("utf-8"))'; }
JVMLINES='^(Mockito is currently self-attaching|WARNING: |OpenJDK 64-Bit Server VM warning: )'
KILLED='Surefire is going to kill self fork JVM'
# recs LOG: every WARN and ERROR record of Boot's log format in a Maven log: level, logger, message; the exception line under it; its
# frames counted (bounded) and its other lines counted. A record ends at the next log line, Maven line or harness line. An object's
# identity hash (@1a2b3c…) becomes "@…"; a message or exception line over 200 characters is cut there, the rest counted.
recs() { awk '
  function out() { if (inr) print "      its stack frames: " (fr > 40 ? "over 40" : fr + 0) ", its other lines: " (ot + 0) " - none shown"; inr = 0; fr = 0; ot = 0; ex = 0 }
  /^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T[^ ]+ +[A-Z]+ [0-9]+ --- \[/ || /^\[(INFO|ERROR|WARNING)\]/ || /^(CENSUS|EXCHANGE) / || /^(Mockito is currently self-attaching|WARNING: |OpenJDK 64-Bit Server VM warning: )/ { out() }
  /^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T[^ ]+ +(WARN|ERROR) [0-9]+ --- \[/ { s = $0; i = index(s, " --- ["); s = substr(s, i + 6); i = index(s, "] "); s = substr(s, i + 2)
    i = index(s, " : "); lg = substr(s, 1, i - 1); sub(/ +$/, "", lg); m = substr(s, i + 3); gsub(/@[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]+/, "@…", m)
    if (length(m) > 200) m = substr(m, 1, 200) " … (" length(m) - 200 " more characters)"
    print "    " $2 " " lg ": " m; inr = 1; ex = 1; next }
  inr && /^\tat / { fr++; next }
  inr && ex && NF > 0 { x = $0; gsub(/@[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]+/, "@…", x); if (length(x) > 200) x = substr(x, 1, 200) " … (" length(x) - 200 " more characters)"; print "      " x; ex = 0; next }
  inr { ot++ }
  END { out() }' "$1"; }
# mrun NAME DIR 'COMMAND': COMMAND run in DIR (Maven started in the background and waited for by its pid, so an interrupt stops it
# and its test JVM); then the reading above
MRE=0
mrun() { local c="cd $2 && $3" e=0 n s t
  echo "\$ $c"
  (eval "$c") > ".harness/$1.log" 2>&1 < /dev/null & mpid=$!; wait "$mpid" || e=$?; mpid=""; MRE=$e
  if ghub ".harness/$1.log"; then die "$1: GraalVM's native plugin went over the network"; fi
  n=$(grep -cE '^\[INFO\] Download(ing|ed) from ' ".harness/$1.log" || true)
  echo "  exit $e · $(grep -m1 -oE 'BUILD (SUCCESS|FAILURE)' ".harness/$1.log" || echo 'no BUILD line') · offline: $( [ "$n" = 0 ] && echo yes || echo "no - $n lines say Maven downloaded")"
  echo "  Surefire's reports ($SR, read by harness/surefire.py):"
  python3 -I harness/surefire.py "$2/$SR" | sed 's/^/  /'
  s=$(summ ".harness/$1.log"); t=$(python3 -I harness/surefire.py "$2/$SR" | sed -n 's/^  in all: [0-9]* reports · //p')
  echo "  Surefire's console summary (its Results line): ${s:-none} · the reports' sum the same: $( [ -n "$s" ] && [ "$s" = "$t" ] && echo yes || echo no)"
  echo "  Surefire's own lines that a fork would not exit ($KILLED …): $(grep -c "$KILLED" ".harness/$1.log" || true)"
  if grep -qE "$HL" ".harness/$1.log"; then echo "  the harness's lines, in the order they ran (CENSUS sorted by test class; its \\u escapes decoded):"
    grep -E '^CENSUS ' ".harness/$1.log" | sort -s -k2,2 | dec | sed 's/^/    /'
    grep -E '^EXCHANGE ' ".harness/$1.log" | dec | sed 's/^/    /'; fi
  echo "  Mockito's lines: $(grep -c '^Mockito is currently self-attaching' ".harness/$1.log" || true) · the JVM's (WARNING: …, OpenJDK 64-Bit Server VM warning: …): $(grep -cE '^(WARNING: |OpenJDK 64-Bit Server VM warning: )' ".harness/$1.log" || true) - printed by Mockito and the JVM, not by a logger; not shown"
  echo "  its log's WARN lines: $(lvl WARN ".harness/$1.log") · ERROR lines: $(lvl ERROR ".harness/$1.log")$( [ "$(lvl WARN ".harness/$1.log")$(lvl ERROR ".harness/$1.log")" = 00 ] || echo ' - each record:')"
  recs ".harness/$1.log"
  echo "  its other lines: $(grep -cvE "$HL|$JVMLINES|$KILLED|^[0-9]{4}-[0-9]{2}-[0-9]{2}T[^ ]+ +(WARN|ERROR) |^\[(INFO|ERROR|WARNING)\] (BUILD |Tests run: )" ".harness/$1.log" || true) - Maven's, Boot's banner and INFO lines, the frames above - not shown"
  t=$(raw "$TOKEN" ".harness/$1.log" "$2/$SR"/*); MLOGS=$((MLOGS + 1))
  [ "$t" = 0 ] || die "$1: the demo token is in the Maven log or a Surefire report ($t)"
  echo "  the demo token in the Maven log and every report: 0 times · the tests' literal, $LIT (written in the tests, not a secret): $(raw "$LIT" ".harness/$1.log" "$2/$SR"/*) times"; }

# ---- tour: the boxes, one path two answers, the routes -------------------------------------------------------------------------
tour() {
  echo "TiffinBox's classes - every .java file in after/'s main sources, both modules: the annotations on its declaration (the lines above it), its kind:"
  python3 - after <<'PY'
import os, re, sys
root = sys.argv[1]
files = []
for mod in ("tiffinbox-core", "tiffinbox-web"):
    base = os.path.join(root, mod, "src/main/java")
    for d, _, fs in os.walk(base):
        files += [os.path.join(d, f) for f in fs if f.endswith(".java")]
count = {}
rows = []
for f in sorted(files, key=lambda p: os.path.basename(p)):
    lines = open(f, encoding="utf-8").read().split("\n")
    for i, l in enumerate(lines):
        m = re.match(r"^(?:public |final |abstract )*(class|record|enum|interface|@interface) (\w+)", l)
        if m: break
    else:
        rows.append("  %s: no type declaration found" % os.path.basename(f)); continue
    ann, j = [], i - 1
    while j >= 0 and lines[j].startswith("@"):
        ann.insert(0, re.match(r"@(\w+)", lines[j]).group(1)); j -= 1
    for a in ann: count[a] = count.get(a, 0) + 1
    rows.append("  %s (%s, %s): %s" % (m.group(2), m.group(1), "core" if "/tiffinbox-core/" in f else "web", " ".join("@" + a for a in ann) or "no annotation"))
print("\n".join(rows))
print("  TiffinBox's classes: %d (core %d, web %d)" % (len(rows), sum(1 for f in files if "/tiffinbox-core/" in f), sum(1 for f in files if "/tiffinbox-web/" in f)))
print("  each annotation, counted: " + " · ".join("@%s %d" % (k, count[k]) for k in sorted(count)))
PY
  echo "  @Service, @Repository, @Entity anywhere in after/'s sources (an annotation line, main and test): @Service $(grep -rhE '^ *@Service\b' after/tiffinbox-*/src | grep -c . || true) · @Repository $(grep -rhE '^ *@Repository\b' after/tiffinbox-*/src | grep -c . || true) · @Entity $(grep -rhE '^ *@Entity\b' after/tiffinbox-*/src | grep -c . || true)"
  echo "  Customer, as tiffinbox-core declares it: $(grep -m1 -E '^public record Customer' after/$CJ/Customer.java | sed 's/(.*//')"
  echo "the four boxes - controller · service · repository · entity - and what after/ has in each:"
  echo "  controller: $(grep -lE '^@(Rest)?Controller$' after/$MJ/*.java | sed 's#.*/##; s#\.java$##' | paste -sd' ' -) - by Spring's own annotation (@Controller, @RestController); the advice beside them: $(grep -lE '^@RestControllerAdvice$' after/$MJ/*.java | sed 's#.*/##; s#\.java$##')"
  echo "  service: a class named …Service: $(find after/tiffinbox-*/src/main -name '*Service.java' | grep -c . || true) · annotated @Service: 0 (above) - the work sits in $(grep -lE '^@Component$' after/$CJ/Dashboard.java after/$CJ/OrderQueue.java | sed 's#.*/##; s#\.java$##' | paste -sd' ' -), each a @Component"
  echo "  repository: $(find after/tiffinbox-*/src/main -name '*Repository.java' | sed 's#.*/##; s#\.java$##' | paste -sd' ' -) - the word in TiffinBox's own class name; its annotation: $(awk '/^@/ { a = $0 } /^public final class CustomerRepository/ { print a; exit }' after/$CJ/CustomerRepository.java)"
  echo "  entity: Customer - a record; annotated @Entity: 0 (above)"
  echo "one path, two answers, and the routes - after/'s jar, the routes exposed for this run (the mappings lesson's line), port 19604:"
  start "$(at .harness/after 19604 "$R_MAP")"; up 19604; ready 19604
  echo "\$ $(url "$R_PAGE" 19604)"; curl -s -H 'Accept: text/html' http://127.0.0.1:19604/dashboard > .harness/page.html < /dev/null || true
  echo "  the page: <title>$(sed -n 's/.*<title>\([^<]*\)<\/title>.*/\1/p' .harness/page.html | head -1)</title> · its table's rows: $(grep -c '<tr' .harness/page.html || true) - the rest of it not shown"
  askj "$L_DASH" 19604
  echo "\$ $(url "$L_MAPS" 19604)"; curl -s http://127.0.0.1:19604/actuator/mappings > .harness/mappings.json < /dev/null || true
  python3 - .harness/mappings.json <<'PY'
import json, sys
d = json.load(open(sys.argv[1]))
rows = []
for c in d["contexts"].values():
    rows += c["mappings"].get("dispatcherServlets", {}).get("dispatcherServlet", [])
mine = []
for r in rows:
    h = ((r.get("details") or {}).get("handlerMethod") or {})
    if h.get("className", "").startswith("com.tiffinbox"):
        mine.append((h["className"].rsplit(".", 1)[1], h["name"], r["predicate"]))
print("  the routing table (dispatcherServlet's rows): %d · TiffinBox's (a handler method in com.tiffinbox): %d · the others (Actuator's, Boot's /error, the static files): %d" % (len(rows), len(mine), len(rows) - len(mine)))
by = {}
for k, n, p in sorted(mine, key=lambda x: (x[0], x[2])):
    by[k] = by.get(k, 0) + 1
    print("    %s#%s  %s" % (k, n, p))
print("  by class: " + " · ".join("%s %d" % (k, by[k]) for k in sorted(by)))
PY
  stop 19604 .harness/after; }

# ---- seven: the seven on after/ and the previous tree; then against TiffinBox's own server's ----------------------------------
own() { awk -v s="\$ \$CURLSET 19300 .harness/anchor/secrets/tiffinbox/shutdown-token" 'f && /^  (GET|POST) / { sub(/^  /, ""); print; n++; if (n == 7) exit } index($0, s) == 1 { f = 1 }' "$OWN"; }
seven7() {
  echo "the seven - after/'s jar (port 19600) and the previous tree's (port 19605), a fresh JVM each:"
  start "$(at .harness/after 19600 "$R_RUN")"; up 19600; ready 19600; seven 19600 .harness/after; cp .harness/responses.m.txt .harness/seven-after.txt
  start "$(at .harness/before 19605 "$R_RUN")"; up 19605; ready 19605; seven 19605 .harness/before; cp .harness/responses.m.txt .harness/seven-before.txt
  echo "  lines that differ: $(diff .harness/seven-before.txt .harness/seven-after.txt | grep -c '^[<>]' || true) · the same, byte for byte: $(awk 'NR == FNR { a[FNR] = $0; next } a[FNR] == $0 { n++; l = l " " FNR } END { print n + 0 " (" substr(l, 2) ")" }' .harness/seven-before.txt .harness/seven-after.txt)"
  echo "TiffinBox's own server's seven - the servlet lesson's capture of the anchor the last course left, published in that lesson's README, its first block that runs \$CURLSET:"
  own > .harness/seven-own.txt
  sed 's/^/  /' .harness/seven-own.txt
  echo "  its lines: $(wc -l < .harness/seven-own.txt | tr -d ' ') · md5 $(md5 -q .harness/seven-own.txt) · the md5 that README publishes beside them: $(grep -c "md5 $(md5 -q .harness/seven-own.txt)" "$OWN" | sed 's/^0$/not there/; s/^[1-9][0-9]*$/there/')"
  echo "after/'s seven against TiffinBox's own server's, line by line:"
  awk 'NR == FNR { a[FNR] = $0; next } { r = $1 " " $2; if (a[FNR] == $0) { print "  line " FNR ", " r ": the same, byte for byte"; s++ } else { print "  line " FNR ", " r ": differs"; print "    TiffinBox'"'"'s own server: " a[FNR]; print "    after/:                    " $0; d++ } } END { print "  the same: " s + 0 " · different: " d + 0 }' .harness/seven-own.txt .harness/seven-after.txt
  echo "  why each differs - the lessons that changed it, by title:"
  echo "    GET /nowhere - the JDK's server wrote its own 404 page; Embedded Tomcat, Threads and Connectors handed the 404 to Boot (its four keys, which Boot's Default Error Response read), and ProblemDetail and RFC 9457 made it Spring MVC's problem detail"
  echo "    GET /shutdown - TiffinBox's router wrote its own 405; @RestController and Request Mapping made it Spring MVC's (Boot's four keys), and ProblemDetail and RFC 9457 a problem detail"; }

# ---- retired: Course 5's four web files, and the port Boot's analyzer explains -------------------------------------------------
retired() { local f c i c5=../c5-unit27/after/$MJ n=0 e=0
  echo "Course 5's four web files - in the tree the last course left (the servlet lesson's anchor) and in after/:"
  for f in ActuatorRoutes Route PortTakenFailureAnalyzer TiffinBoxServer; do n=$((n + $(lines "$c5/$f.java"))); echo "  $f.java: the last course's $(lines "$c5/$f.java") lines · after/'s: $( [ -f "after/$MJ/$f.java" ] && echo "$(lines "after/$MJ/$f.java") lines" || echo 'no file')"; done
  echo "  the four, in the last course's tree: $n lines"
  echo "  files named ActuatorRoutes.java, Route.java or PortTakenFailureAnalyzer.java anywhere in after/: $(find after -name ActuatorRoutes.java -o -name Route.java -o -name PortTakenFailureAnalyzer.java | grep -c . || true)"
  echo "  TiffinBoxServer.java's imports of the JDK's server (com.sun.net.httpserver): the last course's $(grep -c '^import com\.sun\.net\.httpserver\.' "$c5/TiffinBoxServer.java" || true) · after/'s $(grep -c '^import com\.sun\.net\.httpserver\.' "after/$MJ/TiffinBoxServer.java" || true) · in all of after/'s sources: $(grep -rh '^import com\.sun\.net\.httpserver\.' after/tiffinbox-*/src | grep -c . || true)"
  echo "  after/'s TiffinBoxServer: $(grep -m1 -E '^@RestController$' "after/$MJ/TiffinBoxServer.java") · its Javadoc's line: $(grep -m1 -oE 'TiffinBox no longer runs a server of its own' "after/$MJ/TiffinBoxServer.java")"
  echo "  what does each job now, and the lesson that handed it over, by title: the JDK's HttpServer (TiffinBoxServer) - embedded Tomcat, Embedded Tomcat, Threads and Connectors · ActuatorRoutes - Boot's Actuator on Spring MVC, the same lesson · PortTakenFailureAnalyzer - Boot's PortInUseFailureAnalyzer, the same lesson · Route - Spring MVC's request mappings, @RestController and Request Mapping"
  echo "the failure analyzers - TiffinBox's own spring.factories (after/'s web module) and the jar that registers Boot's port analyzer:"
  sed -n 's/^org\.springframework\.boot\.diagnostics\.FailureAnalyzer=/  TiffinBox'"'"'s: /p' after/tiffinbox-web/src/main/resources/META-INF/spring.factories
  echo "  spring-boot-web-server-4.1.1.jar (in .m2-demo), its META-INF/spring.factories names: $(unzip -p "$M2/org/springframework/boot/spring-boot-web-server/4.1.1/spring-boot-web-server-4.1.1.jar" META-INF/spring.factories | tr ',\\' '\n\n' | grep -o 'org\.springframework\.boot\.web\.server\.PortInUseFailureAnalyzer' | sort -u) · the class in that jar: $(unzip -Z1 "$M2/org/springframework/boot/spring-boot-web-server/4.1.1/spring-boot-web-server-4.1.1.jar" | grep -c '^org/springframework/boot/web/server/PortInUseFailureAnalyzer\.class$') file"
  echo "a second TiffinBox on a port the first holds - after/'s jar twice, port 19607:"
  start "$(at .harness/after 19607 "$R_RUN")"; up 19607; ready 19607
  c=$(at .harness/after 19607 "$R_RUN"); sec .harness/after; echo "\$ $c"
  (eval "$(exe "$c")") > .harness/run2.out 2>&1 < /dev/null & pid2=$!
  i=0; while kill -0 "$pid2" 2> /dev/null && [ $i -lt 240 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$pid2" 2> /dev/null && { kill "$pid2"; die "the second TiffinBox was still running 60 s after it started"; }
  wait "$pid2" || e=$?; pid2=""
  echo "  the second: exit $e · listening on 19607 now: $(lsof -nP -iTCP:19607 -sTCP:LISTEN -t 2> /dev/null | grep -c . || true) process, the first: $( [ "$(lsof -nP -iTCP:19607 -sTCP:LISTEN -t 2> /dev/null)" = "$pid" ] && echo yes || echo no)"
  echo "  its log's ERROR lines, by logger:"; awk '/^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T[^ ]+ +ERROR / { s = $0; i = index(s, " --- ["); s = substr(s, i + 6); i = index(s, "] "); s = substr(s, i + 2); i = index(s, " : "); lg = substr(s, 1, i - 1); sub(/ +$/, "", lg); print "    ERROR " lg ": " substr(s, i + 3) }' .harness/run2.out
  echo "  Boot's report, whole (the lines after the ERROR line, to the end of the log):"
  awk '/APPLICATION FAILED TO START/ { f = 1 } f && NF { print "    " $0 }' .harness/run2.out
  logtok .harness/run2.out /dev/null
  stop 19607 .harness/after; }

# ---- length: A/B/A' - a 61-letter name; C (labelled) - 61 spaces, three JVMs ------------------------------------------------------
# form PORT 'LINE': the form's POST, its status line; the page it answered with - its title and every message beside a field
form() { local c; c=$(url "$2" "$1"); echo "\$ $c"; (eval "$c") > .harness/form.html 2>&1 < /dev/null || true
  echo "  its status line: $(tail -1 .harness/form.html)"
  echo "  the page: <title>$(sed -n 's/.*<title>\([^<]*\)<\/title>.*/\1/p' .harness/form.html | head -1)</title> · its messages: $(grep -o '<span class="error">[^<]*</span>' .harness/form.html | sed 's/<[^>]*>//g' | paste -sd'|' - | sed 's/|/ · /g') - the rest of it not shown"; }
lena() { local p=$1 d=$2
  start "$(at "$d" "$p" "$R_RUN")"; up "$p"; ready "$p"
  echo "  no Accept-Language:"; askj "$L_BIG" "$p"
  echo "  Accept-Language: de:"; askj "$L_BIGDE" "$p"
  echo "  the form, no Accept-Language:"; form "$p" "$L_BIGFORM"
  echo "  the list after them:"; askj "$L_CUST" "$p"
  stop "$p" "$d"; echo "  its log's records (WARN and ERROR, each labelled by its logger):"; recs .harness/run.out; echo "  WARN lines: $(lvl WARN .harness/run.out) · ERROR lines: $(lvl ERROR .harness/run.out)"; }
length() { local k
  echo "A - after/ (Customer's name @NotBlank @Size(max = 60)), its jar, port 19600:"
  echo "  the record's first line in after/: $(grep -m1 -E '^public record Customer' after/$CJ/Customer.java)"
  lena 19600 .harness/after
  echo "B - the previous tree (before/, the testing lesson's frozen tree), its jar, port 19605:"
  echo "  the record's first line there: $(grep -m1 -E '^public record Customer' $PREV/$CJ/Customer.java)"
  start "$(at .harness/before 19605 "$R_RUN")"; up 19605; ready 19605
  echo "  no Accept-Language:"; askj "$L_BIG" 19605
  echo "  the list after it:"; askj "$L_CUST" 19605
  stop 19605 .harness/before; echo "  its log's records (WARN and ERROR, each labelled by its logger):"; recs .harness/run.out; echo "  WARN lines: $(lvl WARN .harness/run.out) · ERROR lines: $(lvl ERROR .harness/run.out) · H2's refusal (its exception's message), in the log: $(grep -c 'Value too long for column "NAME CHARACTER VARYING(60)"' .harness/run.out || true) times"
  echo "A' - A again (a fresh JVM of after/'s jar, port 19600):"
  lena 19600 .harness/after
  awk "/^A - after/ { f = 1; next } /^B - the previous tree/ { f = 0 } f" .harness/cap.raw | grep -v '^  the record' > .harness/a1.txt || true
  awk "/^A' - A again/ { f = 1; next } f" .harness/cap.raw > .harness/a2.txt
  echo "A' against A, line for line (A's line about the record aside): the same: $(cmp -s .harness/a1.txt .harness/a2.txt && [ -s .harness/a1.txt ] && echo yes || echo no)"
  echo "C (labelled) - a name of 61 spaces, blank and too long: three fresh JVMs of after/'s jar, port 19600, no Accept-Language:"
  : > .harness/c61.txt
  for k in 1 2 3; do echo "  JVM $k:"; start "$(at .harness/after 19600 "$R_RUN")"; up 19600; ready 19600
    askj "$L_SPACES" 19600 | tee .harness/c61.one; grep -v '^\$ ' .harness/c61.one >> .harness/c61.txt; stop 19600 .harness/after; done
  echo "  the three answers: $(sort -u .harness/c61.txt | grep -c . || true) distinct - md5 $(sort -u .harness/c61.txt | md5 -q)"; }

# ---- upload: a bulk upload ---------------------------------------------------------------------------------------------------
upload() {
  echo "the file - harness/import.csv, every line (the third's name: $(awk -F, 'NR == 3 { print length($1) }' harness/import.csv) letters):"
  awk '{ print "  " NR ": " $0 }' harness/import.csv
  echo "after/'s jar, port 19600:"
  start "$(at .harness/after 19600 "$R_RUN")"; up 19600; ready 19600
  echo "  the upload, no Accept-Language:"; askj "$L_IMPORT" 19600
  echo "  the list after it:"; askj "$L_CUST" 19600
  echo "  no part named file:"; askj "$L_NOFILE" 19600
  stop 19600 .harness/after; echo "  its log's records (WARN and ERROR):"; recs .harness/run.out; echo "  WARN lines: $(lvl WARN .harness/run.out) · ERROR lines: $(lvl ERROR .harness/run.out)"
  echo "the same file with Accept-Language: de - a fresh JVM of after/'s jar, port 19600:"
  start "$(at .harness/after 19600 "$R_RUN")"; up 19600; ready 19600
  askj "$L_IMPORTDE" 19600
  stop 19600 .harness/after; }

# ---- feed: who joined, and the shutdown with a listener connected ------------------------------------------------------------------
data() { local i=0; while [ "$(grep -c '^data:' "$1" 2> /dev/null || true)" -lt "$2" ] && [ $i -lt 80 ]; do sleep 0.25; i=$((i + 1)); done
  echo "  data lines in the listener's file now: $(grep -c '^data:' "$1" || true) (waited for $2, at most 20 s)"; }
feed() {
  echo "after/'s jar, port 19600, a listener connected - then a JSON add, a form add, and an upload's row:"
  start "$(at .harness/after 19600 "$R_RUN")"; up 19600; ready 19600
  listen 19600 .harness/feed.txt
  echo "  the JSON API:"; askj "$R_POST" 19600
  echo "  the form:"; askj "$R_FORM" 19600
  echo "  an upload:"; askj "$L_IMPORT" 19600
  data .harness/feed.txt 3
  echo "  POST /shutdown, the listener still connected:"; stop 19600 .harness/after; lend
  events .harness/feed.txt "the listener's file"
  echo "  Boot's and Framework's shutdown lines, each labelled by its logger:"; blog .harness/run.out "$SHUTL"
  echo "  lines that say a bean was still running after the shutdown phase's timeout: $(grep -c 'still running after timeout' .harness/run.out || true)"
  echo "C (labelled) - a copy whose feed does not end its streams when the context closes (.harness/noend: CustomerFeed's @EventListener line taken out - this unit's line), built with the README's package line, offline (its tests ran):"
  copy after .harness/noend; c=$(printf '%s\n' "$L_NOEND"); echo "\$ cd .harness/noend && $c"; (cd .harness/noend && eval "$c") < /dev/null || die "the sed failed"
  cdiff after/$MJ/CustomerFeed.java .harness/noend/$MJ/CustomerFeed.java
  mrun noend .harness/noend "$(off .harness/noend "$R_PLAIN" package | sed 's/^cd [^ ]* && //')"
  [ -f .harness/noend/$JARP ] || die "C: the copy's jar was not built"
  echo "  its jar, port 19606, a listener connected, one JSON add:"
  start "$(at .harness/noend 19606 "$R_RUN")"; up 19606; ready 19606
  listen 19606 .harness/feed-c.txt
  askj "$R_POST" 19606; data .harness/feed-c.txt 1
  echo "  POST /shutdown, the listener still connected:"; stop 19606 .harness/noend 60; lend 60
  events .harness/feed-c.txt "the listener's file"
  echo "  Boot's and Framework's shutdown lines, each labelled by its logger:"; blog .harness/run.out "$SHUTL"; }

# ---- tests: TiffinBox's tests, read from Surefire's reports ------------------------------------------------------------------------
tests() {
  echo "TiffinBox's tests - after/ with the harness's Census joined (.harness/tests), the README's line:"
  hcopy tests
  echo "  after/'s test classes and their test methods (the @Test lines in each file): $(for f in TiffinBoxWebTest FullStackTest FeedTest; do printf '%s %s · ' "$f" "$(grep -c '^    @Test$' after/$TT/com/tiffinbox/web/$f.java)"; done | sed 's/ · $//')"
  mrun tests .harness/tests "$(off .harness/tests "$R_TEST" | sed 's/^cd [^ ]* && //')"
  echo "C (labelled) - the harness's StreamWait: TiffinBox's slice, the feed asked for with MockMvcTester's default exchange (this unit's line):"
  mrun stream .harness/tests "$(off .harness/tests "$L_STREAM" | sed 's/^cd [^ ]* && //')"; }

# ---- exercise: the README's commands, exactly as written, then the solution's - in ONE shell --------------------------------------
block() { awk '/^```bash$/ { if (!d) { f = 1 }; next } f && /^```$/ { f = 0; d = 1 } f' "$1"; }
where() { case "$1" in "$U") echo "this unit's folder" ;; "$U"/*) echo "${1#"$U"/}" ;; *) echo "outside this unit's folder" ;; esac; }
exercise() { local setup sol i=0 e1 d1 e2 d2 n
  setup=$(block exercise/README.md); sol=$(block exercise/solution/SOLUTION.md)
  [ -n "$setup" ] && [ -n "$sol" ] || die "exercise/README.md or SOLUTION.md no longer gives its commands"
  n=$(printf '%s\n' "$setup" | grep -c .)
  [ "$(printf '%s\n' "$sol" | grep -c .)" = "$n" ] || die "SOLUTION.md's first bash block must be the README's two export lines, the line that fixes the file, and the README's last four lines"
  [ "$(printf '%s\n' "$sol" | sed -n 1,2p)" = "$(printf '%s\n' "$setup" | sed -n 1,2p)" ] || die "SOLUTION.md must start with the README's two export lines (a new shell's java may be another JDK)"
  printf '%s\n' "$sol" | sed -n 1p | grep -qxF 'export JAVA_HOME=/opt/homebrew/opt/openjdk@25' || die "SOLUTION.md's first line must export this script's JAVA_HOME"
  [ "$(printf '%s\n' "$sol" | tail -4)" = "$(printf '%s\n' "$setup" | tail -4)" ] || die "SOLUTION.md's last four lines must be the README's last four, exactly - a fresh JVM, the upload again, the stop"
  printf '%s\n' "$setup" | grep -qxF "(cd .harness/mine && ${R_IMPORT/18431/19600})" || die "exercise/README.md's upload must be the anchor README's line, run where the file is, on port 19600"
  rm -f .harness/ex-*; rm -rf .harness/mine
  printf '%s\n' "$setup" > .harness/ex-readme.sh; printf '%s\n' "$sol" > .harness/ex-sol.sh
  cat > .harness/ex-drive.sh <<'DRV'
cd "$1" || exit 1
. "$1/.harness/ex-readme.sh" > "$1/.harness/ex-readme.out" 2>&1 < /dev/null
echo "$? $PWD" > "$1/.harness/ex-readme.st"
cp "$1/.harness/mine/run.log" "$1/.harness/ex-readme.log" 2> /dev/null
. "$1/.harness/ex-sol.sh" > "$1/.harness/ex-sol.out" 2>&1 < /dev/null
echo "$? $PWD" > "$1/.harness/ex-sol.st"
DRV
  sec .harness/after
  env -i HOME="$HOME" PATH="$XPATH" /bin/bash --noprofile --norc .harness/ex-drive.sh "$U" > .harness/ex-shell.out 2>&1 < /dev/null & xpid=$!
  while kill -0 "$xpid" 2> /dev/null && [ $i -lt 1200 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$xpid" 2> /dev/null && { killtree "$xpid"; die "the exercise's shell still ran after 300 s"; }
  wait "$xpid" || true; xpid=""
  [ -f .harness/ex-readme.st ] && [ -f .harness/ex-sol.st ] || { cat .harness/ex-shell.out .harness/ex-readme.out .harness/ex-sol.out 2> /dev/null | tail -20 >&3; die "the exercise's shell did not reach the end of both blocks"; }
  read -r e1 d1 < .harness/ex-readme.st; read -r e2 d2 < .harness/ex-sol.st
  [ "$e1" = 0 ] || { tail -20 .harness/ex-readme.out >&3; die "the exercise's commands failed: exit $e1"; }
  [ "$e2" = 0 ] || { tail -20 .harness/ex-sol.out >&3; die "the solution's lines failed: exit $e2"; }
  echo "exercise/README.md's commands, then the solution's lines (exercise/solution/SOLUTION.md), exactly as written, one after the other in ONE shell - env -i (HOME, and the PATH this script was started with), /bin/bash --noprofile --norc, started in this folder:"
  echo "the README's $n lines:"
  printf '%s\n' "$setup" | sed 's/^/  $ /'
  echo "  exit $e1 · what they printed:"; tsmask < .harness/ex-readme.out | sed 's/^/    /'
  echo "  the shell is now in: $(where "$d1") · the JVM's log: Boot's first line: $(first .harness/ex-readme.log) · the demo token in it: $(raw "$TOKEN" .harness/ex-readme.log) times · listening on 19600 now: $(listeners 19600)"
  echo "the solution's $(printf '%s\n' "$sol" | grep -c .) lines, next, in the same shell:"
  printf '%s\n' "$sol" | sed 's/^/  $ /'
  echo "  exit $e2 · what they printed:"; tsmask < .harness/ex-sol.out | sed 's/^/    /'
  echo "  the shell is now in: $(where "$d2") · the demo token in the JVM's log: $(raw "$TOKEN" .harness/mine/run.log) times · listening on 19600 now: $(listeners 19600)"
  echo "  the copy's customers.csv now, every line:"; awk '{ print "    " NR ": " $0 }' .harness/mine/customers.csv; }

# ---- forms: the native build, then four forms ------------------------------------------------------------------------------------------
nbuild() { local ci cn s0 s1 e=0
  ci=$(off "$1" "$R_INSTALL" install); cn=$(off "$1" "$R_NATIVE")
  echo "\$ $ci"; mbuild "$ci" "$1.install.log" "$1 (both modules, into \$M2; the tests ran)"
  echo "  the tests this build ran (Surefire's reports, harness/surefire.py):"; python3 -I harness/surefire.py "$1/$SR" | sed 's/^/  /'
  echo "  Surefire's own lines that a fork would not exit: $(grep -c "$KILLED" "$1.install.log" || true) · the demo token in the build's log and its reports: $(raw "$TOKEN" "$1.install.log" "$1/$SR"/*) times"
  echo "\$ $cn"
  s0=$(date +%s); (eval "$cn") > "$1.native.log" 2>&1 < /dev/null & mpid=$!; wait "$mpid" || e=$?; mpid=""; NB_E=$e; s1=$(date +%s); NB_S=$((s1 - s0))
  echo "  (terminal only) the native build in $1 took $NB_S s - $( [ $NB_S -lt 1200 ] && echo under || echo OVER ) the 20-minute bound" >&3
  [ $NB_S -lt 1200 ] || die "the native build took over 20 minutes"
  if ghub "$1.native.log"; then echo "  offline: no - GraalVM's native plugin went to GitHub for its metadata repository"; die "the native build in $1: GraalVM's native plugin went over the network - README.md, The repository"; fi; }
nlines() {
  echo "  its lines, in order (the rest - $(grep -cvE '^\[INFO\] --- |^\[INFO\] Found GraalVM|^Warning: |^\[[1-8]/8\] |^\[INFO\] BUILD |^The build process encountered ' "$1" || true) lines - not shown):"
  grep -E '^\[INFO\] --- .* @ tiffinbox-web ---$|^\[INFO\] Found GraalVM installation from ' "$1" | sed 's/^\[INFO\] /    /'
  grep -E '^Warning: ' "$1" | sed -E "s/ in '(file:[^']*|null)'/ in '…'/" | sed 's/^/    /'
  grep -E '^\[[1-8]/8\] ' "$1" | sed 's/\.\.\..*$/.../' | sed 's/^/    /'
  grep -E '^The build process encountered |^\[INFO\] BUILD ' "$1" | sed 's/^\[INFO\] //' | sed 's/^/    /'; }
nresult() { echo "  exit $NB_E · $(grep -m1 -oE 'BUILD (SUCCESS|FAILURE)' "$1" || echo 'no BUILD line') · stages it printed: $(grep -cE '^\[[1-8]/8\] ' "$1" || true) of the $(grep -m1 -oE '^\[1/[0-9]+\]' "$1" | sed 's/.*\///; s/]//') it announces · its lines that say the metadata repository was downloaded over http, or failed to: $(grep -cE 'Downloaded GraalVM reachability metadata repository from http|Failed to download from http' "$1" || true) · offline: yes"; }
# hv DIR: R.145 - the Hibernate Validator metadata file the native plugin wrote for this build, read in target/classes and in the jar;
# its size goes to the terminal only (it is 2,306 or 157,308 bytes, build to build - printed, never hashed), and to .harness/hv.txt
HVS=""
hv() { local a b
  a=$(wc -c < "$1/tiffinbox-web/target/classes/$HVF" 2> /dev/null | tr -d ' ') || a=""; b=$(unzip -p "$1/$JARP" "$HVF" 2> /dev/null | wc -c | tr -d ' ')
  [ -n "$a" ] && [ "$a" = "$b" ] || die "R.145: the Hibernate Validator metadata file is missing, or its jar's copy differs (target/classes ${a:-none} B, the jar $b B)"
  HVS=$a; echo "$a" >> .harness/hv.txt
  echo "  (terminal only, R.145) the Hibernate Validator metadata file this build made - $HVF: $a bytes (in target/classes and in the jar the same)" >&3
  echo "  the Hibernate Validator metadata file this build made ($HVF): in target/classes and in the jar the same · its size: printed on the terminal, never hashed (R.145)"; }
lbk() { awk -v a="$1" 'index($0, a) == 1 { f = 1; next } /^[1-4] the / { f = 0 } f' .harness/cap.raw > .harness/blk.txt
  if [ "$1" = '4 the image' ]; then [ "$(grep -c '^  docker port: ' .harness/blk.txt)" = 2 ] && [ "$(grep -cE '^  docker port: 18425/tcp -> 127\.0\.0\.1:19603$' .harness/blk.txt)" = 2 ] && echo yes || echo no
  else [ "$(grep -c '^  listens on: ' .harness/blk.txt)" -gt 0 ] && [ "$(grep -c '^  listens on: ' .harness/blk.txt)" = "$(grep -cE '^  listens on: 127\.0\.0\.1:[0-9]+ · loopback only: yes$' .harness/blk.txt)" ] && echo yes || echo no; fi; }
blines() { local s
  s=$(grep -E '^#[0-9]+ \[internal\] load metadata for |^#[0-9]+ \[[a-z0-9-]+ 1/[0-9]+\] FROM |^#[0-9]+ naming to ' "$1" | sed -E 's/^#[0-9]+ //; s/( [0-9]+\.[0-9]+s)? done$//' | awk '!seen[$0]++')
  printf '%s\n' "$s" | sed 's/^/    /'
  echo "  its lines that say pull: $(grep -ci 'pull' "$1" || true) · its other lines: $( [ "$(wc -l < "$1" | tr -d ' ')" -lt 300 ] && echo 'fewer than 300' || echo '300 or more'), not shown"; }
inside() { docker exec "$1" cat /proc/net/tcp /proc/net/tcp6 2> /dev/null | awk '
  function hex(x,  i, v) { v = 0; for (i = 1; i <= length(x); i++) v = v * 16 + index("0123456789ABCDEF", toupper(substr(x, i, 1))) - 1; return v }
  $4 == "0A" { split($2, a, ":"); p = hex(a[2]); h = a[1]
    if (h == "00000000000000000000000000000000") ad = "[::]"; else if (h == "00000000") ad = "0.0.0.0"; else if (h == "0100007F") ad = "127.0.0.1"; else if (h == "00000000000000000000000001000000") ad = "[::1]"; else ad = "another address"
    print ad ":" p }' | sort -u | paste -sd' ' -; }
dstart() { local ec=0; sec "$(dir "$1")"; echo "\$ $1"; (eval "$1") > .harness/d.out 2> .harness/d.err < /dev/null || ec=$?
  [ $ec = 0 ] || { cat .harness/d.err >&3; die "docker run failed: exit $ec"; }; }
dgone() { local i=0 e
  while [ "$(docker inspect -f '{{.State.Running}}' "$1" 2> /dev/null)" = true ] && [ $i -lt 240 ]; do sleep 0.25; i=$((i + 1)); done
  [ "$(docker inspect -f '{{.State.Running}}' "$1" 2> /dev/null)" != true ] || die "the container $1 still ran after 60 s"
  echo "\$ docker wait $1"; e=$(docker wait "$1"); echo "  $e"; LASTE=$e; }
dlog() { local t h; docker logs "$1" > .harness/run.out 2>&1 || true; : > .harness/run.err
  t=$(raw "$TOKEN" .harness/run.out); h=$(LC_ALL=C grep -aoi -- 'x-shutdown-token' .harness/run.out | wc -l | tr -d ' ')
  CLOGS=$((CLOGS + 1)); [ "$t" = 0 ] && [ "$h" = 0 ] || die "a container's log held the demo token ($t) or its header's name ($h)"; }
dbind() { echo "  inside the container, listening: $(inside "$BOX")"
  echo "  docker port: $(docker port "$BOX" | paste -sd' ' -)"
  echo "  on this Mac, listening on port $1: $(lsof -nP -iTCP:"$1" -sTCP:LISTEN 2> /dev/null | awk 'NR > 1 { print $9 }' | sort -u | paste -sd' ' -)"; }
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
# second PORT: a listener connected; the invalid customer, the 61-letter name (no Accept-Language, then de), the upload - one event -
# and the dashboard's page
second() { listen "$1" ".harness/feed-$1.txt"
  echo "  the invalid customer, no Accept-Language:"; askj "$L_INV" "$1"
  echo "  the 61-letter name, no Accept-Language:"; askj "$L_BIG" "$1"
  echo "  the 61-letter name, Accept-Language: de:"; askj "$L_BIGDE" "$1"
  echo "  the upload, no Accept-Language:"; askj "$L_IMPORT" "$1"
  data ".harness/feed-$1.txt" 1
  echo "\$ $(url "$R_PAGE" "$1")"; curl -s -H 'Accept: text/html' "http://127.0.0.1:$1/dashboard" > .harness/page.html < /dev/null || true
  echo "  the page: <title>$(sed -n 's/.*<title>\([^<]*\)<\/title>.*/\1/p' .harness/page.html | head -1)</title> - the rest of it not shown"; }
# shut: after the server stopped - the listener's end, what it read, the shutdown's lines
shut() { lend; events ".harness/feed-$1.txt" "the listener's file"
  echo "  the shutdown's lines, each labelled by its logger:"; blog .harness/run.out "$SHUTL"; }
dseven() { echo "\$ \$CURLSET $1 .harness/after/$TF"
  "$CURLSET" "$1" ".harness/after/$TF" | grep ' -> ' > .harness/responses.txt || true
  tsmask < .harness/responses.txt > .harness/responses.m.txt
  grep '^POST ' .harness/responses.m.txt | sed 's/^/  /' || echo "  (no POST line)"
  dgone "$BOX"; [ "$(listeners "$1")" = 0 ] || die "something still listens on $1"
  echo "  exit $LASTE · the seven responses: $(wc -l < .harness/responses.m.txt | tr -d ' ') lines · lines the timestamp mask changed: $(diff .harness/responses.txt .harness/responses.m.txt | grep -c '^<' || true) · md5 $(md5 -q .harness/responses.m.txt)"
  dlog "$BOX"; echo "  its log (docker logs): Boot's first line: $(first .harness/run.out) · the demo token 0 times · X-Shutdown-Token 0 times"
  docker rm "$BOX" > /dev/null; }
S466='466c20ed7e0d5439cb052f32ce09de1b'
THREE='"errors":{"mealsPerDay":"must be greater than or equal to 1","name":"must not be blank","pricePerMeal":"must be greater than or equal to 1"}'
forms() { local f
  echo "the native build - after/ copied to .harness/nat with a config tree; the README's two Maven lines, offline; \$GRAALVM_HOME names the GraalVM:"
  copy after .harness/nat
  nbuild .harness/nat; nlines .harness/nat.native.log; nresult .harness/nat.native.log
  hv .harness/nat
  echo "  file: $(file -b ".harness/nat/$BIN" | sed 's/ [A-Za-z0-9_]*$//') · the demo token in its bytes: $(raw "$TOKEN" ".harness/nat/$BIN") · the tests' literal: $(raw "$LIT" ".harness/nat/$BIN") · a test class in it (TiffinBoxWebTest, FullStackTest, FeedTest, WebSlice): $(raw TiffinBoxWebTest ".harness/nat/$BIN") $(raw FullStackTest ".harness/nat/$BIN") $(raw FeedTest ".harness/nat/$BIN") $(raw WebSlice ".harness/nat/$BIN")"
  echo "after/'s jar - .harness/after, built before the captures with the README's package line, offline; the tests that build ran:"
  python3 -I harness/surefire.py ".harness/after/$SR" | sed -n 's/^  in all: /  /p'
  echo "1 the jar - .harness/after, the README's run line, port 19600:"
  start "$(at .harness/after 19600 "$R_RUN")"; up 19600; ready 19600; seven 19600 .harness/after
  echo "  then, on a second start of the jar, a listener connected:"
  start "$(at .harness/after 19600 "$R_RUN")"; up 19600; ready 19600; second 19600; stop 19600 .harness/after; shut 19600
  echo "2 the AOT jar - .harness/nat (the profile native's jar), the README's AOT line, port 19601:"
  start "$(at .harness/nat 19601 "$R_AOTRUN")"; up 19601; ready 19601; seven 19601 .harness/nat
  echo "  then, on a second start of the AOT jar, a listener connected:"
  start "$(at .harness/nat 19601 "$R_AOTRUN")"; up 19601; ready 19601; second 19601; stop 19601 .harness/nat; shut 19601
  echo "3 the binary - .harness/nat, the README's line, port 19602:"
  start "$(at .harness/nat 19602 "$R_BIN")"; up 19602; ready 19602; seven 19602 .harness/nat
  echo "  then, on a second start of the binary, a listener connected:"
  start "$(at .harness/nat 19602 "$R_BIN")"; up 19602; ready 19602; second 19602; stop 19602 .harness/nat; shut 19602
  # R.145: a binary whose validation fails is a stop, never a re-run - BLUE decides the fix (the brief's BLOCKED)
  if ! awk '/^3 the binary/ { f = 1 } /^4 the image/ { f = 0 } f' .harness/cap.raw | grep -qF "$THREE"; then
    echo "  *** STOP (R.145): the binary did not answer the invalid customer with the three messages; its Hibernate Validator metadata file: $HVS bytes - do not re-run: report it (the brief's BLOCKED) ***" >&3
    INTR=1; exit 3; fi
  echo "4 the image - after/'s Dockerfile (the README's build line, this script's tag), the README's run line with your user, published on 127.0.0.1:19603:"
  image
  dstart "$(drun .harness/after 19603)"; ready 19603 "$BOX"; dbind 19603
  dseven 19603
  echo "  then, on a second container of the image, a listener connected:"
  dstart "$(drun .harness/after 19603)"; ready 19603 "$BOX"; dbind 19603
  second 19603
  post 19603 .harness/after; dgone "$BOX"; [ "$(listeners 19603)" = 0 ] || die "something still listens on 19603"
  dlog "$BOX"; echo "  exit $LASTE · its log (docker logs): the demo token 0 times · X-Shutdown-Token 0 times"
  shut 19603
  docker rm "$BOX" > /dev/null
  echo "four forms, one tree: the seven (masked) $(grep -cE "^  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 0 · md5 $S466\$" .harness/cap.raw) of 4 times $S466 · the invalid customer's three messages: $(grep -cF "$THREE" .harness/cap.raw) of 4 · the size message in English: $(grep -cF '"errors":{"name":"size must be between 0 and 60"}' .harness/cap.raw) (four with no Accept-Language, and the binary's with de) · in German: $(grep -cF '"errors":{"name":"Größe muss zwischen 0 und 60 sein"}' .harness/cap.raw) · the upload's answer: $(grep -cF '{"added":1,"file":"import.csv","refused":{"line 3":"name: size must be between 0 and 60","line 4":"not a number: For input string: \"x\"","line 5":"a customer named Ravi already exists"}} 200' .harness/cap.raw) of 4 · the event it made: $(grep -cxF '    data:{"name":"Chetan","mealsPerDay":1,"pricePerMeal":100,"mealType":"VEG"}' .harness/cap.raw) of 4 · the page's title Dashboard · TiffinBox: $(grep -cxF '  the page: <title>Dashboard · TiffinBox</title> - the rest of it not shown' .harness/cap.raw) of 4 · Graceful shutdown complete with the listener connected: $(grep -cE '^    INFO o\.s\.boot\.tomcat\.GracefulShutdown: Graceful shutdown complete$' .harness/cap.raw) of 4 · the listener ended, exit 0: $(grep -cxF '  the listener ended: curl exit 0' .harness/cap.raw) of 4"
  echo "  loopback, form by form: the jar $(lbk '1 the jar') · the AOT jar $(lbk '2 the AOT jar') · the binary $(lbk '3 the binary') · the image, published on 127.0.0.1 alone $(lbk '4 the image')"
  echo "  the locale: options on the binary's and the image's run lines: $(printf '%s\n%s\n' "$(at .harness/nat 19602 "$R_BIN")" "$(drun .harness/after 19603)" | grep -o 'user\.language\|user\.country' | wc -l | tr -d ' ') (none passed: the binary runs as the README writes it, the image as its ENTRYPOINT, java -jar)"; }

cap tour tour
cap seven seven7
cap retired retired
cap length length
cap upload upload
cap feed feed
cap tests tests
cap exercise exercise
[ $GOK = yes ] || die "GRAALVM_HOME is not set: .m2-demo is filled, and the captures that need no GraalVM matched receipts.md5; the native build needs a GraalVM JDK 25 - README.md, The GraalVM"
cap forms forms
echo "  (terminal only, R.145) the Hibernate Validator metadata file's size in each of this run's native builds: $(paste -sd' ' .harness/hv.txt) bytes" >&3
echo
# ---- every number the video says, asserted. Each check reads a line a program computed - a Surefire report, the harness's own line,
# ---- a count - never a label this script prints unconditionally, and names the words it pays for.
x() { grep -qE -- "$2" ".r-$1.out" || die "$1: expected /$2/"; }
n() { grep -cE -- "$2" ".r-$1.out" || true; }
blk() { awk -v a="$2" -v b="$3" 'index($0, a) == 1 { f = 1; next } b != "" && index($0, b) == 1 { f = 0 } f' ".r-$1.out"; }
has() { printf '%s\n' "$1" | grep -qxF -- "$2" || die "$3: expected the line: $2"; }
nhas() { ! printf '%s\n' "$1" | grep -qF -- "$2" || die "$3: did not expect: $2"; }
cnt() { printf '%s\n' "$1" | grep -cxF -- "$2" || true; }
# THE TOKEN: no capture holds it, raw - counted on each run's own output BEFORE masking - and neither does any log, any report, any file
# this unit ships, nor the binary this run built
for f in .harness/raw-*; do [ "$(cat "$f")" = "0" ] || die "a capture's raw output held the token ($f: $(cat "$f"))"; done
SHIP="README.md exercise/README.md exercise/customers.csv exercise/solution/SOLUTION.md receipts.md5 harness/shutdown.sh harness/surefire.py harness/import.csv harness/test/resources/META-INF/spring.factories $(for f in $HTS; do printf 'harness/test/java/probe/web/%s ' "$f"; done) $(cd after && find . -type f | sed 's#^\./#after/#' | paste -sd' ' -)"
NBIN=0
for f in .r-*.out $SHIP .harness/nat/$BIN; do [ -f "$f" ] || continue; case $f in .harness/nat*) NBIN=$((NBIN + 1)) ;; esac; [ "$(raw "$TOKEN" "$f")" = 0 ] || die "$f holds the demo token, raw"; done
[ "$NBIN" = 1 ] || [ ! -f .r-forms.out ] || die "one binary was built, $NBIN were checked"
for f in .harness/*.log; do [ "$(raw "$TOKEN" "$f")" = 0 ] || die "$f (a build's log) holds the demo token"; done
[ "$MLOGS" -gt 0 ] && [ "$LOGS" -gt 0 ] || die "a token count never ran (Maven logs $MLOGS, JVM logs $LOGS)"
# no capture prints a path, a version token of the OS or the JDK, a time, a pid, a random port, a connector port or a unit number
for f in .r-*.out; do
  ! grep -qE '/Users/|/private/|/home/|/var/folders/' "$f" || die "$f holds an absolute path"
  [ -z "${GRAALVM_HOME:-}" ] || ! grep -qF "$GRAALVM_HOME" "$f" || die "$f holds the GraalVM's folder"
  ! grep -qE 'c[0-9]-unit[0-9]|unit ?[0-9]' "$f" || die "$f holds a unit number"
  ! grep -qE ' (with PID|started by) |surefirebooter|Time elapsed|time="' "$f" || die "$f holds Boot's process line, a Surefire booter path or a test's time"
  ! grep -qE '^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T|"timestamp":"?[0-9]|(exec|handler|task|utility)-[0-9]|GMT|CES?T' "$f" || die "$f holds a log time, a timestamp or a thread number"
  ! grep -qE 'Java [0-9]+\.[0-9]|using Java [0-9]|Java-http-client/[0-9]|Macintosh|Mac OS X|Windows NT|X11;|Linux x86|Darwin|arm64|aarch64' "$f" || die "$f holds an OS or a JDK version token (R.128, R.151)"
  ! grep -qE 'http-nio-127\.0\.0\.1-[0-9]' "$f" || die "$f holds a connector name with its port (S6.22)"
  ! grep -qE '(127\.0\.0\.1:|port )(49|5[0-9]|6[0-5])[0-9][0-9][0-9]([^0-9]|$)' "$f" || die "$f holds a random port (R.147)"
  ! grep -qE '^ +at [a-z]' "$f" || die "$f holds a stack frame"; done
# every URL a command names is 127.0.0.1's; every JVM a capture starts has its locale pinned; every start lists secrets/ first
# (R.158); nothing kills by name; no bare wait; no Boot 3 key; no port published on every address
for f in .r-*.out; do ! grep -E '^ *\$ ' "$f" | grep -oE 'https?://[^ '"'"']+' | grep -vE '^http://127\.0\.0\.1:' > /dev/null || die "$f runs a command with a URL that is not 127.0.0.1's"; done
for f in .r-*.out; do ! grep -E '^ *\$ \(?(cd [^ ]+ && )?(exec )?java ' "$f" | grep -vF -- "java $JL " > /dev/null || die "$f starts a JVM without its locale pinned (S6.1)"; done
for f in .r-*.out; do a=$(grep -cE '^\$ cd \.harness/[a-z]+ && (java |tiffinbox-web/target/tiffinbox-web |docker run )' "$f" || true); b=$(grep -cxF "  secrets/ before the start: tiffinbox/shutdown-token - the token's file, and nothing else" "$f" || true)
  [ "$a" = "$b" ] || [ "$f" = .r-exercise.out ] || die "$f: $a starts, $b secrets/ listings (R.158)"; done
[ "$(n exercise "^  secrets/ before the start: tiffinbox/shutdown-token - the token.s file, and nothing else$")" = 1 ] || die "exercise: the folder its JVMs start in, listed once (R.158)"
K1='pki''ll'; K2='kill''all'; for f in receipts.sh harness/surefire.py harness/shutdown.sh; do ! grep -v '^ *#' "$f" | grep -qwE "$K1|$K2" || die "$f names $K1 or $K2 - every process is stopped by its pid"; done
for f in receipts.sh exercise/README.md exercise/solution/SOLUTION.md; do ! grep -nE '(^|[;&|({] *)wait *($|[;&|)}])' "$f" | grep -vE '^[0-9]+: *#' > /dev/null || die "$f has a bare wait (S6.9)"; done
K3='server'; K3="$K3.error."; K4='spring.http''.client.'
for f in receipts.sh README.md exercise/README.md exercise/solution/SOLUTION.md; do ! grep -qF "$K3" "$f" || die "$f names one of Boot 3's error keys (R.99)"; ! grep -qF "$K4" "$f" || die "$f names Boot 3's client key (R.138)"; done
! grep -rqF "$K3" after || die "after/ names one of Boot 3's error keys (R.99)"
! grep -rq 'probe\.web' after/tiffinbox-web after/tiffinbox-core || die "after/'s code names the course's harness - it is never TiffinBox's"
! grep -rqE '^package com\.tiffinbox' harness/test/java || die "a harness class sits in com.tiffinbox (R.43, R.143)"
for f in receipts.sh README.md exercise/README.md exercise/solution/SOLUTION.md; do ! grep -E 'docker run ' "$f" | grep -vE '^#' | grep -E ' -p "?[0-9]+:' > /dev/null || die "$f publishes a port on every address (-p without 127.0.0.1:)"; done
NFORK=$(cat .r-*.out | grep -cE "^ +the fork's locale, read from the reports' properties: " || true)
[ "$NFORK" -gt 0 ] && [ "$(cat .r-*.out | grep -cE "^ +the fork's locale, read from the reports' properties: user\.language en · user\.country US · the same in every report: yes$")" = "$NFORK" ] || die "every test JVM's locale en_US (S6.1)"
echo "  tokens: 0 raw copies in $(ls .harness/raw-* | wc -l | tr -d ' ') raw capture runs, in $(ls .r-*.out | wc -l | tr -d ' ') captures; the demo token 0 in every Maven log and Surefire report ($MLOGS here), the log of every JVM that served ($LOGS), every container ($CLOGS), the image's layers, every file this unit ships (after/ whole), receipts.md5 and the binary; no path, OS or JDK version token, connector port, time, random port, unit number or frame; every JVM's locale pinned; every start's secrets/ listed; every URL 127.0.0.1"

# "eighteen classes ... four controllers ... no service, no repository annotation, the entity is a record ... twenty-one rows, twelve"
TO=$(cat .r-tour.out)
for l in '  TiffinBox'"'"'s classes: 18 (core 7, web 11)' '  @Service, @Repository, @Entity anywhere in after/'"'"'s sources (an annotation line, main and test): @Service 0 · @Repository 0 · @Entity 0' \
         '  Customer, as tiffinbox-core declares it: public record Customer' \
         '  controller: CustomerFeed CustomerImport DashboardPage TiffinBoxServer - by Spring'"'"'s own annotation (@Controller, @RestController); the advice beside them: TiffinBoxErrors' \
         '  service: a class named …Service: 0 · annotated @Service: 0 (above) - the work sits in Dashboard OrderQueue, each a @Component' \
         '  repository: CustomerRepository - the word in TiffinBox'"'"'s own class name; its annotation: @Component' \
         '  the page: <title>Dashboard · TiffinBox</title> · its table'"'"'s rows: 5 - the rest of it not shown' \
         '  {"customers":4,"monthRevenue":24300,"pausedDays":5,"names":["Meera","Priya","Ravi","Sunil"]}' \
         '  the routing table (dispatcherServlet'"'"'s rows): 21 · TiffinBox'"'"'s (a handler method in com.tiffinbox): 12 · the others (Actuator'"'"'s, Boot'"'"'s /error, the static files): 9' \
         '    CustomerFeed#feed  {GET [/customers/feed], produces [text/event-stream]}' '    CustomerImport#importCsv  {POST [/customers/import], consumes [multipart/form-data]}' \
         '  by class: CustomerFeed 1 · CustomerImport 1 · DashboardPage 3 · TiffinBoxServer 7'; do has "$TO" "$l" "tour"; done
printf '%s\n' "$TO" | grep -E '^  each annotation, counted: ' | grep -qF '@Component 6 ' && printf '%s\n' "$TO" | grep -E '^  each annotation, counted: ' | grep -qF '@RestController 3 ' && printf '%s\n' "$TO" | grep -E '^  each annotation, counted: ' | grep -qF '@Controller 1 ' || die "tour: @Component 6, @RestController 3, @Controller 1"
[ "$(printf '%s\n' "$TO" | grep -cE '^    [A-Za-z]+#[a-zA-Z]+  \{')" = 12 ] || die "tour: twelve of TiffinBox's rows listed"
echo "  tour: 18 classes (7 core, 11 web); controllers 4 (3 @RestController, 1 @Controller) + the advice; @Component 6; @Service/@Repository/@Entity 0; Customer a record; /dashboard the page and the JSON; 21 rows, TiffinBox's 12"

# "the same seven, byte for byte ... against TiffinBox's own server: five the same, two different"
SE=$(cat .r-seven.out)
[ "$(cnt "$SE" "  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 0 · md5 $S466")" = 2 ] || die "seven: $S466 on both trees"
for l in '  lines that differ: 0 · the same, byte for byte: 7 (1 2 3 4 5 6 7)' '  its lines: 7 · md5 115c36bac276128e245ca57df11c2891 · the md5 that README publishes beside them: there' \
         '  line 5, GET /nowhere: differs' '  line 6, GET /shutdown: differs' '  the same: 5 · different: 2' \
         '    TiffinBox'"'"'s own server: GET   /nowhere    -> 404 text/html  <h1>404 Not Found</h1>No context found for request' \
         '    TiffinBox'"'"'s own server: GET   /shutdown   -> 405 application/json  {"error":"method not allowed"}'; do has "$SE" "$l" "seven"; done
[ "$(printf '%s\n' "$SE" | grep -cE '^  line [0-9], [A-Z]+ /[a-z]+: the same, byte for byte$')" = 5 ] || die "seven: five lines the same"
[ ! -f ../c6-unit01/.r-before.out ] || [ "$(sed -n '/^\$ \$CURLSET 19300 /,/exit 0/p' ../c6-unit01/.r-before.out | grep -E '^  (GET|POST) ' | head -7 | sed 's/^  //' | md5 -q)" = 115c36bac276128e245ca57df11c2891 ] || die "seven: the servlet lesson's frozen capture (.r-before.out) is not its README's"
echo "  seven: $S466 on after/ and the previous tree, the same 7; TiffinBox's own server's 115c36ba (its README's block): 5 the same, 2 differ (/nowhere, GET /shutdown)"

# "three of the four files are gone; the name stayed, the server left ... Port … was already in use"
RT=$(cat .r-retired.out)
for l in '  ActuatorRoutes.java: the last course'"'"'s 196 lines · after/'"'"'s: no file' '  Route.java: the last course'"'"'s 24 lines · after/'"'"'s: no file' '  PortTakenFailureAnalyzer.java: the last course'"'"'s 51 lines · after/'"'"'s: no file' \
         '  the four, in the last course'"'"'s tree: 548 lines' '  files named ActuatorRoutes.java, Route.java or PortTakenFailureAnalyzer.java anywhere in after/: 0' \
         '  after/'"'"'s TiffinBoxServer: @RestController · its Javadoc'"'"'s line: TiffinBox no longer runs a server of its own' \
         '  spring-boot-web-server-4.1.1.jar (in .m2-demo), its META-INF/spring.factories names: org.springframework.boot.web.server.PortInUseFailureAnalyzer · the class in that jar: 1 file' \
         '  TiffinBox'"'"'s: com.tiffinbox.web.BareArgumentAnalyzer' '  the second: exit 1 · listening on 19607 now: 1 process, the first: yes' \
         '    ERROR o.s.b.d.LoggingFailureAnalysisReporter: ' '    Web server failed to start. Port 19607 was already in use.' \
         '    Identify and stop the process that'"'"'s listening on port 19607 or configure this application to listen on another port.'; do has "$RT" "$l" "retired"; done
printf '%s\n' "$RT" | grep -qE "^  TiffinBoxServer\.java's imports of the JDK's server \(com\.sun\.net\.httpserver\): the last course's [1-9][0-9]* · after/'s 0 · in all of after/'s sources: 0$" || die "retired: the JDK's server imported before, not now"
echo "  retired: ActuatorRoutes 196, Route 24, PortTakenFailureAnalyzer 51 - no file; TiffinBoxServer kept, 0 JDK-server imports; the port-taken pair: exit 1, Boot's PortInUseFailureAnalyzer (spring-boot-web-server's spring.factories)"

# "sixty-one letters: four hundred, size must be between zero and sixty ... the previous tree: five hundred ... sixty-one spaces: both, three JVMs"
LA=$(blk length "A - after/" "B - the previous tree"); LB=$(blk length "B - the previous tree" "A' - A again"); LA2=$(blk length "A' - A again" "A' against A"); LC=$(blk length "C (labelled)" "")
SZE='  {"detail":"the customer breaks 1 rule","errors":{"name":"size must be between 0 and 60"},"instance":"/customers","status":400,"title":"Invalid customer"} 400    (keys sorted)'
SZD='  {"detail":"the customer breaks 1 rule","errors":{"name":"Größe muss zwischen 0 und 60 sein"},"instance":"/customers","status":400,"title":"Invalid customer"} 400    (keys sorted)'
FOUR='  [{"name":"Meera","mealsPerDay":1,"pricePerMeal":150,"mealType":"NON_VEG"},{"name":"Priya","mealsPerDay":1,"pricePerMeal":120,"mealType":"VEGAN"},{"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"},{"name":"Sunil","mealsPerDay":3,"pricePerMeal":100,"mealType":"VEG"}]'
for b in "$LA" "$LA2"; do for l in "$SZE" "$SZD" '  its status line:  200 · Location: []' '  the page: <title>Add a customer · TiffinBox</title> · its messages: size must be between 0 and 60 - the rest of it not shown' "$FOUR" '  WARN lines: 0 · ERROR lines: 0'; do has "$b" "$l" "length A: a 400 in words, nothing stored, no ERROR"; done; done
for l in '  {"error":"Internal Server Error","path":"/customers","status":500,"timestamp":"…"} 500    (keys sorted)' "$FOUR"; do has "$LB" "$l" "length B: the previous tree's 500"; done
printf '%s\n' "$LB" | grep -qE '^  WARN lines: 0 · ERROR lines: 1 · H2.s refusal \(its exception.s message\), in the log: [1-9] times$' && printf '%s\n' "$LB" | grep -qF '    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: Servlet.service() for servlet [dispatcherServlet] in context with path [] threw exception [Request processing failed: org.h2.jdbc.JdbcSQLDataException: Value too long for column' || die "length B: one ERROR, Tomcat's, H2's refusal inside it"
nhas "$LB" '"status":400' "length B: no 400 on the previous tree"
x length "^A' against A, line for line \(A's line about the record aside\): the same: yes\$"
printf '%s\n' "$LA2" | grep -qxF "\$ cd .harness/after && ${L_RUNL/18431/19600}" || die "length A': its \$ line (S6.2)"
[ "$(cnt "$LC" '  {"detail":"the customer breaks 2 rules","errors":{"name":"must not be blank; size must be between 0 and 60"},"instance":"/customers","status":400,"title":"Invalid customer"} 400    (keys sorted)')" = 3 ] && printf '%s\n' "$LC" | grep -qE '^  the three answers: 1 distinct - md5 [0-9a-f]{32}$' || die "length C: 61 spaces, both messages, sorted, three JVMs one answer (R.160)"
echo "  length: A 400 size message (English; de German), the form shows it, nothing stored, 0 ERROR; B 500 Boot's four keys, 1 Tomcat ERROR with H2's refusal; A' = A; C 61 spaces: both messages, 3 JVMs, 1 answer"

# "one added, three refused, each with why ... no file part: four hundred, Required part"
UP=$(cat .r-upload.out)
for l in '  {"added":1,"file":"import.csv","refused":{"line 3":"name: size must be between 0 and 60","line 4":"not a number: For input string: \"x\"","line 5":"a customer named Ravi already exists"}} 200    (keys sorted)' \
         '  [{"name":"Chetan","mealsPerDay":1,"pricePerMeal":100,"mealType":"VEG"},{"name":"Meera","mealsPerDay":1,"pricePerMeal":150,"mealType":"NON_VEG"},{"name":"Priya","mealsPerDay":1,"pricePerMeal":120,"mealType":"VEGAN"},{"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"},{"name":"Sunil","mealsPerDay":3,"pricePerMeal":100,"mealType":"VEG"}]' \
         '  {"detail":"Required part '"'"'file'"'"' is not present.","instance":"/customers/import","status":400,"title":"Bad Request"} 400' \
         '  {"added":1,"file":"import.csv","refused":{"line 3":"name: Größe muss zwischen 0 und 60 sein","line 4":"not a number: For input string: \"x\"","line 5":"a customer named Ravi already exists"}} 200    (keys sorted)' \
         'the file - harness/import.csv, every line (the third'"'"'s name: 61 letters):'; do has "$UP" "$l" "upload"; done
echo "  upload: added 1 (Chetan, now in /customers), refused 3 - line 3 the size rule, line 4 not a number, line 5 already exists; no file part: 400 Required part 'file' is not present.; de: the size rule in German"

# "three events ... graceful shutdown complete, the listener ends ... C: still running after timeout of 30000ms"
FA=$(blk feed "after/'s jar, port 19600" "C (labelled)"); FC=$(blk feed "C (labelled)" "")
for l in '    data:{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' '    data:{"name":"Lata","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"}' '    data:{"name":"Chetan","mealsPerDay":1,"pricePerMeal":100,"mealType":"VEG"}' \
         '  events named customer-added: 3 · data lines: 3 · id lines: 0 · comment lines: 1' '   302 · Location: [http://127.0.0.1:19600/dashboard]' \
         '    INFO o.s.boot.tomcat.GracefulShutdown: Graceful shutdown complete' '  the listener ended: curl exit 0' \
         '  lines that say a bean was still running after the shutdown phase'"'"'s timeout: 0'; do has "$FA" "$l" "feed: three events, a graceful shutdown with the listener connected (R.159)"; done
for l in '  Surefire'"'"'s own lines that a fork would not exit (Surefire is going to kill self fork JVM …): 1' '    -    @EventListener(ContextClosedEvent.class)' \
         '    INFO o.s.c.support.DefaultLifecycleProcessor: Shutdown phase 2147482623 ends with 1 bean still running after timeout of 30000ms: [webServerGracefulShutdown]' \
         '    INFO o.s.boot.tomcat.GracefulShutdown: Graceful shutdown aborted with one or more requests still active' '  events named customer-added: 1 · data lines: 1 · id lines: 0 · comment lines: 1'; do has "$FC" "$l" "feed C: no listener for the close - Framework's 30000ms line"; done
nhas "$FC" 'Graceful shutdown complete' "feed C: no clean shutdown without the listener"
nhas "$FC" '  the listener ended: curl exit 0' "feed C: the listener cut off, not ended"
echo "  feed: a JSON add, a form add, an upload's row - 3 customer-added events, no id; POST /shutdown with the listener connected: Graceful shutdown complete, curl exit 0, 0 timeout lines; C (the listener method's annotation out): the fork held (Surefire's line, 1), Framework's 30000ms line, Boot's aborted line"

# "eighteen tests, counted from Surefire's reports ... MockMvcTester waits"
TS=$(blk tests "TiffinBox's tests" "C (labelled)"); TSC=$(blk tests "C (labelled)" "")
for l in '    TEST-com.tiffinbox.web.TiffinBoxWebTest.xml: tests 14 · failures 0 · errors 0 · skipped 0' '    TEST-com.tiffinbox.web.FullStackTest.xml: tests 3 · failures 0 · errors 0 · skipped 0' '    TEST-com.tiffinbox.web.FeedTest.xml: tests 1 · failures 0 · errors 0 · skipped 0' \
         '    in all: 3 reports · tests 18 · failures 0 · errors 0 · skipped 0' '  Surefire'"'"'s own lines that a fork would not exit (Surefire is going to kill self fork JVM …): 0' \
         '      passed  aSixtyOneLetterNameIsRefused' '      passed  sixtyOneSpacesBreakBothRules' '      passed  anUploadAddsTheGoodRowAndNamesTheRest' '      passed  theFormIsAPage' '      passed  theFeedIsAnEventStream' \
         '      passed  aFailingRepositoryShowsTheErrorPage' '      passed  aListenerHearsANewCustomer' \
         '  after/'"'"'s test classes and their test methods (the @Test lines in each file): TiffinBoxWebTest 14 · FullStackTest 3 · FeedTest 1'; do has "$TS" "$l" "tests: the counts from Surefire's reports"; done
# R.144: the count is the reports' - the console's summary is shown beside it, and must agree, never stand alone
printf '%s\n' "$TS" | grep -qxF '    in all: 3 reports · tests 18 · failures 0 · errors 0 · skipped 0' && printf '%s\n' "$TS" | grep -qxF "  Surefire's console summary (its Results line): tests 18 · failures 0 · errors 0 · skipped 0 · the reports' sum the same: yes" || die "tests: the reports' 18, the console's summary beside them (R.144)"
for c in FullStackTest FeedTest; do has "$TS" "    CENSUS $c the web server: TomcatWebServer on port <port> · the port in macOS's ephemeral range (49152-65535): yes · in the course's range (19300-19799): no" "tests: $c on a random port (R.147)"
  l_=$(printf '%s\n' "$TS" | grep -E "^    CENSUS $c this test JVM's listening sockets " | sed 's/.*-sTCP:LISTEN): //')
  printf '%s\n' "$l_" | awk '{ gsub(/ 127\./, "\n127.") } 1' > .harness/socks.txt; grep -qxF '127.0.0.1:<port>' .harness/socks.txt && { grep -vE "^127\.0\.0\.1:<[a-z' ]+>\$" .harness/socks.txt > .harness/socks-not.txt; [ $? -le 1 ]; } && [ ! -s .harness/socks-not.txt ] || die "tests: $c's sockets loopback only (R.147) - a grep that cannot run fails here too (RED S6 #548)"; done
for l in '      ERROR  theTesterWaitsForTheStreamsEnd - java.lang.IllegalStateException' '        Async result for handler [com.tiffinbox.web.CustomerFeed#feed()] was not set during the specified timeToWait=0' '  exit 1 · BUILD FAILURE · offline: yes'; do has "$TSC" "$l" "tests C: MockMvcTester waits for an endless stream (R.161)"; done
echo "  tests: TiffinBoxWebTest 14, FullStackTest 3, FeedTest 1 - 18 from the reports, the console the same; no fork held; the random port's bind 127.0.0.1:<port>; C StreamWait: Async result … was not set"

# the exercise's end state: the README's commands, then the solution's, in ONE env -i shell
XS=$(blk exercise "the README's" "the solution's"); XE=$(blk exercise "the solution's" '')
X_SHIP='{"file":"customers.csv","added":0,"refused":{"line 1":"4 values expected, 1 found","line 2":"4 values expected, 1 found","line 3":"4 values expected, 1 found"}} 200'; X_END='{"file":"customers.csv","added":2,"refused":{}} 200'
has "$XS" "    $X_SHIP" "exercise: as shipped"; has "$XE" "    $X_END" "exercise: the solution"
nhas "$XE" "4 values expected" "exercise: the solution's upload refuses nothing"
awk '/^\*\*Done\*\*/ { f = 1 } f' exercise/README.md | grep -qxF -- "$X_END" || die "exercise/README.md: Done names no such line"
grep -qxF -- "$X_END" exercise/solution/SOLUTION.md && grep -qxF -- "$X_SHIP" exercise/README.md || die "exercise: the README and SOLUTION name the measured lines"
for b in "$XS" "$XE"; do printf '%s\n' "$b" | grep -qE "^  the shell is now in: this unit's folder · .* · listening on 19600 now: 0$" || die "exercise: the shell back in this folder, nothing listening"; done
EXQ="Your turn: the README's upload refuses every row of a good list. Read why, fix the file, and upload again."
grep -qxF -- "**Your turn:** ${EXQ#Your turn: }" exercise/README.md || die "exercise/README.md: the spoken exercise line"
[ "$(printf '%s\n' "$EXQ" | wc -w | tr -d ' ')" -le 25 ] || die "exercise: the spoken line is over 25 words"
echo "  exercise: one env -i shell - the README as written: added 0, every line '4 values expected, 1 found'; the solution: added 2, refused {}; the shell in this unit's folder after each, nothing listening"

# "the native build ran all eighteen tests first ... the same seven, messages, upload, event, page, and a clean shutdown, four times"
if [ -f .r-forms.out ]; then FM=$(cat .r-forms.out)
  x forms '^  exit 0 · BUILD SUCCESS · stages it printed: 8 of the 8 it announces · its lines that say the metadata repository was downloaded over http, or failed to: 0 · offline: yes$'
  x forms '^  file: Mach-O 64-bit executable · the demo token in its bytes: 0 · the tests'"'"' literal: 0 · a test class in it \(TiffinBoxWebTest, FullStackTest, FeedTest, WebSlice\): 0 0 0 0$'
  [ "$(cnt "$FM" '    in all: 3 reports · tests 18 · failures 0 · errors 0 · skipped 0')" = 1 ] && has "$FM" '  3 reports · tests 18 · failures 0 · errors 0 · skipped 0' "forms" || die "forms: the native install and the jar's build each ran the eighteen tests"
  has "$FM" "  Surefire's own lines that a fork would not exit: 0 · the demo token in the build's log and its reports: 0 times" "forms: the native install's fork exited"
  printf '%s\n' "$FM" | grep -qxF "four forms, one tree: the seven (masked) 4 of 4 times $S466 · the invalid customer's three messages: 4 of 4 · the size message in English: 5 (four with no Accept-Language, and the binary's with de) · in German: 3 · the upload's answer: 4 of 4 · the event it made: 4 of 4 · the page's title Dashboard · TiffinBox: 4 of 4 · Graceful shutdown complete with the listener connected: 4 of 4 · the listener ended, exit 0: 4 of 4" || die "forms: the summary - every check 4 of 4, German 3 (the binary English to de)"
  [ "$(awk '/^3 the binary/ { f = 1 } /^4 the image/ { f = 0 } f' .r-forms.out | grep -cF '"errors":{"name":"size must be between 0 and 60"}')" = 2 ] || die "forms: the binary answers de in English (S6.1)"
  has "$FM" '  loopback, form by form: the jar yes · the AOT jar yes · the binary yes · the image, published on 127.0.0.1 alone yes' "forms: loopback"
  [ "$(awk '/^3 the binary/ { f = 1 } /^4 the image/ { f = 0 } f' .r-forms.out | grep -cF "$THREE")" = 1 ] || die "forms: the binary's validation - the three messages (R.145)"
  x forms '^  its lines that say pull: 0 · '
  x forms '^  the image saved \(docker save\): [1-9][0-9]* blobs, its [1-9][0-9]* layers among them, each read whole \(gzip ones unpacked\) · the demo token in them: 0$'
  x forms '^  the Hibernate Validator metadata file this build made \(.*\): in target/classes and in the jar the same · its size: printed on the terminal, never hashed \(R\.145\)$'
  [ "$(n forms 'still running after timeout')" = 0 ] || die "forms: no form held its shutdown (R.159)"
  [ -s .harness/hv.txt ] && [ "$(grep -cvE '^(2306|157308)$' .harness/hv.txt)" = 0 ] || die "R.145: an HV file size per native build, 2306 or 157308 ($(paste -sd' ' .harness/hv.txt 2> /dev/null))"
  echo "  forms: 8 of 8 stages, offline, Mach-O, 0 tokens, no test class in the binary; 18 tests ran in the builds; jar, AOT jar, binary, image: the seven, the three messages, the size message, the upload, its event, the page, a graceful shutdown with a listener - 4 of 4 each; de: German 3, the binary English; 0 tokens in the image's layers; the HV file's sizes on the terminal: $(paste -sd' ' .harness/hv.txt 2> /dev/null)"
fi

cmp -s after/README.md ../c6-tiffinbox/README.md || echo "  (after/README.md and ../c6-tiffinbox/README.md differ - the anchor has moved past this unit's after/)" >&3
[ -z "$unpub" ] || die "no published hash for:$unpub - check the captures, then copy the md5s above into receipts.md5 and run again"
echo "c6-unit31: every capture 3/3 and = published; every spoken number asserted; 0 raw demo tokens in every capture, every Maven log and Surefire report, every JVM's and the container's log, the image's layers and the binary; nothing of this run left on Docker"
