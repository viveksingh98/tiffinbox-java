#!/bin/bash
XPATH=$PATH                                           # the PATH you started this with: the exercise's own shell gets it
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25.0.4.1 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"   # the Chrome app on the author's Mac: point it at yours
# GRAALVM_HOME names a GraalVM JDK 25 (README.md, "The GraalVM"): the native build reads it. Without it, this script makes every
# capture that needs no GraalVM, filling .m2-demo on the way, then stops before the native build.
# Course 6 · Sessions, Cookies and Flash Attributes - this unit's receipts. The anchor changes, for the last time in Section 4: the
# form's POST /customers puts a flash attribute on its redirect - "added", the customer's name - and the dashboard page shows
# "<name> added" once; application.yaml's first document gains server.servlet.session.tracking-modes: cookie, so the session that
# note lives in is carried by its cookie alone, never by an address. Nine captures, each run three times and hashed; cap() DIES
# when a hash differs from receipts.md5; every number the video says is asserted at the bottom by a check that can fail; the demo
# token is masked (gsub), and the checks count 0 raw copies of it in every capture, in the log of every run - the container's
# included - in every file this unit ships, in the binary, in the image's layers and in every session file a run wrote.
#   change     the previous tree against after/: the files that differ, the three diffs whole, where the key sits in
#              application.yaml (above the first ---), Boot's metadata for the session keys, the jars' libraries
#   cookie     the seven on both trees, each on a fresh JVM, line for line - and once more with the harness's Sessions and Dump
#              joined: no session made, no Set-Cookie sent; then what makes a session: the routes that make none, the form's POST
#              on the previous tree (no note, no session) and on after/ (the note, the session's cookie), the harness's Visits
#              without a cookie jar and with one, curl's jar, and the tracking modes Tomcat reports on each tree
#   flash      the note across the redirect: the POST with a cookie jar, the dashboard twice; without the jar; a refused form and a
#              JSON POST (no session); curl -L with -X POST (it posts again) and without
#   tracking   A/B/A' - server.servlet.session.tracking-modes: A after/ as shipped (cookie), B cookie,url (Tomcat's default) for
#              the run, A' A again: the anchor's own form line, the redirect's address, the page it leads to for a client that
#              keeps no cookie
#   flags      the attributes Course 10 decides, each for one run: SameSite=Strict, Secure, a 90-second timeout
#   persistent C (labelled) - DevTools on the class path: server.servlet.session.persistent; a visit count across a restart, with
#              DevTools' default and with persistence off; C' C again
#   exercise   exercise/README.md's commands, then exercise/solution/SOLUTION.md's, read from the files and run as written, one after
#              the other in ONE shell a viewer could have: env -i, /bin/bash, started in this folder
#   browser    TiffinBox with Dump and Sessions (the server's record of every request, whole) and headless Chrome, a profile of its
#              own made fresh for each visitor, sealed to 127.0.0.1: after/ - the dashboard, the form typed and sent, the dashboard
#              again, Chrome's cookie store; C (labelled) cookie,url; F (labelled) Secure and SameSite=Strict - each claim with
#              two witnesses
#   forms      the native build of after/; what Spring's AOT step registers, on the previous tree and on after/; then four forms -
#              the jar, the AOT jar, the binary, the image: each one's address, the seven (masked), exit 0; then, on a second start
#              of each, the form's first POST, the note once; on a third, the same POST with cookie,url
# "The previous tree" is before/, the link to ../c6-unit23/after (the anchor before this change: the static-resource lesson's frozen
# tree), COPIED under .harness/before; after/ is this unit's frozen copy of ../c6-tiffinbox after the change, COPIED under
# .harness/after. This script never writes into another unit's folder, and never builds a frozen tree in place. Every run of
# TiffinBox starts in a folder under .harness/ that holds a config tree with a fake token (secrets/), as the README asks - the
# container's too, mounted read-only. Commands are printed exactly as they run: each goes through eval. "$CURLSET" is the comparison
# set since the secrets lesson (../c5-unit11/curlset.sh: the seven requests, POST /shutdown with the token's header read from the
# file). "$M2" is this unit's own repository, .m2-demo. "$CHROME" is the Chrome app (above). The harness - harness/probe/web/*.java
# (compiled with -parameters): Dump and Keys (the serving lesson's, byte for byte), Trace (the CORS lesson's, byte for byte),
# Sessions and Visits (new) - is the course's, never TiffinBox's: outside com.tiffinbox, joined by --spring.main.sources on the
# extracted jar's class path; harness/cdp.mjs drives Chrome over its DevTools protocol (node's own WebSocket); harness/net.py reads
# Chrome's record of a visit's documents; harness/netlog.py (the CORS lesson's, byte for byte) reads Chrome's NetLog;
# harness/shutdown.sh is POST /shutdown with the token read from its file. Every run passes options only. The seven always run on
# a fresh JVM, first.
# The locale: the JVM ignores LC_ALL on macOS - every JVM this script starts has its locale pinned on its run line (-Duser.language=en
# -Duser.country=US, before -jar or -cp), and the checks refuse a java line without it; Keys prints the JVM's locale. No capture
# here prints a message a locale words; Chrome runs with --lang=en-US. The binary takes no JVM options.
# The network: every Maven build runs offline (-o) against .m2-demo and says so ("offline: yes"); a build that cannot resolve an
# artifact offline goes to Maven Central once, and says that ("offline: no - ..."). GraalVM's native plugin reads its metadata
# repository (a zip) from .m2-demo - and when the zip is not there it downloads it from GitHub, even under -o: so a native-profile
# build without the zip goes to Maven Central for it at once, and every native build's log is searched for the plugin's own
# download line - found, the run stops. Docker: no pull - eclipse-temurin:25-jre must already be on the daemon. At run time nothing
# leaves 127.0.0.1: TiffinBox listens there (in a container, on the container's own addresses, published on the host's 127.0.0.1
# alone), every request goes there, Chrome's DevTools port listens there, and Chrome's own background requests go to a proxy address
# where nothing listens (127.0.0.1:9) - its NetLog is read: every address it connected to or tried is 127.0.0.1. Chrome never touches
# a profile but the one this script makes, and is stopped by its pid, never by its name. Without Chrome or node (22 or later) every
# curl capture is made and checked, and the script stops at the browser step (exit 2), before the native build.
# Masks and filters (README.md declares each; awk sub/gsub only): the demo token becomes "[masked: the N-character token]"; the
# GraalVM's folder "$GRAALVM_HOME"; this folder's absolute path "…", the folder above it "…/..", the home folder "~"; your user name
# "<user>"; a Tomcat request thread's number "tomcat-handler-<n>"; Chrome's version in its User-Agent and its sec-ch-ua brand list;
# a session's id - JSESSIONID=<id> in a cookie, ;jsessionid=<id> in an address - in every line of every capture (a session's id is
# a key to that session: R.18). Whether two ids are the same is computed before the mask and printed as yes or no. Spring's error
# timestamp becomes "…" (both forms). An answer's headers are printed whole, on one line, in the order they came - a Date header's
# value, the time, is not printed. A page (HTML) is never printed whole: its <title>, its line and byte counts, its notes, its
# table's first column and how many of its links carry a session id; a JSON answer as its bytes. A run's log lines are printed from
# their logger on; a WARN or ERROR record as its level, logger and message, then its exception line, its frames bounded ("over 40")
# and its other lines counted. The harness's lines (Trace) are printed in the order they ran, numbered from 1. No image, container
# or ID is printed but the base image's digest. No duration is captured: the native build's seconds, and the 20-minute bound, go to
# the terminal only.
# Ports (brief ⚑1, 19530-19539): after/'s jar 19530 · the previous tree 19531 · a run with one key changed 19532 · DevTools 19533 ·
# the image 19534 · the AOT jar 19535 · the binary 19536 · the browser's TiffinBox 19537 · the exercise 19538 · Chrome's DevTools
# port 19539. 18425 (TiffinBox's default), 8080 (Tomcat's) and 35729 (DevTools' Live Reload) are checked free too, and never bound on
# this machine (18425 only inside a container).
# Docker names (no unit number): the image tiffinbox-session:1.0.0 and the container tiffinbox-session. Each is checked absent before
# the first run - a name already there may be yours, and this script removes only what it creates - and removed on every exit.
set -e
# bash 5.2 and later turn an & in the replacement of ${x/pattern/replacement} into the matched text (patsub_replacement, on by
# default). Switched off, so /bin/bash 3.2 (./receipts.sh) and a newer bash (bash receipts.sh) run the same commands.
shopt -u patsub_replacement 2> /dev/null || true
export LC_ALL=C
cd "$(dirname receipts.sh)"
# One run at a time: two runs share .harness/, the ports and the Docker names, and one would corrupt the other.
mkdir .r-lock 2> /dev/null || { echo "  *** another receipts.sh is running in this folder (.r-lock exists) - if none is, rmdir .r-lock ***"; exit 1; }
IMG=tiffinbox-session:1.0.0; BOX=tiffinbox-session
OURS=""
U="$PWD"; UP="$(cd .. && pwd)"; ME="$(id -un)"
# On every exit - the end, a failed check, or Ctrl-C - stop the processes this script started in the background, if they still run:
# $pid (a server), $xpid (the exercise's shell, with every process under it), $cpid (Chrome, with every process under it); then
# sweep(): anything of this run still alive - in its process group, a TiffinBox JVM, a binary, native-image's driver or builder, a
# Maven; anywhere, a process started with this unit's own Chrome profile - is stopped; then dclean(): this run's container and image.
# Chrome's profile is removed, and so is every session file a run wrote (.harness/after/sessions: a session's id and what it holds). After an interrupt, a capture's unfinished runs (.r-NAME.1-3) go too. The clean-up ignores a second
# Ctrl-C, and nothing in it can fail under set -e; the script still exits 130 after an interrupt. No wait in this script is bare.
pid=""; xpid=""; cpid=""
sweep() { local g i l
  g=$(ps -o pgid= -p $$ 2> /dev/null | tr -d ' ') || g=""
  i=0; while [ $i -lt 20 ]; do
    l=$(ps -axo pid=,pgid=,command= 2> /dev/null | awk -v g="$g" -v me=$$ -v gh="${GRAALVM_HOME:-/nonexistent}" -v prof="--user-data-dir=$U/.harness/chrome" '
      $1 != me && $3 != "awk" && $3 != "ps" && (index($0, prof) || ($2 == g && (index($0, "vminvocation.args") || index($3, gh "/bin/native-image") || $3 ~ /tiffinbox-web\/target\/tiffinbox-web$/ || index($0, "tiffinbox-web-1.0.0.jar") || index($0, "com.tiffinbox.web.TiffinBoxServer") || index($0, "org.codehaus.plexus.classworlds.launcher.Launcher")))) { print $1 }' | paste -sd' ' -) || l=""
    [ -n "$l" ] || return 0
    if [ $i -lt 10 ]; then kill $l 2> /dev/null || true; else kill -9 $l 2> /dev/null || true; fi
    sleep 0.5; i=$((i + 1)); done; }
desc() { ps -axo pid=,ppid= 2> /dev/null | awk -v r="$1" '{ p[$1] = $2 } END { n = 1; q[1] = r; for (i = 1; i <= n; i++) for (c in p) if (p[c] == q[i]) { q[++n] = c; print c } }'; }
killtree() { local d; d=$(desc "$1"); kill "$1" $d 2> /dev/null || true; }
dclean() { [ -n "$OURS" ] || return 0
  docker rm -f "$BOX" > /dev/null 2>&1 || true
  docker image rm -f "$IMG" $(sort -u .harness/imgids 2> /dev/null) > /dev/null 2>&1 || true; }
trap 'trap "" INT TERM; for p in "$xpid" "$cpid"; do [ -z "$p" ] || killtree "$p"; done; for p in "$pid" "$xpid" "$cpid"; do if [ -n "$p" ] && kill "$p" 2> /dev/null; then wait "$p" 2> /dev/null || true; fi; done; sweep || true; dclean || true; rm -rf .harness/chrome .harness/after/sessions 2> /dev/null || true; [ -z "$INTR" ] || rm -f .r-*.[123]; rmdir .r-lock 2> /dev/null || true' EXIT
INTR=""; trap 'INTR=1; exit 130' INT TERM
exec 3>&1                                            # die() speaks to the terminal even inside a redirected capture
die() { echo "  *** $* ***" >&3; exit 1; }
java -version 2>&1 | grep -q 'version "25' || die "JDK 25 needed; JAVA_HOME gives: $(java -version 2>&1 | head -1)"
for t in python3 curl rsync lsof unzip javac docker openssl md5; do command -v $t > /dev/null || die "$t is needed"; done
# The browser step needs Chrome and node 22 or later (its built-in WebSocket); both are optional
BROWSER=yes; WHYNOT=""
[ -x "$CHROME" ] || { BROWSER=no; WHYNOT="no Chrome at $CHROME"; }
NODEV=$(node --version 2> /dev/null | sed -E 's/^v([0-9]+).*/\1/') || NODEV=""
case "$NODEV" in ''|*[!0-9]*) BROWSER=no; WHYNOT="${WHYNOT:+$WHYNOT; }no node" ;; *) [ "$NODEV" -ge 22 ] || { BROWSER=no; WHYNOT="${WHYNOT:+$WHYNOT; }node $NODEV is older than 22"; } ;; esac
# A variable of yours must not become a property source, a JVM flag, a build setting, a native-image option or a docker build
# setting (the problem-detail lesson's loop, verbatim: sed -E, a canary planted under every name first, and the run stops if one
# survives).
for v in TIFFINBOX_CANARY SPRING_CANARY MANAGEMENT_CANARY SERVER_CANARY LOGGING_CANARY COMPOSE_CANARY BUILDKIT_CANARY BUILDX_CANARY DEBUG JAVA_TOOL_OPTIONS JDK_JAVA_OPTIONS _JAVA_OPTIONS MAVEN_OPTS MAVEN_ARGS NATIVE_IMAGE_OPTIONS DOCKER_BUILDKIT DOCKER_DEFAULT_PLATFORM SOURCE_DATE_EPOCH; do export "$v=planted-canary"; done
for v in $(env | sed -n -E 's/^(TIFFINBOX_[A-Za-z0-9_]*|SPRING_[A-Za-z0-9_]*|MANAGEMENT_[A-Za-z0-9_]*|SERVER_[A-Za-z0-9_]*|LOGGING_[A-Za-z0-9_]*|COMPOSE_[A-Za-z0-9_]*|BUILDKIT_[A-Za-z0-9_]*|BUILDX_[A-Za-z0-9_]*|DEBUG|JAVA_TOOL_OPTIONS|JDK_JAVA_OPTIONS|_JAVA_OPTIONS|MAVEN_OPTS|MAVEN_ARGS|NATIVE_IMAGE_OPTIONS|DOCKER_BUILDKIT|DOCKER_DEFAULT_PLATFORM|SOURCE_DATE_EPOCH)=.*/\1/p'); do unset "$v"; done
[ -z "$(env | grep -- '=planted-canary$')" ] || die "a variable survived the clean-up above: $(env | grep -- '=planted-canary$' | sed 's/=.*//' | paste -sd' ' -)"
# Every request this script makes goes to 127.0.0.1: an HTTP proxy named in your environment would carry curl's requests (and node's)
# to that proxy instead - 127.0.0.1 and localhost go first in no_proxy and NO_PROXY.
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
[ -L before ] && [ "$(readlink before)" = ../c6-unit23/after ] || die "before must be the link to ../c6-unit23/after - the anchor before this change"
PREV=before
for t in "$PREV" after; do
  [ -f "$t/pom.xml" ] && [ -f "$t/README.md" ] && [ -f "$t/Dockerfile" ] && [ -f "$t/.dockerignore" ] || die "the tree $t (its pom.xml, README.md, Dockerfile or .dockerignore) is missing"
  [ -e "$t/secrets" ] || [ -e "$t/target" ] || [ -e "$t/tiffinbox-web/target" ] || [ -e "$t/tiffinbox-core/target" ] || [ -e "$t/tiffinbox-local.yaml" ] && die "$t holds a secrets/, a target/ or a tiffinbox-local.yaml - it is a frozen copy, never built in place"
  grep -qx 'secrets/' "$t/.dockerignore" || die "$t's .dockerignore no longer keeps secrets/ out of a build context"; done
M2="$PWD/.m2-demo"
W=tiffinbox-web/src/main/java/com/tiffinbox/web     # the web module's Java sources, in a tree
RS=tiffinbox-web/src/main/resources                 # the web module's resources, in a tree
TC=tiffinbox-web/target/classes                     # the web module's compiled classes and resources, in a built tree
JARP=tiffinbox-web/target/tiffinbox-web-1.0.0.jar    # the executable jar, in a tree's web module
BIN=tiffinbox-web/target/tiffinbox-web               # the binary native:compile-no-fork writes, in a tree's web module
TF=secrets/tiffinbox/shutdown-token                  # the config tree's file for tiffinbox.shutdown-token
YML=$RS/application.yaml                             # the web module's configuration file, in a tree
# The demo token. FAKE, and meant to look it: it guards nothing but a demo server on 127.0.0.1 that every capture stops. It is
# written into .harness/*/secrets/ (git-ignored) when this script runs, and no capture prints it: see mask().
TOKEN=not-a-real-token-for-a-session
[ ${#TOKEN} = 30 ] || die "the demo token must be 30 characters: the published captures name its length"
CURLSET=../c5-unit11/curlset.sh
[ -f "$CURLSET" ] || die "$CURLSET is missing"
HWS='harness/probe/web/Dump.java harness/probe/web/Keys.java harness/probe/web/Sessions.java harness/probe/web/Trace.java harness/probe/web/Visits.java'
for f in harness/shutdown.sh harness/cdp.mjs harness/net.py harness/netlog.py $HWS exercise/README.md exercise/solution/SOLUTION.md README.md; do [ -f "$f" ] || die "$f is missing"; done
[ "$(ls harness/probe/web | paste -sd' ' -)" = 'Dump.java Keys.java Sessions.java Trace.java Visits.java' ] || die "harness/probe/web holds another file: javac compiles all of it"
for f in harness/probe/web/Trace.java harness/netlog.py harness/shutdown.sh; do cmp -s "$f" "../c6-unit19/$f" || die "$f is not the CORS lesson's (../c6-unit19/$f), byte for byte"; done
for f in harness/probe/web/Dump.java harness/probe/web/Keys.java; do cmp -s "$f" "../c6-unit22/$f" || die "$f is not the serving lesson's (../c6-unit22/$f), byte for byte"; done

listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
for p in 18425 8080 35729 19530 19531 19532 19533 19534 19535 19536 19537 19538 19539; do
  [ "$(listeners $p)" = 0 ] || die "something already listens on $p - this unit's ports must be free; if it is a process an interrupted run left behind, stop it: kill $(lsof -nP -iTCP:$p -sTCP:LISTEN -t 2> /dev/null | paste -sd' ' -)"; done
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
R_PAGE=$(readme "curl -s -H 'Accept: text/html' http://127.0.0.1:18431/dashboard")
# this unit's line in the anchor's README: the form's POST, its answer's headers - the redirect, its address, the session's cookie
FORMD='name=Lata&mealsPerDay=2&pricePerMeal=110&mealType=VEG'
R_FORM=$(readme "curl -s -D - -o /dev/null --data '$FORMD' http://127.0.0.1:18431/customers")
# This unit's own lines (README.md, "The commands this unit adds") - each asserted to be exactly that
mine() { grep -m1 -xF -- "$1" README.md > /dev/null || die "README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
JL='-Duser.language=en -Duser.country=US'
CPX='"tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*'
L_RUNL=$(mine "java $JL -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431")
L_CPL=$(mine "java $JL -cp $CPX\" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431")
L_URL=$(mine "$L_RUNL --server.servlet.session.tracking-modes=cookie,url")
L_V=$(mine "java $JL -cp $CPX:../hc\" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431 --spring.main.sources=probe.web.Dump,probe.web.Sessions,probe.web.Visits")
L_VURL=$(mine "$L_V --server.servlet.session.tracking-modes=cookie,url")
L_SS=$(mine "$L_V --server.servlet.session.cookie.same-site=strict")
L_SEC=$(mine "$L_V --server.servlet.session.cookie.secure=true")
L_TO=$(mine "$L_V --server.servlet.session.timeout=90s")
L_VF=$(mine "$L_SEC --server.servlet.session.cookie.same-site=strict")
L_DEVT=$(mine "java $JL -cp $CPX:\$M2/org/springframework/boot/spring-boot-devtools/4.1.1/spring-boot-devtools-4.1.1.jar:../hc\" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431 --spring.devtools.livereload.enabled=false --spring.main.sources=probe.web.Keys,probe.web.Visits --server.servlet.session.store-dir=\"\$PWD/sessions\"")
L_DOFF=$(mine "$L_DEVT --server.servlet.session.persistent=false")
L_JAVAC=$(mine "javac -parameters -d .harness/hc -cp \".harness/after/tiffinbox-web/target/extracted/lib/*\" $HWS")
WC=" -w ' %{http_code}\n'"
L_POST=$(mine "curl -s -D .harness/head.txt -o .harness/body.out$WC --data '$FORMD' http://127.0.0.1:18431/customers")
L_POSTJ=$(mine "curl -s -b .harness/jar -c .harness/jar -D .harness/head.txt -o .harness/body.out$WC --data '$FORMD' http://127.0.0.1:18431/customers")
L_PAGE=$(mine "curl -s -D .harness/head.txt -o .harness/body.html -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html' http://127.0.0.1:18431/dashboard")
L_PAGEJ=$(mine "curl -s -b .harness/jar -c .harness/jar -D .harness/head.txt -o .harness/body.html -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html' http://127.0.0.1:18431/dashboard")
L_GET=$(mine "curl -s -D .harness/head.txt -o .harness/body.out$WC http://127.0.0.1:18431/customers")
L_VIS=$(mine "curl -s -D .harness/head.txt -o .harness/body.out$WC http://127.0.0.1:18431/probe/visits")
L_VISJ=$(mine "curl -s -b .harness/jar -c .harness/jar -D .harness/head.txt -o .harness/body.out$WC http://127.0.0.1:18431/probe/visits")
JSOND='{"name":"Zoe","mealsPerDay":1,"pricePerMeal":100,"mealType":"VEG"}'
L_JSON=$(mine "curl -s -D .harness/head.txt -o .harness/body.out$WC -H 'Content-Type: application/json' --data '$JSOND' http://127.0.0.1:18431/customers")
L_LX=$(mine "curl -s -L -X POST -D .harness/head.txt -o .harness/body.out$WC --data '$FORMD' http://127.0.0.1:18431/customers")
L_LJ=$(mine "curl -s -L -b .harness/jar -c .harness/jar -D .harness/head.txt -o .harness/body.html -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html' --data '$FORMD' http://127.0.0.1:18431/customers")
L_CHROME=$(mine "\"\$CHROME\" --headless=new --user-data-dir=\"\$PWD/.harness/chrome\" --no-first-run --no-default-browser-check --disable-background-networking --disable-component-update --disable-sync --disable-domain-reliability --use-mock-keychain --password-store=basic --lang=en-US --proxy-server=http://127.0.0.1:9 --host-resolver-rules='MAP * ~NOTFOUND, EXCLUDE 127.0.0.1' --remote-debugging-address=127.0.0.1 --remote-debugging-port=19539 --log-net-log=\"\$PWD/.harness/netlog.json\" about:blank")
L_OPEN=$(mine "node harness/cdp.mjs 19539 open http://127.0.0.1:18431/dashboard .harness/ev.json")
L_FORM=$(mine "node harness/cdp.mjs 19539 form http://127.0.0.1:18431/customers/new .harness/ev.json 'name=Kiran&mealsPerDay=2&pricePerMeal=110&mealType=VEG'")
L_COOK=$(mine "node harness/cdp.mjs 19539 cookies")
L_CLOSE=$(mine "node harness/cdp.mjs 19539 close")
L_NET=$(mine "python3 harness/net.py .harness/ev.json 18431")
L_NETLOG=$(mine "python3 harness/netlog.py .harness/netlog.json 18431")
# The derivations, each asserted
P_='java '; Q_="java $JL "; r=${R_RUN/"$P_"/$Q_}; r2=${R_CP/"$P_"/$Q_}
[ "$r" = "$L_RUNL" ] && [ "$r2" = "$L_CPL" ] || die "the pinned lines must be the anchor's run and class-path lines with $JL after java, and nothing else"
for l_ in "$L_URL" "$L_VURL" "$L_SS" "$L_SEC" "$L_TO" "$L_VF" "$L_DOFF"; do case $l_ in "$L_RUNL "*) o_=${l_#"$L_RUNL "} ;; "$L_SEC "*) o_=${l_#"$L_SEC "} ;; "$L_V "*) o_=${l_#"$L_V "} ;; "$L_DEVT "*) o_=${l_#"$L_DEVT "} ;; *) die "a line with one option more: $l_" ;; esac
  case $o_ in --server.servlet.session.*=*) ;; *) die "one option, a session key: $l_" ;; esac; [ "${o_#* }" = "$o_" ] || die "one option, no more: $l_"; done
r=${L_V/:..\/hc\"/\"}; r=${r% --spring.main.sources=probe.web.Dump,probe.web.Sessions,probe.web.Visits}; [ "$r" = "$L_CPL" ] || die "the harness line must be the pinned class-path line with the harness added and Dump, Sessions and Visits joined, and nothing else"
r=${L_DEVT/:\$M2\/org\/springframework\/boot\/spring-boot-devtools\/4.1.1\/spring-boot-devtools-4.1.1.jar:..\/hc\"/\"}; r=${r% --spring.devtools.livereload.enabled=false --spring.main.sources=probe.web.Keys,probe.web.Visits --server.servlet.session.store-dir=\"\$PWD/sessions\"}; [ "$r" = "$L_CPL" ] || die "the DevTools line must be the pinned class-path line with DevTools' jar and the harness added, Live Reload off, Keys and Visits joined and a session folder named, and nothing else"
[ "${L_JAVAC#* -cp \"*\" }" = "$HWS" ] || die "the harness's javac line must compile the five files in harness/probe/web, and nothing else"
P_=' -D - -o /dev/null '; Q_=" -D .harness/head.txt -o .harness/body.out$WC "; r=${R_FORM/"$P_"/$Q_}; [ "$r" = "$L_POST" ] || die "the POST line must be the anchor's form line with the headers and the body sent to files and curl's status printed, and nothing else"
JAR='curl -s -b .harness/jar -c .harness/jar '
[ "${L_POST/curl -s /$JAR}" = "$L_POSTJ" ] && [ "${L_PAGE/curl -s /$JAR}" = "$L_PAGEJ" ] && [ "${L_VIS/curl -s /$JAR}" = "$L_VISJ" ] || die "a jar line must be its line with curl's cookie jar (-b, -c .harness/jar), and nothing else"
P_='curl -s '; Q_="curl -s -D .harness/head.txt -o .harness/body.html -w ' %{http_code} · Content-Type: [%{content_type}]\n' "; r=${R_PAGE/"$P_"/$Q_}; [ "$r" = "$L_PAGE" ] || die "the page line must be the anchor's with the headers and the body sent to files and curl's status and Content-Type printed, and nothing else"
P_=" --data '$FORMD'"; r=${L_POST/"$P_"/}; [ "$r" = "$L_GET" ] && Q_=/probe/visits; [ "${L_GET/\/customers/$Q_}" = "$L_VIS" ] || die "the GET lines must be the POST line without its form, at /customers and /probe/visits, and nothing else"
P_=' --data '; Q_=" -H 'Content-Type: application/json' --data "; r=${L_POST/"$P_"/$Q_}; P_="'$FORMD'"; Q_="'$JSOND'"; r=${r/"$P_"/$Q_}; [ "$r" = "$L_JSON" ] || die "the JSON line must be the POST line with a JSON body and its Content-Type, and nothing else"
[ "${L_POST/curl -s /curl -s -L -X POST }" = "$L_LX" ] || die "the -L -X POST line must be the POST line with -L -X POST, and nothing else"
P_='curl -s '; Q_='curl -s -L '; r=${L_PAGEJ/"$P_"/$Q_}; P_=' http://127.0.0.1:18431/dashboard'; Q_=" --data '$FORMD' http://127.0.0.1:18431/customers"; r=${r/"$P_"/$Q_}; [ "$r" = "$L_LJ" ] || die "the -L line must be the jar's page line with -L and the form, posted to /customers, and nothing else"
off() { local c=${2/mvn -B /mvn -o -B -Dmaven.repo.local=\"\$M2\" }
  [ -n "$3" ] && c=${c/ $3/ -DskipTests clean $3}
  printf 'cd %s && %s\n' "$1" "$c"; }
dev() { local c=${1#cd * && }; c=${c/ -o -B -Dmaven.repo.local=\"\$M2\" / -B }; c=${c/ -DskipTests clean / }; printf '%s\n' "$c"; }
# at DIR PORT 'README LINE': the README's line run from DIR, its port 18431 made PORT - and a java line with the JVM's locale pinned
# right after "java" (this unit's pinned lines show the form, and at() must give them back)
at() { local l=${3/--tiffinbox.port=18431/--tiffinbox.port=$2}; case $l in 'java -Djarmode=tools '*|"java $JL "*) ;; 'java '*) l="java $JL ${l#java }" ;; esac; printf 'cd %s && %s\n' "$1" "$l"; }
url() { printf '%s\n' "${1/:18431\//:$2/}"; }
# u PORT 'LINE': one of this unit's curl or Chrome lines, its port 18431 made PORT. fd 'LINE' 'FORM': its form body made FORM
u() { printf '%s\n' "${2//:18431\//:$1/}"; }
fd() { local p="'$FORMD'" q="'$2'"; printf '%s\n' "${1/"$p"/$q}"; }
# lq 'LINE' 'ADDRESS': a curl line of this unit's, its address - the last word - made ADDRESS (a redirect's Location, quoted)
lq() { printf '%s\n' "${1% http://*} '$2'"; }
nlq() { printf '%s\n' "${L_NETLOG% 18431} $*"; }
exe() { printf '%s\n' "$1" | sed -E 's/&& (([A-Z_]+=[^ ]* )*)/\&\& \1exec /'; }
UARG='--user "$(id -u):$(id -g)"'
dbuild() { local c=${R_DBUILD/docker build -t tiffinbox-docker:1.0.0 /docker build --progress=plain -t $IMG }; printf 'cd %s && %s\n' "$1" "$c"; }
drun() { local c=${R_DRUN/--name tiffinbox /--name $BOX $UARG }; c=${c/127.0.0.1:18431:18425/127.0.0.1:$2:18425}; c=${c/% tiffinbox-docker:1.0.0/ $IMG}; [ -z "${3:-}" ] || c="$c $3"; printf 'cd %s && %s\n' "$1" "$c"; }
undock() { local c=${1#cd * && }; c=${c/--progress=plain /}; c=${c/" $UARG"/}; c=${c//$IMG/tiffinbox-docker:1.0.0}; c=${c/--name $BOX /--name tiffinbox }; c=${c/127.0.0.1:1953?:18425/127.0.0.1:18431:18425}; printf '%s\n' "$c"; }
[ "$(undock "$(dbuild .harness/x)")" = "$R_DBUILD" ] || die "not the README's build line with the declared changes: $(dbuild .harness/x)"
[ "$(undock "$(drun .harness/x 19534)")" = "$R_DRUN" ] || die "not the README's run line with the declared changes: $(drun .harness/x 19534)"
O_URL=${L_URL#"$L_RUNL "}
[ "$(undock "$(drun .harness/x 19534 "$O_URL")")" = "$R_DRUN $O_URL" ] || die "not the README's run line with the declared changes and B's option: $(drun .harness/x 19534 "$O_URL")"
C_PRE=$(off .harness/pre "$R_INSTALL" install)
for c in "$C_PRE" "$(off .harness/x "$R_PLAIN" package)" "$(off .harness/x "$R_PNAT" package)" "$(off .harness/x "$R_NATIVE")"; do
  r=$(dev "$c"); [ "$r" = "$R_PLAIN" ] || [ "$r" = "$R_PNAT" ] || [ "$r" = "$R_INSTALL" ] || [ "$r" = "$R_NATIVE" ] || die "not a README line with the offline changes: $c"; done
[ "$(exe "$(at .harness/x 19530 "$R_RUN")")" = "cd .harness/x && exec ${L_RUNL/18431/19530}" ] && [ "$(at .harness/x 18431 "$R_CP")" = "cd .harness/x && $L_CPL" ] && [ "$(at .harness/x 18431 "$L_V")" = "cd .harness/x && $L_V" ] && [ "$(at .harness/x 18431 "$L_DEVT")" = "cd .harness/x && $L_DEVT" ] && [ "$(at .harness/x 19536 "$R_BIN")" = 'cd .harness/x && tiffinbox-web/target/tiffinbox-web --tiffinbox.port=19536' ] || die "at(): the pinned lines are not README.md's, or the binary's line got the JVM's options"
[ "$(u 18431 "$L_POST")" = "$L_POST" ] && [ "$(u 19530 "$L_OPEN")" = 'node harness/cdp.mjs 19539 open http://127.0.0.1:19530/dashboard .harness/ev.json' ] && [ "$(fd "$L_POST" 'name=Om')" = "curl -s -D .harness/head.txt -o .harness/body.out -w ' %{http_code}\n' --data 'name=Om' http://127.0.0.1:18431/customers" ] && [ "$(lq "$L_PAGE" 'http://127.0.0.1:19530/x;a')" = "${L_PAGE% http://*} 'http://127.0.0.1:19530/x;a'" ] && [ "$(nlq 18431)" = "$L_NETLOG" ] || die "u(), fd(), lq() or nlq()"
echo "  the commands: after/README.md gives the $(grep -c '^R_[A-Z]*=$(readme ' receipts.sh) lines this script runs or derives from; README.md the $(grep -c '^L_[A-Z]*=$(mine ' receipts.sh) this unit adds"
# ---- build: before the captures - after/'s native install (it fills .m2-demo on a fresh clone) -------------------------------
rm -rf .harness; mkdir -p .harness; : > .harness/imgids
rsync -a --exclude target --exclude secrets after/ .harness/pre/
ZIP="$M2/org/graalvm/buildtools/graalvm-reachability-metadata/1.1.8/graalvm-reachability-metadata-1.1.8-repository.zip"
ghub() { grep -qE 'Downloaded GraalVM reachability metadata repository from http|Failed to download from http' "$1"; }
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
tree() { mkdir -p "$1/secrets/tiffinbox"; (umask 077 && printf '%s\n' "$TOKEN" > "$1/$TF"); chmod 700 "$1/secrets" "$1/secrets/tiffinbox"; }
mbuild "$C_PRE" .harness/build-pre.log ".harness/pre (after/, the profile native, both modules into \$M2)"
# DevTools is no dependency of the tree, so no build fetches it: on a fresh clone's empty .m2-demo it is fetched by name, offline first
# (the c6 DevTools lesson's way: dependency:get, and the line says which)
DTJP=org/springframework/boot/spring-boot-devtools/4.1.1/spring-boot-devtools-4.1.1.jar
if [ ! -f "$M2/$DTJP" ]; then
  mbuild "cd .harness/pre && mvn -o -B -Dmaven.repo.local=\"\$M2\" dependency:get -Dartifact=org.springframework.boot:spring-boot-devtools:4.1.1 -Dtransitive=false" .harness/devtools-get.log "DevTools 4.1.1's jar, by name (dependency:get)"; fi
for a in org/springframework/boot/spring-boot-starter-thymeleaf/4.1.1/spring-boot-starter-thymeleaf-4.1.1.jar org/graalvm/buildtools/native-maven-plugin/1.1.8/native-maven-plugin-1.1.8.jar $DTJP; do
  [ -f "$M2/$a" ] || die "$a is not in .m2-demo after the first build - README.md, The repository"; done
[ -f "$ZIP" ] || die "GraalVM's metadata repository is not in .m2-demo after the first build - README.md, The repository"
echo "  .m2-demo holds Thymeleaf's starter, DevTools, GraalVM's native plugin 1.1.8 and its metadata repository"
if [ $BROWSER = yes ]; then echo "  the browser: $("$CHROME" --version 2> /dev/null | head -1) · node $(node --version) - printed here, never in a capture"; else echo "  the browser: none - $WHYNOT"; fi

# ---- helpers ------------------------------------------------------------------------------------------------------------
raw() { local t=$1; shift; cat "$@" | LC_ALL=C grep -aoF -- "$t" | wc -l | tr -d ' '; }
LOGS=0; CLOGS=0; LASTE=""
first() { grep -m1 -E ' : Starting |^main Starting ' "$1" | sed 's/^.* : //; s/^main //; s/ with PID .*$//'; }
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
started() { grep -m1 ' : Tomcat started on port ' "$1" | sed 's/^.*--- \[[^]]*\] //; s/ *: /: /'; }
tline() { local i=0; while ! grep -q 'Tomcat started on port ' .harness/run.out && [ $i -lt 120 ]; do sleep 0.25; i=$((i + 1)); done
  echo "  Boot's started line - logger: message: $(started .harness/run.out)"; }
sortj() { python3 -c '
import json, re, sys
for l in sys.stdin.read().splitlines():
    b, _, s = l.rpartition(" ")
    try: o = json.dumps(json.loads(b), sort_keys=True, separators=(",", ":"))
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
mask() { awk -v t="$TOKEN" -v g="${GRAALVM_HOME:-}" -v u="$U" -v up="$UP" -v hm="$HOME" -v me="$ME" -v tl="${#TOKEN}" '
  function lit(x) { gsub(/[][\\.^$*+?(){}|\/]/, "\\\\&", x); return x }
  function enc(x) { gsub(/ /, "%20", x); return x }
  BEGIN { T = lit(t); G = lit(g); GE = lit(enc(g)); P = lit(u); Q = lit(up); H = lit(hm); PE = lit(enc(u)); QE = lit(enc(up)); M = "(^|[^A-Za-z0-9_])" lit(me) "([^A-Za-z0-9_]|$)" }
  { gsub(T, "[masked: the " tl "-character token]"); if (g != "") { gsub(G, "$GRAALVM_HOME"); gsub(GE, "$GRAALVM_HOME") }; gsub(P, "…"); gsub(PE, "…")
    gsub(Q, "…/.."); gsub(QE, "…/.."); gsub(H, "~"); gsub(/\$\$SpringCGLIB\$\$[0-9]+/, "$$SpringCGLIB$$<n>")
    gsub(/tomcat-handler-[0-9]+/, "tomcat-handler-<n>")
    gsub(/Chrome\/[0-9][0-9.]*/, "Chrome/<version>")
    gsub(/JSESSIONID=[0-9A-F]+/, "JSESSIONID=<id>"); gsub(/jsessionid=[0-9A-F]+/, "jsessionid=<id>")
    if (match($0, /sec-ch-ua: /)) $0 = substr($0, 1, RSTART + RLENGTH - 1) "(its brands and their versions: masked)"
    while (match($0, M)) { pre = substr($0, 1, RSTART - 1); s = substr($0, RSTART, RLENGTH); post = substr($0, RSTART + RLENGTH)
      sub(lit(me), "<user>", s); $0 = pre s post }
    print }'; }

unpub=""
cap() { local nm=$1 h pub i; shift
  for i in 1 2 3; do "$@" > .harness/cap.raw 2>&1 || true; [ -z "$pid$xpid$cpid" ] || die "$nm left a process running"
    [ -z "$(docker ps -aq --filter "name=^$BOX\$")" ] || die "$nm left a container"
    raw "$TOKEN" .harness/cap.raw > ".harness/raw-$nm.$i"; mask < .harness/cap.raw > ".r-$nm.$i"; done
  h=$(md5 -q ".r-$nm.1")
  [ "$h" = "$(md5 -q ".r-$nm.2")" ] && [ "$h" = "$(md5 -q ".r-$nm.3")" ] || die "$nm drifts across three runs (diff .r-$nm.1 .r-$nm.2 .r-$nm.3)"
  mv ".r-$nm.1" ".r-$nm.out"; rm -f ".r-$nm.2" ".r-$nm.3"
  pub=$(awk -v n="$nm" '$1 == n { print $2 }' receipts.md5 2> /dev/null || true)
  if [ -z "$pub" ]; then printf '  %-10s md5 %s  3/3  (no published hash)\n' "$nm" "$h"; unpub="$unpub $nm"
  elif [ "$pub" = "$h" ]; then printf '  %-10s md5 %s  3/3  = published\n' "$nm" "$h"
  else printf '  %-10s md5 %s  3/3  DIFFERS from the published %s\n' "$nm" "$h" "$pub"
    die "$nm is not the published capture - suspect another JDK, GraalVM, Boot, Maven, Docker or Chrome, another base image, a busy machine, a busy port, a variable of yours, or an edited source; diff .r-$nm.out against its block in README.md"; fi; }
copy() { rm -rf "$2" "$2".*; rsync -a --exclude target --exclude secrets "$1/" "$2/"; tree "$2"; }
pbuild() { local c; c=$(off "$1" "${3:-$R_PLAIN}" package); echo "\$ $c"; mbuild "$c" "$1.build.log" "$2"; }
lines() { if [ -f "$1" ]; then wc -l < "$1" | tr -d ' '; else echo none; fi; }
libs() { unzip -Z1 "$1" | grep -E '^BOOT-INF/lib/.*\.jar$' | sed 's#^BOOT-INF/lib/##' | sort; }
extract() { local c="cd $1 && $R_EXTRACT"; echo "\$ $c"; (eval "$c") > .harness/extract.log 2>&1 < /dev/null || die "the README's extract line failed in $1"; echo "  exit 0"; }
settle() { local i=0 a b=-1; while [ $i -lt 30 ]; do a=$(wc -l < .harness/run.out | tr -d ' '); [ "$a" = "$b" ] && return 0; b=$a; sleep 0.5; i=$((i + 1)); done; die "the log never settled"; }
mark() { settle; wc -l < .harness/run.out | tr -d ' '; }
# logl FROM [LEVELS]: the run's lines after line FROM at those levels, matched by the log's own line shape (a date first, R.120)
logl() { awk -v from="$1" -v lv="${2:-WARN|ERROR}" 'NR > from && $0 ~ ("^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T[^ ]+ +(" lv ") [0-9]+ --- \\[") { l = $2; s = $0; i = index(s, " --- ["); s = substr(s, i + 6); i = index(s, "] "); s = substr(s, i + 2)
    i = index(s, " : "); lg = substr(s, 1, i - 1); sub(/ +$/, "", lg); msg = substr(s, i + 3)
    gsub(/@[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]+/, "@…", msg); print "    " l " " lg ": " msg }' .harness/run.out; }
recs() { awk -v from="$1" '
  function out() { if (inr) print "      its stack frames: " (fr > 40 ? "over 40" : fr + 0) ", its other lines: " (ot + 0) " - none shown"; inr = 0; fr = 0; ot = 0; ex = 0 }
  NR <= from { next }
  /^HOOK [0-9]+ / { next }
  /^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T[^ ]+ +[A-Z]+ [0-9]+ --- \[/ { out() }
  /^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T[^ ]+ +(WARN|ERROR) [0-9]+ --- \[/ { s = $0; i = index(s, " --- ["); s = substr(s, i + 6); i = index(s, "] "); s = substr(s, i + 2)
    i = index(s, " : "); lg = substr(s, 1, i - 1); sub(/ +$/, "", lg); m = substr(s, i + 3); gsub(/@[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]+/, "@…", m)
    print "    " $2 " " lg ": " m; inr = 1; ex = 1; next }
  inr && /^\tat / { fr++; next }
  inr && ex && NF > 0 { print "      " $0; ex = 0; next }
  inr { ot++ }
  END { out() }' .harness/run.out; }
WARNS() { settle; echo "  WARN lines in this run's log, at Boot's default level: $(logl 0 WARN | grep -c . || true) · ERROR lines: $(logl 0 ERROR | grep -c . || true)"; }
hk() { local o; o=$(awk -v from="$1" 'NR > from && /^HOOK [0-9]+ / { n = $2 + 0; if (k && n <= last) bad = 1; last = n; s = $0; sub(/^HOOK [0-9]+ /, "", s); l[++k] = s }
    END { if (bad) exit 3; print "  the harness'"'"'s lines it printed, in order: " (k + 0); for (i = 1; i <= k; i++) printf "    %2d %s\n", i, l[i] }' .harness/run.out) || die "the harness's lines after line $1 are out of order"
  printf '%s\n' "$o"; }
blkraw() { awk -v a="$1" -v b="$2" 'index($0, a) == 1 { f = 1; next } b != "" && index($0, b) == 1 { f = 0 } f' .harness/cap.raw; }
asame() { [ "$(blkraw "$1" "$2")" = "$(blkraw "$3" "$4")" ] && [ -n "$(blkraw "$3" "$4")" ] && echo yes || echo no; }
# hall: the headers curl wrote (-D .harness/head.txt) - its status line, then every header in the order it came, whole, on one line;
# a Date header's value (the time) is not printed. Under curl -L the file holds every answer curl read: each one's status line
# starts a new line
hall() { [ -f .harness/head.txt ] || { echo "  its headers: no file - curl wrote none"; return 0; }
  tr -d '\r' < .harness/head.txt | awk '/^HTTP\// { if (st != "") print "  " st sh; st = $0; sub(/ +$/, "", st); sh = ""; next } $0 == "" { next }
    { n = $0; sub(/:.*/, "", n); if (tolower(n) == "date") $0 = n ": (the time - not printed)"; sh = sh " · " $0 } END { if (st != "") print "  " st sh }'; }
# hv NAME: one header's value from the headers curl wrote (none: not sent)
hv() { tr -d '\r' < .harness/head.txt 2> /dev/null | awk -v n="$1" 'BEGIN { n = tolower(n) } { k = $0; sub(/:.*/, "", k) } tolower(k) == n { sub(/^[^:]*: /, ""); print; f = 1; exit } END { if (!f) print "none" }'; }
# pagef FILE: a page curl wrote, as this unit prints one - never whole: its <title>, its line and byte counts; its notes (each
# <p class="note"> line, whole); its table's first column; how many of its links (href) carry a session id. JSON: its bytes, the
# error timestamp masked. An empty body: "none".
pagef() { python3 - "$1" <<'PY'
import re, sys
f = sys.argv[1]
try: b = open(f, "rb").read()
except OSError: print("  body: no file - curl wrote none"); sys.exit(0)
if not b: print("  body: none (0 bytes)"); sys.exit(0)
t = b.decode("utf-8", "replace"); L = t.splitlines()
ti = re.search(r"<title>(.*?)</title>", t)
if ti:
    notes = [l.strip() for l in L if 'class="note"' in l]
    col = re.findall(r"<tr><td>([^<]*)</td>", t)
    links = len(re.findall(r'href="[^"]*;jsessionid=', t))
    print("  the page: <title>%s</title> · %d lines, %d bytes - not shown but · its notes: %s · its table's first column: %s · its links that carry a session id: %d"
          % (ti.group(1), len(L), len(b), " | ".join(notes) if notes else "none", " ".join(col) if col else "no table", links))
else:
    print("  body: " + re.sub(r"\"timestamp\":[0-9]+", "\"timestamp\":…", re.sub(r"\"timestamp\":\"[^\"]*\"", "\"timestamp\":\"…\"", t)))
PY
}
# bodyf: the body curl wrote to .harness/body.out - a page as pagef prints one, anything else as its bytes; no file: "no file"
bodyf() { pagef .harness/body.out; }
# sid: the session id the last answer's Set-Cookie carries (none: none); lid: the one its Location carries (none: none) - read
# before any mask, and printed only as present or none, and whether the two are the same
sid() { tr -d '\r' < .harness/head.txt 2> /dev/null | sed -n 's/^[Ss]et-[Cc]ookie: JSESSIONID=\([0-9A-F]*\);.*/\1/p' | tail -1 | grep . || echo none; }
lid() { tr -d '\r' < .harness/head.txt 2> /dev/null | sed -n 's/^[Ll]ocation: .*;jsessionid=\([0-9A-F]*\).*/\1/p' | tail -1 | grep . || echo none; }
ids() { local a b; a=$(sid); b=$(lid); echo "  the session id in its Set-Cookie: $( [ "$a" = none ] && echo none || echo present) · in its Location: $( [ "$b" = none ] && echo none || echo present) · the same id: $( [ "$a" != none ] && [ "$a" = "$b" ] && echo yes || echo no)"; }
# jarf: curl's cookie jar (.harness/jar), its cookies one line each, the fields of curl's own file: the domain (an HttpOnly
# cookie's prefixed #HttpOnly_), whether subdomains get it, the path, secure only, when it expires (0: when the client closes -
# a session cookie), the name=value
jarf() { if [ ! -f .harness/jar ]; then echo "  curl's cookie jar: no file"; return 0; fi
  awk -F '\t' 'NF == 7 { n++; l[n] = $1 " · subdomains " $2 " · path " $3 " · secure only " $4 " · expires " $5 " · " $6 "=" $7 }
    END { print "  curl'"'"'s cookie jar: " (n + 0) " cookie" (n == 1 ? "" : "s"); for (i = 1; i <= n; i++) print "    " l[i] }' .harness/jar; }
# rq 'CURL LINE' [nolog]: a curl line of this unit's (its headers and body to files), printed and run; curl's own line and the WARN
# and ERROR lines the request added; its headers (hall); its body (pagef for a page, bodyf for the rest); each WARN or ERROR record.
# The files are removed first: an answer curl wrote no body for prints "no file" (R.119). nolog: no log read (a container's)
rq() { local n0 w e; [ -n "${2:-}" ] || n0=$(mark); rm -f .harness/head.txt .harness/body.html .harness/body.out; echo "\$ $1"; (eval "$1") 2> /dev/null < /dev/null > .harness/curl.txt || true
  if [ -n "${2:-}" ]; then echo "  curl's line:$(cat .harness/curl.txt)"
  else settle; w=$(logl "$n0" WARN | grep -c . || true); e=$(logl "$n0" ERROR | grep -c . || true); echo "  curl's line:$(cat .harness/curl.txt) · WARN lines it added: $w · ERROR lines: $e"; fi
  hall; case $1 in *' -o .harness/body.html '*) pagef .harness/body.html ;; *) bodyf ;; esac
  [ -n "${2:-}" ] || [ "$w$e" = 00 ] || recs "$n0"; }
# run 'COMMAND': a file command (cp, rm, md5) run from its line's folder, printed as it runs; its output; its exit code
run() { local e=0; echo "\$ $1"; (eval "$1") > .harness/runc.txt 2>&1 < /dev/null || e=$?; sed 's/^/  /' .harness/runc.txt; echo "  exit $e"; }
meta() { unzip -p "$1" META-INF/spring-configuration-metadata.json | python3 -c '
import json, sys
k = sys.argv[1]; d = json.load(sys.stdin)
p = [x for x in d.get("properties", []) if x["name"] == k]
if len(p) != 1: print("  %s: %d entries" % (k, len(p))); sys.exit(0)
p = p[0]; print("  %s - type %s · default %s · %s" % (k, p["type"].rsplit(".", 1)[-1], json.dumps(p.get("defaultValue")), p.get("description", "")))' "$2"; }
# The filters, checked on planted inputs before any capture (R.65): the level counts by line shape; the record filter; the harness's
# lines (a falling running number stops the run); the header filters; the page and body filters; the masks
{ printf '%s\n' '2026-10-22T00:00:00.000Z  WARN 1 --- [planted] o.s.web.servlet.PageNotFound      : planted warning' 'HOOK 0001 Dump            > GET /x ERROR /error' '2026-10-22T00:00:00.001Z ERROR 1 --- [planted] o.a.c.c.C.[.[.[/].[dispatcherServlet]    : planted error' 'java.lang.IllegalArgumentException: planted'
  i=0; while [ $i -lt 45 ]; do printf '\tat planted.Frame%s(Planted.java)\n' $i; i=$((i + 1)); done; printf '%s\n' 'HOOK 0002 Dump            < 500 GET /x'; } > .harness/run.out
[ "$(logl 0 ERROR | grep -c .)" = 1 ] && [ "$(logl 0 WARN | grep -c .)" = 1 ] && [ "$(grep -c ' ERROR ' .harness/run.out)" = 2 ] || die "the level counts: the planted log must give 1 WARN and 1 ERROR by line shape (a bare ' ERROR ' gives 2)"
[ "$(recs 0)" = "$(printf '%s\n' '    WARN o.s.web.servlet.PageNotFound: planted warning' '      its stack frames: 0, its other lines: 0 - none shown' '    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: planted error' '      java.lang.IllegalArgumentException: planted' '      its stack frames: over 40, its other lines: 0 - none shown')" ] || die "recs: the planted log does not come out as declared (.harness/run.out)"
printf '%s\n' 'HOOK 0007 Dump            > GET /x' 'HOOK 0006 Dump            < 200 GET /x' > .harness/run.out
( hk 0 > /dev/null 2>&1 3> /dev/null ) && die "hk: a falling running number must stop the run"
rm -f .harness/run.out
printf 'HTTP/1.1 302 \r\nSet-Cookie: JSESSIONID=0123456789ABCDEF0123456789ABCDEF; Path=/; HttpOnly\r\nLocation: http://127.0.0.1:1/dashboard;jsessionid=0123456789ABCDEF0123456789ABCDEF\r\nDate: Thu, 22 Oct 2026 05:59:37 GMT\r\n\r\nHTTP/1.1 405 \r\nAllow: GET\r\n\r\n' > .harness/head.txt
[ "$(hall)" = "$(printf '%s\n' '  HTTP/1.1 302 · Set-Cookie: JSESSIONID=0123456789ABCDEF0123456789ABCDEF; Path=/; HttpOnly · Location: http://127.0.0.1:1/dashboard;jsessionid=0123456789ABCDEF0123456789ABCDEF · Date: (the time - not printed)' '  HTTP/1.1 405 · Allow: GET')" ] || die "hall: the planted headers (two answers, as curl -L writes them) do not come out as declared"
[ "$(hv location)" = 'http://127.0.0.1:1/dashboard;jsessionid=0123456789ABCDEF0123456789ABCDEF' ] && [ "$(hv Content-Length)" = none ] || die "hv: the planted headers' values do not come out as declared"
[ "$(ids)" = '  the session id in its Set-Cookie: present · in its Location: present · the same id: yes' ] || die "ids: the planted ids must be the same"
sed 's/;jsessionid=0123/;jsessionid=0124/' .harness/head.txt > .harness/head2.txt && mv .harness/head2.txt .harness/head.txt
[ "$(ids)" = '  the session id in its Set-Cookie: present · in its Location: present · the same id: no' ] || die "ids: two planted ids that differ must not be the same"
printf 'HTTP/1.1 200 \r\n\r\n' > .harness/head.txt; [ "$(ids)" = '  the session id in its Set-Cookie: none · in its Location: none · the same id: no' ] || die "ids: no id must come out as none"
rm -f .harness/head.txt
printf '%s\n' '<!DOCTYPE html>' '<html>' '<head><title>Planted · TiffinBox</title><link rel="stylesheet" href="/css/x.css;jsessionid=AB"></head>' '<main>' '  <p class="note">Lata added</p>' '  <table>' '    <tr><td>Meera</td><td>1</td></tr>' '    <tr><td>Lata</td><td>2</td></tr>' '  </table><a href="/dashboard;jsessionid=AB">x</a>' '</main>' '</html>' > .harness/body.html
[ "$(pagef .harness/body.html)" = '  the page: <title>Planted · TiffinBox</title> · 11 lines, 319 bytes - not shown but · its notes: <p class="note">Lata added</p> · its table'"'"'s first column: Meera Lata · its links that carry a session id: 2' ] || die "pagef: the planted page does not come out as declared"
printf '{"timestamp":"2026-10-22T05:59:37.000Z","status":404}' > .harness/body.html; [ "$(pagef .harness/body.html)" = '  body: {"timestamp":"…","status":404}' ] || die "pagef: a JSON body must come out as its bytes, the timestamp masked"
rm -f .harness/body.html
: > .harness/body.out; [ "$(bodyf)" = '  body: none (0 bytes)' ] || die "bodyf: an empty body must come out as none"
rm -f .harness/body.out; [ "$(bodyf)" = '  body: no file - curl wrote none' ] || die "bodyf: no file must come out as no file"
printf '# Netscape HTTP Cookie File\n# planted\n\n#HttpOnly_127.0.0.1\tFALSE\t/\tFALSE\t0\tJSESSIONID\t0123456789ABCDEF0123456789ABCDEF\n' > .harness/jar
[ "$(jarf | mask)" = "$(printf '%s\n' "  curl's cookie jar: 1 cookie" '    #HttpOnly_127.0.0.1 · subdomains FALSE · path / · secure only FALSE · expires 0 · JSESSIONID=<id>')" ] || die "jarf: the planted jar does not come out as declared"
rm -f .harness/jar
[ "$(printf '%s\n' 'User-Agent: Mozilla/5.0 (Macintosh) HeadlessChrome/155.0.0.0 Safari/537.36' 'sec-ch-ua: "Google Chrome";v="155"' 'sec-ch-ua-mobile: ?0' '[x][tomcat-handler-12] x' 'Set-Cookie: JSESSIONID=0123456789ABCDEF0123456789ABCDEF; Path=/' 'Location: /dashboard;jsessionid=0123456789ABCDEF0123456789ABCDEF' | mask)" = "$(printf '%s\n' 'User-Agent: Mozilla/5.0 (Macintosh) HeadlessChrome/<version> Safari/537.36' 'sec-ch-ua: (its brands and their versions: masked)' 'sec-ch-ua-mobile: ?0' '[x][tomcat-handler-<n>] x' 'Set-Cookie: JSESSIONID=<id>; Path=/' 'Location: /dashboard;jsessionid=<id>')" ] || die "mask: Chrome's version, a request thread's number and a session's id must be masked, and nothing else"
echo "  the filters: the level counts (a harness line that says ERROR is no ERROR line), the record filter, the harness's lines, the header filters, the session-id comparison, the page and body filters, the cookie jar's filter and the masks print their planted inputs as declared"

# asame A B C D: whether block A..B and block C..D of this run's output, masked, are line for line the same (and not empty)
blkm() { awk -v a="$1" -v b="$2" 'index($0, a) == 1 { f = 1; next } b != "" && index($0, b) == 1 { f = 0 } f' .harness/cap.raw | mask; }
asame() { [ "$(blkm "$1" "$2")" = "$(blkm "$3" "$4")" ] && [ -n "$(blkm "$3" "$4")" ] && echo yes || echo no; }
# srec FROM: the server's record of the requests since log line FROM - what the harness printed (Dump: each request and its
# answer; Sessions: each session Tomcat made), counted: the requests Dump printed, the Set-Cookie headers among the answers, the
# sessions created
srec() { settle; echo "  the server's record since: requests Dump printed $(awk -v f="$1" 'NR > f && /^HOOK [0-9]+ Dump +> [A-Z]+ \//' .harness/run.out | grep -c . || true) · Set-Cookie headers among their answers $(awk -v f="$1" 'NR > f && /^HOOK [0-9]+ Dump +<   Set-Cookie: /' .harness/run.out | grep -c . || true) · sessions Tomcat created (Sessions) $(awk -v f="$1" 'NR > f && /^HOOK [0-9]+ Sessions +a session was created$/' .harness/run.out | grep -c . || true)"; }
# rqs 'CURL LINE': rq, then the server's record of that one request (a run with the harness joined)
rqs() { local n0; n0=$(mark); rq "$1"; srec "$n0"; }

# ---- change: the flash, the note, one key ------------------------------------------------------------------------------------------
cdiff() { diff -U0 "$1" "$2" | tail -n +3 > .harness/code.diff || true
  echo "  its diff (diff -U0, its file names cut) - hunks: $(grep -c '^@@ ' .harness/code.diff || true) · lines out: $(grep -c '^-' .harness/code.diff || true) · in: $(grep -c '^+' .harness/code.diff || true) - whole:"
  sed 's/^/    /' .harness/code.diff; }
yline() { awk -v k="$2" '$0 == k { print NR; exit }' "$1"; }
change() { local f n m k y d
  echo "the previous tree and after/, both copied under .harness/ with a config tree, each built with the README's line (offline):"
  copy "$PREV" .harness/before; copy after .harness/after
  pbuild .harness/before "the previous tree"; pbuild .harness/after "after/"
  echo "the two jars extracted (the README's line) - the class path the harness runs on:"
  for t in before after; do extract .harness/$t; done
  echo "the harness, compiled against after/'s own libraries - with -parameters:"
  echo "\$ $L_JAVAC"; rm -rf .harness/hc; (eval "$L_JAVAC") > .harness/javac.log 2>&1 < /dev/null || { cat .harness/javac.log >&3; die "the harness did not compile against after/'s libraries"; }
  echo "  exit 0 · its classes: $(cd .harness/hc && find . -name '*.class' | sed 's#^\./##' | sort | paste -sd' ' -)"
  echo "the files that differ, and the files only one tree has:"
  echo "\$ diff -rq -x target -x secrets .harness/before .harness/after"
  diff -rq -x target -x secrets .harness/before .harness/after | sed 's/^/  /' || true
  (cd after && find . -type f | sed 's#^\./##' | sort) > .harness/files.txt
  n=0; m=0; k=0; while IFS= read -r f; do m=$((m + 1)); if [ ! -e ".harness/before/$f" ]; then k=$((k + 1)); elif cmp -s ".harness/before/$f" ".harness/after/$f"; then n=$((n + 1)); fi; done < .harness/files.txt
  echo "  after/'s files: $m · byte for byte the previous tree's: $n · new: $k · those that differ: $((m - n - k))"
  for f in $W/DashboardPage.java $RS/templates/dashboard.html $YML; do
    echo "  $f: $(lines ".harness/before/$f") lines -> $(lines ".harness/after/$f")"; cdiff ".harness/before/$f" ".harness/after/$f"; done
  y=.harness/after/$YML; d=$(yline "$y" '---')
  echo "  where the key sits in after/'s application.yaml (line numbers; the first document ends at the first ---):"
  echo "    server: line $(yline "$y" 'server:') · servlet: line $(yline "$y" '  servlet:') · session: line $(yline "$y" '    session:') · tracking-modes: line $(yline "$y" '      tracking-modes: cookie') · the first ---: line $d · lines in the first document at the first column that say server: $(awk -v d="$d" 'NR < d && /^server:$/' "$y" | grep -c . || true)"
  diff .harness/before/README.md .harness/after/README.md > .harness/file.diff || true
  echo "  README.md - the anchor's README: lines added $(grep -c '^> ' .harness/file.diff || true), removed $(grep -c '^< ' .harness/file.diff || true) - its new section and the history notes the change made false (not shown)"
  echo "  Boot's own metadata for the session's keys (spring-boot-web-server-4.1.1.jar, META-INF/spring-configuration-metadata.json):"
  for k in server.servlet.session.tracking-modes server.servlet.session.timeout server.servlet.session.persistent server.servlet.session.store-dir server.servlet.session.cookie.http-only server.servlet.session.cookie.secure server.servlet.session.cookie.same-site; do meta .harness/after/tiffinbox-web/target/extracted/lib/spring-boot-web-server-4.1.1.jar "$k"; done
  libs .harness/before/$JARP > .harness/lb.txt; libs .harness/after/$JARP > .harness/la.txt
  echo "the executable jar's BOOT-INF/lib: $(wc -l < .harness/lb.txt | tr -d ' ') jars -> $(wc -l < .harness/la.txt | tr -d ' ') · the same names: $(cmp -s .harness/lb.txt .harness/la.txt && echo yes || echo no) · Spring MVC's among them: $(grep '^spring-webmvc-' .harness/la.txt | paste -sd' ' -)"; }

# ---- cookie: the seven; what makes a session ---------------------------------------------------------------------------------------
moved() { python3 - "$1" "$2" <<'PY'
import sys
a = open(sys.argv[1]).read().splitlines(); b = open(sys.argv[2]).read().splitlines()
assert len(a) == len(b) == 7, (len(a), len(b))
d = [i for i in range(7) if a[i] != b[i]]; s = [i for i in range(7) if a[i] == b[i]]
print("  lines that differ: %d%s · the same, byte for byte: %d (%s)" % (len(d), (" (" + " ".join(str(i + 1) for i in d) + ")") if d else "", len(s), " ".join(str(i + 1) for i in s)))
for i in d:
    print("    line %d, the previous tree: %s" % (i + 1, a[i])); print("    line %d, after/:            %s" % (i + 1, b[i]))
PY
}
cookie() { local FPAGE Q_=/customers/new; FPAGE=${L_PAGE/\/dashboard/$Q_}
  echo "the seven - the previous tree, the README's run line, port 19531, a fresh JVM:"
  start "$(at .harness/before 19531 "$R_RUN")"; up 19531; ready 19531; seven 19531 .harness/before; cp .harness/responses.m.txt .harness/seven-before.txt; WARNS; logl 0 WARN
  echo "the seven - after/, the README's run line, port 19530, a fresh JVM:"
  start "$(at .harness/after 19530 "$R_RUN")"; up 19530; ready 19530; seven 19530 .harness/after; cp .harness/responses.m.txt .harness/seven-after.txt; WARNS; logl 0 WARN
  echo "the lines that moved - the previous tree's seven against after/'s, masked, line for line:"
  moved .harness/seven-before.txt .harness/seven-after.txt
  echo "the seven once more - after/, the harness line (Dump, Sessions and Visits joined), port 19530, a fresh JVM:"
  start "$(at .harness/after 19530 "$L_V")"; up 19530; ready 19530; seven 19530 .harness/after
  echo "  the same seven as the README's run line's, byte for byte: $(cmp -s .harness/responses.m.txt .harness/seven-after.txt && echo yes || echo no)"
  srec 0; WARNS
  echo "what makes a session - the previous tree, the harness line, port 19531:"
  start "$(at .harness/before 19531 "$L_V")"; up 19531; ready 19531
  echo "the form's POST (curl's --data: Content-Type application/x-www-form-urlencoded, a form's own type) - this unit's line:"
  rqs "$(u 19531 "$L_POST")"; ids
  echo "the harness's Visits, no cookie sent:"
  rqs "$(u 19531 "$L_VIS")"
  WARNS; stop 19531 .harness/before
  echo "what makes a session - after/, the harness line, port 19530:"
  start "$(at .harness/after 19530 "$L_V")"; up 19530; ready 19530
  echo "the customers, the dashboard page and the form page - no cookie sent:"
  rqs "$(u 19530 "$L_GET")"; rqs "$(u 19530 "$L_PAGE")"; rqs "$(u 19530 "$FPAGE")"
  echo "the form's POST - this unit's line:"
  rqs "$(u 19530 "$L_POST")"; ids
  echo "the harness's Visits, no cookie sent:"
  rqs "$(u 19530 "$L_VIS")"
  echo "the harness's Visits twice with curl's cookie jar - it keeps what Set-Cookie gives and sends it back (this unit's line):"
  run "rm -f .harness/jar"
  rqs "$(u 19530 "$L_VISJ")"; jarf
  rqs "$(u 19530 "$L_VISJ")"; jarf
  WARNS; stop 19530 .harness/after; }

# ---- flash: the note across the redirect ------------------------------------------------------------------------------------------
flash() {
  echo "after/, the README's run line, port 19530 - curl with a cookie jar, as a browser keeps its cookies (this unit's lines):"
  start "$(at .harness/after 19530 "$R_RUN")"; up 19530; ready 19530
  run "rm -f .harness/jar"
  rq "$(u 19530 "$L_POSTJ")"; ids; jarf
  echo "the address it gave - the dashboard, with the jar:"
  rq "$(u 19530 "$L_PAGEJ")"
  echo "the dashboard again, with the jar:"
  rq "$(u 19530 "$L_PAGEJ")"
  echo "without the jar - the same POST for another customer, then the dashboard with no cookie:"
  rq "$(fd "$(u 19530 "$L_POST")" 'name=Om&mealsPerDay=1&pricePerMeal=100&mealType=VEG')"; ids
  rq "$(u 19530 "$L_PAGE")"
  echo "a form the rules refuse, and a JSON POST - no redirect, no note:"
  rq "$(fd "$(u 19530 "$L_POST")" 'name=&mealsPerDay=9&pricePerMeal=0&mealType=X')"
  rq "$(u 19530 "$L_JSON")"
  echo "curl -L follows the redirect - with -X POST it posts again to the address it is given:"
  rq "$(fd "$(u 19530 "$L_LX")" 'name=Asha&mealsPerDay=1&pricePerMeal=100&mealType=VEG')"
  echo "and without -X, with the jar - a GET, as a browser follows a 302:"
  run "rm -f .harness/jar"
  rq "$(fd "$(u 19530 "$L_LJ")" 'name=Dev&mealsPerDay=1&pricePerMeal=100&mealType=VEG')"
  WARNS; stop 19530 .harness/after; }

# ---- tracking: A/B/A' - server.servlet.session.tracking-modes ----------------------------------------------------------------------
# trun 'RUN LINE': the anchor's own form line (its headers whole), then the address it gave, asked for the page twice by a client
# that keeps no cookie
trun() { local c loc
  start "$(at .harness/after 19530 "$1")"; up 19530; ready 19530
  c=$(url "$R_FORM" 19530); echo "\$ $c"; rm -f .harness/head.txt; (eval "$c") > .harness/head.txt 2> /dev/null < /dev/null || true
  hall; ids; loc=$(hv Location)
  echo "  the address it gave, the page asked for by a client that keeps no cookie (this unit's page line, that address):"
  rq "$(lq "$(u 19530 "$L_PAGE")" "$loc")"
  echo "  the same address once more:"
  rq "$(lq "$(u 19530 "$L_PAGE")" "$loc")"
  WARNS; stop 19530 .harness/after; }
tracking() {
  echo "A - after/ as shipped (tracking-modes: cookie), the README's run line, port 19530 - the anchor's own form line:"
  trun "$R_RUN"
  echo "B - Tomcat's default for this run, cookie and url (this unit's line), port 19530:"
  trun "$L_URL"
  echo "A' - A again, a fresh JVM, port 19530:"
  trun "$R_RUN"
  echo "A' against A, its label aside, line for line the same: $(asame 'A - ' 'B - ' "A' - " "A' against A")"; }

# ---- flags: the attributes Course 10 decides -----------------------------------------------------------------------------------------
frun() { start "$(at .harness/after 19532 "$1")"; up 19532; ready 19532; rq "$(u 19532 "$L_VIS")"; WARNS; stop 19532 .harness/after; }
flags() {
  echo "SameSite=Strict - after/, the harness line with one key (this unit's line), port 19532:"; frun "$L_SS"
  echo "Secure - the harness line with one key (this unit's line), port 19532:"; frun "$L_SEC"
  echo "a timeout of 90 seconds - the harness line with one key (this unit's line), port 19532:"; frun "$L_TO"; }

# ---- persistent: C (labelled) - DevTools' session default --------------------------------------------------------------------------
# sfiles: the run's session folder, listed; SESSIONS.ser - Tomcat's file of the sessions it saved when it stopped - searched, never
# printed: the demo token in it, the attribute's name "visits", the session id curl's jar holds
sfiles() { local f=.harness/after/sessions/SESSIONS.ser j
  echo "\$ ls .harness/after/sessions"
  if [ -d .harness/after/sessions ]; then ls .harness/after/sessions | sed 's/^/  /'; else echo "  no such folder"; fi
  if [ -f "$f" ]; then j=$(awk -F '\t' 'NF == 7 && $6 == "JSESSIONID" { print $7 }' .harness/jar 2> /dev/null | tail -1)
    echo "  SESSIONS.ser, searched (never printed): the demo token in it $(raw "$TOKEN" "$f") times · the attribute's name, visits: $( LC_ALL=C grep -aqF visits "$f" && echo yes || echo no) · the session id curl's jar holds: $( [ -n "$j" ] && LC_ALL=C grep -aqF "$j" "$f" && echo yes || echo no)"; fi; }
# prun 'LINE': two visits with curl's jar, POST /shutdown, the session folder; a second JVM on the same line, a third visit
prun() { rm -rf .harness/after/sessions; run "rm -f .harness/jar"
  start "$(at .harness/after 19533 "$1")"; up 19533; ready 19533; settle; hk 0; echo "  listening on 35729 (Live Reload) now: $(listeners 35729)"
  rq "$(u 19533 "$L_VISJ")"; rq "$(u 19533 "$L_VISJ")"
  WARNS; stop 19533 .harness/after; sfiles
  echo "  a second JVM, the same line, port 19533:"
  start "$(at .harness/after 19533 "$1")"; up 19533; ready 19533
  rq "$(u 19533 "$L_VISJ")"
  WARNS; stop 19533 .harness/after; sfiles; rm -rf .harness/after/sessions; }
persistent() { local k
  echo "the keys - Boot's metadata (spring-boot-web-server-4.1.1.jar):"
  for k in server.servlet.session.persistent server.servlet.session.store-dir; do meta .harness/after/tiffinbox-web/target/extracted/lib/spring-boot-web-server-4.1.1.jar "$k"; done
  echo "C (labelled) - DevTools on after/: its extracted jar with DevTools' jar (from \$M2) and the harness on its class path, Live Reload off, Keys and Visits joined, the session folder named in the run's own folder (this unit's line), port 19533:"
  prun "$L_DEVT"
  echo "persistence off for this run (this unit's line), port 19533:"
  prun "$L_DOFF"
  echo "C' - C again, fresh JVMs, port 19533:"
  prun "$L_DEVT"
  echo "C' against C, its label aside, line for line the same: $(asame 'C (labelled) - ' 'persistence off' "C' - " "C' against C")"; }
# ---- exercise: the README's commands, exactly as written, then the solution's - in ONE shell --------------------------------------
block() { awk '/^```bash$/ { if (!d) { f = 1 }; next } f && /^```$/ { f = 0; d = 1 } f' "$1"; }
where() { case "$1" in "$U") echo "this unit's folder" ;; "$U"/*) echo "${1#"$U"/}" ;; *) echo "outside this unit's folder" ;; esac; }
lvl() { grep -cE "^[0-9]{4}-[0-9]{2}-[0-9]{2}T[^ ]+ +$1 " "$2" || true; }
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
  echo "  the shell is now in: $(where "$d1") · the copy's own token in its log: $(raw "$(head -1 .harness/mine/after/$TF)" .harness/ex-readme.log) times · WARN lines in its log: $(lvl WARN .harness/ex-readme.log) · ERROR lines: $(lvl ERROR .harness/ex-readme.log) · listening on 19538 now: $(listeners 19538)"
  echo "the solution's $(printf '%s\n' "$sol" | grep -c .) lines, next, in the same shell:"
  printf '%s\n' "$sol" | sed 's/^/  $ /'
  echo "  exit $e2 · what they printed:"; sed 's/^/    /' .harness/ex-sol.out
  echo "  the shell is now in: $(where "$d2") · the copy's own token in its log: $(raw "$(head -1 .harness/mine/after/$TF)" .harness/mine/run.log) times · WARN lines in its log: $(lvl WARN .harness/mine/run.log) · ERROR lines: $(lvl ERROR .harness/mine/run.log) · listening on 19538 now: $(listeners 19538)"
  echo "  the copy's tiffinbox-local.yaml: $(cat .harness/mine/after/tiffinbox-local.yaml)"; }


# ---- browser: one Chrome per visitor - each claim with two witnesses ----------------------------------------------------------------
cup() { local l i=0 a=""; while [ $i -lt 480 ]; do a=$(addrs "$cpid"); case " $a " in *":19539 "*) break ;; esac; kill -0 "$cpid" 2> /dev/null || break; sleep 0.25; i=$((i + 1)); done
  case " $a " in *":19539 "*) ;; *) die "Chrome never listened on 19539" ;; esac
  l=$(printf '%s\n' "$a" | tr ' ' '\n' | grep ':19539$' | paste -sd' ' -); echo "  Chrome's DevTools port: $l · loopback only: $(lb "$l")"; }
chrome() { local f; [ -e .harness/chrome ] && f=no || f=yes; rm -f .harness/netlog.json
  echo "\$ $L_CHROME"; (eval "exec $L_CHROME") > .harness/chrome.out 2>&1 < /dev/null & cpid=$!
  echo "  its profile, .harness/chrome, made fresh for this visitor (it did not exist before this line): $f"; cup; }
unchrome() { local i=0 e=0; echo "\$ $L_CLOSE"; (eval "$L_CLOSE") > .harness/close.out 2>&1 < /dev/null || true
  while kill -0 "$cpid" 2> /dev/null && [ $i -lt 60 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$cpid" 2> /dev/null && { killtree "$cpid"; die "Chrome still ran 15 s after Browser.close"; }
  wait "$cpid" || e=$?; cpid=""; [ "$(listeners 19539)" = 0 ] || die "something still listens on 19539"
  rm -rf .harness/chrome; echo "  Chrome exit $e · listening on 19539 now: 0 · its profile removed"
  echo "\$ $(nlq "$@")"; (eval "$(nlq "$@")") 2>&1 < /dev/null || true; }
# visit 'CDP LINE': the line printed and run - the page Chrome shows; Chrome's own record of the visit's documents (net.py); then
# the server's record: every harness line the requests printed (Dump, Sessions), and the WARN and ERROR lines they added
visit() { local n0 w e; n0=$(mark); rm -f .harness/ev.json; echo "\$ $1"; (eval "$1") 2>&1 < /dev/null | sed 's/^/  /'
  echo "\$ ${L_NET/ 18431/ 19537}"; (eval "${L_NET/ 18431/ 19537}") 2>&1 < /dev/null; settle
  w=$(logl "$n0" WARN | grep -c . || true); e=$(logl "$n0" ERROR | grep -c . || true)
  echo "  the server's record:"; hk "$n0" | sed 's/^/  /'; echo "    WARN lines they added: $w · ERROR lines: $e"; }
# cook: Chrome's cookie store (cdp.mjs cookies), and - compared before any mask - whether the session id Chrome keeps is the one
# the server's record shows it set last (Dump's Set-Cookie), the one Chrome sent back last (Dump's Cookie), and the one the last
# redirect's Location carried (Dump's Location; none: no id there)
cook() { local a b c l
  echo "\$ $L_COOK"; (eval "$L_COOK") > .harness/cook.txt 2>&1 < /dev/null || true; sed 's/^/  /' .harness/cook.txt
  a=$(sed -n 's/^  JSESSIONID=\([0-9A-F]*\) .*/\1/p' .harness/cook.txt | tail -1)
  b=$(sed -n 's/^HOOK [0-9]* Dump  *<   Set-Cookie: JSESSIONID=\([0-9A-F]*\);.*/\1/p' .harness/run.out | tail -1)
  c=$(sed -n 's/^HOOK [0-9]* Dump  *>   [Cc]ookie: JSESSIONID=\([0-9A-F]*\)$/\1/p' .harness/run.out | tail -1)
  l=$(sed -n 's/^HOOK [0-9]* Dump  *<   Location: .*;jsessionid=\([0-9A-F]*\)$/\1/p' .harness/run.out | tail -1)
  echo "  compared: the id Chrome keeps is the one the server's record shows set: $( [ -n "$a" ] && [ "$a" = "$b" ] && echo yes || echo no) · the one Chrome sent back last: $( [ -n "$a" ] && [ "$a" = "$c" ] && echo yes || echo no) · a redirect's Location in the server's record carried an id: $( [ -n "$l" ] && echo yes || echo no)$( [ -n "$l" ] && echo " · the same id: $( [ "$l" = "$a" ] && echo yes || echo no)")"; }
# serve 'LINE' WHAT: TiffinBox (after/) on 19537, the harness's classes on its class path
serve() { echo "  TiffinBox - $2, port 19537:"; start "$(at .harness/after 19537 "$1")"; up 19537; ready 19537; }
browser() {
  echo "1 after/ - the harness line (Dump, Sessions and Visits joined: the server's record of every request, whole); Chrome headless, a profile of its own, sealed to 127.0.0.1 (its proxy a dead address, every name but 127.0.0.1 unresolvable), its DevTools protocol on 127.0.0.1:19539:"
  serve "$L_V" "after/, the harness line"; chrome
  echo "visit 1 - the dashboard's address, typed into a new tab:"; visit "$(u 19537 "$L_OPEN")"
  echo "visit 2 - the form's address, typed into a new tab; the form filled in and sent with its own button:"; visit "$(u 19537 "$L_FORM")"
  echo "the cookie store, after visit 2:"; cook
  echo "visit 3 - the dashboard's address, typed into a new tab again:"; visit "$(u 19537 "$L_OPEN")"
  unchrome 19537; WARNS; stop 19537 .harness/after
  echo "C (labelled) - Tomcat's default, cookie and url (this unit's line), a new visitor whose first request to make a session is the form's POST:"
  serve "$L_VURL" "after/, cookie and url"; chrome
  echo "visit 1 - the form's address, typed into a new tab; the form filled in and sent with its own button:"; visit "$(u 19537 "$L_FORM")"
  echo "the cookie store, after visit 1:"; cook
  unchrome 19537; WARNS; stop 19537 .harness/after
  echo "F (labelled) - Secure and SameSite=Strict, the attributes Course 10 decides (this unit's line), a new visitor over plain http to 127.0.0.1:"
  serve "$L_VF" "after/, Secure and SameSite=Strict"; chrome
  echo "visit 1 - the form's address, typed into a new tab; the form filled in and sent with its own button:"; visit "$(u 19537 "$L_FORM")"
  echo "the cookie store, after visit 1:"; cook
  unchrome 19537; WARNS; stop 19537 .harness/after; }
# ---- forms: the native build, what Spring's AOT step registered, then four forms ---------------------------------------------------
nbuild() { local ci cn s0 s1
  ci=$(off "$1" "$R_INSTALL" install); cn=$(off "$1" "$R_NATIVE")
  echo "\$ $ci"; mbuild "$ci" "$1.install.log" "$1 (both modules, into \$M2)"
  echo "\$ $cn"
  NB_E=0; s0=$(date +%s); (eval "$cn") > "$1.native.log" 2>&1 < /dev/null || NB_E=$?; s1=$(date +%s); NB_S=$((s1 - s0)); NB_T0=$s0; NB_T1=$s1
  echo "  (terminal only) the native build in $1 took $NB_S s - $( [ $NB_S -lt 1200 ] && echo under || echo OVER ) the 20-minute bound" >&3
  [ $NB_S -lt 1200 ] || die "the native build took over 20 minutes"
  if ghub "$1.native.log"; then echo "  offline: no - GraalVM's native plugin went to GitHub for its metadata repository"; die "the native build in $1: GraalVM's native plugin went over the network - README.md, The repository"; fi; }
nlines() {
  echo "  its lines, in order (the rest - $(grep -cvE '^\[INFO\] --- |^\[INFO\] Found GraalVM|^ - Java version: |^Warning: |^\[[1-8]/8\] |^\[INFO\] BUILD |^The build process encountered ' "$1" || true) lines - not shown):"
  grep -E '^\[INFO\] --- .* @ tiffinbox-web ---$|^\[INFO\] Found GraalVM installation from ' "$1" | sed 's/^\[INFO\] /    /'
  grep -E '^ - Java version: ' "$1" | sed 's/^ - /    /'
  grep -E '^Warning: ' "$1" | sed -E "s/ in '(file:[^']*|null)'/ in '…'/" | sed 's/^/    /'
  grep -E '^\[[1-8]/8\] ' "$1" | sed 's/\.\.\..*$/.../' | sed 's/^/    /'
  grep -E '^The build process encountered |^\[INFO\] BUILD ' "$1" | sed 's/^\[INFO\] //' | sed 's/^/    /'; }
nresult() { echo "  exit $NB_E · $(grep -m1 -oE 'BUILD (SUCCESS|FAILURE)' "$1" || echo 'no BUILD line') · stages it printed: $(grep -cE '^\[[1-8]/8\] ' "$1" || true) of the $(grep -m1 -oE '^\[1/[0-9]+\]' "$1" | sed 's/.*\///; s/]//') it announces · its lines that say the metadata repository was downloaded over http, or failed to: $(grep -cE 'Downloaded GraalVM reachability metadata repository from http|Failed to download from http' "$1" || true) · offline: yes"; }
AOTF=tiffinbox-web/target/spring-aot/main/resources/META-INF/native-image/com.tiffinbox/tiffinbox-web/reachability-metadata.json
aotcmp() { python3 - "$1/$AOTF" "$2/$AOTF" <<'PY'
import json, sys
a, b = (json.load(open(p)) for p in sys.argv[1:3])
ra, rb = a.get("reflection", []), b.get("reflection", [])
def key(e): return json.dumps(e.get("type"), sort_keys=True)
A = {key(e): e for e in ra}; B = {key(e): e for e in rb}
only_a = sorted(t for t in A if t not in B); only_b = sorted(t for t in B if t not in A)
ch = sorted(t for t in A if t in B and json.dumps(A[t], sort_keys=True) != json.dumps(B[t], sort_keys=True))
print("  Spring's generated metadata (%s) - the previous tree's against after/'s: reflection entries %d -> %d · types only the previous tree registers: %s · only after/: %d · entries that differ: %d" % (sys.argv[1].split("/target/", 1)[1], len(ra), len(rb), ", ".join(json.loads(t) for t in only_a) or "none", len(only_b), len(ch)))
def sig(m): return "%s(%s)" % (m["name"], ", ".join(x.rsplit(".", 1)[-1] for x in m.get("parameterTypes", [])))
def what(e):
    k = [x for x in sorted(e) if x not in ("type", "methods")]
    ms = e.get("methods", [])
    return " · ".join(k + ["%d method%s" % (len(ms), "" if len(ms) == 1 else "s")])
def named(t): return "tiffinbox" in t or "Flash" in t or "Redirect" in t or "Session" in t
for t in only_b:
    if named(t): print("    only after/: %s - %s" % (json.loads(t), what(B[t])))
print("    only after/, the rest: %d (not named)" % sum(1 for t in only_b if not named(t)))
for t in ch:
    ma = sorted(sig(m) for m in A[t].get("methods", [])); mb = sorted(sig(m) for m in B[t].get("methods", []))
    other = {k: v for k, v in A[t].items() if k != "methods"} != {k: v for k, v in B[t].items() if k != "methods"}
    ka = {k for k in A[t] if k not in ("type", "methods")}; kb = {k for k in B[t] if k not in ("type", "methods")}
    print("    differs: %s - its methods only before: %s · only after: %s · its other keys only before: %s · only after: %s" % (json.loads(t), " ".join(m for m in ma if m not in mb) or "none", " ".join(m for m in mb if m not in ma) or "none", " ".join(sorted(ka - kb)) or "none", " ".join(sorted(kb - ka)) or "none"))
def res(d): return sorted(json.dumps(x, sort_keys=True) for x in d.get("resources", []))
na = res(a); nb = res(b)
print("  resource entries: %d -> %d · only after/: %s" % (len(na), len(nb), " ".join(json.loads(x).get("glob", x) for x in nb if x not in na) or "none"))
PY
}
lbk() { awk -v a="$1" 'index($0, a) == 1 { f = 1; next } /^[1-4] the / { f = 0 } f' .harness/cap.raw > .harness/blk.txt
  if [ "$1" = '4 the image' ]; then [ "$(grep -c '^  docker port: ' .harness/blk.txt)" = 3 ] && [ "$(grep -cE '^  docker port: 18425/tcp -> 127\.0\.0\.1:19534$' .harness/blk.txt)" = 3 ] && echo yes || echo no
  else [ "$(grep -c '^  listens on: ' .harness/blk.txt)" -gt 0 ] && [ "$(grep -c '^  listens on: ' .harness/blk.txt)" = "$(grep -cE '^  listens on: 127\.0\.0\.1:[0-9]+ · loopback only: yes$' .harness/blk.txt)" ] && echo yes || echo no; fi; }
blines() { local s
  s=$(grep -E '^#[0-9]+ \[internal\] load metadata for |^#[0-9]+ \[[a-z0-9-]+ 1/[0-9]+\] FROM |^#[0-9]+ naming to ' "$1" | sed -E 's/^#[0-9]+ //; s/( [0-9]+\.[0-9]+s)? done$//' | awk '!seen[$0]++')
  printf '%s\n' "$s" | sed 's/^/    /'
  echo "  its lines that say pull: $(grep -ci 'pull' "$1" || true) · its other lines: $( [ "$(wc -l < "$1" | tr -d ' ')" -lt 300 ] && echo 'fewer than 300' || echo '300 or more'), not shown"; }
printf '%s\n' '#14 naming to docker.io/library/planted:1 done' '#14 naming to docker.io/library/planted:1 0.0s done' '#15 naming to docker.io/library/planted:1 0.1s done' > .harness/planted-dbuild.log
PL=$(blines .harness/planted-dbuild.log)
[ "$(printf '%s\n' "$PL" | grep -c 'naming to')" = 1 ] && printf '%s\n' "$PL" | grep -qxF '    naming to docker.io/library/planted:1' || die "blines: a timing survives the filter (the planted log .harness/planted-dbuild.log)"
rm -f .harness/planted-dbuild.log
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
# froutes PORT: on a second start of a form - the form's first POST with curl's cookie jar (this unit's line), then the dashboard
# twice with that jar; a summary line read off what they printed. No log counted (a container's log is read only when it has stopped)
froutes() { local st ad hc n1 n2
  run "rm -f .harness/jar"
  rq "$(u "$1" "$L_POSTJ")" nolog; ids; st=$(sed 's/^ *//; s/ .*//' .harness/curl.txt); ad=$(lid); hc=$(hv Set-Cookie)
  rq "$(u "$1" "$L_PAGEJ")" nolog; n1=$(grep -c 'class="note"' .harness/body.html 2> /dev/null || true); n1="$n1 ($(sed -n 's/.*<p class="note">\([^<]*\)<.*/\1/p' .harness/body.html 2> /dev/null | paste -sd'|' -))"
  rq "$(u "$1" "$L_PAGEJ")" nolog; n2=$(grep -c 'class="note"' .harness/body.html 2> /dev/null || true)
  echo "  this form's answers: the POST $st · a session id in its address: $( [ "$ad" = none ] && echo no || echo yes) · its cookie: $(printf '%s\n' "$hc" | sed 's/JSESSIONID=[0-9A-F]*/JSESSIONID=<id>/') · notes on the first page: $n1 · on the second: $n2"; }
# fb PORT: on a third start, with Tomcat's default (cookie and url): the form's POST without a jar, and where its id went
fb() { local st; rq "$(u "$1" "$L_POST")" nolog; ids; st=$(sed 's/^ *//; s/ .*//' .harness/curl.txt)
  echo "  this form's answer with cookie and url: the POST $st · a session id in its address: $( [ "$(lid)" = none ] && echo no || echo yes) · the cookie's: $( [ "$(lid)" != none ] && [ "$(lid)" = "$(sid)" ] && echo yes || echo no)"; }
dseven() { echo "\$ \$CURLSET $1 .harness/after/$TF"
  "$CURLSET" "$1" ".harness/after/$TF" | grep ' -> ' > .harness/responses.txt || true
  tsmask < .harness/responses.txt > .harness/responses.m.txt
  grep '^POST ' .harness/responses.m.txt | sed 's/^/  /' || echo "  (no POST line)"
  dgone "$BOX"; [ "$(listeners "$1")" = 0 ] || die "something still listens on $1"
  echo "  exit $LASTE · the seven responses: $(wc -l < .harness/responses.m.txt | tr -d ' ') lines · lines the timestamp mask changed: $(diff .harness/responses.txt .harness/responses.m.txt | grep -c '^<' || true) · md5 $(md5 -q .harness/responses.m.txt)"
  dlog "$BOX"; echo "  its log (docker logs): Boot's first line: $(first .harness/run.out) · the demo token 0 times · X-Shutdown-Token 0 times"
  docker rm "$BOX" > /dev/null; }
S466='466c20ed7e0d5439cb052f32ce09de1b'
# dthen 'DOCKER RUN LINE' WHAT FN: a further container of the image - started, ready, its addresses; FN 19534; stopped; its log read
dthen() { echo "  then $2 - TiffinBox listens on 18425 inside it:"
  dstart "$1"; ready 19534 "$BOX"; dbind 19534
  $3 19534
  post 19534 .harness/after; dgone "$BOX"; [ "$(listeners 19534)" = 0 ] || die "something still listens on 19534"
  dlog "$BOX"; echo "  exit $LASTE · its log (docker logs): the demo token 0 times · X-Shutdown-Token 0 times · WARN lines: $(lvl WARN .harness/run.out) · ERROR lines: $(lvl ERROR .harness/run.out)"
  docker rm "$BOX" > /dev/null; }
forms() { local v
  echo "the native build - after/ copied to .harness/nat with a config tree; the README's two Maven lines, offline; \$GRAALVM_HOME names the GraalVM:"
  copy after .harness/nat
  nbuild .harness/nat; nlines .harness/nat.native.log; nresult .harness/nat.native.log
  echo "  file: $(file -b ".harness/nat/$BIN" | sed 's/ [A-Za-z0-9_]*$//') · the demo token in its bytes: $(raw "$TOKEN" ".harness/nat/$BIN")"
  echo "what Spring's AOT step registered - the previous tree built with the README's native-profile line too (.harness/natb), then its metadata against after/'s:"
  copy "$PREV" .harness/natb; pbuild .harness/natb "the previous tree, the profile native" "$R_PNAT"
  aotcmp .harness/natb .harness/nat
  echo "1 the jar - .harness/after, the README's run line, port 19530:"
  start "$(at .harness/after 19530 "$R_RUN")"; up 19530; ready 19530; tline; seven 19530 .harness/after
  echo "  then the form, on a second start of the jar:"
  start "$(at .harness/after 19530 "$R_RUN")"; up 19530; ready 19530; froutes 19530; stop 19530 .harness/after
  echo "  then Tomcat's default, on a third start (this unit's line):"
  start "$(at .harness/after 19530 "$L_URL")"; up 19530; ready 19530; fb 19530; stop 19530 .harness/after
  echo "2 the AOT jar - .harness/nat (the profile native's jar), the README's AOT line, port 19535:"
  start "$(at .harness/nat 19535 "$R_AOTRUN")"; up 19535; ready 19535; tline; seven 19535 .harness/nat
  echo "  then the form, on a second start of the AOT jar:"
  start "$(at .harness/nat 19535 "$R_AOTRUN")"; up 19535; ready 19535; froutes 19535; stop 19535 .harness/nat
  echo "  then Tomcat's default, on a third start (the README's AOT line and B's option):"
  start "$(at .harness/nat 19535 "$R_AOTRUN $O_URL")"; up 19535; ready 19535; fb 19535; stop 19535 .harness/nat
  echo "3 the binary - .harness/nat, the README's line, port 19536:"
  start "$(at .harness/nat 19536 "$R_BIN")"; up 19536; ready 19536; tline; seven 19536 .harness/nat
  echo "  then the form, on a second start of the binary:"
  start "$(at .harness/nat 19536 "$R_BIN")"; up 19536; ready 19536; froutes 19536; stop 19536 .harness/nat
  echo "  then Tomcat's default, on a third start (the README's line and B's option):"
  start "$(at .harness/nat 19536 "$R_BIN $O_URL")"; up 19536; ready 19536; fb 19536; stop 19536 .harness/nat
  echo "4 the image - after/'s Dockerfile (the README's build line, this script's tag), the README's run line with your user, published on 127.0.0.1:19534:"
  image
  dstart "$(drun .harness/after 19534)"; ready 19534 "$BOX"; dbind 19534
  dseven 19534
  dthen "$(drun .harness/after 19534)" "the form, on a second container of the image" froutes
  dthen "$(drun .harness/after 19534 "$O_URL")" "Tomcat's default, on a third container (the README's run line and B's option, after the image's name)" fb
  echo "four forms, one tree: the seven (masked) $(grep -cE "^  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 0 · md5 $S466\$" .harness/cap.raw) of 4 times $S466 · the form's POST 302, no session id in its address, the cookie HttpOnly, the note once: $(grep -cE "^  this form's answers: the POST 302 · a session id in its address: no · its cookie: JSESSIONID=<id>; Path=/; HttpOnly · notes on the first page: 1 \(Lata added\) · on the second: 0\$" .harness/cap.raw) of 4 · with cookie and url, the session id in the address, the cookie's: $(grep -cxF "  this form's answer with cookie and url: the POST 302 · a session id in its address: yes · the cookie's: yes" .harness/cap.raw) of 4"
  echo "  loopback, form by form: the jar $(lbk '1 the jar') · the AOT jar $(lbk '2 the AOT jar') · the binary $(lbk '3 the binary') · the image, published on 127.0.0.1 alone $(lbk '4 the image')"
  echo "  the locale: options on the binary's and the image's run lines: $(printf '%s\n%s\n' "$(at .harness/nat 19536 "$R_BIN")" "$(drun .harness/after 19534)" | grep -o 'user\.language\|user\.country' | wc -l | tr -d ' ') (none passed: the binary runs as the README writes it, the image as its ENTRYPOINT, java -jar)"; }

cap change change
cap cookie cookie
cap flash flash
cap tracking tracking
cap flags flags
cap persistent persistent
cap exercise exercise
if [ $BROWSER = yes ]; then cap browser browser
else echo "  *** the browser step: $WHYNOT - every curl capture is made and checked; the browser capture needs Chrome and node 22 or later (README.md, \"The browser\") ***"; exit 2; fi
[ $GOK = yes ] || die "GRAALVM_HOME is not set: .m2-demo is filled, and the captures that need no GraalVM matched receipts.md5; the native build needs a GraalVM JDK 25 - README.md, The GraalVM"
cap forms forms
echo
# ---- every number the video says, asserted. Each check reads a line a program computed - never a label this script prints
# ---- unconditionally - and names the words it pays for.
x() { grep -qE -- "$2" ".r-$1.out" || die "$1: expected /$2/"; }
n() { grep -cE -- "$2" ".r-$1.out" || true; }
blk() { awk -v a="$2" -v b="$3" 'index($0, a) == 1 { f = 1; next } b != "" && index($0, b) == 1 { f = 0 } f' ".r-$1.out"; }
has() { printf '%s\n' "$1" | grep -qxF -- "$2" || die "$3: expected the line: $2"; }
nhas() { ! printf '%s\n' "$1" | grep -qF -- "$2" || die "$3: did not expect: $2"; }
cnt() { printf '%s\n' "$1" | grep -cxF -- "$2" || true; }
# seg BLOCK 'COMMAND': the lines a command printed in BLOCK - from the line after "$ COMMAND" up to the next "$ " line or label line (or a
# run's WARN count); segn N BLOCK 'COMMAND': the same for the command's Nth run in BLOCK
seg() { printf '%s\n' "$1" | C="\$ $2" awk 'f && (/^\$ / || /^[A-Za-z]/ || /^  WARN lines in this run/) { exit } f { print } $0 == ENVIRON["C"] { f = 1 }'; }
segn() { printf '%s\n' "$2" | C="\$ $3" N="$1" awk 'f && (/^\$ / || /^[A-Za-z]/ || /^  WARN lines in this run/) { exit } f { print } $0 == ENVIRON["C"] && ++k == ENVIRON["N"] { f = 1 }'; }
# THE TOKEN: no capture holds it, raw - counted on each run's own output BEFORE masking - and neither does any log, any file this unit
# ships for reading, nor the binary this run built
for f in .harness/raw-*; do [ "$(cat "$f")" = "0" ] || die "a capture's raw output held the token ($f: $(cat "$f"))"; done
SHIP="README.md exercise/README.md exercise/solution/SOLUTION.md receipts.md5 harness/shutdown.sh harness/cdp.mjs harness/net.py harness/netlog.py $HWS"
NBIN=0
for f in .r-*.out $SHIP .harness/nat/$BIN; do [ -f "$f" ] || continue; case $f in .harness/nat*) NBIN=$((NBIN + 1)) ;; esac; [ "$(raw "$TOKEN" "$f")" = 0 ] || die "$f holds the demo token, raw"; done
[ "$NBIN" = 1 ] || die "one binary was built, $NBIN were checked"
# no capture prints a date, and none prints a session's id: no run of 32 capital hex digits, no JSESSIONID= or jsessionid= but <id>
for f in .r-*.out; do ! grep -qE '/Users/|/private/|/home/|/var/folders/' "$f" || die "$f holds an absolute path"; [ -z "${GRAALVM_HOME:-}" ] || ! grep -qF "$GRAALVM_HOME" "$f" || die "$f holds the GraalVM's folder"; ! grep -qE 'c[0-9]-unit[0-9]|unit ?[0-9]' "$f" || die "$f holds a unit number"; ! grep -qE ' (with PID|started by) ' "$f" || die "$f holds Boot's process line"; ! grep -qE '^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T|"timestamp":"?[0-9]|(exec|handler|task|utility)-[0-9]|GMT|CES?T|<div id=.created|[A-Z][a-z][a-z], [0-9][0-9] [A-Z][a-z][a-z] |[A-Z][a-z][a-z] [A-Z][a-z][a-z] [0-9]+ [0-9][0-9]:[0-9][0-9]|[0-9][0-9]-[0-9][0-9]-20[0-9][0-9]' "$f" || die "$f holds a log line's time, a timestamp, a date or a thread's number"; ! grep -q "^$(printf '\t')at " "$f" || die "$f shows a stack frame"; ! grep -qE 'SpringCGLIB\$\$[0-9]' "$f" || die "$f holds a generated class's number"; ! grep -qE 'sha256:[0-9a-f]{64}' "$f" || [ "$(grep -cE 'sha256:[0-9a-f]{64}' "$f")" = "$(grep -cE 'eclipse-temurin(:25-jre)?@sha256:[0-9a-f]{64}' "$f")" ] || die "$f holds an ID other than the base image's digest"; ! grep -qE ':(8080|35729)([^0-9]|$)' "$f" || die "$f shows a bind on 8080 or 35729"; ! grep -q $'\r' "$f" || die "$f holds a carriage return"; ! grep -qiE '<html|<!doctype' "$f" || die "$f shows an HTML page whole"; ! grep -qE 'Chrome/[0-9]|v="[0-9]' "$f" || die "$f holds Chrome's version"; ! grep -qE '[0-9A-F]{32}' "$f" || die "$f holds a session id (32 capital hex digits)"; ! grep -qE '(JSESSIONID|jsessionid)=[0-9A-Fa-f]' "$f" || die "$f holds a session id after JSESSIONID= or jsessionid="; done
for f in receipts.sh README.md exercise/README.md exercise/solution/SOLUTION.md $HWS; do ! grep -qE "exposure\.include='?\*" "$f" || die "$f exposes every endpoint (R.42)"; done
K3='server'; K3="$K3.error."
for f in receipts.sh README.md exercise/README.md exercise/solution/SOLUTION.md $HWS; do ! grep -qF "$K3" "$f" || die "$f names one of Boot 3's error keys (S3.21)"; done
! grep -rqF "$K3" after || die "after/ names one of Boot 3's error keys (S3.21)"
! grep -rq 'probe\.web' after/tiffinbox-web after/tiffinbox-core || die "after/'s code names the course's harness - it is never TiffinBox's"
for f in receipts.sh README.md exercise/README.md exercise/solution/SOLUTION.md; do ! grep -E 'docker run ' "$f" | grep -vE '^#' | grep -E ' -p "?[0-9]+:' > /dev/null || die "$f publishes a port on every address (-p without 127.0.0.1:)"; done
for f in receipts.sh exercise/README.md exercise/solution/SOLUTION.md; do ! grep -nE '(^|[;&|({] *)wait *($|[;&|)}])' "$f" | grep -vE '^[0-9]+: *#' > /dev/null || die "$f has a bare wait (S3.9)"; done
for f in .r-*.out; do ! grep -E '^\$ ' "$f" | grep -oE 'https?://[^ '"'"']+' | grep -vE '^http://127\.0\.0\.1:' > /dev/null || die "$f runs a command with a URL that is not 127.0.0.1's"; done
for f in .r-*.out; do ! grep -E '^\$ (cd [^ ]+ && )?(exec )?java ' "$f" | grep -vF -- "java $JL " | grep -vF -- 'java -Djarmode=tools ' > /dev/null || die "$f starts a JVM without its locale pinned (S4.1)"; done
K1='pki''ll'; K2='kill''all'; for f in receipts.sh harness/cdp.mjs harness/net.py harness/netlog.py; do ! grep -v '^ *#' "$f" | grep -qwE "$K1|$K2" || die "$f names $K1 or $K2 - Chrome is stopped by its pid (S4.9)"; done
case "$L_CHROME" in *' --user-data-dir="$PWD/.harness/chrome" '*'--proxy-server=http://127.0.0.1:9 '*"--host-resolver-rules='MAP * ~NOTFOUND, EXCLUDE 127.0.0.1'"*'--remote-debugging-address=127.0.0.1 '*) ;; *) die "Chrome's line must name this unit's profile, the dead proxy, the resolver seal and a loopback DevTools address" ;; esac
NL=$(cat .r-*.out | grep -cE "^  its log: the demo token 0 times · X-Shutdown-Token 0 times\$" || true)
echo "  tokens: 0 raw copies in $(ls .harness/raw-* | wc -l | tr -d ' ') raw capture runs, in $(ls .r-*.out | wc -l | tr -d ' ') captures; the demo token 0 in the logs of every JVM that served ($LOGS here; the published captures' $NL) and every container ($CLOGS here), the image's layers, every session file a run wrote, the READMEs, the harness, the exercise, receipts.md5 and the binary; no absolute path, no GraalVM folder, no unit number, no process line, no log time, no timestamp, no date, no session id, no thread number, no stack frame, no whole HTML page, no Chrome version, no 8080 or 35729, no carriage return in any capture; no Boot 3 error key; no harness class in the anchor; no bare wait; no stop by name; every java line's locale pinned; every docker run publishes on 127.0.0.1 alone; every URL a capture runs is 127.0.0.1's"


Z00=' · WARN lines it added: 0 · ERROR lines: 0'
NOF='  body: none (0 bytes)'
# PG TITLE LINES BYTES NOTES COLUMN LINKS: the page line pagef prints
PG() { printf '%s\n' "  the page: <title>$1 · TiffinBox</title> · $2 lines, $3 bytes - not shown but · its notes: $4 · its table's first column: $5 · its links that carry a session id: $6"; }
COL4='Meera Priya Ravi Sunil'; COL5='Lata Meera Priya Ravi Sunil'
VJ() { printf '%s\n' "  body: {\"visits\":$1,\"new\":$2,\"maxInactiveSeconds\":$3,\"trackingModes\":[$4],\"defaultTrackingModes\":[\"COOKIE\",\"URL\"]}"; }
CK='Set-Cookie: JSESSIONID=<id>; Path=/; HttpOnly'
R302() { printf '%s\n' "  HTTP/1.1 302 · $CK · Location: http://127.0.0.1:$1/dashboard$2 · Content-Language: en-US · Content-Length: 0 · Date: (the time - not printed)"; }
REC() { printf '%s\n' "  the server's record since: requests Dump printed $1 · Set-Cookie headers among their answers $2 · sessions Tomcat created (Sessions) $3"; }
IDS() { printf '%s\n' "  the session id in its Set-Cookie: $1 · in its Location: $2 · the same id: $3"; }

# "Three files changed: the flash in the controller, the note in the template, one key above the first dashes"
CO=$(cat .r-change.out)
for l in '  built the previous tree · offline: yes · exit 0' '  built after/ · offline: yes · exit 0' \
         "  after/'s files: 33 · byte for byte the previous tree's: 29 · new: 0 · those that differ: 4" \
         '  tiffinbox-web/src/main/java/com/tiffinbox/web/DashboardPage.java: 100 lines -> 107' '  tiffinbox-web/src/main/resources/templates/dashboard.html: 15 lines -> 16' '  tiffinbox-web/src/main/resources/application.yaml: 122 lines -> 128' \
         '    +        flash.addFlashAttribute("added", customer.name());' '    +import org.springframework.web.servlet.mvc.support.RedirectAttributes;' \
         "    +  <p class=\"note\" th:if=\"\${added != null}\" th:text=\"\${added} + ' added'\">x added</p>" '    @@ -21,0 +22,6 @@' '    +      tracking-modes: cookie' \
         '    server: line 19 · servlet: line 25 · session: line 26 · tracking-modes: line 27 · the first ---: line 121 · lines in the first document at the first column that say server: 1' \
         '  server.servlet.session.tracking-modes - type Session$SessionTrackingMode> · default null · Session tracking modes.' \
         '  server.servlet.session.timeout - type Duration · default "30m" · Session timeout. If a duration suffix is not specified, seconds will be used.' \
         '  server.servlet.session.persistent - type Boolean · default false · Whether to persist session data between restarts.' \
         "the executable jar's BOOT-INF/lib: 61 jars -> 61 · the same names: yes · Spring MVC's among them: spring-webmvc-7.0.9.jar"; do has "$CO" "$l" "change"; done
[ "$(n change '^  Files ')" = 4 ] && [ "$(n change '^  Only in ')" = 0 ] && [ "$(n change '^    \+')" = 16 ] && [ "$(n change '^    -')" = 2 ] || die "change: four files differ (the README, the controller, the template, application.yaml); 16 lines in, 2 out (the controller's comment line and its signature)"
[ "$(cnt "$CO" '  its diff (diff -U0, its file names cut) - hunks: 1 · lines out: 0 · in: 6 - whole:')" = 1 ] && [ "$(cnt "$CO" '  its diff (diff -U0, its file names cut) - hunks: 4 · lines out: 2 · in: 9 - whole:')" = 1 ] && [ "$(cnt "$CO" '  its diff (diff -U0, its file names cut) - hunks: 1 · lines out: 0 · in: 1 - whole:')" = 1 ] || die "change: the three diffs' sizes"
WL=$(printf '%s\n' "$CO" | grep '^    server: line ') || die "change: the key's lines"
set -- $(printf '%s\n' "$WL" | grep -oE 'line [0-9]+' | awk '{ print $2 }'); [ $# = 5 ] && [ "$1" -lt "$2" ] && [ "$2" -lt "$3" ] && [ "$3" -lt "$4" ] && [ "$4" -lt "$5" ] || die "change: the key must sit under server:, in the first document (R.87)"
echo "  change: DashboardPage +9/-2 (RedirectAttributes, addFlashAttribute), dashboard.html +1 (the note), application.yaml +6 (tracking-modes: cookie at line 27 under server: at 19, above the first --- at 121); 29 of 33 files byte for byte; Boot's metadata: tracking-modes no default, timeout 30m, persistent false; 61 libraries, the same"

# "The seven set no cookie and stay the same ... what makes a session: the form's POST, now ... HttpOnly ... new, then not new ... thirty minutes"
CB=$(cat .r-cookie.out)
[ "$(cnt "$CB" "  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 0 · md5 466c20ed7e0d5439cb052f32ce09de1b")" = 3 ] || die "cookie: the seven 466c20ed on both trees and with the harness, the mask 0"
has "$CB" '  lines that differ: 0 · the same, byte for byte: 7 (1 2 3 4 5 6 7)' "cookie: the same, byte for byte: 7"
has "$CB" '  the same seven as the README'"'"'s run line'"'"'s, byte for byte: yes' "cookie: the harness changes none of the seven"
has "$CB" "$(REC 5 0 0)" "cookie: the seven - five requests Dump printed, no Set-Cookie, no session"
[ "$(cnt "$CB" '    WARN o.s.web.servlet.PageNotFound: Request method '"'"'GET'"'"' is not supported')" = 2 ] || die "cookie: one WARN each, PageNotFound's"
CP=$(blk cookie "what makes a session - the previous tree" "what makes a session - after/"); CA=$(blk cookie "what makes a session - after/" "")
[ "$(seg "$CP" "$(u 19531 "$L_POST")")" = "$(printf '%s\n' "  curl's line: 302$Z00" "  HTTP/1.1 302 · Location: http://127.0.0.1:19531/dashboard · Content-Language: en-US · Content-Length: 0 · Date: (the time - not printed)" "$NOF" "$(REC 1 0 0)" "$(IDS none none no)")" ] || die "cookie: the previous tree's form POST - 302, no cookie, no session"
has "$CP" "$(VJ 1 true 1800 '"COOKIE","URL"')" "cookie: the previous tree's tracking modes - Tomcat's default, cookie and url"
for q in "$(u 19530 "$L_GET")" "$(u 19530 "$L_PAGE")" "$(u 19530 "${L_PAGE%/dashboard}/customers/new")"; do seg "$CA" "$q" | grep -qxF "$(REC 1 0 0)" || die "cookie: $q makes a session"; done
[ "$(seg "$CA" "$(u 19530 "$L_POST")")" = "$(printf '%s\n' "  curl's line: 302$Z00" "$(R302 19530 '')" "$NOF" "$(REC 1 1 1)" "$(IDS present none no)")" ] || die "cookie: after/'s form POST - 302, the cookie, one session, a clean address"
[ "$(seg "$CA" "$(u 19530 "$L_VIS")" | sed -n 2,4p)" = "$(printf '%s\n' "  HTTP/1.1 200 · $CK · Content-Type: application/json · Content-Length: 116 · Date: (the time - not printed)" "$(VJ 1 true 1800 '"COOKIE"')" "$(REC 1 1 1)")" ] || die "cookie: Visits without a cookie - the cookie, new, 1800 s, cookie alone"
[ "$(segn 1 "$CA" "$(u 19530 "$L_VISJ")" | sed -n 3,7p)" = "$(printf '%s\n' "$(VJ 1 true 1800 '"COOKIE"')" "$(REC 1 1 1)" "  curl's cookie jar: 1 cookie" '    #HttpOnly_127.0.0.1 · subdomains FALSE · path / · secure only FALSE · expires 0 · JSESSIONID=<id>')" ] || die "cookie: the jar's first visit - new, the jar keeps the HttpOnly session cookie"
[ "$(segn 2 "$CA" "$(u 19530 "$L_VISJ")" | sed -n 2,4p)" = "$(printf '%s\n' "  HTTP/1.1 200 · Content-Type: application/json · Content-Length: 117 · Date: (the time - not printed)" "$(VJ 2 false 1800 '"COOKIE"')" "$(REC 1 0 0)")" ] || die "cookie: the jar's second visit - the cookie sent back, not new, no new cookie"
[ $((1800 / 60)) = 30 ] && has "$CO" '  server.servlet.session.timeout - type Duration · default "30m" · Session timeout. If a duration suffix is not specified, seconds will be used.' "cookie: 1800 s = Boot's 30m" || die "cookie: thirty minutes"
echo "  cookie: the seven $S466 on both trees and with the harness (no Set-Cookie, no session); the previous tree's form POST makes none; after/'s makes one - JSESSIONID, Path=/, HttpOnly, the address clean; the customers and both pages none; Visits new -> not new with curl's jar, 1800 s; the previous tree's modes COOKIE,URL, after/'s COOKIE"

# "The note: once, then gone ... without the cookie, no note ... a refused form, a JSON POST: no session ... curl -L -X POST posts again"
FL=$(cat .r-flash.out)
[ "$(seg "$FL" "$(u 19530 "$L_POSTJ")")" = "$(printf '%s\n' "  curl's line: 302$Z00" "$(R302 19530 '')" "$NOF" "$(IDS present none no)" "  curl's cookie jar: 1 cookie" '    #HttpOnly_127.0.0.1 · subdomains FALSE · path / · secure only FALSE · expires 0 · JSESSIONID=<id>')" ] || die "flash: the POST with the jar"
[ "$(segn 1 "$FL" "$(u 19530 "$L_PAGEJ")" | sed -n 3p)" = "$(PG Dashboard 24 1066 '<p class="note">Lata added</p>' "$COL5" 0)" ] || die "flash: the note, the first time"
[ "$(segn 2 "$FL" "$(u 19530 "$L_PAGEJ")" | sed -n 3p)" = "$(PG Dashboard 24 1036 none "$COL5" 0)" ] || die "flash: no note the second time"
[ "$(seg "$FL" "$(u 19530 "$L_PAGE")" | sed -n 3p)" = "$(PG Dashboard 25 1108 none 'Lata Meera Om Priya Ravi Sunil' 0)" ] || die "flash: without the cookie - Om stored, no note"
[ "$(seg "$FL" "$(fd "$(u 19530 "$L_POST")" 'name=&mealsPerDay=9&pricePerMeal=0&mealType=X')" | sed -n 1,2p)" = "$(printf '%s\n' "  curl's line: 200$Z00" "  HTTP/1.1 200 · Content-Type: text/html;charset=UTF-8 · Content-Language: en-US · Transfer-Encoding: chunked · Date: (the time - not printed)")" ] || die "flash: a refused form - the form again, no cookie"
[ "$(seg "$FL" "$(u 19530 "$L_JSON")" | sed -n 1,2p)" = "$(printf '%s\n' "  curl's line: 201$Z00" "  HTTP/1.1 201 · Location: http://127.0.0.1:19530/customers/Zoe · Content-Type: application/json · Transfer-Encoding: chunked · Date: (the time - not printed)")" ] || die "flash: the JSON POST - 201, no cookie"
LXS=$(seg "$FL" "$(fd "$(u 19530 "$L_LX")" 'name=Asha&mealsPerDay=1&pricePerMeal=100&mealType=VEG')")
for l in "  curl's line: 405 · WARN lines it added: 1 · ERROR lines: 0" "$(R302 19530 '')" "  HTTP/1.1 405 · Allow: GET · Content-Type: application/problem+json · Transfer-Encoding: chunked · Date: (the time - not printed)" '  body: {"detail":"Method '"'"'POST'"'"' is not supported.","instance":"/dashboard","status":405,"title":"Method Not Allowed"}' "    WARN o.s.web.servlet.PageNotFound: Request method 'POST' is not supported"; do has "$LXS" "$l" "flash: curl -L -X POST posts again - 405"; done
seg "$FL" "$(fd "$(u 19530 "$L_LJ")" 'name=Dev&mealsPerDay=1&pricePerMeal=100&mealType=VEG')" | grep -qxF "$(PG Dashboard 28 1357 '<p class="note">Dev added</p>' 'Asha Dev Lata Meera Om Priya Ravi Sunil Zoe' 0)" || die "flash: curl -L without -X, with the jar - the note"
[ "$(printf '%s\n' "$FL" | grep -c ' · Set-Cookie: ')" = 4 ] || die "flash: four answers set a cookie - the four form POSTs that stored a customer, none other"
echo "  flash: the note once (Lata added), then none; no cookie kept - Om stored, no note; a refused form and a JSON POST set no cookie; -L -X POST -> 405 (posted again), -L with the jar -> the note"

# "The default writes the id into the address ... the cookie's own ... every link ... our key keeps only the cookie" (A/B/A')
TA=$(blk tracking "A - " "B - "); TB=$(blk tracking "B - " "A' - "); TA2=$(blk tracking "A' - " "A' against A")
FQ=$(url "$R_FORM" 19530)
for b in "$TA" "$TA2"; do [ "$(seg "$b" "$FQ")" = "$(printf '%s\n' "$(R302 19530 '')" "$(IDS present none no)" "  the address it gave, the page asked for by a client that keeps no cookie (this unit's page line, that address):")" ] || die "tracking A: the anchor's own line - a clean address"
  [ "$(printf '%s\n' "$b" | grep -cxF "$(PG Dashboard 24 1036 none "$COL5" 0)")" = 2 ] || die "tracking A: a client with no cookie gets no note, no id in a link"; done
[ "$(seg "$TB" "$FQ")" = "$(printf '%s\n' "$(R302 19530 ';jsessionid=<id>')" "$(IDS present present yes)" "  the address it gave, the page asked for by a client that keeps no cookie (this unit's page line, that address):")" ] || die "tracking B: the id in the address, the cookie's own"
has "$TB" "$(PG Dashboard 24 1198 '<p class="note">Lata added</p>' "$COL5" 3)" "tracking B: through the address, the note - and three links carry the id"
has "$TB" "$(PG Dashboard 24 1168 none "$COL5" 3)" "tracking B: the note once"
printf '%s\n' "$TB" | grep -qxF "\$ $(at .harness/after 19530 "$L_URL")" && printf '%s\n' "$TA2" | grep -qxF "\$ $(at .harness/after 19530 "$R_RUN")" || die "tracking: B's and A''s \$ lines"
x tracking "^A' against A, its label aside, line for line the same: yes\$"
echo "  tracking: A - Location .../dashboard, no note without the cookie; B cookie,url - Location .../dashboard;jsessionid=<id>, the cookie's id, the note through the address, 3 links carrying the id; A' = A"

# "SameSite Strict and Secure: one key each ... ninety seconds became sixty"
FG=$(cat .r-flags.out)
for l in "  HTTP/1.1 200 · $CK; SameSite=Strict · Content-Type: application/json · Content-Length: 116 · Date: (the time - not printed)" \
         "  HTTP/1.1 200 · Set-Cookie: JSESSIONID=<id>; Path=/; Secure; HttpOnly · Content-Type: application/json · Content-Length: 116 · Date: (the time - not printed)" "$(VJ 1 true 60 '"COOKIE"')"; do has "$FG" "$l" "flags"; done
[ "$(cnt "$FG" "$(VJ 1 true 1800 '"COOKIE"')")" = 2 ] || die "flags: the two cookie keys leave the timeout alone"
echo "  flags: same-site=strict -> SameSite=Strict; secure=true -> Secure; timeout=90s -> 60 s"

# "DevTools turns persistence on: one, two, restart, three ... off: one ... the file holds each session's id"
PS=$(cat .r-persistent.out); PC=$(blk persistent "C (labelled) - " "persistence off"); PO=$(blk persistent "persistence off" "C' - "); PC2=$(blk persistent "C' - " "C' against C")
for b in "$PC" "$PC2" "$PO"; do has "$b" '     2 Keys the property source devtools: 10 keys' "persistent: DevTools' ten keys"; has "$b" '     4 Keys   server.servlet.session.persistent = true' "persistent: DevTools' default"; has "$b" '     1 Keys the JVM'"'"'s locale: en_US' "persistent: the locale"; has "$b" '  listening on 35729 (Live Reload) now: 0' "persistent: 35729 free"
  [ "$(printf '%s\n' "$b" | grep -cxF '  exit 1 · listening on 19533 now: 0')" = 2 ] || die "persistent: DevTools' JVMs exit 1 after POST /shutdown (its restart launcher), both"; done
for b in "$PC" "$PC2"; do has "$b" "    18 Keys the environment's server.servlet.session.persistent: true" "persistent C"
  [ "$(printf '%s\n' "$b" | grep -E '^  body: ' | sed 's/^  body: {"visits":\([0-9]*\),"new":\([a-z]*\),.*/\1 \2/' | paste -sd' ' -)" = '1 true 2 false 3 false' ] || die "persistent C: visits 1, 2 - restart - 3, the same session"
  [ "$(printf '%s\n' "$b" | grep -cxF '  SESSIONS.ser, searched (never printed): the demo token in it 0 times · the attribute'"'"'s name, visits: yes · the session id curl'"'"'s jar holds: yes')" = 2 ] || die "persistent C: SESSIONS.ser holds the session - its id and its attribute - and no token"; done
has "$PO" "    18 Keys the environment's server.servlet.session.persistent: false" "persistent off"
[ "$(printf '%s\n' "$PO" | grep -E '^  body: ' | sed 's/^  body: {"visits":\([0-9]*\),"new":\([a-z]*\),.*/\1 \2/' | paste -sd' ' -)" = '1 true 2 false 1 true' ] && [ "$(printf '%s\n' "$PO" | grep -cxF '  no such folder')" = 2 ] || die "persistent off: after the restart a new session, visits 1; no file written"
x persistent "^C' against C, its label aside, line for line the same: yes\$"
echo "  persistent: DevTools' 10 keys, server.servlet.session.persistent = true; C: visits 1, 2, restart, 3 (not new), SESSIONS.ser holding the session's id and its attribute, the token 0 times; off: 1 again, no file; exit 1 each, 35729 free; C' = C"

# the exercise's end state: the README's commands, then the solution's, in ONE env -i shell
XS=$(blk exercise "the README's" "the solution's"); XE=$(blk exercise "the solution's" '')
X_SHIP='the redirect: 302 · http://127.0.0.1:19538/dashboard;jsessionid=<id>'; X_END='the redirect: 302 · http://127.0.0.1:19538/dashboard'
has "$XS" "    $X_SHIP" "exercise: as shipped"; has "$XE" "    $X_END" "exercise: the solution"
awk '/^\*\*Done\*\*/ { f = 1 } f' exercise/README.md | grep -qxF -- "$X_END" || die "exercise/README.md: Done names no such line"
grep -qxF -- "$X_END" exercise/solution/SOLUTION.md || die "SOLUTION.md: the measured run shows no such line"
grep -qF -- "\`$X_SHIP\`" exercise/README.md || die "exercise/README.md: the shipped line's answer is not named"
for b in "$XS" "$XE"; do printf '%s\n' "$b" | grep -qE "^  the shell is now in: this unit's folder · the copy's own token in its log: 0 times · WARN lines in its log: 0 · ERROR lines: 0 · listening on 19538 now: 0\$" || die "exercise: 0 tokens, 0 and 0, the shell back in this folder, 19538 free"; done
has "$XE" "  the copy's tiffinbox-local.yaml: server.servlet.session.tracking-modes: cookie" "exercise: the key's value, cookie alone"
EXQ="Your turn: the README's redirect carries the session id in its address. Set one key so only the cookie carries it, and post again."
grep -qxF -- "**Your turn:** ${EXQ#Your turn: }" exercise/README.md || die "exercise/README.md: the spoken exercise line"
[ "$(printf '%s\n' "$EXQ" | wc -w | tr -d ' ')" -le 25 ] || die "exercise: the spoken line is over 25 words"
echo "  exercise: one env -i shell - the README as written (cookie,url in the copy's own file) -> the id in the redirect's address; the solution -> the clean address; the shell in this unit's folder after each"

# "In Chrome: the POST comes back with the Set-Cookie; the redirected GET sends it back - the same id ... the note; again, none ... the store's
#  flags ... C: the id in Chrome's address ... F: Secure kept over plain http, on loopback"
if [ -f .r-browser.out ]; then BR=$(cat .r-browser.out)
  B1=$(blk browser "1 after/" "C (labelled)"); BC=$(blk browser "C (labelled)" "F (labelled)"); BF=$(blk browser "F (labelled)" "")
  [ "$(cnt "$BR" '  its profile, .harness/chrome, made fresh for this visitor (it did not exist before this line): yes')" = 3 ] || die "browser: a fresh profile for each of the three visitors"
  [ "$(cnt "$BR" "  Chrome's DevTools port: 127.0.0.1:19539 · loopback only: yes")" = 3 ] && [ "$(cnt "$BR" '  Chrome exit 0 · listening on 19539 now: 0 · its profile removed')" = 3 ] || die "browser: Chrome's port loopback, exit 0, the profile removed - for each visitor"
  [ "$(cnt "$BR" "  Chrome's NetLog - every address it connected to or tried, its own background requests included: 127.0.0.1 only: yes · ports 19537 among them: yes")" = 3 ] || die "browser: the seal, three times"
  [ "$(cnt "$BR" '    WARN lines they added: 0 · ERROR lines: 0')" = 5 ] || die "browser: 0 and 0 for each of the five visits"
  CP_() { printf '%s\n' "  the page Chrome shows: Dashboard · TiffinBox · its address: $1 · its notes: $2 · its links that carry a session id: 0"; }
  has "$B1" "$(CP_ /dashboard none)" "browser 1: the dashboard, no note"; has "$B1" "$(CP_ /dashboard 'Kiran added')" "browser 1: the note after the form"
  [ "$(cnt "$B1" "$(CP_ /dashboard none)")" = 2 ] || die "browser 1: visit 3 shows no note"
  has "$B1" '    POST /customers - the answer Chrome got: 302 · Location: http://127.0.0.1:19537/dashboard' "browser 1: Chrome's record of the 302"
  has "$B1" '      its Set-Cookie, as Chrome received it: JSESSIONID=<id>; Path=/; HttpOnly' "browser 1: the Set-Cookie Chrome received"
  has "$B1" '      the form'"'"'s body, as Chrome sent it: name=Kiran&mealsPerDay=2&pricePerMeal=110&mealType=VEG' "browser 1: the form's body"
  for l in '        Content-Type: application/x-www-form-urlencoded' '        Origin: http://127.0.0.1:19537' '        Sec-Fetch-Site: same-origin'; do has "$B1" "$l" "browser 1: the POST as Chrome sent it"; done
  [ "$(cnt "$B1" '        Cookie: JSESSIONID=<id>')" = 2 ] && [ "$(printf '%s\n' "$B1" | grep -cE '^ +[0-9]+ Dump +>   [Cc]ookie: JSESSIONID=<id>$')" = 2 ] || die "browser 1: the cookie sent back on the redirected GET and on visit 3 - in Chrome's record and the server's"
  [ "$(printf '%s\n' "$B1" | grep -cE '^ +[0-9]+ Sessions +a session was created$')" = 1 ] && has "$B1" '      45 Dump            <   Set-Cookie: JSESSIONID=<id>; Path=/; HttpOnly' "browser 1" || die "browser 1: one session made, at the POST - the server's record"
  has "$B1" '    JSESSIONID=<id> · domain 127.0.0.1 · path / · httpOnly true · secure false · sameSite (none) · session true' "browser 1: the cookie store's flags"
  has "$B1" '  compared: the id Chrome keeps is the one the server'"'"'s record shows set: yes · the one Chrome sent back last: yes · a redirect'"'"'s Location in the server'"'"'s record carried an id: no' "browser 1: one id, kept and sent back"
  has "$BC" "$(CP_ '/dashboard;jsessionid=<id>' 'Kiran added')" "browser C: the id in Chrome's address"
  has "$BC" '    POST /customers - the answer Chrome got: 302 · Location: http://127.0.0.1:19537/dashboard;jsessionid=<id>' "browser C: Chrome's record of the Location"
  has "$BC" '      46 Dump            <   Location: http://127.0.0.1:19537/dashboard;jsessionid=<id>' "browser C: the server's record of the Location"
  has "$BC" '  compared: the id Chrome keeps is the one the server'"'"'s record shows set: yes · the one Chrome sent back last: yes · a redirect'"'"'s Location in the server'"'"'s record carried an id: yes · the same id: yes' "browser C: the address's id is the cookie's"
  has "$BF" '      its Set-Cookie, as Chrome received it: JSESSIONID=<id>; Path=/; Secure; HttpOnly; SameSite=Strict' "browser F: Secure and SameSite=Strict, received"
  has "$BF" '    JSESSIONID=<id> · domain 127.0.0.1 · path / · httpOnly true · secure true · sameSite Strict · session true' "browser F: kept with both flags"
  has "$BF" "$(CP_ /dashboard 'Kiran added')" "browser F: the note - the Secure cookie went back over http to 127.0.0.1"
  has "$BF" '  compared: the id Chrome keeps is the one the server'"'"'s record shows set: yes · the one Chrome sent back last: yes · a redirect'"'"'s Location in the server'"'"'s record carried an id: no' "browser F: sent back"
  ! printf '%s\n' "$BR" | grep -q 'a cookie Chrome refused' || die "browser: Chrome refused a cookie"
  echo "  browser: three visitors, each a fresh sealed profile, NetLog 127.0.0.1 only; 1 - POST 302 with Set-Cookie HttpOnly, the redirected GET with the same cookie, Kiran added, visit 3 no note; the store: httpOnly true, secure false, sameSite none, session true; C - the id in Chrome's address, the cookie's; F - Secure and SameSite=Strict kept and sent over http to 127.0.0.1"
fi

# "Every form: the clean redirect, the HttpOnly cookie, the note once; cookie,url at start writes the id into the address in each"
if [ -f .r-forms.out ]; then FM=$(cat .r-forms.out)
  x forms '^  exit 0 · BUILD SUCCESS · stages it printed: 8 of the 8 it announces · its lines that say the metadata repository was downloaded over http, or failed to: 0 · offline: yes$'
  x forms '^  file: Mach-O 64-bit executable · the demo token in its bytes: 0$'
  has "$FM" "four forms, one tree: the seven (masked) 4 of 4 times $S466 · the form's POST 302, no session id in its address, the cookie HttpOnly, the note once: 4 of 4 · with cookie and url, the session id in the address, the cookie's: 4 of 4" "forms: the summary"
  has "$FM" '  loopback, form by form: the jar yes · the AOT jar yes · the binary yes · the image, published on 127.0.0.1 alone yes' "forms: loopback"
  [ "$(n forms "^  Boot's first line: Starting AOT-processed TiffinBoxServer v1\.0\.0 using Java 25\.0\.4\.1\$")" = 3 ] && [ "$(n forms "^  Boot's first line: Starting AOT-processed TiffinBoxServer using Java 25\.0\.4\.1\$")" = 3 ] || die "forms: the AOT jar and the binary, each started three times, each AOT-processed"
  [ "$(n forms '^  inside the container, listening: \[::\]:18425$')" = 3 ] && [ "$(n forms '^  docker port: 18425/tcp -> 127\.0\.0\.1:19534$')" = 3 ] || die "forms: the image, three containers, 18425 inside, published on 127.0.0.1:19534 alone"
  x forms '^  its lines that say pull: 0 · '
  x forms '^  the image saved \(docker save\): [1-9][0-9]* blobs, its [1-9][0-9]* layers among them, each read whole \(gzip ones unpacked\) · the demo token in them: 0$'
  echo "  forms: 8 of 8 stages, offline, Mach-O, 0 tokens; the jar, the AOT jar, the binary, the image: the seven 4 of 4, the clean redirect with the HttpOnly cookie and the note once 4 of 4, cookie,url -> the id in the address 4 of 4; loopback; 0 tokens in the image's layers"
fi

cmp -s after/README.md ../c6-tiffinbox/README.md || echo "  (after/README.md and ../c6-tiffinbox/README.md differ - the anchor has moved past this unit's after/)" >&3
[ -z "$unpub" ] || die "no published hash for:$unpub - check the captures, then copy the md5s above into receipts.md5 and run again"
echo "c6-unit24: every capture 3/3 and = published; every spoken number asserted; 0 raw demo tokens in every capture, every log, the container's log, the image's layers, every session file and the binary; nothing of this run left on Docker"
