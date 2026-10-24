#!/bin/bash
XPATH=$PATH                                           # the PATH you started this with: the exercise's own shell gets it
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25.0.4.1 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"   # the Chrome app on the author's Mac: point it at yours
# GRAALVM_HOME names a GraalVM JDK 25 (README.md, "The GraalVM"): the native build reads it. Without it, this script makes every
# capture that needs no GraalVM, filling .m2-demo on the way, then stops before the native build.
# Course 6 · Serving HTML: Thymeleaf - this unit's receipts. The anchor changes: tiffinbox-web's POM gains Boot's Thymeleaf starter;
# DashboardPage (a @Controller) answers GET /dashboard for a client that ranks HTML first, GET /customers/new (a form) and POST
# /customers with a form's body (redirect-after-POST); four templates - fragments, dashboard, customer-form, error/5xx - and one
# stylesheet; a runtime hint for the native image. Nine captures, each run three times and hashed; cap() DIES when a hash differs from
# receipts.md5; every number the video says is asserted at the bottom by a check that can fail; the demo token is masked (gsub), and
# the checks count 0 raw copies of it in every capture, in the log of every run - the container's included - in every file this unit
# ships, in the binary and in the image's layers.
#   change     the previous tree against after/: the files that differ and the new ones, the POM's diff, DashboardPage's code, the
#              templates and the stylesheet, Boot's metadata for the template keys, the jar's libraries and classes
#   negotiate  the seven on both trees, each on a fresh JVM, line for line; the routing table on both (/actuator/mappings, exposed for
#              one run); then one URL, two answers: /dashboard for curl's own Accept, for JSON, for HTML alone and for Chrome's whole
#              Accept header (sent by curl; the browser capture shows Chrome sends it); /customers/new for JSON and for HTML; the
#              page with a request's language named
#   fragments  the two pages' head, header and footer, line for line; the template lines that put them there
#   form       the form; a valid POST (302 and its Location), the dashboard after it; the four rules broken - in the JVM's language and
#              in German; letters for a number; a name that is taken; the JSON POST beside it; the request-body lesson's POST without
#              its Content-Type
#   errors     a refusal nobody handles - a name longer than the table allows - for HTML and for curl; a copy whose dashboard template
#              misspells a name; C (labelled): a copy with templates/error/404.html, asked for HTML and with Chrome's Accept
#   devtools   DevTools on the class path (its property source, read by the harness's Keys); A/B/A' - spring.thymeleaf.cache, a
#              template edited while TiffinBox runs from a folder class path; C (labelled): spring.template.provider.cache, the error
#              page added while it runs
#   exercise   exercise/README.md's commands, then exercise/solution/SOLUTION.md's, read from the files and run as written, one after
#              the other in ONE shell a viewer could have: env -i, /bin/bash, started in this folder
#   browser    TiffinBox with Dump (the server's record of every page request, whole) and headless Chrome, a profile of its own made
#              fresh for this run, sealed to 127.0.0.1: the dashboard typed into the address bar; the form filled and sent; the form
#              sent breaking four rules - each claim with two witnesses, Chrome's own record and the server's
#   forms      the native build of after/; what Spring's AOT step registers, on the previous tree and on after/; then four forms -
#              the jar, the AOT jar, the binary, the image: each one's address, the seven (masked), exit 0; then, on a second start of
#              each, every page: the dashboard, the form, four rules broken, a valid POST and the dashboard after it, the error page,
#              and the JSON POST
# "The previous tree" is before/, the link to ../c6-unit16/after (the anchor before this change: the problem-detail lesson's frozen
# tree), COPIED under .harness/before; after/ is this unit's frozen copy of ../c6-tiffinbox after the change, COPIED under
# .harness/after. This script never writes into another unit's folder, and never builds a frozen tree in place. Every run of
# TiffinBox starts in a folder under .harness/ that holds a config tree with a fake token (secrets/), as the README asks - the
# container's too, mounted read-only. Commands are printed exactly as they run: each goes through eval. "$CURLSET" is the comparison
# set since the secrets lesson (../c5-unit11/curlset.sh: the seven requests, POST /shutdown with the token's header read from the
# file). "$M2" is this unit's own repository, .m2-demo. "$CHROME" is the Chrome app (above). The harness - harness/probe/web/*.java
# (compiled with -parameters): Dump, Keys, and Trace (the CORS lesson's, byte for byte) - is the course's, never TiffinBox's: outside
# com.tiffinbox, joined by --spring.main.sources on the extracted jar's class path; harness/exercise/dashboard.html (the exercise's
# template, one name misspelt) and harness/c404/404.html (C's error page) are copied into copies, never into after/; harness/cdp.mjs
# drives Chrome over its DevTools protocol (node's own WebSocket); harness/net.py reads Chrome's record of a visit's page requests;
# harness/netlog.py (the CORS lesson's, byte for byte) reads Chrome's NetLog; harness/shutdown.sh is POST /shutdown with the token read
# from its file. Every run passes options only. The seven always run on a fresh JVM, first.
# The locale: the JVM ignores LC_ALL on macOS - every JVM this script starts has its locale pinned on its run line (-Duser.language=en
# -Duser.country=US, before -jar or -cp), and the checks refuse a java line without it; Keys prints the JVM's locale. Hibernate
# Validator's messages and Thymeleaf's Content-Language follow the request's Accept-Language when it names one - each capture says
# which it sent (none: the JVM's, pinned). Chrome runs with --lang=en-US, and its requests say so. The binary takes no JVM options.
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
# "<user>"; a Tomcat request thread's number, inside a message, "tomcat-handler-<n>"; Chrome's version in its User-Agent and its
# sec-ch-ua brand list - in every line of every capture. Spring's error timestamp becomes "…" (both forms). A page (HTML) is never
# printed whole: its <title>, its <h1>, its line and byte counts, and the lines a capture names (the filter, pagef, declares them);
# Boot's Whitelabel page as its <h1> and its error line, its created date masked; a JSON answer as its bytes. A run's log lines are
# printed from their logger on; a WARN or ERROR record as its level, logger and message, then its exception line, its frames bounded
# ("over 40") and its other lines counted. The harness's lines (Trace) are printed in the order they ran, numbered from 1. curl's
# header lines lose their carriage return; a Date header's value is not printed. No image, container or ID is printed but the base
# image's digest. No duration is captured: the native build's seconds, and the 20-minute bound, go to the terminal only.
# Ports (brief ⚑1, 19510-19519): after/'s jar 19510 · the previous tree 19511 · a folder class path (devtools A/B/A' and C, errors'
# copies) 19512 · DevTools 19513 · the AOT jar 19514 · the image 19515 · the binary 19516 · the browser's TiffinBox 19517 · the
# exercise 19518 · Chrome's DevTools port 19519. 18425 (TiffinBox's default), 8080 (Tomcat's) and 35729 (DevTools' Live Reload) are
# checked free too, and never bound on this machine (18425 only inside a container).
# Docker names (no unit number): the image tiffinbox-pages:1.0.0 and the container tiffinbox-pages. Each is checked absent before
# the first run - a name already there may be yours, and this script removes only what it creates - and removed on every exit.
set -e
# bash 5.2 and later turn an & in the replacement of ${x/pattern/replacement} into the matched text (patsub_replacement, on by
# default). Switched off, so /bin/bash 3.2 (./receipts.sh) and a newer bash (bash receipts.sh) run the same commands.
shopt -u patsub_replacement 2> /dev/null || true
export LC_ALL=C
cd "$(dirname "$0")"
# One run at a time: two runs share .harness/, the ports and the Docker names, and one would corrupt the other.
mkdir .r-lock 2> /dev/null || { echo "  *** another receipts.sh is running in this folder (.r-lock exists) - if none is, rmdir .r-lock ***"; exit 1; }
IMG=tiffinbox-pages:1.0.0; BOX=tiffinbox-pages
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
INTR=""; trap 'INTR=1; exit 130' INT TERM
exec 3>&1                                            # die() speaks to the terminal even inside a redirected capture
die() { echo "  *** $* ***" >&3; exit 1; }
java -version 2>&1 | grep -q 'version "25' || die "JDK 25 needed; JAVA_HOME gives: $(java -version 2>&1 | head -1)"
for t in python3 curl rsync lsof unzip javac docker openssl; do command -v $t > /dev/null || die "$t is needed"; done
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
[ -L before ] && [ "$(readlink before)" = ../c6-unit16/after ] || die "before must be the link to ../c6-unit16/after - the anchor before this change"
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
DTJ='"$M2/org/springframework/boot/spring-boot-devtools/4.1.1/spring-boot-devtools-4.1.1.jar"'   # DevTools' jar, in .m2-demo
# The demo token. FAKE, and meant to look it: it guards nothing but a demo server on 127.0.0.1 that every capture stops. It is
# written into .harness/*/secrets/ (git-ignored) when this script runs, and no capture prints it: see mask().
TOKEN=not-a-real-token-for-the-pages
[ ${#TOKEN} = 30 ] || die "the demo token must be 30 characters: the published captures name its length"
CURLSET=../c5-unit11/curlset.sh
[ -f "$CURLSET" ] || die "$CURLSET is missing"
HWS='harness/probe/web/Dump.java harness/probe/web/Keys.java harness/probe/web/Trace.java'
XT=harness/exercise/dashboard.html                    # the exercise's template: after/'s, one name misspelt
C404=harness/c404/404.html                           # C's error page: templates/error/404.html, in a copy only
for f in harness/shutdown.sh harness/cdp.mjs harness/net.py harness/netlog.py $XT $C404 $HWS exercise/README.md exercise/solution/SOLUTION.md README.md; do [ -f "$f" ] || die "$f is missing"; done
[ "$(ls harness/probe/web | paste -sd' ' -)" = 'Dump.java Keys.java Trace.java' ] || die "harness/probe/web holds another file: javac compiles all of it"
for f in harness/probe/web/Trace.java harness/netlog.py harness/shutdown.sh; do cmp -s "$f" "../c6-unit19/$f" || die "$f is not the CORS lesson's (../c6-unit19/$f), byte for byte"; done
[ ! -e after/$RS/templates/error/404.html ] || die "after/ holds templates/error/404.html - it is C's, a copy's only"

listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
for p in 18425 8080 35729 19510 19511 19512 19513 19514 19515 19516 19517 19518 19519; do
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
R_POST=$(readme "curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '{\"name\":\"Asha\",\"mealsPerDay\":2,\"pricePerMeal\":110,\"mealType\":\"VEG\"}' http://127.0.0.1:18431/customers")
R_PD=$(readme "curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' http://127.0.0.1:18431/customers/Nobody")
# this unit's lines in the anchor's README: the page, and the form's POST
R_PAGE=$(readme "curl -s -H 'Accept: text/html' http://127.0.0.1:18431/dashboard")
R_FORM=$(readme "curl -s -w ' %{http_code} · Location: [%header{location}]\n' -H 'Content-Type: application/x-www-form-urlencoded' --data 'name=Lata&mealsPerDay=2&pricePerMeal=120&mealType=VEG' http://127.0.0.1:18431/customers")
WS=" -w ' %{http_code}\n'"; WT=" -w ' %{http_code} · Content-Type: [%{content_type}]\n'"; WL_=" -w ' %{http_code} · Location: [%header{location}]\n'"
DH=" -D .harness/head.txt -o .harness/body.html"     # this unit's: the headers and the body each to a file, read by the filters
bodyof() { local b=${1#*--data \'}; printf '%s\n' "${b%%\' http://*}"; }
B_ASHA=$(bodyof "$R_POST"); B_LATA=$(bodyof "$R_FORM")
[ "$B_ASHA" = '{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' ] && [ "$B_LATA" = 'name=Lata&mealsPerDay=2&pricePerMeal=120&mealType=VEG' ] || die "the request bodies"
# the form bodies this unit sends, each made from Lata's and asserted: the four rules broken; letters for a number; a name longer than
# the table's column (VARCHAR(60), tiffinbox-core's Database.java) - 61 letters
B_BAD='name=&mealsPerDay=9&pricePerMeal=0&mealType=LUNCH'
B_TWO=${B_LATA/name=Lata&mealsPerDay=2/name=Om&mealsPerDay=two}
LONGN=$(printf '%061d' 0 | tr 0 A); B_LONG=${B_LATA/name=Lata/name=$LONGN}
[ "$B_TWO" = 'name=Om&mealsPerDay=two&pricePerMeal=120&mealType=VEG' ] && [ ${#LONGN} = 61 ] && [ "${B_LONG#name=}" != "$B_LONG" ] || die "the form bodies"
grep -q 'name          VARCHAR(60) NOT NULL UNIQUE,' after/tiffinbox-core/src/main/java/com/tiffinbox/Database.java || die "the customer table's name column is no longer VARCHAR(60)"
# This unit's own lines (README.md, "The commands this unit adds") - each asserted to be exactly that
mine() { grep -m1 -xF -- "$1" README.md > /dev/null || die "README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
JL='-Duser.language=en -Duser.country=US'
FOLD='"tiffinbox-web/target/classes:tiffinbox-web/target/extracted/lib/*" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431'
CHROMEA='text/html,application/xhtml+xml,application/xml;q=0.9,image/jxl,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7'
L_RUNL=$(mine "java $JL -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431")
L_CPL=$(mine "java $JL -cp \"tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*\" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431")
L_MAPS=$(mine "$L_RUNL --management.endpoints.web.exposure.include=health,prometheus,mappings")
L_FOLD=$(mine "java $JL -cp $FOLD")
L_TCF=$(mine "$L_FOLD --spring.thymeleaf.cache=false")
L_TPF=$(mine "$L_FOLD --spring.template.provider.cache=false")
L_DEVT=$(mine "java $JL -cp \"tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:\$M2/org/springframework/boot/spring-boot-devtools/4.1.1/spring-boot-devtools-4.1.1.jar:../hc\" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431 --spring.devtools.livereload.enabled=false --spring.main.sources=probe.web.Keys")
L_JAVAC=$(mine "javac -parameters -d .harness/hc -cp \".harness/after/tiffinbox-web/target/extracted/lib/*\" $HWS")
L_PAGE=$(mine "curl -s$DH$WT -H 'Accept: text/html' http://127.0.0.1:18431/dashboard")
L_FORM=$(mine "curl -s$DH$WT -H 'Content-Type: application/x-www-form-urlencoded' --data '$B_LATA' http://127.0.0.1:18431/customers")
L_EDIT=$(mine "sed -i '' 's/rendered on the server/edited while it runs/' $TC/templates/fragments.html")
L_CHROME=$(mine "\"\$CHROME\" --headless=new --user-data-dir=\"\$PWD/.harness/chrome\" --no-first-run --no-default-browser-check --disable-background-networking --disable-component-update --disable-sync --disable-domain-reliability --use-mock-keychain --password-store=basic --lang=en-US --proxy-server=http://127.0.0.1:9 --host-resolver-rules='MAP * ~NOTFOUND, EXCLUDE 127.0.0.1' --remote-debugging-address=127.0.0.1 --remote-debugging-port=19519 --log-net-log=\"\$PWD/.harness/netlog.json\" about:blank")
L_OPEN=$(mine "node harness/cdp.mjs 19519 open http://127.0.0.1:18431/dashboard .harness/ev.json")
L_SEND=$(mine "node harness/cdp.mjs 19519 form http://127.0.0.1:18431/customers/new .harness/ev.json 'name=Kiran&mealsPerDay=1&pricePerMeal=130&mealType=VEGAN'")
L_CLOSE=$(mine "node harness/cdp.mjs 19519 close")
L_NET=$(mine "python3 harness/net.py .harness/ev.json 18431")
L_NETLOG=$(mine "python3 harness/netlog.py .harness/netlog.json 18431")
# The derivations, each asserted
P_='java '; Q_="java $JL "; r=${R_RUN/"$P_"/$Q_}; r2=${R_CP/"$P_"/$Q_}
[ "$r" = "$L_RUNL" ] && [ "$r2" = "$L_CPL" ] && [ "$L_MAPS" = "${R_MAPS/"$P_"/$Q_}" ] || die "the pinned lines must be the anchor's run, class-path and routing-table lines with $JL after java, and nothing else"
P_='"tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:'; Q_='"tiffinbox-web/target/classes:'; r=${L_CPL/"$P_"/$Q_}; [ "$r" = "$L_FOLD" ] || die "the folder line must be the pinned class-path line with the web module's classes folder in place of its jar, and nothing else"
for l_ in "$L_TCF" "$L_TPF"; do o_=${l_#"$L_FOLD "}; case $o_ in --*=*) ;; *) die "a folder line with one option more: $l_" ;; esac; [ "${o_#* }" = "$o_" ] || die "one option, no more: $l_"; done
O_TCF=${L_TCF#"$L_FOLD "}; O_TPF=${L_TPF#"$L_FOLD "}
r=${L_DEVT/:\$M2\/org\/springframework\/boot\/spring-boot-devtools\/4.1.1\/spring-boot-devtools-4.1.1.jar:..\/hc\"/\"}; r=${r% --spring.devtools.livereload.enabled=false --spring.main.sources=probe.web.Keys}; [ "$r" = "$L_CPL" ] || die "the DevTools line must be the pinned class-path line with DevTools' jar and the harness added, Live Reload off and Keys joined, and nothing else"
[ "${L_JAVAC#* -cp \"*\" }" = "$HWS" ] || die "the harness's javac line must compile the three files in harness/probe/web, and nothing else"
P_='curl -s '; Q_="curl -s$DH$WT "; r=${R_PAGE/"$P_"/$Q_}; [ "$r" = "$L_PAGE" ] || die "the page line must be the anchor's with the headers and the body sent to files and curl's status and Content-Type printed, and nothing else"
r=${R_FORM/"$WL_"/$DH$WT}; [ "$r" = "$L_FORM" ] || die "the form line must be the anchor's with the headers and the body sent to files and its -w changed, and nothing else"
off() { local c=${2/mvn -B /mvn -o -B -Dmaven.repo.local=\"\$M2\" }
  [ -n "$3" ] && c=${c/ $3/ -DskipTests clean $3}
  printf 'cd %s && %s\n' "$1" "$c"; }
dev() { local c=${1#cd * && }; c=${c/ -o -B -Dmaven.repo.local=\"\$M2\" / -B }; c=${c/ -DskipTests clean / }; printf '%s\n' "$c"; }
# at DIR PORT 'README LINE': the README's line run from DIR, its port 18431 made PORT - and a java line with the JVM's locale pinned
# right after "java" (this unit's pinned lines show the form, and at() must give them back)
at() { local l=${3/--tiffinbox.port=18431/--tiffinbox.port=$2}; case $l in 'java -Djarmode=tools '*|"java $JL "*) ;; 'java '*) l="java $JL ${l#java }" ;; esac; printf 'cd %s && %s\n' "$1" "$l"; }
# hcp DIR PORT CLASSES: the README's class-path line from DIR, its port made PORT, the harness's classes added (../hc), CLASSES joined
hcp() { local c; c=$(at "$1" "$2" "$R_CP"); c=${c/lib\/\*\"/lib\/*:..\/hc\"}; printf '%s --spring.main.sources=%s\n' "$c" "$3"; }
url() { printf '%s\n' "${1/:18431\//:$2/}"; }
qurl() { local u="http://127.0.0.1:$1$2"; case $2 in *[\;\?\&\*\{\}\ ]*) u="'$u'" ;; esac; printf '%s\n' "$u"; }
# tq PORT PATH ['ACCEPT']: the problem-detail lesson's line - the body, the status and curl's Content-Type - its path PATH and, when
# given, one Accept header; with none, curl's own Accept: */*
tq() { local c=${R_PD% http://*} h=""; [ -z "${3:-}" ] || h=" -H 'Accept: $3'"; printf '%s%s %s\n' "$c" "$h" "$(qurl "$1" "$2")"; }
# pq PORT 'BODY': the request-body lesson's POST line with curl's Content-Type printed, its body BODY
pq() { local c=${R_POST/"$WS"/$WT} P_="$B_ASHA" Q_="$2"; c=${c/:18431\//:$1/}; c=${c/"$P_"/$Q_}; printf '%s\n' "$c"; }
# nq PORT: the request-body lesson's POST line without its Content-Type header - curl's --data then names a form's type - its headers
# and body sent to files as this unit's lines send them
nq() { local c=${R_POST/"$WS"/$DH$WT} P_=" -H 'Content-Type: application/json'"; c=${c/"$P_"/}; printf '%s\n' "${c/:18431\//:$1/}"; }
# gq PORT PATH ['ACCEPT' | none] ['HEADER']: this unit's page line, its path PATH; its Accept ACCEPT (text/html unless named; none:
# no Accept header - curl's own */*); one header more, HEADER, after it
gq() { local c=${L_PAGE/:18431\//:$1/} P_="/dashboard" Q_="$2" a=" -H 'Accept: text/html'" b; c=${c/"$P_"/$Q_}
  case "${3:-}" in '') b=$a ;; none) b="" ;; *) b=" -H 'Accept: $3'" ;; esac; [ -z "${4:-}" ] || b="$b -H '$4'"; printf '%s\n' "${c/"$a"/$b}"; }
# fq PORT 'BODY' ['HEADER']: this unit's form line, its body BODY, and one header more after its Content-Type
fq() { local c=${L_FORM/:18431\//:$1/} P_="$B_LATA" Q_="$2" k=" -H 'Content-Type: application/x-www-form-urlencoded'" h=""; c=${c/"$P_"/$Q_}; [ -z "${3:-}" ] || { h="$k -H '$3'"; c=${c/"$k"/$h}; }; printf '%s\n' "$c"; }
oq() { local c=${L_OPEN/19519 open http:\/\/127.0.0.1:18431\/dashboard/19519 open http://127.0.0.1:$1$2}; printf '%s\n' "$c"; }
sq() { local c=${L_SEND/127.0.0.1:18431\//127.0.0.1:$1/} P_="'name=Kiran&mealsPerDay=1&pricePerMeal=130&mealType=VEGAN'" Q_="'$2'"; printf '%s\n' "${c/"$P_"/$Q_}"; }
nlq() { printf '%s\n' "${L_NETLOG% 18431} $*"; }
exe() { printf '%s\n' "$1" | sed -E 's/&& (([A-Z_]+=[^ ]* )*)/\&\& \1exec /'; }
UARG='--user "$(id -u):$(id -g)"'
dbuild() { local c=${R_DBUILD/docker build -t tiffinbox-docker:1.0.0 /docker build --progress=plain -t $IMG }; printf 'cd %s && %s\n' "$1" "$c"; }
drun() { local c=${R_DRUN/--name tiffinbox /--name $BOX $UARG }; c=${c/127.0.0.1:18431:18425/127.0.0.1:$2:18425}; c=${c/% tiffinbox-docker:1.0.0/ $IMG}; printf 'cd %s && %s\n' "$1" "$c"; }
undock() { local c=${1#cd * && }; c=${c/--progress=plain /}; c=${c/" $UARG"/}; c=${c//$IMG/tiffinbox-docker:1.0.0}; c=${c/--name $BOX /--name tiffinbox }; c=${c/127.0.0.1:1951?:18425/127.0.0.1:18431:18425}; printf '%s\n' "$c"; }
[ "$(undock "$(dbuild .harness/x)")" = "$R_DBUILD" ] || die "not the README's build line with the declared changes: $(dbuild .harness/x)"
[ "$(undock "$(drun .harness/x 19515)")" = "$R_DRUN" ] || die "not the README's run line with the declared changes: $(drun .harness/x 19515)"
C_PRE=$(off .harness/pre "$R_INSTALL" install)
for c in "$C_PRE" "$(off .harness/x "$R_PLAIN" package)" "$(off .harness/x "$R_PNAT" package)" "$(off .harness/x "$R_NATIVE")"; do
  r=$(dev "$c"); [ "$r" = "$R_PLAIN" ] || [ "$r" = "$R_PNAT" ] || [ "$r" = "$R_INSTALL" ] || [ "$r" = "$R_NATIVE" ] || die "not a README line with the offline changes: $c"; done
[ "$(exe "$(at .harness/x 19510 "$R_RUN")")" = "cd .harness/x && exec ${L_RUNL/18431/19510}" ] && [ "$(at .harness/x 18431 "$R_CP")" = "cd .harness/x && $L_CPL" ] && [ "$(at .harness/x 18431 "$L_FOLD")" = "cd .harness/x && $L_FOLD" ] && [ "$(at .harness/x 19516 "$R_BIN")" = 'cd .harness/x && tiffinbox-web/target/tiffinbox-web --tiffinbox.port=19516' ] || die "at(): the pinned lines are not README.md's, or the binary's line got the JVM's options"
[ "$(gq 18431 /dashboard)" = "$L_PAGE" ] && [ "$(fq 18431 "$B_LATA")" = "$L_FORM" ] && [ "$(gq 19510 /dashboard none)" = "curl -s$DH$WT http://127.0.0.1:19510/dashboard" ] && [ "$(gq 19510 /dashboard text/html 'Accept-Language: de')" = "curl -s$DH$WT -H 'Accept: text/html' -H 'Accept-Language: de' http://127.0.0.1:19510/dashboard" ] || die "gq()"
[ "$(fq 19510 "$B_BAD" 'Accept-Language: de')" = "curl -s$DH$WT -H 'Content-Type: application/x-www-form-urlencoded' -H 'Accept-Language: de' --data '$B_BAD' http://127.0.0.1:19510/customers" ] && [ "$(nq 19510)" = "curl -s$DH$WT --data '$B_ASHA' http://127.0.0.1:19510/customers" ] && [ "$(tq 18431 /customers/Nobody)" = "$R_PD" ] || die "fq(), nq() or tq()"
[ "$(oq 18431 /dashboard)" = "$L_OPEN" ] && [ "$(sq 18431 'name=Kiran&mealsPerDay=1&pricePerMeal=130&mealType=VEGAN')" = "$L_SEND" ] && [ "$(nlq 18431)" = "$L_NETLOG" ] || die "oq(), sq() or nlq()"
echo "  the commands: after/README.md gives the 18 lines this script runs or derives from; README.md the 17 this unit adds"

# ---- build: before the captures - after/'s native install (it fills .m2-demo on a fresh clone); the harness compiled ------------
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
for a in org/springframework/boot/spring-boot-starter-thymeleaf/4.1.1/spring-boot-starter-thymeleaf-4.1.1.jar org/thymeleaf/thymeleaf-spring6/3.1.5.RELEASE/thymeleaf-spring6-3.1.5.RELEASE.jar org/graalvm/buildtools/native-maven-plugin/1.1.8/native-maven-plugin-1.1.8.jar $DTJP; do
  [ -f "$M2/$a" ] || die "$a is not in .m2-demo after the first build - README.md, The repository"; done
[ -f "$ZIP" ] || die "GraalVM's metadata repository is not in .m2-demo after the first build - README.md, The repository"
echo "  .m2-demo holds Thymeleaf's starter and its Spring module, DevTools, GraalVM's native plugin 1.1.8 and its metadata repository"
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
mask() { awk -v t="$TOKEN" -v g="${GRAALVM_HOME:-}" -v u="$U" -v up="$UP" -v hm="$HOME" -v me="$ME" -v tl="${#TOKEN}" '
  function lit(x) { gsub(/[][\\.^$*+?(){}|\/]/, "\\\\&", x); return x }
  function enc(x) { gsub(/ /, "%20", x); return x }
  BEGIN { T = lit(t); G = lit(g); GE = lit(enc(g)); P = lit(u); Q = lit(up); H = lit(hm); PE = lit(enc(u)); QE = lit(enc(up)); M = "(^|[^A-Za-z0-9_])" lit(me) "([^A-Za-z0-9_]|$)" }
  { gsub(T, "[masked: the " tl "-character token]"); if (g != "") { gsub(G, "$GRAALVM_HOME"); gsub(GE, "$GRAALVM_HOME") }; gsub(P, "…"); gsub(PE, "…")
    gsub(Q, "…/.."); gsub(QE, "…/.."); gsub(H, "~"); gsub(/\$\$SpringCGLIB\$\$[0-9]+/, "$$SpringCGLIB$$<n>")
    gsub(/tomcat-handler-[0-9]+/, "tomcat-handler-<n>")
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
code() { grep -vE '^[[:space:]]*(\*|/\*\*|\*/|//|$)' "$1"; }
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
# pagef MODE FILE: an answer's body, as this unit prints one. HTML is never printed whole. A TiffinBox page (its <title> ends
# " · TiffinBox"): its <title> and <h1>, its line and byte counts, then what MODE names - rows: the counts line, tags taken out, and
# the table's first column; form: each input's name and value, and each error message by the input it follows; frag: the lines of its
# <head>, its <header> line and its <footer> line, whole; foot: its <footer> line, whole; err: its <p> lines, tags taken out; sum:
# nothing more. Boot's Whitelabel page: its <h1> and its error line, its created date masked, its paragraphs counted. Anything else
# that is HTML: its <h1> and its length. JSON or text: its bytes, the error timestamp masked. An empty body: "none".
pagef() { python3 - "$1" "$2" <<'PY'
import html, re, sys
mode, f = sys.argv[1], sys.argv[2]
try: b = open(f, "rb").read()
except OSError: print("  body: no file - curl wrote none"); sys.exit(0)
t = b.decode("utf-8", "replace")
if not b: print("  body: none (0 bytes)"); sys.exit(0)
L = t.splitlines()
def strip(x): return html.unescape(re.sub(r"<[^>]+>", "", x)).strip()
ti = re.search(r"<title>(.*?)</title>", t); h1 = re.search(r"<h1>(.*?)</h1>", t)
if t.lstrip().startswith("<html><body><h1>Whitelabel Error Page</h1>"):
    e = re.search(r"<div>(There was an unexpected error .*?)</div>", t)
    print("  the Whitelabel page (Boot's) - its <h1>: Whitelabel Error Page · its error line: %s · its created date: masked · its paragraphs: %d, not shown" % (e.group(1) if e else "none", len(re.findall(r"<p>", t))))
elif ti and ti.group(1).endswith(" · TiffinBox"):
    print("  the page: <title>%s</title> · <h1>%s</h1> · %d lines, %d bytes - not shown%s" % (ti.group(1), h1.group(1) if h1 else "none", len(L), len(b), "" if mode == "sum" else " but these:"))
    if mode == "rows":
        c = [l for l in L if "<p>Customers: " in l]
        print("    the counts: " + (strip(c[0]) if c else "none"))
        print("    the table, first column: " + " ".join(re.findall(r"<tr><td>([^<]*)</td>", t)))
    elif mode == "form":
        for l in L:
            m = re.search(r'<input id="([^"]*)" name="([^"]*)" value="([^"]*)">', l)
            if m:
                s = re.search(r'<span class="error">(.*?)</span>', l)
                print("    %s = \"%s\"%s" % (m.group(2), html.unescape(m.group(3)), " · its message: " + html.unescape(s.group(1)) if s else ""))
        print("    messages on the page: %d" % len(re.findall(r'<span class="error">', t)))
    elif mode == "frag":
        a = next((i for i, l in enumerate(L) if l.strip() == "<head>"), None); z = next((i for i, l in enumerate(L) if l.strip() == "</head>"), None)
        for l in (L[a:z + 1] if a is not None and z is not None else []) + [l for l in L if l.startswith("<header>") or l.startswith("<footer>")]:
            print("    | " + l)
    elif mode == "foot":
        for l in L:
            if l.startswith("<footer>"): print("    | " + l)
    elif mode == "err":
        for l in L:
            if l.strip().startswith("<p>"): print("    " + strip(l))
elif re.search(r"<html|<!doctype", t, re.I):
    print("  an HTML page, not TiffinBox's - its <h1>: %s · %d characters, not shown" % (h1.group(1) if h1 else "none", len(t)))
else:
    print("  body: " + re.sub(r"\"timestamp\":[0-9]+", "\"timestamp\":…", re.sub(r"\"timestamp\":\"[^\"]*\"", "\"timestamp\":\"…\"", t)))
PY
}
# heads: the headers curl wrote (-D .harness/head.txt) - its status line and those a page's answer turns on, in the order they came;
# a header this filter does not name is counted, never shown
heads() { [ -f .harness/head.txt ] || { echo "  its headers: no file - curl wrote none"; return 0; }
  tr -d '\r' < .harness/head.txt | awk '
    NR == 1 { st = $0; sub(/ +$/, "", st); next } $0 == "" { next }
    { n = $0; sub(/:.*/, "", n); k = tolower(n) }
    k == "content-type" || k == "content-language" || k == "location" || k == "content-length" || k == "transfer-encoding" || k == "set-cookie" { sh = sh (sh ? " · " : "") $0; next }
    { o++ } END { printf "  %s · %s · headers not shown: %d\n", st, (sh ? sh : "none of those"), o + 0 }'; }
# rq 'CURL LINE' [MODE] [nolog]: a curl line of this unit's (its headers and body to files), printed and run; curl's own line, the WARN
# and ERROR lines the request added; its headers (heads); its body (pagef MODE); each WARN or ERROR record (recs). The two files are
# removed first: an answer curl wrote no body for prints "none" (R.119). nolog: no log read (a container's)
rq() { local n0 w e; [ -n "${3:-}" ] || n0=$(mark); rm -f .harness/head.txt .harness/body.html; echo "\$ $1"; (eval "$1") 2> /dev/null < /dev/null > .harness/curl.txt || true
  if [ -n "${3:-}" ]; then echo "  curl's line:$(cat .harness/curl.txt)"
  else settle; w=$(logl "$n0" WARN | grep -c . || true); e=$(logl "$n0" ERROR | grep -c . || true); echo "  curl's line:$(cat .harness/curl.txt) · WARN lines it added: $w · ERROR lines: $e"; fi
  heads; pagef "${2:-sum}" .harness/body.html
  [ -n "${3:-}" ] || [ "$w$e" = 00 ] || recs "$n0"; }
# jsq 'COMMAND' [nolog]: a JSON line (tq, pq) - the body and curl's status and Content-Type, the timestamp masked; the WARN and ERROR
# lines it added on the same line; each record
jsq() { local n0 w e; [ -n "${2:-}" ] || n0=$(mark); echo "\$ $1"; (eval "$1") 2>&1 < /dev/null | tsmask > .harness/ask.txt || true
  if [ -n "${2:-}" ]; then sed 's/^/  /' .harness/ask.txt; return 0; fi
  settle; w=$(logl "$n0" WARN | grep -c . || true); e=$(logl "$n0" ERROR | grep -c . || true)
  awk -v w="$w" -v e="$e" '{ l[NR] = $0 } END { for (i = 1; i <= NR; i++) print "  " l[i] (i == NR ? " · WARN lines it added: " w " · ERROR lines: " e : "") }' .harness/ask.txt
  [ "$w$e" = 00 ] || recs "$n0"; }
# run 'COMMAND': a file command (cp, rm, sed) run from its line's folder, printed as it runs; its exit code
run() { local e=0; echo "\$ $1"; (eval "$1") > .harness/runc.txt 2>&1 < /dev/null || e=$?; sed 's/^/  /' .harness/runc.txt; echo "  exit $e"; }
meta() { unzip -p "$1" META-INF/spring-configuration-metadata.json | python3 -c '
import json, sys
k = sys.argv[1]; d = json.load(sys.stdin)
p = [x for x in d.get("properties", []) if x["name"] == k]
if len(p) != 1: print("  %s: %d entries" % (k, len(p))); sys.exit(0)
p = p[0]; print("  %s - type %s · default %s · %s" % (k, p["type"].rsplit(".", 1)[-1], json.dumps(p.get("defaultValue")), p.get("description", "")))' "$2"; }
# The filters, checked on planted inputs before any capture (R.65): the level counts by line shape; the record filter; the harness's
# lines (a falling running number stops the run); the page filter's modes; the header filter; Chrome's masks
{ printf '%s\n' '2026-10-22T00:00:00.000Z  WARN 1 --- [planted] o.s.web.servlet.PageNotFound      : planted warning' 'HOOK 0001 Dump            > GET /x ERROR /error' '2026-10-22T00:00:00.001Z ERROR 1 --- [planted] o.a.c.c.C.[.[.[/].[dispatcherServlet]    : planted error' 'java.lang.IllegalArgumentException: planted'
  i=0; while [ $i -lt 45 ]; do printf '\tat planted.Frame%s(Planted.java)\n' $i; i=$((i + 1)); done; printf '%s\n' 'HOOK 0002 Dump            < 500 GET /x'; } > .harness/run.out
[ "$(logl 0 ERROR | grep -c .)" = 1 ] && [ "$(logl 0 WARN | grep -c .)" = 1 ] && [ "$(grep -c ' ERROR ' .harness/run.out)" = 2 ] || die "the level counts: the planted log must give 1 WARN and 1 ERROR by line shape (a bare ' ERROR ' gives 2)"
[ "$(recs 0)" = "$(printf '%s\n' '    WARN o.s.web.servlet.PageNotFound: planted warning' '      its stack frames: 0, its other lines: 0 - none shown' '    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: planted error' '      java.lang.IllegalArgumentException: planted' '      its stack frames: over 40, its other lines: 0 - none shown')" ] || die "recs: the planted log does not come out as declared (.harness/run.out)"
printf '%s\n' 'HOOK 0007 Dump            > GET /x' 'HOOK 0006 Dump            < 200 GET /x' > .harness/run.out
( hk 0 > /dev/null 2>&1 3> /dev/null ) && die "hk: a falling running number must stop the run"
rm -f .harness/run.out
printf '%s\n' '<!DOCTYPE html>' '<html>' '<head>' '  <title>Planted · TiffinBox</title>' '</head>' '<body>' '<header><h1>TiffinBox</h1></header>' '<p><label>Name <input id="name" name="name" value="a&amp;b"></label> <span class="error">must &quot;x&quot;</span></p>' '<p>Customers: <strong>2</strong></p>' '<tr><td>Asha</td><td>1</td></tr>' '<tr><td>Ravi</td><td>2</td></tr>' '<footer><p>planted</p></footer>' '</body>' '</html>' > .harness/planted.html
[ "$(pagef rows .harness/planted.html)" = "$(printf '%s\n' '  the page: <title>Planted · TiffinBox</title> · <h1>TiffinBox</h1> · 14 lines, 389 bytes - not shown but these:' '    the counts: Customers: 2' '    the table, first column: Asha Ravi')" ] || die "pagef rows: the planted page does not come out as declared"
[ "$(pagef form .harness/planted.html | sed -n 2,3p)" = "$(printf '%s\n' '    name = "a&b" · its message: must "x"' '    messages on the page: 1')" ] || die "pagef form: the planted page does not come out as declared"
[ "$(pagef frag .harness/planted.html | sed 1d)" = "$(printf '%s\n' '    | <head>' '    |   <title>Planted · TiffinBox</title>' '    | </head>' '    | <header><h1>TiffinBox</h1></header>' '    | <footer><p>planted</p></footer>')" ] || die "pagef frag: the planted page does not come out as declared"
printf '%s' "<html><body><h1>Whitelabel Error Page</h1><p>planted paragraph</p><div id='created'>Thu Oct 22 07:04:55 CEST 2026</div><div>There was an unexpected error (type=Internal Server Error, status=500).</div></body></html>" > .harness/planted.html
[ "$(pagef sum .harness/planted.html)" = "  the Whitelabel page (Boot's) - its <h1>: Whitelabel Error Page · its error line: There was an unexpected error (type=Internal Server Error, status=500). · its created date: masked · its paragraphs: 1, not shown" ] || die "pagef: the planted Whitelabel page does not come out as declared"
printf '{"timestamp":"2026-10-22T05:59:37.000Z","status":500}' > .harness/planted.html; [ "$(pagef sum .harness/planted.html)" = '  body: {"timestamp":"…","status":500}' ] || die "pagef: a JSON body must come out as its bytes, the timestamp masked"
: > .harness/planted.html; [ "$(pagef sum .harness/planted.html)" = '  body: none (0 bytes)' ] || die "pagef: an empty body must come out as none"
rm -f .harness/planted.html
printf 'HTTP/1.1 302 \r\nLocation: http://127.0.0.1:19510/dashboard\r\nContent-Language: en-US\r\nContent-Length: 0\r\nDate: Thu, 22 Oct 2026 05:59:37 GMT\r\n\r\n' > .harness/head.txt
[ "$(heads)" = '  HTTP/1.1 302 · Location: http://127.0.0.1:19510/dashboard · Content-Language: en-US · Content-Length: 0 · headers not shown: 1' ] || die "heads: the planted headers do not come out as declared"
rm -f .harness/head.txt
[ "$(printf '%s\n' 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/155.0.0.0 Safari/537.36' 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/155.0.0.0 Safari/537.36' 'sec-ch-ua: "Google Chrome";v="155"' 'sec-ch-ua-mobile: ?0' 'sec-ch-ua-platform: "macOS"' 'sec-ch-ua-platform: "Linux"' '[THYMELEAF][tomcat-handler-12] x' | mask)" = "$(printf '%s\n' 'User-Agent: Mozilla/5.0 (<platform masked>) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/<version> Safari/537.36' 'User-Agent: Mozilla/5.0 (<platform masked>) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/<version> Safari/537.36' 'sec-ch-ua: (its brands and their versions: masked)' 'sec-ch-ua-mobile: ?0' 'sec-ch-ua-platform: (<platform masked>)' 'sec-ch-ua-platform: (<platform masked>)' '[THYMELEAF][tomcat-handler-<n>] x')" ] || die "mask: Chrome's version and the platform (User-Agent, sec-ch-ua-platform) and a request thread's number must be masked, and nothing else"
echo "  the filters: the level counts (a harness line that says ERROR is no ERROR line), the record filter, the harness's lines, the page filter's modes, the header filter and the masks print their planted inputs as declared"

# ---- change: a starter, a controller, four templates, a stylesheet ------------------------------------------------------------------
cdiff() { diff -U0 "$1" "$2" | tail -n +3 > .harness/code.diff || true
  echo "  its diff (diff -U0, its file names cut) - hunks: $(grep -c '^@@ ' .harness/code.diff || true) · lines out: $(grep -c '^-' .harness/code.diff || true) · in: $(grep -c '^+' .harness/code.diff || true) - whole:"
  sed 's/^/    /' .harness/code.diff; }
change() { local f n m k
  echo "the previous tree and after/, both copied under .harness/ with a config tree, each built with the README's line (offline):"
  copy "$PREV" .harness/before; copy after .harness/after
  pbuild .harness/before "the previous tree"; pbuild .harness/after "after/"
  echo "both jars extracted (the README's line) - the class path the harness runs on:"
  extract .harness/before; extract .harness/after
  echo "the harness, compiled against after/'s own libraries - with -parameters:"
  echo "\$ $L_JAVAC"; rm -rf .harness/hc; (eval "$L_JAVAC") > .harness/javac.log 2>&1 < /dev/null || { cat .harness/javac.log >&3; die "the harness did not compile against after/'s libraries"; }
  echo "  exit 0 · its classes: $(cd .harness/hc && find . -name '*.class' | sed 's#^\./##' | sort | paste -sd' ' -)"
  echo "the files that differ, and the files only one tree has:"
  echo "\$ diff -rq -x target -x secrets .harness/before .harness/after"
  diff -rq -x target -x secrets .harness/before .harness/after | sed 's/^/  /' || true
  (cd after && find . -type f | sed 's#^\./##' | sort) > .harness/files.txt
  n=0; m=0; k=0; while IFS= read -r f; do m=$((m + 1)); if [ ! -e ".harness/before/$f" ]; then k=$((k + 1)); elif cmp -s ".harness/before/$f" ".harness/after/$f"; then n=$((n + 1)); fi; done < .harness/files.txt
  echo "  after/'s files: $m · byte for byte the previous tree's: $n · new: $k · those that differ: $((m - n - k))"
  f=tiffinbox-web/pom.xml; echo "  $f: $(lines ".harness/before/$f") lines -> $(lines ".harness/after/$f")"; cdiff ".harness/before/$f" ".harness/after/$f"
  f="$W/DashboardPage.java"; code ".harness/after/$f" > .harness/fa.txt
  echo "  DashboardPage.java (new): $(lines ".harness/after/$f") lines · its lines that are neither comment nor blank: $(wc -l < .harness/fa.txt | tr -d ' ') - whole:"
  sed 's/^/    /' .harness/fa.txt
  echo "  the templates and the stylesheet (new) - their lines:"
  for f in templates/fragments.html templates/dashboard.html templates/customer-form.html templates/error/5xx.html static/css/tiffinbox.css; do
    echo "    $f: $(lines ".harness/after/$RS/$f") · its th: attributes: $(grep -oE ' th:[a-z]+=' ".harness/after/$RS/$f" | sed 's/^ //; s/=$//' | sort | uniq -c | awk '{ printf "%s%s ×%d", (NR > 1 ? ", " : ""), $2, $1 } END { if (NR == 0) printf "none" }')"; done
  echo "  templates/error/404.html in after/: $( [ -e ".harness/after/$RS/templates/error/404.html" ] && echo yes || echo no)"
  diff .harness/before/README.md .harness/after/README.md > .harness/file.diff || true
  echo "  README.md - the anchor's README: lines added $(grep -c '^> ' .harness/file.diff || true), removed $(grep -c '^< ' .harness/file.diff || true) - its new section and the history notes the change made false (not shown)"
  echo "  Boot's own metadata for Thymeleaf's keys (spring-boot-thymeleaf-4.1.1.jar, META-INF/spring-configuration-metadata.json):"
  for k in spring.thymeleaf.prefix spring.thymeleaf.suffix spring.thymeleaf.cache; do meta .harness/after/tiffinbox-web/target/extracted/lib/spring-boot-thymeleaf-4.1.1.jar "$k"; done
  libs .harness/before/$JARP > .harness/lb.txt; libs .harness/after/$JARP > .harness/la.txt
  echo "the executable jar's BOOT-INF/lib: $(wc -l < .harness/lb.txt | tr -d ' ') jars -> $(wc -l < .harness/la.txt | tr -d ' ') · only after/'s: $(comm -13 .harness/lb.txt .harness/la.txt | paste -sd' ' -) · only the previous tree's: $(comm -23 .harness/lb.txt .harness/la.txt | grep -c . || true)"
  unzip -Z1 .harness/before/$JARP | grep '^BOOT-INF/classes/com/tiffinbox/web/.*\.class$' | sed 's#.*/##' | sort > .harness/cb.txt || true
  unzip -Z1 .harness/after/$JARP | grep '^BOOT-INF/classes/com/tiffinbox/web/.*\.class$' | sed 's#.*/##' | sort > .harness/ca.txt || true
  echo "the classes in the jar's com/tiffinbox/web: $(wc -l < .harness/cb.txt | tr -d ' ') -> $(wc -l < .harness/ca.txt | tr -d ' ') · only after/'s: $(comm -13 .harness/cb.txt .harness/ca.txt | paste -sd' ' -)"
  echo "the jar's templates and static files: $(unzip -Z1 .harness/after/$JARP | grep -E '^BOOT-INF/classes/(templates|static)/.*[^/]$' | sed 's#^BOOT-INF/classes/##' | sort | paste -sd' ' -)"; }

# ---- negotiate: the seven, the routing table, one URL with two answers ------------------------------------------------------------
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
# maps PORT: the routing table (/actuator/mappings, exposed for this run) - the dispatcher servlet's rows, then TiffinBox's own routes
# (handler methods in com.tiffinbox), sorted by path and verb: each one's verb, path, class#method, and the media types it produces and
# consumes ("any": none named)
maps() { local c="curl -s http://127.0.0.1:$1/actuator/mappings"; echo "\$ $c"; (eval "$c") 2> /dev/null < /dev/null | python3 -c '
import json, sys
d = json.load(sys.stdin); rows = []; n = 0
for ctx in d["contexts"].values():
    for r in ctx["mappings"]["dispatcherServlets"]["dispatcherServlet"]:
        n += 1; det = r.get("details") or {}; hm = det.get("handlerMethod")
        if hm and hm["className"].startswith("com.tiffinbox."):
            c = det["requestMappingConditions"]
            rows.append((c["patterns"][0], c["methods"][0], hm["className"].rsplit(".", 1)[1] + "#" + hm["name"], ", ".join(x["mediaType"] for x in c["produces"]) or "any", ", ".join(x["mediaType"] for x in c["consumes"]) or "any"))
print("  the dispatcher servlet'"'"'s rows: %d · TiffinBox'"'"'s routes: %d, sorted by path:" % (n, len(rows)))
for p, m, h, pr, co in sorted(rows): print("    %-4s %-17s %-28s produces: %s · consumes: %s" % (m, p, h, pr, co))'; }
negotiate() {
  echo "the seven - the previous tree, the README's run line, port 19511, a fresh JVM:"
  start "$(at .harness/before 19511 "$R_RUN")"; up 19511; ready 19511; seven 19511 .harness/before; cp .harness/responses.m.txt .harness/seven-before.txt; WARNS; logl 0 WARN
  echo "the seven - after/, the README's run line, port 19510, a fresh JVM:"
  start "$(at .harness/after 19510 "$R_RUN")"; up 19510; ready 19510; seven 19510 .harness/after; cp .harness/responses.m.txt .harness/seven-after.txt; WARNS; logl 0 WARN
  echo "the lines that moved - the previous tree's seven against after/'s, masked, line for line:"
  moved .harness/seven-before.txt .harness/seven-after.txt
  echo "the routing table - the previous tree, the README's routing-table line, port 19511:"
  start "$(at .harness/before 19511 "$R_MAPS")"; up 19511; ready 19511; maps 19511
  echo "  then the dashboard for a browser's whole Accept header (Chrome's, sent by curl), on the previous tree:"
  rq "$(gq 19511 /dashboard "$CHROMEA")"
  echo "  and the request-body lesson's POST without its Content-Type (curl's --data names a form's type), on the previous tree:"
  rq "$(nq 19511)"; stop 19511 .harness/before
  echo "the routing table - after/, port 19510:"
  start "$(at .harness/after 19510 "$R_MAPS")"; up 19510; ready 19510; maps 19510; stop 19510 .harness/after
  echo "one URL, two answers - after/, the README's run line, port 19510; no request names a language (Accept-Language) unless its line says so:"
  start "$(at .harness/after 19510 "$R_RUN")"; up 19510; ready 19510
  jsq "$(tq 19510 /dashboard)"; jsq "$(tq 19510 /dashboard application/json)"
  rq "$(gq 19510 /dashboard)" rows; rq "$(gq 19510 /dashboard "$CHROMEA")"
  jsq "$(tq 19510 /customers/new application/json)"; rq "$(gq 19510 /customers/new)"
  rq "$(gq 19510 /dashboard text/html 'Accept-Language: de')"
  WARNS; stop 19510 .harness/after; }

# ---- fragments: the head, the header and the footer, shared ---------------------------------------------------------------------------
fragments() { local a b
  echo "the template lines that put them there - after/'s templates, the lines that name th:fragment or th:replace:"
  for f in fragments.html dashboard.html customer-form.html error/5xx.html; do
    echo "\$ grep -n -e 'th:fragment' -e 'th:replace' $RS/templates/$f"
    a=$(cd after && grep -n -e 'th:fragment' -e 'th:replace' "$RS/templates/$f" || true); if [ -n "$a" ]; then printf '%s\n' "$a" | sed 's/^/  /'; else echo "  none - it names neither"; fi; done
  echo "the two pages - after/, the README's run line, port 19510:"
  start "$(at .harness/after 19510 "$R_RUN")"; up 19510; ready 19510
  rq "$(gq 19510 /dashboard)" frag; cp .harness/body.html .harness/page-d.html
  rq "$(gq 19510 /customers/new)" frag; cp .harness/body.html .harness/page-f.html
  WARNS; stop 19510 .harness/after
  pagef frag .harness/page-d.html | sed 1d > .harness/fd.txt; pagef frag .harness/page-f.html | sed 1d > .harness/ff.txt
  a=$(diff .harness/fd.txt .harness/ff.txt | grep -c '^<' || true)
  echo "  the dashboard's head, header and footer lines against the form's, line for line: $(wc -l < .harness/fd.txt | tr -d ' ') and $(wc -l < .harness/ff.txt | tr -d ' ') lines · lines that differ: $a$( [ "$a" = 1 ] && printf ' - %s' "$(diff .harness/fd.txt .harness/ff.txt | grep '^[<>]' | sed 's/^[<>] *| *//' | paste -sd'|' - | sed 's/|/ against /')")"; }

# ---- form: a form-backing object, a redirect, messages --------------------------------------------------------------------------------
form() {
  echo "the form - after/, the README's run line, port 19510; no request names a language unless its line says so:"
  start "$(at .harness/after 19510 "$R_RUN")"; up 19510; ready 19510
  rq "$(gq 19510 /customers/new)" form
  echo "a valid form - the anchor's line - then the page it redirects to:"
  rq "$(fq 19510 "$B_LATA")"; rq "$(gq 19510 /dashboard)" rows
  echo "four rules broken:"
  rq "$(fq 19510 "$B_BAD")" form
  echo "the same, the request naming German:"
  rq "$(fq 19510 "$B_BAD" 'Accept-Language: de')" form
  echo "letters for a number:"
  rq "$(fq 19510 "$B_TWO")" form
  echo "a name that is taken:"
  rq "$(fq 19510 "$B_LATA")" form
  echo "the JSON POST beside it - the request-body lesson's line, curl's Content-Type printed:"
  jsq "$(pq 19510 "$B_ASHA")"
  echo "the request-body lesson's POST without its Content-Type - curl's --data names a form's type:"
  rq "$(nq 19510)" form
  rq "$(gq 19510 /dashboard)" rows
  WARNS; stop 19510 .harness/after; }

# ---- errors: what nobody handles; a template that is wrong; C - error/404.html ----------------------------------------------------
errors() {
  echo "a refusal nobody handles - a name of 61 letters, the customer table's column holds 60 - after/, the README's run line, port 19510:"
  start "$(at .harness/after 19510 "$R_RUN")"; up 19510; ready 19510
  rq "$(fq 19510 "$B_LONG" 'Accept: text/html')" err
  rq "$(fq 19510 "$B_LONG")"
  WARNS; stop 19510 .harness/after
  echo "a template that is wrong - after/'s build copied to .harness/typo, its dashboard template replaced by the exercise's in its classes folder; the folder line, port 19512:"
  rm -rf .harness/typo; rsync -a --exclude secrets .harness/after/ .harness/typo/; tree .harness/typo
  run "cp $XT .harness/typo/$TC/templates/dashboard.html"
  echo "\$ diff after/$RS/templates/dashboard.html .harness/typo/$TC/templates/dashboard.html"
  diff "after/$RS/templates/dashboard.html" ".harness/typo/$TC/templates/dashboard.html" | sed 's/^/  /' | sed -E 's/<td th:text=.*$/…/' || true
  start "$(at .harness/typo 19512 "$L_FOLD")"; up 19512; ready 19512
  rq "$(gq 19512 /dashboard)" err
  jsq "$(tq 19512 /dashboard)"
  rq "$(gq 19512 /customers/new)"
  WARNS; stop 19512 .harness/typo
  echo "C (labelled) - templates/error/404.html: after/'s build copied to .harness/c404, the harness's 404 page put in its classes folder; the folder line, port 19512:"
  rm -rf .harness/c404; rsync -a --exclude secrets .harness/after/ .harness/c404/; tree .harness/c404
  run "cp $C404 .harness/c404/$TC/templates/error/404.html"
  echo "  the copy's error templates: $(cd .harness/c404/$TC/templates/error && ls | paste -sd' ' -)"
  start "$(at .harness/c404 19512 "$L_FOLD")"; up 19512; ready 19512
  rq "$(gq 19512 /nowhere)"; rq "$(gq 19512 /nowhere "$CHROMEA")"; rq "$(gq 19512 /customers/Nobody "$CHROMEA")"
  WARNS; stop 19512 .harness/c404; }

# ---- devtools: DevTools' keys; A/B/A' - spring.thymeleaf.cache; C - spring.template.provider.cache ------------------------------------
# edit DIR: the folder copy's fragments.html made the source's again (cp), then edited while TiffinBox runs (this unit's sed line)
restore() { run "cd $1 && cp $RS/templates/fragments.html $TC/templates/fragments.html"; }
cachet() { restore .harness/fold
  start "$(at .harness/fold 19512 "$1")"; up 19512; ready 19512
  rq "$(gq 19512 /dashboard)" foot
  run "cd .harness/fold && $L_EDIT"
  rq "$(gq 19512 /dashboard)" foot; rq "$(gq 19512 /customers/new)" foot
  WARNS; stop 19512 .harness/fold; }
provt() { run "cd .harness/fold && rm $TC/templates/error/5xx.html"
  start "$(at .harness/fold 19512 "$1")"; up 19512; ready 19512
  rq "$(fq 19512 "$B_LONG" 'Accept: text/html')" err
  run "cd .harness/fold && cp $RS/templates/error/5xx.html $TC/templates/error/5xx.html"
  rq "$(fq 19512 "$B_LONG" 'Accept: text/html')" err
  WARNS; stop 19512 .harness/fold; }
devtools() { local n
  echo "the keys - Boot's metadata for Thymeleaf's cache (spring-boot-thymeleaf-4.1.1.jar), and for Boot's template-availability cache in every library's metadata; the name in Boot's own class:"
  meta .harness/after/tiffinbox-web/target/extracted/lib/spring-boot-thymeleaf-4.1.1.jar spring.thymeleaf.cache
  n=0; for j in .harness/after/tiffinbox-web/target/extracted/lib/*.jar; do n=$((n + $(unzip -p "$j" META-INF/spring-configuration-metadata.json 2> /dev/null | grep -c '"name": "spring.template.provider.cache"' || true))); done
  echo "  spring.template.provider.cache - entries in the $(ls .harness/after/tiffinbox-web/target/extracted/lib/*.jar | wc -l | tr -d ' ') libraries' metadata: $n"
  echo "\$ unzip -p .harness/after/tiffinbox-web/target/extracted/lib/spring-boot-autoconfigure-4.1.1.jar org/springframework/boot/autoconfigure/template/TemplateAvailabilityProviders.class | grep -ac 'spring.template.provider.cache'"
  echo "  $(unzip -p .harness/after/tiffinbox-web/target/extracted/lib/spring-boot-autoconfigure-4.1.1.jar org/springframework/boot/autoconfigure/template/TemplateAvailabilityProviders.class | grep -ac 'spring.template.provider.cache' || true)"
  echo "DevTools - after/'s extracted jar with DevTools' jar (from \$M2) and the harness on its class path, Live Reload off, the harness's Keys joined, port 19513:"
  start "$(at .harness/after 19513 "$L_DEVT")"; up 19513; ready 19513
  settle; hk 0; echo "  listening on 35729 (Live Reload) now: $(listeners 35729)"
  WARNS; stop 19513 .harness/after
  echo "a folder class path - after/'s build copied to .harness/fold, the web module's classes folder in place of its jar (this unit's folder line):"
  rm -rf .harness/fold; rsync -a --exclude secrets .harness/after/ .harness/fold/; tree .harness/fold
  echo "A - Boot's default, port 19512:"
  cachet "$L_FOLD"
  echo "B - Thymeleaf's cache off for this run (this unit's line), port 19512:"
  cachet "$L_TCF"
  echo "A' - A again, a fresh JVM, port 19512:"
  cachet "$L_FOLD"
  echo "A' against A, its label aside, line for line the same: $(asame 'A - ' 'B - ' "A' - " "A' against A")"
  echo "C (labelled) - Boot's template-availability cache: the error page taken out of the folder before the start, put back while it runs - Boot's default, port 19512:"
  provt "$L_FOLD"
  echo "C - the same, that cache off for this run (this unit's line), port 19512:"
  provt "$L_TPF"
  restore .harness/fold; }

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
  echo "  the shell is now in: $(where "$d1") · the copy's own token in its log: $(raw "$(head -1 .harness/mine/after/$TF)" .harness/ex-readme.log) times · WARN lines in its log: $(lvl WARN .harness/ex-readme.log) · ERROR lines: $(lvl ERROR .harness/ex-readme.log) · listening on 19518 now: $(listeners 19518)"
  echo "  its ERROR lines, from their logger on, the request thread's number masked, each cut at 160 characters:"; grep -E '^[0-9]{4}-[0-9]{2}-[0-9]{2}T[^ ]+ +ERROR ' .harness/ex-readme.log | sed -E 's/^.*--- \[[^]]*\] //; s/ +: /: /' | cut -c1-160 | sed 's/^/    /'
  echo "the solution's $(printf '%s\n' "$sol" | grep -c .) lines, next, in the same shell:"
  printf '%s\n' "$sol" | sed 's/^/  $ /'
  echo "  exit $e2 · what they printed:"; sed 's/^/    /' .harness/ex-sol.out
  echo "  the shell is now in: $(where "$d2") · the copy's own token in its log: $(raw "$(head -1 .harness/mine/after/$TF)" .harness/mine/run.log) times · WARN lines in its log: $(lvl WARN .harness/mine/run.log) · ERROR lines: $(lvl ERROR .harness/mine/run.log) · listening on 19518 now: $(listeners 19518)"
  echo "  the copy's template against after/'s: $(cmp -s ".harness/mine/after/$RS/templates/dashboard.html" "after/$RS/templates/dashboard.html" && echo 'the same, byte for byte' || echo different)"; }

# ---- browser: TiffinBox, Chrome - each claim with two witnesses -------------------------------------------------------------------
# chrome: Chrome (this unit's line) with a profile made fresh for this run, its DevTools port up and loopback
cup() { local l i=0 a=""; while [ $i -lt 480 ]; do a=$(addrs "$cpid"); case " $a " in *":19519 "*) break ;; esac; kill -0 "$cpid" 2> /dev/null || break; sleep 0.25; i=$((i + 1)); done
  case " $a " in *":19519 "*) ;; *) die "Chrome never listened on 19519" ;; esac
  l=$(printf '%s\n' "$a" | tr ' ' '\n' | grep ':19519$' | paste -sd' ' -); echo "  Chrome's DevTools port: $l · loopback only: $(lb "$l")"; }
chrome() { local f; [ -e .harness/chrome ] && f=no || f=yes; rm -f .harness/netlog.json
  echo "\$ $L_CHROME"; (eval "exec $L_CHROME") > .harness/chrome.out 2>&1 < /dev/null & cpid=$!
  echo "  its profile, .harness/chrome, made fresh for this run (it did not exist before this line): $f"; cup; }
unchrome() { local i=0 e=0; echo "\$ $L_CLOSE"; (eval "$L_CLOSE") > .harness/close.out 2>&1 < /dev/null || true
  while kill -0 "$cpid" 2> /dev/null && [ $i -lt 60 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$cpid" 2> /dev/null && { killtree "$cpid"; die "Chrome still ran 15 s after Browser.close"; }
  wait "$cpid" || e=$?; cpid=""; [ "$(listeners 19519)" = 0 ] || die "something still listens on 19519"
  rm -rf .harness/chrome; echo "  Chrome exit $e · listening on 19519 now: 0 · its profile removed"
  echo "\$ $(nlq "$@")"; (eval "$(nlq "$@")") 2>&1 < /dev/null || true; }
# visit 'CDP LINE': the line printed and run - the page Chrome shows; Chrome's own record of the visit's page requests (net.py); then
# the server's record: every harness line the requests printed (Dump), and the WARN and ERROR lines they added
visit() { local n0 w e; n0=$(mark); rm -f .harness/ev.json; echo "\$ $1"; (eval "$1") 2>&1 < /dev/null | sed 's/^/  /'
  echo "\$ ${L_NET/ 18431/ 19517}"; (eval "${L_NET/ 18431/ 19517}") 2>&1 < /dev/null; settle
  w=$(logl "$n0" WARN | grep -c . || true); e=$(logl "$n0" ERROR | grep -c . || true)
  echo "  the server's record:"; hk "$n0" | sed 's/^/  /'; echo "    WARN lines they added: $w · ERROR lines: $e"; }
browser() {
  echo "TiffinBox - after/ on its class path (the README's line), Dump joined (the server's record of every page request, whole), port 19517:"
  start "$(hcp .harness/after 19517 probe.web.Dump)"; up 19517; ready 19517
  echo "Chrome - headless, a profile of its own, sealed to 127.0.0.1 (its proxy a dead address, every name but 127.0.0.1 unresolvable), its DevTools protocol on 127.0.0.1:19519:"
  chrome
  echo "visit 1 - the dashboard's address, typed:"
  visit "$(oq 19517 /dashboard)"
  echo "visit 2 - the form, filled in and sent:"
  visit "$(sq 19517 'name=Kiran&mealsPerDay=1&pricePerMeal=130&mealType=VEGAN')"
  echo "visit 3 - the form sent breaking four rules:"
  visit "$(sq 19517 "$B_BAD")"
  unchrome 19517
  WARNS; stop 19517 .harness/after; }

# ---- forms: the native build, what Spring's AOT step registered, then four forms ---------------------------------------------------
nbuild() { local ci cn s0 s1
  ci=$(off "$1" "$R_INSTALL" install); cn=$(off "$1" "$R_NATIVE")
  echo "\$ $ci"; mbuild "$ci" "$1.install.log" "$1 (both modules, into \$M2)"
  echo "\$ $cn"
  NB_E=0; s0=$(date +%s); (eval "$cn") > "$1.native.log" 2>&1 < /dev/null || NB_E=$?; s1=$(date +%s); NB_S=$((s1 - s0))
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
for t in only_b:
    if "tiffinbox" in t or "thymeleaf" in t.lower(): print("    only after/: %s - %s" % (json.loads(t), what(B[t])))
print("    only after/, the rest: %d (not named)" % sum(1 for t in only_b if not ("tiffinbox" in t or "thymeleaf" in t.lower())))
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
  if [ "$1" = '4 the image' ]; then [ "$(grep -c '^  docker port: ' .harness/blk.txt)" = 2 ] && [ "$(grep -cE '^  docker port: 18425/tcp -> 127\.0\.0\.1:19515$' .harness/blk.txt)" = 2 ] && echo yes || echo no
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
# froutes PORT: every page, on a second start of a form - the dashboard, the form, four rules broken, a valid POST and the dashboard
# after it, the error page for a refusal nobody handles, the JSON POST - each answer printed; no log counted (a container's log is
# read only when it has stopped)
froutes() { rq "$(gq "$1" /dashboard)" rows nolog; rq "$(gq "$1" /customers/new)" sum nolog; rq "$(fq "$1" "$B_BAD")" form nolog
  rq "$(fq "$1" "$B_LATA")" sum nolog; rq "$(gq "$1" /dashboard)" rows nolog; rq "$(fq "$1" "$B_LONG" 'Accept: text/html')" err nolog
  jsq "$(pq "$1" "$B_ASHA")" nolog; }
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
  echo "  file: $(file -b ".harness/nat/$BIN" | sed 's/ [A-Za-z0-9_]*$//') · the demo token in its bytes: $(raw "$TOKEN" ".harness/nat/$BIN")"
  echo "what Spring's AOT step registered - the previous tree built with the README's native-profile line too (.harness/natb), then its metadata against after/'s:"
  copy "$PREV" .harness/natb; pbuild .harness/natb "the previous tree, the profile native" "$R_PNAT"
  aotcmp .harness/natb .harness/nat
  echo "1 the jar - .harness/after, the README's run line, port 19510:"
  start "$(at .harness/after 19510 "$R_RUN")"; up 19510; ready 19510; tline; seven 19510 .harness/after
  echo "  then every page, on a second start of the jar:"
  start "$(at .harness/after 19510 "$R_RUN")"; up 19510; ready 19510; froutes 19510; stop 19510 .harness/after
  echo "2 the AOT jar - .harness/nat (the profile native's jar), the README's AOT line, port 19514:"
  start "$(at .harness/nat 19514 "$R_AOTRUN")"; up 19514; ready 19514; tline; seven 19514 .harness/nat
  echo "  then every page, on a second start of the AOT jar:"
  start "$(at .harness/nat 19514 "$R_AOTRUN")"; up 19514; ready 19514; froutes 19514; stop 19514 .harness/nat
  echo "3 the binary - .harness/nat, the README's line, port 19516:"
  start "$(at .harness/nat 19516 "$R_BIN")"; up 19516; ready 19516; tline; seven 19516 .harness/nat
  echo "  then every page, on a second start of the binary:"
  start "$(at .harness/nat 19516 "$R_BIN")"; up 19516; ready 19516; froutes 19516; stop 19516 .harness/nat
  echo "4 the image - after/'s Dockerfile (the README's build line, this script's tag), the README's run line with your user, published on 127.0.0.1:19515:"
  image
  dstart "$(drun .harness/after 19515)"; ready 19515 "$BOX"; dbind 19515
  dseven 19515
  echo "  then every page, on a second container of the image - TiffinBox listens on 18425 inside it:"
  dstart "$(drun .harness/after 19515)"; ready 19515 "$BOX"; dbind 19515
  froutes 19515
  post 19515 .harness/after; dgone "$BOX"; [ "$(listeners 19515)" = 0 ] || die "something still listens on 19515"
  dlog "$BOX"; echo "  exit $LASTE · its log (docker logs): the demo token 0 times · X-Shutdown-Token 0 times · WARN lines: $(lvl WARN .harness/run.out) · ERROR lines: $(lvl ERROR .harness/run.out)"
  docker rm "$BOX" > /dev/null
  echo "four forms, one tree: the seven (masked) $(grep -cE "^  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 0 · md5 $S466\$" .harness/cap.raw) of 4 times $S466 · the dashboard page: $(grep -c '^  the page: <title>Dashboard · TiffinBox</title> · <h1>TiffinBox</h1> · ' .harness/cap.raw) of 8 · the form's four messages: $(grep -cxF '    messages on the page: 4' .harness/cap.raw) of 4 · a valid POST, 302 to the dashboard: $(grep -cE '^  HTTP/1\.1 302 · Location: http://127\.0\.0\.1:195(10|14|15|16)/dashboard · ' .harness/cap.raw) of 4 · the error page: $(grep -c '^  the page: <title>Something broke · TiffinBox</title> · <h1>TiffinBox could not answer</h1> · ' .harness/cap.raw) of 4"
  echo "  loopback, form by form: the jar $(lbk '1 the jar') · the AOT jar $(lbk '2 the AOT jar') · the binary $(lbk '3 the binary') · the image, published on 127.0.0.1 alone $(lbk '4 the image')"
  echo "  the locale: options on the binary's and the image's run lines: $(printf '%s\n%s\n' "$(at .harness/nat 19516 "$R_BIN")" "$(drun .harness/after 19515)" | grep -o 'user\.language\|user\.country' | wc -l | tr -d ' ') (none passed: the binary runs as the README writes it, the image as its ENTRYPOINT, java -jar)"; }

cap change change
cap negotiate negotiate
cap fragments fragments
cap form form
cap errors errors
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
# seg BLOCK 'COMMAND': the lines a command printed in BLOCK - from the line after "$ COMMAND" up to the next "$ " line or label line (or a run's
# WARN count); segn N BLOCK 'COMMAND': the same for the command's Nth run in BLOCK
seg() { printf '%s\n' "$1" | C="\$ $2" awk 'f && (/^\$ / || /^[A-Za-z]/ || /^  WARN lines in this run/) { exit } f { print } $0 == ENVIRON["C"] { f = 1 }'; }
segn() { printf '%s\n' "$2" | C="\$ $3" N="$1" awk 'f && (/^\$ / || /^[A-Za-z]/ || /^  WARN lines in this run/) { exit } f { print } $0 == ENVIRON["C"] && ++k == ENVIRON["N"] { f = 1 }'; }
# THE TOKEN: no capture holds it, raw - counted on each run's own output BEFORE masking - and neither does any log, any file this unit
# ships for reading, nor the binary this run built
for f in .harness/raw-*; do [ "$(cat "$f")" = "0" ] || die "a capture's raw output held the token ($f: $(cat "$f"))"; done
SHIP="README.md exercise/README.md exercise/solution/SOLUTION.md receipts.md5 harness/shutdown.sh harness/cdp.mjs harness/net.py harness/netlog.py $XT $C404 $HWS"
NBIN=0
for f in .r-*.out $SHIP .harness/nat/$BIN; do [ -f "$f" ] || continue; case $f in .harness/nat*) NBIN=$((NBIN + 1)) ;; esac; [ "$(raw "$TOKEN" "$f")" = 0 ] || die "$f holds the demo token, raw"; done
[ "$NBIN" = 1 ] || die "one binary was built, $NBIN were checked"
for f in .r-*.out; do ! grep -qE '/Users/|/private/|/home/|/var/folders/' "$f" || die "$f holds an absolute path"; [ -z "${GRAALVM_HOME:-}" ] || ! grep -qF "$GRAALVM_HOME" "$f" || die "$f holds the GraalVM's folder"; ! grep -qE 'c[0-9]-unit[0-9]|unit ?[0-9]' "$f" || die "$f holds a unit number"; ! grep -qE ' (with PID|started by) ' "$f" || die "$f holds Boot's process line"; ! grep -qE '^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T|"timestamp":"?[0-9]|(exec|handler|task|utility)-[0-9]|GMT|CES?T|<div id=.created|[A-Z][a-z][a-z], [0-9][0-9] [A-Z][a-z][a-z] |[A-Z][a-z][a-z] [A-Z][a-z][a-z] [0-9]+ [0-9][0-9]:[0-9][0-9]' "$f" || die "$f holds a log line's time, a timestamp, a date or a thread's number"; ! grep -q "^$(printf '\t')at " "$f" || die "$f shows a stack frame"; ! grep -qE 'SpringCGLIB\$\$[0-9]' "$f" || die "$f holds a generated class's number"; ! grep -qE 'sha256:[0-9a-f]{64}' "$f" || [ "$(grep -cE 'sha256:[0-9a-f]{64}' "$f")" = "$(grep -cE 'eclipse-temurin(:25-jre)?@sha256:[0-9a-f]{64}' "$f")" ] || die "$f holds an ID other than the base image's digest"; ! grep -qE ':(8080|35729)([^0-9]|$)' "$f" || die "$f shows a bind on 8080 or 35729"; ! grep -q $'\r' "$f" || die "$f holds a carriage return"; ! grep -qiE '<html|<!doctype' "$f" || die "$f shows an HTML page whole"; ! grep -qE 'Chrome/[0-9]|v="[0-9]' "$f" || die "$f holds Chrome's version"; ! grep -qE 'Macintosh|Mac OS X|Windows NT|X11;|Linux x86|sec-ch-ua-platform: "' "$f" || die "$f holds the platform (User-Agent or sec-ch-ua-platform)"; done
# R.109: a JVM with DevTools on its class path exits 1 - Java's launcher, whose main thread DevTools ends with its SilentExitException
# (the app runs on in restartedMain; README.md, "Found on the way"); every other JVM a capture stops exits 0
for f in .r-*.out; do [ "$(grep -cE '^  exit [1-9][0-9]* · listening on [0-9]+ now: 0$' "$f" || true)" = "$(grep -cE '^  exit 1 · listening on 19513 now: 0$' "$f" || true)" ] || die "$f: a JVM without DevTools exited non-zero"; done
[ "$(grep -cE '^  exit 1 · listening on 19513 now: 0$' .r-devtools.out)" = 1 ] && ! grep -qE '^  exit 0 · listening on 19513 now: 0$' .r-devtools.out || die "devtools: each of DevTools' 1 JVM on 19513 exits 1, none 0 (R.109)"
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
echo "  tokens: 0 raw copies in $(ls .harness/raw-* | wc -l | tr -d ' ') raw capture runs, in $(ls .r-*.out | wc -l | tr -d ' ') captures; the demo token 0 in the logs of every JVM that served ($LOGS here; the published captures' $NL) and every container ($CLOGS here), the image's layers, the READMEs, the harness, the exercise, receipts.md5 and the binary; no absolute path, no GraalVM folder, no unit number, no process line, no log time, no timestamp, no date, no thread number, no stack frame, no whole HTML page, no Chrome version, no 8080 or 35729, no carriage return in any capture; no Boot 3 error key; no harness class in the anchor; no bare wait; no stop by name; every java line's locale pinned; every docker run publishes on 127.0.0.1 alone; every URL a capture runs is 127.0.0.1's"

Z00=' · WARN lines it added: 0 · ERROR lines: 0'
NLC='
'
CL='  curl'"'"'s line:'
HT='  curl'"'"'s line: 200 · Content-Type: [text/html;charset=UTF-8]'
HEADS='  HTTP/1.1 200 · Content-Type: text/html;charset=UTF-8 · Content-Language: en-US · Transfer-Encoding: chunked · headers not shown: 1'
PDASH='  the page: <title>Dashboard · TiffinBox</title> · <h1>TiffinBox</h1> · 22 lines, 926 bytes - not shown'
PFORM='  the page: <title>Add a customer · TiffinBox</title> · <h1>TiffinBox</h1> · 21 lines, 806 bytes - not shown'
P5XX='  the page: <title>Something broke · TiffinBox</title> · <h1>TiffinBox could not answer</h1> · 12 lines, 298 bytes - not shown but these:'
JDASH='  {"customers":4,"monthRevenue":24300,"pausedDays":5,"names":["Meera","Priya","Ravi","Sunil"]} 200 · Content-Type: [application/json]'
FOUR=$(printf '%s\n' '    name = "" · its message: must not be blank' '    mealsPerDay = "9" · its message: must be less than or equal to 3' '    pricePerMeal = "0" · its message: must be greater than or equal to 1' '    mealType = "LUNCH" · its message: must match "VEG|NON_VEG|VEGAN"' '    messages on the page: 4')
TOMH='    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: Servlet.service() for servlet [dispatcherServlet] in context with path [] threw exception [Request processing failed: org.h2.jdbc.JdbcSQLDataException: Value too long for column "NAME CHARACTER VARYING(60)": '

# "The starter: five libraries more ... a controller whose routes return a view's name ... four templates and a stylesheet"
CO=$(cat .r-change.out)
for l in '  built the previous tree · offline: yes · exit 0' '  built after/ · offline: yes · exit 0' "  after/'s files: 33 · byte for byte the previous tree's: 25 · new: 6 · those that differ: 2" '  tiffinbox-web/pom.xml: 130 lines -> 137' '    +      <artifactId>spring-boot-starter-thymeleaf</artifactId>' \
         '    @Controller' '    @ImportRuntimeHints(DashboardPage.TemplateHints.class)' '    final class DashboardPage {' '                hints.reflection().registerType(Dashboard.View.class, MemberCategory.INVOKE_PUBLIC_METHODS);' '                hints.reflection().registerType(Customer.class, MemberCategory.INVOKE_PUBLIC_METHODS);' \
         '        @GetMapping(value = "/dashboard", produces = MediaType.TEXT_HTML_VALUE)' '            model.addAttribute("customerCount", view.customers().size());' '            return "dashboard";' '        @GetMapping(value = "/customers/new", produces = MediaType.TEXT_HTML_VALUE)' \
         '        @PostMapping(value = "/customers", consumes = MediaType.APPLICATION_FORM_URLENCODED_VALUE)' '        String add(@Valid @ModelAttribute("customer") Customer customer, BindingResult errors) throws SQLException {' '                    errors.rejectValue("name", "taken", "a customer named " + customer.name() + " already exists");' '            return "redirect:/dashboard";' \
         '  templates/error/404.html in after/: no' '  spring.thymeleaf.prefix - type String · default "classpath:/templates/" · Prefix that gets prepended to view names when building a URL.' '  spring.thymeleaf.cache - type Boolean · default true · Whether to enable template caching.' \
         "the executable jar's BOOT-INF/lib: 56 jars -> 61 · only after/'s: attoparser-2.0.7.RELEASE.jar spring-boot-thymeleaf-4.1.1.jar thymeleaf-3.1.5.RELEASE.jar thymeleaf-spring6-3.1.5.RELEASE.jar unbescape-1.1.6.RELEASE.jar · only the previous tree's: 0" \
         "the classes in the jar's com/tiffinbox/web: 9 -> 11 · only after/'s: DashboardPage\$TemplateHints.class DashboardPage.class" \
         "the jar's templates and static files: static/css/tiffinbox.css templates/customer-form.html templates/dashboard.html templates/error/5xx.html templates/fragments.html"; do has "$CO" "$l" "change"; done
[ "$(n change '^  Files ')" = 2 ] && [ "$(n change '^  Only in ')" = 3 ] || die "change: two files differ (the README, the POM), three only in after/ (DashboardPage.java, static, templates)"
has "$CO" '    templates/customer-form.html: 17 · its th: attributes: th:action ×1, th:errors ×4, th:field ×4, th:if ×4, th:object ×1, th:replace ×3' "change: the form's th:object, th:field, th:errors"
has "$CO" '    templates/fragments.html: 12 · its th: attributes: th:fragment ×3, th:href ×3, th:text ×1' "change: three fragments"
[ "$(printf '%s\n' "$CO" | grep -c '^    templates/\|^    static/')" = 5 ] || die "change: four templates and a stylesheet"
echo "  change: the starter, 56 -> 61 libraries (the five named); DashboardPage a @Controller, three routes, TemplateHints, customerCount in Java, a taken name a field error; four templates (no error/404.html) and a stylesheet; 25 of 33 files byte for byte; 9 -> 11 web classes"

# "The seven are the same, byte for byte ... nineteen rows ... curl gets JSON, HTML gets the page ... Content-Language ... new is a name"
NG=$(cat .r-negotiate.out)
[ "$(printf '%s\n' "$NG" | grep -cxF "  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 0 · md5 $S466")" = 2 ] || die "negotiate: the seven 466c20ed on both trees, the mask 0"
has "$NG" '  lines that differ: 0 · the same, byte for byte: 7 (1 2 3 4 5 6 7)' "negotiate: the same, byte for byte: 7"
[ "$(printf '%s\n' "$NG" | grep -cxF '    WARN o.s.web.servlet.PageNotFound: Request method '"'"'GET'"'"' is not supported')" = 2 ] || die "negotiate: one WARN each, PageNotFound's"
has "$NG" "  the dispatcher servlet's rows: 16 · TiffinBox's routes: 7, sorted by path:" "negotiate: 16 rows before"
[ "$(seg "$NG" "$(gq 19511 /dashboard "$CHROMEA")" | sed -n 1,3p)" = "$(printf '%s\n' "$CL 200 · Content-Type: [application/json]$Z00" '  HTTP/1.1 200 · Content-Type: application/json · Content-Length: 92 · headers not shown: 1' '  body: {"customers":4,"monthRevenue":24300,"pausedDays":5,"names":["Meera","Priya","Ravi","Sunil"]}')" ] || die "negotiate: the previous tree answers a browser's Accept with the JSON"
seg "$NG" "$(nq 19511)" | grep -qxF "$CL 415 · Content-Type: [application/problem+json]$Z00" || die "negotiate: the previous tree answers a form's Content-Type with a 415"
has "$NG" "  the dispatcher servlet's rows: 19 · TiffinBox's routes: 10, sorted by path:" "negotiate: 19 rows after"
for l in '    GET  /dashboard        DashboardPage#page           produces: text/html · consumes: any' '    GET  /dashboard        TiffinBoxServer#dashboard    produces: any · consumes: any' '    POST /customers        DashboardPage#add            produces: any · consumes: application/x-www-form-urlencoded' '    GET  /customers/new    DashboardPage#form           produces: text/html · consumes: any'; do has "$NG" "$l" "negotiate: the routing table"; done
O2=$(blk negotiate "one URL, two answers" "")
[ "$(seg "$O2" "$(tq 19510 /dashboard)")" = "$JDASH$Z00" ] && [ "$(seg "$O2" "$(tq 19510 /dashboard application/json)")" = "$JDASH$Z00" ] || die "negotiate: curl's own Accept and JSON - the JSON dashboard"
[ "$(seg "$O2" "$(gq 19510 /dashboard)")" = "$(printf '%s\n' "$HT$Z00" "$HEADS" "$PDASH but these:" '    the counts: Customers: 4 · This month: 24300 · Paused days: 5' '    the table, first column: Meera Priya Ravi Sunil')" ] || die "negotiate: HTML alone - the page"
[ "$(seg "$O2" "$(gq 19510 /dashboard "$CHROMEA")")" = "$(printf '%s\n' "$HT$Z00" "$HEADS" "$PDASH")" ] || die "negotiate: Chrome's Accept - the page"
[ "$(seg "$O2" "$(tq 19510 /customers/new application/json)")" = '  {"detail":"no customer named new","instance":"/customers/new","status":404,"title":"Customer not found","name":"new"} 404 · Content-Type: [application/problem+json]'"$Z00" ] || die "negotiate: /customers/new for JSON - no customer named new"
[ "$(seg "$O2" "$(gq 19510 /customers/new)")" = "$(printf '%s\n' "$HT$Z00" "$HEADS" "$PFORM")" ] || die "negotiate: the form for HTML"
seg "$O2" "$(gq 19510 /dashboard text/html 'Accept-Language: de')" | grep -qxF '  HTTP/1.1 200 · Content-Type: text/html;charset=UTF-8 · Content-Language: de · Transfer-Encoding: chunked · headers not shown: 1' || die "negotiate: Accept-Language de - Content-Language: de"
has "$O2" "  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0" "negotiate: 0 and 0"
echo "  negotiate: the seven $S466 on both trees, the same, byte for byte: 7; rows 16 -> 19 (two GET /dashboard, two POST /customers, GET /customers/new); */* and JSON -> JSON; HTML and Chrome's Accept -> the page, Content-Language en-US (de when asked); /customers/new for JSON -> no customer named new; 0 and 0"

# "Both pages pull the same head, header and footer from one file ... seven lines, one different: the title"
FR=$(cat .r-fragments.out)
for l in '  3:<head th:fragment="head(title)">' '  9:<header th:fragment="header"><h1>TiffinBox</h1><nav><a th:href="@{/dashboard}">Dashboard</a> · <a th:href="@{/customers/new}">Add a customer</a></nav></header>' '  10:<footer th:fragment="footer"><p>TiffinBox · rendered on the server</p></footer>' \
         "  3:<head th:replace=\"~{fragments :: head('Dashboard')}\"></head>" "  3:<head th:replace=\"~{fragments :: head('Add a customer')}\"></head>" '  none - it names neither' \
         '  the dashboard'"'"'s head, header and footer lines against the form'"'"'s, line for line: 7 and 7 lines · lines that differ: 1 - <title>Dashboard · TiffinBox</title> against <title>Add a customer · TiffinBox</title>'; do has "$FR" "$l" "fragments"; done
[ "$(printf '%s\n' "$FR" | grep -cxF '    | <footer><p>TiffinBox · rendered on the server</p></footer>')" = 2 ] && [ "$(printf '%s\n' "$FR" | grep -cxF '    | <header><h1>TiffinBox</h1><nav><a href="/dashboard">Dashboard</a> · <a href="/customers/new">Add a customer</a></nav></header>')" = 2 ] || die "fragments: the header and the footer in both pages"
[ "$(printf '%s\n' "$FR" | grep -c "th:replace=\"~{fragments :: ")" = 6 ] || die "fragments: three th:replace lines in each page's template"
echo "  fragments: three th:fragment lines, three th:replace in each page; head, header and footer 7 lines each, 1 differs (the title); the error page names neither"

# "A valid form: three oh two to the dashboard ... four rules, four messages ... in German when asked ... letters for a number ... taken ...
#  the JSON POST still two oh one ... the four fifteen is gone"
FO=$(cat .r-form.out)
has "$FO" '  HTTP/1.1 302 · Location: http://127.0.0.1:19510/dashboard · Content-Language: en-US · Content-Length: 0 · headers not shown: 1' "form: 302 to the dashboard"
[ "$(seg "$FO" "$(fq 19510 "$B_LATA")" | sed -n 1p)" = "$CL 302 · Content-Type: []$Z00" ] && seg "$FO" "$(fq 19510 "$B_LATA")" | grep -qxF '  body: none (0 bytes)' || die "form: the redirect, no body"
has "$FO" '    the counts: Customers: 5 · This month: 31500 · Paused days: 5' "form: five customers"; has "$FO" '    the table, first column: Lata Meera Priya Ravi Sunil' "form: Lata in the table"
[ "$(seg "$FO" "$(fq 19510 "$B_BAD")" | tail -5)" = "$FOUR" ] || die "form: four rules, four messages, in the JVM's English"
seg "$FO" "$(fq 19510 "$B_BAD")" | grep -qxF '  HTTP/1.1 200 · Content-Type: text/html;charset=UTF-8 · Content-Language: en-US · Transfer-Encoding: chunked · headers not shown: 1' || die "form: the form again, 200"
S_DE=$(seg "$FO" "$(fq 19510 "$B_BAD" 'Accept-Language: de')")
for l in '    name = "" · its message: darf nicht leer sein' '    mealsPerDay = "9" · its message: muss kleiner-gleich 3 sein' '    messages on the page: 4' '  HTTP/1.1 200 · Content-Type: text/html;charset=UTF-8 · Content-Language: de · Transfer-Encoding: chunked · headers not shown: 1'; do has "$S_DE" "$l" "form: German, when the request names it"; done
has "$(seg "$FO" "$(fq 19510 "$B_TWO")")" '    mealsPerDay = "two" · its message: Failed to convert value of type java.lang.String to required type int; For input string: "two"' "form: Spring's raw conversion message"
has "$(segn 2 "$FO" "$(fq 19510 "$B_LATA")")" '    name = "Lata" · its message: a customer named Lata already exists' "form: a taken name"
[ "$(seg "$FO" "$(pq 19510 "$B_ASHA")")" = '  {"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 201 · Content-Type: [application/json]'"$Z00" ] || die "form: the JSON POST still 201"
S_NQ=$(seg "$FO" "$(nq 19510)")
[ "$(printf '%s\n' "$S_NQ" | sed -n 1p)" = "$HT$Z00" ] && has "$S_NQ" '    mealsPerDay = "" · its message: Failed to convert value of type null to required type int; Failed to convert from type [null] to type [@jakarta.validation.constraints.Min @jakarta.validation.constraints.Max int] for value [null]' "form: no Content-Type - the form" && has "$S_NQ" '    messages on the page: 1' "form: one message" || die "form: the request-body lesson's POST without its Content-Type - 200, the form, one raw message"
has "$FO" '    the table, first column: Asha Lata Meera Priya Ravi Sunil' "form: Asha by JSON, Lata by the form"
has "$FO" "  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0" "form: 0 and 0"
echo "  form: 302 Location /dashboard, no body, Lata in the table (5); four messages (the JVM's English; German for Accept-Language de); two -> Spring's raw message; Lata again -> already exists; JSON 201; no Content-Type -> 200 the form (was 415); 0 and 0"

# "A refusal nobody handles ... five hundred ... TiffinBox's own error page, Boot's JSON for curl ... the template's typo: two ERROR lines,
#  Thymeleaf's then Tomcat's, the JSON route still two hundred ... error/404.html: never"
ER=$(cat .r-errors.out); E1=$(blk errors "a refusal nobody handles" "a template that is wrong"); E2=$(blk errors "a template that is wrong" "C (labelled)"); E3=$(blk errors "C (labelled)" "")
S_L=$(seg "$E1" "$(fq 19510 "$B_LONG" 'Accept: text/html')")
[ "$(printf '%s\n' "$S_L" | sed -n 1,4p)" = "$(printf '%s\n' "$CL 500 · Content-Type: [text/html;charset=UTF-8] · WARN lines it added: 0 · ERROR lines: 1" '  HTTP/1.1 500 · Content-Type: text/html;charset=UTF-8 · Content-Language: en-US · Transfer-Encoding: chunked · headers not shown: 2' "$P5XX" '    The server failed on /customers: status 500.')" ] || die "errors: a 500 for HTML - TiffinBox's error page"
printf '%s\n' "$S_L" | grep -qF -- "$TOMH" || die "errors: the 500's ERROR line is Tomcat's, H2's refusal in it"
S_J=$(seg "$E1" "$(fq 19510 "$B_LONG")")
[ "$(printf '%s\n' "$S_J" | sed -n 1,3p)" = "$(printf '%s\n' "$CL 500 · Content-Type: [application/json] · WARN lines it added: 0 · ERROR lines: 1" '  HTTP/1.1 500 · Content-Type: application/json · Transfer-Encoding: chunked · headers not shown: 2' '  body: {"timestamp":"…","status":500,"error":"Internal Server Error","path":"/customers"}')" ] || die "errors: the same 500 for curl - Boot's JSON"
S_T=$(seg "$E2" "$(gq 19512 /dashboard)")
[ "$(printf '%s\n' "$S_T" | sed -n 1p)" = "$CL 500 · Content-Type: [text/html;charset=UTF-8] · WARN lines it added: 0 · ERROR lines: 2" ] && has "$S_T" "$P5XX" "errors: the typo, the error page" && has "$S_T" '    The server failed on /dashboard: status 500.' "errors: the typo's path" || die "errors: the typo - 500, the error page, 2 ERROR"
printf '%s\n' "$S_T" | grep -qxF '    ERROR org.thymeleaf.TemplateEngine: [THYMELEAF][tomcat-handler-<n>] Exception processing template "dashboard": Exception evaluating SpringEL expression: "view.custmers" (template: "dashboard" - line 10, col 9)' || die "errors: the first ERROR is Thymeleaf's, naming the template, the expression and its line"
printf '%s\n' "$S_T" | grep -qF '    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: Servlet.service() for servlet [dispatcherServlet] in context with path [] threw exception [Request processing failed: org.thymeleaf.exceptions.TemplateProcessingException: Exception evaluating SpringEL expression: "view.custmers"' || die "errors: the second ERROR is Tomcat's"
has "$S_T" "      org.springframework.expression.spel.SpelEvaluationException: EL1008E: Property or field 'custmers' cannot be found on object of type 'com.tiffinbox.Dashboard\$View' - maybe not public or not valid?" "errors: SpEL's EL1008E"
[ "$(seg "$E2" "$(tq 19512 /dashboard)")" = "$JDASH$Z00" ] || die "errors: the typo copy's JSON dashboard still 200"
[ "$(seg "$E2" "$(gq 19512 /customers/new)")" = "$(printf '%s\n' "$HT$Z00" "$HEADS" "$PFORM")" ] || die "errors: the typo copy's form still 200"
has "$E2" '  >     <tr th:each="c : ${view.custmers}">…' "errors: the one line the copy changes"; [ "$(printf '%s\n' "$E2" | grep -c '^  [<>] ')" = 2 ] || die "errors: one line differs"
has "$E3" '  the copy'"'"'s error templates: 404.html 5xx.html' "errors C: error/404.html in the copy"
P404='  body: {"detail":"No static resource nowhere.","instance":"/nowhere","status":404,"title":"Not Found"}'
for q in "$(gq 19512 /nowhere)" "$(gq 19512 /nowhere "$CHROMEA")"; do [ "$(seg "$E3" "$q")" = "$(printf '%s\n' "$CL 404 · Content-Type: [application/problem+json]$Z00" '  HTTP/1.1 404 · Content-Type: application/problem+json · Transfer-Encoding: chunked · headers not shown: 1' "$P404")" ] || die "errors C: /nowhere for HTML - the problem detail, never error/404.html"; done
seg "$E3" "$(gq 19512 /customers/Nobody "$CHROMEA")" | grep -qxF '  body: {"detail":"no customer named Nobody","instance":"/customers/Nobody","status":404,"title":"Customer not found","name":"Nobody"}' || die "errors C: Nobody with Chrome's Accept - the problem detail"
nhas "$ER" 'Not found · TiffinBox' "errors C: error/404.html never rendered"
echo "  errors: a 61-letter name -> 500, error/5xx.html for HTML, Boot's JSON for curl, 1 ERROR Tomcat's; the typo -> 500, the error page, 2 ERROR (TemplateEngine, then Tomcat's; EL1008E), the JSON route 200; C: error/404.html present, the 404s still problem details"

# "Edit while it runs ... with the cache on, the page already rendered keeps its old footer; a page asked for the first time reads the edit
#  ... cache off: every request reads it ... DevTools: ten defaults ... the template-availability cache"
DT=$(cat .r-devtools.out)
for l in '  spring.thymeleaf.cache - type Boolean · default true · Whether to enable template caching.' '  spring.template.provider.cache - entries in the 61 libraries'"'"' metadata: 0' '  1' '     1 Keys the JVM'"'"'s locale: en_US' '     2 Keys the property source devtools: 10 keys' '     6 Keys   spring.template.provider.cache = false' '     7 Keys   spring.thymeleaf.cache = false' '    13 Keys property sources whose name says devtools: 1' '  listening on 35729 (Live Reload) now: 0'; do has "$DT" "$l" "devtools: the keys"; done
[ "$(printf '%s\n' "$DT" | grep -cE '^ +[0-9]+ Keys   [a-z]')" = 10 ] || die "devtools: DevTools' ten keys, each printed"
OLDF='    | <footer><p>TiffinBox · rendered on the server</p></footer>'; NEWF='    | <footer><p>TiffinBox · edited while it runs</p></footer>'
foots() { printf '%s\n' "$1" | grep -E '^    \| <footer>' | sed 's/^    | <footer><p>TiffinBox · //; s/<\/p><\/footer>$//' | paste -sd'|' -; }
DA=$(blk devtools "A - " "B - "); DB=$(blk devtools "B - " "A' - "); DA2=$(blk devtools "A' - " "A' against A")
[ "$(foots "$DA")" = 'rendered on the server|rendered on the server|edited while it runs' ] || die "devtools A: the dashboard keeps the old footer, the form (first asked) reads the edit"
[ "$(foots "$DB")" = 'rendered on the server|edited while it runs|edited while it runs' ] || die "devtools B: cache off - every request reads the edit"
[ "$(foots "$DA2")" = "$(foots "$DA")" ] || die "devtools A': A's footers"
x devtools "^A' against A, its label aside, line for line the same: yes\$"
printf '%s\n' "$DB" | grep -qxF "\$ cd .harness/fold && ${L_TCF/18431/19512}" && printf '%s\n' "$DA2" | grep -qxF "\$ cd .harness/fold && ${L_FOLD/18431/19512}" || die "devtools: B's and A''s \$ lines"
C1=$(blk devtools "C (labelled)" "C - the same"); C2=$(blk devtools "C - the same" "")
WLP="  the Whitelabel page (Boot's) - its <h1>: Whitelabel Error Page · its error line: There was an unexpected error (type=Internal Server Error, status=500). · its created date: masked · its paragraphs: 1, not shown"
[ "$(printf '%s\n' "$C1" | grep -cxF "$WLP")" = 2 ] && [ "$(printf '%s\n' "$C1" | grep -cxF "$P5XX")" = 0 ] || die "devtools C: the default cache - the Whitelabel page twice, the added error page never found"
[ "$(printf '%s\n' "$C2" | grep -cxF "$WLP")" = 1 ] && [ "$(printf '%s\n' "$C2" | grep -cxF "$P5XX")" = 1 ] || die "devtools C: the cache off - the Whitelabel page, then the added error page"
printf '%s\n' "$C2" | grep -qxF "\$ cd .harness/fold && ${L_TPF/18431/19512}" || die "devtools C: its \$ line"
echo "  devtools: Thymeleaf's cache default true (metadata); A: the dashboard old footer, the form new; B: both new; A' = A; DevTools 10 keys, thymeleaf and template.provider false, 35729 free; C: the provider cache (no metadata entry, named in Boot's class) - an added error page unseen until it is off"

# the exercise's end state: the README's commands, then the solution's, in ONE env -i shell
XS=$(blk exercise "the README's" "the solution's"); XE=$(blk exercise "the solution's" '')
X_SHIP='the dashboard: 500 · text/html;charset=UTF-8 · Something broke · TiffinBox'; X_END='the dashboard: 200 · text/html;charset=UTF-8 · Dashboard · TiffinBox'
has "$XS" "    $X_SHIP" "exercise: as shipped"; has "$XE" "    $X_END" "exercise: the solution"
awk '/^\*\*Done\*\*/ { f = 1 } f' exercise/README.md | grep -qxF -- "$X_END" || die "exercise/README.md: Done names no such line"
grep -qxF -- "$X_END" exercise/solution/SOLUTION.md || die "SOLUTION.md: the measured run shows no such line"
grep -qF -- "\`$X_SHIP\`" exercise/README.md || die "exercise/README.md: the shipped line's answer is not named"
has "$XS" "  the shell is now in: this unit's folder · the copy's own token in its log: 0 times · WARN lines in its log: 0 · ERROR lines: 2 · listening on 19518 now: 0" "exercise: 2 ERROR, the port free"
has "$XS" '    org.thymeleaf.TemplateEngine: [THYMELEAF][tomcat-handler-<n>] Exception processing template "dashboard": Exception evaluating SpringEL expression: "view.custmers"' "exercise: Thymeleaf's line names the expression"
has "$XE" "  the shell is now in: this unit's folder · the copy's own token in its log: 0 times · WARN lines in its log: 0 · ERROR lines: 0 · listening on 19518 now: 0" "exercise: 0 ERROR, the shell in this unit's folder"
has "$XE" "  the copy's template against after/'s: the same, byte for byte" "exercise: the fix is after/'s line"
[ "$(diff "after/$RS/templates/dashboard.html" "$XT" | grep -c '^[<>]')" = 2 ] && grep -qF '${view.custmers}' "$XT" || die "harness/exercise/dashboard.html must be after/'s with one name misspelt"
EXQ="Your turn: the README's dashboard answers five hundred with TiffinBox's error page. Find the misspelt name in the template, fix it, and reload."
grep -qxF -- "**Your turn:** ${EXQ#Your turn: }" exercise/README.md || die "exercise/README.md: the spoken exercise line"
[ "$(printf '%s\n' "$EXQ" | wc -w | tr -d ' ')" -le 25 ] || die "exercise: the spoken line is over 25 words"
echo "  exercise: one env -i shell - the README as written (view.custmers) -> 500 the error page, 2 ERROR; the solution -> 200 the dashboard; the shell in this unit's folder after each"

# "Native: the template reads two records by reflection ... registered ... every page, in every form: the jar, the AOT jar, the binary, the image"
FM=$(cat .r-forms.out)
x forms '^  exit 0 · BUILD SUCCESS · stages it printed: 8 of the 8 it announces · its lines that say the metadata repository was downloaded over http, or failed to: 0 · offline: yes$'
x forms '^  file: Mach-O 64-bit executable · the demo token in its bytes: 0$'
x forms "^  Spring's generated metadata \(spring-aot/main/resources/META-INF/native-image/com\.tiffinbox/tiffinbox-web/reachability-metadata\.json\) - the previous tree's against after/'s: reflection entries 670 -> 687 · types only the previous tree registers: none · only after/: 17 · entries that differ: 1\$"
has "$FM" '    only after/: com.tiffinbox.Dashboard$View - allPublicMethods · 0 methods' "forms: the hint registers Dashboard.View"
has "$FM" '    differs: com.tiffinbox.Customer - its methods only before: none · only after: none · its other keys only before: none · only after: allPublicMethods' "forms: the hint adds Customer's public methods"
has "$FM" '  resource entries: 26 -> 30 · only after/: static static/** templates templates/**' "forms: the templates and the stylesheet in the binary's resources"
has "$FM" "four forms, one tree: the seven (masked) 4 of 4 times $S466 · the dashboard page: 8 of 8 · the form's four messages: 4 of 4 · a valid POST, 302 to the dashboard: 4 of 4 · the error page: 4 of 4" "forms: every page in every form"
has "$FM" '  loopback, form by form: the jar yes · the AOT jar yes · the binary yes · the image, published on 127.0.0.1 alone yes' "forms: loopback"
for t in '1 the jar:19510:2 the AOT jar' '2 the AOT jar:19514:3 the binary' '3 the binary:19516:4 the image' '4 the image:19515:four forms, one tree'; do lb_=${t%%:*}; r_=${t#*:}; p_=${r_%%:*}; nx_=${r_#*:}
  b=$(blk forms "$lb_ - " "$nx_")
  has "$b" "  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 0 · md5 $S466" "forms $lb_: the seven"
  has "$b" "  HTTP/1.1 302 · Location: http://127.0.0.1:$p_/dashboard · Content-Language: $( [ "$p_" = 19516 ] && echo en || echo en-US) · Content-Length: 0 · headers not shown: 1" "forms $lb_: the redirect on its own port"
  has "$b" '    the table, first column: Lata Meera Priya Ravi Sunil' "forms $lb_: Lata in the table"
  has "$b" "$P5XX" "forms $lb_: the error page"; has "$b" '    The server failed on /customers: status 500.' "forms $lb_: the error page's line"
  case "$NLC$b$NLC" in *"$NLC$FOUR$NLC"*) ;; *) die "forms $lb_: the four messages, in English, one after the other" ;; esac
  has "$b" '  {"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 201 · Content-Type: [application/json]' "forms $lb_: the JSON POST 201"; done
[ "$(n forms "^  Boot's first line: Starting AOT-processed TiffinBoxServer v1\.0\.0 using Java 25\.0\.4\.1\$")" = 2 ] && [ "$(n forms "^  Boot's first line: Starting AOT-processed TiffinBoxServer using Java 25\.0\.4\.1\$")" = 2 ] || die "forms: the AOT jar and the binary, AOT-processed, both starts"
[ "$(n forms '^  inside the container, listening: \[::\]:18425$')" = 2 ] && [ "$(n forms '^  docker port: 18425/tcp -> 127\.0\.0\.1:19515$')" = 2 ] || die "forms: the image, two containers, 18425 inside, published on 127.0.0.1:19515 alone"
x forms '^  its lines that say pull: 0 · '
x forms '^  the image saved \(docker save\): [1-9][0-9]* blobs, its [1-9][0-9]* layers among them, each read whole \(gzip ones unpacked\) · the demo token in them: 0$'
echo "  forms: 8 of 8 stages, offline, Mach-O, 0 tokens; AOT 670 -> 687 - Dashboard\$View allPublicMethods, Customer's public methods, Thymeleaf's configuration, templates/** and static/**; the jar, the AOT jar, the binary, the image: the seven 4 of 4, the dashboard 8 of 8, four messages, the 302, the error page and the JSON 201 4 of 4 each; loopback form by form; 0 tokens in the image's layers"

# "In Chrome: the page, the header it sent - the one curl sends - the form's POST, three oh two, the dashboard ... the server saw the same"
if [ -f .r-browser.out ]; then BR=$(cat .r-browser.out)
  V1=$(blk browser "visit 1 - " "visit 2 - "); V2=$(blk browser "visit 2 - " "visit 3 - "); V3=$(blk browser "visit 3 - " "\$ node harness/cdp.mjs 19519 close")
  has "$BR" '  its profile, .harness/chrome, made fresh for this run (it did not exist before this line): yes' "browser: a fresh profile"
  has "$BR" "  Chrome's DevTools port: 127.0.0.1:19519 · loopback only: yes" "browser: Chrome's port, loopback"
  has "$BR" '  Chrome exit 0 · listening on 19519 now: 0 · its profile removed' "browser: Chrome left, exit 0"
  has "$BR" "  Chrome's NetLog - every address it connected to or tried, its own background requests included: 127.0.0.1 only: yes · ports 19517 among them: yes" "browser: the seal"
  has "$V1" '  the page Chrome shows: Dashboard · TiffinBox · its address: /dashboard · its table, first column: Meera Priya Ravi Sunil' "browser 1: the page"
  has "$V1" '    GET /dashboard - the answer Chrome got: 200 text/html' "browser 1: Chrome's record, 200"
  [ "$(printf '%s\n' "$V1" | grep -cxF "        Accept: $CHROMEA")" = 1 ] && [ "$(printf '%s\n' "$V1" | grep -cE "^ +[0-9]+ Dump +>   Accept: $(printf '%s' "$CHROMEA" | sed 's/[][\\.^$*+?(){}|/]/\\&/g')\$")" = 1 ] || die "browser 1: Chrome's Accept, as Chrome sent it and as the server read it, is the one the curl captures send"
  for h in 'Accept-Language: en-US,en;q=0.9' 'Sec-Fetch-Dest: document' 'Sec-Fetch-Mode: navigate' 'Sec-Fetch-Site: none'; do has "$V1" "        $h" "browser 1: as Chrome sent it"; done
  has "$V1" '      16 Dump            < 200 GET /dashboard' "browser 1: the server's 200"; has "$V1" '      18 Dump            <   Content-Language: en-US' "browser 1: the server's Content-Language"
  has "$V2" '  the page Chrome shows: Dashboard · TiffinBox · its address: /dashboard · its table, first column: Kiran Meera Priya Ravi Sunil' "browser 2: Kiran in the table, the address /dashboard"
  has "$V2" "  Chrome's own record (its DevTools protocol) - the documents the tab asked TiffinBox for: 3" "browser 2: three documents"
  has "$V2" '    POST /customers - the answer Chrome got: 302 · Location: http://127.0.0.1:19517/dashboard' "browser 2: Chrome's POST, 302"
  has "$V2" '      the form'"'"'s body, as Chrome sent it: name=Kiran&mealsPerDay=1&pricePerMeal=130&mealType=VEGAN' "browser 2: the form's body"
  P2=$(printf '%s\n' "$V2" | awk '/^    POST \/customers - the answer Chrome got: 302/ { f = 1 } f && /^    GET / { exit } f')
  for h in 'Content-Type: application/x-www-form-urlencoded' 'Origin: http://127.0.0.1:19517' 'Sec-Fetch-Site: same-origin' 'Sec-Fetch-Mode: navigate'; do has "$P2" "        $h" "browser 2: the POST as Chrome sent it"; done
  [ "$(printf '%s\n' "$V2" | grep -c '^    GET /dashboard - the answer Chrome got: 200 text/html$')" = 1 ] || die "browser 2: Chrome followed the redirect with a GET"
  has "$V2" '      43 Dump            < 302 POST /customers' "browser 2: the server's 302"; has "$V2" '      44 Dump            <   Location: http://127.0.0.1:19517/dashboard' "browser 2: the server's Location"
  has "$V2" '      35 Dump            >   Origin: http://127.0.0.1:19517' "browser 2: the server read the Origin"
  has "$V3" '  the page Chrome shows: Add a customer · TiffinBox · its address: /customers · its messages: must not be blank | must be less than or equal to 3 | must be greater than or equal to 1 | must match "VEG|NON_VEG|VEGAN"' "browser 3: four messages, in English"
  has "$V3" '    POST /customers - the answer Chrome got: 200 text/html' "browser 3: 200, the form again"
  [ "$(printf '%s\n' "$BR" | grep -cxF '    WARN lines they added: 0 · ERROR lines: 0')" = 3 ] || die "browser: 0 and 0 for each visit"
  echo "  browser: a fresh sealed profile, NetLog 127.0.0.1 only; 1 - the page, Chrome's Accept = the curl captures' (both witnesses); 2 - POST form-urlencoded, Origin, same-origin -> 302 -> GET /dashboard, Kiran; 3 - four messages in English; 0 and 0"; fi

cmp -s after/README.md ../c6-tiffinbox/README.md || echo "  (after/README.md and ../c6-tiffinbox/README.md differ - the anchor has moved past this unit's after/)" >&3
[ -z "$unpub" ] || die "no published hash for:$unpub - check the captures, then copy the md5s above into receipts.md5 and run again"
echo "c6-unit22: every capture 3/3 and = published; every spoken number asserted; 0 raw demo tokens in every capture, every log, the container's log, the image's layers and the binary; nothing of this run left on Docker"
