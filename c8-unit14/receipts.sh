#!/bin/bash
XPATH=$PATH                                           # the PATH you started this with: the exercise's own shells get it
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
# Course 8 · Redis Data Structures From Java - this unit's receipts. Section 3's FIRST anchor change (C1): before/ is a link to
# ../c8-unit13/after (unit 13's tree), after/ is this unit's tree and ../c8-tiffinbox equals it from this unit's commit on. Section 3
# starts here: Redis as a datastore, under the profile "dev" - Leaderboard.java (new, @Profile("dev"), StringRedisTemplate, GET
# /leaderboard), TiffinBoxServer.start() filling it (reset, then one ZINCRBY per order), KitchenHealthIndicator.java's and
# compose.yaml's notes, application-dev.yaml's note, tiffinbox-web/pom.xml's Redis test starter, slice/RedisSlice and RedisDatastoreIT.
# Two witnesses for every Redis number (R.398): Java's answer (the shipped Leaderboard's route, or a template bean of the context) and
# redis-cli inside the Redis container (docker exec, the image's own client), run while a harness JVM waits at a pause; psql
# (PostgreSQL's own client) renames the table for #119.
# Captures (the JVM ones run three times and hashed; exercise once per run of record - its 3/3 is across the runs; the tests once per
# run of record too, folded into anchor):
#   exercise   exercise/README.md's lines, then SOLUTION.md's, as written, in ONE env -i shell - bash, then zsh -f (Redis by the digest)
#   anchor     the tests; the libraries; after/ under "dev" on PostgreSQL + Redis, three starts in a row against one Redis, the
#              third ended by SIGINT (exit 130)
#   zset       after/ under "dev": the shipped board by Java (the route, StringRedisTemplate) and by redis-cli; the sum beside /kitchen
#   flip       the harness's keys h14:z<n>, h14:z<n+1>, n read off CONFIG GET zset-max-listpack-entries - labelled the harness's
#   structs    the harness's hash, set and counter - labelled the harness's
#   twice      the shipped Leaderboard.record called twice with no reset between, by the harness - labelled
#   trap       the same fill through Boot's redisTemplate bean on a clean key: the bytes redis-cli reads - labelled the harness's
#   absent     after/'s jar under "dev", PostgreSQL up, Redis absent (a port nothing listens on): the start stops, exit 1
#   default    after/ with no profile on H2, no Docker, Redis absent: health 200, /leaderboard 404, no Leaderboard bean
#   notes      the three files NOT edited (md5 against this repository's 3478b30), the quoted lines, #119 re-measured on PostgreSQL
#   seven      the comparison set on before/'s and after/'s jars (H2; after/ on 20530, before/ on 20533); Hibernate's script
# Every tree is COPIED under .harness/ and built there, offline (-o, from .m2-demo, a copy of the course's seed, maven.repo.local
# absolute), every module from the tree's own sources (-pl tiffinbox-web -am, R.391). Every JVM and Maven run under an alarm (R.247),
# every JVM with SIGINT reset to its default (R.410). Every docker call names its socket (dk, R.344), --pull never; every container is
# removed with its volume (rm -fv, R.387).
# Ports (20530-20539): 20530 TiffinBox after/ (the harness's web server; the seven) · 20531 the PostgreSQL container · 20532 the Redis
# container (and the exercise's own Redis, which runs before it) · 20533 TiffinBox before/ for the seven (a second port, so the two
# jars never share one) · 20539 the port "Redis absent" points at, asserted unbound · 20534-20538 spare, never bound.
shopt -u patsub_replacement 2> /dev/null || true
export LC_ALL=C
cd "$(dirname "$0")"
mkdir .r-lock 2> /dev/null || { echo "  *** another receipts.sh is running in this folder (.r-lock exists) - if none is, rmdir .r-lock ***"; exit 1; }
U="$PWD"; UP="$(cd .. && pwd)"; ME="$(id -un)"; G=/usr/bin/grep
IMG=postgres@sha256:77f585114c32fbca283dc835b0596f4e52b51b4c6662d7810b2f4084f60a1873
RIMG=redis@sha256:7958cfbb9d152f87dadfbc89f1b0b15938f0b81ff8982feb327476f4911935c3
CN=c8u14-pg; RN=c8u14-redis; EN=c8u14-ex
DH="unix://$HOME/.orbstack/run/docker.sock"           # the docker socket, pinned (R.344): OrbStack's on the author's Mac - point it at yours
dk() { docker -H "$DH" "$@"; }
pid=""; mpid=""; xpid=""; CSTARTED=""; RSTARTED=""; TC0=""; INTR=""
sweep() { local g i l
  g=$(ps -o pgid= -p $$ 2> /dev/null | tr -d ' ') || g=""
  [ -n "$g" ] || return 0
  i=0; while [ $i -lt 20 ]; do
    l=$(ps -axo pid=,pgid=,command= 2> /dev/null | awk -v g="$g" -v me=$$ '
      $2 == g && $1 != me && $3 != "awk" && $3 != "ps" && (index($0, "probe.u14.") || index($0, "probe.x.") || index($0, "tiffinbox-web-1.0.0.jar") || index($0, "curlset.sh") || index($0, "surefirebooter") || index($0, "org.codehaus.plexus.classworlds.launcher.Launcher") || $3 ~ /(^|\/)javac$/ || index($0, "ex-drive.sh") || index($0, " Board ")) { print $1 }' | paste -sd' ' -) || l=""
    [ -n "$l" ] || return 0
    if [ $i -lt 10 ]; then kill $l 2> /dev/null || true; else kill -9 $l 2> /dev/null || true; fi
    sleep 0.5; i=$((i + 1)); done; }
desc() { ps -axo pid=,ppid= 2> /dev/null | awk -v r="$1" '{ p[$1] = $2 } END { n = 1; q[1] = r; for (i = 1; i <= n; i++) for (c in p) if (p[c] == q[i]) { q[++n] = c; print c } }'; }
killtree() { local d; d=$(desc "$1"); kill "$1" $d 2> /dev/null || true; }
tcrm() { local c n=0 i=0; [ -n "$TC0" ] || return 0
  while [ $i -lt 10 ]; do
    for c in $(dk ps -aq --filter label=org.testcontainers=true 2> /dev/null); do dk rm -fv "$c" > /dev/null 2>&1 && n=$((n + 1)); done
    [ -z "$(dk ps -aq --filter label=org.testcontainers=true 2> /dev/null)" ] && break; sleep 0.5; i=$((i + 1)); done
  [ "$n" = 0 ] || echo "  the trap: $n Testcontainers container(s) removed with their volumes (rm -fv)" >&3; }
ctrm() { [ -n "$TC0" ] || return 0
  [ -z "$(dk ps -aq --filter name=^/$EN\$ 2> /dev/null)" ] || dk rm -fv "$EN" > /dev/null 2>&1 || true
  [ -z "$RSTARTED" ] || { dk rm -fv "$RN" > /dev/null 2>&1 || true; RSTARTED=""; }
  [ -z "$CSTARTED" ] || { dk rm -fv "$CN" > /dev/null 2>&1 || true; CSTARTED=""; }; }
trap 'trap "" INT TERM; for p in "$mpid" "$xpid" "$pid"; do [ -z "$p" ] || killtree "$p"; done; for p in "$pid" "$mpid" "$xpid"; do if [ -n "$p" ] && kill "$p" 2> /dev/null; then wait "$p" 2> /dev/null || true; fi; done; sweep || true; tcrm; ctrm; [ -z "$INTR" ] || rm -f .r-*.[123]; rmdir .r-lock 2> /dev/null || true' EXIT
trap 'INTR=1; exit 130' INT TERM
exec 3>&1
die() { echo "  *** $* ***" >&3; exit 1; }
java -version 2>&1 | $G -q 'version "25' || die "JDK 25 needed; JAVA_HOME gives: $(java -version 2>&1 | head -1)"
javac -version 2>&1 | $G -q '^javac 25' || die "javac 25 needed (the harness is compiled with it)"
for t in python3 perl rsync lsof mvn md5 cmp diff find curl openssl docker git javap /bin/zsh; do command -v $t > /dev/null || die "$t is needed"; done
for v in $(env | sed -n -E 's/^(TIFFINBOX_[A-Za-z0-9_]*|SPRING_[A-Za-z0-9_]*|MANAGEMENT_[A-Za-z0-9_]*|SERVER_[A-Za-z0-9_]*|LOGGING_[A-Za-z0-9_]*|FLYWAY_[A-Za-z0-9_]*|TESTCONTAINERS_[A-Za-z0-9_]*|PG[A-Z]*|REDIS[A-Z_]*|DEBUG|JAVA_TOOL_OPTIONS|JDK_JAVA_OPTIONS|_JAVA_OPTIONS|MAVEN_ARGS|MAVEN_OPTS|DOCKER_HOST|DOCKER_CONTEXT|COMPOSE_[A-Z_]*)=.*/\1/p'); do unset "$v"; done
export no_proxy="127.0.0.1,localhost${no_proxy:+,$no_proxy}" NO_PROXY="127.0.0.1,localhost${NO_PROXY:+,$NO_PROXY}"

# ---- gates before anything is written: the folder, the links, the pins, the prose, the change, R.250, the notes ------------------
[ "$(ls -A | $G -vxE '\.m2-demo|\.harness|\.r-lock|\.r-.*' | paste -sd' ' -)" = 'README.md after before exercise harness receipts.md5 receipts.sh xcheck.sql' ] || die "this folder holds another file, or misses one: $(ls -A | paste -sd' ' -)"
[ "$(ls harness | paste -sd' ' -)" = 'chk14.py dur8.py logback.xml s814.py src surefire.py tree14.py variants.py' ] && [ "$(cd harness/src && find . -type f | sed 's#^\./##' | sort | paste -sd' ' -)" = 'probe/u14/U14.java probe/x/XMain.java' ] || die "harness/ holds another file, or misses one"
[ "$(ls exercise | paste -sd' ' -)" = 'Board.java README.md SOLUTION.md' ] || die "exercise/ holds another file, or misses one"
cmp -s harness/dur8.py ../c8-unit02/harness/dur8.py || die "harness/dur8.py is not the builders' dur8.py as unit 02 shipped it, byte for byte"
cmp -s harness/surefire.py ../c8-unit02/harness/surefire.py || die "harness/surefire.py is not unit 02's, byte for byte"
cmp -s harness/logback.xml ../c8-unit07/harness/logback.xml || die "harness/logback.xml is not unit 07's, byte for byte"
cmp -s harness/src/probe/x/XMain.java ../c7-unit29/harness/src/probe/x/XMain.java || die "harness/src/probe/x/XMain.java is not Course 7 unit 29's, byte for byte"
cmp -s xcheck.sql ../c7-unit39/xcheck.sql || die "xcheck.sql must be Course 7's capstone's, byte for byte (unit 14 moves no JPA mapping)"
[ -L before ] && [ "$(readlink before)" = ../c8-unit13/after ] || die "R.211: before must be a link to ../c8-unit13/after (it points at: $(readlink before 2> /dev/null || echo 'not a link'))"
[ -d after ] && [ ! -L after ] || die "after/ must be this unit's own tree, not a link"
for t in after before; do [ -e "$t/secrets" ] || [ -e "$t/target" ] || [ -e "$t/tiffinbox-web/target" ] || [ -e "$t/tiffinbox-core/target" ] && die "$t holds a secrets/ or a target/ - never built in place"; true; done
git rev-parse -q --verify '3478b30^{commit}' > /dev/null 2>&1 || die "unit 13's commit 3478b30 is not in this repository's history"
pin() { local nm=$1 dir=$2 got want; got=$(python3 -I harness/tree14.py "$dir/") || die "$dir's tree could not be hashed"
  want=$(awk -v n="$nm" '$1 == n { print $2, $3 }' receipts.md5)
  [ -n "$want" ] || die "receipts.md5 has no $nm line - the pin is written from a run's own output"
  [ "$got" = "$want" ] || die "R.211: $dir/'s tree is $got, the pin in receipts.md5 is $want - the tree moved"
  echo "  $dir/ ($3): python3 -I harness/tree14.py $dir/ -> $got = receipts.md5's $nm line"; }
pin before-tree before start; pin after-tree after start
U13P=$(awk '$1 == "after-tree" { print $2, $3 }' ../c8-unit13/receipts.md5)
[ "$U13P" = "$(awk '$1 == "before-tree" { print $2, $3 }' receipts.md5)" ] || die "before/'s pin is not unit 13's after-tree line ($U13P)"
echo "  before/'s pin = ../c8-unit13/receipts.md5's after-tree line ($U13P), re-derived by harness/tree14.py"
AD=$(diff -rq -x .m2-demo -x target -x secrets -x .harness after ../c8-tiffinbox 2>&1 || true)
echo "  after/ against ../c8-tiffinbox: $( [ -z "$AD" ] && echo 'diff -rq empty - the anchor' || echo 'they differ - a later unit moved the anchor; this unit measures after/')"
echo "  after/ against before/ (diff -rq, the files C1 changed):"; diff -rq before/ after/ 2>&1 | sed -E 's#^Files before/(.*) and after/.* differ$#    changed: \1#; s#^Only in after/(.*): (.*)$#    new: \1/\2#; s#^Only in before/(.*): (.*)$#    gone: \1/\2#'
for f in tiffinbox-web/src/main/java/com/tiffinbox/web/RedisCaching.java tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxApp.java tiffinbox-web/src/main/java/com/tiffinbox/web/KitchenMetrics.java tiffinbox-core/src/main/java/com/tiffinbox/CustomerRepository.java tiffinbox-core/src/main/java/com/tiffinbox/Dashboard.java tiffinbox-web/src/main/resources/application.yaml pom.xml tiffinbox-core/pom.xml; do
  [ "$(md5 -q "after/$f")" = "$(md5 -q "before/$f")" ] || die "C1 leaves $f untouched: after/'s differs from before/'s"
  echo "  after/$f: md5 $(md5 -q "after/$f") = before/'s (untouched)"; done
KH=tiffinbox-web/src/main/java/com/tiffinbox/web/KitchenHealthIndicator.java
echo "  after/$KH: md5 $(md5 -q "before/$KH") (before/) -> $(md5 -q "after/$KH") (after/) - #119's note, in place"
# the files this unit does NOT edit (⚑11), against this repository's own commit of unit 13 - never a typed md5
for f in c8-unit09/exercise/README.md c8-unit09/exercise/SOLUTION.md c8-unit11/README.md c8-unit12/pinned.txt; do
  [ "$(md5 -q "../$f")" = "$(git show "3478b30:$f" | md5 -q)" ] || die "⚑11: ../$f is not the file this repository held at 3478b30 - it is never edited here"; done
PROSE='README.md exercise/README.md exercise/SOLUTION.md'
DW=$(python3 -I -B harness/s814.py harness/dur8.py $PROSE) || die "the prose gate did not run (or its self-test failed): $(printf '%s\n' "$DW" | tail -2 | paste -sd';' -)"
printf '%s\n' "$DW" | tail -1 | $G -qE '^self-test: [0-9]+ cases · refused: 0$' || die "a refused word or reading in this unit's prose: $(printf '%s\n' "$DW" | $G ' line ' | head -4 | paste -sd';' -)"
YC=$(for f in $KH compose.yaml tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java tiffinbox-web/src/main/resources/application-dev.yaml tiffinbox-web/pom.xml; do diff "before/$f" "after/$f" | $G '^>' || true; done; cat after/tiffinbox-web/src/main/java/com/tiffinbox/web/Leaderboard.java after/tiffinbox-web/src/test/java/slice/RedisSlice.java after/tiffinbox-web/src/test/java/com/tiffinbox/web/RedisDatastoreIT.java)
YD=$(printf '%s\n' "$YC" | python3 -I -B -c 'import importlib.util,sys; s=importlib.util.spec_from_file_location("d","harness/dur8.py"); m=importlib.util.module_from_spec(s); s.loader.exec_module(m); print(len(m.DUR.findall(sys.stdin.read())))')
[ "$YD" = 0 ] || die "R.402: dur8 finds $YD duration word(s) in the lines C1 added (the Javadoc, the comments, the new classes)"
DISH='thali|khichdi|dal|daal|paneer|biryani|roti|chapati|chapatti|naan|sabzi|sabji|idli|dosa|sambar|rasam|rajma|chole|chana|poha|upma|paratha|pulao|pulav|raita|korma|tikka|masala|samosa|pakora|pakoda|halwa|kheer|jalebi|ladoo|laddu|vada|bhaji|aloo|gobi|jain'
DN=$($G -rniwE -- "$DISH" README.md exercise harness 2> /dev/null | cut -c1-120 | head -2 | paste -sd';' - || true)
[ -z "$DN" ] || die "an Indian dish name (R.215: English names only): $DN"
PH=$($G -rnE 'PENDING|PLACEHOLDER|VALUES-PENDING|\{\{[a-z]+\}\}|\bTODO\b|\bTBD\b|\bFIXME\b' README.md exercise harness/src 2> /dev/null | cut -c1-100 | head -2 | paste -sd';' - || true)
[ -z "$PH" ] || die "a placeholder in this unit's prose or harness: $PH"
for t2 in "What's Next: Not Everything Is a Relation" 'Redis as a Cache' 'Cache Invalidation' 'Conditional Caching, sync and Nulls' 'Spring Data Redis Repositories'; do $G -qF -- "*$t2*" README.md || die "R.224: README.md calls the unit back by its title: $t2"; done
! $G -q '^```java$' README.md || die "README.md holds a java block - the code is the anchor's files and the harness's"
C822=$(head -1 ../c8-unit12/pinned.txt)
$G -qF -- "> $C822" README.md || die "C8-22: README.md quotes ../c8-unit12/pinned.txt's sentence byte for byte, as a quote line"
for q in "$(sed -n '3p' ../c8-unit09/exercise/README.md)" "$(sed -n '3p' ../c8-unit09/exercise/SOLUTION.md)"; do $G -qxF -- "> $q" README.md || die "⚑11 #120: README.md quotes c8-unit09/exercise's line 3 byte for byte"; done
$G -qxF -- "> $(sed -n '515p' ../c8-unit11/README.md)" README.md && $G -qxF -- "> $(sed -n '516p' ../c8-unit11/README.md)" README.md || die "⚑11: README.md quotes c8-unit11/README.md:515-516 byte for byte, its line break kept"
block() { awk '/^```bash$/ { if (!d) { f = 1 }; next } f && /^```$/ { f = 0; d = 1 } f' "$1"; }
wib() { awk '/^What it prints/ { w = 1; next } w == 1 && /^```$/ { w = 2; next } w == 2 && /^```$/ { exit } w == 2 { print }' "$1"; }
EXQ="Your turn: the leaderboard is written, yet redis-cli finds no tiffinbox:leaderboard key and no score for Ravi. Make redis-cli read Ravi's score."
EXW=$(printf '%s\n' "$EXQ" | wc -w | tr -d ' ')
$G -qxF -- "**Your turn:** ${EXQ#Your turn: }" exercise/README.md || die "exercise/README.md: the spoken exercise line"
SETUP=$(block exercise/README.md); SOL=$(block exercise/SOLUTION.md)
[ -n "$SETUP" ] && [ -n "$SOL" ] || die "exercise/README.md or SOLUTION.md no longer gives its commands"
[ "$(diff <(printf '%s\n' "$SETUP") <(printf '%s\n' "$SOL") | $G -c '^[<>]')" = 2 ] || die "R.196: SOLUTION.md's block must be the README's with one line changed"
printf '%s\n' "$SETUP" | $G -E '(^|[ (])(mvn|java|javac) ' | $G -vqF "perl -e 'alarm " && die "exercise/README.md's Java and Maven runs must run under their alarm (R.247)"
printf '%s\n' "$SETUP" | $G -E 'mvn ' | $G -vqF -- '-pl tiffinbox-web -am' && die "R.391: exercise/README.md builds without -pl tiffinbox-web -am"
printf '%s\n' "$SETUP" | sed -E 's/echo "docker [a-z -]*: exit/echo "/g' | $G -oE '\bdocker +[^ ]+' | $G -vqxF 'docker -H' && die "R.344: exercise/README.md calls docker without the pinned socket (docker -H \"\$DH\")"
[ "$(printf '%s\n' "$SETUP" | $G -oE 'docker -H "\$DH" (run|rm)[^;>]*' | $G -c -- '--pull never\|rm -fv')" = 2 ] || die "the exercise's Redis: one docker run --pull never, one rm -fv (R.387)"
for f in exercise/README.md exercise/SOLUTION.md; do [ "$($G -c '^What it prints' "$f")" = 1 ] && [ -n "$(wib "$f")" ] || die "$f must hold one \"What it prints\" line and a block under it"; done
[ "$(wib exercise/README.md | md5 -q)" != "$(wib exercise/SOLUTION.md | md5 -q)" ] || die "R.196: the exercise's broken and solved blocks print the same"
K1='pki''ll'; K2='kill''all'; ! $G -v '^ *#' receipts.sh | $G -qwE "$K1|$K2" || die "receipts.sh names $K1 or $K2 - every process is stopped by its pid"
$G -qxF 'dk() { docker -H "$DH" "$@"; }' receipts.sh || die "R.344: dk() must name the pinned socket (docker -H \"\$DH\")"
DK=$($G -v '^ *#' receipts.sh | $G -vF '$G -' | $G -nE '\bdocker (run|exec|rm|ps|port|info|images|volume|image|pull|events|compose|network)\b' | cut -c1-100 | head -2 | paste -sd';' - || true)
[ -z "$DK" ] || die "R.344: receipts.sh calls docker without the pinned socket (every call is dk): $DK"
RMF=$($G -v '^ *#' receipts.sh | $G -vF '$G -' | $G -oE '(dk|docker) rm( +-[a-z]+)*' | sort -u | paste -sd'|' -)
[ "$RMF" = 'dk rm -fv' ] || die "R.387/R.322: receipts.sh removes a container without its volume - every removal is dk rm -fv (found: ${RMF:-none})"
RUNP=$($G -v '^ *#' receipts.sh | $G -oE '(dk|docker) run -[^"]*' | $G -vcF -- '--pull never' || true)
[ "$RUNP" = 0 ] || die "R.344: a dk run without --pull never"
MVA=$($G -v '^ *#' receipts.sh | $G -F 'clean ' | $G -F '$MV' | $G -vcF -- '-pl tiffinbox-web -am' || true)
[ "$MVA" = 0 ] || die "R.391: a Maven build in receipts.sh without -pl tiffinbox-web -am"
ST=$(python3 -I -B harness/chk14.py static after before) || die "static: $(printf '%s\n' "$ST" | $G '^FAIL' | head -3 | paste -sd';' -)"
printf '%s\n' "$ST" | $G -v '^VALUES ' | sed 's/^/  /'
R250=$(python3 -I -B harness/chk14.py r250 after before) || die "R.250: $(printf '%s\n' "$R250" | $G '^FAIL' | head -2 | paste -sd';' -)"
printf '%s\n' "$R250" | $G -v '^VALUES ' | sed 's/^/  /'
echo "  prose, per sentence (s814, $(printf '%s\n' "$DW" | tail -1 | sed -E 's/^self-test: ([0-9]+) cases.*/\1/')-case self-test): refused 0 over $PROSE · the lines C1 added (Javadoc, comments, the new classes): dur8 0 · dish names 0 · placeholders 0 · called back by title · no java block · C8-22's sentence and ⚑11's three lines quoted byte for byte; the four files never edited = this repository's 3478b30"
echo "  the exercise: the spoken line $EXW words (wc -w); SOLUTION.md's block = the README's with one line changed; the two \"What it prints\" blocks differ (R.196); its build -pl tiffinbox-web -am; its docker calls on the pinned socket, --pull never, rm -fv"
echo "  static: no kill by name; every docker call on the pinned socket, every dk run --pull never; every container removal dk rm -fv (R.387); every Maven build -pl tiffinbox-web -am (R.391)"
mask() { awk -v u="$U" -v up="$UP" -v hm="$HOME" -v me="$ME" '
  function lit(x) { gsub(/[][\\.^$*+?(){}|\/]/, "\\\\&", x); return x }
  function enc(x) { gsub(/ /, "%20", x); return x }
  BEGIN { P = lit(u); Q = lit(up); H = lit(hm); PE = lit(enc(u)); QE = lit(enc(up)); M = "(^|[^A-Za-z0-9_])" lit(me) "([^A-Za-z0-9_]|$)" }
  { gsub(P, "…"); gsub(PE, "…"); gsub(Q, "…/.."); gsub(QE, "…/.."); gsub(H, "~")
    gsub(/ in [0-9.]+ seconds \(process running for [0-9.]+\)/, " in <t> (process running for <t>)")
    gsub(/Time elapsed: [0-9.]+ s/, "Time elapsed: <t>")
    gsub(/\(execution time [0-9:.]+s\)/, "(execution time <t>)")
    gsub(/scanning in [0-9]+ ms/, "scanning in <t>")
    gsub(/initialization completed in [0-9]+ ms/, "initialization completed in <t>")
    gsub(/ started in PT[0-9.]+S/, " started in PT<t>S")
    gsub(/PT[0-9.]+[SMH]/, "PT<t>")
    gsub(/Total time: +[0-9.:]+ [a-z]+/, "Total time: <t>")
    gsub(/ using Java [0-9][0-9.]+/, " using Java <version>")
    gsub(/TTL [0-9]+/, "TTL <n>")
    gsub(/pid [0-9]+/, "pid <n>")
    gsub(/@[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]+/, "@…")
    while (match($0, M)) { pre = substr($0, 1, RSTART - 1); s = substr($0, RSTART, RLENGTH); post = substr($0, RSTART + RLENGTH)
      sub(lit(me), "<user>", s); $0 = pre s post }
    print }'; }
MP=$(printf '%s\n' 'Started TiffinBoxWebTest in 3.1 seconds (process running for 4.2)' 'Tests run: 2, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 3.982 s' 'Finished Spring Data repository scanning in 23 ms. Found 0 Redis repository interfaces.' 'Root WebApplicationContext: initialization completed in 812 ms' 'Successfully applied 3 migrations (execution time 00:00.026s)' 'Container redis@sha256:7958 started in PT0.6S' 'redis-cli TTL 2' 'Total time:  12.345 s' 'PROBE hold: pid 41231' "$U/x $HOME/y" | mask)
printf '%s\n' "$MP" | python3 -I -B -c 'import importlib.util,sys; s=importlib.util.spec_from_file_location("d","harness/dur8.py"); m=importlib.util.module_from_spec(s); s.loader.exec_module(m); t=sys.stdin.read(); sys.exit(1 if m.DUR.search(t) or "PT0" in t or "3.982" in t or "00:00.026" in t or "812" in t or "12.345" in t or "TTL 2" in t or "41231" in t else 0)' || die "R.402: the mask's self-test - a planted duration line passed it unmasked: $(printf '%s\n' "$MP" | head -2 | paste -sd';' -)"
[ "$(printf '%s\n' "$MP" | tail -1)" = '…/x ~/y' ] || die "the mask's self-test: the folders and the home must be masked"
echo "  mask: its self-test refused the planted Started-in-seconds, Time elapsed, scanning, initialization, execution-time, started-in-PT, TTL, Total time and pid lines unmasked (R.402); folders and home masked"
CURLSET=../c5-unit11/curlset.sh
[ -x "$CURLSET" ] || die "$CURLSET is missing - the comparison set the seven runs"
S466=$(sed -n "s/^S466=\([0-9a-f]*\).*/\1/p" ../c7-unit31/receipts.sh)
[ ${#S466} = 32 ] || die "the seven's md5 could not be read off ../c7-unit31/receipts.sh"

# ---- docker and ports: the baselines -------------------------------------------------------------------------------------------
dk info > /dev/null 2>&1 || die "docker -H $DH info failed - is the engine running on that socket? (R.344)"
IMGS0=$(dk images -q --no-trunc 2> /dev/null | sort | paste -sd' ' -); NI0=$(printf '%s\n' "$IMGS0" | wc -w | tr -d ' ')
VOL0=$(dk volume ls -q 2> /dev/null | wc -l | tr -d ' ')
[ "$NI0" -ge 1 ] && [ "$VOL0" -ge 1 ] || die "the baselines must not be empty - images $NI0, volumes $VOL0"
IID=$(dk image inspect --format '{{.Id}}' "$IMG" 2> /dev/null | cut -c8-19)
[ "$IID" = 77f585114c32 ] || die "the image $IMG is not on this machine (its id: ${IID:-none}) - this script never pulls; docker -H \"\$DH\" pull $IMG is yours to run"
RID=$(dk image inspect --format '{{.Id}}' "$RIMG" 2> /dev/null | cut -c8-19)
[ "$RID" = 7958cfbb9d15 ] || die "the image $RIMG is not on this machine (its id: ${RID:-none}) - this script never pulls; docker -H \"\$DH\" pull $RIMG is yours to run"
RY0=$(dk images --format '{{.Repository}}' 2> /dev/null | $G -c ryuk || true)
[ "$RY0" = 0 ] || die "R.318: an image named ryuk is on this machine ($RY0) - Ryuk stays off and none is pulled"
[ -z "$(dk ps -aq --filter label=org.testcontainers=true 2> /dev/null)" ] || die "a Testcontainers container exists before the run - remove it with its volume: docker -H \"\$DH\" rm -fv <id>"
for c in $CN $RN $EN; do [ -z "$(dk ps -aq --filter name=^/$c\$ 2> /dev/null)" ] || die "a container named $c exists before the run - an interrupted run's? docker -H \"\$DH\" rm -fv $c"; done
TC0=1
[ ! -e "$HOME/.testcontainers.properties" ] || die "R.318: ~/.testcontainers.properties exists - this unit's Testcontainers JVMs read a receipt home under .harness/ only"
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2> /dev/null | wc -l | tr -d ' '; }
PORTS="18425 8080 20530 20531 20532 20533 20534 20535 20536 20537 20538 20539"
for p in $PORTS; do [ "$(listeners $p)" = 0 ] || die "something already listens on $p - this unit's ports must be free"; done
[ "$(pgrep -x java | wc -l | tr -d ' ')" = 0 ] || die "a java process is running before this script starts one - not this script's; stop it first"
echo "  docker: -H $(printf '%s' "$DH" | sed "s#$HOME#~#") (pinned) · images $NI0 · volumes $VOL0 · $IMG present, id $IID · $RIMG present, id $RID · nothing pulled, ever · images named ryuk $RY0 · Testcontainers containers 0 · ports 20530-20539 (and 18425, 8080) free · java processes 0"

# ---- the trees, copied; the builds; the harness -------------------------------------------------------------------------------
rm -rf .harness; mkdir -p .harness/run-h2/secrets/tiffinbox .harness/run-pg/secrets/tiffinbox .harness/hc .harness/hcx .harness/home .harness/run
M2="$PWD/.m2-demo"
[ -d "$M2" ] || die ".m2-demo (a copy of the course's seed, _research/m2-seed-c8-s3) is missing - README.md, The repository"
for a in org/springframework/data/spring-data-redis/4.1.2/spring-data-redis-4.1.2.jar io/lettuce/lettuce-core/7.5.2.RELEASE/lettuce-core-7.5.2.RELEASE.jar org/springframework/boot/spring-boot-starter-data-redis-test/4.1.2 org/springframework/boot/spring-boot-data-redis-test/4.1.2 org/postgresql/postgresql/42.7.14/postgresql-42.7.14.jar; do
  [ -e "$M2/$a" ] || die "$a is not in .m2-demo - the seed lacks it (README.md, The repository)"; done
NF0=$(find "$M2" -type f | wc -l | tr -d ' ')
printf '%s\n' 'checks.disable=true' "tinyimage.container.image=$IMG" > .harness/home/.testcontainers.properties
copy() { rsync -a --exclude target --exclude secrets --exclude .m2-demo "$1/" "$2/"; }
copy before .harness/before; copy after .harness/after; copy after .harness/tests
JL='-Duser.language=en -Duser.country=US'
RE=0
bg() { RE=0; (eval "$1") > "$2" 2>&1 < /dev/null & mpid=$!; wait "$mpid" || RE=$?; mpid=""; }
offl() { [ "$($G -cE '^\[INFO\] Download(ing|ed) from ' "$1" || true)" = 0 ] || die "$1: Maven's log says it downloaded (offline: no)"; }
XD=tiffinbox-web/target/extracted
MV="env \"MAVEN_OPTS=-Duser.home=../home -Dstdout.encoding=UTF-8\" perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 600; exec @ARGV' mvn -o -B -Dmaven.repo.local=\"\$M2\""
AL="-DargLine=$JL -Dstdout.encoding=UTF-8 -Duser.home=../../home"
for t in before after; do
  bg "cd .harness/$t && $MV clean package -DskipTests -pl tiffinbox-web -am" .harness/build-$t.log
  [ "$RE" = 0 ] || { tail -20 .harness/build-$t.log >&3; die ".harness/$t did not build offline (exit $RE)"; }; offl .harness/build-$t.log
  bg "cd .harness/$t && perl -e 'alarm 120; exec @ARGV' java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination $XD" .harness/extract-$t.log
  [ "$RE" = 0 ] || die ".harness/$t: the jar's extract failed"; done
bg "javac -parameters -d .harness/hc -cp \".harness/after/$XD/tiffinbox-web-1.0.0.jar:.harness/after/$XD/lib/*\" harness/src/probe/u14/*.java" .harness/javac.log
[ "$RE" = 0 ] || die "the harness did not compile against after/: $(head -5 .harness/javac.log)"
mkdir -p .harness/lib-nofly
for j in $(ls .harness/after/$XD/lib); do case $j in flyway-*|spring-boot-flyway-*) ;; *) ln -s ../after/$XD/lib/$j .harness/lib-nofly/$j ;; esac; done
bg "javac -parameters -d .harness/hcx -cp \".harness/after/$XD/tiffinbox-web-1.0.0.jar:.harness/after/$XD/lib/*\" harness/src/probe/x/XMain.java" .harness/javac-x.log
[ "$RE" = 0 ] || die "Hibernate's schema probe did not compile: $(head -5 .harness/javac-x.log)"
TF=secrets/tiffinbox/shutdown-token
(umask 077 && printf '%s\n' "$(openssl rand -hex 16)" > .harness/run-h2/$TF) || die "the token was not written"
for d in run-pg after before; do mkdir -p .harness/$d/secrets/tiffinbox; (umask 077 && cp .harness/run-h2/$TF .harness/$d/$TF) || die "the token was not copied"; done
TOKEN=$(head -1 .harness/run-h2/$TF); [ ${#TOKEN} = 32 ] || die "the generated token is not 32 characters"
PW=$(openssl rand -hex 16); (umask 077 && printf 'POSTGRES_USER=tiffinbox\nPOSTGRES_PASSWORD=%s\n' "$PW" > .harness/pg.env) || die "the password file was not written"
echo "  built before/'s and after/'s trees offline (mvn -o package -DskipTests -pl tiffinbox-web -am, exit 0, 'Downloaded from' 0), extracted their jars, compiled the harness against after/'s; Hibernate's schema probe compiled; a shutdown token and a PostgreSQL password generated (0600, never printed)"
printf '%s\n' "  every capture of record runs the anchor's own tree, after/ (or before/ for the seven); the harness's keys (h14:…), its fills (twice, trap) and the exercise's program are labelled where they print" > .harness/gate.out

# ---- helpers -------------------------------------------------------------------------------------------------------------------
startdb() {
  CSTARTED=1
  bg "dk run -d --pull never --name $CN -p 127.0.0.1:20531:5432 --env-file .harness/pg.env $IMG" .harness/docker-run.log
  [ "$RE" = 0 ] || die "the PostgreSQL container did not start: $(tail -2 .harness/docker-run.log)"
  RSTARTED=1
  bg "dk run -d --pull never --name $RN -p 127.0.0.1:20532:6379 $RIMG" .harness/docker-run-redis.log
  [ "$RE" = 0 ] || die "the Redis container did not start: $(tail -2 .harness/docker-run-redis.log)"
  local i=0; while ! dk exec "$CN" pg_isready -U tiffinbox -h 127.0.0.1 -q > /dev/null 2>&1; do i=$((i + 1)); [ $i -lt 120 ] || die "PostgreSQL did not accept connections (120 tries)"; sleep 0.5; done
  i=0; while [ "$(dk exec "$RN" redis-cli PING 2> /dev/null)" != PONG ]; do i=$((i + 1)); [ $i -lt 120 ] || die "Redis did not answer PING (120 tries)"; sleep 0.5; done
  DP=$(dk port "$CN" 2> /dev/null | paste -sd'|' -); DR=$(dk port "$RN" 2> /dev/null | paste -sd'|' -)
  [ "$DP" = '5432/tcp -> 127.0.0.1:20531' ] || die "the PostgreSQL container must publish 5432 on 127.0.0.1:20531 alone: $DP"
  [ "$DR" = '6379/tcp -> 127.0.0.1:20532' ] || die "the Redis container must publish 6379 on 127.0.0.1:20532 alone: $DR"
  echo "  the containers: $CN from $IMG (--pull never), published $DP, user tiffinbox, its password from a 0600 file; $RN from $RIMG (--pull never), published $DR, no password - 127.0.0.1 only; pg_isready and PING (cap 120 tries each)"; }
psq() { dk exec "$CN" psql -U tiffinbox -d "$1" -qAt -v ON_ERROR_STOP=1 -c "$2" 2>&1 || die "psql failed on $1: $2"; }
pgdb() { psq postgres "drop database if exists $1 with (force)" > /dev/null; psq postgres "create database $1" > /dev/null
  (umask 077 && printf 'jdbc:postgresql://127.0.0.1:20531/%s?user=tiffinbox&password=%s\n' "$1" "$PW" > .harness/run-pg/secrets/tiffinbox/jdbc-url) || die "the URL was not written"
  PGD=$1; echo "  a fresh database: $1 (psql) · its URL in the config tree (0600, never printed)"; }
pgdrop() { psq postgres "drop database $1 with (force)" > /dev/null; echo "  dropped: $1"; }
rc() { dk exec "$RN" redis-cli "$@" 2>&1 | tr -d '\r'; }
LB=tiffinbox:leaderboard
flush() { [ "$(rc FLUSHALL)" = OK ] || die "redis-cli FLUSHALL failed"; echo "  redis-cli FLUSHALL -> OK · --scan: $(rc --scan | $G -c . || true) keys"; }
board() { echo "  redis-cli ZREVRANGE $LB 0 -1 WITHSCORES: $(rc ZREVRANGE $LB 0 -1 WITHSCORES | paste -sd' ' - | sed -E 's/([A-Za-z]+) ([0-9]+)/\1 \2 ·/g; s/ ·$//')"; }
DEV="--spring.profiles.active=dev --spring.docker.compose.enabled=false --spring.data.redis.host=127.0.0.1 --spring.data.redis.port=20532 --logging.level.tiffinbox=INFO"
HX=0; PH=""
# hj TREE DB PORT STEPS [ARG...]: one harness JVM over TREE's jar, its web server on PORT, on H2 (DB=h2, .harness/run-h2) or on
# PostgreSQL (DB=pg, .harness/run-pg, whose config tree holds the URL); ARG more Spring arguments; at each of the JVM's pauses the
# function named by PH runs (with the pause's number) and its lines are printed after the JVM's own; its exit asserted = $HX
hj() { local tr=$1 db=$2 port=$3 steps=$4 c k=1; shift 4
  c="cd .harness/run-$db && perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 240; exec @ARGV' java $JL -Dstdout.encoding=UTF-8 -cp \"../hc:../$tr/$XD/tiffinbox-web-1.0.0.jar:../$tr/$XD/lib/*\" probe.u14.U14 $steps --tiffinbox.port=$port${1:+ $*} --logging.config=../../harness/logback.xml --spring.main.banner-mode=off"
  echo "\$ $c" | sed 's#\.\./\.\./harness#…/harness#'
  rm -f .harness/run-$db/go; : > .harness/pause.out
  RE=0; (eval "$c") > .harness/h.log 2>&1 < /dev/null & mpid=$!
  while kill -0 "$mpid" 2> /dev/null; do
    if $G -q "^PROBE pause $k: the receipt reads now" .harness/h.log; then
      if [ -n "$PH" ]; then "$PH" $k >> .harness/pause.out 2>&1; fi
      : > .harness/run-$db/go; k=$((k + 1)); fi
    sleep 0.1; done
  wait "$mpid" || RE=$?; mpid=""
  [ "$RE" != 142 ] || die "the harness JVM's alarm fired (exit 142, cap 240 - R.247)"
  hlog .harness/h.log
  sed 's/^/  /' .harness/pause.out
  [ "$(listeners $port)" = 0 ] || die "something still listens on $port after the harness JVM stopped"
  cp .harness/h.log ".harness/h-$tr-$db.log"
  [ "$RE" = "$HX" ] || die "the harness JVM exited $RE, not $HX ($tr, $db, $steps): $($G '^PROBE' .harness/h.log | tail -2 | paste -sd';' -)"; }
NETTY='io.netty.resolver.dns.DnsServerAddressStreamProviders : Can not find io.netty.resolver.dns.macos.MacOSDnsServerAddressStreamProvider'
hlog() {
  $G -oE 'Multiple Spring Data modules found, entering strict repository configuration mode|Found [0-9]+ (JPA|JDBC|Redis) repository interfaces?|HHH000001: Hibernate ORM core version [^ ]+|FlywayExecutor : Database: .*|tiffinbox : (orders cooked|kitchen value): +[0-9]+|Schema validation: missing table \[[a-z_]+\]' "$1" | sed -E 's/FlywayExecutor : //; s/tiffinbox : /tiffinbox: /; s#127\.0\.0\.1:20531/[a-z0-9]+#127.0.0.1:<port>/<db>#' | sed 's/^/  log: /'
  $G -E '^PROBE ' "$1" | mask
  echo "  exit $RE · its log, every line but the harness's own PROBE lines: WARN $($G -c '^WARN ' "$1" || true) (Netty's DNS line on macOS: $($G -cF "$NETTY" "$1" || true)) · ERROR $($G -c '^ERROR ' "$1" || true) · lines naming an Exception or an Error class $($G -v '^PROBE ' "$1" | $G -cE '[A-Za-z]+(Exception|Error)\b' || true)"
  $G '^WARN ' "$1" | $G -vF "$NETTY" | sed -E 's/^WARN +\[[^]]*\] /  its other WARN line: /' | cut -c1-160 | sort; }
NCAP=3
unpub=""; CAPRUN=0
cap() { local nm=$1 i n=$NCAP; shift
  i=1; while [ $i -le $n ]; do CAPRUN=$i; "$@" > .harness/cap.raw 2>&1 || true; [ -z "$pid$mpid$xpid" ] || die "$nm left a process running"
    $G -q '^  \*\*\* ' .harness/cap.raw && { cat .harness/cap.raw >&3; die "$nm stopped (above)"; }
    ! $G -qE 'localhost:[0-9]+|127\.0\.0\.1:(3|4|5|6)[0-9]{4}' .harness/cap.raw || die "R.319: $nm printed a container's port raw"
    ! $G -qF -- "$PW" .harness/cap.raw || die "$nm printed the PostgreSQL password"
    mask < .harness/cap.raw > ".r-$nm.$i"; i=$((i + 1)); done
  CH=$(md5 -q ".r-$nm.1")
  i=2; while [ $i -le $n ]; do [ "$CH" = "$(md5 -q ".r-$nm.$i")" ] || die "$nm drifts across $n runs (diff .r-$nm.1 .r-$nm.$i)"; i=$((i + 1)); done
  mv ".r-$nm.1" ".r-$nm.out"; rm -f ".r-$nm.2" ".r-$nm.3"; CAPN=$n; }
pub() { local nm=$1 h p; h=$(md5 -q ".r-$nm.out"); p=$(awk -v n="$nm" '$1 == n { print $2 }' receipts.md5)
  if [ -z "$p" ]; then printf '  %-9s md5 %s  %s/%s  (no published hash)\n' "$nm" "$h" "$CAPN" "$CAPN"; unpub="$unpub $nm"
  elif [ "$p" = "$h" ]; then printf '  %-9s md5 %s  %s/%s  = published\n' "$nm" "$h" "$CAPN" "$CAPN"
  else printf '  %-9s md5 %s  %s/%s  DIFFERS from the published %s\n' "$nm" "$h" "$CAPN" "$CAPN" "$p"; die "$nm is not the published capture - suspect another JDK, Boot or Maven, a busy machine, a variable of yours, or an edited source; diff .r-$nm.out against its block in README.md"; fi; }
VALS=""
chk() { local nm=$1 o e=0; shift
  o=$(python3 -I -B harness/chk14.py "$nm" "$@") || e=$?
  printf '%s\n' "$o" | $G -v '^VALUES ' > .harness/chk-$nm.out || true
  printf '  chk14 %s: %s checks, FAIL %s\n' "$nm" "$($G -c '^ok ' .harness/chk-$nm.out || true)" "$($G -c '^FAIL ' .harness/chk-$nm.out || true)"
  [ $e = 0 ] || { $G '^FAIL' .harness/chk-$nm.out | head -5 >&3; die "$nm: its check failed (harness/chk14.py)"; }
  VALS="$VALS${VALS:+ · }$nm: $(printf '%s\n' "$o" | sed -n 's/^VALUES //p')"; }
VEXP=0
dockeq() { local v i c n
  i=$(dk images -q --no-trunc 2> /dev/null | sort | paste -sd' ' -); v=$(dk volume ls -q 2> /dev/null | wc -l | tr -d ' ')
  c=$(dk ps -aq --filter label=org.testcontainers=true 2> /dev/null | wc -l | tr -d ' ')
  n=$(find "$M2" -type f | wc -l | tr -d ' ')
  [ "$i" = "$IMGS0" ] || die "$1: the images moved - nothing may be pulled"
  [ "$v" = "$((VOL0 + VEXP))" ] || die "R.322: $1: the volume count is $v, not $VOL0 + $VEXP"
  [ "$c" = 0 ] || die "$1: a Testcontainers container is still there after the run ($c)"
  [ "$n" = "$NF0" ] || die "$1: .m2-demo gained files ($NF0 -> $n) - offline: no"
  echo "  after it: images $NI0 (the same list) · volumes $VOL0 + $VEXP · Testcontainers containers 0 · .m2-demo's files unchanged"; }
MPRE=""
mvnrun() { local d=$1 l=$2 a=$3 e=0 n
  echo "\$ cd $d && ${MPRE:+$MPRE }$MV $a"
  (cd "$d" && eval "${MPRE:+$MPRE }$MV $a") > .harness/$l.log 2>&1 < /dev/null & mpid=$!; wait "$mpid" || e=$?; mpid=""
  [ "$e" != 142 ] || die "$l: Maven's alarm fired (exit 142, cap 600 - R.247)"
  n=$($G -cE '^\[INFO\] Download(ing|ed) from ' .harness/$l.log || true)
  echo "  exit $e · $($G -m1 -oE 'BUILD (SUCCESS|FAILURE)' .harness/$l.log || echo 'no BUILD line') · offline: $( [ "$n" = 0 ] && echo yes || echo "no - $n lines say Maven downloaded") · its alarm's cap: 600 (R.247)"
  [ "$n" = 0 ] || die "$l: Maven downloaded"
  dockeq "$l"; }
results() { $G -E '^\[(INFO|WARNING|ERROR)\] Tests run: [0-9]+, Failures: [0-9]+, Errors: [0-9]+, Skipped: [0-9]+$' "$1" | sed -E 's/^\[[A-Z]+\] /  Surefire'"'"'s Results line: /'; }
SR=tiffinbox-web/target/surefire-reports; SRI=tiffinbox-web/target/surefire-reports-it
pgr() { python3 -I harness/surefire.py "$1" | sed 's/^/  /'; }


# ---- the captures --------------------------------------------------------------------------------------------------------------
tests() { echo "-- the tests: after/ copied to .harness/tests; mvn package with Maven's DOCKER_HOST pointed at nothing (tcp://127.0.0.1:1), offline:"
  rm -rf .harness/tests/tiffinbox-web/target .harness/tests/tiffinbox-core/target
  MPRE="env DOCKER_HOST=tcp://127.0.0.1:1"; mvnrun .harness/tests package "\"$AL\" clean package -pl tiffinbox-web -am"; MPRE=""
  echo "  Surefire's reports, $SR:"; pgr .harness/tests/$SR; echo "  $SRI: $( [ -d .harness/tests/$SRI ] && echo present || echo 'absent - no container test ran')"
  results .harness/package.log
  echo "-- then mvn verify, the anchor's recipe (DOCKER_HOST on the pinned socket, Ryuk off - TESTCONTAINERS_RYUK_DISABLED=true, a receipt home), offline:"
  rm -rf .harness/tests/tiffinbox-web/target .harness/tests/tiffinbox-core/target
  mvnrun .harness/tests verify "\"$AL\" clean verify -pl tiffinbox-web -am"
  echo "  Surefire's reports, $SR:"; pgr .harness/tests/$SR
  echo "  Surefire's reports, $SRI:"; pgr .harness/tests/$SRI
  results .harness/verify.log
  echo "  the verify log: 'Creating container for image' $($G -c 'Creating container for image: ' .harness/verify.log || true) · 'Pulling' $($G -c 'Pulling' .harness/verify.log || true) · its REDIS IT lines:"
  $G '^REDIS IT ' .harness/verify.log | sed 's/^/    /'; }
SIGP=""
phsig() { local p; p=$(sed -n -E 's/^PROBE hold \(.*\): pid ([0-9]+)$/\1/p' .harness/h.log | head -1)
  [ -n "$p" ] || { echo "the receipt at pause $1: no pid line"; return 0; }
  kill -INT "$p" 2> /dev/null && echo "the receipt at pause $1: kill -INT sent to the harness JVM (its pid, read off its own line)"; }
anchor() { local t n
  cat .harness/anchor-tests.out
  echo "-- the jar's libraries (ls lib | wc -l), before/ and after/, and the jars after/ gained or lost (comm, by name):"
  for t in before after; do echo "  $t/: $(ls .harness/$t/$XD/lib | wc -l | tr -d ' ') libraries · spring-data-redis and lettuce in lib/: $(ls .harness/$t/$XD/lib | $G -E '^(spring-data-redis|lettuce-core)-' | paste -sd' ' -)"; done
  echo "  gained: $(comm -13 <(ls .harness/before/$XD/lib) <(ls .harness/after/$XD/lib) | $G -c . || true) · lost: $(comm -23 <(ls .harness/before/$XD/lib) <(ls .harness/after/$XD/lib) | $G -c . || true)"
  echo "-- after/ under the profile dev, on PostgreSQL 18.6 + Redis 8.10.3 (both containers, by the digest), three starts in a row against one Redis, one database:"
  echo "  the overrides on every dev JVM: $DEV (Compose off: no Compose run; the datasource from the config tree, the password never on a command line)"
  echo "  the Redis container's own client: $(rc --version) · INFO server: $(rc INFO server | $G '^redis_version:')"
  flush; pgdb u14a
  for n in 1 2 3; do echo "-- start $n of 3:"
    if [ $n = 3 ]; then PH=phsig; HX=130; hj after pg 20530 http,hold $DEV; PH=""; HX=0
    elif [ $n = 1 ]; then hj after pg 20530 info,http $DEV
    else hj after pg 20530 http $DEV; fi
    board; done
  pgdrop u14a; }
phzset() { echo "the receipt at pause $1, redis-cli (the container's own client):"
  echo "  ZREVRANGE $LB 0 -1 WITHSCORES: $(rc ZREVRANGE $LB 0 -1 WITHSCORES | paste -sd' ' -)"
  echo "  ZSCORE $LB Ravi: $(rc ZSCORE $LB Ravi) · ZREVRANK $LB Sunil: $(rc ZREVRANK $LB Sunil) · ZCARD $LB: $(rc ZCARD $LB) · TYPE $LB: $(rc TYPE $LB) · OBJECT ENCODING $LB: $(rc OBJECT ENCODING $LB)"; }
zset() {
  echo "-- after/ under the profile dev, PostgreSQL + Redis: the board the start filled, by Java (the shipped route, the context's StringRedisTemplate) and by redis-cli at a pause; one JVM:"
  flush; pgdb u14z; PH=phzset; hj after pg 20530 info,http,zset $DEV; PH=""; pgdrop u14z; }
phflip() { echo "the receipt at pause $1, redis-cli: CONFIG GET zset-max-listpack-entries: $(rc CONFIG GET zset-max-listpack-entries | paste -sd' ' -)"
  local k; for k in $(rc --scan --pattern 'h14:z*' | sort); do echo "  $k: ZCARD $(rc ZCARD "$k") · TYPE $(rc TYPE "$k") · OBJECT ENCODING $(rc OBJECT ENCODING "$k")"; done; }
flip() {
  echo "-- the harness's keys (not the anchor's board), after/ under the profile dev, PostgreSQL + Redis; one JVM:"
  flush; pgdb u14f; PH=phflip; hj after pg 20530 flip $DEV; PH=""
  echo "  after the JVM, redis-cli --scan --pattern 'h14:*': $(rc --scan --pattern 'h14:*' | $G -c . || true) keys"; pgdrop u14f; }
phstructs() { echo "the receipt at pause $1, redis-cli:"
  echo "  h14:customer:Ravi: TYPE $(rc TYPE h14:customer:Ravi) · HGETALL $(rc HGETALL h14:customer:Ravi | paste -sd' ' -) · OBJECT ENCODING $(rc OBJECT ENCODING h14:customer:Ravi)"
  echo "  h14:meal-types: TYPE $(rc TYPE h14:meal-types) · SMEMBERS, sorted $(rc SMEMBERS h14:meal-types | sort | paste -sd' ' -) · OBJECT ENCODING $(rc OBJECT ENCODING h14:meal-types)"
  echo "  h14:orders-placed: TYPE $(rc TYPE h14:orders-placed) · GET $(rc GET h14:orders-placed) · OBJECT ENCODING $(rc OBJECT ENCODING h14:orders-placed)"; }
structs() {
  echo "-- the harness's keys (not the anchor's), one structure per beat, after/ under the profile dev, PostgreSQL + Redis; one JVM:"
  flush; pgdb u14s; PH=phstructs; hj after pg 20530 structs $DEV; PH=""
  echo "  after the JVM, redis-cli --scan --pattern 'h14:*': $(rc --scan --pattern 'h14:*' | $G -c . || true) keys"; pgdrop u14s; }
phtwice() { echo "the receipt at pause $1, redis-cli: ZREVRANGE $LB 0 -1 WITHSCORES: $(rc ZREVRANGE $LB 0 -1 WITHSCORES | paste -sd' ' -)"; }
twice() {
  echo "-- the harness calls the shipped Leaderboard.record twice with no reset between (labelled - the start never does: anchor's three starts), after/ under the profile dev, PostgreSQL + Redis; one JVM:"
  flush; pgdb u14t; PH=phtwice; hj after pg 20530 twice $DEV; PH=""
  echo "  after the JVM:"; board; pgdrop u14t; }
EVZ="local k = redis.call('KEYS', '*leaderboard') return redis.call('ZRANGE', k[1], 0, -1, 'WITHSCORES')"
phtrap() { echo "the receipt at pause $1, redis-cli (--no-raw: the bytes as Redis holds them):"
  echo "  --no-raw --scan --pattern '*leaderboard*': $(rc --no-raw --scan --pattern '*leaderboard*' | paste -sd' ' -)"
  echo "  --no-raw EVAL (KEYS finds the key, which holds bytes a shell cannot pass; ZRANGE … WITHSCORES on it): $(rc --no-raw EVAL "$EVZ" 0 | sed -E 's/^[0-9]+\) //' | paste -sd' ' -)"
  echo "  ZSCORE $LB Ravi: ($(rc ZSCORE $LB Ravi)) · EXISTS $LB: $(rc EXISTS $LB)"; }
trap14() {
  echo "-- the harness's fill through Boot's redisTemplate bean (labelled - not the anchor's Leaderboard), after/ under the profile dev, PostgreSQL + Redis; one JVM:"
  flush; pgdb u14x; PH=phtrap; hj after pg 20530 info,trap $DEV; PH=""
  echo "  after the JVM, redis-cli --no-raw --scan --pattern '*leaderboard*': $(rc --no-raw --scan --pattern '*leaderboard*' | $G -c . || true) keys"; pgdrop u14x; }
absent() { local e=0 i c
  echo "-- after/'s jar under the profile dev, PostgreSQL up, Redis absent: --spring.data.redis.port=20539, where nothing listens (lsof: $(listeners 20539) listeners); java -jar, its web server on 20530:"
  pgdb u14b
  echo "\$ cd .harness/run-pg && perl -e '\$SIG{INT}=\"DEFAULT\"; alarm 240; exec @ARGV' java $JL -jar ../after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=20530 --spring.profiles.active=dev --spring.docker.compose.enabled=false --spring.data.redis.host=127.0.0.1 --spring.data.redis.port=20539"
  (cd .harness/run-pg && exec perl -e '$SIG{INT}="DEFAULT"; alarm 240; exec @ARGV' java $JL -jar ../after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=20530 --spring.profiles.active=dev --spring.docker.compose.enabled=false --spring.data.redis.host=127.0.0.1 --spring.data.redis.port=20539) > .harness/absent.log 2>&1 < /dev/null & pid=$!
  wait "$pid" || e=$?; pid=""
  [ "$e" != 142 ] || die "absent: the JVM's alarm fired"
  c=$(curl -s --noproxy '*' -o /dev/null -w '%{http_code}' "http://127.0.0.1:20530/actuator/health" 2> /dev/null || true)
  echo "  the JVM's exit: $e · then curl /actuator/health on 20530: ${c:-none} · listening on 20530: $(listeners 20530)"
  echo "  its log: \"Error creating bean with name 'tiffinBoxServer'\" $($G -c "Error creating bean with name 'tiffinBoxServer'" .harness/absent.log || true) lines · \"RedisConnectionFailureException: Unable to connect to Redis\" $($G -c 'RedisConnectionFailureException: Unable to connect to Redis' .harness/absent.log || true) · \"Application run failed\" $($G -c 'Application run failed' .harness/absent.log || true) · \"Started TiffinBoxApp\" $($G -c 'Started TiffinBoxApp' .harness/absent.log || true) · \"orders cooked\" $($G -c 'orders cooked' .harness/absent.log || true)"
  $G -m1 -oE "Error creating bean with name 'tiffinBoxServer': [A-Za-z ]+" .harness/absent.log | sed 's/^/  its first exception line: /'
  $G -m1 -oE '^Caused by: org\.springframework\.data\.redis\.RedisConnectionFailureException: Unable to connect to Redis' .harness/absent.log | sed 's/^/  its cause: /'
  $G -oE '^Caused by: [a-zA-Z.]+(Exception|Error)' .harness/absent.log | sed 's/^Caused by: //' | paste -sd'<' - | sed 's/^/  the causes, in the order the log names them: /'
  pgdrop u14b; }
default() {
  echo "-- after/ with no profile (TiffinBox's default run): H2 in memory, Docker at nothing (DOCKER_HOST=tcp://127.0.0.1:1), Redis absent (--spring.data.redis.port=20539, nothing listens: $(listeners 20539)); one JVM:"
  DOCKER_HOST=tcp://127.0.0.1:1 hj after h2 20530 info,http,noboard --spring.data.redis.port=20539
  echo "  the docker CLI, pinned, with DOCKER_HOST at nothing: still on the socket - images $(DOCKER_HOST=tcp://127.0.0.1:1 dk images -q 2> /dev/null | wc -l | tr -d ' ') (R.344)"
  echo "-- the 18 under mvn -o package with Docker at nothing (anchor's tests, the same run's package log):"
  results .harness/package.log; }
phren() { case $1 in
  1) psq $PGD "alter table customer rename to customer_renamed" > /dev/null; echo "the receipt at pause 1, psql (a second client, PostgreSQL): alter table customer rename to customer_renamed -> tables named customer $(psq $PGD "select count(*) from pg_tables where tablename = 'customer'") · redis-cli EXISTS 'customers::SimpleKey []': $(rc EXISTS 'customers::SimpleKey []')" ;;
  2) echo "the receipt at pause 2, redis-cli: FLUSHALL -> $(rc FLUSHALL) · EXISTS 'customers::SimpleKey []': $(rc EXISTS 'customers::SimpleKey []') (the cache emptied; the table still renamed)" ;;
  *) psq $PGD "alter table customer_renamed rename to customer" > /dev/null; echo "the receipt at pause 3, psql: renamed back -> tables named customer $(psq $PGD "select count(*) from pg_tables where tablename = 'customer'")" ;; esac; }
notes() { local f
  echo "-- the files this unit does not edit (⚑11), md5 now and md5 of this repository's 3478b30 (git show), and the lines README.md quotes:"
  for f in c8-unit09/exercise/README.md c8-unit09/exercise/SOLUTION.md c8-unit11/README.md c8-unit12/pinned.txt; do echo "  ../$f: md5 $(md5 -q "../$f") · at 3478b30 $(git show "3478b30:$f" | md5 -q)"; done
  echo "  quoted in README.md byte for byte: c8-unit09/exercise/README.md:3 $($G -cxF -- "> $(sed -n '3p' ../c8-unit09/exercise/README.md)" README.md) · SOLUTION.md:3 $($G -cxF -- "> $(sed -n '3p' ../c8-unit09/exercise/SOLUTION.md)" README.md) · c8-unit11/README.md:515 $($G -cxF -- "> $(sed -n '515p' ../c8-unit11/README.md)" README.md) and :516 $($G -cxF -- "> $(sed -n '516p' ../c8-unit11/README.md)" README.md) · c8-unit12/pinned.txt (C8-22) $($G -cF -- "> $(head -1 ../c8-unit12/pinned.txt)" README.md)"
  echo "  $KH: before/ md5 $(md5 -q "before/$KH") · after/ md5 $(md5 -q "after/$KH") · lines naming Course 8, unit 14: $($G -c 'Course 8, unit 14' "after/$KH")"
  echo "-- #119 re-measured (RE-MEASURE 2), after/ under the profile dev, PostgreSQL + Redis: one request caches the list; psql renames the customer table under a running TiffinBox; redis-cli empties the cache; psql renames it back; one JVM:"
  flush; pgdb u14n; PH=phren; hj after pg 20530 rename $DEV; PH=""
  echo "-- then a TiffinBox started with the table renamed (a cold JVM, the same Redis, its cached list still there: --scan $(rc --scan | sort | paste -sd'|' -)):"
  psq $PGD "alter table customer rename to customer_renamed" > /dev/null; echo "  psql: alter table customer rename to customer_renamed"
  HX=1; hj after pg 20530 http $DEV; HX=0
  psq $PGD "alter table customer_renamed rename to customer" > /dev/null; echo "  psql: renamed back"; pgdrop u14n; }
XA=('--spring.datasource.url=jdbc:h2:mem:x14;DB_CLOSE_DELAY=-1' --logging.config=../../harness/logback.xml --logging.level.org.hibernate.orm.core=info --spring.jpa.hibernate.ddl-auto=none --spring.main.banner-mode=off --spring.thymeleaf.check-template-location=false --spring.jpa.properties.jakarta.persistence.schema-generation.scripts.action=create --spring.jpa.properties.jakarta.persistence.schema-generation.scripts.create-target=hibernate-ddl.sql)
seven() { local t i c e a port
  echo "-- Hibernate's schema script over after/'s libraries without Flyway's jars (Course 7's probe.x.XMain, scripts.action=create, a file, never run):"
  rm -f .harness/run/hibernate-ddl.sql
  echo "\$ cd .harness/run && perl -e 'alarm 240; exec @ARGV' java $JL -cp \"../hcx:../lib-nofly/*\" probe.x.XMain \"\${XA[@]}\""
  (cd .harness/run && exec perl -e 'alarm 240; exec @ARGV' java $JL -cp "../hcx:../lib-nofly/*" probe.x.XMain "${XA[@]}") > .harness/x.log 2>&1 < /dev/null & pid=$!; e=0; wait "$pid" || e=$?; pid=""
  [ -f .harness/run/hibernate-ddl.sql ] || { tail -5 .harness/x.log >&3; die "xcheck: no script"; }
  echo "  exit $e · cmp with xcheck.sql (= Course 7's capstone's): $(cmp -s .harness/run/hibernate-ddl.sql xcheck.sql && echo 'the same, byte for byte' || echo differ)"
  for t in before after; do i=0; e=0; [ $t = after ] && port=20530 || port=20533
    echo "-- the seven: $t/'s jar, java -jar, H2 in memory (a fresh JVM), port $port:"
    echo "\$ cd .harness/$t && perl -e 'alarm 240; exec @ARGV' java $JL -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=$port"
    (cd .harness/$t && exec perl -e 'alarm 240; exec @ARGV' java $JL -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=$port) > .harness/seven-run.log 2>&1 < /dev/null & pid=$!
    while [ $i -lt 480 ]; do c=$(curl -s --noproxy '*' -o /dev/null -w '%{http_code}' "http://127.0.0.1:$port/actuator/health/readiness" 2> /dev/null || true); [ "$c" = 200 ] && break
      kill -0 "$pid" 2> /dev/null || { tail -20 .harness/seven-run.log | mask >&3; die "TiffinBox exited before readiness answered 200"; }
      sleep 0.25; i=$((i + 1)); done
    [ "$c" = 200 ] || die "readiness never answered 200 on $port"
    a=$(lsof -nP -a -p "$pid" -iTCP -sTCP:LISTEN 2> /dev/null | awk 'NR > 1 { print $9 }' | sort -u | paste -sd' ' -)
    echo "  GET /actuator/health/readiness -> 200 · GET /actuator/health -> $(curl -s --noproxy '*' -o /dev/null -w '%{http_code}' "http://127.0.0.1:$port/actuator/health") · GET /leaderboard -> $(curl -s --noproxy '*' -o /dev/null -w '%{http_code}' "http://127.0.0.1:$port/leaderboard") · listens on: $a"
    echo "\$ \$CURLSET $port .harness/$t/$TF"
    "$CURLSET" $port .harness/$t/$TF | $G ' -> ' | awk '{ gsub(/"timestamp":"[^"]*"/, "\"timestamp\":\"…\""); print }' > .harness/seven-$t.txt || true
    i=0; while kill -0 "$pid" 2> /dev/null && [ $i -lt 480 ]; do sleep 0.25; i=$((i + 1)); done
    kill -0 "$pid" 2> /dev/null && die "TiffinBox on $port was still running after POST /shutdown"
    wait "$pid" || e=$?; pid=""
    [ "$(listeners $port)" = 0 ] || die "something still listens on $port"
    echo "  GET /dashboard: $($G -E '^GET +/dashboard ' .harness/seven-$t.txt | awk '{ print $4 }')"
    echo "  exit $e · the seven responses: $(wc -l < .harness/seven-$t.txt | tr -d ' ') lines · md5 $(md5 -q .harness/seven-$t.txt) · listening on $port now: 0"
    ! $G -qF -- "$TOKEN" .harness/seven-run.log || die "TiffinBox's log held the token"; done
  echo "  the seven, after/ against before/: lines that differ: $(diff .harness/seven-before.txt .harness/seven-after.txt | $G -c '^[<>]' || true)"; }
where() { case "$1" in "$U") echo "this unit's folder" ;; "$U"/*) echo "${1#"$U"/}" ;; *) echo "outside this unit's folder" ;; esac; }
exsh() { local sh=$1 i=0 e1 d1 e2 d2
  rm -rf .harness/ex; rm -f .harness/ex-*.st .harness/ex-*.out
  case $sh in bash) env -i HOME="$HOME" PATH="$XPATH" /bin/bash --noprofile --norc .harness/ex-drive.sh "$U" > .harness/ex-shell.out 2>&1 < /dev/null & xpid=$! ;;
              zsh) env -i HOME="$HOME" PATH="$XPATH" /bin/zsh -f .harness/ex-drive.sh "$U" > .harness/ex-shell.out 2>&1 < /dev/null & xpid=$! ;; esac
  while kill -0 "$xpid" 2> /dev/null && [ $i -lt 2400 ]; do sleep 0.25; i=$((i + 1)); done
  kill -0 "$xpid" 2> /dev/null && { killtree "$xpid"; die "the exercise's $sh still ran after its cap"; }
  wait "$xpid" || true; xpid=""
  [ -f .harness/ex-readme.st ] && [ -f .harness/ex-sol.st ] || { cat .harness/ex-shell.out .harness/ex-readme.out .harness/ex-sol.out 2> /dev/null | tail -20 >&3; die "the exercise's $sh did not reach the end of both blocks"; }
  read -r e1 d1 < .harness/ex-readme.st; read -r e2 d2 < .harness/ex-sol.st
  echo "in $sh ($( [ $sh = bash ] && echo '/bin/bash --noprofile --norc' || echo '/bin/zsh -f')) - the README's lines, the block's exit $e1:"; sed -E 's/[[:space:]]+$//; s/^/    /' .harness/ex-readme.out
  echo "  then the solution's lines, in the same shell - the block's exit $e2:"; sed -E 's/[[:space:]]+$//; s/^/    /' .harness/ex-sol.out
  echo "  the shell is now in: $(where "$d2") · the shell's own output: $(wc -l < .harness/ex-shell.out | tr -d ' ') lines · listening on 20532 afterwards: $(listeners 20532) · a container named $EN: $(dk ps -aq --filter name=^/$EN\$ | $G -c . || true)"; }
exercise() {
  printf '%s\n' "$SETUP" > .harness/ex-readme.sh; printf '%s\n' "$SOL" > .harness/ex-sol.sh
  printf '%s\n' 'cd "$1" || exit 1' '. "$1/.harness/ex-readme.sh" > "$1/.harness/ex-readme.out" 2>&1 < /dev/null' 'echo "$? $PWD" > "$1/.harness/ex-readme.st"' 'cd "$1" || exit 1' '. "$1/.harness/ex-sol.sh" > "$1/.harness/ex-sol.out" 2>&1 < /dev/null' 'echo "$? $PWD" > "$1/.harness/ex-sol.st"' > .harness/ex-drive.sh
  echo "exercise/README.md's $(printf '%s\n' "$SETUP" | $G -c .) lines, then exercise/SOLUTION.md's, as written, one after the other in ONE env -i shell (HOME and the PATH this script was started with), started in this folder:"
  echo "the solution's line that differs:"; diff <(printf '%s\n' "$SETUP") <(printf '%s\n' "$SOL") | $G '^>' | sed 's/^> /  $ /'
  exsh bash; exsh zsh; }


VEXP=0
NCAP=1; cap exercise exercise; chk exercise .r-exercise.out "$EXW" "$EXQ"
for f in exercise/README.md exercise/SOLUTION.md; do
  w=$(python3 -I -B harness/chk14.py wib .r-exercise.out "$f"); [ "$(wib "$f")" = "$w" ] || die "$f's \"What it prints\" block is not what its lines printed: $(diff <(wib "$f") <(printf '%s\n' "$w") | head -3 | paste -sd' ' -)"; done
echo "  exercise: each file's \"What it prints\" block = what its lines printed (bash's; zsh's the same - chk14)"
pub exercise
export DOCKER_HOST="$DH" TESTCONTAINERS_RYUK_DISABLED=true; tests > .harness/anchor-tests.raw 2>&1 || true; unset DOCKER_HOST TESTCONTAINERS_RYUK_DISABLED
$G -q '^  \*\*\* ' .harness/anchor-tests.raw && { cat .harness/anchor-tests.raw >&3; die "the tests stopped (above)"; }
mask < .harness/anchor-tests.raw > .harness/anchor-tests.out
echo "  the tests (anchor's Maven half): run once in this run of record - their 3/3 is across the runs; the three anchor captures each carry these lines"
startdb; VEXP=0
echo "  $(rc --version) · INFO server: $(rc INFO server | $G '^redis_version:')"
NCAP=3
cap anchor anchor; chk anchor .r-anchor.out; pub anchor
cap zset zset; chk zset .r-zset.out; pub zset
cap flip flip; chk flip .r-flip.out; pub flip
cap structs structs; chk structs .r-structs.out; pub structs
cap twice twice; chk twice .r-twice.out; pub twice
cap trap trap14; chk trap .r-trap.out; pub trap
cap absent absent; chk absent .r-absent.out; pub absent
cap default default; chk default .r-default.out; pub default
cap notes notes; chk notes .r-notes.out; pub notes
cap seven seven; chk seven .r-seven.out "$S466"; pub seven
# R.302: every line of README.md's ```text blocks is a line a run printed; the values line is the captures'
cat .r-*.out .harness/chk-*.out .harness/gate.out 2> /dev/null | sed -E 's/^ +//' > .harness/printed.txt
TX=$(awk '/^```text$/ { b = 1; next } b && /^```$/ { b = 0; next } b && NF { sub(/^ +/, ""); print }' README.md | while IFS= read -r l; do $G -qxF -- "$l" .harness/printed.txt || printf '%s\n' "$l"; done | head -3 | cut -c1-160 | paste -sd';' -)
[ "$($G -c '^```text$' README.md)" -gt 0 ] && [ -z "$TX" ] || die "R.302: README.md's text blocks must be lines the runs printed - not printed: ${TX:-no text block}"
VS="the values the video may say - $VALS"
printf '%s\n' "$VS" > .harness/values.txt
$G -qxF -- "$VS" README.md || die "README.md does not state the values these captures give (the line is in .harness/values.txt)"
echo "  R.302: README.md's $($G -c '^```text$' README.md) text blocks - every line one the runs printed; the values line = the captures' ($(wc -c < .harness/values.txt | tr -d ' ') bytes)"
for f in .r-*.out; do
  ! $G -qE '/Users/|/private/|/var/folders/' "$f" || die "$f holds an absolute path"
  ! $G -qE ' (with PID|started by) | in [0-9.]+ seconds|Time elapsed: [0-9]|Total time: +[0-9]|execution time [0-9]|[0-9] ms\b|PT[0-9]|TTL [1-9]' "$f" || die "R.402: $f holds a time, unmasked"
  ! $G -qE '^ *[0-9]{4}-[0-9]{2}-[0-9]{2}[T ][0-9]|[0-9][0-9]:[0-9][0-9]:[0-9][0-9]\.[0-9]' "$f" || die "$f holds a log time"
  ! $G -qE '^ +at [a-z]' "$f" || die "$f holds a stack frame"
  ! $G -qE 'jdbc:h2:mem:[0-9a-f]{8}' "$f" || die "$f holds H2's generated database name, unmasked"
  ! $G -E '^ *\$ .*(^|[ (])(java|mvn) ' "$f" | $G -vF -- "perl -e '" > /dev/null || die "$f starts a JVM or Maven without its alarm (R.247)"
  ! $G -qF -- "$TOKEN" "$f" || die "$f holds the shutdown token"
  ! $G -qF -- "$PW" "$f" || die "$f holds the PostgreSQL password"; done
DC=$(cat .r-*.out | python3 -I -B -c 'import importlib.util,sys; s=importlib.util.spec_from_file_location("d","harness/dur8.py"); m=importlib.util.module_from_spec(s); s.loader.exec_module(m); print(len(m.DUR.findall(sys.stdin.read())))')
DR=$(awk '/^```text$/ { b = 1; next } b && /^```$/ { b = 0; next } b' README.md | python3 -I -B -c 'import importlib.util,sys; s=importlib.util.spec_from_file_location("d","harness/dur8.py"); m=importlib.util.module_from_spec(s); s.loader.exec_module(m); print(len(m.DUR.findall(sys.stdin.read())))')
[ "$DC" = 0 ] && [ "$DR" = 0 ] || die "R.402: dur8 finds $DC word(s) in the captures and $DR in README.md's text blocks - 0 is the rule"
[ -z "$(find . -path ./.m2-demo -prune -o -path ./.harness -prune -o \( -name '*.mv.db' -o -name '*.trace.db' \) -print)" ] || die "an H2 database file exists outside .harness (R.195)"
echo "  hygiene: dur8 over the captures and README.md's text blocks 0 words; no path, time, TTL count, log time, stack frame, H2 database name, raw port, pid, token or password in any capture; every JVM and Maven under its alarm; no H2 file outside .harness"
# ---- the end: the containers, Testcontainers, the volumes, the images, the trees, the ports -------------------------------------
dk rm -fv "$RN" > /dev/null 2>&1 || die "the Redis container could not be removed"; RSTARTED=""
dk rm -fv "$CN" > /dev/null 2>&1 || die "the PostgreSQL container could not be removed"; CSTARTED=""
tcrm; [ -z "$(dk ps -aq --filter label=org.testcontainers=true 2> /dev/null)" ] || die "a Testcontainers container is still there"
[ -z "$(dk ps -aq --filter name=^/$EN\$ 2> /dev/null)" ] || die "the exercise's container $EN is still there"
VOL1=$(dk volume ls -q 2> /dev/null | wc -l | tr -d ' '); IMGS1=$(dk images -q --no-trunc 2> /dev/null | sort | paste -sd' ' -)
[ "$VOL1" = "$VOL0" ] || die "R.322: the volume count moved, $VOL0 -> $VOL1"
[ "$IMGS1" = "$IMGS0" ] || die "the images moved over this run - nothing may be pulled"
[ ! -e "$HOME/.testcontainers.properties" ] || die "R.318: ~/.testcontainers.properties appeared over this run"
echo "  docker at the end: $CN and $RN removed with their volumes (rm -fv); the exercise's $EN gone; Testcontainers containers 0; volumes $VOL0 -> $VOL1; images $NI0, the same list (nothing pulled)"
pin before-tree before end; pin after-tree after end
for p in $PORTS; do [ "$(listeners $p)" = 0 ] || die "something listens on $p at the end"; done
echo "  ports: nothing listens on 20530-20539 at the end - the containers bound 20531 and 20532 (the exercise's Redis 20532 before them) and are gone; TiffinBox bound 20530 (after/) and 20533 (before/, the seven) and stopped; 20539 never bound (Redis absent points there); 20534-20538 never bound"
[ -z "$unpub" ] || die "no published hash for:$unpub - check the captures, then copy the md5s above into receipts.md5 and run again"
echo "c8-unit14: every capture = published (JVM captures 3/3 in this run; exercise and the tests once per run); every spoken number asserted by chk14.py; before/ and after/ = their pins; the volume count and the images unchanged"
