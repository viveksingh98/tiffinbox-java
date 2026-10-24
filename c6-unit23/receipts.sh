#!/bin/bash
XPATH=$PATH                                           # the PATH you started this with: the exercise's own shell gets it
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25.0.4.1 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"   # the Chrome app on the author's Mac: point it at yours
# GRAALVM_HOME names a GraalVM JDK 25 (README.md, "The GraalVM"): the native build reads it. Without it, this script makes every
# capture that needs no GraalVM, filling .m2-demo on the way, then stops before the native build.
# Course 6 · Static Resources and Cache Headers - this unit's receipts. The anchor changes: application.yaml's first document gains
# three keys - Boot's content version strategy (on, for every path) and a cache period of 365 days for the static files - so every
# page links its stylesheet by a name that carries the file's md5, and the stylesheet's answer lets a browser keep it a year. Nine
# captures, each run three times and hashed; cap() DIES when a hash differs from receipts.md5; every number the video says is asserted
# at the bottom by a check that can fail; the demo token is masked (gsub), and the checks count 0 raw copies of it in every capture,
# in the log of every run - the container's included - in every file this unit ships, in the binary and in the image's layers.
#   change     the previous tree against after/: the files that differ, application.yaml's diff and where its keys sit (above the
#              first ---), Boot's metadata for the keys; "the new build" - each tree with the harness's stylesheet in place of its
#              own - and the four builds, the jars' libraries
#   headers    the seven on both trees, each on a fresh JVM, line for line; then what a static file comes with on the previous tree:
#              the page's link, the stylesheet's answer whole, the validators it carries, a conditional GET; the page's own answer
#   date       whose date Last-Modified is: the root POM's fixed build time, the jars' listings, the previous tree and its new build
#              answering the stylesheet - the same date, other bytes - and the new build asked as a cache holding the old file asks
#   versioned  A/B/A' - spring.web.resources.chain.strategy.content.enabled: A after/ and its new build (the anchor's own lines: the
#              page's link, the stylesheet's headers); B the strategy off for the run; A' A again
#   etag       the handler that serves static files (/actuator/mappings, exposed for one run); the versioned answer's ETag sent back
#              alone, as *, beside If-Modified-Since; If-Modified-Since alone
#   devtools   Boot's metadata for the resource keys; DevTools on the class path (its property source, read by the harness's Keys)
#              on the previous tree and on after/; E/F/E' - spring.web.resources.chain.cache, a stylesheet changed while TiffinBox
#              runs from a folder class path
#   exercise   exercise/README.md's commands, then exercise/solution/SOLUTION.md's, read from the files and run as written, one after
#              the other in ONE shell a viewer could have: env -i, /bin/bash, started in this folder
#   browser    TiffinBox with Dump (the server's record of every request, the stylesheet's included, whole) and headless Chrome, a
#              profile of its own made fresh for each visitor, sealed to 127.0.0.1: one tab visits the dashboard, TiffinBox is
#              replaced by its new build on the same port, the tab visits again and reloads - the previous tree; C (labelled) it with
#              Cache-Control: no-cache; after/; D (labelled) after/ with no-cache - each claim with two witnesses; G (labelled), the
#              control for the first: the previous tree with its static files read from a folder this run writes, so Last-Modified is
#              seconds old - visited twice, eight seconds apart (Chrome's own lifetime for an answer with none is a guess from that age)
#   forms      the native build of after/; what Spring's AOT step registers, on the previous tree and on after/; then four forms -
#              the jar, the AOT jar, the binary, the image: each one's address, the seven (masked), exit 0; then, on a second start of
#              each, the page's link, the versioned stylesheet's answer, a conditional GET by date and one by the ETag
# "The previous tree" is before/, the link to ../c6-unit22/after (the anchor before this change: the serving lesson's frozen tree),
# COPIED under .harness/before; after/ is this unit's frozen copy of ../c6-tiffinbox after the change, COPIED under .harness/after.
# "The new build" of a tree is a copy of it with harness/newbuild/tiffinbox.css - the stylesheet with one line added - in place of its
# own static/css/tiffinbox.css, built the same way: .harness/before-new and .harness/after-new. This script never writes into another
# unit's folder, and never builds a frozen tree in place. Every run of TiffinBox starts in a folder under .harness/ that holds a
# config tree with a fake token (secrets/), as the README asks - the container's too, mounted read-only. Commands are printed exactly
# as they run: each goes through eval. "$CURLSET" is the comparison set since the secrets lesson (../c5-unit11/curlset.sh: the seven
# requests, POST /shutdown with the token's header read from the file). "$M2" is this unit's own repository, .m2-demo. "$CHROME" is
# the Chrome app (above). The harness - harness/probe/web/*.java (compiled with -parameters): Dump (the serving lesson's, one path
# fewer skipped: /css/), Keys (the serving lesson's, byte for byte) and Trace (the CORS lesson's, byte for byte) - is the course's,
# never TiffinBox's: outside com.tiffinbox, joined by --spring.main.sources on the extracted jar's class path; harness/newbuild/
# tiffinbox.css is copied into copies, never into after/; harness/cdp.mjs drives Chrome over its DevTools protocol (node's own
# WebSocket); harness/net.py reads Chrome's record of a visit's requests; harness/netlog.py (the CORS lesson's, byte for byte) reads
# Chrome's NetLog; harness/shutdown.sh is POST /shutdown with the token read from its file. Every run passes options only. The seven
# always run on a fresh JVM, first.
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
# "<user>"; a Tomcat request thread's number "tomcat-handler-<n>"; Chrome's version in its User-Agent and its sec-ch-ua brand list -
# in every line of every capture. Spring's error timestamp becomes "…" (both forms). An answer's headers are printed whole, on one
# line, in the order they came - a Date header's value, the time, is not printed; Last-Modified's is (it is the build's fixed time,
# never the clock's). A page (HTML) is never printed whole: its <title>, its line and byte counts, and its stylesheet's <link> line;
# a stylesheet as its bytes and its md5; a JSON answer as its bytes. A run's log lines are printed from their logger on; a WARN or
# ERROR record as its level, logger and message, then its exception line, its frames bounded ("over 40") and its other lines counted.
# The harness's lines (Trace) are printed in the order they ran, numbered from 1. No image, container or ID is printed but the base
# image's digest. No duration is captured: the native build's seconds, and the 20-minute bound, go to the terminal only.
# Ports (brief ⚑1, 19520-19529): after/'s jar 19520 · the previous tree 19521 · a new build 19522 · DevTools 19523 · a folder class
# path (devtools E/F/E'), then the image 19524 · the AOT jar 19525 · the binary 19526 · the browser's TiffinBox 19527 · the exercise
# 19528 · Chrome's DevTools port 19529. 18425 (TiffinBox's default), 8080 (Tomcat's) and 35729 (DevTools' Live Reload) are checked
# free too, and never bound on this machine (18425 only inside a container).
# Docker names (no unit number): the image tiffinbox-static:1.0.0 and the container tiffinbox-static. Each is checked absent before
# the first run - a name already there may be yours, and this script removes only what it creates - and removed on every exit.
set -e
# bash 5.2 and later turn an & in the replacement of ${x/pattern/replacement} into the matched text (patsub_replacement, on by
# default). Switched off, so /bin/bash 3.2 (./receipts.sh) and a newer bash (bash receipts.sh) run the same commands.
shopt -u patsub_replacement 2> /dev/null || true
export LC_ALL=C
cd "$(dirname receipts.sh)"
# One run at a time: two runs share .harness/, the ports and the Docker names, and one would corrupt the other.
mkdir .r-lock 2> /dev/null || { echo "  *** another receipts.sh is running in this folder (.r-lock exists) - if none is, rmdir .r-lock ***"; exit 1; }
IMG=tiffinbox-static:1.0.0; BOX=tiffinbox-static
OURS=""
U="$PWD"; UP="$(cd .. && pwd)"; ME="$(id -un)"
# On every exit - the end, a failed check, or Ctrl-C - stop the processes this script started in the background, if they still run:
# $pid (a server), $xpid (the exercise's shell, with every process under it), $cpid (Chrome, with every process under it); then
# sweep(): anything of this run still alive - in its process group, a TiffinBox JVM, a binary, native-image's driver or builder, a
# Maven; anywhere, a process started with this unit's own Chrome profile - is stopped; then dclean(): this run's container and image.
# Chrome's profile is removed. After an interrupt, a capture's unfinished runs (.r-NAME.1-3) go too. The clean-up ignores a second
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
trap 'trap "" INT TERM; for p in "$xpid" "$cpid"; do [ -z "$p" ] || killtree "$p"; done; for p in "$pid" "$xpid" "$cpid"; do if [ -n "$p" ] && kill "$p" 2> /dev/null; then wait "$p" 2> /dev/null || true; fi; done; sweep || true; dclean || true; rm -rf .harness/chrome 2> /dev/null || true; [ -z "$INTR" ] || rm -f .r-*.[123]; rmdir .r-lock 2> /dev/null || true' EXIT
INTR=""; FRESHD=""; trap 'INTR=1; exit 130' INT TERM
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
[ -L before ] && [ "$(readlink before)" = ../c6-unit22/after ] || die "before must be the link to ../c6-unit22/after - the anchor before this change"
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
CSS=static/css/tiffinbox.css                         # the stylesheet, under a tree's resources (or classes)
YML=$RS/application.yaml                             # the web module's configuration file, in a tree
# The demo token. FAKE, and meant to look it: it guards nothing but a demo server on 127.0.0.1 that every capture stops. It is
# written into .harness/*/secrets/ (git-ignored) when this script runs, and no capture prints it: see mask().
TOKEN=not-a-real-token-for-the-cache
[ ${#TOKEN} = 30 ] || die "the demo token must be 30 characters: the published captures name its length"
CURLSET=../c5-unit11/curlset.sh
[ -f "$CURLSET" ] || die "$CURLSET is missing"
HWS='harness/probe/web/Dump.java harness/probe/web/Keys.java harness/probe/web/Trace.java'
NEWCSS=harness/newbuild/tiffinbox.css                 # the new build's stylesheet: after/'s with one line added
for f in harness/shutdown.sh harness/cdp.mjs harness/net.py harness/netlog.py $NEWCSS $HWS exercise/README.md exercise/solution/SOLUTION.md README.md; do [ -f "$f" ] || die "$f is missing"; done
[ "$(ls harness/probe/web | paste -sd' ' -)" = 'Dump.java Keys.java Trace.java' ] || die "harness/probe/web holds another file: javac compiles all of it"
for f in harness/probe/web/Trace.java harness/netlog.py harness/shutdown.sh; do cmp -s "$f" "../c6-unit19/$f" || die "$f is not the CORS lesson's (../c6-unit19/$f), byte for byte"; done
cmp -s harness/probe/web/Keys.java ../c6-unit22/harness/probe/web/Keys.java || die "harness/probe/web/Keys.java is not the serving lesson's, byte for byte"
# Dump is the serving lesson's with one path fewer skipped: its code lines differ in one place, the /css/ test
[ "$(diff ../c6-unit22/harness/probe/web/Dump.java harness/probe/web/Dump.java | grep -E '^[<>] ' | grep -vE '^[<>]  \*' | paste -sd'|' -)" = '<         if (r.getRequestURI().startsWith("/actuator") || r.getRequestURI().equals("/shutdown") || r.getRequestURI().startsWith("/css/")|>         if (r.getRequestURI().startsWith("/actuator") || r.getRequestURI().equals("/shutdown")' ] || die "harness/probe/web/Dump.java must be the serving lesson's with its /css/ skip taken out, and nothing else in its code"
[ "$(diff "after/$RS/$CSS" "$NEWCSS" | grep -c '^[<>] ')" = 1 ] && [ "$(diff "after/$RS/$CSS" "$NEWCSS" | grep '^[<>] ')" = '> footer { color: #555; }' ] || die "$NEWCSS must be after/'s stylesheet with one line added: footer { color: #555; }"
cmp -s "after/$RS/$CSS" "$PREV/$RS/$CSS" || die "after/'s stylesheet must be the previous tree's, byte for byte"

listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
for p in 18425 8080 35729 19520 19521 19522 19523 19524 19525 19526 19527 19528 19529; do
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
R_MAPS=$(readme "$J --management.endpoints.web.exposure.include=health,prometheus,mappings")
R_DBUILD=$(readme 'docker build -t tiffinbox-docker:1.0.0 .')
R_DRUN=$(readme 'docker run -d --name tiffinbox -m 512m -v "$PWD/secrets:/app/secrets:ro" -p 127.0.0.1:18431:18425 tiffinbox-docker:1.0.0')
R_READY=$(readme "curl -s -w ' %{http_code}\n' http://127.0.0.1:18431/actuator/health/readiness")
R_PAGE=$(readme "curl -s -H 'Accept: text/html' http://127.0.0.1:18431/dashboard")
# this unit's lines in the anchor's README: the page's stylesheet link, and the stylesheet's headers - its name the file's own md5
R_LINK=$(readme "curl -s -H 'Accept: text/html' http://127.0.0.1:18431/dashboard | grep -o '/css/[^\"]*'")
H0=$(md5 -q "after/$RS/$CSS")
R_CSSH=$(readme "curl -s -D - -o /dev/null http://127.0.0.1:18431/css/tiffinbox-$H0.css")
WS=" -w ' %{http_code}\n'"
# This unit's own lines (README.md, "The commands this unit adds") - each asserted to be exactly that
mine() { grep -m1 -xF -- "$1" README.md > /dev/null || die "README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
JL='-Duser.language=en -Duser.country=US'
FOLD='"tiffinbox-web/target/classes:tiffinbox-web/target/extracted/lib/*" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431'
CHROMEA='text/html,application/xhtml+xml,application/xml;q=0.9,image/jxl,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7'
OLDLM='Tue, 15 Sep 2026 00:00:00 GMT'                 # the build's fixed time, as Last-Modified writes it - asserted against every answer
L_RUNL=$(mine "java $JL -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431")
L_CPL=$(mine "java $JL -cp \"tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*\" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431")
L_MAPS=$(mine "$L_RUNL --management.endpoints.web.exposure.include=health,prometheus,mappings")
L_OFF=$(mine "$L_RUNL --spring.web.resources.chain.strategy.content.enabled=false")
L_FOLD=$(mine "java $JL -cp $FOLD")
L_CCF=$(mine "$L_FOLD --spring.web.resources.chain.cache=false")
L_DUMP=$(mine "java $JL -cp \"tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc\" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431 --spring.main.sources=probe.web.Dump")
L_DUMPNC=$(mine "$L_DUMP --spring.web.resources.cache.cachecontrol.no-cache=true")
L_FRESHL=$(mine "$L_DUMP --spring.web.resources.static-locations=file:../fresh/")
L_FRESH=$(mine "mkdir -p .harness/fresh/css && cp .harness/before/$RS/$CSS .harness/fresh/css/tiffinbox.css")
L_DEVT=$(mine "java $JL -cp \"tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:\$M2/org/springframework/boot/spring-boot-devtools/4.1.1/spring-boot-devtools-4.1.1.jar:../hc\" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431 --spring.devtools.livereload.enabled=false --spring.main.sources=probe.web.Keys")
L_JAVAC=$(mine "javac -parameters -d .harness/hc -cp \".harness/after/tiffinbox-web/target/extracted/lib/*\" $HWS")
L_NEWB=$(mine "cp $NEWCSS .harness/after-new/$RS/$CSS")
L_PAGE=$(mine "curl -s -D .harness/head.txt -o .harness/body.html -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html' http://127.0.0.1:18431/dashboard")
L_CSS=$(mine "curl -s -D .harness/head.txt -o .harness/body.out -w ' %{http_code} · %{size_download} bytes\n' http://127.0.0.1:18431/css/tiffinbox.css")
L_IMS=$(mine "curl -s -D .harness/head.txt -o .harness/body.out -w ' %{http_code} · %{size_download} bytes\n' -H 'If-Modified-Since: $OLDLM' http://127.0.0.1:18431/css/tiffinbox.css")
L_EDIT=$(mine "cp ../../$NEWCSS $TC/$CSS")
L_CHROME=$(mine "\"\$CHROME\" --headless=new --user-data-dir=\"\$PWD/.harness/chrome\" --no-first-run --no-default-browser-check --disable-background-networking --disable-component-update --disable-sync --disable-domain-reliability --use-mock-keychain --password-store=basic --lang=en-US --proxy-server=http://127.0.0.1:9 --host-resolver-rules='MAP * ~NOTFOUND, EXCLUDE 127.0.0.1' --remote-debugging-address=127.0.0.1 --remote-debugging-port=19529 --log-net-log=\"\$PWD/.harness/netlog.json\" about:blank")
L_OPEN=$(mine "node harness/cdp.mjs 19529 open http://127.0.0.1:18431/dashboard .harness/ev.json")
L_AGAIN=$(mine "node harness/cdp.mjs 19529 again http://127.0.0.1:18431/dashboard .harness/ev.json")
L_RELOAD=$(mine "node harness/cdp.mjs 19529 reload .harness/ev.json")
L_CLOSE=$(mine "node harness/cdp.mjs 19529 close")
L_NET=$(mine "python3 harness/net.py .harness/ev.json 18431")
L_NETLOG=$(mine "python3 harness/netlog.py .harness/netlog.json 18431")
# The derivations, each asserted
P_='java '; Q_="java $JL "; r=${R_RUN/"$P_"/$Q_}; r2=${R_CP/"$P_"/$Q_}
[ "$r" = "$L_RUNL" ] && [ "$r2" = "$L_CPL" ] && [ "$L_MAPS" = "${R_MAPS/"$P_"/$Q_}" ] || die "the pinned lines must be the anchor's run, class-path and routing-table lines with $JL after java, and nothing else"
P_='"tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:'; Q_='"tiffinbox-web/target/classes:'; r=${L_CPL/"$P_"/$Q_}; [ "$r" = "$L_FOLD" ] || die "the folder line must be the pinned class-path line with the web module's classes folder in place of its jar, and nothing else"
for l_ in "$L_OFF" "$L_CCF" "$L_DUMPNC"; do case $l_ in "$L_RUNL "*) o_=${l_#"$L_RUNL "} ;; "$L_FOLD "*) o_=${l_#"$L_FOLD "} ;; "$L_DUMP "*) o_=${l_#"$L_DUMP "} ;; *) die "a line with one option more: $l_" ;; esac
  case $o_ in --*=*) ;; *) die "one option, an option: $l_" ;; esac; [ "${o_#* }" = "$o_" ] || die "one option, no more: $l_"; done
O_OFF=${L_OFF#"$L_RUNL "}; O_CCF=${L_CCF#"$L_FOLD "}; O_NC=${L_DUMPNC#"$L_DUMP "}
r=${L_DEVT/:\$M2\/org\/springframework\/boot\/spring-boot-devtools\/4.1.1\/spring-boot-devtools-4.1.1.jar:..\/hc\"/\"}; r=${r% --spring.devtools.livereload.enabled=false --spring.main.sources=probe.web.Keys}; [ "$r" = "$L_CPL" ] || die "the DevTools line must be the pinned class-path line with DevTools' jar and the harness added, Live Reload off and Keys joined, and nothing else"
r=${L_DUMP/:..\/hc\"/\"}; r=${r% --spring.main.sources=probe.web.Dump}; [ "$r" = "$L_CPL" ] || die "the Dump line must be the pinned class-path line with the harness added and Dump joined, and nothing else"
[ "${L_JAVAC#* -cp \"*\" }" = "$HWS" ] || die "the harness's javac line must compile the three files in harness/probe/web, and nothing else"
P_='curl -s '; Q_="curl -s -D .harness/head.txt -o .harness/body.html -w ' %{http_code} · Content-Type: [%{content_type}]\n' "; r=${R_PAGE/"$P_"/$Q_}; [ "$r" = "$L_PAGE" ] || die "the page line must be the anchor's with the headers and the body sent to files and curl's status and Content-Type printed, and nothing else"
P_=' -D - -o /dev/null '; Q_=" -D .harness/head.txt -o .harness/body.out -w ' %{http_code} · %{size_download} bytes\n' "; r=${R_CSSH/"$P_"/$Q_}; r=${r/tiffinbox-$H0.css/tiffinbox.css}; [ "$r" = "$L_CSS" ] || die "the stylesheet line must be the anchor's with the headers and the body sent to files, curl's status and size printed, and the plain name, and nothing else"
P_=' http://'; Q_=" -H 'If-Modified-Since: $OLDLM' http://"; r=${L_CSS/"$P_"/$Q_}; [ "$r" = "$L_IMS" ] || die "the conditional line must be the stylesheet line with one header, If-Modified-Since, and nothing else"
off() { local c=${2/mvn -B /mvn -o -B -Dmaven.repo.local=\"\$M2\" }
  [ -n "$3" ] && c=${c/ $3/ -DskipTests clean $3}
  printf 'cd %s && %s\n' "$1" "$c"; }
dev() { local c=${1#cd * && }; c=${c/ -o -B -Dmaven.repo.local=\"\$M2\" / -B }; c=${c/ -DskipTests clean / }; printf '%s\n' "$c"; }
# at DIR PORT 'README LINE': the README's line run from DIR, its port 18431 made PORT - and a java line with the JVM's locale pinned
# right after "java" (this unit's pinned lines show the form, and at() must give them back)
at() { local l=${3/--tiffinbox.port=18431/--tiffinbox.port=$2}; case $l in 'java -Djarmode=tools '*|"java $JL "*) ;; 'java '*) l="java $JL ${l#java }" ;; esac; printf 'cd %s && %s\n' "$1" "$l"; }
url() { printf '%s\n' "${1/:18431\//:$2/}"; }
# gq PORT: this unit's page line, its port PORT. cq PORT PATH ['HEADER' ['HEADER']]: this unit's stylesheet line, its port PORT, its
# path PATH, one or two request headers before the address
gq() { printf '%s\n' "${L_PAGE/:18431\//:$1/}"; }
cq() { local c=${L_CSS/:18431\/css\/tiffinbox.css/:$1$2} h="" P_=' http://' Q_; [ -z "${3:-}" ] || h=" -H '$3'"; [ -z "${4:-}" ] || h="$h -H '$4'"; Q_="$h http://"; printf '%s\n' "${c/"$P_"/$Q_}"; }
vq() { local c=${L_OPEN/19529 open http:\/\/127.0.0.1:18431\//19529 open http://127.0.0.1:$1/}; printf '%s\n' "$c"; }
aq() { local c=${L_AGAIN/19529 again http:\/\/127.0.0.1:18431\//19529 again http://127.0.0.1:$1/}; printf '%s\n' "$c"; }
nlq() { printf '%s\n' "${L_NETLOG% 18431} $*"; }
exe() { printf '%s\n' "$1" | sed -E 's/&& (([A-Z_]+=[^ ]* )*)/\&\& \1exec /'; }
UARG='--user "$(id -u):$(id -g)"'
dbuild() { local c=${R_DBUILD/docker build -t tiffinbox-docker:1.0.0 /docker build --progress=plain -t $IMG }; printf 'cd %s && %s\n' "$1" "$c"; }
drun() { local c=${R_DRUN/--name tiffinbox /--name $BOX $UARG }; c=${c/127.0.0.1:18431:18425/127.0.0.1:$2:18425}; c=${c/% tiffinbox-docker:1.0.0/ $IMG}; printf 'cd %s && %s\n' "$1" "$c"; }
undock() { local c=${1#cd * && }; c=${c/--progress=plain /}; c=${c/" $UARG"/}; c=${c//$IMG/tiffinbox-docker:1.0.0}; c=${c/--name $BOX /--name tiffinbox }; c=${c/127.0.0.1:1952?:18425/127.0.0.1:18431:18425}; printf '%s\n' "$c"; }
[ "$(undock "$(dbuild .harness/x)")" = "$R_DBUILD" ] || die "not the README's build line with the declared changes: $(dbuild .harness/x)"
[ "$(undock "$(drun .harness/x 19524)")" = "$R_DRUN" ] || die "not the README's run line with the declared changes: $(drun .harness/x 19524)"
C_PRE=$(off .harness/pre "$R_INSTALL" install)
for c in "$C_PRE" "$(off .harness/x "$R_PLAIN" package)" "$(off .harness/x "$R_PNAT" package)" "$(off .harness/x "$R_NATIVE")"; do
  r=$(dev "$c"); [ "$r" = "$R_PLAIN" ] || [ "$r" = "$R_PNAT" ] || [ "$r" = "$R_INSTALL" ] || [ "$r" = "$R_NATIVE" ] || die "not a README line with the offline changes: $c"; done
[ "$(exe "$(at .harness/x 19520 "$R_RUN")")" = "cd .harness/x && exec ${L_RUNL/18431/19520}" ] && [ "$(at .harness/x 18431 "$R_CP")" = "cd .harness/x && $L_CPL" ] && [ "$(at .harness/x 18431 "$L_FOLD")" = "cd .harness/x && $L_FOLD" ] && [ "$(at .harness/x 18431 "$L_DUMP")" = "cd .harness/x && $L_DUMP" ] && [ "$(at .harness/x 19526 "$R_BIN")" = 'cd .harness/x && tiffinbox-web/target/tiffinbox-web --tiffinbox.port=19526' ] || die "at(): the pinned lines are not README.md's, or the binary's line got the JVM's options"
[ "$(gq 18431)" = "$L_PAGE" ] && [ "$(cq 18431 /css/tiffinbox.css)" = "$L_CSS" ] && [ "$(cq 18431 /css/tiffinbox.css "If-Modified-Since: $OLDLM")" = "$L_IMS" ] && [ "$(cq 19520 /css/x.css 'A: 1' 'B: 2')" = "curl -s -D .harness/head.txt -o .harness/body.out -w ' %{http_code} · %{size_download} bytes\n' -H 'A: 1' -H 'B: 2' http://127.0.0.1:19520/css/x.css" ] || die "gq() or cq()"
[ "$(vq 18431)" = "$L_OPEN" ] && [ "$(aq 18431)" = "$L_AGAIN" ] && [ "$(nlq 18431)" = "$L_NETLOG" ] || die "vq(), aq() or nlq()"
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
if [ $BROWSER = yes ]; then echo "  the browser: $("$CHROME" --version 2> /dev/null | head -1) on $(uname -s) $(uname -m) (the platform its User-Agent and sec-ch-ua-platform name) · node $(node --version) - printed here, never in a capture"; else echo "  the browser: none - $WHYNOT"; fi

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
mask() { awk -v fd="${FRESHD:-}" -v t="$TOKEN" -v g="${GRAALVM_HOME:-}" -v u="$U" -v up="$UP" -v hm="$HOME" -v me="$ME" -v tl="${#TOKEN}" '
  function lit(x) { gsub(/[][\\.^$*+?(){}|\/]/, "\\\\&", x); return x }
  function enc(x) { gsub(/ /, "%20", x); return x }
  BEGIN { T = lit(t); G = lit(g); GE = lit(enc(g)); P = lit(u); Q = lit(up); H = lit(hm); PE = lit(enc(u)); QE = lit(enc(up)); M = "(^|[^A-Za-z0-9_])" lit(me) "([^A-Za-z0-9_]|$)" }
  { gsub(T, "[masked: the " tl "-character token]"); if (g != "") { gsub(G, "$GRAALVM_HOME"); gsub(GE, "$GRAALVM_HOME") }; gsub(P, "…"); gsub(PE, "…")
    gsub(Q, "…/.."); gsub(QE, "…/.."); gsub(H, "~"); gsub(/\$\$SpringCGLIB\$\$[0-9]+/, "$$SpringCGLIB$$<n>")
    gsub(/tomcat-handler-[0-9]+/, "tomcat-handler-<n>")
    if (fd != "") gsub(lit(fd), "(the file time of this run: masked)")
    gsub(/Chrome\/[0-9][0-9.]*/, "Chrome/<version>"); gsub(/Mozilla\/5\.0 \([^)]*\)/, "Mozilla/5.0 (<platform masked>)")
    if (match($0, /sec-ch-ua-platform: /)) $0 = substr($0, 1, RSTART + RLENGTH - 1) "(<platform masked>)"
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
# a Date header's value (the time) is not printed, nor a Last-Modified other than the build's fixed time (a folder class path's file
# time; the binary's - lmwhere() says where it falls)
hall() { [ -f .harness/head.txt ] || { echo "  its headers: no file - curl wrote none"; return 0; }
  tr -d '\r' < .harness/head.txt | awk -v lm="$OLDLM" 'NR == 1 { st = $0; sub(/ +$/, "", st); next } $0 == "" { next }
    { n = $0; sub(/:.*/, "", n); v = $0; sub(/^[^:]*: /, "", v); if (tolower(n) == "date") $0 = n ": (the time - not printed)"
      else if (tolower(n) == "last-modified" && v != lm) $0 = n ": (another time - not printed)"; sh = sh " · " $0 } END { print "  " st sh }'; }
# hv NAME: one header's value from the headers curl wrote (none: not sent)
hv() { tr -d '\r' < .harness/head.txt 2> /dev/null | awk -v n="$1" 'BEGIN { n = tolower(n) } { k = $0; sub(/:.*/, "", k) } tolower(k) == n { sub(/^[^:]*: /, ""); print; f = 1; exit } END { if (!f) print "none" }'; }
# pagef FILE: a page curl wrote, as this unit prints one - never whole: its <title>, its line and byte counts, and its stylesheet's
# <link> line, whole. JSON or text: its bytes, the error timestamp masked. An empty body: "none".
pagef() { python3 - "$1" <<'PY'
import re, sys
f = sys.argv[1]
try: b = open(f, "rb").read()
except OSError: print("  body: no file - curl wrote none"); sys.exit(0)
if not b: print("  body: none (0 bytes)"); sys.exit(0)
t = b.decode("utf-8", "replace"); L = t.splitlines()
ti = re.search(r"<title>(.*?)</title>", t)
if ti:
    k = [l.strip() for l in L if 'rel="stylesheet"' in l]
    print("  the page: <title>%s</title> · %d lines, %d bytes - not shown but its stylesheet link%s %s" % (ti.group(1), len(L), len(b), "" if len(k) == 1 else "s (%d)" % len(k), " | ".join(k) if k else "none"))
else:
    print("  body: " + re.sub(r"\"timestamp\":[0-9]+", "\"timestamp\":…", re.sub(r"\"timestamp\":\"[^\"]*\"", "\"timestamp\":\"…\"", t)))
PY
}
# bodyf: the stylesheet's body curl wrote (-o .harness/body.out): its bytes and md5; a JSON answer as its bytes; no file: "no file"
bodyf() { if [ ! -f .harness/body.out ]; then echo "  body: no file - curl wrote none"
  elif [ ! -s .harness/body.out ]; then echo "  body: none (0 bytes)"
  elif [ "$(head -c 1 .harness/body.out)" = '{' ]; then echo "  body: $(tsmask < .harness/body.out)"
  else echo "  body: $(wc -c < .harness/body.out | tr -d ' ') bytes · md5 $(md5 -q .harness/body.out)"; fi; }
# rq 'CURL LINE' [nolog]: a curl line of this unit's (its headers and body to files), printed and run; curl's own line and the WARN
# and ERROR lines the request added; its headers (hall); its body (pagef for a page, bodyf for the rest); each WARN or ERROR record.
# The files are removed first: an answer curl wrote no body for prints "no file" (R.119). nolog: no log read (a container's)
rq() { local n0 w e; [ -n "${2:-}" ] || n0=$(mark); rm -f .harness/head.txt .harness/body.html .harness/body.out; echo "\$ $1"; (eval "$1") 2> /dev/null < /dev/null > .harness/curl.txt || true
  if [ -n "${2:-}" ]; then echo "  curl's line:$(cat .harness/curl.txt)"
  else settle; w=$(logl "$n0" WARN | grep -c . || true); e=$(logl "$n0" ERROR | grep -c . || true); echo "  curl's line:$(cat .harness/curl.txt) · WARN lines it added: $w · ERROR lines: $e"; fi
  hall; case $1 in *' -o .harness/body.html '*) pagef .harness/body.html ;; *) bodyf ;; esac
  [ -n "${2:-}" ] || [ "$w$e" = 00 ] || recs "$n0"; }
# lnk: the stylesheet's address in the page curl wrote last (its <link>'s href)
lnk() { sed -n 's/.*<link rel="stylesheet" href="\([^"]*\)">.*/\1/p' .harness/body.html | sed -n 1p; }
# askl 'README LINE' PORT: the anchor's own one-line command, its port made PORT, printed and run; its output; LINK is its first line
askl() { local c; c=$(url "$1" "$2"); echo "\$ $c"; (eval "$c") > .harness/askl.txt 2> /dev/null < /dev/null || true; sed 's/^/  /' .harness/askl.txt; LINK=$(sed -n 1p .harness/askl.txt); }
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
printf 'HTTP/1.1 304 \r\nCache-Control: no-cache\r\nLast-Modified: Tue, 15 Sep 2026 00:00:00 GMT\r\nETag: W/"ab"\r\nDate: Thu, 22 Oct 2026 05:59:37 GMT\r\n\r\n' > .harness/head.txt
[ "$(hall)" = '  HTTP/1.1 304 · Cache-Control: no-cache · Last-Modified: Tue, 15 Sep 2026 00:00:00 GMT · ETag: W/"ab" · Date: (the time - not printed)' ] || die "hall: the planted headers do not come out as declared"
printf 'HTTP/1.1 200 \r\nLast-Modified: Thu, 22 Oct 2026 15:51:41 GMT\r\n\r\n' > .harness/head2.txt; [ "$(mv .harness/head.txt .harness/head1.txt; mv .harness/head2.txt .harness/head.txt; hall; mv .harness/head.txt .harness/head2.txt; mv .harness/head1.txt .harness/head.txt)" = '  HTTP/1.1 200 · Last-Modified: (another time - not printed)' ] || die "hall: a Last-Modified that is not the build's fixed time must not be printed"; rm -f .harness/head2.txt
[ "$(hv etag)" = 'W/"ab"' ] && [ "$(hv Last-Modified)" = 'Tue, 15 Sep 2026 00:00:00 GMT' ] && [ "$(hv Content-Length)" = none ] || die "hv: the planted headers' values do not come out as declared"
rm -f .harness/head.txt
printf '%s\n' '<!DOCTYPE html>' '<html>' '<head>' '  <title>Planted · TiffinBox</title>' '  <link rel="stylesheet" href="/css/x-ab.css">' '</head>' '</html>' > .harness/body.html
[ "$(pagef .harness/body.html)" = '  the page: <title>Planted · TiffinBox</title> · 7 lines, 131 bytes - not shown but its stylesheet link <link rel="stylesheet" href="/css/x-ab.css">' ] && [ "$(lnk)" = /css/x-ab.css ] || die "pagef or lnk: the planted page does not come out as declared"
printf '{"timestamp":"2026-10-22T05:59:37.000Z","status":404}' > .harness/body.html; [ "$(pagef .harness/body.html)" = '  body: {"timestamp":"…","status":404}' ] || die "pagef: a JSON body must come out as its bytes, the timestamp masked"
rm -f .harness/body.html
printf 'a { }\n' > .harness/body.out; [ "$(bodyf)" = "  body: 6 bytes · md5 $(printf 'a { }\n' | md5 -q)" ] || die "bodyf: a stylesheet must come out as its bytes and its md5"
: > .harness/body.out; [ "$(bodyf)" = '  body: none (0 bytes)' ] || die "bodyf: an empty body must come out as none"
rm -f .harness/body.out; [ "$(bodyf)" = '  body: no file - curl wrote none' ] || die "bodyf: no file must come out as no file"
[ "$(printf '%s\n' 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/155.0.0.0 Safari/537.36' 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/155.0.0.0 Safari/537.36' 'sec-ch-ua: "Google Chrome";v="155"' 'sec-ch-ua-mobile: ?0' 'sec-ch-ua-platform: "macOS"' 'sec-ch-ua-platform: "Linux"' '[x][tomcat-handler-12] x' | mask)" = "$(printf '%s\n' 'User-Agent: Mozilla/5.0 (<platform masked>) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/<version> Safari/537.36' 'User-Agent: Mozilla/5.0 (<platform masked>) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/<version> Safari/537.36' 'sec-ch-ua: (its brands and their versions: masked)' 'sec-ch-ua-mobile: ?0' 'sec-ch-ua-platform: (<platform masked>)' 'sec-ch-ua-platform: (<platform masked>)' '[x][tomcat-handler-<n>] x')" ] || die "mask: Chrome's version and the platform (User-Agent, sec-ch-ua-platform) and a request thread's number must be masked, and nothing else"
echo "  the filters: the level counts (a harness line that says ERROR is no ERROR line), the record filter, the harness's lines, the header filters, the page and body filters and the masks print their planted inputs as declared"

# ---- change: three keys in application.yaml; the new build -----------------------------------------------------------------------
cdiff() { diff -U0 "$1" "$2" | tail -n +3 > .harness/code.diff || true
  echo "  its diff (diff -U0, its file names cut) - hunks: $(grep -c '^@@ ' .harness/code.diff || true) · lines out: $(grep -c '^-' .harness/code.diff || true) · in: $(grep -c '^+' .harness/code.diff || true) - whole:"
  sed 's/^/    /' .harness/code.diff; }
# where: the line of KEY (its last segment, at INDENT spaces) in a tree's application.yaml, and the first "---"
yline() { awk -v k="$2" '$0 == k { print NR; exit }' "$1"; }
change() { local f n m k y d
  echo "the previous tree and after/, both copied under .harness/ with a config tree, each built with the README's line (offline):"
  copy "$PREV" .harness/before; copy after .harness/after
  pbuild .harness/before "the previous tree"; pbuild .harness/after "after/"
  echo "the new build - each tree copied again, the harness's stylesheet in place of its own (this unit's line, for after/'s; the same for the previous tree's), built the same way:"
  copy "$PREV" .harness/before-new; copy after .harness/after-new
  run "$L_NEWB"; run "cp $NEWCSS .harness/before-new/$RS/$CSS"
  pbuild .harness/before-new "the previous tree's new build"; pbuild .harness/after-new "after/'s new build"
  echo "the four jars extracted (the README's line) - the class path the harness runs on:"
  for t in before after before-new after-new; do extract .harness/$t; done
  echo "the harness, compiled against after/'s own libraries - with -parameters:"
  echo "\$ $L_JAVAC"; rm -rf .harness/hc; (eval "$L_JAVAC") > .harness/javac.log 2>&1 < /dev/null || { cat .harness/javac.log >&3; die "the harness did not compile against after/'s libraries"; }
  echo "  exit 0 · its classes: $(cd .harness/hc && find . -name '*.class' | sed 's#^\./##' | sort | paste -sd' ' -)"
  echo "the files that differ, and the files only one tree has:"
  echo "\$ diff -rq -x target -x secrets .harness/before .harness/after"
  diff -rq -x target -x secrets .harness/before .harness/after | sed 's/^/  /' || true
  (cd after && find . -type f | sed 's#^\./##' | sort) > .harness/files.txt
  n=0; m=0; k=0; while IFS= read -r f; do m=$((m + 1)); if [ ! -e ".harness/before/$f" ]; then k=$((k + 1)); elif cmp -s ".harness/before/$f" ".harness/after/$f"; then n=$((n + 1)); fi; done < .harness/files.txt
  echo "  after/'s files: $m · byte for byte the previous tree's: $n · new: $k · those that differ: $((m - n - k))"
  f=$YML; echo "  $f: $(lines ".harness/before/$f") lines -> $(lines ".harness/after/$f")"; cdiff ".harness/before/$f" ".harness/after/$f"
  y=.harness/after/$YML; d=$(yline "$y" '---')
  echo "  where the keys sit in after/'s application.yaml (line numbers; the first document ends at the first ---):"
  echo "    web: line $(yline "$y" '  web:') · content's enabled: line $(yline "$y" '            enabled: true') · paths: line $(yline "$y" '            paths: /**') · cache's period: line $(yline "$y" '        period: 365d') · the first ---: line $d · the first document's spring: key, at its first column: line $(awk -v d="$d" 'NR < d && /^spring:$/ { print NR }' "$y" | paste -sd' ' -)"
  diff .harness/before/README.md .harness/after/README.md > .harness/file.diff || true
  echo "  README.md - the anchor's README: lines added $(grep -c '^> ' .harness/file.diff || true), removed $(grep -c '^< ' .harness/file.diff || true) - its new section and the history notes the change made false (not shown)"
  echo "  Boot's own metadata for the keys (spring-boot-autoconfigure-4.1.1.jar, META-INF/spring-configuration-metadata.json):"
  for k in spring.web.resources.chain.strategy.content.enabled spring.web.resources.chain.strategy.content.paths spring.web.resources.cache.period spring.web.resources.chain.enabled; do meta .harness/after/tiffinbox-web/target/extracted/lib/spring-boot-autoconfigure-4.1.1.jar "$k"; done
  echo "the new build's stylesheet against after/'s:"
  echo "\$ diff after/$RS/$CSS $NEWCSS"; diff "after/$RS/$CSS" "$NEWCSS" | sed 's/^/  /' || true
  echo "\$ md5 -q after/$RS/$CSS $NEWCSS"; md5 -q "after/$RS/$CSS" "$NEWCSS" | sed 's/^/  /'
  echo "  their bytes: $(wc -c < "after/$RS/$CSS" | tr -d ' ') and $(wc -c < "$NEWCSS" | tr -d ' ') · the new builds against their trees, the files that differ: $(diff -rq -x target -x secrets .harness/before .harness/before-new | grep -c . || true) and $(diff -rq -x target -x secrets .harness/after .harness/after-new | grep -c . || true)"
  libs .harness/before/$JARP > .harness/lb.txt; libs .harness/after/$JARP > .harness/la.txt
  echo "the executable jar's BOOT-INF/lib: $(wc -l < .harness/lb.txt | tr -d ' ') jars -> $(wc -l < .harness/la.txt | tr -d ' ') · the same names: $(cmp -s .harness/lb.txt .harness/la.txt && echo yes || echo no) · Spring MVC's among them: $(grep '^spring-webmvc-' .harness/la.txt | paste -sd' ' -)"; }

# ---- headers: the seven; what a static file comes with ---------------------------------------------------------------------------
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
# vals: the validators and the lifetime the last answer carried - each header present or not, from the headers curl wrote
vals() { echo "  $1 - Last-Modified: $(hv Last-Modified) · ETag: $(hv ETag) · Cache-Control: $(hv Cache-Control)"; }
headers() {
  echo "the seven - the previous tree, the README's run line, port 19521, a fresh JVM:"
  start "$(at .harness/before 19521 "$R_RUN")"; up 19521; ready 19521; seven 19521 .harness/before; cp .harness/responses.m.txt .harness/seven-before.txt; WARNS; logl 0 WARN
  echo "the seven - after/, the README's run line, port 19520, a fresh JVM:"
  start "$(at .harness/after 19520 "$R_RUN")"; up 19520; ready 19520; seven 19520 .harness/after; cp .harness/responses.m.txt .harness/seven-after.txt; WARNS; logl 0 WARN
  echo "the lines that moved - the previous tree's seven against after/'s, masked, line for line:"
  moved .harness/seven-before.txt .harness/seven-after.txt
  echo "what a static file comes with - the previous tree, the README's run line, port 19521:"
  start "$(at .harness/before 19521 "$R_RUN")"; up 19521; ready 19521
  echo "the page, and the stylesheet it links:"
  rq "$(gq 19521)"; vals "the page's validators and lifetime"
  rq "$(cq 19521 "$(lnk)")"; vals "the stylesheet's validators and lifetime"
  echo "  the file in the tree it came from: $(md5 -q ".harness/before/$RS/$CSS") · the body's md5 the same: $( [ "$(md5 -q .harness/body.out)" = "$(md5 -q ".harness/before/$RS/$CSS")" ] && echo yes || echo no)"
  echo "the stylesheet asked again as a cache that holds it asks - its own Last-Modified sent back (this unit's line):"
  rq "$(cq 19521 /css/tiffinbox.css "If-Modified-Since: $OLDLM")"
  WARNS; stop 19521 .harness/before; }

# ---- date: whose date ---------------------------------------------------------------------------------------------------------------
zdates() { python3 - "$1" <<'PY'
import collections, sys, zipfile
z = zipfile.ZipFile(sys.argv[1]); c = collections.Counter("%02d-%02d-%04d %02d:%02d" % (d[1], d[2], d[0], d[3], d[4]) for d in (i.date_time for i in z.infolist()))
print("  its entries: %d · each one's date as the listing gives it: %s" % (sum(c.values()), " · ".join("%s ×%d" % kv for kv in sorted(c.items()))))
PY
}
date_() { local a b
  echo "the root POM's fixed build time - the line, in the previous tree and in after/:"
  for t in before after; do echo "\$ grep -n outputTimestamp .harness/$t/pom.xml"; grep -n outputTimestamp ".harness/$t/pom.xml" | sed 's/^/  /'; done
  echo "the stylesheet's entry in two jars - the previous tree's and its new build's (unzip -l: its entry line; the listing's header and total lines, 4, not shown):"
  for t in before before-new; do echo "\$ unzip -l .harness/$t/$JARP BOOT-INF/classes/$CSS"; unzip -l ".harness/$t/$JARP" "BOOT-INF/classes/$CSS" | awk 'NR > 3 && $4 ~ /tiffinbox\.css$/' | sed 's/^ */  /'; zdates ".harness/$t/$JARP"; done
  echo "the previous tree, the README's run line, port 19521:"
  start "$(at .harness/before 19521 "$R_RUN")"; up 19521; ready 19521
  rq "$(cq 19521 /css/tiffinbox.css)"; a=$(hv Last-Modified); WARNS; stop 19521 .harness/before
  echo "its new build - the stylesheet with one line more - the README's run line, port 19522:"
  start "$(at .harness/before-new 19522 "$R_RUN")"; up 19522; ready 19522
  rq "$(cq 19522 /css/tiffinbox.css)"; b=$(hv Last-Modified)
  echo "  the two answers' Last-Modified, the same: $( [ "$a" = "$b" ] && echo yes || echo no) · the root POM's time, written as HTTP writes a date: $(python3 -c 'import datetime, email.utils, sys; print(email.utils.format_datetime(datetime.datetime.fromisoformat(sys.argv[1].replace("Z", "+00:00")), usegmt=True))' "$(sed -n 's/.*<project.build.outputTimestamp>\(.*\)<\/project.build.outputTimestamp>.*/\1/p' .harness/before-new/pom.xml)") - the same as theirs: $( [ "$a" = "$OLDLM" ] && echo yes || echo no)"
  echo "the new build asked as a cache that holds the OLD file asks - the date the previous build sent (this unit's line):"
  rq "$(cq 19522 /css/tiffinbox.css "If-Modified-Since: $a")"
  WARNS; stop 19522 .harness/before-new; }

# ---- versioned: A/B/A' - the content strategy -------------------------------------------------------------------------------------
# carries LINK FILE: whether the link's name is the stylesheet's name with FILE's md5 in it
carries() { local m; m=$(md5 -q "$2"); case $1 in "/css/tiffinbox-$m.css") echo yes ;; *) echo no ;; esac; }
# vrun TREE NEWTREE 'RUN LINE': TREE's page link (the anchor's own line) and its stylesheet's answers; then NEWTREE's
vrun() { local o
  start "$(at .harness/$1 19520 "$3")"; up 19520; ready 19520
  askl "$R_LINK" 19520; o=$LINK
  echo "\$ md5 -q .harness/$1/$RS/$CSS"; echo "  $(md5 -q ".harness/$1/$RS/$CSS") · the link's name carries it: $(carries "$o" ".harness/$1/$RS/$CSS")"
  rq "$(cq 19520 "$o")"; vals "its validators and lifetime"
  [ "$o" = /css/tiffinbox.css ] || { rq "$(cq 19520 /css/tiffinbox.css)"; vals "the plain name's validators and lifetime"; }
  WARNS; stop 19520 .harness/$1
  echo "  then .harness/$2 - its new build - the same line, port 19522:"
  start "$(at .harness/$2 19522 "$3")"; up 19522; ready 19522
  askl "$R_LINK" 19522
  echo "\$ md5 -q .harness/$2/$RS/$CSS"; echo "  $(md5 -q ".harness/$2/$RS/$CSS") · the link's name carries it: $(carries "$LINK" ".harness/$2/$RS/$CSS")"
  echo "  the link, against the previous build's: $( [ "$LINK" = "$o" ] && echo the same || echo different)"
  rq "$(cq 19522 "$LINK")"; vals "its validators and lifetime"
  if [ "$LINK" = "$o" ]; then echo "  asked as a cache that holds the previous build's file asks - that build's Last-Modified (this unit's line):"; rq "$(cq 19522 "$o" "If-Modified-Since: $OLDLM")"
  else echo "  the previous build's link, asked of this build:"; rq "$(cq 19522 "$o")"; fi
  WARNS; stop 19522 .harness/$2; }
versioned() {
  echo "A - after/ as shipped (the keys on), the README's run line, port 19520 - the page's link by the anchor's own line:"
  vrun after after-new "$R_RUN"
  echo "B - the content strategy off for this run (this unit's line), port 19520:"
  vrun after after-new "$L_OFF"
  echo "A' - A again, fresh JVMs, port 19520:"
  vrun after after-new "$R_RUN"
  echo "A' against A, its label aside, line for line the same: $(asame 'A - ' 'B - ' "A' - " "A' against A")"; }

# ---- etag: the validator that matches nothing ---------------------------------------------------------------------------------
etag() { local e
  echo "the handler that serves static files - after/, the README's routing-table line (mappings exposed for this run), port 19520:"
  start "$(at .harness/after 19520 "$R_MAPS")"; up 19520; ready 19520
  echo "\$ curl -s http://127.0.0.1:19520/actuator/mappings"
  curl -s http://127.0.0.1:19520/actuator/mappings 2> /dev/null < /dev/null | python3 -c '
import json, sys
d = json.load(sys.stdin); rows = []; n = 0
for ctx in d["contexts"].values():
    for r in ctx["mappings"]["dispatcherServlets"]["dispatcherServlet"]:
        n += 1
        if r.get("handler", "").startswith("ResourceHttpRequestHandler"): rows.append((r["predicate"], r["handler"]))
print("  the dispatcher servlet'"'"'s rows: %d · those whose handler is Spring MVC'"'"'s ResourceHttpRequestHandler: %d" % (n, len(rows)))
for p, h in rows: print("    %s -> %s" % (p, h))'
  askl "$R_LINK" 19520
  rq "$(cq 19520 "$LINK")"; e=$(hv ETag); vals "its validators and lifetime"
  echo "its ETag sent back alone (If-None-Match), the way a cache that holds this file asks:"
  rq "$(cq 19520 "$LINK" "If-None-Match: $e")"
  echo "If-None-Match: * (any copy at all):"
  rq "$(cq 19520 "$LINK" 'If-None-Match: *')"
  echo "both validators, the ETag and the date - what a browser sends:"
  rq "$(cq 19520 "$LINK" "If-Modified-Since: $OLDLM" "If-None-Match: $e")"
  echo "the date alone (If-Modified-Since):"
  rq "$(cq 19520 "$LINK" "If-Modified-Since: $OLDLM")"
  WARNS; stop 19520 .harness/after; }

# ---- devtools: DevTools' two resource keys against application.yaml; E/F/E' - the chain's cache ----------------------------------
dtrun() { start "$(at .harness/$1 19523 "$L_DEVT")"; up 19523; ready 19523
  settle; hk 0; echo "  listening on 35729 (Live Reload) now: $(listeners 35729)"
  rq "$(gq 19523)"; rq "$(cq 19523 "$(lnk)")"; vals "the stylesheet's validators and lifetime"
  WARNS; stop 19523 .harness/$1; }
# ccrun 'FOLDER LINE': the folder copy's stylesheet made after/'s again; TiffinBox on it; the page's link; the stylesheet replaced
# while it runs (this unit's line); the page's link again, and the stylesheet it names
ccrun() { run "cd .harness/fold && cp $RS/$CSS $TC/$CSS"
  start "$(at .harness/fold 19524 "$1")"; up 19524; ready 19524
  askl "$R_LINK" 19524
  run "cd .harness/fold && $L_EDIT"
  echo "\$ md5 -q .harness/fold/$TC/$CSS"; echo "  $(md5 -q ".harness/fold/$TC/$CSS")"
  askl "$R_LINK" 19524; rq "$(cq 19524 "$LINK")"
  WARNS; stop 19524 .harness/fold; }
devtools() { local k
  echo "the keys - Boot's metadata (spring-boot-autoconfigure-4.1.1.jar):"
  for k in spring.web.resources.cache.period spring.web.resources.chain.cache spring.web.resources.cache.cachecontrol.no-cache; do meta .harness/after/tiffinbox-web/target/extracted/lib/spring-boot-autoconfigure-4.1.1.jar "$k"; done
  echo "DevTools on the previous tree - its extracted jar with DevTools' jar (from \$M2) and the harness on its class path, Live Reload off, the harness's Keys joined, port 19523:"
  dtrun before
  echo "DevTools on after/ - the same line, port 19523:"
  dtrun after
  echo "a folder class path - after/'s build copied to .harness/fold, the web module's classes folder in place of its jar (this unit's folder line):"
  rm -rf .harness/fold; rsync -a --exclude secrets .harness/after/ .harness/fold/; tree .harness/fold
  echo "E - the resource chain's cache as Boot sets it, port 19524:"
  ccrun "$L_FOLD"
  echo "F - the chain's cache off for this run (this unit's line), port 19524:"
  ccrun "$L_CCF"
  echo "E' - E again, a fresh JVM, port 19524:"
  ccrun "$L_FOLD"
  echo "E' against E, its label aside, line for line the same: $(asame 'E - ' 'F - ' "E' - " "E' against E")"
  run "cd .harness/fold && cp $RS/$CSS $TC/$CSS"; }

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
  echo "  the shell is now in: $(where "$d1") · the copy's own token in its log: $(raw "$(head -1 .harness/mine/after/$TF)" .harness/ex-readme.log) times · WARN lines in its log: $(lvl WARN .harness/ex-readme.log) · ERROR lines: $(lvl ERROR .harness/ex-readme.log) · listening on 19528 now: $(listeners 19528)"
  echo "the solution's $(printf '%s\n' "$sol" | grep -c .) lines, next, in the same shell:"
  printf '%s\n' "$sol" | sed 's/^/  $ /'
  echo "  exit $e2 · what they printed:"; sed 's/^/    /' .harness/ex-sol.out
  echo "  the shell is now in: $(where "$d2") · the copy's own token in its log: $(raw "$(head -1 .harness/mine/after/$TF)" .harness/mine/run.log) times · WARN lines in its log: $(lvl WARN .harness/mine/run.log) · ERROR lines: $(lvl ERROR .harness/mine/run.log) · listening on 19528 now: $(listeners 19528)"
  echo "  the copy's tiffinbox-local.yaml: $(cat .harness/mine/after/tiffinbox-local.yaml) · the copy's stylesheet's md5: $(md5 -q .harness/mine/after/$RS/$CSS)"; }

# ---- browser: TiffinBox, then its new build on the same port; one Chrome tab - each claim with two witnesses -------------------------
cup() { local l i=0 a=""; while [ $i -lt 480 ]; do a=$(addrs "$cpid"); case " $a " in *":19529 "*) break ;; esac; kill -0 "$cpid" 2> /dev/null || break; sleep 0.25; i=$((i + 1)); done
  case " $a " in *":19529 "*) ;; *) die "Chrome never listened on 19529" ;; esac
  l=$(printf '%s\n' "$a" | tr ' ' '\n' | grep ':19529$' | paste -sd' ' -); echo "  Chrome's DevTools port: $l · loopback only: $(lb "$l")"; }
chrome() { local f; [ -e .harness/chrome ] && f=no || f=yes; rm -f .harness/netlog.json
  echo "\$ $L_CHROME"; (eval "exec $L_CHROME") > .harness/chrome.out 2>&1 < /dev/null & cpid=$!
  echo "  its profile, .harness/chrome, made fresh for this visitor (it did not exist before this line): $f"; cup; }
unchrome() { local i=0 e=0; echo "\$ $L_CLOSE"; (eval "$L_CLOSE") > .harness/close.out 2>&1 < /dev/null || true
  while kill -0 "$cpid" 2> /dev/null && [ $i -lt 60 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$cpid" 2> /dev/null && { killtree "$cpid"; die "Chrome still ran 15 s after Browser.close"; }
  wait "$cpid" || e=$?; cpid=""; [ "$(listeners 19529)" = 0 ] || die "something still listens on 19529"
  rm -rf .harness/chrome; echo "  Chrome exit $e · listening on 19529 now: 0 · its profile removed"
  echo "\$ $(nlq "$@")"; (eval "$(nlq "$@")") 2>&1 < /dev/null || true; }
# visit 'CDP LINE': the line printed and run - the page Chrome shows; Chrome's own record of the visit's requests (net.py); then the
# server's record: every harness line the requests printed (Dump), and the WARN and ERROR lines they added
visit() { local n0 w e; n0=$(mark); rm -f .harness/ev.json; echo "\$ $1"; (eval "$1") 2>&1 < /dev/null | sed 's/^/  /'
  echo "\$ ${L_NET/ 18431/ 19527}"; (eval "${L_NET/ 18431/ 19527}") 2>&1 < /dev/null; settle
  w=$(logl "$n0" WARN | grep -c . || true); e=$(logl "$n0" ERROR | grep -c . || true)
  echo "  the server's record:"; hk "$n0" | sed 's/^/  /'; echo "    WARN lines they added: $w · ERROR lines: $e"; }
# serve TREE 'LINE' WHAT: TiffinBox from TREE on 19527, the harness's classes on its class path
serve() { echo "  TiffinBox - $3, port 19527:"; start "$(at .harness/$1 19527 "$2")"; up 19527; ready 19527; }
# visitor LABEL TREE NEWTREE 'LINE' NOLD: Chrome fresh; NOLD visits of TREE (the first opens the tab, the others type the address
# again); TREE replaced by NEWTREE on the same port; the address typed again, then a reload - or, with NEWTREE "-", nothing more
visitor() { local k=2
  serve "$2" "$4" ".harness/$2"; chrome
  echo "visit 1 - the dashboard's address, typed into a new tab:"; visit "$(vq 19527)"
  if [ "$5" = 2 ]; then echo "visit 2 - the address typed again, the same TiffinBox:"; visit "$(aq 19527)"; k=3; fi
  if [ "$3" != - ]; then
    WARNS; stop 19527 ".harness/$2"; serve "$3" "$4" ".harness/$3 - the new build, on the same port"
    echo "  the new build's stylesheet, asked by curl at the plain name (no validator sent):"; rq "$(cq 19527 /css/tiffinbox.css)"
    echo "visit $k - the address typed again:"; visit "$(aq 19527)"
    if [ "$5" = 1 ]; then echo "visit $((k + 1)) - the page reloaded:"; visit "$L_RELOAD"; fi
    unchrome 19527; WARNS; stop 19527 ".harness/$3"
  else unchrome 19527; WARNS; stop 19527 ".harness/$2"; fi; }
browser() {
  echo "1 the previous tree - no keys - its class path (the README's line), Dump joined (the server's record of every request, whole), port 19527; Chrome headless, a profile of its own, sealed to 127.0.0.1 (its proxy a dead address, every name but 127.0.0.1 unresolvable), its DevTools protocol on 127.0.0.1:19529:"
  visitor 1 before before-new "$L_DUMP" 1
  echo "C (labelled) - the previous tree with Cache-Control: no-cache on its static files (this unit's line), a new visitor:"
  visitor C before before-new "$L_DUMPNC" 2
  echo "2 after/ - the keys - the same line as 1, a new visitor:"
  visitor 2 after after-new "$L_DUMP" 1
  echo "D (labelled) - after/ with Cache-Control: no-cache (this unit's line), a new visitor:"
  visitor D after - "$L_DUMPNC" 2
  echo "G (labelled) - the control for 1: the previous tree with its static files read from a folder this run writes (this unit's line), so the stylesheet's Last-Modified is seconds old, not weeks; a new visitor:"
  run "$L_FRESH"; FRESHD=$(LC_ALL=C date -u -r .harness/fresh/css/tiffinbox.css '+%a, %d %b %Y %H:%M:%S GMT')
  echo "  the file's time, as Last-Modified writes it: $FRESHD - written by the line above"
  serve before "$L_FRESHL" ".harness/before, its static files from .harness/fresh"; chrome
  echo "visit 1 - the dashboard's address, typed into a new tab:"; visit "$(vq 19527)"
  echo "visit 2 - the address typed again, the same TiffinBox, eight seconds later (a wait, not a witness):"
  echo "\$ sleep 8"; sleep 8; visit "$(aq 19527)"
  unchrome 19527; WARNS; stop 19527 .harness/before; rm -rf .harness/fresh; }

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
def named(t): return "tiffinbox" in t or "thymeleaf" in t.lower() or "Resource" in t
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
  if [ "$1" = '4 the image' ]; then [ "$(grep -c '^  docker port: ' .harness/blk.txt)" = 2 ] && [ "$(grep -cE '^  docker port: 18425/tcp -> 127\.0\.0\.1:19524$' .harness/blk.txt)" = 2 ] && echo yes || echo no
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
# froutes PORT: on a second start of a form - the page's link (the anchor's own line), the stylesheet it names, then asked by its
# date (If-Modified-Since) and by its ETag (If-None-Match); no log counted (a container's log is read only when it has stopped)
# lmwhere VALUE: where a Last-Modified falls - the root POM's time; a time inside this run's native build (its native step's start and
# end, read off the clock, never printed); or another time
lmwhere() { if [ "$1" = "$OLDLM" ]; then echo "the root POM's time"; return 0; fi
  python3 -c 'import email.utils, sys; t = email.utils.parsedate_to_datetime(sys.argv[1]).timestamp(); print("a time inside this run'"'"'s native build" if int(sys.argv[2]) <= t <= int(sys.argv[3]) else "another time")' "$1" "${NB_T0:-0}" "${NB_T1:-0}"; }
froutes() { local e c l s1 s2; askl "$R_LINK" "$1"; rq "$(cq "$1" "$LINK")" nolog; e=$(hv ETag); c=$(hv Cache-Control); l=$(hv Last-Modified)
  rq "$(cq "$1" "$LINK" "If-Modified-Since: $OLDLM")" nolog; s1=$(sed 's/^ *//; s/ .*//' .harness/curl.txt)
  rq "$(cq "$1" "$LINK" "If-None-Match: $e")" nolog; s2=$(sed 's/^ *//; s/ .*//' .harness/curl.txt)
  echo "  this form's answers: the link carries the file's md5: $( [ "$LINK" = "/css/tiffinbox-$H0.css" ] && echo yes || echo no) · Cache-Control: $c · ETag: $e · Last-Modified: $(lmwhere "$l") · asked with the root POM's time: $s1 · asked with its ETag: $s2"; }
dseven() { echo "\$ \$CURLSET $1 .harness/after/$TF"
  "$CURLSET" "$1" ".harness/after/$TF" | grep ' -> ' > .harness/responses.txt || true
  tsmask < .harness/responses.txt > .harness/responses.m.txt
  grep '^POST ' .harness/responses.m.txt | sed 's/^/  /' || echo "  (no POST line)"
  dgone "$BOX"; [ "$(listeners "$1")" = 0 ] || die "something still listens on $1"
  echo "  exit $LASTE · the seven responses: $(wc -l < .harness/responses.m.txt | tr -d ' ') lines · lines the timestamp mask changed: $(diff .harness/responses.txt .harness/responses.m.txt | grep -c '^<' || true) · md5 $(md5 -q .harness/responses.m.txt)"
  dlog "$BOX"; echo "  its log (docker logs): Boot's first line: $(first .harness/run.out) · the demo token 0 times · X-Shutdown-Token 0 times"
  docker rm "$BOX" > /dev/null; }
S466='466c20ed7e0d5439cb052f32ce09de1b'
forms() { local v
  echo "the native build - after/ copied to .harness/nat with a config tree; the README's two Maven lines, offline; \$GRAALVM_HOME names the GraalVM:"
  copy after .harness/nat
  nbuild .harness/nat; nlines .harness/nat.native.log; nresult .harness/nat.native.log
  echo "  file: $(file -b ".harness/nat/$BIN" | sed 's/ [A-Za-z0-9_]*$//') · the demo token in its bytes: $(raw "$TOKEN" ".harness/nat/$BIN")"
  echo "what Spring's AOT step registered - the previous tree built with the README's native-profile line too (.harness/natb), then its metadata against after/'s:"
  copy "$PREV" .harness/natb; pbuild .harness/natb "the previous tree, the profile native" "$R_PNAT"
  aotcmp .harness/natb .harness/nat
  echo "1 the jar - .harness/after, the README's run line, port 19520:"
  start "$(at .harness/after 19520 "$R_RUN")"; up 19520; ready 19520; tline; seven 19520 .harness/after
  echo "  then the stylesheet, on a second start of the jar:"
  start "$(at .harness/after 19520 "$R_RUN")"; up 19520; ready 19520; froutes 19520; stop 19520 .harness/after
  echo "2 the AOT jar - .harness/nat (the profile native's jar), the README's AOT line, port 19525:"
  start "$(at .harness/nat 19525 "$R_AOTRUN")"; up 19525; ready 19525; tline; seven 19525 .harness/nat
  echo "  then the stylesheet, on a second start of the AOT jar:"
  start "$(at .harness/nat 19525 "$R_AOTRUN")"; up 19525; ready 19525; froutes 19525; stop 19525 .harness/nat
  echo "3 the binary - .harness/nat, the README's line, port 19526:"
  start "$(at .harness/nat 19526 "$R_BIN")"; up 19526; ready 19526; tline; seven 19526 .harness/nat
  echo "  then the stylesheet, on a second start of the binary:"
  start "$(at .harness/nat 19526 "$R_BIN")"; up 19526; ready 19526; froutes 19526; stop 19526 .harness/nat
  echo "4 the image - after/'s Dockerfile (the README's build line, this script's tag), the README's run line with your user, published on 127.0.0.1:19524:"
  image
  dstart "$(drun .harness/after 19524)"; ready 19524 "$BOX"; dbind 19524
  dseven 19524
  echo "  then the stylesheet, on a second container of the image - TiffinBox listens on 18425 inside it:"
  dstart "$(drun .harness/after 19524)"; ready 19524 "$BOX"; dbind 19524
  froutes 19524
  post 19524 .harness/after; dgone "$BOX"; [ "$(listeners 19524)" = 0 ] || die "something still listens on 19524"
  dlog "$BOX"; echo "  exit $LASTE · its log (docker logs): the demo token 0 times · X-Shutdown-Token 0 times · WARN lines: $(lvl WARN .harness/run.out) · ERROR lines: $(lvl ERROR .harness/run.out)"
  docker rm "$BOX" > /dev/null
  echo "four forms, one tree: the seven (masked) $(grep -cE "^  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 0 · md5 $S466\$" .harness/cap.raw) of 4 times $S466 · the link with the file's md5, a year's lifetime and its ETag: $(grep -cE "^  this form's answers: the link carries the file's md5: yes · Cache-Control: max-age=31536000 · ETag: W/\"$H0\" · " .harness/cap.raw) of 4 · Last-Modified the root POM's time: $(grep -c "^  this form's answers: .* · Last-Modified: the root POM's time · " .harness/cap.raw) of 4 · asked with that time, 304: $(grep -c "^  this form's answers: .* · asked with the root POM's time: 304 · " .harness/cap.raw) of 4 · asked with its ETag, 200: $(grep -c "^  this form's answers: .* · asked with its ETag: 200\$" .harness/cap.raw) of 4"
  echo "  loopback, form by form: the jar $(lbk '1 the jar') · the AOT jar $(lbk '2 the AOT jar') · the binary $(lbk '3 the binary') · the image, published on 127.0.0.1 alone $(lbk '4 the image')"
  echo "  the locale: options on the binary's and the image's run lines: $(printf '%s\n%s\n' "$(at .harness/nat 19526 "$R_BIN")" "$(drun .harness/after 19524)" | grep -o 'user\.language\|user\.country' | wc -l | tr -d ' ') (none passed: the binary runs as the README writes it, the image as its ENTRYPOINT, java -jar)"; }

cap change change
cap headers headers
cap date date_
cap versioned versioned
cap etag etag
cap devtools devtools
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
SHIP="README.md exercise/README.md exercise/solution/SOLUTION.md receipts.md5 harness/shutdown.sh harness/cdp.mjs harness/net.py harness/netlog.py $NEWCSS $HWS"
NBIN=0
for f in .r-*.out $SHIP .harness/nat/$BIN; do [ -f "$f" ] || continue; case $f in .harness/nat*) NBIN=$((NBIN + 1)) ;; esac; [ "$(raw "$TOKEN" "$f")" = 0 ] || die "$f holds the demo token, raw"; done
[ "$NBIN" = 1 ] || die "one binary was built, $NBIN were checked"
# a capture may print two dates, and only these: the build's fixed time as Last-Modified writes it, and as unzip's listing writes it
for f in .r-*.out; do ! grep -qE '/Users/|/private/|/home/|/var/folders/' "$f" || die "$f holds an absolute path"; [ -z "${GRAALVM_HOME:-}" ] || ! grep -qF "$GRAALVM_HOME" "$f" || die "$f holds the GraalVM's folder"; ! grep -qE 'c[0-9]-unit[0-9]|unit ?[0-9]' "$f" || die "$f holds a unit number"; ! grep -qE ' (with PID|started by) ' "$f" || die "$f holds Boot's process line"; ! sed "s/$OLDLM//g; s/09-15-2026 00:00//g" "$f" | grep -qE '^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T|"timestamp":"?[0-9]|(exec|handler|task|utility)-[0-9]|GMT|CES?T|<div id=.created|[A-Z][a-z][a-z], [0-9][0-9] [A-Z][a-z][a-z] |[A-Z][a-z][a-z] [A-Z][a-z][a-z] [0-9]+ [0-9][0-9]:[0-9][0-9]|[0-9][0-9]-[0-9][0-9]-20[0-9][0-9]' || die "$f holds a log line's time, a timestamp, a date or a thread's number"; ! grep -q "^$(printf '\t')at " "$f" || die "$f shows a stack frame"; ! grep -qE 'SpringCGLIB\$\$[0-9]' "$f" || die "$f holds a generated class's number"; ! grep -qE 'sha256:[0-9a-f]{64}' "$f" || [ "$(grep -cE 'sha256:[0-9a-f]{64}' "$f")" = "$(grep -cE 'eclipse-temurin(:25-jre)?@sha256:[0-9a-f]{64}' "$f")" ] || die "$f holds an ID other than the base image's digest"; ! grep -qE ':(8080|35729)([^0-9]|$)' "$f" || die "$f shows a bind on 8080 or 35729"; ! grep -q $'\r' "$f" || die "$f holds a carriage return"; ! grep -qiE '<html|<!doctype' "$f" || die "$f shows an HTML page whole"; ! grep -qE 'Chrome/[0-9]|v="[0-9]' "$f" || die "$f holds Chrome's version"; ! grep -qE 'Macintosh|Mac OS X|Windows NT|X11;|Linux x86|sec-ch-ua-platform: "' "$f" || die "$f holds the platform (User-Agent or sec-ch-ua-platform)"; done
# R.109: a JVM with DevTools on its class path exits 1 - Java's launcher, whose main thread DevTools ends with its SilentExitException
# (the app runs on in restartedMain; README.md, "Found on the way"); every other JVM a capture stops exits 0
for f in .r-*.out; do [ "$(grep -cE '^  exit [1-9][0-9]* · listening on [0-9]+ now: 0$' "$f" || true)" = "$(grep -cE '^  exit 1 · listening on 19523 now: 0$' "$f" || true)" ] || die "$f: a JVM without DevTools exited non-zero"; done
[ "$(grep -cE '^  exit 1 · listening on 19523 now: 0$' .r-devtools.out)" = 2 ] && ! grep -qE '^  exit 0 · listening on 19523 now: 0$' .r-devtools.out || die "devtools: each of DevTools' 2 JVMs on 19523 exits 1, none 0 (R.109)"
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
echo "  tokens: 0 raw copies in $(ls .harness/raw-* | wc -l | tr -d ' ') raw capture runs, in $(ls .r-*.out | wc -l | tr -d ' ') captures; the demo token 0 in the logs of every JVM that served ($LOGS here; the published captures' $NL) and every container ($CLOGS here), the image's layers, the READMEs, the harness, the exercise, receipts.md5 and the binary; no absolute path, no GraalVM folder, no unit number, no process line, no log time, no timestamp, no date but the build's fixed time, no thread number, no stack frame, no whole HTML page, no Chrome version, no 8080 or 35729, no carriage return in any capture; no Boot 3 error key; no harness class in the anchor; no bare wait; no stop by name; every java line's locale pinned; every docker run publishes on 127.0.0.1 alone; every URL a capture runs is 127.0.0.1's"

Z00=' · WARN lines it added: 0 · ERROR lines: 0'
NLC='
'
H1=$(md5 -q "$NEWCSS")                                  # the new build's stylesheet's md5, computed (H0: after/'s, above)
V0="/css/tiffinbox-$H0.css"; V1="/css/tiffinbox-$H1.css"
[ "$H0" = 10ba2401fd96e2e382866a731d207fc4 ] && [ "$H1" = c10b71bcdaab1872b81fd1f9d1965761 ] || die "the two stylesheets' md5s are not the ones this README and the exercise name"
CSSH="  HTTP/1.1 200 · Last-Modified: $OLDLM · Accept-Ranges: bytes · Content-Type: text/css · Content-Length: 200 · Date: (the time - not printed)"
VERH() { printf '%s\n' "  HTTP/1.1 200 · Cache-Control: max-age=31536000 · Last-Modified: $OLDLM · ETag: W/\"$1\" · Accept-Ranges: bytes · Content-Type: text/css · Content-Length: $2 · Date: (the time - not printed)"; }
PLAINY="  HTTP/1.1 200 · Cache-Control: max-age=31536000 · Last-Modified: $OLDLM · Accept-Ranges: bytes · Content-Type: text/css · Content-Length: 200 · Date: (the time - not printed)"
C304="  curl's line: 304 · 0 bytes$Z00"
NOF='  body: no file - curl wrote none'

# "Two files changed: application.yaml's three keys ... above the first dashes ... the new build: one line more"
CO=$(cat .r-change.out)
for l in '  built the previous tree · offline: yes · exit 0' '  built after/ · offline: yes · exit 0' "  built the previous tree's new build · offline: yes · exit 0" "  built after/'s new build · offline: yes · exit 0" \
         "  after/'s files: 33 · byte for byte the previous tree's: 31 · new: 0 · those that differ: 2" '  tiffinbox-web/src/main/resources/application.yaml: 106 lines -> 122' '    @@ -64,0 +65,16 @@' \
         '    +            enabled: true' '    +            paths: /**' '    +        period: 365d' \
         '  spring.web.resources.chain.strategy.content.enabled - type Boolean · default false · Whether to enable the content Version Strategy.' \
         '  spring.web.resources.chain.strategy.content.paths - type String[] · default ["/**"] · List of patterns to apply to the content Version Strategy.' \
         '  spring.web.resources.cache.period - type Duration · default null · Cache period for the resources served by the resource handler. If a duration suffix is not specified, seconds will be used. Can be overridden by the '"'"'spring.web.resources.cache.cachecontrol'"'"' properties.' \
         '  > footer { color: #555; }' "  $H0" "  $H1" '  their bytes: 200 and 224 · the new builds against their trees, the files that differ: 1 and 1' \
         "the executable jar's BOOT-INF/lib: 61 jars -> 61 · the same names: yes · Spring MVC's among them: spring-webmvc-7.0.9.jar"; do has "$CO" "$l" "change"; done
[ "$(n change '^  Files ')" = 2 ] && [ "$(n change '^  Only in ')" = 0 ] && [ "$(n change '^    \+')" = 16 ] && [ "$(n change '^    -')" = 0 ] || die "change: two files differ (the README, application.yaml); the YAML gains 16 lines and loses none"
WL=$(printf '%s\n' "$CO" | grep '^    web: line ') || die "change: the keys' lines"
set -- $(printf '%s\n' "$WL" | grep -oE 'line [0-9]+' | awk '{ print $2 }'); [ $# = 6 ] && [ "$6" -lt "$1" ] && [ "$1" -lt "$2" ] && [ "$2" -lt "$3" ] && [ "$3" -lt "$4" ] && [ "$4" -lt "$5" ] || die "change: the keys must sit in the first document - spring: < web: < enabled < paths < period < the first --- ($WL)"
has "$CO" "    web: line 72 · content's enabled: line 77 · paths: line 78 · cache's period: line 80 · the first ---: line 115 · the first document's spring: key, at its first column: line 23" "change: the keys' line numbers (R.87)"
echo "  change: application.yaml +16 lines (three keys and their comment) at 72-80, above the first --- at 115; content's enabled false and paths [/**] by default (Boot's metadata), cache.period none; 31 of 33 files byte for byte; the new build = one line, 200 -> 224 bytes; 61 libraries, the same"

# "The seven: the same, byte for byte ... a stylesheet comes with its date ... no lifetime, no ETag ... asked with its date: three oh four"
HD=$(cat .r-headers.out)
[ "$(cnt "$HD" "  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 0 · md5 466c20ed7e0d5439cb052f32ce09de1b")" = 2 ] || die "headers: the seven 466c20ed on both trees, the mask 0"
has "$HD" '  lines that differ: 0 · the same, byte for byte: 7 (1 2 3 4 5 6 7)' "headers: the same, byte for byte: 7"
[ "$(cnt "$HD" '    WARN o.s.web.servlet.PageNotFound: Request method '"'"'GET'"'"' is not supported')" = 2 ] || die "headers: one WARN each, PageNotFound's"
H3=$(blk headers "what a static file comes with" "")
has "$H3" '  the page: <title>Dashboard · TiffinBox</title> · 22 lines, 926 bytes - not shown but its stylesheet link <link rel="stylesheet" href="/css/tiffinbox.css">' "headers: the page links the plain name"
has "$H3" "  the page's validators and lifetime - Last-Modified: none · ETag: none · Cache-Control: none" "headers: the page has no validator"
[ "$(seg "$H3" "$(cq 19521 /css/tiffinbox.css)")" = "$(printf '%s\n' "  curl's line: 200 · 200 bytes$Z00" "$CSSH" "  body: 200 bytes · md5 $H0" "  the stylesheet's validators and lifetime - Last-Modified: $OLDLM · ETag: none · Cache-Control: none" "  the file in the tree it came from: $H0 · the body's md5 the same: yes")" ] || die "headers: the stylesheet - Last-Modified, Accept-Ranges, Content-Type, Content-Length; no Cache-Control, no ETag; the file's own bytes"
[ "$(seg "$H3" "$(cq 19521 /css/tiffinbox.css "If-Modified-Since: $OLDLM")")" = "$(printf '%s\n' "$C304" "  HTTP/1.1 304 · Last-Modified: $OLDLM · Date: (the time - not printed)" "$NOF")" ] || die "headers: its own date sent back - 304, 0 bytes, no body file"
has "$H3" "  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0" "headers: 0 and 0"
echo "  headers: the seven $S466 on both trees, the same, byte for byte: 7; the page links /css/tiffinbox.css and carries no validator; the stylesheet 200 - Last-Modified, Accept-Ranges, Content-Type, Content-Length, no Cache-Control, no ETag; its date sent back -> 304, 0 bytes"

# "Whose date? The build's ... the new stylesheet, the same date ... a cache holding the old file is told: not modified"
DA=$(cat .r-date.out)
[ "$(cnt "$DA" '  32:    <project.build.outputTimestamp>2026-09-15T00:00:00Z</project.build.outputTimestamp>')" = 2 ] || die "date: the root POM's fixed time in both trees"
for l in '  200  09-15-2026 00:00   BOOT-INF/classes/static/css/tiffinbox.css' '  224  09-15-2026 00:00   BOOT-INF/classes/static/css/tiffinbox.css' \
         "  the two answers' Last-Modified, the same: yes · the root POM's time, written as HTTP writes a date: $OLDLM - the same as theirs: yes" "  body: 200 bytes · md5 $H0" "  body: 224 bytes · md5 $H1"; do has "$DA" "$l" "date"; done
[ "$(cnt "$DA" "  its entries: 218 · each one's date as the listing gives it: 09-15-2026 00:00 ×218")" = 2 ] || die "date: every entry of both jars carries the one date"
[ "$(seg "$DA" "$(cq 19522 /css/tiffinbox.css "If-Modified-Since: $OLDLM")")" = "$(printf '%s\n' "$C304" "  HTTP/1.1 304 · Last-Modified: $OLDLM · Date: (the time - not printed)" "$NOF")" ] || die "date: the new build answers the old date 304, 0 bytes"
echo "  date: outputTimestamp 2026-09-15T00:00:00Z in both POMs; both jars' 218 entries dated 09-15-2026 00:00; the previous tree and its new build: 200 and 224 bytes, other md5s, the same Last-Modified (the POM's time); the new build, asked with the old date -> 304, 0 bytes"

# "A: a name with the file's md5 ... a year ... the new build, a new name ... B: the plain name, three oh four ... A' = A"
VA=$(blk versioned "A - " "B - "); VB=$(blk versioned "B - " "A' - "); VA2=$(blk versioned "A' - " "A' against A")
has "$VA" "  $V0" "versioned A: the page links the file's own md5"; has "$VA" "  $V1" "versioned A: the new build links its own"
[ "$(cnt "$VA" "  $H0 · the link's name carries it: yes")" = 1 ] && [ "$(cnt "$VA" "  $H1 · the link's name carries it: yes")" = 1 ] && has "$VA" "  the link, against the previous build's: different" "versioned A: a new name" || die "versioned A: each link carries its file's md5, computed"
[ "$(seg "$VA" "$(cq 19520 "$V0")" | sed -n 1,3p)" = "$(printf '%s\n' "  curl's line: 200 · 200 bytes$Z00" "$(VERH "$H0" 200)" "  body: 200 bytes · md5 $H0")" ] || die "versioned A: the versioned answer - max-age=31536000, the ETag, the file"
[ "$(seg "$VA" "$(cq 19520 /css/tiffinbox.css)" | sed -n 1,2p)" = "$(printf '%s\n' "  curl's line: 200 · 200 bytes$Z00" "$PLAINY")" ] || die "versioned A: the plain name still answers 200 - a year's lifetime, no ETag"
[ "$(seg "$VA" "$(cq 19522 "$V1")" | sed -n 1,3p)" = "$(printf '%s\n' "  curl's line: 200 · 224 bytes$Z00" "$(VERH "$H1" 224)" "  body: 224 bytes · md5 $H1")" ] || die "versioned A: the new build's new name, its file"
seg "$VA" "$(cq 19522 "$V0")" | grep -qxF "  body: {\"detail\":\"No static resource ${V0#/}.\",\"instance\":\"$V0\",\"status\":404,\"title\":\"Not Found\"}" || die "versioned A: the previous build's name on the new build - 404"
[ "$(cnt "$VB" '  /css/tiffinbox.css')" = 2 ] && has "$VB" "  the link, against the previous build's: the same" "versioned B" || die "versioned B: the plain link on both builds"
[ "$(seg "$VB" "$(cq 19522 /css/tiffinbox.css "If-Modified-Since: $OLDLM")")" = "$(printf '%s\n' "$C304" "  HTTP/1.1 304 · Cache-Control: max-age=31536000 · Last-Modified: $OLDLM · Date: (the time - not printed)" "$NOF")" ] || die "versioned B: the new build answers the old date 304"
printf '%s\n' "$VB" | grep -qxF "\$ $(at .harness/after 19520 "$L_OFF")" && printf '%s\n' "$VA2" | grep -qxF "\$ $(at .harness/after 19520 "$R_RUN")" || die "versioned: B's and A''s \$ lines"
x versioned "^A' against A, its label aside, line for line the same: yes\$"
echo "  versioned: A - the link /css/tiffinbox-<the file's md5>.css, max-age=31536000 and a weak ETag; the plain name still 200 with a year's lifetime; the new build's link differs, the old name 404 there; B - the plain link on both, the new build 304 for the old date; A' = A"

# "The ETag matches nothing: sent back alone, as a star, beside the date - two hundred and the whole file; the date alone: three oh four"
ET=$(cat .r-etag.out)
has "$ET" '    /** -> ResourceHttpRequestHandler [classpath [META-INF/resources/], classpath [resources/], classpath [static/], classpath [public/], ServletContext [/]]' "etag: Spring MVC's resource handler serves /**"
[ "$(seg "$ET" "$(cq 19520 "$V0")" | sed -n 1,2p)" = "$(printf '%s\n' "  curl's line: 200 · 200 bytes$Z00" "$(VERH "$H0" 200)")" ] || die "etag: the versioned answer, asked plainly - 200 and its ETag"
for q in "$(cq 19520 "$V0" "If-None-Match: W/\"$H0\"")" "$(cq 19520 "$V0" 'If-None-Match: *')" "$(cq 19520 "$V0" "If-Modified-Since: $OLDLM" "If-None-Match: W/\"$H0\"")"; do
  [ "$(seg "$ET" "$q" | sed -n 1,3p)" = "$(printf '%s\n' "  curl's line: 200 · 200 bytes$Z00" "$(VERH "$H0" 200)" "  body: 200 bytes · md5 $H0")" ] || die "etag: If-None-Match ($q) - 200 and the whole file"; done
[ "$(seg "$ET" "$(cq 19520 "$V0" "If-Modified-Since: $OLDLM")")" = "$(printf '%s\n' "$C304" "  HTTP/1.1 304 · Cache-Control: max-age=31536000 · Last-Modified: $OLDLM · Date: (the time - not printed)" "$NOF")" ] || die "etag: the date alone - 304"
has "$ET" "  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0" "etag: 0 and 0"
echo "  etag: /** served by ResourceHttpRequestHandler; its ETag alone, *, and beside the date -> 200 and 200 bytes each; the date alone -> 304"

# "DevTools: the period zero - no-store - and the chain's cache off; application.yaml's year wins ... the chain's cache keeps an old name"
DT=$(cat .r-devtools.out); DP=$(blk devtools "DevTools on the previous tree" "DevTools on after/"); DQ=$(blk devtools "DevTools on after/" "a folder class path")
for l in '  spring.web.resources.cache.period - type Duration · default null · Cache period for the resources served by the resource handler. If a duration suffix is not specified, seconds will be used. Can be overridden by the '"'"'spring.web.resources.cache.cachecontrol'"'"' properties.' '  spring.web.resources.chain.cache - type Boolean · default true · Whether to enable caching in the Resource chain.'; do has "$DT" "$l" "devtools: the metadata"; done
for b in "$DP" "$DQ"; do for l in '     1 Keys the JVM'"'"'s locale: en_US' '     2 Keys the property source devtools: 10 keys' '    11 Keys   spring.web.resources.cache.period = 0' '    12 Keys   spring.web.resources.chain.cache = false' '    13 Keys property sources whose name says devtools: 1' '    17 Keys the environment'"'"'s spring.web.resources.chain.cache: false' '  listening on 35729 (Live Reload) now: 0' '  exit 1 · listening on 19523 now: 0'; do has "$b" "$l" "devtools: DevTools' keys"; done; done
[ "$(printf '%s\n' "$DP" | grep -cE '^ +[0-9]+ Keys   [a-z]')" = 10 ] || die "devtools: DevTools' ten keys, each printed"
has "$DP" "    16 Keys the environment's spring.web.resources.cache.period: 0" "devtools: on the previous tree, DevTools' 0"
has "$DP" "  the stylesheet's validators and lifetime - Last-Modified: $OLDLM · ETag: none · Cache-Control: no-store" "devtools: the period 0 is no-store"
has "$DP" "  HTTP/1.1 200 · Cache-Control: no-store · Last-Modified: $OLDLM · Accept-Ranges: bytes · Content-Type: text/css · Content-Length: 200 · Date: (the time - not printed)" "devtools: the answer's own Cache-Control, no-store"
has "$DQ" "    16 Keys the environment's spring.web.resources.cache.period: 365d" "devtools: on after/, application.yaml's 365d beats DevTools' 0"
has "$DQ" "  the stylesheet's validators and lifetime - Last-Modified: $OLDLM · ETag: W/\"$H0\" · Cache-Control: max-age=31536000" "devtools: after/'s year under DevTools"
FE=$(blk devtools "E - " "F - "); FF=$(blk devtools "F - " "E' - "); FE2=$(blk devtools "E' - " "E' against E")
lk() { printf '%s\n' "$1" | grep -E '^  /css/' | sed 's/^  //' | paste -sd'|' -; }
[ "$(lk "$FE")" = "$V0|$V0" ] && seg "$FE" "$(cq 19524 "$V0")" | grep -qxF "  curl's line: 404 · 181 bytes$Z00" || die "devtools E: the chain's cache on - the page keeps the old name, and it answers 404"
[ "$(lk "$FF")" = "$V0|$V1" ] && seg "$FF" "$(cq 19524 "$V1")" | grep -qxF "  curl's line: 200 · 224 bytes$Z00" || die "devtools F: the cache off - the new name, the new file"
[ "$(lk "$FE2")" = "$(lk "$FE")" ] && x devtools "^E' against E, its label aside, line for line the same: yes\$" || die "devtools E': E's links"
printf '%s\n' "$FF" | grep -qxF "\$ cd .harness/fold && ${L_CCF/18431/19524}" && printf '%s\n' "$FE2" | grep -qxF "\$ cd .harness/fold && ${L_FOLD/18431/19524}" || die "devtools: F's and E''s \$ lines"
echo "  devtools: DevTools 10 keys on this class path - cache.period 0 (no-store on the previous tree) and chain.cache false; on after/ the environment reads 365d (application.yaml beats DevTools' default), max-age=31536000; exit 1 each, 35729 free; E: the chain's cache keeps the old name, 404; F: the new name, 200; E' = E"

# the exercise's end state: the README's commands, then the solution's, in ONE env -i shell
XS=$(blk exercise "the README's" "the solution's"); XE=$(blk exercise "the solution's" '')
X_SHIP='the stylesheet: /css/tiffinbox.css · 304 · 0 bytes'; X_END="the stylesheet: $V1 · 200 · 224 bytes"
has "$XS" "    $X_SHIP" "exercise: as shipped"; has "$XE" "    $X_END" "exercise: the solution"
awk '/^\*\*Done\*\*/ { f = 1 } f' exercise/README.md | grep -qxF -- "$X_END" || die "exercise/README.md: Done names no such line"
grep -qxF -- "$X_END" exercise/solution/SOLUTION.md || die "SOLUTION.md: the measured run shows no such line"
grep -qF -- "\`$X_SHIP\`" exercise/README.md || die "exercise/README.md: the shipped line's answer is not named"
for b in "$XS" "$XE"; do printf '%s\n' "$b" | grep -qE "^  the shell is now in: this unit's folder · the copy's own token in its log: 0 times · WARN lines in its log: 0 · ERROR lines: 0 · listening on 19528 now: 0\$" || die "exercise: 0 tokens, 0 and 0, the port free, the shell in this unit's folder"; done
has "$XE" "  the copy's tiffinbox-local.yaml: spring.web.resources.chain.strategy.content.enabled: true · the copy's stylesheet's md5: $H1" "exercise: the key switched on, the new stylesheet"
EXQ="Your turn: the README's new stylesheet still gets three oh four. Switch on content versioning, read the page's link, and ask again."
grep -qxF -- "**Your turn:** ${EXQ#Your turn: }" exercise/README.md || die "exercise/README.md: the spoken exercise line"
[ "$(printf '%s\n' "$EXQ" | wc -w | tr -d ' ')" -le 25 ] || die "exercise: the spoken line is over 25 words"
echo "  exercise: one env -i shell - the README as written (the strategy off in the copy's own file) -> 304, 0 bytes; the solution -> the new name, 200, 224 bytes; the shell in this unit's folder after each"

# "In Chrome: no lifetime, so Chrome keeps the old stylesheet and asks nobody - even on reload ... no-cache: it asks, and the server says
#  not modified ... the versioned name: a new build, a new name, fetched once ... the ETag matches nothing"
if [ -f .r-browser.out ]; then BR=$(cat .r-browser.out)
  B1=$(blk browser "1 the previous tree" "C (labelled)"); BC=$(blk browser "C (labelled)" "2 after/"); B2=$(blk browser "2 after/" "D (labelled)"); BD=$(blk browser "D (labelled)" "G (labelled)"); BG=$(blk browser "G (labelled)" "")
  [ "$(cnt "$BR" '  its profile, .harness/chrome, made fresh for this visitor (it did not exist before this line): yes')" = 5 ] || die "browser: a fresh profile for each of the five visitors"
  [ "$(cnt "$BR" "  Chrome's DevTools port: 127.0.0.1:19529 · loopback only: yes")" = 5 ] && [ "$(cnt "$BR" '  Chrome exit 0 · listening on 19529 now: 0 · its profile removed')" = 5 ] || die "browser: Chrome's port loopback, exit 0, the profile removed - five times"
  [ "$(cnt "$BR" "  Chrome's NetLog - every address it connected to or tried, its own background requests included: 127.0.0.1 only: yes · ports 19527 among them: yes")" = 5 ] || die "browser: the seal, five times"
  [ "$(cnt "$BR" '    WARN lines they added: 0 · ERROR lines: 0')" = 13 ] || die "browser: 0 and 0 for each of the thirteen visits"
  PG() { printf '%s\n' "  the page Chrome shows: Dashboard · TiffinBox · its address: /dashboard · its stylesheet: $1 · its footer, coloured by it: $2"; }
  OLDC='rgb(0, 0, 0)'; NEWC='rgb(85, 85, 85)'
  vb() { awk -v a="visit $2 - " 'index($0, a) == 1 { f = 1; next } f && (/^visit / || /^  WARN lines in this run/) { exit } f' <<< "$1"; }
  # 1: the previous tree
  V=$(vb "$B1" 1); has "$V" "$(PG /css/tiffinbox.css "$OLDC")" "browser 1, visit 1: the page, the plain name"
  has "$V" '    Stylesheet GET /css/tiffinbox.css - from the server: 200 text/css' "browser 1, visit 1: the stylesheet fetched"; has "$V" "      the answer's: Last-Modified: $OLDLM · Content-Length: 200" "browser 1, visit 1: no lifetime, no ETag"
  has "$V" '      24 Dump            > GET /css/tiffinbox.css' "browser 1, visit 1: the server's record of the stylesheet"
  has "$B1" "  body: 224 bytes · md5 $H1" "browser 1: the new build serves the new stylesheet (curl)"
  for k in 2 3; do V=$(vb "$B1" $k); has "$V" "$(PG /css/tiffinbox.css "$OLDC")" "browser 1, visit $k: the old colour on the new build"
    has "$V" "    Stylesheet GET /css/tiffinbox.css - from Chrome's own cache, nothing sent: 200" "browser 1, visit $k: from Chrome's cache"
    [ "$(printf '%s\n' "$V" | grep -c ' Dump  *> GET ')" = 1 ] && has "$V" '       1 Dump            > GET /dashboard' "browser 1, visit $k" || die "browser 1, visit $k: the server saw the page only - no stylesheet request"; done
  has "$(vb "$B1" 3)" "      the headers Chrome sent that ask about a kept copy: Cache-Control: max-age=0 · its other headers: 14, not shown" "browser 1, visit 3: a reload asks again for the page alone"
  # C: no-cache on the previous tree
  V=$(vb "$BC" 2); has "$V" '    Stylesheet GET /css/tiffinbox.css - from the server: 304 text/css' "browser C, visit 2: Chrome's record, 304"
  has "$V" "      the headers Chrome sent that ask about a kept copy: If-Modified-Since: $OLDLM · its other headers: 13, not shown" "browser C, visit 2: the date Chrome sent"
  has "$V" '      39 Dump            < 304 GET /css/tiffinbox.css' "browser C, visit 2: the server's 304"; has "$V" '      42 Dump            <   body: 0 bytes' "browser C, visit 2: no body"
  has "$V" "      32 Dump            >   If-Modified-Since: $OLDLM" "browser C, visit 2: the server read the date"
  V=$(vb "$BC" 3); has "$V" "$(PG /css/tiffinbox.css "$OLDC")" "browser C, visit 3: the old colour on the new build"
  has "$V" '    Stylesheet GET /css/tiffinbox.css - from the server: 304 text/css' "browser C, visit 3: the new build says 304"; has "$V" '      39 Dump            < 304 GET /css/tiffinbox.css' "browser C, visit 3: the server's 304"
  # 2: after/
  V=$(vb "$B2" 1); has "$V" "$(PG "$V0" "$OLDC")" "browser 2, visit 1: the versioned name"
  has "$V" "      the answer's: Cache-Control: max-age=31536000 · ETag: W/\"$H0\" · Last-Modified: $OLDLM · Content-Length: 200" "browser 2, visit 1: a year's lifetime"
  V=$(vb "$B2" 2); has "$V" "$(PG "$V1" "$NEWC")" "browser 2, visit 2: the new build's name, the new colour"
  has "$V" "    Stylesheet GET $V1 - from the server: 200 text/css" "browser 2, visit 2: fetched"; has "$V" "      24 Dump            > GET $V1" "browser 2, visit 2: the server's record"
  V=$(vb "$B2" 3); has "$V" "$(PG "$V1" "$NEWC")" "browser 2, visit 3: the new colour after a reload"
  has "$V" "    Stylesheet GET $V1 - from Chrome's own cache, nothing sent: 200" "browser 2, visit 3: from Chrome's cache"; [ "$(printf '%s\n' "$V" | grep -c ' Dump  *> GET ')" = 1 ] || die "browser 2, visit 3: the server saw the page only"
  # D: after/ with no-cache
  V=$(vb "$BD" 2); has "$V" "      the headers Chrome sent that ask about a kept copy: If-Modified-Since: $OLDLM · If-None-Match: W/\"$H0\" · its other headers: 13, not shown" "browser D, visit 2: both validators"
  has "$V" "    Stylesheet GET $V0 - from the server: 200 text/css" "browser D, visit 2: 200"; has "$V" '      50 Dump            <   body: 200 bytes' "browser D, visit 2: the whole file again"
  # G, the control for 1: "with no lifetime, Chrome guesses one from how old Last-Modified is" - a date seconds old, asked again 8 s later
  FM_="(the file time of this run: masked)"
  has "$BG" "\$ $L_FRESH" "browser G: the folder's file written by the README's line"; has "$BG" "  the file's time, as Last-Modified writes it: $FM_ - written by the line above" "browser G: the file's time, masked"
  has "$BG" "\$ $(at .harness/before 19527 "$L_FRESHL")" "browser G: the static files from .harness/fresh"
  V=$(vb "$BG" 1); has "$V" "$(PG /css/tiffinbox.css "$OLDC")" "browser G, visit 1: the page, the plain name"
  has "$V" '    Stylesheet GET /css/tiffinbox.css - from the server: 200 text/css' "browser G, visit 1: the stylesheet fetched"; has "$V" "      the answer's: Last-Modified: $FM_ · Content-Length: 200" "browser G, visit 1: no lifetime, the fresh date"
  V=$(vb "$BG" 2); has "$V" '$ sleep 8' "browser G, visit 2: eight seconds after visit 1"
  has "$V" '    Stylesheet GET /css/tiffinbox.css - from the server: 304 text/css' "browser G, visit 2: Chrome asked again - 304"
  has "$V" "      the headers Chrome sent that ask about a kept copy: If-Modified-Since: $FM_ · its other headers: 13, not shown" "browser G, visit 2: the date Chrome sent"
  printf '%s\n' "$V" | grep -qE '^ +[0-9]+ Dump +< 304 GET /css/tiffinbox\.css$' && printf '%s\n' "$V" | grep -qE "^ +[0-9]+ Dump +>   If-Modified-Since: \(the file time of this run: masked\)\$" || die "browser G, visit 2: the server's record - the date read, 304"
  [ "$(printf '%s\n' "$BG" | grep -c "$OLDLM")" = 0 ] || die "browser G: the build's date nowhere in G - its file's own time only"
  [ "$(printf '%s\n' "$BR" | grep -c 'Stylesheet GET .* - from the server: 304 ')" = 3 ] || die "browser: three 304s in Chrome's record, C's two and G's"
  echo "  browser: five visitors, each a fresh sealed profile, NetLog 127.0.0.1 only; 1 - no lifetime: the new build's stylesheet never asked for, the old colour, reload too; C - no-cache: If-Modified-Since -> 304 in both records, the new build's 304 keeps the old colour; 2 - the new name fetched, the new colour, reload from the cache; D - both validators -> 200 and the whole file; G - a date seconds old: 8 s later Chrome asks again, 304"; fi

# "Every form ... the jar, the AOT jar, the image: the same; the binary: its own date"
if [ -f .r-forms.out ]; then FM=$(cat .r-forms.out)
  x forms '^  exit 0 · BUILD SUCCESS · stages it printed: 8 of the 8 it announces · its lines that say the metadata repository was downloaded over http, or failed to: 0 · offline: yes$'
  x forms '^  file: Mach-O 64-bit executable · the demo token in its bytes: 0$'
  x forms "^  Spring's generated metadata \(spring-aot/main/resources/META-INF/native-image/com\.tiffinbox/tiffinbox-web/reachability-metadata\.json\) - the previous tree's against after/'s: reflection entries 687 -> 690 · types only the previous tree registers: none · only after/: 3 · entries that differ: 0\$"
  has "$FM" '    only after/: org.springframework.boot.webmvc.autoconfigure.WebMvcAutoConfiguration$ResourceChainCustomizerConfiguration - 0 methods' "forms: AOT registers the resource chain's configuration"
  has "$FM" "four forms, one tree: the seven (masked) 4 of 4 times $S466 · the link with the file's md5, a year's lifetime and its ETag: 4 of 4 · Last-Modified the root POM's time: 3 of 4 · asked with that time, 304: 3 of 4 · asked with its ETag, 200: 4 of 4" "forms: every form serves the versioned stylesheet; the binary's date is its own"
  has "$(blk forms '3 the binary - ' '4 the image')" "  this form's answers: the link carries the file's md5: yes · Cache-Control: max-age=31536000 · ETag: W/\"$H0\" · Last-Modified: a time inside this run's native build · asked with the root POM's time: 200 · asked with its ETag: 200" "forms: the binary's Last-Modified is its native build's time; the POM's time gets 200 there"
  has "$FM" '  loopback, form by form: the jar yes · the AOT jar yes · the binary yes · the image, published on 127.0.0.1 alone yes' "forms: loopback"
  [ "$(n forms "^  Boot's first line: Starting AOT-processed TiffinBoxServer v1\.0\.0 using Java 25\.0\.4\.1\$")" = 2 ] && [ "$(n forms "^  Boot's first line: Starting AOT-processed TiffinBoxServer using Java 25\.0\.4\.1\$")" = 2 ] || die "forms: the AOT jar and the binary, AOT-processed, both starts"
  [ "$(n forms '^  inside the container, listening: \[::\]:18425$')" = 2 ] && [ "$(n forms '^  docker port: 18425/tcp -> 127\.0\.0\.1:19524$')" = 2 ] || die "forms: the image, two containers, 18425 inside, published on 127.0.0.1:19524 alone"
  x forms '^  its lines that say pull: 0 · '
  x forms '^  the image saved \(docker save\): [1-9][0-9]* blobs, its [1-9][0-9]* layers among them, each read whole \(gzip ones unpacked\) · the demo token in them: 0$'
  echo "  forms: 8 of 8 stages, offline, Mach-O, 0 tokens; AOT 687 -> 690 (the resource chain's three configuration classes); the jar, the AOT jar, the binary, the image: the seven 4 of 4, the versioned link, a year and the ETag 4 of 4, the ETag -> 200 4 of 4; Last-Modified the POM's time and its 304 in 3 - the binary's is a time inside its own native build, and that date gets 200; loopback form by form; 0 tokens in the image's layers"; fi

cmp -s after/README.md ../c6-tiffinbox/README.md || echo "  (after/README.md and ../c6-tiffinbox/README.md differ - the anchor has moved past this unit's after/)" >&3
[ -z "$unpub" ] || die "no published hash for:$unpub - check the captures, then copy the md5s above into receipts.md5 and run again"
echo "c6-unit23: every capture 3/3 and = published; every spoken number asserted; 0 raw demo tokens in every capture, every log, the container's log, the image's layers and the binary; nothing of this run left on Docker"
