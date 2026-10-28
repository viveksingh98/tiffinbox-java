#!/bin/bash
XPATH=$PATH                                           # the PATH you started this with: the exercise's own shell gets it
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25.0.4.1 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# GRAALVM_HOME names a GraalVM JDK 25 (README.md, "The GraalVM"): the native build reads it. Without it, this script makes every
# capture that needs no GraalVM, filling .m2-demo on the way, then stops before the native build.
# Course 6 · Testing the Web Layer - this unit's receipts. The anchor changes, for the only time in Section 5: TiffinBox gets its
# first tests. tiffinbox-web/pom.xml gains Boot's test starter for MVC (test scope) and the argLine property that pins the test JVM's
# locale; src/test gains WebSlice (the configuration the slice starts from, outside com.tiffinbox), TiffinBoxWebTest (a slice of
# the web layer, three mocks, MockMvc) and FullStackTest (the whole application on a random port). Seven captures, each run three
# times and hashed; cap() DIES when a hash differs from receipts.md5; every number the video says is asserted at the bottom by a
# check that can fail; the demo token is masked (gsub), and the checks count 0 raw copies of it in every capture, in the log of every
# run and every Maven build, in every Surefire report, in every file this unit ships, in the binary and in the image's layers.
#   change     the previous tree against after/: the files that differ and the new ones, the POM's diff whole; the seven on both
#              trees' jars, each a fresh JVM, line for line; both trees built with the README's line - the tests the build ran,
#              read from Surefire's reports; the starter's POM and the jars it adds to the tests' class path, counted, by scope;
#              the executable jars entry by entry, tiffinbox-core's jar byte for byte; the README's -DskipTests line; Maven's own
#              JVM under MAVEN_OPTS and the test JVM's locale in the same run
#   slice      @WebMvcTest alone (a copy, one line taken out of TiffinBoxWebTest); then A/B/A' - what the slice is pointed at: A
#              WebSlice as shipped, B TiffinBoxApp (a copy, one line changed), A' A again - each with the harness's Census: the
#              context's beans, TiffinBox's by the com.tiffinbox filter, the mocks, MockMvc's filters; the test that says the
#              database is left out; the whole application's context beside it; Mockito's and the JVM's console lines; C
#              (labelled) a copy of WebSlice inside com.tiffinbox: the whole application's context again
#   requests   TiffinBoxWebTest as shipped (the README's line), Census's EXCHANGE line for every answer MockMvc completed, and each
#              test's verdict; C (labelled) the same with the test JVM's locale made de_DE for the run (-DargLine); D (labelled) the
#              same with TiffinBox's problem-details key off for the run
#   untested   what the slice did not run: a repository that throws and a page whose dashboard throws (the harness's SliceLimits),
#              the chain every request ran in, MockMvc's against Tomcat's - REQUEST and ERROR - (the harness's Chains, on the
#              full stack); the servlet context and the web server each test ran on
#   fullstack  FullStackTest (Census: the bind, read off the test JVM's pid; the random port masked) and the harness's Answers (the
#              same setup, its answers printed); Tomcat's ERROR line, labelled; C (labelled) TestRestTemplate on this class path
#   exercise   exercise/README.md's commands, then exercise/solution/SOLUTION.md's, read from the files and run as written, one after
#              the other in ONE shell a viewer could have: env -i, /bin/bash, started in this folder
#   forms      the native build of after/ (the tests it ran; the Hibernate Validator metadata file's size on the terminal, R.145);
#              then four forms - the jar, the AOT jar, the binary, the image: each one's address, the seven (masked), exit 0; then,
#              on a second start of each, the invalid POST's three messages and the dashboard's page
# "The previous tree" is before/, the link to ../c6-unit24/after (the anchor before this change: the sessions lesson's frozen tree),
# COPIED under .harness/before; after/ is this unit's frozen copy of ../c6-tiffinbox after the change, COPIED under .harness/ for
# every build. This script never writes into another unit's folder, and never builds a frozen tree in place. Every run of TiffinBox
# starts in a folder under .harness/ that holds a config tree with a fake token (secrets/), as the README asks - the container's too,
# mounted read-only; every test runs in tiffinbox-web/ of such a folder, where no secrets/ is: the tests' token is a literal written
# in them. Commands are printed exactly as they run: each goes through eval. "$CURLSET" is the comparison set since the secrets
# lesson (../c5-unit11/curlset.sh: the seven requests, POST /shutdown with the token's header read from the file). "$M2" is this
# unit's own repository, .m2-demo. The harness - harness/test (copied into a copy's tiffinbox-web/src/test, never into after/):
# Census (a TestExecutionListener, named in harness/test/resources/META-INF/spring.factories), ChainDump and Traced (a filter that
# prints the chain it runs in, and its registration), SliceLimits, Chains, Answers and TemplateCheck (test classes Surefire runs only
# when -Dtest names them) - all in probe.web, outside com.tiffinbox; harness/surefire.py reads Surefire's reports; harness/shutdown.sh
# is POST /shutdown with the token read from its file (the CORS lesson's, byte for byte). The seven always run on a fresh JVM, first.
# The locale: the JVM ignores LC_ALL on macOS - every JVM this script starts has its locale pinned on its run line (-Duser.language=en
# -Duser.country=US, before -jar), and the checks refuse a java line without it. A test JVM is Surefire's own (a fork): Maven's options
# never reach it, the POM's argLine does - the same two options - and each run's reports say which locale the fork had. The binary
# takes no JVM options.
# The network: every Maven build runs offline (-o) against .m2-demo and says so ("offline: yes"); a build that cannot resolve an
# artifact offline goes to Maven Central once, and says that ("offline: no - ..."). GraalVM's native plugin reads its metadata
# repository (a zip) from .m2-demo - and when the zip is not there it downloads it from GitHub, even under -o: so a native-profile
# build without the zip goes to Maven Central for it at once, and every native build's log is searched for the plugin's own
# download line - found, the run stops. Docker: no pull - eclipse-temurin:25-jre must already be on the daemon. At run time nothing
# leaves 127.0.0.1: TiffinBox listens there (in a container, on the container's own addresses, published on the host's 127.0.0.1
# alone), every request goes there; a test's server listens on 127.0.0.1 too (application.yaml's address) on a port the system
# picks (RANDOM_PORT: macOS's ephemeral range, 49152-65535), read off the test JVM's pid and masked.
# Masks and filters (README.md declares each; awk sub/gsub only): the demo token becomes "[masked: the N-character token]"; the
# GraalVM's folder "$GRAALVM_HOME"; this folder's absolute path "…", the folder above it "…/..", the home folder "~"; your user name
# "<user>"; a Tomcat request thread's number "tomcat-handler-<n>"; the Java version in Boot's first line "Java <version>" (printed on
# the terminal once); a random port "<port>" (Census prints none); Spring's error timestamp "…" (both forms). A Maven log is never
# printed whole: its BUILD line, Surefire's console summary (beside the reports' sum), the harness's lines (CENSUS, EXCHANGE, CHAIN,
# LIMIT, ANSWER - in the order they ran, CENSUS sorted by its test class), its WARN and ERROR records (level, logger, message, the
# exception line under it; frames bounded "over 40", other lines counted) and Mockito's and the JVM's console lines (counted; shown
# once, in slice); the rest is counted, never shown. Surefire's reports are read by harness/surefire.py (counts, verdicts, the
# failure's first lines, the fork's locale) - never a time. A page (HTML) is its <title>; a JSON answer its bytes, keys sorted. No
# duration is captured: the native build's seconds, and the 20-minute bound, go to the terminal only; so does the Hibernate Validator
# metadata file's size (R.145: printed, never hashed).
# Ports (brief ⚑1, 19570-19574): after/'s jar 19570 · the AOT jar 19571 · the binary 19572 · the image 19573 (published on 127.0.0.1)
# · the previous tree's jar 19574. A test's server takes the port the system gives (above). 18425 (TiffinBox's default), 8080
# (Tomcat's) and 35729 (DevTools' Live Reload) are checked free too, and never bound on this machine (18425 only inside a container).
# Docker names (no unit number): the image tiffinbox-tests:1.0.0 and the container tiffinbox-tests. Each is checked absent before the
# first run - a name already there may be yours, and this script removes only what it creates - and removed on every exit.
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
IMG=tiffinbox-tests:1.0.0; BOX=tiffinbox-tests
OURS=""
U="$PWD"; UP="$(cd .. && pwd)"; ME="$(id -un)"
# On every exit - the end, a failed check, or Ctrl-C - stop the processes this script started in the background, if they still run:
# $pid (a server), $mpid (a Maven, with every process under it - Surefire's test JVM, the native image's builder), $xpid (the
# exercise's shell, with every process under it); then sweep(): anything of this run still alive in its process group - a TiffinBox
# JVM, a binary, a Maven, Surefire's fork, native-image's driver or builder - is stopped; then dclean(): this run's container and
# image. After an interrupt, a capture's unfinished runs (.r-NAME.1-3) go too; after a failed check they stay, for the diff the message
# names. The clean-up ignores a second Ctrl-C, and nothing in it can fail under set -e; the script still exits 130 after an interrupt
# (README.md, "Interrupted"). sweep() kills only processes of this run's own process group - start each run in a group of its own. No
# wait in this script is bare: each names its pid.
pid=""; mpid=""; xpid=""
sweep() { local g i l
  g=$(ps -o pgid= -p $$ 2> /dev/null | tr -d ' ') || g=""
  [ -n "$g" ] || return 0
  i=0; while [ $i -lt 20 ]; do
    l=$(ps -axo pid=,pgid=,command= 2> /dev/null | awk -v g="$g" -v me=$$ -v gh="${GRAALVM_HOME:-/nonexistent}" '
      $2 == g && $1 != me && $3 != "awk" && $3 != "ps" && (index($0, "vminvocation.args") || index($3, gh "/bin/native-image") || index($0, "com.oracle.svm") || $3 ~ /tiffinbox-web\/target\/tiffinbox-web$/ || index($0, "tiffinbox-web-1.0.0.jar") || index($0, "com.tiffinbox.web.TiffinBoxServer") || index($0, "surefirebooter") || index($0, "org.codehaus.plexus.classworlds.launcher.Launcher")) { print $1 }' | paste -sd' ' -) || l=""
    [ -n "$l" ] || return 0
    if [ $i -lt 10 ]; then kill $l 2> /dev/null || true; else kill -9 $l 2> /dev/null || true; fi
    sleep 0.5; i=$((i + 1)); done; }
# desc PID: every process under PID - its children, theirs, and so on (ps, by parent); killtree PID: PID and all of them, TERM
desc() { ps -axo pid=,ppid= 2> /dev/null | awk -v r="$1" '{ p[$1] = $2 } END { n = 1; q[1] = r; for (i = 1; i <= n; i++) for (c in p) if (p[c] == q[i]) { q[++n] = c; print c } }'; }
killtree() { local d; d=$(desc "$1"); kill "$1" $d 2> /dev/null || true; }
dclean() { [ -n "$OURS" ] || return 0
  docker rm -f "$BOX" > /dev/null 2>&1 || true
  docker image rm -f "$IMG" $(sort -u .harness/imgids 2> /dev/null) > /dev/null 2>&1 || true; }
trap 'trap "" INT TERM; for p in "$mpid" "$xpid"; do [ -z "$p" ] || killtree "$p"; done; for p in "$pid" "$mpid" "$xpid"; do if [ -n "$p" ] && kill "$p" 2> /dev/null; then wait "$p" 2> /dev/null || true; fi; done; sweep || true; dclean || true; [ -z "$INTR" ] || rm -f .r-*.[123]; rmdir .r-lock 2> /dev/null || true' EXIT
INTR=""; trap 'INTR=1; exit 130' INT TERM
exec 3>&1                                            # die() speaks to the terminal even inside a redirected capture
die() { echo "  *** $* ***" >&3; exit 1; }
java -version 2>&1 | grep -q 'version "25' || die "JDK 25 needed; JAVA_HOME gives: $(java -version 2>&1 | head -1)"
for t in python3 curl rsync lsof unzip mvn docker openssl md5 cmp; do command -v $t > /dev/null || die "$t is needed"; done
# A test's lsof (the harness's Census reads the test server's bind with it) is found through the PATH the test JVM inherits
case ":$PATH:" in *:/usr/sbin:*) ;; *) die "PATH must name /usr/sbin - the test JVM runs lsof from it (README.md, \"Run it\")" ;; esac
# A variable of yours must not become a property source, a JVM flag, a build setting, a native-image option or a docker build
# setting (the problem-detail lesson's loop, verbatim: sed -E, a canary planted under every name first, and the run stops if one
# survives). MAVEN_OPTS among them: this unit sets it for one command, on that command's own line.
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
[ -L before ] && [ "$(readlink before)" = ../c6-unit24/after ] || die "before must be the link to ../c6-unit24/after - the anchor before this change"
PREV=before
for t in "$PREV" after; do
  [ -f "$t/pom.xml" ] && [ -f "$t/README.md" ] && [ -f "$t/Dockerfile" ] && [ -f "$t/.dockerignore" ] || die "the tree $t (its pom.xml, README.md, Dockerfile or .dockerignore) is missing"
  [ -e "$t/secrets" ] || [ -e "$t/target" ] || [ -e "$t/tiffinbox-web/target" ] || [ -e "$t/tiffinbox-core/target" ] || [ -e "$t/tiffinbox-local.yaml" ] && die "$t holds a secrets/, a target/ or a tiffinbox-local.yaml - it is a frozen copy, never built in place"
  grep -qx 'secrets/' "$t/.dockerignore" || die "$t's .dockerignore no longer keeps secrets/ out of a build context"; done
M2="$PWD/.m2-demo"
TT=tiffinbox-web/src/test/java                      # the web module's test sources, in a tree
WT=$TT/com/tiffinbox/web/TiffinBoxWebTest.java      # the slice test, in a tree
SR=tiffinbox-web/target/surefire-reports            # Surefire's reports, in a built tree
JARP=tiffinbox-web/target/tiffinbox-web-1.0.0.jar    # the executable jar, in a tree's web module
CJAR=tiffinbox-core/target/tiffinbox-core-1.0.0.jar  # the core module's plain jar, in a built tree
BIN=tiffinbox-web/target/tiffinbox-web               # the binary native:compile-no-fork writes, in a tree's web module
TF=secrets/tiffinbox/shutdown-token                  # the config tree's file for tiffinbox.shutdown-token
HVF=META-INF/native-image/org.hibernate.validator/hibernate-validator/9.1.3.Final/reachability-metadata.json   # R.145's file
# The demo token. FAKE, and meant to look it: it guards nothing but a demo server on 127.0.0.1 that every capture stops. It is
# written into .harness/*/secrets/ (git-ignored) when this script runs, and no capture prints it: see mask().
TOKEN=demo-token-for-the-first-tests
[ ${#TOKEN} = 30 ] || die "the demo token must be 30 characters: the published captures name its length"
# The tests' token: a literal written in TiffinBoxWebTest, FullStackTest and the harness's tests - not a secret, and not the token
LIT=not-the-real-token
CURLSET=../c5-unit11/curlset.sh
[ -f "$CURLSET" ] || die "$CURLSET is missing"
HTS='Answers.java Census.java ChainDump.java Chains.java SliceLimits.java TemplateCheck.java Traced.java'
for f in harness/shutdown.sh harness/surefire.py harness/test/resources/META-INF/spring.factories exercise/README.md exercise/RevenueTest.java exercise/solution/SOLUTION.md README.md; do [ -f "$f" ] || die "$f is missing"; done
[ "$(ls harness/test/java/probe/web | paste -sd' ' -)" = "$HTS" ] || die "harness/test/java/probe/web holds another file: Maven compiles all of it"
[ "$(ls harness | paste -sd' ' -)" = 'shutdown.sh surefire.py test' ] && [ "$(ls harness/test | paste -sd' ' -)" = 'java resources' ] || die "harness/ holds another file"
[ "$(ls exercise | paste -sd' ' -)" = 'README.md RevenueTest.java solution' ] && [ "$(ls exercise/solution | paste -sd' ' -)" = 'SOLUTION.md' ] || die "exercise/ holds another file"
cmp -s harness/shutdown.sh ../c6-unit19/harness/shutdown.sh || die "harness/shutdown.sh is not the CORS lesson's (../c6-unit19/harness/shutdown.sh), byte for byte"
for f in after/$TT/slice/WebSlice.java after/$WT after/$TT/com/tiffinbox/web/FullStackTest.java; do [ -f "$f" ] || die "$f is missing - after/'s tests"; done
[ "$(cd after/$TT && find . -type f | sed 's#^\./##' | sort | paste -sd' ' -)" = 'com/tiffinbox/web/FullStackTest.java com/tiffinbox/web/TiffinBoxWebTest.java slice/WebSlice.java' ] || die "after/'s test sources hold another file"

listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
for p in 18425 8080 35729 19570 19571 19572 19573 19574; do
  [ "$(listeners $p)" = 0 ] || die "something already listens on $p - this unit's ports must be free; if it is a process an interrupted run left behind, stop it: kill $(lsof -nP -iTCP:$p -sTCP:LISTEN -t 2> /dev/null | paste -sd' ' -)"; done
[ -z "$(docker ps -aq --filter "name=^$BOX\$" 2> /dev/null)" ] || die "a container named $BOX exists - it may be yours, and this script removes only what it creates; remove it yourself (docker rm -f $BOX), then run again"
docker image inspect "$IMG" > /dev/null 2>&1 && die "an image named $IMG exists - it may be yours; remove it yourself (docker image rm $IMG), then run again"
OURS=yes


# ---- the commands: read from after/README.md, the anchor's own, and asserted - each line must be there, whole -------------
readme() { grep -m1 -xF -- "$1" after/README.md > /dev/null || die "after/README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
R_PLAIN=$(readme 'mvn -B package')
R_RUN=$(readme 'java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431')
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
# this unit's lines in the anchor's README: the tests, run by Maven
R_TEST=$(readme 'mvn -B clean test')
R_INST=$(readme 'mvn -B install')
R_TESTW=$(readme 'mvn -B -pl tiffinbox-web -Dtest=TiffinBoxWebTest clean test')
R_SKIP=$(readme 'mvn -q -DskipTests package')                  # Course 4's line: since this unit, -DskipTests skips something
# This unit's own lines (README.md, "The commands this unit adds") - each asserted to be exactly that
mine() { grep -m1 -xF -- "$1" README.md > /dev/null || die "README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
JL='-Duser.language=en -Duser.country=US'
L_RUNL=$(mine "java $JL -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431")
L_AOTL=$(mine "java $JL -Dspring.aot.enabled=true -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431")
L_DEPS=$(mine 'mvn -B package dependency:list -DoutputFile=target/deps.txt')
L_HC=$(mine 'rsync -a harness/test/ .harness/COPY/tiffinbox-web/src/test/')
F_="f=$WT"
L_ALONE=$(mine "$F_ && sed '/@ContextConfiguration(classes = WebSlice.class)/d' \"\$f\" > \"\$f.new\" && mv \"\$f.new\" \"\$f\"")
L_B=$(mine "$F_ && sed 's/@ContextConfiguration(classes = WebSlice.class)/@ContextConfiguration(classes = TiffinBoxApp.class)/' \"\$f\" > \"\$f.new\" && mv \"\$f.new\" \"\$f\"")
L_SLICE=$(mine "mvn -B -pl tiffinbox-web -Dtest='TiffinBoxWebTest#theSliceLeavesTheDatabaseOut,FullStackTest' clean test")
L_DE=$(mine "mvn -B -pl tiffinbox-web -Dtest=TiffinBoxWebTest '-DargLine=-Duser.language=de -Duser.country=DE' clean test")
L_PD=$(mine "mvn -B -pl tiffinbox-web -Dtest=TiffinBoxWebTest '-DargLine=-Duser.language=en -Duser.country=US -Dspring.mvc.problemdetails.enabled=false' clean test")
L_LIM=$(mine "mvn -B -pl tiffinbox-web -Dtest='TiffinBoxWebTest#aFailingRepositoryLeavesNoStatus,SliceLimits,Chains' clean test")
L_FULL=$(mine 'mvn -B -pl tiffinbox-web -Dtest=FullStackTest,Answers clean test')
L_INT=$(mine 'mvn -B -pl tiffinbox-web -Dtest=FullStackTest clean test')
L_IN=$(mine "sed 's/^package slice;/package com.tiffinbox.web;/; s/^public class WebSlice /public class WebSliceInside /' $TT/slice/WebSlice.java > $TT/com/tiffinbox/web/WebSliceInside.java")
L_TRT=$(mine 'mvn -B -pl tiffinbox-web -Dtest=TemplateCheck clean test')
MO_="MAVEN_OPTS='-Duser.language=de -Duser.country=DE'"
L_MV=$(mine "$MO_ mvn -v")
L_MO=$(mine "$MO_ mvn -B -pl tiffinbox-web -Dtest='TiffinBoxWebTest#theTestsRunInEnglish' clean test")
INV='{"name":"","mealsPerDay":0,"pricePerMeal":0,"mealType":"VEG"}'
L_INV=$(mine "curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '$INV' http://127.0.0.1:18431/customers")
# The derivations, each asserted: one change each, and nothing else
P_='java '; Q_="java $JL "; [ "${R_RUN/"$P_"/$Q_}" = "$L_RUNL" ] && [ "${R_AOTRUN/"$P_"/$Q_}" = "$L_AOTL" ] || die "the pinned lines must be the anchor's run lines with $JL after java, and nothing else"
[ "$R_PLAIN dependency:list -DoutputFile=target/deps.txt" = "$L_DEPS" ] || die "the deps line must be the README's package line with dependency:list writing target/deps.txt, and nothing else"
P_=' -Dtest=TiffinBoxWebTest '; for l_ in "$L_SLICE" "$L_LIM" "$L_FULL" "$L_INT" "$L_TRT"; do
  case $l_ in "mvn -B -pl tiffinbox-web -Dtest="*" clean test") o_=${l_#mvn -B -pl tiffinbox-web }; o_=${o_% clean test}; [ "${R_TESTW/"$P_"/ $o_ }" = "$l_" ] || die "not the README's test line with another -Dtest: $l_" ;; *) die "not the README's test line with another -Dtest: $l_" ;; esac
  case ${o_#-Dtest=} in *' '*) die "one -Dtest, no other option: $l_" ;; esac; done
# (a replacement that holds quotes goes in a variable: bash 3.2 and 5.3 treat quotes inside ${x/a/b} differently, within "...")
P_=' clean test'; Q_=" '-DargLine=-Duser.language=de -Duser.country=DE' clean test"; [ "${R_TESTW/"$P_"/$Q_}" = "$L_DE" ] || die "the de line must be the README's test line with -DargLine for de_DE, and nothing else"
Q_=" '-DargLine=$JL -Dspring.mvc.problemdetails.enabled=false' clean test"; [ "${R_TESTW/"$P_"/$Q_}" = "$L_PD" ] || die "the problem-details line must be the README's test line with -DargLine: the POM's locale and the key off, and nothing else"
P_='mvn -q '; Q_='mvn -o -B -Dmaven.repo.local="$M2" -q '; C_SKIP="cd .harness/after && ${R_SKIP/"$P_"/$Q_}"; C_SKIP=${C_SKIP/ package/ clean package}
[ "$C_SKIP" = "cd .harness/after && mvn -o -B -Dmaven.repo.local=\"\$M2\" -q -DskipTests clean package" ] || die "the skip line must be the README's with the offline changes and clean: $C_SKIP"
P_=' -Dtest=TiffinBoxWebTest '; Q_=" -Dtest='TiffinBoxWebTest#theTestsRunInEnglish' "; [ "$MO_ ${L_MO#"$MO_ "}" = "$L_MO" ] && [ "${L_MO#"$MO_ "}" = "${R_TESTW/"$P_"/$Q_}" ] || die "the MAVEN_OPTS line must be the README's test line, one test method named, MAVEN_OPTS before it, and nothing else"
P_="--data '{\"name\":\"Asha\",\"mealsPerDay\":2,\"pricePerMeal\":110,\"mealType\":\"VEG\"}'"; Q_="--data '$INV'"; [ "${R_POST/"$P_"/$Q_}" = "$L_INV" ] || die "the invalid POST must be the README's POST with the slice test's invalid customer, and nothing else"
off() { local c=${2/mvn -B /mvn -o -B -Dmaven.repo.local=\"\$M2\" }
  [ -n "${3:-}" ] && c=${c/ $3/ clean $3}
  printf 'cd %s && %s\n' "$1" "$c"; }
dev() { local c=${1#cd * && }; c=${c/ -o -B -Dmaven.repo.local=\"\$M2\" / -B }; c=${c/ clean package/ package}; c=${c/ clean install/ install}; printf '%s\n' "$c"; }
for c in "$(off .harness/x "$R_INSTALL" install)" "$(off .harness/x "$R_PLAIN" package)" "$(off .harness/x "$L_DEPS" package)" "$(off .harness/x "$R_NATIVE")" "$(off .harness/x "$R_TESTW")" "$(off .harness/x "$L_MO")"; do
  r=$(dev "$c"); [ "$r" = "$R_PLAIN" ] || [ "$r" = "$L_DEPS" ] || [ "$r" = "$R_INSTALL" ] || [ "$r" = "$R_NATIVE" ] || [ "$r" = "$R_TESTW" ] || [ "$r" = "$L_MO" ] || die "not a README line with the offline changes: $c"; done
# at DIR PORT 'README LINE': the README's line run from DIR, its port 18431 made PORT - a java line with the JVM's locale pinned
at() { local l=${3/--tiffinbox.port=18431/--tiffinbox.port=$2}; case $l in "java $JL "*) ;; 'java '*) l="java $JL ${l#java }" ;; esac; printf 'cd %s && %s\n' "$1" "$l"; }
url() { printf '%s\n' "${1/:18431\//:$2/}"; }
exe() { printf '%s\n' "$1" | sed -E 's/&& (([A-Z_]+=[^ ]* )*)/\&\& \1exec /'; }
UARG='--user "$(id -u):$(id -g)"'
dbuild() { local c=${R_DBUILD/docker build -t tiffinbox-docker:1.0.0 /docker build --progress=plain -t $IMG }; printf 'cd %s && %s\n' "$1" "$c"; }
drun() { local c=${R_DRUN/--name tiffinbox /--name $BOX $UARG }; c=${c/127.0.0.1:18431:18425/127.0.0.1:$2:18425}; c=${c/% tiffinbox-docker:1.0.0/ $IMG}; printf 'cd %s && %s\n' "$1" "$c"; }
undock() { local c=${1#cd * && }; c=${c/--progress=plain /}; c=${c/" $UARG"/}; c=${c//$IMG/tiffinbox-docker:1.0.0}; c=${c/--name $BOX /--name tiffinbox }; c=${c/127.0.0.1:1957?:18425/127.0.0.1:18431:18425}; printf '%s\n' "$c"; }
[ "$(undock "$(dbuild .harness/x)")" = "$R_DBUILD" ] || die "not the README's build line with the declared changes: $(dbuild .harness/x)"
[ "$(undock "$(drun .harness/x 19573)")" = "$R_DRUN" ] || die "not the README's run line with the declared changes: $(drun .harness/x 19573)"
[ "$(exe "$(at .harness/x 19570 "$R_RUN")")" = "cd .harness/x && exec ${L_RUNL/18431/19570}" ] && [ "$(at .harness/x 19571 "$R_AOTRUN")" = "cd .harness/x && ${L_AOTL/18431/19571}" ] && [ "$(at .harness/x 19572 "$R_BIN")" = 'cd .harness/x && tiffinbox-web/target/tiffinbox-web --tiffinbox.port=19572' ] || die "at(): the pinned lines are not README.md's, or the binary's line got the JVM's options"
echo "  the commands: after/README.md gives the $(grep -c '^R_[A-Z]*=$(readme ' receipts.sh) lines this script runs or derives from; README.md the $(grep -c '^L_[A-Z]*=$(mine ' receipts.sh) this unit adds"
JV=$(java -version 2>&1 | sed -n 's/.*version "\([^"]*\)".*/\1/p' | head -1)
echo "  (terminal only) the JDK is $JV - Boot's first line names it; the captures say Java <version>" >&3
# ---- build: before the captures - after/'s native-profile install: it fills .m2-demo on a fresh clone, runs the tests, and puts
# ---- both modules into $M2 (the -pl tiffinbox-web lines take tiffinbox-core from there) ----------------------------------------
rm -rf .harness; mkdir -p .harness; : > .harness/imgids
rsync -a --exclude target --exclude secrets after/ .harness/pre/
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
tree() { mkdir -p "$1/secrets/tiffinbox"; (umask 077 && printf '%s\n' "$TOKEN" > "$1/$TF"); chmod 700 "$1/secrets" "$1/secrets/tiffinbox"; }
C_PRE=$(off .harness/pre "$R_INSTALL" install)
mbuild "$C_PRE" .harness/build-pre.log ".harness/pre (after/, the profile native, both modules into \$M2; the tests ran)"
# the deps line once more, on the same copy: Maven's dependency plugin, which no build above uses, reaches .m2-demo before any capture
# (on a fresh clone this line says offline: no; a capture that fetched it would say so once, and drift)
C_PRED=$(off .harness/pre "$L_DEPS" package)
mbuild "$C_PRED" .harness/build-pred.log ".harness/pre (the README's package line with dependency:list - Maven's dependency plugin into \$M2)"
for a in org/apache/maven/plugins/maven-dependency-plugin org/springframework/boot/spring-boot-starter-webmvc-test/4.1.1/spring-boot-starter-webmvc-test-4.1.1.pom org/springframework/boot/spring-boot-webmvc-test/4.1.1/spring-boot-webmvc-test-4.1.1.jar org/graalvm/buildtools/native-maven-plugin/1.1.8/native-maven-plugin-1.1.8.jar com/tiffinbox/tiffinbox-core/1.0.0/tiffinbox-core-1.0.0.jar; do
  [ -e "$M2/$a" ] || die "$a is not in .m2-demo after the first build - README.md, The repository"; done
[ -f "$ZIP" ] || die "GraalVM's metadata repository is not in .m2-demo after the first build - README.md, The repository"
echo "  .m2-demo holds Boot's test starter for MVC and its modules, Maven's dependency plugin, GraalVM's native plugin 1.1.8 and its metadata repository, and TiffinBox's two modules"

# ---- helpers ------------------------------------------------------------------------------------------------------------
raw() { local t=$1; shift; cat "$@" 2> /dev/null | LC_ALL=C grep -aoF -- "$t" | wc -l | tr -d ' '; }
LOGS=0; CLOGS=0; MLOGS=0; LASTE=""
first() { grep -m1 -E ' : Starting |^main Starting ' "$1" | sed 's/^.* : //; s/^main //; s/ with PID .*$//; s/ using Java [0-9][0-9.]*/ using Java <version>/'; }
start() { echo "\$ $1"; (eval "$(exe "$1")") > .harness/run.out 2> .harness/run.err < /dev/null & pid=$!; }
addrs() { lsof -nP -a -p "$1" -iTCP -sTCP:LISTEN 2> /dev/null | awk 'NR > 1 { print $9 }' | sort -u | paste -sd' ' -; }
listening() { local a="" i=0
  while [ $i -lt 480 ]; do a=$(addrs "$1"); case " $a " in *":$2 "*) break ;; esac; kill -0 "$1" 2> /dev/null || break; sleep 0.25; i=$((i + 1)); done
  echo "${a:-nothing}"; }
lb() { local a n=0; for a in $1; do n=$((n + 1)); case $a in 127.0.0.1:*) ;; *) echo no; return ;; esac; done; [ $n -gt 0 ] && echo yes || echo no; }
# up PORT: the server $pid listens on PORT, loopback only; Boot's first line
up() { local l; l=$(listening "$pid" "$1"); [ "$l" != nothing ] || { tail -20 .harness/run.out >&3; die "it never listened on $1"; }
  case " $l " in *':8080 '*|*':35729 '*) kill -9 "$pid" 2> /dev/null || true; die "it listened on 8080 or 35729 - never bound by this script";; esac
  echo "  listens on: $l · loopback only: $(lb "$l")"; echo "  Boot's first line: $(first .harness/run.out)"; }
sortj() { python3 -c '
import json, re, sys
for l in sys.stdin.read().splitlines():
    b, _, s = l.rpartition(" ")
    try: o = json.dumps(json.loads(b), sort_keys=True, separators=(",", ":"), ensure_ascii=False)
    except ValueError: print("  " + l); continue
    print("  " + o + " " + s + ("    (keys sorted)" if o != b else ""))'; }
askj() { local c; c=$(url "$1" "$2"); echo "\$ $c"; (eval "$c") 2>&1 < /dev/null | sortj; }
ready() { local i=0 c=""
  while [ $i -lt 480 ]; do c=$(curl -s -o /dev/null -w '%{http_code}' "http://127.0.0.1:$1/actuator/health/readiness" 2> /dev/null || true); [ "$c" = 200 ] && break
    if [ -n "$pid" ]; then kill -0 "$pid" 2> /dev/null || { tail -20 .harness/run.out >&3; die "it exited before readiness answered 200"; }; fi
    if [ -n "${2:-}" ]; then [ "$(docker inspect -f '{{.State.Running}}' "$2" 2> /dev/null)" = true ] || { docker logs "$2" 2>&1 | tail -20 >&3; die "the container exited before readiness answered 200"; }; fi
    sleep 0.25; i=$((i + 1)); done
  [ "$c" = 200 ] || die "readiness never answered 200 on $1"
  askj "$R_READY" "$1"; }
logtok() { local t h; t=$(raw "$TOKEN" .harness/run.out .harness/run.err); h=$(cat .harness/run.out .harness/run.err | LC_ALL=C grep -aoi -- 'x-shutdown-token' | wc -l | tr -d ' ')
  LOGS=$((LOGS + 1)); [ "$t" = 0 ] && [ "$h" = 0 ] || die "a log held the demo token ($t) or its header's name ($h)"
  echo "  its log: the demo token 0 times · X-Shutdown-Token $h times"; }
tsmask() { awk '{ gsub(/"timestamp":"[^"]*"/, "\"timestamp\":\"…\""); gsub(/"timestamp":[0-9]+/, "\"timestamp\":…"); print }'; }
gone() { local i=0 e=0
  while kill -0 "$pid" 2> /dev/null && [ $i -lt 60 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$pid" 2> /dev/null && { kill "$pid"; die "the server on $1 was still running 15 s after POST /shutdown"; }
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
stop() { post "$1" "$2"; gone "$1"; echo "  exit $LASTE · listening on $1 now: 0"; logtok; }
lvl() { grep -cE "^[0-9]{4}-[0-9]{2}-[0-9]{2}T[^ ]+ +$1 " "$2" || true; }
mask() { awk -v t="$TOKEN" -v g="${GRAALVM_HOME:-}" -v u="$U" -v up="$UP" -v hm="$HOME" -v me="$ME" -v tl="${#TOKEN}" '
  function lit(x) { gsub(/[][\\.^$*+?(){}|\/]/, "\\\\&", x); return x }
  function enc(x) { gsub(/ /, "%20", x); return x }
  BEGIN { T = lit(t); G = lit(g); GE = lit(enc(g)); P = lit(u); Q = lit(up); H = lit(hm); PE = lit(enc(u)); QE = lit(enc(up)); M = "(^|[^A-Za-z0-9_])" lit(me) "([^A-Za-z0-9_]|$)" }
  { gsub(T, "[masked: the " tl "-character token]"); if (g != "") { gsub(G, "$GRAALVM_HOME"); gsub(GE, "$GRAALVM_HOME") }; gsub(P, "…"); gsub(PE, "…")
    gsub(Q, "…/.."); gsub(QE, "…/.."); gsub(H, "~"); gsub(/\$\$SpringCGLIB\$\$[0-9]+/, "$$SpringCGLIB$$<n>")
    gsub(/tomcat-handler-[0-9]+/, "tomcat-handler-<n>"); gsub(/ using Java [0-9][0-9.]+/, " using Java <version>")
    while (match($0, M)) { pre = substr($0, 1, RSTART - 1); s = substr($0, RSTART, RLENGTH); post = substr($0, RSTART + RLENGTH)
      sub(lit(me), "<user>", s); $0 = pre s post }
    print }'; }

unpub=""
cap() { local nm=$1 h pub i; shift
  for i in 1 2 3; do "$@" > .harness/cap.raw 2>&1 || true; [ -z "$pid$mpid$xpid" ] || die "$nm left a process running"
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
copy() { rm -rf "$2" "$2".*; rsync -a --exclude target --exclude secrets "$1/" "$2/"; tree "$2"; }
# hcopy NAME: after/ copied to .harness/NAME, the harness's test sources and resources added to its web module (this unit's line)
hcopy() { local c=${L_HC/COPY/$1}; copy after ".harness/$1"; echo "\$ $c"; (eval "$c") < /dev/null || die "$c failed"
  echo "  the copy's test sources now: $(cd ".harness/$1/$TT" && find . -name '*.java' | sed 's#^\./##' | sort | sed 's#.*/##' | paste -sd' ' -) · its test resources: $(cd ".harness/$1/tiffinbox-web/src/test/resources" && find . -type f | sed 's#^\./##' | paste -sd' ' -)"; }
lines() { if [ -f "$1" ]; then wc -l < "$1" | tr -d ' '; else echo none; fi; }
libs() { unzip -Z1 "$1" | grep -E '^BOOT-INF/lib/.*\.jar$' | sed 's#^BOOT-INF/lib/##' | sort; }
cdiff() { diff -U0 "$1" "$2" | tail -n +3 > .harness/code.diff || true
  echo "  its diff (diff -U0, its file names cut) - hunks: $(grep -c '^@@ ' .harness/code.diff || true) · lines out: $(grep -c '^-' .harness/code.diff || true) · in: $(grep -c '^+' .harness/code.diff || true) - whole:"
  sed 's/^/    /' .harness/code.diff; }

# ---- a Maven run of the tests, read: its command, its BUILD line, Surefire's reports (surefire.py), the console's summary beside
# ---- them, the harness's lines, its WARN and ERROR records, Mockito's and the JVM's lines, what was not shown; the tokens counted
# summ LOG: Surefire's console summary - its last "Tests run:" line without " -- in " (the Results line), its four numbers
summ() { grep -E '^\[(INFO|ERROR|WARNING)\] Tests run: [0-9]+, Failures: [0-9]+, Errors: [0-9]+, Skipped: [0-9]+$' "$1" | tail -1 | sed -E 's/.*Tests run: ([0-9]+), Failures: ([0-9]+), Errors: ([0-9]+), Skipped: ([0-9]+)$/tests \1 · failures \2 · errors \3 · skipped \4/'; }
HL='^(CENSUS|EXCHANGE|CHAIN|LIMIT|ANSWER) '
# dec: the harness prints ASCII (the test JVM's console under LC_ALL=C is), each other character as a backslash, u and four hex
# digits (Census.print); this turns each back into its character, UTF-8 - nothing else in a line changes
dec() { python3 -c 'import re, sys; sys.stdout.buffer.write(re.sub(r"\\u([0-9a-f]{4})", lambda m: chr(int(m.group(1), 16)), sys.stdin.buffer.read().decode("ascii")).encode("utf-8"))'; }
JVMLINES='^(Mockito is currently self-attaching|WARNING: |OpenJDK 64-Bit Server VM warning: )'
# recs LOG: every WARN and ERROR record of Boot's log format in a Maven log: level, logger, message; the exception line under it; its
# frames counted (bounded) and its other lines counted. A record ends at the next log line, Maven line or harness line. An object's
# identity hash (@1a2b3c…) becomes "@…"; a message or exception line over 200 characters is cut there, the rest counted.
recs() { awk '
  function out() { if (inr) print "      its stack frames: " (fr > 40 ? "over 40" : fr + 0) ", its other lines: " (ot + 0) " - none shown"; inr = 0; fr = 0; ot = 0; ex = 0 }
  /^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T[^ ]+ +[A-Z]+ [0-9]+ --- \[/ || /^\[(INFO|ERROR|WARNING)\]/ || /^(CENSUS|EXCHANGE|CHAIN|LIMIT|ANSWER) / || /^(Mockito is currently self-attaching|WARNING: |OpenJDK 64-Bit Server VM warning: )/ { out() }
  /^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T[^ ]+ +(WARN|ERROR) [0-9]+ --- \[/ { s = $0; i = index(s, " --- ["); s = substr(s, i + 6); i = index(s, "] "); s = substr(s, i + 2)
    i = index(s, " : "); lg = substr(s, 1, i - 1); sub(/ +$/, "", lg); m = substr(s, i + 3); gsub(/@[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]+/, "@…", m)
    if (length(m) > 200) m = substr(m, 1, 200) " … (" length(m) - 200 " more characters)"
    print "    " $2 " " lg ": " m; inr = 1; ex = 1; next }
  inr && /^\tat / { fr++; next }
  inr && ex && NF > 0 { x = $0; gsub(/@[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]+/, "@…", x); if (length(x) > 200) x = substr(x, 1, 200) " … (" length(x) - 200 " more characters)"; print "      " x; ex = 0; next }
  inr { ot++ }
  END { out() }' "$1"; }
# mrun NAME DIR 'COMMAND' [show]: COMMAND run in DIR (Maven started in the background and waited for by its pid, so an interrupt
# stops it and its test JVM); then the reading above. With "show", Mockito's and the JVM's lines are printed, labelled - once, in slice.
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
  if grep -qE "$HL" ".harness/$1.log"; then echo "  the harness's lines, in the order they ran (CENSUS sorted by test class; its \\u escapes decoded):"
    grep -E '^CENSUS ' ".harness/$1.log" | sort -s -k2,2 | dec | sed 's/^/    /'
    grep -E '^(EXCHANGE|CHAIN|LIMIT|ANSWER) ' ".harness/$1.log" | dec | sed 's/^/    /'; fi
  if [ "${4:-}" = show ]; then echo "  Mockito's line and the JVM's - printed on the console by Mockito (its inline mock maker attaching itself) and by the JVM (that attach), not by a logger; sorted (the JVM's own warning and the others reach the log in either order):"
    grep -E "$JVMLINES" ".harness/$1.log" | sort | sed 's/^/    /'; fi
  echo "  Mockito's lines: $(grep -c '^Mockito is currently self-attaching' ".harness/$1.log" || true) · the JVM's (WARNING: …, OpenJDK 64-Bit Server VM warning: …): $(grep -cE '^(WARNING: |OpenJDK 64-Bit Server VM warning: )' ".harness/$1.log" || true)"
  echo "  its log's WARN lines: $(lvl WARN ".harness/$1.log") · ERROR lines: $(lvl ERROR ".harness/$1.log")$( [ "$(lvl WARN ".harness/$1.log")$(lvl ERROR ".harness/$1.log")" = 00 ] || echo ' - each record:')"
  recs ".harness/$1.log"
  echo "  its other lines: $(grep -cvE "$HL|$JVMLINES|^[0-9]{4}-[0-9]{2}-[0-9]{2}T[^ ]+ +(WARN|ERROR) |^\[(INFO|ERROR|WARNING)\] (BUILD |Tests run: )" ".harness/$1.log" || true) - Maven's, Boot's banner and INFO lines, the frames above - not shown"
  t=$(raw "$TOKEN" ".harness/$1.log" "$2/$SR"/*); MLOGS=$((MLOGS + 1))
  [ "$t" = 0 ] || die "$1: the demo token is in the Maven log or a Surefire report ($t)"
  echo "  the demo token in the Maven log and every report: 0 times · the tests' literal, $LIT (written in the tests, not a secret): $(raw "$LIT" ".harness/$1.log" "$2/$SR"/*) times"; }

# ---- change: the tests' starter, the argLine, three test sources ---------------------------------------------------------------------
change() { local f n m k
  echo "the previous tree and after/, both copied under .harness/ with a config tree:"
  copy "$PREV" .harness/before; copy after .harness/after
  echo "the files that differ, and the files only one tree has:"
  echo "\$ diff -rq -x target -x secrets .harness/before .harness/after"
  diff -rq -x target -x secrets .harness/before .harness/after | sed 's/^/  /' || true
  (cd after && find . -type f | sed 's#^\./##' | sort) > .harness/files.txt
  n=0; m=0; k=0; while IFS= read -r f; do m=$((m + 1)); if [ ! -e ".harness/before/$f" ]; then k=$((k + 1)); echo "  new: $f - $(lines "after/$f") lines"; elif cmp -s ".harness/before/$f" ".harness/after/$f"; then n=$((n + 1)); fi; done < .harness/files.txt
  echo "  after/'s files: $m · byte for byte the previous tree's: $n · new: $k · those that differ: $((m - n - k))"
  f=tiffinbox-web/pom.xml; echo "  $f: $(lines ".harness/before/$f") lines -> $(lines ".harness/after/$f")"; cdiff ".harness/before/$f" ".harness/after/$f"
  diff .harness/before/README.md .harness/after/README.md > .harness/file.diff || true
  echo "  README.md - the anchor's README: lines added $(grep -c '^> ' .harness/file.diff || true), removed $(grep -c '^< ' .harness/file.diff || true) - its new section and the history notes the change made false (not shown)"
  echo "  where the POM's new lines sit: inside <build>: $(awk '/<build>/ { b = 1 } /<\/build>/ { b = 0 } b && /argLine|spring-boot-starter-webmvc-test|<scope>test</' .harness/after/$f | grep -c . || true) · <build> itself, line for line the previous tree's: $(diff <(sed -n '/<build>/,/<\/build>/p' .harness/before/$f) <(sed -n '/<build>/,/<\/build>/p' .harness/after/$f) > /dev/null && echo yes || echo no)"
  echo "the seven - each tree's jar, a fresh JVM each (the previous tree on 19574, after/ on 19570), built first with the README's package line, offline:"
  c=$(off .harness/before "$L_DEPS" package); echo "\$ $c"; mbuild "$c" .harness/before.build.log "the previous tree"
  c=$(off .harness/after "$L_DEPS" package); echo "\$ $c"; mbuild "$c" .harness/after.build.log "after/"
  start "$(at .harness/before 19574 "$R_RUN")"; up 19574; ready 19574; seven 19574 .harness/before; cp .harness/responses.m.txt .harness/seven-before.txt
  start "$(at .harness/after 19570 "$R_RUN")"; up 19570; ready 19570; seven 19570 .harness/after; cp .harness/responses.m.txt .harness/seven-after.txt
  echo "  lines that differ: $(diff .harness/seven-before.txt .harness/seven-after.txt | grep -c '^[<>]' || true) · the same, byte for byte: $(awk 'NR == FNR { a[FNR] = $0; next } a[FNR] == $0 { n++; l = l " " FNR } END { print n + 0 " (" substr(l, 2) ")" }' .harness/seven-before.txt .harness/seven-after.txt)"
  echo "what each build ran - Surefire's reports, and the console's summary (the README's package line runs the tests now):"
  for t in before after; do [ $t = before ] && echo "  the previous tree's build:" || echo "  after/'s build:"
    python3 -I harness/surefire.py ".harness/$t/$SR" | sed 's/^/  /'
    echo "    Surefire's console summary (its Results line): $(summ .harness/$t.build.log | grep . || echo none) · lines that say No tests to run: $(grep -c 'No tests to run' .harness/$t.build.log || true) · the plugin, as Maven names its goal: $(grep -oE 'surefire:[0-9.]+:test' .harness/$t.build.log | sort -u | paste -sd' ' -)"; done
  echo "the README's Course 4 line, -DskipTests - after/ copied afresh (.harness/skip), offline:"
  copy after .harness/skip; c=${C_SKIP/.harness\/after/.harness\/skip}; echo "\$ $c"
  e=0; (eval "$c") > .harness/skip.log 2>&1 < /dev/null & mpid=$!; wait "$mpid" || e=$?; mpid=""
  echo "  exit $e · what it printed (-q): $(grep -c . .harness/skip.log || true) lines · Surefire's reports: $(ls .harness/skip/$SR/TEST-*.xml 2> /dev/null | grep -c . || true) · the jar: $( [ -f .harness/skip/$JARP ] && echo built || echo none) · its BOOT-INF/lib the same 61 names: $(libs .harness/skip/$JARP | cmp -s - <(libs .harness/after/$JARP) 2> /dev/null && echo yes || echo no)"
  echo "the starter's own POM (in .m2-demo, org/springframework/boot/spring-boot-starter-webmvc-test/4.1.1/), its dependencies:"
  python3 - "$M2/org/springframework/boot/spring-boot-starter-webmvc-test/4.1.1/spring-boot-starter-webmvc-test-4.1.1.pom" .harness/before/tiffinbox-web/target/deps.txt <<'PY'
import re, sys, xml.etree.ElementTree as ET
ns = {"m": "http://maven.apache.org/POM/4.0.0"}
r = ET.parse(sys.argv[1]).getroot()
before = open(sys.argv[2]).read()
ds = r.findall("m:dependencies/m:dependency", ns)
print("  %d dependencies:" % len(ds))
n = 0
for d in ds:
    g, a, v, s = (d.findtext("m:" + k, "", ns) for k in ("groupId", "artifactId", "version", "scope"))
    on = (" %s:%s:jar:" % (g, a)) in before or ("\n   %s:%s:jar:" % (g, a)) in before
    n += 0 if on else 1
    print("    %s:%s:%s (%s) - on the previous tree's class path already: %s" % (g, a, v, s, "yes" if on else "no"))
print("  the starter's dependencies new to TiffinBox: %d" % n)
PY
  echo "the class path Maven resolved for tiffinbox-web, each tree (dependency:list, target/deps.txt), by scope:"
  for t in before after; do sed -n 's/^   \([^ ]*\) -- .*/\1/p' .harness/$t/tiffinbox-web/target/deps.txt | sort > .harness/deps-$t.txt; done
  echo "  the previous tree: $(wc -l < .harness/deps-before.txt | tr -d ' ') artifacts - compile $(grep -c ':compile$' .harness/deps-before.txt || true), runtime $(grep -c ':runtime$' .harness/deps-before.txt || true), test $(grep -c ':test$' .harness/deps-before.txt || true) · after/: $(wc -l < .harness/deps-after.txt | tr -d ' ') - compile $(grep -c ':compile$' .harness/deps-after.txt || true), runtime $(grep -c ':runtime$' .harness/deps-after.txt || true), test $(grep -c ':test$' .harness/deps-after.txt || true)"
  echo "  only after/'s (comm -13), each in test scope: $(comm -13 .harness/deps-before.txt .harness/deps-after.txt | grep -c . || true) - all of them:"
  comm -13 .harness/deps-before.txt .harness/deps-after.txt | sed 's/^/    /'
  echo "  only the previous tree's: $(comm -23 .harness/deps-before.txt .harness/deps-after.txt | grep -c . || true) · Boot's RestClient module (spring-boot-restclient) on after/'s test class path: $(grep -c ':spring-boot-restclient:' .harness/deps-after.txt || true) · TestRestTemplate's own module (spring-boot-resttestclient): $(grep -c ':spring-boot-resttestclient:' .harness/deps-after.txt || true)"
  echo "  the classes the tests use, each read off the jar that holds it on after/'s test class path (unzip -Z1 of every jar dependency:list names, in .m2-demo):"
  python3 - "$M2" .harness/deps-after.txt <<'PY2'
import os, sys, zipfile
m2, lst = sys.argv[1], sys.argv[2]
jars = []
for l in open(lst):
    g, a, t, v, sc = l.strip().split(":")          # groupId:artifactId:type:version:scope - dependency:list's form here (no classifier)
    jars.append(os.path.join(m2, g.replace(".", "/"), a, v, "%s-%s.jar" % (a, v)))
names = {os.path.basename(j): set(zipfile.ZipFile(j).namelist()) for j in jars if os.path.exists(j) and zipfile.is_zipfile(j)}
for c in ("org.springframework.boot.webmvc.test.autoconfigure.WebMvcTest", "org.springframework.boot.test.context.SpringBootTest",
          "org.springframework.test.web.servlet.MockMvc", "org.springframework.test.web.servlet.assertj.MockMvcTester",
          "org.springframework.test.context.bean.override.mockito.MockitoBean", "org.springframework.test.web.servlet.client.RestTestClient",
          "org.springframework.boot.resttestclient.autoconfigure.AutoConfigureRestTestClient", "org.springframework.boot.resttestclient.TestRestTemplate",
          "org.springframework.boot.context.TypeExcludeFilter", "org.mockito.Mockito"):
    e = c.replace(".", "/") + ".class"
    print("    %s - %s" % (c.rsplit(".", 1)[1], " ".join(sorted(k for k, v in names.items() if e in v)) or "in no jar"))
mb = sorted(k for k, v in names.items() for e in v if e.endswith("/MockBean.class"))
print("    a class named MockBean, in any of these %d jars: %s" % (len(names), " ".join(mb) or "none"))
PY2
  libs .harness/before/$JARP > .harness/lb.txt; libs .harness/after/$JARP > .harness/la.txt
  echo "the executable jar's BOOT-INF/lib: $(wc -l < .harness/lb.txt | tr -d ' ') jars -> $(wc -l < .harness/la.txt | tr -d ' ') · the same names: $(cmp -s .harness/lb.txt .harness/la.txt && echo yes || echo no)"
  echo "the two executable jars, entry by entry (unzip, each entry's bytes compared):"
  python3 - .harness/before/$JARP .harness/after/$JARP <<'PY'
import sys, zipfile
a, b = (zipfile.ZipFile(p) for p in sys.argv[1:3])
na, nb = set(a.namelist()), set(b.namelist())
diff = sorted(n for n in na & nb if a.read(n) != b.read(n))
print("  entries: %d -> %d · only in the previous tree's: %d · only in after/'s: %d · in both, bytes that differ: %d - %s" % (len(na), len(nb), len(na - nb), len(nb - na), len(diff), ", ".join(diff) or "none"))
PY
  echo "  the jar files themselves, byte for byte: $(cmp -s .harness/before/$JARP .harness/after/$JARP && echo the same || echo different) · tiffinbox-core's jar ($CJAR), byte for byte: $(cmp -s .harness/before/$CJAR .harness/after/$CJAR && echo the same || echo different) · after/'s jar holds a test class: $(unzip -Z1 .harness/after/$JARP | grep -cE 'Test\.class$|/slice/' || true)"
  echo "Maven's own JVM and the test JVM - MAVEN_OPTS for one command each, its words de_DE; the second runs one test, in after/'s copy:"
  echo "\$ cd .harness/after && $L_MV"
  (cd .harness/after && eval "$L_MV") > .harness/mv.log 2>&1 < /dev/null || die "mvn -v failed"
  echo "  its line that names the locale (the others - Maven's, Java's and the system's versions and folders - not shown): $(grep -m1 '^Default locale: ' .harness/mv.log | sed 's/, platform encoding.*//')"
  mrun mopts .harness/after "$(off .harness/after "$L_MO" | sed 's/^cd [^ ]* && //')"
  echo "  the test's own line: $(grep -m1 "^the test JVM's locale: " .harness/mopts.log || echo none)"; }

# ---- slice: alone; A/B/A' - what the slice is pointed at --------------------------------------------------------------------------
slice() { local c
  echo "TiffinBoxApp - after/'s tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxApp.java, its annotations (the class's other lines not shown):"
  grep -E '^@' after/tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxApp.java | sed 's/^/  /'
  echo "  a @SpringBootConfiguration or @SpringBootApplication anywhere in after/'s main sources: $(grep -rlE '@SpringBoot(Configuration|Application)' after/tiffinbox-web/src/main after/tiffinbox-core/src/main | grep -c . || true) files · in its test sources: $(grep -rlE '^@SpringBootConfiguration' after/$TT | sed "s#^after/$TT/##" | paste -sd' ' -)"
  echo "  the three classes the slice mocks, as tiffinbox-core declares them: $(for c in CustomerRepository Dashboard OrderQueue; do grep -hE "^public (final )?class $c" after/tiffinbox-core/src/main/java/com/tiffinbox/$c.java | sed 's/ {$//; s/ implements .*//'; done | paste -sd'|' - | sed 's/|/ · /g')"
  echo "WebSlice - after/'s $TT/slice/WebSlice.java, its package and annotations:"
  grep -E '^(package |@|        excludeFilters)' after/$TT/slice/WebSlice.java | sed 's/^/  /'
  echo "the slice alone - a copy of after/ (.harness/alone), TiffinBoxWebTest's @ContextConfiguration line taken out (this unit's line); TiffinBoxWebTest alone:"
  copy after .harness/alone; c=$(printf '%s\n' "$L_ALONE"); echo "\$ cd .harness/alone && $c"; (cd .harness/alone && eval "$c") < /dev/null || die "the sed failed"
  cdiff after/$WT .harness/alone/$WT
  mrun alone .harness/alone "$(off .harness/alone "$R_TESTW" | sed 's/^cd [^ ]* && //')"
  echo "A - after/ as shipped, the harness's Census joined (.harness/sliceA); TiffinBoxWebTest's one test that the database is left out, and FullStackTest:"
  hcopy sliceA
  mrun sliceA .harness/sliceA "$(off .harness/sliceA "$L_SLICE" | sed 's/^cd [^ ]* && //')" show
  echo "B - the slice pointed at TiffinBoxApp (.harness/sliceB: the copy, its @ContextConfiguration line changed - this unit's line):"
  hcopy sliceB; c=$(printf '%s\n' "$L_B"); echo "\$ cd .harness/sliceB && $c"; (cd .harness/sliceB && eval "$c") < /dev/null || die "the sed failed"
  cdiff after/$WT .harness/sliceB/$WT
  mrun sliceB .harness/sliceB "$(off .harness/sliceB "$L_SLICE" | sed 's/^cd [^ ]* && //')"
  echo "A' - A again (.harness/sliceA, copied afresh):"
  hcopy sliceA
  mrun sliceA2 .harness/sliceA "$(off .harness/sliceA "$L_SLICE" | sed 's/^cd [^ ]* && //')"
  awk "/^A - after/ { f = 1 } /^B - the slice/ { f = 0 } f" .harness/cap.raw | sed 1d | grep -vE "^  Mockito's line and the JVM's - printed|^    (Mockito is currently self-attaching|WARNING: |OpenJDK 64-Bit Server VM warning: )" > .harness/a1.txt || true
  awk "/^A' - A again/ { f = 1 } f" .harness/cap.raw | sed 1d > .harness/a2.txt
  echo "A' against A, its label aside and the console lines A showed once, line for line the same: $(cmp -s .harness/a1.txt .harness/a2.txt && [ -s .harness/a1.txt ] && echo yes || echo no)"
  echo "C (labelled) - a copy of WebSlice inside com.tiffinbox, beside the one in slice (.harness/sliceC: this unit's line); FullStackTest, the whole application:"
  hcopy sliceC; c=$(printf '%s\n' "$L_IN"); echo "\$ cd .harness/sliceC && $c"; (cd .harness/sliceC && eval "$c") < /dev/null || die "the sed failed"
  echo "  the copy's com/tiffinbox/web/WebSliceInside.java against slice/WebSlice.java:"; cdiff after/$TT/slice/WebSlice.java .harness/sliceC/$TT/com/tiffinbox/web/WebSliceInside.java
  mrun sliceC .harness/sliceC "$(off .harness/sliceC "$L_INT" | sed 's/^cd [^ ]* && //')"; }

# ---- requests: the slice's answers, without a socket ------------------------------------------------------------------------------
requests() {
  echo "TiffinBoxWebTest - after/ as shipped, Census joined (.harness/req), the README's line; every answer MockMvc completed (EXCHANGE):"
  hcopy req
  mrun req .harness/req "$(off .harness/req "$R_TESTW" | sed 's/^cd [^ ]* && //')"
  echo "  the test's own line: $(grep -m1 "^the test JVM's locale: " .harness/req.log || echo none)"
  echo "C (labelled) - the same copy, the test JVM's locale de_DE for this run: -DargLine replaces the POM's argLine (this unit's line):"
  mrun reqde .harness/req "$(off .harness/req "$L_DE" | sed 's/^cd [^ ]* && //')"
  echo "  the test's own line: $(grep -m1 "^the test JVM's locale: " .harness/reqde.log || echo none)"
  echo "D (labelled) - the same copy, TiffinBox's problem-details key switched off for this run: -DargLine, the POM's locale and the key (this unit's line):"
  echo "  the key in after/'s application.yaml: $(awk '/^  mvc:$/ { m = 1; next } m && /^    problemdetails:$/ { p = 1; next } p && /^      enabled: / { print "spring.mvc.problemdetails.enabled: " $2 " (line " NR ")"; exit }' after/tiffinbox-web/src/main/resources/application.yaml)"
  mrun reqpd .harness/req "$(off .harness/req "$L_PD" | sed 's/^cd [^ ]* && //')"; }

# ---- untested: what the slice did not run ---------------------------------------------------------------------------------------------
untested() {
  echo "a failure nobody handled, in the slice and on Tomcat - after/, Census, Traced (ChainDump for the REQUEST and the ERROR dispatch), SliceLimits and Chains (.harness/lim):"
  hcopy lim
  mrun lim .harness/lim "$(off .harness/lim "$L_LIM" | sed 's/^cd [^ ]* && //')"; }

# ---- fullstack: the real server ----------------------------------------------------------------------------------------------------
fullstack() {
  echo "FullStackTest, and the harness's Answers (the same setup, its answers printed) - after/, Census joined (.harness/full):"
  hcopy full
  echo "  the system's own range for a port it picks (sysctl net.inet.ip.portrange, on this Mac): $(sysctl -n net.inet.ip.portrange.first 2> /dev/null)-$(sysctl -n net.inet.ip.portrange.last 2> /dev/null)"
  mrun full .harness/full "$(off .harness/full "$L_FULL" | sed 's/^cd [^ ]* && //')"
  echo "C (labelled) - TestRestTemplate (the harness's TemplateCheck: @AutoConfigureTestRestTemplate) on the class path TiffinBox's POM gives its tests:"
  mrun trt .harness/full "$(off .harness/full "$L_TRT" | sed 's/^cd [^ ]* && //')"; }

# ---- exercise: the README's commands, exactly as written, then the solution's - in ONE shell --------------------------------------
block() { awk '/^```bash$/ { if (!d) { f = 1 }; next } f && /^```$/ { f = 0; d = 1 } f' "$1"; }
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
cp "$1/.harness/mine/test.log" "$1/.harness/ex-readme.log" 2> /dev/null
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
  echo "  the shell is now in: $(where "$d1") · the demo token in the copy's test log and reports: $(raw "$TOKEN" .harness/ex-readme.log) times · the copy's secrets folder: $( [ -e .harness/mine/after/secrets ] && echo yes || echo none)"
  echo "the solution's $(printf '%s\n' "$sol" | grep -c .) lines, next, in the same shell:"
  printf '%s\n' "$sol" | sed 's/^/  $ /'
  echo "  exit $e2 · what they printed:"; sed 's/^/    /' .harness/ex-sol.out
  echo "  the shell is now in: $(where "$d2") · the demo token in the copy's test log: $(raw "$TOKEN" .harness/mine/test.log) times"
  echo "  the copy's RevenueTest, its assertion now: $(grep -m1 'assertThat(tester' .harness/mine/after/$TT/com/tiffinbox/web/RevenueTest.java | sed 's/^ *//')"; }

# ---- forms: the native build, then four forms ------------------------------------------------------------------------------------------
nbuild() { local ci cn s0 s1 e=0
  ci=$(off "$1" "$R_INSTALL" install); cn=$(off "$1" "$R_NATIVE")
  echo "\$ $ci"; mbuild "$ci" "$1.install.log" "$1 (both modules, into \$M2; the tests ran)"
  echo "  the tests this build ran (Surefire's reports, harness/surefire.py):"; python3 -I harness/surefire.py "$1/$SR" | sed 's/^/  /'
  echo "  the demo token in the build's log and its reports: $(raw "$TOKEN" "$1.install.log" "$1/$SR"/*) times"
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
  if [ "$1" = '4 the image' ]; then [ "$(grep -c '^  docker port: ' .harness/blk.txt)" = 2 ] && [ "$(grep -cE '^  docker port: 18425/tcp -> 127\.0\.0\.1:19573$' .harness/blk.txt)" = 2 ] && echo yes || echo no
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
dstart() { local ec=0; echo "\$ $1"; (eval "$1") > .harness/d.out 2> .harness/d.err < /dev/null || ec=$?
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
# invalid PORT: the slice test's invalid customer POSTed (this unit's line), its answer's keys sorted; the dashboard's page, its title
invalid() { askj "$L_INV" "$1"
  echo "\$ $(url "$R_PAGE" "$1")"; curl -s -H 'Accept: text/html' "http://127.0.0.1:$1/dashboard" > .harness/page.html < /dev/null || true
  echo "  the page: <title>$(sed -n 's/.*<title>\([^<]*\)<\/title>.*/\1/p' .harness/page.html | head -1)</title> - the rest of it not shown"; }
dseven() { echo "\$ \$CURLSET $1 .harness/after/$TF"
  "$CURLSET" "$1" ".harness/after/$TF" | grep ' -> ' > .harness/responses.txt || true
  tsmask < .harness/responses.txt > .harness/responses.m.txt
  grep '^POST ' .harness/responses.m.txt | sed 's/^/  /' || echo "  (no POST line)"
  dgone "$BOX"; [ "$(listeners "$1")" = 0 ] || die "something still listens on $1"
  echo "  exit $LASTE · the seven responses: $(wc -l < .harness/responses.m.txt | tr -d ' ') lines · lines the timestamp mask changed: $(diff .harness/responses.txt .harness/responses.m.txt | grep -c '^<' || true) · md5 $(md5 -q .harness/responses.m.txt)"
  dlog "$BOX"; echo "  its log (docker logs): Boot's first line: $(first .harness/run.out) · the demo token 0 times · X-Shutdown-Token 0 times"
  docker rm "$BOX" > /dev/null; }
S466='466c20ed7e0d5439cb052f32ce09de1b'
forms() {
  echo "the native build - after/ copied to .harness/nat with a config tree; the README's two Maven lines, offline; \$GRAALVM_HOME names the GraalVM:"
  copy after .harness/nat
  nbuild .harness/nat; nlines .harness/nat.native.log; nresult .harness/nat.native.log
  hv .harness/nat
  echo "  file: $(file -b ".harness/nat/$BIN" | sed 's/ [A-Za-z0-9_]*$//') · the demo token in its bytes: $(raw "$TOKEN" ".harness/nat/$BIN") · the tests' literal: $(raw "$LIT" ".harness/nat/$BIN") · a test class in it (TiffinBoxWebTest, FullStackTest, WebSlice): $(raw TiffinBoxWebTest ".harness/nat/$BIN") $(raw FullStackTest ".harness/nat/$BIN") $(raw WebSlice ".harness/nat/$BIN")"
  echo "after/'s jar - .harness/after, the README's package line, offline (the tests ran):"
  copy after .harness/after; c=$(off .harness/after "$R_PLAIN" package); echo "\$ $c"; mbuild "$c" .harness/after.build.log "after/"
  python3 -I harness/surefire.py ".harness/after/$SR" | sed -n 's/^  in all: /  the tests this build ran: /p'
  echo "1 the jar - .harness/after, the README's run line, port 19570:"
  start "$(at .harness/after 19570 "$R_RUN")"; up 19570; ready 19570; seven 19570 .harness/after
  echo "  then the invalid customer and the page, on a second start of the jar:"
  start "$(at .harness/after 19570 "$R_RUN")"; up 19570; ready 19570; invalid 19570; stop 19570 .harness/after
  echo "2 the AOT jar - .harness/nat (the profile native's jar), the README's AOT line, port 19571:"
  start "$(at .harness/nat 19571 "$R_AOTRUN")"; up 19571; ready 19571; seven 19571 .harness/nat
  echo "  then the invalid customer and the page, on a second start of the AOT jar:"
  start "$(at .harness/nat 19571 "$R_AOTRUN")"; up 19571; ready 19571; invalid 19571; stop 19571 .harness/nat
  echo "3 the binary - .harness/nat, the README's line, port 19572:"
  start "$(at .harness/nat 19572 "$R_BIN")"; up 19572; ready 19572; seven 19572 .harness/nat
  echo "  then the invalid customer and the page, on a second start of the binary:"
  start "$(at .harness/nat 19572 "$R_BIN")"; up 19572; ready 19572; invalid 19572; stop 19572 .harness/nat
  # R.145: a binary whose validation fails is a stop, never a re-run - BLUE decides the fix (the brief's BLOCKED)
  if ! awk '/^3 the binary/ { f = 1 } /^4 the image/ { f = 0 } f' .harness/cap.raw | grep -qF '"errors":{"mealsPerDay":"must be greater than or equal to 1","name":"must not be blank","pricePerMeal":"must be greater than or equal to 1"}'; then
    echo "  *** STOP (R.145): the binary did not answer the invalid customer with the three messages; its Hibernate Validator metadata file: $HVS bytes - do not re-run: report it (the brief's BLOCKED) ***" >&3
    INTR=1; exit 3; fi
  echo "4 the image - after/'s Dockerfile (the README's build line, this script's tag), the README's run line with your user, published on 127.0.0.1:19573:"
  image
  dstart "$(drun .harness/after 19573)"; ready 19573 "$BOX"; dbind 19573
  dseven 19573
  echo "  then the invalid customer and the page, on a second container of the image:"
  dstart "$(drun .harness/after 19573)"; ready 19573 "$BOX"; dbind 19573
  invalid 19573
  post 19573 .harness/after; dgone "$BOX"; [ "$(listeners 19573)" = 0 ] || die "something still listens on 19573"
  dlog "$BOX"; echo "  exit $LASTE · its log (docker logs): the demo token 0 times · X-Shutdown-Token 0 times · WARN lines: $(lvl WARN .harness/run.out) · ERROR lines: $(lvl ERROR .harness/run.out)"
  docker rm "$BOX" > /dev/null
  echo "four forms, one tree: the seven (masked) $(grep -cE "^  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 0 · md5 $S466\$" .harness/cap.raw) of 4 times $S466 · the invalid customer 400 with the three messages: $(grep -cF '"errors":{"mealsPerDay":"must be greater than or equal to 1","name":"must not be blank","pricePerMeal":"must be greater than or equal to 1"}' .harness/cap.raw) of 4 · the page's title Dashboard · TiffinBox: $(grep -cxF '  the page: <title>Dashboard · TiffinBox</title> - the rest of it not shown' .harness/cap.raw) of 4"
  echo "  loopback, form by form: the jar $(lbk '1 the jar') · the AOT jar $(lbk '2 the AOT jar') · the binary $(lbk '3 the binary') · the image, published on 127.0.0.1 alone $(lbk '4 the image')"
  echo "  the locale: options on the binary's and the image's run lines: $(printf '%s\n%s\n' "$(at .harness/nat 19572 "$R_BIN")" "$(drun .harness/after 19573)" | grep -o 'user\.language\|user\.country' | wc -l | tr -d ' ') (none passed: the binary runs as the README writes it, the image as its ENTRYPOINT, java -jar)"; }

cap change change
cap slice slice
cap requests requests
cap untested untested
cap fullstack fullstack
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
SHIP="README.md exercise/README.md exercise/RevenueTest.java exercise/solution/SOLUTION.md receipts.md5 harness/shutdown.sh harness/surefire.py harness/test/resources/META-INF/spring.factories $(for f in $HTS; do printf 'harness/test/java/probe/web/%s ' "$f"; done) after/$TT/slice/WebSlice.java after/$WT after/$TT/com/tiffinbox/web/FullStackTest.java after/README.md after/tiffinbox-web/pom.xml"
NBIN=0
for f in .r-*.out $SHIP .harness/nat/$BIN; do [ -f "$f" ] || continue; case $f in .harness/nat*) NBIN=$((NBIN + 1)) ;; esac; [ "$(raw "$TOKEN" "$f")" = 0 ] || die "$f holds the demo token, raw"; done
[ "$NBIN" = 1 ] || die "one binary was built, $NBIN were checked"
[ "$MLOGS" -gt 0 ] && [ "$LOGS" -gt 0 ] && [ "$CLOGS" -gt 0 ] || die "a token count never ran (Maven logs $MLOGS, JVM logs $LOGS, container logs $CLOGS)"
# no capture prints a path, a version token of the OS or the JDK, a time, a pid, a random port or a unit number
for f in .r-*.out; do
  ! grep -qE '/Users/|/private/|/home/|/var/folders/' "$f" || die "$f holds an absolute path"
  [ -z "${GRAALVM_HOME:-}" ] || ! grep -qF "$GRAALVM_HOME" "$f" || die "$f holds the GraalVM's folder"
  ! grep -qE 'c[0-9]-unit[0-9]|unit ?[0-9]' "$f" || die "$f holds a unit number"
  ! grep -qE ' (with PID|started by) |surefirebooter|Time elapsed|time="' "$f" || die "$f holds Boot's process line, a Surefire booter path or a test's time"
  ! grep -qE '^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T|"timestamp":"?[0-9]|(exec|handler|task|utility)-[0-9]|GMT|CES?T' "$f" || die "$f holds a log time, a timestamp or a thread number"
  ! grep -qE 'Java [0-9]+\.[0-9]|Java-http-client/[0-9]|Macintosh|Mac OS X|Windows NT|X11;|Linux x86|Darwin|arm64|aarch64' "$f" || die "$f holds an OS or a JDK version token (R.128)"
  ! grep -qE '(127\.0\.0\.1:|port )(49|5[0-9]|6[0-5])[0-9][0-9][0-9]([^0-9]|$)' "$f" || die "$f holds a random port"
  ! grep -qE '^ +at [a-z]' "$f" || die "$f holds a stack frame"; done
# every URL a command names is 127.0.0.1's; every JVM a capture starts has its locale pinned; nothing kills by name; no bare wait; no
# Boot 3 key; no port published on every address
for f in .r-*.out; do ! grep -E '^ *\$ ' "$f" | grep -oE 'https?://[^ '"'"']+' | grep -vE '^http://127\.0\.0\.1:' > /dev/null || die "$f runs a command with a URL that is not 127.0.0.1's"; done
for f in .r-*.out; do ! grep -E '^\$ (cd [^ ]+ && )?(exec )?java ' "$f" | grep -vF -- "java $JL " > /dev/null || die "$f starts a JVM without its locale pinned (S4.1)"; done
K1='pki''ll'; K2='kill''all'; for f in receipts.sh harness/surefire.py; do ! grep -v '^ *#' "$f" | grep -qwE "$K1|$K2" || die "$f names $K1 or $K2 - every process is stopped by its pid"; done
for f in receipts.sh exercise/README.md exercise/solution/SOLUTION.md; do ! grep -nE '(^|[;&|({] *)wait *($|[;&|)}])' "$f" | grep -vE '^[0-9]+: *#' > /dev/null || die "$f has a bare wait (S3.9)"; done
K3='server'; K3="$K3.error."; K4='spring.http''.client.'
for f in receipts.sh README.md exercise/README.md exercise/solution/SOLUTION.md exercise/RevenueTest.java; do ! grep -qF "$K3" "$f" || die "$f names one of Boot 3's error keys (R.99)"; ! grep -qF "$K4" "$f" || die "$f names Boot 3's client key (R.138)"; done
! grep -rqF "$K3" after || die "after/ names one of Boot 3's error keys (R.99)"
! grep -rq 'probe\.web' after/tiffinbox-web after/tiffinbox-core || die "after/'s code names the course's harness - it is never TiffinBox's"
! grep -rqE '^package com\.tiffinbox' harness/test/java || die "a harness class sits in com.tiffinbox (R.43, R.143)"
for f in receipts.sh README.md exercise/README.md exercise/solution/SOLUTION.md; do ! grep -E 'docker run ' "$f" | grep -vE '^#' | grep -E ' -p "?[0-9]+:' > /dev/null || die "$f publishes a port on every address (-p without 127.0.0.1:)"; done
# R.124/S5.1: every test JVM's locale, read from its reports - en_US, but in requests' C, where -DargLine made it de_DE for that run
[ "$(cat .r-*.out | grep -cE "^ +the fork's locale, read from the reports' properties: user\.language de · user\.country DE · the same in every report: yes$")" = 1 ] && grep -qE "^ +the fork's locale, read from the reports' properties: user\.language de" <(blk requests "C (labelled)" "D (labelled)") || die "the fork's locale: de_DE once, in requests' C, nowhere else"
NFORK=$(cat .r-*.out | grep -cE "^ +the fork's locale, read from the reports' properties: " || true)
[ "$(cat .r-*.out | grep -cE "^ +the fork's locale, read from the reports' properties: user\.language en · user\.country US · the same in every report: yes$")" = $((NFORK - 1)) ] || die "every other test JVM's locale en_US (S5.1)"
NL=$(cat .r-*.out | grep -cE "^  its log: the demo token 0 times · X-Shutdown-Token 0 times\$" || true)
NM=$(cat .r-*.out | grep -cE "^  the demo token in the Maven log and every report: 0 times · " || true)
echo "  tokens: 0 raw copies in $(ls .harness/raw-* | wc -l | tr -d ' ') raw capture runs, in $(ls .r-*.out | wc -l | tr -d ' ') captures; the demo token 0 in the Maven log and every Surefire report of every test run ($MLOGS here; the published captures' $NM), the log of every JVM that served ($LOGS; $NL), every container ($CLOGS), the image's layers, the READMEs, the harness, the exercise, after/'s tests and POM, receipts.md5 and the binary; the tests' literal said as a literal; no path, no OS or JDK version token, no time, no random port, no unit number, no frame; every JVM's locale pinned; every URL 127.0.0.1"

# "One dependency in test scope ... four modules, thirty-three jars ... the only changed entry is the copy of the POM ... MAVEN_OPTS never reaches them"
CO=$(cat .r-change.out)
for l in "  after/'s files: 36 · byte for byte the previous tree's: 31 · new: 3 · those that differ: 2" '  tiffinbox-web/pom.xml: 137 lines -> 152' \
         '  its diff (diff -U0, its file names cut) - hunks: 2 · lines out: 0 · in: 15 - whole:' '    +    <argLine>-Duser.language=en -Duser.country=US</argLine>' \
         '    +      <artifactId>spring-boot-starter-webmvc-test</artifactId>' '    +      <scope>test</scope>' \
         "  where the POM's new lines sit: inside <build>: 0 · <build> itself, line for line the previous tree's: yes" \
         '  lines that differ: 0 · the same, byte for byte: 7 (1 2 3 4 5 6 7)' \
         "    Surefire's reports: none (no TEST-*.xml in surefire-reports)" \
         "    Surefire's console summary (its Results line): none · lines that say No tests to run: 2 · the plugin, as Maven names its goal: surefire:3.5.6:test" \
         "    Surefire's console summary (its Results line): tests 11 · failures 0 · errors 0 · skipped 0 · lines that say No tests to run: 1 · the plugin, as Maven names its goal: surefire:3.5.6:test" \
         '    in all: 2 reports · tests 11 · failures 0 · errors 0 · skipped 0' \
         '  5 dependencies:' '    org.springframework.boot:spring-boot-starter-webmvc:4.1.1 (compile) - on the previous tree'"'"'s class path already: yes' "  the starter's dependencies new to TiffinBox: 4" \
         '  the previous tree: 70 artifacts - compile 67, runtime 3, test 0 · after/: 103 - compile 67, runtime 3, test 33' \
         "  only after/'s (comm -13), each in test scope: 33 - all of them:" \
         "  only the previous tree's: 0 · Boot's RestClient module (spring-boot-restclient) on after/'s test class path: 0 · TestRestTemplate's own module (spring-boot-resttestclient): 1" \
         '    WebMvcTest - spring-boot-webmvc-test-4.1.1.jar' '    SpringBootTest - spring-boot-test-4.1.1.jar' '    MockMvc - spring-test-7.0.9.jar' '    MockMvcTester - spring-test-7.0.9.jar' \
         '    MockitoBean - spring-test-7.0.9.jar' '    RestTestClient - spring-test-7.0.9.jar' '    AutoConfigureRestTestClient - spring-boot-resttestclient-4.1.1.jar' \
         '    TestRestTemplate - spring-boot-resttestclient-4.1.1.jar' '    TypeExcludeFilter - spring-boot-4.1.1.jar' '    Mockito - mockito-core-5.23.0.jar' \
         "the executable jar's BOOT-INF/lib: 61 jars -> 61 · the same names: yes" \
         "  entries: 218 -> 218 · only in the previous tree's: 0 · only in after/'s: 0 · in both, bytes that differ: 1 - META-INF/maven/com.tiffinbox/tiffinbox-web/pom.xml" \
         "  the jar files themselves, byte for byte: different · tiffinbox-core's jar (tiffinbox-core/target/tiffinbox-core-1.0.0.jar), byte for byte: the same · after/'s jar holds a test class: 0" \
         "  its line that names the locale (the others - Maven's, Java's and the system's versions and folders - not shown): Default locale: de_DE" \
         "  the test's own line: the test JVM's locale: en_US"; do has "$CO" "$l" "change"; done
[ "$(cnt "$CO" '  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 0 · md5 466c20ed7e0d5439cb052f32ce09de1b')" = 2 ] || die "change: the seven 466c20ed on both trees' jars, the mask 0"
[ "$(printf '%s\n' "$CO" | grep -cE '^    [a-z][a-z0-9.-]*:[a-z0-9.-]+:jar:[^:]+:test$')" = 33 ] && ! printf '%s\n' "$CO" | grep -qE '^    [^ ]+:jar:[^:]+:(compile|runtime)$' || die "change: the 33 new artifacts, every one test scope"
for a in org.junit.jupiter:junit-jupiter:jar:6.0.3 org.assertj:assertj-core:jar:3.27.7 org.mockito:mockito-core:jar:5.23.0 org.springframework:spring-test:jar:7.0.9; do has "$CO" "    $a:test" "change: $a"; done
for m in spring-boot-starter-test spring-boot-webmvc-test spring-boot-resttestclient spring-boot-starter-jackson-test; do has "$CO" "    org.springframework.boot:$m:4.1.1 (compile) - on the previous tree's class path already: no" "change: the starter brings $m"; done
SK=$(printf '%s\n' "$CO" | grep '^  exit [0-9]* · what it printed (-q): ') || die "change: the -DskipTests build"
[ "$SK" = '  exit 0 · what it printed (-q): 0 lines · Surefire'"'"'s reports: 0 · the jar: built · its BOOT-INF/lib the same 61 names: yes' ] || die "change: -DskipTests builds the jar and writes no report: $SK"
P_=.harness/after; Q_=.harness/skip; has "$CO" "\$ ${C_SKIP/"$P_"/$Q_}" "change: the README's Course 4 line, run (in its own copy)"
MO=$(blk change "Maven's own JVM and the test JVM" "")
has "$MO" "      passed  theTestsRunInEnglish" "change: under MAVEN_OPTS de, the test JVM still en_US"
has "$MO" "    the fork's locale, read from the reports' properties: user.language en · user.country US · the same in every report: yes" "change: the fork en_US"
# a check that can distinguish: the same report reader says de_DE when the fork is German (requests C)
echo "  change: pom.xml +15 (argLine; the starter, test scope), <build> untouched; 3 new test sources; 31 of 36 byte for byte; the seven 466c20ed on both, the same 7; the previous build no tests, after/'s 11 (0 failures, surefire 3.5.6); the starter's 5 dependencies, 4 new; 33 new jars, all test scope, no spring-boot-restclient; owners read off the jars, no MockBean; 61 libraries the same; 218 entries, the POM alone differs; core the same; -DskipTests: jar, no report; MAVEN_OPTS de: Maven de_DE, the test JVM en_US"

# "WebMvcTest alone ... unable to find ... A: a hundred and thirty, seven ... three mocks ... B: TiffinBoxApp, eleven, the database, the test fails ... A again ... C"
SL=$(cat .r-slice.out); SA=$(blk slice "A - after/" "B - the slice"); SB=$(blk slice "B - the slice" "A' - A again"); SA2=$(blk slice "A' - A again" "A' against A"); SC=$(blk slice "C (labelled)" "")
for l in '  @Configuration' '  @EnableAutoConfiguration' '  @ComponentScan("com.tiffinbox")' "  a @SpringBootConfiguration or @SpringBootApplication anywhere in after/'s main sources: 0 files · in its test sources: slice/WebSlice.java" \
         '  the three classes the slice mocks, as tiffinbox-core declares them: public final class CustomerRepository · public final class Dashboard · public final class OrderQueue' \
         '  package slice;' '  @SpringBootConfiguration' '    -@ContextConfiguration(classes = WebSlice.class)' \
         '      ERROR  (the class: no test method ran) - java.lang.IllegalStateException' '    +@ContextConfiguration(classes = TiffinBoxApp.class)'; do has "$SL" "$l" "slice"; done
printf '%s\n' "$SL" | grep -qxE '        Unable to find a @SpringBootConfiguration by searching packages upwards from the test\. You can use @ContextConfiguration, .*' || die "slice: alone - Unable to find a @SpringBootConfiguration (the whole first sentence)"
grep -qF 'Unable to find a @SpringBootConfiguration by searching packages upwards from the test.' .harness/alone.log 2> /dev/null || [ ! -f .harness/alone.log ] || die "slice: alone - the sentence whole in Maven's log"
TBA='    CENSUS TiffinBoxWebTest the context'"'"'s beans: 130 · TiffinBox'"'"'s (com.tiffinbox): 7 - com.tiffinbox.CustomerRepository#0 (CustomerRepository), com.tiffinbox.Dashboard#0 (Dashboard), com.tiffinbox.OrderQueue#0 (OrderQueue), dashboardPage (DashboardPage), tiffinBoxErrors (TiffinBoxErrors), tiffinBoxServer (TiffinBoxServer), tiffinbox-com.tiffinbox.TiffinBoxProperties (TiffinBoxProperties)'
FULL11='customerRepository (CustomerRepository), dashboard (Dashboard), dashboardPage (DashboardPage), database (Database), kitchenHealthIndicator (KitchenHealthIndicator), kitchenMetrics (KitchenMetrics), orderQueue (OrderQueue), tiffinBoxApp (TiffinBoxApp), tiffinBoxErrors (TiffinBoxErrors), tiffinBoxServer (TiffinBoxServer), tiffinbox-com.tiffinbox.TiffinBoxProperties (TiffinBoxProperties)'
TFS="    CENSUS FullStackTest the context's beans: 293 · TiffinBox's (com.tiffinbox): 11 - $FULL11"
for b in "$SA" "$SA2"; do has "$b" "$TBA" "slice A: 130 beans, 7 TiffinBox's - three mocks"; has "$b" "$TFS" "slice A: the whole application's 293, 11"; has "$b" '      passed  theSliceLeavesTheDatabaseOut' "slice A: the database left out"
  has "$b" "    CENSUS TiffinBoxWebTest MockMvc's filters: 4 - OrderedCharacterEncodingFilter, OrderedFormContentFilter, OrderedRequestContextFilter, ResourceUrlEncodingFilter" "slice A: MockMvc's 4"
  has "$b" "  Mockito's lines: 1 · the JVM's (WARNING: …, OpenJDK 64-Bit Server VM warning: …): 5" "slice A: Mockito's 1, the JVM's 5"; done
has "$SB" "    CENSUS TiffinBoxWebTest the context's beans: 134 · TiffinBox's (com.tiffinbox): 11 - $FULL11" "slice B: 134 beans, the same 11 as the application"
has "$SB" '      FAILED  theSliceLeavesTheDatabaseOut - java.lang.AssertionError' "slice B: the test fails"; has "$SB" '        Expecting empty but was: ["database"]' "slice B: the database is in"
has "$SB" '  exit 1 · BUILD FAILURE · offline: yes' "slice B: the build fails"
x slice "^A' against A, its label aside and the console lines A showed once, line for line the same: yes\$"
printf '%s\n' "$SA2" | grep -qxF "\$ $(off .harness/sliceA "$L_SLICE")" || die "slice A': its \$ line - the mvn command and the test method's name (S5.2)"
[ "$(printf '%s\n' "$SA" | grep -cE '^    (Mockito is currently self-attaching|WARNING: |OpenJDK 64-Bit Server VM warning: )')" = 6 ] && [ "$(printf '%s\n' "$SB" "$SA2" "$SC" | grep -cE '^    (Mockito is currently self-attaching|WARNING: |OpenJDK 64-Bit Server VM warning: )')" = 0 ] || die "slice: Mockito's and the JVM's six lines shown once, in A"
has "$SA" '    WARNING: A Java agent has been loaded dynamically (…/.m2-demo/net/bytebuddy/byte-buddy-agent/1.18.11/byte-buddy-agent-1.18.11.jar)' "slice A: the JVM's line, its path masked"
printf '%s\n' "$SC" | grep "^    CENSUS FullStackTest the context's beans: " | grep -F "· TiffinBox's (com.tiffinbox): 12 - " | grep -qF 'webSliceInside (WebSliceInside$$SpringCGLIB$$<n>)' || die "slice C: WebSlice inside com.tiffinbox joins the whole application's context - 12"
echo "  slice: TiffinBoxApp's three annotations, no @SpringBootConfiguration in main; alone - Unable to find a @SpringBootConfiguration; A 130 beans, 7 TiffinBox's (3 mocks com.tiffinbox.X#0), the application 293/11, the database out; B TiffinBoxApp - 134, 11, ['database'], the test fails; A' = A; C inside com.tiffinbox - the application 12; Mockito 1 + the JVM 5, shown once"

# "Customers two hundred ... Nobody four oh four ... three messages, English ... de, German ... four oh five, Allow POST ... the page's title ... C: German JVM ... D: the key off"
RA=$(blk requests "TiffinBoxWebTest - after/" "C (labelled)"); RC=$(blk requests "C (labelled)" "D (labelled)"); RD=$(blk requests "D (labelled)" "")
E_PAGE='    EXCHANGE GET /dashboard · Accept-Language: none -> 200 · Content-Type: text/html;charset=UTF-8 · body: a page, its title: Dashboard · TiffinBox'
E_EN='    EXCHANGE POST /customers · Accept-Language: none -> 400 · Content-Type: application/problem+json · body: {"detail":"the customer breaks 3 rules","instance":"/customers","status":400,"title":"Invalid customer","errors":{"mealsPerDay":"must be greater than or equal to 1","name":"must not be blank","pricePerMeal":"must be greater than or equal to 1"}}'
E_405='    EXCHANGE GET /shutdown · Accept-Language: none -> 405 · Content-Type: application/problem+json · Allow: POST · body: {"detail":"Method '"'"'GET'"'"' is not supported.","instance":"/shutdown","status":405,"title":"Method Not Allowed"}'
E_CUS='    EXCHANGE GET /customers · Accept-Language: none -> 200 · Content-Type: application/json · body: [{"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"}]'
E_404='    EXCHANGE GET /customers/Nobody · Accept-Language: none -> 404 · Content-Type: application/problem+json · body: {"detail":"no customer named Nobody","instance":"/customers/Nobody","status":404,"title":"Customer not found","name":"Nobody"}'
E_DE='    EXCHANGE POST /customers · Accept-Language: de -> 400 · Content-Type: application/problem+json · body: {"detail":"the customer breaks 3 rules","instance":"/customers","status":400,"title":"Invalid customer","errors":{"mealsPerDay":"muss größer-gleich 1 sein","name":"darf nicht leer sein","pricePerMeal":"muss größer-gleich 1 sein"}}'
E_405OFF='    EXCHANGE GET /shutdown · Accept-Language: none -> 405 · Content-Type: null · Allow: POST · body: '
for b in "$RA" "$RC"; do for l in "$E_PAGE" "$E_EN" "$E_405" "$E_CUS" "$E_404" "$E_DE"; do has "$b" "$l" "requests: the answers MockMvc completed"; done
  [ "$(printf '%s\n' "$b" | grep -c '^    EXCHANGE ')" = 6 ] || die "requests: six answers completed, six EXCHANGE lines"; done
[ "$(printf '%s\n' "$RA" | grep -c '^      passed  ')" = 9 ] && has "$RA" '    in all: 1 reports · tests 9 · failures 0 · errors 0 · skipped 0' "requests" || die "requests: the nine pass"
has "$RA" "  the test's own line: the test JVM's locale: en_US" "requests: the test JVM en_US"; has "$RA" '    WARN o.s.web.servlet.PageNotFound: Request method '"'"'GET'"'"' is not supported' "requests: the 405's WARN - Spring MVC's PageNotFound"
for l in '      FAILED  theTestsRunInEnglish - org.opentest4j.AssertionFailedError' '        expected: en_US' '        but was: de_DE' "  the test's own line: the test JVM's locale: de_DE" '    in all: 1 reports · tests 9 · failures 1 · errors 0 · skipped 0'; do has "$RC" "$l" "requests C: the German JVM - the language test fails, the messages stay English"; done
has "$RD" '  the key in after/'"'"'s application.yaml: spring.mvc.problemdetails.enabled: true (line 70)' "requests D: TiffinBox's key"
for l in "$E_404" "$E_EN" "$E_405OFF"; do has "$RD" "$l" "requests D: the key off - the 404 and the 400 TiffinBox's own, the 405 without a body"; done
nhas "$RD" "$E_405" "requests D: the 405's problem detail is the key's"
has "$RD" '    in all: 1 reports · tests 9 · failures 0 · errors 0 · skipped 0' "requests D: the nine still pass (the 405's test checks the status and Allow)"
echo "  requests: 9 pass; 200 Ravi, 404 problem+json Nobody, 400 three messages (none: English, de: German), 405 Allow: POST, the page's title; C de_DE JVM - the locale test fails, English stays; D the key off - 404 and 400 the same, the 405's body gone"

# "No status, no body ... the older API throws ... one chain in the slice; on Tomcat two, an error dispatch to /error ... four filters; six"
UT=$(cat .r-untested.out)
for l in '    LIMIT SliceLimits the older MockMvc API, perform(GET /revenue): throws jakarta.servlet.ServletException: Request processing failed: java.lang.IllegalStateException: kitchen on fire' \
         '    LIMIT SliceLimits GET /revenue (a repository that throws): the exception nobody handled: jakarta.servlet.ServletException: Request processing failed: java.lang.IllegalStateException: kitchen on fire · a response: none - getResponse() throws IllegalStateException: Request failed with unresolved exception …' \
         '    LIMIT SliceLimits GET /dashboard as HTML (a dashboard that throws): the exception nobody handled: jakarta.servlet.ServletException: Request processing failed: java.lang.IllegalStateException: page on fire · a response: none - getResponse() throws IllegalStateException: Request failed with unresolved exception …' \
         '    CHAIN REQUEST /revenue - the chain it runs in: MockFilterChain, 6 filters: 1 OrderedCharacterEncodingFilter | 2 OrderedFormContentFilter | 3 OrderedRequestContextFilter | 4 ChainDump | 5 ResourceUrlEncodingFilter | 6 ServletFilterProxy' \
         '    CHAIN REQUEST /revenue - the chain it runs in: ApplicationFilterChain, 7 filters: 1 characterEncodingFilter | 2 webMvcObservationFilter | 3 formContentFilter | 4 requestContextFilter | 5 chainDump | 6 resourceUrlEncodingFilter | 7 Tomcat WebSocket (JSR356) Filter' \
         '    CHAIN ERROR /error - the chain it runs in: ApplicationFilterChain, 5 filters: 1 characterEncodingFilter | 2 formContentFilter | 3 requestContextFilter | 4 chainDump | 5 resourceUrlEncodingFilter' \
         '    LIMIT Chains GET /revenue (a repository that throws), on Tomcat: 500 · Content-Type: application/json' \
         "    CENSUS TiffinBoxWebTest MockMvc's filters: 4 - OrderedCharacterEncodingFilter, OrderedFormContentFilter, OrderedRequestContextFilter, ResourceUrlEncodingFilter" \
         '    CENSUS TiffinBoxWebTest the servlet context: SpringBootMockServletContext' '    CENSUS TiffinBoxWebTest the web server: none' '    CENSUS SliceLimits the web server: none' \
         '    CENSUS Chains the servlet context: ApplicationContextFacade' '      passed  aFailingRepositoryLeavesNoStatus' '    in all: 3 reports · tests 4 · failures 0 · errors 0 · skipped 0'; do has "$UT" "$l" "untested"; done
[ "$(printf '%s\n' "$UT" | grep -c '^    CHAIN ERROR ')" = 1 ] && [ "$(printf '%s\n' "$UT" | grep -c '^    CHAIN .*MockFilterChain')" = 2 ] || die "untested: the ERROR dispatch on Tomcat once, none in the slice (its two requests, one chain each)"
TC=$(printf '%s\n' "$UT" | sed -n 's/^    CHAIN REQUEST \/revenue - the chain it runs in: ApplicationFilterChain, \([0-9]*\) filters: .*/\1/p'); MC=$(printf '%s\n' "$UT" | sed -n "s/^    CENSUS TiffinBoxWebTest MockMvc's filters: \([0-9]*\) - .*/\1/p")
[ "$((TC - 1))" = 6 ] && [ "$MC" = 4 ] || die "untested: Tomcat's 6 besides the harness's own, MockMvc's 4 ($TC, $MC)"
echo "  untested: the slice - no status, no body (hasFailed, getResponse throws, perform throws ServletException), one REQUEST chain, the page unresolved too; Tomcat - REQUEST then ERROR /error, 500; MockMvc's 4 filters, Tomcat's 6 (+ the harness's); a mock servlet context, no web server"

# "a random port ... one two seven, zero, zero, one ... a real five hundred, Boot's four keys ... Tomcat logs it at ERROR ... the error page ... TestRestTemplate"
FS=$(blk fullstack "FullStackTest, and" "C (labelled)"); FC=$(blk fullstack "C (labelled)" "")
for l in "    CENSUS FullStackTest this test JVM's listening sockets (lsof -nP -a -p <its pid> -iTCP -sTCP:LISTEN): 127.0.0.1:<port>" \
         "    CENSUS FullStackTest the web server: TomcatWebServer on port <port> · the port in macOS's ephemeral range (49152-65535): yes · in the course's range (19300-19799): no" \
         "    CENSUS FullStackTest the test JVM: locale en_US · working directory tiffinbox-web · a secrets folder there: no · the settings record's token is the tests' literal: yes" \
         '  the system'"'"'s own range for a port it picks (sysctl net.inet.ip.portrange, on this Mac): 49152-65535' \
         '    ANSWER GET /revenue (a repository that throws) -> 500 · Content-Type: application/json · body: {"timestamp":"…","status":500,"error":"Internal Server Error","path":"/revenue"} · its keys: 4 - error, path, status, timestamp' \
         '    ANSWER GET /nowhere -> 404 · Content-Type: application/problem+json · body: {"detail":"No static resource nowhere.","instance":"/nowhere","status":404,"title":"Not Found"} · its keys: 4 - detail, instance, status, title' \
         '    ANSWER GET /dashboard as HTML (a repository that throws) -> 500 · Content-Type: text/html;charset=UTF-8 · body: a page, its title: Something broke · TiffinBox' \
         '      passed  aFailingRepositoryIsAFiveHundred' '      passed  aPathNobodyMapsIsAProblemDetail' \
         '    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: Servlet.service() for servlet [dispatcherServlet] in context with path [] threw exception [Request processing failed: java.lang.IllegalStateException: kitchen on fire] with root cause'; do has "$FS" "$l" "fullstack"; done
has "$FS" "    CENSUS FullStackTest the context's beans: 293 · TiffinBox's (com.tiffinbox): 11 - $FULL11" "fullstack: 293, 11"
for l in '      ERROR  nowhere - java.lang.IllegalStateException' '        Caused by: java.lang.NoClassDefFoundError: org/springframework/boot/restclient/RestTemplateBuilder' '  exit 1 · BUILD FAILURE · offline: yes'; do has "$FC" "$l" "fullstack C: TestRestTemplate needs spring-boot-restclient"; done
echo "  fullstack: Tomcat on a port in macOS's ephemeral range (sysctl 49152-65535), not the course's; the test JVM's socket 127.0.0.1:<port>; 293/11; /revenue 500 Boot's four keys, Tomcat's ERROR; /nowhere 404 problem detail; the page 500 Something broke; C TestRestTemplate - NoClassDefFoundError RestTemplateBuilder"

# the exercise's end state: the README's commands, then the solution's, in ONE env -i shell
XS=$(blk exercise "the README's" "the solution's"); XE=$(blk exercise "the solution's" '')
X_SHIP='exit 1 · RevenueTest: tests 1 · errors 0 · failures 1'; X_WHY='  Request failed unexpectedly: jakarta.servlet.ServletException: Request processing failed: java.lang.IllegalStateException: kitchen on fire'; X_END='exit 0 · RevenueTest: tests 1 · errors 0 · failures 0'
has "$XS" "    $X_SHIP" "exercise: as shipped"; has "$XS" "    $X_WHY" "exercise: as shipped, why"; has "$XE" "    $X_END" "exercise: the solution"
nhas "$XE" "Request failed unexpectedly" "exercise: the solution's run fails nothing"
awk '/^\*\*Done\*\*/ { f = 1 } f' exercise/README.md | grep -qxF -- "$X_END" || die "exercise/README.md: Done names no such line"
grep -qxF -- "$X_END" exercise/solution/SOLUTION.md || die "SOLUTION.md: the measured run shows no such line"
grep -qxF -- "$X_SHIP" exercise/README.md && grep -qxF -- "$X_WHY" exercise/README.md || die "exercise/README.md: the shipped lines are not named"
grep -qF 'assertThat(tester.get().uri("/revenue")).hasStatus(500);' exercise/RevenueTest.java || die "exercise: the shipped test asserts the 500"
for b in "$XS" "$XE"; do printf '%s\n' "$b" | grep -qE "^  the shell is now in: this unit's folder · the demo token in the copy's test log" || die "exercise: the shell back in this folder, 0 tokens"; done
has "$XE" '  the copy'"'"'s RevenueTest, its assertion now: assertThat(tester.get().uri("/revenue")).hasFailed().failure().hasMessageContaining("kitchen on fire");' "exercise: the solution's assertion"
EXQ="Your turn: the README's test expects a five hundred from a failing repository, and fails. Assert what MockMvc really saw, and run it again."
grep -qxF -- "**Your turn:** ${EXQ#Your turn: }" exercise/README.md || die "exercise/README.md: the spoken exercise line"
[ "$(printf '%s\n' "$EXQ" | wc -w | tr -d ' ')" -le 25 ] || die "exercise: the spoken line is over 25 words"
echo "  exercise: one env -i shell - the README as written: exit 1, failures 1, Request failed unexpectedly … kitchen on fire; the solution: exit 0, failures 0; the shell in this unit's folder after each"

# "the native build ran all eleven tests first ... the same seven ... the same three messages" (and R.145's answer)
if [ -f .r-forms.out ]; then FM=$(cat .r-forms.out)
  x forms '^  exit 0 · BUILD SUCCESS · stages it printed: 8 of the 8 it announces · its lines that say the metadata repository was downloaded over http, or failed to: 0 · offline: yes$'
  x forms '^  file: Mach-O 64-bit executable · the demo token in its bytes: 0 · the tests'"'"' literal: 0 · a test class in it \(TiffinBoxWebTest, FullStackTest, WebSlice\): 0 0 0$'
  [ "$(cnt "$FM" '    in all: 2 reports · tests 11 · failures 0 · errors 0 · skipped 0')" = 1 ] && has "$FM" '  the tests this build ran: 2 reports · tests 11 · failures 0 · errors 0 · skipped 0' "forms" || die "forms: the native install and the jar's build each ran the eleven tests"
  has "$FM" "four forms, one tree: the seven (masked) 4 of 4 times $S466 · the invalid customer 400 with the three messages: 4 of 4 · the page's title Dashboard · TiffinBox: 4 of 4" "forms: the summary"
  has "$FM" '  loopback, form by form: the jar yes · the AOT jar yes · the binary yes · the image, published on 127.0.0.1 alone yes' "forms: loopback"
  [ "$(n forms "^  Boot's first line: Starting AOT-processed TiffinBoxServer v1\.0\.0 using Java <version>\$")" = 2 ] && [ "$(n forms "^  Boot's first line: Starting AOT-processed TiffinBoxServer using Java <version>\$")" = 2 ] || die "forms: the AOT jar and the binary, each started twice, each AOT-processed"
  [ "$(n forms '^  inside the container, listening: \[::\]:18425$')" = 2 ] && [ "$(n forms '^  docker port: 18425/tcp -> 127\.0\.0\.1:19573$')" = 2 ] || die "forms: the image, two containers, 18425 inside, published on 127.0.0.1:19573 alone"
  x forms '^  its lines that say pull: 0 · '
  x forms '^  the image saved \(docker save\): [1-9][0-9]* blobs, its [1-9][0-9]* layers among them, each read whole \(gzip ones unpacked\) · the demo token in them: 0$'
  x forms '^  the Hibernate Validator metadata file this build made \(.*\): in target/classes and in the jar the same · its size: printed on the terminal, never hashed \(R\.145\)$'
  [ "$(awk '/^3 the binary/ { f = 1 } /^4 the image/ { f = 0 } f' .r-forms.out | grep -cF '"errors":{"mealsPerDay":"must be greater than or equal to 1","name":"must not be blank","pricePerMeal":"must be greater than or equal to 1"}')" = 1 ] || die "forms: the binary's validation - the three messages (R.145)"
  echo "  forms: 8 of 8 stages, offline, Mach-O, 0 tokens, no test class in the binary; the tests the builds ran: 11, 0 failures; the jar, the AOT jar, the binary, the image: the seven 4 of 4, the invalid customer's three messages 4 of 4, the page's title 4 of 4; loopback; 0 tokens in the image's layers; the HV file's sizes on the terminal: $(paste -sd' ' .harness/hv.txt 2> /dev/null)"
fi

cmp -s after/README.md ../c6-tiffinbox/README.md || echo "  (after/README.md and ../c6-tiffinbox/README.md differ - the anchor has moved past this unit's after/)" >&3
[ -z "$unpub" ] || die "no published hash for:$unpub - check the captures, then copy the md5s above into receipts.md5 and run again"
echo "c6-unit28: every capture 3/3 and = published; every spoken number asserted; 0 raw demo tokens in every capture, every Maven log and Surefire report, every JVM's and the container's log, the image's layers and the binary; nothing of this run left on Docker"
