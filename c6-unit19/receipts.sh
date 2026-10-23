#!/bin/bash
XPATH=$PATH                                           # the PATH you started this with: the exercise's own shell gets it
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25.0.4.1 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"   # the Chrome app on the author's Mac: point it at yours
# Course 6 · CORS and Preflight - this unit's receipts. No anchor change: anchor/ is the link to ../c6-unit16/after, the tree the
# problem-detail lesson froze (= c6-tiffinbox at Section 3's end). This script copies that tree under .harness/anchor, builds it and
# runs it - as its README runs it, and on its class path with the course's harness joined (harness/probe/web, outside com.tiffinbox) -
# and asks it the question a browser asks before a cross-origin PUT: a preflight. First by curl, then the three ways Spring MVC can
# answer it, then from a real browser - headless Chrome, a profile of its own made fresh for each run, sealed to 127.0.0.1 - with a page
# served from another origin by jwebserver, the JDK's own file server.
# Five captures, each run three times and hashed; cap() DIES when a hash differs from receipts.md5; every number the video says is
# asserted at the bottom by a check that can fail; the demo token is masked (gsub), and the checks count 0 raw copies of it in every
# capture, in the log of every run and in every file this unit ships.
#   preflight  the anchor built and extracted; the harness compiled; the seven on the jar; then CorsRoutes (one route with
#              @CrossOrigin for http://127.0.0.1:19486) with Hooks: preflights by curl from the origin the rule allows, from one it
#              does not, and to a path no rule covers; the actual requests; an OPTIONS with no Origin at all
#   ways       the annotation and the registry (GlobalCors) side by side, their answers compared line for line; then A/B/A':
#              A - CorsRoutes alone; B - FilterCors joined (a CorsFilter on every path, its one rule for /probe/filter/**); A' - A again
#   star       StarCreds - any origin ("*") and credentials on one global mapping: it starts, then every request to that mapping
#   exercise   exercise/README.md's commands, then exercise/solution/SOLUTION.md's, read from the files and run as written, one after
#              the other in ONE shell a viewer could have: env -i, /bin/bash, started in this folder
#   browser    two origins (jwebserver on 19486 and 19487, serving harness/www/cors.html), TiffinBox with Dump (the server's record
#              of every request, whole), CorsRoutes and Hooks, and Chrome: the allowed PUT, the same page again seven seconds later
#              (past Chrome's own few seconds for an answer with no max age), the PUT from the other origin, a simple GET from it; then
#              C (labelled): FilterCors joined, the allowed PUT, in a fresh profile; D (labelled), the control: the filter's own path,
#              whose answer has no max age, visited twice seven seconds apart - Chrome asks again
# "The anchor" is anchor/, the link to ../c6-unit16/after, COPIED under .harness/anchor; this script never writes into another unit's
# folder, and never builds a frozen tree in place. Every run of TiffinBox starts in .harness/anchor, which holds a config tree with a
# fake token (secrets/), as the README asks. Commands are printed exactly as they run: each goes through eval. "$CURLSET" is the
# comparison set since the secrets lesson (../c5-unit11/curlset.sh). "$M2" is this unit's own repository, .m2-demo. "$CHROME" is the
# Chrome app (above). The harness - harness/probe/web (compiled with -parameters): CorsRoutes, GlobalCors, FilterCors, StarCreds, Dump;
# Trace, Hooks, Interceptor and ProbeOops, the last lesson's, unchanged (checked) - is the course's, never TiffinBox's: outside
# com.tiffinbox, joined by --spring.main.sources on the extracted jar's class path, and named on every capture that uses it;
# harness/www/cors.html is the page; harness/cdp.mjs drives Chrome over its DevTools protocol (node's own WebSocket); harness/net.py
# reads Chrome's record of the page's requests; harness/netlog.py reads Chrome's NetLog; harness/shutdown.sh is POST /shutdown with
# the token read from its file. Every run passes options only. The seven run first, on a fresh JVM of the jar.
# The locale: the JVM ignores LC_ALL on macOS - every JVM this script starts has its locale pinned on its run line (-Duser.language=en
# -Duser.country=US, before -jar or -cp; jwebserver's JVM by -J), every harness JVM prints it (Hooks), and the checks assert en_US.
# Chrome runs with --lang=en-US, and its requests say so (Accept-Language).
# The network: every Maven build runs offline (-o) against .m2-demo and says so ("offline: yes"); a build that cannot resolve an
# artifact offline goes to Maven Central once, and says that. No native build and no Docker. At run time nothing leaves 127.0.0.1:
# TiffinBox, both origins and Chrome's DevTools port listen there (read off each process), every request goes there, and Chrome's own
# background requests go to a proxy address where nothing listens (127.0.0.1:9) - its NetLog is read: every address it connected to or
# tried is 127.0.0.1. Chrome never touches a profile but the one this script makes, and is stopped by its pid, never by its name.
# Without Chrome or node (22 or later) every curl capture is made and checked, and the script stops at the browser step (exit 2).
# Masks and filters (README.md declares each; awk sub/gsub only): the demo token, this folder, the folder above, home, your user name, as
# in the last lesson; Spring's error timestamp; a Date header's value; Chrome's version in its User-Agent ("Chrome/<version>") and its
# sec-ch-ua brand list (masked whole); the platform - the User-Agent's first brackets ("Mozilla/5.0 (<platform masked>)") and
# sec-ch-ua-platform's value ("(<platform masked>)"): a viewer's Chrome on another system sends other words there (RED S4 #305, #381);
# both are printed on the terminal, beside the version, never in a capture. curl's header lines lose their carriage return and trailing spaces. A run's log lines are printed
# from their logger on; a WARN or ERROR record as its level, logger and message, then its exception line, its frames bounded and counted.
# The harness's lines (Trace: Dump's record and the hooks) are printed in the order they ran, numbered from 1 for each request.
# Ports (brief ⚑1, 19480-19489): preflight - the seven and the routes 19480 · ways - the two ways 19481, A and A' 19482, B 19483 ·
# star 19481 · browser - TiffinBox 19484, C 19485, the origins 19486 and 19487, Chrome's DevTools port 19489 · the exercise 19488.
# Captures run one after another, each process stopped (and its port checked free) before the next starts on its port. 18425, 8080
# and 35729 are checked free too, and never bound.
set -e
# bash 5.2 and later turn an & in the replacement of ${x/pattern/replacement} into the matched text (patsub_replacement, on by
# default). Switched off, so /bin/bash 3.2 (./receipts.sh) and a newer bash (bash receipts.sh) run the same commands.
shopt -u patsub_replacement 2> /dev/null || true
export LC_ALL=C
cd "$(dirname "$0")"
mkdir .r-lock 2> /dev/null || { echo "  *** another receipts.sh is running in this folder (.r-lock exists) - if none is, rmdir .r-lock ***"; exit 1; }
U="$PWD"; UP="$(cd .. && pwd)"; ME="$(id -un)"
# On every exit - the end, a failed check, or Ctrl-C - stop the processes this script started in the background, if they still run:
# $pid (TiffinBox), $xpid (the exercise's shell, with every process under it), $cpid (Chrome, with every process under it), $j1 and $j2
# (the two jwebservers); then sweep(): anything of this run still alive - in its process group, a TiffinBox JVM, a Maven or a jwebserver;
# anywhere, a process started with this unit's own Chrome profile - is stopped. The profile is removed. After an interrupt, a
# capture's unfinished runs (.r-NAME.1-3) go too. The clean-up ignores a second Ctrl-C, and nothing in it can fail under set -e; the
# script still exits 130 after an interrupt. No wait in this script is bare: each names its pid.
pid=""; xpid=""; cpid=""; j1=""; j2=""
sweep() { local g i l
  g=$(ps -o pgid= -p $$ 2> /dev/null | tr -d ' ') || g=""
  i=0; while [ $i -lt 20 ]; do
    l=$(ps -axo pid=,pgid=,command= 2> /dev/null | awk -v g="$g" -v me=$$ -v prof="--user-data-dir=$U/.harness/chrome" '
      $1 != me && $3 != "awk" && $3 != "ps" && (index($0, prof) || ($2 == g && (index($0, "tiffinbox-web-1.0.0.jar") || index($0, "com.tiffinbox.web.TiffinBoxServer") || index($0, "org.codehaus.plexus.classworlds.launcher.Launcher") || index($0, "jdk.httpserver")))) { print $1 }' | paste -sd' ' -) || l=""
    [ -n "$l" ] || return 0
    if [ $i -lt 10 ]; then kill $l 2> /dev/null || true; else kill -9 $l 2> /dev/null || true; fi
    sleep 0.5; i=$((i + 1)); done; }
desc() { ps -axo pid=,ppid= 2> /dev/null | awk -v r="$1" '{ p[$1] = $2 } END { n = 1; q[1] = r; for (i = 1; i <= n; i++) for (c in p) if (p[c] == q[i]) { q[++n] = c; print c } }'; }
killtree() { local d; d=$(desc "$1"); kill "$1" $d 2> /dev/null || true; }
trap 'trap "" INT TERM; for p in "$xpid" "$cpid"; do [ -z "$p" ] || killtree "$p"; done; for p in "$pid" "$xpid" "$cpid" "$j1" "$j2"; do if [ -n "$p" ] && kill "$p" 2> /dev/null; then wait "$p" 2> /dev/null || true; fi; done; sweep || true; rm -rf .harness/chrome 2> /dev/null || true; [ -z "$INTR" ] || rm -f .r-*.[123]; rmdir .r-lock 2> /dev/null || true' EXIT
INTR=""; trap 'INTR=1; exit 130' INT TERM
exec 3>&1                                            # die() speaks to the terminal even inside a redirected capture
die() { echo "  *** $* ***" >&3; exit 1; }
java -version 2>&1 | grep -q 'version "25' || die "JDK 25 needed; JAVA_HOME gives: $(java -version 2>&1 | head -1)"
for t in python3 curl rsync lsof unzip javac mvn jwebserver; do command -v $t > /dev/null || die "$t is needed"; done
# The browser step needs Chrome and node 22 or later (its built-in WebSocket); both are optional: without them the curl captures run
BROWSER=yes; WHYNOT=""
[ -x "$CHROME" ] || { BROWSER=no; WHYNOT="no Chrome at $CHROME"; }
NODEV=$(node --version 2> /dev/null | sed -E 's/^v([0-9]+).*/\1/') || NODEV=""
case "$NODEV" in ''|*[!0-9]*) BROWSER=no; WHYNOT="${WHYNOT:+$WHYNOT; }no node" ;; *) [ "$NODEV" -ge 22 ] || { BROWSER=no; WHYNOT="${WHYNOT:+$WHYNOT; }node $NODEV is older than 22"; } ;; esac
# A variable of yours must not become a property source, a JVM flag or a build setting (the last course's failure lesson's loop,
# verbatim: sed -E, a canary planted under every name first, and the run stops if one survives).
for v in TIFFINBOX_CANARY SPRING_CANARY MANAGEMENT_CANARY SERVER_CANARY LOGGING_CANARY DEBUG JAVA_TOOL_OPTIONS JDK_JAVA_OPTIONS _JAVA_OPTIONS MAVEN_OPTS MAVEN_ARGS NATIVE_IMAGE_OPTIONS; do export "$v=planted-canary"; done
for v in $(env | sed -n -E 's/^(TIFFINBOX_[A-Za-z0-9_]*|SPRING_[A-Za-z0-9_]*|MANAGEMENT_[A-Za-z0-9_]*|SERVER_[A-Za-z0-9_]*|LOGGING_[A-Za-z0-9_]*|DEBUG|JAVA_TOOL_OPTIONS|JDK_JAVA_OPTIONS|_JAVA_OPTIONS|MAVEN_OPTS|MAVEN_ARGS|NATIVE_IMAGE_OPTIONS)=.*/\1/p'); do unset "$v"; done
[ -z "$(env | grep -- '=planted-canary$')" ] || die "a variable survived the clean-up above: $(env | grep -- '=planted-canary$' | sed 's/=.*//' | paste -sd' ' -)"
# Every request this script makes goes to 127.0.0.1: an HTTP proxy named in your environment would carry curl's requests (and node's)
# to that proxy instead - 127.0.0.1 and localhost go first in no_proxy and NO_PROXY.
export no_proxy="127.0.0.1,localhost${no_proxy:+,$no_proxy}" NO_PROXY="127.0.0.1,localhost${NO_PROXY:+,$NO_PROXY}"
[ -e secrets ] && die "this folder holds a secrets/ - remove it: every run here starts in a folder under .harness/"
[ -L anchor ] && [ "$(readlink anchor)" = ../c6-unit16/after ] || die "anchor must be the link to ../c6-unit16/after - this unit changes nothing in the anchor"
[ -f anchor/pom.xml ] && [ -f anchor/README.md ] && [ -f anchor/tiffinbox-web/pom.xml ] || die "the anchor (its pom.xml, README.md or web module's pom.xml) is missing"
[ -e anchor/secrets ] || [ -e anchor/target ] || [ -e anchor/tiffinbox-web/target ] || [ -e anchor/tiffinbox-core/target ] || [ -e anchor/tiffinbox-local.yaml ] && die "anchor/ holds a secrets/, a target/ or a tiffinbox-local.yaml - it is a frozen copy, never built in place"
M2="$PWD/.m2-demo"
TF=secrets/tiffinbox/shutdown-token                  # the config tree's file for tiffinbox.shutdown-token
# The demo token. FAKE, and meant to look it: it guards nothing but a demo server on 127.0.0.1 that every capture stops.
TOKEN=demo-token-for-the-preflight
[ ${#TOKEN} = 28 ] || die "the demo token must be 28 characters: the published captures name its length"
CURLSET=../c5-unit11/curlset.sh
[ -f "$CURLSET" ] || die "$CURLSET is missing"
HWS='harness/probe/web/CorsRoutes.java harness/probe/web/Dump.java harness/probe/web/FilterCors.java harness/probe/web/GlobalCors.java harness/probe/web/Hooks.java harness/probe/web/Interceptor.java harness/probe/web/ProbeOops.java harness/probe/web/StarCreds.java harness/probe/web/Trace.java'
for f in harness/shutdown.sh harness/www/cors.html harness/cdp.mjs harness/net.py harness/netlog.py $HWS exercise/README.md exercise/KitchenCors.java exercise/solution/SOLUTION.md exercise/solution/KitchenCors.java README.md; do [ -f "$f" ] || die "$f is missing"; done
[ "$(ls harness/probe/web | paste -sd' ' -)" = 'CorsRoutes.java Dump.java FilterCors.java GlobalCors.java Hooks.java Interceptor.java ProbeOops.java StarCreds.java Trace.java' ] || die "harness/probe/web holds another file: javac compiles all of it"
[ "$(ls harness/www | paste -sd' ' -)" = 'cors.html' ] || die "harness/www holds another file: jwebserver serves all of it"
# The last lesson's four harness files, unchanged: Trace, Hooks, Interceptor and ProbeOops are its, byte for byte
for f in Trace Hooks Interceptor ProbeOops; do cmp -s "harness/probe/web/$f.java" "../c6-unit18/harness/probe/web/$f.java" || die "harness/probe/web/$f.java is not the last lesson's (../c6-unit18/harness/probe/web/$f.java), byte for byte"; done

listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
for p in 18425 8080 35729 19480 19481 19482 19483 19484 19485 19486 19487 19488 19489; do
  [ "$(listeners $p)" = 0 ] || die "something already listens on $p - this unit's ports must be free; if it is a process an interrupted run left behind, stop it: kill $(lsof -nP -iTCP:$p -sTCP:LISTEN -t 2> /dev/null | paste -sd' ' -)"; done

# ---- the commands: read from anchor/README.md, the anchor's own, and asserted - each line must be there, whole ---------------
readme() { grep -m1 -xF -- "$1" anchor/README.md > /dev/null || die "anchor/README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
J='java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431'
CPL='"tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431'
R_PLAIN=$(readme 'mvn -B package')
R_RUN=$(readme "$J")
R_EXTRACT=$(readme 'java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted')
R_CP=$(readme "java -cp $CPL")
R_READY=$(readme "curl -s -w ' %{http_code}\n' http://127.0.0.1:18431/actuator/health/readiness")
# This unit's own lines (README.md, "The commands this unit adds") - each asserted to be exactly that
mine() { grep -m1 -xF -- "$1" README.md > /dev/null || die "README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
JL='-Duser.language=en -Duser.country=US'
O_A='http://127.0.0.1:19486'; O_D='http://127.0.0.1:19487'      # the origin the harness's rules allow; one they do not
L_RUNL=$(mine "java $JL -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431")
L_CPL=$(mine "java $JL -cp $CPL")
L_JAVAC=$(mine "javac -parameters -d .harness/hc -cp \".harness/anchor/tiffinbox-web/target/extracted/lib/*\" $HWS")
L_PF=$(mine "curl -s -D - -o .harness/body.txt -X OPTIONS -H 'Origin: $O_A' -H 'Access-Control-Request-Method: PUT' -H 'Access-Control-Request-Headers: content-type' http://127.0.0.1:18431/probe/cors/menu")
L_GET=$(mine "curl -s -D - -o .harness/body.txt -H 'Origin: $O_D' http://127.0.0.1:18431/customers")
L_JWEB=$(mine "jwebserver -J$(printf '%s' "$JL" | sed 's/ / -J/') -b 127.0.0.1 -p 19486 -d \"\$PWD/harness/www\"")
L_CHROME=$(mine "\"\$CHROME\" --headless=new --user-data-dir=\"\$PWD/.harness/chrome\" --no-first-run --no-default-browser-check --disable-background-networking --disable-component-update --disable-sync --disable-domain-reliability --use-mock-keychain --password-store=basic --lang=en-US --proxy-server=http://127.0.0.1:9 --host-resolver-rules='MAP * ~NOTFOUND, EXCLUDE 127.0.0.1' --remote-debugging-address=127.0.0.1 --remote-debugging-port=19489 --log-net-log=\"\$PWD/.harness/netlog.json\" about:blank")
L_VISIT=$(mine "node harness/cdp.mjs 19489 visit '$O_A/cors.html?m=PUT&u=http://127.0.0.1:18431/probe/cors/menu' .harness/ev.json")
L_CLOSE=$(mine "node harness/cdp.mjs 19489 close")
L_NET=$(mine "python3 harness/net.py .harness/ev.json 18431")
L_NETLOG=$(mine "python3 harness/netlog.py .harness/netlog.json 18431 19486 19487")
# The derivations, each asserted
P_='java '; Q_="java $JL "; r=${R_RUN/"$P_"/$Q_}; r2=${R_CP/"$P_"/$Q_}
[ "$r" = "$L_RUNL" ] && [ "$r2" = "$L_CPL" ] || die "the pinned lines must be the anchor's run and class-path lines with $JL after java, and nothing else"
[ "${L_JAVAC#* -cp \"*\" }" = "$HWS" ] || die "the harness's javac line must compile the nine files in harness/probe/web, and nothing else"
[ "${L_JWEB/ -J-Duser.language=en -J-Duser.country=US / }" = 'jwebserver -b 127.0.0.1 -p 19486 -d "$PWD/harness/www"' ] || die "the jwebserver line must pin its JVM's locale (-J) and nothing else"
off() { local c=${2/mvn -B /mvn -o -B -Dmaven.repo.local=\"\$M2\" }
  [ -n "$3" ] && c=${c/ $3/ -DskipTests clean $3}
  printf 'cd %s && %s\n' "$1" "$c"; }
dev() { local c=${1#cd * && }; c=${c/ -o -B -Dmaven.repo.local=\"\$M2\" / -B }; c=${c/ -DskipTests clean / }; printf '%s\n' "$c"; }
at() { local l=${3/--tiffinbox.port=18431/--tiffinbox.port=$2}; case $l in 'java -Djarmode=tools '*) ;; 'java '*) l="java $JL ${l#java }" ;; esac; printf 'cd %s && %s\n' "$1" "$l"; }
# hcp DIR PORT CLASSES: the README's class-path line from DIR, its port made PORT, the harness's classes added (../hc), CLASSES joined
hcp() { local c; c=$(at "$1" "$2" "$R_CP"); c=${c/lib\/\*\"/lib\/*:..\/hc\"}; printf '%s --spring.main.sources=%s\n' "$c" "$3"; }
url() { printf '%s\n' "${1/:18431\//:$2/}"; }
# pfq PORT PATH ORIGIN: this unit's preflight line - its port, its path and its Origin swapped in
pfq() { local c=${L_PF/:18431\//:$1/} P_="/probe/cors/menu" Q_="$2"; c=${c/"$P_"/$Q_}; P_="Origin: $O_A"; Q_="Origin: $3"; printf '%s\n' "${c/"$P_"/$Q_}"; }
# rq PORT PATH [ORIGIN] [METHOD]: this unit's request line - its port, path and Origin swapped in; no ORIGIN: no Origin header (curl
# sends only its own); METHOD: -X METHOD after the body file
rq() { local c=${L_GET/:18431\//:$1/} P_="/customers" Q_="$2"; c=${c/"$P_"/$Q_}; P_=" -H 'Origin: $O_D'"; Q_="${3:+ -H 'Origin: $3'}"; c=${c/"$P_"/$Q_}
  [ -z "${4:-}" ] || { P_=" .harness/body.txt"; Q_=" .harness/body.txt -X $4"; c=${c/"$P_"/$Q_}; }; printf '%s\n' "$c"; }
jw() { printf '%s\n' "${L_JWEB/-p 19486/-p $1}"; }
# vq PAGEPORT METHOD PORT PATH: this unit's visit line - the page on PAGEPORT asks TiffinBox on PORT for METHOD PATH
vq() { local c=${L_VISIT/127.0.0.1:19486\//127.0.0.1:$1/} P_="m=PUT&u=http://127.0.0.1:18431/probe/cors/menu" Q_="m=$2&u=http://127.0.0.1:$3$4"; printf '%s\n' "${c/"$P_"/$Q_}"; }
nq() { printf '%s\n' "${L_NET/ 18431/ $1}"; }
nlq() { printf '%s\n' "${L_NETLOG% 18431 19486 19487} $*"; }
exe() { printf '%s\n' "$1" | sed -E 's/&& (([A-Z_]+=[^ ]* )*)/\&\& \1exec /'; }
C_PRE=$(off .harness/pre "$R_PLAIN" package)
[ "$(dev "$C_PRE")" = "$R_PLAIN" ] || die "not the README's build line with the offline changes: $C_PRE"
[ "$(exe "$(at .harness/x 19480 "$R_RUN")")" = "cd .harness/x && exec ${L_RUNL/18431/19480}" ] && [ "$(at .harness/x 18431 "$R_CP")" = "cd .harness/x && $L_CPL" ] || die "at(): the pinned lines are not README.md's"
[ "$(pfq 18431 /probe/cors/menu "$O_A")" = "$L_PF" ] && [ "$(rq 18431 /customers "$O_D")" = "$L_GET" ] && [ "$(rq 19480 /probe/cors/menu "" OPTIONS)" = "curl -s -D - -o .harness/body.txt -X OPTIONS http://127.0.0.1:19480/probe/cors/menu" ] || die "pfq() or rq()"
[ "$(vq 19486 PUT 18431 /probe/cors/menu)" = "$L_VISIT" ] && [ "$(vq 19487 GET 19484 /customers)" = "node harness/cdp.mjs 19489 visit '$O_D/cors.html?m=GET&u=http://127.0.0.1:19484/customers' .harness/ev.json" ] && [ "$(nq 18431)" = "$L_NET" ] && [ "$(nlq 18431 19486 19487)" = "$L_NETLOG" ] && [ "$(jw 19486)" = "$L_JWEB" ] || die "vq(), nq(), nlq() or jw()"
echo "  the commands: anchor/README.md gives the 5 lines this script runs or derives from; README.md the 12 this unit adds"

# ---- build: before the captures - the anchor built once (on a fresh clone this fills .m2-demo) -----------------------------------
rm -rf .harness; mkdir -p .harness
mbuild() { local how=yes ec=0 c=$1
  (eval "$c") > "$2" 2>&1 < /dev/null || ec=$?
  if [ $ec != 0 ] && grep -qE 'offline mode|Could not resolve|could not be resolved|Cannot access|No plugin found for prefix' "$2"; then
    how="no - the offline build could not resolve an artifact, so Maven Central was asked"; ec=0
    (eval "${c/mvn -o -B /mvn -B }") > "$2" 2>&1 < /dev/null || ec=$?; fi
  [ $ec = 0 ] || { tail -30 "$2" >&3
    ! grep -qE 'Could not resolve|could not be resolved|Could not transfer|Cannot access' "$2" || die "build failed: $3 - Maven could resolve Boot's parent and plugins neither from .m2-demo nor from Maven Central: a fresh clone's first run needs the network once, to fill .m2-demo"
    die "build failed: $3"; }
  echo "  built $3 · offline: $how · exit $ec"; }
tree() { mkdir -p "$1/secrets/tiffinbox"; (umask 077 && printf '%s\n' "$TOKEN" > "$1/$TF"); chmod 700 "$1/secrets" "$1/secrets/tiffinbox"; }
copy() { rm -rf "$2" "$2".*; rsync -a --exclude target --exclude secrets "$1/" "$2/"; tree "$2"; }
rsync -a --exclude target --exclude secrets anchor/ .harness/pre/
mbuild "$C_PRE" .harness/build-pre.log ".harness/pre (the anchor)"
[ -f "$M2/org/springframework/boot/spring-boot-starter-webmvc/4.1.1/spring-boot-starter-webmvc-4.1.1.jar" ] || die "Spring MVC's starter is not in .m2-demo after the first build"
echo "  .m2-demo holds Spring MVC's starter"
if [ $BROWSER = yes ]; then echo "  the browser: $("$CHROME" --version 2> /dev/null | head -1) on $(uname -s) $(uname -m) (the platform its User-Agent and sec-ch-ua-platform name) · node $(node --version) - printed here, never in a capture"; else echo "  the browser: none - $WHYNOT"; fi

# ---- helpers ------------------------------------------------------------------------------------------------------------
raw() { local t=$1; shift; cat "$@" | LC_ALL=C grep -aoF -- "$t" | wc -l | tr -d ' '; }
LOGS=0; LASTE=""
first() { grep -m1 -E ' : Starting |^main Starting ' "$1" | sed 's/^.* : //; s/^main //; s/ with PID .*$//'; }
start() { echo "\$ $1"; (eval "$(exe "$1")") > .harness/run.out 2> .harness/run.err < /dev/null & pid=$!; }
# addrs PID: the addresses process PID listens on, read off the process (lsof, by pid - its command name is never printed)
addrs() { lsof -nP -a -p "$1" -iTCP -sTCP:LISTEN 2> /dev/null | awk 'NR > 1 { print $9 }' | sort -u | paste -sd' ' -; }
# listening PID PORT: addrs, polled until PID listens on PORT - every 0.25 s, up to 120 s
listening() { local a="" i=0
  while [ $i -lt 480 ]; do a=$(addrs "$1"); case " $a " in *":$2 "*) break ;; esac; kill -0 "$1" 2> /dev/null || break; sleep 0.25; i=$((i + 1)); done
  echo "${a:-nothing}"; }
lb() { local a n=0; for a in $1; do n=$((n + 1)); case $a in 127.0.0.1:*) ;; *) echo no; return ;; esac; done; [ $n -gt 0 ] && echo yes || echo no; }
# up PID PORT [JAVA]: PID listens on PORT, loopback only; for a TiffinBox JVM (JAVA=1), Boot's first line too
up() { local l; l=$(listening "$1" "$2"); [ "$l" != nothing ] || { tail -20 .harness/run.out >&3; die "it never listened on $2"; }
  case " $l " in *':8080 '*|*':35729 '*) kill -9 "$1" 2> /dev/null || true; die "it listened on 8080 or 35729 - never bound by this script";; esac
  echo "  listens on: $l · loopback only: $(lb "$l")"; [ -z "${3:-}" ] || echo "  Boot's first line: $(first .harness/run.out)"; }
ready() { local i=0 c=""
  while [ $i -lt 480 ]; do c=$(curl -s -o /dev/null -w '%{http_code}' "http://127.0.0.1:$1/actuator/health/readiness" 2> /dev/null || true); [ "$c" = 200 ] && break
    kill -0 "$pid" 2> /dev/null || { tail -20 .harness/run.out >&3; die "it exited before readiness answered 200"; }
    sleep 0.25; i=$((i + 1)); done
  [ "$c" = 200 ] || die "readiness never answered 200 on $1"
  local r; r=$(url "$R_READY" "$1"); echo "\$ $r"; (eval "$r") 2>&1 < /dev/null | sed 's/^/  /'; }
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
mask() { awk -v t="$TOKEN" -v u="$U" -v up="$UP" -v hm="$HOME" -v me="$ME" -v tl="${#TOKEN}" '
  function lit(x) { gsub(/[][\\.^$*+?(){}|\/]/, "\\\\&", x); return x }
  function enc(x) { gsub(/ /, "%20", x); return x }
  BEGIN { T = lit(t); P = lit(u); Q = lit(up); H = lit(hm); PE = lit(enc(u)); QE = lit(enc(up)); M = "(^|[^A-Za-z0-9_])" lit(me) "([^A-Za-z0-9_]|$)" }
  { gsub(T, "[masked: the " tl "-character token]"); gsub(P, "…"); gsub(PE, "…")
    gsub(Q, "…/.."); gsub(QE, "…/.."); gsub(H, "~"); gsub(/\$\$SpringCGLIB\$\$[0-9]+/, "$$SpringCGLIB$$<n>")
    gsub(/Chrome\/[0-9][0-9.]*/, "Chrome/<version>"); gsub(/Mozilla\/5\.0 \([^)]*\)/, "Mozilla/5.0 (<platform masked>)")
    if (match($0, /sec-ch-ua-platform: /)) $0 = substr($0, 1, RSTART + RLENGTH - 1) "(<platform masked>)"
    if (match($0, /sec-ch-ua: /)) $0 = substr($0, 1, RSTART + RLENGTH - 1) "(its brands and their versions: masked)"
    while (match($0, M)) { pre = substr($0, 1, RSTART - 1); s = substr($0, RSTART, RLENGTH); post = substr($0, RSTART + RLENGTH)
      sub(lit(me), "<user>", s); $0 = pre s post }
    print }'; }

unpub=""
cap() { local nm=$1 h pub i; shift
  for i in 1 2 3; do "$@" > .harness/cap.raw 2>&1 || true; [ -z "$pid$xpid$cpid$j1$j2" ] || die "$nm left a process running"
    raw "$TOKEN" .harness/cap.raw > ".harness/raw-$nm.$i"; mask < .harness/cap.raw > ".r-$nm.$i"; done
  h=$(md5 -q ".r-$nm.1")
  [ "$h" = "$(md5 -q ".r-$nm.2")" ] && [ "$h" = "$(md5 -q ".r-$nm.3")" ] || die "$nm drifts across three runs (diff .r-$nm.1 .r-$nm.2 .r-$nm.3)"
  mv ".r-$nm.1" ".r-$nm.out"; rm -f ".r-$nm.2" ".r-$nm.3"
  pub=$(awk -v n="$nm" '$1 == n { print $2 }' receipts.md5 2> /dev/null || true)
  if [ -z "$pub" ]; then printf '  %-9s md5 %s  3/3  (no published hash)\n' "$nm" "$h"; unpub="$unpub $nm"
  elif [ "$pub" = "$h" ]; then printf '  %-9s md5 %s  3/3  = published\n' "$nm" "$h"
  else printf '  %-9s md5 %s  3/3  DIFFERS from the published %s\n' "$nm" "$h" "$pub"
    die "$nm is not the published capture - suspect another JDK, Boot, Maven or Chrome, a busy machine, a busy port, a variable of yours, or an edited source; diff .r-$nm.out against its block in README.md"; fi; }
pbuild() { local c; c=$(off "$1" "$R_PLAIN" package); echo "\$ $c"; mbuild "$c" "$1.build.log" "$2"; }
extract() { local c="cd $1 && $R_EXTRACT"; echo "\$ $c"; (eval "$c") > .harness/extract.log 2>&1 < /dev/null || die "the README's extract line failed in $1"; echo "  exit 0"; }
settle() { local i=0 a b=-1; while [ $i -lt 30 ]; do a=$(wc -l < .harness/run.out | tr -d ' '); [ "$a" = "$b" ] && return 0; b=$a; sleep 0.5; i=$((i + 1)); done; die "the log never settled"; }
mark() { settle; wc -l < .harness/run.out | tr -d ' '; }
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
# hk FROM: the harness's lines (Trace: HOOK, the JVM's running number, then what ran) the log gained after line FROM, in the order they
# printed, numbered from 1 - the running number must rise line by line (checked, never shown)
hk() { local o; o=$(awk -v from="$1" 'NR > from && /^HOOK [0-9]+ / { n = $2 + 0; if (k && n <= last) bad = 1; last = n; s = $0; sub(/^HOOK [0-9]+ /, "", s); l[++k] = s }
    END { if (bad) exit 3; print "  the harness'"'"'s lines it printed, in order: " (k + 0); for (i = 1; i <= k; i++) printf "    %2d %s\n", i, l[i] }' .harness/run.out) || die "the harness's lines after line $1 are out of order"
  printf '%s\n' "$o"; }
# hdr: curl's -D - output as printed: carriage returns and trailing spaces dropped, the blank line after the headers dropped, a Date
# header's value not printed, Spring's error timestamp masked
hdr() { tr -d '\r' | awk '{ sub(/ +$/, ""); if ($0 == "") next; if (index($0, "Date: ") == 1) $0 = "Date: (the time: not printed)"; print "  " $0 }' | tsmask; }
# ask 'CURL LINE': printed and run - the status line and every header (hdr), then the body curl wrote this time (a fresh file: the old
# one removed first, so an answer with no body prints []), the WARN and ERROR lines the request added, then every harness line it
# printed (hk) and each WARN or ERROR record (recs)
ask() { local n0 w e; n0=$(mark); rm -f .harness/body.txt; echo "\$ $1"; (eval "$1") 2> /dev/null < /dev/null | hdr
  echo "  body: [$(cat .harness/body.txt 2> /dev/null | tsmask)]"; settle
  w=$(logl "$n0" WARN | grep -c . || true); e=$(logl "$n0" ERROR | grep -c . || true)
  echo "  WARN lines it added: $w · ERROR lines: $e"; hk "$n0"; [ "$w$e" = 00 ] || recs "$n0"; }
loc() { local l; l=$(grep -m1 -E "^HOOK [0-9]+ Hooks +the JVM's locale: " .harness/run.out | sed "s/^.*the JVM's locale: //"); echo "  the JVM's locale (the harness's Hooks): ${l:-not printed}"; }
# serve PORT CLASSES: TiffinBox on its class path, CLASSES joined, from .harness/anchor; up, ready, its locale
serve() { start "$(hcp .harness/anchor "$1" "$2")"; up "$pid" "$1" 1; ready "$1"; loc; }
# blkraw/asame: an A' against its A, their labels aside, line for line (the last lesson's); csame A B: two answers the same, line for line
blkraw() { awk -v a="$1" -v b="$2" 'index($0, a) == 1 { f = 1; next } b != "" && index($0, b) == 1 { f = 0 } f' .harness/cap.raw; }
asame() { [ "$(blkraw "$1" "$2")" = "$(blkraw "$3" "$4")" ] && [ -n "$(blkraw "$3" "$4")" ] && echo yes || echo no; }
# answer CMD: the lines a command printed in this capture so far, up to its WARN/ERROR line - the answer alone (status, headers, body)
answer() { awk -v c="\$ $1" '$0 == c { f = 1; next } f && /^  WARN lines it added: / { exit } f' .harness/cap.raw; }
CS=probe.web.CorsRoutes,probe.web.Hooks

# The filters, checked on planted inputs before any capture (R.65)
mkdir -p .harness
{ printf '%s\n' '2026-10-22T00:00:00.000Z  WARN 1 --- [planted] o.s.web.servlet.PageNotFound      : planted warning' 'HOOK 0001 Interceptor     preHandle       ERROR /error handler BasicErrorController#error' '2026-10-22T00:00:00.001Z ERROR 1 --- [planted] o.a.c.c.C.[.[.[/].[dispatcherServlet]    : planted error' 'java.lang.IllegalArgumentException: planted'
  i=0; while [ $i -lt 45 ]; do printf '\tat planted.Frame%s(Planted.java)\n' $i; i=$((i + 1)); done; printf '%s\n' 'HOOK 0002 Dump            < 500 GET /x'; } > .harness/run.out
[ "$(logl 0 ERROR | grep -c .)" = 1 ] && [ "$(logl 0 WARN | grep -c .)" = 1 ] && [ "$(grep -c ' ERROR ' .harness/run.out)" = 2 ] || die "the level counts: the planted log must give 1 WARN and 1 ERROR by line shape (a bare ' ERROR ' gives 2)"
[ "$(recs 0)" = "$(printf '%s\n' '    WARN o.s.web.servlet.PageNotFound: planted warning' '      its stack frames: 0, its other lines: 0 - none shown' '    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: planted error' '      java.lang.IllegalArgumentException: planted' '      its stack frames: over 40, its other lines: 0 - none shown')" ] || die "recs: the planted log does not come out as declared (.harness/run.out)"
[ "$(hk 0)" = "$(printf '%s\n' "  the harness's lines it printed, in order: 2" '     1 Interceptor     preHandle       ERROR /error handler BasicErrorController#error' '     2 Dump            < 500 GET /x')" ] || die "hk: the planted lines do not come out as declared"
printf '%s\n' 'HOOK 0007 Dump            > GET /x' 'HOOK 0006 Dump            < 200 GET /x' > .harness/run.out
( hk 0 > /dev/null 2>&1 3> /dev/null ) && die "hk: a falling running number must stop the run"
rm -f .harness/run.out
[ "$(printf 'HTTP/1.1 403 \r\nDate: Thu, 22 Oct 2026 05:59:37 GMT\r\nVary: Origin\r\n\r\n' | hdr)" = "$(printf '%s\n' '  HTTP/1.1 403' '  Date: (the time: not printed)' '  Vary: Origin')" ] || die "hdr: the planted headers do not come out as declared"
[ "$(printf '%s\n' 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/155.0.0.0 Safari/537.36' 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/155.0.0.0 Safari/537.36' 'sec-ch-ua: "Google Chrome";v="155"' 'sec-ch-ua-mobile: ?0' 'sec-ch-ua-platform: "macOS"' 'sec-ch-ua-platform: "Linux"' | mask)" = "$(printf '%s\n' 'User-Agent: Mozilla/5.0 (<platform masked>) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/<version> Safari/537.36' 'User-Agent: Mozilla/5.0 (<platform masked>) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/<version> Safari/537.36' 'sec-ch-ua: (its brands and their versions: masked)' 'sec-ch-ua-mobile: ?0' 'sec-ch-ua-platform: (<platform masked>)' 'sec-ch-ua-platform: (<platform masked>)')" ] || die "mask: Chrome's version and the platform must be masked in User-Agent, sec-ch-ua and sec-ch-ua-platform, and nothing else"
echo "  the filters: the level counts (a hook line that says ERROR is no ERROR line), the record filter, the harness's lines (a falling running number stops the run), the header filter and Chrome's masks print their planted inputs as declared"

# ---- preflight: the question, asked by curl -------------------------------------------------------------------------------------
preflight() {
  echo "the anchor - anchor/, copied under .harness/ with a config tree, built with its README's line (offline), its jar extracted (the README's line):"
  copy anchor .harness/anchor; pbuild .harness/anchor "the anchor"; extract .harness/anchor
  echo "the harness, compiled against the anchor's own jar - with -parameters (this unit's line):"
  echo "\$ $L_JAVAC"; rm -rf .harness/hc; (eval "$L_JAVAC") > .harness/javac.log 2>&1 < /dev/null || { cat .harness/javac.log >&3; die "the harness did not compile against the anchor's jar"; }
  echo "  exit 0 · its classes: $(cd .harness/hc && find . -name '*.class' | sed 's#^\./##' | sort | paste -sd' ' -)"
  echo "the seven - the anchor, the README's run line (its locale pinned), port 19480, a fresh JVM:"
  start "$(at .harness/anchor 19480 "$R_RUN")"; up "$pid" 19480 1; ready 19480; seven 19480 .harness/anchor; WARNS; logl 0 WARN
  echo "the routes - the anchor on its class path, CorsRoutes (@CrossOrigin for $O_A on /probe/cors/menu) and Hooks joined, port 19480:"
  serve 19480 "$CS"
  echo "a preflight from the origin the rule allows:"
  ask "$(pfq 19480 /probe/cors/menu "$O_A")"
  echo "the same preflight from another origin:"
  ask "$(pfq 19480 /probe/cors/menu "$O_D")"
  echo "a preflight to a path no CORS rule covers:"
  ask "$(pfq 19480 /customers "$O_A")"
  echo "the actual requests - a GET from the allowed origin, from the other, and a GET of the customer list from the other:"
  ask "$(rq 19480 /probe/cors/menu "$O_A")"
  ask "$(rq 19480 /probe/cors/menu "$O_D")"
  ask "$(rq 19480 /customers "$O_D")"
  echo "an OPTIONS with no Origin at all:"
  ask "$(rq 19480 /probe/cors/menu "" OPTIONS)"
  WARNS; stop 19480 .harness/anchor; }

# ---- ways: three ways, one answer - and the filter that answers every preflight -----------------------------------------------------
ways() {
  echo "two ways - CorsRoutes and GlobalCors (the same rule for /probe/global/**, through Spring MVC's CORS registry) and Hooks, port 19481:"
  serve 19481 probe.web.CorsRoutes,probe.web.GlobalCors,probe.web.Hooks
  ask "$(pfq 19481 /probe/cors/menu "$O_A")"
  ask "$(pfq 19481 /probe/global/menu "$O_A")"
  ask "$(pfq 19481 /probe/cors/menu "$O_D")"
  ask "$(pfq 19481 /probe/global/menu "$O_D")"
  echo "  the annotation's answer and the registry's, line for line - allowed: $([ "$(answer "$(pfq 19481 /probe/cors/menu "$O_A")")" = "$(answer "$(pfq 19481 /probe/global/menu "$O_A")")" ] && echo the same || echo different) · refused: $([ "$(answer "$(pfq 19481 /probe/cors/menu "$O_D")")" = "$(answer "$(pfq 19481 /probe/global/menu "$O_D")")" ] && echo the same || echo different)"
  WARNS; stop 19481 .harness/anchor
  echo "A - CorsRoutes and Hooks, port 19482:"
  serve 19482 "$CS"; ask "$(pfq 19482 /probe/cors/menu "$O_A")"; WARNS; stop 19482 .harness/anchor
  echo "B - the same, FilterCors joined (a CorsFilter in a filter registration that names no path, so it runs on every path; its one rule is for /probe/filter/**), port 19483:"
  serve 19483 probe.web.CorsRoutes,probe.web.FilterCors,probe.web.Hooks
  ask "$(pfq 19483 /probe/cors/menu "$O_A")"
  echo "B - the filter's own path:"
  ask "$(pfq 19483 /probe/filter/menu "$O_A")"
  echo "B - an actual GET of the annotated route:"
  ask "$(rq 19483 /probe/cors/menu "$O_A")"
  WARNS; stop 19483 .harness/anchor
  echo "A' - A again, a fresh JVM, port 19482:"
  serve 19482 "$CS"; ask "$(pfq 19482 /probe/cors/menu "$O_A")"; WARNS; stop 19482 .harness/anchor
  echo "A' against A, its label aside, line for line the same: $(asame "A - " "B - " "A' - " "A' against A")"; }

# ---- star: any origin, with credentials ------------------------------------------------------------------------------------------
star() {
  echo "star - CorsRoutes, StarCreds (any origin, \"*\", and credentials, for /probe/global/**) and Hooks, port 19481:"
  serve 19481 probe.web.CorsRoutes,probe.web.StarCreds,probe.web.Hooks
  WARNS
  ask "$(pfq 19481 /probe/global/menu "$O_A")"
  ask "$(rq 19481 /probe/global/menu "$O_A")"
  echo "the same GET with no Origin at all - not a cross-origin request:"
  ask "$(rq 19481 /probe/global/menu "")"
  echo "the annotated route, no Origin, beside it:"
  ask "$(rq 19481 /probe/cors/menu "")"
  WARNS; stop 19481 .harness/anchor; }

# ---- exercise: the README's commands, exactly as written, then the solution's - in ONE shell --------------------------------------
block() { awk '/^```bash$/ { if (!d) { f = 1 }; next } f && /^```$/ { f = 0; d = 1 } f' "$1"; }
where() { case "$1" in "$U") echo "this unit's folder" ;; "$U"/*) echo "${1#"$U"/}" ;; *) echo "outside this unit's folder" ;; esac; }
lvl() { grep -cE "^[0-9]{4}-[0-9]{2}-[0-9]{2}T[^ ]+ +$1 " "$2" || true; }
exercise() { local setup sol i=0 e1 d1 e2 d2 l1 l2
  setup=$(block exercise/README.md); sol=$(block exercise/solution/SOLUTION.md)
  [ -n "$setup" ] && [ -n "$sol" ] || die "exercise/README.md or SOLUTION.md no longer gives its commands"
  [ "$(printf '%s\n' "$sol" | grep -c .)" = 4 ] || die "SOLUTION.md's first bash block must be the README's two export lines, the solution's copy line and the README's last line"
  [ "$(printf '%s\n' "$sol" | sed -n 1,2p)" = "$(printf '%s\n' "$setup" | sed -n 1,2p)" ] || die "SOLUTION.md must start with the README's two export lines (a new shell's java may be another JDK)"
  printf '%s\n' "$sol" | sed -n 1p | grep -qxF 'export JAVA_HOME=/opt/homebrew/opt/openjdk@25' || die "SOLUTION.md's first line must export this script's JAVA_HOME"
  printf '%s\n' "$sol" | sed -n 3p | grep -qxF 'cp exercise/solution/KitchenCors.java .harness/mine/KitchenCors.java' || die "SOLUTION.md's third line must copy the solution's KitchenCors.java over the copy's"
  l1=$(printf '%s\n' "$setup" | tail -1); l2=$(printf '%s\n' "$sol" | sed -n 4p)
  [ "$l1" = "$l2" ] || die "SOLUTION.md's last line must be the README's last line, unchanged: the fix is in the class, not the command"
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
  echo "  the shell is now in: $(where "$d1") · the JVM's locale in its log: $(grep -m1 "^KitchenCors: the JVM's locale: " .harness/ex-readme.log | sed "s/^.*locale: //") · the copy's own token in its log: $(raw "$(head -1 .harness/mine/anchor/$TF)" .harness/ex-readme.log) times · WARN lines in its log: $(lvl WARN .harness/ex-readme.log) · ERROR lines: $(lvl ERROR .harness/ex-readme.log) · listening on 19488 now: $(listeners 19488)"
  echo "the solution's $(printf '%s\n' "$sol" | grep -c .) lines, next, in the same shell:"
  printf '%s\n' "$sol" | sed 's/^/  $ /'
  echo "  exit $e2 · what they printed:"; sed 's/^/    /' .harness/ex-sol.out
  echo "  the shell is now in: $(where "$d2") · the JVM's locale in its log: $(grep -m1 "^KitchenCors: the JVM's locale: " .harness/mine/run.log | sed "s/^.*locale: //") · the copy's own token in its log: $(raw "$(head -1 .harness/mine/anchor/$TF)" .harness/mine/run.log) times · WARN lines in its log: $(lvl WARN .harness/mine/run.log) · ERROR lines: $(lvl ERROR .harness/mine/run.log) · listening on 19488 now: $(listeners 19488)"
  echo "  the change the solution's KitchenCors.java makes (diff -U0, its hunks):"
  diff -U0 exercise/KitchenCors.java .harness/mine/KitchenCors.java | sed -n '3,$p' | sed 's/^/    /' || true; }

# ---- browser: two origins, TiffinBox, Chrome - each claim with two witnesses -------------------------------------------------------
# origin PORT: a jwebserver serving harness/www on 127.0.0.1:PORT (this unit's line), up and loopback; its pid in $jp
origin() { local c; c=$(jw "$1"); echo "\$ $c"; (eval "exec $c") > ".harness/jweb-$1.out" 2>&1 < /dev/null & jp=$!; up "$jp" "$1"; }
# unorigin PID PORT: stopped by its pid; the port free
unorigin() { local e=0; kill "$1" 2> /dev/null || true; wait "$1" || e=$?; [ "$(listeners "$2")" = 0 ] || die "something still listens on $2"; echo "  the origin on $2 stopped by its pid · exit $e · listening on $2 now: 0"; }
# chrome: Chrome (this unit's line) with a profile made fresh for this run, its DevTools port up and loopback
chrome() { local f; [ -e .harness/chrome ] && f=no || f=yes; rm -f .harness/netlog.json
  echo "\$ $L_CHROME"; (eval "exec $L_CHROME") > .harness/chrome.out 2>&1 < /dev/null & cpid=$!
  echo "  its profile, .harness/chrome, made fresh for this run (it did not exist before this line): $f"; up "$cpid" 19489; }
# unchrome: Browser.close (this unit's line); Chrome must leave within 15 s - else it is killed by its pid, and the run stops - its exit
# code; its DevTools port free; its profile removed; then the NetLog read (this unit's line), with the ports this run's pages used
unchrome() { local i=0 e=0; echo "\$ $L_CLOSE"; (eval "$L_CLOSE") > .harness/close.out 2>&1 < /dev/null || true
  while kill -0 "$cpid" 2> /dev/null && [ $i -lt 60 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$cpid" 2> /dev/null && { killtree "$cpid"; die "Chrome still ran 15 s after Browser.close"; }
  wait "$cpid" || e=$?; cpid=""; [ "$(listeners 19489)" = 0 ] || die "something still listens on 19489"
  rm -rf .harness/chrome; echo "  Chrome exit $e · listening on 19489 now: 0 · its profile removed"
  echo "\$ $(nlq "$@")"; (eval "$(nlq "$@")") 2>&1 < /dev/null || true; }
# visit PAGEPORT METHOD PORT PATH: this unit's visit line, printed and run - what the page printed; Chrome's own record of the page's
# requests to TiffinBox (this unit's net.py line); then the server's record: every harness line the requests printed (Dump, the hooks),
# and the WARN and ERROR lines they added
visit() { local n0 c w e; n0=$(mark); c=$(vq "$1" "$2" "$3" "$4"); rm -f .harness/ev.json; echo "\$ $c"; (eval "$c") 2>&1 < /dev/null | sed 's/^/  /'
  echo "\$ $(nq "$3")"; (eval "$(nq "$3")") 2>&1 < /dev/null; settle
  w=$(logl "$n0" WARN | grep -c . || true); e=$(logl "$n0" ERROR | grep -c . || true)
  echo "  the server's record:"; hk "$n0" | sed 's/^/  /'; echo "    WARN lines they added: $w · ERROR lines: $e"; }
browser() {
  echo "two origins - jwebserver, the JDK's own file server, serving harness/www (cors.html) twice: $O_A (the origin the rules allow) and $O_D (one they do not):"
  origin 19486; j1=$jp; origin 19487; j2=$jp
  echo "TiffinBox - the anchor on its class path, Dump (the server's record of every request, whole), CorsRoutes and Hooks joined, port 19484:"
  serve 19484 probe.web.Dump,probe.web.CorsRoutes,probe.web.Hooks
  echo "Chrome - headless, a profile of its own, sealed to 127.0.0.1 (its proxy a dead address, every name but 127.0.0.1 unresolvable), its DevTools protocol on 127.0.0.1:19489:"
  chrome
  echo "visit 1 - the page on $O_A asks TiffinBox for PUT /probe/cors/menu:"
  visit 19486 PUT 19484 /probe/cors/menu
  echo "visit 2 - the same page again, the same Chrome, seven seconds later (a wait, not a witness: Chrome keeps an answer with no max age for a few seconds, D below):"
  echo "\$ sleep 7"; sleep 7
  visit 19486 PUT 19484 /probe/cors/menu
  echo "visit 3 - the page on $O_D asks for the same PUT:"
  visit 19487 PUT 19484 /probe/cors/menu
  echo "visit 4 - the page on $O_D asks for GET /customers:"
  visit 19487 GET 19484 /customers
  unchrome 19484 19486 19487
  WARNS; stop 19484 .harness/anchor
  echo "C (labelled) - TiffinBox with FilterCors joined too (a CorsFilter on every path, its one rule for /probe/filter/**), port 19485; Chrome again, a fresh profile:"
  serve 19485 probe.web.Dump,probe.web.CorsRoutes,probe.web.FilterCors,probe.web.Hooks
  chrome
  echo "C - the page on $O_A asks for PUT /probe/cors/menu:"
  visit 19486 PUT 19485 /probe/cors/menu
  echo "D (labelled) - the control: the filter's own path, whose answer carries no max age - the same page on $O_A asks for PUT /probe/filter/menu:"
  visit 19486 PUT 19485 /probe/filter/menu
  echo "D again - the same page, the same Chrome, seven seconds later:"
  echo "\$ sleep 7"; sleep 7
  visit 19486 PUT 19485 /probe/filter/menu
  unchrome 19485 19486
  WARNS; stop 19485 .harness/anchor
  echo "the origins:"
  unorigin "$j1" 19486; j1=""; unorigin "$j2" 19487; j2=""; }

cap preflight preflight
cap ways ways
cap star star
cap exercise exercise
if [ $BROWSER = yes ]; then cap browser browser; fi
echo
# ---- every number the video says, asserted. Each check reads a line a program computed - never a label this script prints
# ---- unconditionally - and names the words it pays for.
blk() { awk -v a="$2" -v b="$3" 'index($0, a) == 1 { f = 1; next } b != "" && index($0, b) == 1 { f = 0 } f' ".r-$1.out"; }
has() { printf '%s\n' "$1" | grep -qxF -- "$2" || die "$3: expected the line: $2"; }
nhas() { ! printf '%s\n' "$1" | grep -qF -- "$2" || die "$3: did not expect: $2"; }
# seg BLOCK 'COMMAND': the lines a command printed in BLOCK - from the line after "$ COMMAND" up to the next "$ " line or label line
seg() { printf '%s\n' "$1" | C="\$ $2" awk 'f && (/^\$ / || /^[A-Za-z]/) { exit } f { print } $0 == ENVIRON["C"] { f = 1 }'; }
# ans SEGMENT: the answer alone - the lines before "body: [", the body line included, the harness's lines and the counts dropped
ans() { printf '%s\n' "$1" | awk '{ print } /^  body: \[/ { exit }' | paste -sd'|' -; }
# hl SEGMENT: its harness lines, numbers and padding taken off, one a line
hl() { printf '%s\n' "$1" | awk '/^ +[0-9]+ [A-Z][A-Za-z]+ +/ { $1 = ""; sub(/^ /, ""); gsub(/ +/, " "); print }'; }
cnt() { printf '%s\n' "$1" | grep -cxF -- "$2" || true; }
ccheck() { local c="$1" w="$2" e="$3" n="$4" lbl="$5"; has "$c" "  WARN lines it added: $w · ERROR lines: $e" "$lbl: $w WARN $e ERROR"; has "$c" "  the harness's lines it printed, in order: $n" "$lbl: $n harness lines"; }
# THE TOKEN: no capture holds it, raw - counted on each run's own output BEFORE masking - and neither does any log, nor any shipped file
for f in .harness/raw-*; do [ "$(cat "$f")" = "0" ] || die "a capture's raw output held the token ($f: $(cat "$f"))"; done
SHIP="README.md exercise/README.md exercise/KitchenCors.java exercise/solution/SOLUTION.md exercise/solution/KitchenCors.java receipts.md5 harness/shutdown.sh harness/www/cors.html harness/cdp.mjs harness/net.py harness/netlog.py $HWS"
for f in .r-*.out $SHIP; do [ "$(raw "$TOKEN" "$f")" = 0 ] || die "$f holds the demo token, raw"; done
for f in .r-*.out; do ! grep -qE '/Users/|/private/|/home/|/var/folders/' "$f" || die "$f holds an absolute path"; ! grep -qE 'c[0-9]-unit[0-9]|unit ?[0-9]' "$f" || die "$f holds a unit number"; ! grep -qE ' (with PID|started by) ' "$f" || die "$f holds Boot's process line"; ! grep -qE '^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T|"timestamp":"?[0-9]|(exec|handler|task|utility)-[0-9]|GMT|CES?T|[A-Z][a-z][a-z], [0-9][0-9] [A-Z][a-z][a-z] ' "$f" || die "$f holds a log line's time, a timestamp, a date or a thread's number"; ! grep -q "^$(printf '\t')at " "$f" || die "$f shows a stack frame"; ! grep -qE 'SpringCGLIB\$\$[0-9]' "$f" || die "$f holds a generated class's number"; ! grep -qE ':(8080|35729)([^0-9]|$)' "$f" || die "$f shows a bind on 8080 or 35729"; ! grep -q $'\r' "$f" || die "$f holds a carriage return"; ! grep -qiE '<html|<!doctype' "$f" || die "$f shows an HTML page whole"; ! grep -qE 'Chrome/[0-9]|v="[0-9]' "$f" || die "$f holds Chrome's version"; ! grep -qE 'Macintosh|Mac OS X|Windows NT|X11;|Linux x86|sec-ch-ua-platform: "' "$f" || die "$f holds the platform (User-Agent or sec-ch-ua-platform)"; done
for f in receipts.sh README.md exercise/README.md exercise/solution/SOLUTION.md $HWS exercise/KitchenCors.java exercise/solution/KitchenCors.java; do ! grep -qE "exposure\.include='?\*" "$f" || die "$f exposes every endpoint (R.42)"; done
K3='server'; K3="$K3.error."
for f in receipts.sh $SHIP; do ! grep -qF "$K3" "$f" || die "$f names one of Boot 3's error keys - Boot 4.1 reads only spring.web.error.* (S3.21)"; done
for c in CorsRoutes GlobalCors FilterCors StarCreds Dump Interceptor KitchenCors probe.web; do ! grep -rqwF "$c" anchor/tiffinbox-web/src anchor/tiffinbox-core/src || die "the anchor's sources name $c (a whole word) - a trap is shown on the harness, never in the anchor (S3.18)"; done
for f in receipts.sh exercise/README.md exercise/solution/SOLUTION.md; do ! grep -nE '(^|[;&|({] *)wait *($|[;&|)}])' "$f" | grep -vE '^[0-9]+: *#' > /dev/null || die "$f has a bare wait (S3.9)"; done
# S4.9: Chrome is never stopped by its name - no command in this script or the harness names a pkill or a killall (the words split)
K1='pki''ll'; K2='kill''all'; for f in receipts.sh harness/cdp.mjs harness/net.py harness/netlog.py; do ! grep -v '^ *#' "$f" | grep -qwE "$K1|$K2" || die "$f names $K1 or $K2 - Chrome is stopped by its pid (S4.9)"; done
# S4.16: Chrome's profile is this unit's, made under .harness/ - never a user profile
case "$L_CHROME" in *' --user-data-dir="$PWD/.harness/chrome" '*'--proxy-server=http://127.0.0.1:9 '*"--host-resolver-rules='MAP * ~NOTFOUND, EXCLUDE 127.0.0.1'"*'--remote-debugging-address=127.0.0.1 '*) ;; *) die "Chrome's line must name this unit's profile, the dead proxy, the resolver seal and a loopback DevTools address" ;; esac
for f in .r-*.out; do ! grep -E '^\$ ' "$f" | grep -oE 'https?://[^ '"'"']+' | grep -vE '^http://127\.0\.0\.1:' > /dev/null || die "$f runs a command with a URL that is not 127.0.0.1's"; done
for f in .r-*.out; do ! grep -E '^ *\$ (cd [^ ]+ && )?(exec )?java ' "$f" | grep -vF -- "java $JL " | grep -vF -- 'java -Djarmode=tools ' > /dev/null || die "$f starts a JVM without its locale pinned (S4.1)"; ! grep -E '^\$ jwebserver ' "$f" | grep -vF -- 'jwebserver -J-Duser.language=en -J-Duser.country=US ' > /dev/null || die "$f starts a jwebserver without its JVM's locale pinned (S4.1)"; done
for f in exercise/README.md exercise/solution/SOLUTION.md; do [ "$(grep -c '{ java ' "$f")" = 1 ] && grep '{ java ' "$f" | grep -qF -- "{ java $JL -cp " || die "$f: the exercise's java line must pin the JVM's locale (S4.1)"; done
NL=$(cat .r-*.out | grep -cE "^  its log: the demo token 0 times · X-Shutdown-Token 0 times\$" || true)
echo "  tokens: 0 raw copies in $(ls .harness/raw-* | wc -l | tr -d ' ') raw capture runs, in $(ls .r-*.out | wc -l | tr -d ' ') captures; the demo token 0 in the logs of every JVM that served ($LOGS here; the published captures' $NL), the READMEs, the harness, the exercise and receipts.md5; no absolute path, no unit number, no process line, no log time, no timestamp, no date, no thread number, no stack frame, no whole HTML page, no Chrome version, no 8080 or 35729, no carriage return in any capture; no Boot 3 error key; no harness class in the anchor; no bare wait; no stop by name; every JVM's locale pinned; every URL a capture runs is 127.0.0.1's"

S466='466c20ed7e0d5439cb052f32ce09de1b'
A_OK='  HTTP/1.1 200|  Vary: Origin|  Vary: Access-Control-Request-Method|  Vary: Access-Control-Request-Headers|  Access-Control-Allow-Origin: http://127.0.0.1:19486|  Access-Control-Allow-Methods: GET,PUT|  Access-Control-Allow-Headers: content-type|  Access-Control-Max-Age: 1800|  X-Post-Handle: set|  Allow: GET, HEAD, POST, PUT, DELETE, OPTIONS, PATCH|  Content-Length: 0|  Date: (the time: not printed)|  body: []'
A_NO='  HTTP/1.1 403|  Vary: Origin|  Vary: Access-Control-Request-Method|  Vary: Access-Control-Request-Headers|  Transfer-Encoding: chunked|  Date: (the time: not printed)|  body: [Invalid CORS request]'
PFH='Interceptor preHandle REQUEST /probe/cors/menu handler PreFlightHttpRequestHandler'
LIST='[{"name":"Meera","mealsPerDay":1,"pricePerMeal":150,"mealType":"NON_VEG"},{"name":"Priya","mealsPerDay":1,"pricePerMeal":120,"mealType":"VEGAN"},{"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"},{"name":"Sunil","mealsPerDay":3,"pricePerMeal":100,"mealType":"VEG"}]'
ck_preflight() { local PO S
  PO=$(cat .r-preflight.out)
  has "$PO" '  built the anchor · offline: yes · exit 0' "preflight: the anchor built offline"
  has "$PO" "  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 0 · md5 $S466" "preflight: the seven $S466"
  has "$PO" '    WARN o.s.web.servlet.PageNotFound: Request method '"'"'GET'"'"' is not supported' "preflight: the seven's one WARN, PageNotFound"
  has "$PO" "  the JVM's locale (the harness's Hooks): en_US" "preflight: the locale"
  # "the browser asks first ... allowed: the origin named back, GET and PUT, the header, a max age of eighteen hundred seconds nobody set,
  # three Vary lines ... the interceptor ran, its handler Spring's preflight handler"
  S=$(seg "$PO" "$(pfq 19480 /probe/cors/menu "$O_A")")
  [ "$(ans "$S")" = "$A_OK" ] || die "preflight: the allowed preflight's answer - got: $(ans "$S")"
  [ "$(cnt "$S" '  Vary: Origin')$(printf '%s\n' "$S" | grep -c '^  Vary: ')" = 13 ] || die "preflight: three Vary lines"
  [ "$(printf '%s\n' "$S" | grep '^  Allow: ' | sed 's/^  Allow: //' | tr ',' '\n' | grep -c .)" = 7 ] || die "preflight: Allow names seven methods"
  ccheck "$S" 0 0 3 "preflight: allowed"; hl "$S" | grep -qxF "$PFH" || die "preflight: the interceptor's handler PreFlightHttpRequestHandler"
  # "another origin: four oh three, Invalid CORS request, no content type - not a problem detail; the interceptor never ran"
  S=$(seg "$PO" "$(pfq 19480 /probe/cors/menu "$O_D")")
  [ "$(ans "$S")" = "$A_NO" ] || die "preflight: the refused preflight's answer - got: $(ans "$S")"
  nhas "$S" 'Content-Type' "preflight: the 403 has no Content-Type"; ccheck "$S" 0 0 0 "preflight: refused"
  # "a path no rule covers: two hundred, the methods, no CORS header at all"
  S=$(seg "$PO" "$(pfq 19480 /customers "$O_A")")
  [ "$(ans "$S")" = '  HTTP/1.1 200|  X-Post-Handle: set|  Allow: GET, HEAD, POST, PUT, DELETE, OPTIONS, PATCH|  Content-Length: 0|  Date: (the time: not printed)|  body: []' ] || die "preflight: the unconfigured path's answer - got: $(ans "$S")"
  nhas "$S" 'Access-Control-' "preflight: the unconfigured path, no CORS header"; ccheck "$S" 0 0 3 "preflight: unconfigured"
  hl "$S" | grep -qxF 'Interceptor preHandle REQUEST /customers handler PreFlightHttpRequestHandler' || die "preflight: the unconfigured path's handler"
  S=$(seg "$PO" "$(rq 19480 /probe/cors/menu "$O_A")"); has "$S" '  Access-Control-Allow-Origin: http://127.0.0.1:19486' "preflight: the allowed GET names the origin"; has "$S" '  body: [{"menu":"annotated"}]' "preflight: the allowed GET's body"; ccheck "$S" 0 0 4 "preflight: the allowed GET"
  S=$(seg "$PO" "$(rq 19480 /probe/cors/menu "$O_D")"); [ "$(ans "$S")" = "$A_NO" ] || die "preflight: the refused GET - 403"; ccheck "$S" 0 0 0 "preflight: the refused GET, the controller never ran"
  # "the customer list, asked from another origin by curl: two hundred, the whole list, no CORS header - the controller ran"
  S=$(seg "$PO" "$(rq 19480 /customers "$O_D")"); has "$S" '  HTTP/1.1 200' "preflight: the list, 200"; has "$S" "  body: [$LIST]" "preflight: the whole list"; nhas "$S" 'Access-Control-' "preflight: the list, no CORS header"; ccheck "$S" 0 0 3 "preflight: the list"
  hl "$S" | grep -qxF 'Interceptor preHandle REQUEST /customers handler TiffinBoxServer#customers' || die "preflight: the list's controller ran"
  S=$(seg "$PO" "$(rq 19480 /probe/cors/menu "" OPTIONS)"); has "$S" '  Allow: GET,HEAD,PUT,OPTIONS' "preflight: no Origin - Spring MVC's own OPTIONS answer"; nhas "$S" 'Access-Control-' "preflight: no Origin, no CORS header"
  hl "$S" | grep -qxF 'Interceptor preHandle REQUEST /probe/cors/menu handler HttpOptionsHandler#handle' || die "preflight: no Origin - HttpOptionsHandler"
  has "$PO" "  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0" "preflight: the routes' run, 0/0"
  grep -qF '@CrossOrigin(origins = "http://127.0.0.1:19486")' harness/probe/web/CorsRoutes.java && ! grep -qiE 'maxAge|max-age' harness/probe/web/CorsRoutes.java harness/probe/web/GlobalCors.java harness/probe/web/FilterCors.java || die "preflight: the harness sets no max age, and the annotation names one origin"
  echo "  preflight: the seven $S466; allowed - 200, the origin, GET,PUT, content-type, Max-Age 1800 (set by nobody), 3 Vary, Allow 7 methods, PreFlightHttpRequestHandler; refused - 403 Invalid CORS request, no Content-Type, no hook; unconfigured - 200, Allow, no CORS header; GETs: allowed ACAO, refused 403 no controller, the list from the other origin 200 whole with no CORS header; no Origin - Allow GET,HEAD,PUT,OPTIONS; 0/0"; }
ck_ways() { local WO S B
  WO=$(cat .r-ways.out)
  has "$WO" "  the annotation's answer and the registry's, line for line - allowed: the same · refused: the same" "ways: @CrossOrigin = addCorsMappings"
  S=$(seg "$WO" "$(pfq 19481 /probe/global/menu "$O_A")"); [ "$(ans "$S")" = "$A_OK" ] || die "ways: the registry's answer"
  S=$(seg "$WO" "$(pfq 19482 /probe/cors/menu "$O_A")"); [ "$(ans "$S")" = "$A_OK" ] || die "ways A: the allowed preflight's headers"
  B=$(blk ways "B - the same" "A' - ")
  S=$(seg "$B" "$(pfq 19483 /probe/cors/menu "$O_A")"); [ "$(ans "$S")" = '  HTTP/1.1 200|  Content-Length: 0|  Date: (the time: not printed)|  body: []' ] || die "ways B: the annotated route's preflight, empty - got: $(ans "$S")"; ccheck "$S" 0 0 0 "ways B: no hook"
  S=$(seg "$B" "$(pfq 19483 /probe/filter/menu "$O_A")"); [ "$(ans "$S")" = '  HTTP/1.1 200|  Vary: Origin|  Vary: Access-Control-Request-Method|  Vary: Access-Control-Request-Headers|  Access-Control-Allow-Origin: http://127.0.0.1:19486|  Access-Control-Allow-Methods: GET,PUT|  Access-Control-Allow-Headers: content-type|  Content-Length: 0|  Date: (the time: not printed)|  body: []' ] || die "ways B: the filter's own answer - no Max-Age, no Allow - got: $(ans "$S")"; ccheck "$S" 0 0 0 "ways B: the filter's path, no hook"
  S=$(seg "$B" "$(rq 19483 /probe/cors/menu "$O_A")"); has "$S" '  Access-Control-Allow-Origin: http://127.0.0.1:19486' "ways B: the actual GET keeps its header"
  has "$WO" "A' against A, its label aside, line for line the same: yes" "ways: A' = A"
  [ "$(printf '%s\n' "$WO" | grep -c "^  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0\$")" = 4 ] && [ "$(printf '%s\n' "$WO" | grep -c "^  the JVM's locale (the harness's Hooks): en_US\$")" = 4 ] || die "ways: four JVMs, each en_US and 0/0"
  grep -qF 'source.registerCorsConfiguration("/probe/filter/**", c);' harness/probe/web/FilterCors.java && grep -qF 'registry.addMapping("/probe/global/**").allowedOrigins("http://127.0.0.1:19486").allowedMethods("GET", "PUT");' harness/probe/web/GlobalCors.java || die "ways: the filter's one path, the registry's rule"
  echo "  ways: the registry's preflight = the annotation's, line for line (allowed and refused); A - the headers; B (FilterCors on every path, its one rule for /probe/filter/**) - the annotated route's preflight 200, Content-Length 0, no CORS header, no hook; the filter's own path: no Max-Age, no Allow; the actual GET keeps its header; A' = A"; }
ck_star() { local SO S c
  SO=$(cat .r-star.out)
  has "$SO" "  the JVM's locale (the harness's Hooks): en_US" "star: the locale"
  [ "$(printf '%s\n' "$SO" | grep -n "^  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0\$" | cut -d: -f1)" -lt "$(printf '%s\n' "$SO" | grep -n '^\$ curl -s -D' | head -1 | cut -d: -f1)" ] || die "star: it starts with 0 WARN 0 ERROR"
  SENT='java.lang.IllegalArgumentException: When allowCredentials is true, allowedOrigins cannot contain the special value "*" since that cannot be set on the "Access-Control-Allow-Origin" response header. To allow credentials to a set of origins, list them explicitly or consider using "allowedOriginPatterns" instead.'
  for c in "$(pfq 19481 /probe/global/menu "$O_A")" "$(rq 19481 /probe/global/menu "$O_A")" "$(rq 19481 /probe/global/menu "")"; do
    S=$(seg "$SO" "$c")
    [ "$(ans "$S")" = '  HTTP/1.1 500|  Content-Type: application/json|  Transfer-Encoding: chunked|  Date: (the time: not printed)|  Connection: close|  body: [{"timestamp":"…","status":500,"error":"Internal Server Error","path":"/probe/global/menu"}]' ] || die "star: $c - Boot's 500 - got: $(ans "$S")"
    ccheck "$S" 0 1 3 "star: $c"; has "$S" "      $SENT" "star: Spring's sentence"
    has "$S" '    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: Servlet.service() for servlet [dispatcherServlet] in context with path [] threw exception [Request processing failed: '"$SENT"'] with root cause' "star: Tomcat's ERROR line"
    ! hl "$S" | grep -q 'REQUEST' || die "star: no hook on the request itself"; done
  S=$(seg "$SO" "$(rq 19481 /probe/cors/menu "")"); has "$S" '  HTTP/1.1 200' "star: the annotated route, 200"; ccheck "$S" 0 0 4 "star: the annotated route"
  has "$SO" "  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 3" "star: the run, 0/3"
  grep -qF 'registry.addMapping("/probe/global/**").allowedOrigins("*").allowCredentials(true);' harness/probe/web/StarCreds.java || die "star: the harness's rule"
  echo "  star: starts 0/0; the preflight, the GET with an Origin and the GET with none - each Boot's 500, Connection: close, 1 ERROR (Tomcat's) with Spring's sentence; the annotated route 200; 0/3"; }
ck_exercise() { local XS XE l l0
  XS=$(blk exercise "the README's" "the solution's"); XE=$(blk exercise "the solution's" '')
  l='the preflight: 200 · Access-Control-Allow-Origin: [http://127.0.0.1:19486] · Access-Control-Max-Age: [1800]'; l0='the preflight: 200 · Access-Control-Allow-Origin: [] · Access-Control-Max-Age: []'
  has "$XE" "    $l" "exercise: the solution"; has "$XS" "    $l0" "exercise: as shipped"
  awk '/^\*\*Done\*\*/ { f = 1 } f' exercise/README.md | grep -qxF -- "$l" || die "exercise/README.md: Done names no such line"
  grep -qxF -- "$l" exercise/solution/SOLUTION.md || die "SOLUTION.md: the measured run shows no such line"
  grep -qF -- "\`$l0\`" exercise/README.md || die "exercise/README.md: the shipped line's answer is not named"
  has "$XS" '  exit 0 · what they printed:' "exercise: the README's commands, exit 0"; has "$XE" '  exit 0 · what they printed:' "exercise: the solution's lines, exit 0"
  for b in XS XE; do eval "B_=\$$b"; has "$B_" "  the shell is now in: this unit's folder · the JVM's locale in its log: en_US · the copy's own token in its log: 0 times · WARN lines in its log: 0 · ERROR lines: 0 · listening on 19488 now: 0" "exercise $b: the shell, the locale, the token, 0/0, 19488 free"; done
  has "$XE" '    -    FilterRegistrationBean<CorsFilter> adminCors() {' "exercise: the solution removes the filter's bean"
  [ "$(printf '%s\n' "$XE" | grep -c '^    +')" = 0 ] && [ "$(printf '%s\n' "$XE" | grep -c '^    -')" = 19 ] || die "exercise: the solution removes 19 lines and adds none"
  [ "$(printf '%s\n' "$XE" | grep -c '^  \$ export ')" = 2 ] || die "exercise: SOLUTION.md gives the README's two export lines"
  EXQ="Your turn: the README's preflight comes back with no CORS headers. Find the filter that answers every preflight, remove it, and ask again."
  grep -qxF -- "**Your turn:** ${EXQ#Your turn: }" exercise/README.md || die "exercise/README.md: the spoken exercise line"
  [ "$(printf '%s\n' "$EXQ" | wc -w | tr -d ' ')" -le 25 ] || die "exercise: the spoken line is over 25 words"
  echo "  exercise: one env -i shell - the README as written (a CorsFilter bean beside @CrossOrigin) -> $l0; the solution (the bean removed) -> $l; the shell in this unit's folder after each"; }
ck_browser() { local BO V1 V2 V3 V4 VC VD VE S
  BO=$(cat .r-browser.out)
  V1=$(blk browser "visit 1 - " "visit 2 - "); V2=$(blk browser "visit 2 - " "visit 3 - "); V3=$(blk browser "visit 3 - " "visit 4 - "); V4=$(blk browser "visit 4 - " "C (labelled)"); VC=$(blk browser "C - the page" "D (labelled)"); VD=$(blk browser "D (labelled)" "D again - "); VE=$(blk browser "D again - " "the origins:")
  for p in 19486 19487; do has "$BO" "\$ $(jw $p)" "browser: the origin on $p"; done
  [ "$(printf '%s\n' "$BO" | grep -c '^  listens on: 127.0.0.1:1948[4-9] · loopback only: yes$')" = 6 ] || die "browser: two origins, two TiffinBoxes, two Chromes - each loopback"
  [ "$(printf '%s\n' "$BO" | grep -c '^  its profile, .harness/chrome, made fresh for this run (it did not exist before this line): yes$')" = 2 ] || die "browser: two fresh profiles"
  [ "$(printf '%s\n' "$BO" | grep -c '^  Chrome exit 0 · listening on 19489 now: 0 · its profile removed$')" = 2 ] || die "browser: Chrome left twice, exit 0"
  has "$BO" "  Chrome's NetLog - every address it connected to or tried, its own background requests included: 127.0.0.1 only: yes · ports 19484, 19486, 19487 among them: yes" "browser: the seal"
  has "$BO" "  Chrome's NetLog - every address it connected to or tried, its own background requests included: 127.0.0.1 only: yes · ports 19485, 19486 among them: yes" "browser C: the seal"
  [ "$(printf '%s\n' "$BO" | grep -c "^  the JVM's locale (the harness's Hooks): en_US\$")" = 2 ] || die "browser: two JVMs, en_US"
  # "the allowed PUT: the browser asks first - OPTIONS - then the PUT; the page reads two hundred"
  has "$V1" '  the page printed: answer 200 {"menu":"annotated"}' "browser 1: the page read the answer"
  has "$V1" "  Chrome's own record (its DevTools protocol) - the requests the page made to TiffinBox: 2" "browser 1: two requests"
  has "$V1" '    OPTIONS /probe/cors/menu - a preflight, for the PUT below · sent: yes · the answer Chrome got: 200' "browser 1: the preflight"
  has "$V1" '    PUT /probe/cors/menu - the page'"'"'s fetch · sent: yes · the answer Chrome got: 200 · handed to the page: yes' "browser 1: the PUT"
  for h in 'Access-Control-Request-Method: PUT' 'Access-Control-Request-Headers: content-type' 'Origin: http://127.0.0.1:19486' 'Sec-Fetch-Mode: cors' 'Sec-Fetch-Site: same-site' 'Accept-Language: en-US,en;q=0.9'; do has "$V1" "        $h" "browser 1: Chrome's preflight, as sent"; done
  has "$V1" '      as Chrome sent it, its 13 headers:' "browser 1: the preflight's 13 headers"
  [ "$(hl "$V1" | grep -E '^Dump > (OPTIONS|PUT) ' | paste -sd'|' -)" = 'Dump > OPTIONS /probe/cors/menu|Dump > PUT /probe/cors/menu' ] || die "browser 1: the server got OPTIONS, then PUT"
  hl "$V1" | grep -qxF 'Dump < Access-Control-Max-Age: 1800' && hl "$V1" | grep -qxF "$PFH" && hl "$V1" | grep -qxF 'CorsRoutes annotated' || die "browser 1: the server's preflight answer (Max-Age 1800, PreFlightHttpRequestHandler) and the route"
  # "again: no OPTIONS - the preflight cache"
  has "$V2" '$ sleep 7' "browser 2: seven seconds after visit 1"
  has "$V2" "  Chrome's own record (its DevTools protocol) - the requests the page made to TiffinBox: 1" "browser 2: one request"
  has "$V2" '  the page printed: answer 200 {"menu":"annotated"}' "browser 2: the page read the answer"
  ! hl "$V2" | grep -q '^Dump > OPTIONS' && [ "$(hl "$V2" | grep -c '^Dump > PUT /probe/cors/menu$')" = 1 ] || die "browser 2: the server got the PUT alone"
  # "the other origin: OPTIONS, four oh three - and the PUT never leaves the browser"
  has "$V3" '  the page printed: refused: TypeError: Failed to fetch' "browser 3: the page refused"
  has "$V3" '    OPTIONS /probe/cors/menu - a preflight, for the PUT below · sent: yes · the answer Chrome got: 403' "browser 3: the preflight, 403"
  has "$V3" '    PUT /probe/cors/menu - the page'"'"'s fetch · sent: no · no answer · handed to the page: no - Chrome'"'"'s CORS check: PreflightMissingAllowOriginHeader' "browser 3: the PUT never sent"
  ! hl "$V3" | grep -q '^Dump > PUT' && hl "$V3" | grep -qxF 'Dump < 403 OPTIONS /probe/cors/menu' || die "browser 3: the server got OPTIONS alone"
  # "a simple GET from the other origin: no preflight; the server ran it - two hundred, the whole list - and the page never saw it"
  has "$V4" '  the page printed: refused: TypeError: Failed to fetch' "browser 4: the page refused"
  has "$V4" "  Chrome's own record (its DevTools protocol) - the requests the page made to TiffinBox: 1" "browser 4: one request, no preflight"
  has "$V4" '    GET /customers - the page'"'"'s fetch · sent: yes · the answer Chrome got: 200 · handed to the page: no - Chrome'"'"'s CORS check: MissingAllowOriginHeader' "browser 4: Chrome got 200 and withheld it"
  hl "$V4" | grep -qxF 'Interceptor preHandle REQUEST /customers handler TiffinBoxServer#customers' && hl "$V4" | grep -qxF 'Dump < 200 GET /customers' && hl "$V4" | grep -qxF "Dump < body: [$LIST]" || die "browser 4: the server ran the controller and sent the whole list"
  # C: "joined, in the browser: the preflight gets an empty two hundred, and the PUT is never sent"
  has "$VC" '  the page printed: refused: TypeError: Failed to fetch' "browser C: the page refused"
  has "$VC" '    OPTIONS /probe/cors/menu - a preflight, for the PUT below · sent: yes · the answer Chrome got: 200' "browser C: the preflight, 200"
  has "$VC" '    PUT /probe/cors/menu - the page'"'"'s fetch · sent: no · no answer · handed to the page: no - Chrome'"'"'s CORS check: PreflightMissingAllowOriginHeader' "browser C: the PUT never sent"
  [ "$(hl "$VC" | grep '^Dump < ' | paste -sd'|' -)" = 'Dump < 200 OPTIONS /probe/cors/menu|Dump < body: []' ] && ! hl "$VC" | grep -q '^Interceptor' || die "browser C: the server answered the preflight empty, no hook"
  # D, the control: "with no max age, the browser asks again" - the filter's own path, no Max-Age in its answer, asked twice 7 s apart
  for b in VD VE; do eval "B_=\$$b"
    has "$B_" '  the page printed: answer 200 {"menu":"filter"}' "browser $b: the page read the answer"
    has "$B_" "  Chrome's own record (its DevTools protocol) - the requests the page made to TiffinBox: 2" "browser $b: two requests"
    has "$B_" '    OPTIONS /probe/filter/menu - a preflight, for the PUT below · sent: yes · the answer Chrome got: 200' "browser $b: the preflight"
    [ "$(hl "$B_" | grep -E '^Dump > (OPTIONS|PUT) ' | paste -sd'|' -)" = 'Dump > OPTIONS /probe/filter/menu|Dump > PUT /probe/filter/menu' ] || die "browser $b: the server got OPTIONS, then PUT"
    ! hl "$B_" | grep -q '^Dump < Access-Control-Max-Age' || die "browser $b: the filter's answer carries no Max-Age"; done
  has "$VE" '$ sleep 7' "browser D again: seven seconds after D"
  for b in V1 V2 V3 V4 VC VD VE; do eval "B_=\$$b"; has "$B_" '    WARN lines they added: 0 · ERROR lines: 0' "browser $b: 0/0"; done
  has "$BO" '  the origin on 19486 stopped by its pid · exit 143 · listening on 19486 now: 0' "browser: the origin 19486 stopped"
  has "$BO" '  the origin on 19487 stopped by its pid · exit 143 · listening on 19487 now: 0' "browser: the origin 19487 stopped"
  echo "  browser: Chrome, two fresh sealed profiles, NetLog 127.0.0.1 only; 1 - OPTIONS (13 headers as sent, same-site, en-US) then PUT, the page reads 200; 2 - the PUT alone (the preflight cache); 3 - OPTIONS 403, the PUT never sent (PreflightMissingAllowOriginHeader); 4 - GET /customers: the server ran it, 200 and the whole list, the page refused (MissingAllowOriginHeader); C - FilterCors joined: the preflight 200 empty, no hook, the PUT never sent; visit 2 came 7 s after visit 1; D (the control) - the filter's own path, no Max-Age: OPTIONS then PUT, and 7 s later OPTIONS again"; }
ck_preflight; ck_ways; ck_star; ck_exercise
if [ $BROWSER = yes ]; then ck_browser
else echo "  *** the browser step: $WHYNOT - every curl capture is made and checked; the browser capture needs Chrome and node 22 or later (README.md, \"The browser\") ***"; exit 2; fi
[ -z "$unpub" ] || die "no published hash for:$unpub - check the captures, then copy the md5s above into receipts.md5 and run again"
echo "c6-unit19: every capture 3/3 and = published; every spoken number asserted; 0 raw demo tokens in every capture and every log"
