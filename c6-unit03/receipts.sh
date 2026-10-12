#!/bin/bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25.0.4.1 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# Course 6 · DispatcherServlet, Opened - this unit's receipts. In Core Java II you wrote a router: an annotation, a scan, a
# TreeMap keyed "VERB path", Method.invoke. Spring MVC's DispatcherServlet does the same jobs - find the handler, call it, write the
# answer - through lists of strategies. This unit opens a running one and reads its lists beside yours, in one JVM.
# No anchor change: the tree is ../c5-unit27/after (the last course's final tree; ../c5-tiffinbox holds the same files), reached
# through the link `anchor`, COPIED under .harness/ and changed only in the copy: Spring MVC's starter added to the web module's POM,
# and the Boot plugin's two Jackson 3 excludes dropped. So one JVM runs two servers - TiffinBox's own (the JDK's) and Tomcat, Spring
# MVC's - each on its own port on 127.0.0.1. No native build, no Docker, no GraalVM. Six captures, each run three times and hashed;
# cap() DIES when a hash differs from receipts.md5; every number the video says is asserted at the bottom by a check that can fail;
# the demo token is masked (gsub), and the checks count 0 raw copies of it in every capture, in the log of every run, and in every
# file this unit ships.
#   toy         the copy (its POM against the anchor's); the router you wrote, by grep - the annotation, the scan, the TreeMap,
#               Method.invoke; one JVM, two servers (19320 TiffinBox's, 19321 Tomcat), the addresses read off the pid; the scan's
#               DEBUG lines and the TreeMap's INFO line; each server asked for its own route and for the other's; the seven on
#               TiffinBox's server; after POST /shutdown, which server stopped and whether the JVM lived; then the JVM stopped by pid
#   lists       the DispatcherServlet's strategy lists, read off the running servlet after one request (19322/19323) by the
#               harness's Strategies: the handler mappings by the servlet's public getter, the rest by reflection - each list set
#               beside the context's own beans of that type; and what the servlet held at ready, before any request
#   scan        declare, scan, register, invoke - side by side in one start (19324/19325): TiffinBox's scan at DEBUG and Spring
#               MVC's registration at TRACE, before Tomcat started; one request's frames, down to the DispatcherServlet; two paths
#               a pattern refuses, and the prefix TiffinBox's server takes
#   converters  what writes a JSON answer (19326/19327): A the adapter's message converters, and one request at DEBUG and TRACE -
#               the converter chosen, and no view rendered; C (labelled): a second copy, the last course's two excludes kept; A' = A
#   init        when the servlet reads its lists (19328/19329) - Boot's own default, from its metadata; A the default, B
#               --spring.mvc.servlet.load-on-startup=1, A' = A: the lines before any request reached Tomcat, the harness at ready,
#               then the first request
#   exercise    exercise/README.md's commands and exercise/solution/SOLUTION.md's, read from the files and run as written
# "$CURLSET" is the comparison set since the last course's secrets lesson (../c5-unit11/curlset.sh: the seven requests, POST
# /shutdown with the token's header read from the file). "$M2" is this unit's own repository, .m2-demo. "$pid" is the JVM this
# script started. The harness - harness/probe/*.java, package probe, outside com.tiffinbox - joins TiffinBox by
# --spring.main.sources=..., on the class path the anchor's README gives for the extracted jar, plus the harness's folder; every
# run passes options only (no harness passes a bare word to the guarded tree).
# The network: every build runs offline (-o) against .m2-demo and says so ("offline: yes"); a build that cannot resolve an artifact
# offline goes to Maven Central once, and says that ("offline: no - ..."). At run time nothing leaves 127.0.0.1: both servers
# listen there (asserted on the pid), every request goes there, and Logback writes to the terminal only.
# Masks and filters (README.md declares each; sub/gsub only): the demo token becomes "[masked: the N-character token]", N its
# length in the file the run served with; this folder's absolute path "…", the folder above it "…/..", the home folder "~"; your
# user name "<user>"; the timestamp in Spring's error body "<a time, masked: ISO-8601>" or "<a time, masked: epoch milliseconds>";
# the milliseconds of "Completed initialization in N ms" "…" - in every line of every capture. A log line is printed from its
# level on (its time, process id and thread cut); a log is read through a declared selection, every gap counted; TiffinBox's five
# route lines and each TRACE registration block are printed sorted (reflection's order is unspecified - Core Java II said so).
# No duration is captured.
# Ports (brief ⚑1, 19320-19329): toy 19320/19321 · lists 19322/19323 · scan 19324/19325 · converters 19326/19327 (A and C) · init
# 19328/19329 (A, B, A') · the exercise 19320/19321. In each pair the first is TiffinBox's own server, the second Tomcat. 18425
# (TiffinBox's default) and 8080 (Tomcat's) are checked free too, and never bound.
set -e
# bash 5.2 and later turn an & in the replacement of ${x/pattern/replacement} into the matched text (patsub_replacement, on by
# default). Switched off, so /bin/bash 3.2 (./receipts.sh) and a newer bash (bash receipts.sh) run the same commands.
shopt -u patsub_replacement 2> /dev/null || true
cd "$(dirname "$0")"
mkdir .r-lock 2> /dev/null || { echo "  *** another receipts.sh is running in this folder (.r-lock exists) - if none is, rmdir .r-lock ***"; exit 1; }
# On every exit - the end, a failed check, or Ctrl-C - stop the JVM this script started in the background ($pid), if it still
# runs, then sweep(): anything of this run still alive in its process group - a TiffinBox JVM, a Maven build, javac - is stopped.
# After an interrupt, a capture's unfinished runs (.r-NAME.1-3) go too; after a failed check they stay, for the diff the message
# names. The clean-up ignores a second Ctrl-C, and nothing in it can fail under set -e, so it always reaches the rmdir; the script
# still exits 130 after an interrupt (README.md, "Interrupted").
pid=""
sweep() { local g i l
  g=$(ps -o pgid= -p $$ 2> /dev/null | tr -d ' ') || g=""
  [ -n "$g" ] || return 0
  i=0; while [ $i -lt 20 ]; do
    l=$(ps -axo pid=,pgid=,command= 2> /dev/null | awk -v g="$g" -v me=$$ '
      $2 == g && $1 != me && $3 != "awk" && $3 != "ps" && (index($0, "tiffinbox-web-1.0.0.jar") || index($0, "com.tiffinbox.web.TiffinBoxServer") || index($0, "plexus-classworlds") || $3 == "javac" || index($3, "/javac")) { print $1 }' | paste -sd' ' -) || l=""
    [ -n "$l" ] || return 0
    if [ $i -lt 10 ]; then kill $l 2> /dev/null || true; else kill -9 $l 2> /dev/null || true; fi
    sleep 0.5; i=$((i + 1)); done; }
trap 'trap "" INT TERM; if [ -n "$pid" ] && kill "$pid" 2> /dev/null; then wait "$pid" 2> /dev/null || true; fi; sweep || true; [ -z "$INTR" ] || rm -f .r-*.[123]; rmdir .r-lock 2> /dev/null || true' EXIT
INTR=""; trap 'INTR=1; exit 130' INT TERM
exec 3>&1                                            # die() speaks to the terminal even inside a redirected capture
die() { echo "  *** $* ***" >&3; exit 1; }
java -version 2>&1 | grep -q 'version "25' || die "JDK 25 needed; JAVA_HOME gives: $(java -version 2>&1 | head -1)"
for t in python3 curl rsync lsof md5 unzip diff; do command -v $t > /dev/null || die "$t is needed here"; done
# A variable of yours must not become a property source, a JVM flag or a build setting: every TIFFINBOX_*, SPRING_*, MANAGEMENT_*,
# SERVER_* and LOGGING_* variable, DEBUG (Boot reads it as --debug), the variables that inject JVM flags, MAVEN_OPTS, MAVEN_ARGS and
# NATIVE_IMAGE_OPTIONS are removed first (the last course's failure lesson's loop, verbatim: sed -E, a canary planted under every
# name first, and the run stops if one survives). This unit runs no Docker, so COMPOSE_* is not in the list.
for v in TIFFINBOX_CANARY SPRING_CANARY MANAGEMENT_CANARY SERVER_CANARY LOGGING_CANARY DEBUG JAVA_TOOL_OPTIONS JDK_JAVA_OPTIONS _JAVA_OPTIONS MAVEN_OPTS MAVEN_ARGS NATIVE_IMAGE_OPTIONS; do export "$v=planted-canary"; done
for v in $(env | sed -n -E 's/^(TIFFINBOX_[A-Za-z0-9_]*|SPRING_[A-Za-z0-9_]*|MANAGEMENT_[A-Za-z0-9_]*|SERVER_[A-Za-z0-9_]*|LOGGING_[A-Za-z0-9_]*|DEBUG|JAVA_TOOL_OPTIONS|JDK_JAVA_OPTIONS|_JAVA_OPTIONS|MAVEN_OPTS|MAVEN_ARGS|NATIVE_IMAGE_OPTIONS)=.*/\1/p'); do unset "$v"; done
[ -z "$(env | grep -- '=planted-canary$')" ] || die "a variable survived the clean-up above: $(env | grep -- '=planted-canary$' | sed 's/=.*//' | paste -sd' ' -)"
# Every request this script makes goes to 127.0.0.1: an HTTP proxy named in your environment would carry curl's requests to that
# proxy instead - 127.0.0.1 and localhost go first in no_proxy and NO_PROXY.
export no_proxy="127.0.0.1,localhost${no_proxy:+,$no_proxy}" NO_PROXY="127.0.0.1,localhost${NO_PROXY:+,$NO_PROXY}"
[ -e secrets ] && die "this folder holds a secrets/ - remove it: every run here starts in a folder under .harness/"
[ -L anchor ] && [ "$(readlink anchor)" = ../c5-unit27/after ] || die "anchor must be the link to ../c5-unit27/after - this unit changes nothing in the anchor"
[ -e anchor/secrets ] || [ -e anchor/tiffinbox-web/secrets ] || [ -e anchor/tiffinbox-local.yaml ] || [ -e anchor/target ] || [ -e anchor/tiffinbox-web/target ] || [ -e anchor/banner.txt ] && die "anchor/ (../c5-unit27/after) holds a secrets/, a tiffinbox-local.yaml, a banner.txt or a target/ - it is a frozen copy, never built in place; remove them"
[ -f anchor/pom.xml ] && [ -f anchor/README.md ] || die "anchor/ (../c5-unit27/after) is missing"
# Both trees are frozen: the anchor this unit reads, and the last course's long-lived copy of it. Their files must agree (build
# output and secrets aside: git ignores them).
[ -z "$(diff -rq -x target -x secrets -x .m2-demo anchor ../c5-tiffinbox 2>&1)" ] || die "anchor/ and ../c5-tiffinbox differ: $(diff -rq -x target -x secrets -x .m2-demo anchor ../c5-tiffinbox 2>&1 | head -3)"
M2="$PWD/.m2-demo"; U="$PWD"; UP="$(cd .. && pwd)"; ME="$(id -un)"
TF=secrets/tiffinbox/shutdown-token                  # the config tree's file for tiffinbox.shutdown-token
TOKEN=not-a-real-token-demo-only                     # FAKE, and meant to look it: written into .harness/*/secrets/, never printed
CURLSET=../c5-unit11/curlset.sh
[ -f "$CURLSET" ] || die "$CURLSET is missing"
[ "$(md5 -q "$CURLSET")" = bfa34552cb762f099b6a389386324468 ] || die "$CURLSET is not the last course's comparison set (md5 bfa34552...)"
for f in harness/probe/Hello.java harness/probe/Frames.java harness/probe/Strategies.java harness/probe/Converters.java exercise/README.md exercise/solution/SOLUTION.md README.md; do [ -f "$f" ] || die "$f is missing"; done

# The ports, BEFORE anything is wiped.
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
for p in 18425 8080 19320 19321 19322 19323 19324 19325 19326 19327 19328 19329; do
  [ "$(listeners $p)" = 0 ] || die "something already listens on $p - this unit's ports must be free; if it is a TiffinBox an interrupted run left behind, stop it: kill $(lsof -nP -iTCP:$p -sTCP:LISTEN -t 2> /dev/null | paste -sd' ' -)"; done

# ---- the commands: read from anchor/README.md (the anchor's own) and from README.md (this unit's: the copy's harness folder and its
# ---- options), and asserted - each line must be there, whole -----------------------------------------------------------------
readme() { grep -m1 -xF -- "$1" anchor/README.md > /dev/null || die "anchor/README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
mine() { grep -m1 -xF -- "$1" README.md > /dev/null || die "README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
R_PLAIN=$(readme 'mvn -B package')
R_EXTRACT=$(readme 'java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted')
R_CP=$(readme 'java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431')
R_DEBUG=$(readme 'java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --logging.level.kitchen=debug')
R_WEB=$(readme 'java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --logging.level.web=debug')
R_READY=$(readme "curl -s -w ' %{http_code}\n' http://127.0.0.1:18431/actuator/health/readiness")
R_GET=$(readme "curl -s -w ' %{http_code}\n' http://127.0.0.1:18431/customers")
J_JAVAC=$(mine 'javac -d ../classes -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*" ../../harness/probe/*.java')
SRC='--spring.main.sources'
KDBG=${R_DEBUG##* }; WDBG=${R_WEB##* }
[ "$KDBG" = --logging.level.kitchen=debug ] && [ "$WDBG" = --logging.level.web=debug ] || die "the anchor README's two logging flags"
MAPT=--logging.level.org.springframework.web.servlet.mvc.method.annotation.RequestMappingHandlerMapping=trace
DST=--logging.level.org.springframework.web.servlet.DispatcherServlet=trace
LOS=--spring.mvc.servlet.load-on-startup=1
# cpl TPORT SPORT 'OPTIONS': the anchor README's class-path line, the harness's folder (../classes, from the copy) added to its class
# path, its port made TPORT, Tomcat given 127.0.0.1 and SPORT, then OPTIONS. Each line this script runs must be README.md's, whole.
cpl() { local c=${R_CP/lib\/\*\" /lib\/*:..\/classes\" }; c=${c/--tiffinbox.port=18431/--tiffinbox.port=$1 --server.address=127.0.0.1 --server.port=$2}; printf '%s %s\n' "$c" "$3"; }
L_TOY=$(mine "$(cpl 19320 19321 "$SRC=probe.Hello $KDBG")")
L_LISTS=$(mine "$(cpl 19322 19323 "$SRC=probe.Strategies")")
L_SCAN=$(mine "$(cpl 19324 19325 "$SRC=probe.Hello,probe.Frames $KDBG $MAPT")")
L_CONV=$(mine "$(cpl 19326 19327 "$SRC=probe.Hello,probe.Converters $WDBG $DST")")
L_INITA=$(mine "$(cpl 19328 19329 "$SRC=probe.Strategies")")
L_INITB=$(mine "$(cpl 19328 19329 "$SRC=probe.Strategies $LOS")")
# off DIR 'README mvn LINE': the README's Maven line as this script runs it - from DIR, offline (-o), this unit's own repository,
# clean and without tests. dev() takes those things back out, and must give the README's line again.
off() { local c=${2/mvn -B /mvn -o -B -Dmaven.repo.local=\"\$M2\" }; c=${c/ package/ -DskipTests clean package}; printf 'cd %s && %s\n' "$1" "$c"; }
dev() { local c=${1#cd * && }; c=${c/ -o -B -Dmaven.repo.local=\"\$M2\" / -B }; c=${c/ -DskipTests clean / }; printf '%s\n' "$c"; }
url() { printf '%s\n' "${1/:18431\//:$2/}"; }
exe() { printf '%s\n' "$1" | sed -E 's/&& (([A-Z_]+=[^ ]* )*)/\&\& \1exec /'; }
[ "$(dev "$(off .harness/x "$R_PLAIN")")" = "$R_PLAIN" ] || die "not the README's build line with the offline changes"
# A request: the README's /customers line, its port and path changed, the content type added after the status - this unit's one
# change to it, asserted here.
Q=${R_GET/\\n\'/ %\{content_type\}\\n\'}
[ "$Q" = "curl -s -w ' %{http_code} %{content_type}\n' http://127.0.0.1:18431/customers" ] || die "the request line: the README's, the content type added"
echo "  the commands: anchor/README.md gives the 7 lines this script derives from, README.md the 7 it adds (the harness's javac, six runs)"

# ---- the checks that can fail, each shown failing on a planted value first (README.md, "Found on the way") ---------------------
# bindok 'ADDRESSES' TPORT SPORT: a JVM of this unit may listen on 127.0.0.1:TPORT and 127.0.0.1:SPORT, and nowhere else
bindok() { [ "$1" = "127.0.0.1:$2 127.0.0.1:$3" ]; }
bindok '*:19321 127.0.0.1:19320' 19320 19321 && die "the bind check passed a wildcard address (planted)"
bindok '127.0.0.1:19320' 19320 19321 && die "the bind check passed one server of two (planted)"
bindok '127.0.0.1:19320 127.0.0.1:19321' 19320 19321 || die "the bind check refused the two loopback addresses"

# ---- build: before the captures - two copies of the tree, each with a config tree; the README's plain build in each, then the
# ---- README's extract line; the harness compiled against the first. On a fresh clone (.m2-demo empty: git ignores it) the first
# ---- build fills .m2-demo, once.
rm -rf .harness; mkdir -p .harness
# mbuild 'COMMAND' LOG LABEL: the command, run as printed (eval), its log kept in LOG (never printed whole); Maven Central only if
# the offline build could not resolve something - and the line says which (offline: yes / no).
mbuild() { local how=yes ec=0 c=$1
  (eval "$c") > "$2" 2>&1 < /dev/null || ec=$?
  if [ $ec != 0 ] && grep -qE 'offline mode|Could not resolve|could not be resolved|Cannot access|No plugin found for prefix' "$2"; then
    how="no - the offline build could not resolve an artifact, so Maven Central was asked"; ec=0
    (eval "${c/mvn -o -B /mvn -B }") > "$2" 2>&1 < /dev/null || ec=$?; fi
  [ $ec = 0 ] || { tail -30 "$2" >&3
    ! grep -qE 'Could not resolve|could not be resolved|Could not transfer|Cannot access' "$2" || die "build failed: $3 - Maven could resolve neither from .m2-demo nor from Maven Central: a fresh clone's first run needs the network once, to fill .m2-demo"
    die "build failed: $3"; }
  echo "  built $3 · offline: $how · exit $ec"; }
tree() { mkdir -p "$1/secrets/tiffinbox"; (umask 077 && printf '%s\n' "$TOKEN" > "$1/$TF"); chmod 700 "$1/secrets" "$1/secrets/tiffinbox"; }
# webmvc POM [keep]: the copy's change, made by a program and checked - Spring MVC's starter, one line before </dependencies>; and,
# unless "keep", the Boot plugin's two tools.jackson.core <exclude>s dropped (the Compose module's exclude and the native plugin's
# three exclusions stay)
webmvc() { python3 - "$1" "${2:-drop}" <<'PY'
import sys
p, how = sys.argv[1], sys.argv[2]; s = open(p).read()
dep = '    <dependency><groupId>org.springframework.boot</groupId><artifactId>spring-boot-starter-webmvc</artifactId></dependency>\n'
assert s.count('  </dependencies>') == 1 and 'spring-boot-starter-webmvc' not in s, "the POM's dependencies"
s = s.replace('  </dependencies>', dep + '  </dependencies>')
ex = ''.join('            <exclude>\n              <groupId>tools.jackson.core</groupId>\n              <artifactId>%s</artifactId>\n            </exclude>\n' % a
             for a in ('jackson-databind', 'jackson-core'))
assert s.count(ex) == 1, "the Boot plugin's two Jackson 3 excludes"
if how == 'drop': s = s.replace(ex, '')
open(p, 'w').write(s)
PY
}
for d in serve kept; do rsync -a --exclude target --exclude secrets --exclude .m2-demo anchor/ .harness/$d/; tree .harness/$d; done
webmvc .harness/serve/tiffinbox-web/pom.xml || die "the copy's POM change"
webmvc .harness/kept/tiffinbox-web/pom.xml keep || die "the second copy's POM change"
mbuild "$(off .harness/serve "$R_PLAIN")" .harness/build-serve.log ".harness/serve (the copy: the README's plain build)"
mbuild "$(off .harness/kept "$R_PLAIN")" .harness/build-kept.log ".harness/kept (the copy, the last course's excludes kept)"
for d in serve kept; do (cd .harness/$d && eval "$R_EXTRACT") > .harness/extract-$d.log 2>&1 < /dev/null || { cat .harness/extract-$d.log >&3; die "the README's extract line failed in .harness/$d"; }
  [ -f .harness/$d/tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar ] || die "the extract line made no jar in .harness/$d"; done
(cd .harness/serve && eval "$J_JAVAC") > .harness/javac.log 2>&1 < /dev/null || { cat .harness/javac.log >&3; die "the harness did not compile"; }
[ "$(ls .harness/classes/probe/*.class | wc -l | tr -d ' ')" = 4 ] || die "the harness: four classes expected in .harness/classes/probe"
echo "  extracted .harness/serve and .harness/kept (the README's extract line) · compiled the harness's four classes into .harness/classes"

# ---- helpers ------------------------------------------------------------------------------------------------------------
raw() { local t=$1; shift; cat "$@" | LC_ALL=C grep -aoF -- "$t" | wc -l | tr -d ' '; }
LOGS=0
start() { echo "\$ $1"; (eval "$(exe "$1")") > .harness/run.out 2> .harness/run.err < /dev/null & pid=$!; }
# up TPORT SPORT: first the addresses the JVM listens on, read off its pid every 0.25 s (up to 60 s) until they are 127.0.0.1:TPORT
# and 127.0.0.1:SPORT - Tomcat binds last, once every bean exists; a wildcard address stops the run at once (bindok). No request is
# made before that: a request to TiffinBox's own server while the context is still creating beans makes Spring log lines of its
# own, as many as the requests that raced it (found on the way). Then readiness, polled on TiffinBox's own server (not printed)
# until it answers 200 - it never reaches the DispatcherServlet, so no request has reached Tomcat yet. A JVM that exits first
# stops the run.
up() { local i=0 c="" a=""
  while [ $i -lt 240 ]; do
    a=$(lsof -nP -a -p "$pid" -iTCP -sTCP:LISTEN 2> /dev/null | awk 'NR > 1 { print $9 }' | sort -u | paste -sd' ' -)
    bindok "$a" "$1" "$2" && break
    case " $a " in *' *:'*|*' 0.0.0.0:'*|*' [::]:'*) die "the JVM listens on '$a' - a wildcard address: only 127.0.0.1:$1 and 127.0.0.1:$2 are allowed" ;; esac
    kill -0 "$pid" 2> /dev/null || { tail -20 .harness/run.out >&3; die "it exited before it listened on both ports"; }
    sleep 0.25; i=$((i + 1)); done
  bindok "$a" "$1" "$2" || die "the JVM listens on '$a' - only 127.0.0.1:$1 and 127.0.0.1:$2 are allowed"
  i=0; while [ $i -lt 240 ]; do c=$(curl -s -o /dev/null -w '%{http_code}' "http://127.0.0.1:$1/actuator/health/readiness" 2> /dev/null || true); [ "$c" = 200 ] && break
    kill -0 "$pid" 2> /dev/null || { tail -20 .harness/run.out >&3; die "it exited before readiness answered 200"; }; sleep 0.25; i=$((i + 1)); done
  [ "$c" = 200 ] || die "readiness never answered 200 on $1"
  echo "  listens on (read off its pid): $a"; }
# who TPORT SPORT: which server is which - each one's own line in the run's log (a request below names its server by its port)
who() { echo "  $1 is $SAY_T - its line: $(grep -m1 -E ' tiffinbox +: TiffinBox listening on ' .harness/run.out | sed 's/^.* : //') · $2 is $SAY_S - its line: $(grep -m1 -E '[.]TomcatWebServer +: Tomcat started on port ' .harness/run.out | sed 's/^.* : //')"; }
ask() { local c; c=$(url "$1" "$2"); echo "\$ $c"; (eval "$c") 2>&1 < /dev/null | sed 's/^/  /'; }
# req PORT PATH: the request line (the README's /customers line, its port and path changed, the content type added), printed and run
req() { local c; c=$(url "$Q" "$1"); c=${c%/customers}$2; echo "\$ $c"; (eval "$c") 2>&1 < /dev/null | sed 's/^/  /'; }
logtok() { local t h; t=$(raw "$TOKEN" .harness/run.out .harness/run.err); h=$(cat .harness/run.out .harness/run.err | LC_ALL=C grep -aoi -- 'x-shutdown-token' | wc -l | tr -d ' ')
  LOGS=$((LOGS + 1)); [ "$t" = 0 ] && [ "$h" = 0 ] || die "a log held the demo token ($t) or its header's name ($h)"
  echo "  its log: the demo token 0 times · X-Shutdown-Token 0 times"; }
# down TPORT SPORT: the JVM stopped by its pid (TERM) - it must leave within 15 s; its exit code; both ports free; its log counted
down() { local i=0 e=0
  echo "\$ kill \$pid    # TERM, to the JVM this script started"
  kill "$pid" 2> /dev/null || true
  while kill -0 "$pid" 2> /dev/null && [ $i -lt 60 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$pid" 2> /dev/null && { kill -9 "$pid"; die "the JVM was still running 15 s after TERM"; }
  wait "$pid" || e=$?; pid=""
  [ "$(listeners "$1")" = 0 ] && [ "$(listeners "$2")" = 0 ] || die "something still listens on $1 or $2"
  echo "  exit $e · listening now: $1 $(listeners "$1") · $2 $(listeners "$2")"; logtok; }
# lines N: how many lines the run's log holds now
lines() { wc -l < .harness/run.out | tr -d ' '; }
# settle N 'RE': wait until the log, after its line N, holds a line matching RE - every 0.25 s, up to 15 s (a line is written just
# after the answer it belongs to has left)
settle() { local i=0; while [ $i -lt 60 ]; do tail -n +$(($1 + 1)) .harness/run.out | grep -qE -- "$2" && return 0; sleep 0.25; i=$((i + 1)); done; die "no log line /$2/ after line $1"; }
# logf FROM 'STOP' 'SELECT': the run's log read through a declared selection (python below): its entries from line FROM+1 on, up to
# the first whose "logger: message" matches STOP (or the end); each one SELECT matches is printed from its level on (time, process
# id and thread cut), a TRACE block's lines under it; every gap counted. TiffinBox's route lines (a run of them) and the mapping
# lines of each TRACE block are printed sorted: reflection hands methods back in no specified order.
LOGPY='
import re, sys
path, frm, stop, sel = sys.argv[1], int(sys.argv[2]), sys.argv[3], sys.argv[4]
H = re.compile(r"^\d{4}-\d\d-\d\dT\S+\s+(TRACE|DEBUG|INFO|WARN|ERROR)\s+\d+ --- \[[^\]]*\] (\S+)\s*: ?(.*)$")
L = open(path, errors="replace").read().split("\n")
if L and L[-1] == "": L.pop()
E = []
for i in range(frm, len(L)):
    m = H.match(L[i])
    if m: E.append([i, i, m.group(1), m.group(2), m.group(3).rstrip(), []])
    elif E: E[-1][1] = i; E[-1][5].append(L[i].strip())
    else: pass
end = len(L) - 1
for e in E:
    if stop and re.search(stop, e[3] + ": " + e[4]): end = e[1]; break
shown = [e for e in E if e[1] <= end and re.search(sel, e[3] + ": " + e[4])]
runs, cur = [], []
for e in shown:
    r = e[3] == "tiffinbox" and e[4].startswith("route ")
    if r and cur and cur[-1][0][1] + 1 == e[0]: cur.append((e, r)); continue
    if cur: runs.append(cur)
    cur = [(e, r)]
if cur: runs.append(cur)
out, prev = [], frm - 1
for run in runs:
    es = [e for e, _ in run]
    if all(r for _, r in run): es = sorted(es, key=lambda e: e[4])
    first, last = min(e[0] for e in es), max(e[1] for e in es)
    if first > prev + 1: out.append("  … %d line%s not shown …" % (first - prev - 1, "" if first - prev - 1 == 1 else "s"))
    for e in es:
        out.append("  %s %s:%s" % (e[2], e[3], (" " + e[4]) if e[4] else ""))
        c = [x for x in e[5] if x]
        if c: out += ["      " + x for x in c[:1] + sorted(c[1:])]
    prev = last
if end > prev: out.append("  … %d line%s not shown …" % (end - prev, "" if end - prev == 1 else "s"))
if out: print("\n".join(out))'
logf() { python3 -c "$LOGPY" .harness/run.out "$1" "$2" "$3"; }
# mask: the demo token becomes a label naming its length (read from the file the run served with); this folder's path "…", the
# folder above it "…/..", the home folder "~" (each also in its URL form, spaces as %20); the user name "<user>"; Spring's error
# timestamp, in either form; the milliseconds of the DispatcherServlet's "Completed initialization" line - in every line (gsub)
mask() { awk -v t="$TOKEN" -v n="$TLEN" -v u="$U" -v up="$UP" -v hm="$HOME" -v me="$ME" '
  function lit(x) { gsub(/[][\\.^$*+?(){}|\/]/, "\\\\&", x); return x }
  function enc(x) { gsub(/ /, "%20", x); return x }
  BEGIN { T = lit(t); P = lit(u); Q = lit(up); H = lit(hm); PE = lit(enc(u)); QE = lit(enc(up)); M = lit(me) }
  { gsub(T, "[masked: the " n "-character token]"); gsub(P, "…"); gsub(PE, "…"); gsub(Q, "…/.."); gsub(QE, "…/.."); gsub(H, "~"); gsub(M, "<user>")
    gsub(/"timestamp":"[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T[0-9][0-9]:[0-9][0-9]:[0-9][0-9][.0-9]*Z"/, "\"timestamp\":\"<a time, masked: ISO-8601>\"")
    gsub(/"timestamp":[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]*/, "\"timestamp\":<a time, masked: epoch milliseconds>")
    gsub(/Completed initialization in [0-9][0-9]* ms/, "Completed initialization in … ms"); print }'; }
# The masks, each shown working on a planted line first (a check that can fail): both timestamp forms, the milliseconds, the token
TLEN=26
[ "$(printf '%s\n' '{"timestamp":"2026-10-12T18:39:42.077Z","status":404}' | mask)" = '{"timestamp":"<a time, masked: ISO-8601>","status":404}' ] || die "the mask: Spring's ISO-8601 timestamp (planted)"
[ "$(printf '%s\n' '{"timestamp":1791830621275,"status":404}' | mask)" = '{"timestamp":<a time, masked: epoch milliseconds>,"status":404}' ] || die "the mask: Spring's epoch timestamp (planted)"
[ "$(printf '%s\n' 'Completed initialization in 12 ms' | mask)" = 'Completed initialization in … ms' ] || die "the mask: the milliseconds (planted)"
[ "$(printf 'x %s y\n' "$TOKEN" | mask)" = 'x [masked: the 26-character token] y' ] || die "the mask: the token (planted)"
TLEN=$(head -1 .harness/serve/$TF | tr -d '\n' | wc -c | tr -d ' ')
[ "$TLEN" = "${#TOKEN}" ] || die "the token served with is not the one this script wrote"
echo "  the checks, each failing on a planted value first: the bind check (a wildcard, one server of two) · the masks (both timestamp forms, the milliseconds, the token)"
unpub=""
cap() { local nm=$1 h pub i; shift
  for i in 1 2 3; do "$@" > .harness/cap.raw 2>&1 || true; [ -z "$pid" ] || die "$nm left a process running"
    raw "$TOKEN" .harness/cap.raw > ".harness/raw-$nm.$i"; mask < .harness/cap.raw > ".r-$nm.$i"; done
  h=$(md5 -q ".r-$nm.1")
  [ "$h" = "$(md5 -q ".r-$nm.2")" ] && [ "$h" = "$(md5 -q ".r-$nm.3")" ] || die "$nm drifts across three runs (diff .r-$nm.1 .r-$nm.2 .r-$nm.3)"
  mv ".r-$nm.1" ".r-$nm.out"; rm -f ".r-$nm.2" ".r-$nm.3"
  pub=$(awk -v n="$nm" '$1 == n { print $2 }' receipts.md5 2> /dev/null || true)
  if [ -z "$pub" ]; then printf '  %-11s md5 %s  3/3  (no published hash)\n' "$nm" "$h"; unpub="$unpub $nm"
  elif [ "$pub" = "$h" ]; then printf '  %-11s md5 %s  3/3  = published\n' "$nm" "$h"
  else printf '  %-11s md5 %s  3/3  DIFFERS from the published %s\n' "$nm" "$h" "$pub"
    die "$nm is not the published capture - suspect another JDK, Boot or Maven, a busy machine, a busy port, a variable of yours, or an edited source; diff .r-$nm.out against its block in README.md"; fi; }
WEB=tiffinbox-web/src/main/java/com/tiffinbox/web
SAY_T="TiffinBox's own server"; SAY_S="Tomcat, Spring MVC's server"
STARTUP='^tiffinbox: (route |routes mapped|TiffinBox listening)|RequestMappingHandlerMapping: ($|[0-9]+ mappings in )|TomcatWebServer: Tomcat started on port'

# ---- toy: the router you wrote, beside Spring MVC's, in one JVM ---------------------------------------------------------------
toy() { local i=0 a
  echo "the copy: the anchor's tree, Spring MVC's starter added to the web module's POM, the Boot plugin's two Jackson 3 excludes dropped:"
  echo "\$ diff -U0 anchor/tiffinbox-web/pom.xml .harness/serve/tiffinbox-web/pom.xml | tail -n +3"
  diff -U0 anchor/tiffinbox-web/pom.xml .harness/serve/tiffinbox-web/pom.xml | tail -n +3 | sed 's/^/  /' || true
  echo "  the copy's executable jar: $(unzip -l .harness/serve/tiffinbox-web/target/tiffinbox-web-1.0.0.jar | grep -cE 'BOOT-INF/lib/[^/]+\.jar$') jars in BOOT-INF/lib · spring-webmvc $(unzip -l .harness/serve/tiffinbox-web/target/tiffinbox-web-1.0.0.jar | grep -cE 'BOOT-INF/lib/spring-webmvc-[0-9.]+\.jar$') · tomcat-embed-core $(unzip -l .harness/serve/tiffinbox-web/target/tiffinbox-web-1.0.0.jar | grep -cE 'BOOT-INF/lib/tomcat-embed-core-[0-9.]+\.jar$')"
  echo "the router you wrote, in the copy's TiffinBoxServer.java - declare, scan into a TreeMap, invoke:"
  a="grep -nE '@Route\\(|getAnnotation\\(Route\\.class\\)|new TreeMap<String, Method>\\(\\)|routes\\.put\\(|handler\\.invoke\\(this\\)' $WEB/TiffinBoxServer.java"
  echo "\$ cd .harness/serve && $a"
  (cd .harness/serve && eval "$a") | sed -E 's/^([0-9]+):[[:space:]]+/  \1: /'
  echo "one JVM, two servers - the README's class-path line, the harness's folder added, Tomcat on 127.0.0.1 and a port of its own:"
  start "cd .harness/serve && $L_TOY"; up 19320 19321
  echo "  Boot's first line: $(grep -m1 ' : Starting ' .harness/run.out | sed 's/^.* : //; s/ with PID .*$//')"
  ask "$R_READY" 19320; ask "$R_READY" 19321
  echo "its log, from its first line to Tomcat's started line - TiffinBox's scan, its TreeMap, both servers' own lines:"
  logf 0 'TomcatWebServer: Tomcat started on port' "$STARTUP"
  echo "each server asked for its own route, and for the other's - 19320 is $SAY_T, 19321 $SAY_S:"
  a=$(lines); req 19320 /customers; settle "$a" ' tiffinbox +: GET /customers -> 200$'
  echo "  TiffinBox's line at DEBUG: $(tail -n +$((a + 1)) .harness/run.out | grep -E ' tiffinbox +: GET /customers -> ' | sed 's/^.* tiffinbox *: //')"
  req 19320 /probe/hello
  req 19321 /customers
  req 19321 /probe/hello
  echo "the seven, on $SAY_T (19320):"
  echo "\$ \$CURLSET 19320 .harness/serve/$TF"
  "$CURLSET" 19320 ".harness/serve/$TF" | grep ' -> ' > .harness/responses.txt || true
  sed 's/^/  /' .harness/responses.txt
  echo "  the seven responses: $(wc -l < .harness/responses.txt | tr -d ' ') lines · md5 $(md5 -q .harness/responses.txt)"
  while [ "$(listeners 19320)" != 0 ] && [ $i -lt 60 ]; do sleep 0.25; i=$((i + 1)); done
  [ "$(listeners 19320)" = 0 ] || die "TiffinBox's server still listened on 19320 15 s after POST /shutdown"
  a=$(lsof -nP -a -p "$pid" -iTCP -sTCP:LISTEN 2> /dev/null | awk 'NR > 1 { print $9 }' | sort -u | paste -sd' ' -)
  echo "after POST /shutdown: TiffinBox's server stopped - listening on 19320: 0 · the JVM: $(kill -0 "$pid" 2> /dev/null && echo alive || echo gone) · it listens on: ${a:-nothing}"
  ask "$R_READY" 19321
  a=$(lines); down 19320 19321
  echo "  its log, from TERM on: $(tail -n +$((a + 1)) .harness/run.out | grep -E 'GracefulShutdown' | sed 's/^.* : //' | paste -sd'|' - | sed 's/|/ · /g')"; }

# ---- lists: the strategies, read off the running servlet ----------------------------------------------------------------------
lists() {
  start "cd .harness/serve && $L_LISTS"; up 19322 19323; who 19322 19323
  echo "  before any request reached Tomcat - the harness, at ready: $(grep -m1 -E ' probe +: harness, at ready: ' .harness/run.out | sed 's/^.* : harness, at ready: //')"
  ask "$R_READY" 19323
  echo "after that one request, the servlet's lists - the harness's Strategies (handler mappings by the servlet's getter, the rest by reflection), each beside the context's own beans of that type:"
  req 19323 /probe/strategies
  down 19322 19323; }

# ---- scan: declare, scan, register, invoke - side by side ------------------------------------------------------------------------
scan() { local a
  echo "the harness's route, its whole code - its comment lines ($(grep -cE '^[[:space:]]*(/\*\*|\*|\*/)' harness/probe/Hello.java)) and blank lines ($(grep -cE '^[[:space:]]*$' harness/probe/Hello.java)) not shown:"
  echo "\$ grep -nvE '^[[:space:]]*(/\*\*|\*|\*/|\$)' harness/probe/Hello.java"
  grep -nvE '^[[:space:]]*(/\*\*|\*|\*/|$)' harness/probe/Hello.java | sed -E 's/^([0-9]+):/  \1: /'
  start "cd .harness/serve && $L_SCAN"; up 19324 19325
  echo "its log, from its first line to Tomcat's started line - TiffinBox's scan at DEBUG, Spring MVC's at TRACE:"
  logf 0 'TomcatWebServer: Tomcat started on port' "$STARTUP"
  ask "$R_READY" 19325
  echo "one request - the frames above the harness's frames(), on its own thread, reflection's shown:"
  a=$(lines); req 19325 /probe/frames; settle "$a" 'Mapped to probe\.Frames#frames\(\)'
  echo "  its line at TRACE: $(tail -n +$((a + 1)) .harness/run.out | grep -E 'Mapped to probe\.Frames#' | sed 's/^.* : //')"
  echo "a pattern, not a key - $SAY_S (19325):"
  req 19325 /probe/hello; req 19325 /probe/helloXYZ; req 19325 /probe/hello/
  echo "and $SAY_T (19324) - three letters more:"
  req 19324 /customersXYZ
  down 19324 19325; }

# ---- converters: what writes a JSON answer -----------------------------------------------------------------------------------
cone() { local a
  start "cd $1 && $L_CONV"; up 19326 19327; who 19326 19327
  ask "$R_READY" 19327
  req 19327 /probe/converters
  echo "  Jackson in this copy's extracted lib/: $(ls $1/tiffinbox-web/target/extracted/lib | grep -E '^jackson-databind-' | paste -sd' ' -)"
  [ "$2" = one ] || return 0
  echo "one request, and the lines it added at DEBUG and TRACE:"
  a=$(lines); req 19327 /probe/hello; settle "$a" 'DispatcherServlet +: Completed 200'
  logf "$a" '' '.'; }
converters() {
  echo "A - the copy:"
  cone .harness/serve one; down 19326 19327
  echo "C (labelled) - a second copy, the last course's two Jackson 3 excludes kept (only the starter added):"
  echo "\$ diff -U0 anchor/tiffinbox-web/pom.xml .harness/kept/tiffinbox-web/pom.xml | tail -n +3"
  diff -U0 anchor/tiffinbox-web/pom.xml .harness/kept/tiffinbox-web/pom.xml | tail -n +3 | sed 's/^/  /' || true
  cone .harness/kept; down 19326 19327
  echo "A' - A again:"
  cone .harness/serve one; down 19326 19327; }

# ---- init: when the servlet reads its lists ----------------------------------------------------------------------------------
INITSEL='Initializing Spring DispatcherServlet|DispatcherServlet: (Initializing Servlet|Completed initialization)|TomcatWebServer: Tomcat started on port|probe: harness, at ready'
ione() { local a
  start "cd .harness/serve && $1"; up 19328 19329; who 19328 19329
  echo "  before any request reached Tomcat - its log's lines about the DispatcherServlet's start, Tomcat's start and the harness at ready:"
  logf 0 '' "$INITSEL"
  echo "  the first request to Tomcat - the README's readiness line:"
  a=$(lines); ask "$R_READY" 19329
  echo "  the lines it added about the DispatcherServlet's start: $(tail -n +$((a + 1)) .harness/run.out | grep -cE 'Initializing Spring DispatcherServlet|DispatcherServlet +: (Initializing Servlet|Completed initialization)' || true)"
  logf "$a" '' "$INITSEL"
  down 19328 19329; }
init() { local j
  j=.harness/serve/tiffinbox-web/target/extracted/lib/spring-boot-webmvc-4.1.1.jar
  echo "Boot's own default, from its metadata (spring-boot-webmvc-4.1.1.jar, META-INF/spring-configuration-metadata.json):"
  unzip -p "$j" META-INF/spring-configuration-metadata.json | python3 -c '
import json, sys
p = [x for x in json.load(sys.stdin)["properties"] if x["name"] == "spring.mvc.servlet.load-on-startup"][0]
print("  %s · %s · default %s · %s" % (p["name"], p["type"], p.get("defaultValue"), p.get("description")))'
  echo "A - the default:"; ione "$L_INITA"
  echo "B - --spring.mvc.servlet.load-on-startup=1:"; ione "$L_INITB"
  echo "A' - A again:"; ione "$L_INITA"; }

# ---- exercise: the README's commands, exactly as written, then the solution's ---------------------------------------------
block() { awk '/^```bash$/ { if (!d) { f = 1 }; next } f && /^```$/ { f = 0; d = 1 } f' "$1"; }
exercise() { local setup sol ec=0
  setup=$(block exercise/README.md); sol=$(block exercise/solution/SOLUTION.md)
  [ -n "$setup" ] && [ -n "$sol" ] || die "exercise/README.md or SOLUTION.md no longer gives its commands"
  [ "$(printf '%s\n' "$sol" | grep -c .)" = 1 ] || die "SOLUTION.md's first bash block must be its one line"
  echo "exercise/README.md's commands, run exactly as written from this folder - $(printf '%s\n' "$setup" | grep -c .) lines:"
  printf '%s\n' "$setup" | sed 's/^/  $ /'
  (eval "$setup") > .harness/ex-setup.out 2>&1 < /dev/null || ec=$?
  sed 's/^/  /' .harness/ex-setup.out
  echo "  exit $ec · listening now: 19320 $(listeners 19320) · 19321 $(listeners 19321) · its log's lines saying Tomcat started: $(grep -c 'Tomcat started on port' .harness/mine.log || true) · the demo token in its log: $(raw "$TOKEN" .harness/mine.log)"
  [ $ec = 0 ] || die "the exercise's commands failed"
  echo "the solution's line (exercise/solution/SOLUTION.md), run exactly as written, from this folder:"
  echo "\$ $sol"
  ec=0; (eval "$sol") > .harness/ex-sol.out 2>&1 < /dev/null || ec=$?
  sed 's/^/  /' .harness/ex-sol.out
  echo "  exit $ec · listening now: 19320 $(listeners 19320) · 19321 $(listeners 19321) · the demo token in its log: $(raw "$TOKEN" .harness/mine.log)"; }

cap toy toy
cap lists lists
cap scan scan
cap converters converters
cap init init
cap exercise exercise

echo
# ---- every number the video says, asserted. Each check reads a line a program computed - never a label this script prints
# ---- unconditionally - and names the words it pays for.
x() { grep -qE -- "$2" ".r-$1.out" || die "$1: expected /$2/"; }
n() { grep -cE -- "$2" ".r-$1.out" || true; }
blk() { awk -v a="$2" -v b="$3" 'index($0, a) == 1 { f = 1; next } b != "" && index($0, b) == 1 { f = 0 } f' ".r-$1.out"; }
has() { printf '%s\n' "$1" | grep -qxF -- "$2" || die "$3: expected the line: $2"; }
# sub 'TEXT' A B: the lines of TEXT after the one starting A, up to the one starting B · at_ 'TEXT' LINE: where LINE first is (its number)
sub() { printf '%s\n' "$1" | awk -v a="$2" -v b="$3" 'index($0, a) == 1 { f = 1; next } b != "" && index($0, b) == 1 { f = 0 } f'; }
at_() { printf '%s\n' "$1" | grep -nF -- "$2" | head -1 | cut -d: -f1; }
S115='115c36bac276128e245ca57df11c2891'
READY='  {"status":"UP"} 200'
LOGOK="  its log: the demo token 0 times · X-Shutdown-Token 0 times"
# THE TOKEN: no capture holds it, raw - counted on each run's own output BEFORE masking - and neither does any log (counted when it
# was read: logtok(), the exercise's), nor anything this unit ships for reading
for f in .harness/raw-*; do [ "$(cat "$f")" = 0 ] || die "a capture's raw output held the demo token ($f)"; done
for f in .r-*.out README.md exercise/README.md exercise/solution/SOLUTION.md receipts.md5 harness/probe/*.java; do
  [ -f "$f" ] || continue; [ "$(raw "$TOKEN" "$f")" = 0 ] || die "$f holds the demo token, raw"; done
for f in .r-*.out; do ! grep -qE '/Users/|/private/|/home/|/var/folders/' "$f" || die "$f holds an absolute path"; ! grep -qE 'c[0-9]-unit[0-9]|unit ?[0-9]' "$f" || die "$f holds a unit number"; ! grep -qE ' (with PID|started by) ' "$f" || die "$f holds Boot's process line"; ! grep -qE '^ *[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T|exec-[0-9]|virtual-[0-9]|tomcat-handler-[0-9]' "$f" || die "$f holds a log line's time or a thread's number"; ! grep -q "^$(printf '\t')at " "$f" || die "$f shows a stack trace"; ! grep -qE '"timestamp":"?[0-9]' "$f" || die "$f holds an unmasked timestamp"; ! grep -qE '\*:[0-9]+|0\.0\.0\.0:|\[::\]:' "$f" || die "$f shows a wildcard address"; done
for f in receipts.sh README.md exercise/README.md exercise/solution/SOLUTION.md; do ! grep -E 'exposure\.include=.?\*' "$f" > /dev/null || die "$f exposes every endpoint"; done
NL=$(cat .r-*.out | grep -cxF "$LOGOK" || true)
echo "  token: 0 raw copies in $(ls .harness/raw-* | wc -l | tr -d ' ') raw capture runs, in $(ls .r-*.out | wc -l | tr -d ' ') captures, in the logs of every JVM that served ($LOGS here; the published captures' $NL), the exercise's logs, the READMEs, the harness and receipts.md5; no absolute path, no unit number, no process line, no log time, no thread number, no stack trace, no unmasked timestamp, no wildcard address in any capture"

# "The copy: one starter added, two excludes dropped. Your router: an annotation, a scan into a TreeMap, Method.invoke. One JVM, two
# servers, both on loopback. Each knows only its own routes. The seven, unchanged. After POST /shutdown, TiffinBox's server stops and
# the JVM lives on."
x toy '^  \+    <dependency><groupId>org\.springframework\.boot</groupId><artifactId>spring-boot-starter-webmvc</artifactId></dependency>$'
[ "$(n toy '^  -              <groupId>tools\.jackson\.core</groupId>$')" = 2 ] || die "toy: the two Jackson 3 excludes dropped"
x toy '^  the copy.s executable jar: 58 jars in BOOT-INF/lib · spring-webmvc 1 · tomcat-embed-core 1$'
[ "$(n toy '^  [0-9]+: +@Route\(path = "/')" = 5 ] || die "toy: five @Route lines"
x toy '^  [0-9]+: +Route r = m\.getAnnotation\(Route\.class\);$'; x toy '^  [0-9]+: +var routes = new TreeMap<String, Method>\(\);$'
x toy '^  [0-9]+: +routes\.put\(r\.method\(\) \+ " " \+ r\.path\(\), m\);$'; x toy '^  [0-9]+: +respond\(exchange, 200, handler\.invoke\(this\)\);$'
x toy '^  listens on \(read off its pid\): 127\.0\.0\.1:19320 127\.0\.0\.1:19321$'
T1=$(blk toy 'its log, from its first line' 'each server asked')
[ "$(printf '%s\n' "$T1" | grep -cE '^  DEBUG tiffinbox: route (GET|POST) /[a-z]+ -> [a-z]+\(\)$')" = 5 ] || die "toy: five route lines at DEBUG"
has "$T1" "  DEBUG tiffinbox: route GET /customers -> customers()" "toy: the scan's line"
has "$T1" "  INFO tiffinbox: routes mapped:  [GET /customers, GET /dashboard, GET /kitchen, GET /revenue, POST /shutdown]" "toy: the TreeMap's keys"
has "$T1" "  INFO tiffinbox: TiffinBox listening on http://127.0.0.1:19320" "toy: TiffinBox's own line"
has "$T1" "  INFO o.s.boot.tomcat.TomcatWebServer: Tomcat started on port 19321 (http) with context path '/'" "toy: Tomcat's own line"
T2=$(blk toy 'each server asked' 'the seven, on')
has "$T2" '  [{"name":"Meera","mealsPerDay":1,"pricePerMeal":150,"mealType":"NON_VEG"},{"name":"Priya","mealsPerDay":1,"pricePerMeal":120,"mealType":"VEGAN"},{"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"},{"name":"Sunil","mealsPerDay":3,"pricePerMeal":100,"mealType":"VEG"}] 200 application/json' "toy: TiffinBox's /customers"
has "$T2" "  TiffinBox's line at DEBUG: GET /customers -> 200" "toy: its DEBUG line"
has "$T2" '  <h1>404 Not Found</h1>No context found for request 404 text/html' "toy: the harness's route on TiffinBox's server"
has "$T2" '  {"timestamp":"<a time, masked: ISO-8601>","status":404,"error":"Not Found","path":"/customers"} 404 application/json' "toy: /customers on Tomcat"
has "$T2" '  {"hello":"from a harness method"} 200 application/json' "toy: the harness's route on Tomcat"
x toy "^  the seven responses: 7 lines · md5 $S115\$"
x toy '^after POST /shutdown: TiffinBox.s server stopped - listening on 19320: 0 · the JVM: alive · it listens on: 127\.0\.0\.1:19321$'
[ "$(n toy "^$READY\$")" = 3 ] || die "toy: readiness 200 on both, and on Tomcat after POST /shutdown"
x toy '^  exit 143 · listening now: 19320 0 · 19321 0$'
x toy '^  its log, from TERM on: Commencing graceful shutdown\. Waiting for active requests to complete · Graceful shutdown complete$'
echo "  toy: +1 starter, -2 excludes, 58 jars; @Route x5, getAnnotation, TreeMap, routes.put, handler.invoke; 127.0.0.1:19320 + :19321; 5 route lines, routes mapped; each server 404s the other's route; 115c36ba...; JVM alive on 19321 after POST /shutdown; TERM exit 143"

# "Nine handler mappings, Actuator's three first. Four adapters. Two exception resolvers. Four view resolvers. Each list the context's
# own beans of that kind, the same objects. Before any request: null."
x lists "^  19322 is TiffinBox's own server - its line: TiffinBox listening on http://127\\.0\\.0\\.1:19322 · 19323 is Tomcat, Spring MVC's server - its line: Tomcat started on port 19323 \\(http\\) with context path '/'\$"
x lists '^  before any request reached Tomcat - the harness, at ready: the DispatcherServlet.s handler mappings: null$'
x lists "^  handler mappings: 9 · the context's beans of that type: 9 · the same objects: yes\$"
x lists "^  handler adapters: 4 · the context's beans of that type: 4 · the same objects: yes\$"
x lists "^  exception resolvers: 2 · the context's beans of that type: 2 · the same objects: yes\$"
x lists "^  view resolvers: 4 · the context's beans of that type: 4 · the same objects: yes\$"
x lists '^  1 AdditionalHealthEndpointPathsWebMvcHandlerMapping \(order -100\) · org\.springframework\.boot\.webmvc\.actuate\.endpoint\.web$'
x lists '^  2 WebMvcEndpointHandlerMapping \(order -100\) · org\.springframework\.boot\.webmvc\.actuate\.endpoint\.web$'
x lists '^  3 ControllerEndpointHandlerMapping \(order -100\) · org\.springframework\.boot\.webmvc\.actuate\.endpoint\.web$'
[ "$(n lists '^  [4-9] [A-Za-z]+ \(order -?[0-9]+\) · org\.springframework\.[a-z.]+$')" = 6 ] && [ "$(n lists '^  [4-9] .*\.actuate\.')" = 0 ] || die "lists: six more handler mappings, none of them Actuator's"
x lists '^  5 RequestMappingHandlerMapping \(order 0\) · org\.springframework\.web\.servlet\.mvc\.method\.annotation$'
x lists '^  3 HttpRequestHandlerAdapter$'; x lists '^  1 RequestMappingHandlerAdapter$'
x lists '^  multipartResolver: StandardServletMultipartResolver$'; x lists '^  localeResolver: AcceptHeaderLocaleResolver$'
x lists '^  viewNameTranslator: DefaultRequestToViewNameTranslator$'; x lists '^  flashMapManager: SessionFlashMapManager$'
x lists '^  exit 143 · listening now: 19322 0 · 19323 0$'
echo "  lists: at ready null; 9 mappings (Actuator's 3 first), 4 adapters, 2 exception resolvers, 4 view resolvers - each = the context's beans of its type, the same objects; the four single strategies"

# "TiffinBox's scan, then Spring's: the TRACE line for the harness method, then the count, then Tomcat. The frames: the same
# Method.invoke under both. Three letters more, or a slash: 404. TiffinBox's server: 200."
S1=$(blk scan 'its log, from its first line' 'one request')
has "$S1" "      {GET [/probe/hello]}: hello()" "scan: the registration line"
has "$S1" "      p.Hello:" "scan: the class line"
has "$S1" "  DEBUG s.w.s.m.m.a.RequestMappingHandlerMapping: 4 mappings in 'requestMappingHandlerMapping'" "scan: the count"
a1=$(at_ "$S1" 'DEBUG tiffinbox: route GET /customers'); a2=$(at_ "$S1" 'TiffinBox listening on'); a3=$(at_ "$S1" '{GET [/probe/hello]}: hello()'); a4=$(at_ "$S1" "mappings in 'requestMappingHandlerMapping'"); a5=$(at_ "$S1" 'Tomcat started on port')
[ -n "$a1" ] && [ -n "$a5" ] && [ "$a1" -lt "$a2" ] && [ "$a2" -lt "$a3" ] && [ "$a3" -lt "$a4" ] && [ "$a4" -lt "$a5" ] || die "scan: TiffinBox's scan and its listening line, then Spring's registration and its count, then Tomcat started ($a1 $a2 $a3 $a4 $a5)"
x scan '^  [0-9]+:     @GetMapping\("/probe/hello"\)$'; x scan '^  [0-9]+:         return Map\.of\("hello", "from a harness method"\);$'
HB=$(blk scan "\$ grep -nvE" "\$ cd .harness/serve")
[ "$(printf '%s\n' "$HB" | grep -c .)" = 11 ] && [ "$(printf '%s\n' "$HB" | grep -ciE 'register|put\(|add[A-Z]' || true)" = 0 ] || die "scan: the harness's eleven code lines, none of them registering anything"
x scan '^  1 probe\.Frames\.frames$'; x scan '^  2 jdk\.internal\.reflect\.DirectMethodHandleAccessor\.invoke$'; x scan '^  3 java\.lang\.reflect\.Method\.invoke$'
x scan '^  4 org\.springframework\.web\.method\.support\.InvocableHandlerMethod\.doInvoke$'
x scan '^  7 org\.springframework\.web\.servlet\.mvc\.method\.annotation\.RequestMappingHandlerAdapter\.invokeHandlerMethod$'
x scan '^  10 org\.springframework\.web\.servlet\.DispatcherServlet\.doDispatch$'; x scan '^  below it: 37 more frames · 47 in all$'
x scan '^  its line at TRACE: Mapped to probe\.Frames#frames\(\)$'
x scan '^  \{"timestamp":"<a time, masked: ISO-8601>","status":404,"error":"Not Found","path":"/probe/helloXYZ"\} 404 application/json$'
x scan '^  \{"timestamp":"<a time, masked: ISO-8601>","status":404,"error":"Not Found","path":"/probe/hello/"\} 404 application/json$'
[ "$(n scan '^  \[\{"name":"Meera".*\] 200 application/json$')" = 1 ] || die "scan: /customersXYZ answered by TiffinBox's server"
echo "  scan: 5 route lines; {GET [/probe/hello]}: hello(); 4 mappings; then Tomcat started; frames: Method.invoke at 3, doInvoke at 4, doDispatch at 10, 47 in all; helloXYZ and hello/ 404; /customersXYZ 200"

# "Six message converters here, the last Jackson 3's. One request: the converter picked application/json and wrote it; no view
# rendering. Keep the last course's two excludes, and the sixth is Jackson 2's."
CA=$(blk converters 'A - the copy' 'C (labelled)'); CC=$(blk converters 'C (labelled)' "A' - A again"); CA2=$(blk converters "A' - A again" '')
[ "$CA" = "$CA2" ] || die "converters: A' is not A"
has "$CA" "  message converters, the request mapping adapter's: 6" "converters A: six"
has "$CA" "  6 org.springframework.http.converter.json.JacksonJsonHttpMessageConverter" "converters A: the sixth"
has "$CA" "  Jackson in this copy's extracted lib/: jackson-databind-2.22.2.jar jackson-databind-3.1.5.jar" "converters A: both Jacksons"
has "$CA" '  {"hello":"from a harness method"} 200 application/json' "converters A: the answer"
has "$CA" "  DEBUG m.m.a.RequestResponseBodyMethodProcessor: Using 'application/json', given [*/*] and supported [application/json, application/*+json]" "converters A: the converter chosen"
has "$CA" "  DEBUG m.m.a.RequestResponseBodyMethodProcessor: Writing [{hello=from a harness method}]" "converters A: written"
has "$CA" "  TRACE o.s.web.servlet.DispatcherServlet: No view rendering, null ModelAndView returned." "converters A: no view"
has "$CA" "  DEBUG s.w.s.m.m.a.RequestMappingHandlerMapping: Mapped to probe.Hello#hello()" "converters A: the mapping"
has "$CC" "  message converters, the request mapping adapter's: 6" "converters C: six"
has "$CC" "  6 org.springframework.http.converter.json.MappingJackson2HttpMessageConverter" "converters C: Jackson 2's"
has "$CC" "  Jackson in this copy's extracted lib/: jackson-databind-2.22.2.jar" "converters C: Jackson 2 only"
[ "$(n converters '^  exit 143 · listening now: 19326 0 · 19327 0$')" = 3 ] || die "converters: the three JVMs stopped"
echo "  converters: 6, the last JacksonJsonHttpMessageConverter; Using 'application/json'; Writing; No view rendering; C: 6, the last MappingJackson2HttpMessageConverter"

# "Boot's default is minus one. A: nothing before the first request, then the lines with it. B: before Tomcat started. A again: the
# same as A."
x init '^  spring\.mvc\.servlet\.load-on-startup · java\.lang\.Integer · default -1 · Load on startup priority of the dispatcher servlet\.$'
IA=$(blk init 'A - the default' 'B - '); IB=$(blk init 'B - ' "A' - A again"); IA2=$(blk init "A' - A again" '')
[ "$(printf '%s\n' "$IA" | grep -v '^\$ ')" = "$(printf '%s\n' "$IA2" | grep -v '^\$ ')" ] && [ "$(printf '%s\n' "$IA" | grep '^\$ ')" = "$(printf '%s\n' "$IA2" | grep '^\$ ')" ] || die "init: A' is not A"
has "$IA" "  INFO probe: harness, at ready: the DispatcherServlet's handler mappings: null" "init A: null at ready"
has "$IA" "  the lines it added about the DispatcherServlet's start: 3" "init A: the lines with the first request"
[ "$(sub "$IA" '  before any request' '  the first request' | grep -c 'Initializing' || true)" = 0 ] || die "init A: no Initializing line before the first request"
has "$IB" "  INFO probe: harness, at ready: the DispatcherServlet's handler mappings: 9" "init B: 9 at ready"
has "$IB" "  the lines it added about the DispatcherServlet's start: 0" "init B: none with the first request"
IBB=$(sub "$IB" '  before any request' '  the first request'); i1=$(at_ "$IBB" "Initializing Servlet 'dispatcherServlet'"); i2=$(at_ "$IBB" 'Tomcat started on port')
[ -n "$i1" ] && [ -n "$i2" ] && [ "$i1" -lt "$i2" ] || die "init B: the servlet's init before Tomcat started, before any request"
echo "  init: default -1; A null at ready, 3 lines with the first request; B the init before Tomcat started, 9 at ready, 0 with the first request; A' = A"

# the exercise's end state: the line exercise/README.md calls "Done" is a line of this capture, after the solution's line - and of
# SOLUTION.md's measured run
XE=$(blk exercise "the solution's line" '')
l='{GET [/probe/hello]}: hello()'
has "$XE" "  $l" "exercise"
awk '/^\*\*Done\*\*/ { f = 1 } f' exercise/README.md | grep -qxF -- "$l" || die "exercise/README.md: Done names no such line"
grep -qxF -- "$l" exercise/solution/SOLUTION.md || die "SOLUTION.md: the measured run shows no such line"
x exercise '^  lines that register a route: 0$'
[ "$(n exercise '^  exit 0 · listening now: 19320 0 · 19321 0')" = 2 ] || die "exercise: both runs exit 0, nothing left listening"
echo "  exercise: the README as written -> 0 registration lines (the adapter's logger); the solution -> {GET [/probe/hello]}: hello()"
[ -z "$(diff -rq -x target -x secrets -x .m2-demo -x .harness -x README.md anchor ../c6-tiffinbox 2>&1)" ] || echo "  (the anchor has moved past this tree: this unit's captures are of ../c5-unit27/after, the last course's final tree)" >&3
[ -z "$unpub" ] || die "no published hash for:$unpub - check the captures, then copy the md5s above into receipts.md5 and run again"
echo "c6-unit03: every capture 3/3 and = published; every spoken number asserted; 0 raw demo tokens in every capture and every log; nothing of this run left listening"
