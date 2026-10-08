#!/bin/bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25.0.4.1 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# Course 5 · What's Next: The Web Layer - this unit's receipts, the course's last. TiffinBox has answered HTTP since Core Java II,
# through a server of its own. What exactly does that server do, measured on today's tree - and which of its files do the web's
# jobs? No anchor change: the tree is ../c5-unit27/after, reached through the link `anchor`, read and copied under .harness/, never
# built in place. No native build, no Docker, no GraalVM. Three captures, each run three times and hashed; cap() DIES when a hash
# differs from receipts.md5; every number the video says is asserted at the bottom by a check that can fail; the demo token is
# masked (gsub), and the checks count 0 raw copies of it in every capture, in the log of every run, and in every file this unit
# ships.
#   seam    the README's DEBUG line on 19160: A GET /customers · B GET /customersXYZ (three letters more) · A' = A · C (labelled)
#           GET /nowhere - each with its answer, the lines it added at DEBUG and the timer series it moved; then the rest of the
#           server's jobs (a trailing slash, a longer path, a wrong verb, Accept: application/xml, /actuator, /actuator/mappings
#           unexposed), the timer's series, the seven with the lines they added, the threads; then D (labelled): the README's run
#           line with mappings exposed by flag for one run (19161) - Boot's routing table, read
#   pieces  the web module's files, each with its lines and the three things a grep can tell about it (it imports the JDK's HTTP
#           server; it is the annotation the router reads; it explains the failed bind of the server's start); the core's files
#   readme  the repository's own README: the roadmap line as the last commit before this unit had it, and as it is now
# The course's counts (30 lessons, 5 sections, 19 courses, the next one) and the next course's lesson titles are NOT captured here:
# their sources (TRACK-ROADMAP.md, java5_series.py) are not in this repository. The deck's builder reads them on the day (Course 4's
# finale's method) and README.md says so.
# $CURLSET = ../c5-unit11/curlset.sh (the seven requests, POST /shutdown with the token's header read from the file). $M2 = this
# unit's own repository, .m2-demo. The harness is harness/shutdown.sh alone; no harness passes a bare word to the guarded tree
# (brief ⚑18): every run here passes options only.
# The network: every build runs offline (-o) against .m2-demo and says so ("offline: yes"); a build that cannot resolve an artifact
# offline goes to Maven Central once, and says that ("offline: no - ..."). At run time nothing leaves 127.0.0.1.
# Masks and filters (README.md declares each; sub/gsub only): the demo token becomes "[masked: the 26-character token]"; this
# folder's absolute path "…", the folder above it "…/..", the home folder "~"; your user name "<user>" - in every line of every
# capture. A log line is printed from its message on (its time, process id and thread cut); a thread is said to be virtual or not.
# JSON from Actuator is printed with its keys sorted. No duration is captured.
# Ports (brief ⚑1, 19160-19169): seam's A-C 19160 · seam's D 19161. 18425 (TiffinBox's default) and 8080 (Tomcat's) are checked
# free too, and never bound.
set -e
# bash 5.2 and later turn an & in the replacement of ${x/pattern/replacement} into the matched text (patsub_replacement, on by
# default). Switched off, so /bin/bash 3.2 (./receipts.sh) and a newer bash (bash receipts.sh) run the same commands.
shopt -u patsub_replacement 2> /dev/null || true
cd "$(dirname "$0")"
mkdir .r-lock 2> /dev/null || { echo "  *** another receipts.sh is running in this folder (.r-lock exists) - if none is, rmdir .r-lock ***"; exit 1; }
# On every exit - the end, a failed check, or Ctrl-C - stop the server this script started in the background ($pid), if it still
# runs, then sweep(): anything of this run still alive in its process group - a TiffinBox JVM, a Maven build - is stopped. After an
# interrupt, a capture's unfinished runs (.r-NAME.1-3) go too; after a failed check they stay, for the diff the message names.
pid=""
sweep() { local g i l
  g=$(ps -o pgid= -p $$ 2> /dev/null | tr -d ' ') || g=""
  [ -n "$g" ] || return 0
  i=0; while [ $i -lt 20 ]; do
    l=$(ps -axo pid=,pgid=,command= 2> /dev/null | awk -v g="$g" -v me=$$ '
      $2 == g && $1 != me && $3 != "awk" && $3 != "ps" && (index($0, "tiffinbox-web-1.0.0.jar") || index($0, "com.tiffinbox.web.TiffinBoxServer") || index($0, "plexus-classworlds")) { print $1 }' | paste -sd' ' -) || l=""
    [ -n "$l" ] || return 0
    if [ $i -lt 10 ]; then kill $l 2> /dev/null || true; else kill -9 $l 2> /dev/null || true; fi
    sleep 0.5; i=$((i + 1)); done; }
trap 'trap "" INT TERM; if [ -n "$pid" ] && kill "$pid" 2> /dev/null; then wait "$pid" 2> /dev/null || true; fi; sweep || true; [ -z "$INTR" ] || rm -f .r-*.[123]; rmdir .r-lock 2> /dev/null || true' EXIT
INTR=""; trap 'INTR=1; exit 130' INT TERM
exec 3>&1                                            # die() speaks to the terminal even inside a redirected capture
die() { echo "  *** $* ***" >&3; exit 1; }
java -version 2>&1 | grep -q 'version "25' || die "JDK 25 needed; JAVA_HOME gives: $(java -version 2>&1 | head -1)"
for t in python3 curl rsync lsof md5 git; do command -v $t > /dev/null || die "$t is needed here"; done
# A variable of yours must not become a property source, a JVM flag or a build setting: every TIFFINBOX_*, SPRING_*, MANAGEMENT_*,
# SERVER_* and LOGGING_* variable, DEBUG (Boot reads it as --debug), the variables that inject JVM flags, MAVEN_OPTS, MAVEN_ARGS and
# NATIVE_IMAGE_OPTIONS are removed first (the failure lesson's loop, verbatim: sed -E, a canary planted under every name first, and
# the run stops if one survives - RED C5-S4 #63). This unit runs no Docker, so COMPOSE_* is not in the list (brief S5.15).
for v in TIFFINBOX_CANARY SPRING_CANARY MANAGEMENT_CANARY SERVER_CANARY LOGGING_CANARY DEBUG JAVA_TOOL_OPTIONS JDK_JAVA_OPTIONS _JAVA_OPTIONS MAVEN_OPTS MAVEN_ARGS NATIVE_IMAGE_OPTIONS; do export "$v=planted-canary"; done
for v in $(env | sed -n -E 's/^(TIFFINBOX_[A-Za-z0-9_]*|SPRING_[A-Za-z0-9_]*|MANAGEMENT_[A-Za-z0-9_]*|SERVER_[A-Za-z0-9_]*|LOGGING_[A-Za-z0-9_]*|DEBUG|JAVA_TOOL_OPTIONS|JDK_JAVA_OPTIONS|_JAVA_OPTIONS|MAVEN_OPTS|MAVEN_ARGS|NATIVE_IMAGE_OPTIONS)=.*/\1/p'); do unset "$v"; done
[ -z "$(env | grep -- '=planted-canary$')" ] || die "a variable survived the clean-up above: $(env | grep -- '=planted-canary$' | sed 's/=.*//' | paste -sd' ' -)"
# Every request this script makes goes to 127.0.0.1: 127.0.0.1 and localhost go first in no_proxy and NO_PROXY.
export no_proxy="127.0.0.1,localhost${no_proxy:+,$no_proxy}" NO_PROXY="127.0.0.1,localhost${NO_PROXY:+,$NO_PROXY}"
[ -e secrets ] && die "this folder holds a secrets/ - remove it: every run here starts in a folder under .harness/"
[ -L anchor ] && [ "$(readlink anchor)" = ../c5-unit27/after ] || die "anchor must be the link to ../c5-unit27/after - this unit changes nothing in the anchor"
[ -e anchor/secrets ] || [ -e anchor/tiffinbox-web/secrets ] || [ -e anchor/tiffinbox-local.yaml ] || [ -e anchor/target ] || [ -e anchor/tiffinbox-web/target ] || [ -e anchor/banner.txt ] && die "anchor/ (../c5-unit27/after) holds a secrets/, a tiffinbox-local.yaml, a banner.txt or a target/ - it is the anchor's frozen copy, never built in place; remove them"
M2="$PWD/.m2-demo"; U="$PWD"; UP="$(cd .. && pwd)"; ME="$(id -un)"
TF=secrets/tiffinbox/shutdown-token                  # the config tree's file for tiffinbox.shutdown-token
TOKEN=not-a-real-token-demo-only                     # FAKE, and meant to look it: written into .harness/*/secrets/, never printed
[ ${#TOKEN} = 26 ] || die "the demo token must be 26 characters"
CURLSET=../c5-unit11/curlset.sh
[ -f "$CURLSET" ] || die "$CURLSET is missing"
[ -f anchor/pom.xml ] && [ -f anchor/README.md ] || die "anchor/ (../c5-unit27/after) is missing"
[ -f harness/shutdown.sh ] && [ -f ../README.md ] || die "missing: harness/shutdown.sh or ../README.md"
git -C .. rev-parse --verify -q 53379bd^{commit} > /dev/null || die "the repository's history must hold 53379bd (the last commit before this unit): a full clone, not a shallow one"

listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
for p in 18425 8080 19160 19161 19162 19163 19164 19165 19166 19167 19168 19169; do
  [ "$(listeners $p)" = 0 ] || die "something already listens on $p - this unit's ports must be free; if it is a TiffinBox an interrupted run left behind, stop it: kill $(lsof -nP -iTCP:$p -sTCP:LISTEN -t 2> /dev/null | paste -sd' ' -)"; done

# ---- the commands: read from anchor/README.md, the anchor's own, and asserted - each line must be there, whole -------------
readme() { grep -m1 -xF -- "$1" anchor/README.md > /dev/null || die "anchor/README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
R_PLAIN=$(readme 'mvn -B package')
R_RUN=$(readme 'java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431')
R_DEBUG=$(readme 'java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --logging.level.kitchen=debug')
R_EXPO=$(readme 'java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --management.endpoints.web.exposure.include=health,env')
R_READY=$(readme "curl -s -w ' %{http_code}\n' http://127.0.0.1:18431/actuator/health/readiness")
R_GET=$(readme "curl -s -w ' %{http_code}\n' http://127.0.0.1:18431/customers")
# The mappings run: the README's exposure line with mappings for env (D). A request: the README's /customers line, its path made
# PATH, the content type added after the status - this unit's one change to it, asserted below.
R_MAP=${R_EXPO/include=health,env/include=health,mappings}
[ "$R_MAP" = "$R_RUN --management.endpoints.web.exposure.include=health,mappings" ] || die "the mappings run: the README's run line and one flag"
Q=${R_GET/\\n\'/ %\{content_type\}\\n\'}
[ "$Q" = "curl -s -w ' %{http_code} %{content_type}\n' http://127.0.0.1:18431/customers" ] || die "the request line: the README's, the content type added"
# off DIR 'README mvn LINE': the README's Maven line as this script runs it - from DIR, offline (-o), this unit's own repository,
# clean and without tests. dev() takes those things back out, and must give the README's line again.
off() { local c=${2/mvn -B /mvn -o -B -Dmaven.repo.local=\"\$M2\" }; c=${c/ package/ -DskipTests clean package}; printf 'cd %s && %s\n' "$1" "$c"; }
dev() { local c=${1#cd * && }; c=${c/ -o -B -Dmaven.repo.local=\"\$M2\" / -B }; c=${c/ -DskipTests clean / }; printf '%s\n' "$c"; }
at() { printf 'cd %s && %s\n' "$1" "${3/--tiffinbox.port=18431/--tiffinbox.port=$2}"; }
url() { printf '%s\n' "${1/:18431\//:$2/}"; }
exe() { printf '%s\n' "$1" | sed -E 's/&& (([A-Z_]+=[^ ]* )*)/\&\& \1exec /'; }
[ "$(dev "$(off .harness/x "$R_PLAIN")")" = "$R_PLAIN" ] || die "not the README's build line with the offline changes"
echo "  the commands: anchor/README.md gives all 6 lines this script runs or derives from"

# ---- build: before the captures - the tree with a config tree, the README's plain build. On a fresh clone (.m2-demo empty: git
# ---- ignores it) this build fills .m2-demo, once.
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
rsync -a --exclude target --exclude secrets --exclude .m2-demo anchor/ .harness/serve/; tree .harness/serve
mbuild "$(off .harness/serve "$R_PLAIN")" .harness/build-serve.log ".harness/serve (the tree, the README's plain build)"
[ -f .harness/serve/tiffinbox-web/target/tiffinbox-web-1.0.0.jar ] || die "the README's build made no jar"

# ---- helpers ------------------------------------------------------------------------------------------------------------
raw() { local t=$1; shift; cat "$@" | LC_ALL=C grep -aoF -- "$t" | wc -l | tr -d ' '; }
LOGS=0
start() { echo "\$ $1"; (eval "$(exe "$1")") > .harness/run.out 2> .harness/run.err < /dev/null & pid=$!; }
listening() { local a="" i=0
  while [ $i -lt 240 ]; do
    a=$(lsof -nP -a -p "$pid" -iTCP -sTCP:LISTEN 2> /dev/null | awk 'NR > 1 { print $9 }' | sort -u | paste -sd' ' -)
    [ -n "$a" ] && break; kill -0 "$pid" 2> /dev/null || break; sleep 0.25; i=$((i + 1)); done
  echo "${a:-nothing}"; }
up() { local l; l=$(listening); [ "$l" != nothing ] || { tail -20 .harness/run.out >&3; die "it never listened"; }
  echo "  listens on: $l"; }
ask() { local c; c=$(url "$1" "$2"); echo "\$ $c"; (eval "$c") 2>&1 < /dev/null | sed 's/^/  /'; }
# ready PORT: readiness asked until it answers 200 - every 0.25 s, up to 60 s, not printed - then the README's readiness line,
# printed and run once (brief S5.28). The process is checked alive on every round, and the stop runs on every path (the trap).
ready() { local i=0 c=""
  while [ $i -lt 240 ]; do c=$(curl -s -o /dev/null -w '%{http_code}' "http://127.0.0.1:$1/actuator/health/readiness" 2> /dev/null || true); [ "$c" = 200 ] && break
    kill -0 "$pid" 2> /dev/null || { tail -20 .harness/run.out >&3; die "it exited before readiness answered 200"; }; sleep 0.25; i=$((i + 1)); done
  [ "$c" = 200 ] || die "readiness never answered 200 on $1"
  ask "$R_READY" "$1"; }
logtok() { local t h; t=$(raw "$TOKEN" .harness/run.out .harness/run.err); h=$(cat .harness/run.out .harness/run.err | LC_ALL=C grep -aoi -- 'x-shutdown-token' | wc -l | tr -d ' ')
  LOGS=$((LOGS + 1)); [ "$t" = 0 ] && [ "$h" = 0 ] || die "a log held the demo token ($t) or its header's name ($h)"
  echo "  its log: the demo token 0 times · X-Shutdown-Token 0 times"; }
# seven PORT DIR: the comparison set's seven requests, every response line printed; the process must leave within 15 s, the port
# must be free; then its log counted (logtok)
seven() { local i e=0
  echo "\$ \$CURLSET $1 $2/$TF"
  "$CURLSET" "$1" "$2/$TF" | grep ' -> ' > .harness/responses.txt || true
  sed 's/^/  /' .harness/responses.txt
  i=0; while kill -0 "$pid" 2> /dev/null && [ $i -lt 60 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$pid" 2> /dev/null && { kill "$pid"; die "the server on $1 was still running 15 s after POST /shutdown"; }
  wait "$pid" || e=$?; pid=""
  [ "$(listeners "$1")" = 0 ] || die "something still listens on $1"
  echo "  exit $e · the seven responses: $(wc -l < .harness/responses.txt | tr -d ' ') lines · md5 $(md5 -q .harness/responses.txt)"
  logtok; }
# TiffinBox's answer lines at DEBUG (logger "tiffinbox", "ROUTE -> STATUS") - counted, and printed from their message on, each
# with what its thread is: TiffinBox names no thread; the JDK's virtual threads are named "virtual-N" in Boot's log (N cut)
ANS='^[0-9-]+T[^ ]+ +DEBUG [0-9]+ --- \[[^]]*\] tiffinbox +: [A-Z]+ [^ ]+ -> [0-9]+$|^[0-9-]+T[^ ]+ +DEBUG [0-9]+ --- \[[^]]*\] tiffinbox +: UNKNOWN -> [0-9]+$'
dcount() { grep -cE "$ANS" .harness/run.out || true; }
dlines() { grep -E "$ANS" .harness/run.out | awk -v from="$1" 'NR > from { t = ($0 ~ /\[ *virtual-[0-9]+\]/) ? "a virtual thread" : "another thread"; s = $0; sub(/^.* tiffinbox +: /, "", s); print "    " s "    (on " t ")" }'; }
# the timer: its _count lines from a scrape (/actuator/prometheus, through the bridge: a scrape is neither logged nor timed)
series() { curl -s "http://127.0.0.1:$1/actuator/prometheus" | grep '^tiffinbox_requests_seconds_count{' | sort; }
total() { series "$1" | awk '{ s += $NF } END { print s + 0 }'; }
# settle PORT: wait until every answer TiffinBox timed has its line at DEBUG and nothing moves for half a second (its line is
# written, and its timer stopped, just after the answer leaves) - every 0.5 s, up to 20 s
settle() { local i=0 a b p=""
  while [ $i -lt 40 ]; do a=$(total "$1"); b=$(dcount); [ "$a" = "$b" ] && [ "$a" = "$p" ] && return 0; p=$a; sleep 0.5; i=$((i + 1)); done
  die "the timer ($a) and the lines at DEBUG ($b) never settled on $1"; }
# req PORT PATH ['CURL OPTIONS'] [SAVE|SAME]: the request line (the README's, its path made PATH, OPTIONS before the URL), printed and
# run; what it answered; the lines it added at DEBUG; the timer series it moved. SAVE keeps the answer; SAME compares with it.
req() { local c d0 n
  c=$(url "$Q" "$1"); c=${c%/customers}$2; [ -z "$3" ] || c=${c/ http:/ $3 http:}
  d0=$(dcount); series "$1" > .harness/s0.txt
  echo "\$ $c"; (eval "$c") > .harness/q.out 2>&1 < /dev/null || true
  sed 's/^/  /' .harness/q.out
  [ "$4" != SAVE ] || cp .harness/q.out .harness/qa.out
  [ "$4" != SAME ] || { if cmp -s .harness/q.out .harness/qa.out; then echo "  the same answer as A's, byte for byte: yes"; else echo "  the same answer as A's, byte for byte: no"; fi; }
  settle "$1"; series "$1" > .harness/s1.txt
  n=$(( $(dcount) - d0 )); echo "  its lines at DEBUG: $n"; dlines "$d0"
  echo "  the timer's series it moved: $(diff .harness/s0.txt .harness/s1.txt | grep -c '^>' || true)"
  awk '{ k = $0; sub(/ [^ ]+$/, "", k) } FILENAME == ARGV[1] { was[k] = $NF; next } !(k in was) || was[k] != $NF { print "    " k " " (k in was ? was[k] : "(new)") " -> " $NF }' .harness/s0.txt .harness/s1.txt; }
# sorted URL: Actuator's JSON, its keys sorted (the bridge writes keys in reflection's order, which moved under load: the health
# lesson's finding), and the status
sorted() { local c=$1
  echo "\$ $c    # keys sorted"
  curl -s -o .harness/j.json -w '%{http_code}' "${c##* }" > .harness/j.code 2>&1 < /dev/null || true
  echo "  $(python3 -c 'import json,sys; print(json.dumps(json.load(open(sys.argv[1])), sort_keys=True, separators=(",", ":")))' .harness/j.json) $(cat .harness/j.code)"; }
# mask: the demo token becomes a label naming its length; this folder's path "…", the folder above it "…/..", the home folder "~"
# (each also in its URL form, spaces as %20); the user name "<user>" - in every line (gsub)
mask() { awk -v t="$TOKEN" -v u="$U" -v up="$UP" -v hm="$HOME" -v me="$ME" '
  function lit(x) { gsub(/[][\\.^$*+?(){}|\/]/, "\\\\&", x); return x }
  function enc(x) { gsub(/ /, "%20", x); return x }
  BEGIN { T = lit(t); P = lit(u); Q = lit(up); H = lit(hm); PE = lit(enc(u)); QE = lit(enc(up)); M = lit(me) }
  { gsub(T, "[masked: the 26-character token]"); gsub(P, "…"); gsub(PE, "…"); gsub(Q, "…/.."); gsub(QE, "…/.."); gsub(H, "~"); gsub(M, "<user>"); print }'; }
unpub=""
cap() { local nm=$1 h pub i; shift
  for i in 1 2 3; do "$@" > .harness/cap.raw 2>&1 || true; [ -z "$pid" ] || die "$nm left a process running"
    raw "$TOKEN" .harness/cap.raw > ".harness/raw-$nm.$i"; mask < .harness/cap.raw > ".r-$nm.$i"; done
  h=$(md5 -q ".r-$nm.1")
  [ "$h" = "$(md5 -q ".r-$nm.2")" ] && [ "$h" = "$(md5 -q ".r-$nm.3")" ] || die "$nm drifts across three runs (diff .r-$nm.1 .r-$nm.2 .r-$nm.3)"
  mv ".r-$nm.1" ".r-$nm.out"; rm -f ".r-$nm.2" ".r-$nm.3"
  pub=$(awk -v n="$nm" '$1 == n { print $2 }' receipts.md5 2> /dev/null || true)
  if [ -z "$pub" ]; then printf '  %-10s md5 %s  3/3  (no published hash)\n' "$nm" "$h"; unpub="$unpub $nm"
  elif [ "$pub" = "$h" ]; then printf '  %-10s md5 %s  3/3  = published\n' "$nm" "$h"
  else printf '  %-10s md5 %s  3/3  DIFFERS from the published %s\n' "$nm" "$h" "$pub"
    die "$nm is not the published capture - suspect another JDK, Boot or Maven, a busy machine, a busy port, a variable of yours, or an edited source; diff .r-$nm.out against its block in README.md"; fi; }

# ---- seam: what TiffinBox's own server does ---------------------------------------------------------------------------------
seam() { local d7 P=19160
  echo "A, B, A' and C - the README's DEBUG line (the log group kitchen at DEBUG), from .harness/serve, port $P:"
  start "$(at .harness/serve $P "$R_DEBUG")"; up; ready $P
  echo "  the routes TiffinBox mapped, its own log line: $(grep -m1 ' : routes mapped: ' .harness/run.out | sed 's/^.* : routes mapped: *//')"
  echo "A - GET /customers, the path a route declares:"
  req $P /customers '' SAVE
  echo "B - GET /customersXYZ, three letters more:"
  req $P /customersXYZ '' SAME
  echo "A' - A again:"
  req $P /customers '' SAME
  echo "C (labelled) - GET /nowhere, a path no route declares:"
  req $P /nowhere '' SAME
  echo "the rest of the server's jobs:"
  req $P /customers/ '' SAME
  req $P /kitchen/anything
  req $P /customers '-X DELETE'
  req $P /kitchen "-H 'Accept: application/xml'"
  req $P /actuator
  req $P /actuator/mappings
  echo "the timer's series now - their route tags, and how many answers each counted:"
  series $P | sed 's/^/  /'
  echo "  series whose route is a path as typed (/customersXYZ, /customers/, /kitchen/anything, /nowhere, /actuator): $(series $P | grep -cE 'route="[A-Z]+ /(customersXYZ|customers/|kitchen/|nowhere|actuator)' || true)"
  echo "the seven, then the lines they added at DEBUG (read after the server stopped):"
  d7=$(dcount)
  seven $P .harness/serve
  echo "  their lines at DEBUG: $(( $(dcount) - d7 ))"; dlines "$d7"
  echo "  answered by a route TiffinBox declares: $(dlines "$d7" | grep -vc '^    UNKNOWN ' || true) · by TiffinBox's server with no route (UNKNOWN): $(dlines "$d7" | grep -c '^    UNKNOWN ' || true) · never reached TiffinBox (no line): $(( $(wc -l < .harness/responses.txt) - $(dcount) + d7 ))"
  echo "  the answer that never reached TiffinBox: $(grep -vE '^(GET|POST) +/(customers|revenue|dashboard|kitchen|shutdown) ' .harness/responses.txt | sed 's/ \{2,\}/ /g')"
  echo "this run's answer lines at DEBUG: $(dcount) · on a virtual thread: $(grep -E "$ANS" .harness/run.out | grep -cE '\[ *virtual-[0-9]+\]' || true) · its WARN lines: $(grep -cE '^[0-9-]+T[^ ]+ +WARN ' .harness/run.out || true) · ERROR lines: $(grep -cE '^[0-9-]+T[^ ]+ +ERROR ' .harness/run.out || true)"
  P=19161
  echo "D (labelled) - Boot's routing table: the README's exposure line with mappings, exposed by flag for one run, on the JVM, port $P:"
  start "$(at .harness/serve $P "$R_MAP")"; up; ready $P
  sorted "$(url "${R_GET%/customers}/actuator/mappings" $P)"
  echo "  its contexts: $(python3 -c 'import json,sys; d=json.load(open(sys.argv[1]))["contexts"]; print(len(d), "-", ", ".join(sorted(d)), "· the kinds of mapping listed in them:", sum(len(c.get("mappings") or {}) for c in d.values()))' .harness/j.json)"
  seven $P .harness/serve; }

# ---- pieces: the files ------------------------------------------------------------------------------------------------------
WEB=tiffinbox-web/src/main/java/com/tiffinbox/web; CORE=tiffinbox-core/src/main/java/com/tiffinbox
pieces() { local L
  echo "the web module's files - lines, and three greps: imports the JDK's HTTP server · is the annotation the router reads · explains the failed bind of the server's start:"
  L='for f in '"$WEB"'/*.java; do echo "$(basename "$f") $(wc -l < "$f" | tr -d " ") · $(grep -c "^import com\.sun\.net\.httpserver\." "$f") · $(grep -c "^public @interface Route " "$f") · $(grep -c "thrownIn(TiffinBoxServer\.class, \"start\"" "$f")"; done'
  echo "\$ cd .harness/serve && $L"
  (cd .harness/serve && eval "$L") | sed 's/^/  /' > .harness/pieces.txt; cat .harness/pieces.txt
  echo "  the router reads the annotation: $(cd .harness/serve && grep -c 'getAnnotation(Route\.class)' $WEB/TiffinBoxServer.java) line in TiffinBoxServer.java"
  awk '{ if ($4 + $6 + $8 > 0) { w++; wl += $2; n = n " " $1 } else { r++; rl += $2; o = o " " $1 } } END {
    print "  the files that do one of the three: " w " -" n " · " wl " lines"
    print "  the files that do none: " r " -" o " · " rl " lines" }' .harness/pieces.txt
  echo "the core module's files:"
  L="cat $CORE/*.java | wc -l | tr -d ' '; ls $CORE/*.java | wc -l | tr -d ' '; grep -l 'com.sun.net.httpserver' $CORE/*.java | wc -l | tr -d ' '"
  echo "\$ cd .harness/serve && $L"
  (cd .harness/serve && eval "$L") | paste -sd' ' - | awk '{ print "  lines " $1 " · files " $2 " · that import the JDK\047s HTTP server " $3 }'
  echo "the tree against the anchor, without target/ and secrets/ (diff -rq): $(diff -rq -x target -x secrets .harness/serve anchor | wc -l | tr -d ' ') differences"; }

# ---- readme: the repository's roadmap line (ledger P11) ---------------------------------------------------------------------
readmecap() {
  echo "the roadmap line in the repository's README - as the last commit before this unit had it:"
  echo "\$ git -C .. show 53379bd:README.md | grep -n '^Videos publish'"
  git -C .. show 53379bd:README.md | grep -n '^Videos publish' | sed 's/^/  /'
  echo "and as it is now:"
  echo "\$ grep -n '^Videos publish' ../README.md"
  grep -n '^Videos publish' ../README.md | sed 's/^/  /'
  echo "  its entries, in order (… counted as one): $(grep 'Roadmap' ../README.md | sed 's/^.*: //; s/\.$//' | awk -F ' → ' '{ print NF }') names · after Spring Boot: $(grep 'Roadmap' ../README.md | sed 's/^.*Spring Boot → //; s/ → .*$//') · Build & Test named: $(grep 'Roadmap' ../README.md | grep -c 'Build & Test')"; }

cap seam seam
cap pieces pieces
cap readme readmecap

echo
# ---- every number the video says, asserted. Each check reads a line a program computed - never a label this script prints
# ---- unconditionally - and names the words it pays for.
x() { grep -qE -- "$2" ".r-$1.out" || die "$1: expected /$2/"; }
blk() { awk -v a="$2" -v b="$3" 'index($0, a) == 1 { f = 1; next } b != "" && index($0, b) == 1 { f = 0 } f' ".r-$1.out"; }
has() { printf '%s\n' "$1" | grep -qxF -- "$2" || die "$3: expected the line: $2"; }
cnt() { printf '%s\n' "$1" | grep -cxF -- "$2" || true; }
S115='115c36bac276128e245ca57df11c2891'
SEVEN="  exit 0 · the seven responses: 7 lines · md5 $S115"
CUST='  [{"name":"Meera","mealsPerDay":1,"pricePerMeal":150,"mealType":"NON_VEG"},{"name":"Priya","mealsPerDay":1,"pricePerMeal":120,"mealType":"VEGAN"},{"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"},{"name":"Sunil","mealsPerDay":3,"pricePerMeal":100,"mealType":"VEG"}] 200 application/json'
for f in .harness/raw-*; do [ "$(cat "$f")" = 0 ] || die "a capture's raw output held the demo token ($f)"; done
for f in .r-*.out README.md receipts.md5 harness/shutdown.sh ../README.md; do [ -f "$f" ] || die "missing: $f"
  [ "$(raw "$TOKEN" "$f")" = 0 ] || die "$f holds the demo token, raw"; done
for f in .r-*.out; do ! grep -qE '/Users/|/private/|/home/|/var/folders/' "$f" || die "$f holds an absolute path"; ! grep -qE 'c[0-9]-unit[0-9]|unit ?[0-9]' "$f" || die "$f holds a unit number"; ! grep -qE ' (with PID|started by) ' "$f" || die "$f holds Boot's process line"; ! grep -qE '^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T|virtual-[0-9]' "$f" || die "$f holds a log line's time or a thread's number"; ! grep -q "^$(printf '\t')at " "$f" || die "$f shows a stack frame"; ! grep -q 'offline: no' "$f" || die "$f: a build went online"; done
NL=$(cat .r-*.out | grep -cxF "  its log: the demo token 0 times · X-Shutdown-Token 0 times" || true)
echo "  token: 0 raw copies in $(ls .harness/raw-* | wc -l | tr -d ' ') raw capture runs, in $(ls .r-*.out | wc -l | tr -d ' ') captures, in the logs of every run that served ($LOGS counted here, the published captures' $NL each with 0), this README, the harness, the repository's README and receipts.md5; no absolute path, no unit number, no process line, no log time, no thread number, no stack frame, no build that went online in any capture"

# "A: slash customers, the four customers. B: three letters more, slash customers X Y Z: the same answer, byte for byte, logged and
# timed as GET slash customers. A again: the same. C: slash nowhere: the JDK's own page, no line, no timer."
SA=$(blk seam 'A - GET /customers' 'B - GET'); SB=$(blk seam 'B - GET' "A' - A again"); SA2=$(blk seam "A' - A again" 'C (labelled)'); SC=$(blk seam 'C (labelled)' 'the rest of')
has "$SA" "$CUST" "seam A: the customers"; has "$SB" "$CUST" "seam B: the customers"; has "$SA2" "$CUST" "seam A': the customers"
has "$SB" "  the same answer as A's, byte for byte: yes" "seam B: byte for byte"; has "$SA2" "  the same answer as A's, byte for byte: yes" "seam A': byte for byte"
for b in "$SA" "$SB" "$SA2"; do has "$b" "  its lines at DEBUG: 1" "seam A/B/A': one line"; has "$b" "    GET /customers -> 200    (on a virtual thread)" "seam A/B/A': logged as GET /customers"; has "$b" "  the timer's series it moved: 1" "seam A/B/A': one series"; done
has "$SA" '    tiffinbox_requests_seconds_count{route="GET /customers",status="200"} (new) -> 1' "seam A: timed as GET /customers"
has "$SB" '    tiffinbox_requests_seconds_count{route="GET /customers",status="200"} 1 -> 2' "seam B: timed as GET /customers"
has "$SA2" '    tiffinbox_requests_seconds_count{route="GET /customers",status="200"} 2 -> 3' "seam A': timed as GET /customers"
[ "$(printf '%s\n' "$SA" | grep '^\$ curl')" = "$(printf '%s\n' "$SA2" | grep '^\$ curl')" ] || die "seam: A' is not A's command"
has "$SC" "  <h1>404 Not Found</h1>No context found for request 404 text/html" "seam C: the JDK's page"
has "$SC" "  the same answer as A's, byte for byte: no" "seam C: not A's"
has "$SC" "  its lines at DEBUG: 0" "seam C: no line"; has "$SC" "  the timer's series it moved: 0" "seam C: no timer"
echo "  seam A/B/A'/C: /customersXYZ = /customers byte for byte, logged and timed as GET /customers (1 -> 2 -> 3); /nowhere the JDK's 404 text/html, 0 lines, 0 series"

# "A trailing slash, or slash kitchen slash anything, answers too. A wrong verb gets TiffinBox's own four oh five, as UNKNOWN.
# Accept X M L still gets JSON. Slash actuator is the bridge's four oh four, and mappings isn't even exposed."
SR=$(blk seam 'the rest of' 'the timer')
[ "$(cnt "$SR" "$CUST")" = 1 ] || die "seam: /customers/ answers the customers"; has "$SR" "  the same answer as A's, byte for byte: yes" "seam: /customers/ = A"
[ "$(cnt "$SR" '  {"ordersCooked":120,"ordersValue":24300} 200 application/json')" = 2 ] || die "seam: /kitchen/anything and Accept xml: the kitchen, JSON"
[ "$(cnt "$SR" '    GET /kitchen -> 200    (on a virtual thread)')" = 2 ] || die "seam: both logged as GET /kitchen"
has "$SR" "\$ curl -s -w ' %{http_code} %{content_type}\n' -H 'Accept: application/xml' http://127.0.0.1:19160/kitchen" "seam: the Accept line"
has "$SR" '  {"error":"method not allowed"} 405 application/json' "seam: 405"; has "$SR" '    UNKNOWN -> 405    (on a virtual thread)' "seam: 405 as UNKNOWN"
has "$SR" '    tiffinbox_requests_seconds_count{route="UNKNOWN",status="405"} (new) -> 1' "seam: 405 timed as UNKNOWN"
[ "$(cnt "$SR" '  {"error":"not found"} 404 application/json')" = 2 ] || die "seam: /actuator and /actuator/mappings 404"
[ "$(cnt "$SR" '  its lines at DEBUG: 0')" = 2 ] || die "seam: the bridge's answers neither logged nor timed"
x seam '^  series whose route is a path as typed \(/customersXYZ, /customers/, /kitchen/anything, /nowhere, /actuator\): 0$'
[ "$(grep -c '^  tiffinbox_requests_seconds_count{' .r-seam.out)" = 3 ] || die "seam: three series"
x seam '^  tiffinbox_requests_seconds_count\{route="GET /customers",status="200"\} 4$'
x seam '^  tiffinbox_requests_seconds_count\{route="GET /kitchen",status="200"\} 2$'
echo "  seam, the rest: prefix /customers/, /kitchen/anything 200; DELETE 405 UNKNOWN; Accept xml -> JSON; /actuator 404 x2, untimed; 3 series, 0 typed paths"

# "Two of the seven aren't a route's answer at all: the four oh four is the JDK's page, and the four oh five is TiffinBox's server."
x seam '^  their lines at DEBUG: 6$'
x seam "^  answered by a route TiffinBox declares: 5 · by TiffinBox's server with no route \(UNKNOWN\): 1 · never reached TiffinBox \(no line\): 1$"
x seam '^  the answer that never reached TiffinBox: GET /nowhere -> 404 text/html <h1>404 Not Found</h1>No context found for request$'
x seam '^    UNKNOWN -> 405    \(on a virtual thread\)$'
[ "$(grep -cxF "$SEVEN" .r-seam.out)" = 2 ] || die "seam: the seven, twice"
# "Every answer ran on a virtual thread of its own."
L=$(grep '^this run.s answer lines at DEBUG: ' .r-seam.out); N=$(printf '%s\n' "$L" | sed -E 's/^.*DEBUG: ([0-9]+) · on a virtual thread: ([0-9]+) · .*$/\1 \2/')
[ "${N% *}" = "${N#* }" ] && [ "${N% *}" = 13 ] || die "seam: every answer line on a virtual thread ($N)"
x seam '^this run.s answer lines at DEBUG: 13 · on a virtual thread: 13 · its WARN lines: 0 · ERROR lines: 0$'
# "Boot's own routing table, exposed for one run: one context, and nothing in it."
SD=$(blk seam 'D (labelled)' '')
has "$SD" "\$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19161/actuator/mappings    # keys sorted" "seam D: the mappings line"
has "$SD" '  {"contexts":{"application":{"mappings":{},"parentId":null}}} 200' "seam D: the empty table"
has "$SD" "  its contexts: 1 - application · the kinds of mapping listed in them: 0" "seam D: 1 context, 0 kinds"
has "$SD" "$SEVEN" "seam D: the seven"
echo "  seam, the seven: 6 lines (5 routes, 1 UNKNOWN), /nowhere none; 13/13 answers on virtual threads; D mappings: 1 context, 0 kinds; the seven 115c36ba... twice"

# "Four files do the web's jobs: the server, two hundred and seventy-seven lines; the bridge, a hundred and ninety-six; the
# annotation, twenty-four; the port's failure analyzer, fifty-one. Five hundred and forty-eight lines. The rest don't touch HTTP."
PI=$(cat .r-pieces.out)
has "$PI" "  TiffinBoxServer.java 277 · 3 · 0 · 0" "pieces: the server"
has "$PI" "  ActuatorRoutes.java 196 · 2 · 0 · 0" "pieces: the bridge"
has "$PI" "  Route.java 24 · 0 · 1 · 0" "pieces: the annotation"
has "$PI" "  PortTakenFailureAnalyzer.java 51 · 0 · 0 · 1" "pieces: the analyzer"
has "$PI" "  the router reads the annotation: 1 line in TiffinBoxServer.java" "pieces: the router reads it"
has "$PI" "  the files that do one of the three: 4 - ActuatorRoutes.java PortTakenFailureAnalyzer.java Route.java TiffinBoxServer.java · 548 lines" "pieces: 4 files, 548"
has "$PI" "  the files that do none: 5 - BareArgumentAnalyzer.java BareArgumentGuard.java KitchenHealthIndicator.java KitchenMetrics.java TiffinBoxApp.java · 218 lines" "pieces: 5 files, 218"
has "$PI" "  lines 316 · files 7 · that import the JDK's HTTP server 0" "pieces: the core"
has "$PI" "the tree against the anchor, without target/ and secrets/ (diff -rq): 0 differences" "pieces: the anchor's own files"
echo "  pieces: 277 + 196 + 24 + 51 = 548 in 4 files; 5 files 218 and the core's 7 files 316 do none"

# The README's line (ledger P11): before - Spring Boot, then JPA; now - Spring Web MVC after Spring Boot, Build & Test named.
RD=$(cat .r-readme.out)
has "$RD" "  447:Videos publish a few per day on the channel. Roadmap: Core Java → Spring Framework → Spring Boot → JPA → REST → Security → … → Spring AI." "readme: the line before"
x readme '^  447:Videos publish a few per day on the channel\. Roadmap \(19 courses\): .* → Spring Boot → Spring Web MVC → .* → Spring AI\.$'
x readme '^  its entries, in order \(… counted as one\): [0-9]+ names · after Spring Boot: Spring Web MVC · Build & Test named: 1$'
echo "  readme: line 447, before JPA after Spring Boot; now Spring Web MVC after Spring Boot, Build & Test named"

cmp -s anchor/README.md ../c5-tiffinbox/README.md || echo "  (anchor/README.md and ../c5-tiffinbox/README.md differ - the anchor has moved past this unit's tree)" >&3
[ -z "$unpub" ] || die "no published hash for:$unpub - check the captures, then copy the md5s above into receipts.md5 and run again"
echo "c5-unit30: every capture 3/3 and = published; every spoken number asserted; 0 raw demo tokens in every capture and every run's log"
