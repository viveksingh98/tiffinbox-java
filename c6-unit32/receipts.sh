#!/bin/bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25.0.4.1 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# Course 6 · What's Next: Where the Data Lives - this unit's receipts, the course's last. No anchor change: the tree is
# ../c6-unit31/after (= c6-tiffinbox, the tree the next course starts from), reached through the link `anchor`, copied under
# .harness/ and built there, never in place. No native build, no Docker, no stub. Two captures, each run three times and hashed;
# cap() DIES when a hash differs from receipts.md5; every number the video says from them is asserted at the bottom by a check
# that can fail; the demo token is masked (gsub), and the checks count 0 raw copies of it in every capture, in the log of every
# run and in every file this unit ships.
#   memory  where TiffinBox's data lives: the anchor's database URL (its application.yaml), the SQL it writes by hand
#           (harness/sql.py, counted per file), its repository class; Course 2's JDBC lesson's repository class and URL, read off
#           its own folder ($C2) - the class the next course's first lesson names; then the seven, first, on a fresh JVM (19612);
#           then the first JVM (19610): the customers, Kavya added, the customers, Kavya; POST /shutdown; then the restart - the
#           same tree, the same jar, a new JVM (19611): the customers, Kavya; POST /shutdown
#   readme  the repository's own README, as the commit before this unit's had it ($PIN, the last commit of Course 6's
#           capstone) and as it is now: its title, the folders its opening maps, its course sections, its roadmap line; this
#           unit's Course 6 section, whole; then Course 5's finale's readme capture ($C5, the What's Next lesson of Spring Boot),
#           which hashes those same lines: its pinned reads, and its readme function re-run from its own receipts.sh, its md5
#           beside the one its receipts.md5 publishes
# The course's counts (lessons, sections, courses, the next course and its first titles) and what the course measured (the units'
# captures, the contract's rules, the capstone's tests) are NOT captured here: their sources (java6_series.py, TRACK-ROADMAP.md,
# STYLE-CONTRACT.md) are not in this repository. The deck's builder reads them on the day (Course 4's and Course 5's finales'
# method), and README.md says so.
# "$CURLSET" is the comparison set since the secrets lesson (../c5-unit11/curlset.sh: the seven requests, POST /shutdown with the
# token's header read from the file). "$M2" is this unit's own repository, .m2-demo. "$C2" is ../c2-unit38 (Course 2's
# TiffinBox on a Real Database: The JDBC Repository); "$C5" is ../c5-unit30 (Course 5's What's Next: The Web Layer). The harness:
# harness/shutdown.sh (POST /shutdown with the token read from its file - the CORS lesson's, byte for byte) and harness/sql.py
# (the SQL counter). The seven always run on a fresh JVM, first.
# The locale: the JVM ignores LC_ALL on macOS - every JVM this script starts has its locale pinned on its run line
# (-Duser.language=en -Duser.country=US, before -jar), and the checks refuse a java line without it.
# The network: every Maven build runs offline (-o) against .m2-demo and says so ("offline: yes"); a build that cannot resolve an
# artifact offline goes to Maven Central once, and says that ("offline: no - ..."). At run time nothing leaves 127.0.0.1.
# Masks and filters (README.md declares each; awk sub/gsub only): the demo token becomes "[masked: the 32-character token]"; this
# folder's absolute path "…", the folder above it "…/..", the home folder "~"; your user name "<user>"; the Java version in Boot's
# first line " using Java <version>" (printed on the terminal once); Tomcat's connector name "http-nio-127.0.0.1-<port>"; a
# problem detail's or Boot's error timestamp "…". A JVM's log: Boot's first line, WARN and ERROR counted. A JSON answer is its
# bytes, keys sorted. No duration is captured.
# Ports (brief ⚑1, 19610-19619): the first JVM 19610 · the restart 19611 · the seven's fresh JVM 19612 · 19619 never bound.
# 18425 (TiffinBox's default), 8080 (Tomcat's) and 35729 (DevTools' Live Reload) are checked free too, and never bound.
set -e
# bash 5.2 and later turn an & in the replacement of ${x/pattern/replacement} into the matched text (patsub_replacement, on by
# default). Switched off, so /bin/bash 3.2 (./receipts.sh) and a newer bash (bash receipts.sh) run the same commands.
shopt -u patsub_replacement 2> /dev/null || true
# One locale for every tool, whatever yours is: sort's order, and what a program prints, follow it. (The JVM's is pinned per JVM.)
export LC_ALL=C
cd "$(dirname "$0")"
# One run at a time: two runs share .harness/ and the ports, and one would corrupt the other.
mkdir .r-lock 2> /dev/null || { echo "  *** another receipts.sh is running in this folder (.r-lock exists) - if none is, rmdir .r-lock ***"; exit 1; }
U="$PWD"; UP="$(cd .. && pwd)"; ME="$(id -un)"
# On every exit - the end, a failed check, or Ctrl-C - stop the server this script started in the background ($pid), if it still
# runs, then sweep(): anything of this run still alive in its process group - a TiffinBox JVM, a Maven build - is stopped. After an
# interrupt, a capture's unfinished runs (.r-NAME.1-3) go too; after a failed check they stay, for the diff the message names. The
# clean-up ignores a second Ctrl-C, and nothing in it can fail under set -e; the script still exits 130 after an interrupt
# (README.md, "Interrupted"). sweep() kills only processes of this run's own process group - start each run in a group of its own.
# No wait in this script is bare: each names its pid.
pid=""; mpid=""
sweep() { local g i l
  g=$(ps -o pgid= -p $$ 2> /dev/null | tr -d ' ') || g=""
  [ -n "$g" ] || return 0
  i=0; while [ $i -lt 20 ]; do
    l=$(ps -axo pid=,pgid=,command= 2> /dev/null | awk -v g="$g" -v me=$$ '
      $2 == g && $1 != me && $3 != "awk" && $3 != "ps" && (index($0, "tiffinbox-web-1.0.0.jar") || index($0, "com.tiffinbox.web.TiffinBoxServer") || index($0, "org.codehaus.plexus.classworlds.launcher.Launcher")) { print $1 }' | paste -sd' ' -) || l=""
    [ -n "$l" ] || return 0
    if [ $i -lt 10 ]; then kill $l 2> /dev/null || true; else kill -9 $l 2> /dev/null || true; fi
    sleep 0.5; i=$((i + 1)); done; }
trap 'trap "" INT TERM; for p in "$pid" "$mpid"; do if [ -n "$p" ] && kill "$p" 2> /dev/null; then wait "$p" 2> /dev/null || true; fi; done; sweep || true; [ -z "$INTR" ] || rm -f .r-*.[123]; rmdir .r-lock 2> /dev/null || true' EXIT
INTR=""; trap 'INTR=1; exit 130' INT TERM
exec 3>&1                                            # die() speaks to the terminal even inside a redirected capture
die() { echo "  *** $* ***" >&3; exit 1; }
java -version 2>&1 | grep -q 'version "25' || die "JDK 25 needed; JAVA_HOME gives: $(java -version 2>&1 | head -1)"
for t in python3 curl rsync lsof mvn md5 git cmp unzip; do command -v $t > /dev/null || die "$t is needed"; done
# A variable of yours must not become a property source, a JVM flag or a build setting (the problem-detail lesson's loop,
# verbatim: sed -E, a canary planted under every name first, and the run stops if one survives).
for v in TIFFINBOX_CANARY SPRING_CANARY MANAGEMENT_CANARY SERVER_CANARY LOGGING_CANARY DEBUG JAVA_TOOL_OPTIONS JDK_JAVA_OPTIONS _JAVA_OPTIONS MAVEN_OPTS MAVEN_ARGS; do export "$v=planted-canary"; done
for v in $(env | sed -n -E 's/^(TIFFINBOX_[A-Za-z0-9_]*|SPRING_[A-Za-z0-9_]*|MANAGEMENT_[A-Za-z0-9_]*|SERVER_[A-Za-z0-9_]*|LOGGING_[A-Za-z0-9_]*|DEBUG|JAVA_TOOL_OPTIONS|JDK_JAVA_OPTIONS|_JAVA_OPTIONS|MAVEN_OPTS|MAVEN_ARGS)=.*/\1/p'); do unset "$v"; done
[ -z "$(env | grep -- '=planted-canary$')" ] || die "a variable survived the clean-up above: $(env | grep -- '=planted-canary$' | sed 's/=.*//' | paste -sd' ' -)"
# Every request this script makes goes to 127.0.0.1: 127.0.0.1 and localhost go first in no_proxy and NO_PROXY.
export no_proxy="127.0.0.1,localhost${no_proxy:+,$no_proxy}" NO_PROXY="127.0.0.1,localhost${NO_PROXY:+,$NO_PROXY}"
[ -e secrets ] && die "this folder holds a secrets/ - remove it: every run here starts in a folder under .harness/"
[ -L anchor ] && [ "$(readlink anchor)" = ../c6-unit31/after ] || die "anchor must be the link to ../c6-unit31/after - this unit changes nothing in the anchor"
[ -f anchor/pom.xml ] && [ -f anchor/README.md ] || die "anchor/ (../c6-unit31/after) is missing"
[ -e anchor/secrets ] || [ -e anchor/target ] || [ -e anchor/tiffinbox-web/target ] || [ -e anchor/tiffinbox-core/target ] || [ -e anchor/tiffinbox-local.yaml ] && die "anchor/ (../c6-unit31/after) holds a secrets/, a target/ or a tiffinbox-local.yaml - it is a frozen copy, never built in place"
M2="$PWD/.m2-demo"
TF=secrets/tiffinbox/shutdown-token                  # the config tree's file for tiffinbox.shutdown-token
# The demo token. FAKE, and meant to look it: it guards nothing but a demo server on 127.0.0.1 that every capture stops. It is
# written into .harness/*/secrets/ (git-ignored) when this script runs, and no capture prints it: see mask().
TOKEN=demo-token-for-where-the-data-is
[ ${#TOKEN} = 32 ] || die "the demo token must be 32 characters: the published captures name its length"
CURLSET=../c5-unit11/curlset.sh
C2=../c2-unit38                                      # Course 2's TiffinBox on a Real Database: The JDBC Repository
C5=../c5-unit30                                      # Course 5's What's Next: The Web Layer
PIN=0458d2b                                            # the commit before this unit's: Course 6's capstone, the README as Course 5 left it
CORE=tiffinbox-core/src/main/java/com/tiffinbox; WEB=tiffinbox-web/src/main/java/com/tiffinbox/web
for f in "$CURLSET" harness/shutdown.sh harness/sql.py ../README.md README.md "$C2/README.md" "$C2/src/main/java/JdbcCustomerRepository.java" "$C2/src/main/java/Db.java" "$C5/receipts.sh" "$C5/receipts.md5"; do [ -f "$f" ] || die "$f is missing"; done
[ "$(ls harness | paste -sd' ' -)" = 'shutdown.sh sql.py' ] || die "harness/ holds another file"
cmp -s harness/shutdown.sh ../c6-unit19/harness/shutdown.sh || die "harness/shutdown.sh is not the CORS lesson's (../c6-unit19/harness/shutdown.sh), byte for byte"
git -C .. rev-parse --verify -q "$PIN^{commit}" > /dev/null || die "the repository's history must hold $PIN (the commit before this unit's): a full clone, not a shallow one"

listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
for p in 18425 8080 35729 19610 19611 19612 19619; do
  [ "$(listeners $p)" = 0 ] || die "something already listens on $p - this unit's ports must be free; if it is a TiffinBox an interrupted run left behind, stop it: kill $(lsof -nP -iTCP:$p -sTCP:LISTEN -t 2> /dev/null | paste -sd' ' -)"; done

# ---- the commands: read from anchor/README.md, the anchor's own, and asserted - each line must be there, whole -------------
readme() { grep -m1 -xF -- "$1" anchor/README.md > /dev/null || die "anchor/README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
R_PLAIN=$(readme 'mvn -B package')
R_RUN=$(readme 'java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431')
R_READY=$(readme "curl -s -w ' %{http_code}\n' http://127.0.0.1:18431/actuator/health/readiness")
R_GET=$(readme "curl -s -w ' %{http_code}\n' http://127.0.0.1:18431/customers")
R_ONE=$(readme "curl -s -w ' %{http_code}\n' http://127.0.0.1:18431/customers/Ravi")
R_POST=$(readme "curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '{\"name\":\"Asha\",\"mealsPerDay\":2,\"pricePerMeal\":110,\"mealType\":\"VEG\"}' http://127.0.0.1:18431/customers")
# This unit's own lines (README.md, "The commands this unit adds") - each asserted to be exactly that
mine() { grep -m1 -xF -- "$1" README.md > /dev/null || die "README.md no longer gives the line: $1"; printf '%s\n' "$1"; }
JL='-Duser.language=en -Duser.country=US'
L_RUNL=$(mine "java $JL -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431")
L_ADD=$(mine "curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '{\"name\":\"Kavya\",\"mealsPerDay\":1,\"pricePerMeal\":100,\"mealType\":\"VEG\"}' http://127.0.0.1:18431/customers")
L_KAVYA=$(mine "curl -s -w ' %{http_code}\n' http://127.0.0.1:18431/customers/Kavya")
# The derivations, each asserted: one change each, and nothing else
P_='java '; Q_="java $JL "; [ "${R_RUN/"$P_"/$Q_}" = "$L_RUNL" ] || die "the pinned line must be the anchor's run line with $JL after java, and nothing else"
P_='{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}'; Q_='{"name":"Kavya","mealsPerDay":1,"pricePerMeal":100,"mealType":"VEG"}'; [ "${R_POST/"$P_"/$Q_}" = "$L_ADD" ] || die "Kavya's POST must be the README's POST with Kavya's customer, and nothing else"
[ "${R_ONE/Ravi/Kavya}" = "$L_KAVYA" ] || die "Kavya's line must be the README's /customers/Ravi line asking for Kavya, and nothing else"
# off DIR 'README mvn LINE': the README's Maven line as this script runs it - from DIR, offline (-o), this unit's own repository,
# clean and without tests (the tests are the capstone's capture). dev() takes those things back out, and must give the README's line.
off() { local c=${2/mvn -B /mvn -o -B -Dmaven.repo.local=\"\$M2\" }; c=${c/ package/ -DskipTests clean package}; printf 'cd %s && %s\n' "$1" "$c"; }
dev() { local c=${1#cd * && }; c=${c/ -o -B -Dmaven.repo.local=\"\$M2\" / -B }; c=${c/ -DskipTests clean / }; printf '%s\n' "$c"; }
[ "$(dev "$(off .harness/x "$R_PLAIN")")" = "$R_PLAIN" ] || die "not the README's build line with the offline changes"
# at DIR PORT 'README LINE': the README's line run from DIR, its port 18431 made PORT - a java line with the JVM's locale pinned
at() { local l=${3/--tiffinbox.port=18431/--tiffinbox.port=$2}; case $l in "java $JL "*) ;; 'java '*) l="java $JL ${l#java }" ;; esac; printf 'cd %s && %s\n' "$1" "$l"; }
url() { printf '%s\n' "${1/:18431\//:$2/}"; }
exe() { printf '%s\n' "$1" | sed -E 's/&& (([A-Z_]+=[^ ]* )*)/\&\& \1exec /'; }
[ "$(exe "$(at .harness/x 19610 "$R_RUN")")" = "cd .harness/x && exec ${L_RUNL/18431/19610}" ] || die "at(): not README.md's pinned line"
echo "  the commands: anchor/README.md gives the $(grep -c '^R_[A-Z]*=$(readme ' receipts.sh) lines this script runs or derives from; README.md the $(grep -c '^L_[A-Z]*=$(mine ' receipts.sh) this unit adds"
JV=$(java -version 2>&1 | sed -n 's/.*version "\([^"]*\)".*/\1/p' | head -1)
echo "  (terminal only) the JDK is $JV - Boot's first line names it; the captures say Java <version>" >&3

# ---- build: before the captures - the anchor's tree with a config tree, the README's plain build. On a fresh clone (.m2-demo
# ---- empty: git ignores it) this build fills .m2-demo, once.
rm -rf .harness; mkdir -p .harness
mbuild() { local how=yes ec=0 c=$1
  (eval "$c") > "$2" 2>&1 < /dev/null & mpid=$!; wait "$mpid" || ec=$?; mpid=""
  if [ $ec != 0 ] && grep -qE 'offline mode|Could not resolve|could not be resolved|Cannot access|No plugin found for prefix' "$2"; then
    how="no - the offline build could not resolve an artifact, so Maven Central was asked"; ec=0
    (eval "${c/mvn -o -B /mvn -B }") > "$2" 2>&1 < /dev/null & mpid=$!; wait "$mpid" || ec=$?; mpid=""; fi
  [ $ec = 0 ] || { tail -30 "$2" >&3
    ! grep -qE 'Could not resolve|could not be resolved|Could not transfer|Cannot access' "$2" || die "build failed: $3 - Maven could resolve neither from .m2-demo nor from Maven Central: a fresh clone's first run needs the network once, to fill .m2-demo"
    die "build failed: $3"; }
  echo "  built $3 · offline: $how · exit $ec"; }
# tree FOLDER: a config tree in FOLDER/secrets holding one file, the demo token and a newline, readable by its owner alone
tree() { mkdir -p "$1/secrets/tiffinbox"; (umask 077 && printf '%s\n' "$TOKEN" > "$1/$TF"); chmod 700 "$1/secrets" "$1/secrets/tiffinbox"; }
rsync -a --exclude target --exclude secrets --exclude .m2-demo anchor/ .harness/serve/; tree .harness/serve
mbuild "$(off .harness/serve "$R_PLAIN")" .harness/build-serve.log ".harness/serve (the anchor's tree, the README's plain build)"
[ -f .harness/serve/tiffinbox-web/target/tiffinbox-web-1.0.0.jar ] || die "the README's build made no jar"

# ---- helpers ------------------------------------------------------------------------------------------------------------
raw() { local t=$1; shift; cat "$@" 2> /dev/null | LC_ALL=C grep -aoF -- "$t" | wc -l | tr -d ' '; }
LOGS=0; LASTE=""
first() { grep -m1 -E ' : Starting ' "$1" | sed 's/^.* : //; s/ with PID .*$//; s/ using Java [0-9][0-9.]*/ using Java <version>/'; }
# R.158: the folder a start runs in must hold, in secrets/, the token's file and nothing else - a file there is a key
sec() { local s; s=$(cd "$1/secrets" 2> /dev/null && find . -type f | sed 's#^\./##' | sort | paste -sd' ' -)
  [ "$s" = tiffinbox/shutdown-token ] || die "$1/secrets holds more than the token's file (${s:-nothing}) - every file there is a key (R.158)"
  echo "  secrets/ before the start: $s - the token's file, and nothing else"; }
dir() { printf '%s\n' "$1" | sed -n 's/^cd \([^ ]*\) && .*/\1/p'; }
start() { local p; p=$(printf '%s\n' "$1" | sed -n 's/.*--tiffinbox\.port=\([0-9]*\).*/\1/p')
  [ -n "$p" ] && [ "$(listeners "$p")" = 0 ] || die "port ${p:-?} must be free before a start"
  sec "$(dir "$1")"; echo "\$ $1"; (eval "$(exe "$1")") > .harness/run.out 2> .harness/run.err < /dev/null & pid=$!; }
addrs() { lsof -nP -a -p "$1" -iTCP -sTCP:LISTEN 2> /dev/null | awk 'NR > 1 { print $9 }' | sort -u | paste -sd' ' -; }
listening() { local a="" i=0
  while [ $i -lt 480 ]; do a=$(addrs "$1"); case " $a " in *":$2 "*) break ;; esac; kill -0 "$1" 2> /dev/null || break; sleep 0.25; i=$((i + 1)); done
  echo "${a:-nothing}"; }
lb() { local a n=0; for a in $1; do n=$((n + 1)); case $a in 127.0.0.1:*) ;; *) echo no; return ;; esac; done; [ $n -gt 0 ] && echo yes || echo no; }
# up PORT: the server $pid listens on PORT, loopback only; Boot's first line
up() { local l; l=$(listening "$pid" "$1"); [ "$l" != nothing ] || { tail -20 .harness/run.out >&3; die "it never listened on $1"; }
  case " $l " in *':8080 '*|*':35729 '*|*':19619 '*) kill -9 "$pid" 2> /dev/null || true; die "it listened on 8080, 35729 or 19619 - never bound by this script";; esac
  echo "  listens on: $l · loopback only: $(lb "$l")"; echo "  Boot's first line: $(first .harness/run.out)"; }
tsmask() { awk '{ gsub(/"timestamp":"[^"]*"/, "\"timestamp\":\"…\""); gsub(/"timestamp":[0-9]+/, "\"timestamp\":…"); print }'; }
sortj() { python3 -c '
import json, sys
for l in sys.stdin.read().splitlines():
    b, _, s = l.rpartition(" ")
    try: o = json.dumps(json.loads(b), sort_keys=True, separators=(",", ":"), ensure_ascii=False)
    except ValueError: print("  " + l); continue
    print("  " + o + " " + s + ("    (keys sorted)" if o != b else ""))'; }
askj() { local c; c=$(url "$1" "$2"); echo "\$ $c"; (eval "$c") 2>&1 < /dev/null | tsmask | sortj; }
# names PORT: the README's /customers line's answer, read: the names, in its order, and how many
names() { local c; c=$(url "$R_GET" "$1"); (eval "$c") 2> /dev/null < /dev/null > .harness/list.out || true
  python3 -c 'import json, sys; b, _, s = open(sys.argv[1]).read().strip().rpartition(" "); n = [c["name"] for c in json.loads(b)]; print("  its names: " + " ".join(n) + " · " + str(len(n)) + " customers · " + s)' .harness/list.out; }
ready() { local i=0 c=""
  while [ $i -lt 480 ]; do c=$(curl -s -o /dev/null -w '%{http_code}' "http://127.0.0.1:$1/actuator/health/readiness" 2> /dev/null || true); [ "$c" = 200 ] && break
    kill -0 "$pid" 2> /dev/null || { tail -20 .harness/run.out >&3; die "it exited before readiness answered 200"; }
    sleep 0.25; i=$((i + 1)); done
  [ "$c" = 200 ] || die "readiness never answered 200 on $1"
  askj "$R_READY" "$1"; }
logtok() { local t h; t=$(raw "$TOKEN" .harness/run.out .harness/run.err); h=$(cat .harness/run.out .harness/run.err | LC_ALL=C grep -aoi -- 'x-shutdown-token' | wc -l | tr -d ' ')
  LOGS=$((LOGS + 1)); [ "$t" = 0 ] && [ "$h" = 0 ] || die "a log held the demo token ($t) or its header's name ($h)"
  echo "  its log: the demo token 0 times · X-Shutdown-Token 0 times · WARN lines: $(lvl WARN) · ERROR lines: $(lvl ERROR)"; }
lvl() { cat .harness/run.out .harness/run.err | grep -cE "^[0-9]{4}-[0-9]{2}-[0-9]{2}T[^ ]+ +$1 " || true; }
# gone PORT: the server $pid exits within 15 s of POST /shutdown; its exit code in LASTE
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
stop() { echo "\$ harness/shutdown.sh $1 $2/$TF"; harness/shutdown.sh "$1" "$2/$TF" | tsmask | sed 's/^/  /'; gone "$1"; echo "  exit $LASTE · listening on $1 now: 0"; logtok; }
mask() { awk -v t="$TOKEN" -v u="$U" -v up="$UP" -v hm="$HOME" -v me="$ME" -v tl="${#TOKEN}" '
  function lit(x) { gsub(/[][\\.^$*+?(){}|\/]/, "\\\\&", x); return x }
  function enc(x) { gsub(/ /, "%20", x); return x }
  BEGIN { T = lit(t); P = lit(u); Q = lit(up); H = lit(hm); PE = lit(enc(u)); QE = lit(enc(up)); M = "(^|[^A-Za-z0-9_])" lit(me) "([^A-Za-z0-9_]|$)" }
  { gsub(T, "[masked: the " tl "-character token]"); gsub(P, "…"); gsub(PE, "…")
    gsub(Q, "…/.."); gsub(QE, "…/.."); gsub(H, "~")
    gsub(/tomcat-handler-[0-9]+/, "tomcat-handler-<n>"); gsub(/ using Java [0-9][0-9.]+/, " using Java <version>")
    gsub(/http-nio-127\.0\.0\.1-[0-9]+/, "http-nio-127.0.0.1-<port>")
    while (match($0, M)) { pre = substr($0, 1, RSTART - 1); s = substr($0, RSTART, RLENGTH); post = substr($0, RSTART + RLENGTH)
      sub(lit(me), "<user>", s); $0 = pre s post }
    print }'; }
printf '%s\n' 'Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1' 'Tomcat initialized: http-nio-127.0.0.1-19610' "$TOKEN" > .harness/p1
[ "$(mask < .harness/p1)" = "$(printf '%s\n' 'Starting TiffinBoxServer v1.0.0 using Java <version>' 'Tomcat initialized: http-nio-127.0.0.1-<port>' '[masked: the 32-character token]')" ] || die "mask: the planted JDK version, connector name and token must be masked"
unpub=""
cap() { local nm=$1 h pub i; shift
  for i in 1 2 3; do "$@" > .harness/cap.raw 2>&1 || true; [ -z "$pid$mpid" ] || die "$nm left a process running"
    raw "$TOKEN" .harness/cap.raw > ".harness/raw-$nm.$i"; mask < .harness/cap.raw > ".r-$nm.$i"; done
  h=$(md5 -q ".r-$nm.1")
  [ "$h" = "$(md5 -q ".r-$nm.2")" ] && [ "$h" = "$(md5 -q ".r-$nm.3")" ] || die "$nm drifts across three runs (diff .r-$nm.1 .r-$nm.2 .r-$nm.3)"
  mv ".r-$nm.1" ".r-$nm.out"; rm -f ".r-$nm.2" ".r-$nm.3"
  pub=$(awk -v n="$nm" '$1 == n { print $2 }' receipts.md5 2> /dev/null || true)
  if [ -z "$pub" ]; then printf '  %-10s md5 %s  3/3  (no published hash)\n' "$nm" "$h"; unpub="$unpub $nm"
  elif [ "$pub" = "$h" ]; then printf '  %-10s md5 %s  3/3  = published\n' "$nm" "$h"
  else printf '  %-10s md5 %s  3/3  DIFFERS from the published %s\n' "$nm" "$h" "$pub"
    die "$nm is not the published capture - suspect another JDK, Boot or Maven, a busy machine, a busy port, a variable of yours, an edited source, or a changed repository README; diff .r-$nm.out against its block in README.md"; fi; }

# C (labelled): Course 2's URL - a file under the folder TiffinBox starts in - given by Boot's key on the run line. H2's own shell
# (org.h2.tools.Shell, in the H2 jar the anchor's jar carries) reads that file while no TiffinBox runs; its "(N rows, T ms)" line
# keeps the count and drops the time (no duration is captured).
FILEDB='--tiffinbox.jdbc-url=jdbc:h2:./data/tiffinbox'
L_RUNF=$(mine "$L_RUNL $FILEDB")                    # README.md gives the file line: the pinned run line and the key, nothing else
H2J=$(unzip -Z1 .harness/serve/tiffinbox-web/target/tiffinbox-web-1.0.0.jar | sed -n 's#^BOOT-INF/lib/\(h2-[0-9][0-9.]*\.jar\)$#\1#p')
[ -n "$H2J" ] || die "the anchor's jar carries no H2 jar"
H2="$M2/com/h2database/h2/$(printf '%s\n' "$H2J" | sed 's/^h2-//; s/\.jar$//')/$H2J"; [ -f "$H2" ] || die "$H2J is not in .m2-demo"
L_SHELL=$(mine "java $JL -cp \"\$H2\" org.h2.tools.Shell -url jdbc:h2:./data/tiffinbox -user sa -sql 'SELECT name FROM customer ORDER BY name'")
shell() { local c="cd .harness/serve && $L_SHELL"; echo "\$ $c"
  (eval "$c") < /dev/null 2>&1 | sed -E 's/^\(([0-9]+ rows?), [0-9]+ ms\)$/(\1)/' | sed 's/^/  /'; }

# ---- memory: where the data lives ------------------------------------------------------------------------------------------
memory() { local c
  echo "the anchor's database - its URL, as its application.yaml gives it:"
  c="grep -n 'jdbc' anchor/tiffinbox-web/src/main/resources/application.yaml"; echo "\$ $c"; (eval "$c") | sed 's/^/  /'
  echo "the SQL TiffinBox writes by hand - every Java source of the anchor read by harness/sql.py, the files that hold any:"
  c="python3 harness/sql.py anchor/$CORE/*.java anchor/$WEB/*.java"; echo "\$ $c"
  (eval "$c") > .harness/sql.out
  awk '/^[A-Za-z]+\.java: / { f = ($2 != "0") } f' .harness/sql.out | sed 's/^/  /'
  echo "  files read: $(grep -c '^[A-Za-z]*\.java: ' .harness/sql.out) · files that hold SQL: $(grep '^[A-Za-z]*\.java: ' .harness/sql.out | grep -vc ': 0 SQL strings$' || true) · SQL strings in all: $(grep '^[A-Za-z]*\.java: ' .harness/sql.out | awk '{ s += $2 } END { print s + 0 }')"
  echo "the anchor's repository class - its declaration and the annotation above it:"
  c="grep -n -B1 '^public .*class CustomerRepository' anchor/$CORE/CustomerRepository.java"; echo "\$ $c"; (eval "$c") | sed 's/^/  /'
  echo "  files named JdbcCustomerRepository.java in the anchor: $(find anchor/ -name JdbcCustomerRepository.java | wc -l | tr -d ' ') · the name JdbcCustomerRepository in its sources: $(grep -rl JdbcCustomerRepository anchor/tiffinbox-core/src anchor/tiffinbox-web/src | wc -l | tr -d ' ') files"
  echo "Course 2's JDBC lesson (\$C2) - its title, its repository class, its database's URL:"
  c="sed -n 1p \$C2/README.md | sed 's/^# [^ ]* - //; s/^# [^ ]* — //; s/ (JDK.*\$//'"; echo "\$ $c"; (eval "$c") | sed 's/^/  /'
  c="grep -n '^public .*class JdbcCustomerRepository' \$C2/src/main/java/JdbcCustomerRepository.java"; echo "\$ $c"; (eval "$c") | sed 's/^/  /'
  c="grep -n 'String URL' \$C2/src/main/java/Db.java"; echo "\$ $c"; (eval "$c") | sed 's/^/  /'
  echo "  which is which: the anchor's $(sed -n 's/^ *jdbc-url: //p' anchor/tiffinbox-web/src/main/resources/application.yaml | sed 's/^jdbc:h2:mem:.*/in memory (jdbc:h2:mem:)/; s/^jdbc:h2:\.\/.*/a file (jdbc:h2:.\/ - a path on disk)/') · Course 2's $(sed -n 's/.*String URL *= *"\([^"]*\)".*/\1/p' "$C2/src/main/java/Db.java" | sed 's/^jdbc:h2:mem:.*/in memory (jdbc:h2:mem:)/; s/^jdbc:h2:\.\/.*/a file (jdbc:h2:.\/ - a path on disk)/')"
  echo "the seven, first, on a fresh JVM (port 19612):"
  start "$(at .harness/serve 19612 "$R_RUN")"; up 19612; ready 19612
  seven 19612 .harness/serve
  echo "the first JVM (port 19610) - the customers; Kavya added; the customers; Kavya:"
  start "$(at .harness/serve 19610 "$R_RUN")"; up 19610; ready 19610
  askj "$R_GET" 19610; names 19610
  askj "$L_ADD" 19610
  askj "$R_GET" 19610; names 19610
  askj "$L_KAVYA" 19610
  stop 19610 .harness/serve
  echo "the restart - the same tree, the same jar, a new JVM (port 19611) - the customers; Kavya:"
  start "$(at .harness/serve 19611 "$R_RUN")"; up 19611; ready 19611
  askj "$R_GET" 19611; names 19611
  askj "$L_KAVYA" 19611
  stop 19611 .harness/serve
  echo "C (labelled) - the same two JVMs, the database a file: Course 2's URL by flag, one more option on the same run line:"
  rm -rf .harness/serve/data
  start "$(at .harness/serve 19610 "$R_RUN") $FILEDB"; up 19610; ready 19610
  names 19610
  askj "$L_ADD" 19610
  names 19610
  stop 19610 .harness/serve
  echo "  the folder data/ now: $(ls .harness/serve/data | paste -sd' ' -)"
  echo "between the two JVMs - the file, read by H2's own shell (\$H2: the H2 jar the anchor's jar carries, from \$M2):"
  shell
  start "$(at .harness/serve 19611 "$R_RUN") $FILEDB"; up 19611; ready 19611
  names 19611
  askj "$L_KAVYA" 19611
  stop 19611 .harness/serve
  echo "after the restart - the file, read again:"
  shell
  echo "  listening on 19610, 19611, 19612 now: $(( $(listeners 19610) + $(listeners 19611) + $(listeners 19612) )) · on 19619: $(listeners 19619)"; }

# ---- readme: the repository's front page, and the Course 5 capture that reads it -----------------------------------------------
# view: the lines Course 5's finale's readme capture hashes - the title (line 1), the folders lines 1-5 map, the course sections,
# the roadmap line - read from the README on standard input
view() { awk '{ print }' > .harness/view.md
  echo "  line 1: $(sed -n 1p .harness/view.md)"
  echo "  the folders its opening maps (lines 1-5): $(sed -n 1,5p .harness/view.md | grep -oE '`(c[0-9]-)?unitNN/`' | tr -d '`' | paste -sd' ' -)"
  echo "  its course sections: $(grep -E '^## Course [0-9]+ — ' .harness/view.md | sed 's/^## Course \([0-9]*\) — .*/\1/' | paste -sd' ' -)"
  echo "  its roadmap line: $(grep -n '^Videos publish' .harness/view.md)"; }
readmecap() { local c
  echo "the repository's README, as the commit before this unit's had it (the last commit of Course 6's capstone):"
  echo "\$ git -C .. show $PIN:README.md"; git -C .. show "$PIN:README.md" | view
  echo "and as it is now:"
  echo "\$ cat ../README.md"; view < ../README.md
  git -C .. show "$PIN:README.md" | grep '^Videos publish' > .harness/road-was.txt; grep '^Videos publish' ../README.md > .harness/road-now.txt
  echo "  the roadmap line, the same before and now: $(cmp -s .harness/road-was.txt .harness/road-now.txt && echo yes || echo no)"
  echo "  lines the README gained: $(git -C .. show "$PIN:README.md" | diff - ../README.md | grep -c '^>' || true) · lines it lost: $(git -C .. show "$PIN:README.md" | diff - ../README.md | grep -c '^<' || true)"
  echo "its Course 6 section, whole:"
  awk '/^## Course 6 — /{ f = 1 } f && /^$/ { exit } f { print "  " $0 }' ../README.md
  echo "Course 5's finale's readme capture (\$C5) - the README reads in its receipts.sh, and its readme function re-run from there:"
  c="grep -c 'git -C \.\. show $PIN:README.md' \$C5/receipts.sh"; echo "\$ $c"; (eval "$c") | sed 's/^/  /'
  c="sed -n '/^readmecap() {/,/; }\$/p' \$C5/receipts.sh | grep -c '\.\./README\.md'"; echo "\$ $c"; (eval "$c" || true) | sed 's/^/  /'
  sed -n '/^readmecap() {/,/; }$/p' "$C5/receipts.sh" > .harness/c5-readmecap.sh
  ( cd "$C5" && eval "$(cat "$U/.harness/c5-readmecap.sh")" && readmecap ) > .harness/c5-readme.out 2>&1 || die "Course 5's readme function failed: $(tail -3 .harness/c5-readme.out)"
  echo "  its readme function, run in its own folder: $(wc -l < .harness/c5-readme.out | tr -d ' ') lines · md5 $(md5 -q .harness/c5-readme.out) · its receipts.md5's readme: $(awk '$1 == "readme" { print $2 }' "$C5/receipts.md5") · the same: $([ "$(md5 -q .harness/c5-readme.out)" = "$(awk '$1 == "readme" { print $2 }' "$C5/receipts.md5")" ] && echo yes || echo no)"
  echo "  its title line, as it reads it: $(grep -A1 '^\$ git -C \.\. show [0-9a-f]*:README\.md | sed -n 1p$' .harness/c5-readme.out | tail -1 | sed 's/^ *//')"; }

cap memory memory
cap readme readmecap

echo
# ---- every number the video says, asserted. Each check reads a line a program computed - a count, a status, a hash - never a
# ---- label this script prints unconditionally, and names the words it pays for.
x() { grep -qE -- "$2" ".r-$1.out" || die "$1: expected /$2/"; }
has() { printf '%s\n' "$1" | grep -qxF -- "$2" || die "$3: expected the line: $2"; }
cnt() { printf '%s\n' "$1" | grep -cxF -- "$2" || true; }
blk() { awk -v a="$2" -v b="$3" 'index($0, a) == 1 { f = 1; next } b != "" && index($0, b) == 1 { f = 0 } f' ".r-$1.out"; }
S466='466c20ed7e0d5439cb052f32ce09de1b'
for f in .harness/raw-*; do [ "$(cat "$f")" = 0 ] || die "a capture's raw output held the demo token ($f)"; done
for f in .r-*.out README.md receipts.md5 harness/shutdown.sh harness/sql.py ../README.md; do [ -f "$f" ] || die "missing: $f"
  [ "$(raw "$TOKEN" "$f")" = 0 ] || die "$f holds the demo token, raw"; done
for f in .r-*.out; do ! grep -qE '/Users/|/private/|/home/|/var/folders/' "$f" || die "$f holds an absolute path"; ! grep -qE 'c[0-9]-unit[0-9]|unit ?[0-9]' "$f" || die "$f holds a unit number"; ! grep -qE ' (with PID|started by) ' "$f" || die "$f holds Boot's process line"; ! grep -qE '^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T' "$f" || die "$f holds a log line's time"; ! grep -q "^$(printf '\t')at " "$f" || die "$f shows a stack frame"; ! grep -q 'offline: no' "$f" || die "$f: a build went online"
  ! grep -qE ' using Java [0-9]' "$f" || die "$f holds the JDK's version (R.151)"; ! grep -qE 'http-nio-127\.0\.0\.1-[0-9]' "$f" || die "$f holds a connector's port (S6.22)"; done
# every java line on a capture carries the JVM's locale (S6.1)
! grep -hE '^\$ (cd [^ ]+ && )?java ' .r-*.out | grep -v -- "java $JL " | grep -q . || die "a java line without $JL (S6.1)"
echo "  token: 0 raw copies in $(ls .harness/raw-* | wc -l | tr -d ' ') raw capture runs, in $(ls .r-*.out | wc -l | tr -d ' ') captures, in the logs of every run that served ($LOGS counted here), this README, the harness, the repository's README and receipts.md5; no absolute path, no unit number, no process line, no log time, no stack frame, no JDK version, no connector port, no build that went online in any capture; every java line pinned to $JL"

# "The anchor keeps its customers in H2, in memory." - the URL, read off application.yaml, and what it is
x memory '^  [0-9]+:  jdbc-url: jdbc:h2:mem:tiffinbox;DB_CLOSE_DELAY=-1$'
x memory '^  which is which: the anchor.s in memory \(jdbc:h2:mem:\) · Course 2.s a file \(jdbc:h2:\./ - a path on disk\)$'
# "The SQL is written by hand: five strings in the repository, six in Database, which makes the two tables." (counted)
x memory '^  CustomerRepository\.java: 5 SQL strings$'
x memory '^  Database\.java: 6 SQL strings$'
x memory '^    the tables its CREATE TABLE strings make: 2 - customer, pause$'
x memory '^  files read: [0-9]+ · files that hold SQL: 2 · SQL strings in all: 11$'
# R.162: the anchor's class is CustomerRepository, a @Component; Course 2's is JdbcCustomerRepository, on a file database
x memory '^  [0-9]+-@Component$'
x memory '^  [0-9]+:public final class CustomerRepository \{$'
x memory '^  files named JdbcCustomerRepository\.java in the anchor: 0 · the name JdbcCustomerRepository in its sources: 0 files$'
x memory '^  [0-9]+:public final class JdbcCustomerRepository implements Repository<Customer, Long> \{$'
x memory '^  [0-9]+: +public static final String URL += "jdbc:h2:\./data/tiffinbox";$'
x memory '^  TiffinBox on a Real Database: The JDBC Repository$'
echo "  memory, where: the anchor jdbc:h2:mem: (in memory), CustomerRepository @Component, 5 SQL strings + Database 6 (2 tables) = 11 in 2 files; Course 2's JdbcCustomerRepository on jdbc:h2:./data/tiffinbox (a file), 0 of it in the anchor"
# the seven first, on a fresh JVM: the capstone's set
SV=$(blk memory 'the seven, first' 'the first JVM')
has "$SV" "  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 0 · md5 $S466" "memory: the seven, $S466"
# "Add a customer: two-oh-one, five names. Restart: four names, and Kavya is a four-oh-four."
M1=$(blk memory 'the first JVM' 'the restart'); M2=$(blk memory 'the restart' 'C (labelled)')
[ "$(printf '%s\n' "$M1" | grep -c '^  its names: ')" = 2 ] && [ "$(printf '%s\n' "$M2" | grep -c '^  its names: ')" = 1 ] || die "memory: two lists in the first JVM, one in the restart"
has "$M1" '  its names: Meera Priya Ravi Sunil · 4 customers · 200' "memory: four before the add"
has "$M1" '  {"mealType":"VEG","mealsPerDay":1,"name":"Kavya","pricePerMeal":100} 201    (keys sorted)' "memory: Kavya added, 201"
has "$M1" '  its names: Kavya Meera Priya Ravi Sunil · 5 customers · 200' "memory: five after the add"
has "$M1" "\$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19610/customers/Kavya" "memory: Kavya asked, the first JVM"
[ "$(printf '%s\n' "$M1" | grep -A1 -xF "\$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19610/customers/Kavya" | tail -1)" = '  {"mealType":"VEG","mealsPerDay":1,"name":"Kavya","pricePerMeal":100} 200    (keys sorted)' ] || die "memory: Kavya 200 in the first JVM"
has "$M2" '  its names: Meera Priya Ravi Sunil · 4 customers · 200' "memory: four after the restart"
K404=$(printf '%s\n' "$M2" | grep -A1 -xF "\$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19611/customers/Kavya" | tail -1)
printf '%s\n' "$K404" | grep -qE '^  \{.*"status":404.*\} 404' || die "memory: Kavya 404 after the restart (got: $K404)"
[ "$(printf '%s\n' "$M1" | grep -c '^\$ cd \.harness/serve && java ')" = 1 ] && [ "$(printf '%s\n' "$M2" | grep -c '^\$ cd \.harness/serve && java ')" = 1 ] || die "memory: one JVM each"
[ "$(printf '%s\n' "$M1" | grep '^\$ cd \.harness/serve && java ' | sed 's/19610/P/')" = "$(printf '%s\n' "$M2" | grep '^\$ cd \.harness/serve && java ' | sed 's/19611/P/')" ] || die "memory: the restart is the first JVM's command, its port aside"
[ "$(grep -c '^  exit 0 · listening on 1961[01] now: 0$' .r-memory.out)" = 4 ] || die "memory: four JVMs stopped, exit 0"
[ "$(grep -c '^  POST /shutdown -> 200 ' .r-memory.out)" = 4 ] || die "memory: POST /shutdown 200 four times"
x memory '^  listening on 19610, 19611, 19612 now: 0 · on 19619: 0$'
[ "$(grep -c '^  listens on: 127\.0\.0\.1:1961[012] · loopback only: yes$' .r-memory.out)" = 5 ] || die "memory: five JVMs, loopback only"
[ "$(grep -c "^  its log: the demo token 0 times · X-Shutdown-Token 0 times · WARN lines: [0-9]* · ERROR lines: 0$" .r-memory.out)" = 5 ] || die "memory: five logs, 0 ERROR"
# C (labelled): "Even in a file, she's gone: TiffinBox's own start drops both tables and seeds four customers." - the file held
# five names between the JVMs (H2's shell), the restart lists four and answers Kavya 404, and the file then holds four
! grep -qE '[0-9] ms\)' .r-memory.out || die "memory: H2's shell time not cut"
MC=$(blk memory 'C (labelled)' '  listening on 19610')
[ "$(printf '%s\n' "$MC" | grep -c '^  its names: ')" = 3 ] || die "memory C: three lists"
has "$MC" "\$ cd .harness/serve && ${L_RUNL/18431/19610} $FILEDB" "memory C: the run line and Course 2's URL"
has "$MC" '  its names: Kavya Meera Priya Ravi Sunil · 5 customers · 200' "memory C: five after the add"
has "$MC" '  the folder data/ now: tiffinbox.mv.db' "memory C: the file"
CB=$(printf '%s\n' "$MC" | awk '/^between the two JVMs/ { f = 1; next } /secrets\/ before the start/ { f = 0 } f')
has "$CB" '  NAME' "memory C: the shell's column"; has "$CB" '  (5 rows)' "memory C: five rows in the file between the JVMs"; has "$CB" '  Kavya' "memory C: Kavya in the file"
has "$MC" '  its names: Meera Priya Ravi Sunil · 4 customers · 200' "memory C: four after the restart"
printf '%s\n' "$MC" | grep -A1 -xF "\$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19611/customers/Kavya" | tail -1 | grep -qE '^  \{.*"status":404.*\} 404' || die "memory C: Kavya 404 after the restart"
CA=$(printf '%s\n' "$MC" | awk '/^after the restart/ { f = 1; next } f')
has "$CA" '  (4 rows)' "memory C: four rows after the restart"; [ "$(printf '%s\n' "$CA" | grep -c '^  Kavya$')" = 0 ] || die "memory C: no Kavya after the restart"
echo "  memory C: a file database (jdbc:h2:./data/tiffinbox): Kavya 201, 5 names; the file holds 5 rows between the JVMs; the restart: 4 names, Kavya 404, the file 4 rows - Database's start drops and re-seeds"
echo "  memory, the hand-off: the seven $S466 first; the first JVM 4 names -> Kavya 201 -> 5 names -> Kavya 200; the restart (the same command, its port aside) 4 names, Kavya 404; 3 JVMs loopback, 0 ERROR, every port free"

# The front page: Course 6 joined it; Course 5's capture still reads the README Course 5 left (R.163)
RW=$(blk readme 'the repository' 'and as it is now'); RN=$(blk readme 'and as it is now' 'its Course 6 section')
has "$RW" '  the folders its opening maps (lines 1-5): unitNN/ c2-unitNN/ c3-unitNN/ c4-unitNN/ c5-unitNN/' "readme: the folders before"
has "$RW" '  its course sections: 2 3 4 5' "readme: the sections before"
has "$RN" '  the folders its opening maps (lines 1-5): unitNN/ c2-unitNN/ c3-unitNN/ c4-unitNN/ c5-unitNN/ c6-unitNN/' "readme: the folders now"
has "$RN" '  its course sections: 2 3 4 5 6' "readme: the sections now"
printf '%s\n' "$RN" | grep -qE '^  line 1: # TiffinBox — code for .*\*Spring Boot\* and \*Spring Web MVC\* \(Learn Programming with Vivek\)$' || die "readme: the title names Spring Web MVC"
has "$RN" '  the roadmap line, the same before and now: yes' "readme: the roadmap line unchanged"
x readme '^  ## Course 6 — Spring Web MVC$'
x readme '^  \*\*TiffinBox on Spring MVC\*\*, in `c6-unitNN/` \([0-9]+ units, [0-9]+ sections\), with the long-lived project in `c6-tiffinbox/`'
grep -qxF "\$ grep -c 'git -C \\.\\. show $PIN:README.md' \$C5/receipts.sh" .r-readme.out || die "readme: the pinned reads' grep line"
[ "$(grep -A1 "^\\\$ grep -c 'git -C" .r-readme.out | tail -1)" = '  7' ] || die "readme: Course 5's capture reads the pinned commit on seven lines"
[ "$(grep -A1 "^\\\$ sed -n '/^readmecap" .r-readme.out | tail -1)" = '  0' ] || die "readme: Course 5's readme function reads ../README.md 0 times"
x readme '^  its readme function, run in its own folder: [0-9]+ lines · md5 ([0-9a-f]{32}) · its receipts\.md5.s readme: \1 · the same: yes$'
echo "  readme: before c5-unitNN/ last, sections 2-5; now + c6-unitNN/, section 6, the title names Spring Web MVC, the roadmap line unchanged; Course 5's capture pinned to $PIN (7 lines read it, 0 read ../README.md), re-run = its published md5"

cmp -s anchor/README.md ../c6-tiffinbox/README.md || echo "  (anchor/README.md and ../c6-tiffinbox/README.md differ - the anchor has moved past this unit's tree)" >&3
[ -z "$unpub" ] || die "no published hash for:$unpub - check the captures, then copy the md5s above into receipts.md5 and run again"
echo "c6-unit32: every capture 3/3 and = published; every spoken number asserted; 0 raw demo tokens in every capture and every run's log"
